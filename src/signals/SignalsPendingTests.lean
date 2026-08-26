import Mathlib.Tactic
import SignalsPending

namespace SignalsPendingTests

open Signals.Applications
open Signals.Acoustics
open Signals.IQ
open Signals.Maxwell
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

end SignalsPendingTests
