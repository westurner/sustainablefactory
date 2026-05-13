# Sustainable Factory

Modeling sustainable factory processes with Linked Data and MyST Markdown.

## Overview
This project parses industrial process descriptions (stored as MyST Markdown and JSON chat exports) and converts them into a structured graph linked data representation using the [Industrial Ontologies Foundry (IOF)](https://spec.industrialontologies.org/) core schema.

## Features
- **MyST Markdown & JSON Parser**: Extracts process steps, properties, equipment, materials, cost figures, metrics, and source citations.
- **RDF-star Generation**: Exports to Turtle-star format with reified metadata (`.ttl`).
- **Mermaid Integration**: Visualizes process flows directly from documentation.
- **Sphinx Documentation**: High-quality HTML output with integrated diagrams.

## Installation

Prerequisites: Python 3.11+.

```bash
# Install the package and its dependencies in editable mode
pip install -e .
```

## CLI Reference (`sfcli`)

The project provides the `sfcli` tool line for data extraction and conversion:

- **Parse a file**: Read a Markdown or JSON file to verify parsed processes to the console.
  ```bash
  sfcli parse <input_file>
  ```
- **Export to RDF-star**: Parse a file and export the output as a `.ttl` script.
  ```bash
  sfcli export_rdf <input_file> --output process_data.ttl
  ```
- **Batch Export**: Batch process an entire directory of MyST and JSON files into a consolidated graph representation.
  ```bash
  sfcli batch_export data/chats/ --output all_processes.ttl
  ```
- **Info**: Display package version information.
  ```bash
  sfcli info
  ```

## Directory Structure

Here is a brief overview of the top-level directories in this workspace:

- **`data/`**: Raw input data, including interactive chat exports (Markdown and JSON) describing sustainable processes.
- **`docs/`**: Sphinx documentation source files, configuration, and generated HTML builds.
- **`schema/`**: Foundational Industrial Ontologies Foundry (IOF) RDF schemas, ontologies, and the core `sustainable-factory.ttl` schema.
- **`src/`**: Supplementary source code utilities like `schematool` and `transform_md`.
- **`sustainablefactory/`**: The core Python package providing parsing logic, knowledge graph generation, and RDF extraction features.
- **`tests/`**: Unit testing suite using `pytest`.
- **`tools/`**: Standalone helper scripts, such as data aggregation utilities and RDF-to-Mermaid conversions.

## Development Tasks

A `Makefile` is included to streamline common tasks:

- `make test` / `make pytest`: Run unit tests and generate a coverage report.
- `make build`: Perform full pipeline generation (aggregates data, transforms markdown to docs, and builds HTML pages).
- `make docs`: Builds HTML documentation using Sphinx and MyST-parser.
- `make aggregate_data`: Runs data aggregation tools to process technical features.
- `make serve`: Serves the documentation using a local Python HTTP server.
