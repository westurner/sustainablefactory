---
title: "Written Plan: Compressible & Incompressible Navier–Stokes via Three-Channel Plücker–Madelung and Six-Channel Dual-Schubert QFIM (F_μν = 4 g^FS_μν) in Lean 4, Rust/PyO3, and SymPy"
description: "Phased implementation and formal verification plan uniting incompressible and compressible Navier–Stokes / Navier–Stokes–Korteweg (NSK) fluid dynamics with the Three-Channel Plücker–Madelung and Six-Channel Dual-Schubert Quantum Fisher Information Metric (QFIM) stack across Lean 4 (Signals.NavierStokes), Rust/PyO3 numerical solvers, SymPy symbolic verification, and an arXiv-ready MyST Markdown paper."
---

(dual-schubert-qfim-navier-stokes-plan)=
# Written Plan: Compressible & Incompressible Navier–Stokes via Three-Channel Plücker–Madelung and Six-Channel Dual-Schubert QFIM ($F_{\mu\nu} = 4\,g_{\mu\nu}^{\mathrm{FS}}$)

- **Author:** Wes Turner
- **Planned Owning Paper:** `docs/grassmannian-dual-schubert-qfim-navier-stokes-compressible-incompressible-paper.md` (Paper 53)
- **Companion Papers Reused:**
  - [Formalizing the Infinite-Dimensional Sato Grassmannian $\mathrm{Gr}_p(H)$, Plabic $\mathrm{Gr}_{\ge 0}(2,4)$ KP-II / KdV / AKNS Soliton PDE Solvers, Baker–Akhiezer Lax Pairs, and 6-Channel Dual-Schubert QFIM in Lean 4, Rust/PyO3, and SymPy](grassmannian-sato-hilbert-space-kp-pde-solver-akns-qfim-paper.md)
  - [Why the Quantum Fisher Information Metric Is Four Times the Fubini–Study Kähler Metric ($F_{\mu\nu} = 4\,g_{\mu\nu}^{\mathrm{FS}}$)](grassmannian-qfim-fubini-study-kahler-madelung-unification-paper.md)
  - [Complex Grassmannian $\mathrm{Gr}_{\mathbb{C}}(2,4)$ Fubini–Study Gross–Pitaevskii Equation, Dual-Schubert `iGPE`, and Homogeneous Plücker Madelung Hydrodynamics on the Klein Quadric $\mathcal{Q}_4$](grassmannian-complex-gpe-igpe-plucker-madelung-paper.md)
  - [From Superfluid Gross–Pitaevskii Action and Madelung Polar Substitution to Euler–Lagrange Hydrodynamics and Dilatant Dark Fluid (DDF) Jamming Recovery](grassmannian-madelung-lagrangian-ddf-jamming-paper.md)
  - [Quantum Trajectories in Complex Grassmannian $\mathrm{Gr}_{\mathbb{C}}(k,n)$, Three-Channel Plücker–Madelung–QFIM ($F_{\mu\nu} = 4\,g_{\mu\nu}^{\mathrm{FS}}$), Dual-Schubert `iGPE`, and Dilatant Dark Fluid (`DDF`) Mechanics](grassmannian-quantum-trajectories-bohmian-weak-nonlinear-optics-paper.md)
- **Primary Source Chat Provenance:**
  - {download}`data/chats/bohmian-mechanics-and-navier-stokes-and-nonlinearity.md <../data/chats/bohmian-mechanics-and-navier-stokes-and-nonlinearity.md>` (`216` lines, `sha256: d575c8992e1398f02228d62d4300a223d8efd0f4e1b82c929e2c72401897bea0`; lines `1–140` primary derivation, lines `143–216` duplicate paste).

---

## 1. Audit of the Source Chat & Epistemic Boundaries

Before implementing any Lean 4 or numerical code, an audit of `data/chats/bohmian-mechanics-and-navier-stokes-and-nonlinearity.md` identifies **three mathematical defects or overclaims** that must be proved, corrected, and explicitly bounded:

1. **Defect 1 — Matrix-Shape Mismatch in the $4\times 2$ Stiefel Frame (lines 57–71):**
   Line 57 equates a $4\times 2$ matrix $(z_{ij})$ to a $2\times 2$ block $(\psi_a, \tilde{\psi}_a)$, while lines 63–71 define rows 3 and 4 as spatial derivatives $\partial_x\psi, \partial_y\psi$.
   - **Resolution:** Formalize an explicit $4\times 2$ 1-jet Stiefel frame $Z \in \mathbb{C}^{4\times 2}$ (with upper $2\times 2$ Clebsch/dual spinor block and lower $2\times 2$ covariant derivative block) whose six Plücker minors $p_{ij} = z_{i1}z_{j2} - z_{i2}z_{j1}$ satisfy the Klein quadric $p_{01}p_{23} - p_{02}p_{13} + p_{03}p_{12} = 0$ identically, alongside a 2-component Clebsch/Pauli spinor lift $\psi = (\psi_1, \psi_2)^T$ carrying non-zero continuous vorticity $\boldsymbol{\omega} = \nabla\times\mathbf{v} = \frac{\hbar}{m}\Omega_{\mathrm{Berry}} \ne 0$.
2. **Defect 2 — Hermiticity Sign Error in the Proposed Viscous Operator $\mathcal{H}_{\mathrm{eff}}$ (lines 99–101):**
   Line 100 writes the off-diagonal viscous block as $\begin{pmatrix} 0 & -i\hbar\nu\nabla^2 \\ +i\hbar\nu\nabla^2 & 0 \end{pmatrix}$. Because $\nabla^2$ is formally self-adjoint, $(-i\hbar\nu\nabla^2)^\dagger = +i\hbar\nu\nabla^2$, making this block **Hermitian** (norm-preserving Rabi-like dispersion rather than viscous dissipation).
   - **Resolution:** Machine-check in Lean 4 and SymPy that the chat's off-diagonal block is Hermitian with zero net dissipation, and replace it with the genuine **Bateman / Keldysh doubled anti-Hermitian viscous operator** $\operatorname{diag}(+i\hbar\nu\nabla^2, -i\hbar\nu\nabla^2)$, which preserves the indefinite primal–dual pairing $\langle\tilde{\psi}, \psi\rangle$ while dissipating primal energy at rate $-2\nu\int\lvert\nabla\psi\rvert^2$, paired with the exact Navier–Stokes viscous stress tensor $\nabla\cdot\boldsymbol{\tau}_{\mathrm{visc}}$.
3. **Defect 3 — Overclaim on Constant-Coefficient Hirota Linearization & 3D Blowup Resolution (lines 82–91, 111–133):**
   The Klein quadric removes **Madelung coordinate denominators** ($1/p_{12}$ across the Schubert divisor $\Sigma_1 = \{p_{12} = 0\} \to \Omega_{13}$) and linearizes 1D viscous Burgers via Cole–Hopf ($v = -2\nu\partial_x\ln\tau$), **not** general 3D Navier–Stokes into a constant-coefficient Hirota equation, and does **not** prove Clay Millennium 3D global regularity or finite-time blowup avoidance.
   - **Resolution:** Isolate 3D Clay Millennium regularity, turbulence closure, and physical DDF/evanescent-fluid calibration in `Signals.Pending.DualSchubertNavierStokesPendingBoundary`.

---

## 2. Unified Mathematical Architecture: Dual-Schubert QFIM to Incompressible & Compressible Navier–Stokes

Building directly on `Signals.SatoGrassmannian.DualSchubertQFIM` (`three_channel_plucker_madelung_qfim`, `dual_schubert_six_channel_decomposition`) and `Signals.DFT` Section 27 ($F_{\mu\nu} = 4\,g_{\mu\nu}^{\mathrm{FS}}$), a normalized Plücker / Clebsch-spinor fluid state $\Psi = \sqrt{\rho}\,\hat{p}$ ($\|\hat{p}\| = 1$) obeys:

$$
\frac{\hbar^2}{2m}\|\nabla\Psi\|^2 = \underbrace{\frac{1}{2}m\rho\|\mathbf{v}\|^2}_{\text{Ch. 1: Macroscopic flow } \mathbf{v} = \frac{\hbar}{m}\mathbf{A}_{\mathrm{Berry}}} + \underbrace{\frac{\hbar^2}{8m}\frac{\|\nabla\rho\|^2}{\rho}}_{\text{Ch. 2: Compressible osmotic/Fisher}} + \underbrace{\frac{\hbar^2}{8m}\rho\operatorname{Tr}(F_{\mu\nu})}_{\text{Ch. 3: Projective QFIM } (= \frac{\hbar^2}{2m}\rho\operatorname{Tr}(g_{\mu\nu}^{\mathrm{FS}}))}.
$$

| Fluid Regime | Governing PDEs | Role of 6-Channel Dual-Schubert QFIM | Machine-Checked & Numerical Benchmarks |
| --- | --- | --- | --- |
| **Incompressible Navier–Stokes** ($\rho = \rho_0$, $\nabla\cdot\mathbf{v} = 0$) | $\partial_t\mathbf{v} + (\mathbf{v}\cdot\nabla)\mathbf{v} = -\frac{1}{\rho_0}\nabla P + \nu\Delta\mathbf{v}$ | **Ch. 2 vanishes identically** ($\nabla\rho = 0 \implies v_{\mathrm{osm}} = 0$). **Ch. 1** carries rotational Clebsch-spinor flow ($\boldsymbol{\omega} = \nabla\times\mathbf{v} = \frac{\hbar}{m}\Omega_{\mathrm{Berry}} \ne 0$). **Ch. 3** encodes projective spin-tension stress ($-\frac{\hbar^2}{4m^2}\rho_0 F_{\mu\nu}$, Chern et al. 2016 *Incompressible Schrödinger Flow*). Pressure $P$ acts as the $\mathrm{U}(1)$ Helmholtz–Leray gauge multiplier. Dual-Schubert $(\Psi_+, \Psi_-)$ separates primal kinetic energy from dual enstrophy dissipation $\dot{E} = -\nu\int\|\boldsymbol{\omega}\|^2$. | 1. 2D Taylor–Green decaying vortex ($e^{-2\nu k^2 t}$)<br>2. 2D Lamb–Oseen viscous vortex<br>3. Plane Poiseuille & Couette shear flows<br>4. 3D Beltrami / ABC rotational flow<br>5. Explicit Schubert chart transition $\Omega_0 \to \Sigma_1 \to \Omega_{13}$ |
| **Compressible Navier–Stokes & Navier–Stokes–Korteweg (NSK)** ($\rho(x,t) > 0$) | $\partial_t\rho + \nabla\cdot(\rho\mathbf{v}) = 0$,<br>$\rho(\partial_t\mathbf{v} + (\mathbf{v}\cdot\nabla)\mathbf{v}) = -\nabla P_{\mathrm{cl}}(\rho) - \frac{\rho}{m}\nabla Q + \nabla\cdot\boldsymbol{\tau}_{\mathrm{visc}} + \nabla\cdot\boldsymbol{\sigma}_{\mathrm{QFIM}}$ | **All 3 channels active.** Under **Bresch–Desjardins** density-dependent viscosity $\mu(\rho) = \nu\rho$, the Dual-Schubert velocities $\mathbf{v}_\pm = \mathbf{v} \pm \nu\nabla\ln\rho = \mathbf{v} \pm \frac{2m\nu}{\hbar}\mathbf{v}_{\mathrm{osm}}$ split total kinetic energy into Ch. 1 + Ch. 2 Fisher energy (`dual_schubert_six_channel_decomposition`). The quantum force $-\frac{\rho}{m}\nabla Q = \nabla\cdot\mathbf{K}_{\mathrm{Korteweg}}$ equals the exact Korteweg capillary stress divergence. | 1. 1D viscous Burgers / Cole–Hopf shock ($v = -2\nu\partial_x\ln\tau$)<br>2. Exact Korteweg stress-tensor divergence identity<br>3. Bresch–Desjardins Dual-Schubert energy & Fisher split<br>4. Compressible viscous dissipation positivity $\Phi_{\mathrm{visc}} \ge 0$<br>5. Linearized Stokes acoustic attenuation & 1D finite-volume NSK shock solver |

