import Signals.Huygens
import Mathlib.Topology.MetricSpace.Lipschitz

namespace Signals.Quadrature

open MeasureTheory
open scoped NNReal Topology

/-- A measurable finite partition with one quadrature sample per cell.

The measure may be area restricted to a finite aperture. The partition covers
the coordinate space; zero-measure exterior cells contribute no weight.
-/
structure CellQuadrature {Coordinate : Type*} [MeasurableSpace Coordinate]
    (measure : Measure Coordinate) (cellCount : ℕ) where
  cell : Fin cellCount → Set Coordinate
  measurable : ∀ index, MeasurableSet (cell index)
  disjoint : Pairwise (fun first second => Disjoint (cell first) (cell second))
  cover : (⋃ index, cell index) = Set.univ
  sample : Fin cellCount → Coordinate

/-- The continuum measure decomposes into the actual restricted cell measures. -/
lemma CellQuadrature.measure_decomposition {Coordinate : Type*} [MeasurableSpace Coordinate]
    {measure : Measure Coordinate} {cellCount : ℕ} (quadrature : CellQuadrature measure cellCount) :
    measure = ∑ index, measure.restrict (quadrature.cell index) := by
  have decomposition := measure.restrict_iUnion quadrature.disjoint quadrature.measurable
  rw [quadrature.cover, Measure.restrict_univ, Measure.sum_fintype] at decomposition
  exact decomposition

/-- Integrating an integrable function is the sum of its integrals on the partition cells. -/
lemma CellQuadrature.integral_sum {Coordinate Value : Type*} [MeasurableSpace Coordinate]
    [NormedAddCommGroup Value] [NormedSpace ℝ Value] [CompleteSpace Value]
    {measure : Measure Coordinate} {cellCount : ℕ} (quadrature : CellQuadrature measure cellCount)
    (function : Coordinate → Value) (integrable : Integrable function measure) :
    (∫ point, function point ∂measure) =
      ∑ index, ∫ point, function point ∂measure.restrict (quadrature.cell index) := by
  conv_lhs => rw [quadrature.measure_decomposition]
  exact integral_finsetSum_measure (fun index _ => integrable.restrict)

/-- Cell weights are measured areas or masses, rather than fitted amplitude coefficients. -/
noncomputable def CellQuadrature.weight {Coordinate : Type*} [MeasurableSpace Coordinate]
    {measure : Measure Coordinate} {cellCount : ℕ} (quadrature : CellQuadrature measure cellCount)
    (index : Fin cellCount) : ℝ :=
  (measure.restrict (quadrature.cell index)).real Set.univ

/-- A finite partition preserves the total finite measured area in its quadrature weights. -/
lemma CellQuadrature.weight_sum {Coordinate : Type*} [MeasurableSpace Coordinate]
    {measure : Measure Coordinate} [IsFiniteMeasure measure] {cellCount : ℕ}
    (quadrature : CellQuadrature measure cellCount) :
    ∑ index, quadrature.weight index = measure.real Set.univ := by
  have equality := quadrature.integral_sum (fun _ => (1 : ℝ)) (integrable_const 1)
  simpa [weight, integral_const] using equality.symm

/-- The actual finite weighted sum obtained by sampling once in each measurable cell. -/
noncomputable def CellQuadrature.amplitude {Coordinate : Type*} [MeasurableSpace Coordinate]
    {measure : Measure Coordinate} {cellCount : ℕ} (quadrature : CellQuadrature measure cellCount)
    (density : Coordinate → ℂ) : ℂ :=
  ∑ index, quadrature.weight index • density (quadrature.sample index)

