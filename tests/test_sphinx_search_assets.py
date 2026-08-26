from pathlib import Path


def test_sphinx_build_emits_search_ui_assets(tmp_path):
    """The HTML builder provides the browser-side Sphinx search UI."""
    import subprocess

    source = tmp_path / "docs"
    source.mkdir()
    (source / "conf.py").write_text(
        "extensions = ['myst_parser']\n"
        "project = 'search fixture'\n"
        "html_search_options = {'type': 'js'}\n"
    )
    (source / "index.md").write_text("# Search fixture\n\nSearchable content.\n")
    output = tmp_path / "build"

    subprocess.run(
        ["sphinx-build", "-b", "html", "-E", "-q", str(source), str(output)],
        check=True,
    )

    search_page = (output / "search.html").read_text(encoding="utf-8")
    search_script = output / "_static" / "searchtools.js"
    assert search_script.exists()
    assert "searchtools.js" in search_page
    assert 'src="searchindex.js"' in search_page


def test_enhanced_searchtools_renders_separate_docindex_mode(tmp_path):
    """The enhanced flag adds DocIndex UI without replacing native search."""
    import os
    import subprocess

    workspace = Path(__file__).parents[1]
    source = tmp_path / "docs"
    source.mkdir()
    (source / "conf.py").write_text(
        "import sys\n"
        f"sys.path.insert(0, {str(workspace)!r})\n"
        f"templates_path = [{str(workspace / 'docs' / '_templates')!r}]\n"
        f"html_static_path = [{str(workspace / 'docs' / '_static')!r}]\n"
        "extensions = ['myst_parser', 'sustainablefactory.searchtools']\n"
        "project = 'enhanced search fixture'\n"
        "enhanced_searchtools = True\n"
        "searchtools = {'native': {'enabled': True}, 'docindex': "
        "{'enabled': True, 'oxirs': {'enabled': False}, "
        "'meilisearch': {'enabled': False}}}\n"
    )
    (source / "index.md").write_text("# Enhanced search fixture\n")
    output = tmp_path / "build"
    environment = os.environ.copy()
    environment["PYTHONPATH"] = str(workspace)

    subprocess.run(
        ["sphinx-build", "-b", "html", "-E", "-q", str(source), str(output)],
        check=True,
        env=environment,
    )

    search_page = (output / "search.html").read_text(encoding="utf-8")
    assert "Native Sphinx search" in search_page
    assert "DocIndex search" in search_page
    assert "docindex-search.js" in search_page