import Signals.Propagation
import Signals.Units

namespace Signals.Antennas

open Signals.Propagation
open Signals.Units

/-- Measured material parameters for a lignin-vitrimer dielectric track.

The record does not assert that a particular bio-derived formulation has these
properties; each value is an experimental or separately justified input. -/
structure LigninVitrimerDielectric where
  relativePermittivity : ℝ
  relativePermittivity_pos : 0 < relativePermittivity
  lossTangent : ℝ
  lossTangent_nonnegative : 0 ≤ lossTangent
  tuningRange : ℝ
  tuningRange_nonnegative : 0 ≤ tuningRange
  moistureSensitivity : BoundedFactor

/-- A volume-distributed polarization-current source with finite support. -/
structure VolumeDistributedPolarizationCurrent where
  supportVolume : Volume
  supportVolume_pos : 0 < supportVolume.cubicMeters
  sourceCount : ℕ
  sourceCount_positive : 0 < sourceCount
  currentDensityAmplitude : PolarizationCurrentDensity
  currentDensityAmplitude_nonnegative :
    0 ≤ currentDensityAmplitude.amperesPerSquareMeter
  directionality : ℝ
  directionality_nonnegative : 0 ≤ directionality

/-- A directional broadband antenna driven by a distributed polarization current.

The phase-pattern speed is kept separate from group and information speeds.
This permits a superluminal phase or spot speed as a kinematic input without
encoding superluminal signal transmission. -/
structure DirectionalBroadbandAntenna where
  material : LigninVitrimerDielectric
  polarizationCurrent : VolumeDistributedPolarizationCurrent
  carrierFrequency : Frequency
  carrierFrequency_pos : 0 < carrierFrequency.hz
  bandwidth : Frequency
  bandwidth_pos : 0 < bandwidth.hz
  trackLength : Length
  trackLength_pos : 0 < trackLength.meters
  sweepDuration : Duration
  sweepDuration_pos : 0 < sweepDuration.seconds
  sweepSpeed : Speed
  sweepSpeedLaw : sweepSpeed.metersPerSecond =
    trackLength.meters / sweepDuration.seconds
  phasePatternSpeed : Speed
  phasePatternSpeed_pos : 0 < phasePatternSpeed.metersPerSecond
  groupSpeed : Speed
  groupSpeed_pos : 0 < groupSpeed.metersPerSecond
  groupSpeed_causal : groupSpeed.metersPerSecond ≤ vacuumSpeedOfLight
  informationSpeed : Speed
  informationSpeed_pos : 0 < informationSpeed.metersPerSecond
  informationSpeed_causal : informationSpeed.metersPerSecond ≤ vacuumSpeedOfLight
  inputPower : Power
  inputPower_nonnegative : 0 ≤ inputPower.watts
  radiatedPower : Power
  radiatedPower_nonnegative : 0 ≤ radiatedPower.watts
  radiationEfficiency : BoundedFactor
  radiatedPowerLaw : radiatedPower.watts =
    inputPower.watts * radiationEfficiency.value

/-- A phase pattern or laser spot is superluminal relative to vacuum light speed. -/
def DirectionalBroadbandAntenna.phasePatternSuperluminal
    (antenna : DirectionalBroadbandAntenna) : Prop :=
  vacuumSpeedOfLight < antenna.phasePatternSpeed.metersPerSecond

/-- The track sweep speed follows its measured length and duration. -/
lemma DirectionalBroadbandAntenna.sweep_speed_holds
    (antenna : DirectionalBroadbandAntenna) :
    antenna.sweepSpeed.metersPerSecond =
      antenna.trackLength.meters / antenna.sweepDuration.seconds :=
  antenna.sweepSpeedLaw

/-- The information speed remains within the supplied causal envelope. -/
lemma DirectionalBroadbandAntenna.information_speed_causal
    (antenna : DirectionalBroadbandAntenna) :
    antenna.informationSpeed.metersPerSecond ≤ vacuumSpeedOfLight :=
  antenna.informationSpeed_causal

/-- A passive directional broadband antenna cannot radiate more power than it
receives. -/
lemma DirectionalBroadbandAntenna.radiated_power_le_input
    (antenna : DirectionalBroadbandAntenna) :
    antenna.radiatedPower.watts ≤ antenna.inputPower.watts := by
  rw [antenna.radiatedPowerLaw]
  simpa [mul_one] using
    (mul_le_mul_of_nonneg_left antenna.radiationEfficiency.le_one
      antenna.inputPower_nonnegative)

/-- The field-orientation label of a resonator mode.

