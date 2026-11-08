import Architect
import Mathlib.Basic.Complex.Basic
import Mathlib.Data.Fin.Basic
import Mathlib.LinearAlgebra.Matrix.Notation
import Mathlib.Tactic
import Signals.Coherence
import Signals.Geometry
import Signals.Huygens
import Signals.Lasers
import Signals.OAM
import Signals.Propagation
import Signals.QISM
import Signals.Units

namespace Signals.SolitonBus

open Signals.Coherence
open Signals.Geometry
open Signals.Huygens
open Signals.Lasers
open Signals.Propagation
open Signals.QISM
open Signals.Units

/-! # Soliton-bus transport and operator contracts

The chat corpus proposes WDM, MDM, OAM, thermo-optic routing, homodyne
readout, and Kerr interactions for an N-LIG soliton bus. This module gives
those proposals finite, typed interfaces. The classical Boolean and routing
operations are executable algebra; the quantum gate layer uses explicit finite
complex matrices and amplitude-vector application. QECLean was evaluated as a
possible adapter, but its cached artifacts use a different mathlib context from
Signals, so it is not a hard dependency. Material realization, room-temperature
operation, single-photon Kerr strength, and nondestructive readout remain
explicit calibration or pending-model fields.
-/

/-! ## Classical lane addressing and routing -/

/-- A multiplex address carried by one soliton-bus lane. -/
structure LaneAddress where
  wavelengthChannel : ℕ
  spatialMode : ℕ
  oamCharge : ℤ
  polarizationChannel : ℕ
  timeSlot : ℕ
  deriving DecidableEq, Repr

/-- A physical or modeled lane in the bus. -/
structure SolitonLane where
  label : String
  address : LaneAddress
  carrierFrequency : Frequency
  carrierFrequency_pos : 0 < carrierFrequency.hz

/-- A finite bus with injective lane addresses. -/
structure BusNetwork where
  laneCount : ℕ
  laneCount_pos : 0 < laneCount
  lanes : Fin laneCount → SolitonLane
  laneAddress_injective :
    Function.Injective (fun lane => (lanes lane).address)

/-- A finite frame transported by one addressed soliton lane. -/
structure ClassicalSolitonFrame where
  address : LaneAddress
  amplitude : ℝ
  phase : ℝ
  energy : Energy
  energy_nonnegative : 0 ≤ energy.joules

/-- Optional selectors implement WDM, MDM, OAM, polarization, and TDM filters. -/
structure LaneSelector where
  wavelengthChannel : Option ℕ := none
  spatialMode : Option ℕ := none
  oamCharge : Option ℤ := none
  polarizationChannel : Option ℕ := none
  timeSlot : Option ℕ := none

/-- A selector matches exactly the enabled address dimensions. -/
def LaneSelector.matches (selector : LaneSelector) (address : LaneAddress) : Bool :=
  (match selector.wavelengthChannel with
    | none => true
    | some channel => address.wavelengthChannel == channel) &&
  (match selector.spatialMode with
    | none => true
    | some mode => address.spatialMode == mode) &&
  (match selector.oamCharge with
    | none => true
    | some charge => address.oamCharge == charge) &&
  (match selector.polarizationChannel with
    | none => true
    | some polarization => address.polarizationChannel == polarization) &&
  (match selector.timeSlot with
    | none => true
    | some slot => address.timeSlot == slot)

/-- Multiplexing dimensions represented by the lane address. -/
inductive MultiplexDimension
  | wavelengthDivision
  | modeDivision
  | orbitalAngularMomentum
  | polarizationDivision
  | timeDivision
  deriving DecidableEq, Repr

/-- The finite demultiplexer used by a selector. -/
def demultiplex (selector : LaneSelector)
    (frames : List ClassicalSolitonFrame) : List ClassicalSolitonFrame :=
  frames.filter (fun frame => selector.matches frame.address)

/-- Multiplexing is represented as concatenation of independently addressed lanes. -/
def multiplex (frames : List ClassicalSolitonFrame) : List ClassicalSolitonFrame :=
  frames

/-- A routing plan maps each source lane to one destination lane. -/
structure RoutingPlan (bus : BusNetwork) where
  destination : Fin bus.laneCount → Fin bus.laneCount
  destination_injective : Function.Injective destination

/-- Route one lane through a calibrated routing plan. -/
def routeLane {bus : BusNetwork} (plan : RoutingPlan bus)
    (source : Fin bus.laneCount) : Fin bus.laneCount :=
  plan.destination source

/-- A calibrated route cannot merge distinct source lanes. -/
lemma routeLane_injective {bus : BusNetwork} (plan : RoutingPlan bus) :
    Function.Injective plan.destination :=
  plan.destination_injective

/-- A bucket-brigade broadcast exposes every finite destination lane. -/
def broadcastLanes (bus : BusNetwork) : List (Fin bus.laneCount) :=
  List.ofFn (fun lane => lane)

/-- Select one of two bus paths using a classical control bit. -/
def mux {α : Type*} (select : Bool) (zeroPath onePath : α) : α :=
  if select then onePath else zeroPath

/-- A demultiplexer emits a value on exactly one selected output. -/
def demux {α : Type*} (select : Bool) (value : α) : Option α × Option α :=
  if select then (none, some value) else (some value, none)

/-! ## Classical complete Boolean operator basis -/

def classicalNot (bit : Bool) : Bool := !bit

def classicalNand (left right : Bool) : Bool := !(left && right)

def classicalAnd (left right : Bool) : Bool := left && right

def classicalOr (left right : Bool) : Bool := left || right

def classicalXor (left right : Bool) : Bool := left != right

def classicalXnor (left right : Bool) : Bool := !(classicalXor left right)

def classicalNor (left right : Bool) : Bool := !(left || right)

/-- NAND directly realizes NOT. -/
lemma nand_complete_not (bit : Bool) :
    classicalNand bit bit = classicalNot bit := by
  cases bit <;> rfl

/-- NAND directly realizes AND. -/
lemma nand_complete_and (left right : Bool) :
    classicalNand (classicalNand left right)
      (classicalNand left right) = classicalAnd left right := by
  cases left <;> cases right <;> rfl

/-- NAND directly realizes OR. -/
lemma nand_complete_or (left right : Bool) :
    classicalNand (classicalNand left left)
      (classicalNand right right) = classicalOr left right := by
  cases left <;> cases right <;> rfl

/-- The named classical operator inventory used by the bus controller. -/
inductive ClassicalBusOperator
  | identity
  | not
  | nand
  | and
  | or
  | xor
  | xnor
  | nor
  deriving DecidableEq, Repr

/-- Apply a classical operator to a finite Boolean argument list. -/
def ClassicalBusOperator.apply : ClassicalBusOperator → List Bool → Option Bool
  | ClassicalBusOperator.identity, [bit] => some bit
  | ClassicalBusOperator.not, [bit] => some (classicalNot bit)
  | ClassicalBusOperator.nand, [left, right] => some (classicalNand left right)
  | ClassicalBusOperator.and, [left, right] => some (classicalAnd left right)
  | ClassicalBusOperator.or, [left, right] => some (classicalOr left right)
  | ClassicalBusOperator.xor, [left, right] => some (classicalXor left right)
  | ClassicalBusOperator.xnor, [left, right] => some (classicalXnor left right)
  | ClassicalBusOperator.nor, [left, right] => some (classicalNor left right)
  | _, _ => none

/-- The operator inventory contains a functionally complete NAND basis. -/
def completeClassicalBusOperators : List ClassicalBusOperator :=
  [ClassicalBusOperator.identity, ClassicalBusOperator.not,
    ClassicalBusOperator.nand, ClassicalBusOperator.and,
    ClassicalBusOperator.or, ClassicalBusOperator.xor,
    ClassicalBusOperator.xnor, ClassicalBusOperator.nor]

lemma completeClassicalBusOperators_count :
    completeClassicalBusOperators.length = 8 := by
  rfl

/-! ## Finite quadrature operators -/

/-- A finite phase-space point used for the CV soliton approximation. -/
structure QuadraturePoint where
  q : ℝ
  p : ℝ

/-- Rotation in the finite $(q,p)$ phase plane. -/
noncomputable def rotateQuadrature (angle : ℝ) (point : QuadraturePoint) : QuadraturePoint :=
  { q := point.q * Real.cos angle - point.p * Real.sin angle
    p := point.q * Real.sin angle + point.p * Real.cos angle }

