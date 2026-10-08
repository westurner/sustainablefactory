import Mathlib.Basic.Complex.Basic
import Signals.Plabic
import Mathlib.LinearAlgebra.Matrix.Determinant.Basic
import Mathlib.Tactic

namespace Signals.Geometry

/-- A two-component complex Weyl spinor as algebraic data. -/
structure WeylSpinor where
  first : ℂ
  second : ℂ

/-- The antisymmetric spinor contraction. -/
def angleBracket (left right : WeylSpinor) : ℂ :=
  left.first * right.second - left.second * right.first

/-- Swapping the spinors reverses the angle bracket. -/
lemma angleBracket_swap (left right : WeylSpinor) :
    angleBracket left right = -angleBracket right left := by
  simp [angleBracket]
  ring

/-- A spinor has zero angle bracket with itself. -/
lemma angleBracket_self (spinor : WeylSpinor) :
    angleBracket spinor spinor = 0 := by
  simp [angleBracket]
  ring

/-- Twistor data represented by a pair of Weyl spinors. -/
structure Twistor where
  lambda : WeylSpinor
  mu : WeylSpinor

/-! ## Finite Grassmannian coordinates

The unrestricted matrix record deliberately permits negative Pluecker
coordinates. Positivity is an additional chart condition, not part of the
underlying linear-algebra data.
-/

/-- A strictly ordered selection of `k` columns from `n` columns. -/
structure OrderedColumns (k n : ℕ) where
  index : Fin k → Fin n
  strictlyIncreasing : StrictMono index

/-- A single column is an ordered selection without a vacuous rank assertion. -/
def OrderedColumns.single {n : ℕ} (column : Fin n) : OrderedColumns 1 n :=
  { index := fun _ => column
    strictlyIncreasing := by
      intro first second before
      have equal : first = second := Subsingleton.elim _ _
      subst second
      exact False.elim ((lt_irrefl first) before) }

/-- A finite matrix representing a point before any positivity restriction. -/
structure GrassmannianMatrix (k n : ℕ) where
  mat : Matrix (Fin k) (Fin n) ℝ

/-- The maximal minor selected by an ordered list of columns. -/
def selectedMinor {k n : ℕ}
    (matrix : Matrix (Fin k) (Fin n) ℝ) (columns : OrderedColumns k n) : ℝ :=
  (matrix.submatrix id columns.index).det

/-- The Pluecker coordinate of an ordered column selection. -/
def GrassmannianMatrix.pluckerCoordinate
    {k n : ℕ} (grassmannian : GrassmannianMatrix k n)
    (columns : OrderedColumns k n) : ℝ :=
  selectedMinor grassmannian.mat columns

/-- Left multiplication by a row basis matrix scales every maximal minor by its determinant. -/
lemma selectedMinor_basisChange {k n : ℕ} (basis : Matrix (Fin k) (Fin k) ℝ)
    (matrix : Matrix (Fin k) (Fin n) ℝ) (columns : OrderedColumns k n) :
    selectedMinor (basis * matrix) columns = basis.det * selectedMinor matrix columns := by
  have selection : (basis * matrix).submatrix id columns.index =
      basis * matrix.submatrix id columns.index := by
    ext row column
    simp [Matrix.mul_apply, Matrix.submatrix]
  rw [selectedMinor, selection, Matrix.det_mul]
  rfl

/-- Change the row representative without quotienting by the basis action. -/
def GrassmannianMatrix.changeBasis {k n : ℕ} (grassmannian : GrassmannianMatrix k n)
    (basis : Matrix (Fin k) (Fin k) ℝ) : GrassmannianMatrix k n :=
  ⟨basis * grassmannian.mat⟩

/-- Every Pluecker coordinate transforms by the same determinant factor. -/
lemma GrassmannianMatrix.pluckerCoordinate_basisChange {k n : ℕ}
    (grassmannian : GrassmannianMatrix k n) (basis : Matrix (Fin k) (Fin k) ℝ)
    (columns : OrderedColumns k n) :
    (grassmannian.changeBasis basis).pluckerCoordinate columns =
      basis.det * grassmannian.pluckerCoordinate columns :=
  selectedMinor_basisChange basis grassmannian.mat columns

