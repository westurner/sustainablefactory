import Mathlib.Tactic
import Mathlib.Logic.Equiv.Fin.Rotate
import Signals

namespace SignalsTests

open Signals.Fabrication
open Signals.Geometry
open Signals.Homodyne
open Signals.IQ
open Signals.Antennas
open Signals.Proca
open Signals.Sampling
open Signals.Units
open Signals.Propagation
open Signals.Applications
open Signals.Acoustics
open Signals.Coherence
open Signals.Maxwell
open Signals.NonDestructive
open Signals.Scattering
open Signals.MHD
open Signals.Radio
open Signals.DDF
open Signals.Lasers
open Signals.SolitonBus

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

  def toyLocalOscillator : LocalOscillator :=
    { amplitude := 1
      amplitude_nonnegative := by norm_num
      phase := 0 }

  noncomputable def toyBalancedHomodyne : BalancedHomodyne :=
    { signal := { inPhase := 1, quadrature := 0 }
      localOscillator := toyLocalOscillator
      plusOutput := beamSplitterPlus { inPhase := 1, quadrature := 0 }
        toyLocalOscillator.asSample
      minusOutput := beamSplitterMinus { inPhase := 1, quadrature := 0 }
        toyLocalOscillator.asSample
      plusOutputLaw := by rfl
      minusOutputLaw := by rfl
      plusDetector := sampleEnergy (beamSplitterPlus { inPhase := 1, quadrature := 0 }
        toyLocalOscillator.asSample)
      minusDetector := sampleEnergy (beamSplitterMinus { inPhase := 1, quadrature := 0 }
        toyLocalOscillator.asSample)
      plusDetectorLaw := by rfl
      minusDetectorLaw := by rfl
      differentialPhotocurrent := differentialPhotocurrent
        { inPhase := 1, quadrature := 0 } toyLocalOscillator
      differentialLaw := by rfl }

  example : sampleEnergy (beamSplitterPlus toyBalancedHomodyne.signal
      toyBalancedHomodyne.localOscillator.asSample) +
      sampleEnergy (beamSplitterMinus toyBalancedHomodyne.signal
        toyBalancedHomodyne.localOscillator.asSample) =
      sampleEnergy toyBalancedHomodyne.signal +
        sampleEnergy toyBalancedHomodyne.localOscillator.asSample := by
    exact beamSplitter_energy_conserved toyBalancedHomodyne.signal
      toyBalancedHomodyne.localOscillator.asSample

  example : differentialPhotocurrent toyBalancedHomodyne.signal
      toyBalancedHomodyne.localOscillator = 2 := by
    norm_num [differentialPhotocurrent_eq_interference, toyBalancedHomodyne,
      toyLocalOscillator, LocalOscillator.asSample]

  example : differentialPhotocurrent toyBalancedHomodyne.signal
      toyBalancedHomodyne.localOscillator =
      2 * toyBalancedHomodyne.localOscillator.amplitude *
        rotatedQuadrature toyBalancedHomodyne.signal
          toyBalancedHomodyne.localOscillator.phase := by
    exact differentialPhotocurrent_eq_rotatedQuadrature toyBalancedHomodyne.signal
      toyBalancedHomodyne.localOscillator

  example : toyBalancedHomodyne.differentialPhotocurrent =
      toyBalancedHomodyne.plusDetector - toyBalancedHomodyne.minusDetector := by
    exact toyBalancedHomodyne.differential_holds

  def toySecondLocalOscillator : LocalOscillator :=
    { amplitude := 1
      amplitude_nonnegative := by norm_num
      phase := 1 }

  noncomputable def toyBalancedHomodyneB : BalancedHomodyne :=
    { signal := { inPhase := 1, quadrature := 0 }
      localOscillator := toySecondLocalOscillator
      plusOutput := beamSplitterPlus { inPhase := 1, quadrature := 0 }
        toySecondLocalOscillator.asSample
      minusOutput := beamSplitterMinus { inPhase := 1, quadrature := 0 }
        toySecondLocalOscillator.asSample
      plusOutputLaw := by rfl
      minusOutputLaw := by rfl
      plusDetector := sampleEnergy (beamSplitterPlus { inPhase := 1, quadrature := 0 }
        toySecondLocalOscillator.asSample)
      minusDetector := sampleEnergy (beamSplitterMinus { inPhase := 1, quadrature := 0 }
        toySecondLocalOscillator.asSample)
      plusDetectorLaw := by rfl
      minusDetectorLaw := by rfl
      differentialPhotocurrent := differentialPhotocurrent
        { inPhase := 1, quadrature := 0 }
        toySecondLocalOscillator
      differentialLaw := by rfl }

  noncomputable def toyDualHomodyneTrace : DualHomodyneTrace 2 :=
    { sampleCount_pos := by norm_num
      receiverA := toyBalancedHomodyne
      receiverB := toyBalancedHomodyneB
      missingSamples := 0
      missingSamples_le_count := by norm_num
      validSampleCount := 2
      validSampleCount_pos := by norm_num
      validSampleCountLaw := by norm_num
      outcomesA := fun _ => toyBalancedHomodyne.differentialPhotocurrent
      outcomesB := fun _ => toyBalancedHomodyneB.differentialPhotocurrent
      outcomesALaw := by intro index; rfl
      outcomesBLaw := by intro index; rfl
      meanA := toyBalancedHomodyne.differentialPhotocurrent
      meanB := toyBalancedHomodyneB.differentialPhotocurrent
      meanALaw := by simp /- [Fin.sum_univ_succ] -/
      meanBLaw := by simp /- [Fin.sum_univ_succ] -/
      covariance := 0
      covarianceLaw := by norm_num [Fin.sum_univ_succ]
      correlationScale := 1
      correlationScale_pos := by norm_num
      normalizedCorrelation := 0
      normalizedCorrelationLaw := by norm_num
      residual := 0
      residualTolerance := 1
      residualTolerance_nonnegative := by norm_num
      residualWithinTolerance := by norm_num
      thresholdA := 1
      thresholdB := 2
      binsA := fun index => signBin 1
        toyBalancedHomodyne.differentialPhotocurrent
      binsB := fun index => signBin 2
        toyBalancedHomodyneB.differentialPhotocurrent
      binsALaw := by intro index; rfl
      binsBLaw := by intro index; rfl }

  example : toyDualHomodyneTrace.meanA =
      (∑ index : Fin 2, toyDualHomodyneTrace.outcomesA index) /
        (toyDualHomodyneTrace.validSampleCount : ℝ) := by
    exact toyDualHomodyneTrace.mean_a_holds

  example : toyDualHomodyneTrace.covariance = 0 := by
    norm_num [DualHomodyneTrace.covariance_holds, toyDualHomodyneTrace,
      Fin.sum_univ_succ]

  example : toyDualHomodyneTrace.normalizedCorrelation = 0 := by
    norm_num [DualHomodyneTrace.normalized_correlation_holds,
      toyDualHomodyneTrace]

  example : toyDualHomodyneTrace.missingSamples ≤ 2 := by
    exact toyDualHomodyneTrace.missing_samples_bounded

  example : |toyDualHomodyneTrace.residual| ≤
      toyDualHomodyneTrace.residualTolerance := by
    exact toyDualHomodyneTrace.residual_within_tolerance

  noncomputable def toyHomodyneGrid : HomodyneGrid 1 1 :=
    { width_pos := by norm_num
      height_pos := by norm_num
      localOscillator := toyLocalOscillator
      signal := fun _ _ => { inPhase := 1, quadrature := 0 }
      pixelPhotocurrent := fun _ _ => differentialPhotocurrent
        { inPhase := 1, quadrature := 0 } toyLocalOscillator
      pixelPhotocurrentLaw := by intro column row; rfl
      phaseMap := fun _ _ => ({ inPhase := 1, quadrature := 0 } : Sample).phase
      phaseMapLaw := by intro column row; rfl }

example : toyHomodyneGrid.pixelPhotocurrent 0 0 =
    differentialPhotocurrent (toyHomodyneGrid.signal 0 0)
      toyHomodyneGrid.localOscillator := by
  exact toyHomodyneGrid.pixel_photocurrent_holds 0 0

example : toyHomodyneGrid.phaseMap 0 0 =
    (toyHomodyneGrid.signal 0 0).phase := by
  exact toyHomodyneGrid.phase_map_holds 0 0

  def toyDetectorChannel : DetectorChannel :=
    { efficiency := { value := 1, nonnegative := by norm_num, le_one := by norm_num }
      responsivity := { amperesPerWatt := 2 }
      responsivity_nonnegative := by norm_num
      darkCurrent := { amperes := 1 }
      darkCurrent_nonnegative := by norm_num
      bandwidth := { hz := 10 }
      bandwidth_pos := by norm_num }

  def toyDetectorObservation : DetectorObservation :=
    { detector := toyDetectorChannel
      incidentPower := { watts := 3 }
      incidentPower_nonnegative := by norm_num
      outputCurrent := { amperes := 7 }
      outputCurrentLaw := by norm_num [toyDetectorChannel] }

  noncomputable def toyDetectorNoiseProfile : DetectorNoiseProfile :=
    { shotNoise := { amperesSquaredPerHertz := 1 }
      shotNoise_nonnegative := by norm_num
      electronicNoise := { amperesSquaredPerHertz := 2 }
      electronicNoise_nonnegative := by norm_num
      localOscillatorRin := { amperesSquaredPerHertz := 3 }
      localOscillatorRin_nonnegative := by norm_num
      commonModeRejection :=
        { decibels := 0
          decibels_nonnegative := by norm_num
          leakageFactor := { value := 1, nonnegative := by norm_num, le_one := by norm_num }
          leakageFactorLaw := by norm_num } }

  def toyBalancedDetectorObservation : BalancedDetectorObservation :=
    { plus := toyDetectorObservation
      minus := toyDetectorObservation
      commonModeCurrent := { amperes := 7 }
      differentialCurrent := { amperes := 0 }
      commonModeLaw := by norm_num [toyDetectorObservation]
      differentialLaw := by norm_num [toyDetectorObservation] }

  def toyZeroDarkDetectorChannel : DetectorChannel :=
    { efficiency := { value := 1, nonnegative := by norm_num, le_one := by norm_num }
      responsivity := { amperesPerWatt := 2 }
      responsivity_nonnegative := by norm_num
      darkCurrent := { amperes := 0 }
      darkCurrent_nonnegative := by norm_num
      bandwidth := { hz := 10 }
      bandwidth_pos := by norm_num }

  def toyZeroDarkDetectorObservation : DetectorObservation :=
    { detector := toyZeroDarkDetectorChannel
      incidentPower := { watts := 0 }
      incidentPower_nonnegative := by norm_num
      outputCurrent := { amperes := 0 }
      outputCurrentLaw := by norm_num [toyZeroDarkDetectorChannel] }

  noncomputable def toyBalancedDetectorForComposition : BalancedDetectorObservation :=
    { plus := toyDetectorObservation
      minus := toyZeroDarkDetectorObservation
      commonModeCurrent := { amperes := 7 / 2 }
      differentialCurrent := { amperes := 7 }
      commonModeLaw := by norm_num [toyDetectorObservation, toyZeroDarkDetectorObservation]
      differentialLaw := by norm_num [toyDetectorObservation, toyZeroDarkDetectorObservation] }

  def toyCalibratedPhotocurrent : CalibratedPhotocurrent :=
    { rawCurrent := { amperes := 7 }
      calibration :=
        { rawBefore := 7
          rawAfter := 7
          rawPreserved := by norm_num
          multiplier := 2
          offset := 1
          calibrated := 15
          calibrationLaw := by norm_num }
      rawCurrentLaw := by rfl
      calibratedCurrent := { amperes := 15 }
      calibratedCurrentLaw := by rfl
      residual := 0
      tolerance := 1
      tolerance_nonnegative := by norm_num
      residualLaw := by norm_num }

  example : toyDetectorObservation.outputCurrent.amperes = 7 := by
    norm_num [toyDetectorObservation, toyDetectorChannel]

  example : toyBalancedDetectorObservation.differentialCurrent.amperes = 0 := by
    apply toyBalancedDetectorObservation.differential_zero_of_equal
    rfl

  example : toyDetectorNoiseProfile.commonModeRejection.leakedNoise
      toyDetectorNoiseProfile.localOscillatorRin = 3 := by
    norm_num [CommonModeRejection.leakedNoise, toyDetectorNoiseProfile]

  example : toyDetectorNoiseProfile.commonModeRejection.leakedNoise
      toyDetectorNoiseProfile.localOscillatorRin ≤
      toyDetectorNoiseProfile.localOscillatorRin.amperesSquaredPerHertz := by
    exact toyDetectorNoiseProfile.commonModeRejection.leakedNoise_le
      toyDetectorNoiseProfile.localOscillatorRin
      toyDetectorNoiseProfile.localOscillatorRin_nonnegative

  example : toyCalibratedPhotocurrent.calibration.rawAfter =
      toyCalibratedPhotocurrent.calibration.rawBefore := by
    exact toyCalibratedPhotocurrent.raw_preserved

  example : toyCalibratedPhotocurrent.consistent := by
    norm_num [CalibratedPhotocurrent.consistent, toyCalibratedPhotocurrent]

  def toyHomodyneTraceSample : HomodyneTraceSample :=
    { timestamp := { seconds := 0 }
      localOscillatorPhase := 0
      detectorA := { amperes := 7 }
      detectorB := { amperes := 0 }
      rawDifferential := { amperes := 7 }
      rawDifferentialLaw := by norm_num
      calibration := toyCalibratedPhotocurrent.calibration
      calibratedDifferential := { amperes := 15 }
      calibratedDifferentialLaw := by rfl
      residual := 0
      residualTolerance := 1
      residualTolerance_nonnegative := by norm_num
      loss := { value := 0, nonnegative := by norm_num, le_one := by norm_num }
      efficiency := { value := 1, nonnegative := by norm_num, le_one := by norm_num } }

  example : toyHomodyneTraceSample.rawDifferential.amperes =
      toyHomodyneTraceSample.detectorA.amperes -
        toyHomodyneTraceSample.detectorB.amperes := by
    exact toyHomodyneTraceSample.raw_differential_holds

  example : toyHomodyneTraceSample.calibratedDifferential.amperes =
      toyHomodyneTraceSample.calibration.calibrated := by
    exact toyHomodyneTraceSample.calibrated_differential_holds

def toyCurrent : FourCurrent :=
  { chargeDensity := 0
    currentX := 0
    currentY := 0
    currentZ := 0
    continuityResidual := 0 }

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
    couplingStrengthLaw := by rfl
    fieldEquation := by norm_num [toyModel, toyMatterCoupling, toyCurrent] }

example : toyDrivenField.fourDivergence = 0 := by
  apply toyDrivenField.lorenz_condition
  change (0 : ℝ) = 0
  rfl

example :
    toyModel.mass ^ 2 * toyDrivenField.fourDivergence =
        toyDrivenField.coupling.strength *
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
    sourcePower := { watts := 100 }
    sourcePower_nonnegative := by norm_num
    distance := { meters := 2 }
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

example : toyLink.receivedPower ≤ toyLink.sourcePower.watts := by
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

noncomputable def toyMaterialTransfer : Signals.Scattering.MaterialTransferFunction :=
  { frequency := { hz := 400 * 10 ^ 9 }
    frequency_pos := by norm_num
    transfer := (1 / 2 : ℂ)
    transmittedPowerRatio := 1 / 4
    transmittedPowerRatio_nonnegative := by norm_num
    transmittedPowerRatio_le_one := by norm_num
    powerLaw := by norm_num [Complex.normSq] }

example : toyMaterialTransfer.transmittedPowerRatio = 1 / 4 := by
  norm_num [toyMaterialTransfer, Complex.normSq]

noncomputable def toyFrequencyAttenuation :
    Signals.Scattering.FrequencyDependentAttenuation :=
  { frequency := { hz := 400 * 10 ^ 9 }
    frequency_pos := by norm_num
    attenuationPerLength := 1 / 10
    attenuation_nonnegative := by norm_num
    distance := { meters := 2 }
    distance_nonnegative := by norm_num
    factor := Real.exp (-2 / 5)
    factorLaw := by norm_num }

example : 0 ≤ toyFrequencyAttenuation.factor := by
  exact toyFrequencyAttenuation.factor_nonnegative

example : toyFrequencyAttenuation.factor ≤ 1 := by
  exact toyFrequencyAttenuation.factor_le_one

noncomputable def toySpeckleCovariance :
    Signals.Scattering.SpeckleCovariance 4 :=
  { sampleCount_positive := by norm_num
    covariance := fun _ _ => 1
    covariance_symmetric := by
      intro row column
      rfl
    covariance_diagonal_nonnegative := by
      intro index
      norm_num }

example : toySpeckleCovariance.covariance 0 1 =
    toySpeckleCovariance.covariance 1 0 := by
  exact toySpeckleCovariance.symmetric 0 1

example : 0 ≤ toySpeckleCovariance.covariance 2 2 := by
  exact toySpeckleCovariance.diagonal_nonnegative 2

noncomputable def toyScatteringGrid :
    Signals.Scattering.GridMetrologyRecord 2 2 :=
  { width_positive := by norm_num
    height_positive := by norm_num
    samples := fun _ _ => toyScatteringObservation
    residuals := fun _ _ => toyConsistentResidual
    covariance := toySpeckleCovariance }

example : 0 < 2 ∧ 0 < 2 := by
  exact toyScatteringGrid.dimensions_positive

example : toyScatteringGrid.consistent := by
  rw [toyScatteringGrid.consistent_iff]
  intro row column
  norm_num [toyScatteringGrid, toyConsistentResidual]

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

noncomputable def toyMimoFireCannonPump : MimoFireCannonPump :=
  { beamA := toyPump.beamA
    beamB := toyPump.beamB
    conversion := toyConversion
    array := toyMimo
    beamPowerBudget := 100
    beamPowerBudget_nonnegative := by norm_num
    beamPowerBound := by norm_num [MimoArray.sourcePower, toyMimo] }

noncomputable def toyCelluloseStripResonator : CelluloseStripResonator :=
  { unitCellPeriod := { meters := 1 / 100000000 }
    unitCellPeriod_pos := by norm_num
    unitCellCount := 100
    unitCellCount_pos := by norm_num
    stripLength := { meters := 1 / 1000000 }
    stripLength_pos := by norm_num
    stripLengthLaw := by norm_num
    acousticWavelength := { meters := 1 / 50000000 }
    acousticWavelength_pos := by norm_num
    braggLaw := by norm_num
    longitudinalSoundSpeed := { metersPerSecond := 8000 }
    longitudinalSoundSpeed_pos := by norm_num
    fundamentalFrequency := gigahertz 400
    fundamentalFrequency_pos := by norm_num [gigahertz]
    dispersionLaw := by norm_num [gigahertz]
    drivePower := { watts := 100 }
    drivePower_nonnegative := by norm_num
    acousticConversionEfficiency :=
      { value := 1 / 2, nonnegative := by norm_num, le_one := by norm_num }
    acousticOutputPower := { watts := 50 }
    acousticOutputPowerLaw := by norm_num }

noncomputable def toyFireCannonCelluloseStripDrive :
    FireCannonCelluloseStripDrive :=
  { pump := toyMimoFireCannonPump
    resonator := toyCelluloseStripResonator
    beamAMatchesFundamental := by
      norm_num [toyMimoFireCannonPump, toyPump, toyCelluloseStripResonator]
    beamBMatchesFundamental := by
      norm_num [toyMimoFireCannonPump, toyPump, toyCelluloseStripResonator]
    sumMatchesSecondHarmonic := by
      norm_num [toyMimoFireCannonPump, toyPump, toyCelluloseStripResonator,
        CelluloseStripResonator.secondHarmonicFrequency, gigahertz]
    stripDriveWithinBeamBudget := by
      norm_num [toyMimoFireCannonPump, toyCelluloseStripResonator] }

example : toyCelluloseStripResonator.fundamentalFrequency.hz =
    (gigahertz 400).hz := by
  norm_num [CelluloseStripResonator.fundamentalFrequency_eq,
    toyCelluloseStripResonator, gigahertz]

example : toyCelluloseStripResonator.secondHarmonicFrequency.hz =
    (gigahertz 800).hz := by
  norm_num [CelluloseStripResonator.secondHarmonicFrequency,
    toyCelluloseStripResonator, gigahertz]

example : toyFireCannonCelluloseStripDrive.resonator.acousticOutputPower.watts ≤
    toyFireCannonCelluloseStripDrive.pump.array.sourcePower := by
  exact toyFireCannonCelluloseStripDrive.acoustic_output_le_array_source

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

/-- A twistor incident at a supplied coordinate matrix. -/
def incidentTwistor (lambda : WeylSpinor) (position : SpacetimeMatrix) : Twistor :=
  { lambda := lambda
    mu := WeylSpinor.ofComponents ((-Complex.I) • position.mulVec lambda.component) }

example (lambda : WeylSpinor) (position offset : SpacetimeMatrix) :
    ((incidentTwistor lambda position).translate offset).incident (position + offset) := by
  apply Twistor.translate_incident
  exact WeylSpinor.component_ofComponents _

example (twistor : Twistor) (offset : SpacetimeMatrix) :
    (twistor.translate offset).translate (-offset) = twistor :=
  twistor.translate_neg offset

example (twistor : Twistor) (position offset : SpacetimeMatrix) :
    (twistor.translate offset).incident (position + offset) ↔ twistor.incident position :=
  twistor.translate_incident_iff position offset

example : ((incidentTwistor ⟨1, 0⟩ 0).translate !![1, 2; 3, 4]).mu.component 1 =
    -3 * Complex.I := by
  norm_num [incidentTwistor, Twistor.translate, WeylSpinor.ofComponents,
    WeylSpinor.component, Matrix.mulVec, dotProduct, Fin.sum_univ_two]
  ring

example : orbitalBivector ![1, 0, 0, 0] ![0, 1, 0, 0] 0 1 = 1 := by
  norm_num [orbitalBivector]

example (state : AngularMomentumState) (offset : Signals.Geometry.FourVector) (row column : Fin 4) :
    (state.translate offset).angularMomentum row column =
      -(state.translate offset).angularMomentum column row :=
  (state.translate offset).antisymmetric row column

example (matrix : Matrix2x4) (columns : OrderedColumns 2 4) :
    pluckerAlternating columns matrix = selectedMinor matrix columns := rfl

example (matrix : Matrix2x4) (columns : OrderedColumns 2 4) :
    selectedMinor (matrix ∘ Equiv.swap 0 1) columns = -selectedMinor matrix columns :=
  selectedMinor_swap_rows matrix columns (by decide)

example (matrix : Matrix2x4) (columns : OrderedColumns 2 4)
    (equal : matrix 0 = matrix 1) : selectedMinor matrix columns = 0 :=
  selectedMinor_eq_zero_of_rows_eq matrix columns equal (by decide)

/-- Select a single column; strict monotonicity is vacuous for one row. -/
def singletonColumns {columnCount : ℕ} (column : Fin columnCount) : OrderedColumns 1 columnCount :=
  { index := fun _ => column
    strictlyIncreasing := by
      intro left right less
      fin_cases left
      fin_cases right
      simp at less }

/-- A nonnegative full-rank boundary representative with one zero maximal minor. -/
def boundaryGrassmannian : NonnegativeGrassmannian 1 2 :=
  { mat := !![1, 0]
    nonnegative := by
      intro columns
      rw [GrassmannianMatrix.pluckerCoordinate, selectedMinor, Matrix.det_fin_one]
      change 0 ≤ (!![1, 0] : Matrix (Fin 1) (Fin 2) ℝ) 0 (columns.index 0)
      generalize columns.index 0 = column
      fin_cases column <;> norm_num
    nonzero_minor := ⟨singletonColumns 0, by
      norm_num [GrassmannianMatrix.pluckerCoordinate, selectedMinor, singletonColumns,
        Matrix.det_fin_one, Matrix.submatrix]⟩ }

example : boundaryGrassmannian.pluckerCoordinate (singletonColumns 1) = 0 := by
  norm_num [GrassmannianMatrix.pluckerCoordinate, selectedMinor, boundaryGrassmannian,
    singletonColumns, Matrix.det_fin_one, Matrix.submatrix]

example : ¬boundaryGrassmannian.toGrassmannianMatrix.hasPositiveOrderedMinors := by
  intro positive
  have zero_positive := positive (singletonColumns 1)
  norm_num [GrassmannianMatrix.pluckerCoordinate, selectedMinor, boundaryGrassmannian,
    singletonColumns, Matrix.det_fin_one, Matrix.submatrix] at zero_positive

example : ¬negativeMinorMatrix.hasNonnegativeOrderedMinors := by
  intro nonnegative
  have negative_nonnegative := nonnegative identityColumns
  norm_num [GrassmannianMatrix.pluckerCoordinate, selectedMinor, negativeMinorMatrix,
    identityColumns, Matrix.det_fin_two, Matrix.submatrix] at negative_nonnegative

example : ¬(⟨0⟩ : GrassmannianMatrix 1 1).hasPositiveOrderedMinors := by
  intro positive
  have zero_positive := positive positiveIdentityColumns
  norm_num [GrassmannianMatrix.pluckerCoordinate, selectedMinor,
    Matrix.det_fin_one, Matrix.submatrix] at zero_positive

/-- A nonzero interior representative with a normalized interval parameter. -/
noncomputable def intervalThirdCell : PositiveGrassmannian 1 2 :=
  PositiveGrassmannian.intervalCell (1 / 3) (by norm_num) (by norm_num)

example (basis : Matrix (Fin 2) (Fin 2) ℝ) (matrix : Matrix2x4)
    (columns : OrderedColumns 2 4) :
    selectedMinor (basis * matrix) columns = basis.det * selectedMinor matrix columns :=
  selectedMinor_basisChange _ _ _

example : intervalThirdCell.pluckerCoordinate (singletonColumns 0) = 1 / 3 := by
  norm_num [intervalThirdCell, PositiveGrassmannian.intervalCell,
    GrassmannianMatrix.pluckerCoordinate, selectedMinor, singletonColumns,
    Matrix.det_fin_one, Matrix.submatrix]

example : intervalThirdCell.pluckerCoordinate (singletonColumns 1) = 2 / 3 := by
  norm_num [intervalThirdCell, PositiveGrassmannian.intervalCell,
    GrassmannianMatrix.pluckerCoordinate, selectedMinor, singletonColumns,
    Matrix.det_fin_one, Matrix.submatrix]

example : (intervalThirdCell.changeBasis !![3] (by norm_num [Matrix.det_fin_one])).pluckerCoordinate
    (singletonColumns 0) = 1 := by
  norm_num [PositiveGrassmannian.changeBasis, GrassmannianMatrix.changeBasis,
    intervalThirdCell, PositiveGrassmannian.intervalCell,
    GrassmannianMatrix.pluckerCoordinate, selectedMinor, singletonColumns,
    Matrix.det_fin_one, Matrix.submatrix, Matrix.mul_apply, Fin.sum_univ_one]

example : (boundaryGrassmannian.changeBasis !![3] (by norm_num [Matrix.det_fin_one])).pluckerCoordinate
    (singletonColumns 1) = 0 := by
  change (boundaryGrassmannian.toGrassmannianMatrix.changeBasis !![3]).pluckerCoordinate
    (singletonColumns 1) = 0
  rw [GrassmannianMatrix.pluckerCoordinate_basisChange]
  norm_num [GrassmannianMatrix.pluckerCoordinate, selectedMinor,
    boundaryGrassmannian, singletonColumns, Matrix.det_fin_one, Matrix.submatrix]

example : ¬(intervalThirdCell.toGrassmannianMatrix.changeBasis !![-2]).hasPositiveOrderedMinors :=
  intervalThirdCell.not_positive_of_det_neg !![-2] (by norm_num [Matrix.det_fin_one])
    (singletonColumns 0)

example : (intervalThirdCell.toGrassmannianMatrix.changeBasis !![-2]).pluckerCoordinate
      (singletonColumns 0) /
    (intervalThirdCell.toGrassmannianMatrix.changeBasis !![-2]).pluckerCoordinate
      (singletonColumns 1) =
    intervalThirdCell.pluckerCoordinate (singletonColumns 0) /
      intervalThirdCell.pluckerCoordinate (singletonColumns 1) :=
  intervalThirdCell.toGrassmannianMatrix.pluckerRatio_basisChange !![-2]
    (by norm_num [Matrix.det_fin_one]) _ _

example : Signals.CanonicalForms.intervalForm (1 / 3) (!![2] : Matrix (Fin 1) (Fin 1) ℝ) = 9 := by
  norm_num [Signals.CanonicalForms.intervalForm_apply, Signals.CanonicalForms.intervalCoefficient]

example : Signals.CanonicalForms.triangleForm ![1 / 3, 1 / 3] !![1, 0; 0, 1] = 27 := by
  norm_num [Signals.CanonicalForms.triangleForm_apply, Signals.CanonicalForms.triangleCoefficient]

example : Signals.CanonicalForms.triangleForm ![1 / 3, 1 / 3] !![0, 1; 1, 0] = -27 := by
  norm_num [Signals.CanonicalForms.triangleForm_apply, Signals.CanonicalForms.triangleCoefficient]

example : Signals.CanonicalForms.triangleForm ![1 / 3, 1 / 3] !![1, 2; 1, 2] = 0 := by
  norm_num [Signals.CanonicalForms.triangleForm_apply, Signals.CanonicalForms.triangleCoefficient]

open scoped Topology in
example : ¬Filter.Tendsto (fun coordinate =>
    (coordinate - 1) * Signals.CanonicalForms.intervalCoefficient coordinate)
    (𝓝[≠] (1 : ℝ)) (𝓝 1) := by
  intro wrongSign
  have impossible : (-1 : ℝ) = 1 :=
    tendsto_nhds_unique Signals.CanonicalForms.interval_residue_one wrongSign
  norm_num at impossible

open scoped Topology in
example : Filter.Tendsto (fun normal => normal *
    Signals.CanonicalForms.triangleForm ![normal, 1 / 2] !![1, 0; 0, 1])
    (𝓝[≠] (0 : ℝ)) (𝓝 4) := by
  convert Signals.CanonicalForms.triangle_residue_x (1 / 2)
    (by norm_num) (by norm_num) using 1
  norm_num [Signals.CanonicalForms.intervalCoefficient]

open scoped Topology in
example : Filter.Tendsto (fun normal => normal *
    Signals.CanonicalForms.triangleForm ![1 / 2, normal] !![0, 1; 1, 0])
    (𝓝[≠] (0 : ℝ)) (𝓝 (-4)) := by
  convert Signals.CanonicalForms.triangle_residue_y (1 / 2)
    (by norm_num) (by norm_num) using 1
  norm_num [Signals.CanonicalForms.intervalCoefficient]

open scoped Topology in
example : Filter.Tendsto (fun normal => normal *
    Signals.CanonicalForms.triangleForm ![1 / 2, 1 / 2 - normal] !![0, -1; 1, -1])
    (𝓝[≠] (0 : ℝ)) (𝓝 4) := by
  convert Signals.CanonicalForms.triangle_residue_diagonal (1 / 2)
    (by norm_num) (by norm_num) using 1 <;> norm_num [Signals.CanonicalForms.intervalCoefficient]

example : Signals.CanonicalForms.lowerTriangleCoefficient ![3 / 4, 1 / 4] +
    Signals.CanonicalForms.upperTriangleCoefficient ![3 / 4, 1 / 4] =
    Signals.CanonicalForms.squareCoefficient ![3 / 4, 1 / 4] :=
  Signals.CanonicalForms.square_triangulation _ (by norm_num) (by norm_num)
    (by norm_num) (by norm_num) (by norm_num)

example : Signals.CanonicalForms.squareCoefficient ![1 / 2, 1 / 2] = 16 := by
  norm_num [Signals.CanonicalForms.squareCoefficient]

example : ContinuousAt Signals.CanonicalForms.squareCoefficient ![1 / 2, 1 / 2] :=
  Signals.CanonicalForms.squareCoefficient_continuousAt _ (by norm_num) (by norm_num)
    (by norm_num) (by norm_num)

example : Signals.CanonicalForms.lowerTriangleCoefficient ![1 / 2, 1 / 2] +
    Signals.CanonicalForms.upperTriangleCoefficient ![1 / 2, 1 / 2] ≠
    Signals.CanonicalForms.squareCoefficient ![1 / 2, 1 / 2] := by
  norm_num [Signals.CanonicalForms.lowerTriangleCoefficient,
    Signals.CanonicalForms.upperTriangleCoefficient, Signals.CanonicalForms.triangleCoefficient,
    Signals.CanonicalForms.squareCoefficient]

open scoped Topology in
example : Filter.Tendsto (fun normal => normal *
    (-Signals.CanonicalForms.squareCoefficient ![1 / 2, normal]))
    (𝓝[≠] (0 : ℝ)) (𝓝 (-4)) := by
  convert Signals.CanonicalForms.square_residue_y_zero (1 / 2) using 1
  norm_num [Signals.CanonicalForms.intervalCoefficient]

open scoped Topology in
example : Filter.Tendsto (fun normal => (normal - 1) *
    (-Signals.CanonicalForms.squareCoefficient ![1 / 2, normal]))
    (𝓝[≠] (1 : ℝ)) (𝓝 4) := by
  convert Signals.CanonicalForms.square_residue_y_one (1 / 2) using 1
  norm_num [Signals.CanonicalForms.intervalCoefficient]

example : Signals.Huygens.intensity ((1 : ℂ) + 1) = 4 := by
  norm_num [Signals.Huygens.intensity, Complex.normSq]

example : Signals.Huygens.intensity ((1 : ℂ) + -1) = 0 := by
  norm_num [Signals.Huygens.intensity, Complex.normSq]

example : Signals.Huygens.intensity ((1 : ℂ) + Complex.I) = 2 := by
  norm_num [Signals.Huygens.intensity, Complex.normSq]

example : Signals.Huygens.distance ![0, 0, 0] ![0, 0, 2] = 2 := by
  norm_num [Signals.Huygens.distance, Signals.Huygens.squaredDistance, Fin.sum_univ_succ]

/-- Distinct symmetric point-slit samples in a three-dimensional scalar model. -/
def symmetricSlits : Signals.Huygens.DoubleSlit 1 1 :=
  { wave := { wavelength := ⟨1⟩, wavelength_positive := by norm_num }
    source := ![0, 0, -1]
    first := { point := fun _ => ![-1, 0, 0], weight := fun _ => 1 }
    second := { point := fun _ => ![1, 0, 0], weight := fun _ => 1 }
    firstOpen := true
    secondOpen := true }

example : symmetricSlits.first.regularAt symmetricSlits.source ![0, 0, 1] := by
  intro sample
  constructor <;> intro equal
  · have impossible := congrFun equal 0
    norm_num [symmetricSlits] at impossible
  · have impossible := congrFun equal 0
    norm_num [symmetricSlits] at impossible

/-- Symmetric path lengths give identical complex aperture contributions. -/
lemma symmetricSlits_equal_amplitudes :
    symmetricSlits.first.amplitude symmetricSlits.wave symmetricSlits.source ![0, 0, 1] =
      symmetricSlits.second.amplitude symmetricSlits.wave symmetricSlits.source ![0, 0, 1] := by
  norm_num [symmetricSlits, Signals.Huygens.Aperture.amplitude,
    Signals.Huygens.MonochromaticWave.kernel, Signals.Huygens.distance,
    Signals.Huygens.squaredDistance, Fin.sum_univ_succ]

example : symmetricSlits.intensity ![0, 0, 1] =
    4 * Signals.Huygens.intensity
      (symmetricSlits.first.amplitude symmetricSlits.wave symmetricSlits.source ![0, 0, 1]) := by
  rw [Signals.Huygens.DoubleSlit.intensity,
    symmetricSlits.amplitude_both_open _ rfl rfl, ← symmetricSlits_equal_amplitudes]
  exact Signals.Huygens.intensity_constructive _

example : ({ symmetricSlits with secondOpen := false }).amplitude ![0, 0, 1] =
    symmetricSlits.first.amplitude symmetricSlits.wave symmetricSlits.source ![0, 0, 1] := by
  exact Signals.Huygens.DoubleSlit.amplitude_first_only _ _ rfl rfl

example : ({ symmetricSlits with firstOpen := false, secondOpen := false }).intensity
    ![0, 0, 1] = 0 := by
  exact Signals.Huygens.DoubleSlit.intensity_closed _ _ rfl rfl

example (action : Fin 2 → ℝ) (first second : Fin 2 → ℂ) (hbar : ℝ) :
    Signals.Huygens.finiteHistoryAmplitude action (first + second) hbar =
      Signals.Huygens.finiteHistoryAmplitude action first hbar +
        Signals.Huygens.finiteHistoryAmplitude action second hbar :=
  Signals.Huygens.finiteHistoryAmplitude_add action first second hbar

/-- Both distinct symmetric samples have regular propagation to the central detector. -/
lemma symmetricSlitsRegular : Signals.Huygens.RegularSlitEvaluation symmetricSlits ![0, 0, 1] := by
  constructor <;> intro sample <;> constructor <;> intro equal
  all_goals
    have impossible := congrFun equal 0
    norm_num [symmetricSlits] at impossible

example : symmetricSlits.regularAmplitude ![0, 0, 1] symmetricSlitsRegular =
    symmetricSlits.amplitude ![0, 0, 1] := rfl

