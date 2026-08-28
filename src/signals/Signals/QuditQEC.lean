import Mathlib.Data.Real.Basic
import Mathlib.Data.ZMod.Basic
import Mathlib.Tactic
import Signals.OAM

namespace Signals.Pending

open Signals.OAM

/-! # Qudit error-correction models

Konno et al. demonstrated a propagating optical GKP qubit, while Brock et al.
demonstrated error-corrected GKP qutrits and ququarts beyond break-even. These
records extract the finite algebra and performance bookkeeping needed to reason
about a higher-dimensional OAM design. They do not claim that either experiment
implemented an OAM qudit or that a 100-dimensional code has been constructed.
-/

/-- Addition of finite cyclic qudit labels, with the modulus positivity made
explicit for the `Fin` result. -/
def cyclicShift {dimension : ℕ} (dimension_pos : 0 < dimension)
    (offset label : Fin dimension) : Fin dimension :=
  ⟨(offset.val + label.val) % dimension, Nat.mod_lt _ dimension_pos⟩

/-- A zero shift leaves a finite cyclic label unchanged. -/
lemma cyclicShift_zero {dimension : ℕ} (dimension_pos : 0 < dimension)
    (label : Fin dimension) :
    cyclicShift dimension_pos ⟨0, dimension_pos⟩ label = label := by
  apply Fin.ext
  simp [cyclicShift, Nat.mod_eq_of_lt label.isLt]

/-- The binary symplectic phase pairing generalized to a finite cyclic qudit
module. It is a ring expression over `ZMod dimension`; no field assumption is
made, so composite dimensions such as 100 remain admissible. -/
def quditSymplecticPhase (dimension : ℕ)
    (x z x' z' : ZMod dimension) : ZMod dimension :=
  x * z' - z * x'

/-- The cyclic qudit phase pairing is antisymmetric. -/
lemma quditSymplecticPhase_antisymmetric (dimension : ℕ)
    (x z x' z' : ZMod dimension) :
    quditSymplecticPhase dimension x z x' z' =
      -quditSymplecticPhase dimension x' z' x z := by
  dsimp [quditSymplecticPhase]
  ring

/-- GKP qudit geometry extracted from the displacement-operator construction. -/
structure GKPQuditModel (dimension : ℕ) where
  dimension_at_least_two : 2 ≤ dimension
  logicalPauliSpacing : ℝ
  logicalPauliSpacing_nonnegative : 0 ≤ logicalPauliSpacing
  logicalPauliSpacingLaw : logicalPauliSpacing =
    Real.sqrt (Real.pi / (dimension : ℝ))
  stabilizerLength : ℝ
  stabilizerLength_nonnegative : 0 ≤ stabilizerLength
  stabilizerLengthLaw : stabilizerLength =
    Real.sqrt (Real.pi * (dimension : ℝ))
  envelopeParameter : ℝ
  envelopeParameter_pos : 0 < envelopeParameter
  meanPhotonNumber : ℝ
  meanPhotonNumber_nonnegative : 0 ≤ meanPhotonNumber
  finiteEnergyEnvelopeLaw : meanPhotonNumber =
    1 / (2 * envelopeParameter ^ 2)

/-- The GKP qudit model exposes the logical displacement spacing. -/
lemma GKPQuditModel.logical_spacing_holds {dimension : ℕ}
    (model : GKPQuditModel dimension) :
    model.logicalPauliSpacing =
      Real.sqrt (Real.pi / (dimension : ℝ)) :=
  model.logicalPauliSpacingLaw

/-- The GKP qudit model exposes the stabilizer length. -/
lemma GKPQuditModel.stabilizer_length_holds {dimension : ℕ}
    (model : GKPQuditModel dimension) :
    model.stabilizerLength =
      Real.sqrt (Real.pi * (dimension : ℝ)) :=
  model.stabilizerLengthLaw

/-- A finite-energy GKP qudit QEC gain observation.

