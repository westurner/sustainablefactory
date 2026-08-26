import Mathlib.Tactic
import Signals

namespace SignalsTests

open Signals.Fabrication
open Signals.Geometry
open Signals.IQ
open Signals.Proca
open Signals.Sampling
open Signals.Units
open Signals.Propagation
open Signals.Applications
open Signals.Acoustics
open Signals.Maxwell
open Signals.Scattering

def zeroCalculus : VectorCalculus where
  divergence := fun _ => 0
  curl := fun _ => 0
  vectorTimeDerivative := fun _ => 0
  scalarTimeDerivative := fun _ => 0
  divergence_curl := by intro; rfl
  divergence_add := by intro left right; norm_num
  divergence_timeDerivative := by intro; rfl

def zeroMaxwell : System zeroCalculus where
  electricField := 0
  displacementField := 0
  magneticField := 0
  magneticIntensity := 0
  rho := 0
  current := 0
  gaussElectric := by rfl
  gaussMagnetic := by rfl
  faraday := by
    ext index
    simp [zeroCalculus]
  ampere := by
    ext index
    simp [zeroCalculus]

example : zeroCalculus.divergence zeroMaxwell.displacementField = zeroMaxwell.rho := by
  exact zeroMaxwell.gauss_electric

example : zeroCalculus.divergence zeroMaxwell.magneticField = 0 := by
  exact zeroMaxwell.gauss_magnetic

example : zeroCalculus.curl zeroMaxwell.electricField =
    -zeroCalculus.vectorTimeDerivative zeroMaxwell.magneticField := by
  exact zeroMaxwell.faraday_law

example : zeroCalculus.curl zeroMaxwell.magneticIntensity =
    zeroMaxwell.current + zeroCalculus.vectorTimeDerivative zeroMaxwell.displacementField := by
  exact zeroMaxwell.ampere_maxwell_law

example : zeroCalculus.scalarTimeDerivative zeroMaxwell.rho +
    zeroCalculus.divergence zeroMaxwell.current = 0 := by
  exact zeroMaxwell.charge_continuity

def zeroMaterial : MaterialParameters where
  permittivity := 2
  permittivity_pos := by norm_num
  permeability := 3
  permeability_pos := by norm_num

def zeroOriginalVacuum : OriginalVacuumSystem zeroCalculus where
  parameters := zeroMaterial
  electricField := 0
  magneticField := 0
  rho := 0
  current := 0
  gaussElectric := by norm_num [zeroCalculus, zeroMaterial]
  gaussMagnetic := by rfl
  faraday := by
    ext index
    simp [zeroCalculus]
  ampere := by
    ext index
    simp [zeroCalculus]

example : zeroCalculus.divergence zeroOriginalVacuum.electricField =
    zeroOriginalVacuum.rho / zeroOriginalVacuum.parameters.permittivity := by
  exact zeroOriginalVacuum.gauss_electric

example : zeroCalculus.divergence zeroOriginalVacuum.magneticField = 0 := by
  exact zeroOriginalVacuum.gauss_magnetic

example : zeroCalculus.curl zeroOriginalVacuum.magneticField =
    zeroOriginalVacuum.parameters.permeability • zeroOriginalVacuum.current +
      (zeroOriginalVacuum.parameters.permeability * zeroOriginalVacuum.parameters.permittivity) •
        zeroCalculus.vectorTimeDerivative zeroOriginalVacuum.electricField := by
  exact zeroOriginalVacuum.ampere_maxwell_law

example : (⟨0, 0⟩ : Sample).magnitude = 0 := by
  rw [Sample.zero_magnitude_iff]
  norm_num

example : (⟨3, 4⟩ : Sample).magnitude = 5 := by
  rw [Sample.magnitude, Sample.normSq_eq]
  norm_num

example : (⟨-1, 0⟩ : Sample).phase = Real.pi := by
  rw [Sample.phase]
  change Complex.arg ({ re := -1, im := 0 } : ℂ) = Real.pi
  have negative_one : ({ re := (-1 : ℝ), im := 0 } : ℂ) = (-1 : ℂ) := by
    apply Complex.ext <;> norm_num
  rw [negative_one]
  exact Complex.arg_neg_one

example (convention : Convention) (sample : Sample) :
    (convention.orient sample).magnitude = sample.magnitude := by
  exact convention.orient_magnitude sample

