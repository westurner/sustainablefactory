import Mathlib.Analysis.Normed.Operator.Banach
import Signals.SatoGrassmannian.DeterminantBundle

/-!
# Explicit Group-Level 2-Cocycle on the Sato Big Cell

Ported from `data/chats/Gemini_Formalizing-Sato-Grassmannian-in-Lean_20261120-2337.md`
(block 015). Formalizes the canonical big-cell section `s(g) = ⟦(g, g₊₊)⟧ ∈ GL̂_(2)⁰(H)`,
the trace-class defect `g₊₊ h₊₊ (gh)₊₊⁻¹ ∈ 𝒯(H₊)`, the group-level 2-cocycle
`c(g, h) = det_Fr(g₊₊ h₊₊ (gh)₊₊⁻¹)`, its projective section law `s(g) s(h) = ι(c(g,h)) s(gh)`,
the 2-cocycle identity `c(g, h) c(gh, k) = c(g, hk) c(h, k)`, upper-triangular splitting
(`h₋₊ = 0 ⟹ c(g, h) = 1`), and the group commutator ratio `c(g, h) c(h, g)⁻¹`.
-/

open scoped InnerProductSpace

namespace Signals.SatoGrassmannian.BigCellCocycle

open Signals.SatoGrassmannian Signals.SatoGrassmannian.SchwingerCocycle
open Signals.SatoGrassmannian.DeterminantBundle

variable {ιP ιM : Type*} {H : Type*}
  [NormedAddCommGroup H] [InnerProductSpace ℂ H] [CompleteSpace H]

/-- Big-cell predicate on `GL_(2)⁰(H)`: the upper-left block `g₊₊ : H₊ →L H₊` is bijective. -/
def InBigCell {P : PolarizedHilbertSpace ℂ H}
    {eP : HilbertBasis ιP ℂ P.HPlus} {eM : HilbertBasis ιM ℂ P.HMinus}
    (g : GL2Res0 P eP eM) : Prop :=
  Function.Bijective (blockPP P (g.1.1 : H →L[ℂ] H))

/-- Invertible upper-left block `g₊₊ : H₊ ≃L[ℂ] H₊` via the Banach Open Mapping Theorem. -/
noncomputable def blockPPEquiv {P : PolarizedHilbertSpace ℂ H}
    {eP : HilbertBasis ιP ℂ P.HPlus} {eM : HilbertBasis ιM ℂ P.HMinus}
    (g : GL2Res0 P eP eM) (hg : InBigCell g) : P.HPlus ≃L[ℂ] P.HPlus :=
  ContinuousLinearEquiv.ofBijective (blockPP P (g.1.1 : H →L[ℂ] H))
    (LinearMap.ker_eq_bot.mpr hg.1) (LinearMap.range_eq_top.mpr hg.2)

/-- Canonical big-cell section `s(g) = ⟦(g, g₊₊)⟧ ∈ GL̂_(2)⁰(H)`. -/
noncomputable def bigCellSection {P : PolarizedHilbertSpace ℂ H}
    {eP : HilbertBasis ιP ℂ P.HPlus} {eM : HilbertBasis ιM ℂ P.HMinus}
    [FredholmDetTheory P eP eM]
    (g : GL2Res0 P eP eM) (hg : InBigCell g) : GL2CentralExt P eP eM :=
  QuotientGroup.mk ⟨(g, blockPPEquiv g hg), by
    change (blockPP P (g.1.1 : H →L[ℂ] H)).comp ((blockPPEquiv g hg).symm : P.HPlus →L[ℂ] P.HPlus) -
      ContinuousLinearMap.id ℂ P.HPlus ∈ TraceClassIdeal P eP eM
    have hid : (blockPP P (g.1.1 : H →L[ℂ] H)).comp ((blockPPEquiv g hg).symm : P.HPlus →L[ℂ] P.HPlus) =
        ContinuousLinearMap.id ℂ P.HPlus := by
      apply ContinuousLinearMap.ext; intro x; exact (blockPPEquiv g hg).apply_symm_apply x
    rw [hid, sub_self]; exact Submodule.zero_mem _⟩

