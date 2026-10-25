---
title: "Normed 2D and 3D Tensor Gaussian Splats in Lean 4: Simultaneous Conservation Laws, Holographic Gr_C(2,4) Affine Projection, Inversion-Free Schur–Plücker Calculus, and Multi-Domain Applications"
description: "An arXiv-ready MyST Markdown formal verification paper detailing 2D and 3D normed anisotropic Tensor Gaussian Splats in the Signals Lean 4 library and LeanArchitect Blueprint, proving all simultaneous splitting conservation and holographic Gr_C(2,4) projection laws, and cataloging applications in Appendices across all companion grassmannian-*-paper.md studies."
---

(gaussian-splat-tensors-normed-paper)=
# Normed 2D and 3D Tensor Gaussian Splats in Lean 4: Simultaneous Conservation Laws, Holographic $Gr_{\mathbb{C}}(2,4)$ Affine Projection, Inversion-Free Schur–Plücker Calculus, and Multi-Domain Applications

- **Authors:** Wes Turner
- **Subjects:**
  - Mathematical Physics (`math-ph`); Computational Physics (`physics.comp-ph`); Optics (`physics.optics`); Fluid Dynamics (`physics.flu-dyn`); Logic in Computer Science (`cs.LO`)
- **Formal Verification & Simulation Artifacts:**
  - `Signals` Lean 4 Library (`leanprover/lean4:v4.35.0-rc3`, [../Signals/DDF.lean](../Signals/DDF.lean), [../Signals/Pending.lean](../Signals/Pending.lean), [../SignalsTests.lean](../SignalsTests.lean))
  - `Signals` LeanArchitect Blueprint ([../blueprint/src/content.tex](../blueprint/src/content.tex))
  - `signals-numerical-adapter` Rust/WASM/GLSL Crate ([../numerical_adapter/src/orbital_splat.rs](../numerical_adapter/src/orbital_splat.rs))

