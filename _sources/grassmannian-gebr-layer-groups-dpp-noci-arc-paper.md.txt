---
title: "Verified Finite Contracts for Grassmannian EBR, All 80 Crystallographic Layer Groups, PSD Slavnov–Gram DPPs, Multi-Reference NOCI, Tequila-Compiled Grid DSLs, and Finite-Graph Ihara–Selberg Zeta Functions in Lean 4, Rust/PyO3 (maturin), and Python/SymPy"
description: "An arXiv-ready MyST Markdown formal verification and computational engineering paper executing Workstreams WS-0 through WS-9 of the Grassmannian EBR chat-porting plan across Lean 4, Rust/PyO3 (maturin), Tequila quantum simulation reuse, multi-array PCA morphology reuse, and Python/SymPy symbolic verification, with strict epistemic separation between proved finite contracts and Pending physical or benchmark gates."
---

(grassmannian-gebr-layer-groups-dpp-noci-arc-paper)=
# Verified Finite Contracts for Grassmannian EBR, All 80 Crystallographic Layer Groups, PSD Slavnov–Gram DPPs, Multi-Reference NOCI, `Tequila`-Compiled Grid DSLs, and Finite-Graph Ihara–Selberg Zeta Functions in Lean 4, Rust/PyO3 (`maturin`), and Python/SymPy

- **Authors:** Wes Turner
- **Subjects:**
  - Mathematical Physics (`math-ph`); Quantum Physics (`quant-ph`); Chemical Physics (`physics.chem-ph`); Combinatorics & Crystallography (`math.CO`); Artificial Intelligence & Formal Verification (`cs.AI`, `cs.LO`); Programming Languages (`cs.PL`)
- **Implementation Plan & Source Provenance:**
  - [Grassmannian EBR Chat-Code Porting Ledger and Phased Implementation Plan](grassmannian-gebr-chat-porting-plan.md) (`WS-0` through `WS-9`)
  - AI Chat Source (design provenance, not scholarly validation): {download}`data/chats/Gemini_Quantum-Causal-Grassmannian-Monograph-Review_20261118-1629.md <../data/chats/Gemini_Quantum-Causal-Grassmannian-Monograph-Review_20261118-1629.md>`
  - Reusable Chat-Patch Tooling: {download}`tools/extract_chat_code_blocks.py <../tools/extract_chat_code_blocks.py>` and {download}`chat-code-patches skill <../.agents/skills/chat-code-patches/SKILL.md>`
- **Formal Verification & Simulation Artifacts:**
  - `Signals` Lean 4 Library (`leanprover/lean4:v4.35.0-rc3`, `3,631` core Lake jobs, zero `sorry` axioms):
    - {download}`src/signals/Signals/GrassmannianEBR.lean <../src/signals/Signals/GrassmannianEBR.lean>` (WS-1 Pauli spinor/Minkowski bridge, WS-4 Gram PSD & inverse, WS-5 VRC-3 & 2-state NOCI lowering, WS-9 finite-graph Ihara–Selberg Ramanujan equivalence)
    - {download}`src/signals/Signals/LayerGroups.lean <../src/signals/Signals/LayerGroups.lean>` (WS-3 exact integer/half-lattice affine layer-group monoid/group composition and generator relations)
    - {download}`src/signals/Signals/QuantumCooling.lean <../src/signals/Signals/QuantumCooling.lean>` & {download}`src/signals/Signals/Pending.lean <../src/signals/Signals/Pending.lean>` (WS-2 `InferenceThermodynamicCycleContract` closed-cycle Second Law; WS-8 `TextileObservationContract`)
    - {download}`src/signals/SignalsTests.lean <../src/signals/SignalsTests.lean>` & {download}`src/signals/SignalsPendingTests.lean <../src/signals/SignalsPendingTests.lean>`
  - `signals-numerical-adapter` Rust + PyO3 (`maturin`) Extension (`122` passing unit tests):
    - {download}`src/signals/numerical_adapter/src/layer_groups.rs <../src/signals/numerical_adapter/src/layer_groups.rs>` (all 80 IT Vol. E layer groups $\mathcal{L}_1\text{–}\mathcal{L}_{80}$)
    - {download}`src/signals/numerical_adapter/src/slavnov_dpp.rs <../src/signals/numerical_adapter/src/slavnov_dpp.rs>` (Cholesky regularized Gram $\log\det$ and analytical gradients $2 X G_\varepsilon^{-1}$)
    - {download}`src/signals/numerical_adapter/src/multi_reference_noci.rs <../src/signals/numerical_adapter/src/multi_reference_noci.rs>` (Löwdin canonical orthogonalization, Jacobi eigensolver, stretched $\mathrm{H}_2$ benchmark cross-checked against `tequila_simulator::expectation_pauli_hamiltonian_msb`)
    - {download}`src/signals/numerical_adapter/src/ebr_benchmark.rs <../src/signals/numerical_adapter/src/ebr_benchmark.rs>` (seeded continuous-relaxation EBR + adaptive halting + DPP harness separated from exact backtracking)
    - {download}`src/signals/numerical_adapter/src/arc_dsl.rs <../src/signals/numerical_adapter/src/arc_dsl.rs>` (compositional `GridOp` DSL reusing `multi_array_imaging` PCA object invariants, `layer_groups` $D_4$ operations, and `tequila_simulator::simulate_circuit_msb`)
    - {download}`src/signals/numerical_adapter/src/finite_constraint_solvers.rs <../src/signals/numerical_adapter/src/finite_constraint_solvers.rs>` & {download}`src/signals/numerical_adapter/src/lib.rs <../src/signals/numerical_adapter/src/lib.rs>`
  - Python + SymPy + PyO3 (`signals_numerical_adapter`) Verification Suite:
    - {download}`tests/test_gebr_advancements_sympy_pyo3.py <../tests/test_gebr_advancements_sympy_pyo3.py>`
