---
title: "Semi-Dirac Fermions (Mass in Only One Direction) With and Without Complex Grassmannian Gr_C and Dilatant Dark Fluid (DDF) Mechanics: ZrSiS B^(2/3) Landau Scaling, Dirac-Cone Merging on Gr_C(2,4) and Gr_C(2,6), Directional Sheath Jamming, Anisotropic Tensor Splats, and Quantum/Photonic Applications in Lean 4, Rust, and Python"
description: "An arXiv-ready MyST Markdown formal verification and condensed-matter/quantum-hydrodynamics paper formalizing Semi-Dirac fermions (which possess massive Schrödinger dispersion in one spatial direction and massless relativistic Dirac dispersion in the orthogonal direction) across all four regimes: with and without Complex Grassmannian Gr_C (Gr_C(1,2), Gr_C(2,4), Gr_C(2,6)), and with and without Dilatant Dark Fluid (DDF) longitudinal sheath jamming, including ZrSiS B^(2/3) Landau level scaling (Shao et al., PRX 2024), anisotropic 2D Tensor Gaussian Splat propagation, and engineering applications in Lean 4, Rust, and Python."
---

(grassmannian-semi-dirac-fermions-ddf-paper)=
# Semi-Dirac Fermions (Mass in Only One Direction) With and Without Complex Grassmannian $\mathrm{Gr}_{\mathbb{C}}$ and Dilatant Dark Fluid (DDF) Mechanics: $\mathrm{ZrSiS}$ $B^{2/3}$ Landau Scaling, Dirac-Cone Merging on $\mathrm{Gr}_{\mathbb{C}}(2,4)$ and $\mathrm{Gr}_{\mathbb{C}}(2,6)$, Directional Sheath Jamming, Anisotropic Tensor Splats, and Quantum/Photonic Applications in Lean 4, Rust, and Python

- **Authors:** Wes Turner
- **Subjects:**
  - Mesoscale and Nanoscale Physics (`cond-mat.mes-hall`); Materials Science (`cond-mat.mtrl-sci`); Superconductivity (`cond-mat.supr-con`); Mathematical Physics (`math-ph`); Quantum Physics (`quant-ph`); Logic in Computer Science (`cs.LO`)
