import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic
import Mathlib.Data.Complex.Basic
import Mathlib.Data.Nat.Choose.Basic
import Mathlib.Data.Real.Basic
import Mathlib.Tactic
import Signals.Units

namespace Signals.Pending

open Signals.Units

/-! # Cavity electrodynamics and Grover cavity-QED models

These finite records extract equations from Kipp et al., *Cavity
Electrodynamics of van der Waals Heterostructures* (2024/2025), and Nagib,
Saffman, and Mølmer, *Efficient preparation of entangled states in cavity QED
with Grover's algorithm* and *Deterministic carving of quantum states with
Grover's algorithm* (2025). They are conditional data contracts: Lean checks
the supplied algebra, but does not assert that an arbitrary cavity realizes the
model or that a target fidelity is experimentally achieved.
-/

/-- A pair of coupled cavity and matter modes with hybridized frequencies.

The two hybrid frequencies are the eigenvalues of the real symmetric
normalized two-mode coupling matrix. Frequencies are stored in hertz and the
coupling is stored in the same frequency convention. -/
structure CoupledCavityModes where
  cavityFrequency : Frequency
  cavityFrequency_pos : 0 < cavityFrequency.hz
  matterFrequency : Frequency
  matterFrequency_pos : 0 < matterFrequency.hz
  couplingFrequency : Frequency
  couplingFrequency_nonnegative : 0 ≤ couplingFrequency.hz
  lowerHybridFrequency : Frequency
  lowerHybridFrequency_nonnegative : 0 ≤ lowerHybridFrequency.hz
  upperHybridFrequency : Frequency
  upperHybridFrequency_pos : 0 < upperHybridFrequency.hz
  modeSplitting : Frequency
  modeSplitting_nonnegative : 0 ≤ modeSplitting.hz
  normalizedCoupling : ℝ
  lowerHybridLaw : lowerHybridFrequency.hz =
    (cavityFrequency.hz + matterFrequency.hz) / 2 -
      Real.sqrt (((cavityFrequency.hz - matterFrequency.hz) / 2) ^ 2 +
        couplingFrequency.hz ^ 2)
  upperHybridLaw : upperHybridFrequency.hz =
    (cavityFrequency.hz + matterFrequency.hz) / 2 +
      Real.sqrt (((cavityFrequency.hz - matterFrequency.hz) / 2) ^ 2 +
        couplingFrequency.hz ^ 2)
  modeSplittingLaw : modeSplitting.hz =
    upperHybridFrequency.hz - lowerHybridFrequency.hz
  normalizedCouplingLaw : normalizedCoupling =
    couplingFrequency.hz / cavityFrequency.hz

/-- The hybrid-mode splitting is twice the coupling at exact resonance. -/
lemma CoupledCavityModes.resonant_splitting
    (modes : CoupledCavityModes)
    (resonance : modes.cavityFrequency.hz = modes.matterFrequency.hz) :
    modes.modeSplitting.hz = 2 * modes.couplingFrequency.hz := by
  rw [modes.modeSplittingLaw, modes.upperHybridLaw, modes.lowerHybridLaw,
    resonance]
  have coupling_abs : |modes.couplingFrequency.hz| =
      modes.couplingFrequency.hz :=
    abs_of_nonneg modes.couplingFrequency_nonnegative
  have zero_term :
      ((modes.matterFrequency.hz - modes.matterFrequency.hz) / 2) ^ 2 =
        0 := by ring
  rw [zero_term, zero_add, Real.sqrt_sq_eq_abs, coupling_abs]
  ring

/-- The normalized cavity coupling is nonnegative. -/
lemma CoupledCavityModes.normalized_coupling_nonnegative
    (modes : CoupledCavityModes) :
    0 ≤ modes.normalizedCoupling := by
  rw [modes.normalizedCouplingLaw]
  exact div_nonneg modes.couplingFrequency_nonnegative
    modes.cavityFrequency_pos.le

/-- The ultrastrong-coupling criterion used in the cavity paper. -/
def CoupledCavityModes.ultrastrong (modes : CoupledCavityModes) : Prop :=
  (1 : ℝ) / 10 < modes.normalizedCoupling

