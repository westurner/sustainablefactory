import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Basic.Complex.Basic
import Mathlib.Basic.Real.Basic
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

/-- A normalized one-dimensional acoustic two-port transfer matrix.

The state convention is pressure and particle velocity. The entries are
measured or supplied by a calibrated acoustic solver; this record does not
derive them from an assumed DDF constitutive law. -/
structure AcousticTransferMatrix where
  a : ℂ
  b : ℂ
  c : ℂ
  d : ℂ

/-- Identity transfer matrix for a zero-length acoustic path. -/
def AcousticTransferMatrix.identity : AcousticTransferMatrix :=
  { a := 1, b := 0, c := 0, d := 1 }

/-- Cascade two acoustic two-port matrices in physical path order. -/
def AcousticTransferMatrix.cascade
    (left right : AcousticTransferMatrix) : AcousticTransferMatrix :=
  { a := left.a * right.a + left.b * right.c
    b := left.a * right.b + left.b * right.d
    c := left.c * right.a + left.d * right.c
    d := left.c * right.b + left.d * right.d }

/-- The pressure/velocity transmission denominator for real source and load
impedances. -/
def AcousticTransferMatrix.transmissionDenominator
    (matrix : AcousticTransferMatrix) (sourceImpedance loadImpedance : ℝ) : ℂ :=
  matrix.a * (loadImpedance : ℂ) + matrix.b +
    matrix.c * ((sourceImpedance * loadImpedance : ℝ) : ℂ) +
      matrix.d * (sourceImpedance : ℂ)

/-- Power transmission for a calibrated acoustic two-port between real ports.

This standard transfer-matrix relation preserves phase and layer ordering,
unlike an averaged-permittivity or scalar mixture estimate. -/
noncomputable def AcousticTransferMatrix.powerTransmission
    (matrix : AcousticTransferMatrix) (sourceImpedance loadImpedance : ℝ) : ℝ :=
  (4 * sourceImpedance * loadImpedance) /
    Complex.normSq (matrix.transmissionDenominator sourceImpedance loadImpedance)

/-- A material layer with explicit acoustics and its supplied two-port fit. -/
structure AcousticPathLayer where
  materialReference : String
  materialReference_nonempty : materialReference ≠ ""
  medium : Medium
  thickness : Signals.Units.Length
  thickness_positive : 0 < thickness.meters
  transferMatrix : AcousticTransferMatrix
  transferResidual : ℝ
  transferResidual_nonnegative : 0 ≤ transferResidual
  transferTolerance : ℝ
  transferTolerance_nonnegative : 0 ≤ transferTolerance
  transferWithinTolerance : transferResidual ≤ transferTolerance

/-- A boundary between acoustic layers, with power partition and a supplied
phase-aware two-port fit. -/
structure AcousticPathInterface where
  interfaceReference : String
  interfaceReference_nonempty : interfaceReference ≠ ""
  response : InterfaceResponse
  transferMatrix : AcousticTransferMatrix
  transferResidual : ℝ
  transferResidual_nonnegative : 0 ≤ transferResidual
  transferTolerance : ℝ
  transferTolerance_nonnegative : 0 ≤ transferTolerance
  transferWithinTolerance : transferResidual ≤ transferTolerance

/-- Compose the entrance boundary, then each layer and its exit boundary.

For `N` layers, a valid path supplies `N + 1` interfaces. The fallback cases
make this helper total; `LayeredAcousticPath.interface_count` selects the
physical case. -/
def AcousticTransferMatrix.orderedCascade
    : List AcousticPathLayer → List AcousticPathInterface → AcousticTransferMatrix
  | [], [last] => last.transferMatrix
  | layer :: layers, interface :: interfaces =>
      interface.transferMatrix.cascade
        (layer.transferMatrix.cascade (orderedCascade layers interfaces))
  | _, _ => AcousticTransferMatrix.identity
termination_by layers _ => layers.length

/-- A frequency-specific acoustic path through an ordered stack.