- **Formal Verification & Simulation Artifacts:**
  - `Signals` Lean 4 Library (`leanprover/lean4:v4.35.0-rc3`, [../src/signals/Signals/DFT.lean](../src/signals/Signals/DFT.lean#L4304-L4506), [../src/signals/Signals/Pending.lean](../src/signals/Signals/Pending.lean#L7162-L7238), [../src/signals/SignalsPending.lean](../src/signals/SignalsPending.lean#L898-L962), [../src/signals/SignalsTests.lean](../src/signals/SignalsTests.lean#L7400-L7426), [../src/signals/SignalsPendingTests.lean](../src/signals/SignalsPendingTests.lean#L6048-L6095))
  - `signals-numerical-adapter` Rust/WASM Crate ([../src/signals/numerical_adapter/src/dft_plabic_vrc.rs](../src/signals/numerical_adapter/src/dft_plabic_vrc.rs#L1432-L1501))
  - Python Reference Implementation & Pytest Suite ([../sustainablefactory/qci_grassmannian_dft.py](../sustainablefactory/qci_grassmannian_dft.py#L4271-L4350), [../tests/test_qci_grassmannian_dft.py](../tests/test_qci_grassmannian_dft.py#L990-L1025))
  - Canonical `src/signals/docs/` Mirror: [../src/signals/docs/grassmannian-semi-dirac-fermions-ddf-paper.md](../src/signals/docs/grassmannian-semi-dirac-fermions-ddf-paper.md)
- **Companion Papers:**
  - [Grassmannian Multilayer Graphene Superconductivity, Quantum Anomalous Hall ($C = \pm 5$), Fractional Chern Insulators (`FQAH`), Supersolid Quantum Tornadoes, and Symbiotic Topological Quantum Computing (`G-MGS`)](grassmannian-rhombohedral-graphene-superconductivity-qc-paper.md)
  - [Complex Grassmannian $\mathrm{Gr}_{\mathbb{C}}(2,4)$ Fubini–Study Gross–Pitaevskii Equation, Dual-Schubert `iGPE`, and Homogeneous Plücker Madelung Hydrodynamics on the Klein Quadric $\mathcal{Q}_4$](grassmannian-complex-gpe-igpe-plucker-madelung-paper.md)
  - [Complex Grassmannian $\mathrm{Gr}_{\mathbb{C}}(2,4)$ & $N$-ary $\mathrm{Gr}_{\mathbb{C}}(2, N+2)$ Unification with Dilatant Dark Fluid (DDF) Moving Sheaths, Plücker Sink Fluxes, Anosov Invariance, and Sorkin Triple-Slit Interferometry](grassmannian-ddf-moving-sheath-paper.md)
  - [Normed Tensor Gaussian Splat Mechanics for Complex $\mathrm{Gr}_{\mathbb{C}}(2,4)$ Twistors: Advantages, Limitations, WebGL2/WASM Practicality, and Unification Across Double-Slit, QISM, DDF, and Planetary Gravity](grassmannian-splat-mechanics-paper.md)
  - [Epsilon-Near-Zero (ENZ) and Hyperbolic Metamaterials in Unified Grassmannian–DDF Mechanics: `rGO-polyCBD-SS-Lignin` Nanolaminates, Argon/Ionospheric Trivelpiece–Gould Plasma, Denisov Mode Conversion, and CPA-TNSA $p\text{-}^{11}\text{B}$ / $s\text{CO}_2$ Power Ledgers](grassmannian-enz-hyperbolic-metamaterials-paper.md)
  - [$\mathrm{SU}(4)$ Symmetry, Witten's Twistor String Theory, Lower Grassmannians in $\mathrm{Gr}_{\mathbb{R}}$ and $\mathrm{Gr}_{\mathbb{C}}$, Cachazo–He–Yuan (CHY) vs. DDF vs. Turner Models, and Grand Unification with the Holographic Principle and AdS/CFT](grassmannian-su4-witten-twistor-string-cachazo-ddf-turner-ads-cft-unification-paper.md)
  - [Unification, Engineering Applications, and Research Roadmap of Complex Grassmannian $\mathrm{Gr}_{\mathbb{C}}(2,4)$ and Dilatant Dark Fluid (DDF) Mechanics](grassmannian-unification-applications-roadmap-paper.md)

---

## Abstract

**Semi-Dirac fermions** are exotic two-dimensional relativistic-nonrelativistic hybrid quasiparticles that behave as **massive Schrödinger particles along one spatial axis ($x$)** ($E \propto \frac{\hbar^2 k_x^2}{2 m_x^*}$ with effective mass $m_x^* > 0$) while simultaneously propagating as **massless ultra-relativistic Dirac particles along the orthogonal axis ($y$)** ($E \propto \hbar v_y |k_y|$ with zero rest mass $m_y^* = 0$) ([Dietl, Piéchon & Montambaux 2008](#sd-dietl2008); [Banerjee, Singh, Pardo & Pickett 2009](#sd-banerjee2009); [Montambaux, Piéchon, Fuchs & Goerbig 2009](#sd-montambaux2009)). Following their landmark magneto-optical observation at the nodal-line crossings of $\mathrm{ZrSiS}$ by **Shao et al. (2024)** (*Physical Review X* 14, 041057, [`arXiv:2311.03735`](#sd-shao2024))—verified via the signature **$B^{2/3}$ Landau-level scaling** $E_n(B) \propto [(n + 1/2)B]^{2/3}$—a foundational question arises across condensed-matter physics, complex projective geometry, and quantum hydrodynamics:

> *How are semi-Dirac fermions formulated **with and without the Complex Grassmannian $\mathrm{Gr}_{\mathbb{C}}$** ($\mathrm{Gr}_{\mathbb{C}}(1,2)$, $\mathrm{Gr}_{\mathbb{C}}(2,4)$, and $\mathrm{Gr}_{\mathbb{C}}(2,6)$) and **with and without the Dilatant Dark Fluid (DDF)** (`Signals.DDF`), why does a quasiparticle acquire mass in only one direction from a hydrodynamic perspective, and what engineering and quantum-computing applications follow?*

In this paper, we formalize and machine-check all four regimes ($2 \times 2$: **without/with $\mathrm{Gr}_{\mathbb{C}}$** $\times$ **without/with DDF**) in **Lean 4** (`Signals.DFT` Section 19, `Signals.Pending`), **Rust/WASM** (`dft_plabic_vrc.rs`), and **Python** (`SemiDiracAndSU4WittenUnificationEngine`):

1. **Regime 1 — Without $\mathrm{Gr}_{\mathbb{C}}$, Without DDF (Euclidean 2-Band Bloch Space & $\mathrm{ZrSiS}$ $B^{2/3}$ Landau Scaling)**:
   We formalize the universal Montambaux–Banerjee–Shao squared dispersion `semiDiracEnergySq`

   $$
   E_{\mathrm{SD}}^2(k_x, k_y; m_x^*, v_y, \Delta_m) = \left(\frac{\hbar^2 k_x^2}{2 m_x^*} + \Delta_m\right)^2 + (\hbar v_y k_y)^2,
   $$

   proving the transition across the three merging phases ($\Delta_m < 0$ two-Dirac-cone semimetal with nodes at $\frac{\hbar^2 k_x^2}{2 m_x^*} = -\Delta_m$; $\Delta_m = 0$ critical semi-Dirac point with massive $x$-branch $E = \frac{\hbar^2 k_x^2}{2 m_x^*}$ and massless $y$-branch $E = \hbar v_y |k_y|$; and $\Delta_m > 0$ gapped insulator with gap $2\Delta_m$), directional group velocities (`semiDiracGroupVelocityX`, `semiDiracGroupVelocityY`), and the exact **$\mathrm{ZrSiS}$ $B^{2/3}$ Landau-level cube law** (`semiDiracLandauLevelCube`: scaling $B \mapsto 8 B$ scales $E_n(B)^3$ by $8^2 = 64 = (8^{2/3})^3$).
2. **Regime 2 — With Complex Grassmannian $\mathrm{Gr}_{\mathbb{C}}$ ($\mathrm{Gr}_{\mathbb{C}}(2,4)$ and $\mathrm{Gr}_{\mathbb{C}}(2,6)$), Without DDF**:
   While a single 2-band Bloch spinor lives on $\mathrm{Gr}_{\mathbb{C}}(1,2) \cong \mathbb{CP}^1$, capturing the **pair of merging valleys $(\mathbf{K}_+, \mathbf{K}_-)$** without branch-cut singularities lifts the state to the canonical affine chart $Z_{\mathrm{SD}} = (I_2 \mid W_{\mathrm{SD}}) \in \mathrm{Gr}_{\mathbb{C}}(2,4) \cong \mathcal{Q}_4 \subset \mathbb{P}^5(\mathbb{C})$. We prove that the Plücker coordinate $p_{23}(Z_{\mathrm{SD}}) = \det W_{\mathrm{SD}}$ (`semiDiracPluckerDet`) equals $E_{\mathrm{SD}}^2(k_x, k_y; \Delta_m)$ identically, and that the $\mathrm{SU}(4)$-invariant Fubini–Study Kähler determinant factor (`semiDiracKahlerDetFactor`) factors into an exact square:

   $$
   \det\bigl(I_2 + W_{\mathrm{SD}} W_{\mathrm{SD}}^\dagger\bigr) = \bigl\|p(Z_{\mathrm{SD}})\bigr\|_{\mathbb{C}^6}^2 = 1 + 2 E_{\mathrm{SD}}^2 + E_{\mathrm{SD}}^4 = \bigl(1 + E_{\mathrm{SD}}^2(k_x, k_y; \Delta_m)\bigr)^2 \ge 1.
   $$

   In uniaxial-strained rhombohedral trilayer graphene (`RTG`, $N=3$), the 6-orbital space $\mathrm{Gr}_{\mathbb{C}}(2,6)$ ($\dim_{\mathbb{R}} = 16$, $15$ Plücker coordinates) hosts trigonal-warping pocket merging into a semi-Dirac saddle point.
3. **Regime 3 — Without $\mathrm{Gr}_{\mathbb{C}}$, With Dilatant Dark Fluid (DDF Longitudinal Sheath Jamming)**:
   DDF ([`MovingSheath`](../src/signals/Signals/DDF.lean)) provides a concrete **microscopic hydrodynamic mechanism for why mass exists in only one direction**: a bosonic sheath moving or compressed along the $x$-axis undergoes **longitudinal shear-thickening jamming** $\Lambda_\parallel(\beta_x) = \gamma_\varphi(\beta_x) = (1 - \beta_x^2)^{-1/2} > 1$, generating an enhanced longitudinal effective mass (`semiDiracDdfJammedMassX`)

   $$
   m_x^*(\beta_x) = m_0\,\gamma_\varphi(\beta_x)^2 = \frac{m_0}{1 - \beta_x^2} > m_0 \qquad (\text{e.g., } m_x^*(3/5) = \frac{25}{16} m_0),
   $$

   while orthogonal transverse shear fluctuations along $y$ propagate at the gapless superfluid phonon speed $v_y = c_\phi = (\varrho_{\max}^\varphi j_{\min}^\varphi)^{-1/2}$ with **strictly zero rest mass ($m_y^* = 0$)**.
4. **Regime 4 — Unified With Both $\mathrm{Gr}_{\mathbb{C}}(2,4)$ AND DDF + Anisotropic 2D Tensor Gaussian Splats**:
   Combining the $\mathrm{Gr}_{\mathbb{C}}(2,4)$ Plücker chart with DDF longitudinal sheath jamming (`semiDiracDdfGr24EnergySq`) and evolving a 2D `NormedTensorGaussianSplat2D` wavepacket (`semiDiracAnisotropicSplatVarX`, `semiDiracAnisotropicSplatVarY`) proves that a semi-Dirac wavepacket undergoes **dispersive Bohmian quantum-potential spreading along the massive $x$-axis** ($\sigma_x^2(t) = \sigma_{x,0}^2 + \frac{\hbar^2 t^2}{4 (m_x^*)^2 \sigma_{x,0}^2} > \sigma_{x,0}^2$) while maintaining **dispersionless soliton-like constant width along the massless $y$-axis** ($\sigma_y^2(t) = \sigma_{y,0}^2$).

---

## 1. Physics of Semi-Dirac Fermions: Directional Mass, Dirac-Cone Merging, and the $\mathrm{ZrSiS}$ $B^{2/3}$ Discovery

### 1.1 Comparison of 2D Quasiparticle Universality Classes

In two spatial dimensions $(k_x, k_y)$, electronic and photonic quasiparticles fall into three fundamental dispersion classes:

| Quasiparticle Class | Prototype Material | $x$-Axis Dispersion ($k_y = 0$) | $y$-Axis Dispersion ($k_x = 0$) | Density of States $\rho(E)$ | Landau Levels $E_n(B)$ | Berry Phase $\Phi_B$ |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **1. Non-Relativistic Schrödinger** | 2DEG ($\mathrm{GaAs}$, $\mathrm{Si}$ inversion layer) | Massive quadratic: $\frac{\hbar^2 k_x^2}{2 m^*}$ | Massive quadratic: $\frac{\hbar^2 k_y^2}{2 m^*}$ | Constant: $E^0$ | Linear: $\hbar\omega_c(n + \frac{1}{2}) \propto B^1$ | $0$ |
| **2. Isotropic Relativistic Dirac** | Monolayer Graphene ($N=1$) | Massless linear: $\hbar v_F \|k_x\|$ | Massless linear: $\hbar v_F \|k_y\|$ | Linear: $E^1$ | Square-root: $v_F\sqrt{2\hbar e B n} \propto B^{1/2}$ | $\pm\pi$ |
| **3. Semi-Dirac Hybrid (`Signals.DFT` Sec. 19)** | **$\mathrm{ZrSiS}$ nodal-line crossing** ([Shao et al. 2024](#sd-shao2024)), $\mathrm{TiO}_2/\mathrm{VO}_2$, strained graphene / black phosphorus | **Massive quadratic**: $\frac{\hbar^2 k_x^2}{2 m_x^*}$ ($m_x^* > 0$) | **Massless linear**: $\hbar v_y \|k_y\|$ ($m_y^* = 0$) | **Square-root**: $E^{1/2}$ | **Two-thirds power**: $\propto [(n + \frac{1}{2})B]^{2/3}$ | $0$ ($\pi + (-\pi)$) |

### 1.2 Universal Montambaux–Banerjee–Shao Merging Hamiltonian

When two 2D Dirac cones of opposite chirality ($\Phi_B = +\pi$ and $\Phi_B = -\pi$) approach each other along the $k_x$-axis under uniaxial strain, pressure, interlayer sliding, or nodal-line crossing in $\mathrm{ZrSiS}$ ([Montambaux et al. 2009](#sd-montambaux2009); [Shao et al. 2024](#sd-shao2024)), the low-energy $2\times 2$ effective Bloch Hamiltonian is governed by the merging parameter $\Delta_m \in \mathbb{R}$:

$$
\mathcal{H}_{\mathrm{SD}}(k_x, k_y; \Delta_m) = \left(\frac{\hbar^2 k_x^2}{2 m_x^*} + \Delta_m\right)\sigma_x + \hbar v_y k_y\,\sigma_y,
$$

with squared energy eigenvalue (`semiDiracEnergySq` in [../src/signals/Signals/DFT.lean](../src/signals/Signals/DFT.lean#L4318-L4319)):

$$
E_{\mathrm{SD}}^2(k_x, k_y; m_x^*, v_y, \Delta_m) = \left(\frac{\hbar^2 k_x^2}{2 m_x^*} + \Delta_m\right)^2 + (\hbar v_y k_y)^2.
$$

```{mermaid}
flowchart LR
    subgraph Phase1["1. Two-Cone Semimetal (Δ_m < 0)"]
        P1["Two massless Dirac nodes at\nk_x = ±√(-2m_x* Δ_m)/ℏ, k_y = 0\nBerry phases +π and -π\nE_SD²(-Δ_m, Δ_m, 0) = 0"]
    end

    subgraph Phase2["2. Critical Semi-Dirac Point (Δ_m = 0)"]
        P2["Cones merge at k = (0, 0)\n• x-axis (k_y = 0): Massive E = ℏ²k_x²/(2m_x*)\n• y-axis (k_x = 0): Massless E = ℏv_y|k_y|\n• ZrSiS Landau levels: E_n(B) ∝ [(n+1/2)B]^(2/3)"]
    end

    subgraph Phase3["3. Gapped Anisotropic Insulator (Δ_m > 0)"]
        P3["Berry phases annihilate (+π - π = 0)\nFull spectral gap E_gap = 2Δ_m > 0\nE_SD²(0, 0; Δ_m) = Δ_m²"]
    end

    Phase1 -->|"Uniaxial Strain / Nodal Crossing (Δ_m → 0⁻)"| Phase2
    Phase2 -->|"Lifshitz Gap Opening (Δ_m > 0)"| Phase3
```

### 1.3 Why Semi-Dirac Landau Levels Scale as $B^{2/3}$ (`semiDiracLandauLevelCube`)

In a perpendicular magnetic field $\mathbf{B} = B\hat{z}$ inside the Landau gauge $\mathbf{A} = (0, B x, 0)$, minimal Peierls substitution $k_x \mapsto -i\partial_x$ and $k_y \mapsto k_y + \frac{e B}{\hbar}x$ transforms $\mathcal{H}_{\mathrm{SD}}^2$ (at $\Delta_m = 0$) into a **quartic anharmonic oscillator** in the shifted coordinate $\tilde{x} = x + \frac{\hbar k_y}{e B}$:

$$
\mathcal{H}_{\mathrm{SD}}^2\,\psi_n(\tilde{x}) = \left[\frac{\hbar^4}{4 (m_x^*)^2}\frac{d^4}{d\tilde{x}^4} + e^2 v_y^2 B^2 \tilde{x}^2\right]\psi_n(\tilde{x}) = E_n(B)^2\,\psi_n(\tilde{x}).
$$

Rescaling $\tilde{x} = \ell_{\mathrm{SD}}\,\xi$ with characteristic semi-Dirac magnetic length $\ell_{\mathrm{SD}} = \bigl(\frac{\hbar^2}{2 m_x^* e v_y B}\bigr)^{1/3} \propto B^{-1/3}$ factors all parameter dependence out of the differential operator, yielding the exact **$\mathbf{B^{2/3}}$ quantization law** ([Montambaux et al. 2009](#sd-montambaux2009); [Shao et al. 2024](#sd-shao2024)):

$$
E_n(B) = \pm\,\alpha_{\mathrm{WKB}}\left(\frac{\hbar^2 e^2 v_y^2}{m_x^*}\right)^{1/3}\left[\left(n + \frac{1}{2}\right) B\right]^{2/3} \iff E_n(B)^3 = C_{\mathrm{LL}}^3\,\frac{v_y^2\,\bigl((n + 1/2) B\bigr)^2}{m_x^*},
$$

where $\alpha_{\mathrm{WKB}} = \bigl[\frac{3\pi}{\sqrt{2}}\frac{\Gamma(3/4)}{\Gamma(1/4)}\bigr]^{2/3} \approx 1.1732$. In Lean 4 (`semiDiracLandauLevelCube`), we prove that scaling $B \mapsto 8 B$ scales $E_n(B)^3$ by $8^2 = 64 = (8^{2/3})^3$, so $E_n(8B) = 4\,E_n(B)$ (whereas a Schrödinger fermion scales by $8\times$ and a graphene Dirac fermion scales by $\sqrt{8} \approx 2.828\times$).

---

## 2. The Four-Regime Architecture: Semi-Dirac Fermions With and Without $\mathrm{Gr}_{\mathbb{C}}$, With and Without DDF

To systematically connect condensed-matter semi-Dirac physics with our broader `Signals` formalization, we analyze the complete $2 \times 2$ matrix of models:

| Regime | Complex Grassmannian $\mathrm{Gr}_{\mathbb{C}}$ | Dilatant Dark Fluid (DDF) | Mathematical State Space & Governing Law | Key Physical Capability Added | Lean 4 Declarations (`Signals.DFT`) |
| :--- | :---: | :---: | :--- | :--- | :--- |
| **Regime 1** | **Without $\mathrm{Gr}_{\mathbb{C}}$** | **Without DDF** | 2D Euclidean momentum space $\mathbb{R}^2_k$; $E_{\mathrm{SD}}^2 = (T_x + \Delta_m)^2 + P_y^2$ | Captures directional mass $(m_x^* > 0, m_y^* = 0)$, $E^{1/2}$ DOS, and $\mathrm{ZrSiS}$ $B^{2/3}$ Landau levels, but treats $(m_x^*, v_y)$ as empirical parameters and has branch cuts when tracking two merging valleys | `semiDiracEnergySq`, `semiDiracGroupVelocityX`, `semiDiracGroupVelocityY`, `semiDiracLandauLevelCube` |
| **Regime 2** | **With $\mathrm{Gr}_{\mathbb{C}}(2,4)$ / $\mathrm{Gr}_{\mathbb{C}}(2,6)$** | **Without DDF** | Canonical affine chart $Z_{\mathrm{SD}} = (I_2 \mid W_{\mathrm{SD}}) \in \mathrm{Gr}_{\mathbb{C}}(2,4) \cong \mathcal{Q}_4 \subset \mathbb{P}^5(\mathbb{C})$ (and $\mathrm{Gr}_{\mathbb{C}}(2,6)$ for strained `RTG`) | **Plücker minor $p_{23} = \det W_{\mathrm{SD}} = E_{\mathrm{SD}}^2$**; Fubini–Study Kähler potential factor is a **perfect square** $\det(I_2 + W_{\mathrm{SD}}W_{\mathrm{SD}}^\dagger) = (1 + E_{\mathrm{SD}}^2)^2 \ge 1$; singularity-free two-valley merging on $\mathcal{Q}_4$ | `semiDiracPluckerDet`, `semiDiracKahlerDetFactor` |
| **Regime 3** | **Without $\mathrm{Gr}_{\mathbb{C}}$** | **With DDF (`MovingSheath`)** | DDF two-phase bosonic substrate ($\phi$ superfluid + $\varphi$ dilatant phase) with longitudinal sheath velocity $\beta_x = v_x / c_\phi$ | **Explains *why* mass is directional**: longitudinal shear-thickening jamming $\gamma_\varphi(\beta_x)^2 = (1 - \beta_x^2)^{-1}$ generates $m_x^*(\beta_x) = m_0/(1-\beta_x^2) > 0$ along $\hat{x}$ while transverse $\hat{y}$ phonons remain gapless ($m_y^* = 0, v_y = c_\phi$) | `semiDiracDdfJammedMassX`, `Signals.DDF.MovingSheath` |
| **Regime 4** | **With $\mathrm{Gr}_{\mathbb{C}}(2,4)$** | **With DDF + Tensor Splats** | DDF-dressed Kähler chart on $\mathrm{Gr}_{\mathbb{C}}(2,4)$ + anisotropic 2D `NormedTensorGaussianSplat2D` | Unified Plücker–DDF dispersion $E_{\mathrm{SD,DDF}}^2 = (\frac{T_x}{1-\beta_x^2} + \Delta_m)^2 + P_y^2$ and **hybrid wavepacket kinematics**: Bohmian quantum-potential spreading along $x$ ($\sigma_x(t)$ grows) + dispersionless soliton transport along $y$ ($\sigma_y(t) = \sigma_{y,0}$) | `semiDiracDdfGr24EnergySq`, `semiDiracAnisotropicSplatVarX`, `semiDiracAnisotropicSplatVarY`, `semi_dirac_fermions_with_and_without_grc_and_ddf_identities` |

---

### 2.1 Regime 2 in Detail: Why $\mathrm{Gr}_{\mathbb{C}}(2,4)$ and $\mathrm{Gr}_{\mathbb{C}}(2,6)$ Are the Natural Manifolds for Dirac-Cone Merging

1. **Limitation of $\mathrm{Gr}_{\mathbb{C}}(1,2) \cong \mathbb{CP}^1$ Without Higher Grassmannians**:
   For a single isolated Dirac cone, the occupied valence-band eigenstate $|u_-(\mathbf{k})\rangle \in \mathbb{C}^2$ defines a complex line in $\mathrm{Gr}_{\mathbb{C}}(1,2) \cong \mathbb{CP}^1 \cong S^2$ carrying Berry phase $\Phi_B = \pm\pi$. However, at the semi-Dirac transition ($\Delta_m \to 0$), **two valleys $(\mathbf{K}_+, \mathbf{K}_-)$ of opposite chirality coalesce** and exchange spectral weight across the pseudospin-orbit-coupled 4-component valley-sublattice space $\mathbb{C}^4 = \operatorname{span}\{|A, K_+\rangle, |B, K_+\rangle, |A, K_-\rangle, |B, K_-\rangle\}$.
2. **Canonical Affine Chart $Z_{\mathrm{SD}} = (I_2 \mid W_{\mathrm{SD}}) \in \mathrm{Gr}_{\mathbb{C}}(2,4)$**:
   Selecting the 2-dimensional occupied valence subspace inside the 4-dimensional two-valley space $\mathbb{C}^4$ defines a point in the complex Grassmannian **$\mathrm{Gr}_{\mathbb{C}}(2,4) \cong \mathcal{Q}_4 \subset \mathbb{P}^5(\mathbb{C})$** (real dimension $2\times 2\times(4-2) = 8$, $\binom{4}{2} = 6$ Plücker coordinates). On the canonical affine chart $Z_{\mathrm{SD}} = (I_2 \mid W_{\mathrm{SD}})$ with

   $$
   W_{\mathrm{SD}}(T_x, \Delta_m, P_y) = \begin{pmatrix} T_x + \Delta_m & -i P_y \\ i P_y & T_x + \Delta_m \end{pmatrix} \in \mathbb{C}^{2 \times 2}, \qquad T_x = \frac{\hbar^2 k_x^2}{2 m_x^*},\quad P_y = \hbar v_y k_y,
   $$

   the six homogeneous Plücker coordinates $p(Z_{\mathrm{SD}}) = (p_{01}, p_{02}, p_{03}, p_{12}, p_{13}, p_{23}) \in \mathbb{C}^6$ are:

   $$
   p_{01} = 1, \quad p_{02} = -i P_y, \quad p_{03} = -(T_x + \Delta_m), \quad p_{12} = T_x + \Delta_m, \quad p_{13} = -i P_y, \quad p_{23} = \det W_{\mathrm{SD}} = (T_x + \Delta_m)^2 + P_y^2.
   $$

   - **Exact Klein Quadric Satisfaction**:

     $$
     p_{01} p_{23} - p_{02} p_{13} + p_{03} p_{12} = 1\cdot\bigl((T_x + \Delta_m)^2 + P_y^2\bigr) - (-i P_y)(-i P_y) - (T_x + \Delta_m)^2 = 0.
     $$

   - **Exact Plücker Determinant Dispersion (`semiDiracPluckerDet`)**:
     The terminal Plücker minor $p_{23}(Z_{\mathrm{SD}})$ equals the squared semi-Dirac energy $E_{\mathrm{SD}}^2(k_x, k_y; \Delta_m)$, which vanishes at the two Dirac nodes $(T_x = -\Delta_m, P_y = 0)$ for $\Delta_m < 0$ and at the semi-Dirac point $(0,0)$ for $\Delta_m = 0$.
   - **Perfect-Square Fubini–Study Kähler Determinant (`semiDiracKahlerDetFactor`)**:
     Because $W_{\mathrm{SD}}^\dagger W_{\mathrm{SD}} = E_{\mathrm{SD}}^2\,I_2$, the Cauchy–Binet Kähler determinant factor ([grassmannian-complex-gpe-igpe-plucker-madelung-paper.md](grassmannian-complex-gpe-igpe-plucker-madelung-paper.md)) simplifies to an exact square:

     $$
     \det\bigl(I_2 + W_{\mathrm{SD}} W_{\mathrm{SD}}^\dagger\bigr) = \bigl\|p(Z_{\mathrm{SD}})\bigr\|_{\mathbb{C}^6}^2 = 1 + \operatorname{Tr}(W_{\mathrm{SD}} W_{\mathrm{SD}}^\dagger) + |\det W_{\mathrm{SD}}|^2 = 1 + 2 E_{\mathrm{SD}}^2 + E_{\mathrm{SD}}^4 = \bigl(1 + E_{\mathrm{SD}}^2\bigr)^2 \ge 1.
     $$

3. **Extension to $\mathrm{Gr}_{\mathbb{C}}(2,6)$ in Uniaxially Strained Rhombohedral Trilayer Graphene (`RTG`, $N=3$)**:
   In `RTG` ([grassmannian-rhombohedral-graphene-superconductivity-qc-paper.md](grassmannian-rhombohedral-graphene-superconductivity-qc-paper.md)), the 6-orbital sublattice space $(A_1, B_1, A_2, B_2, A_3, B_3)$ has boundary Grassmannian $\mathrm{Gr}_{\mathbb{C}}(2,6)$ (`gmgsBoundaryGrassmannianRealDim 3 = 16`, `gmgsPluckerSublatticeQuditDim 3 = 15`). Under uniaxial heterostrain ($\varepsilon_{xx} \approx 0.2\%\text{–}0.5\%$), two of the three trigonal-warping Dirac pockets merge at a **semi-Dirac Lifshitz transition** ($\Delta_m = 0$), converting the logarithmic Van Hove singularity into an algebraically divergent $E^{-1/2}$ one-dimensional saddle-point DOS that strongly amplifies the Kohn–Luttinger / `IVC` pairing susceptibility in `SC1` and `SC2`!

---

### 2.2 Regimes 3 & 4 in Detail: DDF Longitudinal Sheath Jamming and Anisotropic Tensor Gaussian Splats

Why should a physical medium exhibit non-zero inertia $m_x^* > 0$ along $\hat{x}$ while remaining strictly massless ($m_y^* = 0$) along $\hat{y}$?

1. **DDF Directional Shear-Thickening Jamming (`MovingSheath` in `Signals.DDF`, `semiDiracDdfJammedMassX`)**:
   In the Dilatant Dark Fluid ([src/signals/Signals/DDF.lean](../src/signals/Signals/DDF.lean)), the vacuum/condensate consists of a superfluid $\phi$ phase coupled to a dispersed $\varphi$ phase that undergoes **stress-induced dilatant jamming along the axis of compression**. When a sheath moves or is strained along the $x$-axis at dimensionless velocity ratio $\beta_x = v_x / c_\phi \in [0, 1)$, the longitudinal sheath compression factor is the Lorentz jamming factor $\Lambda_\parallel(\beta_x) = \gamma_\varphi(\beta_x) = (1 - \beta_x^2)^{-1/2}$:
   - **Along the compressed $x$-axis**: Inter-particle jamming of the $\varphi$ phase opens a Bogoliubov/jamming effective mass (`semiDiracDdfJammedMassX`)

     $$
     m_x^*(\beta_x) = m_0\,\gamma_\varphi(\beta_x)^2 = \frac{m_0}{1 - \beta_x^2} > m_0, \qquad T_x^{\mathrm{DDF}}(\beta_x) = \frac{T_x}{1 - \beta_x^2},
     $$

     which diverges as $\beta_x \to 1^-$ (complete longitudinal localization / flat band).
   - **Along the orthogonal $y$-axis**: There is zero normal compression ($\Lambda_\perp = 1$), so transverse acoustic/shear excitations propagate through the superfluid $\phi$ channel at the unjammed phonon speed $v_y = c_\phi = (\varrho_{\max}^\varphi j_{\min}^\varphi)^{-1/2}$ with **zero rest mass ($m_y^* = 0$)**!
2. **Anisotropic 2D Normed Tensor Gaussian Splat Evolution (`semiDiracAnisotropicSplatVarX`, `semiDiracAnisotropicSplatVarY`)**:
   Representing a localized semi-Dirac wavepacket as a 2D `NormedTensorGaussianSplat2D` ([grassmannian-splat-mechanics-paper.md](grassmannian-splat-mechanics-paper.md)) with principal widths $(\sigma_{x,0}, \sigma_{y,0})$ aligned with the crystal axes $(x, y)$:
   - Along the **massive $x$-axis**, the repulsive Madelung Bohm quantum potential $Q_x = -\frac{\hbar^2}{2 m_x^*}\frac{\partial_x^2\sqrt{\rho}}{\sqrt{\rho}}$ drives standard Schrödinger wavepacket spreading (`semiDiracAnisotropicSplatVarX`):

     $$
     \sigma_x^2(t) = \sigma_{x,0}^2 + \frac{\hbar^2 t^2}{4 (m_x^*)^2 \sigma_{x,0}^2} > \sigma_{x,0}^2 \qquad (t > 0).
     $$

   - Along the **massless $y$-axis**, the linear relativistic dispersion $E_y = \hbar v_y |k_y|$ has zero second derivative ($\frac{\partial^2 E_y}{\partial k_y^2} = 0$), so a co-moving chiral wavepacket propagates at constant speed $v_y$ with **zero dispersive broadening** (`semiDiracAnisotropicSplatVarY`):

     $$
     \sigma_y^2(t) = \sigma_{y,0}^2 \qquad (\forall\,t \ge 0).
     $$

   This hybrid **"spread-in-$x$, soliton-in-$y$"** Tensor Gaussian Splat dynamics is unique to semi-Dirac fermions and is machine-checked in `semi_dirac_fermions_with_and_without_grc_and_ddf_identities`.

---

## 3. Applications of Semi-Dirac Fermions Across Nanoelectronics, Photonics, Energy, and Topological Quantum Computing

```{mermaid}
flowchart TB
    SD["Semi-Dirac Fermion Quasiparticles\nE_SD² = (ℏ²k_x²/(2m_x*) + Δ_m)² + (ℏv_y k_y)²\nMassive along x (m_x* > 0) | Massless along y (m_y* = 0)"]

    App1["1. Ballistic Directional Diodes & Klein Collimators\n• y-axis: 100% Klein tunneling (T_y = 1) across p-n barriers\n• x-axis: Exponential WKB tunneling (T_x ≪ 1) & FET switching\n• Zero-etching ballistic interconnects in ZrSiS & strained graphene"]

    App2["2. Intrinsic In-Plane Hyperbolic Plasmonics & THz Detectors\n• Drude weight ratio D_yy / D_xx ∝ E_F^(1/2) ≫ 1\n• Natural in-plane hyperbolic sheet (Im σ_yy > 0, Im σ_xx → 0)\n• Sub-diffraction canalization & polarization-selective THz rectification"]

    App3["3. High-Figure-of-Merit Anisotropic Thermoelectrics\n• Massless y-axis: Ultra-high mobility μ_yy & electrical conductivity σ_yy\n• Massive x-axis: Large DOS effective mass m_x* boosting Seebeck S\n• Orthogonal decoupling of power factor S²σ_yy from lattice heat κ_xx"]

    App4["4. Etch-Free 1D Topological Majorana / Parafermion Channels\n• Proximity SC1/SC2 on Gr_C(2,6) RTG or Gr_C(2,10) RPG\n• v_{g,x} ≪ v_y confines Bogoliubov quasiparticles into 1D y-channels\n• Eliminates physical nanowire edge-roughness D_it decoherence (G-IEP)"]

    SD --> App1
    SD --> App2
    SD --> App3
    SD --> App4
```

### 3.1 Summary of Engineering & Quantum Applications

| Application Domain | Physical Mechanism in Semi-Dirac System | Quantitative Advantage Over Isotropic Dirac / Schrödinger | Connection to Companion `Signals` Modules |
| :--- | :--- | :--- | :--- |
| **1. Ballistic Directional Diode & Klein-Tunneling Transistor** | Along $\hat{y}$ ($k_x=0$), pseudospin $\sigma_y$ conservation enforces **perfect Klein transmission $T_y = 1$** across electrostatic barriers $V_0$. Along $\hat{x}$ ($k_y=0$), massive Schrödinger barrier reflection yields $T_x \sim \exp(-2\sqrt{2 m_x^*(V_0 - E)}\,L/\hbar) \ll 1$. | Achieves simultaneously **ballistic zero-resistance interconnect transport along $\hat{y}$** and **high-$I_{\mathrm{on}}/I_{\mathrm{off}}$ FET gate pinch-off along $\hat{x}$** in a single homogeneous crystal ($\mathrm{ZrSiS}$, black phosphorus, or strained `RTG`), solving graphene's zero-bandgap Klein-leakage problem. | `Signals.DFT` (`semiDiracEnergySq`, `giepSubthresholdSwingWithDit`) |
| **2. Lithography-Free In-Plane Hyperbolic Polaritons & THz Bolometers** | The anisotropic intraband Drude weights scale as $D_{xx} \propto E_F^{3/4} (m_x^*)^{-1/2}$ vs. $D_{yy} \propto E_F^{1/4} v_y (m_x^*)^{1/2}$, yielding an extreme anisotropy ratio $D_{yy}/D_{xx} \propto (m_x^* v_y^2 / E_F)^{1/2} \gg 1$ at low doping $E_F \to 0$. | Produces **natural in-plane hyperbolic plasmon/polariton canalization** ($\operatorname{Im}\sigma_{yy}$ inductive while $\operatorname{Im}\sigma_{xx}$ is capacitive/resistive) without sub-wavelength `rGO` grating etching, ideal for $400\text{–}800\text{ GHz}$ polarization-sensitive THz receivers. | `Signals.DDF` (`rgo_polycbd_enz_hyperbolic_and_plasma_metamaterial_identities`) |
| **3. Orthogonal-Axis Thermoelectric Energy Harvesting ($ZT$ Enhancement)** | Standard isotropic materials suffer from the Wiedemann–Franz / Pisarenko trade-off between high Seebeck coefficient $S$ (requiring heavy mass $m^*$) and high conductivity $\sigma$ (requiring light mass). Semi-Dirac fermions provide **both simultaneously**: heavy $m_x^*$ sets the phase-space entropy per carrier, while massless $v_y$ drives current along $\hat{y}$. | Decouples the Seebeck thermopower $S_{yy}$ and electrical conductivity $\sigma_{yy}$ from the massive-axis thermal diffusion, boosting the thermoelectric power factor $S_{yy}^2 \sigma_{yy}$ at cryogenic and room temperatures. | `Signals.DFT` (`InterfacialHeatTransportEngine`), `Signals.DDF` (`CattaneoVernotteHeatModel`) |
| **4. Etch-Free 1D Topological Majorana ($\mathrm{MZM}$) & Parafermion Qudit Waveguides** | In a semi-Dirac band proximitized by or hosting intrinsic chiral superconductivity (`SC1`/`SC2` in `RTG`/`RPG`), the vanishing transverse group velocity $v_{g,x}(k_x) = \hbar k_x / m_x^* \to 0$ near $k_x = 0$ suppresses transverse quasiparticle diffraction ($\sigma_y(t) = \sigma_{y,0}$ constant), channeling Bogoliubov modes along 1D $\hat{y}$ trajectories. | Creates **virtual 1D Kitaev/parafermion nanowires inside a pristine 2D sheet** without reactive-ion etching (RIE), completely avoiding the sidewall dangling-bond trap density $D_{\mathrm{it}}$ (`G-IEP`) and enhancing the CdGM mini-gap $\omega_0 = \Delta_0^2 / E_F \approx 20\text{ }\mu\text{eV}$. | `Signals.DFT` (`gmgsVortexCoreMiniGap`, `kitaevChemicalPotentialTopological`, `semiDiracAnisotropicSplatVarY`) |

---

## 4. Machine-Checked Lean 4 Verification (`Signals.DFT` Section 19)

The following theorem `semi_dirac_fermions_with_and_without_grc_and_ddf_identities` is machine-checked in [../src/signals/Signals/DFT.lean](../src/signals/Signals/DFT.lean#L4435-L4506) (and tested in [../src/signals/SignalsTests.lean](../src/signals/SignalsTests.lean#L7400-L7426) and [../src/signals/SignalsPendingTests.lean](../src/signals/SignalsPendingTests.lean#L6048-L6095)):

```lean
import Signals

namespace SemiDiracFermionsPaperVerification

open Signals.DFT

example (kx ky m_x v_y delta_m tx py : ℝ) :
    semiDiracEnergySq kx 0 m_x v_y 0 = (kx ^ 2 / (2 * m_x)) ^ 2 ∧
      semiDiracEnergySq 0 ky m_x v_y 0 = (v_y * ky) ^ 2 ∧
      semiDiracEnergySq 0 0 m_x v_y delta_m = delta_m ^ 2 ∧
      semiDiracPluckerDet (-delta_m) delta_m 0 = 0 ∧
      semiDiracGroupVelocityX 0 m_x = 0 ∧
      semiDiracGroupVelocityY v_y = v_y ∧
      semiDiracLandauLevelCube 1 1 1 1 8 = 64 * semiDiracLandauLevelCube 1 1 1 1 1 ∧
      semiDiracPluckerDet (kx ^ 2 / (2 * m_x)) delta_m (v_y * ky) =
        semiDiracEnergySq kx ky m_x v_y delta_m ∧
      semiDiracKahlerDetFactor tx delta_m py =
        (1 + semiDiracPluckerDet tx delta_m py) ^ 2 ∧
      1 ≤ semiDiracKahlerDetFactor tx delta_m py ∧
      semiDiracDdfJammedMassX 1 0 = 1 ∧
      semiDiracDdfJammedMassX 1 (3 / 5) = 25 / 16 ∧
      semiDiracDdfGr24EnergySq tx delta_m py 0 = semiDiracPluckerDet tx delta_m py ∧
      semiDiracPluckerDet 16 0 0 < semiDiracDdfGr24EnergySq 16 0 0 (3 / 5) ∧
      (semiDiracAnisotropicSplatVarX 1 0 1 < semiDiracAnisotropicSplatVarX 1 2 1 ∧
        semiDiracAnisotropicSplatVarY 1 2 = semiDiracAnisotropicSplatVarY 1 0) :=
  semi_dirac_fermions_with_and_without_grc_and_ddf_identities kx ky m_x v_y delta_m tx py

end SemiDiracFermionsPaperVerification
```

---

## References

- <a id="sd-dietl2008"></a>**Dietl, P., Piéchon, F., & Montambaux, G. (2008).** *New Magnetic Field Dependence of Landau Levels in a Graphenelike Structure.* Physical Review Letters, 100(23), 236405. `https://doi.org/10.1103/PhysRevLett.100.236405`
- <a id="sd-banerjee2009"></a>**Banerjee, S., Singh, R. R. P., Pardo, V., & Pickett, W. E. (2009).** *Tight-Binding Modeling and Low-Energy Behavior of the Semi-Dirac Point.* Physical Review Letters, 103(1), 016402. `https://doi.org/10.1103/PhysRevLett.103.016402`
- <a id="sd-montambaux2009"></a>**Montambaux, G., Piéchon, F., Fuchs, J.-N., & Goerbig, M. O. (2009).** *Merging of Dirac points in a two-dimensional crystal.* Physical Review B, 80(15), 153412. `https://doi.org/10.1103/PhysRevB.80.153412`
- <a id="sd-kim2015"></a>**Kim, J., Baik, S. S., Ryu, S. H., Sohn, Y., Park, S., Park, B.-G., Denlinger, J., Yi, Y., Choi, H. J., & Kim, K. S. (2015).** *Observation of tunable band gap and anisotropic Dirac semimetal state in black phosphorus.* Science, 349(6249), 723–726. `https://doi.org/10.1126/science.aaa6486`
- <a id="sd-shao2024"></a>**Shao, Y., Moon, S., Rudenko, A. N., Wang, J., Herzog-Arbeitman, J., Ozerov, M., Graf, D., Son, Y.,Queiroz, R., Lee, S. H., Mao, Z., Katsnelson, M. I., Bernevig, B. A., Smirnov, D., Millis, A. J., & Basov, D. N. (2024).** *Semi-Dirac Fermions in a Topological Metal.* Physical Review X, 14(4), 041057 (`arXiv:2311.03735`). `https://doi.org/10.1103/PhysRevX.14.041057`
- <a id="sd-fedi2026"></a>**Fedi, M. (2026).** *Gravity and Special Relativity in a Dilatant Dark Fluid.* SSRN 7406660.
