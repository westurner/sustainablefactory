
## transform_md
transform_md parses industrial process descriptions (like [paper.myst.md](paper.myst.md)) and converts them into a structured graph linked data representation
using the **Industrial Ontologies Foundry (IOF)** and sustainablefactory process schema.
[ [schema](schema.md) ]

- **Parser**: Extracts steps, properties, and Mermaid diagrams.
- **RDF Generator**: Produces Turtle-star (`.ttl`) with reified confidence metrics.
- **Visualizer**: Integrated Mermaid diagrams for process flow overview.

## YAML toctrees and tagged chat overlays

The `toctreeyaml` directive extends Sphinx's native `toctree` directive with a
Jupyter Book-compatible YAML tree. It reads `_toc.yml` by default, or a file
selected with `:file:`:

```{toctreeyaml}
:file: _toc.yml
:maxdepth: 2
```

The same attributes can be supplied inline as YAML content. `root`,
`chapters`, nested `sections`, `parts`, `file`, and `title` are supported.

```{toctreeyaml}
maxdepth: 2
chapters:
  - file: readme
  - file: schema
    title: Project Schema
```

Chat source selection and tag overlays are configured in
`docs/_toc.yml` under `sustainablefactory.chat_sources`. Run `make chat_overlays` to create the `chats__all`
overlay and one `chats/TAG` symlink directory for each source-document tag.
The transformation targets use the all overlay and generate only MyST and
notebook outputs; `docindex` indexes the MyST files.

See [Workflow Performance Plan](workflow-performance-plan.md) for the staged
plan to simplify and accelerate the complete transformation, documentation,
and search-index workflow.
