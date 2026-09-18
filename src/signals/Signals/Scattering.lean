import Mathlib.Data.Complex.Basic
import Mathlib.Data.Real.Basic
import Mathlib.Tactic
import Signals.Contracts
import Signals.IQ
import Signals.Propagation

namespace Signals.Scattering

open Signals.IQ
open Signals.Contracts
open Signals.Propagation
open Signals.Units

/-- A coherent incident/return observation represented by I/Q samples. -/
structure Observation where
  incident : Sample
  incidentNormSq : ℝ
  incidentNormSq_pos : 0 < incidentNormSq
  incidentNormSqLaw : incidentNormSq = Complex.normSq incident.asComplex
  scattered : Sample

/-- A positive incident norm excludes a zero incident complex field. -/
lemma Observation.incident_ne_zero (observation : Observation) :
    observation.incident.asComplex ≠ 0 := by
  intro incident_zero
  have norm_zero : observation.incidentNormSq = 0 := by
    rw [observation.incidentNormSqLaw, incident_zero]
    simp
  linarith [observation.incidentNormSq_pos]

/-- The complex coherent scattering-amplitude ratio. -/
noncomputable def Observation.amplitudeRatio (observation : Observation) : ℂ :=
  observation.scattered.asComplex / observation.incident.asComplex

/-- The measured scattered-to-incident power ratio. -/
noncomputable def Observation.powerRatio (observation : Observation) : ℝ :=
  Complex.normSq observation.scattered.asComplex / observation.incidentNormSq

/-- Scattered power ratio is nonnegative. -/
lemma Observation.powerRatio_nonnegative (observation : Observation) :
    0 ≤ observation.powerRatio := by
  unfold Observation.powerRatio
  exact div_nonneg (Complex.normSq_nonneg _) observation.incidentNormSq_pos.le

/-- A round-trip phase model with an explicit reference phase and unwrapped phase. -/
structure HeightModel where
  waveNumber : ℝ
  waveNumber_ne_zero : waveNumber ≠ 0
  referencePhase : ℝ
  height : ℝ
  unwrappedPhase : ℝ
  roundTripLaw : unwrappedPhase = referencePhase + 2 * waveNumber * height

/-- Recover height from a reference-subtracted unwrapped scattering phase. -/
noncomputable def HeightModel.reconstructHeight (model : HeightModel) : ℝ :=
  (model.unwrappedPhase - model.referencePhase) / (2 * model.waveNumber)

/-- The height reconstruction is exact under the round-trip phase model. -/
lemma HeightModel.reconstructHeight_eq_height (model : HeightModel) :
    model.reconstructHeight = model.height := by
  unfold HeightModel.reconstructHeight
  rw [model.roundTripLaw]
  field_simp [model.waveNumber_ne_zero]
  ring

/-- A scattered-power measurement with a calibrated incident flux. -/
structure CrossSectionMeasurement where
  incidentFlux : ℝ
  incidentFlux_pos : 0 < incidentFlux
  scatteredPower : ℝ
  scatteredPower_nonnegative : 0 ≤ scatteredPower
  crossSection : ℝ
  crossSection_nonnegative : 0 ≤ crossSection
  powerLaw : scatteredPower = incidentFlux * crossSection

