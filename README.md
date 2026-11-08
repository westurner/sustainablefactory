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

The [`src/signals/`](src/signals/README.md) package and its companion Rust/WASM/WebGL2 crate [`src/signals/numerical_adapter/`](src/signals/numerical_adapter/) formalize and test our unified **Complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ / $Gr_{\mathbb{C}}(2,N+2)$** and **Dilatant Dark Fluid (DDF)** mechanics (both without splats and with Normed 2D/3D Anisotropic Tensor Gaussian Splats) across twenty-three companion papers in [`docs/`](docs/):
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
11. [Normed 2D and 3D Tensor Gaussian Splats in Lean 4: Simultaneous Conservation Laws, Holographic $Gr_{\mathbb{C}}(2,4)$ Affine Projection, Inversion-Free Schur–Plücker Calculus, and Multi-Domain Applications](docs/gaussian-splat-tensors-normed-paper.md) ([src/signals/docs/gaussian-splat-tensors-normed-paper.md](src/signals/docs/gaussian-splat-tensors-normed-paper.md))
12. [Holographic $Gr_{\mathbb{C}}(2,4)$ Depth Recovery and Convergent Multi-Beam Volumetric Imaging: Plücker Axial Variance Inversion, Perspective Range Tomography, and Self-Calibrating Phase Conjugation in Lean 4](docs/grassmannian-holographic-imaging-depth-recovery-paper.md)
13. [3D Vectorial Wave Model for Longitudinal Polarization ($E_z$) and Higher-Rank $Gr_{\mathbb{C}}(3,n)$ Volumetric Imaging: Debye–Wolf Counter-Polarization, High-NA Dielectric Metasurfaces, ZRI Collimation vs. Thin-Film ENZ-Lignin Boundary Amplification in Lean 4](docs/grassmannian-vectorial-longitudinal-polarization-paper.md)
14. [Epsilon-Near-Zero (ENZ) and Hyperbolic Metamaterials in Unified Grassmannian–DDF Mechanics: `rGO-polyCBD-SS-Lignin` Nanolaminates, Argon/Ionospheric Trivelpiece–Gould Plasma, Denisov Mode Conversion, and CPA-TNSA $p\text{-}^{11}\text{B}$ / $s\text{CO}_2$ Power Ledgers in Lean 4](docs/grassmannian-enz-hyperbolic-metamaterials-paper.md)
15. [Holographic $405\text{ nm} / 532\text{ nm}$ Longitudinal Carbon Nanolithography, 6-Stage Linux RISC-V (`CVA6`, `CHERI-CVA6`, & `Ibex`), Volumetric KiCAD/GDSII EDA, and Exothermic Radical-Recombination Physics in Lean 4 and Rust/WASM](docs/grassmannian-riscv-holographic-nanolithography-kicad-paper.md)
16. [From Superfluid Gross–Pitaevskii Action and Madelung Polar Substitution to Euler–Lagrange Hydrodynamics and Dilatant Dark Fluid (DDF) Jamming Recovery in Complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ Mechanics](docs/grassmannian-madelung-lagrangian-ddf-jamming-paper.md)
17. [Hawking Radiation, Inverse Gross–Pitaevskii (`iGPE`) Unwinding, and Amplituhedron/CP-ALS Decoding in Complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ and Dilatant Dark Fluid (DDF) Mechanics: With and Without DDF, With and Without Normed Tensor Gaussian Splats in Lean 4](docs/grassmannian-hawking-radiation-decoding-paper.md) ([src/signals/docs/grassmannian-hawking-radiation-decoding-paper.md](src/signals/docs/grassmannian-hawking-radiation-decoding-paper.md))
18. [Multi-Spectral and Multi-Array Grassmannian Imaging Across Scales: Hubble $2\times$ CCD Mosaics ($\mathrm{Gr}_{\mathbb{R}}(4, N_{\mathrm{pixels}})$ & $\mathrm{Gr}_{\mathbb{R}}(d, \Lambda)$), Cosmic-Ray Particle Telemetry, LVP Medical Direct-Conversion & Proca Phase-Contrast Arrays, LIFU / AOT / TRUE Sub-Surface Optical Focusing, and Sub-Nanometer ($< 1\text{ nm}$) Convergent Holographic Nanolithography in Lean 4 and Rust/WASM](docs/grassmannian-multispectral-hubble-medical-nanoimaging-paper.md) ([src/signals/docs/grassmannian-multispectral-hubble-medical-nanoimaging-paper.md](src/signals/docs/grassmannian-multispectral-hubble-medical-nanoimaging-paper.md))
19. [Grassmannian Quantum Causal Inference, Counterfactual Semantics, Indefinite Causal Order, Constructor Theory, and Landau vs. Quantum Mpemba / Entropy-Siphoning Laws in Lean 4 and Rust/WASM](docs/grassmannian-quantum-causal-inference-mpemba-paper.md) ([src/signals/docs/grassmannian-quantum-causal-inference-mpemba-paper.md](src/signals/docs/grassmannian-quantum-causal-inference-mpemba-paper.md))
20. [Complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ Fubini–Study Gross–Pitaevskii Equation, Dual-Schubert `iGPE`, Homogeneous Plücker $\mathcal{Q}_4$ Madelung Hydrodynamics, and Revised Superposition, Gravity, & Gravitational-Wave Models in Lean 4 and Rust/WASM](docs/grassmannian-complex-gpe-igpe-plucker-madelung-paper.md) ([src/signals/docs/grassmannian-complex-gpe-igpe-plucker-madelung-paper.md](src/signals/docs/grassmannian-complex-gpe-igpe-plucker-madelung-paper.md))
21. [Quantum Causal Grassmannian Transformers, JEV vs. $\operatorname{do}$-Calculus Decision Models, Tautological Fiber Bundles, and Linear-in-Volume Spatiotemporal VideoGen in Lean 4 and Rust/WASM](docs/grassmannian-quantum-causal-jev-bundle-transformer-videogen-paper.md) ([src/signals/docs/grassmannian-quantum-causal-jev-bundle-transformer-videogen-paper.md](src/signals/docs/grassmannian-quantum-causal-jev-bundle-transformer-videogen-paper.md))
22. [Beyond $6{,}400\times$ Volumetric Efficiency: Splat-Sparse Grassmannian Nanoimaging, Surgical Medicine, Jeffrey's Kinematic Engine, and Quantum Causal Semantic GraphRAG in Lean 4 and Rust/WASM](docs/grassmannian-quantum-causal-splat-nanoimaging-surgical-graphrag-paper.md) ([src/signals/docs/grassmannian-quantum-causal-splat-nanoimaging-surgical-graphrag-paper.md](src/signals/docs/grassmannian-quantum-causal-splat-nanoimaging-surgical-graphrag-paper.md))
23. [Unrestricted Spin-Polarized Grassmannian Kohn–Sham DFT (`QCI-GXC`), Complex Plabic Vector-Relation Configurations (`VRC`), and Overcoming the Speed–Accuracy Barrier in Quantum Chemistry (Full 55-Subset Two-Electron ERI `WTMAD-2 = 1.643 kcal/mol`, `ALD/CVD`, $144\times$ Cayley & $192\times$ `RI-J` Speedups, and Polariton/Plasmon/Skyrmion/MZM Non-Destructive Readout)](docs/grassmannian-speed-accuracy-barrier-quantum-chemistry-paper.md) ([docs/grassmannian-kohn-sham-dft-complex-plabic-vrc-paper.md](docs/grassmannian-kohn-sham-dft-complex-plabic-vrc-paper.md))
24. [Tuning Materials with Light (Discovered Materials Grand Challenge 04): Time-Linear Grassmannian Generalized Kadanoff–Baym Ansatz (`G-GKBA`) and Coupled Electron–Exciton–Phonon–Bogoliubov Dynamics Across Hubbard Chains/Ladders, $\mathrm{WSe}_2$, Graphite, and $\mathrm{MgB}_2$ in Lean 4, Python, and Rust](docs/grassmannian-tuning-materials-with-light-paper.md) ([docs/tuning-materials-with-light-plan.md](docs/tuning-materials-with-light-plan.md))
25. [Predicting Heat Transport across Solid Interfaces (Discovered Materials Grand Challenge 05): Grassmannian Thermal Boundary Conductance (`G-TBC`), Bond-Stiffness Plücker Transmission, Anharmonic $\mathrm{Gr}_{\mathbb{C}}(2,5)$ Up-Conversion, and Transferable Semiconductor/Carbide/Polymer Benchmarks in Lean 4, Python, and Rust](docs/grassmannian-interfacial-heat-transport-paper.md) ([docs/interfacial-heat-transport-plan.md](docs/interfacial-heat-transport-plan.md))
26. [A Predictive Theory of Cuprate Superconductivity (Discovered Materials Grand Challenge 01): Grassmannian Zhang–Rice Plücker Pairing (`G-CSC`), $d_{x^2-y^2}$ Dome, Pseudogap Fermi Arcs, Planckian Strange Metal, and 12-Target Benchmarks Across $\mathrm{LSCO}$, $\mathrm{Bi2212}$, $\mathrm{YBCO}$, $\mathrm{Tl2201}$, and $\mathrm{Hg1201}$ in Lean 4, Python, and Rust](docs/grassmannian-cuprate-superconductivity-paper.md) ([docs/cuprate-superconductivity-plan.md](docs/cuprate-superconductivity-plan.md))
27. [Interfacial Electrical Properties from Processing History (Discovered Materials Grand Challenge 02): Grassmannian Process-to-Electrical Modeling (`G-IEP`), Plabic 3-Flux Deal–Grove Kinetics, McWeeny Dangling-Bond Passivation, and 5-Interface Benchmarks Across Planar $\mathrm{Si/SiO_2}$, Curved $\mathrm{Si}$ Nanowires, $\mathrm{SiC/SiO_2}$, $\mathrm{HfO_2/SiO_2/Si}$, and $\mathrm{Ge/SiGe}$ in Lean 4, Python, and Rust](docs/grassmannian-interfacial-electrical-properties-paper.md) ([docs/interfacial-electrical-properties-plan.md](docs/interfacial-electrical-properties-plan.md))
28. [Superconductivity, Quantum Anomalous Hall Effects, and Topological Quantum Computing in Trilayer and Pentalayer Rhombohedral & Moiré Graphene: Grassmannian Boundary Sublattice Projection (`G-MGS`), Light–Heavy Kondo Hybridization, Fubini–Study Optical Sum Rules, $C = \pm 5$ QAHE, $C = 1$ Anomalous Hall Crystals, and Supersolid Quantum Vortices in Lean 4, Python, and Rust](docs/grassmannian-rhombohedral-graphene-superconductivity-qc-paper.md) ([docs/rhombohedral-graphene-superconductivity-plan.md](docs/rhombohedral-graphene-superconductivity-plan.md))
