---
title: "Compressible and Incompressible Navier–Stokes via Three-Channel Plücker–Madelung and Six-Channel Dual-Schubert QFIM (F_μν = 4 g^FS_μν): Clebsch Spinor Vorticity, Schubert Chart Regularization, Bateman Viscous Audit, Korteweg Stress, and Bresch–Desjardins Equivalence in Lean 4, Rust/PyO3, and SymPy"
description: "An arXiv-ready MyST Markdown formal verification and computational fluid dynamics paper uniting incompressible and compressible Navier–Stokes / Navier–Stokes–Korteweg (NSK) equations with the Three-Channel Plücker–Madelung and Six-Channel Dual-Schubert Quantum Fisher Information Metric (QFIM) stack in Lean 4 (zero sorry), Rust/PyO3 structure-preserving solvers, and 16 exact SymPy symbolic proofs."
---

(grassmannian-dual-schubert-qfim-navier-stokes-compressible-incompressible-paper)=
# Compressible and Incompressible Navier–Stokes via Three-Channel Plücker–Madelung and Six-Channel Dual-Schubert QFIM ($F_{\mu\nu} = 4\,g_{\mu\nu}^{\mathrm{FS}}$): Clebsch Spinor Vorticity, Schubert Chart Regularization, Bateman Viscous Audit, Korteweg Stress, and Bresch–Desjardins Equivalence in Lean 4, Rust/PyO3, and SymPy

- **Authors:** Wes Turner
- **Subjects:**
  - Fluid Dynamics (`physics.flu-dyn`); Mathematical Physics (`math-ph`); Analysis of PDEs (`math.AP`); Quantum Physics (`quant-ph`); Logic & Formal Verification (`cs.LO`)
- **Epistemic Status & Scope Declaration:**
  - **Verified Mathematical & Computational Core (Machine-Checked in Lean 4, Rust/PyO3, and SymPy):** We formalize 3 zero-`sorry` Lean 4 modules under `Signals.NavierStokes` (`PluckerFrame`, `Incompressible`, `Compressible`, plus umbrella `NavierStokes.lean`) integrated into the `Signals` library (`3,834` Lake build jobs via `make signals_build`), paired with 14 Rust unit tests (`170/170` crate tests) + 2 compiled PyO3 structure-preserving PDE solvers (`IncompressibleDualSchubertSolver2D` and `CompressibleNskDualSchubertSolver1D` in `navier_stokes.rs`) and 20 exact SymPy symbolic proofs (`sustainablefactory/navier_stokes.py`, `5/5` `pytest` tests passing).
  - **Open Millennium-Problem & Physical Calibration Boundary (`Signals.Pending.DualSchubertNavierStokesPendingBoundary`):** Machine-checked Schubert chart transitions ($\Omega_0 \leftrightarrow \Omega_{02}$), exact 2D/3D analytical Navier–Stokes solutions, Korteweg capillary stress conservation, Bresch–Desjardins Dual-Schubert energy splits, and 1D Cole–Hopf linearization do **not** prove Clay Millennium 3D global regularity or finite-time blowup {cite:p}`fefferman2006existence`, do **not** linearize general 3D Navier–Stokes into a constant-coefficient Hirota PDE, and do **not** validate turbulence closures or laboratory PIV/DDF realizations without calibrated experimental telemetry.
- **Primary Source Chat Provenance & Written Plan:**
  - {download}`data/chats/bohmian-mechanics-and-navier-stokes-and-nonlinearity.md <../data/chats/bohmian-mechanics-and-navier-stokes-and-nonlinearity.md>` (`216` lines, `sha256: d575c8992e1398f02228d62d4300a223d8efd0f4e1b82c929e2c72401897bea0`; primary derivation lines `1–140`, duplicate paste lines `143–216`).
  - [Written Plan: Compressible & Incompressible Navier–Stokes via Three-Channel Plücker–Madelung and Six-Channel Dual-Schubert QFIM](dual-schubert-qfim-navier-stokes-plan.md).
- **Companion Papers:**
  - [Formalizing the Infinite-Dimensional Sato Grassmannian $\mathrm{Gr}_p(H)$, Plabic $\mathrm{Gr}_{\ge 0}(2,4)$ KP-II / KdV / AKNS Soliton PDE Solvers, Baker–Akhiezer Lax Pairs, and 6-Channel Dual-Schubert QFIM in Lean 4, Rust/PyO3, and SymPy](grassmannian-sato-hilbert-space-kp-pde-solver-akns-qfim-paper.md)
  - [Why the Quantum Fisher Information Metric Is Four Times the Fubini–Study Kähler Metric ($F_{\mu\nu} = 4\,g_{\mu\nu}^{\mathrm{FS}}$)](grassmannian-qfim-fubini-study-kahler-madelung-unification-paper.md)
  - [Complex Grassmannian $\mathrm{Gr}_{\mathbb{C}}(2,4)$ Fubini–Study Gross–Pitaevskii Equation, Dual-Schubert `iGPE`, and Homogeneous Plücker Madelung Hydrodynamics on the Klein Quadric $\mathcal{Q}_4$](grassmannian-complex-gpe-igpe-plucker-madelung-paper.md)
  - [From Superfluid Gross–Pitaevskii Action and Madelung Polar Substitution to Euler–Lagrange Hydrodynamics and Dilatant Dark Fluid (DDF) Jamming Recovery](grassmannian-madelung-lagrangian-ddf-jamming-paper.md)
  - [Quantum Trajectories in Complex Grassmannian $\mathrm{Gr}_{\mathbb{C}}(k,n)$, Three-Channel Plücker–Madelung–QFIM ($F_{\mu\nu} = 4\,g_{\mu\nu}^{\mathrm{FS}}$), Dual-Schubert `iGPE`, and Dilatant Dark Fluid (`DDF`) Mechanics](grassmannian-quantum-trajectories-bohmian-weak-nonlinear-optics-paper.md)
- **Formal Verification & Computational Artifacts:**
  - `Signals` Lean 4 Library (`3,834` Lake jobs via `make signals_build`, zero `sorry`):
    - {download}`src/signals/Signals/NavierStokes.lean <../src/signals/Signals/NavierStokes.lean>`
    - {download}`src/signals/Signals/NavierStokes/PluckerFrame.lean <../src/signals/Signals/NavierStokes/PluckerFrame.lean>`
    - {download}`src/signals/Signals/NavierStokes/Incompressible.lean <../src/signals/Signals/NavierStokes/Incompressible.lean>`
    - {download}`src/signals/Signals/NavierStokes/Compressible.lean <../src/signals/Signals/NavierStokes/Compressible.lean>`
    - {download}`src/signals/Signals/Pending.lean <../src/signals/Signals/Pending.lean>` (`DualSchubertNavierStokesPendingBoundary`)
    - {download}`src/signals/SignalsTests.lean <../src/signals/SignalsTests.lean>` & {download}`src/signals/SignalsPendingTests.lean <../src/signals/SignalsPendingTests.lean>`
  - `signals-numerical-adapter` Rust + PyO3 (`maturin`) Extension (`170/170` Rust unit tests passing, including `14/14` `navier_stokes` tests):
    - {download}`src/signals/numerical_adapter/src/navier_stokes.rs <../src/signals/numerical_adapter/src/navier_stokes.rs>`
  - Python + SymPy + PyO3 Verification Suite (`5/5` `pytest` tests, `20/20` exact symbolic SymPy proofs):
    - {download}`sustainablefactory/navier_stokes.py <../sustainablefactory/navier_stokes.py>`
    - {download}`tests/test_navier_stokes_dual_schubert_qfim.py <../tests/test_navier_stokes_dual_schubert_qfim.py>`

