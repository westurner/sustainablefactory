import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Data.Complex.Basic
import Mathlib.Data.Real.Basic
import Mathlib.Tactic
import Signals.Acoustics
import Signals.Applications
import Signals.CavityQED
import Signals.ActiveOptics
import Signals.ProtocolZ8
import Signals.QuditQEC
import Signals.SemiDirac
import Signals.LaserProcesses
import Signals.Geometry
import Signals.DirectionalBroadbandAntenna
import Signals.Homodyne
import Signals.LayerCodes
import Signals.QECReferences
import Signals.Maxwell
import Signals.MHD
import Signals.NonDestructive
import Signals.OAM
import Signals.PaperModels
import Signals.Proca
import Signals.Propagation
import Signals.Units

namespace Signals.Pending

open Signals.Applications
open Signals.Acoustics
open Signals.Geometry
open Signals.Antennas
open Signals.Homodyne
open Signals.Maxwell
open Signals.MHD
open Signals.NonDestructive
open Signals.OAM
open Signals.Proca
open Signals.Propagation
open Signals.Units

/-! # Pending physical formalisms

This namespace contains explicit mathematical models for the requested SQG,
fracture-state, and Amplituhedron proposals. The structures make their physical
premises visible as fields. A constructed value is a model instance, not an
experimental validation of the associated proposal.
-/

/-- Conventional low-frequency and very-low-frequency radio bands. -/
inductive RadioBand
  | lf
  | vlf
  deriving DecidableEq, Repr

/-- Lower edge in hertz of a conventional radio band. -/
def RadioBand.lowerHz : RadioBand → ℝ
  | RadioBand.lf => 30000
  | RadioBand.vlf => 3000

/-- Upper edge in hertz of a conventional radio band. -/
def RadioBand.upperHz : RadioBand → ℝ
  | RadioBand.lf => 300000
  | RadioBand.vlf => 30000

/-- A frequency is inside a selected LF/VLF half-open band. -/
def RadioBand.inRange (band : RadioBand) (frequencyHz : ℝ) : Prop :=
  band.lowerHz ≤ frequencyHz ∧ frequencyHz < band.upperHz

/-- A radio test vector with an explicit band-membership proof. -/
structure RadioTestVector where
  band : RadioBand
  frequencyHz : ℝ
  frequency_positive : 0 < frequencyHz
  inBand : band.inRange frequencyHz

/-- Broad body classes for through-body propagation test vectors. -/
inductive BodyKind
  | earth
  | planet
  | asteroid
  | named
  deriving DecidableEq, Repr

/-- A named planetary or small-body propagation target. -/
structure BodyTarget where
  kind : BodyKind
  name : String
  deriving DecidableEq, Repr

/-- The Earth as a through-body test target. -/
def BodyTarget.earth : BodyTarget :=
  { kind := BodyKind.earth, name := "Earth" }

/-- A named planet as a through-body test target. -/
def BodyTarget.planet (name : String) : BodyTarget :=
  { kind := BodyKind.planet, name := name }

/-- A named asteroid as a through-body test target. -/
def BodyTarget.asteroid (name : String) : BodyTarget :=
  { kind := BodyKind.asteroid, name := name }

/-- An arbitrary named body as a through-body test target. -/
def BodyTarget.named (name : String) : BodyTarget :=
  { kind := BodyKind.named, name := name }

/-- A body-specific atmospheric Argon feed model.

The abundance is represented as a molar fraction, not as a mass fraction or an
energy source. Captured molar flow remains an explicit process measurement. -/
structure AtmosphericArgonSource where
  body : BodyTarget
  argonMoleFraction : BoundedFactor
  ambientMolarFlow : MolarFlowRate
  ambientMolarFlow_nonnegative : 0 ≤ ambientMolarFlow.molesPerSecond
  capturedArgonMolarFlow : MolarFlowRate
  capturedArgonMolarFlow_nonnegative :
    0 ≤ capturedArgonMolarFlow.molesPerSecond
  captureLaw : capturedArgonMolarFlow.molesPerSecond =
    argonMoleFraction.value * ambientMolarFlow.molesPerSecond

/-- Approximate atmospheric Argon molar fraction supplied for Earth-air studies. -/
def earthArgonMoleFraction : BoundedFactor :=
  { value := 0.009
    nonnegative := by norm_num
    le_one := by norm_num }

/-- Approximate atmospheric Argon molar fraction supplied for Mars-atmosphere studies. -/
def marsArgonMoleFraction : BoundedFactor :=
  { value := 0.019
    nonnegative := by norm_num
    le_one := by norm_num }

/-- The atmospheric source exposes its captured Argon flow law. -/
lemma AtmosphericArgonSource.capture_flow_holds
    (source : AtmosphericArgonSource) :
    source.capturedArgonMolarFlow.molesPerSecond =
      source.argonMoleFraction.value * source.ambientMolarFlow.molesPerSecond :=
  source.captureLaw

/-! ## GPE formulation distinctions

The abbreviation `iGPE` is used inconsistently in the source material. These
records distinguish the three requested meanings: inverse reconstruction,
inhomogeneous source-driven evolution, and the nonlinear interactive model.
They are pointwise normalized records rather than PDE solvers.
-/

/-- The equation role represented by a pointwise GPE record. -/
inductive GPEVariant
  | inverse
  | inhomogeneous
  | interactive
  deriving DecidableEq, Repr

/-- The nonlinear, interactive GPE point used by the existing SQG record. -/
structure InteractiveGPEPoint where
  hbar : ℝ
  hbar_pos : 0 < hbar
  effectiveMass : ℝ
  effectiveMass_pos : 0 < effectiveMass
  potential : ℝ
  coupling : ℝ
  density : ℝ
  density_nonnegative : 0 ≤ density
  wavefunction : ℂ
  timeDerivative : ℂ
  laplacian : ℂ
  balance : Complex.I * hbar * timeDerivative =
    (-(hbar ^ 2 / (2 * effectiveMass))) * laplacian +
      (potential + coupling * density) * wavefunction

/-- Compatibility name retained for existing SQG and test fixtures. -/
abbrev IGPEPoint := InteractiveGPEPoint

/-- The interactive record's formulation tag. -/
def InteractiveGPEPoint.formulation (_point : InteractiveGPEPoint) : GPEVariant :=
  GPEVariant.interactive

/-- An interactive GPE point exposes its assumed local field equation. -/
lemma InteractiveGPEPoint.balance_holds (point : InteractiveGPEPoint) :
    Complex.I * point.hbar * point.timeDerivative =
      (-(point.hbar ^ 2 / (2 * point.effectiveMass))) * point.laplacian +
        (point.potential + point.coupling * point.density) * point.wavefunction :=
  point.balance

/-- An inverse GPE point reconstructs the potential from a nonzero wavefunction. -/
structure InverseGPEPoint where
  hbar : ℝ
  hbar_pos : 0 < hbar
  effectiveMass : ℝ
  effectiveMass_pos : 0 < effectiveMass
  coupling : ℝ
  density : ℝ
  density_nonnegative : 0 ≤ density
  wavefunction : ℂ
  wavefunction_nonzero : wavefunction ≠ 0
  timeDerivative : ℂ
  laplacian : ℂ
  potential : ℂ
  inverseLaw : potential =
    Complex.I * hbar * timeDerivative / wavefunction +
      ((hbar ^ 2 / (2 * effectiveMass) : ℝ) : ℂ) * laplacian / wavefunction -
      ((coupling * density : ℝ) : ℂ)

/-- The inverse record's formulation tag. -/
def InverseGPEPoint.formulation (_point : InverseGPEPoint) : GPEVariant :=
  GPEVariant.inverse

/-- An inverse GPE point exposes its supplied potential reconstruction. -/
lemma InverseGPEPoint.potential_reconstruction (point : InverseGPEPoint) :
    point.potential =
      Complex.I * point.hbar * point.timeDerivative / point.wavefunction +
        ((point.hbar ^ 2 / (2 * point.effectiveMass) : ℝ) : ℂ) *
          point.laplacian / point.wavefunction -
        ((point.coupling * point.density : ℝ) : ℂ) :=
  point.inverseLaw

/-- An inhomogeneous GPE point includes an explicit external source term. -/
structure InhomogeneousGPEPoint where
  hbar : ℝ
  hbar_pos : 0 < hbar
  effectiveMass : ℝ
  effectiveMass_pos : 0 < effectiveMass
  potential : ℝ
  coupling : ℝ
  density : ℝ
  density_nonnegative : 0 ≤ density
  wavefunction : ℂ
  timeDerivative : ℂ
  laplacian : ℂ
  source : ℂ
  balance : Complex.I * hbar * timeDerivative =
    (-(hbar ^ 2 / (2 * effectiveMass))) * laplacian +
      (potential + coupling * density) * wavefunction + source

/-- The inhomogeneous record's formulation tag. -/
def InhomogeneousGPEPoint.formulation
    (_point : InhomogeneousGPEPoint) : GPEVariant :=
  GPEVariant.inhomogeneous

/-- An inhomogeneous GPE point exposes its source-driven balance. -/
lemma InhomogeneousGPEPoint.balance_holds (point : InhomogeneousGPEPoint) :
    Complex.I * point.hbar * point.timeDerivative =
      (-(point.hbar ^ 2 / (2 * point.effectiveMass))) * point.laplacian +
        (point.potential + point.coupling * point.density) * point.wavefunction +
          point.source :=
  point.balance

/-- A Pending QND parity contract over a finite OAM qudit.

The signal state and parity are required to survive a dispersive probe readout.
This records the claimed non-demolition behavior; it does not prove that a
physical Kerr interaction has no unmodeled loss or backaction.
-/
structure QuantumNonDemolitionParity (dimension : ℕ) where
  readout : DispersiveReadout (Qudit dimension)
  detectorLoss : BoundedFactor
  parityBefore : Bool
  parityAfter : Bool
  parityPreserved : parityAfter = parityBefore
  measuredParity : Bool
  parityReadoutLaw : measuredParity = parityAfter
  repeatedParity : Bool
  repeatedParityLaw : repeatedParity = measuredParity
  parityResidual : ℝ
  parityResidual_nonnegative : 0 ≤ parityResidual
  parityResidualBound : ℝ
  parityResidualBound_nonnegative : 0 ≤ parityResidualBound
  parityResidualWithinBound : parityResidual ≤ parityResidualBound
  signalDisturbance : ℝ
  signalDisturbance_nonnegative : 0 ≤ signalDisturbance
  disturbanceBound : ℝ
  disturbanceBound_nonnegative : 0 ≤ disturbanceBound
  disturbanceWithinBound : signalDisturbance ≤ disturbanceBound
  absorptionMeasurement : Energy
  absorptionMeasurement_nonnegative : 0 ≤ absorptionMeasurement.joules
  absorptionBound : Energy
  absorptionBound_nonnegative : 0 ≤ absorptionBound.joules
  absorptionWithinBound : absorptionMeasurement.joules ≤ absorptionBound.joules

