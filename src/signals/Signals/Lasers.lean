import Mathlib.Data.Real.Basic
import Mathlib.Tactic
import Signals.DirectionalBroadbandAntenna
import Signals.Units

namespace Signals.Lasers

open Signals.Antennas
open Signals.Propagation
open Signals.Units

/-! # Laser source and process parameter contracts

This module separates laser-source families from process tasks. Its records keep
wavelength, power, pulse, fluence, scan, and shock quantities explicit. They are
calibration contracts; they do not infer a material transformation from a
nominal laser label.
-/

/-- Source families represented by the laser parameter model. -/
inductive LaserKind
  | semiconductorDiode
  | fiber
  | carbonDioxide
  | ndYag
  | excimer
  | ultrafast
  | shockDrive
  | laserCompressionShock
  | integratedCarbon
  | lightSlinger
  | nanophotonicParametricOscillator
  | hollowCoreSoliton
  | proposedProcaHolographic
  deriving DecidableEq, Repr

/-- Emission regimes used by the parameter records. -/
inductive LaserMode
  | continuousWave
  | nanosecondPulse
  | picosecondPulse
  | femtosecondPulse
  | pulsedShock
  deriving DecidableEq, Repr

/-- Evidence state for a laser profile or a proposed source family. -/
inductive LaserEvidenceStatus
  | demonstratedProcess
  | calibrationRequired
  | modeledOnly
  | unsupportedProposal
  deriving DecidableEq, Repr

/-- Optical amplification mechanisms represented by the parameter model. -/
inductive OpticalAmplificationKind
  | none
  | secondHarmonicResonance
  | fourWaveMixing
  | erbiumDopedFiber
  | semiconductorOpticalAmplifier
  deriving DecidableEq, Repr

/-- Reflector architectures used to provide a calibrated optical feedback path. -/
inductive BraggReflectorKind
  | distributedBraggReflector
  | multilayerBraggMirror
  deriving DecidableEq, Repr

/-- The finite source-family inventory exposed by the module. -/
def laserKinds : List LaserKind :=
  [LaserKind.semiconductorDiode, LaserKind.fiber,
    LaserKind.carbonDioxide, LaserKind.ndYag, LaserKind.excimer,
    LaserKind.ultrafast, LaserKind.shockDrive,
    LaserKind.laserCompressionShock, LaserKind.integratedCarbon,
    LaserKind.lightSlinger, LaserKind.nanophotonicParametricOscillator,
    LaserKind.hollowCoreSoliton,
    LaserKind.proposedProcaHolographic]

/-- A conservative default evidence boundary for a source family. -/
def LaserKind.defaultEvidence : LaserKind → LaserEvidenceStatus
  | LaserKind.proposedProcaHolographic => LaserEvidenceStatus.unsupportedProposal
  | LaserKind.lightSlinger => LaserEvidenceStatus.modeledOnly
  | LaserKind.nanophotonicParametricOscillator =>
      LaserEvidenceStatus.demonstratedProcess
  | LaserKind.hollowCoreSoliton => LaserEvidenceStatus.demonstratedProcess
  | _ => LaserEvidenceStatus.calibrationRequired

/-- Nominal telecom signal wavelength used by the integrated-carbon chat model. -/
noncomputable def telecom1550Nm : Length :=
  { meters := 1550 * 10 ^ (-9 : ℤ) }

lemma telecom1550Nm_positive : 0 < telecom1550Nm.meters := by
  norm_num [telecom1550Nm, zpow_neg]

/-! ## Integrated carbon laser platforms

The chat corpus describes N-LIG waveguides, carbon-nanotube structures, and
rGO-vitrimer metasurfaces as proposed integrated components around a nominal
1550 nm signal. These labels are kept separate from demonstrated laser-source
physics; the profile carries an explicit evidence status and measured/calibrated
power fields.
-/

/-- Carbon components that may be integrated with a laser or optical cavity. -/
inductive CarbonIntegration
  | nLigWaveguide
  | carbonNanotubeWaveguide
  | rgoVitrimerMetasurface
  | carbonSaturableAbsorber
  deriving DecidableEq, Repr

/-- Soliton applications represented by the waveguide model. -/
inductive SolitonApplication
  | hollowCoreAttosecond
  | qpuBus
  | frequencyComb
  | waveguideTransport
  deriving DecidableEq, Repr

/-- Platforms used by a nanophotonic parametric oscillator record. -/
inductive ParametricOscillatorPlatform
  | thinFilmLithiumNiobate
  | proposedCarbonComposite
  | other
  deriving DecidableEq, Repr

/-- Spectral regions used by a soliton or its generated dispersive wave. -/
inductive SpectralBand
  | deepUltraviolet
  | nearInfrared
  | extremeUltraviolet
  | softXray
  | terahertz
  deriving DecidableEq, Repr