/-- A phase-space displacement. -/
def displaceQuadrature (delta : QuadraturePoint) (point : QuadraturePoint) :
    QuadraturePoint :=
  { q := point.q + delta.q
    p := point.p + delta.p }

/-- A finite squeezing map with reciprocal quadrature scales. -/
noncomputable def squeezeQuadrature (squeeze : ℝ) (point : QuadraturePoint) : QuadraturePoint :=
  { q := Real.exp squeeze * point.q
    p := Real.exp (-squeeze) * point.p }

/-- A balanced two-mode beam splitter on finite quadratures. -/
noncomputable def balancedBeamSplitter (left right : QuadraturePoint) :
    QuadraturePoint × QuadraturePoint :=
  ( { q := (left.q + right.q) / Real.sqrt 2
      p := (left.p + right.p) / Real.sqrt 2 },
    { q := (left.q - right.q) / Real.sqrt 2
      p := (left.p - right.p) / Real.sqrt 2 } )

/-- A finite Kerr phase shift, kept as a calibrated nonlinear model. -/
def kerrPhaseShift (coupling amplitude : ℝ) : ℝ :=
  coupling * amplitude ^ 2

/-- Cross-phase modulation of a probe by a signal soliton. -/
noncomputable def crossPhaseModulate (coupling : ℝ) (signal probe : QuadraturePoint) :
    QuadraturePoint :=
  rotateQuadrature (kerrPhaseShift coupling signal.q) probe

/-! ## Scholarly propagation dynamics -/

/-- Propagation lengths and soliton-order data for a finite NLSE contract. -/
structure SolitonPropagationDynamics where
  pulseDuration : Duration
  pulseDuration_pos : 0 < pulseDuration.seconds
  peakPower : Power
  peakPower_pos : 0 < peakPower.watts
  groupVelocityDispersion : ℝ
  groupVelocityDispersion_anomalous : groupVelocityDispersion < 0
  nonlinearCoefficient : ℝ
  nonlinearCoefficient_pos : 0 < nonlinearCoefficient
  dispersionLength : Length
  dispersionLength_pos : 0 < dispersionLength.meters
  nonlinearLength : Length
  nonlinearLength_pos : 0 < nonlinearLength.meters
  solitonOrderSquared : ℝ
  solitonOrderSquared_pos : 0 < solitonOrderSquared
  dispersionLengthLaw :
    dispersionLength.meters =
      pulseDuration.seconds ^ 2 / |groupVelocityDispersion|
  nonlinearLengthLaw :
    nonlinearLength.meters =
      1 / (nonlinearCoefficient * peakPower.watts)
  solitonOrderSquaredLaw :
    solitonOrderSquared = dispersionLength.meters / nonlinearLength.meters
  fissionLength : Option Length
  selfCompressionObserved : Prop
  selfCompressionObserved_hypothesis : selfCompressionObserved
  dispersiveWaveObserved : Prop
  dispersiveWaveObserved_hypothesis : dispersiveWaveObserved
  evidenceStatus : LaserEvidenceStatus

lemma SolitonPropagationDynamics.dispersion_length_holds
    (dynamics : SolitonPropagationDynamics) :
    dynamics.dispersionLength.meters =
      dynamics.pulseDuration.seconds ^ 2 /
        |dynamics.groupVelocityDispersion| :=
  dynamics.dispersionLengthLaw

lemma SolitonPropagationDynamics.nonlinear_length_holds
    (dynamics : SolitonPropagationDynamics) :
    dynamics.nonlinearLength.meters =
      1 / (dynamics.nonlinearCoefficient * dynamics.peakPower.watts) :=
  dynamics.nonlinearLengthLaw

lemma SolitonPropagationDynamics.soliton_order_squared_holds
    (dynamics : SolitonPropagationDynamics) :
    dynamics.solitonOrderSquared =
      dynamics.dispersionLength.meters / dynamics.nonlinearLength.meters :=
  dynamics.solitonOrderSquaredLaw

/-- Two co-propagating pulses with a calibrated cross-phase collision law. -/
structure SolitonCollisionDynamics where
  signalAddress : LaneAddress
  probeAddress : LaneAddress
  effectiveInteractionLength : Length
  effectiveInteractionLength_pos : 0 < effectiveInteractionLength.meters
  signalPower : Power
  signalPower_nonnegative : 0 ≤ signalPower.watts
  probePower : Power
  probePower_nonnegative : 0 ≤ probePower.watts
  /-- Includes the convention-dependent XPM factor and modal overlap. -/
  xpmCoefficient : ℝ
  xpmCoefficient_nonnegative : 0 ≤ xpmCoefficient
  xpmPhaseShift : ℝ
  xpmPhaseShiftLaw :
    xpmPhaseShift =
      xpmCoefficient * signalPower.watts * effectiveInteractionLength.meters
  collisionObserved : Prop
  collisionObserved_hypothesis : collisionObserved
  crosstalkFraction : BoundedFactor
  evidenceStatus : LaserEvidenceStatus

lemma SolitonCollisionDynamics.xpm_phase_shift_holds
    (collision : SolitonCollisionDynamics) :
    collision.xpmPhaseShift =
      collision.xpmCoefficient * collision.signalPower.watts *
        collision.effectiveInteractionLength.meters :=
  collision.xpmPhaseShiftLaw

/-- Long-haul OAM/MDM transmission data with measured crosstalk controls. -/
structure OAMMultiplexingObservation where
  fiberLength : Length
  fiberLength_pos : 0 < fiberLength.meters
  modeGroupCount : ℕ
  modeGroupCount_pos : 0 < modeGroupCount
  symbolRate : Frequency
  symbolRate_pos : 0 < symbolRate.hz
  dataRateGbps : ℝ
  dataRateGbps_pos : 0 < dataRateGbps
  modeCrosstalk : BoundedFactor
  equalizerOrder : ℕ
  equalizerOrder_pos : 0 < equalizerOrder
  transmissionObserved : Prop
  transmissionObserved_hypothesis : transmissionObserved
  evidenceStatus : LaserEvidenceStatus

/-- Operators can act inside the bus, at a bus interface, or off the bus. -/
inductive SolitonOperatorPlacement
  | onBus
  | busInterface
  | offBus
  deriving DecidableEq, Repr

inductive SolitonDynamicsOperator
  | linearPropagation
  | selfPhaseModulation
  | crossPhaseModulation
  | solitonSelfCompression
  | resonantDispersiveWave
  | oamModeCoupling
  | homodyneReadout
  | parityMeasurement
  deriving DecidableEq, Repr

def SolitonDynamicsOperator.defaultPlacement :
    SolitonDynamicsOperator → SolitonOperatorPlacement
  | SolitonDynamicsOperator.linearPropagation => SolitonOperatorPlacement.onBus
  | SolitonDynamicsOperator.selfPhaseModulation => SolitonOperatorPlacement.onBus
  | SolitonDynamicsOperator.crossPhaseModulation => SolitonOperatorPlacement.onBus
  | SolitonDynamicsOperator.solitonSelfCompression =>
      SolitonOperatorPlacement.onBus
  | SolitonDynamicsOperator.resonantDispersiveWave =>
      SolitonOperatorPlacement.busInterface
  | SolitonDynamicsOperator.oamModeCoupling => SolitonOperatorPlacement.onBus
  | SolitonDynamicsOperator.homodyneReadout => SolitonOperatorPlacement.offBus
  | SolitonDynamicsOperator.parityMeasurement =>
      SolitonOperatorPlacement.busInterface

/-! ## Finite qubit operators on the bus -/

abbrev QubitBasis : Type := Fin 2
abbrev TwoQubitBasis : Type := QubitBasis × QubitBasis
abbrev ThreeQubitBasis : Type := QubitBasis × QubitBasis × QubitBasis
/- These aliases are finite operators. The one-qubit inventory below carries
unitary proofs; multi-qubit matrices remain explicit operator data until their
permutation-unitarity lemmas are added. -/
abbrev OneQubitGate : Type := Matrix QubitBasis QubitBasis ℂ
abbrev TwoQubitGate : Type := Matrix TwoQubitBasis TwoQubitBasis ℂ
abbrev ThreeQubitGate : Type := Matrix ThreeQubitBasis ThreeQubitBasis ℂ

/-- The finite matrix criterion used for unitary gate checks. -/
def isUnitaryMatrix {α : Type*} [Fintype α] [DecidableEq α]
    (matrix : Matrix α α ℂ) : Prop :=
  matrix * star matrix = 1

