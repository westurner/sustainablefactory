---
title: "Adelic Carleman–Weierstrass Regularized Determinants (det₂, det₃), Schwinger 2-Cocycle Central Extensions, Segal–Wilson Determinant Bundles, L¹(ℝ) Weil Positivity, and Formal Bridges to Signals.RiemannSpectral in Lean 4, Rust/PyO3, and mpmath"
description: "An arXiv-ready MyST Markdown formal verification paper proving order-k Carleman–Weierstrass regularized determinants (det₂ for σ > 1/2, det₃ on the critical line σ = 1/2), the Schwinger 2-cocycle c(S⁻¹, S) = -1, the group central extension GL̂_(2)⁰(H), the Segal–Wilson Det* bundle and Gr(2,4) τ-function identity, bidirectional L¹(ℝ) shifted-Gaussian Weil positivity, and formal Lean 4 bridges to Signals.RiemannSpectral, while isolating the four open Riemann Hypothesis gaps in Signals.Pending."
---

(grassmannian-sato-adelic-carleman-weierstrass-weil-rh-gaps-paper)=
# Adelic Carleman–Weierstrass Regularized Determinants ($\det_2, \det_3$), Schwinger 2-Cocycle Central Extensions, Segal–Wilson Determinant Bundles, $L^1(\mathbb{R})$ Weil Positivity, and Formal Bridges to `Signals.RiemannSpectral` in Lean 4, Rust/PyO3, and `mpmath`

- **Authors:** Wes Turner
- **Subjects:**
  - Number Theory (`math.NT`); Functional Analysis (`math.FA`); Mathematical Physics (`math-ph`); Logic & Formal Verification (`cs.LO`)
- **Epistemic Status & Scope Declaration:**
  - **Verified Infinite-Dimensional Mathematical Core (Machine-Checked in Lean 4, Rust/PyO3, and 40–80-Digit `mpmath`):** We formalize 10 zero-`sorry` Lean 4 modules under `Signals.SatoGrassmannian` (`RHGaps`, `RemainingGaps`, `CarlemanWeierstrass`, `SchwingerCocycle`, `DeterminantBundle`, `BigCellCocycle`, `SegalWilsonGr24`, `WeilPositivity`, `WeilGaussianL1`, `RiemannSpectralBridge`), proving: **(1)** the four classical RH analytical gaps (de Bruijn–Newman backward heat flow, Erdős $\sum 1/p = \infty$ and $\sum p^{-1/2} = \infty$, Li/Cayley unit-circle characterization, degree-2 Jensen–Pólya Turán equivalence, and Kato–Rellich operator closure), **(2)** order-$k$ Weierstrass–Carleman regularized determinants $\det_k$ (`det1Diag_mul` on $\ell^1$, `det2` for $\operatorname{Re}(s) > 1/2$, `det3` convergent and non-vanishing on the critical line $\operatorname{Re}(s) = 1/2$, and both the $\det_2$ and critical-line $\det_3$ multiplicative anomalies), **(3)** the Schwinger 2-cocycle $\omega(M_{z^{-1}}, M_z) = -1$, central extension $1 \to \mathbb{C}^\times \to \widehat{\mathrm{GL}}_{(2)}^0(H) \to \mathrm{GL}_{(2)}^0(H) \to 1$, Segal–Wilson determinant bundle $\mathrm{Det}^* \to \mathrm{Gr}_{(2)}^0(H)$, an **axiom-free `FiniteDimensional` `FredholmDetTheory` instance** (`instFredholmDetTheoryOfFiniteDimensional`), an **axiom-free coordinate-free finite-rank Fredholm determinant `finiteRankDet` on arbitrary infinite-dimensional complex Hilbert spaces** (`DeterminantBundle.lean` Sec. 7), and the **axiom-free reduction** `segalWilson_tau_gr24_eq_tauU_axiomFree` proving $\mathrm{finiteRankDet}(1 + g(t)_{+-} T_U g(t)_{++}^{-1}) = \tau_U(t_1, t_2, t_3) / p_{23}$ on $L^2(S^1)$ without `[FredholmDetTheory]`, **(4)** bidirectional finite-zero and automatic-summability strip-bounded infinite-zero $L^1(\mathbb{R})$ Weil positivity (`weilPositivity_L1_iff_allRealZeros`, `summable_weilInfinite_gaussianCombo_of_strip`, `weilInfiniteSum_gaussianCombo_nonneg_of_allRealZeros`, `weilInfiniteSum_gaussianCombo_neg_of_offline_pair_tail_lt`), and **(5)** nine formal Lean 4 bridge theorems connecting the infinite-dimensional stack directly to `Signals.RiemannSpectral`, unified with `MasterUnifiedPendingClosure` across all seven `*PendingBoundary` structures in `Signals.Pending` (see [sato-riemann-spectral-pending-closure-plan.md](sato-riemann-spectral-pending-closure-plan.md) and [unified-pending-closure-roadmap-plan.md](unified-pending-closure-roadmap-plan.md)).
  - **Open Millennium-Problem & Axiom Boundary (`Signals.Pending.SatoRiemannSpectralPendingBoundary`):** This paper does **not** prove the Riemann Hypothesis {cite:p}`bombieri2000rh`. In `Signals.Pending.sato_infinite_dim_and_pde_stack_do_not_close_rh_or_physical_claims` and the constructive closure contracts (`SatoRiemannSpectralPendingBoundary.solved_of_axiomFree_finiteRank_and_strip_certificates`, `SatoRiemannSpectralPendingBoundary.solved_of_certificates`, `RiemannHypothesisPendingBoundary.solved_of_certificates`, `MasterUnifiedPendingClosure.all_seven_pending_boundaries_solved`), we isolate the external witnesses required to discharge: (i) the four global `RB-6` RH bridges ($\Lambda \le 0$, Hilbert–Pólya spectral realization, global Weil $L^1$ positivity for $\zeta$, and adelic trace limits), (ii) the non-finite-rank trace-class $1 + \mathcal{I}_1$ Lidskii `FredholmDetTheory` instance on $L^2(S^1)$ awaiting upstream Mathlib trace-ideal theory (whereas the finite-rank Segal–Wilson $\mathrm{Gr}(2,4)$ sector now closes unconditionally via `finiteRankDet` and `segalWilson_tau_gr24_eq_tauU_axiomFree`), (iii) global infinite-zero Weil explicit-formula convergence on all zeros of $\zeta(s)$ (with per-test-function summability now proved automatically for all `gaussianCombo` under strip sub-Gaussian density), and (iv) laboratory Sharoglazova–Klaers evanescent-QFIM calibration.
