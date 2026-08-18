from pathlib import Path
from types import SimpleNamespace

import pytest
import yaml
from click.testing import CliRunner
from docindex_core.config import IndexingStats


@pytest.fixture(autouse=True)
def cli_test_backend(monkeypatch):
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


def test_cli_commands(monkeypatch, tmp_path, stats_obj):
    import importlib

    cli_mod = importlib.import_module("docindex_cli.cli")

    class FakeIndexer:
        def __init__(self, cfg):
            self.cfg = cfg

        def index_chat_directory(self, source, skip_unchanged=False):
            return stats_obj

        def index_sphinx_html(
            self,
            source,
            max_heading_level=3,
            exclude_patterns=None,
            max_retries=3,
            retry_delay=1.0,
            staging_suffix="_staging",
        ):
            return stats_obj

        def index_sphinx_html_legacy(
            self, source, max_heading_level=3, exclude_patterns=None
        ):
            return stats_obj

        def get_index_status(self):
            return {"connected": True, "indices": {"all": {"documents": 2}}}

    class FakeClient:
        def __init__(self, cfg):
            self.cfg = cfg

        def search(self, index, query, limit=10):
            return [
                SimpleNamespace(
                        id="doc-1",
                        title="T",
                        type="chat",
                        relevance_score=0.5,
                        url=None,
                        source_uri="file:///workspace/doc-1.md",
                        content_snippet="x",
                )
            ]

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

    result = runner.invoke(
        cli_mod.cli, ["index-chats", "--source", str(src_dir), "--batch-size", "5"]
    )
    assert result.exit_code == 0

    result = runner.invoke(
        cli_mod.cli, ["index-html", "--source", str(src_dir), "--headings", "bad"]
    )
    assert result.exit_code == 0

    result = runner.invoke(cli_mod.cli, ["status"])
    assert result.exit_code == 0

    result = runner.invoke(cli_mod.cli, ["search", "--index", "all", "--query", "abc"])
    assert result.exit_code == 0

    result = runner.invoke(cli_mod.cli, ["search", "--index", "all", "abc"])
    assert result.exit_code == 0

    result = runner.invoke(cli_mod.cli, ["list-indices"])
    assert result.exit_code == 0

    result = runner.invoke(cli_mod.cli, ["clear-index", "--index", "all", "--confirm"])
    assert result.exit_code == 0

    result = runner.invoke(cli_mod.cli, ["delete-index", "--index", "all", "--confirm"])
    assert result.exit_code == 0


def test_default_oxirs_storage_path_uses_workspace_root():
    import importlib

    cli_mod = importlib.import_module("docindex_cli.cli")
    workspace_root = Path(__file__).resolve().parents[5]

    assert Path(cli_mod._default_oxirs_storage_path()) == (
        workspace_root / ".tmp" / "docindex" / "oxirs"
    )


def test_cli_c12_search_includes_term_in_snippet(monkeypatch):
    import importlib

    cli_mod = importlib.import_module("docindex_cli.cli")
    received_queries = []

    class FakeClient:
        def __init__(self, cfg):
            pass

        def search(self, index, query, limit=10):
            received_queries.append(query)
            return [
                SimpleNamespace(
                    id="doc-c12",
                    title="C12 architecture",
                    type="chat",
                    relevance_score=1.0,
                    url=None,
                    source_uri="file:///workspace/c12.md",
                    content_snippet="C12 uses a carbon nanotube as the qubit.",
                ),
                SimpleNamespace(
                    id="doc-c12-2",
                    title="Isotopic carbon",
                    type="chat",
                    relevance_score=1.0,
                    url=None,
                    source_uri="urn:docindex:doc c12-2",
                    content_snippet="The c12 isotope is used in this design.",
                ),
            ]

    monkeypatch.setattr(cli_mod, "MeilisearchClient", FakeClient)

    result = CliRunner().invoke(cli_mod.cli, ["search", "C12"])

    assert result.exit_code == 0, result.output
    assert received_queries == ["C12"]

    yaml_output = result.output[result.output.index("- rank:") :]
    rendered_results = yaml.safe_load(yaml_output)
    snippets = [item["snippet"] for item in rendered_results]
    source_uris = [item["source_uri"] for item in rendered_results]

    assert snippets
    assert all("c12" in snippet.casefold() for snippet in snippets)
    assert source_uris == ["file:///workspace/c12.md", "urn:docindex:doc%20c12-2"]


