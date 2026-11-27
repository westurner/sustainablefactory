---
title: "Written Plan: Closing the Constructive Contracts, Finite-Dimensional Fredholm Determinant, Infinite-Series Weil Positivity, and Unified Certificate Solvers for SatoRiemannSpectralPendingBoundary, RiemannHypothesisPendingBoundary, and ToupinCelestialMillenniumPendingBoundary"
description: "Phased implementation and formal verification plan resolving the constructive gaps and overlapping epistemic boundaries across SatoRiemannSpectralPendingBoundary, RiemannHypothesisPendingBoundary, ToupinCelestialMillenniumPendingBoundary, and YangMillsMassGapHiggsCPTPendingBoundary in Lean 4, Rust/PyO3, SymPy/mpmath, and MyST Markdown."
---

(sato-riemann-spectral-pending-closure-plan)=
# Written Plan: Constructive Gap-Closure Contracts and Unified Certificate Solvers for `SatoRiemannSpectralPendingBoundary`

- **Author:** Wes Turner
- **Owning Papers:**
  - [Adelic Carleman–Weierstrass Regularized Determinants ($\det_2, \det_3$), Schwinger 2-Cocycle Central Extensions, Segal–Wilson Determinant Bundles, $L^1(\mathbb{R})$ Weil Positivity, and Formal Bridges to `Signals.RiemannSpectral`](grassmannian-sato-adelic-carleman-weierstrass-weil-rh-gaps-paper.md) (Section 7)
  - [Formalizing the Infinite-Dimensional Sato Grassmannian $\mathrm{Gr}_p(H)$, Plabic $\mathrm{Gr}_{\ge 0}(2,4)$ KP-II / KdV / AKNS Soliton PDE Solvers, Baker–Akhiezer Lax Pairs, and 6-Channel Dual-Schubert QFIM](grassmannian-sato-hilbert-space-kp-pde-solver-akns-qfim-paper.md)
- **Companion Papers & Overlapping Pending Boundaries Integrated:**
  - [Finite Spectral Contracts for Riemann Hypothesis Approaches (`RB-1`–`RB-6`)](grassmannian-riemann-spectral-ihara-jensen-polya-paper.md) & [RH Analytical Bridges Plan](riemann-spectral-bridges-plan.md) (`RiemannHypothesisPendingBoundary`)
  - [Celestial Holography, Plancherel–Unruh Graviton Loop Weights ($M_1 = 1/8, M_2 = 1/90$), & Integrated Turner Models `15a` & `15b`](grassmannian-celestial-holography-graviton-turner-riemann-paper.md) (`ToupinCelestialMillenniumPendingBoundary`)
  - [Written Plan: Constructive Gap-Closure Contracts and Certificate Solver for `YangMillsMassGapHiggsCPTPendingBoundary`](yang-mills-higgs-cpt-pending-closure-plan.md) (`ContinuumYangMillsOSCertificate`, `CelestialConfiningSpectralCertificate`)
  - [Quantum Trajectories in Complex Grassmannian $\mathrm{Gr}_{\mathbb{C}}(k,n)$, Three-Channel Plücker–Madelung–QFIM, & DDF Mechanics](grassmannian-quantum-trajectories-bohmian-weak-nonlinear-optics-paper.md) (`DualSchubertQFIM.sharoglazova_klaers_evanescent_speed_law`, `DDFFractureCommunicationEvidence`)
- **Primary Source Provenance:**
  - {download}`data/chats/Gemini_Formalizing-Sato-Grassmannian-in-Lean_20261120-2337.md <../data/chats/Gemini_Formalizing-Sato-Grassmannian-in-Lean_20261120-2337.md>` (Blocks 008–017, lines 4336–11306)
  - {download}`data/chats/Gemini_Quantum-Causal-Grassmannian-Monograph-Review_20261118-1629.md <../data/chats/Gemini_Quantum-Causal-Grassmannian-Monograph-Review_20261118-1629.md>` (lines 2348–5728)

---

## 1. Epistemic Scope & Overlapping `Signals.Pending` Boundaries

In Section 7 of [grassmannian-sato-adelic-carleman-weierstrass-weil-rh-gaps-paper.md](grassmannian-sato-adelic-carleman-weierstrass-weil-rh-gaps-paper.md) and `Signals.Pending.SatoRiemannSpectralPendingBoundary` ({download}`src/signals/Signals/Pending.lean <../src/signals/Signals/Pending.lean>`), four open gates separate our verified 21-module `Signals.SatoGrassmannian` stack from closing `allSatoGatesClosed`. Moreover, inspecting `Signals.Pending` reveals **direct structural overlaps** across four related boundaries:

1. **`RiemannHypothesisPendingBoundary`** is embedded simultaneously inside **`SatoRiemannSpectralPendingBoundary`** (`rhBoundary`) and **`ToupinCelestialMillenniumPendingBoundary`** (`rhBoundary`), yet neither `RiemannHypothesisPendingBoundary`, `SatoRiemannSpectralPendingBoundary`, nor `ToupinCelestialMillenniumPendingBoundary` previously possessed constructive certificate types or `ofCertificates` / `solved_of_certificates` solvers.
2. **`ToupinCelestialMillenniumPendingBoundary.yangMillsContinuumSpectralTransferBridge`** overlaps directly with Gates 1 and 2 (`ContinuumYangMillsOSCertificate` and `CelestialConfiningSpectralCertificate`) already formalized for **`YangMillsMassGapHiggsCPTPendingBoundary`**.
3. **`SatoRiemannSpectralPendingBoundary.mathlibLidskiiFredholmDetConstructed`** (`FredholmDetTheory` in `DeterminantBundle.lean`) lacked both a concrete axiom-free `FiniteDimensional` instance via Mathlib `LinearMap.det` and the order-3 critical-line multiplicative anomaly `det3Diag_mul_anomaly` on $\ell^3$ ($\operatorname{Re}(s) = 1/2$, where `det2Diag` diverges).
4. **`SatoRiemannSpectralPendingBoundary.globalInfiniteZeroWeilBridge`** (`WeilGaussianL1.lean`) handled only finite `Finset ℂ` zero sets rather than countably infinite strip-bounded zero sequences `(z : ℕ → ℂ, m : ℕ → ℕ)` with explicit $L^1(\mathbb{R})$ super-Gaussian decay and tail-dominated off-line disproof bounds.
5. **`SatoRiemannSpectralPendingBoundary.evanescentQfimExperimentalValidation`** overlaps with `DualSchubertQFIM.sharoglazova_klaers_evanescent_speed_law`, `DDFFractureCommunicationEvidence`, `ComplexGrassmannianGPEAndPluckerMadelungHypothesis`, and `ControlledMeasurement` telemetry records in `Pending.lean`.

| Open Gate / Overlapping Boundary | Root Obstruction in Section 7 & `Pending.lean` | Constructive Solution & Formal Contract Implemented (`SRS-1`–`SRS-5`) |
| --- | --- | --- |
| **Gate 1 (`rhBoundary : RiemannHypothesisPendingBoundary`)** | Four global RH bridges ($\Lambda \le 0$, adelic Sato trace limit, global Weil/Li/Jensen–Pólya positivity, Hilbert–Pólya self-adjoint operator closure) lacked constructive certificate types and `solved_of_certificates` linking `RHGaps`, `RemainingGaps`, `CarlemanWeierstrass`, `WeilGaussianL1`, and `RiemannSpectral`. | Define `DeBruijnNewmanUpperCertificate`, `AdelicSatoTraceLimitCertificate`, `GlobalWeilLiJensenCertificate`, and `SelfAdjointSpectralOperatorCertificate`; prove **`RiemannHypothesisPendingBoundary.solved_of_certificates`**, discharging `allFourBridgesClosed`, `dBNConstant Flow = 0`, `AllRealZeros Ξ`, adelic $k=3$ convergence on `Re(s) = 1/2`, and finite Li/Jensen–Pólya/quartic-dBN bounds. |
| **Gate 2 (`mathlibLidskiiFredholmDetConstructed`)** | `DeterminantBundle.lean` axiomatized `FredholmDetTheory` without any concrete axiom-free instance; `CarlemanWeierstrass.lean` proved `det2Diag_mul_anomaly` ($\sigma > 1/2$) but lacked `det1Diag_mul` ($\ell^1$) and `det3Diag_mul_anomaly` on $\sigma = 1/2$. | **1.** Prove **`instFredholmDetTheoryOfFiniteDimensional`** in `DeterminantBundle.lean` using Mathlib `LinearMap.det`, discharging all four `FredholmDetTheory` axioms with zero `sorry` on finite-dimensional truncations.<br>**2.** Prove `det1Diag_mul`, `det1Diag_single`, and **`det3Diag_mul_anomaly`** (via $P_3(a)+P_3(b)-P_3(a+b+ab) = -ab(a+b+\tfrac{1}{2}ab)$ on $\ell^3$) on $\operatorname{Re}(s) = 1/2$.<br>**3.** Add `LidskiiFredholmDetCertificate` for `hardyPolarization`. |
| **Gate 3 (`globalInfiniteZeroWeilBridge`)** | `WeilGaussianL1.lean` proved `weilPositivity_L1_iff_allRealZeros` only for finite `Finset ℂ`. | Upgrade `WeilGaussianL1.lean` with **`norm_mellinTransform_shiftedGaussian_strip`**, **`weilInfiniteSum_nonneg_of_allRealZeros`**, and **`weilInfiniteSum_neg_of_offline_pair_tail_lt`** for countably infinite strip-bounded zero sequences `(z : ℕ → ℂ, m : ℕ → ℕ)` under explicit tail convergence, plus `GlobalInfiniteZeroWeilCertificate`. |
| **Gate 4 (`evanescentQfimExperimentalValidation`)** | Physical Sharoglazova–Klaers evanescent speed and Dual-Schubert QFIM claims lacked a dedicated certificate bridging `DualSchubertQFIM.sharoglazova_klaers_evanescent_speed_law` and `ControlledMeasurement`. | Define `EvanescentQfimExperimentalCertificate` tying `(ℏ, m, E_abs, J₀, x)` and `ControlledMeasurement` calibration to `sharoglazova_klaers_evanescent_speed_law`, and prove **`SatoRiemannSpectralPendingBoundary.solved_of_certificates`**. |
| **Overlap Closure (`ToupinCelestialMillenniumPendingBoundary`)** | Embedded `rhBoundary` and `yangMillsContinuumSpectralTransferBridge` independently of `YangMillsMassGapHiggsCPTPendingBoundary` and `SatoRiemannSpectralPendingBoundary`. | Define `MeyerFrechetToGnsCertificate` and `BsdHigherRankEulerCertificate`; reuse `RiemannHypothesisCertificates`, `ContinuumYangMillsOSCertificate`, and `CelestialConfiningSpectralCertificate` to prove **`ToupinCelestialMillenniumPendingBoundary.solved_of_certificates`**. |