/-- A unit-modulus complex phase used by parameterized phase gates. -/
structure UnitPhase where
  value : ℂ
  unit : value * star value = 1

def unitPhaseOne : UnitPhase :=
  { value := 1, unit := by simp }

def unitPhaseI : UnitPhase :=
  { value := Complex.I, unit := by simp [Complex.conj_I, Complex.I_mul_I] }

def unitPhaseNegOne : UnitPhase :=
  { value := -1, unit := by simp }

/-- A diagonal one-qubit phase gate. -/
def phaseGate (phase : UnitPhase) : OneQubitGate :=
  !![1, 0; 0, phase.value]

def xMatrix : Matrix QubitBasis QubitBasis ℂ := !![0, 1; 1, 0]

def yMatrix : Matrix QubitBasis QubitBasis ℂ :=
  !![0, -Complex.I; Complex.I, 0]

def zMatrix : Matrix QubitBasis QubitBasis ℂ := !![1, 0; 0, -1]

noncomputable def hMatrix : Matrix QubitBasis QubitBasis ℂ :=
  (1 / Real.sqrt 2) • !![1, 1; 1, -1]

def xGate : OneQubitGate := xMatrix

def yGate : OneQubitGate := yMatrix

def zGate : OneQubitGate := zMatrix

noncomputable def hGate : OneQubitGate := hMatrix

lemma phaseGate_unitary (phase : UnitPhase) :
    isUnitaryMatrix (phaseGate phase) := by
  unfold isUnitaryMatrix phaseGate
  ext row column
  fin_cases row <;> fin_cases column
  · norm_num [Matrix.mul_apply]
  · norm_num [Matrix.mul_apply]
  · norm_num [Matrix.mul_apply]
  · norm_num [Matrix.mul_apply]
    simpa only [starRingEnd_apply] using phase.unit

lemma xGate_unitary : isUnitaryMatrix xGate := by
  unfold isUnitaryMatrix xGate xMatrix
  ext row column
  fin_cases row <;> fin_cases column <;>
    simp [Matrix.mul_apply]

lemma yGate_unitary : isUnitaryMatrix yGate := by
  unfold isUnitaryMatrix yGate yMatrix
  ext row column
  fin_cases row <;> fin_cases column <;>
    simp [Matrix.mul_apply]

lemma zGate_unitary : isUnitaryMatrix zGate := by
  unfold isUnitaryMatrix zGate zMatrix
  ext row column
  fin_cases row <;> fin_cases column <;>
    simp [Matrix.mul_apply]

lemma hGate_unitary : isUnitaryMatrix hGate := by
  unfold isUnitaryMatrix hGate hMatrix
  ext row column
  fin_cases row <;> fin_cases column <;>
    simp [Matrix.mul_apply]
  all_goals
    have hsqrt : (Real.sqrt (2 : ℝ)) ^ 2 = 2 := by norm_num
    have hsqrtComplex : (Real.sqrt (2 : ℝ) : ℂ) ^ 2 = 2 := by
      exact_mod_cast hsqrt
    field_simp
    rw [hsqrtComplex]
    norm_num

/-! ### Permutation gates -/

def flipBit (bit : QubitBasis) : QubitBasis :=
  if bit = 0 then 1 else 0

lemma flipBit_involutive : Function.Involutive flipBit := by
  intro bit
  fin_cases bit <;> simp [flipBit]

def cnotMap : TwoQubitBasis → TwoQubitBasis
  | (control, target) =>
      if control = 0 then (control, target) else (control, flipBit target)

lemma cnotMap_involutive : Function.Involutive cnotMap := by
  intro pair
  rcases pair with ⟨control, target⟩
  fin_cases control <;> fin_cases target <;> simp [cnotMap, flipBit]

def swapMap : TwoQubitBasis → TwoQubitBasis
  | (left, right) => (right, left)

lemma swapMap_involutive : Function.Involutive swapMap := by
  intro pair
  rcases pair with ⟨left, right⟩
  rfl

def toffoliMap : ThreeQubitBasis → ThreeQubitBasis
  | (controlOne, (controlTwo, target)) =>
      if controlOne = 1 ∧ controlTwo = 1 then
        (controlOne, (controlTwo, flipBit target))
      else
        (controlOne, (controlTwo, target))

lemma toffoliMap_involutive : Function.Involutive toffoliMap := by
  intro triple
  rcases triple with ⟨controlOne, controlTwo, target⟩
  fin_cases controlOne <;> fin_cases controlTwo <;> fin_cases target <;>
    simp [toffoliMap, flipBit]

def cnotGate : TwoQubitGate :=
  fun row column =>
    if row.1 = column.1 then
      if row.1 = 0 then
        if row.2 = column.2 then 1 else 0
      else if row.2 = flipBit column.2 then 1 else 0
    else 0

def swapGate : TwoQubitGate :=
  fun row column =>
    if row.1 = column.2 ∧ row.2 = column.1 then 1 else 0

def toffoliGate : ThreeQubitGate :=
  fun row column =>
    if row.1 = column.1 ∧ row.2.1 = column.2.1 then
      if row.1 = 1 ∧ row.2.1 = 1 then
        if row.2.2 = flipBit column.2.2 then 1 else 0
      else if row.2.2 = column.2.2 then 1 else 0
    else 0

/-- One-qubit generators available to a soliton bus. -/
inductive OneQubitBusGate
  | identity
  | pauliX
  | pauliY
  | pauliZ
  | hadamard
  | balancedBeamSplitter
  | phase (phase : UnitPhase)

noncomputable def OneQubitBusGate.toGate : OneQubitBusGate → OneQubitGate
  | OneQubitBusGate.identity => phaseGate unitPhaseOne
  | OneQubitBusGate.pauliX => xGate
  | OneQubitBusGate.pauliY => yGate
  | OneQubitBusGate.pauliZ => zGate
  | OneQubitBusGate.hadamard => hGate
  | OneQubitBusGate.balancedBeamSplitter => hGate
  | OneQubitBusGate.phase phaseValue => phaseGate phaseValue

/-- Two-qubit generators available to a soliton bus. -/
inductive TwoQubitBusGate
  | cnot
  | swap
  | controlledPhase (phase : UnitPhase)

def controlledPhaseGate (phase : UnitPhase) : TwoQubitGate :=
  fun row column =>
    if row = column then
      if row = (1, 1) then phase.value else 1
    else
      0

def TwoQubitBusGate.toGate : TwoQubitBusGate → TwoQubitGate
  | TwoQubitBusGate.cnot => cnotGate
  | TwoQubitBusGate.swap => swapGate
  | TwoQubitBusGate.controlledPhase phase => controlledPhaseGate phase

/-- Apply a finite unitary gate to a complex amplitude vector. -/
def applyGate {α : Type*} [Fintype α] [DecidableEq α]
    (gate : Matrix α α ℂ) (state : α → ℂ) : α → ℂ :=
  Matrix.mulVec gate state

/-- Apply a one-qubit bus gate to a finite amplitude vector. -/
noncomputable def applyOneQubitGate (gate : OneQubitBusGate)
    (state : QubitBasis → ℂ) : QubitBasis → ℂ :=
  applyGate gate.toGate state

/-- Apply a two-qubit bus gate to a finite amplitude vector. -/
noncomputable def applyTwoQubitGate (gate : TwoQubitBusGate)
    (state : TwoQubitBasis → ℂ) : TwoQubitBasis → ℂ :=
  applyGate gate.toGate state

/-- Apply the three-qubit Toffoli gate to a finite amplitude vector. -/
noncomputable def applyToffoli (state : ThreeQubitBasis → ℂ) :
    ThreeQubitBasis → ℂ :=
  applyGate toffoliGate state

/-- A finite standard-generator inventory for qubit soliton processing. -/
def completeQuantumBusGenerators : List OneQubitBusGate :=
  [OneQubitBusGate.identity, OneQubitBusGate.pauliX,
    OneQubitBusGate.pauliY, OneQubitBusGate.pauliZ,
    OneQubitBusGate.hadamard, OneQubitBusGate.balancedBeamSplitter,
    OneQubitBusGate.phase unitPhaseI]

lemma completeQuantumBusGenerators_count :
    completeQuantumBusGenerators.length = 7 := by
  rfl

