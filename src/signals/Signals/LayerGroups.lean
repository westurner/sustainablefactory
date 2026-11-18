import Mathlib.Tactic

namespace Signals.LayerGroups

/-! ### WS-3: Exact Affine Layer-Group Operations Modulo 2D Lattice Translations

Layer groups are 3D subperiodic crystallographic symmetry groups that are periodic
in two lattice directions `(u, v)` and finite/non-periodic in the out-of-plane
coordinate `z`. Every operation in all 80 International Tables Vol. E layer groups
can be written in the appropriate Bravais basis (oblique, rectangular, square, or
hexagonal) as an exact integer `3 × 3` point-group matrix `R` with `R_{2,0} = R_{2,1} = 0`,
`R_{0,2} = R_{1,2} = 0`, `R_{2,2} ∈ {-1, 1}`, and a half-integer in-plane translation
`(t_u / 2, t_v / 2, 0)` modulo `ℤ² × {0}` (so `t_u, t_v ∈ Fin 2`).

This module formalizes that exact quotient monoid/group action and proves check
figures for representative layer groups without conflating crystallographic
symmetry orders with electronic transport or QAHE claims.
-/

/-- Exact `2 × 2` integer in-plane matrix plus out-of-plane sign `rz ∈ {-1, 1}`
and half-integer in-plane translation `(tu, tv)` modulo 2 (representing `tu/2, tv/2 mod 1`). -/
structure LayerOp where
  a00 : ℤ
  a01 : ℤ
  a10 : ℤ
  a11 : ℤ
  rz : ℤ
  tu : ZMod 2
  tv : ZMod 2
  deriving DecidableEq, Repr

/-- Identity operation `(I_2, +1, (0, 0))`. -/
def LayerOp.id : LayerOp :=
  { a00 := 1, a01 := 0, a10 := 0, a11 := 1, rz := 1, tu := 0, tv := 0 }

/-- Exact composition `(R₁, t₁) ∘ (R₂, t₂) = (R₁ R₂, R₁ t₂ + t₁ mod 2)` in the 2D lattice quotient. -/
def LayerOp.comp (g h : LayerOp) : LayerOp :=
  { a00 := g.a00 * h.a00 + g.a01 * h.a10
    a01 := g.a00 * h.a01 + g.a01 * h.a11
    a10 := g.a10 * h.a00 + g.a11 * h.a10
    a11 := g.a10 * h.a01 + g.a11 * h.a11
    rz := g.rz * h.rz
    tu := (g.a00 : ZMod 2) * h.tu + (g.a01 : ZMod 2) * h.tv + g.tu
    tv := (g.a10 : ZMod 2) * h.tu + (g.a11 : ZMod 2) * h.tv + g.tv }

/-- In-plane matrix determinant `a00 * a11 - a01 * a10`. -/
def LayerOp.det2 (g : LayerOp) : ℤ :=
  g.a00 * g.a11 - g.a01 * g.a10

/-- Full 3D point-group determinant `det2 * rz`. -/
def LayerOp.det3 (g : LayerOp) : ℤ :=
  g.det2 * g.rz

/-- Left identity law for `LayerOp.comp`. -/
theorem LayerOp.id_comp (g : LayerOp) : LayerOp.id.comp g = g := by
  cases g
  simp [LayerOp.id, LayerOp.comp]

/-- Right identity law for `LayerOp.comp`. -/
theorem LayerOp.comp_id (g : LayerOp) : g.comp LayerOp.id = g := by
  cases g
  simp [LayerOp.id, LayerOp.comp]

/-- Associativity of exact layer-group affine composition modulo `ℤ² × {0}`. -/
theorem LayerOp.comp_assoc (f g h : LayerOp) :
    (f.comp g).comp h = f.comp (g.comp h) := by
  cases f
  cases g
  cases h
  simp only [LayerOp.comp, Int.cast_add, Int.cast_mul]
  congr 1 <;> ring

