import Mathlib.Tactic
import SignalsPending

namespace SignalsPendingTests

open Signals.Applications
open Signals.Acoustics
open Signals.Geometry
open Signals.IQ
open Signals.Antennas
open Signals.Maxwell
open Signals.NonDestructive
open Signals.OAM
open Signals.Pending
open Signals.Proca
open Signals.Propagation
open Signals.Units

def pendingCalculus : VectorCalculus where
  divergence := fun _ => 0
  curl := fun _ => 0
  vectorTimeDerivative := fun _ => 0
  scalarTimeDerivative := fun _ => 0
  divergence_curl := by intro; rfl
  divergence_add := by intro left right; norm_num
  divergence_timeDerivative := by intro; rfl

noncomputable def toyModel : Model :=
  { mass := 3
    mass_pos := by norm_num
    coupling := 1
    medium := { refractiveIndex := 1, refractiveIndex_pos := by norm_num }
    boundary :=
      { reflectionMagnitude := 1
        reflectionMagnitude_nonneg := by norm_num
        reflectionMagnitude_le_one := by norm_num } }

noncomputable def toyCurrent : FourCurrent :=
  { chargeDensity := 0
    currentX := 0
    currentY := 0
    currentZ := 0
    continuityResidual := 0
    conserved := by norm_num }

noncomputable def toyConstitutive : ConstitutiveRelation :=
  { relativePermittivity := 2
    relativePermittivity_pos := by norm_num
    relativePermeability := 1
    relativePermeability_pos := by norm_num
    conductivity := 0
    conductivity_nonneg := by norm_num
    lossTangent := 0
    lossTangent_nonneg := by norm_num }

noncomputable def toyField : DrivenField toyModel :=
  { fourDivergence := 0
    coupling :=
      { strength := 1
        strength_nonneg := by norm_num
        constitutive := toyConstitutive
        source := toyCurrent }
    fieldEquation := by norm_num [toyModel, toyCurrent] }

noncomputable def toyMode : Mode toyModel :=
  { frequency := 5
    frequency_pos := by norm_num
    transverseWaveNumber := 0
    longitudinalWaveNumber := 4
    dispersion := by norm_num [toyModel] }

example : toyField.fourDivergence = 0 := by
  exact toyField.lorenz_condition

noncomputable def toyPendingLink : LinkBudget :=
  { mode := PropagationMode.throughSpaceBallistic
    sourcePower := 1
    sourcePower_nonnegative := by norm_num
    distance := 1
    distance_nonnegative := by norm_num
    coupling :=
      { regime := CouplingRegime.farField
        antennaEfficiency := { value := 1, nonnegative := by norm_num, le_one := by norm_num }
        impedanceMatch := { value := 1, nonnegative := by norm_num, le_one := by norm_num }
        apertureCoupling := { value := 1, nonnegative := by norm_num, le_one := by norm_num }
        alignment := { value := 1, nonnegative := by norm_num, le_one := by norm_num }
        radiativeCoupling := { value := 1, nonnegative := by norm_num, le_one := by norm_num }
        reactiveFraction := { value := 0, nonnegative := by norm_num, le_one := by norm_num }
        energyPartition := by norm_num }
    medium :=
      { attenuationPerLength := 0
        attenuation_nonneg := by norm_num
        bulkTransmission := { value := 1, nonnegative := by norm_num, le_one := by norm_num } }
    interface :=
      { reflectionPower := 0
        transmissionPower := 1
        absorptionPower := 0
        reflection_nonnegative := by norm_num
        transmission_nonnegative := by norm_num
        absorption_nonnegative := by norm_num
        power_conservation := by norm_num } }

noncomputable def toyChannel : ProcaChannel :=
  { domain := MediumDomain.throughSpace
    model := toyModel
    field := toyField
    mode := toyMode
    link := toyPendingLink
    longitudinalCoupling := 1
    longitudinalCoupling_nonzero := by norm_num
    longitudinalModeAssumed := by norm_num [toyMode] }

example : toyChannel.longitudinalCoupling * toyChannel.mode.longitudinalWaveNumber ≠ 0 := by
  exact toyChannel.longitudinalModeAssumed

def earthLfVector : RadioTestVector :=
  { band := RadioBand.lf
    frequencyHz := 100000
    frequency_positive := by norm_num
    inBand := by norm_num [RadioBand.inRange, RadioBand.lowerHz, RadioBand.upperHz] }

def marsVlfVector : RadioTestVector :=
  { band := RadioBand.vlf
    frequencyHz := 10000
    frequency_positive := by norm_num
    inBand := by norm_num [RadioBand.inRange, RadioBand.lowerHz, RadioBand.upperHz] }

def earthRouteVector : ThroughBodyRadioTestVector :=
  { target := BodyTarget.earth
    domain := MediumDomain.throughBody BodyTarget.earth
    frequency := earthLfVector
    domainLaw := by rfl }

def marsRouteVector : ThroughBodyRadioTestVector :=
  { target := BodyTarget.planet "Mars"
    domain := MediumDomain.throughBody (BodyTarget.planet "Mars")
    frequency := marsVlfVector
    domainLaw := by rfl }

def asteroidRouteVector : ThroughBodyRadioTestVector :=
  { target := BodyTarget.asteroid "Ceres"
    domain := MediumDomain.throughBody (BodyTarget.asteroid "Ceres")
    frequency := earthLfVector
    domainLaw := by rfl }

