---
title: "Hawking Radiation, Inverse Gross–Pitaevskii (iGPE) Unwinding, and Amplituhedron/CP-ALS Decoding in Complex Grassmannian Gr_C(2,4) and Dilatant Dark Fluid (DDF) Mechanics: With and Without DDF, With and Without Normed Tensor Gaussian Splats in Lean 4"
description: "An arXiv-ready MyST Markdown formal verification and numerical simulation paper critiquing, fixing, and connecting HawkingRadiationDecoding and toyHawkingAmplituhedronMap across the 2x2 matrix of Without-DDF vs. With-DDF and Without-Splats vs. With-Splats hypotheses in Lean 4 and Rust/WASM."
---

(grassmannian-hawking-radiation-decoding-paper)=
# Hawking Radiation, Inverse Gross–Pitaevskii (`iGPE`) Unwinding, and Amplituhedron / CP-ALS Decoding in Complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ and Dilatant Dark Fluid (DDF) Mechanics: With and Without DDF, With and Without Normed Tensor Gaussian Splats in Lean 4

- **Authors:** Wes Turner
- **Subjects:**
  - General Relativity and Quantum Cosmology (`gr-qc`); Quantum Physics (`quant-ph`); Quantum Gases (`cond-mat.quant-gas`); High Energy Physics - Theory (`hep-th`); Mathematical Physics (`math-ph`); Logic in Computer Science (`cs.LO`)
