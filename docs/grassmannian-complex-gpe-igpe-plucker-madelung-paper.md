---
title: "Complex Grassmannian Gr_C(2,4) Fubini–Study Gross–Pitaevskii Equation, Dual-Schubert iGPE, and Homogeneous Plücker Madelung Hydrodynamics on the Klein Quadric Q_4 in Lean 4 and Rust/WASM"
description: "An arXiv-ready MyST Markdown formal verification and numerical simulation paper formulating the Gross–Pitaevskii equation (GPE), coupled Dual-Grassmannian interactive/inverse Gross–Pitaevskii (iGPE) system on Gr_C(2,4) × Gr_C(2,4)∨, Fubini–Study Bogoliubov dispersion and critical Deborah shear-fracture threshold (De/De_c ≥ 1), and homogeneous Plücker 6-vector Madelung hydrodynamics on the Klein quadric Q_4 ⊂ P^5(C) in Lean 4 and Rust/WASM."
---

(grassmannian-complex-gpe-igpe-plucker-madelung-paper)=
# Complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ Fubini–Study Gross–Pitaevskii Equation, Dual-Schubert `iGPE`, and Homogeneous Plücker Madelung Hydrodynamics on the Klein Quadric $\mathcal{Q}_4$ in Lean 4 and Rust/WASM

- **Authors:** Wes Turner
- **Subjects:**
  - Mathematical Physics (`math-ph`); Quantum Gases (`cond-mat.quant-gas`); High Energy Physics - Theory (`hep-th`); General Relativity and Quantum Cosmology (`gr-qc`); Logic in Computer Science (`cs.LO`)
