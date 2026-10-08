import Mathlib.Combinatorics.SimpleGraph.Basic
import Mathlib.Data.Matrix.Basic
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

end Signals.Plabic
