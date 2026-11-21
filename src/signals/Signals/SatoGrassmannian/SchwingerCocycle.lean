import Mathlib.Analysis.InnerProductSpace.Adjoint
import Mathlib.Analysis.InnerProductSpace.l2Space
import Mathlib.Algebra.Lie.Basic
import Mathlib.Topology.Algebra.InfiniteSum.Order
import Signals.SatoGrassmannian.Base
import Signals.SatoGrassmannian.CircleL2
import Signals.SatoGrassmannian.RemainingGaps
import Signals.SatoGrassmannian.CarlemanWeierstrass

open scoped InnerProductSpace BigOperators

namespace Signals.SatoGrassmannian.SchwingerCocycle

open Signals.SatoGrassmannian Signals.SatoGrassmannian.CircleL2
open Signals.SatoGrassmannian.RemainingGaps Signals.SatoGrassmannian.CarlemanWeierstrass

/-! ### Section 1: Hilbert–Schmidt Ideal Closure, Adjoint Symmetry & Trace Cyclicity -/

section HilbertSchmidtCalculus

variable {ι₁ ι₂ : Type*} {E F G : Type*}
  [NormedAddCommGroup E] [InnerProductSpace ℂ E] [CompleteSpace E]
  [NormedAddCommGroup F] [InnerProductSpace ℂ F] [CompleteSpace F]
  [NormedAddCommGroup G] [InnerProductSpace ℂ G] [CompleteSpace G]

/-- Hilbert–Schmidt predicate between two complex Hilbert spaces relative to a basis of the domain. -/
def IsHS (eE : HilbertBasis ι₁ ℂ E) (T : E →L[ℂ] F) : Prop :=
  Summable (fun i : ι₁ => ‖T (eE i)‖ ^ 2)

omit [CompleteSpace E] in
/-- Parseval norm-square identity derived directly from `HilbertBasis.hasSum_inner_mul_inner`. -/
lemma hasSum_norm_inner_sq (e : HilbertBasis ι₁ ℂ E) (x : E) :
    HasSum (fun i : ι₁ => ‖⟪e i, x⟫_ℂ‖ ^ 2) (‖x‖ ^ 2) := by
  have h := (e.hasSum_inner_mul_inner x x).map Complex.reAddGroupHom Complex.continuous_re
  have hL : (⇑Complex.reAddGroupHom ∘ fun i => ⟪x, e i⟫_ℂ * ⟪e i, x⟫_ℂ) =
      fun i => ‖⟪e i, x⟫_ℂ‖ ^ 2 := by
    funext i
    change (⟪x, e i⟫_ℂ * ⟪e i, x⟫_ℂ).re = ‖⟪e i, x⟫_ℂ‖ ^ 2
    rw [← inner_conj_symm (e i) x, Complex.mul_conj, Complex.ofReal_re,
      Complex.normSq_eq_norm_sq, RCLike.norm_conj]
  have hR : Complex.reAddGroupHom ⟪x, x⟫_ℂ = ‖x‖ ^ 2 := by
    change (⟪x, x⟫_ℂ).re = ‖x‖ ^ 2
    rw [inner_self_eq_norm_sq_to_K]
    norm_cast
  rwa [hL, hR] at h

omit [CompleteSpace E] [CompleteSpace F] in
lemma IsHS.zero (eE : HilbertBasis ι₁ ℂ E) : IsHS eE (0 : E →L[ℂ] F) := by
  unfold IsHS; simp

omit [CompleteSpace E] [CompleteSpace F] in
lemma IsHS.neg {eE : HilbertBasis ι₁ ℂ E} {T : E →L[ℂ] F} (hT : IsHS eE T) :
    IsHS eE (-T) := by
  unfold IsHS at hT ⊢; simpa using hT

omit [CompleteSpace E] [CompleteSpace F] in
lemma IsHS.add {eE : HilbertBasis ι₁ ℂ E} {S T : E →L[ℂ] F}
    (hS : IsHS eE S) (hT : IsHS eE T) : IsHS eE (S + T) := by
  refine Summable.of_nonneg_of_le (fun _ => sq_nonneg _) (fun i => ?_)
    ((Summable.add hS hT).mul_left 2)
  have htri : ‖(S + T) (eE i)‖ ≤ ‖S (eE i)‖ + ‖T (eE i)‖ := norm_add_le _ _
  nlinarith [sq_nonneg (‖S (eE i)‖ - ‖T (eE i)‖), norm_nonneg ((S + T) (eE i))]

omit [CompleteSpace E] [CompleteSpace F] in
lemma IsHS.sub {eE : HilbertBasis ι₁ ℂ E} {S T : E →L[ℂ] F}
    (hS : IsHS eE S) (hT : IsHS eE T) : IsHS eE (S - T) := by
  rw [sub_eq_add_neg]; exact hS.add hT.neg

omit [CompleteSpace E] [CompleteSpace F] in
lemma IsHS.smul {eE : HilbertBasis ι₁ ℂ E} {T : E →L[ℂ] F} (c : ℂ) (hT : IsHS eE T) :
    IsHS eE (c • T) := by
  refine Summable.of_nonneg_of_le (fun _ => sq_nonneg _) (fun i => ?_)
    (Summable.mul_left (‖c‖ ^ 2) hT)
  simp [norm_smul, mul_pow]

omit [CompleteSpace E] [CompleteSpace F] [CompleteSpace G] in
/-- Left-ideal closure of `IsHS` under bounded composition. -/
lemma IsHS.comp_left {eE : HilbertBasis ι₁ ℂ E} {T : E →L[ℂ] F}
    (hT : IsHS eE T) (A : F →L[ℂ] G) : IsHS eE (A.comp T) := by
  refine Summable.of_nonneg_of_le (fun _ => sq_nonneg _) (fun i => ?_)
    (Summable.mul_left (‖A‖ ^ 2) hT)
  calc ‖A (T (eE i))‖ ^ 2 ≤ (‖A‖ * ‖T (eE i)‖) ^ 2 :=
        pow_le_pow_left₀ (norm_nonneg _) (A.le_opNorm _) 2
    _ = ‖A‖ ^ 2 * ‖T (eE i)‖ ^ 2 := mul_pow _ _ 2

/-- **Adjoint Symmetry of Hilbert–Schmidt Operators:** `T ∈ ℐ₂ ⟹ T† ∈ ℐ₂`. -/
theorem IsHS.adjoint {eE : HilbertBasis ι₁ ℂ E} {eF : HilbertBasis ι₂ ℂ F}
    {T : E →L[ℂ] F} (hT : IsHS eE T) :
    IsHS eF (ContinuousLinearMap.adjoint T) := by
  let g : ι₁ × ι₂ → ℝ := fun p => ‖⟪eF p.2, T (eE p.1)⟫_ℂ‖ ^ 2
  have hg_nonneg : ∀ p, 0 ≤ g p := fun _ => sq_nonneg _
  have hg_summ : Summable g := by
    rw [summable_prod_of_nonneg hg_nonneg]
    refine ⟨fun i => (hasSum_norm_inner_sq eF (T (eE i))).summable, ?_⟩
    exact hT.congr fun i => (hasSum_norm_inner_sq eF (T (eE i))).tsum_eq.symm
  have hg_swap : Summable (fun q : ι₂ × ι₁ => g (q.2, q.1)) :=
    hg_summ.comp_injective (Equiv.prodComm ι₂ ι₁).injective
  rw [summable_prod_of_nonneg (fun q => hg_nonneg (q.2, q.1))] at hg_swap
  refine hg_swap.2.congr fun j => ?_
  have hparseval := (hasSum_norm_inner_sq eE (ContinuousLinearMap.adjoint T (eF j))).tsum_eq
  rw [← hparseval]
  refine tsum_congr fun i => ?_
  dsimp [g]
  rw [ContinuousLinearMap.adjoint_inner_right, ← inner_conj_symm (T (eE i)) (eF j), RCLike.norm_conj]