/-- The QND parity contract preserves the signal qudit state. -/
lemma QuantumNonDemolitionParity.signal_preserved
    {dimension : ℕ} (measurement : QuantumNonDemolitionParity dimension) :
    measurement.readout.signalAfter = measurement.readout.signalBefore :=
  measurement.readout.signalPreserved

/-- The QND parity contract preserves the measured parity. -/
lemma QuantumNonDemolitionParity.parity_preserved
    {dimension : ℕ} (measurement : QuantumNonDemolitionParity dimension) :
    measurement.parityAfter = measurement.parityBefore :=
  measurement.parityPreserved

/-- The QND parity readout returns the post-interaction parity. -/
lemma QuantumNonDemolitionParity.measured_parity_eq
    {dimension : ℕ} (measurement : QuantumNonDemolitionParity dimension) :
    measurement.measuredParity = measurement.parityAfter :=
  measurement.parityReadoutLaw

/-- The Pending QND record exposes its detector-loss factor. -/
lemma QuantumNonDemolitionParity.detector_loss_nonnegative
    {dimension : ℕ} (measurement : QuantumNonDemolitionParity dimension) :
    0 ≤ measurement.detectorLoss.value :=
  measurement.detectorLoss.nonnegative

/-- The Pending QND record compares a repeated parity result with the first result. -/
lemma QuantumNonDemolitionParity.repeated_parity_eq
    {dimension : ℕ} (measurement : QuantumNonDemolitionParity dimension) :
    measurement.repeatedParity = measurement.measuredParity :=
  measurement.repeatedParityLaw

/-- The Pending QND record bounds its parity-classification residual. -/
lemma QuantumNonDemolitionParity.parity_residual_within_bound
    {dimension : ℕ} (measurement : QuantumNonDemolitionParity dimension) :
    measurement.parityResidual ≤ measurement.parityResidualBound :=
  measurement.parityResidualWithinBound

/-- The Pending QND record bounds the measured signal disturbance. -/
lemma QuantumNonDemolitionParity.disturbance_within_bound
    {dimension : ℕ} (measurement : QuantumNonDemolitionParity dimension) :
    measurement.signalDisturbance ≤ measurement.disturbanceBound :=
  measurement.disturbanceWithinBound

/-- The Pending QND record bounds its measured absorbed energy. -/
lemma QuantumNonDemolitionParity.absorption_within_bound
    {dimension : ℕ} (measurement : QuantumNonDemolitionParity dimension) :
    measurement.absorptionMeasurement.joules ≤ measurement.absorptionBound.joules :=
  measurement.absorptionWithinBound

/-- Pending assumptions for quantum quadrature commutation and uncertainty. -/
structure QuantumQuadratureAssumption where
  hbar : ℝ
  hbar_pos : 0 < hbar
  amplitudeVariance : ℝ
  amplitudeVariance_nonnegative : 0 ≤ amplitudeVariance
  phaseVariance : ℝ
  phaseVariance_nonnegative : 0 ≤ phaseVariance
  commutatorMagnitude : ℝ
  commutatorLaw : commutatorMagnitude = hbar / 2
  uncertaintyProduct : ℝ
  uncertaintyBound : ℝ
  uncertaintyBoundLaw : uncertaintyBound = hbar ^ 2 / 4
  uncertaintyWithinBound : uncertaintyBound ≤ uncertaintyProduct
  squeezingParameter : ℝ
  squeezingParameter_nonnegative : 0 ≤ squeezingParameter

/-- The Pending quadrature record exposes its commutator assumption. -/
lemma QuantumQuadratureAssumption.commutator_holds
    (assumption : QuantumQuadratureAssumption) :
    assumption.commutatorMagnitude = assumption.hbar / 2 :=
  assumption.commutatorLaw

/-- The Pending quadrature record exposes its uncertainty lower bound. -/
lemma QuantumQuadratureAssumption.uncertainty_holds
    (assumption : QuantumQuadratureAssumption) :
    assumption.uncertaintyBound = assumption.hbar ^ 2 / 4 :=
  assumption.uncertaintyBoundLaw

/-- A Pending two-mode squeezed-vacuum variance model. -/
structure TwoModeSqueezedVacuum where
  squeezingParameter : ℝ
  squeezingParameter_nonnegative : 0 ≤ squeezingParameter
  xDifferenceVariance : ℝ
  pSumVariance : ℝ
  xDifferenceVarianceLaw :
    xDifferenceVariance = 2 * Real.exp (-2 * squeezingParameter)
  pSumVarianceLaw :
    pSumVariance = 2 * Real.exp (-2 * squeezingParameter)

/-- The Pending TMSV record exposes its X-difference variance. -/
lemma TwoModeSqueezedVacuum.x_difference_variance_holds
    (state : TwoModeSqueezedVacuum) :
    state.xDifferenceVariance = 2 * Real.exp (-2 * state.squeezingParameter) :=
  state.xDifferenceVarianceLaw

/-- The Pending TMSV record exposes its P-sum variance. -/
lemma TwoModeSqueezedVacuum.p_sum_variance_holds
    (state : TwoModeSqueezedVacuum) :
    state.pSumVariance = 2 * Real.exp (-2 * state.squeezingParameter) :=
  state.pSumVarianceLaw

/-- Finite CV Bell-state measurement bookkeeping for two quadrature modes. -/
structure CVBellStateMeasurement where
  inputX : ℝ
  resourceX : ℝ
  inputP : ℝ
  resourceP : ℝ
  measuredX : ℝ
  measuredP : ℝ
  measuredXLaw : measuredX = (inputX - resourceX) / Real.sqrt 2
  measuredPLaw : measuredP = (inputP + resourceP) / Real.sqrt 2

/-- The measured X combination follows the balanced Bell-state law. -/
lemma CVBellStateMeasurement.measured_x_holds
    (measurement : CVBellStateMeasurement) :
    measurement.measuredX =
      (measurement.inputX - measurement.resourceX) / Real.sqrt 2 :=
  measurement.measuredXLaw

/-- The measured P combination follows the balanced Bell-state law. -/
lemma CVBellStateMeasurement.measured_p_holds
    (measurement : CVBellStateMeasurement) :
    measurement.measuredP =
      (measurement.inputP + measurement.resourceP) / Real.sqrt 2 :=
  measurement.measuredPLaw

/-- Continuous classical feed-forward bookkeeping for CV teleportation. -/
structure CVFeedForward where
  gain : ℝ
  measuredX : ℝ
  measuredP : ℝ
  displacementX : ℝ
  displacementP : ℝ
  displacementXLaw : displacementX = gain * measuredX
  displacementPLaw : displacementP = gain * measuredP

/-- The X displacement follows the supplied feed-forward gain. -/
lemma CVFeedForward.displacement_x_holds (feedForward : CVFeedForward) :
    feedForward.displacementX = feedForward.gain * feedForward.measuredX :=
  feedForward.displacementXLaw

/-- The P displacement follows the supplied feed-forward gain. -/
lemma CVFeedForward.displacement_p_holds (feedForward : CVFeedForward) :
    feedForward.displacementP = feedForward.gain * feedForward.measuredP :=
  feedForward.displacementPLaw

/-- Pending CV teleportation plumbing with explicit loss and finite-squeezing noise. -/
structure CVTeleportationBookkeeping where
  bellMeasurement : CVBellStateMeasurement
  feedForward : CVFeedForward
  resourceLoss : BoundedFactor
  finiteSqueezingNoise : ℝ
  finiteSqueezingNoise_nonnegative : 0 ≤ finiteSqueezingNoise
  feedForwardMeasurementLaw :
    feedForward.measuredX = bellMeasurement.measuredX ∧
      feedForward.measuredP = bellMeasurement.measuredP

/-- Pending nonlinear signal/probe phase coupling data for a Kerr interaction. -/
structure KerrInteraction (state : Type u) where
  signalBefore : state
  signalAfter : state
  signalPreserved : signalAfter = signalBefore
  couplingStrength : ℝ
  couplingStrength_nonnegative : 0 ≤ couplingStrength
  interactionLength : Length
  interactionLength_nonnegative : 0 ≤ interactionLength.meters
  signalObservable : ℝ
  probePhaseShift : ℝ
  probePhaseShiftLaw :
    probePhaseShift = couplingStrength * interactionLength.meters * signalObservable

/-- The Pending Kerr record exposes its supplied cross-phase law. -/
lemma KerrInteraction.probe_phase_shift_holds
    {state : Type u} (interaction : KerrInteraction state) :
    interaction.probePhaseShift =
      interaction.couplingStrength * interaction.interactionLength.meters *
        interaction.signalObservable :=
  interaction.probePhaseShiftLaw

/-- Pending hardware-readiness observations for an integrated homodyne detector. -/
structure HomodyneHardwareReadiness where
  insertionLoss : ℝ
  insertionLoss_nonnegative : 0 ≤ insertionLoss
  beamSplitterImbalance : ℝ
  beamSplitterImbalance_nonnegative : 0 ≤ beamSplitterImbalance
  detectorBandwidth : Frequency
  detectorBandwidth_pos : 0 < detectorBandwidth.hz
  thermalLoad : Power
  thermalLoad_nonnegative : 0 ≤ thermalLoad.watts
  materialResponse : ℝ
  materialResponse_nonnegative : 0 ≤ materialResponse
  modeOverlap : BoundedFactor
  calibrationReady : Bool

/-! ## Lignin-vitrimer perovskite solar and imaging boundaries

The source chats use LVP for a proposed lignin-vitrimer perovskite material
family spanning roll-to-roll solar membranes, direct-conversion X-ray panels,
and speculative Proca phase-contrast imaging. These records retain composition,
process, calibration, stability, and control data without promoting proposed
material performance to a verified property.
-/

/-- Manufacturing routes proposed for an LVP precursor or membrane. -/
inductive LVPProcessRoute
  | laboratory
  | slotDie
  | rollToRoll
  | maskedExposure
  deriving DecidableEq, Repr