/-- Photon energy represented in electron-volts. -/
structure PhotonEnergy where
  electronVolts : ℝ
  electronVolts_pos : 0 < electronVolts

/-- Strong-field ionization evidence for an argon target. -/
structure ArgonIonizationObservation where
  pulseDuration : Duration
  pulseDuration_pos : 0 < pulseDuration.seconds
  irradiance : Irradiance
  irradiance_nonnegative : 0 ≤ irradiance.wattsPerSquareMeter
  photonEnergy : PhotonEnergy
  observedChargeState : ℕ
  observedChargeState_pos : 0 < observedChargeState
  ionizationObserved : Prop
  ionizationObserved_hypothesis : ionizationObserved
  evidenceStatus : LaserEvidenceStatus

/-- Calibrated soliton mechanics for a waveguide or QPU bus. -/
structure SolitonWaveguideParameters where
  application : SolitonApplication
  mediumLabel : String
  carrierWavelength : Length
  carrierWavelength_pos : 0 < carrierWavelength.meters
  coreRadius : Length
  coreRadius_pos : 0 < coreRadius.meters
  gasPressure : Pressure
  gasPressure_nonnegative : 0 ≤ gasPressure.pascals
  propagationDistance : Length
  propagationDistance_pos : 0 < propagationDistance.meters
  pulseDuration : Duration
  pulseDuration_pos : 0 < pulseDuration.seconds
  peakPower : Power
  peakPower_pos : 0 < peakPower.watts
  groupSpeed : Speed
  groupSpeed_pos : 0 < groupSpeed.metersPerSecond
  groupSpeed_causal : groupSpeed.metersPerSecond ≤ vacuumSpeedOfLight
  modeCount : ℕ
  modeCount_pos : 0 < modeCount
  dispersionParameter : ℝ
  dispersionParameter_anomalous : dispersionParameter < 0
  nonlinearParameter : ℝ
  nonlinearParameter_pos : 0 < nonlinearParameter
  solitonOrderSquared : ℝ
  solitonOrderSquared_law :
    solitonOrderSquared =
      nonlinearParameter * peakPower.watts * pulseDuration.seconds ^ 2 /
        |dispersionParameter|
  solitonOrderSquared_pos : 0 < solitonOrderSquared
  solitonOrderSquared_supercritical : 1 < solitonOrderSquared
  modeMatched : Prop
  modeMatched_hypothesis : modeMatched
  pressureProfileControlled : Prop
  pressureProfileControlled_hypothesis : pressureProfileControlled
  dispersionNonlinearityBalanced : Prop
  dispersionNonlinearityBalanced_hypothesis : dispersionNonlinearityBalanced
  shapePreservationObserved : Prop
  shapePreservationObserved_hypothesis : shapePreservationObserved
  evidenceStatus : LaserEvidenceStatus

/-- The measured or simulated soliton-order control law. -/
lemma SolitonWaveguideParameters.soliton_order_squared_holds
    (parameters : SolitonWaveguideParameters) :
    parameters.solitonOrderSquared =
      parameters.nonlinearParameter * parameters.peakPower.watts *
          parameters.pulseDuration.seconds ^ 2 /
        |parameters.dispersionParameter| :=
  parameters.solitonOrderSquared_law

/-- The contract is in the compression regime when its supplied order exceeds one. -/
lemma SolitonWaveguideParameters.soliton_order_supercritical
    (parameters : SolitonWaveguideParameters) :
    1 < parameters.solitonOrderSquared :=
  parameters.solitonOrderSquared_supercritical

/-- Quantitative contract for a nanophotonic parametric frequency-comb source. -/
structure NanophotonicParametricOscillatorParameters where
  platform : ParametricOscillatorPlatform
  pumpWavelength : Length
  pumpWavelength_pos : 0 < pumpWavelength.meters
  pumpRepetitionRate : Frequency
  pumpRepetitionRate_pos : 0 < pumpRepetitionRate.hz
  pumpPulseEnergy : Energy
  pumpPulseEnergy_pos : 0 < pumpPulseEnergy.joules
  oscillationThresholdEnergy : Energy
  oscillationThresholdEnergy_pos : 0 < oscillationThresholdEnergy.joules
  threshold_le_pump : oscillationThresholdEnergy.joules ≤ pumpPulseEnergy.joules
  spectralSpanOctaves : ℝ
  spectralSpanOctaves_pos : 0 < spectralSpanOctaves
  dispersionEngineered : Prop
  dispersionEngineered_hypothesis : dispersionEngineered
  coherentCombObserved : Prop
  coherentCombObserved_hypothesis : coherentCombObserved
  phaseLockedToPump : Prop
  phaseLockedToPump_hypothesis : phaseLockedToPump
  evidenceStatus : LaserEvidenceStatus

/-- The pump energy is above the supplied oscillation threshold. -/
lemma NanophotonicParametricOscillatorParameters.pump_above_threshold
    (parameters : NanophotonicParametricOscillatorParameters) :
    parameters.oscillationThresholdEnergy.joules ≤
      parameters.pumpPulseEnergy.joules :=
  parameters.threshold_le_pump

