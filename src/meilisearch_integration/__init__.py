"""
Meilisearch Integration for Sphinx Documentation

This module provides:
- Chat export indexing (JSON and Markdown)
- Sphinx HTML documentation indexing
- Full-text search API
- CLI tools for index management
"""

from .api import MeilisearchClient
from .config import (
    Document,
    DocumentType,
    MeilisearchConfig,
    IndexSettings,
    SearchResult,
    IndexingStats,
    DocumentMetadata,
)
from .indexer import DocumentIndexer
from .chat_parser import ChatParser, BatchChatIndexer
from .html_parser import SphinxHTMLParser, BatchHTMLIndexer
from .cli import cli

__version__ = "0.1.0"
__all__ = [
    "MeilisearchClient",
    "Document",
    "DocumentType",
    "MeilisearchConfig",
    "IndexSettings",
    "SearchResult",
    "IndexingStats",
    "DocumentMetadata",
    "DocumentIndexer",
    "ChatParser",
    "BatchChatIndexer",
    "SphinxHTMLParser",
    "BatchHTMLIndexer",
    "cli",
]