- **Formal Verification & Simulation Artifacts:**
  - `Signals` Lean 4 Library (`leanprover/lean4:v4.35.0-rc3`, [../src/signals/Signals/HawkingRadiation.lean](../src/signals/Signals/HawkingRadiation.lean), [../src/signals/Signals/DDF.lean](../src/signals/Signals/DDF.lean), [../src/signals/Signals/Pending.lean](../src/signals/Signals/Pending.lean#L180-L235), [../src/signals/Signals/Pending.lean](../src/signals/Signals/Pending.lean#L1360-L1855), [../src/signals/SignalsPending.lean](../src/signals/SignalsPending.lean#L60-L88), [../src/signals/SignalsTests.lean](../src/signals/SignalsTests.lean#L5660-L5745), [../src/signals/SignalsPendingTests.lean](../src/signals/SignalsPendingTests.lean#L4850-L5070))
  - `Signals` LeanArchitect Blueprint ([../src/signals/blueprint/src/content.tex](../src/signals/blueprint/src/content.tex))
  - `signals-numerical-adapter` Rust/WASM Crate ([../src/signals/numerical_adapter/src/polariton_spp.rs](../src/signals/numerical_adapter/src/polariton_spp.rs#L460-L545))
  - Canonical `src/signals/docs/` Mirror: [../src/signals/docs/grassmannian-hawking-radiation-decoding-paper.md](../src/signals/docs/grassmannian-hawking-radiation-decoding-paper.md)
- **Companion `grassmannian-*-paper.md` Series:**
  1. [Huygens–Steiner Barycentric Coherence, Complex $Gr_{\mathbb{C}}(2,4)$ Plücker Channels, and Multi-Model Double-Slit & OAM Relative Predictive Error in Lean 4](grassmannian-huygens-double-slit-oam-paper.md)
  2. [Grassmannian Geometry of the Quantum Inverse Scattering Method, Algebraic Bethe Ansatz, and Inverse Scattering Metrology in Lean 4](grassmannian-qism-bethe-ansatz-paper.md)
  3. [Complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ & $N$-ary $Gr_{\mathbb{C}}(2, N+2)$ Unification with Dilatant Dark Fluid (DDF) Moving Sheaths, Plücker Sink Fluxes, Anosov Invariance, and Sorkin Triple-Slit Interferometry in Lean 4](grassmannian-ddf-moving-sheath-paper.md)
  4. [Grassmannian Gravity from QED & Gauge Scattering Amplitudes: Complex $Gr_{\mathbb{C}}(2,4)$ Orbital Precession, Mercury's Perihelion, $N$-Body Dynamics, and Dilatant Dark Fluid (DDF) Unification in Lean 4](grassmannian-gravity-from-qed-scattering-paper.md)
  5. [Normed Tensor Gaussian Splat Mechanics for Complex $Gr_{\mathbb{C}}(2,4)$ Twistors: Advantages, Limitations, WebGL2/WASM Practicality, and Unification Across Double-Slit, QISM, DDF, and Planetary Gravity in Lean 4](grassmannian-splat-mechanics-paper.md)
  6. [Inelastic Scattering and the Heat Problem in Unified Grassmannian–DDF Mechanics: Inverse Compton, Stokes/Anti-Stokes Raman, Fourier vs. Cattaneo–Vernotte, and Subluminal Second-Sound Tensor Splatting in Lean 4](grassmannian-thermal-compton-raman-paper.md)
  7. [Polaritons and Surface Plasmon Polaritons (SPPs) in Unified Grassmannian–DDF Mechanics: Hopfield–Rabi Anticrossing, Lyddane–Sachs–Teller Reststrahlen Bands, $Gr_{\mathbb{C}}(2,4)$ Evanescent Skin-Depth Duality, and Sub-Wavelength Tensor Splatting in Lean 4](grassmannian-polariton-spp-mechanics-paper.md)
  8. [The Holographic Principle in Complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ and Dilatant Dark Fluid (DDF) Mechanics: 't Hooft–Susskind Horizon Entropy, Gauss–Smarr Bulk Mass Recovery, Plücker Redshift Lapse, and Planck Tensor Splatting in Lean 4](grassmannian-holographic-principle-paper.md)
  9. [AdS/CFT Correspondence, Planar Integrability, and Secret Symmetries in Unified Complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ and Dilatant Dark Fluid (DDF) Mechanics: From Maldacena and $\mathfrak{psl}(2|2)_c$ Yangians to Plücker Outer Automorphisms and Holographic RG Tensor Splatting in Lean 4](grassmannian-ads-cft-ddf-paper.md)
  10. [Unification, Engineering Applications, and Research Roadmap of Complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ and Dilatant Dark Fluid (DDF) Mechanics: Cross-Domain Plücker Invariants, Photonic–Thermal–Quantum Systems, and Formal Verification in Lean 4](grassmannian-unification-applications-roadmap-paper.md)
  11. [Normed 2D and 3D Tensor Gaussian Splats in Lean 4: Simultaneous Conservation Laws, Holographic $Gr_{\mathbb{C}}(2,4)$ & $Gr_{\mathbb{C}}(3,6)$ Affine Projection, Inversion-Free Schur–Plücker Calculus, and Multi-Domain Applications](gaussian-splat-tensors-normed-paper.md)
  12. [Holographic $Gr_{\mathbb{C}}(2,4)$ Depth Recovery and Convergent Multi-Beam Volumetric Imaging: Plücker Axial Variance Inversion, Perspective Range Tomography, and Self-Calibrating Phase Conjugation in Lean 4](grassmannian-holographic-imaging-depth-recovery-paper.md)
  13. [3D Vectorial Wave Model for Longitudinal Polarization ($E_z$) and Higher-Rank $Gr_{\mathbb{C}}(3,n)$ Volumetric Imaging: Debye–Wolf Counter-Polarization, High-NA Dielectric Metasurfaces, ZRI Collimation vs. Thin-Film ENZ-Lignin Boundary Amplification in Lean 4](grassmannian-vectorial-longitudinal-polarization-paper.md)
  14. [Epsilon-Near-Zero (ENZ) and Hyperbolic Metamaterials in Unified Grassmannian–DDF Mechanics: `rGO-polyCBD-SS-Lignin` Nanolaminates, Argon/Ionospheric Trivelpiece–Gould Plasma, Denisov Mode Conversion, and CPA-TNSA $p\text{-}^{11}\text{B}$ / $s\text{CO}_2$ Power Ledgers in Lean 4](grassmannian-enz-hyperbolic-metamaterials-paper.md)
  15. [Holographic $405\text{ nm} / 532\text{ nm}$ Longitudinal Carbon Nanolithography, 6-Stage Linux RISC-V (`CVA6`, `CHERI-CVA6`, & `Ibex`), Volumetric KiCAD/GDSII EDA, and Exothermic Radical-Recombination Physics in Lean 4 and Rust/WASM](grassmannian-riscv-holographic-nanolithography-kicad-paper.md)
  16. [From Superfluid Gross–Pitaevskii Action and Madelung Polar Substitution to Euler–Lagrange Hydrodynamics and Dilatant Dark Fluid (DDF) Jamming Recovery in Complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ Mechanics](grassmannian-madelung-lagrangian-ddf-jamming-paper.md)

---

## Abstract

In the research corpus ([Superfluid Quantum Gravity and Hawking Radiation, lines 46–2890](#hawk-chat-sqg2026); [Review Pop III GW Remnants, lines 400–855](#hawk-chat-popiii2026); [Gravity Models: Dilatant Fluid vs. GR, lines 85–555](#hawk-chat-fluid2026)), Hawking radiation and analog-horizon signal recovery are discussed across two orthogonal theoretical axes: **(A) Without DDF vs. With DDF** (semiclassical curved-spacetime / post-Minkowskian QED-gauge double copy vs. two-component $(\phi, \varphi)$ Dilatant Dark Fluid acoustic horizons and shear-thickened fracture bursts) and **(B) Without Splats vs. With Normed Tensor Gaussian Splats** (continuum Eulerian PDEs and splat-free $Gr_{\mathbb{C}}(2,4)$ Plücker channel matrices vs. Planck-pixelated `holographicPlanckSplat`, $90^\circ$ eigenvector-snapping `rotateOrthogonal90`, and trace-preserving `isotropicTraceSwell` wavepackets).

Prior to this work, the finite decoding pipeline `HawkingRadiationDecoding` in [../src/signals/Signals/Pending.lean](../src/signals/Signals/Pending.lean) and its compile-time fixture `toyHawkingAmplituhedronMap` in [../src/signals/SignalsPendingTests.lean](../src/signals/SignalsPendingTests.lean) were isolated from the verified `Signals.DDF` and `Signals.Homodyne` modules and exhibited six concrete mathematical and structural gaps. Moreover, because flat-space post-Minkowskian QED/gauge scattering double copy (`Signals.QEDGravity`) models weak-field tree/loop scattering amplitudes rather than event-horizon Bogoliubov pair creation, we factor black-hole horizon thermodynamics, Hawking radiation, Gordon acoustic metrics, S301 pericenter stress wakes, and 2D/3D tensor-splat fracture mechanics into the dedicated module `Signals.HawkingRadiation` ([../src/signals/Signals/HawkingRadiation.lean](../src/signals/Signals/HawkingRadiation.lean)) alongside **Rust/WASM** (`polariton_spp.rs`):

1. **Four-Quadrant Formalization (`Without DDF` vs. `With DDF` $\times$ `Without Splats` vs. `With Splats` in `Signals.HawkingRadiation`)**:
   - **Quadrant I (`Without DDF, Without Splats` — `Signals.HawkingRadiation.hawking_thermodynamics_without_ddf_identities`)**: Formalizes the semiclassical Schwarzschild radius $r_S = \frac{2GM}{c^2}$, photon-sphere radius $r_{\mathrm{ph}} = \frac{3GM}{c^2} = \frac{3}{2}r_S$ and ray-vs.-wave diffraction limit (`photonSphereRayOpticsResolved`: $\lambda \le 2r_{\mathrm{ph}} = 3r_S$), surface gravity $\kappa_S = \frac{c^2}{2r_S}$, Hawking (1975) temperature $T_H = \frac{\hbar\kappa_S}{2\pi k_B c} = \frac{\hbar c^3}{8\pi G M k_B} > 0$, Bekenstein–Hawking entropy $S_{\mathrm{BH}} = \frac{k_B A_S}{4\ell_P^2}$, Gauss–Smarr mass recovery $\frac{\kappa_S A_S}{4\pi G} = M$, First-Law product $T_H S_{\mathrm{BH}} = \frac{\hbar c r_S}{4\ell_P^2} = \frac{G M \hbar}{2 c \ell_P^2}$, splat-free $Gr_{\mathbb{C}}(2,4)$ Schwarzschild redshift lapse $|w_A^{\mathbb{C}}(M_S)|^2|w_B^{\mathbb{C}}(M_S)|^2 = 1 - r_S/r > 0$, and the Sgr A* / S301 relativistic order hierarchy $0 < \beta^3 < \beta^2 < \beta < 1$ (`kerrSpinFrameDraggingOrder` vs. `schwarzschildRelativisticOrder`).
   - **Quadrant II (`Without DDF, With Splats` — `Signals.DDF` & `Signals.HawkingRadiation`)**: Formalizes 't Hooft–Susskind Planck-pixelated horizon screen tiles (`holographicPlanckSplat` with $\det\Sigma_{\mathrm{Planck}} = \ell_P^4$ and UV Bohm quantum-potential cutoff $Q_{\mathrm{core}} = \frac{\hbar^2}{2m\ell_P^2}$), Penrose's Hermitian Pauli spinor spacetime matrix $X^{AA'}(t,x,y,z)$ with $\det X^{AA'} = \frac{1}{2}(t^2 - x^2 - y^2 - z^2)$ and spinor 4-periodicity $i^2 = -1, i^4 = 1$ (`gordon_metric_quartic_gpe_and_penrose_spinor_identities`), and 2D/3D symplectic transverse-traceless gravitational-wave splats (`ttGravitationalWaveSplat`, `ttGravitationalWaveSplat3D`).
   - **Quadrant III (`With DDF, Without Splats` — `RiverExterior.hawking_radiation_ddf_and_splat_fracture_identities`, `gordon_metric_quartic_gpe_and_penrose_spinor_identities`, & `s301_pericenter_vs_aphelion_wake_identities`)**: Formalizes the DDF acoustic Hawking temperature $T_H^{\mathrm{DDF}} = \frac{\hbar\kappa_H}{2\pi k_B c} = \frac{\hbar c}{4\pi k_B r_H}$, its dispersed-phase $(\varrho_{\max}^\varphi j_{\min}^\varphi)^{-3}$ scaling, the Gordon acoustic metric $g_{00}^{\mathrm{Gordon}}(\rho_0, c, v_\phi(r))/(-\rho_0 c) = 1 - r_H/r = |w_A^{\mathbb{C}}(M_{\mathrm{holo}})|^2|w_B^{\mathbb{C}}(M_{\mathrm{holo}})|^2$, quartic GPE pressure $P_{\mathrm{GPE}} = \frac{g}{2}|\psi|^4 = \frac{g}{2}A^4$, the S301 test-star pericenter vs. aphelion stress wake (`testStarWakeStress`) and $Gr_{\mathbb{C}}(2,4)$ vis-viva ratio $\frac{r_{\max}}{r_{\min}} = \frac{1+e}{1-e} = \frac{|w_A^{\mathbb{C}}|^2}{|w_B^{\mathbb{C}}|^2} > 1$, and the continuum **hydrodynamic Inverse Gross–Pitaevskii (`iGPE`) potential reconstruction** $V_{\mathrm{ext}} = -\partial_t S - \frac{1}{2}m_\phi v_\phi^2 - g_\phi A^2 + \frac{\hbar^2}{2m_\phi}\frac{\Delta A}{A}$ (`madelungInversePotentialReconstruction`), proving that it zeroes `quantumHamiltonJacobiResidual` identically and unwinds the stationary `RiverExterior` flow to $V_{\mathrm{ext}}(r) = m_\phi\Phi_\phi(r) = -\frac{m_\phi G_\phi M}{r}$.
   - **Quadrant IV (`With DDF, With Splats` — 2D & 3D Splat Fracture, Vieta $3 \times 3$ Cubic Roots, & WGSL Quaternion Instance Matrices)**: Formalizes the two-stage quantum fracture of both 2D (`NormedTensorGaussianSplat2D`) and 3D (`NormedTensorGaussianSplat3D`) Gaussian splats ([Superfluid Quantum Gravity and Hawking Radiation, lines 710–1405](#hawk-chat-sqg2026)): **(a)** the $90^\circ$ orthogonal eigenvector snap (`rotateOrthogonal90`, `snapOrthogonalXZ`, and `rightHandedEigenvectorSwapMatrix` with $\det = +1$ vs. `unnegatedEigenvectorSwapMatrix` with $\det = -1$); **(b)** the transformation-toughening isotropic metric swell (`isotropicTraceSwell` and `isotropicTraceSwell3D`), which conserves $\operatorname{Tr}\Sigma$, expands $\det\Sigma$, and releases a strictly positive core Bohm quantum-potential burst $\Delta Q_{\mathrm{core}} > 0$ in both 2D and 3D; **(c)** Vieta's trigonometric $3 \times 3$ symmetric eigenvalue trace conservation $\lambda_1 + \lambda_2 + \lambda_3 = 3q$; and **(d)** the exact polynomial and unit-quaternion determinant laws for the WGSL Three.js `compose_instance_matrix` linear block `wgslInstanceMatrix3x3`:
     $$\det M_{\mathrm{inst}}^{(3\times 3)}(q, s) = s_x\,s_y\,s_z\,\Bigl(1 + 4\bigl(q_x^2 + q_y^2 + q_z^2\bigr)\bigl(q_x^2 + q_y^2 + q_z^2 + q_w^2 - 1\bigr)\Bigr) \underset{|q|^2=1}{=} s_x\,s_y\,s_z.$$
2. **Six Structural Critiques & Machine-Checked Fixes in `HawkingRadiationDecoding` and `toyHawkingAmplituhedronMap`**:
   We prove `ObservedHomodyneTensor.trace_im_zero`, `homodyne_pi_div_two_phase_sweep_recovers_quadrature`, `InverseGPEPoint.potential_eq_interactive_of_shared_state`, `HawkingGrassmannianSynthesisContract.madelung_and_pointwise_igpe_potential_bridge`, `finiteInverseQFT_two_hadamard`, `finiteInverseQFT_two_involution`, `HawkingRadiationDecoding.width_le_height`, `HawkingRadiationDecoding.als_observed_slice_eq_weighted_recovered`, and `HawkingGrassmannianSynthesisContract.als_rank_lt_page_bond_dimension`, and upgrade the degenerate all-zero $1 \times 1 \times 2$ test fixtures with non-zero $1 \times 2 \times 2$ connected fixtures (`toyConnectedHawkingDecoding`, `toyHawkingGrassmannianSynthesis`).

---

## 1. The Four-Quadrant Architecture: With and Without DDF $\times$ With and Without Splats

```{mermaid}
flowchart TD
    subgraph Q1["Quadrant I: Without DDF, Without Splats (Signals.HawkingRadiation)"]
        S1["Semiclassical Schwarzschild, Photon Sphere, & S301 Kerr Hierarchy\n• r_S = 2GM/c², r_ph = (3/2)r_S, κ_S = c²/(2r_S), A_S = 4π r_S²\n• Hawking Temperature T_H = ℏ κ_S / (2π k_B c) = ℏ c³ / (8π G M k_B)\n• Gauss–Smarr: κ_S A_S / (4π G) = M,  T_H S_BH = ℏ c r_S / (4 ℓ_P²)\n• S301 Order: 0 < β³ < β² < β < 1,  |w_A^C(M_S)|² |w_B^C(M_S)|² = 1 - r_S / r"]
    end

    subgraph Q2["Quadrant II: Without DDF, With Splats (Signals.DDF & Signals.HawkingRadiation)"]
        S2["Planck Horizon Screen, Penrose Pauli Spinors, & Symplectic TT Wave Splats\n• holographicPlanckSplat (σ_1 = σ_2 = ℓ_P): det Σ = ℓ_P⁴, A_H = 4ℓ_P²(S_BH/k_B)\n• UV Bohm Cutoff: Q_core(Σ_Planck) = ℏ² / (2 m ℓ_P²) > 0\n• Penrose Pauli Spinor Matrix: i⁴ = 1, det X^{AA'} = ½(t² - x² - y² - z²)\n• Symplectic TT Wave Splats (2D & 3D): det Σ_TT = σ_0⁴ (area-preserving)"]
    end

    subgraph Q3["Quadrant III: With DDF, Without Splats (Signals.HawkingRadiation & Signals.DDF)"]
        S3["DDF RiverExterior Acoustic Horizon, Gordon Metric, S301 Wake, & Continuum iGPE\n• c² = (ϱ_max^φ j_min^φ)⁻¹, r_H = 2 G_ϕ M / c², (T_H^DDF)² ∝ (ϱ_max^φ j_min^φ)⁻³\n• Gordon Metric: g_00^Gordon / (-ρ_0 c) = 1 - r_H / r = |w_A^C(M_holo)|² |w_B^C(M_holo)|²\n• Hydrodynamic iGPE Reconstruction: V_ext = -∂_t S - ½ m_ϕ v_ϕ² - g_ϕ A² + (ℏ²/2m_ϕ)(ΔA/A)\n• S301 Pericenter Wake: σ_wake(r_max) < σ_wake(r_min), r_max/r_min = |w_A^C|²/|w_B^C|² > 1"]
    end

    subgraph Q4["Quadrant IV: With DDF, With Splats (Signals.HawkingRadiation & Signals.DDF)"]
        S4["2D & 3D Splat Fracture (90° Snap & Isotropic Swell), Vieta Cubic, & WGSL Quaternions\n• ddfTensorSplat: σ_1 = σ_0 γ_φ⁻¹, σ_2 = σ_0 ⇒ det Σ_DDF = σ_0⁴(1 - β²)\n• 2D & 3D 90° Snap (rotateOrthogonal90, snapOrthogonalXZ, det S_RH = +1): preserves det Σ, Tr Σ, Q_core\n• 2D & 3D Isotropic Swell: conserves Tr Σ, expands det Σ, releases ΔQ_core > 0\n• Vieta 3×3 Trace λ_1+λ_2+λ_3 = 3q & WGSL det M_inst^(3×3) = s_x s_y s_z at |q|² = 1"]
    end

    subgraph DEC["Connected Pending Decoding & Evidence Boundary (Signals.Pending)"]
        D1["HawkingRadiationDecoding & HawkingGrassmannianSynthesisContract\n1. Dual-Quadrature Homodyne (0, π/2 LO Sweep): X(t) + i P(t)\n2. Shared-State GPE ↔ iGPE & Continuum Madelung QHJ Potential Bridge\n3. 2-Point Hadamard iQFT Involution: (√2, √2) ↦ (2, 0)\n4. Positive Grassmannian Fork [2, 3] & Rank-2 CP/ALS Reconstruction\n5. Page-Curve Bond-Dimension Gate: rank ≤ 10 < exp(S_BH / 2k_B) for S_BH/k_B > 2 ln 10"]
    end

    Q1 --> DEC
    Q2 --> DEC
    Q3 --> DEC
    Q4 --> DEC
```

### 1.1 Summary Comparison Across the Four Quadrants

| Physical / Mathematical Feature | **Quadrant I: Without DDF, Without Splats** (`Signals.HawkingRadiation`) | **Quadrant II: Without DDF, With Splats** (`Signals.DDF` & `Signals.HawkingRadiation`) | **Quadrant III: With DDF, Without Splats** (`Signals.HawkingRadiation` & `Signals.DDF`) | **Quadrant IV: With DDF, With Splats** (`Signals.HawkingRadiation` & `Signals.DDF`) |
|---|---|---|---|---|
| **Horizon Radius & Characteristic Speed** | Schwarzschild $r_S = \frac{2GM}{c^2}$, photon sphere $r_{\mathrm{ph}} = \frac{3}{2}r_S$, speed $c$ | Planck length $\ell_P = \sqrt{\frac{G\hbar}{c^3}}$, pixel area $4\ell_P^2$, Pauli $\det X^{AA'} = \frac{1}{2}s^2$ | Acoustic horizon $r_H = \frac{2G_\phi M}{c^2}$ where $\|v_\phi(r_H)\| = c = (\varrho_{\max}^\varphi j_{\min}^\varphi)^{-1/2}$ | Jammed sheath $\sigma_1 = \sigma_0\gamma_\varphi(v)^{-1}$, $\sigma_2 = \sigma_0$ (`ddfTensorSplat`) |
| **Hawking Temperature & Entropy** | $T_H = \frac{\hbar c^3}{8\pi G M k_B}$, $S_{\mathrm{BH}} = \frac{k_B A_S}{4\ell_P^2}$, $T_H S_{\mathrm{BH}} = \frac{\hbar c r_S}{4\ell_P^2}$ | $A_H = 4\ell_P^2(S_{\mathrm{BH}}/k_B)$ tiled by `holographicPlanckSplat` | $T_H^{\mathrm{DDF}} = \frac{\hbar\kappa_H}{2\pi k_B c}$, $(T_H^{\mathrm{DDF}})^2 \propto (\varrho_{\max}^\varphi j_{\min}^\varphi)^{-3}$ ([chat lines 46–85](#hawk-chat-sqg2026)) | 2D & 3D burst release $\Delta Q_{\mathrm{core}} = Q_{\mathrm{core}}(\Sigma) - Q_{\mathrm{core}}(\Sigma_{\mathrm{swell}}) > 0$ ([chat lines 146–185](#hawk-chat-sqg2026)) |
| **$Gr_{\mathbb{C}}(2,4)$ Plücker Redshift / Invariant** | $\|w_A^{\mathbb{C}}(M_S)\|^2\|w_B^{\mathbb{C}}(M_S)\|^2 = 1 - \frac{r_S}{r} > 0$, S301 $\beta^3 < \beta^2$ | $\det\Sigma_{\mathrm{Planck}} = \ell_P^4$, $\det\Sigma_{\mathrm{TT}} = \sigma_0^4$ | $\frac{g_{00}^{\mathrm{Gordon}}}{-\rho_0 c} = 1 - \frac{r_H}{r} = \|w_A^{\mathbb{C}}(M_{\mathrm{holo}})\|^2\|w_B^{\mathbb{C}}(M_{\mathrm{holo}})\|^2$ | $\det\Sigma_{\mathrm{swell}} - \det\Sigma_{\mathrm{DDF}} = \frac{\sigma_0^4 \beta^4}{4} \ge 0$, WGSL $\det M_{\mathrm{inst}}^{(3\times 3)} = s_x s_y s_z$ |
| **Medium Propagation & `iGPE` Unwinding** | Linear vacuum propagation ($g_\phi = 0, V_{\mathrm{ext}} = 0$) | Free Gaussian wavepacket dispersion | Nonlinear GP / Madelung QHJ unwinding `madelungInversePotentialReconstruction` & S301 `testStarWakeStress` | 4D Schur-complement temporal conditioning $\Sigma_{xx\|t}^{\mathrm{DDF}}(\nu) < \Sigma_{xx\|t}(\mu_0)$ ([Pop III lines 535–605](#hawk-chat-popiii2026)) |
| **Primary Lean 4 Theorem** | `hawking_thermodynamics_without_ddf_identities` | `RiverExterior.holographic_gr24_ddf_and_antiAmplituhedron_identities`, `gordon_metric_quartic_gpe_and_penrose_spinor_identities` | `RiverExterior.hawking_radiation_ddf_and_splat_fracture_identities`, `s301_pericenter_vs_aphelion_wake_identities` | `RiverExterior.hawking_radiation_ddf_and_splat_fracture_identities` |

---

## 2. Mathematical Derivations Across the Four Quadrants

### 2.1 Quadrant I (Without DDF, Without Splats): Semiclassical Hawking Temperature, Photon Sphere, S301 Kerr Hierarchy, and $Gr_{\mathbb{C}}(2,4)$ Lapse

In standard General Relativity (`Signals.HawkingRadiation` in [../src/signals/Signals/HawkingRadiation.lean](../src/signals/Signals/HawkingRadiation.lean#L50-L280)), a spherically symmetric mass $M > 0$ has Schwarzschild radius $r_S = \frac{2GM}{c^2}$ (`schwarzschildRadius`), photon-sphere radius $r_{\mathrm{ph}} = \frac{3GM}{c^2} = \frac{3}{2}r_S$ (`photonSphereRadius`, with ray-optics vs. wave-diffraction criterion `photonSphereRayOpticsResolved`: $\lambda \le 2r_{\mathrm{ph}} = 3r_S$; [Airy Beams & Microscopic Black Holes, lines 780–805](#hawk-chat-airy2026)), horizon area $A_S = 4\pi r_S^2$ (`schwarzschildHorizonArea`), and surface gravity $\kappa_S = \frac{c^2}{2r_S}$ (`schwarzschildSurfaceGravity`). By [Hawking (1975)](#hawk-hawking1975) and [Bekenstein (1973)](#hawk-bekenstein1973), quantum field fluctuations across the null horizon emit a thermal Bose/Fermi spectrum at temperature (`hawkingTemperature`):

$$
T_H = \frac{\hbar\,\kappa_S}{2\pi\,k_B\,c} = \frac{\hbar\,c^3}{8\pi\,G\,M\,k_B} > 0, \qquad
S_{\mathrm{BH}} = \frac{k_B\,A_S}{4\,\ell_P^2} = \frac{\pi\,k_B\,r_S^2}{\ell_P^2} > 0.
$$

Theorem `hawking_thermodynamics_without_ddf_identities` machine-checks the photon-sphere ratio $r_{\mathrm{ph}} = \frac{3}{2}r_S > r_S$, the inverse-mass scaling $T_H \cdot M = \frac{\hbar c^3}{8\pi G k_B}$, the Gauss–Smarr 2D boundary mass integral $\frac{\kappa_S A_S}{4\pi G} = M$, the First-Law product $T_H S_{\mathrm{BH}} = \frac{\hbar c r_S}{4\ell_P^2} = \frac{G M \hbar}{2 c \ell_P^2} = \frac{1}{2}M c^2$ (when $\ell_P^2 = G\hbar/c^3$), the Sgr A* / S301 relativistic correction order hierarchy $0 < \beta^3 < \beta^2 < \beta < 1$ (`kerrSpinFrameDraggingOrder` vs. `schwarzschildRelativisticOrder`, with $(1/12)^2 = 1/144$ and $(1/12)^3 = 1/1728$), and the splat-free $Gr_{\mathbb{C}}(2,4)$ Plücker channel product for $\beta_S(r) = \sqrt{r_S / r} \in (0, 1)$:

$$
\bigl|w_A^{\mathbb{C}}(M_S(r))\bigr|^2\,\bigl|w_B^{\mathbb{C}}(M_S(r))\bigr|^2 = \left(1 + \sqrt{\frac{r_S}{r}}\right)\left(1 - \sqrt{\frac{r_S}{r}}\right) = 1 - \frac{r_S}{r} > 0 \qquad (r > r_S).
$$

### 2.2 Quadrant III (With DDF, Without Splats): Acoustic Hawking Temperature, Gordon Metric, S301 Pericenter Wake, & Hydrodynamic `iGPE` Potential Unwinding

In the Dilatant Dark Fluid (`Signals.HawkingRadiation` in [../src/signals/Signals/HawkingRadiation.lean](../src/signals/Signals/HawkingRadiation.lean#L430-L550) and `RiverExterior` in [../src/signals/Signals/DDF.lean](../src/signals/Signals/DDF.lean)), the emergent speed of light $c = (\varrho_{\max}^\varphi j_{\min}^\varphi)^{-1/2}$ is set by the saturated jamming density $\varrho_{\max}^\varphi$ and minimum compressibility $j_{\min}^\varphi$ of the dispersed $\varphi$-phase ([Fedi 2026](#hawk-fedi2026); [Unruh 1981](#hawk-unruh1981)). Substituting $r_H = \frac{2 G_\phi M}{c^2}$ and $c^2 = (\varrho_{\max}^\varphi j_{\min}^\varphi)^{-1}$ into `RiverExterior.hawkingTemperature` proves:

$$
T_H^{\mathrm{DDF}} = \frac{\hbar\,\kappa_H}{2\pi\,k_B\,c} = \frac{\hbar\,c}{4\pi\,k_B\,r_H}, \qquad
\bigl(T_H^{\mathrm{DDF}}\bigr)^2 = \frac{\hbar^2}{64\pi^2 k_B^2 G_\phi^2 M^2 \bigl(\varrho_{\max}^\varphi j_{\min}^\varphi\bigr)^3}.
$$

Moreover, in `gordon_metric_quartic_gpe_and_penrose_spinor_identities` ([../src/signals/Signals/HawkingRadiation.lean](../src/signals/Signals/HawkingRadiation.lean#L334-L429)), the Gordon acoustic metric temporal component $g_{00}^{\mathrm{Gordon}}(\rho_0, c, v) = -\frac{\rho_0}{c}(c^2 - v^2)$ (`gordonAcousticMetricG00`; [Special Relativity: Geometry vs. Fluid, lines 790–825](#hawk-chat-penrose2026)) vanishes at the sonic horizon $v = c$ and, when normalized by $-\rho_0 c$ along the `RiverExterior` inflow $v_\phi(r) = -\sqrt{2 G_\phi M / r}$, equals the exact Painlevé–Gullstrand lapse and $Gr_{\mathbb{C}}(2,4)$ Plücker channel product:

$$
\frac{g_{00}^{\mathrm{Gordon}}\bigl(\rho_0, c, v_\phi(r)\bigr)}{-\rho_0\,c} = 1 - \frac{r_H}{r} = \bigl|w_A^{\mathbb{C}}(M_{\mathrm{holo}}(r))\bigr|^2\,\bigl|w_B^{\mathbb{C}}(M_{\mathrm{holo}}(r))\bigr|^2 > 0 \qquad (r > r_H).
$$

Furthermore, as noted in the chat corpus ([Superfluid Quantum Gravity and Hawking Radiation, lines 2730–2760](#hawk-chat-sqg2026)), acoustic excitations propagating through a Bose–Einstein condensate / superfluid experience nonlinear Gross–Pitaevskii dispersion and external potential gradients. In the Madelung polar representation $\psi = A e^{i S / \hbar}$ ($A = \sqrt{\rho} > 0, v_\phi = \nabla S / m_\phi$; [grassmannian-madelung-lagrangian-ddf-jamming-paper.md](grassmannian-madelung-lagrangian-ddf-jamming-paper.md)), the Euler–Lagrange amplitude equation is the Quantum Hamilton–Jacobi (QHJ) balance:

$$
\mathcal{R}_{\mathrm{QHJ}} = \partial_t S + \frac{1}{2}m_\phi v_\phi^2 + V_{\mathrm{ext}} + g_\phi A^2 - \frac{\hbar^2}{2 m_\phi}\frac{\Delta A}{A} = 0.
$$

Solving explicitly for $V_{\mathrm{ext}}$ defines the **hydrodynamic Inverse Gross–Pitaevskii (`iGPE`) potential reconstruction** (`madelungInversePotentialReconstruction`):

$$
V_{\mathrm{rec}}(m_\phi, \hbar, g_\phi, A, \Delta A, \partial_t S, v_\phi)
= -\partial_t S - \frac{1}{2}m_\phi v_\phi^2 - g_\phi A^2 + \frac{\hbar^2}{2 m_\phi}\frac{\Delta A}{A}.
$$

Theorem `RiverExterior.hawking_radiation_ddf_and_splat_fracture_identities` and theorem `s301_pericenter_vs_aphelion_wake_identities` prove:
1. Substituting $V_{\mathrm{ext}} = V_{\mathrm{rec}}$ into `quantumHamiltonJacobiResidual` yields $\mathcal{R}_{\mathrm{QHJ}} = 0$ identically,
2. In the stationary coarse-grained `RiverExterior` flow ($\partial_t S = 0, g_\phi = 0, \Delta A = 0, v_\phi(r) = -\sqrt{2 G_\phi M / r}$), `madelungInversePotentialReconstruction` unwinds the superfluid inflow to recover the exact Newtonian / Bernoulli gravitational potential:
   $$V_{\mathrm{rec}}\bigl(m_\phi, \hbar, 0, A, 0, 0, v_\phi(r)\bigr) = m_\phi\,\Phi_\phi(r) = -\frac{m_\phi\,G_\phi\,M}{r},$$
3. For an eccentric test star (S301 analog, $0 < e < 1$), the pericenter stress wake `testStarWakeStress` strictly exceeds the aphelion wake, and the aphelion-to-pericenter ratio equals the uncrossed $Gr_{\mathbb{C}}(2,4)$ Plücker channel ratio $\frac{r_{\max}}{r_{\min}} = \frac{1+e}{1-e} = \frac{|w_A^{\mathbb{C}}(M_{\mathbb{C}}^{\mathrm{orb}})|^2}{|w_B^{\mathbb{C}}(M_{\mathbb{C}}^{\mathrm{orb}})|^2} > 1$.

### 2.3 Quadrant IV (With DDF, With Splats): 2D & 3D $90^\circ$ Topological Snap, Transformation-Toughening Isotropic Swell, Vieta $3 \times 3$ Cubic Roots, & WGSL Quaternion Instance Matrix

In the WGSL/Three.js quantum-fracture shader proposed in [Superfluid Quantum Gravity and Hawking Radiation, lines 710–1405 and 1645–1855](#hawk-chat-sqg2026), when the local shear-stretch ratio of an anisotropic Gaussian splat (`NormedTensorGaussianSplat2D` or `NormedTensorGaussianSplat3D`) breaches the critical fracture threshold, the splat undergoes four verified algebraic laws proved in `RiverExterior.hawking_radiation_ddf_and_splat_fracture_identities` ([../src/signals/Signals/HawkingRadiation.lean](../src/signals/Signals/HawkingRadiation.lean#L747-L988)):

1. **2D & 3D $90^\circ$ Orthogonal Eigenvector Snap (`rotateOrthogonal90`, `snapOrthogonalXZ`, & `rightHandedEigenvectorSwapMatrix`)**:
   Swapping $(\sigma_1, \sigma_2) \mapsto (\sigma_2, \sigma_1)$ in 2D (`rotateOrthogonal90`) or $(\sigma_1, \sigma_2, \sigma_3) \mapsto (\sigma_3, \sigma_2, \sigma_1)$ in 3D (`snapOrthogonalXZ`) preserves $\det\Sigma, \operatorname{Tr}\Sigma$, and $Q_{\mathrm{core}}$, while negating the swapped column (`rightHandedEigenvectorSwapMatrix`, $(v_0, v_1, v_2) \mapsto (v_2, v_1, -v_0)$) preserves right-handed orientation $\det(R \cdot S_{\mathrm{RH}}) = +\det R$ (whereas omitting the negation in `unnegatedEigenvectorSwapMatrix` flips the sign $\det(R \cdot S_{\mathrm{unneg}}) = -\det R$, turning the splat inside-out).
2. **2D & 3D Transformation-Toughening Isotropic Metric Swell (`isotropicTraceSwell` & `isotropicTraceSwell3D`)**:
   Collapsing the principal variances to their arithmetic mean $\sigma_{\mathrm{swell}}^2 = \frac{\sigma_1^2 + \sigma_2^2}{2}$ in 2D or $\sigma_{\mathrm{swell,3D}}^2 = \frac{\sigma_1^2 + \sigma_2^2 + \sigma_3^2}{3}$ in 3D conserves $\operatorname{Tr}\Sigma$, expands the 2D covariance determinant by $\det\Sigma_{\mathrm{swell}} - \det\Sigma = \bigl(\frac{\sigma_1^2 - \sigma_2^2}{2}\bigr)^2 \ge 0$ (and $\frac{1}{4}\sigma_0^4\beta^4$ for `s.ddfTensorSplat`), and releases a nonnegative core Bohm quantum-potential burst in both 2D and 3D:
   $$Q_{\mathrm{core}}(\Sigma) - Q_{\mathrm{core}}(\Sigma_{\mathrm{swell}}) = \frac{\hbar^2\,\bigl(\sigma_1^2 - \sigma_2^2\bigr)^2}{4 m_\phi\,\sigma_1^2\,\sigma_2^2\,\bigl(\sigma_1^2 + \sigma_2^2\bigr)} \ge 0,$$
   $$Q_{\mathrm{core,3D}}(\Sigma_{\mathrm{3D}}) - Q_{\mathrm{core,3D}}(\Sigma_{\mathrm{swell,3D}}) = \frac{\hbar^2\,\bigl((\sigma_1^2 - \sigma_2^2)^2\sigma_3^2 + (\sigma_2^2 - \sigma_3^2)^2\sigma_1^2 + (\sigma_3^2 - \sigma_1^2)^2\sigma_2^2\bigr)}{4 m_\phi\,\sigma_1^2\,\sigma_2^2\,\sigma_3^2\,\bigl(\sigma_1^2 + \sigma_2^2 + \sigma_3^2\bigr)} \ge 0.$$
3. **Vieta $3 \times 3$ Symmetric Eigenvalue Trace & WGSL Quaternion `compose_instance_matrix` Determinant (`wgslInstanceMatrix3x3`)**:
   In the WGSL shader, `vietaEigenvalue1`, `vietaEigenvalue2`, and `vietaEigenvalue3` satisfy $\lambda_1 + \lambda_2 + \lambda_3 = 3q$ identically, and the $3 \times 3$ linear block of `compose_instance_matrix(position, q, scale)` satisfies:
   $$\det M_{\mathrm{inst}}^{(3\times 3)}(q, s) = s_x\,s_y\,s_z\,\Bigl(1 + 4\bigl(q_x^2 + q_y^2 + q_z^2\bigr)\bigl(q_x^2 + q_y^2 + q_z^2 + q_w^2 - 1\bigr)\Bigr) \underset{|q|^2=1}{=} s_x\,s_y\,s_z.$$

---

## 3. Critique, Fixes, and Stage Connections for `HawkingRadiationDecoding` and `toyHawkingAmplituhedronMap`

Our audit of `HawkingRadiationDecoding` ([../src/signals/Signals/Pending.lean](../src/signals/Signals/Pending.lean#L1360-L1895)) and `toyHawkingAmplituhedronMap` ([../src/signals/SignalsPendingTests.lean](../src/signals/SignalsPendingTests.lean#L2377-L2505)) identified six concrete gaps between the chat proposal, the Grassmannian/DDF papers, and the Lean 4 implementation. Each gap is now formally diagnosed and resolved:

| # | Audited Component | Identified Gap / Critique | Formal Resolution & New Lean 4 Declaration |
|---|---|---|---|
| **1** | `ObservedHomodyneTensor.trace` | Coerces a single real scalar `(tensor.value x y time : ℂ)` to $\mathbb{C}$, so $(\mathrm{trace}).\mathrm{im} = 0$ identically (`ObservedHomodyneTensor.trace_im_zero`). This loses the momentum quadrature $P(t)$ needed by the chat's "Hardware QFT via $\pi/2$ LO phase sweeping" ([chat lines 2588–2678](#hawk-chat-sqg2026)). | Added `ObservedQuadratureHomodyneTensor` (`inPhase` $X$ + `quadrature` $P$) and proved `homodyne_pi_div_two_phase_sweep_recovers_quadrature`, connecting `Signals.Homodyne.rotatedQuadrature` at $\theta_{\mathrm{LO}} \in \{0, \pi/2\}$ directly to $X(t) + i P(t)$. |
| **2** | `InteractiveGPEPoint` vs. `InverseGPEPoint` | Both records sat side-by-side in `HawkingRadiationDecoding`, but no field or lemma connected them or proved that `InverseGPEPoint` actually inverts `InteractiveGPEPoint` or connects to `madelungInversePotentialReconstruction`. | Proved `InverseGPEPoint.potential_eq_interactive_of_shared_state`, `HawkingGrassmannianSynthesisContract.connected_gpe_potential_recovery`, and `HawkingGrassmannianSynthesisContract.madelung_and_pointwise_igpe_potential_bridge`: $\mathrm{inv}.\mathrm{potential} = (\mathrm{inter}.\mathrm{potential} : \mathbb{C})$ ($\operatorname{Im} V = 0$) and $\mathcal{R}_{\mathrm{QHJ}}(V_{\mathrm{rec}}) = 0$. |
| **3** | `finiteInverseQFT` & `toyFiniteIQFT` | `finiteInverseQFT` uses the $-2\pi i k j / N$ phase factor, and `toyFiniteIQFT` was tested only on the zero vector `fun _ => 0`, never testing phase unscrambling or spectral peak concentration. | Proved `finiteInverseQFT_two_hadamard` and the round-trip involution `finiteInverseQFT_two_involution` ($H_2^2 = I_2$), and constructed `toyNonzeroFiniteIQFT` mapping the spread time trace $(\sqrt{2}, \sqrt{2})$ to the sharp frequency peak `![2, 0]`. |
| **4** | `HawkingRadiationDecoding` (`amplituhedron` & `als`) | `amplituhedron : AmplituhedronMap width height sampleCount` uses spatial `width, height` as Grassmannian dimensions $(k, n)$, and `iqftExternalDataLaw` broadcasts `(iqft.output column).re` identically across all rows `row : Fin height`. | Proved `HawkingRadiationDecoding.width_le_height` ($\mathrm{width} \le \mathrm{height}$ from `OrderedColumns width height` injectivity) and `HawkingRadiationDecoding.als_observed_slice_eq_weighted_recovered`: $\mathrm{als}.\mathrm{observed}\;x\;y_0\;t = \bigl(\sum_y C_{x,y}\bigr)\cdot\mathrm{recovered}(t)$. |
| **5** | `toyHawkingAmplituhedronMap` & `toyHawkingALS` | `toyHawkingAmplituhedronMap` was $1 \times 1 \times 2$ with `externalData = 0` and `image = 0`, and `toyHawkingALS` had `factorX = factorY = factorT = 0`. | Added `toyHawkingNonzeroAmplituhedronMap` ($1 \times 2 \times 2$ with positive Grassmannian fork `!![2, 3]`, Plücker minors $2, 3 > 0$, and non-zero image `!![10, 0]`), `toyHawkingNonzeroALS` (non-zero rank-2 factors `factorX = !![1, 1]`, `factorY = !![1, 1; 1, 1]`, `factorT = !![5, 5; 0, 0]`), and `toyConnectedHawkingDecoding`. |
| **6** | `ALSRank` ($2 \le r \le 10$) vs. Page-Curve Entanglement | A low ALS residual in a rank-$2..10$ simulation could be misread as general astrophysical black-hole decryption, contradicting the chat's own Page-curve scaling note ([chat lines 2526–2545](#hawk-chat-sqg2026)). | Added `HawkingGrassmannianSynthesisContract` and proved `als_rank_lt_page_bond_dimension` (and `SignalsPending.hawking_synthesis_gpe_and_page_bounds`): whenever $S_{\mathrm{BH}}/k_B > 2\ln 10 \approx 4.605$, $\mathrm{rank} \le 10 < \exp(S_{\mathrm{BH}}/(2k_B)) = \chi_{\mathrm{Page}}$. |

---

## 4. Catalog of Check Figures & Quantitative Benchmarks Across Lean 4 and Rust/WASM

| # | Quadrant / Stage | Observable / Mathematical Identity | Exact Formula / Input Parameters | Verified Check Figure | Lean 4 / Rust Verification |
|---|---|---|---|---|---|
| **1** | Quadrant I (Without DDF, Without Splats) | Schwarzschild radius & surface gravity ($G=1, M=2, c=2$) | $r_S = \frac{2GM}{c^2}$, $\kappa_S = \frac{c^2}{2r_S}$ | $r_S = 1$, $\kappa_S = 2$ | `schwarzschildRadius`, `schwarzschildSurfaceGravity` |
| **2** | Quadrant I (Without DDF, Without Splats) | Semiclassical Hawking temperature ($G=1, M=2, c=2, \hbar=1, k_B=1$) | $T_H = \frac{\hbar c^3}{8\pi G M k_B}$, $T_H \cdot M = \frac{\hbar c^3}{8\pi G k_B}$ | $T_H = \frac{1}{2\pi} \approx 0.159155$, $T_H M = \frac{1}{\pi}$ | `hawkingTemperature`, `wasm_hawking_temperature` |
| **3** | Quadrant I (Without DDF, Without Splats) | First-Law product $T_H S_{\mathrm{BH}}$ ($r_S=1, c=2, \hbar=1, \ell_P=1/2$) | $T_H S_{\mathrm{BH}} = \frac{\hbar c r_S}{4\ell_P^2}$ | $2.0$ | `hawking_thermodynamics_without_ddf_identities` |
| **4** | Quadrant I & III (Without Splats) | $Gr_{\mathbb{C}}(2,4)$ Schwarzschild / PG redshift lapse ($r_S = r_H = 1, r = 4$) | $\|w_A^{\mathbb{C}}\|^2\|w_B^{\mathbb{C}}\|^2 = 1 - \frac{r_H}{r}$ | $\frac{3}{4} = 0.75 > 0$ | `hawking_thermodynamics_without_ddf_identities` |
| **5** | Quadrant II (Without DDF, With Splats) | Planck horizon screen tile ($\ell_P = 1/2, m=1, \hbar=1$) | $\det\Sigma_{\mathrm{Planck}} = \ell_P^4$, $Q_{\mathrm{core}} = \frac{\hbar^2}{2m\ell_P^2}$ | $\det\Sigma = \frac{1}{16} = 0.0625$, $Q_{\mathrm{core}} = 2.0$ | `holographicPlanckSplat`, `planck_splat` |
| **6** | Quadrant III (With DDF, Without Splats) | Continuum `iGPE` / Madelung inverse potential on `RiverExterior` ($G_\phi=1, M=2, r=4, m_\phi=1$) | $V_{\mathrm{rec}}(m_\phi, \hbar, 0, A, 0, 0, v_\phi(4)) = -\frac{m_\phi G_\phi M}{r}$ | $-\frac{1}{2} = -0.5$ | `madelungInversePotentialReconstruction` |
| **7** | Quadrant IV (With DDF, With Splats) | $90^\circ$ orthogonal eigenvector snap ($\sigma_1 = 3, \sigma_2 = 1$) | `splat.rotateOrthogonal90`: $(\sigma_1, \sigma_2) \mapsto (1, 3)$ | $\det\Sigma_{\mathrm{rot}} = 9$, $\operatorname{Tr}\Sigma_{\mathrm{rot}} = 10$ (preserved) | `NormedTensorGaussianSplat2D.rotateOrthogonal90` |
| **8** | Quadrant IV (With DDF, With Splats) | Transformation-toughening isotropic metric swell ($\sigma_1 = 3, \sigma_2 = 1$) | $\sigma_{\mathrm{swell}}^2 = \frac{3^2+1^2}{2} = 5$, $\det\Sigma_{\mathrm{swell}} - \det\Sigma = \bigl(\frac{9-1}{2}\bigr)^2$ | $\operatorname{Tr}\Sigma_{\mathrm{swell}} = 10$, $\det\Sigma_{\mathrm{swell}} = 25 > 9$ ($\Delta\det\Sigma = +16$) | `NormedTensorGaussianSplat2D.isotropicTraceSwell` |
| **9** | Quadrant IV (With DDF, With Splats) | Core Bohm quantum-potential burst release ($\sigma_1 = 3, \sigma_2 = 1, m_\phi=1, \hbar=1$) | $Q_{\mathrm{core}}(\Sigma) - Q_{\mathrm{core}}(\Sigma_{\mathrm{swell}}) = \frac{(9-1)^2}{4(9)(1)(10)}$ | $\frac{5}{18} - \frac{1}{10} = \frac{8}{45} \approx 0.177778 > 0$ | `RiverExterior.hawking_radiation_ddf_and_splat_fracture_identities` |
| **10** | Quadrant IV (With DDF, With Splats) | DDF moving-sheath splat metric swell ($\sigma_0 = 2, \beta = 1/2 \implies \beta^2 = 1/4$) | $\det\Sigma_{\mathrm{swell}} - \det\Sigma_{\mathrm{DDF}} = \frac{\sigma_0^4 \beta^4}{4}$ | $\frac{16 \times (1/16)}{4} = \frac{1}{4} = 0.25 > 0$ | `RiverExterior.hawking_radiation_ddf_and_splat_fracture_identities` |
| **11** | Stage 1 (Homodyne Quadrature Sweep) | $\pi/2$ LO phase sweep on `Sample` ($X = 3, P = 4$) | `rotatedQuadrature s 0 = 3`, `rotatedQuadrature s (π/2) = 4` | $3 + 4i = s.\mathrm{asComplex}$ | `homodyne_pi_div_two_phase_sweep_recovers_quadrature` |
| **12** | Stage 2 (Connected Pointwise `iGPE`) | Shared-state `InteractiveGPEPoint` $\leftrightarrow$ `InverseGPEPoint` ($V=5, g=2, \rho=3, \psi=2, \Delta\psi=44$) | $V_{\mathrm{inv}} = \frac{i\hbar\psi_t + (\hbar^2/2m)\Delta\psi}{\psi} - g\rho = \frac{22}{2} - 6$ | $V_{\mathrm{inv}} = 5 + 0i = (V_{\mathrm{inter}} : \mathbb{C})$ | `InverseGPEPoint.potential_eq_interactive_of_shared_state` |
| **13** | Stage 3 (2-Point Hadamard `iQFT`) | `finiteInverseQFT 2` spectral peak concentration & involution | Input $(\sqrt{2}, \sqrt{2}) \mapsto \frac{1}{\sqrt{2}}(\sqrt{2}\pm\sqrt{2})$ | Output `![2, 0]`; second pass recovers $(\sqrt{2}, \sqrt{2})$ | `finiteInverseQFT_two_hadamard`, `finiteInverseQFT_two_involution` |
| **14** | Stage 4 (Positive Grassmannian Fork) | `toyHawkingNonzeroAmplituhedronMap` ($C = [2, 3]$, $Z = [2, 0; 2, 0]$) | $Y = C \cdot Z = [(2+3)\cdot 2, (2+3)\cdot 0]$, chart weight $10/2$ | $Y = [10, 0]$, $\Delta_{\{0\}} = 2 > 0, \Delta_{\{1\}} = 3 > 0$, weight $= 5$ | `toyHawkingNonzeroAmplituhedronMap`, `toyHawkingNonzeroLogarithmicChart` |
| **15** | Stage 5 (Rank-2 CP/ALS Decomposition) | `toyHawkingNonzeroALS` ($A=[1,1], B=[1,1;1,1], C=[5,5;0,0]$) | $\widehat{Y}_{x,y,0} = 1\cdot 1\cdot 5 + 1\cdot 1\cdot 5 = 10$, $\widehat{Y}_{x,y,1} = 0$ | Euclidean tensor residual $= 0 \le 0.1$ | `toyHawkingNonzeroALS`, `toyConnectedHawkingDecoding` |
| **16** | Stage 6 (Page Bond-Dimension Gate) | `ALSRank` ($r = 2 \le 10$) vs. $\chi_{\mathrm{Page}} = \exp(S_{\mathrm{BH}}/(2k_B))$ at $S_{\mathrm{BH}}/k_B = 10 > 2\ln 10$ | $r = 2 \le 10 < e^5 \approx 148.413$ | $2 < e^5$ (low-rank filter vs. full Page scrambling) | `HawkingGrassmannianSynthesisContract.als_rank_lt_page_bond_dimension` |
| **17** | Quadrant I (Photon Sphere & S301 Kerr Hierarchy) | Photon sphere $r_{\mathrm{ph}} = \frac{3}{2}r_S$ & S301 ($\beta = 1/12$) $\beta^3$ vs. $\beta^2$ order | $\beta^2 = (1/12)^2$, $\beta^3 = (1/12)^3$ | $r_{\mathrm{ph}} = 1.5\,r_S$, $\beta^3 = \frac{1}{1728} < \frac{1}{144} = \beta^2$ | `photonSphereRadius`, `kerrSpinFrameDraggingOrder` |
| **18** | Quadrant II & III (Gordon Metric & Penrose Pauli Spinor) | Gordon acoustic lapse $g_{00}^{\mathrm{Gordon}}/(-\rho_0 c)$, spinor $i^4=1$, & Pauli $\det X^{AA'}$ | $\det X^{AA'}(t,x,y,z)$ | $1 - r_H/r = \|w_A^{\mathbb{C}}\|^2\|w_B^{\mathbb{C}}\|^2$, $\frac{1}{2}(t^2 - x^2 - y^2 - z^2)$ | `gordon_metric_quartic_gpe_and_penrose_spinor_identities` |
| **19** | Quadrant III (S301 Pericenter Stress Wake) | Pericenter vs. aphelion wake stress & $Gr_{\mathbb{C}}(2,4)$ vis-viva ratio | $r_{\max}/r_{\min} = \frac{1+e}{1-e} = \frac{\|w_A^{\mathbb{C}}(M_{\mathbb{C}}^{\mathrm{orb}})\|^2}{\|w_B^{\mathbb{C}}(M_{\mathbb{C}}^{\mathrm{orb}})\|^2}$ | $\sigma_{\mathrm{wake}}(r_{\max}) < \sigma_{\mathrm{wake}}(r_{\min})$, $r_{\max}/r_{\min} > 1$ | `s301_pericenter_vs_aphelion_wake_identities` |
| **20** | Quadrant IV (3D Splat Fracture, Vieta Cubic, & WGSL Quaternion) | Right-handed swap $\det = +1$, 3D $\Delta Q_{\mathrm{core,3D}} \ge 0$, Vieta $\sum\lambda_i = 3q$, & WGSL $\det M_{\mathrm{inst}}^{(3\times 3)}$ | $s_x s_y s_z\bigl(1 + 4(q_x^2+q_y^2+q_z^2)(\|q\|^2-1)\bigr)$ | $\det M_{\mathrm{inst}}^{(3\times 3)} = s_x s_y s_z$ at $\|q\|^2 = 1$ | `RiverExterior.hawking_radiation_ddf_and_splat_fracture_identities` |

---

## 5. Machine-Checked Lean 4 Verification (`Signals.HawkingRadiation`, `Signals.Pending`, & `SignalsPending`)

The following self-contained Lean 4 verification block typechecks directly against `Signals`, `SignalsPending`, and `SignalsPendingTests` (`lake env lean`) and certifies all four quadrants (`Without DDF` vs. `With DDF` $\times$ `Without Splats` vs. `With Splats`), the Gordon acoustic metric, Penrose Pauli spinor determinant, S301 pericenter stress wake, 2D/3D splat fracture, Vieta $3 \times 3$ cubic trace, WGSL quaternion instance matrix determinant, and all six resolved `HawkingRadiationDecoding` and `toyHawkingNonzeroAmplituhedronMap` theorems:

```lean
import Signals
import SignalsPending
import SignalsPendingTests

namespace ArxivHawkingRadiationDecodingPaperVerification

open Signals
open Signals.Geometry
open Signals.IQ
open Signals.Homodyne
open Signals.QEDGravity
open Signals.DDF
open Signals.HawkingRadiation
open Signals.Pending
open SignalsPending
open SignalsPendingTests

noncomputable def paperDDFSub : DDFSubstrate :=
  { m_phi := 1
    m_phi_pos := by norm_num
    m_varphi := 10
    m_varphi_pos := by norm_num
    rho_phi_0 := 1
    rho_phi_0_pos := by norm_num
    rho_max_varphi := 1
    rho_max_varphi_pos := by norm_num
    j_min_varphi := 1 / 4
    j_min_varphi_pos := by norm_num }

noncomputable def paperSheath : MovingSheath paperDDFSub :=
  { velocity := 1
    velocity_nonneg := by norm_num
    subluminal := by
      have hc : paperDDFSub.c = 2 := by
        dsimp [DDFSubstrate.c, paperDDFSub]
        norm_num
      rw [hc]
      norm_num }

noncomputable def paperRiver : RiverExterior paperDDFSub :=
  { G_phi := 1
    G_phi_pos := by norm_num
    sourceMass := 2
    sourceMass_pos := by norm_num }

noncomputable def paperS301Orbit : PlanetaryOrbit :=
  { semiMajorAxis := 8
    semiMajorAxis_pos := by norm_num
    eccentricity := 4 / 5
    eccentricity_nonneg := by norm_num
    eccentricity_lt_one := by norm_num }

-- Unified verification across all 4 Quadrants (Without/With DDF x Without/With Splats),
-- Gordon acoustic metric, Penrose Pauli spinor matrix, S301 pericenter stress wake,
-- 2D/3D splat fracture, WGSL quaternion instance matrix, and connected HawkingRadiationDecoding:
example (θ q_v p_v φ_v sx sy sz t x y z : ℝ)
    (R_mat : Matrix (Fin 3) (Fin 3) ℝ) (sample : Sample) (input2 : Fin 2 → ℂ) :
    let splat_aniso : NormedTensorGaussianSplat2D :=
      { centerX := 0
        centerY := 0
        weight := 5
        weight_nonneg := by norm_num
        sigma1 := 3
        sigma1_pos := by norm_num
        sigma2 := 1
        sigma2_pos := by norm_num
        orientationAngle := θ }
    let splat3d_aniso : NormedTensorGaussianSplat3D :=
      { centerX := 0
        centerY := 0
        centerZ := 0
        weight := 5
        weight_nonneg := by norm_num
        sigma1 := 3
        sigma1_pos := by norm_num
        sigma2 := 2
        sigma2_pos := by norm_num
        sigma3 := 1
        sigma3_pos := by norm_num
        orientationAngle := θ
        pitchAngle := 0 }
    let splat_ddf := paperSheath.ddfTensorSplat 0 0 5 2 (by norm_num) (by norm_num) θ
    -- (1) Quadrant I (Without DDF, Without Splats): Semiclassical T_H, Photon Sphere, S301 β³ Hierarchy, & Gr_C(2,4) Lapse:
    0 < hawkingTemperature 1 1 1 2 2 ∧
    photonSphereRadius 1 2 2 = (3 / 2 : ℝ) * schwarzschildRadius 1 2 2 ∧
    hawkingTemperature 1 1 1 2 2 * 2 = 1 * 2 ^ 3 / (8 * Real.pi * 1 * 1) ∧
    (schwarzschildSurfaceGravity 1 2 2 * schwarzschildHorizonArea 1 2 2) /
        (4 * Real.pi * 1) = 2 ∧
    hawkingTemperature 1 1 1 2 2 * bekensteinHawkingEntropy 1 (1 / 2) 1 2 2 =
      1 * 2 * schwarzschildRadius 1 2 2 / (4 * (1 / 2) ^ 2) ∧
    kerrSpinFrameDraggingOrder (1 / 12) < schwarzschildRelativisticOrder (1 / 12) ∧
    -- (2) Gordon Acoustic Metric, Quartic |ψ|⁴ GPE Pressure, & Penrose Spinor i⁴ = 1 / Pauli det X^{AA'}:
    gordonAcousticMetricG00 2 paperDDFSub.c (paperRiver.velocity 4) / (-2 * paperDDFSub.c) =
      1 - paperRiver.horizonRadius / 4 ∧
    (Complex.I : ℂ) ^ 4 = 1 ∧
    (pauliSpacetimeSpinorMatrix t x y z).det =
      (((1 / 2 : ℝ) * (t ^ 2 - x ^ 2 - y ^ 2 - z ^ 2) : ℝ) : ℂ) ∧
    -- (3) Quadrant III (With DDF, Without Splats): Acoustic T_H^DDF, S301 Wake, & Hydrodynamic iGPE Unwinding:
    testStarWakeStress 3 1 paperS301Orbit.aphelionRadius 0 50 <
      testStarWakeStress 3 1 paperS301Orbit.perihelionRadius 0 50 ∧
    0 < paperRiver.hawkingTemperature 1 1 ∧
    (paperRiver.hawkingTemperature 1 1) ^ 2 =
      1 ^ 2 /
        (64 * Real.pi ^ 2 * 1 ^ 2 * paperRiver.G_phi ^ 2 * paperRiver.sourceMass ^ 2 *
          (paperDDFSub.rho_max_varphi * paperDDFSub.j_min_varphi) ^ 3) ∧
    madelungInversePotentialReconstruction 1 1 0 3 0 0 (paperRiver.velocity 4) =
      - (1 * paperRiver.G_phi * paperRiver.sourceMass / 4) ∧
    -- (4) Quadrant IV (With DDF, With Splats): 2D & 3D 90° Snap, Isotropic Swell, Vieta 3x3 Trace, & WGSL Quaternion Instance Matrix:
    splat_aniso.rotateOrthogonal90.covDet = splat_aniso.covDet ∧
    splat_aniso.isotropicTraceSwell.covTrace = splat_aniso.covTrace ∧
    splat_aniso.covDet < splat_aniso.isotropicTraceSwell.covDet ∧
    splat_aniso.isotropicTraceSwell.coreBohmPotential 1 1 <
      splat_aniso.coreBohmPotential 1 1 ∧
    splat_ddf.isotropicTraceSwell.covDet - splat_ddf.covDet =
      (2 ^ 4 * paperSheath.betaSq ^ 2) / 4 ∧
    splat3d_aniso.snapOrthogonalXZ.covDet = splat3d_aniso.covDet ∧
    splat3d_aniso.isotropicTraceSwell3D.covTrace = splat3d_aniso.covTrace ∧
    splat3d_aniso.isotropicTraceSwell3D.coreBohmPotential 1 1 ≤
      splat3d_aniso.coreBohmPotential 1 1 ∧
    (R_mat * rightHandedEigenvectorSwapMatrix).det = R_mat.det ∧
    (R_mat * unnegatedEigenvectorSwapMatrix).det = -R_mat.det ∧
    vietaEigenvalue1 q_v p_v φ_v + vietaEigenvalue2 q_v p_v φ_v +
      vietaEigenvalue3 q_v p_v φ_v = 3 * q_v ∧
    (wgslInstanceMatrix3x3 0 (3 / 5) 0 (4 / 5) sx sy sz).det = sx * sy * sz ∧
    -- (5) Connected HawkingRadiationDecoding, 2-Point Hadamard iQFT, & Non-Zero Amplituhedron/ALS:
    rotatedQuadrature sample 0 = sample.inPhase ∧
    rotatedQuadrature sample (Real.pi / 2) = sample.quadrature ∧
    finiteInverseQFT 2 (finiteInverseQFT 2 input2) 0 = input2 0 ∧
    toyNonzeroFiniteIQFT.output 0 = 2 ∧
    toyNonzeroFiniteIQFT.output 1 = 0 ∧
    toyHawkingNonzeroAmplituhedronMap.image 0 0 = 10 ∧
    toyConnectedHawkingDecoding.als.observed 0 toyConnectedHawkingDecoding.alsSliceY 0 =
      (∑ y : Fin 2, toyConnectedHawkingDecoding.amplituhedron.source.mat 0 y) *
        toyConnectedHawkingDecoding.inputComparison.recovered 0 ∧
    toyHawkingGrassmannianSynthesis.decoding.inverseGPE.potential =
      (toyHawkingGrassmannianSynthesis.decoding.interactiveGPE.potential : ℂ) ∧
    toyHawkingGrassmannianSynthesis.decoding.inverseGPE.potential =
      (madelungInversePotentialReconstruction 1 1 2 2 52 0 0 : ℂ) ∧
    1 ≤ 2 := by
  intro splat_aniso splat3d_aniso splat_ddf
  have hr_gt : schwarzschildRadius 1 2 2 < 4 := by
    unfold schwarzschildRadius
    norm_num
  have hr_ddf_gt : paperRiver.horizonRadius < 4 := by
    dsimp [RiverExterior.horizonRadius, paperRiver, DDFSubstrate.c, paperDDFSub]
    norm_num
  have h_q1 := hawking_thermodynamics_without_ddf_identities
    1 2 2 1 1 (1 / 2) 4 θ (1 / 12)
    (by norm_num) (by norm_num) (by norm_num)
    (by norm_num) (by norm_num) (by norm_num) hr_gt
    (by norm_num) (by norm_num)
  have h_gordon := gordon_metric_quartic_gpe_and_penrose_spinor_identities
    paperRiver 2 5 3 4 θ t x y z (by norm_num) hr_ddf_gt
  have h_s301 := s301_pericenter_vs_aphelion_wake_identities
    paperS301Orbit (by dsimp [paperS301Orbit]; norm_num) 3 1 0 50 θ
    (by norm_num) (by norm_num) (by norm_num)
  have h_q34 := paperRiver.hawking_radiation_ddf_and_splat_fracture_identities
    paperSheath splat_aniso splat3d_aniso
    1 1 (1 / 2) 1 0 3 0 0 1 4 5 2 θ q_v p_v φ_v 0 (3 / 5) 0 (4 / 5) sx sy sz R_mat
    (by norm_num) (by norm_num) (by norm_num)
    (by norm_num) (by norm_num) (by norm_num)
    (by norm_num) (by norm_num) (by norm_num)
  have h_aniso_ne : splat_aniso.sigma1 ^ 2 ≠ splat_aniso.sigma2 ^ 2 := by
    dsimp [splat_aniso]
    norm_num
  have h_quad := homodyne_pi_div_two_phase_sweep_recovers_quadrature sample
  have h_inv0 := finiteInverseQFT_two_involution input2 0
  have h_slice := toyConnectedHawkingDecoding.als_observed_slice_eq_weighted_recovered 0 0
  have h_gpe := toyHawkingGrassmannianSynthesis.connected_gpe_potential_recovery
  have h_bridge := toyHawkingGrassmannianSynthesis.madelung_and_pointwise_igpe_potential_bridge
    1 1 2 2 52 0 0 (by
      unfold madelungInversePotentialReconstruction
      norm_num [toyHawkingGrassmannianSynthesis, toyConnectedHawkingDecoding,
        toyNonzeroInteractiveGPE])
  have h_wle := toyConnectedHawkingDecoding.width_le_height
  exact ⟨h_q1.2.2.2.2.1, h_q1.2.1, h_q1.2.2.2.2.2.2.2.1,
    h_q1.2.2.2.2.2.2.2.2.1, h_q1.2.2.2.2.2.2.2.2.2.1,
    h_q1.2.2.2.2.2.2.2.2.2.2.2.2.2.2.1,
    h_gordon.2.1, h_gordon.2.2.2.2.2.1, h_gordon.2.2.2.2.2.2,
    h_s301.2.2.1, h_q34.1, h_q34.2.2.2.1, h_q34.2.2.2.2.2.2.1,
    h_q34.2.2.2.2.2.2.2.1, h_q34.2.2.2.2.2.2.2.2.2.2.1,
    h_q34.2.2.2.2.2.2.2.2.2.2.2.2.2.1 h_aniso_ne,
    h_q34.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.1 h_aniso_ne,
    h_q34.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.1,
    h_q34.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.1,
    h_q34.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.1,
    h_q34.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.1,
    h_q34.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.1,
    h_q34.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.1,
    h_q34.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.1,
    h_q34.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2,
    h_quad.1, h_quad.2.1, h_inv0, rfl, rfl, rfl,
    h_slice, h_gpe.1, h_bridge.1, h_wle⟩

end ArxivHawkingRadiationDecodingPaperVerification
```

---

### Scholarly References

(hawk-bekenstein1973)=
<a id="hawk-bekenstein1973"></a>
1. Bekenstein, J. D. (1973). *Black Holes and Entropy*. Physical Review D 7(8), 2333–2346. [DOI: 10.1103/PhysRevD.7.2333](https://doi.org/10.1103/PhysRevD.7.2333).

(hawk-hawking1975)=
<a id="hawk-hawking1975"></a>
2. Hawking, S. W. (1975). *Particle Creation by Black Holes*. Communications in Mathematical Physics 43(3), 199–220. [DOI: 10.1007/BF02345020](https://doi.org/10.1007/BF02345020).

(hawk-unruh1981)=
<a id="hawk-unruh1981"></a>
3. Unruh, W. G. (1981). *Experimental Black-Hole Evaporation?* Physical Review Letters 46(21), 1351–1353. [DOI: 10.1103/PhysRevLett.46.1351](https://doi.org/10.1103/PhysRevLett.46.1351).

(hawk-page1993)=
<a id="hawk-page1993"></a>
4. Page, D. N. (1993). *Information in Black Hole Radiation*. Physical Review Letters 71(23), 3743–3746. [DOI: 10.1103/PhysRevLett.71.3743](https://doi.org/10.1103/PhysRevLett.71.3743); [arXiv:hep-th/9306083](https://arxiv.org/abs/hep-th/9306083).

(hawk-hayden2007)=
<a id="hawk-hayden2007"></a>
5. Hayden, P., and Preskill, J. (2007). *Black holes as mirrors: quantum information in random subsystems*. Journal of High Energy Physics 2007(09), 120. [DOI: 10.1088/1126-6708/2007/09/120](https://doi.org/10.1088/1126-6708/2007/09/120); [arXiv:0708.4025](https://arxiv.org/abs/0708.4025).

(hawk-carusotto2008)=
<a id="hawk-carusotto2008"></a>
6. Carusotto, I., Fagnocchi, S., Recati, A., Balbinot, R., and Fabbri, A. (2008). *Numerical observation of Hawking radiation from acoustic black holes in atomic Bose–Einstein condensates*. New Journal of Physics 10, 103001. [DOI: 10.1088/1367-2630/10/10/103001](https://doi.org/10.1088/1367-2630/10/10/103001).

(hawk-kolda2009)=
<a id="hawk-kolda2009"></a>
7. Kolda, T. G., and Bader, B. W. (2009). *Tensor Decompositions and Applications*. SIAM Review 51(3), 455–500. [DOI: 10.1137/07070111X](https://doi.org/10.1137/07070111X).

(hawk-arkani2014)=
<a id="hawk-arkani2014"></a>
8. Arkani-Hamed, N., and Trnka, J. (2014). *The Amplituhedron*. Journal of High Energy Physics 2014(10), 030. [DOI: 10.1007/JHEP10(2014)030](https://doi.org/10.1007/JHEP10(2014)030); [arXiv:1312.2007](https://arxiv.org/abs/1312.2007).

(hawk-steinhauer2016)=
<a id="hawk-steinhauer2016"></a>
9. Steinhauer, J. (2016). *Observation of quantum Hawking radiation and its entanglement in an analogue black hole*. Nature Physics 12, 959–965. [DOI: 10.1038/nphys3863](https://doi.org/10.1038/nphys3863).

(hawk-fedi2026)=
<a id="hawk-fedi2026"></a>
10. Fedi, M. (2026). *Dilatant Dark Fluid: Toward a Unified Quantum-Hydrodynamic Origin of Lorentz Invariance, Gravity, and Cosmological Phenomenology*. SSRN Preprint 7406660.

(hawk-chat-sqg2026)=
<a id="hawk-chat-sqg2026"></a>
11. Provenance Chat Log (2026). *Superfluid Quantum Gravity and Hawking Radiation (Quantum Fracture States, Transformation Toughening, 90° Splat Snap, iGPE Unwinding, iQFT Phase Unscrambling, and Amplituhedron-Constrained CP/ALS Decoding)*. ({download}`data/chats/Superfluid-Quantum-Gravity-and-Hawking-Radiation.md, lines 46-2890 <../data/chats/Superfluid-Quantum-Gravity-and-Hawking-Radiation.md>`).

(hawk-chat-popiii2026)=
<a id="hawk-chat-popiii2026"></a>
12. Provenance Chat Log (2026). *Review Pop III GW Remnants (GPE Vortex Secondary Scattering, Kelvin-Wave Damping, and 4D Schur-Complement Temporal Slice Conditioning)*. ({download}`data/chats/Review-Pop-III-GW-Remnants.md, lines 400-855 <../data/chats/Review-Pop-III-GW-Remnants.md>`).

(hawk-chat-fluid2026)=
<a id="hawk-chat-fluid2026"></a>
13. Provenance Chat Log (2026). *Gravity Models: Dilatant Fluid vs. GR (Analog Gravity Acoustic Black Holes, Soft Hair, and Fluid/Gravity Duality)*. ({download}`data/chats/_Gravity-Models-Dilatant-Fluid-vs.-GR.md, lines 85-555 <../data/chats/_Gravity-Models-Dilatant-Fluid-vs.-GR.md>`).

(hawk-chat-penrose2026)=
<a id="hawk-chat-penrose2026"></a>
14. Provenance Chat Log (2026). *Special Relativity: Geometry vs. Fluid (Gordon Acoustic Metric, Quartic $|\psi|^4$ Self-Interaction Pressure, Spinor $i^4 = 1$ Periodicity, and Penrose Pauli Spinor Spacetime Matrix $X^{AA'}$)*. ({download}`data/chats/_Special-Relativity-Geometry-vs.-Fluid.md, lines 790-945 <../data/chats/_Special-Relativity-Geometry-vs.-Fluid.md>`).

(hawk-chat-airy2026)=
<a id="hawk-chat-airy2026"></a>
15. Provenance Chat Log (2026). *Airy Beams and Communications and Illumination (Microscopic Black Hole Photon-Sphere Ray-Optics vs. Wave-Diffraction Criterion and Holographic Broadcast)*. ({download}`data/chats/_Airy-Beams-and-Communications-and-Illumination.md, lines 780-815 <../data/chats/_Airy-Beams-and-Communications-and-Illumination.md>`).

---

### BibTeX Citations

```bibtex
@article{hawking1975particle,
  author  = {Hawking, Stephen W.},
  title   = {Particle Creation by Black Holes},
  journal = {Communications in Mathematical Physics},
  volume  = {43},
  number  = {3},
  pages   = {199--220},
  year    = {1975},
  doi     = {10.1007/BF02345020},
  url     = {https://doi.org/10.1007/BF02345020}
}

@article{unruh1981experimental,
  author  = {Unruh, William G.},
  title   = {Experimental Black-Hole Evaporation?},
  journal = {Physical Review Letters},
  volume  = {46},
  number  = {21},
  pages   = {1351--1353},
  year    = {1981},
  doi     = {10.1103/PhysRevLett.46.1351},
  url     = {https://doi.org/10.1103/PhysRevLett.46.1351}
}

@article{hayden2007black,
  author  = {Hayden, Patrick and Preskill, John},
  title   = {Black holes as mirrors: quantum information in random subsystems},
  journal = {Journal of High Energy Physics},
  volume  = {2007},
  number  = {09},
  pages   = {120},
  year    = {2007},
  doi     = {10.1088/1126-6708/2007/09/120},
  eprint  = {0708.4025},
  archivePrefix = {arXiv}
}

@article{kolda2009tensor,
  author  = {Kolda, Tamara G. and Bader, Brett W.},
  title   = {Tensor Decompositions and Applications},
  journal = {SIAM Review},
  volume  = {51},
  number  = {3},
  pages   = {455--500},
  year    = {2009},
  doi     = {10.1137/07070111X},
  url     = {https://doi.org/10.1137/07070111X}
}

@misc{chat_sqg_hawking_radiation_2026,
  author       = {{unknown}},
  title        = {Superfluid Quantum Gravity and Hawking Radiation: Quantum Fracture States, iGPE, iQFT, and Amplituhedron CP/ALS Decoding},
  year         = {2026},
  howpublished = {AI chat log},
  note         = {Source: data/chats/Superfluid-Quantum-Gravity-and-Hawking-Radiation.md, lines 46-2890},
  url          = {../data/chats/Superfluid-Quantum-Gravity-and-Hawking-Radiation.md}
}

@misc{chat_pop_iii_gw_remnants_2026,
  author       = {{unknown}},
  title        = {Review Pop III GW Remnants: GPE Vortex Scattering and 4D Schur-Complement Temporal Conditioning},
  year         = {2026},
  howpublished = {AI chat log},
  note         = {Source: data/chats/Review-Pop-III-GW-Remnants.md, lines 400-855},
  url          = {../data/chats/Review-Pop-III-GW-Remnants.md}
}

@misc{chat_special_relativity_gordon_penrose_2026,
  author       = {{unknown}},
  title        = {Special Relativity: Geometry vs. Fluid (Gordon Acoustic Metric, Quartic Self-Interaction, and Penrose Pauli Spinors)},
  year         = {2026},
  howpublished = {AI chat log},
  note         = {Source: data/chats/_Special-Relativity-Geometry-vs.-Fluid.md, lines 790-945},
  url          = {../data/chats/_Special-Relativity-Geometry-vs.-Fluid.md}
}

@misc{chat_airy_beams_photon_sphere_2026,
  author       = {{unknown}},
  title        = {Airy Beams and Communications and Illumination (Microscopic Black Hole Photon-Sphere Diffraction and Holographic Broadcast)},
  year         = {2026},
  howpublished = {AI chat log},
  note         = {Source: data/chats/_Airy-Beams-and-Communications-and-Illumination.md, lines 780-815},
  url          = {../data/chats/_Airy-Beams-and-Communications-and-Illumination.md}
}
```

### Schema.org Metadata (JSON-LD)

```json
{
  "@context": "https://schema.org",
  "@type": "ScholarlyArticle",
  "headline": "Hawking Radiation, Inverse Gross–Pitaevskii (iGPE) Unwinding, and Amplituhedron/CP-ALS Decoding in Complex Grassmannian Gr_C(2,4) and Dilatant Dark Fluid (DDF) Mechanics: With and Without DDF, With and Without Normed Tensor Gaussian Splats in Lean 4",
  "author": {
    "@type": "Person",
    "name": "Wes Turner"
  },
  "dateModified": "2026-10-30",
  "isBasedOn": [
    "data/chats/Superfluid-Quantum-Gravity-and-Hawking-Radiation.md",
    "data/chats/Review-Pop-III-GW-Remnants.md",
    "data/chats/_Gravity-Models-Dilatant-Fluid-vs.-GR.md",
    "data/chats/_Special-Relativity-Geometry-vs.-Fluid.md",
    "data/chats/_Airy-Beams-and-Communications-and-Illumination.md",
    "src/signals/Signals/HawkingRadiation.lean",
    "src/signals/Signals/DDF.lean",
    "src/signals/Signals/Pending.lean",
    "src/signals/SignalsPendingTests.lean",
    "src/signals/numerical_adapter/src/polariton_spp.rs"
  ],
  "about": [
    "Hawking Radiation",
    "Inverse Gross-Pitaevskii Equation",
    "Quantum Fourier Transform",
    "Amplituhedron",
    "CANDECOMP/PARAFAC Alternating Least Squares",
    "Complex Grassmannian Gr_C(2,4)",
    "Dilatant Dark Fluid",
    "Normed Tensor Gaussian Splats",
    "Lean 4 Formal Verification"
  ]
}
```
