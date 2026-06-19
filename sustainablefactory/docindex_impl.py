"""Sustainablefactory implementation layer for docindex components.

This module intentionally represents one concrete implementation in this
repository while generic components live in separate, reusable packages.
"""

from docindex_integration import (
    MeilisearchClient,
    Document,
    DocumentType,
    MeilisearchConfig,
    IndexSettings,
    SearchResult,
    IndexingStats,
    DocumentMetadata,
    DocumentIndexer,
    ChatParser,
    BatchChatIndexer,
    SphinxHTMLParser,
    BatchHTMLIndexer,
)

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