The longitudinal label describes a field component in the modeled structure;
it does not mean that the mode is a massive Proca excitation. -/
inductive ResonatorMode
  | transverse
  | longitudinal
  deriving DecidableEq, Repr

/-- Application classes identified in the CW research notes. -/
inductive CWApplication
  | oceanMetrology
  | waveguideTransport
  | pclpNanolithography
  | mimoAcousticMixing
  | antiFireSuppression
  | frcFusion
  | topologicalThruster
  | argonPowerPlant
  | wirelessPower
  | deepSpaceCommunications
  deriving DecidableEq, Repr

/-- Controls that a CW application may require beyond a carrier alone. -/
structure CWApplicationRequirements where
  phaseReference : Bool
  activeMask : Bool
  convergentBeams : Bool
  rangeModulation : Bool
  massiveModeHypothesis : Bool

/-- The control requirements implied by each application class in the source
chat. These flags classify proposed architectures; they do not validate them. -/
def CWApplication.requirements : CWApplication → CWApplicationRequirements
  | CWApplication.oceanMetrology =>
      { phaseReference := true
        activeMask := false
        convergentBeams := false
        rangeModulation := true
        massiveModeHypothesis := false }
  | CWApplication.waveguideTransport =>
      { phaseReference := false
        activeMask := false
        convergentBeams := false
        rangeModulation := false
        massiveModeHypothesis := false }
  | CWApplication.pclpNanolithography =>
      { phaseReference := false
        activeMask := true
        convergentBeams := false
        rangeModulation := false
        massiveModeHypothesis := true }
  | CWApplication.mimoAcousticMixing =>
      { phaseReference := false
        activeMask := true
        convergentBeams := true
        rangeModulation := false
        massiveModeHypothesis := true }
  | CWApplication.antiFireSuppression =>
      { phaseReference := false
        activeMask := true
        convergentBeams := false
        rangeModulation := false
        massiveModeHypothesis := true }
  | CWApplication.frcFusion =>
      { phaseReference := false
        activeMask := true
        convergentBeams := true
        rangeModulation := false
        massiveModeHypothesis := true }
  | CWApplication.topologicalThruster =>
      { phaseReference := false
        activeMask := true
        convergentBeams := false
        rangeModulation := false
        massiveModeHypothesis := true }
  | CWApplication.argonPowerPlant =>
      { phaseReference := false
        activeMask := true
        convergentBeams := false
        rangeModulation := false
        massiveModeHypothesis := true }
  | CWApplication.wirelessPower =>
      { phaseReference := false
        activeMask := true
        convergentBeams := false
        rangeModulation := false
        massiveModeHypothesis := true }
  | CWApplication.deepSpaceCommunications =>
      { phaseReference := true
        activeMask := false
        convergentBeams := false
        rangeModulation := false
        massiveModeHypothesis := true }

/-- An active rGO-vitrimer mask with finite programmable phase/amplitude range. -/
structure RGOVitrimerActiveMask where
  elementCount : ℕ
  elementCount_positive : 0 < elementCount
  phaseModulationRange : ℝ
  phaseModulationRange_nonnegative : 0 ≤ phaseModulationRange
  amplitudeModulationRange : ℝ
  amplitudeModulationRange_nonnegative : 0 ≤ amplitudeModulationRange
  controlPower : Power
  controlPower_nonnegative : 0 ≤ controlPower.watts

/-- Two or more coherent CW beams with a declared intersection region. -/
structure ConvergentCWBeams where
  beamCount : ℕ
  beamCount_at_least_two : 2 ≤ beamCount
  driveFrequency : Frequency
  driveFrequency_pos : 0 < driveFrequency.hz
  intersectionArea : Area
  intersectionArea_pos : 0 < intersectionArea.squareMeters
  phaseAlignment : BoundedFactor

/-- A continuous-wave resonator with measured enhancement and power loss. -/
structure ContinuousWaveResonator where
  mode : ResonatorMode
  resonantFrequency : Frequency
  resonantFrequency_pos : 0 < resonantFrequency.hz
  driveFrequency : Frequency
  driveFrequency_pos : 0 < driveFrequency.hz
  resonanceMatch : driveFrequency.hz = resonantFrequency.hz
  drivePower : Power
  drivePower_nonnegative : 0 ≤ drivePower.watts
  intracavityPower : Power
  intracavityPower_nonnegative : 0 ≤ intracavityPower.watts
  enhancementFactor : ℝ
  enhancementFactor_ge_one : 1 ≤ enhancementFactor
  intracavityPowerLaw : intracavityPower.watts =
    drivePower.watts * enhancementFactor
  emittedPower : Power
  emittedPower_nonnegative : 0 ≤ emittedPower.watts
  dissipatedPower : Power
  dissipatedPower_nonnegative : 0 ≤ dissipatedPower.watts
  passivePowerBalance : emittedPower.watts + dissipatedPower.watts =
    drivePower.watts