theorem centralProj_bigCellSection {P : PolarizedHilbertSpace ℂ H}
    {eP : HilbertBasis ιP ℂ P.HPlus} {eM : HilbertBasis ιM ℂ P.HMinus}
    [FredholmDetTheory P eP eM] (g : GL2Res0 P eP eM) (hg : InBigCell g) :
    centralProj P eP eM (bigCellSection g hg) = g := rfl

/-- The defect operator `g₊₊ h₊₊ (gh)₊₊⁻¹ ∈ 𝒯(H₊)` for `g, h, gh` in the big cell. -/
noncomputable def bigCellDefect {P : PolarizedHilbertSpace ℂ H}
    {eP : HilbertBasis ιP ℂ P.HPlus} {eM : HilbertBasis ιM ℂ P.HMinus}
    (g h : GL2Res0 P eP eM) (hg : InBigCell g) (hh : InBigCell h) (hgh : InBigCell (g * h)) :
    TraceClassGroup P eP eM :=
  ⟨blockPPEquiv g hg * blockPPEquiv h hh * (blockPPEquiv (g * h) hgh)⁻¹, by
    have hsplit :
        ((blockPP P (g.1.1 : H →L[ℂ] H)).comp (blockPP P (h.1.1 : H →L[ℂ] H))).comp
          ((blockPPEquiv (g * h) hgh).symm : P.HPlus →L[ℂ] P.HPlus) -
          ContinuousLinearMap.id ℂ P.HPlus =
        -(((blockPM P (g.1.1 : H →L[ℂ] H)).comp (blockMP P (h.1.1 : H →L[ℂ] H))).comp
          ((blockPPEquiv (g * h) hgh).symm : P.HPlus →L[ℂ] P.HPlus)) := by
      apply ContinuousLinearMap.ext; intro x
      set y := (blockPPEquiv (g * h) hgh).symm x
      have hmul := congrArg (fun L : P.HPlus →L[ℂ] P.HPlus => L y)
        (blockPP_comp P (g.1.1 : H →L[ℂ] H) (h.1.1 : H →L[ℂ] H))
      have hghy : blockPP P ((g.1.1 : H →L[ℂ] H).comp (h.1.1 : H →L[ℂ] H)) y = x :=
        (blockPPEquiv (g * h) hgh).apply_symm_apply x
      rw [hghy] at hmul
      change blockPP P (g.1.1 : H →L[ℂ] H) (blockPP P (h.1.1 : H →L[ℂ] H) y) - x =
        -(blockPM P (g.1.1 : H →L[ℂ] H) (blockMP P (h.1.1 : H →L[ℂ] H) y))
      change x = blockPP P (g.1.1 : H →L[ℂ] H) (blockPP P (h.1.1 : H →L[ℂ] H) y) +
        blockPM P (g.1.1 : H →L[ℂ] H) (blockMP P (h.1.1 : H →L[ℂ] H) y) at hmul
      rw [hmul]
      abel
    change ((blockPP P (g.1.1 : H →L[ℂ] H)).comp (blockPP P (h.1.1 : H →L[ℂ] H))).comp
      ((blockPPEquiv (g * h) hgh).symm : P.HPlus →L[ℂ] P.HPlus) -
      ContinuousLinearMap.id ℂ P.HPlus ∈ TraceClassIdeal P eP eM
    rw [hsplit]
    exact Submodule.neg_mem _
      (TraceClassIdeal.comp_right (TraceClassIdeal.of_hs_cross g.1.2.1 h.1.2.2) _)⟩

/-- Explicit group-level 2-cocycle `c(g, h) = det_Fr(g₊₊ h₊₊ (gh)₊₊⁻¹) ∈ ℂˣ` on the big cell. -/
noncomputable def bigCellCocycle {P : PolarizedHilbertSpace ℂ H}
    {eP : HilbertBasis ιP ℂ P.HPlus} {eM : HilbertBasis ιM ℂ P.HMinus}
    [FredholmDetTheory P eP eM]
    (g h : GL2Res0 P eP eM) (hg : InBigCell g) (hh : InBigCell h) (hgh : InBigCell (g * h)) : ℂˣ :=
  detFrUnits P eP eM (bigCellDefect g h hg hh hgh)