/-- A finite IOF/EMMO process bridge for LVP deposition and crystallization. -/
structure LVPProcess where
  route : LVPProcessRoute
  webSpeed : Speed
  webSpeed_pos : 0 < webSpeed.metersPerSecond
  webTension : Force
  webTension_nonnegative : 0 ≤ webTension.newtons
  rollerRate : Frequency
  rollerRate_nonnegative : 0 ≤ rollerRate.hz
  precursorViscosity : DynamicViscosity
  precursorViscosity_nonnegative : 0 ≤ precursorViscosity.pascalSeconds
  precursorMassFlow : MassFlowRate
  precursorMassFlow_nonnegative : 0 ≤ precursorMassFlow.kilogramsPerSecond
  ambientHumidity : RelativeHumidity
  ambientHumidity_nonnegative : 0 ≤ ambientHumidity.fraction
  ambientHumidity_le_one : ambientHumidity.fraction ≤ 1
  wetFilmThickness : Length
  wetFilmThickness_pos : 0 < wetFilmThickness.meters
  processTemperature : Temperature
  processTemperature_pos : 0 < processTemperature.kelvin
  crystallizationTime : Duration
  crystallizationTime_pos : 0 < crystallizationTime.seconds
  availableCureTime : Duration
  availableCureTime_pos : 0 < availableCureTime.seconds
  cureSufficient : crystallizationTime.seconds ≤ availableCureTime.seconds

/-- The process bridge exposes its explicit cure-time condition. -/
lemma LVPProcess.cure_sufficient (process : LVPProcess) :
    process.crystallizationTime.seconds ≤ process.availableCureTime.seconds :=
  process.cureSufficient

/-- A proposed Lignin-Vitrimer Perovskite composition and deposition process. -/
structure LigninVitrimerPerovskite where
  perovskiteComposition : String
  ligninFraction : BoundedFactor
  vitrimerFraction : BoundedFactor
  perovskiteFraction : BoundedFactor
  carbonTransportFraction : BoundedFactor
  compositionLaw : ligninFraction.value + vitrimerFraction.value +
      perovskiteFraction.value + carbonTransportFraction.value = 1
  activeLayerThickness : Length
  activeLayerThickness_pos : 0 < activeLayerThickness.meters
  process : LVPProcess

/-- Compatibility abbreviation for the LVP material record. -/
abbrev LVP := LigninVitrimerPerovskite

/-- The LVP composition fractions sum to one by supplied model data. -/
lemma LigninVitrimerPerovskite.composition_holds
    (material : LigninVitrimerPerovskite) :
    material.ligninFraction.value + material.vitrimerFraction.value +
      material.perovskiteFraction.value + material.carbonTransportFraction.value = 1 :=
  material.compositionLaw

/-- Photovoltaic output and stability observations for an LVP solar membrane. -/
structure LVPPhotovoltaicObservation where
  material : LigninVitrimerPerovskite
  activeArea : Area
  activeArea_pos : 0 < activeArea.squareMeters
  incidentIrradiance : Irradiance
  incidentIrradiance_nonnegative : 0 ≤ incidentIrradiance.wattsPerSquareMeter
  outputPower : Power
  outputPower_nonnegative : 0 ≤ outputPower.watts
  conversionEfficiency : BoundedFactor
  outputPowerLaw : outputPower.watts =
    conversionEfficiency.value * incidentIrradiance.wattsPerSquareMeter *
      activeArea.squareMeters
  openCircuitVoltage : Voltage
  openCircuitVoltage_nonnegative : 0 ≤ openCircuitVoltage.volts
  shortCircuitCurrentDensity : CurrentDensity
  shortCircuitCurrentDensity_nonnegative :
    0 ≤ shortCircuitCurrentDensity.amperesPerSquareMeter
  fillFactor : BoundedFactor
  operatingTemperature : Temperature
  operatingTemperature_pos : 0 < operatingTemperature.kelvin
  relativeHumidity : RelativeHumidity
  relativeHumidity_nonnegative : 0 ≤ relativeHumidity.fraction
  relativeHumidity_le_one : relativeHumidity.fraction ≤ 1
  exposureDuration : Duration
  exposureDuration_pos : 0 < exposureDuration.seconds
  postExposureOutputPower : Power
  postExposureOutputPower_nonnegative : 0 ≤ postExposureOutputPower.watts
  retainedPowerFraction : BoundedFactor
  retentionLaw : postExposureOutputPower.watts =
    retainedPowerFraction.value * outputPower.watts
  comparisonResidual : ℝ
  comparisonResidual_nonnegative : 0 ≤ comparisonResidual
  comparisonTolerance : ℝ
  comparisonTolerance_nonnegative : 0 ≤ comparisonTolerance
  comparisonWithinTolerance : comparisonResidual ≤ comparisonTolerance

/-- The LVP photovoltaic output follows the irradiance-area-efficiency law. -/
lemma LVPPhotovoltaicObservation.output_power_holds
    (observation : LVPPhotovoltaicObservation) :
    observation.outputPower.watts =
      observation.conversionEfficiency.value *
        observation.incidentIrradiance.wattsPerSquareMeter *
          observation.activeArea.squareMeters :=
  observation.outputPowerLaw

/-- The photovoltaic stability comparison is within its supplied tolerance. -/
lemma LVPPhotovoltaicObservation.comparison_within_tolerance
    (observation : LVPPhotovoltaicObservation) :
    observation.comparisonResidual ≤ observation.comparisonTolerance :=
  observation.comparisonWithinTolerance

/-- A validation stage for an LVP imaging device. -/
inductive LVPImagingValidationLevel
  | material
  | benchtop
  | phantom
  | preclinical
  | clinical
  deriving DecidableEq, Repr

/-- Finite direct-conversion X-ray imaging observations for an LVP panel. -/
structure LVPDirectConversionImaging (width height : ℕ) where
  material : LigninVitrimerPerovskite
  validationLevel : LVPImagingValidationLevel
  pixelPitch : Length
  pixelPitch_pos : 0 < pixelPitch.meters
  incidentDose : AbsorbedDose
  incidentDose_nonnegative : 0 ≤ incidentDose.grays
  exposureDuration : Duration
  exposureDuration_pos : 0 < exposureDuration.seconds
  pixelDose : Matrix (Fin width) (Fin height) AbsorbedDose
  pixelDose_nonnegative : ∀ row column, 0 ≤ (pixelDose row column).grays
  rawSignal : Matrix (Fin width) (Fin height) ℝ
  darkSignal : Matrix (Fin width) (Fin height) ℝ
  correctedSignal : Matrix (Fin width) (Fin height) ℝ
  darkCorrectionLaw : ∀ row column,
    correctedSignal row column = rawSignal row column - darkSignal row column
  signalGain : ℝ
  signalGain_nonnegative : 0 ≤ signalGain
  directConversionLaw : ∀ row column,
    correctedSignal row column = signalGain * (pixelDose row column).grays
  detectionSensitivity : ℝ
  detectionSensitivity_nonnegative : 0 ≤ detectionSensitivity
  spatialResolution : Length
  spatialResolution_pos : 0 < spatialResolution.meters
  imageResidual : ℝ
  imageResidual_nonnegative : 0 ≤ imageResidual
  imageResidualTolerance : ℝ
  imageResidualTolerance_nonnegative : 0 ≤ imageResidualTolerance
  imageResidualWithinTolerance : imageResidual ≤ imageResidualTolerance

/-- Dark-current correction for a direct-conversion LVP image. -/
lemma LVPDirectConversionImaging.dark_correction_holds
    {width height : ℕ} (observation : LVPDirectConversionImaging width height)
    (row : Fin width) (column : Fin height) :
    observation.correctedSignal row column =
      observation.rawSignal row column - observation.darkSignal row column :=
  observation.darkCorrectionLaw row column

/-- The direct-conversion pixel response follows its supplied dose calibration. -/
lemma LVPDirectConversionImaging.dose_response_holds
    {width height : ℕ} (observation : LVPDirectConversionImaging width height)
    (row : Fin width) (column : Fin height) :
    observation.correctedSignal row column =
      observation.signalGain * (observation.pixelDose row column).grays :=
  observation.directConversionLaw row column

/-- The imaging residual is within its supplied calibration tolerance. -/
lemma LVPDirectConversionImaging.residual_within_tolerance
    {width height : ℕ} (observation : LVPDirectConversionImaging width height) :
    observation.imageResidual ≤ observation.imageResidualTolerance :=
  observation.imageResidualWithinTolerance

/-! ## Mixed-species atmospheric scavenging

These records are a finite normalized model of the source-chat Gaussian-splat
proposal. They expose species-dependent mass and thermal covariance, but do
not assert that a phase gradient can homogenize a real atmospheric flow.
-/

/-- A gas component with particle mass, partial density, and temperature data. -/
structure AtmosphericSpecies where
  name : String
  particleMass : ℝ
  particleMass_pos : 0 < particleMass
  partialDensity : ℝ
  partialDensity_nonnegative : 0 ≤ partialDensity
  temperature : ℝ
  temperature_pos : 0 < temperature

/-- A finite tensor Gaussian splat for one atmospheric species. -/
structure TensorGaussianSplat where
  species : AtmosphericSpecies
  meanVelocity : Vector3
  covariance : Matrix (Fin 3) (Fin 3) ℝ
  covariance_symmetric : ∀ row column,
    covariance row column = covariance column row
  covariance_diagonal_nonnegative : ∀ axis, 0 ≤ covariance axis axis
  boltzmannScale : ℝ
  boltzmannScale_pos : 0 < boltzmannScale
  thermalVariance : ℝ
  thermalVariance_nonnegative : 0 ≤ thermalVariance
  thermalVarianceLaw : thermalVariance =
    boltzmannScale * species.temperature / species.particleMass
  covarianceDiagonalLaw : ∀ axis, covariance axis axis = thermalVariance

/-- A finite mixture of species-dependent atmospheric splats. -/
structure AtmosphericMixture (componentCount : ℕ) where
  component : Fin componentCount → TensorGaussianSplat

/-- The summed partial density represented by a finite mixture. -/
def AtmosphericMixture.totalPartialDensity
    {componentCount : ℕ} (mixture : AtmosphericMixture componentCount) : ℝ :=
  ∑ index, (mixture.component index).species.partialDensity

