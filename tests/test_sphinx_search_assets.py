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