/-- Cross section is determined by scattered power and incident flux. -/
lemma CrossSectionMeasurement.crossSection_eq_ratio
    (measurement : CrossSectionMeasurement) :
    measurement.crossSection = measurement.scatteredPower / measurement.incidentFlux := by
  rw [measurement.powerLaw]
  field_simp [measurement.incidentFlux_pos.ne']

/-- A measured quantity with an explicit residual and tolerance. -/
structure ResidualMeasurement where
  predicted : ℝ
  observed : ℝ
  residual : ℝ
  tolerance : ℝ
  tolerance_nonnegative : 0 ≤ tolerance
  residualLaw : residual = observed - predicted

/-- A residual is within the calibrated uncertainty. -/
def ResidualMeasurement.consistent (measurement : ResidualMeasurement) : Prop :=
  |measurement.residual| ≤ measurement.tolerance

/-- An out-of-tolerance residual is an anomaly candidate, not a diagnosis. -/
def ResidualMeasurement.anomalyCandidate (measurement : ResidualMeasurement) : Prop :=
  ¬measurement.consistent

/-- The residual and anomaly predicates expose their intended inequalities. -/
lemma ResidualMeasurement.consistent_iff (measurement : ResidualMeasurement) :
    measurement.consistent ↔ |measurement.residual| ≤ measurement.tolerance := by
  rfl

lemma ResidualMeasurement.anomalyCandidate_iff (measurement : ResidualMeasurement) :
    measurement.anomalyCandidate ↔ ¬|measurement.residual| ≤ measurement.tolerance := by
  rfl

/-- Adapt a scattering residual to the shared measurement contract. -/
def ResidualMeasurement.toResidualContract (measurement : ResidualMeasurement)
  (consistent : measurement.consistent) :
    ResidualContract ℝ ℝ ℝ :=
  { measured := measurement.observed
    predicted := measurement.predicted
    residual := measurement.residual
    residualFunction := fun observed predicted => observed - predicted
    residualLaw := measurement.residualLaw
    magnitude := abs
    magnitude_nonnegative := abs_nonneg _
    tolerance := measurement.tolerance
    tolerance_nonnegative := measurement.tolerance_nonnegative
    withinTolerance := by
      exact measurement.consistent_iff.mp consistent }

/-- A nonnegative signal and positive noise power define a linear SNR model. -/
structure SignalToNoise where
  signalPower : ℝ
  signalPower_nonnegative : 0 ≤ signalPower
  noisePower : ℝ
  noisePower_pos : 0 < noisePower

/-- Signal-to-noise ratio as a dimensionless power ratio. -/
noncomputable def SignalToNoise.ratio (measurement : SignalToNoise) : ℝ :=
  measurement.signalPower / measurement.noisePower

/-- Signal-to-noise ratio is nonnegative. -/
lemma SignalToNoise.ratio_nonnegative (measurement : SignalToNoise) :
    0 ≤ measurement.ratio := by
  unfold SignalToNoise.ratio
  exact div_nonneg measurement.signalPower_nonnegative measurement.noisePower_pos.le

/-- A scattering-metrology record joins coherent data, height reconstruction,
and an independent residual measurement. -/
structure MetrologyRecord where
  observation : Observation
  heightModel : HeightModel
  residual : ResidualMeasurement

/-- A metrology record is accepted only when its residual is consistent. -/
def MetrologyRecord.accepted (record : MetrologyRecord) : Prop :=
  record.residual.consistent

/-- Acceptance is exactly the residual tolerance condition. -/
lemma MetrologyRecord.accepted_iff (record : MetrologyRecord) :
    record.accepted ↔ |record.residual.residual| ≤ record.residual.tolerance := by
  rfl

/-- A passive complex material response at one measured frequency. -/
structure MaterialTransferFunction where
  frequency : Frequency
  frequency_pos : 0 < frequency.hz
  transfer : ℂ
  transmittedPowerRatio : ℝ
  transmittedPowerRatio_nonnegative : 0 ≤ transmittedPowerRatio
  transmittedPowerRatio_le_one : transmittedPowerRatio ≤ 1
  powerLaw : transmittedPowerRatio = Complex.normSq transfer

/-- The material transfer function exposes its complex power law. -/
lemma MaterialTransferFunction.power_holds
    (response : MaterialTransferFunction) :
    response.transmittedPowerRatio = Complex.normSq response.transfer :=
  response.powerLaw

/-- Frequency-dependent bulk attenuation with an explicit exponential law. -/
structure FrequencyDependentAttenuation where
  frequency : Frequency
  frequency_pos : 0 < frequency.hz
  attenuationPerLength : ℝ
  attenuation_nonnegative : 0 ≤ attenuationPerLength
  distance : Length
  distance_nonnegative : 0 ≤ distance.meters
  factor : ℝ
  factorLaw : factor =
    Real.exp (-2 * attenuationPerLength * distance.meters)

/-- Frequency-dependent attenuation is nonnegative. -/
lemma FrequencyDependentAttenuation.factor_nonnegative
    (attenuation : FrequencyDependentAttenuation) :
    0 ≤ attenuation.factor := by
  rw [attenuation.factorLaw]
  exact (Real.exp_pos _).le

/-- Nonnegative frequency-dependent attenuation cannot amplify power. -/
lemma FrequencyDependentAttenuation.factor_le_one
    (attenuation : FrequencyDependentAttenuation) :
    attenuation.factor ≤ 1 := by
  rw [attenuation.factorLaw, ← Real.exp_zero, Real.exp_le_exp]
  nlinarith [attenuation.attenuation_nonnegative,
    attenuation.distance_nonnegative]

/-- Finite speckle covariance metadata for a grid of observations. -/
structure SpeckleCovariance (sampleCount : ℕ) where
  sampleCount_positive : 0 < sampleCount
  covariance : Matrix (Fin sampleCount) (Fin sampleCount) ℝ
  covariance_symmetric : ∀ row column,
    covariance row column = covariance column row
  covariance_diagonal_nonnegative : ∀ index,
    0 ≤ covariance index index

/-- A speckle covariance record exposes its symmetry law. -/
lemma SpeckleCovariance.symmetric
    {sampleCount : ℕ} (covariance : SpeckleCovariance sampleCount)
    (row column : Fin sampleCount) :
    covariance.covariance row column = covariance.covariance column row :=
  covariance.covariance_symmetric row column

/-- A speckle covariance record exposes nonnegative diagonal variance. -/
lemma SpeckleCovariance.diagonal_nonnegative
    {sampleCount : ℕ} (covariance : SpeckleCovariance sampleCount)
    (index : Fin sampleCount) :
    0 ≤ covariance.covariance index index :=
  covariance.covariance_diagonal_nonnegative index

/-- A finite scattering grid with residual uncertainty and speckle metadata. -/
structure GridMetrologyRecord (width height : ℕ) where
  width_positive : 0 < width
  height_positive : 0 < height
  samples : Fin width → Fin height → Observation
  residuals : Fin width → Fin height → ResidualMeasurement
  covariance : SpeckleCovariance (width * height)

/-- A finite grid contains at least one observation in each dimension. -/
lemma GridMetrologyRecord.dimensions_positive
    {width height : ℕ} (record : GridMetrologyRecord width height) :
    0 < width ∧ 0 < height :=
  ⟨record.width_positive, record.height_positive⟩

/-- Every grid residual retains its calibrated uncertainty predicate. -/
def GridMetrologyRecord.consistent
    {width height : ℕ} (record : GridMetrologyRecord width height) : Prop :=
  ∀ row column, (record.residuals row column).consistent

/-- A grid is consistent when each retained residual is within tolerance. -/
lemma GridMetrologyRecord.consistent_iff
    {width height : ℕ} (record : GridMetrologyRecord width height) :
    record.consistent ↔ ∀ row column,
      |(record.residuals row column).residual| ≤
        (record.residuals row column).tolerance := by
  constructor
  · intro consistent row column
    exact (record.residuals row column).consistent_iff.mp
      (consistent row column)
  · intro consistent row column
    exact (record.residuals row column).consistent_iff.mpr
      (consistent row column)

end Signals.Scattering