- **Companion Papers Reused:**
  - [Unification, Engineering Applications, and Research Roadmap](grassmannian-unification-applications-roadmap-paper.md)
  - [A Rust/PyO3 (`maturin`) Quantum Simulation Backend for `Tequila`](grassmannian-tequila-rust-pyo3-quantum-simulator-paper.md)
  - [Multi-Spectral and Multi-Array Grassmannian Imaging Across Scales](grassmannian-multispectral-hubble-medical-nanoimaging-paper.md)
  - [Grassmannian Geometry of Quantum Causal Inference, Counterfactual Semantics, Constructor Theory, and the Mpemba / Entropy-Siphoning Laws](grassmannian-quantum-causal-inference-mpemba-paper.md)
  - [Why the Quantum Fisher Information Metric Is Four Times the Fubini–Study Kähler Metric ($F_{\mu\nu} = 4\,g_{\mu\nu}^{\mathrm{FS}}$)](grassmannian-qfim-fubini-study-kahler-madelung-unification-paper.md)
  - [Grassmannian Geometry of the Quantum Inverse Scattering Method and Algebraic Bethe Ansatz](grassmannian-qism-bethe-ansatz-paper.md)
  - [Superconductivity, QAHE/FQAH, Supersolid Vortices, and Topological Quantum Computing in Rhombohedral and Moiré Multilayer Graphene (`G-MGS`)](grassmannian-rhombohedral-graphene-superconductivity-qc-paper.md)

---

## Abstract

Translating speculative research dialogues into trustworthy scientific software requires separating **machine-checked finite mathematics and deterministic reference implementations** from **unmeasured physical, benchmark, or analytic claims**. Following the audit of 64 fenced code blocks in `data/chats/Gemini_Quantum-Causal-Grassmannian-Monograph-Review_20261118-1629.md` ([Porting Plan](grassmannian-gebr-chat-porting-plan.md)), this paper reports the tri-language execution of all nine workstreams (`WS-1` through `WS-9`) in **Lean 4** (`3,631` Lake jobs, zero `sorry`), **Rust + PyO3 (`maturin`)** (`122` unit tests compiled into the editable Python extension `signals_numerical_adapter`), and **Python/SymPy** (`15` combined SymPy/PyO3 + `Tequila` tests passing).