def namedBodyRouteVector : ThroughBodyRadioTestVector :=
  { target := BodyTarget.named "TestBody"
    domain := MediumDomain.throughBody (BodyTarget.named "TestBody")
    frequency := marsVlfVector
    domainLaw := by rfl }

example : earthRouteVector.frequency.band = RadioBand.lf := by
  rfl

example : marsRouteVector.frequency.band = RadioBand.vlf := by
  rfl

example : asteroidRouteVector.target.kind = BodyKind.asteroid := by
  rfl

example : namedBodyRouteVector.domain =
    MediumDomain.throughBody (BodyTarget.named "TestBody") := by
  exact namedBodyRouteVector.domain_eq_target

noncomputable def toyIGPE : IGPEPoint :=
  { hbar := 1
    hbar_pos := by norm_num
    effectiveMass := 1
    effectiveMass_pos := by norm_num
    potential := 0
    coupling := 0
    density := 0
    density_nonnegative := by norm_num
    wavefunction := 1
    timeDerivative := 0
    laplacian := 0
    balance := by norm_num }

example :
    Complex.I * toyIGPE.hbar * toyIGPE.timeDerivative =
      (-(toyIGPE.hbar ^ 2 / (2 * toyIGPE.effectiveMass))) * toyIGPE.laplacian +
        (toyIGPE.potential + toyIGPE.coupling * toyIGPE.density) * toyIGPE.wavefunction := by
  exact toyIGPE.balance_holds

example : toyIGPE.formulation = GPEVariant.interactive := by
  rfl

noncomputable def toyInverseGPE : InverseGPEPoint :=
  { hbar := 1
    hbar_pos := by norm_num
    effectiveMass := 1
    effectiveMass_pos := by norm_num
    coupling := 0
    density := 0
    density_nonnegative := by norm_num
    wavefunction := 1
    wavefunction_nonzero := by norm_num
    timeDerivative := 0
    laplacian := 0
    potential := 0
    inverseLaw := by norm_num }

example : toyInverseGPE.formulation = GPEVariant.inverse := by
  rfl

example : toyInverseGPE.potential =
    Complex.I * toyInverseGPE.hbar * toyInverseGPE.timeDerivative /
        toyInverseGPE.wavefunction +
      ((toyInverseGPE.hbar ^ 2 /
          (2 * toyInverseGPE.effectiveMass) : ℝ) : ℂ) *
        toyInverseGPE.laplacian / toyInverseGPE.wavefunction -
      ((toyInverseGPE.coupling * toyInverseGPE.density : ℝ) : ℂ) := by
  exact toyInverseGPE.potential_reconstruction

noncomputable def toyInhomogeneousGPE : InhomogeneousGPEPoint :=
  { hbar := 1
    hbar_pos := by norm_num
    effectiveMass := 1
    effectiveMass_pos := by norm_num
    potential := 0
    coupling := 0
    density := 0
    density_nonnegative := by norm_num
    wavefunction := 1
    timeDerivative := -Complex.I
    laplacian := 0
    source := 1
    balance := by norm_num }

example : toyInhomogeneousGPE.formulation = GPEVariant.inhomogeneous := by
  rfl

example :
    Complex.I * toyInhomogeneousGPE.hbar * toyInhomogeneousGPE.timeDerivative =
      (-(toyInhomogeneousGPE.hbar ^ 2 /
          (2 * toyInhomogeneousGPE.effectiveMass))) *
          toyInhomogeneousGPE.laplacian +
        (toyInhomogeneousGPE.potential +
          toyInhomogeneousGPE.coupling * toyInhomogeneousGPE.density) *
          toyInhomogeneousGPE.wavefunction +
        toyInhomogeneousGPE.source := by
  exact toyInhomogeneousGPE.balance_holds

def toyThermalCovariance : Matrix (Fin 3) (Fin 3) ℝ :=
  fun row column => if row = column then 1 else 0

def toyNitrogen : AtmosphericSpecies :=
  { name := "N2"
    particleMass := 28
    particleMass_pos := by norm_num
    partialDensity := 7
    partialDensity_nonnegative := by norm_num
    temperature := 300
    temperature_pos := by norm_num }

def toyOxygen : AtmosphericSpecies :=
  { name := "O2"
    particleMass := 32
    particleMass_pos := by norm_num
    partialDensity := 2
    partialDensity_nonnegative := by norm_num
    temperature := 300
    temperature_pos := by norm_num }

noncomputable def toyNitrogenSplat : TensorGaussianSplat :=
  { species := toyNitrogen
    meanVelocity := fun _ => 0
    covariance := toyThermalCovariance
    covariance_symmetric := by
      intro row column
      by_cases equal : row = column
      · simp [equal]
      · have notEqual : column ≠ row := by
          intro reverse
          exact equal reverse.symm
        simp [toyThermalCovariance, equal, notEqual]
    covariance_diagonal_nonnegative := by
      intro axis
      simp [toyThermalCovariance]
    boltzmannScale := 28 / 300
    boltzmannScale_pos := by norm_num
    thermalVariance := 1
    thermalVariance_nonnegative := by norm_num
    thermalVarianceLaw := by norm_num [toyNitrogen]
    covarianceDiagonalLaw := by
      intro axis
      simp [toyThermalCovariance] }