/-- Right-ideal closure of `IsHS` under bounded composition via adjoint symmetry. -/
theorem IsHS.comp_right {eE : HilbertBasis ι₁ ℂ E} {eF : HilbertBasis ι₂ ℂ F}
    {T : E →L[ℂ] F} (hT : IsHS eE T) (B : E →L[ℂ] E) :
    IsHS eE (T.comp B) := by
  have h1 : IsHS eF ((ContinuousLinearMap.adjoint B).comp (ContinuousLinearMap.adjoint T)) :=
    (hT.adjoint (eF := eF)).comp_left (ContinuousLinearMap.adjoint B)
  have h2 : ContinuousLinearMap.adjoint (T.comp B) =
      (ContinuousLinearMap.adjoint B).comp (ContinuousLinearMap.adjoint T) :=
    ContinuousLinearMap.adjoint_comp T B
  have h3 : IsHS eE (ContinuousLinearMap.adjoint (ContinuousLinearMap.adjoint (T.comp B))) := by
    rw [h2]; exact h1.adjoint (eF := eE)
  simpa [ContinuousLinearMap.adjoint_adjoint] using h3

/-- Hilbert–Schmidt trace pairing `Tr_E(X ∘ Y) = ∑' i, ⟪e_i, X (Y e_i)⟫` for `X : F →L E`, `Y : E →L F`. -/
noncomputable def hsPairTrace (eE : HilbertBasis ι₁ ℂ E) (X : F →L[ℂ] E) (Y : E →L[ℂ] F) : ℂ :=
  ∑' i : ι₁, ⟪eE i, X (Y (eE i))⟫_ℂ

/-- Absolute summability of the diagonal trace series for any pair of Hilbert–Schmidt operators. -/
lemma summable_hsPairTrace {eE : HilbertBasis ι₁ ℂ E} {eF : HilbertBasis ι₂ ℂ F}
    {X : F →L[ℂ] E} {Y : E →L[ℂ] F} (hX : IsHS eF X) (hY : IsHS eE Y) :
    Summable (fun i : ι₁ => ⟪eE i, X (Y (eE i))⟫_ℂ) := by
  have hXadj : IsHS eE (ContinuousLinearMap.adjoint X) := hX.adjoint (eF := eE)
  refine Summable.of_norm_bounded ((Summable.add hXadj hY).mul_left (1 / 2)) fun i => ?_
  rw [← ContinuousLinearMap.adjoint_inner_left]
  have hcs := @norm_inner_le_norm ℂ F _ _ _ (ContinuousLinearMap.adjoint X (eE i)) (Y (eE i))
  nlinarith [sq_nonneg (‖ContinuousLinearMap.adjoint X (eE i)‖ - ‖Y (eE i)‖)]

/-- **Theorem 1.1 (Trace Cyclicity `Tr_E(X ∘ Y) = Tr_F(Y ∘ X)`):** -/
theorem hsPairTrace_cyclicity {eE : HilbertBasis ι₁ ℂ E} {eF : HilbertBasis ι₂ ℂ F}
    {X : F →L[ℂ] E} {Y : E →L[ℂ] F} (hX : IsHS eF X) (hY : IsHS eE Y) :
    hsPairTrace eE X Y = hsPairTrace eF Y X := by
  let a : ι₁ → ι₂ → ℂ := fun i j => ⟪ContinuousLinearMap.adjoint X (eE i), eF j⟫_ℂ * ⟪eF j, Y (eE i)⟫_ℂ
  have hNorm1 : Summable (fun p : ι₁ × ι₂ => ‖⟪ContinuousLinearMap.adjoint X (eE p.1), eF p.2⟫_ℂ‖ ^ 2) := by
    rw [summable_prod_of_nonneg (fun _ => sq_nonneg _)]
    refine ⟨fun i => ?_, ?_⟩
    · exact (hasSum_norm_inner_sq eF (ContinuousLinearMap.adjoint X (eE i))).summable.congr fun j => by
        rw [← inner_conj_symm (ContinuousLinearMap.adjoint X (eE i)) (eF j), RCLike.norm_conj]
    · refine (hX.adjoint (eF := eE)).congr fun i => ?_
      rw [← (hasSum_norm_inner_sq eF (ContinuousLinearMap.adjoint X (eE i))).tsum_eq]
      exact tsum_congr fun j => by
        rw [← inner_conj_symm (ContinuousLinearMap.adjoint X (eE i)) (eF j), RCLike.norm_conj]
  have hNorm2 : Summable (fun p : ι₁ × ι₂ => ‖⟪eF p.2, Y (eE p.1)⟫_ℂ‖ ^ 2) := by
    rw [summable_prod_of_nonneg (fun _ => sq_nonneg _)]
    refine ⟨fun i => (hasSum_norm_inner_sq eF (Y (eE i))).summable, ?_⟩
    exact hY.congr fun i => (hasSum_norm_inner_sq eF (Y (eE i))).tsum_eq.symm
  have hJoint : Summable a.uncurry := by
    refine Summable.of_norm_bounded ((hNorm1.add hNorm2).mul_left (1 / 2)) fun p => ?_
    dsimp [a, Function.uncurry]
    rw [norm_mul]
    nlinarith [sq_nonneg (‖⟪ContinuousLinearMap.adjoint X (eE p.1), eF p.2⟫_ℂ‖ - ‖⟪eF p.2, Y (eE p.1)⟫_ℂ‖)]
  have hRow : ∀ i, Summable (a i) := fun i =>
    (eF.hasSum_inner_mul_inner (ContinuousLinearMap.adjoint X (eE i)) (Y (eE i))).summable
  have hCol : ∀ j, Summable (fun i => a i j) := fun j => by
    have h := (eE.hasSum_inner_mul_inner (ContinuousLinearMap.adjoint Y (eF j)) (X (eF j))).summable
    refine h.congr fun i => ?_
    dsimp [a]
    rw [ContinuousLinearMap.adjoint_inner_left, ContinuousLinearMap.adjoint_inner_left, mul_comm]
  unfold hsPairTrace
  calc ∑' i : ι₁, ⟪eE i, X (Y (eE i))⟫_ℂ
      = ∑' i : ι₁, ∑' j : ι₂, a i j := by
        refine tsum_congr fun i => ?_
        rw [← ContinuousLinearMap.adjoint_inner_left]
        exact (eF.hasSum_inner_mul_inner _ _).tsum_eq.symm
    _ = ∑' j : ι₂, ∑' i : ι₁, a i j := by
        let b : ι₂ → ι₁ → ℂ := fun j i => a i j
        have hJoint' : Summable b.uncurry :=
          (hJoint.comp_injective (Equiv.prodComm ι₂ ι₁).injective).congr fun ⟨_, _⟩ => rfl
        exact Summable.tsum_comm' (f := b) hJoint' hCol hRow
    _ = ∑' j : ι₂, ⟪eF j, Y (X (eF j))⟫_ℂ := by
        refine tsum_congr fun j => ?_
        rw [← ContinuousLinearMap.adjoint_inner_left]
        rw [← (eE.hasSum_inner_mul_inner (ContinuousLinearMap.adjoint Y (eF j)) (X (eF j))).tsum_eq]
        refine tsum_congr fun i => ?_
        dsimp [a]
        rw [ContinuousLinearMap.adjoint_inner_left, ContinuousLinearMap.adjoint_inner_left, mul_comm]