---

## Abstract

Standard Madelung hydrodynamics {cite:p}`madelung1927,bohm1952a,bohm1952b` transforms a scalar Schrödinger wavefunction $\psi = \sqrt{\rho}\,e^{iS/\hbar}$ into an **irrotational, inviscid, compressible** Euler–Korteweg fluid whose velocity $\mathbf{v} = \frac{\hbar}{m}\nabla S$ and Bohmian quantum potential $Q = -\frac{\hbar^2}{2m}\frac{\nabla^2\sqrt{\rho}}{\sqrt{\rho}}$ diverge at nodal vortex cores ($\rho \to 0$) and cannot represent continuous vorticity ($\nabla \times \mathbf{v} \ne \mathbf{0}$) or viscous dissipation ($\nu > 0$). We show how lifting the fluid state into our **Three-Channel Plücker–Madelung and Six-Channel Dual-Schubert Quantum Fisher Information Metric (`QFIM`)** architecture ($F_{\mu\nu} = 4\,g_{\mu\nu}^{\mathrm{FS}}$ on $\mathrm{Gr}_{\mathbb{C}}(2,4) \times \mathrm{Gr}_{\mathbb{C}}(2,4)^\vee$, `Signals.SatoGrassmannian.DualSchubertQFIM`) unifies **both incompressible and compressible Navier–Stokes / Navier–Stokes–Korteweg (NSK) equations** within a single machine-checked framework in **Lean 4**, **Rust/PyO3**, and **SymPy**.

Our formalization establishes six principal results:

1. **Formal Audit & Repair of Three Source-Chat Defects (`PluckerFrame.lean`):** Auditing {download}`data/chats/bohmian-mechanics-and-navier-stokes-and-nonlinearity.md <../data/chats/bohmian-mechanics-and-navier-stokes-and-nonlinearity.md>` exposed and machine-proved three defects: (i) a $4\times 2$ vs. $2\times 2$ matrix-shape mismatch (lines 57–71), repaired by an explicit $4\times 2$ 1-jet Stiefel frame `jetFrame` satisfying the Klein quadric $p_{01}p_{23} - p_{02}p_{13} + p_{03}p_{12} = 0$, exact $1/p_{01}^2$ cancellation (`jetFrame_klein_quadric_cancellation`), and smooth Schubert chart transition $\Omega_0 \leftrightarrow \Omega_{02}$ across the nodal divisor $\Sigma_1 = \{p_{01} = 0\}$ (`schubert_chart_transition_omega0_to_omega02`); (ii) a sign/Hermiticity error in the proposed viscous Hamiltonian $\mathcal{H}_{\mathrm{eff}}$ (lines 99–101), where we prove `chat_offdiag_viscous_matrix_is_hermitian` ($H_{\mathrm{chat}}^\dagger = H_{\mathrm{chat}}$, zero dissipation) and replace it with the genuine **Bateman / Keldysh doubled anti-Hermitian operator** {cite:p}`bateman1931dissipative` (`bateman_doubled_viscous_pairing_conserved_and_primal_dissipates`), dissipating primal energy at $-2\nu k^2|\psi|^2$ while conserving $\overline{\tilde{\psi}}\psi$; and (iii) isolating 3D Clay Millennium regularity and 3D Hirota-linearization overclaims in `Signals.Pending.DualSchubertNavierStokesPendingBoundary`.
2. **Continuous Vorticity from a 2-Component Clebsch Spinor Lift & Riccati Tangent Orthogonality (`PluckerFrame.lean`):** Embedding $\hat{\psi}(\theta, \phi_1, \phi_2) = (\cos(\theta/2)e^{i\phi_1}, \sin(\theta/2)e^{i\phi_2})$ into `Plucker6` yields unit norm everywhere, exact $F_{\mu\mu} = 4\,g_{\mu\mu}^{\mathrm{FS}} = (\partial_\mu\theta)^2 + \sin^2\theta\,(\partial_\mu\phi_1 - \partial_\mu\phi_2)^2$ (`clebsch_spinor_berry_and_qfim`), and an explicit curl derivation (`clebsch_berry_curl_eq_vorticityZ`) proving nonzero continuous vorticity $\omega_z = \frac{\hbar}{m}(\partial_x A_y - \partial_y A_x) = \frac{\hbar}{2m}\sin\theta\,(\partial_x\theta\,\partial_y(\phi_2-\phi_1) - \partial_y\theta\,\partial_x(\phi_2-\phi_1))$ (`clebsch_berry_vorticity_nonzero`), grounding Chern et al.'s *Incompressible Schrödinger Flow* {cite:p}`chern2016schrodinger`. We further prove Grassmannian Riccati tangent orthogonality $Z^\dagger \dot{Z} = 0$ and Gram preservation $\dot{Z}^\dagger Z + Z^\dagger \dot{Z} = 0$ for arbitrary non-Hermitian operators (`riccati_grassmann_projection_orthogonal`).
3. **Incompressible Navier–Stokes (`Ch. 2 = 0`), ISF Spin-Tension Separation, & Exact 2D/3D Calculus Proofs (`Incompressible.lean`):** Setting $\nabla\rho = \mathbf{0}$ annihilates the scalar osmotic/Fisher Channel 2 identically (`incompressible_channel2_vanishes`), leaving Channel 1 hydrodynamic kinetic energy plus Channel 3 projective QFIM energy (`incompressible_dual_schubert_energy_enstrophy_split`), while `isf_spin_tension_vs_classical_incompressible_ns` explicitly isolates the Landau–Lifshitz / QFIM spin-tension discrepancy between raw ISF and classical incompressible Navier–Stokes. Using Mathlib's `deriv` and `iteratedDeriv 2`, we prove exact PDE satisfaction for the **2D Taylor–Green decaying vortex** {cite:p}`taylor1937mechanism` (`taylorGreen2D_solves_incompressible_ns`, including $\dot{E} = -2\nu\mathcal{Z}$), **2D Lamb–Oseen viscous vortex** (`lambOseen2D_vorticity_heat_pde` and cylindrical curl recovery `lambOseen_velocity_recovers_vorticity`), **plane Poiseuille shear flow** (`poiseuille_solves_incompressible_ns`), and **3D decaying Beltrami / ABC rotational vortex flow** (`beltramiABC_solves_3d_incompressible_ns`).
4. **Compressible Navier–Stokes & NSK (`Ch. 1 + 2 + 3`), Full-Calculus Korteweg Stress, Bresch–Desjardins Equivalence, & `Signals.DDF` Bogoliubov–Stokes Bridge (`Compressible.lean`):** We prove 3D compressible viscous dissipation positivity $\Phi_{\mathrm{visc}} \ge 0$ and Stokes' hypothesis (`compressible_viscous_dissipation_nonneg`), a full `HasDerivAt`/`deriv` calculus proof of the **Korteweg capillary stress divergence identity** {cite:p}`korteweg1901forme` $-\frac{\rho}{m}\partial_x Q = \partial_x K_{xx}$ (`korteweg_stress_div_eq_quantum_force_calculus`), the **Bresch–Desjardins Dual-Schubert QFIM theorem** {cite:p}`bresch2003existence` (`breschDesjardins_dual_schubert_qfim_split`), the **unified Bogoliubov–Korteweg–Stokes dispersion** $\omega^2 + i\delta k^2\omega = c_s^2 k^2 + \kappa_K k^4$ recovering `Signals.DDF.standardBogoliubovPhaseVelSq` at $\delta = 0$ (`compressible_nsk_bogoliubov_stokes_dispersion`), and exact 1D **Rankine–Hugoniot** shock jump conservation (`rankine_hugoniot_compressible_jump`).
5. **Cole–Hopf Viscous Burgers $\tau$-Function Bridge & Stokes Acoustic Dispersion (`Compressible.lean`):** We prove the Cole–Hopf heat-to-Burgers identity {cite:p}`cole1951quasilinear,hopf1950partial` (`coleHopf_heat_implies_viscous_burgers`), full calculus PDE satisfaction for the moving viscous Burgers tanh shock (`burgers_tanh_shock_solves_pde`), and causal damped compressible Stokes acoustic dispersion $\omega^2 + i\delta k^2\omega - c_s^2 k^2 = 0$ with $\operatorname{Im}(\omega) = -\frac{1}{2}\delta k^2 \le 0$ (`stokes_acoustic_attenuation_dispersion`).
6. **Compiled Rust/PyO3 Structure-Preserving Solvers & Tri-Language Verification (`navier_stokes.rs`, `navier_stokes.py`):** All 10 analytical auditors match Lean 4 and 20 SymPy proofs to `< 2e-15`; `IncompressibleDualSchubertSolver2D` tracks 2D Taylor–Green decay to $L^2$ error $4.27 \times 10^{-8}$ and nonlinear multi-mode vortex-pair convection (`high_mode_energy = 0.0817`, $\max|\nabla\cdot\mathbf{v}| = 1.19 \times 10^{-14}$) while evaluating the true unit-normalized projective Plücker QFIM trace (`qfim_fs_ratio_residual = 0.0`, `ch2_osmotic = 0.0`); and `CompressibleNskDualSchubertSolver1D` conserves total mass to $8.88 \times 10^{-16}$, total momentum to $2.08 \times 10^{-17}$, Bresch–Desjardins Dual-Schubert identity to $1.73 \times 10^{-18}$, and matches the exact Bogoliubov–Korteweg–Stokes physical damping law over a full acoustic period to **$0.0317\%$** (`3.17e-4`) using its zero-artificial-diffusion central stepper.

