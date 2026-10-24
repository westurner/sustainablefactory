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
  2. [Grassmannian Geometry of the Quantum Inverse Scattering Method, Algebraic Bethe Ansatz, and Inverse Scattering Metrology in Lean 4](grassmannian-qism-bethe-ansatz-paper.myst.md)
  3. [Complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ & $N$-ary $Gr_{\mathbb{C}}(2, N+2)$ Unification with Dilatant Dark Fluid (DDF) Moving Sheaths, Plücker Sink Fluxes, Anosov Invariance, and Sorkin Triple-Slit Interferometry in Lean 4](grassmannian-ddf-moving-sheath-paper.myst.md)
  4. [Grassmannian Gravity from QED & Gauge Scattering Amplitudes: Complex $Gr_{\mathbb{C}}(2,4)$ Orbital Precession, Mercury's Perihelion, $N$-Body Dynamics, and Dilatant Dark Fluid (DDF) Unification in Lean 4](grassmannian-gravity-from-qed-scattering-paper.md)
  5. [Normed Tensor Gaussian Splat Mechanics for Complex $Gr_{\mathbb{C}}(2,4)$ Twistors: Advantages, Limitations, WebGL2/WASM Practicality, and Unification Across Double-Slit, QISM, DDF, and Planetary Gravity in Lean 4](grassmannian-splat-mechanics-paper.md)
  6. [Inelastic Scattering and the Heat Problem in Unified Grassmannian–DDF Mechanics: Inverse Compton, Stokes/Anti-Stokes Raman, Fourier vs. Cattaneo–Vernotte, and Subluminal Second-Sound Tensor Splatting in Lean 4](grassmannian-thermal-compton-raman-paper.md)

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

## 4. Machine-Checked Lean 4 Verification (`Signals.Scattering` & `Signals.DDF`)

The following self-contained Lean 4 verification block typechecks directly against `Signals` and verifies all Polariton and Surface Plasmon Polariton theorems—both **without splats** and **with Normed 2D Anisotropic Tensor Gaussian Splats**:

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

end ArxivPolaritonSppPaperVerification
```

---

## 5. Rust & WebAssembly (`wasm32-unknown-unknown`) Implementation and Reproducibility

In [src/signals/numerical_adapter/src/polariton_spp.rs](../src/signals/numerical_adapter/src/polariton_spp.rs), both `PolaritonHopfieldModel` and `SurfacePlasmonPolaritonModel` (with both splat-free continuum methods and `NormedTensorGaussianSplat2D` hotspot methods) are implemented in pure Rust with C-ABI WebAssembly exports (`wasm_polariton_upper_freq`, `wasm_polariton_lower_freq`, `wasm_spp_effective_index`, `wasm_spp_hotspot_bohm_potential`), parametric `rstest` suites, and `insta` regression snapshots ([signals_numerical_adapter__polariton_spp__tests__polariton_and_spp_gr24_ddf_summary.snap](../src/signals/numerical_adapter/src/snapshots/signals_numerical_adapter__polariton_spp__tests__polariton_and_spp_gr24_ddf_summary.snap)).

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

<a id="pol-chat-rydberg2026"></a>
8. Provenance Chat Log (2026). *Review Pop III GW Remnants (Exciton-Polariton Quantum Fluid of Light & Rydberg-Polariton Analog Gravity Simulator)*. ({download}`data/chats/Review-Pop-III-GW-Remnants.md, lines 1021-1135 <../data/chats/Review-Pop-III-GW-Remnants.md>`).

<a id="pol-chat-nlig2026"></a>
9. Provenance Chat Log (2026). *Gemini 08 (Monolithic N-LIG Graphene Plasmonic Waveguides & Sub-Wavelength SPP Confinement in Lignin-Vitrimer)*. ({download}`data/chats/Gemini-_08.md, lines 2536-2775 <../data/chats/Gemini-_08.md>`).

<a id="pol-chat-spp2026"></a>
10. Provenance Chat Log (2026). *SPPs, Plasma, and Material Synthesis (Surface Plasmon Polariton Hotspots, Plasmonic Catalysis, and Nuclear Transmutation Energy Barrier)*. ({download}`data/chats/_SPPs, Plasma, and Material Synthesis .md, lines 65-120 <../data/chats/_SPPs, Plasma, and Material Synthesis .md>`).

<a id="pol-chat-ldcf2026"></a>
11. Provenance Chat Log (2026). *Lignin-Derived Carbon Fibers Applications (Bulk Polariton Coupling & Phonon Decay)*. ({download}`data/chats/Lignin-Derived-Carbon-Fibers-Applications.md, lines 1940-1965 <../data/chats/Lignin-Derived-Carbon-Fibers-Applications.md>`).

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
  doi     = {10.1103/PhysRev.112.1555}
}

@article{lyddane1941polar,
  author  = {Lyddane, R. H. and Sachs, R. G. and Teller, E.},
  title   = {On the Polar Vibrations of Alkali Halides},
  journal = {Physical Review},
  volume  = {59},
  number  = {8},
  pages   = {673--676},
  year    = {1941},
  doi     = {10.1103/PhysRev.59.673}
}

@article{barnes2003surface,
  author  = {Barnes, William L. and Dereux, Alain and Ebbesen, Thomas W.},
  title   = {Surface plasmon subwavelength optics},
  journal = {Nature},
  volume  = {424},
  number  = {6950},
  pages   = {824--830},
  year    = {2003},
  doi     = {10.1038/nature01937}
}

@book{maier2007plasmonics,
  author    = {Maier, Stefan A.},
  title     = {Plasmonics: Fundamentals and Applications},
  publisher = {Springer},
  year      = {2007},
  doi       = {10.1007/0-387-37825-1}
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
