import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Data.Real.Basic
import Mathlib.Tactic
import Signals.Propagation
import Signals.Proca
import Signals.Units

namespace Signals.Applications

open Signals.Propagation
open Signals.Proca
open Signals.Units

/-- A finite-energy Airy-like packet with explicit truncation and aperture data.

The ideal Airy solution is not finite-energy. This record therefore models the
truncated packet used by an experiment and keeps its range and aperture limits
visible. -/
structure AiryPacket where
  truncation : ℝ
  truncation_positive : 0 < truncation
  aperture : ℝ
  aperture_positive : 0 < aperture
  finiteEnergy : ℝ
  finiteEnergy_nonnegative : 0 ≤ finiteEnergy
  selfHealingRange : ℝ
  selfHealingRange_nonnegative : 0 ≤ selfHealingRange
  curvature : ℝ

/-- A guided mode with explicit core/cladding contrast and modal overlap. -/
structure WaveguideSpec where
  corePermittivity : ℝ
  corePermittivity_pos : 0 < corePermittivity
  claddingPermittivity : ℝ
  claddingPermittivity_pos : 0 < claddingPermittivity
  coreGuides : claddingPermittivity < corePermittivity
  modeOverlap : BoundedFactor
  confinement : BoundedFactor
  propagationLoss : ℝ
  propagationLoss_nonnegative : 0 ≤ propagationLoss
  interactionLength : Length
  interactionLength_pos : 0 < interactionLength.meters

/-- The normalized guided-mode transfer factor. -/
noncomputable def WaveguideSpec.transferFactor (waveguide : WaveguideSpec) : ℝ :=
  waveguide.modeOverlap.value * waveguide.confinement.value *
    Real.exp (-waveguide.propagationLoss * waveguide.interactionLength.meters)

/-- Modal and confinement factors cannot amplify guided power. -/
lemma WaveguideSpec.transferFactor_bounds (waveguide : WaveguideSpec) :
    0 ≤ waveguide.transferFactor ∧ waveguide.transferFactor ≤ 1 := by
  constructor
  · exact mul_nonneg
      (mul_nonneg waveguide.modeOverlap.nonnegative waveguide.confinement.nonnegative)
      (Real.exp_pos _).le
  · have modal_nonnegative := mul_nonneg waveguide.modeOverlap.nonnegative
      waveguide.confinement.nonnegative
    have modal_le_one := mul_le_one waveguide.modeOverlap.le_one
      waveguide.confinement.nonnegative waveguide.confinement.le_one
    have attenuation_le_one : Real.exp
        (-waveguide.propagationLoss * waveguide.interactionLength.meters) ≤ 1 := by
      rw [← Real.exp_zero, Real.exp_le_exp]
      nlinarith [waveguide.propagationLoss_nonnegative,
        waveguide.interactionLength_pos.le]
    exact mul_le_one modal_le_one (Real.exp_pos _).le attenuation_le_one

/-- A two-beam nonlinear frequency-conversion specification.

The response fields correspond to the missing quantities in the source chat:
nonlinear coefficient, mechanical susceptibility, phase matching, modal overlap,
propagation loss, and boundary response. Their values must be supplied by a
material measurement or a separately justified model. -/
structure NonlinearConversion where
  nonlinearCoefficient : ℝ
  nonlinearCoefficient_nonnegative : 0 ≤ nonlinearCoefficient
  mechanicalSusceptibility : ℝ
  mechanicalSusceptibility_nonnegative : 0 ≤ mechanicalSusceptibility
  phaseMatching : BoundedFactor
  modeOverlap : BoundedFactor
  propagationLoss : ℝ
  propagationLoss_nonnegative : 0 ≤ propagationLoss
  interactionLength : ℝ
  interactionLength_nonnegative : 0 ≤ interactionLength
  boundary : InterfaceResponse

/-- A normalized conversion response including loss and interface transmission. -/
noncomputable def NonlinearConversion.response (conversion : NonlinearConversion) : ℝ :=
  conversion.nonlinearCoefficient * conversion.mechanicalSusceptibility *
    conversion.phaseMatching.value * conversion.modeOverlap.value *
    Real.exp (-conversion.propagationLoss * conversion.interactionLength) *
    conversion.boundary.transmissionPower

/-- The modeled nonlinear response is nonnegative. -/
lemma NonlinearConversion.response_nonnegative (conversion : NonlinearConversion) :
    0 ≤ conversion.response := by
  unfold NonlinearConversion.response
  exact mul_nonneg
    (mul_nonneg
      (mul_nonneg
        (mul_nonneg
          (mul_nonneg conversion.nonlinearCoefficient_nonnegative
            conversion.mechanicalSusceptibility_nonnegative)
          conversion.phaseMatching.nonnegative)
        conversion.modeOverlap.nonnegative)
      (Real.exp_pos _).le)
    conversion.boundary.transmission_nonnegative