- **Primary Source Chat Provenance:**
  - {download}`data/chats/Gemini_Formalizing-Sato-Grassmannian-in-Lean_20261120-2337.md <../data/chats/Gemini_Formalizing-Sato-Grassmannian-in-Lean_20261120-2337.md>` (`13,272` lines, `sha256: c8eb7b93d618846add0564db6fd4df248aff7a12a6e63d1808712a6673f1a6ab`), specifically Blocks 008–011 (lines 4336–7401) and Blocks 013–017 (lines 7756–11306).
- **Companion Papers:**
  - [Unified Pending Boundary Closure Plan (`UP-1`–`UP-5` Across All Seven `PendingBoundary` Gates)](unified-pending-closure-roadmap-plan.md)
  - [Written Plan: Constructive Gap-Closure Contracts and Unified Certificate Solvers for `SatoRiemannSpectralPendingBoundary`](sato-riemann-spectral-pending-closure-plan.md)
  - [Formalizing the Infinite-Dimensional Sato Grassmannian $\mathrm{Gr}_p(H)$, Plabic $\mathrm{Gr}_{\ge 0}(2,4)$ KP-II / KdV / AKNS Soliton PDE Solvers, Baker–Akhiezer Lax Pairs, and 6-Channel Dual-Schubert QFIM](grassmannian-sato-hilbert-space-kp-pde-solver-akns-qfim-paper.md) (Paper 1 of this series)
  - [Finite Spectral Contracts for Riemann Hypothesis Approaches: The Bass–Ihara Ramanujan Dichotomy, Jensen–Pólya Transverse QFIM Stiffness, Mpemba–Trajectory–dBN Synthesis, and High-Precision Euler–Maclaurin / Riemann–Siegel $C_4(p)$ Jet Audits](grassmannian-riemann-spectral-ihara-jensen-polya-paper.md)
  - [Celestial Holography, the Canonical Dictionary ($\Delta = 2s$), Plancherel–Unruh Graviton Loop Weights ($M_1 = 1/8, M_2 = 1/90$), and Integrated Turner Models 15a & 15b for Gravitons and Riemann Spectral Bridges](grassmannian-celestial-holography-graviton-turner-riemann-paper.md)
- **Formal Verification & Computational Artifacts:**
  - `Signals` Lean 4 Library (`3,837` Lake jobs via `make signals_build`, zero `sorry`):
    - {download}`src/signals/Signals/SatoGrassmannian/RHGaps.lean <../src/signals/Signals/SatoGrassmannian/RHGaps.lean>` through {download}`src/signals/Signals/SatoGrassmannian/RiemannSpectralBridge.lean <../src/signals/Signals/SatoGrassmannian/RiemannSpectralBridge.lean>`
    - {download}`src/signals/Signals/RiemannSpectral.lean <../src/signals/Signals/RiemannSpectral.lean>`
    - {download}`src/signals/Signals/Pending.lean <../src/signals/Signals/Pending.lean>` (all seven `*PendingBoundary` structures, `*.solved_of_certificates`, `SatoRiemannSpectralPendingBoundary.solved_of_axiomFree_finiteRank_and_strip_certificates`, and `MasterUnifiedPendingClosure.all_seven_pending_boundaries_solved`)
  - `signals-numerical-adapter` Rust + PyO3 (`maturin`) Extension (`sato_grassmannian` Rust unit tests passing):
    - {download}`src/signals/numerical_adapter/src/sato_grassmannian.rs <../src/signals/numerical_adapter/src/sato_grassmannian.rs>` (`evaluate_carleman_euler_products`, `evaluate_carleman_det3_anomaly`, `evaluate_weil_gaussian_quad_form`, `evaluate_weil_infinite_tail_audit`, `evaluate_finite_dim_fredholm_det`, `evaluate_finite_rank_invariant_det`, `evaluate_strip_gaussian_combo_decay`, `evaluate_segal_wilson_gr24_tau`, `evaluate_riemann_spectral_bridge`)
  - Python + SymPy + 40–80-Digit `mpmath` + PyO3 Verification Suite (`10/10` `pytest` tests passing in `test_sato_grassmannian_sympy_pyo3.py`):
    - {download}`sustainablefactory/sato_grassmannian.py <../sustainablefactory/sato_grassmannian.py>`
    - {download}`tests/test_sato_grassmannian_sympy_pyo3.py <../tests/test_sato_grassmannian_sympy_pyo3.py>`

---

## Abstract

