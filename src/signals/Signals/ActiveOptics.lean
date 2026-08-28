import Mathlib.Data.Real.Basic
import Mathlib.Tactic
import Signals.Propagation
import Signals.Units

namespace Signals.Pending

open Signals.Propagation
open Signals.Units

/-! # Active optical and plasmonic models

These finite records extract the active-gain and surface-plasmon models from
Dean et al., Zhang et al., and Lei et al. They keep pump power, loss, phase
matching, and simulation status explicit. A gain record is not a claim of
free energy or passive amplification.
-/

/-- A second-harmonic frequency relation with an explicitly matched resonance. -/
structure SecondHarmonicResonance where
  fundamentalFrequency : Frequency
  fundamentalFrequency_pos : 0 < fundamentalFrequency.hz
  secondHarmonicFrequency : Frequency
  secondHarmonicFrequency_pos : 0 < secondHarmonicFrequency.hz
  resonantFrequency : Frequency
  resonantFrequency_pos : 0 < resonantFrequency.hz
  secondHarmonicLaw : secondHarmonicFrequency.hz =
    2 * fundamentalFrequency.hz
  resonanceLaw : resonantFrequency.hz = secondHarmonicFrequency.hz

/-- An active optical amplifier with explicit signal, pump, output, and loss
power accounting. -/
structure ActiveOpticalAmplifier where
  signalInputPower : Power
  signalInputPower_nonnegative : 0 ≤ signalInputPower.watts
  pumpPower : Power
  pumpPower_nonnegative : 0 ≤ pumpPower.watts
  signalOutputPower : Power
  signalOutputPower_nonnegative : 0 ≤ signalOutputPower.watts
  dissipatedPower : Power
  dissipatedPower_nonnegative : 0 ≤ dissipatedPower.watts
  linearGain : ℝ
  linearGain_nonnegative : 0 ≤ linearGain
  gainLaw : signalOutputPower.watts =
    linearGain * signalInputPower.watts
  powerBalance : signalOutputPower.watts + dissipatedPower.watts =
    signalInputPower.watts + pumpPower.watts

/-- An active amplifier cannot output more signal power than signal plus pump
power under its explicit balance law. -/
lemma ActiveOpticalAmplifier.output_le_input_and_pump
    (amplifier : ActiveOpticalAmplifier) :
    amplifier.signalOutputPower.watts ≤
      amplifier.signalInputPower.watts + amplifier.pumpPower.watts := by
  linarith [amplifier.powerBalance, amplifier.dissipatedPower_nonnegative]

/-- Positive signal input and output above input imply linear gain above one. -/
lemma ActiveOpticalAmplifier.gain_gt_one
    (amplifier : ActiveOpticalAmplifier)
    (signalInput_pos : 0 < amplifier.signalInputPower.watts)
    (output_gt_input : amplifier.signalInputPower.watts <
      amplifier.signalOutputPower.watts) :
    1 < amplifier.linearGain := by
  rw [amplifier.gainLaw] at output_gt_input
  exact (lt_mul_iff_one_lt_left signalInput_pos).mp output_gt_input

/-- The integrated thin-film lithium-niobate OPA model reported by Dean et al. -/
structure LowPowerIntegratedOPA where
  resonance : SecondHarmonicResonance
  amplifier : ActiveOpticalAmplifier
  reportedGainDecibels : ℝ
  reportedGainDecibels_min : 17 ≤ reportedGainDecibels
  bandwidthHz : ℝ
  bandwidth_nonnegative : 0 ≤ bandwidthHz
  inputPowerLimitWatts : ℝ
  inputPowerLimit_pos : 0 < inputPowerLimitWatts
  inputPowerBelowLimit : amplifier.pumpPower.watts < inputPowerLimitWatts

/-- The experimentally reported input-power limit is represented as a positive
bound supplied by the OPA observation. -/
lemma LowPowerIntegratedOPA.input_power_below_limit
    (observation : LowPowerIntegratedOPA) :
    observation.amplifier.pumpPower.watts < observation.inputPowerLimitWatts :=
  observation.inputPowerBelowLimit

/-- A free-electron-pumped surface-plasmon-polariton amplifier. -/
structure SPPFreeElectronAmplifier where
  inputPower : Power
  inputPower_nonnegative : 0 ≤ inputPower.watts
  electronPumpPower : Power
  electronPumpPower_nonnegative : 0 ≤ electronPumpPower.watts
  outputPower : Power
  outputPower_nonnegative : 0 ≤ outputPower.watts
  lossPower : Power
  lossPower_nonnegative : 0 ≤ lossPower.watts
  linearGain : ℝ
  linearGain_nonnegative : 0 ≤ linearGain
  gainLaw : outputPower.watts = linearGain * inputPower.watts
  powerBalance : outputPower.watts + lossPower.watts =
    inputPower.watts + electronPumpPower.watts
  initialFrequency : Frequency
  initialFrequency_pos : 0 < initialFrequency.hz
  finalFrequency : Frequency
  finalFrequency_pos : 0 < finalFrequency.hz
  interactionLength : Length
  interactionLength_pos : 0 < interactionLength.meters
  twofoldRedshiftLaw : finalFrequency.hz = initialFrequency.hz / 2
  phaseAlignment : BoundedFactor

