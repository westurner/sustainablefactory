import Architect
import Mathlib.Basic.Real.Basic
import Mathlib.Tactic
import Physlib.ClassicalMechanics.RigidBody.Basic

namespace Signals.Coherence

/-! ## Huygens-Steiner and polarization complementarity -/

/--
The two scalar observables used by the complementary polarization/coherence
model. The identity is an explicit model assumption, so it does not claim
that every measured optical field has this form.
-/
@[blueprint "def:signals-coherence-complementarity-pair"
  (title := "Normalized polarization-entanglement complementarity pair")
  (statement := /-- Records nonnegative polarization $P\ge 0$ and entanglement $K\ge 0$
    satisfying $P^2+K^2=1$. -/)]
structure Complementarity where
  polarization : ℝ
  entanglement : ℝ
  polarization_nonneg : 0 ≤ polarization
  entanglement_nonneg : 0 ≤ entanglement
  identity : polarization ^ 2 + entanglement ^ 2 = 1

/-- The complementary polarization/coherence identity. -/
@[blueprint "lem:signals-coherence-complementarity-holds"
  (title := "Pythagorean polarization-entanglement complementarity identity")
  (statement := /-- In any \texttt{Complementarity} record, $P^2+K^2=1$. -/)
  (proof := /-- Apply \texttt{identity}. -/)
  (latexEnv := "lemma")]
lemma Complementarity.identity_holds (profile : Complementarity) :
  profile.polarization ^ 2 + profile.entanglement ^ 2 = 1 :=
  profile.identity

/-- The normalized model bounds the degree of polarization by one. -/
@[blueprint "lem:signals-coherence-polarization-le-one"
  (title := "Upper bound on normalized degree of polarization")
  (statement := /-- When $P^2+K^2=1$, $P\le 1$. -/)
  (proof := /-- Nonlinear arithmetic from $P^2+K^2=1$ and $K^2\ge 0$. -/)
  (latexEnv := "lemma")]
lemma Complementarity.polarization_le_one (profile : Complementarity) :
    profile.polarization ≤ 1 := by
  nlinarith [profile.identity, sq_nonneg profile.entanglement]

/-- The normalized model bounds the entanglement measure by one. -/
@[blueprint "lem:signals-coherence-entanglement-le-one"
  (title := "Upper bound on normalized entanglement measure")
  (statement := /-- When $P^2+K^2=1$, $K\le 1$. -/)
  (proof := /-- Nonlinear arithmetic from $P^2+K^2=1$ and $P^2\ge 0$. -/)
  (latexEnv := "lemma")]
lemma Complementarity.entanglement_le_one (profile : Complementarity) :
    profile.entanglement ≤ 1 := by
  nlinarith [profile.identity, sq_nonneg profile.polarization]

/-- A scalar parallel-axis model with center-of-mass inertia. -/
@[blueprint "def:signals-coherence-parallel-axis"
  (title := "Scalar Huygens--Steiner parallel-axis model")
  (statement := /-- Records center-of-mass moment of inertia $I_{\mathrm{cm}}$, total mass $m$,
    and parallel-axis displacement $d$. -/)]
structure ParallelAxis where
  centerInertia : ℝ
  mass : ℝ
  offset : ℝ

/-- The inertia about a parallel axis in the scalar model. -/
@[blueprint "def:signals-coherence-parallel-axis-inertia"
  (title := "Parallel-axis shifted moment of inertia")
  (statement := /-- Defines $I = I_{\mathrm{cm}} + m d^2$. -/)]
def ParallelAxis.inertia (axis : ParallelAxis) : ℝ :=
  axis.centerInertia + axis.mass * axis.offset ^ 2

/-- The Huygens-Steiner, or parallel-axis, identity. -/
@[blueprint "lem:signals-coherence-parallel-axis-eq"
  (title := "Huygens--Steiner parallel-axis theorem")
  (statement := /-- For any \texttt{ParallelAxis} record, $I = I_{\mathrm{cm}} + m d^2$. -/)
  (proof := /-- Definitional equality. -/)
  (latexEnv := "lemma")]
lemma ParallelAxis.parallel_axis (axis : ParallelAxis) :
    axis.inertia = axis.centerInertia + axis.mass * axis.offset ^ 2 := by
  rfl