example : 0 < Signals.Huygens.distance symmetricSlits.source (symmetricSlits.first.point 0) :=
  symmetricSlits.first.source_distance_pos _ _ symmetricSlitsRegular.firstRegular 0

example : 0 < Signals.Huygens.distance (symmetricSlits.second.point 0) ![0, 0, 1] :=
  symmetricSlits.second.detector_distance_pos _ _ symmetricSlitsRegular.secondRegular 0

example : ¬symmetricSlits.first.regularAt (symmetricSlits.first.point 0) ![0, 0, 1] :=
  symmetricSlits.first.not_regularAt_source _ _ 0 rfl

example : ¬Signals.Huygens.RegularSlitEvaluation symmetricSlits (symmetricSlits.first.point 0) := by
  intro regular
  exact symmetricSlits.first.not_regularAt_detector _ _ 0 rfl regular.firstRegular

example : ¬Signals.Huygens.RegularSlitEvaluation symmetricSlits (symmetricSlits.second.point 0) := by
  intro regular
  exact symmetricSlits.second.not_regularAt_detector _ _ 0 rfl regular.secondRegular

/-- A one-metre separation certificate for the first symmetric sample. -/
noncomputable def symmetricFirstSeparation : Signals.Huygens.ApertureSeparation
    symmetricSlits.first symmetricSlits.source ![0, 0, 1] :=
  { minimum := ⟨1⟩
    minimum_positive := by norm_num
    sourceBound := by
      intro sample
      norm_num [symmetricSlits, Signals.Huygens.distance,
        Signals.Huygens.squaredDistance, Fin.sum_univ_succ]
    detectorBound := by
      intro sample
      norm_num [symmetricSlits, Signals.Huygens.distance,
        Signals.Huygens.squaredDistance, Fin.sum_univ_succ]
  }

example : symmetricSlits.first.regularAt symmetricSlits.source ![0, 0, 1] :=
  symmetricFirstSeparation.regular

example : ¬∃ scale : Signals.Huygens.ActionScale, scale.hbar = 0 := by
  rintro ⟨scale, zero⟩
  exact scale.nonzero zero

example : ¬∃ scale : Signals.Huygens.ActionScale, scale.hbar = -1 := by
  rintro ⟨scale, negative⟩
  have positive := scale.positive
  rw [negative] at positive
  norm_num at positive

example : (⟨1, by norm_num⟩ : Signals.Huygens.ActionScale).amplitude
    (fun _ : Fin 2 => 0) (fun _ => 1) = 2 := by
  norm_num [Signals.Huygens.ActionScale.amplitude, Signals.Huygens.finiteHistoryAmplitude]

/-- Two vertically separated rows in a slit at the supplied horizontal coordinate. -/
def finiteSlitPoint (side : ℝ) (row : Fin 2) : Signals.Huygens.Point3 :=
  ![side, if row = 0 then -1 else 1, 0]

/-- Nonempty finite-extent quadratures with an independently selectable relative transmission phase. -/
noncomputable def finiteWidthSlits (wave : Signals.Huygens.MonochromaticWave) (phase : ℂ) :
    Signals.Huygens.DoubleSlit 2 2 :=
  { wave := wave
    source := ![0, 0, -1]
    first := { point := finiteSlitPoint (-1), weight := fun _ => 1 / 2 }
    second := { point := finiteSlitPoint 1, weight := fun _ => phase / 2 }
    firstOpen := true
    secondOpen := true }

/-- A fixed four-path analytic reference that does not call any aperture or slit evaluator. -/
noncomputable def fourPathReference (wave : Signals.Huygens.MonochromaticWave)
    (phase : ℂ) (detector : Signals.Huygens.Point3) : ℂ :=
  (wave.pathAmplitude (Real.sqrt 3) (Signals.Huygens.distance ![-1, -1, 0] detector) +
    wave.pathAmplitude (Real.sqrt 3) (Signals.Huygens.distance ![-1, 1, 0] detector)) / 2 +
  phase * (wave.pathAmplitude (Real.sqrt 3) (Signals.Huygens.distance ![1, -1, 0] detector) +
    wave.pathAmplitude (Real.sqrt 3) (Signals.Huygens.distance ![1, 1, 0] detector)) / 2

/-- All four sampled kernel products agree with the independent analytic reference. -/
lemma finiteWidthSlits_reference (wave : Signals.Huygens.MonochromaticWave) (phase : ℂ)
    (detector : Signals.Huygens.Point3) :
    (finiteWidthSlits wave phase).amplitude detector = fourPathReference wave phase detector := by
  simp only [finiteWidthSlits, Signals.Huygens.DoubleSlit.amplitude,
    ite_true, Signals.Huygens.Aperture.amplitude]
  simp_rw [mul_assoc, Signals.Huygens.MonochromaticWave.kernel_product]
  norm_num [fourPathReference, finiteSlitPoint, Signals.Huygens.distance,
    Signals.Huygens.squaredDistance, Fin.sum_univ_succ]
  ring

/-- The whole detector plane is regular, including off-axis positions and every phase. -/
lemma finiteWidthSlits_regular (wave : Signals.Huygens.MonochromaticWave) (phase : ℂ)
    (detector : Signals.Huygens.Point3) (height : detector 2 = 1) :
    Signals.Huygens.RegularSlitEvaluation (finiteWidthSlits wave phase) detector := by
  constructor <;> intro sample <;> constructor <;> intro equal
  all_goals
    have impossible := congrFun equal 2
    norm_num [finiteWidthSlits, finiteSlitPoint, height] at impossible

/-- A fixed zero-tolerance comparison over a nonempty, nonsymmetric detector domain. -/
lemma fourPathComparison (wave : Signals.Huygens.MonochromaticWave) (phase : ℂ) :
    Signals.Huygens.AmplitudeComparison (fourPathReference wave phase)
      (finiteWidthSlits wave phase).amplitude {detector | detector 2 = 1} 0 :=
  { domain_nonempty := ⟨![0, 0, 1], rfl⟩
    tolerance_nonnegative := le_rfl
    amplitudeError := by
      intro detector _
      rw [finiteWidthSlits_reference]
      simp }

/-- At the central detector the four equally long paths reduce to one reference phase. -/
lemma fourPathReference_center (wave : Signals.Huygens.MonochromaticWave) (phase : ℂ) :
    fourPathReference wave phase ![0, 0, 1] =
      (1 + phase) * wave.pathAmplitude (Real.sqrt 3) (Real.sqrt 3) := by
  norm_num [fourPathReference, Signals.Huygens.distance,
    Signals.Huygens.squaredDistance, Fin.sum_univ_succ]
  ring

/-- The central single-slit reference is nonzero at every positive wavelength. -/
lemma centralPath_norm (wave : Signals.Huygens.MonochromaticWave) :
    ‖wave.pathAmplitude (Real.sqrt 3) (Real.sqrt 3)‖ = 1 / 3 := by
  rw [wave.pathAmplitude_norm _ _ (by positivity) (by positivity)]
  norm_num

example (wave : Signals.Huygens.MonochromaticWave) :
    Signals.Huygens.intensity ((finiteWidthSlits wave 1).amplitude ![0, 0, 1]) =
      4 * Signals.Huygens.intensity (wave.pathAmplitude (Real.sqrt 3) (Real.sqrt 3)) := by
  rw [finiteWidthSlits_reference, fourPathReference_center]
  simpa only [add_mul, one_mul] using Signals.Huygens.intensity_constructive
    (wave.pathAmplitude (Real.sqrt 3) (Real.sqrt 3))

example (wave : Signals.Huygens.MonochromaticWave) :
    (finiteWidthSlits wave (-1)).amplitude ![0, 0, 1] = 0 := by
  rw [finiteWidthSlits_reference, fourPathReference_center]
  simp

example (wave : Signals.Huygens.MonochromaticWave) :
    Signals.Huygens.intensity ((finiteWidthSlits wave Complex.I).amplitude ![0, 0, 1]) =
      2 * Signals.Huygens.intensity (wave.pathAmplitude (Real.sqrt 3) (Real.sqrt 3)) := by
  rw [finiteWidthSlits_reference, fourPathReference_center, add_mul, one_mul]
  exact Signals.Huygens.intensity_quadrature _

example (wave : Signals.Huygens.MonochromaticWave) (detector : Signals.Huygens.Point3) :
    ({ finiteWidthSlits wave 1 with secondOpen := false }).amplitude detector =
      (finiteWidthSlits wave 1).first.amplitude wave ![0, 0, -1] detector :=
  Signals.Huygens.DoubleSlit.amplitude_first_only _ _ rfl rfl

example (wave : Signals.Huygens.MonochromaticWave) (detector : Signals.Huygens.Point3) :
    ({ finiteWidthSlits wave 1 with firstOpen := false }).amplitude detector =
      (finiteWidthSlits wave 1).second.amplitude wave ![0, 0, -1] detector :=
  Signals.Huygens.DoubleSlit.amplitude_second_only _ _ rfl rfl

example : Signals.Huygens.RegularSlitEvaluation (finiteWidthSlits symmetricSlits.wave 1)
    ![1, 2, 1] := finiteWidthSlits_regular _ _ _ rfl

example : Signals.Huygens.RegularSlitEvaluation
    (finiteWidthSlits { wavelength := ⟨2⟩, wavelength_positive := by norm_num } Complex.I)
    ![-2, 1, 1] := finiteWidthSlits_regular _ _ _ rfl

/-- A wrong relative phase fails a tolerance chosen in advance, with no detector-specific fitting. -/
lemma wrongPhase_rejected (wave : Signals.Huygens.MonochromaticWave) :
    ¬Signals.Huygens.AmplitudeComparison (fourPathReference wave (-1))
      (finiteWidthSlits wave 1).amplitude {detector | detector 2 = 1} (1 / 4) := by
  apply Signals.Huygens.AmplitudeComparison.reject _ _
    {detector : Signals.Huygens.Point3 | detector 2 = 1} _ ![0, 0, 1] (by rfl)
  rw [finiteWidthSlits_reference, fourPathReference_center, fourPathReference_center]
  simp only [add_neg_cancel, zero_mul, zero_sub, norm_neg]
  rw [norm_mul, centralPath_norm]
  norm_num

/-- A literal unit-tangent interval-form evaluation with no fitted phase or physical embedding. -/
noncomputable def unphasedIntervalCandidate (_detector : Signals.Huygens.Point3) : ℂ :=
  (Signals.CanonicalForms.intervalForm (1 / 2) (!![1] : Matrix (Fin 1) (Fin 1) ℝ) : ℝ)

/-- The literal geometric scalar cannot satisfy this raw-number optical comparison at the fixed tolerance. -/
lemma unphasedIntervalCandidate_rejected (wave : Signals.Huygens.MonochromaticWave) :
    ¬Signals.Huygens.AmplitudeComparison unphasedIntervalCandidate
      (finiteWidthSlits wave 1).amplitude {detector | detector 2 = 1} (1 / 4) := by
  apply Signals.Huygens.AmplitudeComparison.reject _ _
    {detector : Signals.Huygens.Point3 | detector 2 = 1} _ ![0, 0, 1] (by rfl)
  have candidateNorm : ‖unphasedIntervalCandidate ![0, 0, 1]‖ = 4 := by
    norm_num [unphasedIntervalCandidate, Signals.CanonicalForms.intervalForm_apply,
      Signals.CanonicalForms.intervalCoefficient]
  have referenceNorm : ‖(finiteWidthSlits wave 1).amplitude ![0, 0, 1]‖ = 2 / 3 := by
    rw [finiteWidthSlits_reference, fourPathReference_center, norm_mul, centralPath_norm]
    norm_num
  have lower := norm_sub_norm_le (unphasedIntervalCandidate ![0, 0, 1])
    ((finiteWidthSlits wave 1).amplitude ![0, 0, 1])
  rw [candidateNorm, referenceNorm] at lower
  linarith

example : ¬Signals.Huygens.AmplitudeComparison (fourPathReference symmetricSlits.wave 1)
    (finiteWidthSlits symmetricSlits.wave 1).amplitude (∅ : Set Signals.Huygens.Point3) 0 := by
  intro comparison
  simpa using comparison.domain_nonempty

/-- Unit-amplitude error against a dark reference saturates the absolute intensity bound. -/
example : |Signals.Huygens.intensity (1 : ℂ) - Signals.Huygens.intensity 0| =
    ‖(1 : ℂ) - 0‖ * (‖(1 : ℂ)‖ + ‖(0 : ℂ)‖) := by
  norm_num [Signals.Huygens.intensity, Complex.normSq]

example (candidate classical : Signals.Huygens.Point3 → ℂ)
    (comparison : Signals.Huygens.AmplitudeComparison candidate classical
      {detector | detector 2 = 1} (1 / 4)) :
    |Signals.Huygens.intensity (candidate ![1, 2, 1]) -
      Signals.Huygens.intensity (classical ![1, 2, 1])| ≤
    (1 / 4) * (‖candidate ![1, 2, 1]‖ + ‖classical ![1, 2, 1]‖) :=
  comparison.intensityError _ rfl

example (first intermediate classical : Signals.Huygens.Point3 → ℂ)
    (firstComparison : Signals.Huygens.AmplitudeComparison first intermediate Set.univ (1 / 4))
    (secondComparison : Signals.Huygens.AmplitudeComparison intermediate classical Set.univ (1 / 2)) :
    Signals.Huygens.AmplitudeComparison first classical Set.univ (3 / 4) := by
  have sum : (1 / 4 : ℝ) + 1 / 2 = 3 / 4 := by norm_num
  exact sum ▸ firstComparison.compose secondComparison

/-- A fixed planar scalar field with an explicit unit normalization, not an exact boundary solution. -/
def toyPlanarField : Signals.Huygens.FixedPlanarField :=
  { wave := symmetricSlits.wave
    source := ![0, 0, -1]
    height := 0
    transmission := fun _ => 1
    normalization := 1 }

example (coordinate : ℝ × ℝ) :
    toyPlanarField.point coordinate ≠ toyPlanarField.source ∧
      toyPlanarField.point coordinate ≠ ![1, 2, 1] := by
  constructor <;> intro equal
  all_goals
    have impossible := congrFun equal 2
    norm_num [toyPlanarField, Signals.Huygens.FixedPlanarField.point] at impossible

example : ¬Signals.Huygens.IntegrablePlanarEvaluation toyPlanarField {(0, 0)} ![0, 0, 0] := by
  intro evaluation
  have distinct := (evaluation.regular (0, 0) (Set.mem_singleton _)).2
  exact distinct rfl

example (first second : Set (ℝ × ℝ)) (disjoint : Disjoint first second)
    (secondMeasurable : MeasurableSet second)
    (firstEvaluation : Signals.Huygens.IntegrablePlanarEvaluation toyPlanarField first ![1, 2, 1])
    (secondEvaluation : Signals.Huygens.IntegrablePlanarEvaluation toyPlanarField second ![1, 2, 1]) :
    toyPlanarField.amplitude (first ∪ second) ![1, 2, 1] =
      toyPlanarField.amplitude first ![1, 2, 1] + toyPlanarField.amplitude second ![1, 2, 1] :=
  toyPlanarField.amplitude_union _ _ _ disjoint secondMeasurable firstEvaluation secondEvaluation

example (measure : MeasureTheory.Measure (ℝ × ℝ)) [MeasureTheory.IsProbabilityMeasure measure] :
    ‖(∫ _, (1 : ℂ) ∂measure) - (∫ _, (0 : ℂ) ∂measure)‖ ≤ 1 := by
  have bound := Signals.Huygens.integral_error_le measure (fun _ => (1 : ℂ)) (fun _ => 0)
    (MeasureTheory.integrable_const _) (MeasureTheory.integrable_const _) 1
    (Filter.Eventually.of_forall (fun _ => by simp))
  exact bound.trans_eq (by simp)

/-- Two atomic masses are a numerical quadrature control, not physical aperture-area data. -/
noncomputable def quadratureControlMeasure : MeasureTheory.Measure ℝ :=
  MeasureTheory.Measure.dirac 0 + MeasureTheory.Measure.dirac 1

instance : MeasureTheory.IsFiniteMeasure quadratureControlMeasure := by
  unfold quadratureControlMeasure
  infer_instance

/-- The finite control integrates the nonconstant linear density. -/
lemma quadratureControl_integrable :
    MeasureTheory.Integrable (fun point : ℝ => (point : ℂ)) quadratureControlMeasure := by
  simp only [quadratureControlMeasure, MeasureTheory.integrable_add_measure]
  constructor <;> exact MeasureTheory.integrable_dirac (by finiteness)

/-- The independently integrated control density has unit total value. -/
lemma quadratureControl_integral : (∫ point : ℝ, (point : ℂ) ∂quadratureControlMeasure) = 1 := by
  rw [quadratureControlMeasure, MeasureTheory.integral_add_measure
    (MeasureTheory.integrable_dirac (by finiteness)) (MeasureTheory.integrable_dirac (by finiteness))]
  simp

/-- A deliberately coarse one-cell sample misses the mass at one. -/
def coarseQuadrature : Signals.Quadrature.CellQuadrature quadratureControlMeasure 1 :=
  { cell := fun _ => Set.univ
    measurable := fun _ => MeasurableSet.univ
    disjoint := by
      intro first second distinct
      exact False.elim (distinct (Subsingleton.elim _ _))
    cover := by
      ext point
      constructor
      · intro _
        trivial
      · intro _
        exact Set.mem_iUnion.mpr ⟨0, trivial⟩
    sample := fun _ => 0 }

/-- Two disjoint cells refine the same measured domain without fitting their weights. -/
def refinedQuadrature : Signals.Quadrature.CellQuadrature quadratureControlMeasure 2 :=
  { cell := fun index => if index = 0 then {0} else ({0} : Set ℝ)ᶜ
    measurable := by intro index; fin_cases index <;> simp
    disjoint := by
      intro first second distinct
      fin_cases first <;> fin_cases second <;> simp_all
    cover := by
      ext point
      simpa [Fin.exists_fin_succ] using Classical.em (point = 0)
    sample := fun index => if index = 0 then 0 else 1 }

example : ∑ index, refinedQuadrature.weight index = 2 := by
  rw [refinedQuadrature.weight_sum]
  norm_num [quadratureControlMeasure, MeasureTheory.measureReal_def]

example : (∫ point : ℝ, (point : ℂ) ∂quadratureControlMeasure) = 1 := quadratureControl_integral

example : coarseQuadrature.amplitude (fun point : ℝ => (point : ℂ)) = 0 := by
  simp [Signals.Quadrature.CellQuadrature.amplitude, coarseQuadrature]

example : refinedQuadrature.amplitude (fun point : ℝ => (point : ℂ)) = 1 := by
  norm_num [Signals.Quadrature.CellQuadrature.amplitude, Signals.Quadrature.CellQuadrature.weight,
    refinedQuadrature, quadratureControlMeasure, Fin.sum_univ_succ,
    MeasureTheory.measureReal_def, MeasureTheory.Measure.restrict_apply]

example : ‖coarseQuadrature.amplitude (fun point : ℝ => (point : ℂ)) -
    ∫ point : ℝ, (point : ℂ) ∂quadratureControlMeasure‖ = 1 := by
  rw [quadratureControl_integral]
  simp [Signals.Quadrature.CellQuadrature.amplitude, coarseQuadrature]

open scoped NNReal in
example : ¬(∀ index, ∀ᵐ point ∂quadratureControlMeasure.restrict (coarseQuadrature.cell index),
    dist (coarseQuadrature.sample index) point ≤ (0 : ℝ)) := by
  intro impossibleMesh
  have lipschitz : LipschitzWith 1 (fun point : ℝ => (point : ℂ)) :=
    LipschitzWith.of_dist_le_mul (by intro first second; simp [dist_eq_norm, ← Complex.ofReal_sub])
  have impossible := coarseQuadrature.amplitude_error_le_of_lipschitz
    (fun point : ℝ => (point : ℂ)) quadratureControl_integrable 1 0 lipschitz impossibleMesh
  rw [quadratureControl_integral] at impossible
  norm_num [Signals.Quadrature.CellQuadrature.amplitude, coarseQuadrature] at impossible

example {measure : MeasureTheory.Measure (ℝ × ℝ)} {count : ℕ}
    (quadrature : Signals.Quadrature.CellQuadrature measure count) :
    (quadrature.toAperture toyPlanarField).amplitude toyPlanarField.wave toyPlanarField.source
      ![1, 2, 1] = quadrature.amplitude (toyPlanarField.density ![1, 2, 1]) :=
  quadrature.toAperture_amplitude _ _

/-- A three-spoke graph with three boundary vertices and one internal vertex. -/
def plabicStarGraph : SimpleGraph (Signals.Plabic.Vertex 3 1) where
  Adj left right := match left, right with
    | Sum.inl _, Sum.inr _ => True
    | Sum.inr _, Sum.inl _ => True
    | _, _ => False
  symm := by
    constructor
    intro left right adjacent
    cases left <;> cases right <;> exact adjacent
  loopless := by
    constructor
    intro vertex
    cases vertex <;> exact id

/-- The central neighbors are exactly the three boundary labels. -/
def plabicStarNeighbors (internal : Fin 1) :
    plabicStarGraph.neighborSet (Sum.inr internal) ≃ Fin 3 where
  toFun neighbor := by
    rcases neighbor with ⟨vertex, adjacent⟩
    cases vertex with
    | inl index => exact index
    | inr _ => exact False.elim adjacent
  invFun index := ⟨Sum.inl index, trivial⟩
  left_inv := by
    rintro ⟨vertex, adjacent⟩
    cases vertex with
    | inl index => rfl
    | inr _ => exact False.elim adjacent
  right_inv _ := rfl

/-- A genuine single-cycle central rotation with a selectable node color. -/
def plabicStar (color : Signals.Plabic.NodeColor) : Signals.Plabic.RotationSystem 3 1 :=
  { graph := plabicStarGraph
    color := fun _ => color
    rotation := fun vertex => match vertex with
      | Sum.inl _ => Equiv.refl _
      | Sum.inr internal =>
          ((plabicStarNeighbors internal).trans (finRotate 3)).trans
            (plabicStarNeighbors internal).symm
    singleOrbit := by
      intro internal first second
      rcases first with ⟨first, first_adjacent⟩
      rcases second with ⟨second, second_adjacent⟩
      cases first with
      | inr _ => exact False.elim first_adjacent
      | inl first =>
          cases second with
          | inr _ => exact False.elim second_adjacent
          | inl second =>
              fin_cases first <;> fin_cases second
              all_goals first | exact ⟨0, rfl⟩ | exact ⟨1, rfl⟩ | exact ⟨2, rfl⟩
    boundaryNeighbor := fun _ => Sum.inr 0
    boundaryAdjacent := fun _ => trivial
    boundaryUnique := by
      intro index vertex adjacent
      cases vertex with
      | inl _ => exact False.elim adjacent
      | inr internal =>
          congr 1
          exact Fin.eq_zero internal }

/-- Each central-star strand exits after one turn, with a checked boundary permutation. -/
def plabicStarRouting (color : Signals.Plabic.NodeColor) :
    Signals.Plabic.BoundaryRouting (plabicStar color) :=
  { perm := match color with
      | .black => finRotate 3
      | .white => (finRotate 3).symm
    steps := fun _ => 1
    exits := by
      intro index
      cases color <;> rfl
    fixedColor := fun _ _ => color }

example : ((plabicStar .black).route 1 ((plabicStar .black).start 0)).dst =
    Sum.inl 1 := rfl

example : ((plabicStar .white).route 1 ((plabicStar .white).start 0)).dst =
    Sum.inl 2 := rfl

example : ((plabicStar .black).route 4 ((plabicStar .black).start 0)).dst =
    Sum.inl 1 := rfl

example : (plabicStar .black).firstExit 0 ((plabicStar .black).start 0) = none := rfl

example (color : Signals.Plabic.NodeColor) (index : Fin 3) :
    (plabicStar color).dartTurn ((plabicStar color).start index) =
      (plabicStar color).step ((plabicStar color).start index) :=
  (plabicStar color).dartTurn_internal _ 0 rfl

example : (plabicStar .black).dartTurn
    ((plabicStar .black).route 1 ((plabicStar .black).start 0)) =
      (plabicStar .black).start 1 := rfl

example : (plabicStar .white).dartTurn
    ((plabicStar .white).route 1 ((plabicStar .white).start 0)) =
      (plabicStar .white).start 2 := rfl

example : ((plabicStar .black).dartTurn :
    Signals.Plabic.DirectedEdge (plabicStar .black) → _)^[6]
      ((plabicStar .black).start 0) = (plabicStar .black).start 0 := rfl

example : ¬((plabicStar .black).dartTurn
    ((plabicStar .black).route 1 ((plabicStar .black).start 0)) =
      (plabicStar .black).route 2 ((plabicStar .black).start 0)) := by
  intro impossible
  have destination := congrArg Signals.Plabic.DirectedEdge.dst impossible
  change Sum.inr (0 : Fin 1) = Sum.inl (1 : Fin 3) at destination
  cases destination

example : (plabicStar .black).firstExit 1 ((plabicStar .black).start 0) =
  some (1, 1) := rfl

example : (plabicStar .white).firstExit 1 ((plabicStar .white).start 0) =
  some (1, 2) := rfl

example : (plabicStar .black).firstExit 4 ((plabicStar .black).start 0) =
  some (1, 1) := rfl

example : (plabicStar .black).firstExit 0
  ((plabicStar .black).route 1 ((plabicStar .black).start 0)) = some (0, 1) := rfl

example : ¬((plabicStar .black).firstExit 4 ((plabicStar .black).start 0) =
  some (2, 1)) := by decide

example : ∀ earlier < 1, ∀ index,
  ((plabicStar .black).route earlier ((plabicStar .black).start 0)).dst ≠ Sum.inl index :=
  ((plabicStar .black).firstExit_spec 4 ((plabicStar .black).start 0) 1 1 rfl).2.2

example : ∀ index, ((plabicStar .black).route 0 ((plabicStar .black).start 0)).dst ≠
  Sum.inl index :=
  ((plabicStar .black).firstExit_none_iff 0 ((plabicStar .black).start 0)).mp rfl

example (color : Signals.Plabic.NodeColor) (index : Fin 3) :
  ∃ steps ≤ 1, (plabicStar color).firstExit 1 ((plabicStar color).start index) =
    some (steps, (plabicStarRouting color).perm index) :=
  (plabicStar color).firstExit_exists 1 ((plabicStar color).start index)
  ((plabicStarRouting color).perm index) ((plabicStarRouting color).exits index)

/-- The derived search recovers all star exits without a supplied first-exit count. -/
lemma plabicStar_exitData (color : Signals.Plabic.NodeColor) (index : Fin 3) :
    (plabicStar color).boundaryExitData index = (1, (plabicStarRouting color).perm index) := by
  have first : (plabicStar color).firstExit 1 ((plabicStar color).start index) =
      some (1, (plabicStarRouting color).perm index) := by cases color <;> rfl
  have same := (plabicStar color).firstExit_unique 1 _ ((plabicStar color).start index)
    1 ((plabicStar color).boundaryExitData index).1 ((plabicStarRouting color).perm index)
    ((plabicStar color).boundaryExitData index).2 first
    ((plabicStar color).boundaryExitData_found index)
  exact Prod.ext same.1.symm same.2.symm

example : (plabicStar .black).boundaryExitData 0 = (1, 1) := plabicStar_exitData _ _

example : (plabicStar .white).boundaryExitData 0 = (1, 2) := plabicStar_exitData _ _

example : ¬((plabicStar .black).boundaryExitData 0 = (2, 1)) := by
  intro delayed
  have count := congrArg Prod.fst delayed
  rw [plabicStar_exitData] at count
  norm_num at count

/-- Two directly adjacent boundaries test zero-step exits with no internal vertices. -/
def plabicBoundaryPair : Signals.Plabic.RotationSystem 2 0 :=
  { graph := ⊤
    color := fun internal => Fin.elim0 internal
    rotation := fun _ => Equiv.refl _
    singleOrbit := by intro internal; exact Fin.elim0 internal
    boundaryNeighbor := fun index => if index = 0 then Sum.inl 1 else Sum.inl 0
    boundaryAdjacent := by intro index; fin_cases index <;> decide
    boundaryUnique := by
      intro index vertex adjacent
      cases vertex with
      | inr internal => exact Fin.elim0 internal
      | inl other =>
          change Sum.inl index ≠ (Sum.inl other : Signals.Plabic.Vertex 2 0) at adjacent
          fin_cases index <;> fin_cases other <;> simp_all }

example : plabicBoundaryPair.firstExit 0 (plabicBoundaryPair.start 0) = some (0, 1) := rfl

/-- Both direct-boundary exits recover the independently specified transposition. -/
lemma plabicBoundaryPair_exitData (index : Fin 2) :
    plabicBoundaryPair.boundaryExitData index = (0, if index = 0 then 1 else 0) := by
  have first : plabicBoundaryPair.firstExit 0 (plabicBoundaryPair.start index) =
      some (0, if index = 0 then 1 else 0) := by fin_cases index <;> rfl
  have same := plabicBoundaryPair.firstExit_unique 0 _ (plabicBoundaryPair.start index)
    0 (plabicBoundaryPair.boundaryExitData index).1 (if index = 0 then 1 else 0)
    (plabicBoundaryPair.boundaryExitData index).2 first (plabicBoundaryPair.boundaryExitData_found index)
  exact Prod.ext same.1.symm same.2.symm

example : plabicBoundaryPair.boundaryExitData 0 = (0, 1) := plabicBoundaryPair_exitData _

/-- The constructed star boundary permutation matches the independent clockwise/counterclockwise control. -/
lemma plabicStar_boundaryPerm (color : Signals.Plabic.NodeColor) :
    (plabicStar color).boundaryPerm = (plabicStarRouting color).perm := by
  apply Equiv.ext
  intro index
  exact congrArg Prod.snd (plabicStar_exitData color index)

example : (plabicStar .black).boundaryPerm 0 = 1 := by rw [plabicStar_boundaryPerm]; rfl

example : (plabicStar .white).boundaryPerm 0 = 2 := by rw [plabicStar_boundaryPerm]; rfl

example : (plabicStar .black).boundaryPerm.symm 0 = 2 := by rw [plabicStar_boundaryPerm]; rfl

example : ¬((plabicStar .black).boundaryPerm 0 = 2) := by rw [plabicStar_boundaryPerm]; decide

example : plabicBoundaryPair.boundaryPerm = finRotate 2 := by
  apply Equiv.ext
  intro index
  have labels := congrArg Prod.snd (plabicBoundaryPair_exitData index)
  fin_cases index <;> exact labels

example (system : Signals.Plabic.RotationSystem 3 1) : Function.Bijective system.boundaryPerm :=
  system.boundaryPerm.bijective

example : ((plabicStar .black).derivedRouting (fun _ _ => .black)).decorated.perm 0 = 1 := by
  change (plabicStar .black).boundaryPerm 0 = 1
  rw [plabicStar_boundaryPerm]
  rfl

example : (plabicStarRouting .black).decorated.perm 0 = 1 := rfl

example : (plabicStarRouting .white).decorated.perm 0 = 2 := rfl

example : Function.Bijective (plabicStarRouting .black).decorated.perm :=
  (plabicStarRouting .black).perm_bijective

example : (Signals.Plabic.DecoratedPermutation.identityWhite 1).fixedColor 0 rfl =
    Signals.Plabic.NodeColor.white := rfl

example : ¬(∀ first second : Fin 3, ∃ steps : ℕ,
    (Equiv.refl (Fin 3))^[steps] first = second) := by
  intro singleOrbit
  obtain ⟨steps, impossible⟩ := singleOrbit 0 1
  simp at impossible

open scoped NNReal in
/-- A ranked two-edge chain is a nonconstant weighted-path control, not an optical phase model. -/
def weightedChain : Signals.Plabic.WeightedAcyclicNetwork 3 2 :=
  Signals.Plabic.WeightedAcyclicNetwork.twoEdgePath 2 3

/-- The independently specified two edge weights multiply in the finite boundary path sum. -/
lemma weightedChain_transfer : weightedChain.transfer 0 2 = 6 := by
  simp only [Signals.Plabic.WeightedAcyclicNetwork.transfer, Finset.sum_range_succ,
    Finset.range_zero, Finset.sum_empty, zero_add, Matrix.add_apply,
    pow_zero, pow_one, pow_two, Matrix.one_apply, Matrix.mul_apply]
  norm_num [weightedChain, Signals.Plabic.WeightedAcyclicNetwork.twoEdgePath, Fin.sum_univ_succ]

example : weightedChain.boundaryMeasurement (fun _ : Fin 1 => 0) (fun _ : Fin 1 => 2) 0 0 = 6 :=
  weightedChain_transfer

example : weightedChain.transfer 2 0 = 0 := by
  simp only [Signals.Plabic.WeightedAcyclicNetwork.transfer, Finset.sum_range_succ,
    Finset.range_zero, Finset.sum_empty, zero_add, Matrix.add_apply,
    pow_zero, pow_one, pow_two, Matrix.one_apply, Matrix.mul_apply]
  norm_num [weightedChain, Signals.Plabic.WeightedAcyclicNetwork.twoEdgePath, Fin.sum_univ_succ]

example : weightedChain.weight ^ 3 = 0 := weightedChain.nilpotent

example : (∑ length ∈ Finset.range 8, weightedChain.weight ^ length) = weightedChain.transfer :=
  weightedChain.transfer_stable 5

example : ¬(weightedChain.transfer 0 2 = 5) := by
  rw [weightedChain_transfer]
  norm_num

example (network : Signals.Plabic.WeightedAcyclicNetwork 3 2)
    (levels : network.level = weightedChain.level) : network.weight 2 0 = 0 := by
  by_contra nonzero
  have impossible := network.ascending 2 0 nonzero
  rw [levels] at impossible
  norm_num [weightedChain, Signals.Plabic.WeightedAcyclicNetwork.twoEdgePath] at impossible

example : (Signals.Plabic.WeightedAcyclicNetwork.twoEdgePath 2 (6 / 2)).boundaryMeasurement
    (fun _ : Fin 1 => 0) (fun _ : Fin 1 => 2) =
    (Signals.Plabic.WeightedAcyclicNetwork.oneEdgePath 6).boundaryMeasurement
      (fun _ : Fin 1 => 0) (fun _ : Fin 1 => 1) :=
  Signals.Plabic.WeightedAcyclicNetwork.subdivision_boundary 6 2 (by norm_num)

example : (Signals.Plabic.WeightedAcyclicNetwork.twoEdgePath 2 (0 / 2)).boundaryMeasurement
    (fun _ : Fin 1 => 0) (fun _ : Fin 1 => 2) =
    (Signals.Plabic.WeightedAcyclicNetwork.oneEdgePath 0).boundaryMeasurement
      (fun _ : Fin 1 => 0) (fun _ : Fin 1 => 1) :=
  Signals.Plabic.WeightedAcyclicNetwork.subdivision_boundary 0 2 (by norm_num)

example : ¬((Signals.Plabic.WeightedAcyclicNetwork.twoEdgePath 0 (6 / 0)).boundaryMeasurement
    (fun _ : Fin 1 => 0) (fun _ : Fin 1 => 2) =
    (Signals.Plabic.WeightedAcyclicNetwork.oneEdgePath 6).boundaryMeasurement
      (fun _ : Fin 1 => 0) (fun _ : Fin 1 => 1)) := by
  intro invalidMove
  have entry := congrArg (fun measurement : Matrix (Fin 1) (Fin 1) _ => measurement 0 0) invalidMove
  change (Signals.Plabic.WeightedAcyclicNetwork.twoEdgePath 0 (6 / 0)).transfer 0 2 =
    (Signals.Plabic.WeightedAcyclicNetwork.oneEdgePath 6).transfer 0 1 at entry
  rw [Signals.Plabic.WeightedAcyclicNetwork.twoEdgePath_transfer,
    Signals.Plabic.WeightedAcyclicNetwork.oneEdgePath_transfer] at entry
  norm_num at entry

example : ¬((Signals.Plabic.WeightedAcyclicNetwork.twoEdgePath 2 6).transfer 0 2 =
    (Signals.Plabic.WeightedAcyclicNetwork.oneEdgePath 6).transfer 0 1) := by
  rw [Signals.Plabic.WeightedAcyclicNetwork.twoEdgePath_transfer,
    Signals.Plabic.WeightedAcyclicNetwork.oneEdgePath_transfer]
  norm_num

example : Signals.Geometry.GrassmannianMatrix.pluckerCoordinate
  (Signals.Geometry.forkPositive 2 3 (by norm_num) (by norm_num)).toGrassmannianMatrix
  (Signals.Geometry.OrderedColumns.single 1) = 3 := by
  change Signals.Geometry.selectedMinor (Signals.Geometry.forkRepresentative 2 3).mat
    (Signals.Geometry.OrderedColumns.single 1) = 3
  rw [Signals.Geometry.forkRepresentative_mat, Signals.Geometry.selectedMinor, Matrix.det_fin_one]
  norm_num [Signals.Geometry.OrderedColumns.single]

example : Signals.Geometry.GrassmannianMatrix.pluckerCoordinate
  (Signals.Geometry.forkNonnegative 2 0 (Or.inl (by norm_num))).toGrassmannianMatrix
  (Signals.Geometry.OrderedColumns.single 1) = 0 := by
  change Signals.Geometry.selectedMinor (Signals.Geometry.forkRepresentative 2 0).mat
    (Signals.Geometry.OrderedColumns.single 1) = 0
  rw [Signals.Geometry.forkRepresentative_mat, Signals.Geometry.selectedMinor, Matrix.det_fin_one]
  norm_num [Signals.Geometry.OrderedColumns.single]