/-- **Theorem 1.1 (Projective Section Law):** `s(g) * s(h) = ι(c(g, h)) * s(gh)`. -/
theorem bigCellSection_mul {P : PolarizedHilbertSpace ℂ H}
    {eP : HilbertBasis ιP ℂ P.HPlus} {eM : HilbertBasis ιM ℂ P.HMinus}
    [FredholmDetTheory P eP eM] [Nonempty ιP]
    (g h : GL2Res0 P eP eM) (hg : InBigCell g) (hh : InBigCell h) (hgh : InBigCell (g * h)) :
    bigCellSection g hg * bigCellSection h hh =
      centralIncl P eP eM (bigCellCocycle g h hg hh hgh) * bigCellSection (g * h) hgh := by
  unfold bigCellCocycle
  rw [centralIncl_detFrUnits]
  unfold bigCellSection
  rw [← QuotientGroup.mk_mul, ← QuotientGroup.mk_mul]
  congr 1
  apply Subtype.ext
  apply Prod.ext
  · simp [preCentralOfTraceClass]
  · change blockPPEquiv g hg * blockPPEquiv h hh =
      (blockPPEquiv g hg * blockPPEquiv h hh * (blockPPEquiv (g * h) hgh)⁻¹) *
        blockPPEquiv (g * h) hgh
    rw [inv_mul_cancel_right]

