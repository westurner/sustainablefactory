import logging
from typing import List, Dict, Any, Optional
from datetime import datetime

from docindex_core.backends.base import BaseSearchBackend
from docindex_core.config import Document, SearchResult, IndexingStats

logger = logging.getLogger(__name__)


class MultiBackend(BaseSearchBackend):
    """Search backend that wraps and delegates to multiple underlying backends."""

    def __init__(self, backends: List[BaseSearchBackend]):
        """Initialize MultiBackend with a list of search backends."""
        if not backends:
            raise ValueError("MultiBackend requires at least one active backend.")
        self.backends = backends

    @property
    def primary_backend(self) -> BaseSearchBackend:
        """The primary backend used for query operations."""
        return self.backends[0]

    def verify_connection(self) -> bool:
        """Verify connection to all backends. Return True only if all connect successfully."""
        results = []
        for b in self.backends:
            try:
                results.append(b.verify_connection())
            except Exception as e:
                logger.warning(f"Backend connection check failed for {b.__class__.__name__}: {e}")
                results.append(False)
        return all(results)

    def optimize(self) -> None:
        """Forward optimize request to all child backends."""
        for b in self.backends:
            try:
                b.optimize()
            except Exception as e:
                logger.warning(f"Backend optimization failed for {b.__class__.__name__}: {e}")

    def create_or_update_index(
        self,
        index_name: str,
        settings: Optional[Any] = None,
        primary_key: str = "id"
    ) -> Dict[str, Any]:
        """Create or update index on all backends."""
        results = {}
        for b in self.backends:
            res = b.create_or_update_index(index_name, settings, primary_key)
            if res:
                results.update(res)
        return results

    def clear_index(self, index_name: str) -> Dict[str, Any]:
        """Clear index on all backends."""
        results = {}
        for b in self.backends:
            res = b.clear_index(index_name)
            if res:
                results.update(res)
        return results

    def delete_index(self, index_name: str) -> bool:
        """Delete index on all backends."""
        results = []
        for b in self.backends:
            results.append(b.delete_index(index_name))
        return all(results)

    def add_documents(
        self,
        index_name: str,
        documents: List[Document],
        batch_size: Optional[int] = None,
        progress: bool = False,
        total_estimate: Optional[int] = None
    ) -> IndexingStats:
        """Add documents to all backends. Returns stats from primary backend."""
        stats_list = []
        for b in self.backends:
            stats = b.add_documents(
                index_name=index_name,
                documents=documents,
                batch_size=batch_size,
                progress=progress,
                total_estimate=total_estimate
            )
            stats_list.append(stats)
        return stats_list[0]

    def search(
        self,
        index_name: str,
        query: str,
        limit: int = 20,
        offset: int = 0,
        filters: Optional[str] = None,
        sort: Optional[List[str]] = None,
    ) -> List[SearchResult]:
        """Search documents. Routed only to the primary backend."""
        return self.primary_backend.search(
            index_name=index_name,
            query=query,
            limit=limit,
            offset=offset,
            filters=filters,
            sort=sort
        )

    def get_index_stats(self, index_name: str) -> Dict[str, Any]:
        """Get index stats from the primary backend."""
        return self.primary_backend.get_index_stats(index_name)

    def get_synonyms(self, index_name: str) -> Dict[str, List[str]]:
        """Get synonyms from the primary backend."""
        return self.primary_backend.get_synonyms(index_name)

    def update_synonyms(self, index_name: str, synonyms: Dict[str, List[str]]) -> Dict[str, Any]:
        """Update synonyms on all backends."""
        results = {}
        for b in self.backends:
            res = b.update_synonyms(index_name, synonyms)
            if res:
                results.update(res)
        return results

    def clear_synonyms(self, index_name: str) -> Dict[str, Any]:
        """Clear synonyms on all backends."""
        results = {}
        for b in self.backends:
            res = b.clear_synonyms(index_name)
            if res:
                results.update(res)
        return results

    def delete_documents_by_filter(self, index_name: str, filters: str) -> Dict[str, Any]:
        """Delete documents by filter on all backends."""
        results = {}
        for b in self.backends:
            res = b.delete_documents_by_filter(index_name, filters)
            if res:
                results.update(res)
        return results

    def swap_indexes(self, index_a: str, index_b: str) -> Dict[str, Any]:
        """Swap indexes on all backends."""
        results = {}
        for b in self.backends:
            res = b.swap_indexes(index_a, index_b)
            if res:
                results.update(res)
        return results