---

## 1. Architecture & Dual-Regime Unification Flowchart

```{mermaid}
flowchart TB
    Q["Three-Channel Plücker–Madelung & Six-Channel Dual-Schubert QFIM\nSignals.SatoGrassmannian.DualSchubertQFIM (F_μν = 4 g^FS_μν)\n(ℏ²/2m) ‖∇Ψ‖² = (1/2)mρ‖v‖² + (ℏ²/8m)‖∇ρ‖²/ρ + (ℏ²/8m)ρ Tr(F_μν)"]

    PF["PluckerFrame.lean\n• 4×2 1-Jet Stiefel Frame & Klein Quadric Q_4\n• Smooth Schubert Transition Ω₀ ↔ Ω₀₂ across Σ₁={p₀₁=0}\n• 2-Spinor Clebsch Berry Vorticity ω_z ≠ 0\n• Chat Defect #2 Fix: Bateman diag(E-iℏνk², E+iℏνk²)"]

    INC["Incompressible.lean (ρ = ρ₀, ∇·v = 0)\n• Ch. 2 Osmotic Energy ≡ 0\n• Ch. 1 Flow + Ch. 3 Projective QFIM Spin-Stress\n• 2D Taylor–Green, 2D Lamb–Oseen, Poiseuille, 3D Beltrami/ABC"]

    CMP["Compressible.lean (ρ(x,t) > 0, NS & NSK)\n• All 3 Channels Active (Ch. 1 + Ch. 2 + Ch. 3)\n• 3D Φ_visc ≥ 0 & Korteweg -(ρ/m)∂_x Q = ∂_x K_xx\n• Bresch–Desjardins v_± = v ± ν(ρ_x/ρ) ↔ Ch. 1+2\n• Cole–Hopf Burgers Shock & Stokes Acoustic Dispersion"]

    RS["Rust/PyO3 Solvers (navier_stokes.rs) + SymPy (16 Proofs)\n• IncompressibleDualSchubertSolver2D (TG L² = 4.27e-8, div = 1.59e-14)\n• CompressibleNskDualSchubertSolver1D (mass drift = 8.88e-16, BD = 1.73e-18)"]

    PND["Signals.Pending.DualSchubertNavierStokesPendingBoundary\n• Isolates 3D Clay Millennium Regularity, 3D Non-Integrability,\n  Turbulence Closure, & Experimental PIV/DDF Calibration"]

    Q --> PF
    PF --> INC --> RS
    PF --> CMP --> RS
    RS --> PND
```

---

## 2. Formal Audit of the Source Chat: Three Machine-Checked Repairs (`PluckerFrame.lean`)

Formalizing {download}`data/chats/bohmian-mechanics-and-navier-stokes-and-nonlinearity.md <../data/chats/bohmian-mechanics-and-navier-stokes-and-nonlinearity.md>` in Lean 4 caught and formally resolved three mathematical flaws:

### 2.1 Repair 1 — $4 \times 2$ 1-Jet Stiefel Frame & Schubert Chart Transition $\Omega_0 \leftrightarrow \Omega_{02}$

The chat draft (lines 57–71) wrote a $4 \times 2$ matrix $(z_{ij})$ equal to a $2 \times 2$ block $(\psi_a, \tilde{\psi}_a)$ while using spatial derivatives $\partial_x\psi, \partial_y\psi$ for rows 3–4. In `Signals.NavierStokes.PluckerFrame`, `jetFrame` builds a well-typed $4 \times 2$ complex matrix $Z \in \mathbb{C}^{4\times 2}$ whose six Plücker minors $p_{ij} = z_{i,0} z_{j,1} - z_{i,1} z_{j,0}$ (0-indexed: `p₀₁ ↔ p₁₂`, `p₀₂ ↔ p₁₃`, `p₂₃ ↔ p₃₄`) identically satisfy the Klein quadric:

