import Mathlib.Data.Real.Basic
import Mathlib.Tactic
import Physlib.ClassicalMechanics.RigidBody.Basic

namespace Signals.Coherence

/-! ## Huygens-Steiner and polarization complementarity -/

/--
The two scalar observables used by the complementary polarization/coherence
model. The identity is an explicit model assumption, so it does not claim
that every measured optical field has this form.
-/
structure Complementarity where
  polarization : ℝ
  entanglement : ℝ
  polarization_nonneg : 0 ≤ polarization
  entanglement_nonneg : 0 ≤ entanglement
  identity : polarization ^ 2 + entanglement ^ 2 = 1

/-- The complementary polarization/coherence identity. -/
lemma Complementarity.identity_holds (profile : Complementarity) :
  profile.polarization ^ 2 + profile.entanglement ^ 2 = 1 :=
  profile.identity

/-- The normalized model bounds the degree of polarization by one. -/
lemma Complementarity.polarization_le_one (profile : Complementarity) :
    profile.polarization ≤ 1 := by
  nlinarith [sq_nonneg profile.entanglement]

/-- The normalized model bounds the entanglement measure by one. -/
lemma Complementarity.entanglement_le_one (profile : Complementarity) :
    profile.entanglement ≤ 1 := by
  nlinarith [sq_nonneg profile.polarization]

/-- A scalar parallel-axis model with center-of-mass inertia. -/
structure ParallelAxis where
  centerInertia : ℝ
  mass : ℝ
  offset : ℝ

/-- The inertia about a parallel axis in the scalar model. -/
def ParallelAxis.inertia (axis : ParallelAxis) : ℝ :=
  axis.centerInertia + axis.mass * axis.offset ^ 2

/-- The Huygens-Steiner, or parallel-axis, identity. -/
lemma ParallelAxis.parallel_axis (axis : ParallelAxis) :
    axis.inertia = axis.centerInertia + axis.mass * axis.offset ^ 2 := by
  rfl

/-- A nonnegative mass cannot decrease inertia under a parallel-axis shift. -/
lemma ParallelAxis.centerInertia_le_inertia (axis : ParallelAxis)
    (mass_nonneg : 0 ≤ axis.mass) :
    axis.centerInertia ≤ axis.inertia := by
  rw [ParallelAxis.parallel_axis]
  nlinarith [sq_nonneg axis.offset]

end Signals.Coherence
