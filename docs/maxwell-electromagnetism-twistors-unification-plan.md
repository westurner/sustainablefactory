---
title: "Written Plan: Maxwell Electromagnetic Theory Across Pre-Tensor Quaternions, Modern Vectors (Gimbal Lock), Relativistic Tensors, and Penrose Twistors, Unified Across Gravity/Electron Models, DFT/VRC, SQG/DDF, SU(4) Lower Grassmannians, ER=EPR M1–M3, Soft Photons, and QFIM = 4 g^FS"
description: "Structured theoretical, formal-verification (Lean 4), numerical-reproduction (Rust/WASM), and MyST documentation plan for unifying Maxwell electromagnetic theory across pre-tensor quaternion, modern 3-vector (gimbal-lock), relativistic tensor, and Penrose twistor/Grassmannian formulations with longitudinal E_z waves, OAM tubular solitons, multi-model gravity/electron EM synthesis, DFT/VRC vs. SQG/DDF media, polaritons/plasmons on SU(4) lower Grassmannians, ER=EPR multi-path methods M1–M3, soft and TRUE-conjugated soft photons, and QFIM = 4 g^FS."
---

(maxwell-electromagnetism-twistors-unification-plan)=
# Written Plan: Maxwell Electromagnetic Theory, Twistors, Longitudinal $E_z$ & OAM Tubular Solitons, and Multi-Model Gravity/Electron Unification in Lean 4 and Rust

- **Companion Paper**: [grassmannian-maxwell-electromagnetism-twistors-ez-oam-solitons-gravity-models-paper.md](grassmannian-maxwell-electromagnetism-twistors-ez-oam-solitons-gravity-models-paper.md)
- **Related Unification & Metrology Papers**:
  - [grassmannian-unification-applications-roadmap-paper.md](grassmannian-unification-applications-roadmap-paper.md)
  - [grassmannian-qfim-fubini-study-kahler-madelung-unification-paper.md](grassmannian-qfim-fubini-study-kahler-madelung-unification-paper.md)
  - [grassmannian-er-epr-witten-su4-plucker-tachyons-semi-dirac-paper.md](grassmannian-er-epr-witten-su4-plucker-tachyons-semi-dirac-paper.md)
  - [grassmannian-ddf-fracture-communication-vs-er-epr-wormholes-paper.md](grassmannian-ddf-fracture-communication-vs-er-epr-wormholes-paper.md)
  - [grassmannian-kohn-sham-dft-complex-plabic-vrc-paper.md](grassmannian-kohn-sham-dft-complex-plabic-vrc-paper.md)
  - [grassmannian-polariton-spp-mechanics-paper.md](grassmannian-polariton-spp-mechanics-paper.md)
- **Verification & Simulation Artifacts**:
  - Lean 4: {download}`src/signals/Signals/DFT.lean, lines 7935–10189 <../src/signals/Signals/DFT.lean>`, {download}`src/signals/Signals/Pending.lean, lines 8652–9154 <../src/signals/Signals/Pending.lean>`, {download}`src/signals/SignalsPending.lean, lines 2036–2436 <../src/signals/SignalsPending.lean>`, {download}`src/signals/SignalsTests.lean, lines 8425–8769 <../src/signals/SignalsTests.lean>`, {download}`src/signals/SignalsPendingTests.lean, lines 6985–7337 <../src/signals/SignalsPendingTests.lean>`
  - Rust/WASM: {download}`src/signals/numerical_adapter/src/dft_plabic_vrc.rs, lines 2159–2938 and 3970–4357 <../src/signals/numerical_adapter/src/dft_plabic_vrc.rs>`

---

## 1. Objectives & Architectural Scope

This plan structures the formal verification (Lean 4), numerical simulation (Rust/WASM), and arXiv-ready MyST documentation for unifying **Maxwell's electromagnetic theory** across its four historical/geometric representations and across all gravity, electron, dense-matter, quasiparticle, wormhole/fracture, soft-photon, and quantum-information-geometric models in the `Signals` architecture:

1. **Layer 1 — Historical & Geometric Formulations of Maxwell EM (Paper Sec. 1; `Signals.DFT` Sec. 26)**:
   - Review Maxwell's original pre-tensor component & quaternion formulation (`maxwellOriginal1865EquationCount = 20`, $\nabla\mathbf{F} = -\nabla\cdot\mathbf{F} + \nabla\times\mathbf{F}$, `maxwellQuaternionNablaNormSq`).
   - Analyze the modern Heaviside–Gibbs 3-vector formulation (`heavisideGibbsVectorEquationCount = 4`) and prove its structural limitations: Euler coordinate/polarization **gimbal lock** at $\theta_{\mathrm{pitch}} = \pm\pi/2$ (`eulerKinematicJacobianDet (Real.pi / 2) = 0`, contrasted with non-singular spinor/quaternion norm `unitQuaternionNormSq = 1`), Aharonov–Bohm potential erasure, and $100\%$ paraxial 2D Jones error on focal $E_z$.
   - Review Maxwell's stress tensor and Minkowski's relativistic 2-form (`minkowskiTensorEquationCount = 2`, `maxwellLorentzInvariantLagrange`, `maxwellLorentzInvariantPontryagin`, and 4D conformal tracelessness `maxwellStressEnergyTraceInDim 4 f_contract = 0`).
   - Formulate Penrose's massless spinor/twistor theory (`penroseTwistorSpinorEquationCount = 1`, `maxwellSpinorNullDeterminant`) on $\mathbb{CP}^3 = \mathrm{Gr}_{\mathbb{C}}(1,4)$ and its Plücker lift to $\mathrm{Gr}_{\mathbb{C}}(2,4) \cong \mathcal{Q}_4 \subset \mathbb{CP}^5$ and $\mathrm{Gr}_{\mathbb{C}}(3,6)$.
2. **Layer 2 — Longitudinal Waves ($E_z$), `OAM`, and Hollow-Core Tubular Solitons (Paper Sec. 2; `Signals.DFT` Secs. 26 & 26.1)**:
   - Prove 3D Fourier Gauss orthogonality $E_z = -(k_x E_x + k_y E_y)/k_z$ (`maxwellGaussLongitudinalEz`), Debye–Wolf counter-polarization $E_z = 2 E_0 \sin\theta$, high-NA `SAM` $\to$ `OAM` conversion $\ell_z = \ell_{\mathrm{in}} + \sigma_{\mathrm{SAM}}$ (`samToOamLongitudinalTopologicalCharge`), ENZ $100\times\text{–}400\times$ boundary amplification, and gapped Proca/Kähler longitudinal polarization $e_L^z = \omega / m_{\mathrm{eff}}$ (`procaLongitudinalPolarizationZ`).
   - Prove why twistors (Robinson congruences and two-twistor $\mathrm{Gr}_{\mathbb{C}}(2,4)$ / $\mathrm{Gr}_{\mathbb{C}}(3,6)$ Plücker states) outperform 3-vector and scalar Madelung models for **tubular OAM solitons**: hollow ring radius squared $r_{\mathrm{ring}}^2 = w_0^2|\ell|/2$ (`tubularSolitonRingRadiusSq`), radial self-trapping (`tubularSolitonRadialEquilibriumResidual`), nonlocal suppression of azimuthal breakup (`nonlocalStabilizedAzimuthalMiGain < 0`), Abraham–Minkowski product invariance $p_{\mathrm{Abr}}p_{\mathrm{Mink}} = p_0^2$, Gouy mode order $2p + |\ell| + 1$, and dark-core regularization (`pluckerRegularizedVortexCoreNormSq ≥ 1` vs. $1/r^2$ `scalarBohmVortexCoreDivergence`).