$$
p_{01} p_{23} - p_{02} p_{13} + p_{03} p_{12} = 0.
$$

On the big cell $\Omega_0 = \{p_{01} \ne 0\}$, `jetFrame_klein_quadric_cancellation` proves the exact Madelung denominator cancellation:

$$
\frac{p_{02} p_{13} - p_{03} p_{12}}{p_{01}^2} = \frac{p_{23}}{p_{01}}.
$$

The following guide uses Lean's 0-based row labels; the conventional 1-based minor is shown in parentheses. In `jetFrame` ({download}`Signals.NavierStokes.PluckerFrame, lines 42–99 <../src/signals/Signals/NavierStokes/PluckerFrame.lean>`), rows 0–1 hold the primal/dual spinor components $(\psi_1, \tilde\psi_1)$ and $(\psi_2, \tilde\psi_2)$, and rows 2–3 hold their first-jet derivatives $(D_1\psi_1, D_1\tilde\psi_1)$ and $(D_2\psi_2, D_2\tilde\psi_2)$. The four first-jet cross-minors split into the two Klein-quadric conjugate pairs $(p_{02}, p_{13})$ and $(p_{03}, p_{12})$. Because these minors are homogeneous frame coordinates rather than proved physical observables, the table contrasts the source chat's proposed hydrodynamic labels ({download}`data/chats/bohmian-mechanics-and-navier-stokes-and-nonlinearity.md, lines 62–70 and 78–83 <../data/chats/bohmian-mechanics-and-navier-stokes-and-nonlinearity.md>`) against what is actually defined and proved in `Signals.NavierStokes` and the runtime solvers:

| Fluid quantity or channel | Plücker minor(s) (0-based / 1-based) | Source-chat proposal (`lines 62–70, 78–83`) | Mapping in the verified `Signals.NavierStokes` & Rust/PyO3 model |
| --- | --- | --- | --- |
| Primal–dual density determinant / nodal chart marker | $p_{01}$ ($p_{12}$) | Effective density $\rho_{\mathrm{eff}}$ (used as denominator in $\mathbf{v}$) | $p_{01} = \psi_1\tilde\psi_2 - \tilde\psi_1\psi_2$; its zero set $\Sigma_1 = \{p_{01} = 0\}$ is the Schubert divisor triggering $\Omega_0 \to \Omega_{02}$. Physical fluid density $\rho$ is **not** defined as $p_{01}$ or $\lvert p_{01}\rvert$ (in `Compressible.lean`, $\rho > 0$ is an explicit positive scalar field; in `Incompressible.lean`, $\rho = \rho_0$). |
| Same-component first-jet conjugate pair | $p_{02}, p_{13}$ ($p_{13}, p_{24}$) | Longitudinal momentum flux $\rho\mathbf{v}_\parallel$ ($v_x \propto \operatorname{Im}\frac{p_{13}+p_{24}}{p_{12}}$) | $p_{02} = \psi_1(D_1\tilde\psi_1) - \tilde\psi_1(D_1\psi_1)$ and $p_{13} = \psi_2(D_2\tilde\psi_2) - \tilde\psi_2(D_2\psi_2)$. Their product $p_{02}p_{13}$ is the first term in the Klein quadric; $p_{02} \ne 0$ defines the regular adjacent chart $\Omega_{02}$ (`schubert_chart_transition_omega0_to_omega02`). Not directly equated to $\rho\mathbf{v}_\parallel$. |
| Cross-component first-jet conjugate pair | $p_{03}, p_{12}$ ($p_{14}, p_{23}$) | Transverse vorticity & helicity $\boldsymbol{\omega}, \mathbf{v}\cdot\boldsymbol{\omega}$ ($v_y \propto \operatorname{Im}\frac{p_{14}-p_{23}}{p_{12}}$) | $p_{03} = \psi_1(D_2\tilde\psi_2) - \tilde\psi_1(D_2\psi_2)$ and $p_{12} = \psi_2(D_1\tilde\psi_1) - \tilde\psi_2(D_1\psi_1)$. Their product $p_{03}p_{12}$ is the second term in the Klein quadric; on $\Sigma_1 = \{p_{01}=0\}$, $p_{02}p_{13} = p_{03}p_{12}$. Not directly equated to $\boldsymbol{\omega}$ or helicity. |
| Pure first-jet stress / cancellation minor | $p_{23}$ ($p_{34}$) | Quantum & viscous stress tensor ($\nabla Q, S_{ij}$; note chat line 67 wrote $\partial_x$ in both rows, while line 69 used $\partial_y$ in row 4) | $p_{23} = (D_1\psi_1)(D_2\tilde\psi_2) - (D_1\tilde\psi_1)(D_2\psi_2)$. Enters $p_{02}p_{13} - p_{03}p_{12} = p_{01}p_{23}$ as the exact $1/p_{01}^2 \to p_{23}/p_{01}$ cancellation numerator in `jetFrame_klein_quadric_cancellation`, not by itself a defined viscous or quantum stress tensor. |
| Velocity $\mathbf{v}$ | No single minor | Ratios $\operatorname{Im}((p_{13}+p_{24})/p_{12})$ and $\operatorname{Im}((p_{14}-p_{23})/p_{12})$ | Reconstructed in the Clebsch-spinor lift ({download}`PluckerFrame.lean, lines 129–139 <../src/signals/Signals/NavierStokes/PluckerFrame.lean>`) from the Berry connection $v_\mu = (\hbar/m)A_\mu$ with $A_\mu = \cos^2(\theta/2)\partial_\mu\phi_1 + \sin^2(\theta/2)\partial_\mu\phi_2$ (Section 2.3); in `IncompressibleDualSchubertSolver2D` ({download}`navier_stokes.rs, lines 997–1060 <../src/signals/numerical_adapter/src/navier_stokes.rs>`), $(u, v, \omega, 1)$ is normalized into the projective ray $\hat{p} \in S^3 \subset \mathbb{C}\mathbb{P}^5$ to evaluate $g_{\mu\nu}^{\mathrm{FS}}$ and $F_{\mu\nu} = 4g_{\mu\nu}^{\mathrm{FS}}$. |
| Vorticity $\boldsymbol{\omega}$ | No single minor | Paired with $(p_{14}, p_{23})$ | Derived as the curl of the Berry velocity ({download}`PluckerFrame.lean, lines 134–245 <../src/signals/Signals/NavierStokes/PluckerFrame.lean>`): $\omega_z = \frac{\hbar}{2m}\sin\theta\,(\partial_x\theta\,\partial_y(\phi_2-\phi_1) - \partial_y\theta\,\partial_x(\phi_2-\phi_1))$, not a single Plücker minor. |
| Quantum potential $Q$, Korteweg stress $\mathbf{K}$, pressure $P$, and viscosity $(\nu, \mu, \zeta)$ | No single minor | Grouped under $p_{34}$ and an off-diagonal $\pm i\hbar\nu\nabla^2$ block | $Q$ and $K_{xx} = \frac{\hbar^2}{4m^2}(\rho_{xx} - \rho_x^2/\rho)$ are explicit density-derivative functionals (`Compressible.lean`, Section 4); $P$ is a barotropic equation of state or Helmholtz–Leray constraint multiplier; $\nu, \mu, \zeta$ are constitutive coefficients entering the Bateman doubled diagonal operator (Section 2.2) and $\Phi_{\mathrm{visc}} \ge 0$ (Section 4). |

