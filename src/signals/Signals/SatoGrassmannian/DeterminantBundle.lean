import Mathlib.Analysis.InnerProductSpace.Adjoint
import Mathlib.Analysis.InnerProductSpace.GramSchmidtOrtho
import Mathlib.Analysis.InnerProductSpace.Projection.Basic
import Mathlib.GroupTheory.QuotientGroup.Basic
import Mathlib.LinearAlgebra.Determinant
import Mathlib.LinearAlgebra.Dimension.Finrank
import Mathlib.LinearAlgebra.Matrix.NonsingularInverse
import Signals.SatoGrassmannian.Base
import Signals.SatoGrassmannian.RieszSchauder
import Signals.SatoGrassmannian.KPFlow
import Signals.SatoGrassmannian.SchwingerCocycle

/-!
# Trace-Class Ideal, Pressley–Segal Central Extension `GL̂_(2)⁰(H)` & Determinant Line Bundle `Det*`

Ported from `data/chats/Gemini_Formalizing-Sato-Grassmannian-in-Lean_20261120-2337.md`
(block 014). Formalizes:
1. `ℐ₂ ⊆ 𝒦` (`IsHS.isCompactOperator`) and finite-rank invertible perturbation of index-0
   Fredholm operators (`exists_equiv_sub_finiteRank_of_index_zero`).
2. The trace-class ideal `ℐ₁(H₊)` (`TraceClassIdeal`), multiplicative monoid `1 + ℐ₁(H₊)`
   (`TraceClassMonoid`), structure group `𝒯(H₊) = GL(H₊) ∩ (1 + ℐ₁(H₊))` (`TraceClassGroup`),
   and the minimal axiomatic Fredholm determinant interface `FredholmDetTheory`.
3. The Pressley–Segal central extension `1 → ℂˣ → GL̂_(2)⁰(H) → GL_(2)⁰(H) → 1` with
   injectivity, centrality, exactness, and surjectivity proved unconditionally.
4. The Hilbert–Schmidt Sato Grassmannian `Gr_(2)⁰(H)`, admissible frames `𝒫(W)`,
   determinant line bundle `Det*(W)`, canonical holomorphic section `σ(W) ≠ 0 ↔ ker p₊ = ⊥`,
   equivariant `GL̂_(2)⁰(H)` action with weight `+1` central scalar action, and the
   big-cell Segal–Wilson `τ`-function identity `segalWilson_tau_bigCell`.
-/

open scoped InnerProductSpace BigOperators

namespace Signals.SatoGrassmannian.DeterminantBundle

open Signals.SatoGrassmannian Signals.SatoGrassmannian.KPFlow
open Signals.SatoGrassmannian.SchwingerCocycle

/-! ============================================================================
## Section 1: Hilbert–Schmidt Compactness, Finite-Rank Perturbations & Trace-Class Ideal
============================================================================ -/

section TraceClassFoundation

universe u
variable {ι₁ ι₂ : Type*} {E F : Type u}
  [NormedAddCommGroup E] [InnerProductSpace ℂ E] [CompleteSpace E]
  [NormedAddCommGroup F] [InnerProductSpace ℂ F] [CompleteSpace F]

/-- Every bounded operator with finite-dimensional range is Hilbert–Schmidt. -/
theorem isHS_of_finiteDimensional_range (eE : HilbertBasis ι₁ ℂ E) (T : E →L[ℂ] F)
    [FiniteDimensional ℂ (LinearMap.range T.toLinearMap)] :
    IsHS eE T := by
  let R := LinearMap.range T.toLinearMap
  let b := stdOrthonormalBasis ℂ R
  have hParseval : ∀ y : R, ‖(y : F)‖ ^ 2 = ∑ k, ‖⟪(b k : F), (y : F)⟫_ℂ‖ ^ 2 := by
    intro y
    have hrepr : ∑ k, ⟪b k, y⟫_ℂ • b k = y := by
      simpa [OrthonormalBasis.repr_apply_apply] using b.sum_repr y
    have hinner : ⟪y, y⟫_ℂ = ∑ k, ((‖⟪b k, y⟫_ℂ‖ ^ 2 : ℝ) : ℂ) := by
      calc ⟪y, y⟫_ℂ = ⟪∑ k, ⟪b k, y⟫_ℂ • b k, y⟫_ℂ := by rw [hrepr]
        _ = ∑ k, ⟪⟪b k, y⟫_ℂ • b k, y⟫_ℂ := sum_inner _ _ _
        _ = ∑ k, ((‖⟪b k, y⟫_ℂ‖ ^ 2 : ℝ) : ℂ) := by
            refine Finset.sum_congr rfl fun k _ => ?_
            rw [inner_smul_left, mul_comm, Complex.mul_conj, Complex.normSq_eq_norm_sq]
    have hre := congrArg Complex.re hinner
    rw [inner_self_eq_norm_sq_to_K, Complex.re_sum] at hre
    have hL : (((‖y‖ : ℝ) : ℂ) ^ 2).re = ‖y‖ ^ 2 := by norm_cast
    have hR : (∑ k, (((‖⟪b k, y⟫_ℂ‖ ^ 2 : ℝ) : ℂ)).re) = ∑ k, ‖⟪b k, y⟫_ℂ‖ ^ 2 := by
      refine Finset.sum_congr rfl fun k _ => ?_; norm_cast
    exact hL.symm.trans (hre.trans hR)
  have hSumm_k : ∀ k, Summable (fun i : ι₁ => ‖⟪(b k : F), T (eE i)⟫_ℂ‖ ^ 2) := by
    intro k
    have h := (hasSum_norm_inner_sq eE (ContinuousLinearMap.adjoint T (b k : F))).summable
    refine h.congr fun i => ?_
    rw [ContinuousLinearMap.adjoint_inner_right, ← inner_conj_symm (T (eE i)) (b k : F),
      RCLike.norm_conj]
  have hSum : Summable (fun i : ι₁ => ∑ k, ‖⟪(b k : F), T (eE i)⟫_ℂ‖ ^ 2) := by
    classical
    refine Finset.induction_on (Finset.univ : Finset (Fin (Module.finrank ℂ R)))
      (by simp) ?_
    intro k s hk ih
    simpa [Finset.sum_insert hk] using (hSumm_k k).add ih
  refine hSum.congr fun i => ?_
  exact (hParseval ⟨T (eE i), ⟨eE i, rfl⟩⟩).symm