/-- **Corollary (Diagonal Trace Commutation):** `Tr_E((D ∘ X) ∘ Y) = Tr_E(X ∘ (Y ∘ D))`
for bounded `D : E →L E` and Hilbert–Schmidt `X, Y`. -/
theorem hsPairTrace_mul_diag {eE : HilbertBasis ι₁ ℂ E} {eF : HilbertBasis ι₂ ℂ F}
    (D : E →L[ℂ] E) {X : F →L[ℂ] E} {Y : E →L[ℂ] F} (hX : IsHS eF X) (hY : IsHS eE Y) :
    hsPairTrace eE (D.comp X) Y = hsPairTrace eE X (Y.comp D) := by
  rw [hsPairTrace_cyclicity (hX.comp_left D) hY,
      hsPairTrace_cyclicity hX (hY.comp_right (eF := eF) D)]
  rfl

lemma hsPairTrace_add_left {eE : HilbertBasis ι₁ ℂ E} {eF : HilbertBasis ι₂ ℂ F}
    {X₁ X₂ : F →L[ℂ] E} {Y : E →L[ℂ] F} (hX₁ : IsHS eF X₁) (hX₂ : IsHS eF X₂) (hY : IsHS eE Y) :
    hsPairTrace eE (X₁ + X₂) Y = hsPairTrace eE X₁ Y + hsPairTrace eE X₂ Y := by
  unfold hsPairTrace
  have hfun : (fun i => ⟪eE i, (X₁ + X₂) (Y (eE i))⟫_ℂ) =
      fun i => ⟪eE i, X₁ (Y (eE i))⟫_ℂ + ⟪eE i, X₂ (Y (eE i))⟫_ℂ := by
    funext i; simp [inner_add_right]
  rw [hfun, (summable_hsPairTrace hX₁ hY).tsum_add (summable_hsPairTrace hX₂ hY)]

lemma hsPairTrace_add_right {eE : HilbertBasis ι₁ ℂ E} {eF : HilbertBasis ι₂ ℂ F}
    {X : F →L[ℂ] E} {Y₁ Y₂ : E →L[ℂ] F} (hX : IsHS eF X) (hY₁ : IsHS eE Y₁) (hY₂ : IsHS eE Y₂) :
    hsPairTrace eE X (Y₁ + Y₂) = hsPairTrace eE X Y₁ + hsPairTrace eE X Y₂ := by
  unfold hsPairTrace
  have hfun : (fun i => ⟪eE i, X ((Y₁ + Y₂) (eE i))⟫_ℂ) =
      fun i => ⟪eE i, X (Y₁ (eE i))⟫_ℂ + ⟪eE i, X (Y₂ (eE i))⟫_ℂ := by
    funext i; simp [map_add, inner_add_right]
  rw [hfun, (summable_hsPairTrace hX hY₁).tsum_add (summable_hsPairTrace hX hY₂)]

omit [CompleteSpace E] [CompleteSpace F] in
lemma hsPairTrace_neg_left (eE : HilbertBasis ι₁ ℂ E) (X : F →L[ℂ] E) (Y : E →L[ℂ] F) :
    hsPairTrace eE (-X) Y = -hsPairTrace eE X Y := by
  unfold hsPairTrace; simp [inner_neg_right, tsum_neg]

omit [CompleteSpace E] [CompleteSpace F] in
lemma hsPairTrace_neg_right (eE : HilbertBasis ι₁ ℂ E) (X : F →L[ℂ] E) (Y : E →L[ℂ] F) :
    hsPairTrace eE X (-Y) = -hsPairTrace eE X Y := by
  unfold hsPairTrace; simp [map_neg, inner_neg_right, tsum_neg]

lemma hsPairTrace_sub_left {eE : HilbertBasis ι₁ ℂ E} {eF : HilbertBasis ι₂ ℂ F}
    {X₁ X₂ : F →L[ℂ] E} {Y : E →L[ℂ] F} (hX₁ : IsHS eF X₁) (hX₂ : IsHS eF X₂) (hY : IsHS eE Y) :
    hsPairTrace eE (X₁ - X₂) Y = hsPairTrace eE X₁ Y - hsPairTrace eE X₂ Y := by
  rw [sub_eq_add_neg, hsPairTrace_add_left hX₁ hX₂.neg hY, hsPairTrace_neg_left, sub_eq_add_neg]

lemma hsPairTrace_sub_right {eE : HilbertBasis ι₁ ℂ E} {eF : HilbertBasis ι₂ ℂ F}
    {X : F →L[ℂ] E} {Y₁ Y₂ : E →L[ℂ] F} (hX : IsHS eF X) (hY₁ : IsHS eE Y₁) (hY₂ : IsHS eE Y₂) :
    hsPairTrace eE X (Y₁ - Y₂) = hsPairTrace eE X Y₁ - hsPairTrace eE X Y₂ := by
  rw [sub_eq_add_neg, hsPairTrace_add_right hX hY₁ hY₂.neg, hsPairTrace_neg_right, sub_eq_add_neg]

omit [CompleteSpace E] [CompleteSpace F] in
lemma hsPairTrace_smul_left (eE : HilbertBasis ι₁ ℂ E) (c : ℂ) (X : F →L[ℂ] E) (Y : E →L[ℂ] F) :
    hsPairTrace eE (c • X) Y = c * hsPairTrace eE X Y := by
  unfold hsPairTrace; simp [inner_smul_right, tsum_mul_left]

omit [CompleteSpace E] [CompleteSpace F] in
lemma hsPairTrace_smul_right (eE : HilbertBasis ι₁ ℂ E) (c : ℂ) (X : F →L[ℂ] E) (Y : E →L[ℂ] F) :
    hsPairTrace eE X (c • Y) = c * hsPairTrace eE X Y := by
  unfold hsPairTrace; simp [map_smul, inner_smul_right, tsum_mul_left]

end HilbertSchmidtCalculus

/-! ### Section 2: Restricted Group `GL_(2)(H)`, Lie Algebra `gl_(2)(H)` & Schwinger 2-Cocycle -/

section RestrictedGL2AndCocycle

variable {ιP ιM : Type*} {H : Type*}
  [NormedAddCommGroup H] [InnerProductSpace ℂ H] [CompleteSpace H]

lemma blockPM_comp (P : PolarizedHilbertSpace ℂ H) (A B : H →L[ℂ] H) :
    blockPM P (A.comp B) =
      (blockPP P A).comp (blockPM P B) + (blockPM P A).comp (blockMM P B) := by
  ext y
  have hBy : B (y : H) =
      ((blockPM P B y : P.HPlus) : H) + ((blockMM P B y : P.HMinus) : H) :=
    (pPlus_add_pMinus P (B (y : H))).symm
  simp only [blockPM, blockPP, blockMM, ContinuousLinearMap.comp_apply,
    add_apply, Submodule.coe_subtypeL, Submodule.coe_subtype]
  conv_lhs => rw [hBy, map_add, map_add]
  rfl