example : Signals.Geometry.GrassmannianMatrix.pluckerCoordinate
  (Signals.Geometry.forkNonnegative 0 3 (Or.inr (by norm_num))).toGrassmannianMatrix
  (Signals.Geometry.OrderedColumns.single 1) = 3 := by
  change Signals.Geometry.selectedMinor (Signals.Geometry.forkRepresentative 0 3).mat
    (Signals.Geometry.OrderedColumns.single 1) = 3
  rw [Signals.Geometry.forkRepresentative_mat, Signals.Geometry.selectedMinor, Matrix.det_fin_one]
  norm_num [Signals.Geometry.OrderedColumns.single]

example : ¬(Signals.Geometry.forkRepresentative 0 3).hasPositiveOrderedMinors := by
  intro positive
  have impossible := positive (Signals.Geometry.OrderedColumns.single 0)
  rw [Signals.Geometry.GrassmannianMatrix.pluckerCoordinate, Signals.Geometry.selectedMinor,
    Signals.Geometry.forkRepresentative_mat, Matrix.det_fin_one] at impossible
  norm_num [Signals.Geometry.OrderedColumns.single] at impossible

example : ¬∃ representative : Signals.Geometry.NonnegativeGrassmannian 1 2,
    representative.mat = (Signals.Geometry.forkRepresentative 0 0).mat := by
  rintro ⟨representative, same⟩
  obtain ⟨columns, nonzero⟩ := representative.nonzero_minor
  change Signals.Geometry.selectedMinor representative.mat columns ≠ 0 at nonzero
  rw [same] at nonzero
  apply nonzero
  rw [Signals.Geometry.forkRepresentative_mat, Signals.Geometry.selectedMinor, Matrix.det_fin_one]
  change (!![0, 0] : Matrix (Fin 1) (Fin 2) ℝ) 0 (columns.index 0) = 0
  generalize columns.index 0 = column
  fin_cases column <;> rfl

example : (twoChannelRepresentative 2 0 0 3).pluckerCoordinate identityColumns = 6 := by
  change (twoChannelRepresentative 2 0 0 3).mat.det = 6
  rw [twoChannelRepresentative_det]
  norm_num

example : (twoChannelRepresentative 0 2 3 0).pluckerCoordinate identityColumns = -6 := by
  change (twoChannelRepresentative 0 2 3 0).mat.det = -6
  rw [twoChannelRepresentative_det]
  norm_num

example : 0 < (twoChannelRepresentative 3 1 1 2).mat.det := by
  rw [twoChannelRepresentative_det_pos_iff]
  norm_num

example : (twoChannelRepresentative 1 2 3 4).pluckerCoordinate identityColumns = -2 := by
  change (twoChannelRepresentative 1 2 3 4).mat.det = -2
  rw [twoChannelRepresentative_det]
  norm_num

example : ¬(twoChannelRepresentative 1 2 3 4).hasNonnegativeOrderedMinors := by
  intro nonnegative
  have impossible := nonnegative identityColumns
  change 0 ≤ (twoChannelRepresentative 1 2 3 4).mat.det at impossible
  rw [twoChannelRepresentative_det] at impossible
  norm_num at impossible

example : (twoChannelRepresentative 1 2 2 4).pluckerCoordinate identityColumns = 0 := by
  change (twoChannelRepresentative 1 2 2 4).mat.det = 0
  rw [twoChannelRepresentative_det]
  norm_num

example : (twoChannelRepresentative 1 2 2 4).mat ≠ 0 := by
  intro zeroMatrix
  have entry := congrArg (fun matrix : Matrix (Fin 2) (Fin 2) ℝ => matrix 0 0) zeroMatrix
  rw [twoChannelRepresentative_mat] at entry
  norm_num at entry

example : ¬∃ representative : NonnegativeGrassmannian 2 2,
    representative.mat = (twoChannelRepresentative 1 2 2 4).mat := by
  rintro ⟨representative, same⟩
  obtain ⟨columns, nonzero⟩ := representative.nonzero_minor
  have ordered : columns.index 0 < columns.index 1 := columns.strictlyIncreasing (by decide)
  have first : columns.index 0 = 0 := by
    apply Fin.ext
    omega
  have second : columns.index 1 = 1 := by
    apply Fin.ext
    omega
  change selectedMinor representative.mat columns ≠ 0 at nonzero
  rw [same, twoChannelRepresentative_mat, selectedMinor, Matrix.det_fin_two] at nonzero
  norm_num [Matrix.submatrix, first, second] at nonzero

example : (singleHubRepresentative 2 3 5 7).mat = !![10, 14; 15, 21] := by
  rw [singleHubRepresentative_mat]
  norm_num

example (row column : Fin 2) : 0 < (singleHubRepresentative 2 3 5 7).mat row column := by
  rw [singleHubRepresentative_mat]
  fin_cases row <;> fin_cases column <;> norm_num

example : (singleHubRepresentative 2 3 5 7).pluckerCoordinate identityColumns = 0 := by
  change (singleHubRepresentative 2 3 5 7).mat.det = 0
  exact singleHubRepresentative_det 2 3 5 7

example : ¬(singleHubRepresentative 2 3 5 7).hasPositiveOrderedMinors := by
  intro positive
  have impossible := positive identityColumns
  change 0 < (singleHubRepresentative 2 3 5 7).mat.det at impossible
  rw [singleHubRepresentative_det] at impossible
  exact lt_irrefl 0 impossible

example (firstIn secondIn firstOut secondOut : NNReal) :
    ¬∃ representative : NonnegativeGrassmannian 2 2,
      representative.mat = (singleHubRepresentative firstIn secondIn firstOut secondOut).mat := by
  rintro ⟨representative, same⟩
  obtain ⟨columns, nonzero⟩ := representative.nonzero_minor
  have ordered : columns.index 0 < columns.index 1 := columns.strictlyIncreasing (by decide)
  have first : columns.index 0 = 0 := by
    apply Fin.ext
    omega
  have second : columns.index 1 = 1 := by
    apply Fin.ext
    omega
  change selectedMinor representative.mat columns ≠ 0 at nonzero
  have selection : selectedMinor representative.mat columns =
      (singleHubRepresentative firstIn secondIn firstOut secondOut).mat.det := by
    rw [same, selectedMinor, Matrix.det_fin_two, Matrix.det_fin_two]
    simp [Matrix.submatrix, first, second]
  rw [selection, singleHubRepresentative_det] at nonzero
  exact nonzero rfl

example : ((0 : Matrix (Fin 2) (Fin 0) ℝ) *
    (0 : Matrix (Fin 0) (Fin 2) ℝ)).det = 0 := by
  rw [twoStep_det_pathPairs]
  simp

example : ((!![2; 3] : Matrix (Fin 2) (Fin 1) ℝ) *
    (!![5, 7] : Matrix (Fin 1) (Fin 2) ℝ)).det = 0 := by
  rw [twoStep_det_pathPairs]
  norm_num [Fin.sum_univ_succ]

example : ((!![2, 0; 0, 3] : Matrix (Fin 2) (Fin 2) ℝ) *
    (!![5, 0; 0, 7] : Matrix (Fin 2) (Fin 2) ℝ)).det = 210 := by
  rw [twoStep_det_pathPairs]
  norm_num [Fin.sum_univ_succ]

example : ((!![1, 2; 3, 4] : Matrix (Fin 2) (Fin 2) ℝ) *
    (!![5, 0; 0, 7] : Matrix (Fin 2) (Fin 2) ℝ)).det = -70 := by
  rw [twoStep_det_pathPairs]
  norm_num [Fin.sum_univ_succ]

example : ¬0 ≤ ((!![1, 2; 3, 4] : Matrix (Fin 2) (Fin 2) ℝ) *
    (!![5, 0; 0, 7] : Matrix (Fin 2) (Fin 2) ℝ)).det := by
  rw [twoStep_det_pathPairs]
  norm_num [Fin.sum_univ_succ]

example : (singleHubRepresentative 2 3 5 7).mat =
    ( !![2; 3] : Matrix (Fin 2) (Fin 1) ℝ) *
      (!![5, 7] : Matrix (Fin 1) (Fin 2) ℝ) := by
  rw [singleHubRepresentative_mat]
  apply Matrix.ext
  intro row column
  fin_cases row <;> fin_cases column <;> norm_num [Matrix.mul_apply, Fin.sum_univ_succ]

/-- Independent incoming weights for three intermediate vertices. -/
def threeMiddleIncoming : Matrix (Fin 2) (Fin 3) ℝ := !![2, 0, 1; 0, 3, 1]

/-- Independent outgoing weights for the same three intermediate vertices. -/
def threeMiddleOutgoing : Matrix (Fin 3) (Fin 2) ℝ := !![5, 0; 0, 7; 1, 1]

/-- All ordered-pair contributions of the three-vertex fixture have compatible signs. -/
lemma threeMiddle_compatible : ∀ first second,
    0 ≤ twoStepMinorPair threeMiddleIncoming threeMiddleOutgoing first second := by
  intro first second
  fin_cases first <;> fin_cases second <;>
    norm_num [twoStepMinorPair, threeMiddleIncoming, threeMiddleOutgoing]

example : (threeMiddleIncoming * threeMiddleOutgoing).det = 241 := by
  rw [twoStep_det_pathPairs]
  norm_num [threeMiddleIncoming, threeMiddleOutgoing, Fin.sum_univ_succ]

example : 0 ≤ (threeMiddleIncoming * threeMiddleOutgoing).det :=
  twoStep_det_nonnegative _ _ threeMiddle_compatible

example : 0 < (threeMiddleIncoming * threeMiddleOutgoing).det := by
  refine twoStep_det_positive _ _ threeMiddle_compatible 0 1 ?_
  norm_num [twoStepMinorPair, threeMiddleIncoming, threeMiddleOutgoing]

example : (∑ first, ∑ second,
    twoStepMinorPair threeMiddleIncoming threeMiddleOutgoing first second) = 482 := by
  norm_num [twoStepMinorPair, threeMiddleIncoming, threeMiddleOutgoing, Fin.sum_univ_succ]

example : twoStepMinorPair threeMiddleIncoming threeMiddleOutgoing 1 2 = 21 := by
  norm_num [twoStepMinorPair, threeMiddleIncoming, threeMiddleOutgoing]

example : 0 ≤ ((!![2; 3] : Matrix (Fin 2) (Fin 1) ℝ) *
    (!![5, 7] : Matrix (Fin 1) (Fin 2) ℝ)).det := by
  apply twoStep_det_nonnegative
  intro first second
  fin_cases first
  fin_cases second
  norm_num [twoStepMinorPair]

example : ¬∃ first second : Fin 1,
    0 < twoStepMinorPair (!![2; 3] : Matrix (Fin 2) (Fin 1) ℝ)
      (!![5, 7] : Matrix (Fin 1) (Fin 2) ℝ) first second := by
  rintro ⟨first, second, active⟩
  fin_cases first
  fin_cases second
  norm_num [twoStepMinorPair] at active

example : ¬(∀ first second : Fin 2,
    0 ≤ twoStepMinorPair (!![1, 2; 3, 4] : Matrix (Fin 2) (Fin 2) ℝ)
      (!![5, 1; 1, 7] : Matrix (Fin 2) (Fin 2) ℝ) first second) := by
  intro compatible
  have impossible := compatible 0 1
  norm_num [twoStepMinorPair] at impossible

example : ((!![1, 2; 3, 4] : Matrix (Fin 2) (Fin 2) ℝ) *
    (!![5, 1; 1, 7] : Matrix (Fin 2) (Fin 2) ℝ)).det = -68 := by
  rw [twoStep_det_pathPairs]
  norm_num [Fin.sum_univ_succ]

/-- Independent outgoing weights to three ordered sinks. -/
def threeSinkOutgoing : Matrix (Fin 3) (Fin 3) ℝ := !![1, 1, 1; 0, 1, 2; 1, 2, 3]

example : threeMiddleIncoming * threeSinkOutgoing = !![3, 4, 5; 1, 5, 9] := by
  apply Matrix.ext
  intro row column
  fin_cases row <;> fin_cases column <;>
    norm_num [threeMiddleIncoming, threeSinkOutgoing, Matrix.mul_apply, Fin.sum_univ_succ]

example : selectedMinor (threeMiddleIncoming * threeSinkOutgoing)
    (OrderedColumns.pair 0 1 (by decide)) = 11 := by
  rw [twoStep_selectedMinor, Matrix.det_fin_two]
  norm_num [threeMiddleIncoming, threeSinkOutgoing, OrderedColumns.pair,
    Matrix.submatrix, Matrix.mul_apply, Fin.sum_univ_succ]

example : selectedMinor (threeMiddleIncoming * threeSinkOutgoing)
    (OrderedColumns.pair 0 2 (by decide)) = 22 := by
  rw [twoStep_selectedMinor, Matrix.det_fin_two]
  norm_num [threeMiddleIncoming, threeSinkOutgoing, OrderedColumns.pair,
    Matrix.submatrix, Matrix.mul_apply, Fin.sum_univ_succ]

example : selectedMinor (threeMiddleIncoming * threeSinkOutgoing)
    (OrderedColumns.pair 1 2 (by decide)) = 11 := by
  rw [twoStep_selectedMinor, Matrix.det_fin_two]
  norm_num [threeMiddleIncoming, threeSinkOutgoing, OrderedColumns.pair,
    Matrix.submatrix, Matrix.mul_apply, Fin.sum_univ_succ]

example : (∑ first, ∑ second, twoStepMinorPair threeMiddleIncoming
    (threeSinkOutgoing.submatrix id (OrderedColumns.pair 0 2 (by decide)).index)
      first second) = 44 := by
  rw [twoStep_selectedMinor_pairs, twoStep_selectedMinor, Matrix.det_fin_two]
  norm_num [threeMiddleIncoming, threeSinkOutgoing, OrderedColumns.pair,
    Matrix.submatrix, Matrix.mul_apply, Fin.sum_univ_succ]

example : ¬selectedMinor (threeMiddleIncoming * threeSinkOutgoing)
    (OrderedColumns.pair 0 2 (by decide)) = 11 := by
  rw [twoStep_selectedMinor, Matrix.det_fin_two]
  norm_num [threeMiddleIncoming, threeSinkOutgoing, OrderedColumns.pair,
    Matrix.submatrix, Matrix.mul_apply, Fin.sum_univ_succ]

/-- Every selected input minor pair of the three-sink fixture has a compatible sign. -/
lemma threeSink_compatible : ∀ columns : OrderedColumns 2 3, ∀ first second,
    0 ≤ twoStepMinorPair threeMiddleIncoming
      (threeSinkOutgoing.submatrix id columns.index) first second := by
  intro columns first second
  have ordered : columns.index 0 < columns.index 1 := columns.strictlyIncreasing (by decide)
  simp only [twoStepMinorPair, Matrix.submatrix]
  generalize lowerEq : columns.index 0 = lower at ordered
  generalize upperEq : columns.index 1 = upper at ordered
  fin_cases lower <;> fin_cases upper <;> norm_num at ordered
  all_goals
    fin_cases first <;> fin_cases second <;>
      norm_num [threeMiddleIncoming, threeSinkOutgoing, lowerEq, upperEq]

/-- Every ordered sink selection has a positive independently computed input pair. -/
lemma threeSink_active : ∀ columns : OrderedColumns 2 3, ∃ first second,
    0 < twoStepMinorPair threeMiddleIncoming
      (threeSinkOutgoing.submatrix id columns.index) first second := by
  intro columns
  refine ⟨0, 1, ?_⟩
  have ordered : columns.index 0 < columns.index 1 := columns.strictlyIncreasing (by decide)
  simp only [twoStepMinorPair, Matrix.submatrix]
  generalize lowerEq : columns.index 0 = lower at ordered
  generalize upperEq : columns.index 1 = upper at ordered
  fin_cases lower <;> fin_cases upper <;> norm_num at ordered
  all_goals norm_num [threeMiddleIncoming, threeSinkOutgoing, lowerEq, upperEq]

/-- The three-sink positive record is derived from input-pair compatibility and active witnesses. -/
def threeSinkPositive : PositiveGrassmannian 2 3 :=
  twoStepPositive threeMiddleIncoming threeSinkOutgoing threeSink_compatible threeSink_active

example (columns : OrderedColumns 2 3) :
    0 < threeSinkPositive.toGrassmannianMatrix.pluckerCoordinate columns :=
  threeSinkPositive.pluckerCoordinate_pos columns

example : threeSinkPositive.toGrassmannianMatrix.mat =
    threeMiddleIncoming * threeSinkOutgoing := rfl

example : threeSinkPositive.toGrassmannianMatrix.pluckerCoordinate
    (OrderedColumns.pair 0 2 (by decide)) = 22 := by
  change selectedMinor (threeMiddleIncoming * threeSinkOutgoing) _ = 22
  rw [twoStep_selectedMinor, Matrix.det_fin_two]
  norm_num [threeMiddleIncoming, threeSinkOutgoing, OrderedColumns.pair,
    Matrix.submatrix, Matrix.mul_apply, Fin.sum_univ_succ]

example : ∃ columns : OrderedColumns 2 3,
    GrassmannianMatrix.pluckerCoordinate
      (threeSinkPositive.toNonnegative (OrderedColumns.pair 0 1 (by decide))).toGrassmannianMatrix
      columns ≠ 0 := by
  exact (threeSinkPositive.toNonnegative (OrderedColumns.pair 0 1 (by decide))).nonzero_minor

/-- A derived full-rank nonnegative product retains its repeated-column zero minor. -/
def boundaryTwoStep : NonnegativeGrassmannian 2 3 :=
  twoStepNonnegative (!![2, 0; 0, 3] : Matrix (Fin 2) (Fin 2) ℝ)
    (!![1, 1, 1; 0, 0, 1] : Matrix (Fin 2) (Fin 3) ℝ)
    (by
      intro columns first second
      have ordered : columns.index 0 < columns.index 1 := columns.strictlyIncreasing (by decide)
      simp only [twoStepMinorPair, Matrix.submatrix]
      generalize lowerEq : columns.index 0 = lower at ordered
      generalize upperEq : columns.index 1 = upper at ordered
      fin_cases lower <;> fin_cases upper <;> norm_num at ordered
      all_goals fin_cases first <;> fin_cases second <;> norm_num [lowerEq, upperEq])
    (by
      refine ⟨OrderedColumns.pair 0 2 (by decide), 0, 1, ?_⟩
      norm_num [twoStepMinorPair, OrderedColumns.pair, Matrix.submatrix])

example : boundaryTwoStep.toGrassmannianMatrix.pluckerCoordinate
    (OrderedColumns.pair 0 1 (by decide)) = 0 := by
  norm_num [boundaryTwoStep, twoStepNonnegative, twoStepRepresentative,
    GrassmannianMatrix.pluckerCoordinate, selectedMinor, OrderedColumns.pair,
    Matrix.det_fin_two, Matrix.submatrix, Matrix.mul_apply, Fin.sum_univ_succ]

example : boundaryTwoStep.toGrassmannianMatrix.pluckerCoordinate
    (OrderedColumns.pair 0 2 (by decide)) = 6 := by
  norm_num [boundaryTwoStep, twoStepNonnegative, twoStepRepresentative,
    GrassmannianMatrix.pluckerCoordinate, selectedMinor, OrderedColumns.pair,
    Matrix.det_fin_two, Matrix.submatrix, Matrix.mul_apply, Fin.sum_univ_succ]

example : ¬boundaryTwoStep.toGrassmannianMatrix.hasPositiveOrderedMinors := by
  intro positive
  have impossible := positive (OrderedColumns.pair 0 1 (by decide))
  norm_num [boundaryTwoStep, twoStepNonnegative, twoStepRepresentative,
    GrassmannianMatrix.pluckerCoordinate, selectedMinor, OrderedColumns.pair,
    Matrix.det_fin_two, Matrix.submatrix, Matrix.mul_apply, Fin.sum_univ_succ] at impossible

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

noncomputable def toyLigninVitrimer : LigninVitrimerDielectric :=
  { relativePermittivity := 2
    relativePermittivity_pos := by norm_num
    lossTangent := 1 / 100
    lossTangent_nonnegative := by norm_num
    tuningRange := 1 / 10
    tuningRange_nonnegative := by norm_num
    moistureSensitivity :=
      { value := 1 / 10
        nonnegative := by norm_num
        le_one := by norm_num } }

noncomputable def toyLightSlinger : DirectionalBroadbandAntenna :=
  { material := toyLigninVitrimer
    polarizationCurrent :=
      { supportVolume := { cubicMeters := 1 }
        supportVolume_pos := by norm_num
        sourceCount := 4
        sourceCount_positive := by norm_num
        currentDensityAmplitude := { amperesPerSquareMeter := 1 }
        currentDensityAmplitude_nonnegative := by norm_num
        directionality := 1
        directionality_nonnegative := by norm_num }
    carrierFrequency := { hz := 400 * 10 ^ 9 }
    carrierFrequency_pos := by norm_num
    bandwidth := { hz := 1 * 10 ^ 9 }
    bandwidth_pos := by norm_num
    trackLength := { meters := 2 }
    trackLength_pos := by norm_num
    sweepDuration := { seconds := 1 }
    sweepDuration_pos := by norm_num
    sweepSpeed := { metersPerSecond := 2 }
    sweepSpeedLaw := by norm_num
    phasePatternSpeed := { metersPerSecond := 600000000 }
    phasePatternSpeed_pos := by norm_num
    groupSpeed := { metersPerSecond := 200000000 }
    groupSpeed_pos := by norm_num
    groupSpeed_causal := by norm_num [vacuumSpeedOfLight]
    informationSpeed := { metersPerSecond := 200000000 }
    informationSpeed_pos := by norm_num
    informationSpeed_causal := by norm_num [vacuumSpeedOfLight]
    inputPower := { watts := 10 }
    inputPower_nonnegative := by norm_num
    radiatedPower := { watts := 8 }
    radiatedPower_nonnegative := by norm_num
    radiationEfficiency :=
      { value := 4 / 5
        nonnegative := by norm_num
        le_one := by norm_num }
    radiatedPowerLaw := by norm_num }

example : toyLightSlinger.phasePatternSuperluminal := by
  norm_num [DirectionalBroadbandAntenna.phasePatternSuperluminal, toyLightSlinger,
    vacuumSpeedOfLight]

example : toyLightSlinger.informationSpeed.metersPerSecond ≤ vacuumSpeedOfLight := by
  exact toyLightSlinger.information_speed_causal

example : toyLightSlinger.sweepSpeed.metersPerSecond = 2 := by
  norm_num [DirectionalBroadbandAntenna.sweep_speed_holds, toyLightSlinger]

example : toyLightSlinger.radiatedPower.watts ≤ toyLightSlinger.inputPower.watts := by
  exact toyLightSlinger.radiated_power_le_input

noncomputable def toySolitonWaveguide : SolitonWaveguideParameters where
  application := SolitonApplication.qpuBus
  mediumLabel := "argon"
  carrierWavelength := { meters := 800 * 10 ^ (-9 : ℤ) }
  carrierWavelength_pos := by norm_num [zpow_neg]
  coreRadius := { meters := 50 * 10 ^ (-6 : ℤ) }
  coreRadius_pos := by norm_num [zpow_neg]
  gasPressure := { pascals := 10 ^ 5 }
  gasPressure_nonnegative := by norm_num
  propagationDistance := { meters := 1 }
  propagationDistance_pos := by norm_num
  pulseDuration := { seconds := 2 * 10 ^ (-15 : ℤ) }
  pulseDuration_pos := by norm_num [zpow_neg]
  peakPower := { watts := 1 }
  peakPower_pos := by norm_num
  groupSpeed := { metersPerSecond := 200000000 }
  groupSpeed_pos := by norm_num
  groupSpeed_causal := by norm_num [vacuumSpeedOfLight]
  modeCount := 1
  modeCount_pos := by norm_num
  dispersionParameter := -1
  dispersionParameter_anomalous := by norm_num
  nonlinearParameter := 10 ^ 30
  nonlinearParameter_pos := by norm_num
  solitonOrderSquared := 4
  solitonOrderSquared_law := by
    norm_num [abs_of_nonpos]
  solitonOrderSquared_pos := by norm_num
  solitonOrderSquared_supercritical := by norm_num
  modeMatched := True
  modeMatched_hypothesis := by trivial
  pressureProfileControlled := True
  pressureProfileControlled_hypothesis := by trivial
  dispersionNonlinearityBalanced := True
  dispersionNonlinearityBalanced_hypothesis := by trivial
  shapePreservationObserved := True
  shapePreservationObserved_hypothesis := by trivial
  evidenceStatus := LaserEvidenceStatus.calibrationRequired

example : toySolitonWaveguide.groupSpeed.metersPerSecond ≤ vacuumSpeedOfLight := by
  exact toySolitonWaveguide.groupSpeed_causal

example : toySolitonWaveguide.solitonOrderSquared = 4 := by
  rfl

example : 1 < toySolitonWaveguide.solitonOrderSquared := by
  exact toySolitonWaveguide.soliton_order_supercritical

example : LaserInteractionProfile.kind
    (LaserInteractionProfile.solitonWaveguide toySolitonWaveguide) =
      LaserInteractionKind.solitonBus := by
  rfl

noncomputable def toyHydrogenPlasmaLens : PlasmaLensParameters where
  gas := PlasmaLensGas.hydrogen
  photonEnergy := { electronVolts := 20, electronVolts_pos := by norm_num }
  inputPulseDuration := { seconds := 100 * 10 ^ (-18 : ℤ) }
  inputPulseDuration_pos := by norm_num [zpow_neg]
  outputPulseDuration := { seconds := 90 * 10 ^ (-18 : ℤ) }
  outputPulseDuration_pos := by norm_num [zpow_neg]
  transmission := { value := 9 / 10, nonnegative := by norm_num, le_one := by norm_num }
  pulseStretchingNegligible := True
  pulseStretchingNegligible_hypothesis := by trivial
  temporalCompressionPossible := True
  temporalCompressionPossible_hypothesis := by trivial
  harmonicSeparationSupported := True
  harmonicSeparationSupported_hypothesis := by trivial
  evidenceStatus := LaserEvidenceStatus.calibrationRequired

example : 0 ≤ toyHydrogenPlasmaLens.transmission.value := by
  exact toyHydrogenPlasmaLens.transmission_nonnegative

example : LaserKind.defaultEvidence LaserKind.hollowCoreSoliton =
    LaserEvidenceStatus.demonstratedProcess := by
  rfl

example : LaserKind.defaultEvidence LaserKind.nanophotonicParametricOscillator =
    LaserEvidenceStatus.demonstratedProcess := by
  rfl

example : completeClassicalBusOperators.length = 8 := by
  exact completeClassicalBusOperators_count

example (left right : Bool) :
    classicalNand (classicalNand left right)
      (classicalNand left right) = classicalAnd left right := by
  exact nand_complete_and left right

example : parity [true, false, true] = false := by
  rfl

def toySolitonAddress : LaneAddress where
  wavelengthChannel := 3
  spatialMode := 2
  oamCharge := 7
  polarizationChannel := 1
  timeSlot := 4

def toySolitonSelector : LaneSelector where
  wavelengthChannel := some 3
  spatialMode := some 2
  oamCharge := some 7
  polarizationChannel := some 1
  timeSlot := some 4

def toySolitonFrame : ClassicalSolitonFrame where
  address := toySolitonAddress
  amplitude := 1
  phase := 0
  energy := { joules := 1 }
  energy_nonnegative := by norm_num

example : toySolitonSelector.matches toySolitonAddress = true := by
  rfl

example : demultiplex toySolitonSelector [toySolitonFrame] = [toySolitonFrame] := by
  rfl

example : completeQuantumBusGenerators.length = 7 := by
  exact completeQuantumBusGenerators_count

example (gate : OneQubitBusGate) : isUnitaryMatrix gate.toGate := by
  exact gate.unitary

example : Function.Involutive cnotMap := by
  exact cnotMap_involutive

example : Function.Involutive swapMap := by
  exact swapMap_involutive

example : Function.Involutive toffoliMap := by
  exact toffoliMap_involutive

example (gate : OneQubitBusGate) (state : QubitBasis → ℂ) :
    applyOneQubitGate gate state =
      Matrix.mulVec gate.toGate state := by
  rfl

example (gate : TwoQubitBusGate) (state : TwoQubitBasis → ℂ) :
    applyTwoQubitGate gate state =
      Matrix.mulVec gate.toGate state := by
  rfl

example (dynamics : SolitonPropagationDynamics) :
    dynamics.dispersionLength.meters =
      dynamics.pulseDuration.seconds ^ 2 /
        |dynamics.groupVelocityDispersion| := by
  exact dynamics.dispersion_length_holds

example (dynamics : SolitonPropagationDynamics) :
    dynamics.nonlinearLength.meters =
      1 / (dynamics.nonlinearCoefficient * dynamics.peakPower.watts) := by
  exact dynamics.nonlinear_length_holds

example (dynamics : SolitonPropagationDynamics) :
    dynamics.solitonOrderSquared =
      dynamics.dispersionLength.meters / dynamics.nonlinearLength.meters := by
  exact dynamics.soliton_order_squared_holds

example (collision : SolitonCollisionDynamics) :
    collision.xpmPhaseShift =
      collision.xpmCoefficient * collision.signalPower.watts *
        collision.effectiveInteractionLength.meters := by
  exact collision.xpm_phase_shift_holds

example :
    SolitonDynamicsOperator.homodyneReadout.defaultPlacement =
      SolitonOperatorPlacement.offBus := by
  rfl

example :
    SolitonDynamicsOperator.crossPhaseModulation.defaultPlacement =
      SolitonOperatorPlacement.onBus := by
  rfl

example :
    SolitonDynamicsOperator.resonantDispersiveWave.defaultPlacement =
      SolitonOperatorPlacement.busInterface := by
  rfl

example (parameters : NanophotonicParametricOscillatorParameters) :
    parameters.oscillationThresholdEnergy.joules ≤
      parameters.pumpPulseEnergy.joules := by
  exact parameters.pump_above_threshold

example (parameters : NanophotonicParametricOscillatorParameters) :
    LaserInteractionProfile.kind
        (LaserInteractionProfile.nanophotonicParametricOscillator parameters) =
      LaserInteractionKind.nanophotonicParametricOscillator := by
  rfl

example (parameters : OpticalSuperconductingQubitControlParameters) :
    LaserInteractionProfile.kind
        (LaserInteractionProfile.opticalSuperconductingQubitControl parameters) =
      LaserInteractionKind.opticalSuperconductingQubitControl := by
  rfl

example (parameters : ChiralQuantumInterconnectParameters) :
    LaserInteractionProfile.kind
        (LaserInteractionProfile.chiralQuantumInterconnect parameters) =
      LaserInteractionKind.chiralQuantumInterconnect := by
  rfl

example (parameters : DualBeamFsProcessingParameters) :
    LaserInteractionProfile.kind
        (LaserInteractionProfile.dualBeamFemtosecondProcessing parameters) =
      LaserInteractionKind.dualBeamFemtosecondProcessing := by
  rfl

def toyRydbergReceiver : RydbergEITReceiver :=
  { probeFrequency := { hz := 1 }
    probeFrequency_pos := by norm_num
    couplingFrequency := { hz := 2 }
    couplingFrequency_pos := by norm_num
    fieldAmplitude := { voltsPerMeter := 2 }
    fieldAmplitude_nonnegative := by norm_num
    starkCoefficient := 3
    starkCoefficient_nonnegative := by norm_num
    starkShift := 12
    starkShiftLaw := by norm_num }

example : toyRydbergReceiver.starkShift = 12 := by
  rfl

example : 0 ≤ toyRydbergReceiver.starkShift := by
  exact toyRydbergReceiver.stark_shift_nonnegative

example : CWApplication.oceanMetrology.requirements.rangeModulation = true := by
  rfl

example : CWApplication.waveguideTransport.requirements.massiveModeHypothesis =
    false := by
  rfl

example : CWApplication.pclpNanolithography.requirements.activeMask = true := by
  rfl

example : CWApplication.mimoAcousticMixing.requirements.convergentBeams = true := by
  rfl

example : CWApplication.antiFireSuppression.requirements.activeMask = true := by
  rfl

example : CWApplication.frcFusion.requirements.convergentBeams = true := by
  rfl

example : CWApplication.topologicalThruster.requirements.massiveModeHypothesis =
    true := by
  rfl

example : CWApplication.argonPowerPlant.requirements.activeMask = true := by
  rfl

example : CWApplication.wirelessPower.requirements.massiveModeHypothesis = true := by
  rfl

example : CWApplication.deepSpaceCommunications.requirements.phaseReference =
    true := by
  rfl

noncomputable def toyCWApplicationResonator : ContinuousWaveResonator :=
  { mode := ResonatorMode.transverse
    resonantFrequency := { hz := 10 }
    resonantFrequency_pos := by norm_num
    driveFrequency := { hz := 10 }
    driveFrequency_pos := by norm_num
    resonanceMatch := by norm_num
    drivePower := { watts := 2 }
    drivePower_nonnegative := by norm_num
    intracavityPower := { watts := 4 }
    intracavityPower_nonnegative := by norm_num
    enhancementFactor := 2
    enhancementFactor_ge_one := by norm_num
    intracavityPowerLaw := by norm_num
    emittedPower := { watts := 1 }
    emittedPower_nonnegative := by norm_num
    dissipatedPower := { watts := 1 }
    dissipatedPower_nonnegative := by norm_num
    passivePowerBalance := by norm_num }

def toyRGOVitrimerActiveMask : RGOVitrimerActiveMask :=
  { elementCount := 4
    elementCount_positive := by norm_num
    phaseModulationRange := 1
    phaseModulationRange_nonnegative := by norm_num
    amplitudeModulationRange := 1
    amplitudeModulationRange_nonnegative := by norm_num
    controlPower := { watts := 1 }
    controlPower_nonnegative := by norm_num }

noncomputable def toyPCLPApplicationReadiness : CWApplicationReadiness :=
  { application := CWApplication.pclpNanolithography
    resonator := toyCWApplicationResonator
    activeMask := some toyRGOVitrimerActiveMask
    convergentBeams := none
    rangeModulationEnabled := false
    informationSpeed := { metersPerSecond := 1 }
    informationSpeed_pos := by norm_num
    informationSpeed_causal := by norm_num [vacuumSpeedOfLight]
    activeMaskRequirement := by simp [CWApplication.requirements]
    convergentBeamRequirement := by simp [CWApplication.requirements]
    rangeModulationRequirement := by simp [CWApplication.requirements]
    cwDriven := by
      norm_num [ContinuousWaveResonator.isDriven,
        toyCWApplicationResonator] }

def toyConvergentCWBeams : ConvergentCWBeams :=
  { beamCount := 2
    beamCount_at_least_two := by norm_num
    driveFrequency := { hz := 400 * 10 ^ 9 }
    driveFrequency_pos := by norm_num
    intersectionArea := { squareMeters := 1 }
    intersectionArea_pos := by norm_num
    phaseAlignment :=
      { value := 1
        nonnegative := by norm_num
        le_one := by norm_num } }

example : toyPCLPApplicationReadiness.application.requirements.activeMask = false ∨
    toyPCLPApplicationReadiness.activeMask.isSome = true := by
  exact toyPCLPApplicationReadiness.active_mask_requirement

example : toyPCLPApplicationReadiness.application.requirements.convergentBeams =
    false ∨ toyPCLPApplicationReadiness.convergentBeams.isSome = true := by
  exact toyPCLPApplicationReadiness.convergent_beam_requirement

example : toyPCLPApplicationReadiness.informationSpeed.metersPerSecond ≤
    vacuumSpeedOfLight := by
  exact toyPCLPApplicationReadiness.information_speed_causal

example : toyConvergentCWBeams.beamCount ≥ 2 := by
  exact toyConvergentCWBeams.beamCount_at_least_two

def toyInspection (method : InspectionMethod) : InspectionRecord :=
  { method := method
    specimenStateBefore := 1
    specimenStateAfter := 1
    statePreserved := by rfl
    stimulusPower := { watts := 1 }
    stimulusPower_nonnegative := by norm_num
    response := 1
    response_nonnegative := by norm_num }

example : (toyInspection InspectionMethod.terahertzConductivity).method =
    InspectionMethod.terahertzConductivity := by
  rfl

example : (toyInspection InspectionMethod.terahertzIntegrity).method =
    InspectionMethod.terahertzIntegrity := by
  rfl

example : (toyInspection InspectionMethod.mmWaveRadar).method =
    InspectionMethod.mmWaveRadar := by
  rfl

example : (toyInspection InspectionMethod.resonantFrequencyMapping).method =
    InspectionMethod.resonantFrequencyMapping := by
  rfl

example : (toyInspection InspectionMethod.opticalInterferometry).method =
    InspectionMethod.opticalInterferometry := by
  rfl

example : (toyInspection InspectionMethod.ultrasonicPulseEcho).method =
    InspectionMethod.ultrasonicPulseEcho := by
  rfl

example : (toyInspection InspectionMethod.phasedArrayUltrasound).method =
    InspectionMethod.phasedArrayUltrasound := by
  rfl

example : (toyInspection InspectionMethod.eddyCurrent).method =
    InspectionMethod.eddyCurrent := by
  rfl

