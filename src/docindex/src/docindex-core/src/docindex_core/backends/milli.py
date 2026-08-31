"""Meilisearch (milli) backend implementation for docindex."""

from __future__ import annotations

import os
import logging
from typing import List, Optional, Dict, Any
from datetime import datetime, timezone

import meilisearch
from meilisearch.errors import MeilisearchError, MeilisearchCommunicationError
from pydantic import BaseModel, Field

from .base import BaseSearchBackend
from ..config import Document, SearchResult, IndexingStats, DocumentType
from ..synonyms_manager import SynonymsManager

logger = logging.getLogger(__name__)


def _get_tqdm():
    import sys

    if "docindex_core.api" in sys.modules:
        api = sys.modules["docindex_core.api"]
        if hasattr(api, "_tqdm") and api._tqdm is not None:
            return api._tqdm, getattr(api, "_HAS_TQDM", True)
    try:  # pragma: no cover
        from tqdm.auto import tqdm as local_tqdm

        return local_tqdm, True
    except ImportError:  # pragma: no cover
        return None, False


class MilliConfig(BaseModel):
    """Configuration for Meilisearch connection."""

    host: str = Field(default="localhost", description="Meilisearch host")
    port: int = Field(default=7700, description="Meilisearch port")
    api_key: Optional[str] = Field(default=None, description="Meilisearch API key")
    batch_size: int = Field(default=1000, description="Batch size for indexing")
    index_name: str = Field(default="all", description="Default index name")
    enabled: bool = Field(default=True, description="Enable Meilisearch indexing")

    @property
    def url(self) -> str:
        """Get Meilisearch URL."""
        return f"http://{self.host}:{self.port}"

    @classmethod
    def from_env(cls) -> MilliConfig:
        """Load configuration from environment variables."""
        return cls(
            host=os.getenv("MEILISEARCH_HOST", "localhost"),
            port=int(os.getenv("MEILISEARCH_PORT", "7700")),
            api_key=os.getenv("MEILISEARCH_API_KEY"),
            batch_size=int(os.getenv("MEILISEARCH_BATCH_SIZE", "1000")),
            enabled=os.getenv("MEILISEARCH_ENABLED", "true").lower() == "true",
        )


class IndexSettings(BaseModel):
    """Meilisearch index settings."""

    searchable_attributes: List[str] = ["title", "content", "summary", "concepts"]
    filterable_attributes: List[str] = ["type", "date_indexed", "filename", "chat_type"]
    sortable_attributes: List[str] = ["date_indexed"]
    synonyms: Dict[str, List[str]] = Field(default_factory=SynonymsManager.load)


DEFAULT_INDEX_SETTINGS = IndexSettings()