/-- A resonator is continuously driven when its CW drive power is positive. -/
def ContinuousWaveResonator.isDriven
    (resonator : ContinuousWaveResonator) : Prop :=
  0 < resonator.drivePower.watts

/-- The resonator's drive and resonance frequencies match. -/
lemma ContinuousWaveResonator.resonance_match
    (resonator : ContinuousWaveResonator) :
    resonator.driveFrequency.hz = resonator.resonantFrequency.hz :=
  resonator.resonanceMatch

/-- Intracavity enhancement is no smaller than drive power under the supplied
enhancement model. -/
lemma ContinuousWaveResonator.drive_power_le_intracavity
    (resonator : ContinuousWaveResonator) :
    resonator.drivePower.watts ≤ resonator.intracavityPower.watts := by
  rw [resonator.intracavityPowerLaw]
  nlinarith [resonator.drivePower_nonnegative,
    resonator.enhancementFactor_ge_one]

/-- Passive resonator output cannot exceed its supplied drive power. -/
lemma ContinuousWaveResonator.emitted_power_le_drive
    (resonator : ContinuousWaveResonator) :
    resonator.emittedPower.watts ≤ resonator.drivePower.watts := by
  linarith [resonator.passivePowerBalance,
    resonator.dissipatedPower_nonnegative]

/-- Readiness data for a CW application, with explicit mask/beam requirements.

This is a testable interface contract. It does not establish that the stated
application works or that a CW resonator emits a massive longitudinal mode. -/
structure CWApplicationReadiness where
  application : CWApplication
  resonator : ContinuousWaveResonator
  activeMask : Option RGOVitrimerActiveMask
  convergentBeams : Option ConvergentCWBeams
  rangeModulationEnabled : Bool
  informationSpeed : Speed
  informationSpeed_pos : 0 < informationSpeed.metersPerSecond
  informationSpeed_causal : informationSpeed.metersPerSecond ≤ vacuumSpeedOfLight
  activeMaskRequirement :
    application.requirements.activeMask = false ∨ activeMask.isSome = true
  convergentBeamRequirement :
    application.requirements.convergentBeams = false ∨ convergentBeams.isSome = true
  rangeModulationRequirement :
    application.requirements.rangeModulation = false ∨ rangeModulationEnabled = true
  cwDriven : resonator.isDriven

/-- A ready application exposes its causal information-speed bound. -/
lemma CWApplicationReadiness.information_speed_causal
    (readiness : CWApplicationReadiness) :
    readiness.informationSpeed.metersPerSecond ≤ vacuumSpeedOfLight :=
  readiness.informationSpeed_causal

/-- The active-mask requirement is an explicit readiness condition. -/
lemma CWApplicationReadiness.active_mask_requirement
    (readiness : CWApplicationReadiness) :
    readiness.application.requirements.activeMask = false ∨
      readiness.activeMask.isSome = true :=
  readiness.activeMaskRequirement

/-- The convergent-beam requirement is an explicit readiness condition. -/
lemma CWApplicationReadiness.convergent_beam_requirement
    (readiness : CWApplicationReadiness) :
    readiness.application.requirements.convergentBeams = false ∨
      readiness.convergentBeams.isSome = true :=
  readiness.convergentBeamRequirement

/-- A Rydberg-EIT field observation with a calibrated quadratic Stark response. -/
structure RydbergEITReceiver where
  probeFrequency : Frequency
  probeFrequency_pos : 0 < probeFrequency.hz
  couplingFrequency : Frequency
  couplingFrequency_pos : 0 < couplingFrequency.hz
  fieldAmplitude : ElectricFieldAmplitude
  fieldAmplitude_nonnegative : 0 ≤ fieldAmplitude.voltsPerMeter
  starkCoefficient : ℝ
  starkCoefficient_nonnegative : 0 ≤ starkCoefficient
  starkShift : ℝ
  starkShiftLaw : starkShift =
    starkCoefficient * fieldAmplitude.voltsPerMeter ^ 2

/-- The calibrated Stark shift is nonnegative for a nonnegative coefficient. -/
lemma RydbergEITReceiver.stark_shift_nonnegative
    (receiver : RydbergEITReceiver) :
    0 ≤ receiver.starkShift := by
  rw [receiver.starkShiftLaw]
  exact mul_nonneg receiver.starkCoefficient_nonnegative (sq_nonneg _)

end Signals.Antennas