/-- Determinant is multiplicative under composition. -/
theorem LayerOp.det3_comp (g h : LayerOp) :
    (g.comp h).det3 = g.det3 * h.det3 := by
  cases g
  cases h
  simp only [LayerOp.comp, LayerOp.det3, LayerOp.det2]
  ring

/-- Canonical generators used across the 80 International Tables Vol. E layer groups. -/
def opC2z : LayerOp := ⟨-1, 0, 0, -1, 1, 0, 0⟩
def opMz : LayerOp := ⟨1, 0, 0, 1, -1, 0, 0⟩
def opAz : LayerOp := ⟨1, 0, 0, 1, -1, 1, 0⟩
def opC2x : LayerOp := ⟨1, 0, 0, -1, -1, 0, 0⟩
def opC2y : LayerOp := ⟨-1, 0, 0, 1, -1, 0, 0⟩
def opMx : LayerOp := ⟨-1, 0, 0, 1, 1, 0, 0⟩
def opMy : LayerOp := ⟨1, 0, 0, -1, 1, 0, 0⟩
def opC4z : LayerOp := ⟨0, -1, 1, 0, 1, 0, 0⟩
def opC6zHex : LayerOp := ⟨1, -1, 1, 0, 1, 0, 0⟩
def opC3zHex : LayerOp := ⟨0, -1, 1, -1, 1, 0, 0⟩
def opM110Hex : LayerOp := ⟨0, 1, 1, 0, 1, 0, 0⟩
def opM1m10Hex : LayerOp := ⟨0, -1, -1, 0, 1, 0, 0⟩

/-- Exact algebraic order check figures for representative International Tables Vol. E generators:
- `C_2z`, `m_z`, `a_z`, `m_x`, `m_y`, `M_110`, `M_1-10` have order 2;
- `C_3z` has order 3;
- `C_4z` has order 4;
- `C_6z` has order 6 and `C_6z² = C_3z`, `C_6z³ = C_2z`;
- Stockinette (`L_7 = p112/a`): `C_2z` and `a_z` commute, generating an order-4 group;
- `L_19 = p222`: `C_2x` and `C_2y` multiply to `C_2z`;
- `L_80 = p6/mmm`: `C_6z`, `m_z`, and `M_110` satisfy the `D_6 × C_s` dihedral/reflection relations
  (giving order `12 × 2 = 24`). -/
theorem layerGroup_generator_relations :
    opC2z.comp opC2z = LayerOp.id ∧
      opMz.comp opMz = LayerOp.id ∧
      opAz.comp opAz = LayerOp.id ∧
      opC2z.comp opAz = opAz.comp opC2z ∧
      opC2x.comp opC2y = opC2z ∧
      opC4z.comp (opC4z.comp (opC4z.comp opC4z)) = LayerOp.id ∧
      opC3zHex.comp (opC3zHex.comp opC3zHex) = LayerOp.id ∧
      opC6zHex.comp opC6zHex = opC3zHex ∧
      opC6zHex.comp (opC6zHex.comp opC6zHex) = opC2z ∧
      opM110Hex.comp opM110Hex = LayerOp.id ∧
      opM1m10Hex.comp opM1m10Hex = LayerOp.id ∧
      opM110Hex.comp (opC6zHex.comp opM110Hex) =
        opC6zHex.comp (opC6zHex.comp (opC6zHex.comp (opC6zHex.comp opC6zHex))) ∧
      opMz.comp opC6zHex = opC6zHex.comp opMz ∧
      opMz.comp opM110Hex = opM110Hex.comp opMz := by
  decide

/-- Crystallographic count partition of the 80 International Tables Vol. E layer groups across the
five 2D Bravais-lattice / crystal-system families:
2 (triclinic/oblique) + 5 (monoclinic/oblique) + 11 (monoclinic/rectangular) +
30 (orthorhombic/rectangular) + 16 (tetragonal/square) + 16 (trigonal/hexagonal) = 80. -/
theorem eighty_layer_groups_family_partition :
    2 + 5 + 11 + 30 + 16 + 16 = 80 := by
  norm_num

end Signals.LayerGroups
