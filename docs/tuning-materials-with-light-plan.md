---
title: "Written Plan for Discovered Materials Problem 04: Tuning Materials with Light via Time-Linear Grassmannian G-GKBA"
description: "Structured theoretical, algorithmic, formal-verification (Lean 4), and numerical-reproduction (Rust & Python) plan for solving Discovered Materials Grand Challenge Problem 04 ('Tuning Materials with Light')."
---

(tuning-materials-with-light-plan)=
# Written Plan: Solving Discovered Materials Problem 04 (*Tuning Materials with Light*) via Unified Grassmannian Mechanics

- **Target Challenge**: [Discovered Materials — Problem 04: Tuning Materials with Light](https://discoveredmaterials.com/grand-challenges/tuning-materials-with-light/) ({cite}`discoveredmaterials2026problem04`, written with inputs from Prof. Felipe H. da Jornada, Stanford University)
- **Companion Paper**: [grassmannian-tuning-materials-with-light-paper.md](grassmannian-tuning-materials-with-light-paper.md)
- **Verification & Simulation Artifacts**:
  - Lean 4: [../src/signals/Signals/DFT.lean](../src/signals/Signals/DFT.lean#L720-L1005), [../src/signals/Signals/Pending.lean](../src/signals/Signals/Pending.lean#L6145-L6275), [../src/signals/SignalsTests.lean](../src/signals/SignalsTests.lean#L7020-L7070), [../src/signals/SignalsPendingTests.lean](../src/signals/SignalsPendingTests.lean#L5555-L5610)
  - Rust: [../src/signals/numerical_adapter/src/dft_plabic_vrc.rs](../src/signals/numerical_adapter/src/dft_plabic_vrc.rs#L380-L570)
  - Python: [../sustainablefactory/qci_grassmannian_dft.py](../sustainablefactory/qci_grassmannian_dft.py#L2200-L2460), [../tests/test_qci_grassmannian_dft.py](../tests/test_qci_grassmannian_dft.py#L540-L620)

---

## 1. Executive Summary & Theoretical Synthesis

Simulating a laser-driven solid over picosecond-to-hundred-picosecond timescales requires evolving **electron–electron ($\mathrm{e\text{-}e}$)**, **electron–phonon ($\mathrm{e\text{-}ph}$)**, and **phonon–phonon ($\mathrm{ph\text{-}ph}$)** interactions simultaneously out of equilibrium. While the two-time **Kadanoff–Baym Equations (KBE)** of non-equilibrium Green's function (NEGF) theory {cite}`kadanoff1962quantum` are formally exact, their cubic scaling in time steps $O(N_t^3)$ and cubic/quartic scaling in basis size $O(N_{\mathrm{basis}}^3)$ restrict direct KBE simulations to a few lattice sites and tens of femtoseconds.

Our written plan synthesizes six already-verified pillars of the `Signals` Grassmannian library into a single **Time-Linear Grassmannian Generalized Kadanoff–Baym Ansatz (`G-GKBA`)** framework:

| Grassmannian Pillar in `Signals` | Existing Module & Paper | Role in Problem 04 (*Tuning Materials with Light*) |
|---|---|---|
| **1. Unrestricted Spin-Polarized Grassmannian & Unitary Cayley Retraction** | `Signals.DFT` ([Paper 22](grassmannian-kohn-sham-dft-complex-plabic-vrc-paper.md), [Paper 23](grassmannian-speed-accuracy-barrier-quantum-chemistry-paper.md)) | Evolves the coherent 1-RDM projector $P_\sigma(t) \in \mathrm{Gr}_{\mathbb{C}}(N_\sigma, N_{\mathrm{basis}})$ in $O(N_{\mathrm{occ}}^2 N_{\mathrm{basis}})$ per step via $U(\Omega_\sigma) = (I - \frac{1}{2}\Omega_\sigma)^{-1}(I + \frac{1}{2}\Omega_\sigma)$, yielding a $(N_{\mathrm{basis}}/N_{\mathrm{occ}})^2 = 144\times$ basis speedup. |
| **2. McWeeny Idempotency Defect & Cumulant Splitting** | `Signals.DFT.mcweenyPurificationPoly`, `twoOrbitalLinearCorrelationEntropy` | Decomposes the non-equilibrium 1-RDM into a pure Grassmannian frame plus a correlated cumulant defect $\delta\rho_\sigma(t) = \rho_\sigma(t) - (3\rho_\sigma^2 - 2\rho_\sigma^3)$, tracking $\mathrm{e\text{-}e}$ double occupancy and quasiparticle depletion in $O(N_t)$ time. |
| **3. Complex Homogeneous Vector-Relation Configurations (`VRC`)** | `Signals.Plabic.VectorRelationConfiguration`, `Signals.QuantumCausalInference.GrassmannianCausalBackend` | Resolves on-shell exciton/polariton/Cooper-pair resonances at $x_X = -1$ without Plabic rational chart poles ($V K^\top = 0$). |
| **4. Multi-Lag Plücker Memory & Jeffrey Kinematic Engine** | `Signals.QuantumCausalInference` ([Paper 20](grassmannian-quantum-causal-jev-bundle-transformer-videogen-paper.md), [Paper 21](grassmannian-quantum-causal-splat-nanoimaging-surgical-graphrag-paper.md)) | Compresses non-Markovian KBE collision memory $\int_{t_0}^t d\bar{t}\,\Sigma(t,\bar{t})G(\bar{t},t)$ into $m_{\mathrm{lags}}$ Plücker wedges ($O(N_t^3) \to O(N_t)$), yielding an overall $N_t^2(N_{\mathrm{basis}}/N_{\mathrm{occ}})^2 = \mathbf{1.44\times 10^8\times}$ speedup. |
| **5. Bose–Einstein Phonon Kinetics, Cattaneo–Vernotte Second Sound, & 2D/3D Tensor Gaussian Splats** | `Signals.Scattering`, `Signals.DDF` ([Paper 6](grassmannian-thermal-compton-raman-paper.md), [Paper 10](gaussian-splat-tensors-normed-paper.md)) | Evolves mode-resolved optical ($K\text{-}A_1'$, $\Gamma\text{-}E_{2g}$) and acoustic (`LA`, `TA`) phonon populations $n_{\mathbf{q},\nu}(t)$ and represents diffuse scattering maps $I(\mathbf{q}, t)$ via anisotropic Gaussian splats. |
| **6. Dual-Grassmannian $\mathrm{Gr}_{\mathbb{C}}(2,4) \times \mathrm{Gr}_{\mathbb{C}}(2,4)^\vee$ Nambu–Bogoliubov Pairing & $\mathrm{MgB}_2$ Phase Bounds** | `Signals.DDF` Section 30 ([Paper 19](grassmannian-complex-gpe-igpe-plucker-madelung-paper.md)), `Signals.Pending.CryogenicSpoolAMBHypothesis` | Models two-band ($\sigma, \pi$) Anderson pseudospins, $T_c = 38\text{ K}$ gap closure, $0.63\text{ THz}$ 1st/3rd harmonic generation, the $1\text{ THz}$ Higgs/pair-breaking resonance at $7\text{ K}$, and $150\text{ kV/cm}$ conductivity quenching at $2\text{ ps}$. |

---

## 2. Staged Execution Plan Across the Four Reproduction Targets

### Phase 1: Mathematical Formalization in Lean 4 (`Signals.DFT` Sections 13–14 & `Signals.Pending` Section 32)
1. **Complexity & Scaling Proofs (`grassmannGKBASpeedupRatio`, `effectiveGGKBASpeedupWithCumulants`)**:
   - Formalize `twoTimeKBEFlops`, `timeLinearGrassmannGKBAFlops`, `grassmannGKBASpeedupRatio`, `ggkbaTotalFlopsWithCumulants`, and `effectiveGGKBASpeedupWithCumulants`, proving $\mathcal{S}_{\mathrm{G\text{-}GKBA}} = N_t^2 (N_{\mathrm{basis}}/N_{\mathrm{occ}})^2 = 1.44 \times 10^8$ bare and $\mathbf{1.44 \times 10^7 > 10^7}$ even with $9\times$ G1–G2 two-particle/phonon cumulant overhead ($C_{\mathrm{cum}} = 108{,}000\text{ FLOPs/step}$).
2. **Target 1 — Hubbard 11-Site Chain & $6\times 2$ Ladder (`arXiv:2606.10773`)**:
   - Formalize `hubbardCorrelatedDoubleOccupancy`, `hubbardDensityImbalance`, `hubbardDoublonDecayRate`, `hubbardSuperexchangeScale` ($J_{\mathrm{ex}} = 4J^2/U$), and `hubbardOpticalConductivityThreshold`.
   - Prove monotonic double-occupancy suppression across $U/J \in \{0, 5, 15, 20\}$, slower doublon decay at $U/J = 15$ than $U/J = 5$, superexchange ordering $J_{\mathrm{ex}}(1,15) < J_{\mathrm{ex}}(1,5) < J_{\mathrm{ex}}(1,3)$, and strict ordering of the $6\times 2$ ladder optical conductivity thresholds at $U/J = 3, 6, 12$.
3. **Target 2 — $\mathrm{WSe}_2$ Bright & Momentum-Dark Exciton Dynamics & High-Density Pauli Mott Screening (`Science` 370, 1199 (2020))**:
   - Formalize `wse2ResonantPumpEv` ($1.72\text{ eV}$), `wse2AboveGapPumpEv` ($2.48\text{ eV}$), `wse2DarkExcitonEnergyEv` ($1.675\text{ eV}$), `wse2DarkExcitonBuildupFs` ($400\text{ fs}$), `wse2LateTimeBrightToDarkRatio` ($0.5$), `excitonPauliPhaseSpaceFillingFactor` ($1 - n_{\mathrm{ex}}/n_{\mathrm{Mott}}$), and `excitonHighDensityEffectiveBinding`.
4. **Target 3 — Graphite Electron–Lattice Energy Flow, Coupled 5-Reservoir ODE Rate Conservation, & Anharmonic Relaxation (`PRB` 100, 214115 (2019))**:
   - Formalize `graphiteTotalEnergyBalance` across the five coupled reservoirs ($E_{\mathrm{el}}, E_{A_1'}, E_{E_{2g}}, E_{\mathrm{LA}}, E_{\mathrm{TA}}$), `graphiteFiveReservoirRateSum` ($\sum_r \dot{E}_r = P_{\mathrm{laser}}(t)$), and `graphiteA1pOpticalRiseAndDecay` across the $0.5, 1.5, 5, 100\text{ ps}$ snapshots.
5. **Target 4 — $\mathrm{MgB}_2$ Equilibrium Pairing, Driven THz Superconductivity, Out-of-Equilibrium $T_c^{\mathrm{neq}}$, & $3\omega$ Saturation (`PRL` 135, 036902 (2025))**:
   - Formalize `mgb2KatsumiCriticalTempK` ($38\text{ K}$), `mgb2LowerPiGapSq`, `mgb2NormalizedFirstHarmonic`, `mgb2ThirdHarmonicResonanceDenomSq` (minimized at $1.0\text{ THz}$ at $7\text{ K}$), `mgb2DrivenSuperfluidConductivityIm` (quenched at $2\text{ ps}$ after a $150\text{ kV/cm}$ pump), `mgb2NonEquilibriumCriticalTemp` ($T_c^{\mathrm{neq}} = T_{c0}(1 - 2n_{\mathrm{qp}})$), and `mgb2SaturatedThirdHarmonicAmplitude`.
6. **Evidentiary Boundary Contract (`Signals.Pending.LightDrivenMaterialsPendingHypothesis`)**:
   - Isolate full Brillouin-zone $GW\text{-}\mathrm{BSE}$ / DFPT matrix-element calibration and experimental trARPES / UEDS / THz-TDS validation in `Signals.Pending` (`light_driven_materials_gkba_and_four_target_bounds`, `light_driven_materials_critique_and_gap_closure_bounds`).

### Phase 2: Rust & Python Numerical Implementation & Verification
1. **Rust (`src/signals/numerical_adapter/src/dft_plabic_vrc.rs`)**:
   - Implement all Problem 04 functions and constants and verify in `test_tuning_materials_with_light_problem04_check_figures`.
2. **Python (`sustainablefactory/qci_grassmannian_dft.py` & `tests/test_qci_grassmannian_dft.py`)**:
   - Implement `TuningMaterialsWithLightEngine` with `simulate_hubbard_chain_and_ladder`, `simulate_wse2_exciton_dynamics`, `simulate_graphite_electron_lattice_flow`, `simulate_mgb2_driven_superconductivity`, and `run_all_four_targets_benchmark`, verified by `test_tuning_materials_with_light_problem04_all_four_targets`.

### Phase 3: MyST Paper, Unification Integration, & Build Verification
1. Write [grassmannian-tuning-materials-with-light-paper.md](grassmannian-tuning-materials-with-light-paper.md) and synchronize with `src/signals/docs/`.
2. Update [grassmannian-unification-applications-roadmap-paper.md](grassmannian-unification-applications-roadmap-paper.md), `docs/_toc.yml`, `docs/citations.bib`, `README.md`, `src/signals/README.md`, `AGENTS.md`, and `src/signals/blueprint/src/content.tex`.
3. Run `lake build`, `cargo test`, `pytest`, markdown math linters, Sphinx HTML build, and `git diff --check`.