/-- A cellwise Lipschitz and mesh-distance bound yields an explicit finite quadrature error rate. -/
lemma CellQuadrature.amplitude_error_le {Coordinate : Type*} [MeasurableSpace Coordinate]
    [PseudoMetricSpace Coordinate] {measure : Measure Coordinate} [IsFiniteMeasure measure]
    {cellCount : ℕ} (quadrature : CellQuadrature measure cellCount) (density : Coordinate → ℂ)
    (integrable : Integrable density measure) (constant : ℝ≥0) (meshSize : ℝ)
    (lipschitz : ∀ index, ∀ᵐ point ∂measure.restrict (quadrature.cell index),
      ‖density (quadrature.sample index) - density point‖ ≤
        (constant : ℝ) * dist (quadrature.sample index) point)
    (meshBound : ∀ index, ∀ᵐ point ∂measure.restrict (quadrature.cell index),
      dist (quadrature.sample index) point ≤ meshSize) :
    ‖quadrature.amplitude density - ∫ point, density point ∂measure‖ ≤
      (constant : ℝ) * meshSize * measure.real Set.univ := by
  rw [amplitude, quadrature.integral_sum density integrable, ← Finset.sum_sub_distrib]
  calc
    ‖∑ index, (quadrature.weight index • density (quadrature.sample index) -
      ∫ point, density point ∂measure.restrict (quadrature.cell index))‖ ≤
        ∑ index, ‖quadrature.weight index • density (quadrature.sample index) -
          ∫ point, density point ∂measure.restrict (quadrature.cell index)‖ :=
      norm_sum_le _ _
    _ ≤ ∑ index, (constant : ℝ) * meshSize * quadrature.weight index := by
      apply Finset.sum_le_sum
      intro index _
      have bound : ∀ᵐ point ∂measure.restrict (quadrature.cell index),
          ‖density (quadrature.sample index) - density point‖ ≤ (constant : ℝ) * meshSize := by
        filter_upwards [lipschitz index, meshBound index] with point localLipschitz localMesh
        exact localLipschitz.trans (mul_le_mul_of_nonneg_left localMesh constant.property)
      simpa [weight, integral_const] using Signals.Huygens.integral_error_le
        (measure.restrict (quadrature.cell index)) (fun _ => density (quadrature.sample index))
        density (integrable_const _) integrable.restrict ((constant : ℝ) * meshSize) bound
    _ = (constant : ℝ) * meshSize * measure.real Set.univ := by
      rw [← Finset.mul_sum, quadrature.weight_sum]

/-- Global Lipschitz regularity discharges the cellwise density condition without assuming an error bound. -/
lemma CellQuadrature.amplitude_error_le_of_lipschitz {Coordinate : Type*}
    [MeasurableSpace Coordinate] [PseudoMetricSpace Coordinate]
    {measure : Measure Coordinate} [IsFiniteMeasure measure] {cellCount : ℕ}
    (quadrature : CellQuadrature measure cellCount) (density : Coordinate → ℂ)
    (integrable : Integrable density measure) (constant : ℝ≥0) (meshSize : ℝ)
    (lipschitz : LipschitzWith constant density)
    (meshBound : ∀ index, ∀ᵐ point ∂measure.restrict (quadrature.cell index),
      dist (quadrature.sample index) point ≤ meshSize) :
    ‖quadrature.amplitude density - ∫ point, density point ∂measure‖ ≤
      (constant : ℝ) * meshSize * measure.real Set.univ := by
  apply quadrature.amplitude_error_le density integrable constant meshSize _ meshBound
  intro index
  exact Filter.Eventually.of_forall (fun point => by
    simpa only [dist_eq_norm] using lipschitz.dist_le_mul (quadrature.sample index) point)