class MilliBackend(BaseSearchBackend):
    """Wrapper around Meilisearch client for document indexing and search."""

    def __init__(self, config: Optional[MilliConfig] = None):
        """Initialize Meilisearch client.

        Args:
            config: MilliConfig instance. If None, loads from environment.
        """
        self.config = config or MilliConfig.from_env()
        self._client: Optional[meilisearch.Client] = None
        self._verify_connection()

    @property
    def client(self) -> meilisearch.Client:
        """Lazy-load and return Meilisearch client."""
        if self._client is None:
            try:
                self._client = meilisearch.Client(
                    url=self.config.url, api_key=self.config.api_key
                )
                logger.info(f"Connected to Meilisearch at {self.config.url}")
            except MeilisearchCommunicationError as e:
                logger.error(f"Failed to connect to Meilisearch: {e}")
                raise
        return self._client

    def _verify_connection(self) -> bool:
        """Verify connection to Meilisearch server."""
        try:
            _ = self.client.health()
            return True
        except MeilisearchCommunicationError as e:
            logger.warning(f"Meilisearch unreachable: {e}")
            return False

    def verify_connection(self) -> bool:
        """Verify connection to the backend."""
        return self._verify_connection()

    def create_or_update_index(
        self, index_name: str, settings: Optional[Any] = None, primary_key: str = "id"
    ) -> Dict[str, Any]:
        """Create or update a Meilisearch index.

        Args:
            index_name: Name of the index
            settings: IndexSettings to apply
            primary_key: Primary key field for documents

        Returns:
            Index creation/update response
        """
        if settings is None:
            settings = DEFAULT_INDEX_SETTINGS

        try:
            # Create index if it doesn't exist
            try:
                self.client.create_index(index_name, {"primaryKey": primary_key})
                logger.info(f"Created new index: {index_name}")
            except MeilisearchError as e:
                if "already exists" not in str(e):  # pragma: no branch
                    raise
                logger.debug(f"Index {index_name} already exists")

            # create_index returns a TaskInfo, not an Index; always get the
            # Index object via client.index() for subsequent operations.
            index = self.client.index(index_name)

            # Update settings
            index.update_settings(
                {
                    "searchableAttributes": settings.searchable_attributes,
                    "filterableAttributes": settings.filterable_attributes,
                    "sortableAttributes": settings.sortable_attributes,
                    "synonyms": settings.synonyms,
                }
            )
            logger.info(f"Updated settings for index: {index_name}")
            return {"index": index_name, "status": "ready"}

        except MeilisearchError as e:
            logger.error(f"Failed to create/update index {index_name}: {e}")
            raise

    def _submit_batches(
        self,
        index_name: str,
        documents: List[Document],
        batch_size: int,
        pbar=None,
    ) -> tuple:
        """Submit documents in batches **without** waiting for tasks to finish.

        Returns ``(submitted_tasks, n_submitted, n_submit_errors)`` where
        *submitted_tasks* is a ``List[(task_uid, batch_len)]``.
        """
        index = self.client.index(index_name)
        total = len(documents)
        submitted_tasks: List[tuple] = []
        n_submitted = 0
        n_errors = 0
        total_batches = (total + batch_size - 1) // batch_size

        for i in range(0, total, batch_size):
            batch = documents[i : i + batch_size]
            batch_data = [
                doc.model_dump(mode="json")
                if hasattr(doc, "model_dump")
                else getattr(doc, "__dict__", doc)
                for doc in batch
            ]
            try:
                task = index.add_documents(batch_data)
                submitted_tasks.append((task.task_uid, len(batch)))
                n_submitted += len(batch)
                batch_num = (i // batch_size) + 1
                logger.info(
                    f"Submitted batch {batch_num}/{total_batches} "
                    f"({len(batch)} docs → {index_name}, task_uid={task.task_uid})"
                )
                if pbar is not None:
                    pbar.update(len(batch))
            except MeilisearchError as e:
                logger.error(f"Failed to submit batch at position {i}: {e}")
                n_errors += len(batch)
                if pbar is not None:
                    pbar.update(len(batch))

        return submitted_tasks, n_submitted, n_errors

    def _finalize_tasks(
        self,
        index_name: str,
        submitted_tasks: List[tuple],
        n_submitted: int,
        n_errors: int,
        start_time: datetime,
        progress: bool = False,
    ) -> IndexingStats:
        """Wait for the last submitted task, verify all tasks, return :class:`IndexingStats`."""
        indexed = n_submitted
        errors = n_errors
        total = n_submitted + n_errors

        if submitted_tasks:
            last_uid = submitted_tasks[-1][0]
            logger.info(
                f"Waiting for last task {last_uid} "
                f"({len(submitted_tasks)} batch(es) queued for '{index_name}') …"
            )
            index = self.client.index(index_name)
            finished = index.wait_for_task(last_uid, timeout_in_ms=120_000)
            last_status = getattr(finished, "status", "unknown")
            logger.info(f"Last task {last_uid}: {last_status}")

            task_errors = 0
            tqdm_cls, has_tqdm = _get_tqdm()
            verify_pbar = (
                tqdm_cls(
                    total=len(submitted_tasks),
                    desc=f"Verifying  → {index_name}",
                    unit="task",
                    leave=False,
                )
                if (progress and has_tqdm and tqdm_cls is not None)
                else None
            )
            try:
                for task_uid, batch_len in submitted_tasks:
                    result = index.get_task(task_uid)
                    status = getattr(result, "status", "unknown")
                    details = getattr(result, "details", {})
                    committed = (
                        details.get("indexedDocuments", batch_len)
                        if isinstance(details, dict)
                        else getattr(details, "indexed_documents", batch_len)
                    )
                    if status == "failed":
                        err_info = getattr(result, "error", {})
                        logger.error(
                            f"Task {task_uid} FAILED "
                            f"({batch_len} docs submitted): {err_info}"
                        )
                        task_errors += batch_len
                    else:
                        logger.info(
                            f"Task {task_uid}: {status} "
                            f"({committed}/{batch_len} docs committed)"
                        )
                    if verify_pbar is not None:
                        verify_pbar.update(1)
            finally:
                if verify_pbar is not None:
                    verify_pbar.close()

            if task_errors:
                indexed -= task_errors
                errors += task_errors

        end_time = datetime.now(timezone.utc)
        duration = (end_time - start_time).total_seconds()
        stats = IndexingStats(
            total_documents=total,
            indexed_documents=indexed,
            skipped_documents=0,
            errors=errors,
            start_time=start_time,
            end_time=end_time,
            duration_seconds=duration,
        )
        logger.info(
            f"Indexing complete: {indexed}/{total} documents "
            f"({stats.success_rate:.1f}% success rate) in {duration:.1f}s"
        )
        return stats

    def add_documents(
        self,
        index_name: str,
        documents: List[Document],
        batch_size: Optional[int] = None,
        progress: bool = False,
        total_estimate: Optional[int] = None,
    ) -> IndexingStats:
        """Submit documents and wait for all tasks to complete."""
        if batch_size is None:
            batch_size = self.config.batch_size

        if not documents:
            now = datetime.now(timezone.utc)
            return IndexingStats(
                total_documents=0,
                indexed_documents=0,
                skipped_documents=0,
                errors=0,
                start_time=now,
                end_time=now,
                duration_seconds=0.0,
            )

        start_time = datetime.now(timezone.utc)

        tqdm_cls, has_tqdm = _get_tqdm()
        pbar = (
            tqdm_cls(
                total=total_estimate if total_estimate is not None else len(documents),
                desc=f"Submitting → {index_name}",
                unit="doc",
                leave=False,
            )
            if (progress and has_tqdm and tqdm_cls is not None)
            else None
        )
        try:
            submitted_tasks, n_submitted, n_errors = self._submit_batches(
                index_name, documents, batch_size, pbar=pbar
            )
        except Exception as e:
            logger.error(f"Unexpected error during indexing: {e}")
            raise
        finally:
            if pbar is not None:
                pbar.close()

        return self._finalize_tasks(
            index_name, submitted_tasks, n_submitted, n_errors, start_time, progress
        )

    def search(
        self,
        index_name: str,
        query: str,
        limit: int = 20,
        offset: int = 0,
        filters: Optional[str] = None,
        sort: Optional[List[str]] = None,
    ) -> List[SearchResult]:
        """Search documents in index."""
        try:
            index = self.client.index(index_name)
            response = index.search(
                query,
                {
                    "limit": limit,
                    "offset": offset,
                    "filter": filters,
                    "sort": sort,
                    "showRankingScore": True,
                },
            )

            results = []
            for hit in response.get("hits", []):
                results.append(
                    SearchResult(
                        id=hit.get("id", ""),
                        type=hit.get("type", DocumentType.SPHINX_HTML),
                        title=hit.get("title", ""),
                        url=hit.get("url"),
                        content_snippet=hit.get("content", "")[:200],
                        relevance_score=hit.get("_rankingScore", 0.0),
                        matched_fields=hit.get("_matchedFields", []),
                    )
                )

            logger.debug(f"Search '{query}' returned {len(results)} results")
            return results

        except MeilisearchError as e:
            logger.error(f"Search failed for query '{query}': {e}")
            raise

    def delete_index(self, index_name: str) -> bool:
        """Delete an index."""
        try:
            self.client.delete_index(index_name)
            logger.info(f"Deleted index: {index_name}")
            return True
        except MeilisearchError as e:
            logger.error(f"Failed to delete index {index_name}: {e}")
            raise

    def get_index_stats(self, index_name: str) -> Dict[str, Any]:
        """Get statistics for an index."""
        try:
            index = self.client.index(index_name)
            stats = index.get_stats()
            if isinstance(stats, dict):
                return stats
            return {
                "numberOfDocuments": getattr(stats, "number_of_documents", 0),
                "isIndexing": getattr(stats, "is_indexing", False),
            }
        except MeilisearchError as e:
            logger.error(f"Failed to get stats for index {index_name}: {e}")
            raise

    def list_indices(self) -> List[Dict[str, Any]]:
        """List all indices."""
        try:
            indices = self.client.get_indexes()
            result_list = (
                indices.get("results", [])
                if isinstance(indices, dict)
                else list(indices)
            )
            return [
                {
                    "uid": idx.uid,
                    "name": idx.uid,
                    "primary_key": getattr(idx, "primary_key", None),
                }
                for idx in result_list
            ]
        except MeilisearchError as e:
            logger.error(f"Failed to list indices: {e}")
            raise

    def clear_index(self, index_name: str) -> bool:
        """Clear all documents from an index."""
        try:
            index = self.client.index(index_name)
            index.delete_all_documents()
            logger.info(f"Cleared index: {index_name}")
            return True
        except MeilisearchError as e:
            logger.error(f"Failed to clear index {index_name}: {e}")
            raise

    def get_synonyms(self, index_name: str) -> Dict[str, List[str]]:
        """Fetch the current synonym map from a Meilisearch index."""
        try:
            index = self.client.index(index_name)
            result = index.get_synonyms()
            logger.debug(f"Fetched {len(result)} synonym entries from '{index_name}'")
            return result
        except MeilisearchError as e:
            logger.error(f"Failed to get synonyms for index '{index_name}': {e}")
            raise

    def update_synonyms(
        self,
        index_name: str,
        synonyms: Dict[str, List[str]],
    ) -> Dict[str, Any]:
        """Replace the synonym map on a Meilisearch index."""
        try:
            index = self.client.index(index_name)
            task = index.update_synonyms(synonyms)
            logger.info(
                f"Updated {len(synonyms)} synonym entries on index '{index_name}' "
                f"(task uid: {getattr(task, 'task_uid', task)})"
            )
            return task if isinstance(task, dict) else vars(task)
        except MeilisearchError as e:
            logger.error(f"Failed to update synonyms for index '{index_name}': {e}")
            raise

    def reset_synonyms(self, index_name: str) -> Dict[str, Any]:
        """Remove all synonyms from a Meilisearch index."""
        try:
            index = self.client.index(index_name)
            task = index.reset_synonyms()
            logger.info(f"Reset synonyms on index '{index_name}'")
            return task if isinstance(task, dict) else vars(task)
        except MeilisearchError as e:
            logger.error(f"Failed to reset synonyms for index '{index_name}': {e}")
            raise

    def clear_synonyms(self, index_name: str) -> Any:
        """Clear synonyms."""
        return self.reset_synonyms(index_name)

    def wait_for_task(
        self,
        task_uid: int,
        timeout_ms: int = 30_000,
        interval_ms: int = 250,
    ) -> Dict[str, Any]:
        """Block until a Meilisearch task reaches a terminal state."""
        try:
            result = self.client.wait_for_task(
                task_uid,
                timeout_in_ms=timeout_ms,
                interval_in_ms=interval_ms,
            )
            status = getattr(result, "status", None) or result.get("status")
            if status == "failed":
                error = getattr(result, "error", None) or result.get("error", {})
                raise MeilisearchError(f"Task {task_uid} failed: {error}")
            logger.debug(f"Task {task_uid} completed with status '{status}'")
            return result if isinstance(result, dict) else vars(result)
        except MeilisearchError:
            raise
        except Exception as e:
            logger.error(f"wait_for_task({task_uid}) raised unexpected error: {e}")
            raise

    def swap_indexes(self, pairs: List[tuple]) -> Dict[str, Any]:
        """Atomically swap pairs of Meilisearch indices."""
        swap_payload = [{"indexes": [a, b]} for a, b in pairs]
        try:
            task = self.client.swap_indexes(swap_payload)
            logger.info(
                f"Swapped index pairs: {pairs} "
                f"(task uid: {getattr(task, 'task_uid', task)})"
            )
            return task if isinstance(task, dict) else vars(task)
        except MeilisearchError as e:
            logger.error(f"Failed to swap indexes {pairs}: {e}")
            raise

    def delete_documents_by_filter(
        self,
        index_name: str,
        filter_str: str,
    ) -> Dict[str, Any]:
        """Delete documents matching a filter expression from an index."""
        try:
            index = self.client.index(index_name)
            task = index.delete_documents_by_filter(filter_str)
            logger.info(
                f"Deleting docs from '{index_name}' where {filter_str!r} "
                f"(task uid: {getattr(task, 'task_uid', task)})"
            )
            return task if isinstance(task, dict) else vars(task)
        except MeilisearchError as e:
            logger.error(
                f"Failed to delete documents by filter from '{index_name}': {e}"
            )
            raise

    def delete_index_if_exists(self, index_name: str) -> bool:
        """Delete an index, silently succeeding if it does not exist."""
        try:
            self.client.delete_index(index_name)
            logger.info(f"Deleted staging index: {index_name}")
            return True
        except MeilisearchError as e:
            if "not found" in str(e).lower() or "index_not_found" in str(e).lower():
                logger.debug(f"Index '{index_name}' did not exist — nothing to delete")
                return False
            logger.error(f"Failed to delete index '{index_name}': {e}")
            raise


# Legacy compatibility exports
MeilisearchConfig = MilliConfig
MeilisearchClient = MilliBackend
