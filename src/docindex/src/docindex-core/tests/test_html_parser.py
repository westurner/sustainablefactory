from pathlib import Path

import pytest

from docindex_core.html_parser import (
    BatchHTMLIndexer,
    HTMLSectionExtractor,
    SphinxHTMLParser,
)


def test_html_section_extractor_basic_and_script_style_ignored():
    html = """
    <h1>Title</h1>
    <p>Paragraph one</p>
    <code>inline-code</code>
    <h4>Ignored heading</h4>
    <script>ignore me</script>
    <style>.x{}</style>
    <h2>Sub</h2>
    <p>Paragraph two</p>
    """
    ex = HTMLSectionExtractor(max_heading_level=2)
    ex.feed(html)
    sections = ex.get_sections()
    assert len(sections) == 2
    assert sections[0]["title"] == "Title"


def test_html_section_extractor_paragraph_before_heading_raises():
    html = "<p>orphan paragraph</p>"
    ex = HTMLSectionExtractor()
    with pytest.raises(TypeError):
        ex.feed(html)


def test_html_section_extractor_unmatched_endtags_and_empty_paragraph():
    ex = HTMLSectionExtractor()
    # Unmatched end tag path.
    ex.handle_endtag("div")

    # Paragraph with no current_text path.
    ex.current_section = {"content": []}
    ex.current_text = []
    ex.handle_endtag("p")
    assert ex.current_section["content"] == []


def test_parse_html_file_happy_and_min_length(tmp_path):
    p = tmp_path / "page.html"
    p.write_text("<h1>Doc</h1><p>" + ("x" * 60) + "</p>")
    docs = SphinxHTMLParser.parse_html_file(p, min_content_length=50)
    assert len(docs) == 1
    assert docs[0].id.startswith("html_page_")

    docs2 = SphinxHTMLParser.parse_html_file(p, min_content_length=999)
    assert docs2 == []


def test_parse_html_file_empty_title_branch(tmp_path):
    p = tmp_path / "untitled.html"
    p.write_text("<h1></h1><p>" + ("z" * 80) + "</p>")
    docs = SphinxHTMLParser.parse_html_file(p, min_content_length=10)
    assert len(docs) == 1
    assert "Section" in docs[0].title


def test_parse_html_file_open_error(tmp_path):
    missing = tmp_path / "missing.html"
    assert SphinxHTMLParser.parse_html_file(missing) == []


def test_parse_html_file_feed_error_branch(tmp_path, monkeypatch):
    p = tmp_path / "page2.html"
    p.write_text("<h1>A</h1><p>" + ("y" * 80) + "</p>")

    class BrokenExtractor(HTMLSectionExtractor):
        def feed(self, data):  # noqa: D401
            raise RuntimeError("bad html")

    monkeypatch.setattr(
        "docindex_core.html_parser.HTMLSectionExtractor", BrokenExtractor
    )
    # feed fails, so no sections/documents.
    assert SphinxHTMLParser.parse_html_file(p) == []


@pytest.mark.parametrize(
    "path,stem,expected",
    [
        (Path("/a/b/html/readme.html"), "readme", "readme"),
        (Path("/x/y/z/index.html"), "index", "x/y/z/index"),
    ],
)
def test_calculate_url(path, stem, expected):
    assert SphinxHTMLParser._calculate_url(path, stem) == expected


@pytest.mark.parametrize(
    "text,expected",
    [
        (" Hello, World! ", "hello-world"),
        ("A   B---C", "a-b-c"),
    ],
)
def test_slugify(text, expected):
    assert SphinxHTMLParser._slugify(text) == expected


def test_batch_html_indexer_get_files_parse_all_total(tmp_path, monkeypatch):
    html_dir = tmp_path / "_build" / "html"
    (html_dir / "sub").mkdir(parents=True)

    (html_dir / "index.html").write_text("<h1>Home</h1><p>" + ("a" * 60) + "</p>")
    (html_dir / "genindex.html").write_text("<h1>Index</h1><p>" + ("b" * 60) + "</p>")
    (html_dir / "tables_and_figures.myst.html").write_text(
        "<h1>Tables</h1><p>" + ("t" * 60) + "</p>"
    )
    (html_dir / "sub" / "index.html").write_text("<h1>Nested</h1><p>" + ("c" * 60) + "</p>")
    (html_dir / "sub" / "page.html").write_text("<h1>Page</h1><p>" + ("d" * 60) + "</p>")

    idx = BatchHTMLIndexer(html_dir)
    files = idx.get_html_files()
    names = [f.name for f in files]
    assert "index.html" in names
    assert "genindex.html" not in names
    assert "tables_and_figures.myst.html" in names
    project_files = idx.get_html_files(
        exclude_patterns=["tables_and_figures.myst.html"]
    )
    assert "tables_and_figures.myst.html" not in [f.name for f in project_files]
    assert not any(str(f).endswith("sub/index.html") for f in files)

    original = SphinxHTMLParser.parse_html_file

    def maybe_boom(path, **kwargs):
        if path.name == "page.html":
            raise RuntimeError("boom")
        return original(path, **kwargs)

    monkeypatch.setattr(SphinxHTMLParser, "parse_html_file", staticmethod(maybe_boom))
    parsed = list(idx.parse_all())
    assert any(fp.name == "index.html" for fp, _ in parsed)
    assert idx.get_total_documents() >= 1


def test_batch_html_indexer_parse_all_skips_empty_documents(tmp_path, monkeypatch):
    html_dir = tmp_path / "_build" / "html"
    html_dir.mkdir(parents=True)
    (html_dir / "page.html").write_text("<h1>Page</h1><p>" + ("x" * 60) + "</p>")

    idx = BatchHTMLIndexer(html_dir)
    monkeypatch.setattr(SphinxHTMLParser, "parse_html_file", staticmethod(lambda *a, **k: []))
    assert list(idx.parse_all()) == []


def test_batch_html_indexer_init_missing_dir(tmp_path):
    with pytest.raises(ValueError):
        BatchHTMLIndexer(tmp_path / "missing")


def test_html_parser_ignores_script_and_style(tmp_path):
    p = tmp_path / "ignores.html"
    p.write_text("<h1>Ignore</h1><script>const a = 1;</script><style>body {color: red;}</style><p>Expected &amp; Text that is longer than min content length requirement which is fifty characters.</p>")
    docs = SphinxHTMLParser.parse_html_file(p)
    assert len(docs) == 1
    assert "Expected & Text" in docs[0].content
    assert "const a = 1" not in docs[0].content
    assert "body {" not in docs[0].content