example (frequency phase : ℝ) (rate : SamplingRate) (aliasIndex : ℤ) (index : ℕ) :
    toneSample 1 (aliasedFrequency frequency rate aliasIndex) rate.hz phase index =
      toneSample 1 frequency rate.hz phase index := by
  exact toneSample_aliased 1 frequency phase rate aliasIndex index

example : ¬ (InBand ⟨1, by norm_num⟩ 1 ∧ InBand ⟨1, by norm_num⟩ 4) := by
  intro frequencies
  exact no_one_rate_alias (bandwidth := ⟨1, by norm_num⟩)
    (rate := ⟨3, by norm_num⟩) (by norm_num [NyquistCondition]) frequencies.1 frequencies.2
      (by norm_num)

def toyModel : Model :=
  { mass := 3
    mass_pos := by norm_num
    coupling := 1
    medium := { refractiveIndex := 1, refractiveIndex_pos := by norm_num }
    boundary :=
      { reflectionMagnitude := 1
        reflectionMagnitude_nonneg := by norm_num
        reflectionMagnitude_le_one := by norm_num } }

def toyMode : Mode toyModel :=
  { frequency := 5
    frequency_pos := by norm_num
    transverseWaveNumber := 0
    longitudinalWaveNumber := 4
    dispersion := by norm_num [toyModel] }

example : minkowskiDot toyMode.momentum toyMode.longitudinalPolarization = 0 := by
  exact Mode.momentum_dot_longitudinalPolarization_eq_zero toyMode

def toyMeasurement : PhaseHeightMeasurement :=
  { waveNumber := 2
    waveNumber_ne_zero := by norm_num
    height := 3
    unwrappedPhase := 12
    roundTripPhase := by norm_num }

example : toyMeasurement.height =
  Signals.IQ.heightFromPhase toyMeasurement.waveNumber toyMeasurement.unwrappedPhase := by
  exact toyMeasurement.height_eq_heightFromPhase

def toyCurrent : FourCurrent :=
  { chargeDensity := 0
    currentX := 0
    currentY := 0
    currentZ := 0
    continuityResidual := 0
    conserved := by norm_num }

def toyConstitutive : ConstitutiveRelation :=
  { relativePermittivity := 2
    relativePermittivity_pos := by norm_num
    relativePermeability := 1
    relativePermeability_pos := by norm_num
    conductivity := 0
    conductivity_nonneg := by norm_num
    lossTangent := 0
    lossTangent_nonneg := by norm_num }

def toyMatterCoupling : MatterCoupling :=
  { strength := 1
    strength_nonneg := by norm_num
    constitutive := toyConstitutive
    source := toyCurrent }

def toyDrivenField : DrivenField toyModel :=
  { fourDivergence := 0
    coupling := toyMatterCoupling
    fieldEquation := by norm_num [toyModel, toyMatterCoupling, toyCurrent] }

example : toyDrivenField.fourDivergence = 0 := by
  exact toyDrivenField.lorenz_condition

example :
    toyModel.mass ^ 2 * toyDrivenField.fourDivergence =
      toyDrivenField.coupling.source.continuityResidual := by
  exact toyDrivenField.source_balance

def toyConversion : NonlinearConversion :=
  { nonlinearCoefficient := 1
    nonlinearCoefficient_nonnegative := by norm_num
    mechanicalSusceptibility := 1
    mechanicalSusceptibility_nonnegative := by norm_num
    phaseMatching := { value := 1, nonnegative := by norm_num, le_one := by norm_num }
    modeOverlap := { value := 1, nonnegative := by norm_num, le_one := by norm_num }
    propagationLoss := 0
    propagationLoss_nonnegative := by norm_num
    interactionLength := 1
    interactionLength_nonnegative := by norm_num
    boundary :=
      { reflectionPower := 0
        transmissionPower := 1
        absorptionPower := 0
        reflection_nonnegative := by norm_num
        transmission_nonnegative := by norm_num
        absorption_nonnegative := by norm_num
        power_conservation := by norm_num } }

def toyPump : FireCannonPump :=
  { beamA :=
      { center := gigahertz 400
        center_positive := by norm_num [gigahertz]
        halfWidthHz := 1
        halfWidth_nonnegative := by norm_num }
    beamB :=
      { center := gigahertz 400
        center_positive := by norm_num [gigahertz]
        halfWidthHz := 1
        halfWidth_nonnegative := by norm_num }
    conversion := toyConversion }

