import Mathlib.Data.Complex.Basic
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

end Signals.Geometry
