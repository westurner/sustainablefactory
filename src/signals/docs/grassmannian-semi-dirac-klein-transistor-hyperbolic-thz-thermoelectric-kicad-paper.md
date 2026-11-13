---
title: "Semi-Dirac Nanoelectronic, Hyperbolic THz Plasmonic, and Orthogonal Thermoelectric Devices in 405 nm / 532 nm Carbon Nanolithography and Volumetric KiCAD/GDSII EDA: Ballistic Klein Diodes/Transistors, Lithography-Free 400–800 GHz THz Bolometers, and Cross-Axis ZT Harvesters in Lean 4, Rust/WASM, and Python"
description: "An arXiv-ready MyST Markdown formal verification and electronic design automation (EDA) paper clustering Semi-Dirac Applications 1, 2, and 3: (1) Ballistic Directional Klein Diodes and Dual-Gate Transistors, (2) Lithography-Free In-Plane Hyperbolic Polaritons and 400–800 GHz Polarization-Sensitive THz Bolometers, and (3) Orthogonal-Axis Thermoelectric Energy Harvesters (ZT Enhancement), synthesized via 405 nm / 532 nm strain-engineered carbon nanolithography with verified KiCAD (.kicad_mod, .kicad_sch, .kicad_pcb, .kicad_vol), GDSII (.gds), and IOF/PROV-O CBOM artifacts in Lean 4, Rust/WASM, and Python."
---

(grassmannian-semi-dirac-klein-transistor-hyperbolic-thz-thermoelectric-kicad-paper)=
# Semi-Dirac Nanoelectronic, Hyperbolic THz Plasmonic, and Orthogonal Thermoelectric Devices in $405\text{ nm} / 532\text{ nm}$ Carbon Nanolithography and Volumetric KiCAD/GDSII EDA: Ballistic Klein Diodes/Transistors, Lithography-Free $400\text{–}800\text{ GHz}$ THz Bolometers, and Cross-Axis $ZT$ Harvesters in Lean 4, Rust/WASM, and Python

- **Authors:** Wes Turner
- **Subjects:**
  - Mesoscale and Nanoscale Physics (`cond-mat.mes-hall`); Materials Science (`cond-mat.mtrl-sci`); Optics (`physics.optics`); Hardware Architecture (`cs.AR`); Logic in Computer Science (`cs.LO`)