noncomputable def toyOxygenSplat : TensorGaussianSplat :=
  { species := toyOxygen
    meanVelocity := fun _ => 0
    covariance := toyThermalCovariance
    covariance_symmetric := by
      intro row column
      by_cases equal : row = column
      · simp [equal]
      · have notEqual : column ≠ row := by
          intro reverse
          exact equal reverse.symm
        simp [toyThermalCovariance, equal, notEqual]
    covariance_diagonal_nonnegative := by
      intro axis
      simp [toyThermalCovariance]
    boltzmannScale := 32 / 300
    boltzmannScale_pos := by norm_num
    thermalVariance := 1
    thermalVariance_nonnegative := by norm_num
    thermalVarianceLaw := by norm_num [toyOxygen]
    covarianceDiagonalLaw := by
      intro axis
      simp [toyThermalCovariance] }

noncomputable def toyAtmosphericMixture : AtmosphericMixture 2 :=
  { component := fun index =>
      if index = 0 then toyNitrogenSplat else toyOxygenSplat }

example : (toyAtmosphericMixture.component 0).species.name = "N2" := by
  rfl

example : (toyAtmosphericMixture.component 1).species.name = "O2" := by
  rfl

example : toyAtmosphericMixture.totalPartialDensity = 9 := by
  norm_num [AtmosphericMixture.totalPartialDensity, toyAtmosphericMixture,
    toyNitrogenSplat, toyOxygenSplat, toyNitrogen, toyOxygen,
    Fin.sum_univ_succ]

noncomputable def toyAtmosphericScavenging : AtmosphericScavenging 2 :=
  { mixture := toyAtmosphericMixture
    gateWidth := 1
    gateWidth_pos := by norm_num
    acceptance := fun index => if index = 0 then 1 else 1 / 2
    acceptance_nonnegative := by
      intro index
      fin_cases index <;> norm_num
    acceptance_le_one := by
      intro index
      fin_cases index <;> norm_num
    normalizedThroughput := 8
    normalizedThroughputLaw := by
      norm_num [toyAtmosphericMixture, toyNitrogenSplat, toyOxygenSplat,
        toyNitrogen, toyOxygen, Fin.sum_univ_succ] }

example : toyAtmosphericScavenging.normalizedThroughput = 8 := by
  rfl

example : 0 ≤ toyAtmosphericScavenging.normalizedThroughput := by
  exact toyAtmosphericScavenging.normalizedThroughput_nonnegative

noncomputable def toyDimensionedScavenging : DimensionedScavengingFlow 2 :=
  { normalizedModel := toyAtmosphericScavenging
    flowScale := { kilogramsPerSecond := 2 }
    flowScale_nonnegative := by norm_num
    massFlow := { kilogramsPerSecond := 16 }
    massFlowLaw := by norm_num [toyAtmosphericScavenging] }

example : toyDimensionedScavenging.massFlow.kilogramsPerSecond = 16 := by
  rfl

example : 0 ≤ toyDimensionedScavenging.massFlow.kilogramsPerSecond := by
  exact toyDimensionedScavenging.massFlow_nonnegative

def toyClassicalControlVolume : ClassicalControlVolume :=
  { inletMassFlow := { kilogramsPerSecond := 2 }
    inletMassFlow_nonnegative := by norm_num
    outletMassFlow := { kilogramsPerSecond := 2 }
    outletMassFlow_nonnegative := by norm_num
    massStorageRate := { kilogramsPerSecond := 0 }
    massBalance := by norm_num
    inletSpeed := { metersPerSecond := 10 }
    inletSpeed_nonnegative := by norm_num
    outletSpeed := { metersPerSecond := 20 }
    outletSpeed_nonnegative := by norm_num
    inletMomentumFlux := { newtons := 20 }
    inletMomentumFluxLaw := by norm_num
    outletMomentumFlux := { newtons := 40 }
    outletMomentumFluxLaw := by norm_num
    momentumStorageRate := { newtons := 0 }
    externalAxialForce := { newtons := 20 }
    momentumBalance := by norm_num
    electricalInputPower := { watts := 5 }
    electricalInputPower_nonnegative := by norm_num
    aerodynamicHeatPower := { watts := 7 }
    aerodynamicHeatPower_nonnegative := by norm_num
    usefulOutputPower := { watts := 10 }
    usefulOutputPower_nonnegative := by norm_num
    lossPower := { watts := 2 }
    lossPower_nonnegative := by norm_num
    energyBalance := by norm_num }

example : toyClassicalControlVolume.inletMassFlow.kilogramsPerSecond =
    toyClassicalControlVolume.outletMassFlow.kilogramsPerSecond := by
  exact toyClassicalControlVolume.steady_mass_flow (by
    norm_num [toyClassicalControlVolume])

example : toyClassicalControlVolume.externalAxialForce.newtons = 20 := by
  norm_num [ClassicalControlVolume.external_force_eq_momentum_change,
    toyClassicalControlVolume]

example : toyClassicalControlVolume.usefulOutputPower.watts ≤
    toyClassicalControlVolume.electricalInputPower.watts +
      toyClassicalControlVolume.aerodynamicHeatPower.watts := by
  exact toyClassicalControlVolume.useful_output_le_input

def toyFlowBoundaryCondition : FlowBoundaryCondition :=
  { pressure := { pascals := 101325 }
    pressure_nonnegative := by norm_num
    heatFlux := { wattsPerSquareMeter := 100 }
    heatFlux_nonnegative := by norm_num
    velocity := fun _ => { metersPerSecond := 3 } }

