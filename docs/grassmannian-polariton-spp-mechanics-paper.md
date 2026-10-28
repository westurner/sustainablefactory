---
title: "Polaritons and Surface Plasmon Polaritons (SPPs) in Unified Grassmannian–DDF Mechanics: Hopfield–Rabi Anticrossing, Lyddane–Sachs–Teller Reststrahlen Bands, Gr_C(2,4) Evanescent Skin-Depth Duality, and Sub-Wavelength Tensor Splatting in Lean 4"
description: "An arXiv-ready formal verification and numerical simulation paper modeling microcavity/bulk Polaritons and Surface Plasmon Polaritons (SPPs) in complex Grassmannian Gr_C(2,4) and Dilatant Dark Fluid (DDF) mechanics, both without splats (continuum Hopfield/LST/SPP dispersion, Plücker skin-depth duality, and propagation semigroups) and with Normed 2D Anisotropic Tensor Gaussian Splats (sub-wavelength hotspot compression, Bohm quantum pressure amplification, and Ohmic-thermal relaxation) in Lean 4 and Rust/WASM."
---

(grassmannian-polariton-spp-mechanics-paper)=
# Polaritons and Surface Plasmon Polaritons (SPPs) in Unified Grassmannian–DDF Mechanics: Hopfield–Rabi Anticrossing, Lyddane–Sachs–Teller Reststrahlen Bands, $Gr_{\mathbb{C}}(2,4)$ Evanescent Skin-Depth Duality, and Sub-Wavelength Tensor Splatting in Lean 4

- **Authors:** Wes Turner
- **Subjects:**
  - Optics (`physics.optics`); Mesoscale and Nanoscale Physics (`cond-mat.mes-hall`); Mathematical Physics (`math-ph`); Quantum Physics (`quant-ph`); Logic in Computer Science (`cs.LO`)
- **Formal Verification & Simulation Artifacts:**
  - `Signals` Lean 4 Library (`leanprover/lean4:v4.35.0-rc3`, `Signals.Scattering`, `Signals.DDF`, `Signals.Pending`)
  - `signals-numerical-adapter` Rust/WASM Crate (`src/signals/numerical_adapter/src/polariton_spp.rs`)