/-- A finite mixture has nonnegative total partial density. -/
lemma AtmosphericMixture.totalPartialDensity_nonnegative
    {componentCount : ℕ} (mixture : AtmosphericMixture componentCount) :
    0 ≤ mixture.totalPartialDensity := by
  unfold AtmosphericMixture.totalPartialDensity
  exact Finset.sum_nonneg fun index _ =>
    (mixture.component index).species.partialDensity_nonnegative

/-- A normalized finite approximation to the source-chat gate-overlap integral. -/
structure AtmosphericScavenging (componentCount : ℕ) where
  mixture : AtmosphericMixture componentCount
  gateWidth : ℝ
  gateWidth_pos : 0 < gateWidth
  acceptance : Fin componentCount → ℝ
  acceptance_nonnegative : ∀ index, 0 ≤ acceptance index
  acceptance_le_one : ∀ index, acceptance index ≤ 1
  normalizedThroughput : ℝ
  normalizedThroughputLaw : normalizedThroughput =
    ∑ index, (mixture.component index).species.partialDensity * acceptance index

/-- The normalized scavenging throughput is nonnegative. -/
lemma AtmosphericScavenging.normalizedThroughput_nonnegative
    {componentCount : ℕ} (model : AtmosphericScavenging componentCount) :
    0 ≤ model.normalizedThroughput := by
  rw [model.normalizedThroughputLaw]
  exact Finset.sum_nonneg fun index _ =>
    mul_nonneg (model.mixture.component index).species.partialDensity_nonnegative
      (model.acceptance_nonnegative index)

/-- An idealized phase-slip output with explicit homogenization assumptions. -/
structure PhaseSlipHomogenization (componentCount : ℕ) where
  input : AtmosphericMixture componentCount
  targetVelocity : Vector3
  outputVelocity : Fin componentCount → Vector3
  outputCovariance : Fin componentCount → Matrix (Fin 3) (Fin 3) ℝ
  velocityLock : ∀ index, outputVelocity index = targetVelocity
  covarianceCollapse : ∀ index, outputCovariance index = 0

/-- The idealized homogenization record exposes its common output velocity. -/
lemma PhaseSlipHomogenization.common_velocity
    {componentCount : ℕ} (model : PhaseSlipHomogenization componentCount)
    (index : Fin componentCount) :
    model.outputVelocity index = model.targetVelocity :=
  model.velocityLock index

/-- The idealized homogenization record exposes its zero covariance assumption. -/
lemma PhaseSlipHomogenization.zero_output_covariance
    {componentCount : ℕ} (model : PhaseSlipHomogenization componentCount)
    (index : Fin componentCount) :
    model.outputCovariance index = 0 :=
  model.covarianceCollapse index

/-- A tiled square panel with explicit stable dimensions. -/
structure SquarePanel where
  width : ℝ
  width_pos : 0 < width
  height : ℝ
  height_pos : 0 < height
  tileRows : ℕ
  tileRows_positive : 0 < tileRows
  tileColumns : ℕ
  tileColumns_positive : 0 < tileColumns

/-- A classical edge-shear indicator for a square-panel plume.

This is a risk proxy for discontinuity at the physical aperture. It is not a
proof that the surrounding fluid is turbulent or laminar.
-/
structure SquarePanelPlume where
  panel : SquarePanel
  unshapedEdgeShear : ℝ
  unshapedEdgeShear_nonnegative : 0 ≤ unshapedEdgeShear
  apodization : ℝ
  apodization_nonnegative : 0 ≤ apodization
  apodization_le_one : apodization ≤ 1
  residualEdgeShear : ℝ
  residualEdgeShearLaw : residualEdgeShear =
    unshapedEdgeShear * (1 - apodization)

/-- The residual edge-shear proxy after square-panel apodization. -/
def SquarePanelPlume.edgeShearIndicator (plume : SquarePanelPlume) : ℝ :=
  plume.residualEdgeShear

/-- Apodization leaves a nonnegative edge-shear indicator no larger than the
unshaped square-panel value. -/
lemma SquarePanelPlume.edgeShearIndicator_bounds (plume : SquarePanelPlume) :
    0 ≤ plume.edgeShearIndicator ∧
      plume.edgeShearIndicator ≤ plume.unshapedEdgeShear := by
  rw [SquarePanelPlume.edgeShearIndicator, plume.residualEdgeShearLaw]
  constructor
  · exact mul_nonneg plume.unshapedEdgeShear_nonnegative
      (sub_nonneg.mpr plume.apodization_le_one)
  · exact mul_le_of_le_one_right plume.unshapedEdgeShear_nonnegative
      (by linarith [plume.apodization_nonnegative])

/-- A calibrated conversion from normalized gate throughput to mass flow. -/
structure DimensionedScavengingFlow (componentCount : ℕ) where
  normalizedModel : AtmosphericScavenging componentCount
  flowScale : MassFlowRate
  flowScale_nonnegative : 0 ≤ flowScale.kilogramsPerSecond
  massFlow : MassFlowRate
  massFlowLaw : massFlow.kilogramsPerSecond =
    flowScale.kilogramsPerSecond * normalizedModel.normalizedThroughput

/-- A calibrated scavenging flow has nonnegative mass flow. -/
lemma DimensionedScavengingFlow.massFlow_nonnegative
    {componentCount : ℕ} (flow : DimensionedScavengingFlow componentCount) :
    0 ≤ flow.massFlow.kilogramsPerSecond := by
  rw [flow.massFlowLaw]
  exact mul_nonneg flow.flowScale_nonnegative
    flow.normalizedModel.normalizedThroughput_nonnegative

/-- A finite classical control volume with mass, momentum, and energy balances.

The scalar momentum direction is a chosen control-volume axis. All quantities
are supplied in the unit wrappers from `Signals.Units`; the balance fields are
model assumptions to be checked against a physical experiment.
-/
structure ClassicalControlVolume where
  inletMassFlow : MassFlowRate
  inletMassFlow_nonnegative : 0 ≤ inletMassFlow.kilogramsPerSecond
  outletMassFlow : MassFlowRate
  outletMassFlow_nonnegative : 0 ≤ outletMassFlow.kilogramsPerSecond
  massStorageRate : MassFlowRate
  massBalance : inletMassFlow.kilogramsPerSecond =
    outletMassFlow.kilogramsPerSecond + massStorageRate.kilogramsPerSecond
  inletSpeed : Speed
  inletSpeed_nonnegative : 0 ≤ inletSpeed.metersPerSecond
  outletSpeed : Speed
  outletSpeed_nonnegative : 0 ≤ outletSpeed.metersPerSecond
  inletMomentumFlux : Force
  inletMomentumFluxLaw : inletMomentumFlux.newtons =
    inletMassFlow.kilogramsPerSecond * inletSpeed.metersPerSecond
  outletMomentumFlux : Force
  outletMomentumFluxLaw : outletMomentumFlux.newtons =
    outletMassFlow.kilogramsPerSecond * outletSpeed.metersPerSecond
  momentumStorageRate : Force
  externalAxialForce : Force
  momentumBalance : outletMomentumFlux.newtons - inletMomentumFlux.newtons +
      momentumStorageRate.newtons = externalAxialForce.newtons
  electricalInputPower : Power
  electricalInputPower_nonnegative : 0 ≤ electricalInputPower.watts
  aerodynamicHeatPower : Power
  aerodynamicHeatPower_nonnegative : 0 ≤ aerodynamicHeatPower.watts
  usefulOutputPower : Power
  usefulOutputPower_nonnegative : 0 ≤ usefulOutputPower.watts
  lossPower : Power
  lossPower_nonnegative : 0 ≤ lossPower.watts
  energyBalance : usefulOutputPower.watts + lossPower.watts =
    electricalInputPower.watts + aerodynamicHeatPower.watts

/-- A steady control volume has equal inlet and outlet mass flow. -/
lemma ClassicalControlVolume.steady_mass_flow
    (volume : ClassicalControlVolume)
    (steady : volume.massStorageRate.kilogramsPerSecond = 0) :
    volume.inletMassFlow.kilogramsPerSecond =
      volume.outletMassFlow.kilogramsPerSecond := by
  linarith [volume.massBalance]

/-- Momentum accounting exposes the external axial force. -/
lemma ClassicalControlVolume.external_force_eq_momentum_change
    (volume : ClassicalControlVolume) :
    volume.externalAxialForce.newtons =
      volume.outletMomentumFlux.newtons - volume.inletMomentumFlux.newtons +
        volume.momentumStorageRate.newtons := by
  linarith [volume.momentumBalance]

/-- A control volume cannot deliver more useful power than its declared inputs. -/
lemma ClassicalControlVolume.useful_output_le_input
    (volume : ClassicalControlVolume) :
    volume.usefulOutputPower.watts ≤
      volume.electricalInputPower.watts + volume.aerodynamicHeatPower.watts := by
  linarith [volume.energyBalance, volume.lossPower_nonnegative]

/-- Pressure, heat flux, and vector velocity at a control-volume boundary. -/
structure FlowBoundaryCondition where
  pressure : Pressure
  pressure_nonnegative : 0 ≤ pressure.pascals
  heatFlux : HeatFlux
  heatFlux_nonnegative : 0 ≤ heatFlux.wattsPerSquareMeter
  velocity : Fin 3 → Speed

/-- Measured-versus-predicted boundary data with explicit residual tolerances. -/
structure FlowBoundaryObservation where
  measured : FlowBoundaryCondition
  predicted : FlowBoundaryCondition
  pressureTolerance : ℝ
  pressureTolerance_nonnegative : 0 ≤ pressureTolerance
  pressureResidual : ℝ
  pressureResidualLaw : pressureResidual =
    measured.pressure.pascals - predicted.pressure.pascals
  heatFluxTolerance : ℝ
  heatFluxTolerance_nonnegative : 0 ≤ heatFluxTolerance
  heatFluxResidual : ℝ
  heatFluxResidualLaw : heatFluxResidual =
    measured.heatFlux.wattsPerSquareMeter -
      predicted.heatFlux.wattsPerSquareMeter
  velocityTolerance : ℝ
  velocityTolerance_nonnegative : 0 ≤ velocityTolerance
  velocityResidual : Fin 3 → ℝ
  velocityResidualLaw : ∀ axis, velocityResidual axis =
    (measured.velocity axis).metersPerSecond -
      (predicted.velocity axis).metersPerSecond
  consistent : |pressureResidual| ≤ pressureTolerance ∧
    |heatFluxResidual| ≤ heatFluxTolerance ∧
      ∀ axis, |velocityResidual axis| ≤ velocityTolerance

