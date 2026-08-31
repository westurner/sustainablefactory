"""OxiRS search and RDF graph backend implementation for docindex."""

from __future__ import annotations

import json
import logging
import os
import re
from datetime import UTC, datetime
from pathlib import Path
from typing import Any

import httpx
from pydantic import BaseModel, Field

# We import pyoxigraph dynamically to avoid strict runtime requirement
# if the package is used in environments that only use the HTTP client.
try:
    import pyoxigraph as ox

    _HAS_PYOXIGRAPH = True
except ImportError:
    _HAS_PYOXIGRAPH = False

from ..config import Document, DocumentType, IndexingStats, SearchResult
from .base import BaseSearchBackend

logger = logging.getLogger(__name__)

# Constants for Ontologies
DOCINDEX_NS = "http://westurner.github.io/sustainablefactory/docindex/#"
RDF_TYPE = "http://www.w3.org/1999/02/22-rdf-syntax-ns#type"
XSD_DATETIME = "http://www.w3.org/2001/XMLSchema#dateTime"


class OxiRSConfig(BaseModel):
    """Configuration for OxiRS backend connection."""

    url: str | None = Field(default=None, description="HTTP endpoint for OxiRS SPARQL")
    storage_path: str | None = Field(
        default=None, description="Path to local pyoxigraph database"
    )
    batch_size: int = Field(default=100, description="Batch size for indexing")
    enabled: bool = Field(default=True, description="Enable OxiRS indexing")

    @classmethod
    def from_env(cls) -> OxiRSConfig:
        """Load configuration from environment variables."""
        return cls(
            url=os.getenv("OXIRS_URL"),
            storage_path=os.getenv("OXIRS_STORAGE_PATH"),
            batch_size=int(os.getenv("OXIRS_BATCH_SIZE", "100")),
            enabled=os.getenv("OXIRS_ENABLED", "true").lower() == "true",
        )


