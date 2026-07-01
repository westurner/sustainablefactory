# docindex-core

Reusable search indexing and SPARQL query library for Sustainable Factory.

## Features

- **Multi-Backend Search Architecture**: Supports both `oxirs` (RDF/SPARQL using local pyoxigraph or remote endpoints) and `milli` (Meilisearch) search backends.
- **Simultaneous Multi-Indexing**: Broadcasts index updates, creation, and document inserts to multiple search backends simultaneously, while querying from a primary database client.
- **Zero-Gap Atomic Updates**: Implements staging index schemas and atomic swaps (`swap_indexes`) to ensure search remains uninterrupted during re-indexing operations.
- **Robust Parsers**: High-performance Markdown/HTML sections parsers for document indexing.

## Configuration & Backends

The indexer can be configured with one or more search backends:
- **`oxirs` (Default)**: Leverages RDF/SPARQL. Uses an in-memory/on-disk `pyoxigraph` store by default, or connects to a remote SPARQL HTTP service.
- **`milli`**: Connects to a Meilisearch search instance.

To configure multiple backends simultaneously, specify a comma-separated list of backends (e.g., `oxirs,milli`).

## Installation

```bash
pip install -e ./src/docindex-core
```

## Usage

```python
from docindex_core import DocumentIndexer
from docindex_core.config import DocIndexConfig

# Initialize the indexer with the default backend (oxirs)
config = DocIndexConfig(
    backend="oxirs",
    storage_path="./data/oxirs_store"
)
indexer = DocumentIndexer(config=config)

# Indexing HTML pages
stats = indexer.index_sphinx_html("./docs/_build/html")
print(f"Indexed {stats.indexed_documents} documents.")

# Searching documents
results = indexer.client.search("all", "carbon footprint")
for result in results:
    print(result.title, result.url)
```

## Running Tests with 100% Coverage

```bash
pytest --cov=docindex_core --cov-report=term-missing tests/
```