---

## 2. Phased Workstreams (`SRS-1` Through `SRS-5`)

### `SRS-1`: Axiom-Free Finite-Dimensional `FredholmDetTheory` & Critical-Line `det₃` Anomaly
- **Files:** `src/signals/Signals/SatoGrassmannian/CarlemanWeierstrass.lean`, `src/signals/Signals/SatoGrassmannian/DeterminantBundle.lean`
- **Deliverables (Zero `sorry`):**
  1. `det1Diag_mul`, `det1Diag_single`: prove exact $\ell^1$ trace-class multiplicativity and rank-1 scaling for `detKDiag 1`.
  2. `det3Diag_mul_anomaly`, `det3_eulerPrimes_critical_line_anomaly`: prove cubic $\ell^3$ summability of $ab(a+b+\tfrac{1}{2}ab)$ and the exact order-3 Carleman multiplicative anomaly directly on $\operatorname{Re}(s) = 1/2$.
  3. `instFredholmDetTheoryOfFiniteDimensional`: construct an axiom-free `FredholmDetTheory P eP eM` instance whenever `[FiniteDimensional ℂ P.HPlus]` via `LinearMap.det` and `Matrix.det_diagonal`.
- **Gate:** `make signals_build` passes with zero errors and zero `sorry`.

### `SRS-2`: Infinite-Series $L^1(\mathbb{R})$ Weil Positivity & Bridge Theorems
- **Files:** `src/signals/Signals/SatoGrassmannian/WeilGaussianL1.lean`, `src/signals/Signals/SatoGrassmannian/RiemannSpectralBridge.lean`
- **Deliverables (Zero `sorry`):**
  1. `AdmissibleL1All`, `admissibleL1All_gaussianCombo`, `norm_mellinTransform_shiftedGaussian_strip`: prove uniform super-Gaussian decay $\lVert\mathcal{M}_{g_a}(z)\rVert \le \sqrt{2\pi}\exp(-\operatorname{Re}(z)^2/2 + B^2/2 + |a|B)$ on horizontal strips $\lvert\operatorname{Im}(z)\rvert \le B$.
  2. `weilInfiniteSum`, `weilInfiniteSum_nonneg_of_allRealZeros`, `weilInfiniteSum_neg_of_offline_pair_tail_lt`: prove infinite-series critical-line nonnegativity and tail-dominated off-line negativity for countably infinite zero sequences `(z : ℕ → ℂ, m : ℕ → ℕ)`.
  3. `det3_critical_line_and_li_cayley_bridge` and `weil_infinite_real_vs_evanescent_qfim_bridge` in `RiemannSpectralBridge.lean`.
- **Gate:** `make signals_build` passes with zero errors and zero `sorry`.

