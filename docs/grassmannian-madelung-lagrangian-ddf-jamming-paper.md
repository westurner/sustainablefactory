---
title: "From Superfluid Gross–Pitaevskii Action and Madelung Polar Substitution to Euler–Lagrange Hydrodynamics and Dilatant Dark Fluid (DDF) Jamming Recovery in Complex Grassmannian Gr_C(2,4) Mechanics"
description: "An arXiv-ready MyST Markdown formal verification and numerical simulation paper bridging the superfluid Gross–Pitaevskii action and Madelung polar substitution ψ = √ρ exp(iS/ℏ) to the Euler–Lagrange continuity and Quantum Hamilton–Jacobi (QHJ) equations, stationary Painlevé–Gullstrand river flow, dilatant-phase (φ) variational recovery of DDF Lorentz jamming Λ_∥(v) = γ_φ(v), action-derived Minkowski proper time, and Complex Grassmannian Gr_C(2,4) Plücker duality in Lean 4 and Rust/WASM."
---

(grassmannian-madelung-lagrangian-ddf-jamming-paper)=
# From Superfluid Gross–Pitaevskii Action and Madelung Polar Substitution to Euler–Lagrange Hydrodynamics and Dilatant Dark Fluid (DDF) Jamming Recovery in Complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ Mechanics

- **Authors:** Wes Turner
- **Subjects:**
  - Mathematical Physics (`math-ph`); Quantum Gases (`cond-mat.quant-gas`); Quantum Physics (`quant-ph`); General Relativity and Quantum Cosmology (`gr-qc`); Logic in Computer Science (`cs.LO`)