Each layer retains its own material properties, thickness, and transfer fit;
each interface retains reflection/absorption/transmission and phase-aware fit.
The path-level transfer is the ordered cascade, not an arithmetic average. -/
structure LayeredAcousticPath where
  frequency : Signals.Units.Frequency
  frequency_positive : 0 < frequency.hz
  sourceImpedance : ℝ
  sourceImpedance_positive : 0 < sourceImpedance
  loadImpedance : ℝ
  loadImpedance_positive : 0 < loadImpedance
  layers : List AcousticPathLayer
  layers_nonempty : layers ≠ []
  interfaces : List AcousticPathInterface
  interface_count : interfaces.length = layers.length + 1
  transferMatrix : AcousticTransferMatrix
  transferMatrixLaw : transferMatrix =
    AcousticTransferMatrix.orderedCascade layers interfaces
  transferDenominator_nonzero :
    AcousticTransferMatrix.transmissionDenominator transferMatrix
      sourceImpedance loadImpedance ≠ 0
  powerTransmission : BoundedFactor
  powerTransmissionLaw : powerTransmission.value =
    AcousticTransferMatrix.powerTransmission transferMatrix
      sourceImpedance loadImpedance
  phaseDelay : Signals.Units.Duration
  phaseDelay_nonnegative : 0 ≤ phaseDelay.seconds
  calibrationResidual : ℝ
  calibrationResidual_nonnegative : 0 ≤ calibrationResidual
  calibrationTolerance : ℝ
  calibrationTolerance_nonnegative : 0 ≤ calibrationTolerance
  calibrationWithinTolerance : calibrationResidual ≤ calibrationTolerance
  artifactReference : String

/-- Static material identity and thickness, excluding state-conditioned acoustic
properties and transfer fits. -/
def AcousticPathLayer.stackDescriptor (layer : AcousticPathLayer) : String × ℝ :=
  (layer.materialReference, layer.thickness.meters)

/-- Static interface identity, excluding its state-conditioned response fit. -/
def AcousticPathInterface.stackDescriptor (interface : AcousticPathInterface) : String :=
  interface.interfaceReference

/-- Check the fixed physical stack and port impedances while allowing acoustic
properties and measured transfer matrices to vary with material state. -/
def LayeredAcousticPath.sameStackGeometry
    (left right : LayeredAcousticPath) : Prop :=
  left.layers.map AcousticPathLayer.stackDescriptor =
      right.layers.map AcousticPathLayer.stackDescriptor ∧
    left.interfaces.map AcousticPathInterface.stackDescriptor =
      right.interfaces.map AcousticPathInterface.stackDescriptor ∧
    left.sourceImpedance = right.sourceImpedance ∧
    left.loadImpedance = right.loadImpedance

/-- Total physical thickness of an ordered acoustic path. -/
def LayeredAcousticPath.totalThickness (path : LayeredAcousticPath) : ℝ :=
  path.layers.foldl (fun total layer => total + layer.thickness.meters) 0

