import Mathlib.Data.Real.Basic
import Mathlib.Tactic
import Signals.IQ
import Signals.NonDestructive
import Signals.Propagation

namespace Signals.Homodyne

open Signals.IQ
open Signals.NonDestructive
open Signals.Propagation
open Signals.Units

/-- A classical local oscillator with a selectable phase reference. -/
structure LocalOscillator where
  amplitude : ℝ
  amplitude_nonnegative : 0 ≤ amplitude
  phase : ℝ

/-- Convert the local oscillator amplitude and phase to an I/Q reference. -/
noncomputable def LocalOscillator.asSample (oscillator : LocalOscillator) : Sample :=
  { inPhase := oscillator.amplitude * Real.cos oscillator.phase
    quadrature := oscillator.amplitude * Real.sin oscillator.phase }

/-- The normalized plus output of an ideal 50:50 beam splitter. -/
noncomputable def beamSplitterPlus (signal reference : Sample) : Sample :=
  { inPhase := (signal.inPhase + reference.inPhase) / Real.sqrt 2
    quadrature := (signal.quadrature + reference.quadrature) / Real.sqrt 2 }

/-- The normalized minus output of an ideal 50:50 beam splitter. -/
noncomputable def beamSplitterMinus (signal reference : Sample) : Sample :=
  { inPhase := (signal.inPhase - reference.inPhase) / Real.sqrt 2
    quadrature := (signal.quadrature - reference.quadrature) / Real.sqrt 2 }

/-- The squared I/Q envelope used as the finite classical detector signal. -/
noncomputable def sampleEnergy (sample : Sample) : ℝ :=
  Complex.normSq sample.asComplex

/-- The differential signal produced by the two balanced detector outputs. -/
noncomputable def differentialPhotocurrent (signal : Sample)
    (oscillator : LocalOscillator) : ℝ :=
  sampleEnergy (beamSplitterPlus signal oscillator.asSample) -
    sampleEnergy (beamSplitterMinus signal oscillator.asSample)

/-- A complete finite classical balanced-homodyne observation. -/
structure BalancedHomodyne where
  signal : Sample
  localOscillator : LocalOscillator
  plusOutput : Sample
  minusOutput : Sample
  plusOutputLaw : plusOutput = beamSplitterPlus signal localOscillator.asSample
  minusOutputLaw : minusOutput = beamSplitterMinus signal localOscillator.asSample
  plusDetector : ℝ
  minusDetector : ℝ
  plusDetectorLaw : plusDetector = sampleEnergy plusOutput
  minusDetectorLaw : minusDetector = sampleEnergy minusOutput
  differentialPhotocurrent : ℝ
  differentialLaw : differentialPhotocurrent = plusDetector - minusDetector

/-- The ideal beam splitter conserves the finite I/Q energy. -/
lemma beamSplitter_energy_conserved (signal reference : Sample) :
    sampleEnergy (beamSplitterPlus signal reference) +
        sampleEnergy (beamSplitterMinus signal reference) =
      sampleEnergy signal + sampleEnergy reference := by
  rw [sampleEnergy, sampleEnergy, sampleEnergy, sampleEnergy]
  simp only [Sample.normSq_eq, beamSplitterPlus, beamSplitterMinus]
  have hsqrt : (Real.sqrt 2) ^ 2 = (2 : ℝ) := by
    norm_num
  field_simp [hsqrt]
  rw [hsqrt]
  ring

/-- The detector difference is the interference term of signal and reference. -/
lemma differentialPhotocurrent_eq_interference (signal : Sample)
    (oscillator : LocalOscillator) :
    differentialPhotocurrent signal oscillator =
      2 * (signal.inPhase * oscillator.amplitude * Real.cos oscillator.phase +
        signal.quadrature * oscillator.amplitude * Real.sin oscillator.phase) := by
  rw [differentialPhotocurrent, sampleEnergy, sampleEnergy]
  simp only [Sample.normSq_eq, beamSplitterPlus, beamSplitterMinus,
    LocalOscillator.asSample]
  have hsqrt : (Real.sqrt 2) ^ 2 = (2 : ℝ) := by
    norm_num
  field_simp [hsqrt]
  rw [hsqrt]
  ring

