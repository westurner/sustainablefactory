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