/-- **Theorem 1.2 (Group 2-Cocycle Identity on the Big Cell):**
`c(g, h) * c(gh, k) = c(g, hk) * c(h, k)` whenever `g, h, k, gh, hk, ghk` lie in the big cell. -/
theorem bigCellCocycle_isCocycle {P : PolarizedHilbertSpace ℂ H}
    {eP : HilbertBasis ιP ℂ P.HPlus} {eM : HilbertBasis ιM ℂ P.HMinus}
    [FredholmDetTheory P eP eM] [Nonempty ιP]
    (g h k : GL2Res0 P eP eM)
    (hg : InBigCell g) (hh : InBigCell h) (hk : InBigCell k)
    (hgh : InBigCell (g * h)) (hhk : InBigCell (h * k))
    (hghk : InBigCell (g * h * k)) :
    bigCellCocycle g h hg hh hgh * bigCellCocycle (g * h) k hgh hk hghk =
      bigCellCocycle g (h * k) hg hhk (by rwa [← mul_assoc]) * bigCellCocycle h k hh hk hhk := by
  have hghk' : InBigCell (g * (h * k)) := by rwa [← mul_assoc]
  have hL : (bigCellSection g hg * bigCellSection h hh) * bigCellSection k hk =
      centralIncl P eP eM (bigCellCocycle g h hg hh hgh * bigCellCocycle (g * h) k hgh hk hghk) *
        bigCellSection (g * h * k) hghk := by
    rw [bigCellSection_mul g h hg hh hgh, mul_assoc,
        bigCellSection_mul (g * h) k hgh hk hghk, ← mul_assoc, ← map_mul]
  have hR : bigCellSection g hg * (bigCellSection h hh * bigCellSection k hk) =
      centralIncl P eP eM (bigCellCocycle g (h * k) hg hhk hghk' * bigCellCocycle h k hh hk hhk) *
        bigCellSection (g * (h * k)) hghk' := by
    rw [bigCellSection_mul h k hh hk hhk]
    have hcomm := Subgroup.mem_center_iff.mp
      (centralIncl_mem_center P eP eM (bigCellCocycle h k hh hk hhk))
      (bigCellSection g hg)
    rw [← mul_assoc, hcomm, mul_assoc, bigCellSection_mul g (h * k) hg hhk hghk',
        ← mul_assoc, ← map_mul, mul_comm (bigCellCocycle h k hh hk hhk)]
  have hassoc : bigCellSection (g * h * k) hghk = bigCellSection (g * (h * k)) hghk' := by
    simp only [mul_assoc]
  have heq := hL.symm.trans ((mul_assoc _ _ _).trans hR)
  rw [← hassoc] at heq
  exact centralIncl_injective P eP eM (mul_right_cancel heq)

/-- **Corollary 1.3 (Canonical Splitting on Upper-Triangular / KP Flow Subgroups):**
Whenever `h₋₊ = 0` (as for all `kpFlow t ∈ Γ₊`), `c(g, h) = 1` and `s(g) s(h) = s(gh)`. -/
theorem bigCellCocycle_eq_one_of_blockMP_zero {P : PolarizedHilbertSpace ℂ H}
    {eP : HilbertBasis ιP ℂ P.HPlus} {eM : HilbertBasis ιM ℂ P.HMinus}
    [FredholmDetTheory P eP eM]
    (g h : GL2Res0 P eP eM) (hg : InBigCell g) (hh : InBigCell h) (hgh : InBigCell (g * h))
    (hMP : blockMP P (h.1.1 : H →L[ℂ] H) = 0) :
    bigCellCocycle g h hg hh hgh = 1 := by
  have hdef : bigCellDefect g h hg hh hgh = 1 := by
    apply Subtype.ext; apply DFunLike.ext; intro x
    set y := (blockPPEquiv (g * h) hgh).symm x
    have hmul := congrArg (fun L : P.HPlus →L[ℂ] P.HPlus => L y)
      (blockPP_comp P (g.1.1 : H →L[ℂ] H) (h.1.1 : H →L[ℂ] H))
    rw [hMP, ContinuousLinearMap.comp_zero, add_zero] at hmul
    have hghy : blockPP P ((g.1.1 : H →L[ℂ] H).comp (h.1.1 : H →L[ℂ] H)) y = x :=
      (blockPPEquiv (g * h) hgh).apply_symm_apply x
    rw [hghy] at hmul
    exact hmul.symm
  unfold bigCellCocycle
  rw [hdef, map_one]

/-- **Corollary 1.4 (Group Commutator Ratio):** For commuting big-cell elements `g h = h g`,
`s(g) s(h) s(g)⁻¹ s(h)⁻¹ = ι(c(g, h) c(h, g)⁻¹)`. -/
theorem bigCell_commutator_eq {P : PolarizedHilbertSpace ℂ H}
    {eP : HilbertBasis ιP ℂ P.HPlus} {eM : HilbertBasis ιM ℂ P.HMinus}
    [FredholmDetTheory P eP eM] [Nonempty ιP]
    (g h : GL2Res0 P eP eM) (hcomm : g * h = h * g)
    (hg : InBigCell g) (hh : InBigCell h) (hgh : InBigCell (g * h)) :
    let hhg : InBigCell (h * g) := hcomm ▸ hgh
    bigCellSection g hg * bigCellSection h hh *
      (bigCellSection g hg)⁻¹ * (bigCellSection h hh)⁻¹ =
      centralIncl P eP eM (bigCellCocycle g h hg hh hgh * (bigCellCocycle h g hh hg hhg)⁻¹) := by
  intro hhg
  have h1 := bigCellSection_mul g h hg hh hgh
  have h2 := bigCellSection_mul h g hh hg hhg
  have hsEq : bigCellSection (g * h) hgh = bigCellSection (h * g) hhg := by
    congr 1
  rw [hsEq] at h1
  calc bigCellSection g hg * bigCellSection h hh *
          (bigCellSection g hg)⁻¹ * (bigCellSection h hh)⁻¹
      = (bigCellSection g hg * bigCellSection h hh) *
          (bigCellSection h hh * bigCellSection g hg)⁻¹ := by
          rw [mul_inv_rev, mul_assoc]
    _ = (centralIncl P eP eM (bigCellCocycle g h hg hh hgh) * bigCellSection (h * g) hhg) *
          (centralIncl P eP eM (bigCellCocycle h g hh hg hhg) * bigCellSection (h * g) hhg)⁻¹ := by
          rw [h1, h2]
    _ = centralIncl P eP eM (bigCellCocycle g h hg hh hgh) *
          (bigCellSection (h * g) hhg * (bigCellSection (h * g) hhg)⁻¹) *
          (centralIncl P eP eM (bigCellCocycle h g hh hg hhg))⁻¹ := by
          rw [mul_inv_rev]; group
    _ = centralIncl P eP eM (bigCellCocycle g h hg hh hgh * (bigCellCocycle h g hh hg hhg)⁻¹) := by
          rw [mul_inv_cancel, mul_one, ← map_inv, ← map_mul]

end Signals.SatoGrassmannian.BigCellCocycle