lemma OneQubitBusGate.unitary (gate : OneQubitBusGate) :
    isUnitaryMatrix gate.toGate := by
  cases gate with
  | identity => exact phaseGate_unitary unitPhaseOne
  | pauliX => exact xGate_unitary
  | pauliY => exact yGate_unitary
  | pauliZ => exact zGate_unitary
  | hadamard => exact hGate_unitary
  | balancedBeamSplitter => exact hGate_unitary
  | phase phaseValue => exact phaseGate_unitary phaseValue

/-! ## Conditional nonlinear interactions -/

/-- Interaction classes found in the soliton-bus proposals. -/
inductive SolitonInteractionKind
  | linearSuperposition
  | modeExchange
  | crossPhaseModulation
  | kerrNonlinearity
  | controlledPhase
  | homodyneProbe
  | parityReadout
  deriving DecidableEq, Repr

/-- Evidence-bound contract for a nonlinear or readout interaction. -/
structure InteractionContract where
  kind : SolitonInteractionKind
  couplingStrength : ℝ
  couplingStrength_nonnegative : 0 ≤ couplingStrength
  phaseShift : ℝ
  phaseShiftLaw : phaseShift = kerrPhaseShift couplingStrength 1
  nonabsorptive : Prop
  nonabsorptive_hypothesis : nonabsorptive
  evidenceStatus : LaserEvidenceStatus

/-- Parity of a finite Boolean payload, suitable for a classical syndrome path. -/
def parity (payload : List Bool) : Bool :=
  payload.foldl classicalXor false

lemma parity_empty : parity [] = false := by
  rfl

/-- A chat-proposed nondestructive parity contract keeps the probe phase explicit. -/
structure NondestructiveParityContract where
  signalAddress : LaneAddress
  probeAddress : LaneAddress
  measuredParity : Bool
  probePhaseShift : ℝ
  primaryPayloadPreserved : Prop
  primaryPayloadPreserved_hypothesis : primaryPayloadPreserved
  evidenceStatus : LaserEvidenceStatus

/-! ## Multi-lane ($N > 0$) soliton-bus interferometric coupler, $Gr_{\mathbb{C}}(2,4)$ twistor channels, and QISM collision invariants -/

/-- A multi-lane ($N > 0$) soliton-bus interferometric coupler and OAM grating
demultiplexer parameterized by lane count `numLanes > 0`, lane aperture width
`laneWidth`, lane height `laneHeight`, center-to-center waveguide pitch
`laneSeparation`, wavelength, coupler propagation distance, Qian--Izadi /
Pluecker barycentric power-imbalance shift `barycentricShift`, visibility,
non-equilibrium Pilot-Wave residual, Wigner spatial/rotational decoherence rates,
and differential OAM topological charge step `deltaOAM`. -/
@[blueprint "def:signals-soliton-multi-lane-coupler"
  (title := "Multi-lane (N > 0) soliton-bus interferometric coupler and OAM demultiplexer")
  (statement := /-- A multi-lane ($N>0$) soliton-bus coupler record storing lane count $N>0$,
    lane width $a>0$, lane height $b>0$, waveguide pitch $d>0$, wavelength $\lambda>0$,
    coupler distance $L>0$, barycentric lane-imbalance shift $d_{\mathrm{bary}}\in[-1,1]$,
    visibility $\mathcal{V}\in[0,1]$, Pilot-Wave residual $\delta_{\mathrm{neq}}$,
    Wigner decoherence rates $\gamma_{\mathrm{dec}},\gamma_{\mathrm{OAM}}\ge 0$, and
    differential OAM charge $\Delta\ell\in\mathbb Z$. -/)]
structure SolitonMultiLaneCoupler where
  numLanes : ℕ
  numLanes_pos : 0 < numLanes
  singleLaneScale : ℝ
  singleLaneScale_pos : 0 < singleLaneScale
  laneWidth : ℝ
  laneWidth_pos : 0 < laneWidth
  laneHeight : ℝ
  laneHeight_pos : 0 < laneHeight
  laneSeparation : ℝ
  laneSeparation_pos : 0 < laneSeparation
  wavelength : ℝ
  wavelength_pos : 0 < wavelength
  couplerLength : ℝ
  couplerLength_pos : 0 < couplerLength
  barycentricShift : ℝ
  barycentricShift_lower : -1 ≤ barycentricShift
  barycentricShift_upper : barycentricShift ≤ 1
  visibility : ℝ
  visibility_nonneg : 0 ≤ visibility
  visibility_le_one : visibility ≤ 1
  nonEquilibriumResidual : ℝ
  decoherenceRate : ℝ
  decoherenceRate_nonneg : 0 ≤ decoherenceRate
  oamDecoherenceRate : ℝ
  oamDecoherenceRate_nonneg : 0 ≤ oamDecoherenceRate
  deltaOAM : ℤ

/-- Coherent $N$-lane Fraunhofer coupler output intensity at $(x, y, \phi)$. -/
@[blueprint "def:signals-soliton-coupler-fraunhofer-intensity"
  (title := "Coherent N-lane Fraunhofer soliton-coupler output intensity")
  (statement := /-- Evaluate the coherent $N$-lane Fraunhofer intensity
    \texttt{fraunhoferMultiSlit} for a \texttt{SolitonMultiLaneCoupler}. -/)]
noncomputable def SolitonMultiLaneCoupler.fraunhoferIntensity
    (coupler : SolitonMultiLaneCoupler) (azimuthPhi x y : ℝ) : ℝ :=
  fraunhoferMultiSlit coupler.numLanes
    coupler.singleLaneScale coupler.laneWidth coupler.laneHeight
    coupler.laneSeparation coupler.wavelength coupler.couplerLength
    coupler.deltaOAM azimuthPhi x y

/-- Partially coherent $N$-lane Huygens--Steiner / Qian--Izadi coupler output intensity. -/
@[blueprint "def:signals-soliton-coupler-huygens-steiner-intensity"
  (title := "Huygens--Steiner N-lane soliton-coupler output intensity")
  (statement := /-- Evaluate the $N$-lane Huygens--Steiner intensity
    \texttt{huygensSteinerMultiSlit} with visibility $\mathcal{V}$ for a
    \texttt{SolitonMultiLaneCoupler}. -/)]
noncomputable def SolitonMultiLaneCoupler.huygensSteinerIntensity
    (coupler : SolitonMultiLaneCoupler) (azimuthPhi x y : ℝ) : ℝ :=
  huygensSteinerMultiSlit coupler.numLanes
    coupler.singleLaneScale coupler.laneWidth coupler.laneHeight
    coupler.laneSeparation coupler.wavelength coupler.couplerLength
    coupler.visibility coupler.deltaOAM azimuthPhi x y

/-- Single-lane ($N = 1$) soliton-bus coupler output reduces identically to the
single-waveguide diffraction envelope $I_0 E_{\mathrm{slit}}(x, y)$. -/
@[blueprint "lem:signals-soliton-coupler-single-lane"
  (title := "Single-lane (N = 1) soliton-coupler envelope reduction")
  (statement := /-- When \texttt{coupler.numLanes = 1},
    \texttt{coupler.huygensSteinerIntensity} equals $I_0 E_{\mathrm{slit}}(x,y)$. -/)
  (proof := /-- Substitute \texttt{h\_one} and apply \texttt{huygensSteinerMultiSlit\_one\_slit}. -/)
  (latexEnv := "lemma")]
lemma SolitonMultiLaneCoupler.singleLane_intensity
    (coupler : SolitonMultiLaneCoupler) (h_one : coupler.numLanes = 1)
    (azimuthPhi x y : ℝ) :
    coupler.huygensSteinerIntensity azimuthPhi x y =
      coupler.singleLaneScale *
        rectangularSlitEnvelope coupler.laneWidth coupler.laneHeight
          coupler.wavelength coupler.couplerLength x y := by
  unfold SolitonMultiLaneCoupler.huygensSteinerIntensity
  rw [h_one]
  exact huygensSteinerMultiSlit_one_slit
    coupler.singleLaneScale coupler.laneWidth coupler.laneHeight
    coupler.laneSeparation coupler.wavelength coupler.couplerLength
    coupler.visibility coupler.deltaOAM azimuthPhi x y

