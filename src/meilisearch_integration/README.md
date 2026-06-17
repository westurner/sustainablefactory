# Meilisearch Integration for Sphinx Documentation

A complete search infrastructure for indexing and searching Sphinx documentation, chat exports, and MyST markdown files using Meilisearch.

## Features

- **Multi-source indexing**: Index chat exports (JSON/Markdown), Sphinx HTML, and MyST markdown
- **Full-text search**: Fast, relevant search results with filtering and sorting
- **CLI tools**: Command-line interface for index management and search
- **Sphinx integration**: Automatic indexing via Sphinx build hooks
- **Batch processing**: Efficient batch indexing with progress tracking
- **Docker support**: Fedora-based container with Meilisearch pre-installed
- **Change tracking**: Skip re-indexing unchanged files

## Quick Start

### 1. Build the Docker Image

```bash
make meilisearch_build
```

### 2. Start Meilisearch

```bash
make meilisearch_start
```

### 3. Index Your Documentation

**Index chat exports:**
```bash
make meilisearch_index_chats
```

**Index Sphinx HTML:**
```bash
make meilisearch_index_html
```

**Index everything:**
```bash
make meilisearch_index_all
```

### 4. Search

```bash
make meilisearch_search
# Then enter your query when prompted
```

### 5. Check Status

```bash
make meilisearch_status
```

## Installation

### Prerequisites

- Python 3.10+
- Podman or Docker
- Sphinx 7.0+

### Install Python Dependencies

```bash
pip install -r requirements-meilisearch.txt
```

Or in development mode:

```bash
pip install meilisearch sphinx-pagefind pydantic click python-dotenv
```

## Architecture

### Core Components

```
src/meilisearch_integration/
├── config.py            # Configuration, schemas, models
├── api.py               # Meilisearch client wrapper
├── indexer.py           # Main indexing coordinator
├── chat_parser.py       # Chat export parsing
├── html_parser.py       # Sphinx HTML parsing
├── hooks.py             # Sphinx event integration
└── cli.py               # Command-line interface
```

### Document Types

1. **Chat Documents** (`type: "chat"`)
   - Source: `docs/chats/*.json` or `docs/chats/*.myst.md`
   - Strategy: Split by conversation turns or sections
   - Metadata: Chat type (gemini, copilot, etc.), role, turn number

2. **Sphinx Documents** (`type: "sphinx"`)
   - Source: `docs/_build/html/`
   - Strategy: Extract by heading levels (1-3 by default)
   - Metadata: Heading level, breadcrumb, URL path

3. **MyST Markdown** (`type: "myst"`)
   - Source: `docs/*.myst.md`, `docs/chats/*.myst.md`
   - Strategy: Index entire file or split by sections
   - Metadata: Frontmatter, file path, modification time

## Usage

### Command-Line Interface

```bash
# Index chat files
python3 -m sustainablefactory.meilisearch_integration.cli index-chats \
  --source docs/chats \
  --batch-size 1000

# Index Sphinx HTML
python3 -m sustainablefactory.meilisearch_integration.cli index-html \
  --source docs/_build/html \
  --headings 1-3

# Search
python3 -m sustainablefactory.meilisearch_integration.cli search \
  --query "lignin vitrimer" \
  --index all \
  --limit 20

# Show status
python3 -m sustainablefactory.meilisearch_integration.cli status

# List indices
python3 -m sustainablefactory.meilisearch_integration.cli list-indices

# Clear an index
python3 -m sustainablefactory.meilisearch_integration.cli clear-index \
  --index chats \
  --confirm

# Delete an index
python3 -m sustainablefactory.meilisearch_integration.cli delete-index \
  --index myst \
  --confirm
```

### Python API

```python
from sustainablefactory.meilisearch_integration import DocumentIndexer, MeilisearchConfig
from pathlib import Path

# Create indexer
config = MeilisearchConfig(host='localhost', port=7700)
indexer = DocumentIndexer(config)

# Index chat exports
stats = indexer.index_chat_directory(Path('docs/chats'))
print(f"Indexed {stats.indexed_documents} documents")

# Index Sphinx HTML
stats = indexer.index_sphinx_html(Path('docs/_build/html'))

# Get index status
status = indexer.get_index_status()
print(status)
```

### Search API

```python
from sustainablefactory.meilisearch_integration import MeilisearchClient

client = MeilisearchClient()
results = client.search(
    index_name='all',
    query='carbon nanotube',
    limit=20,
    filters="type = 'chat'"
)

for result in results:
    print(f"{result.title} ({result.relevance_score})")
    print(f"  {result.content_snippet}...")
```

## Configuration

### Environment Variables

```bash
# Meilisearch connection
export MEILISEARCH_HOST=localhost
export MEILISEARCH_PORT=7700
export MEILISEARCH_API_KEY=your-api-key

# Indexing
export MEILISEARCH_BATCH_SIZE=1000
export MEILISEARCH_ENABLED=true
```

### Sphinx Integration (docs/conf.py)

```python
# Enable automatic Meilisearch indexing after builds
extensions = [
    'sustainablefactory.meilisearch_integration.hooks',
    # ... other extensions
]

# Optional: Configure Meilisearch settings
meilisearch_enabled = True
meilisearch_host = 'localhost'
meilisearch_port = 7700
```

## Makefile Targets

| Target | Description |
|--------|-------------|
| `meilisearch_build` | Build Docker image |
| `meilisearch_start` | Start Meilisearch container |
| `meilisearch_stop` | Stop Meilisearch container |
| `meilisearch_index_chats` | Index chat exports |
| `meilisearch_index_html` | Index Sphinx HTML |
| `meilisearch_index_all` | Index all sources |
| `meilisearch_status` | Show index status |
| `meilisearch_search` | Interactive search |
| `build_with_search` | Build docs and index |