- **Companion `grassmannian-*-paper.md` Series:**
  1. [Huygens–Steiner Barycentric Coherence, Complex $Gr_{\mathbb{C}}(2,4)$ Plücker Channels, and Multi-Model Double-Slit & OAM Relative Predictive Error in Lean 4](../../../docs/grassmannian-huygens-double-slit-oam-paper.md)
  2. [Grassmannian Geometry of the Quantum Inverse Scattering Method, Algebraic Bethe Ansatz, and Inverse Scattering Metrology in Lean 4](../../../docs/grassmannian-qism-bethe-ansatz-paper.md)
  3. [Complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ & $N$-ary $Gr_{\mathbb{C}}(2, N+2)$ Unification with Dilatant Dark Fluid (DDF) Moving Sheaths, Plücker Sink Fluxes, Anosov Invariance, and Sorkin Triple-Slit Interferometry in Lean 4](../../../docs/grassmannian-ddf-moving-sheath-paper.md)
  4. [Grassmannian Gravity from QED & Gauge Scattering Amplitudes: Complex $Gr_{\mathbb{C}}(2,4)$ Orbital Precession, Mercury's Perihelion, $N$-Body Dynamics, and Dilatant Dark Fluid (DDF) Unification in Lean 4](../../../docs/grassmannian-gravity-from-qed-scattering-paper.md)
  5. [Normed Tensor Gaussian Splat Mechanics for Complex $Gr_{\mathbb{C}}(2,4)$ Twistors: Advantages, Limitations, WebGL2/WASM Practicality, and Unification Across Double-Slit, QISM, DDF, and Planetary Gravity in Lean 4](../../../docs/grassmannian-splat-mechanics-paper.md)
  6. [Inelastic Scattering and the Heat Problem in Unified Grassmannian–DDF Mechanics: Inverse Compton, Stokes/Anti-Stokes Raman, Fourier vs. Cattaneo–Vernotte, and Subluminal Second-Sound Tensor Splatting in Lean 4](../../../docs/grassmannian-thermal-compton-raman-paper.md)
  7. [Polaritons and Surface Plasmon Polaritons (SPPs) in Unified Grassmannian–DDF Mechanics: Hopfield–Rabi Anticrossing, Lyddane–Sachs–Teller Reststrahlen Bands, $Gr_{\mathbb{C}}(2,4)$ Evanescent Skin-Depth Duality, and Sub-Wavelength Tensor Splatting in Lean 4](../../../docs/grassmannian-polariton-spp-mechanics-paper.md)
  8. [The Holographic Principle in Complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ and Dilatant Dark Fluid (DDF) Mechanics: 't Hooft–Susskind Horizon Entropy, Gauss–Smarr Bulk Mass Recovery, Plücker Redshift Lapse, and Planck Tensor Splatting in Lean 4](../../../docs/grassmannian-holographic-principle-paper.md)
  9. [AdS/CFT Correspondence, Planar Integrability, and Secret Symmetries in Unified Complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ and Dilatant Dark Fluid (DDF) Mechanics: From Maldacena and $\mathfrak{psl}(2|2)_c$ Yangians to Plücker Outer Automorphisms and Holographic RG Tensor Splatting in Lean 4](../../../docs/grassmannian-ads-cft-ddf-paper.md)
  10. [Unification, Engineering Applications, and Research Roadmap of Complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ and Dilatant Dark Fluid (DDF) Mechanics: Cross-Domain Plücker Invariants, Photonic–Thermal–Quantum Systems, and Formal Verification in Lean 4](../../../docs/grassmannian-unification-applications-roadmap-paper.md)
  11. [Holographic $Gr_{\mathbb{C}}(2,4)$ Depth Recovery and Convergent Multi-Beam Volumetric Imaging: Plücker Axial Variance Inversion, Perspective Range Tomography, and Self-Calibrating Phase Conjugation in Lean 4](grassmannian-holographic-imaging-depth-recovery-paper.md)

---

## Abstract

We present a comprehensive mathematical and formal-verification treatise on **Normed Anisotropic Tensor Gaussian Splats** in two and three spatial dimensions (`NormedTensorGaussianSplat2D` and `NormedTensorGaussianSplat3D` in [../Signals/DDF.lean](../Signals/DDF.lean#L2466-L6065), and velocity-space `TensorGaussianSplat` in [../Signals/Pending.lean](../Signals/Pending.lean#L813-L845)), together with their LeanArchitect (`@[blueprint]`) dependency graph and Rust/WASM/WebGL2 numerical implementation ([../numerical_adapter/src/orbital_splat.rs](../numerical_adapter/src/orbital_splat.rs#L172-L914)). Specifically:

1. **Unified 2D and 3D Normed Tensor Gaussian Splat Primitives**:
   We formulate exact $L^1(\mathbb{R}^d)$-normalized Gaussian wavepackets ($d \in \{2, 3\}$) whose principal variances $(\sigma_1^2, \sigma_2^2)$ or $(\sigma_1^2, \sigma_2^2, \sigma_3^2)$ encode complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ Plücker channel moduli while their square-root envelope $\sqrt{G(\mathbf{x})}\,\Delta_{02}^{\mathbb{C}}\Delta_{13}^{\mathbb{C}}$ carries coherent twistor interference, repulsive core Bohm quantum potential $Q_{\mathrm{core}}(\Sigma) = \frac{\hbar^2}{4m}\operatorname{Tr}(\Sigma^{-1})$, and Madelung quantum pressure tensor $\Pi_{ij}(\mathbf{x}) = \frac{\hbar^2}{4m^2}G(\mathbf{x})(\Sigma^{-1})_{ij}$.
2. **Complete Catalog of Simultaneous Conservation & Holographic $Gr_{\mathbb{C}}(2,4)$ Projection Laws**:
   We state and prove the full suite of simultaneous conservation laws for adaptive two-child splat splitting in 2D (`NormedTensorGaussianSplat2D.splitMajor_conservation_identities`) and 3D (`NormedTensorGaussianSplat3D.splitMajor3D_and_holographic_gr24_projection_identities`), establishing:
   - Exact $L^1$ mass conservation ($w_+ + w_- = w$),
   - Exact 2D and 3D center-of-mass preservation ($\frac{1}{2}(\mathbf{x}_+ + \mathbf{x}_-) = \mathbf{x}_c$),
   - Exact 2D and 3D major-axis second-moment variance conservation ($\|\mathbf{x}_+ - \mathbf{x}_c\|^2 + \tilde{\sigma}_1^2 = \sigma_1^2$ for displacement $\delta_1 = \frac{\sqrt{3}}{2}\sigma_1$),
   - Covariance determinant reduction ($\det\Sigma_+ = \frac{1}{4}\det\Sigma$) and dimension-independent core Bohm barrier amplification ($\Delta Q_{\mathrm{core}} = \frac{3\hbar^2}{4m\sigma_1^2} > 0$),
   - The **Holographic $Gr_{\mathbb{C}}(2,4)$ Affine Projection Trick** reducing 3D splats to 2D screen splats via additive Bohm mode splitting, perspective $1/z_c^2$ renormalization-group (RG) scaling, depth-invariance of lateral $Gr_{\mathbb{C}}(2,4)$ anisotropy, commutativity of in-plane splitting with projection, and exact recovery of the hidden 3rd principal variance $\sigma_3^2$ from the uncrossed Plücker channel ratio $\frac{|w_A^{\mathbb{C}}(M_{\mathrm{depth}})|^2}{|w_B^{\mathbb{C}}(M_{\mathrm{depth}})|^2} = \frac{\sigma_1^2 + \sigma_2^2}{\sigma_3^2}$.
3. **Inversion-Free Schur–Plücker Determinant Calculus (`schur_plucker_inversion_free_and_twistor_vane_identities`)**:
   We prove that $4 \times 4$ impeller shear Jacobian updates $\Sigma_{4\times 4} = J(s,\tau)J(s,\tau)^T$ and 3D Schur complements $\Sigma_{\mathrm{3D}} = A - B D^{-1} C$ reduce via the Schur determinant identity to an $O(1)$ inversion-free formula in the $Gr_{\mathbb{C}}(2,4)$ Plücker channel product $|w_A^{\mathbb{C}}(M_\tau)|^2|w_B^{\mathbb{C}}(M_\tau)|^2 = 1 - \tau^2$:
   $$\det(\Sigma_{\mathrm{3D}}) = \frac{(1 - \tau^2)^2}{1 + \tau^2},$$
   while diagnosing and fixing an upper-triangular sign bug ($\det = 1 + s\tau$) in the chat-proposed `AmplituhedronFluidSplat` matrix.
4. **Appendices of Multi-Domain Applications**:
   Appendices A–I detail how 2D and 3D normed tensor Gaussian splats apply across wave optics, QISM soliton buses, DDF moving sheaths and datacenter impellers, relativistic planetary orbits, Compton/Raman/second-sound heat transport, polaritons/SPPs and $\chi^{(2)}$ OPA squeezing, horizon/AdS holography, volumetric imaging & convergent holography, and atmospheric species scavenging.

---

## 1. Mathematical Architecture of Normed Tensor Gaussian Splats in 2D and 3D

### 1.1 Why Normed Anisotropic Tensor Gaussian Splats?

Standard visual 3D Gaussian Splatting ([Kerbl et al. 2023](#kerbl2023); [Zwicker et al. 2001](#zwicker2001)) treats each Gaussian primitive as an empirical radiance kernel optimized by stochastic gradient descent for novel-view synthesis, without enforcing $L^1$ mass/energy conservation, symplectic volume preservation, or quantum-hydrodynamic pressure balance. Conversely, in unified Complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ and Dilatant Dark Fluid (DDF) mechanics ([Fedi 2026](#fedi2026); [Grassmannian Splat Mechanics Chat 2026](#splat-chat2026)), a **Normed Tensor Gaussian Splat** is a conservation-enforcing Lagrangian wavepacket primitive:

```{mermaid}
flowchart TD
    subgraph Gr24["Complex Twistor & Plücker Layer (Signals.Geometry / Signals.DDF)"]
        M24["M_C ∈ Gr_C(2,4) (Lateral Anisotropy d_bary, Phase Δϕ)"]
        Mdepth["M_depth ∈ Gr_C(2,4) (Depth Anisotropy δ_depth, Phase θ_z)"]
    end

    subgraph Splat3D["3D Volumetric Layer: NormedTensorGaussianSplat3D"]
        S3["Center (x_c, y_c, z_c), Weight w ≥ 0\nPrincipal Widths (σ₁, σ₂, σ₃), Angles (θ, ψ)\nN_3D = 1 / ((2π)^{3/2} σ₁ σ₂ σ₃)"]
        Split3D["3D Adaptive Two-Child Split (splitMajorPlus / Minus)\nδ₁ = (√3/2)σ₁ along u₁ = (cos ψ cos θ, cos ψ sin θ, sin ψ)\nw_± = w/2, σ̃₁ = σ₁/2, ΔQ_core = 3ℏ²/(4mσ₁²)"]
    end

    subgraph HoloProj["Holographic Gr_C(2,4) Affine Projection Trick"]
        Ortho["projectOrthographic2D (X-Ray / Radon Marginal)"]
        Persp["projectPerspective2D (EWA / Poincaré Scale s = f / z_c)"]
        Recover["recoverDepthVarianceSq & recoverFocalDepthSq\nσ₃² = Tr Σ_ortho / R_depth,  z_c² = f² (Tr Σ_ortho / Tr Σ_persp)"]
    end

    subgraph Splat2D["2D Screen & Wavepacket Layer: NormedTensorGaussianSplat2D"]
        S2["Center (x_c, y_c), Weight w ≥ 0, Widths (σ₁, σ₂), Angle θ\nN_2D = 1 / (2π σ₁ σ₂),  Ψ_splat = √G(x,y) · Δ_02^C Δ_13^C"]
        Split2D["2D Adaptive Two-Child Split (splitMajorPlus / Minus)\nWebGL2 GLSL (#version 300 es) + Rust WASM (f64)"]
    end

    M24 --> S2
    M24 --> S3
    Mdepth --> S3
    S3 --> Split3D
    S3 --> Ortho
    S3 --> Persp
    Mdepth --> Recover
    Ortho --> Recover
    Persp --> Recover
    Ortho --> S2
    Persp --> S2
    S2 --> Split2D
```

### 1.2 The Three Splat Structures in the `Signals` Lean 4 Library

| Structure Name & Module Location | Dimension & Space | Core Fields & Positivity Guards | Primary Physical & Mathematical Role |
|---|---|---|---|
| [`NormedTensorGaussianSplat2D`](../Signals/DDF.lean#L2466-L2477) (`Signals.DDF`) | $2\text{D}$ configuration or screen plane $\mathbb{R}^2$ | `centerX`, `centerY`, `weight` ($w \ge 0$), `sigma1` ($\sigma_1 > 0$), `sigma2` ($\sigma_2 > 0$), `orientationAngle` ($\theta \in \mathbb{R}$) | 2D Madelung/orbital/polariton/thermal splat, $Gr_{\mathbb{C}}(2,4)$ twistor wavepacket $\Psi_{\mathrm{splat}}$, and WebGL2 screen primitive |
| [`NormedTensorGaussianSplat3D`](../Signals/DDF.lean#L5225-L5240) (`Signals.DDF`) | $3\text{D}$ bulk space $\mathbb{R}^3$ | `centerX`, `centerY`, `centerZ`, `weight` ($w \ge 0$), `sigma1`, `sigma2`, `sigma3` ($\sigma_i > 0$), `orientationAngle` ($\theta$), `pitchAngle` ($\psi$) | 3D volumetric packet with 3D adaptive splitting and holographic $Gr_{\mathbb{C}}(2,4)$ affine projection to `NormedTensorGaussianSplat2D` |
| [`TensorGaussianSplat`](../Signals/Pending.lean#L813-L826) (`Signals.Pending`) | $3\text{D}$ velocity space $\mathbb{R}_v^3$ | `species : AtmosphericSpecies`, `meanVelocity : Vector3`, `covariance : Matrix (Fin 3) (Fin 3) ℝ`, `thermalVariance = k_B T / m` | Species-resolved Maxwell–Boltzmann velocity-space Gaussian splat for multi-species atmospheric scavenging (`AtmosphericMixture`) |

#### 1.2.1 Exact 2D Definitions (`NormedTensorGaussianSplat2D`)

For a `splat : NormedTensorGaussianSplat2D` ([../Signals/DDF.lean](../Signals/DDF.lean#L2466-L2538)):

$$
\det\Sigma_{\mathrm{2D}} = \sigma_1^2\,\sigma_2^2 > 0, \qquad
\operatorname{Tr}\Sigma_{\mathrm{2D}} = \sigma_1^2 + \sigma_2^2 > 0, \qquad
\mathcal{N}_{\mathrm{2D}}(\Sigma_{\mathrm{2D}}) = \frac{1}{2\pi\,\sigma_1\,\sigma_2} > 0,
$$

$$
Q_{\Sigma_{\mathrm{2D}}}(x, y) = \left(\frac{u_1}{\sigma_1}\right)^2 + \left(\frac{u_2}{\sigma_2}\right)^2 \ge 0, \qquad
\begin{pmatrix} u_1 \\ u_2 \end{pmatrix} =
\begin{pmatrix} \cos\theta & \sin\theta \\ -\sin\theta & \cos\theta \end{pmatrix}
\begin{pmatrix} x - x_c \\ y - y_c \end{pmatrix},
$$

$$
G_{\mathrm{2D}}(x, y) = w\,\mathcal{N}_{\mathrm{2D}}(\Sigma_{\mathrm{2D}})\,\exp\!\left(-\frac{1}{2} Q_{\Sigma_{\mathrm{2D}}}(x, y)\right) \in \bigl[0,\, w\,\mathcal{N}_{\mathrm{2D}}(\Sigma_{\mathrm{2D}})\bigr].
$$

Its core repulsive Bohm quantum potential and Madelung quantum pressure tensor $\Pi_{ij}(x,y) = -\frac{\hbar^2}{4m^2}G_{\mathrm{2D}}(x,y)\partial_i\partial_j\ln G_{\mathrm{2D}}(x,y)$ ([../Signals/DDF.lean](../Signals/DDF.lean#L2838-L3025)) are:

$$
Q_{\mathrm{core,2D}}(\Sigma_{\mathrm{2D}}) = \frac{\hbar^2}{4m}\left(\frac{1}{\sigma_1^2} + \frac{1}{\sigma_2^2}\right) = \frac{\hbar^2\,\operatorname{Tr}\Sigma_{\mathrm{2D}}}{4m\,\det\Sigma_{\mathrm{2D}}} > 0, \qquad
\operatorname{Tr}\Pi(x, y) = \frac{1}{m}\,Q_{\mathrm{core,2D}}(\Sigma_{\mathrm{2D}})\,G_{\mathrm{2D}}(x, y).
$$

#### 1.2.2 Exact 3D Definitions (`NormedTensorGaussianSplat3D`)

For a `splat : NormedTensorGaussianSplat3D` ([../Signals/DDF.lean](../Signals/DDF.lean#L5225-L5285)) with unit major axis $\mathbf{u}_1 = (\cos\psi\cos\theta,\, \cos\psi\sin\theta,\, \sin\psi) \in S^2$:

$$
\det\Sigma_{\mathrm{3D}} = \sigma_1^2\,\sigma_2^2\,\sigma_3^2 > 0, \qquad
\operatorname{Tr}\Sigma_{\mathrm{3D}} = \sigma_1^2 + \sigma_2^2 + \sigma_3^2 > 0, \qquad
\mathcal{N}_{\mathrm{3D}}(\Sigma_{\mathrm{3D}}) = \frac{1}{(2\pi)^{3/2}\,\sigma_1\,\sigma_2\,\sigma_3} > 0,
$$

$$
Q_{\mathrm{core,3D}}(\Sigma_{\mathrm{3D}}) = \frac{\hbar^2}{4m}\left(\frac{1}{\sigma_1^2} + \frac{1}{\sigma_2^2} + \frac{1}{\sigma_3^2}\right) > 0.
$$

---

## 2. Complete Catalog of Simultaneous Conservation, Holographic $Gr_{\mathbb{C}}(2,4)$ Projection, and Schur–Plücker Laws

Below is the complete, cross-referenced list of simultaneous conservation and projection laws machine-checked in `Signals.DDF`.

### 2.1 The 9 Simultaneous 2D Adaptive Splat-Splitting Conservation Laws (`NormedTensorGaussianSplat2D.splitMajor_conservation_identities`)

Defined in [../Signals/DDF.lean](../Signals/DDF.lean#L5071-L5221) (Blueprint node `thm:signals-ddf-splat2d-split-major-conservation`) and implemented in Rust in [`NormedTensorGaussianSplat2D::split_if_anisotropic`](../numerical_adapter/src/orbital_splat.rs#L633-L674). For parent `splat` and children `c_plus = splat.splitMajorPlus`, `c_minus = splat.splitMajorMinus` with offset $\delta_1 = \frac{\sqrt{3}}{2}\sigma_1$ and halved major width $\tilde{\sigma}_1 = \sigma_1 / 2$:

| # | Law Name | Mathematical Statement | Lean 4 Accessor / Conjunct in `splitMajor_conservation_identities` |
|---|---|---|---|
| **2D-1** | **Exact $L^1(\mathbb{R}^2)$ Mass/Weight Conservation** | $w_+ + w_- = \frac{w}{2} + \frac{w}{2} = w$ | `h.1` (`c_plus.weight + c_minus.weight = splat.weight`) |
| **2D-2** | **Center-of-Mass $X$-Coordinate Preservation** | $\frac{1}{2}(x_+ + x_-) = x_c$ | `h.2.1` (`(c_plus.centerX + c_minus.centerX) / 2 = splat.centerX`) |
| **2D-3** | **Center-of-Mass $Y$-Coordinate Preservation** | $\frac{1}{2}(y_+ + y_-) = y_c$ | `h.2.2.1` (`(c_plus.centerY + c_minus.centerY) / 2 = splat.centerY`) |
| **2D-4** | **1D Principal Major-Axis Variance Conservation** | $\tilde{\sigma}_1^2 + \delta_1^2 = \left(\frac{\sigma_1}{2}\right)^2 + \left(\frac{\sqrt{3}}{2}\sigma_1\right)^2 = \sigma_1^2$ | `h.2.2.2.1` (`c_plus.sigma1 ^ 2 + splat.splitMajorOffset ^ 2 = splat.sigma1 ^ 2`) |
| **2D-5** | **Rotated 2D Euclidean Second-Moment Conservation ($\forall \theta \in \mathbb{R}$)** | $(x_+ - x_c)^2 + (y_+ - y_c)^2 + \tilde{\sigma}_1^2 = \sigma_1^2$ | `h.2.2.2.2.1` (`(c_plus.centerX - splat.centerX)^2 + (c_plus.centerY - splat.centerY)^2 + c_plus.sigma1^2 = splat.sigma1^2`) |
| **2D-6** | **Anisotropy Aspect-Ratio Halving** | $\frac{\tilde{\sigma}_1}{\tilde{\sigma}_2} = \frac{1}{2}\,\frac{\sigma_1}{\sigma_2}$ | `h.2.2.2.2.2.1` (`c_plus.sigma1 / c_plus.sigma2 = (1 / 2) * (splat.sigma1 / splat.sigma2)`) |
| **2D-7** | **Covariance Determinant Quartering** | $\det\Sigma_{\mathrm{2D},+} = \frac{1}{4}\det\Sigma_{\mathrm{2D}}$ | `h.2.2.2.2.2.2.1` (`c_plus.covDet = (1 / 4) * splat.covDet`) |
| **2D-8** | **Exact Core Bohm Potential Refinement Increment** | $Q_{\mathrm{core,2D}}(\Sigma_{\mathrm{2D},+}) - Q_{\mathrm{core,2D}}(\Sigma_{\mathrm{2D}}) = \frac{3\hbar^2}{4m\sigma_1^2}$ | `h.2.2.2.2.2.2.2.1` (`c_plus.coreBohmPotential m hbar - splat.coreBohmPotential m hbar = (3 * hbar^2) / (4 * m * splat.sigma1^2)`) |
| **2D-9** | **Strict Core Bohm Repulsive Barrier Amplification** | $Q_{\mathrm{core,2D}}(\Sigma_{\mathrm{2D}}) < Q_{\mathrm{core,2D}}(\Sigma_{\mathrm{2D},+})$ | `h.2.2.2.2.2.2.2.2` (`splat.coreBohmPotential m hbar < c_plus.coreBohmPotential m hbar`) |

---

### 2.2 The 10 Simultaneous 3D Splitting Conservation & Holographic $Gr_{\mathbb{C}}(2,4)$ Affine Projection Laws (`NormedTensorGaussianSplat3D.splitMajor3D_and_holographic_gr24_projection_identities`)

Defined in [../Signals/DDF.lean](../Signals/DDF.lean#L5441-L5656) (Blueprint node `thm:signals-ddf-splat3d-and-holographic-gr24-projection-trick`, comprising 16 formal conjuncts grouped into 10 physical laws) and implemented in Rust in [`NormedTensorGaussianSplat3D::split_if_anisotropic`](../numerical_adapter/src/orbital_splat.rs#L789-L832), [`project_orthographic_2d`](../numerical_adapter/src/orbital_splat.rs#L835-L846), [`project_perspective_2d`](../numerical_adapter/src/orbital_splat.rs#L851-L865), and [`holographic_gr24_depth_invariants`](../numerical_adapter/src/orbital_splat.rs#L877-L887):

| Law # | Physical & Geometric Law | Mathematical Identity | Lean 4 Source & Conjunct(s) in [../Signals/DDF.lean](../Signals/DDF.lean#L5441-L5511) |
|---|---|---|---|
| **Law 1** | **3D $L^1(\mathbb{R}^3)$ Mass/Weight Conservation** | $w_+ + w_- = w$ | `h3d.1` ([line 5480](../Signals/DDF.lean#L5480)) |
| **Law 2** | **3D Center-of-Mass Vector Conservation** | $\frac{x_+ + x_-}{2} = x_c, \quad \frac{y_+ + y_-}{2} = y_c, \quad \frac{z_+ + z_-}{2} = z_c$ | `h3d.2.1`, `h3d.2.2.1`, `h3d.2.2.2.1` ([lines 5481–5483](../Signals/DDF.lean#L5481-L5483)) |
| **Law 3** | **3D Spherical-Harmonic $(\theta, \psi)$ Major-Axis Second-Moment Conservation** | $(x_+ - x_c)^2 + (y_+ - y_c)^2 + (z_+ - z_c)^2 + \tilde{\sigma}_1^2 = \sigma_1^2$ via $\cos^2\psi(\cos^2\theta + \sin^2\theta) + \sin^2\psi = 1$ and $\left(\frac{\sqrt{3}}{2}\right)^2 + \left(\frac{1}{2}\right)^2 = 1$ | `h3d.2.2.2.2.1` ([lines 5484–5487](../Signals/DDF.lean#L5484-L5487)) |
| **Law 4** | **3D Covariance Volume Quartering** | $\det\Sigma_{\mathrm{3D},+} = \tilde{\sigma}_1^2\sigma_2^2\sigma_3^2 = \frac{1}{4}\det\Sigma_{\mathrm{3D}}$ | `h3d.2.2.2.2.2.1` ([line 5488](../Signals/DDF.lean#L5488)) |
| **Law 5** | **Dimension-Independent Core Bohm Refinement Increment & Strict Amplification** | $Q_{\mathrm{core,3D}}(\Sigma_{\mathrm{3D},+}) - Q_{\mathrm{core,3D}}(\Sigma_{\mathrm{3D}}) = \frac{3\hbar^2}{4m\sigma_1^2} > 0$ (identical to the 2D increment because $\sigma_2^{-2} + \sigma_3^{-2}$ cancels!) | `h3d.2.2.2.2.2.2.1` & `h3d.2.2.2.2.2.2.2.1` ([lines 5489–5491](../Signals/DDF.lean#L5489-L5491)) |
| **Law 6** | **Holographic 3D-to-2D Additive Core Bohm Potential Decomposition** | $Q_{\mathrm{core,3D}}(\Sigma_{\mathrm{3D}}) = Q_{\mathrm{core,2D}}(\Sigma_{\mathrm{2D}}^{\mathrm{ortho}}) + \operatorname{continuumBohmPotentialMode}\!\left(m, \hbar, \frac{1}{\sqrt{2}\sigma_3}\right)$ | `h3d.2.2.2.2.2.2.2.2.1` ([lines 5492–5494](../Signals/DDF.lean#L5492-L5494)) |
| **Law 7** | **Perspective / Poincaré AdS Bulk-to-Boundary Covariance & Bohm RG Scaling** | $\det\Sigma_{\mathrm{2D}}^{\mathrm{persp}} = \left(\frac{f}{z_c}\right)^4 \frac{\det\Sigma_{\mathrm{3D}}}{\sigma_3^2}, \qquad Q_{\mathrm{core,2D}}(\Sigma_{\mathrm{2D}}^{\mathrm{persp}}) = \left(\frac{z_c}{f}\right)^2 Q_{\mathrm{core,2D}}(\Sigma_{\mathrm{2D}}^{\mathrm{ortho}})$ | `h3d.2.2.2.2.2.2.2.2.2.1` & `h3d.2.2.2.2.2.2.2.2.2.2.1` ([lines 5495–5497](../Signals/DDF.lean#L5495-L5497)) |
| **Law 8** | **Strict Depth-Invariance of Projective $Gr_{\mathbb{C}}(2,4)$ Lateral Anisotropy** | $\frac{\sigma_{1,\mathrm{persp}}^2 - \sigma_{2,\mathrm{persp}}^2}{\sigma_{1,\mathrm{persp}}^2 + \sigma_{2,\mathrm{persp}}^2} = \frac{\sigma_1^2 - \sigma_2^2}{\sigma_1^2 + \sigma_2^2}$ (independent of bulk depth $z_c$ and focal scale $f$) | `h3d.2.2.2.2.2.2.2.2.2.2.2.1` ([lines 5498–5501](../Signals/DDF.lean#L5498-L5501)) |
| **Law 9** | **Exact Commutativity of In-Plane ($\psi = 0$) 3D Splitting and 2D Projection** | $\psi = 0 \implies (\text{splat}.\mathrm{splitMajorPlus}).\mathrm{projectOrthographic2D} = (\text{splat}.\mathrm{projectOrthographic2D}).\mathrm{splitMajorPlus}$ | `h3d.2.2.2.2.2.2.2.2.2.2.2.2.1` ([lines 5502–5503](../Signals/DDF.lean#L5502-L5503)) |
| **Law 10** | **Holographic $Gr_{\mathbb{C}}(2,4)$ Plücker Channel Recovery of the 3rd Principal Variance $\sigma_3^2$** | $\delta_{\mathrm{depth}} = \frac{(\sigma_1^2 + \sigma_2^2) - \sigma_3^2}{(\sigma_1^2 + \sigma_2^2) + \sigma_3^2} \in (-1, 1) \quad\text{and}\quad \frac{|w_A^{\mathbb{C}}(M_{\mathrm{depth}})|^2}{|w_B^{\mathbb{C}}(M_{\mathrm{depth}})|^2} = \frac{\sigma_1^2 + \sigma_2^2}{\sigma_3^2}$ | `h3d.2.2.2.2.2.2.2.2.2.2.2.2.2.1`, `.2.1`, & `.2.2` ([lines 5504–5509](../Signals/DDF.lean#L5504-L5509)) |

---

### 2.3 The 11 Simultaneous Inversion-Free Schur–Plücker & Momentum-Twistor Shear Laws (`schur_plucker_inversion_free_and_twistor_vane_identities`)

Defined in [../Signals/DDF.lean](../Signals/DDF.lean#L5744-L5860) (Blueprint node `thm:signals-ddf-schur-plucker-inversion-free-identities`) and implemented in Rust in [`schur_plucker_inversion_free_volume`](../numerical_adapter/src/orbital_splat.rs#L896-L914), resolving Prompts 16–18 of [LBGPC-Fluid-Datacenter-Energy-Savings.myst.md](../../../docs/chats/LBGPC-Fluid-Datacenter-Energy-Savings.myst.md#L2218-L2462):

| # | Identity / Law | Mathematical Formula | Lean 4 Source & Conjunct in [../Signals/DDF.lean](../Signals/DDF.lean#L5744-L5768) |
|---|---|---|---|
| **SP-1** | **Impeller $4 \times 4$ Shear Jacobian Determinant** | $\det J(s, \tau) = 1 - \tau^2$ (invariant under in-plane laminar shear $s$) | `h_schur.1` |
| **SP-2** | **Sheared $4 \times 4$ Covariance Determinant** | $\det\Sigma_{4\times 4} = \det(J(s,\tau)J(s,\tau)^T) = (1 - \tau^2)^2$ | `h_schur.2.1` |
| **SP-3** | **Normal $(3,3)$ Covariance Pivot Positivity** | $(\Sigma_{4\times 4})_{3,3} = 1 + \tau^2 > 0$ | `h_schur.2.2.1` |
| **SP-4** | **Inversion-Free Schur Determinant Factorization** | $\det\Sigma_{4\times 4} = (\Sigma_{4\times 4})_{3,3} \cdot \operatorname{schurComplement3DVolume}(\tau)$ | `h_schur.2.2.2.1` |
| **SP-5** | **Critique of Chat's `AmplituhedronFluidSplat` Matrix** | $\det(\operatorname{chatAmplituhedronTwistorMatrix}(s, \tau)) = 1 + s\tau$ | `h_schur.2.2.2.2.1` |
| **SP-6** | **Proof of Inverted Stall Ordering in Chat's Raw Matrix** | $s > 0, \tau > 0 \implies \det Z_{\mathrm{chat}}(s, 0) = 1 < 1 + s\tau = \det Z_{\mathrm{chat}}(s, \tau)$ | `h_schur.2.2.2.2.2.1` |
| **SP-7** | **Corrected Momentum-Twistor Shear 4-Bracket** | $\det(\operatorname{correctedTwistorShearMatrix}(s, \tau)) = 1 - \tau^2$ | `h_schur.2.2.2.2.2.2.1` |
| **SP-8** | **$Gr_{\mathbb{C}}(2,4)$ Uncrossed Plücker Product Identity** | $|w_A^{\mathbb{C}}(M_\tau)|^2\,|w_B^{\mathbb{C}}(M_\tau)|^2 = (1+\tau)(1-\tau) = 1 - \tau^2$ | `h_schur.2.2.2.2.2.2.2.1` |
| **SP-9** | **Inversion-Free Plücker Representation of 3D Schur Volume** | $\operatorname{schurComplement3DVolume}(\tau) = \frac{\bigl(|w_A^{\mathbb{C}}(M_\tau)|^2\,|w_B^{\mathbb{C}}(M_\tau)|^2\bigr)^2}{1 + \tau^2}$ | `h_schur.2.2.2.2.2.2.2.2.1` |
| **SP-10** | **Laminar Vortical Vane ($\tau = 0$) Unit Volume Preservation** | $\operatorname{schurComplement3DVolume}(0) = 1$ | `h_schur.2.2.2.2.2.2.2.2.2.1` |
| **SP-11** | **Strict Turbulent Stall Volume Contraction ($0 < \tau < 1$)** | $\operatorname{schurComplement3DVolume}(\tau) < \operatorname{schurComplement3DVolume}(0) = 1$ | `h_schur.2.2.2.2.2.2.2.2.2.2` |

---

### 2.4 The 11 Simultaneous Holographic $Gr_{\mathbb{C}}(2,4)$ Imaging Depth-Recovery & Convergent-Beam Laws (`holographic_gr24_imaging_depth_recovery_and_convergent_beam_identities`)

Defined in [../Signals/DDF.lean](../Signals/DDF.lean#L5938-L6065) (Blueprint node `thm:signals-ddf-holographic-gr24-imaging-depth-recovery`) and analyzed in detail in our companion imaging paper [grassmannian-holographic-imaging-depth-recovery-paper.md](grassmannian-holographic-imaging-depth-recovery-paper.md):

| # | Imaging & Convergent-Beam Law | Mathematical Formula | Lean 4 Conjunct in [../Signals/DDF.lean](../Signals/DDF.lean#L5951-L5972) |
|---|---|---|---|
| **IM-1** | **Exact Inversion of Unseen 3rd Principal Variance $\sigma_3^2$** | $\operatorname{recoverDepthVarianceSq}(\operatorname{Tr}\Sigma_{\mathrm{2D}}^{\mathrm{ortho}}, R_{\mathrm{depth}}) = \frac{\sigma_1^2 + \sigma_2^2}{R_{\mathrm{depth}}} = \sigma_3^2$ | `h_img.1` |
| **IM-2** | **Full 3D Covariance Trace Recovery from 2D Screen Data** | $\operatorname{Tr}\Sigma_{\mathrm{2D}}^{\mathrm{ortho}} + \sigma_{3,\mathrm{rec}}^2 = \operatorname{Tr}\Sigma_{\mathrm{3D}}$ | `h_img.2.1` |
| **IM-3** | **Full 3D Covariance Determinant Recovery from 2D Screen Data** | $\det\Sigma_{\mathrm{2D}}^{\mathrm{ortho}} \cdot \sigma_{3,\mathrm{rec}}^2 = \det\Sigma_{\mathrm{3D}}$ | `h_img.2.2.1` |
| **IM-4** | **Full 3D Core Bohm Quantum Potential Recovery from 2D Screen Data** | $Q_{\mathrm{core,2D}}(\Sigma_{\mathrm{2D}}^{\mathrm{ortho}}) + \frac{\hbar^2}{4m}\frac{R_{\mathrm{depth}}}{\operatorname{Tr}\Sigma_{\mathrm{2D}}^{\mathrm{ortho}}} = Q_{\mathrm{core,3D}}(\Sigma_{\mathrm{3D}})$ | `h_img.2.2.2.1` |
| **IM-5** | **Tomographic Focal Depth $z_c^2$ Recovery from 2D Screen Traces** | $f^2\,\frac{\operatorname{Tr}\Sigma_{\mathrm{2D}}^{\mathrm{ortho}}}{\operatorname{Tr}\Sigma_{\mathrm{2D}}^{\mathrm{persp}}} = z_c^2$ | `h_img.2.2.2.2.1` |
| **IM-6** | **Tomographic Focal Depth $z_c^2$ Recovery from 2D Bohm Potentials** | $f^2\,\frac{Q_{\mathrm{core,2D}}(\Sigma_{\mathrm{2D}}^{\mathrm{persp}})}{Q_{\mathrm{core,2D}}(\Sigma_{\mathrm{2D}}^{\mathrm{ortho}})} = z_c^2$ | `h_img.2.2.2.2.2.1` |
| **IM-7** | **Two-Beam Collinear vs. Single-Beam Axial Precision** | $\frac{1}{\sigma_\parallel^2} < \frac{2}{\sigma_\parallel^2}$ | `h_img.2.2.2.2.2.2.1` |
| **IM-8** | **Crossed Orthogonal Convergent-Beam Confocal Axial Precision Boost** | $\frac{2}{\sigma_\parallel^2} < \frac{1}{\sigma_\parallel^2} + \frac{1}{\sigma_\perp^2} = \operatorname{convergentCrossedAxialPrecision}(\sigma_\perp, \sigma_\parallel)$ ($\sigma_\perp < \sigma_\parallel$) | `h_img.2.2.2.2.2.2.2.1` |
| **IM-9** | **Synchronous $N$-Beam Coherent vs. Incoherent Focal Intensity Factor** | $(N_{\mathrm{beam}} A_0)^2 = N_{\mathrm{beam}}\cdot(N_{\mathrm{beam}} A_0^2)$ | `h_img.2.2.2.2.2.2.2.2.1` |
| **IM-10** | **Strict Coherent Multi-Beam Focal Gain ($N_{\mathrm{beam}} > 1$)** | $N_{\mathrm{beam}} A_0^2 < (N_{\mathrm{beam}} A_0)^2$ | `h_img.2.2.2.2.2.2.2.2.2.1` |
| **IM-11** | **Self-Calibrating Pilot-Tone Phase-Conjugation Exact Restoration** | $\operatorname{ddfThermalGr24Matrix}(\delta_d, \theta_z + \phi_{\mathrm{err}} - \phi_{\mathrm{err}}) = M_{\mathrm{depth}}$ | `h_img.2.2.2.2.2.2.2.2.2.2` |

---

## 3. LeanArchitect (`@[blueprint]`) Node Index & Machine-Checked Lean 4 Proofs

### 3.1 LeanArchitect Blueprint Node Registry (`Signals.DDF`)

Every definition and theorem in the 2D and 3D Tensor Gaussian Splat hierarchy is annotated with LeanArchitect's `@[blueprint "..."]` attribute in [../Signals/DDF.lean](../Signals/DDF.lean) and indexed by `\inputleanmodule{Signals.DDF}` in [../blueprint/src/content.tex](../blueprint/src/content.tex#L247):

| Blueprint Node Label | Lean 4 Declaration | Title / Summary |
|---|---|---|
| `def:signals-ddf-normed-tensor-gaussian-splat2d` | `NormedTensorGaussianSplat2D` | Normed 2D anisotropic Tensor Gaussian Splat primitive |
| `def:signals-ddf-splat2d-cov-det` | `NormedTensorGaussianSplat2D.covDet` | 2D covariance determinant $\det\Sigma = \sigma_1^2\sigma_2^2$ |
| `def:signals-ddf-splat2d-cov-trace` | `NormedTensorGaussianSplat2D.covTrace` | 2D covariance trace $\operatorname{Tr}\Sigma = \sigma_1^2 + \sigma_2^2$ |
| `def:signals-ddf-splat2d-norm-factor` | `NormedTensorGaussianSplat2D.normFactor` | 2D $L^1(\mathbb{R}^2)$ normalization factor $1/(2\pi\sigma_1\sigma_2)$ |
| `def:signals-ddf-splat2d-mahalanobis` | `NormedTensorGaussianSplat2D.mahalanobisSq` | Rotated 2D Mahalanobis quadratic form $Q_\Sigma(x,y)$ |
| `def:signals-ddf-splat2d-eval` | `NormedTensorGaussianSplat2D.eval` | Pointwise evaluation $G_{\mathrm{2D}}(x,y)$ |
| `thm:signals-ddf-splat2d-properties` | `NormedTensorGaussianSplat2D.eval_properties` | Positivity, center peak value, and global upper bound |
| `def:signals-ddf-sheath-tensor-splat` | `MovingSheath.ddfTensorSplat` | DDF moving-sheath splat ($\sigma_1 = \sigma_0/\gamma_\varphi(v)$) |
| `thm:signals-ddf-sheath-tensor-splat-identities` | `MovingSheath.ddfTensorSplat_identities` | $\det\Sigma_{\mathrm{DDF}} = \sigma_0^4\gamma_\varphi^{-2}$ and $\mathcal{N}_{\mathrm{DDF}} = \gamma_\varphi/(2\pi\sigma_0^2)$ |
| `def:signals-ddf-planetary-gr24-tensor-splat` | `PlanetaryOrbit.gr24TensorSplat` | Planetary $Gr_{\mathbb{C}}(2,4)$ orbital splat ($\sigma_{1,2} = \sigma_0\sqrt{1\pm e}$) |
| `thm:signals-ddf-planetary-gr24-tensor-splat-identities` | `PlanetaryOrbit.gr24TensorSplat_identities` | $\operatorname{Tr}\Sigma = 2\sigma_0^2$, $\det\Sigma = \sigma_0^4(1-e^2) = \sigma_0^4(p/a)$ |
| `def:signals-ddf-splat2d-complex-twistor-wavepacket` | `NormedTensorGaussianSplat2D.complexTwistorWavepacket` | $\Psi_{\mathrm{splat}} = \sqrt{G}\,\Delta_{02}^{\mathbb{C}}\Delta_{13}^{\mathbb{C}}$ |
| `def:signals-ddf-splat2d-complex-twistor-intensity` | `NormedTensorGaussianSplat2D.complexTwistorIntensity` | $I_{\mathrm{splat}} = G\,\lvert\Delta_{02}^{\mathbb{C}}\Delta_{13}^{\mathbb{C}}\rvert^2$ |
| `thm:signals-ddf-splat2d-complex-twistor-representation` | `NormedTensorGaussianSplat2D.complexTwistor_representation_identities` | Dual-layer $Gr_{\mathbb{C}}(2,4)$ crossing & dark-fringe null |
| `def:signals-ddf-splat2d-core-bohm-potential` | `NormedTensorGaussianSplat2D.coreBohmPotential` | 2D core Bohm potential $\frac{\hbar^2}{4m}(\sigma_1^{-2}+\sigma_2^{-2})$ |
| `thm:signals-ddf-splat2d-core-bohm-identities` | `NormedTensorGaussianSplat2D.coreBohmPotential_identities` | $Q_{\mathrm{core}} = \frac{\hbar^2\operatorname{Tr}\Sigma}{4m\det\Sigma}$ and $\gamma_\varphi^2+1$ scaling |
| `thm:signals-ddf-splat2d-quantum-pressure-identities` | `NormedTensorGaussianSplat2D.quantumPressureTensor_identities` | Madelung quantum pressure tensor $\Pi_{ij}$ and $\Pi_{11}^{\mathrm{DDF}} = \gamma_\varphi^2\Pi_{22}^{\mathrm{DDF}}$ |
| `def:signals-ddf-splat2d-evolve-thermal` | `NormedTensorGaussianSplat2D.evolveThermal` | $L^1$-conserving anisotropic thermal variance evolution |
| `thm:signals-ddf-splat2d-thermal-semigroup-and-bohm-decay` | `NormedTensorGaussianSplat2D.evolveThermal_semigroup_and_bohm_decay` | Chapman–Kolmogorov semigroup, Bohm relaxation, & Second Law |
| `def:signals-ddf-spp-hotspot-tensor-splat` | `sppHotspotTensorSplat` | Sub-wavelength SPP hotspot tensor splat |
| `def:signals-ddf-holographic-planck-splat` | `holographicPlanckSplat` | Horizon Planck-cell tensor splat ($\sigma_1=\sigma_2=\ell_P$) |
| `def:signals-ddf-opa-squeezed-tensor-splat` | `opaSqueezedTensorSplat` | Symplectic $\chi^{(2)}$ SHG-OPA squeezed tensor splat |
| `def:signals-ddf-ads-holographic-rg-splat` | `adsHolographicRGSplat` | AdS/CFT holographic RG scale-radius dilated splat |
| `thm:signals-ddf-splat2d-split-major-conservation` | `NormedTensorGaussianSplat2D.splitMajor_conservation_identities` | 9 simultaneous 2D two-child splitting conservation laws |
| `def:signals-ddf-normed-tensor-gaussian-splat3d` | `NormedTensorGaussianSplat3D` | Normed 3D anisotropic Tensor Gaussian Splat primitive |
| `def:signals-ddf-splat3d-project-orthographic2d` | `NormedTensorGaussianSplat3D.projectOrthographic2D` | Orthographic 3D-to-2D marginal projection |
| `def:signals-ddf-splat3d-project-perspective2d` | `NormedTensorGaussianSplat3D.projectPerspective2D` | EWA / Poincaré perspective 3D-to-2D projection ($s = f/z_c$) |
| `def:signals-ddf-splat3d-holographic-depth-anisotropy` | `NormedTensorGaussianSplat3D.holographicDepthAnisotropy` | Depth anisotropy $\delta_{\mathrm{depth}} = \frac{\sigma_1^2+\sigma_2^2-\sigma_3^2}{\sigma_1^2+\sigma_2^2+\sigma_3^2}$ |
| `thm:signals-ddf-splat3d-and-holographic-gr24-projection-trick` | `NormedTensorGaussianSplat3D.splitMajor3D_and_holographic_gr24_projection_identities` | 10 simultaneous 3D splitting & holographic $Gr_{\mathbb{C}}(2,4)$ projection laws |
| `thm:signals-ddf-schur-plucker-inversion-free-identities` | `schur_plucker_inversion_free_and_twistor_vane_identities` | Inversion-free Schur–Plücker volume & twistor shear theorem |
| `thm:signals-ddf-holographic-gr24-imaging-depth-recovery` | `NormedTensorGaussianSplat3D.holographic_gr24_imaging_depth_recovery_and_convergent_beam_identities` | Holographic $Gr_{\mathbb{C}}(2,4)$ depth recovery & convergent-beam theorem |

### 3.2 Self-Contained Machine-Checked Lean 4 Verification Block

The following Lean 4 block is verified directly against `Signals` and `SignalsPending`:

```lean
import Signals
import SignalsPending

namespace NormedTensorGaussianSplatPaperVerification

open Signals.Geometry
open Signals.DDF

-- 1. 2D Adaptive Splat Splitting Conservation (All 9 Simultaneous Laws)
example (splat2d : NormedTensorGaussianSplat2D) :
    let c_plus := splat2d.splitMajorPlus
    let c_minus := splat2d.splitMajorMinus
    c_plus.weight + c_minus.weight = splat2d.weight ∧
    (c_plus.centerX + c_minus.centerX) / 2 = splat2d.centerX ∧
    (c_plus.centerY + c_minus.centerY) / 2 = splat2d.centerY ∧
    c_plus.sigma1 ^ 2 + splat2d.splitMajorOffset ^ 2 = splat2d.sigma1 ^ 2 ∧
    (c_plus.centerX - splat2d.centerX) ^ 2 +
        (c_plus.centerY - splat2d.centerY) ^ 2 + c_plus.sigma1 ^ 2 =
      splat2d.sigma1 ^ 2 ∧
    c_plus.sigma1 / c_plus.sigma2 = (1 / 2) * (splat2d.sigma1 / splat2d.sigma2) ∧
    c_plus.covDet = (1 / 4) * splat2d.covDet ∧
    c_plus.coreBohmPotential 1 1 - splat2d.coreBohmPotential 1 1 =
      (3 * 1 ^ 2) / (4 * 1 * splat2d.sigma1 ^ 2) ∧
    splat2d.coreBohmPotential 1 1 < c_plus.coreBohmPotential 1 1 := by
  exact splat2d.splitMajor_conservation_identities 1 1 (by norm_num) (by norm_num)

-- 2. 3D Adaptive Splat Splitting & Holographic Gr_C(2,4) Affine Projection (All 16 Conjuncts)
example (splat3d : NormedTensorGaussianSplat3D) (hz : 0 < splat3d.centerZ) (θ_z : ℝ) :
    let c_plus := splat3d.splitMajorPlus
    let c_minus := splat3d.splitMajorMinus
    let s_ortho := splat3d.projectOrthographic2D
    let s_persp := splat3d.projectPerspective2D 2 (by norm_num) hz
    let δ_d := splat3d.holographicDepthAnisotropy
    let M_depth := ddfThermalGr24Matrix δ_d θ_z
    c_plus.weight + c_minus.weight = splat3d.weight ∧
    (c_plus.centerX + c_minus.centerX) / 2 = splat3d.centerX ∧
    (c_plus.centerY + c_minus.centerY) / 2 = splat3d.centerY ∧
    (c_plus.centerZ + c_minus.centerZ) / 2 = splat3d.centerZ ∧
    (c_plus.centerX - splat3d.centerX) ^ 2 +
        (c_plus.centerY - splat3d.centerY) ^ 2 +
        (c_plus.centerZ - splat3d.centerZ) ^ 2 + c_plus.sigma1 ^ 2 =
      splat3d.sigma1 ^ 2 ∧
    c_plus.covDet = (1 / 4) * splat3d.covDet ∧
    c_plus.coreBohmPotential 1 1 - splat3d.coreBohmPotential 1 1 =
      (3 * 1 ^ 2) / (4 * 1 * splat3d.sigma1 ^ 2) ∧
    splat3d.coreBohmPotential 1 1 < c_plus.coreBohmPotential 1 1 ∧
    splat3d.coreBohmPotential 1 1 =
      s_ortho.coreBohmPotential 1 1 +
        continuumBohmPotentialMode 1 1 (1 / (Real.sqrt 2 * splat3d.sigma3)) ∧
    s_persp.covDet = (2 / splat3d.centerZ) ^ 4 * (splat3d.covDet / splat3d.sigma3 ^ 2) ∧
    s_persp.coreBohmPotential 1 1 =
      (splat3d.centerZ / 2) ^ 2 * s_ortho.coreBohmPotential 1 1 ∧
    (s_persp.sigma1 ^ 2 - s_persp.sigma2 ^ 2) /
        (s_persp.sigma1 ^ 2 + s_persp.sigma2 ^ 2) =
      (splat3d.sigma1 ^ 2 - splat3d.sigma2 ^ 2) /
        (splat3d.sigma1 ^ 2 + splat3d.sigma2 ^ 2) ∧
    (splat3d.pitchAngle = 0 → c_plus.projectOrthographic2D = s_ortho.splitMajorPlus) ∧
    -1 < δ_d ∧
    δ_d < 1 ∧
    Complex.normSq (complexPluckerSinkAmplitudeA M_depth) /
        Complex.normSq (complexPluckerSinkAmplitudeB M_depth) =
      (splat3d.sigma1 ^ 2 + splat3d.sigma2 ^ 2) / splat3d.sigma3 ^ 2 := by
  exact splat3d.splitMajor3D_and_holographic_gr24_projection_identities
    2 1 1 θ_z (by norm_num) hz (by norm_num) (by norm_num)

-- 3. Inversion-Free Schur-Plücker Determinant Identity vs. 4×4 Jacobians
example (θ : ℝ) :
    let J := impellerShear4x4 2 (3 / 5)
    let Sigma4 := J * J.transpose
    let M_τ := ddfThermalGr24Matrix (3 / 5) θ
    J.det = 1 - (3 / 5 : ℝ) ^ 2 ∧
    Sigma4.det = Sigma4 3 3 * schurComplement3DVolume (3 / 5) ∧
    (chatAmplituhedronTwistorMatrix 2 0).det <
      (chatAmplituhedronTwistorMatrix 2 (3 / 5)).det ∧
    (correctedTwistorShearMatrix 2 (3 / 5)).det = 1 - (3 / 5 : ℝ) ^ 2 ∧
    schurComplement3DVolume (3 / 5) =
      (Complex.normSq (complexPluckerSinkAmplitudeA M_τ) *
        Complex.normSq (complexPluckerSinkAmplitudeB M_τ)) ^ 2 / (1 + (3 / 5 : ℝ) ^ 2) ∧
    schurComplement3DVolume (3 / 5) < schurComplement3DVolume 0 := by
  intro J Sigma4 M_τ
  have h := schur_plucker_inversion_free_and_twistor_vane_identities
    2 (3 / 5) θ (by norm_num) (by norm_num) (by norm_num)
  exact ⟨h.1, h.2.2.2.1, h.2.2.2.2.2.1, h.2.2.2.2.2.2.1,
    h.2.2.2.2.2.2.2.2.1, h.2.2.2.2.2.2.2.2.2.2⟩

end NormedTensorGaussianSplatPaperVerification
```

---

## 4. Appendices: Multi-Domain Applications Across the `grassmannian-*-paper.md` Series

### Appendix A: Coherent Wave Optics, Multi-Slit Interferometry, & OAM Vortex Beams
- **Companion Paper**: [grassmannian-huygens-double-slit-oam-paper.md](../../../docs/grassmannian-huygens-double-slit-oam-paper.md)
- **Lean 4 & Rust Sources**: [`Signals.Huygens`](../Signals/Huygens.lean), [`NormedTensorGaussianSplat2D.complexTwistor_representation_identities`](../Signals/DDF.lean#L2771-L2835), [`double_slit.rs`](../numerical_adapter/src/double_slit.rs)
- **Application Summary**: Pairing the 2D covariance tensor $\Sigma_{\mathrm{2D}}$ ($\det\Sigma_{\mathrm{2D}} = \sigma_0^4(1 - d_{\mathrm{bary}}^2) = \sigma_0^4\mathcal{V}^2$) with the complex Plücker crossing amplitude $\Psi_{\mathrm{splat}} = \sqrt{G_{\mathrm{2D}}}\,\Delta_{02}^{\mathbb{C}}\Delta_{13}^{\mathbb{C}}$ eliminates the $50\%$ on-axis relative error of unphased $Gr_{\ge 0}(2,4)$ density sums and reproduces exact Fraunhofer and OAM Laguerre–Gaussian fringe visibility across $N$-slit apertures.

### Appendix B: Quantum Inverse Scattering Method (QISM), Bethe Ansatz, & Soliton Bus
- **Companion Paper**: [grassmannian-qism-bethe-ansatz-paper.md](../../../docs/grassmannian-qism-bethe-ansatz-paper.md)
- **Lean 4 Sources**: [`Signals.QISM`](../Signals/QISM.lean), [`Signals.SolitonBus`](../Signals/SolitonBus.lean)
- **Application Summary**: $GL(2)$ gauge transformations $M \mapsto B M$ on $Gr_{\mathbb{C}}(2,4)$ act on Gaussian wavepackets as symplectic covariance updates $\Sigma \mapsto B\Sigma B^T$, while non-singular covariance determinants ($\det\Sigma > 0$) provide the continuum phase-space counterpart to Mukhin–Tarasov–Varchenko Casorati Wronskian nondegeneracy.

### Appendix C: Dilatant Dark Fluid (DDF) Moving Sheaths, Anosov Flows, & Datacenter Impeller CFD
- **Companion Papers**: [grassmannian-ddf-moving-sheath-paper.md](../../../docs/grassmannian-ddf-moving-sheath-paper.md), [grassmannian-splat-mechanics-paper.md](../../../docs/grassmannian-splat-mechanics-paper.md)
- **Chat Provenance**: [LBGPC-Fluid-Datacenter-Energy-Savings.myst.md, lines 2218–2462](../../../docs/chats/LBGPC-Fluid-Datacenter-Energy-Savings.myst.md#L2218-L2462); [Grassmannian Splat Mechanics and Vortex Space Emergence.md, lines 658–691](../../../data/chats/Grassmannian%20Splat%20Mechanics%20and%20Vortex%20Space%20Emergence.md#L658-L691)
- **Lean 4 & Rust Sources**: [`MovingSheath.ddfTensorSplat`](../Signals/DDF.lean#L2592), [`schur_plucker_inversion_free_and_twistor_vane_identities`](../Signals/DDF.lean#L5744), [`orbital_splat.rs`](../numerical_adapter/src/orbital_splat.rs#L896)
- **Application Summary**: Under Lorentz jamming $\gamma_\varphi(v) = (1 - v^2/c^2)^{-1/2}$, longitudinal splat contraction $\sigma_1 = \sigma_0/\gamma_\varphi(v)$ amplifies the repulsive core Bohm potential by $\gamma_\varphi(v)^2 + 1$ and the longitudinal Madelung quantum stress by $\Pi_{11}^{\mathrm{DDF}}/\Pi_{22}^{\mathrm{DDF}} = \gamma_\varphi(v)^2$. When Anosov stretching elongates a splat past `max_aspect_ratio`, 2D/3D `split_if_anisotropic` remeshes it while conserving mass, center of mass, and second-moment variance. For 4D-to-3D impeller shear projections, `schurComplement3DVolume` replaces $4\times 4$ matrix multiplications and `pinv(D)` with the $O(1)$ Plücker channel product $(1-\tau^2)^2/(1+\tau^2)$.

### Appendix D: Relativistic Planetary Orbits, BCJ Double Copy, & $N$-Body Sink Gravity
- **Companion Paper**: [grassmannian-gravity-from-qed-scattering-paper.md](../../../docs/grassmannian-gravity-from-qed-scattering-paper.md)
- **Lean 4 & Rust Sources**: [`PlanetaryOrbit.gr24TensorSplat`](../Signals/DDF.lean#L2661), [`OrbitalSplatScene`](../numerical_adapter/src/orbital_splat.rs#L676), [`orbital_splat.frag.glsl`](../numerical_adapter/src/shaders/orbital_splat.frag.glsl)
- **Application Summary**: Encoding orbital eccentricity $e \in [0, 1)$ into $\sigma_{1,2} = \sigma_0\sqrt{1\pm e}$ yields $\operatorname{Tr}\Sigma = 2\sigma_0^2$ and $\det\Sigma = \sigma_0^4(1-e^2) = \sigma_0^4(p/a)$, while rotating $\theta = \varpi(t)$ tracks relativistic perihelion precession ($42.98''/\text{cy}$ for Mercury) in real-time WebGL2 shaders.

### Appendix E: Inverse Compton, Raman Scattering, & Cattaneo–Vernotte Second-Sound Heat Splatting
- **Companion Paper**: [grassmannian-thermal-compton-raman-paper.md](../../../docs/grassmannian-thermal-compton-raman-paper.md)
- **Lean 4 & Rust Sources**: [`NormedTensorGaussianSplat2D.evolveThermal`](../Signals/DDF.lean#L3499), [`evolveThermal_semigroup_and_bohm_decay`](../Signals/DDF.lean#L3740), [`thermal_inelastic.rs`](../numerical_adapter/src/thermal_inelastic.rs)
- **Application Summary**: Anisotropic thermal diffusion $\sigma_i^2(t+\Delta t) = \sigma_i^2(t) + 2\alpha_i\Delta t$ with DDF longitudinal diffusivity $\alpha_\parallel^{\mathrm{DDF}} = \alpha_0\gamma_\varphi(v)^{-2}$ obeys an exact Chapman–Kolmogorov semigroup law, monotonically relaxes the core Bohm potential, and strictly increases $\det\Sigma(t)$ (Second Law of Thermodynamics) while respecting the subluminal second-sound bound $c_{\mathrm{th}}^{\mathrm{DDF}} \le c$.

### Appendix F: Polaritons, Surface Plasmon Polaritons (SPPs), & $\chi^{(2)}$ SHG-OPA Squeezed Splats
- **Companion Paper**: [grassmannian-polariton-spp-mechanics-paper.md](../../../docs/grassmannian-polariton-spp-mechanics-paper.md)
- **Lean 4 & Rust Sources**: [`sppHotspotTensorSplat`](../Signals/DDF.lean#L4136), [`opaSqueezedTensorSplat`](../Signals/DDF.lean#L4668), [`polariton_spp.rs`](../numerical_adapter/src/polariton_spp.rs)
- **Application Summary**: Sub-wavelength SPP confinement compresses the splat covariance determinant by $n_{\mathrm{SPP}}^{-4}\kappa_{\mathrm{ratio}}^{-2}$ and boosts the Bohm quantum potential to $\frac{\hbar^2 n_{\mathrm{SPP}}^2(1+\kappa_{\mathrm{ratio}}^2)}{4m\lambda_0^2}$, while $\chi^{(2)}$ resonant OPA squeezing ($\sigma_1 = \sigma_0 e^{r_{\mathrm{sq}}}$, $\sigma_2 = \sigma_0 e^{-r_{\mathrm{sq}}}$) preserves $\det\Sigma_{\mathrm{OPA}} = \sigma_0^4$ and amplifies $\Pi_{22}^{\mathrm{OPA}}/\Pi_{11}^{\mathrm{OPA}} = e^{4r_{\mathrm{sq}}}$.

### Appendix G: Horizon Holography, Planck UV Bohm Cutoff, & AdS/CFT Holographic RG Flow
- **Companion Papers**: [grassmannian-holographic-principle-paper.md](../../../docs/grassmannian-holographic-principle-paper.md), [grassmannian-ads-cft-ddf-paper.md](../../../docs/grassmannian-ads-cft-ddf-paper.md)
- **Lean 4 Sources**: [`holographicPlanckSplat`](../Signals/DDF.lean#L4476), [`adsHolographicRGSplat`](../Signals/DDF.lean#L4862)
- **Application Summary**: Tiling an acoustic or gravitational horizon of area $A_H = 4\pi r_H^2$ with Planck-scale tensor splats ($\sigma_1 = \sigma_2 = \ell_P$) enforces a finite UV Bohm potential cutoff $Q_{\mathrm{core}}(\Sigma_{\mathrm{Planck}}) = \frac{\hbar^2}{2m\ell_P^2}$, while bulk-to-boundary Poincaré RG dilation $z \mapsto \lambda_{\mathrm{rg}} z$ scales $\det\Sigma_{\mathrm{IR}} = \lambda_{\mathrm{rg}}^4\det\Sigma_{\mathrm{UV}}$ and $Q_{\mathrm{core}}^{\mathrm{IR}} = \lambda_{\mathrm{rg}}^{-2}Q_{\mathrm{core}}^{\mathrm{UV}}$.

### Appendix H: Holographic $Gr_{\mathbb{C}}(2,4)$ Depth Recovery in Imaging & Convergent Volumetric Holography
- **Companion Paper**: [grassmannian-holographic-imaging-depth-recovery-paper.md](grassmannian-holographic-imaging-depth-recovery-paper.md)
- **Lean 4 Sources**: [`NormedTensorGaussianSplat3D.holographic_gr24_imaging_depth_recovery_and_convergent_beam_identities`](../Signals/DDF.lean#L5938), [`LVPDirectConversionImaging`](../Signals/Pending.lean#L743), [`MultiBeamHolographyResult`](../Signals/Pending.lean#L2509)
- **Application Summary**: Recovers the unseen 3rd principal variance $\sigma_3^2$, 3D trace, 3D determinant, 3D core Bohm potential, and focal depth $z_c^2$ of 3D Gaussian voxels from 2D detector planes and dual-channel $Gr_{\mathbb{C}}(2,4)$ Plücker ratios, and combines crossed convergent beams ($\tau_{z,\mathrm{conv}} = \sigma_\parallel^{-2} + \sigma_\perp^{-2}$) with pilot-tone phase conjugation for aberration-free volumetric synthesis and tomography.

### Appendix I: Atmospheric Species Scavenging & Velocity-Space Tensor Gaussian Splats
- **Lean 4 Sources**: [`TensorGaussianSplat`](../Signals/Pending.lean#L813), [`AtmosphericMixture`](../Signals/Pending.lean#L829), [`AtmosphericScavenging`](../Signals/Pending.lean#L846)
- **Chat Provenance**: [Twistors-and-Positive-Grassmannian-Interference.md, lines 279–620](../../../data/chats/Twistors-and-Positive-Grassmannian-Interference.md#L279-L620)
- **Application Summary**: Represents each gas species ($\text{N}_2, \text{O}_2, \text{Ar}, \text{CO}_2$) in a multi-component intake plume as a 3D velocity-space Gaussian splat with thermal variance $\sigma_{v,s}^2 = k_B T_s / m_s$ and bounded gate-overlap acceptance $a_s \in [0, 1]$, keeping species-resolved mass and momentum conservation explicit before any Pending phase-slip homogenization hypothesis.

---

### Scholarly References

- <a id="kerbl2023"></a> Kerbl, B., Kopanas, G., Leimkühler, T., & Drettakis, G. (2023). 3D Gaussian Splatting for Real-Time Radiance Field Rendering. *ACM Transactions on Graphics (SIGGRAPH 2023)*, 42(4), 139:1–139:14. DOI: `10.1145/3592433`.
- <a id="zwicker2001"></a> Zwicker, M., Pfister, H., van Baar, J., & Gross, M. (2001). EWA Volume Splatting. *Proceedings of IEEE Visualization 2001*, 29–36. DOI: `10.1109/VISUAL.2001.964490`.
- <a id="fedi2026"></a> Fedi, M. (2026). Dilatant Dark Fluid: Quantum-Hydrodynamic Lorentz Jamming and Acoustic Horizon Mechanics. *SSRN Electronic Journal*, SSRN 7406660.
- <a id="splat-chat2026"></a> Provenance Chat Log (2026). *Grassmannian Splat Mechanics and Vortex Space Emergence*. Local corpus: [data/chats/Grassmannian Splat Mechanics and Vortex Space Emergence.md, lines 658–1435](../../../data/chats/Grassmannian%20Splat%20Mechanics%20and%20Vortex%20Space%20Emergence.md#L658-L1435).
- <a id="lbgpc-chat2026"></a> Provenance Chat Log (2026). *LBGPC Fluid Datacenter Energy Savings*. Local corpus: [docs/chats/LBGPC-Fluid-Datacenter-Energy-Savings.myst.md, lines 2218–2518](../../../docs/chats/LBGPC-Fluid-Datacenter-Energy-Savings.myst.md#L2218-L2518).

```bibtex
@article{kerbl2023_3dgs,
  author  = {Kerbl, Bernhard and Kopanas, Georgios and Leimk{\"u}hler, Thomas and Drettakis, George},
  title   = {3D Gaussian Splatting for Real-Time Radiance Field Rendering},
  journal = {ACM Transactions on Graphics},
  volume  = {42},
  number  = {4},
  pages   = {139:1--139:14},
  year    = {2023},
  doi     = {10.1145/3592433}
}

@inproceedings{zwicker2001_ewa,
  author    = {Zwicker, Matthias and Pfister, Hanspeter and van Baar, Jeroen and Gross, Markus},
  title     = {EWA Volume Splatting},
  booktitle = {Proceedings of IEEE Visualization 2001},
  pages     = {29--36},
  year      = {2001},
  doi       = {10.1109/VISUAL.2001.964490}
}

@misc{chat_grassmannian_splat_mechanics_2026,
  author       = {{unknown}},
  title        = {Grassmannian Splat Mechanics and Vortex Space Emergence},
  year         = {2026},
  howpublished = {AI chat log},
  note         = {Source: data/chats/Grassmannian Splat Mechanics and Vortex Space Emergence.md, lines 658-1435}
}

@misc{chat_lbgpc_fluid_datacenter_2026,
  author       = {{unknown}},
  title        = {LBGPC Fluid Datacenter Energy Savings},
  year         = {2026},
  howpublished = {AI chat log},
  note         = {Source: docs/chats/LBGPC-Fluid-Datacenter-Energy-Savings.myst.md, lines 2218-2518}
}
```

```json
{
  "@context": "https://schema.org",
  "@type": "ScholarlyArticle",
  "headline": "Normed 2D and 3D Tensor Gaussian Splats in Lean 4: Simultaneous Conservation Laws, Holographic Gr_C(2,4) Affine Projection, Inversion-Free Schur-Plucker Calculus, and Multi-Domain Applications",
  "author": {
    "@type": "Person",
    "name": "Wes Turner"
  },
  "dateModified": "2026-10-25",
  "isBasedOn": [
    "src/signals/Signals/DDF.lean",
    "src/signals/Signals/Pending.lean",
    "src/signals/numerical_adapter/src/orbital_splat.rs",
    "data/chats/Grassmannian Splat Mechanics and Vortex Space Emergence.md",
    "docs/chats/LBGPC-Fluid-Datacenter-Energy-Savings.myst.md"
  ],
  "about": [
    "Normed Tensor Gaussian Splats",
    "Complex Grassmannian Gr_C(2,4)",
    "Adaptive Splat Splitting Conservation",
    "Holographic Affine Projection",
    "Schur Complement Plucker Identity",
    "Lean 4 Formal Verification"
  ]
}
```
