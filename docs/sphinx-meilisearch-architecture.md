# Sphinx-Meilisearch Integration Architecture

## Overview

This document outlines the architecture for integrating Meilisearch full-text search with Sphinx documentation, enabling efficient indexing of chat exports, processed markdown, and HTML documentation.

---

## 1. System Architecture

### 1.1 Components

```
┌─────────────────────────────────────────────────────────────┐
│                    Data Processing Pipeline                 │
└─────────────────────────────────────────────────────────────┘
         ↓
    data/chats/          ──→  transform-md  ──→  docs/chats/
    (.md, .json)                                  (.myst.md, .ipynb)
         ↓                                               ↓
    sphinx/              ──→  docs/_build/html/        │
    .rst, .md                                          ↓
         ↓                                          ┌──────────────────┐
         └──────────────────────→  Meilisearch  ←─┤  Indexer Module  │
                                  (Port 7700)     └──────────────────┘
                                       ↓
                              ┌────────────────────┐
                              │  Search UI / API   │
                              │  (sphinx-pagefind  │
                              │   or custom)       │
                              └────────────────────┘
```

### 1.2 Key Integration Points

1. **Document Sources**: Chat exports (JSON/Markdown), Sphinx-built HTML, MyST markdown
2. **Indexing Strategy**:
   - Index raw chats by segments
   - Index HTML build output by sections
   - Index source markdown for development
3. **Index Management**:
   - Track file modifications with inode/hash
   - Rebuild on `make html` via hooks
   - Batch operations for performance
4. **Search UI**:
   - Sphinx-pagefind for static site search
   - JSON API for programmatic access
   - Snippet highlighting and relevance ranking
  - Native Sphinx search and optional DocIndex search are separate modes;
    configure the enhanced UI with `docindex_searchtools_enhanced` and
    `docindex_searchtools` in `docs/conf.py`.
   - `sphinxcontrib.webmcp` exposes the same public search modes, navigation,
     page context, and compact doctree metadata through `document.modelContext`.

---

## 2. File Structure

```
sustainablefactory/
├── Dockerfile.meilisearch          # Fedora toolbox container
├── requirements-meilisearch.txt    # Python dependencies
├── src/
│   └── meilisearch_integration/   # New module
│       ├── __init__.py
│       ├── config.py               # Configuration and schemas
│       ├── indexer.py              # Core indexing logic
│       ├── chat_parser.py          # Chat extraction module
│       ├── html_parser.py          # HTML section parser
│       ├── hooks.py                # Sphinx/Make hooks
│       ├── api.py                  # Meilisearch API wrapper
│       └── cli.py                  # CLI commands
├── docs/
│   └── search-config.json          # Search UI configuration
├── Makefile                        # Updated with meilisearch targets
├── pyproject.toml                  # Updated with search dependencies
└── .env.meilisearch               # Configuration (local only)
```

---

## 3. Data Model & Indexing Strategy

### 3.1 Document Structure in Meilisearch

Each indexed document represents a **searchable unit** (can vary by source):

```typescript
// Chat document (from docs/chats/)
{
  id: string                        // Unique identifier: "chat_<filename>_<segment>"
  type: "chat"
  title: string                     // Chat title from metadata
  filename: string                  // Original filename
  segment_index: number             // Segment number within chat
  content: string                   // Text content (max 100KB per document)
  summary: string                   // Optional AI-generated summary
  metadata: {
    source_file: string
    chat_type: "gemini" | "copilot" | "custom"
    tags: string[]
    date_indexed: ISO8601
    concepts: string[]              // Extracted entities/concepts
  }
  relevance_score: number           // Set during search
}

// Sphinx HTML document (from docs/_build/html/)
{
  id: string                        // "html_<page_path>_<section_id>"
  type: "sphinx"
  title: string                     // Page/section title
  url: string                       // Relative URL path
  path: string                      // File path in _build/html/
  section_title: string             // Heading text
  content: string                   // HTML converted to text
  code_snippets: CodeSnippet[]      // Extracted code blocks
  metadata: {
    source_file: string
    heading_level: number           // 1-6
    breadcrumb: string[]
    last_built: ISO8601
    sphinx_role: string             // e.g., "doc", "ref", "py:class"
  }
}

// MyST Markdown document (from docs/chats/)
{
  id: string                        // "myst_<filename>"
  type: "myst"
  title: string
  filename: string
  content: string
  frontmatter: Record<string, any>
  metadata: {
    source_file: string
    last_modified: ISO8601
    word_count: number
  }
}
```

