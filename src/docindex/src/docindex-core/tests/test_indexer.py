from pathlib import Path
from types import SimpleNamespace

import pytest

from docindex_core.config import IndexingStats


@pytest.fixture(autouse=True)
def force_milli_backend(monkeypatch):
    monkeypatch.setenv("DOCINDEX_BACKEND", "milli")


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

        def _submit_batches(self, name, docs, batch_size, pbar=None):
            stats = self.add_documents(name, docs)
            self._cached = getattr(self, "_cached", {})
            self._cached[name] = stats
            return [(1, len(docs))], len(docs), 0

        def _finalize_tasks(self, name, tasks, n_ok, n_err, start_time, progress=False):
            return getattr(self, "_cached", {}).get(name)

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

        def _submit_batches(self, name, docs, batch_size, pbar=None):
            # Pipelined path: for empty collections, this should never be called.
            raise AssertionError("should not be called (empty collections)")

        def _finalize_tasks(self, name, tasks, n_ok, n_err, start_time, progress=False):
            return None  # empty — indexer returns fallback empty IndexingStats

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
    s2 = indexer.index_sphinx_html(tmp_path)  # atomic primary
    s3 = indexer.index_sphinx_html_legacy(tmp_path)  # non-atomic legacy
    assert s1.total_documents == 0
    assert s2.total_documents == 0
    assert s3.total_documents == 0


def test_index_sphinx_html_atomic_success(monkeypatch, tmp_path, stats_obj, caplog):
    """index_sphinx_html() processes documents in batches and returns stats."""
    import docindex_core.indexer as idx_mod

    caplog.set_level("INFO", logger="docindex_core.indexer")
    swapped = []

    class FakeClient:
        def __init__(self, cfg):
            pass

        def create_or_update_index(self, name, settings=None):
            pass

        def add_documents(self, name, docs):
            return stats_obj

        def wait_for_task(self, task_uid, **kwargs):
            return {"status": "SUCCEEDED"}

        def _submit_batches(self, name, docs, batch_size, pbar=None):
            stats = self.add_documents(name, docs)
            self._cached = getattr(self, "_cached", {})
            self._cached[name] = stats
            return [(1, len(docs))], len(docs), 0

        def swap_indexes(self, pairs):
            swapped.extend(pairs)

        def delete_index_if_exists(self, name):
            return True

        def delete_documents_by_filter(self, index_name, filter_str):
            return {"taskUid": 1}

        def _finalize_tasks(self, name, tasks, n_ok, n_err, start_time, progress=False):
            return getattr(self, "_cached", {}).get(name)

    class FakeBatchHtml:
        def __init__(self, path):
            pass

        def parse_all(self, exclude_patterns=None, max_heading_level=3):
            html_file = tmp_path / "index.html"
            html_file.write_bytes(b"x" * 1024)
            return iter([(html_file, [SimpleNamespace(type="sphinx_html")])])

    monkeypatch.setattr(idx_mod, "MeilisearchClient", FakeClient)
    monkeypatch.setattr(idx_mod, "BatchHTMLIndexer", FakeBatchHtml)

    indexer = idx_mod.DocumentIndexer()
    stats = indexer.index_sphinx_html(tmp_path)

    assert stats.indexed_documents == 2
    assert swapped == [("sphinx_staging", "sphinx")]
    completion_logs = [
        record.getMessage()
        for record in caplog.records
        if "Atomic HTML indexing complete" in record.getMessage()
    ]
    assert completion_logs
    assert "documents/s" in completion_logs[-1]
    assert "kilobytes/s" in completion_logs[-1]


def test_index_sphinx_html_atomic_cancelled(monkeypatch, tmp_path):
    """KeyboardInterrupt during HTML indexing returns partial stats without raising."""
    import docindex_core.indexer as idx_mod

    class FakeClient:
        def __init__(self, cfg):
            pass

        def create_or_update_index(self, name, settings=None):
            pass

        def add_documents(self, name, docs):  # should not be reached
            return None

        def wait_for_task(self, *a, **kw):
            pass

        def _submit_batches(self, name, docs, batch_size, pbar=None):
            # KeyboardInterrupt fires before any doc reaches _submit_batches
            raise AssertionError("should not be reached on cancellation")

        def delete_index_if_exists(self, name):
            return True

        def _finalize_tasks(self, name, tasks, n_ok, n_err, start_time, progress=False):
            return None

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
    assert stats.total_documents == 0  # no docs were sent before cancellation


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

        def _submit_batches(self, name, docs, batch_size, pbar=None):
            stats = self.add_documents(name, docs)
            self._cached = getattr(self, "_cached", {})
            self._cached[name] = stats
            return [(1, len(docs))], len(docs), 0

        def _finalize_tasks(self, name, tasks, n_ok, n_err, start_time, progress=False):
            return getattr(self, "_cached", {}).get(name)

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


