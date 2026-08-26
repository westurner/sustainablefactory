import Physlib.Electromagnetism.Vacuum.HarmonicWave

namespace Signals.Physlib

open Electromagnetism

/-- Free-space permittivity and permeability are positive in Physlib's model. -/
lemma freeSpace_constants_positive (space : FreeSpace) :
    0 < space.ε₀ ∧ 0 < space.μ₀ := by
  exact ⟨space.ε₀_pos, space.μ₀_pos⟩

end Signals.Physlib