Crucially, rather than duplicating existing infrastructure, the implementation directly reuses our companion `Signals` and `Tequila` stack:
1. **`WS-1` (Dispersion Physics)**: Connects `Gr24DispersionParameters` to `Signals.Proca.FourVector` (`+,-,-,-`) and SI `Signals.Units`, proving Hermitian Pauli spinor determinant preservation $\det K(k) = k_0^2 - k_x^2 - k_y^2 - k_z^2$ and exact $z$-Lorentz boost invariance in Lean 4 and SymPy while keeping physical Maxwell/Proca/evanescent identifications gated in `Signals.Pending`.
2. **`WS-2` (Closed-Cycle Conditional Landauer & QFIM–Bures)**: Quarantines speculative vacuum-extraction prose in `Signals.QuantumCooling` and proves in `Signals.Pending.InferenceThermodynamicCycleContract` that even when single-shot conditional erasure is negative ($S(A\mid M) < 0$), closing the cycle via memory reset and dimensioned QFIM–Bures action dissipation $\hbar\mathcal{L}_{\mathrm{QFIM}}^2 / (4\tau)$ obeys the Second Law ($Q_{\mathrm{closed}} \ge k_B T \ln 2 \cdot N_{\mathrm{bits}} > 0$).
3. **`WS-3` (All 80 Crystallographic Layer Groups)**: Formalizes exact integer/half-lattice affine composition modulo $\mathbb{Z}^2 \times \{0\}$ in `Signals.LayerGroups` and exhaustively verifies identity, closure, inverses, exact group orders, and 17-wallpaper projections across all 80 International Tables Vol. E layer groups ($\mathcal{L}_1\text{–}\mathcal{L}_{80}$) in Rust/PyO3, keeping `G-MGS` transport/QAHE claims decoupled.
4. **`WS-4` (PSD-Verified Slavnov–Gram DPP)**: Proves $2\times 2$ regularized Gram positivity, duplicate collapse, and inverse identities in Lean 4; implements exact Cholesky $\log\det(X^\top X + \varepsilon I)$ and analytical gradients $2 X G_\varepsilon^{-1}$ verified against SymPy symbolic differentiation ($<10^{-11}$); and empirically demonstrates on 8-Queens that raw-coordinate Gram-DPP spans only `5/12` $D_4$ orbits without explicit orbifold quotienting (vs. `12/12` after $D_4$ quotienting).
5. **`WS-5` (`QCI-GXC` Multi-Reference NOCI & VRC-3)**: Proves VRC-3 smooth degeneracy evaluation at $\Delta\varepsilon = 0$, the $1/4$ QNG step from $F_{\mu\nu} = 4 g_{\mu\nu}^{\mathrm{FS}}$, and exact 2-state NOCI variational lowering in Lean 4; implements Löwdin canonical orthogonalization and Jacobi eigensolving in Rust/PyO3; and cross-checks stretched $\mathrm{H}_2$ (2-site Hubbard) 2-state PUHF vs. 3-state NOCI against exact FCI and `tequila_simulator::expectation_pauli_hamiltonian_msb` ($|\Delta E| < 10^{-12}$, $\langle\hat{S}^2\rangle = 0$).
6. **`WS-6` (Seeded EBR Harness)**: Separates continuous Sinkhorn + McWeeny + DPP relaxation from exact backtracking, showing transparently that unlearned continuous relaxation achieves `Pass@1 = 0.20` on 4-Queens and `0.00` on 6- and 8-Queens (`seed = 42`), refuting unbenchmarked `100% Pass@1` claims without an upstream trained EBR energy network (`arXiv:2611.08977`).
7. **`WS-7` (Compositional Grid DSL Reusing `Tequila` & `multi_array_imaging`)**: Implements typed `GridOp` primitives (rotations, flips, transpose, connected-component object extraction, cropping, recoloring, tiling, mirroring, bounded BFS synthesis) that reuse `multi_array_imaging` rotation-invariant PCA descriptors (`cov_det_2d`, `aspect_ratio`, `bbox_fill_density`, `principal_angle_rad`), `layer_groups` $D_4 \subset \mathcal{L}_{55}$ matrices, and exact reversible `TequilaGateOp` (`X`, `SWAP`) quantum-circuit execution via `tequila_simulator::simulate_circuit_msb`.
8. **`WS-8` & `WS-9` (Textile Gate & Isolated Finite-Graph Ihara–Selberg)**: Encodes `TextileObservationContract` in `Signals.Pending` with `Units.Length`/`Units.Force`/`Units.Duration`, verifies 3D knitted centerline Klein residual $= 0$ in SymPy, and proves the established finite-graph Ramanujan critical-circle equivalence ($\lambda^2 \le 4q \implies |u|^2 = 1/q$) verified symbolically on the 10-vertex 3-regular Petersen graph ($q=2$) without making any Riemann Hypothesis claim.