/-- Pluecker ratios are invariant under any nonsingular row basis change, including orientation reversal. -/
lemma GrassmannianMatrix.pluckerRatio_basisChange {k n : ℕ}
    (grassmannian : GrassmannianMatrix k n) (basis : Matrix (Fin k) (Fin k) ℝ)
    (nonsingular : basis.det ≠ 0) (first second : OrderedColumns k n) :
    (grassmannian.changeBasis basis).pluckerCoordinate first /
        (grassmannian.changeBasis basis).pluckerCoordinate second =
      grassmannian.pluckerCoordinate first / grassmannian.pluckerCoordinate second := by
  rw [grassmannian.pluckerCoordinate_basisChange, grassmannian.pluckerCoordinate_basisChange]
  exact mul_div_mul_left _ _ nonsingular

/-- Every ordered maximal minor is strictly positive. -/
def GrassmannianMatrix.hasPositiveOrderedMinors
    {k n : ℕ} (grassmannian : GrassmannianMatrix k n) : Prop :=
  ∀ columns : OrderedColumns k n,
    0 < grassmannian.pluckerCoordinate columns

/-- The positive Grassmannian condition, isolated from unrestricted matrices. -/
structure PositiveGrassmannian (k n : ℕ)
    extends GrassmannianMatrix k n where
  strictly_positive : toGrassmannianMatrix.hasPositiveOrderedMinors

lemma PositiveGrassmannian.pluckerCoordinate_pos
    {k n : ℕ} (grassmannian : PositiveGrassmannian k n)
    (columns : OrderedColumns k n) :
    0 < grassmannian.toGrassmannianMatrix.pluckerCoordinate columns :=
  grassmannian.strictly_positive columns

/-- The linear projection selecting the ordered columns of a row vector. -/
def OrderedColumns.projection {k n : ℕ} (columns : OrderedColumns k n) :
    (Fin n → ℝ) →ₗ[ℝ] (Fin k → ℝ) where
  toFun row := row ∘ columns.index
  map_add' _ _ := rfl
  map_smul' _ _ := rfl

/-- The selected determinant as an alternating map on the matrix rows. -/
def pluckerAlternating {k n : ℕ} (columns : OrderedColumns k n) :
    AlternatingMap ℝ (Fin n → ℝ) ℝ (Fin k) :=
  Matrix.detRowAlternating.compLinearMap columns.projection

/-- The alternating-map construction agrees with the existing maximal minor. -/
lemma pluckerAlternating_eq_selectedMinor {k n : ℕ}
    (columns : OrderedColumns k n) (matrix : Matrix (Fin k) (Fin n) ℝ) :
    pluckerAlternating columns matrix = selectedMinor matrix columns := rfl

/-- Exchanging distinct rows negates the selected Pluecker coordinate. -/
lemma selectedMinor_swap_rows {k n : ℕ}
    (matrix : Matrix (Fin k) (Fin n) ℝ) (columns : OrderedColumns k n)
    {left right : Fin k} (distinct : left ≠ right) :
    selectedMinor (matrix ∘ Equiv.swap left right) columns =
      -selectedMinor matrix columns :=
  (pluckerAlternating columns).map_swap matrix distinct

/-- Equal distinct rows force every maximal minor to vanish. -/
lemma selectedMinor_eq_zero_of_rows_eq {k n : ℕ}
    (matrix : Matrix (Fin k) (Fin n) ℝ) (columns : OrderedColumns k n)
    {left right : Fin k} (equal : matrix left = matrix right) (distinct : left ≠ right) :
    selectedMinor matrix columns = 0 :=
  (pluckerAlternating columns).map_eq_zero_of_eq matrix equal distinct

