# sustainablefactory - Agent Specialization Guide

This document defines specialized agents and their purposes for working with the sustainablefactory project. Use these agent descriptions to guide your work on specific tasks.

---

## Core Project Agents

### 1. **Schema & Ontology Agent**
**Purpose**: Manage RDF schemas, ontologies, and linked data representations.

**Expertise**:
- Working with Industrial Ontologies Foundry (IOF) RDF schemas
- Managing the `schema/` directory and `sustainable-factory.ttl` core schema
- Running `schematool` CLI to sync external RDF schemas
- Understanding Turtle, Turtle-star, and RDF-star formats
- Validating ontology structure and coverage

**Key Commands**:
```bash
schematool --help
make update_schemadir
```

**Related Files**:
- `src/schematool/` — RDF schema sync utility
- `schema/` — IOF and foundational ontologies
- `schema/sustainable-factory.ttl` — Core project schema
- `sustainablefactory/rdf_gen.py` — RDF-star generation logic

**Typical Tasks**:
- Update and synchronize external RDF schemas
- Validate or extend the core ontology
- Review RDF-star output for graph consistency
- Document schema changes in `docs/schema.md`

---

### 2. **Data Processing & Parsing Agent**
**Purpose**: Parse input documents and extract structured data for knowledge graph generation.

**Expertise**:
- Parsing MyST Markdown files with process descriptions
- Processing JSON chat exports from AI assistants
- Extracting process steps, equipment, materials, costs, metrics, and citations
- Understanding the data extraction pipeline in `sustainablefactory/parser.py`
- Working with multiple input formats and normalizing them

**Key Commands**:
```bash
sfcli parse <input_file>
sfcli export_rdf <input_file> --output process_data.ttl
sfcli batch_export data/chats/ --output all_processes.ttl
```

**Related Files**:
- `sustainablefactory/parser.py` — Core parsing logic
- `sustainablefactory/cli.py` — CLI interface for parsing
- `data/chats/` — Input chat exports (MD and JSON)
- `sustainablefactory/rdf_gen.py` — RDF generation after parsing
- `tests/test_parser.py` — Parser unit tests

**Typical Tasks**:
- Parse new markdown or JSON documents to extract processes
- Debug parsing issues or missing entity detection
- Extend parser to handle new document structures
- Batch process directories of input files
- Validate extracted data before RDF export

---

### 3. **Markdown Transformation & Notebook Sync Agent**
**Purpose**: Normalize, transform, and synchronize markdown files with Jupyter Notebooks.

**Expertise**:
- Using `transform_md` to clean up AI-generated chat exports
- Converting between multiple markdown dialects (Standard, MyST, Quarto)
- Two-way synchronization between `.md` and `.ipynb` files
- Handling chat splitting, code fence normalization, and mermaid conversion
- Extending the transform registry with custom formats
- Managing metadata and kernelspecs in notebooks

**Key Commands**:
```bash
transform-md --indir data/chatoverlay/chats__all/ --outdir docs/chats/ \
  --transform-cell-split m1 --out-format=myst,ipynb,chatexport_abc1
transform-md --help
make transform_md_all
```

**Related Files**:
- `src/transform_md/` — Markdown transformation utility
- `src/transform_md/transform_md/transform_md.py` — Core implementation
- `data/chats/` — Input markdown chat exports
- `data/chatoverlay/chats__all/` — Organized chat overlay directory
- `docs/chats/` — Output transformed markdown and notebooks
- `tests/test_*.py` (in transform_md) — Transform tests

**Typical Tasks**:
- Transform chat exports from AI to clean markdown or notebooks
- Register new markdown formats or extensions
- Implement custom cell templates for specialized formats
- Debug transformation issues in chat splitting or fence normalization
- Synchronize notebook changes back to markdown

---

### 4. **Documentation & Build Agent**
**Purpose**: Build, generate, and maintain project documentation.

**Expertise**:
- Building Sphinx documentation with MyST parser and Mermaid diagrams
- Generating HTML output and managing `_build/` directory
- Understanding `conf.py` and documentation configuration
- Integrating data aggregation into the build pipeline
- Managing documentation workflow and deployment

**Key Commands**:
```bash
make docs
make build  # Full pipeline: aggregate_data → transform_md_all → docs
make serve
```

**Related Files**:
- `docs/` — Sphinx documentation source
- `docs/conf.py` — Sphinx configuration
- `docs/index.md` — Main documentation index
- `docs/schema.md` — Schema documentation
- `docs/_build/html/` — Generated HTML output
- `Makefile` — Build orchestration

**Typical Tasks**:
- Build HTML documentation locally
- Fix documentation build errors or warnings
- Add or update MyST markdown documentation files
- Integrate new sections or data into docs
- Deploy or serve built documentation

