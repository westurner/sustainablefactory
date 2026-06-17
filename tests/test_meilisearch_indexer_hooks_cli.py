from pathlib import Path
from types import SimpleNamespace

import pytest
from click.testing import CliRunner

from meilisearch_integration.config import IndexingStats


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
    import meilisearch_integration.indexer as idx_mod

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
    import meilisearch_integration.indexer as idx_mod

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


def test_hooks_setup_and_build_finished(monkeypatch, tmp_path, stats_obj):
    import meilisearch_integration.hooks as hooks

    calls = []

    class FakeIndexer:
        def __init__(self, cfg):
            calls.append(("init", cfg.host))

        def index_sphinx_html(self, outdir):
            calls.append(("index", str(outdir)))
            return stats_obj

    monkeypatch.setattr(hooks, "DocumentIndexer", FakeIndexer)

    class App:
        def __init__(self):
            self.config = SimpleNamespace()
            self.builder = SimpleNamespace(name="html")
            self.outdir = str(tmp_path)
            self._events = []

        def connect(self, event, func):
            self._events.append((event, func.__name__))

    app = App()
    hooks.setup_meilisearch_hooks(app)
    assert any(ev[0] == "build-finished" for ev in app._events)

    # config-inited branches
    cfg_disabled = SimpleNamespace(meilisearch_enabled=False)
    hooks.on_config_inited(app, cfg_disabled)
    cfg_enabled = SimpleNamespace(meilisearch_enabled=True, meilisearch_host="localhost", meilisearch_port=7700)
    hooks.on_config_inited(app, cfg_enabled)

    # Disabled branch
    app.config.meilisearch_enabled = False
    hooks.on_build_finished(app, None)

    # Exception branch
    app.config.meilisearch_enabled = True
    hooks.on_build_finished(app, RuntimeError("build failed"))

    # Non-html branch
    app.builder.name = "dirhtml"
    hooks.on_build_finished(app, None)

    # Missing dir branch
    app.builder.name = "html"
    app.outdir = str(tmp_path / "missing")
    hooks.on_build_finished(app, None)

    # Happy path
    app.outdir = str(tmp_path)
    hooks.on_build_finished(app, None)
    assert any(c[0] == "index" for c in calls)

    class RaisingIndexer:
        def __init__(self, cfg):
            raise RuntimeError("init failed")

    monkeypatch.setattr(hooks, "DocumentIndexer", RaisingIndexer)
    hooks.on_build_finished(app, None)

    meta = hooks.setup(app)
    assert meta["parallel_read_safe"] is True


def test_hooks_importerror_fallback_module():
    import importlib

    m = importlib.import_module("meilisearch_integration.hooks")
    assert hasattr(m, "setup")


def test_cli_commands(monkeypatch, tmp_path, stats_obj):
    import importlib

    cli_mod = importlib.import_module("meilisearch_integration.cli")

    class FakeIndexer:
        def __init__(self, cfg):
            self.cfg = cfg

        def index_chat_directory(self, source, skip_unchanged=False):
            return stats_obj

        def index_sphinx_html(self, source, max_heading_level=3, exclude_patterns=None):
            return stats_obj

        def get_index_status(self):
            return {"connected": True, "indices": {"all": {"documents": 2}}}

    class FakeClient:
        def __init__(self, cfg):
            self.cfg = cfg

        def search(self, index, query, limit=10):
            return [SimpleNamespace(title="T", type="chat", relevance_score=0.5, content_snippet="x")]

        def list_indices(self):
            return [{"name": "all"}]

        def clear_index(self, index):
            return True

        def delete_index(self, index):
            return True

    monkeypatch.setattr(cli_mod, "DocumentIndexer", FakeIndexer)
    monkeypatch.setattr(cli_mod, "MeilisearchClient", FakeClient)

    src_dir = tmp_path / "src"
    src_dir.mkdir()

    runner = CliRunner()

    result = runner.invoke(cli_mod.cli, ["index-chats", "--source", str(src_dir), "--batch-size", "5"])
    assert result.exit_code == 0

    result = runner.invoke(cli_mod.cli, ["index-html", "--source", str(src_dir), "--headings", "bad"])
    assert result.exit_code == 0

    result = runner.invoke(cli_mod.cli, ["status"])
    assert result.exit_code == 0

    result = runner.invoke(cli_mod.cli, ["search", "--index", "all", "--query", "abc"])
    assert result.exit_code == 0

    result = runner.invoke(cli_mod.cli, ["list-indices"])
    assert result.exit_code == 0

    result = runner.invoke(cli_mod.cli, ["clear-index", "--index", "all", "--confirm"])
    assert result.exit_code == 0

    result = runner.invoke(cli_mod.cli, ["delete-index", "--index", "all", "--confirm"])
    assert result.exit_code == 0


