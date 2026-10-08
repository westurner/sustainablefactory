import Mathlib.Combinatorics.SimpleGraph.Basic
import Mathlib.Data.Matrix.Basic
import Mathlib.Dynamics.PeriodicPts.Lemmas
import Mathlib.GroupTheory.Perm.Basic
import Mathlib.Tactic

namespace Signals.Plabic

open scoped NNReal

/-! Finite bicolored strand routing with explicit rotation and exit data.

A rotation system is not by itself a planar disk embedding. Same-color edges
are allowed. Termination, the bijective boundary map, fixed-point decorations,
and any later identification with positroid cells must not be inferred merely
from the existence of a finite graph.
-/

/-- Internal vertex colors for the prescribed strand-turning convention. -/
inductive NodeColor where
  | black
  | white
  deriving DecidableEq, Repr

/-- A permutation with a color supplied exactly where a fixed point needs decoration. -/
structure DecoratedPermutation (boundaryCount : ℕ) where
  perm : Equiv.Perm (Fin boundaryCount)
  fixedColor : ∀ index, perm index = index → NodeColor

/-- Identity boundary routing with every fixed point decorated white. -/
def DecoratedPermutation.identityWhite (boundaryCount : ℕ) :
    DecoratedPermutation boundaryCount :=
  { perm := Equiv.refl _
    fixedColor := fun _ _ => .white }

/-- Distinct boundary and internal vertex identifiers; each internal identifier has one color. -/
abbrev Vertex (boundaryCount internalCount : ℕ) := Fin boundaryCount ⊕ Fin internalCount

/-- A finite graph with one incident edge per boundary vertex and cyclic internal rotations.

`rotation` is interpreted as counterclockwise; black uses it and white uses its
inverse. `singleOrbit` rules out a purported cyclic order consisting of several
cycles. A genus-zero disk embedding and reducedness are not supplied here.
-/
structure RotationSystem (boundaryCount internalCount : ℕ) where
  graph : SimpleGraph (Vertex boundaryCount internalCount)
  color : Fin internalCount → NodeColor
  rotation : ∀ vertex, Equiv.Perm (graph.neighborSet vertex)
  singleOrbit : ∀ internal (first second : graph.neighborSet (Sum.inr internal)),
    ∃ steps : ℕ, (rotation (Sum.inr internal))^[steps] first = second
  boundaryNeighbor : Fin boundaryCount → Vertex boundaryCount internalCount
  boundaryAdjacent : ∀ index, graph.Adj (Sum.inl index) (boundaryNeighbor index)
  boundaryUnique : ∀ index vertex, graph.Adj (Sum.inl index) vertex →
    vertex = boundaryNeighbor index

/-- A directed edge carries its adjacency proof throughout routing. -/
structure DirectedEdge {boundaryCount internalCount : ℕ}
    (system : RotationSystem boundaryCount internalCount) where
  src : Vertex boundaryCount internalCount
  dst : Vertex boundaryCount internalCount
  adjacent : system.graph.Adj src dst

/-- Directed edges are equivalent to a vertex paired with one of its outgoing neighbors. -/
def DirectedEdge.outgoingEquiv {boundaryCount internalCount : ℕ}
    (system : RotationSystem boundaryCount internalCount) :
    DirectedEdge system ≃ Σ vertex, system.graph.neighborSet vertex where
  toFun edge := ⟨edge.src, ⟨edge.dst, edge.adjacent⟩⟩
  invFun outgoing := ⟨outgoing.1, outgoing.2.val, outgoing.2.property⟩
  left_inv edge := by cases edge; rfl
  right_inv outgoing := by rcases outgoing with ⟨vertex, neighbor, adjacent⟩; rfl

/-- Finite vertex and neighbor sets give a finite directed-edge carrier without extra graph data. -/
instance {boundaryCount internalCount : ℕ} (system : RotationSystem boundaryCount internalCount) :
    Finite (DirectedEdge system) :=
  Finite.of_equiv (Σ vertex, system.graph.neighborSet vertex) (DirectedEdge.outgoingEquiv system).symm

/-- Directed edges agree once their source and destination agree; adjacency proofs are irrelevant. -/
@[ext] lemma DirectedEdge.ext {boundaryCount internalCount : ℕ}
    {system : RotationSystem boundaryCount internalCount} (first second : DirectedEdge system)
    (sources : first.src = second.src) (destinations : first.dst = second.dst) : first = second := by
  cases first
  cases second
  cases sources
  cases destinations
  rfl

/-- Reverse each directed edge; graph symmetry makes this an involutive permutation. -/
def DirectedEdge.reverse {boundaryCount internalCount : ℕ}
    (system : RotationSystem boundaryCount internalCount) : Equiv.Perm (DirectedEdge system) where
  toFun edge := ⟨edge.dst, edge.src, edge.adjacent.symm⟩
  invFun edge := ⟨edge.dst, edge.src, edge.adjacent.symm⟩
  left_inv _ := rfl
  right_inv _ := rfl

