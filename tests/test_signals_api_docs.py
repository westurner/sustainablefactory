import sys
from pathlib import Path


sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "src" / "signals"))

import build_api_docs
from build_api_docs import SIGNALS_ROOT, module_name, rewrite_html_links, rewrite_module_href


def test_module_links_use_hosted_api_docs():
    assert rewrite_module_href(
        ".././Mathlib/Analysis/Real/Sqrt.html#Real.sqrt",
        "Signals/DDF.html",
        "https://github.com/hanwenzhu/LeanArchitect/blob/rev/",
    ) == (
        "https://leanprover-community.github.io/mathlib4_docs/"
        "Mathlib/Analysis/Real/Sqrt.html#Real.sqrt"
    )
    assert rewrite_module_href(
        ".././Physlib/Mechanics/Basic.html",
        "Signals/DDF.html",
        "https://github.com/hanwenzhu/LeanArchitect/blob/rev/",
    ) == "https://physlib.io/docs/Physlib/Mechanics/Basic.html"
    assert rewrite_module_href(
        ".././Init.html",
        "Signals/DDF.html",
        "https://github.com/hanwenzhu/LeanArchitect/blob/rev/",
    ) == "https://lean-lang.org/doc/api/Init.html"


def test_architect_links_use_pinned_source_and_drop_doc_anchor():
    assert rewrite_module_href(
        ".././Architect/Geometry.html#Architect.Geometry.Point",
        "Signals/DDF.html",
        "https://github.com/hanwenzhu/LeanArchitect/blob/revision/",
    ) == "https://github.com/hanwenzhu/LeanArchitect/blob/revision/Architect/Geometry.lean"
    assert rewrite_module_href(
        ".././Architect.html",
        "Signals/DDF.html",
        "https://github.com/hanwenzhu/LeanArchitect/blob/revision/",
    ) == "https://github.com/hanwenzhu/LeanArchitect/blob/revision/Architect.lean"


def test_local_and_absolute_links_are_unchanged():
    architect_base = "https://github.com/hanwenzhu/LeanArchitect/blob/revision/"
    assert rewrite_module_href(
        ".././Signals/DDF.html#Signals.DDF",
        "Signals/Pending.html",
        architect_base,
    ) == ".././Signals/DDF.html#Signals.DDF"
    assert rewrite_module_href(
        "https://example.com/guide.html",
        "Signals/DDF.html",
        architect_base,
    ) == "https://example.com/guide.html"


def test_html_rewrite_preserves_signals_links(tmp_path: Path):
    doc_dir = tmp_path / "doc"
    page = doc_dir / "Signals" / "DDF.html"
    page.parent.mkdir(parents=True)
    page.write_text(
        '<a href=".././Mathlib/Analysis/Real/Sqrt.html#Real.sqrt">Mathlib</a>'
        '<a href=".././Signals/Pending.html">Signals</a>',
        encoding="utf-8",
    )

    rewrite_html_links(doc_dir, "https://github.com/hanwenzhu/LeanArchitect/blob/rev/")

    content = page.read_text(encoding="utf-8")
    assert "https://leanprover-community.github.io/mathlib4_docs/Mathlib/Analysis/Real/Sqrt.html#Real.sqrt" in content
    assert 'href=".././Signals/Pending.html"' in content


def test_html_rewrite_prefers_existing_local_mathlib_page(tmp_path: Path):
    doc_dir = tmp_path / "doc"
    page = doc_dir / "Signals" / "DDF.html"
    local_mathlib_page = doc_dir / "Mathlib" / "Analysis" / "Real" / "Sqrt.html"
    page.parent.mkdir(parents=True)
    local_mathlib_page.parent.mkdir(parents=True)
    page.write_text(
        '<a href=".././Mathlib/Analysis/Real/Sqrt.html#Real.sqrt">Mathlib</a>',
        encoding="utf-8",
    )
    local_mathlib_page.write_text("<html></html>", encoding="utf-8")

    rewrite_html_links(doc_dir, "https://github.com/hanwenzhu/LeanArchitect/blob/rev/")

    content = page.read_text(encoding="utf-8")
    assert 'href=".././Mathlib/Analysis/Real/Sqrt.html#Real.sqrt"' in content


def test_generated_docs_cleanup_preserves_hosted_dependency_pages(tmp_path: Path, monkeypatch):
    doc_dir = tmp_path / "doc"
    local_mathlib_page = doc_dir / "Mathlib" / "Analysis" / "Real" / "Sqrt.html"
    stale_signals_page = doc_dir / "Signals" / "OldModule.html"
    local_mathlib_page.parent.mkdir(parents=True)
    stale_signals_page.parent.mkdir(parents=True)
    local_mathlib_page.write_text("<html></html>", encoding="utf-8")
    stale_signals_page.write_text("<html></html>", encoding="utf-8")
    monkeypatch.setattr(build_api_docs, "DOC_DIR", doc_dir)

    build_api_docs.clear_generated_docs()

    assert local_mathlib_page.is_file()
    assert not stale_signals_page.exists()


def test_module_name_uses_source_path():
    source = SIGNALS_ROOT / "Signals" / "DDF.lean"
    assert module_name(source) == "Signals.DDF"