example : toyPump.sumFrequency.hz = (gigahertz 800).hz := by
  apply FireCannonPump.two_400GHz_sum
  · rfl
  · rfl

example : 0 ≤ toyConversion.response := by
  exact toyConversion.response_nonnegative

noncomputable def toyCouplingFactors : CouplingFactors :=
  { regime := CouplingRegime.nearField
    antennaEfficiency := { value := 9 / 10, nonnegative := by norm_num, le_one := by norm_num }
    impedanceMatch := { value := 4 / 5, nonnegative := by norm_num, le_one := by norm_num }
    apertureCoupling := { value := 3 / 4, nonnegative := by norm_num, le_one := by norm_num }
    alignment := { value := 9 / 10, nonnegative := by norm_num, le_one := by norm_num }
    radiativeCoupling := { value := 7 / 8, nonnegative := by norm_num, le_one := by norm_num }
    reactiveFraction := { value := 1 / 10, nonnegative := by norm_num, le_one := by norm_num }
    energyPartition := by norm_num }

noncomputable def toyInterface : InterfaceResponse :=
  { reflectionPower := 1 / 10
    transmissionPower := 4 / 5
    absorptionPower := 1 / 10
    reflection_nonnegative := by norm_num
    transmission_nonnegative := by norm_num
    absorption_nonnegative := by norm_num
    power_conservation := by norm_num }

noncomputable def toyMediumLoss : MediumLoss :=
  { attenuationPerLength := 1 / 10
    attenuation_nonneg := by norm_num
    bulkTransmission := { value := 9 / 10, nonnegative := by norm_num, le_one := by norm_num } }

noncomputable def toyLink : LinkBudget :=
  { mode := PropagationMode.lithosphericChord
    sourcePower := 100
    sourcePower_nonnegative := by norm_num
    distance := 2
    distance_nonnegative := by norm_num
    coupling := toyCouplingFactors
    medium := toyMediumLoss
    interface := toyInterface }

example : 0 ≤ toyCouplingFactors.total ∧ toyCouplingFactors.total ≤ 1 := by
  exact ⟨toyCouplingFactors.total_nonnegative, toyCouplingFactors.total_le_one⟩

example : toyLink.transferFactor ≤ 1 := by
  exact toyLink.transferFactor_le_one

example : toyCouplingFactors.reactiveFraction.value + toyCouplingFactors.radiativeCoupling.value ≤ 1 := by
  exact toyCouplingFactors.reactive_plus_radiative_le_one

example : toyLink.receivedPower ≤ toyLink.sourcePower := by
  exact toyLink.receivedPower_le_sourcePower

noncomputable def toyPowerTransfer : PowerTransfer :=
  { link := toyLink
    receiverEfficiency := { value := 3 / 4, nonnegative := by norm_num, le_one := by norm_num } }

example : toyPowerTransfer.usablePower ≤ toyPowerTransfer.link.receivedPower := by
  exact toyPowerTransfer.usablePower_le_receivedPower

noncomputable def toyAcousticMedium : Signals.Acoustics.Medium :=
  { density := 1
    density_pos := by norm_num
    soundSpeed := 1
    soundSpeed_pos := by norm_num
    attenuationPerLength := 0
    attenuation_nonnegative := by norm_num }

noncomputable def toyAcousticWave : Signals.Acoustics.Wave :=
  { frequencyHz := 30000
    frequency_positive := by norm_num
    pressureAmplitude := 10
    pressureAmplitude_nonnegative := by norm_num
    medium := toyAcousticMedium }

example : toyAcousticMedium.impedance = 1 := by
  norm_num [Signals.Acoustics.Medium.impedance, toyAcousticMedium]

example : toyAcousticWave.intensity = 100 := by
  norm_num [Signals.Acoustics.Wave.intensity, toyAcousticWave,
    Signals.Acoustics.Medium.impedance, toyAcousticMedium]

noncomputable def toyUltrasonicTransfer : Signals.Acoustics.UltrasonicTransfer :=
  { wave := toyAcousticWave
    ultrasonicFrequency := by norm_num [toyAcousticWave]
    link := toyLink
    apertureArea := 1
    apertureArea_pos := by norm_num
    transmitterEfficiency := { value := 1 / 2, nonnegative := by norm_num, le_one := by norm_num }
    receiverEfficiency := { value := 1 / 2, nonnegative := by norm_num, le_one := by norm_num }
    sourcePowerLaw := by
      norm_num [toyLink, toyAcousticWave, toyAcousticMedium,
        Signals.Acoustics.Wave.intensity, Signals.Acoustics.Medium.impedance,
        toyCouplingFactors, toyInterface, toyMediumLoss] }