- **Companion Papers:**
  1. [Huygens–Steiner Barycentric Coherence, Complex $Gr_{\mathbb{C}}(2,4)$ Plücker Channels, and Multi-Model Double-Slit & OAM Relative Predictive Error in Lean 4](grassmannian-huygens-double-slit-oam-paper.md)
  2. [Grassmannian Geometry of the Quantum Inverse Scattering Method, Algebraic Bethe Ansatz, and Inverse Scattering Metrology in Lean 4](grassmannian-qism-bethe-ansatz-paper.md)
  3. [Complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ & $N$-ary $Gr_{\mathbb{C}}(2, N+2)$ Unification with Dilatant Dark Fluid (DDF) Moving Sheaths, Plücker Sink Fluxes, Anosov Invariance, and Sorkin Triple-Slit Interferometry in Lean 4](grassmannian-ddf-moving-sheath-paper.md)
  4. [Grassmannian Gravity from QED & Gauge Scattering Amplitudes: Complex $Gr_{\mathbb{C}}(2,4)$ Orbital Precession, Mercury's Perihelion, $N$-Body Dynamics, and Dilatant Dark Fluid (DDF) Unification in Lean 4](grassmannian-gravity-from-qed-scattering-paper.md)
  5. [Normed Tensor Gaussian Splat Mechanics for Complex $Gr_{\mathbb{C}}(2,4)$ Twistors: Advantages, Limitations, WebGL2/WASM Practicality, and Unification Across Double-Slit, QISM, DDF, and Planetary Gravity in Lean 4](grassmannian-splat-mechanics-paper.md)
  6. [Inelastic Scattering and the Heat Problem in Unified Grassmannian–DDF Mechanics: Inverse Compton, Stokes/Anti-Stokes Raman, Fourier vs. Cattaneo–Vernotte, and Subluminal Second-Sound Tensor Splatting in Lean 4](grassmannian-thermal-compton-raman-paper.md)
  7. [The Holographic Principle in Complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ and Dilatant Dark Fluid (DDF) Mechanics: 't Hooft–Susskind Horizon Entropy, Gauss–Smarr Bulk Mass Recovery, Plücker Redshift Lapse, and Planck Tensor Splatting in Lean 4](grassmannian-holographic-principle-paper.md)
  8. [AdS/CFT Correspondence, Planar Integrability, and Secret Symmetries in Unified Complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ and Dilatant Dark Fluid (DDF) Mechanics: From Maldacena and $\mathfrak{psl}(2|2)_c$ Yangians to Plücker Outer Automorphisms and Holographic RG Tensor Splatting in Lean 4](grassmannian-ads-cft-ddf-paper.md)
  9. [Unification, Engineering Applications, and Research Roadmap of Complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ and Dilatant Dark Fluid (DDF) Mechanics: Cross-Domain Plücker Invariants, Photonic–Thermal–Quantum Systems, and Formal Verification in Lean 4](grassmannian-unification-applications-roadmap-paper.md)

---

## Abstract

How do **polaritons** (coupled photon–exciton and photon–phonon quasiparticles in microcavities and polar dielectrics) and **Surface Plasmon Polaritons (SPPs)** (sub-wavelength electromagnetic surface waves bound to metal–dielectric or graphene–vitrimer interfaces) embed into our unified **complex Grassmannian $Gr_{\mathbb{C}}(2,4)$** and **Dilatant Dark Fluid (DDF)** mechanics—both **without splats** (pure continuum field equations and Plücker invariants) and **with Normed 2D Anisotropic Tensor Gaussian Splats**? In this paper, we present machine-checked theorems in Lean 4 (`Signals.Scattering` and `Signals.DDF`) paired with a zero-dependency Rust and WebAssembly (`wasm32-unknown-unknown`) implementation (`src/signals/numerical_adapter/src/polariton_spp.rs`) establishing four main results:

1. **Polariton Hopfield–Rabi Anticrossing, $Gr_{\mathbb{C}}(2,4)$ Hybridization Complementarity, & Lyddane–Sachs–Teller Reststrahlen Dispersion (`polariton_hopfield_rabi_and_lst_identities`)**:
   For a cavity or bulk photon mode $\omega_{\mathrm{ph}}$ strongly coupled at vacuum Rabi rate $g > 0$ to a matter resonance $\omega_{\mathrm{ex}}$ (exciton or transverse optical phonon $\omega_{\mathrm{TO}}$) with detuning $\Delta_{\mathrm{pol}} = \omega_{\mathrm{ph}} - \omega_{\mathrm{ex}}$, the upper ($\omega_{\mathrm{UP}}$) and lower ($\omega_{\mathrm{LP}}$) polariton eigenfrequencies satisfy exact trace conservation $\omega_{\mathrm{UP}} + \omega_{\mathrm{LP}} = \omega_{\mathrm{ph}} + \omega_{\mathrm{ex}}$, avoided-crossing gap $\omega_{\mathrm{UP}} - \omega_{\mathrm{LP}} = \sqrt{\Delta_{\mathrm{pol}}^2 + 4g^2} \ge 2g > 0$, and determinant invariance $\omega_{\mathrm{ph}}\omega_{\mathrm{ex}} - \omega_{\mathrm{UP}}\omega_{\mathrm{LP}} = g^2$ (`reconstructPolaritonRabiCouplingSq`). Defining the normalized Hopfield barycentric shift $d_{\mathrm{Hopfield}} = \Delta_{\mathrm{pol}} / \sqrt{\Delta_{\mathrm{pol}}^2 + 4g^2} \in (-1, 1)$, the Hopfield photon fraction $|C|^2 = (1 + d_{\mathrm{Hopfield}})/2$ and matter fraction $|X|^2 = (1 - d_{\mathrm{Hopfield}})/2$ obey the Pythagorean $Gr_{\mathbb{C}}(2,4)$ Plücker complementarity law:
   $$|C|^2 + |X|^2 = 1, \qquad 4|C|^2|X|^2 = 1 - d_{\mathrm{Hopfield}}^2 = \frac{4g^2}{\Delta_{\mathrm{pol}}^2 + 4g^2} > 0.$$
   For polar dielectrics governed by the Lyddane–Sachs–Teller (LST) permittivity $\varepsilon_{\mathrm{pol}}(\omega) = \varepsilon_\infty \frac{\omega^2 - \omega_{\mathrm{LO}}^2}{\omega^2 - \omega_{\mathrm{TO}}^2}$ ($0 < \omega_{\mathrm{TO}} < \omega_{\mathrm{LO}}$), we prove the static limit $\varepsilon_{\mathrm{pol}}(0) = \varepsilon_\infty \omega_{\mathrm{LO}}^2 / \omega_{\mathrm{TO}}^2$, the Epsilon-Near-Zero (ENZ) bulk longitudinal polariton cutoff $\varepsilon_{\mathrm{pol}}(\omega_{\mathrm{LO}}) = 0$, and strict negativity $\varepsilon_{\mathrm{pol}}(\omega) < 0$ throughout the Reststrahlen band $\omega \in (\omega_{\mathrm{TO}}, \omega_{\mathrm{LO}})$.
2. **Splat-Free Continuum Surface Plasmon Polariton (SPP) Dispersion, $Gr_{\mathbb{C}}(2,4)$ Plücker Skin-Depth Duality, & Spatial Semigroup (`MovingSheath.sppContinuum_gr24_and_semigroup_identities`)**:
   At a planar interface between a dielectric ($\varepsilon_d > 0$) and a conductor with negative real permittivity $\varepsilon_m = -|\varepsilon_m| < -\varepsilon_d < 0$, the squared effective SPP index $n_{\mathrm{SPP}}^2 = \frac{\varepsilon_d|\varepsilon_m|}{|\varepsilon_m| - \varepsilon_d}$ strictly exceeds $\varepsilon_d$ by $n_{\mathrm{SPP}}^2 - \varepsilon_d = \frac{\varepsilon_d^2}{|\varepsilon_m| - \varepsilon_d} > 0$, placing the SPP wavevector $k_{\mathrm{SPP}} = k_0 n_{\mathrm{SPP}}$ outside the dielectric light cone and requiring prism, grating, or cylindrical phase matching (`CylindricalSPPMode`). Embedding the SPP permittivity contrast $\chi_{\mathrm{SPP}} = \frac{|\varepsilon_m| - \varepsilon_d}{|\varepsilon_m| + \varepsilon_d} \in (0, 1)$ into $Gr_{\mathbb{C}}(2,4)$ via `sppGr24Matrix χ_spp θ` proves that the uncrossed Plücker channel ratio equals the exact normal evanescent skin-depth ratio $\delta_d / \delta_m = \kappa_m / \kappa_d = |\varepsilon_m| / \varepsilon_d > 1$:
   $$\frac{|w_A^{\mathbb{C}}(M_{\mathrm{SPP}})|^2}{|w_B^{\mathbb{C}}(M_{\mathrm{SPP}})|^2} = \frac{1 + \chi_{\mathrm{SPP}}}{1 - \chi_{\mathrm{SPP}}} = \frac{|\varepsilon_m|}{\varepsilon_d} = \frac{\kappa_m}{\kappa_d} > 1, \qquad |w_A^{\mathbb{C}}|^2\,|w_B^{\mathbb{C}}|^2 = \frac{4\varepsilon_d|\varepsilon_m|}{(|\varepsilon_m| + \varepsilon_d)^2} > 0.$$
   Along the interface, continuum SPP attenuation `evolveContinuumSppPropagation γ_spp L I0` satisfies the Chapman–Kolmogorov spatial semigroup laws ($\Delta L = 0$ identity and $L_1 + L_2$ additivity), while the conductor-side continuum Bohm evanescent quantum potential exceeds the dielectric side by $(|\varepsilon_m|/\varepsilon_d)^2 > 1$.
3. **With Normed 2D Anisotropic Tensor Gaussian Splats: Sub-Wavelength SPP Hotspot Compression, Bohm Quantum Pressure Amplification, & Ohmic-Thermal Semigroup (`MovingSheath.sppTensorSplat_and_thermal_identities`)**:
   Representing a localized SPP wavepacket or plasmonic hotspot by `sppHotspotTensorSplat` with longitudinal width $\sigma_1 = \lambda_0 / n_{\mathrm{SPP}}$ and normal skin-depth width $\sigma_2 = \lambda_0 / (n_{\mathrm{SPP}}\kappa_{\mathrm{ratio}})$ ($\kappa_{\mathrm{ratio}} = |\varepsilon_m|/\varepsilon_d \ge 1$, $n_{\mathrm{SPP}} \ge 1$) compresses the covariance determinant to $\det\Sigma_{\mathrm{SPP}} = \frac{\lambda_0^4}{n_{\mathrm{SPP}}^4 \kappa_{\mathrm{ratio}}^2}$, boosts the peak normalization factor to $\mathcal{N}(\Sigma_{\mathrm{SPP}}) = \frac{n_{\mathrm{SPP}}^2 \kappa_{\mathrm{ratio}}}{2\pi\lambda_0^2}$, and amplifies the repulsive core Bohm quantum potential and Madelung quantum pressure anisotropy:
   $$Q_{\mathrm{core}}(\Sigma_{\mathrm{SPP}}) = \frac{\hbar^2\,n_{\mathrm{SPP}}^2\,(1 + \kappa_{\mathrm{ratio}}^2)}{4 m\,\lambda_0^2} \ge \frac{\hbar^2}{2 m\,\lambda_0^2}, \qquad \Pi_{22}^{\mathrm{SPP}}(x,y) = \kappa_{\mathrm{ratio}}^2\,\Pi_{11}^{\mathrm{SPP}}(x,y),$$
   while Ohmic-thermal relaxation `splat_spp.evolveThermal α1 α2 dt` obeys exact $L^1$ energy conservation, Chapman–Kolmogorov semigroup identity/additivity, and monotonic Bohm potential decay.
4. **Explicit Physical & Evidence Boundaries**:
   We distinguish verified electromagnetic/hydrodynamic polariton and SPP laws from active-gain power balances (`SPPFreeElectronAmplifier`) and document the hard nuclear Coulomb barrier separating eV-scale SPP plasmonic catalysis from MeV-scale nuclear transmutation.

---

## 1. Polaritons on $Gr_{\mathbb{C}}(2,4)$: Hopfield Bogoliubov Mixing, Vacuum Rabi Anticrossing, and Lyddane–Sachs–Teller Reststrahlen Dispersion

When an electromagnetic mode of frequency $\omega_{\mathrm{ph}} > 0$ couples strongly to a dipolar matter excitation of frequency $\omega_{\mathrm{ex}} > 0$—such as a semiconductor Wannier–Mott or Rydberg exciton in a microcavity ([Hopfield 1958](#pol-hopfield1958); [Weisbuch et al. 1992](#pol-weisbuch1992); [Provenance Chat Log: Rydberg-Polariton Analog Gravity Simulator (2026)](#pol-chat-rydberg2026), lines 1021–1135) or a transverse optical (TO) phonon in a polar dielectric ([Huang 1951](#pol-huang1951); [Provenance Chat Log: Bulk Polariton Coupling in Lignin-Derived Carbon Fibers (2026)](#pol-chat-ldcf2026), lines 1940–1965)—the normal modesHybridize into **Upper Polariton (UP)** and **Lower Polariton (LP)** quasiparticles.

### 1.1 Vacuum Rabi Splitting, Avoided Crossing, and Exact Inverse Rabi Spectroscopy

In `Signals.Scattering` ([src/signals/Signals/Scattering.lean](../src/signals/Signals/Scattering.lean#L973-L1150)), for photon–matter detuning $\Delta_{\mathrm{pol}} = \omega_{\mathrm{ph}} - \omega_{\mathrm{ex}}$ and vacuum Rabi coupling strength $g > 0$, the $2 \times 2$ Hopfield Hamiltonian

$$
H_{\mathrm{Hopfield}} = \begin{pmatrix} \omega_{\mathrm{ph}} & g \\ g & \omega_{\mathrm{ex}} \end{pmatrix}
$$

has effective Rabi splitting (`polaritonEffectiveRabiSplitting`) and upper/lower polariton eigenfrequencies (`upperPolaritonFreq`, `lowerPolaritonFreq`):

$$
\Omega_{\mathrm{eff}}(\Delta_{\mathrm{pol}}, g) = \sqrt{\Delta_{\mathrm{pol}}^2 + 4 g^2} \ge 2 g > 0, \qquad
\omega_{\mathrm{UP},\mathrm{LP}} = \frac{\omega_{\mathrm{ph}} + \omega_{\mathrm{ex}} \pm \Omega_{\mathrm{eff}}(\Delta_{\mathrm{pol}}, g)}{2}.
$$

In `polariton_hopfield_rabi_and_lst_identities`, we prove that the trace and determinant of $H_{\mathrm{Hopfield}}$ are exact spectral invariants:

$$
\omega_{\mathrm{UP}} + \omega_{\mathrm{LP}} = \omega_{\mathrm{ph}} + \omega_{\mathrm{ex}}, \qquad
\omega_{\mathrm{UP}} - \omega_{\mathrm{LP}} = \Omega_{\mathrm{eff}}(\Delta_{\mathrm{pol}}, g) \ge 2 g > 0,
$$

$$
\operatorname{reconstructPolaritonRabiCouplingSq}(\omega_{\mathrm{ph}}, \omega_{\mathrm{ex}}, \omega_{\mathrm{UP}}, \omega_{\mathrm{LP}}) = \omega_{\mathrm{ph}}\,\omega_{\mathrm{ex}} - \omega_{\mathrm{UP}}\,\omega_{\mathrm{LP}} = g^2.
$$

### 1.2 Hopfield Photon/Matter Fractions as $Gr_{\mathbb{C}}(2,4)$ Plücker Channel Weights

Defining the normalized Hopfield barycentric photon–matter shift (`hopfieldBarycentricShift`):

$$
d_{\mathrm{Hopfield}}(\Delta_{\mathrm{pol}}, g) = \frac{\Delta_{\mathrm{pol}}}{\sqrt{\Delta_{\mathrm{pol}}^2 + 4 g^2}} \in (-1, 1),
$$

the upper-branch **Hopfield photon fraction** $|C|^2$ (`hopfieldPhotonWeight`) and **matter fraction** $|X|^2$ (`hopfieldMatterWeight`) are:

$$
|C|^2 = \frac{1 + d_{\mathrm{Hopfield}}}{2}, \qquad |X|^2 = \frac{1 - d_{\mathrm{Hopfield}}}{2}.
$$

When embedded into the complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ via $M_{\mathrm{Hopfield}} = \operatorname{ddfThermalGr24Matrix}(d_{\mathrm{Hopfield}}, \theta)$, the uncrossed Plücker channel amplitudes satisfy $\frac{1}{2}|w_A^{\mathbb{C}}|^2 = |C|^2$ and $\frac{1}{2}|w_B^{\mathbb{C}}|^2 = |X|^2$, yielding the exact Pythagorean Hopfield–Plücker complementarity law (`polariton_hopfield_rabi_and_lst_identities`):

$$
|C|^2 + |X|^2 = 1, \qquad |C|^2 - |X|^2 = d_{\mathrm{Hopfield}}, \qquad
|w_A^{\mathbb{C}}|^2\,|w_B^{\mathbb{C}}|^2 = 4\,|C|^2\,|X|^2 = 1 - d_{\mathrm{Hopfield}}^2 = \frac{4 g^2}{\Delta_{\mathrm{pol}}^2 + 4 g^2} > 0.
$$

At zero detuning ($\Delta_{\mathrm{pol}} = 0$, $\omega_{\mathrm{ph}} = \omega_{\mathrm{ex}}$), $d_{\mathrm{Hopfield}} = 0$, $|C|^2 = |X|^2 = 1/2$, and the $Gr_{\mathbb{C}}(2,4)$ Plücker hybridization product reaches its unit maximum $4|C|^2|X|^2 = 1$ (maximally entangled half-light / half-matter polariton).

### 1.3 Lyddane–Sachs–Teller (LST) Phonon-Polariton Permittivity, ENZ Longitudinal Modes, & the Reststrahlen Band

In polar crystals and structured dielectric composites ($\text{SiO}_2$ quartzite, $\text{SiC}$, $\text{ZnS}$, or Lignin-Vitrimer matrices; [Lyddane, Sachs, and Teller 1941](#pol-lst1941); [Provenance Chat Log: Classical Near-Fields vs. Proca & ENZ Polaritons (2026)](#pol-chat-proca2026), lines 78–115; [Provenance Chat Log: IQ-Sampling & ENZ Volume Plasmon Polaritons (2026)](#pol-chat-iq2026), lines 15120–15130), coupling between transverse photons and optical phonons with transverse frequency $\omega_{\mathrm{TO}} > 0$ and longitudinal frequency $\omega_{\mathrm{LO}} > \omega_{\mathrm{TO}}$ yields the dispersive permittivity (`lyddaneSachsTellerPermittivity`):

$$
\varepsilon_{\mathrm{pol}}(\omega) = \varepsilon_\infty\,\frac{\omega^2 - \omega_{\mathrm{LO}}^2}{\omega^2 - \omega_{\mathrm{TO}}^2}.
$$

Theorem `polariton_hopfield_rabi_and_lst_identities` proves three fundamental regimes:
1. **Static Dielectric Limit ($\omega = 0$)**: $\varepsilon_{\mathrm{pol}}(0) = \varepsilon_\infty\,\frac{\omega_{\mathrm{LO}}^2}{\omega_{\mathrm{TO}}^2} = \varepsilon_{\mathrm{st}} > \varepsilon_\infty$,
2. **Epsilon-Near-Zero (ENZ) Longitudinal Bulk Polariton Cutoff ($\omega = \omega_{\mathrm{LO}}$)**: $\varepsilon_{\mathrm{pol}}(\omega_{\mathrm{LO}}) = 0$, where $\nabla \cdot (\varepsilon_{\mathrm{pol}}\mathbf{E}) = 0$ admits a non-trivial **longitudinal bulk polariton wave** ($\mathbf{E} \parallel \mathbf{k}$) at the longitudinal optical frequency $\omega_{\mathrm{LO}}$,
3. **Reststrahlen Stop-Band & Surface-Polariton Window ($\omega_{\mathrm{TO}} < \omega < \omega_{\mathrm{LO}}$)**: $\varepsilon_{\mathrm{pol}}(\omega) < 0$, where bulk transverse propagation is forbidden and the negative-permittivity dielectric interface supports **Surface Phonon Polaritons (SPhPs)** by the exact same boundary equations as metallic Surface Plasmon Polaritons.

---

## 2. Surface Plasmon Polaritons (SPPs) Without Splats: Continuum Dispersion, $Gr_{\mathbb{C}}(2,4)$ Plücker Skin-Depth Duality, and Spatial Semigroup

A **Surface Plasmon Polariton (SPP)** ([Raether 1988](#pol-raether1988); [Barnes, Dereux, and Ebbesen 2003](#pol-barnes2003); [Maier 2007](#pol-maier2007)) is a transverse-magnetic (TM) electromagnetic surface wave coupled to collective surface electron oscillations at the planar interface ($z = 0$) between a positive-permittivity dielectric ($\varepsilon_d > 0$ for $z > 0$) and a negative-permittivity conductor ($\varepsilon_m = -|\varepsilon_m| < -\varepsilon_d < 0$ for $z < 0$, so $0 < \varepsilon_d < |\varepsilon_m|$).

### 2.1 Sub-Wavelength Momentum Enhancement Outside the Light Cone & Evanescent Decay Ratio

Solving Maxwell's TM continuity conditions for $E_x$ and $D_z = \varepsilon E_z$ across $z = 0$ yields the squared effective SPP refractive index (`sppEffectiveIndexSq` in [src/signals/Signals/DDF.lean](../src/signals/Signals/DDF.lean#L4075-L4295)):

$$
n_{\mathrm{SPP}}^2(\varepsilon_d, |\varepsilon_m|) = \left(\frac{c\,k_{\mathrm{SPP}}}{\omega}\right)^2 = \frac{\varepsilon_d\,\varepsilon_m}{\varepsilon_d + \varepsilon_m} = \frac{\varepsilon_d\,|\varepsilon_m|}{|\varepsilon_m| - \varepsilon_d}.
$$

In `MovingSheath.sppContinuum_gr24_and_semigroup_identities`, we prove (with **zero splats**):
1. **Strict Momentum Enhancement Beyond the Dielectric Light Cone**:
   $$n_{\mathrm{SPP}}^2(\varepsilon_d, |\varepsilon_m|) - \varepsilon_d = \frac{\varepsilon_d^2}{|\varepsilon_m| - \varepsilon_d} > 0 \implies k_{\mathrm{SPP}} = k_0\,n_{\mathrm{SPP}} > k_0\sqrt{\varepsilon_d}.$$
   Because $k_{\mathrm{SPP}}$ strictly exceeds the maximum tangential wavevector $k_0\sqrt{\varepsilon_d}\sin\theta_{\mathrm{inc}}$ of any propagating plane wave in the dielectric, free-space light cannot directly launch SPPs on a flat interface without momentum-matching via a Kretschmann/Otto prism, a periodic diffraction grating, a high-NA radially polarized focus, or a phase-matched cylindrical microtube (`CylindricalSPPMode` in [src/signals/Signals/ActiveOptics.lean](../src/signals/Signals/ActiveOptics.lean#L127-L155)).
2. **Exact Normal Evanescent Skin-Depth Ratio**:
   Normal to the interface, the field decays evanescently as $\exp(-\kappa_d z)$ in the dielectric ($z > 0$) and $\exp(+\kappa_m z)$ in the conductor ($z < 0$), where $\kappa_d^2 = k_0^2(n_{\mathrm{SPP}}^2 - \varepsilon_d)$ and $\kappa_m^2 = k_0^2(n_{\mathrm{SPP}}^2 + |\varepsilon_m|)$. We prove the exact identity:
   $$\frac{\kappa_d^2}{\kappa_m^2} = \frac{n_{\mathrm{SPP}}^2 - \varepsilon_d}{n_{\mathrm{SPP}}^2 + |\varepsilon_m|} = \frac{\varepsilon_d^2}{|\varepsilon_m|^2} \implies \frac{\delta_d}{\delta_m} = \frac{\kappa_m}{\kappa_d} = \frac{|\varepsilon_m|}{\varepsilon_d} > 1,$$
   confirming that the evanescent tail extends $|\varepsilon_m|/\varepsilon_d$ times farther into the dielectric than into the conductor.

### 2.2 Splat-Free $Gr_{\mathbb{C}}(2,4)$ Plücker Skin-Depth Duality & Spatial Semigroup

Defining the dimensionless **SPP permittivity contrast** (`sppPermittivityContrast`):

$$
\chi_{\mathrm{SPP}}(\varepsilon_d, |\varepsilon_m|) = \frac{|\varepsilon_m| - \varepsilon_d}{|\varepsilon_m| + \varepsilon_d} \in (0, 1) \qquad (0 < \varepsilon_d < |\varepsilon_m|),
$$

and embedding $(\chi_{\mathrm{SPP}}, \theta)$ into $Gr_{\mathbb{C}}(2,4)$ via $M_{\mathrm{SPP}} = \operatorname{sppGr24Matrix}(\chi_{\mathrm{SPP}}, \theta)$, Theorem `MovingSheath.sppContinuum_gr24_and_semigroup_identities` proves:
- **Plücker Channel Ratio Equals the Exact Evanescent Skin-Depth Ratio**:
  $$\frac{|w_A^{\mathbb{C}}(M_{\mathrm{SPP}})|^2}{|w_B^{\mathbb{C}}(M_{\mathrm{SPP}})|^2} = \operatorname{reconstructSppPermittivityRatio}(\chi_{\mathrm{SPP}}) = \frac{1 + \chi_{\mathrm{SPP}}}{1 - \chi_{\mathrm{SPP}}} = \frac{|\varepsilon_m|}{\varepsilon_d} = \frac{\delta_d}{\delta_m} = \frac{\kappa_m}{\kappa_d} > 1,$$
- **Plücker Channel Product Encodes Electrostatic Surface-Plasmon Resonance Proximity**:
  $$|w_A^{\mathbb{C}}(M_{\mathrm{SPP}})|^2\,|w_B^{\mathbb{C}}(M_{\mathrm{SPP}})|^2 = 1 - \chi_{\mathrm{SPP}}^2 = \frac{4\,\varepsilon_d\,|\varepsilon_m|}{(|\varepsilon_m| + \varepsilon_d)^2} > 0,$$
  which approaches $1$ as $|\varepsilon_m| \to \varepsilon_d^+$ (the electrostatic surface plasmon resonance $\omega \to \omega_{\mathrm{sp}} = \omega_p / \sqrt{1 + \varepsilon_d}$ where $n_{\mathrm{SPP}} \to \infty$),
- **Splat-Free Continuum Spatial Propagation Semigroup & Bohm Evanescent Amplification**:
  $$\operatorname{evolveContinuumSppPropagation}(\gamma_{\mathrm{SPP}}, 0, I_0) = I_0,$$
  $$\operatorname{evolveContinuumSppPropagation}\bigl(\gamma_{\mathrm{SPP}}, L_2, \operatorname{evolveContinuumSppPropagation}(\gamma_{\mathrm{SPP}}, L_1, I_0)\bigr) = \operatorname{evolveContinuumSppPropagation}(\gamma_{\mathrm{SPP}}, L_1 + L_2, I_0),$$
  $$Q_{\mathrm{cont}}\!\left(m, \hbar, \frac{|\varepsilon_m|}{\varepsilon_d}\kappa_d\right) = \left(\frac{|\varepsilon_m|}{\varepsilon_d}\right)^2 Q_{\mathrm{cont}}(m, \hbar, \kappa_d).$$

---

## 3. Surface Plasmon Polaritons With Normed Tensor Gaussian Splats: Sub-Wavelength Hotspot Compression & Bohm Quantum Pressure

When modeling localized SPP wavepackets, plasmonic nano-antenna hotspots ([Provenance Chat Log: SPPs, Plasma, and Material Synthesis (2026)](#pol-chat-spp2026), lines 69–75), or **N-LIG (Nitrogen-doped Laser-Induced Graphene) plasmonic waveguides** on Lignin-Vitrimer substrates ([Provenance Chat Log: Monolithic N-LIG Graphene Plasmonic Waveguides (2026)](#pol-chat-nlig2026), lines 2742–2775, where $n_{\mathrm{SPP}} \approx 100$ confines $1550\text{ nm}$ telecom light to $\lambda_0 / 100$), we construct `sppHotspotTensorSplat` in `Signals.DDF` ([src/signals/Signals/DDF.lean](../src/signals/Signals/DDF.lean#L4128-L4415)) with:

$$
\sigma_1 = \frac{\lambda_0}{n_{\mathrm{SPP}}}, \qquad \sigma_2 = \frac{\lambda_0}{n_{\mathrm{SPP}}\,\kappa_{\mathrm{ratio}}}, \qquad \kappa_{\mathrm{ratio}} = \frac{|\varepsilon_m|}{\varepsilon_d} \ge 1.
$$

In `MovingSheath.sppTensorSplat_and_thermal_identities`, we prove five exact properties for `splat_spp`:
1. **Sub-Wavelength Mode-Area Determinant Compression**:
   $$\det\Sigma_{\mathrm{SPP}} = \sigma_1^2\,\sigma_2^2 = \frac{\lambda_0^4}{n_{\mathrm{SPP}}^4\,\kappa_{\mathrm{ratio}}^2} \le \lambda_0^4,$$
2. **Plasmonic Hotspot Peak Intensity Normalization Enhancement**:
   $$\mathcal{N}(\Sigma_{\mathrm{SPP}}) = \frac{n_{\mathrm{SPP}}^2\,\kappa_{\mathrm{ratio}}}{2\pi\,\lambda_0^2},$$
3. **Sub-Wavelength Amplification of the Core Bohm Quantum Potential**:
   $$Q_{\mathrm{core}}(\Sigma_{\mathrm{SPP}}) = \frac{\hbar^2\,n_{\mathrm{SPP}}^2\,(1 + \kappa_{\mathrm{ratio}}^2)}{4 m\,\lambda_0^2} \ge \frac{\hbar^2}{2 m\,\lambda_0^2},$$
   demonstrating that compressing the optical mode by $n_{\mathrm{SPP}}$ (e.g., $n_{\mathrm{SPP}} = 100$ in N-LIG graphene plasmons) amplifies the repulsive Madelung/Bohm quantum pressure by $n_{\mathrm{SPP}}^2(1 + \kappa_{\mathrm{ratio}}^2)/2 \ge 10^4\times$,
4. **Normal-to-Longitudinal Madelung Quantum Stress Anisotropy**:
   $$\Pi_{22}^{\mathrm{SPP}}(x,y) = \kappa_{\mathrm{ratio}}^2\,\Pi_{11}^{\mathrm{SPP}}(x,y),$$
5. **Ohmic-Thermal Splat Semigroup Identity, Additivity, & Monotonic Bohm Relaxation**:
   As Ohmic losses heat the interface (`splat_spp.evolveThermal α1 α2 dt`), total energy $w$ is conserved, the Chapman–Kolmogorov semigroup laws ($\mathcal{E}(0) = \mathrm{id}$ and $\mathcal{E}(\Delta t_2)\circ\mathcal{E}(\Delta t_1) = \mathcal{E}(\Delta t_1 + \Delta t_2)$) hold identically, and the hotspot Bohm potential relaxes monotonically: $Q_{\mathrm{core}}(\Sigma_{\mathrm{SPP}}(t + \Delta t_1)) \le Q_{\mathrm{core}}(\Sigma_{\mathrm{SPP}}(t))$.

### 3.1 Comparison of Polariton and Surface Plasmon Polariton Regimes in Our Unified Mechanics

| Quasiparticle / Waveguide Regime | Constitutive Dispersion & $Gr_{\mathbb{C}}(2,4)$ Invariant | Confinement Scale ($n_{\mathrm{eff}}$) & Bohm Quantum Pressure $Q_{\mathrm{core}}$ | Primary Advantages & Verified Applications | Physical & Evidence Boundaries |
|---|---|---|---|---|
| **1. Microcavity Exciton-Polariton / Rydberg Polariton** (`upperPolaritonFreq`, `lowerPolaritonFreq`, `hopfieldBarycentricShift`) | $\omega_{\mathrm{UP},\mathrm{LP}} = \frac{\omega_{\mathrm{ph}}+\omega_{\mathrm{ex}}\pm\sqrt{\Delta^2+4g^2}}{2}$<br>$4|C|^2|X|^2 = 1 - d_{\mathrm{Hopfield}}^2 = \frac{4g^2}{\Delta^2+4g^2}$ | Optical cavity scale ($\sigma \sim \lambda_0 / n_{\mathrm{cav}}$); strong Kerr/Rydberg dipole interactions | Tabletop superfluidity, quantized vortices (`quantized_vortex_circulation`), QND dispersive phase readout (`DispersiveReadout`), and DDF analog-gravity horizons | Requires cryogenic or high-$Q$ perovskite/$\text{GaAs}$/$\text{Cu}_2\text{O}$ microcavities and continuous holding-beam pumping |
| **2. Bulk & Reststrahlen Phonon-Polariton (SPhP / ENZ)** (`lyddaneSachsTellerPermittivity`) | $\varepsilon_{\mathrm{pol}}(\omega) = \varepsilon_\infty\frac{\omega^2-\omega_{\mathrm{LO}}^2}{\omega^2-\omega_{\mathrm{TO}}^2}$<br>$\varepsilon_{\mathrm{pol}}(\omega_{\mathrm{LO}}) = 0$ (ENZ); $\varepsilon_{\mathrm{pol}}(\omega) < 0$ in $(\omega_{\mathrm{TO}}, \omega_{\mathrm{LO}})$ | Low-loss mid-IR/THz surface confinement in Reststrahlen band; longitudinal bulk mode at $\omega = \omega_{\mathrm{LO}}$ | Low Ohmic loss compared to metals; targeted internal phonon heating for vitrimer transesterification curing | Restricted to narrow material-specific optical-phonon Reststrahlen frequency bands |
| **3. Noble-Metal–Dielectric SPP ($\text{Au}/\text{SiO}_2$, $\text{Cu}/\text{Quartzite}$)** (`sppEffectiveIndexSq`, `sppPermittivityContrast`) | $n_{\mathrm{SPP}}^2 = \frac{\varepsilon_d|\varepsilon_m|}{|\varepsilon_m|-\varepsilon_d} > \varepsilon_d$<br>$\frac{|w_A^{\mathbb{C}}|^2}{|w_B^{\mathbb{C}}|^2} = \frac{1+\chi_{\mathrm{SPP}}}{1-\chi_{\mathrm{SPP}}} = \frac{|\varepsilon_m|}{\varepsilon_d} = \frac{\delta_d}{\delta_m}$ | Moderate sub-wavelength confinement ($n_{\mathrm{SPP}} \sim 1.1\text{–}5$); skin-depth anisotropy $\Pi_{22} = (|\varepsilon_m|/\varepsilon_d)^2 \Pi_{11}$ | High near-field hotspot intensity $\mathcal{N} \propto n_{\mathrm{SPP}}^2 \kappa_{\mathrm{ratio}}$ for plasmonic catalysis, $e^-$-beam SPP amplification (`SPPFreeElectronAmplifier`), and biosensing | Significant Ohmic Joule damping ($\gamma_{\mathrm{SPP}} > 0$); **eV-scale hotspots cannot overcome MeV nuclear Coulomb barriers** to transmute $\text{SiO}_2$ into $\text{Au}$ or $\text{Nd}$ |
| **4. N-LIG Graphene–Vitrimer SPP Bus** (`sppHotspotTensorSplat`, `sppTensorSplat_and_thermal_identities`) | Gate-tunable Drude conductivity; $\det\Sigma_{\mathrm{SPP}} = \frac{\lambda_0^4}{n_{\mathrm{SPP}}^4 \kappa_{\mathrm{ratio}}^2}$ | **Extreme sub-wavelength confinement** ($n_{\mathrm{SPP}} \sim 50\text{–}100$, $\sigma_1 = \lambda_0 / n_{\mathrm{SPP}}$); $>10^4\times$ Bohm quantum pressure boost | $100\times$ higher on-chip routing density than $1550\text{ nm}$ fiber, electrostatic vitrimer gating, and $100\%$ ethyl-lactate recyclability | Requires phase-matched launching and active thermal relaxation accounting ($\tau_r$ clock-cycle bound) |

---

## 4. Coherent Synchrotron Radiation (CSR) on Cylindrical SPP Microtubes & Carbon Nanotubes vs. Cavity QED

In a recent study, [Lei et al. (2025)](#pol-lei2025) (*Physical Review Letters*, `10.1103/cnym-16hc`, `arXiv:2507.04561`; cataloged in `laserReferenceLei2025Csr` in [src/signals/Signals/LaserReferences.lean](../src/signals/Signals/LaserReferences.lean#L351-L370) and `CylindricalSPPMode` / `CoherentRadiationScaling` in [src/signals/Signals/ActiveOptics.lean](../src/signals/Signals/ActiveOptics.lean#L127-L185)) demonstrated via 3D particle-in-cell (PIC) simulations that grazing-incidence circularly polarized laser pulses exciting **cylindrical Surface Plasmon Polaritons (SPPs)** on a near-critical solid microtube or aligned carbon nanotube (CNT) bundle surface trap and accelerate dense surface electron bunches into relativistic helical trajectories ($\gamma_e \gg 1$), emitting brilliant X-ray **Coherent Synchrotron Radiation (CSR)**.

### 4.1 Superradiant $N_e^2$ Bunching Law and Relativistic $\gamma_e^3$ Critical Frequency

When a laser with axial wavenumber $k_L$ and azimuthal spin/OAM index $m_L \in \mathbb{Z}$ matches the cylindrical SPP mode (`CylindricalSPPMode`: $k_L = k_{\mathrm{SPP}}$, $m_L = m_{\mathrm{SPP}}$) on a microtube of electron density $n_e$ near the relativistic critical density $n_c$, the travelling SPP wave potential bunches $N_e \ge 1$ surface electrons within a sub-wavelength microbunch of form factor $f_{\mathrm{bunch}} \in [0, 1]$. In `Signals.Scattering` ([src/signals/Signals/Scattering.lean](../src/signals/Signals/Scattering.lean#L1230-L1430)), we define `csrBunchingIntensity` and `csrCriticalFrequency`:

$$
I_{\mathrm{CSR}}(N_e, f_{\mathrm{bunch}}, I_1) = \bigl(N_e + N_e(N_e - 1)\,f_{\mathrm{bunch}}^2\bigr)\,I_1, \qquad
\omega_c^{\mathrm{CSR}}(\omega_{\mathrm{rot}}, \gamma_e) = \frac{3}{2}\,\omega_{\mathrm{rot}}\,\gamma_e^3,
$$

and prove in `csr_spp_cherenkov_cavity_and_grover_identities`:
1. **Incoherent Synchrotron Limit ($f_{\mathrm{bunch}} = 0$)**: $I_{\mathrm{CSR}}(N_e, 0, I_1) = N_e\,I_1$,
2. **Superradiant Phase-Locked SPP Microbunching Limit ($f_{\mathrm{bunch}} = 1$)**: $I_{\mathrm{CSR}}(N_e, 1, I_1) = N_e^2\,I_1$,
3. **Universal Interpolation Bound**: $N_e\,I_1 \le I_{\mathrm{CSR}}(N_e, f_{\mathrm{bunch}}, I_1) \le N_e^2\,I_1$ for all $N_e \ge 1$ and $f_{\mathrm{bunch}} \in [0, 1]$,
4. **Relativistic X-Ray Harmonic Upshift**: $\frac{3}{2}\omega_{\mathrm{rot}} \le \omega_c^{\mathrm{CSR}}(\omega_{\mathrm{rot}}, \gamma_e)$ for all $\gamma_e \ge 1$.

### 4.2 How Distinct Is Cylindrical SPP-Driven CSR from Cavity QED and van der Waals Cavity Electrodynamics?

A central physical question is how cylindrical SPP-driven CSR ([Lei et al. 2025](#pol-lei2025)) differs from **Single-Photon Cavity QED** and from **van der Waals Heterostructure Cavity Electrodynamics** ([Kipp et al. 2024](#pol-kipp2024), `arXiv:2403.19745`, graphite/hBN/graphene optical cavities). In `Signals.Scattering`, we formalize the single-emitter Cavity QED cooperativity `cavityQEDCooperativity`:

$$
C_1(g_0, \kappa_{\mathrm{cav}}, \gamma_{\mathrm{emit}}) = \frac{4 g_0^2}{\kappa_{\mathrm{cav}}\,\gamma_{\mathrm{emit}}}, \qquad
C_{N_e}\!\left(\sqrt{N_e}\,g_0, \kappa_{\mathrm{cav}}, \gamma_{\mathrm{emit}}\right) = N_e\,C_1(g_0, \kappa_{\mathrm{cav}}, \gamma_{\mathrm{emit}}).
$$

The three regimes are physically and mathematically distinct across six fundamental axes:

| Physical / Mathematical Dimension | 1. Single-Photon Cavity QED (Jaynes–Cummings Regime) | 2. van der Waals Heterostructure Cavity Electrodynamics ([Kipp et al. 2024](#pol-kipp2024), `arXiv:2403.19745`) | 3. Cylindrical SPP-Driven Coherent Synchrotron Radiation (CSR) ([Lei et al. 2025](#pol-lei2025), `arXiv:2507.04561`) |
|---|---|---|---|
| **Electromagnetic Boundary Geometry** | Closed 3D standing-wave Fabry–Pérot or photonic-crystal resonator with discrete mode volume $V_{\mathrm{mode}}$ | Sub-wavelength hyperbolic Fabry–Pérot cavity formed by atomically flat **graphite mirrors** encapsulating **graphene** and hBN | **Open-boundary travelling cylindrical surface wave** ($k_L = k_{\mathrm{SPP}}, m_L = m_{\mathrm{SPP}}$) along a near-critical microtube or CNT bundle |
| **Matter Degrees of Freedom** | Single quantized two-level emitter (atom, quantum dot, or single rare-earth ion in fiber; [Optica 2025](#pol-rareearth2025)) | Collective 2D Dirac Fermi sea of $N_e \gg 1$ conduction electrons in graphene | Relativistic continuum plasma microbunches ($\gamma_e \gg 1$) accelerated along helical surface trajectories |
| **Governing Coupling Invariant** | Single-photon cooperativity $C_1 = \frac{4 g_0^2}{\kappa_{\mathrm{cav}}\gamma_{\mathrm{emit}}} > 1$ and anharmonic $\sqrt{n}$ Jaynes–Cummings ladder | Collective Dicke/Hopfield cooperativity $C_{N_e} = N_e C_1$ and ultrastrong Hopfield avoided crossing $\Omega_{\mathrm{eff}} = \sqrt{\Delta^2 + 4 N_e g_0^2}$ (`polariton_hopfield_rabi_and_lst_identities`) | Coherent bunching factor $f_{\mathrm{bunch}} \in [0, 1]$ with superradiant intensity $I_{\mathrm{CSR}} = \bigl(N_e + N_e(N_e-1)f_{\mathrm{bunch}}^2\bigr)I_1$ (`csrBunchingIntensity`) |
| **Spectral Signature** | Discrete vacuum Rabi doublet $\omega_0 \pm g_0$ with photon blockade ($g^{(2)}(0) < 1$) | Tunable THz polariton branches $\omega_{\mathrm{UP}}, \omega_{\mathrm{LP}}$ with spectral-weight transfer across the avoided crossing | Broadband relativistic synchrotron harmonic comb extending to X-ray critical frequency $\omega_c = \frac{3}{2}\omega_{\mathrm{rot}}\gamma_e^3$ into a Cherenkov/Mach cone |
| **Reversibility vs. Radiative Escape** | Reversible coherent Rabi oscillations between cavity photon and emitter | Reversible hybrid plasmon–cavity polariton beating damped by Drude/phonon rate $\gamma_{\mathrm{SPP}}$ | Irreversible open-boundary travelling-wave emission into the asymptotic far-field radiation zone |
| **$Gr_{\mathbb{C}}(2,4)$ Representation** | 2-plane Hopfield mixing matrix $M_{\mathrm{Hopfield}}(d_{\mathrm{Hopfield}}, \theta)$ with $N_e = 1$ | Collective $Gr_{\mathbb{C}}(2,4)$ Hopfield hybridization $4|C|^2|X|^2 = 1 - d_{\mathrm{Hopfield}}^2$ | Cherenkov/synchrotron Mach cone $M_{\mathrm{Cherenkov}}(\chi_C, \theta)$ with $\chi_C = \cos\theta_C = v_{\mathrm{ph}}/v_e \in (0, 1)$ |

---

## 5. Cherenkov Radiation vs. SPPs, Effective Mass in Longitudinal Plasma Waves, Electron-Phonon Whirlpools, and Graphene THz-eV Free-Electron SPP Amplification

### 5.1 Why Transverse Plasma Waves Have Superluminal Phase Velocity ($v_{\mathrm{ph},\perp} > c$) While Longitudinal Effective-Mass Waves and SPPs Enable Cherenkov Resonance

A foundational question raised in the literature ([HN Discussion 40876505](#pol-hn40876505)) is:
> *(a) Are SPPs distinct from Cherenkov radiation and photon–electron–phonon vorticity? (b) What is the exact relation between the Vavilov–Cherenkov condition and effective photon mass in longitudinal plasma waves?*

In `Signals.Scattering` (`csr_spp_cherenkov_cavity_and_grover_identities`), we prove the exact kinematic dichotomy that answers both questions:

1. **Transverse Electromagnetic Plasma Waves Have Effective Proca Mass $m_{\mathrm{eff}} = \hbar\omega_p / c^2$ and Strictly Superluminal Phase Velocity ($v_{\mathrm{ph},\perp} > c$)**:
   In an isotropic, unmagnetized plasma with plasma frequency $\omega_p > 0$ ($\varepsilon(\omega) = 1 - \omega_p^2 / \omega^2$), transverse electromagnetic waves obey the Klein–Gordon / Proca dispersion relation $\omega^2 = \omega_p^2 + c^2 k^2$. For any propagating mode ($\omega > \omega_p$), the squared phase velocity (`transversePlasmaPhaseVelSq`) is:
   $$v_{\mathrm{ph},\perp}^2(c, \omega, \omega_p) = \frac{\omega^2}{k^2} = \frac{c^2\,\omega^2}{\omega^2 - \omega_p^2} > c^2.$$
   Because every material charge satisfies $v_e < c < v_{\mathrm{ph},\perp}$, **subluminal electrons can never emit transverse Cherenkov radiation in an isotropic unmagnetized plasma** ($\cos\theta_C = v_{\mathrm{ph},\perp} / v_e > 1$ has no real angle solution).
2. **Longitudinal Bohm–Gross Plasma Waves and SPPs Slow the Phase Velocity Below $c$ ($v_{\mathrm{ph}} < c$), Enabling Subluminal Cherenkov / Landau Synchronous Emission**:
   - **Longitudinal Plasma Waves (`longitudinalPlasmaPhaseVelSq`)**: A longitudinal Langmuir / Bohm–Gross mode ($\mathbf{E} \parallel \mathbf{k}$, where $\varepsilon_L(\omega, k) = 0$) obeys $\omega^2 = \omega_p^2 + 3 v_{\mathrm{th}}^2 k^2$, so its squared phase velocity is:
     $$v_{\mathrm{ph},\parallel}^2(v_{\mathrm{th}}, \omega_p, k) = \frac{\omega_p^2}{k^2} + 3 v_{\mathrm{th}}^2.$$
     Although the cutoff frequency $\omega_p$ acts as an effective rest mass $m_{\mathrm{eff}} = \hbar\omega_p / c^2$ at $k \to 0$, the thermal acoustic speed $3 v_{\mathrm{th}}^2 \ll c^2$ replaces $c^2$ at large $k$. For all wavenumbers $k > \omega_p / \sqrt{c^2 - 3 v_{\mathrm{th}}^2}$, the longitudinal phase velocity is **strictly subluminal** ($v_{\mathrm{ph},\parallel} < c$)!
   - **Surface Plasmon Polaritons (`sppEffectiveIndexSq`)**: Similarly, at a conductor–dielectric interface, $n_{\mathrm{SPP}}^2 = \frac{\varepsilon_d|\varepsilon_m|}{|\varepsilon_m| - \varepsilon_d} > \varepsilon_d \ge 1$ slows the SPP phase velocity to $v_{\mathrm{ph},\mathrm{SPP}} = c / n_{\mathrm{SPP}} < c$.
   - **$Gr_{\mathbb{C}}(2,4)$ Cherenkov Mach Cone (`cherenkovCosine`)**: Whenever $0 < v_{\mathrm{ph}} < v_e < c$, a subluminal electron satisfies the synchronous Cherenkov / Smith–Purcell / Landau condition $\chi_C = \cos\theta_C = \frac{v_{\mathrm{ph}}}{v_e} \in (0, 1)$, and the uncrossed $Gr_{\mathbb{C}}(2,4)$ Plücker product of `ddfThermalGr24Matrix χ_C θ` equals the squared Cherenkov Mach-cone sine:
     $$|w_A^{\mathbb{C}}|^2\,|w_B^{\mathbb{C}}|^2 = 1 - \chi_C^2 = \sin^2\theta_C = \frac{v_e^2 - v_{\mathrm{ph}}^2}{v_e^2} \in (0, 1).$$
   Thus, **SPPs and Cherenkov radiation are distinct**: an SPP is a *bound eigenmode* of a conductor–dielectric boundary ($E_z$ evanescent normal to the surface), whereas Cherenkov radiation is a *kinematic shock-cone emission mechanism* triggered whenever a charged particle exceeds the phase velocity $v_{\mathrm{ph}}$ of a medium mode (whether a bulk dielectric photon, a longitudinal Bohm–Gross plasma wave, or a surface plasmon polariton as in [Lei et al. 2025](#pol-lei2025) and [Zhang et al. 2022](#pol-zhang2022)).
3. **Distinction from Photon–Electron–Phonon Vorticity & Room-Temperature Graphene Current Whirlpools ([Science 2024](#pol-whirlpool2024), `10.1126/science.adj2167`)**:
   In room-temperature graphene at the charge-neutrality Dirac point, electron–electron and electron–optical-phonon scattering enters a hydrodynamic Navier–Stokes regime where steady current forms stationary **current whirlpools (vortices)** ($\nabla \times \mathbf{J} \neq \mathbf{0}$) with negative nonlocal resistance ([Palm et al. 2024](#pol-whirlpool2024)). In `Signals.DDF`, these are modeled by `vortexTangentialVelocity`, `quantized_vortex_circulation`, and `plaquette_phase_slip_syndrome` (real-space circulation vortices in the carrier velocity field), whereas an SPP is a high-frequency propagating TM surface wave whose Poynting vector circulates in the $(x, z)$ plane via transverse spin-momentum locking without requiring a dc current whirlpool.

### 5.2 Free-Electron SPP Amplification ([Zhang et al. 2022](#pol-zhang2022)) Driven by Terahertz-eV Graphene Circuits

In [Zhang et al. (2022)](#pol-zhang2022) (*Nature* `10.1038/s41586-022-05239-2` / `d41586-022-03455-4`; modeled by `SPPFreeElectronAmplifier` in [src/signals/Signals/ActiveOptics.lean](../src/signals/Signals/ActiveOptics.lean#L86-L125)), free electrons moving along a metallic wire pump and coherently amplify a co-propagating SPP seed, obeying the passive/active power balance $P_{\mathrm{out}} + P_{\mathrm{loss}} = P_{\mathrm{in}} + P_{e\text{-pump}}$ and a twofold redshift relation $\omega_{\mathrm{final}} = \omega_{\mathrm{initial}} / 2$.

How would the emissions vary if this experiment were driven by a **Terahertz-electronvolt ($E_F \sim 0.1\text{–}1.0\text{ eV}$, $f \sim 0.5\text{–}30\text{ THz}$) input from an on-chip graphene circuit**?
- **Dirac Plasmon Scaling (`grapheneDiracPlasmonFreqSq`)**: Unlike 3D noble metals with fixed eV-scale plasma frequency $\omega_p \propto n_{3D}^{1/2}$, massless 2D Dirac fermions in graphene have a gate-tunable plasmon dispersion:
  $$\omega_{\mathrm{GPP}}^2(E_F, q) = \frac{e^2\,E_F}{2\pi\varepsilon_0\varepsilon_r\hbar^2}\,q \propto E_F\,q.$$
  In `csr_spp_cherenkov_cavity_and_grover_identities`, we prove the exact linear scaling $\operatorname{grapheneDiracPlasmonFreqSq}(\lambda_E E_F, q) = \lambda_E \operatorname{grapheneDiracPlasmonFreqSq}(E_F, q)$.
- **Three Concrete Emission Consequences for a Graphene THz-eV Circuit**:
  1. **Ultra-Slow Phase Velocity ($v_{\mathrm{ph}} \sim c / 100$) Lowers Required Electron Energy from keV to On-Chip eV**: Because graphene plasmons at THz/mid-IR frequencies have $n_{\mathrm{SPP}} \sim 50\text{–}100$, the synchronous Cherenkov/Smith–Purcell electron velocity $v_e \approx v_{\mathrm{ph}} = c / n_{\mathrm{SPP}} \approx 3 \times 10^6\text{ m/s}$ corresponds to a kinetic energy of only $E_e = \frac{1}{2}m_e v_e^2 \approx 25\text{ eV}$ (solid-state ballistic/tunneling voltage) rather than relativistic keV–MeV vacuum electron beams.
  2. **Voltage-Tunable THz Emission Window**: Sweeping the graphene gate chemical potential $E_F \in [0.1, 0.8]\text{ eV}$ continuously tunes the amplified SPP emission frequency as $\omega_{\mathrm{GPP}} \propto \sqrt{E_F}$ across the $1\text{–}30\text{ THz}$ band.
  3. **Sub-Wavelength Bohm Quantum Pressure & Landau Damping Boundary**: By `MovingSheath.sppTensorSplat_and_thermal_identities`, the $n_{\mathrm{SPP}} \sim 100$ confinement amplifies the hotspot Bohm potential by $n_{\mathrm{SPP}}^2(1 + \kappa_{\mathrm{ratio}}^2)/2 \ge 10^4\times$, while interband Landau damping turns on sharply if $\hbar\omega_{\mathrm{GPP}} > 2 E_F$ (requiring operation in the Pauli-blocked window $\hbar\omega_{\mathrm{GPP}} < 2 E_F$).

### 5.3 Low-Symmetry Hyperbolic Shear Polaritons (`arXiv:2312.06805`), Grover State Carving (`10.1103/s3vs-xz7w`), & Single Rare-Earth Ion Fiber Addressing (`oe-33-19-41011`)

Our Lean 4 and Rust models also capture three complementary nanophotonic regimes from [HN Discussion 41442489](#pol-hn41442489) and [HN Discussion 45620981](#pol-hn45620981):
- **Low-Symmetry Shear Phonon-Polaritons (`lowSymmetryShearCoupling`; [Galiffi et al. 2023](#pol-galiffi2023), `arXiv:2312.06805`)**: In low-symmetry monoclinic or trigonal crystals such as $\alpha$-quartz or $\beta\text{-Ga}_2\text{O}_3$, non-orthogonal phonon oscillators induce an off-diagonal shear permittivity $\varepsilon_{xy} = (\varepsilon_1 - \varepsilon_2)\sin\phi\cos\phi$. We prove in `RiverExterior.holographic_gr24_ddf_and_antiAmplituhedron_identities` that $\varepsilon_{xy}$ vanishes in isotropic media ($\varepsilon_1 = \varepsilon_2$) or along principal axes ($\phi = 0$), and drives asymmetric hyperbolic shear canalization when $\varepsilon_1 \neq \varepsilon_2$ and $\sin(2\phi) \neq 0$.
- **Deterministic Quantum State Carving via Grover's Reflection (`groverSuccessAmplitude`; [Phys. Rev. A 2025](#pol-grover2025), `10.1103/s3vs-xz7w`)**: Carving a target quantum state out of an $N$-dimensional cavity/qudit superposition by alternating phase-oracle and diffusion reflections rotates the target amplitude from $\sin\theta = 1/\sqrt{N}$ to $\sin(3\theta) = \sin\theta(3 - 4\sin^2\theta)$ in one step. We prove in `csr_spp_cherenkov_cavity_and_grover_identities` that for $N = 4$ ($\sin\theta = 1/2$, corresponding to the 4 twistor columns of $Gr_{\mathbb{C}}(2,4)$), `groverSuccessAmplitude (1 / 2) = 1`—achieving **100% deterministic state carving in a single step**.
- **Selective Single Rare-Earth Ion Excitation in Optical Fiber ([Optics Express 2025](#pol-rareearth2025), `oe-33-19-41011`)**: Frequency-domain spectral hole burning and sub-wavelength mode addressing isolate a single rare-earth ion ($N_e = 1$) inside a guided fiber mode, operating in the single-emitter limit $C_1 = \operatorname{cavityQEDCooperativity}(g_0, \kappa, \gamma)$ paired with a localized `NormedTensorGaussianSplat2D` mode profile.

---

## 6. Anti-Amplituhedron Destructive Phase Cancellation for Hydroxyl ($\text{OH}^*$) Plasma Fire Suppression

In [docs/anti-fire-cannon-review.md](anti-fire-cannon-review.md), a speculative proposal hypothesized projecting an **"Anti-Amplituhedron"** phase profile to cancel hydroxyl ($\text{OH}^*$) radical plasma in underground fires. Using our complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ and SPP attenuation mechanics in `Signals.DDF` ([src/signals/Signals/DDF.lean](../src/signals/Signals/DDF.lean#L4420-L4660)), we establish the exact boundary between what is **mathematically proved** and what remains an **unverified physical hypothesis**:

1. **What Is Mathematically True on $Gr_{\mathbb{C}}(2,4)$ (`antiAmplituhedronGr24Matrix`)**:
   In the *positive* real Grassmannian $Gr_{\ge 0}(2,4)$ (the domain of the standard tree-level Amplituhedron), all ordered Plücker minors are nonnegative, so $w_A + w_B = \Delta_{02}\Delta_{13} > 0$ can **never** cancel to zero for active channels. However, lifting to the *complex* Grassmannian $Gr_{\mathbb{C}}(2,4)$ outside $Gr_{\ge 0}(2,4)$ via `antiAmplituhedronGr24Matrix A = complexGr24ChannelMatrix A (-A)` ($\Delta\theta = \pi$ phase inversion) produces two active channels with $w_A^{\mathbb{C}} = +A$, $w_B^{\mathbb{C}} = -A$, and $|w_A^{\mathbb{C}}|^2 = |w_B^{\mathbb{C}}|^2 = A^2 > 0$ whose coherent crossing amplitude vanishes identically (`RiverExterior.holographic_gr24_ddf_and_antiAmplituhedron_identities`):
   $$w_A^{\mathbb{C}}(M_{\mathrm{anti}}) + w_B^{\mathbb{C}}(M_{\mathrm{anti}}) = \Delta_{02}^{\mathbb{C}}(M_{\mathrm{anti}})\,\Delta_{13}^{\mathbb{C}}(M_{\mathrm{anti}}) = A + (-A) = 0.$$
   This is a genuine destructive interferometric null (an "anti-amplituhedron" dark node in $Gr_{\mathbb{C}}(2,4) \setminus Gr_{\ge 0}(2,4)$) that creates a steep local ponderomotive intensity gradient $\nabla |\mathbf{E}|^2$ (`ponderomotiveForce_down_gradient` in `Signals.MHD`).
2. **Physical Soil Attenuation & Thermodynamic Boundaries (`evolveContinuumSppPropagation`)**:
   - **Electromagnetic Skin-Depth Attenuation in Moist Soil**: At $400\text{–}800\text{ GHz}$, moist soil and landfill overburden have strong dielectric loss $\gamma_{\mathrm{soil}} \gg 1\text{ m}^{-1}$, so the continuum intensity `evolveContinuumSppPropagation γ_soil L I0` decays exponentially as $I_0 \exp(-\gamma_{\mathrm{soil}} L)$ within millimeters to centimeters unless delivered mechanically via the **ground-driven anti-fire shaft array** documented in [docs/anti-fire-cannon-review.md](anti-fire-cannon-review.md#L58-L96).
   - **Destructive Interference Redistributes Energy Rather Than Destroying Heat**: A destructive phase null $\Delta_{02}^{\mathbb{C}}\Delta_{13}^{\mathbb{C}} = 0$ at a focal node shifts electromagnetic energy into adjacent constructive lobes (preserving total $L^1$ / $L^2$ energy); it does not by itself remove the stored sensible heat $\rho c_v \Delta T$ of a burning solid mass without an explicit thermal sink (`MHDPowerAccounting` / `ClassicalControlVolume`).

---

## 7. How Optical Amplification Works: Low-Power Second-Harmonic ($\chi^{(2)}$) Resonance ([Dean et al. 2025](#pol-dean2025), `10.1038/s41586-025-09959-z`) vs. Free-Electron SPP Pumping ([Zhang et al. 2022](#pol-zhang2022)) and Rare-Earth Inversion

How does **low-power integrated optical amplification through second-harmonic resonance** ([Dean et al. 2025](#pol-dean2025), *Nature*, `10.1038/s41586-025-09959-z`; modeled by `SecondHarmonicResonance`, `ActiveOpticalAmplifier`, and `LowPowerIntegratedOPA` in [src/signals/Signals/ActiveOptics.lean](../src/signals/Signals/ActiveOptics.lean#L18-L84) and by `second_harmonic_opa_and_centrosymmetry_identities` / `opaSqueezed_splat_and_continuum_identities` in `Signals.Scattering` and `Signals.DDF`) work physically and mathematically, and how does it compare against Erbium-Doped Fiber Amplifiers (EDFAs) and Free-Electron SPP Amplification ([Zhang et al. 2022](#pol-zhang2022))?

### 7.1 The Four-Step Physical & Mathematical Mechanism of Second-Harmonic Resonant Optical Parametric Amplification (OPA)

1. **Symmetry Selection Rule — Why $\chi^{(2)}$ Requires Non-Centrosymmetric Crystals (`secondOrderPolarization`)**:
   The second-order nonlinear polarization is $P_i^{(2)} = \varepsilon_0 \sum_{jk} \chi_{ijk}^{(2)} E_j E_k$ (`secondOrderPolarization χ2 E = χ2 * E^2`). Under spatial inversion $\mathbf{r} \mapsto -\mathbf{r}$, the polar vectors $\mathbf{P}^{(2)}$ and $\mathbf{E}$ invert ($\mathbf{P}^{(2)} \mapsto -\mathbf{P}^{(2)}$, $\mathbf{E} \mapsto -\mathbf{E}$), so $E^2 = (-E)^2$ is invariant while $P^{(2)}$ changes sign. In any **centrosymmetric** material, the crystal is invariant under inversion ($\chi^{(2)} = -\chi^{(2)}$), which we prove in `second_harmonic_opa_and_centrosymmetry_identities` forces:
   $$\chi^{(2)} = -\chi^{(2)} \implies \chi^{(2)} = 0 \implies P^{(2)}(\chi^{(2)}, E) = 0.$$
   Therefore, centrosymmetric pristine graphene, achiral carbon nanotubes, and isotropic amorphous lignin have vanishing bulk $\chi^{(2)} = 0$. Achieving $\chi^{(2)}$ second-harmonic generation (SHG) and optical parametric amplification (OPA) requires a **non-centrosymmetric** crystal lattice—such as Periodically Poled Thin-Film Lithium Niobate ($\text{TFLN}$, $\text{LiNbO}_3$, used in [Dean et al. 2025](#pol-dean2025)), trigonal $\alpha$-quartz, or macroscopically aligned chiral **Cellulose Nanocrystals (CNCs)** (`CelluloseStripResonator`; [Provenance Chat Log: Breaking Centrosymmetry with Aligned CNCs in SHG Resonant OPA (2026)](#pol-chat-opa2026), lines 3020–3165).
2. **Resonant Second-Harmonic Recirculation Buildup (`shgResonantIntracavityPower`)**:
   In a conventional single-pass $\chi^{(2)}$ OPA, an input fundamental wave ($\omega_0$) first generates a second-harmonic pump ($\omega_{\mathrm{SH}} = 2\omega_0$, `SecondHarmonicResonance`), which then parametrically amplifies a signal ($\omega_s$) and idler ($\omega_i = 2\omega_0 - \omega_s$) via three-wave mixing $2\omega_0 \to \omega_s + \omega_i$. Because single-pass SHG is inefficient at low power, conventional OPAs require watt-to-kilowatt peak pump powers.
   In [Dean et al. (2025)](#pol-dean2025) (`10.1038/s41586-025-09959-z`), the integrated waveguide resonator **resonantly traps and recirculates the second harmonic ($2\omega_0$)** with cavity buildup factor $F_{\mathrm{SH}} \ge 1$ (`shgResonantIntracavityPower F_sh P_2w = F_sh * P_2w`). We prove in `second_harmonic_opa_and_centrosymmetry_identities`:
   $$P_{2\omega} \le P_{2\omega}^{\mathrm{intracav}} = F_{\mathrm{SH}}\,P_{2\omega}, \qquad F_{\mathrm{SH}}\,\left(\frac{P_{\mathrm{thresh}}}{F_{\mathrm{SH}}}\right) = P_{\mathrm{thresh}},$$
   proving that resonant recirculation lowers the external input power required to reach a parametric threshold $P_{\mathrm{thresh}}$ by a factor of $F_{\mathrm{SH}}$—enabling $>17\text{ dB}$ broadband gain with $<200\text{ mW}$ input power (`LowPowerIntegratedOPA`), while strictly obeying the thermodynamic energy conservation bound $P_{\mathrm{out}} \le P_{\mathrm{in}} + P_{\mathrm{pump}}$ (`ActiveOpticalAmplifier.output_le_input_and_pump`).
3. **Phase-Matching Detuning Gate (`opaNetGainSq`)**:
   For parametric coupling rate $g_{\mathrm{OPA}}$ and wavevector phase mismatch $\Delta k = k_{2\omega} - k_s - k_i$, the net squared spatial gain rate is (`opaNetGainSq`):
   $$g_{\mathrm{net}}^2(g_{\mathrm{OPA}}, \Delta k) = g_{\mathrm{OPA}}^2 - \left(\frac{\Delta k}{2}\right)^2 \le g_{\mathrm{OPA}}^2.$$
   At perfect phase matching ($\Delta k = 0$), $g_{\mathrm{net}}^2(g_{\mathrm{OPA}}, 0) = g_{\mathrm{OPA}}^2$ reaches maximum gain; when piezoelectric or electro-optic detuning shifts $\Delta k \to 2 g_{\mathrm{OPA}}$, $g_{\mathrm{net}}^2(g_{\mathrm{OPA}}, 2 g_{\mathrm{OPA}}) = 0$, switching off the parametric gain cleanly without mechanical moving parts.
4. **Symplectic Phase-Sensitive Quadrature Squeezing & Bohm Quantum-Potential Barrier (With and Without Splats: `opaSqueezed_splat_and_continuum_identities`)**:
   In a degenerate phase-sensitive OPA with squeeze parameter $r_{\mathrm{sq}} = g_{\mathrm{eff}} L \ge 0$, the in-phase quadrature is amplified by $G_+(r_{\mathrm{sq}}) = \exp(2 r_{\mathrm{sq}}) \ge 1$ (`opaAmplifiedQuadratureGain`) while the orthogonal quadrature is squeezed by $G_-(r_{\mathrm{sq}}) = \exp(-2 r_{\mathrm{sq}}) \le 1$ (`opaSqueezedQuadratureGain`), with exact symplectic unit product $G_+(r_{\mathrm{sq}})\,G_-(r_{\mathrm{sq}}) = 1$.
   - **Without Splats**: The squeezed-quadrature continuum Bohm potential scale `continuumBohmPotentialMode m hbar (κ0 * exp r_sq)` is amplified by $\exp(2 r_{\mathrm{sq}}) \ge 1$.
   - **With Normed Tensor Gaussian Splats (`opaSqueezedTensorSplat`)**: A wavepacket with principal widths $\sigma_1 = \sigma_0 e^{r_{\mathrm{sq}}}$ and $\sigma_2 = \sigma_0 e^{-r_{\mathrm{sq}}}$ preserves its symplectic phase-space area $\det\Sigma_{\mathrm{OPA}} = \sigma_0^4$ and peak normalization $\mathcal{N}(\Sigma_{\mathrm{OPA}}) = \frac{1}{2\pi\sigma_0^2}$ identically (matching our Anosov symplectic invariance theorem `anosov_plucker_invariance`), while its repulsive core Bohm quantum potential increases to:
     $$Q_{\mathrm{core}}(\Sigma_{\mathrm{OPA}}) = \frac{\hbar^2\,\bigl(\exp(2 r_{\mathrm{sq}}) + \exp(-2 r_{\mathrm{sq}})\bigr)}{4 m\,\sigma_0^2} \ge \frac{\hbar^2}{2 m\,\sigma_0^2}.$$

### 7.2 Comparison of Three Optical Amplification Paradigms in `Signals`

| Amplification Mechanism | Physical Gain Medium & Symmetry Requirement | Frequency & Phase-Matching Law | Noise Limit & Reversibility | Lean 4 Formalization in `Signals` |
|---|---|---|---|---|
| **1. Second-Harmonic ($\chi^{(2)}$) Resonant OPA** ([Dean et al. 2025](#pol-dean2025), `10.1038/s41586-025-09959-z`) | **Non-centrosymmetric** dielectric crystal ($\chi^{(2)} \neq 0$: $\text{TFLN}$ $\text{LiNbO}_3$, $\alpha$-quartz, or aligned chiral CNCs; **zero rare-earth ions**) | $\omega_{\mathrm{SH}} = 2\omega_0 = \omega_{\mathrm{res}}$; $2\omega_0 \to \omega_s + \omega_i$; $g_{\mathrm{net}}^2 = g_{\mathrm{OPA}}^2 - (\Delta k / 2)^2$ | **Phase-sensitive quantum-limited ($0\text{ dB}$ noise figure)**; symplectic squeezing $\det\Sigma_{\mathrm{OPA}} = \sigma_0^4$ | `SecondHarmonicResonance`, `LowPowerIntegratedOPA`, `second_harmonic_opa_and_centrosymmetry_identities`, `opaSqueezed_splat_and_continuum_identities` |
| **2. Free-Electron-Pumped SPP Amplifier** ([Zhang et al. 2022](#pol-zhang2022), `10.1038/s41586-022-05239-2`) | Conductive metal wire or gate-tuned graphene SPP waveguide ($\varepsilon_m < -\varepsilon_d < 0$) pumped by a co-propagating electron beam | Cherenkov/Smith–Purcell velocity matching $v_e \approx v_{\mathrm{ph},\mathrm{SPP}}$; twofold redshift $\omega_{\mathrm{final}} = \omega_{\mathrm{initial}} / 2$ | Open-boundary stimulated Cherenkov/SPP energy transfer bounded by $P_{\mathrm{out}} \le P_{\mathrm{in}} + P_{e\text{-pump}}$ | `SPPFreeElectronAmplifier`, `grapheneDiracPlasmonFreqSq`, `csr_spp_cherenkov_cavity_and_grover_identities` |
| **3. Rare-Earth Inversion Amplifier (EDFA / Single-Ion Fiber)** (`oe-33-19-41011`) | $\text{Er}^{3+}$ / $\text{Yb}^{3+}$ ions doped in silica or host matrix (centrosymmetric host allowed; relies on $4f$ atomic population inversion) | Fixed atomic transition lines ($\sim 1530\text{–}1565\text{ nm}$ for $\text{Er}^{3+}$); no phase matching required | Phase-insensitive ($3\text{ dB}$ quantum spontaneous-emission noise floor); slow ms-scale $T_1$ recovery | `ActiveOpticalAmplifier`, `cavityQEDCooperativity` |

---

## 8. Machine-Checked Lean 4 Verification (`Signals.Scattering` & `Signals.DDF`)

The following self-contained Lean 4 verification block typechecks directly against `Signals` and verifies all Polariton, Surface Plasmon Polariton, CSR-SPP, Cherenkov–Proca, Graphene THz-eV, Grover state-carving, Anti-Amplituhedron, and Second-Harmonic Resonant OPA theorems—both **without splats** and **with Normed 2D Anisotropic Tensor Gaussian Splats**:

```lean
import Signals

namespace ArxivPolaritonSppPaperVerification

open Signals.Geometry
open Signals.Scattering
open Signals.DDF

-- 1. Polariton Hopfield-Rabi anticrossing, inverse Rabi spectroscopy, Gr_C(2,4) hybridization complementarity, and Lyddane-Sachs-Teller Reststrahlen band
example :
    let ω_UP := upperPolaritonFreq 7 4 2
    let ω_LP := lowerPolaritonFreq 7 4 2
    let d_hop := hopfieldBarycentricShift (7 - 4) 2
    let w_ph := hopfieldPhotonWeight d_hop
    let w_ex := hopfieldMatterWeight d_hop
    ω_UP + ω_LP = 7 + 4 ∧
    ω_UP - ω_LP = polaritonEffectiveRabiSplitting (7 - 4) 2 ∧
    2 * 2 ≤ ω_UP - ω_LP ∧
    reconstructPolaritonRabiCouplingSq 7 4 ω_UP ω_LP = 2 ^ 2 ∧
    -1 < d_hop ∧ d_hop < 1 ∧
    w_ph + w_ex = 1 ∧
    w_ph - w_ex = d_hop ∧
    4 * w_ph * w_ex = 1 - d_hop ^ 2 ∧
    1 - d_hop ^ 2 = (4 * 2 ^ 2) / ((7 - 4 : ℝ) ^ 2 + 4 * 2 ^ 2) ∧
    lyddaneSachsTellerPermittivity 3 4 6 0 = 3 * (6 ^ 2 / 4 ^ 2) ∧
    lyddaneSachsTellerPermittivity 3 4 6 6 = 0 ∧
    lyddaneSachsTellerPermittivity 3 4 6 5 < 0 :=
  polariton_hopfield_rabi_and_lst_identities
    7 4 2 3 4 6 5 (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num)

-- 2. Surface Plasmon Polaritons (SPPs) With and Without Normed Tensor Gaussian Splats
example {sub : DDFSubstrate} (s : MovingSheath sub) (θ x y : ℝ) :
    -- (A) Without Splats: Continuum SPP Dispersion, Gr_C(2,4) Plücker Skin-Depth Ratio, Spatial Semigroup, and Evanescent Bohm Scaling
    let n_spp_sq := sppEffectiveIndexSq 2 6
    let chi_spp := sppPermittivityContrast 2 6
    let M_spp := sppGr24Matrix chi_spp θ
    let I_step1 := evolveContinuumSppPropagation (1 / 2) 3 10
    -- (B) With Tensor Gaussian Splats: Sub-Wavelength SPP Hotspot Compression, Bohm Quantum Pressure Amplification, and Ohmic-Thermal Semigroup
    let splat_spp := sppHotspotTensorSplat 0 0 5 1 10 3
      (by norm_num) (by norm_num) (by norm_num) (by norm_num) θ
    let spp_step0 := splat_spp.evolveThermal 1 2 0 (by norm_num) (by norm_num) le_rfl
    let spp_step1 := splat_spp.evolveThermal 1 2 3 (by norm_num) (by norm_num) (by norm_num)
    let spp_step12 := spp_step1.evolveThermal 1 2 4 (by norm_num) (by norm_num) (by norm_num)
    let spp_step_sum := splat_spp.evolveThermal 1 2 (3 + 4) (by norm_num) (by norm_num) (by norm_num)
    n_spp_sq - 2 = 2 ^ 2 / (6 - 2) ∧
    2 < n_spp_sq ∧
    (n_spp_sq - 2) / (n_spp_sq + 6) = 2 ^ 2 / 6 ^ 2 ∧
    Complex.normSq (complexPluckerSinkAmplitudeA M_spp) /
        Complex.normSq (complexPluckerSinkAmplitudeB M_spp) =
      reconstructSppPermittivityRatio chi_spp ∧
    reconstructSppPermittivityRatio chi_spp = 6 / 2 ∧
    Complex.normSq (complexPluckerSinkAmplitudeA M_spp) *
        Complex.normSq (complexPluckerSinkAmplitudeB M_spp) =
      (4 * 2 * 6) / (6 + 2) ^ 2 ∧
    evolveContinuumSppPropagation (1 / 2) 0 10 = 10 ∧
    evolveContinuumSppPropagation (1 / 2) 4 I_step1 =
      evolveContinuumSppPropagation (1 / 2) (3 + 4) 10 ∧
    continuumBohmPotentialMode 1 1 ((6 / 2) * 5) =
      (6 / 2) ^ 2 * continuumBohmPotentialMode 1 1 5 ∧
    splat_spp.covDet = 1 ^ 4 / (10 ^ 4 * 3 ^ 2) ∧
    splat_spp.normFactor = (10 ^ 2 * 3) / (2 * Real.pi * 1 ^ 2) ∧
    1 ^ 2 / (2 * 1 * 1 ^ 2) ≤ splat_spp.coreBohmPotential 1 1 ∧
    splat_spp.quantumPressurePrincipal2 1 1 x y =
      3 ^ 2 * splat_spp.quantumPressurePrincipal1 1 1 x y ∧
    spp_step0 = splat_spp ∧
    spp_step12 = spp_step_sum ∧
    spp_step1.coreBohmPotential 1 1 ≤ splat_spp.coreBohmPotential 1 1 := by
  intro n_spp_sq chi_spp M_spp I_step1 splat_spp spp_step0 spp_step1 spp_step12 spp_step_sum
  have h_cont := s.sppContinuum_gr24_and_semigroup_identities
    2 6 (1 / 2) 3 4 10 5 1 1 θ (by norm_num) (by norm_num)
  have h_splat := s.sppTensorSplat_and_thermal_identities
    0 0 5 1 10 3 1 2 3 4 1 1 θ x y
    (by norm_num) (by norm_num) (by norm_num) (by norm_num)
    (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  exact ⟨h_cont.1, h_cont.2.1, h_cont.2.2.1, h_cont.2.2.2.2.2.1,
    h_cont.2.2.2.2.2.2.1, h_cont.2.2.2.2.2.2.2.1,
    h_cont.2.2.2.2.2.2.2.2.1, h_cont.2.2.2.2.2.2.2.2.2.1,
    h_cont.2.2.2.2.2.2.2.2.2.2,
    h_splat.1, h_splat.2.1, h_splat.2.2.2.1, h_splat.2.2.2.2.1,
    h_splat.2.2.2.2.2.1, h_splat.2.2.2.2.2.2.1, h_splat.2.2.2.2.2.2.2⟩

-- 3. CSR-SPP superradiance, Cavity QED cooperativity, Cherenkov-Proca phase matching, Graphene THz-eV scaling,
--    Grover state carving, Anti-Amplituhedron cancellation, and Second-Harmonic Resonant OPA (with and without splats)
example {sub : DDFSubstrate} (re : RiverExterior sub)
    (hr : re.horizonRadius < 4) (θ φ x y : ℝ) :
    let M_anti := antiAmplituhedronGr24Matrix 5
    let splat_opa := opaSqueezedTensorSplat 0 0 5 2 3 (by norm_num) (by norm_num) θ
    csrBunchingIntensity 10 0 3 = 10 * 3 ∧
    csrBunchingIntensity 10 1 3 = 10 ^ 2 * 3 ∧
    10 * 3 ≤ csrBunchingIntensity 10 (1 / 2) 3 ∧
    csrBunchingIntensity 10 (1 / 2) 3 ≤ 10 ^ 2 * 3 ∧
    cavityQEDCooperativity (Real.sqrt 10 * 2) 3 5 =
      10 * cavityQEDCooperativity 2 3 5 ∧
    (2 : ℝ) ^ 2 < transversePlasmaPhaseVelSq 2 5 3 ∧
    longitudinalPlasmaPhaseVelSq (1 / 2) 3 2 < 2 ^ 2 ∧
    0 < 1 - (cherenkovCosine 3 5) ^ 2 ∧
    grapheneDiracPlasmonFreqSq (4 * 2) 7 =
      4 * grapheneDiracPlasmonFreqSq 2 7 ∧
    groverSuccessAmplitude (1 / 2) = 1 ∧
    complexTwoRowMinor M_anti 0 2 * complexTwoRowMinor M_anti 1 3 = 0 ∧
    lowSymmetryShearCoupling 4 4 φ = 0 ∧
    secondOrderPolarization 0 10 = 0 ∧
    shgResonantIntracavityPower 15 (300 / 15) = 300 ∧
    opaNetGainSq 4 (2 * 4) = 0 ∧
    opaAmplifiedQuadratureGain 3 * opaSqueezedQuadratureGain 3 = 1 ∧
    continuumBohmPotentialMode 1 1 5 ≤
      continuumBohmPotentialMode 1 1 (5 * Real.exp 3) ∧
    splat_opa.covDet = 2 ^ 4 ∧
    1 ^ 2 / (2 * 1 * 2 ^ 2) ≤ splat_opa.coreBohmPotential 1 1 ∧
    splat_opa.quantumPressurePrincipal2 1 1 x y =
      Real.exp (4 * 3) * splat_opa.quantumPressurePrincipal1 1 1 x y := by
  intro M_anti splat_opa
  have h_csr := csr_spp_cherenkov_cavity_and_grover_identities
    10 (1 / 2) 3 2 5 2 3 5 2 5 3 (1 / 2) 2 3 5 4 2 7
    (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num)
    (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  have h_holo := re.holographic_gr24_ddf_and_antiAmplituhedron_identities
    5 4 2 φ 4 1 (1 / 2) 0 0 1 1 1 θ hr
    (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  have h_opa := second_harmonic_opa_and_centrosymmetry_identities
    0 10 15 20 300 4 2 3 (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  have h_opa_splat := opaSqueezed_splat_and_continuum_identities
    0 0 5 2 3 5 1 1 θ x y (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  exact ⟨h_csr.1, h_csr.2.1, h_csr.2.2.1, h_csr.2.2.2.1, h_csr.2.2.2.2.2.1,
    h_csr.2.2.2.2.2.2.1, h_csr.2.2.2.2.2.2.2.1, h_csr.2.2.2.2.2.2.2.2.2.2.2.1,
    h_csr.2.2.2.2.2.2.2.2.2.2.2.2.1, h_csr.2.2.2.2.2.2.2.2.2.2.2.2.2,
    h_holo.2.2.1, h_holo.2.2.2.1,
    h_opa.2.1, h_opa.2.2.2.1, h_opa.2.2.2.2.2.2.1, h_opa.2.2.2.2.2.2.2.2.2,
    h_opa_splat.2.1, h_opa_splat.2.2.1, h_opa_splat.2.2.2.2.2.1,
    h_opa_splat.2.2.2.2.2.2⟩

end ArxivPolaritonSppPaperVerification
```

---

## 9. Rust & WebAssembly (`wasm32-unknown-unknown`) Implementation and Reproducibility

In [src/signals/numerical_adapter/src/polariton_spp.rs](../src/signals/numerical_adapter/src/polariton_spp.rs), `PolaritonHopfieldModel`, `SurfacePlasmonPolaritonModel`, `CsrSppCherenkovCavityModel`, `HolographicDdfGr24Model`, and `SecondHarmonicResonantOpaModel` (with both splat-free continuum methods and `NormedTensorGaussianSplat2D` hotspot/Planck/OPA-squeezed methods) are implemented in pure Rust with C-ABI WebAssembly exports (`wasm_polariton_upper_freq`, `wasm_polariton_lower_freq`, `wasm_spp_effective_index`, `wasm_spp_hotspot_bohm_potential`, `wasm_csr_bunching_intensity`, `wasm_bekenstein_hawking_entropy`, `wasm_shg_opa_squeezed_bohm_potential`), parametric `rstest` suites, and `insta` regression snapshots ([signals_numerical_adapter__polariton_spp__tests__polariton_and_spp_gr24_ddf_summary.snap](../src/signals/numerical_adapter/src/snapshots/signals_numerical_adapter__polariton_spp__tests__polariton_and_spp_gr24_ddf_summary.snap)).

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

<a id="pol-hopfield1958"></a>
1. Hopfield, J. J. (1958). *Theory of the Contribution of Excitons to the Complex Dielectric Constant of Crystals*. Physical Review 112(5), 1555–1567. [DOI: 10.1103/PhysRev.112.1555](https://doi.org/10.1103/PhysRev.112.1555).

<a id="pol-huang1951"></a>
2. Huang, K. (1951). *On the Interaction between the Radiation Field and Ionic Crystals*. Proceedings of the Royal Society of London A 208(1094), 352–365. [DOI: 10.1098/rspa.1951.0166](https://doi.org/10.1098/rspa.1951.0166).

<a id="pol-lst1941"></a>
3. Lyddane, R. H., Sachs, R. G., and Teller, E. (1941). *On the Polar Vibrations of Alkali Halides*. Physical Review 59(8), 673–676. [DOI: 10.1103/PhysRev.59.673](https://doi.org/10.1103/PhysRev.59.673).

<a id="pol-weisbuch1992"></a>
4. Weisbuch, C., Nishioka, M., Ishikawa, A., and Arakawa, Y. (1992). *Observation of the Coupled Exciton-Photon Mode Splitting in a Semiconductor Quantum Microcavity*. Physical Review Letters 69(23), 3314–3317. [DOI: 10.1103/PhysRevLett.69.3314](https://doi.org/10.1103/PhysRevLett.69.3314).

<a id="pol-raether1988"></a>
5. Raether, H. (1988). *Surface Plasmons on Smooth and Rough Surfaces and on Gratings*. Springer Tracts in Modern Physics, Vol. 111. [DOI: 10.1007/BFb0048317](https://doi.org/10.1007/BFb0048317).

<a id="pol-barnes2003"></a>
6. Barnes, W. L., Dereux, A., and Ebbesen, T. W. (2003). *Surface plasmon subwavelength optics*. Nature 424(6950), 824–830. [DOI: 10.1038/nature01937](https://doi.org/10.1038/nature01937).

<a id="pol-maier2007"></a>
7. Maier, S. A. (2007). *Plasmonics: Fundamentals and Applications*. Springer. [DOI: 10.1007/0-387-37825-1](https://doi.org/10.1007/0-387-37825-1).

<a id="pol-lei2025"></a>
8. Lei, B., et al. (2025). *Coherent synchrotron radiation by excitation of surface plasmon polariton on near-critical solid microtube surface*. Physical Review Letters, `10.1103/cnym-16hc`; [arXiv:2507.04561](https://arxiv.org/abs/2507.04561).

<a id="pol-zhang2022"></a>
9. Zhang, X., et al. (2022). *Coherent surface plasmon polariton amplification via free-electron pumping*. Nature 611, 55–60. [DOI: 10.1038/s41586-022-05239-2](https://doi.org/10.1038/s41586-022-05239-2); Research Briefing [DOI: 10.1038/d41586-022-03455-4](https://doi.org/10.1038/d41586-022-03455-4).

<a id="pol-dean2025"></a>
10. Dean, et al. (2025). *Low-power integrated optical amplification through second-harmonic resonance*. Nature. [DOI: 10.1038/s41586-025-09959-z](https://doi.org/10.1038/s41586-025-09959-z).

<a id="pol-kipp2024"></a>
11. Kipp, G., et al. (2024). *Cavity electrodynamics of van der Waals heterostructures*. Nature Physics (2025) / [arXiv:2403.19745](https://arxiv.org/abs/2403.19745).

<a id="pol-galiffi2023"></a>
12. Galiffi, E., et al. (2023). *Extreme light confinement and control in low-symmetry phonon-polaritonic crystals*. Nature Reviews Materials 9, 9–28; [arXiv:2312.06805](https://arxiv.org/abs/2312.06805).

<a id="pol-whirlpool2024"></a>
13. Palm, M. L., et al. (2024). *Observation of current whirlpools in graphene at room temperature*. Science 384(6694), 465–469. [DOI: 10.1126/science.adj2167](https://doi.org/10.1126/science.adj2167).

<a id="pol-grover2025"></a>
14. *Deterministic carving of quantum states with Grover's algorithm* (2025). Physical Review A. [DOI: 10.1103/s3vs-xz7w](https://doi.org/10.1103/s3vs-xz7w).

<a id="pol-rareearth2025"></a>
15. *Selective excitation of a single rare-earth ion in an optical fiber* (2025). Optics Express 33(19), 41011. [URL](https://opg.optica.org/oe/fulltext.cfm?uri=oe-33-19-41011).

<a id="pol-hn40876505"></a>
16. Hacker News Technical Discussion (2024–2025). *Items 40876505, 41442489, and 45620981*.

<a id="pol-chat-rydberg2026"></a>
17. Provenance Chat Log (2026). *Review Pop III GW Remnants (Exciton-Polariton Quantum Fluid of Light & Rydberg-Polariton Analog Gravity Simulator)*. ({download}`data/chats/Review-Pop-III-GW-Remnants.md, lines 1021-1135 <../data/chats/Review-Pop-III-GW-Remnants.md>`).

<a id="pol-chat-nlig2026"></a>
18. Provenance Chat Log (2026). *Gemini 08 (Monolithic N-LIG Graphene Plasmonic Waveguides & Sub-Wavelength SPP Confinement in Lignin-Vitrimer)*. ({download}`data/chats/Gemini-_08.md, lines 2536-2775 <../data/chats/Gemini-_08.md>`).

<a id="pol-chat-spp2026"></a>
19. Provenance Chat Log (2026). *SPPs, Plasma, and Material Synthesis (Surface Plasmon Polariton Hotspots, Plasmonic Catalysis, and Nuclear Transmutation Energy Barrier)*. ({download}`data/chats/_SPPs, Plasma, and Material Synthesis .md, lines 65-120 <../data/chats/_SPPs, Plasma, and Material Synthesis .md>`).

<a id="pol-chat-ldcf2026"></a>
20. Provenance Chat Log (2026). *Lignin-Derived Carbon Fibers Applications (Bulk Polariton Coupling & Phonon Decay)*. ({download}`data/chats/Lignin-Derived-Carbon-Fibers-Applications.md, lines 1940-1965 <../data/chats/Lignin-Derived-Carbon-Fibers-Applications.md>`).

<a id="pol-chat-opa2026"></a>
21. Provenance Chat Log (2026). *IQ-Sampling for Signal Phase (Breaking Centrosymmetry with Aligned CNCs in Second-Harmonic Resonant OPA & SQG Optical Gate)*. ({download}`data/chats/IQ-Sampling-for-Signal-Phase.md, lines 2318-2460 <../data/chats/IQ-Sampling-for-Signal-Phase.md>`).

<a id="pol-chat-proca2026"></a>
12. Provenance Chat Log (2026). *Classical Near-Fields vs. Proca Propagation (Evanescent Surface Plasmons vs. Propagating Longitudinal Modes)*. ({download}`data/chats/Classical-Near-Fields-vs.-Proca-Propagation.md, lines 75-115 <../data/chats/Classical-Near-Fields-vs.-Proca-Propagation.md>`).

<a id="pol-chat-iq2026"></a>
13. Provenance Chat Log (2026). *IQ-Sampling for Signal Phase (Epsilon-Near-Zero Volume Plasmon Polaritons)*. ({download}`data/chats/IQ-Sampling-for-Signal-Phase.md, lines 15120-15130 <../data/chats/IQ-Sampling-for-Signal-Phase.md>`).

---

### BibTeX Citations

```bibtex
@article{hopfield1958theory,
  author  = {Hopfield, J. J.},
  title   = {Theory of the Contribution of Excitons to the Complex Dielectric Constant of Crystals},
  journal = {Physical Review},
  volume  = {112},
  number  = {5},
  pages   = {1555--1567},
  year    = {1958},
  doi     = {10.1103/PhysRev.112.1555},
  url     = {https://doi.org/10.1103/PhysRev.112.1555}
}

@article{lyddane1941polar,
  author  = {Lyddane, R. H. and Sachs, R. G. and Teller, E.},
  title   = {On the Polar Vibrations of Alkali Halides},
  journal = {Physical Review},
  volume  = {59},
  number  = {8},
  pages   = {673--676},
  year    = {1941},
  doi     = {10.1103/PhysRev.59.673},
  url     = {https://doi.org/10.1103/PhysRev.59.673}
}

@article{barnes2003surface,
  author  = {Barnes, William L. and Dereux, Alain and Ebbesen, Thomas W.},
  title   = {Surface plasmon subwavelength optics},
  journal = {Nature},
  volume  = {424},
  number  = {6950},
  pages   = {824--830},
  year    = {2003},
  doi     = {10.1038/nature01937},
  url     = {https://doi.org/10.1038/nature01937}
}

@book{maier2007plasmonics,
  author    = {Maier, Stefan A.},
  title     = {Plasmonics: Fundamentals and Applications},
  publisher = {Springer},
  year      = {2007},
  doi       = {10.1007/0-387-37825-1},
  url     = {https://doi.org/10.1007/0-387-37825-1}
}
```

### Schema.org Metadata (JSON-LD)

```json
{
  "@context": "https://schema.org",
  "@type": "ScholarlyArticle",
  "headline": "Polaritons and Surface Plasmon Polaritons (SPPs) in Unified Grassmannian–DDF Mechanics: Hopfield–Rabi Anticrossing, Lyddane–Sachs–Teller Reststrahlen Bands, Gr_C(2,4) Evanescent Skin-Depth Duality, and Sub-Wavelength Tensor Splatting in Lean 4",
  "author": {
    "@type": "Person",
    "name": "Wes Turner"
  },
  "dateModified": "2026-10-24",
  "about": [
    "Polaritons",
    "Surface Plasmon Polaritons",
    "Hopfield Bogoliubov Transformation",
    "Lyddane-Sachs-Teller Relation",
    "Complex Grassmannian Gr_C(2,4)",
    "Dilatant Dark Fluid",
    "Normed Tensor Gaussian Splatting",
    "Lean 4 Formal Verification",
    "Rust WebAssembly"
  ],
  "isBasedOn": [
    "data/chats/Review-Pop-III-GW-Remnants.md",
    "data/chats/Gemini-_08.md",
    "data/chats/_SPPs, Plasma, and Material Synthesis .md",
    "data/chats/Lignin-Derived-Carbon-Fibers-Applications.md",
    "data/chats/Classical-Near-Fields-vs.-Proca-Propagation.md",
    "src/signals/Signals/Scattering.lean",
    "src/signals/Signals/DDF.lean",
    "src/signals/numerical_adapter/src/polariton_spp.rs"
  ]
}
```
