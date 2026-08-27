import json
import subprocess
from pathlib import Path

from sphinxcontrib.webmcp.extension import _public_search_config

ROOT = Path(__file__).parents[1]


def test_public_search_config_drops_private_api_keys():
    config = _public_search_config(
        {
            "search": {
                "native": True,
                "docindex": {
                    "enabled": True,
                    "oxirs": {
                        "enabled": True,
                        "url": "http://oxirs/query",
                    },
                    "meilisearch": {
                        "enabled": True,
                        "url": "http://meili",
                        "api_key": "private-admin-key",
                        "public_api_key": "public-search-key",
                    },
                },
            }
        }
    )

    assert config["docindex"]["meilisearch"]["public_api_key"] == "public-search-key"
    assert "api_key" not in config["docindex"]["meilisearch"]


def test_webmcp_build_emits_theme_independent_manifest_and_script(tmp_path):
    source = tmp_path / "docs"
    source.mkdir()
    (source / "conf.py").write_text(
        "import sys\n"
        f"sys.path.insert(0, {str(ROOT / 'src' / 'sphinxcontrib-webmcp' / 'src')!r})\n"
        "extensions = ['myst_parser', 'sphinxcontrib.webmcp']\n"
        "source_suffix = {'.md': 'markdown'}\n"
        "master_doc = 'index'\n"
        "project = 'WebMCP fixture'\n"
        "docindex_webmcp_enabled = True\n"
        "docindex_webmcp = {'search': {'native': True, 'docindex': {'enabled': False}}}\n"
    )
    (source / "index.md").write_text(
        "# Home\n\n## Getting started\n\nWebMCP fixture content.\n"
    )
    output = tmp_path / "build"

    subprocess.run(
        ["sphinx-build", "-b", "html", "-E", "-W", str(source), str(output)],
        check=True,
    )

    manifest = json.loads((output / "webmcp.json").read_text(encoding="utf-8"))
    page = manifest["pages"][0]
    assert (output / "_static" / "webmcp.js").exists()
    assert manifest["navigation"]["root"] == "index"
    assert page["url"] == "index.html"
    heading = next(
        heading
        for heading in page["doctree"]["headings"]
        if heading["title"] == "Getting started"
    )
    assert heading["level"] == 2
    assert '"api_key"' not in json.dumps(manifest)

    script = (
        ROOT
        / "src"
        / "sphinxcontrib-webmcp"
        / "src"
        / "sphinxcontrib"
        / "webmcp"
        / "static"
        / "webmcp.js"
    ).read_text(encoding="utf-8")
    for tool_name in (
        "sphinx.get_page_context",
        "sphinx.list_navigation",
        "sphinx.get_documentation_metadata",
        "sphinx.search",
        "sphinx.navigate",
    ):
        assert tool_name in script
