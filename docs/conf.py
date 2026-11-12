# Configuration file for the Sphinx documentation builder.
import os
import shutil
import subprocess
import sys
from pathlib import Path

# Add the project root to sys.path so we can import the parser/gen modules if needed
sys.path.insert(0, str(Path(__file__).parents[1]))

project = "Sustainable Factory"
copyright = "2026, @westurner"
author = "@westurner"
release = "0.1.0"

# -- General configuration ---------------------------------------------------
extensions = [
    "myst_parser",
    "sphinxcontrib.bibtex",
    "sphinxcontrib.mermaid",
    "sphinx.ext.coverage",
    # "sphinx.ext.doctest",
    # "sphinx.ext.githubpages",
    # "sphinx.ext.ifconfig",
    # "sphinx.ext.imgmath",  # requires `latex`
    "sphinx.ext.intersphinx",
    "sphinx.ext.mathjax",
    "sphinx.ext.autodoc",
    "sphinx.ext.napoleon",
    # "sphinx.ext.todo",
    "sphinx.ext.viewcode",
    "sphinxcontrib.webmcp",
    "docindex_sphinx.hooks",
    "sustainablefactory.sphinx_yaml_toc",
    "sustainablefactory.searchtools",
]

templates_path = ["_templates"]
exclude_patterns = [
    "_build",
    "Thumbs.db",
    ".DS_Store",
    "__pycache__",
    "chats/*.chatexport_abc1.md",
]

docindex_html_exclude_patterns = [
    "tables_and_figures.html",
    "chats/*.html",
]

html_search_options = {"type": "js"}

docindex_searchtools_enhanced = True
docindex_static_wasm_enabled = True
docindex_rdf_hdt_enabled = True
docindex_searchtools = {
    "rdf_hdt": {
        "enabled": True,
        "static_hdt": "_static/docindex.hdt",
        "hdt_module": "",
    },
    "native": {"enabled": True},
    "docindex": {
        "enabled": True,
        "index": "all",
        "oxirs": {
            "enabled": True,
            "url": "",
            "query_url": "http://localhost:7878/query",
            "static_data": "_static/docindex.nt",
            "wasm_module": "_static/oxirs_wasm.js",
            "static_hdt": "_static/docindex.hdt",
            "hdt_enabled": True,
            "hdt_module": "",
            "index": "all",
        },
        "meilisearch": {
            "enabled": False,
            "url": "http://localhost:7700",
            "index": "all",
            "public_api_key": "",
        },
    },
}


docindex_webmcp_enabled = True
docindex_webmcp = {
    "exposed_to": [],
    "search": {
        "native": True,
        "docindex": {
            "enabled": True,
            "index": "all",
            "oxirs": {
                "enabled": True,
                "url": "",
                "query_url": "http://localhost:7878/query",
                "static_data": "_static/docindex.nt",
                "wasm_module": "_static/oxirs_wasm.js",
                "static_hdt": "_static/docindex.hdt",
                "hdt_enabled": True,
                "hdt_module": "",
            },
            "meilisearch": {
                "enabled": False,
                "url": "http://localhost:7700",
                "public_api_key": "",
            },
        },
    },
}

# -- MyST Parser configuration -----------------------------------------------
myst_enable_extensions = [
    "colon_fence",
    "deflist",
    "dollarmath",
    "amsmath",
    "fieldlist",
    "html_admonition",
    "html_image",
    "linkify",
    "replacements",
    "smartquotes",
    "substitution",
    "tasklist",
]

myst_fence_as_directive = ["mermaid"]

bibtex_bibfiles = ["citations.bib"]
bibtex_default_style = "unsrt"
bibtex_reference_style = "author_year"

# -- Mermaid configuration ---------------------------------------------------
# You can use a CDN or local file for mermaid.js
# mermaid_version = "10.2.0"

# -- Options for HTML output -------------------------------------------------
try:
    import wrd_sphinx_theme

    html_theme = "wrd_sphinx_theme"
    extensions.append("wrd_sphinx_theme")
except ImportError:
    # html_theme = "furo"      # pip install furo
    # html_theme = "sphinxdoc" # native
    # html_theme = "nature"    # native
    html_theme = "classic"  # native
    print(f"NOTE: wrd_sphinx_theme not found. Defaulting to html_theme={html_theme!r}")

html_static_path = [
    static_path
    for static_path in (
        "_static",
        "data/",
    )
    if (Path(__file__).parent / static_path).is_dir()
]