### 3.2 Indexing Strategy

#### Source 1: Chat Exports (JSON/Markdown)

**Input**: `data/chats/*.json` or `docs/chats/*.myst.md`
**Strategy**: Split by conversation turns or sections
**Frequency**: On-demand or via `make meilisearch_index_chats`

```python
# Pseudocode: chat_parser.py
for chat_file in docs/chats:
    if file_extension == '.json':
        turns = parse_json_turns(file)
        documents = [
            Document(
                id=f"chat_{stem}_{i}",
                type="chat",
                content=turn["content"],
                metadata={"turn": i, "role": turn["role"]}
            )
            for i, turn in enumerate(turns)
        ]
    elif file_extension == '.myst.md':
        sections = split_by_markdown_headings(file)
        documents = [
            Document(
                id=f"chat_{stem}_{i}",
                type="chat",
                content=section,
                title=extract_heading(section)
            )
            for i, section in enumerate(sections)
        ]
    meilisearch.add_documents(documents)
```

#### Source 2: Sphinx HTML Output

**Input**: `docs/_build/html/`
**Strategy**: Parse HTML, extract sections by heading levels
**Frequency**: Automatic after `make html` (via hook)

```python
# Pseudocode: html_parser.py
for html_file in docs/_build/html:
    if html_file.endswith('.html'):
        sections = extract_sections_from_html(html_file)
        documents = [
            Document(
                id=f"html_{page_id}_{section_id}",
                type="sphinx",
                title=section["title"],
                content=section["text"],
                url=section["url"],
                metadata={
                    "heading_level": section["level"],
                    "breadcrumb": section["breadcrumb"]
                }
            )
            for section_id, section in enumerate(sections)
        ]
        meilisearch.add_documents(documents)
```

#### Source 3: MyST Markdown Source Files

**Input**: `docs/*.myst.md`, `docs/chats/*.myst.md`
**Strategy**: Index entire file + extract sections
**Frequency**: On-demand via `make meilisearch_index_myst`

---

## 4. Hook System (Django-Haystack Style)

### 4.1 Sphinx Build Hooks

Integrate with Sphinx's event system to auto-index on document changes:

```python
# sustainablefactory/src/meilisearch_integration/hooks.py

# Hook into Sphinx config
def setup(app):
    """Register Sphinx event handlers for Meilisearch indexing."""
    app.connect("config-inited", on_config_inited)
    app.connect("build-finished", on_build_finished)
    app.connect("env-updated", on_env_updated)

def on_config_inited(app, config):
    """Initialize Meilisearch client on Sphinx startup."""
    config.meilisearch_enabled = True
    config.meilisearch_host = os.getenv("MEILISEARCH_HOST", "localhost")
    config.meilisearch_port = int(os.getenv("MEILISEARCH_PORT", 7700))
    config.meilisearch_api_key = os.getenv("MEILISEARCH_API_KEY")

def on_build_finished(app, exception):
    """Index HTML documents after build completion."""
    if exception or not app.config.meilisearch_enabled:
        return

    logger.info("Indexing Sphinx HTML output to Meilisearch...")
    indexer = SphinxHTMLIndexer(
        host=app.config.meilisearch_host,
        port=app.config.meilisearch_port
    )
    indexer.index_html_build(app.outdir)

def on_env_updated(app, env):
    """Track document changes for selective re-indexing."""
    # Get list of updated files from Sphinx environment
    changed_files = env.get_updated_docs()
    logger.debug(f"Updated docs: {changed_files}")
```

### 4.2 Make Targets with Hooks