---

## 1. Cross-Module Reuse Architecture

```{mermaid}
flowchart TB
    subgraph Existing["Existing Verified Owners Reused (No Duplication)"]
        E1["Signals.Proca & Signals.Units<br/>(FourVector, minkowskiDot, SI types)"]
        E2["Signals.QISM & Signals.Pending<br/>(slavnovDet2_pauli_exclusion, Pending gates)"]
        E3["tequila_simulator.rs & src/tequila<br/>(TequilaGateOp, simulate_circuit_msb,<br/>expectation_pauli_hamiltonian_msb)"]
        E4["multi_array_imaging.rs (Paper 17)<br/>(2D PCA cov_det_2d, aspect_ratio,<br/>bbox_fill_density, principal_angle_rad)"]
    end

    subgraph NewModules["New Workstreams WS-1..WS-9 (Lean 4 + Rust/PyO3 + SymPy)"]
        N1["WS-1 & WS-2: GrassmannianEBR.lean,<br/>QuantumCooling.lean, Pending.lean<br/>(Pauli spinor boost + Closed-Cycle Second Law)"]
        N2["WS-3 & WS-4: LayerGroups.lean,<br/>layer_groups.rs (80 groups), slavnov_dpp.rs"]
        N3["WS-5 & WS-6: multi_reference_noci.rs,<br/>ebr_benchmark.rs (seeded harness)"]
        N4["WS-7, WS-8, WS-9: arc_dsl.rs,<br/>TextileObservationContract, Ihara–Selberg"]
    end

    subgraph Bridge["PyO3 0.24 + maturin Editable Extension & SymPy Suite"]
        P1["signals_numerical_adapter (19 PyO3 functions + 2 pyclasses)<br/>+ tests/test_gebr_advancements_sympy_pyo3.py"]
    end

    E1 --> N1
    E2 --> N2
    E3 --> N3
    E3 --> N4
    E4 --> N4
    N2 --> N4
    N1 --> P1
    N2 --> P1
    N3 --> P1
    N4 --> P1
```

---

## 2. Phase A: Dimensioned Dispersion (`WS-1`) & Closed-Cycle Thermodynamics (`WS-2`)

### 2.1 Hermitian Pauli Spinor Map and Lorentz-Boost Invariance (`WS-1`)

In `Signals.GrassmannianEBR` ({download}`src/signals/Signals/GrassmannianEBR.lean <../src/signals/Signals/GrassmannianEBR.lean>`), `DimensionedWavevector` lifts SI `Frequency` and `Speed` (`Signals.Units`) into `Signals.Proca.FourVector` $k^\mu = (f/c, k_x, k_y, k_z)$ in fixed signature $(+,-,-,-)$ and maps it to the $2\times 2$ Hermitian Pauli matrix:

$$
K(k) = \begin{pmatrix} k_0 + k_z & k_x - i k_y \\ k_x + i k_y & k_0 - k_z \end{pmatrix}, \qquad \det K(k) = (k_0 + k_z)(k_0 - k_z) - (k_x^2 + k_y^2) = k_0^2 - k_x^2 - k_y^2 - k_z^2.
$$

Lean 4 proves `pauliSpinorDet_eq_minkowskiDot`, `pauliSpinorDet_lorentzBoostZ` (for any boost satisfying $\cosh^2\eta - \sinh^2\eta = 1$), `dimensionedWavevector_minkowski_eq_dispersionInterval`, and `procaMode_pauliSpinorDet_eq_mass_sq` (linking `Signals.Proca.Mode.dispersion_relation` to $\det K(p) = m^2 > 0$). Physical identification with Maxwell, Proca, or sub-nanometer evanescent laboratory modes remains gated in `Signals.Pending.CWProcaEmissionHypothesis` and [Flat Light, Proca, and N-LIG Validation Plan](flat-light-proca-nlig-validation-plan.md).

### 2.2 Closed-Cycle Conditional Landauer & QFIM–Bures Accounting (`WS-2`)