/-- All ordered maximal minors are nonnegative, including boundary zeros. -/
def GrassmannianMatrix.hasNonnegativeOrderedMinors {k n : ℕ}
    (grassmannian : GrassmannianMatrix k n) : Prop :=
  ∀ columns : OrderedColumns k n, 0 ≤ grassmannian.pluckerCoordinate columns

/-- A full-rank nonnegative representative, not a quotient by change of basis. -/
structure NonnegativeGrassmannian (k n : ℕ) extends GrassmannianMatrix k n where
  nonnegative : toGrassmannianMatrix.hasNonnegativeOrderedMinors
  nonzero_minor : ∃ columns : OrderedColumns k n,
    toGrassmannianMatrix.pluckerCoordinate columns ≠ 0

/-- Nonnegative representatives allow a minor to vanish on a boundary. -/
lemma NonnegativeGrassmannian.pluckerCoordinate_nonnegative {k n : ℕ}
    (grassmannian : NonnegativeGrassmannian k n) (columns : OrderedColumns k n) :
    0 ≤ grassmannian.toGrassmannianMatrix.pluckerCoordinate columns :=
  grassmannian.nonnegative columns

/-- An available ordered minor makes a positive representative nonnegative and full-rank. -/
def PositiveGrassmannian.toNonnegative {k n : ℕ}
    (grassmannian : PositiveGrassmannian k n) (columns : OrderedColumns k n) :
    NonnegativeGrassmannian k n :=
  { toGrassmannianMatrix := grassmannian.toGrassmannianMatrix
    nonnegative := fun selection => le_of_lt (grassmannian.strictly_positive selection)
    nonzero_minor := ⟨columns, ne_of_gt (grassmannian.strictly_positive columns)⟩ }

/-- Orientation-preserving basis changes preserve positive representatives. -/
def PositiveGrassmannian.changeBasis {k n : ℕ} (grassmannian : PositiveGrassmannian k n)
    (basis : Matrix (Fin k) (Fin k) ℝ) (orientation : 0 < basis.det) : PositiveGrassmannian k n :=
  { toGrassmannianMatrix := grassmannian.toGrassmannianMatrix.changeBasis basis
    strictly_positive := by
      intro columns
      rw [GrassmannianMatrix.pluckerCoordinate_basisChange]
      exact mul_pos orientation (grassmannian.strictly_positive columns) }

/-- Orientation-preserving changes also preserve boundary zeros and a full-rank witness. -/
def NonnegativeGrassmannian.changeBasis {k n : ℕ} (grassmannian : NonnegativeGrassmannian k n)
    (basis : Matrix (Fin k) (Fin k) ℝ) (orientation : 0 < basis.det) : NonnegativeGrassmannian k n :=
  { toGrassmannianMatrix := grassmannian.toGrassmannianMatrix.changeBasis basis
    nonnegative := by
      intro columns
      rw [GrassmannianMatrix.pluckerCoordinate_basisChange]
      exact mul_nonneg (le_of_lt orientation) (grassmannian.nonnegative columns)
    nonzero_minor := by
      obtain ⟨columns, nonzero⟩ := grassmannian.nonzero_minor
      refine ⟨columns, ?_⟩
      rw [GrassmannianMatrix.pluckerCoordinate_basisChange]
      exact mul_ne_zero (ne_of_gt orientation) nonzero }

/-- A negative determinant reverses every positive minor, so positivity is not invariant under GL(k). -/
lemma PositiveGrassmannian.not_positive_of_det_neg {k n : ℕ}
    (grassmannian : PositiveGrassmannian k n) (basis : Matrix (Fin k) (Fin k) ℝ)
    (orientation : basis.det < 0) (columns : OrderedColumns k n) :
    ¬(grassmannian.toGrassmannianMatrix.changeBasis basis).hasPositiveOrderedMinors := by
  intro positive
  have alleged := positive columns
  rw [GrassmannianMatrix.pluckerCoordinate_basisChange] at alleged
  exact (not_lt_of_gt (mul_neg_of_neg_of_pos orientation (grassmannian.strictly_positive columns)))
    alleged

