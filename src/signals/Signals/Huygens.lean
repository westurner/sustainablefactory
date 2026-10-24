import Architect
import Mathlib.Analysis.Complex.Exponential
import Mathlib.Analysis.Complex.Trigonometric
import Mathlib.Analysis.SpecialFunctions.Sqrt
import Mathlib.MeasureTheory.Integral.Bochner.Set
import Mathlib.MeasureTheory.Measure.Lebesgue.Basic
import Mathlib.Tactic
import Signals.Coherence
import Signals.Geometry
import Signals.Units

namespace Signals.Huygens

/-! Finite scalar Huygens-Fresnel sums and a guarded planar approximation.

Coordinates and wavelengths are in metres. Aperture weights include the supplied
quadrature, transmission, and obliquity factors. Intensity is an uncalibrated
squared complex amplitude, not irradiance or a normalized probability density.
Planar integrals require explicit regularity and integrability. Neither layer
asserts an exact vector boundary-value solution or a quantum path measure.
-/

/-- Three Cartesian spatial coordinates measured in metres. -/
abbrev Point3 := Fin 3 → ℝ

/-- Squared Euclidean separation in square metres. -/
def squaredDistance (source detector : Point3) : ℝ :=
  ∑ coordinate, (detector coordinate - source coordinate) ^ 2

/-- Euclidean separation in metres. -/
noncomputable def distance (source detector : Point3) : ℝ :=
  Real.sqrt (squaredDistance source detector)

/-- A point has zero separation from itself. -/
lemma distance_self (point : Point3) : distance point point = 0 := by
  simp [distance, squaredDistance]

/-- Squared Euclidean separation is nonnegative. -/
lemma squaredDistance_nonnegative (source detector : Point3) :
    0 ≤ squaredDistance source detector :=
  Finset.sum_nonneg (fun coordinate _ => sq_nonneg (detector coordinate - source coordinate))

/-- Distinct points have strictly positive separation. -/
lemma distance_pos_of_ne (source detector : Point3) (distinct : source ≠ detector) :
    0 < distance source detector := by
  obtain ⟨coordinate, unequal⟩ := Function.ne_iff.mp distinct
  have positive : 0 < (detector coordinate - source coordinate) ^ 2 :=
    sq_pos_of_ne_zero (sub_ne_zero.mpr unequal.symm)
  have lowerBound : (detector coordinate - source coordinate) ^ 2 ≤
      squaredDistance source detector :=
    Finset.single_le_sum (fun index _ => sq_nonneg (detector index - source index))
      (Finset.mem_univ coordinate)
  exact Real.sqrt_pos.mpr (lt_of_lt_of_le positive lowerBound)

/-- A scalar monochromatic wavelength with an explicit positive length. -/
@[blueprint "def:signals-monochromatic-wave"
  (title := "Positive scalar wavelength")
  (statement := /-- A monochromatic scalar reference supplies a positive wavelength in metres,
    giving angular wavenumber $k=2\pi/\lambda$. -/)]
structure MonochromaticWave where
  wavelength : Signals.Units.Length
  wavelength_positive : 0 < wavelength.meters

/-- Angular wavenumber in radians per metre. -/
noncomputable def MonochromaticWave.wavenumber (wave : MonochromaticWave) : ℝ :=
  2 * Real.pi / wave.wavelength.meters

/-- The outgoing scalar kernel `exp(i k r) / r`, omitting a common normalization.

Lean's division makes its value zero at coincident points. That totalized value
is not a physical Green-function value at the singularity; use `regularAt`.
-/
@[blueprint "def:signals-scalar-kernel"
  (title := "Outgoing scalar reference kernel")
  (statement := /-- The scalar reference kernel is $\exp(ikr)/r$, with a common normalization
    omitted. Its totalized coincident-point value is not a physical singular Green-function value. -/)]
noncomputable def MonochromaticWave.kernel (wave : MonochromaticWave)
    (source detector : Point3) : ℂ :=
  Complex.exp (Complex.I * ((wave.wavenumber * distance source detector : ℝ) : ℂ)) /
    (distance source detector : ℂ)

/-- An analytic two-segment path reference, independent of aperture summation. -/
noncomputable def MonochromaticWave.pathAmplitude (wave : MonochromaticWave)
    (firstDistance secondDistance : ℝ) : ℂ :=
  Complex.exp (Complex.I * ((wave.wavenumber * (firstDistance + secondDistance) : ℝ) : ℂ)) /
    ((firstDistance * secondDistance : ℝ) : ℂ)

/-- Multiplying the two propagation kernels agrees with the analytic path reference. -/
lemma MonochromaticWave.kernel_product (wave : MonochromaticWave)
    (source sample detector : Point3) :
    wave.kernel source sample * wave.kernel sample detector =
      wave.pathAmplitude (distance source sample) (distance sample detector) := by
  unfold kernel pathAmplitude
  rw [div_mul_div_comm, ← Complex.exp_add]
  push_cast
  congr 1
  ring

/-- Positive path lengths give a nonzero analytic reference with known absolute magnitude. -/
lemma MonochromaticWave.pathAmplitude_norm (wave : MonochromaticWave)
    (firstDistance secondDistance : ℝ) (firstPositive : 0 < firstDistance)
    (secondPositive : 0 < secondDistance) :
    ‖wave.pathAmplitude firstDistance secondDistance‖ = 1 / (firstDistance * secondDistance) := by
  rw [pathAmplitude, norm_div, Complex.norm_exp_I_mul_ofReal]
  simp only [Complex.norm_real, Real.norm_eq_abs, abs_of_pos (mul_pos firstPositive secondPositive)]

/-- Finite aperture samples with supplied complex quadrature coefficients. -/
structure Aperture (sampleCount : ℕ) where
  point : Fin sampleCount → Point3
  weight : Fin sampleCount → ℂ

/-- The sampled propagation avoids coincident source, aperture, and detector points. -/
@[blueprint "def:signals-aperture-regularity"
  (title := "Finite propagation regularity")
  (statement := /-- Each sampled aperture point must differ from both the source and detector.
    This regularity predicate excludes the totalized zero-distance singularities. -/)]
def Aperture.regularAt {sampleCount : ℕ} (aperture : Aperture sampleCount)
    (source detector : Point3) : Prop :=
  ∀ sample, aperture.point sample ≠ source ∧ aperture.point sample ≠ detector

/-- A finite source-to-aperture-to-detector Huygens-Fresnel sum. -/
@[blueprint "def:signals-finite-aperture-amplitude"
  (title := "Finite complex aperture sum")
  (statement := /-- Sum the supplied complex aperture coefficients times the source-to-sample
    and sample-to-detector scalar kernels. This finite algebraic evaluator is total;
    regularity is required separately for physical use. -/)]
noncomputable def Aperture.amplitude {sampleCount : ℕ} (aperture : Aperture sampleCount)
    (wave : MonochromaticWave) (source detector : Point3) : ℂ :=
  ∑ sample, aperture.weight sample * wave.kernel source (aperture.point sample) *
    wave.kernel (aperture.point sample) detector

/-- An empty aperture contributes no amplitude. -/
lemma Aperture.amplitude_empty (aperture : Aperture 0)
    (wave : MonochromaticWave) (source detector : Point3) :
    aperture.amplitude wave source detector = 0 := by
  simp [Aperture.amplitude]

/-- Apply a uniform complex transmission factor without changing aperture geometry. -/
def Aperture.scale {sampleCount : ℕ} (aperture : Aperture sampleCount) (factor : ℂ) :
    Aperture sampleCount :=
  { aperture with weight := fun sample => factor * aperture.weight sample }

/-- Uniform transmission acts linearly on the finite complex amplitude. -/
lemma Aperture.amplitude_scale {sampleCount : ℕ} (aperture : Aperture sampleCount)
    (factor : ℂ) (wave : MonochromaticWave) (source detector : Point3) :
    (aperture.scale factor).amplitude wave source detector =
      factor * aperture.amplitude wave source detector := by
  simp [amplitude, scale, mul_assoc, Finset.mul_sum]

/-- Coincidence with a source sample is rejected by the regularity predicate. -/
lemma Aperture.not_regularAt_source {sampleCount : ℕ} (aperture : Aperture sampleCount)
    (source detector : Point3) (sample : Fin sampleCount)
    (coincident : aperture.point sample = source) : ¬aperture.regularAt source detector := by
  intro regular
  exact (regular sample).1 coincident

/-- Coincidence with a detector sample is rejected by the regularity predicate. -/
lemma Aperture.not_regularAt_detector {sampleCount : ℕ} (aperture : Aperture sampleCount)
    (source detector : Point3) (sample : Fin sampleCount)
    (coincident : aperture.point sample = detector) : ¬aperture.regularAt source detector := by
  intro regular
  exact (regular sample).2 coincident

/-- Regular source-to-sample propagation has a positive denominator distance. -/
lemma Aperture.source_distance_pos {sampleCount : ℕ} (aperture : Aperture sampleCount)
    (source detector : Point3) (regular : aperture.regularAt source detector)
    (sample : Fin sampleCount) : 0 < distance source (aperture.point sample) :=
  distance_pos_of_ne _ _ (regular sample).1.symm

/-- Regular sample-to-detector propagation has a positive denominator distance. -/
lemma Aperture.detector_distance_pos {sampleCount : ℕ} (aperture : Aperture sampleCount)
    (source detector : Point3) (regular : aperture.regularAt source detector)
    (sample : Fin sampleCount) : 0 < distance (aperture.point sample) detector :=
  distance_pos_of_ne _ _ (regular sample).2

/-- A supplied positive lower bound on all finite source and detector separations. -/
structure ApertureSeparation {sampleCount : ℕ} (aperture : Aperture sampleCount)
    (source detector : Point3) where
  minimum : Signals.Units.Length
  minimum_positive : 0 < minimum.meters
  sourceBound : ∀ sample, minimum.meters ≤ distance source (aperture.point sample)
  detectorBound : ∀ sample, minimum.meters ≤ distance (aperture.point sample) detector

/-- A positive separation certificate implies regularity without totalized singular values. -/
@[blueprint "lem:signals-separation-regularity"
  (title := "Positive separation implies regularity")
  (statement := /-- A positive lower bound on every source-sample and sample-detector
    separation implies finite aperture regularity. -/)
  (proof := /-- Coincident points have distance zero, contradicting the positive lower bound. -/)
  (latexEnv := "lemma")]
lemma ApertureSeparation.regular {sampleCount : ℕ} {aperture : Aperture sampleCount}
    {source detector : Point3} (separation : ApertureSeparation aperture source detector) :
    aperture.regularAt source detector := by
  intro sample
  constructor
  · intro coincident
    have bound := separation.sourceBound sample
    rw [coincident, distance_self] at bound
    exact (not_le_of_gt separation.minimum_positive) bound
  · intro coincident
    have bound := separation.detectorBound sample
    rw [coincident, distance_self] at bound
    exact (not_le_of_gt separation.minimum_positive) bound

/-- Squared complex amplitude, without detector or power calibration. -/
@[blueprint "def:signals-scalar-intensity"
  (title := "Uncalibrated scalar intensity")
  (statement := /-- Define $I(a)=|a|^2$ for a complex amplitude $a$. Detector calibration,
    irradiance normalization and a probability interpretation are not supplied. -/)]
def intensity (amplitude : ℂ) : ℝ := Complex.normSq amplitude

/-- Squared complex amplitudes are nonnegative. -/
lemma intensity_nonnegative (amplitude : ℂ) : 0 ≤ intensity amplitude :=
  Complex.normSq_nonneg amplitude

/-- Superposition includes the coherent cross term, not just the sum of intensities. -/
@[blueprint "lem:signals-coherent-cross-term"
  (title := "Coherent superposition law")
  (statement := /-- $I(a+b)=I(a)+I(b)+2\operatorname{Re}(a\overline b)$.
    Complex phases cannot be replaced by nonnegative path weights without a separate bridge. -/)
  (proof := /-- Apply the squared complex norm addition identity. -/)
  (latexEnv := "lemma")]
lemma intensity_superposition (first second : ℂ) :
    intensity (first + second) = intensity first + intensity second +
      2 * (first * star second).re :=
  Complex.normSq_add first second

/-- Equal coherent contributions give four times the single contribution's intensity. -/
lemma intensity_constructive (amplitude : ℂ) :
    intensity (amplitude + amplitude) = 4 * intensity amplitude := by
  simp [intensity, Complex.normSq]
  ring

/-- Opposite coherent contributions cancel exactly. -/
@[blueprint "lem:signals-destructive-interference"
  (title := "Nonzero-path cancellation control")
  (statement := /-- For any complex amplitude $a$, $I(a+(-a))=0$; this also permits
    nonzero individual contributions. A dark fringe need not mean either path vanishes. -/)
  (proof := /-- The opposite amplitudes sum to zero, whose squared norm is zero. -/)
  (latexEnv := "lemma")]
lemma intensity_destructive (amplitude : ℂ) : intensity (amplitude + -amplitude) = 0 := by
  simp [intensity]

/-- Equal contributions with a quarter-turn relative phase have twice the individual intensity. -/
lemma intensity_quadrature (amplitude : ℂ) :
    intensity (amplitude + Complex.I * amplitude) = 2 * intensity amplitude := by
  simp [intensity, Complex.normSq, Complex.mul_re, Complex.mul_im]
  ring

/-- A comparison certifies already fixed functions on a nonempty domain at a fixed tolerance. -/
@[blueprint "def:signals-amplitude-comparison"
  (title := "Fixed nonvacuous amplitude comparisons")
  (statement := /-- Two fixed complex-valued functions on a nonempty detector domain
    satisfy a supplied nonnegative uniform absolute-error tolerance. This record is a
    conditional certificate, not evidence that independently evaluated models agree. -/)]
structure AmplitudeComparison {Detector : Type*} (candidate classical : Detector → ℂ)
    (domain : Set Detector) (tolerance : ℝ) : Prop where
  domain_nonempty : domain.Nonempty
  tolerance_nonnegative : 0 ≤ tolerance
  amplitudeError : ∀ detector ∈ domain, ‖candidate detector - classical detector‖ ≤ tolerance