/-- Optical-to-microwave control data for a superconducting-qubit transducer. -/
structure OpticalSuperconductingQubitControlParameters where
  transducerPlatform : String
  opticalCarrierFrequency : Frequency
  opticalCarrierFrequency_pos : 0 < opticalCarrierFrequency.hz
  microwaveQubitFrequency : Frequency
  microwaveQubitFrequency_pos : 0 < microwaveQubitFrequency.hz
  opticalPumpPower : Power
  opticalPumpPower_nonnegative : 0 ≤ opticalPumpPower.watts
  conversionEfficiency : BoundedFactor
  addedNoisePhotons : ℝ
  addedNoisePhotons_nonnegative : 0 ≤ addedNoisePhotons
  addedNoiseBudget : ℝ
  addedNoiseBudget_nonnegative : 0 ≤ addedNoiseBudget
  addedNoiseWithinBudget : addedNoisePhotons ≤ addedNoiseBudget
  microwaveLinkLossDb : ℝ
  microwaveLinkLossDb_nonnegative : 0 ≤ microwaveLinkLossDb
  coherentOpticalControlObserved : Prop
  coherentOpticalControlObserved_hypothesis : coherentOpticalControlObserved
  rabiOscillationsObserved : Prop
  rabiOscillationsObserved_hypothesis : rabiOscillationsObserved
  cryogenicOperation : Prop
  cryogenicOperation_hypothesis : cryogenicOperation
  evidenceStatus : LaserEvidenceStatus

/-- A transducer's conversion efficiency remains in its declared range. -/
lemma OpticalSuperconductingQubitControlParameters.conversion_efficiency_nonnegative
    (parameters : OpticalSuperconductingQubitControlParameters) :
    0 ≤ parameters.conversionEfficiency.value :=
  parameters.conversionEfficiency.nonnegative

/-- Chiral microwave-interconnect data for remote entanglement. -/
structure ChiralQuantumInterconnectParameters where
  moduleCount : ℕ
  moduleCount_pos : 0 < moduleCount
  waveguideFrequency : Frequency
  waveguideFrequency_pos : 0 < waveguideFrequency.hz
  qubitSpacing : Length
  qubitSpacing_pos : 0 < qubitSpacing.meters
  interModuleDistance : Length
  interModuleDistance_pos : 0 < interModuleDistance.meters
  propagationTransmission : BoundedFactor
  wStateQubitCount : ℕ
  wStateQubitCount_law : wStateQubitCount = 4
  wStateFidelity : BoundedFactor
  directionalEmissionObserved : Prop
  directionalEmissionObserved_hypothesis : directionalEmissionObserved
  directionalAbsorptionObserved : Prop
  directionalAbsorptionObserved_hypothesis : directionalAbsorptionObserved
  pulseOptimizationCalibrated : Prop
  pulseOptimizationCalibrated_hypothesis : pulseOptimizationCalibrated
  remoteEntanglementObserved : Prop
  remoteEntanglementObserved_hypothesis : remoteEntanglementObserved
  evidenceStatus : LaserEvidenceStatus

/-- The interconnect records a four-qubit W-state target, not a generic fidelity claim. -/
lemma ChiralQuantumInterconnectParameters.w_state_qubit_count
    (parameters : ChiralQuantumInterconnectParameters) :
    parameters.wStateQubitCount = 4 :=
  parameters.wStateQubitCount_law

/-- Dual-beam femtosecond-processing data for localized waveguide writing. -/
structure DualBeamFsProcessingParameters where
  pulseDuration : Duration
  pulseDuration_pos : 0 < pulseDuration.seconds
  pulseEnergy : Energy
  pulseEnergy_pos : 0 < pulseEnergy.joules
  beamAngleRadians : ℝ
  processingDepth : Length
  processingDepth_pos : 0 < processingDepth.meters
  dualBeamCoherenceObserved : Prop
  dualBeamCoherenceObserved_hypothesis : dualBeamCoherenceObserved
  aberrationReduced : Prop
  aberrationReduced_hypothesis : aberrationReduced
  selfFocusingSuppressed : Prop
  selfFocusingSuppressed_hypothesis : selfFocusingSuppressed
  filamentationSuppressed : Prop
  filamentationSuppressed_hypothesis : filamentationSuppressed
  depthDependenceReduced : Prop
  depthDependenceReduced_hypothesis : depthDependenceReduced
  interfaceRoughnessReduced : Prop
  interfaceRoughnessReduced_hypothesis : interfaceRoughnessReduced
  waveguideWritten : Prop
  waveguideWritten_hypothesis : waveguideWritten
  propagationLossDbPerCentimeter : ℝ
  propagationLossDbPerCentimeter_nonnegative :
    0 ≤ propagationLossDbPerCentimeter
  evidenceStatus : LaserEvidenceStatus