class OxiRSBackend(BaseSearchBackend):
    """Search and indexing backend targeting OxiRS (RDF Graph Database)."""

    def __init__(self, config: OxiRSConfig | None = None):
        """Initialize OxiRS client."""
        self.config = config or OxiRSConfig.from_env()
        self._local_store: ox.Store | None = None
        self._synonyms: dict[str, dict[str, list[str]]] = {}

        if not self.config.url and not self.config.storage_path:
            # Fallback to an in-memory local store
            logger.info("Initializing in-memory pyoxigraph Store for OxiRSBackend")
            if _HAS_PYOXIGRAPH:
                self._local_store = ox.Store()
            else:
                logger.warning(
                    "pyoxigraph is not installed. Local store operations will fail."
                )
        elif self.config.storage_path:
            logger.info(
                f"Initializing local pyoxigraph Store at {self.config.storage_path}"
            )
            if _HAS_PYOXIGRAPH:
                # Ensure directory exists
                os.makedirs(self.config.storage_path, exist_ok=True)
                self._local_store = ox.Store(self.config.storage_path)
            else:
                logger.error(
                    "pyoxigraph is required for local storage_path but not installed."
                )

    def verify_connection(self) -> bool:
        """Verify connection to the backend."""
        if self._local_store is not None:
            return True
        if self.config.url:
            try:
                with httpx.Client() as client:
                    res = client.get(self.config.url, timeout=5.0)
                    return res.status_code < 400
            except httpx.HTTPError as e:
                logger.warning(f"OxiRS remote endpoint unreachable: {e}")
                return False
            except OSError as e:
                logger.warning(f"OxiRS remote endpoint unavailable: {e}")
                return False
            except Exception:
                logger.exception("Unexpected error verifying OxiRS remote endpoint")
                return False
        return False

    def _verify_connection(self) -> bool:
        """Backward compatibility alias."""
        return self.verify_connection()

    def _get_graph_uri(self, index_name: str) -> str:
        """Get the named graph URI for a specific index."""
        return (
            f"http://westurner.github.io/sustainablefactory/docindex/graph/{index_name}"
        )

    @staticmethod
    def _is_missing_graph_error(error: Exception) -> bool:
        """Return whether an OxiRS error indicates an absent graph."""
        message = str(error).lower()
        return (
            "does not exist" in message
            or "not exist" in message
            or "not found" in message
        )

    def _get_doc_uri(self, doc_id: str) -> str:
        """Get the subject URI for a specific document."""
        # Sanitize URI components
        safe_id = doc_id.replace(":", "_").replace("/", "_").replace("#", "_")
        return f"http://westurner.github.io/sustainablefactory/docindex/doc/{safe_id}"

    def _get_source_uri(self, doc: Any) -> str:
        """Return a stable URI for the source document."""
        metadata = getattr(doc, "metadata", None)
        source_file = getattr(metadata, "source_file", None)
        if source_file:
            return Path(source_file).expanduser().resolve().as_uri()
        if getattr(doc, "url", None):
            return doc.url
        return self._get_doc_uri(str(doc.id))

    @staticmethod
    def _make_search_snippet(
        content: str,
        title: str,
        terms: list[str],
        max_length: int = 200,
    ) -> tuple[str, list[str]]:
        """Return a context window around the first matched term."""
        for field_name, field_value in (("content", content), ("title", title)):
            for term in terms:
                match = re.search(re.escape(term), field_value, re.IGNORECASE)
                if match is None:
                    continue

                start = max(0, match.start() - max_length // 2)
                end = min(len(field_value), start + max_length)
                if end - start < max_length:
                    start = max(0, end - max_length)
                snippet = field_value[start:end]
                if start:
                    snippet = f"...{snippet}"
                if end < len(field_value):
                    snippet = f"{snippet}..."
                return snippet, [field_name]

        return content[:max_length], ["content"]

    def create_or_update_index(
        self, index_name: str, settings: Any | None = None, primary_key: str = "id"
    ) -> dict[str, Any]:
        """Create or update a named graph index."""
        logger.info(f"OxiRS: Initialized/verified index graph for {index_name}")
        return {"index": index_name, "status": "ready"}

    def clear_index(self, index_name: str) -> dict[str, Any]:
        """Clear all documents from the named graph index."""
        graph_uri = self._get_graph_uri(index_name)
        # Clear graph via SPARQL Update
        query = f"DROP SILENT GRAPH <{graph_uri}>"
        if self._local_store is not None:
            # Recreate empty graph
            self._local_store.update(query)
            self._local_store.update(f"CREATE GRAPH <{graph_uri}>")
        elif self.config.url:
            self._execute_http_update(query)
            self._execute_http_update(f"CREATE GRAPH <{graph_uri}>")
        return {"status": "success"}

    def _delete_document_quads(
        self, index_name: str, doc_id: str
    ) -> None:  # pragma: no cover
        """Helper to delete triples related to a document in a specific graph."""
        doc_uri = self._get_doc_uri(doc_id)
        graph_uri = self._get_graph_uri(index_name)

        if self._local_store is not None:
            # Delete in local store
            subject_node = ox.NamedNode(doc_uri)
            graph_node = ox.NamedNode(graph_uri)

            # Retrieve all quads with this subject in this graph
            to_remove = list(
                self._local_store.quads_for_pattern(
                    subject_node, None, None, graph_node
                )
            )
            for q in to_remove:
                self._local_store.remove(q)
        elif self.config.url:
            # Delete via HTTP SPARQL Update
            update_query = f"""
            DELETE WHERE {{
                GRAPH <{graph_uri}> {{
                    <{doc_uri}> ?p ?o .
                }}
            }}
            """
            self._execute_http_update(update_query)

    def _get_document_quads_and_triples(self, index_name: str, doc: Any) -> tuple:
        """Helper to generate list of local quads and remote SPARQL triple strings for a document."""
        doc_uri = self._get_doc_uri(doc.id)
        graph_uri = self._get_graph_uri(index_name)

        quads = []
        if _HAS_PYOXIGRAPH:
            g = ox.NamedNode(graph_uri)
            s = ox.NamedNode(doc_uri)
            quads = [
                ox.Quad(
                    s, ox.NamedNode(RDF_TYPE), ox.NamedNode(f"{DOCINDEX_NS}Document"), g
                ),
                ox.Quad(s, ox.NamedNode(f"{DOCINDEX_NS}id"), ox.Literal(doc.id), g),
                ox.Quad(
                    s, ox.NamedNode(f"{DOCINDEX_NS}type"), ox.Literal(str(doc.type)), g
                ),
                ox.Quad(
                    s, ox.NamedNode(f"{DOCINDEX_NS}title"), ox.Literal(doc.title), g
                ),
                ox.Quad(
                    s, ox.NamedNode(f"{DOCINDEX_NS}content"), ox.Literal(doc.content), g
                ),
                ox.Quad(
                    s,
                    ox.NamedNode(f"{DOCINDEX_NS}filename"),
                    ox.Literal(doc.filename),
                    g,
                ),
                ox.Quad(
                    s,
                    ox.NamedNode(f"{DOCINDEX_NS}sourceUri"),
                    ox.Literal(self._get_source_uri(doc)),
                    g,
                ),
            ]
            if getattr(doc, "url", None):
                quads.append(
                    ox.Quad(
                        s, ox.NamedNode(f"{DOCINDEX_NS}url"), ox.Literal(doc.url), g
                    )
                )
            if getattr(doc, "summary", None):
                quads.append(
                    ox.Quad(
                        s,
                        ox.NamedNode(f"{DOCINDEX_NS}summary"),
                        ox.Literal(doc.summary),
                        g,
                    )
                )
            if getattr(doc, "build_id", None):
                quads.append(
                    ox.Quad(
                        s,
                        ox.NamedNode(f"{DOCINDEX_NS}buildId"),
                        ox.Literal(doc.build_id),
                        g,
                    )
                )
            if getattr(doc, "metadata", None) and getattr(
                doc.metadata, "date_indexed", None
            ):
                dt_str = doc.metadata.date_indexed.isoformat()
                quads.append(
                    ox.Quad(
                        s,
                        ox.NamedNode(f"{DOCINDEX_NS}dateIndexed"),
                        ox.Literal(dt_str, datatype=ox.NamedNode(XSD_DATETIME)),
                        g,
                    )
                )

        triples = [
            f"<{doc_uri}> a <{DOCINDEX_NS}Document> ;",
            f"  <{DOCINDEX_NS}id> {self._to_sparql_literal(doc.id)} ;",
            f"  <{DOCINDEX_NS}type> {self._to_sparql_literal(str(doc.type))} ;",
            f"  <{DOCINDEX_NS}title> {self._to_sparql_literal(doc.title)} ;",
            f"  <{DOCINDEX_NS}content> {self._to_sparql_literal(doc.content)} ;",
            f"  <{DOCINDEX_NS}filename> {self._to_sparql_literal(doc.filename)} ;",
            f"  <{DOCINDEX_NS}sourceUri> {self._to_sparql_literal(self._get_source_uri(doc))} ;",
        ]
        if getattr(doc, "url", None):
            triples.append(f"  <{DOCINDEX_NS}url> {self._to_sparql_literal(doc.url)} ;")
        if getattr(doc, "summary", None):
            triples.append(
                f"  <{DOCINDEX_NS}summary> {self._to_sparql_literal(doc.summary)} ;"
            )
        if getattr(doc, "build_id", None):
            triples.append(
                f"  <{DOCINDEX_NS}buildId> {self._to_sparql_literal(doc.build_id)} ;"
            )
        if getattr(doc, "metadata", None) and getattr(
            doc.metadata, "date_indexed", None
        ):
            dt_str = doc.metadata.date_indexed.isoformat()
            triples.append(
                f'  <{DOCINDEX_NS}dateIndexed> "{dt_str}"^^<{XSD_DATETIME}> ;'
            )

        triples_str = "\n".join(triples).rstrip(" ;") + " ."
        return quads, triples_str

    def _add_document_quads(
        self, index_name: str, doc: Document
    ) -> None:  # pragma: no cover
        """Helper to map a Document to RDF triples/quads and insert them."""
        self.add_documents(index_name, [doc])

    def _to_sparql_literal(self, value: str) -> str:
        """Escape string content for safe SPARQL queries."""
        escaped = value.replace("\\", "\\\\").replace('"', '\\"').replace("\n", "\\n")
        return f'"{escaped}"'

    def _execute_http_post(self, url: str, **kwargs) -> Any:
        """Execute HTTP POST request using client context manager to support connection pooling and mocking."""
        import httpx

        with httpx.Client() as client:
            return client.post(url, **kwargs)

    def _execute_http_update(self, query: str) -> None:
        """Send a SPARQL Update POST request."""
        if not self.config.url:
            raise ValueError("OxiRS HTTP URL is not configured.")

        # OxiRS standard update endpoint is typically /update or /
        update_url = self.config.url
        if not update_url.endswith("/update") and not update_url.endswith("/"):
            # try to guess if it's a raw port or base url
            update_url = f"{update_url.rstrip('/')}/update"

        try:
            response = self._execute_http_post(
                update_url,
                headers={"Content-Type": "application/sparql-update"},
                content=query.encode("utf-8"),
                timeout=30.0,
            )
            response.raise_for_status()
        except httpx.HTTPError:
            logger.exception("OxiRS HTTP SPARQL update failed")
            raise

    def add_documents(
        self,
        index_name: str,
        documents: list[Any],
        batch_size: int | None = None,
        progress: bool = False,
        total_estimate: int | None = None,
    ) -> IndexingStats:
        """Add documents to OxiRS graph indices in bulk."""
        start_time = datetime.now(UTC)
        indexed = 0
        errors = 0
        total = len(documents)

        if not documents:  # pragma: no cover
            end_time = datetime.now(UTC)
            return IndexingStats(
                total_documents=0,
                indexed_documents=0,
                skipped_documents=0,
                errors=0,
                start_time=start_time,
                end_time=end_time,
                duration_seconds=0.0,
            )

        graph_uri = self._get_graph_uri(index_name)

        if self._local_store is not None:
            quads_to_remove = []
            quads_to_add = []
            for doc in documents:
                try:
                    doc_id = doc.id
                    doc_uri = self._get_doc_uri(doc_id)
                    g = ox.NamedNode(graph_uri)
                    s = ox.NamedNode(doc_uri)
                    quads, _ = self._get_document_quads_and_triples(index_name, doc)
                except (AttributeError, TypeError, ValueError) as e:
                    logger.warning(
                        "Skipping malformed document %r for local OxiRS: %s",
                        getattr(doc, "id", "unknown"),
                        e,
                    )
                    errors += 1
                    continue

                quads_to_remove.extend(
                    list(self._local_store.quads_for_pattern(s, None, None, g))
                )
                quads_to_add.extend(quads)
                indexed += 1

            for q in quads_to_remove:
                self._local_store.remove(q)
            if quads_to_add:
                self._local_store.extend(quads_to_add)

        elif self.config.url:
            doc_ids = []
            triples_blocks = []
            for doc in documents:
                try:
                    doc_id = doc.id
                    doc_ids.append(doc_id)
                    _, triples_str = self._get_document_quads_and_triples(
                        index_name, doc
                    )
                    triples_blocks.append(triples_str)
                    indexed += 1
                except (AttributeError, TypeError, ValueError) as e:
                    logger.warning(
                        "Skipping malformed document %r for remote OxiRS: %s",
                        getattr(doc, "id", "unknown"),
                        e,
                    )
                    errors += 1

            if doc_ids:
                ids_filter = ", ".join(self._to_sparql_literal(i) for i in doc_ids)
                delete_query = f"""
                PREFIX docindex: <{DOCINDEX_NS}>
                WITH <{graph_uri}>
                DELETE {{
                    ?s ?p ?o .
                }} WHERE {{
                    ?s docindex:id ?doc_id .
                    ?s ?p ?o .
                    FILTER(?doc_id IN ({ids_filter}))
                }}
                """

                insert_query = f"""
                PREFIX docindex: <{DOCINDEX_NS}>
                INSERT DATA {{
                    GRAPH <{graph_uri}> {{
                        {"  ".join(triples_blocks)}
                    }}
                }}
                """

                bulk_query = f"{delete_query} ;\n{insert_query}"
                try:
                    self._execute_http_update(bulk_query)
                except httpx.HTTPError:
                    logger.exception("Failed to execute bulk OxiRS SPARQL update")
                    errors += len(doc_ids)
                    indexed -= len(doc_ids)

        end_time = datetime.now(UTC)
        duration = (end_time - start_time).total_seconds()

        return IndexingStats(
            total_documents=total,
            indexed_documents=indexed,
            skipped_documents=0,
            errors=errors,
            start_time=start_time,
            end_time=end_time,
            duration_seconds=duration,
        )

    def search(
        self,
        index_name: str,
        query: str,
        limit: int = 20,
        offset: int = 0,
        filters: str | None = None,
        sort: list[str] | None = None,
    ) -> list[SearchResult]:
        """Search documents in named graph index via SPARQL query."""
        graph_uri = self._get_graph_uri(index_name)

        terms = [term for term in query.split() if term]
        if terms:
            term_filters = []
            for term in terms:
                pattern = json.dumps(re.escape(term))
                term_filters.append(
                    f'(regex(str(?content), {pattern}, "i") || '
                    f'regex(str(?title), {pattern}, "i"))'
                )
            search_filter = " && ".join(term_filters)
        else:
            search_filter = "true"

        sparql_query = f"""
        PREFIX docindex: <{DOCINDEX_NS}>

        SELECT ?id ?type ?title ?url ?sourceUri ?content ?filename ?dateIndexed WHERE {{
            GRAPH <{graph_uri}> {{
                ?subject a docindex:Document ;
                         docindex:id ?id ;
                         docindex:type ?type ;
                         docindex:title ?title ;
                         docindex:content ?content ;
                         docindex:filename ?filename .
                OPTIONAL {{ ?subject docindex:url ?url }}
                OPTIONAL {{ ?subject docindex:sourceUri ?sourceUri }}
                OPTIONAL {{ ?subject docindex:dateIndexed ?dateIndexed }}

                # Check for query match in content or title (case-insensitive)
                FILTER ({search_filter})
            }}
        }}
        LIMIT {limit} OFFSET {offset}
        """

        results = []

        if self._local_store is not None:
            # Query local store
            solutions = self._local_store.query(sparql_query)
            # solutions is an iterator of BindingPlayloads
            for sol in solutions:
                # pyoxigraph solution bindings can be queried by variable names
                id_val = str(sol["id"].value)
                type_val = DocumentType(str(sol["type"].value))
                title_val = str(sol["title"].value)
                content_val = str(sol["content"].value)
                try:
                    url_binding = sol["url"]
                except KeyError:
                    url_binding = None
                url_val = str(url_binding.value) if url_binding is not None else None
                try:
                    source_binding = sol["sourceUri"]
                except KeyError:
                    source_binding = None
                source_uri = (
                    str(source_binding.value)
                    if source_binding is not None
                    else url_val or self._get_doc_uri(id_val)
                )
                snippet, matched_fields = self._make_search_snippet(
                    content_val, title_val, terms
                )

                results.append(
                    SearchResult(
                        id=id_val,
                        type=type_val,
                        title=title_val,
                        url=url_val,
                        source_uri=source_uri,
                        content_snippet=snippet,
                        relevance_score=1.0,  # Regex doesn't supply relevance score
                        matched_fields=matched_fields,
                    )
                )
        elif self.config.url:
            # Query HTTP endpoint
            query_url = self.config.url
            if not query_url.endswith("/query") and not query_url.endswith("/"):
                query_url = f"{query_url.rstrip('/')}/query"

            try:
                response = self._execute_http_post(
                    query_url,
                    data={"query": sparql_query},
                    headers={"Accept": "application/sparql-results+json"},
                    timeout=30.0,
                )
                response.raise_for_status()
                json_data = response.json()

                for binding in json_data.get("results", {}).get("bindings", []):
                    id_val = binding["id"]["value"]
                    type_val = DocumentType(binding["type"]["value"])
                    title_val = binding["title"]["value"]
                    content_val = binding["content"]["value"]
                    url_val = binding.get("url", {}).get("value")
                    source_uri = binding.get("sourceUri", {}).get("value") or (
                        url_val or self._get_doc_uri(id_val)
                    )
                    snippet, matched_fields = self._make_search_snippet(
                        content_val, title_val, terms
                    )

                    results.append(
                        SearchResult(
                            id=id_val,
                            type=type_val,
                            title=title_val,
                            url=url_val,
                            source_uri=source_uri,
                            content_snippet=snippet,
                            relevance_score=1.0,
                            matched_fields=matched_fields,
                        )
                    )
            except (httpx.HTTPError, KeyError, TypeError, ValueError):
                logger.exception("OxiRS HTTP SPARQL query failed")
                raise

        return results

    def delete_index(self, index_name: str) -> bool:
        """Clear all triples associated with this graph index."""
        graph_uri = self._get_graph_uri(index_name)

        if self._local_store is not None:
            graph_node = ox.NamedNode(graph_uri)
            # Remove all quads belonging to this named graph
            quads = list(
                self._local_store.quads_for_pattern(None, None, None, graph_node)
            )
            for q in quads:
                self._local_store.remove(q)
            logger.info(f"OxiRS: Deleted named graph for {index_name}")
            return True
        elif self.config.url:
            update_query = f"DROP GRAPH <{graph_uri}>"
            try:
                self._execute_http_update(update_query)
                return True
            except Exception:
                logger.exception("Failed to delete OxiRS index %s", index_name)
                return False
        return False

    def get_index_stats(self, index_name: str) -> dict[str, Any]:
        """Count unique document subjects in the index named graph."""
        graph_uri = self._get_graph_uri(index_name)
        sparql_query = f"""
        PREFIX docindex: <{DOCINDEX_NS}>
        SELECT (COUNT(DISTINCT ?s) AS ?count) WHERE {{
            GRAPH <{graph_uri}> {{
                ?s a docindex:Document .
            }}
        }}
        """
        count = 0

        if self._local_store is not None:
            solutions = self._local_store.query(sparql_query)
            for sol in solutions:
                count = int(sol["count"].value)
        elif self.config.url:
            query_url = self.config.url
            if not query_url.endswith("/query") and not query_url.endswith("/"):
                query_url = f"{query_url.rstrip('/')}/query"
            try:
                response = self._execute_http_post(
                    query_url,
                    data={"query": sparql_query},
                    headers={"Accept": "application/sparql-results+json"},
                    timeout=10.0,
                )
                response.raise_for_status()
                json_data = response.json()
                bindings = json_data.get("results", {}).get("bindings", [])
                if bindings:
                    count = int(bindings[0]["count"]["value"])
            except Exception:
                logger.exception("Failed to get stats for OxiRS index")

        return {"numberOfDocuments": count, "isIndexing": False}

    # Synonyms / Mock implementations for interface compatibility
    def get_synonyms(self, index_name: str) -> dict[str, list[str]]:
        """Get synonyms (Mocked in OxiRS)."""
        return self._synonyms.get(index_name, {})

    def update_synonyms(self, index_name: str, synonyms: dict[str, list[str]]) -> Any:
        """Update synonyms (Mocked in OxiRS)."""
        self._synonyms[index_name] = synonyms
        return {"status": "success"}

    def clear_synonyms(self, index_name: str) -> Any:
        """Clear synonyms (Mocked in OxiRS)."""
        self._synonyms[index_name] = {}
        return {"status": "success"}

    # Milli Compatibility Layer methods
    def _submit_batches(
        self,
        index_name: str,
        documents: list[Document],
        batch_size: int,
        pbar=None,
    ) -> tuple:
        """Compatibility submission method for pipelined indexing."""
        n_submitted = 0
        n_errors = 0
        for doc in documents:
            try:
                self._add_document_quads(index_name, doc)
                n_submitted += 1
            except (AttributeError, TypeError, ValueError) as e:
                logger.warning(
                    "Failed to submit malformed document %r to OxiRS: %s",
                    getattr(doc, "id", "unknown"),
                    e,
                )
                n_errors += 1
            if pbar is not None:
                pbar.update(1)
        return [], n_submitted, n_errors

    def _finalize_tasks(
        self,
        index_name: str,
        submitted_tasks: list[tuple],
        n_submitted: int,
        n_errors: int,
        start_time: datetime,
        progress: bool = False,
    ) -> IndexingStats:
        """Compatibility finalizer method returning IndexingStats."""
        end_time = datetime.now(UTC)
        duration = (end_time - start_time).total_seconds()
        return IndexingStats(
            total_documents=n_submitted + n_errors,
            indexed_documents=n_submitted,
            skipped_documents=0,
            errors=n_errors,
            start_time=start_time,
            end_time=end_time,
            duration_seconds=duration,
        )

    def delete_index_if_exists(self, index_name: str) -> bool:
        """Delete an index named graph if it exists."""
        return self.delete_index(index_name)

    def swap_indexes(self, pairs: list[tuple]) -> dict[str, Any]:
        """Atomically swap pairs of OxiRS named graphs."""
        for a, b in pairs:
            graph_a = self._get_graph_uri(a)
            graph_b = self._get_graph_uri(b)
            temp_graph = (
                "http://westurner.github.io/sustainablefactory/docindex/graph/temp_swap"
            )

            # Execute graph swap via SPARQL UPDATE
            swap_query = f"""
            MOVE <{graph_a}> TO <{temp_graph}> ;
            MOVE <{graph_b}> TO <{graph_a}> ;
            MOVE <{temp_graph}> TO <{graph_b}>
            """
            try:
                if self._local_store is not None:
                    self._local_store.update(swap_query)
                elif self.config.url:
                    self._execute_http_update(swap_query)
            except (httpx.HTTPError, RuntimeError) as e:
                if not self._is_missing_graph_error(e):
                    raise
                fallback_query = f"MOVE <{graph_b}> TO <{graph_a}>"
                try:
                    if self._local_store is not None:
                        self._local_store.update(fallback_query)
                    elif self.config.url:
                        self._execute_http_update(fallback_query)
                except (httpx.HTTPError, RuntimeError) as e2:
                    # If staging (graph_b) also does not exist, it means the staging index was empty.
                    # We clear the live graph (graph_a). We only do this if the error indicates a missing graph.
                    if self._is_missing_graph_error(e2):
                        clear_query = f"DROP SILENT GRAPH <{graph_a}>"
                        try:
                            if self._local_store is not None:
                                self._local_store.update(clear_query)
                            elif self.config.url:
                                self._execute_http_update(clear_query)
                        except (httpx.HTTPError, RuntimeError) as clear_error:
                            raise e from clear_error
                    else:
                        raise
        return {"status": "success"}

    def optimize(self) -> None:
        """Optimize the local pyoxigraph Store for future workload."""
        if self._local_store is not None:
            try:
                logger.info("Optimizing local OxiRS pyoxigraph Store...")
                self._local_store.optimize()
            except Exception:
                logger.exception("OxiRS database optimization failed")

    def delete_documents_by_filter(
        self,
        index_name: str,
        filter_str: str,
    ) -> dict[str, Any]:
        """Delete documents matching a simple type filter expression."""
        graph_uri = self._get_graph_uri(index_name)
        import re

        # Parse build_id != "..." or build_id != '...'
        build_id_match = re.search(
            r'build_id\s*!=\s*["\'](.*?)["\']', filter_str, re.IGNORECASE
        )
        build_id_val = build_id_match.group(1) if build_id_match else None

        # Parse type IN ["..."] or type = "..."
        match = re.search(r"type\s+IN\s+\[(.*?)\]", filter_str, re.IGNORECASE)
        types = []
        if match:
            types = [t.strip().strip('"').strip("'") for t in match.group(1).split(",")]
        else:
            match_eq = re.search(
                r'type\s*=\s*["\'](.*?)["\']', filter_str, re.IGNORECASE
            )
            if match_eq:
                types = [match_eq.group(1)]

        if types:
            filter_exprs = " || ".join([f'?type = "{t}"' for t in types])
            if build_id_val:
                query = f"""
                PREFIX docindex: <{DOCINDEX_NS}>
                DELETE {{
                    GRAPH <{graph_uri}> {{
                        ?s ?p ?o .
                    }}
                }} WHERE {{
                    GRAPH <{graph_uri}> {{
                        ?s docindex:type ?type .
                        ?s ?p ?o .
                        OPTIONAL {{ ?s docindex:buildId ?build_id }}
                        FILTER(({filter_exprs}) && (!bound(?build_id) || ?build_id != "{build_id_val}"))
                    }}
                }}
                """
            else:
                query = f"""
                PREFIX docindex: <{DOCINDEX_NS}>
                DELETE {{
                    GRAPH <{graph_uri}> {{
                        ?s ?p ?o .
                    }}
                }} WHERE {{
                    GRAPH <{graph_uri}> {{
                        ?s docindex:type ?type .
                        ?s ?p ?o .
                        FILTER({filter_exprs})
                    }}
                }}
                """
            if self._local_store is not None:
                self._local_store.update(query)
            elif self.config.url:
                self._execute_http_update(query)

        # Parse id IN ["..."] or id = "..."
        id_match = re.search(r"id\s+IN\s+\[(.*?)\]", filter_str, re.IGNORECASE)
        ids = []
        if id_match:
            ids = [
                t.strip().strip('"').strip("'") for t in id_match.group(1).split(",")
            ]
        else:
            id_eq_match = re.search(
                r'id\s*=\s*["\']?(.*?)["\']?$', filter_str, re.IGNORECASE
            )
            if id_eq_match:
                ids = [id_eq_match.group(1).strip().strip('"').strip("'")]

        if ids:
            filter_exprs = " || ".join([f'?doc_id = "{i}"' for i in ids])
            query = f"""
            PREFIX docindex: <{DOCINDEX_NS}>
            DELETE {{
                GRAPH <{graph_uri}> {{
                    ?s ?p ?o .
                }}
            }} WHERE {{
                GRAPH <{graph_uri}> {{
                    ?s docindex:id ?doc_id .
                    ?s ?p ?o .
                    FILTER({filter_exprs})
                }}
            }}
            """
            if self._local_store is not None:
                self._local_store.update(query)
            elif self.config.url:
                self._execute_http_update(query)
        return {"status": "success"}

    def wait_for_task(
        self,
        task_uid: int,
        timeout_ms: int = 30_000,
        interval_ms: int = 250,
    ) -> dict[str, Any]:
        """Compatibility task wait (always immediately succeeds)."""
        return {"status": "succeeded"}

    def list_indices(self) -> list[dict[str, Any]]:
        """list active named graph indices."""
        query = "SELECT DISTINCT ?g WHERE { GRAPH ?g { ?s ?p ?o } }"
        graphs = []
        if self._local_store is not None:
            solutions = self._local_store.query(query)
            for sol in solutions:
                g_val = str(sol["g"].value)
                if "docindex/graph/" in g_val:
                    name = g_val.split("docindex/graph/")[-1]
                    graphs.append({"uid": name, "name": name, "primary_key": "id"})
        elif self.config.url:
            query_url = self.config.url
            if not query_url.endswith("/query") and not query_url.endswith("/"):
                query_url = f"{query_url.rstrip('/')}/query"
            try:
                response = self._execute_http_post(
                    query_url,
                    data={"query": query},
                    headers={"Accept": "application/sparql-results+json"},
                    timeout=10.0,
                )
                response.raise_for_status()
                json_data = response.json()
                for binding in json_data.get("results", {}).get("bindings", []):
                    g_val = binding["g"]["value"]
                    if "docindex/graph/" in g_val:
                        name = g_val.split("docindex/graph/")[-1]
                        graphs.append({"uid": name, "name": name, "primary_key": "id"})
            except Exception:
                logger.exception("Failed to list OxiRS indices")
        return graphs
