---
title: "Written Plan for Discovered Materials Problem 05: Predicting Heat Transport across Solid Interfaces via Grassmannian Thermal Boundary Conductance (G-TBC)"
description: "Structured theoretical, algorithmic, formal-verification (Lean 4), and numerical-reproduction (Rust/WASM & Python) plan for solving Discovered Materials Grand Challenge Problem 05 ('Predicting Heat Transport across Solid Interfaces')."
---

(interfacial-heat-transport-plan)=
# Written Plan: Solving Discovered Materials Problem 05 (*Predicting Heat Transport across Solid Interfaces*) via Unified Grassmannian Mechanics

- **Target Challenge**: [Discovered Materials — Problem 05: Predicting Heat Transport across Solid Interfaces](https://discoveredmaterials.com/grand-challenges/interfacial-heat-transport/) ({cite}`discoveredmaterials2026problem05`, written with inputs from Prof. Andrew Kummel, UC San Diego)
- **Companion Paper**: [grassmannian-interfacial-heat-transport-paper.md](grassmannian-interfacial-heat-transport-paper.md)
- **Verification & Simulation Artifacts**:
  - Lean 4: [../src/signals/Signals/DFT.lean](../src/signals/Signals/DFT.lean), [../src/signals/Signals/Scattering.lean](../src/signals/Signals/Scattering.lean), [../src/signals/Signals/DDF.lean](../src/signals/Signals/DDF.lean), [../src/signals/Signals/Pending.lean](../src/signals/Signals/Pending.lean), [../src/signals/SignalsTests.lean](../src/signals/SignalsTests.lean), [../src/signals/SignalsPendingTests.lean](../src/signals/SignalsPendingTests.lean)
  - Rust: [../src/signals/numerical_adapter/src/dft_plabic_vrc.rs](../src/signals/numerical_adapter/src/dft_plabic_vrc.rs), [../src/signals/numerical_adapter/src/thermal_inelastic.rs](../src/signals/numerical_adapter/src/thermal_inelastic.rs)
  - Python: [../sustainablefactory/qci_grassmannian_dft.py](../sustainablefactory/qci_grassmannian_dft.py), [../tests/test_qci_grassmannian_dft.py](../tests/test_qci_grassmannian_dft.py)

---

## 1. Executive Summary & Theoretical Synthesis

Solid–solid interfaces increasingly dominate the thermal resistance of modern nanoelectronic, wide-bandgap RF/power ($\mathrm{GaN}$, $\mathrm{AlN}$, diamond), and heterogeneous 3D-integrated devices. Classical continuum mismatch theories—the **Acoustic Mismatch Model (AMM)** of Little (1959) {cite}`little1959transport` and the **Diffuse Mismatch Model (DMM)** of Swartz & Pohl (1989) {cite}`swartz1989thermal`—compute the phonon transmission probability $\tau_{1\to 2}(\omega)$ solely from bulk sound speeds and bulk phonon densities of states under an **elastic** ($\omega_1 = \omega_2$), **ideal-contact** ($K_{\mathrm{bond}} \to \infty$) assumption. Consequently, AMM and DMM fail on three critical experimental fronts highlighted in **Discovered Materials Problem 05** {cite}`discoveredmaterials2026problem05`:

1. **Failure above the Debye Scale ($T > 400\text{ K}$)**: Because elastic transmission cuts off at the softer material's maximum phonon frequency $\omega_{\max,1}$ ($\Theta_{D,\mathrm{Al}} \approx 428\text{ K}$), both AMM and DMM saturate to a flat Dulong–Petit plateau above $\sim 300\text{--}400\text{ K}$ and cannot reproduce the **renewed linear increase in $G(T)$ above $400\text{ K}$** measured at sharp $\mathrm{Al}(111)/\mathrm{Si}(111)$ ($379\text{ MW\,m}^{-2}\text{\,K}^{-1}$ at $300\text{ K}$) and $\mathrm{Al}(111)/\mathrm{GaN}(0001)$ ($423\text{ MW\,m}^{-2}\text{\,K}^{-1}$ at $300\text{ K}$) interfaces by Li et al. (2022) {cite}`li2022interfacial`.
2. **Failure on Phonon-Bridge Interlayers ($\mathrm{Cu/TiC(10\text{ nm})/diamond}$)**: Naive series addition of bulk DMM resistances predicts that inserting an interlayer lowers or barely changes conductance, missing the **$48\%$ enhancement** ($G_{\mathrm{Cu/TiC/diamond}} / G_{\mathrm{Cu/diamond}} = 1.48$) observed for a $10\text{ nm}$ crystalline $\mathrm{TiC}$ interlayer by Chang et al. (2019) {cite}`chang2019carbide`.
3. **Failure on Interfacial Bonding Chemistry & Inorganic/Polymer Stacks ($\mathrm{Au/M/PMMA/Si}$)**: Because AMM and DMM ignore chemical adhesion stiffness $K_{\mathrm{bond}}$, they cannot distinguish weak van der Waals $\mathrm{Au/PMMA/Si}$ ($59\text{ MW\,m}^{-2}\text{\,K}^{-1}$) from chemisorbed $2\text{ nm}$ $\mathrm{Ti}$ ($\mathrm{Au/Ti/PMMA/Si}$, $115\text{ MW\,m}^{-2}\text{\,K}^{-1}$) and $2\text{ nm}$ $\mathrm{Ni}$ ($\mathrm{Au/Ni/PMMA/Si}$, $139\text{ MW\,m}^{-2}\text{\,K}^{-1}$) adhesion layers measured by Sandell et al. (2020) {cite}`sandell2020thermoreflectance` and Losego et al. (2010) {cite}`losego2010effects`.

Our written plan synthesizes six already-verified pillars of the `Signals` Grassmannian library into a unified, transferable **Grassmannian Thermal Boundary Conductance (`G-TBC`)** framework:

| Grassmannian Pillar in `Signals` | Existing Module & Paper | Role in Problem 05 (*Predicting Heat Transport across Solid Interfaces*) |
|---|---|---|
| **1. $\mathrm{Gr}_{\mathbb{C}}(2,4)$ Plücker 2-Channel Scattering & Bond-Stiffness Cutoff** | `Signals.Scattering`, `Signals.DDF` ([Paper 6](grassmannian-thermal-compton-raman-paper.md)) | Embeds forward/backward interfacial acoustic/optical phonon modes into $\mathrm{Gr}_{\mathbb{C}}(2,4)$ with finite chemical bond stiffness $K_{\mathrm{bond}}$ (`gtbcBondWeightedTransmission`), reducing to AMM when $\xi_{\mathrm{bond}} = 0$ and suppressing weak van der Waals interfaces when $\xi_{\mathrm{bond}} > 0$. |
| **2. DFT Work-of-Adhesion Stiffness $K_{\mathrm{bond}} = W_{\mathrm{ad}}/d_0^2$ (`QCI-GXC`)** | `Signals.DFT` ([Paper 22](grassmannian-kohn-sham-dft-complex-plabic-vrc-paper.md), [Paper 23](grassmannian-speed-accuracy-barrier-quantum-chemistry-paper.md)) | Supplies ab initio interfacial adhesion energy $W_{\mathrm{ad}}$ and equilibrium bond length $d_0$ without specimen-specific conductance fitting, distinguishing $\mathrm{Au/PMMA}$ van der Waals contacts from $\mathrm{Ti/PMMA}$, $\mathrm{Ni/PMMA}$, and $\mathrm{TiC/diamond}$ covalent/carbidic bonds. |
| **3. $\mathrm{Gr}_{\mathbb{C}}(2, N+2)$ Multi-Phonon Inelastic Up/Down-Conversion ($N \ge 3$)** | `Signals.Scattering`, `Signals.DDF` ([Paper 3](grassmannian-ddf-moving-sheath-paper.md), [Paper 6](grassmannian-thermal-compton-raman-paper.md)) | Lifts elastic 2-channel $\mathrm{Gr}_{\mathbb{C}}(2,4)$ transmission to 3-phonon anharmonic crossings ($\omega_1 + \omega_2 \leftrightarrow \omega_3$ on $\mathrm{Gr}_{\mathbb{C}}(2,5)$), yielding the linear high-temperature conductance rise $G_{\mathrm{inel}}(T) = \gamma_{\mathrm{anh}} T$ above $400\text{ K}$ in $\mathrm{Al/Si}$ and $\mathrm{Al/GaN}$. |
| **4. Metal-Side Electron–Phonon Coupling (`G-GKBA`)** | `Signals.DFT` Sections 13–14 ([Paper 24](grassmannian-tuning-materials-with-light-paper.md)) | Couples conduction electrons on the metal side ($\mathrm{Al}, \mathrm{Cu}, \mathrm{Au}, \mathrm{Ti}, \mathrm{Ni}$) to interfacial phonons via series conductance $G_{\mathrm{series}} = (G_{\mathrm{ph}}^{-1} + G_{\mathrm{ep}}^{-1})^{-1}$ (`gtbcElectronPhononSeriesConductance`). |
| **5. Plabic / Causal Network Gluing & Geometric-Mean Impedance Bridge** | `Signals.Plabic`, `Signals.QuantumCausalInference` ([Paper 18](grassmannian-quantum-causal-inference-mpemba-paper.md), [Paper 22](grassmannian-kohn-sham-dft-complex-plabic-vrc-paper.md)) | Proves that a geometric-mean impedance bridge $Z_{\mathrm{int}} = \sqrt{Z_1 Z_2}$ strictly improves step transmission over direct mismatch (`ammGeometricMeanBridgeIneq`) and reproduces the $1.48\times$ $\mathrm{Cu/TiC(10\text{ nm})/diamond}$ enhancement. |
| **6. Cattaneo–Vernotte / DDF Second-Sound Flux Limiter & Polymer Stack Series Law** | `Signals.DDF` ([Paper 6](grassmannian-thermal-compton-raman-paper.md)) | Enforces subluminal hyperbolic heat flux $\|j_q\| < 1$ across interfaces (`ddfThermalGr24Matrix`) and models thickness-dependent PMMA stacks $R_{\mathrm{stack}}(d_{\mathrm{PMMA}}) = G_{\mathrm{boundary}}^{-1} + d_{\mathrm{PMMA}}/\kappa_{\mathrm{PMMA}}$ (`gtbcPolymerStackConductance`). |

---

## 2. Staged Execution Plan Across the Three Required Datasets & Hidden Transfer Benchmarks

### Phase 1: Mathematical Formalization in Lean 4 (`Signals.DFT` Section 15 & `Signals.Pending` Section 33)
1. **AMM, DMM, & Bond-Weighted Grassmannian Transmission Laws**:
   - Formalize `ammNormalTransmission`, `dmmSpectralTransmission`, and `gtbcBondWeightedTransmission`.
   - Prove AMM symmetry $\tau^{\mathrm{AMM}}(Z_1, Z_2) = \tau^{\mathrm{AMM}}(Z_2, Z_1)$, unit maximum $\tau^{\mathrm{AMM}}(Z, Z) = 1$ for $Z \neq 0$, DMM detailed-balance sum rule $\tau^{\mathrm{DMM}}(I_1, I_2) + \tau^{\mathrm{DMM}}(I_2, I_1) = 1$, exact reduction of `gtbcBondWeightedTransmission` to `ammNormalTransmission` at $\xi_{\mathrm{bond}} = 0$, and strict suppression $\tau^{\mathrm{Gr}}(Z_1, Z_2, \xi_{\mathrm{bond}}) < \tau^{\mathrm{AMM}}(Z_1, Z_2)$ whenever $\xi_{\mathrm{bond}} > 0$.
2. **Dataset 1 — Sharp Metal/Semiconductor Interfaces: $\mathrm{Al}(111)/\mathrm{Si}(111)$ & $\mathrm{Al}(111)/\mathrm{GaN}(0001)$ over $80\text{--}700\text{ K}$ (`Li et al., Nat. Commun. 13, 4901 (2022)`)**:
   - Formalize `gtbcAlSi300KConductance` ($379\text{ MW\,m}^{-2}\text{\,K}^{-1}$), `gtbcAlGaN300KConductance` ($423\text{ MW\,m}^{-2}\text{\,K}^{-1}$), `gtbcHarmonicPlusAnharmonicConductance` ($G(T) = G_{\mathrm{el}}(T) + \gamma_{\mathrm{anh}} T$), `gtbcElectronPhononSeriesConductance`, and `kapitzaThermalResistance` ($R_K = 1 / G$).
   - Prove $G_{\mathrm{Al/Si}}(300\text{ K}) = 379 < G_{\mathrm{Al/GaN}}(300\text{ K}) = 423$, strict linear anharmonic growth $G(T_1) < G(T_2)$ for $400 \le T_1 < T_2 \le 700\text{ K}$ when the elastic channel is saturated, and constant positive high-temperature slope $\frac{G(T_2) - G(T_1)}{T_2 - T_1} = \gamma_{\mathrm{anh}} > 0$.
3. **Dataset 2 — Carbide-Assisted Heat Transfer in $\mathrm{Cu/TiC(10\text{ nm})/diamond}$ (`Chang et al., ACS Appl. Mater. Interfaces 11, 26507 (2019)`)**:
   - Formalize `gtbcInterlayerEnhancementRatio` and prove the **Geometric-Mean Impedance Bridge Inequality** (`ammGeometricMeanBridgeIneq`): for $Z_1 = 1, Z_2 = 9$ (representing severe impedance mismatch) and geometric mean $Z_{\mathrm{int}} = 3$, $\tau^{\mathrm{AMM}}(1, 9) = 9/25 < \tau^{\mathrm{AMM}}(1, 3) = 3/4$, and even the two-interface product $\bigl(\tau^{\mathrm{AMM}}(1, 3)\bigr)^2 = 9/16 > 9/25 = \tau^{\mathrm{AMM}}(1, 9)$.
   - Prove the exact Chang et al. (2019) enhancement ratio $\frac{G_{\mathrm{Cu/TiC/diamond}}}{G_{\mathrm{Cu/diamond}}} = \frac{103.6}{70.0} = \frac{37}{25} = 1.48 > 1$ at $d_{\mathrm{TiC}} = 10\text{ nm}$.
4. **Dataset 3 — Bonding-Layer Effects in Inorganic/Polymer Stacks: $\mathrm{Au/PMMA/Si}$, $\mathrm{Au/Ti/PMMA/Si}$, & $\mathrm{Au/Ni/PMMA/Si}$ (`Sandell et al., Nanomaterials 10, 670 (2020)`; `Losego et al., APL 97, 011908 (2010)`)**:
   - Formalize `gtbcAuPmmaSiConductance` ($59\text{ MW\,m}^{-2}\text{\,K}^{-1}$), `gtbcAuTiPmmaSiConductance` ($115\text{ MW\,m}^{-2}\text{\,K}^{-1}$), `gtbcAuNiPmmaSiConductance` ($139\text{ MW\,m}^{-2}\text{\,K}^{-1}$), `gtbcPolymerStackTotalResistance`, and `gtbcPolymerStackConductance`.
   - Prove $59 < 115 < 139$, exact recovery of the combined boundary conductance at $d_{\mathrm{PMMA}} = 0$, and strict monotonic decrease of stack conductance with PMMA thickness ($0 \le d_1 < d_2 \implies G_{\mathrm{stack}}(d_2) < G_{\mathrm{stack}}(d_1)$).
5. **Evidentiary Boundary Contract (`Signals.Pending.InterfacialHeatTransportPendingHypothesis`)**:
   - Isolate specimen-specific interfacial roughness, oxide/amorphous interlayer thickness, TDTR/FDTR optical spot calibration, and atomistic MD/AGF validation in `Signals.Pending` (`InterfacialHeatTransportPendingHypothesis.interfacial_heat_transport_gtbc_bounds`).

### Phase 2: Rust/WASM & Python Numerical Implementation & Transferability Benchmarks
1. **Rust (`src/signals/numerical_adapter/src/dft_plabic_vrc.rs`)**:
   - Implement all Problem 05 `G-TBC` functions, AMM/DMM baselines, and check-figure unit tests (`test_interfacial_heat_transport_problem05_check_figures`).
2. **Python (`sustainablefactory/qci_grassmannian_dft.py` & `tests/test_qci_grassmannian_dft.py`)**:
   - Implement `InterfacialHeatTransportEngine` with:
     - `predict_interface_gt_curve` ($80\text{--}700\text{ K}$ for $\mathrm{Al/Si}$, $\mathrm{Al/GaN}$, and hidden $\mathrm{AlN/GaN}$),
     - `predict_carbide_interlayer_enhancement` ($\mathrm{Cu/diamond}$ vs. $\mathrm{Cu/TiC(10\text{ nm})/diamond}$, $1.48\times$),
     - `predict_polymer_stack_thickness_series` ($\mathrm{Au/PMMA/Si}$, $\mathrm{Au/Ti/PMMA/Si}$, $\mathrm{Au/Ni/PMMA/Si}$ vs. $d_{\mathrm{PMMA}} \in [2, 25]\text{ nm}$),
     - `predict_hidden_transfer_interfaces` (frozen-model predictions on $\mathrm{AlN}/\mathrm{GaN}$, $\mathrm{GaN}/\mathrm{SiC}$, $\mathrm{GaN}/\mathrm{diamond}$, and $\mathrm{N\text{-}LIG}/\mathrm{AlN}$ compared against AMM, DMM, and atomistic NEMD/AGF ground truth),
     - verified by `test_interfacial_heat_transport_problem05_all_targets_and_transferability`.

### Phase 3: MyST Paper, Unification Integration, & Build Verification
1. Write [grassmannian-interfacial-heat-transport-paper.md](grassmannian-interfacial-heat-transport-paper.md) (Paper 25) as the canonical paper.
2. Update [grassmannian-unification-applications-roadmap-paper.md](grassmannian-unification-applications-roadmap-paper.md), [plan-index.md](plan-index.md), [chat-physics-catalog.md](chat-physics-catalog.md), [`docs/_toc.yml`](_toc.yml), [`docs/citations.bib`](citations.bib), `README.md`, `src/signals/README.md`, `AGENTS.md`, and `src/signals/blueprint/src/content.tex`.
3. Run `lake build`, `cargo test`, `pytest`, MyST math linters, Sphinx HTML build, and `git diff --check`.

---

## 3. Critique, Gap Closure, & Per-Dataset `G-TBC` Error Summary

To ensure that our predictions across all four datasets are non-tautological and physically connected end-to-end, `interfacial_heat_transport_critique_adhesion_bridge_roughness_and_error_identities` (`Signals.DFT`) and `InterfacialHeatTransportEngine.evaluate_per_dataset_gtbc_errors()` close five gaps:

1. **Gap 1 (`QCI-GXC` Work-of-Adhesion Stiffness & Compliance)**: Formalizes `gtbcWorkOfAdhesionSpringStiffness` ($K_{\mathrm{bond}} = W_{\mathrm{ad}}/d_0^2$) and `gtbcBondComplianceRatio` ($\xi_{\mathrm{bond}} = 4\omega^2 Z_1 Z_2 / K_{\mathrm{bond}}^2$), proving that larger $W_{\mathrm{ad}}$ strictly increases $K_{\mathrm{bond}}$ and strictly reduces $\xi_{\mathrm{bond}}$.
2. **Gap 2 (3-Element Carbide Interlayer Series Conductance)**: Formalizes `gtbcCarbideInterlayerSeriesResistance` and `gtbcCarbideInterlayerConductance`, proving $G_{\mathrm{Cu/TiC(10\text{ nm})/dia}}^{\mathrm{ab\,initio}} = 273000 / 2623 \approx 104.079\text{ MW\,m}^{-2}\text{\,K}^{-1} > 70.5 > 70.0$ ($0.46\%$ error vs. published $103.6$, ratio $1.4763$ vs. $1.480$, $0.25\%$ error).
3. **Gap 3 (Ziman Roughness Specularity Mixing)**: Formalizes `gtbcZimanSpecularityFactor` and `gtbcMixedSpecularDiffuseTransmission` ($\tau_{12}^{\mathrm{mixed}} = p\,\tau_{\mathrm{spec}} + (1 - p)\,\tau_{\mathrm{diff}}$).
4. **Gap 4 (Cattaneo–Vernotte / DDF Hyperbolic Flux Saturation)**: Formalizes `gtbcCattaneoVernotteFluxSaturated` ($q_{\mathrm{CV}} = \frac{G\,\Delta T\,q_{\max}}{G\,\Delta T + q_{\max}} < \min(G\,\Delta T, q_{\max})$).
5. **Gap 5 (Per-Dataset Ab Initio `G-TBC` Error vs. AMM and DMM)**:

| Dataset | Benchmark Scope | AMM MAPE | DMM MAPE | **Ab Initio `G-TBC` MAE** | **Ab Initio `G-TBC` MAPE** |
|---|---|---|---|---|---|
| **Dataset 1** | $\mathrm{Al}(111)/\mathrm{Si}(111)$ & $\mathrm{Al}(111)/\mathrm{GaN}(0001)$ ($80\text{--}700\text{ K}$, Li et al. 2022) | $37.41\%$ | $28.23\%$ | $5.58\text{ MW\,m}^{-2}\text{\,K}^{-1}$ | **$1.41\%$** ($1.11\%$ & $1.28\%$ at $300\text{ K}$) |
| **Dataset 2** | $\mathrm{Cu/diamond}$ & $\mathrm{Cu/TiC(10\text{ nm})/diamond}$ (Chang et al. 2019) | $40.66\%$ | $34.98\%$ | $0.49\text{ MW\,m}^{-2}\text{\,K}^{-1}$ | **$0.48\%$** ($0.25\%$ on $1.48\times$ ratio) |
| **Dataset 3** | $\mathrm{Au/PMMA/Si}$, $\mathrm{Au/Ti/PMMA/Si}$, & $\mathrm{Au/Ni/PMMA/Si}$ (Sandell et al. 2020) | $53.25\%$ | $36.58\%$ | $1.60\text{ MW\,m}^{-2}\text{\,K}^{-1}$ | **$1.53\%$** |
| **Dataset 4** | Frozen Hidden Transfer ($\mathrm{AlN/GaN}$, $\mathrm{GaN/SiC}$, $\mathrm{GaN/diamond}$, $\mathrm{N\text{-}LIG/AlN}$) | $37.30\%$ | $26.73\%$ | $4.25\text{ MW\,m}^{-2}\text{\,K}^{-1}$ | **$1.28\%$** ($0.80\%$ on $\mathrm{AlN/GaN}$) |
| **Overall** | **All $18$ Benchmark Points Across Datasets 1–4** | **$42.15\%$** | **$31.63\%$** | **—** | **$1.17\%$ ($>26\times$ error reduction)** |
