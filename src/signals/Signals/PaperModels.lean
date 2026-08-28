import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic
import Mathlib.Data.Complex.Basic
import Mathlib.Data.Real.Basic
import Mathlib.Tactic

namespace Signals.Pending

/-! # Finite models extracted from the attached papers

These structures preserve selected equations and observable ratios from the
attached papers in finite Lean data. They are normalized or discretized models;
they do not assert that a Proca metamaterial, massive photon, quantum source,
or proposed experiment has been realized.
-/

/-- A normalized massive-mode dispersion relation and real-wave cutoff.

This records the form `omega^2 = k^2 + m^2` used by the Proca metamaterial
papers after normalization of the speed of light. -/
structure ProcaDispersion where
  mass : ℝ
  mass_nonnegative : 0 ≤ mass
  angularFrequency : ℝ
  angularFrequency_pos : 0 < angularFrequency
  waveNumber : ℝ
  waveNumber_nonnegative : 0 ≤ waveNumber
  aboveCutoff : mass ≤ angularFrequency
  dispersionLaw : angularFrequency ^ 2 = waveNumber ^ 2 + mass ^ 2

/-- The dispersion relation exposes the squared wave-number law. -/
lemma ProcaDispersion.dispersion_holds (mode : ProcaDispersion) :
    mode.angularFrequency ^ 2 = mode.waveNumber ^ 2 + mode.mass ^ 2 :=
  mode.dispersionLaw

/-- A real propagating mode has nonnegative frequency above its mass cutoff. -/
lemma ProcaDispersion.cutoff_holds (mode : ProcaDispersion) :
    mode.mass ≤ mode.angularFrequency :=
  mode.aboveCutoff

/-- Transverse and longitudinal dielectric response in the normalized Proca
metamaterial model.

The longitudinal law depends on the wave number and therefore records the
paper's spatial-dispersion boundary. -/
structure ProcaMaterialResponse where
  mode : ProcaDispersion
  transverseDielectric : ℝ
  longitudinalDielectric : ℝ
  transverseLaw : transverseDielectric =
    1 - mode.mass ^ 2 / mode.angularFrequency ^ 2
  longitudinalLaw : longitudinalDielectric =
    1 - (mode.mass ^ 2 + mode.waveNumber ^ 2) /
      mode.angularFrequency ^ 2

/-- The transverse dielectric response follows the supplied Proca law. -/
lemma ProcaMaterialResponse.transverse_holds (response : ProcaMaterialResponse) :
    response.transverseDielectric =
      1 - response.mode.mass ^ 2 / response.mode.angularFrequency ^ 2 :=
  response.transverseLaw

/-- The longitudinal dielectric response follows the supplied spatially
nonlocal law. -/
lemma ProcaMaterialResponse.longitudinal_holds (response : ProcaMaterialResponse) :
    response.longitudinalDielectric =
      1 - (response.mode.mass ^ 2 + response.mode.waveNumber ^ 2) /
        response.mode.angularFrequency ^ 2 :=
  response.longitudinalLaw

/-- The longitudinal response vanishes on the supplied Proca dispersion shell. -/
lemma ProcaMaterialResponse.longitudinal_zero_on_dispersion
    (response : ProcaMaterialResponse) :
    response.longitudinalDielectric = 0 := by
  rw [response.longitudinalLaw]
  have dispersion_sum :
      response.mode.mass ^ 2 + response.mode.waveNumber ^ 2 =
        response.mode.angularFrequency ^ 2 := by
    nlinarith [response.mode.dispersionLaw]
  rw [dispersion_sum]
  field_simp [ne_of_gt response.mode.angularFrequency_pos]
  norm_num