/-- A normalized one-dimensional positive cell with representative [t, 1-t]. -/
def PositiveGrassmannian.intervalCell (coordinate : ℝ) (lower : 0 < coordinate)
    (upper : coordinate < 1) : PositiveGrassmannian 1 2 :=
  { mat := !![coordinate, 1 - coordinate]
    strictly_positive := by
      intro columns
      rw [GrassmannianMatrix.pluckerCoordinate, selectedMinor, Matrix.det_fin_one]
      change 0 < (!![coordinate, 1 - coordinate] : Matrix (Fin 1) (Fin 2) ℝ) 0 (columns.index 0)
      generalize columns.index 0 = column
      fin_cases column
      · simpa using lower
      · simpa using sub_pos.mpr upper }

open scoped NNReal

/-- The actual fork boundary row, converted from nonnegative weights to a real representative. -/
noncomputable def forkRepresentative (firstWeight secondWeight : ℝ≥0) : GrassmannianMatrix 1 2 :=
  { mat := fun row column =>
      ((Signals.Plabic.WeightedAcyclicNetwork.fork firstWeight secondWeight).boundaryMeasurement
        (fun _ : Fin 1 => 0) Fin.succ row column : ℝ) }

/-- Both fork columns are derived from finite boundary measurements rather than supplied minors. -/
lemma forkRepresentative_mat (firstWeight secondWeight : ℝ≥0) :
    (forkRepresentative firstWeight secondWeight).mat = !![(firstWeight : ℝ), (secondWeight : ℝ)] := by
  unfold forkRepresentative
  rw [Signals.Plabic.WeightedAcyclicNetwork.fork_boundary]
  apply Matrix.ext
  intro row column
  fin_cases row
  fin_cases column <;> rfl

/-- Two positive fork weights yield a positive one-row representative. -/
noncomputable def forkPositive (firstWeight secondWeight : ℝ≥0)
    (firstPositive : 0 < firstWeight) (secondPositive : 0 < secondWeight) : PositiveGrassmannian 1 2 :=
  { toGrassmannianMatrix := forkRepresentative firstWeight secondWeight
    strictly_positive := by
      intro columns
      rw [GrassmannianMatrix.pluckerCoordinate, selectedMinor, forkRepresentative_mat,
        Matrix.det_fin_one]
      change 0 < (!![(firstWeight : ℝ), (secondWeight : ℝ)] : Matrix (Fin 1) (Fin 2) ℝ)
        0 (columns.index 0)
      generalize columns.index 0 = column
      fin_cases column
      · exact_mod_cast firstPositive
      · exact_mod_cast secondPositive }

/-- A nonzero branch supplies the nonzero-minor witness for a nonnegative fork representative. -/
noncomputable def forkNonnegative (firstWeight secondWeight : ℝ≥0)
    (active : firstWeight ≠ 0 ∨ secondWeight ≠ 0) : NonnegativeGrassmannian 1 2 :=
  { toGrassmannianMatrix := forkRepresentative firstWeight secondWeight
    nonnegative := by
      intro columns
      rw [GrassmannianMatrix.pluckerCoordinate, selectedMinor, forkRepresentative_mat,
        Matrix.det_fin_one]
      change 0 ≤ (!![(firstWeight : ℝ), (secondWeight : ℝ)] : Matrix (Fin 1) (Fin 2) ℝ)
        0 (columns.index 0)
      generalize columns.index 0 = column
      fin_cases column
      · exact firstWeight.property
      · exact secondWeight.property
    nonzero_minor := by
      rcases active with firstActive | secondActive
      · refine ⟨OrderedColumns.single 0, ?_⟩
        rw [GrassmannianMatrix.pluckerCoordinate, selectedMinor, forkRepresentative_mat,
          Matrix.det_fin_one]
        change (firstWeight : ℝ) ≠ 0
        exact_mod_cast firstActive
      · refine ⟨OrderedColumns.single 1, ?_⟩
        rw [GrassmannianMatrix.pluckerCoordinate, selectedMinor, forkRepresentative_mat,
          Matrix.det_fin_one]
        change (secondWeight : ℝ) ≠ 0
        exact_mod_cast secondActive }