/-- Free-electron pumping supplies the active amplifier's output and loss
budget; output cannot exceed signal plus electron-pump input. -/
lemma SPPFreeElectronAmplifier.output_le_total_input
    (amplifier : SPPFreeElectronAmplifier) :
    amplifier.outputPower.watts ≤
      amplifier.inputPower.watts + amplifier.electronPumpPower.watts := by
  linarith [amplifier.powerBalance, amplifier.lossPower_nonnegative]

/-- A twofold redshift is exposed as the supplied frequency relation. -/
lemma SPPFreeElectronAmplifier.twofold_redshift
    (amplifier : SPPFreeElectronAmplifier) :
    amplifier.finalFrequency.hz = amplifier.initialFrequency.hz / 2 :=
  amplifier.twofoldRedshiftLaw

/-- Cylindrical SPP excitation data with explicit axial and azimuthal phase
matching. -/
structure CylindricalSPPMode where
  laserWaveNumber : ℝ
  laserWaveNumber_nonnegative : 0 ≤ laserWaveNumber
  sppWaveNumber : ℝ
  sppWaveNumber_nonnegative : 0 ≤ sppWaveNumber
  laserAzimuthalIndex : ℤ
  sppAzimuthalIndex : ℤ
  phaseMatching : laserWaveNumber = sppWaveNumber
  azimuthalMatching : laserAzimuthalIndex = sppAzimuthalIndex
  overlapEfficiency : BoundedFactor
  electronDensity : ℝ
  electronDensity_pos : 0 < electronDensity
  criticalDensity : ℝ
  criticalDensity_pos : 0 < criticalDensity
  nearCriticalRatio : ℝ
  nearCriticalRatioLaw : nearCriticalRatio =
    electronDensity / criticalDensity

/-- The cylindrical SPP mode exposes its phase-matching condition. -/
lemma CylindricalSPPMode.phase_matching_holds
    (mode : CylindricalSPPMode) :
    mode.laserWaveNumber = mode.sppWaveNumber :=
  mode.phaseMatching

/-- The cylindrical SPP mode exposes its azimuthal selection rule. -/
lemma CylindricalSPPMode.azimuthal_matching_holds
    (mode : CylindricalSPPMode) :
    mode.laserAzimuthalIndex = mode.sppAzimuthalIndex :=
  mode.azimuthalMatching

/-- A finite coherent-radiation model comparing coherent and incoherent sums.
The field-amplitude model scales as $N^2$ while the incoherent intensity scales
as $N$. -/
structure CoherentRadiationScaling where
  electronCount : ℝ
  electronCount_ge_one : 1 ≤ electronCount
  singleElectronIntensity : ℝ
  singleElectronIntensity_nonnegative : 0 ≤ singleElectronIntensity
  coherentIntensity : ℝ
  coherentIntensity_nonnegative : 0 ≤ coherentIntensity
  incoherentIntensity : ℝ
  incoherentIntensity_nonnegative : 0 ≤ incoherentIntensity
  coherentLaw : coherentIntensity =
    electronCount ^ 2 * singleElectronIntensity
  incoherentLaw : incoherentIntensity =
    electronCount * singleElectronIntensity

/-- Coherent radiation is no weaker than the incoherent sum when at least one
phase-aligned electron contributes. -/
lemma CoherentRadiationScaling.incoherent_le_coherent
    (scaling : CoherentRadiationScaling) :
    scaling.incoherentIntensity ≤ scaling.coherentIntensity := by
  rw [scaling.coherentLaw, scaling.incoherentLaw]
  have count_nonnegative : 0 ≤ scaling.electronCount :=
    le_trans (by norm_num) scaling.electronCount_ge_one
  have count_difference_nonnegative :
      0 ≤ scaling.electronCount ^ 2 - scaling.electronCount := by
    have factor_nonnegative :
        0 ≤ scaling.electronCount * (scaling.electronCount - 1) :=
      mul_nonneg count_nonnegative
        (sub_nonneg.mpr scaling.electronCount_ge_one)
    nlinarith
  nlinarith [mul_nonneg count_difference_nonnegative
    scaling.singleElectronIntensity_nonnegative]

/-- A Vavilov-Cherenkov angle relation for a normalized rotating electron
modulation. It is a supplied kinematic condition, not a causality claim. -/
structure CherenkovAngleModel where
  rotationFrequency : ℝ
  rotationFrequency_pos : 0 < rotationFrequency
  modulationFrequency : ℝ
  modulationFrequency_pos : 0 < modulationFrequency
  angleCosine : ℝ
  angleCosineLaw : angleCosine =
    1 - rotationFrequency / modulationFrequency

/-- The angle model exposes its supplied cosine relation. -/
lemma CherenkovAngleModel.angle_cosine_holds
    (model : CherenkovAngleModel) :
    model.angleCosine =
      1 - model.rotationFrequency / model.modulationFrequency :=
  model.angleCosineLaw

end Signals.Pending
