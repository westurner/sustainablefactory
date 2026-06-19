"""docindex-core package."""

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
]