# -- Custom Setup to handle RDF visualization --------------------------------
def _regenerate_glossary(app):
    """Regenerate docs/glossary.md from docs/glossary.yaml before building.

    Only rewrites the file when the content would change, so incremental
    Sphinx builds stay fast.  Skips silently when docindex_core is not
    installed (e.g. read-the-docs minimal builds).
    """
    try:
        from docindex_core import GlossaryManager, SynonymsManager
    except ImportError:
        return

    docs_dir = Path(__file__).parent
    glossary_yaml = docs_dir / "glossary.yaml"
    glossary_md = docs_dir / "glossary.md"

    if not glossary_yaml.exists():
        return

    data = GlossaryManager.load(glossary_yaml)

    # Optionally fold in synonyms from the bundled synonyms.yaml
    synonyms_yaml = (
        docs_dir.parent
        / "src"
        / "docindex-core"
        / "src"
        / "docindex_core"
        / "synonyms.yaml"
    )
    if synonyms_yaml.exists():
        synonyms = SynonymsManager.load(synonyms_yaml)
        data = GlossaryManager.merge_synonyms(data, synonyms)

    changed = GlossaryManager.write_myst_if_changed(
        data, glossary_md, source_path=glossary_yaml
    )
    if changed:
        import logging

        logging.getLogger(__name__).info("glossary.md regenerated from glossary.yaml")


def _compute_signals_blueprint_input_hash(signals_dir: Path) -> str:
    import hashlib

    digest = hashlib.sha256()
    tracked_files = sorted(
        list((signals_dir / "Signals").rglob("*.lean"))
        + list(signals_dir.glob("Signals*.lean"))
        + list((signals_dir / "blueprint" / "src").rglob("*"))
        + [
            signals_dir / "Makefile",
            signals_dir / "build_api_docs.py",
            signals_dir / "lakefile.toml",
            signals_dir / "lake-manifest.json",
            signals_dir / "requirements-blueprint.txt",
        ]
    )
    for path in tracked_files:
        if path.is_file() and path.suffix != ".paux":
            digest.update(str(path.relative_to(signals_dir)).encode("utf-8"))
            digest.update(b"\0")
            digest.update(path.read_bytes())
            digest.update(b"\0")
    disable_eq = os.environ.get("DISABLE_EQUATIONS", "1")
    digest.update(f"DISABLE_EQUATIONS={disable_eq}\0".encode("utf-8"))
    return digest.hexdigest()


def _build_signals_blueprint(app):
    if app.builder.format != "html":
        return
    if os.environ.get("SIGNALS_BLUEPRINT_PREBUILT") == "1":
        return

    repo_root = Path(__file__).resolve().parents[1]
    signals_dir = repo_root / "src" / "signals"
    build_dir = signals_dir / ".lake" / "build"
    stamp_path = build_dir / "sphinx-blueprint-inputs.sha256"
    web_index = signals_dir / "blueprint" / "web" / "index.html"
    api_index = build_dir / "doc" / "Signals.html"
    linked_api_index = signals_dir / "blueprint" / "web" / "signals-api" / "Signals.html"

    current_hash = _compute_signals_blueprint_input_hash(signals_dir)
    if (
        os.environ.get("SIGNALS_API_FORCE_REBUILD") != "1"
        and stamp_path.is_file()
        and stamp_path.read_text(encoding="utf-8").strip() == current_hash
        and web_index.is_file()
        and api_index.is_file()
        and linked_api_index.is_file()
    ):
        return

    tmp_dir = repo_root / ".tmp"
    if not tmp_dir.exists():
        tmp_dir.mkdir(mode=0o1777)
        tmp_dir.chmod(0o1777)

    log_path = tmp_dir / "signals-blueprint.log"
    env = os.environ.copy()
    env["TMPDIR"] = str(tmp_dir)
    with log_path.open("w", encoding="utf-8") as log_file:
        result = subprocess.run(
            ["make", "-C", str(signals_dir), "blueprint"],
            cwd=repo_root,
            env=env,
            stdout=log_file,
            stderr=subprocess.STDOUT,
            check=False,
        )
    if result.returncode != 0:
        tail = "\n".join(log_path.read_text(encoding="utf-8").splitlines()[-60:])
        raise RuntimeError(
            f"Signals blueprint build failed (see {log_path}):\n{tail}"
        )
    build_dir.mkdir(parents=True, exist_ok=True)
    stamp_path.write_text(current_hash + "\n", encoding="utf-8")


def _copy_signals_blueprint(app, exception):
    if exception is not None or app.builder.format != "html":
        return

    repo_root = Path(__file__).resolve().parents[1]
    source = repo_root / "src" / "signals" / "blueprint" / "web"
    if not source.is_dir():
        return
    destination = Path(app.outdir) / "signals-blueprint"
    if destination.exists():
        shutil.rmtree(destination)

    def link_or_copy(src, dst):
        try:
            os.link(src, dst)
        except OSError:
            shutil.copy2(src, dst)

    shutil.copytree(source, destination, copy_function=link_or_copy)


def setup(app):
    # Regenerate glossary.md from glossary.yaml at build start
    app.connect("builder-inited", lambda app: _regenerate_glossary(app))
    app.connect("builder-inited", _build_signals_blueprint)
    app.connect("build-finished", _copy_signals_blueprint)
