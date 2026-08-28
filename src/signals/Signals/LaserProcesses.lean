import Mathlib.Data.Real.Basic
import Mathlib.Tactic
import Signals.Units

namespace Signals.Pending

open Signals.Units

/-! # Laser-processing task models

These records keep optical power, pulse energy, fluence, pulse duration, and
beam geometry separate. They are calibration contracts for process planning,
not universal operating recipes. In particular, a consumer laser-head rating
cannot be substituted for a pulsed-process fluence or a shock pressure.
-/

/-- The beam or source regime used by a laser-processing task. -/
inductive LaserBeamKind
  | continuousWave
  | nanosecondPulse
  | picosecondPulse
  | femtosecondPulse
  | pulsedShockDrive
  | unsupportedProcaHolographic
  deriving DecidableEq, Repr

/-- The status of a task relative to the evidence currently available. -/
inductive LaserTaskStatus
  | demonstratedProcess
  | demonstratedAnalog
  | calibrationRequired
  | unsupportedProposal
  deriving DecidableEq, Repr

/-- A finite task label covering the requested process families. -/
inductive LaserTask
  | ablation
  | laserCompressionShock
  | graphene
  | convergentHolographicGraphene
  | diamond
  | convergentHolographicGrapheneAndDiamond
  deriving DecidableEq, Repr

/-- A CW/scanned laser task, where average optical power and scan geometry are
separate from the material threshold. -/
structure ContinuousWaveLaserTask where
  task : LaserTask
  beamKind : LaserBeamKind
  status : LaserTaskStatus
  wavelength : Length
  wavelength_pos : 0 < wavelength.meters
  averagePower : Power
  averagePower_nonnegative : 0 ≤ averagePower.watts
  maximumAveragePower : Power
  maximumAveragePower_nonnegative : 0 ≤ maximumAveragePower.watts
  averagePower_le_maximum : averagePower.watts ≤ maximumAveragePower.watts
  spotArea : Area
  spotArea_pos : 0 < spotArea.squareMeters
  scanSpeed : Speed
  scanSpeed_pos : 0 < scanSpeed.metersPerSecond
  absorbedPowerThreshold : Power
  absorbedPowerThreshold_nonnegative : 0 ≤ absorbedPowerThreshold.watts
  endToEndEfficiency : ℝ
  endToEndEfficiency_nonnegative : 0 ≤ endToEndEfficiency
  endToEndEfficiency_le_one : endToEndEfficiency ≤ 1
  absorbedPowerLaw : absorbedPowerThreshold.watts ≤
    endToEndEfficiency * averagePower.watts

/-- The CW task's calibrated threshold is met by its declared average power. -/
lemma ContinuousWaveLaserTask.threshold_met
    (task : ContinuousWaveLaserTask) :
    task.absorbedPowerThreshold.watts ≤
      task.endToEndEfficiency * task.averagePower.watts :=
  task.absorbedPowerLaw

/-- Under positive efficiency, a CW task requires at least threshold divided by
end-to-end efficiency in average incident optical power. -/
lemma ContinuousWaveLaserTask.average_power_lower_bound
    (task : ContinuousWaveLaserTask)
    (efficiency_pos : 0 < task.endToEndEfficiency) :
    task.absorbedPowerThreshold.watts / task.endToEndEfficiency ≤
      task.averagePower.watts := by
  apply (div_le_iff₀ efficiency_pos).2
  simpa [mul_comm] using task.absorbedPowerLaw

/-- A CW task stays below its calibrated maximum average optical power. -/
lemma ContinuousWaveLaserTask.average_power_le_maximum
    (task : ContinuousWaveLaserTask) :
    task.averagePower.watts ≤ task.maximumAveragePower.watts :=
  task.averagePower_le_maximum

/-- A pulsed laser task, where pulse energy, pulse duration, repetition rate,
spot area, fluence, and peak power are distinct calibrated quantities. -/
structure PulsedLaserTask where
  task : LaserTask
  beamKind : LaserBeamKind
  status : LaserTaskStatus
  wavelength : Length
  wavelength_pos : 0 < wavelength.meters
  pulseEnergy : Energy
  pulseEnergy_nonnegative : 0 ≤ pulseEnergy.joules
  pulseDuration : Duration
  pulseDuration_pos : 0 < pulseDuration.seconds
  repetitionRate : Frequency
  repetitionRate_nonnegative : 0 ≤ repetitionRate.hz
  spotArea : Area
  spotArea_pos : 0 < spotArea.squareMeters
  fluence : LaserFluence
  fluence_nonnegative : 0 ≤ fluence.joulesPerSquareMeter
  peakPower : Power
  peakPower_nonnegative : 0 ≤ peakPower.watts
  maximumPeakPower : Power
  maximumPeakPower_nonnegative : 0 ≤ maximumPeakPower.watts
  peakPower_le_maximum : peakPower.watts ≤ maximumPeakPower.watts
  fluenceLaw : fluence.joulesPerSquareMeter * spotArea.squareMeters =
    pulseEnergy.joules
  peakPowerLaw : peakPower.watts * pulseDuration.seconds = pulseEnergy.joules