The source defines gain from physical and logical decay rates. A gain above one
means the logical memory decays more slowly than the comparison physical qudit.
-/structure QuditQECGainObservation where
  dimension : ℕ
  dimension_at_least_two : 2 ≤ dimension
  physicalDecayRate : ℝ
  physicalDecayRate_pos : 0 < physicalDecayRate
  logicalDecayRate : ℝ
  logicalDecayRate_pos : 0 < logicalDecayRate
  gain : ℝ
  gain_nonnegative : 0 ≤ gain
  gainLaw : gain = physicalDecayRate / logicalDecayRate
  reportedStandardError : ℝ
  reportedStandardError_nonnegative : 0 ≤ reportedStandardError
  reportedGainAboveBreakEven : 1 < gain - reportedStandardError
  sourceStatus : String

/-- A physical/logical decay-rate comparison above break-even has gain above
one. -/
lemma QuditQECGainObservation.gain_gt_one
    (observation : QuditQECGainObservation)
    (logical_slower : observation.logicalDecayRate <
      observation.physicalDecayRate) :
    1 < observation.gain := by
  rw [observation.gainLaw]
  apply (lt_div_iff₀ observation.logicalDecayRate_pos).2
  simpa using logical_slower

/-- The reported gain uncertainty still lies above the break-even point. -/
lemma QuditQECGainObservation.reported_gain_gt_one
    (observation : QuditQECGainObservation) :
    1 < observation.gain - observation.reportedStandardError :=
  observation.reportedGainAboveBreakEven

/-- Centered integer labels for a 100-state OAM register. -/
def centeredOAMMode (mode : Fin 100) : ℤ :=
  (mode.val : ℤ) - 50

/-- Centered OAM labels are distinct. -/
lemma centeredOAMMode_injective :
    Function.Injective centeredOAMMode := by
  intro left right h
  apply Fin.ext
  dsimp [centeredOAMMode] at h
  omega

/-- A 100-state OAM qudit design with explicit QEC-readiness fields.

The state is a finite OAM register. `gkpModel` records which higher-dimensional
GKP ideas are being compared; it is not an assertion that OAM modes realize the
oscillator displacement operators. -/
structure OAM100QuditQECDesign where
  state : Qudit 100
  modeLabel : Fin 100 → ℤ
  modeLabelLaw : ∀ mode, modeLabel mode = centeredOAMMode mode
  modeLabel_injective : Function.Injective modeLabel
  modeSpacing : ℝ
  modeSpacing_pos : 0 < modeSpacing
  gkpModel : GKPQuditModel 100
  factorLeft : ℕ
  factorRight : ℕ
  factorizationLaw : factorLeft * factorRight = 100
  syndromeAxisCount : ℕ
  syndromeAxisCountLaw : syndromeAxisCount = 2
  syndromeReadoutSpecified : Bool
  recoveryMapSpecified : Bool
  modeLossRate : ℝ
  modeLossRate_nonnegative : 0 ≤ modeLossRate
  modeDephasingRate : ℝ
  modeDephasingRate_nonnegative : 0 ≤ modeDephasingRate

/-- The OAM design retains exactly 100 finite mode labels. -/
lemma OAM100QuditQECDesign.mode_label_injective
    (design : OAM100QuditQECDesign) :
    Function.Injective design.modeLabel :=
  design.modeLabel_injective

/-- The two GKP stabilizer directions are represented as explicit design
metadata, not as a completed OAM syndrome circuit. -/
lemma OAM100QuditQECDesign.two_syndrome_axes
    (design : OAM100QuditQECDesign) :
    design.syndromeAxisCount = 2 :=
  design.syndromeAxisCountLaw

/-- The 100-level design can be factored as a 4-by-25 register at the finite
arithmetic level. This does not assert an error-correcting tensor-product code.
-/
lemma OAM100QuditQECDesign.factorization
    (design : OAM100QuditQECDesign) :
    design.factorLeft * design.factorRight = 100 :=
  design.factorizationLaw

end Signals.Pending
