import Mathlib.Analysis.Fourier.AddCircle
import Mathlib.Analysis.Normed.Module.FiniteDimension
import Mathlib.LinearAlgebra.Dimension.Finrank
import Signals.SatoGrassmannian.Base
import Signals.SatoGrassmannian.RieszSchauder
import Signals.SatoGrassmannian.CircleL2

open scoped InnerProductSpace

namespace Signals.SatoGrassmannian.Gr24Truncation

open Signals.SatoGrassmannian Signals.SatoGrassmannian.CircleL2

/-- Ambient 4-dimensional complex vector space `ℂ⁴` for the Fourier window `{-2, -1, 0, 1}`. -/
abbrev C4 := Fin 4 → ℂ

/-- The finite-dimensional complex Grassmannian `Gr_ℂ(2, 4)` of 2-planes in `ℂ⁴`. -/
abbrev Gr24 := { U : Submodule ℂ C4 // Module.finrank ℂ U = 2 }

/-! ### Window Embedding `ι₄ : ℂ⁴ ↪ L²(S¹)` and Evaluation `π₄ : L²(S¹) ↠ ℂ⁴` -/

/-- Isometric embedding of `ℂ⁴` onto `span {e₋₂, e₋₁, e₀, e₁} ≤ L²(S¹)`. -/
noncomputable def windowEmbed : C4 →L[ℂ] HCircle :=
  ∑ j : Fin 4, (ContinuousLinearMap.proj (R := ℂ) (φ := fun _ : Fin 4 => ℂ) j).smulRight
    (eBasis ((j : ℤ) - 2))

/-- Continuous Fourier-window extraction `f ↦ (f̂(-2), f̂(-1), f̂(0), f̂(1))`. -/
noncomputable def windowEval : HCircle →L[ℂ] C4 :=
  ContinuousLinearMap.pi fun j : Fin 4 => innerSL ℂ (eBasis ((j : ℤ) - 2))

lemma windowEval_apply (f : HCircle) (j : Fin 4) :
    windowEval f j = eBasis.repr f ((j : ℤ) - 2) := by
  simp [windowEval, HilbertBasis.repr_apply_apply]

lemma repr_windowEmbed_window (u : C4) (j : Fin 4) :
    eBasis.repr (windowEmbed u) ((j : ℤ) - 2) = u j := by
  simp only [windowEmbed, sum_apply, ContinuousLinearMap.smulRight_apply,
    ContinuousLinearMap.proj_apply, map_sum, map_smul, lp.coeFn_sum, lp.coeFn_smul,
    Finset.sum_apply, Pi.smul_apply, smul_eq_mul, HilbertBasis.repr_self, lp.single_apply]
  rw [Finset.sum_eq_single j]
  · simp
  · intro k _ hkj
    have hne : (j : ℤ) - 2 ≠ (k : ℤ) - 2 := by
      intro h; exact hkj (Fin.ext (by omega)).symm
    simp [hne]
  · intro h; exact absurd (Finset.mem_univ j) h

lemma repr_windowEmbed_of_lt (u : C4) {n : ℤ} (hn : n < -2) :
    eBasis.repr (windowEmbed u) n = 0 := by
  simp only [windowEmbed, sum_apply, ContinuousLinearMap.smulRight_apply,
    ContinuousLinearMap.proj_apply, map_sum, map_smul, lp.coeFn_sum, lp.coeFn_smul,
    Finset.sum_apply, Pi.smul_apply, smul_eq_mul, HilbertBasis.repr_self, lp.single_apply]
  refine Finset.sum_eq_zero fun k _ => ?_
  have hne : n ≠ (k : ℤ) - 2 := by omega
  simp [hne]

lemma repr_windowEmbed_of_ge (u : C4) {n : ℤ} (hn : 2 ≤ n) :
    eBasis.repr (windowEmbed u) n = 0 := by
  simp only [windowEmbed, sum_apply, ContinuousLinearMap.smulRight_apply,
    ContinuousLinearMap.proj_apply, map_sum, map_smul, lp.coeFn_sum, lp.coeFn_smul,
    Finset.sum_apply, Pi.smul_apply, smul_eq_mul, HilbertBasis.repr_self, lp.single_apply]
  refine Finset.sum_eq_zero fun k _ => ?_
  have hk : (k : ℤ) < 4 := by exact_mod_cast k.isLt
  have hne : n ≠ (k : ℤ) - 2 := by omega
  simp [hne]

lemma windowEval_windowEmbed (u : C4) : windowEval (windowEmbed u) = u := by
  ext j
  rw [windowEval_apply, repr_windowEmbed_window]

/-- Orthogonal projection onto `H₋` preserves all strictly negative Fourier modes. -/
lemma repr_projMinus_of_neg (x : HCircle) {n : ℤ} (hn : n < 0) :
    eBasis.repr (hardyMinus.orthogonalProjectionOnto x : HCircle) n = eBasis.repr x n := by
  rw [HilbertBasis.repr_apply_apply, HilbertBasis.repr_apply_apply]
  have he_mem : eBasis n ∈ hardyMinus := by
    rw [mem_hardyMinus_iff]
    intro k hk
    rw [HilbertBasis.repr_apply_apply, eBasis.orthonormal.inner_eq_zero]
    omega
  have hortho : x - (hardyMinus.orthogonalProjectionOnto x : HCircle) ∈ hardyMinusᗮ :=
    Submodule.sub_starProjection_mem_orthogonal x
  have h0 : ⟪eBasis n, x - (hardyMinus.orthogonalProjectionOnto x : HCircle)⟫_ℂ = 0 :=
    hortho (eBasis n) he_mem
  rw [inner_sub_right] at h0
  exact (sub_eq_zero.mp h0).symm

/-! ### Finite-Rank Truncated Subspace `Ψ(U) = H_{≥ 2} ⊕ ι₄(U)` -/

/-- The high-frequency tail `H_{≥ 2} = { f ∈ L²(S¹) | ∀ n < 2, f̂(n) = 0 }`. -/
noncomputable def hardyGe2 : Submodule ℂ HCircle where
  carrier := { f : HCircle | ∀ n : ℤ, n < 2 → eBasis.repr f n = 0 }
  add_mem' ha hb n hn := by simp [ha n hn, hb n hn]
  zero_mem' _ _ := by simp
  smul_mem' c _ ha n hn := by simp [ha n hn]

/-- The truncated subspace `Ψ(U) ≤ L²(S¹)` associated to `U ≤ ℂ⁴`. -/
noncomputable def truncSubspace (U : Submodule ℂ C4) : Submodule ℂ HCircle where
  carrier := { f : HCircle | (∀ n : ℤ, n < -2 → eBasis.repr f n = 0) ∧ windowEval f ∈ U }
  add_mem' := fun ⟨h1a, h1b⟩ ⟨h2a, h2b⟩ =>
    ⟨fun n hn => by simp [h1a n hn, h2a n hn], by rw [map_add]; exact U.add_mem h1b h2b⟩
  zero_mem' := ⟨fun _ _ => by simp, by rw [map_zero]; exact U.zero_mem⟩
  smul_mem' := fun c _ ⟨ha, hb⟩ =>
    ⟨fun n hn => by simp [ha n hn], by rw [map_smul]; exact U.smul_mem c hb⟩

/-- Explicit direct-sum identification `Ψ(U) = H_{≥ 2} ⊔ ι₄(U)`. -/
theorem truncSubspace_eq_sup (U : Submodule ℂ C4) :
    truncSubspace U = hardyGe2 ⊔ U.map windowEmbed.toLinearMap := by
  apply le_antisymm
  · intro f ⟨hf_neg, hf_win⟩
    let u : C4 := windowEval f
    have hge2 : f - windowEmbed u ∈ hardyGe2 := by
      intro n hn
      rw [map_sub, lp.coeFn_sub, Pi.sub_apply]
      by_cases hlt : n < -2
      · rw [hf_neg n hlt, repr_windowEmbed_of_lt u hlt, sub_self]
      · push Not at hlt
        let j : Fin 4 := ⟨(n + 2).toNat, by omega⟩
        have hj : (j : ℤ) - 2 = n := by dsimp [j]; omega
        rw [← hj, repr_windowEmbed_window, ← windowEval_apply, sub_self]
    have hsplit : f = (f - windowEmbed u) + windowEmbed u := (sub_add_cancel _ _).symm
    rw [hsplit]
    exact Submodule.add_mem_sup hge2 ⟨u, hf_win, rfl⟩
  · refine sup_le ?_ ?_
    · intro f hf
      refine ⟨fun n hn => hf n (by omega), ?_⟩
      have h0 : windowEval f = 0 := by
        ext j
        rw [windowEval_apply]
        have hj : (j : ℤ) < 4 := by exact_mod_cast j.isLt
        exact hf ((j : ℤ) - 2) (by omega)
      rw [h0]; exact U.zero_mem
    · rintro _ ⟨u, hu, rfl⟩
      exact ⟨fun n hn => repr_windowEmbed_of_lt u hn, by
        change windowEval (windowEmbed u) ∈ U
        rwa [windowEval_windowEmbed]⟩

lemma truncSubspace_isClosed (U : Submodule ℂ C4) :
    IsClosed (truncSubspace U : Set HCircle) := by
  have heq : (truncSubspace U : Set HCircle) =
      (⋂ n : ℤ, ⋂ _ : n < -2, (innerSL ℂ (eBasis n)) ⁻¹' {0}) ∩
      (windowEval ⁻¹' (U : Set C4)) := by
    ext f
    simp only [SetLike.mem_coe, truncSubspace, Submodule.mem_mk, AddSubmonoid.mem_mk,
      AddSubsemigroup.mem_mk, Set.mem_ofPred_eq, Set.mem_inter_iff, Set.mem_iInter,
      Set.mem_preimage, Set.mem_singleton_iff, HilbertBasis.repr_apply_apply]
    rfl
  rw [heq]
  refine (isClosed_iInter fun n => isClosed_iInter fun _ =>
    isClosed_singleton.preimage (innerSL ℂ (eBasis n)).continuous).inter ?_
  exact (Submodule.closed_of_finiteDimensional U).preimage windowEval.continuous

lemma projMinus_truncSubspace_isCompact (U : Submodule ℂ C4) :
    IsCompactOperator (projMinus hardyPolarization (truncSubspace U)) := by
  have he_m2 : eBasis (-2) ∈ hardyMinus := by
    rw [mem_hardyMinus_iff]; intro k hk
    rw [HilbertBasis.repr_apply_apply, eBasis.orthonormal.inner_eq_zero]; omega
  have he_m1 : eBasis (-1) ∈ hardyMinus := by
    rw [mem_hardyMinus_iff]; intro k hk
    rw [HilbertBasis.repr_apply_apply, eBasis.orthonormal.inner_eq_zero]; omega
  let b1 : hardyPolarization.HMinus := ⟨eBasis (-2), he_m2⟩
  let b2 : hardyPolarization.HMinus := ⟨eBasis (-1), he_m1⟩
  have hle : LinearMap.range (projMinus hardyPolarization (truncSubspace U)).toLinearMap ≤
      Submodule.span ℂ ({b1, b2} : Set hardyPolarization.HMinus) := by
    rintro _ ⟨w, rfl⟩
    change projMinus hardyPolarization (truncSubspace U) w ∈ _
    have hEq : projMinus hardyPolarization (truncSubspace U) w =
        eBasis.repr w.1 (-2) • b1 + eBasis.repr w.1 (-1) • b2 := by
      apply Subtype.ext
      apply eBasis.repr.injective
      ext n
      change eBasis.repr (hardyMinus.orthogonalProjectionOnto w.1 : HCircle) n =
        eBasis.repr (eBasis.repr w.1 (-2) • eBasis (-2) + eBasis.repr w.1 (-1) • eBasis (-1)) n
      rw [map_add, map_smul, map_smul, lp.coeFn_add, lp.coeFn_smul, lp.coeFn_smul,
        Pi.add_apply, Pi.smul_apply, Pi.smul_apply, smul_eq_mul, smul_eq_mul,
        HilbertBasis.repr_self, HilbertBasis.repr_self, lp.single_apply, lp.single_apply]
      by_cases h0 : 0 ≤ n
      · rw [(mem_hardyMinus_iff _).mp (hardyMinus.orthogonalProjectionOnto w.1).2 n h0]
        have h1 : n ≠ -2 := by omega
        have h2 : n ≠ -1 := by omega
        simp [h1, h2]
      · push Not at h0
        rw [repr_projMinus_of_neg w.1 h0]
        by_cases hm2 : n = -2
        · subst hm2; simp
        · by_cases hm1 : n = -1
          · subst hm1; simp
          · have hlt : n < -2 := by omega
            rw [w.2.1 n hlt]
            simp [hm2, hm1]
    rw [hEq]
    exact Submodule.add_mem _
      (Submodule.smul_mem _ _ (Submodule.subset_span (Set.mem_insert b1 _)))
      (Submodule.smul_mem _ _ (Submodule.subset_span (Set.mem_insert_of_mem b1 rfl)))
  have : FiniteDimensional ℂ (Submodule.span ℂ ({b1, b2} : Set hardyPolarization.HMinus)) :=
    FiniteDimensional.span_of_finite ℂ ((Set.finite_singleton b2).insert b1)
  have : FiniteDimensional ℂ (LinearMap.range (projMinus hardyPolarization (truncSubspace U)).toLinearMap) :=
    Module.Finite.of_injective (Submodule.inclusion hle) (Submodule.inclusion_injective hle)
  exact isCompactOperator_of_finiteDimensional_range _

/-- Positive-frequency projection `α_U : U →ₗ[ℂ] ℂ²` sending `u ↦ (u 2, u 3)`. -/
def posPair : C4 →ₗ[ℂ] (Fin 2 → ℂ) where
  toFun u i := u ⟨i.1 + 2, by omega⟩
  map_add' _ _ := rfl
  map_smul' _ _ := rfl

def alphaMap (U : Submodule ℂ C4) : U →ₗ[ℂ] (Fin 2 → ℂ) :=
  posPair.comp U.subtype

/-- `ker(p₊|_{Ψ(U)}) ≃ₗ[ℂ] ker(α_U)`. -/
noncomputable def kerProjPlusEquiv (U : Submodule ℂ C4) :
    LinearMap.ker (projPlus hardyPolarization (truncSubspace U)).toLinearMap ≃ₗ[ℂ]
      LinearMap.ker (alphaMap U) where
  toFun := fun ⟨w, hw⟩ =>
    ⟨⟨windowEval w.1, w.2.2⟩, by
      ext i
      change windowEval w.1 ⟨i.1 + 2, by omega⟩ = 0
      rw [windowEval_apply]
      have hidx : ((⟨i.1 + 2, by omega⟩ : Fin 4).1 : ℤ) - 2 = (i.1 : ℤ) := by
        simp only [Nat.cast_add, Nat.cast_ofNat]; ring
      rw [hidx, ← repr_projPlus_of_nonneg w.1 (by omega)]
      have hw0 : (hardyPlus.orthogonalProjectionOnto w.1 : HCircle) = 0 := congrArg Subtype.val hw
      rw [hw0, map_zero]; rfl⟩
  invFun := fun ⟨u, hu⟩ =>
    ⟨⟨windowEmbed u.1, fun n hn => repr_windowEmbed_of_lt u.1 hn,
        by rw [windowEval_windowEmbed]; exact u.2⟩, by
      apply Subtype.ext
      apply eBasis.repr.injective
      ext n
      change eBasis.repr (hardyPlus.orthogonalProjectionOnto (windowEmbed u.1) : HCircle) n =
        eBasis.repr (0 : HCircle) n
      rw [map_zero]; change eBasis.repr (hardyPlus.orthogonalProjectionOnto (windowEmbed u.1) : HCircle) n = 0
      by_cases hn : n < 0
      · exact (mem_hardyPlus_iff _).mp (hardyPlus.orthogonalProjectionOnto _).2 n hn
      · push Not at hn
        rw [repr_projPlus_of_nonneg _ hn]
        by_cases hge : 2 ≤ n
        · exact repr_windowEmbed_of_ge u.1 hge
        · push Not at hge
          let i : Fin 2 := ⟨n.toNat, by omega⟩
          have hi : ((⟨i.1 + 2, by omega⟩ : Fin 4) : ℤ) - 2 = n := by dsimp [i]; omega
          rw [← hi, repr_windowEmbed_window]
          exact congrFun hu i⟩
  left_inv := fun ⟨w, hw⟩ => by
    apply Subtype.ext; apply Subtype.ext
    apply eBasis.repr.injective
    ext n
    by_cases hlt : n < -2
    · rw [repr_windowEmbed_of_lt _ hlt, w.2.1 n hlt]
    · push Not at hlt
      by_cases h0 : 0 ≤ n
      · have hw0 : (hardyPlus.orthogonalProjectionOnto w.1 : HCircle) = 0 := congrArg Subtype.val hw
        have hwn : eBasis.repr w.1 n = 0 := by
          rw [← repr_projPlus_of_nonneg w.1 h0, hw0, map_zero]; rfl
        by_cases hge : 2 ≤ n
        · rw [repr_windowEmbed_of_ge _ hge, hwn]
        · push Not at hge
          let j : Fin 4 := ⟨(n + 2).toNat, by omega⟩
          have hj : (j : ℤ) - 2 = n := by dsimp [j]; omega
          change eBasis.repr (windowEmbed (windowEval w.1)) n = eBasis.repr w.1 n
          rw [← hj, repr_windowEmbed_window, windowEval_apply]
      · push Not at h0
        let j : Fin 4 := ⟨(n + 2).toNat, by omega⟩
        have hj : (j : ℤ) - 2 = n := by dsimp [j]; omega
        change eBasis.repr (windowEmbed (windowEval w.1)) n = eBasis.repr w.1 n
        rw [← hj, repr_windowEmbed_window, windowEval_apply]
  right_inv := fun ⟨u, _⟩ => by
    apply Subtype.ext; apply Subtype.ext
    exact windowEval_windowEmbed u.1
  map_add' := fun _ _ => by ext i; simp [map_add]
  map_smul' := fun _ _ => by ext i; simp [map_smul]

/-- `ℂ² ⧸ range(α_U) ≃ₗ[ℂ] H₊ ⧸ range(p₊|_{Ψ(U)})`. -/
noncomputable def cokerProjPlusEquiv (U : Submodule ℂ C4) :
    ((Fin 2 → ℂ) ⧸ LinearMap.range (alphaMap U)) ≃ₗ[ℂ]
      (hardyPolarization.HPlus ⧸ LinearMap.range (projPlus hardyPolarization (truncSubspace U)).toLinearMap) := by
  let ι01 : (Fin 2 → ℂ) →ₗ[ℂ] hardyPolarization.HPlus :=
    { toFun := fun c => ⟨c 0 • eBasis 0 + c 1 • eBasis 1,
        hardyPlus.add_mem (hardyPlus.smul_mem _ (mem_hardyPlus_basis 0))
          (hardyPlus.smul_mem _ (mem_hardyPlus_basis 1))⟩
      map_add' := fun a b => by apply Subtype.ext; simp [add_smul]; abel
      map_smul' := fun r a => by apply Subtype.ext; simp [smul_add, mul_smul] }
  have hrepr_ι01 : ∀ (c : Fin 2 → ℂ) (n : ℤ),
      eBasis.repr (ι01 c : HCircle) n =
        (if n = 0 then c 0 else 0) + (if n = 1 then c 1 else 0) := by
    intro c n
    change eBasis.repr (c 0 • eBasis 0 + c 1 • eBasis 1) n = _
    rw [map_add, map_smul, map_smul, lp.coeFn_add, lp.coeFn_smul, lp.coeFn_smul,
      Pi.add_apply, Pi.smul_apply, Pi.smul_apply, smul_eq_mul, smul_eq_mul,
      HilbertBasis.repr_self, HilbertBasis.repr_self, lp.single_apply, lp.single_apply]
    simp only [Pi.single_apply]
    split_ifs <;> simp
  let φ : (Fin 2 → ℂ) →ₗ[ℂ]
      (hardyPolarization.HPlus ⧸ LinearMap.range (projPlus hardyPolarization (truncSubspace U)).toLinearMap) :=
    (LinearMap.range (projPlus hardyPolarization (truncSubspace U)).toLinearMap).mkQ.comp ι01
  have hsurj : Function.Surjective φ := by
    intro q
    obtain ⟨h, rfl⟩ := Submodule.Quotient.mk_surjective _ q
    let c : Fin 2 → ℂ := fun i => eBasis.repr h.1 (i.1 : ℤ)
    refine ⟨c, ?_⟩
    simp only [φ, LinearMap.comp_apply, Submodule.mkQ_apply]
    rw [Submodule.Quotient.eq]
    have hdiff_ge2 : (ι01 c : HCircle) - h.1 ∈ hardyGe2 := by
      intro n hn
      rw [map_sub, lp.coeFn_sub, Pi.sub_apply]
      by_cases hneg : n < 0
      · rw [(mem_hardyPlus_iff _).mp (ι01 c).2 n hneg, (mem_hardyPlus_iff _).mp h.2 n hneg, sub_self]
      · push Not at hneg
        have h01 : n = 0 ∨ n = 1 := by omega
        rcases h01 with rfl | rfl
        · rw [hrepr_ι01]; simp [c]
        · rw [hrepr_ι01]; simp [c]
    have hdiff_mem : (ι01 c : HCircle) - h.1 ∈ truncSubspace U := by
      rw [truncSubspace_eq_sup]
      exact Submodule.mem_sup_left hdiff_ge2
    refine ⟨⟨(ι01 c : HCircle) - h.1, hdiff_mem⟩, ?_⟩
    apply Subtype.ext
    change (hardyPlus.orthogonalProjectionOnto ((ι01 c - h : hardyPolarization.HPlus) : HCircle) : HCircle) = _
    exact congrArg Subtype.val
      (Submodule.orthogonalProjectionOnto_mem_subspace_eq_self (ι01 c - h))
  have hker : LinearMap.ker φ = LinearMap.range (alphaMap U) := by
    ext c
    simp only [φ, LinearMap.mem_ker, LinearMap.comp_apply, Submodule.mkQ_apply,
      Submodule.Quotient.mk_eq_zero, LinearMap.mem_range]
    constructor
    · rintro ⟨w, hw⟩
      refine ⟨⟨windowEval w.1, w.2.2⟩, ?_⟩
      ext i
      change windowEval w.1 ⟨i.1 + 2, by omega⟩ = c i
      rw [windowEval_apply]
      have hi : ((⟨i.1 + 2, by omega⟩ : Fin 4).1 : ℤ) - 2 = (i.1 : ℤ) := by
        simp only [Nat.cast_add, Nat.cast_ofNat]; ring
      rw [hi, ← repr_projPlus_of_nonneg w.1 (by omega)]
      have hw' : (hardyPlus.orthogonalProjectionOnto w.1 : HCircle) = (ι01 c : HCircle) :=
        congrArg Subtype.val hw
      rw [hw', hrepr_ι01]
      fin_cases i <;> simp
    · rintro ⟨u, rfl⟩
      have hw_mem : windowEmbed u.1 ∈ truncSubspace U :=
        ⟨fun n hn => repr_windowEmbed_of_lt u.1 hn, by rw [windowEval_windowEmbed]; exact u.2⟩
      refine ⟨⟨windowEmbed u.1, hw_mem⟩, ?_⟩
      apply Subtype.ext
      apply eBasis.repr.injective
      ext n
      change eBasis.repr (hardyPlus.orthogonalProjectionOnto (windowEmbed u.1) : HCircle) n =
        eBasis.repr (ι01 (alphaMap U u) : HCircle) n
      by_cases hneg : n < 0
      · rw [(mem_hardyPlus_iff _).mp (hardyPlus.orthogonalProjectionOnto _).2 n hneg,
          (mem_hardyPlus_iff _).mp (ι01 _).2 n hneg]
      · push Not at hneg
        rw [repr_projPlus_of_nonneg _ hneg, hrepr_ι01]
        by_cases hge : 2 ≤ n
        · rw [repr_windowEmbed_of_ge u.1 hge]
          have h0 : n ≠ 0 := by omega
          have h1 : n ≠ 1 := by omega
          simp [h0, h1]
        · push Not at hge
          have h01 : n = 0 ∨ n = 1 := by omega
          rcases h01 with rfl | rfl
          · have h2 : ((2 : Fin 4) : ℤ) - 2 = 0 := by norm_num
            rw [← h2, repr_windowEmbed_window]
            simp [alphaMap, posPair]
          · have h3 : ((3 : Fin 4) : ℤ) - 2 = 1 := by norm_num
            rw [← h3, repr_windowEmbed_window]
            simp [alphaMap, posPair]
  exact (Submodule.quotEquivOfEq _ _ hker.symm).trans (φ.quotKerEquivOfSurjective hsurj)

/-- **Theorem 1 (Finite-Rank Truncation Embedding):** Every 2-plane `U ∈ Gr_ℂ(2, 4)`
embeds into `Gr_res(L²(S¹))` with virtual dimension `0`. -/
noncomputable def truncEmbed (U : Gr24) : SatoGr hardyPolarization :=
  ⟨truncSubspace U.1, by
    have hClosed := truncSubspace_isClosed U.1
    have : CompleteSpace (truncSubspace U.1) := hClosed.completeSpace_coe
    have hFinKer : FiniteDimensional ℂ (LinearMap.ker (projPlus hardyPolarization (truncSubspace U.1)).toLinearMap) :=
      Module.Finite.equiv (kerProjPlusEquiv U.1).symm
    have hFinCoker : FiniteDimensional ℂ
        (hardyPolarization.HPlus ⧸ LinearMap.range (projPlus hardyPolarization (truncSubspace U.1)).toLinearMap) :=
      Module.Finite.equiv (cokerProjPlusEquiv U.1)
    refine ⟨hClosed, ⟨hFinKer, hFinCoker, closedRange_of_finiteDimensional_coker _⟩,
      projMinus_truncSubspace_isCompact U.1⟩⟩

/-- **Theorem 2 (Injectivity):** `truncEmbed : Gr_ℂ(2, 4) ↪ Gr_res(L²(S¹))` is injective. -/
theorem truncEmbed_injective : Function.Injective truncEmbed := by
  intro U₁ U₂ hEq
  have hSub : truncSubspace U₁.1 = truncSubspace U₂.1 := congrArg Subtype.val hEq
  apply Subtype.ext
  ext u
  have hiff : windowEmbed u ∈ truncSubspace U₁.1 ↔ windowEmbed u ∈ truncSubspace U₂.1 := by
    rw [hSub]
  constructor
  · intro hu
    have h2 := (hiff.mp ⟨fun n hn => repr_windowEmbed_of_lt u hn, by rwa [windowEval_windowEmbed]⟩).2
    rwa [windowEval_windowEmbed] at h2
  · intro hu
    have h1 := (hiff.mpr ⟨fun n hn => repr_windowEmbed_of_lt u hn, by rwa [windowEval_windowEmbed]⟩).2
    rwa [windowEval_windowEmbed] at h1

/-- **Theorem 3 (Virtual Dimension Zero):** Every truncated 2-plane lies in the
neutral charge sector `vdim(Ψ(U)) = 0`. -/
theorem virtualDim_truncEmbed (U : Gr24) :
    virtualDim (truncEmbed U) = 0 := by
  unfold virtualDim fredholmIndex truncEmbed
  change (Module.finrank ℂ (LinearMap.ker (projPlus hardyPolarization (truncSubspace U.1)).toLinearMap) : ℤ) -
    (Module.finrank ℂ (hardyPolarization.HPlus ⧸
      LinearMap.range (projPlus hardyPolarization (truncSubspace U.1)).toLinearMap) : ℤ) = 0
  rw [(kerProjPlusEquiv U.1).finrank_eq, ← (cokerProjPlusEquiv U.1).finrank_eq]
  have hRN := LinearMap.finrank_range_add_finrank_ker (alphaMap U.1)
  have hQ := Submodule.finrank_quotient_add_finrank (LinearMap.range (alphaMap U.1))
  have hC2 : Module.finrank ℂ (Fin 2 → ℂ) = 2 := by simp
  have hU : Module.finrank ℂ U.1 = 2 := U.2
  omega

/-! ### Plücker Coordinates & Klein Quadric `𝒬₄ ⊂ ℙ⁵` -/

/-- Plücker coordinate `p_{ij}(v, w) = v_i w_j - v_j w_i` (2×2 minor of the frame `[v; w]`). -/
def pluckerCoord (v w : C4) (i j : Fin 4) : ℂ :=
  v i * w j - v j * w i

theorem pluckerCoord_antisymm (v w : C4) (i j : Fin 4) :
    pluckerCoord v w j i = -pluckerCoord v w i j := by
  unfold pluckerCoord; ring

/-- `GL₂(ℂ)`-equivariance: changing basis scales all Plücker coordinates by `det A`. -/
theorem pluckerCoord_gl2_change (v w : C4) (a b c d : ℂ) (i j : Fin 4) :
    pluckerCoord (a • v + b • w) (c • v + d • w) i j =
      (a * d - b * c) * pluckerCoord v w i j := by
  simp only [pluckerCoord, Pi.add_apply, Pi.smul_apply, smul_eq_mul]
  ring

/-- **Theorem 4 (Klein Quadric `𝒬₄` Plücker Relation):**
Every 2-plane frame satisfies `p₀₁ p₂₃ - p₀₂ p₁₃ + p₀₃ p₁₂ = 0`. -/
theorem kleinQuadric_relation (v w : C4) :
    pluckerCoord v w 0 1 * pluckerCoord v w 2 3 -
    pluckerCoord v w 0 2 * pluckerCoord v w 1 3 +
    pluckerCoord v w 0 3 * pluckerCoord v w 1 2 = 0 := by
  unfold pluckerCoord
  ring

/-- **Theorem 5 (Big-Cell Criterion):** For a 2-plane `U = span {v, w}`,
`Ψ(U)` lies in the Sato big cell (`ker p₊ = ⊥`, so `p₊` is an isomorphism)
if and only if the top Plücker minor `p₂₃(v, w) ≠ 0`. -/
theorem ker_projPlus_eq_bot_iff_plucker23_ne_zero (U : Gr24) (v w : C4)
    (hspan : U.1 = Submodule.span ℂ ({v, w} : Set C4))
    (hli : LinearIndependent ℂ ![v, w]) :
    LinearMap.ker (projPlus hardyPolarization (truncSubspace U.1)).toLinearMap = ⊥ ↔
      pluckerCoord v w 2 3 ≠ 0 := by
  have hker_iff : LinearMap.ker (projPlus hardyPolarization (truncSubspace U.1)).toLinearMap = ⊥ ↔
      LinearMap.ker (alphaMap U.1) = ⊥ := by
    constructor
    · intro h
      have : Subsingleton (LinearMap.ker (projPlus hardyPolarization (truncSubspace U.1)).toLinearMap) := by
        rw [h]; infer_instance
      have : Subsingleton (LinearMap.ker (alphaMap U.1)) :=
        (kerProjPlusEquiv U.1).symm.injective.subsingleton
      exact (Submodule.eq_bot_iff _).mpr fun x hx =>
        congrArg Subtype.val (Subsingleton.elim (⟨x, hx⟩ : LinearMap.ker (alphaMap U.1)) 0)
    · intro h
      have : Subsingleton (LinearMap.ker (alphaMap U.1)) := by rw [h]; infer_instance
      have : Subsingleton (LinearMap.ker (projPlus hardyPolarization (truncSubspace U.1)).toLinearMap) :=
        (kerProjPlusEquiv U.1).injective.subsingleton
      exact (Submodule.eq_bot_iff _).mpr fun x hx =>
        congrArg Subtype.val (Subsingleton.elim (⟨x, hx⟩ : LinearMap.ker _) 0)
  rw [hker_iff]
  have hmem_comb : ∀ u : C4, u ∈ U.1 ↔ ∃ a b : ℂ, a • v + b • w = u := by
    intro u
    rw [hspan, Submodule.mem_span_pair]
  have hlin_zero : ∀ a b : ℂ, a • v + b • w = 0 → a = 0 ∧ b = 0 := by
    intro a b hab
    have hcomb := Fintype.linearIndependent_iff.mp hli ![a, b] (by
      simpa [Fin.sum_univ_two] using hab)
    exact ⟨hcomb 0, hcomb 1⟩
  constructor
  · intro hbot hp23
    unfold pluckerCoord at hp23
    have hcontra : ∀ a b : ℂ, (a ≠ 0 ∨ b ≠ 0) →
        a * v 2 + b * w 2 = 0 → a * v 3 + b * w 3 = 0 → False := by
      intro a b hab h2 h3
      let u : U.1 := ⟨a • v + b • w, (hmem_comb _).mpr ⟨a, b, rfl⟩⟩
      have hu_ker : u ∈ LinearMap.ker (alphaMap U.1) := by
        ext i; fin_cases i
        · simpa [u, alphaMap, posPair] using h2
        · simpa [u, alphaMap, posPair] using h3
      rw [hbot, Submodule.mem_bot] at hu_ker
      have h0 : a • v + b • w = 0 := congrArg Subtype.val hu_ker
      obtain ⟨ha, hb⟩ := hlin_zero a b h0
      exact hab.elim (fun h => h ha) (fun h => h hb)
    by_cases hw2 : w 2 = 0
    · by_cases hw3 : w 3 = 0
      · exact hcontra 0 1 (Or.inr one_ne_zero) (by simp [hw2]) (by simp [hw3])
      · have hv2 : v 2 = 0 := by
          have : v 2 * w 3 = 0 := by linear_combination hp23 + v 3 * hw2
          exact (mul_eq_zero.mp this).resolve_right hw3
        exact hcontra (-w 3) (v 3) (Or.inl (neg_ne_zero.mpr hw3))
          (by simp [hv2, hw2]) (by ring)
    · exact hcontra (-w 2) (v 2) (Or.inl (neg_ne_zero.mpr hw2))
        (by ring) (by linear_combination hp23)
  · intro hp23
    rw [Submodule.eq_bot_iff]
    rintro ⟨u, hu⟩ hker
    obtain ⟨a, b, rfl⟩ := (hmem_comb u).mp hu
    have h2 : a * v 2 + b * w 2 = 0 := by simpa [alphaMap, posPair] using congrFun hker 0
    have h3 : a * v 3 + b * w 3 = 0 := by simpa [alphaMap, posPair] using congrFun hker 1
    have hda : pluckerCoord v w 2 3 * a = 0 := by
      unfold pluckerCoord; linear_combination w 3 * h2 - w 2 * h3
    have hdb : pluckerCoord v w 2 3 * b = 0 := by
      unfold pluckerCoord; linear_combination v 2 * h3 - v 3 * h2
    have ha : a = 0 := (mul_eq_zero.mp hda).resolve_left hp23
    have hb : b = 0 := (mul_eq_zero.mp hdb).resolve_left hp23
    apply Subtype.ext
    simp [ha, hb]

/-- **Theorem 6 (Converse on the Big Cell — Sign-Corrected):** Any point
`(p₀₁, p₀₂, p₀₃, p₁₂, p₁₃, p₂₃) ∈ 𝒬₄` with `p₂₃ ≠ 0` explicitly reconstructs a 2-plane
`U ∈ Gr_ℂ(2, 4)` with basis `v = (p₀₃/p₂₃, p₁₃/p₂₃, 1, 0)` and
`w = (-p₀₂/p₂₃, -p₁₂/p₂₃, 0, 1)` realizing the exact projective Plücker coordinates
(scaled by `p₂₃⁻¹`). -/
theorem kleinQuadric_reconstruct_bigCell (p01 p02 p03 p12 p13 p23 : ℂ)
    (hQ : p01 * p23 - p02 * p13 + p03 * p12 = 0) (hp23 : p23 ≠ 0) :
    let v : C4 := ![p03 / p23, p13 / p23, 1, 0]
    let w : C4 := ![-p02 / p23, -p12 / p23, 0, 1]
    LinearIndependent ℂ ![v, w] ∧
    pluckerCoord v w 0 1 = p01 / p23 ∧
    pluckerCoord v w 0 2 = p02 / p23 ∧
    pluckerCoord v w 0 3 = p03 / p23 ∧
    pluckerCoord v w 1 2 = p12 / p23 ∧
    pluckerCoord v w 1 3 = p13 / p23 ∧
    pluckerCoord v w 2 3 = p23 / p23 := by
  intro v w
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · rw [Fintype.linearIndependent_iff]
    intro c hc i
    have h2 := congrFun hc 2
    have h3 := congrFun hc 3
    simp only [Fin.sum_univ_two, Pi.add_apply, Pi.smul_apply, smul_eq_mul, Pi.zero_apply,
      Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons, v, w,
      Matrix.cons_val_two, Matrix.tail_cons, Matrix.cons_val_three,
      mul_one, mul_zero, add_zero, zero_add] at h2 h3
    fin_cases i
    · exact h2
    · exact h3
  · simp only [pluckerCoord, v, w, Matrix.cons_val_zero, Matrix.cons_val_one]
    field_simp [hp23]
    linear_combination -hQ
  · simp [pluckerCoord, v, w]; ring
  · simp [pluckerCoord, v, w]
  · simp [pluckerCoord, v, w]; ring
  · simp [pluckerCoord, v, w]
  · simp [pluckerCoord, v, w, div_self hp23]

end Signals.SatoGrassmannian.Gr24Truncation