/-- The actual two-channel boundary matrix with nonnegative entries converted to real scalars. -/
noncomputable def twoChannelRepresentative
    (firstFirst firstSecond secondFirst secondSecond : ℝ≥0) : GrassmannianMatrix 2 2 :=
  { mat := fun row column =>
      ((Signals.Plabic.WeightedAcyclicNetwork.twoChannel
        firstFirst firstSecond secondFirst secondSecond).boundaryMeasurement
        (Fin.castAdd 2) (Fin.natAdd 2) row column : ℝ) }

/-- The real representative retains all four entries of the measured two-channel boundary matrix. -/
lemma twoChannelRepresentative_mat (firstFirst firstSecond secondFirst secondSecond : ℝ≥0) :
    (twoChannelRepresentative firstFirst firstSecond secondFirst secondSecond).mat =
      !![(firstFirst : ℝ), (firstSecond : ℝ); (secondFirst : ℝ), (secondSecond : ℝ)] := by
  unfold twoChannelRepresentative
  rw [Signals.Plabic.WeightedAcyclicNetwork.twoChannel_boundary]
  apply Matrix.ext
  intro row column
  fin_cases row <;> fin_cases column <;> rfl

/-- The two-channel determinant is the signed difference of the two source/sink pair products. -/
lemma twoChannelRepresentative_det (firstFirst firstSecond secondFirst secondSecond : ℝ≥0) :
    (twoChannelRepresentative firstFirst firstSecond secondFirst secondSecond).mat.det =
      (firstFirst : ℝ) * (secondSecond : ℝ) - (firstSecond : ℝ) * (secondFirst : ℝ) := by
  rw [twoChannelRepresentative_mat, Matrix.det_fin_two]
  rfl

/-- Positive measured determinant requires ordered-product dominance, not just positive entries. -/
lemma twoChannelRepresentative_det_pos_iff
    (firstFirst firstSecond secondFirst secondSecond : ℝ≥0) :
    0 < (twoChannelRepresentative firstFirst firstSecond secondFirst secondSecond).mat.det ↔
      (firstSecond : ℝ) * (secondFirst : ℝ) < (firstFirst : ℝ) * (secondSecond : ℝ) := by
  rw [twoChannelRepresentative_det, sub_pos]

/-- The actual shared-hub boundary matrix converted from nonnegative weights to real entries. -/
noncomputable def singleHubRepresentative (firstIn secondIn firstOut secondOut : ℝ≥0) :
    GrassmannianMatrix 2 2 :=
  { mat := fun row column =>
      ((Signals.Plabic.WeightedAcyclicNetwork.singleHub
        firstIn secondIn firstOut secondOut).boundaryMeasurement
        (Fin.castAdd 3) (Fin.natAdd 3) row column : ℝ) }

/-- The shared hub produces an incoming/outgoing product matrix from its finite path sums. -/
lemma singleHubRepresentative_mat (firstIn secondIn firstOut secondOut : ℝ≥0) :
    (singleHubRepresentative firstIn secondIn firstOut secondOut).mat =
      !![(firstIn : ℝ) * (firstOut : ℝ), (firstIn : ℝ) * (secondOut : ℝ);
        (secondIn : ℝ) * (firstOut : ℝ), (secondIn : ℝ) * (secondOut : ℝ)] := by
  unfold singleHubRepresentative
  rw [Signals.Plabic.WeightedAcyclicNetwork.singleHub_boundary]
  apply Matrix.ext
  intro row column
  fin_cases row <;> fin_cases column <;> rfl

/-- The two signed path-pair products through the shared hub cancel for every choice of edge weights. -/
lemma singleHubRepresentative_det (firstIn secondIn firstOut secondOut : ℝ≥0) :
    (singleHubRepresentative firstIn secondIn firstOut secondOut).mat.det = 0 := by
  rw [singleHubRepresentative_mat, Matrix.det_fin_two]
  dsimp
  ring

