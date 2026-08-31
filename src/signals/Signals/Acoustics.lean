import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Data.Real.Basic
import Mathlib.Tactic
import Signals.Contracts
import Signals.Propagation

namespace Signals.Acoustics

open Signals.Propagation
open Signals.Contracts

/-- Homogeneous acoustic-medium parameters in normalized SI-style units. -/
structure Medium where
  density : ℝ
  density_pos : 0 < density
  soundSpeed : ℝ
  soundSpeed_pos : 0 < soundSpeed
  attenuationPerLength : ℝ
  attenuation_nonnegative : 0 ≤ attenuationPerLength

/-- Plane-wave acoustic impedance derived from density and sound speed. -/
def Medium.impedance (medium : Medium) : ℝ :=
  medium.density * medium.soundSpeed

/-- Acoustic impedance is positive for a positive-density medium. -/
lemma Medium.impedance_pos (medium : Medium) :
    0 < medium.impedance := by
  unfold Medium.impedance
  exact mul_pos medium.density_pos medium.soundSpeed_pos

/-- A finite-frequency acoustic wave used for transfer experiments. -/
structure Wave where
  frequencyHz : ℝ
  frequency_positive : 0 < frequencyHz
  pressureAmplitude : ℝ
  pressureAmplitude_nonnegative : 0 ≤ pressureAmplitude
  medium : Medium

/-- Plane-wave acoustic intensity from RMS pressure and acoustic impedance. -/
noncomputable def Wave.intensity (wave : Wave) : ℝ :=
  wave.pressureAmplitude ^ 2 / wave.medium.impedance

/-- Acoustic intensity is nonnegative. -/
lemma Wave.intensity_nonnegative (wave : Wave) :
    0 ≤ wave.intensity := by
  unfold Wave.intensity
  exact div_nonneg (sq_nonneg _) (wave.medium.impedance_pos.le)

/-- A transfer experiment for an ultrasonic wave.

The electromagnetic or mechanical source is represented by the existing
passive `LinkBudget`; transmitter and receiver conversion efficiencies are
additional measured factors. -/
structure UltrasonicTransfer where
  wave : Wave
  ultrasonicFrequency : 20000 < wave.frequencyHz
  link : LinkBudget
  apertureArea : ℝ
  apertureArea_pos : 0 < apertureArea
  transmitterEfficiency : BoundedFactor
  receiverEfficiency : BoundedFactor
  sourcePowerLaw : link.sourcePower.watts = wave.intensity * apertureArea

/-- Incident acoustic power through the modeled transducer aperture. -/
noncomputable def UltrasonicTransfer.incidentPower
    (transfer : UltrasonicTransfer) : ℝ :=
  transfer.wave.intensity * transfer.apertureArea

/-- Incident acoustic power is nonnegative. -/
lemma UltrasonicTransfer.incidentPower_nonnegative
    (transfer : UltrasonicTransfer) :
    0 ≤ transfer.incidentPower := by
  unfold UltrasonicTransfer.incidentPower
  exact mul_nonneg transfer.wave.intensity_nonnegative transfer.apertureArea_pos.le

/-- Power delivered to the receiver after acoustic transduction. -/
noncomputable def UltrasonicTransfer.receivedPower
    (transfer : UltrasonicTransfer) : ℝ :=
  transfer.link.receivedPower * transfer.transmitterEfficiency.value *
    transfer.receiverEfficiency.value

/-- Acoustic transfer power is nonnegative. -/
lemma UltrasonicTransfer.receivedPower_nonnegative
    (transfer : UltrasonicTransfer) :
    0 ≤ transfer.receivedPower := by
  unfold UltrasonicTransfer.receivedPower
  exact mul_nonneg
    (mul_nonneg transfer.link.receivedPower_nonnegative
      transfer.transmitterEfficiency.nonnegative)
    transfer.receiverEfficiency.nonnegative

/-- Passive acoustic transduction cannot deliver more than link-received power. -/
lemma UltrasonicTransfer.receivedPower_le_linkPower
    (transfer : UltrasonicTransfer) :
    transfer.receivedPower ≤ transfer.link.receivedPower := by
  unfold UltrasonicTransfer.receivedPower
  have transmitter_step : transfer.link.receivedPower *
      transfer.transmitterEfficiency.value ≤ transfer.link.receivedPower := by
    calc
      transfer.link.receivedPower * transfer.transmitterEfficiency.value ≤
          transfer.link.receivedPower * 1 :=
        mul_le_mul_of_nonneg_left transfer.transmitterEfficiency.le_one
          transfer.link.receivedPower_nonnegative
      _ = transfer.link.receivedPower := by ring
  calc
    transfer.link.receivedPower * transfer.transmitterEfficiency.value *
        transfer.receiverEfficiency.value ≤
        transfer.link.receivedPower * transfer.receiverEfficiency.value :=
      mul_le_mul_of_nonneg_right transmitter_step transfer.receiverEfficiency.nonnegative
    _ ≤ transfer.link.receivedPower * 1 :=
      mul_le_mul_of_nonneg_left transfer.receiverEfficiency.le_one
        transfer.link.receivedPower_nonnegative
    _ = transfer.link.receivedPower := by ring

/-- Passive acoustic transfer cannot deliver more power than its source. -/
lemma UltrasonicTransfer.receivedPower_le_sourcePower
    (transfer : UltrasonicTransfer) :
  transfer.receivedPower ≤ transfer.link.sourcePower.watts := by
  exact le_trans transfer.receivedPower_le_linkPower
    transfer.link.receivedPower_le_sourcePower

/-- Passive acoustic transfer cannot deliver more power than incident power. -/
lemma UltrasonicTransfer.receivedPower_le_incidentPower
    (transfer : UltrasonicTransfer) :
    transfer.receivedPower ≤ transfer.incidentPower := by
  unfold UltrasonicTransfer.incidentPower
  rw [← transfer.sourcePowerLaw]
  exact transfer.receivedPower_le_sourcePower

/-- An observed acoustic-transfer result with a stated model residual. -/
structure TransferMeasurement where
  predictedPower : ℝ
  observedPower : ℝ
  tolerance : ℝ
  tolerance_nonnegative : 0 ≤ tolerance
  residual : ℝ
  residualLaw : residual = observedPower - predictedPower

/-- A measurement is consistent with its transfer model within tolerance. -/
def TransferMeasurement.consistent (measurement : TransferMeasurement) : Prop :=
  |measurement.residual| ≤ measurement.tolerance

/-- The consistency predicate unfolds to the stated residual bound. -/
lemma TransferMeasurement.consistent_iff (measurement : TransferMeasurement) :
    measurement.consistent ↔ |measurement.residual| ≤ measurement.tolerance := by
  rfl

/-- Adapt an acoustic residual to the shared measurement contract. -/
def TransferMeasurement.toResidualContract (measurement : TransferMeasurement)
  (consistent : measurement.consistent) :
    ResidualContract ℝ ℝ ℝ :=
  { measured := measurement.observedPower
    predicted := measurement.predictedPower
    residual := measurement.residual
    residualFunction := fun observed predicted => observed - predicted
    residualLaw := measurement.residualLaw
    magnitude := abs
    magnitude_nonnegative := abs_nonneg _
    tolerance := measurement.tolerance
    tolerance_nonnegative := measurement.tolerance_nonnegative
    withinTolerance := by
      exact measurement.consistent_iff.mp consistent }

end Signals.Acoustics