/-- A finite planar Proca/Chern--Simons response from the nonlinear (2+1)-D
model. The Chern--Simons response is retained as complex-valued model data. -/
structure PlanarProcaCSResponse where
  procaMass : ℝ
  procaMass_nonnegative : 0 ≤ procaMass
  chernSimonsMass : ℝ
  angularFrequency : ℝ
  angularFrequency_pos : 0 < angularFrequency
  waveNumber : ℝ
  transverseDielectric : ℝ
  longitudinalDielectric : ℝ
  chernSimonsDielectric : ℂ
  transverseLaw : transverseDielectric =
    1 - procaMass ^ 2 / angularFrequency ^ 2
  longitudinalLaw : longitudinalDielectric =
    1 - (procaMass ^ 2 + waveNumber ^ 2) /
      angularFrequency ^ 2
  chernSimonsLaw : chernSimonsDielectric =
    Complex.I * chernSimonsMass / (angularFrequency : ℂ) ^ 3

/-- The planar transverse response follows its supplied law. -/
lemma PlanarProcaCSResponse.transverse_holds
    (response : PlanarProcaCSResponse) :
    response.transverseDielectric =
      1 - response.procaMass ^ 2 / response.angularFrequency ^ 2 :=
  response.transverseLaw

/-- The planar longitudinal response retains wave-number dependence. -/
lemma PlanarProcaCSResponse.longitudinal_holds
    (response : PlanarProcaCSResponse) :
    response.longitudinalDielectric =
      1 - (response.procaMass ^ 2 + response.waveNumber ^ 2) /
        response.angularFrequency ^ 2 :=
  response.longitudinalLaw

/-- The planar Chern--Simons response follows its supplied complex law. -/
lemma PlanarProcaCSResponse.chern_simons_holds
    (response : PlanarProcaCSResponse) :
    response.chernSimonsDielectric =
      Complex.I * response.chernSimonsMass /
        (response.angularFrequency : ℂ) ^ 3 :=
  response.chernSimonsLaw

/-- A normalized massive cavity mode with the photon-mass frequency correction.

`masslessFrequency` stands for the empty-cavity mode scale, while
`massiveFrequency` records the paper's square-root resonance correction. -/
structure MassiveCavityMode where
  masslessFrequency : ℝ
  masslessFrequency_pos : 0 < masslessFrequency
  photonMassFrequency : ℝ
  photonMassFrequency_nonnegative : 0 ≤ photonMassFrequency
  massiveFrequency : ℝ
  massiveFrequency_pos : 0 < massiveFrequency
  resonanceLaw : massiveFrequency ^ 2 =
    masslessFrequency ^ 2 + photonMassFrequency ^ 2
  radiationPressureRatio : ℝ
  radiationPressureRatioLaw : radiationPressureRatio =
    massiveFrequency / masslessFrequency

/-- A nonzero photon-mass frequency raises the normalized cavity frequency. -/
lemma MassiveCavityMode.massive_frequency_ge_massless
    (mode : MassiveCavityMode) :
    mode.masslessFrequency ≤ mode.massiveFrequency := by
  by_contra not_ge
  have frequency_lt : mode.massiveFrequency < mode.masslessFrequency :=
    lt_of_not_ge not_ge
  have square_difference_pos :
      0 < (mode.masslessFrequency - mode.massiveFrequency) *
        (mode.masslessFrequency + mode.massiveFrequency) :=
    mul_pos (sub_pos.mpr frequency_lt)
      (add_pos mode.masslessFrequency_pos mode.massiveFrequency_pos)
  nlinarith [mode.resonanceLaw, sq_nonneg mode.photonMassFrequency]

/-- The massive-cavity radiation-pressure ratio is at least one. -/
lemma MassiveCavityMode.radiation_pressure_ratio_ge_one
    (mode : MassiveCavityMode) :
    1 ≤ mode.radiationPressureRatio := by
  rw [mode.radiationPressureRatioLaw]
  exact (le_div_iff₀ mode.masslessFrequency_pos).2
    (by simpa using mode.massive_frequency_ge_massless)