/-- End-to-end ultrasonic power transfer with explicit transmitter, path, and
receiver energy partitions. -/
structure LayeredUltrasonicTransfer where
  path : LayeredAcousticPath
  electricalInputPower : Signals.Units.Power
  electricalInput_nonnegative : 0 ≤ electricalInputPower.watts
  transmitterEfficiency : BoundedFactor
  acousticLaunchPower : Signals.Units.Power
  acousticLaunchPower_nonnegative : 0 ≤ acousticLaunchPower.watts
  transmitterLossPower : Signals.Units.Power
  transmitterLossPower_nonnegative : 0 ≤ transmitterLossPower.watts
  transmitterConversionLaw : acousticLaunchPower.watts =
    transmitterEfficiency.value * electricalInputPower.watts
  transmitterEnergyBalance : electricalInputPower.watts =
    acousticLaunchPower.watts + transmitterLossPower.watts
  auxiliaryPathInputPower : Signals.Units.Power
  auxiliaryPathInputPower_nonnegative : 0 ≤ auxiliaryPathInputPower.watts
  acousticReceivedPower : Signals.Units.Power
  acousticReceivedPower_nonnegative : 0 ≤ acousticReceivedPower.watts
  reflectedPower : Signals.Units.Power
  reflectedPower_nonnegative : 0 ≤ reflectedPower.watts
  absorbedPower : Signals.Units.Power
  absorbedPower_nonnegative : 0 ≤ absorbedPower.watts
  distributedLossPower : Signals.Units.Power
  distributedLossPower_nonnegative : 0 ≤ distributedLossPower.watts
  pathTransmissionLaw : acousticReceivedPower.watts =
    path.powerTransmission.value *
      (acousticLaunchPower.watts + auxiliaryPathInputPower.watts)
  pathEnergyBalance : acousticLaunchPower.watts + auxiliaryPathInputPower.watts =
    acousticReceivedPower.watts + reflectedPower.watts +
      absorbedPower.watts + distributedLossPower.watts
  receiverEfficiency : BoundedFactor
  deliveredElectricalPower : Signals.Units.Power
  deliveredElectricalPower_nonnegative : 0 ≤ deliveredElectricalPower.watts
  receiverLossPower : Signals.Units.Power
  receiverLossPower_nonnegative : 0 ≤ receiverLossPower.watts
  receiverConversionLaw : deliveredElectricalPower.watts =
    receiverEfficiency.value * acousticReceivedPower.watts
  receiverEnergyBalance : acousticReceivedPower.watts =
    deliveredElectricalPower.watts + receiverLossPower.watts

/-- The layered UPT ledger closes across conversion, path, and receiver losses. -/
lemma LayeredUltrasonicTransfer.energy_balance
    (transfer : LayeredUltrasonicTransfer) :
    transfer.electricalInputPower.watts + transfer.auxiliaryPathInputPower.watts =
      transfer.deliveredElectricalPower.watts + transfer.transmitterLossPower.watts +
        transfer.reflectedPower.watts + transfer.absorbedPower.watts +
          transfer.distributedLossPower.watts + transfer.receiverLossPower.watts := by
  calc
    transfer.electricalInputPower.watts + transfer.auxiliaryPathInputPower.watts =
        transfer.acousticLaunchPower.watts + transfer.transmitterLossPower.watts +
          transfer.auxiliaryPathInputPower.watts := by rw [transfer.transmitterEnergyBalance]
    _ = transfer.acousticLaunchPower.watts + transfer.auxiliaryPathInputPower.watts +
          transfer.transmitterLossPower.watts := by ring
    _ = transfer.acousticReceivedPower.watts + transfer.reflectedPower.watts +
          transfer.absorbedPower.watts + transfer.distributedLossPower.watts +
            transfer.transmitterLossPower.watts := by rw [transfer.pathEnergyBalance]
    _ = transfer.deliveredElectricalPower.watts + transfer.receiverLossPower.watts +
          transfer.reflectedPower.watts + transfer.absorbedPower.watts +
            transfer.distributedLossPower.watts + transfer.transmitterLossPower.watts := by
      rw [transfer.receiverEnergyBalance]
    _ = transfer.deliveredElectricalPower.watts + transfer.transmitterLossPower.watts +
          transfer.reflectedPower.watts + transfer.absorbedPower.watts +
            transfer.distributedLossPower.watts + transfer.receiverLossPower.watts := by ring

/-- Delivered UPT power cannot exceed the electrical and auxiliary path inputs. -/
lemma LayeredUltrasonicTransfer.deliveredPower_le_totalInput
    (transfer : LayeredUltrasonicTransfer) :
    transfer.deliveredElectricalPower.watts ≤
      transfer.electricalInputPower.watts + transfer.auxiliaryPathInputPower.watts := by
  rw [transfer.energy_balance]
  linarith [transfer.transmitterLossPower_nonnegative,
    transfer.reflectedPower_nonnegative, transfer.absorbedPower_nonnegative,
    transfer.distributedLossPower_nonnegative, transfer.receiverLossPower_nonnegative]

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
