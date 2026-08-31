"""Backward compatibility wrapper for Meilisearch API classes."""

try:
    from tqdm.auto import tqdm as _tqdm

    _HAS_TQDM = True
except ImportError:  # pragma: no cover
    _HAS_TQDM = False
    _tqdm = None
