import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic
import Mathlib.Tactic
import Signals.IQ

namespace Signals.Sampling

open Signals.IQ

/-- A sampling rate whose value is strictly positive. -/
structure SamplingRate where
  hz : ℝ
  positive : 0 < hz

/-- A nonnegative one-sided bandwidth. -/
structure Bandwidth where
  hz : ℝ
  nonnegative : 0 ≤ hz

/-- The strict Nyquist condition for a bandwidth and sampling rate. -/
def NyquistCondition (bandwidth : Bandwidth) (rate : SamplingRate) : Prop :=
  2 * bandwidth.hz < rate.hz

/-- A frequency lies in a symmetric band around the carrier. -/
def InBand (bandwidth : Bandwidth) (frequency : ℝ) : Prop :=
  |frequency| ≤ bandwidth.hz

/-- The phase of a complex I/Q tone at one sample index. -/
noncomputable def sampleAngle (frequency rate phase : ℝ) (index : ℕ) : ℝ :=
  2 * Real.pi * frequency * (index : ℝ) / rate + phase

/-- A real-amplitude complex tone written as an I/Q sample. -/
noncomputable def toneSample (amplitude frequency rate phase : ℝ) (index : ℕ) : Sample :=
  { inPhase := amplitude * Real.cos (sampleAngle frequency rate phase index)
    quadrature := amplitude * Real.sin (sampleAngle frequency rate phase index) }

/-- A finite sequence of receiver samples. -/
structure SampledSignal (sampleCount : ℕ) where
  values : Fin sampleCount → Sample

/-- Sample a tone at the indices of a finite receiver buffer. -/
noncomputable def sampleTone (sampleCount : ℕ) (amplitude frequency rate phase : ℝ) :
    SampledSignal sampleCount where
  values := fun index => toneSample amplitude frequency rate phase index.val

/-- The finite reconstruction operator returns the recorded samples exactly. -/
def reconstruct (signal : SampledSignal sampleCount) : Fin sampleCount → Sample :=
  signal.values

/-- Reconstruction in the finite sample model is exact by construction. -/
lemma reconstruct_exact (signal : SampledSignal sampleCount) (index : Fin sampleCount) :
    reconstruct signal index = signal.values index := by
  rfl

/-- Frequencies separated by an integer multiple of the sampling rate. -/
def aliasedFrequency (frequency : ℝ) (rate : SamplingRate) (aliasIndex : ℤ) : ℝ :=
  frequency + (aliasIndex : ℝ) * rate.hz

/-- The sample angle changes by an integer number of full turns under aliasing. -/
lemma sampleAngle_aliased (frequency phase : ℝ) (rate : SamplingRate)
    (aliasIndex : ℤ) (index : ℕ) :
    sampleAngle (aliasedFrequency frequency rate aliasIndex) rate.hz phase index =
      sampleAngle frequency rate.hz phase index +
        (aliasIndex * (index : ℤ) : ℝ) * (2 * Real.pi) := by
  unfold sampleAngle aliasedFrequency
  have rate_ne_zero : rate.hz ≠ 0 := ne_of_gt rate.positive
  push_cast
  field_simp [rate_ne_zero]
  ring

/-- Integer-rate aliases produce identical in-phase and quadrature samples. -/
lemma toneSample_aliased (amplitude frequency phase : ℝ) (rate : SamplingRate)
    (aliasIndex : ℤ) (index : ℕ) :
    toneSample amplitude (aliasedFrequency frequency rate aliasIndex) rate.hz phase index =
      toneSample amplitude frequency rate.hz phase index := by
  unfold toneSample
  rw [sampleAngle_aliased frequency phase rate aliasIndex index]
  congr 1
  ·
    exact congrArg (fun value : ℝ => amplitude * value)
      (by
        simpa [Int.cast_mul, mul_assoc] using
          (Real.cos_add_int_mul_two_pi (sampleAngle frequency rate.hz phase index)
            (aliasIndex * (index : ℤ))))
  ·
    exact congrArg (fun value : ℝ => amplitude * value)
      (by
        simpa [Int.cast_mul, mul_assoc] using
          (Real.sin_add_int_mul_two_pi (sampleAngle frequency rate.hz phase index)
            (aliasIndex * (index : ℤ))))

/-- A finite sampled tone is unchanged by a whole-rate frequency alias. -/
lemma sampleTone_aliased (sampleCount : ℕ) (amplitude frequency phase : ℝ)
  (rate : SamplingRate) (aliasIndex : ℤ) :
  sampleTone sampleCount amplitude (aliasedFrequency frequency rate aliasIndex) rate.hz phase =
      sampleTone sampleCount amplitude frequency rate.hz phase := by
  unfold sampleTone
  congr
  funext index
  exact toneSample_aliased amplitude frequency phase rate aliasIndex index.val

/-- Strict Nyquist sampling prevents two in-band frequencies from differing by one rate. -/
lemma no_one_rate_alias {bandwidth : Bandwidth} {rate : SamplingRate}
    (nyquist : NyquistCondition bandwidth rate) {frequency₁ frequency₂ : ℝ}
    (frequency₁_in_band : InBand bandwidth frequency₁)
    (frequency₂_in_band : InBand bandwidth frequency₂)
    (frequency_alias : frequency₂ = frequency₁ + rate.hz) :
    False := by
  unfold NyquistCondition at nyquist
  unfold InBand at frequency₁_in_band frequency₂_in_band
  rw [frequency_alias] at frequency₂_in_band
  rw [abs_le] at frequency₁_in_band frequency₂_in_band
  nlinarith [nyquist, rate.positive]

/-- The strict Nyquist condition is equivalent to the displayed bandwidth inequality. -/
lemma nyquist_condition_iff {bandwidth : Bandwidth} {rate : SamplingRate} :
    NyquistCondition bandwidth rate ↔ 2 * bandwidth.hz < rate.hz := by
  rfl

end Signals.Sampling