---

## 3. Phased Implementation Workstreams (`NS-1` Through `NS-5`)

### `NS-1`: Lean 4 Formalization (`Signals.NavierStokes.*` & `Signals.Pending`)
- **Files:**
  - `src/signals/Signals/NavierStokes/PluckerFrame.lean`
  - `src/signals/Signals/NavierStokes/Incompressible.lean`
  - `src/signals/Signals/NavierStokes/Compressible.lean`
  - `src/signals/Signals/NavierStokes.lean` (umbrella import, imported in `src/signals/Signals.lean`)
  - `src/signals/Signals/Pending.lean` (`DualSchubertNavierStokesPendingBoundary`)
  - `src/signals/SignalsPending.lean`, `src/signals/SignalsTests.lean`, `src/signals/SignalsPendingTests.lean`
- **Core Theorems (Zero `sorry`):**
  1. `PluckerFrame.lean`: 2-component Clebsch-spinor Berry curvature $\equiv$ continuous vorticity (`clebsch_berry_vorticity_nonzero`), $4\times 2$ jet-frame Klein quadric cancellation (`jetFrame_klein_quadric_cancellation`), smooth chart transition bijection $\Omega_0 \leftrightarrow \Omega_{13}$ across $\Sigma_1 = \{p_{12}=0\}$ (`schubert_chart_transition_omega0_to_omega13`), and Chat Bug #2 proof (`chat_offdiag_viscous_matrix_is_hermitian` vs. `bateman_doubled_viscous_pairing_conserved_and_primal_dissipates`).
  2. `Incompressible.lean`: `incompressible_channel2_vanishes`, `incompressible_dual_schubert_energy_enstrophy_split`, exact PDE proofs for 2D Taylor–Green (`taylorGreen2D_solves_incompressible_ns`, `taylorGreen2D_energy_enstrophy_decay`), 2D Lamb–Oseen (`lambOseen2D_vorticity_heat_pde`), plane Poiseuille/Couette (`poiseuille_solves_incompressible_ns`), and 3D Beltrami (`beltrami3D_solves_steady_incompressible_ns`).
  3. `Compressible.lean`: 3D compressible stress tensor & Stokes hypothesis (`compressible_viscous_dissipation_nonneg`), exact Korteweg capillary stress divergence (`korteweg_stress_div_eq_quantum_force`), Bresch–Desjardins Dual-Schubert QFIM identity (`breschDesjardins_dual_schubert_qfim_split`), Cole–Hopf viscous Burgers & tanh shock (`coleHopf_burgers_solves_viscous_burgers`, `burgers_tanh_shock_solves_pde`), and linearized Stokes acoustic attenuation (`stokes_acoustic_attenuation_dispersion`).
  4. `Pending.lean`: `DualSchubertNavierStokesPendingBoundary` and impossibility theorem `dual_schubert_ns_identities_do_not_close_millennium_or_physical_claims`.
- **Gate:** `make signals_build` passes cleanly with zero errors and zero `sorry`.

### `NS-2`: Rust + PyO3 (`maturin`) Analytical Auditors & Time-Marching Solvers
- **Files:** `src/signals/numerical_adapter/src/navier_stokes.rs`, `src/signals/numerical_adapter/src/lib.rs`
- **Deliverables:**
  1. Analytical residual auditors (`< 1e-13`): `audit_taylor_green_2d`, `audit_lamb_oseen_2d`, `audit_beltrami_3d`, `audit_viscous_burgers_cole_hopf`, `audit_compressible_nsk_korteweg_bd`, `audit_schubert_chart_transition_vortex`, and `audit_bateman_vs_chat_heff`.
  2. `#[pyclass] IncompressibleDualSchubertSolver2D`: 2D periodic $(N_x \times N_y)$ Chorin / Helmholtz–Leray projection + viscous step tracking $L^\infty$ divergence error, kinetic energy, enstrophy, Dual-Schubert 6-channel QFIM, and automatic $\Omega_0 \leftrightarrow \Omega_{13}$ Schubert chart switching.
  3. `#[pyclass] CompressibleNskDualSchubertSolver1D`: 1D periodic finite-volume Rusanov + viscous + Korteweg capillary stress solver for barotropic compressible NS/NSK tracking mass conservation, Bresch–Desjardins Dual-Schubert energy, and Channel 1/2/3 QFIM decomposition.
