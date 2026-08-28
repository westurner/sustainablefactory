import Mathlib.Tactic
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
      meanALaw := by simp [Fin.sum_univ_succ]
      meanBLaw := by simp [Fin.sum_univ_succ]
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

end SignalsTests