/-- The finite quadrature selected by a local-oscillator phase. -/
noncomputable def rotatedQuadrature (signal : Sample) (phase : ℝ) : ℝ :=
  signal.inPhase * Real.cos phase + signal.quadrature * Real.sin phase

/-- The balanced detector difference is twice the reference amplitude times the
selected finite quadrature. -/
lemma differentialPhotocurrent_eq_rotatedQuadrature (signal : Sample)
    (oscillator : LocalOscillator) :
    differentialPhotocurrent signal oscillator =
      2 * oscillator.amplitude * rotatedQuadrature signal oscillator.phase := by
  rw [differentialPhotocurrent_eq_interference]
  unfold rotatedQuadrature
  ring

/-- A balanced homodyne record exposes its differential-current law. -/
lemma BalancedHomodyne.differential_holds (measurement : BalancedHomodyne) :
    measurement.differentialPhotocurrent =
      measurement.plusDetector - measurement.minusDetector :=
  measurement.differentialLaw

/-- Calibrated common-mode rejection data for a balanced detector. -/
structure CommonModeRejection where
  decibels : ℝ
  decibels_nonnegative : 0 ≤ decibels
  leakageFactor : BoundedFactor
  leakageFactorLaw : leakageFactor.value = 10 ^ (-decibels / 10)

/-- A finite detector channel response with efficiency, bandwidth, and dark current. -/
structure DetectorChannel where
  efficiency : BoundedFactor
  responsivity : Responsivity
  responsivity_nonnegative : 0 ≤ responsivity.amperesPerWatt
  darkCurrent : Current
  darkCurrent_nonnegative : 0 ≤ darkCurrent.amperes
  bandwidth : Frequency
  bandwidth_pos : 0 < bandwidth.hz

/-- A detector observation with an explicit optical-power-to-current law. -/
structure DetectorObservation where
  detector : DetectorChannel
  incidentPower : Power
  incidentPower_nonnegative : 0 ≤ incidentPower.watts
  outputCurrent : Current
  outputCurrentLaw :
    outputCurrent.amperes =
      detector.responsivity.amperesPerWatt * detector.efficiency.value *
          incidentPower.watts + detector.darkCurrent.amperes

/-- Shot, electronic, and local-oscillator intensity-noise data. -/
structure DetectorNoiseProfile where
  shotNoise : CurrentNoisePowerDensity
  shotNoise_nonnegative : 0 ≤ shotNoise.amperesSquaredPerHertz
  electronicNoise : CurrentNoisePowerDensity
  electronicNoise_nonnegative : 0 ≤ electronicNoise.amperesSquaredPerHertz
  localOscillatorRin : CurrentNoisePowerDensity
  localOscillatorRin_nonnegative : 0 ≤ localOscillatorRin.amperesSquaredPerHertz
  commonModeRejection : CommonModeRejection

/-- Common-mode noise leakage after a calibrated rejection factor. -/
def CommonModeRejection.leakedNoise
    (rejection : CommonModeRejection) (noise : CurrentNoisePowerDensity) : ℝ :=
  rejection.leakageFactor.value * noise.amperesSquaredPerHertz

/-- A bounded rejection factor preserves nonnegative noise density. -/
lemma CommonModeRejection.leakedNoise_nonnegative
    (rejection : CommonModeRejection) (noise : CurrentNoisePowerDensity)
    (noise_nonnegative : 0 ≤ noise.amperesSquaredPerHertz) :
    0 ≤ rejection.leakedNoise noise := by
  unfold CommonModeRejection.leakedNoise
  exact mul_nonneg rejection.leakageFactor.nonnegative noise_nonnegative

