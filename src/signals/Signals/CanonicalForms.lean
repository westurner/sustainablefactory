import Mathlib.LinearAlgebra.Matrix.Determinant.Basic
import Mathlib.Topology.Instances.Real.Lemmas
import Mathlib.Tactic

namespace Signals.CanonicalForms

open scoped Topology

/-! Affine interval and planar canonical-form examples in fixed oriented coordinates.

Forms are position-dependent alternating covectors, not just reciprocal scalars.
Residues are punctured-neighborhood limits of regularized coefficients. These
examples do not assert a general projective canonical-form existence theorem or
an optical evaluation operation.
-/

/-- Coefficient of dt on the oriented interval (0,1). -/
noncomputable def intervalCoefficient (coordinate : ℝ) : ℝ :=
  1 / (coordinate * (1 - coordinate))

/-- The interval one-form acts on a one-dimensional tangent vector by its coefficient. -/
noncomputable def intervalForm (coordinate : ℝ) :
    AlternatingMap ℝ (Fin 1 → ℝ) ℝ (Fin 1) :=
  intervalCoefficient coordinate • Matrix.detRowAlternating

/-- The alternating one-form has the stated dt coefficient. -/
lemma intervalForm_apply (coordinate : ℝ) (vectors : Matrix (Fin 1) (Fin 1) ℝ) :
    intervalForm coordinate vectors = intervalCoefficient coordinate * vectors 0 0 := by
  change intervalCoefficient coordinate * Matrix.det vectors = _
  rw [Matrix.det_fin_one]

/-- The interval coefficient is normalized away from its two boundary points. -/
lemma intervalCoefficient_normalization (coordinate : ℝ) (lower : 0 < coordinate)
    (upper : coordinate < 1) :
    intervalCoefficient coordinate * (coordinate * (1 - coordinate)) = 1 := by
  exact one_div_mul_cancel (mul_ne_zero (ne_of_gt lower) (ne_of_gt (sub_pos.mpr upper)))

