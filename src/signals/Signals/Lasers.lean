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
  | laserCompressionShock
  | integratedCarbon
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

/-- Optical amplification mechanisms represented by the parameter model. -/
inductive OpticalAmplificationKind
  | none
  | secondHarmonicResonance
  | fourWaveMixing
  | erbiumDopedFiber
  | semiconductorOpticalAmplifier
  deriving DecidableEq, Repr

/-- Reflector architectures used to provide a calibrated optical feedback path. -/
inductive BraggReflectorKind
  | distributedBraggReflector
  | multilayerBraggMirror
  deriving DecidableEq, Repr

/-- The finite source-family inventory exposed by the module. -/
def laserKinds : List LaserKind :=
  [LaserKind.semiconductorDiode, LaserKind.fiber,
    LaserKind.carbonDioxide, LaserKind.ndYag, LaserKind.excimer,
    LaserKind.ultrafast, LaserKind.shockDrive,
    LaserKind.laserCompressionShock, LaserKind.integratedCarbon,
    LaserKind.proposedProcaHolographic]

/-- A conservative default evidence boundary for a source family. -/
def LaserKind.defaultEvidence : LaserKind → LaserEvidenceStatus
  | LaserKind.proposedProcaHolographic => LaserEvidenceStatus.unsupportedProposal
  | _ => LaserEvidenceStatus.calibrationRequired

/-- Nominal telecom signal wavelength used by the integrated-carbon chat model. -/
noncomputable def telecom1550Nm : Length :=
  { meters := 1550 * 10 ^ (-9 : ℤ) }

lemma telecom1550Nm_positive : 0 < telecom1550Nm.meters := by
  norm_num [telecom1550Nm, zpow_neg]

/-! ## Integrated carbon laser platforms

The chat corpus describes N-LIG waveguides, carbon-nanotube structures, and
rGO-vitrimer metasurfaces as proposed integrated components around a nominal
1550 nm signal. These labels are kept separate from demonstrated laser-source
physics; the profile carries an explicit evidence status and measured/calibrated
power fields.
-/

/-- Carbon components that may be integrated with a laser or optical cavity. -/
inductive CarbonIntegration
  | nLigWaveguide
  | carbonNanotubeWaveguide
  | rgoVitrimerMetasurface
  | carbonSaturableAbsorber
  deriving DecidableEq, Repr

/-- Parameters for a distributed or multilayer Bragg reflector. -/
structure BraggReflectorParameters where
  kind : BraggReflectorKind
  centerWavelength : Length
  centerWavelength_pos : 0 < centerWavelength.meters
  layerCount : ℕ
  layerCount_pos : 0 < layerCount
  highIndex : ℝ
  highIndex_nonnegative : 0 ≤ highIndex
  lowIndex : ℝ
  lowIndex_nonnegative : 0 ≤ lowIndex
  indexContrast : ℝ
  indexContrast_nonnegative : 0 ≤ indexContrast
  indexContrastLaw : indexContrast = highIndex - lowIndex
  reflectivity : ℝ
  reflectivity_nonnegative : 0 ≤ reflectivity
  reflectivity_le_one : reflectivity ≤ 1
  evidenceStatus : LaserEvidenceStatus

/-- Parameters for an optical-amplification stage or resonant repeater. -/
structure OpticalAmplificationParameters where
  kind : OpticalAmplificationKind
  pumpWavelength : Length
  pumpWavelength_pos : 0 < pumpWavelength.meters
  pumpPower : Power
  pumpPower_nonnegative : 0 ≤ pumpPower.watts
  gainDb : ℝ
  gainDb_nonnegative : 0 ≤ gainDb
  phaseMatchingCalibrated : Prop
  phaseMatchingCalibrated_hypothesis : phaseMatchingCalibrated
  reflector : Option BraggReflectorParameters
  evidenceStatus : LaserEvidenceStatus

/-- Process labels for pulsed shock and laser-peening work. -/
inductive ShockProcess
  | genericPulsedShock
  | laserCompressionShock
  | laserPeening
  deriving DecidableEq, Repr

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

/-- Parameters for a carbon-integrated laser or optical resonator platform. -/
structure IntegratedCarbonParameters extends CommonParameters where
  carbonComponent : CarbonIntegration
  signalWavelength : Length
  signalWavelength_pos : 0 < signalWavelength.meters
  pumpPower : Power
  pumpPower_nonnegative : 0 ≤ pumpPower.watts
  outputPower : Power
  outputPower_nonnegative : 0 ≤ outputPower.watts
  waveguideLength : Length
  waveguideLength_pos : 0 < waveguideLength.meters
  cavityQualityFactor : ℝ
  cavityQualityFactor_pos : 0 < cavityQualityFactor
  amplification : Option OpticalAmplificationParameters

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
  process : ShockProcess
  shockPressure : Pressure
  shockPressure_nonnegative : 0 ≤ shockPressure.pascals
  shockPressureThreshold : Pressure
  shockPressureThreshold_nonnegative : 0 ≤ shockPressureThreshold.pascals
  pressureThresholdLaw : shockPressureThreshold.pascals ≤ shockPressure.pascals

/-- The source family implied by a shock-process label. -/
def ShockParameters.kind (parameters : ShockParameters) : LaserKind :=
  match parameters.process with
  | ShockProcess.laserCompressionShock => LaserKind.laserCompressionShock
  | ShockProcess.laserPeening => LaserKind.laserCompressionShock
  | ShockProcess.genericPulsedShock => LaserKind.shockDrive

/-- A typed laser profile with source family, emission mode, and parameters. -/
inductive LaserProfile
  | continuousWave (kind : LaserKind) (parameters : ContinuousWaveParameters)
  | integratedCarbon (parameters : IntegratedCarbonParameters)
  | pulsed (kind : LaserKind) (mode : LaserMode) (parameters : PulsedParameters)
  | shock (parameters : ShockParameters)

/-- The source family associated with a profile. -/
def LaserProfile.kind : LaserProfile → LaserKind
  | LaserProfile.continuousWave kind _ => kind
  | LaserProfile.integratedCarbon _ => LaserKind.integratedCarbon
  | LaserProfile.pulsed kind _ _ => kind
  | LaserProfile.shock parameters => parameters.kind

/-- The emission regime associated with a profile. -/
def LaserProfile.mode : LaserProfile → LaserMode
  | LaserProfile.continuousWave _ _ => LaserMode.continuousWave
  | LaserProfile.integratedCarbon _ => LaserMode.continuousWave
  | LaserProfile.pulsed _ mode _ => mode
  | LaserProfile.shock _ => LaserMode.pulsedShock

/-- The wavelength associated with a profile. -/
def LaserProfile.wavelength : LaserProfile → Length
  | LaserProfile.continuousWave _ parameters => parameters.wavelength
  | LaserProfile.integratedCarbon parameters => parameters.wavelength
  | LaserProfile.pulsed _ _ parameters => parameters.wavelength
  | LaserProfile.shock parameters => parameters.wavelength

/-- The signal wavelength is exposed when a profile is carbon-integrated. -/
def LaserProfile.signalWavelength : LaserProfile → Option Length
  | LaserProfile.integratedCarbon parameters => some parameters.signalWavelength
  | _ => none

/-- The average optical power represented by a profile. -/
def LaserProfile.averagePower : LaserProfile → Power
  | LaserProfile.continuousWave _ parameters => parameters.averagePower
  | LaserProfile.integratedCarbon parameters => parameters.pumpPower
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