/-- A consistent boundary observation exposes its pressure residual check. -/
lemma FlowBoundaryObservation.pressure_within_tolerance
    (observation : FlowBoundaryObservation) :
    |observation.pressureResidual| ≤ observation.pressureTolerance :=
  observation.consistent.1

/-- A consistent boundary observation exposes its heat-flux residual check. -/
lemma FlowBoundaryObservation.heatFlux_within_tolerance
    (observation : FlowBoundaryObservation) :
    |observation.heatFluxResidual| ≤ observation.heatFluxTolerance :=
  observation.consistent.2.1

/-- A consistent boundary observation exposes its componentwise velocity checks. -/
lemma FlowBoundaryObservation.velocity_within_tolerance
    (observation : FlowBoundaryObservation) (axis : Fin 3) :
    |observation.velocityResidual axis| ≤ observation.velocityTolerance :=
  observation.consistent.2.2 axis

/-- Pending SQG medium parameters for a Maxwell constitutive model.

The metric correction, effective constitutive parameters, and dilatant pressure
are model inputs. They do not assert that the physical vacuum has these
properties. -/
structure SQGMedium where
  baseline : MaterialParameters
  metricCorrection : ℝ
  effectivePermittivity : ℝ
  effectivePermittivity_pos : 0 < effectivePermittivity
  effectivePermeability : ℝ
  effectivePermeability_pos : 0 < effectivePermeability
  permittivityLaw : effectivePermittivity =
    baseline.permittivity * (1 + metricCorrection)
  permeabilityLaw : effectivePermeability =
    baseline.permeability * (1 + metricCorrection)
  dilatantPressure : ℝ
  dilatantPressure_nonnegative : 0 ≤ dilatantPressure

/-- A Maxwell system with an explicit SQG-modified constitutive medium.

The additional `sqgCurrent` is the only new source in Ampere-Maxwell's law.
Any physical interpretation of it must be justified or measured separately. -/
structure SQGMaxwellSystem (calculus : VectorCalculus) where
  medium : SQGMedium
  vacuumState : IGPEPoint
  electricField : Vector3
  displacementField : Vector3
  magneticField : Vector3
  magneticIntensity : Vector3
  rho : ℝ
  current : Vector3
  sqgCurrent : Vector3
  constitutiveElectric : displacementField =
    medium.effectivePermittivity • electricField
  constitutiveMagnetic : magneticField =
    medium.effectivePermeability • magneticIntensity
  gaussElectric : calculus.divergence displacementField = rho
  gaussMagnetic : calculus.divergence magneticField = 0
  faraday : calculus.curl electricField = -calculus.vectorTimeDerivative magneticField
  ampere : calculus.curl magneticIntensity =
    (current + sqgCurrent) + calculus.vectorTimeDerivative displacementField

/-- The SQG-modified electric constitutive relation is explicit model data. -/
lemma SQGMaxwellSystem.electric_constitutive
    {calculus : VectorCalculus} (system : SQGMaxwellSystem calculus) :
    system.displacementField = system.medium.effectivePermittivity •
      system.electricField :=
  system.constitutiveElectric

/-- The SQG-modified magnetic constitutive relation is explicit model data. -/
lemma SQGMaxwellSystem.magnetic_constitutive
    {calculus : VectorCalculus} (system : SQGMaxwellSystem calculus) :
    system.magneticField = system.medium.effectivePermeability •
      system.magneticIntensity :=
  system.constitutiveMagnetic

/-- Charge continuity for the total ordinary-plus-SQG current. -/
lemma SQGMaxwellSystem.total_charge_continuity
    {calculus : VectorCalculus} (system : SQGMaxwellSystem calculus) :
    calculus.scalarTimeDerivative system.rho +
        calculus.divergence (system.current + system.sqgCurrent) = 0 := by
  have divergence_ampere := congrArg calculus.divergence system.ampere
  rw [calculus.divergence_curl, calculus.divergence_add,
    calculus.divergence_timeDerivative, system.gaussElectric] at divergence_ampere
  linarith

/-- Disable the pending SQG current to recover the verified Maxwell system. -/
def SQGMaxwellSystem.toMaxwellSystem
    {calculus : VectorCalculus} (system : SQGMaxwellSystem calculus)
    (sqgCurrent_zero : system.sqgCurrent = 0) : Maxwell.System calculus :=
  { electricField := system.electricField
    displacementField := system.displacementField
    magneticField := system.magneticField
    magneticIntensity := system.magneticIntensity
    rho := system.rho
    current := system.current
    gaussElectric := system.gaussElectric
    gaussMagnetic := system.gaussMagnetic
    faraday := system.faraday
    ampere := by simpa [sqgCurrent_zero] using system.ampere }

/-- The SQG extension reduces to ordinary Maxwell Ampere-Maxwell sourcing when
its additional current is zero. -/
lemma SQGMaxwellSystem.toMaxwellSystem_ampere
    {calculus : VectorCalculus} (system : SQGMaxwellSystem calculus)
    (sqgCurrent_zero : system.sqgCurrent = 0) :
    calculus.curl system.magneticIntensity =
      system.current + calculus.vectorTimeDerivative system.displacementField := by
  simpa [sqgCurrent_zero] using system.ampere

/-- A finite effective acoustic metric record for an iQFT analogue model. -/
structure EffectiveAcousticMetric where
  density : ℝ
  density_nonnegative : 0 ≤ density
  soundSpeed : ℝ
  soundSpeed_pos : 0 < soundSpeed
  flowSpeed : ℝ
  gTT : ℝ
  gTT_law : gTT = density * (flowSpeed ^ 2 - soundSpeed ^ 2)

/-- The pending metric model's ergoregion predicate. -/
def EffectiveAcousticMetric.ergoregion (metric : EffectiveAcousticMetric) : Prop :=
  0 < metric.gTT

/-- Positive `gTT` is exactly the pending ergoregion condition. -/
lemma EffectiveAcousticMetric.ergoregion_iff (metric : EffectiveAcousticMetric) :
    metric.ergoregion ↔ 0 < metric.gTT := by
  rfl

/-- A phase slip with an explicit integer winding number. -/
structure PhaseSlip where
  winding : ℤ
  phaseJump : ℝ
  windingLaw : phaseJump = (winding : ℝ) * (2 * Real.pi)

/-- A phase slip with zero winding has zero phase jump. -/
lemma PhaseSlip.zero_winding_phase (slip : PhaseSlip)
    (zero_winding : slip.winding = 0) :
    slip.phaseJump = 0 := by
  rw [slip.windingLaw, zero_winding]
  norm_num

/-! ## Amplituhedron-inspired finite maps

The source-chat construction uses a matrix map `Y = C * Z`. The records below
make that map executable over finite real matrices while keeping positivity as
an optional condition on the input. The reciprocal chart is only a local
finite-dimensional analogue of a logarithmic form; it is not a formalization
of the full canonical differential form.
-/

/-- A finite matrix map from Grassmannian data to an image matrix. -/
structure AmplituhedronMap (k n m : ℕ) where
  source : GrassmannianMatrix k n
  externalData : Matrix (Fin n) (Fin m) ℝ
  image : Matrix (Fin k) (Fin m) ℝ
  imageLaw : image = source.mat * externalData

/-- The finite image equation is available as a normal rewrite lemma. -/
lemma AmplituhedronMap.image_eq
    {k n m : ℕ} (map : AmplituhedronMap k n m) :
    map.image = map.source.mat * map.externalData :=
  map.imageLaw

/-- A local chart with explicit positive-domain and non-boundary assumptions. -/
structure LogarithmicChart (k n m : ℕ) where
  map : AmplituhedronMap k n m
  source_positive : map.source.hasPositiveOrderedMinors
  boundary : OrderedColumns k n
  boundaryCoordinate : ℝ
  boundaryCoordinateLaw : boundaryCoordinate =
    map.source.pluckerCoordinate boundary
  boundaryCoordinate_nonzero : boundaryCoordinate ≠ 0
  residue : ℝ

/-- The finite reciprocal weight associated with a non-boundary chart. -/
noncomputable def LogarithmicChart.weight
    {k n m : ℕ} (chart : LogarithmicChart k n m) : ℝ :=
  chart.residue / chart.boundaryCoordinate

/-- The chart weight has the expected residue-times-coordinate law. -/
lemma LogarithmicChart.weight_mul_boundary
    {k n m : ℕ} (chart : LogarithmicChart k n m) :
    chart.weight * chart.boundaryCoordinate = chart.residue := by
  dsimp [LogarithmicChart.weight]
  field_simp [chart.boundaryCoordinate_nonzero]

/-- A measured amplitude identified with the finite chart weight by hypothesis. -/
structure AmplituhedronScatteringHypothesis (k n m : ℕ) where
  chart : LogarithmicChart k n m
  measuredAmplitude : ℝ
  measuredAmplitudeLaw : measuredAmplitude = chart.weight

/-- The measured amplitude exposes the chart interpretation as supplied data. -/
lemma AmplituhedronScatteringHypothesis.measured_amplitude_eq
    {k n m : ℕ} (hypothesis : AmplituhedronScatteringHypothesis k n m) :
    hypothesis.measuredAmplitude = hypothesis.chart.weight :=
  hypothesis.measuredAmplitudeLaw

/-- A finite Amplituhedron-inspired phase profile used by pending models. -/
structure AmplituhedronProfile where
  dimension : ℕ
  dimension_positive : 0 < dimension
  phaseWeight : ℝ
  phaseWeight_nonnegative : 0 ≤ phaseWeight
  phaseWeight_le_one : phaseWeight ≤ 1

/-- A pending structured-wave operational state. -/
inductive FractureState
  | generated
  | guided
  | attenuated
  | received
  deriving DecidableEq, Repr

/-- A Proca wave carrying a pending finite phase profile. -/
structure FractureWave where
  model : Proca.Model
  field : Proca.DrivenField model
  state : FractureState
  profile : AmplituhedronProfile
  frequency : ℝ
  frequency_positive : 0 < frequency
  amplitude : ℝ
  amplitude_nonnegative : 0 ≤ amplitude

/-- The phase-weighted amplitude of a pending fracture state. -/
def FractureWave.effectiveAmplitude (wave : FractureWave) : ℝ :=
  wave.amplitude * wave.profile.phaseWeight

