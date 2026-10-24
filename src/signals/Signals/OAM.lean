import Architect
import Mathlib.Data.Fintype.BigOperators
import Mathlib.Basic.Complex.Basic
import Mathlib.Tactic

namespace Signals.OAM

/-- A finite-dimensional OAM qudit state with normalized complex amplitudes. -/
@[blueprint "def:signals-oam-qudit"
  (title := "Normalized finite-dimensional OAM qudit state")
  (statement := /-- An OAM qudit of dimension $d$ assigns complex amplitudes $c_m\in\mathbb C$
    to $m\in\operatorname{Fin}(d)$ satisfying $\sum_{m}|c_m|^2=1$. -/)]
structure Qudit (dimension : ℕ) where
  amplitudes : Fin dimension → ℂ
  normalized : ∑ mode, Complex.normSq (amplitudes mode) = 1

/-- The number of computational basis states for several qudits. -/
@[blueprint "def:signals-oam-basis-state-count"
  (title := "Multi-qudit OAM computational basis state count")
  (statement := /-- For $s$ qudits of local OAM dimension $d$, the product Hilbert space has
    $d^s$ computational basis states. -/)]
def basisStateCount (dimension systems : ℕ) : ℕ :=
  dimension ^ systems

/-- Ten qudits with 100 modes each span exactly 10^20 basis states. -/
@[blueprint "lem:signals-oam-basis-100-10"
  (title := "Ten 100-mode OAM qudits span 10^20 basis states")
  (statement := /-- $\operatorname{basisStateCount}(100,10)=10^{20}$. -/)
  (proof := /-- Exact integer exponent arithmetic. -/)
  (latexEnv := "lemma")]
lemma basisStateCount_100_10 : basisStateCount 100 10 = 10 ^ 20 := by
  norm_num [basisStateCount]

/-- Ten 100-level qudits span more basis states than fifty qubits. -/
@[blueprint "lem:signals-oam-basis-gt-50-qubits"
  (title := "Ten 100-mode OAM qudits exceed the state space of 50 qubits")
  (statement := /-- $2^{50} < \operatorname{basisStateCount}(100,10)$. -/)
  (proof := /-- Compare $2^{50}$ and $100^{10}$ by integer arithmetic. -/)
  (latexEnv := "lemma")]
lemma basisStateCount_100_10_gt_2_50 :
    2 ^ 50 < basisStateCount 100 10 := by
  norm_num [basisStateCount]

end Signals.OAM
