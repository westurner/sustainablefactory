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
  nlinarith [profile.identity, sq_nonneg profile.entanglement]

/-- The normalized model bounds the entanglement measure by one. -/
lemma Complementarity.entanglement_le_one (profile : Complementarity) :
    profile.entanglement ≤ 1 := by
  nlinarith [profile.identity, sq_nonneg profile.polarization]

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

/-! ## Finite polarization-entanglement spectra -/

/-- A normalized finite spectrum for the polarization coherence matrix.

The entries represent the normalized eigenvalues `m_i` used in the paper's
arbitrary-dimensional construction. The spectrum is finite data; it does not
assert that a particular optical source or quantum state realizes it. -/
structure CoherenceSpectrum (dimension : ℕ) where
  weight : Fin dimension → ℝ
  weight_nonnegative : ∀ index, 0 ≤ weight index
  normalized : ∑ index, weight index = 1

/-- The squared degree of polarization from a normalized finite spectrum. -/
noncomputable def CoherenceSpectrum.polarizationSquared
    {dimension : ℕ} (spectrum : CoherenceSpectrum dimension) : ℝ :=
  (dimension : ℝ) / ((dimension - 1 : ℕ) : ℝ) *
      ∑ index, (spectrum.weight index) ^ 2 -
    1 / ((dimension - 1 : ℕ) : ℝ)

/-- The squared Schmidt-weight entanglement from a normalized finite spectrum. -/
noncomputable def CoherenceSpectrum.entanglementSquared
    {dimension : ℕ} (spectrum : CoherenceSpectrum dimension) : ℝ :=
  (dimension : ℝ) / ((dimension - 1 : ℕ) : ℝ) *
      (1 - ∑ index, (spectrum.weight index) ^ 2)

/-- The denominator in the normalized $N$-dimensional measures is positive
when there are at least two components. -/
lemma CoherenceSpectrum.denominator_pos
    {dimension : ℕ} (dimension_at_least_two : 2 ≤ dimension) :
    0 < ((dimension - 1 : ℕ) : ℝ) := by
  have natural_pos : 0 < dimension - 1 := by omega
  exact_mod_cast natural_pos

/-- The paper's arbitrary-dimensional squared complementarity identity. -/
lemma CoherenceSpectrum.squared_complementarity
    {dimension : ℕ} (spectrum : CoherenceSpectrum dimension)
    (dimension_at_least_two : 2 ≤ dimension) :
    spectrum.polarizationSquared + spectrum.entanglementSquared = 1 := by
  unfold CoherenceSpectrum.polarizationSquared
    CoherenceSpectrum.entanglementSquared
  have denominator_ne : ((dimension - 1 : ℕ) : ℝ) ≠ 0 :=
    ne_of_gt (CoherenceSpectrum.denominator_pos dimension_at_least_two)
  field_simp [denominator_ne]
  rw [Nat.cast_sub (by omega)]
  ring

/-- Explicit polarization and entanglement values attached to a finite
coherence spectrum. Their squared laws are kept as visible model fields so a
measured or numerical realization cannot be confused with the algebraic
identity itself. -/
structure CoherenceComplementarity (dimension : ℕ) where
  spectrum : CoherenceSpectrum dimension
  polarization : ℝ
  entanglement : ℝ
  polarization_nonnegative : 0 ≤ polarization
  entanglement_nonnegative : 0 ≤ entanglement
  polarization_squared_law : polarization ^ 2 = spectrum.polarizationSquared
  entanglement_squared_law : entanglement ^ 2 = spectrum.entanglementSquared

/-- The finite spectrum model satisfies the paper's $P^2 + K^2 = 1$ relation. -/
lemma CoherenceComplementarity.complementarity_identity
    {dimension : ℕ} (profile : CoherenceComplementarity dimension)
    (dimension_at_least_two : 2 ≤ dimension) :
    profile.polarization ^ 2 + profile.entanglement ^ 2 = 1 := by
  rw [profile.polarization_squared_law, profile.entanglement_squared_law]
  exact profile.spectrum.squared_complementarity dimension_at_least_two

/-- A barycentric inertia mapping for the normalized spectrum model.

The origin-axis inertia and center-axis inertia are related by the
Huygens-Steiner theorem. The two squared optical quantities are recorded as
the corresponding normalized inertia difference and its complement. -/
structure HuygensSteinerMapping where
  axis : ParallelAxis
  originInertia : ℝ
  originInertiaLaw : originInertia = axis.inertia
  normalizedMass : axis.mass = 1
  polarizationSquared : ℝ
  entanglementSquared : ℝ
  polarizationSquared_nonnegative : 0 ≤ polarizationSquared
  entanglementSquared_nonnegative : 0 ≤ entanglementSquared
  polarizationLaw : polarizationSquared = originInertia - axis.centerInertia
  entanglementLaw : entanglementSquared =
    1 - (originInertia - axis.centerInertia)

/-- The Huygens-Steiner mapping preserves the complementary squared identity. -/
lemma HuygensSteinerMapping.complementarity_identity
    (mapping : HuygensSteinerMapping) :
    mapping.polarizationSquared + mapping.entanglementSquared = 1 := by
  rw [mapping.polarizationLaw, mapping.entanglementLaw]
  ring

/-- With unit normalized mass, the polarization squared value equals the
parallel-axis displacement squared. -/
lemma HuygensSteinerMapping.polarization_eq_offset_squared
    (mapping : HuygensSteinerMapping) :
    mapping.polarizationSquared = mapping.axis.offset ^ 2 := by
  rw [mapping.polarizationLaw, mapping.originInertiaLaw,
    ParallelAxis.parallel_axis, mapping.normalizedMass]
  ring

end Signals.Coherence
