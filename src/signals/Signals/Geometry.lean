import Architect
import Mathlib.Basic.Complex.Basic
import Signals.Plabic
import Mathlib.LinearAlgebra.Matrix.Determinant.Basic
import Mathlib.Tactic

/-!
# Finite geometric representatives

Ordered minors, orientation laws and finite two-step products are checked algebra.
Positive conditions require their stated input hypotheses; full-rank promotion
requires an available nonzero minor. No quotient, planar embedding or optical
interpretation is constructed here.
-/

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
@[blueprint "def:signals-twistor-data"
  (title := "Finite twistor data")
  (statement := /-- A twistor record consists of two complex two-component Weyl spinors.
    Incidence and coordinate conventions are supplied separately. -/)]
structure Twistor where
  lambda : WeylSpinor
  mu : WeylSpinor

/-! ## Finite Grassmannian coordinates

The unrestricted matrix record deliberately permits negative Pluecker
coordinates. Positivity is an additional chart condition, not part of the
underlying linear-algebra data.
-/

/-- A strictly ordered selection of `k` columns from `n` columns. -/
@[blueprint "def:signals-ordered-columns"
  (title := "Ordered column selections")
  (statement := /-- An ordered selection of $k$ columns among $n$ is a strictly increasing map
    $\operatorname{Fin}(k)\to\operatorname{Fin}(n)$. -/)]
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

/-- Select two distinct columns in the supplied increasing order. -/
def OrderedColumns.pair {n : ℕ} (first second : Fin n) (ordered : first < second) :
    OrderedColumns 2 n :=
  { index := ![first, second]
    strictlyIncreasing := by
      intro left right before
      fin_cases left <;> fin_cases right <;> simp_all }

/-- A finite matrix representing a point before any positivity restriction. -/
@[blueprint "def:signals-grassmannian-matrix"
  (title := "Unrestricted finite representatives")
  (statement := /-- A representative is a real $k\times n$ matrix. This record alone imposes
    neither full rank nor positivity and does not construct a Grassmannian quotient. -/)]
structure GrassmannianMatrix (k n : ℕ) where
  mat : Matrix (Fin k) (Fin n) ℝ

/-- The maximal minor selected by an ordered list of columns. -/
@[blueprint "def:signals-selected-minor"
  (title := "Ordered maximal minors")
  (statement := /-- For an ordered column selection $J$, define $\Delta_J(M)=\det(M_J)$,
    where $M_J$ retains every row and the selected columns in their supplied order. -/)]
def selectedMinor {k n : ℕ}
    (matrix : Matrix (Fin k) (Fin n) ℝ) (columns : OrderedColumns k n) : ℝ :=
  (matrix.submatrix id columns.index).det

/-- The Pluecker coordinate of an ordered column selection. -/
def GrassmannianMatrix.pluckerCoordinate
    {k n : ℕ} (grassmannian : GrassmannianMatrix k n)
    (columns : OrderedColumns k n) : ℝ :=
  selectedMinor grassmannian.mat columns

/-- Left multiplication by a row basis matrix scales every maximal minor by its determinant. -/
@[blueprint "lem:signals-minor-basis-change"
  (title := "Determinant basis-change law")
  (statement := /-- Every ordered maximal minor obeys
    $\Delta_J(BM)=\det(B)\Delta_J(M)$ for a square row-basis matrix $B$. -/)
  (proof := /-- Column selection commutes with left multiplication; apply determinant multiplicativity. -/)
  (latexEnv := "lemma")]
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
@[blueprint "def:signals-positive-condition"
  (title := "Positive ordered-minor condition")
  (statement := /-- A positive-condition representative has $\Delta_J(M)>0$ for every
    available ordered selection $J$. An available selection is still required for full-rank promotion. -/)]
structure PositiveGrassmannian (k n : ℕ)
    extends GrassmannianMatrix k n where
  strictly_positive : toGrassmannianMatrix.hasPositiveOrderedMinors