- **Gate:** `cargo test --manifest-path src/signals/numerical_adapter/Cargo.toml navier_stokes` (all `#[test]` passing) and `maturin develop --manifest-path src/signals/numerical_adapter/Cargo.toml --release --features extension-module`.

### `NS-3`: SymPy Exact Proofs & `pytest` Cross-Verification Suite
- **Files:** `sustainablefactory/navier_stokes.py`, `tests/test_navier_stokes_dual_schubert_qfim.py`
- **Deliverables:**
  1. `verify_symbolic_navier_stokes_qfim_identities()`: exact SymPy proofs of Clebsch vorticity, Klein quadric & chart transition, Chat Bug #2 Hermitian vs. Bateman dissipation, 2D Taylor–Green, 2D Lamb–Oseen, 3D Beltrami, Poiseuille, Korteweg stress divergence, compressible dissipation positivity, Bresch–Desjardins Dual-Schubert identity, Cole–Hopf Burgers shock, Stokes acoustic dispersion, and incompressible/compressible 6-channel Dual-Schubert QFIM.
  2. `pytest` tests cross-checking every Rust/PyO3 analytical auditor and validating time-marching convergence & conservation for both `IncompressibleDualSchubertSolver2D` and `CompressibleNskDualSchubertSolver1D`.
- **Gate:** `pytest -q tests/test_navier_stokes_dual_schubert_qfim.py` passes 100%.

### `NS-4`: MyST Markdown Paper (Paper 53) & Documentation Integration
- **Files:**
  - `docs/grassmannian-dual-schubert-qfim-navier-stokes-compressible-incompressible-paper.md`
  - `docs/citations.bib` (verified entries for Bresch–Desjardins, Chern–Knöppel–Pinkall–Schröder ISF, Bateman, Korteweg, Fefferman, Taylor–Green, Cole, Hopf)
  - `docs/_toc.yml` (register plan & Paper 53)
  - `docs/grassmannian-unification-applications-roadmap-paper.md` (integrate Paper 53 across Master Plücker Dictionary, Section 2.14, Pending Routing Matrix, Section 5 Lean 4 capstone, BibTeX, and Schema.org JSON-LD)
- **Gate:** `lake env lean` on extracted roadmap Section 5 capstone; `0` findings from `fix_markdown_table_math_pipes.py` and `fix_markdown_display_math_spacing.py`; `make -C docs html` with `0` warnings on plan, Paper 53, and roadmap; `git diff --check`.

### `NS-5`: Commit Sequence
1. `PRO: Add written plan for compressible and incompressible Navier-Stokes via Dual-Schubert QFIM` (`docs/dual-schubert-qfim-navier-stokes-plan.md`).
2. `ENH: Formalize compressible and incompressible Navier-Stokes via Dual-Schubert QFIM in Lean 4` (`Signals.NavierStokes.*`, `Signals.lean`, `Pending.lean`, `SignalsPending.lean`, tests).
3. `ENH: Implement Rust/PyO3 Navier-Stokes Dual-Schubert QFIM solvers and SymPy/pytest cross-verification` (`navier_stokes.rs`, `lib.rs`, `sustainablefactory/navier_stokes.py`, `tests/test_navier_stokes_dual_schubert_qfim.py`).
4. `DOCS: Add Paper 53 on Dual-Schubert QFIM compressible/incompressible Navier-Stokes and update roadmap` (Paper 53, `citations.bib`, `_toc.yml`, roadmap).
