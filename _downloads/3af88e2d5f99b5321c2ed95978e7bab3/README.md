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

The [`src/signals/`](src/signals/README.md) package and its companion Rust/WASM/WebGL2 crate [`src/signals/numerical_adapter/`](src/signals/numerical_adapter/) formalize and test our unified **Complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ / $Gr_{\mathbb{C}}(2,N+2)$** and **Dilatant Dark Fluid (DDF)** mechanics (both without splats and with Normed 2D/3D Anisotropic Tensor Gaussian Splats) across forty-three companion papers in [`docs/`](docs/). Reported error scores are listed below; “not reported” means the roadmap gives no numerical error score for that paper:
1. [Huygens–Steiner Barycentric Coherence, Complex $Gr_{\mathbb{C}}(2,4)$ Plücker Channels, and Multi-Model Double-Slit & OAM Relative Predictive Error in Lean 4](docs/grassmannian-huygens-double-slit-oam-paper.md)
   - **Reported error score:** 0.00% relative error for the complex phase-locked models; positive-real baseline: 50% on-axis and 100% at dark fringes.
2. [Grassmannian Geometry of the Quantum Inverse Scattering Method, Algebraic Bethe Ansatz, and Inverse Scattering Metrology in Lean 4](docs/grassmannian-qism-bethe-ansatz-paper.md)
   - **Reported error score:** Zero residual for valid 3-point Casorati-Wronskian solutions; no empirical prediction-error metric is reported.
3. [Complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ & $N$-ary $Gr_{\mathbb{C}}(2, N+2)$ Unification with Dilatant Dark Fluid (DDF) Moving Sheaths, Plücker Sink Fluxes, Anosov Invariance, and Sorkin Triple-Slit Interferometry in Lean 4](docs/grassmannian-ddf-moving-sheath-paper.md)
   - **Reported error score:** 0% for the complex Grassmannian crossing model; positive-real baseline: 50% on-axis and 100% at dark fringes.
