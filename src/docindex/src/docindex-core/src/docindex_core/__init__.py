"""docindex-core package."""

from .backends.base import BaseSearchBackend
from .backends.milli import (
    MilliBackend,
    MilliConfig,
    IndexSettings,
    DEFAULT_INDEX_SETTINGS,
)
from .backends.oxirs import OxiRSBackend, OxiRSConfig
from .backends.multi import MultiBackend
from .api import MeilisearchClient, MeilisearchConfig
from .config import (
    Document,
    DocumentType,
    DocIndexConfig,
    SearchResult,
    IndexingStats,
    DocumentMetadata,
)
from .indexer import DocumentIndexer
from .synonyms_manager import SynonymsManager
from .glossary_manager import GlossaryManager
from .chat_parser import ChatParser, BatchChatIndexer
from .html_parser import SphinxHTMLParser, BatchHTMLIndexer

__version__ = "0.1.0"

__all__ = [
    "BaseSearchBackend",
    "MilliBackend",
    "MilliConfig",
    "OxiRSBackend",
    "OxiRSConfig",
    "MultiBackend",
    "MeilisearchClient",
    "MeilisearchConfig",
    "IndexSettings",
    "DEFAULT_INDEX_SETTINGS",
    "Document",
    "DocumentType",
    "DocIndexConfig",
    "SearchResult",
    "IndexingStats",
    "DocumentMetadata",
    "DocumentIndexer",
    "ChatParser",
    "BatchChatIndexer",
    "SphinxHTMLParser",
    "BatchHTMLIndexer",
    "SynonymsManager",
    "GlossaryManager",
]