/-- Dual-lane ($N = 2$) soliton-bus coupler output coincides identically with
`huygensSteinerOAMDoubleSlit`. -/
@[blueprint "thm:signals-soliton-coupler-dual-lane"
  (title := "Dual-lane (N = 2) soliton-coupler equivalence to Huygens--Steiner OAM double-slit")
  (statement := /-- When \texttt{coupler.numLanes = 2},
    \texttt{coupler.huygensSteinerIntensity} equals \texttt{huygensSteinerOAMDoubleSlit}. -/)
  (proof := /-- Substitute \texttt{h\_two} and apply
    \texttt{huygensSteinerMultiSlit\_two\_slits\_eq\_huygensSteinerOAM}. -/)]
theorem SolitonMultiLaneCoupler.dualLane_intensity_eq_huygensSteinerOAM
    (coupler : SolitonMultiLaneCoupler) (h_two : coupler.numLanes = 2)
    (azimuthPhi x y : ℝ) :
    coupler.huygensSteinerIntensity azimuthPhi x y =
      huygensSteinerOAMDoubleSlit
        coupler.singleLaneScale coupler.laneWidth coupler.laneHeight
        coupler.laneSeparation coupler.wavelength coupler.couplerLength
        coupler.visibility coupler.deltaOAM azimuthPhi x y := by
  unfold SolitonMultiLaneCoupler.huygensSteinerIntensity
  rw [h_two]
  exact huygensSteinerMultiSlit_two_slits_eq_huygensSteinerOAM
    coupler.singleLaneScale coupler.laneWidth coupler.laneHeight
    coupler.laneSeparation coupler.wavelength coupler.couplerLength
    coupler.visibility coupler.deltaOAM azimuthPhi x y

/-- **Complex $Gr_{\mathbb{C}}(2, 4)$ Twistor Representation of a Dual-Lane OAM Soliton Coupler**:
For any dual-lane soliton coupler with barycentric lane-imbalance shift
$d_{\mathrm{bary}} = \text{coupler.barycentricShift} \in [-1, 1]$, encoding the
two OAM lane amplitudes in `complexGr24ChannelMatrix z1 z2` with
$z_{1,2} = \sqrt{1 \pm d_{\mathrm{bary}}}\,e^{\pm i(\theta + \Delta\ell\,\phi/2)}$
reproduces the Huygens--Steiner OAM coupler output with visibility
$\mathcal{V} = \sqrt{1 - d_{\mathrm{bary}}^2}$ identically across all $(x, y, \phi)$,
with zero relative predictive error. -/
@[blueprint "thm:signals-soliton-coupler-complex-gr24"
  (title := "Complex Gr_C(2,4) twistor crossing-minor equivalence for dual-lane OAM soliton couplers")
  (statement := /-- For any \texttt{SolitonMultiLaneCoupler}, encoding the dual-rail OAM
    amplitudes $z_{1,2}=\sqrt{1\pm d_{\mathrm{bary}}}(\cos\theta_{\mathrm{OAM}}\pm i\sin\theta_{\mathrm{OAM}})$
    in $M_{\mathbb C}(z_1,z_2)$ reproduces
    $I_{\mathrm{HS,OAM}}\bigl(x,y,\phi;\Delta\ell,\sqrt{1-d_{\mathrm{bary}}^2}\bigr)$ with zero
    relative predictive error everywhere. -/)
  (proof := /-- Apply \texttt{complexGr24CrossingDoubleSlit\_oam\_barycentric\_eq\_huygensSteinerOAM}
    with \texttt{coupler.barycentricShift\_lower} and \texttt{coupler.barycentricShift\_upper}. -/)]
theorem SolitonMultiLaneCoupler.dualLane_complexGr24_eq_huygensSteinerOAM
    (coupler : SolitonMultiLaneCoupler) (azimuthPhi x y : ℝ) :
    let θ := Real.pi * coupler.laneSeparation * x /
        (coupler.wavelength * coupler.couplerLength) +
      (coupler.deltaOAM : ℝ) * azimuthPhi / 2
    let a := Real.sqrt (1 + coupler.barycentricShift)
    let b := Real.sqrt (1 - coupler.barycentricShift)
    let z1 : ℂ := ↑(a * Real.cos θ) + Complex.I * ↑(a * Real.sin θ)
    let z2 : ℂ := ↑(b * Real.cos θ) - Complex.I * ↑(b * Real.sin θ)
    complexGr24CrossingDoubleSlit (complexGr24ChannelMatrix z1 z2)
        coupler.singleLaneScale coupler.laneWidth coupler.laneHeight
        coupler.wavelength coupler.couplerLength x y =
      huygensSteinerOAMDoubleSlit
        coupler.singleLaneScale coupler.laneWidth coupler.laneHeight
        coupler.laneSeparation coupler.wavelength coupler.couplerLength
        (Real.sqrt (1 - coupler.barycentricShift ^ 2))
        coupler.deltaOAM azimuthPhi x y ∧
    relativePredictiveError
      (complexGr24CrossingDoubleSlit (complexGr24ChannelMatrix z1 z2)
        coupler.singleLaneScale coupler.laneWidth coupler.laneHeight
        coupler.wavelength coupler.couplerLength x y)
      (huygensSteinerOAMDoubleSlit
        coupler.singleLaneScale coupler.laneWidth coupler.laneHeight
        coupler.laneSeparation coupler.wavelength coupler.couplerLength
        (Real.sqrt (1 - coupler.barycentricShift ^ 2))
        coupler.deltaOAM azimuthPhi x y) = 0 :=
  complexGr24CrossingDoubleSlit_oam_barycentric_eq_huygensSteinerOAM
    coupler.singleLaneScale coupler.laneWidth coupler.laneHeight
    coupler.laneSeparation coupler.wavelength coupler.couplerLength
    coupler.barycentricShift coupler.deltaOAM azimuthPhi x y
    coupler.barycentricShift_lower coupler.barycentricShift_upper

/-- **Three-Soliton Collision Order Independence & Baxter $TQ$ Invariance on the Bus**:
When three soliton lanes with spectral rapidities $(u, v, w)$ and coupling $\eta$
collide pairwise in an integrable NLSE / Yangian interaction zone, the $8 \times 8$
three-mode scattering product satisfies the Quantum Yang--Baxter Equation
$R_{12}(u-v;\eta)\,R_{13}(u-w;\eta)\,R_{23}(v-w;\eta) =
R_{23}(v-w;\eta)\,R_{13}(u-w;\eta)\,R_{12}(u-v;\eta)$ and the three-point
Casorati Wronskians on $Gr(2,4)$ satisfy Baxter's $TQ$ difference equation identically. -/
@[blueprint "thm:signals-soliton-three-waveguide-yang-baxter"
  (title := "Three-soliton Yang--Baxter collision order independence and Gr(2,4) Baxter TQ invariance")
  (statement := /-- For any soliton rapidities $u,v,w\in\mathbb R$, coupling $\eta\in\mathbb R$,
    and Baxter pair $(Q_+,Q_-)$, the $8\times 8$ three-mode scattering matrices satisfy
    $R_{12}(u-v)R_{13}(u-w)R_{23}(v-w)=R_{23}(v-w)R_{13}(u-w)R_{12}(u-v)$ and the
    three-point Casorati Wronskian $TQ$ residual vanishes identically. -/)
  (proof := /-- Combine \texttt{Signals.QISM.yang\_baxter\_equation\_matrix8} and
    \texttt{Signals.QISM.baxterTQResidual\_wronskian\_zero}. -/)]
theorem solitonThreeWaveguide_yang_baxter_consistency
    (u v w η : ℝ) (Q_plus Q_minus : ℝ → ℝ) :
    yangR12_8 (spectralDiff u v) η * yangR13_8 (spectralDiff u w) η *
        yangR23_8 (spectralDiff v w) η =
      yangR23_8 (spectralDiff v w) η * yangR13_8 (spectralDiff u w) η *
        yangR12_8 (spectralDiff u v) η ∧
    baxterTQResidual
      (casoratiWronskian Q_plus Q_minus (u - η) (u + η))
      (casoratiWronskian Q_plus Q_minus u (u + η))
      (casoratiWronskian Q_plus Q_minus (u - η) u)
      (Q_plus u) (Q_plus (u - η)) (Q_plus (u + η)) = 0 :=
  ⟨yang_baxter_equation_matrix8 u v w η,
    baxterTQResidual_wronskian_zero Q_plus Q_minus u η⟩

/-! ## Revised Semi-Dirac Soliton Bus, Slow-Light CROW Delay Lines, Tiered 128-to-64-Bit RDMA LUT-CORDIC QRAM, and Integrated Multi-Band ($405\text{–}1550\text{ nm}$) CNC / $c\text{-BAs}$ Photonics -/