The chat export ({download}`lines 522–695 and 1082–1221 <../data/chats/Gemini_Quantum-Causal-Grassmannian-Monograph-Review_20261118-1629.md>`) proposed an unclamped single-shot Landauer–Bures work sum and interpreted negative values as net inference cooling. `Signals.Pending.InferenceThermodynamicCycleContract` closes the cycle with explicit SI energy units:

$$
Q_{\mathrm{closed}} = \underbrace{k_B T \ln 2 \cdot S(A \mid M)\,N_{\mathrm{bits}}}_{Q_{\mathrm{single\text{-}shot}}} + \underbrace{Q_{\mathrm{reset}}}_{\ge k_B T \ln 2 (1 - S(A \mid M)) N_{\mathrm{bits}}} + \underbrace{\frac{\hbar \mathcal{L}_{\mathrm{QFIM}}^2}{4 \tau_{\mathrm{step}}}}_{\Delta W_{\mathrm{Bures}} \ge 0} + W_{\mathrm{ctrl}} \ge k_B T \ln 2 \cdot N_{\mathrm{bits}} > 0.
$$

Both Lean (`InferenceThermodynamicCycleContract.closedCycle_secondLaw_bound`, `singleShot_vs_unentangled_control`) and SymPy (`test_ws2_closed_cycle_landauer_and_qfim_bures_dimensions_sympy`) confirm that the signed conditional entropy $S(A\mid M)$ cancels identically over the closed cycle, preserving the Second Law even when single-shot conditional erasure is negative.

---

## 3. Phase B: Exact 80 Crystallographic Layer Groups (`WS-3`) & Cholesky Slavnov–Gram DPP (`WS-4`)

### 3.1 Exhaustive Verification of All 80 International Tables Vol. E Layer Groups (`WS-3`)

Every crystallographic layer group $\mathcal{L}_1\text{–}\mathcal{L}_{80}$ acts on $\mathbb{R}^3 / (\mathbb{Z}^2 \times \{0\})$ via exact affine pairs $(R, \mathbf{t})$ with $R = \operatorname{diag}(A, r_z)$, $A \in \mathrm{GL}_2(\mathbb{Z})$, $r_z \in \{-1, +1\}$, and half-lattice in-plane translations $t_u, t_v \in \mathbb{Z}/2\mathbb{Z}$. `Signals.LayerGroups` proves associativity (`LayerOp.comp_assoc`), identity laws, determinant multiplicativity (`LayerOp.det3_comp`), exact generator relations (`layerGroup_generator_relations`), and the crystal-system partition $2 + 5 + 11 + 30 + 16 + 16 = 80$.

In Rust (`layer_groups.rs`, exposed via `py_verify_all_80_layer_groups` and `py_layer_group_orbit`), BFS closure over exact integer/mod-2 generators verifies **all 80 groups** for identity, closure, inverses, exact quotient order, and projection onto **all 17 2D wallpaper groups**:

| Layer Group | Symbol | Crystal System | Wallpaper Projection | Verified Quotient Order | Generic Orbit Size | Context |
| --- | --- | --- | --- | ---: | ---: | --- |
| $\mathcal{L}_1$ | `p1` | Triclinic / oblique | `p1` | 1 | 1 | Trivial baseline |
| $\mathcal{L}_7$ | `p112/a` | Monoclinic / oblique | `p2` | 4 | 4 | Stockinette symmetry tag (`WS-8`) |
| $\mathcal{L}_{19}$ | `p222` | Orthorhombic / rect. | `p2mm` | 4 | 4 | $1\times 1$ Rib symmetry tag (`WS-8`) |
| $\mathcal{L}_{37}$ | `pmmm` | Orthorhombic / rect. | `p2mm` | 8 | 8 | Garter stitch symmetry tag (`WS-8`) |
| $\mathcal{L}_{55}$ | `p4mm` | Tetragonal / square | `p4mm` | 8 | 8 | $D_4$ grid ops (`WS-7`) |
| $\mathcal{L}_{61}$ | `p4/mmm` | Tetragonal / square | `p4mm` | 16 | 16 | Double-sided square layer |
| $\mathcal{L}_{80}$ | `p6/mmm` | Hexagonal | `p6mm` | 24 | 24 | Hexagonal layer symmetry (decoupled from `G-MGS` QAHE) |

### 3.2 PSD-Verified Cholesky Slavnov–Gram DPP and Raw vs. Orbifold Coverage (`WS-4`)