/-- Common-mode noise leakage cannot exceed the supplied noise density. -/
lemma CommonModeRejection.leakedNoise_le
    (rejection : CommonModeRejection) (noise : CurrentNoisePowerDensity)
    (noise_nonnegative : 0 ≤ noise.amperesSquaredPerHertz) :
    rejection.leakedNoise noise ≤ noise.amperesSquaredPerHertz := by
  unfold CommonModeRejection.leakedNoise
  calc
    rejection.leakageFactor.value * noise.amperesSquaredPerHertz ≤
        1 * noise.amperesSquaredPerHertz := by
      exact mul_le_mul_of_nonneg_right rejection.leakageFactor.le_one noise_nonnegative
    _ = noise.amperesSquaredPerHertz := by ring

/-- The two calibrated current channels of a balanced detector. -/
structure BalancedDetectorObservation where
  plus : DetectorObservation
  minus : DetectorObservation
  commonModeCurrent : Current
  differentialCurrent : Current
  commonModeLaw :
    commonModeCurrent.amperes =
      (plus.outputCurrent.amperes + minus.outputCurrent.amperes) / 2
  differentialLaw :
    differentialCurrent.amperes =
      plus.outputCurrent.amperes - minus.outputCurrent.amperes

/-- Equal detector currents cancel in the balanced differential channel. -/
lemma BalancedDetectorObservation.differential_zero_of_equal
    (measurement : BalancedDetectorObservation)
    (equal_currents : measurement.plus.outputCurrent.amperes =
      measurement.minus.outputCurrent.amperes) :
    measurement.differentialCurrent.amperes = 0 := by
  rw [measurement.differentialLaw, equal_currents]
  ring

/-- Raw-current calibration with a measured residual and explicit tolerance. -/
structure CalibratedPhotocurrent where
  rawCurrent : Current
  calibration : CalibrationRecord
  rawCurrentLaw : calibration.rawAfter = rawCurrent.amperes
  calibratedCurrent : Current
  calibratedCurrentLaw : calibratedCurrent.amperes = calibration.calibrated
  residual : ℝ
  tolerance : ℝ
  tolerance_nonnegative : 0 ≤ tolerance
  residualLaw : residual = calibratedCurrent.amperes - calibration.calibrated

/-- A calibrated photocurrent is accepted when its residual is in tolerance. -/
def CalibratedPhotocurrent.consistent (measurement : CalibratedPhotocurrent) : Prop :=
  |measurement.residual| ≤ measurement.tolerance

/-- The calibrated photocurrent exposes its raw-data preservation invariant. -/
lemma CalibratedPhotocurrent.raw_preserved (measurement : CalibratedPhotocurrent) :
    measurement.calibration.rawAfter = measurement.calibration.rawBefore :=
  measurement.calibration.rawPreserved

/-- The calibrated photocurrent exposes its residual tolerance condition. -/
lemma CalibratedPhotocurrent.consistent_iff (measurement : CalibratedPhotocurrent) :
    measurement.consistent ↔ |measurement.residual| ≤ measurement.tolerance := by
  rfl

/-- Bin a measured quadrature against an explicit finite threshold. -/
noncomputable def signBin (threshold outcome : ℝ) : Bool :=
  if threshold ≤ outcome then true else false

/-- A quadrature outcome with its threshold classification recorded. -/
structure BinnedQuadrature where
  outcome : ℝ
  threshold : ℝ
  bin : Bool
  binLaw : bin = signBin threshold outcome

