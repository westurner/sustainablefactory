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
    s2 = indexer.index_sphinx_html(tmp_path / "ok")
    assert s1.indexed_documents == 2
    assert s2.indexed_documents == 2

    with pytest.raises(ValueError):
        indexer.index_chat_directory(tmp_path / "missing")
    with pytest.raises(ValueError):
        indexer.index_sphinx_html(tmp_path / "missing")

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
    s2 = indexer.index_sphinx_html(tmp_path)
    assert s1.total_documents == 0
    assert s2.total_documents == 0