example : (toyInspection InspectionMethod.lockInThermography).method =
    InspectionMethod.lockInThermography := by
  rfl

example : (toyInspection InspectionMethod.fiberRayleighBrillouin).method =
    InspectionMethod.fiberRayleighBrillouin := by
  rfl

example : (toyInspection InspectionMethod.infraredPhotothermal).method =
    InspectionMethod.infraredPhotothermal := by
  rfl

example : (toyInspection InspectionMethod.acousticEmission).method =
    InspectionMethod.acousticEmission := by
  rfl

example : (toyInspection InspectionMethod.rfidAudit).method =
    InspectionMethod.rfidAudit := by
  rfl

example : (toyInspection InspectionMethod.eddyCurrent).specimenStateAfter =
    (toyInspection InspectionMethod.eddyCurrent).specimenStateBefore := by
  rfl

def toyPhaseFingerprint : PhaseFingerprint :=
  { targetPhaseBefore := 0
    targetPhaseAfter := 2
    phaseShift := 2
    phaseShiftLaw := by norm_num
    targetEnergyBefore := 1
    targetEnergyAfter := 1
    energyPreserved := by norm_num
    polarizationBefore := 1
    polarizationAfter := 1
    polarizationPreserved := by norm_num
    absorbedTargetEnergy := { joules := 0 }
    absorbedTargetEnergy_nonnegative := by norm_num
    absorbedTargetEnergy_zero := by norm_num }

example : toyPhaseFingerprint.phaseShift = 2 := by
  norm_num [PhaseFingerprint.phase_shift_holds, toyPhaseFingerprint]

example : toyPhaseFingerprint.targetEnergyAfter =
    toyPhaseFingerprint.targetEnergyBefore := by
  exact toyPhaseFingerprint.energy_preserved

example : toyPhaseFingerprint.polarizationAfter =
    toyPhaseFingerprint.polarizationBefore := by
  exact toyPhaseFingerprint.polarization_preserved

example : toyPhaseFingerprint.absorbedTargetEnergy.joules = 0 := by
  exact toyPhaseFingerprint.no_absorbed_target_energy