/-- A gate-tunable collective-mode resonance fitted to a carrier-density law.
The exponent is stored as a model parameter because the reported power law is a
fit, not a universal graphene theorem. -/
structure CarrierDensityResonance where
  carrierDensity : ℝ
  carrierDensity_pos : 0 < carrierDensity
  prefactor : ℝ
  prefactor_pos : 0 < prefactor
  exponent : ℝ
  resonanceFrequency : Frequency
  resonanceFrequency_pos : 0 < resonanceFrequency.hz
  resonanceLaw : resonanceFrequency.hz =
    prefactor * Real.rpow carrierDensity exponent

/-- A finite spectral-weight transfer record for two hybrid branches. -/
structure SpectralWeightTransfer where
  upperWeightBefore : ℝ
  upperWeightBefore_nonnegative : 0 ≤ upperWeightBefore
  lowerWeightBefore : ℝ
  lowerWeightBefore_nonnegative : 0 ≤ lowerWeightBefore
  upperWeightAfter : ℝ
  upperWeightAfter_nonnegative : 0 ≤ upperWeightAfter
  lowerWeightAfter : ℝ
  lowerWeightAfter_nonnegative : 0 ≤ lowerWeightAfter
  conservation : upperWeightBefore + lowerWeightBefore =
    upperWeightAfter + lowerWeightAfter
  transferAmount : ℝ
  transferAmount_nonnegative : 0 ≤ transferAmount
  transferLaw : transferAmount = upperWeightBefore - upperWeightAfter

/-- Spectral weight transfer is equal and opposite between the two branches. -/
lemma SpectralWeightTransfer.lower_branch_gain
    (transfer : SpectralWeightTransfer) :
    transfer.lowerWeightAfter - transfer.lowerWeightBefore =
      transfer.transferAmount := by
  rw [transfer.transferLaw]
  linarith [transfer.conservation]

/-- An ideal phase inversion on a selected state component. -/
structure GroverPhaseInversion where
  targetBefore : ℂ
  targetAfter : ℂ
  orthogonalBefore : ℂ
  orthogonalAfter : ℂ
  targetLaw : targetAfter = -targetBefore
  orthogonalLaw : orthogonalAfter = orthogonalBefore

/-- The two-dimensional Grover rotation model used for state preparation.
The target and orthogonal amplitudes are the coordinates in the plane spanned
by the initial and target states. -/
structure GroverRotation where
  overlap : ℝ
  overlap_nonnegative : 0 ≤ overlap
  overlap_le_one : overlap ≤ 1
  angle : ℝ
  overlapLaw : overlap = Real.sin (angle / 2)
  iterationCount : ℕ
  targetAmplitude : ℝ
  orthogonalAmplitude : ℝ
  targetAmplitudeLaw : targetAmplitude =
    Real.sin (((2 * iterationCount + 1 : ℕ) : ℝ) * angle / 2)
  orthogonalAmplitudeLaw : orthogonalAmplitude =
    Real.cos (((2 * iterationCount + 1 : ℕ) : ℝ) * angle / 2)
  fidelity : ℝ
  fidelityLaw : fidelity = targetAmplitude ^ 2

/-- The ideal Grover output has nonnegative fidelity. -/
lemma GroverRotation.fidelity_nonnegative (rotation : GroverRotation) :
    0 ≤ rotation.fidelity := by
  rw [rotation.fidelityLaw]
  exact sq_nonneg _

/-- One Grover iteration reaches the target when the overlap angle is pi/3. -/
lemma GroverRotation.one_step_perfect
    (rotation : GroverRotation)
    (one_step : rotation.iterationCount = 1)
    (one_step_angle : rotation.angle = Real.pi / 3) :
    rotation.targetAmplitude = 1 ∧ rotation.fidelity = 1 := by
  constructor
  · rw [rotation.targetAmplitudeLaw, one_step, one_step_angle]
    have angle_identity :
        ((2 * 1 + 1 : ℕ) : ℝ) * (Real.pi / 3) / 2 = Real.pi / 2 := by
      norm_num
      ring
    rw [angle_identity, Real.sin_pi_div_two]
  · rw [rotation.fidelityLaw]
    rw [rotation.targetAmplitudeLaw, one_step, one_step_angle]
    have angle_identity :
        ((2 * 1 + 1 : ℕ) : ℝ) * (Real.pi / 3) / 2 = Real.pi / 2 := by
      norm_num
      ring
    rw [angle_identity, Real.sin_pi_div_two]
    norm_num

