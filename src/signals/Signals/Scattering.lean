import Mathlib.Data.Complex.Basic
import Mathlib.Data.Real.Basic
import Mathlib.Tactic
import Signals.IQ
import Signals.Propagation

namespace Signals.Scattering

open Signals.IQ
open Signals.Propagation

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

end Signals.Scattering
