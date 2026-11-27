---
title: "Unified Pending Boundary Closure Plan: Cross-Domain Certificate Architecture Across All Seven PendingBoundary Gates, Infinite-Dimensional Finite-Rank FredholmDet, and Strip Sub-Gaussian L¹(ℝ) Weil Convergence"
description: "Master cross-plan synthesis unifying the seven epistemic PendingBoundary gates in Signals.Pending (RiemannHypothesis, ToupinCelestialMillennium, SatoRiemannSpectral, DualSchubertNavierStokes, PhotoelectricEmission, AntimatterAnnihilationAlphaG, and YangMillsMassGapHiggsCPT) alongside axiom-free infinite-dimensional finite-rank Fredholm determinants and strip sub-Gaussian L¹(ℝ) Weil summability in Lean 4, Rust/PyO3, SymPy/mpmath, and MyST Markdown."
---

(unified-pending-closure-roadmap-plan)=
# Unified Pending Boundary Closure Plan: Cross-Domain Certificate Architecture Across All Seven `PendingBoundary` Gates

- **Author:** Wes Turner
- **Owning Synthesis Plans Integrated:**
  - [Sato–Riemann Spectral Pending Closure Plan (`SRS-1`–`SRS-7`)](sato-riemann-spectral-pending-closure-plan.md)
  - [RH Analytical Bridges Plan (`RB-1`–`RB-6`)](riemann-spectral-bridges-plan.md)
  - [Yang–Mills / Higgs / CPT Pending Closure Plan (`YM-1`–`YM-5`)](yang-mills-higgs-cpt-pending-closure-plan.md)
  - [Dual-Schubert QFIM Navier–Stokes Plan (`NS-1`–`NS-6`)](dual-schubert-qfim-navier-stokes-plan.md)
  - [Antimatter Annihilation & CERN `ALPHA-g` Plan (`AG-1`–`AG-5`)](antimatter-annihilation-alpha-g-plan.md)
  - [Maxwell EM, Twistors, Longitudinal $E_z$, & Photoelectric Unification Plan](maxwell-electromagnetism-twistors-unification-plan.md)
  - [Dispersive Homodyne & Residual Unification Plan](dispersive-homodyne-plan.md)

---

## 1. Cross-Plan Overlap Audit in `Signals.Pending`

Auditing all seven top-level `*PendingBoundary` structures in {download}`src/signals/Signals/Pending.lean <../src/signals/Signals/Pending.lean>` alongside our paper corpus reveals four direct structural overlaps and three missing certificate-closure implementations:

| `PendingBoundary` Structure in `Pending.lean` | Embedded / Overlapping Sub-Boundaries & Shared Theorems | Prior Closure Status | Unified Upgrade Implemented Here (`UP-1`–`UP-5`) |
| --- | --- | --- | --- |
| **1. `RiemannHypothesisPendingBoundary`** | Embedded in both `SatoRiemannSpectralPendingBoundary` and `ToupinCelestialMillenniumPendingBoundary` (`RB-6` bridges 1–4). | Had `ofCertificates` / `solved_of_certificates`; `AdelicSatoTraceLimitCertificate` & `GlobalWeilLiJensenCertificate` needed tighter bridge to strip-bounded infinite Weil & finite-rank `finiteRankDet`. | Keep shared 4-certificate bundle `(c1..c4)` and connect `GlobalInfiniteZeroWeilCertificate` via automatic strip sub-Gaussian `gaussianCombo` summability (`UP-2`). |
| **2. `SatoRiemannSpectralPendingBoundary`** | Embeds `rhBoundary` (`RB-6`); shares `DualSchubertQFIM.sharoglazova_klaers_evanescent_speed_law` with `PhotoelectricEmissionPendingBoundary` and `DualSchubertNavierStokesPendingBoundary`; `FredholmDetTheory` lacked an axiom-free finite-rank determinant on infinite-dim `HPlus`. | Had `ofCertificates` / `solved_of_certificates` and `instFredholmDetTheoryOfFiniteDimensional`, but **infinite-dimensional finite-rank** `I + F` (`segalWilson_tau_gr24_eq_tauU`) still required `[FredholmDetTheory]`. | **Prove `finiteRankDet` unconditionally on arbitrary infinite-dimensional `HPlus`** via the finite-dimensional invariant subspace `V = range F ⊔ (ker F)ᗮ`, closing `segalWilson_tau_gr24_eq_tauU_axiomFree` with **zero axioms** (`UP-1`)! |
| **3. `ToupinCelestialMillenniumPendingBoundary`** | Embeds `rhBoundary`, shares `ContinuumYangMillsOSCertificate` & `CelestialConfiningSpectralCertificate` with `YangMillsMassGapHiggsCPTPendingBoundary`, and shares `M_1 = 1/8, M_2 = 1/90` with `AntimatterAnnihilationAlphaGPendingBoundary`. | Had `ofCertificates` / `solved_of_certificates`, but `PlancherelLoopMeasurementCertificate` was not yet shared with `AntimatterAnnihilationAlphaGPendingBoundary`. | Unify `PlancherelLoopMeasurementCertificate` across `ToupinCelestialMillenniumPendingBoundary` and `AntimatterAnnihilationAlphaGPendingBoundary` (`UP-3`, `UP-4`). |
| **4. `YangMillsMassGapHiggsCPTPendingBoundary`** | Shares `ContinuumYangMillsOSCertificate` & `CelestialConfiningSpectralCertificate` with `Toupin`, and Model `16a`/`16b` $\eta_{\mathrm{act}}^\gamma$ (`ElectroweakBaryogenesisModel16Certificate`) with `AntimatterAnnihilationAlphaGPendingBoundary.activePhotonSourcingResolved`. | Already had `ofCertificates` / `solved_of_certificates`. | Share `ActivePhotonSourcingCertificate` cleanly across Model `16a`/`16b` and `AntimatterAnnihilationAlphaGPendingBoundary` (`UP-3`, `UP-4`). |
| **5. `DualSchubertNavierStokesPendingBoundary`** | Uses `ClassicalControlVolume`, `FlowBoundaryCondition`, `FlowBoundaryObservation`, `ControlledMeasurement`, and `Signals.NavierStokes.*` (`taylorGreen2D`, `korteweg_stress_div_eq_quantum_force`, `breschDesjardins_dual_schubert_qfim_split`, `coleHopf_burgers_solves_viscous_burgers`). | **Missing** certificate structures, `ofCertificates`, and `solved_of_certificates`. | Add `NavierStokes3DRegularityCertificate`, `NavierStokes3DHirotaLinearizabilityCertificate`, `TurbulenceSubgridClosureCertificate`, `ExperimentalFluidTelemetryCertificate`, and `.solved_of_certificates` (`UP-3`). |
| **6. `PhotoelectricEmissionPendingBoundary`** | Overlaps with `QCI-GXC` (`mcweenyPurificationPoly`), `Signals.DDF.enzBoundaryIntensityEnhancement`, `LongitudinalBeamApplicationEvidence`, `DualSchubertQFIM.sharoglazova_klaers_evanescent_speed_law`, `Signals.SatoGrassmannian.AKNS`, and `ControlledMeasurement`. | **Missing** certificate structures, `ofCertificates`, and `solved_of_certificates`. | Add `WorkFunctionCalibrationCertificate`, `KeldyshYieldCertificate`, `EnzOamLossCertificate`, `AttosecondTimingCertificate`, and `.solved_of_certificates` (`UP-3`). |
| **7. `AntimatterAnnihilationAlphaGPendingBoundary`** | Overlaps with `Signals.AntimatterGravity`, `Signals.DDF.ActiveRadiationSourcing` ($\eta_{\mathrm{act}}^\gamma \in \{0, 1\}$), Model `16a`/`16b` (`YangMills`), and `bareLoopM1 = 1/8, bareLoopM2 = 1/90` (`Toupin`). | **Missing** certificate structures, `ofCertificates`, and `solved_of_certificates`. | Add `AlphaGWepPrecisionCertificate`, `PositroniumFreeFallCertificate`, `ActivePhotonSourcingCertificate`, `PlancherelLoopMeasurementCertificate`, and `.solved_of_certificates` (`UP-3`). |

---

## 2. Workstreams (`UP-1` Through `UP-5`)

### `UP-1`: Axiom-Free Finite-Rank Determinant on Arbitrary Infinite-Dimensional Hilbert Spaces (`DeterminantBundle.lean` & `SegalWilsonGr24.lean`)
- **Mathematical Insight:** For **any** bounded operator $F : H_+ \to H_+$ with finite-dimensional range on an arbitrary (possibly infinite-dimensional) complex Hilbert space $H_+$, $\ker F$ is closed, so $(\ker F)^\perp \simeq H_+/\ker F \simeq \operatorname{range} F$ is finite-dimensional, making

  $$
  V(F) := \operatorname{range} F \sqcup (\ker F)^\perp \subset H_+
  $$

  a finite-dimensional subspace satisfying $F(V) \subseteq \operatorname{range} F \subseteq V$ and $F|_{V^\perp} \equiv 0$. Therefore $(I + F)|_{V(F)}$ is a genuine finite-dimensional endomorphism and $(I + F)|_{V(F)^\perp} = I_{V(F)^\perp}$, defining an **axiom-free, basis-independent Fredholm determinant** `finiteRankDet (I + F) := LinearMap.det ((I + F)|_{V(F)})`.