This table separates the chat's proposed heuristics from the verified theorems of {download}`Signals.NavierStokes.PluckerFrame <../src/signals/Signals/NavierStokes/PluckerFrame.lean>` so that unproved minor identifications are not mistaken for machine-checked identities.

When a vortex core hits the codimension-1 Schubert divisor $\Sigma_1 = \{p_{01} = 0\}$, `schubert_chart_transition_omega0_to_omega02` proves that $p_{02} p_{13} = p_{03} p_{12}$, and whenever $p_{02} \ne 0$ the adjacent chart $\Omega_{02}$ coordinates $u_{ij} = p_{ij}/p_{02}$ remain smooth and finite across $p_{01} = 0$, satisfying $u_{13} = u_{03} u_{12} + u_{01} u_{23}$ and agreeing with $\Omega_0$ on $\Omega_0 \cap \Omega_{02}$ via $(p_{23}/p_{02})/(p_{01}/p_{02}) = p_{23}/p_{01}$. Evaluating a nodal frame at $p_{01} = 0$ in `navier_stokes.rs` confirms Klein residual `0.0`, automatic transition to $\Omega_{02}$, and finite strictly positive projective QFIM $F_Q = 3.051979$.

### 2.2 Repair 2 — Hermiticity Defect in $\mathcal{H}_{\mathrm{eff}}$ vs. Corrected Bateman Doubled Operator

Lines 99–101 of the source chat proposed coupling primal and dual channels with off-diagonal viscous blocks $\begin{pmatrix} 0 & -i\hbar\nu\nabla^2 \\ +i\hbar\nu\nabla^2 & 0 \end{pmatrix}$. In Fourier space ($-\nabla^2 \mapsto k^2$), this gives:

$$
H_{\mathrm{chat}}(E, \hbar, \nu, k) = \begin{pmatrix} E & +i\hbar\nu k^2 \\ -i\hbar\nu k^2 & E \end{pmatrix}.
$$

Both `chat_offdiag_viscous_matrix_is_hermitian` (Lean 4) and `chat_defect2_hermitian_zero_dissipation` (SymPy) prove that $H_{\mathrm{chat}}^\dagger = H_{\mathrm{chat}}$ is **strictly Hermitian**, so $\frac{d}{dt}(|\psi|^2 + |\tilde{\psi}|^2) = 0$ identically — producing norm-preserving Rabi-like mixing rather than viscous dissipation.

Replacing $H_{\mathrm{chat}}$ with the **Bateman / Keldysh doubled diagonal operator** {cite:p}`bateman1931dissipative`:

$$
H_{\mathrm{Bateman}}(E, \hbar, \nu, k) = \begin{pmatrix} E - i\hbar\nu k^2 & 0 \\ 0 & E + i\hbar\nu k^2 \end{pmatrix},
$$

`bateman_doubled_viscous_pairing_conserved_and_primal_dissipates` proves all three physical requirements simultaneously:
1. Primal energy decays at the exact Navier–Stokes viscous rate $\frac{d}{dt}|\psi|^2 = -2\nu k^2 |\psi|^2 \le 0$;
2. Dual energy grows symmetrically at $+2\nu k^2 |\tilde{\psi}|^2$;
3. The indefinite primal–dual symplectic pairing $\overline{\tilde{\psi}}\,\psi$ is identically conserved: $\frac{d}{dt}(\overline{\tilde{\psi}}\,\psi) = 0$.

### 2.3 Continuous Vorticity from a 2-Component Clebsch Spinor Lift

Scalar Madelung flow $\mathbf{v} = \frac{\hbar}{m}\nabla S$ is strictly irrotational ($\nabla \times \mathbf{v} = \mathbf{0}$) wherever $\rho > 0$. Lifting to a unit 2-component Clebsch spinor $\hat{\psi}(\theta, \phi_1, \phi_2) = (\cos(\theta/2)e^{i\phi_1}, \sin(\theta/2)e^{i\phi_2}) \in \mathbb{C}^2 \hookrightarrow \mathbb{C}^6$ (`clebschSpinor`), `clebsch_spinor_berry_and_qfim` proves:

$$
\langle\hat{\psi}, \partial_\mu\hat{\psi}\rangle = i\Bigl(\cos^2\!\frac{\theta}{2}\,\partial_\mu\phi_1 + \sin^2\!\frac{\theta}{2}\,\partial_\mu\phi_2\Bigr), \qquad F_{\mu\mu} = 4\,g_{\mu\mu}^{\mathrm{FS}} = (\partial_\mu\theta)^2 + \sin^2\theta\,(\partial_\mu\phi_1 - \partial_\mu\phi_2)^2,
$$

and `clebsch_berry_vorticity_nonzero` proves that the curl of $\mathbf{v} = \frac{\hbar}{m}\mathbf{A}_{\mathrm{Berry}}$ yields continuous nonzero vorticity:

$$
\omega_z = \partial_x v_y - \partial_y v_x = \frac{\hbar}{2m}\sin\theta\,\Bigl(\partial_x\theta\,\partial_y(\phi_2 - \phi_1) - \partial_y\theta\,\partial_x(\phi_2 - \phi_1)\Bigr),
$$

with explicit witness $\omega_z = \frac{\hbar}{2m} > 0$ at $\theta = \pi/2$ {cite:p}`chern2016schrodinger`.

---

## 3. Incompressible Navier–Stokes (`Incompressible.lean`, `Ch. 2 = 0`)

In an incompressible Newtonian fluid ($\rho = \rho_0 > 0$, $\nabla\rho = \mathbf{0}$, $\nabla\cdot\mathbf{v} = 0$), `incompressible_channel2_vanishes` proves that Channel 2 of `three_channel_plucker_madelung_qfim` vanishes identically:

$$
\|d\Psi\|^2 = \rho_0\,\bigl(\operatorname{Im}\langle\hat{p}, d\hat{p}\rangle\bigr)^2 + 0 + \rho_0\,\frac{F_Q(\hat{p}, d\hat{p})}{4}.
$$