lemma blockMP_comp (P : PolarizedHilbertSpace ℂ H) (A B : H →L[ℂ] H) :
    blockMP P (A.comp B) =
      (blockMP P A).comp (blockPP P B) + (blockMM P A).comp (blockMP P B) := by
  ext x
  have hBx : B (x : H) =
      ((blockPP P B x : P.HPlus) : H) + ((blockMP P B x : P.HMinus) : H) :=
    (pPlus_add_pMinus P (B (x : H))).symm
  simp only [blockMP, blockPP, blockMM, ContinuousLinearMap.comp_apply,
    add_apply, Submodule.coe_subtypeL, Submodule.coe_subtype]
  conv_lhs => rw [hBx, map_add, map_add]
  rfl

/-- Polarized direct-sum Hilbert basis `eP ⊕ eM` of `H = H₊ ⊕ H₋`. -/
noncomputable def polarizedBasis (P : PolarizedHilbertSpace ℂ H)
    (eP : HilbertBasis ιP ℂ P.HPlus) (eM : HilbertBasis ιM ℂ P.HMinus) :
    HilbertBasis (ιP ⊕ ιM) ℂ H := by
  classical
  let v : ιP ⊕ ιM → H := Sum.elim (fun i => (eP i : H)) (fun j => (eM j : H))
  have hortho : Orthonormal ℂ v := by
    rw [orthonormal_iff_ite]
    rintro (i₁ | j₁) (i₂ | j₂)
    · simpa [v] using orthonormal_iff_ite.mp eP.orthonormal i₁ i₂
    · have h0 : ⟪(eP i₁ : H), (eM j₂ : H)⟫_ℂ = 0 := by
        have hm : (eM j₂ : H) ∈ P.HPlusᗮ := P.ortho_eq ▸ (eM j₂).2
        exact hm (eP i₁ : H) (eP i₁).2
      simp [v, h0]
    · have h0 : ⟪(eM j₁ : H), (eP i₂ : H)⟫_ℂ = 0 := by
        have hm : (eM j₁ : H) ∈ P.HPlusᗮ := P.ortho_eq ▸ (eM j₁).2
        exact inner_eq_zero_symm.mp (hm (eP i₂ : H) (eP i₂).2)
      simp [v, h0]
    · simpa [v] using orthonormal_iff_ite.mp eM.orthonormal j₁ j₂
  have hdense : ⊤ ≤ (Submodule.span ℂ (Set.range v)).topologicalClosure := by
    intro x _
    have hsplit : x = (P.HPlus.orthogonalProjectionOnto x : H) + (P.HMinus.orthogonalProjectionOnto x : H) :=
      (pPlus_add_pMinus P x).symm
    have hclosed : IsClosed ((Submodule.span ℂ (Set.range v)).topologicalClosure : Set H) :=
      isClosed_closure
    have hplus : (P.HPlus.orthogonalProjectionOnto x : H) ∈
        (Submodule.span ℂ (Set.range v)).topologicalClosure := by
      have hsum := (eP.hasSum_repr (P.HPlus.orthogonalProjectionOnto x)).map
        P.HPlus.subtypeL.toAddMonoidHom P.HPlus.subtypeL.continuous
      refine hclosed.mem_of_tendsto hsum ?_
      filter_upwards with s
      refine Submodule.sum_mem _ fun i _ => Submodule.smul_mem _ _ ?_
      exact Submodule.le_topologicalClosure _ (Submodule.subset_span ⟨Sum.inl i, rfl⟩)
    have hminus : (P.HMinus.orthogonalProjectionOnto x : H) ∈
        (Submodule.span ℂ (Set.range v)).topologicalClosure := by
      have hsum := (eM.hasSum_repr (P.HMinus.orthogonalProjectionOnto x)).map
        P.HMinus.subtypeL.toAddMonoidHom P.HMinus.subtypeL.continuous
      refine hclosed.mem_of_tendsto hsum ?_
      filter_upwards with s
      refine Submodule.sum_mem _ fun j _ => Submodule.smul_mem _ _ ?_
      exact Submodule.le_topologicalClosure _ (Submodule.subset_span ⟨Sum.inr j, rfl⟩)
    rw [hsplit]
    exact Submodule.add_mem _ hplus hminus
  exact HilbertBasis.mk hortho hdense

/-- `[J, A]` is Hilbert–Schmidt iff both off-diagonal blocks `A₊₋` and `A₋₊` are Hilbert–Schmidt. -/
theorem isHS_commutator_J_iff (P : PolarizedHilbertSpace ℂ H)
    (eP : HilbertBasis ιP ℂ P.HPlus) (eM : HilbertBasis ιM ℂ P.HMinus) (A : H →L[ℂ] H) :
    IsHS (polarizedBasis P eP eM) ((polarizationJ P).comp A - A.comp (polarizationJ P)) ↔
      IsHS eM (blockPM P A) ∧ IsHS eP (blockMP P A) := by
  have h1 : ∀ i : ιP,
      ‖((polarizationJ P).comp A - A.comp (polarizationJ P))
        (polarizedBasis P eP eM (Sum.inl i))‖ ^ 2 = 4 * ‖blockMP P A (eP i)‖ ^ 2 := by
    intro i
    rw [commutator_J_eq]
    have he : polarizedBasis P eP eM (Sum.inl i) = (eP i : H) := by simp [polarizedBasis]
    rw [he]
    simp only [smul_apply, sub_apply, ContinuousLinearMap.comp_apply,
      Submodule.coe_subtypeL, Submodule.coe_subtype,
      orthoProj_minus_of_mem_plus, map_zero, zero_sub, norm_smul, norm_neg]
    have hproj : P.HPlus.orthogonalProjectionOnto (eP i : H) = eP i :=
      Submodule.orthogonalProjectionOnto_mem_subspace_eq_self (eP i)
    rw [hproj]
    norm_num; ring
  have h2 : ∀ j : ιM,
      ‖((polarizationJ P).comp A - A.comp (polarizationJ P))
        (polarizedBasis P eP eM (Sum.inr j))‖ ^ 2 = 4 * ‖blockPM P A (eM j)‖ ^ 2 := by
    intro j
    rw [commutator_J_eq]
    have he : polarizedBasis P eP eM (Sum.inr j) = (eM j : H) := by simp [polarizedBasis]
    rw [he]
    simp only [smul_apply, sub_apply, ContinuousLinearMap.comp_apply,
      Submodule.coe_subtypeL, Submodule.coe_subtype,
      orthoProj_plus_of_mem_minus, map_zero, sub_zero, norm_smul]
    have hproj : P.HMinus.orthogonalProjectionOnto (eM j : H) = eM j :=
      Submodule.orthogonalProjectionOnto_mem_subspace_eq_self (eM j)
    rw [hproj]
    norm_num; ring
  unfold IsHS
  constructor
  · intro h
    refine ⟨?_, ?_⟩
    · have hr : Summable (fun j : ιM => 4 * ‖blockPM P A (eM j)‖ ^ 2) :=
        (h.comp_injective Sum.inr_injective).congr fun j => h2 j
      exact (summable_mul_left_iff (by norm_num : (4 : ℝ) ≠ 0)).mp hr
    · have hl : Summable (fun i : ιP => 4 * ‖blockMP P A (eP i)‖ ^ 2) :=
        (h.comp_injective Sum.inl_injective).congr fun i => h1 i
      exact (summable_mul_left_iff (by norm_num : (4 : ℝ) ≠ 0)).mp hl
  · rintro ⟨hPM, hMP⟩
    let g₁ : ιP ⊕ ιM → ℝ := Sum.elim (fun i => 4 * ‖blockMP P A (eP i)‖ ^ 2) (fun _ => 0)
    let g₂ : ιP ⊕ ιM → ℝ := Sum.elim (fun _ => 0) (fun j => 4 * ‖blockPM P A (eM j)‖ ^ 2)
    have hg₁ : Summable g₁ :=
      (Sum.inl_injective.summable_iff (f := g₁) (by
        rintro (_ | j) hne
        · exact absurd ⟨_, rfl⟩ hne
        · rfl)).mp (hMP.mul_left 4)
    have hg₂ : Summable g₂ :=
      (Sum.inr_injective.summable_iff (f := g₂) (by
        rintro (i | _) hne
        · rfl
        · exact absurd ⟨_, rfl⟩ hne)).mp (hPM.mul_left 4)
    refine (hg₁.add hg₂).congr ?_
    rintro (i | j)
    · simpa [g₁, g₂] using (h1 i).symm
    · simpa [g₁, g₂] using (h2 j).symm

