import Mathlib.Combinatorics.SimpleGraph.Basic
import Mathlib.GroupTheory.Perm.Basic
import Mathlib.Tactic

namespace Signals.Plabic

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

end Signals.Plabic