/-- A phase profile cannot increase a nonnegative pending wave amplitude. -/
lemma FractureWave.effectiveAmplitude_bounds (wave : FractureWave) :
    0 ≤ wave.effectiveAmplitude ∧ wave.effectiveAmplitude ≤ wave.amplitude := by
  constructor
  · exact mul_nonneg wave.amplitude_nonnegative wave.profile.phaseWeight_nonnegative
  · exact mul_le_of_le_one_right wave.amplitude_nonnegative
      wave.profile.phaseWeight_le_one

/-! ## Hawking-like decoding bookkeeping

The source describes a proposed chain from prepared modulation and observed
homodyne data through inverse-GPE correction, inverse-QFT processing, an
Amplituhedron constraint, and CP/ALS reconstruction. The records below retain
that chain as finite data and residual metadata; they do not establish a
physical Hawking decoder or a quantum Fourier-transform implementation.
-/

/-- A prepared finite modulation trace, representing the known input `X(t)`. -/
structure PreparedModulation (sampleCount : ℕ) where
  value : Fin sampleCount → ℝ

/-- A finite spatial-temporal homodyne tensor, representing observed `Y(x,y,t)`. -/
structure ObservedHomodyneTensor (width height sampleCount : ℕ) where
  value : Fin width → Fin height → Fin sampleCount → ℝ

/-- A complex time trace selected from an observed homodyne tensor. -/
def ObservedHomodyneTensor.trace
    {width height sampleCount : ℕ} (tensor : ObservedHomodyneTensor width height sampleCount)
    (x : Fin width) (y : Fin height) : Fin sampleCount → ℂ :=
  fun time => (tensor.value x y time : ℂ)

/-- The explicit normalization factor for a finite inverse-QFT kernel. -/
noncomputable def inverseQFTNormalization (dimension : ℕ) : ℝ :=
  1 / Real.sqrt (dimension : ℝ)

/-- A finite inverse quantum Fourier transform kernel used as Pending
decoding bookkeeping. -/
noncomputable def finiteInverseQFT (dimension : ℕ) (input : Fin dimension → ℂ)
    (outputIndex : Fin dimension) : ℂ :=
  ((inverseQFTNormalization dimension : ℝ) : ℂ) *
    ∑ inputIndex : Fin dimension,
      input inputIndex * Complex.exp
        (((-2 : ℝ) : ℂ) * Complex.I * (Real.pi : ℂ) *
          (((outputIndex.val : ℝ) * (inputIndex.val : ℝ) /
            (dimension : ℝ) : ℝ) : ℂ))

/-- A finite inverse-QFT record with an explicit transform law. -/
structure FiniteIQFT (dimension : ℕ) where
  dimension_positive : 0 < dimension
  input : Fin dimension → ℂ
  output : Fin dimension → ℂ
  normalizationFactor : ℝ
  normalizationLaw : normalizationFactor = inverseQFTNormalization dimension
  outputLaw : ∀ outputIndex, output outputIndex =
    finiteInverseQFT dimension input outputIndex

/-- The finite inverse-QFT output follows its supplied kernel law. -/
lemma FiniteIQFT.output_holds {dimension : ℕ} (transform : FiniteIQFT dimension)
    (outputIndex : Fin dimension) :
    transform.output outputIndex =
      finiteInverseQFT dimension transform.input outputIndex :=
  transform.outputLaw outputIndex

/-- An alternating-least-squares rank constrained to the planned 2--10 range. -/
structure ALSRank where
  rank : ℕ
  lowerBound : 2 ≤ rank
  upperBound : rank ≤ 10

/-- The ALS rank is explicitly within the planned finite range. -/
lemma ALSRank.in_range (rank : ALSRank) : 2 ≤ rank.rank ∧ rank.rank ≤ 10 :=
  ⟨rank.lowerBound, rank.upperBound⟩

/-- The finite CP reconstruction generated by three factor matrices. -/
noncomputable def cpReconstruction
    (width height sampleCount rank : ℕ)
    (factorX : Matrix (Fin width) (Fin rank) ℝ)
    (factorY : Matrix (Fin height) (Fin rank) ℝ)
    (factorT : Matrix (Fin sampleCount) (Fin rank) ℝ) :
    Fin width → Fin height → Fin sampleCount → ℝ :=
  fun x y time => ∑ component : Fin rank,
    factorX x component * factorY y component * factorT time component

/-- A finite CP/ALS reconstruction record with factor, residual, and iteration
metadata. It records an ALS result supplied by an external numerical process. -/
structure ALSDecomposition (width height sampleCount : ℕ) where
  rank : ALSRank
  observed : Fin width → Fin height → Fin sampleCount → ℝ
  reconstructed : Fin width → Fin height → Fin sampleCount → ℝ
  factorX : Matrix (Fin width) (Fin rank.rank) ℝ
  factorY : Matrix (Fin height) (Fin rank.rank) ℝ
  factorT : Matrix (Fin sampleCount) (Fin rank.rank) ℝ
  reconstructionLaw : ∀ x y time, reconstructed x y time =
    cpReconstruction width height sampleCount rank.rank factorX factorY factorT x y time
  residualMagnitude : ℝ
  residualMagnitude_nonnegative : 0 ≤ residualMagnitude
  residualTolerance : ℝ
  residualTolerance_nonnegative : 0 ≤ residualTolerance
  residualWithinTolerance : residualMagnitude ≤ residualTolerance
  iterations : ℕ
  maximumIterations : ℕ
  iterationsWithinLimit : iterations ≤ maximumIterations

/-- The ALS reconstruction residual is within its supplied tolerance. -/
lemma ALSDecomposition.residual_within_tolerance
    {width height sampleCount : ℕ} (decomposition : ALSDecomposition width height sampleCount) :
    decomposition.residualMagnitude ≤ decomposition.residualTolerance :=
  decomposition.residualWithinTolerance

/-- A known-input comparison records recovered samples and its residual bound. -/
structure KnownInputComparison (sampleCount : ℕ) where
  prepared : Fin sampleCount → ℝ
  recovered : Fin sampleCount → ℝ
  residualMagnitude : ℝ
  residualMagnitude_nonnegative : 0 ≤ residualMagnitude
  residualTolerance : ℝ
  residualTolerance_nonnegative : 0 ≤ residualTolerance
  residualWithinTolerance : residualMagnitude ≤ residualTolerance

/-- Pending decoding of a Hawking-like emission through iGPE, iQFT,
Amplituhedron, and finite-rank ALS stages. -/
structure HawkingRadiationDecoding (width height sampleCount : ℕ) where
  emission : FractureWave
  interactiveGPE : InteractiveGPEPoint
  inverseGPE : InverseGPEPoint
  preparedModulation : PreparedModulation sampleCount
  observedTensor : ObservedHomodyneTensor width height sampleCount
  observationX : Fin width
  observationY : Fin height
  observedTrace : Fin sampleCount → ℂ
  observedTraceLaw : ∀ time, observedTrace time =
    observedTensor.trace observationX observationY time
  iGPEOutput : Fin sampleCount → ℂ
  iGPEResidualMagnitude : ℝ
  iGPEResidualMagnitude_nonnegative : 0 ≤ iGPEResidualMagnitude
  iGPEResidualTolerance : ℝ
  iGPEResidualTolerance_nonnegative : 0 ≤ iGPEResidualTolerance
  iGPEResidualWithinTolerance : iGPEResidualMagnitude ≤ iGPEResidualTolerance
  iqft : FiniteIQFT sampleCount
  iqftInputLaw : ∀ inputIndex, iqft.input inputIndex = iGPEOutput inputIndex
  amplituhedron : AmplituhedronMap width height sampleCount
  amplituhedronChart : LogarithmicChart width height sampleCount
  amplituhedronChartMapLaw : amplituhedronChart.map = amplituhedron
  iqftExternalDataLaw : ∀ row column,
    amplituhedron.externalData row column = (iqft.output column).re
  als : ALSDecomposition width height sampleCount
  alsSliceY : Fin height
  alsProjection : Matrix (Fin width) (Fin sampleCount) ℝ
  alsProjectionObservedLaw : ∀ x time,
    alsProjection x time = als.observed x alsSliceY time
  alsProjectionMapLaw : alsProjection = amplituhedron.image
  inputComparison : KnownInputComparison sampleCount
  inputComparisonPreparedLaw : inputComparison.prepared = preparedModulation.value
  inputComparisonRecoveredLaw : ∀ time,
    inputComparison.recovered time = (iqft.output time).re

/-- The Pending decoder preserves the observed homodyne trace at the tensor boundary. -/
lemma HawkingRadiationDecoding.observed_trace_holds
    {width height sampleCount : ℕ} (decoding : HawkingRadiationDecoding width height sampleCount)
    (time : Fin sampleCount) :
    decoding.observedTrace time =
      decoding.observedTensor.trace decoding.observationX decoding.observationY time :=
  decoding.observedTraceLaw time

/-- The Pending decoder preserves the iGPE-to-iQFT stage boundary. -/
lemma HawkingRadiationDecoding.iqft_input_holds
    {width height sampleCount : ℕ} (decoding : HawkingRadiationDecoding width height sampleCount)
    (inputIndex : Fin sampleCount) :
    decoding.iqft.input inputIndex = decoding.iGPEOutput inputIndex :=
  decoding.iqftInputLaw inputIndex

/-- The Pending decoder links the ALS observation slice to the finite geometric map. -/
lemma HawkingRadiationDecoding.als_projection_holds
    {width height sampleCount : ℕ}
    (decoding : HawkingRadiationDecoding width height sampleCount) :
    decoding.alsProjection = decoding.amplituhedron.image :=
  decoding.alsProjectionMapLaw

/-- Medium domains proposed for pending massive-vector propagation. -/
inductive MediumDomain
  | atmosphere
  | cloud
  | lithosphere
  | ionosphere
  | waveguide
  | throughSpace
  | throughBody (body : BodyTarget)
  deriving DecidableEq, Repr

/-- An LF/VLF test vector explicitly assigned to a named through-body domain. -/
structure ThroughBodyRadioTestVector where
  target : BodyTarget
  domain : MediumDomain
  frequency : RadioTestVector
  domainLaw : domain = MediumDomain.throughBody target

/-- The domain recorded by a through-body vector is its target body. -/
lemma ThroughBodyRadioTestVector.domain_eq_target
    (vector : ThroughBodyRadioTestVector) :
    vector.domain = MediumDomain.throughBody vector.target :=
  vector.domainLaw