/-- **Theorem 1.2 (Hilbert–Schmidt Restricted Group `GL_(2)(H)`):**
Invertible operators with Hilbert–Schmidt off-diagonal blocks form a subgroup of `GL(H)`. -/
noncomputable def GL2Res (P : PolarizedHilbertSpace ℂ H)
    (eP : HilbertBasis ιP ℂ P.HPlus) (eM : HilbertBasis ιM ℂ P.HMinus) :
    Subgroup (H ≃L[ℂ] H) where
  carrier := { g | IsHS eM (blockPM P (g : H →L[ℂ] H)) ∧ IsHS eP (blockMP P (g : H →L[ℂ] H)) }
  one_mem' := by
    change IsHS eM _ ∧ IsHS eP _
    rw [← isHS_commutator_J_iff]
    change IsHS _ ((polarizationJ P).comp (ContinuousLinearMap.id ℂ H) -
      (ContinuousLinearMap.id ℂ H).comp (polarizationJ P))
    simp [IsHS.zero]
  mul_mem' := by
    intro g h hg hh
    change IsHS eM _ ∧ IsHS eP _ at hg hh ⊢
    rw [← isHS_commutator_J_iff] at hg hh ⊢
    have hderiv :
        (polarizationJ P).comp ((g : H →L[ℂ] H).comp (h : H →L[ℂ] H)) -
          ((g : H →L[ℂ] H).comp (h : H →L[ℂ] H)).comp (polarizationJ P) =
        ((polarizationJ P).comp (g : H →L[ℂ] H) - (g : H →L[ℂ] H).comp (polarizationJ P)).comp
          (h : H →L[ℂ] H) +
        (g : H →L[ℂ] H).comp
          ((polarizationJ P).comp (h : H →L[ℂ] H) - (h : H →L[ℂ] H).comp (polarizationJ P)) := by
      ext x; simp [ContinuousLinearMap.comp_apply]
    change IsHS _ ((polarizationJ P).comp ((g : H →L[ℂ] H).comp (h : H →L[ℂ] H)) -
      ((g : H →L[ℂ] H).comp (h : H →L[ℂ] H)).comp (polarizationJ P))
    rw [hderiv]
    exact (hg.comp_right (eF := polarizedBasis P eP eM) (h : H →L[ℂ] H)).add
      (hh.comp_left (g : H →L[ℂ] H))
  inv_mem' := by
    intro g hg
    change IsHS eM _ ∧ IsHS eP _ at hg ⊢
    rw [← isHS_commutator_J_iff] at hg ⊢
    have hinv :
        (polarizationJ P).comp (g.symm : H →L[ℂ] H) -
          (g.symm : H →L[ℂ] H).comp (polarizationJ P) =
        -((g.symm : H →L[ℂ] H).comp
          (((polarizationJ P).comp (g : H →L[ℂ] H) - (g : H →L[ℂ] H).comp (polarizationJ P)).comp
            (g.symm : H →L[ℂ] H))) := by
      ext x
      simp only [sub_apply, ContinuousLinearMap.comp_apply,
        neg_apply, map_sub, ContinuousLinearEquiv.coe_coe,
        ContinuousLinearEquiv.apply_symm_apply, ContinuousLinearEquiv.symm_apply_apply]
      abel
    change IsHS _ ((polarizationJ P).comp (g.symm : H →L[ℂ] H) -
      (g.symm : H →L[ℂ] H).comp (polarizationJ P))
    rw [hinv]
    exact ((hg.comp_right (eF := polarizedBasis P eP eM) (g.symm : H →L[ℂ] H)).comp_left
      (g.symm : H →L[ℂ] H)).neg

/-- Restricted Lie algebra `gl_(2)(H)` of bounded operators with Hilbert–Schmidt off-diagonal blocks. -/
noncomputable def gl2ResAlg (P : PolarizedHilbertSpace ℂ H)
    (eP : HilbertBasis ιP ℂ P.HPlus) (eM : HilbertBasis ιM ℂ P.HMinus) :
    Subalgebra ℂ (H →L[ℂ] H) where
  carrier := { A | IsHS eM (blockPM P A) ∧ IsHS eP (blockMP P A) }
  one_mem' := by
    change IsHS eM _ ∧ IsHS eP _
    rw [← isHS_commutator_J_iff]
    change IsHS _ ((polarizationJ P).comp (ContinuousLinearMap.id ℂ H) -
      (ContinuousLinearMap.id ℂ H).comp (polarizationJ P))
    simp [IsHS.zero]
  zero_mem' := by
    change IsHS eM _ ∧ IsHS eP _
    rw [← isHS_commutator_J_iff]; simp [IsHS.zero]
  add_mem' := fun {A B} hA hB => by
    change IsHS eM _ ∧ IsHS eP _ at hA hB ⊢
    rw [← isHS_commutator_J_iff] at hA hB ⊢
    have heq : (polarizationJ P).comp (A + B) - (A + B).comp (polarizationJ P) =
        ((polarizationJ P).comp A - A.comp (polarizationJ P)) +
        ((polarizationJ P).comp B - B.comp (polarizationJ P)) := by
      ext x; simp; abel
    rw [heq]; exact hA.add hB
  mul_mem' := fun {A B} hA hB => by
    change IsHS eM _ ∧ IsHS eP _ at hA hB ⊢
    rw [← isHS_commutator_J_iff] at hA hB ⊢
    have hderiv : (polarizationJ P).comp (A.comp B) - (A.comp B).comp (polarizationJ P) =
        ((polarizationJ P).comp A - A.comp (polarizationJ P)).comp B +
        A.comp ((polarizationJ P).comp B - B.comp (polarizationJ P)) := by
      ext x; simp [ContinuousLinearMap.comp_apply]
    change IsHS _ ((polarizationJ P).comp (A.comp B) - (A.comp B).comp (polarizationJ P))
    rw [hderiv]
    exact (hA.comp_right (eF := polarizedBasis P eP eM) B).add (hB.comp_left A)
  algebraMap_mem' := fun c => by
    change IsHS eM _ ∧ IsHS eP _
    rw [← isHS_commutator_J_iff]
    have heq : (polarizationJ P).comp (algebraMap ℂ (H →L[ℂ] H) c) -
        (algebraMap ℂ (H →L[ℂ] H) c).comp (polarizationJ P) = 0 := by
      ext x; simp [Algebra.algebraMap_eq_smul_one]
    rw [heq]; exact IsHS.zero _