/-- A nonnegative mass cannot decrease inertia under a parallel-axis shift. -/
@[blueprint "lem:signals-coherence-center-inertia-le"
  (title := "Parallel-axis shift is nondecreasing for nonnegative mass")
  (statement := /-- When $m\ge 0$, $I_{\mathrm{cm}}\le I_{\mathrm{cm}}+m d^2$. -/)
  (proof := /-- Add the nonnegative term $m d^2\ge 0$. -/)
  (latexEnv := "lemma")]
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
@[blueprint "def:signals-coherence-spectrum"
  (title := "Normalized finite polarization coherence spectrum")
  (statement := /-- A finite vector of nonnegative eigenvalues $m_i\ge 0$ summing to $1$. -/)]
structure CoherenceSpectrum (dimension : ℕ) where
  weight : Fin dimension → ℝ
  weight_nonnegative : ∀ index, 0 ≤ weight index
  normalized : ∑ index, weight index = 1

/-- The squared degree of polarization from a normalized finite spectrum. -/
@[blueprint "def:signals-coherence-spectrum-polarization-sq"
  (title := "Squared degree of polarization of a coherence spectrum")
  (statement := /-- Defines $P_N^2=\frac{N}{N-1}\sum_i m_i^2 - \frac{1}{N-1}$. -/)]
noncomputable def CoherenceSpectrum.polarizationSquared
    {dimension : ℕ} (spectrum : CoherenceSpectrum dimension) : ℝ :=
  (dimension : ℝ) / ((dimension - 1 : ℕ) : ℝ) *
      ∑ index, (spectrum.weight index) ^ 2 -
    1 / ((dimension - 1 : ℕ) : ℝ)

/-- The squared Schmidt-weight entanglement from a normalized finite spectrum. -/
@[blueprint "def:signals-coherence-spectrum-entanglement-sq"
  (title := "Squared Schmidt-weight entanglement of a coherence spectrum")
  (statement := /-- Defines $K_N^2=\frac{N}{N-1}(1-\sum_i m_i^2)$. -/)]
noncomputable def CoherenceSpectrum.entanglementSquared
    {dimension : ℕ} (spectrum : CoherenceSpectrum dimension) : ℝ :=
  (dimension : ℝ) / ((dimension - 1 : ℕ) : ℝ) *
      (1 - ∑ index, (spectrum.weight index) ^ 2)

/-- The denominator in the normalized $N$-dimensional measures is positive
when there are at least two components. -/
@[blueprint "lem:signals-coherence-spectrum-denom-pos"
  (title := "Positivity of N-dimensional coherence normalization denominator")
  (statement := /-- When $N\ge 2$, $N-1>0$. -/)
  (proof := /-- Integer arithmetic cast to $\mathbb R$. -/)
  (latexEnv := "lemma")]
lemma CoherenceSpectrum.denominator_pos
    {dimension : ℕ} (dimension_at_least_two : 2 ≤ dimension) :
    0 < ((dimension - 1 : ℕ) : ℝ) := by
  have natural_pos : 0 < dimension - 1 := by omega
  exact_mod_cast natural_pos

/-- The paper's arbitrary-dimensional squared complementarity identity. -/
@[blueprint "thm:signals-coherence-spectrum-complementarity"
  (title := "Arbitrary-dimensional squared polarization-entanglement complementarity")
  (statement := /-- For any $N\ge 2$ and normalized \texttt{CoherenceSpectrum},
    $P_N^2+K_N^2=1$. -/)
  (proof := /-- Clear the positive denominator $N-1>0$ and cancel $\sum_i m_i^2$ terms. -/)]
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
@[blueprint "def:signals-coherence-complementarity-spectrum"
  (title := "Spectrum-backed polarization-entanglement complementarity record")
  (statement := /-- Attaches nonnegative $P,K$ to a \texttt{CoherenceSpectrum} with
    $P^2=P_N^2$ and $K^2=K_N^2$. -/)]
structure CoherenceComplementarity (dimension : ℕ) where
  spectrum : CoherenceSpectrum dimension
  polarization : ℝ
  entanglement : ℝ
  polarization_nonnegative : 0 ≤ polarization
  entanglement_nonnegative : 0 ≤ entanglement
  polarization_squared_law : polarization ^ 2 = spectrum.polarizationSquared
  entanglement_squared_law : entanglement ^ 2 = spectrum.entanglementSquared