/-- The cavity radiation-pressure ratio is strictly above one when the mass
frequency is nonzero. -/
lemma MassiveCavityMode.radiation_pressure_ratio_gt_one
    (mode : MassiveCavityMode)
    (photonMassFrequency_pos : 0 < mode.photonMassFrequency) :
    1 < mode.radiationPressureRatio := by
  have frequency_gt : mode.masslessFrequency < mode.massiveFrequency := by
    by_contra not_gt
    have frequency_le : mode.massiveFrequency ≤ mode.masslessFrequency :=
      le_of_not_gt not_gt
    have square_difference_nonneg :
        0 ≤ (mode.masslessFrequency - mode.massiveFrequency) *
          (mode.masslessFrequency + mode.massiveFrequency) :=
      mul_nonneg (sub_nonneg.mpr frequency_le)
        (add_pos mode.masslessFrequency_pos mode.massiveFrequency_pos).le
    nlinarith [mode.resonanceLaw, sq_pos_of_pos photonMassFrequency_pos]
  rw [mode.radiationPressureRatioLaw]
  apply (lt_div_iff₀ mode.masslessFrequency_pos).2
  simpa using frequency_gt

/-- A finite Proca dipole pattern with complementary transverse and longitudinal
angular contributions. `scale` contains the source and dispersion prefactor. -/
structure ProcaDipolePattern where
  scale : ℝ
  scale_nonnegative : 0 ≤ scale
  angle : ℝ
  transversePattern : ℝ
  longitudinalPattern : ℝ
  totalPattern : ℝ
  transverseLaw : transversePattern = scale * (Real.sin angle) ^ 2
  longitudinalLaw : longitudinalPattern = scale * (Real.cos angle) ^ 2
  totalLaw : totalPattern = transversePattern + longitudinalPattern

/-- The summed transverse and longitudinal Proca dipole pattern is isotropic in
this finite angular model. -/
lemma ProcaDipolePattern.total_isotropic (pattern : ProcaDipolePattern) :
    pattern.totalPattern = pattern.scale := by
  rw [pattern.totalLaw, pattern.transverseLaw, pattern.longitudinalLaw]
  rw [← mul_add, Real.sin_sq_add_cos_sq, mul_one]

/-- A finite quantum-source directivity sample based on local detection rate over
an explicitly supplied positive angular average. -/
structure QuantumSourceDirectivity where
  localDetectionRate : ℝ
  localDetectionRate_nonnegative : 0 ≤ localDetectionRate
  angularAverageRate : ℝ
  angularAverageRate_pos : 0 < angularAverageRate
  directivity : ℝ
  directivityLaw : directivity = localDetectionRate / angularAverageRate

/-- A finite directivity is nonnegative. -/
lemma QuantumSourceDirectivity.directivity_nonnegative
    (source : QuantumSourceDirectivity) :
    0 ≤ source.directivity := by
  rw [source.directivityLaw]
  exact div_nonneg source.localDetectionRate_nonnegative
    source.angularAverageRate_pos.le

/-- An isotropic source has unit directivity when its local rate equals the
angular average. -/
lemma QuantumSourceDirectivity.isotropic_directivity
    (source : QuantumSourceDirectivity)
    (rate_eq_average : source.localDetectionRate = source.angularAverageRate) :
    source.directivity = 1 := by
  rw [source.directivityLaw, rate_eq_average]
  exact div_self (ne_of_gt source.angularAverageRate_pos)

/-- A finite scalar witness for the paper's nonlocalizability decay estimate.
The commutator magnitude is modeled as a positive coefficient divided by the
fourth power of separation. -/
structure NonlocalityDecay where
  separation : ℝ
  separation_pos : 0 < separation
  coefficient : ℝ
  coefficient_pos : 0 < coefficient
  commutatorMagnitude : ℝ
  commutatorMagnitudeLaw : commutatorMagnitude =
    coefficient / separation ^ 4

/-- The finite nonlocality-decay witness is positive. -/
lemma NonlocalityDecay.commutator_positive (witness : NonlocalityDecay) :
    0 < witness.commutatorMagnitude := by
  rw [witness.commutatorMagnitudeLaw]
  exact div_pos witness.coefficient_pos (pow_pos witness.separation_pos 4)

end Signals.Pending