/-- Neighbor turns use the chosen color internally and the unique boundary edge externally. -/
def RotationSystem.turnRotation {boundaryCount internalCount : ℕ}
    (system : RotationSystem boundaryCount internalCount) (vertex : Vertex boundaryCount internalCount) :
    Equiv.Perm (system.graph.neighborSet vertex) :=
  match vertex with
  | Sum.inl _ => Equiv.refl _
  | Sum.inr internal => match system.color internal with
      | .black => system.rotation (Sum.inr internal)
      | .white => (system.rotation (Sum.inr internal)).symm

/-- Continue strands through boundaries to obtain a derived permutation on all directed edges. -/
def RotationSystem.dartTurn {boundaryCount internalCount : ℕ}
    (system : RotationSystem boundaryCount internalCount) : Equiv.Perm (DirectedEdge system) :=
  (DirectedEdge.reverse system).trans
    (((DirectedEdge.outgoingEquiv system).trans
      (Equiv.sigmaCongrRight system.turnRotation)).trans (DirectedEdge.outgoingEquiv system).symm)

/-- Each continuing turn leaves from the previous directed edge's destination. -/
lemma RotationSystem.dartTurn_source {boundaryCount internalCount : ℕ}
    (system : RotationSystem boundaryCount internalCount) (edge : DirectedEdge system) :
    (system.dartTurn edge).src = edge.dst := rfl

/-- Every dart returns in a positive number of turns bounded by the finite dart count. -/
lemma RotationSystem.dartTurn_period {boundaryCount internalCount : ℕ}
    (system : RotationSystem boundaryCount internalCount) (edge : DirectedEdge system) :
    ∃ period > 0, period ≤ Nat.card (DirectedEdge system) ∧
      (system.dartTurn : DirectedEdge system → DirectedEdge system)^[period] edge = edge := by
  classical
  let _ : Fintype (DirectedEdge system) := Fintype.ofFinite _
  let turn : DirectedEdge system → DirectedEdge system := system.dartTurn
  have periodic := system.dartTurn.injective.mem_periodicPts edge
  refine ⟨Function.minimalPeriod turn edge,
    Function.minimalPeriod_pos_of_mem_periodicPts periodic, ?_,
    (Function.isPeriodicPt_minimalPeriod turn edge).eq⟩
  simpa only [Nat.card_eq_fintype_card] using
    (Function.minimalPeriod_le_card (f := turn) (x := edge))

/-- The unique outgoing edge at a boundary vertex initializes its strand. -/
def RotationSystem.start {boundaryCount internalCount : ℕ}
    (system : RotationSystem boundaryCount internalCount) (index : Fin boundaryCount) :
    DirectedEdge system :=
  { src := Sum.inl index
    dst := system.boundaryNeighbor index
    adjacent := system.boundaryAdjacent index }

/-- One routing step: black takes the next neighbor, white the previous, and boundary stops. -/
def RotationSystem.step {boundaryCount internalCount : ℕ}
    (system : RotationSystem boundaryCount internalCount) (edge : DirectedEdge system) :
    DirectedEdge system :=
  match edge.dst with
  | Sum.inl _ => edge
  | Sum.inr internal =>
      let incoming : system.graph.neighborSet edge.dst := ⟨edge.src, edge.adjacent.symm⟩
      let outgoing := match system.color internal with
        | .black => system.rotation edge.dst incoming
        | .white => (system.rotation edge.dst).symm incoming
      { src := edge.dst
        dst := outgoing.val
        adjacent := outgoing.property }

/-- Routing at an exit boundary leaves the directed edge unchanged. -/
lemma RotationSystem.step_boundary {boundaryCount internalCount : ℕ}
    (system : RotationSystem boundaryCount internalCount) (edge : DirectedEdge system)
    (index : Fin boundaryCount) (terminal : edge.dst = Sum.inl index) :
    system.step edge = edge := by
  simp [RotationSystem.step, terminal]

/-- At an internal destination the continuing dart turn agrees with the original strand step. -/
lemma RotationSystem.dartTurn_internal {boundaryCount internalCount : ℕ}
    (system : RotationSystem boundaryCount internalCount) (edge : DirectedEdge system)
    (internal : Fin internalCount) (destination : edge.dst = Sum.inr internal) :
    system.dartTurn edge = system.step edge := by
  cases edge with
  | mk source target adjacent =>
      dsimp at destination
      subst target
      cases color : system.color internal <;>
        simp [dartTurn, DirectedEdge.reverse, DirectedEdge.outgoingEquiv,
          Equiv.sigmaCongrRight, turnRotation, step, color]