/-- The **Schwinger / Kac–Peterson 2-cocycle** `ω(A, B) = Tr_{H₊}(A₊₋ B₋₊ - B₊₋ A₋₊)`. -/
noncomputable def schwingerCocycle (P : PolarizedHilbertSpace ℂ H)
    (eP : HilbertBasis ιP ℂ P.HPlus) (A B : H →L[ℂ] H) : ℂ :=
  hsPairTrace eP (blockPM P A) (blockMP P B) - hsPairTrace eP (blockPM P B) (blockMP P A)

theorem schwingerCocycle_self (P : PolarizedHilbertSpace ℂ H)
    (eP : HilbertBasis ιP ℂ P.HPlus) (A : H →L[ℂ] H) :
    schwingerCocycle P eP A A = 0 :=
  sub_self _

theorem schwingerCocycle_antisymm (P : PolarizedHilbertSpace ℂ H)
    (eP : HilbertBasis ιP ℂ P.HPlus) (A B : H →L[ℂ] H) :
    schwingerCocycle P eP B A = -schwingerCocycle P eP A B := by
  unfold schwingerCocycle; ring

/-- **Theorem 1.3 (Chevalley–Eilenberg 2-Cocycle / Jacobi Identity for `ω`):**
For all `A, B, C ∈ gl_(2)(H)`, `ω([A, B], C) + ω([B, C], A) + ω([C, A], B) = 0`. -/
theorem schwingerCocycle_jacobi (P : PolarizedHilbertSpace ℂ H)
    (eP : HilbertBasis ιP ℂ P.HPlus) (eM : HilbertBasis ιM ℂ P.HMinus)
    {A B C : H →L[ℂ] H}
    (hA : A ∈ gl2ResAlg P eP eM) (hB : B ∈ gl2ResAlg P eP eM) (hC : C ∈ gl2ResAlg P eP eM) :
    schwingerCocycle P eP (A * B - B * A) C +
    schwingerCocycle P eP (B * C - C * B) A +
    schwingerCocycle P eP (C * A - A * C) B = 0 := by
  have hexpand : ∀ {X Y Z : H →L[ℂ] H},
      X ∈ gl2ResAlg P eP eM → Y ∈ gl2ResAlg P eP eM → Z ∈ gl2ResAlg P eP eM →
      schwingerCocycle P eP (X * Y - Y * X) Z =
        (hsPairTrace eP ((blockPP P X).comp (blockPM P Y)) (blockMP P Z) +
         hsPairTrace eP ((blockPM P X).comp (blockMM P Y)) (blockMP P Z) -
         hsPairTrace eP ((blockPP P Y).comp (blockPM P X)) (blockMP P Z) -
         hsPairTrace eP ((blockPM P Y).comp (blockMM P X)) (blockMP P Z)) -
        (hsPairTrace eP (blockPM P Z) ((blockMP P X).comp (blockPP P Y)) +
         hsPairTrace eP (blockPM P Z) ((blockMM P X).comp (blockMP P Y)) -
         hsPairTrace eP (blockPM P Z) ((blockMP P Y).comp (blockPP P X)) -
         hsPairTrace eP (blockPM P Z) ((blockMM P Y).comp (blockMP P X))) := by
    intro X Y Z hX hY hZ
    have hPM : blockPM P (X * Y - Y * X) =
        ((blockPP P X).comp (blockPM P Y) + (blockPM P X).comp (blockMM P Y)) -
        ((blockPP P Y).comp (blockPM P X) + (blockPM P Y).comp (blockMM P X)) := by
      have hsub : blockPM P (X * Y - Y * X) = blockPM P (X.comp Y) - blockPM P (Y.comp X) := by
        ext u; simp [blockPM]
      rw [hsub, blockPM_comp, blockPM_comp]
    have hMP : blockMP P (X * Y - Y * X) =
        ((blockMP P X).comp (blockPP P Y) + (blockMM P X).comp (blockMP P Y)) -
        ((blockMP P Y).comp (blockPP P X) + (blockMM P Y).comp (blockMP P X)) := by
      have hsub : blockMP P (X * Y - Y * X) = blockMP P (X.comp Y) - blockMP P (Y.comp X) := by
        ext u; simp [blockMP]
      rw [hsub, blockMP_comp, blockMP_comp]
    unfold schwingerCocycle
    rw [hPM, hMP]
    have h1 := hY.1.comp_left (blockPP P X)
    have h2 := hX.1.comp_right (eF := eP) (blockMM P Y)
    have h3 := hX.1.comp_left (blockPP P Y)
    have h4 := hY.1.comp_right (eF := eP) (blockMM P X)
    have h5 := hX.2.comp_right (eF := eM) (blockPP P Y)
    have h6 := hY.2.comp_left (blockMM P X)
    have h7 := hY.2.comp_right (eF := eM) (blockPP P X)
    have h8 := hX.2.comp_left (blockMM P Y)
    rw [hsPairTrace_sub_left (h1.add h2) (h3.add h4) hZ.2,
        hsPairTrace_add_left h1 h2 hZ.2, hsPairTrace_add_left h3 h4 hZ.2,
        hsPairTrace_sub_right hZ.1 (h5.add h6) (h7.add h8),
        hsPairTrace_add_right hZ.1 h5 h6, hsPairTrace_add_right hZ.1 h7 h8]
    ring
  rw [hexpand hA hB hC, hexpand hB hC hA, hexpand hC hA hB]
  have cA1 := hsPairTrace_mul_diag (eE := eP) (eF := eM) (blockPP P A) hB.1 hC.2
  have cA2 := hsPairTrace_mul_diag (eE := eP) (eF := eM) (blockPP P A) hC.1 hB.2
  have cB1 := hsPairTrace_mul_diag (eE := eP) (eF := eM) (blockPP P B) hC.1 hA.2
  have cB2 := hsPairTrace_mul_diag (eE := eP) (eF := eM) (blockPP P B) hA.1 hC.2
  have cC1 := hsPairTrace_mul_diag (eE := eP) (eF := eM) (blockPP P C) hA.1 hB.2
  have cC2 := hsPairTrace_mul_diag (eE := eP) (eF := eM) (blockPP P C) hB.1 hA.2
  have m1 : hsPairTrace eP ((blockPM P A).comp (blockMM P B)) (blockMP P C) =
      hsPairTrace eP (blockPM P A) ((blockMM P B).comp (blockMP P C)) := rfl
  have m2 : hsPairTrace eP ((blockPM P B).comp (blockMM P A)) (blockMP P C) =
      hsPairTrace eP (blockPM P B) ((blockMM P A).comp (blockMP P C)) := rfl
  have m3 : hsPairTrace eP ((blockPM P B).comp (blockMM P C)) (blockMP P A) =
      hsPairTrace eP (blockPM P B) ((blockMM P C).comp (blockMP P A)) := rfl
  have m4 : hsPairTrace eP ((blockPM P C).comp (blockMM P B)) (blockMP P A) =
      hsPairTrace eP (blockPM P C) ((blockMM P B).comp (blockMP P A)) := rfl
  have m5 : hsPairTrace eP ((blockPM P C).comp (blockMM P A)) (blockMP P B) =
      hsPairTrace eP (blockPM P C) ((blockMM P A).comp (blockMP P B)) := rfl
  have m6 : hsPairTrace eP ((blockPM P A).comp (blockMM P C)) (blockMP P B) =
      hsPairTrace eP (blockPM P A) ((blockMM P C).comp (blockMP P B)) := rfl
  linear_combination cA1 - cA2 + cB1 - cB2 + cC1 - cC2 + m1 - m2 + m3 - m4 + m5 - m6