/-- **$\mathrm{CO}_2$-Carbonate $\chi^{(3)}$-Enhanced Cross-Phase Modulation (`CPHASE` / `CNOT`) Interaction Length**:
$$L_{\mathrm{CPHASE}}(\lambda, n_2, I_{\mathrm{ctrl}}) = \frac{\lambda}{2\,n_2\,I_{\mathrm{ctrl}}}.$$
Introducing Direct-Air-Captured $\mathrm{CO}_2$ carbonate bridges ($-\text{O–CO–O}-$) during laser
induction increases $n_2$ by $5\times$ (`_Quantum Computing Hardware Architectures Review  .myst.md`,
Prompts 7 & 13), shrinking $L_{\mathrm{CPHASE}}$ by $5\times$ ($80\%$ reduction in gate length/power). -/
@[blueprint "def:signals-soliton-co2-carbonate-cphase-length"
  (title := "CO₂-carbonate χ^(3) CPHASE / CNOT interaction length λ / (2 n_2 I_ctrl)")
  (statement := /-- Define $\operatorname{co2CarbonateChi3CphaseLength}(\lambda, n_2, I_{\mathrm{ctrl}})
    = \lambda / (2 n_2 I_{\mathrm{ctrl}})$. -/)]
noncomputable def co2CarbonateChi3CphaseLength (lambda n2 i_ctrl : ℝ) : ℝ :=
  lambda / (2 * n2 * i_ctrl)

/-- **Slow-Light `N-LIG` CROW (Coupled Resonator Optical Waveguide) Physical Buffer Length**:
$$L_{\mathrm{CROW}}(N_{\mathrm{cycles}}, f_{\mathrm{clk}}, c_0, n_g) = \left(\frac{N_{\mathrm{cycles}}}{f_{\mathrm{clk}}}\right)\left(\frac{c_0}{n_g}\right).$$
Buffers an incoming soliton while the 64-bit LUT-CORDIC decoder computes the `rGO` phase map
(`_Quantum Computing Hardware Architectures Review  .myst.md`, Prompt 18, lines 1765–1790). -/
@[blueprint "def:signals-soliton-crow-slow-light-delay-length"
  (title := "Slow-light N-LIG CROW optical delay buffer length (N_cycles / f_clk) * (c_0 / n_g)")
  (statement := /-- Define $\operatorname{crowSlowLightDelayLength}(N_{\mathrm{cycles}}, f_{\mathrm{clk}}, c_0, n_g)
    = (N_{\mathrm{cycles}} / f_{\mathrm{clk}}) \cdot (c_0 / n_g)$. -/)]
noncomputable def crowSlowLightDelayLength (cycles f_clk_ghz c_m_per_ns n_group : ℝ) : ℝ :=
  (cycles / f_clk_ghz) * (c_m_per_ns / n_group)

/-- **Tiered 128-Bit Inter-Node QNIC to 64-Bit Intra-QPU RDMA Payload Bit Width**:
Strips the 64-bit room-temperature QNIC header (32-bit Rack/Wafer ID + 16-bit Time-Bin + 16-bit
Bell-pair graph tag) at the cryostat boundary, passing the 64-bit intra-module payload
(`[63:32]` 32-bit Spatial Via + `[31:16]` 16-bit WDM Color + `[15:0]` 16-bit OAM $\ell$ & superposition)
to the RFSoC (`_Quantum Computing Hardware Architectures Review  .myst.md`, Prompts 16–18). -/
@[blueprint "def:signals-soliton-tiered-qnic-payload-bits"
  (title := "Tiered 128-bit QNIC to 64-bit intra-QPU RDMA payload bit width")
  (statement := /-- Define $\operatorname{tieredQnicStrippedPayloadBits}(B_{\mathrm{total}}, B_{\mathrm{header}})
    = B_{\mathrm{total}} - B_{\mathrm{header}}$. -/)]
def tieredQnicStrippedPayloadBits (total_bits header_bits : ℕ) : ℕ :=
  total_bits - header_bits

/-- **Hybrid LUT-Seeded CORDIC Thermal-Drift-Compensated OAM Phase Map**:
$$\phi_{\mathrm{final}}(\ell, \theta_{\mathrm{LUT}}, \Delta\theta_{\mathrm{CORDIC}})
= \ell\,\theta_{\mathrm{LUT}} + \ell\,\Delta\theta_{\mathrm{CORDIC}} = \ell\,(\theta_{\mathrm{LUT}} + \Delta\theta_{\mathrm{CORDIC}}).$$ -/
@[blueprint "def:signals-soliton-lut-plus-cordic-oam-phase"
  (title := "Hybrid LUT-seeded CORDIC thermal-drift-compensated OAM phase map")
  (statement := /-- Define $\operatorname{lutPlusCordicOamPhase}(\ell, \theta_{\mathrm{LUT}}, \Delta\theta_{\mathrm{CORDIC}})
    = \ell \theta_{\mathrm{LUT}} + \ell \Delta\theta_{\mathrm{CORDIC}}$. -/)]
def lutPlusCordicOamPhase (l_charge theta_lut delta_theta_cordic : ℝ) : ℝ :=
  l_charge * theta_lut + l_charge * delta_theta_cordic

/-- **`NLIG_Power_Manager` PWM-Throttled Internal-Pumping Average Thermal Load ($\text{mW}$)**:
$$P_{\mathrm{avg,mW}}(I_{\mathrm{mA}}, R_\Omega, D_{\mathrm{PWM}}) = \left(\frac{I_{\mathrm{mA}}}{1000}\right)^2 R_\Omega \cdot 1000 \cdot D_{\mathrm{PWM}}.$$
At $I = 1.5\text{ mA}, R = 500\text{ }\Omega$, the $60\text{ }\mu\text{s} / 160\text{ }\mu\text{s} = 3/8$ ($37.5\%$)
PWM duty cycle reduces per-node heat from $1.125\text{ mW}$ to $27/64 \approx 0.422\text{ mW}$, allowing
$250$ simultaneous dowsing nodes within the $110\text{ mW}$ 4K budget (`_Quantum Computing Hardware Architectures Review  .myst.md`, Prompts 13–14). -/
@[blueprint "def:signals-soliton-nlig-internal-pump-avg-power-mw"
  (title := "NLIG_Power_Manager PWM-throttled internal-pumping average power (mW)")
  (statement := /-- Define $\operatorname{nligInternalPumpAvgPowerMw}(I_{\mathrm{mA}}, R_\Omega, D_{\mathrm{PWM}})
    = (I_{\mathrm{mA}} / 1000)^2 R_\Omega \cdot 1000 \cdot D_{\mathrm{PWM}}$. -/)]
noncomputable def nligInternalPumpAvgPowerMw (i_ma r_ohm duty_cycle : ℝ) : ℝ :=
  (i_ma / 1000) ^ 2 * r_ohm * 1000 * duty_cycle

/-- **Periodic Cellulose Nanocrystal (CNC) $\chi^{(2)}$ PSA Signal-Booster Net Link Gain ($\text{dB}$)**:
$$G_{\mathrm{net,dB}}(L_{\mathrm{total}}, d_{\mathrm{CNC}}, \alpha_{\mathrm{dB/m}}, G_{\mathrm{CNC,dB}})
= -L_{\mathrm{total}}\,\alpha_{\mathrm{dB/m}} + \left(\frac{L_{\mathrm{total}}}{d_{\mathrm{CNC}}}\right) G_{\mathrm{CNC,dB}}.$$
Inserting high-$Q$ non-centrosymmetric CNC checkpoints every $d_{\mathrm{CNC}} = 10\text{ m}$ (or $100\text{ m}$)
along an `N-LIG` waveguide (`_Quantum Processor and Soliton Discussions  .md`, lines 8306–8415;
`IQ-Sampling-for-Signal-Phase.md`, line 3932; `Lignin-Vitrimer-Surface-Roughness-Limits.md`, lines 1130–1245)
boosts the soliton signal at $0\text{ dB}$ quantum noise figure and resets the Quantum Geometric Tensor. -/
@[blueprint "def:signals-soliton-cnc-periodic-booster-net-link-gain-db"
  (title := "Periodic Cellulose Nanocrystal (CNC) χ^(2) PSA signal-booster net link gain (dB)")
  (statement := /-- Define $\operatorname{cncPeriodicBoosterNetLinkGainDb}(L_{\mathrm{total}}, d_{\mathrm{CNC}}, \alpha_{\mathrm{dB/m}}, G_{\mathrm{CNC,dB}})
    = -L_{\mathrm{total}} \alpha_{\mathrm{dB/m}} + (L_{\mathrm{total}} / d_{\mathrm{CNC}}) G_{\mathrm{CNC,dB}}$. -/)]