/-- A two-step two-channel determinant expands as signed pairs of intermediate-vertex terms. -/
lemma twoStep_det_pathPairs {middleCount : ℕ}
    (incoming : Matrix (Fin 2) (Fin middleCount) ℝ)
    (outgoing : Matrix (Fin middleCount) (Fin 2) ℝ) :
    (incoming * outgoing).det =
      ∑ first, ∑ second, incoming 0 first * incoming 1 second *
        (outgoing first 0 * outgoing second 1 - outgoing first 1 * outgoing second 0) := by
  rw [Matrix.det_fin_two]
  simp only [Matrix.mul_apply]
  rw [Finset.sum_mul_sum, Finset.sum_mul_sum, ← Finset.sum_sub_distrib]
  apply Finset.sum_congr rfl
  intro first _
  rw [← Finset.sum_sub_distrib]
  apply Finset.sum_congr rfl
  intro second _
  ring

/-- A repeated intermediate vertex contributes zero to the signed path-pair expansion. -/
lemma twoStep_sameMiddle_term {middleCount : ℕ}
    (incoming : Matrix (Fin 2) (Fin middleCount) ℝ)
    (outgoing : Matrix (Fin middleCount) (Fin 2) ℝ) (middle : Fin middleCount) :
    incoming 0 middle * incoming 1 middle *
      (outgoing middle 0 * outgoing middle 1 - outgoing middle 1 * outgoing middle 0) = 0 := by
  ring

/-! ## Massive spinor-helicity bookkeeping

The records below expose the massive replacement for the massless
factorization used in the source chat. They state on-shell and factorization
conditions as supplied data; they do not assert that an experimental field is
described by this representation.
-/

/-- A real four-momentum in the mostly-minus metric convention. -/
structure FourMomentum where
  energy : ℝ
  px : ℝ
  py : ℝ
  pz : ℝ
  mass : ℝ
  mass_nonnegative : 0 ≤ mass
  mass_shell : energy ^ 2 - px ^ 2 - py ^ 2 - pz ^ 2 = mass ^ 2

/-- The momentum bispinor in a fixed Pauli-matrix convention. -/
def FourMomentum.bispinor (momentum : FourMomentum) :
    Matrix (Fin 2) (Fin 2) ℂ :=
  fun row column =>
    if row = 0 then
      if column = 0 then
        ((momentum.energy + momentum.pz : ℝ) : ℂ)
      else
        (momentum.px : ℂ) - Complex.I * (momentum.py : ℂ)
    else if column = 0 then
      (momentum.px : ℂ) + Complex.I * (momentum.py : ℂ)
    else
      ((momentum.energy - momentum.pz : ℝ) : ℂ)

/-- The two-component coordinate function used in a spinor outer product. -/
def WeylSpinor.component (spinor : WeylSpinor) (index : Fin 2) : ℂ :=
  if index = 0 then spinor.first else spinor.second

/-- Construct a Weyl spinor from its two complex components. -/
def WeylSpinor.ofComponents (components : Fin 2 → ℂ) : WeylSpinor :=
  ⟨components 0, components 1⟩

/-- Converting components to a spinor and back preserves the vector. -/
lemma WeylSpinor.component_ofComponents (components : Fin 2 → ℂ) :
    (WeylSpinor.ofComponents components).component = components := by
  funext index
  fin_cases index <;> simp [WeylSpinor.ofComponents, WeylSpinor.component]

/-- Equality of the two components determines a spinor. -/
lemma WeylSpinor.component_injective : Function.Injective WeylSpinor.component := by
  intro left right components
  cases left
  cases right
  congr 1
  · simpa [WeylSpinor.component] using congrFun components (0 : Fin 2)
  · simpa [WeylSpinor.component] using congrFun components (1 : Fin 2)

/-- Equality of lambda and of the mu components determines a twistor. -/
lemma Twistor.ext_components {left right : Twistor}
    (lambda_equal : left.lambda = right.lambda)
    (mu_equal : left.mu.component = right.mu.component) : left = right := by
  have mu_equal := WeylSpinor.component_injective mu_equal
  cases left
  cases right
  cases lambda_equal
  cases mu_equal
  rfl

