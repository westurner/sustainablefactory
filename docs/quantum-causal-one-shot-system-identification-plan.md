---
title: "Written Plan: Quantum-Causal Grassmannian One-Shot System Identification (QCI-OSID) — Reimplementing the Boullé–Halikias–Otto–Townsend (2026) Zero-One Law with Plabic/LGV Minors, Pearl do-Surgery, Gr_C(2,4) Quantum Switch, Jeffrey Kinematics, and QFIM = 4 g_FS"
description: "Phased Lean 4, Rust/WASM/PyO3, SymPy/mpmath, and MyST verification plan reimplementing and generalizing Boullé et al. (PNAS 2026, doi:10.1073/pnas.2624491123) one-shot system identification using Grassmannian Quantum Causal Inference, Tautological Fiber Bundles, Indefinite Causal Order, Jeffrey's Kinematic Engine, Quantum Cramér–Rao conditioning, and Closed-Loop Landauer thermodynamics."
---

(quantum-causal-one-shot-system-identification-plan)=
# Written Plan: Quantum-Causal Grassmannian One-Shot System Identification (`QCI-OSID`)

- **Authors:** Wes Turner
- **Target Paper:** [Quantum-Causal Grassmannian One-Shot System Identification (`QCI-OSID`): Reimplementing the Zero-One Law of Boullé, Halikias, Otto, & Townsend (2026) in Lean 4 and Rust/PyO3](grassmannian-quantum-causal-one-shot-system-identification-paper.md)
- **Primary External Source Attributed:**
  - Nicolas Boullé, Diana Halikias, Samuel E. Otto, & Alex Townsend (2026), *"A zero-one law for one-shot system identification"*, *Proc. Natl. Acad. Sci. U.S.A.* (`PNAS`) **123**(47), e2624491123 (`doi:10.1073/pnas.2624491123`, `arXiv:2607.15832v2`), and companion proof manuscript *"One-shot identification of analytic systems"* (`arXiv:2611.30470v1`).