/-- A frequency sweep has a positive center and finite nonnegative half-width. -/
structure FrequencySweep where
  center : Frequency
  center_positive : 0 < center.hz
  halfWidthHz : ℝ
  halfWidth_nonnegative : 0 ≤ halfWidthHz

/-- Two swept beams whose central frequencies add to the generated central frequency. -/
structure FireCannonPump where
  beamA : FrequencySweep
  beamB : FrequencySweep
  conversion : NonlinearConversion

/-- A MIMO array specification for coherent multi-beam pumping. -/
structure MimoArray where
  elementCount : ℕ
  elementCount_positive : 0 < elementCount
  elementPower : Power
  elementPower_nonnegative : 0 ≤ elementPower.watts
  arrayEfficiency : BoundedFactor

/-- The idealized upper bound on radiated MIMO source power. -/
def MimoArray.sourcePower (array : MimoArray) : ℝ :=
  array.elementCount * array.elementPower.watts * array.arrayEfficiency.value

/-- Array efficiency cannot make source power exceed the element-count budget. -/
lemma MimoArray.sourcePower_le_element_budget (array : MimoArray) :
    array.sourcePower ≤ array.elementCount * array.elementPower.watts := by
  unfold MimoArray.sourcePower
  simpa [mul_one] using
    (mul_le_mul_of_nonneg_left array.arrayEfficiency.le_one
      (mul_nonneg (Nat.cast_nonneg array.elementCount) array.elementPower_nonnegative))

/-- A fire-cannon pump with a MIMO source and a measured conversion contract. -/
structure MimoFireCannonPump extends FireCannonPump where
  array : MimoArray
  beamPowerBudget : ℝ
  beamPowerBudget_nonnegative : 0 ≤ beamPowerBudget
  beamPowerBound : beamPowerBudget ≤ array.sourcePower

/-- The central sum-frequency of the two fire-cannon beams. -/
def FireCannonPump.sumFrequency (pump : FireCannonPump) : Frequency :=
  { hz := pump.beamA.center.hz + pump.beamB.center.hz }

/-- The central frequency of two 400 GHz beams is 800 GHz. -/
lemma FireCannonPump.two_400GHz_sum (pump : FireCannonPump)
    (beamA_400 : pump.beamA.center.hz = (gigahertz 400).hz)
    (beamB_400 : pump.beamB.center.hz = (gigahertz 400).hz) :
    pump.sumFrequency.hz = (gigahertz 800).hz := by
  rw [FireCannonPump.sumFrequency, beamA_400, beamB_400]
  norm_num [gigahertz]

/-- The frequency half-width of a sum-frequency sweep is bounded by the sum
of the input half-widths. -/
def FireCannonPump.sumHalfWidth (pump : FireCannonPump) : ℝ :=
  pump.beamA.halfWidthHz + pump.beamB.halfWidthHz

/-- A sum-frequency sweep has nonnegative half-width. -/
lemma FireCannonPump.sumHalfWidth_nonnegative (pump : FireCannonPump) :
    0 ≤ pump.sumHalfWidth := by
  unfold FireCannonPump.sumHalfWidth
  exact add_nonneg pump.beamA.halfWidth_nonnegative pump.beamB.halfWidth_nonnegative

/-- A receiver-side power-transfer application with explicit extraction efficiency. -/
structure PowerTransfer where
  link : LinkBudget
  receiverEfficiency : BoundedFactor

/-- Usable power after link losses and receiver extraction. -/
noncomputable def PowerTransfer.usablePower (transfer : PowerTransfer) : ℝ :=
  transfer.link.receivedPower * transfer.receiverEfficiency.value

/-- Receiver extraction cannot increase the already-delivered link power. -/
lemma PowerTransfer.usablePower_le_receivedPower (transfer : PowerTransfer) :
    transfer.usablePower ≤ transfer.link.receivedPower := by
  unfold PowerTransfer.usablePower
  calc
    transfer.link.receivedPower * transfer.receiverEfficiency.value ≤
        transfer.link.receivedPower * 1 :=
      mul_le_mul_of_nonneg_left transfer.receiverEfficiency.le_one
        transfer.link.receivedPower_nonnegative
    _ = transfer.link.receivedPower := by ring

/-- A plasma drive with separate control and propellant energy budgets.

The power balance is an explicit conservation assumption. It replaces the
unsupported vacuum-energy claim with a model that can later be calibrated to a
measured drive. -/
structure PlasmaDrive where
  controlPower : ℝ
  controlPower_nonnegative : 0 ≤ controlPower
  propellantPower : ℝ
  propellantPower_nonnegative : 0 ≤ propellantPower
  outputPower : ℝ
  outputPower_nonnegative : 0 ≤ outputPower
  powerBalance : outputPower ≤ controlPower + propellantPower

/-- The modeled plasma drive cannot output more power than its declared inputs. -/
lemma PlasmaDrive.output_le_input (drive : PlasmaDrive) :
    drive.outputPower ≤ drive.controlPower + drive.propellantPower :=
  drive.powerBalance

end Signals.Applications