`Signals.GrassmannianEBR` proves that for $a, b \ge 0$, $c^2 \le ab$, and $\varepsilon > 0$, $\det G_\varepsilon = (a+\varepsilon)(b+\varepsilon) - c^2 > 0$ (`gramDet2Reg_pos`), duplicate vectors collapse $\det G_0 = 0$ (`gramDet2_duplicate_zero`), and $G_\varepsilon G_\varepsilon^{-1} = I_2$ (`gram2Reg_inverse_identities`). In Rust (`slavnov_dpp.rs`, exposed via `py_evaluate_gram_dpp`), Cholesky factorization computes $\log\det(X^\top X + \varepsilon I_K)$ and exact analytical gradients:

$$
\frac{\partial}{\partial X}\,\log\det\!\left(X^\top X + \varepsilon I_K\right) = 2\,X\,(X^\top X + \varepsilon I_K)^{-1},
$$

matching both central finite differences ($<10^{-7}$) and exact SymPy symbolic differentiation ($<10^{-11}$). Against the exact 8-Queens oracle (`92` boards in `12` $D_4$ orbits), greedy MAP Gram-DPP (`select_k = 12`, $\varepsilon = 10^{-4}$) reveals a concrete geometric limitation missed by chat prose:

| 8-Queens Selection Pool | Exact Oracle Pool Size | Requested $K$ | Distinct Solutions Selected | Distinct $D_4$ Orbits Covered | Final $\log\det G_\varepsilon$ |
| --- | ---: | ---: | ---: | ---: | ---: |
| Raw coordinate embedding (`orbifold_quotient=False`) | 92 | 12 | 12 | **5 / 12** | `-0.758290` |
| $D_4$-orbifold quotient (`orbifold_quotient=True`) | 12 | 12 | 12 | **12 / 12** | `-4.303787` |

Because rotated/reflected boards within the same $D_4$ orbit can be nearly orthogonal in $\mathbb{R}^{64}$, raw coordinate Gram-DPP selects orthogonal symmetry copies across only 5 of 12 fundamental orbits; full orbit diversity requires explicit orbifold quotienting prior to DPP selection.

---

## 4. Phase C: Multi-Reference NOCI (`WS-5`), Seeded EBR Harness (`WS-6`), & `Tequila`-Compiled Grid DSL (`WS-7`)

### 4.1 Multi-Reference NOCI vs. Exact FCI and `Tequila` Jordan–Wigner Pauli Expectation (`WS-5`)

`Signals.GrassmannianEBR` proves VRC-3 smooth degeneracy evaluation (`vrcPairExcitationSmooth_at_degeneracy`: $V/(\Delta\varepsilon^2 + V^2)\big|_{\Delta\varepsilon=0} = 1/V$), the $1/4$ QNG step from $F_{\mu\nu} = 4 g_{\mu\nu}^{\mathrm{FS}}$ (`qngStepFromQfim_eq_quarter_fubiniStudy`), and exact 2-state NOCI variational lowering (`nociTwoState_variational_lowering`).

In Rust (`multi_reference_noci.rs`, exposed via `py_solve_noci_generalized` and `py_benchmark_stretched_h2_noci`), Löwdin canonical orthogonalization with an explicit overlap-eigenvalue cutoff solves $H c = E S c$ on the minimal-basis 2-site 2-electron stretched-$\mathrm{H}_2$ Hubbard Hamiltonian and cross-verifies the resulting 3-state NOCI wavefunction directly against the 4-qubit Jordan–Wigner Pauli Hamiltonian in `tequila_simulator::expectation_pauli_hamiltonian_msb`:

| $(t, U)$ | $E_{\mathrm{RHF}}$ | $E_{\mathrm{UHF}}$ | $\langle\hat{S}^2\rangle_{\mathrm{UHF}}$ | $E_{\mathrm{NOCI\text{-}2}}$ (PUHF) | $E_{\mathrm{NOCI\text{-}3}}$ | $E_{\mathrm{FCI}}$ (SymPy) | $E_{\mathrm{Tequila\text{-}JW}}$ | $\|E_{\mathrm{NOCI\text{-}3}} - E_{\mathrm{FCI}}\|$ |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| $(1.0, 3.0)$ | `-0.500000` | `-0.666667` | `0.555556` | `-0.923077` | `-1.000000` | `-1.000000` | `-1.000000` | `< 1e-12` |
| $(1.0, 5.0)$ | `+0.500000` | `-0.400000` | `0.840000` | `-0.689655` | `-0.701562` | `-0.701562` | `-0.701562` | `< 1e-12` |
| $(0.5, 4.0)$ | `+1.000000` | `-0.125000` | `0.937500` | `-0.235294` | `-0.236068` | `-0.236068` | `-0.236068` | `< 1e-12` |