---

### 5. **End-to-End Testing & CI/CD Agent**
**Purpose**: Manage Playwright e2e tests, containerization, and CI workflows.

**Expertise**:
- Running Playwright browser automation tests locally or in containers
- Using Podman for containerized test environments
- Understanding `e2etest.sh` test runner and its options
- Managing test configurations in `e2e/playwright.config.ts`
- Working with GitHub Actions workflows in `.github/workflows/`

**Key Commands**:
```bash
./e2etest.sh --help
./e2etest.sh --on-host          # Run tests on local host
./e2etest.sh --in-container     # Run tests in Podman container
./e2etest.sh --install          # Install Playwright browsers
```

**Related Files**:
- `e2etest.sh` — End-to-end test runner script
- `e2e/` — Playwright test suite directory
- `e2e/playwright.config.ts` — Playwright configuration
- `e2e/tests/` — Test specs
- `.github/workflows/` — CI/CD workflow definitions
- `Dockerfile.e2e` — Container image for e2e tests

**Typical Tasks**:
- Run e2e tests locally or in containers
- Debug test failures
- Add new test cases
- Update Playwright configuration
- Manage CI workflows and status checks

---

### 6. **Data Aggregation & Metrics Agent**
**Purpose**: Process and aggregate technical data from documents into structured formats.

**Expertise**:
- Using `tools/aggregate_technical_data.py` to extract and aggregate data
- Processing extracted metrics and cost figures
- Managing output formats (JSON, TTL, other serializations)
- Integrating aggregation into the build pipeline

**Key Commands**:
```bash
python3 tools/aggregate_technical_data.py
make aggregate_data
```

**Related Files**:
- `tools/aggregate_technical_data.py` — Data aggregation script
- `tools/` — Supporting utility scripts
- `schema_inventory.json` — Output schema inventory
- `schema_inventory_full.json` — Full schema inventory

**Typical Tasks**:
- Run aggregation to collect technical metrics
- Debug aggregation issues or missing data
- Extend aggregation logic for new data types
- Integrate aggregation outputs into documentation or RDF

---

## Cross-Agent Workflows

### Full Build Pipeline
```
data/chats/ → parser → RDF-star → documentation → HTML output
       ↓
    transform-md → docs/chats/ (markdown + notebooks)
```

**Agent Sequence**: Data Processing → Markdown Transformation → Documentation & Build

### Chat Export Processing
```
Raw AI chat exports (JSON/MD) → transform_md cleanup → docs/chats/ output
                             → parse → RDF export → Knowledge graph
```

**Agent Sequence**: Markdown Transformation → Data Processing → Schema & Ontology

### Documentation Regeneration
```
make build → aggregate_data + transform_md_all + docs → HTML
```

**Agent Sequence**: Data Aggregation → Markdown Transformation → Documentation & Build

---

## Development Workflow

### Running Tests
```bash
make test                    # Run pytest with coverage
pytest --cov=. --cov-report=term-missing .
```

### Local Development Cycle
1. **Data Processing Agent**: Parse and validate input files
2. **Markdown Transformation Agent**: Clean and transform exports
3. **Data Aggregation Agent**: Extract technical metrics
4. **Documentation Agent**: Build HTML output
5. **E2E Testing Agent**: Validate in browser

### Continuous Integration
- GitHub Actions workflows orchestrate the build pipeline
- E2E tests run in containerized Podman environments
- Check `.github/workflows/` for deployment configurations

---

## Key Dependencies & Tools

| Tool | Agent | Purpose |
|------|-------|---------|
| `sfcli` | Data Processing | CLI for parsing and RDF export |
| `schematool` | Schema & Ontology | Sync RDF schemas |
| `transform-md` | Markdown Transformation | Markdown normalization and notebook sync |
| `sphinx` + `myst-parser` | Documentation | Build Sphinx docs from MyST markdown |
| `pytest` | All | Unit testing framework |
| `playwright` | E2E Testing | Browser automation |
| `podman` | E2E Testing | Container runtime for tests |

---

## Getting Started with Each Agent

**New to the project?** Start with the **Data Processing Agent** to understand the input → output pipeline.

**Working on schemas?** Use the **Schema & Ontology Agent** to manage ontology changes.

**Cleaning up documentation?** Use the **Markdown Transformation Agent** to transform exports.

**Building for production?** Coordinate **Markdown Transformation** → **Data Aggregation** → **Documentation** agents for the full pipeline.

**Testing changes?** Use the **E2E Testing Agent** to validate in real browsers.

---

## Questions & Support

For specific task categorization or clarification, refer to the relevant agent's **Typical Tasks** section.
For multi-step workflows involving multiple agents, follow the **Cross-Agent Workflows** guide.
