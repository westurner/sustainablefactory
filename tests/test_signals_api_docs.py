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


def test_sanitize_blueprint_tex_escapes_percent_ampersand_and_currency_dollar(tmp_path: Path):
    bp_dir = tmp_path / "blueprint" / "module" / "Signals" / "SolitonBus.artifacts"
    bp_dir.mkdir(parents=True)
    artifact = bp_dir / "thm:test.tex"
    artifact.write_text(
        "\\begin{theorem}[Master theorem: Ragone & 98% recovery, $876k/yr savings, e in [0, 1)]\n"
        "% at /workspaces/sustainablefactory/src/signals/Signals/SolitonBus.lean:10.0-20.0\n"
        "Proves 37.5% PWM & $\\begin{pmatrix} a & b \\\\ c & d \\end{pmatrix}$ balance.\n"
        "\\end{theorem}\n",
        encoding="utf-8",
    )

    repaired = build_api_docs.sanitize_blueprint_tex(tmp_path / "blueprint")
    assert repaired == 1

    sanitized = artifact.read_text(encoding="utf-8")
    lines = sanitized.splitlines()
    assert lines[0] == (
        r"\begin{theorem}[Master theorem: Ragone \& 98\% recovery, \$876k/yr savings, "
        r"e in $\lbrack$0, 1)]"
    )
    assert lines[1].startswith("% at ")
    assert r"37.5\% PWM \& $\begin{pmatrix} a & b \\ c & d \end{pmatrix}$" in lines[2]
    # Second run is idempotent
    assert build_api_docs.sanitize_blueprint_tex(tmp_path / "blueprint") == 0


def test_cache_manifest_roundtrip(tmp_path: Path, monkeypatch):
    cache_file = tmp_path / "api-docs-cache.json"
    monkeypatch.setattr(build_api_docs, "CACHE_MANIFEST", cache_file)
    assert build_api_docs.load_cache_manifest() is None

    build_api_docs.save_cache_manifest("global123", {"Signals.DFT": "abc", "Signals.DDF": "def"})
    loaded = build_api_docs.load_cache_manifest()
    assert loaded is not None
    assert loaded["global_hash"] == "global123"
    assert loaded["module_hashes"] == {"Signals.DFT": "abc", "Signals.DDF": "def"}


def test_sanitize_blueprint_tex_preserves_multiline_matrix_and_cases_ampersands():
    raw_tex = (
        "\\begin{theorem}[Slavnov & Cases Test]\n"
        "Cost is $500 for A & B with:\n"
        "\\[\n"
        "M = \\begin{pmatrix}\n"
        "  K(v_0, u_0) & K(v_0, u_1) \\\\\n"
        "  K(v_1, u_0) & K(v_1, u_1)\n"
        "\\end{pmatrix}, \\qquad\n"
        "f(x) = \\begin{cases} 1 & x > 0 \\\\ 0 & x \\le 0 \\end{cases} \\text{ & done.}\n"
        "\\]\n"
        "\\end{theorem}\n"
    )
    sanitized = build_api_docs.sanitize_blueprint_tex_text(raw_tex)
    assert r"Cost is \$500 for A \& B with:" in sanitized
    assert "  K(v_0, u_0) & K(v_0, u_1) \\\\" in sanitized
    assert "  K(v_1, u_0) & K(v_1, u_1)" in sanitized
    assert r"\begin{cases} 1 & x > 0 \\ 0 & x \le 0 \end{cases}" in sanitized
    assert r"\text{ \& done.}" in sanitized
    # Idempotence check
    assert build_api_docs.sanitize_blueprint_tex_text(sanitized) == sanitized

    # Regression test: multi-line inline math after `$2\times 5$` must NOT escape `$2`
    multiline_math = (
        "\\begin{definition}[Triple-slit]\n"
        "Define the $2\\times 5$ matrix $M =\n"
        "M_0 \\in \\mathbb{C}^{2\\times 5}$.\n"
        "\\end{definition}\n"
    )
    assert build_api_docs.sanitize_blueprint_tex_text(multiline_math) == multiline_math

    # Regression test: subarray environment preserves `&` alignment separators
    subarray_math = (
        "\\begin{lemma}[Subarray]\n"
        "$\\sum_{\\begin{subarray}{c} i & j \\end{subarray}} a_{ij}$ & text.\n"
        "\\end{lemma}\n"
    )
    assert (
        r"\sum_{\begin{subarray}{c} i & j \end{subarray}} a_{ij}$ \& text."
        in build_api_docs.sanitize_blueprint_tex_text(subarray_math)
    )


def test_conf_signals_blueprint_hash_tracks_disable_equations(tmp_path: Path, monkeypatch):
    import docs.conf as docs_conf

    sig_dir = tmp_path / "signals"
    (sig_dir / "Signals").mkdir(parents=True)
    (sig_dir / "blueprint" / "src").mkdir(parents=True)
    (sig_dir / "Signals" / "Core.lean").write_text("def x := 1\n", encoding="utf-8")
    (sig_dir / "Signals.lean").write_text("import Signals.Core\n", encoding="utf-8")
    (sig_dir / "blueprint" / "src" / "web.tex").write_text("hello\n", encoding="utf-8")
    (sig_dir / "blueprint" / "src" / "plastex.paux").write_text("ignored\n", encoding="utf-8")
    for fname in ("Makefile", "build_api_docs.py", "lakefile.toml", "lake-manifest.json", "requirements-blueprint.txt"):
        (sig_dir / fname).write_text(fname, encoding="utf-8")

    monkeypatch.setenv("DISABLE_EQUATIONS", "1")
    h1 = docs_conf._compute_signals_blueprint_input_hash(sig_dir)
    # Changing .paux does not invalidate hash
    (sig_dir / "blueprint" / "src" / "plastex.paux").write_text("changed\n", encoding="utf-8")
    assert docs_conf._compute_signals_blueprint_input_hash(sig_dir) == h1

    # Changing DISABLE_EQUATIONS invalidates hash
    monkeypatch.setenv("DISABLE_EQUATIONS", "0")
    h0 = docs_conf._compute_signals_blueprint_input_hash(sig_dir)
    assert h0 != h1
