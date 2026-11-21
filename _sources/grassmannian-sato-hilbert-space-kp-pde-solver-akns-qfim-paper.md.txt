---
title: "Formalizing the Infinite-Dimensional Sato Grassmannian Gr_p(H), Plabic Gr_≥0(2,4) KP-II / KdV / AKNS Soliton PDE Solvers, Baker–Akhiezer Lax Pairs, and 6-Channel Dual-Schubert QFIM in Lean 4, Rust/PyO3, and SymPy"
description: "An arXiv-ready MyST Markdown formal verification paper presenting the infinite-dimensional Hilbert-space Sato Grassmannian Gr_p(H) on L²(S¹), the finite Gr_C(2,4) Klein-quadric truncation, Hirota bilinear KP-II and KdV soliton PDE solvers, Baker–Akhiezer Lax pairs, AKNS focusing NLS and defocusing GPE solitons, 6-channel Dual-Schubert QFIM decomposition, and an overflow-proof log-sum-exp Rust/PyO3 solver verified with Lean 4 (zero sorry) and SymPy."
---

(grassmannian-sato-hilbert-space-kp-pde-solver-akns-qfim-paper)=
# Formalizing the Infinite-Dimensional Sato Grassmannian $\mathrm{Gr}_p(H)$, Plabic $\mathrm{Gr}_{\ge 0}(2,4)$ KP-II / KdV / AKNS Soliton PDE Solvers, Baker–Akhiezer Lax Pairs, and 6-Channel Dual-Schubert QFIM in Lean 4, Rust/PyO3, and SymPy

- **Authors:** Wes Turner
- **Subjects:**
  - Exactly Solvable and Integrable Systems (`nlin.SI`); Mathematical Physics (`math-ph`); Functional Analysis (`math.FA`); Logic & Formal Verification (`cs.LO`)
- **Epistemic Status & Scope Declaration:**
  - **Verified Mathematical & Computational Core (Machine-Checked in Lean 4, Rust/PyO3, and SymPy):** We formalize 11 zero-`sorry` Lean 4 modules under `Signals.SatoGrassmannian` (`Base`, `RieszSchauder`, `CircleL2`, `Gr24Truncation`, `KPFlow`, `HirotaKP`, `KP2Nonlinear`, `PDESolver`, `LaxPair`, `AKNS`, `DualSchubertQFIM`), building the infinite-dimensional polarized Hilbert-space Sato Grassmannian $\mathrm{Gr}_p(H)$ {cite:p}`qcb-sato1981,qcb-segal1985,pressley1986loop`, Hardy polarization on $L^2(S^1)$, exact Klein-quadric truncation $\mathrm{Gr}_{\mathbb{C}}(2,4) \hookrightarrow \mathrm{Gr}_2(L^2(S^1))$, KP flows, Hirota bilinear KP-II identity {cite:p}`hirota2004direct`, Kodama–Williams $\mathrm{Gr}_{\ge 0}(2,4)$ totally nonnegative soliton webs {cite:p}`kodama2014kp,postnikov2006plabic`, explicit KdV 1- and 2-soliton PDE proofs, Baker–Akhiezer $B_2$/$B_3$ Lax equations, AKNS focusing NLS bright soliton and defocusing GPE dark soliton PDEs {cite:p}`ablowitz1974inverse`, and the 6-channel Dual-Schubert Quantum Fisher Information Metric (QFIM) decomposition ($F_Q = 4\,g_{\mathrm{FS}}$). Every algebraic and differential identity is cross-checked by 13 exact SymPy symbolic proofs and a compiled Rust/PyO3 `PlabicGr24Solver` extension (`kp2_residual = 3.11e-15`).
  - **Open Experimental & Axiom Boundary (`Signals.Pending.SatoRiemannSpectralPendingBoundary`):** Checked PDE identities and QFIM decompositions prove exact consequences of the underlying integrable equations and projective Kähler geometry. They do **not** experimentally validate Sharoglazova–Klaers evanescent tunneling velocities {cite:p}`sharoglazova_energyspeed_2025`, massive Proca photons, or physical laboratory realizations without independent measurement data.
- **Primary Source Chat Provenance:**
  - {download}`data/chats/Gemini_Formalizing-Sato-Grassmannian-in-Lean_20261120-2337.md <../data/chats/Gemini_Formalizing-Sato-Grassmannian-in-Lean_20261120-2337.md>` (`13,272` lines, `sha256: c8eb7b93d618846add0564db6fd4df248aff7a12a6e63d1808712a6673f1a6ab`), specifically Blocks 001–007 (lines 73–4227), Block 012 (lines 7410–7748), Blocks 018–022 (lines 11446–13254).