/-- A complex coordinate matrix; no Hermiticity or spacetime metric is assumed. -/
abbrev SpacetimeMatrix := Matrix (Fin 2) (Fin 2) ℂ

/-- Incidence in the convention `mu = -i x lambda`. -/
def Twistor.incident (twistor : Twistor) (position : SpacetimeMatrix) : Prop :=
  twistor.mu.component = (-Complex.I) • position.mulVec twistor.lambda.component

/-- The algebraic shear induced by translating the coordinate matrix. -/
def Twistor.translate (twistor : Twistor) (offset : SpacetimeMatrix) : Twistor :=
  { lambda := twistor.lambda
    mu := WeylSpinor.ofComponents
      (twistor.mu.component - Complex.I • offset.mulVec twistor.lambda.component) }

/-- Translation leaves the first spinor unchanged. -/
lemma Twistor.translate_lambda (twistor : Twistor) (offset : SpacetimeMatrix) :
    (twistor.translate offset).lambda = twistor.lambda := rfl

/-- The second spinor changes by the prescribed matrix shear. -/
lemma Twistor.translate_mu (twistor : Twistor) (offset : SpacetimeMatrix) :
    (twistor.translate offset).mu.component =
      twistor.mu.component - Complex.I • offset.mulVec twistor.lambda.component :=
  WeylSpinor.component_ofComponents _

/-- The shear preserves incidence at the translated coordinate matrix. -/
lemma Twistor.translate_incident (twistor : Twistor) (position offset : SpacetimeMatrix)
    (incidence : twistor.incident position) :
    (twistor.translate offset).incident (position + offset) := by
  unfold Twistor.incident at incidence ⊢
  rw [Twistor.translate_mu, Twistor.translate_lambda, incidence, Matrix.add_mulVec]
  simp [smul_add, neg_smul, sub_eq_add_neg]

/-- A zero coordinate translation is the identity shear. -/
lemma Twistor.translate_zero (twistor : Twistor) : twistor.translate 0 = twistor := by
  apply Twistor.ext_components
  · rfl
  simp [Twistor.translate_mu]

/-- Successive coordinate translations add their offsets. -/
lemma Twistor.translate_add (twistor : Twistor) (first second : SpacetimeMatrix) :
    (twistor.translate first).translate second = twistor.translate (first + second) := by
  apply Twistor.ext_components
  · rfl
  simp only [Twistor.translate_mu, Twistor.translate_lambda, Matrix.add_mulVec, smul_add]
  abel

/-- The negative offset undoes a translation. -/
lemma Twistor.translate_neg (twistor : Twistor) (offset : SpacetimeMatrix) :
    (twistor.translate offset).translate (-offset) = twistor := by
  rw [Twistor.translate_add, add_neg_cancel, Twistor.translate_zero]

/-- Incidence is equivalent before and after applying the same coordinate translation. -/
lemma Twistor.translate_incident_iff (twistor : Twistor) (position offset : SpacetimeMatrix) :
    (twistor.translate offset).incident (position + offset) ↔ twistor.incident position := by
  constructor
  · intro translated
    have restored := (twistor.translate offset).translate_incident
      (position + offset) (-offset) translated
    simpa [Twistor.translate_neg] using restored
  · exact twistor.translate_incident position offset

/-- A finite sum of two rank-one spinor products. -/
def massiveSpinorProduct
    (left right : Fin 2 → WeylSpinor) : Matrix (Fin 2) (Fin 2) ℂ :=
  fun row column =>
    ∑ label : Fin 2,
      (left label).component row * (right label).component column

/-- A massive momentum together with its supplied spinor-helicity factorization. -/
structure MassiveSpinorHelicity (momentum : FourMomentum) where
  left : Fin 2 → WeylSpinor
  right : Fin 2 → WeylSpinor
  factorization : momentum.bispinor = massiveSpinorProduct left right

