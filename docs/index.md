# Sustainable Factory Documentation

Welcome to the Sustainable Factory project documentation.


## Sustainable Factory Project
```{toctreeyaml}
:maxdepth: 3
:caption: Table of Contents:
:file: _toc.yml
```
- {ref}`tables_and_figures`

## `sustainablefactory` Software
This project uses MyST Markdown and JSON to capture and model sustainable process and product information and generates RDF linked data.

This system parses industrial process descriptions (like [paper.myst.md](paper.myst.md)) and converts them into a structured graph linked data representation
using the **Industrial Ontologies Foundry (IOF)** and sustainablefactory process schema.
[ [schema](schema.md) ]

- **Parser**: Extracts steps, properties, and Mermaid diagrams.
- **RDF Generator**: Produces Turtle-star (`.ttl`) with reified confidence metrics.
- **Visualizer**: Integrated Mermaid diagrams for process flow overview.

- See {ref}`readme`