## Docker Deployment

### Build the Image

```bash
podman build -f Dockerfile.meilisearch -t sustainablefactory-meilisearch:latest
```

### Run the Container

```bash
# Development (single instance)
podman run -it \
  -p 7700:7700 \
  -p 8000:8000 \
  -v $(pwd):/workspace \
  -e MEILI_MASTER_KEY=dev-key \
  sustainablefactory-meilisearch:latest

# Production (background)
podman run -d \
  -p 7700:7700 \
  -v meilisearch-data:/meilisearch-data \
  -e MEILI_MASTER_KEY=prod-key \
  sustainablefactory-meilisearch:latest
```

### Run Commands in Container

```bash
# Index chats
podman exec meilisearch-dev python3 -m sustainablefactory.meilisearch_integration.cli \
  index-chats --source docs/chats

# Check status
podman exec meilisearch-dev python3 -m sustainablefactory.meilisearch_integration.cli \
  status
```

## Performance Optimization

### Batch Indexing

Documents are indexed in batches (default 1000) to avoid hitting Meilisearch limits:

```bash
python3 -m sustainablefactory.meilisearch_integration.cli index-chats \
  --source docs/chats \
  --batch-size 5000  # Larger batches for faster indexing
```

### Selective Heading Levels

Extract only important heading levels to reduce document count:

```bash
python3 -m sustainablefactory.meilisearch_integration.cli index-html \
  --source docs/_build/html \
  --headings 1-2  # Only H1-H2
```

### Index Settings

Meilisearch is configured with optimized settings for your document types:

- **Searchable attributes**: title, content, summary, concepts
- **Filterable attributes**: type, date_indexed, filename
- **Sortable attributes**: date_indexed
- **Synonyms**: Common technical term variations

## Search UI Integration

### Sphinx-Pagefind

For a static-site search solution without a running server:

```python
# docs/conf.py
extensions = ['sphinx_pagefind']

sphinx_pagefind_excluded_extensions = ['.pdf']
sphinx_pagefind_root_selector = 'div.main-content'
```

### Custom JSON API

Query Meilisearch directly from a web frontend:

```html
<script>
const API_URL = 'http://localhost:7700';

async function search(query) {
  const response = await fetch(`${API_URL}/indexes/all/search`, {
    method: 'POST',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify({q: query, limit: 20})
  });
  return await response.json();
}

// Usage
search('lignin vitrimer').then(results => {
  results.hits.forEach(hit => {
    console.log(hit.title, hit.content);
  });
});
</script>
```

## Examples

### Index and Search in One Command

```bash
make meilisearch_index_all && make meilisearch_search
```

### Build Docs with Full Search

```bash
make build_with_search
```

### Rebuild Index After Changes

```bash
make meilisearch_status              # Check current state
make meilisearch_index_chats         # Index only chats
make meilisearch_index_html          # Index only HTML
```

### Custom Search Filter

Search only chat exports:

```bash
python3 -m sustainablefactory.meilisearch_integration.cli search \
  --query "carbon" \
  --index chats \
  --limit 50
```

## Troubleshooting

### Meilisearch Connection Failed

```bash
# Check if container is running
podman ps | grep meilisearch

# Check logs
podman logs meilisearch-dev

# Restart container
make meilisearch_stop
make meilisearch_start
```

### No Documents Indexed

```bash
# Check status
make meilisearch_status

# Debug with verbose output
LOGLEVEL=DEBUG python3 -m sustainablefactory.meilisearch_integration.cli \
  index-chats --source docs/chats
```

### Slow Indexing

- Increase batch size: `--batch-size 5000`
- Use SSD storage for Meilisearch data
- Run indexing on a faster machine
- Index only specific heading levels

### Search Returns No Results

1. Verify documents were indexed: `make meilisearch_status`
2. Check query syntax in Meilisearch documentation
3. Try a simpler query (e.g., single word)
4. Check document content: `make meilisearch_search`

## Development

### Run Tests

```bash
pytest tests/ -k meilisearch -v
```

### Add Custom Parsers

```python
from sustainablefactory.meilisearch_integration.config import Document, DocumentType, DocumentMetadata

class CustomParser:
    @staticmethod
    def parse(filepath):
        """Parse custom file format."""
        return [
            Document(
                id="custom_1",
                type=DocumentType.CHAT,
                title="...",
                content="...",
                filename=filepath.name,
                metadata=DocumentMetadata(source_file=str(filepath))
            )
        ]
```

### Extend Index Settings

```python
from sustainablefactory.meilisearch_integration.config import IndexSettings

settings = IndexSettings(
    searchable_attributes=[...],
    synonyms={
        "your_term": ["alternative", "variant"]
    }
)
```

## References

- [Meilisearch Documentation](https://docs.meilisearch.com/)
- [Sphinx Events API](https://www.sphinx-doc.org/en/master/extdev/appapi.html#event-api)
- [Sphinx-Pagefind](https://github.com/lelouch77/sphinx-pagefind)
- [Full Architecture Document](../sphinx-meilisearch-architecture.md)

## License

Same as sustainablefactory project

## Contributing

See [CONTRIBUTING.md](../../CONTRIBUTING.md) for guidelines.

## Support

For issues or questions:
1. Check [Troubleshooting](#troubleshooting) section
2. Review [Meilisearch Documentation](https://docs.meilisearch.com/)
3. Open an issue in the repository

---

**Last Updated**: 2026-06-17
