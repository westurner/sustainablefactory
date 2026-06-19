"""
Meilisearch API wrapper and client management.
"""

from __future__ import annotations

import logging
from typing import List, Optional, Dict, Any
from datetime import datetime, timezone

import meilisearch
from meilisearch.errors import MeilisearchError, MeilisearchCommunicationError

from .config import (
    Document, MeilisearchConfig, IndexSettings, DEFAULT_INDEX_SETTINGS,
    SearchResult, DocumentType, IndexingStats
)

logger = logging.getLogger(__name__)


class MeilisearchClient:
    """Wrapper around Meilisearch client for document indexing and search."""
    
    def __init__(self, config: Optional[MeilisearchConfig] = None):
        """Initialize Meilisearch client.
        
        Args:
            config: MeilisearchConfig instance. If None, loads from environment.
        """
        self.config = config or MeilisearchConfig.from_env()
        self._client: Optional[meilisearch.Client] = None
        self._verify_connection()
    
    @property
    def client(self) -> meilisearch.Client:
        """Lazy-load and return Meilisearch client."""
        if self._client is None:
            try:
                self._client = meilisearch.Client(
                    url=self.config.url,
                    api_key=self.config.api_key
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
    
    def create_or_update_index(
        self,
        index_name: str,
        settings: Optional[IndexSettings] = None,
        primary_key: str = "id"
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
                index = self.client.create_index(index_name, {"primaryKey": primary_key})
                logger.info(f"Created new index: {index_name}")
            except MeilisearchError as e:
                if "already exists" not in str(e):  # pragma: no branch
                    raise
                logger.debug(f"Index {index_name} already exists")
                index = self.client.index(index_name)
            
            # Update settings
            index.update_settings({
                "searchableAttributes": settings.searchable_attributes,
                "filterableAttributes": settings.filterable_attributes,
                "sortableAttributes": settings.sortable_attributes,
                "synonyms": settings.synonyms,
            })
            logger.info(f"Updated settings for index: {index_name}")
            return {"index": index_name, "status": "ready"}
        
        except MeilisearchError as e:
            logger.error(f"Failed to create/update index {index_name}: {e}")
            raise
    
    def add_documents(
        self,
        index_name: str,
        documents: List[Document],
        batch_size: Optional[int] = None
    ) -> IndexingStats:
        """Add or update documents in index.
        
        Args:
            index_name: Name of the index
            documents: List of Document objects to index
            batch_size: Batch size for indexing (uses config default if None)
            
        Returns:
            IndexingStats with indexing results
        """
        if batch_size is None:
            batch_size = self.config.batch_size
        
        if not documents:
            return IndexingStats(
                total_documents=0,
                indexed_documents=0,
                skipped_documents=0,
                errors=0,
                start_time=datetime.now(timezone.utc),
                end_time=datetime.now(timezone.utc),
                duration_seconds=0.0
            )
        
        start_time = datetime.now(timezone.utc)
        index = self.client.index(index_name)
        
        total = len(documents)
        indexed = 0
        errors = 0
        
        try:
            # Process documents in batches
            for i in range(0, total, batch_size):
                batch = documents[i:i+batch_size]
                batch_data = [doc.model_dump() for doc in batch]
                
                try:
                    task = index.add_documents(batch_data)
                    indexed += len(batch)
                    batch_num = (i // batch_size) + 1
                    total_batches = (total + batch_size - 1) // batch_size
                    logger.info(
                        f"Indexed batch {batch_num}/{total_batches} "
                        f"({len(batch)} documents)"
                    )
                except MeilisearchError as e:
                    logger.error(f"Failed to index batch at position {i}: {e}")
                    errors += len(batch)
        
        except Exception as e:
            logger.error(f"Unexpected error during indexing: {e}")
            raise
        
        end_time = datetime.now(timezone.utc)
        duration = (end_time - start_time).total_seconds()
        
        stats = IndexingStats(
            total_documents=total,
            indexed_documents=indexed,
            skipped_documents=0,
            errors=errors,
            start_time=start_time,
            end_time=end_time,
            duration_seconds=duration
        )
        
        logger.info(
            f"Indexing complete: {indexed}/{total} documents "
            f"({stats.success_rate:.1f}% success rate) "
            f"in {duration:.1f}s"
        )
        
        return stats
    
    def search(
        self,
        index_name: str,
        query: str,
        limit: int = 20,
        offset: int = 0,
        filters: Optional[str] = None,
        sort: Optional[List[str]] = None
    ) -> List[SearchResult]:
        """Search documents in index.
        
        Args:
            index_name: Name of the index
            query: Search query string
            limit: Maximum number of results
            offset: Results offset for pagination
            filters: Meilisearch filter string
            sort: Fields to sort by
            
        Returns:
            List of SearchResult objects
        """
        try:
            index = self.client.index(index_name)
            response = index.search(
                query,
                {
                    "limit": limit,
                    "offset": offset,
                    "filter": filters,
                    "sort": sort,
                }
            )
            
            results = []
            for hit in response.get("hits", []):
                results.append(SearchResult(
                    id=hit.get("id", ""),
                    type=hit.get("type", DocumentType.SPHINX_HTML),
                    title=hit.get("title", ""),
                    url=hit.get("url"),
                    content_snippet=hit.get("content", "")[:200],
                    relevance_score=hit.get("_rankingScore", 0.0),
                    matched_fields=hit.get("_matchedFields", [])
                ))
            
            logger.debug(f"Search '{query}' returned {len(results)} results")
            return results
        
        except MeilisearchError as e:
            logger.error(f"Search failed for query '{query}': {e}")
            raise
    
    def delete_index(self, index_name: str) -> bool:
        """Delete an index.
        
        Args:
            index_name: Name of the index to delete
            
        Returns:
            True if successful
        """
        try:
            self.client.delete_index(index_name)
            logger.info(f"Deleted index: {index_name}")
            return True
        except MeilisearchError as e:
            logger.error(f"Failed to delete index {index_name}: {e}")
            raise
    
    def get_index_stats(self, index_name: str) -> Dict[str, Any]:
        """Get statistics for an index.
        
        Args:
            index_name: Name of the index
            
        Returns:
            Index statistics
        """
        try:
            index = self.client.index(index_name)
            stats = index.get_stats()
            return stats
        except MeilisearchError as e:
            logger.error(f"Failed to get stats for index {index_name}: {e}")
            raise
    
    def list_indices(self) -> List[Dict[str, Any]]:
        """List all indices.
        
        Returns:
            List of index information dictionaries
        """
        try:
            indices = self.client.get_indexes()
            return [idx.get_dict() for idx in indices]
        except MeilisearchError as e:
            logger.error(f"Failed to list indices: {e}")
            raise
    
    def clear_index(self, index_name: str) -> bool:
        """Clear all documents from an index.
        
        Args:
            index_name: Name of the index
            
        Returns:
            True if successful
        """
        try:
            index = self.client.index(index_name)
            index.delete_all_documents()
            logger.info(f"Cleared index: {index_name}")
            return True
        except MeilisearchError as e:
            logger.error(f"Failed to clear index {index_name}: {e}")
            raise

    def get_synonyms(self, index_name: str) -> Dict[str, List[str]]:
        """Fetch the current synonym map from a Meilisearch index.

        Args:
            index_name: Name of the index.

        Returns:
            Dict mapping canonical terms to synonym lists.
        """
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
        """Replace the synonym map on a Meilisearch index.

        This is a full replacement: existing synonyms not present in *synonyms*
        will be removed.  Use :meth:`merge_synonyms` to add without removing.

        Args:
            index_name: Name of the index.
            synonyms: New synonym map to apply.

        Returns:
            Meilisearch task response dict.
        """
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
        """Remove all synonyms from a Meilisearch index.

        Args:
            index_name: Name of the index.

        Returns:
            Meilisearch task response dict.
        """
        try:
            index = self.client.index(index_name)
            task = index.reset_synonyms()
            logger.info(f"Reset synonyms on index '{index_name}'")
            return task if isinstance(task, dict) else vars(task)
        except MeilisearchError as e:
            logger.error(f"Failed to reset synonyms for index '{index_name}': {e}")
            raise
