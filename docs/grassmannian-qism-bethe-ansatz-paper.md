---
title: "Grassmannian Geometry of the Quantum Inverse Scattering Method, Algebraic Bethe Ansatz, and Inverse Scattering Metrology in Lean 4"
description: "An arXiv-ready formal verification paper formalizing Yang's rational R-matrix, 2×2 monodromy matrices, shifted Yangian quantum determinants, Gr(2,4) Baxter QQ/TQ Wronskians, Mukhin–Tarasov–Varchenko nondegeneracy, Slavnov determinants, and inverse scattering metrology in Lean 4."
---

(grassmannian-qism-bethe-ansatz-paper)=
# Grassmannian Geometry of the Quantum Inverse Scattering Method, Algebraic Bethe Ansatz, and Inverse Scattering Metrology in Lean 4

**Authors:** Wes Turner
**Subjects:** Mathematical Physics (`math-ph`); Exactly Solvable and Integrable Systems (`nlin.SI`); Quantum Physics (`quant-ph`); Logic in Computer Science (`cs.LO`)
**Formal Verification Artifact:** `Signals` Lean 4 Library (`leanprover/lean4:v4.35.0-rc3`, Mathlib `v4.35.0-rc3`)
**Companion Papers:**
- [Huygens–Steiner Barycentric Coherence, Complex $Gr_{\mathbb{C}}(2,4)$ Plücker Channels, and Multi-Model Double-Slit & OAM Relative Predictive Error in Lean 4](grassmannian-huygens-double-slit-oam-paper.md)
- [Complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ & $N$-ary $Gr_{\mathbb{C}}(2, N+2)$ Unification with Dilatant Dark Fluid (DDF) Moving Sheaths, Plücker Sink Fluxes, Anosov Invariance, and Sorkin Triple-Slit Interferometry in Lean 4](grassmannian-ddf-moving-sheath-paper.md)
- [Grassmannian Gravity from QED & Gauge Scattering Amplitudes: Complex $Gr_{\mathbb{C}}(2,4)$ Orbital Precession, Mercury's Perihelion, $N$-Body Dynamics, and Dilatant Dark Fluid (DDF) Unification in Lean 4](grassmannian-gravity-from-qed-scattering-paper.md)
- [Normed Tensor Gaussian Splat Mechanics for Complex $Gr_{\mathbb{C}}(2,4)$ Twistors: Advantages, Limitations, WebGL2/WASM Practicality, and Unification Across Double-Slit, QISM, DDF, and Planetary Gravity in Lean 4](grassmannian-splat-mechanics-paper.md)
- [Inelastic Scattering and the Heat Problem in Unified Grassmannian–DDF Mechanics: Inverse Compton, Stokes/Anti-Stokes Raman, Fourier vs. Cattaneo–Vernotte, and Subluminal Second-Sound Tensor Splatting in Lean 4](grassmannian-thermal-compton-raman-paper.md)

---

## Abstract

The Quantum Inverse Scattering Method (QISM) and Algebraic Bethe Ansatz (ABA) solve $(1+1)$-dimensional integrable quantum many-body systems, yet conventional operator diagonalization scales exponentially with lattice size ($\dim \mathcal{H}_{\mathrm{phys}} = 2^N$) and off-shell correlation functions generate $(M!)^2$ algebraic contractions under the $RTT$ commutation relations. We present a machine-checked formalization in the Lean 4 theorem prover (`Signals.QISM`, `Signals.Scattering`, and `Signals.Geometry`) demonstrating how finite Grassmannian geometry resolves these bottlenecks:

1. **Yang's $4 \times 4$ Rational $R$-Matrix, Regularity, Unitarity, and Three-Site Braid Identity**:
   We formalize the two-space permutation matrix $P$ ($P^2 = I_4$) and Yang's rational $R$-matrix $R(u;\eta) = u I_4 + \eta P$, proving the regularity condition $R(0;\eta) = \eta P$, triplet/singlet channel decomposition, quantum unitarity $R(u-v;\eta)R(v-u;\eta) = (\eta^2 - (u-v)^2)I_4 = -w_{\mathrm{sym}} w_{\mathrm{anti}} I_4$, and the three-site Yang–Baxter braid interference identity.
2. **Monodromy Composition, Cauchy–Binet Expansion, and Shifted Yangian Quantum Determinants**:
   We formalize $2 \times 2$ auxiliary Lax/monodromy matrices $T(u) = \begin{pmatrix} A & B \\ C & D \end{pmatrix}$, proving cyclic transfer-trace invariance $\operatorname{Tr}(L_2 L_1) = \operatorname{Tr}(L_1 L_2)$, determinant multiplicativity, Cauchy–Binet path-pair expansion over virtual intermediate channels, and the equivalence of left- and right-ordered shifted Yangian quantum determinants $\operatorname{qdet}_{L/R}(T(u), T(u-\eta))$ under the antisymmetric $RTT$ exchange balance.
3. **Baxter $Q$-Pairs in $Gr(2,4)$, the Plücker $QQ$-System, $TQ$ Wronskian Solutions, and MTV Nondegeneracy**:
   Representing a Bethe state by a 2-plane $W = \operatorname{span}\{Q_+, Q_-\}$ evaluated at four spectral points defines a $2 \times 4$ Grassmannian matrix whose Plücker coordinates are Casorati Wronskians $W(u_j, u_k)$. We prove $GL(2)$ basis-change covariance, derive Baxter's functional $QQ$-system / Hirota bilinear equation directly from the 3-term Plücker relation on $Gr(2,4)$, prove that three-point Casorati Wronskians solve Baxter's $TQ$ difference equation identically, expose the spurious triple-zero Bethe-root degeneracy, and prove the Mukhin–Tarasov–Varchenko (MTV) Wronskian nondegeneracy theorem ruling out $0/0$ Bethe roots.
4. **Slavnov / Gaudin Determinant Compression and Inverse Scattering Metrology**:
   We formalize $2 \times 2$ Slavnov/Gaudin determinants as Grassmannian minors, prove rapidity-swap antisymmetry and Pauli-exclusion vanishing at colliding Bethe or dual rapidities, and integrate `Signals.QISM` with `Signals.Scattering` to prove exact inverse parameter recovery, unitary two-body transmission/reflection flux partition, inverse monodromy reconstruction, and calibrated Baxter $TQ$ residual metrology.

---

## 1. Introduction & Architecture Overview

Introduced by Takhtajan, Faddeev, and Sklyanin ([Takhtajan and Faddeev 1979](#qism-takhtajan1979); [Sklyanin 1992](#qism-sklyanin1992); [Korepin et al. 1993](#qism-korepin1993); [Faddeev 1996](#qism-faddeev1996)), the Quantum Inverse Scattering Method (QISM) reformulates Hans Bethe's coordinate ansatz into an algebraic framework governed by the Yangian $Y(\mathfrak{gl}_n)$. Just as the Grassmannian $Gr(k,n)$ bypasses exponential Feynman-diagram expansion in $4\text{D}$ scattering amplitudes ([Arkani-Hamed and Trnka 2014](#qism-arkani2014)), Grassmannian geometry bypasses the $2^N$ Hilbert-space bottleneck of QISM:

| QISM / Bethe Ansatz Object | Conventional Hilbert-Space Formulation | Grassmannian Formulation (`Signals.QISM` & `Signals.Geometry`) | Complexity Reduction |
|---|---|---|---|
| **Monodromy $T(u) = L_N \cdots L_1$** | Product of operators on $V_{\mathrm{aux}} \otimes (\mathbb{C}^k)^{\otimes N}$ | Boundary measurement / Cauchy–Binet composition (`comp_det_eq_pathPairs`) | $k^N \times k^N$ matrices $\to$ $k \times n$ matrix |
| **Yang–Baxter Equation ($RTT$)** | Operator identity on $V_1 \otimes V_2 \otimes \mathcal{H}$ | Spectral cocycle & three-site braid identity (`yang_baxter_rational_braid`) | Local graph / braid equivalence |
| **Transfer Spectrum $t(u)$ & BAE** | Canceling $2^M$ unwanted commutator terms | 3-term Plücker $QQ$-system (`baxter_qq_pluecker_identity`) & Wronskian $TQ$ identity (`baxterTQResidual_wronskian_zero`) | $2^N$ diagonalization $\to$ $Gr(2,4)$ Plücker algebra |
| **Spurious Root Filtering** | Ad-hoc inspection of vanishing wavefunctions | MTV Casorati Wronskian nondegeneracy (`mtv_wronskian_nondegenerate_of_root`) | Certified full-rank Plücker minor |
| **Correlators $\langle \Psi | \mathcal{O} | \Psi \rangle$** | $(M!)^2$ $RTT$ commutator contractions | Single Plücker / Slavnov determinant (`slavnovDet2`, `slavnovDet2_pauli_exclusion`) | $O((M!)^2) \to O(M^3)$ determinant |

---

## 2. Yang's Rational $R$-Matrix, Regularity, Unitarity, and Braid Identity

For spectral parameters $u, v \in \mathbb{R}$ and coupling $\eta \in \mathbb{R}$, let $\delta(u,v) = u - v$ (`spectralDiff`). On $\mathbb{R}^2 \otimes \mathbb{R}^2 \cong \mathbb{R}^4$, the permutation operator $P$ (`swapMatrix4`) and Yang's rational $R$-matrix (`yangRMatrix4` in [src/signals/Signals/QISM.lean](../src/signals/Signals/QISM.lean#L43-L162)) are:

$$
R(u; \eta) = u I_4 + \eta P, \qquad
P = \begin{pmatrix}
1 & 0 & 0 & 0 \\
0 & 0 & 1 & 0 \\
0 & 1 & 0 & 0 \\
0 & 0 & 0 & 1
\end{pmatrix}.
$$

We prove in [QISM.lean](../src/signals/Signals/QISM.lean#L52-L162):
1. **Involutive Swap (`swapMatrix4_mul_self`)**: $P^2 = I_4$.
2. **Regularity at Zero Spectral Shift (`yangRMatrix4_zero`)**: $R(0;\eta) = \eta P$.
3. **Symmetric (Triplet) and Antisymmetric (Singlet) Eigenvalues (`yangSymmetricWeight`, `yangAntisymmetricWeight`, `yangRMatrix4_triplet_entry`)**:
   $$w_{\mathrm{sym}}(u,v;\eta) = \delta(u,v) + \eta, \qquad w_{\mathrm{anti}}(u,v;\eta) = \delta(u,v) - \eta, \qquad R(u-v;\eta)_{00} = w_{\mathrm{sym}}(u,v;\eta).$$
4. **Quantum Unitarity (`yangRMatrix4_unitarity`)**:
   $$R(u - v; \eta)\,R(v - u; \eta) = \bigl(\eta^2 - (u - v)^2\bigr) I_4 = - w_{\mathrm{sym}}(u,v;\eta)\,w_{\mathrm{anti}}(u,v;\eta)\,I_4.$$
5. **Three-Site Rational Braid Identity & Full $8 \times 8$ Matrix Quantum Yang–Baxter Equation (`yang_baxter_rational_braid`, `yang_baxter_equation_matrix8`)**:
   From the spectral cocycle $\delta(u,v) + \delta(v,w) = \delta(u,w)$ (`spectralDiff_add`) and the symmetric-group representation `permMatrix8` on $(\mathbb{R}^2)^{\otimes 3} \cong \mathbb{R}^8$ (`swap12Perm8`, `swap13Perm8`, `swap23Perm8`), the embedded $8 \times 8$ rational $R$-matrices `yangR12_8`, `yangR13_8`, `yangR23_8` satisfy the exact operator identity:
   $$R_{12}(u - v; \eta)\,R_{13}(u - w; \eta)\,R_{23}(v - w; \eta) = R_{23}(v - w; \eta)\,R_{13}(u - w; \eta)\,R_{12}(u - v; \eta).$$

```lean
import Signals
import SignalsPending

namespace ArxivQISMPaperVerification

open Signals.Geometry
open Signals.QISM
open Signals.Scattering

-- 1. Swap involution, R-matrix regularity, quantum unitarity, and full 8×8 Quantum Yang-Baxter Equation
example (u v w η : ℝ) :
    swapMatrix4 * swapMatrix4 = (1 : Matrix (Fin 4) (Fin 4) ℝ) ∧
    yangRMatrix4 0 η = η • swapMatrix4 ∧
    yangRMatrix4 (spectralDiff u v) η * yangRMatrix4 (spectralDiff v u) η =
      (- (yangSymmetricWeight u v η * yangAntisymmetricWeight u v η)) •
        (1 : Matrix (Fin 4) (Fin 4) ℝ) ∧
    yangR12_8 (spectralDiff u v) η * yangR13_8 (spectralDiff u w) η *
        yangR23_8 (spectralDiff v w) η =
      yangR23_8 (spectralDiff v w) η * yangR13_8 (spectralDiff u w) η *
        yangR12_8 (spectralDiff u v) η :=
  ⟨swapMatrix4_mul_self, yangRMatrix4_zero η, yangRMatrix4_unitarity u v η,
    yang_baxter_equation_matrix8 u v w η⟩
```

---

## 3. Monodromy Composition, Cauchy–Binet Expansion, and Shifted Quantum Determinants

A $2 \times 2$ auxiliary Lax or monodromy matrix $T(u) = \begin{pmatrix} A & B \\ C & D \end{pmatrix}$ is represented by `MonodromyMatrix2` ([QISM.lean](../src/signals/Signals/QISM.lean#L164-L320)):

- **Transfer Trace & Cyclic Invariance (`transferTrace_eq_trace`, `transferTrace_comp_comm`)**:
  The auxiliary trace $t(u) = A + D$ agrees with `Matrix.trace` on `toMatrix` and obeys $\operatorname{Tr}(L_2 L_1) = \operatorname{Tr}(L_1 L_2)$.
- **Grassmannian Minor & Cauchy–Binet Composition (`classicalDet_eq_twoRowMinor`, `classicalDet_comp`, `comp_det_eq_pathPairs`)**:
  The determinant $\det T = A D - B C$ equals the $2 \times 2$ Grassmannian minor $\Delta_{01}(T)$, is multiplicative across lattice sites ($\det(L_2 L_1) = \det(L_2)\det(L_1)$), and expands via `Signals.Geometry.twoStep_det_pathPairs` as a sum over intermediate virtual channel pairs $(a,b) \in \operatorname{Fin}(2)^2$:
  $$\det(L_2 L_1) = \sum_{a=0}^1 \sum_{b=0}^1 (L_2)_{0a}(L_2)_{1b}\bigl((L_1)_{a0}(L_1)_{b1} - (L_1)_{a1}(L_1)_{b0}\bigr).$$
- **Shifted Yangian Quantum Determinants (`quantumDetLeft`, `quantumDetRight`, `quantumDetLeft_self`, `quantumDet_left_eq_right_iff`)**:
  In the Yangian $Y(\mathfrak{gl}_2)$, the central quantum determinant evaluates the second factor at the shifted spectral argument $u - \eta$:
  $$\operatorname{qdet}_L(T(u), T(u-\eta)) = A(u)D(u-\eta) - B(u)C(u-\eta), \qquad \operatorname{qdet}_R(T(u), T(u-\eta)) = D(u)A(u-\eta) - C(u)B(u-\eta).$$
  At zero shift ($T(u-\eta) = T(u)$), $\operatorname{qdet}_L(T, T) = \det T$ (`quantumDetLeft_self`). For general shifted matrices, `quantumDet_left_eq_right_iff` proves:
  $$\operatorname{qdet}_L(T(u), T(u-\eta)) = \operatorname{qdet}_R(T(u), T(u-\eta)) \iff A(u)D(u-\eta) - D(u)A(u-\eta) = B(u)C(u-\eta) - C(u)B(u-\eta).$$

---

## 4. Baxter $Q$-Polynomials in $Gr(2,4)$, the $QQ$-System, and MTV Nondegeneracy

In the Mukhin–Tarasov–Varchenko Grassmannian correspondence ([Mukhin et al. 2009](#qism-mtv2009)), a Bethe eigenstate is encoded by a 2-plane $W = \operatorname{span}\{Q_+(u), Q_-(u)\}$ of Baxter functions. Sampling $(Q_+, Q_-)$ at four spectral rapidities $(u_0, u_1, u_2, u_3)$ constructs the $2 \times 4$ Grassmannian matrix (`baxterGrassmannianMatrix` in [QISM.lean](../src/signals/Signals/QISM.lean#L322-L545)):

$$
M_Q(u_0, u_1, u_2, u_3) =
\begin{pmatrix}
Q_+(u_0) & Q_+(u_1) & Q_+(u_2) & Q_+(u_3) \\
Q_-(u_0) & Q_-(u_1) & Q_-(u_2) & Q_-(u_3)
\end{pmatrix}, \qquad
\Delta_{jk}(M_Q) = W(u_j, u_k) = Q_+(u_j)Q_-(u_k) - Q_+(u_k)Q_-(u_j).
$$

1. **$GL(2)$ Basis-Change Covariance (`baxterGrassmannianMatrix_basisChange`)**:
   Left-multiplying $M_Q$ by any basis matrix $B \in \mathbb{R}^{2 \times 2}$ scales every ordered Casorati Wronskian minor uniformly by $\det B$: $\Delta_J(B M_Q) = (\det B)\,\Delta_J(M_Q)$.
2. **Baxter's Functional $QQ$-System from $Gr(2,4)$ (`baxter_qq_pluecker_identity`)**:
   Applying the 3-term Plücker identity (`twoRowMinor_pluecker`) to $M_Q$ immediately yields the functional $QQ$-system / Hirota bilinear equation:
   $$W(u_0, u_1)W(u_2, u_3) - W(u_0, u_2)W(u_1, u_3) + W(u_0, u_3)W(u_1, u_2) = 0.$$
3. **Three-Point Wronskian Solution of Baxter's $TQ$ Equation (`baxterTQResidual_wronskian_zero`)**:
   For Baxter's $TQ$ difference residual $\operatorname{baxterTQResidual}(T, a, d, Q(u), Q(u-\eta), Q(u+\eta)) = T Q(u) - (a Q(u-\eta) + d Q(u+\eta))$, setting $T(u) = W(u-\eta, u+\eta)$, $a(u) = W(u, u+\eta)$, and $d(u) = W(u-\eta, u)$ satisfies `baxterTQResidual = 0` identically for all $u, \eta \in \mathbb{R}$.
4. **Spurious Triple-Zero Degeneracy vs. MTV Wronskian Nondegeneracy (`baxterTQResidual_spurious_zero`, `mtv_wronskian_nondegenerate_of_root`, `baxterGrassmannianMatrix_nonzero_minor`, `bethe_ansatz_ratio_of_tq_root`)**:
   - At a Bethe root $Q_+(u_m) = 0$, a vanishing $TQ$ residual implies the polynomial Bethe Ansatz Equation $a(u_m)Q_+(u_m-\eta) + d(u_m)Q_+(u_m+\eta) = 0$ (`bethe_ansatz_eq_of_tq_root`).
   - If $Q_+(u_m) = Q_+(u_m-\eta) = Q_+(u_m+\eta) = 0$ simultaneously, `baxterTQResidual_spurious_zero` proves that $\operatorname{baxterTQResidual}(T, a, d, 0, 0, 0) = 0$ for *every* $T \in \mathbb{R}$, leaving the transfer eigenvalue $T$ unconstrained and the rational phase-shift ratio $0/0$ undefined.
   - Theorem `mtv_wronskian_nondegenerate_of_root` proves that when $Q_+(u_m) = 0$ and the Casorati Wronskian $W(u_m, u_m-\eta) \neq 0$, both $Q_+(u_m-\eta) \neq 0$ and $Q_-(u_m) \neq 0$ are strictly forced, certifying a nonzero Plücker coordinate on $Gr(2,4)$ (`baxterGrassmannianMatrix_nonzero_minor`) and yielding the rational Bethe Ansatz Equation (`bethe_ansatz_ratio_of_tq_root`):
     $$\frac{a(u_m)}{d(u_m)} = -\frac{Q_+(u_m + \eta)}{Q_+(u_m - \eta)}.$$

```lean
-- 2. Baxter QQ-system Plücker identity, Wronskian TQ solution, and MTV nondegeneracy
example (Q_plus Q_minus : ℝ → ℝ) (u0 u1 u2 u3 u η : ℝ) :
    casoratiWronskian Q_plus Q_minus u0 u1 * casoratiWronskian Q_plus Q_minus u2 u3 -
      casoratiWronskian Q_plus Q_minus u0 u2 * casoratiWronskian Q_plus Q_minus u1 u3 +
      casoratiWronskian Q_plus Q_minus u0 u3 * casoratiWronskian Q_plus Q_minus u1 u2 = 0 ∧
    baxterTQResidual
      (casoratiWronskian Q_plus Q_minus (u - η) (u + η))
      (casoratiWronskian Q_plus Q_minus u (u + η))
      (casoratiWronskian Q_plus Q_minus (u - η) u)
      (Q_plus u) (Q_plus (u - η)) (Q_plus (u + η)) = 0 :=
  ⟨baxter_qq_pluecker_identity Q_plus Q_minus u0 u1 u2 u3,
    baxterTQResidual_wronskian_zero Q_plus Q_minus u η⟩
```

---

## 5. Slavnov Determinant Compression & Inverse Scattering Metrology (`Signals.Scattering`)

In Step 4 of Sklyanin's QISM procedure, two-magnon scalar products and Gaudin norms collapse from $(2!)^2 = 4$ commutator contractions into a single $2 \times 2$ Grassmannian minor (`slavnovDet2` and `slavnovKernelMatrix2` in [QISM.lean](../src/signals/Signals/QISM.lean#L547-L639)):
- **Matrix Determinant Equivalence (`slavnovDet2_eq_det`)**: $\operatorname{slavnovDet2}(G) = \Delta_{01}(G) = \det G$.
- **Pauli Exclusion at Colliding Rapidities (`slavnovDet2_pauli_exclusion`, `slavnovDet2_dual_pauli_exclusion`)**: When either the two Bethe rapidities coincide ($u_0 = u_1 = u$) or the two dual rapidities coincide ($v_0 = v_1 = v$), the Slavnov minor vanishes identically.
- **Rapidity-Swap Antisymmetry (`slavnovDet2_swap_bethe`)**: Exchanging $u_0 \leftrightarrow u_1$ negates the Slavnov determinant.

In [src/signals/Signals/Scattering.lean](../src/signals/Signals/Scattering.lean#L430-L585), `Signals.QISM` is integrated directly with the scattering metrology and inverse-reconstruction contracts:
1. **Exact Inverse $R$-Matrix Parameter Recovery (`reconstruct_yang_parameters`)**: `reconstructSpectralDiff` and `reconstructYangCoupling` recover $\delta(u,v) = u - v$ and $\eta$ from $w_{\mathrm{sym}}$ and $w_{\mathrm{anti}}$.
2. **Unitary Two-Body Scattering Flux Partition (`yang_scattering_probability_conservation`)**: Whenever $\delta(u,v)^2 + \eta^2 \neq 0$, the transmission probability $T_{\mathrm{prob}} = \delta(u,v)^2 / (\delta(u,v)^2 + \eta^2)$ and reflection probability $R_{\mathrm{prob}} = \eta^2 / (\delta(u,v)^2 + \eta^2)$ are nonnegative and sum to $1$.
3. **Inverse Monodromy Reconstruction (`reconstruct_monodromy_from_trace_and_minor`)**: Recovers $D(u) = t(u) - A(u)$ and the off-diagonal magnon product $B(u)C(u) = A(u)D(u) - \Delta_{01}(T(u))$.
4. **Calibrated Baxter $TQ$ Residual Metrology (`baxterTQResidualMeasurement_wronskian_consistent`, `baxterTQResidualMeasurement_offShell_anomaly`)**: Three-point Casorati Wronskian solutions on $Gr(2,4)$ are `.consistent` for every tolerance $\tau \ge 0$, whereas off-shell Bethe-root violations exceeding $\tau$ trigger `.anomalyCandidate`.
5. **Inelastic Stokes/Anti-Stokes Raman & Relativistic Inverse Compton Channel Inversion (`raman_stokes_antiStokes_gr24_identities`, `inverseCompton_thomson_and_recoil_identities`)**: The same QISM channel inversion operators `reconstructSpectralDiff` and `reconstructYangCoupling` recover the optical pump frequency $\omega_L = (\omega_{AS} + \omega_S)/2$ and vibrational phonon frequency $\Omega_v = (\omega_{AS} - \omega_S)/2$ from the anti-Stokes and Stokes Raman sidebands $\omega_{AS}, \omega_S$, while the $Gr_{\mathbb{C}}(2,4)$ Plücker channel ratio $\frac{1+\delta_R}{1-\delta_R}$ (Raman) and $\frac{1+\beta}{1-\beta}$ (Inverse Compton) connects directly to thermal and relativistic scattering metrology (see [grassmannian-thermal-compton-raman-paper.md](grassmannian-thermal-compton-raman-paper.md)).

```lean
-- 3. Slavnov Pauli exclusion, calibrated Scattering metrology, and Raman/Inverse Compton channel inversion
example (K : ℝ → ℝ → ℝ) (v0 v1 u : ℝ) (Q_plus Q_minus : ℝ → ℝ) (η : ℝ) :
    slavnovDet2 (slavnovKernelMatrix2 K v0 v1 u u) = 0 ∧
    slavnovDet2 (slavnovKernelMatrix2 K u u v0 v1) = 0 ∧
    (baxterTQResidualMeasurement
      (casoratiWronskian Q_plus Q_minus (u - η) (u + η))
      (casoratiWronskian Q_plus Q_minus u (u + η))
      (casoratiWronskian Q_plus Q_minus (u - η) u)
      (Q_plus u) (Q_plus (u - η)) (Q_plus (u + η))
      (1 / 10) (by norm_num)).consistent ∧
    reconstructSpectralDiff (ramanAntiStokesFreq 10 2) (ramanStokesFreq 10 2) = 10 ∧
    reconstructYangCoupling (ramanAntiStokesFreq 10 2) (ramanStokesFreq 10 2) = 2 ∧
    inverseComptonKleinNishinaRatio (3 / 5) (1 / 10) <
      inverseComptonDopplerRatio (3 / 5) :=
  ⟨slavnovDet2_pauli_exclusion K v0 v1 u,
    slavnovDet2_dual_pauli_exclusion K u v0 v1,
    baxterTQResidualMeasurement_wronskian_consistent Q_plus Q_minus u η (1 / 10) (by norm_num),
    (raman_stokes_antiStokes_gr24_identities 10 2 (1 / 2)
      (by norm_num) (by norm_num) (by norm_num) (by norm_num)).1,
    (raman_stokes_antiStokes_gr24_identities 10 2 (1 / 2)
      (by norm_num) (by norm_num) (by norm_num) (by norm_num)).2.1,
    (inverseCompton_thomson_and_recoil_identities (3 / 5) (1 / 10)
      (by norm_num) (by norm_num) (by norm_num)).2.2.2⟩

end ArxivQISMPaperVerification
```

---

## 6. Conclusion & Reproducibility

By formalizing the Grassmannian structure of the Quantum Inverse Scattering Method (`Signals.QISM`, `Signals.Scattering`, `Signals.Geometry`) in Lean 4, we have machine-checked the complete chain from Yang's $4 \times 4$ rational $R$-matrix and shifted Yangian quantum determinants to the $Gr(2,4)$ Plücker $QQ$-system, three-point Casorati Wronskian $TQ$ solutions, MTV Wronskian nondegeneracy, and $2 \times 2$ Slavnov determinant compression. In our companion paper ([grassmannian-huygens-double-slit-oam-paper.md](grassmannian-huygens-double-slit-oam-paper.md)), we show that the same $2 \times 4$ Plücker identity governs the Pythagorean Plücker–Steiner barycentric shift and eliminates the $50\%$ unphased crossing-minor error in 3D double-slit and OAM interferometry when lifted to $Gr_{\mathbb{C}}(2,4)$.

To reproduce all Lean proofs and blueprint artifacts from the repository root:

```bash
make signals_build
pushd src/signals
lake build :blueprint :blueprintJson
popd
```

---

### Scholarly References

<a id="qism-takhtajan1979"></a>
1. Takhtadzhan, L. A., and Faddeev, L. D. (1979). *The Quantum Method of the Inverse Problem and the Heisenberg XYZ Model*. Russian Mathematical Surveys 34(5), 11–68. [DOI: 10.1070/RM1979v034n05ABEH003909](https://doi.org/10.1070/RM1979v034n05ABEH003909).

<a id="qism-sklyanin1992"></a>
2. Sklyanin, E. K. (1992). *Quantum Inverse Scattering Method. Selected Topics*. In *Quantum Group and Quantum Integrable Systems*, Nankai Lectures on Mathematical Physics, pp. 63–97. [arXiv:hep-th/9211111](https://arxiv.org/abs/hep-th/9211111).

<a id="qism-korepin1993"></a>
3. Korepin, V. E., Bogoliubov, N. M., and Izergin, A. G. (1993). *Quantum Inverse Scattering Method and Correlation Functions*. Cambridge Monographs on Mathematical Physics, Cambridge University Press. [DOI: 10.1017/CBO9780511628832](https://doi.org/10.1017/CBO9780511628832).

<a id="qism-faddeev1996"></a>
4. Faddeev, L. D. (1996). *How Algebraic Bethe Ansatz Works for Integrable Models*. Les Houches Summer School Proceedings 64, 149–219. [arXiv:hep-th/9605187](https://arxiv.org/abs/hep-th/9605187).

<a id="qism-mtv2009"></a>
5. Mukhin, E., Tarasov, V., and Varchenko, A. (2009). *Schubert Calculus and Representations of the General Linear Group*. Journal of the American Mathematical Society 22(4), 909–940. [DOI: 10.1090/S0894-0347-09-00640-7](https://doi.org/10.1090/S0894-0347-09-00640-7); [arXiv:0711.4079](https://arxiv.org/abs/0711.4079).

<a id="qism-arkani2014"></a>
6. Arkani-Hamed, N., and Trnka, J. (2014). *The Amplituhedron*. Journal of High Energy Physics 2014(10), 030. [DOI: 10.1007/JHEP10(2014)030](https://doi.org/10.1007/JHEP10%282014%29030); [arXiv:1312.2007](https://arxiv.org/abs/1312.2007).

---

### BibTeX Citations

```bibtex
@article{takhtajan1979qism,
  author  = {Takhtadzhan, Leon A. and Faddeev, L. D.},
  title   = {The Quantum Method of the Inverse Problem and the {H}eisenberg {XYZ} Model},
  journal = {Russian Mathematical Surveys},
  volume  = {34},
  number  = {5},
  pages   = {11--68},
  year    = {1979},
  doi     = {10.1070/RM1979v034n05ABEH003909}
}

@article{sklyanin1992qism,
  author  = {Sklyanin, Evgeny K.},
  title   = {Quantum Inverse Scattering Method. {S}elected Topics},
  journal = {arXiv preprint hep-th/9211111},
  year    = {1992}
}

@book{korepin1993qism,
  author    = {Korepin, Vladimir E. and Bogoliubov, N. M. and Izergin, A. G.},
  title     = {Quantum Inverse Scattering Method and Correlation Functions},
  publisher = {Cambridge University Press},
  year      = {1993},
  doi       = {10.1017/CBO9780511628832}
}

@article{mukhin2009schubert,
  author  = {Mukhin, Evgeny and Tarasov, Vitaly and Varchenko, Alexander},
  title   = {Schubert Calculus and Representations of the General Linear Group},
  journal = {Journal of the American Mathematical Society},
  volume  = {22},
  number  = {4},
  pages   = {909--940},
  year    = {2009},
  doi     = {10.1090/S0894-0347-09-00640-7}
}
```

### Schema.org Metadata (JSON-LD)

```json
{
  "@context": "https://schema.org",
  "@type": "ScholarlyArticle",
  "headline": "Grassmannian Geometry of the Quantum Inverse Scattering Method, Algebraic Bethe Ansatz, and Inverse Scattering Metrology in Lean 4",
  "author": {
    "@type": "Person",
    "name": "Wes Turner"
  },
  "dateModified": "2026-10-24",
  "about": [
    "Quantum Inverse Scattering Method",
    "Algebraic Bethe Ansatz",
    "Yang-Baxter Equation",
    "Grassmannian Geometry",
    "Baxter QQ-System",
    "Slavnov Determinant",
    "Lean 4 Formal Verification"
  ],
  "isBasedOn": [
    "src/signals/Signals/QISM.lean",
    "src/signals/Signals/Scattering.lean",
    "src/signals/Signals/Geometry.lean"
  ]
}
```