def test_cli_search_adds_browser_highlight_and_source_location(monkeypatch, tmp_path):
    import importlib

    cli_mod = importlib.import_module("docindex_cli.cli")
    source_path = tmp_path / "html with spaces" / "tables.html"
    source_path.parent.mkdir()
    source_path.write_text("heading\nC12 is here\n", encoding="utf-8")

    class FakeClient:
        def __init__(self, cfg):
            pass

        def search(self, index, query, limit=10):
            return [
                SimpleNamespace(
                    id="doc-c12",
                    title="C12 section",
                    type="sphinx_html",
                    relevance_score=1.0,
                    url="tables and figures.myst#scaling the magnetic vacuum",
                    source_uri=source_path.as_uri(),
                    content_snippet="C12 is here",
                )
            ]

    monkeypatch.setattr(cli_mod, "MeilisearchClient", FakeClient)

    result = CliRunner().invoke(
        cli_mod.cli,
        ["search", "C12", "--url-prefix", "https://docs.example/reference"],
    )

    assert result.exit_code == 0, result.output
    rendered = yaml.safe_load(result.output[result.output.index("- rank:") :])[0]
    assert (
        rendered["url"]
        == "tables%20and%20figures.myst#scaling%20the%20magnetic%20vacuum"
    )
    assert rendered["browser_url"] == (
        "https://docs.example/reference/tables%20and%20figures.myst?highlight=C12#"
        "scaling%20the%20magnetic%20vacuum"
    )
    assert rendered["source_location"] == f"{source_path}:2:1"
    assert f'  source_location: "{source_path}:2:1"' in result.output
    assert rendered["open"] == rendered["browser_url"]


def test_cli_search_osc8_is_text_only_and_disableable(monkeypatch):
    import importlib

    cli_mod = importlib.import_module("docindex_cli.cli")

    class FakeClient:
        def __init__(self, cfg):
            pass

        def search(self, index, query, limit=10):
            return [
                SimpleNamespace(
                    id="doc-c12",
                    title="C12 section",
                    type="chat",
                    relevance_score=1.0,
                    url="https://docs.example/c12",
                    source_uri="urn:docindex:doc-c12",
                    content_snippet="C12 is here",
                )
            ]

    monkeypatch.setattr(cli_mod, "MeilisearchClient", FakeClient)

    yaml_result = CliRunner().invoke(cli_mod.cli, ["search", "C12"])
    text_result = CliRunner().invoke(
        cli_mod.cli,
        [
            "search",
            "C12",
            "--output-format",
            "text",
            "--url-prefix",
            "https://docs.example",
        ],
    )
    plain_result = CliRunner().invoke(
        cli_mod.cli,
        ["search", "C12", "--output-format", "text", "--no-osc8"],
    )

    assert yaml_result.exit_code == 0
    yaml.safe_load(yaml_result.output[yaml_result.output.index("- rank:") :])
    assert "\033]8;;" not in yaml_result.output
    assert "\033]8;;https://docs.example/c12?highlight=C12" in text_result.output
    assert "\033]8;;" not in plain_result.output


def test_cli_empty_and_cancel_branches(monkeypatch):
    import importlib

    cli_mod = importlib.import_module("docindex_cli.cli")

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

    cli_mod = importlib.import_module("docindex_cli.cli")

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

    clear_result = runner.invoke(
        cli_mod.cli, ["clear-index", "--index", "all"], input="y\n"
    )
    assert clear_result.exit_code == 0
    delete_result = runner.invoke(
        cli_mod.cli, ["delete-index", "--index", "all"], input="y\n"
    )
    assert delete_result.exit_code == 0


def test_cli_status_exception_branch(monkeypatch):
    import importlib

    cli_mod = importlib.import_module("docindex_cli.cli")

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

    cli_mod = importlib.import_module("docindex_cli.cli")

    class BrokenIndexer:
        def __init__(self, cfg):
            pass

        def index_chat_directory(self, source, skip_unchanged=False):
            raise RuntimeError("boom")

        def index_sphinx_html(
            self,
            source,
            max_heading_level=3,
            exclude_patterns=None,
            max_retries=3,
            retry_delay=1.0,
            staging_suffix="_staging",
        ):
            raise RuntimeError("boom")

        def index_sphinx_html_legacy(
            self, source, max_heading_level=3, exclude_patterns=None
        ):
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

    assert (
        runner.invoke(
            cli_mod.cli,
            [
                "index-chats",
                "--source",
                str(src_dir),
                "--backend",
                "milli",
                "--oxirs-url",
                "http://x",
                "--oxirs-storage-path",
                "/tmp/y",
            ],
        ).exit_code
        == 1
    )
    assert (
        runner.invoke(
            cli_mod.cli,
            [
                "index-html",
                "--source",
                str(src_dir),
                "--backend",
                "milli",
                "--oxirs-url",
                "http://x",
                "--oxirs-storage-path",
                "/tmp/y",
            ],
        ).exit_code
        == 1
    )
    assert (
        runner.invoke(
            cli_mod.cli,
            [
                "index-html-legacy",
                "--source",
                str(src_dir),
                "--backend",
                "milli",
                "--oxirs-url",
                "http://x",
                "--oxirs-storage-path",
                "/tmp/y",
            ],
        ).exit_code
        == 1
    )
    assert runner.invoke(cli_mod.cli, ["--backend", "milli", "status"]).exit_code == 1
    assert (
        runner.invoke(
            cli_mod.cli, ["--backend", "milli", "search", "--query", "q"]
        ).exit_code
        == 1
    )
    assert (
        runner.invoke(cli_mod.cli, ["--backend", "milli", "list-indices"]).exit_code
        == 1
    )
    assert (
        runner.invoke(
            cli_mod.cli, ["--backend", "milli", "clear-index", "--confirm"]
        ).exit_code
        == 1
    )
    assert (
        runner.invoke(
            cli_mod.cli, ["--backend", "milli", "delete-index", "--confirm"]
        ).exit_code
        == 1
    )