/-- A single held-out disagreement larger than the fixed tolerance rejects a comparison. -/
@[blueprint "lem:signals-comparison-rejection"
  (title := "Held-out disagreement rejection")
  (statement := /-- One detector in the fixed domain whose amplitude disagreement exceeds
    the fixed tolerance rules out the comparison certificate. -/)
  (proof := /-- The observed strict inequality contradicts the certificate's pointwise upper bound. -/)
  (latexEnv := "lemma")]
lemma AmplitudeComparison.reject {Detector : Type*} (candidate classical : Detector → ℂ)
    (domain : Set Detector) (tolerance : ℝ) (detector : Detector) (member : detector ∈ domain)
    (disagreement : tolerance < ‖candidate detector - classical detector‖) :
    ¬AmplitudeComparison candidate classical domain tolerance := by
  intro comparison
  exact (not_le_of_gt disagreement) (comparison.amplitudeError detector member)

/-- Absolute intensity error stays controlled even when the reference intensity vanishes. -/
@[blueprint "lem:signals-absolute-intensity-error"
  (title := "Dark-fringe-safe intensity error")
  (statement := /-- $|I(a)-I(b)|\le |a-b|(|a|+|b|)$, including at zero reference intensity.
    No relative-error division is used. -/)
  (proof := /-- Factor the difference of squared norms and use the reverse triangle inequality. -/)
  (latexEnv := "lemma")]
lemma intensity_error_le (candidate classical : ℂ) :
    |intensity candidate - intensity classical| ≤
      ‖candidate - classical‖ * (‖candidate‖ + ‖classical‖) := by
  have factor : ‖candidate‖ ^ 2 - ‖classical‖ ^ 2 =
      (‖candidate‖ - ‖classical‖) * (‖candidate‖ + ‖classical‖) := by ring
  rw [intensity, intensity, Complex.normSq_eq_norm_sq, Complex.normSq_eq_norm_sq,
    factor, abs_mul, abs_of_nonneg (add_nonneg (norm_nonneg _) (norm_nonneg _))]
  exact mul_le_mul_of_nonneg_right (abs_norm_sub_norm_le candidate classical) (by positivity)

/-- A certified amplitude comparison yields an absolute, not relative, intensity error. -/
lemma AmplitudeComparison.intensityError {Detector : Type*} {candidate classical : Detector → ℂ}
    {domain : Set Detector} {tolerance : ℝ}
    (comparison : AmplitudeComparison candidate classical domain tolerance)
    (detector : Detector) (member : detector ∈ domain) :
    |intensity (candidate detector) - intensity (classical detector)| ≤
      tolerance * (‖candidate detector‖ + ‖classical detector‖) :=
  (intensity_error_le _ _).trans
    (mul_le_mul_of_nonneg_right (comparison.amplitudeError detector member) (by positivity))

/-- Composition keeps two independently certified amplitude-error budgets separate and additive. -/
@[blueprint "lem:signals-comparison-composition"
  (title := "Additive comparison budgets")
  (statement := /-- Two certified comparisons on the same domain compose with the sum of
    their fixed absolute-error tolerances. -/)
  (proof := /-- Split the difference through the intermediate function and apply the triangle inequality. -/)
  (latexEnv := "lemma")]
lemma AmplitudeComparison.compose {Detector : Type*} {candidate intermediate classical : Detector → ℂ}
    {domain : Set Detector} {firstTolerance secondTolerance : ℝ}
    (first : AmplitudeComparison candidate intermediate domain firstTolerance)
    (second : AmplitudeComparison intermediate classical domain secondTolerance) :
    AmplitudeComparison candidate classical domain (firstTolerance + secondTolerance) := by
  refine ⟨first.domain_nonempty, add_nonneg first.tolerance_nonnegative
    second.tolerance_nonnegative, ?_⟩
  intro detector member
  calc
    ‖candidate detector - classical detector‖ =
        ‖(candidate detector - intermediate detector) +
          (intermediate detector - classical detector)‖ := by congr 1; ring
    _ ≤ ‖candidate detector - intermediate detector‖ +
        ‖intermediate detector - classical detector‖ := norm_add_le _ _
    _ ≤ firstTolerance + secondTolerance :=
      add_le_add (first.amplitudeError detector member) (second.amplitudeError detector member)

/-- Fixed scalar two-kernel planar-aperture data, not an exact Helmholtz boundary solution.

Coordinates use metres and integration uses planar Lebesgue area. Transmission
and normalization include the chosen source, quadrature, and obliquity convention;
they do not supply an irradiance calibration or change when the aperture mask changes.
-/
@[blueprint "def:signals-fixed-planar-field"
  (title := "Fixed planar scalar approximation")
  (statement := /-- Fix the wave, source, aperture plane, complex transmission and normalization.
    The resulting two-kernel density is integrated against planar area; it is not an exact
    Helmholtz boundary solution or a calibrated irradiance model. -/)]
structure FixedPlanarField where
  wave : MonochromaticWave
  source : Point3
  height : ℝ
  transmission : ℝ × ℝ → ℂ
  normalization : ℂ

/-- Embed aperture coordinates in the fixed plane. -/
def FixedPlanarField.point (field : FixedPlanarField) (coordinate : ℝ × ℝ) : Point3 :=
  ![coordinate.1, coordinate.2, field.height]

/-- The fixed-field approximation density under the explicitly supplied normalization. -/
noncomputable def FixedPlanarField.density (field : FixedPlanarField) (detector : Point3)
    (coordinate : ℝ × ℝ) : ℂ :=
  field.normalization * field.transmission coordinate *
    field.wave.kernel field.source (field.point coordinate) *
    field.wave.kernel (field.point coordinate) detector

/-- Integrate the fixed scalar field against area in the aperture's two-dimensional coordinates. -/
noncomputable def FixedPlanarField.amplitude (field : FixedPlanarField)
    (region : Set (ℝ × ℝ)) (detector : Point3) : ℂ :=
  ∫ coordinate in region, field.density detector coordinate

/-- Evaluation requires regular propagation and integrability rather than totalized bad integrals. -/
@[blueprint "def:signals-planar-evaluation-guard"
  (title := "Planar evaluation assumptions")
  (statement := /-- On the selected region, every planar propagation point avoids the source
    and detector, and the fixed density is integrable. Both conditions are explicit assumptions. -/)]
structure IntegrablePlanarEvaluation (field : FixedPlanarField) (region : Set (ℝ × ℝ))
    (detector : Point3) : Prop where
  regular : ∀ coordinate ∈ region,
    field.point coordinate ≠ field.source ∧ field.point coordinate ≠ detector
  integrable : MeasureTheory.IntegrableOn (field.density detector) region

/-- A proof-gated continuum amplitude for the selected fixed-field approximation. -/
noncomputable def FixedPlanarField.regularAmplitude (field : FixedPlanarField)
    (region : Set (ℝ × ℝ)) (detector : Point3)
    (_evaluation : IntegrablePlanarEvaluation field region detector) : ℂ :=
  field.amplitude region detector

/-- Disjoint-mask addition uses the same incident field and propagation convention on both regions. -/
@[blueprint "lem:signals-disjoint-planar-masks"
  (title := "Fixed-field mask addition")
  (statement := /-- For disjoint aperture masks, a measurable second mask and guarded
    integrable evaluations, the union's fixed-field amplitude is the sum of the two amplitudes. -/)
  (proof := /-- Apply disjoint set-integral addition to the same density on both masks. -/)
  (latexEnv := "lemma")]
lemma FixedPlanarField.amplitude_union (field : FixedPlanarField) (first second : Set (ℝ × ℝ))
    (detector : Point3) (disjoint : Disjoint first second) (secondMeasurable : MeasurableSet second)
    (firstEvaluation : IntegrablePlanarEvaluation field first detector)
    (secondEvaluation : IntegrablePlanarEvaluation field second detector) :
    field.amplitude (first ∪ second) detector =
      field.amplitude first detector + field.amplitude second detector :=
  MeasureTheory.setIntegral_union disjoint secondMeasurable
    firstEvaluation.integrable secondEvaluation.integrable

/-- A finite-area pointwise density error controls the integral error; it is not a quadrature rate. -/
@[blueprint "lem:signals-integrated-density-error"
  (title := "Finite-measure integral error")
  (statement := /-- For integrable complex densities on a finite measure space, an almost-everywhere
    bound $|f-g|\le\varepsilon$ gives $|\int f-\int g|\le\varepsilon\mu(X)$.
    This alone is not a mesh-dependent quadrature rate. -/)
  (proof := /-- Integrate the difference and apply the constant norm bound on its integral. -/)
  (latexEnv := "lemma")]
lemma integral_error_le {Coordinate : Type*} [MeasurableSpace Coordinate]
    (measure : MeasureTheory.Measure Coordinate) [MeasureTheory.IsFiniteMeasure measure]
    (candidate classical : Coordinate → ℂ)
    (candidateIntegrable : MeasureTheory.Integrable candidate measure)
    (classicalIntegrable : MeasureTheory.Integrable classical measure) (error : ℝ)
    (densityError : ∀ᵐ coordinate ∂measure, ‖candidate coordinate - classical coordinate‖ ≤ error) :
    ‖(∫ coordinate, candidate coordinate ∂measure) -
      (∫ coordinate, classical coordinate ∂measure)‖ ≤ error * measure.real Set.univ := by
  rw [← MeasureTheory.integral_sub candidateIntegrable classicalIntegrable]
  exact MeasureTheory.norm_integral_le_of_norm_le_const densityError

/-- Two finite slit apertures with independent open/closed boundary masks. -/
structure DoubleSlit (firstCount secondCount : ℕ) where
  wave : MonochromaticWave
  source : Point3
  first : Aperture firstCount
  second : Aperture secondCount
  firstOpen : Bool
  secondOpen : Bool

/-- The total scalar field at an arbitrary three-dimensional detector position. -/
noncomputable def DoubleSlit.amplitude {firstCount secondCount : ℕ}
    (slits : DoubleSlit firstCount secondCount) (detector : Point3) : ℂ :=
  (if slits.firstOpen then slits.first.amplitude slits.wave slits.source detector else 0) +
    (if slits.secondOpen then slits.second.amplitude slits.wave slits.source detector else 0)

/-- The detector's uncalibrated scalar intensity profile. -/
noncomputable def DoubleSlit.intensity {firstCount secondCount : ℕ}
    (slits : DoubleSlit firstCount secondCount) (detector : Point3) : ℝ :=
  Signals.Huygens.intensity (slits.amplitude detector)

/-- Conservative regularity requires both apertures to avoid coincident points, even if masked. -/
structure RegularSlitEvaluation {firstCount secondCount : ℕ}
    (slits : DoubleSlit firstCount secondCount) (detector : Point3) : Prop where
  firstRegular : slits.first.regularAt slits.source detector
  secondRegular : slits.second.regularAt slits.source detector

/-- Evaluate only after a caller supplies regularity for both finite apertures. -/
@[blueprint "def:signals-guarded-slit-amplitude"
  (title := "Guarded masked slit evaluator")
  (statement := /-- Independent Boolean masks select the two finite aperture contributions.
    The guarded evaluator requires regularity for both apertures even when a mask is closed. -/)]
noncomputable def DoubleSlit.regularAmplitude {firstCount secondCount : ℕ}
    (slits : DoubleSlit firstCount secondCount) (detector : Point3)
    (_regular : RegularSlitEvaluation slits detector) : ℂ :=
  slits.amplitude detector

/-- The guarded evaluator preserves the original algebraic amplitude on regular inputs. -/
lemma DoubleSlit.regularAmplitude_eq {firstCount secondCount : ℕ}
    (slits : DoubleSlit firstCount secondCount) (detector : Point3)
    (regular : RegularSlitEvaluation slits detector) :
    slits.regularAmplitude detector regular = slits.amplitude detector := rfl

/-- Opening both slits gives the sum of the two complex contributions. -/
lemma DoubleSlit.amplitude_both_open {firstCount secondCount : ℕ}
    (slits : DoubleSlit firstCount secondCount) (detector : Point3)
    (first_open : slits.firstOpen = true) (second_open : slits.secondOpen = true) :
    slits.amplitude detector = slits.first.amplitude slits.wave slits.source detector +
      slits.second.amplitude slits.wave slits.source detector := by
  simp [DoubleSlit.amplitude, first_open, second_open]

/-- The two-open-slit profile contains the phase-sensitive interference term. -/
@[blueprint "lem:signals-open-slit-interference"
  (title := "Two-open-slit coherent intensity")
  (statement := /-- When both slit masks are open, the intensity includes the coherent cross
    term of their complex aperture amplitudes, rather than only the sum of individual intensities. -/)
  (proof := /-- Derive the masked amplitude sum and apply the coherent superposition law. -/)
  (latexEnv := "lemma")]
lemma DoubleSlit.intensity_both_open {firstCount secondCount : ℕ}
    (slits : DoubleSlit firstCount secondCount) (detector : Point3)
    (first_open : slits.firstOpen = true) (second_open : slits.secondOpen = true) :
    slits.intensity detector =
      Signals.Huygens.intensity (slits.first.amplitude slits.wave slits.source detector) +
      Signals.Huygens.intensity (slits.second.amplitude slits.wave slits.source detector) +
      2 * (slits.first.amplitude slits.wave slits.source detector *
        star (slits.second.amplitude slits.wave slits.source detector)).re := by
  rw [DoubleSlit.intensity, slits.amplitude_both_open detector first_open second_open]
  exact intensity_superposition _ _

/-- Closing the second slit removes its amplitude and coherent cross term. -/
lemma DoubleSlit.amplitude_first_only {firstCount secondCount : ℕ}
    (slits : DoubleSlit firstCount secondCount) (detector : Point3)
    (first_open : slits.firstOpen = true) (second_closed : slits.secondOpen = false) :
    slits.amplitude detector = slits.first.amplitude slits.wave slits.source detector := by
  simp [DoubleSlit.amplitude, first_open, second_closed]

/-- Closing the first slit leaves only the second finite aperture contribution. -/
lemma DoubleSlit.amplitude_second_only {firstCount secondCount : ℕ}
    (slits : DoubleSlit firstCount secondCount) (detector : Point3)
    (firstClosed : slits.firstOpen = false) (secondOpen : slits.secondOpen = true) :
    slits.amplitude detector = slits.second.amplitude slits.wave slits.source detector := by
  simp [DoubleSlit.amplitude, firstClosed, secondOpen]

/-- Closing both slits gives zero scalar intensity. -/
lemma DoubleSlit.intensity_closed {firstCount secondCount : ℕ}
    (slits : DoubleSlit firstCount secondCount) (detector : Point3)
    (first_closed : slits.firstOpen = false) (second_closed : slits.secondOpen = false) :
    slits.intensity detector = 0 := by
  simp [DoubleSlit.intensity, DoubleSlit.amplitude, Signals.Huygens.intensity,
    first_closed, second_closed]

/-- A finite weighted sum of history phases `exp(i action / hbar)`.

Actions and `hbar` use a common action unit (joule seconds in SI). This is a
finite algebraic sum, not a continuum path integral; physical use needs positive
`hbar` and a separately justified history discretization.
-/
noncomputable def finiteHistoryAmplitude {historyCount : ℕ}
    (action : Fin historyCount → ℝ) (coefficient : Fin historyCount → ℂ) (hbar : ℝ) : ℂ :=
  ∑ history, coefficient history *
    Complex.exp (Complex.I * ((action history / hbar : ℝ) : ℂ))

/-- Finite history amplitudes are linear in their supplied complex coefficients. -/
lemma finiteHistoryAmplitude_add {historyCount : ℕ} (action : Fin historyCount → ℝ)
    (first second : Fin historyCount → ℂ) (hbar : ℝ) :
    finiteHistoryAmplitude action (first + second) hbar =
      finiteHistoryAmplitude action first hbar + finiteHistoryAmplitude action second hbar := by
  simp [finiteHistoryAmplitude, add_mul, Finset.sum_add_distrib]

/-- A positive action scale in the same units as each supplied action (joule seconds in SI). -/
@[blueprint "def:signals-positive-action-scale"
  (title := "Positive finite-history action scale")
  (statement := /-- A positive action scale permits finite weighted history phases
    $\exp(iS/\hbar)$ with actions in the same units. This supplies neither a continuum
    quantum path measure nor a justified physical history discretization. -/)]
structure ActionScale where
  hbar : ℝ
  positive : 0 < hbar

/-- The positive action scale cannot be the totalized zero divisor. -/
lemma ActionScale.nonzero (scale : ActionScale) : scale.hbar ≠ 0 :=
  ne_of_gt scale.positive

/-- A finite history amplitude whose action scale is required to be positive. -/
noncomputable def ActionScale.amplitude {historyCount : ℕ} (scale : ActionScale)
    (action : Fin historyCount → ℝ) (coefficient : Fin historyCount → ℂ) : ℂ :=
  finiteHistoryAmplitude action coefficient scale.hbar

/-- The positive-scale wrapper preserves finite coefficient linearity. -/
lemma ActionScale.amplitude_add {historyCount : ℕ} (scale : ActionScale)
    (action : Fin historyCount → ℝ) (first second : Fin historyCount → ℂ) :
    scale.amplitude action (first + second) =
      scale.amplitude action first + scale.amplitude action second :=
  finiteHistoryAmplitude_add action first second scale.hbar

/-! ## Analytic Fraunhofer rectangular double-slit benchmark

The benchmark below implements the paraxial/Fraunhofer far-field formula for two
equal uniformly illuminated rectangular slits of width `a`, height `b`, and
center-to-center separation `d` on a screen at distance `L`:
`I(x, y) = 4 I_0 sinc²(π a x / (λ L)) sinc²(π b y / (λ L)) cos²(π d x / (λ L))`.
This is an explicit analytic reference for far-field comparisons; it is not a
theorem about near-field discrete aperture sums.
-/

/-- The unnormalized cardinal sine `sinc(z) = sin(z) / z` with `sinc(0) = 1`. -/
@[blueprint "def:signals-unnormalized-sinc"
  (title := "Unnormalized cardinal sine")
  (statement := /-- Define $\operatorname{sinc}(z)=\sin(z)/z$ for $z\ne 0$ and
    $\operatorname{sinc}(0)=1$. -/)]
noncomputable def unnormalizedSinc (z : ℝ) : ℝ :=
  if z = 0 then 1 else Real.sin z / z

/-- At zero argument, `unnormalizedSinc` evaluates to one. -/
@[simp]
lemma unnormalizedSinc_zero : unnormalizedSinc 0 = 1 := by
  simp [unnormalizedSinc]

/-- `unnormalizedSinc` is an even function. -/
lemma unnormalizedSinc_even (z : ℝ) : unnormalizedSinc (-z) = unnormalizedSinc z := by
  by_cases hz : z = 0
  · subst hz
    simp
  · have hneg : -z ≠ 0 := neg_ne_zero.mpr hz
    simp [unnormalizedSinc, hz, hneg, Real.sin_neg, neg_div_neg_eq]

/-- `unnormalizedSinc` vanishes at every nonzero integer multiple of `π`. -/
@[blueprint "lem:signals-sinc-int-pi-zero"
  (title := "Cardinal sine zeros at nonzero integer multiples of π")
  (statement := /-- For every nonzero integer $n\in\mathbb Z$,
    $\operatorname{sinc}(n\pi)=0$. -/)
  (proof := /-- Since $n\ne 0$ and $\pi\ne 0$, $n\pi\ne 0$ and $\sin(n\pi)=0$. -/)
  (latexEnv := "lemma")]
lemma unnormalizedSinc_int_mul_pi (n : ℤ) (nonzero : n ≠ 0) :
    unnormalizedSinc ((n : ℝ) * Real.pi) = 0 := by
  have h_arg : (n : ℝ) * Real.pi ≠ 0 :=
    mul_ne_zero (Int.cast_ne_zero.mpr nonzero) Real.pi_ne_zero
  simp [unnormalizedSinc, h_arg, Real.sin_int_mul_pi]

/-- Analytic Fraunhofer far-field intensity benchmark for two equal rectangular slits. -/
@[blueprint "def:signals-fraunhofer-double-slit-benchmark"
  (title := "Fraunhofer rectangular double-slit intensity benchmark")
  (statement := /-- For single-slit on-axis scale $I_0$, slit width $a$, height $b$,
    center separation $d$, wavelength $\lambda$, and screen distance $L$, define
    $I_{\mathrm{F}}(x,y)=4I_0\operatorname{sinc}^2(\pi a x/(\lambda L))
    \operatorname{sinc}^2(\pi b y/(\lambda L))\cos^2(\pi d x/(\lambda L))$. -/)]
noncomputable def fraunhoferRectangularDoubleSlit
    (singleSlitScale slitWidth slitHeight separation wavelength screenDistance x y : ℝ) : ℝ :=
  4 * singleSlitScale *
    (unnormalizedSinc (Real.pi * slitWidth * x / (wavelength * screenDistance))) ^ 2 *
    (unnormalizedSinc (Real.pi * slitHeight * y / (wavelength * screenDistance))) ^ 2 *
    (Real.cos (Real.pi * separation * x / (wavelength * screenDistance))) ^ 2

/-- The Fraunhofer benchmark is nonnegative when the single-slit scale `I_0` is nonnegative. -/
@[blueprint "lem:signals-fraunhofer-nonnegative"
  (title := "Nonnegativity of the Fraunhofer double-slit benchmark")
  (statement := /-- When $I_0\ge 0$, $I_{\mathrm{F}}(x,y)\ge 0$ for all $(x,y)$. -/)
  (proof := /-- Product of $4I_0\ge 0$ and three squared real factors. -/)
  (latexEnv := "lemma")]
lemma fraunhoferRectangularDoubleSlit_nonnegative
    (singleSlitScale slitWidth slitHeight separation wavelength screenDistance x y : ℝ)
    (scale_nonneg : 0 ≤ singleSlitScale) :
    0 ≤ fraunhoferRectangularDoubleSlit
      singleSlitScale slitWidth slitHeight separation wavelength screenDistance x y := by
  unfold fraunhoferRectangularDoubleSlit
  positivity

/-- On the optical axis `(x, y) = (0, 0)`, the Fraunhofer benchmark equals `4 * I_0`. -/
@[blueprint "lem:signals-fraunhofer-on-axis"
  (title := "On-axis constructive Fraunhofer maximum")
  (statement := /-- At $(x,y)=(0,0)$, $I_{\mathrm{F}}(0,0)=4I_0$. -/)
  (proof := /-- Both $\operatorname{sinc}(0)$ factors and $\cos(0)$ equal $1$. -/)
  (latexEnv := "lemma")]
lemma fraunhoferRectangularDoubleSlit_onAxis
    (singleSlitScale slitWidth slitHeight separation wavelength screenDistance : ℝ) :
    fraunhoferRectangularDoubleSlit
      singleSlitScale slitWidth slitHeight separation wavelength screenDistance 0 0 =
      4 * singleSlitScale := by
  simp [fraunhoferRectangularDoubleSlit]

/-- The Fraunhofer benchmark is symmetric under planar inversion `(x, y) ↦ (-x, -y)`. -/
@[blueprint "lem:signals-fraunhofer-even-symmetry"
  (title := "Planar inversion symmetry of the Fraunhofer benchmark")
  (statement := /-- For all $(x,y)$, $I_{\mathrm{F}}(-x,-y)=I_{\mathrm{F}}(x,y)$. -/)
  (proof := /-- Use evenness of $\operatorname{sinc}$ and $\cos$. -/)
  (latexEnv := "lemma")]
lemma fraunhoferRectangularDoubleSlit_even
    (singleSlitScale slitWidth slitHeight separation wavelength screenDistance x y : ℝ) :
    fraunhoferRectangularDoubleSlit
      singleSlitScale slitWidth slitHeight separation wavelength screenDistance (-x) (-y) =
    fraunhoferRectangularDoubleSlit
      singleSlitScale slitWidth slitHeight separation wavelength screenDistance x y := by
  unfold fraunhoferRectangularDoubleSlit
  have hx : Real.pi * slitWidth * (-x) / (wavelength * screenDistance) =
      -(Real.pi * slitWidth * x / (wavelength * screenDistance)) := by ring
  have hy : Real.pi * slitHeight * (-y) / (wavelength * screenDistance) =
      -(Real.pi * slitHeight * y / (wavelength * screenDistance)) := by ring
  have hd : Real.pi * separation * (-x) / (wavelength * screenDistance) =
      -(Real.pi * separation * x / (wavelength * screenDistance)) := by ring
  rw [hx, hy, hd, unnormalizedSinc_even, unnormalizedSinc_even, Real.cos_neg]

/-- At the first half-period interference minimum `x = λ L / (2 d)`, the Fraunhofer
double-slit intensity vanishes identically. -/
@[blueprint "lem:signals-fraunhofer-dark-fringe"
  (title := "First Fraunhofer destructive interference minimum")
  (statement := /-- For $d\ne 0$, $\lambda\ne 0$, and $L\ne 0$, at $x=\lambda L/(2d)$
    the interference factor $\cos(\pi/2)=0$ forces $I_{\mathrm{F}}(\lambda L/(2d),y)=0$. -/)
  (proof := /-- Simplify the cosine argument to $\pi/2$ and apply $\cos(\pi/2)=0$. -/)
  (latexEnv := "lemma")]
lemma fraunhoferRectangularDoubleSlit_dark_fringe
    (singleSlitScale slitWidth slitHeight separation wavelength screenDistance y : ℝ)
    (h_sep : separation ≠ 0) (h_wave : wavelength ≠ 0) (h_dist : screenDistance ≠ 0) :
    fraunhoferRectangularDoubleSlit
      singleSlitScale slitWidth slitHeight separation wavelength screenDistance
      (wavelength * screenDistance / (2 * separation)) y = 0 := by
  unfold fraunhoferRectangularDoubleSlit
  have h_arg :
      Real.pi * separation * (wavelength * screenDistance / (2 * separation)) /
        (wavelength * screenDistance) = Real.pi / 2 := by
    field_simp [h_sep, h_wave, h_dist]
  rw [h_arg, Real.cos_pi_div_two]
  ring

/-- At any nonzero integer single-slit diffraction minimum `x = n λ L / a`, the
Fraunhofer intensity vanishes identically. -/
@[blueprint "lem:signals-fraunhofer-diffraction-null"
  (title := "Single-slit Fraunhofer diffraction envelope nulls")
  (statement := /-- For $n\in\mathbb Z\setminus\{0\}$, $a\ne 0$, $\lambda\ne 0$, and $L\ne 0$,
    at $x=n\lambda L/a$ the horizontal envelope $\operatorname{sinc}(n\pi)=0$ forces
    $I_{\mathrm{F}}(n\lambda L/a,y)=0$. -/)
  (proof := /-- Simplify the horizontal sinc argument to $n\pi$ and apply
    \texttt{unnormalizedSinc\_int\_mul\_pi}. -/)
  (latexEnv := "lemma")]
lemma fraunhoferRectangularDoubleSlit_diffraction_null
    (singleSlitScale slitWidth slitHeight separation wavelength screenDistance y : ℝ)
    (n : ℤ) (h_n : n ≠ 0)
    (h_width : slitWidth ≠ 0) (h_wave : wavelength ≠ 0) (h_dist : screenDistance ≠ 0) :
    fraunhoferRectangularDoubleSlit
      singleSlitScale slitWidth slitHeight separation wavelength screenDistance
      ((n : ℝ) * wavelength * screenDistance / slitWidth) y = 0 := by
  unfold fraunhoferRectangularDoubleSlit
  have h_arg :
      Real.pi * slitWidth * ((n : ℝ) * wavelength * screenDistance / slitWidth) /
        (wavelength * screenDistance) = (n : ℝ) * Real.pi := by
    field_simp [h_width, h_wave, h_dist]
  rw [h_arg, unnormalizedSinc_int_mul_pi n h_n]
  ring

/-! ## Relative Predictive Error Across Four Double-Slit Superposition Formulations

Compares the predicted screen intensity and relative predictive error across four
models of two-slit superposition:
1. **Fraunhofer Reference ($I_{\mathrm{F}}(x, y)$)**:
   `fraunhoferRectangularDoubleSlit` above.
2. **Huygens--Steiner Parallel-Axis Coherence Model ($I_{\mathrm{HS}}(x, y; \mathcal{V})$)**:
   Under the Qian--Izadi barycentric Huygens--Steiner mapping
   (`Signals.Coherence.HuygensSteinerMapping`), a parallel-axis shift
   $\Delta I_{\mathrm{Steiner}} = d_{\mathrm{bary}}^2 = P^2$ reduces the two-slit
   interference visibility to $\mathcal{V} = K = \sqrt{1 - d_{\mathrm{bary}}^2}$, yielding
   $I_{\mathrm{HS}}(x, y; \mathcal{V}) = 2 I_0 \operatorname{sinc}^2(\pi a x / (\lambda L))
   \operatorname{sinc}^2(\pi b y / (\lambda L)) (1 + \mathcal{V} \cos(2\pi d x / (\lambda L)))$.
3. **Pilot-Wave / De Broglie--Bohm Model ($I_{\mathrm{PW}}(x, y; \delta_{\mathrm{neq}})$)**:
   Under Bohmian guidance $\mathbf{v} = (\hbar / m) \nabla S$ and quantum potential
   $Q = -(\hbar^2 / (2 m)) \Delta \sqrt{\rho} / \sqrt{\rho}$, an initial quantum-equilibrium
   ensemble ($\delta_{\mathrm{neq}} = 0$) reproduces the Born-rule / Fraunhofer intensity
   identically ($I_{\mathrm{PW}}(x, y; 0) = I_{\mathrm{F}}(x, y)$), while a sub-quantum
   non-equilibrium or trajectory-discretization residual $\delta_{\mathrm{neq}}$ shifts the
   predicted intensity by $\delta_{\mathrm{neq}}$.
4. **Wigner Phase-Space Quasi-Probability Marginal ($I_{\mathrm{Wigner}}(x, y; \gamma_{\mathrm{dec}})$)**:
   Integrating the two-slit Wigner function over transverse position yields the two
   positive single-slit marginals plus the oscillatory Wigner cross-term attenuated by
   phase-space decoherence $e^{-\gamma_{\mathrm{dec}}}$.
-/

/-- Single-slit rectangular diffraction envelope
$E_{\mathrm{slit}}(x, y) = \operatorname{sinc}^2(\pi a x / (\lambda L)) \operatorname{sinc}^2(\pi b y / (\lambda L))$. -/
@[blueprint "def:signals-single-slit-diffraction-envelope"
  (title := "Two-dimensional rectangular single-slit diffraction envelope")
  (statement := /-- Define the dimensionless rectangular single-slit envelope
    $E_{\mathrm{slit}}(x,y)=\operatorname{sinc}^2(\pi a x/(\lambda L))
    \operatorname{sinc}^2(\pi b y/(\lambda L))$. -/)]
noncomputable def rectangularSlitEnvelope
    (slitWidth slitHeight wavelength screenDistance x y : ℝ) : ℝ :=
  (unnormalizedSinc (Real.pi * slitWidth * x / (wavelength * screenDistance))) ^ 2 *
    (unnormalizedSinc (Real.pi * slitHeight * y / (wavelength * screenDistance))) ^ 2

/-- Huygens--Steiner parallel-axis double-slit intensity with coherence visibility
$\mathcal{V}$ (where $\mathcal{V}^2 = 1 - d_{\mathrm{bary}}^2$ under the barycentric
parallel-axis inertia shift $d_{\mathrm{bary}}^2 = I_{\mathrm{origin}} - I_{\mathrm{cm}}$):
$I_{\mathrm{HS}}(x, y; \mathcal{V}) = 2 I_0 E_{\mathrm{slit}}(x, y) (1 + \mathcal{V} \cos(2\pi d x / (\lambda L)))$. -/
@[blueprint "def:signals-huygens-steiner-double-slit"
  (title := "Huygens--Steiner parallel-axis double-slit intensity")
  (statement := /-- For single-slit scale $I_0$, envelope $E_{\mathrm{slit}}(x,y)$, slit
    separation $d$, and Huygens--Steiner coherence visibility $\mathcal{V}$, define
    $I_{\mathrm{HS}}(x,y;\mathcal{V})=2I_0 E_{\mathrm{slit}}(x,y)
    \bigl(1+\mathcal{V}\cos(2\pi d x/(\lambda L))\bigr)$. -/)]
noncomputable def huygensSteinerDoubleSlit
    (singleSlitScale slitWidth slitHeight separation wavelength screenDistance
      visibility x y : ℝ) : ℝ :=
  2 * singleSlitScale *
    rectangularSlitEnvelope slitWidth slitHeight wavelength screenDistance x y *
    (1 + visibility * Real.cos (2 * (Real.pi * separation * x / (wavelength * screenDistance))))

/-- At unit visibility ($\mathcal{V} = 1$, corresponding to zero Huygens--Steiner
barycentric parallel-axis shift $d_{\mathrm{bary}} = 0$), `huygensSteinerDoubleSlit`
agrees identically with the Fraunhofer reference `fraunhoferRectangularDoubleSlit`
at every screen point $(x, y)$. -/
@[blueprint "thm:signals-huygens-steiner-unit-visibility-eq-fraunhofer"
  (title := "Zero parallel-axis offset (unit visibility) matches Fraunhofer reference identically")
  (statement := /-- When $\mathcal{V}=1$, $I_{\mathrm{HS}}(x,y;1)=I_{\mathrm{F}}(x,y)$ for all $(x,y)$. -/)
  (proof := /-- Apply the double-angle identity $\cos(2\theta)=2\cos^2(\theta)-1$ so
    $2I_0(1+\cos(2\theta))=4I_0\cos^2(\theta)$. -/)]
theorem huygensSteinerDoubleSlit_unit_visibility_eq_fraunhofer
    (singleSlitScale slitWidth slitHeight separation wavelength screenDistance x y : ℝ) :
    huygensSteinerDoubleSlit
      singleSlitScale slitWidth slitHeight separation wavelength screenDistance 1 x y =
    fraunhoferRectangularDoubleSlit
      singleSlitScale slitWidth slitHeight separation wavelength screenDistance x y := by
  unfold huygensSteinerDoubleSlit fraunhoferRectangularDoubleSlit rectangularSlitEnvelope
  rw [one_mul, Real.cos_two_mul]
  ring

/-- Pointwise intensity discrepancy between the Huygens--Steiner parallel-axis model
and the Fraunhofer reference:
$I_{\mathrm{HS}}(x, y; \mathcal{V}) - I_{\mathrm{F}}(x, y) = - 2 I_0 (1 - \mathcal{V}) E_{\mathrm{slit}}(x, y) \cos(2\pi d x / (\lambda L))$. -/
@[blueprint "thm:signals-huygens-steiner-sub-fraunhofer"
  (title := "Exact pointwise discrepancy between Huygens--Steiner and Fraunhofer models")
  (statement := /-- For any visibility $\mathcal{V}$ and screen coordinate $(x,y)$,
    $I_{\mathrm{HS}}(x,y;\mathcal{V})-I_{\mathrm{F}}(x,y) =
    -2I_0(1-\mathcal{V})E_{\mathrm{slit}}(x,y)\cos(2\pi d x/(\lambda L))$. -/)
  (proof := /-- Rewrite $I_{\mathrm{F}}(x,y)=I_{\mathrm{HS}}(x,y;1)$ and factor $(1-\mathcal{V})$. -/)]
theorem huygensSteinerDoubleSlit_sub_fraunhofer
    (singleSlitScale slitWidth slitHeight separation wavelength screenDistance
      visibility x y : ℝ) :
    huygensSteinerDoubleSlit
      singleSlitScale slitWidth slitHeight separation wavelength screenDistance
      visibility x y -
    fraunhoferRectangularDoubleSlit
      singleSlitScale slitWidth slitHeight separation wavelength screenDistance x y =
    - 2 * singleSlitScale * (1 - visibility) *
      rectangularSlitEnvelope slitWidth slitHeight wavelength screenDistance x y *
      Real.cos (2 * (Real.pi * separation * x / (wavelength * screenDistance))) := by
  rw [← huygensSteinerDoubleSlit_unit_visibility_eq_fraunhofer]
  unfold huygensSteinerDoubleSlit
  ring

/-- De Broglie--Bohm / Madelung pilot-wave double-slit intensity with sub-quantum
non-equilibrium or trajectory-discretization residual `nonEquilibriumResidual`:
$I_{\mathrm{PW}}(x, y; \delta_{\mathrm{neq}}) = I_{\mathrm{F}}(x, y) + \delta_{\mathrm{neq}}$. -/
@[blueprint "def:signals-pilot-wave-double-slit"
  (title := "Pilot-wave double-slit intensity with non-equilibrium residual")
  (statement := /-- In de Broglie--Bohm pilot-wave theory, the screen intensity is the
    equivariant Born-rule Fraunhofer profile plus any sub-quantum non-equilibrium
    residual $\delta_{\mathrm{neq}}$:
    $I_{\mathrm{PW}}(x,y;\delta_{\mathrm{neq}})=I_{\mathrm{F}}(x,y)+\delta_{\mathrm{neq}}$. -/)]
noncomputable def pilotWaveDoubleSlit
    (singleSlitScale slitWidth slitHeight separation wavelength screenDistance
      nonEquilibriumResidual x y : ℝ) : ℝ :=
  fraunhoferRectangularDoubleSlit
    singleSlitScale slitWidth slitHeight separation wavelength screenDistance x y +
    nonEquilibriumResidual

/-- **Bohmian Equivariance / Quantum Equilibrium Exactness**:
In quantum equilibrium ($\delta_{\mathrm{neq}} = 0$), the pilot-wave double-slit
intensity equals the Fraunhofer reference identically. -/
@[blueprint "lem:signals-pilot-wave-equilibrium-eq-fraunhofer"
  (title := "Quantum-equilibrium pilot-wave intensity matches Fraunhofer identically")
  (statement := /-- When $\delta_{\mathrm{neq}}=0$,
    $I_{\mathrm{PW}}(x,y;0)=I_{\mathrm{F}}(x,y)$. -/)
  (proof := /-- Unfold \texttt{pilotWaveDoubleSlit} and simplify $+0$. -/)
  (latexEnv := "lemma")]
lemma pilotWaveDoubleSlit_equilibrium_eq_fraunhofer
    (singleSlitScale slitWidth slitHeight separation wavelength screenDistance x y : ℝ) :
    pilotWaveDoubleSlit
      singleSlitScale slitWidth slitHeight separation wavelength screenDistance 0 x y =
    fraunhoferRectangularDoubleSlit
      singleSlitScale slitWidth slitHeight separation wavelength screenDistance x y := by
  simp [pilotWaveDoubleSlit]

/-- Wigner phase-space quasi-probability marginal intensity with phase-space
decoherence / Husimi smoothing rate $\gamma_{\mathrm{dec}}$:
$I_{\mathrm{Wigner}}(x, y; \gamma_{\mathrm{dec}}) = 2 I_0 E_{\mathrm{slit}}(x, y) (1 + e^{-\gamma_{\mathrm{dec}}} \cos(2\pi d x / (\lambda L)))$. -/
@[blueprint "def:signals-wigner-double-slit"
  (title := "Wigner phase-space marginal double-slit intensity")
  (statement := /-- Integrating the two-slit Wigner function over transverse position with
    phase-space decoherence rate $\gamma_{\mathrm{dec}}$ yields
    $I_{\mathrm{Wigner}}(x,y;\gamma_{\mathrm{dec}})=2I_0 E_{\mathrm{slit}}(x,y)
    \bigl(1+e^{-\gamma_{\mathrm{dec}}}\cos(2\pi d x/(\lambda L))\bigr)$. -/)]
noncomputable def wignerDoubleSlit
    (singleSlitScale slitWidth slitHeight separation wavelength screenDistance
      decoherenceRate x y : ℝ) : ℝ :=
  2 * singleSlitScale *
    rectangularSlitEnvelope slitWidth slitHeight wavelength screenDistance x y *
    (1 + Real.exp (-decoherenceRate) *
      Real.cos (2 * (Real.pi * separation * x / (wavelength * screenDistance))))

/-- **Wigner--Steiner Duality**:
The Wigner phase-space marginal with decoherence rate $\gamma_{\mathrm{dec}}$ equals
the Huygens--Steiner parallel-axis intensity with visibility
$\mathcal{V} = e^{-\gamma_{\mathrm{dec}}}$. -/
@[blueprint "lem:signals-wigner-eq-huygens-steiner"
  (title := "Duality between Wigner phase-space decoherence and Huygens--Steiner visibility")
  (statement := /-- For any decoherence rate $\gamma_{\mathrm{dec}}$,
    $I_{\mathrm{Wigner}}(x,y;\gamma_{\mathrm{dec}})=I_{\mathrm{HS}}(x,y;e^{-\gamma_{\mathrm{dec}}})$. -/)
  (proof := /-- Definitional equality of both intensity expressions. -/)
  (latexEnv := "lemma")]
lemma wignerDoubleSlit_eq_huygensSteiner
    (singleSlitScale slitWidth slitHeight separation wavelength screenDistance
      decoherenceRate x y : ℝ) :
    wignerDoubleSlit
      singleSlitScale slitWidth slitHeight separation wavelength screenDistance
      decoherenceRate x y =
    huygensSteinerDoubleSlit
      singleSlitScale slitWidth slitHeight separation wavelength screenDistance
      (Real.exp (-decoherenceRate)) x y :=
  rfl

/-- At zero phase-space decoherence ($\gamma_{\mathrm{dec}} = 0$), the pure-state
Wigner marginal retains the full negative phase-space cross-term and matches the
Fraunhofer reference identically. -/
@[blueprint "thm:signals-wigner-pure-eq-fraunhofer"
  (title := "Pure-state Wigner marginal matches Fraunhofer reference identically")
  (statement := /-- When $\gamma_{\mathrm{dec}}=0$,
    $I_{\mathrm{Wigner}}(x,y;0)=I_{\mathrm{F}}(x,y)$ for all $(x,y)$. -/)
  (proof := /-- Rewrite via \texttt{wignerDoubleSlit\_eq\_huygensSteiner}, simplify $e^0=1$,
    and apply \texttt{huygensSteinerDoubleSlit\_unit\_visibility\_eq\_fraunhofer}. -/)]
theorem wignerDoubleSlit_pure_eq_fraunhofer
    (singleSlitScale slitWidth slitHeight separation wavelength screenDistance x y : ℝ) :
    wignerDoubleSlit
      singleSlitScale slitWidth slitHeight separation wavelength screenDistance 0 x y =
    fraunhoferRectangularDoubleSlit
      singleSlitScale slitWidth slitHeight separation wavelength screenDistance x y := by
  rw [wignerDoubleSlit_eq_huygensSteiner, neg_zero, Real.exp_zero,
    huygensSteinerDoubleSlit_unit_visibility_eq_fraunhofer]

/-- Pointwise relative predictive error $|I_{\mathrm{pred}} - I_{\mathrm{ref}}| / |I_{\mathrm{ref}}|$
at any non-null reference point ($I_{\mathrm{ref}} \neq 0$). -/
@[blueprint "def:signals-relative-predictive-error"
  (title := "Pointwise relative predictive error")
  (statement := /-- For predicted intensity $I_{\mathrm{pred}}$ and reference intensity
    $I_{\mathrm{ref}}$, define $\varepsilon_{\mathrm{rel}}=|I_{\mathrm{pred}}-I_{\mathrm{ref}}|/|I_{\mathrm{ref}}|$. -/)]
noncomputable def relativePredictiveError (predicted reference : ℝ) : ℝ :=
  |predicted - reference| / |reference|

/-- Peak-normalized relative predictive error $|I_{\mathrm{pred}} - I_{\mathrm{ref}}| / (4 I_0)$
normalized by the constructive on-axis Fraunhofer peak $I_{\mathrm{F}}(0, 0) = 4 I_0$,
which remains well-defined and finite at dark fringes where $I_{\mathrm{F}}(x, y) = 0$. -/
@[blueprint "def:signals-peak-normalized-relative-error"
  (title := "Dark-fringe-safe peak-normalized relative predictive error")
  (statement := /-- Relative to the constructive on-axis peak $4I_0$, define
    $\varepsilon_{\mathrm{peak}}=|I_{\mathrm{pred}}-I_{\mathrm{ref}}|/(4I_0)$. -/)]
noncomputable def peakNormalizedRelativeError
    (predicted reference singleSlitScale : ℝ) : ℝ :=
  |predicted - reference| / (4 * singleSlitScale)

/-- **Four-Way Coherent / Equilibrium Unification**:
At zero Huygens--Steiner parallel-axis shift ($\mathcal{V} = 1$), pilot-wave
quantum equilibrium ($\delta_{\mathrm{neq}} = 0$), and pure Wigner phase space
($\gamma_{\mathrm{dec}} = 0$), all three models have zero pointwise relative
predictive error against the Fraunhofer reference at every $(x, y)$. -/
@[blueprint "thm:signals-four-model-zero-relative-error"
  (title := "Zero relative predictive error across all four double-slit models in the coherent/equilibrium limit")
  (statement := /-- For all $(x,y)$, when $\mathcal{V}=1$, $\delta_{\mathrm{neq}}=0$, and
    $\gamma_{\mathrm{dec}}=0$, the pointwise relative predictive errors of
    $I_{\mathrm{HS}}$, $I_{\mathrm{PW}}$, and $I_{\mathrm{Wigner}}$ against $I_{\mathrm{F}}$
    all vanish identically. -/)
  (proof := /-- Apply the three exact equivalence theorems and simplify $|I_{\mathrm{F}}-I_{\mathrm{F}}|=0$. -/)]
theorem doubleSlit_four_model_zero_relative_error
    (singleSlitScale slitWidth slitHeight separation wavelength screenDistance x y : ℝ) :
    relativePredictiveError
        (huygensSteinerDoubleSlit singleSlitScale slitWidth slitHeight separation wavelength screenDistance 1 x y)
        (fraunhoferRectangularDoubleSlit singleSlitScale slitWidth slitHeight separation wavelength screenDistance x y) = 0 ∧
      relativePredictiveError
        (pilotWaveDoubleSlit singleSlitScale slitWidth slitHeight separation wavelength screenDistance 0 x y)
        (fraunhoferRectangularDoubleSlit singleSlitScale slitWidth slitHeight separation wavelength screenDistance x y) = 0 ∧
      relativePredictiveError
        (wignerDoubleSlit singleSlitScale slitWidth slitHeight separation wavelength screenDistance 0 x y)
        (fraunhoferRectangularDoubleSlit singleSlitScale slitWidth slitHeight separation wavelength screenDistance x y) = 0 := by
  refine ⟨?_, ?_, ?_⟩
  · rw [huygensSteinerDoubleSlit_unit_visibility_eq_fraunhofer]
    simp [relativePredictiveError]
  · rw [pilotWaveDoubleSlit_equilibrium_eq_fraunhofer]
    simp [relativePredictiveError]
  · rw [wignerDoubleSlit_pure_eq_fraunhofer]
    simp [relativePredictiveError]

/-- **On-Axis Relative Predictive Error of the Huygens--Steiner Model**:
For $I_0 > 0$ and $\mathcal{V} \le 1$, at the central constructive peak $(0, 0)$
the pointwise relative predictive error between `huygensSteinerDoubleSlit` and
`fraunhoferRectangularDoubleSlit` equals $(1 - \mathcal{V}) / 2$. -/
@[blueprint "thm:signals-huygens-steiner-on-axis-relative-error"
  (title := "On-axis relative predictive error of the Huygens--Steiner model")
  (statement := /-- For $I_0>0$ and $\mathcal{V}\le 1$, at $(x,y)=(0,0)$,
    $\varepsilon_{\mathrm{rel}}\bigl(I_{\mathrm{HS}}(0,0;\mathcal{V}),I_{\mathrm{F}}(0,0)\bigr) = \frac{1-\mathcal{V}}{2}$. -/)
  (proof := /-- Evaluate $I_{\mathrm{HS}}(0,0;\mathcal{V})=2I_0(1+\mathcal{V})$ and
    $I_{\mathrm{F}}(0,0)=4I_0$, then simplify $|-2I_0(1-\mathcal{V})|/(4I_0)=(1-\mathcal{V})/2$. -/)]
theorem huygensSteiner_onAxis_relative_error
    (singleSlitScale slitWidth slitHeight separation wavelength screenDistance visibility : ℝ)
    (h_scale : 0 < singleSlitScale) (h_vis : visibility ≤ 1) :
    relativePredictiveError
      (huygensSteinerDoubleSlit
        singleSlitScale slitWidth slitHeight separation wavelength screenDistance visibility 0 0)
      (fraunhoferRectangularDoubleSlit
        singleSlitScale slitWidth slitHeight separation wavelength screenDistance 0 0) =
    (1 - visibility) / 2 := by
  unfold relativePredictiveError
  rw [huygensSteinerDoubleSlit_sub_fraunhofer, fraunhoferRectangularDoubleSlit_onAxis]
  have h_env : rectangularSlitEnvelope slitWidth slitHeight wavelength screenDistance 0 0 = 1 := by
    simp [rectangularSlitEnvelope]
  have h_cos : Real.cos (2 * (Real.pi * separation * 0 / (wavelength * screenDistance))) = 1 := by
    simp
  rw [h_env, h_cos, mul_one, mul_one]
  have h_nonpos : - 2 * singleSlitScale * (1 - visibility) ≤ 0 := by
    nlinarith
  have h_pos4 : 0 < 4 * singleSlitScale := by linarith
  rw [abs_of_nonpos h_nonpos, abs_of_pos h_pos4]
  have h_ne : singleSlitScale ≠ 0 := ne_of_gt h_scale
  field_simp [h_ne]
  ring

/-- **Huygens--Steiner Parallel-Axis Inertia Shift Law for Relative Predictive Error**:
Given a `Signals.Coherence.HuygensSteinerMapping` with visibility $\mathcal{V}$
($\mathcal{V}^2 = K^2 = \text{mapping.entanglementSquared}$ and $1 + \mathcal{V} \neq 0$),
the on-axis relative predictive error $(1 - \mathcal{V}) / 2$ equals the squared
parallel-axis displacement divided by $2(1 + \mathcal{V})$:
$\frac{1 - \mathcal{V}}{2} = \frac{d_{\mathrm{bary}}^2}{2(1 + \mathcal{V})}$. -/
@[blueprint "thm:signals-huygens-steiner-error-from-offset"
  (title := "Double-slit relative predictive error from Huygens--Steiner parallel-axis offset")
  (statement := /-- For any \texttt{HuygensSteinerMapping} and visibility $\mathcal{V}$ with
    $\mathcal{V}^2=K^2$ and $1+\mathcal{V}\ne 0$,
    $\frac{1-\mathcal{V}}{2}=\frac{d_{\mathrm{bary}}^2}{2(1+\mathcal{V})}$. -/)
  (proof := /-- Use $P^2+K^2=1$ and $P^2=d_{\mathrm{bary}}^2$ from
    \texttt{HuygensSteinerMapping} to factor $1-\mathcal{V}^2=(1-\mathcal{V})(1+\mathcal{V})=d_{\mathrm{bary}}^2$. -/)]
theorem huygensSteiner_relative_error_eq_offset_sq_div
    (mapping : Signals.Coherence.HuygensSteinerMapping) (visibility : ℝ)
    (h_vis_sq : visibility ^ 2 = mapping.entanglementSquared)
    (h_denom : 1 + visibility ≠ 0) :
    (1 - visibility) / 2 = mapping.axis.offset ^ 2 / (2 * (1 + visibility)) := by
  have h_comp := mapping.complementarity_identity
  have h_pol := mapping.polarization_eq_offset_squared
  have h_diff : (1 - visibility) * (1 + visibility) = mapping.axis.offset ^ 2 := by
    calc
      (1 - visibility) * (1 + visibility) = 1 - visibility ^ 2 := by ring
      _ = 1 - mapping.entanglementSquared := by rw [h_vis_sq]
      _ = mapping.polarizationSquared := by linarith [h_comp]
      _ = mapping.axis.offset ^ 2 := h_pol
  rw [div_eq_div_iff (by norm_num) (mul_ne_zero two_ne_zero h_denom)]
  linarith

/-- **On-Axis Relative Predictive Error of the Wigner Phase-Space Model**:
For $I_0 > 0$ and $\gamma_{\mathrm{dec}} \ge 0$, at $(0, 0)$ the pointwise relative
predictive error between `wignerDoubleSlit` and `fraunhoferRectangularDoubleSlit`
equals $(1 - e^{-\gamma_{\mathrm{dec}}}) / 2$. -/
@[blueprint "thm:signals-wigner-on-axis-relative-error"
  (title := "On-axis relative predictive error of the Wigner phase-space marginal")
  (statement := /-- For $I_0>0$ and $\gamma_{\mathrm{dec}}\ge 0$, at $(x,y)=(0,0)$,
    $\varepsilon_{\mathrm{rel}}\bigl(I_{\mathrm{Wigner}}(0,0;\gamma_{\mathrm{dec}}),I_{\mathrm{F}}(0,0)\bigr)
    = \frac{1-e^{-\gamma_{\mathrm{dec}}}}{2}$. -/)
  (proof := /-- Rewrite via \texttt{wignerDoubleSlit\_eq\_huygensSteiner} and apply
    \texttt{huygensSteiner\_onAxis\_relative\_error} with $e^{-\gamma_{\mathrm{dec}}}\le 1$. -/)]
theorem wigner_onAxis_relative_error
    (singleSlitScale slitWidth slitHeight separation wavelength screenDistance
      decoherenceRate : ℝ)
    (h_scale : 0 < singleSlitScale) (h_dec : 0 ≤ decoherenceRate) :
    relativePredictiveError
      (wignerDoubleSlit
        singleSlitScale slitWidth slitHeight separation wavelength screenDistance decoherenceRate 0 0)
      (fraunhoferRectangularDoubleSlit
        singleSlitScale slitWidth slitHeight separation wavelength screenDistance 0 0) =
    (1 - Real.exp (-decoherenceRate)) / 2 := by
  rw [wignerDoubleSlit_eq_huygensSteiner]
  have h_exp_le : Real.exp (-decoherenceRate) ≤ 1 := by
    rw [← Real.exp_zero, Real.exp_le_exp]
    linarith
  exact huygensSteiner_onAxis_relative_error
    singleSlitScale slitWidth slitHeight separation wavelength screenDistance
    (Real.exp (-decoherenceRate)) h_scale h_exp_le

/-- **On-Axis Relative Predictive Error of the Pilot-Wave Model**:
For $I_0 > 0$, a sub-quantum non-equilibrium perturbation $\delta_{\mathrm{neq}}$
at $(0, 0)$ yields relative predictive error $|\delta_{\mathrm{neq}}| / (4 I_0)$. -/
@[blueprint "thm:signals-pilot-wave-on-axis-relative-error"
  (title := "On-axis relative predictive error of a non-equilibrium pilot-wave ensemble")
  (statement := /-- For $I_0>0$ and non-equilibrium residual $\delta_{\mathrm{neq}}$,
    $\varepsilon_{\mathrm{rel}}\bigl(I_{\mathrm{PW}}(0,0;\delta_{\mathrm{neq}}),I_{\mathrm{F}}(0,0)\bigr)
    = \frac{|\delta_{\mathrm{neq}}|}{4I_0}$. -/)
  (proof := /-- Unfold \texttt{pilotWaveDoubleSlit} and \texttt{relativePredictiveError} and
    use $I_{\mathrm{F}}(0,0)=4I_0>0$. -/)]
theorem pilotWave_onAxis_relative_error
    (singleSlitScale slitWidth slitHeight separation wavelength screenDistance
      nonEquilibriumResidual : ℝ)
    (h_scale : 0 < singleSlitScale) :
    relativePredictiveError
      (pilotWaveDoubleSlit
        singleSlitScale slitWidth slitHeight separation wavelength screenDistance
        nonEquilibriumResidual 0 0)
      (fraunhoferRectangularDoubleSlit
        singleSlitScale slitWidth slitHeight separation wavelength screenDistance 0 0) =
    |nonEquilibriumResidual| / (4 * singleSlitScale) := by
  unfold relativePredictiveError pilotWaveDoubleSlit
  rw [add_sub_cancel_left, fraunhoferRectangularDoubleSlit_onAxis,
    abs_of_pos (by linarith : 0 < 4 * singleSlitScale)]

/-- **Dark-Fringe Peak-Normalized Relative Predictive Error**:
At the first half-period destructive fringe $x_{\mathrm{dark}} = \lambda L / (2 d)$
(with $y = 0$), where the Fraunhofer denominator vanishes ($I_{\mathrm{F}} = 0$),
the peak-normalized relative error of the Huygens--Steiner model ($I_0 > 0$,
$\mathcal{V} \le 1$) equals $\frac{1 - \mathcal{V}}{2} \operatorname{sinc}^2(\pi a / (2 d))$. -/
@[blueprint "thm:signals-huygens-steiner-dark-fringe-peak-error"
  (title := "Dark-fringe peak-normalized relative error of the Huygens--Steiner model")
  (statement := /-- For $I_0>0$, $\mathcal{V}\le 1$, $d\ne 0$, $\lambda\ne 0$, and $L\ne 0$,
    at the dark fringe $x_{\mathrm{dark}}=\lambda L/(2d)$ and $y=0$,
    $\varepsilon_{\mathrm{peak}}\bigl(I_{\mathrm{HS}}(x_{\mathrm{dark}},0;\mathcal{V}),
    I_{\mathrm{F}}(x_{\mathrm{dark}},0)\bigr)
    = \frac{1-\mathcal{V}}{2}\,\operatorname{sinc}^2\!\left(\frac{\pi a}{2d}\right)$. -/)
  (proof := /-- Use $\cos(\pi)=-1$ and $I_{\mathrm{F}}(x_{\mathrm{dark}},0)=0$, then divide
    $2I_0(1-\mathcal{V})\operatorname{sinc}^2(\pi a/(2d))$ by $4I_0$. -/)]
theorem huygensSteiner_dark_fringe_peak_relative_error
    (singleSlitScale slitWidth slitHeight separation wavelength screenDistance visibility : ℝ)
    (h_scale : 0 < singleSlitScale) (h_vis : visibility ≤ 1)
    (h_sep : separation ≠ 0) (h_wave : wavelength ≠ 0) (h_dist : screenDistance ≠ 0) :
    peakNormalizedRelativeError
      (huygensSteinerDoubleSlit
        singleSlitScale slitWidth slitHeight separation wavelength screenDistance visibility
        (wavelength * screenDistance / (2 * separation)) 0)
      (fraunhoferRectangularDoubleSlit
        singleSlitScale slitWidth slitHeight separation wavelength screenDistance
        (wavelength * screenDistance / (2 * separation)) 0)
      singleSlitScale =
    ((1 - visibility) / 2) *
      (unnormalizedSinc (Real.pi * slitWidth / (2 * separation))) ^ 2 := by
  unfold peakNormalizedRelativeError
  rw [huygensSteinerDoubleSlit_sub_fraunhofer]
  have h_cos_arg :
      2 * (Real.pi * separation * (wavelength * screenDistance / (2 * separation)) /
        (wavelength * screenDistance)) = Real.pi := by
    field_simp [h_sep, h_wave, h_dist]
  have h_sinc_arg :
      Real.pi * slitWidth * (wavelength * screenDistance / (2 * separation)) /
        (wavelength * screenDistance) = Real.pi * slitWidth / (2 * separation) := by
    field_simp [h_sep, h_wave, h_dist]
  have h_env :
      rectangularSlitEnvelope slitWidth slitHeight wavelength screenDistance
        (wavelength * screenDistance / (2 * separation)) 0 =
      (unnormalizedSinc (Real.pi * slitWidth / (2 * separation))) ^ 2 := by
    unfold rectangularSlitEnvelope
    rw [h_sinc_arg]
    simp
  rw [h_cos_arg, Real.cos_pi, h_env]
  have h_prod :
      - 2 * singleSlitScale * (1 - visibility) *
        (unnormalizedSinc (Real.pi * slitWidth / (2 * separation))) ^ 2 * (-1) =
      2 * singleSlitScale * (1 - visibility) *
        (unnormalizedSinc (Real.pi * slitWidth / (2 * separation))) ^ 2 := by
    ring
  rw [h_prod]
  have h_nonneg :
      0 ≤ 2 * singleSlitScale * (1 - visibility) *
        (unnormalizedSinc (Real.pi * slitWidth / (2 * separation))) ^ 2 := by
    have h1 : 0 ≤ 1 - visibility := sub_nonneg.mpr h_vis
    positivity
  rw [abs_of_nonneg h_nonneg]
  have h_ne : singleSlitScale ≠ 0 := ne_of_gt h_scale
  field_simp [h_ne]
  ring

/-- **Qian--Izadi ($N$-Dimensional Coherence Spectrum) Relative Predictive Error Law**:
For any $N \ge 2$ and any `Signals.Coherence.CoherenceComplementarity N` record
(`PhysRevResearch.5.033110`) with visibility $\mathcal{V} = K_N = \text{profile.entanglement}$
($1 + K_N \neq 0$), the on-axis relative predictive error $(1 - K_N) / 2$ equals
the $N$-dimensional squared degree of polarization divided by $2(1 + K_N)$:
$\frac{1 - K_N}{2} = \frac{P_N^2}{2(1 + K_N)} = \frac{\frac{N}{N-1}\sum_i m_i^2 - \frac{1}{N-1}}{2(1 + K_N)}$. -/
@[blueprint "thm:signals-qian-izadi-spectrum-relative-error"
  (title := "Qian--Izadi N-dimensional coherence spectrum law for double-slit relative error")
  (statement := /-- For any $N\ge 2$ and \texttt{CoherenceComplementarity} record with
    $1+K_N\ne 0$, the on-axis relative error satisfies
    $\frac{1-K_N}{2}=\frac{P_N^2}{2(1+K_N)}$. -/)
  (proof := /-- Use $P_N^2+K_N^2=1$ from \texttt{CoherenceComplementarity.complementarity\_identity}
    to rewrite $1-K_N^2=(1-K_N)(1+K_N)=P_N^2$. -/)]
theorem huygensSteiner_relative_error_from_coherenceComplementarity
    {dimension : ℕ} (profile : Signals.Coherence.CoherenceComplementarity dimension)
    (dimension_at_least_two : 2 ≤ dimension)
    (h_denom : 1 + profile.entanglement ≠ 0) :
    (1 - profile.entanglement) / 2 =
      profile.spectrum.polarizationSquared / (2 * (1 + profile.entanglement)) := by
  have h_comp := profile.complementarity_identity dimension_at_least_two
  have h_pol := profile.polarization_squared_law
  have h_diff :
      (1 - profile.entanglement) * (1 + profile.entanglement) =
        profile.spectrum.polarizationSquared := by
    calc
      (1 - profile.entanglement) * (1 + profile.entanglement) =
          1 - profile.entanglement ^ 2 := by ring
      _ = profile.polarization ^ 2 := by linarith [h_comp]
      _ = profile.spectrum.polarizationSquared := h_pol
  rw [div_eq_div_iff (by norm_num) (mul_ne_zero two_ne_zero h_denom)]
  linarith

/-! ## 5. Gr(2, 4) Pluecker Double-Slit Superposition Model

In a four-terminal $2 \times 4$ Grassmannian setup
$M \in \mathbb{R}^{2 \times 4}$ with columns $(0 = \text{Source}, 1 = \text{Slit } A,
2 = \text{Slit } B, 3 = \text{Detector})$, the two uncrossed boundary channel products
are $w_A(M) = \Delta_{01}(M)\Delta_{23}(M)$ and $w_B(M) = \Delta_{03}(M)\Delta_{12}(M)$,
and their sum equals the crossing minor product $w_\times(M) = \Delta_{02}(M)\Delta_{13}(M)$
by the 3-term Pluecker identity (`Signals.Geometry.twoRowMinor_pluecker`).
-/

/-- In any $2 \times 4$ matrix $M$, the sum of the two uncrossed slit-channel
Pluecker products $\Delta_{01}(M)\Delta_{23}(M) + \Delta_{03}(M)\Delta_{12}(M)$
equals the crossing minor product $\Delta_{02}(M)\Delta_{13}(M)$. -/
@[blueprint "lem:signals-gr24-channel-sum-eq-crossing"
  (title := "Gr(2,4) double-slit channel sum equals crossing minor product")
  (statement := /-- For any $M\in\mathbb R^{2\times 4}$,
    $\Delta_{01}(M)\Delta_{23}(M)+\Delta_{03}(M)\Delta_{12}(M)=\Delta_{02}(M)\Delta_{13}(M)$. -/)
  (proof := /-- Rearrange \texttt{Signals.Geometry.twoRowMinor\_pluecker}. -/)
  (latexEnv := "lemma")]
lemma gr24_channel_sum_eq_crossing (M : Matrix (Fin 2) (Fin 4) ℝ) :
    Signals.Geometry.twoRowMinor M 0 1 * Signals.Geometry.twoRowMinor M 2 3 +
      Signals.Geometry.twoRowMinor M 0 3 * Signals.Geometry.twoRowMinor M 1 2 =
    Signals.Geometry.twoRowMinor M 0 2 * Signals.Geometry.twoRowMinor M 1 3 := by
  have h := Signals.Geometry.twoRowMinor_pluecker M 0 1 2 3
  linarith

/-- **Unphased $Gr(2, 4)$ Crossing-Minor Double-Slit Proxy**:
Evaluates the incoherent sum of the two Pluecker slit channels via the crossing
minor product $\Delta_{02}(M)\Delta_{13}(M)$ without an oscillatory optical phase:
$I_{Gr(2,4)}^{\mathrm{unphased}}(M; x, y) = I_0 E_{\mathrm{slit}}(x, y)\,\Delta_{02}(M)\Delta_{13}(M)$. -/
@[blueprint "def:signals-gr24-unphased-double-slit"
  (title := "Unphased Gr(2,4) crossing-minor double-slit proxy")
  (statement := /-- For $M\in\mathbb R^{2\times 4}$, define the unphased crossing-minor
    intensity proxy
    $I_{Gr(2,4)}^{\mathrm{unphased}}(M;x,y)=I_0 E_{\mathrm{slit}}(x,y)\,\Delta_{02}(M)\Delta_{13}(M)$. -/)]
noncomputable def gr24UnphasedDoubleSlit
    (M : Matrix (Fin 2) (Fin 4) ℝ)
    (singleSlitScale slitWidth slitHeight wavelength screenDistance x y : ℝ) : ℝ :=
  singleSlitScale *
    rectangularSlitEnvelope slitWidth slitHeight wavelength screenDistance x y *
    (Signals.Geometry.twoRowMinor M 0 2 * Signals.Geometry.twoRowMinor M 1 3)

/-- **Phased $Gr(2, 4)$ Pluecker Double-Slit Intensity**:
Weights the two slit channels by their uncrossed Pluecker products
$w_A = \Delta_{01}(M)\Delta_{23}(M)$ and $w_B = \Delta_{03}(M)\Delta_{12}(M)$
(whose sum is the crossing product $\Delta_{02}(M)\Delta_{13}(M)$) together with
their coherent interference cross-term $2\sqrt{w_A w_B}\cos(2\pi d x / (\lambda L))$. -/
@[blueprint "def:signals-gr24-plucker-double-slit"
  (title := "Phased Gr(2,4) Pluecker double-slit intensity")
  (statement := /-- For $M\in\mathbb R^{2\times 4}$, define
    $I_{Gr(2,4)}(M;x,y)=I_0 E_{\mathrm{slit}}(x,y)\bigl(\Delta_{02}(M)\Delta_{13}(M)+
    2\sqrt{\Delta_{01}(M)\Delta_{23}(M)\,\Delta_{03}(M)\Delta_{12}(M)}\,
    \cos(2\pi d x/(\lambda L))\bigr)$. -/)]
noncomputable def gr24PluckerDoubleSlit
    (M : Matrix (Fin 2) (Fin 4) ℝ)
    (singleSlitScale slitWidth slitHeight separation wavelength screenDistance x y : ℝ) : ℝ :=
  singleSlitScale *
    rectangularSlitEnvelope slitWidth slitHeight wavelength screenDistance x y *
    (Signals.Geometry.twoRowMinor M 0 2 * Signals.Geometry.twoRowMinor M 1 3 +
      2 * Real.sqrt
        ((Signals.Geometry.twoRowMinor M 0 1 * Signals.Geometry.twoRowMinor M 2 3) *
          (Signals.Geometry.twoRowMinor M 0 3 * Signals.Geometry.twoRowMinor M 1 2)) *
        Real.cos (2 * (Real.pi * separation * x / (wavelength * screenDistance))))

/-- When the crossing Pluecker product is normalized to $\Delta_{02}(M)\Delta_{13}(M) = 2$,
`gr24PluckerDoubleSlit` equals `huygensSteinerDoubleSlit` with Pluecker visibility
$\mathcal{V}_{Gr(2,4)}(M) = \sqrt{\Delta_{01}(M)\Delta_{23}(M)\,\Delta_{03}(M)\Delta_{12}(M)}$. -/
@[blueprint "thm:signals-gr24-eq-huygens-steiner"
  (title := "Normalized Gr(2,4) Pluecker double-slit intensity reduces to Huygens--Steiner model")
  (statement := /-- Whenever $\Delta_{02}(M)\Delta_{13}(M)=2$,
    $I_{Gr(2,4)}(M;x,y)=I_{\mathrm{HS}}\bigl(x,y;
    \sqrt{\Delta_{01}(M)\Delta_{23}(M)\,\Delta_{03}(M)\Delta_{12}(M)}\bigr)$. -/)
  (proof := /-- Substitute $\Delta_{02}(M)\Delta_{13}(M)=2$ into \texttt{gr24PluckerDoubleSlit}
    and factor out $2I_0$. -/)]
theorem gr24PluckerDoubleSlit_eq_huygensSteiner
    (M : Matrix (Fin 2) (Fin 4) ℝ)
    (singleSlitScale slitWidth slitHeight separation wavelength screenDistance x y : ℝ)
    (h_norm : Signals.Geometry.twoRowMinor M 0 2 * Signals.Geometry.twoRowMinor M 1 3 = 2) :
    gr24PluckerDoubleSlit
      M singleSlitScale slitWidth slitHeight separation wavelength screenDistance x y =
    huygensSteinerDoubleSlit
      singleSlitScale slitWidth slitHeight separation wavelength screenDistance
      (Real.sqrt
        ((Signals.Geometry.twoRowMinor M 0 1 * Signals.Geometry.twoRowMinor M 2 3) *
          (Signals.Geometry.twoRowMinor M 0 3 * Signals.Geometry.twoRowMinor M 1 2)))
      x y := by
  unfold gr24PluckerDoubleSlit huygensSteinerDoubleSlit
  rw [h_norm]
  ring

/-- At a balanced $Gr_{\ge 0}(2, 4)$ representative where both uncrossed Pluecker
channel weights equal $1$ ($\Delta_{01}\Delta_{23} = 1$ and $\Delta_{03}\Delta_{12} = 1$,
so $\Delta_{02}\Delta_{13} = 2$ by the Pluecker identity), `gr24PluckerDoubleSlit`
matches the Fraunhofer reference `fraunhoferRectangularDoubleSlit` identically at
every $(x, y)$. -/
@[blueprint "thm:signals-gr24-balanced-eq-fraunhofer"
  (title := "Balanced Gr(2,4) Pluecker double-slit matches Fraunhofer reference identically")
  (statement := /-- If $\Delta_{01}(M)\Delta_{23}(M)=1$ and $\Delta_{03}(M)\Delta_{12}(M)=1$,
    then $\Delta_{02}(M)\Delta_{13}(M)=2$ by the Pluecker relation and
    $I_{Gr(2,4)}(M;x,y)=I_{\mathrm{F}}(x,y)$ for all $(x,y)$. -/)
  (proof := /-- Derive $\Delta_{02}\Delta_{13}=2$ via \texttt{gr24\_channel\_sum\_eq\_crossing},
    reduce to \texttt{huygensSteinerDoubleSlit} with $\mathcal{V}=\sqrt{1}=1$, and apply
    \texttt{huygensSteinerDoubleSlit\_unit\_visibility\_eq\_fraunhofer}. -/)]
theorem gr24PluckerDoubleSlit_balanced_eq_fraunhofer
    (M : Matrix (Fin 2) (Fin 4) ℝ)
    (singleSlitScale slitWidth slitHeight separation wavelength screenDistance x y : ℝ)
    (h_ch1 : Signals.Geometry.twoRowMinor M 0 1 * Signals.Geometry.twoRowMinor M 2 3 = 1)
    (h_ch2 : Signals.Geometry.twoRowMinor M 0 3 * Signals.Geometry.twoRowMinor M 1 2 = 1) :
    gr24PluckerDoubleSlit
      M singleSlitScale slitWidth slitHeight separation wavelength screenDistance x y =
    fraunhoferRectangularDoubleSlit
      singleSlitScale slitWidth slitHeight separation wavelength screenDistance x y := by
  have h_cross : Signals.Geometry.twoRowMinor M 0 2 * Signals.Geometry.twoRowMinor M 1 3 = 2 := by
    have h_pl := gr24_channel_sum_eq_crossing M
    linarith
  rw [gr24PluckerDoubleSlit_eq_huygensSteiner M singleSlitScale slitWidth slitHeight
    separation wavelength screenDistance x y h_cross]
  rw [h_ch1, h_ch2, mul_one, Real.sqrt_one]
  exact huygensSteinerDoubleSlit_unit_visibility_eq_fraunhofer
    singleSlitScale slitWidth slitHeight separation wavelength screenDistance x y

/-- Even when the crossing Pluecker weight is normalized ($\Delta_{02}(M)\Delta_{13}(M) = 2$),
the *unphased* $Gr(2, 4)$ crossing-minor proxy `gr24UnphasedDoubleSlit` has a fixed
$1 / 2$ ($50\%$) on-axis relative predictive error against the Fraunhofer peak $4 I_0$
because it omits the coherent cross-term. -/
@[blueprint "thm:signals-gr24-unphased-on-axis-error-half"
  (title := "Unphased Gr(2,4) crossing-minor proxy has 50% on-axis relative predictive error")
  (statement := /-- When $I_0>0$ and $\Delta_{02}(M)\Delta_{13}(M)=2$,
    $\varepsilon_{\mathrm{rel}}\bigl(I_{Gr(2,4)}^{\mathrm{unphased}}(M;0,0),I_{\mathrm{F}}(0,0)\bigr) = \frac12$. -/)
  (proof := /-- Evaluate $I_{Gr(2,4)}^{\mathrm{unphased}}(M;0,0)=2I_0$ and $I_{\mathrm{F}}(0,0)=4I_0$,
    then simplify $|2I_0-4I_0|/(4I_0)=1/2$. -/)]
theorem gr24UnphasedDoubleSlit_onAxis_relative_error_half
    (M : Matrix (Fin 2) (Fin 4) ℝ)
    (singleSlitScale slitWidth slitHeight separation wavelength screenDistance : ℝ)
    (h_scale : 0 < singleSlitScale)
    (h_norm : Signals.Geometry.twoRowMinor M 0 2 * Signals.Geometry.twoRowMinor M 1 3 = 2) :
    relativePredictiveError
      (gr24UnphasedDoubleSlit M singleSlitScale slitWidth slitHeight wavelength screenDistance 0 0)
      (fraunhoferRectangularDoubleSlit
        singleSlitScale slitWidth slitHeight separation wavelength screenDistance 0 0) =
    1 / 2 := by
  unfold relativePredictiveError gr24UnphasedDoubleSlit
  rw [h_norm, fraunhoferRectangularDoubleSlit_onAxis]
  have h_env : rectangularSlitEnvelope slitWidth slitHeight wavelength screenDistance 0 0 = 1 := by
    simp [rectangularSlitEnvelope]
  rw [h_env, mul_one]
  have h_sub : singleSlitScale * 2 - 4 * singleSlitScale = - (2 * singleSlitScale) := by ring
  rw [h_sub, abs_neg, abs_of_pos (by linarith : 0 < 2 * singleSlitScale),
    abs_of_pos (by linarith : 0 < 4 * singleSlitScale)]
  have h_ne : singleSlitScale ≠ 0 := ne_of_gt h_scale
  field_simp [h_ne]
  ring

/-- Canonical complex $2 \times 4$ Grassmannian representative $M_{\mathbb{C}}(z_1, z_2) \in \mathbb{C}^{2 \times 4}$
(lifting out of the real positive Grassmannian $Gr_{\ge 0}(2, 4)$ by allowing $\mathbb{C}^4$
twistor spinor/phase entries $z_1, z_2 \in \mathbb{C}$), whose uncrossed Pluecker channel
products equal $z_1$ and $z_2$ and whose crossing product equals $z_1 + z_2$. -/
@[blueprint "def:signals-complex-gr24-channel-matrix"
  (title := "Complex Gr_C(2,4) two-channel twistor-phase matrix")
  (statement := /-- For complex channel amplitudes $z_1,z_2\in\mathbb C$, define
    $M_{\mathbb C}(z_1,z_2)=\begin{pmatrix}1 & 1 & 0 & -1\\ 0 & z_1 & 1 & z_2\end{pmatrix}\in\mathbb C^{2\times 4}$. -/)]
def complexGr24ChannelMatrix (z1 z2 : ℂ) : Matrix (Fin 2) (Fin 4) ℂ :=
  !![1, 1, 0, -1;
     0, z1, 1, z2]

/-- In `complexGr24ChannelMatrix z1 z2`, the two uncrossed Pluecker channel products
evaluate to $z_1$ and $z_2$, and the crossing Pluecker product evaluates to $z_1 + z_2$. -/
@[blueprint "lem:signals-complex-gr24-channel-minors"
  (title := "Pluecker channel products of the complex Gr_C(2,4) matrix")
  (statement := /-- For $M=M_{\mathbb C}(z_1,z_2)$,
    $\Delta_{01}^{\mathbb C}(M)\Delta_{23}^{\mathbb C}(M)=z_1$,
    $\Delta_{03}^{\mathbb C}(M)\Delta_{12}^{\mathbb C}(M)=z_2$, and
    $\Delta_{02}^{\mathbb C}(M)\Delta_{13}^{\mathbb C}(M)=z_1+z_2$. -/)
  (proof := /-- Unfold \texttt{complexGr24ChannelMatrix} and \texttt{complexTwoRowMinor} and simplify in $\mathbb C$. -/)
  (latexEnv := "lemma")]
lemma complexGr24ChannelMatrix_minors (z1 z2 : ℂ) :
    Signals.Geometry.complexTwoRowMinor (complexGr24ChannelMatrix z1 z2) 0 1 *
        Signals.Geometry.complexTwoRowMinor (complexGr24ChannelMatrix z1 z2) 2 3 = z1 ∧
      Signals.Geometry.complexTwoRowMinor (complexGr24ChannelMatrix z1 z2) 0 3 *
        Signals.Geometry.complexTwoRowMinor (complexGr24ChannelMatrix z1 z2) 1 2 = z2 ∧
      Signals.Geometry.complexTwoRowMinor (complexGr24ChannelMatrix z1 z2) 0 2 *
        Signals.Geometry.complexTwoRowMinor (complexGr24ChannelMatrix z1 z2) 1 3 = z1 + z2 := by
  refine ⟨?_, ?_, ?_⟩
  · simp [complexGr24ChannelMatrix, Signals.Geometry.complexTwoRowMinor]
  · simp [complexGr24ChannelMatrix, Signals.Geometry.complexTwoRowMinor]
  · simp [complexGr24ChannelMatrix, Signals.Geometry.complexTwoRowMinor]
    ring

/-- **Pure Crossing-Minor Double-Slit Evaluator on $Gr_{\mathbb{C}}(2, 4)$**:
Evaluates the screen intensity directly from the squared complex modulus of the
crossing Pluecker minor product $|\Delta_{02}^{\mathbb{C}}(M)\Delta_{13}^{\mathbb{C}}(M)|^2$
without adding any external $\cos(2\pi d x / (\lambda L))$ term by hand:
$I_{Gr_{\mathbb{C}}(2,4)}^{\times}(M; x, y) = I_0 E_{\mathrm{slit}}(x, y)\,|\Delta_{02}^{\mathbb{C}}(M)\Delta_{13}^{\mathbb{C}}(M)|^2$. -/
@[blueprint "def:signals-complex-gr24-crossing-double-slit"
  (title := "Complex Gr_C(2,4) pure crossing-minor double-slit intensity")
  (statement := /-- For $M\in\mathbb C^{2\times 4}$, define the pure crossing-minor intensity
    $I_{Gr_{\mathbb C}(2,4)}^{\times}(M;x,y)=I_0 E_{\mathrm{slit}}(x,y)\,
    \bigl|\Delta_{02}^{\mathbb C}(M)\Delta_{13}^{\mathbb C}(M)\bigr|^2$. -/)]
noncomputable def complexGr24CrossingDoubleSlit
    (M : Matrix (Fin 2) (Fin 4) ℂ)
    (singleSlitScale slitWidth slitHeight wavelength screenDistance x y : ℝ) : ℝ :=
  singleSlitScale *
    rectangularSlitEnvelope slitWidth slitHeight wavelength screenDistance x y *
    intensity (Signals.Geometry.complexTwoRowMinor M 0 2 *
      Signals.Geometry.complexTwoRowMinor M 1 3)

/-- **Complex Pluecker Interference Theorem**:
On $Gr_{\mathbb{C}}(2, 4)$, the squared modulus of the crossing Pluecker product
$|\Delta_{02}^{\mathbb{C}}\Delta_{13}^{\mathbb{C}}|^2$ automatically expands via the
3-term complex Pluecker relation into the sum of the two uncrossed channel intensities
plus their coherent interference cross-term $2\operatorname{Re}(\mathcal{A}_1 \overline{\mathcal{A}_2})$. -/
@[blueprint "thm:signals-complex-gr24-crossing-superposition"
  (title := "Complex Gr_C(2,4) crossing minor automatically generates the coherent cross-term")
  (statement := /-- For any $M\in\mathbb C^{2\times 4}$ with uncrossed channel products
    $\mathcal A_1=\Delta_{01}^{\mathbb C}\Delta_{23}^{\mathbb C}$ and
    $\mathcal A_2=\Delta_{03}^{\mathbb C}\Delta_{12}^{\mathbb C}$,
    $|\Delta_{02}^{\mathbb C}\Delta_{13}^{\mathbb C}|^2 = |\mathcal A_1|^2 + |\mathcal A_2|^2 + 2\operatorname{Re}(\mathcal A_1\overline{\mathcal A_2})$. -/)
  (proof := /-- Rewrite $\Delta_{02}^{\mathbb C}\Delta_{13}^{\mathbb C}=\mathcal A_1+\mathcal A_2$ via
    \texttt{complexGr24\_crossing\_eq\_channel\_sum} and apply \texttt{intensity\_superposition}. -/)]
theorem complexGr24_crossing_intensity_eq_superposition (M : Matrix (Fin 2) (Fin 4) ℂ) :
    intensity (Signals.Geometry.complexTwoRowMinor M 0 2 *
        Signals.Geometry.complexTwoRowMinor M 1 3) =
      intensity (Signals.Geometry.complexTwoRowMinor M 0 1 *
          Signals.Geometry.complexTwoRowMinor M 2 3) +
        intensity (Signals.Geometry.complexTwoRowMinor M 0 3 *
          Signals.Geometry.complexTwoRowMinor M 1 2) +
        2 * ((Signals.Geometry.complexTwoRowMinor M 0 1 *
            Signals.Geometry.complexTwoRowMinor M 2 3) *
          star (Signals.Geometry.complexTwoRowMinor M 0 3 *
            Signals.Geometry.complexTwoRowMinor M 1 2)).re := by
  rw [Signals.Geometry.complexGr24_crossing_eq_channel_sum]
  exact intensity_superposition _ _

/-- **Elimination of the 50% Unphased Proxy Error in $Gr_{\mathbb{C}}(2, 4)$**:
By lifting from the real positive Grassmannian $Gr_{\ge 0}(2, 4)$ to the complex
Grassmannian $Gr_{\mathbb{C}}(2, 4)$ with conjugate $\mathbb{C}^4$ twistor phase
entries $z_1 = \cos\theta + i\sin\theta$ and $z_2 = \cos\theta - i\sin\theta$
(where $\theta = \pi d x / (\lambda L)$), the pure crossing-minor evaluator
`complexGr24CrossingDoubleSlit` matches `fraunhoferRectangularDoubleSlit`
identically at every $(x, y)$, reducing the $50\%$ unphased proxy error to $0$. -/
@[blueprint "thm:signals-complex-gr24-eliminates-unphased-error"
  (title := "Lifting to complex Gr_C(2,4) eliminates the 50% unphased crossing-minor error")
  (statement := /-- For $\theta=\pi d x/(\lambda L)$, $z_1=\cos\theta+i\sin\theta$, and
    $z_2=\cos\theta-i\sin\theta$, the pure crossing-minor intensity satisfies
    $I_{Gr_{\mathbb C}(2,4)}^{\times}(M_{\mathbb C}(z_1,z_2);x,y)=I_{\mathrm F}(x,y)$ and
    $\varepsilon_{\mathrm{rel}}\bigl(I_{Gr_{\mathbb C}(2,4)}^{\times}(M_{\mathbb C}(z_1,z_2);x,y),I_{\mathrm F}(x,y)\bigr)=0$. -/)
  (proof := /-- By \texttt{complexGr24ChannelMatrix\_minors}, $\Delta_{02}^{\mathbb C}\Delta_{13}^{\mathbb C}=z_1+z_2=2\cos\theta$,
    whose squared complex modulus is $4\cos^2\theta$. -/)]
theorem complexGr24CrossingDoubleSlit_zero_error
    (singleSlitScale slitWidth slitHeight separation wavelength screenDistance x y : ℝ) :
    let θ := Real.pi * separation * x / (wavelength * screenDistance)
    let z1 : ℂ := ↑(Real.cos θ) + Complex.I * ↑(Real.sin θ)
    let z2 : ℂ := ↑(Real.cos θ) - Complex.I * ↑(Real.sin θ)
    complexGr24CrossingDoubleSlit (complexGr24ChannelMatrix z1 z2)
        singleSlitScale slitWidth slitHeight wavelength screenDistance x y =
      fraunhoferRectangularDoubleSlit
        singleSlitScale slitWidth slitHeight separation wavelength screenDistance x y ∧
    relativePredictiveError
      (complexGr24CrossingDoubleSlit (complexGr24ChannelMatrix z1 z2)
        singleSlitScale slitWidth slitHeight wavelength screenDistance x y)
      (fraunhoferRectangularDoubleSlit
        singleSlitScale slitWidth slitHeight separation wavelength screenDistance x y) = 0 := by
  intro θ z1 z2
  have h_sum : z1 + z2 = ((2 * Real.cos θ : ℝ) : ℂ) := by
    dsimp [z1, z2]
    push_cast
    ring
  have h_cross :
      Signals.Geometry.complexTwoRowMinor (complexGr24ChannelMatrix z1 z2) 0 2 *
        Signals.Geometry.complexTwoRowMinor (complexGr24ChannelMatrix z1 z2) 1 3 =
      ((2 * Real.cos θ : ℝ) : ℂ) := by
    rw [(complexGr24ChannelMatrix_minors z1 z2).2.2, h_sum]
  have h_int :
      intensity (Signals.Geometry.complexTwoRowMinor (complexGr24ChannelMatrix z1 z2) 0 2 *
        Signals.Geometry.complexTwoRowMinor (complexGr24ChannelMatrix z1 z2) 1 3) =
      4 * (Real.cos θ) ^ 2 := by
    rw [h_cross]
    unfold intensity
    rw [Complex.normSq_ofReal]
    ring
  have h_eq :
      complexGr24CrossingDoubleSlit (complexGr24ChannelMatrix z1 z2)
        singleSlitScale slitWidth slitHeight wavelength screenDistance x y =
      fraunhoferRectangularDoubleSlit
        singleSlitScale slitWidth slitHeight separation wavelength screenDistance x y := by
    unfold complexGr24CrossingDoubleSlit fraunhoferRectangularDoubleSlit rectangularSlitEnvelope
    rw [h_int]
    dsimp [θ]
    ring
  refine ⟨h_eq, ?_⟩
  rw [h_eq]
  simp [relativePredictiveError]

/-- **Normalized $Gr(2, 4)$ Barycentric Parallel-Axis Complementarity**:
When the crossing Pluecker product is normalized to $\Delta_{02}(M)\Delta_{13}(M) = 2$,
the squared Pluecker barycentric shift $d_{\mathrm{bary}}(M)^2$ and the squared
Pluecker visibility $\mathcal{V}_{Gr(2,4)}(M)^2 = (\Delta_{01}\Delta_{23})(\Delta_{03}\Delta_{12})$
satisfy the exact Qian--Izadi / Huygens--Steiner complementarity law
$d_{\mathrm{bary}}(M)^2 + \mathcal{V}_{Gr(2,4)}(M)^2 = 1$, and the on-axis
asymmetric relative error against the symmetric Fraunhofer reference is
$\frac{d_{\mathrm{bary}}(M)^2}{2(1 + \mathcal{V}_{Gr(2,4)}(M))}$. -/
@[blueprint "thm:signals-gr24-barycentric-complementarity"
  (title := "Gr(2,4) Pluecker barycentric shift and visibility complementarity")
  (statement := /-- When $\Delta_{02}(M)\Delta_{13}(M)=2$,
    $d_{\mathrm{bary}}(M)^2 + \Delta_{01}(M)\Delta_{23}(M)\,\Delta_{03}(M)\Delta_{12}(M) = 1$. -/)
  (proof := /-- Substitute $\Delta_{02}(M)\Delta_{13}(M)=2$ into
    \texttt{Signals.Geometry.gr24\_plucker\_pythagorean\_identity}. -/)]
theorem gr24_barycentric_complementarity
    (M : Matrix (Fin 2) (Fin 4) ℝ)
    (h_norm : Signals.Geometry.twoRowMinor M 0 2 * Signals.Geometry.twoRowMinor M 1 3 = 2) :
    (Signals.Geometry.gr24BarycentricShift M) ^ 2 +
      (Signals.Geometry.twoRowMinor M 0 1 * Signals.Geometry.twoRowMinor M 2 3) *
        (Signals.Geometry.twoRowMinor M 0 3 * Signals.Geometry.twoRowMinor M 1 2) = 1 := by
  have h := Signals.Geometry.gr24_plucker_pythagorean_identity M
  rw [h_norm] at h
  linarith

/-- **General Barycentric Parallel-Axis Equivalence in Complex $Gr_{\mathbb{C}}(2, 4)$**:
For *any* barycentric parallel-axis shift $d_{\mathrm{bary}} \in [-1, 1]$, encoding
the asymmetric slit amplitudes as complex $\mathbb{C}^4$-projected channel entries
$z_1 = \sqrt{1 + d_{\mathrm{bary}}}(\cos\theta + i\sin\theta)$ and
$z_2 = \sqrt{1 - d_{\mathrm{bary}}}(\cos\theta - i\sin\theta)$ in $M_{\mathbb{C}}(z_1, z_2)$
causes the pure crossing-minor evaluator `complexGr24CrossingDoubleSlit` to
reproduce the partially coherent Huygens--Steiner / Qian--Izadi intensity
`huygensSteinerDoubleSlit` with visibility $\mathcal{V} = \sqrt{1 - d_{\mathrm{bary}}^2}$
**identically at every $(x, y)$**, with zero relative predictive error against $I_{\mathrm{HS}}$. -/
@[blueprint "thm:signals-complex-gr24-barycentric-eq-huygens-steiner"
  (title := "Complex Gr_C(2,4) crossing minor with barycentric shift d_bary matches Huygens--Steiner identically")
  (statement := /-- For any $d_{\mathrm{bary}}\in[-1,1]$ and $\theta=\pi d x/(\lambda L)$, setting
    $z_1=\sqrt{1+d_{\mathrm{bary}}}(\cos\theta+i\sin\theta)$ and
    $z_2=\sqrt{1-d_{\mathrm{bary}}}(\cos\theta-i\sin\theta)$ yields
    $I_{Gr_{\mathbb C}(2,4)}^{\times}(M_{\mathbb C}(z_1,z_2);x,y) =
    I_{\mathrm{HS}}\bigl(x,y;\sqrt{1-d_{\mathrm{bary}}^2}\bigr)$ and zero relative error against $I_{\mathrm{HS}}$. -/)
  (proof := /-- Expand $|\Delta_{02}^{\mathbb C}\Delta_{13}^{\mathbb C}|^2 = |z_1+z_2|^2
    = (\sqrt{1+d_{\mathrm{bary}}}+\sqrt{1-d_{\mathrm{bary}}})^2\cos^2\theta
    + (\sqrt{1+d_{\mathrm{bary}}}-\sqrt{1-d_{\mathrm{bary}}})^2\sin^2\theta
    = 2\bigl(1+\sqrt{1-d_{\mathrm{bary}}^2}\cos(2\theta)\bigr)$. -/)]
theorem complexGr24CrossingDoubleSlit_barycentric_eq_huygensSteiner
    (singleSlitScale slitWidth slitHeight separation wavelength screenDistance
      d_bary x y : ℝ)
    (h_lower : -1 ≤ d_bary) (h_upper : d_bary ≤ 1) :
    let θ := Real.pi * separation * x / (wavelength * screenDistance)
    let a := Real.sqrt (1 + d_bary)
    let b := Real.sqrt (1 - d_bary)
    let z1 : ℂ := ↑(a * Real.cos θ) + Complex.I * ↑(a * Real.sin θ)
    let z2 : ℂ := ↑(b * Real.cos θ) - Complex.I * ↑(b * Real.sin θ)
    complexGr24CrossingDoubleSlit (complexGr24ChannelMatrix z1 z2)
        singleSlitScale slitWidth slitHeight wavelength screenDistance x y =
      huygensSteinerDoubleSlit
        singleSlitScale slitWidth slitHeight separation wavelength screenDistance
        (Real.sqrt (1 - d_bary ^ 2)) x y ∧
    relativePredictiveError
      (complexGr24CrossingDoubleSlit (complexGr24ChannelMatrix z1 z2)
        singleSlitScale slitWidth slitHeight wavelength screenDistance x y)
      (huygensSteinerDoubleSlit
        singleSlitScale slitWidth slitHeight separation wavelength screenDistance
        (Real.sqrt (1 - d_bary ^ 2)) x y) = 0 := by
  intro θ a b z1 z2
  have ha_nonneg : 0 ≤ 1 + d_bary := by linarith
  have hb_nonneg : 0 ≤ 1 - d_bary := by linarith
  have ha2 : a ^ 2 = 1 + d_bary := Real.sq_sqrt ha_nonneg
  have hb2 : b ^ 2 = 1 - d_bary := Real.sq_sqrt hb_nonneg
  have hab : a * b = Real.sqrt (1 - d_bary ^ 2) := by
    dsimp [a, b]
    rw [← Real.sqrt_mul ha_nonneg]
    congr 1
    ring
  have h_cross :
      Signals.Geometry.complexTwoRowMinor (complexGr24ChannelMatrix z1 z2) 0 2 *
        Signals.Geometry.complexTwoRowMinor (complexGr24ChannelMatrix z1 z2) 1 3 =
      z1 + z2 :=
    (complexGr24ChannelMatrix_minors z1 z2).2.2
  have h_normSq :
      intensity (z1 + z2) =
        ((a + b) * Real.cos θ) ^ 2 + ((a - b) * Real.sin θ) ^ 2 := by
    dsimp [z1, z2]
    simp only [intensity, Complex.normSq_apply, Complex.add_re, Complex.add_im,
      Complex.sub_re, Complex.sub_im, Complex.mul_re, Complex.mul_im,
      Complex.ofReal_re, Complex.ofReal_im, Complex.I_re, Complex.I_im]
    ring
  have h_trig : (Real.cos θ) ^ 2 + (Real.sin θ) ^ 2 = 1 := Real.cos_sq_add_sin_sq θ
  have h_cos2 : Real.cos (2 * θ) = 2 * (Real.cos θ) ^ 2 - 1 := Real.cos_two_mul θ
  have h_alg :
      ((a + b) * Real.cos θ) ^ 2 + ((a - b) * Real.sin θ) ^ 2 =
        2 * (1 + Real.sqrt (1 - d_bary ^ 2) * Real.cos (2 * θ)) := by
    calc
      ((a + b) * Real.cos θ) ^ 2 + ((a - b) * Real.sin θ) ^ 2 =
          (a ^ 2 + b ^ 2) * ((Real.cos θ) ^ 2 + (Real.sin θ) ^ 2) +
            2 * (a * b) * (2 * (Real.cos θ) ^ 2 - ((Real.cos θ) ^ 2 + (Real.sin θ) ^ 2)) := by
        ring
      _ = (1 + d_bary + (1 - d_bary)) * 1 +
            2 * Real.sqrt (1 - d_bary ^ 2) * (2 * (Real.cos θ) ^ 2 - 1) := by
        rw [ha2, hb2, h_trig, hab]
      _ = 2 * (1 + Real.sqrt (1 - d_bary ^ 2) * Real.cos (2 * θ)) := by
        rw [← h_cos2]
        ring
  have h_eq :
      complexGr24CrossingDoubleSlit (complexGr24ChannelMatrix z1 z2)
        singleSlitScale slitWidth slitHeight wavelength screenDistance x y =
      huygensSteinerDoubleSlit
        singleSlitScale slitWidth slitHeight separation wavelength screenDistance
        (Real.sqrt (1 - d_bary ^ 2)) x y := by
    unfold complexGr24CrossingDoubleSlit huygensSteinerDoubleSlit
    rw [h_cross, h_normSq, h_alg]
    dsimp [θ]
    ring
  refine ⟨h_eq, ?_⟩
  rw [h_eq]
  simp [relativePredictiveError]

/-! ## 6. Orbital Angular Momentum (OAM) Double-Slit Superposition Across Methods

When the two slits carry helical OAM phase factors $e^{i \ell_1 \phi}$ and
$e^{i \ell_2 \phi}$ with differential topological charge
$\Delta \ell = \ell_2 - \ell_1 \in \mathbb{Z}$ and azimuthal angle $\phi \in \mathbb{R}$,
the two-slit interference phase shifts by $\Delta \ell \cdot \phi$, twisting the
fringes into a forked optical vortex and creating an on-axis dark core at
$\phi = \pi$ when $\Delta \ell = 1$.
-/

/-- Analytic Fraunhofer OAM double-slit intensity with differential topological
charge `deltaOAM : ℤ` and azimuthal angle `azimuthPhi : ℝ`:
$I_{\mathrm{F,OAM}}(x, y, \phi; \Delta\ell) = 4 I_0 E_{\mathrm{slit}}(x, y) \cos^2(\pi d x / (\lambda L) + \Delta\ell\,\phi / 2)$. -/
@[blueprint "def:signals-fraunhofer-oam-double-slit"
  (title := "Fraunhofer OAM double-slit intensity with helical topological charge")
  (statement := /-- For differential OAM charge $\Delta\ell\in\mathbb Z$ and azimuthal angle
    $\phi\in\mathbb R$, define
    $I_{\mathrm{F,OAM}}(x,y,\phi;\Delta\ell)=4I_0 E_{\mathrm{slit}}(x,y)
    \cos^2\!\left(\frac{\pi d x}{\lambda L}+\frac{\Delta\ell\,\phi}{2}\right)$. -/)]
noncomputable def fraunhoferOAMDoubleSlit
    (singleSlitScale slitWidth slitHeight separation wavelength screenDistance : ℝ)
    (deltaOAM : ℤ) (azimuthPhi x y : ℝ) : ℝ :=
  4 * singleSlitScale *
    rectangularSlitEnvelope slitWidth slitHeight wavelength screenDistance x y *
    (Real.cos (Real.pi * separation * x / (wavelength * screenDistance) +
      (deltaOAM : ℝ) * azimuthPhi / 2)) ^ 2

/-- Huygens--Steiner / Qian--Izadi OAM double-slit intensity with visibility `visibility`,
differential OAM charge `deltaOAM : ℤ`, and azimuthal angle `azimuthPhi : ℝ`:
$I_{\mathrm{HS,OAM}}(x, y, \phi; \Delta\ell, \mathcal{V}) = 2 I_0 E_{\mathrm{slit}}(x, y) (1 + \mathcal{V} \cos(2\pi d x / (\lambda L) + \Delta\ell\,\phi))$. -/
@[blueprint "def:signals-huygens-steiner-oam-double-slit"
  (title := "Huygens--Steiner OAM double-slit intensity")
  (statement := /-- Define the coherence-weighted OAM double-slit intensity
    $I_{\mathrm{HS,OAM}}(x,y,\phi;\Delta\ell,\mathcal{V})=2I_0 E_{\mathrm{slit}}(x,y)
    \bigl(1+\mathcal{V}\cos(2\pi d x/(\lambda L)+\Delta\ell\,\phi)\bigr)$. -/)]
noncomputable def huygensSteinerOAMDoubleSlit
    (singleSlitScale slitWidth slitHeight separation wavelength screenDistance
      visibility : ℝ)
    (deltaOAM : ℤ) (azimuthPhi x y : ℝ) : ℝ :=
  2 * singleSlitScale *
    rectangularSlitEnvelope slitWidth slitHeight wavelength screenDistance x y *
    (1 + visibility * Real.cos
      (2 * (Real.pi * separation * x / (wavelength * screenDistance)) +
        (deltaOAM : ℝ) * azimuthPhi))

/-- Wigner angle--OAM phase-space marginal intensity with rotational decoherence
rate `oamDecoherenceRate` scaling quadratically with the OAM charge difference
$(\Delta\ell)^2$:
$I_{\mathrm{Wigner,OAM}}(x, y, \phi; \Delta\ell, \gamma_{\mathrm{OAM}}) = 2 I_0 E_{\mathrm{slit}}(x, y) (1 + e^{-\gamma_{\mathrm{OAM}} (\Delta\ell)^2} \cos(2\pi d x / (\lambda L) + \Delta\ell\,\phi))$. -/
@[blueprint "def:signals-wigner-oam-double-slit"
  (title := "Wigner angle--OAM phase-space marginal double-slit intensity")
  (statement := /-- With rotational phase-space diffusion $\gamma_{\mathrm{OAM}}(\Delta\ell)^2$,
    define $I_{\mathrm{Wigner,OAM}}(x,y,\phi;\Delta\ell,\gamma_{\mathrm{OAM}})=
    2I_0 E_{\mathrm{slit}}(x,y)\bigl(1+e^{-\gamma_{\mathrm{OAM}}(\Delta\ell)^2}
    \cos(2\pi d x/(\lambda L)+\Delta\ell\,\phi)\bigr)$. -/)]
noncomputable def wignerOAMDoubleSlit
    (singleSlitScale slitWidth slitHeight separation wavelength screenDistance
      oamDecoherenceRate : ℝ)
    (deltaOAM : ℤ) (azimuthPhi x y : ℝ) : ℝ :=
  huygensSteinerOAMDoubleSlit
    singleSlitScale slitWidth slitHeight separation wavelength screenDistance
    (Real.exp (- oamDecoherenceRate * (deltaOAM : ℝ) ^ 2))
    deltaOAM azimuthPhi x y

/-- At unit visibility ($\mathcal{V} = 1$), `huygensSteinerOAMDoubleSlit` matches
`fraunhoferOAMDoubleSlit` identically for all $(x, y, \phi)$ and $\Delta\ell \in \mathbb{Z}$. -/
@[blueprint "thm:signals-huygens-steiner-oam-unit-eq-fraunhofer"
  (title := "Unit-visibility Huygens--Steiner OAM intensity matches Fraunhofer OAM benchmark")
  (statement := /-- When $\mathcal{V}=1$,
    $I_{\mathrm{HS,OAM}}(x,y,\phi;\Delta\ell,1)=I_{\mathrm{F,OAM}}(x,y,\phi;\Delta\ell)$. -/)
  (proof := /-- Apply the double-angle identity $\cos(2\theta)=2\cos^2(\theta)-1$ to
    $\theta=\pi d x/(\lambda L)+\Delta\ell\,\phi/2$. -/)]
theorem huygensSteinerOAMDoubleSlit_unit_visibility_eq_fraunhoferOAM
    (singleSlitScale slitWidth slitHeight separation wavelength screenDistance : ℝ)
    (deltaOAM : ℤ) (azimuthPhi x y : ℝ) :
    huygensSteinerOAMDoubleSlit
      singleSlitScale slitWidth slitHeight separation wavelength screenDistance 1
      deltaOAM azimuthPhi x y =
    fraunhoferOAMDoubleSlit
      singleSlitScale slitWidth slitHeight separation wavelength screenDistance
      deltaOAM azimuthPhi x y := by
  unfold huygensSteinerOAMDoubleSlit fraunhoferOAMDoubleSlit
  have h_angle :
      2 * (Real.pi * separation * x / (wavelength * screenDistance)) +
        (deltaOAM : ℝ) * azimuthPhi =
      2 * (Real.pi * separation * x / (wavelength * screenDistance) +
        (deltaOAM : ℝ) * azimuthPhi / 2) := by
    ring
  rw [one_mul, h_angle, Real.cos_two_mul]
  ring

/-- When both slits carry the same OAM charge ($\Delta\ell = 0$), `fraunhoferOAMDoubleSlit`
reduces identically to the standard planar `fraunhoferRectangularDoubleSlit` for every
azimuthal angle $\phi$. -/
@[blueprint "lem:signals-fraunhofer-oam-zero-charge"
  (title := "Equal-charge OAM double-slit reduces to standard Fraunhofer intensity")
  (statement := /-- When $\Delta\ell=0$,
    $I_{\mathrm{F,OAM}}(x,y,\phi;0)=I_{\mathrm{F}}(x,y)$ for all $\phi$. -/)
  (proof := /-- Substitute $\Delta\ell=0$ and unfold \texttt{rectangularSlitEnvelope}. -/)
  (latexEnv := "lemma")]
lemma fraunhoferOAMDoubleSlit_zero_charge_eq_standard
    (singleSlitScale slitWidth slitHeight separation wavelength screenDistance
      azimuthPhi x y : ℝ) :
    fraunhoferOAMDoubleSlit
      singleSlitScale slitWidth slitHeight separation wavelength screenDistance 0
      azimuthPhi x y =
    fraunhoferRectangularDoubleSlit
      singleSlitScale slitWidth slitHeight separation wavelength screenDistance x y := by
  unfold fraunhoferOAMDoubleSlit fraunhoferRectangularDoubleSlit rectangularSlitEnvelope
  simp only [Int.cast_zero, zero_mul, zero_div, add_zero]
  ring

/-- **OAM Fork Vortex Singularity at $\Delta\ell = 1, \phi = \pi$**:
When $\Delta\ell = 1$, at $(x, y) = (0, 0)$ and $\phi = \pi$, the azimuthal helical
phase shift $\Delta\ell\,\phi / 2 = \pi / 2$ causes exact destructive cancellation
on the optical axis ($I_{\mathrm{F,OAM}}(0, 0, \pi; 1) = 0$), so an unphased /
non-OAM Fraunhofer reference ($I_{\mathrm{F}}(0, 0) = 4 I_0$) incurs a $100\%$ ($1$)
on-axis relative error. -/
@[blueprint "thm:signals-fraunhofer-oam-vortex-null-pi"
  (title := "On-axis OAM vortex phase-singularity null and 100% non-OAM relative error at φ = π")
  (statement := /-- For $\Delta\ell=1$ and $\phi=\pi$, $I_{\mathrm{F,OAM}}(0,0,\pi;1)=0$,
    and for $I_0>0$, $\varepsilon_{\mathrm{rel}}\bigl(I_{\mathrm{F,OAM}}(0,0,\pi;1),
    I_{\mathrm{F}}(0,0)\bigr)=1$. -/)
  (proof := /-- Evaluate $\cos(\pi/2)=0$ at $(0,0,\pi)$, then compute $|0-4I_0|/(4I_0)=1$. -/)]
theorem fraunhoferOAMDoubleSlit_vortex_null_at_pi
    (singleSlitScale slitWidth slitHeight separation wavelength screenDistance : ℝ)
    (h_scale : 0 < singleSlitScale) :
    fraunhoferOAMDoubleSlit
        singleSlitScale slitWidth slitHeight separation wavelength screenDistance
        1 Real.pi 0 0 = 0 ∧
      relativePredictiveError
        (fraunhoferOAMDoubleSlit
          singleSlitScale slitWidth slitHeight separation wavelength screenDistance
          1 Real.pi 0 0)
        (fraunhoferRectangularDoubleSlit
          singleSlitScale slitWidth slitHeight separation wavelength screenDistance 0 0) = 1 := by
  have h_zero :
      fraunhoferOAMDoubleSlit
        singleSlitScale slitWidth slitHeight separation wavelength screenDistance
        1 Real.pi 0 0 = 0 := by
    unfold fraunhoferOAMDoubleSlit
    simp [Real.cos_pi_div_two]
  refine ⟨h_zero, ?_⟩
  rw [h_zero, fraunhoferRectangularDoubleSlit_onAxis]
  unfold relativePredictiveError
  rw [zero_sub, abs_neg, abs_of_pos (by linarith : 0 < 4 * singleSlitScale),
    div_self (by linarith : 4 * singleSlitScale ≠ 0)]

/-- **Wigner Angle--OAM Phase-Space Relative Predictive Error Law**:
For $I_0 > 0$ and $\gamma_{\mathrm{OAM}} \ge 0$, at $(x, y, \phi) = (0, 0, 0)$ the
relative predictive error between `wignerOAMDoubleSlit` and `fraunhoferOAMDoubleSlit`
equals $\frac{1 - e^{-\gamma_{\mathrm{OAM}} (\Delta\ell)^2}}{2}$, which vanishes when
$\Delta\ell = 0$ and increases with $|\Delta\ell|$. -/
@[blueprint "thm:signals-wigner-oam-on-axis-relative-error"
  (title := "Quadratic OAM charge-difference scaling of Wigner phase-space relative error")
  (statement := /-- For $I_0>0$ and $\gamma_{\mathrm{OAM}}\ge 0$, at $(x,y,\phi)=(0,0,0)$,
    $\varepsilon_{\mathrm{rel}}\bigl(I_{\mathrm{Wigner,OAM}}(0,0,0;\Delta\ell,\gamma_{\mathrm{OAM}}),
    I_{\mathrm{F,OAM}}(0,0,0;\Delta\ell)\bigr)
    = \frac{1-e^{-\gamma_{\mathrm{OAM}}(\Delta\ell)^2}}{2}$. -/)
  (proof := /-- Reduce at $\phi=0$ to \texttt{wigner\_onAxis\_relative\_error} with effective
    decoherence rate $\gamma_{\mathrm{OAM}}(\Delta\ell)^2\ge 0$. -/)]
theorem wignerOAM_onAxis_relative_error
    (singleSlitScale slitWidth slitHeight separation wavelength screenDistance
      oamDecoherenceRate : ℝ)
    (deltaOAM : ℤ)
    (h_scale : 0 < singleSlitScale) (h_dec : 0 ≤ oamDecoherenceRate) :
    relativePredictiveError
      (wignerOAMDoubleSlit
        singleSlitScale slitWidth slitHeight separation wavelength screenDistance
        oamDecoherenceRate deltaOAM 0 0 0)
      (fraunhoferOAMDoubleSlit
        singleSlitScale slitWidth slitHeight separation wavelength screenDistance
        deltaOAM 0 0 0) =
    (1 - Real.exp (- (oamDecoherenceRate * (deltaOAM : ℝ) ^ 2))) / 2 := by
  have h_wigner :
      wignerOAMDoubleSlit
        singleSlitScale slitWidth slitHeight separation wavelength screenDistance
        oamDecoherenceRate deltaOAM 0 0 0 =
      wignerDoubleSlit
        singleSlitScale slitWidth slitHeight separation wavelength screenDistance
        (oamDecoherenceRate * (deltaOAM : ℝ) ^ 2) 0 0 := by
    unfold wignerOAMDoubleSlit wignerDoubleSlit huygensSteinerOAMDoubleSlit
    simp
  have h_fraun :
      fraunhoferOAMDoubleSlit
        singleSlitScale slitWidth slitHeight separation wavelength screenDistance
        deltaOAM 0 0 0 =
      fraunhoferRectangularDoubleSlit
        singleSlitScale slitWidth slitHeight separation wavelength screenDistance 0 0 := by
    unfold fraunhoferOAMDoubleSlit fraunhoferRectangularDoubleSlit rectangularSlitEnvelope
    simp
  rw [h_wigner, h_fraun]
  have h_rate_nonneg : 0 ≤ oamDecoherenceRate * (deltaOAM : ℝ) ^ 2 :=
    mul_nonneg h_dec (sq_nonneg _)
  exact wigner_onAxis_relative_error
    singleSlitScale slitWidth slitHeight separation wavelength screenDistance
    (oamDecoherenceRate * (deltaOAM : ℝ) ^ 2) h_scale h_rate_nonneg

end Signals.Huygens
