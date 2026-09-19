import Mathlib.Data.Real.Basic
import Mathlib.Tactic
import Signals.Units

namespace Signals.Lasers

open Signals.Units

/-! # Laser source and process parameter contracts

This module separates laser-source families from process tasks. Its records keep
wavelength, power, pulse, fluence, scan, and shock quantities explicit. They are
calibration contracts; they do not infer a material transformation from a
nominal laser label.
-/

/-- Source families represented by the laser parameter model. -/
inductive LaserKind
  | semiconductorDiode
  | fiber
  | carbonDioxide
  | ndYag
  | excimer
  | ultrafast
  | shockDrive
  | proposedProcaHolographic
  deriving DecidableEq, Repr

/-- Emission regimes used by the parameter records. -/
inductive LaserMode
  | continuousWave
  | nanosecondPulse
  | picosecondPulse
  | femtosecondPulse
  | pulsedShock
  deriving DecidableEq, Repr

/-- Evidence state for a laser profile or a proposed source family. -/
inductive LaserEvidenceStatus
  | demonstratedProcess
  | calibrationRequired
  | modeledOnly
  | unsupportedProposal
  deriving DecidableEq, Repr

/-- The finite source-family inventory exposed by the module. -/
def laserKinds : List LaserKind :=
  [LaserKind.semiconductorDiode, LaserKind.fiber,
    LaserKind.carbonDioxide, LaserKind.ndYag, LaserKind.excimer,
    LaserKind.ultrafast, LaserKind.shockDrive,
    LaserKind.proposedProcaHolographic]

/-- A conservative default evidence boundary for a source family. -/
def LaserKind.defaultEvidence : LaserKind → LaserEvidenceStatus
  | LaserKind.proposedProcaHolographic => LaserEvidenceStatus.unsupportedProposal
  | _ => LaserEvidenceStatus.calibrationRequired

/-- Parameters shared by continuous-wave and pulsed laser profiles. -/
structure CommonParameters where
  wavelength : Length
  wavelength_pos : 0 < wavelength.meters
  spotArea : Area
  spotArea_pos : 0 < spotArea.squareMeters
  evidenceStatus : LaserEvidenceStatus

/-- Parameters for a continuous-wave or scanned laser. -/
structure ContinuousWaveParameters extends CommonParameters where
  averagePower : Power
  averagePower_nonnegative : 0 ≤ averagePower.watts
  scanSpeed : Speed
  scanSpeed_pos : 0 < scanSpeed.metersPerSecond
  exposureDuration : Duration
  exposureDuration_pos : 0 < exposureDuration.seconds

/-- Parameters for a pulsed laser. -/
structure PulsedParameters extends CommonParameters where
  pulseEnergy : Energy
  pulseEnergy_nonnegative : 0 ≤ pulseEnergy.joules
  pulseDuration : Duration
  pulseDuration_pos : 0 < pulseDuration.seconds
  repetitionRate : Frequency
  repetitionRate_nonnegative : 0 ≤ repetitionRate.hz
  fluence : LaserFluence
  fluence_nonnegative : 0 ≤ fluence.joulesPerSquareMeter
  peakPower : Power
  peakPower_nonnegative : 0 ≤ peakPower.watts
  fluenceLaw : fluence.joulesPerSquareMeter * spotArea.squareMeters =
    pulseEnergy.joules
  peakPowerLaw : peakPower.watts * pulseDuration.seconds = pulseEnergy.joules

/-- Parameters for a pulsed laser process with a measured shock state. -/
structure ShockParameters extends PulsedParameters where
  shockPressure : Pressure
  shockPressure_nonnegative : 0 ≤ shockPressure.pascals
  shockPressureThreshold : Pressure
  shockPressureThreshold_nonnegative : 0 ≤ shockPressureThreshold.pascals
  pressureThresholdLaw : shockPressureThreshold.pascals ≤ shockPressure.pascals

/-- A typed laser profile with source family, emission mode, and parameters. -/
inductive LaserProfile
  | continuousWave (kind : LaserKind) (parameters : ContinuousWaveParameters)
  | pulsed (kind : LaserKind) (mode : LaserMode) (parameters : PulsedParameters)
  | shock (parameters : ShockParameters)

/-- The source family associated with a profile. -/
def LaserProfile.kind : LaserProfile → LaserKind
  | LaserProfile.continuousWave kind _ => kind
  | LaserProfile.pulsed kind _ _ => kind
  | LaserProfile.shock _ => LaserKind.shockDrive

/-- The emission regime associated with a profile. -/
def LaserProfile.mode : LaserProfile → LaserMode
  | LaserProfile.continuousWave _ _ => LaserMode.continuousWave
  | LaserProfile.pulsed _ mode _ => mode
  | LaserProfile.shock _ => LaserMode.pulsedShock

/-- The wavelength associated with a profile. -/
def LaserProfile.wavelength : LaserProfile → Length
  | LaserProfile.continuousWave _ parameters => parameters.wavelength
  | LaserProfile.pulsed _ _ parameters => parameters.wavelength
  | LaserProfile.shock parameters => parameters.wavelength

/-- The average optical power represented by a profile. -/
def LaserProfile.averagePower : LaserProfile → Power
  | LaserProfile.continuousWave _ parameters => parameters.averagePower
  | LaserProfile.pulsed _ _ parameters =>
      { watts := parameters.pulseEnergy.joules * parameters.repetitionRate.hz }
  | LaserProfile.shock parameters =>
      { watts := parameters.pulseEnergy.joules * parameters.repetitionRate.hz }

/-- Pulse fluence follows pulse energy divided by illuminated area. -/
lemma PulsedParameters.fluence_holds (parameters : PulsedParameters) :
    parameters.fluence.joulesPerSquareMeter * parameters.spotArea.squareMeters =
      parameters.pulseEnergy.joules :=
  parameters.fluenceLaw

/-- Pulse peak power follows pulse energy divided by pulse duration. -/
lemma PulsedParameters.peak_power_holds (parameters : PulsedParameters) :
    parameters.peakPower.watts * parameters.pulseDuration.seconds =
      parameters.pulseEnergy.joules :=
  parameters.peakPowerLaw

/-- A shock profile meets its explicitly supplied pressure threshold. -/
lemma ShockParameters.pressure_threshold_met (parameters : ShockParameters) :
    parameters.shockPressureThreshold.pascals ≤ parameters.shockPressure.pascals :=
  parameters.pressureThresholdLaw

end Signals.Lasers
