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


def test_hooks_setup_and_build_finished(monkeypatch, tmp_path, stats_obj):
    import docindex_sphinx.hooks as hooks

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

    cfg_disabled = SimpleNamespace(meilisearch_enabled=False)
    hooks.on_config_inited(app, cfg_disabled)
    cfg_enabled = SimpleNamespace(
        meilisearch_enabled=True,
        meilisearch_host="localhost",
        meilisearch_port=7700,
    )
    hooks.on_config_inited(app, cfg_enabled)

    app.config.meilisearch_enabled = False
    hooks.on_build_finished(app, None)

    app.config.meilisearch_enabled = True
    hooks.on_build_finished(app, RuntimeError("build failed"))

    app.builder.name = "dirhtml"
    hooks.on_build_finished(app, None)

    app.builder.name = "html"
    app.outdir = str(tmp_path / "missing")
    hooks.on_build_finished(app, None)

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

    m = importlib.import_module("docindex_sphinx.hooks")
    assert hasattr(m, "setup")