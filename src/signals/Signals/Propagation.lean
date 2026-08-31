import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Data.Real.Basic
import Mathlib.Tactic
import Signals.Units

namespace Signals.Propagation

/-- A calibrated dimensionless factor constrained to the interval `[0, 1]`. -/
structure BoundedFactor where
  value : ℝ
  nonnegative : 0 ≤ value
  le_one : value ≤ 1

/-- Multiplication of independent efficiency or transmission factors. -/
lemma mul_le_one {left right : ℝ} (left_le_one : left ≤ 1) (right_nonnegative : 0 ≤ right)
    (right_le_one : right ≤ 1) :
    left * right ≤ 1 := by
  calc
    left * right ≤ 1 * right := mul_le_mul_of_nonneg_right left_le_one right_nonnegative
    _ ≤ 1 * 1 := mul_le_mul_of_nonneg_left right_le_one (by norm_num)
    _ = 1 := by ring

/-- Whether a link is coupled in the far field or near field. -/
inductive CouplingRegime
  | farField
  | nearField
  deriving DecidableEq, Repr

/-- Antenna and geometry factors for a radiative link.

Near-field operation is represented separately from far-field operation. The
reactive fraction records energy stored locally rather than silently treating
near-field coupling as lossless propagation. -/
structure CouplingFactors where
  regime : CouplingRegime
  antennaEfficiency : BoundedFactor
  impedanceMatch : BoundedFactor
  apertureCoupling : BoundedFactor
  alignment : BoundedFactor
  radiativeCoupling : BoundedFactor
  reactiveFraction : BoundedFactor
  energyPartition : reactiveFraction.value + radiativeCoupling.value ≤ 1

/-- The product of antenna, impedance, aperture, alignment, and radiation factors. -/
def CouplingFactors.total (factors : CouplingFactors) : ℝ :=
  factors.antennaEfficiency.value * factors.impedanceMatch.value *
    factors.apertureCoupling.value * factors.alignment.value *
    factors.radiativeCoupling.value

/-- All coupling factors give a nonnegative total transfer factor. -/
lemma CouplingFactors.total_nonnegative (factors : CouplingFactors) :
    0 ≤ factors.total := by
  unfold CouplingFactors.total
  exact mul_nonneg
    (mul_nonneg
      (mul_nonneg
        (mul_nonneg factors.antennaEfficiency.nonnegative factors.impedanceMatch.nonnegative)
        factors.apertureCoupling.nonnegative)
      factors.alignment.nonnegative)
    factors.radiativeCoupling.nonnegative

/-- Independent coupling factors cannot amplify delivered power. -/
lemma CouplingFactors.total_le_one (factors : CouplingFactors) :
    factors.total ≤ 1 := by
  unfold CouplingFactors.total
  have first_nonnegative := mul_nonneg factors.antennaEfficiency.nonnegative
    factors.impedanceMatch.nonnegative
  have first_le_one := mul_le_one factors.antennaEfficiency.le_one
    factors.impedanceMatch.nonnegative factors.impedanceMatch.le_one
  have second_nonnegative := mul_nonneg first_nonnegative
    factors.apertureCoupling.nonnegative
  have second_le_one := mul_le_one first_le_one factors.apertureCoupling.nonnegative
    factors.apertureCoupling.le_one
  have third_nonnegative := mul_nonneg second_nonnegative factors.alignment.nonnegative
  have third_le_one := mul_le_one second_le_one factors.alignment.nonnegative
    factors.alignment.le_one
  exact mul_le_one third_le_one factors.radiativeCoupling.nonnegative
    factors.radiativeCoupling.le_one

/-- The near-field bookkeeping leaves no more than unit total energy for stored
and radiated components. -/
lemma CouplingFactors.reactive_plus_radiative_le_one (factors : CouplingFactors) :
    factors.reactiveFraction.value + factors.radiativeCoupling.value ≤ 1 :=
  factors.energyPartition

/-- Bulk constitutive loss represented by a nonnegative attenuation coefficient
and a separately calibrated transmission factor. -/
structure MediumLoss where
  attenuationPerLength : ℝ
  attenuation_nonneg : 0 ≤ attenuationPerLength
  bulkTransmission : BoundedFactor

/-- Power reflection, transmission, and absorption at an interface.

The conservation equation is data supplied by the interface model; it does not
assume that a material boundary is reflection-free. -/
structure InterfaceResponse where
  reflectionPower : ℝ
  transmissionPower : ℝ
  absorptionPower : ℝ
  reflection_nonnegative : 0 ≤ reflectionPower
  transmission_nonnegative : 0 ≤ transmissionPower
  absorption_nonnegative : 0 ≤ absorptionPower
  power_conservation : reflectionPower + transmissionPower + absorptionPower = 1