def toyFlowBoundaryObservation : FlowBoundaryObservation :=
  { measured := toyFlowBoundaryCondition
    predicted := toyFlowBoundaryCondition
    pressureTolerance := 1
    pressureTolerance_nonnegative := by norm_num
    pressureResidual := 0
    pressureResidualLaw := by norm_num [toyFlowBoundaryCondition]
    heatFluxTolerance := 1
    heatFluxTolerance_nonnegative := by norm_num
    heatFluxResidual := 0
    heatFluxResidualLaw := by norm_num [toyFlowBoundaryCondition]
    velocityTolerance := 1
    velocityTolerance_nonnegative := by norm_num
    velocityResidual := fun _ => 0
    velocityResidualLaw := by
      intro axis
      norm_num [toyFlowBoundaryCondition]
    consistent := by
      constructor
      · norm_num
      constructor
      · norm_num
      · intro axis
        norm_num }

example : |toyFlowBoundaryObservation.pressureResidual| ≤
    toyFlowBoundaryObservation.pressureTolerance := by
  exact toyFlowBoundaryObservation.pressure_within_tolerance

example : |toyFlowBoundaryObservation.heatFluxResidual| ≤
    toyFlowBoundaryObservation.heatFluxTolerance := by
  exact toyFlowBoundaryObservation.heatFlux_within_tolerance

example : |toyFlowBoundaryObservation.velocityResidual 2| ≤
    toyFlowBoundaryObservation.velocityTolerance := by
  exact toyFlowBoundaryObservation.velocity_within_tolerance 2

noncomputable def toyHomogenization : PhaseSlipHomogenization 2 :=
  { input := toyAtmosphericMixture
    targetVelocity := fun _ => 1
    outputVelocity := fun _ => fun _ => 1
    outputCovariance := fun _ => 0
    velocityLock := by
      intro index
      rfl
    covarianceCollapse := by
      intro index
      rfl }

example : toyHomogenization.outputVelocity 0 = toyHomogenization.targetVelocity := by
  exact toyHomogenization.common_velocity 0

example : toyHomogenization.outputCovariance 1 = 0 := by
  exact toyHomogenization.zero_output_covariance 1

def toySquarePanel : SquarePanel :=
  { width := 1
    width_pos := by norm_num
    height := 1
    height_pos := by norm_num
    tileRows := 2
    tileRows_positive := by norm_num
    tileColumns := 2
    tileColumns_positive := by norm_num }

noncomputable def toySquarePanelPlume : SquarePanelPlume :=
  { panel := toySquarePanel
    unshapedEdgeShear := 10
    unshapedEdgeShear_nonnegative := by norm_num
    apodization := 3 / 5
    apodization_nonnegative := by norm_num
    apodization_le_one := by norm_num
    residualEdgeShear := 4
    residualEdgeShearLaw := by norm_num }

example : toySquarePanelPlume.edgeShearIndicator = 4 := by
  rfl

example : toySquarePanelPlume.edgeShearIndicator ≤
    toySquarePanelPlume.unshapedEdgeShear := by
  exact toySquarePanelPlume.edgeShearIndicator_bounds.2

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
    pressureAmplitude := 1
    pressureAmplitude_nonnegative := by norm_num
    medium := toyAcousticMedium }

noncomputable def toyUltrasonicTransfer : Signals.Acoustics.UltrasonicTransfer :=
  { wave := toyAcousticWave
    ultrasonicFrequency := by norm_num [toyAcousticWave]
    link := toyPendingLink
    apertureArea := 1
    apertureArea_pos := by norm_num
    transmitterEfficiency := { value := 1, nonnegative := by norm_num, le_one := by norm_num }
    receiverEfficiency := { value := 1, nonnegative := by norm_num, le_one := by norm_num }
    sourcePowerLaw := by
      norm_num [toyPendingLink, toyAcousticWave, toyAcousticMedium,
        Signals.Acoustics.Wave.intensity, Signals.Acoustics.Medium.impedance] }

noncomputable def toyAcousticMeasurement : Signals.Acoustics.TransferMeasurement :=
  { predictedPower := 1
    observedPower := 6 / 5
    tolerance := 1 / 10
    tolerance_nonnegative := by norm_num
    residual := 1 / 5
    residualLaw := by norm_num }

noncomputable def toyAcousticEvidence : AcousticFractureEvidence :=
  { transfer := toyUltrasonicTransfer
    measurement := toyAcousticMeasurement
    predictedPowerLaw := by
      norm_num [toyUltrasonicTransfer, toyPendingLink,
        Signals.Acoustics.UltrasonicTransfer.receivedPower,
        LinkBudget.receivedPower, LinkBudget.transferFactor,
        CouplingFactors.total, LinkBudget.attenuationFactor,
        toyAcousticMeasurement]
    outsideClassicalTolerance := by
      norm_num [Signals.Acoustics.TransferMeasurement.consistent,
        toyAcousticMeasurement] }

example : toyUltrasonicTransfer.receivedPower ≤ toyUltrasonicTransfer.incidentPower := by
  exact toyUltrasonicTransfer.receivedPower_le_incidentPower

example : toyAcousticEvidence.supportsFractureHypothesis := by
  exact toyAcousticEvidence.outsideClassicalTolerance

noncomputable def toySQGMedium : SQGMedium :=
  { baseline :=
      { permittivity := 2
        permittivity_pos := by norm_num
        permeability := 3
        permeability_pos := by norm_num }
    metricCorrection := 0
    effectivePermittivity := 2
    effectivePermittivity_pos := by norm_num
    effectivePermeability := 3
    effectivePermeability_pos := by norm_num
    permittivityLaw := by norm_num
    permeabilityLaw := by norm_num
    dilatantPressure := 0
    dilatantPressure_nonnegative := by norm_num }