/-- Field-resolved attosecond soliton and dispersive-wave parameters. -/
structure AttosecondSolitonParameters where
  waveguide : SolitonWaveguideParameters
  pulseDuration : Duration
  pulseDuration_pos : 0 < pulseDuration.seconds
  fieldSquaredFwhm : Duration
  fieldSquaredFwhm_pos : 0 < fieldSquaredFwhm.seconds
  dispersiveWaveBand : SpectralBand
  dispersiveWaveGenerated : Prop
  dispersiveWaveGenerated_hypothesis : dispersiveWaveGenerated
  nonlinearPhotoconductiveSampling : Prop
  nonlinearPhotoconductiveSampling_hypothesis :
    nonlinearPhotoconductiveSampling
  argonIonization : Option ArgonIonizationObservation
  evidenceStatus : LaserEvidenceStatus

/-- Gaseous medium used by a plasma-lens contract. -/
inductive PlasmaLensGas
  | hydrogen
  | other
  deriving DecidableEq, Repr

/-- Plasma-lens parameters for broadband attosecond focusing. -/
structure PlasmaLensParameters where
  gas : PlasmaLensGas
  photonEnergy : PhotonEnergy
  inputPulseDuration : Duration
  inputPulseDuration_pos : 0 < inputPulseDuration.seconds
  outputPulseDuration : Duration
  outputPulseDuration_pos : 0 < outputPulseDuration.seconds
  transmission : BoundedFactor
  pulseStretchingNegligible : Prop
  pulseStretchingNegligible_hypothesis : pulseStretchingNegligible
  temporalCompressionPossible : Prop
  temporalCompressionPossible_hypothesis : temporalCompressionPossible
  harmonicSeparationSupported : Prop
  harmonicSeparationSupported_hypothesis : harmonicSeparationSupported
  evidenceStatus : LaserEvidenceStatus

/-- The plasma-lens transmission remains in the declared bounded range. -/
lemma PlasmaLensParameters.transmission_nonnegative
    (parameters : PlasmaLensParameters) :
    0 ≤ parameters.transmission.value :=
  parameters.transmission.nonnegative

/-- Color-center families represented by nanodiamond product records. -/
inductive NanodiamondColorCenter
  | none
  | nitrogenVacancy
  | siliconVacancy
  | other
  deriving DecidableEq, Repr

/-- Formation routes represented by the nanodiamond product model. -/
inductive NanodiamondFormationMethod
  | electronBeamAdamantane
  | highPressureTemperature
  | directLaserWritingBiomass
  | irradiationAndAnneal
  deriving DecidableEq, Repr

/-- Product classes for carbon nanodiamond applications. -/
inductive CarbonNanodiamondProductKind
  | structuralNanodiamond
  | quantumGradeNanodiamond
  | positionedColorCenterNanostructure
  deriving DecidableEq, Repr

/-- Shared product characterization for a carbon nanodiamond batch. -/
structure CarbonNanodiamondProductParameters where
  productKind : CarbonNanodiamondProductKind
  formationMethod : NanodiamondFormationMethod
  precursorLabel : String
  particleDiameter : Length
  particleDiameter_pos : 0 < particleDiameter.meters
  colorCenter : NanodiamondColorCenter
  colorCenterCount : ℕ
  coherenceTime : Option Duration
  evidenceStatus : LaserEvidenceStatus

/-- Process-specific electron-beam nanodiamond characterization. -/
structure ElectronBeamNanodiamondParameters extends
    CarbonNanodiamondProductParameters where
  electronBeamEnergyKeV : ℝ
  electronBeamEnergyKeV_pos : 0 < electronBeamEnergyKeV
  temperatureMinimum : Temperature
  temperatureMinimum_nonnegative : 0 ≤ temperatureMinimum.kelvin
  temperatureMaximum : Temperature
  temperatureMaximum_nonnegative : 0 ≤ temperatureMaximum.kelvin
  temperatureRangeLaw : temperatureMinimum.kelvin ≤ temperatureMaximum.kelvin
  vacuumProcess : Prop
  vacuumProcess_hypothesis : vacuumProcess
  cubicStructureObserved : Prop
  cubicStructureObserved_hypothesis : cubicStructureObserved
  hydrogenEvolutionObserved : Prop
  hydrogenEvolutionObserved_hypothesis : hydrogenEvolutionObserved

/-- Process-specific quantum-grade nanodiamond characterization. -/
structure QuantumGradeNanodiamondParameters extends
    CarbonNanodiamondProductParameters where
  synthesisTemperature : Temperature
  synthesisTemperature_nonnegative : 0 ≤ synthesisTemperature.kelvin
  synthesisPressure : Pressure
  synthesisPressure_nonnegative : 0 ≤ synthesisPressure.pascals
  luminescent : Prop
  luminescent_hypothesis : luminescent
  chargeStabilityImproved : Prop
  chargeStabilityImproved_hypothesis : chargeStabilityImproved