/-- **Central Extension `gl̂_(2)(H) = gl_(2)(H) ⊕ ℂ·c`:**
Bracket `[(A, α), (B, β)] = ([A, B], ω(A, B))`. -/
structure CentralExtElem (P : PolarizedHilbertSpace ℂ H)
    (eP : HilbertBasis ιP ℂ P.HPlus) (eM : HilbertBasis ιM ℂ P.HMinus) where
  op : gl2ResAlg P eP eM
  central : ℂ

noncomputable def centralBracket (P : PolarizedHilbertSpace ℂ H)
    (eP : HilbertBasis ιP ℂ P.HPlus) (eM : HilbertBasis ιM ℂ P.HMinus)
    (X Y : CentralExtElem P eP eM) : CentralExtElem P eP eM :=
  ⟨⟨X.op.1 * Y.op.1 - Y.op.1 * X.op.1,
    Subalgebra.sub_mem _ (Subalgebra.mul_mem _ X.op.2 Y.op.2) (Subalgebra.mul_mem _ Y.op.2 X.op.2)⟩,
   schwingerCocycle P eP X.op.1 Y.op.1⟩

/-- The central extension bracket satisfies the Jacobi identity unconditionally. -/
theorem centralBracket_jacobi (P : PolarizedHilbertSpace ℂ H)
    (eP : HilbertBasis ιP ℂ P.HPlus) (eM : HilbertBasis ιM ℂ P.HMinus)
    (X Y Z : CentralExtElem P eP eM) :
    let B := centralBracket P eP eM
    (B (B X Y) Z).op.1 + (B (B Y Z) X).op.1 + (B (B Z X) Y).op.1 = 0 ∧
    (B (B X Y) Z).central + (B (B Y Z) X).central + (B (B Z X) Y).central = 0 :=
  ⟨by dsimp [centralBracket]; noncomm_ring,
   schwingerCocycle_jacobi P eP eM X.op.2 Y.op.2 Z.op.2⟩

end RestrictedGL2AndCocycle

/-! ### Section 3: Non-Triviality on `L²(S¹)` & Diagonal `det₂` Group Cocycle Shadow -/

section CircleNonTrivialityAndDet2Shadow

/-- Orthonormal Hardy basis `{ eₙ | n ∈ ℕ }` of `H₊ ≤ L²(S¹)`. -/
noncomputable def hardyPlusBasis : HilbertBasis ℕ ℂ hardyPolarization.HPlus := by
  let v : ℕ → hardyPolarization.HPlus := fun n => ⟨eBasis (n : ℤ), mem_hardyPlus_basis n⟩
  have hortho : Orthonormal ℂ v := by
    rw [orthonormal_iff_ite]
    intro m n
    change ⟪eBasis (m : ℤ), eBasis (n : ℤ)⟫_ℂ = if m = n then 1 else 0
    have h := orthonormal_iff_ite.mp eBasis.orthonormal (m : ℤ) (n : ℤ)
    simpa using h
  have hdense : ⊤ ≤ (Submodule.span ℂ (Set.range v)).topologicalClosure := by
    rintro ⟨f, hf⟩ _
    have hsum := eBasis.hasSum_repr f
    have hsum_sub : HasSum (fun n : ℕ => eBasis.repr f (n : ℤ) • v n) ⟨f, hf⟩ := by
      have hproj : HasSum (fun k : ℤ => hardyPlus.orthogonalProjectionOnto (eBasis.repr f k • eBasis k))
          (hardyPlus.orthogonalProjectionOnto f) :=
        hsum.map hardyPlus.orthogonalProjectionOnto.toAddMonoidHom
          hardyPlus.orthogonalProjectionOnto.continuous
      have hself : hardyPlus.orthogonalProjectionOnto f = ⟨f, hf⟩ :=
        Submodule.orthogonalProjectionOnto_mem_subspace_eq_self ⟨f, hf⟩
      rw [hself] at hproj
      have hzero : ∀ k : ℤ, k ∉ Set.range (Nat.cast : ℕ → ℤ) →
          hardyPlus.orthogonalProjectionOnto (eBasis.repr f k • eBasis k) = 0 := by
        intro k hk
        have hlt : k < 0 := by
          by_contra hge; push Not at hge
          lift k to ℕ using hge
          exact hk ⟨k, rfl⟩
        rw [(mem_hardyPlus_iff f).mp hf k hlt, zero_smul, map_zero]
      have hnat := (hasSum_subtype_iff_of_support_subset (s := Set.range (Nat.cast : ℕ → ℤ))
        (f := fun k : ℤ => hardyPlus.orthogonalProjectionOnto (eBasis.repr f k • eBasis k))
        (fun k hk => by
          by_contra hnot
          exact hk (hzero k hnot))).mpr hproj
      let eNat : ℕ ≃ Set.range (Nat.cast : ℕ → ℤ) :=
        Equiv.ofBijective (fun n : ℕ => ⟨(n : ℤ), ⟨n, rfl⟩⟩)
          ⟨fun _ _ h => Int.ofNat.inj (congrArg Subtype.val h), fun ⟨_, n, rfl⟩ => ⟨n, rfl⟩⟩
      have hnat' := (eNat.hasSum_iff).mpr hnat
      refine hnat'.congr_fun fun n => ?_
      symm
      change hardyPlus.orthogonalProjectionOnto (eBasis.repr f (n : ℤ) • eBasis (n : ℤ)) = _
      rw [map_smul]
      congr 1
      exact Submodule.orthogonalProjectionOnto_mem_subspace_eq_self (v n)
    have hclosed : IsClosed ((Submodule.span ℂ (Set.range v)).topologicalClosure : Set hardyPolarization.HPlus) :=
      isClosed_closure
    refine hclosed.mem_of_tendsto hsum_sub ?_
    filter_upwards with s
    exact Submodule.sum_mem _ fun n _ =>
      Submodule.smul_mem _ _ (Submodule.le_topologicalClosure _ (Submodule.subset_span ⟨n, rfl⟩))
  exact HilbertBasis.mk hortho hdense

/-- Orthogonal projection onto `H₋` preserves all negative Fourier coefficients `n < 0`. -/
lemma repr_projMinus_of_neg (x : HCircle) {n : ℤ} (hn : n < 0) :
    eBasis.repr (hardyMinus.orthogonalProjectionOnto x : HCircle) n = eBasis.repr x n := by
  have hmem : eBasis n ∈ hardyMinus := by
    rw [mem_hardyMinus_iff]
    intro k hk
    rw [HilbertBasis.repr_self, lp.single_apply]
    have hne : k ≠ n := by omega
    simp [hne]
  rw [HilbertBasis.repr_apply_apply, HilbertBasis.repr_apply_apply]
  have hortho : x - (hardyMinus.orthogonalProjectionOnto x : HCircle) ∈ hardyMinusᗮ :=
    Submodule.sub_starProjection_mem_orthogonal x
  have h0 : ⟪eBasis n, x - (hardyMinus.orthogonalProjectionOnto x : HCircle)⟫_ℂ = 0 :=
    hortho (eBasis n) hmem
  rw [inner_sub_right] at h0
  exact (sub_eq_zero.mp h0).symm

