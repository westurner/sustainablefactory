---
title: "Plan Index: Research, Validation, and Implementation Roadmaps"
description: "Central index and routing matrix for all physics validation plans, Lean 4 formalization roadmaps, Rust/WASM numerical adapter specifications, and documentation/indexing performance plans."
---

(plan-index)=
# Plan Index: Research, Validation, and Implementation Roadmaps

This document indexes the nine project plan and specification documents across [`docs/`](index.md) and [`src/signals/`](../src/signals/README.md), and maps how each component of the [Complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ and Dilatant Dark Fluid (DDF) Unification](grassmannian-unification-applications-roadmap-paper.md) routes to its owning reference paper and implementation plan.

---

## 1. Routing Matrix: What Belongs in Reference Papers vs. Existing Plan Documents

| Content / Capability from the Unification | Where It Belongs in Reference / Paper Docs | Which Existing Plan Document Owns the Next Steps |
|---|---|---|
| **Master 9-Domain $Gr_{\mathbb{C}}(2,4)$ Plücker Dictionary & Synthesis** | [grassmannian-unification-applications-roadmap-paper.md](grassmannian-unification-applications-roadmap-paper.md), [README.md](../README.md#L84-L98), [src/signals/README.md](../src/signals/README.md#L186-L246) | [huygens-grassmannian-amplituhedron-plan.md](huygens-grassmannian-amplituhedron-plan.md#L1538-L1650) (Iterations 24–33 & Synthesis section) |
| **3D Fresnel-to-Fraunhofer Remainder, Higher-Rank $Gr_{\mathbb{C}}(k,n)$ ($k \ge 3$), & LGV Disjoint-Path Positivity** | [grassmannian-huygens-double-slit-oam-paper.md](grassmannian-huygens-double-slit-oam-paper.md), [src/signals/Signals/Geometry.lean](../src/signals/Signals/Geometry.lean), [src/signals/Signals/Plabic.lean](../src/signals/Signals/Plabic.lean) | [huygens-grassmannian-amplituhedron-plan.md](huygens-grassmannian-amplituhedron-plan.md#L1445-L1745) (Iteration 33 & Phase 2, Phase 3, and Phase 6 Acceptance Obligations) |
| **$\chi^{(2)}$ SHG-OPA Squeezing (`opaSqueezedTensorSplat`), Dispersive QND Readout, & Soliton-Bus QEC** | [grassmannian-polariton-spp-mechanics-paper.md](grassmannian-polariton-spp-mechanics-paper.md), [soliton-bus.md](soliton-bus.md), [anti-fire-cannon-review.md](anti-fire-cannon-review.md) | [dispersive-homodyne-plan.md](dispersive-homodyne-plan.md#L24-L35) (updated with cross-links to `second_harmonic_opa_and_centrosymmetry_identities` and `opaSqueezed_splat_and_continuum_identities`) |
| **N-LIG Graphene SPP Waveguides, Transverse ($v_{\mathrm{ph},\perp}>c$) vs. Longitudinal ($v_{\mathrm{ph},\parallel}<c$) Cutoff, & CW Laser Controls** | [grassmannian-polariton-spp-mechanics-paper.md](grassmannian-polariton-spp-mechanics-paper.md), [flat-light-nanolithography-scholarly.md](flat-light-nanolithography-scholarly.md), [chat-physics-catalog.md](chat-physics-catalog.md) | [flat-light-proca-nlig-validation-plan.md](flat-light-proca-nlig-validation-plan.md#L38-L50) (updated with cross-links to `csr_spp_cherenkov_cavity_and_grover_identities` and `sppContinuum_gr24_and_semigroup_identities`) |
| **DDF Active-Radiation Null ($\eta_{\mathrm{act}}^\gamma = 0$), Vortex Circulation, & JHTDB/PIV Cutouts** | [grassmannian-ddf-moving-sheath-paper.md](grassmannian-ddf-moving-sheath-paper.md), [grassmannian-holographic-principle-paper.md](grassmannian-holographic-principle-paper.md), [src/signals/OPEN_FLOW_DATASETS.md](../src/signals/OPEN_FLOW_DATASETS.md) | [src/signals/DDF_FRACTURE_COMMUNICATION_PLAN.md](../src/signals/DDF_FRACTURE_COMMUNICATION_PLAN.md) (`HDDF-active-null` crossed-beam discriminator & Magnus control) and [src/signals/RUST_NUMERICAL_ADAPTER_SPEC.md](../src/signals/RUST_NUMERICAL_ADAPTER_SPEC.md) |
| **AdS/CFT Dictionary, Planar Integrability (`arXiv:1012.3982`), & $\mathfrak{psl}(2|2)_c$ Secret Symmetries (`arXiv:1204.2366`)** | [grassmannian-ads-cft-ddf-paper.md](grassmannian-ads-cft-ddf-paper.md), [grassmannian-qism-bethe-ansatz-paper.md](grassmannian-qism-bethe-ansatz-paper.md), [src/signals/blueprint/src/content.tex](../src/signals/blueprint/src/content.tex) | [huygens-grassmannian-amplituhedron-plan.md](huygens-grassmannian-amplituhedron-plan.md#L1402-L1485) (Iterations 32–33) and [lean-blueprint-rust-port-plan.md](lean-blueprint-rust-port-plan.md) (`:blueprint` / `:blueprintJson` export) |
| **2D/3D Normed Tensor Gaussian Splats, Simultaneous Splitting Conservation, Holographic $Gr_{\mathbb{C}}(2,4)$ Depth Recovery, & Convergent Volumetric Imaging** | [gaussian-splat-tensors-normed-paper.md](gaussian-splat-tensors-normed-paper.md) ([src/signals/docs/gaussian-splat-tensors-normed-paper.md](../src/signals/docs/gaussian-splat-tensors-normed-paper.md)), [grassmannian-holographic-imaging-depth-recovery-paper.md](grassmannian-holographic-imaging-depth-recovery-paper.md), [grassmannian-splat-mechanics-paper.md](grassmannian-splat-mechanics-paper.md) | [src/signals/RUST_NUMERICAL_ADAPTER_SPEC.md](../src/signals/RUST_NUMERICAL_ADAPTER_SPEC.md) (`orbital_splat.rs`), [flat-light-proca-nlig-validation-plan.md](flat-light-proca-nlig-validation-plan.md), and [dispersive-homodyne-plan.md](dispersive-homodyne-plan.md) |

---

## 2. Summary of All Nine Project Plan Documents

1. **[huygens-grassmannian-amplituhedron-plan.md](huygens-grassmannian-amplituhedron-plan.md) (*Huygens Diffraction, Grassmannians, and Positive Geometry*)**:
   - **Scope**: Master 33-iteration Lean 4 and Rust/WASM roadmap progressing from finite aperture sums, measured-cell quadrature, and plabic network routing to $Gr_{\mathbb{C}}(2,4)$ & $Gr_{\mathbb{C}}(3,n)$, QISM/Bethe ansatz, DDF moving sheaths, BCJ/planetary gravity, normed Tensor Gaussian Splats, Inverse Compton/Raman/second-sound heat, polaritons/SPPs, 't Hooft–Susskind holography, AdS/CFT integrability, and $16 \times 16$ $\mathfrak{psl}(2|2)_c$ secret symmetries.
   - **Status**: Iterations 1–33 complete (`3,715` Lake jobs, 10 companion papers, 48 Rust/WASM tests passing), including the paraxial Fresnel-to-Fraunhofer remainder bound (`fresnel_to_fraunhofer_remainder_bound`, `CellQuadrature.fresnelFraunhoferComparison`), higher-rank $Gr(3,n)$ / $Gr_{\mathbb{C}}(3,n)$ 4-term Plücker relations (`threeRowMinor_pluecker`), multi-layer & 3-channel LGV disjoint-path positivity (`lgv_multiLayer_det_positive`, `planar_threeChannel_lgv_and_bottleneck_identities`), full $16 \times 16$ $\mathfrak{psl}(2|2)_c$ worldsheet $R$-matrix and Yangian-tail secret intertwining (`psl22_rmatrix16_secret_coproduct_intertwining`), and adaptive two-child splat splitting conservation (`splitMajor_conservation_identities`, `split_if_anisotropic`).
   - **Remaining**: Non-paraxial 3D Rayleigh–Sommerfeld vector boundary-integral remainder, arbitrary-rank ($k \ge 4$) Plücker syzygies, and calibrated laboratory interferometric/Raman/thermal-wave dataset ingestion.
2. **[flat-light-proca-nlig-validation-plan.md](flat-light-proca-nlig-validation-plan.md) (*Flat Light, Proca, and N-LIG Waveguide Validation Plan*)**:
   - **Scope**: Preregistered experimental and computational adjudication program separating five claims: (1) N-LIG material synthesis, (2) classical guided optical/THz/SPP modes, (3) multi-beam holography, (4) low-power CW graphitization, and (5) Pending Proca/Flat Light hypotheses.
   - **Status**: Classical & Pending contracts implemented (`LongitudinalBeamApplicationEvidence`, `sppEffectiveIndexSq`, `transversePlasmaPhaseVelSq` vs. `longitudinalPlasmaPhaseVelSq`).
   - **Remaining**: Dose-stepped CW vs. pulsed N-LIG Raman/XPS/HAZ experiments and high-NA vectorial PSF/MTF imaging controls.
3. **[dispersive-homodyne-plan.md](dispersive-homodyne-plan.md) (*Dispersive Homodyne Coverage and Implementation Plan*)**:
   - **Scope**: Audits and plans `Signals.Homodyne`, `Signals.NonDestructive`, `Signals.MHD`, dual-homodyne CHSH/Bell traces, dispersive QND parity readout, $\chi^{(2)}$ OPA squeezing, Hawking-like CP/ALS decoding, and Argon MHD power ledgers.
   - **Status**: Substantially implemented (`Signals.Homodyne`, `Signals.NonDestructive`, `Signals.MHD`, `SecondHarmonicResonantOpaModel`, `opaSqueezedTensorSplat`).
   - **Remaining**: Contract regression fixtures (`WaveguideSpec.propagationLoss`, `DualHomodyneTrace.missingSamples`, CMRR dB-to-linear conversion) and calibrated detector-loss/shot-noise trace ingestion.
4. **[src/signals/DDF_FRACTURE_COMMUNICATION_PLAN.md](../src/signals/DDF_FRACTURE_COMMUNICATION_PLAN.md) (*DDF Fracture-Communication Validation Plan*)**:
   - **Scope**: Replaces earlier SQG fracture framing with a three-part hypothesis test: `H0` (ordinary calibrated acoustic/elastic/optical transfer + classical Magnus lift $L' = \rho U \Gamma$), `HDDF` (causal transverse-phonon perturbation tied to an independently measured vortex/pressure-deficit observable), and `HDDF-active-null` (crossed-laser-beam deflection test of $\eta_{\mathrm{act}}^\gamma = 0$).
   - **Status**: Contracts (`DDFFractureCommunicationEvidence`, `MagnusEffectControl`) and JHTDB/PIV/RSPID dataset probes implemented.
   - **Remaining**: Populate `DDFFractureCommunicationEvidence` from an independent defect measurement with blinded waveform replication.
5. **[src/signals/RUST_NUMERICAL_ADAPTER_SPEC.md](../src/signals/RUST_NUMERICAL_ADAPTER_SPEC.md) (*Rust Numerical Adapter Specification*)**:
   - **Scope**: Defines the Lean-to-Rust/WASM/WebGL2 boundary: Vortex `0.86.1` columnar arrays, PDEBench HDF5, Zenodo cylinder PIV, RSPID synthetic controls, JHTDB 3D cutouts, RK2 FTLE/LCS advection, and the four physics modules (`double_slit.rs`, `orbital_splat.rs`, `thermal_inelastic.rs`, `polariton_spp.rs`).
   - **Status**: Native core, Vortex/HDF5/JHTDB readers, and all four `wasm32-unknown-unknown` / WebGL2 physics modules implemented (48 tests passing).
   - **Remaining**: Vortex vs. Arrow/Parquet large-cutout benchmarks and adaptive splat splitting/remeshing under high Anosov/OPA aspect ratios.
6. **[lean-blueprint-rust-port-plan.md](lean-blueprint-rust-port-plan.md) (*Lean Blueprint and SphinxDocRs Roadmap*)**:
   - **Scope**: Integrates LeanArchitect's `:blueprint` / `:blueprintJson` facets with `dsport`'s Rust `sphinxdocrs` engine, optional Lean LSP semantic enrichment, and `ratex` PDF generation.
   - **Status**: Package-wide `:blueprint` and `:blueprintJson` facets active across all four `Signals` targets (3,715 Lake jobs).
   - **Remaining**: Phase 1 `ratex` XeLaTeX PDF parity check and Phase 3–4 Rust `BlueprintSnapshot` importer in `sphinxdocrs`.
7. **[rdfhdt-implementation-plan.md](rdfhdt-implementation-plan.md) (*RDF-HDT Implementation Plan*)**:
   - **Scope**: Plans a streaming Rust `hdt-rs` (`0.7.3`) bridge (`export_hdt` / `import_hdt`) between `pyoxigraph.Store` and static `.hdt` search artifacts (`docindex.hdt`), avoiding Python string materialization while retaining `docindex.nt` fallback.
   - **Status**: Architecture and `docs/conf.py` hooks defined (`docindex_rdf_hdt_enabled`).
   - **Remaining**: Implement the standalone Rust helper crate under `src/docindex` and benchmark against N-Triples export.
8. **[workflow-performance-plan.md](workflow-performance-plan.md) (*Workflow Simplification and Performance Plan*)**:
   - **Scope**: Content-hash manifest pipeline (`.tmp/workflow/chat-manifest.json`) driving incremental `transform-md`, Sphinx HTML builds, and `docindex` OxiRS/Meilisearch indexing from [`docs/_toc.yml`](_toc.yml).
   - **Status**: Phase 0 & Phase 1 incremental runner active (`make chat_overlays`, `tools/workflow_transform.py`).
   - **Remaining**: Single-pass in-memory MyST+notebook fan-out in `transform-md`, Sphinx changed-page instrumentation for incremental `docindex` upserts, and `.tmp/workflow/last-run.json` metrics.
9. **[wiki-plan.md](wiki-plan.md) (*Products Catalog & Docs Wiki Structure Plan*)**:
   - **Scope**: Defines the R&D Wiki hierarchy, CamelCase Hashtaggable names ("hames", e.g., `ProductOmniCarbonBattery`, `LignoluxUnderground`), PEP 440 semver+git-hash product versioning, and RDF 1.2 / IOF / ValueFlows / EMMO `(input, process, output)` templates in YAML-LD / JSON-LD for digital-twin factory layout synthesis.