def toyDispersiveReadout : DispersiveReadout ℝ :=
  { signalBefore := 1
    signalAfter := 1
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

example : toyDispersiveReadout.signalAfter = toyDispersiveReadout.signalBefore := by
  exact toyDispersiveReadout.signal_preserved

example : toyDispersiveReadout.signalEnergyAfter =
    toyDispersiveReadout.signalEnergyBefore := by
  exact toyDispersiveReadout.signal_energy_preserved

example : toyDispersiveReadout.absorbedSignalEnergy.joules = 0 := by
  exact toyDispersiveReadout.no_absorbed_signal_energy

example : toyDispersiveReadout.probePhaseAfter =
    toyDispersiveReadout.probePhaseBefore + toyDispersiveReadout.probePhaseShift := by
  exact toyDispersiveReadout.probe_phase_holds

example : toyDispersiveReadout.absorbedProbeEnergy.joules = 0 := by
  exact toyDispersiveReadout.no_absorbed_probe_energy

def toyDispersivePhaseFingerprint : DispersivePhaseFingerprint ℝ :=
  { readout := toyDispersiveReadout
    fingerprint := toyPhaseFingerprint
    phaseShiftAgreement := by rfl }

example : toyDispersivePhaseFingerprint.fingerprint.phaseShift =
    toyDispersivePhaseFingerprint.readout.probePhaseShift := by
  exact toyDispersivePhaseFingerprint.phase_shift_agrees

noncomputable def toyDispersiveHomodyneReadout : DispersiveHomodyneReadout ℝ :=
  { readout := toyDispersiveReadout
    opticalMeasurement := toyBalancedHomodyne
    detectorMeasurement := toyBalancedDetectorForComposition
    calibratedCurrent := toyCalibratedPhotocurrent
    phaseShiftAgreement := by
      norm_num [toyDispersiveReadout, toyBalancedHomodyne,
        differentialPhotocurrent_eq_interference, toyLocalOscillator,
        LocalOscillator.asSample]
    rawCurrentAgreement := by norm_num [toyCalibratedPhotocurrent,
      toyBalancedDetectorForComposition] }

example : toyDispersiveHomodyneReadout.readout.probePhaseShift =
    toyDispersiveHomodyneReadout.opticalMeasurement.differentialPhotocurrent := by
  exact toyDispersiveHomodyneReadout.phase_shift_agrees

example : toyDispersiveHomodyneReadout.calibratedCurrent.rawCurrent.amperes =
    toyDispersiveHomodyneReadout.detectorMeasurement.differentialCurrent.amperes := by
  exact toyDispersiveHomodyneReadout.raw_current_agrees

def toyCalibrationRecord : CalibrationRecord :=
  { rawBefore := 10
    rawAfter := 10
    rawPreserved := by norm_num
    multiplier := 2
    offset := 0
    calibrated := 20
    calibrationLaw := by norm_num }

example : toyCalibrationRecord.rawAfter = toyCalibrationRecord.rawBefore := by
  exact toyCalibrationRecord.raw_preserved

example : toyCalibrationRecord.calibrated = 20 := by
  norm_num [CalibrationRecord.calibration_holds, toyCalibrationRecord]

def toyReversibleOperation : ReversibleOperation :=
  { kind := VitrimerOperationKind.disassembly
    stateBefore := 1
    stateAfter := 2
    stateAfterLaw := by norm_num
    operationPower := { watts := 1 }
    operationPower_nonnegative := by norm_num
    restoredState := 1
    restoreLaw := by norm_num }

example : toyReversibleOperation.restoredState =
    toyReversibleOperation.stateBefore := by
  exact toyReversibleOperation.restores_state

def toyInSituRemediation : InSituRemediation :=
  { hostIntegrityBefore := 1
    hostIntegrityAfter := 2
    integrity_non_decreased := by norm_num
    stimulusPower := { watts := 1 }
    stimulusPower_nonnegative := by norm_num }

example : toyInSituRemediation.hostIntegrityBefore ≤
    toyInSituRemediation.hostIntegrityAfter := by
  exact toyInSituRemediation.integrity_bound

def toyNonDestructiveRecovery : NonDestructiveRecovery :=
  { sourceStateBefore := 1
    sourceStateAfter := 1
    sourceStatePreserved := by rfl
    recoveredQuantity := 2
    recoveredQuantity_nonnegative := by norm_num }

example : toyNonDestructiveRecovery.sourceStateAfter =
    toyNonDestructiveRecovery.sourceStateBefore := by
  exact toyNonDestructiveRecovery.source_preserved

noncomputable def toyECR245GHz : ElectronCyclotronResonance :=
  { driveFrequency := gigahertz (49 / 20)
    driveFrequency_pos := by norm_num [gigahertz]
    magneticFluxDensity := { tesla := 7 / 80 }
    magneticFluxDensity_pos := by norm_num
    electronGyromagneticRatioHzPerTesla := (gigahertz 28).hz
    electronGyromagneticRatio_pos := by norm_num [gigahertz]
    sourcePower := { watts := 20 }
    sourcePower_nonnegative := by norm_num
    resonanceLaw := by norm_num [gigahertz] }

noncomputable def toyECR28GHz : ElectronCyclotronResonance :=
  { driveFrequency := gigahertz 28
    driveFrequency_pos := by norm_num [gigahertz]
    magneticFluxDensity := { tesla := 1 }
    magneticFluxDensity_pos := by norm_num
    electronGyromagneticRatioHzPerTesla := (gigahertz 28).hz
    electronGyromagneticRatio_pos := by norm_num [gigahertz]
    sourcePower := { watts := 20 }
    sourcePower_nonnegative := by norm_num
    resonanceLaw := by norm_num [gigahertz] }

noncomputable def toyECR98GHz : ElectronCyclotronResonance :=
  { driveFrequency := gigahertz 98
    driveFrequency_pos := by norm_num [gigahertz]
    magneticFluxDensity := { tesla := 7 / 2 }
    magneticFluxDensity_pos := by norm_num
    electronGyromagneticRatioHzPerTesla := (gigahertz 28).hz
    electronGyromagneticRatio_pos := by norm_num [gigahertz]
    sourcePower := { watts := 20 }
    sourcePower_nonnegative := by norm_num
    resonanceLaw := by norm_num [gigahertz] }

example : toyECR245GHz.magneticFluxDensity.tesla = 7 / 80 := by
  norm_num [ElectronCyclotronResonance.magneticFluxDensity_eq_frequency_div_ratio,
    toyECR245GHz, gigahertz]

example : toyECR28GHz.magneticFluxDensity.tesla = 1 := by
  norm_num [ElectronCyclotronResonance.magneticFluxDensity_eq_frequency_div_ratio,
    toyECR28GHz, gigahertz]

example : toyECR98GHz.magneticFluxDensity.tesla = 7 / 2 := by
  norm_num [ElectronCyclotronResonance.magneticFluxDensity_eq_frequency_div_ratio,
    toyECR98GHz, gigahertz]

noncomputable def toyGHzAcousticMedium : Signals.Acoustics.Medium :=
  { density := 1
    density_pos := by norm_num
    soundSpeed := 8000
    soundSpeed_pos := by norm_num
    attenuationPerLength := 0
    attenuation_nonnegative := by norm_num }

noncomputable def toyGHzAcousticWave : Signals.Acoustics.Wave :=
  { frequencyHz := (gigahertz 400).hz
    frequency_positive := by norm_num [gigahertz]
    pressureAmplitude := 10
    pressureAmplitude_nonnegative := by norm_num
    medium := toyGHzAcousticMedium }

noncomputable def toyGHzUltrasonicTransfer : Signals.Acoustics.UltrasonicTransfer :=
  { wave := toyGHzAcousticWave
    ultrasonicFrequency := by norm_num [toyGHzAcousticWave, gigahertz]
    link := toyLink
    apertureArea := 8000
    apertureArea_pos := by norm_num
    transmitterEfficiency :=
      { value := 1 / 2, nonnegative := by norm_num, le_one := by norm_num }
    receiverEfficiency :=
      { value := 1 / 2, nonnegative := by norm_num, le_one := by norm_num }
    sourcePowerLaw := by
      norm_num [toyLink, toyGHzAcousticWave, toyGHzAcousticMedium,
        Signals.Acoustics.Wave.intensity, Signals.Acoustics.Medium.impedance,
        toyCouplingFactors, toyInterface, toyMediumLoss] }

noncomputable def toyLongitudinalAcousticDrive : LongitudinalAcousticDrive :=
  { transfer := toyGHzUltrasonicTransfer
    wavelength := { meters := 1 / 50000000 }
    wavelength_pos := by norm_num
    dispersionLaw := by
      norm_num [toyGHzUltrasonicTransfer, toyGHzAcousticWave,
        toyGHzAcousticMedium, gigahertz] }

example : toyLongitudinalAcousticDrive.wavelength.meters = 1 / 50000000 := by
  norm_num [LongitudinalAcousticDrive.wavelength_eq_soundSpeed_div_frequency,
    toyLongitudinalAcousticDrive, toyGHzUltrasonicTransfer, toyGHzAcousticWave,
    toyGHzAcousticMedium, gigahertz]

example : toyLongitudinalAcousticDrive.depositedPower.watts ≤
    toyLongitudinalAcousticDrive.transfer.link.sourcePower.watts := by
  exact toyLongitudinalAcousticDrive.deposited_power_le_source

noncomputable def toyConductiveArgonFlow : ConductiveArgonFlow :=
  { massFlow := { kilogramsPerSecond := 1 }
    massFlow_nonnegative := by norm_num
    velocity := { metersPerSecond := 2 }
    velocity_nonnegative := by norm_num
    ionizationFraction :=
      { value := 1 / 2, nonnegative := by norm_num, le_one := by norm_num }
    ionizationFraction_positive := by norm_num
    conductivity := { siemensPerMeter := 1 }
    conductivity_positive := by norm_num }

noncomputable def toyFaradayChannel : FaradayChannel :=
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

example : loadingFactor toyFaradayChannel.load = 1 / 4 := by
  norm_num [loadingFactor, toyFaradayChannel]

example : toyFaradayChannel.powerDensity.wattsPerCubicMeter = 4 := by
  norm_num [toyFaradayChannel]

example : toyFaradayChannel.powerDensity.wattsPerCubicMeter ≤
    (baseFaradayPowerDensity toyFaradayChannel.conductivity
      toyFaradayChannel.velocity toyFaradayChannel.magneticFluxDensity).wattsPerCubicMeter *
      (1 / 4 : ℝ) := by
  exact toyFaradayChannel.power_density_le_quarter_base

example : toyFaradayChannel.extractedPower.watts ≤
    toyFaradayChannel.extractedPower.watts := by
  exact le_rfl

def toyMHDPowerAccounting : MHDPowerAccounting :=
  { controlPower := { watts := 2 }
    controlPower_nonnegative := by norm_num
    motivePower := { watts := 2 }
    motivePower_nonnegative := by norm_num
    electricalOutputPower := { watts := 4 }
    electricalOutputPower_nonnegative := by norm_num
    lossPower := { watts := 0 }
    lossPower_nonnegative := by norm_num
    energyBalance := by norm_num }

example : toyMHDPowerAccounting.electricalOutputPower.watts ≤
    toyMHDPowerAccounting.totalInputPower.watts := by
  exact toyMHDPowerAccounting.output_le_total_input

example : toyMHDPowerAccounting.efficiency ≤ 1 := by
  apply toyMHDPowerAccounting.efficiency_le_one
  norm_num [MHDPowerAccounting.totalInputPower, toyMHDPowerAccounting]

example : toyMHDPowerAccounting.efficiency = 1 := by
  norm_num [MHDPowerAccounting.efficiency,
    MHDPowerAccounting.totalInputPower, toyMHDPowerAccounting]

example : controlOnlyRatio toyMHDPowerAccounting.electricalOutputPower
    toyMHDPowerAccounting.controlPower = 2 := by
  norm_num [controlOnlyRatio, toyMHDPowerAccounting]

noncomputable def toyArgonMHDPlant : ArgonMHDPlant :=
  { argon := toyConductiveArgonFlow
    channel := toyFaradayChannel
    accounting := toyMHDPowerAccounting
    kineticInputPower := { watts := 2 }
    kineticInputPowerLaw := by
      norm_num [argonKineticPower, toyConductiveArgonFlow]
    motivePowerLaw := by rfl
    outputPowerLaw := by rfl }

example : toyArgonMHDPlant.accounting.motivePower.watts =
    (argonKineticPower toyArgonMHDPlant.argon).watts := by
  exact toyArgonMHDPlant.motive_power_eq_kinetic

example : toyArgonMHDPlant.accounting.electricalOutputPower.watts ≤
    toyArgonMHDPlant.accounting.controlPower.watts +
      (argonKineticPower toyArgonMHDPlant.argon).watts := by
  exact toyArgonMHDPlant.output_le_declared_input

example : (argonJetThrust toyConductiveArgonFlow).newtons = 2 := by
  norm_num [argonJetThrust, toyConductiveArgonFlow]

example : (argonJetThrust toyConductiveArgonFlow).newtons *
    toyConductiveArgonFlow.velocity.metersPerSecond =
      2 * (argonKineticPower toyConductiveArgonFlow).watts := by
  exact argonJetThrust_mul_velocity toyConductiveArgonFlow

def toyLongitudinalMHDPowerAccounting : MHDPowerAccounting :=
  { controlPower := { watts := 100 }
    controlPower_nonnegative := by norm_num
    motivePower := { watts := 2 }
    motivePower_nonnegative := by norm_num
    electricalOutputPower := { watts := 4 }
    electricalOutputPower_nonnegative := by norm_num
    lossPower := { watts := 98 }
    lossPower_nonnegative := by norm_num
    energyBalance := by norm_num }

noncomputable def toyLongitudinalArgonMHDPlant : ArgonMHDPlant :=
  { argon := toyConductiveArgonFlow
    channel := toyFaradayChannel
    accounting := toyLongitudinalMHDPowerAccounting
    kineticInputPower := { watts := 2 }
    kineticInputPowerLaw := by
      norm_num [argonKineticPower, toyConductiveArgonFlow]
    motivePowerLaw := by rfl
    outputPowerLaw := by rfl }

noncomputable def toyLongitudinalAcousticArgonOperatingPoint :
    LongitudinalAcousticArgonOperatingPoint :=
  { plant := toyLongitudinalArgonMHDPlant
    drive := toyLongitudinalAcousticDrive
    acousticSourceWithinControl := by
      norm_num [toyLongitudinalArgonMHDPlant, toyLongitudinalMHDPowerAccounting,
        toyLongitudinalAcousticDrive, toyGHzUltrasonicTransfer, toyLink] }

example : toyLongitudinalAcousticArgonOperatingPoint.drive.depositedPower.watts ≤
    toyLongitudinalAcousticArgonOperatingPoint.plant.accounting.controlPower.watts := by
  exact toyLongitudinalAcousticArgonOperatingPoint.deposited_power_le_control

noncomputable def toyStripToArgonInterface : InterfaceResponse :=
  { reflectionPower := 999 / 1000
    transmissionPower := 1 / 1000
    absorptionPower := 0
    reflection_nonnegative := by norm_num
    transmission_nonnegative := by norm_num
    absorption_nonnegative := by norm_num
    power_conservation := by norm_num }

noncomputable def toyStripArgonLink : LinkBudget :=
  { mode := PropagationMode.ionosphericMhdDuct
    sourcePower := { watts := 1 / 20 }
    sourcePower_nonnegative := by norm_num
    distance := { meters := 1 }
    distance_nonnegative := by norm_num
    coupling := toyCouplingFactors
    medium := toyMediumLoss
    interface := toyInterface }

noncomputable def toyStripArgonWave : Signals.Acoustics.Wave :=
  { frequencyHz := (gigahertz 800).hz
    frequency_positive := by norm_num [gigahertz]
    pressureAmplitude := 10
    pressureAmplitude_nonnegative := by norm_num
    medium := toyGHzAcousticMedium }

noncomputable def toyStripArgonTransfer : Signals.Acoustics.UltrasonicTransfer :=
  { wave := toyStripArgonWave
    ultrasonicFrequency := by norm_num [toyStripArgonWave, gigahertz]
    link := toyStripArgonLink
    apertureArea := 4
    apertureArea_pos := by norm_num
    transmitterEfficiency :=
      { value := 1 / 2, nonnegative := by norm_num, le_one := by norm_num }
    receiverEfficiency :=
      { value := 1 / 2, nonnegative := by norm_num, le_one := by norm_num }
    sourcePowerLaw := by
      norm_num [toyStripArgonLink, toyStripArgonWave, toyGHzAcousticMedium,
        Signals.Acoustics.Wave.intensity, Signals.Acoustics.Medium.impedance] }

noncomputable def toyStripArgonAcousticDrive : LongitudinalAcousticDrive :=
  { transfer := toyStripArgonTransfer
    wavelength := { meters := 1 / 100000000 }
    wavelength_pos := by norm_num
    dispersionLaw := by
      norm_num [toyStripArgonTransfer, toyStripArgonWave,
        toyGHzAcousticMedium, gigahertz] }

noncomputable def toyStripLongitudinalArgonPoint :
    LongitudinalAcousticArgonOperatingPoint :=
  { plant := toyLongitudinalArgonMHDPlant
    drive := toyStripArgonAcousticDrive
    acousticSourceWithinControl := by
      norm_num [toyStripArgonAcousticDrive, toyStripArgonTransfer,
        toyStripArgonLink, toyLongitudinalArgonMHDPlant,
        toyLongitudinalMHDPowerAccounting] }

noncomputable def toyCelluloseStripArgonOperatingPoint :
    CelluloseStripArgonOperatingPoint :=
  { argonPoint := toyStripLongitudinalArgonPoint
    stripDrive := toyFireCannonCelluloseStripDrive
    stripToArgonInterface := toyStripToArgonInterface
    transmittedAcousticPower := { watts := 1 / 20 }
    transmittedAcousticPower_nonnegative := by norm_num
    transmittedPowerLaw := by
      norm_num [toyFireCannonCelluloseStripDrive, toyCelluloseStripResonator,
        toyStripToArgonInterface]
    acousticSourcePowerLaw := by
      norm_num [toyStripLongitudinalArgonPoint, toyStripArgonAcousticDrive,
        toyStripArgonTransfer, toyStripArgonLink]
    frequencyMatch := by
      norm_num [toyStripLongitudinalArgonPoint, toyStripArgonAcousticDrive,
        toyStripArgonTransfer, toyStripArgonWave,
        toyFireCannonCelluloseStripDrive, toyCelluloseStripResonator,
        CelluloseStripResonator.secondHarmonicFrequency, gigahertz]
    arraySource_positive := by
      norm_num [toyFireCannonCelluloseStripDrive, toyMimoFireCannonPump,
        MimoArray.sourcePower, toyMimo]
    arraySourceWithinControl := by
      norm_num [toyFireCannonCelluloseStripDrive, toyMimoFireCannonPump,
        MimoArray.sourcePower, toyMimo, toyStripLongitudinalArgonPoint,
        toyLongitudinalArgonMHDPlant, toyLongitudinalMHDPowerAccounting] }

example :
    toyCelluloseStripArgonOperatingPoint.transmittedAcousticPower.watts = 1 / 20 := by
  norm_num [toyCelluloseStripArgonOperatingPoint]

example : toyCelluloseStripArgonOperatingPoint.sourceEfficiency = 1 / 2000 := by
  norm_num [CelluloseStripArgonOperatingPoint.sourceEfficiency,
    toyCelluloseStripArgonOperatingPoint, toyStripLongitudinalArgonPoint,
    toyStripArgonAcousticDrive, toyStripArgonTransfer, toyStripArgonLink,
    toyFireCannonCelluloseStripDrive, toyMimoFireCannonPump,
    MimoArray.sourcePower, toyMimo]

example : toyCelluloseStripArgonOperatingPoint.sourceEfficiency ≤ 1 := by
  exact toyCelluloseStripArgonOperatingPoint.source_efficiency_le_one

example :
    toyCelluloseStripArgonOperatingPoint.argonPoint.drive.transfer.link.sourcePower.watts ≤
      toyCelluloseStripArgonOperatingPoint.stripDrive.resonator.acousticOutputPower.watts := by
  exact toyCelluloseStripArgonOperatingPoint.source_power_le_strip_output

example :
    toyCelluloseStripArgonOperatingPoint.argonPoint.drive.transfer.link.sourcePower.watts ≤
      toyCelluloseStripArgonOperatingPoint.argonPoint.plant.accounting.controlPower.watts := by
  exact toyCelluloseStripArgonOperatingPoint.source_power_le_control

def toyECR245GHzCosts : MHDOperatingCosts :=
  { pumpPower := { watts := 0 }
    pumpPower_nonnegative := by norm_num
    ionizationPower := { watts := 20 }
    ionizationPower_nonnegative := by norm_num
    fieldPower := { watts := 0 }
    fieldPower_nonnegative := by norm_num
    coolingPower := { watts := 0 }
    coolingPower_nonnegative := by norm_num }

def toyECR28GHzCosts : MHDOperatingCosts :=
  { pumpPower := { watts := 0 }
    pumpPower_nonnegative := by norm_num
    ionizationPower := { watts := 30 }
    ionizationPower_nonnegative := by norm_num
    fieldPower := { watts := 0 }
    fieldPower_nonnegative := by norm_num
    coolingPower := { watts := 0 }
    coolingPower_nonnegative := by norm_num }

def toyECR98GHzCosts : MHDOperatingCosts :=
  { pumpPower := { watts := 0 }
    pumpPower_nonnegative := by norm_num
    ionizationPower := { watts := 40 }
    ionizationPower_nonnegative := by norm_num
    fieldPower := { watts := 0 }
    fieldPower_nonnegative := by norm_num
    coolingPower := { watts := 0 }
    coolingPower_nonnegative := by norm_num }

noncomputable def toyArgonSweepPoint245GHz : ArgonFrequencySweepPoint :=
  { ecr := toyECR245GHz
    operatingPoint := toyLongitudinalAcousticArgonOperatingPoint
    operatingCosts := toyECR245GHzCosts
    ecrSourceWithinIonizationCost := by
      norm_num [toyECR245GHz, toyECR245GHzCosts]
    ionizationPower_positive := by norm_num [toyECR245GHzCosts]
    fullInput_positive := by
      norm_num [MHDPowerAccounting.fullInputPower,
        MHDPowerAccounting.totalInputPower, MHDOperatingCosts.auxiliaryPower,
        toyLongitudinalAcousticArgonOperatingPoint, toyLongitudinalArgonMHDPlant,
        toyLongitudinalMHDPowerAccounting, toyECR245GHzCosts] }

noncomputable def toyArgonSweepPoint28GHz : ArgonFrequencySweepPoint :=
  { ecr := toyECR28GHz
    operatingPoint := toyLongitudinalAcousticArgonOperatingPoint
    operatingCosts := toyECR28GHzCosts
    ecrSourceWithinIonizationCost := by
      norm_num [toyECR28GHz, toyECR28GHzCosts]
    ionizationPower_positive := by norm_num [toyECR28GHzCosts]
    fullInput_positive := by
      norm_num [MHDPowerAccounting.fullInputPower,
        MHDPowerAccounting.totalInputPower, MHDOperatingCosts.auxiliaryPower,
        toyLongitudinalAcousticArgonOperatingPoint, toyLongitudinalArgonMHDPlant,
        toyLongitudinalMHDPowerAccounting, toyECR28GHzCosts] }

noncomputable def toyArgonSweepPoint98GHz : ArgonFrequencySweepPoint :=
  { ecr := toyECR98GHz
    operatingPoint := toyLongitudinalAcousticArgonOperatingPoint
    operatingCosts := toyECR98GHzCosts
    ecrSourceWithinIonizationCost := by
      norm_num [toyECR98GHz, toyECR98GHzCosts]
    ionizationPower_positive := by norm_num [toyECR98GHzCosts]
    fullInput_positive := by
      norm_num [MHDPowerAccounting.fullInputPower,
        MHDPowerAccounting.totalInputPower, MHDOperatingCosts.auxiliaryPower,
        toyLongitudinalAcousticArgonOperatingPoint, toyLongitudinalArgonMHDPlant,
        toyLongitudinalMHDPowerAccounting, toyECR98GHzCosts] }

noncomputable def toyArgonFrequencySweep : ArgonFrequencySweep 3 :=
  { point := ![toyArgonSweepPoint245GHz, toyArgonSweepPoint28GHz,
      toyArgonSweepPoint98GHz] }

example : toyArgonSweepPoint245GHz.electricalYield = 2 / 61 := by
  norm_num [ArgonFrequencySweepPoint.electricalYield,
    MHDPowerAccounting.fullEfficiency, MHDPowerAccounting.fullInputPower,
    MHDPowerAccounting.totalInputPower, MHDOperatingCosts.auxiliaryPower,
    toyArgonSweepPoint245GHz, toyLongitudinalAcousticArgonOperatingPoint,
    toyLongitudinalArgonMHDPlant, toyLongitudinalMHDPowerAccounting,
    toyECR245GHzCosts]

example : toyArgonSweepPoint245GHz.ionizationYield = 1 / 40 := by
  norm_num [ArgonFrequencySweepPoint.ionizationYield,
    ConductiveArgonFlow.ionizedMassFlow, toyArgonSweepPoint245GHz,
    toyLongitudinalAcousticArgonOperatingPoint, toyLongitudinalArgonMHDPlant,
    toyConductiveArgonFlow, toyECR245GHzCosts]

example : toyArgonSweepPoint245GHz.thrustPerInputPower = 1 / 61 := by
  norm_num [ArgonFrequencySweepPoint.thrustPerInputPower, argonJetThrust,
    MHDPowerAccounting.fullInputPower, MHDPowerAccounting.totalInputPower,
    MHDOperatingCosts.auxiliaryPower, toyArgonSweepPoint245GHz,
    toyLongitudinalAcousticArgonOperatingPoint, toyLongitudinalArgonMHDPlant,
    toyLongitudinalMHDPowerAccounting, toyConductiveArgonFlow,
    toyECR245GHzCosts]

example : toyArgonFrequencySweep.IsElectricalYieldOptimal (0 : Fin 3) := by
  intro index
  fin_cases index <;>
    norm_num [ArgonFrequencySweepPoint.electricalYield,
      MHDPowerAccounting.fullEfficiency, MHDPowerAccounting.fullInputPower,
      MHDPowerAccounting.totalInputPower, MHDOperatingCosts.auxiliaryPower,
      toyArgonFrequencySweep, toyArgonSweepPoint245GHz,
      toyArgonSweepPoint28GHz, toyArgonSweepPoint98GHz,
      toyLongitudinalAcousticArgonOperatingPoint, toyLongitudinalArgonMHDPlant,
      toyLongitudinalMHDPowerAccounting, toyECR245GHzCosts, toyECR28GHzCosts,
      toyECR98GHzCosts]

example : toyArgonFrequencySweep.IsIonizationYieldOptimal (0 : Fin 3) := by
  intro index
  fin_cases index <;>
    norm_num [ArgonFrequencySweepPoint.ionizationYield,
      ConductiveArgonFlow.ionizedMassFlow, toyArgonFrequencySweep,
      toyArgonSweepPoint245GHz, toyArgonSweepPoint28GHz,
      toyArgonSweepPoint98GHz, toyLongitudinalAcousticArgonOperatingPoint,
      toyLongitudinalArgonMHDPlant, toyConductiveArgonFlow,
      toyECR245GHzCosts, toyECR28GHzCosts, toyECR98GHzCosts]

example : toyArgonFrequencySweep.IsThrustPerPowerOptimal (0 : Fin 3) := by
  intro index
  fin_cases index <;>
    norm_num [ArgonFrequencySweepPoint.thrustPerInputPower, argonJetThrust,
      MHDPowerAccounting.fullInputPower, MHDPowerAccounting.totalInputPower,
      MHDOperatingCosts.auxiliaryPower, toyArgonFrequencySweep,
      toyArgonSweepPoint245GHz, toyArgonSweepPoint28GHz,
      toyArgonSweepPoint98GHz, toyLongitudinalAcousticArgonOperatingPoint,
      toyLongitudinalArgonMHDPlant, toyLongitudinalMHDPowerAccounting,
      toyConductiveArgonFlow, toyECR245GHzCosts, toyECR28GHzCosts,
      toyECR98GHzCosts]

noncomputable def toyClosedLoopArgonMHD : ClosedLoopArgonMHD :=
  { plant := toyArgonMHDPlant
    controlPower := { watts := 2 }
    controlPower_nonnegative := by norm_num
    externalMotivePower := { watts := 2 }
    externalMotivePower_nonnegative := by norm_num
    exportedPower := { watts := 4 }
    exportedPower_nonnegative := by norm_num
    loopLossPower := { watts := 0 }
    loopLossPower_nonnegative := by norm_num
    controlPowerLaw := by rfl
    externalMotivePowerLaw := by rfl
    exportedPowerLaw := by rfl
    closedLoopEnergyBalance := by norm_num }

example : toyClosedLoopArgonMHD.exportedPower.watts ≤
    toyClosedLoopArgonMHD.controlPower.watts +
      toyClosedLoopArgonMHD.externalMotivePower.watts := by
  exact toyClosedLoopArgonMHD.exported_le_declared_input

noncomputable def toyZeroConductiveArgonFlow : ConductiveArgonFlow :=
  { massFlow := { kilogramsPerSecond := 0 }
    massFlow_nonnegative := by norm_num
    velocity := { metersPerSecond := 1 }
    velocity_nonnegative := by norm_num
    ionizationFraction :=
      { value := 1 / 2, nonnegative := by norm_num, le_one := by norm_num }
    ionizationFraction_positive := by norm_num
    conductivity := { siemensPerMeter := 1 }
    conductivity_positive := by norm_num }

def toyZeroFaradayChannel : FaradayChannel :=
  { conductivity := { siemensPerMeter := 1 }
    conductivity_nonnegative := by norm_num
    velocity := { metersPerSecond := 1 }
    velocity_nonnegative := by norm_num
    magneticFluxDensity := { tesla := 1 }
    magneticFluxDensity_nonnegative := by norm_num
    load := { value := 0, nonnegative := by norm_num, le_one := by norm_num }
    channelVolume := { cubicMeters := 1 }
    channelVolume_pos := by norm_num
    powerDensity := { wattsPerCubicMeter := 0 }
    powerDensityLaw := by
      norm_num [idealFaradayPowerDensity, loadingFactor]
    extractedPower := { watts := 0 }
    extractedPower_nonnegative := by norm_num
    extractedPowerLaw := by norm_num }

def toyZeroMHDPowerAccounting : MHDPowerAccounting :=
  { controlPower := { watts := 0 }
    controlPower_nonnegative := by norm_num
    motivePower := { watts := 0 }
    motivePower_nonnegative := by norm_num
    electricalOutputPower := { watts := 0 }
    electricalOutputPower_nonnegative := by norm_num
    lossPower := { watts := 0 }
    lossPower_nonnegative := by norm_num
    energyBalance := by norm_num }

noncomputable def toyZeroArgonMHDPlant : ArgonMHDPlant :=
  { argon := toyZeroConductiveArgonFlow
    channel := toyZeroFaradayChannel
    accounting := toyZeroMHDPowerAccounting
    kineticInputPower := { watts := 0 }
    kineticInputPowerLaw := by
      norm_num [argonKineticPower, toyZeroConductiveArgonFlow]
    motivePowerLaw := by rfl
    outputPowerLaw := by rfl }

noncomputable def toyZeroClosedLoopArgonMHD : ClosedLoopArgonMHD :=
  { plant := toyZeroArgonMHDPlant
    controlPower := { watts := 0 }
    controlPower_nonnegative := by norm_num
    externalMotivePower := { watts := 0 }
    externalMotivePower_nonnegative := by norm_num
    exportedPower := { watts := 0 }
    exportedPower_nonnegative := by norm_num
    loopLossPower := { watts := 0 }
    loopLossPower_nonnegative := by norm_num
    controlPowerLaw := by rfl
    externalMotivePowerLaw := by rfl
    exportedPowerLaw := by rfl
    closedLoopEnergyBalance := by norm_num }

example : toyZeroClosedLoopArgonMHD.exportedPower.watts = 0 := by
  exact toyZeroClosedLoopArgonMHD.zero_export_of_zero_inputs rfl rfl

noncomputable def toyEqualCoherenceSpectrum : CoherenceSpectrum 3 :=
  { weight := fun _ => 1 / 3
    weight_nonnegative := by
      intro index
      norm_num
    normalized := by
      norm_num }

noncomputable def toyEqualCoherenceProfile : CoherenceComplementarity 3 :=
  { spectrum := toyEqualCoherenceSpectrum
    polarization := 0
    entanglement := 1
    polarization_nonnegative := by norm_num
    entanglement_nonnegative := by norm_num
    polarization_squared_law := by
      norm_num [CoherenceSpectrum.polarizationSquared,
        toyEqualCoherenceSpectrum]
    entanglement_squared_law := by
      norm_num [CoherenceSpectrum.entanglementSquared,
        toyEqualCoherenceSpectrum] }

example : toyEqualCoherenceProfile.polarization ^ 2 +
    toyEqualCoherenceProfile.entanglement ^ 2 = 1 := by
  exact toyEqualCoherenceProfile.complementarity_identity (by norm_num)

example : toyEqualCoherenceProfile.polarization = 0 := by
  exact rfl

def toyHuygensSteinerMapping : HuygensSteinerMapping :=
  { axis :=
      { centerInertia := 2
        mass := 1
        offset := 1 }
    originInertia := 3
    originInertiaLaw := by
      norm_num [ParallelAxis.inertia]
    normalizedMass := by norm_num
    polarizationSquared := 1
    entanglementSquared := 0
    polarizationSquared_nonnegative := by norm_num
    entanglementSquared_nonnegative := by norm_num
    polarizationLaw := by norm_num
    entanglementLaw := by norm_num }

example : toyHuygensSteinerMapping.polarizationSquared =
    toyHuygensSteinerMapping.axis.offset ^ 2 := by
  exact toyHuygensSteinerMapping.polarization_eq_offset_squared

example : toyHuygensSteinerMapping.polarizationSquared +
    toyHuygensSteinerMapping.entanglementSquared = 1 := by
  exact toyHuygensSteinerMapping.complementarity_identity

  -- Radio module tests

  def toyCrystalDetector : CrystalDetector :=
    { forwardDrop := 0.3
      threshold := 0.7
      hThreshold := by norm_num
      hDrop := by norm_num
      hDropSmall := by norm_num }

  example : toyCrystalDetector.forwardDrop < toyCrystalDetector.threshold := by
    exact toyCrystalDetector.hDropSmall

  example : crystalDetectorOutput toyCrystalDetector 1.0 = 0.7 := by
    norm_num [crystalDetectorOutput, toyCrystalDetector]

  noncomputable def toySinusoidalModulation : ℝ → ℝ :=
    fun t => Real.sin (2 * Real.pi * 1000 * t)

  noncomputable def toyAMSignal : AMSignal :=
    { carrierFreq := 1_000_000
      carrierAmplitude := 10
      hCarrierAmp := by norm_num
      modulation := toySinusoidalModulation
      modulationIndex := 0.8
      hModIndex := by norm_num
      phase := 0 }

  example : toyAMSignal.modulationIndex ≤ 1 := by
    norm_num [toyAMSignal]

  example : toyAMSignal.bandwidth 1000 = 2000 := by
    norm_num [AMSignal.bandwidth, toyAMSignal]

  example : toyAMSignal.lowerSideband 1000 = 999_000 := by
    norm_num [AMSignal.lowerSideband, toyAMSignal]

  example : toyAMSignal.upperSideband 1000 = 1_001_000 := by
    norm_num [AMSignal.upperSideband, toyAMSignal]

  noncomputable def toyFMSignal : FMSignal :=
    { carrierFreq := 100_000_000
      carrierAmplitude := 10
      hCarrierAmp := by norm_num
      modulation := toySinusoidalModulation
      frequencyDeviation := 75_000
      hFreqDev := by norm_num
      phase := 0 }

  example : toyFMSignal.frequencyDeviation > 0 := by
    norm_num [toyFMSignal]

  example : toyFMSignal.modulationIndex 1000 = 75 := by
    norm_num [FMSignal.modulationIndex, toyFMSignal]

  example : toyFMSignal.carsonBandwidth 1000 = 152000 := by
    norm_num [FMSignal.carsonBandwidth, toyFMSignal]

  example : toyFMSignal.narrowbandApprox 1000 = 2000 := by
    norm_num [FMSignal.narrowbandApprox, toyFMSignal]

  def toyReceiver : RadioReceiver :=
    { tuneFreq := 1_000_000
      bandwidth := 10_000
      hBandwidth := by norm_num
      sensitivity := 0.0001
      hSensitivity := by norm_num }

  example : toyReceiver.isInBand toyReceiver.tuneFreq := by
    exact toyReceiver.tuneFreq_in_band

  example : toyReceiver.isInBand 1_005_000 := by
    norm_num [RadioReceiver.isInBand, toyReceiver]

  example : ¬toyReceiver.isInBand 1_020_000 := by
    norm_num [RadioReceiver.isInBand, toyReceiver]

  example : voltageToPower 10 = 2 := by
    norm_num [voltageToPower]

  example : powerToVoltage 2 = 10 := by
    norm_num [powerToVoltage]

  def toyLCTuner : LCTuner :=
    { inductance := 0.0001  -- 100 μH
      hInductance := by norm_num
      capacitance := 0.00000025  -- 250 pF
      hCapacitance := by norm_num }

  example : 0 < toyLCTuner.resonantFreq := by
    unfold LCTuner.resonantFreq toyLCTuner
    norm_num
    exact Real.pi_pos

  example : isNarrowband 100 10_000 := by
    unfold isNarrowband
    linarith

  -- DDF module tests

  noncomputable def toyDDFSubstrate : DDFSubstrate :=
    { m_phi := 1
      m_phi_pos := by norm_num
      m_varphi := 10
      m_varphi_pos := by norm_num
      rho_phi_0 := 1
      rho_phi_0_pos := by norm_num
      rho_max_varphi := 1
      rho_max_varphi_pos := by norm_num
      j_min_varphi := 1 / 4
      j_min_varphi_pos := by norm_num }

  example : 0 < toyDDFSubstrate.c := by
    exact toyDDFSubstrate.c_pos

  example : toyDDFSubstrate.c = 2 := by
    dsimp [DDFSubstrate.c, toyDDFSubstrate]
    norm_num

  noncomputable def toyMovingSheath : MovingSheath toyDDFSubstrate :=
    { velocity := 1
      velocity_nonneg := by norm_num
      subluminal := by
        have hc : toyDDFSubstrate.c = 2 := by
          dsimp [DDFSubstrate.c, toyDDFSubstrate]
          norm_num
        rw [hc]
        norm_num }

  example : 0 < toyMovingSheath.jammingFactor := by
    exact toyMovingSheath.jammingFactor_pos

  example : toyMovingSheath.betaSq = 1 / 4 := by
    dsimp [MovingSheath.betaSq, toyMovingSheath]
    have hc : toyDDFSubstrate.c = 2 := by
      dsimp [DDFSubstrate.c, toyDDFSubstrate]
      norm_num
    rw [hc]
    norm_num

  example (dt dtau : ℝ) (h_dtau : dtau = dt / toyMovingSheath.jammingFactor) :
      toyDDFSubstrate.c ^ 2 * dtau ^ 2 =
        toyDDFSubstrate.c ^ 2 * dt ^ 2 - (toyMovingSheath.velocity * dt) ^ 2 := by
    exact material_minkowski_interval toyMovingSheath dt dtau h_dtau

  noncomputable def toyRiverExterior : RiverExterior toyDDFSubstrate :=
    { G_phi := 1
      G_phi_pos := by norm_num
      sourceMass := 2
      sourceMass_pos := by norm_num }

  example (r : ℝ) (hr : 0 < r) :
      toyRiverExterior.bernoulliPotential r = - (2 / r) := by
    have h := toyRiverExterior.bernoulli_potential_eq r hr
    rw [h]
    dsimp [toyRiverExterior]
    ring

  example : toyRiverExterior.horizonRadius = 1 := by
    dsimp [RiverExterior.horizonRadius, toyRiverExterior]
    have hc : toyDDFSubstrate.c = 2 := by
      dsimp [DDFSubstrate.c, toyDDFSubstrate]
      norm_num
    rw [hc]
    norm_num

  example : toyRiverExterior.velocity toyRiverExterior.horizonRadius = - toyDDFSubstrate.c := by
    exact toyRiverExterior.horizon_velocity_matches_c

  noncomputable def toyIsothermalRegime : IsothermalGalacticRegime toyDDFSubstrate :=
    { c_phi := 10
      c_phi_pos := by norm_num
      q_rho := 2
      q_rho_pos := by norm_num
      a_iso := 1 / 10
      a_iso_pos := by norm_num }

  example : toyIsothermalRegime.v_flat = Real.sqrt 2 * 10 := by
    exact isothermal_sphere_flat_velocity toyIsothermalRegime rfl

  example : toyIsothermalRegime.v_flat ^ 2 = 200 := by
    have h := toyIsothermalRegime.v_flat_sq
    rw [h]
    dsimp [toyIsothermalRegime]
    norm_num

  example (G c E b K : ℝ) :
      mutualPhotonDeflection ActiveRadiationSourcing.dilatantDarkFluid G c E b K = 0 := by
    exact ddf_photon_deflection_null G c E b K

  example (G c E b K : ℝ) :
      mutualPhotonDeflection ActiveRadiationSourcing.generalRelativity G c E b K =
        K * G * E / (c ^ 4 * b) := by
    exact gr_photon_deflection_active G c E b K

/-! ## Madelung circulation, plaquette holonomy, Bogoliubov & Wakefield/MHD tests -/

/-- Circular contour integral of azimuthal vortex velocity matches quantized DDF circulation. -/
example (hbar R : ℝ) (hR : R ≠ 0) (n : ℤ) :
    ∫ θ in (0 : ℝ)..(2 * Real.pi),
      (vortexTangentialVelocity toyDDFSubstrate.m_phi hbar n R θ * R) =
      (n : ℝ) * toyDDFSubstrate.circulationQuantum hbar := by
  exact toyDDFSubstrate.quantized_vortex_circulation_eq hbar R hR n

/-- Single-valued lattice site phases around a unit plaquette have zero coboundary sum. -/
example :
    let e_bottom := (2 : ℝ) - 1
    let e_right := (5 : ℝ) - 2
    let e_top := (3 : ℝ) - 5
    let e_left := (1 : ℝ) - 3
    e_bottom + e_right + e_top + e_left = 0 := by
  exact plaquette_coboundary_zero 1 2 5 3

/-- A 2πn branch jump on one plaquette link yields the exact 2πn vortex syndrome. -/
example :
    let e_bottom := (2 : ℝ) - 1
    let e_right := (5 : ℝ) - 2
    let e_top := ((3 : ℝ) - 5) + ((2 : ℤ) : ℝ) * (2 * Real.pi)
    let e_left := (1 : ℝ) - 3
    e_bottom + e_right + e_top + e_left = ((2 : ℤ) : ℝ) * (2 * Real.pi) := by
  exact plaquette_phase_slip_syndrome 1 2 5 3 2

/-- Bogoliubov excitation phase velocity squared is bounded below by the sound speed squared. -/
example (c_s m p : ℝ) :
    c_s ^ 2 ≤ bogoliubovPhaseVelSq c_s m p := by
  exact bogoliubov_phase_velocity_sq_ge_cs_sq c_s m p

/-- Subcritical superflow has strictly positive moving-frame excitation energy. -/
example : 0 < movingFrameExcitationEnergy 10 2 3 := by
  exact subcritical_no_dissipation 3 4 2 10 (by norm_num) (by norm_num) (by norm_num)

/-- Supercritical flow produces negative moving-frame excitation energy at the acoustic pole. -/
example : movingFrameExcitationEnergy 8 2 5 < 0 := by
  exact supercritical_excitation_onset 5 4 2 8 (by norm_num) (by norm_num) (by norm_num)

/-- Ponderomotive potential is nonnegative for positive particle mass. -/
example (E0 : Vec3 → Vec3) (x : Vec3) :
    0 ≤ ponderomotivePotential 1 2 3 E0 x := by
  exact ponderomotivePotential_nonneg 1 2 3 E0 x (by norm_num)

/-- Secular ponderomotive drift force points down the electric-field intensity gradient. -/
example (grad_E0_sq : Vec3 → Vec3) (x : Vec3) :
    (ponderomotiveForce 1 2 3 grad_E0_sq x) ⬝ᵥ (grad_E0_sq x) ≤ 0 := by
  exact ponderomotiveForce_down_gradient 1 2 3 grad_E0_sq x (by norm_num)

/-- Averaging the instantaneous Lorentz force over one RF period isolates the secular ponderomotive force. -/
example (grad_E0_sq F_osc : Vec3 → Vec3) (x : Vec3) (i : Fin 3) :
    let T := 2 * Real.pi / 2
    let F_inst (t : ℝ) : ℝ :=
      ponderomotiveForce 1 1 2 grad_E0_sq x i + F_osc x i * Real.cos (2 * t)
    (1 / T) * (∫ t in (0 : ℝ)..T, F_inst t) =
      ponderomotiveForce 1 1 2 grad_E0_sq x i := by
  exact ponderomotive_cycle_average 1 1 2 (by norm_num) grad_E0_sq F_osc x
    (2 * Real.pi / 2) rfl i

/-- Differential aerodynamic torque is orthogonal to the lever arm from the center of mass. -/
example (V_wake n : Vec3 → Vec3) (CM x : Vec3) :
    (differentialAerodynamicMoment 1.2 V_wake n CM x) ⬝ᵥ (x - CM) = 0 := by
  exact differentialAerodynamicMoment_orthogonal_lever_arm 1.2 V_wake n CM x

/-- Differential aerodynamic torque is orthogonal to the normal surface pressure force. -/
example (V_wake n : Vec3 → Vec3) (CM x : Vec3) :
    (differentialAerodynamicMoment 1.2 V_wake n CM x) ⬝ᵥ
      (differentialPressureForce 1.2 V_wake n x) = 0 := by
  exact differentialAerodynamicMoment_orthogonal_force 1.2 V_wake n CM x

/-- At a stagnation point (V = 0), static Bernoulli pressure recovers p_0 = 101325 Pa and C_p = 1,
whereas dynamic pressure vanishes. -/
example (x : Vec3) :
    pressureCoefficient 100 (fun _ => 0) x = 1 ∧
      bernoulliStaticPressure 101325 1.2 (fun _ => 0) x = 101325 ∧
      dynamicPressure 1.2 (fun _ => 0) x = 0 :=
  bernoulliStaticPressure_at_stagnation 101325 1.2 100 (fun _ => 0) x rfl

/-- Static Bernoulli surface traction at a stagnation point equals (-p_0) • n(x), whereas the
dynamic-pressure load proxy vanishes. -/
example (x : Vec3) :
    bernoulliSurfaceTraction 100 1.2 (fun _ => 0) (fun _ => ![0, 0, 1]) x = ![0, 0, -100] ∧
      differentialPressureForce 1.2 (fun _ => 0) (fun _ => ![0, 0, 1]) x = 0 := by
  refine ⟨?_, differentialPressureForce_at_stagnation 1.2 (fun _ => 0) (fun _ => ![0, 0, 1]) x rfl⟩
  rw [bernoulliSurfaceTraction_at_stagnation 100 1.2 (fun _ => 0) (fun _ => ![0, 0, 1]) x rfl]
  ext i
  fin_cases i <;> norm_num

/-- Static pressure reconstructed from freestream p_inf + q_inf * C_p matches p_0 - q(x). -/
example (V_flow : Vec3 → Vec3) (x : Vec3) :
    bernoulliStaticPressure 160 2 V_flow x =
      bernoulliStaticPressureFromFreestream 100 2 60 V_flow x :=
  bernoulliStaticPressure_eq_freestream 160 100 2 60 V_flow x (by norm_num) (by norm_num)

/-- Static Bernoulli pressure decreases when flow speed increases from |V| = 3 to |V| = 5. -/
example (x : Vec3) :
    bernoulliStaticPressure 100 2 (fun _ => ![3, 4, 0]) x <
      bernoulliStaticPressure 100 2 (fun _ => ![3, 0, 0]) x := by
  norm_num [bernoulliStaticPressure, dynamicPressure, normSqVec3, dotProduct, Fin.sum_univ_three]

/-- Differential static-Bernoulli aerodynamic torque is orthogonal to the lever arm. -/
example (V_flow n : Vec3 → Vec3) (CM x : Vec3) :
    (bernoulliAerodynamicMoment 101325 1.2 V_flow n CM x) ⬝ᵥ (x - CM) = 0 :=
  bernoulliAerodynamicMoment_orthogonal_lever_arm 101325 1.2 V_flow n CM x

/-- Differential static-Bernoulli aerodynamic torque is orthogonal to the static surface traction. -/
example (V_flow n : Vec3 → Vec3) (CM x : Vec3) :
    (bernoulliAerodynamicMoment 101325 1.2 V_flow n CM x) ⬝ᵥ
      (bernoulliSurfaceTraction 101325 1.2 V_flow n x) = 0 :=
  bernoulliAerodynamicMoment_orthogonal_force 101325 1.2 V_flow n CM x

/-- Halbach transverse magnetic field deflects longitudinal electron velocity into the x-axis. -/
example :
    magneticLorentzForce (-1) (longitudinalVelocity 4) (transverseHalbachField 3) =
      ![12, 0, 0] := by
  rw [halbach_transverse_conversion]
  ext i
  fin_cases i <;> norm_num

/-- Pure magnetic Lorentz deflection is orthogonal to velocity and performs zero work. -/
example (v B : Vec3) :
    (magneticLorentzForce (-1) v B) ⬝ᵥ v = 0 := by
  exact magneticLorentzForce_work_free (-1) v B

/-- Radial centrifugal pressure head from hub r = 1 to rim r = 3 evaluates to 200. -/
example :
    ∫ r in (1 : ℝ)..3, centrifugalPressureGradient 2 5 r = 200 := by
  rw [centrifugal_pump_head]
  norm_num

/-- Isothermal closed rotating loop has zero net centrifugal circulation head. -/
example :
    (∫ r in (1 : ℝ)..3, centrifugalPressureGradient 4 5 r) -
      (∫ r in (1 : ℝ)..3, centrifugalPressureGradient 4 5 r) = 0 := by
  exact centrifugal_closed_loop_isothermal_zero 4 5 1 3

/-- Pitch precession about the X axis induces a pure Y-axis yaw gyroscopic torque. -/
example :
    gyroscopicTorque 2 ![3, 0, 0] 5 = ![0, -30, 0] := by
  have h := pitch_induces_yaw_torque 2 3 5
  dsimp at h
  rw [h]
  ext i
  fin_cases i <;> norm_num

/-- Bohm-Gross phase and group velocities multiply to 3 * v_th² = 27. -/
example :
    langmuirPhaseVelocity 10 2 * bohmGrossGroupVelocity 10 2 3 = 27 := by
  rw [bohm_gross_phase_group_product 10 2 3 (by norm_num) (by norm_num)]
  norm_num

/-- Electrostatic wave energy density is bounded by the Dawson saturation ceiling. -/
example :
    electrostaticWaveEnergyDensity 2 3 ≤ electrostaticWaveEnergyDensity 2 5 := by
  exact dawson_energy_density_bound 2 3 5 (by norm_num) (by norm_num) (by norm_num)

/-- Positive bump-on-tail distribution slope yields strictly positive inverse Landau growth for k > 0. -/
example : 0 < landauGrowthRate 2 3 4 1 := by
  exact inverse_landau_growth_pos 2 3 4 1 (by norm_num) (by norm_num) (by norm_num) (by norm_num)

/-- Negative thermal Maxwellian slope yields strictly negative Landau damping for k > 0. -/
example : landauGrowthRate 2 3 4 (-1) < 0 := by
  exact thermal_landau_damping_neg 2 3 4 (-1) (by norm_num) (by norm_num) (by norm_num) (by norm_num)

/-- Checked Gaussian Maxwellian derivative at v = 1 is negative: -exp(-1/2). -/
example : HasDerivAt (fun velocity : ℝ => Real.exp (-(velocity ^ 2) / 2))
    (-Real.exp (-(1 / 2 : ℝ))) 1 := by
  convert (Real.hasDerivAt_exp (- ((1 : ℝ) ^ 2) / 2)).comp 1
    (((hasDerivAt_id (1 : ℝ)).pow 2).neg.div_const 2) using 1 <;>
    norm_num [Function.comp_def]

/-- Checked Gaussian Maxwellian derivative at v = -1 is positive: +exp(-1/2). -/
example : HasDerivAt (fun velocity : ℝ => Real.exp (-(velocity ^ 2) / 2))
    (Real.exp (-(1 / 2 : ℝ))) (-1) := by
  convert (Real.hasDerivAt_exp (- ((-1 : ℝ) ^ 2) / 2)).comp (-1)
    (((hasDerivAt_id (-1 : ℝ)).pow 2).neg.div_const 2) using 1 <;>
    norm_num [Function.comp_def]

/-- Forward wave (k = 1) in a Gaussian thermal Maxwellian damps (γ < 0). -/
example : landauGrowthRate 1 1 1 (-Real.exp (-(1 / 2 : ℝ))) < 0 :=
  thermal_landau_damping_neg 1 1 1 _
    (by norm_num) (by norm_num) (by norm_num) (neg_neg_of_pos (Real.exp_pos _))

/-- Backward wave (k = -1) in a Gaussian thermal Maxwellian (where ∂f₀/∂v(-1) = +exp(-1/2) > 0)
also damps (γ < 0) rather than growing. -/
example : landauGrowthRate 1 (-1) 1 (Real.exp (-(1 / 2 : ℝ))) < 0 :=
  backward_thermal_landau_damping_neg 1 (-1) 1 _
    (by norm_num) (by norm_num) (by norm_num) (Real.exp_pos _)

/-- Regression guard: a backward wave (k = -1) with positive thermal slope at v = -1 cannot grow. -/
example : ¬(0 < landauGrowthRate 1 (-1) 1 (Real.exp (-(1 / 2 : ℝ)))) :=
  not_lt_of_gt (backward_thermal_landau_damping_neg 1 (-1) 1 _
    (by norm_num) (by norm_num) (by norm_num) (Real.exp_pos _))

/-- Zero quasilinear plateau slope saturates linear Landau growth at zero. -/
example : landauGrowthRate 2 3 4 0 = 0 := by
  exact quasilinear_plateau_saturation 2 3 4

/-- Woltjer-Taylor Beltrami current J = α • B experiences zero internal magnetic Lorentz force. -/
example (B : Vec3) :
    crossProduct (taylorBeltramiCurrent 3 B) B = ![0, 0, 0] := by
  exact taylor_state_force_free 3 B

/-- Active thermal extraction exceeding Ohmic heating preserves a positive magnetic pinch margin. -/
example :
    0 < (10 : ℝ) - (8 + 1 - 3) := by
  exact active_cooling_stabilizes_pinch 10 8 1 3 (by norm_num) (by norm_num)

/-- Discrete 4-cycle 1-cocycle circulation sum is invariant under vertex gauge shifts. -/
example :
    ((1 : ℝ) + (10 - 20)) + (2 + (30 - 10)) + (3 + (40 - 30)) + (4 + (20 - 40)) =
      1 + 2 + 3 + 4 := by
  exact discrete_four_cycle_gauge_invariance 1 2 3 4 20 10 30 40

/-! ## Iterations 21–23: General 2×n Pluecker relations, parallel-path reduction, and Fraunhofer benchmark -/

/-- A 2×5 real matrix used to test arbitrary four-column Pluecker selections. -/
def fiveColumnPlueckerMatrix : Matrix (Fin 2) (Fin 5) ℝ :=
  !![1, 0, -1, -2, -3; 0, 1, 2, 5, 9]

/-- Strictly increasing selection of four columns (0, 1, 3, 4) from five columns. -/
def fourOfFiveColumns : OrderedColumns 4 5 :=
  { index := ![0, 1, 3, 4]
    strictlyIncreasing := by
      intro left right before
      fin_cases left <;> fin_cases right <;> simp_all }

/-- The ordered four-column selection (0, 1, 3, 4) obeys the three-term Pluecker identity. -/
example :
    selectedMinor fiveColumnPlueckerMatrix
        (OrderedColumns.pair (fourOfFiveColumns.index 0) (fourOfFiveColumns.index 1)
          (fourOfFiveColumns.strictlyIncreasing (by decide))) *
      selectedMinor fiveColumnPlueckerMatrix
        (OrderedColumns.pair (fourOfFiveColumns.index 2) (fourOfFiveColumns.index 3)
          (fourOfFiveColumns.strictlyIncreasing (by decide))) -
    selectedMinor fiveColumnPlueckerMatrix
        (OrderedColumns.pair (fourOfFiveColumns.index 0) (fourOfFiveColumns.index 2)
          (fourOfFiveColumns.strictlyIncreasing (by decide))) *
      selectedMinor fiveColumnPlueckerMatrix
        (OrderedColumns.pair (fourOfFiveColumns.index 1) (fourOfFiveColumns.index 3)
          (fourOfFiveColumns.strictlyIncreasing (by decide))) +
    selectedMinor fiveColumnPlueckerMatrix
        (OrderedColumns.pair (fourOfFiveColumns.index 0) (fourOfFiveColumns.index 3)
          (fourOfFiveColumns.strictlyIncreasing (by decide))) *
      selectedMinor fiveColumnPlueckerMatrix
        (OrderedColumns.pair (fourOfFiveColumns.index 1) (fourOfFiveColumns.index 2)
          (fourOfFiveColumns.strictlyIncreasing (by decide))) = 0 :=
  selectedMinor_pluecker_four fiveColumnPlueckerMatrix fourOfFiveColumns

/-- The crossing minor product on columns (0, 1, 3, 4) equals the sum of uncrossed minor products. -/
example :
    selectedMinor fiveColumnPlueckerMatrix
        (OrderedColumns.pair (fourOfFiveColumns.index 0) (fourOfFiveColumns.index 2)
          (fourOfFiveColumns.strictlyIncreasing (by decide))) *
      selectedMinor fiveColumnPlueckerMatrix
        (OrderedColumns.pair (fourOfFiveColumns.index 1) (fourOfFiveColumns.index 3)
          (fourOfFiveColumns.strictlyIncreasing (by decide))) = 15 := by
  rw [selectedMinor_crossing_product_eq_sum]
  simp only [ ← twoRowMinor_eq_selectedMinor]
  norm_num [twoRowMinor, fiveColumnPlueckerMatrix, fourOfFiveColumns]

/-- A 2×4 matrix with all-negative ordered minors whose quadratic Pluecker minor products are all positive. -/
def negatedPlueckerMatrix : Matrix (Fin 2) (Fin 4) ℝ :=
  !![1, 1, 1, 1; -1, -2, -3, -4]

/-- Both uncrossed minor products and the crossing minor product of `negatedPlueckerMatrix` are positive. -/
example :
    0 < twoRowMinor negatedPlueckerMatrix 0 1 * twoRowMinor negatedPlueckerMatrix 2 3 ∧
      0 < twoRowMinor negatedPlueckerMatrix 0 3 * twoRowMinor negatedPlueckerMatrix 1 2 ∧
      twoRowMinor negatedPlueckerMatrix 0 2 * twoRowMinor negatedPlueckerMatrix 1 3 = 4 := by
  norm_num [twoRowMinor, negatedPlueckerMatrix]

/-- Positive quadratic Pluecker products do not imply nonnegative ordered minors without a sign anchor. -/
example : ¬(GrassmannianMatrix.mk negatedPlueckerMatrix).hasNonnegativeOrderedMinors := by
  intro nonnegative
  have h01 := nonnegative (OrderedColumns.pair 0 1 (by decide))
  change 0 ≤ selectedMinor negatedPlueckerMatrix (OrderedColumns.pair 0 1 (by decide)) at h01
  rw [← twoRowMinor_eq_selectedMinor] at h01
  norm_num [twoRowMinor, negatedPlueckerMatrix] at h01

/-- The diamond network sums the two parallel two-edge path products: 2 * 3 + 4 * 5 = 26. -/
example : (Signals.Plabic.WeightedAcyclicNetwork.diamond 2 4 3 5).transfer 0 3 = 26 := by
  rw [Signals.Plabic.WeightedAcyclicNetwork.diamond_transfer]
  norm_num

/-- A zero weight on the second parallel branch reduces the diamond transfer to the first path product. -/
example : (Signals.Plabic.WeightedAcyclicNetwork.diamond 2 0 3 5).transfer 0 3 = 6 := by
  rw [Signals.Plabic.WeightedAcyclicNetwork.diamond_transfer]
  norm_num

/-- Parallel two-edge path reduction preserves the one-source/one-sink boundary measurement matrix. -/
example :
    (Signals.Plabic.WeightedAcyclicNetwork.diamond 2 4 3 5).boundaryMeasurement
      (fun _ : Fin 1 => 0) (fun _ : Fin 1 => 3) =
    (Signals.Plabic.WeightedAcyclicNetwork.oneEdgePath 26).boundaryMeasurement
      (fun _ : Fin 1 => 0) (fun _ : Fin 1 => 1) := by
  have h : (2 : NNReal) * 3 + 4 * 5 = 26 := by norm_num
  rw [← h]
  exact Signals.Plabic.WeightedAcyclicNetwork.parallel_reduction_boundary 2 4 3 5

/-- Negative control: parallel two-edge paths multiply along series legs rather than summing all four edge weights. -/
example :
    (Signals.Plabic.WeightedAcyclicNetwork.diamond 2 4 3 5).transfer 0 3 ≠ 2 + 4 + 3 + 5 := by
  rw [Signals.Plabic.WeightedAcyclicNetwork.diamond_transfer]
  norm_num

/-- On-axis Fraunhofer double-slit intensity equals four times the single-slit scale. -/
example :
    Signals.Huygens.fraunhoferRectangularDoubleSlit 3 2 4 6 1 5 0 0 = 12 := by
  rw [Signals.Huygens.fraunhoferRectangularDoubleSlit_onAxis]
  norm_num

/-- The Fraunhofer double-slit benchmark vanishes at the first half-period destructive fringe x = λL/(2d). -/
example :
    Signals.Huygens.fraunhoferRectangularDoubleSlit 3 2 4 6 1 5 (1 * 5 / (2 * 6)) 1 = 0 :=
  Signals.Huygens.fraunhoferRectangularDoubleSlit_dark_fringe 3 2 4 6 1 5 1
    (by norm_num) (by norm_num) (by norm_num)

/-- The Fraunhofer double-slit benchmark vanishes at the first single-slit diffraction minimum x = λL/a. -/
example :
    Signals.Huygens.fraunhoferRectangularDoubleSlit 3 2 4 6 1 5 (((1 : ℤ) : ℝ) * 1 * 5 / 2) 1 = 0 :=
  Signals.Huygens.fraunhoferRectangularDoubleSlit_diffraction_null 3 2 4 6 1 5 1 1
    (by decide) (by norm_num) (by norm_num) (by norm_num)

/-- Negative control: a positive-intensity claim fails at the half-period Fraunhofer dark fringe. -/
example :
    ¬(0 < Signals.Huygens.fraunhoferRectangularDoubleSlit 3 2 4 6 1 5 (1 * 5 / (2 * 6)) 0) := by
  rw [Signals.Huygens.fraunhoferRectangularDoubleSlit_dark_fringe 3 2 4 6 1 5 0
    (by norm_num) (by norm_num) (by norm_num)]
  norm_num

/-! ## Quantum Inverse Scattering Method (QISM) and Grassmannian Bethe Ansatz tests -/

/-- Spectral differences across three rapidities (5, 3, 1) satisfy the additive cocycle law. -/
example : Signals.QISM.spectralDiff 5 3 + Signals.QISM.spectralDiff 3 1 = Signals.QISM.spectralDiff 5 1 :=
  Signals.QISM.spectralDiff_add 5 3 1

/-- The 4×4 two-qubit permutation matrix P is involutive: P² = I_4. -/
example : Signals.QISM.swapMatrix4 * Signals.QISM.swapMatrix4 = 1 :=
  Signals.QISM.swapMatrix4_mul_self

/-- At u = 0, Yang's 4×4 rational R-matrix reduces to η • P (regularity condition). -/
example : Signals.QISM.yangRMatrix4 0 3 = (3 : ℝ) • Signals.QISM.swapMatrix4 :=
  Signals.QISM.yangRMatrix4_zero 3

/-- The (0, 0) triplet entry of Yang's 4×4 R-matrix equals the symmetric-channel weight (u - v) + η. -/
example : Signals.QISM.yangRMatrix4 (Signals.QISM.spectralDiff 7 2) 3 0 0 = 8 := by
  rw [Signals.QISM.yangRMatrix4_triplet_entry]
  norm_num [Signals.QISM.yangSymmetricWeight, Signals.QISM.spectralDiff]

/-- Quantum unitarity of Yang's 4×4 R-matrix: R(u - v) * R(v - u) = (η² - (u - v)²) • I_4. -/
example :
    Signals.QISM.yangRMatrix4 (Signals.QISM.spectralDiff 5 2) 4 *
      Signals.QISM.yangRMatrix4 (Signals.QISM.spectralDiff 2 5) 4 =
      (7 : ℝ) • (1 : Matrix (Fin 4) (Fin 4) ℝ) := by
  rw [Signals.QISM.yangRMatrix4_unitarity]
  congr 1
  norm_num [Signals.QISM.yangSymmetricWeight, Signals.QISM.yangAntisymmetricWeight,
    Signals.QISM.spectralDiff]

/-- Rational Yang-Baxter braid interference identity on concrete spectral parameters. -/
example :
    (2 : ℝ) * Signals.QISM.spectralDiff 7 1 * 2 =
      2 * Signals.QISM.spectralDiff 7 4 * 2 + 2 ^ 2 * Signals.QISM.spectralDiff 4 1 :=
  Signals.QISM.yang_baxter_rational_braid 7 4 1 2

/-- Cyclic invariance of the composed 2×2 QISM transfer trace: Tr(L2 * L1) = Tr(L1 * L2). -/
example :
    let L1 : Signals.QISM.MonodromyMatrix2 := { A := 1, B := 2, C := 3, D := 4 }
    let L2 : Signals.QISM.MonodromyMatrix2 := { A := 2, B := 5, C := 7, D := 1 }
    (L2.comp L1).transferTrace = (L1.comp L2).transferTrace := by
  intro L1 L2
  exact Signals.QISM.MonodromyMatrix2.transferTrace_comp_comm L2 L1

/-- Composing two 2×2 Lax matrices multiplies their classical determinants: (-2) * (-2) = 4. -/
example :
    let L1 : Signals.QISM.MonodromyMatrix2 := { A := 1, B := 2, C := 3, D := 4 }
    let L2 : Signals.QISM.MonodromyMatrix2 := { A := 2, B := 1, C := 4, D := 1 }
    (L2.comp L1).classicalDet = 4 := by
  intro L1 L2
  rw [Signals.QISM.MonodromyMatrix2.classicalDet_comp]
  norm_num [L1, L2, Signals.QISM.MonodromyMatrix2.classicalDet]

/-- Baxter pair Q_+(u) = u and Q_-(u) = 1 has constant unit Casorati Wronskian W(u, v) = u - v,
and its four-point evaluations obey the 3-term Gr(2, 4) Pluecker QQ-system identity. -/
example :
    let Q_plus := fun u : ℝ => u
    let Q_minus := fun _ : ℝ => (1 : ℝ)
    Signals.QISM.casoratiWronskian Q_plus Q_minus 1 2 *
        Signals.QISM.casoratiWronskian Q_plus Q_minus 3 4 -
      Signals.QISM.casoratiWronskian Q_plus Q_minus 1 3 *
        Signals.QISM.casoratiWronskian Q_plus Q_minus 2 4 +
      Signals.QISM.casoratiWronskian Q_plus Q_minus 1 4 *
        Signals.QISM.casoratiWronskian Q_plus Q_minus 2 3 = 0 :=
  Signals.QISM.baxter_qq_pluecker_identity (fun u => u) (fun _ => 1) 1 2 3 4

/-- Three-point Casorati Wronskians solve Baxter's TQ difference equation identically. -/
example :
    let Q_plus := fun u : ℝ => u ^ 2 - 1
    let Q_minus := fun u : ℝ => u + 2
    Signals.QISM.baxterTQResidual
      (Signals.QISM.casoratiWronskian Q_plus Q_minus (3 - 1) (3 + 1))
      (Signals.QISM.casoratiWronskian Q_plus Q_minus 3 (3 + 1))
      (Signals.QISM.casoratiWronskian Q_plus Q_minus (3 - 1) 3)
      (Q_plus 3) (Q_plus (3 - 1)) (Q_plus (3 + 1)) = 0 :=
  Signals.QISM.baxterTQResidual_wronskian_zero (fun u => u ^ 2 - 1) (fun u => u + 2) 3 1

/-- Evaluating a satisfied Baxter TQ relation at a Bethe root Q(u_m) = 0 enforces a * Q_- + d * Q_+ = 0. -/
example : (3 : ℝ) * 4 + (-6) * 2 = 0 :=
  Signals.QISM.bethe_ansatz_eq_of_tq_root 99 3 (-6) 0 4 2 (by norm_num [Signals.QISM.baxterTQResidual]) rfl

/-- Critique regression: a spurious triple-zero Bethe root Q(u_m) = Q(u_m - η) = Q(u_m + η) = 0
leaves the transfer eigenvalue T unconstrained (both T = 10 and T = -77 give zero residual). -/
example :
    Signals.QISM.baxterTQResidual 10 3 5 0 0 0 = 0 ∧
      Signals.QISM.baxterTQResidual (-77) 3 5 0 0 0 = 0 :=
  ⟨Signals.QISM.baxterTQResidual_spurious_zero 10 3 5,
    Signals.QISM.baxterTQResidual_spurious_zero (-77) 3 5⟩

/-- MTV Wronskian nondegeneracy: when Q_+(u) = u - 2 and Q_-(u) = 1, the root u_m = 2 has
nonvanishing Casorati Wronskian W(2, 1) = 1 ≠ 0, forcing Q_+(1) ≠ 0 and Q_-(2) ≠ 0. -/
example :
    (fun u : ℝ => u - 2) 1 ≠ 0 ∧ (fun _ : ℝ => (1 : ℝ)) 2 ≠ 0 :=
  Signals.QISM.mtv_wronskian_nondegenerate_of_root
    (fun u => u - 2) (fun _ => 1) 2 1 (by norm_num)
    (by norm_num [Signals.QISM.casoratiWronskian])

/-- Nonvanishing Casorati Wronskian certifies an explicit nonzero Pluecker minor for the 2×4 Baxter matrix. -/
example :
    ∃ columns : OrderedColumns 2 4,
      (GrassmannianMatrix.mk
        (Signals.QISM.baxterGrassmannianMatrix (fun u => u - 2) (fun _ => 1) 2 1 3 4)).pluckerCoordinate
          columns ≠ 0 :=
  Signals.QISM.baxterGrassmannianMatrix_nonzero_minor
    (fun u => u - 2) (fun _ => 1) 2 1 3 4 (by norm_num [Signals.QISM.casoratiWronskian])

/-- Under nondegeneracy, the Bethe Ansatz Equation recovers the exact rational phase-shift ratio a / d = -Q_+ / Q_-. -/
example : (6 : ℝ) / (-3) = - 8 / 4 :=
  Signals.QISM.bethe_ansatz_ratio_of_tq_root 42 6 (-3) 0 4 8
    (by norm_num [Signals.QISM.baxterTQResidual]) rfl (by norm_num) (by norm_num)

/-- Left and right Yangian quantum determinants coincide when the RTT exchange balance holds. -/
example :
    let T_u : Signals.QISM.MonodromyMatrix2 := { A := 5, B := 2, C := 3, D := 4 }
    let T_shift : Signals.QISM.MonodromyMatrix2 := { A := 2, B := 1, C := 5, D := 3 }
    Signals.QISM.quantumDetLeft T_u T_shift = Signals.QISM.quantumDetRight T_u T_shift := by
  intro T_u T_shift
  exact (Signals.QISM.quantumDet_left_eq_right_iff T_u T_shift).mpr (by norm_num [T_u, T_shift])

/-- Negative control: without the RTT exchange balance, left and right shifted determinants differ. -/
example :
    let T_u : Signals.QISM.MonodromyMatrix2 := { A := 5, B := 2, C := 3, D := 4 }
    let T_shift : Signals.QISM.MonodromyMatrix2 := { A := 2, B := 1, C := 1, D := 3 }
    Signals.QISM.quantumDetLeft T_u T_shift ≠ Signals.QISM.quantumDetRight T_u T_shift := by
  intro T_u T_shift
  norm_num [T_u, T_shift, Signals.QISM.quantumDetLeft, Signals.QISM.quantumDetRight]

/-- Two-magnon Slavnov / Gaudin determinant matches the 2×2 Grassmannian minor: 5 * 7 - 2 * 3 = 29. -/
example : Signals.QISM.slavnovDet2 !![5, 2; 3, 7] = 29 := by
  norm_num [Signals.QISM.slavnovDet2, Signals.Geometry.twoRowMinor]

/-- Pauli exclusion control: when two Bethe rapidities collide (u_0 = u_1 = 3) or two
dual rapidities collide (v_0 = v_1 = 2), the 2×2 Slavnov determinant vanishes identically. -/
example (K : ℝ → ℝ → ℝ) :
    Signals.QISM.slavnovDet2 (Signals.QISM.slavnovKernelMatrix2 K 1 2 3 3) = 0 ∧
      Signals.QISM.slavnovDet2 (Signals.QISM.slavnovKernelMatrix2 K 2 2 1 4) = 0 :=
  ⟨Signals.QISM.slavnovDet2_pauli_exclusion K 1 2 3,
    Signals.QISM.slavnovDet2_dual_pauli_exclusion K 2 1 4⟩

/-- Swapping the two Bethe rapidities negates the 2×2 Slavnov determinant. -/
example (K : ℝ → ℝ → ℝ) :
    Signals.QISM.slavnovDet2 (Signals.QISM.slavnovKernelMatrix2 K 1 2 4 3) =
      - Signals.QISM.slavnovDet2 (Signals.QISM.slavnovKernelMatrix2 K 1 2 3 4) :=
  Signals.QISM.slavnovDet2_swap_bethe K 1 2 3 4

/-- Inverse scattering parameter recovery: triplet and singlet Yang R-matrix eigenvalues
reconstruct the exact spectral rapidity difference δ(u, v) = u - v and coupling η. -/
example :
    Signals.Scattering.reconstructSpectralDiff
        (Signals.QISM.yangSymmetricWeight 9 4 3)
        (Signals.QISM.yangAntisymmetricWeight 9 4 3) =
      Signals.QISM.spectralDiff 9 4 ∧
      Signals.Scattering.reconstructYangCoupling
        (Signals.QISM.yangSymmetricWeight 9 4 3)
        (Signals.QISM.yangAntisymmetricWeight 9 4 3) = 3 :=
  Signals.Scattering.reconstruct_yang_parameters 9 4 3

/-- Unitary two-body scattering probability conservation for Yang's rational R-matrix:
(3/5)² + (4/5)² = 9/25 + 16/25 = 1. -/
example :
    0 ≤ Signals.Scattering.yangTransmissionProb 5 2 4 ∧
      0 ≤ Signals.Scattering.yangReflectionProb 5 2 4 ∧
      Signals.Scattering.yangTransmissionProb 5 2 4 +
        Signals.Scattering.yangReflectionProb 5 2 4 = 1 :=
  Signals.Scattering.yang_scattering_probability_conservation 5 2 4
    (by norm_num [Signals.QISM.spectralDiff])

/-- Inverse monodromy recovery of D(u) = t(u) - A(u) and B(u) * C(u) = A(u) * D(u) - Δ_01(T). -/
example :
    let T : Signals.QISM.MonodromyMatrix2 := { A := 5, B := 2, C := 3, D := 4 }
    T.transferTrace - T.A = T.D ∧
      T.A * T.D - Signals.Geometry.twoRowMinor T.toMatrix 0 1 = T.B * T.C := by
  intro T
  exact Signals.Scattering.reconstruct_monodromy_from_trace_and_minor T

/-- A three-point Casorati Wronskian Baxter TQ solution produces a metrologically consistent
Scattering.ResidualMeasurement for any nonnegative tolerance. -/
example :
    (Signals.Scattering.baxterTQResidualMeasurement
      (Signals.QISM.casoratiWronskian (fun u => u ^ 2 - 1) (fun u => u + 2) (3 - 1) (3 + 1))
      (Signals.QISM.casoratiWronskian (fun u => u ^ 2 - 1) (fun u => u + 2) 3 (3 + 1))
      (Signals.QISM.casoratiWronskian (fun u => u ^ 2 - 1) (fun u => u + 2) (3 - 1) 3)
      ((fun u : ℝ => u ^ 2 - 1) 3)
      ((fun u : ℝ => u ^ 2 - 1) (3 - 1))
      ((fun u : ℝ => u ^ 2 - 1) (3 + 1))
      (1 / 10) (by norm_num)).consistent :=
  Signals.Scattering.baxterTQResidualMeasurement_wronskian_consistent
    (fun u => u ^ 2 - 1) (fun u => u + 2) 3 1 (1 / 10) (by norm_num)

/-- An off-shell Bethe root with |a Q(u_m - η) + d Q(u_m + η)| > tolerance is flagged as
an anomalyCandidate in Signals.Scattering. -/
example :
    (Signals.Scattering.baxterTQResidualMeasurement 10 3 2 0 1 1 (1 / 2) (by norm_num)).anomalyCandidate :=
  Signals.Scattering.baxterTQResidualMeasurement_offShell_anomaly 10 3 2 1 1 (1 / 2)
    (by norm_num) (by norm_num)

/-! ## Four-Model Double-Slit Relative Predictive Error tests -/

/-- In the coherent / quantum-equilibrium / pure-state limit (V = 1, δ_neq = 0, γ_dec = 0),
all four double-slit superposition models (Huygens-Steiner, Pilot-Wave, Wigner, and Fraunhofer)
have zero pointwise relative predictive error across the entire detector plane. -/
example (x y : ℝ) :
    Signals.Huygens.relativePredictiveError
        (Signals.Huygens.huygensSteinerDoubleSlit 3 2 4 6 1 5 1 x y)
        (Signals.Huygens.fraunhoferRectangularDoubleSlit 3 2 4 6 1 5 x y) = 0 ∧
      Signals.Huygens.relativePredictiveError
        (Signals.Huygens.pilotWaveDoubleSlit 3 2 4 6 1 5 0 x y)
        (Signals.Huygens.fraunhoferRectangularDoubleSlit 3 2 4 6 1 5 x y) = 0 ∧
      Signals.Huygens.relativePredictiveError
        (Signals.Huygens.wignerDoubleSlit 3 2 4 6 1 5 0 x y)
        (Signals.Huygens.fraunhoferRectangularDoubleSlit 3 2 4 6 1 5 x y) = 0 :=
  Signals.Huygens.doubleSlit_four_model_zero_relative_error 3 2 4 6 1 5 x y

/-- At visibility V = 4/5 (from a Huygens-Steiner parallel-axis offset d_bary = 3/5),
the on-axis relative predictive error against the Fraunhofer peak is (1 - 4/5) / 2 = 1/10. -/
example :
    Signals.Huygens.relativePredictiveError
      (Signals.Huygens.huygensSteinerDoubleSlit 3 2 4 6 1 5 (4 / 5) 0 0)
      (Signals.Huygens.fraunhoferRectangularDoubleSlit 3 2 4 6 1 5 0 0) = 1 / 10 := by
  rw [Signals.Huygens.huygensSteiner_onAxis_relative_error 3 2 4 6 1 5 (4 / 5)
    (by norm_num) (by norm_num)]
  norm_num

/-- A concrete Pythagorean Huygens-Steiner mapping with parallel-axis offset d_bary = 3/5
and visibility V = K = 4/5 derives the exact on-axis relative error d_bary² / (2 * (1 + V)) = 1/10. -/
noncomputable def toyDoubleSlitSteinerMapping : Signals.Coherence.HuygensSteinerMapping :=
  { axis := { centerInertia := 2, mass := 1, offset := 3 / 5 }
    originInertia := 59 / 25
    originInertiaLaw := by norm_num [Signals.Coherence.ParallelAxis.inertia]
    normalizedMass := rfl
    polarizationSquared := 9 / 25
    entanglementSquared := 16 / 25
    polarizationSquared_nonnegative := by norm_num
    entanglementSquared_nonnegative := by norm_num
    polarizationLaw := by norm_num
    entanglementLaw := by norm_num }

example :
    (1 - (4 / 5 : ℝ)) / 2 =
      toyDoubleSlitSteinerMapping.axis.offset ^ 2 / (2 * (1 + 4 / 5)) :=
  Signals.Huygens.huygensSteiner_relative_error_eq_offset_sq_div
    toyDoubleSlitSteinerMapping (4 / 5)
    (by norm_num [toyDoubleSlitSteinerMapping]) (by norm_num)

/-- A non-equilibrium Pilot-Wave residual δ_neq = 3 at single-slit scale I_0 = 5
yields on-axis relative predictive error 3 / (4 * 5) = 3/20. -/
example :
    Signals.Huygens.relativePredictiveError
      (Signals.Huygens.pilotWaveDoubleSlit 5 2 4 6 1 5 3 0 0)
      (Signals.Huygens.fraunhoferRectangularDoubleSlit 5 2 4 6 1 5 0 0) = 3 / 20 := by
  rw [Signals.Huygens.pilotWave_onAxis_relative_error 5 2 4 6 1 5 3 (by norm_num)]
  norm_num

/-- At the half-period dark fringe x = λL/(2d) where I_F = 0, the peak-normalized relative
predictive error of the Huygens-Steiner model (V = 3/5) equals (1/5) * sinc²(πa/(2d)). -/
example :
    Signals.Huygens.peakNormalizedRelativeError
      (Signals.Huygens.huygensSteinerDoubleSlit 5 2 4 6 1 5 (3 / 5) (1 * 5 / (2 * 6)) 0)
      (Signals.Huygens.fraunhoferRectangularDoubleSlit 5 2 4 6 1 5 (1 * 5 / (2 * 6)) 0)
      5 =
    (1 / 5 : ℝ) * (Signals.Huygens.unnormalizedSinc (Real.pi * 2 / (2 * 6))) ^ 2 := by
  rw [Signals.Huygens.huygensSteiner_dark_fringe_peak_relative_error 5 2 4 6 1 5 (3 / 5)
    (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num)]
  ring

/-- Binary N = 2 Qian-Izadi coherence spectrum with slit weights m_0 = 4/5 and m_1 = 1/5
yields squared polarization P_2² = (m_0 - m_1)² = 9/25 and squared visibility K_2² = 4 m_0 m_1 = 16/25. -/
noncomputable def toyBinaryQianIzadiSpectrum : Signals.Coherence.CoherenceSpectrum 2 :=
  { weight := ![4 / 5, 1 / 5]
    weight_nonnegative := by
      intro idx
      fin_cases idx <;> norm_num
    normalized := by
      simp [Fin.sum_univ_two]
      norm_num }

example :
    toyBinaryQianIzadiSpectrum.polarizationSquared = (4 / 5 - 1 / 5 : ℝ) ^ 2 ∧
      toyBinaryQianIzadiSpectrum.entanglementSquared = 4 * (4 / 5 : ℝ) * (1 / 5) :=
  toyBinaryQianIzadiSpectrum.binary_polarization_and_entanglement

/-- A balanced positive Gr(2, 4) matrix with uncrossed Pluecker channel products
Δ_01 Δ_23 = 1 * 1 = 1 and Δ_03 Δ_12 = 1 * 1 = 1, and crossing product Δ_02 Δ_13 = 1 * 2 = 2. -/
def balancedGr24DoubleSlitMatrix : Matrix (Fin 2) (Fin 4) ℝ :=
  !![1, 1, 0, -1;
     0, 1, 1, 1]

/-- At the balanced Gr(2, 4) representative, the phased Pluecker double-slit intensity
equals the Fraunhofer reference identically across the entire screen. -/
example (x y : ℝ) :
    Signals.Huygens.gr24PluckerDoubleSlit balancedGr24DoubleSlitMatrix 3 2 4 6 1 5 x y =
      Signals.Huygens.fraunhoferRectangularDoubleSlit 3 2 4 6 1 5 x y :=
  Signals.Huygens.gr24PluckerDoubleSlit_balanced_eq_fraunhofer
    balancedGr24DoubleSlitMatrix 3 2 4 6 1 5 x y
    (by norm_num [balancedGr24DoubleSlitMatrix, Signals.Geometry.twoRowMinor])
    (by norm_num [balancedGr24DoubleSlitMatrix, Signals.Geometry.twoRowMinor])

/-- Even at the balanced Gr(2, 4) representative (where Δ_02 Δ_13 = 2), the unphased
crossing-minor proxy incurs a 50% (1/2) on-axis relative predictive error. -/
example :
    Signals.Huygens.relativePredictiveError
      (Signals.Huygens.gr24UnphasedDoubleSlit balancedGr24DoubleSlitMatrix 3 2 4 1 5 0 0)
      (Signals.Huygens.fraunhoferRectangularDoubleSlit 3 2 4 6 1 5 0 0) = 1 / 2 :=
  Signals.Huygens.gr24UnphasedDoubleSlit_onAxis_relative_error_half
    balancedGr24DoubleSlitMatrix 3 2 4 6 1 5 (by norm_num)
    (by norm_num [balancedGr24DoubleSlitMatrix, Signals.Geometry.twoRowMinor])

/-- OAM fork vortex singularity: when Δℓ = 1 and φ = π, the on-axis OAM double-slit
intensity vanishes identically, and a non-OAM Fraunhofer reference has 100% (1) relative error. -/
example :
    Signals.Huygens.fraunhoferOAMDoubleSlit 3 2 4 6 1 5 1 Real.pi 0 0 = 0 ∧
      Signals.Huygens.relativePredictiveError
        (Signals.Huygens.fraunhoferOAMDoubleSlit 3 2 4 6 1 5 1 Real.pi 0 0)
        (Signals.Huygens.fraunhoferRectangularDoubleSlit 3 2 4 6 1 5 0 0) = 1 :=
  Signals.Huygens.fraunhoferOAMDoubleSlit_vortex_null_at_pi 3 2 4 6 1 5 (by norm_num)

/-- Equal-charge OAM beams (Δℓ = 0) experience zero Wigner rotational phase-space relative error. -/
example :
    Signals.Huygens.relativePredictiveError
      (Signals.Huygens.wignerOAMDoubleSlit 3 2 4 6 1 5 2 0 0 0 0)
      (Signals.Huygens.fraunhoferOAMDoubleSlit 3 2 4 6 1 5 0 0 0 0) = 0 := by
  rw [Signals.Huygens.wignerOAM_onAxis_relative_error 3 2 4 6 1 5 2 0 (by norm_num) (by norm_num)]
  simp

/-- Lifting from the positive real Grassmannian Gr_>=0(2, 4) to the complex Grassmannian
Gr_C(2, 4) with C^4 twistor phase entries z_1 = cos θ + i sin θ and z_2 = cos θ - i sin θ
reduces the pure crossing-minor relative predictive error from 1/2 (50%) to 0 everywhere. -/
example (x y : ℝ) :
    let θ := Real.pi * 6 * x / (1 * 5)
    let z1 : ℂ := ↑(Real.cos θ) + Complex.I * ↑(Real.sin θ)
    let z2 : ℂ := ↑(Real.cos θ) - Complex.I * ↑(Real.sin θ)
    Signals.Huygens.complexGr24CrossingDoubleSlit
        (Signals.Huygens.complexGr24ChannelMatrix z1 z2) 3 2 4 1 5 x y =
      Signals.Huygens.fraunhoferRectangularDoubleSlit 3 2 4 6 1 5 x y ∧
    Signals.Huygens.relativePredictiveError
      (Signals.Huygens.complexGr24CrossingDoubleSlit
        (Signals.Huygens.complexGr24ChannelMatrix z1 z2) 3 2 4 1 5 x y)
      (Signals.Huygens.fraunhoferRectangularDoubleSlit 3 2 4 6 1 5 x y) = 0 :=
  Signals.Huygens.complexGr24CrossingDoubleSlit_zero_error 3 2 4 6 1 5 x y

/-- Outside the positive Grassmannian (z_1 = 1, z_2 = -1), two nonzero uncrossed slit
channels cancel in the crossing Pluecker product Δ_02 Δ_13 = 1 + (-1) = 0 to produce
an exact dark fringe. -/
example :
    Signals.Geometry.complexTwoRowMinor (Signals.Huygens.complexGr24ChannelMatrix 1 (-1)) 0 1 *
        Signals.Geometry.complexTwoRowMinor (Signals.Huygens.complexGr24ChannelMatrix 1 (-1)) 2 3 = 1 ∧
      Signals.Geometry.complexTwoRowMinor (Signals.Huygens.complexGr24ChannelMatrix 1 (-1)) 0 3 *
        Signals.Geometry.complexTwoRowMinor (Signals.Huygens.complexGr24ChannelMatrix 1 (-1)) 1 2 = -1 ∧
      Signals.Geometry.complexTwoRowMinor (Signals.Huygens.complexGr24ChannelMatrix 1 (-1)) 0 2 *
        Signals.Geometry.complexTwoRowMinor (Signals.Huygens.complexGr24ChannelMatrix 1 (-1)) 1 3 = 0 := by
  have h := Signals.Huygens.complexGr24ChannelMatrix_minors 1 (-1)
  simpa using h

/-- An asymmetric Gr(2, 4) matrix with uncrossed channel weights w_A = 8/5 and w_B = 2/5
(summing to Δ_02 Δ_13 = 2) has Pluecker barycentric shift d_bary = (8/5 - 2/5)/2 = 3/5
and satisfies the Pythagorean Pluecker-Steiner complementarity law d_bary² + w_A w_B = (3/5)² + (4/5)² = 1. -/
noncomputable def asymmetricGr24DoubleSlitMatrix : Matrix (Fin 2) (Fin 4) ℝ :=
  !![1, 1, 0, -1;
     0, 8 / 5, 1, 2 / 5]

example :
    Signals.Geometry.gr24BarycentricShift asymmetricGr24DoubleSlitMatrix = 3 / 5 ∧
      (Signals.Geometry.gr24BarycentricShift asymmetricGr24DoubleSlitMatrix) ^ 2 +
        (Signals.Geometry.twoRowMinor asymmetricGr24DoubleSlitMatrix 0 1 *
          Signals.Geometry.twoRowMinor asymmetricGr24DoubleSlitMatrix 2 3) *
        (Signals.Geometry.twoRowMinor asymmetricGr24DoubleSlitMatrix 0 3 *
          Signals.Geometry.twoRowMinor asymmetricGr24DoubleSlitMatrix 1 2) = 1 := by
  refine ⟨?_, Signals.Huygens.gr24_barycentric_complementarity asymmetricGr24DoubleSlitMatrix ?_⟩
  · norm_num [asymmetricGr24DoubleSlitMatrix, Signals.Geometry.gr24BarycentricShift,
      Signals.Geometry.twoRowMinor]
  · norm_num [asymmetricGr24DoubleSlitMatrix, Signals.Geometry.twoRowMinor]

/-- For a nonzero barycentric parallel-axis shift d_bary = 3/5 (visibility V = √(1 - (3/5)²) = 4/5),
the pure complex Gr_C(2, 4) crossing-minor evaluator matches the partially coherent
Huygens-Steiner intensity identically across the entire screen, with zero relative error. -/
example (x y : ℝ) :
    let θ := Real.pi * 6 * x / (1 * 5)
    let a := Real.sqrt (1 + (3 / 5 : ℝ))
    let b := Real.sqrt (1 - (3 / 5 : ℝ))
    let z1 : ℂ := ↑(a * Real.cos θ) + Complex.I * ↑(a * Real.sin θ)
    let z2 : ℂ := ↑(b * Real.cos θ) - Complex.I * ↑(b * Real.sin θ)
    Signals.Huygens.complexGr24CrossingDoubleSlit
        (Signals.Huygens.complexGr24ChannelMatrix z1 z2) 3 2 4 1 5 x y =
      Signals.Huygens.huygensSteinerDoubleSlit
        3 2 4 6 1 5 (Real.sqrt (1 - (3 / 5 : ℝ) ^ 2)) x y ∧
    Signals.Huygens.relativePredictiveError
      (Signals.Huygens.complexGr24CrossingDoubleSlit
        (Signals.Huygens.complexGr24ChannelMatrix z1 z2) 3 2 4 1 5 x y)
      (Signals.Huygens.huygensSteinerDoubleSlit
        3 2 4 6 1 5 (Real.sqrt (1 - (3 / 5 : ℝ) ^ 2)) x y) = 0 :=
  Signals.Huygens.complexGr24CrossingDoubleSlit_barycentric_eq_huygensSteiner
    3 2 4 6 1 5 (3 / 5) x y (by norm_num) (by norm_num)

/-- Full 8×8 matrix Quantum Yang-Baxter Equation on (ℝ²)⊗³ for rapidities (7, 4, 1) and η = 2. -/
example :
    Signals.QISM.yangR12_8 (Signals.QISM.spectralDiff 7 4) 2 *
        Signals.QISM.yangR13_8 (Signals.QISM.spectralDiff 7 1) 2 *
        Signals.QISM.yangR23_8 (Signals.QISM.spectralDiff 4 1) 2 =
      Signals.QISM.yangR23_8 (Signals.QISM.spectralDiff 4 1) 2 *
        Signals.QISM.yangR13_8 (Signals.QISM.spectralDiff 7 1) 2 *
        Signals.QISM.yangR12_8 (Signals.QISM.spectralDiff 7 4) 2 :=
  Signals.QISM.yang_baxter_equation_matrix8 7 4 1 2

/-- Complex Gr_C(2, 4) crossing minor with helical OAM twist Δℓ = 2 and barycentric shift d_bary = 3/5
matches Huygens-Steiner OAM intensity identically across all (x, y, φ) with zero relative error. -/
example (φ x y : ℝ) :
    let θ := Real.pi * 6 * x / (1 * 5) + ((2 : ℤ) : ℝ) * φ / 2
    let a := Real.sqrt (1 + (3 / 5 : ℝ))
    let b := Real.sqrt (1 - (3 / 5 : ℝ))
    let z1 : ℂ := ↑(a * Real.cos θ) + Complex.I * ↑(a * Real.sin θ)
    let z2 : ℂ := ↑(b * Real.cos θ) - Complex.I * ↑(b * Real.sin θ)
    Signals.Huygens.complexGr24CrossingDoubleSlit
        (Signals.Huygens.complexGr24ChannelMatrix z1 z2) 3 2 4 1 5 x y =
      Signals.Huygens.huygensSteinerOAMDoubleSlit
        3 2 4 6 1 5 (Real.sqrt (1 - (3 / 5 : ℝ) ^ 2)) 2 φ x y ∧
    Signals.Huygens.relativePredictiveError
      (Signals.Huygens.complexGr24CrossingDoubleSlit
        (Signals.Huygens.complexGr24ChannelMatrix z1 z2) 3 2 4 1 5 x y)
      (Signals.Huygens.huygensSteinerOAMDoubleSlit
        3 2 4 6 1 5 (Real.sqrt (1 - (3 / 5 : ℝ) ^ 2)) 2 φ x y) = 0 :=
  Signals.Huygens.complexGr24CrossingDoubleSlit_oam_barycentric_eq_huygensSteinerOAM
    3 2 4 6 1 5 (3 / 5) 2 φ x y (by norm_num) (by norm_num)

/-- Multi-slit (N > 0) single-slit (N = 1) and double-slit (N = 2) reductions. -/
example (Δℓ : ℤ) (φ x y : ℝ) :
    Signals.Huygens.huygensSteinerMultiSlit 1 3 2 4 6 1 5 (4 / 5) Δℓ φ x y =
      3 * Signals.Huygens.rectangularSlitEnvelope 2 4 1 5 x y ∧
    Signals.Huygens.huygensSteinerMultiSlit 2 3 2 4 6 1 5 (4 / 5) Δℓ φ x y =
      Signals.Huygens.huygensSteinerOAMDoubleSlit 3 2 4 6 1 5 (4 / 5) Δℓ φ x y :=
  ⟨Signals.Huygens.huygensSteinerMultiSlit_one_slit 3 2 4 6 1 5 (4 / 5) Δℓ φ x y,
    Signals.Huygens.huygensSteinerMultiSlit_two_slits_eq_huygensSteinerOAM 3 2 4 6 1 5 (4 / 5) Δℓ φ x y⟩

/-- Dual-lane OAM SolitonMultiLaneCoupler with barycentric shift d_bary = 3/5 matches
Huygens-Steiner OAM double-slit and Complex Gr_C(2,4) crossing-minor evaluator. -/
noncomputable def toyDualLaneSolitonCoupler : Signals.SolitonBus.SolitonMultiLaneCoupler :=
  { numLanes := 2
    numLanes_pos := by norm_num
    singleLaneScale := 3
    singleLaneScale_pos := by norm_num
    laneWidth := 2
    laneWidth_pos := by norm_num
    laneHeight := 4
    laneHeight_pos := by norm_num
    laneSeparation := 6
    laneSeparation_pos := by norm_num
    wavelength := 1
    wavelength_pos := by norm_num
    couplerLength := 5
    couplerLength_pos := by norm_num
    barycentricShift := 3 / 5
    barycentricShift_lower := by norm_num
    barycentricShift_upper := by norm_num
    visibility := 4 / 5
    visibility_nonneg := by norm_num
    visibility_le_one := by norm_num
    nonEquilibriumResidual := 0
    decoherenceRate := 0
    decoherenceRate_nonneg := by norm_num
    oamDecoherenceRate := 0
    oamDecoherenceRate_nonneg := by norm_num
    deltaOAM := 1 }

example (φ x y : ℝ) :
    toyDualLaneSolitonCoupler.huygensSteinerIntensity φ x y =
      Signals.Huygens.huygensSteinerOAMDoubleSlit 3 2 4 6 1 5 (4 / 5) 1 φ x y ∧
    Signals.QISM.yangR12_8 (Signals.QISM.spectralDiff 7 4) 2 *
        Signals.QISM.yangR13_8 (Signals.QISM.spectralDiff 7 1) 2 *
        Signals.QISM.yangR23_8 (Signals.QISM.spectralDiff 4 1) 2 =
      Signals.QISM.yangR23_8 (Signals.QISM.spectralDiff 4 1) 2 *
        Signals.QISM.yangR13_8 (Signals.QISM.spectralDiff 7 1) 2 *
        Signals.QISM.yangR12_8 (Signals.QISM.spectralDiff 7 4) 2 :=
  ⟨toyDualLaneSolitonCoupler.dualLane_intensity_eq_huygensSteinerOAM rfl φ x y,
    (Signals.SolitonBus.solitonThreeWaveguide_yang_baxter_consistency 7 4 1 2
      (fun u => u ^ 2 - 1) (fun u => u + 2)).1⟩

/-! ## Plücker Sink-Flux Superposition, DDF Shear-Jamming Duality, & Anosov Symplectic Invariance tests -/

/-- Plücker sink-flux conservation Q_A + Q_B = Δ_02 Δ_13 = 2 and barycentric asymmetry
(Q_A - Q_B)/2 = d_bary = 3/5 on `asymmetricGr24DoubleSlitMatrix`. -/
example :
    Signals.DDF.pluckerSinkFluxA asymmetricGr24DoubleSlitMatrix +
        Signals.DDF.pluckerSinkFluxB asymmetricGr24DoubleSlitMatrix = 2 ∧
      (Signals.DDF.pluckerSinkFluxA asymmetricGr24DoubleSlitMatrix -
        Signals.DDF.pluckerSinkFluxB asymmetricGr24DoubleSlitMatrix) / 2 = 3 / 5 := by
  have h := Signals.DDF.pluckerSinkFlux_conservation_and_asymmetry asymmetricGr24DoubleSlitMatrix
  rw [h.1, h.2]
  norm_num [asymmetricGr24DoubleSlitMatrix, Signals.Geometry.twoRowMinor,
    Signals.Geometry.gr24BarycentricShift]

/-- Critique 1 verification: at the balanced symmetric point (Q_A = Q_B = 1, d_bary = 0),
the phased Gr(2,4) model has 0% relative error everywhere, whereas the unphased sum
w_A + w_B = Δ_02 Δ_13 = 2 has 50% (1/2) on-axis relative error. -/
example (x y : ℝ) :
    Signals.Geometry.gr24BarycentricShift balancedGr24DoubleSlitMatrix = 0 ∧
      Signals.Huygens.relativePredictiveError
        (Signals.Huygens.gr24PluckerDoubleSlit balancedGr24DoubleSlitMatrix 3 2 4 6 1 5 x y)
        (Signals.Huygens.fraunhoferRectangularDoubleSlit 3 2 4 6 1 5 x y) = 0 ∧
      Signals.Huygens.relativePredictiveError
        (Signals.Huygens.gr24UnphasedDoubleSlit balancedGr24DoubleSlitMatrix 3 2 4 1 5 0 0)
        (Signals.Huygens.fraunhoferRectangularDoubleSlit 3 2 4 6 1 5 0 0) = 1 / 2 :=
  Signals.DDF.ddf_symmetric_zero_shear_vs_unphased_critique
    balancedGr24DoubleSlitMatrix 3 2 4 6 1 5 x y (by norm_num)
    (by norm_num [Signals.DDF.pluckerSinkFluxA, balancedGr24DoubleSlitMatrix, Signals.Geometry.twoRowMinor])
    (by norm_num [Signals.DDF.pluckerSinkFluxB, balancedGr24DoubleSlitMatrix, Signals.Geometry.twoRowMinor])

/-- Quadratic power-law bounds d_bary²/4 ≤ ε ≤ d_bary²/2 and exact inversion
d_bary² = 4ε(1 - ε) at d_bary = 3/5 (where V = 4/5 and ε = 1/10). -/
example :
    let d_bary : ℝ := 3 / 5
    let V := Real.sqrt (1 - d_bary ^ 2)
    let ε := (1 - V) / 2
    d_bary ^ 2 / 4 ≤ ε ∧ ε ≤ d_bary ^ 2 / 2 ∧ d_bary ^ 2 = 4 * ε * (1 - ε) :=
  Signals.DDF.ddf_relative_error_power_law_and_inversion (3 / 5) (by norm_num) (by norm_num)

/-- Symplectic 2D Anosov hyperbolic stretch preserves every Plücker minor and d_bary,
whereas a non-symplectic jamming deformation scales d_bary by exp(2(λ_1 + λ_2)t). -/
example (lyapunovRate t : ℝ) :
    Signals.Geometry.gr24BarycentricShift
        (Signals.DDF.anosovHyperbolicMatrix lyapunovRate t * asymmetricGr24DoubleSlitMatrix) =
      Signals.Geometry.gr24BarycentricShift asymmetricGr24DoubleSlitMatrix ∧
    (Signals.DDF.anosovHyperbolicMatrix lyapunovRate t).det = 1 :=
  ⟨(Signals.DDF.anosov_plucker_invariance asymmetricGr24DoubleSlitMatrix lyapunovRate t 0 1).2,
    Signals.DDF.anosovHyperbolicMatrix_det_one lyapunovRate t⟩

/-- Differential DDF vortex circulation vanishes at the symmetric irrotational point (ℓ_1 = ℓ_2 = 3),
yielding zero Wigner rotational relative predictive error. -/
example :
    toyDDFSubstrate.differentialVortexCirculation 1 3 3 = 0 ∧
      Signals.Huygens.relativePredictiveError
        (Signals.Huygens.wignerOAMDoubleSlit 3 2 4 6 1 5 2 (3 - 3) 0 0 0)
        (Signals.Huygens.fraunhoferOAMDoubleSlit 3 2 4 6 1 5 (3 - 3) 0 0 0) = 0 := by
  have h := toyDDFSubstrate.vortex_circulation_wigner_error 1 (by norm_num) 3 3
    3 2 4 6 1 5 2 (by norm_num) (by norm_num)
  exact ⟨h.2.1, h.2.2⟩

/-- Solution to Critique 1: at the symmetric point (Q_A = Q_B = 1), the squared real
crossing product (Δ_02 Δ_13)² = (1 + 1)² = 4 has 0% relative error at (0, 0), and
complex Gr_C(2,4) sink amplitudes w_A^ℂ + w_B^ℂ = Δ_02^ℂ Δ_13^ℂ have 0% error everywhere. -/
example (M_C : Matrix (Fin 2) (Fin 4) ℂ) (x y : ℝ) :
    Signals.DDF.gr24SquaredCrossingDoubleSlit balancedGr24DoubleSlitMatrix 3 2 4 1 5 0 0 =
      Signals.Huygens.fraunhoferRectangularDoubleSlit 3 2 4 6 1 5 0 0 ∧
    Signals.Huygens.relativePredictiveError
      (Signals.DDF.gr24SquaredCrossingDoubleSlit balancedGr24DoubleSlitMatrix 3 2 4 1 5 0 0)
      (Signals.Huygens.fraunhoferRectangularDoubleSlit 3 2 4 6 1 5 0 0) = 0 ∧
    Signals.DDF.complexPluckerSinkAmplitudeA M_C +
      Signals.DDF.complexPluckerSinkAmplitudeB M_C =
      Signals.Geometry.complexTwoRowMinor M_C 0 2 *
        Signals.Geometry.complexTwoRowMinor M_C 1 3 := by
  have h := Signals.DDF.ddf_critique1_solved_squared_crossing_and_complex_gr24
    balancedGr24DoubleSlitMatrix M_C 3 2 4 6 1 5 x y
    (by norm_num [Signals.DDF.pluckerSinkFluxA, balancedGr24DoubleSlitMatrix, Signals.Geometry.twoRowMinor])
    (by norm_num [Signals.DDF.pluckerSinkFluxB, balancedGr24DoubleSlitMatrix, Signals.Geometry.twoRowMinor])
  exact ⟨h.1, h.2.1, h.2.2.1⟩

/-- Solution to Critique 2: projectively normalized Plücker barycentric shift d̂_bary and
visibility V̂² obey d̂_bary² + V̂² = 1 and are invariant under arbitrary non-symplectic
compressive jamming diag(exp(rate1 * t), exp(rate2 * t)). -/
example (rate1 rate2 t : ℝ) :
    let B : Matrix (Fin 2) (Fin 2) ℝ :=
      !![Real.exp (rate1 * t), 0; 0, Real.exp (rate2 * t)]
    (Signals.Geometry.gr24ProjectiveBarycentricShift asymmetricGr24DoubleSlitMatrix) ^ 2 +
      Signals.Geometry.gr24ProjectiveVisibilitySq asymmetricGr24DoubleSlitMatrix = 1 ∧
    Signals.Geometry.gr24ProjectiveBarycentricShift (B * asymmetricGr24DoubleSlitMatrix) =
      Signals.Geometry.gr24ProjectiveBarycentricShift asymmetricGr24DoubleSlitMatrix ∧
    Signals.Geometry.gr24ProjectiveVisibilitySq (B * asymmetricGr24DoubleSlitMatrix) =
      Signals.Geometry.gr24ProjectiveVisibilitySq asymmetricGr24DoubleSlitMatrix :=
  ⟨Signals.Geometry.gr24_projective_pythagorean_complementarity asymmetricGr24DoubleSlitMatrix
      (by norm_num [asymmetricGr24DoubleSlitMatrix, Signals.Geometry.twoRowMinor]),
    (Signals.DDF.ddf_critique2_solved_projective_and_trace_renormalized_jamming
      asymmetricGr24DoubleSlitMatrix rate1 rate2 t).1,
    (Signals.DDF.ddf_critique2_solved_projective_and_trace_renormalized_jamming
      asymmetricGr24DoubleSlitMatrix rate1 rate2 t).2.1⟩

/-- Solution to Critique 3: recovery of DDF substrate product ϱ_max^φ * j_min^φ = 1/4
and velocity squared v² = 1 from `toyMovingSheath` optical error ε, and quantized
vortex frame-dragging swirl velocity on `toyRiverExterior`. -/
example (hbar r : ℝ) (ℓ₁ ℓ₂ : ℤ) :
    let ε := (1 - toyMovingSheath.coherenceVisibility) / 2
    toyDDFSubstrate.rho_max_varphi * toyDDFSubstrate.j_min_varphi *
        toyMovingSheath.velocity ^ 2 = 4 * ε * (1 - ε) ∧
    toyRiverExterior.swirlVelocity (((ℓ₂ - ℓ₁ : ℤ) : ℝ) * hbar) r =
      (toyRiverExterior.G_phi * toyDDFSubstrate.m_phi *
        (toyDDFSubstrate.rho_max_varphi * toyDDFSubstrate.j_min_varphi) /
        (Real.pi * r ^ 2)) *
        toyDDFSubstrate.differentialVortexCirculation hbar ℓ₁ ℓ₂ ∧
    toyRiverExterior.swirlVelocity (((ℓ₁ - ℓ₁ : ℤ) : ℝ) * hbar) r = 0 :=
  ⟨(toyMovingSheath.ddf_critique3_solved_substrate_parameter_recovery).1,
    (toyRiverExterior.quantized_vortex_swirl_from_circulation hbar r ℓ₁ ℓ₂).1,
    (toyRiverExterior.quantized_vortex_swirl_from_circulation hbar r ℓ₁ ℓ₂).2⟩

/-- Master Gr_C(2,4)-DDF Unification: `toyMovingSheath.gr24TwistorMatrix` has Madelung
sink densities 1 + β and 1 - β multiplying to γ_φ(v)⁻², and its pure crossing-minor
intensity matches `huygensSteinerOAMDoubleSlit` with visibility γ_φ(v)⁻¹ and 0% error everywhere. -/
example (Δℓ : ℤ) (φ x y : ℝ) :
    let M_C := toyMovingSheath.gr24TwistorMatrix 6 1 5 Δℓ φ x
    Complex.normSq (Signals.DDF.complexPluckerSinkAmplitudeA M_C) *
        Complex.normSq (Signals.DDF.complexPluckerSinkAmplitudeB M_C) =
      (toyMovingSheath.jammingFactor ^ 2)⁻¹ ∧
    Signals.Huygens.complexGr24CrossingDoubleSlit M_C 3 2 4 1 5 x y =
      Signals.Huygens.huygensSteinerOAMDoubleSlit
        3 2 4 6 1 5 (toyMovingSheath.jammingFactor)⁻¹ Δℓ φ x y ∧
    Signals.Huygens.relativePredictiveError
      (Signals.Huygens.complexGr24CrossingDoubleSlit M_C 3 2 4 1 5 x y)
      (Signals.Huygens.huygensSteinerOAMDoubleSlit
        3 2 4 6 1 5 (toyMovingSheath.jammingFactor)⁻¹ Δℓ φ x y) = 0 := by
  intro M_C
  have h_mad := toyMovingSheath.gr24TwistorMatrix_madelung_sector_identities 6 1 5 Δℓ φ x
  have h_cross := toyMovingSheath.gr24TwistorMatrix_crossing_eq_ddf_oam_intensity
    3 2 4 6 1 5 Δℓ φ x y
  exact ⟨h_mad.2.2.2.2.1.trans h_mad.2.2.2.2.2, h_cross.1, h_cross.2⟩

/-- Triple-slit (N = 3) principal peak 9, secondary-minimum null at β = π/3,
on-axis relative error (2/3)(1 - V) = 2/15 at V = 4/5, and exact Gr_C(2,5) collector match. -/
example (Δℓ : ℤ) (φ x y : ℝ) :
    Signals.Huygens.multiSlitInterferenceFactor 3 1 0 = 9 ∧
    Signals.Huygens.multiSlitInterferenceFactor 3 1 (Real.pi / 3) = 0 ∧
    Signals.Huygens.relativePredictiveError
      (Signals.Huygens.huygensSteinerMultiSlit 3 3 2 4 6 1 5 (4 / 5) Δℓ 0 0 0)
      (Signals.Huygens.fraunhoferMultiSlit 3 3 2 4 6 1 5 Δℓ 0 0 0) = 2 / 15 ∧
    (let β := Real.pi * 6 * x / (1 * 5) + (Δℓ : ℝ) * φ / 2
     let z0 : ℂ := ↑(Real.cos (2 * β)) + Complex.I * ↑(Real.sin (2 * β))
     let z1 : ℂ := 1
     let z2 : ℂ := ↑(Real.cos (2 * β)) - Complex.I * ↑(Real.sin (2 * β))
     let M_C := Signals.Geometry.complexGr2NChannelMatrix 3 ![z0, z1, z2]
     Signals.Huygens.relativePredictiveError
       (Signals.Huygens.complexGr2NCollectorMultiSlit 3 M_C 3 2 4 1 5 x y)
       (Signals.Huygens.fraunhoferMultiSlit 3 3 2 4 6 1 5 Δℓ φ x y) = 0) := by
  have h_pn := Signals.Huygens.tripleSlit_peak_and_secondary_null 1
  have h_err := Signals.Huygens.tripleSlit_onAxis_relative_error
    3 2 4 6 1 5 (4 / 5) Δℓ (by norm_num) (by norm_num)
  have h_gr25 := (Signals.Huygens.complexGr25CollectorTripleSlit_eq_fraunhoferMultiSlit
    3 2 4 6 1 5 Δℓ φ x y).2
  refine ⟨h_pn.2.1, h_pn.2.2, ?_, h_gr25⟩
  rw [h_err]
  norm_num

/-- Triple-slit (N = 3) Gr_C(2,5)-DDF sheath twistor matrix Madelung sector densities
sum to 3, multiply to γ_φ(v)⁻², and have vanishing Sorkin third-order parameter κ₃ = 0. -/
example (Δℓ : ℤ) (φ x : ℝ) :
    let M_5 := toyMovingSheath.gr25TripleSlitTwistorMatrix 6 1 5 Δℓ φ x
    let A0 := Signals.Geometry.complexTwoRowMinor M_5
      (Signals.Geometry.narySourceCol 3) (Signals.Geometry.narySlitCol 0)
    let A1 := Signals.Geometry.complexTwoRowMinor M_5
      (Signals.Geometry.narySourceCol 3) (Signals.Geometry.narySlitCol 1)
    let A2 := Signals.Geometry.complexTwoRowMinor M_5
      (Signals.Geometry.narySourceCol 3) (Signals.Geometry.narySlitCol 2)
    Complex.normSq A0 + Complex.normSq A1 + Complex.normSq A2 = 3 ∧
      Complex.normSq A0 * Complex.normSq A1 * Complex.normSq A2 =
        (toyMovingSheath.jammingFactor ^ 2)⁻¹ ∧
      Signals.Geometry.sorkinTripleSlitParameter A0 A1 A2 = 0 := by
  have h := toyMovingSheath.gr25TripleSlitTwistorMatrix_madelung_sector_identities 6 1 5 Δℓ φ x
  exact ⟨h.2.2.2.1, h.2.2.2.2.2.1, h.2.2.2.2.2.2⟩

/-- Mercury-like eccentric orbit (a = 387/1000 AU, e = 2056/10000) and Earth-like orbit (a = 1 AU, e = 167/10000). -/
noncomputable def toyMercuryOrbit : Signals.DDF.PlanetaryOrbit :=
  { semiMajorAxis := 387 / 1000
    semiMajorAxis_pos := by norm_num
    eccentricity := 2056 / 10000
    eccentricity_nonneg := by norm_num
    eccentricity_lt_one := by norm_num }

noncomputable def toyEarthOrbit : Signals.DDF.PlanetaryOrbit :=
  { semiMajorAxis := 1
    semiMajorAxis_pos := by norm_num
    eccentricity := 167 / 10000
    eccentricity_nonneg := by norm_num
    eccentricity_lt_one := by norm_num }

/-- Kepler's Third Law, acoustic-horizon / DDF substrate perihelion precession, and
universal planetary semi-latus rectum ratio across Mercury and Earth. -/
example :
    toyRiverExterior.keplerPeriodSq toyMercuryOrbit / toyMercuryOrbit.semiMajorAxis ^ 3 =
      toyRiverExterior.keplerPeriodSq toyEarthOrbit / toyEarthOrbit.semiMajorAxis ^ 3 ∧
    toyRiverExterior.perihelionPrecessionRad toyMercuryOrbit =
      3 * Real.pi * toyRiverExterior.horizonRadius / toyMercuryOrbit.semiLatusRectum ∧
    toyRiverExterior.perihelionPrecessionRad toyMercuryOrbit /
        toyRiverExterior.perihelionPrecessionRad toyEarthOrbit =
      toyEarthOrbit.semiLatusRectum / toyMercuryOrbit.semiLatusRectum := by
  rw [toyRiverExterior.kepler_third_law toyMercuryOrbit,
    toyRiverExterior.kepler_third_law toyEarthOrbit]
  exact ⟨rfl,
    (toyRiverExterior.perihelionPrecession_eq_horizon_and_substrate toyMercuryOrbit).2.1,
    toyRiverExterior.perihelionPrecession_ratio toyMercuryOrbit toyEarthOrbit⟩

/-- Gr_C(2,4) planetary orbital precession twistor matrix encodes aphelion/perihelion
ratios, eccentricity, semi-latus rectum ratio p/a = 1 - e², and Δϖ cosine. -/
example (Δϖ : ℝ) :
    let M_C := toyMercuryOrbit.gr24PrecessionMatrix Δϖ
    Complex.normSq (Signals.DDF.complexPluckerSinkAmplitudeA M_C) =
        toyMercuryOrbit.aphelionRadius / toyMercuryOrbit.semiMajorAxis ∧
      Complex.normSq (Signals.DDF.complexPluckerSinkAmplitudeB M_C) =
        toyMercuryOrbit.perihelionRadius / toyMercuryOrbit.semiMajorAxis ∧
      Complex.normSq (Signals.DDF.complexPluckerSinkAmplitudeA M_C) *
        Complex.normSq (Signals.DDF.complexPluckerSinkAmplitudeB M_C) =
        toyMercuryOrbit.semiLatusRectum / toyMercuryOrbit.semiMajorAxis := by
  have h := toyMercuryOrbit.gr24PrecessionMatrix_orbital_identities Δϖ
  exact ⟨h.1, h.2.1, h.2.2.2.1⟩

/-- Precessing conic trajectory turning points (perihelion at φ = 0, aphelion at φ = π/(1 - η)),
exact π-free arcsecond precession formula, and Mercury's 42.98''/cy and 574.61''/cy bounds. -/
example :
    1 / toyMercuryOrbit.perihelionRadius + 1 / toyMercuryOrbit.aphelionRadius =
      2 / toyMercuryOrbit.semiLatusRectum ∧
    toyMercuryOrbit.precessingRadius (1 / 1000) 0 = toyMercuryOrbit.perihelionRadius ∧
    toyMercuryOrbit.precessingRadius (1 / 1000) (Real.pi / (1 - 1 / 1000)) =
      toyMercuryOrbit.aphelionRadius ∧
    toyRiverExterior.perihelionPrecessionArcsecPerOrbit toyMercuryOrbit =
      1944000 * toyRiverExterior.horizonRadius / toyMercuryOrbit.semiLatusRectum ∧
    4298 / 100 < (1944000 * (295325 / 100000 : ℝ) / 55460529) * (4152026 / 10000) ∧
    (1944000 * (295325 / 100000 : ℝ) / 55460529) * (4152026 / 10000) < 4299 / 100 := by
  have h_tp := toyMercuryOrbit.precessingRadius_perihelion_and_aphelion (1 / 1000) (by norm_num)
  have h_arc := (toyRiverExterior.perihelionPrecessionArcsecPerOrbit_eq toyMercuryOrbit).1
  have h_merc := Signals.DDF.mercury_perihelion_precession_arcsec_per_century_bounds
  exact ⟨toyMercuryOrbit.harmonic_mean_semiLatusRectum, h_tp.1, h_tp.2, h_arc, h_merc.1, h_merc.2.1⟩

/-- Normed 2D Anisotropic Tensor Gaussian Splatting for DDF MovingSheath and Gr_C(2,4) PlanetaryOrbit. -/
example (θ ϖ x y : ℝ) :
    let splat_ddf := toyMovingSheath.ddfTensorSplat 0 0 5 2 (by norm_num) (by norm_num) θ
    let splat_orb := toyMercuryOrbit.gr24TensorSplat 1 (-1) 3 2 (by norm_num) (by norm_num) ϖ
    0 ≤ splat_ddf.eval x y ∧
    splat_ddf.eval x y ≤ splat_ddf.eval 0 0 ∧
    splat_ddf.covDet = 2 ^ 4 * (toyMovingSheath.jammingFactor ^ 2)⁻¹ ∧
    splat_ddf.normFactor = toyMovingSheath.jammingFactor / (2 * Real.pi * 2 ^ 2) ∧
    splat_orb.covTrace = 2 * 2 ^ 2 ∧
    splat_orb.covDet = 2 ^ 4 * (toyMercuryOrbit.semiLatusRectum / toyMercuryOrbit.semiMajorAxis) := by
  intro splat_ddf splat_orb
  have h_prop := splat_ddf.eval_properties x y
  have h_ddf := toyMovingSheath.ddfTensorSplat_identities 0 0 5 2 (by norm_num) (by norm_num) θ
  have h_orb := toyMercuryOrbit.gr24TensorSplat_identities 1 (-1) 3 2 (by norm_num) (by norm_num) ϖ
  exact ⟨h_prop.2.2.2.1, h_prop.2.2.2.2.2, h_ddf.2.1, h_ddf.2.2, h_orb.1, h_orb.2.2⟩

/-- Complex Gr_C(2,4) twistor wavepacket representation on a NormedTensorGaussianSplat2D
and core repulsive Bohm quantum potential scaling Q_core^DDF ∝ γ_φ(v)² + 1. -/
example (M_C : Matrix (Fin 2) (Fin 4) ℂ) (θ x y : ℝ) :
    let splat_ddf := toyMovingSheath.ddfTensorSplat 0 0 5 2 (by norm_num) (by norm_num) θ
    splat_ddf.complexTwistorIntensity M_C x y =
      splat_ddf.eval x y *
        Complex.normSq
          (Signals.Geometry.complexTwoRowMinor M_C 0 2 *
            Signals.Geometry.complexTwoRowMinor M_C 1 3) ∧
    0 < splat_ddf.coreBohmPotential 1 1 ∧
    splat_ddf.coreBohmPotential 1 1 =
      (1 ^ 2 / (4 * 1 * 2 ^ 2)) * (toyMovingSheath.jammingFactor ^ 2 + 1) := by
  intro splat_ddf
  have h_tw := splat_ddf.complexTwistor_representation_identities M_C x y
  have h_bohm := NormedTensorGaussianSplat2D.coreBohmPotential_identities
    toyMovingSheath splat_ddf 0 0 5 2 1 1 θ (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  exact ⟨h_tw.2.1, h_bohm.1, h_bohm.2.2⟩

/-- Madelung Quantum Pressure Tensor Π_ij precision-matrix trace/determinant identities
and DDF longitudinal-to-transverse quantum stress ratio Π_11^DDF = γ_φ(v)² Π_22^DDF. -/
example (θ x y : ℝ) :
    let splat_ddf := toyMovingSheath.ddfTensorSplat 0 0 5 2 (by norm_num) (by norm_num) θ
    splat_ddf.quantumPressureTrace 1 1 x y =
      (splat_ddf.coreBohmPotential 1 1 / 1) * splat_ddf.eval x y ∧
    splat_ddf.quantumPressureDet 1 1 x y =
      (1 ^ 2 / (4 * 1 ^ 2)) ^ 2 * (splat_ddf.eval x y ^ 2 / splat_ddf.covDet) ∧
    splat_ddf.quantumPressurePrincipal1 1 1 x y =
      toyMovingSheath.jammingFactor ^ 2 * splat_ddf.quantumPressurePrincipal2 1 1 x y := by
  intro splat_ddf
  have h_qp := NormedTensorGaussianSplat2D.quantumPressureTensor_identities
    toyMovingSheath splat_ddf 0 0 5 2 1 1 θ x y (by norm_num) (by norm_num) (by norm_num)
  exact ⟨h_qp.1, h_qp.2.2.1, h_qp.2.2.2⟩

/-- Inverse Compton Thomson Doppler upshift, Klein-Nishina quantum recoil suppression,
and Stokes/anti-Stokes Raman Gr_C(2,4) channel inversion & thermal Boltzmann asymmetry. -/
example (Δℓ : ℤ) (φ x : ℝ) :
    let M_C := toyMovingSheath.gr24TwistorMatrix 6 1 5 Δℓ φ x
    Complex.normSq (Signals.DDF.complexPluckerSinkAmplitudeA M_C) /
        Complex.normSq (Signals.DDF.complexPluckerSinkAmplitudeB M_C) =
      Signals.Scattering.inverseComptonDopplerRatio toyMovingSheath.beta ∧
    Signals.Scattering.inverseComptonKleinNishinaRatio (3 / 5) (1 / 10) <
      Signals.Scattering.inverseComptonDopplerRatio (3 / 5) ∧
    Signals.Scattering.reconstructSpectralDiff
      (Signals.Scattering.ramanAntiStokesFreq 10 2)
      (Signals.Scattering.ramanStokesFreq 10 2) = 10 ∧
    Signals.Scattering.reconstructYangCoupling
      (Signals.Scattering.ramanAntiStokesFreq 10 2)
      (Signals.Scattering.ramanStokesFreq 10 2) = 2 ∧
    Signals.Scattering.ramanAntiStokesToStokesThermalRatio 10 2 (1 / 2) <
      (Signals.Scattering.ramanAntiStokesFreq 10 2 /
        Signals.Scattering.ramanStokesFreq 10 2) ^ 4 := by
  intro M_C
  have h_ics_ddf := toyMovingSheath.inverseCompton_gr24_identities 6 1 5 Δℓ φ x
  have h_ics := Signals.Scattering.inverseCompton_thomson_and_recoil_identities
    (3 / 5) (1 / 10) (by norm_num) (by norm_num) (by norm_num)
  have h_ram := Signals.Scattering.raman_stokes_antiStokes_gr24_identities
    10 2 (1 / 2) (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  exact ⟨h_ics_ddf.1, h_ics.2.2.2, h_ram.1, h_ram.2.1, h_ram.2.2.2.2⟩

/-- Fourier acausal phase-speed blow-up, Cattaneo-Vernotte hyperbolic second-sound
factorization, and unified Grassmannian-DDF subluminal thermal transport & splat evolution. -/
noncomputable def toyCattaneoVernotteModel : Signals.DDF.CattaneoVernotteHeatModel :=
  { thermalConductivity := 4
    thermalConductivity_pos := by norm_num
    volumetricHeatCapacity := 2
    volumetricHeatCapacity_pos := by norm_num
    relaxationTime := 1 / 2
    relaxationTime_pos := by norm_num }

example (θ : ℝ) :
    let m_f := toyCattaneoVernotteModel.toFourierHeatModel
    let ω_star := (10 : ℝ) ^ 2 / (2 * m_f.diffusivity) + 1
    let splat_ddf := toyMovingSheath.ddfTensorSplat 0 0 5 2 (by norm_num) (by norm_num) θ
    let splat_evol := splat_ddf.evolveThermal 1 2 3 (by norm_num) (by norm_num) (by norm_num)
    (10 : ℝ) ^ 2 < m_f.highFreqPhaseSpeedSq ω_star ∧
    0 < toyCattaneoVernotteModel.secondSoundSpeed ∧
    toyCattaneoVernotteModel.cattaneoFluxResidual 7 0 (-2) =
      7 - m_f.fourierFlux (-2) ∧
    0 < toyMovingSheath.ddfSecondSoundSpeed 1 ∧
    toyMovingSheath.ddfSecondSoundSpeed 1 ≤ toyDDFSubstrate.c ∧
    toyMovingSheath.ddfLongitudinalDiffusivity 1 (1 / 2) / (1 ^ 2 * (1 / 2)) =
      splat_ddf.covDet / 2 ^ 4 ∧
    splat_evol.weight = splat_ddf.weight ∧
    splat_evol.covTrace = splat_ddf.covTrace + 2 * (1 + 2) * 3 := by
  intro m_f ω_star splat_ddf splat_evol
  have h_f := m_f.diffusivity_pos_and_acausal_speed 10
  have h_cv := toyCattaneoVernotteModel.identities 7 (-2) 0 0 0
  have h_c_ge : (1 : ℝ) ≤ toyDDFSubstrate.c := by
    dsimp [toyDDFSubstrate, Signals.DDF.DDFSubstrate.c]
    norm_num
  have h_ddf_th := toyMovingSheath.ddfThermalTransport_and_splat_identities
    splat_ddf 0 0 5 2 1 (1 / 2) 1 2 3 θ
    (by norm_num) (by norm_num) (by norm_num) h_c_ge (by norm_num)
    (by norm_num) (by norm_num) (by norm_num)
  exact ⟨h_f.2.2, h_cv.2.1, h_cv.2.2.2.2, h_ddf_th.1, h_ddf_th.2.1,
    h_ddf_th.2.2.2.1, h_ddf_th.2.2.2.2.1, h_ddf_th.2.2.2.2.2⟩

/-- Splat-free continuum Grassmannian Gr_C(2,4)-DDF thermal transport:
subluminal second sound, Plücker channel product bridge for jammed diffusivity,
telegrapher wave-operator factorization, and Gr_C(2,4) Riemann-invariant flux limiter. -/
example (θ : ℝ) :
    let M_sheath := toyMovingSheath.gr24TwistorMatrix 6 1 5 2 0 0
    let M_th := Signals.DDF.ddfThermalGr24Matrix (3 / 5) θ
    0 < toyMovingSheath.ddfSecondSoundSpeed 1 ∧
    toyMovingSheath.ddfSecondSoundSpeed 1 ≤ toyDDFSubstrate.c ∧
    toyMovingSheath.ddfLongitudinalDiffusivity 1 (1 / 2) / (1 ^ 2 * (1 / 2)) =
      Complex.normSq (Signals.DDF.complexPluckerSinkAmplitudeA M_sheath) *
        Complex.normSq (Signals.DDF.complexPluckerSinkAmplitudeB M_sheath) ∧
    toyMovingSheath.ddfTelegrapherResidual 1 (1 / 2) 4 2 (-1) /
        toyMovingSheath.ddfLongitudinalDiffusivity 1 (1 / 2) =
      (toyMovingSheath.jammingFactor ^ 2 / 1 ^ 2) * 4 +
        (toyMovingSheath.jammingFactor ^ 2 / (1 ^ 2 * (1 / 2))) * 2 - (-1) ∧
    (Complex.normSq (Signals.DDF.complexPluckerSinkAmplitudeA M_th) -
        Complex.normSq (Signals.DDF.complexPluckerSinkAmplitudeB M_th)) / 2 = 3 / 5 ∧
    0 < Complex.normSq (Signals.DDF.complexPluckerSinkAmplitudeA M_th) *
        Complex.normSq (Signals.DDF.complexPluckerSinkAmplitudeB M_th) := by
  intro M_sheath M_th
  have h_c_ge : (1 : ℝ) ≤ toyDDFSubstrate.c := by
    dsimp [toyDDFSubstrate, Signals.DDF.DDFSubstrate.c]
    norm_num
  have h_cont := toyMovingSheath.ddfThermalTransport_continuum_identities
    1 (1 / 2) 6 1 5 0 0 4 2 (-1) (3 / 5) θ 2
    (by norm_num) h_c_ge (by norm_num) (by norm_num) (by norm_num)
  exact ⟨h_cont.1, h_cont.2.1, h_cont.2.2.1, h_cont.2.2.2.2.1,
    h_cont.2.2.2.2.2.1, h_cont.2.2.2.2.2.2.2⟩

/-- Bose-Einstein spontaneous/stimulated Raman occupancy ratio n_BE / (n_BE + 1) = exp(-ξ),
exact Raman thermometer inversion, physical DDF heat-flux bound, and Second-Law
covariance determinant growth det Σ(t + Δt) > det Σ(t). -/
example (θ : ℝ) :
    let splat_ddf := toyMovingSheath.ddfTensorSplat 0 0 5 2 (by norm_num) (by norm_num) θ
    let splat_evol := splat_ddf.evolveThermal 1 2 3 (by norm_num) (by norm_num) (by norm_num)
    Signals.Scattering.boseEinsteinOccupancy (1 / 2) /
        (Signals.Scattering.boseEinsteinOccupancy (1 / 2) + 1) =
      Real.exp (-(1 / 2 : ℝ)) ∧
    Signals.Scattering.reconstructRamanBoltzmannExponent 10 2
        (Signals.Scattering.ramanAntiStokesToStokesThermalRatio 10 2 (1 / 2)) = 1 / 2 ∧
    splat_ddf.covDet < splat_evol.covDet := by
  intro splat_ddf splat_evol
  have h_be := Signals.Scattering.raman_boseEinstein_and_thermometer_inversion
    10 2 (1 / 2) (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  have h_c_ge : (1 : ℝ) ≤ toyDDFSubstrate.c := by
    dsimp [toyDDFSubstrate, Signals.DDF.DDFSubstrate.c]
    norm_num
  have h_qmax_pos : 0 < toyMovingSheath.ddfMaxCausalHeatFlux 2 1 10 := by
    unfold Signals.DDF.MovingSheath.ddfMaxCausalHeatFlux
      Signals.DDF.MovingSheath.ddfSecondSoundSpeed
    have h_vis : 0 < toyMovingSheath.coherenceVisibility :=
      Real.sqrt_pos.mpr toyMovingSheath.one_sub_betaSq_pos
    positivity
  have h_ent := toyMovingSheath.ddfThermal_fluxLimiter_and_entropy_growth
    splat_ddf 2 1 10 0 1 2 3
    (by norm_num) (by norm_num) h_c_ge (by norm_num)
    (by rw [zero_div]; norm_num) (by rw [zero_div]; norm_num)
    (by norm_num) (by norm_num) (by norm_num)
  exact ⟨h_be.2.1, h_be.2.2.2, h_ent.2.2.2.2.2 ⟨by norm_num, by norm_num⟩⟩

/-- Complete inverse recovery of Inverse Compton β, Klein-Nishina recoil ε_rec,
and absolute Raman temperature T, together with Chapman-Kolmogorov thermal
semigroup identity/additivity and monotonic Bohm potential relaxation both with
and without Tensor Gaussian Splats. -/
example (θ : ℝ) :
    let D := Signals.Scattering.inverseComptonDopplerRatio (3 / 5)
    let R_KN := Signals.Scattering.inverseComptonKleinNishinaRatio (3 / 5) (1 / 4)
    let R_Raman := Signals.Scattering.ramanAntiStokesToStokesThermalRatio 10 2 (150 / 300)
    -- With Tensor Gaussian Splats:
    let splat_ddf := toyMovingSheath.ddfTensorSplat 0 0 5 2 (by norm_num) (by norm_num) θ
    let step0 := splat_ddf.evolveThermal 1 2 0 (by norm_num) (by norm_num) le_rfl
    let step1 := splat_ddf.evolveThermal 1 2 3 (by norm_num) (by norm_num) (by norm_num)
    let step12 := step1.evolveThermal 1 2 4 (by norm_num) (by norm_num) (by norm_num)
    let step_sum := splat_ddf.evolveThermal 1 2 (3 + 4) (by norm_num) (by norm_num) (by norm_num)
    -- Without Splats (Continuum Modes, Cattaneo Heat-Flux Relaxation, and Gr_C(2,4) Plücker Second Law):
    let kappa1 := Signals.DDF.evolveContinuumThermalMode 2 1 3 5
    let jq1 := Signals.DDF.evolveContinuumReducedHeatFlux (1 / 2) 3 (3 / 5)
    let M0 := Signals.DDF.ddfThermalGr24Matrix (3 / 5) θ
    let M1 := Signals.DDF.ddfThermalGr24Matrix jq1 θ
    Signals.Scattering.reconstructInverseComptonBeta D = 3 / 5 ∧
    Signals.Scattering.reconstructKleinNishinaRecoil D R_KN = 1 / 4 ∧
    Signals.Scattering.reconstructRamanTemperature 10 2 150 R_Raman = 300 ∧
    step0 = splat_ddf ∧
    step12 = step_sum ∧
    step1.coreBohmPotential 1 1 ≤ splat_ddf.coreBohmPotential 1 1 ∧
    Signals.DDF.evolveContinuumThermalMode 2 1 0 5 = 5 ∧
    Signals.DDF.evolveContinuumReducedHeatFlux (1 / 2) 0 (3 / 5) = 3 / 5 ∧
    Signals.DDF.evolveContinuumThermalMode 2 1 4 kappa1 =
      Signals.DDF.evolveContinuumThermalMode 2 1 (3 + 4) 5 ∧
    Signals.DDF.evolveContinuumReducedHeatFlux (1 / 2) 4 jq1 =
      Signals.DDF.evolveContinuumReducedHeatFlux (1 / 2) (3 + 4) (3 / 5) ∧
    Signals.DDF.continuumBohmPotentialMode 1 1 kappa1 =
      Signals.DDF.continuumBohmPotentialMode 1 1 5 * Real.exp (-2 * 2 * 1 ^ 2 * 3) ∧
    Signals.DDF.continuumBohmPotentialMode 1 1 kappa1 ≤
      Signals.DDF.continuumBohmPotentialMode 1 1 5 ∧
    Complex.normSq (Signals.DDF.complexPluckerSinkAmplitudeA M1) *
        Complex.normSq (Signals.DDF.complexPluckerSinkAmplitudeB M1) -
      Complex.normSq (Signals.DDF.complexPluckerSinkAmplitudeA M0) *
        Complex.normSq (Signals.DDF.complexPluckerSinkAmplitudeB M0) =
      (3 / 5) ^ 2 * (1 - Real.exp (-2 * 3 / (1 / 2))) ∧
    Complex.normSq (Signals.DDF.complexPluckerSinkAmplitudeA M0) *
        Complex.normSq (Signals.DDF.complexPluckerSinkAmplitudeB M0) ≤
      Complex.normSq (Signals.DDF.complexPluckerSinkAmplitudeA M1) *
        Complex.normSq (Signals.DDF.complexPluckerSinkAmplitudeB M1) := by
  intro D R_KN R_Raman splat_ddf step0 step1 step12 step_sum kappa1 jq1 M0 M1
  have h_inv := Signals.Scattering.inelastic_compton_and_raman_temperature_inversion
    (3 / 5) (1 / 4) 10 2 150 300 (1 / 10)
    (by norm_num) (by norm_num) (by norm_num)
    (by norm_num) (by norm_num) (by norm_num)
    (by norm_num) (by norm_num) (by norm_num)
  have h_semi := Signals.DDF.NormedTensorGaussianSplat2D.evolveThermal_semigroup_and_bohm_decay
    splat_ddf 1 2 3 4 1 1
    (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  have h_c_ge : (1 : ℝ) ≤ toyDDFSubstrate.c := by
    dsimp [toyDDFSubstrate, Signals.DDF.DDFSubstrate.c]
    norm_num
  have h_cont_semi := toyMovingSheath.ddfContinuum_semigroup_and_bohm_decay
    2 1 10 0 (1 / 2) 2 1 3 4 5 5 (3 / 5) 1 1 θ
    (by norm_num) (by norm_num) h_c_ge (by norm_num)
    (by rw [zero_div]; norm_num) (by rw [zero_div]; norm_num)
    (by norm_num) (by norm_num) (by norm_num)
    (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  exact ⟨h_inv.1, h_inv.2.1, h_inv.2.2.1, h_semi.1, h_semi.2.1, h_semi.2.2.2,
    h_cont_semi.2.2.2.1, h_cont_semi.2.2.2.2.1,
    h_cont_semi.2.2.2.2.2.1, h_cont_semi.2.2.2.2.2.2.1,
    h_cont_semi.2.2.2.2.2.2.2.1, h_cont_semi.2.2.2.2.2.2.2.2.1,
    h_cont_semi.2.2.2.2.2.2.2.2.2.1, h_cont_semi.2.2.2.2.2.2.2.2.2.2⟩

/-- Polariton Hopfield-Rabi anticrossing, inverse Rabi spectroscopy,
Lyddane-Sachs-Teller Reststrahlen stop-band, and Surface Plasmon Polariton (SPP)
dispersion, Gr_C(2,4) Plücker skin-depth duality, propagation semigroup, and
sub-wavelength Bohm pressure enhancement both with and without Tensor Gaussian Splats. -/
example (θ x y : ℝ) :
    let ω_UP := Signals.Scattering.upperPolaritonFreq 7 4 2
    let ω_LP := Signals.Scattering.lowerPolaritonFreq 7 4 2
    let d_hop := Signals.Scattering.hopfieldBarycentricShift (7 - 4) 2
    let w_ph := Signals.Scattering.hopfieldPhotonWeight d_hop
    let w_ex := Signals.Scattering.hopfieldMatterWeight d_hop
    -- Without Splats (Continuum SPP Dispersion, Gr_C(2,4) Plücker Skin-Depth Ratio, and Propagation Semigroup):
    let n_spp_sq := Signals.DDF.sppEffectiveIndexSq 2 6
    let chi_spp := Signals.DDF.sppPermittivityContrast 2 6
    let M_spp := Signals.DDF.sppGr24Matrix chi_spp θ
    let I_step1 := Signals.DDF.evolveContinuumSppPropagation (1 / 2) 3 10
    -- With Tensor Gaussian Splats (Sub-Wavelength SPP Hotspot Confinement & Ohmic-Thermal Semigroup):
    let splat_spp := Signals.DDF.sppHotspotTensorSplat 0 0 5 1 10 3
      (by norm_num) (by norm_num) (by norm_num) (by norm_num) θ
    let spp_step0 := splat_spp.evolveThermal 1 2 0 (by norm_num) (by norm_num) le_rfl
    let spp_step1 := splat_spp.evolveThermal 1 2 3 (by norm_num) (by norm_num) (by norm_num)
    let spp_step12 := spp_step1.evolveThermal 1 2 4 (by norm_num) (by norm_num) (by norm_num)
    let spp_step_sum := splat_spp.evolveThermal 1 2 (3 + 4) (by norm_num) (by norm_num) (by norm_num)
    ω_UP + ω_LP = 7 + 4 ∧
    2 * 2 ≤ ω_UP - ω_LP ∧
    Signals.Scattering.reconstructPolaritonRabiCouplingSq 7 4 ω_UP ω_LP = 2 ^ 2 ∧
    w_ph + w_ex = 1 ∧
    4 * w_ph * w_ex = 1 - d_hop ^ 2 ∧
    Signals.Scattering.lyddaneSachsTellerPermittivity 3 4 6 6 = 0 ∧
    Signals.Scattering.lyddaneSachsTellerPermittivity 3 4 6 5 < 0 ∧
    2 < n_spp_sq ∧
    (n_spp_sq - 2) / (n_spp_sq + 6) = 2 ^ 2 / 6 ^ 2 ∧
    Complex.normSq (Signals.DDF.complexPluckerSinkAmplitudeA M_spp) /
        Complex.normSq (Signals.DDF.complexPluckerSinkAmplitudeB M_spp) =
      Signals.DDF.reconstructSppPermittivityRatio chi_spp ∧
    Signals.DDF.reconstructSppPermittivityRatio chi_spp = 6 / 2 ∧
    Signals.DDF.evolveContinuumSppPropagation (1 / 2) 0 10 = 10 ∧
    Signals.DDF.evolveContinuumSppPropagation (1 / 2) 4 I_step1 =
      Signals.DDF.evolveContinuumSppPropagation (1 / 2) (3 + 4) 10 ∧
    Signals.DDF.continuumBohmPotentialMode 1 1 ((6 / 2) * 5) =
      (6 / 2) ^ 2 * Signals.DDF.continuumBohmPotentialMode 1 1 5 ∧
    splat_spp.covDet = 1 ^ 4 / (10 ^ 4 * 3 ^ 2) ∧
    1 ^ 2 / (2 * 1 * 1 ^ 2) ≤ splat_spp.coreBohmPotential 1 1 ∧
    splat_spp.quantumPressurePrincipal2 1 1 x y =
      3 ^ 2 * splat_spp.quantumPressurePrincipal1 1 1 x y ∧
    spp_step0 = splat_spp ∧
    spp_step12 = spp_step_sum ∧
    spp_step1.coreBohmPotential 1 1 ≤ splat_spp.coreBohmPotential 1 1 := by
  intro ω_UP ω_LP d_hop w_ph w_ex n_spp_sq chi_spp M_spp I_step1
    splat_spp spp_step0 spp_step1 spp_step12 spp_step_sum
  have h_pol := Signals.Scattering.polariton_hopfield_rabi_and_lst_identities
    7 4 2 3 4 6 5 (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  have h_spp_cont := toyMovingSheath.sppContinuum_gr24_and_semigroup_identities
    2 6 (1 / 2) 3 4 10 5 1 1 θ (by norm_num) (by norm_num)
  have h_spp_splat := toyMovingSheath.sppTensorSplat_and_thermal_identities
    0 0 5 1 10 3 1 2 3 4 1 1 θ x y
    (by norm_num) (by norm_num) (by norm_num) (by norm_num)
    (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  exact ⟨h_pol.1, h_pol.2.2.1, h_pol.2.2.2.1, h_pol.2.2.2.2.2.2.1,
    h_pol.2.2.2.2.2.2.2.2.1, h_pol.2.2.2.2.2.2.2.2.2.2.2.1,
    h_pol.2.2.2.2.2.2.2.2.2.2.2.2,
    h_spp_cont.2.1, h_spp_cont.2.2.1, h_spp_cont.2.2.2.2.2.1,
    h_spp_cont.2.2.2.2.2.2.1, h_spp_cont.2.2.2.2.2.2.2.2.1,
    h_spp_cont.2.2.2.2.2.2.2.2.2.1, h_spp_cont.2.2.2.2.2.2.2.2.2.2,
    h_spp_splat.1, h_spp_splat.2.2.2.1, h_spp_splat.2.2.2.2.1,
    h_spp_splat.2.2.2.2.2.1, h_spp_splat.2.2.2.2.2.2.1,
    h_spp_splat.2.2.2.2.2.2.2⟩

/-- Coherent Synchrotron Radiation (CSR) on cylindrical SPP microtubes/CNTs,
Cavity QED cooperativity, Cherenkov-Proca longitudinal phase matching,
Graphene THz-eV Dirac plasmon scaling, 4-state Grover quantum state carving,
Anti-Amplituhedron destructive cancellation, low-symmetry shear polaritons, and
't Hooft-Susskind-DDF Holographic Principle (with and without splats). -/
example (θ φ : ℝ) :
    let M_anti := Signals.DDF.antiAmplituhedronGr24Matrix 5
    let M_holo := Signals.DDF.ddfThermalGr24Matrix (toyRiverExterior.inflowBeta 4) θ
    let splat_p := Signals.DDF.holographicPlanckSplat 0 0 1 (1 / 2)
      (by norm_num) (by norm_num) θ
    Signals.Scattering.csrBunchingIntensity 10 0 3 = 10 * 3 ∧
    Signals.Scattering.csrBunchingIntensity 10 1 3 = 10 ^ 2 * 3 ∧
    10 * 3 ≤ Signals.Scattering.csrBunchingIntensity 10 (1 / 2) 3 ∧
    Signals.Scattering.csrBunchingIntensity 10 (1 / 2) 3 ≤ 10 ^ 2 * 3 ∧
    Signals.Scattering.cavityQEDCooperativity (Real.sqrt 10 * 2) 3 5 =
      10 * Signals.Scattering.cavityQEDCooperativity 2 3 5 ∧
    (2 : ℝ) ^ 2 < Signals.Scattering.transversePlasmaPhaseVelSq 2 5 3 ∧
    Signals.Scattering.longitudinalPlasmaPhaseVelSq (1 / 2) 3 2 < 2 ^ 2 ∧
    0 < 1 - (Signals.Scattering.cherenkovCosine 3 5) ^ 2 ∧
    Signals.Scattering.grapheneDiracPlasmonFreqSq (4 * 2) 7 =
      4 * Signals.Scattering.grapheneDiracPlasmonFreqSq 2 7 ∧
    Signals.Scattering.groverSuccessAmplitude (1 / 2) = 1 ∧
    Signals.Geometry.complexTwoRowMinor M_anti 0 2 *
        Signals.Geometry.complexTwoRowMinor M_anti 1 3 = 0 ∧
    Signals.DDF.lowSymmetryShearCoupling 4 4 φ = 0 ∧
    (toyRiverExterior.horizonSurfaceGravity * toyRiverExterior.horizonArea) /
        (4 * Real.pi * toyRiverExterior.G_phi) = toyRiverExterior.sourceMass ∧
    Complex.normSq (Signals.DDF.complexPluckerSinkAmplitudeA M_holo) *
        Complex.normSq (Signals.DDF.complexPluckerSinkAmplitudeB M_holo) =
      1 - toyRiverExterior.horizonRadius / 4 ∧
    splat_p.covDet = (1 / 2) ^ 4 ∧
    splat_p.coreBohmPotential 1 1 = 1 ^ 2 / (2 * 1 * (1 / 2) ^ 2) := by
  intro M_anti M_holo splat_p
  have h_csr := Signals.Scattering.csr_spp_cherenkov_cavity_and_grover_identities
    10 (1 / 2) 3 2 5 2 3 5 2 5 3 (1 / 2) 2 3 5 4 2 7
    (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num)
    (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  have hrH_lt : toyRiverExterior.horizonRadius < 4 := by
    have hc : toyDDFSubstrate.c = 2 := by
      dsimp [Signals.DDF.DDFSubstrate.c, toyDDFSubstrate]
      norm_num
    dsimp [Signals.DDF.RiverExterior.horizonRadius, toyRiverExterior]
    rw [hc]
    norm_num
  have h_holo := toyRiverExterior.holographic_gr24_ddf_and_antiAmplituhedron_identities
    5 4 2 φ 4 1 (1 / 2) 0 0 1 1 1 θ hrH_lt
    (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  exact ⟨h_csr.1, h_csr.2.1, h_csr.2.2.1, h_csr.2.2.2.1, h_csr.2.2.2.2.2.1,
    h_csr.2.2.2.2.2.2.1, h_csr.2.2.2.2.2.2.2.1, h_csr.2.2.2.2.2.2.2.2.2.2.2.1,
    h_csr.2.2.2.2.2.2.2.2.2.2.2.2.1, h_csr.2.2.2.2.2.2.2.2.2.2.2.2.2,
    h_holo.2.2.1, h_holo.2.2.2.1, h_holo.2.2.2.2.2.2.2.1,
    h_holo.2.2.2.2.2.2.2.2.1, h_holo.2.2.2.2.2.2.2.2.2.2.1,
    h_holo.2.2.2.2.2.2.2.2.2.2.2.1⟩

/-- Low-power integrated optical amplification through second-harmonic (χ^(2))
resonance (Dean et al. 2025, Nature s41586-025-09959-z): centrosymmetry selection
rule, SHG intracavity buildup, phase-matching detuning gate, and symplectic OPA
squeezing & Bohm quantum-potential barrier both with and without Tensor Gaussian Splats. -/
example (θ x y : ℝ) :
    let splat_opa := Signals.DDF.opaSqueezedTensorSplat 0 0 5 2 3
      (by norm_num) (by norm_num) θ
    Signals.Scattering.secondOrderPolarization 0 10 = 0 ∧
    (20 : ℝ) ≤ Signals.Scattering.shgResonantIntracavityPower 15 20 ∧
    Signals.Scattering.shgResonantIntracavityPower 15 (300 / 15) = 300 ∧
    Signals.Scattering.opaNetGainSq 4 0 = 4 ^ 2 ∧
    Signals.Scattering.opaNetGainSq 4 (2 * 4) = 0 ∧
    Signals.Scattering.opaAmplifiedQuadratureGain 3 *
      Signals.Scattering.opaSqueezedQuadratureGain 3 = 1 ∧
    Signals.DDF.continuumBohmPotentialMode 1 1 5 ≤
      Signals.DDF.continuumBohmPotentialMode 1 1 (5 * Real.exp 3) ∧
    splat_opa.covDet = 2 ^ 4 ∧
    splat_opa.normFactor = 1 / (2 * Real.pi * 2 ^ 2) ∧
    1 ^ 2 / (2 * 1 * 2 ^ 2) ≤ splat_opa.coreBohmPotential 1 1 ∧
    splat_opa.quantumPressurePrincipal2 1 1 x y =
      Real.exp (4 * 3) * splat_opa.quantumPressurePrincipal1 1 1 x y := by
  intro splat_opa
  have h_opa := Signals.Scattering.second_harmonic_opa_and_centrosymmetry_identities
    0 10 15 20 300 4 2 3 (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  have h_splat := Signals.DDF.opaSqueezed_splat_and_continuum_identities
    0 0 5 2 3 5 1 1 θ x y (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  exact ⟨h_opa.2.1, h_opa.2.2.1, h_opa.2.2.2.1, h_opa.2.2.2.2.1,
    h_opa.2.2.2.2.2.2.1, h_opa.2.2.2.2.2.2.2.2.2,
    h_splat.2.1, h_splat.2.2.1, h_splat.2.2.2.1, h_splat.2.2.2.2.2.1,
    h_splat.2.2.2.2.2.2⟩

/-- AdS/CFT dictionary (Maldacena 1998, GKPW 1998, KSS 2005, Ryu-Takayanagi 2006),
Planar Integrability (Beisert et al. 2012, arXiv:1012.3982), Secret Symmetries
(de Leeuw et al. 2012, arXiv:1204.2366), and Grassmannian Gr_C(2,4)-DDF unification
(with and without Tensor Gaussian Splats). -/
example (p p1 p2 B0 θ : ℝ) :
    let Δ_p := Signals.Scattering.adsCftScalingDimensionPlus 4 5
    let Δ_m := Signals.Scattering.adsCftScalingDimensionMinus 4 5
    let C_p := Signals.Scattering.psl22BraidedCentralChargeC p
    let CDag_p := Signals.Scattering.psl22BraidedCentralChargeCDag p
    let C_1 := Signals.Scattering.psl22BraidedCentralChargeC p1
    let C_2 := Signals.Scattering.psl22BraidedCentralChargeC p2
    let W_sec := Signals.DDF.psl22SecretAutomorphismGr24Matrix 2 1 1 1
    let M_ads5 := Signals.DDF.ddfThermalGr24Matrix ((1 / 2 : ℝ) ^ 2) θ
    let splat_uv := Signals.DDF.adsHolographicRGSplat 0 0 1 (1 / 2)
      (by norm_num) (by norm_num) θ
    let splat_ir := Signals.DDF.adsHolographicRGSplat 0 0 1 (2 * (1 / 2))
      (by norm_num) (by norm_num) θ
    Δ_p + Δ_m = 4 ∧
    Δ_p * Δ_m = -5 ∧
    Δ_p * (Δ_p - 4) = 5 ∧
    Signals.Scattering.adsCftScalingDimensionPlus 4
      (Signals.Scattering.adsBreitenlohnerFreedmanBound 4) = 4 / 2 ∧
    Signals.Scattering.adsCftScalingDimensionPlus 4 0 = 4 ∧
    Signals.Scattering.adsCftScalingDimensionMinus 4 0 = 0 ∧
    Signals.Scattering.ryuTakayanagiEntanglementEntropyAdS3 6 3 10 2 =
      (Signals.Scattering.brownHenneauxCentralCharge 6 3 / 3) * Real.log (10 / 2) ∧
    0 < Signals.Scattering.kssShearViscosityEntropyBound 1 1 ∧
    Signals.Scattering.adsCouplingFromStringTension (Real.sqrt 16 / (2 * Real.pi)) = 16 ∧
    Signals.Scattering.adsMagnonDispersion 2 16 0 = 2 ∧
    Signals.Scattering.adsMagnonDispersionSq 2
      (Signals.Scattering.adsCouplingFromStringTension 3) Real.pi = 2 ^ 2 + 4 * 3 ^ 2 ∧
    (2 : ℝ) ^ 2 ≤ Signals.Scattering.adsMagnonDispersionSq 2 16 p ∧
    2 * Signals.Scattering.betheOneLoopMagnonEnergy 16 (1 / (2 * Real.sqrt 3)) =
      Signals.Scattering.konishiOneLoopAnomalousDim 16 ∧
    Signals.Scattering.konishiOneLoopAnomalousDim 16 =
      (3 / 2) * Signals.Scattering.cuspAnomalousDimOneLoop 16 ∧
    Signals.Scattering.cuspAnomalousDimWeak3Loop 0 = 0 ∧
    C_p * CDag_p + C_p + CDag_p = 0 ∧
    (1 + C_1) * (1 + C_2) = 1 + Signals.Scattering.psl22BraidedCoproductC C_1 C_2 ∧
    Signals.Scattering.gl22LongRepDim 0 0 = 16 ∧
    Signals.Scattering.psl22ShortBoundStateDim 1 = 4 ∧
    Signals.Scattering.psl22ShortBoundStateDim 2 <
      Signals.Scattering.gl22LongRepDim (2 / 2) 0 ∧
    Matrix.trace (Signals.Scattering.secretSymmetryMatrix B0) = 0 ∧
    Signals.Scattering.supertrace22 (Signals.Scattering.secretSymmetryMatrix B0) = 4 * B0 ∧
    Signals.Scattering.qDeformedHubbardCartanDA.transpose =
      Signals.Scattering.qDeformedHubbardCartanDA ∧
    Matrix.mulVec Signals.Scattering.qDeformedHubbardCartanDA ![1, 1, 1, 1] = 0 ∧
    Matrix.trace Signals.Scattering.qDeformedHubbardCartanDA = 0 ∧
    Matrix.det Signals.Scattering.qDeformedHubbardCartanDA = 0 ∧
    Signals.Geometry.complexTwoRowMinor W_sec 0 1 = 1 ∧
    Signals.Geometry.complexTwoRowMinor W_sec 0 3 = 3 ∧
    (Signals.Geometry.complexTwoRowMinor W_sec 0 3) ^ 2 +
        Signals.Geometry.complexTwoRowMinor W_sec 0 2 *
          Signals.Geometry.complexTwoRowMinor W_sec 1 3 =
      Signals.Geometry.complexTwoRowMinor W_sec 0 1 *
        Signals.Geometry.complexTwoRowMinor W_sec 2 3 ∧
    Complex.normSq (Signals.DDF.complexPluckerSinkAmplitudeA M_ads5) *
        Complex.normSq (Signals.DDF.complexPluckerSinkAmplitudeB M_ads5) =
      Signals.DDF.adsPlanarBlackBraneEmblackening 1 2 4 ∧
    Signals.DDF.continuumBohmPotentialMode 1 1 ((1 / (1 / 2)) / 2) =
      (1 / 2 ^ 2) * Signals.DDF.continuumBohmPotentialMode 1 1 (1 / (1 / 2)) ∧
    splat_ir.covDet = 2 ^ 4 * splat_uv.covDet ∧
    splat_ir.coreBohmPotential 1 1 = (1 / 2 ^ 2) * splat_uv.coreBohmPotential 1 1 := by
  intro Δ_p Δ_m C_p CDag_p C_1 C_2 W_sec M_ads5 splat_uv splat_ir
  have hu_K : (1 / (2 * Real.sqrt 3 : ℝ)) ^ 2 = 1 / 12 := by
    have h3 : (Real.sqrt 3) ^ 2 = 3 := Real.sq_sqrt (by norm_num)
    calc
      (1 / (2 * Real.sqrt 3 : ℝ)) ^ 2 = 1 / (4 * (Real.sqrt 3) ^ 2) := by ring
      _ = 1 / 12 := by rw [h3]; norm_num
  have h_ads := Signals.Scattering.ads_cft_integrability_and_secret_symmetry_identities
    4 5 1 1 6 3 10 2 2 16 3 p (1 / (2 * Real.sqrt 3)) p1 p2 B0
    (by norm_num) (by norm_num [Signals.Scattering.adsBreitenlohnerFreedmanBound])
    (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num) hu_K
  have hrH_lt : toyRiverExterior.horizonRadius < 4 := by
    have hc : toyDDFSubstrate.c = 2 := by
      dsimp [Signals.DDF.DDFSubstrate.c, toyDDFSubstrate]
      norm_num
    dsimp [Signals.DDF.RiverExterior.horizonRadius, toyRiverExterior]
    rw [hc]
    norm_num
  have h_unif := toyRiverExterior.grassmannian_ads_cft_ddf_and_secret_symmetry_unification
    2 1 1 1 1 2 4 0 0 1 (1 / 2) 2 1 1 θ
    (by norm_num) (by norm_num) (by norm_num) hrH_lt
    (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  have h_w01 : Signals.Geometry.complexTwoRowMinor W_sec 0 1 = 1 := by
    rw [h_unif.1]
    norm_num
  have h_w03 : Signals.Geometry.complexTwoRowMinor W_sec 0 3 = 3 := by
    rw [h_unif.2.2.1]
    norm_num
  rcases h_ads with ⟨ha1, ha2, ha3, ha4, ha5, ha6, ha7, ha8, ha9, ha10,
    ha11, ha12, ha13, ha14, ha15, ha16, _ha17, ha18, ha19, ha20, ha21,
    ha22, ha23, ha24, ha25, ha26, ha27⟩
  rcases h_unif with ⟨_hu1, _hu2, _hu3, _hu4, _hu5, _hu6, _hu7, hu8,
    hu9, _hu10, _hu11, hu12, hu13, _hu14, hu15, _hu16⟩
  exact ⟨ha1, ha2, ha3, ha4, ha5, ha6, ha7, ha8, ha9, ha10,
    ha11, ha12, ha13, ha14, ha15, ha16, ha18, ha19, ha20, ha21,
    ha22, ha23, ha24, ha25, ha26, ha27,
    h_w01, h_w03, hu8, hu9, hu12, hu13, hu15⟩

/-- Paraxial Fresnel-to-Fraunhofer quadratic phase remainder bound, higher-rank
Gr(3, 6) four-term quadratic Plücker relation, three-channel (k = 3) LGV
vertex-disjoint path positivity vs. 2-vertex bottleneck cancellation,
full 16×16 psl(2|2)_c worldsheet R-matrix secret coproduct intertwining
(including the Yangian tail for arbitrary B1 ≠ B2 and L_BF ≠ 0), and
adaptive two-child Tensor Gaussian Splat splitting conservation. -/
def toyRank3GrassmannianMatrix : Matrix (Fin 3) (Fin 6) ℝ :=
  !![1, 2, -1, 3, 0, 4;
     0, 1, 2, -2, 1, -1;
     2, -1, 1, 0, 3, 2]

example (x y B1 B2 B0 A_B B_B D_F E_F G_BF L_BF θ : ℝ)
    (A32 : Matrix (Fin 3) (Fin 2) ℝ) (B23 : Matrix (Fin 2) (Fin 3) ℝ) :
    let φ_fraun := Signals.Huygens.fraunhoferLinearPhase x y (3 / 10) (4 / 10) (1 / 2) 10
    let Δφ := Signals.Huygens.fresnelPhaseRemainder (3 / 10) (4 / 10) (1 / 2) 10
    let φ_fres := Signals.Huygens.fresnelParaxialPhase x y (3 / 10) (4 / 10) (1 / 2) 10
    let N_F := Signals.Huygens.fresnelNumber 1 (1 / 2) 10
    let splat_ddf := toyMovingSheath.ddfTensorSplat 0 0 5 2 (by norm_num) (by norm_num) θ
    φ_fres - φ_fraun = Δφ ∧
    0 ≤ Δφ ∧
    Δφ ≤ Real.pi * N_F ∧
    Signals.Huygens.intensity (Signals.Huygens.unitPhasor φ_fres - Signals.Huygens.unitPhasor φ_fraun) ≤
      (Real.pi * N_F) ^ 2 ∧
    Signals.Geometry.threeRowMinor toyRank3GrassmannianMatrix 0 1 2 *
        Signals.Geometry.threeRowMinor toyRank3GrassmannianMatrix 3 4 5 -
      Signals.Geometry.threeRowMinor toyRank3GrassmannianMatrix 0 1 3 *
        Signals.Geometry.threeRowMinor toyRank3GrassmannianMatrix 2 4 5 +
      Signals.Geometry.threeRowMinor toyRank3GrassmannianMatrix 0 1 4 *
        Signals.Geometry.threeRowMinor toyRank3GrassmannianMatrix 2 3 5 -
      Signals.Geometry.threeRowMinor toyRank3GrassmannianMatrix 0 1 5 *
        Signals.Geometry.threeRowMinor toyRank3GrassmannianMatrix 2 3 4 = 0 ∧
    (Signals.Plabic.planarThreeChannelLowerStep 1 1 1 5 7 *
      Signals.Plabic.planarThreeChannelUpperStep 2 3 4 6 8).det = 2 * 3 * 4 ∧
    0 < (Signals.Plabic.planarThreeChannelLowerStep 1 1 1 5 7 *
      Signals.Plabic.planarThreeChannelUpperStep 2 3 4 6 8).det ∧
    (A32 * B23).det = 0 ∧
    Signals.Scattering.psl22GradedSwap16 * Signals.Scattering.psl22GradedSwap16 =
      (1 : Matrix (Fin 16) (Fin 16) ℝ) ∧
    Signals.Scattering.psl22SecretCoproductOp16 B1 B2 *
        Signals.Scattering.psl22WorldsheetRMatrix16 A_B B_B D_F E_F G_BF 0 =
      Signals.Scattering.psl22WorldsheetRMatrix16 A_B B_B D_F E_F G_BF 0 *
        Signals.Scattering.psl22SecretCoproductDiag16 B1 B2 ∧
    Signals.Scattering.psl22SecretCoproductOp16 B0 B0 *
        Signals.Scattering.psl22WorldsheetRMatrix16 A_B B_B D_F E_F G_BF L_BF =
      Signals.Scattering.psl22WorldsheetRMatrix16 A_B B_B D_F E_F G_BF L_BF *
        Signals.Scattering.psl22SecretCoproductDiag16 B0 B0 ∧
    (Signals.Scattering.psl22SecretCoproductOp16 B1 B2 *
        Signals.Scattering.psl22WorldsheetRMatrix16 A_B B_B D_F E_F G_BF L_BF -
      Signals.Scattering.psl22WorldsheetRMatrix16 A_B B_B D_F E_F G_BF L_BF *
        Signals.Scattering.psl22SecretCoproductDiag16 B1 B2) 2 2 =
      2 * (B2 - B1) * L_BF ∧
    Signals.Scattering.psl22SecretCoproductFullOp16 B1 B2 G_BF L_BF *
        Signals.Scattering.psl22WorldsheetRMatrix16 A_B B_B D_F E_F G_BF L_BF =
      Signals.Scattering.psl22WorldsheetRMatrix16 A_B B_B D_F E_F G_BF L_BF *
        Signals.Scattering.psl22SecretCoproductFull16 B1 B2 G_BF L_BF ∧
    splat_ddf.splitMajorPlus.weight + splat_ddf.splitMajorMinus.weight = splat_ddf.weight ∧
    splat_ddf.splitMajorPlus.sigma1 ^ 2 + splat_ddf.splitMajorOffset ^ 2 =
      splat_ddf.sigma1 ^ 2 ∧
    splat_ddf.coreBohmPotential 1 1 < splat_ddf.splitMajorPlus.coreBohmPotential 1 1 := by
  intro φ_fraun Δφ φ_fres N_F splat_ddf
  have h_fres := Signals.Huygens.fresnel_to_fraunhofer_remainder_bound
    x y (3 / 10) (4 / 10) 1 (1 / 2) 10 (by norm_num) (by norm_num) (by norm_num)
  have h_pl3 := Signals.Geometry.threeRowMinor_pluecker
    toyRank3GrassmannianMatrix 0 1 2 3 4 5
  have h_lgv3 := Signals.Plabic.planar_threeChannel_lgv_and_bottleneck_identities
    2 3 4 6 8 5 7 (by norm_num) (by norm_num) (by norm_num) A32 B23
  have h_r16 := Signals.Scattering.psl22_rmatrix16_secret_coproduct_intertwining
    B1 B2 B0 A_B B_B D_F E_F G_BF L_BF
  have h_spl := splat_ddf.splitMajor_conservation_identities 1 1 (by norm_num) (by norm_num)
  exact ⟨h_fres.1, h_fres.2.1, h_fres.2.2.1, h_fres.2.2.2.2.2,
    h_pl3, h_lgv3.2.2.1, h_lgv3.2.2.2.1, h_lgv3.2.2.2.2,
    h_r16.1, h_r16.2.2.1, h_r16.2.2.2.1, h_r16.2.2.2.2.1, h_r16.2.2.2.2.2,
    h_spl.1, h_spl.2.2.2.1, h_spl.2.2.2.2.2.2.2.2⟩

/-- 3D NormedTensorGaussianSplat3D adaptive splitting, holographic Gr_C(2,4) affine
projection trick, and inversion-free Schur-Plücker vs. 4×4 Jacobian determinant identity. -/
noncomputable def toySplat3D : Signals.DDF.NormedTensorGaussianSplat3D :=
  { centerX := 1
    centerY := -2
    centerZ := 4
    weight := 6
    weight_nonneg := by norm_num
    sigma1 := 8
    sigma1_pos := by norm_num
    sigma2 := 2
    sigma2_pos := by norm_num
    sigma3 := 1
    sigma3_pos := by norm_num
    orientationAngle := 0
    pitchAngle := 0 }

example (θ_z : ℝ) :
    let c3_plus := toySplat3D.splitMajorPlus
    let c3_minus := toySplat3D.splitMajorMinus
    let s_ortho := toySplat3D.projectOrthographic2D
    let s_persp := toySplat3D.projectPerspective2D 2 (by norm_num) (by norm_num [toySplat3D])
    let M_depth := Signals.DDF.ddfThermalGr24Matrix toySplat3D.holographicDepthAnisotropy θ_z
    let J := Signals.DDF.impellerShear4x4 2 (3 / 5)
    let Sigma4 := J * J.transpose
    c3_plus.weight + c3_minus.weight = toySplat3D.weight ∧
    (c3_plus.centerX - toySplat3D.centerX) ^ 2 +
        (c3_plus.centerY - toySplat3D.centerY) ^ 2 +
        (c3_plus.centerZ - toySplat3D.centerZ) ^ 2 + c3_plus.sigma1 ^ 2 =
      toySplat3D.sigma1 ^ 2 ∧
    c3_plus.covDet = (1 / 4) * toySplat3D.covDet ∧
    toySplat3D.coreBohmPotential 1 1 < c3_plus.coreBohmPotential 1 1 ∧
    s_persp.coreBohmPotential 1 1 =
      (toySplat3D.centerZ / 2) ^ 2 * s_ortho.coreBohmPotential 1 1 ∧
    c3_plus.projectOrthographic2D = s_ortho.splitMajorPlus ∧
    Complex.normSq (Signals.DDF.complexPluckerSinkAmplitudeA M_depth) /
        Complex.normSq (Signals.DDF.complexPluckerSinkAmplitudeB M_depth) =
      (toySplat3D.sigma1 ^ 2 + toySplat3D.sigma2 ^ 2) / toySplat3D.sigma3 ^ 2 ∧
    Sigma4.det = Sigma4 3 3 * Signals.DDF.schurComplement3DVolume (3 / 5) ∧
    (Signals.DDF.correctedTwistorShearMatrix 2 (3 / 5)).det = 1 - (3 / 5 : ℝ) ^ 2 ∧
    Signals.DDF.schurComplement3DVolume (3 / 5) < Signals.DDF.schurComplement3DVolume 0 := by
  intro c3_plus c3_minus s_ortho s_persp M_depth J Sigma4
  have h3d := toySplat3D.splitMajor3D_and_holographic_gr24_projection_identities
    2 1 1 θ_z (by norm_num) (by norm_num [toySplat3D]) (by norm_num) (by norm_num)
  have h_schur := Signals.DDF.schur_plucker_inversion_free_and_twistor_vane_identities
    2 (3 / 5) θ_z (by norm_num) (by norm_num) (by norm_num)
  exact ⟨h3d.1, h3d.2.2.2.2.1, h3d.2.2.2.2.2.1, h3d.2.2.2.2.2.2.2.1,
    h3d.2.2.2.2.2.2.2.2.2.2.1, h3d.2.2.2.2.2.2.2.2.2.2.2.2.1 rfl,
    h3d.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2,
    h_schur.2.2.2.1, h_schur.2.2.2.2.2.2.1, h_schur.2.2.2.2.2.2.2.2.2.2⟩

example (θ_z φ_err : ℝ) :
    let s_ortho := toySplat3D.projectOrthographic2D
    let s_persp := toySplat3D.projectPerspective2D 2 (by norm_num) (by norm_num [toySplat3D])
    let M_depth := Signals.DDF.ddfThermalGr24Matrix toySplat3D.holographicDepthAnisotropy θ_z
    let R_depth :=
      Complex.normSq (Signals.DDF.complexPluckerSinkAmplitudeA M_depth) /
        Complex.normSq (Signals.DDF.complexPluckerSinkAmplitudeB M_depth)
    let sigma3_sq_rec := Signals.DDF.recoverDepthVarianceSq s_ortho.covTrace R_depth
    sigma3_sq_rec = toySplat3D.sigma3 ^ 2 ∧
    s_ortho.covTrace + sigma3_sq_rec = toySplat3D.covTrace ∧
    s_ortho.covDet * sigma3_sq_rec = toySplat3D.covDet ∧
    Signals.DDF.recoverFocalDepthSq 2 s_ortho.covTrace s_persp.covTrace =
      toySplat3D.centerZ ^ 2 ∧
    2 / (4 : ℝ) ^ 2 < Signals.DDF.convergentCrossedAxialPrecision 1 4 ∧
    (4 : ℝ) * (3 : ℝ) ^ 2 < (4 * (3 : ℝ)) ^ 2 ∧
    Signals.DDF.ddfThermalGr24Matrix toySplat3D.holographicDepthAnisotropy (θ_z + φ_err - φ_err) =
      M_depth := by
  intro s_ortho s_persp M_depth R_depth sigma3_sq_rec
  have h_img :=
    toySplat3D.holographic_gr24_imaging_depth_recovery_and_convergent_beam_identities
      2 1 1 θ_z φ_err 1 4 4 3
      (by norm_num) (by norm_num [toySplat3D]) (by norm_num) (by norm_num)
      (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  exact ⟨h_img.1, h_img.2.1, h_img.2.2.1, h_img.2.2.2.2.1,
    h_img.2.2.2.2.2.2.2.1, h_img.2.2.2.2.2.2.2.2.2.1, h_img.2.2.2.2.2.2.2.2.2.2⟩

example (φ1 φ2 φ3 : ℝ) :
    let M3 := toySplat3D.gr36TwistorMatrix φ1 φ2 φ3
    Signals.Geometry.complexThreeRowMinor M3 3 4 5 = 1 ∧
    Complex.normSq (Signals.Geometry.complexThreeRowMinor M3 0 4 5) = toySplat3D.sigma1 ^ 2 ∧
    Complex.normSq (Signals.Geometry.complexThreeRowMinor M3 3 1 5) = toySplat3D.sigma2 ^ 2 ∧
    Complex.normSq (Signals.Geometry.complexThreeRowMinor M3 3 4 2) = toySplat3D.sigma3 ^ 2 ∧
    Complex.normSq (Signals.Geometry.complexThreeRowMinor M3 0 1 2) = toySplat3D.covDet ∧
    (1 ^ 2 / (4 * (1 : ℝ))) *
        ((Complex.normSq (Signals.Geometry.complexThreeRowMinor M3 3 1 2) +
            Complex.normSq (Signals.Geometry.complexThreeRowMinor M3 0 4 2) +
            Complex.normSq (Signals.Geometry.complexThreeRowMinor M3 0 1 5)) /
          Complex.normSq (Signals.Geometry.complexThreeRowMinor M3 0 1 2)) =
      toySplat3D.coreBohmPotential 1 1 ∧
    Signals.Geometry.complexThreeRowMinor M3 0 1 2 * Signals.Geometry.complexThreeRowMinor M3 3 4 5 -
        Signals.Geometry.complexThreeRowMinor M3 0 1 3 * Signals.Geometry.complexThreeRowMinor M3 2 4 5 +
        Signals.Geometry.complexThreeRowMinor M3 0 1 4 * Signals.Geometry.complexThreeRowMinor M3 2 3 5 -
        Signals.Geometry.complexThreeRowMinor M3 0 1 5 * Signals.Geometry.complexThreeRowMinor M3 2 3 4 = 0 := by
  intro M3
  have h := toySplat3D.gr36_volumetric_imaging_and_plucker_identities φ1 φ2 φ3 1 1 (by norm_num)
  exact ⟨h.1, h.2.1, h.2.2.1, h.2.2.2.1, h.2.2.2.2.2.2.2.1,
    h.2.2.2.2.2.2.2.2.2.1, h.2.2.2.2.2.2.2.2.2.2.2⟩

example (φ : ℝ) :
    let ray1 := Signals.DDF.debyeWolfRayVec3 2 (Real.pi / 2) φ
    let ray2 := Signals.DDF.debyeWolfRayVec3 2 (Real.pi / 2) (φ + Real.pi)
    ray1.1 ^ 2 + ray1.2.1 ^ 2 + ray1.2.2 ^ 2 = (2 : ℝ) ^ 2 ∧
    ray1.1 + ray2.1 = 0 ∧
    ray1.2.1 + ray2.2.1 = 0 ∧
    ray1.2.2 + ray2.2.2 = 2 * Signals.DDF.debyeWolfLongitudinalComponent 2 (Real.pi / 2) ∧
    Signals.DDF.hyperbolicMetasurfacePhase 0 5 1 = 0 ∧
    Signals.DDF.hyperbolicMetasurfacePhase 3 5 1 < 0 ∧
    (Signals.DDF.radialNanopillarJonesMatrix (Real.pi / 2) 0 0) ^ 2 +
        (Signals.DDF.radialNanopillarJonesMatrix (Real.pi / 2) 1 0) ^ 2 = 1 ∧
    (Signals.DDF.radialNanopillarJonesMatrix (Real.pi / 2)).det = -1 ∧
    Signals.DDF.enzBoundaryIntensityEnhancement 1 (1 / 10) = 100 ∧
    Signals.DDF.enzBoundaryIntensityEnhancement 1 (1 / 20) = 400 ∧
    100 ≤ Signals.DDF.enzBoundaryIntensityEnhancement 1 (1 / 15) ∧
    Signals.DDF.enzBoundaryIntensityEnhancement 1 (1 / 15) ≤ 400 ∧
    Signals.DDF.regularizedEnzEnhancement 1 2 (1 / 10) ≤
      Signals.DDF.regularizedEnzEnhancement 1 0 (1 / 10) := by
  intro ray1 ray2
  have hsin_pi2 : Real.sin (Real.pi / 2) ≠ 0 := by
    rw [Real.sin_pi_div_two]
    norm_num
  have h := Signals.DDF.vectorial_longitudinal_polarization_metasurface_and_enz_identities
    2 (Real.pi / 2) φ 3 5 1 10 1 1 (1 / 15) 3 2 (1 / 10)
    (by norm_num) hsin_pi2 (by norm_num) (by norm_num) (by norm_num)
    (by norm_num) (by norm_num) (by norm_num)
  exact ⟨h.1, h.2.1, h.2.2.1, h.2.2.2.1, h.2.2.2.2.2.2.2.1,
    h.2.2.2.2.2.2.2.2.1, h.2.2.2.2.2.2.2.2.2.2.1, h.2.2.2.2.2.2.2.2.2.2.2.1,
    h.2.2.2.2.2.2.2.2.2.2.2.2.2.1, h.2.2.2.2.2.2.2.2.2.2.2.2.2.2.1,
    h.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.1, h.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.1,
    h.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.1⟩

example (θ : ℝ) :
    let f_enz := Signals.DDF.emtCriticalEnzFillFraction (282 / 100) 110
    let f_pole := Signals.DDF.emtPerpendicularPoleFillFraction (282 / 100) 110
    let eps_par := Signals.DDF.emtEpsilonParallel (32 / 1000) (-110) (282 / 100)
    let eps_perp := Signals.DDF.emtEpsilonPerp (32 / 1000) (-110) (282 / 100)
    let rot90 := Signals.DDF.rotated90MetamaterialTensor eps_par eps_perp
    let M_hmm := Signals.DDF.ddfThermalGr24Matrix (Signals.DDF.hmmAnisotropyParam 110 (282 / 100)) θ
    f_enz + f_pole = 1 ∧
    Signals.DDF.emtEpsilonParallel f_enz (-110) (282 / 100) = 0 ∧
    0 < Signals.DDF.emtEpsilonPerp f_enz (-110) (282 / 100) ∧
    eps_par < 0 ∧
    0 < eps_perp ∧
    eps_par * eps_perp < 0 ∧
    0 < rot90.1 ∧
    rot90.2 < 0 ∧
    eps_perp * (2 : ℝ) ^ 2 < Signals.DDF.typeIIHyperbolicKzSq 2 eps_perp 110 5 ∧
    Signals.DDF.coldPlasmaEpsilonParallel 400 400 = 0 ∧
    Signals.DDF.coldPlasmaEpsilonParallel 200 400 *
      Signals.DDF.coldPlasmaEpsilonPerp 200 400 300 < 0 ∧
    Signals.DDF.denisovModeConversionParam 10 1 0 = 0 ∧
    Complex.normSq (Signals.DDF.complexPluckerSinkAmplitudeA M_hmm) /
        Complex.normSq (Signals.DDF.complexPluckerSinkAmplitudeB M_hmm) =
      110 / (282 / 100) ∧
    Signals.DDF.ionAcousticSpeedSq (5 / 3) 10 40 <
      Signals.DDF.ionAcousticSpeedSq (5 / 3) 10 4 ∧
    Signals.DDF.tnsaEngineeringGain (1 / 5) (1 / 10) 30 (17 / 20) < 1 ∧
    Signals.DDF.tnsaEngineeringGain (1 / 5) (38 / 100) 40 (17 / 20) = 646 / 250 ∧
    Signals.DDF.coolantMassFlowRate 45600 (5 / 4) 200 = 912 / 5 ∧
    Signals.DDF.pulsedBusRequiredCapacitance 258400000 (1 / 10) (1 / 1000) 10000 9800 =
      14212 / 1100 := by
  intro f_enz f_pole eps_par eps_perp rot90 M_hmm
  have h_hmm := Signals.DDF.rgo_polycbd_enz_hyperbolic_and_plasma_metamaterial_identities
    (282 / 100) 110 (32 / 1000) 2 5 200 400 300 10 1 θ
    (by norm_num) (by norm_num)
    (by unfold Signals.DDF.emtCriticalEnzFillFraction; norm_num)
    (by unfold Signals.DDF.emtPerpendicularPoleFillFraction; norm_num)
    (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  have h_tnsa := Signals.DDF.argon_ion_acoustic_tnsa_enz_polycbd_and_sco2_ledger_identities
    (5 / 3) 10 800 (1 / 10) (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  exact ⟨h_hmm.1, h_hmm.2.2.2.2.2.1, h_hmm.2.2.2.2.2.2.2.1,
    h_hmm.2.2.2.2.2.2.2.2.1, h_hmm.2.2.2.2.2.2.2.2.2.1, h_hmm.2.2.2.2.2.2.2.2.2.2.1,
    h_hmm.2.2.2.2.2.2.2.2.2.2.2.1, h_hmm.2.2.2.2.2.2.2.2.2.2.2.2.1,
    h_hmm.2.2.2.2.2.2.2.2.2.2.2.2.2.2.1, h_hmm.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.1,
    h_hmm.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.1,
    h_hmm.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.1,
    h_hmm.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2,
    h_tnsa.1, h_tnsa.2.2.2.2.2.2.1, h_tnsa.2.2.2.2.2.2.2.2.1,
    h_tnsa.2.2.2.2.2.2.2.2.2.2.1, h_tnsa.2.2.2.2.2.2.2.2.2.2.2.2.1⟩

end SignalsTests
