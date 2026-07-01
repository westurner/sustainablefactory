"""Base search backend interfaces for docindex."""

from __future__ import annotations

from abc import ABC, abstractmethod
from typing import List, Optional, Dict, Any

from ..config import Document, SearchResult, IndexingStats


class BaseSearchBackend(ABC):
    """Abstract base class for docindex search and indexing backends."""

    @abstractmethod
    def create_or_update_index(
        self,
        index_name: str,
        settings: Optional[Any] = None,
        primary_key: str = "id",
    ) -> Dict[str, Any]:
        """Create or update index configuration."""
        raise NotImplementedError

    @abstractmethod
    def add_documents(
        self,
        index_name: str,
        documents: List[Document],
        batch_size: Optional[int] = None,
        progress: bool = False,
        total_estimate: Optional[int] = None,
    ) -> IndexingStats:
        """Add documents to index."""
        raise NotImplementedError

    @abstractmethod
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
        raise NotImplementedError

    @abstractmethod
    def delete_index(self, index_name: str) -> bool:
        """Delete an index."""
        raise NotImplementedError

    @abstractmethod
    def clear_index(self, index_name: str) -> Dict[str, Any]:
        """Clear all documents from an index."""
        raise NotImplementedError


    @abstractmethod
    def get_index_stats(self, index_name: str) -> Dict[str, Any]:
        """Get statistics for an index."""
        raise NotImplementedError

    @abstractmethod
    def get_synonyms(self, index_name: str) -> Dict[str, List[str]]:
        """Get current synonym mapping."""
        raise NotImplementedError

    @abstractmethod
    def update_synonyms(self, index_name: str, synonyms: Dict[str, List[str]]) -> Any:
        """Update synonym mapping."""
        raise NotImplementedError

    @abstractmethod
    def clear_synonyms(self, index_name: str) -> Any:
        """Clear synonyms."""
        raise NotImplementedError

    @abstractmethod
    def verify_connection(self) -> bool:
        """Verify connection to the backend."""
        raise NotImplementedError

    def optimize(self) -> None:
        """Optimize the backend database (no-op by default)."""
        pass

