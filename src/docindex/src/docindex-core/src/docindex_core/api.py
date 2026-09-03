"""Backward compatibility wrapper for Meilisearch API classes."""

import meilisearch

try:
    from tqdm.auto import tqdm as _tqdm

    _HAS_TQDM = True
except ImportError:  # pragma: no cover
    _HAS_TQDM = False
    _tqdm = None

from .backends.milli import (
    MilliBackend as MeilisearchClient,
    MilliConfig as MeilisearchConfig,
    IndexSettings,
    DEFAULT_INDEX_SETTINGS,
)
from .config import (
    Document,
    DocumentType,
    SearchResult,
    IndexingStats,
    DocumentMetadata,
)