/-- A boundary arrival continues through its unique incident edge to the corresponding start. -/
lemma RotationSystem.dartTurn_boundary {boundaryCount internalCount : ℕ}
    (system : RotationSystem boundaryCount internalCount) (edge : DirectedEdge system)
    (index : Fin boundaryCount) (destination : edge.dst = Sum.inl index) :
    system.dartTurn edge = system.start index := by
  cases edge with
  | mk source target adjacent =>
      dsimp at destination
      subst target
      apply DirectedEdge.ext
      · rfl
      · exact system.boundaryUnique index source adjacent.symm

/-- Evaluate a strand for a bounded number of steps, retaining a valid directed edge. -/
def RotationSystem.route {boundaryCount internalCount : ℕ}
    (system : RotationSystem boundaryCount internalCount) : ℕ → DirectedEdge system →
      DirectedEdge system
  | 0, edge => edge
  | steps + 1, edge => system.step (system.route steps edge)

/-- Once a strand reaches a boundary, every further bounded evaluation preserves the exit. -/
lemma RotationSystem.route_boundary {boundaryCount internalCount : ℕ}
    (system : RotationSystem boundaryCount internalCount) (edge : DirectedEdge system)
    (index : Fin boundaryCount) (terminal : edge.dst = Sum.inl index) (steps : ℕ) :
    system.route steps edge = edge := by
  induction steps with
  | zero => rfl
  | succ steps induction_hypothesis =>
      rw [RotationSystem.route, induction_hypothesis]
      exact system.step_boundary edge index terminal

/-- Moving the first step outside a bounded route leaves the same strand endpoint. -/
lemma RotationSystem.route_succ_start {boundaryCount internalCount : ℕ}
  (system : RotationSystem boundaryCount internalCount) (steps : ℕ) (edge : DirectedEdge system) :
  system.route (steps + 1) edge = system.route steps (system.step edge) := by
  induction steps with
  | zero => rfl
  | succ steps induction_hypothesis =>
      exact congrArg system.step induction_hypothesis

/-- Splitting a route into two consecutive bounded evaluations preserves its endpoint. -/
lemma RotationSystem.route_add {boundaryCount internalCount : ℕ}
    (system : RotationSystem boundaryCount internalCount) (steps extra : ℕ)
    (edge : DirectedEdge system) :
    system.route (steps + extra) edge = system.route extra (system.route steps edge) := by
  induction extra with
  | zero => rfl
  | succ extra induction_hypothesis => exact congrArg system.step induction_hypothesis

/-- Search for the first boundary exit, returning its step count or an explicit fuel failure. -/
def RotationSystem.firstExit {boundaryCount internalCount : ℕ}
  (system : RotationSystem boundaryCount internalCount) : ℕ → DirectedEdge system →
    Option (ℕ × Fin boundaryCount)
  | 0, edge => match edge.dst with
    | Sum.inl index => some (0, index)
    | Sum.inr _ => none
  | fuel + 1, edge => match edge.dst with
    | Sum.inl index => some (0, index)
    | Sum.inr _ => (system.firstExit fuel (system.step edge)).map
      (fun exit => (exit.1 + 1, exit.2))

  /-- A successful search reaches the reported boundary within fuel, with no earlier boundary exit. -/
  lemma RotationSystem.firstExit_spec {boundaryCount internalCount : ℕ}
    (system : RotationSystem boundaryCount internalCount) (fuel : ℕ) (edge : DirectedEdge system)
    (steps : ℕ) (index : Fin boundaryCount)
    (result : system.firstExit fuel edge = some (steps, index)) :
    steps ≤ fuel ∧ (system.route steps edge).dst = Sum.inl index ∧
      ∀ earlier < steps, ∀ other, (system.route earlier edge).dst ≠ Sum.inl other := by
    induction fuel generalizing edge steps index with
    | zero =>
      cases terminal : edge.dst with
      | inl found =>
        simp only [firstExit, terminal, Option.some.injEq, Prod.mk.injEq] at result
        rcases result with ⟨rfl, rfl⟩
        exact ⟨Nat.le_refl _, terminal, by intro earlier before; omega⟩
      | inr _ => simp [firstExit, terminal] at result
    | succ fuel induction_hypothesis =>
      cases terminal : edge.dst with
      | inl found =>
        simp only [firstExit, terminal, Option.some.injEq, Prod.mk.injEq] at result
        rcases result with ⟨rfl, rfl⟩
        exact ⟨Nat.zero_le _, terminal, by intro earlier before; omega⟩
      | inr _ =>
        cases previous : system.firstExit fuel (system.step edge) with
        | none => simp [firstExit, terminal, previous] at result
        | some exit =>
          rcases exit with ⟨previousSteps, previousIndex⟩
          simp only [firstExit, terminal, previous, Option.map_some,
          Option.some.injEq, Prod.mk.injEq] at result
          rcases result with ⟨rfl, rfl⟩
          obtain ⟨bound, destination, minimal⟩ :=
          induction_hypothesis (system.step edge) previousSteps previousIndex previous
          refine ⟨Nat.succ_le_succ bound, ?_, ?_⟩
          · simpa only [route_succ_start] using destination
          · intro earlier before other
            cases earlier with
            | zero => simp [route, terminal]
            | succ earlier =>
              have earlierBound : earlier < previousSteps := by omega
              simpa only [route_succ_start] using minimal earlier earlierBound other

  /-- Any boundary reached by the fuel-limited route is found by the first-exit search. -/
  lemma RotationSystem.firstExit_exists {boundaryCount internalCount : ℕ}
    (system : RotationSystem boundaryCount internalCount) (fuel : ℕ) (edge : DirectedEdge system)
    (index : Fin boundaryCount) (terminal : (system.route fuel edge).dst = Sum.inl index) :
    ∃ steps ≤ fuel, system.firstExit fuel edge = some (steps, index) := by
    induction fuel generalizing edge with
    | zero =>
      exact ⟨0, Nat.le_refl _, by simp [firstExit, show edge.dst = Sum.inl index from terminal]⟩
    | succ fuel induction_hypothesis =>
      cases destination : edge.dst with
      | inl found =>
        have sameIndex : found = index := Sum.inl.inj (by
          simpa only [system.route_boundary edge found destination (fuel + 1), destination]
            using terminal)
        exact ⟨0, Nat.zero_le _, by simp [firstExit, destination, sameIndex]⟩
      | inr _ =>
        rw [route_succ_start] at terminal
        obtain ⟨steps, bound, result⟩ := induction_hypothesis (system.step edge) terminal
        exact ⟨steps + 1, Nat.succ_le_succ bound, by simp [firstExit, destination, result]⟩