lemma FourMomentum.mass_shell_holds (momentum : FourMomentum) :
    momentum.energy ^ 2 - momentum.px ^ 2 - momentum.py ^ 2 - momentum.pz ^ 2 =
      momentum.mass ^ 2 :=
  momentum.mass_shell

/-- Real matrices with two rows and four columns. -/
abbrev Matrix2x4 := Matrix (Fin 2) (Fin 4) ℝ

/-- The determinant of the two columns selected by `left` and `right`. -/
def minor (matrix : Matrix2x4) (left right : Fin 4) : ℝ :=
  matrix 0 left * matrix 1 right - matrix 0 right * matrix 1 left

/-- Swapping columns negates a two-column minor. -/
lemma minor_swap (matrix : Matrix2x4) (left right : Fin 4) :
    minor matrix left right = -minor matrix right left := by
  simp [minor]

/-- Repeating a column gives a zero two-column minor. -/
lemma minor_self (matrix : Matrix2x4) (column : Fin 4) :
    minor matrix column column = 0 := by
  simp [minor]

/-- The quadratic Pluecker relation for every two-row, four-column matrix.

This is a finite determinant identity; it does not assert an Amplituhedron
volume or any physical interpretation of the matrix. -/
lemma pluecker_relation (matrix : Matrix2x4) :
    minor matrix 0 1 * minor matrix 2 3 -
      minor matrix 0 2 * minor matrix 1 3 +
      minor matrix 0 3 * minor matrix 1 2 = 0 := by
  simp [minor]
  ring

/-! ## Orbital angular-momentum translations

These are real coordinate identities for a four-index bivector, not an
identification of the bivector with a two-by-two commutator or a Casimir.
-/

/-- Four real coordinates in a fixed common index convention. -/
abbrev FourVector := Fin 4 → ℝ

/-- The orbital bivector `position wedge momentum`. -/
def orbitalBivector (position momentum : FourVector) : Matrix (Fin 4) (Fin 4) ℝ :=
  fun row column => position row * momentum column - position column * momentum row

/-- The orbital tensor is antisymmetric. -/
lemma orbitalBivector_antisymmetric (position momentum : FourVector) (row column : Fin 4) :
    orbitalBivector position momentum row column =
      -orbitalBivector position momentum column row := by
  simp [orbitalBivector]

/-- Translating the position adds the offset's orbital bivector. -/
lemma orbitalBivector_translate (position offset momentum : FourVector) :
    orbitalBivector (position + offset) momentum =
      orbitalBivector position momentum + orbitalBivector offset momentum := by
  funext row column
  simp [orbitalBivector]
  ring

/-- Momentum and an antisymmetric angular-momentum tensor as algebraic data. -/
structure AngularMomentumState where
  momentum : FourVector
  angularMomentum : Matrix (Fin 4) (Fin 4) ℝ
  antisymmetric : ∀ row column, angularMomentum row column = -angularMomentum column row

/-- Coordinate translation adds `offset wedge momentum` while preserving momentum. -/
def AngularMomentumState.translate (state : AngularMomentumState) (offset : FourVector) :
    AngularMomentumState :=
  { momentum := state.momentum
    angularMomentum := state.angularMomentum + orbitalBivector offset state.momentum
    antisymmetric := by
      intro row column
      simp only [Matrix.add_apply]
      rw [state.antisymmetric row column,
        orbitalBivector_antisymmetric offset state.momentum row column]
      ring }

/-- Coordinate translation does not change the supplied momentum. -/
lemma AngularMomentumState.translate_momentum (state : AngularMomentumState)
    (offset : FourVector) : (state.translate offset).momentum = state.momentum := rfl

/-- The angular-momentum shift exposes the full four-index wedge tensor. -/
lemma AngularMomentumState.translate_angularMomentum (state : AngularMomentumState)
    (offset : FourVector) : (state.translate offset).angularMomentum =
      state.angularMomentum + orbitalBivector offset state.momentum := rfl

end Signals.Geometry
