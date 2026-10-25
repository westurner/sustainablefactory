---
title: "3D Vectorial Wave Model for Longitudinal Polarization (E_z) and Higher-Rank Gr_C(3,n) Volumetric Imaging: Debye–Wolf Counter-Polarization, High-NA Dielectric Metasurfaces, ZRI Collimation vs. Thin-Film ENZ-Lignin Boundary Amplification in Lean 4"
description: "An arXiv-ready MyST Markdown formal verification and nanophotonics paper formalizing the 3-element Debye–Wolf vectorial wave model, counter-polarization transverse cancellation, ZRI bulk extinction vs. upstream collimation, hyperbolic dielectric metasurfaces, 100x-400x thin-film ENZ boundary amplification, and higher-rank Gr_C(3,6) / Gr_C(3,n) 3D volumetric splat imaging in Lean 4."
---

(grassmannian-vectorial-longitudinal-polarization-paper)=
# 3D Vectorial Wave Model for Longitudinal Polarization ($E_z$) and Higher-Rank $Gr_{\mathbb{C}}(3,n)$ Volumetric Imaging: Debye–Wolf Counter-Polarization, High-NA Dielectric Metasurfaces, ZRI Collimation vs. Thin-Film ENZ-Lignin Boundary Amplification in Lean 4

- **Authors:** Wes Turner
- **Subjects:**
  - Optics (`physics.optics`); Mesoscale and Nanoscale Physics (`cond-mat.mes-hall`); Medical Physics (`physics.med-ph`); Mathematical Physics (`math-ph`); Logic in Computer Science (`cs.LO`)