- **Lean 4 Deliverables (Zero `sorry`, Zero Axioms):**
  1. `FiniteRankInvSubspace`, `canonicalInvSubspace`, `det_restrict_eq`, & `finiteRankDet : FiniteRankMonoid E →* ℂ`: well-defined for any `F` with `FiniteDimensional ℂ (LinearMap.range F.toLinearMap)` (independent of enlarging $V$ to any finite-dimensional $W \supseteq V$ on which $F$ vanishes on $W^\perp$ and maps $W \to W$).
  2. `finiteRankDet.map_one`, `finiteRankDet.map_mul`, `finiteRankDet_conj`, `finiteRankDet_rankOneScale`, `finiteRankDet_rankOneScaleProd`, `finiteRankDet_ne_zero_iff`, and `finiteRankDet_eq_detFr_of_finiteDimensional`: proves all `FredholmDetTheory` properties unconditionally for finite-rank perturbations on infinite-dimensional $H_+$ and proves exact agreement with `instFredholmDetTheoryOfFiniteDimensional` on finite-dimensional spaces.
  3. **`segalWilson_tau_gr24_eq_tauU_axiomFree`** in `SegalWilsonGr24.lean`: proves $\det_{\mathrm{fin}}(I_{H_+} + g(t)_{+-} T_U g(t)_{++}^{-1}) = \tau_U(t_1, t_2, t_3) / p_{23}$ directly on infinite-dimensional $L^2(S^1)$ **without `[FredholmDetTheory]`**!

### `UP-2`: Automatic Strip Sub-Gaussian `WeilGaussianL1` Summability (`WeilGaussianL1.lean` & `RiemannSpectralBridge.lean`)
- **Lean 4 Deliverables (Zero `sorry`):**
  1. `norm_mellinTransform_gaussianCombo_strip`: uniform bound $\lVert \mathcal{M}_{f_{\delta, P}}(z)\rVert \le C_{\delta, P}(B)\,e^{-\operatorname{Re}(z)^2/2}$ on $\lvert \operatorname{Im}(z)\rvert \le B$.
  2. `summable_weilInfinite_gaussianCombo_of_strip` & `summable_weilInfinite_normSq_gaussianCombo_of_strip`: for any strip-bounded zero sequence `∀ n, |(z n).im| ≤ B` satisfying `Summable (fun n => (m n : ℝ) * Real.exp (-(z n).re ^ 2))`, **every** `f = gaussianCombo δ P` is automatically Weil-summable.
  3. `weilInfiniteSum_gaussianCombo_nonneg_of_allRealZeros`, `weilInfiniteSum_gaussianCombo_neg_of_offline_pair_tail_lt`, `weil_infinite_gaussianCombo_strip_vs_evanescent_qfim_bridge`, and `StripGaussianWeilCertificate` / `GlobalInfiniteZeroWeilCertificate.ofStripGaussian`: removes per-function `hSumm` from `GlobalInfiniteZeroWeilCertificate`.

### `UP-3` & `UP-4`: Complete Certificate Solvers for `NavierStokes`, `Photoelectric`, `Antimatter`, & Master Cross-Boundary Unification (`Pending.lean`, `SignalsPending.lean`, Tests)
- **Lean 4 Deliverables (Zero `sorry`):**
  1. `DualSchubertNavierStokesPendingBoundary.ofCertificates` & `.solved_of_certificates`
  2. `PhotoelectricEmissionPendingBoundary.ofCertificates` & `.solved_of_certificates`
  3. `AntimatterAnnihilationAlphaGPendingBoundary.ofCertificates` & `.solved_of_certificates`
  4. **`MasterUnifiedPendingClosure`** (`MasterUnifiedPendingClosure.all_seven_pending_boundaries_solved`): consumes a single unified bundle of shared + domain certificates and constructively closes **all seven** `*PendingBoundary` structures simultaneously (`RiemannHypothesis`, `ToupinCelestialMillennium`, `SatoRiemannSpectral`, `DualSchubertNavierStokes`, `PhotoelectricEmission`, `AntimatterAnnihilationAlphaG`, and `YangMillsMassGapHiggsCPT`).
  5. Update `@[blueprint]` lemmas in `SignalsPending.lean` and regression examples in `SignalsTests.lean` and `SignalsPendingTests.lean`.

### `UP-5`: Rust/PyO3, SymPy/`mpmath`, Plan/Paper Integration, & Commit
- Add `evaluate_finite_rank_invariant_det` (`py_audit_finite_rank_invariant_det`, explicit $V = \operatorname{range} F \sqcup (\ker F)^\perp$ check on truncated $L^2(S^1)$), `evaluate_strip_gaussian_combo_decay` (`py_audit_strip_gaussian_combo_decay`), and `audit_unified_pending_closures_mpmath_vs_rust` in `sato_grassmannian.rs` / `lib.rs` / `sustainablefactory/sato_grassmannian.py` / `tests/test_sato_grassmannian_sympy_pyo3.py`.
- Verify `make signals_build`, `cargo test`, `maturin develop --release`, `pytest`, Markdown scanners, `make -C docs html`, Playwright browser MathJax check, and `git diff --check`.