```makefile
# Makefile additions

.PHONY: meilisearch_start
meilisearch_start:
	@echo "meilisearch_start  #  Start Meilisearch server"
	podman run -d -p 7700:7700 -e MEILI_MASTER_KEY=dev-key \
		--name meilisearch-dev \
		sustainablefactory-meilisearch:latest

.PHONY: meilisearch_stop
meilisearch_stop:
	@echo "meilisearch_stop  #  Stop Meilisearch server"
	podman stop meilisearch-dev || true
	podman rm meilisearch-dev || true

.PHONY: meilisearch_index_chats
meilisearch_index_chats:
	@echo "meilisearch_index_chats  #  Index chat exports to Meilisearch"
	python3 -m sustainablefactory.meilisearch_integration.cli index-chats --source docs/chats

.PHONY: meilisearch_index_html
meilisearch_index_html:
	@echo "meilisearch_index_html  #  Index Sphinx HTML to Meilisearch"
	python3 -m sustainablefactory.meilisearch_integration.cli index-html --source docs/_build/html

.PHONY: meilisearch_index_all
meilisearch_index_all: meilisearch_index_chats meilisearch_index_html
	@echo "meilisearch_index_all  #  Index all sources"

.PHONY: build_with_search
build_with_search: build meilisearch_index_html
	@echo "build_with_search  #  Build docs and index to Meilisearch"
```

### 4.3 File Change Tracking

Use file hashing to avoid re-indexing unchanged documents:

```python
# sustainablefactory/src/meilisearch_integration/cache.py

import json
import hashlib
from pathlib import Path
from typing import Dict

class IndexCache:
    """Track file hashes to detect changes."""

    def __init__(self, cache_file: Path = Path(".meilisearch_cache")):
        self.cache_file = cache_file
        self.hashes = self._load_cache()

    def _load_cache(self) -> Dict[str, str]:
        if self.cache_file.exists():
            return json.loads(self.cache_file.read_text())
        return {}

    def save_cache(self):
        self.cache_file.write_text(json.dumps(self.hashes, indent=2))

    def file_changed(self, filepath: Path) -> bool:
        """Check if file has been modified since last index."""
        new_hash = hashlib.md5(filepath.read_bytes()).hexdigest()
        old_hash = self.hashes.get(str(filepath))

        if new_hash != old_hash:
            self.hashes[str(filepath)] = new_hash
            return True
        return False

    def get_changed_files(self, directory: Path) -> list[Path]:
        """Get list of changed files in directory."""
        return [
            f for f in directory.rglob("*")
            if f.is_file() and self.file_changed(f)
        ]
```

---

## 5. CLI Interface

```bash
# Index chat exports
$ python3 -m sustainablefactory.meilisearch_integration.cli index-chats \
  --source docs/chats \
  --batch-size 100 \
  --skip-unchanged

# Index Sphinx HTML
$ python3 -m sustainablefactory.meilisearch_integration.cli index-html \
  --source docs/_build/html \
  --headings 1-3 \
  --exclude-pages "genindex,search,modindex"

# Manage indices
$ python3 -m sustainablefactory.meilisearch_integration.cli list-indices

# Clear index
$ python3 -m sustainablefactory.meilisearch_integration.cli clear-index \
  --index chats --confirm

# Search (testing)
$ python3 -m sustainablefactory.meilisearch_integration.cli search \
  --query "lignin vitrimer" \
  --index all \
  --limit 10

# Status
$ python3 -m sustainablefactory.meilisearch_integration.cli status
```

---

## 6. Search UI Integration

### 6.1 Sphinx-Pagefind