### `SRS-3`: Unified Constructive Certificate Solvers in `Signals.Pending`
- **Files:** `src/signals/Signals/Pending.lean`, `src/signals/SignalsPending.lean`, `src/signals/SignalsTests.lean`, `src/signals/SignalsPendingTests.lean`
- **Deliverables (Zero `sorry`):**
  1. Define `DeBruijnNewmanUpperCertificate`, `AdelicSatoTraceLimitCertificate`, `GlobalWeilLiJensenCertificate`, `SelfAdjointSpectralOperatorCertificate`, `RiemannHypothesisPendingBoundary.ofCertificates`, and **`RiemannHypothesisPendingBoundary.solved_of_certificates`**.
  2. Define `LidskiiFredholmDetCertificate`, `GlobalInfiniteZeroWeilCertificate`, `EvanescentQfimExperimentalCertificate`, `SatoRiemannSpectralPendingBoundary.ofCertificates`, and **`SatoRiemannSpectralPendingBoundary.solved_of_certificates`**.
  3. Define `MeyerFrechetToGnsCertificate`, `BsdHigherRankEulerCertificate`, `ToupinCelestialMillenniumPendingBoundary.ofCertificates`, and **`ToupinCelestialMillenniumPendingBoundary.solved_of_certificates`** (reusing `ContinuumYangMillsOSCertificate` and `CelestialConfiningSpectralCertificate`).
  4. Add `@[blueprint]` lemmas in `SignalsPending.lean` and regression examples in `SignalsTests.lean` and `SignalsPendingTests.lean`.
- **Gate:** `make signals_build` succeeds with zero `sorry`.

### `SRS-4`: Rust/PyO3 & SymPy/`mpmath` Audits
- **Files:** `src/signals/numerical_adapter/src/sato_grassmannian.rs`, `src/signals/numerical_adapter/src/lib.rs`, `sustainablefactory/sato_grassmannian.py`, `tests/test_sato_grassmannian_sympy_pyo3.py`
- **Deliverables:**
  1. `evaluate_carleman_det3_anomaly` & `py_audit_carleman_det3_anomaly`: audit `det3Diag_mul_anomaly` at $\sigma = 1/2, t = \gamma_1$ and `det1Diag_mul` at $\sigma = 2.0$.
  2. `evaluate_weil_infinite_tail_audit` & `py_audit_weil_infinite_tail`: verify infinite-tail Weil convergence on the first 30 true Riemann zeros plus off-line witness dominance below $-4\pi$.
  3. `evaluate_finite_dim_fredholm_det` & `py_audit_finite_dim_fredholm_det`: cross-check `detFr_rankOne_nilpotent_eq_one`, `detFr_blockLowerTriangular_two`, and similarity invariance on a truncated Hardy matrix.
  4. Exact SymPy proofs + 40-digit `mpmath` cross-checks in `pytest`.
- **Gate:** `cargo test`, `maturin develop --release`, and `pytest -q tests/test_sato_grassmannian_sympy_pyo3.py` all pass.

### `SRS-5`: Documentation Integration, Sphinx HTML Check, & Commit
- **Files:** `docs/grassmannian-sato-adelic-carleman-weierstrass-weil-rh-gaps-paper.md`, `docs/grassmannian-sato-hilbert-space-kp-pde-solver-akns-qfim-paper.md`, `docs/grassmannian-celestial-holography-graviton-turner-riemann-paper.md`, `docs/plan-index.md`, `docs/_toc.yml`
- **Gate:** Zero Markdown scanner findings, `make -C docs html` clean, browser inspection confirms MathJax rendering and zero `mjx-merror`, `git diff --check` clean.

### `SRS-6` & `SRS-7`: Unified Extension (Finite-Rank Axiom-Free `finiteRankDet` & Strip Sub-Gaussian `WeilGaussianL1`)
Integrated with [unified-pending-closure-roadmap-plan.md](unified-pending-closure-roadmap-plan.md):
- **`SRS-6` (`DeterminantBundle.lean`, `SegalWilsonGr24.lean`):** Prove `finiteRankDet` on arbitrary infinite-dimensional `HPlus` via $V(F) = \operatorname{range} F \sqcup (\ker F)^\perp$, prove agreement with `instFredholmDetTheoryOfFiniteDimensional` (`finiteRankDet_eq_detFr_of_finiteDimensional`), and discharge `segalWilson_tau_gr24_eq_tauU_axiomFree` without `[FredholmDetTheory]`.
- **`SRS-7` (`WeilGaussianL1.lean`, `Pending.lean`):** Prove `norm_mellinTransform_gaussianCombo_strip` and `summable_weilInfinite_gaussianCombo_of_strip` so `StripGaussianWeilCertificate` / `GlobalInfiniteZeroWeilCertificate.ofStripGaussian` drops per-function `hSumm` and joins `MasterUnifiedPendingClosure`.

---

## References

```{bibliography}
:filter: docname in docnames
```
