import Mathlib.Data.Real.Basic

namespace Signals.Units

/-- A frequency measured in hertz. -/
structure Frequency where
  hz : ℝ

/-- A length measured in metres. -/
structure Length where
  meters : ℝ

/-- A power measured in watts. -/
structure Power where
  watts : ℝ

/-- Construct a frequency from a value expressed in gigahertz. -/
def gigahertz (value : ℝ) : Frequency :=
  { hz := value * 10 ^ 9 }

/-- The representation of 400 GHz in hertz. -/
lemma gigahertz_400_hz : (gigahertz 400).hz = 400 * 10 ^ 9 := by
  rfl

end Signals.Units