/-- The finite spectrum model satisfies the paper's $P^2 + K^2 = 1$ relation. -/
@[blueprint "lem:signals-coherence-complementarity-spectrum-id"
  (title := "Spectrum-backed complementarity satisfies P² + K² = 1")
  (statement := /-- For $N\ge 2$, any \texttt{CoherenceComplementarity} record obeys $P^2+K^2=1$. -/)
  (proof := /-- Rewrite $P^2,K^2$ to spectrum values and apply \texttt{squared\_complementarity}. -/)
  (latexEnv := "lemma")]
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
@[blueprint "def:signals-coherence-huygens-steiner-mapping"
  (title := "Barycentric Huygens--Steiner optical coherence mapping")
  (statement := /-- Maps unit-mass parallel-axis inertia shift $I_{\mathrm{origin}}-I_{\mathrm{cm}}=d^2$
    to squared polarization $P^2$ and its complement $1-(I_{\mathrm{origin}}-I_{\mathrm{cm}})$
    to squared entanglement/visibility $K^2$. -/)]
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
@[blueprint "lem:signals-coherence-huygens-steiner-complementarity"
  (title := "Huygens--Steiner mapping preserves P² + K² = 1")
  (statement := /-- In any \texttt{HuygensSteinerMapping}, $P^2+K^2=1$. -/)
  (proof := /-- Substitute \texttt{polarizationLaw} and \texttt{entanglementLaw} and cancel. -/)
  (latexEnv := "lemma")]
lemma HuygensSteinerMapping.complementarity_identity
    (mapping : HuygensSteinerMapping) :
    mapping.polarizationSquared + mapping.entanglementSquared = 1 := by
  rw [mapping.polarizationLaw, mapping.entanglementLaw]
  ring

/-- With unit normalized mass, the polarization squared value equals the
parallel-axis displacement squared. -/
@[blueprint "thm:signals-coherence-polarization-eq-offset-sq"
  (title := "Squared polarization equals squared Huygens--Steiner parallel-axis offset")
  (statement := /-- In any unit-mass \texttt{HuygensSteinerMapping}, $P^2 = d^2$. -/)
  (proof := /-- Substitute $I_{\mathrm{origin}}=I_{\mathrm{cm}}+m d^2$ and $m=1$. -/)]
lemma HuygensSteinerMapping.polarization_eq_offset_squared
    (mapping : HuygensSteinerMapping) :
    mapping.polarizationSquared = mapping.axis.offset ^ 2 := by
  rw [mapping.polarizationLaw, mapping.originInertiaLaw,
    ParallelAxis.parallel_axis, mapping.normalizedMass]
  ring

/-- For a binary ($N = 2$) coherence spectrum (`CoherenceSpectrum 2`, e.g. two slits
with normalized weights $m_0 + m_1 = 1$ in Qian & Izadi, *Phys. Rev. Research* 5,
033110 (2023)), the squared degree of polarization equals the squared weight
imbalance $(m_0 - m_1)^2$ and the squared Schmidt entanglement/visibility equals
$4 m_0 m_1$. -/
@[blueprint "thm:signals-coherence-binary-spectrum-weights"
  (title := "Binary N=2 Qian--Izadi coherence spectrum imbalance and visibility laws")
  (statement := /-- For any $N=2$ \texttt{CoherenceSpectrum} with $m_0+m_1=1$,
    $P_2^2=(m_0-m_1)^2$ and $K_2^2=4 m_0 m_1$. -/)
  (proof := /-- Expand $\sum_{i\in\operatorname{Fin}(2)} m_i = m_0+m_1=1$ and
    $\sum_{i\in\operatorname{Fin}(2)} m_i^2 = m_0^2+m_1^2$, then close by ring algebra. -/)]
theorem CoherenceSpectrum.binary_polarization_and_entanglement
    (spectrum : CoherenceSpectrum 2) :
    spectrum.polarizationSquared = (spectrum.weight 0 - spectrum.weight 1) ^ 2 ∧
      spectrum.entanglementSquared = 4 * spectrum.weight 0 * spectrum.weight 1 := by
  have h_norm : spectrum.weight 0 + spectrum.weight 1 = 1 := by
    simpa [Fin.sum_univ_two] using spectrum.normalized
  have h_w1 : spectrum.weight 1 = 1 - spectrum.weight 0 := by linarith [h_norm]
  have h_sum_sq :
      (∑ index : Fin 2, (spectrum.weight index) ^ 2) =
        (spectrum.weight 0) ^ 2 + (spectrum.weight 1) ^ 2 := by
    simp [Fin.sum_univ_two]
  constructor
  · unfold CoherenceSpectrum.polarizationSquared
    rw [h_sum_sq, h_w1]
    norm_num
    ring
  · unfold CoherenceSpectrum.entanglementSquared
    rw [h_sum_sq, h_w1]
    norm_num
    ring

end Signals.Coherence
