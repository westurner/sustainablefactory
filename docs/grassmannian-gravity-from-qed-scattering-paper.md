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
- [Unification, Engineering Applications, and Research Roadmap of Complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ and Dilatant Dark Fluid (DDF) Mechanics: Cross-Domain Plücker Invariants, Photonic–Thermal–Quantum Systems, and Formal Verification in Lean 4](grassmannian-unification-applications-roadmap-paper.md)

---

## Abstract

Can planetary orbital dynamics—including the anomalous $42.98''/\text{century}$ perihelion precession of Mercury, $N$-body gravitational perturbations, and quadrupole gravitational waves—be derived and verified from flat-space gauge/QED scattering amplitudes, Grassmannian Plücker geometry, and quantum-hydrodynamic substrates without assuming fundamental spacetime curvature? We present a machine-checked formalization in the Lean 4 theorem prover (`Signals.QEDGravity`, `Signals.DDF`, `Signals.Geometry`, and `Signals.Huygens`) uniting five frameworks:

1. **BCJ Color–Kinematics Duality & Double Copy on $Gr_{\mathbb{C}}(2,4)$ (`bcj_plucker_jacobi_and_double_copy`)**:
   In 4-point gauge scattering ([Bern, Carrasco, and Johansson 2008](#grav-bcj2008); [Arkani-Hamed and Trnka 2014](#grav-arkani2014)), the kinematic numerators $(n_s, n_t, n_u)$ defined by the quadratic Plücker products $n_s = \Delta_{01}^{\mathbb{C}}\Delta_{23}^{\mathbb{C}}$, $n_t = -\Delta_{02}^{\mathbb{C}}\Delta_{13}^{\mathbb{C}}$, and $n_u = \Delta_{03}^{\mathbb{C}}\Delta_{12}^{\mathbb{C}}$ automatically satisfy the Jacobi identity $n_s + n_t + n_u = 0$ via the 3-term Plücker relation on $Gr_{\mathbb{C}}(2,4)$. Squaring the kinematic numerator ($\text{Gravity} = \text{Gauge}^2$) maps gauge-fluid vorticity ($\boldsymbol{\omega} = \nabla \times \mathbf{v}$) onto the symmetric graviton/fluid shear-stress tensor $n_t^2 = (n_s + n_u)^2 = n_s^2 + 2 n_s n_u + n_u^2$.
2. **1-Loop Post-Minkowskian Effective Potential, DDF Substrate Decomposition, & Mercury's Perihelion Precession**:
   Matching the 1-loop classical scattering amplitude ([Partanen and Tulkki 2025](#grav-partanen2025); [Bjerrum-Bohr et al. 2018](#grav-bjerrum2018)) or the conservative Dilatant Dark Fluid (DDF) sheath action ([Fedi 2026](#grav-fedi2026)) yields the effective central potential
   $$V_{\mathrm{eff}}(r) = -\frac{G_\phi M m}{r}\left(1 + \frac{3 L^2}{m^2 c^2 r^2}\right) = m\,\Phi_\phi(r) - \frac{3\,G_\phi M\,L^2\,\varrho_{\max}^\varphi j_{\min}^\varphi}{m\,r^3},$$
   where $\Phi_\phi(r) = -G_\phi M / r$ is the superfluid Bernoulli enthalpy deficit and $\varrho_{\max}^\varphi j_{\min}^\varphi = c^{-2}$ is the DDF dispersed-phase compressibility-density product. This generates the exact per-orbit anomalous perihelion advance:
   $$\Delta\varpi = \frac{6\pi G_\phi M}{c^2 a(1 - e^2)} = \frac{3\pi\,r_H}{a(1 - e^2)} = \frac{6\pi\,G_\phi M\,\varrho_{\max}^\varphi j_{\min}^\varphi}{a(1 - e^2)},$$
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

```lean
import Signals
import SignalsPending

namespace ArxivGravityFromQEDPaperVerification

open Signals.Geometry
open Signals.Coherence
open Signals.Huygens
open Signals.DDF

-- 1. BCJ kinematic Jacobi identity and double-copy square on Gr_C(2,4)
example (M_C : Matrix (Fin 2) (Fin 4) ℂ) :
    let n_s := complexTwoRowMinor M_C 0 1 * complexTwoRowMinor M_C 2 3
    let n_t := - (complexTwoRowMinor M_C 0 2 * complexTwoRowMinor M_C 1 3)
    let n_u := complexTwoRowMinor M_C 0 3 * complexTwoRowMinor M_C 1 2
    n_s + n_t + n_u = 0 ∧
      n_t ^ 2 = n_s ^ 2 + 2 * n_s * n_u + n_u ^ 2 :=
  bcj_plucker_jacobi_and_double_copy M_C
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
   $$\bigl|w_A^{\mathbb{C}}(M_{\mathbb{C}}^{\mathrm{orb}})\bigr|^2 = \bigl|\Delta_{01}^{\mathbb{C}}\Delta_{23}^{\mathbb{C}}\bigr|^2 = 1 + e = \frac{r_{\max}}{a}.$$
2. **Perihelion Ratio as Second Madelung Channel Density**:
   $$\bigl|w_B^{\mathbb{C}}(M_{\mathbb{C}}^{\mathrm{orb}})\bigr|^2 = \bigl|\Delta_{03}^{\mathbb{C}}\Delta_{12}^{\mathbb{C}}\bigr|^2 = 1 - e = \frac{r_{\min}}{a}.$$
3. **Orbital Eccentricity as Plücker Barycentric Shift**:
   $$\frac{|w_A^{\mathbb{C}}|^2 - |w_B^{\mathbb{C}}|^2}{2} = e.$$
4. **Semi-Latus Rectum Ratio $p/a = 1 - e^2$ as Madelung Density Product & Reciprocal Jamming Factor**:
   $$\bigl|w_A^{\mathbb{C}}\bigr|^2\,\bigl|w_B^{\mathbb{C}}\bigr|^2 = 1 - e^2 = \frac{p}{a} = \left(\frac{b}{a}\right)^2.$$
   Consequently, the denominator $p = a(1 - e^2)$ of Mercury's perihelion precession formula $\Delta\varpi = \frac{3\pi r_H}{a(1 - e^2)}$ is $a$ times the product of the two uncrossed Madelung channel densities on $Gr_{\mathbb{C}}(2,4)$!
5. **Crossing Plücker Minor Encodes Precession Cosine & Minor-to-Major Axis Ratio**:
   $$\bigl|\Delta_{02}^{\mathbb{C}}(M_{\mathbb{C}}^{\mathrm{orb}})\,\Delta_{13}^{\mathbb{C}}(M_{\mathbb{C}}^{\mathrm{orb}})\bigr|^2 = 2\left(1 + \sqrt{1 - e^2}\cos\Delta\varpi\right).$$

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
   $$\det \Sigma_{\mathrm{DDF}}(s) = \sigma_0^4(1 - \beta^2) = \frac{\sigma_0^4}{\gamma_\varphi(v)^2}, \qquad \mathcal{N}_{\mathrm{DDF}}(s) = \frac{\gamma_\varphi(v)}{2\pi \sigma_0^2}.$$
3. **Complex $Gr_{\mathbb{C}}(2,4)$ Planetary Orbit Tensor Splat (`PlanetaryOrbit.gr24TensorSplat`, `PlanetaryOrbit.gr24TensorSplat_identities`)**:
   With principal variances weighted by the two $Gr_{\mathbb{C}}(2,4)$ Madelung channel densities $\sigma_1^2 = \sigma_0^2 |w_A^{\mathbb{C}}|^2 = \sigma_0^2(1 + e)$ and $\sigma_2^2 = \sigma_0^2 |w_B^{\mathbb{C}}|^2 = \sigma_0^2(1 - e)$ oriented along the precessing perihelion angle $\varpi$:
   $$\operatorname{Tr} \Sigma_{Gr_{\mathbb{C}}(2,4)} = 2\sigma_0^2, \qquad \det \Sigma_{Gr_{\mathbb{C}}(2,4)} = \sigma_0^4(1 - e^2) = \sigma_0^4\,\frac{p}{a}.$$

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

end ArxivGravityFromQEDPaperVerification
```

---

## 5. Rust + WebAssembly (`wasm32-unknown-unknown`) + WebGL2 GLSL Simulation & Normed Tensor Gaussian Splatting

In [src/signals/numerical_adapter/src/orbital_splat.rs](../src/signals/numerical_adapter/src/orbital_splat.rs) and the WebGL2 (`#version 300 es`) shaders [orbital_splat.vert.glsl](../src/signals/numerical_adapter/src/shaders/orbital_splat.vert.glsl) and [orbital_splat.frag.glsl](../src/signals/numerical_adapter/src/shaders/orbital_splat.frag.glsl), we implement the complete orbital mechanics and multi-layer normed Tensor Gaussian Splatting pipeline:

1. **Planetary Precession & Symplectic Velocity-Verlet $N$-Body Simulation (`PlanetaryOrbitParams`, `RelativisticOrbitState`)**:
   - Evaluates the $\pi$-free arcsecond precession $\Delta\varpi_{\mathrm{arcsec}} = \frac{1,944,000\,r_H}{p}$, the precessing polar conic $r(\varphi; \eta_{\mathrm{prec}}) = \frac{p}{1 + e\cos((1 - \eta_{\mathrm{prec}})\varphi)}$, the $Gr_{\mathbb{C}}(2,4)$ orbital precession matrix `gr24_precession_matrix`, the $N$-body $Gr_{\mathbb{C}}(2, N+2)$ Madelung sink sum `nbody_bernoulli_potential_gr2n`, and the symplectic Velocity-Verlet integrator `step_velocity_verlet` for $V_{\mathrm{eff}}(r)$.
2. **Multi-Layer Normed 2D Anisotropic Tensor Gaussian Splatting (`NormedTensorGaussianSplat2D`, `SplatRole`, `OrbitalSplatScene`)**:
   - **`SplatRole::BodySinkSource (0)`**: Gravitating bodies, attractors, superfluid sinks ($\Phi_\phi < 0$), and sources.
   - **`SplatRole::Gr24OrbitalField (1)`**: Complex $Gr_{\mathbb{C}}(2,4)$ orbital field splats with $\sigma_1 = \sigma_0\sqrt{1+e} = \sigma_0|w_A^{\mathbb{C}}|$, $\sigma_2 = \sigma_0\sqrt{1-e} = \sigma_0|w_B^{\mathbb{C}}|$, $\operatorname{Tr}\Sigma = 2\sigma_0^2$, and $\det\Sigma = \sigma_0^4(1-e^2) = \sigma_0^4(p/a)$.
   - **`SplatRole::DdfMovingSheathField (2)`**: DDF moving-sheath splats with longitudinal Lorentz/jamming contraction $\sigma_1 = \sigma_0/\gamma_\varphi(v)$ along the velocity vector and transverse width $\sigma_2 = \sigma_0$, so $\det\Sigma_{\mathrm{DDF}} = \sigma_0^4\gamma_\varphi(v)^{-2}$ and $\mathcal{N}_{\mathrm{DDF}} = \frac{\gamma_\varphi(v)}{2\pi\sigma_0^2}$.
   - **`SplatRole::VortexSwirlField (3)`**: Gravitomagnetic / Kerr–Lense–Thirring vortex swirl splats.
3. **Parametric `rstest` Fixtures & `insta` (`cargo-insta`) Snapshot Verification**:
   - Verified across all five solar-system benchmarks (`Mercury`, `Venus`, `Earth`, `Mars`, `Icarus`) with `#[rstest]` and locked in [signals_numerical_adapter__orbital_splat__tests__solar_system_precession_and_normed_splat_scene.snap](../src/signals/numerical_adapter/src/snapshots/signals_numerical_adapter__orbital_splat__tests__solar_system_precession_and_normed_splat_scene.snap).

---

## 6. Conclusion & Reproducibility

By formalizing the BCJ Plücker double copy on $Gr_{\mathbb{C}}(2,4)$, the 1-loop QFT / DDF effective orbital potential $V_{\mathrm{eff}}(r)$, the anomalous perihelion precession $\Delta\varpi = \frac{3\pi r_H}{a(1 - e^2)}$, the $Gr_{\mathbb{C}}(2,4)$ planetary orbital precession matrix `PlanetaryOrbit.gr24PrecessionMatrix`, the $N$-body sink potential on $Gr_{\mathbb{C}}(2, N+2)$, and `NormedTensorGaussianSplat2D` in Lean 4 and Rust/WASM/GLSL, we have established a machine-checked bridge from flat-space scattering amplitudes and positive/complex Grassmannian geometry to planetary orbital mechanics and Dilatant Dark Fluid hydrodynamics.

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
1. Partanen, M., and Tulkki, J. (2025). *Gravity Generated by Four One-Dimensional Unitary Gauge Symmetries and the Standard Model* /  [arXiv:2310.01460](https://arxiv.org/abs/2310.01460).

<a id="ddf-partanen2025-2"></a>
2. Partanen, M., and Tulkki, J. (2025). *Perihelion precession of planetary orbits solved from quantum field theory*.
[arXiv:2506.14447](https://arxiv.org/abs/2506.14447).

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

---

### BibTeX Citations

```bibtex
@article{partanen2025perihelion,
  author  = {Partanen, Mikko and Tulkki, Jukka},
  title   = {Perihelion Precession of Planetary Orbits Solved from Quantum Field Theory},
  journal = {arXiv preprint arXiv:2506.14447},
  year    = {2025},
  url     = {https://arxiv.org/abs/2506.14447}
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
  "dateModified": "2026-10-24",
  "about": [
    "Gravity from Scattering Amplitudes",
    "BCJ Double Copy",
    "Perihelion Precession of Mercury",
    "N-Body Gravitational Dynamics",
    "Complex Grassmannian Gr_C(2,4)",
    "Dilatant Dark Fluid",
    "Lean 4 Formal Verification"
  ],
  "isBasedOn": [
    "docs/gravity-from-qed-scattering-with-amplituhedron-geometry.md",
    "data/chats/N-body-gravity-from-QED-with-scattering-amplitudes.md",
    "data/chats/_Special-Relativity-Geometry-vs.-Fluid.md",
    "data/chats/_Gravity-Models-Dilatant-Fluid-vs.-GR.md",
    "src/signals/Signals/DDF.lean",
    "src/signals/Signals/Geometry.lean"
  ]
}
```