noncomputable def toySQGMaxwell : SQGMaxwellSystem pendingCalculus :=
  { medium := toySQGMedium
    vacuumState := toyIGPE
    electricField := 0
    displacementField := 0
    magneticField := 0
    magneticIntensity := 0
    rho := 0
    current := 0
    sqgCurrent := 0
    constitutiveElectric := by
      ext index
      simp
    constitutiveMagnetic := by
      ext index
      simp
    gaussElectric := by rfl
    gaussMagnetic := by rfl
    faraday := by
      ext index
      simp [pendingCalculus]
    ampere := by
      ext index
      simp [pendingCalculus] }

example : toySQGMaxwell.medium.effectivePermittivity =
    toySQGMaxwell.medium.baseline.permittivity *
      (1 + toySQGMaxwell.medium.metricCorrection) := by
  exact toySQGMaxwell.medium.permittivityLaw

example : pendingCalculus.scalarTimeDerivative toySQGMaxwell.rho +
    pendingCalculus.divergence (toySQGMaxwell.current + toySQGMaxwell.sqgCurrent) = 0 := by
  exact toySQGMaxwell.total_charge_continuity

example : pendingCalculus.curl toySQGMaxwell.magneticIntensity =
    toySQGMaxwell.current +
      pendingCalculus.vectorTimeDerivative toySQGMaxwell.displacementField := by
  exact toySQGMaxwell.toMaxwellSystem_ampere (by
    funext index
    rfl)

noncomputable def toyMetric : EffectiveAcousticMetric :=
  { density := 1
    density_nonnegative := by norm_num
    soundSpeed := 1
    soundSpeed_pos := by norm_num
    flowSpeed := 2
    gTT := 3
    gTT_law := by norm_num }

example : toyMetric.ergoregion := by
  norm_num [EffectiveAcousticMetric.ergoregion, toyMetric]

noncomputable def toySlip : PhaseSlip :=
  { winding := 0
    phaseJump := 0
    windingLaw := by norm_num }

example : toySlip.phaseJump = 0 := by
  exact toySlip.zero_winding_phase rfl

noncomputable def toyProfile : AmplituhedronProfile :=
  { dimension := 4
    dimension_positive := by norm_num
    phaseWeight := 1 / 2
    phaseWeight_nonnegative := by norm_num
    phaseWeight_le_one := by norm_num }

noncomputable def toyWave : FractureWave :=
  { model := toyModel
    field := toyField
    state := FractureState.generated
    profile := toyProfile
    frequency := 400
    frequency_positive := by norm_num
    amplitude := 2
    amplitude_nonnegative := by norm_num }

example : toyWave.effectiveAmplitude = 1 := by
  norm_num [FractureWave.effectiveAmplitude, toyWave, toyProfile]

noncomputable def toyAntiProfile : AntiAmplituhedronProfile :=
  { phaseGradient := 1
    phaseGradient_nonnegative := by norm_num
    divergence := -2
    divergent := by norm_num
    profileWeight := 3
    profileWeight_nonnegative := by norm_num
    pressureExpansion := 6
    expansionLaw := by norm_num }

noncomputable def toyExpansion : SQGVacuumExpansion :=
  { baselineCoupling := 1
    effectiveCoupling := -1
    negativeCoupling := by norm_num
    vacuumDensity := 2
    vacuumDensity_nonnegative := by norm_num
    expansionProfile := toyAntiProfile
    pressure := 12
    pressureLaw := by norm_num [toyAntiProfile] }

example : 0 ≤ toyExpansion.pressure := by
  exact toyExpansion.pressure_nonnegative

noncomputable def toyBarrier : WKBBarrier :=
  { properDistanceFactor := 1
    properDistanceFactor_nonnegative := by norm_num
    effectiveBarrier := 4
    effectiveBarrier_nonnegative := by norm_num
    exponent := 2
    exponent_nonnegative := by norm_num
    exponentLaw := by norm_num
    tunnelingProbability := Real.exp (-4)
    probabilityLaw := by norm_num }

example : 0 ≤ toyBarrier.tunnelingProbability ∧ toyBarrier.tunnelingProbability ≤ 1 := by
  exact toyBarrier.probability_bounds

noncomputable def toyFusion : FusionReaction :=
  { reactionProbability := 1
    probability_nonnegative := by norm_num
    probability_le_one := by norm_num
    energyPerReaction := 18
    energyPerReaction_nonnegative := by norm_num
    reactionRate := 2
    reactionRate_nonnegative := by norm_num
    inputPower := 10
    inputPower_nonnegative := by norm_num
    outputPower := 36
    outputPower_nonnegative := by norm_num
    outputLaw := by norm_num }

noncomputable def toyDeterministicFusion : DeterministicFusionClaim :=
  { reaction := toyFusion
    probabilityOne := by norm_num [toyFusion] }

example : toyDeterministicFusion.reaction.outputPower =
    toyDeterministicFusion.reaction.energyPerReaction *
      toyDeterministicFusion.reaction.reactionRate := by
  exact toyDeterministicFusion.outputLaw

noncomputable def toyLedger : EnergyLedger :=
  { controlPower := 1
    controlPower_nonnegative := by norm_num
    fuelPower := 2
    fuelPower_nonnegative := by norm_num
    spacetimePower := 3
    spacetimePower_nonnegative := by norm_num
    outputPower := 5
    outputPower_nonnegative := by norm_num
    lossPower := 1
    lossPower_nonnegative := by norm_num
    balance := by norm_num }

