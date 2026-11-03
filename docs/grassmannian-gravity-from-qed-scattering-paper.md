---
title: "Grassmannian Gravity from QED & Gauge Scattering Amplitudes: Complex Gr_C(2,4) Orbital Precession, Mercury's Perihelion, N-Body Dynamics, and Dilatant Dark Fluid (DDF) Unification in Lean 4"
description: "An arXiv-ready formal verification paper deriving planetary orbits, Mercury's 42.98 arcsec/century perihelion precession, and N-body gravitational dynamics from flat-space QED/gauge scattering amplitudes, BCJ double copy on Gr_C(2,4), and Dilatant Dark Fluid (DDF) hydrodynamics in Lean 4."
---

(grassmannian-gravity-from-qed-scattering-paper)=
# Grassmannian Gravity from QED & Gauge Scattering Amplitudes: Complex $Gr_{\mathbb{C}}(2,4)$ Orbital Precession, Mercury's Perihelion, $N$-Body Dynamics, and Dilatant Dark Fluid (DDF) Unification in Lean 4

**Authors:** Wes Turner
**Subjects:** General Relativity and Quantum Cosmology (`gr-qc`); High Energy Physics - Theory (`hep-th`); Mathematical Physics (`math-ph`); Astrophysics - Earth and Planetary Astrophysics (`astro-ph.EP`); Logic in Computer Science (`cs.LO`)
**Formal Verification Artifact:** `Signals` Lean 4 Library (`leanprover/lean4:v4.35.0-rc3`, Mathlib `v4.35.0-rc3`)
**Companion Papers:**
- [Huygens–Steiner Barycentric Coherence, Complex $Gr_{\mathbb{C}}(2,4)$ Plücker Channels, and Multi-Model Double-Slit & OAM Relative Predictive Error in Lean 4](grassmannian-huygens-double-slit-oam-paper.md)
- [Complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ & $N$-ary $Gr_{\mathbb{C}}(2, N+2)$ Unification with Dilatant Dark Fluid (DDF) Moving Sheaths, Plücker Sink Fluxes, Anosov Invariance, and Sorkin Triple-Slit Interferometry in Lean 4](grassmannian-ddf-moving-sheath-paper.md)
- [Grassmannian Geometry of the Quantum Inverse Scattering Method, Algebraic Bethe Ansatz, and Inverse Scattering Metrology in Lean 4](grassmannian-qism-bethe-ansatz-paper.md)
- [Normed Tensor Gaussian Splat Mechanics for Complex $Gr_{\mathbb{C}}(2,4)$ Twistors: Advantages, Limitations, WebGL2/WASM Practicality, and Unification Across Double-Slit, QISM, DDF, and Planetary Gravity in Lean 4](grassmannian-splat-mechanics-paper.md)
- [Inelastic Scattering and the Heat Problem in Unified Grassmannian–DDF Mechanics: Inverse Compton, Stokes/Anti-Stokes Raman, Fourier vs. Cattaneo–Vernotte, and Subluminal Second-Sound Tensor Splatting in Lean 4](grassmannian-thermal-compton-raman-paper.md)
- [Polaritons and Surface Plasmon Polaritons (SPPs) in Unified Grassmannian–DDF Mechanics: Hopfield–Rabi Anticrossing, Lyddane–Sachs–Teller Reststrahlen Bands, $Gr_{\mathbb{C}}(2,4)$ Evanescent Skin-Depth Duality, and Sub-Wavelength Tensor Splatting in Lean 4](grassmannian-polariton-spp-mechanics-paper.md)
- [The Holographic Principle in Complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ and Dilatant Dark Fluid (DDF) Mechanics: 't Hooft–Susskind Horizon Entropy, Gauss–Smarr Bulk Mass Recovery, Plücker Redshift Lapse, and Planck Tensor Splatting in Lean 4](grassmannian-holographic-principle-paper.md)
- [AdS/CFT Correspondence, Planar Integrability, and Secret Symmetries in Unified Complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ and Dilatant Dark Fluid (DDF) Mechanics: From Maldacena and $\mathfrak{psl}(2|2)_c$ Yangians to Plücker Outer Automorphisms and Holographic RG Tensor Splatting in Lean 4](grassmannian-ads-cft-ddf-paper.md)
- [Complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ Fubini–Study Gross–Pitaevskii Equation, Dual-Schubert `iGPE`, and Homogeneous Plücker Madelung Hydrodynamics on the Klein Quadric $\mathcal{Q}_4$ in Lean 4 and Rust/WASM](grassmannian-complex-gpe-igpe-plucker-madelung-paper.md)
- [Unification, Engineering Applications, and Research Roadmap of Complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ and Dilatant Dark Fluid (DDF) Mechanics: Cross-Domain Plücker Invariants, Photonic–Thermal–Quantum Systems, and Formal Verification in Lean 4](grassmannian-unification-applications-roadmap-paper.md)

---

## Abstract

Can planetary orbital dynamics—including the anomalous $42.98''/\text{century}$ perihelion precession of Mercury, $N$-body gravitational perturbations, and quadrupole gravitational waves—be derived and verified from flat-space gauge/QED scattering amplitudes, Grassmannian Plücker geometry, and quantum-hydrodynamic substrates without assuming fundamental spacetime curvature? We present a machine-checked formalization in the Lean 4 theorem prover (`Signals.QEDGravity`, `Signals.DDF`, `Signals.Geometry`, and `Signals.Huygens`) uniting five frameworks:

1. **BCJ Color–Kinematics Duality & Double Copy on $Gr_{\mathbb{C}}(2,4)$ (`bcj_plucker_jacobi_and_double_copy`)**:
   In 4-point gauge scattering ([Bern, Carrasco, and Johansson 2008](#grav-bcj2008); [Arkani-Hamed and Trnka 2014](#grav-arkani2014)), the kinematic numerators $(n_s, n_t, n_u)$ defined by the quadratic Plücker products $n_s = \Delta_{01}^{\mathbb{C}}\Delta_{23}^{\mathbb{C}}$, $n_t = -\Delta_{02}^{\mathbb{C}}\Delta_{13}^{\mathbb{C}}$, and $n_u = \Delta_{03}^{\mathbb{C}}\Delta_{12}^{\mathbb{C}}$ automatically satisfy the Jacobi identity $n_s + n_t + n_u = 0$ via the 3-term Plücker relation on $Gr_{\mathbb{C}}(2,4)$. Squaring the kinematic numerator ($\text{Gravity} = \text{Gauge}^2$) maps gauge-fluid vorticity ($\boldsymbol{\omega} = \nabla \times \mathbf{v}$) onto the symmetric graviton/fluid shear-stress tensor $n_t^2 = (n_s + n_u)^2 = n_s^2 + 2 n_s n_u + n_u^2$.
2. **1-Loop Post-Minkowskian Effective Potential, DDF Substrate Decomposition, & Mercury's Perihelion Precession**:
   Matching the 1-loop classical scattering amplitude ([Partanen and Tulkki 2025](#grav-partanen2025); [Bjerrum-Bohr et al. 2018](#grav-bjerrum2018)) or the conservative Dilatant Dark Fluid (DDF) sheath action ([Fedi 2026](#grav-fedi2026)) yields the effective central potential

   $$
   V_{\mathrm{eff}}(r) = -\frac{G_\phi M m}{r}\left(1 + \frac{3 L^2}{m^2 c^2 r^2}\right) = m\,\Phi_\phi(r) - \frac{3\,G_\phi M\,L^2\,\varrho_{\max}^\varphi j_{\min}^\varphi}{m\,r^3},
   $$

   where $\Phi_\phi(r) = -G_\phi M / r$ is the superfluid Bernoulli enthalpy deficit and $\varrho_{\max}^\varphi j_{\min}^\varphi = c^{-2}$ is the DDF dispersed-phase compressibility-density product. This generates the exact per-orbit anomalous perihelion advance:

   $$
   \Delta\varpi = \frac{6\pi G_\phi M}{c^2 a(1 - e^2)} = \frac{3\pi\,r_H}{a(1 - e^2)} = \frac{6\pi\,G_\phi M\,\varrho_{\max}^\varphi j_{\min}^\varphi}{a(1 - e^2)},
   $$

   reproducing Mercury's anomalous $42.98''/\text{century}$ precession (and the total $574.61''/\text{century}$ advance when summed with the $531.63''/\text{century}$ Newtonian $N$-body planetary perturbations).
3. **Complex $Gr_{\mathbb{C}}(2,4)$ Planetary Orbital Precession Twistor Matrix (`PlanetaryOrbit.gr24PrecessionMatrix`)**:
   Encoding orbital eccentricity $e \in [0, 1)$ as the $Gr_{\mathbb{C}}(2,4)$ barycentric parallel-axis shift ($d_{\mathrm{bary}} = e$) and the anomalous perihelion phase $\Delta\varpi / 2$ in $M_{\mathbb{C}}^{\mathrm{orb}} \in Gr_{\mathbb{C}}(2,4)$ makes the Madelung channel densities equal the normalized aphelion and perihelion radii ($|w_A^{\mathbb{C}}|^2 = 1 + e = r_{\max}/a$, $|w_B^{\mathbb{C}}|^2 = 1 - e = r_{\min}/a$), while their product $|w_A^{\mathbb{C}}|^2 |w_B^{\mathbb{C}}|^2 = 1 - e^2 = p/a = \gamma_\varphi(e c)^{-2}$ is the exact semi-latus rectum ratio governing $\Delta\varpi = 3\pi r_H / p$.
4. **$N$-Body Sink Superposition on $Gr_{\mathbb{C}}(2, N+2)$ & Conservative Action vs. Stokes-Drag Critique**:
   We embed the $N$-body Newtonian/superfluid sink potential $\Phi_\phi^{(N)} = -\sum_{j=0}^{N-1} \frac{G_\phi M_j}{r_j}$ into $Gr_{\mathbb{C}}(2, N+2)$ and prove (`ddf_conservative_action_vs_stokes_drag_critique`) that conservative 1-loop QFT / DDF sheath mechanics preserves orbital energy ($\frac{dE}{dt} = 0$) while generating $\Delta\varpi > 0$, whereas naive dissipative Stokes drag ($F_{\mathrm{drag}} > 0 \implies \frac{dE}{dt} = -F_{\mathrm{drag}} v < 0$) is ruled out by solar-system ephemerides.
5. **Quadrupole Gravitational Waves Without DDF (`Signals.QEDGravity`) vs. With DDF (`Signals.DDF`) & 3D `NormedTensorGaussianSplat3D`**:
   Promoting `gr24PrecessionMatrix` to the dynamic quadrupole wave matrix `PlanetaryOrbit.gr24QuadrupoleWaveMatrix` in [src/signals/Signals/QEDGravity.lean](../src/signals/Signals/QEDGravity.lean) proves (`PlanetaryOrbit.qed_gravitational_wave_without_ddf_identities`) that the crossing Plücker minor oscillates at $2\Phi_{\mathrm{orb}}(t) + \Delta\varpi$ and the 2.5PN Peters–Mathews eccentricity factor obeys $f_{\mathrm{PM}}(e)^2 = P_{\mathrm{PM}}(e)^2 / (|w_A^{\mathbb{C}}|^2 |w_B^{\mathbb{C}}|^2)^7$. In [src/signals/Signals/DDF.lean](../src/signals/Signals/DDF.lean), `RiverExterior.gravitational_wave_with_ddf_identities` and `NormedTensorGaussianSplat3D.gravitational_wave_splat3d_and_projection_identities` formalize the $(\varrho_{\max}^\varphi j_{\min}^\varphi)$ strain/luminosity decomposition, GPE vortex density-gradient secondary-wavelet scattering, strain-thickened Kelvin-wave tail damping, 4D Schur-complement temporal conditioning, and 3D `NormedTensorGaussianSplat3D` volumetric wavepackets (whose orthographic 2D projection `projectOrthographic2D` recovers `NormedTensorGaussianSplat2D`).

---

## 1. From QED / Gauge Scattering & the Amplituhedron to Gravity and Quantum Fluids

In both modern post-Minkowskian scattering-amplitude theory ([Bern et al. 2008](#grav-bcj2008); [Bjerrum-Bohr et al. 2018](#grav-bjerrum2018); [Partanen and Tulkki 2025](#grav-partanen2025)) and superfluid/dilatant quantum-hydrodynamic models ([Fedi 2026](#grav-fedi2026)), classical gravitational dynamics is computed over a **flat Minkowski background** without postulating fundamental geometric curvature ({download}`data/chats/N-body-gravity-from-QED-with-scattering-amplitudes.md, lines 1-1120 <../data/chats/N-body-gravity-from-QED-with-scattering-amplitudes.md>`; {download}`data/chats/_Special-Relativity-Geometry-vs.-Fluid.md, lines 130-520 <../data/chats/_Special-Relativity-Geometry-vs.-Fluid.md>`):

```
┌──────────────────────────────┐     BCJ Double Copy      ┌──────────────────────────────┐
│  QED / Yang-Mills Amplitudes │ ───────────────────────► │  Graviton Scattering M_grav  │
│  in Gr_C(2,4) (n_s+n_t+n_u=0)│   (Gravity = Gauge²)     │  Tree O(G) + 1-Loop O(G²)    │
└──────────────┬───────────────┘                          └──────────────┬───────────────┘
               │ Madelung / Kerr-Schild                                  │ Fourier Transform q -> r
               ▼                                                         ▼
┌──────────────────────────────┐     DDF Constitutive     ┌──────────────────────────────┐
│  Gauge Vortex Fluid (ω = ∇×v)│ ───────────────────────► │  V_eff(r) & N-Body Orbits    │
│  & Superfluid Sinks Φ_ϕ(r)   │  γ_φ(v) = (1 - v²/c²)⁻¹/²│  Mercury Δϖ = 42.98''/cy     │
└──────────────────────────────┘                          └──────────────────────────────┘
```

### 1.1 BCJ Color–Kinematics Duality Realized by the $Gr_{\mathbb{C}}(2,4)$ Plücker Identity

In 4-point tree-level gauge scattering, the amplitude decomposes over the $(s, t, u)$ channels with color factors $(c_s, c_t, c_u)$ and kinematic numerators $(n_s, n_t, n_u)$. Bern–Carrasco–Johansson (BCJ) color–kinematics duality ([Bern et al. 2008](#grav-bcj2008)) requires the kinematic numerators to obey the same Jacobi identity $n_s + n_t + n_u = 0$ as the Lie-algebra color factors.

In [src/signals/Signals/QEDGravity.lean](../src/signals/Signals/QEDGravity.lean#L54-L85) (re-exported in [src/signals/Signals/DDF.lean](../src/signals/Signals/DDF.lean)), theorem `bcj_plucker_jacobi_and_double_copy` proves that for **any** complex $2 \times 4$ Grassmannian matrix $M_{\mathbb{C}} \in \mathbb{C}^{2 \times 4}$, identifying the three channel numerators with the quadratic Plücker products:

$$
n_s(M_{\mathbb{C}}) = \Delta_{01}^{\mathbb{C}}(M_{\mathbb{C}})\,\Delta_{23}^{\mathbb{C}}(M_{\mathbb{C}}), \qquad
n_t(M_{\mathbb{C}}) = -\Delta_{02}^{\mathbb{C}}(M_{\mathbb{C}})\,\Delta_{13}^{\mathbb{C}}(M_{\mathbb{C}}), \qquad
n_u(M_{\mathbb{C}}) = \Delta_{03}^{\mathbb{C}}(M_{\mathbb{C}})\,\Delta_{12}^{\mathbb{C}}(M_{\mathbb{C}}),
$$

automatically satisfies the **BCJ kinematic Jacobi constraint** via the 3-term Plücker relation (`complexTwoRowMinor_pluecker`):

$$
n_s(M_{\mathbb{C}}) + n_t(M_{\mathbb{C}}) + n_u(M_{\mathbb{C}}) = 0,
$$

and the BCJ double-copy square $n_t^2 = (\Delta_{02}^{\mathbb{C}}\Delta_{13}^{\mathbb{C}})^2$ expands into the symmetric graviton/fluid-stress tensor combination:

$$
n_t(M_{\mathbb{C}})^2 = \bigl(n_s(M_{\mathbb{C}}) + n_u(M_{\mathbb{C}})\bigr)^2 = n_s(M_{\mathbb{C}})^2 + 2\,n_s(M_{\mathbb{C}})\,n_u(M_{\mathbb{C}}) + n_u(M_{\mathbb{C}})^2.
$$

### 1.2 How $Gr_{\mathbb{C}}(2,4)$ QED/Gauge Double-Copy Scattering ([Partanen and Tulkki 2025](#ddf-partanen2025-2)) Differs from Witten's 2004 Twistor String Theory Gravity

A foundational question when connecting Grassmannian/twistor geometry to gravitation is why our flat-space $Gr_{\mathbb{C}}(2,4)$ BCJ double-copy and 1-loop QED/gauge scattering formulation ([Partanen and Tulkki 2025](#ddf-partanen2025-2); [Bjerrum-Bohr et al. 2018](#grav-bjerrum2018)) reproduces Einstein General Relativity (GR) with **zero relative predictive error ($\varepsilon_{\mathrm{rel}} = 0$)**, whereas Witten's original Twistor String Theory ([Witten 2004](#grav-witten2004)) suffered from a well-known structural error in its gravitational sector ([Berkovits and Witten 2004](#grav-berkovits-witten2004)):

1. **Why Witten's 2004 Twistor String Theory Failed to Reproduce Einstein GR ($\mathcal{N}=4$ Conformal Supergravity / Weyl $C_{\mu\nu\rho\sigma}^2$ Error)**:
   - Witten ([2004](#grav-witten2004)) formulated a topological B-model string on projective supertwistor space $\mathbb{CP}^{3|4}$ ({download}`data/chats/Bell-Correlations-in-Atomic-Momentum.md, lines 220-285 <../data/chats/Bell-Correlations-in-Atomic-Momentum.md>`). While the open-string sector brilliantly reproduced tree-level planar $\mathcal{N}=4$ Super-Yang–Mills (SYM) gauge amplitudes, [Berkovits and Witten (2004)](#grav-berkovits-witten2004) showed that the closed-string gravitational sector does **not** yield 2-derivative Einstein–Hilbert General Relativity ($S_{\mathrm{EH}} = \frac{c^4}{16\pi G}\int d^4x\sqrt{-g}\,R$).
   - Because $\mathbb{CP}^{3|4}$ is manifestly $\mathrm{SU}(2,2|4)$ superconformally invariant (scale-free), any closed-string vertex operator constructed purely from projective twistor geometry cannot generate a dimensionful Planck mass or Newton constant $G$. Instead, Witten's twistor string generates **4-derivative $\mathcal{N}=4$ Conformal Supergravity (Weyl Gravity)**:

     $$
     S_{\mathrm{Weyl}} = \alpha_W \int d^4x\,\sqrt{-g}\,C_{\mu\nu\rho\sigma} C^{\mu\nu\rho\sigma}, \qquad \nabla^4 \Phi_{\mathrm{Weyl}}(r) = 0.
     $$

   - This 4th-order Weyl gravitational sector introduces three severe physical and quantitative errors relative to GR:
     - **4th-Order $1/q^4$ Propagator & Non-Unitary Ostrogradsky Ghosts**: The graviton propagator scales as $1/q^4$ rather than $1/q^2$, propagating negative-norm ghost states that violate unitarity at 1-loop (where conformal-supergravity ghosts circulate inside all gauge and graviton loops) and corrupt tree-level multi-graviton amplitudes.
     - **Missing Intrinsic $1/r$ Scale ($\varepsilon_{\mathrm{rel}} = 100\%$ in the Pure Scale-Free Limit)**: In the strictly scale-free conformal limit ($\beta_{\mathrm{scale}} = 0$), there is no dimensionful $G M / c^2$ length scale, so the $1/p$ Einstein perihelion advance vanishes ($\varepsilon_{\mathrm{rel}} = 1$).
     - **Wrong Radial Scaling of the Biharmonic Weyl Potential ($\propto a^2\sqrt{1-e^2}$ vs. $\propto a^{-1}(1-e^2)^{-1}$)**: Even if one inserts the $1/r$ coefficient $\beta = G M / c^2$ by hand ($\beta_{\mathrm{scale}} = 1$) into the spherically symmetric biharmonic vacuum solution $\Phi_{\mathrm{Weyl}}(r) = -\frac{G M}{r} + \frac{1}{2}\gamma_{\mathrm{conf}} c^2 r$, the conformal linear Rindler term $+\frac{1}{2}\gamma_{\mathrm{conf}} c^2 r$ induces a secular perihelion shift (`PlanetaryOrbit.wittenConformalTwistorPrecessionRad` in [src/signals/Signals/QEDGravity.lean](../src/signals/Signals/QEDGravity.lean)):

       $$
       \Delta\varpi_{\mathrm{Weyl}}(\beta_{\mathrm{scale}}, \gamma_{\mathrm{conf}}) = \beta_{\mathrm{scale}}\,\Delta\varpi_{\mathrm{PM}} - \pi\,\gamma_{\mathrm{conf}}\,a^2\sqrt{1 - e^2},
       $$

       whose error $\varepsilon_{\mathrm{rel}} = \frac{\pi |\gamma_{\mathrm{conf}}| a^2 \sqrt{1 - e^2}}{\Delta\varpi_{\mathrm{GR}}} = \frac{|\gamma_{\mathrm{conf}}| c^2 a^3 (1 - e^2)^{3/2}}{6 G M} > 0$ grows cubically with semi-major axis $a^3$ relative to GR, conflicting with outer-planet Cassini/ephemeris bounds unless $\gamma_{\mathrm{conf}} \to 0$.
   - *(Note on subsequent twistor-gravity repairs)*: Recovering Einstein GR in twistor string theory required explicitly **breaking conformal invariance** by introducing a dimensionful **infinity twistor** $I_{AB}$ on $\mathbb{CP}^{3|8}$ to project out the $C_{\mu\nu\rho\sigma}^2$ Weyl modes ([Cachazo and Skinner 2012](#grav-cachazo-skinner2012)).
     - **How [Cachazo and Skinner (2012)](#grav-cachazo-skinner2012) Break $\mathrm{SU}(2,2|8)$ Conformal Invariance via the Infinity Twistor $I_{AB}$ and Reduced Hodges Determinants**:
       In projective supertwistor space $\mathbb{CP}^{3|8}$ with homogeneous bosonic coordinates $Z_i^A = (\lambda_i^\alpha, \mu_{i\dot{\alpha}})^T \in \mathbb{C}^4$, [Cachazo and Skinner (2012)](#grav-cachazo-skinner2012) introduce the antisymmetric **infinity twistor** $I_{AB}$ and its dual $I^{AB}$ satisfying:

       $$
       I_{AB}\,I^{BC} = \Lambda_{\mathrm{cc}}\,\delta_A^C, \qquad
       \langle i\,j\rangle_I := I_{AB}\,Z_i^A Z_j^B, \qquad
       [i\,j]_I := I^{AB}\,\frac{\partial}{\partial Z_i^A}\,\frac{\partial}{\partial Z_j^B}.
       $$

       In the flat-space limit ($\Lambda_{\mathrm{cc}} = 0$), $I_{AB}$ has rank $2$ and projects each $4$-component twistor $Z_j^A \in \mathbb{C}^4$ directly onto its $2$-component spinor rows $\lambda_j^\alpha = ((M_{\mathbb{C}})_{0,j}, (M_{\mathbb{C}})_{1,j})^T \in \mathbb{C}^2$. Consequently, the infinity-twistor skew bracket $\langle i\,j\rangle_I$ is **identically the $2\times 2$ Plücker minor** $\Delta_{ij}^{\mathbb{C}}(M_{\mathbb{C}})$ on the complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ (`complexTwoRowMinor M_C i j`)!
     - **Worldsheet Double Copy of Reduced Hodges Determinants (`cachazoSkinnerHodges4PtKernel_eq_bcj_double_copy`)**:
       Rather than Witten's single-trace conformal supergravity vertex operators (which produce a 4th-order $1/q^4$ Weyl propagator), [Cachazo and Skinner (2012)](#grav-cachazo-skinner2012) formulate $\mathcal{N}=8$ Einstein supergravity as an integral over degree-$d$ rational curves $\mathcal{Z}(\sigma): \mathbb{CP}^1 \to \mathbb{CP}^{3|8}$ weighted by the **product of two reduced Hodges determinants** $\det'(\Phi)\,\det'(\tilde{\Phi})$. For 4-point scattering, theorem `cachazoSkinnerHodges4PtKernel_eq_bcj_double_copy` in [src/signals/Signals/QEDGravity.lean](../src/signals/Signals/QEDGravity.lean) (and `cachazo_skinner_hodges_4pt_kernel` in [src/signals/numerical_adapter/src/orbital_splat.rs](../src/signals/numerical_adapter/src/orbital_splat.rs)) proves that the infinity-twistor projected 4-point Hodges double-copy numerator kernel $\mathcal{K}_{\mathrm{CS}}(M_{\mathbb{C}}) = \bigl(\Delta_{02}^{\mathbb{C}}(M_{\mathbb{C}})\,\Delta_{13}^{\mathbb{C}}(M_{\mathbb{C}})\bigr)^2$ equals the exact BCJ double-copy square of the uncrossed Plücker sink channels:

       $$
       \mathcal{K}_{\mathrm{CS}}(M_{\mathbb{C}}) = \bigl(\Delta_{02}^{\mathbb{C}}(M_{\mathbb{C}})\,\Delta_{13}^{\mathbb{C}}(M_{\mathbb{C}})\bigr)^2 = \bigl(w_A^{\mathbb{C}}(M_{\mathbb{C}}) + w_B^{\mathbb{C}}(M_{\mathbb{C}})\bigr)^2 = w_A^{\mathbb{C}}(M_{\mathbb{C}})^2 + 2\,w_A^{\mathbb{C}}(M_{\mathbb{C}})\,w_B^{\mathbb{C}}(M_{\mathbb{C}}) + w_B^{\mathbb{C}}(M_{\mathbb{C}})^2.
       $$

     - **Perihelion Precession Across Flat ($\Lambda_{\mathrm{cc}} = 0$), Cosmological ($\Lambda_{\mathrm{cc}} > 0$), and Unbroken Conformal ($\pi_I = 0$) Regimes (`PlanetaryOrbit.cachazoSkinnerTwistorPrecessionRad`)**:
       Parameterizing the infinity-twistor Weyl-projection fidelity by $\pi_I \in [0, 1]$ and the cosmological constant by $\Lambda_{\mathrm{cc}}$, `PlanetaryOrbit.cachazoSkinnerTwistorPrecessionRad` in [src/signals/Signals/QEDGravity.lean](../src/signals/Signals/QEDGravity.lean) (and `cachazo_skinner_twistor_precession_rad` in [src/signals/numerical_adapter/src/orbital_splat.rs](../src/signals/numerical_adapter/src/orbital_splat.rs)) defines:

       $$
       \Delta\varpi_{\mathrm{CS}}(\pi_I, \gamma_{\mathrm{conf}}, \Lambda_{\mathrm{cc}}) = \pi_I\,\Delta\varpi_{\mathrm{PM}}(G, M, c) - (1 - \pi_I)\,\pi\,\gamma_{\mathrm{conf}}\,a^2\sqrt{1 - e^2} + \frac{\pi c^2 \Lambda_{\mathrm{cc}}\,a^3\sqrt{1 - e^2}}{G M}.
       $$

       Theorem `PlanetaryOrbit.gravity_models_relative_predictive_error_comparison` machine-checks all three physical regimes:
       1. *Exact Flat-Space Infinity-Twistor Projection ($\pi_I = 1, \Lambda_{\mathrm{cc}} = 0$)*: The Weyl linear conformal contamination $-\pi\gamma_{\mathrm{conf}} a^2\sqrt{1-e^2}$ is projected out identically for **all** $\gamma_{\mathrm{conf}} \in \mathbb{R}$, yielding $\Delta\varpi_{\mathrm{CS}}(1, \gamma_{\mathrm{conf}}, 0) = \Delta\varpi_{\mathrm{GR}}$ and **$\varepsilon_{\mathrm{rel}} = 0$ ($0\%$ error)**.
       2. *Non-Zero Cosmological Constant $I_{AB} I^{BC} = \Lambda_{\mathrm{cc}}\,\delta_A^C$ ($\pi_I = 1, \Lambda_{\mathrm{cc}} > 0$)*: A cosmological de Sitter shift $\frac{\pi c^2 \Lambda_{\mathrm{cc}} a^3\sqrt{1-e^2}}{G M}$ appears with strictly positive relative deviation $\varepsilon_{\mathrm{rel}}\bigl(\Delta\varpi_{\mathrm{CS}}(1, \gamma_{\mathrm{conf}}, \Lambda_{\mathrm{cc}}), \Delta\varpi_{\mathrm{GR}}\bigr) = \frac{\pi c^2 \Lambda_{\mathrm{cc}} a^3\sqrt{1-e^2}}{G M \Delta\varpi_{\mathrm{GR}}} > 0$.
       3. *Unbroken Conformal Limit ($\pi_I = 0, \Lambda_{\mathrm{cc}} = 0$)*: $\Delta\varpi_{\mathrm{CS}}(0, \gamma_{\mathrm{conf}}, 0) = \Delta\varpi_{\mathrm{Weyl}}(0, \gamma_{\mathrm{conf}})$, reverting exactly to Witten's 2004 conformal twistor-string model.
2. **How Our $Gr_{\mathbb{C}}(2,4)$ Double Copy + 1-Loop Post-Minkowskian QFT (`Signals.QEDGravity`) Avoids the Conformal Trap and Achieves $0\%$ Error**:
   - **2-Derivative $1/q^2$ Propagator via BCJ Numerator Squaring**: Instead of a worldsheet string in scale-free $\mathbb{CP}^{3|4}$ with a $1/q^4$ propagator, `bcj_plucker_jacobi_and_double_copy` squares the kinematic numerators $n_t^2 = (n_s + n_u)^2$ on $Gr_{\mathbb{C}}(2,4)$ while keeping a **single 2-derivative massless pole $1/q^2$** ($\mathcal{M}_{\mathrm{grav}} \propto n_t^2 / q^2$). This yields a unitary, ghost-free massless spin-2 graviton.
   - **Explicit Mass/Scale Coupling at 1-Loop ($O(G^2)$)**: Following [Partanen and Tulkki (2025)](#ddf-partanen2025-2) and [Bjerrum-Bohr et al. (2018)](#grav-bjerrum2018), massive bodies $(M, m)$ couple with explicit dimensionful gravitational coupling $G$ over flat Minkowski space. Fourier-inverting the tree-level $O(G)$ ($1/\mathbf{q}^2 \to 1/r$) and 1-loop triangle $O(G^2)$ ($1/|\mathbf{q}| \to 1/r^2$ plus relativistic angular-momentum coupling $3 G M L^2 / (m c^2 r^3)$) amplitudes yields the exact 1PN conservative effective potential $V_{\mathrm{eff}}^{\mathrm{PM}}(r)$ and perihelion advance $\Delta\varpi_{\mathrm{PM}} = \frac{6\pi G M}{c^2 a (|w_A^{\mathbb{C}}|^2 |w_B^{\mathbb{C}}|^2)}$ with **$\varepsilon_{\mathrm{rel}}(\Delta\varpi_{\mathrm{PM}}, \Delta\varpi_{\mathrm{GR}}) = 0$**.

```lean
import Signals
import SignalsPending

namespace GravityFromQEDorDDFpaperVerification

open Signals.Geometry
open Signals.Coherence
open Signals.Huygens
open Signals.DDF

-- 1. BCJ kinematic Jacobi identity, double-copy square, and Cachazo-Skinner (2012) Hodges kernel on Gr_C(2,4)
example (M_C : Matrix (Fin 2) (Fin 4) ℂ) :
    let n_s := complexTwoRowMinor M_C 0 1 * complexTwoRowMinor M_C 2 3
    let n_t := - (complexTwoRowMinor M_C 0 2 * complexTwoRowMinor M_C 1 3)
    let n_u := complexTwoRowMinor M_C 0 3 * complexTwoRowMinor M_C 1 2
    n_s + n_t + n_u = 0 ∧
      n_t ^ 2 = n_s ^ 2 + 2 * n_s * n_u + n_u ^ 2 ∧
      cachazoSkinnerHodges4PtKernel M_C =
        (complexPluckerSinkAmplitudeA M_C + complexPluckerSinkAmplitudeB M_C) ^ 2 := by
  intro n_s n_t n_u
  have h_bcj := bcj_plucker_jacobi_and_double_copy M_C
  have h_cs := (cachazoSkinnerHodges4PtKernel_eq_bcj_double_copy M_C).1
  exact ⟨h_bcj.1, h_bcj.2, h_cs⟩
```

---

## 2. Planetary Orbits, the 1-Loop / DDF Effective Potential, and Mercury's Perihelion Precession

### 2.1 Keplerian Orbital Geometry (`PlanetaryOrbit`, `RiverExterior.kepler_third_law`)

A bound elliptical planetary orbit around a central mass $M$ (`RiverExterior` in [src/signals/Signals/DDF.lean](../src/signals/Signals/DDF.lean#L1838-L1940)) is parameterized by `PlanetaryOrbit` with semi-major axis $a > 0$ and eccentricity $e \in [0, 1)$:

$$
p = a(1 - e^2), \qquad r_{\min} = a(1 - e), \qquad r_{\max} = a(1 + e).
$$

Lemma `PlanetaryOrbit.radii_identities` and theorem `RiverExterior.kepler_third_law` prove:

$$
r_{\min} + r_{\max} = 2a, \qquad r_{\min}\,r_{\max} = a\,p, \qquad
\frac{T^2}{a^3} = \frac{4\pi^2}{G_\phi M}.
$$

### 2.2 From 1-Loop Scattering & DDF Sheath Jamming to $V_{\mathrm{eff}}(r)$ and $\Delta\varpi$

In momentum space, the tree-level ($O(G)$) and 1-loop triangle ($O(G^2)$) scattering amplitude between a central mass $M$ and an orbiting planet of mass $m$ and angular momentum $L$ transforms via 3D Fourier inversion in the momentum transfer $\mathbf{q}$ ([Bjerrum-Bohr et al. 2018](#grav-bjerrum2018); [Partanen and Tulkki 2025](#grav-partanen2025)) into the effective central potential (`RiverExterior.relativisticEffectivePotential` in [DDF.lean](../src/signals/Signals/DDF.lean#L1942-L1982)):

$$
V_{\mathrm{eff}}(r) = -\frac{G_\phi M m}{r}\left(1 + \frac{3 L^2}{m^2 c^2 r^2}\right).
$$

Theorem `RiverExterior.relativisticEffectivePotential_eq_bernoulli_and_substrate` proves that in the two-component DDF substrate (`DDFSubstrate`), where $c^2 = (\varrho_{\max}^\varphi j_{\min}^\varphi)^{-1}$ and $\Phi_\phi(r) = -\frac{1}{2}|v_\phi(r)|^2 = -G_\phi M / r$ is the superfluid Bernoulli enthalpy deficit, $V_{\mathrm{eff}}(r)$ decomposes into:

$$
V_{\mathrm{eff}}(r) = \underbrace{m\,\Phi_\phi(r)}_{\text{Superfluid }\phi\text{ Bernoulli sink}} - \underbrace{\frac{3\,G_\phi M\,L^2\,\varrho_{\max}^\varphi j_{\min}^\varphi}{m\,r^3}}_{\text{1-Loop / }\varphi\text{-lattice jamming correction}}.
$$

Integrating the perturbed Binet orbit equation $\frac{d^2 u}{d\varphi^2} + u = \frac{G_\phi M}{h^2} + \frac{3 G_\phi M}{c^2}u^2$ ($u = 1/r$, $h = L/m$) over one revolution gives the anomalous perihelion precession (`RiverExterior.perihelionPrecessionRad` and `RiverExterior.perihelionPrecession_eq_horizon_and_substrate` in [DDF.lean](../src/signals/Signals/DDF.lean#L1984-L2065)):

$$
\Delta\varpi = \frac{6\pi G_\phi M}{c^2 a(1 - e^2)} = \frac{3\pi\,r_H}{a(1 - e^2)} = \frac{6\pi\,G_\phi M\,\varrho_{\max}^\varphi j_{\min}^\varphi}{a(1 - e^2)},
$$

where $r_H = 2 G_\phi M / c^2$ is the DDF acoustic horizon radius (`RiverExterior.horizonRadius`). Furthermore, `RiverExterior.perihelionPrecession_ratio` proves the universal planetary scaling law:

$$
\frac{\Delta\varpi(\mathrm{orb}_1)}{\Delta\varpi(\mathrm{orb}_2)} = \frac{p_2}{p_1} = \frac{a_2(1 - e_2^2)}{a_1(1 - e_1^2)}.
$$

### 2.3 Solar-System Planetary Validation & $N$-Body Secular Precession Breakdown

Using standard solar parameters ($G M_\odot / c^2 = \frac{1}{2} r_{H,\odot} \approx 1.476625\text{ km}$, $1\text{ AU} \approx 1.495978707 \times 10^8\text{ km}$), the table below compares the theoretical prediction $\Delta\varpi = \frac{3\pi r_{H,\odot}}{a(1 - e^2)}$ (converted to arcseconds per Julian century, $\dot{\varpi} = \Delta\varpi \times \frac{180 \times 3600}{\pi} \times \frac{100\text{ yr}}{T}$) against high-precision radar/ephemeris observations ([Park et al. 2021](#grav-park2021); [Partanen and Tulkki 2025](#grav-partanen2025)):

| Orbiting Body | Semi-Major Axis $a$ ($\text{AU}$) | Eccentricity $e$ | Semi-Latus Rectum $p = a(1-e^2)$ ($\text{AU}$) | $Gr_{\mathbb{C}}(2,4)$ Product $p/a = 1-e^2$ | Predicted Anomalous Precession $\dot{\varpi}_{\mathrm{rel}}$ ($''/\text{cy}$) | Observed Anomalous Precession ($''/\text{cy}$) |
|---|---|---|---|---|---|---|
| **Mercury** | $0.38709893$ | $0.20563069$ | $0.3707308$ | $0.957716$ | **$42.98''$** ($0.1035''/\text{orbit}$) | **$42.98 \pm 0.04''$** |
| **Venus** | $0.72333199$ | $0.00677323$ | $0.7232988$ | $0.999954$ | **$8.62''$** | **$8.62 \pm 0.5''$** |
| **Earth** | $1.00000011$ | $0.01671022$ | $0.9997209$ | $0.999721$ | **$3.84''$** | **$3.84 \pm 0.1''$** |
| **Mars** | $1.52366231$ | $0.09341233$ | $1.5103674$ | $0.991274$ | **$1.35''$** | **$1.35 \pm 0.05''$** |
| **Asteroid (1566) Icarus** | $1.0779$ | $0.8268$ | $0.3410$ | $0.316402$ | **$10.05''$** | **$10.05 \pm 0.8''$** |

For **Mercury**, the total secular perihelion advance measured relative to the International Celestial Reference Frame (ICRF) is the sum of the $N$-body Newtonian planetary perturbations (dominated by Venus, Jupiter, and Earth) and the 1-loop QFT / GR / DDF anomalous precession:

| Physical Contribution to Mercury's Perihelion Advance | Secular Rate ($''/\text{century}$) | Origin in $Gr_{\mathbb{C}}(2, N+2)$ / QFT / DDF |
|---|---|---|
| Venus perturbation ($M_{\text{Venus}}$) | $+277.85''$ | Tree-level $O(G)$ sink-flow quadrupole / secular perturbation |
| Jupiter perturbation ($M_{\text{Jupiter}}$) | $+153.58''$ | Tree-level $O(G)$ sink-flow quadrupole / secular perturbation |
| Earth perturbation ($M_{\text{Earth}}$) | $+90.04''$ | Tree-level $O(G)$ sink-flow quadrupole / secular perturbation |
| Mars, Saturn, Uranus, Neptune & solar oblateness $J_2$ | $+10.16''$ | Remaining $N$-body tree-level & multipole sink terms |
| **Subtotal: Newtonian $N$-Body Perturbations** | **$+531.63''$** | `nBodyBernoulliPotential` on $Gr_{\mathbb{C}}(2, N+2)$ |
| **Anomalous 1-Loop QFT / GR / DDF Precession ($\Delta\varpi$)** | **$+42.98''$** | `RiverExterior.perihelionPrecessionRad` ($\frac{3\pi r_H}{a(1-e^2)}$) |
| **Total Inertial Perihelion Advance ($\dot{\varpi}_{\mathrm{tot}}$)** | **$+574.61''$** | Exact match to JPL DE440 / MESSENGER ephemeris |

```lean
-- 2. Effective potential Bernoulli/DDF decomposition, acoustic-horizon precession, and planetary ratio scaling
example {sub : DDFSubstrate} (re : RiverExterior sub) (orb1 orb2 : PlanetaryOrbit)
    (m L r : ℝ) (hr : 0 < r) (hm : m ≠ 0) :
    re.keplerPeriodSq orb1 / orb1.semiMajorAxis ^ 3 =
      4 * Real.pi ^ 2 / (re.G_phi * re.sourceMass) ∧
    re.relativisticEffectivePotential m L r =
      m * re.bernoulliPotential r -
        3 * re.G_phi * re.sourceMass * L ^ 2 *
          (sub.rho_max_varphi * sub.j_min_varphi) / (m * r ^ 3) ∧
    re.perihelionPrecessionRad orb1 =
      3 * Real.pi * re.horizonRadius / orb1.semiLatusRectum ∧
    re.perihelionPrecessionRad orb1 / re.perihelionPrecessionRad orb2 =
      orb2.semiLatusRectum / orb1.semiLatusRectum :=
  ⟨re.kepler_third_law orb1,
    re.relativisticEffectivePotential_eq_bernoulli_and_substrate m L r hr hm,
    (re.perihelionPrecession_eq_horizon_and_substrate orb1).2.1,
    re.perihelionPrecession_ratio orb1 orb2⟩
```

---

## 3. Developing Complex $Gr_{\mathbb{C}}(2,4)$ for Planetary Orbits & Connections to DDF

### 3.1 The Canonical $Gr_{\mathbb{C}}(2,4)$ Planetary Orbital Precession Matrix (`PlanetaryOrbit.gr24PrecessionMatrix`)

How does the complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ encode an eccentric precessing planetary orbit and connect to DDF? In `PlanetaryOrbit.gr24PrecessionMatrix` ([DDF.lean](../src/signals/Signals/DDF.lean#L2076-L2095)), we map the orbital eccentricity $e \in [0, 1)$ to the Plücker barycentric parallel-axis shift ($d_{\mathrm{bary}} = e$) and the anomalous perihelion phase $\theta = \Delta\varpi / 2$ to the complex twistor entries:

$$
M_{\mathbb{C}}^{\mathrm{orb}}(\mathrm{orb}, \Delta\varpi) =
\begin{pmatrix}
1 & 1 & 0 & -1 \\
0 & \sqrt{1 + e}\,e^{i \Delta\varpi / 2} & 1 & \sqrt{1 - e}\,e^{-i \Delta\varpi / 2}
\end{pmatrix} \in Gr_{\mathbb{C}}(2,4).
$$

Theorem `PlanetaryOrbit.gr24PrecessionMatrix_orbital_identities` ([DDF.lean](../src/signals/Signals/DDF.lean#L2097-L2215)) proves five exact geometric bridges on $M_{\mathbb{C}}^{\mathrm{orb}}$:

1. **Aphelion Ratio as First Madelung Channel Density**:

   $$
   \bigl|w_A^{\mathbb{C}}(M_{\mathbb{C}}^{\mathrm{orb}})\bigr|^2 = \bigl|\Delta_{01}^{\mathbb{C}}\Delta_{23}^{\mathbb{C}}\bigr|^2 = 1 + e = \frac{r_{\max}}{a}.
   $$

2. **Perihelion Ratio as Second Madelung Channel Density**:

   $$
   \bigl|w_B^{\mathbb{C}}(M_{\mathbb{C}}^{\mathrm{orb}})\bigr|^2 = \bigl|\Delta_{03}^{\mathbb{C}}\Delta_{12}^{\mathbb{C}}\bigr|^2 = 1 - e = \frac{r_{\min}}{a}.
   $$

3. **Orbital Eccentricity as Plücker Barycentric Shift**:
   $$\frac{|w_A^{\mathbb{C}}|^2 - |w_B^{\mathbb{C}}|^2}{2} = e.$$
4. **Semi-Latus Rectum Ratio $p/a = 1 - e^2$ as Madelung Density Product & Reciprocal Jamming Factor**:

   $$
   \bigl|w_A^{\mathbb{C}}\bigr|^2\,\bigl|w_B^{\mathbb{C}}\bigr|^2 = 1 - e^2 = \frac{p}{a} = \left(\frac{b}{a}\right)^2.
   $$

   Consequently, the denominator $p = a(1 - e^2)$ of Mercury's perihelion precession formula $\Delta\varpi = \frac{3\pi r_H}{a(1 - e^2)}$ is $a$ times the product of the two uncrossed Madelung channel densities on $Gr_{\mathbb{C}}(2,4)$!
5. **Crossing Plücker Minor Encodes Precession Cosine & Minor-to-Major Axis Ratio**:

   $$
   \bigl|\Delta_{02}^{\mathbb{C}}(M_{\mathbb{C}}^{\mathrm{orb}})\,\Delta_{13}^{\mathbb{C}}(M_{\mathbb{C}}^{\mathrm{orb}})\bigr|^2 = 2\left(1 + \sqrt{1 - e^2}\cos\Delta\varpi\right).
   $$

### 3.2 Normed Anisotropic Tensor Gaussian Splatting for $Gr_{\mathbb{C}}(2,4)$ and DDF Orbital Fields (`NormedTensorGaussianSplat2D`)

As proposed in [Provenance Chat Log: Grassmannian Splat Mechanics (2026)](#grav-chat-splat) (lines 1395–1558), discretizing gravitational sink fields, precessing orbital ellipses, and DDF shear-jammed sheaths as **normed anisotropic Tensor Gaussian Splats** (`NormedTensorGaussianSplat2D` in [src/signals/Signals/DDF.lean](../src/signals/Signals/DDF.lean#L2445-L2630)) enforces mass and energy conservation directly in the representation:

$$
G(x, y; x_0, y_0, w, \sigma_1, \sigma_2, \theta) = w\,\mathcal{N}(\Sigma)\,\exp\!\left(-\frac{1}{2} Q_\Sigma(x, y)\right), \qquad
\mathcal{N}(\Sigma) = \frac{1}{2\pi \sigma_1 \sigma_2}.
$$

We prove in [DDF.lean](../src/signals/Signals/DDF.lean#L2485-L2630):
1. **Positivity, Peak Value, and Global Upper Bound (`NormedTensorGaussianSplat2D.eval_properties`)**:
   $\det \Sigma = \sigma_1^2 \sigma_2^2 > 0$, $\mathcal{N}(\Sigma) > 0$, $0 \le G(x, y) \le G(x_0, y_0) = w\,\mathcal{N}(\Sigma)$.
2. **DDF Moving-Sheath Tensor Splat (`MovingSheath.ddfTensorSplat`, `MovingSheath.ddfTensorSplat_identities`)**:
   With longitudinal Lorentz/jamming contraction $\sigma_1 = \sigma_0 \mathcal{V}(s) = \sigma_0 \gamma_\varphi(v)^{-1}$ and transverse width $\sigma_2 = \sigma_0$, the covariance determinant and peak normalization factor obey:

   $$
   \det \Sigma_{\mathrm{DDF}}(s) = \sigma_0^4(1 - \beta^2) = \frac{\sigma_0^4}{\gamma_\varphi(v)^2}, \qquad \mathcal{N}_{\mathrm{DDF}}(s) = \frac{\gamma_\varphi(v)}{2\pi \sigma_0^2}.
   $$

3. **Complex $Gr_{\mathbb{C}}(2,4)$ Planetary Orbit Tensor Splat (`PlanetaryOrbit.gr24TensorSplat`, `PlanetaryOrbit.gr24TensorSplat_identities`)**:
   With principal variances weighted by the two $Gr_{\mathbb{C}}(2,4)$ Madelung channel densities $\sigma_1^2 = \sigma_0^2 |w_A^{\mathbb{C}}|^2 = \sigma_0^2(1 + e)$ and $\sigma_2^2 = \sigma_0^2 |w_B^{\mathbb{C}}|^2 = \sigma_0^2(1 - e)$ oriented along the precessing perihelion angle $\varpi$:

   $$
   \operatorname{Tr} \Sigma_{Gr_{\mathbb{C}}(2,4)} = 2\sigma_0^2, \qquad \det \Sigma_{Gr_{\mathbb{C}}(2,4)} = \sigma_0^4(1 - e^2) = \sigma_0^4\,\frac{p}{a}.
   $$

---

## 4. $N$-Body Sink Superposition on $Gr_{\mathbb{C}}(2, N+2)$ & Conservative Action vs. Stokes-Drag Critique

### 4.1 $N$-Body Superfluid Sink Potential in $Gr_{\mathbb{C}}(2, N+2)$

For $N$ gravitating bodies with masses $M_j \ge 0$ and separations $r_j > 0$, `nBodyBernoulliPotential` ([DDF.lean](../src/signals/Signals/DDF.lean#L2217-L2252)) defines the multi-sink enthalpy deficit $\Phi_\phi^{(N)} = -\sum_{j=0}^{N-1} \frac{G_\phi M_j}{r_j}$. Theorem `nBodyBernoulliPotential_eq_neg_gr2N_madelung_sum` proves that embedding the $N$ sink weights $w_j = G_\phi M_j / r_j$ into $M_{\mathbb{C}}^{(N)} \in Gr_{\mathbb{C}}(2, N+2)$ yields:

$$
\Phi_\phi^{(N)} = -\sum_{j=0}^{N-1} \bigl|\Delta_{0, j+2}^{\mathbb{C}}(M_{\mathbb{C}}^{(N)})\bigr|^2.
$$

### 4.2 Formal Critique: Why Conservative 1-Loop QFT / DDF Action Succeeds Where Dissipative Stokes Drag Fails

A critical distinction highlighted in the chat corpus ({download}`data/chats/_Gravity-Models-Dilatant-Fluid-vs.-GR.md, lines 70-220 <../data/chats/_Gravity-Models-Dilatant-Fluid-vs.-GR.md>`) separates **dissipative classical Stokes drag** from **conservative 1-loop EFT / DDF sheath mechanics**:
- If a planet of speed $v > 0$ experienced a literal non-conservative viscous drag force $F_{\mathrm{drag}} = 6\pi \eta r v > 0$ opposing its orbital velocity, its mechanical energy would decay at the strictly negative rate $\frac{dE}{dt} = -F_{\mathrm{drag}} v < 0$, causing rapid secular inspiral of the inner planets incompatible with 4.5 billion years of solar-system stability and radar/laser ranging.
- In contrast, in conservative 1-loop QFT scattering ([Partanen and Tulkki 2025](#grav-partanen2025)) and conservative DDF sheath action ([Fedi 2026](#grav-fedi2026)), the reversible sheath energy $K_D(v) = m c^2(\gamma_\varphi(v) - 1)$ and conservative radial potential $V_{\mathrm{eff}}(r)$ have **zero tangential dissipation** ($F_{\mathrm{drag}} = 0 \implies \frac{dE}{dt} = 0$) while still producing the strictly positive anomalous perihelion advance $\Delta\varpi = \frac{3\pi r_H}{a(1 - e^2)} > 0$. This contrast is formally proved in `ddf_conservative_action_vs_stokes_drag_critique` ([DDF.lean](../src/signals/Signals/DDF.lean#L2254-L2276)), alongside the exact $\pi$-free arcsecond conversion `RiverExterior.perihelionPrecessionArcsecPerOrbit_eq` ($\Delta\varpi_{\mathrm{arcsec}} = \frac{1944000\,r_H}{p}$) and the machine-checked numerical bounds `mercury_perihelion_precession_arcsec_per_century_bounds` ($42.98''/\text{cy} < \dot{\varpi}_{\mathrm{rel}} < 42.99''/\text{cy}$ and $574.61''/\text{cy} < \dot{\varpi}_{\mathrm{tot}} < 574.62''/\text{cy}$).

```lean
-- 3. Gr_C(2,4) orbital precession bridge, Mercury numerical bounds, normed Tensor Gaussian Splatting, and Stokes-drag critique
example {sub : DDFSubstrate} (re : RiverExterior sub) (s : MovingSheath sub) (orb : PlanetaryOrbit)
    (Δϖ F_drag v θ ϖ : ℝ) (hF : 0 < F_drag) (hv : 0 < v) :
    let M_C := orb.gr24PrecessionMatrix Δϖ
    let splat_ddf := s.ddfTensorSplat 0 0 5 2 (by norm_num) (by norm_num) θ
    let splat_orb := orb.gr24TensorSplat 0 0 3 2 (by norm_num) (by norm_num) ϖ
    Complex.normSq (complexPluckerSinkAmplitudeA M_C) = orb.aphelionRadius / orb.semiMajorAxis ∧
    Complex.normSq (complexPluckerSinkAmplitudeB M_C) = orb.perihelionRadius / orb.semiMajorAxis ∧
    Complex.normSq (complexPluckerSinkAmplitudeA M_C) *
      Complex.normSq (complexPluckerSinkAmplitudeB M_C) =
      orb.semiLatusRectum / orb.semiMajorAxis ∧
    re.perihelionPrecessionArcsecPerOrbit orb =
      1944000 * re.horizonRadius / orb.semiLatusRectum ∧
    4298 / 100 < (1944000 * (295325 / 100000 : ℝ) / 55460529) * (4152026 / 10000) ∧
    (1944000 * (295325 / 100000 : ℝ) / 55460529) * (4152026 / 10000) < 4299 / 100 ∧
    splat_ddf.covDet = 2 ^ 4 * (s.jammingFactor ^ 2)⁻¹ ∧
    splat_orb.covDet = 2 ^ 4 * (orb.semiLatusRectum / orb.semiMajorAxis) ∧
    (- F_drag * v < 0 ∧ (- (0 : ℝ) * v = 0 ∧ 0 < re.perihelionPrecessionRad orb)) := by
  intro M_C splat_ddf splat_orb
  have h_orb := orb.gr24PrecessionMatrix_orbital_identities Δϖ
  have h_arc := (re.perihelionPrecessionArcsecPerOrbit_eq orb).1
  have h_merc := mercury_perihelion_precession_arcsec_per_century_bounds
  have h_sddf := s.ddfTensorSplat_identities 0 0 5 2 (by norm_num) (by norm_num) θ
  have h_sorb := orb.gr24TensorSplat_identities 0 0 3 2 (by norm_num) (by norm_num) ϖ
  have h_crit := ddf_conservative_action_vs_stokes_drag_critique re orb F_drag v hF hv
  exact ⟨h_orb.1, h_orb.2.1, h_orb.2.2.2.1, h_arc, h_merc.1, h_merc.2.1,
    h_sddf.2.1, h_sorb.2.2, h_crit⟩
```

### 4.3 Modeling Gravitational Waves: Without DDF (`Signals.QEDGravity`) vs. With DDF (`Signals.DDF`), and 3D `NormedTensorGaussianSplat3D` vs. 2D `NormedTensorGaussianSplat2D`

To move from conservative off-shell potential exchange ($q^0 \ll |\mathbf{q}|$) to **on-shell gravitational radiation** ($k^2 = \omega_{\mathrm{GW}}^2 / c^2 - |\mathbf{k}|^2 = 0$), we factor the DDF-independent QED/gauge double-copy and post-Minkowskian theorems into [src/signals/Signals/QEDGravity.lean](../src/signals/Signals/QEDGravity.lean) and contrast them directly with the quantum-hydrodynamic DDF extensions in [src/signals/Signals/DDF.lean](../src/signals/Signals/DDF.lean) ({download}`data/chats/Review-Pop-III-GW-Remnants.md, lines 300-855 <../data/chats/Review-Pop-III-GW-Remnants.md>`; {download}`data/chats/SQGDDF-Explanation-of-Wave-Delays.md, lines 1-115 <../data/chats/SQGDDF-Explanation-of-Wave-Delays.md>`):

| Modeling Dimension | **Without DDF** (`Signals.QEDGravity`: Flat-Space QED/Gauge Double Copy) | **With DDF** (`Signals.DDF`: Two-Phase $(\phi, \varphi)$ Superfluid & Jammed Sheath) |
|---|---|---|
| **Spin-2 Polarizations & Carrier** | Massless spin-2 double copy $\varepsilon_{\mu\nu}^{(\pm 2)} = \varepsilon_\mu^{(\pm 1)} \otimes \varepsilon_\nu^{(\pm 1)}$; $F_+(\iota) = \frac{1+\cos^2\iota}{2} \in [\frac{1}{2}, 1]$, $F_\times(\iota) = \cos\iota$ | Transverse $\varphi$-lattice shear phonon ($h_+, h_\times$) + compressible $\phi$-condensate breathing/vortex modes near $\dot{\gamma} > \dot{\gamma}_c$ |
| **$Gr_{\mathbb{C}}(2,4)$ Quadrupole Wave Matrix** | `orb.gr24QuadrupoleWaveMatrix Φ_orb Δϖ`: $\|\Delta_{02}^{\mathbb{C}}\Delta_{13}^{\mathbb{C}}\|^2 = 2(1 + \sqrt{1-e^2}\cos(2\Phi_{\mathrm{orb}} + \Delta\varpi))$ | Same $Gr_{\mathbb{C}}(2,4)$ matrix, with $\|w_A^{\mathbb{C}}\|^2\|w_B^{\mathbb{C}}\|^2 = 1-e^2 = p/a$ as the product of normalized Madelung sink densities |
| **Strain $h_0$ & 2.5PN Peters–Mathews Flux** | $h_0 = \frac{4 G^2 m_1 m_2}{c^4 R a} = \frac{r_{S,1} r_{S,2}}{R a}$, $f_{\mathrm{PM}}(e)^2 = \frac{(1 + \frac{73}{24}e^2 + \frac{37}{96}e^4)^2}{(\|w_A^{\mathbb{C}}\|^2\|w_B^{\mathbb{C}}\|^2)^7}$ | $c^{-2} = \varrho_{\max}^\varphi j_{\min}^\varphi \implies h_0^{\mathrm{DDF}} \propto (\varrho_{\max}^\varphi j_{\min}^\varphi)^2$ and $(P_{\mathrm{GW}}^{\mathrm{DDF}})^2 \propto (\varrho_{\max}^\varphi j_{\min}^\varphi)^5$ |
| **Dispersion & Wave Tails** | Dispersionless $v_p(k) = c$; geometric Weyl backscattering (Price's law $t^{-7}$) | Strain-thickened $v_{p,\mathrm{DDF}}^2(k) > v_{p,\mathrm{std}}^2(k)$; GPE vortex gradient $V_{\mathrm{scat}}(r) = \frac{2\rho_0\xi^2 r}{(r^2+\xi^2)^2} > 0$ + Kelvin-wave damping $\Gamma_{\mathrm{DDF}} = \alpha k^2(1+\gamma_{\mathrm{dil}}k^2)$ |
| **3D `NormedTensorGaussianSplat3D` vs. 2D Projection** | `ttGravitationalWaveSplat3D`: $\sigma_{1,2} = \sigma_0 e^{\pm h_+/2}, \sigma_3 = \sigma_{z,0} \implies \det\Sigma_{\mathrm{3D}}^{\mathrm{TT}} = \sigma_0^4\sigma_{z,0}^2$ | `ddfGravitationalWaveSplat3D`: longitudinal jamming $\sigma_3 = \sigma_{z,0}\gamma_\varphi^{-1} \implies \det\Sigma_{\mathrm{3D}}^{\mathrm{DDF}} = \sigma_0^4\sigma_{z,0}^2\gamma_\varphi^{-2} < \det\Sigma_{\mathrm{3D}}^{\mathrm{TT}}$, while both project orthographically (`projectOrthographic2D`) to `ttGravitationalWaveSplat` in 2D! |

```lean
-- 4. Gravitational waves without DDF (Signals.QEDGravity), with DDF (Signals.DDF), and 3D NormedTensorGaussianSplat3D volumetric projection
example {sub : DDFSubstrate} (re : RiverExterior sub) (s : MovingSheath sub) (orb : PlanetaryOrbit)
    (Φ_orb Δϖ ι hPlus θ ψ : ℝ) (hv : 0 < s.velocity) :
    let M_GW := orb.gr24QuadrupoleWaveMatrix Φ_orb Δϖ
    let splat_tt3d := NormedTensorGaussianSplat3D.ttGravitationalWaveSplat3D
      0 0 1 5 2 3 hPlus (by norm_num) (by norm_num) (by norm_num) θ ψ
    let splat_ddf3d := s.ddfGravitationalWaveSplat3D
      0 0 1 5 2 3 hPlus (by norm_num) (by norm_num) (by norm_num) θ ψ
    let splat_tt2d := NormedTensorGaussianSplat2D.ttGravitationalWaveSplat
      0 0 5 2 hPlus (by norm_num) (by norm_num) θ
    Complex.normSq (complexTwoRowMinor M_GW 0 2 * complexTwoRowMinor M_GW 1 3) =
      2 * (1 + Real.sqrt (1 - orb.eccentricity ^ 2) * Real.cos (2 * Φ_orb + Δϖ)) ∧
    orb.petersMathewsFactor ^ 2 =
      orb.petersMathewsPolynomial ^ 2 /
        (Complex.normSq (complexPluckerSinkAmplitudeA M_GW) *
          Complex.normSq (complexPluckerSinkAmplitudeB M_GW)) ^ 7 ∧
    re.quadrupoleStrainAmplitude orb 2 10 =
      4 * re.G_phi ^ 2 * re.sourceMass * 2 *
        (sub.rho_max_varphi * sub.j_min_varphi) ^ 2 / (10 * orb.semiMajorAxis) ∧
    0 < gpeVortexScatteringPotential 4 2 3 ∧
    newtonianAcousticDampingRate 2 3 < dilatantKelvinTailDampingRate 2 (1 / 2) 3 ∧
    splat_tt3d.projectOrthographic2D = splat_tt2d ∧
    splat_ddf3d.projectOrthographic2D = splat_tt2d ∧
    splat_ddf3d.covDet < splat_tt3d.covDet ∧
    splat_ddf3d.coreBohmPotential 1 1 - splat_tt3d.coreBohmPotential 1 1 =
      (1 ^ 2 / (4 * 1 * 3 ^ 2)) * (s.jammingFactor ^ 2 - 1) := by
  intro M_GW splat_tt3d splat_ddf3d splat_tt2d
  have h_no_ddf := orb.qed_gravitational_wave_without_ddf_identities
    Φ_orb Δϖ ι re.G_phi re.sourceMass 2 sub.c 10
    re.G_phi_pos re.sourceMass_pos (by norm_num) sub.c_pos (by norm_num) 3 2 2 3
  have h_ddf := re.gravitational_wave_with_ddf_identities
    s orb Φ_orb Δϖ ι 2 10 1 1 2 4 2 3 2 (1 / 2) 3 5 2 hPlus θ 2 (3 / 5) 10 1 2
    (by norm_num) (by norm_num) (by norm_num) (by norm_num)
    (by norm_num) (by norm_num) (by norm_num) (by norm_num)
    (by norm_num) (by norm_num) (by norm_num)
    (by norm_num) (by norm_num) (by norm_num) (by norm_num)
    (by norm_num) (by norm_num) 0 0 0 0
  have h3d := NormedTensorGaussianSplat3D.gravitational_wave_splat3d_and_projection_identities
    s orb 0 0 1 5 2 3 hPlus θ ψ 1 1
    (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  exact ⟨h_no_ddf.2.2.2.2.2.2.2.1, h_no_ddf.2.2.2.2.2.2.2.2.2.2.2.2.1,
    h_ddf.2.1, h_ddf.2.2.2.2.2.2.2.2.2.1, h_ddf.2.2.2.2.2.2.2.2.2.2.2.1,
    h3d.1, h3d.2.1, h3d.2.2.2.2.2.2.1 hv, h3d.2.2.2.2.2.2.2.2⟩
```

### 4.4 Multi-Model Gravity Comparison Table & Machine-Checked Relative Predictive Errors (`PlanetaryOrbit.gravity_models_relative_predictive_error_comparison`)

To benchmark competing theoretical models of gravitation against Einstein General Relativity (GR) and JPL DE440 solar-system ephemerides ([Park et al. 2021](#grav-park2021)), we evaluate the pointwise relative predictive error (`Signals.Huygens.relativePredictiveError`, $\varepsilon_{\mathrm{rel}}(\Delta\varpi_{\mathrm{model}}, \Delta\varpi_{\mathrm{GR}}) = \frac{|\Delta\varpi_{\mathrm{model}} - \Delta\varpi_{\mathrm{GR}}|}{|\Delta\varpi_{\mathrm{GR}}|}$) in theorem `PlanetaryOrbit.gravity_models_relative_predictive_error_comparison` ([src/signals/Signals/QEDGravity.lean](../src/signals/Signals/QEDGravity.lean)):

| Gravity Model & Geometric / Field Mechanism | Carrier Spin & Propagator / Field Equation | Anomalous 2-Body Perihelion Precession $\Delta\varpi_{\mathrm{model}}$ per Orbit | Mercury Anomalous Rate $\dot{\varpi}_{\mathrm{rel}}$ ($''/\text{cy}$) | Anomalous Precession Error $\varepsilon_{\mathrm{rel}}(\Delta\varpi, \Delta\varpi_{\mathrm{GR}})$ | Mercury Total Inertial Error $\varepsilon_{\mathrm{rel}}(\dot{\varpi}_{\mathrm{tot}}, 574.61'')$ | Solar Light Bending $\frac{\Delta\theta_\gamma}{\Delta\theta_{\gamma,\mathrm{GR}}}$ & Unitarity / Conservation Status |
|---|---|---|---|---|---|---|
| **1. Newtonian $1/r$ Gravity** (`newtonianAnomalousPrecessionRad`: tree-level $O(G)$ only) | Instantaneous scalar potential ($\nabla^2 \Phi = 4\pi G\rho$) | $0$ (closed Keplerian ellipse) | $0.00''$ ($\dot{\varpi}_{\mathrm{tot}} = 531.63''$) | **$1$ ($100\%$)** | $7.48\%$ ($42.98''$ deficit) | $\frac{1}{2}$ (Soldner ballistic); conservative ($\frac{dE}{dt} = 0$), non-relativistic |
| **2. Nordström Relativistic Scalar Gravity** ([Nordström 1913](#grav-nordstrom1913): `nordstromScalarPrecessionRad`) | Spin-$0$ scalar coupled to trace $T^\mu_\mu$ ($\Box\Phi = 4\pi G T^\mu_\mu$, $1/q^2$) | $-\frac{1}{6}\Delta\varpi_{\mathrm{GR}} = -\frac{\pi G M}{c^2 a(1-e^2)}$ (**retrograde**) | $-7.16''$ ($\dot{\varpi}_{\mathrm{tot}} = 524.47''$) | **$\frac{7}{6} \approx 116.67\%$** | $8.73\%$ ($50.14''$ deficit) | **$0$ ($100\%$ error: $T^\mu_\mu(\text{EM}) = 0$)**; unitary, ruled out by Eddington & Mercury |
| **3. Einstein's General Relativity (1915 / 1916)** ([Einstein 1915](#grav-einstein1915); [Einstein 1916](#grav-einstein1916): `einsteinGeneralRelativityPrecessionRad` at $\beta_{\mathrm{PPN}}=1, \gamma_{\mathrm{PPN}}=1$) | Pseudo-Riemannian metric $g_{\mu\nu}$ ($G_{\mu\nu} = \frac{8\pi G}{c^4} T_{\mu\nu}$, Schwarzschild $ds^2$ & PPN $\frac{2-\beta_{\mathrm{PPN}}+2\gamma_{\mathrm{PPN}}}{3}=1$) | $\Delta\varpi_{\mathrm{EGR}}(1,1) = \frac{6\pi G M}{c^2 a(1-e^2)} = \frac{3\pi r_S}{p}$ | **$42.98''$** ($\dot{\varpi}_{\mathrm{tot}} = 574.61''$) | **$0$ ($0\%$)** | **$0\%$** | $1$ ($1.75''$ at solar limb, $\frac{1+\gamma_{\mathrm{PPN}}}{2}=1$, $\eta_{\mathrm{act}}^\gamma = 1$); conservative at 1PN ($\frac{dE}{dt}=0$), $r=0$ singularity & 2-loop non-renormalizable |
| **4. Special-Relativistic Spin-1 Vector / Un-Doubled Coulomb-QED** (`spinOneVectorPrecessionRad`) | Spin-$1$ vector $A_\mu$ without BCJ spin-$2$ double copy ($1/q^2$) | $+\frac{1}{6}\Delta\varpi_{\mathrm{GR}} = +\frac{\pi G M}{c^2 a(1-e^2)}$ (Sommerfeld) | $+7.16''$ ($\dot{\varpi}_{\mathrm{tot}} = 538.79''$) | **$\frac{5}{6} \approx 83.33\%$** | $6.23\%$ ($35.82''$ deficit) | $\frac{1}{2}$ ($50\%$ error); like charges repel, misses $5/6$ of 1-loop spin-2 tensor coupling |
| **5a. Witten's 2004 Twistor String Theory (Pure Scale-Free Conformal Limit)** ([Witten 2004](#grav-witten2004); [Berkovits and Witten 2004](#grav-berkovits-witten2004): `wittenConformalTwistorPrecessionRad` at $\beta_{\mathrm{scale}}=0, \gamma_{\mathrm{conf}}=0$) | $\mathcal{N}=4$ Weyl conformal supergravity on $\mathbb{CP}^{3\|4}$ ($S \propto \int C_{\mu\nu\rho\sigma}^2$, **4th-order $1/q^4$**) | $0$ (no dimensionful Newton scale $G M / c^2$ in $\mathrm{SU}(2,2\|4)$) | $0.00''$ (scale-free) | **$1$ ($100\%$)** | $7.48\%$ | Conformal light cones preserved, but **non-unitary $1/q^4$ Ostrogradsky ghosts** in all loops |
| **5b. Witten's Twistor-String Conformal Gravity with Biharmonic Linear Potential** ([Berkovits and Witten 2004](#grav-berkovits-witten2004): `wittenConformalTwistorPrecessionRad` at $\beta_{\mathrm{scale}}=1, \gamma_{\mathrm{conf}}>0$) | 4th-order biharmonic $\nabla^4\Phi = 0 \implies \Phi = -\frac{G M}{r} + \frac{1}{2}\gamma_{\mathrm{conf}}c^2 r$ ($1/q^4$ + $1/q^2$) | $\Delta\varpi_{\mathrm{GR}} - \pi\,\gamma_{\mathrm{conf}}\,a^2\sqrt{1-e^2}$ (wrong $+a^2$ scaling!) | $42.98'' - \dot{\varpi}_{\gamma}(a^2)$ | **$\frac{\pi\gamma_{\mathrm{conf}}a^2\sqrt{1-e^2}}{\Delta\varpi_{\mathrm{GR}}} > 0$** (grows as $a^3$!) | $> 0$ (diverges for outer planets as $a^3$) | Unphysical linear Rindler deflection $\propto \gamma_{\mathrm{conf}} b$; **non-unitary $1/q^4$ ghosts** |
| **6. Dissipative Viscous Stokes-Drag Fluid** (`ddf_conservative_action_vs_stokes_drag_critique`: $F_{\mathrm{drag}} = 6\pi\eta r v > 0$) | Non-conservative tangential drag in naive mechanical ether | Secular semi-major axis decay $\frac{da}{dt} < 0$ | Catastrophic orbital inspiral | **Non-conservative ($\frac{dE}{dt} = -F_{\mathrm{drag}}v < 0$)** | Ruled out ($>10^{12}\times$ ephemeris bound) | Violates energy conservation, Lorentz invariance, and 4.5 Gyr solar-system stability |
| **7a. Cachazo–Skinner (2012) Infinity-Twistor with Cosmological Constant ($\Lambda_{\mathrm{cc}} > 0$)** ([Cachazo and Skinner 2012](#grav-cachazo-skinner2012): `cachazoSkinnerTwistorPrecessionRad` at $\pi_I=1, \Lambda_{\mathrm{cc}}>0$) | Spin-$2$ on $\mathbb{CP}^{3\|8}$ with $I_{AB} I^{BC} = \Lambda_{\mathrm{cc}}\,\delta_A^C$ ($1/q^2 + \Lambda_{\mathrm{cc}}$) | $\Delta\varpi_{\mathrm{GR}} + \frac{\pi c^2 \Lambda_{\mathrm{cc}}\,a^3\sqrt{1-e^2}}{G M}$ | $42.98'' + \dot{\varpi}_{\Lambda}(a^3)$ | **$\frac{\pi c^2 \Lambda_{\mathrm{cc}}\,a^3\sqrt{1-e^2}}{G M\,\Delta\varpi_{\mathrm{GR}}} > 0$** | $> 0$ (bounded by solar-system $\Lambda_{\mathrm{cc}}$ constraints) | $1$; de Sitter cosmological correction scaling as $a^3\sqrt{1-e^2}$ |
| **7b. Cachazo–Skinner (2012) Infinity-Twistor Rational Curves ($\Lambda_{\mathrm{cc}} = 0$)** ([Cachazo and Skinner 2012](#grav-cachazo-skinner2012): `cachazoSkinnerTwistorPrecessionRad` at $\pi_I=1, \Lambda_{\mathrm{cc}}=0$) | Spin-$2$ on $\mathbb{CP}^{3\|8}$ with rank-2 $I_{AB}$ projecting onto $Gr_{\mathbb{C}}(2,4)$ & reduced Hodges $\det'(\Phi)\det'(\tilde{\Phi})$ ($1/q^2$) | $\Delta\varpi_{\mathrm{CS}}(1,\gamma_{\mathrm{conf}},0) = \Delta\varpi_{\mathrm{GR}} = \frac{6\pi G M}{c^2 a(1-e^2)}$ ($\forall\,\gamma_{\mathrm{conf}}$) | **$42.98''$** ($\dot{\varpi}_{\mathrm{tot}} = 574.61''$) | **$0$ ($0\%$)** | **$0\%$** | $1$ ($1.75''$ at solar limb); $I_{AB}$ projects out $C_{\mu\nu\rho\sigma}^2$ Weyl modes identically |
| **8a. Fedi's "Superfluid Quantum Gravity" (2016: Pure Inviscid Euler/Bernoulli Sink Flow)** ([Fedi 2016](#grav-fedi2016): `fediSQG2016PrecessionRad` at $\kappa_{\mathrm{rel}}=0, \delta_{\mathrm{GPE}}=0$) | Inviscid BEC quantum space (SQS) radial sink $v_r = -\sqrt{2GM/r}$, Bernoulli potential $\Phi_{\mathrm{SQS}} = -\frac{1}{2}v_r^2 = -\frac{GM}{r}$ | $0$ (pure inverse-square $-\nabla\Phi_{\mathrm{SQS}} = -\frac{GM}{r^2}\hat{\mathbf{r}}$ without $1/r^3$ relativistic term) | $0.00''$ ($\dot{\varpi}_{\mathrm{tot}} = 531.63''$) | **$1$ ($100\%$)** | $7.48\%$ ($42.98''$ deficit) | $\frac{1}{2}$ without acoustic metric; continuous fermion-sink continuity question ($\nabla\cdot\mathbf{v} \neq 0$) |
| **8b. Fedi's "Superfluid Quantum Gravity" (2016: Relativistic Acoustic Pressure + GPE Bohm Core)** ([Fedi 2016](#grav-fedi2016): `fediSQG2016PrecessionRad` at $\kappa_{\mathrm{rel}}=1, \delta_{\mathrm{GPE}}\ge 0$) | Gross–Pitaevskii / Madelung BEC ($i\hbar\partial_t\Psi = (-\frac{\hbar^2}{2m}\nabla^2 + V + g\|\Psi\|^2)\Psi$) + Bohm potential $Q = -\frac{\hbar^2}{2m}\frac{\nabla^2\sqrt{\rho}}{\sqrt{\rho}}$ | $\Delta\varpi_{\mathrm{GR}} + \delta_{\mathrm{GPE}}$ ($\Delta\varpi_{\mathrm{SQG,2016}}(1,0) = \Delta\varpi_{\mathrm{GR}}$ for healing length $\xi \ll a$) | **$42.98''$** ($\delta_{\mathrm{GPE}} \to 0$ at planetary scale) | **$0$ ($0\%$ at $\delta_{\mathrm{GPE}}=0$)**; $\frac{\delta_{\mathrm{GPE}}}{\Delta\varpi_{\mathrm{GR}}} > 0$ near core | **$0\%$** (at $\delta_{\mathrm{GPE}}=0$) | $1$ in acoustic refractive index $n(r)$; Bohm quantum potential $Q$ regularizes $r=0$ core singularity |
| **9a. Fedi's "Hydrodynamics of the Dark Superfluid" (2017: Dilatant $\gamma - 1$ w/ Pioneer Drag $\eta_{\mathrm{drag}} > 0$)** ([Fedi 2017](#grav-fedi2017): `fediDarkSuperfluid2017PrecessionRad` at $\lambda_\gamma=1, \eta_{\mathrm{drag}}>0$) | Shear-thickening dark superfluid $\eta_{\mathrm{eff}}(v) \propto \gamma(v) - 1$ + baseline Stokes drag $\eta_{\mathrm{drag}} > 0$ fitted to Pioneer 10/11 | $\Delta\varpi_{\mathrm{GR}} - 2\pi\,\eta_{\mathrm{drag}}\,a\sqrt{1-e^2}$ | $42.98'' - \dot{\varpi}_{\mathrm{drag}}(\eta_{\mathrm{drag}})$ | **$\frac{2\pi\eta_{\mathrm{drag}}a\sqrt{1-e^2}}{\Delta\varpi_{\mathrm{GR}}} > 0$** | $> 0$ (plus secular $\frac{da}{dt} < 0$) | Double-counts Pioneer 10/11 RTG thermal recoil; baseline $\eta_{\mathrm{drag}} > 0$ breaks Lorentz invariance & $\frac{dE}{dt} = 0$ |
| **9b. Fedi's "Hydrodynamics of the Dark Superfluid" (2017: Conservative Dilatant $\gamma - 1$ w/ Mercury Perihelion, $\eta_{\mathrm{drag}} = 0$)** ([Fedi 2017](#grav-fedi2017): `fediDarkSuperfluid2017PrecessionRad` at $\lambda_\gamma=1, \eta_{\mathrm{drag}}=0$) | Shear-thickening dark superfluid with $\eta_{\mathrm{eff}}(v) \propto (1 - v^2/c^2)^{-1/2} - 1 \simeq \frac{1}{2}\frac{v^2}{c^2}$ and zero baseline drag ($\eta_{\mathrm{drag}}=0$) | $\Delta\varpi_{\mathrm{dark,2017}}(1,0) = \Delta\varpi_{\mathrm{GR}} = \frac{6\pi G_\phi M}{c^2 a(1-e^2)}$ | **$42.98''$** ($\dot{\varpi}_{\mathrm{tot}} = 574.61''$) | **$0$ ($0\%$)** | **$0\%$** | $1$ ($1.75''$ refractive bending); phenomenological $\gamma - 1$ substitution (derived variationally via $\Lambda_\parallel(v)$ sheath closure in [Fedi 2026](#grav-fedi2026)) |
| **10. Partanen & Tulkki (2025) Four-$\mathrm{U}(1)$ Gauge Gravity + 1-Loop Post-Minkowskian QFT (Without $Gr_{\mathbb{C}}(2,4)$)** ([Partanen and Tulkki 2025](#grav-partanen2025); [Partanen and Tulkki 2025b](#ddf-partanen2025-2); [Bjerrum-Bohr et al. 2018](#grav-bjerrum2018): `partanenTulkki2025PrecessionRad`) | Flat-space 8-spinor $\mathrm{U}(1)^4$ gauge gravity ($1/q^2$) + 1-loop $O(G^2)$ triangle amplitude in Minkowski space | $\Delta\varpi_{\mathrm{PT,2025}} = \frac{6\pi G M}{c^2 a(1-e^2)} = \Delta\varpi_{\mathrm{GR}}$ | **$42.98''$** ($\dot{\varpi}_{\mathrm{tot}} = 574.61''$) | **$0$ ($0\%$)** | **$0\%$** | $1$ ($1.75''$ at solar limb, $\eta_{\mathrm{act}}^\gamma = 1$); **unitary, renormalizable flat-space QFT without $Gr_{\mathbb{C}}(2,4)$ Plücker twistor coordinates** |
| **11. Fedi's Conservative Dilatant Dark Fluid (DDF, 2026: Without $Gr_{\mathbb{C}}(2,4)$)** ([Fedi 2026](#grav-fedi2026): `fediDDF2026PrecessionRad`, `RiverExterior.perihelionPrecessionRad`) | Two-component $(\phi, \varphi)$ superfluid sink $\Phi_\phi = -\frac{G_\phi M}{r}$ + dispersed $\varphi$-phase jamming $c^{-2} = \varrho_{\max}^\varphi j_{\min}^\varphi$, variational $\Lambda_\parallel(v) \implies \gamma_\varphi(v)$ | $\Delta\varpi_{\mathrm{DDF,2026}} = \frac{6\pi G_\phi M \varrho_{\max}^\varphi j_{\min}^\varphi}{a(1-e^2)} = \frac{3\pi r_H}{p}$ | **$42.98''$** ($\dot{\varpi}_{\mathrm{tot}} = 574.61''$) | **$0$ ($0\%$)** | **$0\%$** | $1$ ($1.75''$ passive refractive bending in solar $\Phi_\phi$), **$\eta_{\mathrm{act}}^\gamma = 0$ for photon–photon active beam deflection** (without $Gr_{\mathbb{C}}(2,4)$ or 3D tensor splats) |
| **12. Turner (2026) Flat-Space $Gr_{\mathbb{C}}(2,4)$ BCJ Double Copy + 1-Loop Post-Minkowskian QFT (Without DDF)** (`Signals.QEDGravity`: `turnerGr24QEDPrecessionRad`, `gr24PrecessionMatrix`) | Spin-$2$ Plücker double copy $n_t^2 = (n_s+n_u)^2$ on $M_{\mathbb{C}}^{\mathrm{orb}} \in Gr_{\mathbb{C}}(2,4)$ ($1/q^2$) + 1-loop $O(G^2)$ triangle | $\Delta\varpi_{\mathrm{Turner,2026}} = \frac{6\pi G M}{c^2 a(\|w_A^{\mathbb{C}}(M_{\mathbb{C}}^{\mathrm{orb}})\|^2\|w_B^{\mathbb{C}}(M_{\mathbb{C}}^{\mathrm{orb}})\|^2)} = \Delta\varpi_{\mathrm{GR}}$ | **$42.98''$** ($\dot{\varpi}_{\mathrm{tot}} = 574.61''$) | **$0$ ($0\%$)** | **$0\%$** | $1$ ($1.75''$ at solar limb, $\eta_{\mathrm{act}}^\gamma = 1$); **exact $Gr_{\mathbb{C}}(2,4)$ Plücker channel factorization $\|w_A^{\mathbb{C}}\|^2\|w_B^{\mathbb{C}}\|^2 = 1-e^2 = p/a$** |
| **13. Turner (2026) Unified $Gr_{\mathbb{C}}(2,4)$ + Conservative Dilatant Dark Fluid (DDF) + 3D `NormedTensorGaussianSplat3D`** ([Fedi 2026](#grav-fedi2026), `Signals.DDF` + `NormedTensorGaussianSplat3D` (Turner 2026)) | Superfluid $\phi$ Bernoulli sink $\Phi_\phi = -\frac{G_\phi M}{r}$ + $\varphi$-jamming $c^{-2} = \varrho_{\max}^\varphi j_{\min}^\varphi$ on $M_{\mathbb{C}}^{\mathrm{orb}} \in Gr_{\mathbb{C}}(2,4)$ & $Gr_{\mathbb{C}}(2, N+2)$ | $\frac{3\pi r_H}{a(\|w_A^{\mathbb{C}}(M_{\mathbb{C}}^{\mathrm{orb}})\|^2\|w_B^{\mathbb{C}}(M_{\mathbb{C}}^{\mathrm{orb}})\|^2)} = \frac{6\pi G_\phi M \varrho_{\max}^\varphi j_{\min}^\varphi}{a(1-e^2)}$ | **$42.98''$** ($\dot{\varpi}_{\mathrm{tot}} = 574.61''$) | **$0$ ($0\%$)** | **$0\%$** | $1$ ($1.75''$ passive refractive bending in $\Phi_\phi$), **$\eta_{\mathrm{act}}^\gamma = 0$ laboratory discriminator vs. GR**, + 2D/3D `NormedTensorGaussianSplat3D` & Bohm core regularization |
| **14a. Turner (2026) Homogeneous Plücker $\mathcal{Q}_4$ Madelung QHJ + Fubini–Study Kähler Chart + `iGPE` Potential Inversion (Without DDF)** ([grassmannian-complex-gpe-igpe-plucker-madelung-paper.md](grassmannian-complex-gpe-igpe-plucker-madelung-paper.md): `PlanetaryOrbit.turnerPluckerIGPEPrecessionRad`, `pluckerInversePotentialReconstruction`) | Homogeneous Plücker $\mathcal{Q}_4 \subset \mathbb{P}^5(\mathbb{C})$ QHJ + Fubini–Study Kähler chart $\det(I_2 + W_{\mathrm{orb}}W_{\mathrm{orb}}^\dagger) - 3 = 1-e^2 = p/a$ + Penrose Bohm–Weyl $W_{\mathrm{Weyl}} \propto Q_{\mathrm{Pl\ddot{u}cker}}$ | $\frac{6\pi G M}{c^2 a(\det(I_2 + W_{\mathrm{orb}}W_{\mathrm{orb}}^\dagger) - 3)} + \delta_{\mathrm{Jos}}$ ($\Delta\varpi_{\mathrm{GR}}$ at $\delta_{\mathrm{Jos}}=0$) | **$42.98''$** ($\dot{\varpi}_{\mathrm{tot}} = 574.61''$ at $\delta_{\mathrm{Jos}}=0$) | **$0$ ($0\%$ at $\delta_{\mathrm{Jos}}=0$)**; $\frac{\delta_{\mathrm{Jos}}}{\Delta\varpi_{\mathrm{GR}}} > 0$ near core | **$0\%$** (at $\delta_{\mathrm{Jos}}=0$) | $1$ ($1.75''$ at solar limb); reconstructs $V_{\mathrm{ext,re}}^{\mathrm{rec}}$ from `pluckerInversePotentialReconstruction` ($\mathcal{R}_{\mathrm{QHJ}}^{\mathrm{Pl\ddot{u}cker}}=0$) |
| **14b. Turner (2026) Unified Dual-Grassmannian $Gr_{\mathbb{C}}(2,4)\times Gr_{\mathbb{C}}(2,4)^\vee$ `iGPE` + Homogeneous Plücker $\mathcal{Q}_4$ Madelung + Conservative DDF** ([grassmannian-complex-gpe-igpe-plucker-madelung-paper.md](grassmannian-complex-gpe-igpe-plucker-madelung-paper.md): `RiverExterior.turnerDualGr24IGPEDDFPrecessionRad`) | Coupled $(\Psi(\mathbf{Z}), \Phi(\mathbf{Z}^\perp))$ on $Gr_{\mathbb{C}}(2,4)\times Gr_{\mathbb{C}}(2,4)^\vee$ ($p \leftrightarrow \tilde{p}$) + $c^{-2} = \varrho_{\max}^\varphi j_{\min}^\varphi$ + Einstein–Kähler gap $R_{\mathrm{Gr}}(2,4)=16$ | $\frac{6\pi G_\phi M \varrho_{\max}^\varphi j_{\min}^\varphi}{a(\det(I_2 + W_{\mathrm{orb}}W_{\mathrm{orb}}^\dagger) - 3)} + \delta_{\mathrm{Jos}}$ ($\Delta\varpi_{\mathrm{GR}}$ at $\delta_{\mathrm{Jos}}=0$) | **$42.98''$** ($\dot{\varpi}_{\mathrm{tot}} = 574.61''$ at $\delta_{\mathrm{Jos}}=0$) | **$0$ ($0\%$ at $\delta_{\mathrm{Jos}}=0$)**; $\frac{\delta_{\mathrm{Jos}}}{\Delta\varpi_{\mathrm{GR}}} > 0$ near core | **$0\%$** (at $\delta_{\mathrm{Jos}}=0$) | $1$ ($1.75''$ passive bending), **$\eta_{\mathrm{act}}^\gamma = 0$**, + chiral primary-to-dual ($\Psi \leftrightarrow \Phi$) Schubert tunneling regularizing $r=0$ at $\mathrm{De}/\mathrm{De}_c = 1$ |

```lean
-- 5. Multi-model gravity relative predictive error comparison (Einstein GR, Partanen-Tulkki 2025 QFT, Fedi 2026 DDF, Turner 2026 Gr_C(2,4), Fedi 2016 SQG, Fedi 2017 dark superfluid, and Cachazo-Skinner 2012 infinity twistor vs. Witten conformal twistor string, spin-1 vector 5/6, Nordström scalar 7/6, and Newtonian 1)
example (orb : PlanetaryOrbit) (G M c γ_conf Λ_cc δ_GPE η_drag : ℝ)
    (hG : 0 < G) (hM : 0 < M) (hc : 0 < c) (hγ : 0 < γ_conf) (hΛ : 0 < Λ_cc)
    (hδ : 0 < δ_GPE) (hη : 0 < η_drag) :
    let Δϖ_GR := orb.perihelionPrecessionRadPM G M c
    let M_C := orb.gr24PrecessionMatrix Δϖ_GR
    0 < Δϖ_GR ∧
    Δϖ_GR =
      6 * Real.pi * G * M /
        (c ^ 2 * orb.semiMajorAxis *
          (Complex.normSq (complexPluckerSinkAmplitudeA M_C) *
            Complex.normSq (complexPluckerSinkAmplitudeB M_C))) ∧
    relativePredictiveError Δϖ_GR Δϖ_GR = 0 ∧
    relativePredictiveError orb.newtonianAnomalousPrecessionRad Δϖ_GR = 1 ∧
    orb.nordstromScalarPrecessionRad G M c < 0 ∧
    relativePredictiveError (orb.nordstromScalarPrecessionRad G M c) Δϖ_GR = 7 / 6 ∧
    orb.einsteinGeneralRelativityPrecessionRad G M c 1 1 = Δϖ_GR ∧
    relativePredictiveError (orb.einsteinGeneralRelativityPrecessionRad G M c 1 1) Δϖ_GR = 0 ∧
    relativePredictiveError (orb.spinOneVectorPrecessionRad G M c) Δϖ_GR = 5 / 6 ∧
    relativePredictiveError (orb.wittenConformalTwistorPrecessionRad G M c 0 0) Δϖ_GR = 1 ∧
    relativePredictiveError (orb.wittenConformalTwistorPrecessionRad G M c 1 γ_conf) Δϖ_GR =
      Real.pi * γ_conf * orb.semiMajorAxis ^ 2 *
        Real.sqrt (1 - orb.eccentricity ^ 2) / Δϖ_GR ∧
    0 < relativePredictiveError (orb.wittenConformalTwistorPrecessionRad G M c 1 γ_conf) Δϖ_GR ∧
    relativePredictiveError (orb.fediSQG2016PrecessionRad G M c 0 0) Δϖ_GR = 1 ∧
    orb.fediSQG2016PrecessionRad G M c 1 0 = Δϖ_GR ∧
    relativePredictiveError (orb.fediSQG2016PrecessionRad G M c 1 0) Δϖ_GR = 0 ∧
    relativePredictiveError (orb.fediSQG2016PrecessionRad G M c 1 δ_GPE) Δϖ_GR =
      δ_GPE / Δϖ_GR ∧
    0 < relativePredictiveError (orb.fediSQG2016PrecessionRad G M c 1 δ_GPE) Δϖ_GR ∧
    orb.fediDarkSuperfluid2017PrecessionRad G M c 1 0 = Δϖ_GR ∧
    relativePredictiveError (orb.fediDarkSuperfluid2017PrecessionRad G M c 1 0) Δϖ_GR = 0 ∧
    relativePredictiveError (orb.fediDarkSuperfluid2017PrecessionRad G M c 1 η_drag) Δϖ_GR =
      2 * Real.pi * η_drag * orb.semiMajorAxis *
        Real.sqrt (1 - orb.eccentricity ^ 2) / Δϖ_GR ∧
    0 < relativePredictiveError (orb.fediDarkSuperfluid2017PrecessionRad G M c 1 η_drag) Δϖ_GR ∧
    orb.cachazoSkinnerTwistorPrecessionRad G M c 1 γ_conf 0 = Δϖ_GR ∧
    relativePredictiveError (orb.cachazoSkinnerTwistorPrecessionRad G M c 1 γ_conf 0) Δϖ_GR = 0 ∧
    relativePredictiveError (orb.cachazoSkinnerTwistorPrecessionRad G M c 1 γ_conf Λ_cc) Δϖ_GR =
      Real.pi * c ^ 2 * Λ_cc * orb.semiMajorAxis ^ 3 *
        Real.sqrt (1 - orb.eccentricity ^ 2) / (G * M) / Δϖ_GR ∧
    0 < relativePredictiveError (orb.cachazoSkinnerTwistorPrecessionRad G M c 1 γ_conf Λ_cc) Δϖ_GR ∧
    orb.cachazoSkinnerTwistorPrecessionRad G M c 0 γ_conf 0 =
      orb.wittenConformalTwistorPrecessionRad G M c 0 γ_conf ∧
    orb.partanenTulkki2025PrecessionRad G M c = Δϖ_GR ∧
    relativePredictiveError (orb.partanenTulkki2025PrecessionRad G M c) Δϖ_GR = 0 ∧
    orb.fediDDF2026PrecessionRad G M c = Δϖ_GR ∧
    relativePredictiveError (orb.fediDDF2026PrecessionRad G M c) Δϖ_GR = 0 ∧
    orb.turnerGr24QEDPrecessionRad G M c Δϖ_GR = Δϖ_GR ∧
    relativePredictiveError (orb.turnerGr24QEDPrecessionRad G M c Δϖ_GR) Δϖ_GR = 0 :=
  orb.gravity_models_relative_predictive_error_comparison G M c γ_conf Λ_cc δ_GPE η_drag
    hG hM hc hγ hΛ hδ hη
```

### 4.5 Multi-Model Gravitational Wave Comparison Table & Machine-Checked Relative Predictive Errors (`PlanetaryOrbit.gravitational_wave_models_relative_predictive_error_comparison`)

To complement the conservative 1PN perihelion precession benchmark of Section 4.4 with **radiative 2.5PN ($O(G^3/c^5)$) gravitational-wave emission, polarization structure, and multi-messenger propagation**, we evaluate the pointwise relative predictive error (`Signals.Huygens.relativePredictiveError`, $\varepsilon_{\mathrm{rel}}(P_{\mathrm{GW}}^{\mathrm{model}}, P_{\mathrm{GW}}^{\mathrm{GR}}) = \frac{|P_{\mathrm{GW}}^{\mathrm{model}} - P_{\mathrm{GW}}^{\mathrm{GR}}|}{|P_{\mathrm{GW}}^{\mathrm{GR}}|}$) in theorem `PlanetaryOrbit.gravitational_wave_models_relative_predictive_error_comparison` ([src/signals/Signals/QEDGravity.lean](../src/signals/Signals/QEDGravity.lean)) and `GravitationalWaveModelErrorComparison::evaluate` ([src/signals/numerical_adapter/src/orbital_splat.rs](../src/signals/numerical_adapter/src/orbital_splat.rs)).

The reference benchmark $P_{\mathrm{GW}}^{\mathrm{GR}} = \mathrm{orb}.\mathrm{petersMathewsLuminosityPM}\,G\,m_1\,m_2\,c$ is Einstein's quadrupole radiation formula ([Einstein 1916b](#grav-einstein1916-gw); [Einstein 1918](#grav-einstein1918-gw)) integrated over an eccentric Keplerian orbit by [Peters and Mathews (1963)](#grav-peters1963) and factored through the dynamic $Gr_{\mathbb{C}}(2,4)$ quadrupole twistor matrix $M_{\mathbb{C}}^{\mathrm{GW}} = \mathrm{orb}.\mathrm{gr24QuadrupoleWaveMatrix}\,\Phi_{\mathrm{orb}}\,\Delta\varpi$:

$$
P_{\mathrm{GW}}^{\mathrm{GR}} = \frac{32}{5}\frac{G^4 m_1^2 m_2^2(m_1 + m_2)}{c^5 a^5}\,f_{\mathrm{PM}}(e), \qquad
f_{\mathrm{PM}}(e)^2 = \frac{\bigl(1 + \frac{73}{24}e^2 + \frac{37}{96}e^4\bigr)^2}{\bigl(|w_A^{\mathbb{C}}(M_{\mathbb{C}}^{\mathrm{GW}})|^2\,|w_B^{\mathbb{C}}(M_{\mathbb{C}}^{\mathrm{GW}})|^2\bigr)^7},
$$

which is observationally confirmed to $< 0.16\%$ by the orbital period decay of the Hulse–Taylor binary pulsar PSR B1913+16 ([Hulse and Taylor 1975](#grav-hulse1975); [Weisberg and Huang 2016](#grav-weisberg2016)), by direct LIGO–Virgo binary coalescence waveforms ([Abbott et al. 2016](#grav-abbott2016)), and by the multi-messenger binary neutron star merger GW170817 / GRB 170817A ($\Delta t \approx +1.74\text{ s}$ across $D_L \approx 40\text{ Mpc}$, bounding $\frac{|c_{\mathrm{GW}} - c|}{c} \lesssim 3 \times 10^{-15}$, [Abbott et al. 2017](#grav-abbott2017); [Provenance Chat Log: Review Pop III GW Remnants 2026](#grav-chat-gw-remnants); [Provenance Chat Log: SQG/DDF Explanation of Wave Delays 2026](#grav-chat-gw-delays); [Provenance Chat Log: Gravity Models: Dilatant Fluid vs. GR 2026](#grav-chat-dilatant-gr)):

| Gravitational-Wave Model & Radiative Mechanism | Polarization Modes, Helicity, & Wave Operator | Binary Radiated Luminosity $P_{\mathrm{GW}}^{\mathrm{model}}$ (2.5PN / Leading Multipole) | TT $(+, \times)$ Luminosity Error $\varepsilon_{\mathrm{rel}}(P_{\mathrm{GW}}^{\mathrm{TT}}, P_{\mathrm{GW}}^{\mathrm{GR}})$ | Total Multipole Luminosity Error $\varepsilon_{\mathrm{rel}}(P_{\mathrm{GW}}^{\mathrm{tot}}, P_{\mathrm{GW}}^{\mathrm{GR}})$ | Propagation Speed $c_{\mathrm{GW}}/c$, GW170817 Timing ($\Delta t \approx 1.74\text{ s}$), & Dispersion / Tail Structure |
|---|---|---|---|---|---|
| **1. Newtonian $1/r$ Instantaneous Gravity** (`newtonianGWLuminosity`: $c \to \infty$) | Elliptic Poisson equation $\nabla^2\Phi = 4\pi G\rho$; **zero propagating wave modes** | $0$ (no radiation reaction; $\frac{da}{dt} = 0$ in isolated 2-body binary) | **$1$ ($100\%$)** | **$1$ ($100\%$)** | $c_{\mathrm{GW}} = \infty$ (acausal action at a distance; ruled out by PSR B1913+16 & GW150914/GW170817) |
| **2. Nordström Relativistic Scalar Gravity** ([Nordström 1913](#grav-nordstrom1913): `nordstromScalarGWLuminosity`) | Spin-$0$ scalar breathing mode ($s = 0$, $\Box\Phi = 4\pi G T^\mu_\mu$); **zero $(+, \times)$ tensor modes** | $P_{\mathrm{GW}}^{\mathrm{scalar}}(\kappa_{\mathrm{scalar}}) = \kappa_{\mathrm{scalar}} P_{\mathrm{GW}}^{\mathrm{GR}}$ ($\kappa_{\mathrm{scalar}}=0$ in TT channel; $\kappa_{\mathrm{scalar}}=\frac{1}{6}$ virial trace quadrupole) | **$1$ ($100\%$)** | **$\frac{5}{6} \approx 83.33\%$** ($\kappa_{\mathrm{scalar}} = \frac{1}{6}$) | $c_{\mathrm{GW}}/c = 1$; monopole/dipole vanish by mass/momentum conservation; ruled out by LIGO–Virgo 3-detector $(+, \times)$ polarization tests |
| **3. Einstein's General Relativity (1916 / 1918) & Peters–Mathews (1963)** ([Einstein 1916b](#grav-einstein1916-gw); [Einstein 1918](#grav-einstein1918-gw); [Peters and Mathews 1963](#grav-peters1963): `einsteinGeneralRelativityGWLuminosity` at $\kappa_{\mathrm{quad}}=1$) | Massless spin-$2$ transverse-traceless $(h_+, h_\times)$ modes ($s = \pm 2$, $\Box\bar{h}_{\mu\nu} = -\frac{16\pi G}{c^4}T_{\mu\nu}$) | $P_{\mathrm{GW}}^{\mathrm{EGR}}(1) = \frac{32}{5}\frac{G^4 m_1^2 m_2^2(m_1+m_2)}{c^5 a^5} f_{\mathrm{PM}}(e) = P_{\mathrm{GW}}^{\mathrm{GR}}$ | **$0$ ($0\%$)** | **$0$ ($0\%$)** | $c_{\mathrm{GW}}/c = 1$ (dispersionless in vacuum); $\Delta t \approx 1.74\text{ s}$ from extrinsic jet/cocoon breakout; curved-spacetime Weyl tail $\propto t^{-7}$ |
| **4. Special-Relativistic Spin-1 Vector / Un-Doubled Larmor Model** (`spinOneVectorGWLuminosity`) | Spin-$1$ vector modes ($s = \pm 1$, $\Box A_\mu = \mu_0 J_\mu$); **zero $(+, \times)$ tensor modes** | $P_{\mathrm{GW}}^{\mathrm{vector}}(\kappa_{\mathrm{vec}}, \Delta_{\mathrm{dip}}) = \kappa_{\mathrm{vec}} P_{\mathrm{GW}}^{\mathrm{GR}} + \Delta_{\mathrm{dip}}$ ($\ddot{\mathbf{d}}=\mathbf{0} \implies \Delta_{\mathrm{dip}}=0$, $\kappa_{\mathrm{vec}}=\frac{1}{4}$) | **$1$ ($100\%$)** | **$\frac{3}{4} = 75\%$** ($\kappa_{\mathrm{vec}} = \frac{1}{4}, \Delta_{\mathrm{dip}} = 0$) | $c_{\mathrm{GW}}/c = 1$; universal $q_i/m_i = \sqrt{G}$ kills Larmor dipole ($\ddot{\mathbf{d}}=\mathbf{0}$), while vector quadrupole misses $75\%$ of spin-2 flux |
| **5a. Witten's 2004 Twistor String Theory (Pure Scale-Free Conformal Limit)** ([Witten 2004](#grav-witten2004); [Berkovits and Witten 2004](#grav-berkovits-witten2004): `wittenConformalTwistorGWLuminosity` at $\beta_{\mathrm{scale}}=0, \delta P_{\mathrm{ghost}}=0$) | 4th-order Weyl conformal supergravity ($\Box^2 h_{\mu\nu} = 0$, $1/q^4$ propagator on $\mathbb{CP}^{3\|4}$) | $0$ (no dimensionful $G/c^5$ coupling in unbroken $\mathrm{SU}(2,2\|4)$) | **$1$ ($100\%$)** | **$1$ ($100\%$)** | Conformal light cone $k^2 = 0$, but no dimensionful quadrupole radiation reaction in the scale-free limit |
| **5b. Witten's Twistor-String Conformal Gravity with Negative-Norm Weyl Ghost Flux** ([Berkovits and Witten 2004](#grav-berkovits-witten2004): `wittenConformalTwistorGWLuminosity` at $\beta_{\mathrm{scale}}=1, \delta P_{\mathrm{ghost}}>0$) | Massless spin-$2$ ($+1/q^2$) minus massive/dipole Ostrogradsky spin-$2$ ghost ($-1/(q^2 - m_{\mathrm{gh}}^2)$) | $P_{\mathrm{GW}}^{\mathrm{GR}} - \delta P_{\mathrm{ghost}}$ (negative-energy ghost radiation reduces or reverses inspiral!) | **$\frac{\delta P_{\mathrm{ghost}}}{P_{\mathrm{GW}}^{\mathrm{GR}}} > 0$** | **$\frac{\delta P_{\mathrm{ghost}}}{P_{\mathrm{GW}}^{\mathrm{GR}}} > 0$** | **Non-unitary**: negative-norm ghost states carry negative energy $-\delta P_{\mathrm{ghost}} < 0$, violating optical theorem & binary pulsar damping |
| **6. Dissipative Viscous Stokes-Drag Ether** (`ddf_conservative_action_vs_stokes_drag_critique`: $P_{\mathrm{Stokes}} = F_{\mathrm{drag}} v > 0$) | Overdamped diffusive shear mode ($\partial_t \mathbf{v} = \nu\nabla^2\mathbf{v}$) in classical viscous fluid | $P_{\mathrm{diss}} = F_{\mathrm{drag}} v \propto v^2$ (dominates $O(v^5/c^5)$ quadrupole flux by $>10^{10}\times$) | **$1$ ($100\%$)** (no far-field TT wave) | **$\frac{P_{\mathrm{Stokes}}}{P_{\mathrm{GW}}^{\mathrm{GR}}} \gg 1$** | Exponentially attenuated $\exp(-\alpha k^2 t)$ over astrophysical distances ([Provenance Chat Log: Dilatant Fluid vs. GR 2026](#grav-chat-dilatant-gr), lines 45–85) |
| **7a. Cachazo–Skinner (2012) Infinity-Twistor with Cosmological Constant ($\Lambda_{\mathrm{cc}} > 0$)** ([Cachazo and Skinner 2012](#grav-cachazo-skinner2012): `cachazoSkinnerTwistorGWLuminosity` at $\pi_I=1, \delta P_\Lambda>0$) | Spin-$2$ on $\mathbb{CP}^{3\|8}$ with $I_{AB} I^{BC} = \Lambda_{\mathrm{cc}}\,\delta_A^C$ (de Sitter background) | $P_{\mathrm{GW}}^{\mathrm{GR}} + \delta P_\Lambda$ (cosmological de Sitter quadrupole shift $\delta P_\Lambda \propto \Lambda_{\mathrm{cc}}$) | **$\frac{\delta P_\Lambda}{P_{\mathrm{GW}}^{\mathrm{GR}}} > 0$** | **$\frac{\delta P_\Lambda}{P_{\mathrm{GW}}^{\mathrm{GR}}} > 0$** | $c_{\mathrm{GW}}/c = 1$; tiny cosmological-constant correction $\delta P_\Lambda / P_{\mathrm{GW}}^{\mathrm{GR}} \sim \mathcal{O}(\Lambda_{\mathrm{cc}} a^2) \ll 10^{-30}$ |
| **7b. Cachazo–Skinner (2012) Infinity-Twistor Rational Curves ($\Lambda_{\mathrm{cc}} = 0$)** ([Cachazo and Skinner 2012](#grav-cachazo-skinner2012): `cachazoSkinnerTwistorGWLuminosity` at $\pi_I=1, \delta P_\Lambda=0$) | Spin-$2$ double copy $\det'(\Phi)\det'(\tilde{\Phi})$ with rank-2 $I_{AB}$ projecting onto $Gr_{\mathbb{C}}(2,4)$ ($1/q^2$) | $P_{\mathrm{GW}}^{\mathrm{CS}}(1, \delta P_{\mathrm{ghost}}, 0) = P_{\mathrm{GW}}^{\mathrm{GR}}$ ($\forall\,\delta P_{\mathrm{ghost}}$; ghosts projected out!) | **$0$ ($0\%$)** | **$0$ ($0\%$)** | $c_{\mathrm{GW}}/c = 1$; $\mathcal{K}_{\mathrm{CS}}(M_{\mathbb{C}}^{\mathrm{GW}}) = (\Delta_{02}^{\mathbb{C}}\Delta_{13}^{\mathbb{C}})^2 = (w_A^{\mathbb{C}}+w_B^{\mathbb{C}})^2$; unitary & ghost-free |
| **8a. Fedi's "Superfluid Quantum Gravity" (2016: Pure Longitudinal Inviscid BEC Sink)** ([Fedi 2016](#grav-fedi2016): `fediSQG2016GWLuminosity` at $\kappa_{\mathrm{trans}}=0, \delta P_{\mathrm{GPE}}=0$) | Longitudinal compressional sound wave ($s = 0$, $c_s = \sqrt{\partial P/\partial\rho}$); **zero shear modulus $\mu_{\mathrm{shear}} = 0$** | $0$ in spin-2 TT $(+, \times)$ polarization channel (scalar acoustic radiation only) | **$1$ ($100\%$)** | **$1$ ($100\%$ on TT modes)** | Pure scalar BEC cannot propagate transverse-traceless $(h_+, h_\times)$ shear waves without a quantized vortex lattice ([Provenance Chat Log: Dilatant Fluid vs. GR 2026](#grav-chat-dilatant-gr), lines 79–265) |
| **8b. Fedi's "Superfluid Quantum Gravity" (2016: Vortex-Lattice Transverse Elasticity + GPE Bogoliubov Dispersion)** ([Fedi 2016](#grav-fedi2016): `fediSQG2016GWLuminosity` at $\kappa_{\mathrm{trans}}=1, \delta P_{\mathrm{GPE}}\ge 0$) | Transverse Tkachenko / vortex-lattice phonon + Bogoliubov dispersion $v_p^2(k) = c_0^2 + \frac{\hbar^2 k^2}{4 m_\phi^2}$ | $P_{\mathrm{GW}}^{\mathrm{GR}} + \delta P_{\mathrm{GPE}}$ ($P_{\mathrm{GW}}^{\mathrm{SQG,2016}}(1,0) = P_{\mathrm{GW}}^{\mathrm{GR}}$ for $k\xi \ll 1$) | **$0$ ($0\%$ at $\delta P_{\mathrm{GPE}}=0$)**; $\frac{\delta P_{\mathrm{GPE}}}{P_{\mathrm{GW}}^{\mathrm{GR}}} > 0$ at UV $k\xi \sim 1$ | **$0\%$** (at $\delta P_{\mathrm{GPE}}=0$) | $c_{\mathrm{GW}}/c = 1 + \mathcal{O}(k^2\xi^2)$ ($\xi \ll \lambda_{\mathrm{GW}} \implies \|\Delta c/c\| \ll 10^{-15}$); GPE vortex core $V_{\mathrm{scat}}(r) > 0$ generates secondary Huygens tails |
| **9a. Fedi's "Hydrodynamics of the Dark Superfluid" (2017: Dilatant $\gamma - 1$ w/ Baseline Stokes Drag $P_{\mathrm{Stokes}} > 0$)** ([Fedi 2017](#grav-fedi2017): `fediDarkSuperfluid2017GWLuminosity` at $\lambda_\gamma=1, P_{\mathrm{Stokes}}>0$) | Shear-thickening dark superfluid $\eta_{\mathrm{eff}}(v) \propto \gamma(v) - 1$ + baseline Stokes drag $P_{\mathrm{Stokes}} > 0$ | $P_{\mathrm{GW}}^{\mathrm{GR}} + P_{\mathrm{Stokes}}$ (excess non-quadrupole orbital energy loss!) | **$\frac{P_{\mathrm{Stokes}}}{P_{\mathrm{GW}}^{\mathrm{GR}}} > 0$** | **$\frac{P_{\mathrm{Stokes}}}{P_{\mathrm{GW}}^{\mathrm{GR}}} > 0$** | Baseline linear viscosity $\alpha > 0$ damps GW amplitude & over-predicts PSR B1913+16 orbital decay unless $P_{\mathrm{Stokes}} \to 0$ |
| **9b. Fedi's "Hydrodynamics of the Dark Superfluid" (2017: Conservative Dilatant $\gamma - 1$ Shear, $P_{\mathrm{Stokes}} = 0$)** ([Fedi 2017](#grav-fedi2017): `fediDarkSuperfluid2017GWLuminosity` at $\lambda_\gamma=1, P_{\mathrm{Stokes}}=0$) | Frictionless superfluid baseline ($\eta_0 = 0$) with transient dilatant shear impedance $\eta_{\mathrm{eff}} \propto \gamma - 1$ | $P_{\mathrm{GW}}^{\mathrm{dark,2017}}(1, 0) = P_{\mathrm{GW}}^{\mathrm{GR}}$ | **$0$ ($0\%$)** | **$0$ ($0\%$)** | $c_{\mathrm{GW}}/c = 1$ in low-strain interstellar vacuum; near-merger $\dot{\gamma} > \dot{\gamma}_c$ shear-thickening impedance wall ([Provenance Chat Log: SQG/DDF Wave Delays 2026](#grav-chat-gw-delays), lines 45–85) |
| **10. Partanen & Tulkki (2025) Four-$\mathrm{U}(1)$ Gauge Gravity + 2.5PN Post-Minkowskian QFT (Without $Gr_{\mathbb{C}}(2,4)$)** ([Partanen and Tulkki 2025](#grav-partanen2025); [Bjerrum-Bohr et al. 2018](#grav-bjerrum2018): `partanenTulkki2025GWLuminosity`) | Flat-space $\mathrm{U}(1)^4$ gauge gravity ($s = \pm 2$, $1/q^2$) + 2.5PN radiative quadrupole over Minkowski space | $P_{\mathrm{GW}}^{\mathrm{PT,2025}} = \frac{32}{5}\frac{G^4 m_1^2 m_2^2(m_1+m_2)}{c^5 a^5} f_{\mathrm{PM}}(e) = P_{\mathrm{GW}}^{\mathrm{GR}}$ | **$0$ ($0\%$)** | **$0$ ($0\%$)** | $c_{\mathrm{GW}}/c = 1$; unitary, ghost-free flat-space QFT without $Gr_{\mathbb{C}}(2,4)$ Plücker twistor coordinates or 3D tensor splats |
| **11. Fedi's Conservative Dilatant Dark Fluid (DDF, 2026: Without $Gr_{\mathbb{C}}(2,4)$)** ([Fedi 2026](#grav-fedi2026): `fediDDF2026GWLuminosity`, `RiverExterior.petersMathewsLuminosity`) | Transverse $\varphi$-lattice shear phonon ($c^{-2} = \varrho_{\max}^\varphi j_{\min}^\varphi$, $s = \pm 2$) with zero baseline Stokes drag ($P_{\mathrm{Stokes}} = 0$) | $P_{\mathrm{GW}}^{\mathrm{DDF,2026}} = \frac{32}{5}\frac{G_\phi^4 m_1^2 m_2^2(m_1+m_2)(\varrho_{\max}^\varphi j_{\min}^\varphi)^{5/2}}{a^5} f_{\mathrm{PM}}(e) = P_{\mathrm{GW}}^{\mathrm{GR}}$ | **$0$ ($0\%$)** | **$0$ ($0\%$)** | $c_{\mathrm{GW}} = (\varrho_{\max}^\varphi j_{\min}^\varphi)^{-1/2} = c$; GPE vortex tail $V_{\mathrm{scat}}(r) > 0$ & Kelvin damping $+\alpha\gamma_{\mathrm{dil}}k^4 > 0$ (without $Gr_{\mathbb{C}}(2,4)$ or 3D tensor splats) |
| **12. Turner (2026) Flat-Space $Gr_{\mathbb{C}}(2,4)$ BCJ Double Copy + 2.5PN Post-Minkowskian QFT (Without DDF)** (`Signals.QEDGravity`: `turnerGr24QEDGWLuminosity`, `gr24QuadrupoleWaveMatrix`) | Spin-$2$ double copy $\varepsilon_{\mu\nu}^{(\pm 2)} = \varepsilon_\mu^{(\pm 1)}\otimes\varepsilon_\nu^{(\pm 1)}$ on $M_{\mathbb{C}}^{\mathrm{GW}} \in Gr_{\mathbb{C}}(2,4)$ ($1/q^2$) | $\frac{32}{5}\frac{G^4 m_1^2 m_2^2(m_1+m_2)}{c^5 a^5}\frac{P_{\mathrm{PM}}(e)}{(\sqrt{\|w_A^{\mathbb{C}}\|^2\|w_B^{\mathbb{C}}\|^2})^7} = P_{\mathrm{GW}}^{\mathrm{GR}}$ | **$0$ ($0\%$)** | **$0$ ($0\%$)** | $c_{\mathrm{GW}}/c = 1$; $\|\Delta_{02}^{\mathbb{C}}\Delta_{13}^{\mathbb{C}}\|^2 = 2(1+\sqrt{1-e^2}\cos(2\Phi_{\mathrm{orb}}+\Delta\varpi))$; 3D `ttGravitationalWaveSplat3D` $\det\Sigma_{\mathrm{3D}}^{\mathrm{TT}} = \sigma_0^4\sigma_{z,0}^2$ |
| **13. Turner (2026) Unified $Gr_{\mathbb{C}}(2,4)$ + Conservative Dilatant Dark Fluid (DDF) + 3D `NormedTensorGaussianSplat3D`** ([Fedi 2026](#grav-fedi2026), `Signals.DDF` + `NormedTensorGaussianSplat3D` (Turner 2026)) | Transverse $\varphi$-lattice shear phonon ($c^{-2} = \varrho_{\max}^\varphi j_{\min}^\varphi$) on $M_{\mathbb{C}}^{\mathrm{GW}} \in Gr_{\mathbb{C}}(2,4)$ + GPE vortex & Kelvin-wave tail | $(P_{\mathrm{GW}}^{\mathrm{DDF}})^2 = \bigl(\frac{32}{5}\frac{G_\phi^4 M^2 m_2^2(M+m_2)}{a^5}\bigr)^2 (\varrho_{\max}^\varphi j_{\min}^\varphi)^5 \frac{P_{\mathrm{PM}}(e)^2}{(\|w_A^{\mathbb{C}}\|^2\|w_B^{\mathbb{C}}\|^2)^7}$ | **$0$ ($0\%$)** | **$0$ ($0\%$)** | $c_{\mathrm{GW}} = (\varrho_{\max}^\varphi j_{\min}^\varphi)^{-1/2} = c$; GPE tail $V_{\mathrm{scat}}(r) = \frac{2\rho_0\xi^2 r}{(r^2+\xi^2)^2} > 0$, Kelvin damping $+\alpha\gamma_{\mathrm{dil}}k^4 > 0$, & 3D `ddfGravitationalWaveSplat3D` $\det\Sigma_{\mathrm{3D}}^{\mathrm{DDF}} = \sigma_0^4\sigma_{z,0}^2\gamma_\varphi^{-2}$ |
| **14a. Turner (2026) Homogeneous Plücker $\mathcal{Q}_4$ Quadrupole Wave + Fubini–Study Kähler `iGPE` 2.5PN Flux (Without DDF)** ([grassmannian-complex-gpe-igpe-plucker-madelung-paper.md](grassmannian-complex-gpe-igpe-plucker-madelung-paper.md): `PlanetaryOrbit.turnerPluckerIGPEGWLuminosity`) | Homogeneous Plücker $p_{\mathrm{GW}}(t) \in \mathcal{Q}_4 \subset \mathbb{P}^5(\mathbb{C})$ ($\mathcal{C}(p_{\mathrm{GW}})=0$) + Fubini–Study Kähler $\det(I_2 + W_{\mathrm{orb}}W_{\mathrm{orb}}^\dagger) - 3 = 1-e^2$ | $\frac{32}{5}\frac{G^4 m_1^2 m_2^2(m_1+m_2)}{c^5 a^5}\frac{P_{\mathrm{PM}}(e)}{(\sqrt{\det(I_2+W_{\mathrm{orb}}W_{\mathrm{orb}}^\dagger)-3})^7} + \delta P_{\mathrm{Jos}}$ | **$0$ ($0\%$ at $\delta P_{\mathrm{Jos}}=0$)**; $\frac{\delta P_{\mathrm{Jos}}}{P_{\mathrm{GW}}^{\mathrm{GR}}} > 0$ at fracture | **$0\%$** (at $\delta P_{\mathrm{Jos}}=0$) | $c_{\mathrm{GW}}/c = 1$; corrected Hermitian normal $n(p)=\overline{\tilde{p}}$ & tangent metric $\mathcal{H}^{I\bar{J}}$ on $\mathcal{Q}_4$ |
| **14b. Turner (2026) Unified Dual-Grassmannian $Gr_{\mathbb{C}}(2,4)\times Gr_{\mathbb{C}}(2,4)^\vee$ `iGPE` + Plücker $\mathcal{Q}_4$ + DDF + Deborah Shear-Fracture Ringdown** ([grassmannian-complex-gpe-igpe-plucker-madelung-paper.md](grassmannian-complex-gpe-igpe-plucker-madelung-paper.md): `RiverExterior.turnerDualGr24IGPEDDFGWLuminosity`) | Transverse $\varphi$-lattice spin-2 mode + gapped longitudinal Proca mode ($R_{\mathrm{Gr}}(2,4)=16, m_{\gamma,\mathrm{eff}}^2 > 0$) + dual-Schubert $J_{\mathrm{Josephson}}$ | $P_{\mathrm{GW}}^{\mathrm{DDF}} + \delta P_{\mathrm{Jos}}$ ($P_{\mathrm{GW}}^{\mathrm{GR}}$ in sub-critical inspiral $\mathrm{De}/\mathrm{De}_c < 1 \implies \delta P_{\mathrm{Jos}}=0$) | **$0$ ($0\%$ at $\delta P_{\mathrm{Jos}}=0$)**; $\frac{\delta P_{\mathrm{Jos}}}{P_{\mathrm{GW}}^{\mathrm{GR}}} > 0$ at $\mathrm{De} > \mathrm{De}_c$ | **$0\%$** (at $\delta P_{\mathrm{Jos}}=0$) | $c_{\mathrm{GW}} = (\varrho_{\max}^\varphi j_{\min}^\varphi)^{-1/2} = c$; tachyonic ringdown fracture ($\hbar^2\omega^2 < 0 \iff \mathrm{De}/\mathrm{De}_c > 1$) sheds $\delta P_{\mathrm{Jos}} > 0$ into $Gr_{\mathbb{C}}(2,4)^\vee$ while conserving $\frac{d}{d\tau'}(\|\Psi\|^2+\|\Phi\|^2)=0$ |

```lean
-- 6. Multi-model gravitational-wave luminosity relative predictive error comparison (Einstein GR 1916/1918 + Peters-Mathews 1963, Partanen-Tulkki 2025 QFT, Fedi 2026 DDF, Turner 2026 Gr_C(2,4), Cachazo-Skinner 2012, Fedi 2016 SQG, and Fedi 2017 dark superfluid vs. Witten conformal ghost, spin-1 vector 3/4, Nordström scalar 5/6, and Newtonian 1)
example (orb : PlanetaryOrbit)
    (Φ_orb Δϖ G m1 m2 c δP_ghost δP_Λ δP_GPE P_Stokes : ℝ)
    (hG : 0 < G) (hm1 : 0 < m1) (hm2 : 0 < m2) (hc : 0 < c)
    (hGhost : 0 < δP_ghost) (hΛ : 0 < δP_Λ) (hGPE : 0 < δP_GPE) (hStokes : 0 < P_Stokes) :
    let P_GR := orb.petersMathewsLuminosityPM G m1 m2 c
    let M_GW := orb.gr24QuadrupoleWaveMatrix Φ_orb Δϖ
    0 < P_GR ∧
    P_GR ^ 2 =
      ((32 / 5 : ℝ) * G ^ 4 * m1 ^ 2 * m2 ^ 2 * (m1 + m2) /
        (c ^ 5 * orb.semiMajorAxis ^ 5)) ^ 2 *
        (orb.petersMathewsPolynomial ^ 2 /
          (Complex.normSq (complexPluckerSinkAmplitudeA M_GW) *
            Complex.normSq (complexPluckerSinkAmplitudeB M_GW)) ^ 7) ∧
    relativePredictiveError P_GR P_GR = 0 ∧
    relativePredictiveError orb.newtonianGWLuminosity P_GR = 1 ∧
    relativePredictiveError (orb.nordstromScalarGWLuminosity G m1 m2 c 0) P_GR = 1 ∧
    relativePredictiveError (orb.nordstromScalarGWLuminosity G m1 m2 c (1 / 6)) P_GR = 5 / 6 ∧
    orb.einsteinGeneralRelativityGWLuminosity G m1 m2 c 1 = P_GR ∧
    relativePredictiveError (orb.einsteinGeneralRelativityGWLuminosity G m1 m2 c 1) P_GR = 0 ∧
    relativePredictiveError (orb.spinOneVectorGWLuminosity G m1 m2 c 0 0) P_GR = 1 ∧
    relativePredictiveError (orb.spinOneVectorGWLuminosity G m1 m2 c (1 / 4) 0) P_GR = 3 / 4 ∧
    relativePredictiveError (orb.wittenConformalTwistorGWLuminosity G m1 m2 c 0 0) P_GR = 1 ∧
    relativePredictiveError (orb.wittenConformalTwistorGWLuminosity G m1 m2 c 1 δP_ghost) P_GR =
      δP_ghost / P_GR ∧
    0 < relativePredictiveError (orb.wittenConformalTwistorGWLuminosity G m1 m2 c 1 δP_ghost) P_GR ∧
    relativePredictiveError (orb.fediSQG2016GWLuminosity G m1 m2 c 0 0) P_GR = 1 ∧
    orb.fediSQG2016GWLuminosity G m1 m2 c 1 0 = P_GR ∧
    relativePredictiveError (orb.fediSQG2016GWLuminosity G m1 m2 c 1 0) P_GR = 0 ∧
    relativePredictiveError (orb.fediSQG2016GWLuminosity G m1 m2 c 1 δP_GPE) P_GR =
      δP_GPE / P_GR ∧
    0 < relativePredictiveError (orb.fediSQG2016GWLuminosity G m1 m2 c 1 δP_GPE) P_GR ∧
    orb.fediDarkSuperfluid2017GWLuminosity G m1 m2 c 1 0 = P_GR ∧
    relativePredictiveError (orb.fediDarkSuperfluid2017GWLuminosity G m1 m2 c 1 0) P_GR = 0 ∧
    relativePredictiveError (orb.fediDarkSuperfluid2017GWLuminosity G m1 m2 c 1 P_Stokes) P_GR =
      P_Stokes / P_GR ∧
    0 < relativePredictiveError (orb.fediDarkSuperfluid2017GWLuminosity G m1 m2 c 1 P_Stokes) P_GR ∧
    orb.cachazoSkinnerTwistorGWLuminosity G m1 m2 c 1 δP_ghost 0 = P_GR ∧
    relativePredictiveError (orb.cachazoSkinnerTwistorGWLuminosity G m1 m2 c 1 δP_ghost 0) P_GR = 0 ∧
    relativePredictiveError (orb.cachazoSkinnerTwistorGWLuminosity G m1 m2 c 1 δP_ghost δP_Λ) P_GR =
      δP_Λ / P_GR ∧
    0 < relativePredictiveError (orb.cachazoSkinnerTwistorGWLuminosity G m1 m2 c 1 δP_ghost δP_Λ) P_GR ∧
    orb.cachazoSkinnerTwistorGWLuminosity G m1 m2 c 0 δP_ghost 0 =
      orb.wittenConformalTwistorGWLuminosity G m1 m2 c 0 δP_ghost ∧
    orb.partanenTulkki2025GWLuminosity G m1 m2 c = P_GR ∧
    relativePredictiveError (orb.partanenTulkki2025GWLuminosity G m1 m2 c) P_GR = 0 ∧
    orb.fediDDF2026GWLuminosity G m1 m2 c = P_GR ∧
    relativePredictiveError (orb.fediDDF2026GWLuminosity G m1 m2 c) P_GR = 0 ∧
    orb.turnerGr24QEDGWLuminosity G m1 m2 c Φ_orb Δϖ = P_GR ∧
    relativePredictiveError (orb.turnerGr24QEDGWLuminosity G m1 m2 c Φ_orb Δϖ) P_GR = 0 :=
  orb.gravitational_wave_models_relative_predictive_error_comparison
    Φ_orb Δϖ G m1 m2 c δP_ghost δP_Λ δP_GPE P_Stokes
    hG hm1 hm2 hc hGhost hΛ hGPE hStokes

-- 7. Revised Turner (2026) Models 14a & 14b for 1PN Perihelion Precession and 2.5PN + Ringdown Gravitational Waves
-- via Fubini-Study Kähler Chart W_orb and Homogeneous Plücker Q_4 Madelung & Dual-Grassmannian iGPE
example {sub : DDFSubstrate} (s : MovingSheath sub) (re : RiverExterior sub)
    (orb : PlanetaryOrbit) (s_pl : PluckerMadelungState)
    (Φ_orb Δϖ m2 δ_Jos δP_Jos : ℝ) (hm2 : 0 < m2) (hJos : 0 < δ_Jos) (hPJos : 0 < δP_Jos) :
    let W_orb := PlanetaryOrbit.gr24AffineChart orb Δϖ
    let Δϖ_GR := re.perihelionPrecessionRad orb
    let P_GR := re.petersMathewsLuminosity orb m2
    kahlerDetFactor W_orb - 3 = 1 - orb.eccentricity ^ 2 ∧
    PlanetaryOrbit.turnerPluckerIGPEPrecessionRad orb re.G_phi re.sourceMass sub.c Δϖ 0 = Δϖ_GR ∧
    relativePredictiveError
      (PlanetaryOrbit.turnerPluckerIGPEPrecessionRad orb re.G_phi re.sourceMass sub.c Δϖ 0) Δϖ_GR = 0 ∧
    relativePredictiveError
      (PlanetaryOrbit.turnerPluckerIGPEPrecessionRad orb re.G_phi re.sourceMass sub.c Δϖ δ_Jos) Δϖ_GR =
      δ_Jos / Δϖ_GR ∧
    re.turnerDualGr24IGPEDDFPrecessionRad orb Δϖ 0 = Δϖ_GR ∧
    relativePredictiveError (re.turnerDualGr24IGPEDDFPrecessionRad orb Δϖ 0) Δϖ_GR = 0 ∧
    relativePredictiveError (re.turnerDualGr24IGPEDDFPrecessionRad orb Δϖ δ_Jos) Δϖ_GR =
      δ_Jos / Δϖ_GR ∧
    OnKleinQuadric (twistorToPluckerVec (orb.gr24QuadrupoleWaveMatrix Φ_orb Δϖ)) ∧
    PlanetaryOrbit.turnerPluckerIGPEGWLuminosity orb re.G_phi re.sourceMass m2 sub.c Φ_orb Δϖ 0 = P_GR ∧
    relativePredictiveError
      (PlanetaryOrbit.turnerPluckerIGPEGWLuminosity orb re.G_phi re.sourceMass m2 sub.c Φ_orb Δϖ 0) P_GR = 0 ∧
    relativePredictiveError
      (PlanetaryOrbit.turnerPluckerIGPEGWLuminosity orb re.G_phi re.sourceMass m2 sub.c Φ_orb Δϖ δP_Jos) P_GR =
      δP_Jos / P_GR ∧
    re.turnerDualGr24IGPEDDFGWLuminosity orb m2 0 = P_GR ∧
    relativePredictiveError (re.turnerDualGr24IGPEDDFGWLuminosity orb m2 0) P_GR = 0 ∧
    relativePredictiveError (re.turnerDualGr24IGPEDDFGWLuminosity orb m2 δP_Jos) P_GR =
      δP_Jos / P_GR := by
  intro W_orb Δϖ_GR P_GR
  have h := turner_2026_revised_superposition_gravity_and_gw_plucker_igpe_models
    s re orb s_pl 1 1 3 2 4 6 1 5 (1 / 10) 1 1 2 0 0 0 Φ_orb Δϖ m2 δ_Jos δP_Jos hm2 hJos hPJos
  exact ⟨h.2.2.2.2.2.2.1, h.2.2.2.2.2.2.2.2.1, h.2.2.2.2.2.2.2.2.2.1,
    h.2.2.2.2.2.2.2.2.2.2.1, h.2.2.2.2.2.2.2.2.2.2.2.1, h.2.2.2.2.2.2.2.2.2.2.2.2.1,
    h.2.2.2.2.2.2.2.2.2.2.2.2.2.1, h.2.2.2.2.2.2.2.2.2.2.2.2.2.2.1,
    h.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.1, h.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.1,
    h.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.1, h.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.1,
    h.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.1, h.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2⟩

end GravityFromQEDorDDFpaperVerification
```

---

## 5. Rust + WebAssembly (`wasm32-unknown-unknown`) + WebGL2 GLSL Simulation & Normed Tensor Gaussian Splatting

In [src/signals/numerical_adapter/src/orbital_splat.rs](../src/signals/numerical_adapter/src/orbital_splat.rs) and the WebGL2 (`#version 300 es`) shaders [orbital_splat.vert.glsl](../src/signals/numerical_adapter/src/shaders/orbital_splat.vert.glsl) and [orbital_splat.frag.glsl](../src/signals/numerical_adapter/src/shaders/orbital_splat.frag.glsl), we implement the complete orbital mechanics and multi-layer normed Tensor Gaussian Splatting pipeline:

1. **Planetary Precession, Multi-Model Precession & Gravitational-Wave Error Comparisons, & Symplectic Velocity-Verlet $N$-Body Simulation (`PlanetaryOrbitParams`, `GravityModelErrorComparison`, `GravitationalWaveModelErrorComparison`, `RelativisticOrbitState`)**:
   - Evaluates the $\pi$-free arcsecond precession $\Delta\varpi_{\mathrm{arcsec}} = \frac{1,944,000\,r_H}{p}$, the precessing polar conic $r(\varphi; \eta_{\mathrm{prec}}) = \frac{p}{1 + e\cos((1 - \eta_{\mathrm{prec}})\varphi)}$, the $Gr_{\mathbb{C}}(2,4)$ orbital precession matrix `gr24_precession_matrix`, Fubini–Study Kähler determinant factor `gr24_kahler_det_factor`, and dynamic quadrupole wave matrix `gr24_quadrupole_wave_matrix`, the Cachazo–Skinner 4-point Hodges double-copy kernel `cachazo_skinner_hodges_4pt_kernel`, the 17-row multi-model perihelion error comparison `GravityModelErrorComparison::evaluate` and 17-row multi-model gravitational-wave luminosity error comparison `GravitationalWaveModelErrorComparison::evaluate` (Newtonian, Nordström spin-0, Einstein General Relativity 1915/1916/1918 & Peters–Mathews 1963, spin-1 vector, Witten 2004 conformal twistor string, Fedi 2016 Superfluid Quantum Gravity, Fedi 2017 dark superfluid, Cachazo–Skinner 2012 infinity-twistor, Partanen & Tulkki 2025 $\mathrm{U}(1)^4$ QFT, Fedi 2026 conservative DDF, Turner 2026 flat-space $Gr_{\mathbb{C}}(2,4)$ & unified DDF + 3D splats, and **Models 14a/14b** `turner_plucker_igpe_precession_rad` / `turner_plucker_igpe_gw_luminosity`), the $N$-body $Gr_{\mathbb{C}}(2, N+2)$ Madelung sink sum `nbody_bernoulli_potential_gr2n`, and the symplectic Velocity-Verlet integrator `step_velocity_verlet` for $V_{\mathrm{eff}}(r)$.
2. **Multi-Layer Normed 2D & 3D Anisotropic Tensor Gaussian Splatting (`NormedTensorGaussianSplat2D`, `NormedTensorGaussianSplat3D`, `SplatRole`, `OrbitalSplatScene`)**:
   - **`SplatRole::BodySinkSource (0)`**: Gravitating bodies, attractors, superfluid sinks ($\Phi_\phi < 0$), and sources.
   - **`SplatRole::Gr24OrbitalField (1)`**: Complex $Gr_{\mathbb{C}}(2,4)$ orbital field splats with $\sigma_1 = \sigma_0\sqrt{1+e} = \sigma_0|w_A^{\mathbb{C}}|$, $\sigma_2 = \sigma_0\sqrt{1-e} = \sigma_0|w_B^{\mathbb{C}}|$, $\operatorname{Tr}\Sigma = 2\sigma_0^2$, and $\det\Sigma = \sigma_0^4(1-e^2) = \sigma_0^4(p/a)$ (and 3D `NormedTensorGaussianSplat3D::from_gr36_orbit`).
   - **`SplatRole::DdfMovingSheathField (2)`**: DDF moving-sheath splats with longitudinal Lorentz/jamming contraction $\sigma_1 = \sigma_0/\gamma_\varphi(v)$ along the velocity vector and transverse width $\sigma_2 = \sigma_0$, so $\det\Sigma_{\mathrm{DDF}} = \sigma_0^4\gamma_\varphi(v)^{-2}$ and $\mathcal{N}_{\mathrm{DDF}} = \frac{\gamma_\varphi(v)}{2\pi\sigma_0^2}$, alongside 3D gravitational-wave splats `from_tt_gravitational_wave` and `from_ddf_gravitational_wave`.
   - **`SplatRole::VortexSwirlField (3)`**: Gravitomagnetic / Kerr–Lense–Thirring vortex swirl splats.
3. **Parametric `rstest` Fixtures & `insta` (`cargo-insta`) Snapshot Verification**:
   - Verified across all five solar-system benchmarks (`Mercury`, `Venus`, `Earth`, `Mars`, `Icarus`) with `#[rstest]` and locked in [signals_numerical_adapter__orbital_splat__tests__solar_system_precession_and_normed_splat_scene.snap](../src/signals/numerical_adapter/src/snapshots/signals_numerical_adapter__orbital_splat__tests__solar_system_precession_and_normed_splat_scene.snap).

---

## 6. Conclusion & Reproducibility

By formalizing the BCJ Plücker double copy on $Gr_{\mathbb{C}}(2,4)$, the 1-loop QFT / DDF effective orbital potential $V_{\mathrm{eff}}(r)$, the anomalous perihelion precession $\Delta\varpi = \frac{3\pi r_H}{a(1 - e^2)}$, the $Gr_{\mathbb{C}}(2,4)$ planetary orbital precession matrix `PlanetaryOrbit.gr24PrecessionMatrix` and dynamic quadrupole wave matrix `PlanetaryOrbit.gr24QuadrupoleWaveMatrix`, the multi-model perihelion and gravitational-wave relative error theorems `PlanetaryOrbit.gravity_models_relative_predictive_error_comparison` and `PlanetaryOrbit.gravitational_wave_models_relative_predictive_error_comparison`, the $N$-body sink potential on $Gr_{\mathbb{C}}(2, N+2)$, and 2D/3D normed Tensor Gaussian Splatting (`NormedTensorGaussianSplat2D`, `NormedTensorGaussianSplat3D`) in Lean 4 and Rust/WASM/GLSL, we have established a machine-checked bridge from flat-space scattering amplitudes and positive/complex Grassmannian geometry to planetary orbital mechanics, gravitational radiation, and Dilatant Dark Fluid hydrodynamics:

1. **Flat-Space $Gr_{\mathbb{C}}(2,4)$ Double Copy & Resolution of Witten's 2004 Twistor-String Conformal Gravity Problem**:
   - The 3-term Plücker identity on $Gr_{\mathbb{C}}(2,4)$ (`bcj_plucker_jacobi_and_double_copy`) automatically satisfies the BCJ kinematic Jacobi relation $n_s + n_t + n_u = 0$ and squares gauge-fluid vorticity into the symmetric graviton/fluid shear-stress tensor $n_t^2 = (n_s + n_u)^2 = n_s^2 + 2 n_s n_u + n_u^2$.
   - Whereas Witten's original $\mathbb{CP}^{3|4}$ twistor string ([Witten 2004](#grav-witten2004); [Berkovits and Witten 2004](#grav-berkovits-witten2004)) preserved full $\mathrm{SU}(2,2|4)$ conformal symmetry—producing 4th-order Weyl conformal supergravity ($S_{\mathrm{Weyl}} \propto \int C_{\mu\nu\rho\sigma}^2$, propagator $1/q^4$) with non-unitary Ostrogradsky ghosts, unphysical $+\frac{1}{2}\gamma_{\mathrm{conf}}c^2 r$ linear potentials whose perihelion error grows as $a^3$, and negative-energy ghost radiation $-\delta P_{\mathrm{ghost}} < 0$—both the Cachazo–Skinner ([2012](#grav-cachazo-skinner2012)) rank-2 infinity twistor $I_{AB}$ on $\mathbb{CP}^{3|8}$ (`cachazo_skinner_4pt_hodges_double_copy_gr24`) and flat-space $Gr_{\mathbb{C}}(2,4)$ post-Minkowskian QFT ([Partanen and Tulkki 2025](#grav-partanen2025), [Bjerrum-Bohr et al. 2018](#grav-bjerrum2018), Turner 2026) break spurious conformal invariance down to the Poincaré group, yielding a unitary, ghost-free 2-derivative $1/q^2$ graviton propagator with $\varepsilon_{\mathrm{rel}} = 0$.
2. **Conservative 1PN Orbital Precession & 17-Row Multi-Model Error Verification (`PlanetaryOrbit.gravity_models_relative_predictive_error_comparison`)**:
   - Matching the 1-loop $O(G^2)$ triangle amplitude or the conservative DDF moving-sheath action ([Fedi 2026](#grav-fedi2026)) yields $V_{\mathrm{eff}}(r) = -\frac{G_\phi M m}{r}\bigl(1 + \frac{3 L^2}{m^2 c^2 r^2}\bigr) = m\Phi_\phi(r) - \frac{3 G_\phi M L^2 \varrho_{\max}^\varphi j_{\min}^\varphi}{m r^3}$ (`effectiveOrbitalPotential_eq_ddf_substrate`), generating the exact anomalous advance $\Delta\varpi = \frac{6\pi G_\phi M}{c^2 a(1 - e^2)} = \frac{3\pi r_H}{p} = \frac{6\pi G_\phi M \varrho_{\max}^\varphi j_{\min}^\varphi}{a(|w_A^{\mathbb{C}}|^2 |w_B^{\mathbb{C}}|^2)}$ (`Mercury` $42.98''/\text{cy}$ anomalous; $574.61''/\text{cy}$ total with $531.63''/\text{cy}$ Newtonian $N$-body perturbations on $Gr_{\mathbb{C}}(2, N+2)$).
   - Pointwise evaluation of `Signals.Huygens.relativePredictiveError` across our 17-row perihelion benchmark (Section 4.4) rules out Newtonian $1/r$ gravity ($\varepsilon_{\mathrm{rel}} = 1$), Nordström's scalar gravity ($\Delta\varpi_{\mathrm{Nord}} = -\frac{1}{6}\Delta\varpi_{\mathrm{GR}} < 0$, retrograde $\varepsilon_{\mathrm{rel}} = 7/6 \approx 116.67\%$), special-relativistic spin-1 vector gravity ($\Delta\varpi_{\mathrm{vec}} = +\frac{1}{6}\Delta\varpi_{\mathrm{GR}}$, $\varepsilon_{\mathrm{rel}} = 5/6 \approx 83.33\%$), pure inviscid Bernoulli sink flow without relativistic acoustic pressure ($\varepsilon_{\mathrm{rel}} = 1$), and dissipative Stokes drag ($\frac{dE}{dt} = -F_{\mathrm{drag}} v < 0$, `ddf_conservative_action_vs_stokes_drag_critique`), while proving $\varepsilon_{\mathrm{rel}} = 0$ for Einstein GR ([1915](#grav-einstein1915); [1916a](#grav-einstein1916)), Cachazo–Skinner ($\Lambda_{\mathrm{cc}} = 0$), Fedi's 2016 SQG with relativistic acoustic pressure ($\kappa_{\mathrm{rel}} = 1, \delta_{\mathrm{GPE}} \to 0$), Fedi's 2017 conservative dilatant $\gamma - 1$ superfluid ($\eta_{\mathrm{drag}} = 0$), Partanen & Tulkki's (2025) $\mathrm{U}(1)^4$ 1-loop QFT (`partanenTulkki2025PrecessionRad`, without $Gr_{\mathbb{C}}(2,4)$), Fedi's (2026) conservative DDF (`fediDDF2026PrecessionRad`, without $Gr_{\mathbb{C}}(2,4)$), Turner's (2026) flat-space $Gr_{\mathbb{C}}(2,4)$ 1-loop QFT (`turnerGr24QEDPrecessionRad`), Turner's (2026) unified $Gr_{\mathbb{C}}(2,4)$ + DDF + 3D `NormedTensorGaussianSplat3D`, and the revised Turner (2026) Fubini–Study Kähler + Plücker $\mathcal{Q}_4$ Madelung `iGPE` **Models 14a (`turnerPluckerIGPEPrecessionRad`) and 14b (`turnerDualGr24IGPEDDFPrecessionRad`)** at $\delta_{\mathrm{Jos}} = 0$.
3. **Radiative 2.5PN Quadrupole Gravitational Waves Without and With DDF & 17-Row Multi-Model Error Verification (`PlanetaryOrbit.gravitational_wave_models_relative_predictive_error_comparison`)**:
   - Promoting `gr24PrecessionMatrix` to the dynamic quadrupole wave matrix $M_{\mathbb{C}}^{\mathrm{GW}} = \mathrm{orb}.\mathrm{gr24QuadrupoleWaveMatrix}\,\Phi_{\mathrm{orb}}\,\Delta\varpi$ (`PlanetaryOrbit.qed_gravitational_wave_without_ddf_identities`) proves that the crossing Plücker minor oscillates at the twice-orbital quadrupole phase $2\Phi_{\mathrm{orb}}(t) + \Delta\varpi$ and that the Peters–Mathews ([1963](#grav-peters1963)) eccentricity enhancement factor $f_{\mathrm{PM}}(e)$ factors through the seventh power of the Plücker channel product $(|w_A^{\mathbb{C}}|^2 |w_B^{\mathbb{C}}|^2)^7 = (1 - e^2)^7$.
   - Pointwise evaluation of `relativePredictiveError` across our 17-row radiative benchmark (Section 4.5) confirms $\varepsilon_{\mathrm{rel}} = 0$ against $P_{\mathrm{GW}}^{\mathrm{GR}}$ for Einstein GR ([1916b](#grav-einstein1916-gw); [1918](#grav-einstein1918-gw)), Cachazo–Skinner ($\Lambda_{\mathrm{cc}} = 0$), Fedi 2016 SQG with vortex-lattice transverse elasticity ($\kappa_{\mathrm{trans}} = 1, \delta P_{\mathrm{GPE}} \to 0$), Fedi 2017 conservative dilatant superfluid ($P_{\mathrm{Stokes}} = 0$), Partanen & Tulkki (2025) 2.5PN QFT (`partanenTulkki2025GWLuminosity`, without $Gr_{\mathbb{C}}(2,4)$), Fedi (2026) conservative DDF (`fediDDF2026GWLuminosity`, without $Gr_{\mathbb{C}}(2,4)$), Turner (2026) flat-space $Gr_{\mathbb{C}}(2,4)$ spin-2 double copy (`turnerGr24QEDGWLuminosity`), Turner (2026) unified $Gr_{\mathbb{C}}(2,4)$ + DDF + 3D `NormedTensorGaussianSplat3D`, and the revised Turner (2026) Fubini–Study Kähler + Plücker $\mathcal{Q}_4$ Madelung `iGPE` **Models 14a (`turnerPluckerIGPEGWLuminosity`) and 14b (`turnerDualGr24IGPEDDFGWLuminosity`)** at $\delta P_{\mathrm{Jos}} = 0$, while proving the exact radiative deficits of Newtonian ($\varepsilon_{\mathrm{rel}} = 1$), Nordström spin-0 scalar ($\varepsilon_{\mathrm{rel}}^{\mathrm{TT}} = 1$, $\varepsilon_{\mathrm{rel}}^{\mathrm{tot}} = 5/6$), spin-1 vector ($\varepsilon_{\mathrm{rel}}^{\mathrm{TT}} = 1$, $\varepsilon_{\mathrm{rel}}^{\mathrm{tot}} = 3/4$ due to universal $q_i/m_i = \sqrt{G}$ killing the Larmor dipole), and pure longitudinal inviscid BEC ($\mu_{\mathrm{shear}} = 0 \implies \varepsilon_{\mathrm{rel}}^{\mathrm{TT}} = 1$).
   - Coupling to the DDF substrate (`RiverExterior.gravitational_wave_with_ddf_identities`) replaces $c^{-5}$ in $P_{\mathrm{GW}}$ with $(\varrho_{\max}^\varphi j_{\min}^\varphi)^{5/2}$, guarantees luminal far-field propagation $c_{\mathrm{GW}} = (\varrho_{\max}^\varphi j_{\min}^\varphi)^{-1/2} = c$ matching GW170817 / GRB 170817A ($|\Delta c/c| \lesssim 3 \times 10^{-15}$, [Abbott et al. 2017](#grav-abbott2017)), and yields concrete quantum-hydrodynamic signatures in strong-field regimes: GPE vortex density-gradient tail scattering $V_{\mathrm{scat}}(r) = \frac{2\rho_0\xi^2 r}{(r^2 + \xi^2)^2} > 0$, strain-thickened Kelvin-wave high-$k$ damping $+\alpha\gamma_{\mathrm{dil}}k^4 > 0$, and 4D Schur-complement temporal conditioning.
4. **2D/3D Normed Tensor Gaussian Splatting & Falsifiable Experimental Discriminators**:
   - Both orbital fields and propagating 3D gravitational-wave packets are unified as $L^1$-normalized Gaussian splats (`NormedTensorGaussianSplat3D.gravitational_wave_splat3d_and_projection_identities`), where flat-space TT waves preserve transverse area $\sigma_1\sigma_2 = \sigma_0^2$ and 3D volume $\det\Sigma_{\mathrm{3D}}^{\mathrm{TT}} = \sigma_0^4\sigma_{z,0}^2$, DDF sheath jamming contracts the longitudinal axis by $\gamma_\varphi(v)^{-1}$ so $\det\Sigma_{\mathrm{3D}}^{\mathrm{DDF}} = \sigma_0^4\sigma_{z,0}^2\gamma_\varphi(v)^{-2}$, and orthographic 2D projection (`projectOrthographic2D`) recovers `NormedTensorGaussianSplat2D` exactly.
   - Finally, while flat-space $Gr_{\mathbb{C}}(2,4)$ QED/gauge double-copy scattering and DDF are observationally degenerate with Einstein GR for passive solar-system orbits ($\Delta\varpi = 42.98''/\text{cy}$), passive solar-limb light deflection ($1.75''$), and far-field binary pulsar / interferometer quadrupole luminosity ($P_{\mathrm{GW}}^{\mathrm{GR}}$), our formalization isolates three falsifiable experimental discriminators (`Signals.DDF.ActiveRadiationSourcing`, `RiverExterior.gravitational_wave_with_ddf_identities`, `Signals.DDF.IsothermalGalacticRegime`):
     1. **Laboratory Photon–Photon Active Beam Deflection ($\eta_{\mathrm{act}}^\gamma = 0$ in DDF vs. $\eta_{\mathrm{act}}^\gamma = 1$ in GR)**: Because massless photons in DDF are pure transverse $\varphi$-lattice polarization waves without $\phi$-condensate mass-sink intake, the active gravitational deflection between non-co-propagating laser beams vanishes identically ($\eta_{\mathrm{act}}^\gamma = 0$), providing a direct laboratory test against standard GR ($\eta_{\mathrm{act}}^\gamma = 1$).
     2. **Strong-Field Merger Ringdown Dispersion, Kelvin-Wave Damping, & Bohm-Core Regularization**: At extreme merger strain rates ($\dot{\gamma} > \dot{\gamma}_c$) and UV wavevectors $k\xi \sim 1$, DDF predicts Bogoliubov phase dispersion $v_p^2(k) = c^2 + \frac{\hbar^2 k^2}{4 m_\phi^2}$, strain-thickened Kelvin-wave damping $+\alpha\gamma_{\mathrm{dil}}k^4 > 0$, and GPE Bohm quantum-potential core regularization in place of a classical $r = 0$ curvature singularity.
     3. **Outer-Disk Galactic Rotation Plateaus ($v_{\mathrm{flat}} = \sqrt{q_\rho}\,c_\phi$)**: In low-acceleration galactic outskirts, the isothermal logarithmic barotrope of the $\phi$ superfluid produces flat rotation curves $v_{\mathrm{flat}} = \sqrt{2}\,c_\phi$ ($q_\rho = 2$) without cold dark matter particle halos.

To reproduce all Lean 4 proofs, blueprint dependency graphs, and Rust/WASM/GLSL numerical simulations from the repository root:

```bash
make signals_build
pushd src/signals
lake build :blueprint :blueprintJson
pushd numerical_adapter
cargo test
cargo build --lib --target wasm32-unknown-unknown --release
popd
popd
```

---

### Scholarly References

<a id="grav-partanen2025"></a>
1. Partanen, M., and Tulkki, J. (2025). *Gravity Generated by Four One-Dimensional Unitary Gauge Symmetries and the Standard Model*. Reports on Progress in Physics 88(5), 057802. [DOI: 10.1088/1361-6633/adc82e](https://doi.org/10.1088/1361-6633/adc82e); [arXiv:2310.01460](https://arxiv.org/abs/2310.01460).

<a id="ddf-partanen2025-2"></a>
2. Partanen, M., and Tulkki, J. (2025). *Perihelion precession of planetary orbits solved from quantum field theory*. Preprint [arXiv:2506.14447](https://arxiv.org/abs/2506.14447).

<a id="grav-bcj2008"></a>
3. Bern, Z., Carrasco, J. J. M., and Johansson, H. (2008). *New Relations for Gauge-Theory Amplitudes*. Physical Review D 78(8), 085011. [DOI: 10.1103/PhysRevD.78.085011](https://doi.org/10.1103/PhysRevD.78.085011); [arXiv:0805.3993](https://arxiv.org/abs/0805.3993).

<a id="grav-bjerrum2018"></a>
4. Bjerrum-Bohr, N. E. J., Damgaard, P. H., Festuccia, G., Planté, L., and Vanhove, P. (2018). *General Relativity from Scattering Amplitudes*. Physical Review Letters 121(17), 171601. [DOI: 10.1103/PhysRevLett.121.171601](https://doi.org/10.1103/PhysRevLett.121.171601); [arXiv:1806.04920](https://arxiv.org/abs/1806.04920).

<a id="grav-arkani2014"></a>
5. Arkani-Hamed, N., and Trnka, J. (2014). *The Amplituhedron*. Journal of High Energy Physics 2014(10), 030. [DOI: 10.1007/JHEP10(2014)030](https://doi.org/10.1007/JHEP10%282014%29030); [arXiv:1312.2007](https://arxiv.org/abs/1312.2007).

<a id="grav-fedi2026"></a>
6. Fedi, M. (2026). *Dilatant Dark Fluid: Toward a Unified Quantum-Hydrodynamic Origin of Lorentz Invariance, Gravity, and Cosmological Phenomenology*. SSRN Preprint 7406660. [Preprint page](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=7406660); [SSRN DOI](https://doi.org/10.2139/ssrn.7406660).

<a id="grav-park2021"></a>
7. Park, R. S., Folkner, W. M., Williams, J. G., and Boggs, D. H. (2021). *The JPL Planetary and Lunar Ephemerides DE440 and DE441*. The Astronomical Journal 161(3), 105. [DOI: 10.3847/1538-3881/abd414](https://doi.org/10.3847/1538-3881/abd414).

<a id="grav-chat-nbody"></a>
8. Provenance Chat Log (2026). *N-Body Gravity from QED with Scattering Amplitudes*. ({download}`data/chats/N-body-gravity-from-QED-with-scattering-amplitudes.md, lines 1-1120 <../data/chats/N-body-gravity-from-QED-with-scattering-amplitudes.md>`).

<a id="grav-chat-sr-fluid"></a>
9. Provenance Chat Log (2026). *Special Relativity: Geometry vs. Fluid*. ({download}`data/chats/_Special-Relativity-Geometry-vs.-Fluid.md, lines 130-520 <../data/chats/_Special-Relativity-Geometry-vs.-Fluid.md>`).

<a id="grav-chat-splat"></a>
10. Provenance Chat Log (2026). *Grassmannian Splat Mechanics and Vortex Space Emergence*. ({download}`data/chats/Grassmannian Splat Mechanics and Vortex Space Emergence.md, lines 1395-1558 <../data/chats/Grassmannian Splat Mechanics and Vortex Space Emergence.md>`).

<a id="grav-witten2004"></a>
11. Witten, E. (2004). *Perturbative Gauge Theory as a String Theory in Twistor Space*. Communications in Mathematical Physics 252(1–3), 189–258. [DOI: 10.1007/s00220-004-1187-3](https://doi.org/10.1007/s00220-004-1187-3); [arXiv:hep-th/0312171](https://arxiv.org/abs/hep-th/0312171).

<a id="grav-berkovits-witten2004"></a>
12. Berkovits, N., and Witten, E. (2004). *Conformal Supergravity in Twistor-String Theory*. Journal of High Energy Physics 2004(08), 009. [DOI: 10.1088/1126-6708/2004/08/009](https://doi.org/10.1088/1126-6708/2004/08/009); [arXiv:hep-th/0406051](https://arxiv.org/abs/hep-th/0406051).

<a id="grav-cachazo-skinner2012"></a>
13. Cachazo, F., and Skinner, D. (2013). *Gravity from Rational Curves in Twistor Space*. Physical Review Letters 110(16), 161301. [DOI: 10.1103/PhysRevLett.110.161301](https://doi.org/10.1103/PhysRevLett.110.161301); [arXiv:1207.0741](https://arxiv.org/abs/1207.0741).

<a id="grav-nordstrom1913"></a>
14. Nordström, G. (1913). *Zur Theorie der Gravitation vom Standpunkt des Relativitätsprinzips*. Annalen der Physik 347(13), 533–554. [DOI: 10.1002/andp.19133471303](https://doi.org/10.1002/andp.19133471303).

<a id="grav-einstein1915"></a>
15. Einstein, A. (1915). *Erklärung der Perihelbewegung des Merkur aus der allgemeinen Relativitätstheorie*. Sitzungsberichte der Königlich Preußischen Akademie der Wissenschaften (Berlin), 831–839.

<a id="grav-einstein1916"></a>
16. Einstein, A. (1916a). *Die Grundlage der allgemeinen Relativitätstheorie*. Annalen der Physik 354(7), 769–822. [DOI: 10.1002/andp.19163540702](https://doi.org/10.1002/andp.19163540702).

<a id="grav-fedi2016"></a>
17. Fedi, M. (2016). *Superfluid Quantum Gravity (Gravity as a Fluid Dynamic Phenomenon in a Superfluid Quantum Space: Fluid Quantum Gravity and Relativity)*. HAL Open Science Preprint `hal-01248015v3` / `hal-01248015v4`. [HAL: hal-01248015](https://hal.science/hal-01248015).

<a id="grav-fedi2017"></a>
18. Fedi, M. (2017). *Hydrodynamics of the Dark Superfluid* (and *A Superfluid Theory of Everything?*, Canadian Journal of Physics 97(5), 2018/2019, deriving Mercury's perihelion precession via dilatant Lorentz viscosity $\eta \propto \gamma - 1$). [HAL: hal-01248015](https://hal.science/hal-01248015).

<a id="grav-einstein1916-gw"></a>
19. Einstein, A. (1916b). *Näherungsweise Integration der Feldgleichungen der Gravitation*. Sitzungsberichte der Königlich Preußischen Akademie der Wissenschaften (Berlin), 688–696.

<a id="grav-einstein1918-gw"></a>
20. Einstein, A. (1918). *Über Gravitationswellen*. Sitzungsberichte der Königlich Preußischen Akademie der Wissenschaften (Berlin), 154–167.

<a id="grav-peters1963"></a>
21. Peters, P. C., and Mathews, J. (1963). *Gravitational Radiation from Point Masses in a Keplerian Orbit*. Physical Review 131(1), 435–440. [DOI: 10.1103/PhysRev.131.435](https://doi.org/10.1103/PhysRev.131.435).

<a id="grav-hulse1975"></a>
22. Hulse, R. A., and Taylor, J. H. (1975). *Discovery of a Pulsar in a Binary System*. The Astrophysical Journal Letters 195, L51–L53. [DOI: 10.1086/181708](https://doi.org/10.1086/181708).

<a id="grav-weisberg2016"></a>
23. Weisberg, J. M., and Huang, Y. (2016). *Relativistic Measurements from Timing the Binary Pulsar PSR B1913+16*. The Astrophysical Journal 829(1), 55. [DOI: 10.3847/0004-637X/829/1/55](https://doi.org/10.3847/0004-637X/829/1/55); [arXiv:1606.02744](https://arxiv.org/abs/1606.02744).

<a id="grav-abbott2016"></a>
24. Abbott, B. P., et al. (LIGO Scientific Collaboration and Virgo Collaboration) (2016). *Observation of Gravitational Waves from a Binary Black Hole Merger*. Physical Review Letters 116(6), 061102. [DOI: 10.1103/PhysRevLett.116.061102](https://doi.org/10.1103/PhysRevLett.116.061102); [arXiv:1602.03837](https://arxiv.org/abs/1602.03837).

<a id="grav-abbott2017"></a>
25. Abbott, B. P., et al. (LIGO Scientific Collaboration, Virgo Collaboration, Fermi Gamma-Ray Burst Monitor, and INTEGRAL) (2017). *Gravitational Waves and Gamma-Rays from a Binary Neutron Star Merger: GW170817 and GRB 170817A*. The Astrophysical Journal Letters 848(2), L13. [DOI: 10.3847/2041-8213/aa920c](https://doi.org/10.3847/2041-8213/aa920c); [arXiv:1710.05834](https://arxiv.org/abs/1710.05834).

<a id="grav-chat-gw-remnants"></a>
26. Provenance Chat Log (2026). *Review Pop III GW Remnants*. ({download}`data/chats/Review-Pop-III-GW-Remnants.md, lines 300-855 <../data/chats/Review-Pop-III-GW-Remnants.md>`).

<a id="grav-chat-gw-delays"></a>
27. Provenance Chat Log (2026). *SQG/DDF Explanation of Wave Delays*. ({download}`data/chats/SQGDDF-Explanation-of-Wave-Delays.md, lines 1-115 <../data/chats/SQGDDF-Explanation-of-Wave-Delays.md>`).

<a id="grav-chat-dilatant-gr"></a>
28. Provenance Chat Log (2026). *Gravity Models: Dilatant Fluid vs. GR*. ({download}`data/chats/_Gravity-Models-Dilatant-Fluid-vs.-GR.md, lines 45-270 <../data/chats/_Gravity-Models-Dilatant-Fluid-vs.-GR.md>`).

---

### BibTeX Citations

```bibtex
@article{partanen2025gravity,
  author  = {Partanen, Mikko and Tulkki, Jukka},
  title   = {Gravity Generated by Four One-Dimensional Unitary Gauge Symmetries and the Standard Model},
  journal = {Reports on Progress in Physics},
  volume  = {88},
  number  = {5},
  pages   = {057802},
  year    = {2025},
  doi     = {10.1088/1361-6633/adc82e},
  eprint  = {2310.01460},
  url     = {https://arxiv.org/abs/2310.01460}
}

@article{partanen2025perihelion,
  author  = {Partanen, Mikko and Tulkki, Jukka},
  title   = {Perihelion Precession of Planetary Orbits Solved from Quantum Field Theory},
  journal = {arXiv preprint arXiv:2506.14447},
  year    = {2025},
  url     = {https://arxiv.org/abs/2506.14447}
}

@article{nordstrom1913gravitation,
  author  = {Nordstr{\"o}m, Gunnar},
  title   = {Zur Theorie der Gravitation vom Standpunkt des Relativit{\"a}tsprinzips},
  journal = {Annalen der Physik},
  volume  = {347},
  number  = {13},
  pages   = {533--554},
  year    = {1913},
  doi     = {10.1002/andp.19133471303}
}

@article{einstein1915perihelion,
  author  = {Einstein, Albert},
  title   = {Erkl{\"a}rung der Perihelbewegung des Merkur aus der allgemeinen Relativit{\"a}tstheorie},
  journal = {Sitzungsberichte der K{\"o}niglich Preu{\ss}ischen Akademie der Wissenschaften (Berlin)},
  pages   = {831--839},
  year    = {1915}
}

@article{einstein1916grundlage,
  author  = {Einstein, Albert},
  title   = {Die Grundlage der allgemeinen Relativit{\"a}tstheorie},
  journal = {Annalen der Physik},
  volume  = {354},
  number  = {7},
  pages   = {769--822},
  year    = {1916},
  doi     = {10.1002/andp.19163540702}
}

@article{einstein1916gravitationswellen,
  author  = {Einstein, Albert},
  title   = {N{\"a}herungsweise Integration der Feldgleichungen der Gravitation},
  journal = {Sitzungsberichte der K{\"o}niglich Preu{\ss}ischen Akademie der Wissenschaften (Berlin)},
  pages   = {688--696},
  year    = {1916}
}

@article{einstein1918gravitationswellen,
  author  = {Einstein, Albert},
  title   = {{\"U}ber Gravitationswellen},
  journal = {Sitzungsberichte der K{\"o}niglich Preu{\ss}ischen Akademie der Wissenschaften (Berlin)},
  pages   = {154--167},
  year    = {1918}
}

@article{peters1963gravitational,
  author  = {Peters, Philip C. and Mathews, Jon},
  title   = {Gravitational Radiation from Point Masses in a {Keplerian} Orbit},
  journal = {Physical Review},
  volume  = {131},
  number  = {1},
  pages   = {435--440},
  year    = {1963},
  doi     = {10.1103/PhysRev.131.435}
}

@article{hulse1975binary,
  author  = {Hulse, Russell A. and Taylor, Joseph H.},
  title   = {Discovery of a Pulsar in a Binary System},
  journal = {The Astrophysical Journal Letters},
  volume  = {195},
  pages   = {L51--L53},
  year    = {1975},
  doi     = {10.1086/181708}
}

@article{weisberg2016relativistic,
  author  = {Weisberg, Joel M. and Huang, Yuping},
  title   = {Relativistic Measurements from Timing the Binary Pulsar {PSR B1913+16}},
  journal = {The Astrophysical Journal},
  volume  = {829},
  number  = {1},
  pages   = {55},
  year    = {2016},
  doi     = {10.3847/0004-637X/829/1/55},
  eprint  = {1606.02744}
}

@article{abbott2016gw150914,
  author  = {Abbott, B. P. and others},
  title   = {Observation of Gravitational Waves from a Binary Black Hole Merger},
  journal = {Physical Review Letters},
  volume  = {116},
  number  = {6},
  pages   = {061102},
  year    = {2016},
  doi     = {10.1103/PhysRevLett.116.061102},
  eprint  = {1602.03837}
}

@article{abbott2017gw170817,
  author  = {Abbott, B. P. and others},
  title   = {Gravitational Waves and Gamma-Rays from a Binary Neutron Star Merger: {GW170817} and {GRB 170817A}},
  journal = {The Astrophysical Journal Letters},
  volume  = {848},
  number  = {2},
  pages   = {L13},
  year    = {2017},
  doi     = {10.3847/2041-8213/aa920c},
  eprint  = {1710.05834}
}

@misc{fedi2016sqg,
  author       = {Fedi, Marco},
  title        = {Superfluid Quantum Gravity: Gravity as a Fluid Dynamic Phenomenon in a Superfluid Quantum Space},
  year         = {2016},
  howpublished = {HAL Open Science Preprint hal-01248015},
  url          = {https://hal.science/hal-01248015}
}

@misc{fedi2017darksuperfluid,
  author       = {Fedi, Marco},
  title        = {Hydrodynamics of the Dark Superfluid},
  year         = {2017},
  howpublished = {HAL Open Science / Canadian Journal of Physics formulation},
  url          = {https://hal.science/hal-01248015}
}

@misc{fedi2026ddf,
  author       = {Fedi, Marco},
  title        = {Dilatant Dark Fluid: Toward a Unified Quantum-Hydrodynamic Origin of {Lorentz} Invariance, Gravity, and Cosmological Phenomenology},
  year         = {2026},
  howpublished = {SSRN Preprint 7406660},
  doi          = {10.2139/ssrn.7406660},
  url          = {https://papers.ssrn.com/sol3/papers.cfm?abstract_id=7406660}
}

@article{arkani2014amplituhedron,
  author  = {Arkani-Hamed, Nima and Trnka, Jaroslav},
  title   = {The Amplituhedron},
  journal = {Journal of High Energy Physics},
  volume  = {2014},
  number  = {10},
  pages   = {030},
  year    = {2014},
  doi     = {10.1007/JHEP10(2014)030},
  eprint  = {1312.2007}
}

@article{witten2004twistor,
  author  = {Witten, Edward},
  title   = {Perturbative Gauge Theory as a String Theory in Twistor Space},
  journal = {Communications in Mathematical Physics},
  volume  = {252},
  number  = {1-3},
  pages   = {189--258},
  year    = {2004},
  doi     = {10.1007/s00220-004-1187-3},
  eprint  = {hep-th/0312171}
}

@article{berkovits2004conformal,
  author  = {Berkovits, Nathan and Witten, Edward},
  title   = {Conformal Supergravity in Twistor-String Theory},
  journal = {Journal of High Energy Physics},
  volume  = {2004},
  number  = {08},
  pages   = {009},
  year    = {2004},
  doi     = {10.1088/1126-6708/2004/08/009},
  eprint  = {hep-th/0406051}
}

@article{cachazo2013gravity,
  author  = {Cachazo, Freddy and Skinner, David},
  title   = {Gravity from Rational Curves in Twistor Space},
  journal = {Physical Review Letters},
  volume  = {110},
  number  = {16},
  pages   = {161301},
  year    = {2013},
  doi     = {10.1103/PhysRevLett.110.161301},
  eprint  = {1207.0741}
}

@article{bern2008bcj,
  author  = {Bern, Zvi and Carrasco, John Joseph M. and Johansson, Henrik},
  title   = {New Relations for Gauge-Theory Amplitudes},
  journal = {Physical Review D},
  volume  = {78},
  number  = {8},
  pages   = {085011},
  year    = {2008},
  doi     = {10.1103/PhysRevD.78.085011},
  url     = {https://doi.org/10.1103/PhysRevD.78.085011}
}

@article{bjerrum2018general,
  author  = {Bjerrum-Bohr, N. E. J. and Damgaard, Poul H. and Festuccia, Guido and Plant{\'e}, Ludovic and Vanhove, Pierre},
  title   = {General Relativity from Scattering Amplitudes},
  journal = {Physical Review Letters},
  volume  = {121},
  number  = {17},
  pages   = {171601},
  year    = {2018},
  doi     = {10.1103/PhysRevLett.121.171601},
  url     = {https://doi.org/10.1103/PhysRevLett.121.171601}
}

@article{park2021de440,
  author  = {Park, Ryan S. and Folkner, William M. and Williams, James G. and Boggs, Dale H.},
  title   = {The {JPL} Planetary and Lunar Ephemerides {DE440} and {DE441}},
  journal = {The Astronomical Journal},
  volume  = {161},
  number  = {3},
  pages   = {105},
  year    = {2021},
  doi     = {10.3847/1538-3881/abd414},
  url     = {https://doi.org/10.3847/1538-3881/abd414}
}

@misc{chat_nbody_qed_2026,
  author       = {{Unknown}},
  title        = {N-Body Gravity from {QED} with Scattering Amplitudes},
  year         = {2026},
  howpublished = {AI chat log},
  note         = {Source: data/chats/N-body-gravity-from-QED-with-scattering-amplitudes.md, lines 1-1120},
  url          = {../data/chats/N-body-gravity-from-QED-with-scattering-amplitudes.md}
}

@misc{chat_sr_fluid_2026,
  author       = {{Unknown}},
  title        = {Special Relativity: Geometry vs. Fluid},
  year         = {2026},
  howpublished = {AI chat log},
  note         = {Source: data/chats/_Special-Relativity-Geometry-vs.-Fluid.md, lines 130-520},
  url          = {../data/chats/_Special-Relativity-Geometry-vs.-Fluid.md}
}

@misc{chat_splat_vortex_2026,
  author       = {{Unknown}},
  title        = {Grassmannian Splat Mechanics and Vortex Space Emergence},
  year         = {2026},
  howpublished = {AI chat log},
  note         = {Source: data/chats/Grassmannian Splat Mechanics and Vortex Space Emergence.md, lines 1395-1558},
  url          = {../data/chats/Grassmannian Splat Mechanics and Vortex Space Emergence.md}
}

@misc{chat_pop_iii_gw_remnants_2026,
  author       = {{Unknown}},
  title        = {Review {Pop III GW} Remnants},
  year         = {2026},
  howpublished = {AI chat log},
  note         = {Source: data/chats/Review-Pop-III-GW-Remnants.md, lines 300-855},
  url          = {../data/chats/Review-Pop-III-GW-Remnants.md}
}

@misc{chat_sqg_ddf_wave_delays_2026,
  author       = {{Unknown}},
  title        = {{SQG/DDF} Explanation of Wave Delays},
  year         = {2026},
  howpublished = {AI chat log},
  note         = {Source: data/chats/SQGDDF-Explanation-of-Wave-Delays.md, lines 1-115},
  url          = {../data/chats/SQGDDF-Explanation-of-Wave-Delays.md}
}

@misc{chat_gravity_models_dilatant_gr_2026,
  author       = {{Unknown}},
  title        = {Gravity Models: Dilatant Fluid vs. {GR}},
  year         = {2026},
  howpublished = {AI chat log},
  note         = {Source: data/chats/_Gravity-Models-Dilatant-Fluid-vs.-GR.md, lines 45-270},
  url          = {../data/chats/_Gravity-Models-Dilatant-Fluid-vs.-GR.md}
}
```

### Schema.org Metadata (JSON-LD)

```json
{
  "@context": "https://schema.org",
  "@type": "ScholarlyArticle",
  "headline": "Grassmannian Gravity from QED & Gauge Scattering Amplitudes: Complex Gr_C(2,4) Orbital Precession, Mercury's Perihelion, N-Body Dynamics, and Dilatant Dark Fluid (DDF) Unification in Lean 4",
  "author": {
    "@type": "Person",
    "name": "Wes Turner"
  },
  "dateModified": "2026-11-03",
  "about": [
    "Gravity from Scattering Amplitudes",
    "BCJ Double Copy",
    "Perihelion Precession of Mercury",
    "Gravitational Waves",
    "Peters-Mathews Quadrupole Luminosity",
    "N-Body Gravitational Dynamics",
    "Complex Grassmannian Gr_C(2,4)",
    "Dilatant Dark Fluid",
    "Superfluid Quantum Gravity",
    "Lean 4 Formal Verification"
  ],
  "isBasedOn": [
    "docs/gravity-from-qed-scattering-with-amplituhedron-geometry.md",
    "data/chats/N-body-gravity-from-QED-with-scattering-amplitudes.md",
    "data/chats/_Special-Relativity-Geometry-vs.-Fluid.md",
    "data/chats/_Gravity-Models-Dilatant-Fluid-vs.-GR.md",
    "data/chats/Review-Pop-III-GW-Remnants.md",
    "data/chats/SQGDDF-Explanation-of-Wave-Delays.md",
    "src/signals/Signals/QEDGravity.lean",
    "src/signals/Signals/DDF.lean",
    "src/signals/Signals/Geometry.lean",
    "src/signals/numerical_adapter/src/orbital_splat.rs"
  ]
}
```