def test_cli_empty_and_cancel_branches(monkeypatch):
    import importlib

    cli_mod = importlib.import_module("meilisearch_integration.cli")

    class FakeIndexer:
        def __init__(self, cfg):
            pass

        def get_index_status(self):
            return {"connected": True, "indices": {}}

    class EmptyClient:
        def __init__(self, cfg):
            pass

        def search(self, index, query, limit=10):
            return []

        def list_indices(self):
            return []

        def clear_index(self, index):
            return True

        def delete_index(self, index):
            return True

    monkeypatch.setattr(cli_mod, "DocumentIndexer", FakeIndexer)
    monkeypatch.setattr(cli_mod, "MeilisearchClient", EmptyClient)

    runner = CliRunner()

    result = runner.invoke(cli_mod.cli, ["search", "--query", "abc"])
    assert result.exit_code == 0
    assert "No results found" in result.output

    result = runner.invoke(cli_mod.cli, ["list-indices"])
    assert result.exit_code == 0
    assert "No indices found" in result.output

    result = runner.invoke(cli_mod.cli, ["clear-index"], input="n\n")
    assert result.exit_code == 0
    assert "Cancelled" in result.output

    result = runner.invoke(cli_mod.cli, ["delete-index"], input="n\n")
    assert result.exit_code == 0
    assert "Cancelled" in result.output


def test_cli_status_disconnected_and_confirm_yes(monkeypatch):
    import importlib

    cli_mod = importlib.import_module("meilisearch_integration.cli")

    class DownIndexer:
        def __init__(self, cfg):
            pass

        def get_index_status(self):
            return {"connected": False, "error": "down"}

    class OkClient:
        def __init__(self, cfg):
            pass

        def clear_index(self, index):
            return True

        def delete_index(self, index):
            return True

    monkeypatch.setattr(cli_mod, "DocumentIndexer", DownIndexer)
    monkeypatch.setattr(cli_mod, "MeilisearchClient", OkClient)

    runner = CliRunner()
    status_result = runner.invoke(cli_mod.cli, ["status"])
    assert status_result.exit_code == 1
    assert "Connection failed" in status_result.output

    # Cover positive confirmation path when --confirm is not provided.
    clear_result = runner.invoke(cli_mod.cli, ["clear-index", "--index", "all"], input="y\n")
    assert clear_result.exit_code == 0
    delete_result = runner.invoke(cli_mod.cli, ["delete-index", "--index", "all"], input="y\n")
    assert delete_result.exit_code == 0


def test_cli_status_exception_branch(monkeypatch):
    import importlib

    cli_mod = importlib.import_module("meilisearch_integration.cli")

    class ExplodingIndexer:
        def __init__(self, cfg):
            pass

        def get_index_status(self):
            raise RuntimeError("oops")

    monkeypatch.setattr(cli_mod, "DocumentIndexer", ExplodingIndexer)

    runner = CliRunner()
    result = runner.invoke(cli_mod.cli, ["status"])
    assert result.exit_code == 1
    assert "Error:" in result.output


def test_cli_error_branches(monkeypatch, tmp_path):
    import importlib

    cli_mod = importlib.import_module("meilisearch_integration.cli")

    class BrokenIndexer:
        def __init__(self, cfg):
            pass

        def index_chat_directory(self, source, skip_unchanged=False):
            raise RuntimeError("boom")

        def index_sphinx_html(self, source, max_heading_level=3, exclude_patterns=None):
            raise RuntimeError("boom")

        def get_index_status(self):
            return {"connected": False, "error": "down"}

    class BrokenClient:
        def __init__(self, cfg):
            pass

        def search(self, *args, **kwargs):
            raise RuntimeError("boom")

        def list_indices(self):
            raise RuntimeError("boom")

        def clear_index(self, index):
            raise RuntimeError("boom")

        def delete_index(self, index):
            raise RuntimeError("boom")

    monkeypatch.setattr(cli_mod, "DocumentIndexer", BrokenIndexer)
    monkeypatch.setattr(cli_mod, "MeilisearchClient", BrokenClient)

    src_dir = tmp_path / "src"
    src_dir.mkdir()

    runner = CliRunner()

    assert runner.invoke(cli_mod.cli, ["index-chats", "--source", str(src_dir)]).exit_code == 1
    assert runner.invoke(cli_mod.cli, ["index-html", "--source", str(src_dir)]).exit_code == 1
    assert runner.invoke(cli_mod.cli, ["status"]).exit_code == 1
    assert runner.invoke(cli_mod.cli, ["search", "--query", "q"]).exit_code == 1
    assert runner.invoke(cli_mod.cli, ["list-indices"]).exit_code == 1
    assert runner.invoke(cli_mod.cli, ["clear-index", "--confirm"]).exit_code == 1
    assert runner.invoke(cli_mod.cli, ["delete-index", "--confirm"]).exit_code == 1