example : toyLedger.outputPower ≤
    toyLedger.controlPower + toyLedger.fuelPower + toyLedger.spacetimePower := by
  exact toyLedger.output_le_declared_input

noncomputable def toyExtractionClaim : SpacetimeExtractionClaim :=
  { ledger := toyLedger
    overControlAndFuel := by norm_num [toyLedger] }

example : 0 < toyExtractionClaim.ledger.spacetimePower := by
  exact toyExtractionClaim.spacetimePower_positive

def toyAmplituhedronSource : GrassmannianMatrix 1 1 :=
  { mat := fun _ _ => 1 }

def toyAmplituhedronExternalData : Matrix (Fin 1) (Fin 1) ℝ :=
  fun _ _ => 3

def toyAmplituhedronMap : AmplituhedronMap 1 1 1 :=
  { source := toyAmplituhedronSource
    externalData := toyAmplituhedronExternalData
    image := fun _ _ => 3
    imageLaw := by
      funext row column
      change (3 : ℝ) = ∑ index : Fin 1, 1 * 3
      simp }

def toyAmplituhedronBoundary : OrderedColumns 1 1 :=
  { index := fun _ => 0
    strictlyIncreasing := by
      intro left right greater
      omega }

def toyLogarithmicChart : LogarithmicChart 1 1 1 :=
  { map := toyAmplituhedronMap
    source_positive := by
      intro columns
      have index_zero : columns.index 0 = 0 := Fin.eq_zero (columns.index 0)
      change 0 < (toyAmplituhedronSource.mat.submatrix id columns.index).det
      rw [Matrix.det_fin_one]
      change 0 < toyAmplituhedronSource.mat 0 (columns.index 0)
      rw [index_zero]
      norm_num [toyAmplituhedronSource, Matrix.submatrix]
    boundary := toyAmplituhedronBoundary
    boundaryCoordinate := 1
    boundaryCoordinateLaw := by
      change (1 : ℝ) =
        (toyAmplituhedronSource.mat.submatrix id toyAmplituhedronBoundary.index).det
      rw [Matrix.det_fin_one]
      norm_num [toyAmplituhedronSource, toyAmplituhedronBoundary,
        Matrix.submatrix]
    boundaryCoordinate_nonzero := by norm_num
    residue := 7 }

def toyAmplituhedronHypothesis : AmplituhedronScatteringHypothesis 1 1 1 :=
  { chart := toyLogarithmicChart
    measuredAmplitude := 7
    measuredAmplitudeLaw := by
      norm_num [LogarithmicChart.weight, toyLogarithmicChart] }

example : toyAmplituhedronMap.image =
    toyAmplituhedronMap.source.mat * toyAmplituhedronMap.externalData := by
  exact toyAmplituhedronMap.image_eq

example : toyLogarithmicChart.weight *
    toyLogarithmicChart.boundaryCoordinate = toyLogarithmicChart.residue := by
  exact toyLogarithmicChart.weight_mul_boundary

example : toyAmplituhedronHypothesis.measuredAmplitude = 7 := by
  rfl

noncomputable def toyQudit : Qudit 1 :=
  { amplitudes := fun _ => 1
    normalized := by norm_num [Fin.sum_univ_succ] }

noncomputable def toyQNDParity : QuantumNonDemolitionParity 1 :=
  { readout :=
      { signalBefore := toyQudit
        signalAfter := toyQudit
        signalPreserved := by rfl
        signalEnergyBefore := { joules := 1 }
        signalEnergyAfter := { joules := 1 }
        signalEnergyPreserved := by rfl
        absorbedSignalEnergy := { joules := 0 }
        absorbedSignalEnergy_nonnegative := by norm_num
        absorbedSignalEnergy_zero := by norm_num
        probePhaseBefore := 0
        probePhaseAfter := 2
        probePhaseShift := 2
        coupling := 1
        signalObservable := 2
        probePhaseLaw := by norm_num
        probePhaseShiftLaw := by norm_num
        absorbedProbeEnergy := { joules := 0 }
        absorbedProbeEnergy_nonnegative := by norm_num
        absorbedProbeEnergy_zero := by norm_num }
    detectorLoss := { value := 0, nonnegative := by norm_num, le_one := by norm_num }
    parityBefore := false
    parityAfter := false
    parityPreserved := by rfl
    measuredParity := false
    parityReadoutLaw := by rfl
    repeatedParity := false
    repeatedParityLaw := by rfl
    parityResidual := 0
    parityResidual_nonnegative := by norm_num
    parityResidualBound := 1
    parityResidualBound_nonnegative := by norm_num
    parityResidualWithinBound := by norm_num
    signalDisturbance := 0
    signalDisturbance_nonnegative := by norm_num
    disturbanceBound := 1
    disturbanceBound_nonnegative := by norm_num
    disturbanceWithinBound := by norm_num
    absorptionMeasurement := { joules := 0 }
    absorptionMeasurement_nonnegative := by norm_num
    absorptionBound := { joules := 1 }
    absorptionBound_nonnegative := by norm_num
    absorptionWithinBound := by norm_num }

example : toyQNDParity.readout.signalAfter = toyQNDParity.readout.signalBefore := by
  exact toyQNDParity.signal_preserved

example : toyQNDParity.parityAfter = toyQNDParity.parityBefore := by
  exact toyQNDParity.parity_preserved