example : 0 ≤ toyUltrasonicTransfer.receivedPower := by
  exact toyUltrasonicTransfer.receivedPower_nonnegative

example : toyUltrasonicTransfer.receivedPower ≤ toyUltrasonicTransfer.incidentPower := by
  exact toyUltrasonicTransfer.receivedPower_le_incidentPower

noncomputable def toyScatteringObservation : Signals.Scattering.Observation :=
  { incident := ⟨1, 0⟩
    incidentNormSq := 1
    incidentNormSq_pos := by norm_num
    incidentNormSqLaw := by
      norm_num [Signals.IQ.Sample.asComplex, Complex.normSq]
    scattered := ⟨0, 1⟩ }

example : toyScatteringObservation.powerRatio = 1 := by
  norm_num [Signals.Scattering.Observation.powerRatio,
    toyScatteringObservation, Signals.IQ.Sample.asComplex, Complex.normSq]

example : toyScatteringObservation.incident.asComplex ≠ 0 := by
  exact toyScatteringObservation.incident_ne_zero

example : 0 ≤ toyScatteringObservation.powerRatio := by
  exact toyScatteringObservation.powerRatio_nonnegative

def toyScatteringHeight : Signals.Scattering.HeightModel :=
  { waveNumber := 2
    waveNumber_ne_zero := by norm_num
    referencePhase := 1
    height := 3
    unwrappedPhase := 13
    roundTripLaw := by norm_num }

example : toyScatteringHeight.reconstructHeight = 3 := by
  norm_num [Signals.Scattering.HeightModel.reconstructHeight, toyScatteringHeight]

example : toyScatteringHeight.reconstructHeight = toyScatteringHeight.height := by
  exact toyScatteringHeight.reconstructHeight_eq_height

def toyCrossSection : Signals.Scattering.CrossSectionMeasurement :=
  { incidentFlux := 2
    incidentFlux_pos := by norm_num
    scatteredPower := 6
    scatteredPower_nonnegative := by norm_num
    crossSection := 3
    crossSection_nonnegative := by norm_num
    powerLaw := by norm_num }

example : toyCrossSection.crossSection = toyCrossSection.scatteredPower /
    toyCrossSection.incidentFlux := by
  exact toyCrossSection.crossSection_eq_ratio

def toyConsistentResidual : Signals.Scattering.ResidualMeasurement :=
  { predicted := 10
    observed := 10.1
    residual := 0.1
    tolerance := 0.1
    tolerance_nonnegative := by norm_num
    residualLaw := by norm_num }

def toyAnomalousResidual : Signals.Scattering.ResidualMeasurement :=
  { predicted := 10
    observed := 10.5
    residual := 0.5
    tolerance := 0.1
    tolerance_nonnegative := by norm_num
    residualLaw := by norm_num }

example : toyConsistentResidual.consistent := by
  norm_num [Signals.Scattering.ResidualMeasurement.consistent, toyConsistentResidual]

example : toyAnomalousResidual.anomalyCandidate := by
  norm_num [Signals.Scattering.ResidualMeasurement.anomalyCandidate,
    Signals.Scattering.ResidualMeasurement.consistent, toyAnomalousResidual]

def toySNR : Signals.Scattering.SignalToNoise :=
  { signalPower := 4
    signalPower_nonnegative := by norm_num
    noisePower := 2
    noisePower_pos := by norm_num }

example : toySNR.ratio = 2 := by
  norm_num [Signals.Scattering.SignalToNoise.ratio, toySNR]

noncomputable def toyMimo : MimoArray :=
  { elementCount := 2
    elementCount_positive := by norm_num
    elementPower := { watts := 100 }
    elementPower_nonnegative := by norm_num
    arrayEfficiency := { value := 1 / 2, nonnegative := by norm_num, le_one := by norm_num } }

example : toyMimo.sourcePower = 100 := by
  norm_num [MimoArray.sourcePower, toyMimo]

example : toyMimo.sourcePower ≤ toyMimo.elementCount * toyMimo.elementPower.watts := by
  exact toyMimo.sourcePower_le_element_budget