- **Formal Verification & Simulation Artifacts:**
  - `Signals` Lean 4 Library (`leanprover/lean4:v4.35.0-rc3`, [../src/signals/Signals/DDF.lean](../src/signals/Signals/DDF.lean#L7395-L7935), [../src/signals/Signals/Pending.lean](../src/signals/Signals/Pending.lean#L4839-L4932), [../src/signals/SignalsTests.lean](../src/signals/SignalsTests.lean#L1909-L1958), [../src/signals/SignalsPendingTests.lean](../src/signals/SignalsPendingTests.lean#L4815-L4853))
  - `Signals` LeanArchitect Blueprint ([../src/signals/blueprint/src/content.tex](../src/signals/blueprint/src/content.tex#L260-L315))
  - `signals-numerical-adapter` Rust/WASM Variational & Hydrodynamic Engine ([../src/signals/numerical_adapter/src/madelung_lagrangian.rs](../src/signals/numerical_adapter/src/madelung_lagrangian.rs))
  - Canonical `src/signals/docs/` Mirror: [../src/signals/docs/grassmannian-madelung-lagrangian-ddf-jamming-paper.md](../src/signals/docs/grassmannian-madelung-lagrangian-ddf-jamming-paper.md)
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
  16. [Hawking Radiation, Inverse Gross–Pitaevskii (`iGPE`) Unwinding, and Amplituhedron/CP-ALS Decoding in Complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ and Dilatant Dark Fluid (DDF) Mechanics: With and Without DDF, With and Without Normed Tensor Gaussian Splats in Lean 4](grassmannian-hawking-radiation-decoding-paper.md)

---

## Abstract

In earlier modules of `Signals.DDF`, the Madelung representation of the continuous superfluid condensate ($\phi$) was introduced at the kinematic variable level ($\rho = |\psi|^2$, $A = \sqrt{\rho}$, $S = \hbar\arg\psi$, $\mathbf{v}_\phi = \frac{\hbar}{m_\phi}\nabla\theta = \frac{1}{m_\phi}\nabla S$, and $Q = -\frac{\hbar^2}{2 m_\phi}\frac{\Delta\sqrt{\rho}}{\sqrt{\rho}}$), while the operational Minkowski interval theorem (`material_minkowski_interval`) took the clock proper-time relation $d\tau_D = dt / \gamma_\varphi(v)$ as an external hypothesis (`h_dtau`). In this paper, we upgrade the **DDF $\to$ Madelung $\to$ Lagrangian** connection from a kinematic variable decomposition to a machine-checked **variational dynamics theorem** (`MovingSheath.madelung_lagrangian_variational_and_dilatant_jamming_identities` in [../src/signals/Signals/DDF.lean](../src/signals/Signals/DDF.lean#L7395-L7935)) paired with a zero-dependency **Rust/WASM** variational and conservative finite-difference solver ([../src/signals/numerical_adapter/src/madelung_lagrangian.rs](../src/signals/numerical_adapter/src/madelung_lagrangian.rs)):

1. **Superfluid Gross–Pitaevskii Action & Exact Madelung Polar Substitution ($\psi = A e^{i S / \hbar}$)**:
   We formalize the polar complex order parameter $\psi(A, \theta) = A(\cos\theta + i\sin\theta)$ (`madelungPolarWavefunction`) and its chain-rule spatiotemporal derivative $\partial_\mu\psi = (\partial_\mu A + i A\,\partial_\mu\theta)e^{i\theta}$ (`madelungPolarDerivative`) for $\theta = S / \hbar$. Substituting these into the complex Gross–Pitaevskii / nonlinear Schrödinger (NLS) Lagrangian density $\mathcal{L}_{\mathrm{GP}}$ (`grossPitaevskiiPolarLagrangianDensity`) proves over $\mathbb{C}$ that the temporal symplectic term $-\hbar\,\operatorname{Im}(\psi^*\partial_t\psi)$ equals $-A^2\,\partial_t S = -\rho\,\partial_t S$ (canceling $\dot{A}$ identically), the spatial gradient norm squared $|\nabla\psi|^2$ splits into $(\nabla A)^2 + A^2(\nabla S / \hbar)^2$, and $\mathcal{L}_{\mathrm{GP}}$ equals both the amplitude-phase Lagrangian density $\mathcal{L}_{\mathrm{Mad}}(A, \nabla A, \partial_t S, \nabla S)$ and the hydrodynamic density-phase Lagrangian density $\mathcal{L}_{\mathrm{Mad}}^\rho(\rho, \nabla\rho, \partial_t S, \nabla S)$ for $\rho = A^2, \nabla\rho = 2 A\nabla A$.
2. **Euler–Lagrange Variations Yield Compressible Continuity, Quantum Hamilton–Jacobi (QHJ), and Stationary `RiverExterior` Gravity**:
   - Varying $\mathcal{L}_{\mathrm{Mad}}$ with respect to the action phase $S$ (with canonical momentum $\pi_S = \partial\mathcal{L}_{\mathrm{Mad}}/\partial(\partial_t S) = -\rho$ and spatial flux $J_S = \partial\mathcal{L}_{\mathrm{Mad}}/\partial(\nabla S) = -\rho v_\phi$) proves that the Euler–Lagrange phase residual $\mathcal{E}_S = -\partial_t\pi_S - \nabla\cdot J_S$ is identically the compressible continuity residual $\partial_t\rho + \nabla\cdot(\rho v_\phi) = 0$.
   - Varying $\mathcal{L}_{\mathrm{Mad}}$ with respect to the amplitude $A = \sqrt{\rho} > 0$ proves that dividing the Euler–Lagrange amplitude residual $\mathcal{E}_A = \frac{\partial\mathcal{L}_{\mathrm{Mad}}}{\partial A} - \nabla\cdot\frac{\partial\mathcal{L}_{\mathrm{Mad}}}{\partial(\nabla A)}$ by $-2A$ yields the exact **Quantum Hamilton–Jacobi (QHJ)** equation $\partial_t S + \frac{1}{2}m_\phi v_\phi^2 + V_{\mathrm{ext}} + g_\phi\rho + Q(\rho) = 0$.
   - In the stationary coarse-grained Painlevé–Gullstrand `RiverExterior` limit ($\partial_t S = 0, g_\phi = 0, \Delta A = 0, v_\phi(r) = -\sqrt{2 G_\phi M / r}, V_{\mathrm{ext}}(r) = m_\phi\Phi_\phi(r)$), the QHJ residual vanishes identically for all $r > 0$.
3. **Dilatant-Phase ($\varphi$) Coupling Uniquely Recovers DDF Jamming $\Lambda_\parallel(v) = \gamma_\varphi(v)$, Legendre Energy $H_{\mathrm{DDF}} = \gamma_\varphi(v) m c^2$, and Action-Derived Proper Time $d\tau_D = dt / \gamma_\varphi(v)$**:
   Coupling a translating vortex sheath ($v < c$) to the dispersed dilatant $\varphi$-substrate defines the sheath-compression Euler–Lagrange residual $\mathcal{R}_{\mathrm{sheath}}(\Lambda_\parallel) = \Lambda_\parallel(1 - \beta^2) - \Lambda_\parallel^{-1}$ (`MovingSheath.sheathCompressionResidual`) and convex variational excess $\Delta\mathcal{E}_{\mathrm{sheath}}(\Lambda_\parallel) = \frac{1}{2}m c^2(1 - \beta^2)(\Lambda_\parallel - \gamma_\varphi(v))^2 \ge 0$ (`MovingSheath.sheathVariationalExcess`). We prove that for $\Lambda_\parallel > 0$, $\mathcal{R}_{\mathrm{sheath}}(\Lambda_\parallel) = 0 \iff \Lambda_\parallel = \gamma_\varphi(v) = (1 - v^2/c^2)^{-1/2}$. Evaluating the worldline dilatant Lagrangian $L_{\mathrm{DDF}}(v) = -m c^2 / \gamma_\varphi(v)$ proves that:
   - the Legendre transform $H_{\mathrm{DDF}}(v) = v\,p_{\mathrm{DDF}}(v) - L_{\mathrm{DDF}}(v)$ recovers $H_{\mathrm{DDF}}(v) = \gamma_\varphi(v)m c^2 = m c^2 + K_D(v)$ and the relativistic mass shell $H_{\mathrm{DDF}}^2 - c^2 p_{\mathrm{DDF}}^2 = m^2 c^4$, and
   - the normalized action increment $d\tau_D = \bigl(-L_{\mathrm{DDF}}(v)/(m c^2)\bigr)dt = dt / \gamma_\varphi(v)$ (`MovingSheath.actionProperTime`) **derives** the proper-time law from the Lagrangian and satisfies $c^2 d\tau_D^2 = c^2 dt^2 - (v\,dt)^2$ unconditionally!
4. **Complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ Plücker Duality & Strain-Thickened Bogoliubov Dispersion**:
   We prove that the squared normalized dilatant Lagrangian equals the uncrossed $Gr_{\mathbb{C}}(2,4)$ Plücker channel product and the normalized `NormedTensorGaussianSplat2D` covariance determinant:
   $$\left(\frac{L_{\mathrm{DDF}}(v)}{-m c^2}\right)^2 = \bigl|w_A^{\mathbb{C}}(M_{\mathrm{sheath}})\bigr|^2\,\bigl|w_B^{\mathbb{C}}(M_{\mathrm{sheath}})\bigr|^2 = \frac{\det\Sigma_{\mathrm{DDF}}}{\sigma_0^4} = \frac{1}{\gamma_\varphi(v)^2} = 1 - \frac{v^2}{c^2},$$
   and that strain-thickened dilatant coupling $g_{\mathrm{DDF}}(k) = g_0(1 + \gamma_{\mathrm{dil}} k^2)$ strictly accelerates high-wavenumber Bogoliubov quasiparticles ($v_{p,\mathrm{DDF}}^2(k) > v_p^2(k)$ for $k, \gamma_{\mathrm{dil}} > 0$).

---

## 1. Architecture of the Variational Bridge: From Superfluid Action to DDF Jamming & $Gr_{\mathbb{C}}(2,4)$

```{mermaid}
flowchart TD
    subgraph GP["1. Superfluid Gross–Pitaevskii (NLS) Action (ϕ-Condensate)"]
        LGP["Complex GP Lagrangian Density L_GP(ψ, ∂_t ψ, ∇ψ)\nL_GP = -ℏ Im(ψ* ∂_t ψ) - (ℏ²/2m_ϕ)|∇ψ|² - V_ext|ψ|² - (g_ϕ/2)|ψ|⁴"]
        Polar["Madelung Polar Substitution ψ = A exp(iS/ℏ), A = √ρ > 0\n• |ψ|² = A² = ρ\n• -ℏ Im(ψ* ∂_t ψ) = -A² ∂_t S = -ρ ∂_t S (A_dot cancels!)\n• |∇ψ|² = (∇A)² + A²(∇S/ℏ)²"]
        LMad["Real Hydrodynamic Lagrangian Density L_Mad(ρ, ∇ρ, ∂_t S, ∇S)\nL_Mad = -ρ(∂_t S + |∇S|²/(2m_ϕ) + V_ext + ½ g_ϕ ρ) - (ℏ²/8m_ϕ)|∇ρ|²/ρ"]
    end

    subgraph EL["2. Euler–Lagrange Variational Equations"]
        ELS["Phase Variation δS / δS = 0 (U(1) Noether Current)\nπ_S = ∂L/∂(∂_t S) = -ρ,  J_S = ∂L/∂(∇S) = -ρ v_ϕ\n⇒ E_S = ∂_t ρ + ∇·(ρ v_ϕ) = 0 (Continuity Equation)"]
        ELA["Amplitude Variation δS / δA = 0 (Divided by -2A)\n⇒ ∂_t S + ½ m_ϕ v_ϕ² + V_ext + g_ϕ ρ + Q(ρ) = 0\nwhere Q(ρ) = -(ℏ²/2m_ϕ)(Δ√ρ / √ρ) (Quantum Hamilton–Jacobi)"]
        River["Stationary Coarse-Grained RiverExterior Limit\n∂_t S = 0, g_ϕ = 0, Q → 0, v_ϕ = -√(2 G_ϕ M / r)\n⇒ ½ v_ϕ(r)² + Φ_ϕ(r) = 0 ⇔ Φ_ϕ(r) = -G_ϕ M / r"]
    end

    subgraph DDF["3. Dilatant-Phase (φ) Coupling & Gr_C(2,4) Plücker Unification"]
        Sheath["Sheath Compression Variational Principle (v < c)\nR_sheath(Λ_∥) = Λ_∥(1 - β²) - 1/Λ_∥ = 0,  ΔE_sheath(Λ_∥) ≥ 0\n⇒ Unique Stationary Minimum Λ_∥ = γ_φ(v) = (1 - v²/c²)^(-1/2)"]
        Worldline["Worldline Dilatant Action & Legendre Transform\nL_DDF(v) = -m c² / γ_φ(v),  p_DDF = γ_φ m v\n• H_DDF = v p_DDF - L_DDF = γ_φ m c² = m c² + K_D(v)\n• H_DDF² - c² p_DDF² = m² c⁴\n• Action Proper Time dτ_D = (-L_DDF/mc²)dt = dt/γ_φ ⇒ c²dτ_D² = c²dt² - v²dt²"]
        Gr24["Complex Grassmannian Gr_C(2,4) & Tensor Splat Identity\n(L_DDF / -mc²)² = |w_A^C(M_sheath)|² |w_B^C(M_sheath)|² = det Σ_DDF / σ_0⁴ = 1 - β²"]
    end

    LGP --> Polar --> LMad
    LMad --> ELS
    LMad --> ELA --> River
    ELA --> Sheath --> Worldline --> Gr24
```

### 1.1 Resolving Two Foundational Questions from the Research Corpus

In our review of the repository's Grassmannian and DDF papers ([Grassmannian Splat Mechanics and Vortex Space Emergence, lines 89–195](#mad-chat-splat2026); [Review Pop III GW Remnants, lines 621–660](#mad-chat-gw2026)), two structural questions emerged regarding the relationship between `Signals.DDF`, Madelung hydrodynamics, and Lagrangian field theory:

1. **From Kinematic Decomposition to Variational Dynamics**:
   Prior to this work, `Signals.DDF` defined the Madelung density $\rho(\mathbf{x}) = |\psi(\mathbf{x})|^2$ (`madelungDensity`), amplitude $\sqrt{\rho(\mathbf{x})}$ (`madelungAmplitude`), phase $S(\mathbf{x}) = \arg\psi(\mathbf{x})$ (`madelungPhase`), superfluid velocity $\mathbf{v}(\mathbf{x}) = \frac{\hbar}{m}\nabla S(\mathbf{x})$ (`superfluidVelocity`), and Bohm quantum potential $Q(\mathbf{x}) = -\frac{\hbar^2}{2m}\frac{\Delta\sqrt{\rho}}{\sqrt{\rho}}$ (`bohmQuantumPotential`), and used "Lagrangian" in the particle/wavepacket sense (`NormedTensorGaussianSplat2D`) rather than as an action functional $\mathcal{S}[\psi, \psi^*] = \int \mathcal{L}_{\mathrm{GP}}\,dt\,d^3x$.
2. **Discharging the Proper-Time Hypothesis `h_dtau` in `material_minkowski_interval`**:
   In [src/signals/Signals/DDF.lean](../src/signals/Signals/DDF.lean#L160-L185), the docstring of `material_minkowski_interval` referred to *"action-derived clock proper time $d\tau_D = dt / \gamma_\varphi(v)$"*, but the theorem signature previously accepted `h_dtau : dtau = dt / s.jammingFactor` as an explicit hypothesis rather than deriving $d\tau_D$ from a worldline Lagrangian $L_{\mathrm{DDF}}(v)$.

Sections 2–4 below show how `Signals.DDF` and `madelung_lagrangian.rs` close both gaps completely.

---

## 2. Superfluid Gross–Pitaevskii Action, Madelung Polar Substitution, and Euler–Lagrange Hydrodynamics

### 2.1 Exact Polar Substitution in the Gross–Pitaevskii Lagrangian Density

For a continuous bosonic superfluid condensate $\psi(\mathbf{x}, t) \in \mathbb{C}$ of boson mass $m_\phi > 0$ in an external potential $V_{\mathrm{ext}}$ with contact self-interaction coupling $g_\phi$, the Gross–Pitaevskii (nonlinear Schrödinger) Lagrangian density is ([Madelung 1927](#mad-madelung1927); [Gross 1961](#mad-gross1961); [Pitaevskii 1961](#mad-pitaevskii1961)):

$$
\mathcal{L}_{\mathrm{GP}}(\psi, \partial_t\psi, \nabla\psi)
= \frac{i\hbar}{2}\bigl(\psi^*\partial_t\psi - \psi\partial_t\psi^*\bigr)
  - \frac{\hbar^2}{2 m_\phi}|\nabla\psi|^2
  - V_{\mathrm{ext}}|\psi|^2
  - \frac{g_\phi}{2}|\psi|^4.
$$

Because $\psi^*\partial_t\psi - \psi\partial_t\psi^* = 2 i\,\operatorname{Im}(\psi^*\partial_t\psi)$, the temporal symplectic term is real-valued and equals (`grossPitaevskiiTemporalSymplecticTerm`):

$$
\frac{i\hbar}{2}\bigl(\psi^*\partial_t\psi - \psi\partial_t\psi^*\bigr) = -\hbar\,\operatorname{Im}(\psi^*\partial_t\psi).
$$

Substituting the polar representation $\psi(A, \theta) = A(\cos\theta + i\sin\theta) = A e^{i\theta}$ (`madelungPolarWavefunction`) with real square-root amplitude $A = \sqrt{\rho} > 0$, phase angle $\theta = S / \hbar$, and chain-rule derivative (`madelungPolarDerivative`):

$$
\partial_\mu\psi = (\partial_\mu A + i A\,\partial_\mu\theta)e^{i\theta}
= (\partial_\mu A\cos\theta - A\,\partial_\mu\theta\sin\theta) + i(\partial_\mu A\sin\theta + A\,\partial_\mu\theta\cos\theta),
$$

Theorem `MovingSheath.madelung_lagrangian_variational_and_dilatant_jamming_identities` ([src/signals/Signals/DDF.lean](../src/signals/Signals/DDF.lean#L7708-L7806)) proves four exact algebraic identities over $\mathbb{C}$:
1. **Amplitude Normalization**: $|\psi|^2 = \operatorname{Complex.normSq}(\psi) = A^2(\cos^2\theta + \sin^2\theta) = A^2 = \rho$.
2. **Exact Cancellation of $\dot{A}$ in the Symplectic Time Term**:
   $$-\hbar\,\operatorname{Im}(\psi^*\partial_t\psi) = -\hbar A^2 \dot{\theta}(\cos^2\theta + \sin^2\theta) = -A^2\,\partial_t S = -\rho\,\partial_t S.$$
3. **Orthogonal Decomposition of the Spatial Gradient Norm Squared**:
   $$|\nabla\psi|^2 = (\nabla A)^2 + A^2\left(\frac{\nabla S}{\hbar}\right)^2.$$
4. **Equivalence of Complex GP, Amplitude-Phase, and Hydrodynamic Density-Phase Lagrangians**:
   $$\mathcal{L}_{\mathrm{GP}}(\psi, \partial_t\psi, \nabla\psi)
   = \underbrace{-A^2\left(\partial_t S + \frac{(\nabla S)^2}{2 m_\phi} + V_{\mathrm{ext}}\right) - \frac{g_\phi}{2}A^4 - \frac{\hbar^2}{2 m_\phi}(\nabla A)^2}_{\mathcal{L}_{\mathrm{Mad}}(A, \nabla A, \partial_t S, \nabla S)}
   = \underbrace{-\rho\left(\partial_t S + \frac{(\nabla S)^2}{2 m_\phi} + V_{\mathrm{ext}} + \frac{g_\phi}{2}\rho\right) - \frac{\hbar^2}{8 m_\phi}\frac{(\nabla\rho)^2}{\rho}}_{\mathcal{L}_{\mathrm{Mad}}^\rho(\rho, \nabla\rho, \partial_t S, \nabla S)}$$
   for $\rho = A^2 > 0$ and $\nabla\rho = 2 A\nabla A$, where the last term is the Fisher-information / von Weizsäcker quantum gradient density.

### 2.2 Euler–Lagrange Variations: Compressible Continuity & Quantum Hamilton–Jacobi (QHJ) Equations

Treating $S$ and $A = \sqrt{\rho}$ as the independent real fields in the action $\mathcal{S}[A, S] = \int \mathcal{L}_{\mathrm{Mad}}(A, \nabla A, \partial_t S, \nabla S)\,dt\,d^3x$:

| Variational Field | Canonical Conjugate Momenta & Fluxes | Euler–Lagrange Equation | Physical Meaning & Lean 4 Declaration |
|---|---|---|---|
| **Phase $S$**<br>($U(1)$ shift invariance $\partial\mathcal{L}_{\mathrm{Mad}}/\partial S = 0$) | $\pi_S = \frac{\partial\mathcal{L}_{\mathrm{Mad}}}{\partial(\partial_t S)} = -\rho$,<br>$\mathbf{J}_S = \frac{\partial\mathcal{L}_{\mathrm{Mad}}}{\partial(\nabla S)} = -\rho\frac{\nabla S}{m_\phi} = -\rho\mathbf{v}_\phi$ | $\mathcal{E}_S = -\partial_t\pi_S - \nabla\cdot\mathbf{J}_S = \partial_t\rho + \nabla\cdot(\rho\mathbf{v}_\phi) = 0$ | **Compressible Continuity Equation** (`madelungPhaseEulerLagrangeResidual`, `madelungContinuityResidual`) |
| **Amplitude $A = \sqrt{\rho} > 0$**<br>($\partial\mathcal{L}_{\mathrm{Mad}}/\partial\dot{A} = 0$) | $\frac{\partial\mathcal{L}_{\mathrm{Mad}}}{\partial A} = -2A\bigl(\partial_t S + \frac{|\nabla S|^2}{2m_\phi} + V_{\mathrm{ext}} + g_\phi A^2\bigr)$,<br>$\nabla\cdot\frac{\partial\mathcal{L}_{\mathrm{Mad}}}{\partial(\nabla A)} = -\frac{\hbar^2}{m_\phi}\Delta A$ | $\frac{\mathcal{E}_A}{-2A} = \partial_t S + \frac{1}{2}m_\phi v_\phi^2 + V_{\mathrm{ext}} + g_\phi\rho - \frac{\hbar^2}{2m_\phi}\frac{\Delta A}{A} = 0$ | **Quantum Hamilton–Jacobi (QHJ) Equation** with Bohm potential $Q(\rho) = -\frac{\hbar^2}{2m_\phi}\frac{\Delta\sqrt{\rho}}{\sqrt{\rho}}$ (`madelungAmplitudeEulerLagrangeResidual`, `quantumHamiltonJacobiResidual`) |
| **Stationary `RiverExterior` Limit**<br>($\partial_t S = 0, g_\phi = 0, \Delta A = 0$) | $v_\phi(r) = -\sqrt{\frac{2 G_\phi M}{r}}$,<br>$V_{\mathrm{ext}}(r) = m_\phi\Phi_\phi(r) = -\frac{m_\phi G_\phi M}{r}$ | $\mathcal{R}_{\mathrm{QHJ}} = \frac{1}{2}m_\phi\left(\frac{2 G_\phi M}{r}\right) - \frac{m_\phi G_\phi M}{r} = 0$ | **Painlevé–Gullstrand River Bernoulli Balance** (`RiverExterior.bernoulli_potential_eq`) |

### 2.3 Field Legendre Transform ($\mathcal{H}_{\mathrm{Mad}} \ge 0$) & Gradient Bridge to the Compressible Madelung–Euler Momentum Equation

A natural critique of the real hydrodynamic Lagrangian density $\mathcal{L}_{\mathrm{Mad}}$ in Section 2.1 is: *why do the kinetic, external-potential, self-interaction, and quantum-gradient terms all appear with minus signs in $\mathcal{L}_{\mathrm{Mad}}$?* Theorem `madelung_hamiltonian_euler_ads_and_nanolithography_bridge_identities` ([src/signals/Signals/DDF.lean](../src/signals/Signals/DDF.lean#L8008-L8145)) resolves this by proving the canonical field Legendre transformation with respect to $\partial_t S$:

1. **Positive-Definite Field Legendre Hamiltonian Density (`madelungAmplitudeHamiltonianDensity`, `madelungHydrodynamicHamiltonianDensity`)**:
   Because $\pi_S = \frac{\partial\mathcal{L}_{\mathrm{Mad}}}{\partial(\partial_t S)} = -\rho = -A^2$, the canonical Hamilton–Jacobi decomposition $\mathcal{L}_{\mathrm{Mad}} = \pi_S\,\partial_t S - \mathcal{H}_{\mathrm{Mad}}$ yields the strictly nonnegative energy density:
   $$\mathcal{H}_{\mathrm{Mad}} = \pi_S\,\partial_t S - \mathcal{L}_{\mathrm{Mad}} = A^2\left(\frac{(\nabla S)^2}{2 m_\phi} + V_{\mathrm{ext}}\right) + \frac{g_\phi}{2}A^4 + \frac{\hbar^2}{2 m_\phi}(\nabla A)^2 = \frac{1}{2}m_\phi\rho v_\phi^2 + V_{\mathrm{ext}}\rho + \frac{g_\phi}{2}\rho^2 + \frac{\hbar^2}{8 m_\phi}\frac{(\nabla\rho)^2}{\rho} \ge 0$$
   whenever $m_\phi > 0, V_{\mathrm{ext}} \ge 0, g_\phi \ge 0$.
2. **Spatial Gradient Bridge from QHJ to the Compressible Madelung–Euler Momentum Equation (`madelungEulerMomentumResidual`)**:
   For irrotational flow $v_\phi = \nabla S / m_\phi$ with mixed-partial symmetry $\nabla(\partial_t S) = m_\phi\partial_t v_\phi$ and convective identity $\nabla\bigl(\frac{1}{2}m_\phi v_\phi^2\bigr) = m_\phi v_\phi\nabla v_\phi$, dividing the spatial gradient of the QHJ equation by $m_\phi > 0$ yields the exact compressible Madelung–Euler momentum residual:
   $$\frac{(m_\phi\partial_t v_\phi) + (m_\phi v_\phi\nabla v_\phi) + \nabla V_{\mathrm{ext}} + g_\phi\nabla\rho + \nabla Q(\rho)}{m_\phi} = \partial_t v_\phi + v_\phi\nabla v_\phi + \frac{\nabla V_{\mathrm{ext}} + g_\phi\nabla\rho + \nabla Q(\rho)}{m_\phi} = \mathcal{R}_{\mathrm{Euler}}.$$

---

## 3. Dilatant-Phase ($\varphi$) Coupling: Variational Recovery of DDF Jamming $\Lambda_\parallel(v) = \gamma_\varphi(v)$ and Action-Derived Proper Time

### 3.1 Variational Derivation of Longitudinal Sheath Compression $\Lambda_\parallel(v) = \gamma_\varphi(v)$

In Marco Fedi's Dilatant Dark Fluid framework ([Fedi 2026](#mad-fedi2026); [src/signals/Signals/DDF.lean](../src/signals/Signals/DDF.lean#L49-L185)), the continuous $\phi$-superfluid coexists with a heavier dispersed dilatant phase ($\varphi$) of saturated jamming density $\varrho_{\max}^\varphi > 0$ and minimum compressibility $j_{\min}^\varphi > 0$, supporting transverse phonons at the emergent speed of light $c = (\varrho_{\max}^\varphi j_{\min}^\varphi)^{-1/2}$ (`DDFSubstrate.c`).

When a massive vortex-core defect of rest mass $m > 0$ translates at subluminal velocity $v < c$ ($\beta = v/c \in [0, 1)$, $\beta^2 = v^2/c^2 < 1$) through the $\varphi$-substrate, the comoving acoustic wave operator acquires the anisotropic convective factor $1 - v^2/c^2 = 1 - \beta^2 > 0$ along the motion axis. Balancing longitudinal elastic compression of the sheath scale $\Lambda_\parallel > 0$ against the dilatant log-strain restoring potential defines the sheath-compression variational functional:

$$
\mathcal{W}_{\mathrm{sheath}}(\Lambda_\parallel; v) = \frac{1}{2}m c^2\bigl[\Lambda_\parallel^2(1 - \beta^2) - 2\ln\Lambda_\parallel - 1\bigr],
$$

whose Euler–Lagrange stationary residual with respect to $\Lambda_\parallel$ (normalized by $m c^2$) is (`MovingSheath.sheathCompressionResidual` in [src/signals/Signals/DDF.lean](../src/signals/Signals/DDF.lean#L7611-L7618)):

$$
\mathcal{R}_{\mathrm{sheath}}(\Lambda_\parallel) = \frac{1}{m c^2}\frac{\partial\mathcal{W}_{\mathrm{sheath}}}{\partial\Lambda_\parallel} = \Lambda_\parallel(1 - \beta^2) - \frac{1}{\Lambda_\parallel},
$$

with quadratic convex variational excess (`MovingSheath.sheathVariationalExcess`):

$$
\Delta\mathcal{E}_{\mathrm{sheath}}(\Lambda_\parallel) = \frac{1}{2}m c^2(1 - \beta^2)\bigl(\Lambda_\parallel - \gamma_\varphi(v)\bigr)^2 \ge 0.
$$

In `MovingSheath.madelung_lagrangian_variational_and_dilatant_jamming_identities`, we prove:
1. **Stationary Point & Global Minimum at $\Lambda_\parallel = \gamma_\varphi(v)$**:
   $$\mathcal{R}_{\mathrm{sheath}}\bigl(\gamma_\varphi(v)\bigr) = 0 \quad\text{and}\quad \Delta\mathcal{E}_{\mathrm{sheath}}\bigl(\gamma_\varphi(v)\bigr) = 0.$$
2. **Uniqueness of the Variational Jamming Solution for $\Lambda_\parallel > 0$**:
   $$\mathcal{R}_{\mathrm{sheath}}(\Lambda_\parallel) = 0 \iff \Lambda_\parallel^2(1 - \beta^2) = 1 \iff \Lambda_\parallel = \gamma_\varphi(v) = \frac{1}{\sqrt{1 - v^2/c^2}},$$
   recovering `profile_closure_jamming_factor` directly as the unique Euler–Lagrange stationary point of the dilatant sheath coupling.

### 3.2 Worldline Dilatant Action, Legendre Transform to $H_{\mathrm{DDF}} = \gamma_\varphi(v) m c^2$, and Unconditional Minkowski Proper Time

Evaluating the translating vortex-sheath worldline action at its stationary jamming factor $\Lambda_\parallel = \gamma_\varphi(v)$ yields the relativistic Born–Infeld / dilatant worldline Lagrangian (`MovingSheath.dilatantLagrangian`):

$$
L_{\mathrm{DDF}}(v) = -\frac{m c^2}{\gamma_\varphi(v)} = -m c^2\sqrt{1 - \frac{v^2}{c^2}}.
$$

From $L_{\mathrm{DDF}}(v)$, `MovingSheath.madelung_lagrangian_variational_and_dilatant_jamming_identities` machine-checks the complete relativistic mechanics and proper-time chain:

1. **Canonical Momentum (`MovingSheath.dilatantCanonicalMomentum`)**:
   $$p_{\mathrm{DDF}}(v) = \frac{\partial L_{\mathrm{DDF}}}{\partial v} = \gamma_\varphi(v)\,m\,v.$$
2. **Legendre Transform Recovers Total Material Energy & Reversible Kinetic Energy (`MovingSheath.dilatantHamiltonian`)**:
   $$H_{\mathrm{DDF}}(v) = v\,p_{\mathrm{DDF}}(v) - L_{\mathrm{DDF}}(v) = \gamma_\varphi(v) m v^2 + \frac{m c^2}{\gamma_\varphi(v)} = \gamma_\varphi(v)\,m c^2 = m c^2 + K_D(v),$$
   where $K_D(v) = m c^2(\gamma_\varphi(v) - 1)$ is `MovingSheath.kineticEnergy`.
3. **Relativistic Mass-Shell Dispersion Invariant**:
   $$H_{\mathrm{DDF}}(v)^2 - c^2\,p_{\mathrm{DDF}}(v)^2 = \bigl(\gamma_\varphi(v) m c^2\bigr)^2 - c^2\bigl(\gamma_\varphi(v) m v\bigr)^2 = (m c^2)^2.$$
4. **Action-Derived Clock Proper Time & Unconditional Minkowski Interval (`MovingSheath.actionProperTime`)**:
   Defining the clock proper-time increment directly from the normalized worldline action increment $-dS_{\mathrm{DDF}}/(m c^2)$:
   $$d\tau_D = s.\mathrm{actionProperTime}(m, dt) = \left(\frac{-L_{\mathrm{DDF}}(v)}{m c^2}\right)dt = \frac{dt}{\gamma_\varphi(v)}$$
   proves **unconditionally** (without any external `h_dtau` assumption) that:
   $$c^2\,\bigl(s.\mathrm{actionProperTime}(m, dt)\bigr)^2 = c^2\,dt^2 - (v\,dt)^2.$$

### 3.3 Four-Way Equivalence with Complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ Plücker Channels & Tensor Splats

Embedding the moving sheath into $Gr_{\mathbb{C}}(2,4)$ via $M_{\mathrm{sheath}} = s.\mathrm{gr24TwistorMatrix}(d, \lambda, L, \Delta\ell, \phi, x)$ and into the normed anisotropic Gaussian splat family via $\mathrm{splat}_{\mathrm{DDF}} = s.\mathrm{ddfTensorSplat}(c_x, c_y, w, \sigma_0, h_w, h_{\sigma_0}, \theta)$ establishes the exact four-way identity:

$$
\left(\frac{L_{\mathrm{DDF}}(v)}{-m c^2}\right)^2
= \bigl|w_A^{\mathbb{C}}(M_{\mathrm{sheath}})\bigr|^2\,\bigl|w_B^{\mathbb{C}}(M_{\mathrm{sheath}})\bigr|^2
= \frac{\det\Sigma_{\mathrm{DDF}}}{\sigma_0^4}
= \frac{1}{\gamma_\varphi(v)^2}
= 1 - \frac{v^2}{c^2}.
$$

### 3.4 Cross-Domain Bridge to $\text{AdS}_5/\text{CFT}_4$ Black-Brane Emblackening, $405\text{ nm}/532\text{ nm}$ STED Nanolithography, and `kicad-volumetric` DRC

Theorem `madelung_hamiltonian_euler_ads_and_nanolithography_bridge_identities` ([src/signals/Signals/DDF.lean](../src/signals/Signals/DDF.lean#L8008-L8145)) connects the Madelung variational formalism directly to the companion AdS/CFT ([grassmannian-ads-cft-ddf-paper.md](grassmannian-ads-cft-ddf-paper.md)) and holographic RISC-V carbon nanolithography ([grassmannian-riscv-holographic-nanolithography-kicad-paper.md](grassmannian-riscv-holographic-nanolithography-kicad-paper.md)) papers:

1. **$\text{AdS}_5$ Planar Black-Brane Emblackening vs. DDF Worldline Lagrangian Square**:
   Evaluating $M_{\text{AdS}_5} = \operatorname{ddfThermalGr24Matrix}\bigl((z/z_H)^2, \theta\bigr)$ for $0 < z < z_H$ proves that the uncrossed $Gr_{\mathbb{C}}(2,4)$ Plücker channel product equals the $\text{AdS}_5$ black-brane emblackening factor:
   $$\bigl|w_A^{\mathbb{C}}(M_{\text{AdS}_5})\bigr|^2\,\bigl|w_B^{\mathbb{C}}(M_{\text{AdS}_5})\bigr|^2 = 1 - \left(\frac{z}{z_H}\right)^4 = \operatorname{adsPlanarBlackBraneEmblackening}(z, z_H, 4) > 0,$$
   matching the squared normalized worldline Lagrangian $\bigl(L_{\mathrm{DDF}}/(-mc^2)\bigr)^2 = 1 - \beta^2$ on $Gr_{\mathbb{C}}(2,4)$.
2. **Two-Spline Madelung Polar Wave Superposition & `kicad-volumetric` Metric Interference DRC**:
   For two adjacent nanolithography splines with amplitudes $A_1, A_2 > 0$:
   - **Single-Flash In-Phase Exposure ($\Delta\theta = 0$)**: $\operatorname{Complex.normSq}\bigl(\psi(A_1, \theta) + \psi(A_2, \theta)\bigr) = (A_1 + A_2)^2 = \operatorname{twoTraceConstructiveSqueezePeak}(A_1, A_2)$ (which at $A_1 = A_2 = 4/5$ reaches $64/25 = 2.56 > 2 = A_{sp3}$, triggering an unintended $sp^3$ diamond short/wall).
   - **Quadrature ($\Delta\theta = \pi/2$) / Orthogonal-Flash Decomposition**: $\operatorname{Complex.normSq}\bigl(\psi(A_1, \theta) + \psi(A_2, \theta + \pi/2)\bigr) = A_1^2 + A_2^2 < \operatorname{twoTraceConstructiveSqueezePeak}(A_1, A_2)$, eliminating the $2 A_1 A_2$ interference cross-term identically.
3. **$532\text{ nm}$ STED Depletion Amplifies Core Bohm Quantum Potential by $1 + \zeta_{532} = 64\times$ (`stedCoreBohmPotential`)**:
   Compressing the $405\text{ nm}$ write spot by a coaxial $532\text{ nm}$ helical doughnut beam of saturation ratio $\zeta_{532} > 0$ amplifies the repulsive core Bohm quantum-confinement potential of the focal Gaussian splat by:
   $$\operatorname{stedCoreBohmPotential}(m_\phi, \hbar, \lambda_w, \mathrm{NA}, \zeta_{532}) = (1 + \zeta_{532})\,\operatorname{stedCoreBohmPotential}(m_\phi, \hbar, \lambda_w, \mathrm{NA}, 0),$$
   yielding an exact $64\times$ quantum-confinement boost at $\zeta_{532} = 63$ ($w_{\mathrm{STED}} \approx 18.08\text{ nm}$).

---

## 4. Strain-Thickened Dilatant Bogoliubov Dispersion & Evidence Boundaries (`Signals.Pending`)

In a standard weakly interacting Bose–Einstein condensate ($\phi$-phase alone), linearized perturbations around uniform density $\rho_0 > 0$ obey the Bogoliubov squared phase velocity (`standardBogoliubovPhaseVelSq` in [src/signals/Signals/DDF.lean](../src/signals/Signals/DDF.lean#L7667-L7674)):

$$
v_p^2(k) = \frac{\omega_{\mathrm{Bog}}^2(k)}{k^2} = \frac{\hbar^2 k^2}{4 m_\phi^2} + \frac{g_0 \rho_0}{m_\phi}.
$$

When coupled to the shear-thickening dilatant phase ($\varphi$) ([Review Pop III GW Remnants, lines 621–660](#mad-chat-gw2026)), high-wavenumber shear strain promotes the effective contact coupling to $g_{\mathrm{DDF}}(k) = g_0(1 + \gamma_{\mathrm{dil}} k^2)$ with dilatant coefficient $\gamma_{\mathrm{dil}} > 0$ (`dilatantBogoliubovPhaseVelSq`):

$$
v_{p,\mathrm{DDF}}^2(k) = \frac{\hbar^2 k^2}{4 m_\phi^2} + \frac{g_0(1 + \gamma_{\mathrm{dil}} k^2)\rho_0}{m_\phi}
= v_p^2(k) + \frac{g_0 \gamma_{\mathrm{dil}} k^2 \rho_0}{m_\phi} > v_p^2(k) \qquad (k > 0, \gamma_{\mathrm{dil}} > 0).
$$

### Epistemic & Physical Evidence Boundary (`MadelungDilatantVariationalHypothesis`)

In accordance with the repository's evidence-triage discipline ([../src/signals/Signals/Pending.lean](../src/signals/Signals/Pending.lean#L4839-L4932)), `MadelungDilatantVariationalHypothesis` separates the machine-checked variational identities from open experimental premises:

| Claim / Mathematical Layer | Status in `Signals` | Owning Declaration | Required Experimental / Calibration Control |
|---|---|---|---|
| Polar substitution $\psi = \sqrt{\rho}e^{iS/\hbar}$ in $\mathcal{L}_{\mathrm{GP}}$ yields $\mathcal{L}_{\mathrm{Mad}}$, continuity $\partial_t\rho + \nabla\cdot(\rho v_\phi) = 0$, and QHJ $\partial_t S + \frac{1}{2}m_\phi v_\phi^2 + V_{\mathrm{ext}} + g_\phi\rho + Q = 0$ | **Verified** (`Signals.DDF`) | `MovingSheath.madelung_lagrangian_variational_and_dilatant_jamming_identities` | Exact mathematical identity for any $C^2$ non-vanishing complex order parameter ($A = \sqrt{\rho} > 0$ outside vortex cores). |
| Stationary dilatant sheath closure $\mathcal{R}_{\mathrm{sheath}}(\Lambda_\parallel) = 0 \iff \Lambda_\parallel = \gamma_\varphi(v)$, Legendre transform $H_{\mathrm{DDF}} = \gamma_\varphi m c^2$, and action proper time $d\tau_D = dt/\gamma_\varphi(v)$ | **Verified** (`Signals.DDF`) | `MovingSheath.madelung_lagrangian_variational_and_dilatant_jamming_identities` | Proves internal variational consistency of the constitutive DDF sheath model; does not by itself prove that physical vacuum is a material ether. |
| Strain-thickened Bogoliubov dispersion $g(k) = g_0(1 + \gamma_{\mathrm{dil}} k^2) \implies v_{p,\mathrm{DDF}}^2(k) > v_p^2(k)$ | **Verified** algebra / **Pending** physical realization | `dilatantBogoliubovPhaseVelSq`, `MadelungDilatantVariationalHypothesis` | Requires `laboratoryAcousticDispersionCalibrated` (Bragg spectroscopy or acoustic time-of-flight in a shear-thickening colloidal/BEC medium) and `crossedBeamDeflectionDiscriminatorTested` ($\eta_{\mathrm{act}}^\gamma = 0$ vs. $1$). |

---

## 5. Catalog of Check Figures & Quantitative Benchmarks Across Lean 4 and Rust/WASM

| # | Observable / Variational Identity | Exact Formula / Input Parameters | Verified Check Figure | Lean 4 / Rust Verification |
|---|---|---|---|---|
| **1** | Polar wavefunction norm $|\psi(3, \theta)|^2$ | $\operatorname{Complex.normSq}(\operatorname{madelungPolarWavefunction}(3, \theta))$ | $9$ (for all $\theta \in \mathbb{R}$) | `SignalsTests.lean`, `madelung_lagrangian.rs` |
| **2** | GP temporal symplectic term ($A=3, \hbar=2, \partial_t S = -3$) | $-\hbar\,\operatorname{Im}(\psi^*\partial_t\psi) = -A^2\,\partial_t S$ | $+27$ (independent of $\dot{A}$) | `grossPitaevskiiTemporalSymplecticTerm` |
| **3** | Equivalence $\mathcal{L}_{\mathrm{GP}} = \mathcal{L}_{\mathrm{Mad}} = \mathcal{L}_{\mathrm{Mad}}^\rho$ ($m_\phi=1, \hbar=2, g_\phi=5, V_{\mathrm{ext}}=7, A=3, \nabla A=4, \partial_t S=-3, \nabla S=2$) | $-9(-3 + 2 + 7) - \frac{5}{2}(81) - 2(16)$ | $-288.5 = -\frac{577}{2}$ | `grossPitaevskiiPolarLagrangianDensity`, `madelungHydrodynamicLagrangianDensity` |
| **4** | Phase Euler–Lagrange residual $\mathcal{E}_S$ ($\partial_t\rho = 0.75, \nabla\cdot(\rho v_\phi) = -0.75$) | $-\partial_t\pi_S - \nabla\cdot J_S = \partial_t\rho + \nabla\cdot(\rho v_\phi)$ | $0$ | `madelungPhaseEulerLagrangeResidual` |
| **5** | Amplitude Euler–Lagrange to QHJ ratio ($A = 3 > 0$) | $\mathcal{E}_A / (-2A) - \mathcal{R}_{\mathrm{QHJ}}$ | $0$ (identically) | `madelungAmplitudeEulerLagrangeResidual`, `quantumHamiltonJacobiResidual` |
| **6** | Stationary `RiverExterior` QHJ residual ($G_\phi=1, M=2, r=4, m_\phi=1$) | $\frac{1}{2}v_\phi(4)^2 + \Phi_\phi(4) = \frac{1}{2}(1) - \frac{1}{2}$ | $0$ | `RiverExterior.bernoulliPotential`, `quantumHamiltonJacobiResidual` |
| **7** | Stationary sheath compression at $\beta = 3/5$ ($\beta^2 = 9/25$) | $\Lambda_\parallel = \gamma_\varphi = \frac{5}{4} = 1.25$, $\mathcal{R}_{\mathrm{sheath}}(5/4)$ | $\mathcal{R}_{\mathrm{sheath}}(5/4) = 0$, $\Lambda_\parallel^2 = \frac{25}{16} > 1$ | `toyMadelungDilatantVariational` (`SignalsPendingTests.lean`) |
| **8** | Off-equilibrium sheath variational excess ($m=3, c=5, \beta=3/5, \Lambda_\parallel = 7/4$) | $\frac{1}{2}(3)(25)(16/25)(7/4 - 5/4)^2$ | $6.0 > 0$ | `MovingSheath.sheathVariationalExcess`, `madelung_lagrangian.rs` |
| **9** | Legendre-transformed dilatant Hamiltonian ($m=5, c=2, v=1 \implies \gamma_\varphi = 2/\sqrt{3}$) | $H_{\mathrm{DDF}} = v p_{\mathrm{DDF}} - L_{\mathrm{DDF}} = \gamma_\varphi m c^2$ | $\frac{40}{\sqrt{3}} = 20 + 20\left(\frac{2}{\sqrt{3}} - 1\right)$ | `MovingSheath.dilatantHamiltonian` |
| **10** | Relativistic mass-shell invariant ($m=5, c=2, v=1$) | $H_{\mathrm{DDF}}^2 - c^2 p_{\mathrm{DDF}}^2 = (m c^2)^2$ | $400$ | `SignalsTests.lean`, `madelung_lagrangian.rs` |
| **11** | Action-derived Minkowski interval ($c=2, v=1, dt=2.5$) | $c^2 d\tau_D^2 = c^2 dt^2 - (v\,dt)^2$ | $18.75 = \frac{75}{4}$ | `MovingSheath.actionProperTime` |
| **12** | 4-way $Gr_{\mathbb{C}}(2,4)$ Plücker & splat Lagrangian identity ($\beta = 3/5$) | $(L_{\mathrm{DDF}}/(-mc^2))^2 = |w_A^{\mathbb{C}}|^2|w_B^{\mathbb{C}}|^2 = \det\Sigma/\sigma_0^4 = 1 - \beta^2$ | $\frac{16}{25} = 0.64$ | `gr24_plucker_and_splat_invariants` |
| **13** | Dilatant vs. standard Bogoliubov squared phase velocity ($m_\phi=1, g_0=2, \rho_0=3, \gamma_{\mathrm{dil}}=1/2, \hbar=2, k=4$) | $v_{p,\mathrm{DDF}}^2 = 16 + 6(1 + 8) = 70$ vs. $v_p^2 = 16 + 6 = 22$ | $v_{p,\mathrm{DDF}}^2 - v_p^2 = 48 > 0$ | `dilatantBogoliubovPhaseVelSq` |
| **14** | 1D periodic conservative Madelung–QHJ time step ($N=6$ cells, $\Delta x = 0.5, \Delta t = 0.01$) | $\sum_{i=0}^5 \rho_i(t + \Delta t) - \sum_{i=0}^5 \rho_i(t)$ | $0$ (to machine precision $< 10^{-12}$) | `madelung_1d_periodic_stepper_conserves_total_mass` |
| **15** | Field Legendre Hamiltonian density $\mathcal{H}_{\mathrm{Mad}} = \pi_S\partial_t S - \mathcal{L}_{\mathrm{Mad}}$ ($m_\phi=1, \hbar=2, g_\phi=5, V_{\mathrm{ext}}=7, A=3, \nabla A=4, \nabla S=2$) | $9(2 + 7) + \frac{5}{2}(81) + 2(16)$ | $+315.5 = \frac{631}{2} > 0$ | `madelungAmplitudeHamiltonianDensity`, `madelungHydrodynamicHamiltonianDensity` |
| **16** | QHJ spatial gradient to Madelung–Euler momentum residual | $\frac{m_\phi\partial_t v_\phi + m_\phi v_\phi\nabla v_\phi + \nabla V_{\mathrm{ext}} + g_\phi\nabla\rho + \nabla Q}{m_\phi} - \mathcal{R}_{\mathrm{Euler}}$ | $0$ (identically) | `madelungEulerMomentumResidual` |
| **17** | Two-spline polar Madelung superposition ($A_1 = A_2 = 4/5 = 0.8$) | In-phase $|\psi_1+\psi_2|^2 = (A_1+A_2)^2$ vs. quadrature $|\psi_1+i\psi_2|^2 = A_1^2+A_2^2$ | $2.56 > 2 = A_{sp3}$ vs. $1.28 < 2 = A_{sp3}$ | `two_spline_polar_superposition_densities`, `twoTraceConstructiveSqueezePeak` |
| **18** | $405\text{ nm}/532\text{ nm}$ STED Bohm quantum-confinement amplification ($\zeta_{532} = 63$) | $Q_{\mathrm{STED}}(\zeta_{532}=63) / Q_{\mathrm{STED}}(\zeta_{532}=0) = 1 + \zeta_{532}$ | $64\times$ | `stedCoreBohmPotential`, `sted_core_bohm_potential` |

---

## 6. Machine-Checked Lean 4 Verification (`Signals.DDF` & `Signals.Pending`)

The following self-contained Lean 4 proof block typechecks directly against `Signals` and `SignalsPending` (`lake env lean`) and verifies the complete chain from the Gross–Pitaevskii polar substitution to the Euler–Lagrange continuity and Quantum Hamilton–Jacobi equations, the field Legendre Hamiltonian and Euler momentum bridge, the stationary `RiverExterior` limit, the dilatant sheath jamming recovery, the Legendre Hamiltonian and mass-shell invariant, the unconditional action-derived Minkowski interval, the $Gr_{\mathbb{C}}(2,4)$ Plücker and $\text{AdS}_5$ black-brane identities, the $405\text{ nm}/532\text{ nm}$ STED nanolithography quantum-confinement bridge, and the Pending evidence contract:

```lean
import Signals
import SignalsPending

namespace ArxivMadelungLagrangianDdfJammingVerification

open Signals
open Signals.Geometry
open Signals.DDF
open Signals.Pending

noncomputable def paperDDFSubstrate : DDFSubstrate :=
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

noncomputable def paperMovingSheath : MovingSheath paperDDFSubstrate :=
  { velocity := 1
    velocity_nonneg := by norm_num
    subluminal := by
      have hc : paperDDFSubstrate.c = 2 := by
        dsimp [DDFSubstrate.c, paperDDFSubstrate]
        norm_num
      rw [hc]
      norm_num }

noncomputable def paperRiverExterior : RiverExterior paperDDFSubstrate :=
  { G_phi := 1
    G_phi_pos := by norm_num
    sourceMass := 2
    sourceMass_pos := by norm_num }

noncomputable def paperVariationalHypothesis : MadelungDilatantVariationalHypothesis :=
  { bosonMass := 1
    bosonMass_pos := by norm_num
    baseCouplingG0 := 2
    baseCouplingG0_pos := by norm_num
    dilatantStrainCoeff := 1 / 2
    dilatantStrainCoeff_pos := by norm_num
    sheathBetaSq := 9 / 25
    sheathBetaSq_nonneg := by norm_num
    sheathBetaSq_lt_one := by norm_num
    sheathCompressionFactor := 5 / 4
    sheathCompressionFactor_pos := by norm_num
    stationaryJammingClosure := by norm_num
    laboratoryAcousticDispersionCalibrated := True
    laboratoryAcousticDispersionCalibrated_hypothesis := trivial
    crossedBeamDeflectionDiscriminatorTested := True
    crossedBeamDeflectionDiscriminatorTested_hypothesis := trivial }

example (S S_t grad_S A_dot laplacian_A dt_rho div_rho_v
    dt_v v_phi grad_v grad_V grad_rho grad_Q dt x : ℝ) :
    let θ := S / 2
    let ψ := madelungPolarWavefunction 3 θ
    let ψ_t := madelungPolarDerivative 3 A_dot θ (S_t / 2)
    let ψ_x := madelungPolarDerivative 3 4 θ (grad_S / 2)
    let M_sheath := paperMovingSheath.gr24TwistorMatrix 6 1 5 2 0 x
    let ψ1 := madelungPolarWavefunction (4 / 5) θ
    let ψ2_inPhase := madelungPolarWavefunction (4 / 5) θ
    let ψ2_quad := madelungPolarWavefunction (4 / 5) (θ + Real.pi / 2)
    -- (1) Polar substitution in the Gross-Pitaevskii Lagrangian & Legendre Hamiltonian density:
    Complex.normSq ψ = 3 ^ 2 ∧
    grossPitaevskiiTemporalSymplecticTerm 2 ψ ψ_t = -(3 ^ 2) * S_t ∧
    grossPitaevskiiPolarLagrangianDensity 1 2 5 7 ψ ψ_t ψ_x =
      madelungAmplitudeLagrangianDensity 1 2 5 7 3 4 S_t grad_S ∧
    madelungHydrodynamicLagrangianDensity 1 2 5 7 (3 ^ 2) (2 * 3 * 4) S_t grad_S =
      madelungAmplitudeLagrangianDensity 1 2 5 7 3 4 S_t grad_S ∧
    madelungPhaseCanonicalMomentum (3 ^ 2) * S_t -
        madelungAmplitudeLagrangianDensity 1 2 5 7 3 4 S_t grad_S =
      madelungAmplitudeHamiltonianDensity 1 2 5 7 3 4 grad_S ∧
    0 ≤ madelungAmplitudeHamiltonianDensity 1 2 5 7 3 4 grad_S ∧
    -- (2) Euler-Lagrange Continuity, QHJ, Euler Momentum, & RiverExterior limit:
    madelungPhaseEulerLagrangeResidual (-dt_rho) (-div_rho_v) =
      madelungContinuityResidual dt_rho div_rho_v ∧
    madelungAmplitudeEulerLagrangeResidual 1 2 5 7 3 laplacian_A S_t grad_S / (-2 * 3) =
      quantumHamiltonJacobiResidual 1 2 5 7 3 laplacian_A S_t (grad_S / 1) ∧
    ((1 * dt_v) + (1 * v_phi * grad_v) + grad_V + 5 * grad_rho + grad_Q) / 1 =
      madelungEulerMomentumResidual 1 5 dt_v v_phi grad_v grad_V grad_rho grad_Q ∧
    quantumHamiltonJacobiResidual 1 2 0 (1 * paperRiverExterior.bernoulliPotential 4) 3 0 0
      (paperRiverExterior.velocity 4) = 0 ∧
    -- (3) Dilatant sheath jamming recovery, Legendre Hamiltonian, & unconditional Minkowski interval:
    paperMovingSheath.sheathCompressionResidual paperMovingSheath.jammingFactor = 0 ∧
    (paperMovingSheath.sheathCompressionResidual 2 = 0 ↔ 2 = paperMovingSheath.jammingFactor) ∧
    paperMovingSheath.dilatantHamiltonian 5 =
      5 * paperDDFSubstrate.c ^ 2 + paperMovingSheath.kineticEnergy 5 ∧
    (paperMovingSheath.dilatantHamiltonian 5) ^ 2 -
        paperDDFSubstrate.c ^ 2 * (paperMovingSheath.dilatantCanonicalMomentum 5) ^ 2 =
      (5 * paperDDFSubstrate.c ^ 2) ^ 2 ∧
    paperDDFSubstrate.c ^ 2 * (paperMovingSheath.actionProperTime 5 dt) ^ 2 =
      paperDDFSubstrate.c ^ 2 * dt ^ 2 - (paperMovingSheath.velocity * dt) ^ 2 ∧
    -- (4) Complex Gr_C(2,4) Plücker duality, dilatant Bogoliubov, STED Bohm 64x boost, & Pending contract:
    (paperMovingSheath.dilatantLagrangian 5 / (-(5 * paperDDFSubstrate.c ^ 2))) ^ 2 =
      Complex.normSq (complexPluckerSinkAmplitudeA M_sheath) *
        Complex.normSq (complexPluckerSinkAmplitudeB M_sheath) ∧
    standardBogoliubovPhaseVelSq 1 2 3 2 4 <
      dilatantBogoliubovPhaseVelSq 1 2 3 (1 / 2) 2 4 ∧
    Complex.normSq (ψ1 + ψ2_inPhase) = twoTraceConstructiveSqueezePeak (4 / 5) (4 / 5) ∧
    Complex.normSq (ψ1 + ψ2_quad) < Complex.normSq (ψ1 + ψ2_inPhase) ∧
    stedCoreBohmPotential 1 2 405 (7 / 5) 63 =
      64 * stedCoreBohmPotential 1 2 405 (7 / 5) 0 ∧
    1 < paperVariationalHypothesis.sheathCompressionFactor ^ 2 := by
  intro θ ψ ψ_t ψ_x M_sheath ψ1 ψ2_inPhase ψ2_quad
  have h := paperMovingSheath.madelung_lagrangian_variational_and_dilatant_jamming_identities
    paperRiverExterior 1 2 5 7 3 A_dot 4 laplacian_A S S_t grad_S
    dt_rho div_rho_v 4 5 2 dt 2 3 (1 / 2) 4 6 1 5 2 0 x
    (by norm_num) (by norm_num) (by norm_num) (by norm_num)
    (by norm_num) (by norm_num) (by norm_num) (by norm_num)
    (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  have hb := madelung_hamiltonian_euler_ads_and_nanolithography_bridge_identities
    1 2 5 7 3 4 S_t grad_S dt_v v_phi grad_v grad_V grad_rho grad_Q
    1 2 (4 / 5) (4 / 5) 405 (7 / 5) 63 θ
    (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num)
    (by norm_num) (by norm_num) (by norm_num) (by norm_num)
    (by norm_num) (by norm_num) (by norm_num)
  have h_pend := paperVariationalHypothesis.compression_sq_gt_one
    (by norm_num [paperVariationalHypothesis])
  exact ⟨h.1, h.2.1, h.2.2.2.1, h.2.2.2.2.1, hb.1, hb.2.2.1,
    h.2.2.2.2.2.1, h.2.2.2.2.2.2.1, hb.2.2.2.1, h.2.2.2.2.2.2.2.1,
    h.2.2.2.2.2.2.2.2.1, h.2.2.2.2.2.2.2.2.2.2.2.1,
    h.2.2.2.2.2.2.2.2.2.2.2.2.2.1, h.2.2.2.2.2.2.2.2.2.2.2.2.2.2.1,
    h.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.1, h.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.1,
    h.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2,
    hb.2.2.2.2.2.2.1, hb.2.2.2.2.2.2.2.2.1, hb.2.2.2.2.2.2.2.2.2.2, h_pend⟩

end ArxivMadelungLagrangianDdfJammingVerification
```

---

### Scholarly References

(mad-madelung1927)=
<a id="mad-madelung1927"></a>
1. Madelung, E. (1927). *Quantentheorie in hydrodynamischer Form*. Zeitschrift für Physik 40(3–4), 322–326. [DOI: 10.1007/BF01400372](https://doi.org/10.1007/BF01400372).

(mad-bohm1952)=
<a id="mad-bohm1952"></a>
2. Bohm, D. (1952). *A Suggested Interpretation of the Quantum Theory in Terms of "Hidden" Variables. I*. Physical Review 85(2), 166–179. [DOI: 10.1103/PhysRev.85.166](https://doi.org/10.1103/PhysRev.85.166).

(mad-gross1961)=
<a id="mad-gross1961"></a>
3. Gross, E. P. (1961). *Structure of a quantized vortex in boson systems*. Il Nuovo Cimento 20(3), 454–477. [DOI: 10.1007/BF02731494](https://doi.org/10.1007/BF02731494).

(mad-pitaevskii1961)=
<a id="mad-pitaevskii1961"></a>
4. Pitaevskii, L. P. (1961). *Vortex Lines in an Imperfect Bose Gas*. Soviet Physics JETP 13(2), 451–454.

(mad-unruh1981)=
<a id="mad-unruh1981"></a>
5. Unruh, W. G. (1981). *Experimental Black-Hole Evaporation?* Physical Review Letters 46(21), 1351–1353. [DOI: 10.1103/PhysRevLett.46.1351](https://doi.org/10.1103/PhysRevLett.46.1351).

(mad-fedi2026)=
<a id="mad-fedi2026"></a>
6. Fedi, M. (2026). *Dilatant Dark Fluid: Toward a Unified Quantum-Hydrodynamic Origin of Lorentz Invariance, Gravity, and Cosmological Phenomenology*. SSRN Preprint 7406660.

(mad-chat-splat2026)=
<a id="mad-chat-splat2026"></a>
7. Provenance Chat Log (2026). *Grassmannian Splat Mechanics and Vortex Space Emergence (Gross–Pitaevskii Equation, Madelung Transformation, Continuity & Quantum Pressure Euler Equations, and SQG/DDF Horizon Regularization)*. ({download}`data/chats/Grassmannian Splat Mechanics and Vortex Space Emergence.md, lines 89-195 <../data/chats/Grassmannian Splat Mechanics and Vortex Space Emergence.md>`).

(mad-chat-gw2026)=
<a id="mad-chat-gw2026"></a>
8. Provenance Chat Log (2026). *Review Pop III GW Remnants (Dilatant Dark Fluid Strain-Thickened Bogoliubov Dispersion $g(k) = g_0(1 + \gamma k^2)$)*. ({download}`data/chats/Review-Pop-III-GW-Remnants.md, lines 621-660 <../data/chats/Review-Pop-III-GW-Remnants.md>`).

(mad-chat-gravity2026)=
<a id="mad-chat-gravity2026"></a>
9. Provenance Chat Log (2026). *Gravity Models: Dilatant Fluid vs. GR (Lorentz Jamming Factor and Acoustic Horizon Physics)*. ({download}`data/chats/_Gravity-Models-Dilatant-Fluid-vs.-GR.md, lines 70-185 <../data/chats/_Gravity-Models-Dilatant-Fluid-vs.-GR.md>`).

---

### BibTeX Citations

```bibtex
@article{madelung1927quantentheorie,
  author  = {Madelung, Erwin},
  title   = {Quantentheorie in hydrodynamischer {F}orm},
  journal = {Zeitschrift f{\"u}r Physik},
  volume  = {40},
  number  = {3--4},
  pages   = {322--326},
  year    = {1927},
  doi     = {10.1007/BF01400372},
  url     = {https://doi.org/10.1007/BF01400372}
}

@article{gross1961structure,
  author  = {Gross, Eugene P.},
  title   = {Structure of a quantized vortex in boson systems},
  journal = {Il Nuovo Cimento},
  volume  = {20},
  number  = {3},
  pages   = {454--477},
  year    = {1961},
  doi     = {10.1007/BF02731494},
  url     = {https://doi.org/10.1007/BF02731494}
}

@misc{fedi2026ddf,
  author       = {Fedi, Marco},
  title        = {Dilatant Dark Fluid: Toward a Unified Quantum-Hydrodynamic Origin of {L}orentz Invariance, Gravity, and Cosmological Phenomenology},
  year         = {2026},
  howpublished = {SSRN Preprint 7406660}
}

@misc{chat_grassmannian_splat_gpe_madelung_2026,
  author       = {{unknown}},
  title        = {Grassmannian Splat Mechanics and Vortex Space Emergence: Gross-Pitaevskii Equation and Madelung Hydrodynamics},
  year         = {2026},
  howpublished = {AI chat log},
  note         = {Source: data/chats/Grassmannian Splat Mechanics and Vortex Space Emergence.md, lines 89-195},
  url          = {../data/chats/Grassmannian Splat Mechanics and Vortex Space Emergence.md}
}

@misc{chat_pop_iii_gw_dilatant_bogoliubov_2026,
  author       = {{unknown}},
  title        = {Review Pop III GW Remnants: Dilatant Dark Fluid Bogoliubov Dispersion},
  year         = {2026},
  howpublished = {AI chat log},
  note         = {Source: data/chats/Review-Pop-III-GW-Remnants.md, lines 621-660},
  url          = {../data/chats/Review-Pop-III-GW-Remnants.md}
}
```

### Schema.org Metadata (JSON-LD)

```json
{
  "@context": "https://schema.org",
  "@type": "ScholarlyArticle",
  "headline": "From Superfluid Gross–Pitaevskii Action and Madelung Polar Substitution to Euler–Lagrange Hydrodynamics and Dilatant Dark Fluid (DDF) Jamming Recovery in Complex Grassmannian Gr_C(2,4) Mechanics",
  "author": {
    "@type": "Person",
    "name": "Wes Turner"
  },
  "dateModified": "2026-10-27",
  "isBasedOn": [
    "data/chats/Grassmannian Splat Mechanics and Vortex Space Emergence.md",
    "data/chats/Review-Pop-III-GW-Remnants.md",
    "data/chats/_Gravity-Models-Dilatant-Fluid-vs.-GR.md",
    "src/signals/Signals/DDF.lean",
    "src/signals/Signals/Pending.lean",
    "src/signals/numerical_adapter/src/madelung_lagrangian.rs"
  ],
  "about": [
    "Gross-Pitaevskii Action",
    "Madelung Transformation",
    "Quantum Hamilton-Jacobi Equation",
    "Euler-Lagrange Variational Principle",
    "Dilatant Dark Fluid Jamming Factor",
    "Complex Grassmannian Gr_C(2,4)",
    "Lean 4 Formal Verification"
  ]
}
```