def test_document_indexer_backend_arg():
    from unittest.mock import MagicMock
    from docindex_core.indexer import DocumentIndexer

    mock_backend = MagicMock()
    mock_backend.config = "fake_config"
    indexer = DocumentIndexer(backend=mock_backend)
    assert indexer.client == mock_backend
    assert indexer.config == "fake_config"


def test_document_indexer_keyboard_interrupt(monkeypatch, tmp_path):
    from unittest.mock import MagicMock
    import docindex_core.indexer as idx_mod

    class CancelledIndexer:
        def __init__(self, path):
            pass

        def parse_all(self, *args, **kwargs):
            yield (Path("index.html"), [SimpleNamespace(type="sphinx_html")])
            raise KeyboardInterrupt()

    monkeypatch.setattr(idx_mod, "BatchHTMLIndexer", CancelledIndexer)
    mock_client = MagicMock()
    mock_client.config = idx_mod.DocIndexConfig(batch_size=10)
    mock_client._finalize_tasks.return_value = None
    indexer = idx_mod.DocumentIndexer(backend=mock_client)

    stats = indexer.index_sphinx_html_legacy(tmp_path)
    assert stats.total_documents == 0

    stats_atomic = indexer.index_sphinx_html(tmp_path)
    assert stats_atomic.total_documents == 0


def test_indexer_additional_branches(monkeypatch, tmp_path, stats_obj):
    import time
    from unittest.mock import MagicMock
    import docindex_core.indexer as idx_mod

    # 1. Document routing branches
    indexer = idx_mod.DocumentIndexer(backend=MagicMock())
    doc_chat = SimpleNamespace(type="chat")
    doc_myst = SimpleNamespace(type="sphinx_md")
    doc_plain = SimpleNamespace()
    assert indexer._get_index_names_for_document(doc_chat) == ["all", "chats"]
    assert indexer._get_index_names_for_document(doc_myst) == ["all", "sphinx", "myst"]
    assert indexer._get_index_names_for_document(doc_plain) == ["all"]

    # 2. _send_batch_with_retry exception retry path
    mock_client = MagicMock()
    mock_client._submit_batches.side_effect = Exception("failed")
    indexer.client = mock_client

    monkeypatch.setattr(time, "sleep", lambda x: None)
    with pytest.raises(Exception, match="failed"):
        indexer._send_batch_with_retry(
            "all",
            [doc_plain],
            max_retries=2,
            retry_delay=0.1,
            pending_tasks={},
            submit_counts={},
        )

    # 3. index_chat_directory batching (batch_size=1)
    class FakeChatIndexer:
        def __init__(self, path):
            pass

        def get_chat_files(self):
            return [Path("chat.json")]

        def parse_all(self):
            return [("chat.json", [doc_chat, doc_chat])]

    monkeypatch.setattr(idx_mod, "BatchChatIndexer", FakeChatIndexer)
    mock_client2 = MagicMock()
    mock_client2._submit_batches.return_value = ([], 2, 0)
    mock_client2._finalize_tasks.return_value = stats_obj
    indexer.client = mock_client2
    indexer.config.batch_size = 1

    indexer.index_chat_directory(tmp_path)
    assert mock_client2._submit_batches.call_count >= 2

    # 4. index_sphinx_html swap_indexes / GC failure
    class FakeHTMLIndexer:
        def __init__(self, path):
            pass

        def get_html_files(self, pat=None):
            return [Path("index.html")]

        def parse_all(self, **kwargs):
            return [("index.html", [doc_myst, doc_myst])]

    monkeypatch.setattr(idx_mod, "BatchHTMLIndexer", FakeHTMLIndexer)
    mock_client3 = MagicMock()
    mock_client3._submit_batches.return_value = ([], 2, 0)
    mock_client3.swap_indexes.side_effect = Exception("swap failed")
    mock_client3.delete_documents_by_filter.side_effect = Exception("gc failed")
    indexer.client = mock_client3
    indexer.config.batch_size = 1

    with pytest.raises(Exception, match="swap failed"):
        indexer.index_sphinx_html(tmp_path)

    # Swap succeeds, GC fails
    mock_client4 = MagicMock()
    mock_client4._submit_batches.return_value = ([], 2, 0)
    mock_client4.delete_documents_by_filter.side_effect = Exception("gc failed")
    indexer.client = mock_client4

    # GC failure is logged as warning but does not raise
    stats = indexer.index_sphinx_html(tmp_path)
    assert stats is not None

    # 5. index_sphinx_html_legacy total_estimate calculation + batch_size=1
    stats = indexer.index_sphinx_html_legacy(tmp_path)
    assert stats is not None


def test_document_indexer_multi_backends_init():
    from docindex_core.config import DocIndexConfig
    from docindex_core.indexer import DocumentIndexer
    from docindex_core.backends.multi import MultiBackend

    cfg = DocIndexConfig(backend="oxirs,milli", storage_path="/tmp/fake_oxirs_path")
    indexer = DocumentIndexer(config=cfg)
    assert isinstance(indexer.client, MultiBackend)
    assert len(indexer.client.backends) == 2
