"""Sustainablefactory implementation layer for docindex components."""

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