/-- Process-specific color-center positioning characterization. -/
structure ColorCenterPositioningParameters extends
    CarbonNanodiamondProductParameters where
  hostPillarDiameter : Length
  hostPillarDiameter_pos : 0 < hostPillarDiameter.meters
  depthPositionAccuracy : Length
  depthPositionAccuracy_pos : 0 < depthPositionAccuracy.meters
  lateralPositionAccuracy : Length
  lateralPositionAccuracy_pos : 0 < lateralPositionAccuracy.meters
  singleCenterYieldImproved : Prop
  singleCenterYieldImproved_hypothesis : singleCenterYieldImproved

/-- A product record with the process-specific evidence boundary preserved. -/
inductive CarbonNanodiamondProduct
  | electronBeam (parameters : ElectronBeamNanodiamondParameters)
  | quantumGrade (parameters : QuantumGradeNanodiamondParameters)
  | positionedColorCenter (parameters : ColorCenterPositioningParameters)

/-- Parameters for a distributed or multilayer Bragg reflector. -/
structure BraggReflectorParameters where
  kind : BraggReflectorKind
  centerWavelength : Length
  centerWavelength_pos : 0 < centerWavelength.meters
  layerCount : ℕ
  layerCount_pos : 0 < layerCount
  highIndex : ℝ
  highIndex_nonnegative : 0 ≤ highIndex
  lowIndex : ℝ
  lowIndex_nonnegative : 0 ≤ lowIndex
  indexContrast : ℝ
  indexContrast_nonnegative : 0 ≤ indexContrast
  indexContrastLaw : indexContrast = highIndex - lowIndex
  reflectivity : ℝ
  reflectivity_nonnegative : 0 ≤ reflectivity
  reflectivity_le_one : reflectivity ≤ 1
  evidenceStatus : LaserEvidenceStatus

/-- Parameters for an optical-amplification stage or resonant repeater. -/
structure OpticalAmplificationParameters where
  kind : OpticalAmplificationKind
  pumpWavelength : Length
  pumpWavelength_pos : 0 < pumpWavelength.meters
  pumpPower : Power
  pumpPower_nonnegative : 0 ≤ pumpPower.watts
  gainDb : ℝ
  gainDb_nonnegative : 0 ≤ gainDb
  phaseMatchingCalibrated : Prop
  phaseMatchingCalibrated_hypothesis : phaseMatchingCalibrated
  reflector : Option BraggReflectorParameters
  evidenceStatus : LaserEvidenceStatus

/-- Process labels for pulsed shock and laser-peening work. -/
inductive ShockProcess
  | genericPulsedShock
  | laserCompressionShock
  | laserPeening
  deriving DecidableEq, Repr

/-- Laser-matter interaction classes kept distinct from laser source families. -/
inductive LaserInteractionKind
  | surfacePlasmonPolariton
  | coherentSynchrotronRadiation
  | freeElectronSurfacePlasmonAmplification
  | cavityElectrodynamics
  | phononPolariton
  | lightSlingerWaveguide
  | solitonWaveguide
  | attosecondSoliton
  | argonStrongFieldIonization
  | plasmaLens
  | solitonBus
  | nanophotonicParametricOscillator
  | opticalSuperconductingQubitControl
  | chiralQuantumInterconnect
  | dualBeamFemtosecondProcessing
  deriving DecidableEq, Repr

/-- Radiation channels that may coexist in a surface-mode model. -/
inductive SurfaceEmissionChannel
  | surfacePlasmonMode
  | coherentSynchrotron
  | vavilovCherenkov
  deriving DecidableEq, Repr

/-- Coupling regime for a material mode and a cavity mode. -/
inductive CavityRegime
  | classicalCoupledMode
  | strongCoupling
  | cavityQED
  deriving DecidableEq, Repr

/-- Parameters for the modeled near-critical microtube SPP/CSR mechanism. -/
structure SurfacePlasmonCSRParameters where
  driveWavelength : Length
  driveWavelength_pos : 0 < driveWavelength.meters
  microtubeRadius : Length
  microtubeRadius_pos : 0 < microtubeRadius.meters
  electronNumberDensity : ℝ
  electronNumberDensity_nonnegative : 0 ≤ electronNumberDensity
  emissionChannel : SurfaceEmissionChannel
  emissionAngleRadians : ℝ
  harmonicOrder : ℕ
  harmonicOrder_pos : 0 < harmonicOrder
  coherenceEnhancementFactor : ℝ
  coherenceEnhancementFactor_nonnegative : 0 ≤ coherenceEnhancementFactor
  highContrastLaserControl : Prop
  highContrastLaserControl_hypothesis : highContrastLaserControl
  microtubeAlignmentCalibrated : Prop
  microtubeAlignmentCalibrated_hypothesis : microtubeAlignmentCalibrated
  evidenceStatus : LaserEvidenceStatus