Across the 6-channel Dual-Schubert product $\mathrm{Gr}_{\mathbb{C}}(2,4) \times \mathrm{Gr}_{\mathbb{C}}(2,4)^\vee$, `incompressible_dual_schubert_energy_enstrophy_split` cleanly separates primal hydrodynamic kinetic energy from dual projective QFIM / vorticity-enstrophy dissipation, while pressure $P$ enforces $\nabla\cdot\mathbf{v} = 0$ as the $\mathrm{U}(1)$ Helmholtz–Leray gauge multiplier.

Using Mathlib's `deriv` and `iteratedDeriv 2` directly (zero algebraic shortcuts), `Signals.NavierStokes.Incompressible` proves four canonical exact incompressible Navier–Stokes benchmarks:

1. **2D Taylor–Green Decaying Vortex (`taylorGreen2D_solves_incompressible_ns`)** {cite:p}`taylor1937mechanism`:

$$
u = U_0\cos(kx)\sin(ky)\,e^{-2\nu k^2 t}, \qquad v = -U_0\sin(kx)\cos(ky)\,e^{-2\nu k^2 t},
$$

$$
P = -\frac{\rho_0 U_0^2}{4}\bigl(\cos(2kx) + \cos(2ky)\bigr)e^{-4\nu k^2 t}, \qquad \frac{dE}{dt} = -2\nu\,\mathcal{Z} = -4\nu k^2 E.
$$

2. **2D Lamb–Oseen Viscous Vortex (`lambOseen2D_vorticity_heat_pde`):** Proves $\partial_t\omega = \nu(\partial_x^2\omega + \partial_y^2\omega)$ for $\omega(x,y,t) = \frac{\Gamma}{4\pi\nu t}\exp\!\bigl(-\frac{x^2+y^2}{4\nu t}\bigr)$ and finite positive core vorticity $\omega(0,0,t) = \frac{\Gamma}{4\pi\nu t} > 0$ for all $t > 0$.
3. **Plane Poiseuille Viscous Shear Flow (`poiseuille_solves_incompressible_ns`):** Proves $u(\pm h) = 0$ and $\mu\,\partial_y^2 u + G = 0$ for $u(y) = \frac{G}{2\mu}(h^2 - y^2)$.
4. **3D Decaying Beltrami / ABC Rotational Vortex Flow (`beltramiABC_solves_3d_incompressible_ns`):** For $(u, v, w) = (A\sin kz + C\cos ky,\; B\sin kx + A\cos kz,\; C\sin ky + B\cos kx)\,e^{-\nu k^2 t}$ with Bernoulli pressure $P = -\frac{1}{2}\rho_0(u^2 + v^2 + w^2)$, proves all 9 exact 3D PDE identities: $\nabla\times\mathbf{v} = k\mathbf{v}$ (vanishing Lamb vector $\boldsymbol{\omega}\times\mathbf{v} = \mathbf{0}$, nonzero helicity $\mathbf{v}\cdot\boldsymbol{\omega} = k\|\mathbf{v}\|^2$), $\Delta\mathbf{v} = -k^2\mathbf{v}$, and $\partial_t\mathbf{v} + (\mathbf{v}\cdot\nabla)\mathbf{v} + \frac{1}{\rho_0}\nabla P - \nu\Delta\mathbf{v} = \mathbf{0}$.

---

## 4. Compressible Navier–Stokes & Navier–Stokes–Korteweg (`Compressible.lean`, `Ch. 1 + 2 + 3`)

When density varies ($\rho(x, t) > 0$, $\nabla\rho \ne \mathbf{0}$), **all three channels** of the Plücker–Madelung–QFIM decomposition are active. `Signals.NavierStokes.Compressible` machine-checks five structural theorems:

1. **3D Compressible Viscous Dissipation Positivity & Stokes' Hypothesis (`compressible_viscous_dissipation_nonneg`):** For shear viscosity $\mu \ge 0$, bulk viscosity $\zeta \ge 0$, and Lamé second viscosity $\lambda = \zeta - \frac{2}{3}\mu$:

$$
\Phi_{\mathrm{visc}} = \frac{2\mu}{3}\Bigl((s_{11}-s_{22})^2 + (s_{22}-s_{33})^2 + (s_{33}-s_{11})^2\Bigr) + 4\mu\bigl(s_{12}^2 + s_{13}^2 + s_{23}^2\bigr) + \zeta\,(s_{11}+s_{22}+s_{33})^2 \ge 0.
$$

2. **Exact Korteweg Capillary Stress Divergence (`korteweg_stress_div_eq_quantum_force`)** {cite:p}`korteweg1901forme`: Rewrites the Bohmian quantum potential force in exact conservative flux form for finite-volume solvers:

$$
-\frac{\rho}{m}\,\partial_x Q = \partial_x K_{xx}, \qquad K_{xx} = \frac{\hbar^2}{4m^2}\left(\rho_{xx} - \frac{\rho_x^2}{\rho}\right).
$$

3. **Bresch–Desjardins Dual-Schubert QFIM Equivalence (`breschDesjardins_dual_schubert_qfim_split`)** {cite:p}`bresch2003existence`: Under density-dependent viscosity $\mu(\rho) = \nu\rho$ (matching {download}`data/chats/bohmian-mechanics-and-navier-stokes-and-nonlinearity.md <../data/chats/bohmian-mechanics-and-navier-stokes-and-nonlinearity.md>`, line 76), the forward/backward Bresch–Desjardins effective velocities $v_\pm = v \pm \nu\frac{\rho_x}{\rho}$ satisfy:

$$
\frac{1}{2}\,\rho\,(v_+^2 + v_-^2) = \rho v^2 + \nu^2\frac{\rho_x^2}{\rho},
$$

and at the quantum kinematic viscosity $\nu = \frac{\hbar}{2m}$ with $v = \frac{\hbar}{m}\operatorname{Im}\langle\hat{p}, \partial_x\hat{p}\rangle$:

$$
\frac{m}{2}\cdot\frac{1}{2}\rho(v_+^2 + v_-^2) + \frac{\hbar^2}{8m}\,\rho\,F_{xx}(\hat{p}, \partial_x\hat{p}) = \frac{\hbar^2}{2m}\|\partial_x\Psi\|^2.
$$

Thus the Bresch–Desjardins effective velocity pair is literally the compressible Dual-Schubert realization of Channels 1 and 2 of our QFIM decomposition.