3. **Layer 3 — Multi-Model EM Wave Dictionary Across All Gravity & Electron Models (Paper Sec. 3; `Signals.DFT` Secs. 26, 27.3, 27.4, & 28)**:
   - Provide a master navigation table linking directly to dedicated subsections (`Sec. 3.1`–`Sec. 3.8`) with explicit Lean 4 and Rust links for:
     - **Sec. 3.1**: Classical Baselines — Einstein GR ($\gamma_{\mathrm{PPN}}=1$), Newtonian / Un-Doubled Spin-1 Vector ($\gamma_{\mathrm{PPN}}=0$, $\varepsilon_{\mathrm{rel}}=50\%$), & Nordström Spin-0 Scalar ($\gamma_{\mathrm{PPN}}=-1$, $\varepsilon_{\mathrm{rel}}=100\%$ via $T^\mu{}_\mu = 0$).
     - **Sec. 3.2**: QED & Gauge Scattering (`BCJ` Double Copy, 1-Loop Euler–Heisenberg Vacuum Birefringence `qedEulerHeisenbergRefractiveShift`, & Partanen–Tulkki $\mathrm{U}(1)^4$ QFT).
     - **Sec. 3.3**: Witten (2004) Twistor String ($1/q^4$ Conformal Weyl Ghost) vs. Cachazo Program (`CSW` / `BCFW` / `Cachazo–Skinner` Infinity Twistor $\pi_I=1$ / `CHY` $(n-3)!$ Worldsheet Roots).
     - **Sec. 3.4**: Superfluid Quantum Gravity & Dilatant Dark Fluid (`SQG/DDF`: $c = (\varrho_{\max}^\varphi j_{\min}^\varphi)^{-1/2}$, `ddfRefractiveLightDeflection`, and Active Laser-Deflection Null $\eta_{\mathrm{act}}^\gamma = 0$ in `activePhotonBeamDeflection`).
     - **Sec. 3.5**: Turner Model 6 — Homogeneous Plücker $\mathcal{Q}_4$ Madelung & Dual-Grassmannian `iGPE` Wave/OAM Superposition (`pluckerMadelungSuperpositionOAMDoubleSlit`).
     - **Sec. 3.6**: Turner Model 12 — Flat-Space $\mathrm{Gr}_{\mathbb{C}}(2,4)$ `BCJ` Double Copy + 2D/3D Tensor Splats Without DDF (`turnerGr24QEDLightDeflection`).
     - **Sec. 3.7**: Turner Model 13 — Unified $\mathrm{Gr}_{\mathbb{C}}(2,4)$ + Conservative DDF + 3D `NormedTensorGaussianSplat3D` (`turnerGr24DDFLightDeflection`).
     - **Sec. 3.8**: Turner Models 14a (Without DDF) & 14b (With DDF) — Klein Quadric $\mathcal{Q}_4$ Fubini–Study Kähler `iGPE` (`turnerPluckerKahlerLightDeflection`, `turnerDualGr24IGPEDDFLightDeflection`, and Heaviside–Larmor duality norm `electricMagneticDualityNormSq`).
4. **Layer 4 — Vacuum Maxwell vs. Dense Media (`DFT` Electron Density & Complex `VRC`) vs. `SQG/DDF` Pressure Differences (Paper Sec. 4; `Signals.DFT` Sec. 26.2)**:
   - Contrast Maxwell's idealized empty vacuum ($\rho_e = 0, \Delta P = 0$) with:
     - **Atmosphere, Plasma, & Condensed Matter (`QCI-GXC` Kohn–Sham `DFT`, `G-GKBA`, & Complex Plabic `VRC`s)**: Wave propagation governed by **electron density $\rho_e(\mathbf{r})$** (`dftElectronDensityPermittivity`) on $\mathrm{Gr}_{\mathbb{C}}(N_\alpha, M)\times\mathrm{Gr}_{\mathbb{C}}(N_\beta, M)$ and pole-free homogeneous Vector-Relation Configurations $(V, K)$ ($V K^\top = 0$) across $x_X = -1$.
     - **`SQG/DDF` Substrate**: No complete vacuum exists ($\rho_0 > 0$ everywhere)—only **differences in superfluid pressure** $\Delta P = P_{\mathrm{ambient}} - P_{\mathrm{local}}$ (`ddfPressureDifferenceEnthalpy`, `ddfPressureGradientRefractiveIndex`).
5. **Layer 5 — Polaritons, Plasmons, Photons, & Electrons on $\mathrm{SU}(4)$ Lower Grassmannians (Paper Sec. 5; `Signals.DFT` Secs. 12, 20, & 26.2)**:
   - Classify spin, statistics, dispersion, application domains, and exact $\mathrm{SU}(4)$ ($\dim_{\mathbb{R}} = 15$) lower Grassmannians $\mathrm{Gr}_{\mathbb{C}}(1,2)$, $\mathrm{Gr}_{\mathbb{C}}(1,3)$, $\mathrm{Gr}_{\mathbb{C}}(1,4)$, $\mathrm{Gr}_{\mathbb{C}}(2,4)$, $\mathrm{Gr}_{\mathbb{C}}(2,5)$, $\mathrm{Gr}_{\mathbb{C}}(2,6)$, $\mathrm{Gr}_{\mathbb{C}}(3,6)$, and $\mathrm{Gr}_{\mathbb{C}}(2,10)$.
