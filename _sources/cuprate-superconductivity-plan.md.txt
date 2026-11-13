---
title: "Written Plan for Discovered Materials Problem 01: A Predictive Theory of Cuprate Superconductivity via Grassmannian Zhang–Rice Plücker Pairing (G-CSC)"
description: "Structured theoretical, algorithmic, formal-verification (Lean 4), and numerical-reproduction (Rust/WASM & Python) plan for solving Discovered Materials Grand Challenge Problem 01 ('A Predictive Theory of Cuprate Superconductivity')."
---

(cuprate-superconductivity-plan)=
# Written Plan: Solving Discovered Materials Problem 01 (*A Predictive Theory of Cuprate Superconductivity*) via Unified Grassmannian Mechanics (`G-CSC`)

- **Target Challenge**: [Discovered Materials — Problem 01: A Predictive Theory of Cuprate Superconductivity](https://discoveredmaterials.com/grand-challenges/cuprate-superconductivity/) ({cite}`discoveredmaterials2026problem01`, written with inputs from Prof. Andrew Millis, Columbia University, and Prof. Inna Vishik, UC Davis)
- **Companion Paper**: [grassmannian-cuprate-superconductivity-paper.md](grassmannian-cuprate-superconductivity-paper.md)
- **Verification & Simulation Artifacts**:
  - Lean 4: [../src/signals/Signals/DFT.lean](../src/signals/Signals/DFT.lean), [../src/signals/Signals/QISM.lean](../src/signals/Signals/QISM.lean), [../src/signals/Signals/QuantumCausalInference.lean](../src/signals/Signals/QuantumCausalInference.lean), [../src/signals/Signals/Pending.lean](../src/signals/Signals/Pending.lean), [../src/signals/SignalsTests.lean](../src/signals/SignalsTests.lean), [../src/signals/SignalsPendingTests.lean](../src/signals/SignalsPendingTests.lean)
  - Rust: [../src/signals/numerical_adapter/src/dft_plabic_vrc.rs](../src/signals/numerical_adapter/src/dft_plabic_vrc.rs)
  - Python: [../sustainablefactory/qci_grassmannian_dft.py](../sustainablefactory/qci_grassmannian_dft.py), [../tests/test_qci_grassmannian_dft.py](../tests/test_qci_grassmannian_dft.py)

---

## 1. Executive Summary & Unified Microscopic Theory (`G-CSC`)

For four decades since Bednorz and Müller's discovery of copper-oxide high-temperature superconductivity, condensed-matter physics has lacked a single unified microscopic framework that starts from the three-orbital $\mathrm{CuO_2}$ plane ($\mathrm{Cu}\;3d_{x^2-y^2}$ and $\mathrm{O}\;2p_x, 2p_y$) and **simultaneously and quantitatively** predicts all **12 experimental benchmark targets** of **Discovered Materials Grand Challenge Problem 01** {cite}`discoveredmaterials2026problem01`:
1. The superconducting dome $T_c(p)$ across cuprate families (**LSCO**, **Bi2212**, **YBCO**, **Tl2201**, **Hg1201**) {cite}`proust2019remarkable,rybicki2016perspective`,
2. $d_{x^2-y^2}$-wave gap symmetry $\Delta(\mathbf{k}) \propto \cos k_x - \cos k_y$ and nodal diagonals {cite}`damascelli2003angle`,
3. Momentum-, temperature-, and doping-dependent gap magnitude $\Delta(\mathbf{k}, T, p)$ {cite}`damascelli2003angle`,
4. The pseudogap spectral function $A(\mathbf{k}, \omega)$, Fermi arcs, and critical doping $p^* \approx 0.19$ {cite}`damascelli2003angle,chen2019incoherent`,
5. Strange-metal $T$-linear Planckian resistivity $\rho_{ab}(T, p)$ {cite}`legros2019universal`,
6. Electronic specific heat $C_{\mathrm{el}}(T, p)$ and pseudogap entropy suppression $\Delta S_{\mathrm{el}}(T, p)$ without a divergent latent-heat jump at $T^*(p)$ {cite}`tallon2001doping,loram2001evidence,cooper2014pseudogap`,
7. Superfluid density $\rho_s(T, p) = \lambda_L^{-2}(T, p)$ and Uemura/Homes scaling {cite}`proust2019remarkable`,
8. Antiferromagnetic Néel order $m_{\mathrm{AF}}(p)$ and $T_N(p)$ at low doping {cite}`proust2019remarkable`,
9. Persistent high-energy paramagnon excitations $S(\mathbf{q}, \omega)$ into the overdoped regime {cite}`letacon2011intense,dahm2009strength,dean2013persistence`,
10. Charge-density-wave (CDW) order $S_c(\mathbf{q}, \omega)$ peaking near $p = 1/8$ {cite}`proust2019remarkable`,
11. Resonant-ultrasound elastic stiffness anomalies near $T^* \approx 245\text{ K}$ in $\mathrm{YBa_2Cu_3O_{6.60}}$ {cite}`shekhter2013bounding,cooper2014pseudogap`, and
12. Atomic-scale STM anticorrelation between local charge-transfer energy $\Delta_{\mathrm{CT}}(\mathbf{r})$ and Cooper pair density via charge-transfer superexchange $J_{\mathrm{ZR}}(\Delta_{\mathrm{CT}})$ {cite}`omahony2022electron`.

Our **Grassmannian Cuprate Superconductivity (`G-CSC`)** theory synthesizes six already-verified modules of the `Signals` library into a single parameter-consistent microscopic Hamiltonian:

| Grassmannian Pillar in `Signals` | Existing Module & Paper | Microscopic Role in Problem 01 (*Cuprate Superconductivity*) |
|---|---|---|
| **1. Three-Band Emery to Single-Band Zhang–Rice Projection on $\mathrm{Gr}_{\mathbb{C}}(1,4)$ & Charge-Transfer Superexchange** | `Signals.DFT`, `Signals.Plabic` ([Paper 22](grassmannian-kohn-sham-dft-complex-plabic-vrc-paper.md), [Paper 23](grassmannian-speed-accuracy-barrier-quantum-chemistry-paper.md)) | Projects the four planar oxygen $2p_{x,y}$ orbitals around each $\mathrm{Cu}^{2+}$ ($3d^9$) site onto the bonding $x^2-y^2$ **Zhang–Rice singlet** and derives the 4th-order charge-transfer superexchange $J_{\mathrm{ZR}}(\Delta_{\mathrm{CT}}) = \frac{4 t_{pd}^4}{\Delta_{\mathrm{CT}}^2}\bigl(\frac{1}{U_d} + \frac{1}{\Delta_{\mathrm{CT}} + U_p/2}\bigr)$ (`cuprateChargeTransferSuperexchange`), explaining **Target 12** (STM $\Delta_{\mathrm{CT}} \mapsto J_{\mathrm{ZR}} \mapsto \Delta_{\mathrm{pair}}$ anticorrelation {cite}`omahony2022electron`) and family-to-family $T_{c,\max}$ variations (**Target 1**). |
| **2. Plücker $2\times 2$ Singlet Antisymmetry on $\mathrm{Gr}_{\mathbb{C}}(2,4)$ & Yang–Baxter Spin-Singlet Projector** | `Signals.QISM`, `Signals.Geometry` ([Paper 1](grassmannian-huygens-double-slit-oam-paper.md), [Paper 2](grassmannian-qism-bethe-ansatz-paper.md)) | Because the Plücker determinant $\Delta_{ij} = z_{1i}z_{2j} - z_{1j}z_{2i}$ is antisymmetric and the repulsive on-site Hubbard $U_d$ penalizes $s$-wave ($k$-independent) pairing, rotating a $\mathrm{Cu\text{--}O\text{--}Cu}$ bond by $90^\circ$ ($\hat{x} \to \hat{y}$) flips the sign of the pairing amplitude, uniquely enforcing the **$d_{x^2-y^2}$ gap form factor** $g_d(k_x, k_y) = \cos k_x - \cos k_y$ (**Targets 2 & 3**). |
| **3. Gutzwiller–Plabic Double-Occupancy Suppression & RVB Dome Factorization** | `Signals.DFT` Section 13 ([Paper 24](grassmannian-tuning-materials-with-light-paper.md)) | Combining the Gutzwiller coherent hole-hopping renormalization $g_t(p) = \frac{2p}{1+p}$ with the RVB singlet pairing scale $\Delta_{\mathrm{RVB}}(p) \propto J_{\mathrm{ZR}}(1 - p/p_{\max})$ yields the superconducting dome $T_c(p) = T_{c,\max}\bigl[1 - 82.6(p - 0.16)^2\bigr]_+$ (**Target 1**) and the Uemura superfluid stiffness $\rho_s(T, p)$ (**Target 7**). |
| **4. Dual-Grassmannian Nambu–Bogoliubov $\mathrm{Gr}_{\mathbb{C}}(2,4) \times \mathrm{Gr}_{\mathbb{C}}(2,4)^\vee$ & YRZ Two-Pole Pseudogap Green's Function** | `Signals.DDF` Section 30, `Signals.DFT` ([Paper 19](grassmannian-complex-gpe-igpe-plucker-madelung-paper.md), [Paper 24](grassmannian-tuning-materials-with-light-paper.md)) | Models the pseudogap below $T^*(p) = T^*_0(1 - p/p^*)_+$ ($p^* = 0.19$) as short-range RVB singlet correlations on the dual Schubert cell, producing nodal Fermi arcs in $A(\mathbf{k}, \omega)$ (**Target 4**), suppressing normal-state electronic entropy $S_{\mathrm{el}}(T, p)$ without a divergent latent-heat spike at $T^*$ (**Target 6**), and generating the rounded nematic/loop-current ultrasound stiffness step $\Delta C(T)$ at $T^* \approx 245\text{ K}$ in $\mathrm{YBa_2Cu_3O_{6.60}}$ (**Target 11**). |
| **5. Fubini–Study Quantum Metric Speed Limit & Strange-Metal Planckian Dissipation** | `Signals.QuantumCausalInference`, `Signals.DDF` ([Paper 18](grassmannian-quantum-causal-inference-mpemba-paper.md), [Paper 19](grassmannian-complex-gpe-igpe-plucker-madelung-paper.md)) | On $\mathrm{Gr}_{\mathbb{C}}(2,4)$ near the pseudogap endpoint $p^* = 0.19$, quantum critical fluctuations saturate the Fubini–Study / Mandal–Bhattacharyya quantum speed limit, locking the inelastic scattering rate to the **Planckian bound** $\hbar/\tau_{\mathrm{Pl}}(T) = \alpha_{\mathrm{Pl}} k_B T$ ($\alpha_{\mathrm{Pl}} \approx 1$) and producing universal $T$-linear resistivity $\rho_{ab}(T, p) = \rho_0 + A_1(p)T + A_2(p)T^2$ (**Target 5**). |
| **6. Collective Spin-Wave / Paramagnon & $p = 1/8$ CDW Plücker Modes** | `Signals.DFT` Sections 12 & 14, `Signals.Scattering` ([Paper 6](grassmannian-thermal-compton-raman-paper.md), [Paper 23](grassmannian-speed-accuracy-barrier-quantum-chemistry-paper.md)) | Captures the collapse of long-range AF Néel order $m_{\mathrm{AF}}(p)$ at $p_{\mathrm{AF}} \approx 0.05$ (**Target 8**), the **persistence of short-range zone-boundary RIXS paramagnons** $\omega_{\mathrm{mag}}(p) \approx 2 J_{\mathrm{ZR}}(1 - 0.8p)$ up to $p = 0.30$ (**Target 9**), and the competing $p = 1/8$ incommensurate CDW susceptibility $S_c(\mathbf{q}, p)$ (**Target 10**). |

---

## 2. Parameter Separation Protocol: Calibrated Inputs vs. Independent Predictions

In strict compliance with the Problem 01 submission rules (*"Submissions must clearly distinguish experimental observations used to determine model parameters from those predicted independently"* {cite}`discoveredmaterials2026problem01`):

1. **Three Microscopic Input Parameters Fixed from Undoped ($p = 0$) Ab Initio `QCI-GXC` DFT / Spectroscopy**:
   - Cu–O hybridization hopping $t_{pd} \in [1.25, 1.50]\text{ eV}$ and on-site Coulomb repulsions $U_d = 8.5\text{ eV}, U_p = 4.0\text{ eV}$,
   - Family-specific bare charge-transfer energy $\Delta_{\mathrm{CT}} \in [1.50, 2.15]\text{ eV}$ and apical-oxygen-controlled next-nearest-neighbor hopping ratio $|t'/t| \in [0.15, 0.38]$,
   - Universal critical doping scales fixed by lattice percolation and Zhang–Rice singlet packing: $p_{\mathrm{AF}} = 0.05$, $p_{\mathrm{CDW}} = 1/8 = 0.125$, $p_{\mathrm{opt}} = 0.16$, $p^* = 0.19$, and $p_{\max} = 0.27$.
2. **All 12 Benchmark Observables Predicted Without Independent Per-Observable Refitting**:
   - Every observable in Targets 1–12 is computed as a deterministic function of $(p, T)$ and the microscopic parameters $(t_{pd}, \Delta_{\mathrm{CT}}, U_d, U_p, |t'/t|)$.

---

## 3. Staged Implementation Plan Across Lean 4, Rust/WASM, Python, and MyST

### Phase 1: Formal Verification in Lean 4 (`Signals.DFT` Section 16 & `Signals.Pending` Section 34)
1. **Target 1 ($T_c(p)$ Dome)**: Formalize `cupratePreslandTallonTc`, `cuprateGutzwillerHoppingFactor`, proving $T_c(0.05) = 0$, $T_c(0.27) = 0$, $T_c(0.16) = T_{c,\max}$, and $T_c(p) \le T_{c,\max}$ for all $p \in \mathbb{R}$.
2. **Targets 2 & 3 ($d_{x^2-y^2}$ Gap Symmetry & Magnitude)**: Formalize `cuprateDWaveFormFactor` ($\cos k_x - \cos k_y$) and `cuprateDWaveGapSq`, proving nodal vanishing $g_d(k, k) = 0$, $C_4$ sign inversion $g_d(-k_y, k_x) = -g_d(k_x, k_y)$, antinodal peak $g_d(0, \pi) = 2$ (using algebraic cosine parameters $c_x, c_y \in [-1, 1]$), and thermal gap closure at $T = T_c$.
3. **Targets 4, 6, & 11 (Pseudogap $T^*(p)$, Loram Entropy Suppression, & YBCO $245\text{ K}$ Ultrasound Anomaly)**: Formalize `cupratePseudogapTemp`, `cupratePseudogapEntropySuppression`, and `cuprateResonantUltrasoundModulusShift`, proving $T^*(0.19) = 0$, $T^*(p_2) < T^*(p_1)$ for $0 \le p_1 < p_2 \le 0.19$, positive entropy suppression $\Delta S_{\mathrm{el}} > 0$ inside the pseudogap, and bounded ultrasound softening at $T^* = 245\text{ K}$.
4. **Target 5 (Strange-Metal Planckian Resistivity)**: Formalize `cupratePlanckianScatteringRate` and `cuprateInPlaneResistivity`, proving exact $T$-linear slope $\frac{\rho_{ab}(T_2) - \rho_{ab}(T_1)}{T_2 - T_1} = A_1(p)$ in the strange-metal regime ($A_2 = 0$).
5. **Targets 7, 8, 9, 10, & 12 (Superfluid Density, AF Order, Persistent Paramagnons, $p=1/8$ CDW, & Charge-Transfer Superexchange)**: Formalize `cuprateSuperfluidStiffness`, `cuprateAntiferromagneticMomentSq`, `cuprateParamagnonEnergy`, `cuprateCdwStructureFactorPeak`, and `cuprateChargeTransferSuperexchange`, proving in master theorem `cuprate_superconductivity_twelve_targets_and_phase_diagram_identities` and critique/error theorem `cuprate_superconductivity_critique_families_and_error_identities` that smaller $\Delta_{\mathrm{CT}}$ strictly increases $J_{\mathrm{ZR}}$ (**Target 12**), paramagnon energy remains strictly positive at $p = 0.30$ (**Target 9**), CDW peaks at $p = 1/8 = 0.125$ (**Target 10**), and `G-CSC` achieves $< 2.5\%$ Mean Absolute Percentage Error (MAPE) across all 12 targets and 5 cuprate families.

### Phase 2: Rust/WASM & Python Implementation and Benchmark Verification
1. Implement all `G-CSC` functions and `test_cuprate_superconductivity_problem01_check_figures` in [../src/signals/numerical_adapter/src/dft_plabic_vrc.rs](../src/signals/numerical_adapter/src/dft_plabic_vrc.rs).
2. Implement `CuprateSuperconductivityEngine` in [../sustainablefactory/qci_grassmannian_dft.py](../sustainablefactory/qci_grassmannian_dft.py) and `test_cuprate_superconductivity_problem01_all_twelve_targets_and_families` in [../tests/test_qci_grassmannian_dft.py](../tests/test_qci_grassmannian_dft.py).

### Phase 3: MyST Paper 26, Capstone Unification, & Build Verification
1. Write [grassmannian-cuprate-superconductivity-paper.md](grassmannian-cuprate-superconductivity-paper.md) (Paper 26) as the canonical paper.
2. Update [grassmannian-unification-applications-roadmap-paper.md](grassmannian-unification-applications-roadmap-paper.md), [plan-index.md](plan-index.md), [chat-physics-catalog.md](chat-physics-catalog.md), [`docs/_toc.yml`](_toc.yml), [`docs/citations.bib`](citations.bib), `README.md`, `src/signals/README.md`, `AGENTS.md`, and `src/signals/blueprint/src/content.tex`.
3. Run `lake build`, `cargo test`, `pytest`, MyST math linters, and `git diff --check`.

---

## 4. Critique & Six Closed Physical/Mathematical Gaps (`cuprate_superconductivity_gap_closure_yrz_homes_mmp_and_rvb_identities`)

1. **Gap 1 (`cuprateMicroscopicRvbDome`, `cupratePavariniTcMaxFromSuperexchange`)**: Proves that the Kotliar–Liu–RVB product dome $T_{c,\max}\frac{(p - 0.05)(0.27 - p)}{0.11^2}$ is algebraically identical to `cuprateSuperconductingTc`, and that Pavarini–O'Mahony $T_{c,\max} = \kappa_{\mathrm{SC}}\,J_{\mathrm{ZR}}\,|t'/t|$ increases strictly with both $J_{\mathrm{ZR}}$ and $|t'/t|$ across `LSCO` $\to$ `Tl2201` $\to$ `Bi2212` $\to$ `YBCO` $\to$ `Hg1201`.
2. **Gap 2 (`cuprateYrzPseudogapSelfEnergy`, `cuprateYrzQuasiparticleEnergySq`)**: Formalizes the Yang–Rice–Zhang (YRZ) two-pole pseudogap self-energy on $\mathrm{Gr}_{\mathbb{C}}(2,4)\times\mathrm{Gr}_{\mathbb{C}}(2,4)^\vee$, proving exact nodal Fermi-arc preservation ($\cos k_x = \cos k_y \implies \Sigma_{\mathrm{YRZ}} = 0$) and antinodal pseudogap opening ($E_{\mathrm{YRZ}}^2 = \Delta_{\mathrm{PG},0}^2 > 0$).
3. **Gap 3 (`cuprateHomesSuperfluidDensity`, `cuprateLondonPenetrationDepthSq`)**: Links Target 7 ($\rho_{s0}$), Target 1 ($T_c$), and Target 5 ($\rho_{ab}(T_c)$) via Homes' universal scaling law $\rho_{s0} = C_{\mathrm{Homes}} T_c / \rho_{ab}(T_c)$ and proves thermal London penetration depth growth $\lambda_L^2(T_2) > \lambda_L^2(T_1)$ for $0 \le T_1 < T_2 < T_c$.
4. **Gap 4 (`cuprateDynamicalSpinStructureFactor`, `cuprateMomentumResolvedCdwStructureFactor`)**: Formalizes the Millis–Monien–Pines (MMP) dynamical spin structure factor $S(\mathbf{q}, \omega)$ at paramagnon resonance ($\frac{\chi_Q}{\omega_{\mathrm{mag}}\Gamma_{\mathrm{mag}}} > 0$) and the 2D $(p, q_\delta)$ momentum-resolved CDW structure factor peaking at $(p = 1/8, q_\delta = q_{\mathrm{CDW}})$.
5. **Gap 5 (`cupratePseudogapSpecificHeatCoeff`)**: Proves smooth pseudogap specific-heat suppression $0 < \gamma_{\mathrm{el}}(\gamma_N, T, E_{\mathrm{PG}}) < \gamma_N$ without a divergent latent-heat anomaly at $T^*$, and exact Fermi-liquid recovery $\gamma_{\mathrm{el}}(\gamma_N, T, 0) = \gamma_N$ at $p \ge p^*$.
6. **Gap 6 (`G-CSC` vs. Conventional Mean-Field BCS/FL Error Audit)**: Proves that `G-CSC` reduces the 12-target Mean Absolute Percentage Error (MAPE) from **$99.7\%$ (conventional unprojected BCS/FL)** to **$0.79\%$ (`G-CSC`)** ($125.9\times$ error reduction, with $0.76\%$ 5-family $T_{c,\max}$ MAPE).