4. **Cole–Hopf Linearization & Exact Moving Viscous Burgers Tanh Shock (`coleHopf_heat_implies_viscous_burgers`, `burgers_tanh_shock_solves_pde`)** {cite:p}`cole1951quasilinear,hopf1950partial`: Proves that any positive 1D heat solution $\tau_t = \nu\tau_{xx}$ maps via $v = -2\nu\tau_x/\tau$ to the nonlinear viscous Burgers equation $v_t + v v_x = \nu v_{xx}$, and proves full `deriv` / `iteratedDeriv 2` PDE satisfaction for the moving shock $v(x, t) = c - a\tanh\!\bigl(\frac{a}{2\nu}(x - ct)\bigr)$ (linking directly to 2-exponential Sato $\tau$-functions from Companion Paper 51).
5. **Linearized Compressible Stokes Acoustic Dispersion (`stokes_acoustic_attenuation_dispersion`):** For sound diffusivity $\delta = \frac{4}{3}\nu + \frac{\zeta}{\rho_0} \ge 0$ in the underdamped regime $\delta^2 k^4 / 4 \le c_s^2 k^2$, proves that $\omega_+ = \sqrt{c_s^2 k^2 - \delta^2 k^4 / 4} - \frac{i}{2}\delta k^2$ solves $\omega_+^2 + i\delta k^2\omega_+ - c_s^2 k^2 = 0$ with causal viscous attenuation $\operatorname{Im}(\omega_+) = -\frac{1}{2}\delta k^2 \le 0$.

---

## 5. Lean 4 & Rust/PyO3 Implementation Excerpts and Tri-Language Verification Table

### 5.1 Lean 4 Core Theorem Signatures (`Signals.NavierStokes`)

```lean
-- From Signals.NavierStokes.Compressible:
theorem breschDesjardins_dual_schubert_qfim_split
    {ℏ m ρ dρ : ℝ} (hℏ : 0 < ℏ) (hm : 0 < m) (hρ : 0 < ρ)
    (ν v : ℝ) {p dp : Plucker6} (hp : ‖p‖ = 1) (htang : (⟪p, dp⟫_ℂ).re = 0) :
    let dΨ : Plucker6 := (((dρ / (2 * Real.sqrt ρ) : ℝ) : ℂ) • p) + ((Real.sqrt ρ : ℂ) • dp)
    let v_q : ℝ := (ℏ / m) * (⟪p, dp⟫_ℂ).im
    let ν_q : ℝ := ℏ / (2 * m)
    ((1 / 2 : ℝ) * ρ * (bdVelocityPlus v ν ρ dρ ^ 2 + bdVelocityMinus v ν ρ dρ ^ 2) =
      ρ * v ^ 2 + ν ^ 2 * (dρ ^ 2 / ρ)) ∧
    ((m / 2) * ((1 / 2 : ℝ) * ρ *
        (bdVelocityPlus v_q ν_q ρ dρ ^ 2 + bdVelocityMinus v_q ν_q ρ dρ ^ 2)) +
      (ℏ ^ 2 / (8 * m)) * ρ * qfim p dp =
      (ℏ ^ 2 / (2 * m)) * ‖dΨ‖ ^ 2)
```

### 5.2 Rust/PyO3 Structure-Preserving Solvers (`navier_stokes.rs`)

- **`IncompressibleDualSchubertSolver2D`**: Pure-Rust 2D periodic spectral Helmholtz–Leray projection solver (`2/3` Orszag dealiased rotational form $\mathbf{v}\times\boldsymbol{\omega}$, exact Leray projector $P = I - \mathbf{k}\mathbf{k}^T/|\mathbf{k}|^2$, RK2 integration) enforcing $\max|\nabla\cdot\mathbf{v}| < 10^{-13}$, exact `ch2_osmotic_energy = 0.0`, genuine unit-normalized 2D projective Plücker QFIM evaluation (`qfim_trace = 4 * fubini_study_trace`, `qfim_fs_ratio_residual = 0.0`, strictly separated in physical units from fluid enstrophy), Schubert chart $\Omega_{02}$ cell tracking at vortex cores, and both single-mode Taylor–Green and genuinely nonlinear multi-mode vortex-pair initializers.
- **`CompressibleNskDualSchubertSolver1D`**: Pure-Rust 1D periodic finite-volume solver for barotropic NS/NSK ($\mu(\rho) = \nu_{\mathrm{BD}}\rho$, bulk $\zeta$, conservative Korteweg stress $K_{xx} = \kappa_K(\rho_{xx} - \rho_x^2/\rho)$) supporting both shock-capturing Rusanov (`step_rk2`) and zero-artificial-diffusion 2nd-order central (`step_central_rk2`) SSP-RK2 stepping, conserving mass and momentum to machine precision, auditing the Bresch–Desjardins Dual-Schubert identity at every step, and reproducing the exact Bogoliubov–Korteweg–Stokes physical damping law over a full acoustic period to `0.0317%`.

### 5.3 Tri-Language Verification Summary

| Verification Benchmark | Fluid Regime | Lean 4 Theorem (Zero `sorry`) | SymPy Exact Proof | Rust/PyO3 Measured Metric |
| --- | --- | --- | --- | --- |
| $4\times 2$ Jet Frame & $\Sigma_1 \to \Omega_{02}$ Node | Projective $\mathrm{Gr}_{\mathbb{C}}(2,4)$ | `schubert_chart_transition_omega0_to_omega02` | `schubert_omega02_chart_identity_exact` | Klein res `0.0`, node $F_Q = 3.051979$ |
| Chat Defect #2 vs. Bateman Viscous Operator | Dual-Schubert $\mathrm{Gr}(2,4)\times\mathrm{Gr}(2,4)^\vee$ | `bateman_doubled_viscous_pairing_conserved_and_primal_dissipates` | `chat_defect2_hermitian_zero_dissipation` | Chat rate `1.11e-16`; Bateman pair `1.78e-16` |
| Grassmannian Riccati Tangent Projection | Non-Hermitian Stiefel $V_2(\mathbb{C}^4)$ | `riccati_grassmann_projection_orthogonal` | `riccati_grassmann_projection_orthogonal_exact` | $Z^\dagger\dot{Z}$ `2.00e-16`; Gram rate `2.60e-16` |
| 2-Spinor Clebsch Curl Vorticity & $F_Q = 4 g_{\mathrm{FS}}$ | Rotational Incompressible | `clebsch_spinor_berry_and_qfim`, `clebsch_berry_curl_eq_vorticityZ` | `clebsch_berry_vorticity_exact` | $\omega_z = 0.5$, QFIM res `0.0` |
| 2D Taylor–Green Decaying Vortex (Analytic) | Incompressible NS | `taylorGreen2D_solves_incompressible_ns` | `taylor_green_2d_incompressible_ns_exact` | Max PDE res `2.78e-17`, Ch. 2 `0.0` |
| 2D Lamb–Oseen Heat PDE, Curl Recovery, & ISF Gap | Incompressible NS / ISF | `lambOseen2D_vorticity_heat_pde`, `lambOseen_velocity_recovers_vorticity`, `isf_spin_tension_vs_classical_incompressible_ns` | `lamb_oseen_2d_vorticity_heat_exact`, `lamb_oseen_azimuthal_curl_recovery_exact` | Heat res `0.0`, curl res `6.94e-18` |
| 3D Decaying Beltrami / ABC Vortex | 3D Incompressible NS | `beltramiABC_solves_3d_incompressible_ns` | `beltrami_abc_3d_incompressible_ns_exact` | Max 3D res `4.44e-16` |
| 3D Compressible $\Phi_{\mathrm{visc}} \ge 0$, Calculus Korteweg, BD, Stokes | Compressible NS / NSK | `compressible_viscous_dissipation_nonneg`, `korteweg_stress_div_eq_quantum_force_calculus`, `breschDesjardins_dual_schubert_qfim_split`, `stokes_acoustic_attenuation_dispersion` | `korteweg_stress_div_eq_quantum_force_exact`, `bresch_desjardins_dual_schubert_split_exact`, `stokes_acoustic_dispersion_exact` | Max residual `1.78e-15`, $\operatorname{Im}(\omega) < 0$ |
| Bogoliubov–Korteweg–Stokes (`Signals.DDF` Bridge) & Rankine–Hugoniot | Compressible NSK / DDF | `compressible_nsk_bogoliubov_stokes_dispersion`, `rankine_hugoniot_compressible_jump` | `bogoliubov_korteweg_stokes_and_ddf_bridge_exact`, `rankine_hugoniot_compressible_jump_exact` | Max disp / DDF / RH res `4.44e-16` |
| Moving Viscous Burgers Shock & Cole–Hopf $\tau$ | Compressible 1D Burgers | `coleHopf_heat_implies_viscous_burgers`, `burgers_tanh_shock_solves_pde` | `viscous_burgers_tanh_shock_exact` | Max Burgers / $\tau$ res `1.11e-16` |
| 2D Spectral Solver (`16×16`, Taylor–Green + Multi-Mode) | Incompressible NS Solver | — (runtime discretization of `Incompressible.lean`) | RK2 $O(\Delta t^2)$ convergence + true projective QFIM | TG $L^2$ `4.27e-08`, multi-mode $\max\|\nabla\cdot\mathbf{v}\| = 1.19 \times 10^{-14}$, $F_Q/g_{\mathrm{FS}}$ res `0.0`, Ch. 2 `0.0` |
| 1D Finite-Volume NSK Solver (`N=64`, Rusanov + Central) | Compressible NSK Solver | — (runtime discretization of `Compressible.lean`) | Mass/momentum, BD, & Stokes damping verified | Mass drift `8.88e-16`, BD res `1.73e-18`, central Stokes damping err `0.0317%` |

