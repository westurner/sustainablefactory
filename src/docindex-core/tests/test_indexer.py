from pathlib import Path
from types import SimpleNamespace

import pytest

from docindex_core.config import IndexingStats


@pytest.fixture
def stats_obj():
    return IndexingStats(
        total_documents=2,
        indexed_documents=2,
        skipped_documents=0,
        errors=0,
        start_time="2026-01-01T00:00:00",
        end_time="2026-01-01T00:00:01",
        duration_seconds=1.0,
    )


def test_document_indexer_paths(monkeypatch, tmp_path, stats_obj):
    import docindex_core.indexer as idx_mod

    class FakeClient:
        def __init__(self, cfg):
            self.created = []
            self.added = []
            self.swapped = []

        def create_or_update_index(self, name, settings=None):
            if name == "myst":
                raise RuntimeError("ignore")
            self.created.append(name)

        def add_documents(self, name, docs):
            self.added.append((name, len(docs)))
            return stats_obj

        def list_indices(self):
            return [{"name": "all"}]

        def get_index_stats(self, name):
            return {"numberOfDocuments": 3, "isIndexing": False}

        def swap_indexes(self, pairs):
            self.swapped.extend(pairs)

        def delete_index_if_exists(self, name):
            return True

        def delete_documents_by_filter(self, index_name, filter_str):
            return {"taskUid": 1}

        def wait_for_task(self, task_uid, **kwargs):
            return {"status": "SUCCEEDED"}

    class FakeBatchChat:
        def __init__(self, path):
            if "missing" in str(path):
                raise ValueError("missing")

        def parse_all(self):
            return iter([(Path("a.md"), [SimpleNamespace()])])

    class FakeBatchHtml:
        def __init__(self, path):
            if "missing" in str(path):
                raise ValueError("missing")

        def parse_all(self, exclude_patterns=None, max_heading_level=3):
            return iter([(Path("a.html"), [SimpleNamespace()])])

    monkeypatch.setattr(idx_mod, "MeilisearchClient", FakeClient)
    monkeypatch.setattr(idx_mod, "BatchChatIndexer", FakeBatchChat)
    monkeypatch.setattr(idx_mod, "BatchHTMLIndexer", FakeBatchHtml)

    indexer = idx_mod.DocumentIndexer()
    s1 = indexer.index_chat_directory(tmp_path / "ok")
    # index_sphinx_html is now the atomic primary method
    s2 = indexer.index_sphinx_html(tmp_path / "ok")
    # index_sphinx_html_legacy is the non-atomic deprecated method
    s3 = indexer.index_sphinx_html_legacy(tmp_path / "ok")
    assert s1.indexed_documents == 2
    assert s2.indexed_documents == 2
    assert s3.indexed_documents == 2

    with pytest.raises(ValueError):
        indexer.index_chat_directory(tmp_path / "missing")
    with pytest.raises(ValueError):
        indexer.index_sphinx_html(tmp_path / "missing")
    with pytest.raises(ValueError):
        indexer.index_sphinx_html_legacy(tmp_path / "missing")

    status = indexer.get_index_status()
    assert status["connected"] is True

    class BadClient(FakeClient):
        def list_indices(self):
            raise RuntimeError("down")

    monkeypatch.setattr(idx_mod, "MeilisearchClient", BadClient)
    bad = idx_mod.DocumentIndexer()
    s = bad.get_index_status()
    assert s["connected"] is False


def test_document_indexer_empty_collections(monkeypatch, tmp_path):
    import docindex_core.indexer as idx_mod

    class FakeClient:
        def __init__(self, cfg):
            pass

        def create_or_update_index(self, name, settings=None):
            return None

        def add_documents(self, name, docs):
            raise AssertionError("should not be called")

        # Atomic method still calls these even when parse yields nothing
        def swap_indexes(self, pairs):
            pass

        def delete_index_if_exists(self, name):
            return True

        def delete_documents_by_filter(self, index_name, filter_str):
            return {"taskUid": 1}

        def wait_for_task(self, task_uid, **kwargs):
            return {"status": "SUCCEEDED"}

    class EmptyBatch:
        def __init__(self, path):
            pass

        def parse_all(self, *args, **kwargs):
            return iter([])

    monkeypatch.setattr(idx_mod, "MeilisearchClient", FakeClient)
    monkeypatch.setattr(idx_mod, "BatchChatIndexer", EmptyBatch)
    monkeypatch.setattr(idx_mod, "BatchHTMLIndexer", EmptyBatch)

    indexer = idx_mod.DocumentIndexer()
    s1 = indexer.index_chat_directory(tmp_path)
    s2 = indexer.index_sphinx_html(tmp_path)      # atomic primary
    s3 = indexer.index_sphinx_html_legacy(tmp_path)  # non-atomic legacy
    assert s1.total_documents == 0
    assert s2.total_documents == 0
    assert s3.total_documents == 0