/-- Parameters for free-electron pumping of a surface plasmon mode. -/
structure FreeElectronSPPAmplificationParameters where
  driveFrequency : Frequency
  driveFrequency_pos : 0 < driveFrequency.hz
  inputEnergy : Energy
  inputEnergy_nonnegative : 0 ≤ inputEnergy.joules
  emissionFrequency : Frequency
  emissionFrequency_pos : 0 < emissionFrequency.hz
  gainFactor : ℝ
  gainFactor_nonnegative : 0 ≤ gainFactor
  emitterMaterial : String
  electronPumpCalibrated : Prop
  electronPumpCalibrated_hypothesis : electronPumpCalibrated
  evidenceStatus : LaserEvidenceStatus

/-- Parameters for cavity electrodynamics and material-mode coupling. -/
structure CavityElectrodynamicsParameters where
  cavityModeFrequency : Frequency
  cavityModeFrequency_pos : 0 < cavityModeFrequency.hz
  matterModeFrequency : Frequency
  matterModeFrequency_pos : 0 < matterModeFrequency.hz
  couplingRate : Frequency
  couplingRate_pos : 0 < couplingRate.hz
  cavityLinewidth : Frequency
  cavityLinewidth_pos : 0 < cavityLinewidth.hz
  matterLinewidth : Frequency
  matterLinewidth_pos : 0 < matterLinewidth.hz
  cooperativity : ℝ
  cooperativity_nonnegative : 0 ≤ cooperativity
  regime : CavityRegime
  avoidedCrossingObserved : Prop
  avoidedCrossingObserved_hypothesis : avoidedCrossingObserved
  evidenceStatus : LaserEvidenceStatus

/-- Parameters for photon-phonon polariton confinement and propagation. -/
structure PhononPolaritonParameters where
  opticalFrequency : Frequency
  opticalFrequency_pos : 0 < opticalFrequency.hz
  phononFrequency : Frequency
  phononFrequency_pos : 0 < phononFrequency.hz
  confinementLength : Length
  confinementLength_pos : 0 < confinementLength.meters
  anisotropyFactor : ℝ
  anisotropyFactor_nonnegative : 0 ≤ anisotropyFactor
  evidenceStatus : LaserEvidenceStatus

/-! ## LightSlinger volume-current waveguide model

The existing `DirectionalBroadbandAntenna` provides the finite dielectric track,
volume-distributed polarization current, phase-pattern speed, group speed, and
information speed. LightSlinger adds the waveguide and longitudinal-mode
bookkeeping without treating a superluminal phase pattern as superluminal
matter, energy, or information transport.
-/

/-- Parameters for a conditional LightSlinger waveguide profile. -/
structure LightSlingerParameters where
  antenna : DirectionalBroadbandAntenna
  carrierWavelength : Length
  carrierWavelength_pos : 0 < carrierWavelength.meters
  waveguideLength : Length
  waveguideLength_pos : 0 < waveguideLength.meters
  polarizationMode : ResonatorMode
  polarizationMode_longitudinal :
    polarizationMode = ResonatorMode.longitudinal
  phasePatternSuperluminal_hypothesis :
    antenna.phasePatternSuperluminal
  waveguideEmissionCalibrated : Prop
  waveguideEmissionCalibrated_hypothesis : waveguideEmissionCalibrated
  evidenceStatus : LaserEvidenceStatus

/-- The LightSlinger profile exposes the superluminal phase-pattern predicate. -/
def LightSlingerParameters.phasePatternSuperluminal
    (parameters : LightSlingerParameters) : Prop :=
  parameters.antenna.phasePatternSuperluminal

/-- The LightSlinger group speed remains within the supplied causal bound. -/
lemma LightSlingerParameters.groupSpeed_causal
    (parameters : LightSlingerParameters) :
    parameters.antenna.groupSpeed.metersPerSecond ≤ vacuumSpeedOfLight :=
  parameters.antenna.groupSpeed_causal

/-- The LightSlinger information speed remains within the supplied causal bound. -/
lemma LightSlingerParameters.informationSpeed_causal
    (parameters : LightSlingerParameters) :
    parameters.antenna.informationSpeed.metersPerSecond ≤ vacuumSpeedOfLight :=
  parameters.antenna.informationSpeed_causal

