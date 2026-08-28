import Mathlib.Tactic
import SignalsPending

namespace SignalsPendingTests

open Signals.Applications
open Signals.Acoustics
open Signals.Geometry
open Signals.IQ
open Signals.Antennas
open Signals.Maxwell
open Signals.MHD
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
    continuityResidual := 0 }

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
    couplingStrengthLaw := by rfl
    fieldEquation := by norm_num [toyModel, toyCurrent] }

noncomputable def toyMode : Mode toyModel :=
  { frequency := 5
    frequency_pos := by norm_num
    transverseWaveNumber := 0
    longitudinalWaveNumber := 4
    dispersion := by norm_num [toyModel] }

example : toyField.fourDivergence = 0 := by
  apply toyField.lorenz_condition
  rfl

noncomputable def toyPendingLink : LinkBudget :=
  { mode := PropagationMode.throughSpaceBallistic
    sourcePower := { watts := 1 }
    sourcePower_nonnegative := by norm_num
    distance := { meters := 1 }
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

noncomputable def toyEarthArgonSource : AtmosphericArgonSource :=
  { body := BodyTarget.earth
    argonMoleFraction := earthArgonMoleFraction
    ambientMolarFlow := { molesPerSecond := 1000 }
    ambientMolarFlow_nonnegative := by norm_num
    capturedArgonMolarFlow := { molesPerSecond := 9 }
    capturedArgonMolarFlow_nonnegative := by norm_num
    captureLaw := by norm_num [earthArgonMoleFraction] }

noncomputable def toyMarsArgonSource : AtmosphericArgonSource :=
  { body := BodyTarget.planet "Mars"
    argonMoleFraction := marsArgonMoleFraction
    ambientMolarFlow := { molesPerSecond := 1000 }
    ambientMolarFlow_nonnegative := by norm_num
    capturedArgonMolarFlow := { molesPerSecond := 19 }
    capturedArgonMolarFlow_nonnegative := by norm_num
    captureLaw := by norm_num [marsArgonMoleFraction] }

example : toyEarthArgonSource.argonMoleFraction.value = 0.009 := by
  rfl

example : toyMarsArgonSource.argonMoleFraction.value = 0.019 := by
  rfl

example : toyEarthArgonSource.capturedArgonMolarFlow.molesPerSecond = 9 := by
  norm_num [AtmosphericArgonSource.capture_flow_holds,
    toyEarthArgonSource, earthArgonMoleFraction]

example : toyMarsArgonSource.capturedArgonMolarFlow.molesPerSecond = 19 := by
  norm_num [AtmosphericArgonSource.capture_flow_holds,
    toyMarsArgonSource, marsArgonMoleFraction]

noncomputable def toyPendingArgonFlow : ConductiveArgonFlow :=
  { massFlow := { kilogramsPerSecond := 3 / 2 }
    massFlow_nonnegative := by norm_num
    velocity := { metersPerSecond := 2 }
    velocity_nonnegative := by norm_num
    ionizationFraction :=
      { value := 1 / 2, nonnegative := by norm_num, le_one := by norm_num }
    ionizationFraction_positive := by norm_num
    conductivity := { siemensPerMeter := 1 }
    conductivity_positive := by norm_num }

noncomputable def toyPendingFaradayChannel : FaradayChannel :=
  { conductivity := { siemensPerMeter := 1 }
    conductivity_nonnegative := by norm_num
    velocity := { metersPerSecond := 2 }
    velocity_nonnegative := by norm_num
    magneticFluxDensity := { tesla := 2 }
    magneticFluxDensity_nonnegative := by norm_num
    load :=
      { value := 1 / 2, nonnegative := by norm_num, le_one := by norm_num }
    channelVolume := { cubicMeters := 1 }
    channelVolume_pos := by norm_num
    powerDensity := { wattsPerCubicMeter := 4 }
    powerDensityLaw := by
      norm_num [idealFaradayPowerDensity, loadingFactor]
    extractedPower := { watts := 4 }
    extractedPower_nonnegative := by norm_num
    extractedPowerLaw := by norm_num }

def toyPendingMHDAccounting : MHDPowerAccounting :=
  { controlPower := { watts := 1 }
    controlPower_nonnegative := by norm_num
    motivePower := { watts := 3 }
    motivePower_nonnegative := by norm_num
    electricalOutputPower := { watts := 4 }
    electricalOutputPower_nonnegative := by norm_num
    lossPower := { watts := 0 }
    lossPower_nonnegative := by norm_num
    energyBalance := by norm_num }

noncomputable def toyPendingArgonMHDPlant : ArgonMHDPlant :=
  { argon := toyPendingArgonFlow
    channel := toyPendingFaradayChannel
    accounting := toyPendingMHDAccounting
    kineticInputPower := { watts := 3 }
    kineticInputPowerLaw := by
      norm_num [argonKineticPower, toyPendingArgonFlow]
    motivePowerLaw := by rfl
    outputPowerLaw := by rfl }

noncomputable def toyProcaMHDHypothesis : ProcaMHDHypothesis :=
  { channel := toyChannel
    plant := toyPendingArgonMHDPlant
    operatingCosts :=
      { pumpPower := { watts := 1 }
        pumpPower_nonnegative := by norm_num
        ionizationPower := { watts := 2 }
        ionizationPower_nonnegative := by norm_num
        fieldPower := { watts := 1 }
        fieldPower_nonnegative := by norm_num
        coolingPower := { watts := 1 }
        coolingPower_nonnegative := by norm_num }
    controlField :=
      { channel := toyChannel
        role := ProcaMHDFieldRole.coupling
        frequency := { hz := 5 }
        frequency_pos := by norm_num
        frequencyMatch := by
          change (5 : ℝ) = 5
          rfl
        controlPower := { watts := 1 }
        controlPower_nonnegative := by norm_num
        couplingGain := 3
        couplingGain_nonnegative := by norm_num
        coupledMotivePower := { watts := 3 }
        coupledMotivePower_nonnegative := by norm_num
        couplingPowerLaw := by norm_num
        couplingResidual := 0
        couplingResidual_nonnegative := by norm_num
        couplingTolerance := 1
        couplingTolerance_nonnegative := by norm_num
        couplingWithinTolerance := by norm_num }
    controlFieldChannelLaw := by rfl
    opticalControlPower := { watts := 1 }
    opticalControlPower_pos := by norm_num
    opticalControlPowerLaw := by rfl
    controlFieldPowerLaw := by rfl
    motivePower := { watts := 3 }
    motivePower_nonnegative := by norm_num
    motivePowerLaw := by rfl
    coupledMotivePowerLaw := by rfl
    reportedQFactor := 4
    reportedQFactorLaw := by
      norm_num [controlOnlyRatio, toyPendingArgonMHDPlant,
        toyPendingMHDAccounting] }

example : toyPendingArgonMHDPlant.channel.load.value = 1 / 2 := by
  rfl

example : toyPendingArgonMHDPlant.accounting.electricalOutputPower.watts =
    toyPendingArgonMHDPlant.accounting.controlPower.watts +
      toyPendingArgonMHDPlant.accounting.motivePower.watts -
        toyPendingArgonMHDPlant.accounting.lossPower.watts := by
  norm_num [toyPendingArgonMHDPlant, toyPendingMHDAccounting]

example : toyProcaMHDHypothesis.reportedQFactor = 4 := by
  rfl

example : toyProcaMHDHypothesis.controlField.coupledMotivePower.watts =
    toyProcaMHDHypothesis.controlField.couplingGain *
      toyProcaMHDHypothesis.controlField.controlPower.watts := by
  exact toyProcaMHDHypothesis.controlField.coupled_motive_power_holds

example : toyProcaMHDHypothesis.reportedQFactor > 2 ↔
    2 * toyProcaMHDHypothesis.opticalControlPower.watts <
      toyProcaMHDHypothesis.plant.accounting.electricalOutputPower.watts := by
  exact toyProcaMHDHypothesis.reported_qfactor_gt_iff 2

example : toyProcaMHDHypothesis.plant.accounting.totalInputPower.watts =
    toyProcaMHDHypothesis.opticalControlPower.watts +
      toyProcaMHDHypothesis.motivePower.watts := by
  exact toyProcaMHDHypothesis.total_input_includes_motive

example : toyProcaMHDHypothesis.plant.accounting.efficiency ≤ 1 := by
  apply toyProcaMHDHypothesis.actual_efficiency_le_one
  change (0 : ℝ) < 1 + 3
  norm_num

example : toyProcaMHDHypothesis.plant.accounting.fullEfficiency
    toyProcaMHDHypothesis.operatingCosts ≤ 1 := by
  apply toyProcaMHDHypothesis.actual_full_efficiency_le_one
  change (0 : ℝ) < (1 + 3) + (1 + 2 + 1 + 1)
  norm_num

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

def toyALSRank2 : ALSRank :=
  { rank := 2
    lowerBound := by norm_num
    upperBound := by norm_num }

def toyALSRank10 : ALSRank :=
  { rank := 10
    lowerBound := by norm_num
    upperBound := by norm_num }

example : toyALSRank2.rank = 2 := by
  rfl

example : toyALSRank10.rank = 10 := by
  rfl

def toyPreparedModulation : PreparedModulation 2 :=
  { value := fun _ => 1 }

def toyObservedHomodyneTensor : ObservedHomodyneTensor 1 1 2 :=
  { value := fun _ _ time => (time.val : ℝ) }

noncomputable def toyFiniteIQFT : FiniteIQFT 2 :=
  { dimension_positive := by norm_num
    input := fun _ => 1
    output := fun outputIndex =>
      finiteInverseQFT 2 (fun _ => 1) outputIndex
    normalizationFactor := 1 / Real.sqrt (2 : ℝ)
    normalizationLaw := by rfl
    outputLaw := by
      intro outputIndex
      rfl }

noncomputable def toyHawkingAmplituhedronMap : AmplituhedronMap 1 1 2 :=
  { source := { mat := fun _ _ => 1 }
    externalData := fun _ column => (toyFiniteIQFT.output column).re
    image := fun _ column => (toyFiniteIQFT.output column).re
    imageLaw := by
      funext row column
      change (toyFiniteIQFT.output column).re =
        ∑ index : Fin 1, 1 * (toyFiniteIQFT.output column).re
      simp }

noncomputable def toyHawkingLogarithmicChart : LogarithmicChart 1 1 2 :=
  { map := toyHawkingAmplituhedronMap
    source_positive := by
      intro columns
      have index_zero : columns.index 0 = 0 := Fin.eq_zero (columns.index 0)
      change 0 < (toyHawkingAmplituhedronMap.source.mat.submatrix id columns.index).det
      rw [Matrix.det_fin_one]
      change 0 < toyHawkingAmplituhedronMap.source.mat 0 (columns.index 0)
      rw [index_zero]
      norm_num [toyHawkingAmplituhedronMap]
    boundary := toyAmplituhedronBoundary
    boundaryCoordinate := 1
    boundaryCoordinateLaw := by
      change (1 : ℝ) =
        (toyHawkingAmplituhedronMap.source.mat.submatrix id
          toyAmplituhedronBoundary.index).det
      rw [Matrix.det_fin_one]
      norm_num [toyHawkingAmplituhedronMap, toyAmplituhedronBoundary,
        Matrix.submatrix]
    boundaryCoordinate_nonzero := by norm_num
    residue := 1 }

noncomputable def toyHawkingALS : ALSDecomposition 1 1 2 :=
  { rank := toyALSRank2
    observed := fun _ _ time => (toyFiniteIQFT.output time).re
    reconstructed := fun _ _ _ => 0
    factorX := fun _ _ => 0
    factorY := fun _ _ => 0
    factorT := fun _ _ => 0
    reconstructionLaw := by
      intro x y time
      simp [cpReconstruction]
    residualMagnitude := 1
    residualMagnitude_nonnegative := by norm_num
    residualTolerance := 1
    residualTolerance_nonnegative := by norm_num
    residualWithinTolerance := by norm_num
    iterations := 2
    maximumIterations := 10
    iterationsWithinLimit := by norm_num }

example : toyHawkingALS.rank.rank = 2 := by
  rfl

example : toyHawkingALS.residualMagnitude ≤ toyHawkingALS.residualTolerance := by
  exact toyHawkingALS.residual_within_tolerance

noncomputable def toyHawkingDecoding : HawkingRadiationDecoding 1 1 2 :=
  { emission := toyWave
    interactiveGPE := toyIGPE
    inverseGPE := toyInverseGPE
    preparedModulation := toyPreparedModulation
    observedTensor := toyObservedHomodyneTensor
    observationX := 0
    observationY := 0
    observedTrace := toyObservedHomodyneTensor.trace 0 0
    observedTraceLaw := by
      intro time
      rfl
    iGPEOutput := fun _ => 1
    iGPEResidualMagnitude := 0
    iGPEResidualMagnitude_nonnegative := by norm_num
    iGPEResidualTolerance := 1
    iGPEResidualTolerance_nonnegative := by norm_num
    iGPEResidualWithinTolerance := by norm_num
    iqft := toyFiniteIQFT
    iqftInputLaw := by
      intro inputIndex
      rfl
    amplituhedron := toyHawkingAmplituhedronMap
    amplituhedronChart := toyHawkingLogarithmicChart
    amplituhedronChartMapLaw := by
      rfl
    iqftExternalDataLaw := by
      intro row column
      rfl
    als := toyHawkingALS
    alsSliceY := 0
    alsProjection := fun _ time => toyHawkingAmplituhedronMap.image 0 time
    alsProjectionObservedLaw := by
      intro x time
      rfl
    alsProjectionMapLaw := by
      rfl
    inputComparison :=
      { prepared := toyPreparedModulation.value
        recovered := fun time => (toyFiniteIQFT.output time).re
        residualMagnitude := 1
        residualMagnitude_nonnegative := by norm_num
        residualTolerance := 1
        residualTolerance_nonnegative := by norm_num
        residualWithinTolerance := by norm_num }
    inputComparisonPreparedLaw := by
      rfl
    inputComparisonRecoveredLaw := by
      intro time
      rfl }

example : toyHawkingDecoding.observedTrace 0 =
    toyHawkingDecoding.observedTensor.trace 0 0 0 := by
  exact toyHawkingDecoding.observed_trace_holds 0

example : toyHawkingDecoding.iqft.input 0 = toyHawkingDecoding.iGPEOutput 0 := by
  exact toyHawkingDecoding.iqft_input_holds 0

example : toyHawkingDecoding.alsProjection =
    toyHawkingDecoding.amplituhedron.image := by
  exact toyHawkingDecoding.als_projection_holds

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

noncomputable def toyLVPProcess : LVPProcess :=
  { route := LVPProcessRoute.rollToRoll
    webSpeed := { metersPerSecond := 1 }
    webSpeed_pos := by norm_num
    webTension := { newtons := 1 }
    webTension_nonnegative := by norm_num
    rollerRate := { hz := 1 }
    rollerRate_nonnegative := by norm_num
    precursorViscosity := { pascalSeconds := 1 }
    precursorViscosity_nonnegative := by norm_num
    precursorMassFlow := { kilogramsPerSecond := 1 }
    precursorMassFlow_nonnegative := by norm_num
    ambientHumidity := { fraction := 1 / 2 }
    ambientHumidity_nonnegative := by norm_num
    ambientHumidity_le_one := by norm_num
    wetFilmThickness := { meters := 1 / 1000 }
    wetFilmThickness_pos := by norm_num
    processTemperature := { kelvin := 300 }
    processTemperature_pos := by norm_num
    crystallizationTime := { seconds := 1 }
    crystallizationTime_pos := by norm_num
    availableCureTime := { seconds := 2 }
    availableCureTime_pos := by norm_num
    cureSufficient := by norm_num }

noncomputable def toyLVP : LigninVitrimerPerovskite :=
  { perovskiteComposition := "lead-halide"
    ligninFraction := { value := 1 / 4, nonnegative := by norm_num, le_one := by norm_num }
    vitrimerFraction := { value := 1 / 4, nonnegative := by norm_num, le_one := by norm_num }
    perovskiteFraction := { value := 1 / 4, nonnegative := by norm_num, le_one := by norm_num }
    carbonTransportFraction :=
      { value := 1 / 4, nonnegative := by norm_num, le_one := by norm_num }
    compositionLaw := by norm_num
    activeLayerThickness := { meters := 1 / 1000000 }
    activeLayerThickness_pos := by norm_num
    process := toyLVPProcess }

example : toyLVPProcess.crystallizationTime.seconds ≤
    toyLVPProcess.availableCureTime.seconds := by
  exact toyLVPProcess.cure_sufficient

example : toyLVP.ligninFraction.value + toyLVP.vitrimerFraction.value +
    toyLVP.perovskiteFraction.value + toyLVP.carbonTransportFraction.value = 1 := by
  exact toyLVP.composition_holds

noncomputable def toyLVPSolarObservation : LVPPhotovoltaicObservation :=
  { material := toyLVP
    activeArea := { squareMeters := 2 }
    activeArea_pos := by norm_num
    incidentIrradiance := { wattsPerSquareMeter := 1000 }
    incidentIrradiance_nonnegative := by norm_num
    outputPower := { watts := 400 }
    outputPower_nonnegative := by norm_num
    conversionEfficiency :=
      { value := 1 / 5, nonnegative := by norm_num, le_one := by norm_num }
    outputPowerLaw := by norm_num
    openCircuitVoltage := { volts := 1 }
    openCircuitVoltage_nonnegative := by norm_num
    shortCircuitCurrentDensity := { amperesPerSquareMeter := 20 }
    shortCircuitCurrentDensity_nonnegative := by norm_num
    fillFactor := { value := 4 / 5, nonnegative := by norm_num, le_one := by norm_num }
    operatingTemperature := { kelvin := 300 }
    operatingTemperature_pos := by norm_num
    relativeHumidity := { fraction := 1 / 2 }
    relativeHumidity_nonnegative := by norm_num
    relativeHumidity_le_one := by norm_num
    exposureDuration := { seconds := 10 }
    exposureDuration_pos := by norm_num
    postExposureOutputPower := { watts := 360 }
    postExposureOutputPower_nonnegative := by norm_num
    retainedPowerFraction :=
      { value := 9 / 10, nonnegative := by norm_num, le_one := by norm_num }
    retentionLaw := by norm_num
    comparisonResidual := 0
    comparisonResidual_nonnegative := by norm_num
    comparisonTolerance := 1
    comparisonTolerance_nonnegative := by norm_num
    comparisonWithinTolerance := by norm_num }

example : toyLVPSolarObservation.outputPower.watts =
    toyLVPSolarObservation.conversionEfficiency.value *
      toyLVPSolarObservation.incidentIrradiance.wattsPerSquareMeter *
        toyLVPSolarObservation.activeArea.squareMeters := by
  exact toyLVPSolarObservation.output_power_holds

example : toyLVPSolarObservation.comparisonResidual ≤
    toyLVPSolarObservation.comparisonTolerance := by
  exact toyLVPSolarObservation.comparison_within_tolerance

noncomputable def toyLVPDirectConversionImaging : LVPDirectConversionImaging 2 2 :=
  { material := toyLVP
    validationLevel := LVPImagingValidationLevel.benchtop
    pixelPitch := { meters := 1 / 1000 }
    pixelPitch_pos := by norm_num
    incidentDose := { grays := 1 }
    incidentDose_nonnegative := by norm_num
    exposureDuration := { seconds := 1 }
    exposureDuration_pos := by norm_num
    pixelDose := fun _ _ => { grays := 1 }
    pixelDose_nonnegative := by
      intro row column
      norm_num
    rawSignal := fun _ _ => 3
    darkSignal := fun _ _ => 1
    correctedSignal := fun _ _ => 2
    darkCorrectionLaw := by
      intro row column
      norm_num
    signalGain := 2
    signalGain_nonnegative := by norm_num
    directConversionLaw := by
      intro row column
      norm_num
    detectionSensitivity := 1
    detectionSensitivity_nonnegative := by norm_num
    spatialResolution := { meters := 1 / 1000 }
    spatialResolution_pos := by norm_num
    imageResidual := 0
    imageResidual_nonnegative := by norm_num
    imageResidualTolerance := 1
    imageResidualTolerance_nonnegative := by norm_num
    imageResidualWithinTolerance := by norm_num }

example : toyLVPDirectConversionImaging.correctedSignal 0 0 =
    toyLVPDirectConversionImaging.rawSignal 0 0 -
      toyLVPDirectConversionImaging.darkSignal 0 0 := by
  exact toyLVPDirectConversionImaging.dark_correction_holds 0 0

example : toyLVPDirectConversionImaging.correctedSignal 1 1 =
    toyLVPDirectConversionImaging.signalGain *
      (toyLVPDirectConversionImaging.pixelDose 1 1).grays := by
  exact toyLVPDirectConversionImaging.dose_response_holds 1 1

noncomputable def toyLVPProcaImaging : LVPProcaImagingHypothesis 1 1 :=
  { material := toyLVP
    channel := toyChannel
    phaseMap := fun _ _ => 0
    longitudinalFraction :=
      { value := 1, nonnegative := by norm_num, le_one := by norm_num }
    spatialResolution := { meters := 1 / 1000000 }
    spatialResolution_pos := by norm_num
    incidentProbeEnergy := { joules := 1 }
    incidentProbeEnergy_nonnegative := by norm_num
    absorbedProbeEnergy := { joules := 1 / 1000000 }
    absorbedProbeEnergy_nonnegative := by norm_num
    phaseResidual := 0
    phaseResidual_nonnegative := by norm_num
    phaseResidualTolerance := 1
    phaseResidualTolerance_nonnegative := by norm_num
    phaseResidualWithinTolerance := by norm_num
    masslessControlResidual := 0
    masslessControlResidual_nonnegative := by norm_num
    masslessControlTolerance := 1
    masslessControlTolerance_nonnegative := by norm_num
    masslessControlWithinTolerance := by norm_num }

example : toyLVPProcaImaging.phaseResidual ≤
    toyLVPProcaImaging.phaseResidualTolerance := by
  exact toyLVPProcaImaging.phase_residual_within_tolerance

example : toyLVPProcaImaging.masslessControlResidual ≤
    toyLVPProcaImaging.masslessControlTolerance := by
  exact toyLVPProcaImaging.massless_control_within_tolerance

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

def toyPaperProcaDispersion : ProcaDispersion :=
  { mass := 3
    mass_nonnegative := by norm_num
    angularFrequency := 5
    angularFrequency_pos := by norm_num
    waveNumber := 4
    waveNumber_nonnegative := by norm_num
    aboveCutoff := by norm_num
    dispersionLaw := by norm_num }

noncomputable def toyPaperProcaResponse : ProcaMaterialResponse :=
  { mode := toyPaperProcaDispersion
    transverseDielectric := 16 / 25
    longitudinalDielectric := 0
    transverseLaw := by norm_num [toyPaperProcaDispersion]
    longitudinalLaw := by norm_num [toyPaperProcaDispersion] }

example : toyPaperProcaResponse.longitudinalDielectric = 0 := by
  exact toyPaperProcaResponse.longitudinal_zero_on_dispersion

noncomputable def toyPaperPlanarResponse : PlanarProcaCSResponse :=
  { procaMass := 3
    procaMass_nonnegative := by norm_num
    chernSimonsMass := 2
    angularFrequency := 5
    angularFrequency_pos := by norm_num
    waveNumber := 4
    transverseDielectric := 16 / 25
    longitudinalDielectric := 0
    chernSimonsDielectric := Complex.I * (2 : ℂ) / (5 : ℂ) ^ 3
    transverseLaw := by norm_num
    longitudinalLaw := by norm_num
    chernSimonsLaw := rfl }

example : toyPaperPlanarResponse.chernSimonsDielectric =
    Complex.I * (2 : ℂ) / (5 : ℂ) ^ 3 := by
  exact toyPaperPlanarResponse.chern_simons_holds

noncomputable def toyMassiveCavityMode : MassiveCavityMode :=
  { masslessFrequency := 3
    masslessFrequency_pos := by norm_num
    photonMassFrequency := 4
    photonMassFrequency_nonnegative := by norm_num
    massiveFrequency := 5
    massiveFrequency_pos := by norm_num
    resonanceLaw := by norm_num
    radiationPressureRatio := 5 / 3
    radiationPressureRatioLaw := by norm_num }

example : 1 < toyMassiveCavityMode.radiationPressureRatio := by
  exact toyMassiveCavityMode.radiation_pressure_ratio_gt_one
    (by norm_num [toyMassiveCavityMode])

noncomputable def toyPaperDipolePattern : ProcaDipolePattern :=
  { scale := 2
    scale_nonnegative := by norm_num
    angle := 0
    transversePattern := 0
    longitudinalPattern := 2
    totalPattern := 2
    transverseLaw := by norm_num
    longitudinalLaw := by norm_num
    totalLaw := by norm_num }

example : toyPaperDipolePattern.totalPattern = toyPaperDipolePattern.scale := by
  exact toyPaperDipolePattern.total_isotropic

noncomputable def toyQuantumSourceDirectivity : QuantumSourceDirectivity :=
  { localDetectionRate := 3
    localDetectionRate_nonnegative := by norm_num
    angularAverageRate := 2
    angularAverageRate_pos := by norm_num
    directivity := 3 / 2
    directivityLaw := by norm_num }

example : 0 ≤ toyQuantumSourceDirectivity.directivity := by
  exact toyQuantumSourceDirectivity.directivity_nonnegative

noncomputable def toyNonlocalityDecay : NonlocalityDecay :=
  { separation := 2
    separation_pos := by norm_num
    coefficient := 3
    coefficient_pos := by norm_num
    commutatorMagnitude := 3 / 16
    commutatorMagnitudeLaw := by norm_num }

example : 0 < toyNonlocalityDecay.commutatorMagnitude := by
  exact toyNonlocalityDecay.commutator_positive

noncomputable def toyCoupledCavityModes : CoupledCavityModes :=
  { cavityFrequency := { hz := 5 }
    cavityFrequency_pos := by norm_num
    matterFrequency := { hz := 5 }
    matterFrequency_pos := by norm_num
    couplingFrequency := { hz := 1 }
    couplingFrequency_nonnegative := by norm_num
    lowerHybridFrequency := { hz := 4 }
    lowerHybridFrequency_nonnegative := by norm_num
    upperHybridFrequency := { hz := 6 }
    upperHybridFrequency_pos := by norm_num
    modeSplitting := { hz := 2 }
    modeSplitting_nonnegative := by norm_num
    normalizedCoupling := 1 / 5
    lowerHybridLaw := by norm_num
    upperHybridLaw := by norm_num
    modeSplittingLaw := by norm_num
    normalizedCouplingLaw := by norm_num }

example : toyCoupledCavityModes.modeSplitting.hz = 2 := by
  rw [toyCoupledCavityModes.resonant_splitting rfl]
  norm_num [toyCoupledCavityModes]

noncomputable def toyCarrierDensityResonance : CarrierDensityResonance :=
  { carrierDensity := 4
    carrierDensity_pos := by norm_num
    prefactor := 2
    prefactor_pos := by norm_num
    exponent := 0
    resonanceFrequency := { hz := 2 }
    resonanceFrequency_pos := by norm_num
    resonanceLaw := by norm_num }

example : toyCarrierDensityResonance.resonanceFrequency.hz = 2 := by
  rw [toyCarrierDensityResonance.resonanceLaw]
  norm_num [toyCarrierDensityResonance]

def toySpectralWeightTransfer : SpectralWeightTransfer :=
  { upperWeightBefore := 4
    upperWeightBefore_nonnegative := by norm_num
    lowerWeightBefore := 1
    lowerWeightBefore_nonnegative := by norm_num
    upperWeightAfter := 2
    upperWeightAfter_nonnegative := by norm_num
    lowerWeightAfter := 3
    lowerWeightAfter_nonnegative := by norm_num
    conservation := by norm_num
    transferAmount := 2
    transferAmount_nonnegative := by norm_num
    transferLaw := by norm_num }

example : toySpectralWeightTransfer.lowerWeightAfter -
    toySpectralWeightTransfer.lowerWeightBefore =
    toySpectralWeightTransfer.transferAmount := by
  exact toySpectralWeightTransfer.lower_branch_gain

def toyGroverPhaseInversion : GroverPhaseInversion :=
  { targetBefore := 1
    targetAfter := -1
    orthogonalBefore := 2
    orthogonalAfter := 2
    targetLaw := by norm_num
    orthogonalLaw := by norm_num }

noncomputable def toyGroverRotation : GroverRotation :=
  { overlap := 1 / 2
    overlap_nonnegative := by norm_num
    overlap_le_one := by norm_num
    angle := Real.pi / 3
    overlapLaw := by
      rw [show Real.pi / 3 / 2 = Real.pi / 6 by ring,
        Real.sin_pi_div_six]
    iterationCount := 1
    targetAmplitude := 1
    orthogonalAmplitude := 0
    targetAmplitudeLaw := by
      have angle_identity :
          ((2 * 1 + 1 : ℕ) : ℝ) * (Real.pi / 3) / 2 = Real.pi / 2 := by
        norm_num
        ring
      rw [angle_identity, Real.sin_pi_div_two]
    orthogonalAmplitudeLaw := by
      have angle_identity :
          ((2 * 1 + 1 : ℕ) : ℝ) * (Real.pi / 3) / 2 = Real.pi / 2 := by
        norm_num
        ring
      rw [angle_identity, Real.cos_pi_div_two]
    fidelity := 1
    fidelityLaw := by norm_num }

example : toyGroverRotation.targetAmplitude = 1 ∧
    toyGroverRotation.fidelity = 1 := by
  exact toyGroverRotation.one_step_perfect rfl rfl

noncomputable def toyDickeStateOverlap : DickeStateOverlap :=
  { qubitCount := 4
    excitations := 2
    excitations_le_qubits := by norm_num
    rotationAngle := 0
    overlapAmplitude := 0
    overlapLaw := by norm_num }

example : toyDickeStateOverlap.overlapAmplitude = 0 := by
  rw [toyDickeStateOverlap.overlapLaw]
  norm_num [toyDickeStateOverlap]

def toyCavityQEDPhaseOracle : CavityQEDPhaseOracle :=
  { atomCavityCoupling := 2
    atomCavityCoupling_nonnegative := by norm_num
    detuning := 4
    detuning_ne_zero := by norm_num
    dispersiveShift := 1
    dispersiveShiftLaw := by norm_num
    bareCavityFrequency := { hz := 10 }
    bareCavityFrequency_pos := by norm_num
    selectedExcitation := 3
    targetExcitation := 3
    shiftedCavityFrequency := { hz := 13 }
    shiftedCavityFrequency_pos := by norm_num
    shiftedFrequencyLaw := by norm_num
    reflectedPhase := -1
    reflectedPhaseLaw := by norm_num }

example : toyCavityQEDPhaseOracle.shiftedCavityFrequency.hz = 13 := by
  rw [toyCavityQEDPhaseOracle.shifted_frequency_holds]
  norm_num [toyCavityQEDPhaseOracle]

example : Complex.normSq toyCavityQEDPhaseOracle.reflectedPhase = 1 := by
  exact toyCavityQEDPhaseOracle.reflected_phase_normSq

noncomputable def toyGroverCavityFidelityScaling : GroverCavityFidelityScaling :=
  { cooperativity := 100
    cooperativity_pos := by norm_num
    bandwidthRatio := 1 / 100
    bandwidthRatio_nonnegative := by norm_num
    unheraldedExponent := 1 / 2
    unheraldedExponentLaw := by norm_num
    heraldedExponent := 2 / 3
    heraldedExponentLaw := by norm_num
    modeMatching := 99 / 100
    modeMatching_nonnegative := by norm_num
    modeMatching_le_one := by norm_num
    heraldingSuccessProbability := 4 / 5
    heraldingSuccessProbability_nonnegative := by norm_num
    heraldingSuccessProbability_le_one := by norm_num }

example : toyGroverCavityFidelityScaling.heraldedExponent = 2 / 3 := by
  exact toyGroverCavityFidelityScaling.heralded_exponent

noncomputable def toySecondHarmonicResonance : SecondHarmonicResonance :=
  { fundamentalFrequency := { hz := 5 }
    fundamentalFrequency_pos := by norm_num
    secondHarmonicFrequency := { hz := 10 }
    secondHarmonicFrequency_pos := by norm_num
    resonantFrequency := { hz := 10 }
    resonantFrequency_pos := by norm_num
    secondHarmonicLaw := by norm_num
    resonanceLaw := by norm_num }

noncomputable def toyActiveOpticalAmplifier : ActiveOpticalAmplifier :=
  { signalInputPower := { watts := 1 }
    signalInputPower_nonnegative := by norm_num
    pumpPower := { watts := 2 }
    pumpPower_nonnegative := by norm_num
    signalOutputPower := { watts := 2 }
    signalOutputPower_nonnegative := by norm_num
    dissipatedPower := { watts := 1 }
    dissipatedPower_nonnegative := by norm_num
    linearGain := 2
    linearGain_nonnegative := by norm_num
    gainLaw := by norm_num
    powerBalance := by norm_num }

noncomputable def toyLowPowerIntegratedOPA : LowPowerIntegratedOPA :=
  { resonance := toySecondHarmonicResonance
    amplifier := toyActiveOpticalAmplifier
    reportedGainDecibels := 17
    reportedGainDecibels_min := by norm_num
    bandwidthHz := 1
    bandwidth_nonnegative := by norm_num
    inputPowerLimitWatts := 200
    inputPowerLimit_pos := by norm_num
    inputPowerBelowLimit := by norm_num [toyActiveOpticalAmplifier] }

example : toyLowPowerIntegratedOPA.amplifier.signalOutputPower.watts ≤
    toyLowPowerIntegratedOPA.amplifier.signalInputPower.watts +
      toyLowPowerIntegratedOPA.amplifier.pumpPower.watts := by
  exact toyLowPowerIntegratedOPA.amplifier.output_le_input_and_pump

noncomputable def toySPPFreeElectronAmplifier : SPPFreeElectronAmplifier :=
  { inputPower := { watts := 1 }
    inputPower_nonnegative := by norm_num
    electronPumpPower := { watts := 3 }
    electronPumpPower_nonnegative := by norm_num
    outputPower := { watts := 3 }
    outputPower_nonnegative := by norm_num
    lossPower := { watts := 1 }
    lossPower_nonnegative := by norm_num
    linearGain := 3
    linearGain_nonnegative := by norm_num
    gainLaw := by norm_num
    powerBalance := by norm_num
    initialFrequency := { hz := 4 }
    initialFrequency_pos := by norm_num
    finalFrequency := { hz := 2 }
    finalFrequency_pos := by norm_num
    interactionLength := { meters := 1 }
    interactionLength_pos := by norm_num
    twofoldRedshiftLaw := by norm_num
    phaseAlignment := { value := 1, nonnegative := by norm_num, le_one := by norm_num } }

example : toySPPFreeElectronAmplifier.finalFrequency.hz =
    toySPPFreeElectronAmplifier.initialFrequency.hz / 2 := by
  exact toySPPFreeElectronAmplifier.twofold_redshift

def toyCylindricalSPPMode : CylindricalSPPMode :=
  { laserWaveNumber := 3
    laserWaveNumber_nonnegative := by norm_num
    sppWaveNumber := 3
    sppWaveNumber_nonnegative := by norm_num
    laserAzimuthalIndex := 1
    sppAzimuthalIndex := 1
    phaseMatching := by norm_num
    azimuthalMatching := by norm_num
    overlapEfficiency := { value := 1, nonnegative := by norm_num, le_one := by norm_num }
    electronDensity := 1
    electronDensity_pos := by norm_num
    criticalDensity := 1
    criticalDensity_pos := by norm_num
    nearCriticalRatio := 1
    nearCriticalRatioLaw := by norm_num }

def toyCoherentRadiationScaling : CoherentRadiationScaling :=
  { electronCount := 4
    electronCount_ge_one := by norm_num
    singleElectronIntensity := 2
    singleElectronIntensity_nonnegative := by norm_num
    coherentIntensity := 32
    coherentIntensity_nonnegative := by norm_num
    incoherentIntensity := 8
    incoherentIntensity_nonnegative := by norm_num
    coherentLaw := by norm_num
    incoherentLaw := by norm_num }

example : toyCoherentRadiationScaling.incoherentIntensity ≤
    toyCoherentRadiationScaling.coherentIntensity := by
  exact toyCoherentRadiationScaling.incoherent_le_coherent

def toyCSSStabilizerCode : CSSStabilizerCode :=
  { physicalQubits := 3
    physicalQubits_positive := by norm_num
    logicalQubits := 1
    logicalQubits_le_physical := by norm_num
    codeDistance := 1
    codeDistance_positive := by norm_num
    maximumCheckWeight := 4
    maximumCheckWeight_positive := by norm_num
    cssCommutationResidual := 0
    cssCommutationLaw := by norm_num }

def toyLayerCodeLift : LayerCodeLift :=
  { input := toyCSSStabilizerCode
    layerCount := 2
    layerCount_positive := by norm_num
    outputPhysicalQubits := 4
    outputPhysicalQubits_positive := by norm_num
    outputLogicalQubits := 1
    outputLogicalQubits_le_physical := by norm_num
    outputCodeDistance := 1
    outputCodeDistance_positive := by norm_num
    topologicalDimension := 3
    junctionDimension := 1
    maximumStabilizerWeight := 6
    logicalQubitsLaw := by norm_num [toyCSSStabilizerCode]
    topologicalDimensionLaw := by norm_num
    junctionDimensionLaw := by norm_num
    stabilizerWeightBound := by norm_num
    outputCommutationResidual := 0
    outputCommutationLaw := by norm_num
    optimalScalingClaimed := true
    energyBarrierSystemSize := 2
    energyBarrierSystemSize_pos := by norm_num
    energyBarrierCoefficient := 1
    energyBarrierCoefficient_nonnegative := by norm_num
    energyBarrierExponent := 2
    energyBarrierExponent_positive := by norm_num
    energyBarrier := 4
    energyBarrier_nonnegative := by norm_num
    energyBarrierLaw := by norm_num }

example : toyLayerCodeLift.maximumStabilizerWeight ≤ 6 := by
  exact toyLayerCodeLift.stabilizer_weight_le_six

example : surfaceCodeReference.localStatus = QECReferenceStatus.referenceOnly := by
  rfl

example : layerCodeReference.localStatus =
    QECReferenceStatus.localParameterMetadata := by
  rfl

def toyStarConsensusCouncil : StarConsensusCouncil :=
  { nodeCount := 10
    nodeCount_at_least_two := by norm_num
    anchorCount := 1
    anchorCountLaw := by norm_num
    spokeCount := 9
    spokeCountLaw := by norm_num
    globalEntanglingRounds := 1
    globalEntanglingRounds_positive := by norm_num
    postProcessingMajority := true }

noncomputable def toyConsensusObservation : ConsensusObservation :=
  { shots := 100
    shots_positive := by norm_num
    logicalSuccesses := 99
    logicalSuccesses_le_shots := by norm_num
    logicalFidelity := 99 / 100
    logicalFidelity_nonnegative := by norm_num
    logicalFidelity_le_one := by norm_num
    logicalFidelityLaw := by norm_num }

noncomputable def toyMajorityDecodedObservation : MajorityDecodedObservation :=
  { council := toyStarConsensusCouncil
    measuredHammingWeight := 7
    hammingWeight_le_nodeCount := by norm_num [toyStarConsensusCouncil]
    decodedBit := some true
    decodedBitLaw := by norm_num [majorityDecision, toyStarConsensusCouncil]
    fidelity := toyConsensusObservation }

def toyProtocolZ8ReportedBenchmark : ProtocolZ8ReportedBenchmark :=
  { backend := "ibm_torino"
    heartbeat :=
      { backend := "ibm_torino"
        date := "2026-01-09"
        run1 :=
          { runId := 1
            logicalFidelity := 0.9353
            logicalFidelity_nonnegative := by norm_num
            logicalFidelity_le_one := by norm_num
            passed := true }
        run1_id_law := by norm_num
        run2 :=
          { runId := 2
            logicalFidelity := 0.9080
            logicalFidelity_nonnegative := by norm_num
            logicalFidelity_le_one := by norm_num
            passed := true }
        run2_id_law := by norm_num
        run3 :=
          { runId := 3
            logicalFidelity := 0.9363
            logicalFidelity_nonnegative := by norm_num
            logicalFidelity_le_one := by norm_num
            passed := true }
        run3_id_law := by norm_num
        run4 :=
          { runId := 4
            logicalFidelity := 0.9204
            logicalFidelity_nonnegative := by norm_num
            logicalFidelity_le_one := by norm_num
            passed := true }
        run4_id_law := by norm_num
        run5 :=
          { runId := 5
            logicalFidelity := 0.9211
            logicalFidelity_nonnegative := by norm_num
            logicalFidelity_le_one := by norm_num
            passed := true }
        run5_id_law := by norm_num
        averageFidelity := 0.92422
        averageFidelity_nonnegative := by norm_num
        averageFidelity_le_one := by norm_num
        averageFidelityLaw := by norm_num
        reportedAverageFidelity := 0.9242
        reportedAverageFidelity_nonnegative := by norm_num
        reportedAverageFidelity_le_one := by norm_num
        reportedAverageFidelityLaw := by norm_num }
    jobIdentifier := "d5gk867ea9qs739131u0"
    totalShots := 4096
    totalShots_positive := by norm_num
    majorityThreshold := 5
    majorityThreshold_positive := by norm_num
    consensusZeroCount := 1983
    consensusOneCount := 1674
    correctedCount := 103
    listedRawCountCoverage := 3760
    listedRawCountCoverageLaw := by norm_num
    listedRawCountCoverage_le_total := by norm_num
    reportedPhysicalFidelity := 0.6809
    reportedPhysicalFidelity_nonnegative := by norm_num
    reportedPhysicalFidelity_le_one := by norm_num
    reportedLogicalFidelity := 0.9885
    reportedLogicalFidelityLaw := by norm_num
    reportedLogicalFidelity_nonnegative := by norm_num
    reportedLogicalFidelity_le_one := by norm_num
    reportedCorrectionRate := 0.1072
    reportedCorrectionRate_nonnegative := by norm_num
    reportedCorrectionRate_le_one := by norm_num
    evidenceStatus := ConsensusEvidenceStatus.reportedHardware
    completeRawCounts := false
    reproduction := false
    sourceRepository := "https://github.com/ENKI-420/consensus-quantum-protocol" }

example : ¬toyProtocolZ8ReportedBenchmark.independentlyVerified := by
  apply toyProtocolZ8ReportedBenchmark.not_independentlyVerified_of_incomplete
  rfl

example : toyProtocolZ8ReportedBenchmark.heartbeat.averageFidelity = 0.92422 := by
  rw [toyProtocolZ8ReportedBenchmark.heartbeat.average_fidelity_holds]
  norm_num [toyProtocolZ8ReportedBenchmark]

example : toyProtocolZ8ReportedBenchmark.heartbeat.reportedAverageFidelity =
    0.9242 := by
  exact toyProtocolZ8ReportedBenchmark.heartbeat.reported_average_fidelity_holds

example : cyclicShift (by norm_num : 0 < 100)
    ⟨0, by norm_num⟩ ⟨7, by norm_num⟩ = ⟨7, by norm_num⟩ := by
  exact cyclicShift_zero (by norm_num) ⟨7, by norm_num⟩

noncomputable def toyGKPQutrit : GKPQuditModel 3 :=
  { dimension_at_least_two := by norm_num
    logicalPauliSpacing := Real.sqrt (Real.pi / 3)
    logicalPauliSpacing_nonnegative := Real.sqrt_nonneg _
    logicalPauliSpacingLaw := by rfl
    stabilizerLength := Real.sqrt (Real.pi * 3)
    stabilizerLength_nonnegative := Real.sqrt_nonneg _
    stabilizerLengthLaw := by rfl
    envelopeParameter := 0.32
    envelopeParameter_pos := by norm_num
    meanPhotonNumber := 1 / (2 * (0.32 : ℝ) ^ 2)
    meanPhotonNumber_nonnegative := by positivity
    finiteEnergyEnvelopeLaw := by rfl }

noncomputable def toyGKPQuquart : GKPQuditModel 4 :=
  { dimension_at_least_two := by norm_num
    logicalPauliSpacing := Real.sqrt (Real.pi / 4)
    logicalPauliSpacing_nonnegative := Real.sqrt_nonneg _
    logicalPauliSpacingLaw := by rfl
    stabilizerLength := Real.sqrt (Real.pi * 4)
    stabilizerLength_nonnegative := Real.sqrt_nonneg _
    stabilizerLengthLaw := by rfl
    envelopeParameter := 0.32
    envelopeParameter_pos := by norm_num
    meanPhotonNumber := 1 / (2 * (0.32 : ℝ) ^ 2)
    meanPhotonNumber_nonnegative := by positivity
    finiteEnergyEnvelopeLaw := by rfl }

noncomputable def toyQutritGain : QuditQECGainObservation :=
  { dimension := 3
    dimension_at_least_two := by norm_num
    physicalDecayRate := 1
    physicalDecayRate_pos := by norm_num
    logicalDecayRate := 1 / 1.82
    logicalDecayRate_pos := by norm_num
    gain := 1.82
    gain_nonnegative := by norm_num
    gainLaw := by norm_num
    reportedStandardError := 0.03
    reportedStandardError_nonnegative := by norm_num
    reportedGainAboveBreakEven := by norm_num
    sourceStatus := "Brock et al. 2025; experimentally reported qutrit" }

noncomputable def toyQuquartGain : QuditQECGainObservation :=
  { dimension := 4
    dimension_at_least_two := by norm_num
    physicalDecayRate := 1
    physicalDecayRate_pos := by norm_num
    logicalDecayRate := 1 / 1.87
    logicalDecayRate_pos := by norm_num
    gain := 1.87
    gain_nonnegative := by norm_num
    gainLaw := by norm_num
    reportedStandardError := 0.03
    reportedStandardError_nonnegative := by norm_num
    reportedGainAboveBreakEven := by norm_num
    sourceStatus := "Brock et al. 2025; experimentally reported ququart" }

example : 1 < toyQutritGain.gain := by
  apply toyQutritGain.gain_gt_one
  norm_num [toyQutritGain]

example : 1 < toyQuquartGain.gain := by
  apply toyQuquartGain.gain_gt_one
  norm_num [toyQuquartGain]

noncomputable def toyOAM100State : Qudit 100 :=
  { amplitudes := fun mode =>
      if mode = ⟨0, by norm_num⟩ then 1 else 0
    normalized := by
      classical
      simp }

noncomputable def toyOAM100QuditQECDesign : OAM100QuditQECDesign :=
  { state := toyOAM100State
    modeLabel := centeredOAMMode
    modeLabelLaw := by intro mode; rfl
    modeLabel_injective := centeredOAMMode_injective
    modeSpacing := 1
    modeSpacing_pos := by norm_num
    gkpModel :=
      { dimension_at_least_two := by norm_num
        logicalPauliSpacing := Real.sqrt (Real.pi / 100)
        logicalPauliSpacing_nonnegative := Real.sqrt_nonneg _
        logicalPauliSpacingLaw := by rfl
        stabilizerLength := Real.sqrt (Real.pi * 100)
        stabilizerLength_nonnegative := Real.sqrt_nonneg _
        stabilizerLengthLaw := by rfl
        envelopeParameter := 0.1
        envelopeParameter_pos := by norm_num
        meanPhotonNumber := 50
        meanPhotonNumber_nonnegative := by norm_num
        finiteEnergyEnvelopeLaw := by norm_num }
    factorLeft := 4
    factorRight := 25
    factorizationLaw := by norm_num
    syndromeAxisCount := 2
    syndromeAxisCountLaw := by norm_num
    syndromeReadoutSpecified := false
    recoveryMapSpecified := false
    modeLossRate := 0
    modeLossRate_nonnegative := by norm_num
    modeDephasingRate := 0
    modeDephasingRate_nonnegative := by norm_num }

example : toyOAM100QuditQECDesign.factorLeft *
    toyOAM100QuditQECDesign.factorRight = 100 := by
  exact toyOAM100QuditQECDesign.factorization

example : toyOAM100QuditQECDesign.syndromeAxisCount = 2 := by
  exact toyOAM100QuditQECDesign.two_syndrome_axes

noncomputable def toySemiDiracQuadraticAxis : SemiDiracDispersion :=
  { mass := 2
    mass_pos := by norm_num
    linearVelocity := 3
    linearVelocity_pos := by norm_num
    momentumX := 2
    momentumY := 0
    energy := 1
    energy_nonnegative := by norm_num
    dispersionLaw := by norm_num }

noncomputable def toySemiDiracLinearAxis : SemiDiracDispersion :=
  { mass := 2
    mass_pos := by norm_num
    linearVelocity := 3
    linearVelocity_pos := by norm_num
    momentumX := 0
    momentumY := 2
    energy := 6
    energy_nonnegative := by norm_num
    dispersionLaw := by norm_num }

example : toySemiDiracQuadraticAxis.energy ^ 2 =
    (toySemiDiracQuadraticAxis.momentumX ^ 2 /
      (2 * toySemiDiracQuadraticAxis.mass)) ^ 2 := by
  apply toySemiDiracQuadraticAxis.quadratic_axis_energy_squared
  rfl

example : toySemiDiracLinearAxis.energy ^ 2 =
    (toySemiDiracLinearAxis.linearVelocity *
      toySemiDiracLinearAxis.momentumY) ^ 2 := by
  apply toySemiDiracLinearAxis.linear_axis_energy_squared
  rfl

noncomputable def toySemiDiracOpticalResponse : SemiDiracOpticalResponse :=
  { pumpPower := { watts := 2 }
    pumpPower_nonnegative := by norm_num
    quadraticResponse := 1
    quadraticResponse_nonnegative := by norm_num
    linearResponse := 2
    linearResponse_nonnegative := by norm_num
    quadraticResponseGain := 3
    quadraticResponseGain_nonnegative := by norm_num
    linearResponseGain := 1
    linearResponseGain_nonnegative := by norm_num
    quadraticSignal := 7
    quadraticSignal_nonnegative := by norm_num
    linearSignal := 4
    linearSignal_nonnegative := by norm_num
    quadraticResponseLaw := by norm_num
    linearResponseLaw := by norm_num }

example : toySemiDiracOpticalResponse.quadraticResponse <
    toySemiDiracOpticalResponse.quadraticSignal := by
  apply toySemiDiracOpticalResponse.quadratic_response_increases
  · norm_num [toySemiDiracOpticalResponse]
  · norm_num [toySemiDiracOpticalResponse]

noncomputable def toySemiDiracPowerBudget : SemiDiracOpticalPowerBudget :=
  { fiberLaserPower := { watts := 10 }
    fiberLaserPower_nonnegative := by norm_num
    resonatorPower := { watts := 2 }
    resonatorPower_nonnegative := by norm_num
    metamaterialPower := { watts := 3 }
    metamaterialPower_nonnegative := by norm_num
    processPower := { watts := 4 }
    processPower_nonnegative := by norm_num
    lossPower := { watts := 1 }
    lossPower_nonnegative := by norm_num
    inputPower := { watts := 10 }
    inputPower_nonnegative := by norm_num
    powerBalance := by norm_num
    laserInputLaw := by norm_num }

example : toySemiDiracPowerBudget.resonatorPower.watts +
    toySemiDiracPowerBudget.metamaterialPower.watts +
    toySemiDiracPowerBudget.processPower.watts ≤
      toySemiDiracPowerBudget.fiberLaserPower.watts := by
  exact toySemiDiracPowerBudget.outputs_le_fiber_laser

noncomputable def toySemiDiracGrapheneProcess : SemiDiracGrapheneProcess :=
  { budget := toySemiDiracPowerBudget
    endToEndEfficiency :=
      { value := 1 / 2
        nonnegative := by norm_num
        le_one := by norm_num }
    absorbedPower := { watts := 5 }
    absorbedPower_nonnegative := by norm_num
    absorbedPowerLaw := by norm_num [toySemiDiracPowerBudget]
    requiredAbsorbedPower := { watts := 4 }
    requiredAbsorbedPower_nonnegative := by norm_num
    thresholdLaw := by norm_num
    materialCalibrationSpecified := true
    phaseIdentificationSpecified := false
    grapheneFormationVerified := false }

example : toySemiDiracGrapheneProcess.requiredAbsorbedPower.watts ≤
    toySemiDiracGrapheneProcess.absorbedPower.watts := by
  exact toySemiDiracGrapheneProcess.threshold_holds

example : 8 ≤ toySemiDiracGrapheneProcess.budget.fiberLaserPower.watts := by
  have lowerBound :=
    toySemiDiracGrapheneProcess.fiber_laser_power_lower_bound (by
      norm_num [toySemiDiracGrapheneProcess])
  norm_num [toySemiDiracGrapheneProcess] at lowerBound ⊢
  exact lowerBound

noncomputable def toyPulsedAblation : PulsedLaserTask :=
  { task := LaserTask.ablation
    beamKind := LaserBeamKind.femtosecondPulse
    status := LaserTaskStatus.demonstratedAnalog
    wavelength := { meters := 800e-9 }
    wavelength_pos := by norm_num
    pulseEnergy := { joules := 1e-6 }
    pulseEnergy_nonnegative := by norm_num
    pulseDuration := { seconds := 100e-15 }
    pulseDuration_pos := by norm_num
    repetitionRate := { hz := 100000 }
    repetitionRate_nonnegative := by norm_num
    spotArea := { squareMeters := 1e-10 }
    spotArea_pos := by norm_num
    fluence := { joulesPerSquareMeter := 10000 }
    fluence_nonnegative := by norm_num
    peakPower := { watts := 1e7 }
    peakPower_nonnegative := by norm_num
    maximumPeakPower := { watts := 2e7 }
    maximumPeakPower_nonnegative := by norm_num
    peakPower_le_maximum := by norm_num
    fluenceLaw := by norm_num
    peakPowerLaw := by norm_num }

example : toyPulsedAblation.fluence.joulesPerSquareMeter *
  toyPulsedAblation.spotArea.squareMeters =
    toyPulsedAblation.pulseEnergy.joules := by
  exact toyPulsedAblation.fluence_holds

example : toyPulsedAblation.peakPower.watts ≤
    toyPulsedAblation.maximumPeakPower.watts := by
  exact toyPulsedAblation.peak_power_le_maximum

noncomputable def toyLaserCompressionShock : LaserShockTask :=
  { pulsedTask :=
      { task := LaserTask.laserCompressionShock
        beamKind := LaserBeamKind.pulsedShockDrive
        status := LaserTaskStatus.demonstratedAnalog
        wavelength := { meters := 527e-9 }
        wavelength_pos := by norm_num
        pulseEnergy := { joules := 16 }
        pulseEnergy_nonnegative := by norm_num
        pulseDuration := { seconds := 10e-9 }
        pulseDuration_pos := by norm_num
        repetitionRate := { hz := 1 }
        repetitionRate_nonnegative := by norm_num
        spotArea := { squareMeters := 1e-8 }
        spotArea_pos := by norm_num
        fluence := { joulesPerSquareMeter := 1.6e9 }
        fluence_nonnegative := by norm_num
        peakPower := { watts := 1.6e9 }
        peakPower_nonnegative := by norm_num
        maximumPeakPower := { watts := 2e9 }
        maximumPeakPower_nonnegative := by norm_num
        peakPower_le_maximum := by norm_num
        fluenceLaw := by norm_num
        peakPowerLaw := by norm_num }
    shockPressure := { pascals := 2.27e9 }
    shockPressure_nonnegative := by norm_num
    shockPressureThreshold := { pascals := 2e9 }
    shockPressureThreshold_nonnegative := by norm_num
    pressureThresholdLaw := by norm_num
    substrateCalibrated := true
    shockConfinementCalibrated := false }

example : toyLaserCompressionShock.shockPressureThreshold.pascals ≤
    toyLaserCompressionShock.shockPressure.pascals := by
  exact toyLaserCompressionShock.pressure_threshold_met

example : toyLaserCompressionShock.pulsedTask.peakPower.watts ≤
    toyLaserCompressionShock.pulsedTask.maximumPeakPower.watts := by
  exact toyLaserCompressionShock.pulsedTask.peak_power_le_maximum

noncomputable def toyDirectWriteGraphene : ContinuousWaveLaserTask :=
  { task := LaserTask.graphene
    beamKind := LaserBeamKind.continuousWave
    status := LaserTaskStatus.demonstratedProcess
    wavelength := { meters := 10.6e-6 }
    wavelength_pos := by norm_num
    averagePower := { watts := 32 }
    averagePower_nonnegative := by norm_num
    maximumAveragePower := { watts := 40 }
    maximumAveragePower_nonnegative := by norm_num
    averagePower_le_maximum := by norm_num
    spotArea := { squareMeters := 1e-8 }
    spotArea_pos := by norm_num
    scanSpeed := { metersPerSecond := 0.2 }
    scanSpeed_pos := by norm_num
    absorbedPowerThreshold := { watts := 16 }
    absorbedPowerThreshold_nonnegative := by norm_num
    endToEndEfficiency := 1 / 2
    endToEndEfficiency_nonnegative := by norm_num
    endToEndEfficiency_le_one := by norm_num
    absorbedPowerLaw := by norm_num }

example : 32 ≤ toyDirectWriteGraphene.averagePower.watts := by
  have lowerBound := toyDirectWriteGraphene.average_power_lower_bound (by
    norm_num [toyDirectWriteGraphene])
  norm_num [toyDirectWriteGraphene] at lowerBound ⊢

example : toyDirectWriteGraphene.averagePower.watts ≤
    toyDirectWriteGraphene.maximumAveragePower.watts := by
  exact toyDirectWriteGraphene.average_power_le_maximum

noncomputable def toyShockSynthesizedDiamond : LaserShockTask :=
  { pulsedTask := toyLaserCompressionShock.pulsedTask
    shockPressure := { pascals := 60e9 }
    shockPressure_nonnegative := by norm_num
    shockPressureThreshold := { pascals := 50e9 }
    shockPressureThreshold_nonnegative := by norm_num
    pressureThresholdLaw := by norm_num
    substrateCalibrated := true
    shockConfinementCalibrated := true }

example : toyShockSynthesizedDiamond.shockPressureThreshold.pascals ≤
    toyShockSynthesizedDiamond.shockPressure.pascals := by
  exact toyShockSynthesizedDiamond.pressure_threshold_met

example : toyShockSynthesizedDiamond.pulsedTask.peakPower.watts ≤
    toyShockSynthesizedDiamond.pulsedTask.maximumPeakPower.watts := by
  exact toyShockSynthesizedDiamond.pulsedTask.peak_power_le_maximum

noncomputable def toyConvergentHolographicGraphene : HolographicLaserTaskBoundary :=
  { task := LaserTask.convergentHolographicGraphene
    beamKind := LaserBeamKind.unsupportedProcaHolographic
    status := LaserTaskStatus.unsupportedProposal
    sourcePower := { watts := 0.06 }
    sourcePower_nonnegative := by norm_num
    maximumSourcePower := { watts := 0.12 }
    maximumSourcePower_nonnegative := by norm_num
    sourcePower_le_maximum := by norm_num
    beamCount := 4
    beamCount_pos := by norm_num
    phaseControlCalibrated := false
    focalVolumeCalibrated := false
    materialTransformationVerified := false
    independentStructuralVerification := false }

example : toyConvergentHolographicGraphene.status =
    LaserTaskStatus.unsupportedProposal := by
  exact toyConvergentHolographicGraphene.is_unsupported_proposal rfl

example : toyConvergentHolographicGraphene.sourcePower.watts ≤
    toyConvergentHolographicGraphene.maximumSourcePower.watts := by
  exact toyConvergentHolographicGraphene.source_power_le_maximum

noncomputable def toyConvergentHolographicGrapheneAndDiamond :
    HolographicLaserTaskBoundary :=
  { task := LaserTask.convergentHolographicGrapheneAndDiamond
    beamKind := LaserBeamKind.unsupportedProcaHolographic
    status := LaserTaskStatus.unsupportedProposal
    sourcePower := { watts := 25000 }
    sourcePower_nonnegative := by norm_num
    maximumSourcePower := { watts := 25000 }
    maximumSourcePower_nonnegative := by norm_num
    sourcePower_le_maximum := by norm_num
    beamCount := 4
    beamCount_pos := by norm_num
    phaseControlCalibrated := false
    focalVolumeCalibrated := false
    materialTransformationVerified := false
    independentStructuralVerification := false }

example : toyConvergentHolographicGrapheneAndDiamond.status =
    LaserTaskStatus.unsupportedProposal := by
  exact toyConvergentHolographicGrapheneAndDiamond.is_unsupported_proposal rfl

example : toyConvergentHolographicGrapheneAndDiamond.sourcePower.watts ≤
    toyConvergentHolographicGrapheneAndDiamond.maximumSourcePower.watts := by
  exact toyConvergentHolographicGrapheneAndDiamond.source_power_le_maximum

end SignalsPendingTests
