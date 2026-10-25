# Sustainable Factory

Modeling sustainable factory processes with Linked Data and MyST Markdown.

## Overview
This project parses industrial process descriptions (stored as MyST Markdown and JSON chat exports) and converts them into a structured graph linked data representation using the [Industrial Ontologies Foundry (IOF)](https://spec.industrialontologies.org/) core schema.

## Research and Evidence Workflow

Chat-derived physics and engineering work follows an explicit evidence
boundary. Use the [research evidence triage skill](.agents/skills/research-evidence-triage/SKILL.md)
to search and cite source chats, then use the [Signals evidence modeling skill](.agents/skills/signals-evidence-modeling/SKILL.md)
to decide whether a result belongs in verified Lean Signals, `Signals.Pending`,
the process/RDF catalog, or an exclusions list. The [chat physics catalog](docs/chat-physics-catalog.md)
shows the current applications, processes, products, evidence status, and
recommended model updates. See [AGENTS.md](AGENTS.md) for project-wide
boundaries and validation commands.

## Features
- **MyST Markdown & JSON Parser**: Extracts process steps, properties, equipment, materials, cost figures, metrics, and source citations.
- **Linked Data**
  - RDFS
  - ValueFlows (VF), Industrial Ontologies Foundry (IOF),
    Elementary Multiperspective Material Ontology (EMMO)
  - `schematool` (`src/schematool`) generates a directory of precedent RDFS schema in `schema/`
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
- **Export to RDF**: Parse a file and export the output as a `.ttl` script.
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

## Search Indexing (`docindex`)

The project includes an indexer and search library (`docindex`) under `src/` to index sphinx documentation and chat logs:
- **Default backend**: `oxirs` (RDF/SPARQL using `pyoxigraph` store).
- **Supported backends**: `oxirs`, `milli` (Meilisearch).
- **Multi-backend**: Index to both backends simultaneously using `--backend oxirs,milli`.

Usage examples:
```bash
# Index chats using default OxiRS backend
docindex index-chats --source data/chats/

# Index Sphinx HTML atomically
docindex index-html --source docs/_build/html --backend oxirs,milli
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
- `make signals_build`: Builds the Lean 4 `Signals`, `SignalsTests`, `SignalsPending`, and `SignalsPendingTests` targets in [`src/signals/`](src/signals/README.md).

## Formal Verification & Simulation (`src/signals/`)

The [`src/signals/`](src/signals/README.md) package and its companion Rust/WASM/WebGL2 crate [`src/signals/numerical_adapter/`](src/signals/numerical_adapter/) formalize and test our unified **Complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ / $Gr_{\mathbb{C}}(2,N+2)$** and **Dilatant Dark Fluid (DDF)** mechanics (both without splats and with Normed 2D Anisotropic Tensor Gaussian Splats) across nine companion papers in [`docs/`](docs/):
1. [Huygens–Steiner Barycentric Coherence, Complex $Gr_{\mathbb{C}}(2,4)$ Plücker Channels, and Multi-Model Double-Slit & OAM Relative Predictive Error in Lean 4](docs/grassmannian-huygens-double-slit-oam-paper.md)
2. [Grassmannian Geometry of the Quantum Inverse Scattering Method, Algebraic Bethe Ansatz, and Inverse Scattering Metrology in Lean 4](docs/grassmannian-qism-bethe-ansatz-paper.md)
3. [Complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ & $N$-ary $Gr_{\mathbb{C}}(2, N+2)$ Unification with Dilatant Dark Fluid (DDF) Moving Sheaths, Plücker Sink Fluxes, Anosov Invariance, and Sorkin Triple-Slit Interferometry in Lean 4](docs/grassmannian-ddf-moving-sheath-paper.md)
4. [Grassmannian Gravity from QED & Gauge Scattering Amplitudes: Complex $Gr_{\mathbb{C}}(2,4)$ Orbital Precession, Mercury's Perihelion, $N$-Body Dynamics, and Dilatant Dark Fluid (DDF) Unification in Lean 4](docs/grassmannian-gravity-from-qed-scattering-paper.md)
5. [Normed Tensor Gaussian Splat Mechanics for Complex $Gr_{\mathbb{C}}(2,4)$ Twistors: Advantages, Limitations, WebGL2/WASM Practicality, and Unification Across Double-Slit, QISM, DDF, and Planetary Gravity in Lean 4](docs/grassmannian-splat-mechanics-paper.md)
6. [Inelastic Scattering and the Heat Problem in Unified Grassmannian–DDF Mechanics: Inverse Compton, Stokes/Anti-Stokes Raman, Fourier vs. Cattaneo–Vernotte, and Subluminal Second-Sound Tensor Splatting in Lean 4](docs/grassmannian-thermal-compton-raman-paper.md)
7. [Polaritons and Surface Plasmon Polaritons (SPPs) in Unified Grassmannian–DDF Mechanics: Hopfield–Rabi Anticrossing, Lyddane–Sachs–Teller Reststrahlen Bands, $Gr_{\mathbb{C}}(2,4)$ Evanescent Skin-Depth Duality, and Sub-Wavelength Tensor Splatting in Lean 4](docs/grassmannian-polariton-spp-mechanics-paper.md)
8. [The Holographic Principle in Complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ and Dilatant Dark Fluid (DDF) Mechanics: 't Hooft–Susskind Horizon Entropy, Gauss–Smarr Bulk Mass Recovery, Plücker Redshift Lapse, and Planck Tensor Splatting in Lean 4](docs/grassmannian-holographic-principle-paper.md)
9. [AdS/CFT Correspondence, Planar Integrability, and Secret Symmetries in Unified Complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ and Dilatant Dark Fluid (DDF) Mechanics: From Maldacena and $\mathfrak{psl}(2|2)_c$ Yangians to Plücker Outer Automorphisms and Holographic RG Tensor Splatting in Lean 4](docs/grassmannian-ads-cft-ddf-paper.md)
10. [Unification, Engineering Applications, and Research Roadmap of Complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ and Dilatant Dark Fluid (DDF) Mechanics: Cross-Domain Plücker Invariants, Photonic–Thermal–Quantum Systems, and Formal Verification in Lean 4](docs/grassmannian-unification-applications-roadmap-paper.md)