/-- Interface transmission is bounded by one when reflection and absorption are nonnegative. -/
lemma InterfaceResponse.transmission_le_one (response : InterfaceResponse) :
    response.transmissionPower ≤ 1 := by
  nlinarith [response.power_conservation, response.reflection_nonnegative,
    response.absorption_nonnegative]

/-- Propagation strategies discussed in the source communications design. -/
inductive PropagationMode
  | lithosphericChord
  | surfaceAiryArc
  | ionosphericMhdDuct
  | throughSpaceBallistic
  deriving DecidableEq, Repr

/-- A link budget with explicit near/far-field coupling and propagation losses. -/
structure LinkBudget where
  mode : PropagationMode
  sourcePower : Signals.Units.Power
  sourcePower_nonnegative : 0 ≤ sourcePower.watts
  distance : Signals.Units.Length
  distance_nonnegative : 0 ≤ distance.meters
  coupling : CouplingFactors
  medium : MediumLoss
  interface : InterfaceResponse

/-- Power attenuation from the modeled bulk attenuation coefficient. -/
noncomputable def LinkBudget.attenuationFactor (link : LinkBudget) : ℝ :=
  Real.exp (-2 * link.medium.attenuationPerLength * link.distance.meters)

/-- Bulk attenuation is nonnegative. -/
lemma LinkBudget.attenuationFactor_nonnegative (link : LinkBudget) :
    0 ≤ link.attenuationFactor := by
  exact (Real.exp_pos _).le

/-- Nonnegative attenuation cannot increase a link's power. -/
lemma LinkBudget.attenuationFactor_le_one (link : LinkBudget) :
    link.attenuationFactor ≤ 1 := by
  rw [LinkBudget.attenuationFactor, ← Real.exp_zero, Real.exp_le_exp]
  nlinarith [link.medium.attenuation_nonneg, link.distance_nonnegative]

/-- The multiplicative transfer factor for a link budget. -/
noncomputable def LinkBudget.transferFactor (link : LinkBudget) : ℝ :=
  link.coupling.total * link.interface.transmissionPower *
    link.medium.bulkTransmission.value * link.attenuationFactor

/-- A link transfer factor is nonnegative. -/
lemma LinkBudget.transferFactor_nonnegative (link : LinkBudget) :
    0 ≤ link.transferFactor := by
  unfold LinkBudget.transferFactor
  exact mul_nonneg
    (mul_nonneg
      (mul_nonneg link.coupling.total_nonnegative link.interface.transmission_nonnegative)
      link.medium.bulkTransmission.nonnegative)
    link.attenuationFactor_nonnegative

/-- A link transfer factor cannot exceed one. -/
lemma LinkBudget.transferFactor_le_one (link : LinkBudget) :
    link.transferFactor ≤ 1 := by
  unfold LinkBudget.transferFactor
  have first_nonnegative := mul_nonneg link.coupling.total_nonnegative
    link.interface.transmission_nonnegative
  have first_le_one := mul_le_one link.coupling.total_le_one
    link.interface.transmission_nonnegative link.interface.transmission_le_one
  have second_nonnegative := mul_nonneg first_nonnegative
    link.medium.bulkTransmission.nonnegative
  have second_le_one := mul_le_one first_le_one link.medium.bulkTransmission.nonnegative
    link.medium.bulkTransmission.le_one
  exact mul_le_one second_le_one link.attenuationFactor_nonnegative
    link.attenuationFactor_le_one

/-- Received power after antenna, interface, material, and attenuation losses. -/
noncomputable def LinkBudget.receivedPower (link : LinkBudget) : ℝ :=
  link.sourcePower.watts * link.transferFactor

/-- A passive link budget cannot deliver negative received power. -/
lemma LinkBudget.receivedPower_nonnegative (link : LinkBudget) :
    0 ≤ link.receivedPower := by
  exact mul_nonneg link.sourcePower_nonnegative link.transferFactor_nonnegative

/-- Explicit loss factors guarantee received power does not exceed source power. -/
lemma LinkBudget.receivedPower_le_sourcePower (link : LinkBudget) :
  link.receivedPower ≤ link.sourcePower.watts := by
  unfold LinkBudget.receivedPower
  calc
    link.sourcePower.watts * link.transferFactor ≤ link.sourcePower.watts * 1 :=
      mul_le_mul_of_nonneg_left link.transferFactor_le_one link.sourcePower_nonnegative
    _ = link.sourcePower.watts := by ring

end Signals.Propagation