example : toyQNDParity.measuredParity = toyQNDParity.parityAfter := by
  exact toyQNDParity.measured_parity_eq

example : toyQNDParity.repeatedParity = toyQNDParity.measuredParity := by
  exact toyQNDParity.repeated_parity_eq

example : toyQNDParity.parityResidual ≤ toyQNDParity.parityResidualBound := by
  exact toyQNDParity.parity_residual_within_bound

example : toyQNDParity.signalDisturbance ≤ toyQNDParity.disturbanceBound := by
  exact toyQNDParity.disturbance_within_bound

example : toyQNDParity.absorptionMeasurement.joules ≤
    toyQNDParity.absorptionBound.joules := by
  exact toyQNDParity.absorption_within_bound

noncomputable def toyQuantumQuadratureAssumption : QuantumQuadratureAssumption :=
  { hbar := 1
    hbar_pos := by norm_num
    amplitudeVariance := 1
    amplitudeVariance_nonnegative := by norm_num
    phaseVariance := 1
    phaseVariance_nonnegative := by norm_num
    commutatorMagnitude := 1 / 2
    commutatorLaw := by norm_num
    uncertaintyProduct := 1
    uncertaintyBound := 1 / 4
    uncertaintyBoundLaw := by norm_num
    uncertaintyWithinBound := by norm_num
    squeezingParameter := 0
    squeezingParameter_nonnegative := by norm_num }

noncomputable def toyTwoModeSqueezedVacuum : TwoModeSqueezedVacuum :=
  { squeezingParameter := 0
    squeezingParameter_nonnegative := by norm_num
    xDifferenceVariance := 2
    pSumVariance := 2
    xDifferenceVarianceLaw := by norm_num
    pSumVarianceLaw := by norm_num }

noncomputable def toyCVBellStateMeasurement : CVBellStateMeasurement :=
  { inputX := 3
    resourceX := 1
    inputP := 1
    resourceP := 1
    measuredX := (3 - 1) / Real.sqrt 2
    measuredP := (1 + 1) / Real.sqrt 2
    measuredXLaw := by rfl
    measuredPLaw := by rfl }

def toyCVFeedForward : CVFeedForward :=
  { gain := 2
    measuredX := 1
    measuredP := -1
    displacementX := 2
    displacementP := -2
    displacementXLaw := by norm_num
    displacementPLaw := by norm_num }

noncomputable def toyCVTeleportationBookkeeping : CVTeleportationBookkeeping :=
  { bellMeasurement := toyCVBellStateMeasurement
    feedForward :=
      { toyCVFeedForward with
        measuredX := toyCVBellStateMeasurement.measuredX
        measuredP := toyCVBellStateMeasurement.measuredP
        displacementX := 2 * toyCVBellStateMeasurement.measuredX
        displacementP := 2 * toyCVBellStateMeasurement.measuredP
        displacementXLaw := by rfl
        displacementPLaw := by rfl }
    resourceLoss := { value := 0, nonnegative := by norm_num, le_one := by norm_num }
    finiteSqueezingNoise := 0
    finiteSqueezingNoise_nonnegative := by norm_num
    feedForwardMeasurementLaw := by constructor <;> rfl }

example : toyQuantumQuadratureAssumption.commutatorMagnitude =
    toyQuantumQuadratureAssumption.hbar / 2 := by
  exact toyQuantumQuadratureAssumption.commutator_holds

example : toyQuantumQuadratureAssumption.uncertaintyBound ≤
    toyQuantumQuadratureAssumption.uncertaintyProduct := by
  exact toyQuantumQuadratureAssumption.uncertaintyWithinBound

example : toyTwoModeSqueezedVacuum.xDifferenceVariance = 2 := by
  norm_num [TwoModeSqueezedVacuum.x_difference_variance_holds,
    toyTwoModeSqueezedVacuum]

example : toyCVBellStateMeasurement.measuredX =
    (toyCVBellStateMeasurement.inputX - toyCVBellStateMeasurement.resourceX) /
      Real.sqrt 2 := by
  exact toyCVBellStateMeasurement.measured_x_holds

example : toyCVTeleportationBookkeeping.feedForward.displacementP =
    2 * toyCVTeleportationBookkeeping.feedForward.measuredP := by
  exact toyCVTeleportationBookkeeping.feedForward.displacement_p_holds

def toyKerrInteraction : KerrInteraction ℝ :=
  { signalBefore := 1
    signalAfter := 1
    signalPreserved := by rfl
    couplingStrength := 2
    couplingStrength_nonnegative := by norm_num
    interactionLength := { meters := 1 }
    interactionLength_nonnegative := by norm_num
    signalObservable := 3
    probePhaseShift := 6
    probePhaseShiftLaw := by norm_num }

example : toyKerrInteraction.probePhaseShift = 6 := by
  norm_num [KerrInteraction.probe_phase_shift_holds, toyKerrInteraction]

def toyHomodyneHardwareReadiness : HomodyneHardwareReadiness :=
  { insertionLoss := 0
    insertionLoss_nonnegative := by norm_num
    beamSplitterImbalance := 0
    beamSplitterImbalance_nonnegative := by norm_num
    detectorBandwidth := { hz := 1 }
    detectorBandwidth_pos := by norm_num
    thermalLoad := { watts := 1 }
    thermalLoad_nonnegative := by norm_num
    materialResponse := 1
    materialResponse_nonnegative := by norm_num
    modeOverlap := { value := 1, nonnegative := by norm_num, le_one := by norm_num }
    calibrationReady := true }