- **Formal Verification & Simulation Artifacts:**
  - `Signals` Lean 4 Library (`leanprover/lean4:v4.35.0-rc3`, [../src/signals/Signals/DDF.lean](../src/signals/Signals/DDF.lean#L8346-L9304), [../src/signals/Signals/Pending.lean](../src/signals/Signals/Pending.lean#L5495-L5630), [../src/signals/SignalsPending.lean](../src/signals/SignalsPending.lean#L172-L212), [../src/signals/SignalsTests.lean](../src/signals/SignalsTests.lean#L6496-L6568), [../src/signals/SignalsPendingTests.lean](../src/signals/SignalsPendingTests.lean#L5250-L5332))
  - `Signals` LeanArchitect Blueprint ([../src/signals/blueprint/src/content.tex](../src/signals/blueprint/src/content.tex#L315-L385))
  - `signals-numerical-adapter` Rust/WASM Engine ([../src/signals/numerical_adapter/src/madelung_lagrangian.rs](../src/signals/numerical_adapter/src/madelung_lagrangian.rs#L616-L1060))
  - Canonical `src/signals/docs/` Mirror: [../src/signals/docs/grassmannian-complex-gpe-igpe-plucker-madelung-paper.md](../src/signals/docs/grassmannian-complex-gpe-igpe-plucker-madelung-paper.md)
- **Companion Papers:**
  - [From Superfluid Gross–Pitaevskii Action and Madelung Polar Substitution to Euler–Lagrange Hydrodynamics and Dilatant Dark Fluid (DDF) Jamming Recovery in Complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ Mechanics](grassmannian-madelung-lagrangian-ddf-jamming-paper.md)
  - [Hawking Radiation, Inverse Gross–Pitaevskii (`iGPE`) Unwinding, and Amplituhedron/CP-ALS Decoding in Complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ and Dilatant Dark Fluid (DDF) Mechanics](grassmannian-hawking-radiation-decoding-paper.md)
  - [Grassmannian Gravity from QED & Gauge Scattering Amplitudes: Complex $Gr_{\mathbb{C}}(2,4)$ Orbital Precession, Mercury's Perihelion, $N$-Body Dynamics, and Dilatant Dark Fluid (DDF) Unification in Lean 4](grassmannian-gravity-from-qed-scattering-paper.md)
  - [Unification, Engineering Applications, and Research Roadmap of Complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ and Dilatant Dark Fluid (DDF) Mechanics](grassmannian-unification-applications-roadmap-paper.md)

---

## Abstract

In our earlier formalizations of Madelung quantum hydrodynamics ([grassmannian-madelung-lagrangian-ddf-jamming-paper.md](grassmannian-madelung-lagrangian-ddf-jamming-paper.md)) and Inverse Gross–Pitaevskii (`iGPE`) potential unwinding ([grassmannian-hawking-radiation-decoding-paper.md](grassmannian-hawking-radiation-decoding-paper.md)), the Gross–Pitaevskii Lagrangian density $\mathcal{L}_{\mathrm{GP}}$ and Quantum Hamilton–Jacobi (QHJ) equation were formulated on 4D spacetime $\mathbb{R}^{1,3}$, while the complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ entered through boundary Plücker channel matrices $M_{\mathbb{C}}(z_1, z_2)$ encoding reduced sheath velocity $\beta = v/c$, orbital eccentricity $e$, or $\text{AdS}_5$ black-brane emblackening.

In this paper—motivated by and auditing the research derivation in [Gemini: Grassmannian Gross–Pitaevskii Equation Formulation (2026)](#cgpe-chat-gpe2026) ({download}`data/chats/Gemini_Grassmannian-Gross-Pitaevskii-Equation-Formulation_20261103-1045.md, lines 1-1458 <../data/chats/Gemini_Grassmannian-Gross-Pitaevskii-Equation-Formulation_20261103-1045.md>`)—we lift the Gross–Pitaevskii equation, the coupled interactive/inverse `iGPE`, and the Madelung transformation **directly onto the Kähler manifold $Gr_{\mathbb{C}}(2,4) \cong \mathcal{Q}_4 \subset \mathbb{P}^5(\mathbb{C})$ without the positive Grassmannian ($Gr^+(2,4)$) restriction**, and machine-check the resulting theorems in Lean 4 (`Signals.DDF` and `Signals.Pending`) and Rust/WebAssembly (`madelung_lagrangian.rs`):

1. **Homogeneous Plücker 6-Vector Geometry on $\mathcal{Q}_4 \subset \mathbb{P}^5(\mathbb{C})$, Hodge-Dual Involution, & Corrected Hermitian Tangent Projector $\mathcal{H}^{I\bar{J}}$ (`plucker_hodge_klein_quadric_and_projector_identities`)**:
   Every $2 \times 4$ complex twistor matrix $Z \in \mathbb{C}^{2 \times 4}$ maps to a 6-component Plücker vector $p(Z) = (\Delta_{01}^{\mathbb{C}}, \Delta_{02}^{\mathbb{C}}, \Delta_{03}^{\mathbb{C}}, \Delta_{12}^{\mathbb{C}}, \Delta_{13}^{\mathbb{C}}, \Delta_{23}^{\mathbb{C}}) \in \mathbb{C}^6$ (`twistorToPluckerVec`) satisfying the Klein quadric constraint $\mathcal{C}(p) = \sum_{I=0}^5 p_I \tilde{p}^I = 2(p_{01}p_{23} - p_{02}p_{13} + p_{03}p_{12}) = 0$ (`OnKleinQuadric`), where $\tilde{p} = (p_{23}, -p_{13}, p_{12}, p_{03}, -p_{02}, p_{01})$ is the Hodge dual (`pluckerHodgeDual`). We prove that $\tilde{\tilde{p}} = p$ and $\|\tilde{p}\|^2 = \|p\|^2$, and we resolve a subtle complex-conjugation bug in the raw chat SymPy script (lines 1108, 1219–1232): over $\mathbb{C}^6$, the Hermitian normal to the holomorphic quadric $\mathcal{C}(p) = 0$ is the **conjugate** Hodge dual $n_I(p) = \overline{\tilde{p}_I}$ (`pluckerConjHodgeNormal`), for which $\langle p, \overline{\tilde{p}}\rangle = \overline{\mathcal{C}(p)} = 0$ and the intrinsic contravariant Plücker metric operator $\mathcal{H}(p, \bar{p})\,v = \|p\|^2 v - \langle p, v\rangle p - \langle \overline{\tilde{p}}, v\rangle \overline{\tilde{p}}$ (`pluckerContravariantMetricApply`) annihilates both radial Euler scaling ($\mathcal{H}\,p = 0$) and quadric normal variations ($\mathcal{H}\,\overline{\tilde{p}} = 0$) identically.
2. **Canonical Affine Chart $Z = (I_2 \mid W)$, Cauchy–Binet Kähler–Plücker Identity $\det(I_2 + W W^\dagger) = \|p(I_2 \mid W)\|^2 \ge 1$, & Fubini–Study Kinetic Operator (`kahlerDetFactor_eq_pluckerNormSq_and_ge_one`)**:
   On the canonical affine chart $Z = \operatorname{chartToTwistor}(W) = (I_2 \mid W)$ ($W \in \mathbb{C}^{2 \times 2}$, $p_{01} = 1$, $p_{23} = \det W$), we prove that the Fubini–Study Kähler potential determinant argument $\operatorname{kahlerDetFactor}(W) = 1 + \|W\|_{\mathrm{HS}}^2 + |\det W|^2$ equals the ambient Plücker norm squared $\|p(I_2 \mid W)\|_{\mathbb{C}^6}^2 \ge 1$, and that the inverse Fubini–Study kinetic norm $\operatorname{Re}\operatorname{Tr}((I_2 + W W^\dagger) K (I_2 + W^\dagger W) K^\dagger)$ (`fubiniStudyKineticNorm`) reduces at $W = 0$ to the Frobenius norm $\|K\|_{\mathrm{HS}}^2 \ge 0$.
3. **Coupled Dual-Grassmannian `iGPE` ($Gr_{\mathbb{C}}(2,4) \times Gr_{\mathbb{C}}(2,4)^\vee$), Symplectic Norm Balance, & Chiral Josephson Schubert Tunneling (`grassmannian_igpe_norm_balance_and_josephson_identities`)**:
   Coupling a primary condensate $\Psi(\mathbf{Z}, \tau)$ on $\mathbf{Z} \in Gr_{\mathbb{C}}(2,4)$ to its orthogonal dual condensate $\Phi(\mathbf{Z}^\perp, \tau)$ on $\mathbf{Z}^\perp \in Gr_{\mathbb{C}}(2,4)^\vee$ via Schubert incidence coupling $\lambda \in \mathbb{C}$ proves that individual branch densities exchange probability via the chiral Josephson current $J_{\mathrm{Josephson}} = 2\operatorname{Im}(\bar{\Psi}\lambda\Phi)$, while all real kinetic, Fubini–Study curvature, nonlinear contact, and Hermitian Schubert couplings cancel identically in the total norm rate:

   $$
   \frac{d}{d\tau'}\bigl(|\Psi|^2 + |\Phi|^2\bigr) = 2\,\operatorname{Im}(V_{\mathrm{ext}})\,\bigl(|\Psi|^2 + |\Phi|^2\bigr).
   $$

4. **Complex Grassmannian Bogoliubov Dispersion ($R_{\mathrm{Gr}}(2,4) = 16 \implies \Delta_R = \hbar^2/\mathcal{M}$), Emergent Proca Mass, & Critical Deborah Shear-Fracture Equivalence (`grassmannian_bogoliubov_proca_and_deborah_fracture_identities`)**:
   We prove that the Einstein–Kähler scalar curvature $R_{\mathrm{Gr}}(k, n) = n k (n - k)$ equals $16$ on $Gr_{\mathbb{C}}(2,4)$, that repulsive condensates ($g \ge 0, \rho_0 \ge 0$) are strictly stable ($\hbar^2\omega^2 > 0$), and that in the uncoupled Hermitian limit ($\lambda = 0, \operatorname{Im}(V_{\mathrm{ext}}) = 0$), tachyonic Bogoliubov instability ($\hbar^2\omega^2 < 0$) is **mathematically equivalent** to exceeding the critical Deborah vacuum shear-fracture threshold ($\mathrm{De}/\mathrm{De}_c > 1$).
5. **Homogeneous Plücker Madelung QHJ, Plücker `iGPE` Potential Inversion, & Penrose Self-Dual Weyl Curvature Dictionary (`plucker_madelung_qhj_inverse_igpe_and_weyl_bridge_identities`)**:
   We formulate the Madelung Quantum Hamilton–Jacobi equation and inverse `iGPE` potential reconstruction (`pluckerInversePotentialReconstruction`) directly in homogeneous Plücker coordinates on $\mathcal{Q}_4$, prove exact QHJ residual cancellation ($\mathcal{R}_{\mathrm{QHJ}}^{\mathrm{Pl\ddot{u}cker}} = 0$), contrast phase-locked ($\Delta\theta = 0$) vs. chiral $\pi/2$ phase-slip ($\Delta\theta = \pi/2$) Josephson tunneling, and prove the Penrose incidence identity relating the Plücker Bohmian quantum potential $Q_{\mathrm{Pl\ddot{u}cker}}$ to the self-dual Weyl curvature spinor projection $\Psi_{ABCD}$.

---

## 1. Architectural Synthesis: How Intrinsic Complex Grassmannian GPE/iGPE Extends Existing `Signals` Models

A central question when reviewing [Gemini: Grassmannian Gross–Pitaevskii Equation Formulation (2026)](#cgpe-chat-gpe2026) is: **what was already implemented in `Signals`, and what new mathematical capabilities does the intrinsic $Gr_{\mathbb{C}}(2,4) \cong \mathcal{Q}_4$ formulation provide?**

```{mermaid}
flowchart TB
    subgraph Existing["Previously Formalized in Signals.DDF, Signals.HawkingRadiation, & Signals.Pending"]
        E1["Spacetime GP Polar Action & Madelung QHJ (Paper 15)\n• ψ(A, θ) = A exp(iS/ℏ) on ℝ^{1,3}\n• L_GP = L_Mad = L_Mad^ρ, H_Mad ≥ 0\n• Continuity ∂_t ρ + ∇·(ρ v_ϕ) = 0 & QHJ on ℝ^{1,3}\n• Sheath Jamming Λ_∥(v) = γ_φ(v) & dτ_D = dt/γ_φ(v)"]
        E2["Three Pointwise/Spacetime Meanings of iGPE (Paper 16)\n1. InteractiveGPEPoint: local g|ψ|²ψ on ℝ^{1,3}\n2. InhomogeneousGPEPoint: external source S_ext\n3. InverseGPEPoint & madelungInversePotentialReconstruction:\n   reconstructs V_ext(x) from (A, ΔA, ∂_t S, v_ϕ)"]
    end

    subgraph New["New in This Work: Intrinsic Kähler Gr_C(2,4) & Homogeneous Plücker Q_4 Formulation"]
        N1["1. Homogeneous Plücker 6-Vector Calculus on Q_4 ⊂ P^5(C)\n• twistorToPluckerVec Z ∈ C^6, pluckerHodgeDual p̃\n• Klein quadric C(p) = p_I p̃^I = 0 (OnKleinQuadric)\n• Corrected Hermitian normal n(p) = conj(p̃)\n• Contravariant metric H^{IJ̄} annihilating p and conj(p̃)"]
        N2["2. Fubini–Study Affine Chart Z = (I_2 | W) on Gr_C(2,4)\n• Cauchy–Binet Kähler identity: det(I_2 + W W†) = ‖p(I_2 | W)‖² ≥ 1\n• Inverse Fubini–Study kinetic norm Tr((I_2+WW†)K(I_2+W†W)K†)\n• GL(2,C) modular-weighted contact coupling g det(I_2+WW†)^{-w}|Ψ|²"]
        N3["3. Fourth Meaning of iGPE: Coupled Dual-Grassmannian iGPE\n• Orthogonal 2-planes (Z, Z⊥) ∈ Gr_C(2,4) × Gr_C(2,4)∨ (p ↔ p̃)\n• Chiral Josephson Schubert current J_Jos = 2 Im(Ψ̄ λ Φ)\n• Exact symplectic norm balance d(|Ψ|²+|Φ|²)/dτ' = 2 V_im(|Ψ|²+|Φ|²)"]
        N4["4. Complex Grassmannian Bogoliubov, Deborah Fracture, & Plücker Madelung\n• Einstein–Kähler curvature gap R_Gr(2,4) = 16 ⇒ Δ_R = ℏ²/ℳ\n• Tachyonic fracture equivalence: ℏ²ω² < 0 ⇔ De/De_c > 1\n• Homogeneous Plücker QHJ, pluckerInversePotentialReconstruction,\n  & Penrose Bohm–Weyl curvature dictionary"]
    end

    E1 --> N1
    E2 --> N3
    N1 --> N2 --> N3 --> N4
```

### 1.1 Unifying All Four Meanings of “iGPE” Across the Research Corpus

With this extension, `Signals` provides machine-checked definitions and theorems for all **four** distinct formulations abbreviated as `iGPE` across the research chats:

| # | `iGPE` Variant | Mathematical Domain | Governing Equation / Reconstruction Law | Lean 4 Declarations |
|---|---|---|---|---|
| **1** | **Interactive GPE** | Spacetime $\mathbb{R}^{1,3}$ or affine chart $W \in Gr_{\mathbb{C}}(2,4)$ | $i\hbar\partial_t\psi = \bigl(-\frac{\hbar^2}{2m}\Delta + V_{\mathrm{ext}} + g\|\psi\|^2\bigr)\psi$ (or $g\det(I_2 + W W^\dagger)^{-w}\|\Psi\|^2\Psi$ on $Gr_{\mathbb{C}}(2,4)$) | `Signals.Pending.InteractiveGPEPoint`, `Signals.DDF.grassmannianNonLinearPotential` |
| **2** | **Inhomogeneous GPE** | Driven condensate with external source $S_{\mathrm{ext}}$ | $i\hbar\partial_t\psi = \bigl(-\frac{\hbar^2}{2m}\Delta + V_{\mathrm{ext}} + g\|\psi\|^2\bigr)\psi + S_{\mathrm{ext}}$ | `Signals.Pending.InhomogeneousGPEPoint` |
| **3a** | **Spacetime Inverse GPE** | Pointwise complex $(\psi, \partial_t\psi, \Delta\psi)$ or continuum Madelung $(A, \Delta A, \partial_t S, v_\phi)$ | $V_{\mathrm{ext}} = -\partial_t S - \frac{1}{2}m_\phi v_\phi^2 - g_\phi A^2 + \frac{\hbar^2}{2m_\phi}\frac{\Delta A}{A}$ | `Signals.Pending.InverseGPEPoint`, `Signals.HawkingRadiation.madelungInversePotentialReconstruction` |
| **3b** | **Homogeneous Plücker Inverse GPE** | Klein quadric $\mathcal{Q}_4 \subset \mathbb{P}^5(\mathbb{C})$ ($p \in \mathbb{C}^6, \mathcal{C}(p) = 0$) | $V_{\mathrm{ext,re}}^{\mathrm{rec}}(p) = -\partial_\tau S_R - \frac{1}{\mathcal{M}}\mathcal{H}_{I\bar{J}}V^I\bar{V}^{\bar{J}} - g\bigl(\frac{\|p_0\|^2}{\|p\|^2}\bigr)^w\rho - Q_{\mathrm{Pl\ddot{u}cker}}(\rho) - \Lambda_{\mathrm{dual}}(p, \tilde{p})$ | `Signals.DDF.pluckerInversePotentialReconstruction`, `plucker_madelung_qhj_inverse_igpe_and_weyl_bridge_identities` |
| **4** | **Dual-Grassmannian Interactive GPE** | Orthogonal 2-planes $(\mathbf{Z}, \mathbf{Z}^\perp) \in Gr_{\mathbb{C}}(2,4) \times Gr_{\mathbb{C}}(2,4)^\vee$ ($p_I \leftrightarrow \tilde{p}^I$) | Coupled $(\Psi(\mathbf{Z}), \Phi(\mathbf{Z}^\perp))$ with Schubert incidence coupling $\lambda \in \mathbb{C}$ and Josephson current $J_{\mathrm{Josephson}} = 2\operatorname{Im}(\bar{\Psi}\lambda\Phi)$ | `Signals.DDF.CoupledDualGrassmannianState`, `grassmannian_igpe_norm_balance_and_josephson_identities` |

---

## 2. Homogeneous Plücker 6-Vector Calculus on $\mathcal{Q}_4 \subset \mathbb{P}^5(\mathbb{C})$ & Mathematical Audit of the Contravariant Metric $\mathcal{H}^{I\bar{J}}$

### 2.1 Plücker Embedding, Hodge Duality, and the Klein Quadric $\mathcal{Q}_4$

In homogeneous twistor coordinates ([Penrose 1967](#cgpe-penrose1967); [Penrose 1976](#cgpe-penrose1976); [Arkani-Hamed and Trnka 2014](#cgpe-arkani2014)), a 2-plane in $\mathbb{C}^4$ represented by a $2 \times 4$ matrix $Z \in \mathbb{C}^{2 \times 4}$ maps via `twistorToPluckerVec` to the 6-component Plücker vector $p(Z) = (p_0, p_1, p_2, p_3, p_4, p_5) = (\Delta_{01}^{\mathbb{C}}, \Delta_{02}^{\mathbb{C}}, \Delta_{03}^{\mathbb{C}}, \Delta_{12}^{\mathbb{C}}, \Delta_{13}^{\mathbb{C}}, \Delta_{23}^{\mathbb{C}}) \in \mathbb{C}^6$ ({download}`data/chats/Gemini_Grassmannian-Gross-Pitaevskii-Equation-Formulation_20261103-1045.md, lines 14-35 <../data/chats/Gemini_Grassmannian-Gross-Pitaevskii-Equation-Formulation_20261103-1045.md>`).

Defining the **Hodge-dual Plücker 6-vector** (`pluckerHodgeDual`, lines 1110, 1249–1256):

$$
\tilde{p} = \operatorname{pluckerHodgeDual}(p) = (p_5, -p_4, p_3, p_2, -p_1, p_0) = (p_{23}, -p_{13}, p_{12}, p_{03}, -p_{02}, p_{01}),
$$

the **Klein quadric $\mathcal{Q}_4 \subset \mathbb{P}^5(\mathbb{C})$** is the locus where the holomorphic bilinear pairing vanishes (`kleinQuadricForm`, `OnKleinQuadric`):

$$
\mathcal{C}(p) = \sum_{I=0}^5 p_I \tilde{p}^I = 2\bigl(p_0 p_5 - p_1 p_4 + p_2 p_3\bigr) = 0.
$$

### 2.2 Mathematical Audit & Correction of the Chat's SymPy Contravariant Metric Projector

In Section 1 and Section 4 of [Gemini: Grassmannian Gross–Pitaevskii Equation Formulation (2026)](#cgpe-chat-gpe2026) ({download}`lines 1106-1114 and 1200-1236 <../data/chats/Gemini_Grassmannian-Gross-Pitaevskii-Equation-Formulation_20261103-1045.md>`), the chat defines $\tilde{p} = \eta p$ without complex conjugation and writes the contravariant metric projector on $\mathbb{C}^6$ as:

$$
\mathcal{H}_{\mathrm{raw}}^{I\bar{J}} = \|p\|^2\left(\delta^{IJ} - \frac{p^I\bar{p}^J}{\|p\|^2} - \frac{\tilde{p}^I\bar{\tilde{p}}^J}{\|p\|^2}\right).
$$

**Audit Finding**: Under the standard Hermitian inner product $\langle u, v\rangle = \sum_{I=0}^5 \overline{u_I}\,v_I$ (`pluckerHermitianInner`) on $\mathbb{C}^6$:
- Contracting the radial projector $p\,\bar{p}^T$ with the un-conjugated Hodge dual $\tilde{p}$ yields $\langle p, \tilde{p}\rangle = \sum_{I=0}^5 \bar{p}_I \tilde{p}_I = \bar{p}^T \eta p$, which is **not** zero on the complex Klein quadric $p^T \eta p = 0$ unless $p$ has constant phase (such as the real Grassmannian $p \in \mathbb{R}^6$)!
- Instead, because $\mathcal{C}(p) = \sum_{I=0}^5 p_I \tilde{p}_I = 0$ is a **holomorphic** quadratic constraint, its Hermitian normal covector in $\mathbb{C}^6$ is the **complex-conjugated Hodge dual** (`pluckerConjHodgeNormal`):

$$
n_I(p) = \overline{\tilde{p}_I} = (\bar{p}_5, -\bar{p}_4, \bar{p}_3, \bar{p}_2, -\bar{p}_1, \bar{p}_0).
$$

With $n(p) = \overline{\tilde{p}}$, the Hermitian inner products satisfy:

$$
\langle n(p), p\rangle = \sum_{I=0}^5 \tilde{p}_I p_I = \mathcal{C}(p) = 0, \qquad
\langle p, n(p)\rangle = \overline{\mathcal{C}(p)} = 0, \qquad
\langle n(p), n(p)\rangle = \|\tilde{p}\|^2 = \|p\|^2,
$$

for **every** complex point $p \in \mathcal{Q}_4 \subset \mathbb{C}^6$! Defining the intrinsic contravariant Plücker metric operator (`pluckerContravariantMetricApply`) by:

$$
\bigl(\mathcal{H}(p, \bar{p})\,v\bigr)_I = \|p\|^2 v_I - \langle p, v\rangle\,p_I - \langle n(p), v\rangle\,n_I(p),
$$

Theorem `plucker_hodge_klein_quadric_and_projector_identities` ([../src/signals/Signals/DDF.lean](../src/signals/Signals/DDF.lean#L8482-L8566)) machine-checks:
1. $\operatorname{pluckerHodgeDual}(\operatorname{pluckerHodgeDual}(p)) = p$ (involution),
2. $\|\tilde{p}\|^2 = \|n(p)\|^2 = \|p\|^2$ (norm preservation),
3. $\operatorname{OnKleinQuadric}(\operatorname{twistorToPluckerVec}(Z))$ for all $Z \in \mathbb{C}^{2 \times 4}$, and
4. For every $p$ with $\operatorname{OnKleinQuadric}(p)$, $\mathcal{H}(p, \bar{p})\,p = 0$ (radial Euler scaling annihilation) and $\mathcal{H}(p, \bar{p})\,n(p) = 0$ (Klein quadric normal annihilation).

---

## 3. Canonical Affine Chart $Z = (I_2 \mid W)$, Cauchy–Binet Kähler–Plücker Identity, & Coupled Dual-Grassmannian `iGPE`

### 3.1 Cauchy–Binet Kähler Determinant Identity on $Gr_{\mathbb{C}}(2,4)$

In the canonical coordinate patch where $p_{01} = \Delta_{01}^{\mathbb{C}}(Z) = 1 \neq 0$, a 2-plane in $\mathbb{C}^4$ is represented by $Z = \operatorname{chartToTwistor}(W) = (I_2 \mid W)$ with $W \in \mathbb{C}^{2 \times 2}$ ({download}`lines 66-74, 179-196, 322-349 <../data/chats/Gemini_Grassmannian-Gross-Pitaevskii-Equation-Formulation_20261103-1045.md>`). The Fubini–Study metric $g_{a\alpha, \bar{b}\bar{\beta}} = \partial_{a\alpha}\bar{\partial}_{\bar{b}\bar{\beta}}\mathcal{K}$ derives from the Kähler potential $\mathcal{K}(W, W^\dagger) = \ln\det(I_2 + W W^\dagger)$.

Theorem `kahlerDetFactor_eq_pluckerNormSq_and_ge_one` ([../src/signals/Signals/DDF.lean](../src/signals/Signals/DDF.lean#L8634-L8715)) proves that the Kähler determinant factor (`kahlerDetFactor`) equals the sum of squared moduli of all six Plücker coordinates of $Z = (I_2 \mid W)$:

$$
\det(I_2 + W W^\dagger) = 1 + \|W\|_{\mathrm{HS}}^2 + |\det W|^2 = \sum_{0 \le i < j \le 3} \bigl|\Delta_{ij}^{\mathbb{C}}(I_2 \mid W)\bigr|^2 = \bigl\|p(I_2 \mid W)\bigr\|_{\mathbb{C}^6}^2 \ge 1,
$$

and that at the chart origin $W = 0$, the inverse Fubini–Study kinetic quadratic form (`fubiniStudyKineticNorm`):

$$
\mathcal{E}_{\mathrm{kin}}(W, K) = \frac{\hbar^2}{2\mathcal{M}}\operatorname{Re}\operatorname{Tr}\bigl((I_2 + W W^\dagger) K (I_2 + W^\dagger W) K^\dagger\bigr)
$$

reduces identically to $\frac{\hbar^2}{2\mathcal{M}}\|K\|_{\mathrm{HS}}^2 \ge 0$.

### 3.2 Coupled Dual-Grassmannian `iGPE` Symplectic Norm Balance & Chiral Josephson Tunneling

Every 2-plane $\mathbf{Z} \in Gr_{\mathbb{C}}(2,4)$ has a canonical orthogonal complement $\mathbf{Z}^\perp \in Gr_{\mathbb{C}}(2,4)^\vee$ ($\mathbf{Z}\cdot(\mathbf{Z}^\perp)^\dagger = 0$, represented in Plücker coordinates by the Hodge dual $\tilde{p}$). In the coupled Dual-Grassmannian `iGPE` (`CoupledDualGrassmannianState`, {download}`lines 118-128, 477-525 <../data/chats/Gemini_Grassmannian-Gross-Pitaevskii-Equation-Formulation_20261103-1045.md>`), the primary condensate $\Psi(\mathbf{Z}, \tau')$ and dual condensate $\Phi(\mathbf{Z}^\perp, \tau')$ evolve via:

$$
\frac{d\Psi}{d\tau'} = -i\Bigl(\bigl(H_0 + g_{\mathrm{nl}} + V_{\mathrm{re}} + i V_{\mathrm{im}}\bigr)\Psi + \lambda\Phi\Bigr), \qquad
\frac{d\Phi}{d\tau'} = -i\Bigl(\bigl(H_{0,\mathrm{dual}} + g_{\mathrm{dual,nl}} + V_{\mathrm{re}} + i V_{\mathrm{im}}\bigr)\Phi + \bar{\lambda}\Psi\Bigr).
$$

Theorem `grassmannian_igpe_norm_balance_and_josephson_identities` ([../src/signals/Signals/DDF.lean](../src/signals/Signals/DDF.lean#L8863-L8925)) proves:
1. **Individual Branch Rates & Chiral Josephson Schubert Current**:
   With $J_{\mathrm{Josephson}}(\Psi, \Phi, \lambda) = 2\operatorname{Im}(\bar{\Psi}\lambda\Phi)$ (`josephsonSchubertCurrent`),

   $$
   \frac{d}{d\tau'}|\Psi|^2 = 2\,V_{\mathrm{im}}\,|\Psi|^2 + J_{\mathrm{Josephson}}(\Psi, \Phi, \lambda), \qquad
   \frac{d}{d\tau'}|\Phi|^2 = 2\,V_{\mathrm{im}}\,|\Phi|^2 - J_{\mathrm{Josephson}}(\Psi, \Phi, \lambda).
   $$

2. **Exact Cancellation of Real Self-Energies & Josephson Tunneling in the Total Symplectic Norm**:

   $$
   \frac{d}{d\tau'}\bigl(|\Psi|^2 + |\Phi|^2\bigr) = 2\,V_{\mathrm{im}}\,\bigl(|\Psi|^2 + |\Phi|^2\bigr),
   $$

   which vanishes identically ($\frac{d}{d\tau'}(|\Psi|^2 + |\Phi|^2) = 0$) in the Hermitian limit $V_{\mathrm{im}} = 0$.

---

## 4. Complex Grassmannian Bogoliubov Dispersion, Critical Deborah Shear Fracture ($\mathrm{De}/\mathrm{De}_c \ge 1$), & Homogeneous Plücker Madelung Hydrodynamics

### 4.1 Einstein–Kähler Curvature Gap ($R_{\mathrm{Gr}}(2,4) = 16$) & Tachyonic Shear-Fracture Equivalence

Because $Gr_{\mathbb{C}}(k, n)$ is a compact Einstein–Kähler manifold of scalar curvature $R_{\mathrm{Gr}}(k, n) = n k (n - k)$ (`grassmannianEinsteinKahlerScalarCurvature`, equal to $16$ on $Gr_{\mathbb{C}}(2,4)$), the linearized Bogoliubov–de Gennes dispersion relation around a background density $\rho_0 > 0$ acquires the curvature gap $\Delta_R = \frac{\hbar^2}{\mathcal{M}}$ (`grassmannianBogoliubovOmegaSq`, {download}`lines 198-206, 398-408 <../data/chats/Gemini_Grassmannian-Gross-Pitaevskii-Equation-Formulation_20261103-1045.md>`):

$$
\hbar^2\omega^2(\mathbf{k}, W) = \left(\mathcal{E}_{\mathrm{kin}}(\mathbf{k}, W) + \frac{\hbar^2}{\mathcal{M}}\right)\left(\mathcal{E}_{\mathrm{kin}}(\mathbf{k}, W) + \frac{\hbar^2}{\mathcal{M}} + 2\,g_{\mathrm{eff}}(W)\rho_0\right), \qquad g_{\mathrm{eff}}(W) = g\,\det(I_2 + W W^\dagger)^{-w}.
$$

Defining the **Critical Deborah Vacuum Shear-Fracture Ratio** (`grassmannianDeborahFractureRatio`, {download}`lines 447-461 <../data/chats/Gemini_Grassmannian-Gross-Pitaevskii-Equation-Formulation_20261103-1045.md>`):

$$
\frac{\mathrm{De}}{\mathrm{De}_c} = \frac{\max\bigl(0, -2\operatorname{Re}(g_{\mathrm{eff}}\rho_0)\bigr) + |\operatorname{Im}(V_{\mathrm{ext}})|}{\frac{\hbar^2}{\mathcal{M}} + \mathcal{E}_{\mathrm{kin}}(\mathbf{k}, W) + |\lambda|},
$$

Theorem `grassmannian_bogoliubov_proca_and_deborah_fracture_identities` ([../src/signals/Signals/DDF.lean](../src/signals/Signals/DDF.lean#L9015-L9092)) proves:
- In the positive/repulsive sector ($g \ge 0, \rho_0 \ge 0$), $\hbar^2\omega^2(\mathbf{k}, W) > 0$ and $\mathrm{De}/\mathrm{De}_c = 0 < 1$ at $\operatorname{Im}(V_{\mathrm{ext}}) = 0$.
- In the uncoupled Hermitian limit ($|\lambda| = 0, \operatorname{Im}(V_{\mathrm{ext}}) = 0$), tachyonic shear fracture ($\hbar^2\omega^2(\mathbf{k}, W) < 0$, `IsShearFractureUnstable`) occurs **if and only if** $\mathrm{De}/\mathrm{De}_c > 1$:

$$
\hbar^2\omega^2(\mathbf{k}, W) < 0 \iff \frac{\mathrm{De}}{\mathrm{De}_c} > 1.
$$

### 4.2 Homogeneous Plücker Madelung QHJ, Plücker `iGPE` Potential Inversion, & Self-Dual Weyl Curvature Dictionary

Applying the polar Madelung ansatz $\Psi(p, \bar{p}, \tau) = \sqrt{\rho(p, \bar{p}, \tau)}\,\exp(i S_R(p, \bar{p}, \tau)/\hbar)$ directly in homogeneous Plücker coordinates on $\mathcal{Q}_4 \subset \mathbb{P}^5(\mathbb{C})$ (`PluckerMadelungState`, {download}`lines 1117-1190, 1279-1312 <../data/chats/Gemini_Grassmannian-Gross-Pitaevskii-Equation-Formulation_20261103-1045.md>`) yields the **Plücker Quantum Hamilton–Jacobi (QHJ) Equation** (`pluckerHamiltonJacobiResidual`):

$$
\frac{\partial S_R}{\partial\tau} + \frac{1}{\mathcal{M}}\mathcal{H}_{I\bar{J}}V^I\bar{V}^{\bar{J}} + \operatorname{Re}\bigl(V_{\mathrm{ext}}(p)\bigr) + g\left(\frac{|p_0|^2}{\|p\|^2}\right)^w\rho + Q_{\mathrm{Pl\ddot{u}cker}}(\rho) + \Lambda_{\mathrm{dual}}(p, \tilde{p}) = 0,
$$

where:
- $Q_{\mathrm{Pl\ddot{u}cker}}(\rho) = -\frac{\hbar^2}{2\mathcal{M}\sqrt{\rho}}\mathcal{H}^{I\bar{J}}\partial_I\bar{\partial}_{\bar{J}}\sqrt{\rho}$ (`pluckerQuantumPotential`) is the homogeneous Plücker Bohmian quantum potential, and
- $\Lambda_{\mathrm{dual}}(p, \tilde{p}) = \sqrt{\frac{\rho_{\mathrm{dual}}(\tilde{p})}{\rho(p)}}\bigl(\lambda_{\mathrm{re}}\cos\Delta\theta - \lambda_{\mathrm{im}}\sin\Delta\theta\bigr)$ (`dualJosephsonPotential`, $\Delta\theta = (S_{\mathrm{dual}} - S_R)/\hbar$) is the dual Schubert Josephson energy.

Theorem `plucker_madelung_qhj_inverse_igpe_and_weyl_bridge_identities` ([../src/signals/Signals/DDF.lean](../src/signals/Signals/DDF.lean#L9228-L9302)) proves four exact hydrodynamic and twistor-gravity identities:
1. **Homogeneous Plücker `iGPE` Potential Reconstruction**:
   Solving the Plücker QHJ equation for $V_{\mathrm{ext,re}}^{\mathrm{rec}}(p) = \operatorname{pluckerInversePotentialReconstruction}(\partial_\tau S_R, \hbar, \mathcal{M}, g, w, \lambda_{\mathrm{re}}, \lambda_{\mathrm{im}}, s)$ gives $\mathcal{R}_{\mathrm{QHJ}}^{\mathrm{Pl\ddot{u}cker}}(V_{\mathrm{ext,re}}^{\mathrm{rec}}) = 0$ identically.
2. **Phase-Locked Equilibrium ($\Delta\theta = 0, \lambda_{\mathrm{im}} = 0, V_{\mathrm{ext,im}} = 0$)**:
   The Plücker continuity source vanishes ($\Gamma_{\mathrm{Pl\ddot{u}cker}} = 0$) while the dual Josephson potential equals $\sqrt{\rho_{\mathrm{dual}}/\rho}\,\lambda_{\mathrm{re}}$.
3. **Chiral $\pi/2$ Phase-Slip Tunneling ($\Delta\theta = \pi/2, \lambda_{\mathrm{im}} = 0, V_{\mathrm{ext,im}} = 0$)**:
   The dual Josephson energy vanishes ($\Lambda_{\mathrm{dual}} = 0$) while the chiral tunneling source in the Plücker continuity equation reaches its maximum $\Gamma_{\mathrm{Pl\ddot{u}cker}} = \frac{2}{\hbar}\sqrt{\rho\,\rho_{\mathrm{dual}}}\,\lambda_{\mathrm{re}}$.
4. **Penrose Incidence Bohm–Weyl Curvature Dictionary (`reconstructWeylFromPluckerBohm`, lines 1353–1361)**:

   $$
   W_{\mathrm{Weyl}}(x) + \frac{1}{24}R_{4\mathrm{D}}(x) = \frac{2\mathcal{M}}{\hbar^2}Q_{\mathrm{Pl\ddot{u}cker}}(p, \bar{p}) = -\frac{\mathcal{H}^{I\bar{J}}\partial_I\bar{\partial}_{\bar{J}}\sqrt{\rho}}{\sqrt{\rho}}.
   $$

---

## 5. Application to Turner (2026) Models for Superposition, Gravity (1PN Perihelion), and Gravitational Waves (2.5PN & Ringdown Fracture)

How do the intrinsic Fubini–Study Kähler GPE, coupled Dual-Grassmannian `iGPE` ($Gr_{\mathbb{C}}(2,4) \times Gr_{\mathbb{C}}(2,4)^\vee$), Einstein–Kähler Bogoliubov / Deborah shear-fracture dispersion, and homogeneous Plücker $\mathcal{Q}_4 \subset \mathbb{P}^5(\mathbb{C})$ Madelung hydrodynamics apply to and upgrade our earlier (Turner 2026) models for **Superposition** ([grassmannian-huygens-double-slit-oam-paper.md](grassmannian-huygens-double-slit-oam-paper.md)), **Gravity**, and **Gravitational Waves** ([grassmannian-gravity-from-qed-scattering-paper.md](grassmannian-gravity-from-qed-scattering-paper.md))? In Section 30.6 of [../src/signals/Signals/DDF.lean](../src/signals/Signals/DDF.lean#L9305-L9710) (`turner_2026_revised_superposition_gravity_and_gw_plucker_igpe_models`), we formalize three foundational upgrades:

### 5.1 Revised Superposition Model (`pluckerMadelungSuperpositionOAMDoubleSlit`): Linear Superposition as the Klein Quadric Constraint & Dual-Schubert Origin of $\delta_{\mathrm{neq}}$

1. **Linear Wave Superposition Is Enforced by the Klein Quadric $\mathcal{C}(p) = 0$ on $\mathcal{Q}_4 \subset \mathbb{P}^5(\mathbb{C})$**:
   For the canonical complex channel matrix $M_{\mathbb{C}}(z_1, z_2) = \operatorname{complexGr24ChannelMatrix}(z_1, z_2)$, its homogeneous Plücker 6-vector $p_{\mathrm{slit}} = \operatorname{twistorToPluckerVec}(M_{\mathbb{C}}(z_1, z_2)) \in \mathbb{C}^6$ has components:

   $$
   p_{\mathrm{slit}} = \bigl(p_{01}, p_{02}, p_{03}, p_{12}, p_{13}, p_{23}\bigr) = \bigl(z_1,\,1,\,z_2,\,1,\,z_1 + z_2,\,1\bigr).
   $$

   On $\mathcal{Q}_4$, the holomorphic Klein quadric relation $\mathcal{C}(p_{\mathrm{slit}}) = 2(p_{01}p_{23} - p_{02}p_{13} + p_{03}p_{12}) = 0$ reads $p_{02}p_{13} = p_{01}p_{23} + p_{03}p_{12} \iff p_4 = z_1 + z_2$. Thus, **coherent wave amplitude addition $\Psi_{\mathrm{tot}} = z_1 + z_2$ is literally the geometric condition that keeps the 6-vector $p_{\mathrm{slit}}$ on the Klein quadric $\mathcal{Q}_4 \cong Gr_{\mathbb{C}}(2,4)$**!
2. **Phase-Locked Equilibrium vs. Chiral $\pi/2$ Phase-Slip Non-Equilibrium (`pluckerMadelungSuperpositionOAMDoubleSlit`)**:
   Combining the Klein-quadric crossing intensity with the time-of-flight integrated Plücker continuity source $\tau_{\mathrm{flight}}\,\Gamma_{\mathrm{Pl\ddot{u}cker}}(\hbar, V_{\mathrm{ext,im}}, \lambda_{\mathrm{re}}, \lambda_{\mathrm{im}}, s_{\mathrm{pl}})$ proves:
   - In **Hermitian phase-locked equilibrium** ($S_{\mathrm{dual}} = S_R, \lambda_{\mathrm{im}} = 0, V_{\mathrm{ext,im}} = 0 \implies \Gamma_{\mathrm{Pl\ddot{u}cker}} = 0$), `pluckerMadelungSuperpositionOAMDoubleSlit` on $M_{\mathbb{C}}^{\mathrm{DDF}}(s)$ reproduces `huygensSteinerOAMDoubleSlit` with $\mathcal{V} = \gamma_\varphi(v)^{-1}$ and **$\varepsilon_{\mathrm{rel}} = 0$ everywhere**.
   - Under **chiral $\pi/2$ phase-slip Josephson tunneling** ($S_{\mathrm{dual}} - S_R = \frac{\pi}{2}\hbar$), `pluckerMadelungSuperpositionOAMDoubleSlit` derives the de Broglie–Bohm pilot-wave non-equilibrium density offset $\delta_{\mathrm{neq}} = \tau_{\mathrm{flight}}\,\frac{2}{\hbar}\sqrt{\rho\,\rho_{\mathrm{dual}}}\,\lambda_{\mathrm{re}}$ directly from primary-to-dual ($Gr_{\mathbb{C}}(2,4) \leftrightarrow Gr_{\mathbb{C}}(2,4)^\vee$) Schubert incidence tunneling.

### 5.2 Revised Gravity Models (Models 14a & 14b): Orbital Fubini–Study Kähler Identity, Plücker `iGPE` Potential Inversion, & Dual-Schubert Core Regularization

1. **Orbital Fubini–Study Kähler–Plücker Identity (`PlanetaryOrbit.gr24AffineChart`)**:
   Embedding an eccentric precessing orbit ($e \in [0, 1)$, perihelion phase $\Delta\varpi$) into the canonical $2\times 2$ Fubini–Study affine chart $W_{\mathrm{orb}}(\mathrm{orb}, \Delta\varpi) = \operatorname{diag}\!\bigl(\sqrt{1+e}\,e^{i\Delta\varpi/2},\,\sqrt{1-e}\,e^{-i\Delta\varpi/2}\bigr)$ proves that the Kähler determinant factor equals:

   $$
   \det(I_2 + W_{\mathrm{orb}} W_{\mathrm{orb}}^\dagger) = \bigl\|p(I_2 \mid W_{\mathrm{orb}})\bigr\|_{\mathbb{C}^6}^2 = 1 + (1 + e) + (1 - e) + (1 - e^2) = 4 - e^2 = 3 + \frac{p}{a} > 3,
   $$

   so subtracting the constant 3-minor baseline recovers the exact orbital semi-latus rectum ratio:

   $$
   \det(I_2 + W_{\mathrm{orb}} W_{\mathrm{orb}}^\dagger) - 3 = 1 - e^2 = \frac{p}{a} = \bigl|w_A^{\mathbb{C}}(M_{\mathbb{C}}^{\mathrm{orb}})\bigr|^2\,\bigl|w_B^{\mathbb{C}}(M_{\mathbb{C}}^{\mathrm{orb}})\bigr|^2.
   $$

2. **Models 14a (`turnerPluckerIGPEPrecessionRad`, Without DDF) & 14b (`RiverExterior.turnerDualGr24IGPEDDFPrecessionRad`, With DDF)**:
   - Reconstructs the effective central potential $V_{\mathrm{ext,re}}^{\mathrm{rec}}(p)$ from `pluckerInversePotentialReconstruction` ($\mathcal{R}_{\mathrm{QHJ}}^{\mathrm{Pl\ddot{u}cker}} = 0$) and links the self-dual Weyl curvature projection $W_{\mathrm{Weyl}}(x) + \frac{1}{24}R_{4\mathrm{D}}(x) = \frac{2\mathcal{M}}{\hbar^2}Q_{\mathrm{Pl\ddot{u}cker}}(p, \bar{p})$ to the Plücker Bohmian quantum potential (`reconstructWeylFromPluckerBohm`).
   - At solar-system scales where dual-Schubert core tunneling vanishes ($\delta_{\mathrm{Jos}} = 0$), both Model 14a and Model 14b reproduce $\Delta\varpi_{\mathrm{GR}} = \frac{6\pi G M}{c^2 a(\det(I_2 + W_{\mathrm{orb}}W_{\mathrm{orb}}^\dagger) - 3)}$ ($42.98''/\text{cy}$ for Mercury) with **$\varepsilon_{\mathrm{rel}} = 0$ ($0\%$ error)**.
   - In the strong-field near-horizon core ($\delta_{\mathrm{Jos}} > 0$), $\varepsilon_{\mathrm{rel}} = \delta_{\mathrm{Jos}} / \Delta\varpi_{\mathrm{GR}} > 0$ regularizes the classical $r = 0$ curvature singularity via $Q_{\mathrm{Pl\ddot{u}cker}} + \Lambda_{\mathrm{dual}}(p, \tilde{p})$.

### 5.3 Revised Gravitational-Wave Models (Models 14a & 14b): Plücker $\mathcal{Q}_4$ Quadrupole Trajectory, Proca Gap, & Deborah Shear-Fracture Ringdown

1. **Klein-Quadric Quadrupole Wave Trajectory & Kähler Eccentricity Enhancement**:
   The Plücker 6-vector $p_{\mathrm{GW}}(t) = \operatorname{twistorToPluckerVec}(\mathrm{orb}.\mathrm{gr24QuadrupoleWaveMatrix}(\Phi_{\mathrm{orb}}(t), \Delta\varpi))$ evolves on the Klein quadric $\mathcal{Q}_4 \subset \mathbb{P}^5(\mathbb{C})$ ($\operatorname{OnKleinQuadric}(p_{\mathrm{GW}}(t))$), with Peters–Mathews eccentricity factor $f_{\mathrm{PM}}(e)^2 = P_{\mathrm{PM}}(e)^2 / \bigl(\det(I_2 + W_{\mathrm{orb}}W_{\mathrm{orb}}^\dagger) - 3\bigr)^7$.
2. **Sub-Critical Inspiral ($\mathrm{De}/\mathrm{De}_c < 1$, $\varepsilon_{\mathrm{rel}} = 0$) vs. Super-Critical Merger Ringdown Fracture ($\mathrm{De}/\mathrm{De}_c > 1$, $\delta P_{\mathrm{Jos}} > 0$)**:
   - In the **sub-critical inspiral regime** ($\mathrm{De}/\mathrm{De}_c < 1 \iff \hbar^2\omega^2 > 0$, $\delta P_{\mathrm{Jos}} = 0$), transverse spin-2 modes propagate luminally ($c_{\mathrm{GW}} = (\varrho_{\max}^\varphi j_{\min}^\varphi)^{-1/2} = c$), longitudinal modes are gapped by $R_{\mathrm{Gr}}(2,4) = 16$ and $m_{\gamma,\mathrm{eff}}^2 > 0$, and both **Model 14a (`turnerPluckerIGPEGWLuminosity`)** and **Model 14b (`RiverExterior.turnerDualGr24IGPEDDFGWLuminosity`)** match $P_{\mathrm{GW}}^{\mathrm{GR}}$ with **$\varepsilon_{\mathrm{rel}} = 0$ ($0\%$ error)**.
   - In the **super-critical merger ringdown regime** ($\mathrm{De}/\mathrm{De}_c > 1 \iff \hbar^2\omega^2 < 0$, `IsShearFractureUnstable`), tachyonic shear fracture sheds chiral Josephson–Schubert flux $\delta P_{\mathrm{Jos}} > 0$ into $Gr_{\mathbb{C}}(2,4)^\vee$ ($\varepsilon_{\mathrm{rel}} = \delta P_{\mathrm{Jos}} / P_{\mathrm{GW}}^{\mathrm{GR}} > 0$) while conserving the total primary+dual symplectic norm $\frac{d}{d\tau'}(|\Psi|^2 + |\Phi|^2) = 0$ (avoiding Witten's non-unitary $1/q^4$ Weyl ghost $-\delta P_{\mathrm{ghost}} < 0$).

### 5.4 Summary Comparison Table of Revised Turner (2026) Models

| Domain & Model Entry | Lean 4 & Rust Declarations | Governing Plücker $\mathcal{Q}_4$ / Kähler / Dual-`iGPE` Law | Relative Predictive Error $\varepsilon_{\mathrm{rel}}$ & New Physical Capabilities |
|---|---|---|---|
| **Superposition Model 6**:<br>Homogeneous Plücker $\mathcal{Q}_4$ Madelung & Dual-Grassmannian `iGPE` | `pluckerMadelungSuperpositionOAMDoubleSlit`, `SlitModelKind::PluckerMadelungDualIgpe` | $p_{\mathrm{slit}} = (z_1, 1, z_2, 1, z_1+z_2, 1) \in \mathcal{Q}_4$; $I = I_0 E_{\mathrm{slit}}\|p_1 p_4\|^2 + \tau_{\mathrm{flight}}\Gamma_{\mathrm{Pl\ddot{u}cker}}$ | **Phase-locked ($\Delta\theta = 0, V_{\mathrm{im}} = 0$)**: **$\varepsilon_{\mathrm{rel}} = 0$ everywhere** vs. $I_{\mathrm{HS,OAM}}$;<br>**Chiral $\pi/2$ phase-slip**: derives Bohmian $\delta_{\mathrm{neq}} = \tau_{\mathrm{flight}}\frac{2}{\hbar}\sqrt{\rho\rho_{\mathrm{dual}}}\lambda_{\mathrm{re}}$ |
| **Gravity Model 14a (Without DDF)**:<br>Homogeneous Plücker $\mathcal{Q}_4$ Madelung QHJ, Kähler Chart, & `iGPE` Inversion | `PlanetaryOrbit.gr24AffineChart`, `PlanetaryOrbit.turnerPluckerIGPEPrecessionRad`, `turner_plucker_igpe_precession_rad` | $\Delta\varpi = \frac{6\pi G M}{c^2 a(\det(I_2 + W_{\mathrm{orb}}W_{\mathrm{orb}}^\dagger) - 3)} + \delta_{\mathrm{Jos}}$, with $V_{\mathrm{ext,re}}^{\mathrm{rec}}$ from `pluckerInversePotentialReconstruction` & Weyl $W_{\mathrm{Weyl}} \propto Q_{\mathrm{Pl\ddot{u}cker}}$ | **Solar-system ($\delta_{\mathrm{Jos}} = 0$)**: **$\varepsilon_{\mathrm{rel}} = 0$ ($0\%$, $42.98''/\text{cy}$ Mercury)**;<br>**Near-horizon core ($\delta_{\mathrm{Jos}} > 0$)**: $\varepsilon_{\mathrm{rel}} = \delta_{\mathrm{Jos}}/\Delta\varpi_{\mathrm{GR}} > 0$ (regularizes $r=0$) |
| **Gravity Model 14b (With DDF)**:<br>Unified Dual-Grassmannian $Gr_{\mathbb{C}}(2,4)\times Gr_{\mathbb{C}}(2,4)^\vee$ `iGPE` + Plücker $\mathcal{Q}_4$ + DDF | `RiverExterior.turnerDualGr24IGPEDDFPrecessionRad`, `reconstructWeylFromPluckerBohm` | $\Delta\varpi = \frac{6\pi G_\phi M \varrho_{\max}^\varphi j_{\min}^\varphi}{a(\det(I_2 + W_{\mathrm{orb}}W_{\mathrm{orb}}^\dagger) - 3)} + \delta_{\mathrm{Jos}}$ ($c^{-2} = \varrho_{\max}^\varphi j_{\min}^\varphi$, $R_{\mathrm{Gr}}(2,4) = 16$) | **Solar-system ($\delta_{\mathrm{Jos}} = 0$)**: **$\varepsilon_{\mathrm{rel}} = 0$ ($0\%$, $42.98''/\text{cy}$)**;<br>$\eta_{\mathrm{act}}^\gamma = 0$ photon–photon discriminator + chiral dual-Schubert core |
| **GW Model 14a (Without DDF)**:<br>Homogeneous Plücker $\mathcal{Q}_4$ Quadrupole Wave & Kähler `iGPE` 2.5PN Flux | `PlanetaryOrbit.turnerPluckerIGPEGWLuminosity`, `turner_plucker_igpe_gw_luminosity` | $P_{\mathrm{GW}} = \frac{32}{5}\frac{G^4 m_1^2 m_2^2(m_1+m_2)}{c^5 a^5}\frac{P_{\mathrm{PM}}(e)}{(\sqrt{\det(I_2+W_{\mathrm{orb}}W_{\mathrm{orb}}^\dagger)-3})^7} + \delta P_{\mathrm{Jos}}$, $p_{\mathrm{GW}}(t) \in \mathcal{Q}_4$ | **Inspiral ($\mathrm{De}/\mathrm{De}_c < 1, \delta P_{\mathrm{Jos}} = 0$)**: **$\varepsilon_{\mathrm{rel}} = 0$ ($0\%$)**;<br>**Ringdown fracture ($\delta P_{\mathrm{Jos}} > 0$)**: $\varepsilon_{\mathrm{rel}} = \delta P_{\mathrm{Jos}}/P_{\mathrm{GW}}^{\mathrm{GR}} > 0$ |
| **GW Model 14b (With DDF)**:<br>Unified Dual-Grassmannian `iGPE` + Plücker $\mathcal{Q}_4$ + DDF + Deborah Fracture | `RiverExterior.turnerDualGr24IGPEDDFGWLuminosity`, `grassmannianDeborahFractureRatio` | $P_{\mathrm{GW}} = P_{\mathrm{GW}}^{\mathrm{DDF}} + \delta P_{\mathrm{Jos}}$, with $\hbar^2\omega^2 < 0 \iff \mathrm{De}/\mathrm{De}_c > 1$ and $\frac{d}{d\tau'}(\|\Psi\|^2+\|\Phi\|^2) = 0$ | **Inspiral ($\mathrm{De}/\mathrm{De}_c < 1, \delta P_{\mathrm{Jos}} = 0$)**: **$\varepsilon_{\mathrm{rel}} = 0$ ($0\%$)**;<br>unitary primary+dual norm conservation during $\mathrm{De} > \mathrm{De}_c$ ringdown fracture |

---

## 6. Multi-Regime Quantitative Benchmarks & Machine-Checked Verification

### 6.1 Four Kinematic Regimes on $Gr_{\mathbb{C}}(2,4) \cong \mathcal{Q}_4$ (`madelung_lagrangian.rs`)

| # | Kinematic Regime on $Gr_{\mathbb{C}}(2,4)$ | Chart & Coupling Parameters $(\|W\|, \arg W, \|p_{34}/p_{12}\|, g, \rho_0, V_{\mathrm{im}}, w, \|\lambda\|)$ | Kähler Determinant $\det(I_2 + W W^\dagger) = \|p\|^2$ | Bogoliubov $\hbar^2\omega^2$ & Deborah Ratio $\mathrm{De}/\mathrm{De}_c$ | Symplectic Norm Rate $\frac{d}{d\tau'}(\|\Psi\|^2 + \|\Phi\|^2)$ |
|---|---|---|---|---|---|
| **1** | **$Gr^+(2,4)$ Causal Acoustic Core** | $(0.50, 0.00, 0.20, +2.00, 1.50, 0.00, 1.00, 0.35)$ | $1.5425 \ge 1$ | $\hbar^2\omega^2 > 0$, $\mathrm{De}/\mathrm{De}_c = 0 < 1$ (**Stable**) | $0$ (**Unitary Conservation**) |
| **2** | **Evanescent Optical Sheet** | $(1.15, 1.35, 0.45, +1.60, 1.80, +1.10, 1.15, 0.40)$ | $6.0680 \ge 1$ | $\hbar^2\omega^2 > 0$, $\operatorname{Im}(\omega) \neq 0$ (**Evanescent**) | $+2 V_{\mathrm{im}}(\|\Psi\|^2 + \|\Phi\|^2) > 0$ (**Gain**) |
| **3** | **Tachyonic Shear Fracture ($\mathrm{De} > \mathrm{De}_c$)** | $(0.45, 0.00, 0.15, -3.40, 2.20, 0.00, 0.85, 0.00)$ | $1.4406 \ge 1$ | $\hbar^2\omega^2 < 0$, $\mathrm{De}/\mathrm{De}_c > 1$ (**Shear Fracture!**) | $0$ (Conservative Tachyonic Mode) |
| **4** | **Strong Dual `iGPE` Schubert Lock** | $(0.85, -0.95, 0.60, +1.80, 1.60, 0.00, 1.25, 2.60)$ | $3.6201 \ge 1$ | $\hbar^2\omega^2 > 0$, $m_{\gamma,\mathrm{eff}}^2 > 0$ (**Gapped Proca Mode**) | $0$ ($J_{\mathrm{Josephson}}$ cancels between $\Psi, \Phi$) |

### 6.2 Self-Contained Lean 4 Verification Block

```lean
import Signals
import SignalsPending

namespace ComplexGrassmannianGPEPluckerMadelungPaperVerification

open Signals
open Signals.Geometry
open Signals.Huygens
open Signals.DDF
open Signals.Pending

example {sub : DDFSubstrate} (s : MovingSheath sub) (re : RiverExterior sub)
    (orb : PlanetaryOrbit) (W K : Matrix (Fin 2) (Fin 2) ℂ) (Z : Matrix (Fin 2) (Fin 4) ℂ)
    (i : PluckerIdx) (s_coupled : CoupledDualGrassmannianState)
    (z1 z2 : ℂ) (Δℓ : ℤ) (φ x y orbitalPhase deltaVarpi deltaJos deltaPJos : ℝ)
    (dtau_s_real lambda_re lambda_im R_4D : ℝ)
    (hJos : 0 < deltaJos) (hPJos : 0 < deltaPJos) :
    let p_Z := twistorToPluckerVec Z
    let Z_W := chartToTwistor W
    let gpe_rep : GrassmannianGPEParams :=
      { hbar := 1, mass := 1, g_coupling := 2, g_dual := 1, lambda_int := 0, modular_weight := 1 }
    let p_state : PluckerMadelungState :=
      { p := p_Z
        on_quadric := (plucker_hodge_klein_quadric_and_projector_identities p_Z 0 Z).2.2.2.1
        rho := 4
        rho_dual := 9
        s_real := 2
        s_imag := 0
        s_dual := 2
        kinetic_vel_sq := 3
        projected_hessian_sqrt_rho := 6 }
    let v_rec :=
      pluckerInversePotentialReconstruction dtau_s_real 1 1 2 1 lambda_re lambda_im p_state
    let p_slit := twistorToPluckerVec (complexGr24ChannelMatrix z1 z2)
    let M_DDF := s.gr24TwistorMatrix 6 1 5 Δℓ φ x
    let W_orb := PlanetaryOrbit.gr24AffineChart orb deltaVarpi
    let Δϖ_GR := re.perihelionPrecessionRad orb
    let P_GR := re.petersMathewsLuminosity orb 2
    pluckerHodgeDual (pluckerHodgeDual p_Z) i = p_Z i ∧
      pluckerNormSq (pluckerHodgeDual p_Z) = pluckerNormSq p_Z ∧
      OnKleinQuadric p_Z ∧
      pluckerContravariantMetricApply p_Z p_Z i = 0 ∧
      pluckerContravariantMetricApply p_Z (pluckerConjHodgeNormal p_Z) i = 0 ∧
      kahlerDetFactor W = pluckerNormSq (twistorToPluckerVec Z_W) ∧
      1 ≤ kahlerDetFactor W ∧
      fubiniStudyKineticNorm 0 K = fubiniStudyFrobeniusNormSq K ∧
      s_coupled.totalNormTimeDerivative =
        2 * s_coupled.v_im * (Complex.normSq s_coupled.psi + Complex.normSq s_coupled.phi) ∧
      (s_coupled.v_im = 0 → s_coupled.totalNormTimeDerivative = 0) ∧
      grassmannianEinsteinKahlerScalarCurvature 2 4 = 16 ∧
      0 < grassmannianBogoliubovOmegaSq gpe_rep 0 K 3 ∧
      0 < grassmannianProcaMassSq 1 1 1 6 (1 / 2) 4 9 ∧
      pluckerHamiltonJacobiResidual dtau_s_real 1 1 2 1 v_rec lambda_re lambda_im p_state = 0 ∧
      pluckerContinuitySourceRHS 1 0 lambda_re 0 p_state = 0 ∧
      reconstructWeylFromPluckerBohm 1 1 R_4D p_state + (1 / 24 : ℝ) * R_4D =
        - p_state.projected_hessian_sqrt_rho / Real.sqrt p_state.rho ∧
      OnKleinQuadric p_slit ∧
      p_slit 4 = z1 + z2 ∧
      relativePredictiveError
        (pluckerMadelungSuperpositionOAMDoubleSlit M_DDF 3 2 4 1 5 1 1 0 lambda_re 0 p_state x y)
        (huygensSteinerOAMDoubleSlit 3 2 4 6 1 5 (s.jammingFactor)⁻¹ Δℓ φ x y) = 0 ∧
      kahlerDetFactor W_orb - 3 = orb.semiLatusRectum / orb.semiMajorAxis ∧
      relativePredictiveError
        (PlanetaryOrbit.turnerPluckerIGPEPrecessionRad orb re.G_phi re.sourceMass sub.c deltaVarpi 0)
        Δϖ_GR = 0 ∧
      relativePredictiveError (re.turnerDualGr24IGPEDDFPrecessionRad orb deltaVarpi 0) Δϖ_GR = 0 ∧
      relativePredictiveError
        (re.turnerDualGr24IGPEDDFPrecessionRad orb deltaVarpi deltaJos) Δϖ_GR =
        deltaJos / Δϖ_GR ∧
      relativePredictiveError
        (PlanetaryOrbit.turnerPluckerIGPEGWLuminosity
          orb re.G_phi re.sourceMass 2 sub.c orbitalPhase deltaVarpi 0)
        P_GR = 0 ∧
      relativePredictiveError (re.turnerDualGr24IGPEDDFGWLuminosity orb 2 0) P_GR = 0 ∧
      relativePredictiveError (re.turnerDualGr24IGPEDDFGWLuminosity orb 2 deltaPJos) P_GR =
        deltaPJos / P_GR := by
  intro p_Z Z_W gpe_rep p_state v_rec p_slit M_DDF W_orb Δϖ_GR P_GR
  have h_pl := plucker_hodge_klein_quadric_and_projector_identities p_Z i Z
  have h_quad_props := h_pl.2.2.2.2 h_pl.2.2.2.1
  have h_kahler := kahlerDetFactor_eq_pluckerNormSq_and_ge_one W K
  have h_norm := grassmannian_igpe_norm_balance_and_josephson_identities s_coupled
  have h_bog := grassmannian_bogoliubov_proca_and_deborah_fracture_identities
    gpe_rep 0 K 3 9 1 (1 / 2)
    (by norm_num [gpe_rep]) (by norm_num [gpe_rep])
    h_kahler.2.2.2.2.2.2
    (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  have h_proca : 0 < grassmannianProcaMassSq 1 1 1 6 (1 / 2) 4 9 := by
    unfold grassmannianProcaMassSq
    positivity
  have h_qhj := plucker_madelung_qhj_inverse_igpe_and_weyl_bridge_identities
    dtau_s_real 1 1 2 1 lambda_re lambda_im R_4D p_state (by norm_num) (by norm_num)
  have h_rev := turner_2026_revised_superposition_gravity_and_gw_plucker_igpe_models
    s re orb p_state z1 z2 3 2 4 6 1 5 1 1 lambda_re
    Δℓ φ x y orbitalPhase deltaVarpi 2 deltaJos deltaPJos
    (by norm_num) hJos hPJos
  exact ⟨h_pl.1, h_pl.2.1, h_pl.2.2.2.1, h_quad_props.2.2.1, h_quad_props.2.2.2,
    h_kahler.2.2.1, h_kahler.2.2.2.1, h_kahler.2.2.2.2.2.1,
    h_norm.2.2.1, h_norm.2.2.2,
    h_bog.1, h_bog.2.1 (by norm_num [gpe_rep]), h_proca,
    h_qhj.1, (h_qhj.2.1 rfl).1, h_qhj.2.2.2,
    h_rev.1, h_rev.2.2.2.1, (h_rev.2.2.2.2.1 rfl).2, h_rev.2.2.2.2.2.2.2.1,
    h_rev.2.2.2.2.2.2.2.2.2.1, h_rev.2.2.2.2.2.2.2.2.2.2.2.2.1,
    h_rev.2.2.2.2.2.2.2.2.2.2.2.2.2.1, h_rev.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.1,
    h_rev.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.1,
    h_rev.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2⟩

end ComplexGrassmannianGPEPluckerMadelungPaperVerification
```

---

## 7. Conclusion & Reproducibility

By formalizing the homogeneous Plücker 6-vector calculus on the Klein quadric $\mathcal{Q}_4 \subset \mathbb{P}^5(\mathbb{C})$, the corrected Hermitian tangent projector $\mathcal{H}^{I\bar{J}}$, the Cauchy–Binet Kähler determinant identity $\det(I_2 + W W^\dagger) = \|p(I_2 \mid W)\|^2 \ge 1$, the coupled Dual-Grassmannian `iGPE` symplectic norm balance and chiral Josephson Schubert current, the Einstein–Kähler Bogoliubov dispersion ($R_{\mathrm{Gr}}(2,4) = 16$) and critical Deborah shear-fracture threshold ($\hbar^2\omega^2 < 0 \iff \mathrm{De}/\mathrm{De}_c > 1$), and the homogeneous Plücker Madelung QHJ / `iGPE` potential reconstruction and Penrose Bohm–Weyl curvature dictionary in Lean 4 and Rust/WASM, we have unified spacetime Madelung hydrodynamics with intrinsic complex Grassmannian twistor geometry while maintaining strict Pending evidence boundaries (`ComplexGrassmannianGPEAndPluckerMadelungHypothesis`).

```bash
make signals_build
cargo test --manifest-path src/signals/numerical_adapter/Cargo.toml madelung_lagrangian
cargo build --manifest-path src/signals/numerical_adapter/Cargo.toml --lib --target wasm32-unknown-unknown --release
```

---

### Scholarly References

<a id="cgpe-madelung1927"></a>
1. Madelung, E. (1927). *Quantentheorie in hydrodynamischer Form*. Zeitschrift für Physik 40(3–4), 322–326. [DOI: 10.1007/BF01400372](https://doi.org/10.1007/BF01400372).

<a id="cgpe-gross1961"></a>
2. Gross, E. P. (1961). *Structure of a quantized vortex in boson systems*. Il Nuovo Cimento 20(3), 454–477. [DOI: 10.1007/BF02731494](https://doi.org/10.1007/BF02731494).

<a id="cgpe-pitaevskii1961"></a>
3. Pitaevskii, L. P. (1961). *Vortex lines in an imperfect Bose gas*. Soviet Physics JETP 13(2), 451–454.

<a id="cgpe-penrose1967"></a>
4. Penrose, R. (1967). *Twistor Algebra*. Journal of Mathematical Physics 8(2), 345–366. [DOI: 10.1063/1.1705200](https://doi.org/10.1063/1.1705200).

<a id="cgpe-penrose1976"></a>
5. Penrose, R. (1976). *Nonlinear Gravitons and Curved Twistor Theory*. General Relativity and Gravitation 7(1), 31–52. [DOI: 10.1007/BF00762011](https://doi.org/10.1007/BF00762011).

<a id="cgpe-arkani2014"></a>
6. Arkani-Hamed, N., and Trnka, J. (2014). *The Amplituhedron*. Journal of High Energy Physics 2014(10), 030. [DOI: 10.1007/JHEP10(2014)030](https://doi.org/10.1007/JHEP10%282014%29030); [arXiv:1312.2007](https://arxiv.org/abs/1312.2007).

<a id="cgpe-fedi2026"></a>
7. Fedi, M. (2026). *Dilatant Dark Fluid: Toward a Unified Quantum-Hydrodynamic Origin of Lorentz Invariance, Gravity, and Cosmological Phenomenology*. SSRN Preprint 7406660. [DOI: 10.2139/ssrn.7406660](https://doi.org/10.2139/ssrn.7406660).

<a id="cgpe-chat-gpe2026"></a>
8. Provenance Chat Log (2026). *Grassmannian Gross–Pitaevskii Equation Formulation*. ({download}`data/chats/Gemini_Grassmannian-Gross-Pitaevskii-Equation-Formulation_20261103-1045.md, lines 1-1458 <../data/chats/Gemini_Grassmannian-Gross-Pitaevskii-Equation-Formulation_20261103-1045.md>`).

---

### BibTeX Citations

```bibtex
@article{madelung1927quantentheorie,
  author  = {Madelung, Erwin},
  title   = {Quantentheorie in hydrodynamischer Form},
  journal = {Zeitschrift f{\"u}r Physik},
  volume  = {40},
  number  = {3-4},
  pages   = {322--326},
  year    = {1927},
  doi     = {10.1007/BF01400372}
}

@article{penrose1967twistor,
  author  = {Penrose, Roger},
  title   = {Twistor Algebra},
  journal = {Journal of Mathematical Physics},
  volume  = {8},
  number  = {2},
  pages   = {345--366},
  year    = {1967},
  doi     = {10.1063/1.1705200}
}

@article{penrose1976nonlinear,
  author  = {Penrose, Roger},
  title   = {Nonlinear Gravitons and Curved Twistor Theory},
  journal = {General Relativity and Gravitation},
  volume  = {7},
  number  = {1},
  pages   = {31--52},
  year    = {1976},
  doi     = {10.1007/BF00762011}
}

@misc{chat_grassmannian_gpe_2026,
  author       = {Turner, Wes and {Gemini}},
  title        = {Grassmannian {Gross--Pitaevskii} Equation Formulation},
  year         = {2026},
  howpublished = {AI research chat log},
  note         = {Source: data/chats/Gemini_Grassmannian-Gross-Pitaevskii-Equation-Formulation_20261103-1045.md, lines 1--1458}
}
```

### Schema.org Metadata (JSON-LD)

```json
{
  "@context": "https://schema.org",
  "@type": "ScholarlyArticle",
  "headline": "Complex Grassmannian Gr_C(2,4) Fubini–Study Gross–Pitaevskii Equation, Dual-Schubert iGPE, and Homogeneous Plücker Madelung Hydrodynamics on the Klein Quadric Q_4 in Lean 4 and Rust/WASM",
  "author": {
    "@type": "Person",
    "name": "Wes Turner"
  },
  "dateModified": "2026-11-03",
  "about": [
    "Complex Grassmannian Gr_C(2,4)",
    "Gross-Pitaevskii Equation",
    "Interactive and Inverse Gross-Pitaevskii Equation (iGPE)",
    "Plücker Coordinates and Klein Quadric",
    "Madelung Quantum Hydrodynamics",
    "Fubini-Study Metric and Bogoliubov Dispersion",
    "Deborah Number Vacuum Shear Fracture",
    "Penrose Transform and Weyl Curvature",
    "Lean 4 Formal Verification"
  ],
  "isBasedOn": [
    "data/chats/Gemini_Grassmannian-Gross-Pitaevskii-Equation-Formulation_20261103-1045.md",
    "src/signals/Signals/DDF.lean",
    "src/signals/Signals/Pending.lean",
    "src/signals/numerical_adapter/src/madelung_lagrangian.rs"
  ]
}
```