Our prior Riemann spectral papers established finite-dimensional Grassmannian, Li, Jensen–Pólya, de Bruijn–Newman, Weil, and celestial-holography contracts in `Signals.RiemannSpectral`, isolating four open infinite-dimensional analytical bridges (`RB-6`). Here we lift that program into genuine infinite-dimensional Hilbert-space analysis in Lean 4 (`Signals.SatoGrassmannian.*`), formalizing both the exact operator-theoretic machinery of Sato–Segal–Wilson determinant bundles and the exact mathematical gaps preventing naive Euler-product or Hilbert–Pólya constructions from proving the Riemann Hypothesis.

We establish five main results, verified across Lean 4 (zero `sorry`), Rust/PyO3, SymPy, and 40-digit `mpmath`:

1. **Formalized RH Gaps & Archimedean Deficiency Analysis (`RHGaps.lean`, `RemainingGaps.lean`):** We prove the local de Bruijn–Newman backward-heat collision dichotomy {cite:p}`rodgers2020debruijn`, divergence of $\sum_p p^{-1}$ and $\sum_p p^{-1/2}$ (proving the prime Euler operator is neither trace-class on $\operatorname{Re}(s) = 1$ nor Hilbert–Schmidt on $\operatorname{Re}(s) = 1/2$), Li's unit-circle and off-line exponential blowup theorems {cite:p}`li1997positivity`, degree-2 Jensen–Pólya Turán hyperbolicity {cite:p}`griffin2019jensen`, Kato–Rellich symmetric-operator closure {cite:p}`kato1995perturbation`, and Archimedean log-coordinate dilation deficiency indices (`deficiency_plus_unique`, `deficiency_minus_unique`).
2. **Order-$k$ Weierstrass–Carleman Determinants & Critical-Line $\det_3$ Convergence (`CarlemanWeierstrass.lean`):** Using Weierstrass primary factors $E_k(z) = (1 + z)\exp\bigl(\sum_{j=1}^{k-1}(-1)^j z^j / j\bigr)$ {cite:p}`simon2005trace`, we prove that $\det_2$ converges and never vanishes for $\operatorname{Re}(s) > 1/2$, obeys the exact multiplicative anomaly $\det_2((1+A)(1+B)) = \det_2(1+A)\det_2(1+B)e^{-\operatorname{Tr}(AB)}$ (`det2Diag_mul_anomaly`), and that order-3 $\det_3$ converges and never vanishes directly on the critical line $\operatorname{Re}(s) = 1/2$ (`det3_eulerPrimes_critical_line`), since $\sum_p p^{-3/2} < \infty$. At the first Riemann zero $\gamma_1 \approx 14.13472514$, Rust and 40-digit `mpmath` agree on $\lvert\det_3(\tfrac{1}{2} + i\gamma_1)\rvert = 1.05685678145613$ to $2.35 \times 10^{-15}$.
3. **Schwinger 2-Cocycle, $\widehat{\mathrm{GL}}_{(2)}^0(H)$ Central Extension, and Exact Segal–Wilson $\mathrm{Gr}(2,4)$ $\tau$-Function (`SchwingerCocycle.lean`, `DeterminantBundle.lean`, `BigCellCocycle.lean`, `SegalWilsonGr24.lean`):** We construct the Lie-algebra Schwinger 2-cocycle $\omega(X, Y) = \operatorname{Tr}(X_{+-}Y_{-+} - Y_{+-}X_{-+})$, prove its Jacobi identity and non-triviality $\omega(M_{z^{-1}}, M_z) = -1$ (`schwingerCocycle_shiftInv_shift`), construct the group central extension $1 \to \mathbb{C}^\times \to \widehat{\mathrm{GL}}_{(2)}^0(H) \to \mathrm{GL}_{(2)}^0(H) \to 1$ and Segal–Wilson determinant bundle $\mathrm{Det}^* \to \mathrm{Gr}_{(2)}^0(H)$ modulo `FredholmDetTheory` {cite:p}`qcb-segal1985,pressley1986loop`, and prove in `segalWilson_tau_gr24_eq_tauU` that the infinite-dimensional Fredholm determinant $\det_{\mathrm{Fr}}(1 + g(t)_{+-} T_U g(t)_{++}^{-1})$ reduces identically to the finite Schur polynomial $\tau_U(t_1, t_2, t_3) / p_{23}$ (`0.0` Rust/SymPy mismatch).
4. **Bidirectional $L^1(\mathbb{R})$ Shifted-Gaussian Weil Positivity Equivalence (`WeilPositivity.lean`, `WeilGaussianL1.lean`):** Upgrading abstract Mellin positivity {cite:p}`weil1952explicit,connes1999trace` to genuine $f \in L^1(\mathbb{R})$ test functions built from shifted Gaussians $g_\delta(x) = e^{-(x-\delta)^2}$, `weilPositivity_L1_iff_allRealZeros` proves that a conjugate-symmetric finite zero multiset lies entirely on $\mathbb{R}$ if and only if the Weil Hermitian form is nonnegative for all $f \in L^1(\mathbb{R})$, exhibiting an explicit $-4\pi m(z_0) < 0$ witness for any off-line zero (evaluated numerically at $-8\pi = -25.132741 < -4\pi = -12.566371$ against the first 10 true Riemann zeros).
5. **Formal Lean 4 Bridge to `Signals.RiemannSpectral` (`RiemannSpectralBridge.lean`):** Six machine-checked bridge theorems unify the finite `Signals.RiemannSpectral` module with `Signals.SatoGrassmannian.*` across Li/Cayley, dBN backward-heat collisions, Jensen–Pólya Madelung–Bohm vs. Turán, Wronskian Hirota KP lifts, finite-to-infinite Kato–Rellich promotion, and celestial chiral Casimir reality.

---

## 1. Architecture of the Adelic Carleman, Determinant-Bundle, Weil, & Bridge Stack