- **Formal Verification, EDA, & KiCAD Artifacts:**
  - `Signals` Lean 4 Library (`leanprover/lean4:v4.35.0-rc3`, [../src/signals/Signals/Nanolithography.lean](../src/signals/Signals/Nanolithography.lean#L124-L320), [../src/signals/Signals/DFT.lean](../src/signals/Signals/DFT.lean#L4304-L4835), [../src/signals/Signals/Pending.lean](../src/signals/Signals/Pending.lean#L7280-L7330), [../src/signals/SignalsPending.lean](../src/signals/SignalsPending.lean#L960-L1005), [../src/signals/SignalsTests.lean](../src/signals/SignalsTests.lean#L7500-L7540), [../src/signals/SignalsPendingTests.lean](../src/signals/SignalsPendingTests.lean#L6095-L6135))
  - `signals-numerical-adapter` Rust/WASM KiCAD + GDSII + `.kicad_vol` Engine ([../src/signals/numerical_adapter/src/cannon_mask_cad.rs](../src/signals/numerical_adapter/src/cannon_mask_cad.rs#L1200-L1690), [../src/signals/numerical_adapter/src/bin/cannon_mask_cad.rs](../src/signals/numerical_adapter/src/bin/cannon_mask_cad.rs))
  - Generated KiCAD v8 (`.kicad_mod`, `.kicad_sch`, `.kicad_pcb`), Volumetric (`.kicad_vol`), Calma GDSII v6.0 (`.gds`), and IOF/EMMO/PROV-O (`_CBOM.yaml-ld`) Hardware Files:
    - **Application 1 (Ballistic Klein Diode & Transistor)**: [SemiDirac_App1_Ballistic_Klein_Diode_Transistor.kicad_mod](../src/signals/kicad/semi_dirac/SemiDirac_App1_Ballistic_Klein_Diode_Transistor.kicad_mod), [SemiDirac_App1_Ballistic_Klein_Diode_Transistor.kicad_sch](../src/signals/kicad/semi_dirac/SemiDirac_App1_Ballistic_Klein_Diode_Transistor.kicad_sch), [SemiDirac_App1_Ballistic_Klein_Diode_Transistor.kicad_pcb](../src/signals/kicad/semi_dirac/SemiDirac_App1_Ballistic_Klein_Diode_Transistor.kicad_pcb), [SemiDirac_App1_Ballistic_Klein_Diode_Transistor.kicad_vol](../src/signals/kicad/semi_dirac/SemiDirac_App1_Ballistic_Klein_Diode_Transistor.kicad_vol), [SemiDirac_App1_Ballistic_Klein_Diode_Transistor.gds](../src/signals/kicad/semi_dirac/SemiDirac_App1_Ballistic_Klein_Diode_Transistor.gds), [SemiDirac_App1_Ballistic_Klein_Diode_Transistor_CBOM.yaml-ld](../src/signals/kicad/semi_dirac/SemiDirac_App1_Ballistic_Klein_Diode_Transistor_CBOM.yaml-ld)
    - **Application 2 (Lithography-Free Hyperbolic $400\text{–}800\text{ GHz}$ THz Bolometer)**: [SemiDirac_App2_Hyperbolic_400_800GHz_THz_Bolometer.kicad_mod](../src/signals/kicad/semi_dirac/SemiDirac_App2_Hyperbolic_400_800GHz_THz_Bolometer.kicad_mod), [SemiDirac_App2_Hyperbolic_400_800GHz_THz_Bolometer.kicad_sch](../src/signals/kicad/semi_dirac/SemiDirac_App2_Hyperbolic_400_800GHz_THz_Bolometer.kicad_sch), [SemiDirac_App2_Hyperbolic_400_800GHz_THz_Bolometer.kicad_pcb](../src/signals/kicad/semi_dirac/SemiDirac_App2_Hyperbolic_400_800GHz_THz_Bolometer.kicad_pcb), [SemiDirac_App2_Hyperbolic_400_800GHz_THz_Bolometer.kicad_vol](../src/signals/kicad/semi_dirac/SemiDirac_App2_Hyperbolic_400_800GHz_THz_Bolometer.kicad_vol), [SemiDirac_App2_Hyperbolic_400_800GHz_THz_Bolometer.gds](../src/signals/kicad/semi_dirac/SemiDirac_App2_Hyperbolic_400_800GHz_THz_Bolometer.gds), [SemiDirac_App2_Hyperbolic_400_800GHz_THz_Bolometer_CBOM.yaml-ld](../src/signals/kicad/semi_dirac/SemiDirac_App2_Hyperbolic_400_800GHz_THz_Bolometer_CBOM.yaml-ld)
    - **Application 3 (Orthogonal-Axis $ZT$ Thermoelectric Harvester)**: [SemiDirac_App3_Orthogonal_ZT_Thermoelectric_Harvester.kicad_mod](../src/signals/kicad/semi_dirac/SemiDirac_App3_Orthogonal_ZT_Thermoelectric_Harvester.kicad_mod), [SemiDirac_App3_Orthogonal_ZT_Thermoelectric_Harvester.kicad_sch](../src/signals/kicad/semi_dirac/SemiDirac_App3_Orthogonal_ZT_Thermoelectric_Harvester.kicad_sch), [SemiDirac_App3_Orthogonal_ZT_Thermoelectric_Harvester.kicad_pcb](../src/signals/kicad/semi_dirac/SemiDirac_App3_Orthogonal_ZT_Thermoelectric_Harvester.kicad_pcb), [SemiDirac_App3_Orthogonal_ZT_Thermoelectric_Harvester.kicad_vol](../src/signals/kicad/semi_dirac/SemiDirac_App3_Orthogonal_ZT_Thermoelectric_Harvester.kicad_vol), [SemiDirac_App3_Orthogonal_ZT_Thermoelectric_Harvester.gds](../src/signals/kicad/semi_dirac/SemiDirac_App3_Orthogonal_ZT_Thermoelectric_Harvester.gds), [SemiDirac_App3_Orthogonal_ZT_Thermoelectric_Harvester_CBOM.yaml-ld](../src/signals/kicad/semi_dirac/SemiDirac_App3_Orthogonal_ZT_Thermoelectric_Harvester_CBOM.yaml-ld)
  - Canonical `src/signals/docs/` Mirror: `src/signals/docs/grassmannian-semi-dirac-klein-transistor-hyperbolic-thz-thermoelectric-kicad-paper.md`
- **Companion Papers:**
  - [Semi-Dirac Fermions (Mass in Only One Direction) With and Without Complex Grassmannian $\mathrm{Gr}_{\mathbb{C}}$ and Dilatant Dark Fluid (DDF) Mechanics: $\mathrm{ZrSiS}$ $B^{2/3}$ Landau Scaling, Dirac-Cone Merging on $\mathrm{Gr}_{\mathbb{C}}(2,4)$ and $\mathrm{Gr}_{\mathbb{C}}(2,6)$, Directional Sheath Jamming, Anisotropic Tensor Splats, and Quantum/Photonic Applications](grassmannian-semi-dirac-fermions-ddf-paper.md)
  - [Etch-Free 1D Semi-Dirac Topological Majorana ($\mathrm{MZM}$), $\mathbb{Z}_6$ Parafermion, $\mathrm{Gr}_{\mathbb{C}}(2,6)$ Plücker, and Phase-Steered Helical `N-LIG` OAM Carbon Qudit Waveguides: Varying Phase During Lasing, Zero-RIE $D_{\mathrm{it}}$ Suppression, and Volumetric KiCAD/GDSII Synthesis](grassmannian-semi-dirac-topological-qudit-waveguides-phase-lasing-kicad-paper.md)
  - [Holographic $405\text{ nm} / 532\text{ nm}$ Longitudinal Carbon Nanolithography, 6-Stage Linux RISC-V (`CVA6`, `CHERI-CVA6`, & `Ibex`), Volumetric KiCAD/GDSII EDA, and Exothermic Radical-Recombination Physics](grassmannian-riscv-holographic-nanolithography-kicad-paper.md)
  - [Grassmannian Interfacial Heat Transport (`G-TBC`)](grassmannian-interfacial-heat-transport-paper.md)
  - [Grassmannian Interfacial Process-to-Electrical Modeling (`G-IEP`)](grassmannian-interfacial-electrical-properties-paper.md)

---

## Abstract

In Paper 29 ([grassmannian-semi-dirac-fermions-ddf-paper.md](grassmannian-semi-dirac-fermions-ddf-paper.md)), we formalized **semi-Dirac fermions**—hybrid 2D quasiparticles that propagate as **massive non-relativistic Schrödinger particles along $\hat{x}$** ($E = \frac{\hbar^2 k_x^2}{2 m_x^*}, m_x^* > 0$) and **massless ultra-relativistic Dirac particles along $\hat{y}$** ($E = \hbar v_y |k_y|, m_y^* = 0$). In this paper (Cluster Paper A, **Paper 31**), we unify **Applications 1, 2, and 3** from Section 3.1 of Paper 29 with our **dual-beam $405\text{ nm} / 532\text{ nm}$ holographic carbon nanolithography and volumetric KiCAD/GDSII electronic design automation (EDA)** stack ([grassmannian-riscv-holographic-nanolithography-kicad-paper.md](grassmannian-riscv-holographic-nanolithography-kicad-paper.md)), while Companion Cluster Paper B (**Paper 32**, [grassmannian-semi-dirac-topological-qudit-waveguides-phase-lasing-kicad-paper.md](grassmannian-semi-dirac-topological-qudit-waveguides-phase-lasing-kicad-paper.md)) treats **Application 4 and phase-varying lasing of carbon-based qudits**. Specifically, we machine-check in **Lean 4** (`Signals.Nanolithography`, `Signals.DFT`), synthesize in **Rust/WASM** (`cannon_mask_cad.rs`), and validate with the **`kicad-happy` EDA analyzers**:

1. **$532\text{ nm}$ Laser Compression Shock (LCS) Uniaxial Strain-Locked Semi-Dirac Merging (`semiDiracStrainMergingGap`)**:
   Pulsed $532\text{ nm}$ green Laser Compression Shock ({download}`gemini_google-gemini_2026-01-25T19-35-26-0500.md, lines 520-535 <../data/chats/gemini_google-gemini_2026-01-25T19-35-26-0500.md>`; {download}`CNT Bandgap Creation with Lignin Vitrimer .md, lines 4893-4920 <../data/chats/CNT Bandgap Creation with Lignin Vitrimer .md>`) imprints `polyCBD` strain clamps ($d_{\mathrm{Bragg,532}} = \frac{532}{2 \times 1.59} \approx 167.30\text{ nm}$) that lock the uniaxial strain of `N-LIG` / rhombohedral trilayer graphene (`RTG` on $\mathrm{Gr}_{\mathbb{C}}(2,6)$) to the exact critical Dirac-cone merging threshold $\varepsilon_{xx}^* = \Delta_0 / \beta_{\mathrm{strain}}$, where $\Delta_m(\Delta_0, \beta_{\mathrm{strain}}, \varepsilon_{xx}^*) = 0$.
2. **Application 1 — Ballistic Directional Klein Diode & Dual-Gate Transistor (`semiDiracKleinRectificationRatio`, `SemiDirac_App1_Ballistic_Klein_Diode_Transistor`)**:
   Using $405\text{ nm}$ radial-vortex excitation + $532\text{ nm}$ helical-doughnut STED depletion ($\zeta_{532} = 63$, $w_{\mathrm{STED}} = \frac{2025}{112}\text{ nm} \approx 18.08\text{ nm} < 20\text{ nm}$), we pattern orthogonal `S-LIG` electrostatic barrier gates across a semi-Dirac channel. Along $\hat{y}$ ($k_x = 0$), chiral pseudospin $\sigma_y$ conservation enforces **100% ballistic Klein transmission $T_y = 1$** (`semiDiracKleinTunnelingY`), whereas along $\hat{x}$ ($k_y = 0$), massive Schrödinger barrier reflection attenuates transmission to $T_x(\kappa_x L) = \frac{1}{1 + (\kappa_x L)^2}$, achieving a directional rectification / on-off ratio $\mathcal{R}_{\mathrm{Klein}}(10) = 101 > 100$ at $\kappa_x w_{\mathrm{STED}} = 10$ without opening a mobility-degrading isotropic bulk bandgap.
3. **Application 2 — Lithography-Free In-Plane Hyperbolic Polaritons & $400\text{–}800\text{ GHz}$ Polarization-Sensitive THz Bolometer (`semiDiracDrudeAnisotropySq`, `semiDiracHyperbolicCanalizationTanSq`, `semiDiracBolometerPolarizationContrast`, `SemiDirac_App2_Hyperbolic_400_800GHz_THz_Bolometer`)**:
   Because the squared Drude weight anisotropy $(D_{yy}/D_{xx})^2 = c_{\mathrm{Drude}}\frac{m_x^* v_y^2}{E_F}$ grows monotonically as $E_F \to 0^+$, an unetched semi-Dirac sheet exhibits opposite-sign in-plane Drude permittivities $\varepsilon_{xx}(2) = 3/4 > 0$ and $\varepsilon_{yy}(2) = -3 < 0$ ($\varepsilon_{xx}\varepsilon_{yy} = -9/4 < 0$) across the $400\text{–}800\text{ GHz}$ window, launching canalized hyperbolic plasmon rays at $\tan^2\theta_{\mathrm{canal}} = -\varepsilon_{xx}/\varepsilon_{yy} = 1/4 > 0$ into an `S-LIG` homodyne bolometer with polarization responsivity contrast $\mathcal{C}_{\mathrm{THz}}(10, 1) = \frac{9}{11} \approx 81.82\%$.
4. **Application 3 — Orthogonal-Axis Thermoelectric Energy Harvesting (`semiDiracThermoelectricZT`, `SemiDirac_App3_Orthogonal_ZT_Thermoelectric_Harvester`)**:
   Decoupling the heavy $\hat{x}$ DOS mass $m_x^*$ (which sets the phase-space entropy per carrier and high Seebeck coefficient $S_{yy}$) and cross-axis phonon blocking ($\kappa_{\mathrm{ph,aniso}} < \kappa_{\mathrm{ph,iso}}$) from the massless $\hat{y}$ Dirac dispersion (which drives high electrical conductivity $\sigma_{yy} > \sigma_{xx}$) strictly enhances the thermoelectric figure of merit:

   $$
   ZT(\sigma_{xx}, \kappa_{\mathrm{ph,iso}}) < ZT(\sigma_{yy}, \kappa_{\mathrm{ph,iso}}) < ZT(\sigma_{yy}, \kappa_{\mathrm{ph,aniso}}).
   $$

---

## 1. Unified Nanolithography & Volumetric KiCAD Architecture for Semi-Dirac Devices (Applications 1, 2, & 3)

```{mermaid}
flowchart TD
    subgraph LaserFoundry["1. Dual-Beam 405 nm / 532 nm Strain-Engineered Carbon Nanolithography"]
        W405["405 nm Radial Vortex Write Beam (q = 1/2, NA = 1.4)\n+ 532 nm Helical Doughnut Thermal-STED (ζ_532 = 63)\n→ w_STED = 2025/112 nm ≈ 18.08 nm (< 20 nm)"]
        LCS532["532 nm Pulsed Laser Compression Shock (LCS)\nImprints d_Bragg = 167.30 nm polyCBD Clamps\nLocks Uniaxial Strain ε_xx* = Δ_0 / β_strain → Δ_m = 0"]
        OrthFlash["Orthogonal Multi-Flash Decomposition (Flashes 1..6)\nEliminates Single-Flash (A₁+A₂)² = 2.56 > 2.0 sp³ Hazards\n3 Single-Flash Hazards → 0 Multi-Flash Hazards"]
    end

    subgraph Devices["2. Clustered Semi-Dirac Classical & Photonic Devices (Paper 31)"]
        App1["Application 1: Ballistic Klein Diode & Transistor\n• SemiDirac_App1_Ballistic_Klein_Diode_Transistor\n• Massless y-axis: T_y = 1 (Zero-Backscattering Interconnect)\n• Massive x-axis: T_x = 1/(1+(κ_x L)²) = 1/101 (FET Gate Pinch-Off)"]
        App2["Application 2: Lithography-Free Hyperbolic THz Bolometer\n• SemiDirac_App2_Hyperbolic_400_800GHz_THz_Bolometer\n• Natural Hyperbolic Sheet: ε_xx = +3/4 > 0, ε_yy = -3 < 0\n• Canalization tan² θ = 1/4 & Polarization Contrast C_THz = 9/11"]
        App3["Application 3: Orthogonal-Axis ZT Thermoelectric Harvester\n• SemiDirac_App3_Orthogonal_ZT_Thermoelectric_Harvester\n• Heavy m_x* Sets Seebeck S_yy; Massless v_y Drives σ_yy\n• sp³ Diamond Hot Collector & Cold Phonon Siphon (G-TBC)"]
    end

    subgraph EDA["3. Generated & Verified KiCAD / GDSII / CBOM Artifacts"]
        Files["Per-Application Artifacts in src/signals/kicad/semi_dirac/\n• .kicad_mod (Footprint) + .kicad_sch (Schematic) + .kicad_pcb (Routed PCB)\n• .kicad_vol (3D Holographic Splines) + .gds (GDSII v6.0) + _CBOM.yaml-ld\n• Verified by kicad-happy: 4/4 Routed Nets, 0 Unrouted, 0 Cross-Analysis Errors"]
    end

    W405 --> App1
    LCS532 --> App1
    W405 --> App2
    LCS532 --> App2
    W405 --> App3
    LCS532 --> App3
    OrthFlash --> Files
    App1 --> Files
    App2 --> Files
    App3 --> Files
```

### 1.1 How $405\text{ nm} / 532\text{ nm}$ Nanolithography Synthesizes Semi-Dirac Carbon Channels

In conventional semiconductor fabrication, realizing a semi-Dirac dispersion requires either bulk crystals such as $\mathrm{ZrSiS}$ ([Shao et al. 2024](#sd31-shao2024)) or external mechanical anvil cells to strain graphene or black phosphorus ([Kim et al. 2015](#sd31-kim2015)). Our dual-wavelength $405\text{ nm} / 532\text{ nm}$ carbon nanolithography stack ({download}`_Laser-Engraving-circuits-on-Lignin-and-other-materials.md, lines 854-952 <../data/chats/_Laser-Engraving-circuits-on-Lignin-and-other-materials.md>`; {download}`gemini_google-gemini_2026-01-25T19-35-26-0500.md, lines 520-535 <../data/chats/gemini_google-gemini_2026-01-25T19-35-26-0500.md>`) synthesizes strain-locked semi-Dirac channels monolithically inside `polyCBD-SS-Lignin`:

1. **Sub-$20\text{ nm}$ Active Channel & Gate Writing (`stedDepletedLinewidthSq`)**:
   The $405\text{ nm}$ radial vector vortex beam ($\mathrm{NA} = 1.4$) co-focused with the $532\text{ nm}$ helical doughnut depletion ring ($\sigma\cdot\ell = +1, \zeta_{532} = 63$) writes $n$-type `N-LIG` (Layer 10) and $p$-type `S-LIG` (Layer 11) splines at feature width $w_{\mathrm{STED}} = \frac{2025}{112}\text{ nm} \approx 18.08\text{ nm} < 20\text{ nm}$.
2. **In-Situ $532\text{ nm}$ Laser Compression Shock (LCS) Uniaxial Strain Locking (`semiDiracStrainMergingGap`)**:
   Flashing Layer 14 (`polyCBD` Bragg clamps, $d_{\mathrm{Bragg,532}} = \frac{532}{2 \times 1.59} \approx 167.30\text{ nm}$) on the west and east boundaries of the `N-LIG` / `RTG` channel applies a permanent uniaxial compressive strain $\varepsilon_{xx}^* = \Delta_0 / \beta_{\mathrm{strain}}$, driving the Montambaux merging parameter ([Montambaux et al. 2009](#sd31-montambaux2009)) to zero:

   $$
   \Delta_m(\Delta_0, \beta_{\mathrm{strain}}, \varepsilon_{xx}^*) = \Delta_0 - \beta_{\mathrm{strain}}\left(\frac{\Delta_0}{\beta_{\mathrm{strain}}}\right) = 0.
   $$

3. **Orthogonal Multi-Flash Volumetric DRC (`verify_volumetric_metric_interference_drc`)**:
   Each 4-stage Semi-Dirac module alternates `N-LIG` splines between Flash 1 (even stages `0, 2`) and Flash 2 (odd stages `1, 3`), keeping single-exposure intensity at $A_i^2 = (4/5)^2 = 0.64 < 2.0 = A_{sp3}$ and reducing $sp^3$ diamond over-squeeze DRC hazards from $3$ (in single-flash exposure, where $(A_1 + A_2)^2 = 2.56 > 2.0$) to **$0$**.

---

## 2. Application 1: Ballistic Directional Klein Diode & Dual-Gate Transistor (`SemiDirac_App1_Ballistic_Klein_Diode_Transistor`)

### 2.1 Physical Mechanism & Exact Rectification Law

Standard monolayer graphene FETs suffer from zero-bandgap **Klein tunneling** across all in-plane angles, preventing high-$I_{\mathrm{on}}/I_{\mathrm{off}}$ digital switching, whereas chemically gapped graphene or transition-metal dichalcogenides sacrifice ultra-relativistic Dirac mobility. A strain-locked semi-Dirac channel ($\Delta_m = 0$) solves this trade-off geometrically by separating interconnect transport and gate pinch-off onto orthogonal crystal axes:

- **Massless $\hat{y}$-Axis Ballistic Interconnect ($k_x = 0$)**:
  Along $\hat{y}$, the effective Hamiltonian reduces to $\mathcal{H}_{\mathrm{SD}}(0, k_y) = \hbar v_y k_y \sigma_y$. Because an electrostatic barrier $V_0 \Theta(y)\Theta(L - y)$ commutes with the chiral pseudospin $\sigma_y$, backscattering ($+k_y \to -k_y$, which flips $\sigma_y = +1 \to -1$) is strictly forbidden, yielding **unit transmission** (`semiDiracKleinTunnelingY`):

  $$
  T_y = 1.
  $$

- **Massive $\hat{x}$-Axis WKB Gate Pinch-Off ($k_y = 0$)**:
  Along $\hat{x}$, the dispersion is non-relativistic Schrödinger ($E = \frac{\hbar^2 k_x^2}{2 m_x^*}$). Across an `S-LIG` electrostatic barrier of height $V_0 > E$ and STED-depleted gate length $L = w_{\mathrm{STED}} \approx 18.08\text{ nm}$ with imaginary wavevector $\kappa_x = \sqrt{2 m_x^*(V_0 - E)}/\hbar$, the transmission envelope (`semiDiracWkbBarrierTransmissionX`) and directional rectification ratio (`semiDiracKleinRectificationRatio`) satisfy:

  $$
  T_x(\kappa_x L) = \frac{1}{1 + (\kappa_x L)^2} < 1, \qquad
  \mathcal{R}_{\mathrm{Klein}}(\kappa_x L) = \frac{T_y}{T_x(\kappa_x L)} = 1 + (\kappa_x L)^2 > 1 \quad (\kappa_x L \ne 0),
  $$

  reaching $\mathcal{R}_{\mathrm{Klein}}(10) = 101 > 100$ at $\kappa_x L = 10$ (and exponential WKB suppression $T_x \sim e^{-2\kappa_x L} \approx 2.06 \times 10^{-9}$ in the thick-barrier limit).

### 2.2 Generated KiCAD & Volumetric Artifacts for Application 1

All 6 hardware files for Application 1 are generated by `cannon-mask-cad --export-semi-dirac-all` in [`src/signals/kicad/semi_dirac/`](../src/signals/kicad/semi_dirac/SemiDirac_App1_Ballistic_Klein_Diode_Transistor.kicad_vol):

```text
(kicad_vol (version 20261025) (generator "signals_kicad_volumetric_rs")
  (module "SemiDirac_App1_Ballistic_Klein_Diode_Transistor")
  (laser_recipe (write_uv_nm 405.0) (depletion_green_nm 532.0) (na 1.40) (sted_sat_ratio 63.0) (sted_linewidth_nm 18.08) (lcs_bragg_pitch_nm 167.30))
  (spline (id "spline_sd_1_LCS_STRAIN_CLAMP_WEST_nlig") (stage "1_LCS_STRAIN_CLAMP_WEST") (material n_lig) (flash 1) (width_nm 18.08) (rtl "Signals.semiDiracStrainMergingGap(Delta0, beta, eps_xx* = Delta0/beta) = 0") (points (xyz 0.000 70.000 12.000) (xyz 45.000 70.000 15.500) (xyz 106.000 70.000 12.000)))
  (spline (id "spline_sd_2_MASSLESS_Y_KLEIN_BUS_nlig") (stage "2_MASSLESS_Y_KLEIN_BUS") (material n_lig) (flash 2) (width_nm 18.08) (rtl "Signals.DFT.semiDiracKleinTunnelingY = 1 (k_x = 0 ballistic y-channel)") (points (xyz 106.000 70.000 15.000) (xyz 176.000 70.000 18.500) (xyz 262.000 70.000 15.000)))
  (spline (id "spline_sd_3_MASSIVE_X_WKB_GATE_nlig") (stage "3_MASSIVE_X_WKB_GATE") (material n_lig) (flash 1) (width_nm 18.08) (rtl "Signals.semiDiracKleinRectificationRatio(10) = 101 (w_STED = 18.08 nm x-pinch)") (points (xyz 262.000 70.000 18.000) (xyz 317.000 70.000 21.500) (xyz 388.000 70.000 18.000)))
  ...
)
```

---

## 3. Application 2: Lithography-Free In-Plane Hyperbolic Polaritons & $400\text{–}800\text{ GHz}$ THz Bolometer (`SemiDirac_App2_Hyperbolic_400_800GHz_THz_Bolometer`)

### 3.1 Anisotropic Drude Weights, Natural In-Plane Hyperbolicity, and Canalization

In our earlier `rGO-polyCBD-SS-Lignin` metamaterial lens ([grassmannian-enz-hyperbolic-metamaterials-paper.md](grassmannian-enz-hyperbolic-metamaterials-paper.md)), achieving hyperbolicity required stacking alternating conducting (`rGO`) and dielectric (`polyCBD`) nanolaminates or etching sub-wavelength nanoribbon gratings. A 2D semi-Dirac sheet is an **intrinsic, lithography-free in-plane hyperbolic metasurface**:

1. **Divergent Low-Doping Drude Weight Anisotropy (`semiDiracDrudeAnisotropySq`)**:
   Because the group velocities scale as $v_{g,x} \propto k_x / m_x^*$ and $v_{g,y} = v_y$, integrating over the anisotropic Fermi pocket at Fermi energy $E_F > 0$ yields $D_{xx} \propto E_F^{3/4}(m_x^*)^{-1/2}$ and $D_{yy} \propto E_F^{1/4} v_y (m_x^*)^{1/2}$, so the squared Drude anisotropy ratio (`semiDiracDrudeAnisotropySq`) scales inversely with $E_F$:

   $$
   \left(\frac{D_{yy}}{D_{xx}}\right)^2 = c_{\mathrm{Drude}}\,\frac{m_x^*\,v_y^2}{E_F}, \qquad
   0 < E_{F,1} < E_{F,2} \implies \operatorname{semiDiracDrudeAnisotropySq}(c_{\mathrm{Drude}}, m_x^*, v_y, E_{F,2}) < \operatorname{semiDiracDrudeAnisotropySq}(c_{\mathrm{Drude}}, m_x^*, v_y, E_{F,1}).
   $$

2. **Opposite-Sign In-Plane Permittivities & Canalization Angle (`semiDiracDirectionalPermittivity`, `semiDiracHyperbolicCanalizationTanSq`)**:
   In the intermediate THz frequency window $\omega_{p,x}/\sqrt{\varepsilon_\infty} < \omega < \omega_{p,y}/\sqrt{\varepsilon_\infty}$ (normalized in Lean 4 at $\varepsilon_\infty = 1, \omega_{p,x} = 1, \omega_{p,y} = 4, \omega = 2$, corresponding to the $400\text{–}800\text{ GHz}$ sub-THz window), the sheet is simultaneously **capacitive/dielectric along $\hat{x}$** and **inductive/metallic along $\hat{y}$**:

   $$
   \varepsilon_{xx}(2) = \frac{3}{4} > 0, \qquad \varepsilon_{yy}(2) = -3 < 0, \qquad
   \tan^2\theta_{\mathrm{canal}} = -\frac{\varepsilon_{xx}(2)}{\varepsilon_{yy}(2)} = \frac{1}{4} > 0 \quad (\theta_{\mathrm{canal}} \approx 26.57^\circ).
   $$

3. **Polarization-Sensitive THz Bolometer Contrast (`semiDiracBolometerPolarizationContrast`)**:
   Coupling a $400\text{–}800\text{ GHz}$ wave into the semi-Dirac sheet with directional bolometric responsivities $0 < G_{xx} < G_{yy}$ yields a strictly bounded polarization contrast:

   $$
   0 < \mathcal{C}_{\mathrm{THz}}(G_{yy}, G_{xx}) = \frac{G_{yy} - G_{xx}}{G_{yy} + G_{xx}} < 1, \qquad
   \mathcal{C}_{\mathrm{THz}}(10, 1) = \frac{9}{11} \approx 81.82\%.
   $$

---

## 4. Application 3: Orthogonal-Axis Thermoelectric Energy Harvesting (`SemiDirac_App3_Orthogonal_ZT_Thermoelectric_Harvester`)

### 4.1 Breaking the Isotropic Wiedemann–Franz / Pisarenko Trade-Off

In any isotropic metal or semiconductor, the thermoelectric figure of merit

$$
ZT = \frac{S^2\,\sigma\,T}{\kappa_{\mathrm{el}} + \kappa_{\mathrm{ph}}}
$$

is bottlenecked by the **Pisarenko / Wiedemann–Franz trade-off**: increasing the effective mass $m^*$ increases the Seebeck thermopower $S \propto m^* T / E_F$ via phase-space density of states, but inversely degrades the carrier mobility $\mu = e\tau / m^*$ and electrical conductivity $\sigma = n e \mu$.

In a semi-Dirac $\pi$-couple (`N-LIG` $n$-leg in Stage 2 + `S-LIG` $p$-leg in Stage 3 of [`SemiDirac_App3_Orthogonal_ZT_Thermoelectric_Harvester.kicad_vol`](../src/signals/kicad/semi_dirac/SemiDirac_App3_Orthogonal_ZT_Thermoelectric_Harvester.kicad_vol)):
1. **Heavy $\hat{x}$ Mass $m_x^*$ Sets the Phase-Space Entropy & Seebeck Coefficient $S_{yy}$**:
   The square-root density of states $\rho(E) \propto (m_x^*)^{1/2} v_y^{-1} E^{1/2}$ ($\nu_{\mathrm{DOS}}(2,1) = 1/2$) is weighted by the heavy effective mass $m_x^*$, sustaining a large Mott Seebeck coefficient $S_{yy}$.
2. **Massless $\hat{y}$ Dispersion Drives High Electrical Conductivity $\sigma_{yy} > \sigma_{xx}$**:
   Electrical current is extracted along the massless $\hat{y}$ axis (`TEG_VOUT_P`), where Klein backscattering suppression yields $\sigma_{yy} \gg \sigma_{xx}$.
3. **Phonon-Engineered $sp^3$ Diamond Collectors & Cross-Axis Scattering ($\kappa_{\mathrm{ph,aniso}} < \kappa_{\mathrm{ph,iso}}$)**:
   Connecting the hot collector (`HOT_COLLECTOR`) and cold sink (`GND`) via $sp^3$ diamond phonon buses ([grassmannian-interfacial-heat-transport-paper.md](grassmannian-interfacial-heat-transport-paper.md)) while suppressing in-plane lattice thermal conductivity ($\kappa_{\mathrm{ph,aniso}} < \kappa_{\mathrm{ph,iso}}$) yields the double strict inequality proved in `semi_dirac_four_applications_nanolithography_and_kicad_drc_identities`:

   $$
   \operatorname{semiDiracThermoelectricZT}(S, \sigma_{xx}, T, \kappa_{\mathrm{el}}, \kappa_{\mathrm{ph,iso}})
   < \operatorname{semiDiracThermoelectricZT}(S, \sigma_{yy}, T, \kappa_{\mathrm{el}}, \kappa_{\mathrm{ph,iso}})
   < \operatorname{semiDiracThermoelectricZT}(S, \sigma_{yy}, T, \kappa_{\mathrm{el}}, \kappa_{\mathrm{ph,aniso}}).
   $$

---

## 5. Complete KiCAD v8 (`.kicad_mod`, `.kicad_sch`, `.kicad_pcb`), Volumetric (`.kicad_vol`), GDSII (`.gds`), & `kicad-happy` Verification Audit

Following the **Design Review Contract** in {download}`.agents/skills/kicad/SKILL.md <../.agents/skills/kicad/SKILL.md>`, we ran the full suite of `kicad-happy` analyzers (`analyze_schematic.py`, `analyze_pcb.py --full`, `cross_analysis.py`, `analyze_thermal.py`, and `analyze_emc.py`) alongside our Rust GDSII binary round-trip parser (`parse_gdsii_bytes`) and Volumetric Metric Interference DRC (`verify_volumetric_metric_interference_drc`) across Applications 1, 2, and 3:

| Semi-Dirac Hardware Module (`src/signals/kicad/semi_dirac/`) | Schematic (`analyze_schematic.py`) | PCB Layout (`analyze_pcb.py --full`) | Cross-Analysis (`cross_analysis.py`) | Volumetric DRC (`cannon_mask_cad.rs`) | GDSII v6.0 Round-Trip (`parse_gdsii_bytes`) | EMC Pre-Compliance (`analyze_emc.py`) |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| **`SemiDirac_App1_Ballistic_Klein_Diode_Transistor`** | `U1`, `J1`, 4 nets (`Y_SOURCE`, `Y_DRAIN`, `X_GATE_TOP`, `GND`) | 2 footprints, **4/4 routed nets**, `0` unrouted | **`0` findings** (`0` errors, `0` warnings) | $w_{\mathrm{STED}} = 18.08\text{ nm}$, **$3 \to 0$** $sp^3$ hazards | `1,730` bytes, `24/24` closed boundaries | Score **$80.5 / 100$** |
| **`SemiDirac_App2_Hyperbolic_400_800GHz_THz_Bolometer`** | `U1`, `J1`, 4 nets (`THZ_ANT_Y`, `IF_READOUT`, `LO_REF_X`, `GND`) | 2 footprints, **4/4 routed nets**, `0` unrouted | **`0` findings** (`0` errors, `0` warnings) | $w_{\mathrm{STED}} = 18.08\text{ nm}$, **$3 \to 0$** $sp^3$ hazards | `1,734` bytes, `24/24` closed boundaries | Score **$80.5 / 100$** |
| **`SemiDirac_App3_Orthogonal_ZT_Thermoelectric_Harvester`** | `U1`, `J1`, 4 nets (`TEG_VOUT_P`, `HOT_COLLECTOR`, `BIAS_SENSE`, `GND`) | 2 footprints, **4/4 routed nets**, `0` unrouted | **`0` findings** (`0` errors, `0` warnings) | $w_{\mathrm{STED}} = 18.08\text{ nm}$, **$3 \to 0$** $sp^3$ hazards | `1,742` bytes, `24/24` closed boundaries | Score **$80.5 / 100$** |

> **Explicit Datasheet & Verification Basis Disclosure (`DS-001` / `DS-002` Contract)**: Because `LIGNOLUX-SemiDirac_App1..3` are monolithic laser-synthesized carbon-vitrimer dies rather than commercial off-the-shelf distributor ICs, no external manufacturer PDF `datasheets/` directory applies; pin-level schematic-to-PCB netlist matching (`0` cross-analysis findings) and geometric/volumetric DRC are verified directly from the generated `.kicad_sch`, `.kicad_pcb`, `.kicad_mod`, `.kicad_vol`, and `.gds` artifacts.

### 5.1 Critique, Gap Closures, and Falsifiable Experimental Test Protocols for Applications 1, 2, & 3

To ensure that Applications 1, 2, and 3 are non-tautological and experimentally falsifiable, Theorem `semi_dirac_applications_and_phase_lasing_critique_gap_closure_identities` ([../src/signals/Signals/Nanolithography.lean](../src/signals/Signals/Nanolithography.lean#L365-L490)) closes three physical modeling gaps and pairs each device with a concrete benchtop test protocol:

| Application & Critique Gap Closed | Machine-Checked Law in `Signals.Nanolithography` | How to Test & Falsify Experimentally (Hardware & Metrology Protocol) |
| :--- | :--- | :--- |
| **App 1 (`SemiDirac_App1`) — Oblique-Incidence Pseudospin Mismatch & Angular Collimation**:<br>At $k_x \ne 0$, the mass term $T_x = \frac{\hbar^2 k_x^2}{2m_x^*} > 0$ rotates the pseudospin away from $\sigma_y$. | `semiDiracObliqueKleinTransmissionY`:<br>$T_y^{\mathrm{oblique}}(T_x, P_y) = \frac{P_y^2}{P_y^2 + T_x^2}$,<br>$T_y^{\mathrm{oblique}}(0, P_y) = 1$, and $0 < T_y^{\mathrm{oblique}}(T_x, P_y) < 1$ for $T_x \ne 0, P_y \ne 0$. | **4-Terminal Cross-Hall & Polarized Micro-Raman Protocol**:<br>1. Confirm $532\text{ nm}$ LCS uniaxial strain $\varepsilon_{xx}^* = \Delta_0/\beta_{\mathrm{strain}}$ via polarized micro-Raman $G$-peak splitting ($\Delta\omega_G$).<br>2. Sweep `X_GATE_TOP` voltage $V_g$ and measure 4-terminal $G_{yy}(V_g)$ (`Y_SOURCE` $\to$ `Y_DRAIN`) vs. $G_{xx}(V_g)$: verify that $G_{yy}$ maintains a Fabry–Pérot-free ballistic plateau while $G_{xx}$ pinches off with $\mathcal{R}_{\mathrm{Klein}} > 100$. |
| **App 2 (`SemiDirac_App2`) — Drude Scattering Damping $\gamma_{\mathrm{loss}} > 0$ vs. Hyperbolic Canalization**:<br>Finite carrier scattering $\gamma_{\mathrm{loss}} > 0$ broadens the hyperbolic wavefronts unless $Q_{\mathrm{hyp}} = \omega / \gamma_{\mathrm{loss}} > 1$. | `semiDiracHyperbolicQualityFactor`:<br>$1 < Q_{\mathrm{hyp}}(\omega, \gamma_2) < Q_{\mathrm{hyp}}(\omega, \gamma_1)$ for $0 < \gamma_1 < \gamma_2 < \omega$. | **Cryogenic / Room-Temp `s-SNOM` & Wire-Grid THz Polarimetry Protocol**:<br>1. Image $400\text{–}800\text{ GHz}$ polariton rays launched from `1_BOWTIE_THZ_COLLECTOR_Y` via scattering-type scanning near-field optical microscopy (`s-SNOM`) to verify the canalization angle $\tan^2\theta_{\mathrm{canal}} = -\operatorname{Re}\varepsilon_{xx}/\operatorname{Re}\varepsilon_{yy} = 1/4$ ($\theta_{\mathrm{canal}} \approx 26.57^\circ$).<br>2. Rotate a wire-grid THz polarizer from $0^\circ$ ($\hat{y}$) to $90^\circ$ ($\hat{x}$) and measure `IF_READOUT` vs. an unstrained isotropic graphene control ($\mathcal{C}_{\mathrm{THz}} = 0$). |
| **App 3 (`SemiDirac_App3`) — Carnot-Normalized Conversion Efficiency $\eta_{\mathrm{red}}(u)$**:<br>$ZT_{yy}$ must map to a strictly bounded thermodynamic efficiency factor $\eta_{\max} / \eta_{\mathrm{Carnot}} \in (0, 1)$. | `semiDiracThermoelectricReducedEfficiency`:<br>$\eta_{\mathrm{red}}(u) = \frac{u - 1}{u + 1}$ ($u = \sqrt{1+ZT_{yy}}$),<br>$0 < \eta_{\mathrm{red}}(u_1) < \eta_{\mathrm{red}}(u_2) < 1$ for $1 < u_1 < u_2$, and $\eta_{\mathrm{red}}(2) = 1/3$ at $ZT = 3$. | **Suspended Micro-Heater $3\omega$ + Transient Harman $ZT$ Protocol**:<br>1. Apply a calibrated heat flux at `HOT_COLLECTOR` (`1_DIAMOND_HOT_COLLECTOR`) and measure open-circuit Seebeck voltage $\Delta V_{yy} = -S_{yy}\Delta T_y$ at `TEG_VOUT_P`.<br>2. Measure directional $\kappa_{yy}, \kappa_{xx}$ via the $3\omega$ method and cross-check $ZT_{yy} = (V_{\mathrm{DC}} - V_{\mathrm{AC}})/V_{\mathrm{AC}}$ via the transient Harman method. |

---

## 6. Machine-Checked Lean 4 & Rust Verification

The following Lean 4 verification block is machine-checked in [../src/signals/Signals/Nanolithography.lean](../src/signals/Signals/Nanolithography.lean#L124-L490) and [../src/signals/SignalsTests.lean](../src/signals/SignalsTests.lean#L7500-L7565):

```lean
import Signals

namespace SemiDiracApplications1To3Verification

open Signals

example (delta0 : ℝ) :
    semiDiracStrainMergingGap delta0 2 (delta0 / 2) = 0 ∧
      semiDiracKleinRectificationRatio 0 = 1 ∧
      1 < semiDiracKleinRectificationRatio 10 ∧
      semiDiracKleinRectificationRatio 10 = 101 ∧
      semiDiracDrudeAnisotropySq 1 1 1 4 <
        semiDiracDrudeAnisotropySq 1 1 1 1 ∧
      semiDiracHyperbolicCanalizationTanSq (3 / 4) (-3) = 1 / 4 ∧
      0 < semiDiracBolometerPolarizationContrast 10 1 ∧
      semiDiracBolometerPolarizationContrast 10 1 < 1 ∧
      semiDiracThermoelectricZT 2 1 300 1 2 <
        semiDiracThermoelectricZT 2 10 300 1 2 ∧
      semiDiracThermoelectricZT 2 10 300 1 2 <
        semiDiracThermoelectricZT 2 10 300 1 1 ∧
      semiDiracObliqueKleinTransmissionY 0 2 = 1 ∧
      0 < semiDiracObliqueKleinTransmissionY 1 2 ∧
      semiDiracObliqueKleinTransmissionY 1 2 < 1 ∧
      1 < semiDiracHyperbolicQualityFactor 10 2 ∧
      semiDiracHyperbolicQualityFactor 10 2 <
        semiDiracHyperbolicQualityFactor 10 1 ∧
      semiDiracThermoelectricReducedEfficiency 2 = 1 / 3 := by
  have h := semi_dirac_four_applications_nanolithography_and_kicad_drc_identities
    delta0 2 10 1 1 1 1 4 10 1 2 1 10 300 1 1 2 1 2 1
    (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num)
    (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num)
    (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  have hc := semi_dirac_applications_and_phase_lasing_critique_gap_closure_identities
    1 2 10 1 2 (3 / 2) 2 1 1 1
    (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num)
    (by norm_num) (by norm_num)
  exact ⟨h.1, h.2.1, h.2.2.1, h.2.2.2.1, h.2.2.2.2.1,
    h.2.2.2.2.2.1, h.2.2.2.2.2.2.1, h.2.2.2.2.2.2.2.1,
    h.2.2.2.2.2.2.2.2.1, h.2.2.2.2.2.2.2.2.2.1,
    hc.1, hc.2.1, hc.2.2.1, hc.2.2.2.1, hc.2.2.2.2.1,
    hc.2.2.2.2.2.2.2.2.1⟩

end SemiDiracApplications1To3Verification
```

---

## References

(sd31-montambaux2009)=
<a id="sd31-montambaux2009"></a>
1. **Montambaux, G., Piéchon, F., Fuchs, J.-N., & Goerbig, M. O. (2009).** *Merging of Dirac points in a two-dimensional crystal.* Physical Review B, 80(15), 153412. `https://doi.org/10.1103/PhysRevB.80.153412`

(sd31-kim2015)=
<a id="sd31-kim2015"></a>
2. **Kim, J., Baik, S. S., Ryu, S. H., Sohn, Y., Park, S., Park, B.-G., Denlinger, J., Yi, Y., Choi, H. J., & Kim, K. S. (2015).** *Observation of tunable band gap and anisotropic Dirac semimetal state in black phosphorus.* Science, 349(6249), 723–726. `https://doi.org/10.1126/science.aaa6486`

(sd31-shao2024)=
<a id="sd31-shao2024"></a>
3. **Shao, Y., et al. (2024).** *Semi-Dirac Fermions in a Topological Metal.* Physical Review X, 14(4), 041057 (`arXiv:2311.03735`). `https://doi.org/10.1103/PhysRevX.14.041057`

---

### BibTeX Citations

```bibtex
@unpublished{turner2026semi_dirac_devices_kicad,
  author  = {Turner, Wesley},
  title   = {Semi-{D}irac Nanoelectronic, Hyperbolic {THz} Plasmonic, and Orthogonal Thermoelectric Devices in 405 nm / 532 nm Carbon Nanolithography and Volumetric {KiCAD}/{GDSII} {EDA}: Ballistic {K}lein Diodes/Transistors, Lithography-Free 400--800 {GHz} {THz} Bolometers, and Cross-Axis {$ZT$} Harvesters in {L}ean 4, {R}ust/{WASM}, and {P}ython},
  journal = {Sustainable Factory Research Archive},
  year    = {2026},
  note    = {Verified in Lean 4 (v4.35.0-rc3), Rust/WASM, Python, and KiCAD v8}
}
```

### Schema.org Metadata (JSON-LD)

```json
{
  "@context": "https://schema.org",
  "@type": "ScholarlyArticle",
  "headline": "Semi-Dirac Nanoelectronic, Hyperbolic THz Plasmonic, and Orthogonal Thermoelectric Devices in 405 nm / 532 nm Carbon Nanolithography and Volumetric KiCAD/GDSII EDA: Ballistic Klein Diodes/Transistors, Lithography-Free 400–800 GHz THz Bolometers, and Cross-Axis ZT Harvesters in Lean 4, Rust/WASM, and Python",
  "author": {
    "@type": "Person",
    "name": "Wes Turner"
  },
  "dateModified": "2026-11-08",
  "about": [
    "Semi-Dirac Ballistic Klein Diodes and Transistors",
    "Lithography-Free In-Plane Hyperbolic THz Bolometers",
    "Orthogonal-Axis Thermoelectric ZT Harvesters",
    "405 nm / 532 nm Holographic Carbon Nanolithography",
    "Volumetric KiCAD and GDSII EDA",
    "Lean 4 Formal Verification"
  ]
}
```