/-- A pending Proca channel treats a longitudinal massive mode as supplied
model data for one propagation domain. -/
structure ProcaChannel where
  domain : MediumDomain
  model : Proca.Model
  field : Proca.DrivenField model
  mode : Proca.Mode model
  link : LinkBudget
  longitudinalCoupling : ℝ
  longitudinalCoupling_nonzero : longitudinalCoupling ≠ 0
  longitudinalModeAssumed : longitudinalCoupling * mode.longitudinalWaveNumber ≠ 0

/-- The role assigned to a Pending Proca field at an MHD interface. -/
inductive ProcaMHDFieldRole
  | control
  | coupling
  deriving DecidableEq, Repr

/-- A Pending Proca control/coupling field interface.

The coupled motive power is supplied model data with an explicit gain and
residual. This record does not assert that a Proca field exists, accelerates
Argon, or supplies energy from vacuum geometry. -/
structure ProcaControlField where
  channel : ProcaChannel
  role : ProcaMHDFieldRole
  frequency : Frequency
  frequency_pos : 0 < frequency.hz
  frequencyMatch : frequency.hz = channel.mode.frequency
  controlPower : Power
  controlPower_nonnegative : 0 ≤ controlPower.watts
  couplingGain : ℝ
  couplingGain_nonnegative : 0 ≤ couplingGain
  coupledMotivePower : Power
  coupledMotivePower_nonnegative : 0 ≤ coupledMotivePower.watts
  couplingPowerLaw : coupledMotivePower.watts =
    couplingGain * controlPower.watts
  couplingResidual : ℝ
  couplingResidual_nonnegative : 0 ≤ couplingResidual
  couplingTolerance : ℝ
  couplingTolerance_nonnegative : 0 ≤ couplingTolerance
  couplingWithinTolerance : couplingResidual ≤ couplingTolerance

/-- The Pending Proca control field exposes its supplied coupling law. -/
lemma ProcaControlField.coupled_motive_power_holds
    (field : ProcaControlField) :
    field.coupledMotivePower.watts = field.couplingGain * field.controlPower.watts :=
  field.couplingPowerLaw

/-- The Pending control field exposes its supplied mode-frequency match. -/
lemma ProcaControlField.frequency_match (field : ProcaControlField) :
    field.frequency.hz = field.channel.mode.frequency :=
  field.frequencyMatch

/-- The Pending Proca control field exposes its coupling residual bound. -/
lemma ProcaControlField.coupling_within_tolerance
    (field : ProcaControlField) :
    field.couplingResidual ≤ field.couplingTolerance :=
  field.couplingWithinTolerance

/-- A Pending bridge from a Proca channel to the classical Argon MHD plant.

The optical control power and motive flow power are kept separate. A reported
ratio against control power alone is not the plant efficiency and does not
demonstrate energy extraction from vacuum geometry. -/
structure ProcaMHDHypothesis where
  channel : ProcaChannel
  plant : ArgonMHDPlant
  operatingCosts : MHDOperatingCosts
  controlField : ProcaControlField
  controlFieldChannelLaw : controlField.channel = channel
  opticalControlPower : Power
  opticalControlPower_pos : 0 < opticalControlPower.watts
  opticalControlPowerLaw : opticalControlPower.watts =
    plant.accounting.controlPower.watts
  controlFieldPowerLaw : controlField.controlPower.watts =
    opticalControlPower.watts
  motivePower : Power
  motivePower_nonnegative : 0 ≤ motivePower.watts
  motivePowerLaw : motivePower.watts = plant.accounting.motivePower.watts
  coupledMotivePowerLaw : motivePower.watts = controlField.coupledMotivePower.watts
  reportedQFactor : ℝ
  reportedQFactorLaw : reportedQFactor =
    controlOnlyRatio plant.accounting.electricalOutputPower opticalControlPower

/-- The total-input accounting includes both control and motive power. -/
lemma ProcaMHDHypothesis.total_input_includes_motive
    (hypothesis : ProcaMHDHypothesis) :
    hypothesis.plant.accounting.totalInputPower.watts =
      hypothesis.opticalControlPower.watts + hypothesis.motivePower.watts := by
  unfold MHDPowerAccounting.totalInputPower
  rw [← hypothesis.opticalControlPowerLaw, ← hypothesis.motivePowerLaw]

/-- The reported Proca control ratio is the supplied control-only ratio. -/
lemma ProcaMHDHypothesis.reported_qfactor_holds
    (hypothesis : ProcaMHDHypothesis) :
    hypothesis.reportedQFactor =
      controlOnlyRatio hypothesis.plant.accounting.electricalOutputPower
        hypothesis.opticalControlPower :=
  hypothesis.reportedQFactorLaw

/-- A control-only Q-ratio threshold is an output-versus-control inequality. -/
lemma ProcaMHDHypothesis.reported_qfactor_gt_iff
    (hypothesis : ProcaMHDHypothesis) (threshold : ℝ) :
    hypothesis.reportedQFactor > threshold ↔
      threshold * hypothesis.opticalControlPower.watts <
        hypothesis.plant.accounting.electricalOutputPower.watts := by
  rw [hypothesis.reportedQFactorLaw]
  exact controlOnlyRatio_gt_iff
    hypothesis.plant.accounting.electricalOutputPower hypothesis.opticalControlPower
    hypothesis.opticalControlPower_pos threshold

/-- The actual positive-input plant efficiency remains bounded by one. -/
lemma ProcaMHDHypothesis.actual_efficiency_le_one
    (hypothesis : ProcaMHDHypothesis)
    (totalInput_positive : 0 < hypothesis.plant.accounting.totalInputPower.watts) :
    hypothesis.plant.accounting.efficiency ≤ 1 :=
  hypothesis.plant.accounting.efficiency_le_one totalInput_positive

/-- The full-input efficiency includes all declared auxiliary operating costs. -/
lemma ProcaMHDHypothesis.actual_full_efficiency_le_one
    (hypothesis : ProcaMHDHypothesis)
    (fullInput_positive :
      0 < (hypothesis.plant.accounting.fullInputPower hypothesis.operatingCosts).watts) :
    hypothesis.plant.accounting.fullEfficiency hypothesis.operatingCosts ≤ 1 :=
  hypothesis.plant.accounting.full_efficiency_le_one hypothesis.operatingCosts
    fullInput_positive

/-- A Pending Proca phase-contrast imaging hypothesis using an LVP detector. -/
structure LVPProcaImagingHypothesis (width height : ℕ) where
  material : LigninVitrimerPerovskite
  channel : ProcaChannel
  phaseMap : Matrix (Fin width) (Fin height) ℝ
  longitudinalFraction : BoundedFactor
  spatialResolution : Length
  spatialResolution_pos : 0 < spatialResolution.meters
  incidentProbeEnergy : Energy
  incidentProbeEnergy_nonnegative : 0 ≤ incidentProbeEnergy.joules
  absorbedProbeEnergy : Energy
  absorbedProbeEnergy_nonnegative : 0 ≤ absorbedProbeEnergy.joules
  phaseResidual : ℝ
  phaseResidual_nonnegative : 0 ≤ phaseResidual
  phaseResidualTolerance : ℝ
  phaseResidualTolerance_nonnegative : 0 ≤ phaseResidualTolerance
  phaseResidualWithinTolerance : phaseResidual ≤ phaseResidualTolerance
  masslessControlResidual : ℝ
  masslessControlResidual_nonnegative : 0 ≤ masslessControlResidual
  masslessControlTolerance : ℝ
  masslessControlTolerance_nonnegative : 0 ≤ masslessControlTolerance
  masslessControlWithinTolerance : masslessControlResidual ≤ masslessControlTolerance

/-- The Proca imaging phase residual is within its supplied tolerance. -/
lemma LVPProcaImagingHypothesis.phase_residual_within_tolerance
    {width height : ℕ} (hypothesis : LVPProcaImagingHypothesis width height) :
    hypothesis.phaseResidual ≤ hypothesis.phaseResidualTolerance :=
  hypothesis.phaseResidualWithinTolerance

/-- The Proca imaging hypothesis retains an explicit massless control residual. -/
lemma LVPProcaImagingHypothesis.massless_control_within_tolerance
    {width height : ℕ} (hypothesis : LVPProcaImagingHypothesis width height) :
    hypothesis.masslessControlResidual ≤ hypothesis.masslessControlTolerance :=
  hypothesis.masslessControlWithinTolerance

/-- A LightSlinger antenna paired with an explicitly assumed Proca channel.

The frequency match and longitudinal coupling are hypotheses about an interface
experiment; this record does not establish that a dielectric track generates or
transmits a massive longitudinal mode.
-/
structure LightSlingerProcaCoupling where
  antenna : Signals.Antennas.DirectionalBroadbandAntenna
  channel : ProcaChannel
  frequencyMatch : antenna.carrierFrequency.hz = channel.mode.frequency
  longitudinalCouplingAssumed :
    channel.longitudinalCoupling * channel.mode.longitudinalWaveNumber ≠ 0

/-- The coupled antenna and channel use the same supplied carrier frequency. -/
lemma LightSlingerProcaCoupling.frequency_match
    (coupling : LightSlingerProcaCoupling) :
    coupling.antenna.carrierFrequency.hz = coupling.channel.mode.frequency :=
  coupling.frequencyMatch

/-- The coupled channel exposes its supplied longitudinal-mode assumption. -/
lemma LightSlingerProcaCoupling.longitudinal_mode_assumed
    (coupling : LightSlingerProcaCoupling) :
    coupling.channel.longitudinalCoupling *
        coupling.channel.mode.longitudinalWaveNumber ≠ 0 :=
  coupling.longitudinalCouplingAssumed

/-- A CW resonator hypothesized to emit a longitudinal massive Proca mode.

CW drive, resonance, and a longitudinal field label are necessary bookkeeping
conditions in this model. They do not prove that the dielectric track converts
ordinary radiation into a massive mode; that conversion remains the explicit
coupling hypothesis below.
-/
structure CWProcaEmissionHypothesis where
  application : CWApplication
  massiveModeRequired : application.requirements.massiveModeHypothesis = true
  resonator : ContinuousWaveResonator
  channel : ProcaChannel
  cwDriven : resonator.isDriven
  longitudinalMode : resonator.mode = ResonatorMode.longitudinal
  frequencyMatch : resonator.driveFrequency.hz = channel.mode.frequency
  massiveMode : 0 < channel.model.mass
  longitudinalCouplingAssumed :
    channel.longitudinalCoupling * channel.mode.longitudinalWaveNumber ≠ 0
  emittedPower : Power
  emittedPower_nonnegative : 0 ≤ emittedPower.watts
  emittedPowerLaw : emittedPower.watts = resonator.emittedPower.watts