/-- The positive-condition record supplies positivity of each available ordered maximal minor. -/
@[blueprint "lem:signals-positive-coordinate"
  (title := "Positive ordered coordinates")
  (statement := /-- Every available ordered maximal minor of a positive-condition
    representative is strictly positive. -/)
  (proof := /-- Apply the record's explicit ordered-minor positivity hypothesis. -/)
  (latexEnv := "lemma")]
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
@[blueprint "def:signals-nonnegative-representative"
  (title := "Full-rank nonnegative representatives")
  (statement := /-- A nonnegative representative has every ordered maximal minor nonnegative
    and an explicit nonzero ordered minor. This is matrix data, not a quotient. -/)]
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
@[blueprint "def:signals-positive-rank-promotion"
  (title := "Promotion with an available minor")
  (statement := /-- A positive-condition representative and an available ordered selection
    construct a full-rank nonnegative representative using that positive minor. -/)]
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
@[blueprint "lem:signals-orientation-rejection"
  (title := "Orientation reversal rejects positivity")
  (statement := /-- A row basis change with negative determinant reverses every positive
    ordered minor. Given an available selection, the transformed representative is not positive. -/)
  (proof := /-- Apply the basis-change law and the sign of the determinant factor. -/)
  (latexEnv := "lemma")]
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
@[blueprint "def:signals-positive-interval"
  (title := "Normalized positive interval")
  (statement := /-- For $0<t<1$, the row $[t,1-t]$ has positive ordered maximal minors.
    This constructs a representative, not a quotient or weighted-cell correspondence. -/)]
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
@[blueprint "def:signals-positive-fork"
  (title := "Positive measured fork")
  (statement := /-- The actual fork boundary row with two positive edge weights constructs
    a positive one-row representative after conversion to real entries. -/)]
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
@[blueprint "def:signals-nonnegative-fork"
  (title := "Active-branch fork rank")
  (statement := /-- A nonnegative fork with at least one nonzero edge constructs a full-rank
    nonnegative row. One zero branch is allowed; the all-zero row is excluded by the active hypothesis. -/)]
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
@[blueprint "lem:signals-two-channel-determinant"
  (title := "Measured two-channel determinant")
  (statement := /-- The real two-channel boundary matrix has determinant $ad-bc$.
    Nonnegative entries alone do not establish a nonnegative ordered minor. -/)
  (proof := /-- Substitute the derived boundary matrix and expand its two-by-two determinant. -/)
  (latexEnv := "lemma")]
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
@[blueprint "lem:signals-hub-cancellation"
  (title := "Shared-hub determinant cancellation")
  (statement := /-- For any incoming and outgoing hub weights, the measured product matrix
    $[uv,uw;xv,xw]$ has determinant zero. Positive entries do not remove this rank obstruction. -/)
  (proof := /-- Derive the two-edge measured entries, then cancel the two signed pair products. -/)
  (latexEnv := "lemma")]
lemma singleHubRepresentative_det (firstIn secondIn firstOut secondOut : ℝ≥0) :
    (singleHubRepresentative firstIn secondIn firstOut secondOut).mat.det = 0 := by
  rw [singleHubRepresentative_mat, Matrix.det_fin_two]
  dsimp
  ring

/-- A two-step two-channel determinant expands as signed pairs of intermediate-vertex terms. -/
@[blueprint "lem:signals-two-step-path-pairs"
  (title := "Finite two-step pair expansion")
  (statement := /-- For real matrices $A$ of size $2\times m$ and $B$ of size $m\times2$,
    $\det(AB)=\sum_i\sum_j A_{0i}A_{1j}(B_{i0}B_{j1}-B_{i1}B_{j0})$. -/)
  (proof := /-- Expand the determinant and matrix products, distribute the finite sums, and factor each term. -/)
  (latexEnv := "lemma")]
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

/-- The signed product of incoming and outgoing two-by-two minors for one intermediate pair. -/
@[blueprint "def:signals-two-step-minor-pair"
  (title := "Signed input minor pairs")
  (statement := /-- Define $D_{ij}=(A_{0i}A_{1j}-A_{0j}A_{1i})
    (B_{i0}B_{j1}-B_{i1}B_{j0})$. These are algebraic input contributions, not optical amplitudes. -/)]
def twoStepMinorPair {middleCount : ℕ}
    (incoming : Matrix (Fin 2) (Fin middleCount) ℝ)
    (outgoing : Matrix (Fin middleCount) (Fin 2) ℝ) (first second : Fin middleCount) : ℝ :=
  (incoming 0 first * incoming 1 second - incoming 0 second * incoming 1 first) *
    (outgoing first 0 * outgoing second 1 - outgoing first 1 * outgoing second 0)

/-- Pairing both intermediate orders gives products of two-by-two minors, counted twice. -/
@[blueprint "lem:signals-two-step-paired-minors"
  (title := "Paired-minor counting identity")
  (statement := /-- Summing all ordered intermediate pairs gives
    $\sum_i\sum_j D_{ij}=2\det(AB)$. The factor two counts both index orders. -/)
  (proof := /-- Exchange the two summation indices in the reversed contribution and apply the signed pair expansion. -/)
  (latexEnv := "lemma")]
lemma twoStep_minorPairs_sum {middleCount : ℕ}
    (incoming : Matrix (Fin 2) (Fin middleCount) ℝ)
    (outgoing : Matrix (Fin middleCount) (Fin 2) ℝ) :
    (∑ first, ∑ second, twoStepMinorPair incoming outgoing first second) =
      2 * (incoming * outgoing).det := by
  unfold twoStepMinorPair
  have swapped : (∑ first, ∑ second, incoming 0 second * incoming 1 first *
      (outgoing first 0 * outgoing second 1 - outgoing first 1 * outgoing second 0)) =
      -(incoming * outgoing).det := by
    rw [Finset.sum_comm, twoStep_det_pathPairs]
    simp only [← Finset.sum_neg_distrib]
    apply Finset.sum_congr rfl
    intro first _
    apply Finset.sum_congr rfl
    intro second _
    ring
  calc
    _ = (∑ first, ∑ second, incoming 0 first * incoming 1 second *
          (outgoing first 0 * outgoing second 1 - outgoing first 1 * outgoing second 0)) -
        ∑ first, ∑ second, incoming 0 second * incoming 1 first *
          (outgoing first 0 * outgoing second 1 - outgoing first 1 * outgoing second 0) := by
      simp only [sub_mul, Finset.sum_sub_distrib]
    _ = (incoming * outgoing).det - -(incoming * outgoing).det := by
      rw [← twoStep_det_pathPairs, swapped]
    _ = 2 * (incoming * outgoing).det := by ring

/-- Compatible nonnegative minor-pair contributions derive a nonnegative two-step determinant. -/
@[blueprint "lem:signals-two-step-nonnegative"
  (title := "Compatible-pair nonnegativity")
  (statement := /-- If every input contribution $D_{ij}$ is nonnegative, then $\det(AB)\ge0$.
    Compatibility is an explicit hypothesis, not a consequence of positive entries or an embedding. -/)
  (proof := /-- The finite contribution sum is nonnegative; use the paired-minor identity. -/)
  (latexEnv := "lemma")]
lemma twoStep_det_nonnegative {middleCount : ℕ}
    (incoming : Matrix (Fin 2) (Fin middleCount) ℝ)
    (outgoing : Matrix (Fin middleCount) (Fin 2) ℝ)
    (compatible : ∀ first second, 0 ≤ twoStepMinorPair incoming outgoing first second) :
    0 ≤ (incoming * outgoing).det := by
  have nonnegativeSum : 0 ≤ ∑ first, ∑ second, twoStepMinorPair incoming outgoing first second := by
    apply Finset.sum_nonneg
    intro first _
    exact Finset.sum_nonneg (fun second _ => compatible first second)
  rw [twoStep_minorPairs_sum] at nonnegativeSum
  linarith

/-- One positive minor-pair witness among compatible contributions derives strict determinant positivity. -/
@[blueprint "lem:signals-two-step-positive"
  (title := "Active compatible-pair positivity")
  (statement := /-- Nonnegative input contributions and one strictly positive pair imply
    $\det(AB)>0$. The strict pair witness cannot be omitted at a rank boundary. -/)
  (proof := /-- Bound the positive contribution by its row sum and the total sum, then use the counting identity. -/)
  (latexEnv := "lemma")]
lemma twoStep_det_positive {middleCount : ℕ}
    (incoming : Matrix (Fin 2) (Fin middleCount) ℝ)
    (outgoing : Matrix (Fin middleCount) (Fin 2) ℝ)
    (compatible : ∀ first second, 0 ≤ twoStepMinorPair incoming outgoing first second)
    (first second : Fin middleCount)
    (active : 0 < twoStepMinorPair incoming outgoing first second) :
    0 < (incoming * outgoing).det := by
  have rowBound : twoStepMinorPair incoming outgoing first second ≤
      ∑ middle, twoStepMinorPair incoming outgoing first middle :=
    Finset.single_le_sum (fun middle _ => compatible first middle) (Finset.mem_univ second)
  have totalBound : (∑ middle, twoStepMinorPair incoming outgoing first middle) ≤
      ∑ row, ∑ middle, twoStepMinorPair incoming outgoing row middle :=
    Finset.single_le_sum
      (fun row _ => Finset.sum_nonneg (fun middle _ => compatible row middle)) (Finset.mem_univ first)
  rw [twoStep_minorPairs_sum] at totalBound
  linarith

/-- Selecting output columns commutes with finite two-step matrix multiplication. -/
lemma twoStep_selectedMinor {middleCount sinkCount : ℕ}
    (incoming : Matrix (Fin 2) (Fin middleCount) ℝ)
    (outgoing : Matrix (Fin middleCount) (Fin sinkCount) ℝ)
    (columns : OrderedColumns 2 sinkCount) :
    selectedMinor (incoming * outgoing) columns =
      (incoming * outgoing.submatrix id columns.index).det := by
  unfold selectedMinor
  rfl

/-- Every ordered output maximal minor has the derived finite input minor-pair expansion. -/
@[blueprint "lem:signals-selected-paired-minors"
  (title := "Arbitrary ordered output minors")
  (statement := /-- For any ordered pair of sink columns $J$,
    $\sum_i\sum_j D_{ij}(A,B_J)=2\Delta_J(AB)$, with any finite intermediate and sink counts. -/)
  (proof := /-- Column selection commutes with the product; apply the two-channel paired-minor identity. -/)
  (latexEnv := "lemma")]
lemma twoStep_selectedMinor_pairs {middleCount sinkCount : ℕ}
    (incoming : Matrix (Fin 2) (Fin middleCount) ℝ)
    (outgoing : Matrix (Fin middleCount) (Fin sinkCount) ℝ)
    (columns : OrderedColumns 2 sinkCount) :
    (∑ first, ∑ second,
      twoStepMinorPair incoming (outgoing.submatrix id columns.index) first second) =
      2 * selectedMinor (incoming * outgoing) columns := by
  rw [twoStep_selectedMinor]
  exact twoStep_minorPairs_sum incoming (outgoing.submatrix id columns.index)

/-- The unrestricted two-row representative computed by the finite two-step product. -/
def twoStepRepresentative {middleCount sinkCount : ℕ}
    (incoming : Matrix (Fin 2) (Fin middleCount) ℝ)
    (outgoing : Matrix (Fin middleCount) (Fin sinkCount) ℝ) : GrassmannianMatrix 2 sinkCount :=
  ⟨incoming * outgoing⟩

/-- Compatible selected input minor pairs derive nonnegativity of one ordered output minor. -/
lemma twoStep_selectedMinor_nonnegative {middleCount sinkCount : ℕ}
    (incoming : Matrix (Fin 2) (Fin middleCount) ℝ)
    (outgoing : Matrix (Fin middleCount) (Fin sinkCount) ℝ)
    (columns : OrderedColumns 2 sinkCount)
    (compatible : ∀ first second,
      0 ≤ twoStepMinorPair incoming (outgoing.submatrix id columns.index) first second) :
    0 ≤ selectedMinor (incoming * outgoing) columns := by
  rw [twoStep_selectedMinor]
  exact twoStep_det_nonnegative incoming (outgoing.submatrix id columns.index) compatible

/-- A positive selected input pair among compatible pairs derives positivity of one output minor. -/
lemma twoStep_selectedMinor_positive {middleCount sinkCount : ℕ}
    (incoming : Matrix (Fin 2) (Fin middleCount) ℝ)
    (outgoing : Matrix (Fin middleCount) (Fin sinkCount) ℝ)
    (columns : OrderedColumns 2 sinkCount)
    (compatible : ∀ first second,
      0 ≤ twoStepMinorPair incoming (outgoing.submatrix id columns.index) first second)
    (first second : Fin middleCount)
    (active : 0 < twoStepMinorPair incoming (outgoing.submatrix id columns.index) first second) :
    0 < selectedMinor (incoming * outgoing) columns := by
  rw [twoStep_selectedMinor]
  exact twoStep_det_positive incoming (outgoing.submatrix id columns.index) compatible first second active

/-- Compatible input pairs and a positive witness for each ordered selection derive the positive condition. -/
@[blueprint "def:signals-two-step-positive-record"
  (title := "Derived positive-condition records")
  (statement := /-- Compatible input pairs and a positive pair for every ordered sink selection
    construct the positive-condition record for the actual product matrix. Rank promotion still needs an available selection. -/)]
def twoStepPositive {middleCount sinkCount : ℕ}
    (incoming : Matrix (Fin 2) (Fin middleCount) ℝ)
    (outgoing : Matrix (Fin middleCount) (Fin sinkCount) ℝ)
    (compatible : ∀ columns : OrderedColumns 2 sinkCount, ∀ first second,
      0 ≤ twoStepMinorPair incoming (outgoing.submatrix id columns.index) first second)
    (active : ∀ columns : OrderedColumns 2 sinkCount, ∃ first second,
      0 < twoStepMinorPair incoming (outgoing.submatrix id columns.index) first second) :
    PositiveGrassmannian 2 sinkCount :=
  { toGrassmannianMatrix := twoStepRepresentative incoming outgoing
    strictly_positive := by
      intro columns
      obtain ⟨first, second, positive⟩ := active columns
      exact twoStep_selectedMinor_positive incoming outgoing columns (compatible columns)
        first second positive }

/-- One active selected input pair supplies a nonzero output minor for a nonnegative full-rank record. -/
@[blueprint "def:signals-two-step-nonnegative-record"
  (title := "Derived nonnegative full-rank records")
  (statement := /-- Compatible pairs for every ordered sink selection and one available selection
    with a positive pair construct a full-rank nonnegative product representative, retaining boundary zero minors. -/)]
def twoStepNonnegative {middleCount sinkCount : ℕ}
    (incoming : Matrix (Fin 2) (Fin middleCount) ℝ)
    (outgoing : Matrix (Fin middleCount) (Fin sinkCount) ℝ)
    (compatible : ∀ columns : OrderedColumns 2 sinkCount, ∀ first second,
      0 ≤ twoStepMinorPair incoming (outgoing.submatrix id columns.index) first second)
    (active : ∃ columns : OrderedColumns 2 sinkCount, ∃ first second,
      0 < twoStepMinorPair incoming (outgoing.submatrix id columns.index) first second) :
    NonnegativeGrassmannian 2 sinkCount :=
  { toGrassmannianMatrix := twoStepRepresentative incoming outgoing
    nonnegative := fun columns =>
      twoStep_selectedMinor_nonnegative incoming outgoing columns (compatible columns)
    nonzero_minor := by
      obtain ⟨columns, first, second, positive⟩ := active
      refine ⟨columns, ne_of_gt ?_⟩
      exact twoStep_selectedMinor_positive incoming outgoing columns (compatible columns)
        first second positive }

/-! ## Massive spinor-helicity bookkeeping

The records below expose the massive replacement for the massless
factorization used in the source chat. They state on-shell and factorization
conditions as supplied data; they do not assert that an experimental field is
described by this representation.
-/

/-- A real four-momentum in the mostly-minus metric convention. -/
@[blueprint "def:signals-four-momentum-data"
  (title := "Supplied mass-shell data")
  (statement := /-- Real energy and momentum components carry a nonnegative mass and an
    explicit supplied equation $E^2-p_x^2-p_y^2-p_z^2=m^2$ in the mostly-minus convention.
    This record does not derive or experimentally establish the mass-shell premise. -/)]
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
@[blueprint "def:signals-twistor-incidence"
  (title := "Fixed complex incidence convention")
  (statement := /-- Incidence is the coordinate equation $\mu=-iX\lambda$ for a complex
    two-by-two coordinate matrix $X$. Hermiticity and a spacetime metric are not imposed. -/)]
def Twistor.incident (twistor : Twistor) (position : SpacetimeMatrix) : Prop :=
  twistor.mu.component = (-Complex.I) • position.mulVec twistor.lambda.component

/-- The algebraic shear induced by translating the coordinate matrix. -/
@[blueprint "def:signals-twistor-translation"
  (title := "Algebraic coordinate shear")
  (statement := /-- Translation by $H$ leaves $\lambda$ fixed and sends
    $\mu$ to $\mu-iH\lambda$. This is a finite coordinate operation, not an optical evolution law. -/)]
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
@[blueprint "lem:signals-twistor-additive-translation"
  (title := "Additive coordinate translation")
  (statement := /-- Two successive twistor coordinate shears equal the shear by the sum
    of their coordinate offsets. -/)
  (proof := /-- Compare the two spinor components and use matrix-vector linearity. -/)
  (latexEnv := "lemma")]
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
@[blueprint "lem:signals-incidence-translation-equivalence"
  (title := "Incidence under translation")
  (statement := /-- Incidence at $X$ is equivalent to incidence of the translated twistor
    at $X+H$, using the fixed shear convention. -/)
  (proof := /-- Matrix-vector linearity proves forward preservation; the negative offset reverses the shear. -/)
  (latexEnv := "lemma")]
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
@[blueprint "def:signals-supplied-spinor-factorization"
  (title := "Supplied two-label spinor factorization")
  (statement := /-- The momentum bispinor is explicitly supplied as a sum of two spinor
    outer products. The record does not derive factorization existence or require strictly positive mass. -/)]
structure MassiveSpinorHelicity (momentum : FourMomentum) where
  left : Fin 2 → WeylSpinor
  right : Fin 2 → WeylSpinor
  factorization : momentum.bispinor = massiveSpinorProduct left right

/-- Expose the supplied mostly-minus mass-shell equation; this does not derive its physical premise. -/
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
@[blueprint "lem:signals-finite-pluecker-relation"
  (title := "Finite quadratic Pluecker relation")
  (statement := /-- Every real two-row, four-column matrix obeys
    $\Delta_{01}\Delta_{23}-\Delta_{02}\Delta_{13}+\Delta_{03}\Delta_{12}=0$.
    No positivity, amplituhedron volume or optical interpretation follows from this identity alone. -/)
  (proof := /-- Expand the six two-column determinants and cancel the polynomial terms. -/)
  (latexEnv := "lemma")]
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
@[blueprint "def:signals-orbital-bivector"
  (title := "Four-index orbital bivector")
  (statement := /-- In fixed real coordinates, the orbital bivector has entries
    $L_{ab}=x_a p_b-x_b p_a$. This is algebraic tensor data. -/)]
def orbitalBivector (position momentum : FourVector) : Matrix (Fin 4) (Fin 4) ℝ :=
  fun row column => position row * momentum column - position column * momentum row

/-- The orbital tensor is antisymmetric. -/
lemma orbitalBivector_antisymmetric (position momentum : FourVector) (row column : Fin 4) :
    orbitalBivector position momentum row column =
      -orbitalBivector position momentum column row := by
  simp [orbitalBivector]

/-- Translating the position adds the offset's orbital bivector. -/
@[blueprint "lem:signals-orbital-translation"
  (title := "Orbital tensor translation law")
  (statement := /-- Translating position by $h$ sends $x\wedge p$ to
    $x\wedge p+h\wedge p$, without changing the supplied momentum. -/)
  (proof := /-- Expand each tensor entry and distribute the coordinate sum. -/)
  (latexEnv := "lemma")]
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