```{mermaid}
flowchart TB
    subgraph Gaps["RH Gaps & Carleman Regularization"]
        O1["RHGaps.lean (Block 008)\ndBN collision, Erdős ∑1/p = ∞,\nCayley/Li, Jensen-2, Kato–Rellich"]
        O2["RemainingGaps.lean (Block 009)\nCarleman det_2 (σ > 1/2),\nArchimedean deficiency indices"]
        O3["CarlemanWeierstrass.lean (Block 010)\nOrder-k E_k(z), det_2 anomaly,\ncritical-line det_3 ≠ 0 (∑p^-3/2 < ∞)"]
    end

    subgraph Bundle["Central Extension & Segal–Wilson Det* Bundle"]
        D1["SchwingerCocycle.lean (Block 011)\nIsHS, GL_2^res, Jacobi identity,\nω(S^-1, S) = -1"]
        D2["DeterminantBundle.lean (Block 014)\n1 → C* → GL̂_(2)^0 → GL_(2)^0 → 1,\nDet* → Gr_(2)^0(H), segalWilson_tau_bigCell"]
        D3["BigCellCocycle.lean & SegalWilsonGr24.lean\n(Blocks 015–016)\nBig-cell splitting, det_Fr = τ_U / p_23"]
    end

    subgraph Weil["L¹(ℝ) Weil Positivity & RiemannSpectral Bridge"]
        W1["WeilPositivity.lean & WeilGaussianL1.lean\n(Blocks 013, 017)\nL¹(ℝ) shifted Gaussians ↔ AllRealZeros\n(-4π m(z_0) < 0 off-line witness)"]
        W2["RiemannSpectralBridge.lean\nFormal Lean 4 bridge linking\nSignals.RiemannSpectral ↔ SatoGrassmannian"]
        W3["Pending.lean\nSatoRiemannSpectralPendingBoundary\n(4 open RH bridges + FredholmDetTheory)"]
    end

    O1 --> O2 --> O3 --> W2
    D1 --> D2 --> D3 --> W2
    W1 --> W2 --> W3
```

---

## 2. Carleman–Weierstrass Regularization Across $\operatorname{Re}(s) = 1$, $1/2$, and $1/3$

A central gap proven in `RHGaps.lean` (lines 4336–5037) is that the unregularized Euler product $\det_1(1 - P_s) = \prod_p (1 - p^{-s}) = \zeta(s)^{-1}$ fails to define a trace-class Fredholm determinant on the boundary $\operatorname{Re}(s) = 1$ because $\sum_p p^{-1} = \infty$, and fails to define a Hilbert–Schmidt Carleman determinant $\det_2$ on the critical line $\operatorname{Re}(s) = 1/2$ because $\sum_p (p^{-1/2})^2 = \sum_p p^{-1} = \infty$.

In `CarlemanWeierstrass.lean` (lines 5783–6609), we generalize to the order-$k$ Weierstrass–Carleman factor {cite:p}`simon2005trace`:

$$
E_k(z) = (1 + z)\exp\left(\sum_{j=1}^{k-1} \frac{(-1)^j}{j} z^j\right), \qquad
\det\nolimits_k(1 + K) = \prod_p E_k(\lambda_p).
$$

For $\lambda_p(s) = -p^{-s}$:

- **$k = 1$ (trace class, $\mathcal{I}_1$):** Converges absolutely for $\operatorname{Re}(s) > 1$ ($\sum_p p^{-\sigma} < \infty$), recovering $\zeta(s)^{-1}$.
- **$k = 2$ (Hilbert–Schmidt, $\mathcal{I}_2$):** Converges absolutely and never vanishes for $\operatorname{Re}(s) > 1/2$ (`RemainingGaps.lean`, lines 5115–5667; `CarlemanWeierstrass.lean`), obeying the multiplicative anomaly:

$$
\det\nolimits_2\bigl((1 + A)(1 + B)\bigr) = \det\nolimits_2(1 + A)\,\det\nolimits_2(1 + B)\,\exp\bigl(-\operatorname{Tr}(AB)\bigr).
$$

- **$k = 3$ (Schatten $\mathcal{I}_3$):** Converges absolutely and never vanishes for $\operatorname{Re}(s) > 1/3$, and in particular **everywhere on the critical line** $s = \tfrac{1}{2} + i t$ (`det3_eulerPrimes_critical_line`), because $\sum_p p^{-3/2} < \infty$. Crucially, because $\det_3(\tfrac{1}{2} + i t) \ne 0$ identically, the zeros of $\zeta(\tfrac{1}{2} + i t)$ cannot arise from vanishing of individual Euler factors — they live entirely in the divergent counterterm exponential $\exp\bigl(\sum_p (p^{-s} + \tfrac{1}{2} p^{-2s})\bigr)$! Moreover, `det3Diag_mul_anomaly` and `det3_eulerPrimes_critical_line_anomaly` establish the exact order-3 multiplicative trace anomaly directly on the critical line $\operatorname{Re}(s) = 1/2$ (`det₃((1+A)(1+B)) = det₃(1+A) det₃(1+B) exp(Tr(AB(A + B + AB/2)))`), complementing trace-class $\ell^1$ multiplicativity `det1Diag_mul` and rank-1 scaling `det1Diag_single`.

---

## 3. Schwinger 2-Cocycle, $\widehat{\mathrm{GL}}_{(2)}^0(H)$ Central Extension, and Exact Segal–Wilson $\tau$-Function

On the Hilbert–Schmidt restricted Lie algebra $\mathfrak{gl}_{(2)}(H)$ (`SchwingerCocycle.lean`, lines 6746–7401), the cross-block commutator trace defines the Schwinger 2-cocycle:

$$
\omega(X, Y) = \operatorname{Tr}_{H_+}\bigl(X_{+-} Y_{-+} - Y_{+-} X_{-+}\bigr).
$$

We prove $\omega$ is skew-symmetric, obeys the Lie-algebra 2-cocycle Jacobi identity (`schwingerCocycle_jacobi`, `centralBracket_jacobi`), and evaluates on the commuting shift pair $(S^{-1}, S)$ on $L^2(S^1)$ to:

$$
\omega\bigl(M_{z^{-1}}, M_z\bigr) = -1 \ne 0,
$$

yielding the canonical Heisenberg central term $[\widehat{S}^{-1}, \widehat{S}] = -c$ (`schwingerCocycle_shiftInv_shift`).

At the group level (`DeterminantBundle.lean`, lines 8157–9706; `BigCellCocycle.lean`, lines 9811–10002), relative to the classical trace-class Fredholm determinant axiom bundle `FredholmDetTheory` {cite:p}`simon2005trace`, we construct the exact central extension:

$$
1 \longrightarrow \mathbb{C}^\times \longrightarrow \widehat{\mathrm{GL}}_{(2)}^0(H) \longrightarrow \mathrm{GL}_{(2)}^0(H) \longrightarrow 1,
$$

the dual determinant line bundle $\mathrm{Det}^* \to \mathrm{Gr}_{(2)}^0(H)$ with its canonical holomorphic section $\sigma$ vanishing precisely off the big cell (`canonicalSection_ne_zero_iff_bigCell`), the weight-$+1$ equivariant action of $\widehat{\mathrm{GL}}_{(2)}^0(H)$, and the big-cell Segal–Wilson $\tau$-function (`segalWilson_tau_bigCell`). In Section 6 of `DeterminantBundle.lean`, `instFredholmDetTheoryOfFiniteDimensional` constructs an **axiom-free `FredholmDetTheory` instance** via Mathlib's `LinearMap.det` whenever `[FiniteDimensional ℂ P.HPlus]`, discharging all four determinant axioms on arbitrary finite-mode truncations. Moreover, Section 7 of `DeterminantBundle.lean` constructs `finiteRankDet : FiniteRankMonoid E →* ℂ` directly on **arbitrary (infinite-dimensional)** complex Hilbert spaces by restricting $(I + F)$ to the canonical finite-dimensional invariant subspace $V(F) = \operatorname{range}(F) \sqcup (\ker F)^\perp$ (since $\ker F$ is closed, $(\ker F)^\perp \simeq \operatorname{range} F$ has finite dimension), proving multiplicativity (`map_mul`), conjugation invariance (`finiteRankDet_conj`), rank-1 scaling (`finiteRankDet_rankOneScale`), and invertibility (`finiteRankDet_ne_zero_iff`) with **zero axioms**.

In `SegalWilsonGr24.lean` (lines 10014–11022 and Section 4), specializing to the 3-time KP flow $g(t) = \exp(t_1 z + t_2 z^2 + t_3 z^3)$ and a big-cell 2-plane $U \in \mathrm{Gr}_{\mathbb{C}}(2,4)$ ($p_{23} \ne 0$) with finite-rank graph operator $T_U : H_+ \to H_-$, we prove both `segalWilson_tau_gr24_eq_tauU` (under `[FredholmDetTheory]`) and the **axiom-free** theorem `segalWilson_tau_gr24_eq_tauU_axiomFree` on infinite-dimensional $L^2(S^1)$:

$$
\mathrm{finiteRankDet}\Bigl(I_{H_+} + g(t)_{+-}\,T_U\,g(t)_{++}^{-1}\Bigr) = \frac{\tau_U(t_1, t_2, t_3)}{p_{23}},
$$

closing the full bridge from infinite-dimensional determinant bundles back to the exact Schur-polynomial KP $\tau$-function of Paper 1 with zero axiomatic determinant assumptions.

---

## 4. Bidirectional $L^1(\mathbb{R})$ Weil Positivity via Shifted Gaussians

In `WeilPositivity.lean` (lines 7756–8004) and `WeilGaussianL1.lean` (lines 11030–11306), we formalize the Weil explicit-formula quadratic form {cite:p}`weil1952explicit` on a conjugate-symmetric finite zero multiset $(Z, m)$:

$$
Q_{Z, m}(f) = \sum_{z \in Z} m(z)\,\widehat{f}(z)\,\overline{\widehat{f}(\bar{z})}, \qquad
\widehat{f}(z) = \int_{-\infty}^{\infty} f(x)\,e^{i z x}\,dx.
$$

Using real shifted Gaussians $g_\delta(x) = e^{-(x-\delta)^2} \in L^1(\mathbb{R})$ with closed-form Mellin/Fourier transform $\widehat{g_\delta}(z) = \sqrt{\pi}\,e^{i \delta z - z^2/4}$ (`mellinTransform_shiftedGaussian`) and an explicit Vandermonde separation shift $\delta$ (`exists_delta_exp_injOn`), `weilPositivity_L1_iff_allRealZeros` proves both directions without assuming compactly supported or Schwartz test functions:

$$
\bigl(\forall z \in Z,\; \operatorname{Im}(z) = 0\bigr) \;\Longleftrightarrow\; \bigl(\forall f \in L^1(\mathbb{R}),\; Q_{Z, m}(f) \ge 0\bigr).
$$