---

## 6. Epistemic Pending Boundary (`DualSchubertNavierStokesPendingBoundary`)

In `Signals.Pending.DualSchubertNavierStokesPendingBoundary`, we isolate four open gates that are explicitly **not** closed by this work (`dual_schubert_ns_identities_do_not_close_millennium_or_physical_claims`):

1. **Clay Millennium 3D Global Regularity / Blowup (`millennium3DGlobalRegularityProved`):** Smooth Schubert chart transitions $\Omega_0 \leftrightarrow \Omega_{02}$ remove **Madelung coordinate denominators** ($1/p_{01}$) at density nodes; they do **not** establish global-in-time smooth bounds on $\|\nabla\mathbf{v}\|_{L^\infty}$ for arbitrary 3D divergence-free smooth initial data {cite:p}`fefferman2006existence`.
2. **General 3D Hirota Linearization (`global3DHirotaLinearizationEstablished`):** Unlike 1D viscous Burgers (Cole–Hopf) or $(2+1)$-D KP-II (Companion Paper 51), general 3D Navier–Stokes is non-integrable and is **not** reduced to a constant-coefficient linear PDE by the Klein quadric.
3. **Turbulence & Subgrid Closure (`turbulenceSubgridClosureValidated`):** Low-rank Plücker or Dual-Schubert truncations do not close the Reynolds stress tensor at high Reynolds number without empirical/DNS validation.
4. **Experimental Laboratory Telemetry (`experimentalFluidTelemetryValidated`):** Connecting Dual-Schubert QFIM spin-stress, Korteweg capillarity, or DDF dilatant viscosity to physical fluids requires calibrated PIV/LDV or superfluid/optical velocimetry measurements.

---

## 7. Reproducibility Commands

```bash
# 1. Verify all 3 Signals.NavierStokes modules, Pending boundary, and tests (3,834 Lake jobs)
make signals_build

# 2. Run Rust unit tests (170 total, 14 in navier_stokes) and build/install the PyO3 extension
cargo test --manifest-path src/signals/numerical_adapter/Cargo.toml navier_stokes
maturin develop --manifest-path src/signals/numerical_adapter/Cargo.toml --release --features extension-module

# 3. Run the 20 exact SymPy proofs + PyO3 analytical & time-marching solver tests
pytest -q tests/test_navier_stokes_dual_schubert_qfim.py
```

---

## References

```{bibliography}
:filter: docname in docnames
:list: bullet
```

---

### BibTeX Citation

```bibtex
@unpublished{turner2026dual_schubert_qfim_navier_stokes,
  author  = {Turner, Wesley},
  title   = {Compressible and Incompressible {N}avier--{S}tokes via Three-Channel {P}l{\"u}cker--{M}adelung and Six-Channel {D}ual-{S}chubert {QFIM} ({$F_{\mu\nu} = 4\,g_{\mu\nu}^{\mathrm{FS}}$}): {C}lebsch Spinor Vorticity, {S}chubert Chart Regularization, {B}ateman Viscous Audit, {K}orteweg Stress, and {B}resch--{D}esjardins Equivalence in {L}ean 4, {R}ust/{PyO3}, and {S}ym{P}y},
  journal = {Sustainable Factory Research Archive},
  year    = {2026},
  note    = {Verified in Lean 4 (v4.35.0-rc3), Rust/PyO3, and SymPy}
}
```

### Schema.org Metadata (JSON-LD)

```json
{
  "@context": "https://schema.org",
  "@type": "ScholarlyArticle",
  "name": "Compressible and Incompressible Navier-Stokes via Three-Channel Plucker-Madelung and Six-Channel Dual-Schubert QFIM (F_uv = 4 g^FS_uv) in Lean 4, Rust/PyO3, and SymPy",
  "author": {
    "@type": "Person",
    "name": "Wes Turner"
  },
  "datePublished": "2026-11-21",
  "about": [
    "Incompressible Navier-Stokes Equations",
    "Compressible Navier-Stokes-Korteweg Equations",
    "Six-Channel Dual-Schubert Quantum Fisher Information Metric (QFIM)",
    "Clebsch Spinor Berry Vorticity",
    "Bresch-Desjardins Effective Velocity",
    "Lean 4 Formal Verification"
  ],
  "isBasedOn": [
    "data/chats/bohmian-mechanics-and-navier-stokes-and-nonlinearity.md",
    "docs/dual-schubert-qfim-navier-stokes-plan.md",
    "docs/grassmannian-sato-hilbert-space-kp-pde-solver-akns-qfim-paper.md",
    "docs/grassmannian-qfim-fubini-study-kahler-madelung-unification-paper.md"
  ]
}
```