omit [CompleteSpace E] in
/-- **Theorem 1.1 (`ℐ₂ ⊆ 𝒦`):** Every Hilbert–Schmidt operator is compact, proved by
operator-norm approximation with finite-rank partial sums via AM–GM. -/
theorem IsHS.isCompactOperator {eE : HilbertBasis ι₁ ℂ E} {T : E →L[ℂ] F}
    (hT : IsHS eE T) :
    IsCompactOperator (T : E → F) := by
  classical
  have hcl : IsClosed {K : E →L[ℂ] F | IsCompactOperator (K : E → F)} :=
    isClosed_isCompactOperator
  change T ∈ {K : E →L[ℂ] F | IsCompactOperator (K : E → F)}
  rw [← hcl.closure_eq]
  rw [Metric.mem_closure_iff]
  intro ε hε
  let δ : ℝ := ε / 2
  have hδ : 0 < δ := half_pos hε
  let S : ℝ := ∑' i : ι₁, ‖T (eE i)‖ ^ 2
  have hTend := Metric.tendsto_atTop.mp hT.hasSum (δ ^ 2) (sq_pos_of_pos hδ)
  obtain ⟨s, hs⟩ := hTend
  have hDiff_lt : S - ∑ i ∈ s, ‖T (eE i)‖ ^ 2 < δ ^ 2 := by
    have h := hs s le_rfl
    rw [Real.dist_eq, abs_lt] at h
    linarith
  let K : E →L[ℂ] F := ∑ i ∈ s, (innerSL ℂ (eE i)).smulRight (T (eE i))
  have hK_range : LinearMap.range K.toLinearMap ≤ Submodule.span ℂ (s.image (fun i => T (eE i)) : Set F) := by
    rintro _ ⟨x, rfl⟩
    simp only [K, ContinuousLinearMap.coe_coe, sum_apply,
      ContinuousLinearMap.smulRight_apply]
    refine Submodule.sum_mem _ fun i hi => Submodule.smul_mem _ _ ?_
    exact Submodule.subset_span (Finset.mem_coe.mpr (Finset.mem_image_of_mem _ hi))
  have : FiniteDimensional ℂ (Submodule.span ℂ (s.image (fun i => T (eE i)) : Set F)) :=
    FiniteDimensional.span_of_finite ℂ (Finset.finite_toSet _)
  have : FiniteDimensional ℂ (LinearMap.range K.toLinearMap) :=
    FiniteDimensional.of_injective (Submodule.inclusion hK_range) (Submodule.inclusion_injective hK_range)
  have hK_comp : IsCompactOperator (K : E → F) := isCompactOperator_of_finiteDimensional_range K
  let tailT : ι₁ → ℝ := fun i => if i ∈ s then 0 else ‖T (eE i)‖ ^ 2
  have htailT_summ : Summable tailT :=
    Summable.of_nonneg_of_le (fun i => by dsimp [tailT]; split_ifs <;> positivity)
      (fun i => by dsimp [tailT]; split_ifs <;> [exact sq_nonneg _; exact le_rfl]) hT
  have hR_le : ∑' i : ι₁, tailT i ≤ δ ^ 2 := by
    let headT : ι₁ → ℝ := fun i => if i ∈ s then ‖T (eE i)‖ ^ 2 else 0
    have hheadT_summ : Summable headT :=
      summable_of_ne_finset_zero (s := s) fun i hi => by simp [headT, hi]
    have hsplit : (fun i => ‖T (eE i)‖ ^ 2) = fun i => headT i + tailT i := by
      ext i; dsimp [headT, tailT]; split_ifs <;> ring
    have hS_eq : S = (∑ i ∈ s, ‖T (eE i)‖ ^ 2) + ∑' i : ι₁, tailT i := by
      dsimp [S]
      rw [hsplit, hheadT_summ.tsum_add htailT_summ,
        tsum_eq_sum (f := headT) (s := s) (fun i hi => by simp [headT, hi])]
      congr 1
      exact Finset.sum_congr rfl fun i hi => by simp [headT, tailT, hi]
    linarith
  have hTK_basis : ∀ i : ι₁, (T - K) (eE i) = if i ∈ s then 0 else T (eE i) := by
    intro i
    simp only [sub_apply, K, sum_apply,
      ContinuousLinearMap.smulRight_apply, innerSL_apply_apply]
    by_cases hi : i ∈ s
    · simp only [hi, ↓reduceIte]
      rw [Finset.sum_eq_single i]
      · rw [inner_self_eq_norm_sq_to_K, eE.orthonormal.1 i]; norm_num
      · intro j _ hji
        rw [orthonormal_iff_ite.mp eE.orthonormal j i, ite_eq_right_iff.mpr (fun h => absurd h hji), zero_smul]
      · intro h; exact absurd hi h
    · simp only [hi, ↓reduceIte]
      have h0 : ∑ j ∈ s, ⟪eE j, eE i⟫_ℂ • T (eE j) = 0 := by
        refine Finset.sum_eq_zero fun j hj => ?_
        have hji : j ≠ i := fun h => hi (h ▸ hj)
        rw [orthonormal_iff_ite.mp eE.orthonormal j i, ite_eq_right_iff.mpr (fun h => absurd h hji), zero_smul]
      rw [h0, sub_zero]
  have hNorm_le : ‖T - K‖ ≤ δ := by
    refine ContinuousLinearMap.opNorm_le_bound _ hδ.le fun x => ?_
    by_cases hx : x = 0
    · simp [hx]
    have hx_pos : 0 < ‖x‖ := norm_pos_iff.mpr hx
    let α : ℝ := δ / ‖x‖
    have hα : 0 < α := div_pos hδ hx_pos
    have hSumX : HasSum (fun i : ι₁ => ⟪eE i, x⟫_ℂ • (T - K) (eE i)) ((T - K) x) := by
      have h := (eE.hasSum_repr x).map (T - K).toAddMonoidHom (T - K).continuous
      refine h.congr_fun fun i => ?_
      symm
      change (T - K) (eE.repr x i • eE i) = ⟪eE i, x⟫_ℂ • (T - K) (eE i)
      rw [map_smul, HilbertBasis.repr_apply_apply]
    have hBound_term : ∀ i : ι₁,
        ‖⟪eE i, x⟫_ℂ • (T - K) (eE i)‖ ≤
          (α / 2) * ‖⟪eE i, x⟫_ℂ‖ ^ 2 + (1 / (2 * α)) * tailT i := by
      intro i
      rw [hTK_basis i]
      by_cases hi : i ∈ s
      · simp only [hi, ↓reduceIte, smul_zero, norm_zero, tailT]
        positivity
      · simp only [hi, ↓reduceIte, norm_smul, tailT]
        have hsq : 0 ≤ (α * ‖⟪eE i, x⟫_ℂ‖ - ‖T (eE i)‖) ^ 2 := sq_nonneg _
        have h2α : 0 < 2 * α := by linarith
        have hmul : 2 * α * (‖⟪eE i, x⟫_ℂ‖ * ‖T (eE i)‖) ≤
            α ^ 2 * ‖⟪eE i, x⟫_ℂ‖ ^ 2 + ‖T (eE i)‖ ^ 2 := by nlinarith
        have hdiv := (le_div_iff₀' h2α).mpr hmul
        convert hdiv using 1
        field_simp [hα.ne']
    have hMajor_summ : Summable (fun i : ι₁ => (α / 2) * ‖⟪eE i, x⟫_ℂ‖ ^ 2 + (1 / (2 * α)) * tailT i) :=
      ((hasSum_norm_inner_sq eE x).summable.mul_left (α / 2)).add (htailT_summ.mul_left (1 / (2 * α)))
    have hNorm_summ : Summable (fun i : ι₁ => ‖⟪eE i, x⟫_ℂ • (T - K) (eE i)‖) :=
      Summable.of_nonneg_of_le (fun _ => norm_nonneg _) hBound_term hMajor_summ
    calc ‖(T - K) x‖
        = ‖∑' i : ι₁, ⟪eE i, x⟫_ℂ • (T - K) (eE i)‖ := by rw [hSumX.tsum_eq]
      _ ≤ ∑' i : ι₁, ‖⟪eE i, x⟫_ℂ • (T - K) (eE i)‖ := norm_tsum_le_tsum_norm hNorm_summ
      _ ≤ ∑' i : ι₁, ((α / 2) * ‖⟪eE i, x⟫_ℂ‖ ^ 2 + (1 / (2 * α)) * tailT i) :=
            Summable.tsum_le_tsum hBound_term hNorm_summ hMajor_summ
      _ = (α / 2) * (∑' i : ι₁, ‖⟪eE i, x⟫_ℂ‖ ^ 2) + (1 / (2 * α)) * (∑' i : ι₁, tailT i) := by
            rw [((hasSum_norm_inner_sq eE x).summable.mul_left _).tsum_add (htailT_summ.mul_left _),
              tsum_mul_left, tsum_mul_left]
      _ = (α / 2) * ‖x‖ ^ 2 + (1 / (2 * α)) * (∑' i : ι₁, tailT i) := by
            rw [(hasSum_norm_inner_sq eE x).tsum_eq]
      _ ≤ (α / 2) * ‖x‖ ^ 2 + (1 / (2 * α)) * δ ^ 2 := by
            gcongr
      _ = δ * ‖x‖ := by
            dsimp [α]; field_simp [hx_pos.ne', hδ.ne']; ring
  refine ⟨K, hK_comp, ?_⟩
  rw [dist_eq_norm]
  have hδ_lt : δ < ε := by dsimp [δ]; linarith
  linarith

/-- **Theorem 1.2 (Finite-Rank Invertible Perturbation of Index-0 Fredholm Operators):**
Every index-0 Fredholm operator `T : E →L[ℂ] F` between complex Hilbert spaces differs from
a topological linear isomorphism `e : E ≃L[ℂ] F` by a finite-rank bounded operator. -/
theorem exists_equiv_sub_finiteRank_of_index_zero {T : E →L[ℂ] F}
    (hFred : IsFredholm T) (hIdx : fredholmIndex T = 0) :
    ∃ e : E ≃L[ℂ] F, FiniteDimensional ℂ (LinearMap.range (T - (e : E →L[ℂ] F)).toLinearMap) := by
  let K := LinearMap.ker T.toLinearMap
  let R := LinearMap.range T.toLinearMap
  have hKclosed : IsClosed (K : Set E) := isClosed_singleton.preimage T.continuous
  have : CompleteSpace K := hKclosed.completeSpace_coe
  have : CompleteSpace R := hFred.closedRange.completeSpace_coe
  have : FiniteDimensional ℂ K := hFred.finDimKer
  have : FiniteDimensional ℂ (F ⧸ R) := hFred.finDimCoker
  have hRcompl : IsCompl R Rᗮ := R.isCompl_orthogonal
  let eRperp : Rᗮ ≃ₗ[ℂ] (F ⧸ R) := (Submodule.quotientEquivOfIsCompl R Rᗮ hRcompl).symm
  have : FiniteDimensional ℂ Rᗮ := eRperp.symm.finiteDimensional
  have hfinrank : Module.finrank ℂ K = Module.finrank ℂ Rᗮ := by
    have h0 : (Module.finrank ℂ K : ℤ) - (Module.finrank ℂ (F ⧸ R) : ℤ) = 0 := hIdx
    have h1 : Module.finrank ℂ K = Module.finrank ℂ (F ⧸ R) := by omega
    rw [h1, eRperp.finrank_eq]
  let φ : K ≃ₗ[ℂ] Rᗮ := LinearEquiv.ofFinrankEq K Rᗮ hfinrank
  let Φ : E →L[ℂ] F :=
    Rᗮ.subtypeL.comp (φ.toLinearMap.toContinuousLinearMap.comp K.orthogonalProjectionOnto)
  let Q : E →L[ℂ] F := T + Φ
  have hQ_inj : Function.Injective Q := by
    rw [injective_iff_map_eq_zero]
    intro x hx
    have hsum : T x + (φ (K.orthogonalProjectionOnto x) : F) = 0 := hx
    have hTxR : T x ∈ R := ⟨x, rfl⟩
    have hΦRperp : (φ (K.orthogonalProjectionOnto x) : F) ∈ Rᗮ := (φ (K.orthogonalProjectionOnto x)).2
    have hΦ_in_R : (φ (K.orthogonalProjectionOnto x) : F) ∈ R := by
      have : (φ (K.orthogonalProjectionOnto x) : F) = -(T x) := eq_neg_of_add_eq_zero_right hsum
      rw [this]; exact R.neg_mem hTxR
    have hΦ0 : (φ (K.orthogonalProjectionOnto x) : F) = 0 := by
      have hmem : (φ (K.orthogonalProjectionOnto x) : F) ∈ R ⊓ Rᗮ := ⟨hΦ_in_R, hΦRperp⟩
      rwa [hRcompl.inf_eq_bot, Submodule.mem_bot] at hmem
    have hproj0 : K.orthogonalProjectionOnto x = 0 := φ.injective (Subtype.ext (by simpa using hΦ0))
    have hTx0 : x ∈ K := by simpa [K, LinearMap.mem_ker, hΦ0] using hsum
    have hself : K.orthogonalProjectionOnto x = ⟨x, hTx0⟩ :=
      Submodule.orthogonalProjectionOnto_mem_subspace_eq_self ⟨x, hTx0⟩
    rw [hproj0] at hself
    exact (congrArg Subtype.val hself).symm
  have hQ_surj : Function.Surjective Q := by
    intro y
    have hy : y ∈ R ⊔ Rᗮ := by rw [hRcompl.sup_eq_top]; trivial
    obtain ⟨yR, ⟨x₁, rfl⟩, yP, hyP, rfl⟩ := Submodule.mem_sup.mp hy
    have hKcompl : IsCompl K Kᗮ := K.isCompl_orthogonal
    have hx₁ : x₁ ∈ K ⊔ Kᗮ := by rw [hKcompl.sup_eq_top]; trivial
    obtain ⟨xk, hxk, xp, hxp, rfl⟩ := Submodule.mem_sup.mp hx₁
    let u : K := φ.symm ⟨yP, hyP⟩
    have hproj_xp : K.orthogonalProjectionOnto xp = 0 := by
      apply ext_inner_left ℂ
      intro z
      rw [inner_zero_right]
      change ⟪(z : E), (K.orthogonalProjectionOnto xp : E)⟫_ℂ = 0
      have hsplit : xp = (K.orthogonalProjectionOnto xp : E) + (xp - K.orthogonalProjectionOnto xp) :=
        (add_sub_cancel _ _).symm
      have hortho : ⟪(z : E), xp - (K.orthogonalProjectionOnto xp : E)⟫_ℂ = 0 :=
        Submodule.sub_starProjection_mem_orthogonal xp (z : E) z.2
      have hxz : ⟪(z : E), xp⟫_ℂ = 0 := hxp (z : E) z.2
      rw [hsplit, inner_add_right, hortho, add_zero] at hxz
      exact hxz
    refine ⟨xp + (u : E), ?_⟩
    have hTu : T (u : E) = 0 := u.2
    have hTxk : T xk = 0 := hxk
    have hproj_u : K.orthogonalProjectionOnto (u : E) = u :=
      Submodule.orthogonalProjectionOnto_mem_subspace_eq_self u
    simp only [Q, Φ, add_apply, ContinuousLinearMap.comp_apply,
      Submodule.coe_subtypeL, Submodule.coe_subtype, map_add, hTu, hproj_xp, hproj_u]
    simp [u, hTxk]
  let e : E ≃L[ℂ] F :=
    ContinuousLinearEquiv.ofBijective Q (LinearMap.ker_eq_bot.mpr hQ_inj)
      (LinearMap.range_eq_top.mpr hQ_surj)
  refine ⟨e, ?_⟩
  have hsub : T - (e : E →L[ℂ] F) = -Φ := by
    ext x; simp [e, Q]
  rw [hsub]
  have hle : LinearMap.range (-Φ).toLinearMap ≤ Rᗮ := by
    rintro _ ⟨x, rfl⟩
    exact Rᗮ.neg_mem (φ (K.orthogonalProjectionOnto x)).2
  exact FiniteDimensional.of_injective (Submodule.inclusion hle) (Submodule.inclusion_injective hle)

end TraceClassFoundation

/-! ============================================================================
## Section 2: Trace-Class Ideal `ℐ₁(H₊)`, Group `𝒯(H₊)` & `FredholmDetTheory`
============================================================================ -/

section TraceClassIdealAndDet

variable {ιP ιM : Type*} {H : Type*}
  [NormedAddCommGroup H] [InnerProductSpace ℂ H] [CompleteSpace H]

/-- The trace-class two-sided ideal `ℐ₁(H₊)` generated by products `A ∘ B` of Hilbert–Schmidt
operators factoring through the ambient polarized Hilbert space `H`. -/
noncomputable def TraceClassIdeal (P : PolarizedHilbertSpace ℂ H)
    (eP : HilbertBasis ιP ℂ P.HPlus) (eM : HilbertBasis ιM ℂ P.HMinus) :
    Submodule ℂ (P.HPlus →L[ℂ] P.HPlus) :=
  Submodule.span ℂ { T : P.HPlus →L[ℂ] P.HPlus |
    ∃ (A : H →L[ℂ] P.HPlus) (B : P.HPlus →L[ℂ] H),
      IsHS (polarizedBasis P eP eM) A ∧ IsHS eP B ∧ T = A.comp B }

/-- Left-ideal closure of `TraceClassIdeal`. -/
theorem TraceClassIdeal.comp_left {P : PolarizedHilbertSpace ℂ H}
    {eP : HilbertBasis ιP ℂ P.HPlus} {eM : HilbertBasis ιM ℂ P.HMinus}
    (L : P.HPlus →L[ℂ] P.HPlus) {T : P.HPlus →L[ℂ] P.HPlus} (hT : T ∈ TraceClassIdeal P eP eM) :
    L.comp T ∈ TraceClassIdeal P eP eM := by
  refine Submodule.span_induction (p := fun T _ => L.comp T ∈ TraceClassIdeal P eP eM)
    ?_ ?_ ?_ ?_ hT
  · rintro _ ⟨A, B, hA, hB, rfl⟩
    exact Submodule.subset_span ⟨L.comp A, B, hA.comp_left L, hB, rfl⟩
  · simp
  · intro X Y _ _ hX hY
    rw [ContinuousLinearMap.comp_add]; exact Submodule.add_mem _ hX hY
  · intro c X _ hX
    rw [ContinuousLinearMap.comp_smul]; exact Submodule.smul_mem _ c hX

/-- Right-ideal closure of `TraceClassIdeal`. -/
theorem TraceClassIdeal.comp_right {P : PolarizedHilbertSpace ℂ H}
    {eP : HilbertBasis ιP ℂ P.HPlus} {eM : HilbertBasis ιM ℂ P.HMinus}
    {T : P.HPlus →L[ℂ] P.HPlus} (hT : T ∈ TraceClassIdeal P eP eM) (R : P.HPlus →L[ℂ] P.HPlus) :
    T.comp R ∈ TraceClassIdeal P eP eM := by
  refine Submodule.span_induction (p := fun T _ => T.comp R ∈ TraceClassIdeal P eP eM)
    ?_ ?_ ?_ ?_ hT
  · rintro _ ⟨A, B, hA, hB, rfl⟩
    exact Submodule.subset_span
      ⟨A, B.comp R, hA, hB.comp_right (eF := polarizedBasis P eP eM) R, rfl⟩
  · simp
  · intro X Y _ _ hX hY
    rw [ContinuousLinearMap.add_comp]; exact Submodule.add_mem _ hX hY
  · intro c X _ hX
    rw [ContinuousLinearMap.smul_comp]; exact Submodule.smul_mem _ c hX

/-- Every product `X ∘ Y` of cross-polarization Hilbert–Schmidt blocks (`H₋ → H₊` and `H₊ → H₋`)
belongs to `TraceClassIdeal`. -/
theorem TraceClassIdeal.of_hs_cross {P : PolarizedHilbertSpace ℂ H}
    {eP : HilbertBasis ιP ℂ P.HPlus} {eM : HilbertBasis ιM ℂ P.HMinus}
    {X : P.HMinus →L[ℂ] P.HPlus} {Y : P.HPlus →L[ℂ] P.HMinus}
    (hX : IsHS eM X) (hY : IsHS eP Y) :
    X.comp Y ∈ TraceClassIdeal P eP eM := by
  let A : H →L[ℂ] P.HPlus := X.comp P.HMinus.orthogonalProjectionOnto
  let B : P.HPlus →L[ℂ] H := P.HMinus.subtypeL.comp Y
  have hA : IsHS (polarizedBasis P eP eM) A := by
    let g : ιP ⊕ ιM → ℝ := Sum.elim (fun _ => 0) (fun j => ‖X (eM j)‖ ^ 2)
    have hg : Summable g :=
      (Sum.inr_injective.summable_iff (f := g) (by
        rintro (i | _) hne
        · rfl
        · exact absurd ⟨_, rfl⟩ hne)).mp hX
    refine hg.congr ?_
    rintro (i | j)
    · change 0 = ‖X (P.HMinus.orthogonalProjectionOnto (polarizedBasis P eP eM (Sum.inl i)))‖ ^ 2
      have he : polarizedBasis P eP eM (Sum.inl i) = (eP i : H) := by simp [polarizedBasis]
      rw [he, orthoProj_minus_of_mem_plus, map_zero, norm_zero, zero_pow two_ne_zero]
    · change ‖X (eM j)‖ ^ 2 = ‖X (P.HMinus.orthogonalProjectionOnto (polarizedBasis P eP eM (Sum.inr j)))‖ ^ 2
      have he : polarizedBasis P eP eM (Sum.inr j) = (eM j : H) := by simp [polarizedBasis]
      rw [he, Submodule.orthogonalProjectionOnto_mem_subspace_eq_self]
  have hB : IsHS eP B := hY
  have hEq : X.comp Y = A.comp B := by
    ext x
    simp [A, B, Submodule.orthogonalProjectionOnto_mem_subspace_eq_self]
  exact Submodule.subset_span ⟨A, B, hA, hB, hEq⟩

/-- Every product `X ∘ Y` of Hilbert–Schmidt endomorphisms of `H₊` belongs to `TraceClassIdeal`. -/
theorem TraceClassIdeal.of_hs_end {P : PolarizedHilbertSpace ℂ H}
    {eP : HilbertBasis ιP ℂ P.HPlus} {eM : HilbertBasis ιM ℂ P.HMinus}
    {X Y : P.HPlus →L[ℂ] P.HPlus} (hX : IsHS eP X) (hY : IsHS eP Y) :
    X.comp Y ∈ TraceClassIdeal P eP eM := by
  let A : H →L[ℂ] P.HPlus := X.comp P.HPlus.orthogonalProjectionOnto
  let B : P.HPlus →L[ℂ] H := P.HPlus.subtypeL.comp Y
  have hA : IsHS (polarizedBasis P eP eM) A := by
    let g : ιP ⊕ ιM → ℝ := Sum.elim (fun i => ‖X (eP i)‖ ^ 2) (fun _ => 0)
    have hg : Summable g :=
      (Sum.inl_injective.summable_iff (f := g) (by
        rintro (_ | j) hne
        · exact absurd ⟨_, rfl⟩ hne
        · rfl)).mp hX
    refine hg.congr ?_
    rintro (i | j)
    · change ‖X (eP i)‖ ^ 2 = ‖X (P.HPlus.orthogonalProjectionOnto (polarizedBasis P eP eM (Sum.inl i)))‖ ^ 2
      have he : polarizedBasis P eP eM (Sum.inl i) = (eP i : H) := by simp [polarizedBasis]
      rw [he, Submodule.orthogonalProjectionOnto_mem_subspace_eq_self]
    · change 0 = ‖X (P.HPlus.orthogonalProjectionOnto (polarizedBasis P eP eM (Sum.inr j)))‖ ^ 2
      have he : polarizedBasis P eP eM (Sum.inr j) = (eM j : H) := by simp [polarizedBasis]
      rw [he, orthoProj_plus_of_mem_minus, map_zero, norm_zero, zero_pow two_ne_zero]
  have hB : IsHS eP B := hY
  have hEq : X.comp Y = A.comp B := by
    ext x
    simp [A, B, Submodule.orthogonalProjectionOnto_mem_subspace_eq_self]
  exact Submodule.subset_span ⟨A, B, hA, hB, hEq⟩

/-- Every finite-rank operator on `H₊` belongs to `TraceClassIdeal`. -/
theorem TraceClassIdeal.of_finiteDimensional_range {P : PolarizedHilbertSpace ℂ H}
    {eP : HilbertBasis ιP ℂ P.HPlus} {eM : HilbertBasis ιM ℂ P.HMinus}
    (T : P.HPlus →L[ℂ] P.HPlus) [FiniteDimensional ℂ (LinearMap.range T.toLinearMap)] :
    T ∈ TraceClassIdeal P eP eM := by
  let R := LinearMap.range T.toLinearMap
  have : CompleteSpace R := (Submodule.closed_of_finiteDimensional R).completeSpace_coe
  let PR : P.HPlus →L[ℂ] P.HPlus := R.subtypeL.comp R.orthogonalProjectionOnto
  have hPR_range : LinearMap.range PR.toLinearMap ≤ R := by
    rintro _ ⟨x, rfl⟩; exact (R.orthogonalProjectionOnto x).2
  have : FiniteDimensional ℂ (LinearMap.range PR.toLinearMap) :=
    FiniteDimensional.of_injective (Submodule.inclusion hPR_range) (Submodule.inclusion_injective hPR_range)
  have hEq : T = PR.comp T := by
    apply ContinuousLinearMap.ext; intro x
    change T x = (R.orthogonalProjectionOnto (T x) : P.HPlus)
    exact (congrArg Subtype.val
      (Submodule.orthogonalProjectionOnto_mem_subspace_eq_self
        (⟨T x, LinearMap.mem_range.mpr ⟨x, rfl⟩⟩ : R))).symm
  rw [hEq]
  exact TraceClassIdeal.of_hs_end (isHS_of_finiteDimensional_range eP PR)
    (isHS_of_finiteDimensional_range eP T)

/-- Every trace-class operator on `H₊` is compact (`ℐ₁ ⊆ 𝒦`). -/
theorem TraceClassIdeal.isCompactOperator {P : PolarizedHilbertSpace ℂ H}
    {eP : HilbertBasis ιP ℂ P.HPlus} {eM : HilbertBasis ιM ℂ P.HMinus}
    {T : P.HPlus →L[ℂ] P.HPlus} (hT : T ∈ TraceClassIdeal P eP eM) :
    IsCompactOperator (T : P.HPlus → P.HPlus) := by
  refine Submodule.span_induction
    (p := fun (T : P.HPlus →L[ℂ] P.HPlus) _ => IsCompactOperator (T : P.HPlus → P.HPlus))
    ?_ isCompactOperator_zero (fun _ _ _ _ h1 h2 => h1.add h2)
    (fun c X _ h => by
      have hsc : ((c • X : P.HPlus →L[ℂ] P.HPlus) : P.HPlus → P.HPlus) =
          ((c • ContinuousLinearMap.id ℂ P.HPlus).comp X : P.HPlus → P.HPlus) := rfl
      rw [hsc]
      exact h.clm_comp (c • ContinuousLinearMap.id ℂ P.HPlus)) hT
  rintro _ ⟨A, B, _, hB, rfl⟩
  exact (IsHS.isCompactOperator hB).clm_comp A

/-- Multiplicative submonoid `1 + ℐ₁(H₊)` of determinant-class operators on `H₊`. -/
noncomputable def TraceClassMonoid (P : PolarizedHilbertSpace ℂ H)
    (eP : HilbertBasis ιP ℂ P.HPlus) (eM : HilbertBasis ιM ℂ P.HMinus) :
    Submonoid (P.HPlus →L[ℂ] P.HPlus) where
  carrier := { A | A - ContinuousLinearMap.id ℂ P.HPlus ∈ TraceClassIdeal P eP eM }
  one_mem' := by
    change ContinuousLinearMap.id ℂ P.HPlus - ContinuousLinearMap.id ℂ P.HPlus ∈ TraceClassIdeal P eP eM
    rw [sub_self]; exact Submodule.zero_mem _
  mul_mem' := fun {A B} hA hB => by
    have hsplit : A.comp B - ContinuousLinearMap.id ℂ P.HPlus =
        A.comp (B - ContinuousLinearMap.id ℂ P.HPlus) + (A - ContinuousLinearMap.id ℂ P.HPlus) := by
      ext x; simp
    change A.comp B - ContinuousLinearMap.id ℂ P.HPlus ∈ TraceClassIdeal P eP eM
    rw [hsplit]
    exact Submodule.add_mem _ (TraceClassIdeal.comp_left A hB) hA

/-- Structure group `𝒯(H₊) = GL(H₊) ∩ (1 + ℐ₁(H₊))` of the determinant bundle. -/
noncomputable def TraceClassGroup (P : PolarizedHilbertSpace ℂ H)
    (eP : HilbertBasis ιP ℂ P.HPlus) (eM : HilbertBasis ιM ℂ P.HMinus) :
    Subgroup (P.HPlus ≃L[ℂ] P.HPlus) where
  carrier := { t | (t : P.HPlus →L[ℂ] P.HPlus) - ContinuousLinearMap.id ℂ P.HPlus ∈ TraceClassIdeal P eP eM }
  one_mem' := by
    change ContinuousLinearMap.id ℂ P.HPlus - ContinuousLinearMap.id ℂ P.HPlus ∈ TraceClassIdeal P eP eM
    rw [sub_self]; exact Submodule.zero_mem _
  mul_mem' := fun {t₁ t₂} h₁ h₂ =>
    (TraceClassMonoid P eP eM).mul_mem h₁ h₂
  inv_mem' := fun {t} ht => by
    have hsplit : (t.symm : P.HPlus →L[ℂ] P.HPlus) - ContinuousLinearMap.id ℂ P.HPlus =
        -((t.symm : P.HPlus →L[ℂ] P.HPlus).comp
          ((t : P.HPlus →L[ℂ] P.HPlus) - ContinuousLinearMap.id ℂ P.HPlus)) := by
      ext x; simp
    change (t.symm : P.HPlus →L[ℂ] P.HPlus) - ContinuousLinearMap.id ℂ P.HPlus ∈ TraceClassIdeal P eP eM
    rw [hsplit]
    exact Submodule.neg_mem _ (TraceClassIdeal.comp_left _ ht)

/-- Conjugation by any `q ∈ GL(H₊)` preserves both `1 + ℐ₁` and `𝒯(H₊)`. -/
theorem traceClassMonoid_conj (P : PolarizedHilbertSpace ℂ H)
    (eP : HilbertBasis ιP ℂ P.HPlus) (eM : HilbertBasis ιM ℂ P.HMinus)
    (q : P.HPlus ≃L[ℂ] P.HPlus) {A : P.HPlus →L[ℂ] P.HPlus} (hA : A ∈ TraceClassMonoid P eP eM) :
    (q : P.HPlus →L[ℂ] P.HPlus) * A * (q.symm : P.HPlus →L[ℂ] P.HPlus) ∈ TraceClassMonoid P eP eM := by
  have hsplit : ((q : P.HPlus →L[ℂ] P.HPlus).comp A).comp (q.symm : P.HPlus →L[ℂ] P.HPlus) -
      ContinuousLinearMap.id ℂ P.HPlus =
      ((q : P.HPlus →L[ℂ] P.HPlus).comp (A - ContinuousLinearMap.id ℂ P.HPlus)).comp
        (q.symm : P.HPlus →L[ℂ] P.HPlus) := by
    ext x; simp
  change ((q : P.HPlus →L[ℂ] P.HPlus).comp A).comp (q.symm : P.HPlus →L[ℂ] P.HPlus) -
    ContinuousLinearMap.id ℂ P.HPlus ∈ TraceClassIdeal P eP eM
  rw [hsplit]
  exact TraceClassIdeal.comp_right (TraceClassIdeal.comp_left _ hA) _

theorem traceClassGroup_conj (P : PolarizedHilbertSpace ℂ H)
    (eP : HilbertBasis ιP ℂ P.HPlus) (eM : HilbertBasis ιM ℂ P.HMinus)
    (q : P.HPlus ≃L[ℂ] P.HPlus) {t : P.HPlus ≃L[ℂ] P.HPlus} (ht : t ∈ TraceClassGroup P eP eM) :
    q * t * q⁻¹ ∈ TraceClassGroup P eP eM :=
  traceClassMonoid_conj P eP eM q ht

/-- Rank-1 scaling operator `R(i₀, c) x = x + (c - 1) ⟪e_{i₀}, x⟫ e_{i₀}` in `1 + ℐ₁(H₊)`. -/
noncomputable def rankOneScale (P : PolarizedHilbertSpace ℂ H)
    (eP : HilbertBasis ιP ℂ P.HPlus) (i₀ : ιP) (c : ℂ) : P.HPlus →L[ℂ] P.HPlus :=
  ContinuousLinearMap.id ℂ P.HPlus + (c - 1) • (innerSL ℂ (eP i₀)).smulRight (eP i₀)

lemma rankOneScale_mem_monoid (P : PolarizedHilbertSpace ℂ H)
    (eP : HilbertBasis ιP ℂ P.HPlus) (eM : HilbertBasis ιM ℂ P.HMinus) (i₀ : ιP) (c : ℂ) :
    rankOneScale P eP i₀ c ∈ TraceClassMonoid P eP eM := by
  have hsub : rankOneScale P eP i₀ c - ContinuousLinearMap.id ℂ P.HPlus =
      (c - 1) • (innerSL ℂ (eP i₀)).smulRight (eP i₀) := by
    unfold rankOneScale; abel
  change rankOneScale P eP i₀ c - ContinuousLinearMap.id ℂ P.HPlus ∈ TraceClassIdeal P eP eM
  rw [hsub]
  let F := (c - 1) • (innerSL ℂ (eP i₀)).smulRight (eP i₀)
  have hle : LinearMap.range F.toLinearMap ≤ Submodule.span ℂ ({eP i₀} : Set P.HPlus) := by
    rintro _ ⟨x, rfl⟩
    simp only [F, ContinuousLinearMap.coe_coe, smul_apply, ContinuousLinearMap.smulRight_apply]
    exact Submodule.smul_mem _ _ (Submodule.smul_mem _ _ (Submodule.subset_span rfl))
  have : FiniteDimensional ℂ (Submodule.span ℂ ({eP i₀} : Set P.HPlus)) :=
    FiniteDimensional.span_of_finite ℂ (Set.finite_singleton _)
  have : FiniteDimensional ℂ (LinearMap.range F.toLinearMap) :=
    FiniteDimensional.of_injective (Submodule.inclusion hle) (Submodule.inclusion_injective hle)
  exact TraceClassIdeal.of_finiteDimensional_range F

lemma rankOneScale_mul (P : PolarizedHilbertSpace ℂ H)
    (eP : HilbertBasis ιP ℂ P.HPlus) (i₀ : ιP) (c₁ c₂ : ℂ) :
    rankOneScale P eP i₀ c₁ * rankOneScale P eP i₀ c₂ = rankOneScale P eP i₀ (c₁ * c₂) := by
  have hself : ⟪eP i₀, eP i₀⟫_ℂ = 1 := by
    rw [inner_self_eq_norm_sq_to_K, eP.orthonormal.1 i₀]; norm_num
  apply ContinuousLinearMap.ext; intro x
  change (rankOneScale P eP i₀ c₁) ((rankOneScale P eP i₀ c₂) x) = rankOneScale P eP i₀ (c₁ * c₂) x
  simp only [rankOneScale, add_apply, ContinuousLinearMap.id_apply, smul_apply,
    ContinuousLinearMap.smulRight_apply, innerSL_apply_apply, inner_add_right,
    inner_smul_right, hself, mul_one, smul_smul]
  rw [add_assoc, ← add_smul]
  congr 2; ring

lemma rankOneScale_one (P : PolarizedHilbertSpace ℂ H)
    (eP : HilbertBasis ιP ℂ P.HPlus) (i₀ : ιP) :
    rankOneScale P eP i₀ 1 = ContinuousLinearMap.id ℂ P.HPlus := by
  ext x; simp [rankOneScale]

/-- Invertible rank-1 scaling element in `𝒯(H₊)` for `c ∈ ℂˣ`. -/
noncomputable def rankOneTraceClassEquiv (P : PolarizedHilbertSpace ℂ H)
    (eP : HilbertBasis ιP ℂ P.HPlus) (eM : HilbertBasis ιM ℂ P.HMinus) (i₀ : ιP) (c : ℂˣ) :
    TraceClassGroup P eP eM :=
  ⟨{ toLinearEquiv :=
      { toFun := rankOneScale P eP i₀ c
        invFun := rankOneScale P eP i₀ (c⁻¹ : ℂˣ)
        left_inv := fun x => by
          change (rankOneScale P eP i₀ (c⁻¹ : ℂˣ) * rankOneScale P eP i₀ c) x = x
          rw [rankOneScale_mul, ← Units.val_mul, inv_mul_cancel, Units.val_one, rankOneScale_one]; rfl
        right_inv := fun x => by
          change (rankOneScale P eP i₀ c * rankOneScale P eP i₀ (c⁻¹ : ℂˣ)) x = x
          rw [rankOneScale_mul, ← Units.val_mul, mul_inv_cancel, Units.val_one, rankOneScale_one]; rfl
        map_add' := fun x y => map_add _ x y
        map_smul' := fun r x => map_smul _ r x }
     continuous_toFun := (rankOneScale P eP i₀ c).continuous
     continuous_invFun := (rankOneScale P eP i₀ (c⁻¹ : ℂˣ)).continuous },
   rankOneScale_mem_monoid P eP eM i₀ c⟩

/-- Minimal axiomatic interface for the infinite-dimensional Fredholm determinant on `1 + ℐ₁(H₊)`. -/
class FredholmDetTheory (P : PolarizedHilbertSpace ℂ H)
    (eP : HilbertBasis ιP ℂ P.HPlus) (eM : HilbertBasis ιM ℂ P.HMinus) where
  detFr : TraceClassMonoid P eP eM →* ℂ
  detFr_conj : ∀ (q : P.HPlus ≃L[ℂ] P.HPlus) (A : TraceClassMonoid P eP eM),
    detFr ⟨(q : P.HPlus →L[ℂ] P.HPlus) * A.1 * (q.symm : P.HPlus →L[ℂ] P.HPlus),
      traceClassMonoid_conj P eP eM q A.2⟩ = detFr A
  detFr_rankOne : ∀ (i₀ : ιP) (c : ℂ),
    detFr ⟨rankOneScale P eP i₀ c, rankOneScale_mem_monoid P eP eM i₀ c⟩ = c
  detFr_ne_zero_iff : ∀ (A : TraceClassMonoid P eP eM),
    detFr A ≠ 0 ↔ Function.Bijective A.1

/-- Restricted group homomorphism `det_Fr : 𝒯(H₊) →* ℂˣ`. -/
noncomputable def detFrUnits (P : PolarizedHilbertSpace ℂ H)
    (eP : HilbertBasis ιP ℂ P.HPlus) (eM : HilbertBasis ιM ℂ P.HMinus)
    [FredholmDetTheory P eP eM] :
    TraceClassGroup P eP eM →* ℂˣ where
  toFun t := Units.mk0 (FredholmDetTheory.detFr ⟨(t.1 : P.HPlus →L[ℂ] P.HPlus), t.2⟩)
    ((FredholmDetTheory.detFr_ne_zero_iff _).mpr t.1.bijective)
  map_one' := by
    apply Units.ext
    exact (FredholmDetTheory.detFr (P := P) (eP := eP) (eM := eM)).map_one
  map_mul' t₁ t₂ := by
    apply Units.ext
    exact (FredholmDetTheory.detFr (P := P) (eP := eP) (eM := eM)).map_mul
      ⟨(t₁.1 : P.HPlus →L[ℂ] P.HPlus), t₁.2⟩ ⟨(t₂.1 : P.HPlus →L[ℂ] P.HPlus), t₂.2⟩

lemma detFrUnits_conj (P : PolarizedHilbertSpace ℂ H)
    (eP : HilbertBasis ιP ℂ P.HPlus) (eM : HilbertBasis ιM ℂ P.HMinus)
    [FredholmDetTheory P eP eM] (q : P.HPlus ≃L[ℂ] P.HPlus) (t : TraceClassGroup P eP eM) :
    detFrUnits P eP eM ⟨q * t.1 * q⁻¹, traceClassGroup_conj P eP eM q t.2⟩ =
      detFrUnits P eP eM t := by
  apply Units.ext
  exact FredholmDetTheory.detFr_conj q ⟨(t.1 : P.HPlus →L[ℂ] P.HPlus), t.2⟩

lemma detFrUnits_rankOne (P : PolarizedHilbertSpace ℂ H)
    (eP : HilbertBasis ιP ℂ P.HPlus) (eM : HilbertBasis ιM ℂ P.HMinus)
    [FredholmDetTheory P eP eM] (i₀ : ιP) (c : ℂˣ) :
    detFrUnits P eP eM (rankOneTraceClassEquiv P eP eM i₀ c) = c := by
  apply Units.ext
  exact FredholmDetTheory.detFr_rankOne i₀ c

end TraceClassIdealAndDet

/-! ============================================================================
## Section 3: Group-Level Central Extension `1 → ℂˣ → GL̂_(2)⁰(H) → GL_(2)⁰(H) → 1`
============================================================================ -/

section GroupCentralExtension

variable {ιP ιM : Type*} {H : Type*}
  [NormedAddCommGroup H] [InnerProductSpace ℂ H] [CompleteSpace H]

/-- Inclusion `GL_(2)(H) →* GL_res(H)` via `IsHS.isCompactOperator`. -/
noncomputable def gl2ToGLRes (P : PolarizedHilbertSpace ℂ H)
    (eP : HilbertBasis ιP ℂ P.HPlus) (eM : HilbertBasis ιM ℂ P.HMinus) :
    GL2Res P eP eM →* GLRes P where
  toFun g := ⟨g.1, IsHS.isCompactOperator g.2.1, IsHS.isCompactOperator g.2.2⟩
  map_one' := rfl
  map_mul' _ _ := rfl

/-- The identity-component (index-0) Hilbert–Schmidt restricted group `GL_(2)⁰(H)`. -/
noncomputable def GL2Res0 (P : PolarizedHilbertSpace ℂ H)
    (eP : HilbertBasis ιP ℂ P.HPlus) (eM : HilbertBasis ιM ℂ P.HMinus) :
    Subgroup (GL2Res P eP eM) where
  carrier := { g | glResIndex P (gl2ToGLRes P eP eM g) = 0 }
  one_mem' := by
    unfold glResIndex
    change fredholmIndex (blockPP P (ContinuousLinearMap.id ℂ H)) = 0
    rw [blockPP_id]
    exact fredholmIndex_of_equiv (ContinuousLinearEquiv.refl ℂ P.HPlus)
  mul_mem' := fun {g h} hg hh => by
    change glResIndex P (gl2ToGLRes P eP eM g * gl2ToGLRes P eP eM h) = 0
    rw [glResIndex_mul, hg, hh, add_zero]
  inv_mem' := fun {g} hg => by
    have h1 : glResIndex P (gl2ToGLRes P eP eM g⁻¹ * gl2ToGLRes P eP eM g) = 0 := by
      rw [← map_mul, inv_mul_cancel]
      unfold glResIndex
      change fredholmIndex (blockPP P (ContinuousLinearMap.id ℂ H)) = 0
      rw [blockPP_id]
      exact fredholmIndex_of_equiv (ContinuousLinearEquiv.refl ℂ P.HPlus)
    rw [glResIndex_mul, hg, add_zero] at h1
    exact h1

/-- Pressley–Segal pre-extension `ℰ = { (g, q) ∈ GL_(2)⁰(H) × GL(H₊) | g₊₊ q⁻¹ - 1 ∈ ℐ₁(H₊) }`. -/
noncomputable def PreCentralExt (P : PolarizedHilbertSpace ℂ H)
    (eP : HilbertBasis ιP ℂ P.HPlus) (eM : HilbertBasis ιM ℂ P.HMinus) :
    Subgroup (GL2Res0 P eP eM × (P.HPlus ≃L[ℂ] P.HPlus)) where
  carrier := { p |
    (blockPP P (p.1.1.1 : H →L[ℂ] H)).comp (p.2.symm : P.HPlus →L[ℂ] P.HPlus) -
      ContinuousLinearMap.id ℂ P.HPlus ∈ TraceClassIdeal P eP eM }
  one_mem' := by
    change (blockPP P (ContinuousLinearMap.id ℂ H)).comp (ContinuousLinearMap.id ℂ P.HPlus) -
      ContinuousLinearMap.id ℂ P.HPlus ∈ TraceClassIdeal P eP eM
    rw [blockPP_id]
    simp
  mul_mem' := fun {p₁ p₂} h₁ h₂ => by
    let g₁ := p₁.1.1
    let g₂ := p₂.1.1
    let q₁ := p₁.2
    let q₂ := p₂.2
    have hsplit :
        (blockPP P ((g₁.1 : H →L[ℂ] H).comp (g₂.1 : H →L[ℂ] H))).comp
          ((q₂.symm : P.HPlus →L[ℂ] P.HPlus).comp (q₁.symm : P.HPlus →L[ℂ] P.HPlus)) -
          ContinuousLinearMap.id ℂ P.HPlus =
        ((blockPP P (g₁.1 : H →L[ℂ] H)).comp
          ((blockPP P (g₂.1 : H →L[ℂ] H)).comp (q₂.symm : P.HPlus →L[ℂ] P.HPlus) -
            ContinuousLinearMap.id ℂ P.HPlus)).comp (q₁.symm : P.HPlus →L[ℂ] P.HPlus) +
        ((blockPP P (g₁.1 : H →L[ℂ] H)).comp (q₁.symm : P.HPlus →L[ℂ] P.HPlus) -
          ContinuousLinearMap.id ℂ P.HPlus) +
        (((blockPM P (g₁.1 : H →L[ℂ] H)).comp (blockMP P (g₂.1 : H →L[ℂ] H))).comp
          ((q₂.symm : P.HPlus →L[ℂ] P.HPlus).comp (q₁.symm : P.HPlus →L[ℂ] P.HPlus))) := by
      rw [blockPP_comp]
      apply ContinuousLinearMap.ext; intro x
      simp only [sub_apply, add_apply, ContinuousLinearMap.comp_apply,
        ContinuousLinearMap.id_apply, map_sub]
      abel
    change (blockPP P ((g₁.1 : H →L[ℂ] H).comp (g₂.1 : H →L[ℂ] H))).comp
      ((q₂.symm : P.HPlus →L[ℂ] P.HPlus).comp (q₁.symm : P.HPlus →L[ℂ] P.HPlus)) -
      ContinuousLinearMap.id ℂ P.HPlus ∈ TraceClassIdeal P eP eM
    rw [hsplit]
    have ht1 := TraceClassIdeal.comp_right (TraceClassIdeal.comp_left (blockPP P (g₁.1 : H →L[ℂ] H)) h₂)
      (q₁.symm : P.HPlus →L[ℂ] P.HPlus)
    have ht3 := TraceClassIdeal.comp_right
      (TraceClassIdeal.of_hs_cross g₁.2.1 g₂.2.2)
      ((q₂.symm : P.HPlus →L[ℂ] P.HPlus).comp (q₁.symm : P.HPlus →L[ℂ] P.HPlus))
    exact Submodule.add_mem _ (Submodule.add_mem _ ht1 h₁) ht3
  inv_mem' := fun {p} hp => by
    let g := p.1.1
    let q := p.2
    have hginv : g.1⁻¹ ∈ GL2Res P eP eM := (GL2Res P eP eM).inv_mem g.2
    have hcomp_id :
        (blockPP P (g.1.symm : H →L[ℂ] H)).comp (blockPP P (g.1 : H →L[ℂ] H)) +
        (blockPM P (g.1.symm : H →L[ℂ] H)).comp (blockMP P (g.1 : H →L[ℂ] H)) =
          ContinuousLinearMap.id ℂ P.HPlus := by
      rw [← blockPP_comp]
      have hid : (g.1.symm : H →L[ℂ] H).comp (g.1 : H →L[ℂ] H) = ContinuousLinearMap.id ℂ H := by
        ext x; simp
      rw [hid, blockPP_id]
    have hsplit :
        (blockPP P (g.1.symm : H →L[ℂ] H)).comp (q : P.HPlus →L[ℂ] P.HPlus) -
          ContinuousLinearMap.id ℂ P.HPlus =
        -(((blockPP P (g.1.symm : H →L[ℂ] H)).comp
          ((blockPP P (g.1 : H →L[ℂ] H)).comp (q.symm : P.HPlus →L[ℂ] P.HPlus) -
            ContinuousLinearMap.id ℂ P.HPlus)).comp (q : P.HPlus →L[ℂ] P.HPlus)) -
        (blockPM P (g.1.symm : H →L[ℂ] H)).comp (blockMP P (g.1 : H →L[ℂ] H)) := by
      apply ContinuousLinearMap.ext; intro x
      have hid := congrArg (fun L : P.HPlus →L[ℂ] P.HPlus => L x) hcomp_id
      simp only [sub_apply, neg_apply, ContinuousLinearMap.comp_apply,
        ContinuousLinearMap.id_apply, add_apply, map_sub, ContinuousLinearEquiv.coe_coe,
        ContinuousLinearEquiv.symm_apply_apply] at hid ⊢
      conv_lhs => arg 2; rw [← hid]
      abel
    change (blockPP P (g.1.symm : H →L[ℂ] H)).comp (q : P.HPlus →L[ℂ] P.HPlus) -
      ContinuousLinearMap.id ℂ P.HPlus ∈ TraceClassIdeal P eP eM
    rw [hsplit]
    have ht1 := Submodule.neg_mem _ (TraceClassIdeal.comp_right
      (TraceClassIdeal.comp_left (blockPP P (g.1.symm : H →L[ℂ] H)) hp) (q : P.HPlus →L[ℂ] P.HPlus))
    have ht2 := TraceClassIdeal.of_hs_cross hginv.1 g.2.2
    exact Submodule.sub_mem _ ht1 ht2

lemma mem_traceClassGroup_of_fst_eq_one {P : PolarizedHilbertSpace ℂ H}
    {eP : HilbertBasis ιP ℂ P.HPlus} {eM : HilbertBasis ιM ℂ P.HMinus}
    {p : PreCentralExt P eP eM} (h1 : p.1.1 = 1) :
    p.1.2 ∈ TraceClassGroup P eP eM := by
  have hp := p.2
  change (blockPP P (p.1.1.1.1 : H →L[ℂ] H)).comp (p.1.2.symm : P.HPlus →L[ℂ] P.HPlus) -
    ContinuousLinearMap.id ℂ P.HPlus ∈ TraceClassIdeal P eP eM at hp
  have h1' : (p.1.1.1.1 : H →L[ℂ] H) = ContinuousLinearMap.id ℂ H := by
    rw [h1]; rfl
  rw [h1', blockPP_id] at hp
  have hinv : p.1.2⁻¹ ∈ TraceClassGroup P eP eM := hp
  simpa using (TraceClassGroup P eP eM).inv_mem hinv

/-- The normal subgroup `N = { (1, t) ∈ ℰ | det_Fr(t) = 1 }`. -/
noncomputable def DetOneKernel (P : PolarizedHilbertSpace ℂ H)
    (eP : HilbertBasis ιP ℂ P.HPlus) (eM : HilbertBasis ιM ℂ P.HMinus)
    [FredholmDetTheory P eP eM] :
    Subgroup (PreCentralExt P eP eM) where
  carrier := { p | ∃ h1 : p.1.1 = 1,
    detFrUnits P eP eM ⟨p.1.2, mem_traceClassGroup_of_fst_eq_one h1⟩ = 1 }
  one_mem' := ⟨rfl, (detFrUnits P eP eM).map_one⟩
  mul_mem' := fun {p₁ p₂} ⟨h₁, hd₁⟩ ⟨h₂, hd₂⟩ => by
    have h12 : (p₁ * p₂).1.1 = 1 := by simp [h₁, h₂]
    refine ⟨h12, ?_⟩
    have hmul : (⟨(p₁ * p₂).1.2, mem_traceClassGroup_of_fst_eq_one h12⟩ : TraceClassGroup P eP eM) =
        ⟨p₁.1.2, mem_traceClassGroup_of_fst_eq_one h₁⟩ *
        ⟨p₂.1.2, mem_traceClassGroup_of_fst_eq_one h₂⟩ := rfl
    rw [hmul, map_mul, hd₁, hd₂, mul_one]
  inv_mem' := fun {p} ⟨h₁, hd₁⟩ => by
    have hinv : (p⁻¹).1.1 = 1 := by simp [h₁]
    refine ⟨hinv, ?_⟩
    have heq : (⟨(p⁻¹).1.2, mem_traceClassGroup_of_fst_eq_one hinv⟩ : TraceClassGroup P eP eM) =
        (⟨p.1.2, mem_traceClassGroup_of_fst_eq_one h₁⟩ : TraceClassGroup P eP eM)⁻¹ := rfl
    rw [heq, map_inv, hd₁, inv_one]

instance detOneKernel_normal (P : PolarizedHilbertSpace ℂ H)
    (eP : HilbertBasis ιP ℂ P.HPlus) (eM : HilbertBasis ιM ℂ P.HMinus)
    [FredholmDetTheory P eP eM] :
    (DetOneKernel P eP eM).Normal where
  conj_mem := fun n ⟨h1, hd⟩ g => by
    have hconj1 : (g * n * g⁻¹).1.1 = 1 := by
      change g.1.1 * n.1.1 * g.1.1⁻¹ = 1
      rw [h1, mul_one, mul_inv_cancel]
    refine ⟨hconj1, ?_⟩
    have hconj2 := detFrUnits_conj P eP eM g.1.2 ⟨n.1.2, mem_traceClassGroup_of_fst_eq_one h1⟩
    simpa [hd] using hconj2

/-- **Definition (Group-Level Central Extension):** `GL̂_(2)⁰(H) := ℰ ⧸ N`. -/
abbrev GL2CentralExt (P : PolarizedHilbertSpace ℂ H)
    (eP : HilbertBasis ιP ℂ P.HPlus) (eM : HilbertBasis ιM ℂ P.HMinus)
    [FredholmDetTheory P eP eM] :=
  PreCentralExt P eP eM ⧸ DetOneKernel P eP eM

/-- Canonical projection `π : GL̂_(2)⁰(H) →* GL_(2)⁰(H)`. -/
noncomputable def centralProj (P : PolarizedHilbertSpace ℂ H)
    (eP : HilbertBasis ιP ℂ P.HPlus) (eM : HilbertBasis ιM ℂ P.HMinus)
    [FredholmDetTheory P eP eM] :
    GL2CentralExt P eP eM →* GL2Res0 P eP eM :=
  QuotientGroup.lift (DetOneKernel P eP eM)
    { toFun := fun p => p.1.1
      map_one' := rfl
      map_mul' := fun _ _ => rfl }
    (fun _ ⟨h1, _⟩ => h1)

/-- Embed any `t ∈ 𝒯(H₊)` into `ℰ` as `(1, t)`. -/
noncomputable def preCentralOfTraceClass (P : PolarizedHilbertSpace ℂ H)
    (eP : HilbertBasis ιP ℂ P.HPlus) (eM : HilbertBasis ιM ℂ P.HMinus)
    (t : TraceClassGroup P eP eM) : PreCentralExt P eP eM :=
  ⟨(1, t.1), by
    change (blockPP P (ContinuousLinearMap.id ℂ H)).comp (t.1.symm : P.HPlus →L[ℂ] P.HPlus) -
      ContinuousLinearMap.id ℂ P.HPlus ∈ TraceClassIdeal P eP eM
    rw [blockPP_id]
    exact (TraceClassGroup P eP eM).inv_mem t.2⟩

/-- Canonical central inclusion `ι : ℂˣ →* GL̂_(2)⁰(H)` (independent of basis index `i₀`). -/
noncomputable def centralIncl (P : PolarizedHilbertSpace ℂ H)
    (eP : HilbertBasis ιP ℂ P.HPlus) (eM : HilbertBasis ιM ℂ P.HMinus)
    [FredholmDetTheory P eP eM] [Nonempty ιP] :
    ℂˣ →* GL2CentralExt P eP eM :=
  let i₀ : ιP := Classical.arbitrary ιP
  { toFun := fun c =>
      QuotientGroup.mk (preCentralOfTraceClass P eP eM (rankOneTraceClassEquiv P eP eM i₀ c))
    map_one' := by
      change QuotientGroup.mk _ = QuotientGroup.mk (1 : PreCentralExt P eP eM)
      rw [QuotientGroup.eq]
      refine ⟨by simp [preCentralOfTraceClass], ?_⟩
      have h1 : (⟨((preCentralOfTraceClass P eP eM (rankOneTraceClassEquiv P eP eM i₀ 1))⁻¹ * 1).1.2,
          mem_traceClassGroup_of_fst_eq_one (by simp [preCentralOfTraceClass])⟩ : TraceClassGroup P eP eM) =
          (rankOneTraceClassEquiv P eP eM i₀ 1)⁻¹ := by
        apply Subtype.ext; simp [preCentralOfTraceClass]
      rw [h1, map_inv, detFrUnits_rankOne, inv_one]
    map_mul' := fun c₁ c₂ => by
      change QuotientGroup.mk _ = QuotientGroup.mk _ * QuotientGroup.mk _
      rw [← QuotientGroup.mk_mul, QuotientGroup.eq]
      refine ⟨by simp [preCentralOfTraceClass], ?_⟩
      have heq : (⟨((preCentralOfTraceClass P eP eM (rankOneTraceClassEquiv P eP eM i₀ (c₁ * c₂)))⁻¹ *
          (preCentralOfTraceClass P eP eM (rankOneTraceClassEquiv P eP eM i₀ c₁) *
           preCentralOfTraceClass P eP eM (rankOneTraceClassEquiv P eP eM i₀ c₂))).1.2,
          mem_traceClassGroup_of_fst_eq_one (by simp [preCentralOfTraceClass])⟩ : TraceClassGroup P eP eM) =
          (rankOneTraceClassEquiv P eP eM i₀ (c₁ * c₂))⁻¹ *
          (rankOneTraceClassEquiv P eP eM i₀ c₁ * rankOneTraceClassEquiv P eP eM i₀ c₂) := rfl
      rw [heq, map_mul, map_inv, map_mul, detFrUnits_rankOne, detFrUnits_rankOne,
        detFrUnits_rankOne, inv_mul_cancel] }

/-- Any `t ∈ 𝒯(H₊)` represents `centralIncl (detFrUnits t)` in `GL̂_(2)⁰(H)`. -/
theorem centralIncl_detFrUnits (P : PolarizedHilbertSpace ℂ H)
    (eP : HilbertBasis ιP ℂ P.HPlus) (eM : HilbertBasis ιM ℂ P.HMinus)
    [FredholmDetTheory P eP eM] [Nonempty ιP] (t : TraceClassGroup P eP eM) :
    centralIncl P eP eM (detFrUnits P eP eM t) =
      QuotientGroup.mk (preCentralOfTraceClass P eP eM t) := by
  change QuotientGroup.mk _ = QuotientGroup.mk _
  rw [QuotientGroup.eq]
  refine ⟨by simp [preCentralOfTraceClass], ?_⟩
  let i₀ : ιP := Classical.arbitrary ιP
  have heq : (⟨((preCentralOfTraceClass P eP eM
      (rankOneTraceClassEquiv P eP eM i₀ (detFrUnits P eP eM t)))⁻¹ *
      preCentralOfTraceClass P eP eM t).1.2,
      mem_traceClassGroup_of_fst_eq_one (by simp [preCentralOfTraceClass])⟩ : TraceClassGroup P eP eM) =
      (rankOneTraceClassEquiv P eP eM i₀ (detFrUnits P eP eM t))⁻¹ * t := rfl
  rw [heq, map_mul, map_inv, detFrUnits_rankOne, inv_mul_cancel]

/-- **Theorem 3.1 (Injectivity of `ι : ℂˣ ↪ GL̂_(2)⁰(H)`):** -/
theorem centralIncl_injective (P : PolarizedHilbertSpace ℂ H)
    (eP : HilbertBasis ιP ℂ P.HPlus) (eM : HilbertBasis ιM ℂ P.HMinus)
    [FredholmDetTheory P eP eM] [Nonempty ιP] :
    Function.Injective (centralIncl P eP eM) := by
  rw [injective_iff_map_eq_one]
  intro c hc
  change QuotientGroup.mk _ = QuotientGroup.mk (1 : PreCentralExt P eP eM) at hc
  rw [QuotientGroup.eq] at hc
  rcases hc with ⟨h1, hd⟩
  let i₀ : ιP := Classical.arbitrary ιP
  have heq : (⟨((preCentralOfTraceClass P eP eM (rankOneTraceClassEquiv P eP eM i₀ c))⁻¹ * 1).1.2,
      mem_traceClassGroup_of_fst_eq_one h1⟩ : TraceClassGroup P eP eM) =
      (rankOneTraceClassEquiv P eP eM i₀ c)⁻¹ := by
    apply Subtype.ext; simp [preCentralOfTraceClass]
  rw [heq, map_inv, detFrUnits_rankOne] at hd
  simpa using congrArg Inv.inv hd

/-- **Theorem 3.2 (Centrality):** `ι(ℂˣ) ≤ Z(GL̂_(2)⁰(H))`. -/
theorem centralIncl_mem_center (P : PolarizedHilbertSpace ℂ H)
    (eP : HilbertBasis ιP ℂ P.HPlus) (eM : HilbertBasis ιM ℂ P.HMinus)
    [FredholmDetTheory P eP eM] [Nonempty ιP] (c : ℂˣ) :
    centralIncl P eP eM c ∈ Subgroup.center (GL2CentralExt P eP eM) := by
  rw [Subgroup.mem_center_iff]
  intro x
  refine QuotientGroup.induction_on x fun p => ?_
  let i₀ : ιP := Classical.arbitrary ιP
  let t := rankOneTraceClassEquiv P eP eM i₀ c
  change (QuotientGroup.mk p : GL2CentralExt P eP eM) *
      (QuotientGroup.mk (preCentralOfTraceClass P eP eM t) : GL2CentralExt P eP eM) =
    (QuotientGroup.mk (preCentralOfTraceClass P eP eM t) : GL2CentralExt P eP eM) *
      (QuotientGroup.mk p : GL2CentralExt P eP eM)
  rw [← QuotientGroup.mk_mul, ← QuotientGroup.mk_mul, QuotientGroup.eq]
  refine ⟨by simp [preCentralOfTraceClass], ?_⟩
  have h1 : ((p * preCentralOfTraceClass P eP eM t)⁻¹ *
      (preCentralOfTraceClass P eP eM t * p)).1.1 = 1 := by
    simp [preCentralOfTraceClass]
  have heq : (⟨((p * preCentralOfTraceClass P eP eM t)⁻¹ *
      (preCentralOfTraceClass P eP eM t * p)).1.2,
      mem_traceClassGroup_of_fst_eq_one h1⟩ : TraceClassGroup P eP eM) =
      t⁻¹ * ⟨p.1.2⁻¹ * t.1 * (p.1.2⁻¹)⁻¹, traceClassGroup_conj P eP eM p.1.2⁻¹ t.2⟩ := by
    apply Subtype.ext
    simp [preCentralOfTraceClass, mul_assoc]
  rw [heq, map_mul, map_inv, detFrUnits_conj P eP eM p.1.2⁻¹ t, inv_mul_cancel]

/-- **Theorem 3.3 (Exactness):** `range(ι) = ker(π)`. -/
theorem exact_central_extension (P : PolarizedHilbertSpace ℂ H)
    (eP : HilbertBasis ιP ℂ P.HPlus) (eM : HilbertBasis ιM ℂ P.HMinus)
    [FredholmDetTheory P eP eM] [Nonempty ιP] :
    (centralIncl P eP eM).range = (centralProj P eP eM).ker := by
  ext x
  refine QuotientGroup.induction_on x fun p => ?_
  constructor
  · rintro ⟨c, hc⟩
    rw [MonoidHom.mem_ker, ← hc]
    change (preCentralOfTraceClass P eP eM
      (rankOneTraceClassEquiv P eP eM (Classical.arbitrary ιP) c)).1.1 = 1
    rfl
  · intro hp
    have h1 : p.1.1 = 1 := hp
    let t : TraceClassGroup P eP eM := ⟨p.1.2, mem_traceClassGroup_of_fst_eq_one h1⟩
    refine ⟨detFrUnits P eP eM t, ?_⟩
    rw [centralIncl_detFrUnits P eP eM t]
    congr 1
    apply Subtype.ext
    exact Prod.ext h1.symm rfl

/-- **Theorem 3.4 (Surjectivity of `π : GL̂_(2)⁰(H) ↠ GL_(2)⁰(H)`):** -/
theorem centralProj_surjective (P : PolarizedHilbertSpace ℂ H)
    (eP : HilbertBasis ιP ℂ P.HPlus) (eM : HilbertBasis ιM ℂ P.HMinus)
    [FredholmDetTheory P eP eM] :
    Function.Surjective (centralProj P eP eM) := by
  intro g
  have hFred : IsFredholm (blockPP P (g.1.1 : H →L[ℂ] H)) :=
    blockPP_isFredholm P (gl2ToGLRes P eP eM g.1)
  have hIdx : fredholmIndex (blockPP P (g.1.1 : H →L[ℂ] H)) = 0 := g.2
  obtain ⟨q, hFin⟩ := exists_equiv_sub_finiteRank_of_index_zero hFred hIdx
  have hSubTC : blockPP P (g.1.1 : H →L[ℂ] H) - (q : P.HPlus →L[ℂ] P.HPlus) ∈ TraceClassIdeal P eP eM :=
    TraceClassIdeal.of_finiteDimensional_range _
  have hPre : (g, q) ∈ PreCentralExt P eP eM := by
    have hEq : (blockPP P (g.1.1 : H →L[ℂ] H)).comp (q.symm : P.HPlus →L[ℂ] P.HPlus) -
        ContinuousLinearMap.id ℂ P.HPlus =
        (blockPP P (g.1.1 : H →L[ℂ] H) - (q : P.HPlus →L[ℂ] P.HPlus)).comp
          (q.symm : P.HPlus →L[ℂ] P.HPlus) := by
      ext x; simp
    change (blockPP P (g.1.1 : H →L[ℂ] H)).comp (q.symm : P.HPlus →L[ℂ] P.HPlus) -
      ContinuousLinearMap.id ℂ P.HPlus ∈ TraceClassIdeal P eP eM
    rw [hEq]
    exact TraceClassIdeal.comp_right hSubTC _
  exact ⟨QuotientGroup.mk ⟨(g, q), hPre⟩, rfl⟩

end GroupCentralExtension

/-! ============================================================================
## Section 4: Pressley–Segal Determinant Line Bundle `Det*(W)` & Equivariant Lift
============================================================================ -/

section DeterminantLineBundle

variable {ιP ιM : Type*} {H : Type*}
  [NormedAddCommGroup H] [InnerProductSpace ℂ H] [CompleteSpace H]

/-- The index-0 Hilbert–Schmidt Sato Grassmannian `Gr_(2)⁰(H)`:
closed subspaces `W ≤ H` with `p₊ : W → H₊` Fredholm of index `0` and
`p₋† : H₋ → W` Hilbert–Schmidt. -/
def MemGr2Sato0 (P : PolarizedHilbertSpace ℂ H)
    (_eP : HilbertBasis ιP ℂ P.HPlus) (eM : HilbertBasis ιM ℂ P.HMinus) (W : Submodule ℂ H) : Prop :=
  IsClosed (W : Set H) ∧
  IsFredholm (projPlus P W) ∧
  fredholmIndex (projPlus P W) = 0 ∧
  ∃ (_ : CompleteSpace W), IsHS eM (ContinuousLinearMap.adjoint (projMinus P W))

abbrev Gr2Sato0 (P : PolarizedHilbertSpace ℂ H)
    (eP : HilbertBasis ιP ℂ P.HPlus) (eM : HilbertBasis ιM ℂ P.HMinus) :=
  { W : Submodule ℂ H // MemGr2Sato0 P eP eM W }

instance Gr2Sato0.completeSpace {P : PolarizedHilbertSpace ℂ H}
    {eP : HilbertBasis ιP ℂ P.HPlus} {eM : HilbertBasis ιM ℂ P.HMinus}
    (W : Gr2Sato0 P eP eM) : CompleteSpace W.1 :=
  W.2.1.completeSpace_coe

lemma Gr2Sato0.adjoint_projMinus_isHS {P : PolarizedHilbertSpace ℂ H}
    {eP : HilbertBasis ιP ℂ P.HPlus} {eM : HilbertBasis ιM ℂ P.HMinus}
    (W : Gr2Sato0 P eP eM) :
    IsHS eM (ContinuousLinearMap.adjoint (projMinus P W.1)) := by
  rcases W.2.2.2.2 with ⟨_, h⟩
  exact h

/-- `IsHS` right-composition helper for maps into a closed subspace `W ≤ H`,
routing through the fixed ambient basis `polarizedBasis P eP eM`. -/
lemma IsHS.comp_right_sub {P : PolarizedHilbertSpace ℂ H}
    {eP : HilbertBasis ιP ℂ P.HPlus} {eM : HilbertBasis ιM ℂ P.HMinus}
    {W : Submodule ℂ H} {T : P.HMinus →L[ℂ] W}
    (hT : IsHS eM T) (B : P.HMinus →L[ℂ] P.HMinus) :
    IsHS eM (T.comp B) := by
  have h1 : IsHS eM (W.subtypeL.comp T) := hT
  exact h1.comp_right (eF := polarizedBasis P eP eM) B

/-- Every point `W ∈ Gr_(2)⁰(H)` lies in the compact Sato Grassmannian `Gr_res(H)`. -/
theorem Gr2Sato0.memSatoGrassmannian {P : PolarizedHilbertSpace ℂ H}
    {eP : HilbertBasis ιP ℂ P.HPlus} {eM : HilbertBasis ιM ℂ P.HMinus}
    (W : Gr2Sato0 P eP eM) :
    MemSatoGrassmannian P W.1 := by
  refine ⟨W.2.1, W.2.2.1, ?_⟩
  have hAdj : ContinuousLinearMap.adjoint (W.1.subtypeL) = W.1.orthogonalProjectionOnto := by
    apply ContinuousLinearMap.ext; intro y
    apply ext_inner_left ℂ
    intro x
    rw [ContinuousLinearMap.adjoint_inner_right]
    have hsplit : y = (W.1.orthogonalProjectionOnto y : H) + (y - W.1.orthogonalProjectionOnto y) :=
      (add_sub_cancel _ _).symm
    have hortho : ⟪(x : H), y - (W.1.orthogonalProjectionOnto y : H)⟫_ℂ = 0 :=
      Submodule.sub_starProjection_mem_orthogonal y (x : H) x.2
    change ⟪(x : H), y⟫_ℂ = ⟪(x : H), (W.1.orthogonalProjectionOnto y : H)⟫_ℂ
    conv_lhs => rw [hsplit, inner_add_right, hortho, add_zero]
  have hHS_sub : IsHS eM (W.1.subtypeL.comp (ContinuousLinearMap.adjoint (projMinus P W.1))) :=
    W.adjoint_projMinus_isHS
  have hHS_ext : IsHS (polarizedBasis P eP eM)
      ((projMinus P W.1).comp W.1.orthogonalProjectionOnto) := by
    have h := hHS_sub.adjoint (eF := polarizedBasis P eP eM)
    rw [ContinuousLinearMap.adjoint_comp, ContinuousLinearMap.adjoint_adjoint, hAdj] at h
    exact h
  have hEq : projMinus P W.1 =
      ((projMinus P W.1).comp W.1.orthogonalProjectionOnto).comp W.1.subtypeL := by
    ext x; simp [Submodule.orthogonalProjectionOnto_mem_subspace_eq_self]
  rw [hEq]
  exact (IsHS.isCompactOperator hHS_ext).comp_clm W.1.subtypeL

/-- Action of `GL_(2)⁰(H)` on `Gr_(2)⁰(H)` preserving virtual dimension `0` and `IsHS`. -/
noncomputable instance instMulActionGL2Res0 (P : PolarizedHilbertSpace ℂ H)
    (eP : HilbertBasis ιP ℂ P.HPlus) (eM : HilbertBasis ιM ℂ P.HMinus) :
    MulAction (GL2Res0 P eP eM) (Gr2Sato0 P eP eM) where
  smul g W :=
    ⟨W.1.map (g.1.1 : H →ₗ[ℂ] H), by
      let W' := W.1.map (g.1.1 : H →ₗ[ℂ] H)
      have hSato := glRes_smul_mem_and_vdim P (gl2ToGLRes P eP eM g.1)
        ⟨W.1, W.memSatoGrassmannian⟩
      have hClosed : IsClosed (W' : Set H) := hSato.1.1
      have : CompleteSpace W' := hClosed.completeSpace_coe
      have hIdx : fredholmIndex (projPlus P W') = 0 := by
        have h := hSato.2
        change fredholmIndex (projPlus P W') = glResIndex P (gl2ToGLRes P eP eM g.1) +
          fredholmIndex (projPlus P W.1) at h
        rw [h, g.2, W.2.2.2.1, add_zero]
      let e : W.1 ≃L[ℂ] W' := restrictEquiv g.1.1 W.1
      have hpm : projMinus P W' =
          ((blockMP P (g.1.1 : H →L[ℂ] H)).comp (projPlus P W.1) +
           (blockMM P (g.1.1 : H →L[ℂ] H)).comp (projMinus P W.1)).comp
            (e.symm : W' →L[ℂ] W.1) := by
        rw [← projMinus_restrictEquiv P g.1.1 W.1]
        apply ContinuousLinearMap.ext; intro y
        change projMinus P W' y = projMinus P W' (e (e.symm y))
        rw [e.apply_symm_apply]
      have hAdj : ContinuousLinearMap.adjoint (projMinus P W') =
          (ContinuousLinearMap.adjoint (e.symm : W' →L[ℂ] W.1)).comp
            ((ContinuousLinearMap.adjoint (projPlus P W.1)).comp
              (ContinuousLinearMap.adjoint (blockMP P (g.1.1 : H →L[ℂ] H))) +
             (ContinuousLinearMap.adjoint (projMinus P W.1)).comp
              (ContinuousLinearMap.adjoint (blockMM P (g.1.1 : H →L[ℂ] H)))) := by
        rw [hpm, ContinuousLinearMap.adjoint_comp, map_add,
          ContinuousLinearMap.adjoint_comp, ContinuousLinearMap.adjoint_comp]
      have hHS1 : IsHS eM ((ContinuousLinearMap.adjoint (projPlus P W.1)).comp
          (ContinuousLinearMap.adjoint (blockMP P (g.1.1 : H →L[ℂ] H)))) :=
        (g.1.2.2.adjoint (eF := eM)).comp_left _
      have hHS2 : IsHS eM ((ContinuousLinearMap.adjoint (projMinus P W.1)).comp
          (ContinuousLinearMap.adjoint (blockMM P (g.1.1 : H →L[ℂ] H)))) :=
        IsHS.comp_right_sub (P := P) (eP := eP) W.adjoint_projMinus_isHS _
      refine ⟨hClosed, hSato.1.2.1, hIdx, inferInstance, ?_⟩
      rw [hAdj]
      exact (hHS1.add hHS2).comp_left _⟩
  one_smul W := by
    apply Subtype.ext; ext x
    change x ∈ W.1.map LinearMap.id ↔ x ∈ W.1; simp
  mul_smul g₁ g₂ W := by
    apply Subtype.ext; ext x
    change x ∈ W.1.map ((g₁.1.1 : H →ₗ[ℂ] H).comp (g₂.1.1 : H →ₗ[ℂ] H)) ↔
      x ∈ (W.1.map (g₂.1.1 : H →ₗ[ℂ] H)).map (g₁.1.1 : H →ₗ[ℂ] H)
    rw [Submodule.map_comp]

/-! ### Admissible Frames (Stiefel `𝒯`-Torsor `𝒫(W)`) & Determinant Line `Det*(W)` -/

/-- An **admissible frame** for `W ∈ Gr_(2)⁰(H)` is a topological isomorphism `w : H₊ ≃L[ℂ] W`
such that `p₊ ∘ w - id ∈ ℐ₁(H₊)`. -/
abbrev AdmissibleFrame (P : PolarizedHilbertSpace ℂ H)
    (eP : HilbertBasis ιP ℂ P.HPlus) (eM : HilbertBasis ιM ℂ P.HMinus)
    (W : Gr2Sato0 P eP eM) :=
  { w : P.HPlus ≃L[ℂ] W.1 //
    (projPlus P W.1).comp (w : P.HPlus →L[ℂ] W.1) - ContinuousLinearMap.id ℂ P.HPlus ∈
      TraceClassIdeal P eP eM }

/-- **Theorem 4.1 (Existence of Admissible Frames):** Every `W ∈ Gr_(2)⁰(H)` admits
an admissible frame `w : H₊ ≃L[ℂ] W`. -/
theorem nonempty_admissibleFrame (P : PolarizedHilbertSpace ℂ H)
    (eP : HilbertBasis ιP ℂ P.HPlus) (eM : HilbertBasis ιM ℂ P.HMinus)
    (W : Gr2Sato0 P eP eM) :
    Nonempty (AdmissibleFrame P eP eM W) := by
  obtain ⟨u, hFin⟩ := exists_equiv_sub_finiteRank_of_index_zero W.2.2.1 W.2.2.2.1
  let w : P.HPlus ≃L[ℂ] W.1 := u.symm
  have hEq : (projPlus P W.1).comp (w : P.HPlus →L[ℂ] W.1) - ContinuousLinearMap.id ℂ P.HPlus =
      (projPlus P W.1 - (u : W.1 →L[ℂ] P.HPlus)).comp (w : P.HPlus →L[ℂ] W.1) := by
    ext x; simp [w]
  have hRange_le : LinearMap.range ((projPlus P W.1 - (u : W.1 →L[ℂ] P.HPlus)).comp
      (w : P.HPlus →L[ℂ] W.1)).toLinearMap ≤ LinearMap.range (projPlus P W.1 - (u : W.1 →L[ℂ] P.HPlus)).toLinearMap := by
    rintro _ ⟨x, rfl⟩; exact ⟨w x, rfl⟩
  have : FiniteDimensional ℂ (LinearMap.range ((projPlus P W.1 - (u : W.1 →L[ℂ] P.HPlus)).comp
      (w : P.HPlus →L[ℂ] W.1)).toLinearMap) :=
    FiniteDimensional.of_injective (Submodule.inclusion hRange_le) (Submodule.inclusion_injective hRange_le)
  exact ⟨⟨w, by rw [hEq]; exact TraceClassIdeal.of_finiteDimensional_range _⟩⟩

/-- **Theorem 4.2 (`𝒯(H₊)`-Torsor Transition):** Any two admissible frames `w₁, w₂` of `W`
differ by an element `w₁⁻¹ ∘ w₂ ∈ 𝒯(H₊)` (even when `W` lies outside the big cell). -/
noncomputable def frameTransition {P : PolarizedHilbertSpace ℂ H}
    {eP : HilbertBasis ιP ℂ P.HPlus} {eM : HilbertBasis ιM ℂ P.HMinus}
    {W : Gr2Sato0 P eP eM}
    (w₁ w₂ : AdmissibleFrame P eP eM W) : TraceClassGroup P eP eM :=
  ⟨w₂.1.trans w₁.1.symm, by
    let t : P.HPlus ≃L[ℂ] P.HPlus := w₂.1.trans w₁.1.symm
    let K₁ := (projPlus P W.1).comp (w₁.1 : P.HPlus →L[ℂ] W.1) - ContinuousLinearMap.id ℂ P.HPlus
    let K₂ := (projPlus P W.1).comp (w₂.1 : P.HPlus →L[ℂ] W.1) - ContinuousLinearMap.id ℂ P.HPlus
    let A : P.HPlus →L[ℂ] P.HPlus := (projPlus P W.1).comp (w₁.1 : P.HPlus →L[ℂ] W.1)
    have hA_eq : A = (1 : P.HPlus →L[ℂ] P.HPlus) + K₁ := by
      apply ContinuousLinearMap.ext; intro x; simp [A, K₁]
    have hK₁_comp : IsCompactOperator (K₁ : P.HPlus → P.HPlus) :=
      TraceClassIdeal.isCompactOperator w₁.2
    have hRS := rieszSchauder_id_add_compact (K := K₁) hK₁_comp
    rw [← hA_eq] at hRS
    obtain ⟨Q, hFin⟩ := exists_equiv_sub_finiteRank_of_index_zero hRS.1 hRS.2
    have hAQ : A - (Q : P.HPlus →L[ℂ] P.HPlus) ∈ TraceClassIdeal P eP eM :=
      TraceClassIdeal.of_finiteDimensional_range _
    have hAt : A.comp ((t : P.HPlus →L[ℂ] P.HPlus) - ContinuousLinearMap.id ℂ P.HPlus) = K₂ - K₁ := by
      ext x
      simp [A, K₁, K₂, t]
    have hEq : (t : P.HPlus →L[ℂ] P.HPlus) - ContinuousLinearMap.id ℂ P.HPlus =
        (Q.symm : P.HPlus →L[ℂ] P.HPlus).comp
          ((K₂ - K₁) - (A - (Q : P.HPlus →L[ℂ] P.HPlus)).comp
            ((t : P.HPlus →L[ℂ] P.HPlus) - ContinuousLinearMap.id ℂ P.HPlus)) := by
      apply ContinuousLinearMap.ext; intro x
      have h1 : A (t x) - A x = K₂ x - K₁ x := by
        simpa [ContinuousLinearEquiv.coe_coe] using congrArg (fun L : P.HPlus →L[ℂ] P.HPlus => L x) hAt
      have h2 : Q (t x - x) = (K₂ x - K₁ x) - (A (t x - x) - Q (t x - x)) := by
        rw [map_sub A, h1]; abel
      change t x - x = Q.symm ((K₂ x - K₁ x) - (A (t x - x) - Q (t x - x)))
      rw [← h2]
      exact (Q.symm_apply_apply _).symm
    change (t : P.HPlus →L[ℂ] P.HPlus) - ContinuousLinearMap.id ℂ P.HPlus ∈ TraceClassIdeal P eP eM
    rw [hEq]
    exact TraceClassIdeal.comp_left _
      (Submodule.sub_mem _ (Submodule.sub_mem _ w₂.2 w₁.2)
        (TraceClassIdeal.comp_right hAQ _))⟩

lemma frameTransition_refl {P : PolarizedHilbertSpace ℂ H}
    {eP : HilbertBasis ιP ℂ P.HPlus} {eM : HilbertBasis ιM ℂ P.HMinus}
    {W : Gr2Sato0 P eP eM} (w : AdmissibleFrame P eP eM W) :
    frameTransition w w = 1 := by
  apply Subtype.ext; apply DFunLike.ext; intro x
  change w.1.symm (w.1 x) = x
  exact w.1.symm_apply_apply x

lemma frameTransition_mul {P : PolarizedHilbertSpace ℂ H}
    {eP : HilbertBasis ιP ℂ P.HPlus} {eM : HilbertBasis ιM ℂ P.HMinus}
    {W : Gr2Sato0 P eP eM} (w₁ w₂ w₃ : AdmissibleFrame P eP eM W) :
    frameTransition w₁ w₂ * frameTransition w₂ w₃ = frameTransition w₁ w₃ := by
  apply Subtype.ext; apply DFunLike.ext; intro x
  change w₁.1.symm (w₂.1 (w₂.1.symm (w₃.1 x))) = w₁.1.symm (w₃.1 x)
  rw [w₂.1.apply_symm_apply]

lemma frameTransition_symm {P : PolarizedHilbertSpace ℂ H}
    {eP : HilbertBasis ιP ℂ P.HPlus} {eM : HilbertBasis ιM ℂ P.HMinus}
    {W : Gr2Sato0 P eP eM} (w₁ w₂ : AdmissibleFrame P eP eM W) :
    (frameTransition w₁ w₂)⁻¹ = frameTransition w₂ w₁ := by
  apply Subtype.ext; apply DFunLike.ext; intro x
  change (w₂.1.trans w₁.1.symm).symm x = w₂.1.symm (w₁.1 x)
  rfl

/-- Equivalence relation defining the dual Pressley–Segal determinant line `Det*(W)`:
`(w₁, λ₁) ≈ (w₂, λ₂) ↔ λ₂ = det_Fr(w₁⁻¹ ∘ w₂) · λ₁`. -/
def detStarSetoid (P : PolarizedHilbertSpace ℂ H)
    (eP : HilbertBasis ιP ℂ P.HPlus) (eM : HilbertBasis ιM ℂ P.HMinus)
    [FredholmDetTheory P eP eM] (W : Gr2Sato0 P eP eM) :
    Setoid (AdmissibleFrame P eP eM W × ℂ) where
  r p₁ p₂ := p₂.2 = (detFrUnits P eP eM (frameTransition p₁.1 p₂.1) : ℂ) * p₁.2
  iseqv :=
    { refl := fun p => by rw [frameTransition_refl, map_one, Units.val_one, one_mul]
      symm := fun {p₁ p₂} h => by
        rw [h, ← frameTransition_symm, map_inv, ← mul_assoc, Units.val_inv_eq_inv_val,
          inv_mul_cancel₀ (Units.ne_zero _), one_mul]
      trans := fun {p₁ p₂ p₃} h₁₂ h₂₃ => by
        rw [h₂₃, h₁₂, ← mul_assoc, ← Units.val_mul, mul_comm (detFrUnits P eP eM (frameTransition p₂.1 p₃.1)),
          ← map_mul, frameTransition_mul] }

/-- The Pressley–Segal determinant line fiber `Det*(W)` over `W ∈ Gr_(2)⁰(H)`. -/
def DetStar (P : PolarizedHilbertSpace ℂ H)
    (eP : HilbertBasis ιP ℂ P.HPlus) (eM : HilbertBasis ιM ℂ P.HMinus)
    [FredholmDetTheory P eP eM] (W : Gr2Sato0 P eP eM) :=
  Quotient (detStarSetoid P eP eM W)

section DetStarLinearStructure

variable {P : PolarizedHilbertSpace ℂ H}
  {eP : HilbertBasis ιP ℂ P.HPlus} {eM : HilbertBasis ιM ℂ P.HMinus}
  [FredholmDetTheory P eP eM] {W : Gr2Sato0 P eP eM}

noncomputable instance : Zero (DetStar P eP eM W) :=
  ⟨Quotient.mk (detStarSetoid P eP eM W) (Classical.choice (nonempty_admissibleFrame P eP eM W), 0)⟩

lemma detStar_zero_eq (w : AdmissibleFrame P eP eM W) :
    (0 : DetStar P eP eM W) = Quotient.mk (detStarSetoid P eP eM W) (w, 0) :=
  Quotient.sound (by change (0 : ℂ) = _ * 0; simp)

noncomputable instance : SMul ℂ (DetStar P eP eM W) where
  smul c := Quotient.lift (fun p => Quotient.mk (detStarSetoid P eP eM W) (p.1, c * p.2))
    (fun p₁ p₂ h => Quotient.sound (by
      change c * p₂.2 = (detFrUnits P eP eM (frameTransition p₁.1 p₂.1) : ℂ) * (c * p₁.2)
      rw [h]; ring))

noncomputable instance : Add (DetStar P eP eM W) where
  add := Quotient.lift₂
    (fun p₁ p₂ => Quotient.mk (detStarSetoid P eP eM W)
      (p₁.1, p₁.2 + ((detFrUnits P eP eM (frameTransition p₁.1 p₂.1))⁻¹ : ℂˣ) * p₂.2))
    (fun a₁ b₁ a₂ b₂ ha hb => Quotient.sound (by
      change a₂.2 + ((detFrUnits P eP eM (frameTransition a₂.1 b₂.1))⁻¹ : ℂˣ) * b₂.2 =
        (detFrUnits P eP eM (frameTransition a₁.1 a₂.1) : ℂ) *
          (a₁.2 + ((detFrUnits P eP eM (frameTransition a₁.1 b₁.1))⁻¹ : ℂˣ) * b₁.2)
      rw [ha, hb, mul_add]
      congr 1
      have hdet :
          ((detFrUnits P eP eM (frameTransition a₂.1 b₂.1))⁻¹ : ℂˣ) *
            (detFrUnits P eP eM (frameTransition b₁.1 b₂.1)) =
          (detFrUnits P eP eM (frameTransition a₁.1 a₂.1)) *
            ((detFrUnits P eP eM (frameTransition a₁.1 b₁.1))⁻¹ : ℂˣ) := by
        rw [mul_comm ((detFrUnits P eP eM (frameTransition a₂.1 b₂.1))⁻¹ : ℂˣ),
          mul_comm (detFrUnits P eP eM (frameTransition a₁.1 a₂.1)),
          ← map_inv, ← map_inv, ← map_mul, ← map_mul,
          frameTransition_symm, frameTransition_symm,
          frameTransition_mul, frameTransition_mul]
      calc (((detFrUnits P eP eM (frameTransition a₂.1 b₂.1))⁻¹ : ℂˣ) : ℂ) *
            ((detFrUnits P eP eM (frameTransition b₁.1 b₂.1) : ℂ) * b₁.2)
          = ((((detFrUnits P eP eM (frameTransition a₂.1 b₂.1))⁻¹ : ℂˣ) *
              detFrUnits P eP eM (frameTransition b₁.1 b₂.1) : ℂˣ) : ℂ) * b₁.2 := by
            push_cast; ring
        _ = ((detFrUnits P eP eM (frameTransition a₁.1 a₂.1) *
              (detFrUnits P eP eM (frameTransition a₁.1 b₁.1))⁻¹ : ℂˣ) : ℂ) * b₁.2 := by
            rw [hdet]
        _ = (detFrUnits P eP eM (frameTransition a₁.1 a₂.1) : ℂ) *
              ((((detFrUnits P eP eM (frameTransition a₁.1 b₁.1))⁻¹ : ℂˣ) : ℂ) * b₁.2) := by
            push_cast; ring))

/-- **Theorem 4.3 (1-Dimensional Trivialization):** Any admissible frame `w` trivializes
`Det*(W)` onto `ℂ` via `⟦(w', λ)⟧ ↦ det_Fr(w⁻¹ ∘ w')⁻¹ · λ`. -/
noncomputable def detStarTriv (w : AdmissibleFrame P eP eM W) : DetStar P eP eM W ≃ ℂ where
  toFun := Quotient.lift
    (fun p => (((detFrUnits P eP eM (frameTransition w p.1))⁻¹ : ℂˣ) : ℂ) * p.2)
    (fun p₁ p₂ h => by
      rw [h]
      have h' : (((detFrUnits P eP eM (frameTransition w p₂.1))⁻¹ : ℂˣ) : ℂ) *
          (detFrUnits P eP eM (frameTransition p₁.1 p₂.1) : ℂ) =
          (((detFrUnits P eP eM (frameTransition w p₁.1))⁻¹ : ℂˣ) : ℂ) := by
        have h1 : detFrUnits P eP eM (frameTransition w p₁.1) *
            detFrUnits P eP eM (frameTransition p₁.1 p₂.1) =
            detFrUnits P eP eM (frameTransition w p₂.1) := by
          rw [← map_mul, frameTransition_mul]
        have h2 : (detFrUnits P eP eM (frameTransition w p₂.1))⁻¹ *
            detFrUnits P eP eM (frameTransition p₁.1 p₂.1) =
            (detFrUnits P eP eM (frameTransition w p₁.1))⁻¹ := by
          rw [← h1, mul_inv_rev, mul_comm (detFrUnits P eP eM (frameTransition p₁.1 p₂.1))⁻¹,
            mul_assoc, inv_mul_cancel, mul_one]
        rw [← Units.val_mul, h2]
      calc (((detFrUnits P eP eM (frameTransition w p₁.1))⁻¹ : ℂˣ) : ℂ) * p₁.2
          = ((((detFrUnits P eP eM (frameTransition w p₂.1))⁻¹ : ℂˣ) : ℂ) *
              (detFrUnits P eP eM (frameTransition p₁.1 p₂.1) : ℂ)) * p₁.2 := by rw [h']
        _ = (((detFrUnits P eP eM (frameTransition w p₂.1))⁻¹ : ℂˣ) : ℂ) *
              ((detFrUnits P eP eM (frameTransition p₁.1 p₂.1) : ℂ) * p₁.2) := by ring)
  invFun c := Quotient.mk (detStarSetoid P eP eM W) (w, c)
  left_inv v := Quotient.inductionOn v fun p => Quotient.sound (by
    change p.2 = (detFrUnits P eP eM (frameTransition w p.1) : ℂ) *
      ((((detFrUnits P eP eM (frameTransition w p.1))⁻¹ : ℂˣ) : ℂ) * p.2)
    rw [← mul_assoc, ← Units.val_mul, mul_inv_cancel, Units.val_one, one_mul])
  right_inv c := by
    change (((detFrUnits P eP eM (frameTransition w w))⁻¹ : ℂˣ) : ℂ) * c = c
    rw [frameTransition_refl, map_one, inv_one, Units.val_one, one_mul]

/-- **Definition (Canonical Pressley–Segal Holomorphic Section):**
`σ(W) = ⟦(w, det_Fr(p₊ ∘ w))⟧ ∈ Det*(W)`. -/
noncomputable def canonicalSection (P : PolarizedHilbertSpace ℂ H)
    (eP : HilbertBasis ιP ℂ P.HPlus) (eM : HilbertBasis ιM ℂ P.HMinus)
    [FredholmDetTheory P eP eM] (W : Gr2Sato0 P eP eM) : DetStar P eP eM W :=
  let w := Classical.choice (nonempty_admissibleFrame P eP eM W)
  Quotient.mk (detStarSetoid P eP eM W)
    (w, FredholmDetTheory.detFr ⟨(projPlus P W.1).comp (w.1 : P.HPlus →L[ℂ] W.1), w.2⟩)

/-- Frame-independence of the canonical Pressley–Segal section `σ(W)`. -/
theorem canonicalSection_eq (P : PolarizedHilbertSpace ℂ H)
    (eP : HilbertBasis ιP ℂ P.HPlus) (eM : HilbertBasis ιM ℂ P.HMinus)
    [FredholmDetTheory P eP eM] {W : Gr2Sato0 P eP eM}
    (w : AdmissibleFrame P eP eM W) :
    canonicalSection P eP eM W =
      Quotient.mk (detStarSetoid P eP eM W)
        (w, FredholmDetTheory.detFr ⟨(projPlus P W.1).comp (w.1 : P.HPlus →L[ℂ] W.1), w.2⟩) := by
  let w₀ := Classical.choice (nonempty_admissibleFrame P eP eM W)
  refine Quotient.sound ?_
  change FredholmDetTheory.detFr ⟨(projPlus P W.1).comp (w.1 : P.HPlus →L[ℂ] W.1), w.2⟩ =
    (detFrUnits P eP eM (frameTransition w₀ w) : ℂ) *
      FredholmDetTheory.detFr ⟨(projPlus P W.1).comp (w₀.1 : P.HPlus →L[ℂ] W.1), w₀.2⟩
  have hcomp : (⟨(projPlus P W.1).comp (w.1 : P.HPlus →L[ℂ] W.1), w.2⟩ : TraceClassMonoid P eP eM) =
      ⟨(projPlus P W.1).comp (w₀.1 : P.HPlus →L[ℂ] W.1), w₀.2⟩ *
      ⟨((frameTransition w₀ w).1 : P.HPlus →L[ℂ] P.HPlus), (frameTransition w₀ w).2⟩ := by
    apply Subtype.ext; ext x
    simp [frameTransition]
  rw [hcomp, map_mul, mul_comm]
  rfl

/-- **Theorem 4.4 (Big-Cell Non-Vanishing of `σ(W)`):**
`σ(W) ≠ 0` if and only if `W` lies in the Sato big cell (`ker p₊ = ⊥`). -/
theorem canonicalSection_ne_zero_iff_bigCell (P : PolarizedHilbertSpace ℂ H)
    (eP : HilbertBasis ιP ℂ P.HPlus) (eM : HilbertBasis ιM ℂ P.HMinus)
    [FredholmDetTheory P eP eM] (W : Gr2Sato0 P eP eM) :
    canonicalSection P eP eM W ≠ 0 ↔ LinearMap.ker (projPlus P W.1).toLinearMap = ⊥ := by
  let w := Classical.choice (nonempty_admissibleFrame P eP eM W)
  let m : TraceClassMonoid P eP eM := ⟨(projPlus P W.1).comp (w.1 : P.HPlus →L[ℂ] W.1), w.2⟩
  rw [canonicalSection_eq P eP eM w, detStar_zero_eq w]
  have hq : Quotient.mk (detStarSetoid P eP eM W) (w, FredholmDetTheory.detFr m) ≠
      Quotient.mk (detStarSetoid P eP eM W) (w, 0) ↔
      FredholmDetTheory.detFr m ≠ 0 := by
    constructor
    · intro hne h0; apply hne; rw [h0]
    · intro hne hEq
      have hr := Quotient.exact hEq
      change (0 : ℂ) = (detFrUnits P eP eM (frameTransition w w) : ℂ) * _ at hr
      rw [frameTransition_refl, map_one, Units.val_one, one_mul] at hr
      exact hne hr.symm
  refine hq.trans ?_
  rw [FredholmDetTheory.detFr_ne_zero_iff]
  change Function.Bijective ((projPlus P W.1).comp (w.1 : P.HPlus →L[ℂ] W.1)) ↔ _
  have hbij : Function.Bijective ((projPlus P W.1).comp (w.1 : P.HPlus →L[ℂ] W.1)) ↔
      Function.Bijective (projPlus P W.1) := by
    constructor
    · intro h
      have h1 : projPlus P W.1 = ((projPlus P W.1).comp (w.1 : P.HPlus →L[ℂ] W.1)).comp
          (w.1.symm : W.1 →L[ℂ] P.HPlus) := by ext x; simp
      rw [h1]; exact h.comp w.1.symm.bijective
    · intro h; exact h.comp w.1.bijective
  rw [hbij]
  have := W.2.2.1.finDimKer
  have := W.2.2.1.finDimCoker
  have hfin : Module.finrank ℂ (LinearMap.ker (projPlus P W.1).toLinearMap) =
      Module.finrank ℂ (P.HPlus ⧸ LinearMap.range (projPlus P W.1).toLinearMap) := by
    have h0 : (Module.finrank ℂ (LinearMap.ker (projPlus P W.1).toLinearMap) : ℤ) -
        (Module.finrank ℂ (P.HPlus ⧸ LinearMap.range (projPlus P W.1).toLinearMap) : ℤ) = 0 := W.2.2.2.1
    omega
  constructor
  · intro h
    exact LinearMap.ker_eq_bot.mpr h.1
  · intro hker
    refine ⟨LinearMap.ker_eq_bot.mp hker, ?_⟩
    rw [hker, finrank_bot] at hfin
    have hq0 : Module.finrank ℂ (P.HPlus ⧸ LinearMap.range (projPlus P W.1).toLinearMap) = 0 := hfin.symm
    have hsub : Subsingleton (P.HPlus ⧸ LinearMap.range (projPlus P W.1).toLinearMap) :=
      (Module.finrank_zero_iff (R := ℂ)).mp hq0
    have htop : LinearMap.range (projPlus P W.1).toLinearMap = ⊤ :=
      Submodule.Quotient.subsingleton_iff.mp hsub
    exact LinearMap.range_eq_top.mp htop

end DetStarLinearStructure

end DeterminantLineBundle

/-! ### Total Space `DetStarTotal`, Equivariant `GL̂_(2)⁰(H)` Action & Segal–Wilson `τ`-Function -/

section EquivariantActionAndTau

variable {ιP ιM : Type*} {H : Type*}
  [NormedAddCommGroup H] [InnerProductSpace ℂ H] [CompleteSpace H]

/-- Total space of the Pressley–Segal determinant line bundle over `Gr_(2)⁰(H)`. -/
abbrev DetStarTotal (P : PolarizedHilbertSpace ℂ H)
    (eP : HilbertBasis ιP ℂ P.HPlus) (eM : HilbertBasis ιM ℂ P.HMinus)
    [FredholmDetTheory P eP eM] :=
  Σ W : Gr2Sato0 P eP eM, DetStar P eP eM W

lemma detStarTotal_eq {P : PolarizedHilbertSpace ℂ H}
    {eP : HilbertBasis ιP ℂ P.HPlus} {eM : HilbertBasis ιM ℂ P.HMinus}
    [FredholmDetTheory P eP eM]
    {W₁ W₂ : Gr2Sato0 P eP eM} (hW : W₁ = W₂)
    (w₁ : AdmissibleFrame P eP eM W₁) (w₂ : AdmissibleFrame P eP eM W₂) (lam₁ lam₂ : ℂ)
    (hw : ∀ x : P.HPlus, (w₁.1 x : H) = (w₂.1 x : H)) (hlam : lam₁ = lam₂) :
    (⟨W₁, Quotient.mk (detStarSetoid P eP eM W₁) (w₁, lam₁)⟩ : DetStarTotal P eP eM) =
      ⟨W₂, Quotient.mk (detStarSetoid P eP eM W₂) (w₂, lam₂)⟩ := by
  subst hW; subst hlam
  have hweq : w₁ = w₂ := by
    apply Subtype.ext; ext x
    exact hw x
  rw [hweq]

/-- Frame transport `(g, q) • w := (restrictEquiv g W) ∘ w ∘ q⁻¹` preserving admissibility. -/
noncomputable def preCentralActFrame {P : PolarizedHilbertSpace ℂ H}
    {eP : HilbertBasis ιP ℂ P.HPlus} {eM : HilbertBasis ιM ℂ P.HMinus}
    (p : PreCentralExt P eP eM) {W : Gr2Sato0 P eP eM}
    (w : AdmissibleFrame P eP eM W) :
    AdmissibleFrame P eP eM (p.1.1 • W) :=
  let g := p.1.1.1
  let q := p.1.2
  let eW : W.1 ≃L[ℂ] (p.1.1 • W).1 := restrictEquiv g.1 W.1
  let w' : P.HPlus ≃L[ℂ] (p.1.1 • W).1 := (q.symm.trans w.1).trans eW
  ⟨w', by
    have hsplit :
        (projPlus P (p.1.1 • W).1).comp (w' : P.HPlus →L[ℂ] (p.1.1 • W).1) -
          ContinuousLinearMap.id ℂ P.HPlus =
        ((blockPP P (g.1 : H →L[ℂ] H)).comp
          ((projPlus P W.1).comp (w.1 : P.HPlus →L[ℂ] W.1) - ContinuousLinearMap.id ℂ P.HPlus)).comp
            (q.symm : P.HPlus →L[ℂ] P.HPlus) +
        ((blockPP P (g.1 : H →L[ℂ] H)).comp (q.symm : P.HPlus →L[ℂ] P.HPlus) -
          ContinuousLinearMap.id ℂ P.HPlus) +
        ((blockPM P (g.1 : H →L[ℂ] H)).comp
          ((projMinus P W.1).comp (w.1 : P.HPlus →L[ℂ] W.1))).comp
            (q.symm : P.HPlus →L[ℂ] P.HPlus) := by
      apply ContinuousLinearMap.ext; intro x
      have hint := congrArg (fun L : W.1 →L[ℂ] P.HPlus => L (w.1 (q.symm x)))
        (projPlus_restrictEquiv P g.1 W.1)
      change projPlus P (W.1.map (g.1 : H →ₗ[ℂ] H)) (restrictEquiv g.1 W.1 (w.1 (q.symm x))) =
        blockPP P (g.1 : H →L[ℂ] H) (projPlus P W.1 (w.1 (q.symm x))) +
        blockPM P (g.1 : H →L[ℂ] H) (projMinus P W.1 (w.1 (q.symm x))) at hint
      change projPlus P (W.1.map (g.1 : H →ₗ[ℂ] H)) (restrictEquiv g.1 W.1 (w.1 (q.symm x))) - x =
        blockPP P (g.1 : H →L[ℂ] H) (projPlus P W.1 (w.1 (q.symm x)) - q.symm x) +
        (blockPP P (g.1 : H →L[ℂ] H) (q.symm x) - x) +
        blockPM P (g.1 : H →L[ℂ] H) (projMinus P W.1 (w.1 (q.symm x)))
      rw [hint, map_sub]
      abel
    rw [hsplit]
    have ht1 := TraceClassIdeal.comp_right
      (TraceClassIdeal.comp_left (blockPP P (g.1 : H →L[ℂ] H)) w.2) (q.symm : P.HPlus →L[ℂ] P.HPlus)
    have ht2 : (blockPP P (g.1 : H →L[ℂ] H)).comp (q.symm : P.HPlus →L[ℂ] P.HPlus) -
        ContinuousLinearMap.id ℂ P.HPlus ∈ TraceClassIdeal P eP eM := p.2
    have hwMinus_HS : IsHS eP ((projMinus P W.1).comp (w.1 : P.HPlus →L[ℂ] W.1)) := by
      have h1 : IsHS eM ((ContinuousLinearMap.adjoint (w.1 : P.HPlus →L[ℂ] W.1)).comp
          (ContinuousLinearMap.adjoint (projMinus P W.1))) :=
        W.adjoint_projMinus_isHS.comp_left _
      have h2 := h1.adjoint (eF := eP)
      rw [← ContinuousLinearMap.adjoint_comp, ContinuousLinearMap.adjoint_adjoint] at h2
      exact h2
    have ht3 := TraceClassIdeal.comp_right
      (TraceClassIdeal.of_hs_cross g.2.1 hwMinus_HS) (q.symm : P.HPlus →L[ℂ] P.HPlus)
    exact Submodule.add_mem _ (Submodule.add_mem _ ht1 ht2) ht3⟩

/-- Pre-extension fiber map `Det*(W) → Det*(g • W)`. -/
noncomputable def preCentralActFiber {P : PolarizedHilbertSpace ℂ H}
    {eP : HilbertBasis ιP ℂ P.HPlus} {eM : HilbertBasis ιM ℂ P.HMinus}
    [FredholmDetTheory P eP eM] (p : PreCentralExt P eP eM) {W : Gr2Sato0 P eP eM} :
    DetStar P eP eM W → DetStar P eP eM (p.1.1 • W) :=
  Quotient.lift
    (fun x => Quotient.mk (detStarSetoid P eP eM (p.1.1 • W)) (preCentralActFrame p x.1, x.2))
    (fun x₁ x₂ h => Quotient.sound (by
      change x₂.2 = (detFrUnits P eP eM
        (frameTransition (preCentralActFrame p x₁.1) (preCentralActFrame p x₂.1)) : ℂ) * x₁.2
      have htr : frameTransition (preCentralActFrame p x₁.1) (preCentralActFrame p x₂.1) =
          ⟨p.1.2 * (frameTransition x₁.1 x₂.1).1 * p.1.2⁻¹,
            traceClassGroup_conj P eP eM p.1.2 (frameTransition x₁.1 x₂.1).2⟩ := by
        apply Subtype.ext; apply DFunLike.ext; intro u
        change p.1.2 (x₁.1.1.symm ((restrictEquiv p.1.1.1.1 W.1).symm
          (restrictEquiv p.1.1.1.1 W.1 (x₂.1.1 (p.1.2.symm u))))) =
          p.1.2 (x₁.1.1.symm (x₂.1.1 (p.1.2.symm u)))
        rw [(restrictEquiv p.1.1.1.1 W.1).symm_apply_apply]
      rw [htr, detFrUnits_conj]
      exact h))

/-- Action map `GL̂_(2)⁰(H) → Det*(H) → Det*(H)` lifted from the pre-extension. -/
noncomputable def centralExtSmul {P : PolarizedHilbertSpace ℂ H}
    {eP : HilbertBasis ιP ℂ P.HPlus} {eM : HilbertBasis ιM ℂ P.HMinus}
    [FredholmDetTheory P eP eM]
    (γ : GL2CentralExt P eP eM) (x : DetStarTotal P eP eM) : DetStarTotal P eP eM :=
  Quotient.liftOn γ (fun p => (⟨p.1.1 • x.1, preCentralActFiber p x.2⟩ : DetStarTotal P eP eM))
    (fun p₁ p₂ hrel => by
      have hker : p₁⁻¹ * p₂ ∈ DetOneKernel P eP eM := QuotientGroup.eq.mp (Quotient.sound hrel)
      rcases hker with ⟨h1, hd⟩
      have hgEq : p₁.1.1 = p₂.1.1 := by
        have : p₁.1.1⁻¹ * p₂.1.1 = 1 := h1
        exact inv_mul_eq_one.mp this
      let t : TraceClassGroup P eP eM :=
        ⟨(p₁⁻¹ * p₂).1.2, mem_traceClassGroup_of_fst_eq_one h1⟩
      refine Quotient.inductionOn x.2 fun pair => ?_
      have hW : p₁.1.1 • x.1 = p₂.1.1 • x.1 := by rw [hgEq]
      let w₁ := preCentralActFrame p₁ pair.1
      have hw_rel : ∀ (W₂ : Gr2Sato0 P eP eM) (hW' : p₁.1.1 • x.1 = W₂)
          (w₂ : AdmissibleFrame P eP eM W₂),
          (∀ u : P.HPlus, (w₂.1 u : H) = (p₂.1.1.1.1 (pair.1.1 (p₂.1.2.symm u)).1 : H)) →
          (⟨p₁.1.1 • x.1, Quotient.mk (detStarSetoid P eP eM _) (w₁, pair.2)⟩ : DetStarTotal P eP eM) =
          ⟨W₂, Quotient.mk (detStarSetoid P eP eM W₂) (w₂, pair.2)⟩ := by
        intro W₂ hW' w₂ hw₂_val
        subst hW'
        congr 1
        refine Quotient.sound ?_
        change pair.2 = (detFrUnits P eP eM (frameTransition w₁ w₂) : ℂ) * pair.2
        have htr : frameTransition w₁ w₂ =
            ⟨p₁.1.2 * (t⁻¹).1 * p₁.1.2⁻¹,
              traceClassGroup_conj P eP eM p₁.1.2 ((TraceClassGroup P eP eM).inv_mem t.2)⟩ := by
          apply Subtype.ext; apply DFunLike.ext; intro u
          have hinv_u : p₂.1.2.symm u = t.1.symm (p₁.1.2.symm u) := by
            change (p₂.1.2⁻¹) u = (p₁.1.2⁻¹ * p₂.1.2)⁻¹ (p₁.1.2⁻¹ u)
            rw [mul_inv_rev, inv_inv]
            change (p₂.1.2⁻¹) u = p₂.1.2⁻¹ (p₁.1.2 (p₁.1.2.symm u))
            rw [p₁.1.2.apply_symm_apply]
          have hstep : p₁.1.1.1.1.symm (w₂.1 u : H) = (pair.1.1 (p₂.1.2.symm u) : H) := by
            rw [hw₂_val u, ← hgEq]
            exact p₁.1.1.1.1.symm_apply_apply _
          have hsub : (⟨p₁.1.1.1.1.symm (w₂.1 u : H),
              by rw [hstep]; exact (pair.1.1 (p₂.1.2.symm u)).2⟩ : x.1.1) =
              pair.1.1 (p₂.1.2.symm u) := Subtype.ext hstep
          change p₁.1.2 (pair.1.1.symm ⟨p₁.1.1.1.1.symm (w₂.1 u : H), _⟩) =
            p₁.1.2 (t.1.symm (p₁.1.2.symm u))
          rw [hsub, pair.1.1.symm_apply_apply, hinv_u]
        rw [htr, detFrUnits_conj, map_inv, hd, inv_one, Units.val_one, one_mul]
      exact hw_rel (p₂.1.1 • x.1) hW (preCentralActFrame p₂ pair.1) (fun _ => rfl))

/-- **Theorem 4.5 (Equivariant Group Action of `GL̂_(2)⁰(H)` on `Det*(H)`):** -/
noncomputable instance instMulActionCentralExt (P : PolarizedHilbertSpace ℂ H)
    (eP : HilbertBasis ιP ℂ P.HPlus) (eM : HilbertBasis ιM ℂ P.HMinus)
    [FredholmDetTheory P eP eM] :
    MulAction (GL2CentralExt P eP eM) (DetStarTotal P eP eM) where
  smul := centralExtSmul
  one_smul x := by
    rcases x with ⟨W, v⟩
    refine Quotient.inductionOn v fun pair => ?_
    change centralExtSmul (QuotientGroup.mk (1 : PreCentralExt P eP eM))
      ⟨W, Quotient.mk (detStarSetoid P eP eM W) pair⟩ = _
    exact detStarTotal_eq (one_smul (GL2Res0 P eP eM) W)
      (preCentralActFrame (1 : PreCentralExt P eP eM) pair.1) pair.1 pair.2 pair.2
      (fun _ => rfl) rfl
  mul_smul γ₁ γ₂ x := by
    rcases x with ⟨W, v⟩
    refine QuotientGroup.induction_on γ₁ fun p₁ => QuotientGroup.induction_on γ₂ fun p₂ => ?_
    refine Quotient.inductionOn v fun pair => ?_
    change centralExtSmul ((QuotientGroup.mk p₁ : GL2CentralExt P eP eM) * QuotientGroup.mk p₂)
      ⟨W, Quotient.mk (detStarSetoid P eP eM W) pair⟩ =
      centralExtSmul (QuotientGroup.mk p₁)
        (centralExtSmul (QuotientGroup.mk p₂) ⟨W, Quotient.mk (detStarSetoid P eP eM W) pair⟩)
    rw [← QuotientGroup.mk_mul]
    exact detStarTotal_eq (mul_smul p₁.1.1 p₂.1.1 W)
      (preCentralActFrame (p₁ * p₂) pair.1)
      (preCentralActFrame p₁ (preCentralActFrame p₂ pair.1)) pair.2 pair.2
      (fun _ => rfl) rfl

/-- Bundle projection equivariance: `(γ • x).1 = (centralProj γ) • x.1`. -/
theorem centralExt_smul_base (P : PolarizedHilbertSpace ℂ H)
    (eP : HilbertBasis ιP ℂ P.HPlus) (eM : HilbertBasis ιM ℂ P.HMinus)
    [FredholmDetTheory P eP eM] (γ : GL2CentralExt P eP eM) (x : DetStarTotal P eP eM) :
    (γ • x).1 = centralProj P eP eM γ • x.1 :=
  QuotientGroup.induction_on γ fun _ => rfl

/-- **Theorem 4.6 (Weight-`+1` Central Scalar Action):**
Every central scalar `ι(c)` (`c ∈ ℂˣ`) fixes each fiber `Det*(W)` and acts on it by
multiplication by `c`. -/
theorem centralIncl_smul_detStar (P : PolarizedHilbertSpace ℂ H)
    (eP : HilbertBasis ιP ℂ P.HPlus) (eM : HilbertBasis ιM ℂ P.HMinus)
    [FredholmDetTheory P eP eM] [Nonempty ιP]
    (c : ℂˣ) (W : Gr2Sato0 P eP eM) (v : DetStar P eP eM W) :
    centralIncl P eP eM c • (⟨W, v⟩ : DetStarTotal P eP eM) = ⟨W, (c : ℂ) • v⟩ := by
  let i₀ : ιP := Classical.arbitrary ιP
  let t := rankOneTraceClassEquiv P eP eM i₀ c
  let p := preCentralOfTraceClass P eP eM t
  refine Quotient.inductionOn v fun pair => ?_
  have hW : p.1.1 • W = W := one_smul _ W
  have hw_rel : ∀ (W' : Gr2Sato0 P eP eM) (hW' : W' = W) (w' : AdmissibleFrame P eP eM W'),
      (∀ u : P.HPlus, (w'.1 u : H) = (pair.1.1 (t.1.symm u) : H)) →
      (⟨W', Quotient.mk (detStarSetoid P eP eM W') (w', pair.2)⟩ : DetStarTotal P eP eM) =
      ⟨W, Quotient.mk (detStarSetoid P eP eM W) (pair.1, (c : ℂ) * pair.2)⟩ := by
    intro W' hW' w' hw'_val
    subst hW'
    congr 1
    refine Quotient.sound ?_
    change (c : ℂ) * pair.2 = (detFrUnits P eP eM (frameTransition w' pair.1) : ℂ) * pair.2
    have htr : frameTransition w' pair.1 = t := by
      apply Subtype.ext; apply DFunLike.ext; intro u
      change w'.1.symm (pair.1.1 u) = t.1 u
      apply w'.1.injective
      rw [w'.1.apply_symm_apply]
      apply Subtype.ext
      rw [hw'_val (t.1 u), t.1.symm_apply_apply]
    rw [htr, detFrUnits_rankOne]
  exact hw_rel (p.1.1 • W) hW (preCentralActFrame p pair.1) (fun _ => rfl)

/-! ### Section 5: Segal–Wilson `τ`-Function on the Big Cell -/

/-- Graph subspace `Γ(T) ∈ Gr_(2)⁰(H)` for any Hilbert–Schmidt operator `T : H₊ →L[ℂ] H₋`. -/
noncomputable def graphGr2Sato0 (P : PolarizedHilbertSpace ℂ H)
    (eP : HilbertBasis ιP ℂ P.HPlus) (eM : HilbertBasis ιM ℂ P.HMinus)
    (T : P.HPlus →L[ℂ] P.HMinus) (hT : IsHS eP T) : Gr2Sato0 P eP eM :=
  ⟨graphSubspace P T, by
    have hClosed := graphSubspace_isClosed P T
    have : CompleteSpace (graphSubspace P T) := hClosed.completeSpace_coe
    have hFactor : projMinus P (graphSubspace P T) =
        T.comp (graphProjPlusEquiv P T : graphSubspace P T →L[ℂ] P.HPlus) := by
      apply ContinuousLinearMap.ext; rintro ⟨w, ⟨x, rfl⟩⟩
      simp [projMinus, projMinus_graphMap, graphProjPlusEquiv, projPlus, projPlus_graphMap]
    have hAdjHS : IsHS eM (ContinuousLinearMap.adjoint (projMinus P (graphSubspace P T))) := by
      rw [hFactor, ContinuousLinearMap.adjoint_comp]
      exact (hT.adjoint (eF := eM)).comp_left _
    exact ⟨hClosed, isFredholm_of_equiv (graphProjPlusEquiv P T),
      fredholmIndex_of_equiv (graphProjPlusEquiv P T), inferInstance, hAdjHS⟩⟩

/-- Canonical big-cell frame `w_T : H₊ ≃L[ℂ] Γ(T)` with `p₊ ∘ w_T = id`. -/
noncomputable def graphAdmissibleFrame (P : PolarizedHilbertSpace ℂ H)
    (eP : HilbertBasis ιP ℂ P.HPlus) (eM : HilbertBasis ιM ℂ P.HMinus)
    (T : P.HPlus →L[ℂ] P.HMinus) (hT : IsHS eP T) :
    AdmissibleFrame P eP eM (graphGr2Sato0 P eP eM T hT) :=
  ⟨(graphProjPlusEquiv P T).symm, by
    have hid : (projPlus P (graphSubspace P T)).comp
        ((graphProjPlusEquiv P T).symm : P.HPlus →L[ℂ] graphSubspace P T) =
        ContinuousLinearMap.id ℂ P.HPlus := by
      apply ContinuousLinearMap.ext; intro x
      exact (graphProjPlusEquiv P T).apply_symm_apply x
    change (projPlus P (graphSubspace P T)).comp
      ((graphProjPlusEquiv P T).symm : P.HPlus →L[ℂ] graphSubspace P T) -
      ContinuousLinearMap.id ℂ P.HPlus ∈ TraceClassIdeal P eP eM
    rw [hid, sub_self]
    exact Submodule.zero_mem _⟩

/-- **Theorem 5.1 (Segal–Wilson `τ`-Function Identity on the Big Cell):**
Let `T : H₊ →L[ℂ] H₋` be Hilbert–Schmidt (`Γ(T) ∈ Gr_(2)⁰(H)`), and let `g ∈ GL_(2)⁰(H)`
have invertible `g₊₊ = q` (as holds for the entire KP flow `Γ₊`), with canonical lift
`g̃ = [(g, q)] ∈ GL̂_(2)⁰(H)`. Then `1 + g₊₋ T g₊₊⁻¹ ∈ 1 + ℐ₁(H₊)` and the canonical
Pressley–Segal section obeys
`σ(g • Γ(T)) = det_Fr(1 + g₊₋ T g₊₊⁻¹) · (g̃ • σ(Γ(T)))`. -/
theorem segalWilson_tau_bigCell (P : PolarizedHilbertSpace ℂ H)
    (eP : HilbertBasis ιP ℂ P.HPlus) (eM : HilbertBasis ιM ℂ P.HMinus)
    [FredholmDetTheory P eP eM]
    (T : P.HPlus →L[ℂ] P.HMinus) (hT : IsHS eP T)
    (g : GL2Res0 P eP eM) (q : P.HPlus ≃L[ℂ] P.HPlus)
    (hq : (q : P.HPlus →L[ℂ] P.HPlus) = blockPP P (g.1.1 : H →L[ℂ] H)) :
    let W := graphGr2Sato0 P eP eM T hT
    have hPre : (g, q) ∈ PreCentralExt P eP eM := by
      change (blockPP P (g.1.1 : H →L[ℂ] H)).comp (q.symm : P.HPlus →L[ℂ] P.HPlus) -
        ContinuousLinearMap.id ℂ P.HPlus ∈ TraceClassIdeal P eP eM
      rw [← hq]
      have hid : (q : P.HPlus →L[ℂ] P.HPlus).comp (q.symm : P.HPlus →L[ℂ] P.HPlus) =
          ContinuousLinearMap.id ℂ P.HPlus := by ext x; simp
      rw [hid, sub_self]; exact Submodule.zero_mem _
    have hTauMem : ContinuousLinearMap.id ℂ P.HPlus +
        ((blockPM P (g.1.1 : H →L[ℂ] H)).comp T).comp (q.symm : P.HPlus →L[ℂ] P.HPlus) ∈
        TraceClassMonoid P eP eM := by
      change (ContinuousLinearMap.id ℂ P.HPlus +
        ((blockPM P (g.1.1 : H →L[ℂ] H)).comp T).comp (q.symm : P.HPlus →L[ℂ] P.HPlus)) -
        ContinuousLinearMap.id ℂ P.HPlus ∈ TraceClassIdeal P eP eM
      rw [add_sub_cancel_left]
      exact TraceClassIdeal.comp_right (TraceClassIdeal.of_hs_cross g.1.2.1 hT) _
    let gLift : GL2CentralExt P eP eM := QuotientGroup.mk ⟨(g, q), hPre⟩
    let τVal : ℂ := FredholmDetTheory.detFr ⟨_, hTauMem⟩
    (⟨g • W, canonicalSection P eP eM (g • W)⟩ : DetStarTotal P eP eM) =
      ⟨g • W, τVal • (gLift • (⟨W, canonicalSection P eP eM W⟩ : DetStarTotal P eP eM)).2⟩ := by
  intro W hPre hTauMem gLift τVal
  let wT := graphAdmissibleFrame P eP eM T hT
  let p : PreCentralExt P eP eM := ⟨(g, q), hPre⟩
  let w' := preCentralActFrame p wT
  have hSigW : canonicalSection P eP eM W =
      Quotient.mk (detStarSetoid P eP eM W) (wT, 1) := by
    rw [canonicalSection_eq P eP eM wT]
    have hid : (⟨(projPlus P W.1).comp (wT.1 : P.HPlus →L[ℂ] W.1), wT.2⟩ : TraceClassMonoid P eP eM) = 1 := by
      apply Subtype.ext; apply ContinuousLinearMap.ext; intro x
      exact (graphProjPlusEquiv P T).apply_symm_apply x
    rw [hid, map_one]
  have hComp : (⟨(projPlus P (g • W).1).comp (w'.1 : P.HPlus →L[ℂ] (g • W).1), w'.2⟩ :
      TraceClassMonoid P eP eM) = ⟨_, hTauMem⟩ := by
    apply Subtype.ext; apply ContinuousLinearMap.ext; intro x
    have hint := congrArg (fun L : W.1 →L[ℂ] P.HPlus => L (wT.1 (q.symm x)))
      (projPlus_restrictEquiv P g.1.1 W.1)
    have hp1 : projPlus P W.1 (wT.1 (q.symm x)) = q.symm x :=
      (graphProjPlusEquiv P T).apply_symm_apply (q.symm x)
    have hp2 : projMinus P W.1 (wT.1 (q.symm x)) = T (q.symm x) := by
      change projMinus P (graphSubspace P T) ⟨graphMap P T (q.symm x), ⟨q.symm x, rfl⟩⟩ = _
      exact projMinus_graphMap P T (q.symm x)
    have hq_inv : blockPP P (g.1.1 : H →L[ℂ] H) (q.symm x) = x := by
      rw [← hq]; exact q.apply_symm_apply x
    change projPlus P (W.1.map (g.1.1 : H →ₗ[ℂ] H)) (restrictEquiv g.1.1 W.1 (wT.1 (q.symm x))) =
      x + blockPM P (g.1.1 : H →L[ℂ] H) (T (q.symm x))
    change projPlus P (W.1.map (g.1.1 : H →ₗ[ℂ] H)) (restrictEquiv g.1.1 W.1 (wT.1 (q.symm x))) =
      blockPP P (g.1.1 : H →L[ℂ] H) (projPlus P W.1 (wT.1 (q.symm x))) +
      blockPM P (g.1.1 : H →L[ℂ] H) (projMinus P W.1 (wT.1 (q.symm x))) at hint
    rw [hint, hp1, hp2, hq_inv]
  congr 1
  rw [canonicalSection_eq P eP eM w', hComp, hSigW]
  change Quotient.mk (detStarSetoid P eP eM (g • W)) (w', τVal) =
    Quotient.mk (detStarSetoid P eP eM (g • W)) (w', τVal * 1)
  rw [mul_one]

end EquivariantActionAndTau

/-! ============================================================================
## Section 6: Axiom-Free Finite-Dimensional `FredholmDetTheory` Instance
============================================================================ -/

section FiniteDimensionalFredholmDet

variable {ιP ιM : Type*} {H : Type*}
  [NormedAddCommGroup H] [InnerProductSpace ℂ H] [CompleteSpace H]

/-- **Constructive Axiom-Free `FredholmDetTheory` Instance on Finite-Dimensional Subspaces:**
Whenever `P.HPlus` is finite-dimensional (covering all finite-rank Fourier/mode truncations
of `L²(S¹)`), Mathlib's `LinearMap.det` discharges all four axioms of `FredholmDetTheory`
(`detFr` monoid homomorphism, conjugation invariance, `rankOneScale` normalization, and
non-vanishing iff bijectivity) with zero `sorry` and zero extra axioms. -/
noncomputable instance instFredholmDetTheoryOfFiniteDimensional
    (P : PolarizedHilbertSpace ℂ H)
    (eP : HilbertBasis ιP ℂ P.HPlus) (eM : HilbertBasis ιM ℂ P.HMinus)
    [FiniteDimensional ℂ P.HPlus] :
    FredholmDetTheory P eP eM where
  detFr :=
    { toFun := fun A => LinearMap.det A.1.toLinearMap
      map_one' := (LinearMap.det : (P.HPlus →ₗ[ℂ] P.HPlus) →* ℂ).map_one
      map_mul' := fun A B => LinearMap.det_comp A.1.toLinearMap B.1.toLinearMap }
  detFr_conj := fun q A => by
    change LinearMap.det
      (q.toLinearEquiv.toLinearMap ∘ₗ A.1.toLinearMap ∘ₗ q.toLinearEquiv.symm.toLinearMap) =
      LinearMap.det A.1.toLinearMap
    exact LinearMap.det_conj A.1.toLinearMap q.toLinearEquiv
  detFr_rankOne := fun i₀ c => by
    classical
    let S : Submodule ℂ P.HPlus := Submodule.span ℂ ({eP i₀} : Set P.HPlus)
    have hne : eP i₀ ≠ 0 := by
      intro h0
      have hn : ‖eP i₀‖ = 1 := eP.orthonormal.1 i₀
      rw [h0, norm_zero] at hn; norm_num at hn
    let v₀ : S := ⟨eP i₀, Submodule.subset_span rfl⟩
    let bS : Module.Basis (Fin 1) ℂ S :=
      Module.Basis.mk (v := fun _ : Fin 1 => v₀)
        (by
          rw [linearIndependent_unique_iff]
          intro h0
          exact hne (congrArg Subtype.val h0))
        (by
          intro ⟨y, hy⟩ _
          rw [Set.range_const, Submodule.mem_span_singleton]
          rw [Submodule.mem_span_singleton] at hy
          obtain ⟨k, hk⟩ := hy
          exact ⟨k, Subtype.ext hk⟩)
    let bP : Module.Basis (Fin (Module.finrank ℂ Sᗮ)) ℂ Sᗮ := Module.finBasis ℂ Sᗮ
    let eqv : (S × Sᗮ) ≃ₗ[ℂ] P.HPlus :=
      Submodule.prodEquivOfIsCompl S Sᗮ S.isCompl_orthogonal
    let b : Module.Basis (Fin 1 ⊕ Fin (Module.finrank ℂ Sᗮ)) ℂ P.HPlus :=
      (bS.prod bP).map eqv
    let R := rankOneScale P eP i₀ c
    have hself : ⟪eP i₀, eP i₀⟫_ℂ = 1 := by
      rw [inner_self_eq_norm_sq_to_K, eP.orthonormal.1 i₀]; norm_num
    have hRS : R (eP i₀) = c • eP i₀ := by
      simp only [R, rankOneScale, add_apply, ContinuousLinearMap.id_apply, smul_apply,
        ContinuousLinearMap.smulRight_apply, innerSL_apply_apply, hself]
      module
    have hRP : ∀ y : Sᗮ, R (y : P.HPlus) = (y : P.HPlus) := by
      intro y
      have horth : ⟪eP i₀, (y : P.HPlus)⟫_ℂ = 0 :=
        y.2 (eP i₀) (Submodule.subset_span rfl)
      simp [R, rankOneScale, horth]
    have hb_inl : b (Sum.inl 0) = eP i₀ := by
      have heqv : ∀ x : S × Sᗮ, eqv x = (S.subtype.coprod Sᗮ.subtype) x := fun x =>
        congrArg (fun f : S × Sᗮ →ₗ[ℂ] P.HPlus => f x)
          (Submodule.coe_prodEquivOfIsCompl S Sᗮ S.isCompl_orthogonal)
      simp only [b, Module.Basis.map_apply, Module.Basis.prod_apply, LinearMap.coe_inl,
        Sum.elim_inl, Function.comp_apply, bS, Module.Basis.mk_apply, heqv,
        LinearMap.coprod_apply, Submodule.coe_subtype, Submodule.coe_zero, add_zero, v₀]
    have hb_inr : ∀ j, b (Sum.inr j) = (bP j : P.HPlus) := by
      intro j
      have heqv : ∀ x : S × Sᗮ, eqv x = (S.subtype.coprod Sᗮ.subtype) x := fun x =>
        congrArg (fun f : S × Sᗮ →ₗ[ℂ] P.HPlus => f x)
          (Submodule.coe_prodEquivOfIsCompl S Sᗮ S.isCompl_orthogonal)
      simp only [b, Module.Basis.map_apply, Module.Basis.prod_apply, LinearMap.coe_inr,
        Sum.elim_inr, Function.comp_apply, heqv, LinearMap.coprod_apply, Submodule.coe_subtype,
        Submodule.coe_zero, zero_add]
    have hMat : LinearMap.toMatrix b b R.toLinearMap =
        Matrix.diagonal (Sum.elim (fun _ => c) (fun _ => 1)) := by
      ext i j
      rw [LinearMap.toMatrix_apply, Matrix.diagonal_apply]
      rcases j with j | j
      · have hj0 : j = 0 := Fin.eq_zero j
        subst hj0
        change (b.repr (R (b (Sum.inl 0)))) i = _
        rw [hb_inl, hRS, ← hb_inl, map_smul, b.repr_self]
        rcases i with i | i
        · have hi0 : i = 0 := Fin.eq_zero i
          subst hi0; simp
        · simp
      · change (b.repr (R (b (Sum.inr j)))) i = _
        rw [hb_inr j, hRP (bP j), ← hb_inr j, b.repr_self]
        rcases i with i | i
        · simp
        · by_cases hij : i = j
          · subst hij; simp
          · simp [hij]
    change LinearMap.det R.toLinearMap = c
    rw [← LinearMap.det_toMatrix b R.toLinearMap, hMat, Matrix.det_diagonal]
    simp
  detFr_ne_zero_iff := fun A => by
    classical
    let b := Module.finBasis ℂ P.HPlus
    let E := LinearMap.toMatrixAlgEquiv b
    change LinearMap.det A.1.toLinearMap ≠ 0 ↔ Function.Bijective A.1
    rw [← LinearMap.det_toMatrix b A.1.toLinearMap]
    have h1 : (LinearMap.toMatrix b b A.1.toLinearMap).det ≠ 0 ↔
        IsUnit (LinearMap.toMatrix b b A.1.toLinearMap).det := isUnit_iff_ne_zero.symm
    rw [h1, ← Matrix.isUnit_iff_isUnit_det]
    have hE : IsUnit (E A.1.toLinearMap) ↔ IsUnit A.1.toLinearMap :=
      MulEquiv.isUnit_map E
    change IsUnit (E A.1.toLinearMap) ↔ Function.Bijective A.1
    rw [hE, LinearMap.isUnit_iff_ker_eq_bot, LinearMap.ker_eq_bot]
    exact ⟨fun h => ⟨h, (LinearMap.injective_iff_surjective_of_finrank_eq_finrank rfl).mp h⟩,
      fun h => h.1⟩

end FiniteDimensionalFredholmDet

end Signals.SatoGrassmannian.DeterminantBundle
