import Mathlib.Data.Fintype.BigOperators
import Mathlib.Data.Complex.Basic
import Mathlib.Tactic

namespace Signals.OAM

/-- A finite-dimensional OAM qudit state with normalized complex amplitudes. -/
structure Qudit (dimension : ℕ) where
  amplitudes : Fin dimension → ℂ
  normalized : ∑ mode, Complex.normSq (amplitudes mode) = 1

/-- The number of computational basis states for several qudits. -/
def basisStateCount (dimension systems : ℕ) : ℕ :=
  dimension ^ systems

/-- Ten qudits with 100 modes each span exactly 10^20 basis states. -/
lemma basisStateCount_100_10 : basisStateCount 100 10 = 10 ^ 20 := by
  norm_num [basisStateCount]

/-- Ten 100-level qudits span more basis states than fifty qubits. -/
lemma basisStateCount_100_10_gt_2_50 :
    2 ^ 50 < basisStateCount 100 10 := by
  norm_num [basisStateCount]

end Signals.OAM