/-- The CW emission hypothesis exposes its positive drive condition. -/
lemma CWProcaEmissionHypothesis.cw_drive_positive
    (emission : CWProcaEmissionHypothesis) :
    0 < emission.resonator.drivePower.watts :=
  emission.cwDriven

/-- The CW emission hypothesis exposes its longitudinal resonator mode. -/
lemma CWProcaEmissionHypothesis.longitudinal_mode
    (emission : CWProcaEmissionHypothesis) :
    emission.resonator.mode = ResonatorMode.longitudinal :=
  emission.longitudinalMode

/-- The CW emission hypothesis exposes its frequency matching condition. -/
lemma CWProcaEmissionHypothesis.frequency_match
    (emission : CWProcaEmissionHypothesis) :
    emission.resonator.driveFrequency.hz = emission.channel.mode.frequency :=
  emission.frequencyMatch

/-- The CW emission hypothesis exposes its positive Proca mass. -/
lemma CWProcaEmissionHypothesis.massive_mode
    (emission : CWProcaEmissionHypothesis) :
    0 < emission.channel.model.mass :=
  emission.massiveMode

/-- The hypothesized emitted power is the resonator's supplied output. -/
lemma CWProcaEmissionHypothesis.emitted_power_eq
    (emission : CWProcaEmissionHypothesis) :
    emission.emittedPower.watts = emission.resonator.emittedPower.watts :=
  emission.emittedPowerLaw

/-- A candidate fracture observation built from a classical ultrasonic transfer.

An anomalous residual may motivate a fracture-state hypothesis only after the
ordinary acoustic model and its uncertainty are specified. This record does
not identify an unexplained residual with fracture. -/
structure AcousticFractureEvidence where
  transfer : Acoustics.UltrasonicTransfer
  measurement : Acoustics.TransferMeasurement
  predictedPowerLaw : measurement.predictedPower = transfer.receivedPower
  outsideClassicalTolerance : ¬measurement.consistent

/-- The candidate satisfies the explicit residual criterion for further fracture
hypothesis testing. -/
def AcousticFractureEvidence.supportsFractureHypothesis
    (evidence : AcousticFractureEvidence) : Prop :=
  ¬evidence.measurement.consistent

/-- The fracture-supporting criterion is exactly the recorded unexplained
residual condition. -/
lemma AcousticFractureEvidence.supportsFractureHypothesis_iff
    (evidence : AcousticFractureEvidence) :
    evidence.supportsFractureHypothesis ↔ ¬evidence.measurement.consistent := by
  rfl

/-- A pending communications contract joins a fracture wave to a measured link. -/
structure FractureCommunication where
  wave : FractureWave
  channel : ProcaChannel
  packetBandwidth : ℝ
  packetBandwidth_nonnegative : 0 ≤ packetBandwidth
  receiverSensitivity : ℝ
  receiverSensitivity_nonnegative : 0 ≤ receiverSensitivity
  detectable : channel.link.receivedPower ≥ receiverSensitivity

/-- The pending communications contract exposes its detectability assumption. -/
lemma FractureCommunication.detectable_condition
    (communication : FractureCommunication) :
    communication.channel.link.receivedPower ≥ communication.receiverSensitivity :=
  communication.detectable

/-- A finite WKB/Gamow barrier model with an effective metric factor. -/
structure WKBBarrier where
  properDistanceFactor : ℝ
  properDistanceFactor_nonnegative : 0 ≤ properDistanceFactor
  effectiveBarrier : ℝ
  effectiveBarrier_nonnegative : 0 ≤ effectiveBarrier
  exponent : ℝ
  exponent_nonnegative : 0 ≤ exponent
  exponentLaw : exponent =
    properDistanceFactor * Real.sqrt effectiveBarrier
  tunnelingProbability : ℝ
  probabilityLaw : tunnelingProbability = Real.exp (-2 * exponent)

/-- The WKB exponent is consistent with its supplied metric and barrier terms. -/
lemma WKBBarrier.exponent_holds (barrier : WKBBarrier) :
    barrier.exponent = barrier.properDistanceFactor * Real.sqrt barrier.effectiveBarrier :=
  barrier.exponentLaw

/-- A WKB/Gamow probability lies in `[0, 1]` under the pending barrier assumptions. -/
lemma WKBBarrier.probability_bounds (barrier : WKBBarrier) :
    0 ≤ barrier.tunnelingProbability ∧ barrier.tunnelingProbability ≤ 1 := by
  constructor
  · rw [barrier.probabilityLaw]
    exact (Real.exp_pos _).le
  · rw [barrier.probabilityLaw, ← Real.exp_zero, Real.exp_le_exp]
    nlinarith [barrier.exponent_nonnegative]

/-- A pending anti-Amplituhedron phase profile.

Negative divergence is a supplied repulsive-profile hypothesis; it is not
identified with a force or a vacuum-pressure change by this definition alone. -/
structure AntiAmplituhedronProfile where
  phaseGradient : ℝ
  phaseGradient_nonnegative : 0 ≤ phaseGradient
  divergence : ℝ
  divergent : divergence < 0
  profileWeight : ℝ
  profileWeight_nonnegative : 0 ≤ profileWeight
  pressureExpansion : ℝ
  expansionLaw : pressureExpansion = -divergence * profileWeight

/-- A divergent pending profile has nonnegative expansion in its scalar model. -/
lemma AntiAmplituhedronProfile.pressureExpansion_nonnegative
    (profile : AntiAmplituhedronProfile) :
    0 ≤ profile.pressureExpansion := by
  rw [profile.expansionLaw]
  exact mul_nonneg (neg_nonneg.mpr profile.divergent.le) profile.profileWeight_nonnegative

/-- A pending SQG vacuum-expansion record with negative effective coupling. -/
structure SQGVacuumExpansion where
  baselineCoupling : ℝ
  effectiveCoupling : ℝ
  negativeCoupling : effectiveCoupling < 0
  vacuumDensity : ℝ
  vacuumDensity_nonnegative : 0 ≤ vacuumDensity
  expansionProfile : AntiAmplituhedronProfile
  pressure : ℝ
  pressureLaw : pressure =
    vacuumDensity * expansionProfile.pressureExpansion

/-- The pending SQG expansion pressure is nonnegative under its supplied law. -/
lemma SQGVacuumExpansion.pressure_nonnegative (expansion : SQGVacuumExpansion) :
    0 ≤ expansion.pressure := by
  rw [expansion.pressureLaw]
  exact mul_nonneg expansion.vacuumDensity_nonnegative
    expansion.expansionProfile.pressureExpansion_nonnegative

/-- A pending anti-fire model with an explicit reduction hypothesis. -/
structure AntiFireSuppression where
  baselineRate : ℝ
  baselineRate_nonnegative : 0 ≤ baselineRate
  effectiveRate : ℝ
  effectiveRate_nonnegative : 0 ≤ effectiveRate
  profile : AntiAmplituhedronProfile
  suppression : effectiveRate ≤ baselineRate

/-- A pending anti-fire model records that the effective rate is no larger. -/
lemma AntiFireSuppression.effectiveRate_le_baseline
    (model : AntiFireSuppression) :
    model.effectiveRate ≤ model.baselineRate :=
  model.suppression

/-- A fusion reaction model with explicit probability and energy accounting. -/
structure FusionReaction where
  reactionProbability : ℝ
  probability_nonnegative : 0 ≤ reactionProbability
  probability_le_one : reactionProbability ≤ 1
  energyPerReaction : ℝ
  energyPerReaction_nonnegative : 0 ≤ energyPerReaction
  reactionRate : ℝ
  reactionRate_nonnegative : 0 ≤ reactionRate
  inputPower : ℝ
  inputPower_nonnegative : 0 ≤ inputPower
  outputPower : ℝ
  outputPower_nonnegative : 0 ≤ outputPower
  outputLaw : outputPower =
    energyPerReaction * reactionRate * reactionProbability

/-- A deterministic-fusion claim makes unit reaction probability explicit. -/
structure DeterministicFusionClaim where
  reaction : FusionReaction
  probabilityOne : reaction.reactionProbability = 1

/-- Under the pending deterministic claim, output follows the reaction-rate law. -/
lemma DeterministicFusionClaim.outputLaw
    (claim : DeterministicFusionClaim) :
    claim.reaction.outputPower =
      claim.reaction.energyPerReaction * claim.reaction.reactionRate := by
  rw [claim.reaction.outputLaw, claim.probabilityOne]
  ring

/-- An energy ledger with control, fuel, and explicitly declared spacetime input. -/
structure EnergyLedger where
  controlPower : ℝ
  controlPower_nonnegative : 0 ≤ controlPower
  fuelPower : ℝ
  fuelPower_nonnegative : 0 ≤ fuelPower
  spacetimePower : ℝ
  spacetimePower_nonnegative : 0 ≤ spacetimePower
  outputPower : ℝ
  outputPower_nonnegative : 0 ≤ outputPower
  lossPower : ℝ
  lossPower_nonnegative : 0 ≤ lossPower
  balance : outputPower + lossPower = controlPower + fuelPower + spacetimePower

/-- A balanced ledger cannot output more than all declared inputs. -/
lemma EnergyLedger.output_le_declared_input (ledger : EnergyLedger) :
    ledger.outputPower ≤ ledger.controlPower + ledger.fuelPower + ledger.spacetimePower := by
  nlinarith [ledger.balance, ledger.lossPower_nonnegative]

/-- An over-unity claim relative to control and fuel requires positive declared
spacetime input in the pending ledger. -/
structure SpacetimeExtractionClaim where
  ledger : EnergyLedger
  overControlAndFuel : ledger.outputPower > ledger.controlPower + ledger.fuelPower

lemma SpacetimeExtractionClaim.spacetimePower_positive
    (claim : SpacetimeExtractionClaim) :
    0 < claim.ledger.spacetimePower := by
  nlinarith [claim.ledger.balance, claim.ledger.lossPower_nonnegative,
    claim.overControlAndFuel]

end Signals.Pending