/-- A typed laser-matter interaction profile. -/
inductive LaserInteractionProfile
  | surfacePlasmonCSR (parameters : SurfacePlasmonCSRParameters)
  | freeElectronSPPAmplification
      (parameters : FreeElectronSPPAmplificationParameters)
  | cavityElectrodynamics (parameters : CavityElectrodynamicsParameters)
  | phononPolariton (parameters : PhononPolaritonParameters)
  | lightSlinger (parameters : LightSlingerParameters)
  | solitonWaveguide (parameters : SolitonWaveguideParameters)
  | attosecondSoliton (parameters : AttosecondSolitonParameters)
  | argonIonization (parameters : ArgonIonizationObservation)
  | plasmaLens (parameters : PlasmaLensParameters)
    | nanophotonicParametricOscillator
      (parameters : NanophotonicParametricOscillatorParameters)
    | opticalSuperconductingQubitControl
      (parameters : OpticalSuperconductingQubitControlParameters)
    | chiralQuantumInterconnect
      (parameters : ChiralQuantumInterconnectParameters)
    | dualBeamFemtosecondProcessing
      (parameters : DualBeamFsProcessingParameters)

/-- The interaction class associated with a laser-matter profile. -/
def LaserInteractionProfile.kind : LaserInteractionProfile → LaserInteractionKind
  | LaserInteractionProfile.surfacePlasmonCSR _ =>
      LaserInteractionKind.coherentSynchrotronRadiation
  | LaserInteractionProfile.freeElectronSPPAmplification _ =>
      LaserInteractionKind.freeElectronSurfacePlasmonAmplification
  | LaserInteractionProfile.cavityElectrodynamics _ =>
      LaserInteractionKind.cavityElectrodynamics
  | LaserInteractionProfile.phononPolariton _ =>
      LaserInteractionKind.phononPolariton
    | LaserInteractionProfile.lightSlinger _ =>
      LaserInteractionKind.lightSlingerWaveguide
  | LaserInteractionProfile.solitonWaveguide parameters =>
      match parameters.application with
      | SolitonApplication.qpuBus => LaserInteractionKind.solitonBus
      | SolitonApplication.hollowCoreAttosecond =>
        LaserInteractionKind.attosecondSoliton
      | _ => LaserInteractionKind.solitonWaveguide
  | LaserInteractionProfile.attosecondSoliton _ =>
      LaserInteractionKind.attosecondSoliton
  | LaserInteractionProfile.argonIonization _ =>
      LaserInteractionKind.argonStrongFieldIonization
  | LaserInteractionProfile.plasmaLens _ => LaserInteractionKind.plasmaLens
    | LaserInteractionProfile.nanophotonicParametricOscillator _ =>
      LaserInteractionKind.nanophotonicParametricOscillator
    | LaserInteractionProfile.opticalSuperconductingQubitControl _ =>
      LaserInteractionKind.opticalSuperconductingQubitControl
    | LaserInteractionProfile.chiralQuantumInterconnect _ =>
      LaserInteractionKind.chiralQuantumInterconnect
    | LaserInteractionProfile.dualBeamFemtosecondProcessing _ =>
      LaserInteractionKind.dualBeamFemtosecondProcessing

/-- A cavity profile is in the quantum-QED class only when explicitly labeled. -/
def CavityElectrodynamicsParameters.isCavityQED
    (parameters : CavityElectrodynamicsParameters) : Prop :=
  parameters.regime = CavityRegime.cavityQED

/-- Parameters shared by continuous-wave and pulsed laser profiles. -/
structure CommonParameters where
  wavelength : Length
  wavelength_pos : 0 < wavelength.meters
  spotArea : Area
  spotArea_pos : 0 < spotArea.squareMeters
  evidenceStatus : LaserEvidenceStatus

/-- Parameters for a continuous-wave or scanned laser. -/
structure ContinuousWaveParameters extends CommonParameters where
  averagePower : Power
  averagePower_nonnegative : 0 ≤ averagePower.watts
  scanSpeed : Speed
  scanSpeed_pos : 0 < scanSpeed.metersPerSecond
  exposureDuration : Duration
  exposureDuration_pos : 0 < exposureDuration.seconds

/-- Parameters for a carbon-integrated laser or optical resonator platform. -/
structure IntegratedCarbonParameters extends CommonParameters where
  carbonComponent : CarbonIntegration
  signalWavelength : Length
  signalWavelength_pos : 0 < signalWavelength.meters
  pumpPower : Power
  pumpPower_nonnegative : 0 ≤ pumpPower.watts
  outputPower : Power
  outputPower_nonnegative : 0 ≤ outputPower.watts
  waveguideLength : Length
  waveguideLength_pos : 0 < waveguideLength.meters
  cavityQualityFactor : ℝ
  cavityQualityFactor_pos : 0 < cavityQualityFactor
  amplification : Option OpticalAmplificationParameters

/-- Parameters for a pulsed laser. -/
structure PulsedParameters extends CommonParameters where
  pulseEnergy : Energy
  pulseEnergy_nonnegative : 0 ≤ pulseEnergy.joules
  pulseDuration : Duration
  pulseDuration_pos : 0 < pulseDuration.seconds
  repetitionRate : Frequency
  repetitionRate_nonnegative : 0 ≤ repetitionRate.hz
  fluence : LaserFluence
  fluence_nonnegative : 0 ≤ fluence.joulesPerSquareMeter
  peakPower : Power
  peakPower_nonnegative : 0 ≤ peakPower.watts
  fluenceLaw : fluence.joulesPerSquareMeter * spotArea.squareMeters =
    pulseEnergy.joules
  peakPowerLaw : peakPower.watts * pulseDuration.seconds = pulseEnergy.joules

