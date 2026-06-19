# docindex-core

Reusable Meilisearch indexing/search core library.

## Includes

- Document and config models
- Meilisearch client wrapper
- Chat parser
- HTML parser
- Index coordinator

## Install

```bash
pip install docindex-core
```

## Use

```python
from docindex_core import DocumentIndexer, MeilisearchConfig

indexer = DocumentIndexer(MeilisearchConfig(host="localhost", port=7700))
```
