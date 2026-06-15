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
exclude_patterns = ["_build", "Thumbs.db", ".DS_Store", "__pycache__"]

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

html_static_path = ["_static", "../schema"]


# -- Custom Setup to handle RDF visualization --------------------------------
def setup(app):
    # This is where we could add custom directives for RDF if we wanted
    pass
