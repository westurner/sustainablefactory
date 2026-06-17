"""
Main indexer module for coordinating document indexing.
"""

from __future__ import annotations

import logging
from pathlib import Path
from typing import Optional, List

from .api import MeilisearchClient
from .config import MeilisearchConfig, Document, IndexingStats, DEFAULT_INDEX_SETTINGS
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
        """Initialize Meilisearch indices."""
        index_names = ['all', 'chats', 'sphinx', 'myst']
        for index_name in index_names:
            try:
                self.client.create_or_update_index(
                    index_name,
                    settings=DEFAULT_INDEX_SETTINGS
                )
            except Exception as e:
                logger.error(f"Failed to initialize index {index_name}: {e}")
    
    def index_chat_directory(
        self,
        chat_dir: Path,
        skip_unchanged: bool = False
    ) -> IndexingStats:
        """Index all chat files in a directory.
        
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
        
        all_documents = []
        file_count = 0
        
        for filepath, documents in indexer.parse_all():
            all_documents.extend(documents)
            file_count += 1
            logger.debug(f"Collected {len(documents)} documents from {filepath.name}")
        
        logger.info(
            f"Collected {len(all_documents)} documents from {file_count} chat files"
        )
        
        if all_documents:
            stats = self.client.add_documents('all', all_documents)
            stats_chats = self.client.add_documents('chats', all_documents)
            
            logger.info(f"Chat indexing complete: {stats}")
            return stats
        else:
            logger.warning("No documents collected for indexing")
            return IndexingStats(
                total_documents=0,
                indexed_documents=0,
                skipped_documents=0,
                errors=0,
                start_time=None,
                end_time=None,
                duration_seconds=0.0
            )
    
    def index_sphinx_html(
        self,
        html_dir: Path,
        max_heading_level: int = 3,
        exclude_patterns: Optional[List[str]] = None
    ) -> IndexingStats:
        """Index Sphinx HTML documentation.
        
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
        
        all_documents = []
        file_count = 0
        
        for filepath, documents in indexer.parse_all(
            exclude_patterns=exclude_patterns,
            max_heading_level=max_heading_level
        ):
            all_documents.extend(documents)
            file_count += 1
            logger.debug(f"Collected {len(documents)} documents from {filepath.name}")
        
        logger.info(
            f"Collected {len(all_documents)} documents from {file_count} HTML files"
        )
        
        if all_documents:
            stats = self.client.add_documents('all', all_documents)
            stats_sphinx = self.client.add_documents('sphinx', all_documents)
            
            logger.info(f"HTML indexing complete: {stats}")
            return stats
        else:
            logger.warning("No documents collected for HTML indexing")
            return IndexingStats(
                total_documents=0,
                indexed_documents=0,
                skipped_documents=0,
                errors=0,
                start_time=None,
                end_time=None,
                duration_seconds=0.0
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
