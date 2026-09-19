# Sustainable Factory Documentation

Welcome to the Sustainable Factory project documentation.

```{toctree}
:hidden:

search
```

{doc}`Search <search>`

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
- **RDF Generator**: Produces Turtle RDF (`.ttl`) with reified confidence metrics.
- **Visualizer**: Integrated Mermaid diagrams for process flow overview.

## `sustainablefactory` research

- Source chats
  - `data/chats/*.{md,json}`
- Quantum computing
  - [Sustainable Quantum architecture](paper.myst.md)
  - [Soliton bus model](soliton-bus.md): finite multiplexing, routing, and
    operator contracts with chat-derived evidence boundaries.
- [Chat physics catalog](chat-physics-catalog.md): applications, processes,
	products, evidence status, and prioritized Signals-model update candidates.

- See {ref}`readme`