def test_index_sphinx_html_atomic_success(monkeypatch, tmp_path, stats_obj):
    """Primary index_sphinx_html() goes through staging, swap, and GC phases."""
    import docindex_core.indexer as idx_mod

    calls = {"swap": [], "filter_delete": [], "wait": [], "drop": []}

    class FakeClient:
        def __init__(self, cfg):
            pass

        def create_or_update_index(self, name, settings=None):
            pass

        def add_documents(self, name, docs):
            return stats_obj

        def swap_indexes(self, pairs):
            calls["swap"].extend(pairs)

        def delete_index_if_exists(self, name):
            calls["drop"].append(name)
            return True

        def delete_documents_by_filter(self, index_name, filter_str):
            calls["filter_delete"].append((index_name, filter_str))
            return {"taskUid": 42}

        def wait_for_task(self, task_uid, **kwargs):
            calls["wait"].append(task_uid)
            return {"status": "SUCCEEDED"}

    class FakeBatchHtml:
        def __init__(self, path):
            pass

        def parse_all(self, exclude_patterns=None, max_heading_level=3):
            return iter([(Path("index.html"), [SimpleNamespace(type="sphinx_html")])])

    monkeypatch.setattr(idx_mod, "MeilisearchClient", FakeClient)
    monkeypatch.setattr(idx_mod, "BatchHTMLIndexer", FakeBatchHtml)

    indexer = idx_mod.DocumentIndexer()
    stats = indexer.index_sphinx_html(tmp_path, staging_suffix="_stg")

    # swap_indexes was called with staging index pairs
    assert any("sphinx_stg" in str(p) for p in calls["swap"])
    assert any("myst_stg" in str(p) for p in calls["swap"])
    # stale sphinx docs were deleted from 'all' by build_id filter
    assert calls["filter_delete"] and calls["filter_delete"][0][0] == "all"
    assert "build_id" in calls["filter_delete"][0][1]
    # wait_for_task was called after delete
    assert 42 in calls["wait"]
    # staging indices were dropped after successful swap
    assert "sphinx_stg" in calls["drop"]
    assert "myst_stg" in calls["drop"]
    assert stats.indexed_documents == 2


def test_index_sphinx_html_atomic_cancelled(monkeypatch, tmp_path):
    """Cancellation drops staging indices; swap and GC must not run."""
    import docindex_core.indexer as idx_mod

    dropped = []

    class FakeClient:
        def __init__(self, cfg):
            pass

        def create_or_update_index(self, name, settings=None):
            pass

        def add_documents(self, name, docs):  # should not be reached
            return None

        def swap_indexes(self, pairs):
            raise AssertionError("swap must not be called on cancellation")

        def delete_index_if_exists(self, name):
            dropped.append(name)
            return True

        def delete_documents_by_filter(self, *a, **kw):
            raise AssertionError("GC must not run on cancellation")

        def wait_for_task(self, *a, **kw):
            pass

    class FakeBatchHtml:
        def __init__(self, path):
            pass

        def parse_all(self, exclude_patterns=None, max_heading_level=3):
            # Raise KeyboardInterrupt during iteration (before any docs sent)
            raise KeyboardInterrupt()
            yield  # noqa: unreachable — makes this a generator function

    monkeypatch.setattr(idx_mod, "MeilisearchClient", FakeClient)
    monkeypatch.setattr(idx_mod, "BatchHTMLIndexer", FakeBatchHtml)

    indexer = idx_mod.DocumentIndexer()
    stats = indexer.index_sphinx_html(tmp_path)  # must not raise

    # Returns partial stats object without raising
    assert stats is not None
    # Staging indices were cleaned up
    assert "sphinx_staging" in dropped
    assert "myst_staging" in dropped


def test_index_sphinx_html_legacy_no_swap(monkeypatch, tmp_path, stats_obj):
    """Legacy index_sphinx_html_legacy() flushes batches without any index swap."""
    import docindex_core.indexer as idx_mod

    swapped = []

    class FakeClient:
        def __init__(self, cfg):
            pass

        def create_or_update_index(self, name, settings=None):
            pass

        def add_documents(self, name, docs):
            return stats_obj

        def swap_indexes(self, pairs):  # must NOT be called by legacy path
            swapped.extend(pairs)

    class FakeBatchHtml:
        def __init__(self, path):
            pass

        def parse_all(self, exclude_patterns=None, max_heading_level=3):
            return iter([(Path("index.html"), [SimpleNamespace(type="sphinx_html")])])

    monkeypatch.setattr(idx_mod, "MeilisearchClient", FakeClient)
    monkeypatch.setattr(idx_mod, "BatchHTMLIndexer", FakeBatchHtml)

    indexer = idx_mod.DocumentIndexer()
    stats = indexer.index_sphinx_html_legacy(tmp_path)

    assert swapped == [], "legacy path must not call swap_indexes"
    assert stats.indexed_documents == 2