/-- Pulse fluence is pulse energy divided by illuminated area. -/
lemma PulsedLaserTask.fluence_holds
    (task : PulsedLaserTask) :
    task.fluence.joulesPerSquareMeter * task.spotArea.squareMeters =
      task.pulseEnergy.joules :=
  task.fluenceLaw

/-- Peak power is pulse energy divided by pulse duration. -/
lemma PulsedLaserTask.peak_power_holds
    (task : PulsedLaserTask) :
    task.peakPower.watts * task.pulseDuration.seconds = task.pulseEnergy.joules :=
  task.peakPowerLaw

/-- A pulsed task stays below its calibrated maximum peak power. -/
lemma PulsedLaserTask.peak_power_le_maximum
    (task : PulsedLaserTask) :
    task.peakPower.watts ≤ task.maximumPeakPower.watts :=
  task.peakPower_le_maximum

/-- A pulsed task has the expected average power when the pulse train is
specified by its repetition rate. -/
structure PulsedLaserAveragePower where
  task : PulsedLaserTask
  averagePower : Power
  averagePower_nonnegative : 0 ≤ averagePower.watts
  maximumAveragePower : Power
  maximumAveragePower_nonnegative : 0 ≤ maximumAveragePower.watts
  averagePower_le_maximum : averagePower.watts ≤ maximumAveragePower.watts
  averagePowerLaw : averagePower.watts =
    task.pulseEnergy.joules * task.repetitionRate.hz

/-- The pulse-train average power follows energy times repetition rate. -/
lemma PulsedLaserAveragePower.average_power_holds
    (power : PulsedLaserAveragePower) :
    power.averagePower.watts =
      power.task.pulseEnergy.joules * power.task.repetitionRate.hz :=
  power.averagePowerLaw

/-- A pulse train stays below its calibrated maximum average optical power. -/
lemma PulsedLaserAveragePower.average_power_le_maximum
    (power : PulsedLaserAveragePower) :
    power.averagePower.watts ≤ power.maximumAveragePower.watts :=
  power.averagePower_le_maximum

/-- A laser shock task records the pressure threshold separately from laser
energy and fluence. The pressure is a measured or modeled shock-state input. -/
structure LaserShockTask where
  pulsedTask : PulsedLaserTask
  shockPressure : Pressure
  shockPressure_nonnegative : 0 ≤ shockPressure.pascals
  shockPressureThreshold : Pressure
  shockPressureThreshold_nonnegative : 0 ≤ shockPressureThreshold.pascals
  pressureThresholdLaw : shockPressureThreshold.pascals ≤ shockPressure.pascals
  substrateCalibrated : Bool
  shockConfinementCalibrated : Bool

/-- A shock task meets its supplied pressure threshold. -/
lemma LaserShockTask.pressure_threshold_met
    (task : LaserShockTask) :
    task.shockPressureThreshold.pascals ≤ task.shockPressure.pascals :=
  task.pressureThresholdLaw

/-- A volumetric holographic claim is represented as an evidence boundary, not
as a conversion theorem from beam interference to graphene or diamond. -/
structure HolographicLaserTaskBoundary where
  task : LaserTask
  beamKind : LaserBeamKind
  status : LaserTaskStatus
  sourcePower : Power
  sourcePower_nonnegative : 0 ≤ sourcePower.watts
  maximumSourcePower : Power
  maximumSourcePower_nonnegative : 0 ≤ maximumSourcePower.watts
  sourcePower_le_maximum : sourcePower.watts ≤ maximumSourcePower.watts
  beamCount : ℕ
  beamCount_pos : 0 < beamCount
  phaseControlCalibrated : Bool
  focalVolumeCalibrated : Bool
  materialTransformationVerified : Bool
  independentStructuralVerification : Bool

/-- The unsupported holographic task remains explicitly classified as such. -/
lemma HolographicLaserTaskBoundary.is_unsupported_proposal
    (task : HolographicLaserTaskBoundary)
    (status_law : task.status = LaserTaskStatus.unsupportedProposal) :
    task.status = LaserTaskStatus.unsupportedProposal :=
  status_law

/-- An unsupported holographic source remains below its explicit declared
maximum source-power budget. -/
lemma HolographicLaserTaskBoundary.source_power_le_maximum
    (task : HolographicLaserTaskBoundary) :
    task.sourcePower.watts ≤ task.maximumSourcePower.watts :=
  task.sourcePower_le_maximum

end Signals.Pending