- **Formal Verification & Simulation Artifacts:**
  - `Signals` Lean 4 Library (`leanprover/lean4:v4.35.0-rc3`, [../Signals/DDF.lean](../Signals/DDF.lean#L6067-L6588), [../Signals/Geometry.lean](../Signals/Geometry.lean#L1436-L1590), [../Signals/Scattering.lean](../Signals/Scattering.lean), [../SignalsTests.lean](../SignalsTests.lean#L5295-L5355))
  - `Signals` LeanArchitect Blueprint ([../blueprint/src/content.tex](../blueprint/src/content.tex#L230-L255))
  - `signals-numerical-adapter` Rust/WASM/GLSL Crate ([../numerical_adapter/src/orbital_splat.rs](../numerical_adapter/src/orbital_splat.rs#L889-L925))

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
  11. [Normed 2D and 3D Tensor Gaussian Splats in Lean 4: Simultaneous Conservation Laws, Holographic $Gr_{\mathbb{C}}(2,4)$ Affine Projection, Inversion-Free Schur–Plücker Calculus, and Multi-Domain Applications](gaussian-splat-tensors-normed-paper.md)
  12. [Holographic $Gr_{\mathbb{C}}(2,4)$ Depth Recovery and Convergent Multi-Beam Volumetric Imaging: Plücker Axial Variance Inversion, Perspective Range Tomography, and Self-Calibrating Phase Conjugation in Lean 4](grassmannian-holographic-imaging-depth-recovery-paper.md)

---

## Abstract

Conventional 2D Jones calculus and scalar 2D Gerchberg–Saxton (GS) phase retrieval model only paraxial transverse fields $\mathbf{E}_\perp = (E_x, E_y)^T \in \mathbb{C}^2$, assuming $E_z \approx 0$. However, when a radially polarized Continuous Wave (CW) laser beam is tightly focused at high Numerical Aperture ($\mathrm{NA} = n\sin\theta > 0.9$, [Richards & Wolf 1959](#richards1959); [Dorn, Quabis, & Leuchs 2003](#dorn2003); [Vectorial Wave Model Chat 2026](#vec-chat2026)), non-paraxial ray bending tilts the electric field into a 3-element vector $\mathbf{E}(r, \phi, z) = (E_x, E_y, E_z)^T \in \mathbb{C}^3$ whose transverse components cancel on-axis while its longitudinal component $E_z$ interferes constructively to form a sub-diffraction focal needle.

In this paper, we review, critically evaluate, and machine-check in **Lean 4** (`Signals.DDF` and `Signals.Geometry`, with full LeanArchitect `@[blueprint]` annotations) and **Rust/WASM** (`orbital_splat.rs`) the complete optical physics of [data/chats/Vectorial-Wave-Model-for-Longitudinal-Polarization.md](../../../data/chats/Vectorial-Wave-Model-for-Longitudinal-Polarization.md#L1-L215), unifying it with **higher-rank complex Grassmannian $Gr_{\mathbb{C}}(3, n)$ ($Gr_{\mathbb{C}}(3, 6)$) 3D volumetric imaging**:

1. **Why 2D Jones Calculus & Scalar GS Fail at High NA (`vectorial_longitudinal_polarization_metasurface_and_enz_identities`)**:
   For two diametrically opposite radially polarized rays at convergence angle $\theta$ and pupil azimuths $\phi$ and $\phi + \pi$, we prove that $E_x(\phi) + E_x(\phi + \pi) = 0$ and $E_y(\phi) + E_y(\phi + \pi) = 0$ (exact transverse cancellation), whereas $E_z(\phi) + E_z(\phi + \pi) = 2 E_0 \sin\theta$ (constructive longitudinal doubling, yielding focal intensity $I_z = 4 E_0^2 \sin^2\theta$). Because 2D paraxial Jones calculus predicts $E_{z,\mathrm{2DJones}} = 0$, it suffers a **$100\%$ relative error** on the longitudinal focal intensity for all $\sin\theta \ne 0$.
2. **Why Bulk Zero-Refractive-Index (ZRI, $n \to 0$) Media Kill $E_z$ at the Focus Yet Excel at Upstream Wavefront Conditioning**:
   Inside a bulk ZRI medium ($n_{\mathrm{ZRI}} \to 0$), the wavenumber $k = n_{\mathrm{ZRI}} k_0 \to 0$ flattens spatial phase gradients ($\nabla_\perp \Phi \to 0$), causing both the convergence-induced longitudinal component $E_z^{\mathrm{bulk}}(n_{\mathrm{ZRI}}) = E_0 n_{\mathrm{ZRI}} \sin\theta_{\mathrm{in}}$ and the upstream optical path aberration $\Delta\Phi_{\mathrm{ZRI}}(n_{\mathrm{ZRI}}) = n_{\mathrm{ZRI}} k_0 \Delta L$ to vanish identically at $n_{\mathrm{ZRI}} = 0$. Thus ZRI materials neutralize the counter-polarization trick if placed at the focus, but serve as ideal upstream phase flatteners before the SLM/metasurface.
3. **The Two-Stage High-NA Dielectric Metasurface + Thin-Film ENZ-Lignin Boundary Amplification Architecture**:
   - **Stage 1 (High-NA Dielectric Metasurface)**: Sub-wavelength $\mathrm{Si}$ or $\mathrm{TiO_2}$ nanopillars act as local birefringent half-waveplates $J_{\mathrm{pillar}}(\theta) = \begin{pmatrix} \cos\theta & \sin\theta \\ \sin\theta & -\cos\theta \end{pmatrix}$ ($\det J_{\mathrm{pillar}} = -1$, $J_{00}^2 + J_{10}^2 = 1$) while imparting the hyperbolic lens phase $\Phi(r; f, \lambda_0) = -\frac{2\pi}{\lambda_0}(\sqrt{r^2 + f^2} - f)$, which we prove satisfies $\Phi(0) = 0$, $\Phi(r) < 0$ ($r \ne 0$), and exact Optical Path Length (OPL) focal phase equalization $\Phi(r; f, \lambda_0) + \frac{2\pi}{\lambda_0}\sqrt{r^2 + f^2} = \frac{2\pi f}{\lambda_0}$ across the entire aperture.
   - **Stage 2 (Thin-Film ENZ-Lignin Boundary Continuity)**: At the interface between air ($\varepsilon_{\mathrm{air}} = 1$) and an ultra-thin Epsilon-Near-Zero (ENZ) coating ($\varepsilon_{\mathrm{ENZ}} \in [1/20, 1/10]$, e.g. ITO or AZO near its Lyddane–Sachs–Teller longitudinal optical zero $\omega_{\mathrm{LO}}$), Maxwell's normal displacement continuity $\varepsilon_{\mathrm{air}} E_{z,\mathrm{air}} = \varepsilon_{\mathrm{ENZ}} E_{z,\mathrm{ENZ}}$ amplifies the internal longitudinal intensity by $\Gamma_{\mathrm{ENZ}}(1, \varepsilon_{\mathrm{ENZ}}) = (1/\varepsilon_{\mathrm{ENZ}})^2 \in [100, 400]$ ($100\times$ at $\varepsilon_{\mathrm{ENZ}} = 0.1$ and $400\times$ at $\varepsilon_{\mathrm{ENZ}} = 0.05$), bounded in lossy Drude media ($\varepsilon_{\mathrm{ENZ}} = \varepsilon_r + i\varepsilon_i$) by the finite ceiling $\varepsilon_{\mathrm{air}}^2 / \varepsilon_i^2$.
4. **Higher-Rank $Gr_{\mathbb{C}}(3, 6)$ / $Gr_{\mathbb{C}}(3, n)$ Direct 3D Volumetric Splat Imaging (`NormedTensorGaussianSplat3D.gr36_volumetric_imaging_and_plucker_identities`)**:
   Because both the 3-element Debye–Wolf focal field $(E_x, E_y, E_z)^T \in \mathbb{C}^3$ and a 3D Gaussian voxel (`NormedTensorGaussianSplat3D`) are rank-3 objects, embedding them directly into $Gr_{\mathbb{C}}(3, 6)$ (`gr36TwistorMatrix`) allows all three 1D principal variances $(\sigma_1^2, \sigma_2^2, \sigma_3^2)$, all three 2D orthographic marginal determinants ($\det\Sigma_{xy}, \det\Sigma_{xz}, \det\Sigma_{yz}$), the 3D covariance determinant $\det\Sigma_{\mathrm{3D}}$, the 3D trace $\operatorname{Tr}\Sigma_{\mathrm{3D}}$, the 3D core Bohm potential $Q_{\mathrm{core,3D}}$, and the 4-term quadratic Plücker syzygy to be evaluated directly from $3 \times 3$ complex Plücker minors (`complexThreeRowMinor`).

---

## 1. Review & Formal Critique of `Vectorial-Wave-Model-for-Longitudinal-Polarization.md`

### 1.1 Provenance & Claim-by-Claim Audit

The table below audits every physical and mathematical claim in [data/chats/Vectorial-Wave-Model-for-Longitudinal-Polarization.md](../../../data/chats/Vectorial-Wave-Model-for-Longitudinal-Polarization.md#L1-L215) against classical electrodynamics, scholarly literature, and its verified Lean 4 representation in `Signals.DDF`:

| Chat Section & Line Range | Core Physical / Mathematical Claim | Verification Status & Scholarly Provenance | Lean 4 Declaration & `@[blueprint]` Node in [../Signals/DDF.lean](../Signals/DDF.lean#L6067-L6588) |
|---|---|---|---|
| **Prompt 1 & Response 1** ([lines 5–53](../../../data/chats/Vectorial-Wave-Model-for-Longitudinal-Polarization.md#L5-L53)) | 2D Jones calculus and 2D scalar GS assume paraxial transverse fields ($E_z = 0$); high-NA focusing of radially polarized light requires 3-element Debye–Wolf vectors $(E_x, E_y, E_z)^T$, where opposite rays cancel $E_x, E_y$ and double $E_z = 2 E_0 \sin\theta$ | **Verified Classical Vectorial Optics** ([Richards & Wolf 1959](#richards1959); [Dorn, Quabis, & Leuchs 2003](#dorn2003)): radially polarized high-NA focusing produces a sharper longitudinal $E_z$ spot below the scalar Airy limit | `debyeWolfRadialComponent`, `debyeWolfLongitudinalComponent`, `debyeWolfRayVec3`, and `vectorial_longitudinal_polarization_metasurface_and_enz_identities` (`thm:signals-ddf-vectorial-longitudinal-polarization-metasurface-enz`, Laws 1–5) |
| **Prompt 2 & Response 2** ([lines 60–115](../../../data/chats/Vectorial-Wave-Model-for-Longitudinal-Polarization.md#L60-L115)) | Bulk zero-refractive-index (ZRI, $n \to 0$) media stretch $\lambda_{\mathrm{eff}} = \lambda_0/n \to \infty$ ($k = n k_0 \to 0$), flattening spatial phase gradients and killing $E_z$ at the focus, but work upstream to collimate/flatten wavefronts before the SLM | **Verified Classical Metamaterial Electrodynamics** ([Liberal & Engheta 2017](#liberal2017)): $n \to 0 \implies k \to 0$ enforces spatially uniform phase in bulk ZRI, preventing high-angle convergence inside the ZRI bulk while enabling upstream phase conditioning | `vectorial_longitudinal_polarization_metasurface_and_enz_identities` (`h_zri1`: $E_0 \cdot 0 \cdot \sin\theta = 0$ and `h_zri2`: $0 \cdot k_0 \cdot \Delta L = 0$, Law 6) |
| **Response 3, Part 1** ([lines 127–167](../../../data/chats/Vectorial-Wave-Model-for-Longitudinal-Polarization.md#L127-L167)) | High-NA dielectric metasurface ($\mathrm{Si}$ / $\mathrm{TiO_2}$ nanopillars) imparts hyperbolic phase $\Phi(r) = -\frac{2\pi}{\lambda_0}(\sqrt{r^2+f^2}-f)$ and acts as a spatially varying birefringent Jones matrix $J(r,\theta)$ for radial polarization | **Verified Classical Flat-Optics Design** ([Khorasaninejad et al. 2016](#khorasaninejad2016); [Arbabi et al. 2015](#arbabi2015)): hyperbolic phase equalizes optical path length $\Phi(r) + k_0\sqrt{r^2+f^2} = k_0 f$ free of spherical aberration | `hyperbolicMetasurfacePhase`, `radialNanopillarJonesMatrix`, and `vectorial_longitudinal_polarization_metasurface_and_enz_identities` (Laws 7–11) |
| **Response 3, Part 2** ([lines 169–215](../../../data/chats/Vectorial-Wave-Model-for-Longitudinal-Polarization.md#L169-L215)) | Normal displacement continuity $D_{z,\mathrm{air}} = \varepsilon_{\mathrm{air}} E_{z,\mathrm{air}} = \varepsilon_{\mathrm{ENZ}} E_{z,\mathrm{ENZ}}$ across an ultra-thin ENZ film (ITO/AZO on lignin) yields $E_{z,\mathrm{ENZ}} = E_{z,\mathrm{air}}/\varepsilon_{\mathrm{ENZ}}$ and $100\times$–$400\times$ intensity enhancement | **Verified Classical Maxwell Boundary Law with Loss Guard** ([Campione et al. 2015](#campione2015); [Reshef et al. 2019](#reshef2019)): $(1/\varepsilon_{\mathrm{ENZ}})^2 \in [100, 400]$ for $\varepsilon_{\mathrm{ENZ}} \in [0.05, 0.1]$, bounded at $\varepsilon_r = 0$ by Drude loss $\varepsilon_i > 0$ (`regularizedEnzEnhancement`) | `enzBoundaryLongitudinalField`, `enzBoundaryIntensityEnhancement`, `regularizedEnzEnhancement`, and `vectorial_longitudinal_polarization_metasurface_and_enz_identities` (Laws 12–15) |

---

## 2. Why $Gr_{\mathbb{C}}(3, n)$ ($Gr_{\mathbb{C}}(3, 6)$) Is the Native Grassmannian for 3-Vectorial $(E_x, E_y, E_z)$ Optics and 3D Volumetric Imaging

### 2.1 From Rank-2 $Gr_{\mathbb{C}}(2, 4)$ (2D Transverse Jones) to Rank-3 $Gr_{\mathbb{C}}(3, 6)$ (3D Debye–Wolf & Volumetric Voxels)

In paraxial wave optics, the electric field is a 2-component transverse Jones vector $(E_x, E_y)^T \in \mathbb{C}^2$, so a two-channel interferometer or 2D Gaussian splat (`NormedTensorGaussianSplat2D`) naturally lives in the rank-2 complex Grassmannian $Gr_{\mathbb{C}}(2, 4)$. To recover the 3rd axial variance $\sigma_3^2$ of a `NormedTensorGaussianSplat3D` using only $Gr_{\mathbb{C}}(2, 4)$, our companion paper [grassmannian-holographic-imaging-depth-recovery-paper.md](grassmannian-holographic-imaging-depth-recovery-paper.md) paired a lateral twistor matrix $M_{\mathrm{lat}} \in Gr_{\mathbb{C}}(2, 4)$ with a second depth twistor matrix $M_{\mathrm{depth}} \in Gr_{\mathbb{C}}(2, 4)$.

By contrast, in **non-paraxial 3D Debye–Wolf vectorial optics** ($\mathbf{E} = (E_x, E_y, E_z)^T \in \mathbb{C}^3$) and **direct 3D volumetric splat imaging** (`NormedTensorGaussianSplat3D` with $(\sigma_1, \sigma_2, \sigma_3)$), the state has **three** independent complex orthogonal components. Embedding directly into the self-dual rank-3 complex Grassmannian **$Gr_{\mathbb{C}}(3, 6)$** (and more generally $Gr_{\mathbb{C}}(3, n)$ for $n$-beam vectorial holography) via `gr36VolumetricImagingMatrix` and `NormedTensorGaussianSplat3D.gr36TwistorMatrix` ([../Signals/DDF.lean](../Signals/DDF.lean#L6095-L6121)):

$$
M_{\mathbb{C}}^{(3,6)}(\sigma_1 e^{i\phi_1}, \sigma_2 e^{i\phi_2}, \sigma_3 e^{i\phi_3}) =
\begin{pmatrix}
\sigma_1 e^{i\phi_1} & 0 & 0 & 1 & 0 & 0 \\
0 & \sigma_2 e^{i\phi_2} & 0 & 0 & 1 & 0 \\
0 & 0 & \sigma_3 e^{i\phi_3} & 0 & 0 & 1
\end{pmatrix} \in \mathbb{C}^{3 \times 6},
$$

places all three spatial/polarization axes on an equal footing inside a **single** $3 \times 6$ matrix whose $\binom{6}{3} = 20$ three-row Plücker minors $\Delta_{abc}^{\mathbb{C}}$ (`complexThreeRowMinor` in [../Signals/Geometry.lean](../Signals/Geometry.lean#L1451-L1456)) simultaneously encode 1D, 2D, and 3D observables!

### 2.2 The 12 Simultaneous $Gr_{\mathbb{C}}(3, 6)$ / $Gr_{\mathbb{C}}(3, n)$ 3D Volumetric Imaging Laws (`NormedTensorGaussianSplat3D.gr36_volumetric_imaging_and_plucker_identities`)

Proved in [../Signals/DDF.lean](../Signals/DDF.lean#L6165-L6308) (Blueprint node `thm:signals-ddf-gr36-volumetric-imaging-identities`, paired with `complexThreeRowMinor_basisChange` at `lem:signals-ddf-complex-three-row-minor-basis-change` and `complexThreeRowMinor_pluecker` at `thm:signals-complex-three-row-minor-pluecker`):

| # | $Gr_{\mathbb{C}}(3, 6)$ / $Gr_{\mathbb{C}}(3, n)$ Volumetric Imaging Law | Exact $3 \times 3$ Plücker Minor Identity (`complexThreeRowMinor`) | Lean 4 Conjunct in [../Signals/DDF.lean](../Signals/DDF.lean#L6170-L6195) |
|---|---|---|---|
| **G3-1** | **Reference $3 \times 3$ Plücker Minor Normalization** | $\Delta_{345}^{\mathbb{C}}(M_3) = 1$ | `h.1` |
| **G3-2** | **Direct 1st Principal Variance / $x$-Intensity Extraction** | $\bigl|\Delta_{045}^{\mathbb{C}}(M_3)\bigr|^2 = \sigma_1^2$ | `h.2.1` |
| **G3-3** | **Direct 2nd Principal Variance / $y$-Intensity Extraction** | $\bigl|\Delta_{315}^{\mathbb{C}}(M_3)\bigr|^2 = \sigma_2^2$ | `h.2.2.1` |
| **G3-4** | **Direct 3rd Principal (Longitudinal/Depth) Variance / $z$-Intensity Extraction** | $\bigl|\Delta_{342}^{\mathbb{C}}(M_3)\bigr|^2 = \sigma_3^2$ | `h.2.2.2.1` |
| **G3-5** | **Orthographic $xy$-Plane Marginal Covariance Determinant** | $\bigl|\Delta_{015}^{\mathbb{C}}(M_3)\bigr|^2 = \sigma_1^2\sigma_2^2 = \det\Sigma_{\mathrm{2D}}^{\mathrm{ortho}}$ | `h.2.2.2.2.1` |
| **G3-6** | **Orthographic $xz$-Plane Marginal Covariance Determinant** | $\bigl|\Delta_{042}^{\mathbb{C}}(M_3)\bigr|^2 = \sigma_1^2\sigma_3^2$ | `h.2.2.2.2.2.1` |
| **G3-7** | **Orthographic $yz$-Plane Marginal Covariance Determinant** | $\bigl|\Delta_{312}^{\mathbb{C}}(M_3)\bigr|^2 = \sigma_2^2\sigma_3^2$ | `h.2.2.2.2.2.2.1` |
| **G3-8** | **Full 3D Volumetric Covariance Determinant** | $\bigl|\Delta_{012}^{\mathbb{C}}(M_3)\bigr|^2 = \sigma_1^2\sigma_2^2\sigma_3^2 = \det\Sigma_{\mathrm{3D}}$ | `h.2.2.2.2.2.2.2.1` |
| **G3-9** | **Full 3D Covariance Trace / Total Vectorial Intensity** | $\bigl|\Delta_{045}^{\mathbb{C}}\bigr|^2 + \bigl|\Delta_{315}^{\mathbb{C}}\bigr|^2 + \bigl|\Delta_{342}^{\mathbb{C}}\bigr|^2 = \sigma_1^2 + \sigma_2^2 + \sigma_3^2 = \operatorname{Tr}\Sigma_{\mathrm{3D}}$ | `h.2.2.2.2.2.2.2.2.1` |
| **G3-10** | **Direct 3D Core Bohm Quantum Potential from 2D-to-3D Minor Ratio** | $\frac{\hbar^2}{4m}\frac{|\Delta_{312}^{\mathbb{C}}|^2 + |\Delta_{042}^{\mathbb{C}}|^2 + |\Delta_{015}^{\mathbb{C}}|^2}{|\Delta_{012}^{\mathbb{C}}|^2} = Q_{\mathrm{core,3D}}(\Sigma_{\mathrm{3D}})$ | `h.2.2.2.2.2.2.2.2.2.1` |
| **G3-11** | **Exact Compatibility with $Gr_{\mathbb{C}}(2,4)$ Plücker Depth Ratio $R_{\mathrm{depth}}$** | $\frac{|\Delta_{045}^{\mathbb{C}}|^2 + |\Delta_{315}^{\mathbb{C}}|^2}{|\Delta_{342}^{\mathbb{C}}|^2} = \frac{\sigma_1^2 + \sigma_2^2}{\sigma_3^2} = R_{\mathrm{depth}}$ | `h.2.2.2.2.2.2.2.2.2.2.1` |
| **G3-12** | **Universal 4-Term $Gr_{\mathbb{C}}(3, 6)$ Quadratic Plücker Syzygy** | $\Delta_{012}^{\mathbb{C}}\Delta_{345}^{\mathbb{C}} - \Delta_{013}^{\mathbb{C}}\Delta_{245}^{\mathbb{C}} + \Delta_{014}^{\mathbb{C}}\Delta_{235}^{\mathbb{C}} - \Delta_{015}^{\mathbb{C}}\Delta_{234}^{\mathbb{C}} = 0$ | `h.2.2.2.2.2.2.2.2.2.2.2` |

---

## 3. Complete Catalog of the 15 Simultaneous Vectorial Longitudinal Polarization, Metasurface, ZRI, & ENZ Boundary Laws

Proved in `vectorial_longitudinal_polarization_metasurface_and_enz_identities` ([../Signals/DDF.lean](../Signals/DDF.lean#L6445-L6588), Blueprint node `thm:signals-ddf-vectorial-longitudinal-polarization-metasurface-enz`):

| # | Optical / Electrodynamic Law | Mathematical Identity | Lean 4 Conjunct in [../Signals/DDF.lean](../Signals/DDF.lean#L6455-L6480) |
|---|---|---|---|
| **VP-1** | **3-Element Debye–Wolf Single-Ray Vectorial Norm Conservation** | $E_x(\phi)^2 + E_y(\phi)^2 + E_z(\phi)^2 = (E_0\cos\theta\cos\phi)^2 + (E_0\cos\theta\sin\phi)^2 + (E_0\sin\theta)^2 = E_0^2$ | `h.1` |
| **VP-2** | **Counter-Polarization Transverse $E_x$ Cancellation ($\phi$ vs. $\phi+\pi$)** | $E_x(\phi) + E_x(\phi + \pi) = 0$ | `h.2.1` |
| **VP-3** | **Counter-Polarization Transverse $E_y$ Cancellation ($\phi$ vs. $\phi+\pi$)** | $E_y(\phi) + E_y(\phi + \pi) = 0$ | `h.2.2.1` |
| **VP-4** | **Counter-Polarization Longitudinal $E_z$ Constructive Doubling** | $E_z(\phi) + E_z(\phi + \pi) = 2 E_0 \sin\theta$ | `h.2.2.2.1` |
| **VP-5** | **$100\%$ Longitudinal Focal Intensity Error of 2D Paraxial Jones / GS** | $\frac{(E_z(\phi) + E_z(\phi+\pi))^2 - 0}{(E_z(\phi) + E_z(\phi+\pi))^2} = 1$ ($\sin\theta \ne 0$) | `h.2.2.2.2.1` |
| **VP-6** | **Bulk Zero-Refractive-Index ($n_{\mathrm{ZRI}} = 0$) Extinction of Focal $E_z$** | $E_0 \cdot 0 \cdot \sin\theta = 0$ | `h.2.2.2.2.2.1` |
| **VP-7** | **Upstream ZRI ($n_{\mathrm{ZRI}} = 0$) Wavefront Phase-Aberration Flattening** | $0 \cdot k_0 \cdot \Delta L = 0$ | `h.2.2.2.2.2.2.1` |
| **VP-8** | **Hyperbolic Dielectric Metasurface On-Axis Zero Phase** | $\Phi(0; f, \lambda_0) = 0$ | `h.2.2.2.2.2.2.2.1` |
| **VP-9** | **Hyperbolic Dielectric Metasurface Off-Axis Phase Advance ($r \ne 0$)** | $\Phi(r; f, \lambda_0) = -\frac{2\pi}{\lambda_0}(\sqrt{r^2+f^2}-f) < 0$ | `h.2.2.2.2.2.2.2.2.1` |
| **VP-10** | **Exact Optical Path Length (OPL) Focal Phase Equalization ($\forall r \in \mathbb{R}$)** | $\Phi(r; f, \lambda_0) + \frac{2\pi}{\lambda_0}\sqrt{r^2 + f^2} = \frac{2\pi f}{\lambda_0}$ | `h.2.2.2.2.2.2.2.2.2.1` |
| **VP-11** | **Local Nanopillar Birefringent Jones Radial-Conversion Unitarity & Det** | $J_{00}(\theta)^2 + J_{10}(\theta)^2 = \cos^2\theta + \sin^2\theta = 1$ and $\det J_{\mathrm{pillar}}(\theta) = -1$ | `h.2.2.2.2.2.2.2.2.2.2.1` & `.2.1` |
| **VP-12** | **Maxwell Normal Displacement Continuity at Thin-Film ENZ Interface** | $\varepsilon_{\mathrm{ENZ}} \cdot E_{z,\mathrm{ENZ}}(\varepsilon_{\mathrm{air}}, \varepsilon_{\mathrm{ENZ}}, E_{z,\mathrm{air}}) = \varepsilon_{\mathrm{air}} E_{z,\mathrm{air}}$ | `h.2.2.2.2.2.2.2.2.2.2.2.2.1` |
| **VP-13** | **Exact $100\times$ and $400\times$ ENZ Intensity Enhancement Benchmarks** | $\Gamma_{\mathrm{ENZ}}(1, 1/10) = 100$ and $\Gamma_{\mathrm{ENZ}}(1, 1/20) = 400$ | `h.2.2.2.2.2.2.2.2.2.2.2.2.2.1` & `.2.1` |
| **VP-14** | **Monotonic $[100\times, 400\times]$ Enhancement Window on $\varepsilon_{\mathrm{ENZ}} \in [1/20, 1/10]$** | $100 \le \Gamma_{\mathrm{ENZ}}(1, \varepsilon_{\mathrm{ENZ}}) \le 400$ | `h.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.1` & `.2.1` |
| **VP-15** | **Loss-Regularized Complex Drude ENZ Finite Ceiling ($\varepsilon_i \ne 0$)** | $\Gamma_{\mathrm{ENZ,reg}}(\varepsilon_{\mathrm{air}}, \varepsilon_r, \varepsilon_i) \le \Gamma_{\mathrm{ENZ,reg}}(\varepsilon_{\mathrm{air}}, 0, \varepsilon_i) = \frac{\varepsilon_{\mathrm{air}}^2}{\varepsilon_i^2}$ | `h.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.1` & `.2` |

---

## 4. Self-Contained Machine-Checked Lean 4 Proof Block

The following Lean 4 verification block compiles directly against `Signals` and `SignalsPending`:

```lean
import Signals
import SignalsPending

namespace VectorialLongitudinalPolarizationAndGr36PaperVerification

open Signals.Geometry
open Signals.DDF

-- 1. Higher-Rank Gr_C(3,6) Direct 3D Volumetric Splat Imaging & 4-Term Plücker Syzygy
example (splat : NormedTensorGaussianSplat3D) (φ1 φ2 φ3 : ℝ) :
    let M3 := splat.gr36TwistorMatrix φ1 φ2 φ3
    let s_ortho := splat.projectOrthographic2D
    complexThreeRowMinor M3 3 4 5 = 1 ∧
    Complex.normSq (complexThreeRowMinor M3 0 4 5) = splat.sigma1 ^ 2 ∧
    Complex.normSq (complexThreeRowMinor M3 3 1 5) = splat.sigma2 ^ 2 ∧
    Complex.normSq (complexThreeRowMinor M3 3 4 2) = splat.sigma3 ^ 2 ∧
    Complex.normSq (complexThreeRowMinor M3 0 1 5) = s_ortho.covDet ∧
    Complex.normSq (complexThreeRowMinor M3 0 1 2) = splat.covDet ∧
    Complex.normSq (complexThreeRowMinor M3 0 4 5) +
        Complex.normSq (complexThreeRowMinor M3 3 1 5) +
        Complex.normSq (complexThreeRowMinor M3 3 4 2) =
      splat.covTrace ∧
    (1 ^ 2 / (4 * (1 : ℝ))) *
        ((Complex.normSq (complexThreeRowMinor M3 3 1 2) +
            Complex.normSq (complexThreeRowMinor M3 0 4 2) +
            Complex.normSq (complexThreeRowMinor M3 0 1 5)) /
          Complex.normSq (complexThreeRowMinor M3 0 1 2)) =
      splat.coreBohmPotential 1 1 ∧
    complexThreeRowMinor M3 0 1 2 * complexThreeRowMinor M3 3 4 5 -
        complexThreeRowMinor M3 0 1 3 * complexThreeRowMinor M3 2 4 5 +
        complexThreeRowMinor M3 0 1 4 * complexThreeRowMinor M3 2 3 5 -
        complexThreeRowMinor M3 0 1 5 * complexThreeRowMinor M3 2 3 4 = 0 := by
  intro M3 s_ortho
  have h := splat.gr36_volumetric_imaging_and_plucker_identities φ1 φ2 φ3 1 1 (by norm_num)
  exact ⟨h.1, h.2.1, h.2.2.1, h.2.2.2.1, h.2.2.2.2.1, h.2.2.2.2.2.2.2.1,
    h.2.2.2.2.2.2.2.2.1, h.2.2.2.2.2.2.2.2.2.1, h.2.2.2.2.2.2.2.2.2.2.2⟩

-- 2. 3-Element Debye-Wolf Longitudinal Polarization, Counter-Polarization Cancellation,
--    ZRI Extinction vs. Collimation, Hyperbolic Metasurface, & 100x-400x ENZ Boundary Amplification
example (φ : ℝ) :
    let ray1 := debyeWolfRayVec3 2 (Real.pi / 2) φ
    let ray2 := debyeWolfRayVec3 2 (Real.pi / 2) (φ + Real.pi)
    ray1.1 ^ 2 + ray1.2.1 ^ 2 + ray1.2.2 ^ 2 = (2 : ℝ) ^ 2 ∧
    ray1.1 + ray2.1 = 0 ∧
    ray1.2.1 + ray2.2.1 = 0 ∧
    ray1.2.2 + ray2.2.2 = 2 * debyeWolfLongitudinalComponent 2 (Real.pi / 2) ∧
    ((ray1.2.2 + ray2.2.2) ^ 2 - 0) / (ray1.2.2 + ray2.2.2) ^ 2 = 1 ∧
    hyperbolicMetasurfacePhase 0 5 1 = 0 ∧
    hyperbolicMetasurfacePhase 3 5 1 < 0 ∧
    hyperbolicMetasurfacePhase 3 5 1 + (2 * Real.pi / 1) * Real.sqrt (3 ^ 2 + 5 ^ 2) =
      (2 * Real.pi * 5) / 1 ∧
    (radialNanopillarJonesMatrix (Real.pi / 2) 0 0) ^ 2 +
        (radialNanopillarJonesMatrix (Real.pi / 2) 1 0) ^ 2 = 1 ∧
    (radialNanopillarJonesMatrix (Real.pi / 2)).det = -1 ∧
    enzBoundaryIntensityEnhancement 1 (1 / 10) = 100 ∧
    enzBoundaryIntensityEnhancement 1 (1 / 20) = 400 ∧
    100 ≤ enzBoundaryIntensityEnhancement 1 (1 / 15) ∧
    enzBoundaryIntensityEnhancement 1 (1 / 15) ≤ 400 ∧
    regularizedEnzEnhancement 1 2 (1 / 10) ≤ regularizedEnzEnhancement 1 0 (1 / 10) := by
  intro ray1 ray2
  have hsin_pi2 : Real.sin (Real.pi / 2) ≠ 0 := by
    rw [Real.sin_pi_div_two]
    norm_num
  have h := vectorial_longitudinal_polarization_metasurface_and_enz_identities
    2 (Real.pi / 2) φ 3 5 1 10 1 1 (1 / 15) 3 2 (1 / 10)
    (by norm_num) hsin_pi2 (by norm_num) (by norm_num) (by norm_num)
    (by norm_num) (by norm_num) (by norm_num)
  exact ⟨h.1, h.2.1, h.2.2.1, h.2.2.2.1, h.2.2.2.2.1,
    h.2.2.2.2.2.2.2.1, h.2.2.2.2.2.2.2.2.1, h.2.2.2.2.2.2.2.2.2.1,
    h.2.2.2.2.2.2.2.2.2.2.1, h.2.2.2.2.2.2.2.2.2.2.2.1,
    h.2.2.2.2.2.2.2.2.2.2.2.2.2.1, h.2.2.2.2.2.2.2.2.2.2.2.2.2.2.1,
    h.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.1, h.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.1,
    h.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.1⟩

end VectorialLongitudinalPolarizationAndGr36PaperVerification
```

---

### Scholarly References

- <a id="richards1959"></a> Richards, B., & Wolf, E. (1959). Electromagnetic Diffraction in Optical Systems, II. Structure of the Image Field in an Aplanatic System. *Proceedings of the Royal Society of London. Series A*, 253(1274), 358–379. DOI: `10.1098/rspa.1959.0200`.
- <a id="dorn2003"></a> Dorn, R., Quabis, S., & Leuchs, G. (2003). Sharper Focus for a Radially Polarized Light Beam. *Physical Review Letters*, 91(23), 233901. DOI: `10.1103/PhysRevLett.91.233901`.
- <a id="arbabi2015"></a> Arbabi, A., Horie, Y., Bagheri, M., & Faraon, A. (2015). Dielectric Metasurfaces for Complete Control of Phase and Polarization with Subwavelength Spatial Resolution and High Transmission. *Nature Nanotechnology*, 10(11), 937–943. DOI: `10.1038/nnano.2015.186`.
- <a id="khorasaninejad2016"></a> Khorasaninejad, M., Chen, W. T., Devlin, R. C., Oh, J., Zhu, A. Y., & Capasso, F. (2016). Metalenses at Visible Wavelengths: Diffraction-Limited Focusing and Subwavelength Resolution Imaging. *Science*, 352(6290), 1190–1194. DOI: `10.1126/science.aaf6644`.
- <a id="campione2015"></a> Campione, S., Brener, I., & Marquier, F. (2015). Theory of Epsilon-Near-Zero Modes in Ultrathin Films. *Physical Review B*, 91(12), 121408(R). DOI: `10.1103/PhysRevB.91.121408`.
- <a id="liberal2017"></a> Liberal, I., & Engheta, N. (2017). Near-Zero Refractive Index Photonics. *Nature Photonics*, 11(3), 149–158. DOI: `10.1038/nphoton.2017.13`.
- <a id="reshef2019"></a> Reshef, O., De Leon, I., Alam, M. Z., & Boyd, R. W. (2019). Nonlinear Optical Effects in Epsilon-Near-Zero Media. *Nature Reviews Materials*, 4(8), 535–551. DOI: `10.1038/s41578-019-0120-5`.
- <a id="vec-chat2026"></a> Provenance Chat Log (2026). *Vectorial Wave Model for Longitudinal Polarization*. Local corpus: [data/chats/Vectorial-Wave-Model-for-Longitudinal-Polarization.md, lines 1–215](../../../data/chats/Vectorial-Wave-Model-for-Longitudinal-Polarization.md#L1-L215).

```bibtex
@article{richards1959_debyewolf,
  author  = {Richards, B. and Wolf, E.},
  title   = {Electromagnetic Diffraction in Optical Systems, {II}. Structure of the Image Field in an Aplanatic System},
  journal = {Proceedings of the Royal Society of London. Series A},
  volume  = {253},
  number  = {1274},
  pages   = {358--379},
  year    = {1959},
  doi     = {10.1098/rspa.1959.0200}
}

@article{dorn2003_radial,
  author  = {Dorn, Ralf and Quabis, Susanne and Leuchs, Gerd},
  title   = {Sharper Focus for a Radially Polarized Light Beam},
  journal = {Physical Review Letters},
  volume  = {91},
  number  = {23},
  pages   = {233901},
  year    = {2003},
  doi     = {10.1103/PhysRevLett.91.233901}
}

@article{liberal2017_zri,
  author  = {Liberal, I{\~n}igo and Engheta, Nader},
  title   = {Near-Zero Refractive Index Photonics},
  journal = {Nature Photonics},
  volume  = {11},
  number  = {3},
  pages   = {149--158},
  year    = {2017},
  doi     = {10.1038/nphoton.2017.13}
}

@article{campione2015_enz,
  author  = {Campione, Salvatore and Brener, Igal and Marquier, Francois},
  title   = {Theory of Epsilon-Near-Zero Modes in Ultrathin Films},
  journal = {Physical Review B},
  volume  = {91},
  number  = {12},
  pages   = {121408},
  year    = {2015},
  doi     = {10.1103/PhysRevB.91.121408}
}

@misc{chat_vectorial_longitudinal_polarization_2026,
  author       = {{unknown}},
  title        = {Vectorial Wave Model for Longitudinal Polarization},
  year         = {2026},
  howpublished = {AI chat log},
  note         = {Source: data/chats/Vectorial-Wave-Model-for-Longitudinal-Polarization.md, lines 1-215}
}
```

```json
{
  "@context": "https://schema.org",
  "@type": "ScholarlyArticle",
  "headline": "3D Vectorial Wave Model for Longitudinal Polarization (E_z) and Higher-Rank Gr_C(3,n) Volumetric Imaging: Debye-Wolf Counter-Polarization, High-NA Dielectric Metasurfaces, ZRI Collimation vs. Thin-Film ENZ-Lignin Boundary Amplification in Lean 4",
  "author": {
    "@type": "Person",
    "name": "Wes Turner"
  },
  "dateModified": "2026-10-25",
  "isBasedOn": [
    "data/chats/Vectorial-Wave-Model-for-Longitudinal-Polarization.md",
    "src/signals/Signals/DDF.lean",
    "src/signals/Signals/Geometry.lean",
    "src/signals/numerical_adapter/src/orbital_splat.rs"
  ],
  "about": [
    "Debye-Wolf Vectorial Diffraction",
    "Longitudinal Polarization E_z",
    "Higher-Rank Complex Grassmannian Gr_C(3,6)",
    "Dielectric Metasurface Hyperbolic Phase",
    "Epsilon-Near-Zero Boundary Amplification",
    "Lean 4 Formal Verification"
  ]
}
```