/-- Parameters for a pulsed laser process with a measured shock state. -/
structure ShockParameters extends PulsedParameters where
  process : ShockProcess
  shockPressure : Pressure
  shockPressure_nonnegative : 0 ≤ shockPressure.pascals
  shockPressureThreshold : Pressure
  shockPressureThreshold_nonnegative : 0 ≤ shockPressureThreshold.pascals
  pressureThresholdLaw : shockPressureThreshold.pascals ≤ shockPressure.pascals

/-- The source family implied by a shock-process label. -/
def ShockParameters.kind (parameters : ShockParameters) : LaserKind :=
  match parameters.process with
  | ShockProcess.laserCompressionShock => LaserKind.laserCompressionShock
  | ShockProcess.laserPeening => LaserKind.laserCompressionShock
  | ShockProcess.genericPulsedShock => LaserKind.shockDrive

/-- A typed laser profile with source family, emission mode, and parameters. -/
inductive LaserProfile
  | continuousWave (kind : LaserKind) (parameters : ContinuousWaveParameters)
  | integratedCarbon (parameters : IntegratedCarbonParameters)
  | lightSlinger (parameters : LightSlingerParameters)
  | pulsed (kind : LaserKind) (mode : LaserMode) (parameters : PulsedParameters)
  | shock (parameters : ShockParameters)

/-- The source family associated with a profile. -/
def LaserProfile.kind : LaserProfile → LaserKind
  | LaserProfile.continuousWave kind _ => kind
  | LaserProfile.integratedCarbon _ => LaserKind.integratedCarbon
  | LaserProfile.lightSlinger _ => LaserKind.lightSlinger
  | LaserProfile.pulsed kind _ _ => kind
  | LaserProfile.shock parameters => parameters.kind

/-- The emission regime associated with a profile. -/
def LaserProfile.mode : LaserProfile → LaserMode
  | LaserProfile.continuousWave _ _ => LaserMode.continuousWave
  | LaserProfile.integratedCarbon _ => LaserMode.continuousWave
  | LaserProfile.lightSlinger _ => LaserMode.continuousWave
  | LaserProfile.pulsed _ mode _ => mode
  | LaserProfile.shock _ => LaserMode.pulsedShock

/-- The wavelength associated with a profile. -/
def LaserProfile.wavelength : LaserProfile → Length
  | LaserProfile.continuousWave _ parameters => parameters.wavelength
  | LaserProfile.integratedCarbon parameters => parameters.wavelength
  | LaserProfile.lightSlinger parameters => parameters.carrierWavelength
  | LaserProfile.pulsed _ _ parameters => parameters.wavelength
  | LaserProfile.shock parameters => parameters.wavelength

/-- The signal wavelength is exposed when a profile is carbon-integrated. -/
def LaserProfile.signalWavelength : LaserProfile → Option Length
  | LaserProfile.integratedCarbon parameters => some parameters.signalWavelength
  | LaserProfile.lightSlinger parameters => some parameters.carrierWavelength
  | _ => none

/-- The average optical power represented by a profile. -/
def LaserProfile.averagePower : LaserProfile → Power
  | LaserProfile.continuousWave _ parameters => parameters.averagePower
  | LaserProfile.integratedCarbon parameters => parameters.pumpPower
  | LaserProfile.lightSlinger parameters => parameters.antenna.inputPower
  | LaserProfile.pulsed _ _ parameters =>
      { watts := parameters.pulseEnergy.joules * parameters.repetitionRate.hz }
  | LaserProfile.shock parameters =>
      { watts := parameters.pulseEnergy.joules * parameters.repetitionRate.hz }

/-- Pulse fluence follows pulse energy divided by illuminated area. -/
lemma PulsedParameters.fluence_holds (parameters : PulsedParameters) :
    parameters.fluence.joulesPerSquareMeter * parameters.spotArea.squareMeters =
      parameters.pulseEnergy.joules :=
  parameters.fluenceLaw

/-- Pulse peak power follows pulse energy divided by pulse duration. -/
lemma PulsedParameters.peak_power_holds (parameters : PulsedParameters) :
    parameters.peakPower.watts * parameters.pulseDuration.seconds =
      parameters.pulseEnergy.joules :=
  parameters.peakPowerLaw

/-- A shock profile meets its explicitly supplied pressure threshold. -/
lemma ShockParameters.pressure_threshold_met (parameters : ShockParameters) :
    parameters.shockPressureThreshold.pascals ≤ parameters.shockPressure.pascals :=
  parameters.pressureThresholdLaw

end Signals.Lasers