/-- A Dicke-state overlap for a globally rotated product state.
This is the finite version of the binomial overlap used to choose the Grover
rotation angle. -/
structure DickeStateOverlap where
  qubitCount : ℕ
  excitations : ℕ
  excitations_le_qubits : excitations ≤ qubitCount
  rotationAngle : ℝ
  overlapAmplitude : ℝ
  overlapLaw : overlapAmplitude =
    Real.sqrt (Nat.choose qubitCount excitations) *
      Real.cos (rotationAngle / 2) ^ (qubitCount - excitations) *
      Real.sin (rotationAngle / 2) ^ excitations

/-- A cavity-QED phase oracle in the dispersive regime.
The cavity frequency shift is proportional to the number of atoms in the
coupled state, and a resonant reflected photon supplies the conditional sign
flip. -/
structure CavityQEDPhaseOracle where
  atomCavityCoupling : ℝ
  atomCavityCoupling_nonnegative : 0 ≤ atomCavityCoupling
  detuning : ℝ
  detuning_ne_zero : detuning ≠ 0
  dispersiveShift : ℝ
  dispersiveShiftLaw : dispersiveShift =
    atomCavityCoupling ^ 2 / detuning
  bareCavityFrequency : Frequency
  bareCavityFrequency_pos : 0 < bareCavityFrequency.hz
  selectedExcitation : ℕ
  targetExcitation : ℕ
  shiftedCavityFrequency : Frequency
  shiftedCavityFrequency_pos : 0 < shiftedCavityFrequency.hz
  shiftedFrequencyLaw : shiftedCavityFrequency.hz =
    bareCavityFrequency.hz + (selectedExcitation : ℝ) * dispersiveShift
  reflectedPhase : ℂ
  reflectedPhaseLaw : reflectedPhase =
    if selectedExcitation = targetExcitation then -1 else 1

/-- The dispersive cavity shift exposes the atom-number dependence. -/
lemma CavityQEDPhaseOracle.shifted_frequency_holds
    (oracle : CavityQEDPhaseOracle) :
    oracle.shiftedCavityFrequency.hz =
      oracle.bareCavityFrequency.hz +
        (oracle.selectedExcitation : ℝ) * oracle.dispersiveShift :=
  oracle.shiftedFrequencyLaw

/-- The ideal phase oracle has unit-magnitude reflected phase. -/
lemma CavityQEDPhaseOracle.reflected_phase_normSq
    (oracle : CavityQEDPhaseOracle) :
    Complex.normSq oracle.reflectedPhase = 1 := by
  rw [oracle.reflectedPhaseLaw]
  split <;> norm_num

/-- Fidelity-scaling metadata for the finite-bandwidth cavity implementation.
The exponents record the paper's leading cooperativity scalings: unheralded
infidelity scales as `C^(-1/2)` and heralded infidelity as `C^(-2/3)`. -/
structure GroverCavityFidelityScaling where
  cooperativity : ℝ
  cooperativity_pos : 0 < cooperativity
  bandwidthRatio : ℝ
  bandwidthRatio_nonnegative : 0 ≤ bandwidthRatio
  unheraldedExponent : ℝ
  unheraldedExponentLaw : unheraldedExponent = 1 / 2
  heraldedExponent : ℝ
  heraldedExponentLaw : heraldedExponent = 2 / 3
  modeMatching : ℝ
  modeMatching_nonnegative : 0 ≤ modeMatching
  modeMatching_le_one : modeMatching ≤ 1
  heraldingSuccessProbability : ℝ
  heraldingSuccessProbability_nonnegative : 0 ≤ heraldingSuccessProbability
  heraldingSuccessProbability_le_one : heraldingSuccessProbability ≤ 1

/-- The unheralded leading cooperativity exponent is one half. -/
lemma GroverCavityFidelityScaling.unheralded_exponent
    (scaling : GroverCavityFidelityScaling) :
    scaling.unheraldedExponent = 1 / 2 :=
  scaling.unheraldedExponentLaw

/-- The heralded leading cooperativity exponent is two thirds. -/
lemma GroverCavityFidelityScaling.heralded_exponent
    (scaling : GroverCavityFidelityScaling) :
    scaling.heraldedExponent = 2 / 3 :=
  scaling.heraldedExponentLaw

end Signals.Pending
