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
  6. Expose PyO3 bindings `py_audit_qci_one_shot_sysid` and `py_audit_qci_one_shot_sysid_literature_benchmarks` in `lib.rs`, run `cargo test --lib quantum_causal_inference`, and rebuild wheel via `maturin develop --release --features extension-module`.

### `OSID-4`: SymPy + 45-Digit `mpmath` + PyO3 Cross-Verification & Literature Check Figures
- **Files:** `src/signals/numerical_adapter/python/signals_numerical_adapter/one_shot_sysid.py` (`signals_numerical_adapter.one_shot_sysid`), `tests/test_one_shot_sysid_sympy_pyo3.py`
- **Deliverables:** Symbolic SymPy verification of Cauchy–Binet Plücker sum-of-squares, Hankel rank-deficit ($n < 2n-1$), Pearl $\operatorname{do}$-deconfounding, Quantum Switch $\mathrm{Gr}_{\mathbb{C}}(2,4)$ commutator/anticommutator recovery, `QFIM = 4 g_FS` QCRB + Landauer laws, and cross-literature benchmarks (Boullé et al.'s Forced Duffing, 2D Allen–Cahn, 2D Elliptic Prop. 36, 2D Navier–Stokes continuity + 16-term momentum, and $40\times 40$ / $1000\times 1000$ Circulant/Hankel; Qi & Ranard 2019 / Bairey et al. 2019 single-eigenstate Hamiltonian identification & Davis–Kahan perturbation bound; Zhao et al. 2020 super-Heisenberg Quantum Switch metrology; and Goswami et al. 2018 / Rubino et al. 2017 photonic causal witness margins), plus 45-digit `mpmath` vs. Rust/PyO3 numerical assertions via `pytest`.

### `OSID-5`: MyST Paper & Documentation Integration
- **Files:** `docs/grassmannian-quantum-causal-one-shot-system-identification-paper.md`, `docs/_toc.yml`, `docs/plan-index.md`
- **Deliverables:** Complete arXiv-ready MyST paper with Mermaid diagrams, proper KaTeX math and escaped table pipes, verified `{cite:p}` / `{cite:t}` attributions to Boullé et al. (2026), Qi & Ranard (2019), Bairey et al. (2019), Zhao et al. (2020), Rubino et al. (2017), Goswami et al. (2018), and internal papers, and exact Lean/Rust/Python verification ledger.

### `OSID-6`: Full Validation Loop
- **Checks:** Markdown math/table scanners (`tools/fix_markdown_table_math_pipes.py`, `tools/fix_markdown_display_math_spacing.py`), `pytest -q tests/test_one_shot_sysid_sympy_pyo3.py tests/test_markdown_display_math_spacing.py tests/test_markdown_table_math_pipes.py`, `make signals_build`, `make -C docs html > .tmp/docs-html.log 2>&1`, browser inspection for MathJax rendering and zero `mjx-merror`, and `git diff --check`.

---

## 3. Part II: Integrating `QCI-OSID` with `Tequila` and Our `signals` / `grassmann` Backend (`OSID-TQ`)

### 3.1 Motivation

Sections `OSID-1`–`OSID-6` established `QCI-OSID` in standalone Lean 4, Rust/PyO3 (`quantum_causal_inference.rs`), and SymPy/`mpmath`. However, practical quantum system identification in chemistry and many-body hardware requires executing probes, variational eigenstates, noise channels, and expectation-value batches directly inside an operator/circuit compiler stack. Integrating `QCI-OSID` with **Tequila** {cite:p}`tequila2021,kottmann2021direct` and our native Rust/PyO3 **`signals` / `grassmann` Tequila backend** (`sustainablefactory/tequila_signals_backend.py`, `src/signals/numerical_adapter/src/tequila_simulator.rs`, and [the Tequila Rust/PyO3 simulator paper](grassmannian-tequila-rust-pyo3-quantum-simulator-paper.md)) bridges symbolic quantum circuits (`QCircuit`, `QubitHamiltonian`, `ExpectationValue`, `BraKet`, `tq.minimize`) with `QCI-OSID` recovery.

### 3.2 Advantages vs. Disadvantages Trade-Off Analysis

| Dimension | Advantages of `Tequila` + `signals`/`grassmann` Integration | Disadvantages, Costs, & Pitfalls |
| --- | --- | --- |
| **Circuit & Hamiltonian Compilation** | `BackendCircuitSignals` compiles `ExpPauli`, controlled rotations, `SWAP`, and `Toffoli` natively into `RustFastCircuit` without CNOT decomposition ladders; `RustFastHamiltonianSet` evaluates all $\{L_i, L_j\}$ and $[L_m, \mathcal{O}_j]$ batches in one Rayon-parallelized pass. | Adds Python/FFI + `sympy` lambdify marshaling overhead (~ms scale) on tiny $n \le 6$ systems compared to raw Rust `quantum_causal_inference.rs`; requires editable workspace installs (`-e .`, `-e ./src/tequila`, `-e ./src/signals/numerical_adapter`) in `requirements.txt`. |
| **Hilbert Space vs. Continuous PDEs** | Unlocks **128-bit sparse Plücker `HCB-SPA` identification** (`16 * 2^n_occ` bytes) up to $n_{\mathrm{orb}} = 126$ qubits (`Master Theorem 11.2`), beating the $2^n$ dense memory wall (`qulacs`, `cirq`, `qiskit`). | Tequila operates on discrete qubit Hilbert spaces, **not** continuous Banach/Sobolev spaces $H^1(\Omega)$; classical PDEs/ODEs (`Duffing`, `Allen–Cahn`, `Navier–Stokes`) still belong in weak-form `CPQR` (`WIAS`), avoiding $O(2^n)$ QRAM loading. |
| **Shot Noise vs. Exact Quadrature** | `tq.simulate(..., backend="signals")` supports both exact statevectors and realistic Born-rule shot sampling (`samples=S`) for hardware emulation. | Finite-shot sampling introduces $O(1/\sqrt{S})$ matrix noise $\Delta M$, amplified by $1/\lambda_2(v)$ via Davis–Kahan (`osidTequilaShotCountRequired`: halving $\lambda_2$ causes a $4\times$ shot penalty), vs. $10^{-11}\text{–}10^{-15}$ deterministic quadrature. |
| **Noise & McWeeny Purification** | `do_simulate_density(mcweeny_passes=k)` (`3ρ² - 2ρ³`) and `MCWF`/homodyne/heterodyne trajectories heal weakly depolarized **pure eigenstates** ($p \in (1/2, 1)$), shrinking eigenstate `OSID` error (`Master Theorem 11.2`). | Dense density matrices scale as $O(4^n)$ (`16 * 4^n` bytes, limit $n \lesssim 12$); **crucially, McWeeny purification distorts genuine mixed/Gibbs states** ($p \in (0, 1/2) \implies 3p^2 - 2p^3 < p$), corrupting thermal-state `OSID`. |
| **VQE, Quantum Switch, & Non-Unitary Gates** | `tq.minimize(..., backend="signals")` + `compute_natural_gradient` (`QFIM = 4 g_FS`) enables VQE-eigenstate `OSID` + circuit-level $\mathrm{Gr}_{\mathbb{C}}(2,4)$ Quantum Switch control-qubit readout $\langle Z_c\rangle = E_+ - E_-$. | Non-unitary `CausalDo` and `NonlinearKerr` gates sit outside Tequila's two-term unitary `tq.grad` parameter-shift rule; symmetry-unbroken states ($\lambda_2 = 0$) and overall scale/identity shifts ($H \mapsto \alpha H + \beta I$) remain unidentifiable from a single eigenstate. |

### 3.3 Phased Tequila Integration Workstreams (`OSID-TQ-1`–`OSID-TQ-5`)

1. **`OSID-TQ-1`: Editable Workspace Packaging & Backend Registration (`requirements.txt`, `src/signals/numerical_adapter/pyproject.toml`, `sustainablefactory/tequila_signals_backend.py`):**
   - Replace custom `sys.path` / `sys.modules` manipulation in `conftest.py`, `sustainablefactory/tequila_signals_backend.py`, and `sustainablefactory/qci_grassmannian_dft.py` with standard `pip install -e` editable entries in `requirements.txt` (`-e .`, `-e ./src/tequila`, `-e ./src/signals/numerical_adapter`) and `maturin` Python-source packaging (`src/signals/numerical_adapter/python/signals_numerical_adapter/`), ensuring the `signals` and `grassmann` backends load cleanly across `pytest`, subprocesses, and Python entrypoints.
2. **`OSID-TQ-2`: Lean 4 Formalization of Tequila Integration Bounds (`Signals.QuantumCausalInference` Sec. 16.2 & `SignalsTests.lean`):**
   - Formalize `osidTequilaSparsePluckerBytes < osidTequilaStatevectorBytes < osidTequilaDensityMatrixBytes`, McWeeny pure-state healing ($p \in (1/2, 1)$) vs. thermal-state distortion ($p \in (0, 1/2)$), exact shot-count inversion $S_{\mathrm{req}} = (\sigma_1 N / (\lambda_2 \theta_{\mathrm{target}}))^2$, and $4\times$ shot inflation under $\lambda_2 \mapsto \lambda_2 / 2$ (`qci_osid_tequila_backend_advantages_and_disadvantages_identities`).
3. **`OSID-TQ-3`: Tequila-Compiled `QCI-OSID` Engine (`src/signals/numerical_adapter/python/signals_numerical_adapter/one_shot_sysid.py`):**
   - `tequila_osid_single_eigenstate_recovery`: Builds Qi–Ranard connected correlation $\{L_i, L_j\}/2$ and Bairey–Arad–Lindner commutator $i[L_m, \mathcal{O}_j]$ `QubitHamiltonian` batches, compiles once via `BackendExpectationValueSignals` (`RustFastHamiltonianSet`), and recovers $\hat{\mathbf{c}}$ from exact, VQE-converged (`tq.minimize` + `compute_natural_gradient`), and shot-sampled (`samples=S`) Tequila circuits.
   - `tequila_osid_quantum_switch_circuit`: Compiles a 2-qubit Tequila `QCircuit` Quantum Switch extracting $\langle Z_0\rangle = E_+ - E_-$ and Plücker ratio $E_- / E_+$ across `signals`, `grassmann`, `symbolic`, and `qulacs`.
   - `tequila_osid_sparse_plucker_126qubit_audit`: Executes 128-bit sparse Plücker `RustFastCircuit` + `RustFastHamiltonianSet` `OSID` relation recovery at $n = 126$ qubits ($n_{\mathrm{occ}} = 6$, support $= 64$ vs. $2^{126}$).
   - `tequila_osid_noisy_mcweeny_pure_vs_mixed_audit`: Quantifies McWeeny purification's advantage on depolarized pure eigenstates vs. its spectral distortion disadvantage on mixed thermal states.
4. **`OSID-TQ-4`: Pytest Verification (`tests/test_tequila_signals_backend.py` & `tests/test_one_shot_sysid_sympy_pyo3.py`):**
   - Verify all Tequila-OSID workflows, cross-backend numerical parity, and quantitative advantage/disadvantage assertions.
5. **`OSID-TQ-5`: Paper Update & Full Validation (`docs/grassmannian-quantum-causal-one-shot-system-identification-paper.md`):**
   - Add Section 5 documenting the Tequila integration architecture, trade-offs, Lean 4 theorem, and empirical benchmark ledger, followed by `make signals_build`, `cargo test`, `pytest`, Markdown scanners, `make -C docs html`, browser check, and `"ENH: "` commit.

---

## 4. Part III: Sato Grassmannian $\mathrm{Gr}_{\ge 0}(k, n)$ & Arbitrary $N$-Soliton Integration (`OSID-SATO`)

1. **`OSID-SATO-1`: Lean 4 Arbitrary $(k, n)$ & KdV $N$-Soliton Theorems (`Signals.SatoGrassmannian.PDESolver` Sec. 5, `Signals.QuantumCausalInference` Sec. 16.3, `SignalsTests.lean`):**
   - Prove `solitonTauKN_pos_of_totallyNonneg` (global $\tau > 0$ on $\mathrm{Gr}_{\ge 0}(k, n)$), `kdvNSolitonTau_pos_and_y_invariant` (global $\tau > 0$ and $y$-invariance for arbitrary $N$-soliton Hirota KdV with Sato's $\gamma_r = 2 k_r^3$ dispersion normalization), `hirotaKP_kdv3SolitonTau_eq_zero`, and `qci_osid_sato_positroid_akns_and_qfim_bridge_identities` (`Master Theorem 11.3`).
2. **`OSID-SATO-2`: Rust/PyO3 `PlabicGrKNSolver` & Weak-Form `QCI-OSID` Integration (`sato_grassmannian.rs`, `quantum_causal_inference.rs`, `lib.rs`):**
   - Implement `PlabicGrKNSolver` (`from_frame`, `from_totally_positive_vandermonde`, `from_kdv_n_soliton`) sharing the overflow-proof `eval_boltzmann_kp2_jet` cumulant engine with `PlabicGr24Solver`, plus `audit_osid_sato_kp2_kdv_akns_solitons` (`py_audit_qci_one_shot_sysid_sato_pdes`) using composite 16-point Gauss–Legendre weak-form `CPQR` over $\mathrm{Gr}_{>0}(2,4)$, $\mathrm{Gr}_{>0}(2,5)$, $\mathrm{Gr}_{>0}(3,6)$, KdV $N=1,2,3,4$, AKNS bright/dark solitons, and 6-channel `DualSchubertQFIM`.
3. **`OSID-SATO-3`: SymPy + 45-Digit `mpmath` + Pytest (`one_shot_sysid.py`, `test_one_shot_sysid_sympy_pyo3.py`, `test_sato_grassmannian_sympy_pyo3.py`):**
   - Cross-verify Hirota KdV 3-soliton dispersion cancellation in SymPy, 45-digit `mpmath` far-field & 3-soliton values, and `PlabicGrKNSolver` Python bindings.
4. **`OSID-SATO-4`: Paper Updates & Validation (`grassmannian-quantum-causal-one-shot-system-identification-paper.md` Sec. 6, `grassmannian-sato-hilbert-space-kp-pde-solver-akns-qfim-paper.md`, `plan-index.md`):**
   - Document positroid / $N$-soliton zero-one stratification, far-field extrapolation, AKNS separation, and 6-channel `QFIM` QCRB tightening, verified across Lean, Rust, `pytest`, Sphinx HTML, and browser MathJax checks.

---

## References

```{bibliography}
:filter: docname in docnames
:list: bullet
```