example : toyHomodyneHardwareReadiness.insertionLoss = 0 := by
  rfl

noncomputable def toyPendingLigninVitrimer : LigninVitrimerDielectric :=
  { relativePermittivity := 2
    relativePermittivity_pos := by norm_num
    lossTangent := 0
    lossTangent_nonnegative := by norm_num
    tuningRange := 1
    tuningRange_nonnegative := by norm_num
    moistureSensitivity :=
      { value := 0
        nonnegative := by norm_num
        le_one := by norm_num } }

noncomputable def toyPendingLightSlinger : DirectionalBroadbandAntenna :=
  { material := toyPendingLigninVitrimer
    polarizationCurrent :=
      { supportVolume := { cubicMeters := 1 }
        supportVolume_pos := by norm_num
        sourceCount := 1
        sourceCount_positive := by norm_num
        currentDensityAmplitude := { amperesPerSquareMeter := 1 }
        currentDensityAmplitude_nonnegative := by norm_num
        directionality := 1
        directionality_nonnegative := by norm_num }
    carrierFrequency := { hz := 5 }
    carrierFrequency_pos := by norm_num
    bandwidth := { hz := 1 }
    bandwidth_pos := by norm_num
    trackLength := { meters := 1 }
    trackLength_pos := by norm_num
    sweepDuration := { seconds := 1 }
    sweepDuration_pos := by norm_num
    sweepSpeed := { metersPerSecond := 1 }
    sweepSpeedLaw := by norm_num
    phasePatternSpeed := { metersPerSecond := 1 }
    phasePatternSpeed_pos := by norm_num
    groupSpeed := { metersPerSecond := 1 }
    groupSpeed_pos := by norm_num
    groupSpeed_causal := by norm_num [vacuumSpeedOfLight]
    informationSpeed := { metersPerSecond := 1 }
    informationSpeed_pos := by norm_num
    informationSpeed_causal := by norm_num [vacuumSpeedOfLight]
    inputPower := { watts := 1 }
    inputPower_nonnegative := by norm_num
    radiatedPower := { watts := 1 }
    radiatedPower_nonnegative := by norm_num
    radiationEfficiency :=
      { value := 1
        nonnegative := by norm_num
        le_one := by norm_num }
    radiatedPowerLaw := by norm_num }

noncomputable def toyCWResonator : ContinuousWaveResonator :=
  { mode := ResonatorMode.longitudinal
    resonantFrequency := { hz := 5 }
    resonantFrequency_pos := by norm_num
    driveFrequency := { hz := 5 }
    driveFrequency_pos := by norm_num
    resonanceMatch := by norm_num
    drivePower := { watts := 1 }
    drivePower_nonnegative := by norm_num
    intracavityPower := { watts := 2 }
    intracavityPower_nonnegative := by norm_num
    enhancementFactor := 2
    enhancementFactor_ge_one := by norm_num
    intracavityPowerLaw := by norm_num
    emittedPower := { watts := 1 }
    emittedPower_nonnegative := by norm_num
    dissipatedPower := { watts := 0 }
    dissipatedPower_nonnegative := by norm_num
    passivePowerBalance := by norm_num }

example : toyCWResonator.isDriven := by
  norm_num [ContinuousWaveResonator.isDriven, toyCWResonator]

example : toyCWResonator.drivePower.watts ≤
    toyCWResonator.intracavityPower.watts := by
  exact toyCWResonator.drive_power_le_intracavity

example : toyCWResonator.emittedPower.watts ≤ toyCWResonator.drivePower.watts := by
  exact toyCWResonator.emitted_power_le_drive

noncomputable def toyLightSlingerProca : LightSlingerProcaCoupling :=
  { antenna := toyPendingLightSlinger
    channel := toyChannel
    frequencyMatch := by
      change (5 : ℝ) = 5
      rfl
    longitudinalCouplingAssumed := toyChannel.longitudinalModeAssumed }

noncomputable def toyCWProcaEmission : CWProcaEmissionHypothesis :=
  { application := CWApplication.topologicalThruster
    massiveModeRequired := by rfl
    resonator := toyCWResonator
    channel := toyChannel
    cwDriven := by
      norm_num [ContinuousWaveResonator.isDriven, toyCWResonator]
    longitudinalMode := by rfl
    frequencyMatch := by
      change (5 : ℝ) = 5
      rfl
    massiveMode := toyChannel.model.mass_pos
    longitudinalCouplingAssumed := toyChannel.longitudinalModeAssumed
    emittedPower := { watts := 1 }
    emittedPower_nonnegative := by norm_num
    emittedPowerLaw := by rfl }

example : toyLightSlingerProca.antenna.carrierFrequency.hz =
    toyLightSlingerProca.channel.mode.frequency := by
  exact toyLightSlingerProca.frequency_match

example : toyLightSlingerProca.channel.longitudinalCoupling *
    toyLightSlingerProca.channel.mode.longitudinalWaveNumber ≠ 0 := by
  exact toyLightSlingerProca.longitudinal_mode_assumed

example : toyCWProcaEmission.resonator.mode = ResonatorMode.longitudinal := by
  exact toyCWProcaEmission.longitudinal_mode

example : toyCWProcaEmission.channel.model.mass > 0 := by
  exact toyCWProcaEmission.massive_mode

example : toyCWProcaEmission.emittedPower.watts =
    toyCWProcaEmission.resonator.emittedPower.watts := by
  exact toyCWProcaEmission.emitted_power_eq

end SignalsPendingTests
