# Configuration file for the Sphinx documentation builder.
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
    "wrd_sphinx_theme",
]

templates_path = ["_templates"]
exclude_patterns = [
    "_build",
    "Thumbs.db",
    ".DS_Store",
    "__pycache__",
    "chats/*.chatexport_abc1.md",
]

# -- MyST Parser configuration -----------------------------------------------
myst_enable_extensions = [
    "colon_fence",
    "deflist",
    "dollarmath",
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

# -- Mermaid configuration ---------------------------------------------------
# You can use a CDN or local file for mermaid.js
# mermaid_version = "10.2.0"

# -- Options for HTML output -------------------------------------------------
try:
    import wrd_sphinx_theme

    html_theme = "wrd_sphinx_theme"
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
        / "src" / "docindex-core" / "src" / "docindex_core" / "synonyms.yaml"
    )
    if synonyms_yaml.exists():
        synonyms = SynonymsManager.load(synonyms_yaml)
        data = GlossaryManager.merge_synonyms(data, synonyms)

    changed = GlossaryManager.write_myst_if_changed(
        data, glossary_md, source_path=glossary_yaml
    )
    if changed:
        import logging
        logging.getLogger(__name__).info(
            "glossary.md regenerated from glossary.yaml"
        )


def setup(app):
    # Regenerate glossary.md from glossary.yaml at build start
    app.connect("builder-inited", lambda app: _regenerate_glossary(app))