def test_cli_index_html_atomic_options(monkeypatch, tmp_path, stats_obj):
    """index-html passes all atomic options through to index_sphinx_html."""
    import importlib

    cli_mod = importlib.import_module("docindex_cli.cli")

    received = {}

    class FakeIndexer:
        def __init__(self, cfg):
            pass

        def index_sphinx_html(
            self,
            source,
            max_heading_level=3,
            exclude_patterns=None,
            max_retries=3,
            retry_delay=1.0,
            staging_suffix="_staging",
        ):
            received.update(
                max_retries=max_retries,
                retry_delay=retry_delay,
                staging_suffix=staging_suffix,
                max_heading_level=max_heading_level,
            )
            return stats_obj

    monkeypatch.setattr(cli_mod, "DocumentIndexer", FakeIndexer)

    src_dir = tmp_path / "src"
    src_dir.mkdir()
    runner = CliRunner()

    result = runner.invoke(
        cli_mod.cli,
        [
            "index-html",
            "--source",
            str(src_dir),
            "--headings",
            "1-4",
            "--max-retries",
            "5",
            "--retry-delay",
            "2.5",
            "--staging-suffix",
            "_tmp",
        ],
    )
    assert result.exit_code == 0, result.output
    assert received["max_retries"] == 5
    assert received["retry_delay"] == 2.5
    assert received["staging_suffix"] == "_tmp"
    assert received["max_heading_level"] == 4
    assert "Strategy: Version-tag GC" in result.output


def test_cli_index_html_legacy_success(monkeypatch, tmp_path, stats_obj):
    """index-html-legacy calls index_sphinx_html_legacy and shows deprecation note."""
    import importlib

    cli_mod = importlib.import_module("docindex_cli.cli")

    class FakeIndexer:
        def __init__(self, cfg):
            pass

        def index_sphinx_html_legacy(
            self, source, max_heading_level=3, exclude_patterns=None
        ):
            return stats_obj

    monkeypatch.setattr(cli_mod, "DocumentIndexer", FakeIndexer)

    src_dir = tmp_path / "src"
    src_dir.mkdir()
    runner = CliRunner()

    result = runner.invoke(cli_mod.cli, ["index-html-legacy", "--source", str(src_dir)])
    assert result.exit_code == 0, result.output
    assert "legacy" in result.output.lower()
    assert "index-html" in result.output  # deprecation note pointing to primary command


def test_cli_index_html_cancellation(monkeypatch, tmp_path):
    """index-html exits cleanly on KeyboardInterrupt with non-zero code."""
    import importlib

    cli_mod = importlib.import_module("docindex_cli.cli")

    class FakeIndexer:
        def __init__(self, cfg):
            pass

        def index_sphinx_html(self, source, **kwargs):
            raise KeyboardInterrupt()

    monkeypatch.setattr(cli_mod, "DocumentIndexer", FakeIndexer)

    src_dir = tmp_path / "src"
    src_dir.mkdir()
    runner = CliRunner()

    result = runner.invoke(cli_mod.cli, ["index-html", "--source", str(src_dir)])
    assert result.exit_code == 1
    assert "Cancelled" in result.output


def test_cli_multi_backend_and_empty_value_error(monkeypatch):
    import importlib

    cli_mod = importlib.import_module("docindex_cli.cli")

    # 1. Multi backend
    config_multi = SimpleNamespace(
        backend="oxirs,milli",
        url="http://remote",
        storage_path="/tmp/fake",
        batch_size=10,
        enabled=True,
        host="localhost",
        port=7700,
        api_key="key",
        index_name="index",
    )
    # mock OxiRSBackend and MeilisearchClient to avoid real connections
    monkeypatch.setattr(cli_mod, "MeilisearchClient", lambda x: "milli_client")

    backend_multi = cli_mod.get_backend(config_multi)
    from docindex_core.backends.multi import MultiBackend

    assert isinstance(backend_multi, MultiBackend)
    assert len(backend_multi.backends) == 2