example :
    1.3 * 10 ^ 9 <
        (planeWaveIrradiance ⟨10 ^ 6⟩).wattsPerSquareMeter ∧
      (planeWaveIrradiance ⟨10 ^ 6⟩).wattsPerSquareMeter < 1.4 * 10 ^ 9 := by
  exact irradiance_one_megavolt_per_meter_bounds

example :
    132000 < wattsPerSquareCentimeter (planeWaveIrradiance ⟨10 ^ 6⟩) ∧
      wattsPerSquareCentimeter (planeWaveIrradiance ⟨10 ^ 6⟩) < 134000 := by
  exact irradiance_one_megavolt_per_meter_watts_per_square_centimeter_bounds

example (matrix : Matrix2x4) :
    minor matrix 0 1 * minor matrix 2 3 -
      minor matrix 0 2 * minor matrix 1 3 +
      minor matrix 0 3 * minor matrix 1 2 = 0 := by
  exact pluecker_relation matrix

def identityColumns : OrderedColumns 2 2 :=
  { index := id
    strictlyIncreasing := strictMono_id }

def negativeMinorMatrix : GrassmannianMatrix 2 2 :=
  { mat := !![1, 0; 0, -1] }

example : negativeMinorMatrix.pluckerCoordinate identityColumns = -1 := by
  rw [GrassmannianMatrix.pluckerCoordinate, selectedMinor,
    Matrix.det_fin_two]
  norm_num [negativeMinorMatrix, identityColumns, Matrix.submatrix]

def positiveMinorMatrix : GrassmannianMatrix 1 1 :=
  { mat := !![1] }

def positiveIdentityColumns : OrderedColumns 1 1 :=
  { index := id
    strictlyIncreasing := strictMono_id }

def positiveMinorWitness : PositiveGrassmannian 1 1 :=
  { toGrassmannianMatrix := positiveMinorMatrix
    strictly_positive := by
      intro columns
      have index_zero : columns.index 0 = 0 := Fin.eq_zero (columns.index 0)
      change 0 < (positiveMinorMatrix.mat.submatrix id columns.index).det
      rw [Matrix.det_fin_one]
      change 0 < positiveMinorMatrix.mat 0 (columns.index 0)
      rw [index_zero]
      norm_num [positiveMinorMatrix, Matrix.submatrix] }

example : positiveMinorWitness.pluckerCoordinate positiveIdentityColumns = 1 := by
  norm_num [GrassmannianMatrix.pluckerCoordinate, selectedMinor,
    positiveMinorWitness, positiveMinorMatrix, positiveIdentityColumns,
    Matrix.submatrix]

def unitMassMomentum : FourMomentum :=
  { energy := 1
    px := 0
    py := 0
    pz := 0
    mass := 1
    mass_nonnegative := by norm_num
    mass_shell := by norm_num }

def unitMassFactorization : MassiveSpinorHelicity unitMassMomentum :=
  { left := fun label =>
      if label = 0 then { first := 1, second := 0 }
      else { first := 0, second := 1 }
    right := fun label =>
      if label = 0 then { first := 1, second := 0 }
      else { first := 0, second := 1 }
    factorization := by
      funext row column
      fin_cases row <;> fin_cases column <;>
        simp [FourMomentum.bispinor, massiveSpinorProduct,
          WeylSpinor.component, unitMassMomentum] }

example : unitMassMomentum.energy ^ 2 - unitMassMomentum.px ^ 2 -
    unitMassMomentum.py ^ 2 - unitMassMomentum.pz ^ 2 =
      unitMassMomentum.mass ^ 2 := by
  exact unitMassMomentum.mass_shell

example : unitMassMomentum.bispinor =
    massiveSpinorProduct unitMassFactorization.left unitMassFactorization.right := by
  exact unitMassFactorization.factorization

def toyCalibration : Calibration :=
  { expected := 10
    measured := 10.1
    tolerance := 0.1
    tolerance_nonneg := by norm_num
    errorBound := by norm_num }

example : |toyCalibration.measured - toyCalibration.expected| ≤ toyCalibration.tolerance := by
  exact toyCalibration.error_le_tolerance

def toyBudget : ThermalBudget :=
  { peakTemperature := 400
    limitTemperature := 450
    safe := by norm_num }

example : toyBudget.peakTemperature ≤ toyBudget.limitTemperature := by
  exact toyBudget.peak_le_limit

end SignalsTests