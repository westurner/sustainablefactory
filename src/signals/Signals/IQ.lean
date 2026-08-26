import Mathlib.Analysis.SpecialFunctions.Complex.Arg
import Mathlib.Data.Complex.Basic

namespace Signals.IQ

/-- One pair of in-phase and quadrature samples from a coherent receiver. -/
structure Sample where
  inPhase : ℝ
  quadrature : ℝ

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
