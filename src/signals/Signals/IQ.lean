import Mathlib.Analysis.SpecialFunctions.Complex.Arg
import Mathlib.Data.Complex.Basic

namespace Signals.IQ

/-- The sideband sign used by a receiver's carrier mixer. -/
inductive CarrierSideband
  | positive
  | negative
  deriving DecidableEq, Repr

/-- The orientation of the quadrature channel relative to the in-phase channel. -/
inductive QuadratureOrientation
  | standard
  | reversed
  deriving DecidableEq, Repr

/-- A receiver convention for carrier, quadrature, and principal-phase choices. -/
structure Convention where
  carrier : CarrierSideband
  quadrature : QuadratureOrientation
  phaseLower : ℝ
  phaseUpper : ℝ
  phaseRange : phaseLower < phaseUpper

/-- The standard positive-carrier, positive-quadrature convention. -/
noncomputable def standardConvention : Convention where
  carrier := CarrierSideband.positive
  quadrature := QuadratureOrientation.standard
  phaseLower := -Real.pi
  phaseUpper := Real.pi
  phaseRange := by linarith [Real.pi_pos]

/-- One pair of in-phase and quadrature samples from a coherent receiver. -/
structure Sample where
  inPhase : ℝ
  quadrature : ℝ

/-- Apply the selected quadrature orientation to a sample. -/
def Convention.orient (convention : Convention) (sample : Sample) : Sample :=
  match convention.quadrature with
  | QuadratureOrientation.standard => sample
  | QuadratureOrientation.reversed =>
      { inPhase := sample.inPhase, quadrature := -sample.quadrature }

/-- Embed an I/Q sample in the complex baseband plane. -/
def Sample.asComplex (sample : Sample) : ℂ :=
  ⟨sample.inPhase, sample.quadrature⟩

/-- The envelope magnitude of an I/Q sample. -/
noncomputable def Sample.magnitude (sample : Sample) : ℝ :=
  Real.sqrt (Complex.normSq sample.asComplex)

/-- The principal phase represented by an I/Q sample. -/
noncomputable def Sample.phase (sample : Sample) : ℝ :=
  Complex.arg sample.asComplex

/-- The real projection of the complex I/Q representation is the I sample. -/
@[simp] lemma Sample.asComplex_re (sample : Sample) :
    sample.asComplex.re = sample.inPhase := by
  rfl

/-- The imaginary projection of the complex I/Q representation is the Q sample. -/
@[simp] lemma Sample.asComplex_im (sample : Sample) :
    sample.asComplex.im = sample.quadrature := by
  rfl

/-- The squared envelope is the sum of the squared I and Q components. -/
lemma Sample.normSq_eq (sample : Sample) :
    Complex.normSq sample.asComplex =
      sample.inPhase * sample.inPhase + sample.quadrature * sample.quadrature := by
  exact Complex.normSq_mk _ _

/-- The squared envelope of an I/Q sample is nonnegative. -/
lemma Sample.normSq_nonneg (sample : Sample) :
    0 ≤ Complex.normSq sample.asComplex := by
  exact Complex.normSq_nonneg _

/-- An I/Q sample has zero envelope exactly when both channels are zero. -/
lemma Sample.zero_magnitude_iff (sample : Sample) :
    sample.magnitude = 0 ↔ sample.inPhase = 0 ∧ sample.quadrature = 0 := by
  constructor
  · intro h
    rw [Sample.magnitude, Sample.normSq_eq, Real.sqrt_eq_zero'] at h
    constructor <;> nlinarith [sq_nonneg sample.inPhase, sq_nonneg sample.quadrature]
  · rintro ⟨hI, hQ⟩
    simp [Sample.magnitude, Sample.normSq_eq, hI, hQ]

/-- Reversing the quadrature sign preserves the I/Q envelope. -/
lemma Convention.orient_magnitude (convention : Convention) (sample : Sample) :
    (convention.orient sample).magnitude = sample.magnitude := by
  cases convention with
  | mk carrier quadrature phaseLower phaseUpper phaseRange =>
      cases quadrature <;>
        simp [Convention.orient, Sample.magnitude, Sample.normSq_eq]

/-- The complex principal phase uses the half-open interval `(-pi, pi]`. -/
lemma Sample.phase_mem_principal_range (sample : Sample) :
    sample.phase ∈ Set.Ioc (-Real.pi) Real.pi := by
  exact Complex.arg_mem_Ioc sample.asComplex

/-- The phase-to-height conversion for a round-trip wave-number model. -/
noncomputable def heightFromPhase (waveNumber phase : ℝ) : ℝ :=
  phase / (2 * waveNumber)

/-- Convert an I/Q phase to height under the round-trip model. -/
noncomputable def heightFromSample (waveNumber : ℝ) (sample : Sample) : ℝ :=
  heightFromPhase waveNumber sample.phase

/-- The height conversion is the inverse of the round-trip phase relation. -/
lemma heightFromSample_phase (waveNumber : ℝ) (sample : Sample)
    (waveNumber_ne_zero : waveNumber ≠ 0) :
    2 * waveNumber * heightFromSample waveNumber sample = sample.phase := by
  rw [heightFromSample, heightFromPhase]
  field_simp

/-! ## Phase and coherence observables -/

/- The exact principal argument is noncomputable in Mathlib because its
   implementation uses the classical real arcsine function. -/

/-- The I/Q envelope equals the complex norm of the baseband sample. -/
lemma Sample.magnitude_eq_norm (sample : Sample) :
    sample.magnitude = ‖sample.asComplex‖ := by
  rw [Sample.magnitude, Complex.normSq_eq_norm_sq, Real.sqrt_sq_eq_abs,
    abs_of_nonneg (norm_nonneg _)]

/- The two identities below are the phase-reconstruction interface used by
   coherent detection; they avoid treating `arg` as a new physical axiom. -/

/-- The in-phase sample is the envelope times the cosine of its phase. -/
lemma Sample.magnitude_mul_cos_phase (sample : Sample) :
    sample.magnitude * Real.cos sample.phase = sample.inPhase := by
  rw [Sample.magnitude_eq_norm, Sample.phase]
  exact Complex.norm_mul_cos_arg _

/-- The quadrature sample is the envelope times the sine of its phase. -/
lemma Sample.magnitude_mul_sin_phase (sample : Sample) :
    sample.magnitude * Real.sin sample.phase = sample.quadrature := by
  rw [Sample.magnitude_eq_norm, Sample.phase]
  exact Complex.norm_mul_sin_arg _

end Signals.IQ