/-- **Theorem 1.4 (Non-Triviality of the Schwinger 2-Cocycle on `L²(S¹)`):**
Although `M_{z⁻¹}` and `M_z` commute in `B(L²(S¹))`, `ω(M_{z⁻¹}, M_z) = -1 ≠ 0`,
producing the canonical Heisenberg central term `[Ŝ⁻¹, Ŝ] = -c`. -/
theorem schwingerCocycle_shiftInv_shift :
    schwingerCocycle hardyPolarization hardyPlusBasis
      (shiftCLE.symm : HCircle →L[ℂ] HCircle) (shiftCLE : HCircle →L[ℂ] HCircle) = -1 := by
  unfold schwingerCocycle hsPairTrace
  have h1 : ∀ n : ℕ,
      ⟪hardyPlusBasis n, blockPM hardyPolarization (shiftCLE.symm : HCircle →L[ℂ] HCircle)
        (blockMP hardyPolarization (shiftCLE : HCircle →L[ℂ] HCircle) (hardyPlusBasis n))⟫_ℂ = 0 := by
    intro n
    rw [blockMP_shift_eq_zero]; simp
  have h2 : ∀ n : ℕ,
      ⟪hardyPlusBasis n, blockPM hardyPolarization (shiftCLE : HCircle →L[ℂ] HCircle)
        (blockMP hardyPolarization (shiftCLE.symm : HCircle →L[ℂ] HCircle) (hardyPlusBasis n))⟫_ℂ =
      if n = 0 then 1 else 0 := by
    intro n
    rw [blockPM_shift_eq_rankOne]
    have hbn : (hardyPlusBasis n : HCircle) = eBasis (n : ℤ) := by
      simp [hardyPlusBasis]
    have hcoeff : eBasis.repr
        ((blockMP hardyPolarization (shiftCLE.symm : HCircle →L[ℂ] HCircle) (hardyPlusBasis n) :
          hardyPolarization.HMinus) : HCircle) (-1) = if n = 0 then 1 else 0 := by
      change eBasis.repr (hardyMinus.orthogonalProjectionOnto (shiftL2.symm (hardyPlusBasis n : HCircle)) : HCircle) (-1) = _
      rw [repr_projMinus_of_neg _ (by norm_num), repr_shiftL2_symm, hbn,
        HilbertBasis.repr_self, lp.single_apply]
      norm_num
      by_cases h0 : n = 0
      · subst h0; simp
      · have hne : (0 : ℤ) ≠ (n : ℤ) := by omega
        simp [h0, hne]
    rw [hcoeff, inner_smul_right]
    change (if n = 0 then (1 : ℂ) else 0) * ⟪(hardyPlusBasis n : HCircle), eBasis 0⟫_ℂ = _
    rw [hbn]
    by_cases h0 : n = 0
    · subst h0
      simp only [↓reduceIte, one_mul, Nat.cast_zero]
      rw [inner_self_eq_norm_sq_to_K, eBasis.orthonormal.1 0]
      norm_num
    · simp [h0]
  rw [tsum_congr h1, tsum_zero, tsum_congr h2, tsum_ite_eq, zero_sub]

/-- **Theorem 1.5 (Diagonal `det₂` Group 2-Cocycle Shadow):**
On the abelian Hilbert–Schmidt torus `(ℓ²(ι), ⋆)` with circle composition
`(lam ⋆ μ)_i = lam_i + μ_i + lam_i μ_i`, the multiplicative anomaly
`Φ(lam, μ) = exp(-∑' i, lam_i μ_i)` from `det2Diag_mul_anomaly` satisfies the exact
multiplicative group 2-cocycle identity `Φ(lam, μ) Φ(lam ⋆ μ, ν) = Φ(lam, μ ⋆ ν) Φ(μ, ν)`. -/
noncomputable def det2TorusCocycle {ι : Type*} (lam μ : ι → ℂ) : ℂ :=
  Complex.exp (-∑' i : ι, lam i * μ i)

theorem det2TorusCocycle_isCocycle {ι : Type*} {lam μ ν : ι → ℂ}
    (hlam : Summable (fun i : ι => ‖lam i‖ ^ 2))
    (hμ : Summable (fun i : ι => ‖μ i‖ ^ 2))
    (hν : Summable (fun i : ι => ‖ν i‖ ^ 2)) :
    let comp : (ι → ℂ) → (ι → ℂ) → (ι → ℂ) := fun a b i => a i + b i + a i * b i
    det2TorusCocycle lam μ * det2TorusCocycle (comp lam μ) ν =
      det2TorusCocycle lam (comp μ ν) * det2TorusCocycle μ ν := by
  intro comp
  have hlamμ := (det2Diag_mul_anomaly hlam hμ).1
  have hlamν := (det2Diag_mul_anomaly hlam hν).1
  have hμν := (det2Diag_mul_anomaly hμ hν).1
  have hν_bdd : ∃ M : ℝ, 0 ≤ M ∧ ∀ i, ‖ν i‖ ≤ M := by
    let S := ∑' i : ι, ‖ν i‖ ^ 2
    refine ⟨max 1 S, by positivity, fun i => ?_⟩
    have hsq : ‖ν i‖ ^ 2 ≤ max 1 S :=
      le_trans (hν.le_tsum i fun _ _ => sq_nonneg _) (le_max_right 1 S)
    by_cases h1 : ‖ν i‖ ≤ 1
    · exact le_trans h1 (le_max_left 1 S)
    · push Not at h1
      nlinarith
  obtain ⟨M, hM, hνM⟩ := hν_bdd
  have hlamμν : Summable (fun i : ι => lam i * μ i * ν i) := by
    refine Summable.of_norm_bounded (hlamμ.norm.mul_right M) fun i => ?_
    rw [norm_mul]
    exact mul_le_mul_of_nonneg_left (hνM i) (norm_nonneg _)
  have hLHS_sum : ∑' i : ι, (comp lam μ i) * ν i =
      (∑' i, lam i * ν i) + (∑' i, μ i * ν i) + (∑' i, lam i * μ i * ν i) := by
    have hfun : (fun i => comp lam μ i * ν i) =
        fun i => (lam i * ν i + μ i * ν i) + lam i * μ i * ν i := by funext i; dsimp [comp]; ring
    rw [hfun, (hlamν.add hμν).tsum_add hlamμν, hlamν.tsum_add hμν]
  have hRHS_sum : ∑' i : ι, lam i * (comp μ ν i) =
      (∑' i, lam i * μ i) + (∑' i, lam i * ν i) + (∑' i, lam i * μ i * ν i) := by
    have hfun : (fun i => lam i * comp μ ν i) =
        fun i => (lam i * μ i + lam i * ν i) + lam i * μ i * ν i := by funext i; dsimp [comp]; ring
    rw [hfun, (hlamμ.add hlamν).tsum_add hlamμν, hlamμ.tsum_add hlamν]
  unfold det2TorusCocycle
  rw [← Complex.exp_add, ← Complex.exp_add, hLHS_sum, hRHS_sum]
  congr 1; ring

end CircleNonTrivialityAndDet2Shadow

end Signals.SatoGrassmannian.SchwingerCocycle