6. **Layer 6 — Multi-Path $\mathrm{ER}=\mathrm{EPR}$ Methods $M_1$, $M_2$, and $M_3$ (Paper Sec. 6; `Signals.DFT` Secs. 25.2 & 26.2)**:
   - Synthesize $M_1$ (photons around the wormhole), $M_2$ (modes through a contiguous $\mathrm{De} > 1$ DDF fracture waveguide around the wormhole, $>9{,}800\times$ gain), and $M_3$ (Semi-Dirac fermions and `TRUE` soft photons through the wormhole throat), plus their composite transceivers (`triModalAgcDualKeyedErEprRxProbability`).
7. **Layer 7 — Soft Photons & `TRUE`-Conjugated Soft Photons Across Every EM Model (Paper Sec. 7; `Signals.DFT` Secs. 23.3, 26.2, & 28)**:
   - Formalize Weinberg's $O(\omega^{-1})$ eikonal factor (`weinbergSoftPhotonFactor`), two-leg Ward gauge invariance (`softPhotonTwoLegWardResidual = 0`), Low–Cachazo–Strominger $O(\omega^0)$ angular-momentum subleading soft theorem (`lowCachazoStromingerSoftPhotonAmplitude`), Celestial `(h, \bar{h}) = (1, 0)` currents, and $M_3^\gamma$ `TRUE`-conjugated soft-photon $>90\%$ sub-wavelength wormhole coupling without Raychaudhuri throat collapse across every EM model.
8. **Layer 8 — Quantum Fisher Information Metric (`QFIM`) $= 4\times$ Fubini–Study Kähler Metric (Paper Sec. 8; `Signals.DFT` Secs. 27 & 27.5)**:
   - Connect $F_{\mu\nu} = 4\,g_{\mu\nu}^{\mathrm{FS}}$ (`qfimDiag_eq_four_mul_fubiniStudyDiag`, `totalGpeKinetic3D_eq_madelung_qfim_trace`, `qfim_simplex_phase_variance_split`) directly to Poincaré-sphere gimbal-lock elimination (`poincareSphereQfimTheta = 1`), 3D vectorial $E_z$ Fisher gain (`vectorialEzThreeChannelFisher`), $4\ell^2$ OAM super-resolution (`oamSuperpositionQfimPhi`), multi-mode `TRUE` soft-photon QFIM scaling (`trueConjugatedSoftPhotonQfimGain`), and 1PN orbital-QFIM light deflection.

---

## 2. Implementation & Validation Checklist

- [x] **Step 1 (Lean 4 Formalization & Pending Contracts)**:
  - Sections 26, 26.1, 26.2, 27.5, and 28 implemented and proved without `sorry` in `Signals.DFT` (`src/signals/Signals/DFT.lean`), paired with `DDFFractureCommunicationEvidence` Pending boundary theorems in `Signals.Pending` / `SignalsPending` and regression examples in `SignalsTests` / `SignalsPendingTests` (`3,628` Lake jobs passing).
- [x] **Step 2 (Rust/WASM Implementation & Unit Tests)**:
  - All Section 26–28 evaluators and numerical check-figure assertions implemented in `src/signals/numerical_adapter/src/dft_plabic_vrc.rs` (`98` crate tests passing).
- [x] **Step 3 (Complete MyST Paper & Cross-Document Integration)**:
  - Complete Sections 3–9, Scholarly References, BibTeX, and Schema.org JSON-LD in [grassmannian-maxwell-electromagnetism-twistors-ez-oam-solitons-gravity-models-paper.md](grassmannian-maxwell-electromagnetism-twistors-ez-oam-solitons-gravity-models-paper.md).
  - Register both the plan and paper in [`docs/_toc.yml`](_toc.yml), [plan-index.md](plan-index.md), and [grassmannian-unification-applications-roadmap-paper.md](grassmannian-unification-applications-roadmap-paper.md).
- [x] **Step 4 (MyST Math/Table Hygiene, Sphinx HTML Build, & Browser Inspection)**:
  - Run `tools/fix_markdown_table_math_pipes.py` and `tools/fix_markdown_display_math_spacing.py` with reports in `.tmp/`.
  - Run `pytest -q tests/test_markdown_display_math_spacing.py tests/test_markdown_table_math_pipes.py`, `make -C docs html > .tmp/docs-html.log 2>&1`, `git diff --check`, and inspect the rendered HTML page in the integrated browser for MathJax rendering and zero `mjx-merror` / `myst.xref_missing` issues.