noncomputable def cncPeriodicBoosterNetLinkGainDb
    (total_len_m spacing_m loss_db_per_m gain_per_cnc_db : ℝ) : ℝ :=
  -total_len_m * loss_db_per_m + (total_len_m / spacing_m) * gain_per_cnc_db

/-- **Number of Periodic CNC Checkpoints Along an R2R Waveguide Run**:
$$N_{\mathrm{CNC}}(L_{\mathrm{total}}, d_{\mathrm{CNC}}) = L_{\mathrm{total}} / d_{\mathrm{CNC}}.$$ -/
@[blueprint "def:signals-soliton-cnc-checkpoint-count"
  (title := "Number of periodic CNC optical checkpoints L_total / d_CNC")
  (statement := /-- Define $\operatorname{cncCheckpointCount}(L_{\mathrm{total}}, d_{\mathrm{CNC}})
    = L_{\mathrm{total}} / d_{\mathrm{CNC}}$. -/)]
def cncCheckpointCount (total_len_m spacing_m : ℕ) : ℕ :=
  total_len_m / spacing_m

/-- **Normal-Incidence Fresnel Butt-Joint Reflectance $R_{\mathrm{Fresnel}}(n_1, n_2) = \left(\frac{n_1 - n_2}{n_1 + n_2}\right)^2$**:
At $1550\text{ nm}$, a flat butt-joint between `N-LIG` ($n_1 = 1.55$) and Cubic Boron Arsenide
$c\text{-BAs}$ ($n_2 = 3.20$) reflects $(1.65 / 4.75)^2 = 1089 / 9025 \approx 12.07\%$ per facet,
whereas an **Inverted 3D Adiabatic Scarf-Joint Taper** achieves $\eta_{\mathrm{scarf}} = 98.5\%$
transmission ($1.5\%$ loss, `Lignin-Vitrimer-Surface-Roughness-Limits.md`, lines 1265–1310). -/
@[blueprint "def:signals-soliton-fresnel-butt-joint-reflectance"
  (title := "Normal-incidence Fresnel butt-joint reflectance ((n_1 - n_2)/(n_1 + n_2))²")
  (statement := /-- Define $\operatorname{fresnelButtJointReflectance}(n_1, n_2)
    = ((n_1 - n_2) / (n_1 + n_2))^2$. -/)]
noncomputable def fresnelButtJointReflectance (n1 n2 : ℝ) : ℝ :=
  ((n1 - n2) / (n1 + n2)) ^ 2

/-- **Inverted 3D Adiabatic Scarf-Joint Taper Mode-Transfer Efficiency ($\eta_{\mathrm{scarf}} = 98.5\%$)**:
From `Lignin-Vitrimer-Surface-Roughness-Limits.md`, line 1291. -/
@[blueprint "def:signals-soliton-adiabatic-scarf-taper-loss"
  (title := "Inverted 3D adiabatic scarf-joint taper insertion loss fraction 1 - 0.985 = 0.015")
  (statement := /-- Define $\operatorname{adiabaticScarfTaperLoss} = 15 / 1000$. -/)]
noncomputable def adiabaticScarfTaperLoss : ℝ := 15 / 1000

/-- **$590\text{ nm}$ Amber $n$-Adamantane NV-Center Plasmonic Cavity Purcell Factor**:
$$F_P(Q, v_{\mathrm{norm}}, \pi_{\mathrm{approx}}) = \frac{3}{4\,\pi_{\mathrm{approx}}^2}\,\frac{Q}{v_{\mathrm{norm}}}, \qquad v_{\mathrm{norm}} = \frac{V_{\mathrm{mode}}}{(\lambda / n)^3},$$
reducing the $12\text{ ns}$ bulk NV lifetime to $< 1\text{ ns}$ ($F_P \ge 12$, reaching $F_P \approx 75.99$
at $Q = 100, v_{\mathrm{norm}} = 0.10$) for GHz "Optical Dowsing" QND soliton-shadow readout
(`_Quantum Computing Hardware Architectures Review  .myst.md`, Prompt 8, lines 680–755). -/
@[blueprint "def:signals-soliton-nv-purcell-factor-normalized"
  (title := "590nm Amber n-adamantane NV plasmonic cavity Purcell factor (3/(4π²)) * (Q / v_norm)")
  (statement := /-- Define $\operatorname{nvPurcellFactorNormalized}(Q, v_{\mathrm{norm}}, \pi_{\mathrm{approx}})
    = (3 / (4 \pi_{\mathrm{approx}}^2)) \cdot (Q / v_{\mathrm{norm}})$. -/)]
noncomputable def nvPurcellFactorNormalized (q_cav v_norm pi_approx : ℝ) : ℝ :=
  (3 / (4 * pi_approx ^ 2)) * (q_cav / v_norm)

/-- **$\mathrm{CO}_2$-Carbonate $\chi^{(3)}$ Third-Harmonic Generation (`THG`) Wavelength $\lambda_{\mathrm{THG}}(\lambda_0) = \lambda_0 / 3$**:
Converts a $1550\text{ nm}$ telecom soliton into a $1550 / 3 \approx 516.67\text{ nm}$ green synchronization
beacon (`_Quantum Computing Hardware Architectures Review  .myst.md`, Prompt 15, line 1545). -/
@[blueprint "def:signals-soliton-multiband-thg-wavelength-nm"
  (title := "CO₂-carbonate χ^(3) Third-Harmonic Generation wavelength λ_0 / 3")
  (statement := /-- Define $\operatorname{multiBandThirdHarmonicWavelengthNm}(\lambda_0) = \lambda_0 / 3$. -/)]
noncomputable def multiBandThirdHarmonicWavelengthNm (lambda_fund_nm : ℝ) : ℝ :=
  lambda_fund_nm / 3

/-- **Master Theorem for the Revised Semi-Dirac Soliton Bus (Paper 33) and Integrated Multi-Band ($405\text{–}1550\text{ nm}$) CNC / $c\text{-BAs}$ Photonics (Paper 34) (`semi_dirac_soliton_bus_crow_rdma_and_multiband_cnc_cbas_photonics_identities`)**:
Simultaneously establishes:
1. **$\mathrm{CO}_2$-Carbonate $\chi^{(3)}$ $5\times$ CPHASE / CNOT Gate Compression**:
   $\operatorname{co2CarbonateChi3CphaseLength}(\lambda, 5 n_2, I_{\mathrm{ctrl}}) = \frac{1}{5}\operatorname{co2CarbonateChi3CphaseLength}(\lambda, n_2, I_{\mathrm{ctrl}}) < \operatorname{co2CarbonateChi3CphaseLength}(\lambda, n_2, I_{\mathrm{ctrl}})$,
2. **Slow-Light `N-LIG` CROW Delay Line Compression ($24\text{ ns}$ RFSoC CORDIC Window)**:
   $L_{\mathrm{vitrimer}}(n_g=1.5) = 24/5 = 4.8\text{ m} > L_{\mathrm{CROW}}(n_g=5) = 36/25 = 1.44\text{ m} > L_{\mathrm{CROW}}(n_g=300) = 6/250 = 0.024\text{ m}$ ($24\text{ mm}$),
3. **Tiered 128-to-64-Bit QNIC RDMA Header Stripping & LUT-Seeded CORDIC Thermal-Drift Cancellation**:
   $\operatorname{tieredQnicStrippedPayloadBits}(128, 64) = 64$, $32 + 16 + 16 = 64$, and
   $\operatorname{lutPlusCordicOamPhase}(\ell, \theta_{\mathrm{LUT}}, \theta_{\mathrm{true}} - \theta_{\mathrm{LUT}}) = \ell\,\theta_{\mathrm{true}}$,
4. **`NLIG_Power_Manager` $37.5\%$ PWM Duty-Cycle 4K Cryo Budget Compliance**:
   $250 \times \operatorname{nligInternalPumpAvgPowerMw}(3/2, 500, 3/8) = 3375/32 \approx 105.47\text{ mW} < 110\text{ mW} < 250 \times \operatorname{nligInternalPumpAvgPowerMw}(3/2, 500, 1) = 2250/8 = 281.25\text{ mW}$,