/-- Fuel exhaustion is equivalent to reaching no boundary by the bounded route endpoint. -/
lemma RotationSystem.firstExit_none_iff {boundaryCount internalCount : ℕ}
    (system : RotationSystem boundaryCount internalCount) (fuel : ℕ) (edge : DirectedEdge system) :
    system.firstExit fuel edge = none ↔
      ∀ index, (system.route fuel edge).dst ≠ Sum.inl index := by
  constructor
  · intro result index terminal
    obtain ⟨steps, _, found⟩ := system.firstExit_exists fuel edge index terminal
    rw [result] at found
    contradiction
  · intro absent
    cases result : system.firstExit fuel edge with
    | none => rfl
    | some exit =>
      rcases exit with ⟨steps, index⟩
      obtain ⟨bound, destination, _⟩ := system.firstExit_spec fuel edge steps index result
      have extended : (system.route fuel edge).dst = Sum.inl index := by
        rw [← Nat.add_sub_of_le bound, route_add,
          system.route_boundary (system.route steps edge) index destination (fuel - steps)]
        exact destination
      exact False.elim (absent index extended)

/-- Before any boundary arrival, the absorbing route agrees with continuing dart iteration. -/
lemma RotationSystem.route_eq_dartIterate {boundaryCount internalCount : ℕ}
    (system : RotationSystem boundaryCount internalCount) (steps : ℕ) (edge : DirectedEdge system)
    (noBoundary : ∀ earlier < steps, ∀ index, (system.route earlier edge).dst ≠ Sum.inl index) :
    system.route steps edge = (system.dartTurn : DirectedEdge system → DirectedEdge system)^[steps] edge := by
  revert noBoundary
  induction steps with
  | zero => intro _; rfl
  | succ steps induction_hypothesis =>
      intro noBoundary
      have previous := induction_hypothesis (fun earlier before index =>
        noBoundary earlier (by omega) index)
      cases destination : (system.route steps edge).dst with
      | inl index => exact False.elim (noBoundary steps (by omega) index destination)
      | inr internal =>
          rw [route, ← system.dartTurn_internal (system.route steps edge) internal destination,
            previous, Function.iterate_succ_apply']

/-- An exhausted search budget also excludes all boundary arrivals at earlier steps. -/
lemma RotationSystem.firstExit_none_earlier {boundaryCount internalCount : ℕ}
    (system : RotationSystem boundaryCount internalCount) (fuel : ℕ) (edge : DirectedEdge system)
    (result : system.firstExit fuel edge = none) (earlier : ℕ) (bound : earlier ≤ fuel)
    (index : Fin boundaryCount) : (system.route earlier edge).dst ≠ Sum.inl index := by
  intro destination
  have terminal : (system.route fuel edge).dst = Sum.inl index := by
    rw [← Nat.add_sub_of_le bound, route_add,
      system.route_boundary (system.route earlier edge) index destination (fuel - earlier)]
    exact destination
  exact ((system.firstExit_none_iff fuel edge).mp result index) terminal

/-- Every boundary start has an exit found using at most the finite dart count as search fuel. -/
lemma RotationSystem.boundary_firstExit_exists {boundaryCount internalCount : ℕ}
    (system : RotationSystem boundaryCount internalCount) (index : Fin boundaryCount) :
    ∃ steps destination, system.firstExit (Nat.card (DirectedEdge system)) (system.start index) =
      some (steps, destination) := by
  cases result : system.firstExit (Nat.card (DirectedEdge system)) (system.start index) with
  | some exit =>
      rcases exit with ⟨steps, destination⟩
      exact ⟨steps, destination, rfl⟩
  | none =>
      obtain ⟨period, positive, bound, returns⟩ := system.dartTurn_period (system.start index)
      cases period with
      | zero => omega
      | succ previous =>
          have noBoundary : ∀ earlier < previous, ∀ other,
              (system.route earlier (system.start index)).dst ≠ Sum.inl other := by
            intro earlier before other
            exact system.firstExit_none_earlier _ _ result earlier (by omega) other
          have agreement := system.route_eq_dartIterate previous (system.start index) noBoundary
          have sources := congrArg DirectedEdge.src returns
          rw [Function.iterate_succ_apply', system.dartTurn_source, ← agreement] at sources
          exact False.elim
            (system.firstExit_none_earlier _ _ result previous (by omega) index sources)

/-- Extract the guaranteed first exit from the computed dart-count search, not a supplied match. -/
noncomputable def RotationSystem.boundaryExitData {boundaryCount internalCount : ℕ}
    (system : RotationSystem boundaryCount internalCount) (index : Fin boundaryCount) :
    ℕ × Fin boundaryCount :=
  (system.firstExit (Nat.card (DirectedEdge system)) (system.start index)).get (by
    obtain ⟨steps, destination, result⟩ := system.boundary_firstExit_exists index
    rw [result]
    rfl)

/-- The derived boundary data are exactly the successful finite search result. -/
lemma RotationSystem.boundaryExitData_found {boundaryCount internalCount : ℕ}
    (system : RotationSystem boundaryCount internalCount) (index : Fin boundaryCount) :
    system.firstExit (Nat.card (DirectedEdge system)) (system.start index) =
      some (system.boundaryExitData index) := by
  unfold boundaryExitData
  exact (Option.some_get _).symm

/-- Derived boundary data retain the dart-count bound, route endpoint and earliest-exit condition. -/
lemma RotationSystem.boundaryExitData_spec {boundaryCount internalCount : ℕ}
    (system : RotationSystem boundaryCount internalCount) (index : Fin boundaryCount) :
    (system.boundaryExitData index).1 ≤ Nat.card (DirectedEdge system) ∧
      (system.route (system.boundaryExitData index).1 (system.start index)).dst =
        Sum.inl (system.boundaryExitData index).2 ∧
      ∀ earlier < (system.boundaryExitData index).1, ∀ other,
        (system.route earlier (system.start index)).dst ≠ Sum.inl other :=
  system.firstExit_spec _ _ _ _ (system.boundaryExitData_found index)

/-- One turn after the earliest boundary arrival reaches the derived destination's start edge. -/
lemma RotationSystem.boundary_return_eq {boundaryCount internalCount : ℕ}
    (system : RotationSystem boundaryCount internalCount) (index : Fin boundaryCount) :
    (system.dartTurn : DirectedEdge system → DirectedEdge system)^[
      (system.boundaryExitData index).1 + 1] (system.start index) =
        system.start (system.boundaryExitData index).2 := by
  rw [Function.iterate_succ_apply', ← system.route_eq_dartIterate
    (system.boundaryExitData index).1 (system.start index) (system.boundaryExitData_spec index).2.2]
  exact system.dartTurn_boundary _ _ (system.boundaryExitData_spec index).2.1

/-- No positive iterate reaches any boundary start before the derived first-return time. -/
lemma RotationSystem.boundary_no_early_start {boundaryCount internalCount : ℕ}
    (system : RotationSystem boundaryCount internalCount) (first other : Fin boundaryCount)
    (turns : ℕ) (bound : turns ≤ (system.boundaryExitData first).1)
    (returns : (system.dartTurn : DirectedEdge system → DirectedEdge system)^[turns]
      (system.start first) = system.start other) : turns = 0 ∧ first = other := by
  cases turns with
  | zero => exact ⟨rfl, Sum.inl.inj (congrArg DirectedEdge.src returns)⟩
  | succ previous =>
      have minimal := (system.boundaryExitData_spec first).2.2
      have agreement := system.route_eq_dartIterate previous (system.start first)
        (fun earlier before index => minimal earlier (by omega) index)
      have sources := congrArg DirectedEdge.src returns
      rw [Function.iterate_succ_apply', system.dartTurn_source, ← agreement] at sources
      exact False.elim (minimal previous (by omega) other sources)

/-- The positive boundary first-return time is bounded by the finite dart count. -/
lemma RotationSystem.boundary_return_bound {boundaryCount internalCount : ℕ}
    (system : RotationSystem boundaryCount internalCount) (index : Fin boundaryCount) :
    (system.boundaryExitData index).1 + 1 ≤ Nat.card (DirectedEdge system) := by
  obtain ⟨period, positive, bound, returns⟩ := system.dartTurn_period (system.start index)
  have sooner : (system.boundaryExitData index).1 < period := by
    by_contra! earlier
    have impossible := (system.boundary_no_early_start index index period earlier returns).1
    omega
  omega

/-- Invertible dart dynamics and first-return minimality prevent two starts sharing an exit. -/
lemma RotationSystem.boundaryExit_injective {boundaryCount internalCount : ℕ}
    (system : RotationSystem boundaryCount internalCount) :
    Function.Injective (fun index => (system.boundaryExitData index).2) := by
  have ordered_case : ∀ first second : Fin boundaryCount,
      (system.boundaryExitData first).1 ≤ (system.boundaryExitData second).1 →
      (system.boundaryExitData first).2 = (system.boundaryExitData second).2 → first = second := by
    intro first second ordered matched
    let gap := (system.boundaryExitData second).1 - (system.boundaryExitData first).1
    let turn : DirectedEdge system → DirectedEdge system := system.dartTurn
    have total : (system.boundaryExitData first).1 + 1 + gap =
        (system.boundaryExitData second).1 + 1 := by dsimp [gap]; omega
    have sameReturn : turn^[(system.boundaryExitData first).1 + 1] (system.start first) =
        turn^[(system.boundaryExitData first).1 + 1] (turn^[gap] (system.start second)) := by
      rw [← Function.iterate_add_apply, total]
      dsimp only [turn]
      rw [system.boundary_return_eq first, system.boundary_return_eq second, matched]
    have meet := (system.dartTurn.injective.iterate _) sameReturn
    have earliest := system.boundary_no_early_start second first gap
      (Nat.sub_le _ _) meet.symm
    exact earliest.2.symm
  intro first second matched
  rcases le_total (system.boundaryExitData first).1 (system.boundaryExitData second).1 with
    ordered | ordered
  · exact ordered_case first second ordered matched
  · exact (ordered_case second first ordered matched.symm).symm

/-- Construct the boundary permutation from guaranteed earliest exits, without a supplied permutation. -/
noncomputable def RotationSystem.boundaryPerm {boundaryCount internalCount : ℕ}
    (system : RotationSystem boundaryCount internalCount) : Equiv.Perm (Fin boundaryCount) :=
  Equiv.ofBijective (fun index => (system.boundaryExitData index).2)
    ⟨system.boundaryExit_injective, Finite.injective_iff_surjective.mp system.boundaryExit_injective⟩

/-- The constructed boundary permutation is exactly the label returned by the first-exit search. -/
lemma RotationSystem.boundaryPerm_apply {boundaryCount internalCount : ℕ}
    (system : RotationSystem boundaryCount internalCount) (index : Fin boundaryCount) :
    system.boundaryPerm index = (system.boundaryExitData index).2 := rfl

/-- Any two successful fuel budgets return the same earliest step count and boundary label. -/
lemma RotationSystem.firstExit_unique {boundaryCount internalCount : ℕ}
    (system : RotationSystem boundaryCount internalCount) (fuel otherFuel : ℕ)
    (edge : DirectedEdge system) (steps otherSteps : ℕ) (index otherIndex : Fin boundaryCount)
    (result : system.firstExit fuel edge = some (steps, index))
    (otherResult : system.firstExit otherFuel edge = some (otherSteps, otherIndex)) :
    steps = otherSteps ∧ index = otherIndex := by
  obtain ⟨_, destination, minimal⟩ := system.firstExit_spec fuel edge steps index result
  obtain ⟨_, otherDestination, otherMinimal⟩ :=
    system.firstExit_spec otherFuel edge otherSteps otherIndex otherResult
  have sameSteps : steps = otherSteps := by
    apply le_antisymm
    · by_contra! more
      exact minimal otherSteps more otherIndex otherDestination
    · by_contra! more
      exact otherMinimal steps more index destination
  refine ⟨sameSteps, Sum.inl.inj (destination.symm.trans ?_)⟩
  simpa only [sameSteps] using otherDestination

  /-- A checked finite exit certificate and bijective boundary labeling.

  The permutation and finite step counts are supplied and checked against the
  route evaluator, not derived from unproved termination or planarity premises.
  -/
structure BoundaryRouting {boundaryCount internalCount : ℕ}
    (system : RotationSystem boundaryCount internalCount) where
  perm : Equiv.Perm (Fin boundaryCount)
  steps : Fin boundaryCount → ℕ
  exits : ∀ index, (system.route (steps index) (system.start index)).dst = Sum.inl (perm index)
  fixedColor : ∀ index, perm index = index → NodeColor

/-- Extract a decorated permutation only from checked boundary routing data. -/
def BoundaryRouting.decorated {boundaryCount internalCount : ℕ}
    {system : RotationSystem boundaryCount internalCount} (routing : BoundaryRouting system) :
    DecoratedPermutation boundaryCount :=
  { perm := routing.perm
    fixedColor := routing.fixedColor }

/-- The extracted permutation agrees with each finite routed endpoint. -/
lemma BoundaryRouting.route_destination {boundaryCount internalCount : ℕ}
    {system : RotationSystem boundaryCount internalCount} (routing : BoundaryRouting system)
    (index : Fin boundaryCount) :
    (system.route (routing.steps index) (system.start index)).dst =
      Sum.inl (routing.decorated.perm index) :=
  routing.exits index

/-- Bijectivity is available only through the checked routing certificate's permutation. -/
lemma BoundaryRouting.perm_bijective {boundaryCount internalCount : ℕ}
    {system : RotationSystem boundaryCount internalCount} (routing : BoundaryRouting system) :
    Function.Bijective routing.decorated.perm :=
  routing.perm.bijective

/-- Populate the compatibility certificate from derived exits; fixed-point decorations remain explicit. -/
noncomputable def RotationSystem.derivedRouting {boundaryCount internalCount : ℕ}
    (system : RotationSystem boundaryCount internalCount)
    (fixedColor : ∀ index, system.boundaryPerm index = index → NodeColor) : BoundaryRouting system :=
  { perm := system.boundaryPerm
    steps := fun index => (system.boundaryExitData index).1
    exits := fun index => (system.boundaryExitData_spec index).2.1
    fixedColor := fixedColor }

/-- Nonnegative edge weights with a checked strict level increase on every nonzero edge. -/
structure WeightedAcyclicNetwork (vertexCount height : ℕ) where
  level : Fin vertexCount → Fin (height + 1)
  weight : Matrix (Fin vertexCount) (Fin vertexCount) ℝ≥0
  ascending : ∀ first second, weight first second ≠ 0 →
    (level first).val < (level second).val

/-- Matrix-power path weights vanish when their length exceeds the available level difference. -/
lemma WeightedAcyclicNetwork.pathWeight_zero {vertexCount height : ℕ}
    (network : WeightedAcyclicNetwork vertexCount height) (length : ℕ)
    (first second : Fin vertexCount)
    (tooLong : (network.level second).val < (network.level first).val + length) :
    (network.weight ^ length) first second = 0 := by
  induction length generalizing first second with
  | zero =>
    by_cases same : first = second
    · subst second
      omega
    · simp [same]
  | succ length induction_hypothesis =>
    rw [pow_succ, Matrix.mul_apply]
    apply Finset.sum_eq_zero
    intro middle _
    by_cases left : (network.level middle).val < (network.level first).val + length
    · rw [induction_hypothesis first middle left, zero_mul]
    · have right : network.weight middle second = 0 := by
        by_contra nonzero
        have increasing := network.ascending middle second nonzero
        omega
      rw [right, mul_zero]

/-- The checked level bound derives nilpotency; no cyclic-series convergence is assumed. -/
lemma WeightedAcyclicNetwork.nilpotent {vertexCount height : ℕ}
    (network : WeightedAcyclicNetwork vertexCount height) : network.weight ^ (height + 1) = 0 := by
  apply Matrix.ext
  intro first second
  change (network.weight ^ (height + 1)) first second = 0
  apply network.pathWeight_zero
  have bounded := (network.level second).isLt
  omega

/-- Sum all weighted path lengths allowed by the certified acyclic height, including length zero. -/
noncomputable def WeightedAcyclicNetwork.transfer {vertexCount height : ℕ}
    (network : WeightedAcyclicNetwork vertexCount height) :
    Matrix (Fin vertexCount) (Fin vertexCount) ℝ≥0 :=
  ∑ length ∈ Finset.range (height + 1), network.weight ^ length

/-- Increasing the finite path cutoff adds only zero terms, rather than a convergence assumption. -/
lemma WeightedAcyclicNetwork.transfer_stable {vertexCount height : ℕ}
    (network : WeightedAcyclicNetwork vertexCount height) (extra : ℕ) :
    (∑ length ∈ Finset.range (height + 1 + extra), network.weight ^ length) = network.transfer := by
  rw [Finset.sum_range_add]
  have tailZero : (∑ length ∈ Finset.range extra, network.weight ^ (height + 1 + length)) = 0 := by
    apply Finset.sum_eq_zero
    intro length _
    rw [pow_add, network.nilpotent, zero_mul]
  rw [tailZero, add_zero]
  rfl

/-- The finite path sum satisfies the exact identity-plus-one-edge continuation equation. -/
lemma WeightedAcyclicNetwork.transfer_equation {vertexCount height : ℕ}
    (network : WeightedAcyclicNetwork vertexCount height) :
    network.transfer = 1 + network.weight * network.transfer := by
  calc
    network.transfer = ∑ length ∈ Finset.range (height + 1 + 1), network.weight ^ length := by
      rw [Finset.sum_range_succ, network.nilpotent, add_zero]
      rfl
    _ = 1 + ∑ length ∈ Finset.range (height + 1), network.weight ^ (length + 1) := by
      rw [Finset.sum_range_succ']
      simp only [pow_zero]
      exact add_comm _ _
    _ = 1 + network.weight * network.transfer := by
      rw [transfer, Finset.mul_sum]
      congr 1
      apply Finset.sum_congr rfl
      intro length _
      exact pow_succ' network.weight length

/-- Boundary measurements select source/sink entries of the derived finite weighted path sum. -/
noncomputable def WeightedAcyclicNetwork.boundaryMeasurement {vertexCount height : ℕ}
    (network : WeightedAcyclicNetwork vertexCount height) {sourceCount sinkCount : ℕ}
    (sources : Fin sourceCount → Fin vertexCount) (sinks : Fin sinkCount → Fin vertexCount) :
    Matrix (Fin sourceCount) (Fin sinkCount) ℝ≥0 :=
  fun source sink => network.transfer (sources source) (sinks sink)

/-- A single weighted directed edge with source zero and sink one. -/
def WeightedAcyclicNetwork.oneEdgePath (weight : ℝ≥0) : WeightedAcyclicNetwork 2 1 :=
  { level := fun vertex => vertex
    weight := ![![0, weight], ![0, 0]]
    ascending := by
      intro first second nonzero
      fin_cases first <;> fin_cases second <;> norm_num at * }

/-- A subdivided directed edge with an intermediate vertex and two independently supplied weights. -/
def WeightedAcyclicNetwork.twoEdgePath (firstWeight secondWeight : ℝ≥0) :
    WeightedAcyclicNetwork 3 2 :=
  { level := fun vertex => vertex
    weight := ![![0, firstWeight, 0], ![0, 0, secondWeight], ![0, 0, 0]]
    ascending := by
      intro first second nonzero
      fin_cases first <;> fin_cases second <;> norm_num at * }

/-- A single edge's actual finite path sum recovers its supplied edge weight. -/
lemma WeightedAcyclicNetwork.oneEdgePath_transfer (weight : ℝ≥0) :
    (oneEdgePath weight).transfer 0 1 = weight := by
  simp only [transfer, Finset.sum_range_succ, Finset.range_zero, Finset.sum_empty,
    zero_add, Matrix.add_apply, pow_zero, pow_one, Matrix.one_apply]
  simp [oneEdgePath]

/-- A two-edge path's actual finite sum multiplies its two edge weights. -/
lemma WeightedAcyclicNetwork.twoEdgePath_transfer (firstWeight secondWeight : ℝ≥0) :
    (twoEdgePath firstWeight secondWeight).transfer 0 2 = firstWeight * secondWeight := by
  simp only [transfer, Finset.sum_range_succ, Finset.range_zero, Finset.sum_empty,
    zero_add, Matrix.add_apply, pow_zero, pow_one, pow_two, Matrix.one_apply, Matrix.mul_apply]
  simp [twoEdgePath, Fin.sum_univ_succ]

/-- Subdivision by a nonzero factor preserves the complete one-source/one-sink boundary matrix. -/
lemma WeightedAcyclicNetwork.subdivision_boundary (weight factor : ℝ≥0) (nonzero : factor ≠ 0) :
    (twoEdgePath factor (weight / factor)).boundaryMeasurement
      (fun _ : Fin 1 => 0) (fun _ : Fin 1 => 2) =
    (oneEdgePath weight).boundaryMeasurement (fun _ : Fin 1 => 0) (fun _ : Fin 1 => 1) := by
  apply Matrix.ext
  intro source sink
  change (twoEdgePath factor (weight / factor)).transfer 0 2 = (oneEdgePath weight).transfer 0 1
  rw [twoEdgePath_transfer, oneEdgePath_transfer, div_eq_mul_inv]
  calc
    factor * (weight * factor⁻¹) = weight * (factor * factor⁻¹) := by ac_rfl
    _ = weight := by rw [mul_inv_cancel₀ nonzero, mul_one]

end Signals.Plabic
