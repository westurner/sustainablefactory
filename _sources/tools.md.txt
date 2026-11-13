
# Tools
Tools used to develop, build, and document the sustainablefactory project.

## Software Inventory and Citations

The software bibliography is generated from repository installation manifests
by [`tools/generate_software_citations.py`](../tools/generate_software_citations.py).
It currently contains 838 package and tool records: 216 Python distributions,
322 Rust crates and tools, 167 Ubuntu packages, 105 npm packages, 8 Lean
packages or toolchains, 15 unique VS Code extensions, 3 runtimes, and 2 browser
installations. Cite an entry with its generated key, for example
{cite}`software-python-sphinx` or {cite}`software-node-playwright`.

The generator scans 37 `pyproject.toml` files, 27 `requirements*.txt` files,
127 `Cargo.toml` files, 25 `package.json` files, 4 `lakefile.toml` files,
Makefiles, `.devcontainer/devcontainer.json`, and `Dockerfile.e2e`. The recursive
scan intentionally includes vendored, example, and test projects. A declaration
in one of those manifests does not mean that package is installed in the main
development container. `requirements-dev.txt` also references
`requirements-meilisearch.txt`, which is not present in this checkout, so its
contents cannot be included.

The default container setup is defined by [`.devcontainer/devcontainer.json`](../.devcontainer/devcontainer.json)
and [`Dockerfile.e2e`](../Dockerfile.e2e): Ubuntu 24.04 system packages, a
Python virtual environment, Node.js 22.x and npm, the Lean toolchain installed
with elan, PyMuPDF 1.28.2 in `/opt/pdf-tools`, npm dependencies for the root and
`e2e/` projects, and Playwright-managed Chromium and Firefox. The devcontainer
post-create step also installs the root project and `src/schematool` and
`src/transform_md` as editable Python packages, builds Signals with Lake, and
installs the listed VS Code extensions. Other Makefile targets install
additional, task-specific tools and dependencies; they are not all part of
container creation.

Each BibTeX note records the declaration source and version constraint. These
are manifest declarations, not resolved versions or proof that a dependency is
present in a particular environment. The catalog does not resolve transitive
dependencies from lockfiles, package registries, or system package indexes;
Ubuntu package entries identify the Noble repository, not a pinned package
revision. Local packages without a declared homepage intentionally have no
registry URL. Re-run the generator after changing manifests to refresh the
catalog.

## Sphinx
- Commands:
  - `sphinx-build --help`

## Lean
- Features:
  - type verification, theorem modeling, theorem proving
  - machine-checkable proofs
- Commands:
  - `lean`
  - `leanc`

### Lean Libraries
#### Mathlib
- Path: `src/Mathlib`

#### Physlib
- Path: `src/Physlib`

#### QECLean
- Path: `src/QECLean`

#### Signals
- Path: `src/signals`

##### numerical_adapter
- Path: `src/signals/numerical_adapter`
- Features
  - Rust-based fluid analysis
    - Verify that Lyapunov exponents predict observed real fluids from JHTDB
  - Rust code produced from src/signals
    - cannon_mask_cad.rs
    - cylinder.rs
    - double_slit.rs
    - jhtdb.rs
    - madelung_lagrangian.rs
    - orbital_splat.rs
    - polariton_spp.rs
    - thermal_inelastic.rs
  - Python code produced from src/signals
    - jhtdb_cutout_probe.py
    - jhtdb_probe.py
    - matlab_piv_probe.py
    - rspid_subset_probe.py
  - WebGL GLSL Shaders produced from src/signals
    - double_slit.frag.glsl
    - double_slit.vert.glsl
    - orbital_splat.frag.glsl
    - orbital_split.vert.glsl

#### Signals blueprint
- Path: `src/signals/blueprint/src/content.tex`

## Lake
- Features
  - package manager for Lean modules
- Commands
  - `lake`

## Lean Blueprint
- Features
  - annotate Lean modules with structured docstrings
- Commands
  - `leanblueprint`

## Lean Architect
- Features
  - build Lean modules with Lean Blueprint annotations into HTML

## schematool
- Features
  - recursively download RDFS and OWL schemas into an on-disk file layout
- Commands
  - `schematool --help`

## transform_md
transform_md parses industrial process descriptions (like [paper.md](paper.md)) and converts them into a structured graph linked data representation
using the **Industrial Ontologies Foundry (IOF)** and sustainablefactory process schema.
[ [schema](schema.md) ]

- **Parser**: Extracts steps, properties, and Mermaid diagrams.
- **RDF Generator**: Produces Turtle-star (`.ttl`) with reified confidence metrics.
- **Visualizer**: Integrated Mermaid diagrams for process flow overview.

- Commands
  - `transform_md --help`



## docindex
- Features
  - YAML toctrees and tagged chat overlays
- Commands
  - `docindex --help`

### toctreeyaml
The `toctreeyaml` directive extends Sphinx's native `toctree` directive with a
Jupyter Book-compatible YAML tree. It reads `_toc.yml` by default, or a file
selected with `:file:`:

````yaml
```{toctreeyaml}
:file: _toc.yml
:maxdepth: 2
```
````

The same attributes can be supplied inline as YAML content. `root`,
`chapters`, nested `sections`, `parts`, `file`, and `title` are supported.

````yaml
```{toctreeyaml}
maxdepth: 2
chapters:
  - file: readme
  - file: schema
    title: Project Schema
```
````

Chat source selection and tag overlays are configured in
`docs/_toc.yml` under `sustainablefactory.chat_sources`. Run `make chat_overlays` to create the `chats__all`
overlay and one `chats/TAG` symlink directory for each source-document tag.
The transformation targets use the all overlay and generate only MyST and
notebook outputs; `docindex` indexes the MyST files.

The optional `sphinxcontrib-webmcp` extension exposes theme-independent tools
for page context, navigation, documentation metadata, and search through
`document.modelContext`. Enable it with `docindex_webmcp_enabled` and configure
the public behavior with `docindex_webmcp`. It emits `webmcp.json` from the
Sphinx build, including navigation and compact doctree metadata. WebMCP remains
inactive in browsers that do not implement the API or that deny the `tools`
permissions policy.

When `docindex_searchtools_enhanced` is enabled, `docs/_templates/search.html`
shows native Sphinx and DocIndex as separate modes. Enable either configured
backend under `docindex_searchtools.docindex`; `oxirs.url` must accept the existing
form-encoded `query` request, and `meilisearch.url` must be reachable from the
browser. Only a Meilisearch public search key may be placed in
`public_api_key`; never put an administrative key in a static documentation
build.

See [Workflow Performance Plan](workflow-performance-plan.md) for the staged
plan to simplify and accelerate the complete transformation, documentation,
and search-index workflow.