Both 2-state PUHF and 3-state NOCI restore exact singlet symmetry ($\langle\hat{S}^2\rangle = 0.000000$), while exhibiting the strict variational hierarchy $E_{\mathrm{FCI}} = E_{\mathrm{NOCI\text{-}3}} < E_{\mathrm{NOCI\text{-}2}} < E_{\mathrm{UHF}} < E_{\mathrm{RHF}}$.

### 4.2 Seeded Continuous-Relaxation EBR Benchmark Harness (`WS-6`)

`ebr_benchmark.rs` (`py_run_ebr_nqueens_benchmark`) keeps continuous Sinkhorn + McWeeny + DPP relaxation strictly separate from exact backtracking (`finite_constraint_solvers.rs`) and logs deterministic seeded runs (`seed = 42`, `max_steps = 120`, `step_size = 0.15`):

| Problem | Trajectories | DPP Weight | Valid Trajectories | Empirical `Pass@1` | Distinct Valid / Exact Oracle | Mean Halting Steps | Wall Time (ms) |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: |
| `4-Queens` | 10 | `0.00` | 2 | `0.20` | `2 / 2` | `3.20` | `0.046` |
| `4-Queens` | 10 | `0.02` | 2 | `0.20` | `2 / 2` | `72.50` | `1.255` |
| `6-Queens` | 12 | `0.02` | 0 | `0.00` | `0 / 4` | `80.42` | `2.530` |
| `8-Queens` | 20 | `0.02` | 0 | `0.00` | `0 / 92` | `38.15` | `6.994` |

This negative result on $N \ge 6$ is scientifically important: unlearned continuous Sinkhorn + McWeeny + DPP relaxation gets trapped in non-integer/conflicting stationary basins, confirming that upstream EBR performance (`arXiv:2611.08977`) requires a trained energy landscape rather than hand-crafted quadratic relaxations.

### 4.3 Compositional `GridOp` DSL Reusing `Tequila` Circuits and `multi_array_imaging` PCA Invariants (`WS-7`)

`arc_dsl.rs` extends the 32-element symmetry finder in `finite_constraint_solvers.rs` with typed compositional primitives (`Rotate90/180/270`, `FlipHorizontal/Vertical`, `Transpose`, `CropNonZero`, `ExtractLargestObject`, `ExtractSmallestObject`, `Recolor`, `Translate`, `Tile`, `MirrorHorizontalConcat`, `MirrorVerticalConcat`, `FillBoundingBox`) and bounded BFS synthesis (`py_synthesize_grid_program`), reusing three existing repository layers:
1. **`multi_array_imaging.rs` (Paper 17)**: Every 4-connected `GridObject` reuses `cosmic_ray_cluster_aspect_ratio`, `cosmic_ray_bbox_fill_density`, `cosmic_ray_covariance_det_2d`, and `cosmic_ray_principal_axis_angle_rad` to provide rotation- and flip-invariant shape descriptors (verified to $<10^{-12}$ across all 6 non-trivial $D_4$ operations).
2. **`layer_groups.rs` (`WS-3`)**: `grid_op_to_layer_op` maps all spatial symmetries to exact $D_4 \subset \mathcal{L}_{55}$ (`p4mm`) matrices.
3. **`tequila_simulator.rs` (Paper 44 / `src/tequila`)**: On any $2^m \times 2^m$ grid encoded into $2m$ MSB address qubits ($0\text{..}m$ = row, $m\text{..}2m$ = col), `grid_op_to_tequila_gates` compiles flips into Pauli `X` layers and transposes into `SWAP(i, m + i)` layers, and `apply_grid_op_via_tequila_circuit` executes them through `tequila_simulator::simulate_circuit_msb` with exact bit-for-bit equality against classical `apply_op`.