[Sphinx-Pagefind](https://github.com/lelouch77/sphinx-pagefind) provides static site search without requiring a server.

**Configuration** (`docs/conf.py`):

```python
extensions = [
    'sphinx_pagefind',
]

sphinx_pagefind_excluded_extensions = ['.pdf', '.zip']
sphinx_pagefind_root_selector = 'div.main-content'
```

### 6.2 Custom JSON API Search UI

Lightweight HTML/JS interface querying Meilisearch directly:

```html
<!-- docs/_static/meilisearch-search.html -->
<div id="meilisearch-search">
  <input type="text" id="search-input" placeholder="Search docs and chats...">
  <div id="search-results"></div>
</div>

<script>
const MEILISEARCH_HOST = 'http://localhost:7700';
const searchInput = document.getElementById('search-input');
const resultsDiv = document.getElementById('search-results');

searchInput.addEventListener('input', async (e) => {
  const query = e.target.value;
  if (query.length < 2) return;

  try {
    const response = await fetch(`${MEILISEARCH_HOST}/indexes/all/search`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ q: query, limit: 20 })
    });
    const data = await response.json();
    displayResults(data.hits);
  } catch (error) {
    console.error('Search error:', error);
  }
});

function displayResults(hits) {
  resultsDiv.innerHTML = hits.map(hit => `
    <div class="search-result">
      <h3><a href="${hit.url || '#'}">${hit.title}</a></h3>
      <p>${hit.content.substring(0, 150)}...</p>
    </div>
  `).join('');
}
</script>
```

---

## 7. Performance Considerations

### 7.1 Batch Indexing

```python
# Batch documents to avoid hitting Meilisearch limits
BATCH_SIZE = 1000

def index_documents_batched(documents: List[Document]):
    for i in range(0, len(documents), BATCH_SIZE):
        batch = documents[i:i+BATCH_SIZE]
        client.index('all').add_documents(batch)
        logger.info(f"Indexed batch {i//BATCH_SIZE + 1}")
```

### 7.2 Selective Re-indexing

- Track file hashes to skip unchanged files
- Use Meilisearch's `updateDocuments` for modifications only
- Implement incremental indexing for large builds

### 7.3 Index Management

```python
# Meilisearch settings for optimal search
settings = {
    "searchableAttributes": [
        "title",
        "content",
        "summary",
        "concepts"
    ],
    "filterableAttributes": [
        "type",
        "date_indexed",
        "filename"
    ],
    "sortableAttributes": [
        "date_indexed"
    ],
    "synonyms": {
        "lignin": ["kraft lignin", "kraft-lignin", "lig"],
        "vitrimer": ["vitrimer polymer", "vitrimeric"],
    }
}
```

---

## 8. Integration with Build Pipeline

### 8.1 Extended Makefile

```makefile
.PHONY: build
build: aggregate_data transform_md_all docs meilisearch_index_html
	@echo "build  #  Full build pipeline with search indexing"

.PHONY: rebuild_index
rebuild_index:
	@echo "rebuild_index  #  Force full re-index of all sources"
	python3 -m sustainablefactory.meilisearch_integration.cli \
		clear-index --index all --confirm
	$(MAKE) meilisearch_index_all
```

### 8.2 CI/CD Considerations

- Index builds in CI to pre-populate production Meilisearch
- Store index data in persistent volume for containerized deployments
- Export/import indices for multi-environment consistency

---

## 9. Deployment Scenarios

### 9.1 Local Development

```bash
# Start Meilisearch
make meilisearch_start

# Build docs and index
make build_with_search

# Serve with search
make serve
```

### 9.2 Container (Podman)

```bash
# Build container
podman build -f Dockerfile.meilisearch -t sustainablefactory-search:latest

# Run with volumes
podman run -d \
  -p 7700:7700 -p 8000:8000 \
  -v $(pwd):/workspace \
  -e MEILISEARCH_MASTER_KEY=prod-key \
  sustainablefactory-search:latest
```

### 9.3 Production

- Run Meilisearch as a separate service
- Use persistent storage for indices
- Implement authentication/rate limiting
- Cache search results at CDN layer

---

## 10. Future Enhancements

1. **GraphRAG Integration**: Use Meilisearch as vector store for graph-based retrieval
2. **Semantic Search**: Add embedding-based search using sentence-transformers
3. **Analytics**: Track popular searches, query patterns
4. **Auto-suggestions**: Implement query completion with entity extraction
5. **Faceted Search**: Enable filtering by document type, date, concepts
6. **Multi-language Support**: Lemmatization and language-specific analyzers

---

## References

- [Meilisearch Documentation](https://docs.meilisearch.com/)
- [Sphinx-Pagefind](https://github.com/lelouch77/sphinx-pagefind)
- [Django-Haystack (Hook System Reference)](https://django-haystack.readthedocs.io/)
- [Sphinx Events](https://www.sphinx-doc.org/en/master/extdev/appapi.html#event-api)