/-- A finite pair of homodyne quadrature traces and their summary statistics. -/
structure DualHomodyneTrace (sampleCount : ℕ) where
  sampleCount_pos : 0 < sampleCount
  receiverA : BalancedHomodyne
  receiverB : BalancedHomodyne
  missingSamples : ℕ
  missingSamples_le_count : missingSamples ≤ sampleCount
  validSampleCount : ℕ
  validSampleCount_pos : 0 < validSampleCount
  validSampleCountLaw : validSampleCount + missingSamples = sampleCount
  outcomesA : Fin sampleCount → ℝ
  outcomesB : Fin sampleCount → ℝ
  outcomesALaw : ∀ index, outcomesA index = receiverA.differentialPhotocurrent
  outcomesBLaw : ∀ index, outcomesB index = receiverB.differentialPhotocurrent
  meanA : ℝ
  meanB : ℝ
  meanALaw : meanA =
    (∑ index : Fin sampleCount, outcomesA index) / (validSampleCount : ℝ)
  meanBLaw : meanB =
    (∑ index : Fin sampleCount, outcomesB index) / (validSampleCount : ℝ)
  covariance : ℝ
  covarianceLaw : covariance =
    (∑ index : Fin sampleCount,
      (outcomesA index - meanA) * (outcomesB index - meanB)) /
        (validSampleCount : ℝ)
  correlationScale : ℝ
  correlationScale_pos : 0 < correlationScale
  normalizedCorrelation : ℝ
  normalizedCorrelationLaw :
    normalizedCorrelation = covariance / correlationScale
  residual : ℝ
  residualTolerance : ℝ
  residualTolerance_nonnegative : 0 ≤ residualTolerance
  residualWithinTolerance : |residual| ≤ residualTolerance
  thresholdA : ℝ
  thresholdB : ℝ
  binsA : Fin sampleCount → Bool
  binsB : Fin sampleCount → Bool
  binsALaw : ∀ index, binsA index = signBin thresholdA (outcomesA index)
  binsBLaw : ∀ index, binsB index = signBin thresholdB (outcomesB index)

/-- The first finite trace mean follows its supplied sample average. -/
lemma DualHomodyneTrace.mean_a_holds {sampleCount : ℕ}
    (trace : DualHomodyneTrace sampleCount) :
    trace.meanA =
      (∑ index : Fin sampleCount, trace.outcomesA index) /
        (trace.validSampleCount : ℝ) :=
  trace.meanALaw

/-- The second finite trace mean follows its supplied sample average. -/
lemma DualHomodyneTrace.mean_b_holds {sampleCount : ℕ}
    (trace : DualHomodyneTrace sampleCount) :
    trace.meanB =
      (∑ index : Fin sampleCount, trace.outcomesB index) /
        (trace.validSampleCount : ℝ) :=
  trace.meanBLaw

/-- The finite covariance follows its supplied centered-product average. -/
lemma DualHomodyneTrace.covariance_holds {sampleCount : ℕ}
    (trace : DualHomodyneTrace sampleCount) :
    trace.covariance =
      (∑ index : Fin sampleCount,
        (trace.outcomesA index - trace.meanA) *
          (trace.outcomesB index - trace.meanB)) /
        (trace.validSampleCount : ℝ) :=
  trace.covarianceLaw

/-- The normalized finite correlation follows its supplied scale. -/
lemma DualHomodyneTrace.normalized_correlation_holds {sampleCount : ℕ}
    (trace : DualHomodyneTrace sampleCount) :
    trace.normalizedCorrelation = trace.covariance / trace.correlationScale :=
  trace.normalizedCorrelationLaw

/-- The finite dual trace records a bounded count of missing samples. -/
lemma DualHomodyneTrace.missing_samples_bounded {sampleCount : ℕ}
    (trace : DualHomodyneTrace sampleCount) :
    trace.missingSamples ≤ sampleCount :=
  trace.missingSamples_le_count

/-- The finite dual trace exposes its residual acceptance condition. -/
lemma DualHomodyneTrace.residual_within_tolerance {sampleCount : ℕ}
    (trace : DualHomodyneTrace sampleCount) :
    |trace.residual| ≤ trace.residualTolerance :=
  trace.residualWithinTolerance