---

## 5. Phase D: Textile Gate (`WS-8`) & Isolated Finite-Graph Ihara–Selberg Equivalence (`WS-9`)

### 5.1 Dimensioned Textile-Observation Gate (`WS-8`)

In `Signals.Pending`, `TextileObservationContract` ties canonical stitch labels (`stockinetteL7`, `rib1x1L19`, `garterL37`) to their exact IT Vol. E layer-group numbers ($\{7, 19, 37\}$), SI yarn diameter/pitch (`Units.Length`), tensile load (`Units.Force`), relaxation time (`Units.Duration`), strain rate (`Units.Frequency`), minimum replicate count ($\ge 3$), control-fabric flag, and curl-residual uncertainty bound. SymPy (`test_ws8_and_ws9_sympy_yarn_plucker_klein_and_petersen_ihara_zeta`) confirms that a parametric 3D knitted loop centerline $\mathbf{r}(s) = (s, A\sin(\omega s), B\cos(2\omega s))$ satisfies the Plücker Klein identity identically ($p_{12}p_{34} - p_{13}p_{24} + p_{14}p_{23} = 0$).

### 5.2 Isolated Finite-Graph Bass–Ihara Determinant & Ramanujan Critical Circle (`WS-9`)

Strictly decoupled from any claim regarding the Riemann zeta function $\zeta(s)$, `Signals.GrassmannianEBR.ihara_ramanujan_critical_circle_modulus_sq` proves that for any adjacency eigenvalue $\lambda$ of a finite $(q+1)$-regular graph satisfying the Ramanujan bound $\lambda^2 \le 4q$ ($q > 0$), the complex roots of $1 - \lambda u + q u^2 = 0$ satisfy $|u|^2 = 1/q$. SymPy evaluates the exact 10-vertex 3-regular Petersen graph ($q = 2$) determinant:

$$
\det\!\left(I_{10} - u A_{\mathrm{Petersen}} + 2 u^2 I_{10}\right) = (1 - 3u + 2u^2)(1 - u + 2u^2)^5(1 + 2u + 2u^2)^4,
$$

confirming exact eigenvalues $\{3^1, 1^5, (-2)^4\}$ and $|u|^2 = 1/2 = 1/q$ for all 18 non-trivial roots.

---

## 6. Reproducible Tri-Language Verification Commands

```bash
# 1. Lean 4 full Signals + Pending + Tests verification (3,631 Lake jobs)
make signals_build

# 2. Rust native tests (122 passing) + PyO3/maturin editable release build
cd src/signals/numerical_adapter
TMPDIR=/workspaces/sustainablefactory/.tmp maturin develop --release
cargo test

# 3. Python + SymPy + PyO3 + Tequila integration test suites (15 passing)
pytest -q tests/test_gebr_advancements_sympy_pyo3.py tests/test_tequila_signals_backend.py
```

---

## 7. Provenance Metadata (BibTeX & JSON-LD)

```bibtex
@misc{chat_gebr_monograph_review_2026,
  author       = {Turner, Wesley and Google Gemini},
  title        = {Quantum-Causal Grassmannian Monograph Review: G-EBR, 80 Layer Groups, Slavnov-Gram DPP, Multi-Reference NOCI, ARC Grid DSL, and Ihara-Selberg Graph Zeta},
  year         = {2026},
  howpublished = {AI chat log (design provenance only; not scholarly validation)},
  note         = {Source: data/chats/Gemini_Quantum-Causal-Grassmannian-Monograph-Review_20261118-1629.md, lines 20-12155}
}
```

```json
{
  "@context": "https://schema.org",
  "@type": "ScholarlyArticle",
  "headline": "Verified Finite Contracts for Grassmannian EBR, All 80 Crystallographic Layer Groups, PSD Slavnov-Gram DPPs, Multi-Reference NOCI, Tequila-Compiled Grid DSLs, and Finite-Graph Ihara-Selberg Zeta Functions in Lean 4, Rust/PyO3 (maturin), and Python/SymPy",
  "isBasedOn": [
    "data/chats/Gemini_Quantum-Causal-Grassmannian-Monograph-Review_20261118-1629.md",
    "docs/grassmannian-gebr-chat-porting-plan.md"
  ],
  "dateModified": "2026-11-18"
}
```