/-- A continuous regularization determines the simple-pole residue as a genuine limit. -/
lemma residue_limit {coefficient regularized : ℝ → ℝ} {boundary : ℝ}
    (continuous : ContinuousAt regularized boundary)
    (regularization : ∀ coordinate, coordinate ≠ boundary →
      (coordinate - boundary) * coefficient coordinate = regularized coordinate) :
    Filter.Tendsto (fun coordinate => (coordinate - boundary) * coefficient coordinate)
      (𝓝[≠] boundary) (𝓝 (regularized boundary)) := by
  have equal : (fun coordinate => (coordinate - boundary) * coefficient coordinate) =ᶠ[𝓝[≠] boundary]
      regularized := by
    filter_upwards [self_mem_nhdsWithin] with coordinate distinct
    exact regularization coordinate (by simpa using distinct)
  exact (Filter.tendsto_congr' equal).mpr (continuous.tendsto.mono_left nhdsWithin_le_nhds)

/-- Multiplying by the left boundary coordinate removes its pole, including at the other boundary. -/
lemma interval_left_regularization (coordinate : ℝ) (distinct : coordinate ≠ 0) :
    coordinate * intervalCoefficient coordinate = 1 / (1 - coordinate) := by
  by_cases otherBoundary : coordinate = 1
  · subst coordinate
    norm_num [intervalCoefficient]
  · have other : 1 - coordinate ≠ 0 := sub_ne_zero.mpr (Ne.symm otherBoundary)
    unfold intervalCoefficient
    field_simp [distinct, other]

/-- The residue at the left endpoint is +1 in the dt convention. -/
lemma interval_residue_zero :
    Filter.Tendsto (fun coordinate => coordinate * intervalCoefficient coordinate)
      (𝓝[≠] (0 : ℝ)) (𝓝 1) := by
  have continuous : ContinuousAt (fun coordinate : ℝ => 1 / (1 - coordinate)) 0 := by
    fun_prop (disch := norm_num)
  simpa using residue_limit continuous (fun coordinate distinct => by
    simpa using interval_left_regularization coordinate distinct)

/-- Multiplying by t-1 removes the right pole with the oriented negative residue. -/
lemma interval_right_regularization (coordinate : ℝ) (distinct : coordinate ≠ 1) :
    (coordinate - 1) * intervalCoefficient coordinate = -1 / coordinate := by
  by_cases otherBoundary : coordinate = 0
  · subst coordinate
    norm_num [intervalCoefficient]
  · have other : 1 - coordinate ≠ 0 := sub_ne_zero.mpr distinct.symm
    unfold intervalCoefficient
    field_simp [otherBoundary, other]
    ring

/-- The residue at the right endpoint is -1 in the dt convention. -/
lemma interval_residue_one :
    Filter.Tendsto (fun coordinate => (coordinate - 1) * intervalCoefficient coordinate)
      (𝓝[≠] (1 : ℝ)) (𝓝 (-1)) := by
  have continuous : ContinuousAt (fun coordinate : ℝ => -1 / coordinate) 1 := by
    fun_prop (disch := norm_num)
  simpa using residue_limit continuous interval_right_regularization

/-- The interval coefficient has no other affine pole. -/
lemma intervalCoefficient_continuousAt (coordinate : ℝ) (left : coordinate ≠ 0)
    (right : coordinate ≠ 1) : ContinuousAt intervalCoefficient coordinate := by
  unfold intervalCoefficient
  fun_prop (disch := exact mul_ne_zero left (sub_ne_zero.mpr right.symm))

/-- Two real affine coordinates and their tangent-vector space. -/
abbrev Plane := Fin 2 → ℝ

/-- Coefficient of dx wedge dy on x>0, y>0, x+y<1. -/
noncomputable def triangleCoefficient (point : Plane) : ℝ :=
  1 / (point 0 * point 1 * (1 - point 0 - point 1))

/-- A genuine alternating two-form in the standard oriented affine coordinates. -/
noncomputable def triangleForm (point : Plane) : AlternatingMap ℝ Plane ℝ (Fin 2) :=
  triangleCoefficient point • Matrix.detRowAlternating

/-- Evaluation on two tangent vectors is the coefficient times their oriented area. -/
lemma triangleForm_apply (point : Plane) (vectors : Matrix (Fin 2) (Fin 2) ℝ) :
    triangleForm point vectors = triangleCoefficient point *
      (vectors 0 0 * vectors 1 1 - vectors 0 1 * vectors 1 0) := by
  change triangleCoefficient point * Matrix.det vectors = _
  rw [Matrix.det_fin_two]

/-- The triangle coefficient has unit numerator on its regular domain. -/
lemma triangleCoefficient_normalization (point : Plane) (first : point 0 ≠ 0)
    (second : point 1 ≠ 0) (diagonal : 1 - point 0 - point 1 ≠ 0) :
    triangleCoefficient point * (point 0 * point 1 * (1 - point 0 - point 1)) = 1 :=
  one_div_mul_cancel (mul_ne_zero (mul_ne_zero first second) diagonal)

/-- The triangle coefficient has no affine singularity away from its three boundary lines. -/
lemma triangleCoefficient_continuousAt (point : Plane) (first : point 0 ≠ 0)
    (second : point 1 ≠ 0) (diagonal : 1 - point 0 - point 1 ≠ 0) :
    ContinuousAt triangleCoefficient point := by
  unfold triangleCoefficient
  fun_prop (disch := exact mul_ne_zero (mul_ne_zero first second) diagonal)

/-- Cancel a simple real pole without requiring the remaining factor to be nonzero. -/
lemma cancel_pole_factor (coordinate remaining : ℝ) (distinct : coordinate ≠ 0) :
    coordinate * (1 / (coordinate * remaining)) = 1 / remaining := by
  by_cases zero : remaining = 0
  · subst remaining
    simp
  · field_simp [distinct, zero]

/-- Contracting dx wedge dy with the x-normal leaves the positive oriented dy residue. -/
lemma triangle_x_regularization (coordinate normal : ℝ) (distinct : normal ≠ 0) :
    normal * triangleForm ![normal, coordinate] !![1, 0; 0, 1] =
      1 / (coordinate * (1 - normal - coordinate)) := by
  simpa [triangleForm_apply, triangleCoefficient, mul_assoc] using
    cancel_pole_factor normal (coordinate * (1 - normal - coordinate)) distinct

/-- Contracting with the y-normal gives -dx, fixing the second boundary's orientation. -/
lemma triangle_y_regularization (coordinate normal : ℝ) (distinct : normal ≠ 0) :
    normal * triangleForm ![coordinate, normal] !![0, 1; 1, 0] =
      -1 / (coordinate * (1 - coordinate - normal)) := by
  have denominator : coordinate * normal * (1 - coordinate - normal) =
      normal * (coordinate * (1 - coordinate - normal)) := by ring
  have oriented : triangleForm ![coordinate, normal] !![0, 1; 1, 0] =
      -(1 / (normal * (coordinate * (1 - coordinate - normal)))) := by
    rw [triangleForm_apply]
    dsimp [triangleCoefficient]
    rw [denominator]
    ring
  rw [oriented, mul_neg, cancel_pole_factor normal _ distinct]
  simp only [neg_div]

/-- The diagonal normal z=1-x-y and tangent x produce the positive dx orientation. -/
lemma triangle_diagonal_regularization (coordinate normal : ℝ) (distinct : normal ≠ 0) :
    normal * triangleForm ![coordinate, 1 - coordinate - normal] !![0, -1; 1, -1] =
      1 / (coordinate * (1 - coordinate - normal)) := by
  have slack : 1 - coordinate - (1 - coordinate - normal) = normal := by ring
  have denominator : coordinate * (1 - coordinate - normal) * normal =
      normal * (coordinate * (1 - coordinate - normal)) := by ring
  simpa [triangleForm_apply, triangleCoefficient, slack, denominator] using
    cancel_pole_factor normal (coordinate * (1 - coordinate - normal)) distinct

/-- The x-boundary residue is the interval form's coefficient on the surviving coordinate. -/
lemma triangle_residue_x (coordinate : ℝ) (lower : 0 < coordinate) (upper : coordinate < 1) :
    Filter.Tendsto (fun normal => normal * triangleForm ![normal, coordinate] !![1, 0; 0, 1])
      (𝓝[≠] (0 : ℝ)) (𝓝 (intervalCoefficient coordinate)) := by
  have continuous : ContinuousAt (fun normal : ℝ => 1 / (coordinate * (1 - normal - coordinate))) 0 := by
    fun_prop (disch := exact mul_ne_zero (ne_of_gt lower) (by simpa using ne_of_gt (sub_pos.mpr upper)))
  simpa [intervalCoefficient] using residue_limit continuous (fun normal distinct => by
    simpa using triangle_x_regularization coordinate normal distinct)

/-- The y-boundary residue is the negative interval coefficient in the dx convention. -/
lemma triangle_residue_y (coordinate : ℝ) (lower : 0 < coordinate) (upper : coordinate < 1) :
    Filter.Tendsto (fun normal => normal * triangleForm ![coordinate, normal] !![0, 1; 1, 0])
      (𝓝[≠] (0 : ℝ)) (𝓝 (-intervalCoefficient coordinate)) := by
  have continuous : ContinuousAt (fun normal : ℝ => -1 / (coordinate * (1 - coordinate - normal))) 0 := by
    fun_prop (disch := exact mul_ne_zero (ne_of_gt lower) (by simpa using ne_of_gt (sub_pos.mpr upper)))
  simpa [intervalCoefficient, neg_div] using residue_limit continuous (fun normal distinct => by
    simpa using triangle_y_regularization coordinate normal distinct)

/-- The diagonal-boundary residue is the positive interval coefficient in the chosen z,x coordinates. -/
lemma triangle_residue_diagonal (coordinate : ℝ) (lower : 0 < coordinate) (upper : coordinate < 1) :
    Filter.Tendsto (fun normal => normal *
      triangleForm ![coordinate, 1 - coordinate - normal] !![0, -1; 1, -1])
      (𝓝[≠] (0 : ℝ)) (𝓝 (intervalCoefficient coordinate)) := by
  have continuous : ContinuousAt (fun normal : ℝ => 1 / (coordinate * (1 - coordinate - normal))) 0 := by
    fun_prop (disch := exact mul_ne_zero (ne_of_gt lower) (by simpa using ne_of_gt (sub_pos.mpr upper)))
  simpa [intervalCoefficient] using residue_limit continuous (fun normal distinct => by
    simpa using triangle_diagonal_regularization coordinate normal distinct)

/-- The unit square coefficient, whose only affine poles are its four boundary lines. -/
noncomputable def squareCoefficient (point : Plane) : ℝ :=
  1 / (point 0 * point 1 * (1 - point 0) * (1 - point 1))

/-- The square two-form in the same orientation as both constituent triangles. -/
noncomputable def squareForm (point : Plane) : AlternatingMap ℝ Plane ℝ (Fin 2) :=
  squareCoefficient point • Matrix.detRowAlternating

/-- Affine pullback coefficient for the lower triangle, with unit positive Jacobian. -/
noncomputable def lowerTriangleCoefficient (point : Plane) : ℝ :=
  triangleCoefficient ![point 0 - point 1, point 1]

/-- Affine pullback coefficient for the upper triangle, with unit positive Jacobian. -/
noncomputable def upperTriangleCoefficient (point : Plane) : ℝ :=
  triangleCoefficient ![point 0, point 1 - point 0]

/-- Pulling the standard triangle back by (x,y) -> (x-y,y) preserves oriented area. -/
lemma lowerTriangle_pullback (point : Plane) (vectors : Matrix (Fin 2) (Fin 2) ℝ) :
    triangleForm ![point 0 - point 1, point 1] (vectors * !![1, 0; -1, 1]) =
      lowerTriangleCoefficient point * vectors.det := by
  change triangleCoefficient _ * Matrix.det (vectors * !![1, 0; -1, 1]) = _
  rw [Matrix.det_mul]
  simp [Matrix.det_fin_two, lowerTriangleCoefficient]

/-- Pulling the standard triangle back by (x,y) -> (x,y-x) also preserves oriented area. -/
lemma upperTriangle_pullback (point : Plane) (vectors : Matrix (Fin 2) (Fin 2) ℝ) :
    triangleForm ![point 0, point 1 - point 0] (vectors * !![1, -1; 0, 1]) =
      upperTriangleCoefficient point * vectors.det := by
  change triangleCoefficient _ * Matrix.det (vectors * !![1, -1; 0, 1]) = _
  rw [Matrix.det_mul]
  simp [Matrix.det_fin_two, upperTriangleCoefficient]

/-- The two rational triangle extensions cancel their shared diagonal pole. -/
lemma square_triangulation (point : Plane) (first : point 0 ≠ 0) (second : point 1 ≠ 0)
    (firstUpper : point 0 ≠ 1) (secondUpper : point 1 ≠ 1) (diagonal : point 0 ≠ point 1) :
    lowerTriangleCoefficient point + upperTriangleCoefficient point = squareCoefficient point := by
  have firstSlack : 1 - point 0 ≠ 0 := sub_ne_zero.mpr firstUpper.symm
  have secondSlack : 1 - point 1 ≠ 0 := sub_ne_zero.mpr secondUpper.symm
  have diagonalSlack : point 0 - point 1 ≠ 0 := sub_ne_zero.mpr diagonal
  have reverseSlack : point 1 - point 0 ≠ 0 := sub_ne_zero.mpr diagonal.symm
  unfold lowerTriangleCoefficient upperTriangleCoefficient triangleCoefficient squareCoefficient
  simp only [Matrix.cons_val_zero, Matrix.cons_val_one]
  have lowerSlack : 1 - (point 0 - point 1) - point 1 = 1 - point 0 := by ring
  have upperSlack : 1 - point 0 - (point 1 - point 0) = 1 - point 1 := by ring
  rw [lowerSlack, upperSlack]
  field_simp [first, second, firstSlack, secondSlack, diagonalSlack, reverseSlack]
  ring

/-- Triangulation equality holds at the level of alternating forms, not only coefficients. -/
lemma squareForm_triangulation (point : Plane) (first : point 0 ≠ 0) (second : point 1 ≠ 0)
    (firstUpper : point 0 ≠ 1) (secondUpper : point 1 ≠ 1) (diagonal : point 0 ≠ point 1) :
    lowerTriangleCoefficient point • Matrix.detRowAlternating +
      upperTriangleCoefficient point • Matrix.detRowAlternating = squareForm point := by
  rw [← add_smul, square_triangulation point first second firstUpper secondUpper diagonal]
  rfl

/-- The summed square continuation is continuous even on the former interior diagonal. -/
lemma squareCoefficient_continuousAt (point : Plane) (first : point 0 ≠ 0) (second : point 1 ≠ 0)
    (firstUpper : point 0 ≠ 1) (secondUpper : point 1 ≠ 1) :
    ContinuousAt squareCoefficient point := by
  unfold squareCoefficient
  fun_prop (disch := exact mul_ne_zero (mul_ne_zero (mul_ne_zero first second)
    (sub_ne_zero.mpr firstUpper.symm)) (sub_ne_zero.mpr secondUpper.symm))

/-- The square is the product of interval coefficients in the fixed affine chart. -/
lemma squareCoefficient_factorization (first second : ℝ) :
    squareCoefficient ![first, second] = intervalCoefficient first * intervalCoefficient second := by
  simp [squareCoefficient, intervalCoefficient, div_eq_mul_inv, mul_inv_rev]
  ring

/-- At x=0 the oriented coefficient residue is the interval coefficient in y. -/
lemma square_residue_x_zero (coordinate : ℝ) :
    Filter.Tendsto (fun normal => normal * squareCoefficient ![normal, coordinate])
      (𝓝[≠] (0 : ℝ)) (𝓝 (intervalCoefficient coordinate)) := by
  have limit := interval_residue_zero.mul_const (intervalCoefficient coordinate)
  simpa only [one_mul, squareCoefficient_factorization, mul_assoc] using limit

/-- At x=1 the residue has the negative interval coefficient in y. -/
lemma square_residue_x_one (coordinate : ℝ) :
    Filter.Tendsto (fun normal => (normal - 1) * squareCoefficient ![normal, coordinate])
      (𝓝[≠] (1 : ℝ)) (𝓝 (-intervalCoefficient coordinate)) := by
  have limit := interval_residue_one.mul_const (intervalCoefficient coordinate)
  simpa only [neg_one_mul, squareCoefficient_factorization, mul_assoc] using limit

/-- Contracting with the y-normal gives a negative residue at y=0. -/
lemma square_residue_y_zero (coordinate : ℝ) :
    Filter.Tendsto (fun normal => normal * (-squareCoefficient ![coordinate, normal]))
      (𝓝[≠] (0 : ℝ)) (𝓝 (-intervalCoefficient coordinate)) := by
  have limit := (interval_residue_zero.const_mul (intervalCoefficient coordinate)).neg
  have equivalent : (fun normal => -(intervalCoefficient coordinate *
      (normal * intervalCoefficient normal))) =
      (fun normal => normal * (-squareCoefficient ![coordinate, normal])) := by
    funext normal
    rw [squareCoefficient_factorization]
    ring
  rw [equivalent] at limit
  simpa using limit

/-- The y-normal orientation gives a positive residue at y=1. -/
lemma square_residue_y_one (coordinate : ℝ) :
    Filter.Tendsto (fun normal => (normal - 1) * (-squareCoefficient ![coordinate, normal]))
      (𝓝[≠] (1 : ℝ)) (𝓝 (intervalCoefficient coordinate)) := by
  have limit := (interval_residue_one.const_mul (intervalCoefficient coordinate)).neg
  have equivalent : (fun normal => -(intervalCoefficient coordinate *
      ((normal - 1) * intervalCoefficient normal))) =
      (fun normal => (normal - 1) * (-squareCoefficient ![coordinate, normal])) := by
    funext normal
    rw [squareCoefficient_factorization]
    ring
  rw [equivalent] at limit
  simpa using limit

end Signals.CanonicalForms