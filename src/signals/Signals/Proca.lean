import Mathlib.Data.Real.Basic
import Mathlib.Tactic
import Signals.IQ
import Signals.Maxwell

namespace Signals.Proca

/-- A homogeneous medium parameter used by the normalized field model. -/
structure Medium where
  refractiveIndex : ℝ
  refractiveIndex_pos : 0 < refractiveIndex

/-- A scalar reflection boundary condition with an explicit amplitude bound. -/
structure BoundaryCondition where
  reflectionMagnitude : ℝ
  reflectionMagnitude_nonneg : 0 ≤ reflectionMagnitude
  reflectionMagnitude_le_one : reflectionMagnitude ≤ 1

/-- Parameters of a massive-vector field model.

The mass and coupling are model parameters in normalized units. This structure
does not assert that the model describes an optical field in ordinary air. -/
structure Model where
  mass : ℝ
  mass_pos : 0 < mass
  coupling : ℝ
  medium : Medium
  boundary : BoundaryCondition

/-- A normalized four-current with an explicit continuity residual. -/
structure FourCurrent where
  chargeDensity : ℝ
  currentX : ℝ
  currentY : ℝ
  currentZ : ℝ
  continuityResidual : ℝ

/- View a Proca four-current through the shared Maxwell source boundary. -/
def FourCurrent.toSource (source : FourCurrent) : Maxwell.Source :=
  { chargeDensity := source.chargeDensity
    current := fun axis =>
      match axis.val with
      | 0 => source.currentX
      | 1 => source.currentY
      | _ => source.currentZ
    continuityResidual := source.continuityResidual }

/-- Constitutive response data for a homogeneous matter model.

The parameters are normalized real values. Conductivity and loss tangent are
nonnegative so attenuation cannot be silently represented as gain. -/
structure ConstitutiveRelation where
  relativePermittivity : ℝ
  relativePermittivity_pos : 0 < relativePermittivity
  relativePermeability : ℝ
  relativePermeability_pos : 0 < relativePermeability
  conductivity : ℝ
  conductivity_nonneg : 0 ≤ conductivity
  lossTangent : ℝ
  lossTangent_nonneg : 0 ≤ lossTangent

/-- Coupling data between a Proca field and ordinary matter. -/
structure MatterCoupling where
  strength : ℝ
  strength_nonneg : 0 ≤ strength
  constitutive : ConstitutiveRelation
  source : FourCurrent

/-- A source-driven Proca equation in normalized units.

Taking the divergence of the sourced field equation gives the displayed
relation between source nonconservation and field four-divergence. -/
structure DrivenField (model : Model) where
  fourDivergence : ℝ
  coupling : MatterCoupling
  couplingStrengthLaw : coupling.strength = model.coupling
  fieldEquation : model.mass ^ 2 * fourDivergence =
    coupling.strength * coupling.source.continuityResidual

/-- A conserved source forces the source-driven Proca field to be divergence-free. -/
lemma DrivenField.lorenz_condition {model : Model} (field : DrivenField model)
    (source_conserved : field.coupling.source.continuityResidual = 0) :
    field.fourDivergence = 0 := by
  have equation_zero : model.mass ^ 2 * field.fourDivergence = 0 := by
    rw [field.fieldEquation, source_conserved, mul_zero]
  exact (mul_eq_zero.mp equation_zero).resolve_left
    (pow_ne_zero 2 (ne_of_gt model.mass_pos))

/-- The sourced equation exposes the continuity residual used by the model. -/
lemma DrivenField.source_balance {model : Model} (field : DrivenField model) :
    model.mass ^ 2 * field.fourDivergence =
      field.coupling.strength * field.coupling.source.continuityResidual :=
  field.fieldEquation

/-- A four-component vector in the `(time, x, y, z)` ordering. -/
structure FourVector where
  time : ℝ
  x : ℝ
  y : ℝ
  z : ℝ

/-- The Minkowski bilinear form with signature `(+,-,-,-)`. -/
def minkowskiDot (left right : FourVector) : ℝ :=
  left.time * right.time - left.x * right.x - left.y * right.y - left.z * right.z

/-- A mode satisfying the normalized massive-vector dispersion relation.

The transverse and longitudinal wave numbers are explicit so that propagation
and boundary assumptions are not hidden inside a single opaque formula. -/
structure Mode (model : Model) where
  frequency : ℝ
  frequency_pos : 0 < frequency
  transverseWaveNumber : ℝ
  longitudinalWaveNumber : ℝ
  dispersion : frequency ^ 2 = model.mass ^ 2 + transverseWaveNumber ^ 2 +
    longitudinalWaveNumber ^ 2

/-- The mode four-momentum for a wave travelling in the positive z direction. -/
def Mode.momentum {model : Model} (mode : Mode model) : FourVector :=
  { time := mode.frequency
    x := 0
    y := 0
    z := mode.longitudinalWaveNumber }

/-- The longitudinal polarization used by the normalized Proca mode model. -/
noncomputable def Mode.longitudinalPolarization {model : Model} (mode : Mode model) : FourVector :=
  { time := mode.longitudinalWaveNumber / model.mass
    x := 0
    y := 0
    z := mode.frequency / model.mass }

/-- The dispersion relation is part of the mode's explicit field assumptions. -/
lemma Mode.dispersion_relation {model : Model} (mode : Mode model) :
    mode.frequency ^ 2 = model.mass ^ 2 + mode.transverseWaveNumber ^ 2 +
      mode.longitudinalWaveNumber ^ 2 :=
  mode.dispersion

/-- The longitudinal polarization is Minkowski-orthogonal to its momentum. -/
lemma Mode.momentum_dot_longitudinalPolarization_eq_zero {model : Model}
    (mode : Mode model) :
    minkowskiDot mode.momentum mode.longitudinalPolarization = 0 := by
  unfold minkowskiDot Mode.momentum Mode.longitudinalPolarization
  field_simp [ne_of_gt model.mass_pos]
  ring

/-- A round-trip boundary measurement whose phase is assumed to be unwrapped. -/
structure PhaseHeightMeasurement where
  waveNumber : ℝ
  waveNumber_ne_zero : waveNumber ≠ 0
  height : ℝ
  unwrappedPhase : ℝ
  roundTripPhase : unwrappedPhase = 2 * waveNumber * height

/-- Recover height from an unwrapped round-trip phase measurement. -/
lemma PhaseHeightMeasurement.height_eq_heightFromPhase
    (measurement : PhaseHeightMeasurement) :
    measurement.height =
      IQ.heightFromPhase measurement.waveNumber measurement.unwrappedPhase := by
  rw [IQ.heightFromPhase, measurement.roundTripPhase]
  field_simp [measurement.waveNumber_ne_zero]

/-- The I/Q sample form of a phase-height measurement. -/
noncomputable def PhaseHeightMeasurement.sample (measurement : PhaseHeightMeasurement)
    (magnitude : ℝ) : IQ.Sample :=
  { inPhase := magnitude * Real.cos measurement.unwrappedPhase
    quadrature := magnitude * Real.sin measurement.unwrappedPhase }

/-- Under the round-trip assumption, the reconstructed sample height is exact. -/
lemma PhaseHeightMeasurement.sample_height_eq_height
  (measurement : PhaseHeightMeasurement) (_magnitude : ℝ) :
    IQ.heightFromPhase measurement.waveNumber measurement.unwrappedPhase =
      measurement.height := by
  symm
  exact measurement.height_eq_heightFromPhase

end Signals.Proca