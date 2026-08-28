import Mathlib.Data.Nat.Basic
import Mathlib.Data.Real.Basic
import Mathlib.Tactic

namespace Signals.Pending

/-! # Layer-code construction data

Williamson and Baspin, *Layer codes* (Nature Communications 15, 9528, 2024),
describe a construction that transforms CSS stabilizer codes into three-
dimensional topological codes built from surface-code layers and one-
dimensional junctions. The records here preserve finite code parameters and
reported scaling assumptions; they do not implement a decoder or prove a
hardware threshold. See `Signals.QECReferences` for the reference-only
registry linking the Error Correction Zoo entries and the external QECLean
formalization candidate.
-/

/-- Finite metadata about a CSS stabilizer-code family.

This is not a stabilizer group or a quantum code implementation. -/
structure CSSStabilizerCode where
  physicalQubits : ℕ
  physicalQubits_positive : 0 < physicalQubits
  logicalQubits : ℕ
  logicalQubits_le_physical : logicalQubits ≤ physicalQubits
  codeDistance : ℕ
  codeDistance_positive : 0 < codeDistance
  maximumCheckWeight : ℕ
  maximumCheckWeight_positive : 0 < maximumCheckWeight
  cssCommutationResidual : ℕ
  cssCommutationLaw : cssCommutationResidual = 0

/-- Finite metadata about an output of the Layer-code lift.

The construction metadata makes its geometric and stabilizer constraints
explicit. `optimalScalingClaimed` is a status flag supplied by the model and
is not a theorem about every input code. This is not a Pauli, homology, or
decoder implementation. -/
structure LayerCodeLift where
  input : CSSStabilizerCode
  layerCount : ℕ
  layerCount_positive : 0 < layerCount
  outputPhysicalQubits : ℕ
  outputPhysicalQubits_positive : 0 < outputPhysicalQubits
  outputLogicalQubits : ℕ
  outputLogicalQubits_le_physical :
    outputLogicalQubits ≤ outputPhysicalQubits
  outputCodeDistance : ℕ
  outputCodeDistance_positive : 0 < outputCodeDistance
  topologicalDimension : ℕ
  junctionDimension : ℕ
  maximumStabilizerWeight : ℕ
  logicalQubitsLaw : outputLogicalQubits = input.logicalQubits
  topologicalDimensionLaw : topologicalDimension = 3
  junctionDimensionLaw : junctionDimension = 1
  stabilizerWeightBound : maximumStabilizerWeight ≤ 6
  outputCommutationResidual : ℕ
  outputCommutationLaw : outputCommutationResidual = 0
  optimalScalingClaimed : Bool
  energyBarrierSystemSize : ℝ
  energyBarrierSystemSize_pos : 0 < energyBarrierSystemSize
  energyBarrierCoefficient : ℝ
  energyBarrierCoefficient_nonnegative : 0 ≤ energyBarrierCoefficient
  energyBarrierExponent : ℕ
  energyBarrierExponent_positive : 0 < energyBarrierExponent
  energyBarrier : ℝ
  energyBarrier_nonnegative : 0 ≤ energyBarrier
  energyBarrierLaw : energyBarrier =
    energyBarrierCoefficient * energyBarrierSystemSize ^ energyBarrierExponent

/-- The Layer-code lift preserves the supplied logical-qubit count. -/
lemma LayerCodeLift.logical_qubits_holds (lift : LayerCodeLift) :
    lift.outputLogicalQubits = lift.input.logicalQubits :=
  lift.logicalQubitsLaw

/-- The Layer-code output is three-dimensional in the supplied construction
metadata. -/
lemma LayerCodeLift.three_dimensional (lift : LayerCodeLift) :
    lift.topologicalDimension = 3 :=
  lift.topologicalDimensionLaw

/-- Layer junctions are one-dimensional in the supplied construction metadata. -/
lemma LayerCodeLift.one_dimensional_junction (lift : LayerCodeLift) :
    lift.junctionDimension = 1 :=
  lift.junctionDimensionLaw

/-- The maximum stabilizer-check weight is bounded by six. -/
lemma LayerCodeLift.stabilizer_weight_le_six (lift : LayerCodeLift) :
    lift.maximumStabilizerWeight ≤ 6 :=
  lift.stabilizerWeightBound

/-- The output stabilizer checks satisfy the supplied finite commutation
residual law. -/
lemma LayerCodeLift.output_commutation_holds (lift : LayerCodeLift) :
    lift.outputCommutationResidual = 0 :=
  lift.outputCommutationLaw

/-- The polynomial energy-barrier model is nonnegative under its explicit
coefficient and system-size assumptions. -/
lemma LayerCodeLift.energy_barrier_nonnegative_holds
    (lift : LayerCodeLift) :
    0 ≤ lift.energyBarrier := by
  rw [lift.energyBarrierLaw]
  exact mul_nonneg lift.energyBarrierCoefficient_nonnegative
    (pow_nonneg lift.energyBarrierSystemSize_pos.le _)

/-- The input CSS commutation residual is zero under its supplied law. -/
lemma CSSStabilizerCode.commutation_holds
    (code : CSSStabilizerCode) :
    code.cssCommutationResidual = 0 :=
  code.cssCommutationLaw

end Signals.Pending