4. [Grassmannian Gravity from QED & Gauge Scattering Amplitudes: Complex $Gr_{\mathbb{C}}(2,4)$ Orbital Precession, Mercury's Perihelion, $N$-Body Dynamics, and Dilatant Dark Fluid (DDF) Unification in Lean 4](docs/grassmannian-gravity-from-qed-scattering-paper.md)
   - **Reported error score:** 0.00% for revised Turner 1PN and 2.5PN models in the stated solar-system and sub-critical regimes; strong-field corrections are conditional.
5. [Normed Tensor Gaussian Splat Mechanics for Complex $Gr_{\mathbb{C}}(2,4)$ Twistors: Advantages, Limitations, WebGL2/WASM Practicality, and Unification Across Double-Slit, QISM, DDF, and Planetary Gravity in Lean 4](docs/grassmannian-splat-mechanics-paper.md)
   - **Reported error score:** No aggregate numerical error score is reported in the roadmap.
6. [Inelastic Scattering and the Heat Problem in Unified Grassmannian–DDF Mechanics: Inverse Compton, Stokes/Anti-Stokes Raman, Fourier vs. Cattaneo–Vernotte, and Subluminal Second-Sound Tensor Splatting in Lean 4](docs/grassmannian-thermal-compton-raman-paper.md)
   - **Reported error score:** No numerical prediction-error score is reported in the roadmap.
7. [Polaritons and Surface Plasmon Polaritons (SPPs) in Unified Grassmannian–DDF Mechanics: Hopfield–Rabi Anticrossing, Lyddane–Sachs–Teller Reststrahlen Bands, $Gr_{\mathbb{C}}(2,4)$ Evanescent Skin-Depth Duality, and Sub-Wavelength Tensor Splatting in Lean 4](docs/grassmannian-polariton-spp-mechanics-paper.md)
   - **Reported error score:** No numerical prediction-error score is reported in the roadmap.
8. [The Holographic Principle in Complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ and Dilatant Dark Fluid (DDF) Mechanics: 't Hooft–Susskind Horizon Entropy, Gauss–Smarr Bulk Mass Recovery, Plücker Redshift Lapse, and Planck Tensor Splatting in Lean 4](docs/grassmannian-holographic-principle-paper.md)
   - **Reported error score:** No numerical prediction-error score is reported in the roadmap.
9. [AdS/CFT Correspondence, Planar Integrability, and Secret Symmetries in Unified Complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ and Dilatant Dark Fluid (DDF) Mechanics: From Maldacena and $\mathfrak{psl}(2|2)_c$ Yangians to Plücker Outer Automorphisms and Holographic RG Tensor Splatting in Lean 4](docs/grassmannian-ads-cft-ddf-paper.md)
   - **Reported error score:** No numerical prediction-error score is reported in the roadmap.
10. [Normed 2D and 3D Tensor Gaussian Splats in Lean 4: Simultaneous Conservation Laws, Holographic $Gr_{\mathbb{C}}(2,4)$ Affine Projection, Inversion-Free Schur–Plücker Calculus, and Multi-Domain Applications](docs/gaussian-splat-tensors-normed-paper.md) ([src/signals/docs/gaussian-splat-tensors-normed-paper.md](src/signals/docs/gaussian-splat-tensors-normed-paper.md))
    - **Reported error score:** No aggregate numerical error score is reported in the roadmap.
11. [Holographic $Gr_{\mathbb{C}}(2,4)$ Depth Recovery and Convergent Multi-Beam Volumetric Imaging: Plücker Axial Variance Inversion, Perspective Range Tomography, and Self-Calibrating Phase Conjugation in Lean 4](docs/grassmannian-holographic-imaging-depth-recovery-paper.md)
    - **Reported error score:** No numerical prediction-error score is reported in the roadmap.
12. [3D Vectorial Wave Model for Longitudinal Polarization ($E_z$) and Higher-Rank $Gr_{\mathbb{C}}(3,n)$ Volumetric Imaging: Debye–Wolf Counter-Polarization, High-NA Dielectric Metasurfaces, ZRI Collimation vs. Thin-Film ENZ-Lignin Boundary Amplification in Lean 4](docs/grassmannian-vectorial-longitudinal-polarization-paper.md)
    - **Reported error score:** No numerical prediction-error score is reported in the roadmap.
13. [Epsilon-Near-Zero (ENZ) and Hyperbolic Metamaterials in Unified Grassmannian–DDF Mechanics: `rGO-polyCBD-SS-Lignin` Nanolaminates, Argon/Ionospheric Trivelpiece–Gould Plasma, Denisov Mode Conversion, and CPA-TNSA $p\text{-}^{11}\text{B}$ / $s\text{CO}_2$ Power Ledgers in Lean 4](docs/grassmannian-enz-hyperbolic-metamaterials-paper.md)
    - **Reported error score:** No numerical prediction-error score is reported in the roadmap.
14. [Holographic $405\text{ nm} / 532\text{ nm}$ Longitudinal Carbon Nanolithography, 6-Stage Linux RISC-V (`CVA6`, `CHERI-CVA6`, & `Ibex`), Volumetric KiCAD/GDSII EDA, and Exothermic Radical-Recombination Physics in Lean 4 and Rust/WASM](docs/grassmannian-riscv-holographic-nanolithography-kicad-paper.md)
    - **Reported error score:** No numerical prediction-error score is reported in the roadmap.
15. [From Superfluid Gross–Pitaevskii Action and Madelung Polar Substitution to Euler–Lagrange Hydrodynamics and Dilatant Dark Fluid (DDF) Jamming Recovery in Complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ Mechanics](docs/grassmannian-madelung-lagrangian-ddf-jamming-paper.md)
    - **Reported error score:** No numerical prediction-error score is reported in the roadmap.
16. [Hawking Radiation, Inverse Gross–Pitaevskii (`iGPE`) Unwinding, and Amplituhedron/CP-ALS Decoding in Complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ and Dilatant Dark Fluid (DDF) Mechanics: With and Without DDF, With and Without Normed Tensor Gaussian Splats in Lean 4](docs/grassmannian-hawking-radiation-decoding-paper.md) ([src/signals/docs/grassmannian-hawking-radiation-decoding-paper.md](src/signals/docs/grassmannian-hawking-radiation-decoding-paper.md))
    - **Reported error score:** No numerical prediction-error score is reported in the roadmap.
17. [Multi-Spectral and Multi-Array Grassmannian Imaging Across Scales: Hubble $2\times$ CCD Mosaics ($\mathrm{Gr}_{\mathbb{R}}(4, N_{\mathrm{pixels}})$ & $\mathrm{Gr}_{\mathbb{R}}(d, \Lambda)$), Cosmic-Ray Particle Telemetry, LVP Medical Direct-Conversion & Proca Phase-Contrast Arrays, LIFU / AOT / TRUE Sub-Surface Optical Focusing, and Sub-Nanometer ($< 1\text{ nm}$) Convergent Holographic Nanolithography in Lean 4 and Rust/WASM](docs/grassmannian-multispectral-hubble-medical-nanoimaging-paper.md) ([src/signals/docs/grassmannian-multispectral-hubble-medical-nanoimaging-paper.md](src/signals/docs/grassmannian-multispectral-hubble-medical-nanoimaging-paper.md))
    - **Reported error score:** No aggregate numerical error score is reported in the roadmap.
18. [Grassmannian Geometry of Quantum Causal Inference, Counterfactual Semantics, Constructor Theory, and the Mpemba / Entropy-Siphoning Laws in Lean 4 and Rust/WASM](docs/grassmannian-quantum-causal-inference-mpemba-paper.md) ([src/signals/docs/grassmannian-quantum-causal-inference-mpemba-paper.md](src/signals/docs/grassmannian-quantum-causal-inference-mpemba-paper.md))
    - **Reported error score:** No numerical prediction-error score is reported in the roadmap.
19. [Complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ Fubini–Study Gross–Pitaevskii Equation, Dual-Schubert `iGPE`, and Homogeneous Plücker Madelung Hydrodynamics on the Klein Quadric $\mathcal{Q}_4$ in Lean 4 and Rust/WASM](docs/grassmannian-complex-gpe-igpe-plucker-madelung-paper.md) ([src/signals/docs/grassmannian-complex-gpe-igpe-plucker-madelung-paper.md](src/signals/docs/grassmannian-complex-gpe-igpe-plucker-madelung-paper.md))
    - **Reported error score:** 0.00% for revised Model 6 and Models 14a/14b in the stated phase-locked, solar-system, and sub-critical regimes; conditional corrections can be nonzero.
20. [Quantum Causal Grassmannian Transformers, JEV vs. $\operatorname{do}$-Calculus Decision Models, Tautological Fiber Bundles, and Spatiotemporal Video Generation in Lean 4 and Rust/WASM](docs/grassmannian-quantum-causal-jev-bundle-transformer-videogen-paper.md) ([src/signals/docs/grassmannian-quantum-causal-jev-bundle-transformer-videogen-paper.md](src/signals/docs/grassmannian-quantum-causal-jev-bundle-transformer-videogen-paper.md))
    - **Reported error score:** No numerical prediction-error score is reported in the roadmap.
21. [Exceeding $6{,}400\times$ Volumetric Efficiency in 3D Normed Tensor Gaussian Splat Nanoimaging, Surgical Medicine, Jeffrey's Kinematic Engine, and Quantum Causal Semantic GraphRAG in Lean 4 and Rust/WASM](docs/grassmannian-quantum-causal-splat-nanoimaging-surgical-graphrag-paper.md) ([src/signals/docs/grassmannian-quantum-causal-splat-nanoimaging-surgical-graphrag-paper.md](src/signals/docs/grassmannian-quantum-causal-splat-nanoimaging-surgical-graphrag-paper.md))
    - **Reported error score:** No numerical prediction-error score is reported in the roadmap.
22. [Unrestricted Spin-Polarized Grassmannian Kohn–Sham Density Functional Theory, Complex Plabic Vector-Relation Configurations (`VRC`), Quantum Causal Inference (`QCI`), and Soliton / Topological Braiding in Lean 4 and Rust/WASM](docs/grassmannian-kohn-sham-dft-complex-plabic-vrc-paper.md)
    - **Reported error score:** No aggregate numerical error score is reported in the roadmap.
23. [Overcoming the Speed–Accuracy Barrier in Quantum Chemistry via Unrestricted Spin-Polarized Grassmannian Kohn–Sham DFT (`QCI-GXC`), Complex Plabic Vector-Relation Configurations (`VRC`), and Polariton / Plasmon / Skyrmion / MZM Non-Destructive Readout in Lean 4 and Rust/WASM](docs/grassmannian-speed-accuracy-barrier-quantum-chemistry-paper.md)
    - **Reported error score:** WTMAD-2 = 1.643 kcal/mol on GMTKN55 (an energy-error metric, not a percentage).
24. [Tuning Materials with Light (Discovered Materials Grand Challenge 04): Time-Linear Grassmannian Generalized Kadanoff–Baym Ansatz (`G-GKBA`) and Coupled Electron–Exciton–Phonon–Bogoliubov Dynamics Across Hubbard Chains/Ladders, $\mathrm{WSe}_2$, Graphite, and $\mathrm{MgB}_2$ in Lean 4, Python, and Rust](docs/grassmannian-tuning-materials-with-light-paper.md) ([docs/tuning-materials-with-light-plan.md](docs/tuning-materials-with-light-plan.md))
    - **Reported error score:** No aggregate prediction-error score is reported in the roadmap; 1.44 × 10^8 is a speedup, not an error score.
25. [Predicting Heat Transport across Solid Interfaces (Discovered Materials Grand Challenge 05): Grassmannian Thermal Boundary Conductance (`G-TBC`), Bond-Stiffness Plücker Transmission, Anharmonic $\mathrm{Gr}_{\mathbb{C}}(2,5)$ Up-Conversion, and Transferable Semiconductor/Carbide/Polymer Benchmarks in Lean 4, Python, and Rust](docs/grassmannian-interfacial-heat-transport-paper.md) ([docs/interfacial-heat-transport-plan.md](docs/interfacial-heat-transport-plan.md))
    - **Reported error score:** 1.17% overall MAPE across 7 datasets.
26. [A Predictive Theory of Cuprate Superconductivity (Discovered Materials Grand Challenge 01): Grassmannian Zhang–Rice Plücker Pairing (`G-CSC`), $d_{x^2-y^2}$ Dome, Pseudogap Fermi Arcs, Planckian Strange Metal, and 12-Target Benchmarks Across $\mathrm{LSCO}$, $\mathrm{Bi2212}$, $\mathrm{YBCO}$, $\mathrm{Tl2201}$, and $\mathrm{Hg1201}$ in Lean 4, Python, and Rust](docs/grassmannian-cuprate-superconductivity-paper.md) ([docs/cuprate-superconductivity-plan.md](docs/cuprate-superconductivity-plan.md))
    - **Reported error score:** 0.79% overall MAPE across 12 targets.
27. [Interfacial Electrical Properties from Processing History (Discovered Materials Grand Challenge 02): Grassmannian Process-to-Electrical Modeling (`G-IEP`), Plabic 3-Flux Deal–Grove Kinetics, McWeeny Dangling-Bond Passivation, and 5-Interface Benchmarks Across Planar $\mathrm{Si/SiO_2}$, Curved $\mathrm{Si}$ Nanowires, $\mathrm{SiC/SiO_2}$, $\mathrm{HfO_2/SiO_2/Si}$, and $\mathrm{Ge/SiGe}$ in Lean 4, Python, and Rust](docs/grassmannian-interfacial-electrical-properties-paper.md) ([docs/interfacial-electrical-properties-plan.md](docs/interfacial-electrical-properties-plan.md))
    - **Reported error score:** 1.20% overall MAPE across 5 interfaces.
28. [Superconductivity, Quantum Anomalous Hall (`QAHE/FQAH`), Supersolid Vortices, and Topological Quantum Computing in Rhombohedral and Moiré Multilayer Graphene (`G-MGS`): Grassmannian $\mathrm{Gr}_{\mathbb{C}}(2,6)$ & $\mathrm{Gr}_{\mathbb{C}}(2,2N)$ Boundary Sublattice Projection, `MATTG` Light–Heavy Kondo Hybridization, and 8-Target Benchmarks Across Trilayer (`RTG`, `MATTG`) and Pentalayer (`R5G`) Graphene in Lean 4, Python, and Rust](docs/grassmannian-rhombohedral-graphene-superconductivity-qc-paper.md) ([src/signals/docs/grassmannian-rhombohedral-graphene-superconductivity-qc-paper.md](src/signals/docs/grassmannian-rhombohedral-graphene-superconductivity-qc-paper.md))
    - **Reported error score:** 0.64% overall MAPE across 8 target families.
29. [Semi-Dirac Fermions (Mass in Only One Direction) With and Without Complex Grassmannian $\mathrm{Gr}_{\mathbb{C}}$ and Dilatant Dark Fluid (DDF) Mechanics: $\mathrm{ZrSiS}$ $B^{2/3}$ Landau Scaling, Dirac-Cone Merging on $\mathrm{Gr}_{\mathbb{C}}(2,4)$ and $\mathrm{Gr}_{\mathbb{C}}(2,6)$, Directional Sheath Jamming, Anisotropic Tensor Splats, and Quantum/Photonic Applications in Lean 4, Rust, and Python](docs/grassmannian-semi-dirac-fermions-ddf-paper.md) ([src/signals/docs/grassmannian-semi-dirac-fermions-ddf-paper.md](src/signals/docs/grassmannian-semi-dirac-fermions-ddf-paper.md))
    - **Reported error score:** 0.50% relative error for the ZrSiS B^(2/3) Landau-level scaling benchmark (Dirac baseline: 28.94%; Schrödinger baseline: 101.01%).
30. [$\mathrm{SU}(4)$ Symmetry, Witten's Twistor String Theory, Lower Grassmannians in $\mathrm{Gr}_{\mathbb{R}}$ and $\mathrm{Gr}_{\mathbb{C}}$, Relative Merits of Cachazo (CSW / BCFW / Hodges / CHY) vs. DDF vs. Turner Models, and Grand Unification with the Holographic Principle and AdS/CFT in Lean 4, Rust, and Python](docs/grassmannian-su4-witten-twistor-string-cachazo-ddf-turner-ads-cft-unification-paper.md) ([src/signals/docs/grassmannian-su4-witten-twistor-string-cachazo-ddf-turner-ads-cft-unification-paper.md](src/signals/docs/grassmannian-su4-witten-twistor-string-cachazo-ddf-turner-ads-cft-unification-paper.md))
    - **Reported error score:** 0% Mercury perihelion error for Cachazo-Skinner and Turner at solar-system scales; Witten conformal-twistor baseline: 100%.
31. [Semi-Dirac Nanoelectronic, Hyperbolic THz Plasmonic, and Orthogonal Thermoelectric Devices in $405\text{ nm} / 532\text{ nm}$ Carbon Nanolithography and Volumetric KiCAD/GDSII EDA: Ballistic Klein Diodes/Transistors, Lithography-Free $400\text{–}800\text{ GHz}$ THz Bolometers, and Cross-Axis $ZT$ Harvesters in Lean 4, Rust/WASM, and Python](docs/grassmannian-semi-dirac-klein-transistor-hyperbolic-thz-thermoelectric-kicad-paper.md) ([src/signals/docs/grassmannian-semi-dirac-klein-transistor-hyperbolic-thz-thermoelectric-kicad-paper.md](src/signals/docs/grassmannian-semi-dirac-klein-transistor-hyperbolic-thz-thermoelectric-kicad-paper.md))
    - **Reported error score:** No numerical prediction-error score is reported in the roadmap; DRC reports 0 cross-analysis findings.
32. [Etch-Free 1D Semi-Dirac Topological Majorana ($\mathrm{MZM}$), $\mathbb{Z}_6$ Parafermion, $\mathrm{Gr}_{\mathbb{C}}(2,6)$ Plücker, and Phase-Steered Helical `N-LIG` OAM Carbon Qudit Waveguides: Varying Phase During Lasing, Zero-RIE $D_{\mathrm{it}}$ Suppression, and Volumetric KiCAD/GDSII Synthesis in Lean 4, Rust/WASM, and Python](docs/grassmannian-semi-dirac-topological-qudit-waveguides-phase-lasing-kicad-paper.md) ([src/signals/docs/grassmannian-semi-dirac-topological-qudit-waveguides-phase-lasing-kicad-paper.md](src/signals/docs/grassmannian-semi-dirac-topological-qudit-waveguides-phase-lasing-kicad-paper.md))
    - **Reported error score:** No numerical prediction-error score is reported in the roadmap; DRC reports 0 findings.
33. [Revised Semi-Dirac and Complex Grassmannian $\mathrm{Gr}_{\mathbb{C}}(2,4)$ / $\mathrm{Gr}_{\mathbb{C}}(2,6)$ Soliton Bus Architecture: Dispersionless $\hat{y}$-Channeling, $C_8$ Star-Via Ancilla Hubs, Slow-Light `N-LIG` CROW Delay Lines, Tiered 128-to-64-Bit RDMA LUT-CORDIC QRAM, $\mathrm{CO}_2$-Carbonate $\chi^{(3)}$ CNOT Gates, and Volumetric KiCAD/GDSII Synthesis in Lean 4, Rust/WASM, and Python](docs/grassmannian-semi-dirac-soliton-bus-crow-rdma-qram-kicad-paper.md) ([src/signals/docs/grassmannian-semi-dirac-soliton-bus-crow-rdma-qram-kicad-paper.md](src/signals/docs/grassmannian-semi-dirac-soliton-bus-crow-rdma-qram-kicad-paper.md))
    - **Reported error score:** No numerical prediction-error score is reported in the roadmap.
34. [Integrated Multi-Band Classical and Quantum Photonics ($405\text{–}1550\text{ nm}$ & $400\text{–}800\text{ GHz}$): Periodic Cellulose Nanocrystal (CNC) $\chi^{(2)}$ Signal Boosters in `N-LIG` Waveguides, Adiabatic Scarf-Joint $c\text{-BAs}$ Plasmonic-Slot Homodyne Detectors, $590\text{ nm}$ $n$-Adamantane NV Purcell Dowsing, and Volumetric KiCAD/GDSII Synthesis in Lean 4, Rust/WASM, and Python](docs/grassmannian-multiband-1550nm-photonics-cnc-repeaters-cbas-homodyne-kicad-paper.md) ([src/signals/docs/grassmannian-multiband-1550nm-photonics-cnc-repeaters-cbas-homodyne-kicad-paper.md](src/signals/docs/grassmannian-multiband-1550nm-photonics-cnc-repeaters-cbas-homodyne-kicad-paper.md))
    - **Reported error score:** No numerical prediction-error score is reported in the roadmap.
35. [Laser-Induced $sp^2/sp^3$ Carbon and Nanodiamonds from Lignin, Plastics (`PET`/`PE`), $\mathrm{CO}_2$, and Methane Pyrolysis ("Teal Carbon"), H-Terminated Nanodiamond 2D Hole Gas (`2DHG`) FETs, and Biodegradable Carbon Semiconductor Alternatives to $590\text{ nm}$ `n-Adamantane` (`P-CQDs`) and `c-BAs` (`Ox-s-CNT` / `VACNT`) in Lean 4, Rust/WASM, Python, and KiCAD v8](docs/grassmannian-nanodiamond-2dhg-biodegradable-carbon-photonics-kicad-paper.md) ([src/signals/docs/grassmannian-nanodiamond-2dhg-biodegradable-carbon-photonics-kicad-paper.md](src/signals/docs/grassmannian-nanodiamond-2dhg-biodegradable-carbon-photonics-kicad-paper.md))
    - **Reported error score:** No numerical prediction-error score is reported in the roadmap.
36. [3D Helical `VortexVia` and 8-Branch `StarVortexVia` Inter-Layer Interconnects, Low-Power Second-Harmonic Resonant Optical Amplification (Dean et al., *Nature* 2025), and 4-Wire Kelvin + Control Barrier Function (`CBF`) Active-Q Modulators (`AQM`) in Lean 4, Rust/WASM, Python, and KiCAD v8](docs/grassmannian-vortex-vias-shg-opa-aqm-nanolithography-kicad-paper.md) ([src/signals/docs/grassmannian-vortex-vias-shg-opa-aqm-nanolithography-kicad-paper.md](src/signals/docs/grassmannian-vortex-vias-shg-opa-aqm-nanolithography-kicad-paper.md))
    - **Reported error score:** No numerical prediction-error score is reported in the roadmap.
37. [Lignolux Holographic Archival Tape (`LHAT`, $12\text{ }\mu\text{m} \times 10\text{ km}$, $720\text{ TB}$ Raw / $480\text{ TB}$ Usable vs. $18\text{ TB}$ LTO-9): $3{,}000\times$ OAM-Bragg-Polarization Volumetric Multiplexing, Zero-Iteration Log-Polar $64\times 64$ FFT Tracking, $182\text{ fs}$ `VACNT` Kapitza Quench, and $635\text{ nm}$ `QFT-RK` Selective Rewritability in Lean 4, Rust/WASM, Python, and KiCAD v8](docs/grassmannian-lhat-holographic-archival-tape-classical-quantum-kicad-paper.md) ([src/signals/docs/grassmannian-lhat-holographic-archival-tape-classical-quantum-kicad-paper.md](src/signals/docs/grassmannian-lhat-holographic-archival-tape-classical-quantum-kicad-paper.md))
    - **Reported error score:** No numerical prediction-error score is reported in the roadmap.
38. [Hosting Pressed / Mask-Locked 1-Trillion-Parameter LLMs on Lignolux Holographic Archival Tape (`LHAT`) with Passive Optical Matrix-Vector Multiplication (`MVM`), Soliton/OAM QRAM, and Active `N-LIG`/`B-LIG` LoRA Steering Layers in Lean 4, Rust/WASM, Python, and KiCAD v8](docs/grassmannian-pressed-llm-holographic-tape-soliton-qram-steering-kicad-paper.md) ([src/signals/docs/grassmannian-pressed-llm-holographic-tape-soliton-qram-steering-kicad-paper.md](src/signals/docs/grassmannian-pressed-llm-holographic-tape-soliton-qram-steering-kicad-paper.md))
    - **Reported error score:** No numerical prediction-error score is reported in the roadmap.
39. [Quantum Causal Next-Concept Modeling (`QCI-NCM`): Coarse-to-Fine Parallel LLM Inference, Multiscale Residual Counterfactuals, Plücker/`VRC` Constraint Coupling, and Pressed-`LHAT` Scale-Selective Steering Hardware in Lean 4, Rust/WASM, and KiCAD v8](docs/grassmannian-quantum-causal-next-concept-modeling-pressed-llm-kicad-paper.md) ([src/signals/docs/grassmannian-quantum-causal-next-concept-modeling-pressed-llm-kicad-paper.md](src/signals/docs/grassmannian-quantum-causal-next-concept-modeling-pressed-llm-kicad-paper.md))
    - **Reported error score:** 99.99% exact token reconstruction on OpenWebText and 100.00% on Sudoku for the NCM multiscale VQ-VAE tokenizer (`arXiv:2610.14162`); DRC reports 0 cross-analysis findings.
40. [`rGO-Vitrimer` Active Metamaterials, Bistable & Elastomeric E-Paper (`Vector Reflect` & `rGO-Bio-TPU`), Chiral `CNC` `Bio-Bragg` Projectors, and Nanodiamond (`SHG` / `NV` / `n-Adamantane` / `P-CQD`) Active Quantum Displays in Lean 4, Rust/WASM, Python, and KiCAD v8](docs/grassmannian-rgo-vitrimer-active-metamaterial-epaper-nanodiamond-displays-kicad-paper.md) ([src/signals/docs/grassmannian-rgo-vitrimer-active-metamaterial-epaper-nanodiamond-displays-kicad-paper.md](src/signals/docs/grassmannian-rgo-vitrimer-active-metamaterial-epaper-nanodiamond-displays-kicad-paper.md))
    - **Reported error score:** 0.00% Pauli-blocked interband absorption loss ($\alpha = 0$ for $2E_F > \hbar\omega$), 0.1% speckle contrast ($C^2 = 10^{-6}$ at $100\text{ MHz}$), and 99.8% mask fidelity; DRC reports 0 cross-analysis findings.
41. [Lignolux Omni-Carbon Kinetic Batteries (`Al-LGBPC`, Dual-Ion `Iodine`, & `Na-Ion` Hard Carbon), `Q-Node` Quinone Pseudocapacitors, Semi-Dirac Quantum Capacitance, `QCI-GXC` Kohn–Sham DFT Passivation, and Biodegradable / Closed-Loop Recyclable Electrical Components in Lean 4, Rust/WASM, Python, and KiCAD v8](docs/grassmannian-omni-carbon-kinetic-batteries-supercapacitors-dft-biodegradable-components-kicad-paper.md) ([src/signals/docs/grassmannian-omni-carbon-kinetic-batteries-supercapacitors-dft-biodegradable-components-kicad-paper.md](src/signals/docs/grassmannian-omni-carbon-kinetic-batteries-supercapacitors-dft-biodegradable-components-kicad-paper.md))
    - **Reported error score:** 0.00 V PEM electrolyzer voltage mismatch, < 1% McWeeny-passivated self-discharge leakage factor ($3402/625000 \approx 0.54\%$), and $10^{-13} < 10^{-12}\text{ cm}^2/\text{s}$ polyiodide shuttle diffusivity; DRC reports 0 cross-analysis findings.
42. [Plasma-Fluffed Chitosan–Alginate–Magnesium Hemostatic Gauze & `VEGF` Wound Sprays, `Sprout-Zero` Biodegradable Diapers, `Aero-Fleece` Thermal Liners, `CAM` Struvite Geotextiles, and Graphene-Susceptor `FJH` Quartzite Argon Plasma Tubes in Lean 4, Rust/WASM, Python, and KiCAD v8](docs/grassmannian-plasma-fluffed-gauze-diapers-fleece-geotextiles-quartzite-kicad-paper.md) ([src/signals/docs/grassmannian-plasma-fluffed-gauze-diapers-fleece-geotextiles-quartzite-kicad-paper.md](src/signals/docs/grassmannian-plasma-fluffed-gauze-diapers-fleece-geotextiles-quartzite-kicad-paper.md))
    - **Reported error score:** 0.00 charge-neutrality residual in `PEC` coacervation, exact physiological $\mathrm{pH} = 7.4$ bimodal $\mathrm{Mg}$ buffering, and $92\%$ fused-quartz optical transmittance; DRC reports 0 cross-analysis findings.
43. [Layer-Coded Plabic Graphs, Complex Vector-Relation Configurations (`VRC`), and Unrestricted Grassmannian Quantum Chemistry (`QCI-GXC`) in `MADNESS` Multiwavelet `MRA-PNO` and `Tequila` for Computational Advantage](docs/grassmannian-madness-tequila-quantum-chemistry-plabic-vrc-paper.md) ([src/signals/docs/grassmannian-madness-tequila-quantum-chemistry-plabic-vrc-paper.md](src/signals/docs/grassmannian-madness-tequila-quantum-chemistry-plabic-vrc-paper.md))
    - **Reported error score:** 0.00 residual on 4-stage Plabic/LGV-to-Complex-VRC relations ($V K^\top = 0$) across the $x_X = -1$ resonance, $< 10^{-12}$ unitary and idempotency error in PySCF-free Cayley–McWeeny orbital optimization ($9\times\text{–}144\times$ speedup), and $10{,}000\times\text{–}810{,}000\times$ 4-index $g$-tensor compression in `MADNESS` `MRA-PNO`.
44. [A Rust/PyO3 (`maturin`) Quantum Simulation Backend for `Tequila`: Complex Grassmannians $\mathrm{Gr}_{\mathbb{C}}(k, n)$, Layer-Coded Plabic Vector-Relation Configurations (`VRC`), Madelung/DDF Hydrodynamics, and Quantum Causal Inference (`QCI`) in Lean 4, Rust, and Python](docs/grassmannian-tequila-rust-pyo3-quantum-simulator-paper.md) ([src/signals/docs/grassmannian-tequila-rust-pyo3-quantum-simulator-paper.md](src/signals/docs/grassmannian-tequila-rust-pyo3-quantum-simulator-paper.md))
    - **Reported error score:** $< 10^{-14}$ expectation and wavefunction discrepancy vs. Tequila's reference symbolic backend, 0.00 imaginary drift on Hermitian Pauli expectations, $2.2\times\text{–}61.7\times$ speedup over `qulacs` on dense $2^n$ circuits up to $n = 28$ ($4.00\text{ GiB}$), and $68{,}253\times$ speedup on particle-conserving `HCB-SPA` circuits scaling up to $n = 126$ qubits ($1.82\text{ ms}$).