- **Companion Papers:**
  - [Adelic Carleman–Weierstrass Regularized Determinants ($\det_2, \det_3$), Schwinger 2-Cocycle Central Extensions, Segal–Wilson Determinant Bundles, `L¹(ℝ)` Weil Positivity, and Formal Bridges to `Signals.RiemannSpectral`](grassmannian-sato-adelic-carleman-weierstrass-weil-rh-gaps-paper.md) (Paper 2 of this series)
  - [Why the Quantum Fisher Information Metric Is Four Times the Fubini–Study Kähler Metric ($F_{\mu\nu} = 4\,g_{\mu\nu}^{\mathrm{FS}}$)](grassmannian-qfim-fubini-study-kahler-madelung-unification-paper.md)
  - [Complex Grassmannian $\mathrm{Gr}_{\mathbb{C}}(2,4)$ Fubini–Study GPE, Dual-Schubert `iGPE`, Homogeneous Plücker $\mathcal{Q}_4$ Madelung Hydrodynamics, and Revised Turner (2026) Models](grassmannian-complex-gpe-igpe-plucker-madelung-paper.md)
- **Formal Verification & Computational Artifacts:**
  - `Signals` Lean 4 Library (`3,830` Lake jobs via `make signals_build`, zero `sorry`):
    - {download}`src/signals/Signals/SatoGrassmannian.lean <../src/signals/Signals/SatoGrassmannian.lean>`
    - {download}`src/signals/Signals/SatoGrassmannian/Base.lean <../src/signals/Signals/SatoGrassmannian/Base.lean>` through {download}`src/signals/Signals/SatoGrassmannian/DualSchubertQFIM.lean <../src/signals/Signals/SatoGrassmannian/DualSchubertQFIM.lean>`
    - {download}`src/signals/Signals/Pending.lean <../src/signals/Signals/Pending.lean>` (`SatoRiemannSpectralPendingBoundary`)
    - {download}`src/signals/SignalsTests.lean <../src/signals/SignalsTests.lean>` & {download}`src/signals/SignalsPendingTests.lean <../src/signals/SignalsPendingTests.lean>`
  - `signals-numerical-adapter` Rust + PyO3 (`maturin`) Extension (`7/7` `sato_grassmannian` Rust unit tests passing):
    - {download}`src/signals/numerical_adapter/src/sato_grassmannian.rs <../src/signals/numerical_adapter/src/sato_grassmannian.rs>` (`PlabicGr24Solver`, `Kp2Jet`, `evaluate_ba_lax_pair`, `evaluate_akns_solitons`, `evaluate_dual_schubert_qfim`)
  - Python + SymPy + PyO3 Verification Suite (`8/8` `pytest` tests passing):
    - {download}`sustainablefactory/sato_grassmannian.py <../sustainablefactory/sato_grassmannian.py>`
    - {download}`tests/test_sato_grassmannian_sympy_pyo3.py <../tests/test_sato_grassmannian_sympy_pyo3.py>`

---

## Abstract

Finite-dimensional Grassmannians $\mathrm{Gr}_{\mathbb{C}}(2,4)$ and positive Plabic parametrizations $\mathrm{Gr}_{\ge 0}(2,4)$ capture single-soliton and two-soliton interactions, but the full Kadomtsev–Petviashvili (KP) hierarchy lives on the infinite-dimensional Sato–Segal–Wilson Grassmannian $\mathrm{Gr}_p(H)$ of a polarized Hilbert space $H = H_+ \oplus H_-$. We present a complete, zero-`sorry` Lean 4 formalization of the infinite-dimensional Sato Grassmannian and its integrable PDE hierarchy inside the `Signals` library (`Signals.SatoGrassmannian.*`), paired with a compiled Rust/PyO3 `PlabicGr24Solver` and exact SymPy symbolic verification.

Our formalization establishes six main results:

1. **Infinite-Dimensional Polarized Hilbert-Space Grassmannian & Riesz–Schauder Fredholm Theory (`Base.lean`, `RieszSchauder.lean`, `CircleL2.lean`):** We formalize `PolarizedHilbertSpace`, Fredholm projections `IsFredholm`, the Riesz–Schauder theorem (`isFredholm_id_add_compact`, index zero for compact perturbations of the identity), the Hardy space polarization on $H = L^2(S^1, \mathbb{C})$ with unilateral shift $S = M_z$ (`shiftCLE`), and the restricted general linear group $\mathrm{GL}_{\mathrm{res}}(H)$ preserving $\mathrm{Gr}(H)$ with additive Fredholm virtual dimension.
2. **Exact $\mathrm{Gr}_{\mathbb{C}}(2,4)$ Truncation, Klein Quadric, and Two Formalization Bug Fixes (`Gr24Truncation.lean`, `LaxPair.lean`):** Embedding $\mathbb{C}^4 \cong \operatorname{span}\{z^{-2}, z^{-1}, 1, z\} \subset L^2(S^1)$ yields an explicit isomorphism onto the big cell of $\mathrm{Gr}_{\mathbb{C}}(2,4)$ cut out by the Klein quadric $p_{01}p_{23} - p_{02}p_{13} + p_{03}p_{12} = 0$. Formalizing the chat transcript caught and proved **two genuine algebraic errors** in the source derivation: (i) a sign inversion in the big-cell frame reconstruction `kleinQuadric_reconstruct_bigCell` (Block 005, lines 2475–2995), and (ii) a coefficient error in the third spatial derivative $\partial_x^3 \psi$ of the Baker–Akhiezer wave function (`baWave_lax_equations`, Block 019, lines 12135–12380), where the true term is $+6 z k^3 S_2 T - 4 k^4 S_2 T^2$ rather than $+4 k^3 S_2 T (z - k T)$.
3. **Hirota Bilinear KP-II Identity, Nonlinear $u = 2\partial_x^2\log\tau$, and Smooth Kodama–Williams $\mathrm{Gr}_{\ge 0}(2,4)$ Soliton Webs (`KPFlow.lean`, `HirotaKP.lean`, `KP2Nonlinear.lean`, `PDESolver.lean`):** We prove `hirotaKP_tauU_eq_zero` identically via the Klein quadric, `hirotaKP_eq_zero_iff_kp2` (equivalence between Hirota's bilinear form and the nonlinear $(2+1)$-D KP-II PDE $\partial_x(4 u_t - u_{xxx} - 6 u u_x) - 3 u_{yy} = 0$), strict positivity and global smoothness of $\tau(x,y,t) > 0$ on the totally nonnegative cell $\mathrm{Gr}_{\ge 0}(2,4)$ (`solitonTau_pos_of_totallyNonneg`), $y$-invariance of KdV 2-solitons (`kdv2Soliton_y_invariant_and_smooth`), and the exact KdV 1-soliton PDE (`kdv_oneSoliton_pde`).
4. **Baker–Akhiezer Lax Pair & AKNS Focusing NLS / Defocusing GPE Solitons (`LaxPair.lean`, `AKNS.lean`):** We prove both the $B_2$ ($\partial_y \psi = (\partial_x^2 + u)\psi$) and $B_3$ ($\partial_t \psi = (\partial_x^3 + \tfrac{3}{2}u\partial_x + w)\psi$) Lax equations for the KdV 1-soliton, the $2\times 2$ AKNS zero-curvature equivalence `akns_zero_curvature_iff`, the focusing NLS bright soliton `brightSoliton_nls_pde`, and the defocusing GPE dark soliton `darkSoliton_gpe_pde`.
5. **3-Channel Plücker–Madelung & 6-Channel Dual-Schubert QFIM (`DualSchubertQFIM.lean`):** We prove $F_Q = 4\,g_{\mathrm{FS}}$ (`qfim_eq_four_fubiniStudy`), the 3-channel Plücker–Madelung decomposition (`three_channel_plucker_madelung_qfim`), and the additive 6-channel $\mathrm{Gr}_{\mathbb{C}}(2,4)\times\mathrm{Gr}_{\mathbb{C}}(2,4)^\vee$ decomposition (`dual_schubert_six_channel_decomposition`).
6. **Overflow-Proof Log-Sum-Exp Rust/PyO3 PDE Solver (`sato_grassmannian.rs`):** Using normalized Boltzmann weights $w_r = c_r e^{\theta_r - M}/Z$ and central cumulants up to 6th order, `PlabicGr24Solver` evaluates arbitrary $\mathrm{Gr}_{\ge 0}(2,4)$ KP-II soliton webs even at $(x, y, t) = (100, -50, 20)$ without floating-point overflow, achieving `kp2_residual = 3.11e-15`, `lax_b2 = 1.11e-16`, `lax_b3 = 4.97e-16`, `akns_bright = 2.48e-16`, `akns_dark = 2.29e-16`, and `qfim_res = 0.0`.

---

## 1. Architecture of the `Signals.SatoGrassmannian` Core & PDE Stack

```{mermaid}
flowchart TB
    subgraph Core["Hilbert-Space Sato Grassmannian Core"]
        B1["Base.lean (Blocks 001–002)\nPolarizedHilbertSpace, IsFredholm,\nSatoGr, GL_res(H)"]
        B2["RieszSchauder.lean (Block 003)\nCompact perturbations of Id,\nindex(I + K) = 0"]
        B3["CircleL2.lean (Block 004)\nL²(S¹) Fourier basis e_n,\nHardy H_+ ⊕ H_-, shiftCLE"]
        B4["Gr24Truncation.lean (Block 005)\nGr_C(2,4) ↪ Gr(L²(S¹)), Klein Q_4,\nfixed big-cell frame signs"]
    end

    subgraph PDE["Integrable PDE Hierarchy & Lax/AKNS/QFIM"]
        P1["KPFlow.lean & HirotaKP.lean\n(Blocks 006–007)\nexp(∑ t_n z^n), schurTau,\nhirotaKP_tauU_eq_zero"]
        P2["KP2Nonlinear.lean & PDESolver.lean\n(Blocks 012, 018)\nu = 2 ∂_x² log τ, Gr_≥0(2,4) > 0,\nKdV 1- & 2-solitons"]
        P3["LaxPair.lean & AKNS.lean\n(Blocks 019–020)\nFixed B_2/B_3 Lax pair,\nNLS bright & GPE dark solitons"]
        P4["DualSchubertQFIM.lean (Block 022)\nF_Q = 4 g_FS, 3-channel Madelung,\n6-channel Gr(2,4) × Gr(2,4)^∨"]
    end

    subgraph Runtime["Compiled Rust/PyO3 + SymPy Verification"]
        R1["sato_grassmannian.rs (Block 021+)\nLog-sum-exp PlabicGr24Solver,\nBA Lax, AKNS, Dual-Schubert QFIM"]
        R2["sato_grassmannian.py & pytest\n13 SymPy exact proofs +\nPyO3 residual audits (< 10^-14)"]
    end

    B1 --> B2 --> B3 --> B4 --> P1 --> P2 --> P3 --> R1
    B4 --> P4 --> R1 --> R2
```

Every theorem in the 11 Lean 4 modules compiles under Lean `v4.35.0-rc3` and Mathlib with zero `sorry`, zero `admit`, and zero module-level warnings, integrated into the repository's top-level `Signals` library (`3,830` Lake jobs via `make signals_build`).

---

## 2. Polarized Hilbert Space, Riesz–Schauder Fredholm Theory, and $L^2(S^1)$

Following Segal–Wilson {cite:p}`qcb-segal1985` and Pressley–Segal {cite:p}`pressley1986loop`, a polarized complex Hilbert space (`Base.lean`, sourced from `data/chats/Gemini_Formalizing-Sato-Grassmannian-in-Lean_20261120-2337.md`, lines 73–1160) is an orthogonal decomposition $H = H_+ \oplus H_-$ into closed subspaces with orthogonal projections $\pi_+ : H \to H_+$ and $\pi_- : H \to H_-$. A closed subspace $W \subset H$ belongs to the Sato Grassmannian $\mathrm{Gr}(H)$ if:

1. The restricted projection $\pi_+|_{W} : W \to H_+$ is Fredholm (finite-dimensional kernel, closed range, finite-dimensional cokernel).
2. The cross projection $\pi_-|_{W} : W \to H_-$ is compact (and in the Hilbert–Schmidt Grassmannian $\mathrm{Gr}_2(H)$, Hilbert–Schmidt).

In `RieszSchauder.lean` (chat lines 1255–1989), we establish the complete Riesz–Schauder Fredholm package from scratch over Mathlib's `IsCompactOperator`: for every compact $K \in \mathcal{K}(H)$, the operator $I + K$ has finite-dimensional kernel, closed range, finite-dimensional cokernel, and Fredholm index zero (`isFredholm_id_add_compact`).

In `CircleL2.lean` (chat lines 1997–2326), we instantiate $H = L^2(\mathrm{AddCircle}(2\pi), \mathbb{C})$ using Mathlib's orthonormal Fourier basis `fourierBasis` $\{e_n\}_{n \in \mathbb{Z}}$ with $e_n(\theta) = e^{in\theta}$, splitting into the Hardy subspace $H_+ = \overline{\operatorname{span}}\{e_n : n \ge 0\}$ and its orthogonal complement $H_- = \overline{\operatorname{span}}\{e_n : n < 0\}$. Multiplication by $e^{i\theta}$ defines the unitary bilateral shift `shiftCLE : HCircle ≃L[ℂ] HCircle`, whose restriction to $H_+$ has kernel $\{0\}$ and 1-dimensional cokernel $\mathbb{C} e_0$, giving Fredholm index $-1$.

---

## 3. Klein Quadric Truncation $\mathrm{Gr}_{\mathbb{C}}(2,4) \hookrightarrow \mathrm{Gr}(L^2(S^1))$ and Two Machine-Caught Bug Fixes

Mapping $(v_0, v_1, v_2, v_3) \in \mathbb{C}^4$ to $v_0 e_{-2} + v_1 e_{-1} + v_2 e_0 + v_3 e_1 \in L^2(S^1)$ embeds any 2-plane $U = \operatorname{span}\{v, w\} \subset \mathbb{C}^4$ into the virtual-dimension-$0$ Sato Grassmannian via $W_U = U \oplus \overline{\operatorname{span}}\{e_n : n \ge 2\}$ (`Gr24Truncation.lean`, chat lines 2475–2995). Its six Plücker minors $p_{ij} = v_i w_j - v_j w_i$ ($0 \le i < j \le 3$) satisfy the Klein quadric equation:

$$
p_{01} p_{23} - p_{02} p_{13} + p_{03} p_{12} = 0.
$$

### 3.1 Machine-Caught Fix 1: Big-Cell Frame Reconstruction Signs (`Gr24Truncation.lean`)

On the big cell $p_{23} \ne 0$, the unique reduced row-echelon frame $(v_{\mathrm{norm}}, w_{\mathrm{norm}})$ whose $(2,3)$-columns form $I_2$ and whose Plücker coordinates recover $p_{ij} / p_{23}$ is:

$$
v_{\mathrm{norm}} = \left(\frac{p_{03}}{p_{23}},\; \frac{p_{13}}{p_{23}},\; 1,\; 0\right), \qquad
w_{\mathrm{norm}} = \left(-\frac{p_{02}}{p_{23}},\; -\frac{p_{12}}{p_{23}},\; 0,\; 1\right).
$$

In the source chat (Block 005, lines 2475–2995), `w_norm` was originally written with positive signs $(+p_{02}/p_{23}, +p_{12}/p_{23}, 0, 1)$, which gives $v_{\mathrm{norm},0} w_{\mathrm{norm},2} - v_{\mathrm{norm},2} w_{\mathrm{norm},0} = -p_{02}/p_{23}$ — off by a sign from $p_{02}/p_{23}$ (`chat_block005_bug_confirmed_nonzero = True` in SymPy). Lean 4's kernel rejected the erroneous sign during `kleinQuadric_reconstruct_bigCell`, and correcting the signs of $w_{\mathrm{norm}}$ makes both `kleinQuadric_reconstruct_bigCell` and the infinite-dimensional Segal–Wilson theorem `segalWilson_tau_gr24_eq_tauU` (Paper 2) close identically.

### 3.2 Machine-Caught Fix 2: Baker–Akhiezer $\partial_x^3 \psi$ Coefficient (`LaxPair.lean`)

For the KdV 1-soliton potential $u(x, t) = 2 k^2 \operatorname{sech}^2(\theta)$ with $\theta = k x + k^3 t$, the Baker–Akhiezer wave function (`LaxPair.lean`, chat lines 12135–12380) is:

$$
\psi(x, y, t; z) = \bigl(z - k\tanh\theta\bigr)\exp\bigl(z x + z^2 y + z^3 t\bigr).
$$

Setting $T = \tanh\theta$, $S_2 = \operatorname{sech}^2\theta = 1 - T^2$, and $E = e^{zx + z^2 y + z^3 t}$, the exact third spatial derivative is:

$$
\partial_x^3 \psi = \Bigl[z^3(z - k T) - 3 z^2 k^2 S_2 + 6 z k^3 S_2 T + 2 k^4 S_2(1 - 3 T^2)\Bigr] E.
$$

The source chat draft (Block 019) wrote $+4 k^3 S_2 T (z - k T) + 2 k^4 S_2 (1 - 2 T^2)$ instead of $+6 z k^3 S_2 T + 2 k^4 S_2 (1 - 3 T^2)$, leaving an exact discrepancy of $2 k^3 S_2 T (z + k T) E$ (`chat_block019_psi_xxx_bug_confirmed_nonzero = True` in SymPy). With the corrected derivative, `baWave_lax_equations` proves both the $B_2$ and $B_3$ Lax equations unconditionally:

$$
\partial_y \psi = (\partial_x^2 + u)\psi, \qquad
\partial_t \psi = \left(\partial_x^3 + \frac{3}{2} u\,\partial_x + w\right)\psi, \qquad
w = -3 k^3 \tanh\theta \operatorname{sech}^2\theta.
$$

---

## 4. Hirota Bilinear KP-II, Kodama–Williams $\mathrm{Gr}_{\ge 0}(2,4)$ Soliton Webs, and AKNS Solitons

Under the 3-time KP flow $\exp(t_1 z + t_2 z^2 + t_3 z^3)$ (`KPFlow.lean`, chat lines 3001–3617), the Sato $\tau$-function of a 2-plane $U = \operatorname{span}\{v, w\} \in \mathrm{Gr}_{\mathbb{C}}(2,4)$ expands in Schur polynomials indexed by partitions inside the $2\times 2$ Young diagram (`HirotaKP.lean`, chat lines 3736–4227):

$$
\tau_U(t_1, t_2, t_3) = p_{23} + p_{13} s_{(1)} + p_{03} s_{(2)} + p_{12} s_{(1,1)} + p_{02} s_{(2,1)} + p_{01} s_{(2,2)},
$$

where $s_{(1)} = t_1$, $s_{(2)} = t_2 + \tfrac{1}{2} t_1^2$, $s_{(1,1)} = \tfrac{1}{2} t_1^2 - t_2$, $s_{(2,1)} = \tfrac{1}{3} t_1^3 - t_3$, and $s_{(2,2)} = \tfrac{1}{12} t_1^4 + t_2^2 - t_1 t_3$. Both `HirotaKP.hirotaKP_tauU_eq_zero` and SymPy (`hirota_kp_eq_24_times_klein`) prove the exact algebraic identity:

$$
\bigl(D_{t_1}^4 - 4 D_{t_1} D_{t_3} + 3 D_{t_2}^2\bigr)\tau_U \cdot \tau_U = 24\,(p_{01} p_{23} - p_{02} p_{13} + p_{03} p_{12}) = 0.
$$

In `KP2Nonlinear.lean` (chat lines 7410–7748) and `PDESolver.lean` (chat lines 11446–12015), we prove:

1. **Bilinear-to-Nonlinear Equivalence (`hirotaKP_eq_zero_iff_kp2`):** Wherever $\tau(x, y, t) \ne 0$, setting $u = 2\,\partial_x^2 \log\tau$ satisfies $\partial_x(4 u_t - u_{xxx} - 6 u u_x) - 3 u_{yy} = 0$ if and only if Hirota's bilinear expression vanishes.
2. **Wronskian Positroid Soliton Webs (`solitonTau_eq_wronskian`, `hirotaKP_solitonTau_eq_zero`, `solitonTau_pos_of_totallyNonneg`):** For real ordered wavenumbers $\kappa_0 < \kappa_1 < \kappa_2 < \kappa_3$ and a totally nonnegative frame $(v, w) \in \mathrm{Gr}_{\ge 0}(2,4)$ (all $p_{ij} \ge 0$, not all zero),

$$
\tau_{\kappa, v, w}(x, y, t) = \sum_{0 \le i < j \le 3} p_{ij}(\kappa_j - \kappa_i)\exp\Bigl((\kappa_i + \kappa_j)x + (\kappa_i^2 + \kappa_j^2)y + (\kappa_i^3 + \kappa_j^3)t\Bigr) > 0
$$

is strictly positive on all of $\mathbb{R}^3$, guaranteeing global smooth, blowup-free $(2+1)$-D resonant soliton webs {cite:p}`kodama2014kp`.
3. **KdV Reduction (`kdv2Soliton_y_invariant_and_smooth`, `kdv_oneSoliton_pde`):** Choosing symmetric wavenumbers $(-\kappa_2, -\kappa_1, \kappa_1, \kappa_2)$ and the KdV positroid cell annihilates the $y$-dependence ($\partial_y u = \partial_{yy} u = 0$), yielding exact smooth KdV 1- and 2-solitons solving $4 u_t - u_{xxx} - 6 u u_x = 0$.
4. **AKNS Hierarchy (`AKNS.lean`, chat lines 12388–12739):** Passing to $2\times 2$ matrix Lax pairs {cite:p}`ablowitz1974inverse`, we prove `akns_zero_curvature_iff` together with the focusing NLS bright soliton `brightSoliton_nls_pde` ($q(x,t) = A\operatorname{sech}(Ax)e^{i A^2 t}$ solving $i q_t + q_{xx} + 2|q|^2 q = 0$) and the defocusing GPE dark soliton `darkSoliton_gpe_pde` ($q(x,t) = A\tanh(Ax)e^{-2 i A^2 t}$ solving $i q_t + q_{xx} - 2|q|^2 q = 0$).

---

## 5. Three-Channel Plücker–Madelung, Six-Channel Dual-Schubert QFIM, & Evanescent Speed Law

In `DualSchubertQFIM.lean` (chat lines 13049–13254), we lift the projective geometry of $\mathrm{Gr}_{\mathbb{C}}(2,4) \hookrightarrow \mathbb{P}^5(\mathbb{C})$ into a machine-checked quantum-metrology identity connecting directly to our companion paper [Why the Quantum Fisher Information Metric Is Four Times the Fubini–Study Kähler Metric](grassmannian-qfim-fubini-study-kahler-madelung-unification-paper.md):

$$
\|\partial_x \Psi\|^2 = \rho\,\bigl(\operatorname{Im}\langle\hat{p}, \partial_x\hat{p}\rangle\bigr)^2 + \frac{(\partial_x\rho)^2}{4\rho} + \rho\,\frac{F_Q(\hat{p}, \partial_x\hat{p})}{4},
\qquad F_Q(p, v) = 4\,g_{\mathrm{FS}}(p, v) = 4\left(\frac{\|v\|^2}{\|p\|^2} - \frac{|\langle p, v\rangle|^2}{\|p\|^4}\right).
$$

On the dual-Schubert product $\mathrm{Gr}_{\mathbb{C}}(2,4) \times \mathrm{Gr}_{\mathbb{C}}(2,4)^\vee$, `dual_schubert_six_channel_decomposition` proves that the total QFIM splits additively into six nonnegative channels (three forward Plücker channels plus three dual-Schubert channels). Furthermore, **Theorem 4.3** (`sharoglazova_klaers_evanescent_speed_law` in `DualSchubertQFIM.lean`, linked to `er_epr_wormhole_bohm_blowup_and_sharoglazova_klaers_qfim_cushion_identities` in `Signals.QuantumTrajectories` Section 9) formalizes the stationary coupled-waveguide evanescent state $\Psi(x) = e^{-\bar{\kappa} x}(\cosh(\delta\kappa\,x), \sinh(\delta\kappa\,x))$ where $\kappa_{\pm}^2 = 2m(|E_{\mathrm{kin}}| \mp \hbar J_0)/\hbar^2$:

$$
v_{\mathrm{Bohm}}^2 = 0, \qquad g_{\mathrm{FS}}(\hat{p}, \partial_x\hat{p}) = \frac{\delta\kappa^2}{\cosh^2(2\delta\kappa\,x)}, \qquad \left(\frac{\hbar}{m}\right)^2\left[0 + \left(\frac{\partial_x\rho}{2\rho}\right)^2 + \frac{F_Q}{4}\right] = \frac{2}{m}\bigl(|E_{\mathrm{kin}}| - \hbar J_0\tanh(2\delta\kappa\,x)\bigr).
$$

Thus Channel 1 (Bohmian phase velocity) vanishes identically while Channel 2 (scalar osmotic gradient) and Channel 3 (projective Fubini–Study / QFIM) jointly recover the exact evanescent speed law without singularity. As recorded in `Signals.Pending.SatoRiemannSpectralPendingBoundary`, these exact geometric identities do not by themselves establish experimental tunneling speeds in coupled-waveguide cavities {cite:p}`sharoglazova_energyspeed_2025` or physical wormhole-throat stabilization.

---

## 6. Overflow-Proof Log-Sum-Exp Rust/PyO3 PDE Solver & Tri-Language Verification Summary

Directly evaluating $\tau(x,y,t) = \sum_r c_r e^{\theta_r}$ in IEEE-754 `f64` overflows above $\theta_r \approx 709$ (e.g., at $(x, y, t) = (100, -50, 20)$). In `src/signals/numerical_adapter/src/sato_grassmannian.rs` (extending chat Block 021, lines 12747–13021), `PlabicGr24Solver` shifts all exponents by $M = \max_r (\ln c_r + \theta_r)$, forms normalized Boltzmann weights $w_r = e^{\phi_r - M} / Z$, and computes the exact analytical KP-II jet up to 4th derivatives via central cumulants of $(\alpha_r, \beta_r, \gamma_r)$:

$$
u = 2\,\mu_{2,\alpha}, \qquad u_x = 2\,\mu_{3,\alpha}, \qquad u_{xx} = 2(\mu_{4,\alpha} - 3\mu_{2,\alpha}^2),
$$

$$
u_{xxx} = 2(\mu_{5,\alpha} - 10\mu_{3,\alpha}\mu_{2,\alpha}), \qquad u_{xxxx} = 2(\mu_{6,\alpha} - 15\mu_{4,\alpha}\mu_{2,\alpha} - 10\mu_{3,\alpha}^2 + 30\mu_{2,\alpha}^3).
$$

| Verification Artifact | Domain / Benchmark Point | Lean 4 Theorem (Zero `sorry`) | SymPy Exact Proof | Rust/PyO3 Measured Residual |
| --- | --- | --- | --- | --- |
| Big-cell Klein quadric (`Gr(2,4)`) | Postnikov weights $(1.2, 0.8, 1.5, 2.1)$ | `kleinQuadric_reconstruct_bigCell` | `big_cell_reconstruction_corrected_signs` | $\|p_{01}p_{23}-p_{02}p_{13}+p_{03}p_{12}\| < 10^{-15}$ |
| KP-II top-cell resonant web | $\kappa=(-2,-0.5,0.7,1.8)$, $(1.3,-2.4,0.9)$ | `hirotaKP_solitonTau_eq_zero` | `hirota_kp_eq_24_times_klein` | $u = 1.162107$, residual $3.11 \times 10^{-15}$ |
| KP-II extreme-coordinate stability | $\kappa=(-1,0,1,2)$, $(100,-50,20)$ | `solitonTau_pos_of_totallyNonneg` | Exact cumulant invariance | No overflow, residual $< 10^{-11}$ |
| KdV 2-soliton $y$-invariance | $k_1=0.6, k_2=1.3$, $y=0$ vs. $y=17.5$ | `kdv2Soliton_y_invariant_and_smooth` | Exact $\beta_r$ symmetry | $\|u(y=0)-u(y=17.5)\| < 10^{-13}$ |
| Baker–Akhiezer $B_2$ & $B_3$ Lax pair | $k=0.8, z=0.3+1.1i$, $(0.4,-0.2,0.5)$ | `baWave_lax_equations` | `ba_lax_b2_exact`, `ba_lax_b3_exact` | $B_2$: $1.11 \times 10^{-16}$; $B_3$: $4.97 \times 10^{-16}$ |
| AKNS bright NLS & dark GPE solitons | $A=1.3$, $(x,t)=(0.7,-0.4)$ | `brightSoliton_nls_pde`, `darkSoliton_gpe_pde` | `akns_bright_nls_exact`, `akns_dark_gpe_exact` | NLS: $2.48 \times 10^{-16}$; GPE: $2.29 \times 10^{-16}$ |
| 6-channel Dual-Schubert QFIM | Normalized 6+6 Plücker densities | `dual_schubert_six_channel_decomposition` | `dual_schubert_three_channel_plucker_madelung_qfim` | $F_Q^{\mathrm{tot}} = 0.988767$, residual $< 10^{-15}$ |
| Sharoglazova–Klaers evanescent speed law | $\hbar=m=1$, $E_{\mathrm{abs}}=2.5$, $J_0=1.5$, $x=0.37$ | `sharoglazova_klaers_evanescent_speed_law` | `sharoglazova_klaers_evanescent_speed_law` | $v_{\mathrm{Bohm}}^2 = 0$, residual $< 10^{-14}$ |

---

## 7. Reproducibility Commands

```bash
# 1. Verify all 21 Signals.SatoGrassmannian modules, SignalsTests, and SignalsPendingTests
make signals_build

# 2. Run Rust unit tests and build/install the PyO3 extension
cargo test --manifest-path src/signals/numerical_adapter/Cargo.toml sato_grassmannian
maturin develop --manifest-path src/signals/numerical_adapter/Cargo.toml --release --features extension-module

# 3. Run the SymPy + mpmath + PyO3 cross-verification test suite (15 symbolic proofs + PyO3/mpmath)
pytest -q tests/test_sato_grassmannian_sympy_pyo3.py
```

---

## References

```{bibliography}
:filter: docname in docnames
:list: bullet
```