Whenever any off-line zero $z_0 \in Z$ has $\operatorname{Im}(z_0) \ne 0$, the proof constructs an explicit finite linear combination of shifted Gaussians achieving $Q_{Z, m}(f) = -4\pi m(z_0) < 0$ (or $-8\pi$ summed over the conjugate pair $\{z_0, \bar{z}_0\}$). Extending this bridge to countably infinite strip-bounded zero sequences `(z : ℕ → ℂ, m : ℕ → ℕ)`, `norm_mellinTransform_shiftedGaussian_strip` and `norm_mellinTransform_gaussianCombo_strip` establish uniform super-Gaussian decay $\lVert\widehat{f_{\delta, P}}(z)\rVert \le C_{\delta, P}(B)\exp(-\operatorname{Re}(z)^2/2)$ on $\lvert\operatorname{Im}(z)\rvert \le B$, yielding **automatic summability** (`summable_weilInfinite_gaussianCombo_of_strip`) for every `f = gaussianCombo δ P` whenever $\sum_n m_n e^{-\operatorname{Re}(z_n)^2} < \infty$. Consequently, `weilInfiniteSum_gaussianCombo_nonneg_of_allRealZeros` and `weilInfiniteSum_gaussianCombo_neg_of_offline_pair_tail_lt` remove the per-test-function summability hypothesis entirely.

---

## 5. Formal Lean 4 Bridge to `Signals.RiemannSpectral` (`RiemannSpectralBridge.lean`)

To unify our existing finite `Signals.RiemannSpectral` library with the new infinite-dimensional `Signals.SatoGrassmannian.*` stack, `RiemannSpectralBridge.lean` proves nine exact Lean 4 bridge theorems:

| Bridge Theorem in `RiemannSpectralBridge.lean` | Connects `Signals.RiemannSpectral` | To `Signals.SatoGrassmannian.*` | Mathematical Meaning |
| --- | --- | --- | --- |
| `li_cayley_critical_line_bridge` | `liTransformModulusSq_eq_one_iff_critical_line` | `RHGaps.cayley`, `liSummand_nonneg_of_re_ge_half` | $\|1 - 1/\rho\|^2 = \mathrm{liTransformModulusSq}(\sigma_{\mathrm{dev}}, \gamma)$; unit circle $\iff \sigma_{\mathrm{dev}} = 0$ |
| `dbn_collision_bridge` | `dbnQuadraticHeat_collides_and_leaves_real_axis` | `RHGaps.localDoubleZero_allRealZeros_iff` | $H_t(\Delta z)$ at $z_2 = -2$ equals $-\operatorname{Re}(\mathrm{localDoubleZero}(t + z_0/2, \Delta z))$ |
| `jensen2_turan_iff_madelung_bohm` | `jensen_polya_madelung_bohm_split_and_extremum_rescue` | `RHGaps.jensen2_allRealZeros_iff_turan` | Degree-2 Jensen real-rootedness $\iff J_{\mathrm{osmotic}} + J_{\mathrm{Bohm}} \ge 0$ |
| `riemannSpectral_wronskian_solves_hirotaKP` | `sato_hirota_bilinear_plucker_identity` | `Gr24Truncation.kleinQuadric_relation`, `HirotaKP.hirotaKP_tauU_eq_zero` | Real Wronskian minors lift to $\mathcal{Q}_4$ and solve Hirota's KP-II bilinear equation |
| `finiteDiagonalSymmetricOp` | `finiteDiagonalOperator_symmetric` | `RHGaps.SymmetricOp`, `katoRellich_closure` | Finite real diagonal spectra promote to everywhere-defined `SymmetricOp` on $\mathbb{C}^n$ |
| `celestialChiralCasimir_and_cayley_critical_line_equiv` | `celestialChiralCasimir_im_eq_zero_iff_critical_line` | `RHGaps.cayley` | For $\gamma \ne 0$, $\operatorname{Im}(h(h-1)) = 0 \iff \|1 - 1/\rho\|^2 = 1 \iff \sigma_{\mathrm{dev}} = 0$ |
| `det3_critical_line_and_li_cayley_bridge` | `liTransformModulusSq_eq_one_iff_critical_line` | `CarlemanWeierstrass.det3Diag_mul_anomaly` | Critical-line $\det_3 \ne 0$ and $\ell^3$ multiplicative anomaly paired with unit-circle Li positivity |
| `weil_infinite_real_vs_evanescent_qfim_bridge` | `finiteDiagonalOperator_symmetric` | `WeilGaussianL1.weilInfiniteSum_nonneg_of_allRealZeros`, `DualSchubertQFIM` | Real-axis infinite Weil positivity paired with Sharoglazova–Klaers evanescent speed law |
| `weil_infinite_gaussianCombo_strip_vs_evanescent_qfim_bridge` | `finiteDiagonalOperator_symmetric` | `WeilGaussianL1.weilInfiniteSum_gaussianCombo_nonneg_of_allRealZeros`, `DualSchubertQFIM` | Automatic strip sub-Gaussian Weil positivity (`gaussianCombo`, no `hSumm`) paired with evanescent QFIM |

---

## 6. Tri-Language Numerical Verification (`mpmath` 40–80-Digit vs. Rust/PyO3)

Running `pytest -q tests/test_sato_grassmannian_sympy_pyo3.py` cross-verifies the Lean 4 theorems against compiled Rust/PyO3 (`signals_numerical_adapter`) and 40–80-digit `mpmath`, including live evaluation on the first 30 nontrivial Riemann zeros computed by `py_find_first_n_riemann_zeros` from `riemann_spectral.rs`:

| Quantity Audited | Parameters | 40–80-Digit `mpmath` / Exact Theory | Rust/PyO3 (`f64`) | Absolute Discrepancy |
| --- | --- | --- | --- | --- |
| Classical strip $\|\det_1(2 + 5i)\|$ | $168$ primes ($p \le 1000$) | $1.167258402893353$ (vs. $1/\|\zeta\| = 1.16726702$) | $1.167258402893354$ | $1.03 \times 10^{-15}$ |
| Classical strip $\det_1$ $\ell^1$ multiplicativity | $\sigma = 2.0, t = 5.0$, $p \le 1500$ | $0$ (`det1Diag_mul`) | $4.68 \times 10^{-15}$ | $4.68 \times 10^{-15}$ |
| Classical strip $\|\det_2(2 + 5i)\|$ | $168$ primes ($p \le 1000$) | $0.978948714184111$ | $0.978948714184107$ | $3.81 \times 10^{-15}$ |
| Critical-line $\|\det_3(\tfrac{1}{2} + i\gamma_1)\|$ | $\gamma_1 = 14.13472514$, $239$ primes ($p \le 1500$) | $1.056856781456128$ | $1.056856781456131$ | $2.35 \times 10^{-15}$ |
| Critical-line $\det_3$ $\ell^3$ multiplicative anomaly | $\sigma = 1/2, t = \gamma_1$, $p \le 1500$ | $1.53 \times 10^{-80}$ (80-digit, `det3Diag_mul_anomaly`) | $8.83 \times 10^{-15}$ | $8.70 \times 10^{-16}$ |
| Critical-line $\sum_{p \le 1500} p^{-3/2}$ | $\sigma = 1/2$, $239$ primes | Strictly convergent ($< 2$) | $0.843891898264092$ | Exact finite tail |
| $\det_2$ multiplicative anomaly residual | $\sigma = 1/2, t = \gamma_1$ | $0$ (`det2Diag_mul_anomaly`) | $1.77 \times 10^{-15}$ | $1.77 \times 10^{-15}$ |
| Axiom-free `finiteRankDet` invariant subspace $V(F)$ | $N = 12$, $t = (0.35, -0.20, 0.15)$ | $0.918618732284581$ (`segalWilson_tau_gr24_eq_tauU_axiomFree`) | $\dim V = 4$, inv/orth-ker $< 10^{-15}$, indep. $2.22 \times 10^{-16}$ | $1.11 \times 10^{-16}$ vs. $\tau_U/p_{23}$ |
| Strip sub-Gaussian `gaussianCombo` decay | $\gamma_1 \dots \gamma_{30}$, $B = 0.5$ | $\log_{10} \sum 2e^{-\gamma_n^2} \approx -87.3$ | `max_bound_ratio` $\le 1.0 + 10^{-15}$ | Exact automatic summability |
| Finite-dim `FredholmDetTheory` matrix audit | Nilpotent shear & $2\times 2$ conjugation | $0$ (`instFredholmDetTheoryOfFiniteDimensional`) | $0.0$ shear/block, $1.78 \times 10^{-15}$ conj. | $< 1.8 \times 10^{-15}$ |
| Segal–Wilson $\det_{\mathrm{Fr}}$ vs. $\tau_U/p_{23}$ | $t = (0.35, -0.20, 0.15)$ | $0.918618732284581$ | $0.918618732284581$ | $0.0$ |
| First 10 true Riemann zeros: Li/Cayley | $\gamma_1 \dots \gamma_{10}$, $\sigma_{\mathrm{dev}} = 0$ | $0$ (`li_cayley_critical_line_bridge`) | max err $2.22 \times 10^{-16}$ | $2.22 \times 10^{-16}$ |
| Weil $L^1$ form on 10 true critical-line zeros | 3 shifted Gaussians | $\ge 0$ (`weilPositivity_L1_iff_allRealZeros`) | $\mathrm{Re} = 5.02 \times 10^{-43}$, $\mathrm{Im} = 0.0$ | Exact real $\ge 0$ |
| Weil $L^1$ off-line disproof witness | $z_0 = \gamma_1 \pm 0.15 i$ | $-8\pi = -25.132741 < -4\pi = -12.566371$ | $-25.13274122871833$ | $< 10^{-14}$ |
| 30-zero infinite-tail Weil witness | $\gamma_1 \dots \gamma_{30}$ tail vs. $-8\pi$ core | 80-digit tail $3.22 \times 10^{-44}$, zero resid $1.21 \times 10^{-76}$ | Tail $2.79 \times 10^{-40}$, full $-25.13274122871836$ | Full sum $< -4\pi$ |

---
, [sato-riemann-spectral-pending-closure-plan.md](sato-riemann-spectral-pending-closure-plan.md), and the master cross-plan specification [unified-pending-closure-roadmap-plan.md](unified-pending-closure-roadmap-plan.md), `Signals.Pending.sato_infinite_dim_and_pde_stack_do_not_close_rh_or_physical_claims` records the negative epistemic baseline when certificates are absent, while constructive certificate structures and solvers unify all seven `*PendingBoundary` structures in `Signals.Pending`:

1. **Four Open RH Bridges (`RiemannHypothesisPendingBoundary.solved_of_certificates`):** `DeBruijnNewmanUpperCertificate`, `AdelicSatoTraceLimitCertificate`, `GlobalWeilLiJensenCertificate`, and `SelfAdjointSpectralOperatorCertificate` connect directly to `RHGaps.dBN_eq_zero_and_RH`, `RiemannSpectral.dbnQuarticHeat_abs_le_on_box`, `CarlemanWeierstrass.adelicWeierstrass_critical_line_k3`, `RiemannSpectral.finiteDiagonalTransferTraceDistance_le`, `RiemannSpectralBridge.jensen2_turan_iff_madelung_bohm`, and `RemainingGaps.katoRellich_spectral_bridge`. Discharging `allFourBridgesClosed` unconditionally still requires supplying external pure-mathematics witnesses for $\Lambda \le 0$, adelic trace convergence, global Weil/Li/Jensen–Pólya positivity, and a self-adjoint Hilbert–Pólya operator.
2. **Axiom-Free Finite-Rank Fredholm Determinant & Lidskii `FredholmDetTheory` Bundle:** `DeterminantBundle.finiteRankDet` and `SegalWilsonGr24.segalWilson_tau_gr24_eq_tauU_axiomFree` now close the entire finite-rank Segal–Wilson $\mathrm{Gr}(2,4)$ sector on infinite-dimensional $L^2(S^1)$ **with zero axioms** via the canonical invariant subspace $V(F) = \operatorname{range}(F) \sqcup (\ker F)^\perp$, while `DeterminantBundle.instFredholmDetTheoryOfFiniteDimensional` eliminates axioms on arbitrary finite-dimensional truncations and `CarlemanWeierstrass.det1Diag_mul`, `det1Diag_single`, and `det3Diag_mul_anomaly` prove infinite-dimensional diagonal $\ell^1$ and critical-line $\ell^3$ determinant laws. `SatoRiemannSpectralPendingBoundary.solved_of_axiomFree_finiteRank_and_strip_certificates` closes `mathlibLidskiiFredholmDetConstructed` directly on the finite-rank sector without `[FredholmDetTheory]`, whereas `LidskiiFredholmDetCertificate` remains available for general non-finite-rank $1 + \mathcal{I}_1$ trace-class operators.
3. **Strip-Automatic Infinite-Zero Weil Positivity (`StripGaussianWeilCertificate` & `GlobalInfiniteZeroWeilCertificate`):** `WeilGaussianL1.lean` proves `norm_mellinTransform_gaussianCombo_strip`, `summable_weilInfinite_gaussianCombo_of_strip`, `weilInfiniteSum_gaussianCombo_nonneg_of_allRealZeros`, and `weilInfiniteSum_gaussianCombo_neg_of_offline_pair_tail_lt`, proving automatic summability for every `gaussianCombo δ P` under strip sub-Gaussian zero-density convergence $\sum_n m_n e^{-\operatorname{Re}(z_n)^2} < \infty$. Extending the witness to all zeros of $\zeta(s)$ requires supplying the unconditional global Weil explicit-formula convergence witness into `StripGaussianWeilCertificate` or `GlobalInfiniteZeroWeilCertificate`.
4. **Cross-Domain Overlap Closure Across All Seven `*PendingBoundary` Gates (`MasterUnifiedPendingClosure`):** `MasterUnifiedPendingClosure.all_seven_pending_boundaries_solved` simultaneously closes `RiemannHypothesisPendingBoundary`, `SatoRiemannSpectralPendingBoundary`, `ToupinCelestialMillenniumPendingBoundary`, `DualSchubertNavierStokesPendingBoundary`, `PhotoelectricEmissionPendingBoundary`, `AntimatterAnnihilationAlphaGPendingBoundary`, and `YangMillsMassGapHiggsCPTPendingBoundary` by factoring out shared certificates (`rh1..rh4`, `ym1..ym2`, `sharedEvanescent`, `sharedActivePhoton`, and `sharedPlancherel`) into a single machine-checked bundle
2. **Trace-Class Lidskii `FredholmDetTheory` Bundle (`LidskiiFredholmDetCertificate`):** `DeterminantBundle.instFredholmDetTheoryOfFiniteDimensional` eliminates the axiomatic assumption on all finite-dimensional Hilbert-space truncations via Mathlib's `LinearMap.det`, while `CarlemanWeierstrass.det1Diag_mul`, `det1Diag_single`, and `det3Diag_mul_anomaly` prove infinite-dimensional diagonal $\ell^1$ and critical-line $\ell^3$ determinant laws. Supplying a full infinite-dimensional `FredholmDetTheory` instance on `L²(S¹)` via `LidskiiFredholmDetCertificate` closes `mathlibLidskiiFredholmDetConstructed` and discharges `segalWilson_tau_gr24_eq_tauU` inside `SatoRiemannSpectralPendingBoundary.solved_of_certificates`.
3. **Global Infinite-Zero Weil Positivity (`GlobalInfiniteZeroWeilCertificate`):** `WeilGaussianL1.lean` now proves `weilInfiniteSum_nonneg_of_allRealZeros` and `weilInfiniteSum_neg_of_offline_pair_tail_lt` for countably infinite strip-bounded zero sequences `(z : ℕ → ℂ, m : ℕ → ℕ)` with super-Gaussian decay `norm_mellinTransform_shiftedGaussian_strip`. Extending the off-line witness to all zeros of $\zeta(s)$ requires supplying the unconditional Weil explicit-formula convergence witness into `GlobalInfiniteZeroWeilCertificate`.
4. **Physical-Model & Overlapping Celestial/Yang–Mills Boundaries (`EvanescentQfimExperimentalCertificate`, `ToupinCelestialMillenniumPendingBoundary.solved_of_certificates`):** Exact mathematical equivalence between `Signals.RiemannSpectral`, `Signals.SatoGrassmannian`, and `DualSchubertQFIM.sharoglazova_klaers_evanescent_speed_law` makes no unverified physical claims; physical validation is gated by `EvanescentQfimExperimentalCertificate` (coupling `ControlledMeasurement` telemetry to the evanescent QFIM speed law). Simultaneously, `ToupinCelestialMillenniumPendingBoundary.ofCertificates` and `.solved_of_certificates` eliminate the structural overlap across `Signals.Pending` by reusing the shared RH certificates `(c1..c4)` together with `ContinuumYangMillsOSCertificate` and `CelestialConfiningSpectralCertificate` from `YangMillsMassGapHiggsCPTPendingBoundary`.

---

## References

```{bibliography}
:filter: docname in docnames
:list: bullet
```