- **Owning Internal Causal & Operator-Learning Papers:**
  - [Grassmannian Geometry of Quantum Causal Inference, Counterfactual Semantics, Constructor Theory, and the Mpemba / Entropy-Siphoning Laws](grassmannian-quantum-causal-inference-mpemba-paper.md)
  - [Quantum Causal Grassmannian Transformers, JEV vs. $\operatorname{do}$-Calculus Decision Models, Tautological Fiber Bundles, and Spatiotemporal Video Generation](grassmannian-quantum-causal-jev-bundle-transformer-videogen-paper.md)
  - [Beyond $6{,}400\times$ Volumetric Efficiency: Jeffrey's Kinematic Engine, Normed Tensor Gaussian Splat Nanoimaging & Surgical Navigation, and Quantum Causal Semantic GraphRAG](grassmannian-quantum-causal-splat-nanoimaging-surgical-graphrag-paper.md)
  - [Quantum Causal Next-Concept Modeling (`QCI-NCM`): Coarse-to-Fine Parallel LLM Inference, Multiscale Residual Counterfactuals, Plücker/`VRC` Constraint Coupling, and Pressed-`LHAT` Scale-Selective Steering Hardware](grassmannian-quantum-causal-next-concept-modeling-pressed-llm-kicad-paper.md)

---

## 1. Scientific Motivation & Architectural Mapping

Boullé, Halikias, Otto, and Townsend {cite:p}`boulle2026zeroone,boulle2026oneshot_full` prove a sharp **zero-one law** for linearly parameterized analytic systems $\mathcal{L}(u, f) = \sum_{i=1}^N c_i^* \mathcal{D}_i(u, f) = \mathcal{D}_0(u, f)$: either *every* admissible input $f \in \mathcal{F}$ fails to make the parameter-to-recovery map $L_{f,\mathcal{G}(f)} : \mathbb{R}^N \to \mathcal{V}$ injective ($\mathcal{F}_{\mathrm{deg}}(\mathbf{c}^*) = \mathcal{F}$), or $\mathcal{F}_{\mathrm{deg}}(\mathbf{c}^*)$ is **compactly slice-null** and has zero measure under every nondegenerate Gaussian measure on $\mathcal{F}$. Their **Weak Identification of Analytic Systems (`WIAS`)** algorithm tests rank of the $r_0 \times N$ matrix $G_{ij} = \psi_i(\mathcal{D}_j(u, f))$ via column-pivoted QR, providing an *a posteriori* noiseless uniqueness certificate.

From our applied quantum physics and Grassmannian Quantum Causal Inference (`QCI`) perspective, `WIAS` leaves five physical and mathematical gaps that our causal mechanics resolves directly:

| Boullé et al. (2026) Mechanism | Physical / Causal Gap in Quantum & Lab Systems | `QCI-OSID` Reimplementation in `Signals` |
| --- | --- | --- |
| **Determinant Test $\det(\Psi L_{f,\mathcal{G}(f)} E) \neq 0$** | Treats $\mathcal{F}_{\mathrm{deg}}$ purely analytically; does not connect degeneracy to graph bottlenecks or exterior-rank collapse. | **Plabic / LGV Grassmannian Determinant Dichotomy**: $G(f)$ defines an $N$-plane in $\mathrm{Gr}_{\mathbb{R}}(N, r_0)$; Cauchy–Binet $\det(G^\top G) = \sum_I \Delta_I(G)^2 > 0$ certifies open-cell unconfounded identification, whereas factoring through $m < N$ intermediate modes collapses $\det G = 0$ (`singleHubRepresentative_det = 0`, Hankel $n < 2n-1$ vs. Circulant $n = n$). |
| **Observational $(f, u)$ Assumption** | Assumes no unobserved backdoor confounder $U$ drives both probe $f$ and state $u$; observational closed-loop trajectories bias $\hat{\mathbf{c}}$ by $b_{\mathrm{conf}}$. | **Pearl $\operatorname{do}(f := f_{\mathrm{probe}})$ Incoming-Edge Surgery + Giarmatzi–Costa Abduction**: Severs $U \to f$ to eliminate backdoor confounding bias (`causalObservationalTransfer - causalInterventionalDoTransfer = b_conf`), while abducing exogenous drift $u_E = y_{\mathrm{obs}} - \mathbf{c}^* \cdot \mathbf{d}_{\mathrm{obs}}$ in one shot. |
| **Multi-Shot Stacking for $N > n$ (Hankel Matrices)** | Classical $n \times n$ Hankel ($N = 2n - 1 > n$) cannot be identified in 1 right probe ($q_R = 1 \implies \mathrm{rank} \le n < 2n - 1$), requiring $q_R = 2$ sequential shots. | **Coherent $\mathrm{Gr}_{\mathbb{C}}(2,4)$ Quantum Switch & Pole-Free `VRC` Probe**: A control qubit $\|+\rangle_c$ superposes forward and adjoint/commutator-anticommutator probe orderings ($\{A_1, A_2\}$ vs. $[A_1, A_2]$), extracting $E_+$, $E_-$, and Plücker minor ratios from **one coherent quantum shot** while avoiding rational-chart poles. |
| **Dense Operator / Noiseless Idealization** | Dense PDE dictionaries scale quadratically across spatiotemporal grids, and noisy soft observations violate noiseless point evaluation. | **Tautological Bundle `(Z, v)` + Cross-Lag Plücker + Jeffrey Kinematics + `QFIM = 4 g_FS`**: Separates invariant law subspace $Z$ from trajectory fiber $v = Z\alpha$, preserves multi-lag rank via cross-lag wedges ($\mathcal{Q}_4 > 0$), updates soft noisy partitions via **deconfounded Jeffrey Kinematics**, and bounds estimation variance via the **Quantum Cramér–Rao Bound** $\mathrm{Var}(\hat{c}) \ge 1 / (M \cdot \mathrm{QFIM})$. |
| **Qualitative "Irreversible Alteration" Motivation** | Motivates 1-shot recovery informally by noting measurements alter systems irreversibly. | **Closed-Loop Conditional Landauer Bound**: Proves $M$-shot identification incurs $\ge M \cdot k_B T \ln 2 \cdot N_{\mathrm{bits}}$ cyclic heat (`closedLoopErasureAndMemoryResetHeat`), establishing an $M\times$ thermodynamic floor for 1-shot over $M$-shot protocols. |

---

## 2. Phased Workstreams (`OSID-1` Through `OSID-6`)

### `OSID-1`: BibTeX Attribution & Written Plan Registration
- **Files:** `docs/citations.bib`, `docs/quantum-causal-one-shot-system-identification-plan.md`
- **Deliverables:** Add exact BibTeX entries (`boulle2026zeroone`, `boulle2026oneshot_full`, `boulle2023elliptic`, `brunton2016sindy`, `messenger2021wsindy`, `halikias2024matrix`) and publish this phased plan.

### `OSID-2`: Lean 4 Formalization (`Signals.QuantumCausalInference` Sec. 16 & `Signals.Pending`)
- **Files:** `src/signals/Signals/QuantumCausalInference.lean`, `src/signals/Signals/Pending.lean`, `src/signals/SignalsPending.lean`, `src/signals/SignalsTests.lean`, `src/signals/SignalsPendingTests.lean`
- **Deliverables (Zero `sorry`):**
  1. `osidLinearRecoveryResidual`, `osidCauchyBinetGramDet2x3`, `osidPlabicRankBottleneck_det_zero` (finite-dimensional Grassmannian/LGV formulation of injectivity vs. $m < N$ rank bottleneck).
  2. `osidHankelParameterCount`, `osidCirculantParameterCount`, `osidHankelSingleRightProbeDeficit`, and `osid_hankel_vs_circulant_probe_dichotomy` (proving $n < 2n - 1$ for all $n \ge 2$ forces $\mathcal{F}_{\mathrm{deg}}^{(1)} = \mathcal{F}$ on $n \times n$ Hankel matrices, while $n \times n$ Circulant has $N = n$ and $2n \ge 2n - 1$ unlocks 2-probe Hankel recovery).
  3. `osidDoDeconfoundedSlope`, `osidObservationalConfoundedSlope`, `osidAbducedExogenousDrift`, and `osid_do_deconfounding_and_abduction` (Pearl $\operatorname{do}$-surgery eliminates backdoor bias $b_{\mathrm{conf}}$ in one-shot regression while recovering $u_E$).
  4. `osidQuantumSwitchTwoChannelInformation`, `osidQcrbVarianceLowerBound`, `osidMultiShotLandauerHeat`, and `osid_quantum_switch_qfim_qcrb_and_landauer_bounds` (relating `QFIM = 4 g_FS` to QCRB variance $\sigma^2 \ge (4 g_{\mathrm{FS}})^{-1}$ and $M$-shot vs. 1-shot cyclic Landauer dissipation).
  5. `OneShotQuantumSysIdPendingBoundary` + constructive `ofCertificates` / `solved_of_certificates` in `Signals.Pending`, isolating infinite-dimensional Banach Schauder-basis Gaussian measure zero-one convergence, noisy physical probe calibration (`ControlledMeasurement`), and physical Quantum Switch interferometry behind explicit certificates (`osid_finite_certs_do_not_close_banach_or_lab_gates`).
- **Gate:** `make signals_build` passes cleanly with zero `sorry`.

### `OSID-3`: Rust / WASM / PyO3 Numerical Implementation (`quantum_causal_inference.rs` & `lib.rs`)
- **Files:** `src/signals/numerical_adapter/src/quantum_causal_inference.rs`, `src/signals/numerical_adapter/src/lib.rs`
- **Deliverables:**
  1. Column-pivoted QR (`wias_column_pivoted_qr_rank`) returning rank, $\sigma_{\min} \approx |R_{NN}|$, condition estimate $\kappa$, Cauchy–Binet Grassmannian minor sum $\det(G^\top G)$, and least-squares coefficients $\hat{\mathbf{c}}$.
  2. **1D Allen–Cahn / Cubic Reaction–Diffusion PDE (`audit_osid_allen_cahn_pde`)**: 1-shot Gaussian forcing recovery vs. degenerate harmonic forcing ($\det = 0$); plus tautological bundle `(Z, v)` decomposition and cross-lag Plücker $\mathcal{Q}_4 > 0$ diagnostic.
  3. **Chaotic Lorenz ODE Weak Integral Recovery (`audit_osid_lorenz_ode`)**: 1-shot trajectory recovery of $(\sigma, \rho, \beta) = (10, 28, 8/3)$ plus comparison of observational confounded slope vs. Pearl $\operatorname{do}$-deconfounded recovery and Giarmatzi–Costa abduction.
  4. **Structured Matrix Families (`audit_osid_matrix_circulant_vs_hankel_and_switch`)**: $4 \times 4$ Circulant (1-shot full rank 4), $3 \times 3$ Hankel ($N=5 > 3$: 1 classical right probe rank $3 < 5$; 2 classical probes rank $5 = 5$), and 1-shot $\mathrm{Gr}_{\mathbb{C}}(2,4)$ Quantum Switch coherent $\{A_1, A_2\}$ / $[A_1, A_2]$ extraction for non-commuting $2 \times 2$ Pauli/Hamiltonian operators.
  5. **Soft-Partition Noisy `QCI-OSID` (`audit_osid_noisy_jeffrey_qfim_landauer`)**: Jeffrey kinematic update under noisy telemetry, QCRB bound $\mathrm{Var}(\hat{c}) \ge 1 / (M \cdot \mathrm{QFIM})$, and 1-shot vs. $M$-shot closed-loop Landauer heat.
  6. Expose PyO3 bindings `py_audit_qci_one_shot_sysid` in `lib.rs`, run `cargo test --lib quantum_causal_inference`, and rebuild wheel via `maturin develop --release`.

### `OSID-4`: SymPy + 45-Digit `mpmath` + PyO3 Cross-Verification & Literature Check Figures
- **Files:** `sustainablefactory/one_shot_sysid.py`, `tests/test_one_shot_sysid_sympy_pyo3.py`
- **Deliverables:** Symbolic SymPy verification of Cauchy–Binet Plücker sum-of-squares, Hankel rank-deficit ($n < 2n-1$), Pearl $\operatorname{do}$-deconfounding, Quantum Switch $\mathrm{Gr}_{\mathbb{C}}(2,4)$ commutator/anticommutator recovery, `QFIM = 4 g_FS` QCRB + Landauer laws, and cross-literature benchmarks (Boullé et al.'s Forced Duffing, 2D Allen–Cahn, 2D Elliptic Prop. 36, Navier–Stokes continuity, and $1000\times 1000$ Circulant/Hankel; Qi & Ranard 2019 / Bairey et al. 2019 single-eigenstate Hamiltonian identification; Zhao et al. 2020 super-Heisenberg Quantum Switch metrology; and Goswami et al. 2018 / Rubino et al. 2017 photonic causal witness margins), plus 45-digit `mpmath` vs. Rust/PyO3 numerical assertions via `pytest`.

### `OSID-5`: MyST Paper & Documentation Integration
- **Files:** `docs/grassmannian-quantum-causal-one-shot-system-identification-paper.md`, `docs/_toc.yml`, `docs/plan-index.md`
- **Deliverables:** Complete arXiv-ready MyST paper with Mermaid diagrams, proper KaTeX math and escaped table pipes, verified `{cite:p}` / `{cite:t}` attributions to Boullé et al. (2026), Qi & Ranard (2019), Bairey et al. (2019), Zhao et al. (2020), Rubino et al. (2017), Goswami et al. (2018), and internal papers, and exact Lean/Rust/Python verification ledger.

### `OSID-6`: Full Validation Loop
- **Checks:** Markdown math/table scanners (`tools/fix_markdown_table_math_pipes.py`, `tools/fix_markdown_display_math_spacing.py`), `pytest -q tests/test_one_shot_sysid_sympy_pyo3.py tests/test_markdown_display_math_spacing.py tests/test_markdown_table_math_pipes.py`, `make signals_build`, `make -C docs html > .tmp/docs-html.log 2>&1`, browser inspection for MathJax rendering and zero `mjx-merror`, and `git diff --check`.

---

## References

```{bibliography}
:filter: docname in docnames
:list: bullet
```