/-- A finite spatial homodyne sensor grid with a shared local oscillator. -/
structure HomodyneGrid (width height : ℕ) where
  width_pos : 0 < width
  height_pos : 0 < height
  localOscillator : LocalOscillator
  signal : Fin width → Fin height → Sample
  pixelPhotocurrent : Fin width → Fin height → ℝ
  pixelPhotocurrentLaw : ∀ column row,
    pixelPhotocurrent column row =
      differentialPhotocurrent (signal column row) localOscillator
  phaseMap : Fin width → Fin height → ℝ
  phaseMapLaw : ∀ column row, phaseMap column row = (signal column row).phase

/-- A grid pixel follows the shared-LO differential photocurrent law. -/
lemma HomodyneGrid.pixel_photocurrent_holds {width height : ℕ}
    (grid : HomodyneGrid width height) (column : Fin width) (row : Fin height) :
    grid.pixelPhotocurrent column row =
      differentialPhotocurrent (grid.signal column row) grid.localOscillator :=
  grid.pixelPhotocurrentLaw column row

/-- A grid pixel phase follows the source I/Q phase map. -/
lemma HomodyneGrid.phase_map_holds {width height : ℕ}
    (grid : HomodyneGrid width height) (column : Fin width) (row : Fin height) :
    grid.phaseMap column row = (grid.signal column row).phase :=
  grid.phaseMapLaw column row

/-- A typed sample format for downstream homodyne runtime consumers. -/
structure HomodyneTraceSample where
  timestamp : Duration
  localOscillatorPhase : ℝ
  detectorA : Current
  detectorB : Current
  rawDifferential : Current
  rawDifferentialLaw :
    rawDifferential.amperes = detectorA.amperes - detectorB.amperes
  calibration : CalibrationRecord
  calibratedDifferential : Current
  calibratedDifferentialLaw :
    calibratedDifferential.amperes = calibration.calibrated
  residual : ℝ
  residualTolerance : ℝ
  residualTolerance_nonnegative : 0 ≤ residualTolerance
  loss : BoundedFactor
  efficiency : BoundedFactor

/-- A trace sample preserves the raw detector difference law. -/
lemma HomodyneTraceSample.raw_differential_holds
    (sample : HomodyneTraceSample) :
    sample.rawDifferential.amperes = sample.detectorA.amperes -
      sample.detectorB.amperes :=
  sample.rawDifferentialLaw

/-- A trace sample preserves its affine calibration result. -/
lemma HomodyneTraceSample.calibrated_differential_holds
    (sample : HomodyneTraceSample) :
    sample.calibratedDifferential.amperes = sample.calibration.calibrated :=
  sample.calibratedDifferentialLaw

/-- A dispersive readout composed with balanced detection and current calibration. -/
structure DispersiveHomodyneReadout (state : Type u) where
  readout : DispersiveReadout state
  opticalMeasurement : BalancedHomodyne
  detectorMeasurement : BalancedDetectorObservation
  calibratedCurrent : CalibratedPhotocurrent
  phaseShiftAgreement :
    readout.probePhaseShift = opticalMeasurement.differentialPhotocurrent
  rawCurrentAgreement :
    calibratedCurrent.rawCurrent.amperes =
      detectorMeasurement.differentialCurrent.amperes

/-- The composed record exposes agreement between dispersive phase and homodyne signal. -/
lemma DispersiveHomodyneReadout.phase_shift_agrees
    {state : Type u} (measurement : DispersiveHomodyneReadout state) :
    measurement.readout.probePhaseShift =
      measurement.opticalMeasurement.differentialPhotocurrent :=
  measurement.phaseShiftAgreement

/-- The composed record preserves the detector pair's raw differential current. -/
lemma DispersiveHomodyneReadout.raw_current_agrees
    {state : Type u} (measurement : DispersiveHomodyneReadout state) :
    measurement.calibratedCurrent.rawCurrent.amperes =
      measurement.detectorMeasurement.differentialCurrent.amperes :=
  measurement.rawCurrentAgreement

end Signals.Homodyne
