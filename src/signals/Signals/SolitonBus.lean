import Mathlib.Data.Complex.Basic
import Mathlib.Data.Fin.Basic
import Mathlib.LinearAlgebra.Matrix.Notation
import Mathlib.Tactic
import Signals.Lasers
import Signals.OAM
import Signals.Propagation
import Signals.Units

namespace Signals.SolitonBus

open Signals.Lasers
open Signals.Propagation
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
    simp [Matrix.mul_apply, Complex.ext_iff]

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

end Signals.SolitonBus