/-- Uniform regularity over a fixed detector/wavelength domain derives a comparison, not an assumed match. -/
lemma CellQuadrature.uniformComparison {Coordinate Detector : Type*} [MeasurableSpace Coordinate]
    [PseudoMetricSpace Coordinate] {measure : Measure Coordinate} [IsFiniteMeasure measure]
    {cellCount : ℕ} (quadrature : CellQuadrature measure cellCount)
    (density : Detector → Coordinate → ℂ) (domain : Set Detector) (nonempty : domain.Nonempty)
    (constant : ℝ≥0) (meshSize : ℝ) (meshNonnegative : 0 ≤ meshSize)
    (integrable : ∀ detector ∈ domain, Integrable (density detector) measure)
    (lipschitz : ∀ detector ∈ domain, LipschitzWith constant (density detector))
    (meshBound : ∀ index, ∀ᵐ point ∂measure.restrict (quadrature.cell index),
      dist (quadrature.sample index) point ≤ meshSize) :
    Signals.Huygens.AmplitudeComparison (fun detector => quadrature.amplitude (density detector))
      (fun detector => ∫ point, density detector point ∂measure) domain
      ((constant : ℝ) * meshSize * measure.real Set.univ) :=
  { domain_nonempty := nonempty
    tolerance_nonnegative := by positivity
    amplitudeError := fun detector member => quadrature.amplitude_error_le_of_lipschitz
      (density detector) (integrable detector member) constant meshSize
      (lipschitz detector member) meshBound }

/-- Vanishing mesh size implies quadrature-error convergence under one fixed Lipschitz constant. -/
lemma mesh_refinement_error_tendsto_zero {Coordinate : Type*} [MeasurableSpace Coordinate]
    [PseudoMetricSpace Coordinate] {measure : Measure Coordinate} [IsFiniteMeasure measure]
    (cellCount : ℕ → ℕ) (quadrature : ∀ refinement, CellQuadrature measure (cellCount refinement))
    (density : Coordinate → ℂ) (integrable : Integrable density measure) (constant : ℝ≥0)
    (lipschitz : LipschitzWith constant density) (meshSize : ℕ → ℝ)
    (meshBound : ∀ refinement index,
      ∀ᵐ point ∂measure.restrict ((quadrature refinement).cell index),
        dist ((quadrature refinement).sample index) point ≤ meshSize refinement)
    (meshConvergence : Filter.Tendsto meshSize Filter.atTop (𝓝 0)) :
    Filter.Tendsto (fun refinement =>
      ‖(quadrature refinement).amplitude density - ∫ point, density point ∂measure‖)
      Filter.atTop (𝓝 0) := by
  apply squeeze_zero (fun _ => norm_nonneg _)
    (fun refinement => (quadrature refinement).amplitude_error_le_of_lipschitz density
      integrable constant (meshSize refinement) lipschitz (meshBound refinement))
  have scaled : Filter.Tendsto
      (fun refinement => (constant : ℝ) * meshSize refinement * measure.real Set.univ)
      Filter.atTop (𝓝 ((constant : ℝ) * 0 * measure.real Set.univ)) :=
    (tendsto_const_nhds.mul meshConvergence).mul_const (measure.real Set.univ)
  simpa using scaled

/-- Translate measured planar cell weights into the finite aperture API with fixed field normalization. -/
noncomputable def CellQuadrature.toAperture {measure : Measure (ℝ × ℝ)} {cellCount : ℕ}
    (quadrature : CellQuadrature measure cellCount) (field : Signals.Huygens.FixedPlanarField) :
    Signals.Huygens.Aperture cellCount :=
  { point := fun index => field.point (quadrature.sample index)
    weight := fun index => (quadrature.weight index : ℂ) * field.normalization *
      field.transmission (quadrature.sample index) }

/-- The actual finite aperture sum is exactly the measured-cell quadrature of the fixed density. -/
lemma CellQuadrature.toAperture_amplitude {measure : Measure (ℝ × ℝ)} {cellCount : ℕ}
    (quadrature : CellQuadrature measure cellCount) (field : Signals.Huygens.FixedPlanarField)
    (detector : Signals.Huygens.Point3) :
    (quadrature.toAperture field).amplitude field.wave field.source detector =
      quadrature.amplitude (field.density detector) := by
  simp [Signals.Huygens.Aperture.amplitude, toAperture, amplitude,
    Signals.Huygens.FixedPlanarField.density, Complex.real_smul, mul_assoc]

end Signals.Quadrature