5. **Periodic CNC $\chi^{(2)}$ PSA Signal Boosters Every $10\text{ m}$ / $100\text{ m}$ Over $10\text{ km}$**:
   $\operatorname{cncPeriodicBoosterNetLinkGainDb}(L, d_{\mathrm{CNC}}, \alpha, \alpha\,d_{\mathrm{CNC}}) = 0$ for $d_{\mathrm{CNC}} \ne 0$,
   $\operatorname{cncCheckpointCount}(10000, 10) = 1000$, and $\operatorname{cncCheckpointCount}(10000, 100) = 100$,
6. **$1550\text{ nm}$ Adiabatic Scarf-Joint Taper vs. Butt-Joint Fresnel Loss into $c\text{-BAs}$**:
   $\operatorname{adiabaticScarfTaperLoss} = 15/1000 < 1089/9025 = \operatorname{fresnelButtJointReflectance}(31/20, 16/5)$,
7. **$590\text{ nm}$ Amber NV Plasmonic Purcell Enhancement ($F_P > 12$) & Multi-Band ($405\text{–}1550\text{ nm}$) Wavelength Ordering**:
   $12 < \operatorname{nvPurcellFactorNormalized}(100, 1/10, 314/100)$ and
   $405 < 475 < \operatorname{multiBandThirdHarmonicWavelengthNm}(1550) < 532 < 540 < 590 < 650 < 775 < 785 < 800 < 1030 < 1310 < 1550$. -/
@[blueprint "thm:signals-soliton-semi-dirac-bus-crow-rdma-and-multiband-cnc-cbas-photonics"
  (title := "Master theorem for the revised Semi-Dirac Soliton Bus (Paper 33) and Integrated Multi-Band CNC / c-BAs Photonics (Paper 34)")
  (statement := /-- Simultaneously proves $\mathrm{CO}_2$-carbonate $5\times$ CPHASE gate compression, Slow-Light CROW delay compression ($4.8\text{ m} \to 1.44\text{ m} \to 24\text{ mm}$), tiered 128-to-64-bit QNIC RDMA header stripping, LUT-CORDIC thermal drift cancellation, 37.5% PWM 250-node 4K cryo budget compliance ($105.47\text{ mW} < 110\text{ mW}$), periodic CNC $\chi^{(2)}$ PSA zero-net-loss boosting every $d_{\mathrm{CNC}}$, $1550\text{ nm}$ adiabatic scarf-joint taper loss reduction into $c\text{-BAs}$, $590\text{ nm}$ NV Purcell enhancement ($F_P > 12$), and the 13-band $405\text{–}1550\text{ nm}$ wavelength hierarchy. -/)]
theorem semi_dirac_soliton_bus_crow_rdma_and_multiband_cnc_cbas_photonics_identities
    (lambda n2 i_ctrl l_charge theta_lut theta_true total_len_m spacing_m loss_db_per_m : ℝ)
    (hlam : 0 < lambda) (hn2 : 0 < n2) (hic : 0 < i_ctrl) (hspac : spacing_m ≠ 0) :
    co2CarbonateChi3CphaseLength lambda (5 * n2) i_ctrl =
      (1 / 5) * co2CarbonateChi3CphaseLength lambda n2 i_ctrl ∧
    co2CarbonateChi3CphaseLength lambda (5 * n2) i_ctrl <
      co2CarbonateChi3CphaseLength lambda n2 i_ctrl ∧
    crowSlowLightDelayLength 12 (1 / 2) (3 / 10) (3 / 2) = 24 / 5 ∧
    crowSlowLightDelayLength 12 (1 / 2) (3 / 10) 5 = 36 / 25 ∧
    crowSlowLightDelayLength 12 (1 / 2) (3 / 10) 300 = 6 / 250 ∧
    crowSlowLightDelayLength 12 (1 / 2) (3 / 10) 300 <
      crowSlowLightDelayLength 12 (1 / 2) (3 / 10) 5 ∧
    crowSlowLightDelayLength 12 (1 / 2) (3 / 10) 5 <
      crowSlowLightDelayLength 12 (1 / 2) (3 / 10) (3 / 2) ∧
    tieredQnicStrippedPayloadBits 128 64 = 64 ∧
    lutPlusCordicOamPhase l_charge theta_lut (theta_true - theta_lut) =
      l_charge * theta_true ∧
    250 * nligInternalPumpAvgPowerMw (3 / 2) 500 (3 / 8) = 3375 / 32 ∧
    250 * nligInternalPumpAvgPowerMw (3 / 2) 500 (3 / 8) < 110 ∧
    110 < 250 * nligInternalPumpAvgPowerMw (3 / 2) 500 1 ∧
    cncPeriodicBoosterNetLinkGainDb total_len_m spacing_m loss_db_per_m
      (loss_db_per_m * spacing_m) = 0 ∧
    cncCheckpointCount 10000 10 = 1000 ∧
    cncCheckpointCount 10000 100 = 100 ∧
    fresnelButtJointReflectance (31 / 20) (16 / 5) = 1089 / 9025 ∧
    adiabaticScarfTaperLoss < fresnelButtJointReflectance (31 / 20) (16 / 5) ∧
    12 < nvPurcellFactorNormalized 100 (1 / 10) (314 / 100) ∧
    multiBandThirdHarmonicWavelengthNm 1550 = 1550 / 3 ∧
    (405 : ℝ) < 475 ∧
    (475 : ℝ) < multiBandThirdHarmonicWavelengthNm 1550 ∧
    multiBandThirdHarmonicWavelengthNm 1550 < 532 ∧
    (532 : ℝ) < 540 ∧ (540 : ℝ) < 590 ∧ (590 : ℝ) < 650 ∧
    (650 : ℝ) < 775 ∧ (775 : ℝ) < 785 ∧ (785 : ℝ) < 800 ∧
    (800 : ℝ) < 1030 ∧ (1030 : ℝ) < 1310 ∧ (1310 : ℝ) < 1550 := by
  have h_cphase_eq :
      co2CarbonateChi3CphaseLength lambda (5 * n2) i_ctrl =
        (1 / 5) * co2CarbonateChi3CphaseLength lambda n2 i_ctrl := by
    unfold co2CarbonateChi3CphaseLength
    ring
  have h_cphase_pos : 0 < co2CarbonateChi3CphaseLength lambda n2 i_ctrl := by
    unfold co2CarbonateChi3CphaseLength
    positivity
  have h_cphase_lt :
      co2CarbonateChi3CphaseLength lambda (5 * n2) i_ctrl <
        co2CarbonateChi3CphaseLength lambda n2 i_ctrl := by
    rw [h_cphase_eq]
    linarith
  have h_cnc :
      cncPeriodicBoosterNetLinkGainDb total_len_m spacing_m loss_db_per_m
        (loss_db_per_m * spacing_m) = 0 := by
    unfold cncPeriodicBoosterNetLinkGainDb
    field_simp [hspac]
    ring
  refine ⟨
    h_cphase_eq,
    h_cphase_lt,
    by unfold crowSlowLightDelayLength; norm_num,
    by unfold crowSlowLightDelayLength; norm_num,
    by unfold crowSlowLightDelayLength; norm_num,
    by unfold crowSlowLightDelayLength; norm_num,
    by unfold crowSlowLightDelayLength; norm_num,
    rfl,
    by unfold lutPlusCordicOamPhase; ring,
    by unfold nligInternalPumpAvgPowerMw; norm_num,
    by unfold nligInternalPumpAvgPowerMw; norm_num,
    by unfold nligInternalPumpAvgPowerMw; norm_num,
    h_cnc,
    rfl,
    rfl,
    by unfold fresnelButtJointReflectance; norm_num,
    by unfold adiabaticScarfTaperLoss fresnelButtJointReflectance; norm_num,
    by unfold nvPurcellFactorNormalized; norm_num,
    by unfold multiBandThirdHarmonicWavelengthNm; norm_num,
    by norm_num,
    by unfold multiBandThirdHarmonicWavelengthNm; norm_num,
    by unfold multiBandThirdHarmonicWavelengthNm; norm_num,
    by norm_num, by norm_num, by norm_num,
    by norm_num, by norm_num, by norm_num,
    by norm_num, by norm_num, by norm_num⟩

end Signals.SolitonBus
