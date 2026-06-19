"""
Main indexer module for coordinating document indexing.
"""

from __future__ import annotations

import logging
import time
from pathlib import Path
from typing import Optional, List
from datetime import datetime, timezone

from meilisearch.errors import MeilisearchError, MeilisearchCommunicationError

from .api import MeilisearchClient
from .config import MeilisearchConfig, DocumentType, IndexingStats, DEFAULT_INDEX_SETTINGS
from .chat_parser import BatchChatIndexer
from .html_parser import BatchHTMLIndexer

logger = logging.getLogger(__name__)


class DocumentIndexer:
    """Main indexer coordinating all indexing operations."""
    
    def __init__(self, config: Optional[MeilisearchConfig] = None):
        """Initialize indexer.
        
        Args:
            config: MeilisearchConfig. If None, loads from environment.
        """
        self.config = config or MeilisearchConfig.from_env()
        self.client = MeilisearchClient(self.config)
        
        # Ensure default indices exist
        self._init_indices()
    
    def _init_indices(self):
        """Initialize Meilisearch indices.
        
        Indices group documents by source system:
        - 'all': all documents across all sources
        - 'chats': chat export documents
        - 'sphinx': all sphinx-based documents (html, rst, md, notebooks)
        - 'myst': MyST/Markdown-specific documents
        """
        index_names = ['all', 'chats', 'sphinx', 'myst']
        for index_name in index_names:
            try:
                self.client.create_or_update_index(
                    index_name,
                    settings=DEFAULT_INDEX_SETTINGS
                )
            except Exception as e:
                logger.error(f"Failed to initialize index {index_name}: {e}")
    
    def _send_batch_with_retry(
        self,
        index_name: str,
        batch: List,
        max_retries: int,
        retry_delay: float,
    ) -> IndexingStats:
        """Send a document batch to one Meilisearch index with exponential-backoff retry.

        Retries on communication errors and when the returned IndexingStats
        reports errors > 0 (partial batch failure).
        """
        last_exc: Optional[Exception] = None
        last_stats: Optional[IndexingStats] = None

        for attempt in range(max_retries):
            try:
                stats = self.client.add_documents(index_name, batch)
                last_stats = stats
                if stats.errors == 0:
                    return stats
                logger.warning(
                    f"Batch to '{index_name}' had {stats.errors} error(s) "
                    f"(attempt {attempt + 1}/{max_retries})."
                )
            except (MeilisearchCommunicationError, MeilisearchError) as exc:
                last_exc = exc
                logger.warning(
                    f"Batch send to '{index_name}' failed "
                    f"(attempt {attempt + 1}/{max_retries}): {exc}"
                )

            if attempt < max_retries - 1:
                wait = retry_delay * (2 ** attempt)
                logger.info(f"Retrying in {wait:.1f}s...")
                time.sleep(wait)

        if last_exc is not None:
            raise last_exc
        return last_stats  # Exhausted retries; stats may still report errors

    def _get_index_names_for_document(self, doc) -> List[str]:
        """Get indices where this document should be indexed.
        
        Args:
            doc: Document to route (or SimpleNamespace for testing)
            
        Returns:
            List of index names to send document to
        """
        indices = ['all']  # All documents go to 'all' index
        
        # Handle both Document objects and test mocks (SimpleNamespace)
        if not hasattr(doc, 'type'):
            return indices  # Default: only 'all' index
        
        if doc.type == DocumentType.CHAT:
            indices.append('chats')
        elif hasattr(doc.type, 'value') and doc.type.value.startswith('sphinx'):
            indices.append('sphinx')
            # Route SPHINX_MD documents to 'myst' index for MyST-specific queries
            if doc.type == DocumentType.SPHINX_MD:
                indices.append('myst')
        
        return indices
    
    def index_chat_directory(
        self,
        chat_dir: Path,
        skip_unchanged: bool = False
    ) -> IndexingStats:
        """Index all chat files in a directory with memory-efficient batching.
        
        Args:
            chat_dir: Path to directory containing chat files
            skip_unchanged: Skip files that haven't changed (requires cache)
            
        Returns:
            IndexingStats with results
        """
        chat_dir = Path(chat_dir)
        logger.info(f"Indexing chat directory: {chat_dir}")
        
        try:
            indexer = BatchChatIndexer(chat_dir)
        except ValueError as e:
            logger.error(f"Failed to initialize chat indexer: {e}")
            raise
        
        start_time = datetime.now(timezone.utc)
        batch = []
        total_docs_sent = 0
        file_count = 0
        batch_size = self.config.batch_size
        last_stats = None
        
        for filepath, documents in indexer.parse_all():
            file_count += 1
            
            for doc in documents:
                batch.append(doc)
                
                if len(batch) >= batch_size:
                    # Route documents to appropriate indices
                    for index_name in self._get_index_names_for_document(batch[0]):
                        if index_name == 'all':
                            last_stats = self.client.add_documents('all', batch)
                        else:
                            self.client.add_documents(index_name, batch)
                    total_docs_sent += len(batch)
                    logger.info(
                        f"Indexed batch of {len(batch)} documents "
                        f"({total_docs_sent} total from {file_count} files)"
                    )
                    batch = []
        
        if batch:
            # Route final batch to appropriate indices
            for index_name in self._get_index_names_for_document(batch[0]):
                if index_name == 'all':
                    last_stats = self.client.add_documents('all', batch)
                else:
                    self.client.add_documents(index_name, batch)
            total_docs_sent += len(batch)
            logger.info(f"Indexed final batch of {len(batch)} documents")
        
        end_time = datetime.now(timezone.utc)
        duration = (end_time - start_time).total_seconds()
        
        if last_stats:
            logger.info(
                f"Chat indexing complete: {total_docs_sent} documents "
                f"from {file_count} files in {duration:.2f}s"
            )
            return last_stats
        else:
            logger.warning("No documents collected for indexing")
            return IndexingStats(
                total_documents=0,
                indexed_documents=0,
                skipped_documents=0,
                errors=0,
                start_time=start_time,
                end_time=end_time,
                duration_seconds=duration
            )
    
    def index_sphinx_html(
        self,
        html_dir: Path,
        max_heading_level: int = 3,
        exclude_patterns: Optional[List[str]] = None,
        max_retries: int = 3,
        retry_delay: float = 1.0,
    ) -> IndexingStats:
        """Index Sphinx HTML documentation with memory-efficient batching.
        
        Args:
            html_dir: Path to _build/html directory
            max_heading_level: Maximum heading level to extract
            exclude_patterns: File patterns to exclude
            
        Returns:
            IndexingStats with results
        """
        html_dir = Path(html_dir)
        logger.info(f"Indexing Sphinx HTML: {html_dir}")
        
        try:
            indexer = BatchHTMLIndexer(html_dir)
        except ValueError as e:
            logger.error(f"Failed to initialize HTML indexer: {e}")
            raise
        
        start_time = datetime.now(timezone.utc)
        batch = []
        total_docs_sent = 0
        file_count = 0
        batch_size = self.config.batch_size
        last_stats = None
        cancelled = False

        def _flush_batch(b: List) -> None:
            nonlocal last_stats, total_docs_sent
            for index_name in self._get_index_names_for_document(b[0]):
                stats = self._send_batch_with_retry(
                    index_name, b, max_retries, retry_delay
                )
                if index_name == 'all':
                    last_stats = stats
            total_docs_sent += len(b)

        try:
            for filepath, documents in indexer.parse_all(
                exclude_patterns=exclude_patterns,
                max_heading_level=max_heading_level
            ):
                file_count += 1

                for doc in documents:
                    batch.append(doc)

                    if len(batch) >= batch_size:
                        _flush_batch(batch)
                        logger.info(
                            f"Indexed batch of {len(batch)} documents "
                            f"({total_docs_sent} total from {file_count} files)"
                        )
                        batch = []

        except KeyboardInterrupt:
            cancelled = True
            logger.warning(
                f"HTML indexing cancelled after {total_docs_sent} documents "
                f"from {file_count} files. "
                "The index may contain partial data — re-run to complete, "
                "or use Meilisearch swap_indexes for atomic updates."
            )

        if batch and not cancelled:
            _flush_batch(batch)
            logger.info(f"Indexed final batch of {len(batch)} documents")
        elif batch and cancelled:
            logger.warning(
                f"Discarding unsent in-memory batch of {len(batch)} documents "
                "due to cancellation."
            )

        end_time = datetime.now(timezone.utc)
        duration = (end_time - start_time).total_seconds()

        if last_stats:
            if cancelled:
                logger.warning(
                    f"HTML indexing incomplete: {total_docs_sent} documents "
                    f"from {file_count} files in {duration:.2f}s (cancelled)"
                )
            else:
                logger.info(
                    f"HTML indexing complete: {total_docs_sent} documents "
                    f"from {file_count} files in {duration:.2f}s"
                )
            return last_stats
        else:
            logger.warning("No documents collected for HTML indexing")
            return IndexingStats(
                total_documents=0,
                indexed_documents=0,
                skipped_documents=0,
                errors=0,
                start_time=start_time,
                end_time=end_time,
                duration_seconds=duration
            )
    
    def get_index_status(self) -> dict:
        """Get status of all indices.
        
        Returns:
            Dictionary with index information
        """
        try:
            indices = self.client.list_indices()
            status = {
                'connected': True,
                'indices': {}
            }
            
            for idx in indices:
                stats = self.client.get_index_stats(idx['name'])
                status['indices'][idx['name']] = {
                    'documents': stats.get('numberOfDocuments', 0),
                    'updates': stats.get('isIndexing', False)
                }
            
            return status
        except Exception as e:
            logger.error(f"Failed to get index status: {e}")
            return {'connected': False, 'error': str(e)}
