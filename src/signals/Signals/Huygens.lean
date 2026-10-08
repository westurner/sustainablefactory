import Mathlib.Analysis.Complex.Exponential
import Mathlib.Analysis.SpecialFunctions.Sqrt
import Mathlib.Tactic
import Signals.Units

namespace Signals.Huygens

/-! Finite scalar Huygens-Fresnel quadrature in three spatial dimensions.

Coordinates and wavelengths are in metres. Aperture weights include the supplied
quadrature, transmission, and obliquity factors. Intensity is an uncalibrated
squared complex amplitude, not irradiance or a normalized probability density.
No continuum integral, vector boundary-value problem, or quantum path measure
is asserted by these definitions.
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
noncomputable def MonochromaticWave.kernel (wave : MonochromaticWave)
    (source detector : Point3) : ℂ :=
  Complex.exp (Complex.I * ((wave.wavenumber * distance source detector : ℝ) : ℂ)) /
    (distance source detector : ℂ)

/-- Finite aperture samples with supplied complex quadrature coefficients. -/
structure Aperture (sampleCount : ℕ) where
  point : Fin sampleCount → Point3
  weight : Fin sampleCount → ℂ

/-- The sampled propagation avoids coincident source, aperture, and detector points. -/
def Aperture.regularAt {sampleCount : ℕ} (aperture : Aperture sampleCount)
    (source detector : Point3) : Prop :=
  ∀ sample, aperture.point sample ≠ source ∧ aperture.point sample ≠ detector

/-- A finite source-to-aperture-to-detector Huygens-Fresnel sum. -/
noncomputable def Aperture.amplitude {sampleCount : ℕ} (aperture : Aperture sampleCount)
    (wave : MonochromaticWave) (source detector : Point3) : ℂ :=
  ∑ sample, aperture.weight sample * wave.kernel source (aperture.point sample) *
    wave.kernel (aperture.point sample) detector

/-- An empty aperture contributes no amplitude. -/
lemma Aperture.amplitude_empty (aperture : Aperture 0)
    (wave : MonochromaticWave) (source detector : Point3) :
    aperture.amplitude wave source detector = 0 := by
  simp [Aperture.amplitude]

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
def intensity (amplitude : ℂ) : ℝ := Complex.normSq amplitude

/-- Squared complex amplitudes are nonnegative. -/
lemma intensity_nonnegative (amplitude : ℂ) : 0 ≤ intensity amplitude :=
  Complex.normSq_nonneg amplitude

/-- Superposition includes the coherent cross term, not just the sum of intensities. -/
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
lemma intensity_destructive (amplitude : ℂ) : intensity (amplitude + -amplitude) = 0 := by
  simp [intensity]

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

end Signals.Huygens
