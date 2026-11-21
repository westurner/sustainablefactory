import Mathlib.Analysis.Normed.Module.HahnBanach
import Mathlib.Analysis.Normed.Module.RieszLemma
import Mathlib.Analysis.Normed.Module.FiniteDimension
import Mathlib.Analysis.Normed.Operator.Banach
import Mathlib.Analysis.Normed.Operator.Compact.Basic
import Mathlib.LinearAlgebra.Dimension.Finrank
import Signals.SatoGrassmannian.Base

namespace Signals.SatoGrassmannian

universe u

section BanachHelpers

variable {𝕜 : Type*} [RCLike 𝕜]
variable {E F : Type u}
  [NormedAddCommGroup E] [NormedSpace 𝕜 E]
  [NormedAddCommGroup F] [NormedSpace 𝕜 F]

/-- Every continuous linear map with finite-dimensional range is compact. -/
theorem isCompactOperator_of_finiteDimensional_range (T : E →L[𝕜] F)
    [FiniteDimensional 𝕜 (LinearMap.range T.toLinearMap)] :
    IsCompactOperator (T : E → F) := by
  have : ProperSpace (LinearMap.range T.toLinearMap) := FiniteDimensional.proper 𝕜 _
  let B : Set (LinearMap.range T.toLinearMap) := Metric.closedBall 0 ‖T‖
  have hB : IsCompact B := isCompact_closedBall 0 ‖T‖
  have hImgCompact : IsCompact ((Subtype.val : LinearMap.range T.toLinearMap → F) '' B) :=
    hB.image continuous_subtype_val
  refine ⟨(Subtype.val : LinearMap.range T.toLinearMap → F) '' B, hImgCompact, ?_⟩
  refine Filter.mem_of_superset (Metric.closedBall_mem_nhds 0 zero_lt_one) ?_
  intro x hx
  refine ⟨⟨T x, ⟨x, rfl⟩⟩, ?_, rfl⟩
  rw [Metric.mem_closedBall, dist_zero_right] at hx ⊢
  calc ‖(⟨T x, ⟨x, rfl⟩⟩ : LinearMap.range T.toLinearMap)‖
      = ‖T x‖ := rfl
    _ ≤ ‖T‖ * ‖x‖ := T.le_opNorm x
    _ ≤ ‖T‖ * 1 := mul_le_mul_of_nonneg_left hx (norm_nonneg T)
    _ = ‖T‖ := mul_one _

/-- **Hahn–Banach Finite-Dimensional Splitting:** Every finite-dimensional subspace `V ≤ E`
admits a continuous idempotent projection `P_proj : E →L[𝕜] E` with `range P_proj = V` and closed
complement `ker P_proj`. -/
theorem exists_closed_compl_of_finiteDimensional (V : Submodule 𝕜 E)
    [FiniteDimensional 𝕜 V] :
    ∃ (P_proj : E →L[𝕜] E),
      (∀ v : V, P_proj (v : E) = (v : E)) ∧
      LinearMap.range P_proj.toLinearMap = V ∧
      IsClosed (LinearMap.ker P_proj.toLinearMap : Set E) ∧
      IsCompl V (LinearMap.ker P_proj.toLinearMap) := by
  let b := Module.finBasis 𝕜 V
  have hex : ∀ i, ∃ ψ : E →L[𝕜] 𝕜, ∀ v : V, ψ (v : E) = b.coord i v := by
    intro i
    let φ : V →L[𝕜] 𝕜 := (b.coord i).toContinuousLinearMap
    obtain ⟨ψ, hψ, _⟩ := exists_extension_norm_eq V φ
    exact ⟨ψ, fun v => hψ v⟩
  choose ψ hψ using hex
  let P_proj : E →L[𝕜] E := ∑ i, (ψ i).smulRight (b i : E)
  have hP_fix : ∀ v : V, P_proj (v : E) = (v : E) := by
    intro v
    have hsum : P_proj (v : E) = ∑ i, (b.coord i v) • (b i : E) := by
      simp [P_proj, hψ]
    rw [hsum]
    exact_mod_cast b.sum_repr v
  have hP_mem : ∀ x : E, P_proj x ∈ V := by
    intro x
    simp only [P_proj, sum_apply, ContinuousLinearMap.smulRight_apply]
    exact Submodule.sum_mem V fun i _ => V.smul_mem _ (b i).2
  have hRange : LinearMap.range P_proj.toLinearMap = V := by
    apply le_antisymm
    · rintro _ ⟨x, rfl⟩; exact hP_mem x
    · intro v hv; exact ⟨v, hP_fix ⟨v, hv⟩⟩
  have hClosed : IsClosed (LinearMap.ker P_proj.toLinearMap : Set E) :=
    isClosed_singleton.preimage P_proj.continuous
  have hCompl : IsCompl V (LinearMap.ker P_proj.toLinearMap) := by
    rw [isCompl_iff, disjoint_iff, codisjoint_iff]
    constructor
    · rw [Submodule.eq_bot_iff]
      intro x ⟨hxV, hxK⟩
      have hfix : P_proj x = x := hP_fix ⟨x, hxV⟩
      have hx0 : P_proj x = 0 := hxK
      rw [hx0] at hfix
      exact hfix.symm
    · rw [Submodule.eq_top_iff']
      intro x
      have hsub : x - P_proj x ∈ LinearMap.ker P_proj.toLinearMap := by
        change P_proj (x - P_proj x) = 0
        rw [map_sub, hP_fix ⟨P_proj x, hP_mem x⟩, sub_self]
      have hx : x = P_proj x + (x - P_proj x) := (add_sub_cancel _ _).symm
      rw [hx]
      exact Submodule.add_mem_sup (hP_mem x) hsub
  exact ⟨P_proj, hP_fix, hRange, hClosed, hCompl⟩

/-- Sequential compactness under a compact operator: every bounded sequence `(u n)`
has a subsequence `(u (φ n))` whose image `(K (u (φ n)))` converges. -/
lemma isCompactOperator_exists_tendsto_subseq {K : E →L[𝕜] F}
    (hK : IsCompactOperator (K : E → F)) {u : ℕ → E} {M : ℝ} (hM : 0 < M)
    (hu : ∀ n, ‖u n‖ ≤ M) :
    ∃ (y : F) (φ : ℕ → ℕ), StrictMono φ ∧ Filter.Tendsto (fun n => K (u (φ n))) Filter.atTop (nhds y) := by
  rcases hK with ⟨s, hs_comp, hpre⟩
  obtain ⟨r, hr, hrs⟩ := Metric.mem_nhds_iff.mp hpre
  have hr' : 0 < r / 2 := half_pos hr
  let c : ℝ := (r / 2) / M
  have hc : 0 < c := div_pos hr' hM
  let c𝕜 : 𝕜 := (c : 𝕜)
  have hc𝕜_ne : c𝕜 ≠ 0 := by dsimp [c𝕜]; exact_mod_cast hc.ne'
  have hmem : ∀ n, K (c𝕜 • u n) ∈ s := by
    intro n
    apply hrs
    rw [Metric.mem_ball, dist_zero_right, norm_smul, RCLike.norm_ofReal, abs_of_pos hc]
    calc c * ‖u n‖ ≤ ((r / 2) / M) * M := mul_le_mul_of_nonneg_left (hu n) hc.le
      _ = r / 2 := div_mul_cancel₀ _ hM.ne'
      _ < r := half_lt_self hr
  obtain ⟨z, _, φ, hφ, htend⟩ := hs_comp.tendsto_subseq hmem
  refine ⟨c𝕜⁻¹ • z, φ, hφ, ?_⟩
  have hscaled := htend.const_smul c𝕜⁻¹
  refine hscaled.congr fun n => ?_
  dsimp only [Function.comp_apply]
  rw [map_smul, inv_smul_smul₀ hc𝕜_ne]

/-- If `K : E →L[𝕜] E` is compact, then `(id + K)^n - id` is compact for every `n : ℕ`. -/
lemma isCompactOperator_pow_sub_one {K : E →L[𝕜] E}
    (hK : IsCompactOperator (K : E → E)) (n : ℕ) :
    IsCompactOperator ((((1 + K) ^ n - 1 : E →L[𝕜] E) : E → E)) := by
  induction n with
  | zero =>
    simp [isCompactOperator_zero]
  | succ n ih =>
    have hsplit : (1 + K) ^ (n + 1) - 1 = (1 + K) * ((1 + K) ^ n - 1) + K := by
      rw [pow_succ']
      noncomm_ring
    rw [hsplit]
    exact (ih.clm_comp (1 + K)).add hK

end BanachHelpers

/-! ## Lemma 1: Riesz–Schauder Theorem for `id + K` -/

section RieszSchauder

variable {𝕜 : Type*} [RCLike 𝕜]
variable {E : Type u} [NormedAddCommGroup E] [NormedSpace 𝕜 E] [CompleteSpace E]

omit [CompleteSpace E] in
/-- Step 1.1: `ker(id + K)` is finite-dimensional. -/
theorem finiteDimensional_ker_id_add_compact {K : E →L[𝕜] E}
    (hK : IsCompactOperator (K : E → E)) :
    FiniteDimensional 𝕜 (LinearMap.ker ((1 : E →L[𝕜] E) + K).toLinearMap) := by
  let V := LinearMap.ker ((1 : E →L[𝕜] E) + K).toLinearMap
  have hVclosed : IsClosed (V : Set E) := isClosed_singleton.preimage ((1 : E →L[𝕜] E) + K).continuous
  rcases hK with ⟨s, hs_comp, hpre⟩
  obtain ⟨r, hr, hrs⟩ := Metric.mem_nhds_iff.mp hpre
  have hr2 : 0 < r / 2 := half_pos hr
  have hball_compact : IsCompact (Metric.closedBall (0 : V) (r / 2)) := by
    have himg : (Subtype.val : V → E) '' Metric.closedBall (0 : V) (r / 2) ⊆
        (fun y => -y) '' s := by
      rintro _ ⟨⟨x, hxV⟩, hxB, rfl⟩
      have hKx : K x = -x := by
        have h0 : x + K x = 0 := hxV
        exact eq_neg_of_add_eq_zero_right h0
      refine ⟨K x, hrs ?_, by dsimp; rw [hKx, neg_neg]⟩
      rw [Metric.mem_closedBall, dist_zero_right] at hxB
      rw [Metric.mem_ball, dist_zero_right]
      exact lt_of_le_of_lt hxB (half_lt_self hr)
    have hclosed_img : IsClosed ((Subtype.val : V → E) '' Metric.closedBall (0 : V) (r / 2)) := by
      have heq : (Subtype.val : V → E) '' Metric.closedBall (0 : V) (r / 2) =
          (V : Set E) ∩ Metric.closedBall (0 : E) (r / 2) := by
        ext x; constructor
        · rintro ⟨⟨y, hy⟩, hyB, rfl⟩; exact ⟨hy, hyB⟩
        · rintro ⟨hxV, hxB⟩; exact ⟨⟨x, hxV⟩, hxB, rfl⟩
      rw [heq]
      exact hVclosed.inter Metric.isClosed_closedBall
    have hcomp_img : IsCompact ((Subtype.val : V → E) '' Metric.closedBall (0 : V) (r / 2)) :=
      (hs_comp.image continuous_neg).of_isClosed_subset hclosed_img himg
    exact Topology.IsInducing.subtypeVal.isCompact_iff.mpr hcomp_img
  exact FiniteDimensional.of_isCompact_closedBall 𝕜 hr2 hball_compact

/-- Step 1.2: `range(id + K)` is closed in a Banach space. -/
theorem isClosed_range_id_add_compact {K : E →L[𝕜] E}
    (hK : IsCompactOperator (K : E → E)) :
    IsClosed (LinearMap.range ((1 : E →L[𝕜] E) + K).toLinearMap : Set E) := by
  let A : E →L[𝕜] E := 1 + K
  let V := LinearMap.ker A.toLinearMap
  have : FiniteDimensional 𝕜 V := finiteDimensional_ker_id_add_compact hK
  obtain ⟨P_proj, _, _, hWclosed, hCompl⟩ := exists_closed_compl_of_finiteDimensional V
  let W := LinearMap.ker P_proj.toLinearMap
  have hBoundBelow : ∃ c : ℝ, 0 < c ∧ ∀ w : E, w ∈ W → c * ‖w‖ ≤ ‖A w‖ := by
    by_contra hno
    push Not at hno
    have hex : ∀ n : ℕ, ∃ w : E, w ∈ W ∧ ‖w‖ = 1 ∧ ‖A w‖ < (1 : ℝ) / (n + 1) := by
      intro n
      have hpos : (0 : ℝ) < 1 / (n + 1 : ℝ) := by positivity
      obtain ⟨w, hwW, hlt⟩ := hno (1 / (n + 1 : ℝ)) hpos
      have hw0 : w ≠ 0 := by
        intro h0; subst h0; simp at hlt
      have hnorm_pos : 0 < ‖w‖ := norm_pos_iff.mpr hw0
      let u := ((‖w‖⁻¹ : ℝ) : 𝕜) • w
      refine ⟨u, W.smul_mem _ hwW, ?_, ?_⟩
      · rw [norm_smul, RCLike.norm_ofReal, abs_of_pos (inv_pos.mpr hnorm_pos),
          inv_mul_cancel₀ hnorm_pos.ne']
      · rw [map_smul, norm_smul, RCLike.norm_ofReal, abs_of_pos (inv_pos.mpr hnorm_pos)]
        calc ‖w‖⁻¹ * ‖A w‖ < ‖w‖⁻¹ * (1 / (n + 1 : ℝ) * ‖w‖) :=
              mul_lt_mul_of_pos_left hlt (inv_pos.mpr hnorm_pos)
          _ = 1 / (n + 1 : ℝ) := by field_simp [hnorm_pos.ne']
    choose w hwW hwnorm hwA using hex
    obtain ⟨y, φ, hφ, hKtend⟩ :=
      isCompactOperator_exists_tendsto_subseq hK zero_lt_one (fun n => (hwnorm n).le)
    have hAtend : Filter.Tendsto (fun n => A (w (φ n))) Filter.atTop (nhds 0) := by
      rw [tendsto_zero_iff_norm_tendsto_zero]
      refine squeeze_zero (fun _ => norm_nonneg _) (fun n => (hwA (φ n)).le) ?_
      exact tendsto_one_div_add_atTop_nhds_zero_nat.comp hφ.tendsto_atTop
    have hwtend : Filter.Tendsto (fun n => w (φ n)) Filter.atTop (nhds (-y)) := by
      have hsub := hAtend.sub hKtend
      rw [zero_sub] at hsub
      exact hsub.congr fun n => by simp [A]
    have hyW : -y ∈ W := hWclosed.mem_of_tendsto hwtend (Filter.Eventually.of_forall fun n => hwW (φ n))
    have hynorm : ‖-y‖ = 1 := by
      have hnt := hwtend.norm
      have hconst : (fun n => ‖w (φ n)‖) = fun _ => (1 : ℝ) := funext fun n => hwnorm (φ n)
      rw [hconst] at hnt
      exact tendsto_nhds_unique hnt tendsto_const_nhds
    have hyV : -y ∈ V := by
      have hAcont := (A.continuous.tendsto (-y)).comp hwtend
      exact tendsto_nhds_unique hAcont hAtend
    have hy0 : -y = 0 := by
      have hmem : -y ∈ V ⊓ W := ⟨hyV, hyW⟩
      rwa [hCompl.inf_eq_bot, Submodule.mem_bot] at hmem
    rw [hy0, norm_zero] at hynorm
    norm_num at hynorm
  obtain ⟨c, hc, hcb⟩ := hBoundBelow
  have hrange_eq : (LinearMap.range A.toLinearMap : Set E) = A '' (W : Set E) := by
    ext y; constructor
    · rintro ⟨x, rfl⟩
      have hx : x ∈ V ⊔ W := by rw [hCompl.sup_eq_top]; trivial
      obtain ⟨v, hv, w, hw, rfl⟩ := Submodule.mem_sup.mp hx
      refine ⟨w, hw, ?_⟩
      have hv0 : A v = 0 := hv
      change A w = A (v + w)
      rw [map_add, hv0, zero_add]
    · rintro ⟨w, _, rfl⟩; exact ⟨w, rfl⟩
  rw [hrange_eq]
  refine IsComplete.isClosed ?_
  rw [← completeSpace_coe_iff_isComplete]
  refine Metric.complete_of_cauchySeq_tendsto fun u hu_cauchy => ?_
  have hu_mem : ∀ n, ∃ w ∈ W, A w = (u n).1 := fun n => (u n).2
  choose w hwW hAw using hu_mem
  have hw_cauchy : CauchySeq w := by
    rw [Metric.cauchySeq_iff] at hu_cauchy ⊢
    intro ε hε
    obtain ⟨N, hN⟩ := hu_cauchy (c * ε) (mul_pos hc hε)
    refine ⟨N, fun m hm n hn => ?_⟩
    have hdiff := hcb (w m - w n) (W.sub_mem (hwW m) (hwW n))
    have hdist_u : dist (u m) (u n) = ‖A (w m - w n)‖ := by
      rw [map_sub, hAw m, hAw n, Subtype.dist_eq, dist_eq_norm]
    rw [dist_eq_norm]
    have hlt := hN m hm n hn
    rw [hdist_u] at hlt
    nlinarith
  obtain ⟨w₀, hw₀_tend⟩ := cauchySeq_tendsto_of_complete hw_cauchy
  have hw₀W : w₀ ∈ W := hWclosed.mem_of_tendsto hw₀_tend (Filter.Eventually.of_forall hwW)
  refine ⟨⟨A w₀, ⟨w₀, hw₀W, rfl⟩⟩, ?_⟩
  rw [tendsto_subtype_rng]
  exact ((A.continuous.tendsto w₀).comp hw₀_tend).congr fun n => hAw n

/-- Normalized Riesz lemma: given a proper closed subspace `F ≤ X`, there exists a unit vector
`v : X` (`‖v‖ = 1`) at distance `≥ 1/2` from every `y ∈ F`. -/
lemma riesz_unit_vector {X : Type*} [NormedAddCommGroup X] [NormedSpace 𝕜 X]
    {F : Submodule 𝕜 X} (hF : IsClosed (F : Set X)) (hproper : ∃ x : X, x ∉ F) :
    ∃ v : X, ‖v‖ ≤ 1 ∧ ∀ y ∈ F, (1 / 2 : ℝ) ≤ ‖v - y‖ := by
  obtain ⟨u, hu_not, hdist⟩ := riesz_lemma hF hproper (by norm_num : (1 / 2 : ℝ) < 1)
  have hu0 : u ≠ 0 := fun h0 => hu_not (h0 ▸ F.zero_mem)
  have hnorm_pos : 0 < ‖u‖ := norm_pos_iff.mpr hu0
  let v : X := ((‖u‖⁻¹ : ℝ) : 𝕜) • u
  refine ⟨v, ?_, fun y hy => ?_⟩
  · have hv1 : ‖v‖ = 1 := by
      dsimp [v]
      rw [norm_smul, RCLike.norm_ofReal, abs_of_pos (inv_pos.mpr hnorm_pos),
        inv_mul_cancel₀ hnorm_pos.ne']
    exact hv1.le
  · have hy_scaled : ((‖u‖ : ℝ) : 𝕜) • y ∈ F := F.smul_mem _ hy
    have hge := hdist (((‖u‖ : ℝ) : 𝕜) • y) hy_scaled
    have hsub : v - y = ((‖u‖⁻¹ : ℝ) : 𝕜) • (u - ((‖u‖ : ℝ) : 𝕜) • y) := by
      dsimp [v]
      rw [smul_sub, smul_smul]
      have hinv : ((‖u‖⁻¹ : ℝ) : 𝕜) * ((‖u‖ : ℝ) : 𝕜) = 1 := by
        exact_mod_cast inv_mul_cancel₀ hnorm_pos.ne'
      rw [hinv, one_smul]
    rw [hsub, norm_smul, RCLike.norm_ofReal, abs_of_pos (inv_pos.mpr hnorm_pos)]
    have hmul := mul_le_mul_of_nonneg_left hge (inv_pos.mpr hnorm_pos).le
    have hsimp : ‖u‖⁻¹ * (1 / 2 * ‖u‖) = (1 / 2 : ℝ) := by field_simp [hnorm_pos.ne']
    linarith

omit [CompleteSpace E] in
/-- Step 1.3a: Ascent stabilization `∃ p, ker(A^(p+1)) = ker(A^p)` via Riesz's lemma. -/
lemma ascent_stabilizes {K : E →L[𝕜] E} (hK : IsCompactOperator (K : E → E)) :
    ∃ p : ℕ, LinearMap.ker (((1 : E →L[𝕜] E) + K) ^ (p + 1)).toLinearMap =
      LinearMap.ker (((1 : E →L[𝕜] E) + K) ^ p).toLinearMap := by
  let A : E →L[𝕜] E := 1 + K
  by_contra hno
  push Not at hno
  have hstrict : ∀ n, ∃ x : E, x ∈ LinearMap.ker (A ^ (n + 1)).toLinearMap ∧
      x ∉ LinearMap.ker (A ^ n).toLinearMap := by
    intro n
    have hle : LinearMap.ker (A ^ n).toLinearMap ≤ LinearMap.ker (A ^ (n + 1)).toLinearMap := by
      intro x hx
      change (A ^ (n + 1)) x = 0
      have hx' : (A ^ n) x = 0 := hx
      rw [pow_succ', mul_apply_eq_comp, hx', map_zero]
    by_contra hnot
    push Not at hnot
    exact hno n (le_antisymm (fun x hx => hnot x hx) hle)
  have hseq : ∀ n, ∃ x : E, x ∈ LinearMap.ker (A ^ (n + 1)).toLinearMap ∧ ‖x‖ ≤ 1 ∧
      ∀ y ∈ LinearMap.ker (A ^ n).toLinearMap, (1 / 2 : ℝ) ≤ ‖x - y‖ := by
    intro n
    let Kn1 := LinearMap.ker (A ^ (n + 1)).toLinearMap
    let Fn : Submodule 𝕜 Kn1 := (LinearMap.ker (A ^ n).toLinearMap).comap Kn1.subtype
    have hFn_closed : IsClosed (Fn : Set Kn1) :=
      (isClosed_singleton.preimage (A ^ n).continuous).preimage continuous_subtype_val
    obtain ⟨x₀, hx₀1, hx₀0⟩ := hstrict n
    obtain ⟨u, hunorm, hdist⟩ := riesz_unit_vector (𝕜 := 𝕜) hFn_closed ⟨⟨x₀, hx₀1⟩, hx₀0⟩
    refine ⟨u.1, u.2, hunorm, fun y hy => ?_⟩
    have hy1 : y ∈ Kn1 := by
      change (A ^ (n + 1)) y = 0
      have hy' : (A ^ n) y = 0 := hy
      rw [pow_succ', mul_apply_eq_comp, hy', map_zero]
    exact hdist ⟨y, hy1⟩ hy
  choose x hxK hxnorm hxdist using hseq
  obtain ⟨y, φ, hφ, htend⟩ := isCompactOperator_exists_tendsto_subseq hK zero_lt_one hxnorm
  have hcauchy := htend.cauchySeq
  rw [Metric.cauchySeq_iff] at hcauchy
  obtain ⟨N, hN⟩ := hcauchy (1 / 2) (by norm_num)
  have hlt := hN (N + 1) (Nat.le_succ N) N le_rfl
  rw [dist_eq_norm] at hlt
  have hmn : φ N < φ (N + 1) := hφ (Nat.lt_succ_self N)
  have hmem_ker : A (x (φ (N + 1))) + x (φ N) - A (x (φ N)) ∈ LinearMap.ker (A ^ φ (N + 1)).toLinearMap := by
    have hpow_mono : ∀ {a b : ℕ}, a ≤ b → LinearMap.ker (A ^ a).toLinearMap ≤ LinearMap.ker (A ^ b).toLinearMap := by
      intro a b hab
      obtain ⟨d, rfl⟩ := Nat.exists_eq_add_of_le hab
      intro z hz
      change (A ^ (a + d)) z = 0
      have hz' : (A ^ a) z = 0 := hz
      rw [Nat.add_comm, pow_add, mul_apply_eq_comp, hz', map_zero]
    have h1 : A (x (φ (N + 1))) ∈ LinearMap.ker (A ^ φ (N + 1)).toLinearMap := by
      have hx : (A ^ (φ (N + 1) + 1)) (x (φ (N + 1))) = 0 := hxK (φ (N + 1))
      change (A ^ φ (N + 1)) (A (x (φ (N + 1)))) = 0
      rwa [pow_succ, mul_apply_eq_comp] at hx
    have h2 : x (φ N) ∈ LinearMap.ker (A ^ φ (N + 1)).toLinearMap :=
      hpow_mono (Nat.succ_le_of_lt hmn) (hxK (φ N))
    have h3 : A (x (φ N)) ∈ LinearMap.ker (A ^ φ (N + 1)).toLinearMap := by
      have hx : (A ^ (φ N + 1)) (x (φ N)) = 0 := hxK (φ N)
      rw [pow_succ, mul_apply_eq_comp] at hx
      exact hpow_mono hmn.le hx
    exact Submodule.sub_mem _ (Submodule.add_mem _ h1 h2) h3
  have hge := hxdist (φ (N + 1)) _ hmem_ker
  have hid : K (x (φ (N + 1))) - K (x (φ N)) =
      -(x (φ (N + 1)) - (A (x (φ (N + 1))) + x (φ N) - A (x (φ N)))) := by
    simp only [A, add_apply, one_apply_eq_self]
    abel
  rw [hid, norm_neg] at hlt
  linarith

/-- Step 1.3b: Descent stabilization `∃ q, range(A^(q+1)) = range(A^q)` via Riesz's lemma. -/
lemma descent_stabilizes {K : E →L[𝕜] E} (hK : IsCompactOperator (K : E → E)) :
    ∃ q : ℕ, LinearMap.range (((1 : E →L[𝕜] E) + K) ^ (q + 1)).toLinearMap =
      LinearMap.range (((1 : E →L[𝕜] E) + K) ^ q).toLinearMap := by
  let A : E →L[𝕜] E := 1 + K
  have hClosedRange : ∀ n, IsClosed (LinearMap.range (A ^ n).toLinearMap : Set E) := by
    intro n
    have heq : A ^ n = 1 + (A ^ n - 1) := by abel
    rw [heq]
    exact isClosed_range_id_add_compact (isCompactOperator_pow_sub_one hK n)
  by_contra hno
  push Not at hno
  have hstrict : ∀ n, ∃ x : E, x ∈ LinearMap.range (A ^ n).toLinearMap ∧
      x ∉ LinearMap.range (A ^ (n + 1)).toLinearMap := by
    intro n
    have hle : LinearMap.range (A ^ (n + 1)).toLinearMap ≤ LinearMap.range (A ^ n).toLinearMap := by
      rintro _ ⟨z, rfl⟩
      exact ⟨A z, by change (A ^ n) (A z) = (A ^ (n + 1)) z; rw [pow_succ, mul_apply_eq_comp]⟩
    by_contra hnot
    push Not at hnot
    exact hno n (le_antisymm hle (fun x hx => hnot x hx))
  have hseq : ∀ n, ∃ x : E, x ∈ LinearMap.range (A ^ n).toLinearMap ∧ ‖x‖ ≤ 1 ∧
      ∀ y ∈ LinearMap.range (A ^ (n + 1)).toLinearMap, (1 / 2 : ℝ) ≤ ‖x - y‖ := by
    intro n
    let Rn := LinearMap.range (A ^ n).toLinearMap
    let Fn : Submodule 𝕜 Rn := (LinearMap.range (A ^ (n + 1)).toLinearMap).comap Rn.subtype
    have hFn_closed : IsClosed (Fn : Set Rn) :=
      (hClosedRange (n + 1)).preimage continuous_subtype_val
    obtain ⟨x₀, hx₀n, hx₀n1⟩ := hstrict n
    obtain ⟨u, hunorm, hdist⟩ := riesz_unit_vector (𝕜 := 𝕜) hFn_closed ⟨⟨x₀, hx₀n⟩, hx₀n1⟩
    refine ⟨u.1, u.2, hunorm, fun y hy => ?_⟩
    have hyn : y ∈ Rn := by
      rcases hy with ⟨z, rfl⟩
      exact ⟨A z, by change (A ^ n) (A z) = (A ^ (n + 1)) z; rw [pow_succ, mul_apply_eq_comp]⟩
    exact hdist ⟨y, hyn⟩ hy
  choose x hxR hxnorm hxdist using hseq
  obtain ⟨y, φ, hφ, htend⟩ := isCompactOperator_exists_tendsto_subseq hK zero_lt_one hxnorm
  have hcauchy := htend.cauchySeq
  rw [Metric.cauchySeq_iff] at hcauchy
  obtain ⟨N, hN⟩ := hcauchy (1 / 2) (by norm_num)
  have hlt := hN N le_rfl (N + 1) (Nat.le_succ N)
  rw [dist_eq_norm] at hlt
  have hmn : φ N < φ (N + 1) := hφ (Nat.lt_succ_self N)
  have hrange_anti : ∀ {a b : ℕ}, a ≤ b → LinearMap.range (A ^ b).toLinearMap ≤ LinearMap.range (A ^ a).toLinearMap := by
    intro a b hab
    obtain ⟨d, rfl⟩ := Nat.exists_eq_add_of_le hab
    rintro _ ⟨z, rfl⟩
    exact ⟨(A ^ d) z, by change (A ^ a) ((A ^ d) z) = (A ^ (a + d)) z; rw [pow_add, mul_apply_eq_comp]⟩
  have hmem_range : A (x (φ N)) - A (x (φ (N + 1))) + x (φ (N + 1)) ∈
      LinearMap.range (A ^ (φ N + 1)).toLinearMap := by
    have h1 : A (x (φ N)) ∈ LinearMap.range (A ^ (φ N + 1)).toLinearMap := by
      rcases hxR (φ N) with ⟨z, hz⟩
      have hz' : (A ^ φ N) z = x (φ N) := hz
      exact ⟨z, by change (A ^ (φ N + 1)) z = A (x (φ N)); rw [pow_succ', mul_apply_eq_comp, hz']⟩
    have h2 : x (φ (N + 1)) ∈ LinearMap.range (A ^ (φ N + 1)).toLinearMap :=
      hrange_anti (Nat.succ_le_of_lt hmn) (hxR (φ (N + 1)))
    have h3 : A (x (φ (N + 1))) ∈ LinearMap.range (A ^ (φ N + 1)).toLinearMap := by
      rcases hxR (φ (N + 1)) with ⟨z, hz⟩
      have hz' : (A ^ φ (N + 1)) z = x (φ (N + 1)) := hz
      exact hrange_anti (Nat.le_succ_of_le (Nat.succ_le_of_lt hmn))
        ⟨z, by change (A ^ (φ (N + 1) + 1)) z = A (x (φ (N + 1))); rw [pow_succ', mul_apply_eq_comp, hz']⟩
    exact Submodule.add_mem _ (Submodule.sub_mem _ h1 h3) h2
  have hge := hxdist (φ N) _ hmem_range
  have hid : K (x (φ N)) - K (x (φ (N + 1))) =
      -(x (φ N) - (A (x (φ N)) - A (x (φ (N + 1))) + x (φ (N + 1)))) := by
    simp only [A, add_apply, one_apply_eq_self]
    abel
  rw [hid, norm_neg] at hlt
  linarith

/-- **Lemma 1 (Riesz–Schauder Theorem):** For any compact operator `K : E →L[𝕜] E`
on a Banach space, `id + K` is Fredholm with Fredholm index `0`. -/
theorem rieszSchauder_id_add_compact {K : E →L[𝕜] E}
    (hK : IsCompactOperator (K : E → E)) :
    IsFredholm ((1 : E →L[𝕜] E) + K) ∧ fredholmIndex ((1 : E →L[𝕜] E) + K) = 0 := by
  let A : E →L[𝕜] E := 1 + K
  obtain ⟨p, hp⟩ := ascent_stabilizes hK
  obtain ⟨q, hq⟩ := descent_stabilizes hK
  let N : ℕ := max p q + 1
  have hK_step : ∀ m ≥ p, LinearMap.ker (A ^ (m + 1)).toLinearMap = LinearMap.ker (A ^ m).toLinearMap := by
    intro m hm
    obtain ⟨d, rfl⟩ := Nat.exists_eq_add_of_le hm
    induction d with
    | zero => exact hp
    | succ d ih =>
      apply le_antisymm
      · intro x hx
        have hx' : (A ^ (p + (d + 1) + 1)) x = 0 := hx
        change (A ^ (p + (d + 1))) x = 0
        have hAx : A x ∈ LinearMap.ker (A ^ (p + d + 1)).toLinearMap := by
          change (A ^ (p + d + 1)) (A x) = 0
          have : (A ^ (p + d + 1)) (A x) = (A ^ (p + (d + 1) + 1)) x := by
            rw [← mul_apply_eq_comp, ← pow_succ]; congr 1
          rw [this, hx']
        rw [ih (by omega)] at hAx
        have hAx' : (A ^ (p + d)) (A x) = 0 := hAx
        have : (A ^ (p + (d + 1))) x = (A ^ (p + d)) (A x) := by
          rw [← mul_apply_eq_comp, ← pow_succ]; rfl
        rw [this, hAx']
      · intro x hx
        change (A ^ (p + (d + 1) + 1)) x = 0
        have hx' : (A ^ (p + (d + 1))) x = 0 := hx
        rw [pow_succ', mul_apply_eq_comp, hx', map_zero]
  have hR_step : ∀ m ≥ q, LinearMap.range (A ^ (m + 1)).toLinearMap = LinearMap.range (A ^ m).toLinearMap := by
    intro m hm
    obtain ⟨d, rfl⟩ := Nat.exists_eq_add_of_le hm
    induction d with
    | zero => exact hq
    | succ d ih =>
      apply le_antisymm
      · rintro _ ⟨x, rfl⟩
        exact ⟨A x, by change (A ^ (q + (d + 1))) (A x) = (A ^ (q + (d + 1) + 1)) x; rw [← mul_apply_eq_comp, ← pow_succ]⟩
      · rintro _ ⟨x, rfl⟩
        have hmem : (A ^ (q + d)) x ∈ LinearMap.range (A ^ (q + d + 1)).toLinearMap := by
          rw [ih (by omega)]; exact ⟨x, rfl⟩
        obtain ⟨y, hy⟩ := hmem
        have hy' : (A ^ (q + d + 1)) y = (A ^ (q + d)) x := hy
        refine ⟨y, ?_⟩
        change (A ^ (q + (d + 1) + 1)) y = (A ^ (q + (d + 1))) x
        calc (A ^ (q + (d + 1) + 1)) y
            = A ((A ^ (q + d + 1)) y) := by
                rw [← mul_apply_eq_comp, ← pow_succ']; rfl
          _ = A ((A ^ (q + d)) x) := by rw [hy']
          _ = (A ^ (q + (d + 1))) x := by
                rw [← mul_apply_eq_comp, ← pow_succ']; rfl
  have hK_add : ∀ m, LinearMap.ker (A ^ (N + m)).toLinearMap = LinearMap.ker (A ^ N).toLinearMap := by
    intro m
    induction m with
    | zero => simp
    | succ m ih =>
      rw [← Nat.add_assoc, hK_step (N + m) (by omega), ih]
  have hR_add : ∀ m, LinearMap.range (A ^ (N + m)).toLinearMap = LinearMap.range (A ^ N).toLinearMap := by
    intro m
    induction m with
    | zero => simp
    | succ m ih =>
      rw [← Nat.add_assoc, hR_step (N + m) (by omega), ih]
  let KN := LinearMap.ker (A ^ N).toLinearMap
  let RN := LinearMap.range (A ^ N).toLinearMap
  have hCompl : IsCompl KN RN := by
    rw [isCompl_iff, disjoint_iff, codisjoint_iff]
    constructor
    · rw [Submodule.eq_bot_iff]
      rintro y ⟨hyK, ⟨x, rfl⟩⟩
      have hx2N : x ∈ LinearMap.ker (A ^ (N + N)).toLinearMap := by
        change (A ^ (N + N)) x = 0
        rw [pow_add, mul_apply_eq_comp]
        exact hyK
      rw [hK_add N] at hx2N
      exact hx2N
    · rw [Submodule.eq_top_iff']
      intro x
      have hxR : (A ^ N) x ∈ LinearMap.range (A ^ (N + N)).toLinearMap := by
        rw [hR_add N]; exact ⟨x, rfl⟩
      obtain ⟨u, hu⟩ := hxR
      have hu' : (A ^ (N + N)) u = (A ^ N) x := hu
      have hsub : x - (A ^ N) u ∈ KN := by
        change (A ^ N) (x - (A ^ N) u) = 0
        rw [map_sub]
        have hcomp : (A ^ N) ((A ^ N) u) = (A ^ (N + N)) u := by
          rw [← mul_apply_eq_comp, ← pow_add]
        rw [hcomp, hu', sub_self]
      have hx_eq : x = (x - (A ^ N) u) + (A ^ N) u := (sub_add_cancel _ _).symm
      rw [hx_eq]
      exact Submodule.add_mem_sup hsub ⟨u, rfl⟩
  have hFinKN : FiniteDimensional 𝕜 KN := by
    have heq : A ^ N = 1 + (A ^ N - 1) := by abel
    rw [show KN = LinearMap.ker ((1 : E →L[𝕜] E) + (A ^ N - 1)).toLinearMap by simp [KN, ← heq]]
    exact finiteDimensional_ker_id_add_compact (isCompactOperator_pow_sub_one hK N)
  have hA_inv : ∀ u : KN, A u.1 ∈ KN := by
    intro ⟨u, hu⟩
    change (A ^ N) (A u) = 0
    have hu' : (A ^ N) u = 0 := hu
    have hcomm : (A ^ N) (A u) = A ((A ^ N) u) := by
      have h1 : (A ^ N) (A u) = (A ^ (N + 1)) u := by
        rw [← mul_apply_eq_comp, ← pow_succ]
      have h2 : A ((A ^ N) u) = (A ^ (N + 1)) u := by
        rw [← mul_apply_eq_comp, ← pow_succ']
      rw [h1, h2]
    rw [hcomm, hu', map_zero]
  let AK : KN →ₗ[𝕜] KN :=
    { toFun := fun u => ⟨A u.1, hA_inv u⟩
      map_add' := fun u v => by ext; exact map_add A u.1 v.1
      map_smul' := fun c u => by ext; exact map_smul A c u.1 }
  have hker_le_KN : LinearMap.ker A.toLinearMap ≤ KN := by
    intro x hx
    change (A ^ N) x = 0
    have hx' : A x = 0 := hx
    have hN : N = (max p q) + 1 := rfl
    rw [hN, pow_succ, mul_apply_eq_comp, hx', map_zero]
  let eKer : LinearMap.ker A.toLinearMap ≃ₗ[𝕜] LinearMap.ker AK :=
    { toFun := fun ⟨x, hx⟩ => ⟨⟨x, hker_le_KN hx⟩, by ext; exact hx⟩
      invFun := fun ⟨⟨x, _⟩, hx⟩ => ⟨x, congrArg Subtype.val hx⟩
      left_inv := fun ⟨_, _⟩ => rfl
      right_inv := fun ⟨⟨_, _⟩, _⟩ => rfl
      map_add' := fun _ _ => rfl
      map_smul' := fun _ _ => rfl }
  let ψ : KN →ₗ[𝕜] (E ⧸ LinearMap.range A.toLinearMap) := (LinearMap.range A.toLinearMap).mkQ.comp KN.subtype
  have hRN_le_range : RN ≤ LinearMap.range A.toLinearMap := by
    intro y hy
    change y ∈ LinearMap.range (A ^ N).toLinearMap at hy
    rw [← hR_add 1] at hy
    obtain ⟨z, rfl⟩ := hy
    exact ⟨(A ^ N) z, by change A ((A ^ N) z) = (A ^ (N + 1)) z; rw [← mul_apply_eq_comp, ← pow_succ']⟩
  have hψ_surj : Function.Surjective ψ := by
    intro q
    obtain ⟨x, rfl⟩ := Submodule.Quotient.mk_surjective _ q
    have hx : x ∈ KN ⊔ RN := by rw [hCompl.sup_eq_top]; trivial
    obtain ⟨k, hk, r, hr, rfl⟩ := Submodule.mem_sup.mp hx
    refine ⟨⟨k, hk⟩, ?_⟩
    simp only [ψ, LinearMap.comp_apply, Submodule.coe_subtype, Submodule.mkQ_apply]
    rw [Submodule.Quotient.eq]
    have : k - (k + r) = -r := by abel
    rw [this]
    exact (LinearMap.range A.toLinearMap).neg_mem (hRN_le_range hr)
  have hψ_ker : LinearMap.ker ψ = LinearMap.range AK := by
    ext ⟨k, hk⟩
    simp only [ψ, LinearMap.mem_ker, LinearMap.comp_apply, Submodule.coe_subtype,
      Submodule.mkQ_apply, Submodule.Quotient.mk_eq_zero, LinearMap.mem_range]
    constructor
    · rintro ⟨x, hx⟩
      have hx' : x ∈ KN ⊔ RN := by rw [hCompl.sup_eq_top]; trivial
      obtain ⟨u, hu, r, hr, rfl⟩ := Submodule.mem_sup.mp hx'
      have hxA : A (u + r) = k := hx
      have hAr_KN : A r ∈ KN := by
        have : A r = k - A u := by rw [← hxA, map_add]; abel
        rw [this]
        exact KN.sub_mem hk (hA_inv ⟨u, hu⟩)
      have hAr_RN : A r ∈ RN := by
        rcases hr with ⟨z, rfl⟩
        change A ((A ^ N) z) ∈ LinearMap.range (A ^ N).toLinearMap
        rw [← hR_add 1]
        exact ⟨z, by change (A ^ (N + 1)) z = A ((A ^ N) z); rw [pow_succ', mul_apply_eq_comp]⟩
      have hAr0 : A r = 0 := by
        have hmem : A r ∈ KN ⊓ RN := ⟨hAr_KN, hAr_RN⟩
        rwa [hCompl.inf_eq_bot, Submodule.mem_bot] at hmem
      refine ⟨⟨u, hu⟩, ?_⟩
      ext
      simpa [AK, map_add, hAr0] using hxA
    · rintro ⟨⟨u, hu⟩, huEq⟩
      exact ⟨u, congrArg Subtype.val huEq⟩
  let eCoker : (KN ⧸ LinearMap.range AK) ≃ₗ[𝕜] (E ⧸ LinearMap.range A.toLinearMap) :=
    (Submodule.quotEquivOfEq _ _ hψ_ker.symm).trans (ψ.quotKerEquivOfSurjective hψ_surj)
  have hFinKer : FiniteDimensional 𝕜 (LinearMap.ker A.toLinearMap) :=
    finiteDimensional_ker_id_add_compact hK
  have hFinCoker : FiniteDimensional 𝕜 (E ⧸ LinearMap.range A.toLinearMap) :=
    eCoker.finiteDimensional
  have hClosed : IsClosed (LinearMap.range A.toLinearMap : Set E) :=
    isClosed_range_id_add_compact hK
  have hRankNull := LinearMap.finrank_range_add_finrank_ker AK
  have hQuot := Submodule.finrank_quotient_add_finrank (LinearMap.range AK)
  have hEqDim : Module.finrank 𝕜 (LinearMap.ker A.toLinearMap) =
      Module.finrank 𝕜 (E ⧸ LinearMap.range A.toLinearMap) := by
    rw [eKer.finrank_eq, ← eCoker.finrank_eq]
    omega
  refine ⟨⟨hFinKer, hFinCoker, hClosed⟩, ?_⟩
  unfold fredholmIndex
  rw [hEqDim, sub_self]

end RieszSchauder

/-! ## Lemma 2: Parametrix Reduction of `T + K` and `CompactFredholmTheory` Instance -/

section ParametrixReduction

variable {𝕜 : Type*} [RCLike 𝕜]
variable {E F : Type u}
  [NormedAddCommGroup E] [NormedSpace 𝕜 E] [CompleteSpace E]
  [NormedAddCommGroup F] [NormedSpace 𝕜 F] [CompleteSpace F]

/-- Every Fredholm operator admits a bounded two-sided parametrix `R : F →L[𝕜] E`
such that `R ∘ T - id` and `T ∘ R - id` have finite-dimensional range (hence are compact). -/
theorem exists_finiteRank_parametrix {T : E →L[𝕜] F} (hT : IsFredholm T) :
    ∃ (R : F →L[𝕜] E),
      IsCompactOperator ((R.comp T - ContinuousLinearMap.id 𝕜 E : E →L[𝕜] E) : E → E) ∧
      IsCompactOperator ((T.comp R - ContinuousLinearMap.id 𝕜 F : F →L[𝕜] F) : F → F) := by
  have := hT.finDimKer
  have := hT.finDimCoker
  obtain ⟨Pker, hPker_fix, hPker_range, hE0_closed, hE0_compl⟩ :=
    exists_closed_compl_of_finiteDimensional (LinearMap.ker T.toLinearMap)
  let E₀ := LinearMap.ker Pker.toLinearMap
  have : CompleteSpace E₀ := hE0_closed.completeSpace_coe
  obtain ⟨N, hN⟩ := Submodule.exists_isCompl (LinearMap.range T.toLinearMap)
  have : FiniteDimensional 𝕜 N :=
    LinearEquiv.finiteDimensional
      (Submodule.quotientEquivOfIsCompl (LinearMap.range T.toLinearMap) N hN)
  have : CompleteSpace N := FiniteDimensional.complete 𝕜 N
  let Ψ : (E₀ × N) →L[𝕜] F :=
    (T.comp E₀.subtypeL).comp (ContinuousLinearMap.fst 𝕜 E₀ N) +
    N.subtypeL.comp (ContinuousLinearMap.snd 𝕜 E₀ N)
  have hΨ_inj : Function.Injective Ψ := by
    rw [injective_iff_map_eq_zero]
    rintro ⟨e₀, n⟩ h0
    have hsum : T e₀.1 + n.1 = 0 := h0
    have hn_range : n.1 ∈ LinearMap.range T.toLinearMap := by
      have : n.1 = -(T e₀.1) := eq_neg_of_add_eq_zero_right hsum
      rw [this]; exact (LinearMap.range T.toLinearMap).neg_mem ⟨e₀.1, rfl⟩
    have hn0 : n.1 = 0 := by
      have hmem : n.1 ∈ LinearMap.range T.toLinearMap ⊓ N := ⟨hn_range, n.2⟩
      rwa [hN.inf_eq_bot, Submodule.mem_bot] at hmem
    have hTe0 : e₀.1 ∈ LinearMap.ker T.toLinearMap := by
      change T e₀.1 = 0
      simpa [hn0] using hsum
    have he0 : e₀.1 = 0 := by
      have hmem : e₀.1 ∈ LinearMap.ker T.toLinearMap ⊓ E₀ := ⟨hTe0, e₀.2⟩
      rwa [hE0_compl.inf_eq_bot, Submodule.mem_bot] at hmem
    ext <;> assumption
  have hΨ_surj : Function.Surjective Ψ := by
    intro y
    have hy : y ∈ LinearMap.range T.toLinearMap ⊔ N := by rw [hN.sup_eq_top]; trivial
    obtain ⟨u, ⟨x, rfl⟩, v, hv, rfl⟩ := Submodule.mem_sup.mp hy
    have hx : x ∈ LinearMap.ker T.toLinearMap ⊔ E₀ := by rw [hE0_compl.sup_eq_top]; trivial
    obtain ⟨k, hk, e₀, he₀, rfl⟩ := Submodule.mem_sup.mp hx
    refine ⟨(⟨e₀, he₀⟩, ⟨v, hv⟩), ?_⟩
    have hk0 : T k = 0 := hk
    change T e₀ + v = T (k + e₀) + v
    rw [map_add, hk0, zero_add]
  let eΨ : (E₀ × N) ≃L[𝕜] F :=
    ContinuousLinearEquiv.ofBijective Ψ (LinearMap.ker_eq_bot.mpr hΨ_inj)
      (LinearMap.range_eq_top.mpr hΨ_surj)
  let R : F →L[𝕜] E := E₀.subtypeL.comp ((ContinuousLinearMap.fst 𝕜 E₀ N).comp (eΨ.symm : F →L[𝕜] _))
  have hRT : R.comp T - ContinuousLinearMap.id 𝕜 E = -Pker := by
    ext x
    have hsub_E0 : x - Pker x ∈ E₀ := by
      change Pker (x - Pker x) = 0
      rw [map_sub]
      have hmem : Pker x ∈ LinearMap.ker T.toLinearMap := by rw [← hPker_range]; exact ⟨x, rfl⟩
      rw [hPker_fix ⟨Pker x, hmem⟩, sub_self]
    have hTx : T x = eΨ (⟨x - Pker x, hsub_E0⟩, 0) := by
      have hmem : Pker x ∈ LinearMap.ker T.toLinearMap := by rw [← hPker_range]; exact ⟨x, rfl⟩
      have hTker : T (Pker x) = 0 := hmem
      change T x = T (x - Pker x) + 0
      rw [map_sub, hTker, sub_zero, add_zero]
    change (eΨ.symm (T x)).1.1 - x = -(Pker x)
    rw [hTx, ContinuousLinearEquiv.symm_apply_apply]
    change (x - Pker x) - x = -(Pker x)
    abel
  let PN : F →L[𝕜] F := N.subtypeL.comp ((ContinuousLinearMap.snd 𝕜 E₀ N).comp (eΨ.symm : F →L[𝕜] _))
  have hTR : T.comp R - ContinuousLinearMap.id 𝕜 F = -PN := by
    ext y
    obtain ⟨⟨e₀, n⟩, rfl⟩ := eΨ.surjective y
    change T (eΨ.symm (eΨ (e₀, n))).1.1 - eΨ (e₀, n) = -(eΨ.symm (eΨ (e₀, n))).2.1
    rw [ContinuousLinearEquiv.symm_apply_apply]
    change T e₀.1 - (T e₀.1 + n.1) = -n.1
    abel
  refine ⟨R, ?_, ?_⟩
  · rw [hRT]
    have : FiniteDimensional 𝕜 (LinearMap.range Pker.toLinearMap) := by rw [hPker_range]; infer_instance
    exact (isCompactOperator_of_finiteDimensional_range Pker).neg
  · rw [hTR]
    have hle : LinearMap.range PN.toLinearMap ≤ N := by
      rintro _ ⟨y, rfl⟩; exact (eΨ.symm y).2.2
    have : FiniteDimensional 𝕜 (LinearMap.range PN.toLinearMap) :=
      Module.Finite.of_injective (Submodule.inclusion hle) (Submodule.inclusion_injective hle)
    exact (isCompactOperator_of_finiteDimensional_range PN).neg

/-- **Lemma 2 (Compact Perturbation Stability):** Adding a compact operator preserves
both the Fredholm property and the Fredholm index. -/
theorem fredholm_add_compact {T K : E →L[𝕜] F}
    (hT : IsFredholm T) (hK : IsCompactOperator (K : E → F)) :
    IsFredholm (T + K) ∧ fredholmIndex (T + K) = fredholmIndex T := by
  obtain ⟨R, hRT_comp, hTR_comp⟩ := exists_finiteRank_parametrix hT
  have hRT_RS : IsFredholm (R.comp T) ∧ fredholmIndex (R.comp T) = 0 := by
    have heq : R.comp T = (1 : E →L[𝕜] E) + (R.comp T - ContinuousLinearMap.id 𝕜 E) := by
      ext x; simp
    rw [heq]; exact rieszSchauder_id_add_compact hRT_comp
  have hTR_RS : IsFredholm (T.comp R) ∧ fredholmIndex (T.comp R) = 0 := by
    have heq : T.comp R = (1 : F →L[𝕜] F) + (T.comp R - ContinuousLinearMap.id 𝕜 F) := by
      ext y; simp
    rw [heq]; exact rieszSchauder_id_add_compact hTR_comp
  have hR_fred : IsFredholm R := by
    have := hTR_RS.1.finDimKer
    have := hRT_RS.1.finDimCoker
    have hker_le : LinearMap.ker R.toLinearMap ≤ LinearMap.ker (T.comp R).toLinearMap := fun y hy => by
      change T (R y) = 0
      have hy' : R y = 0 := hy
      rw [hy', map_zero]
    have hrange_le : LinearMap.range (R.comp T).toLinearMap ≤ LinearMap.range R.toLinearMap := by
      rintro _ ⟨x, rfl⟩; exact ⟨T x, rfl⟩
    have hK_R : FiniteDimensional 𝕜 (LinearMap.ker R.toLinearMap) :=
      Module.Finite.of_injective (Submodule.inclusion hker_le) (Submodule.inclusion_injective hker_le)
    have hC_R : FiniteDimensional 𝕜 (E ⧸ LinearMap.range R.toLinearMap) :=
      Module.Finite.of_surjective (Submodule.factor hrange_le) (Submodule.factor_surjective hrange_le)
    exact ⟨hK_R, hC_R, closedRange_of_finiteDimensional_coker R⟩
  have hRTK_RS : IsFredholm (R.comp (T + K)) ∧ fredholmIndex (R.comp (T + K)) = 0 := by
    have heq : R.comp (T + K) =
        (1 : E →L[𝕜] E) + ((R.comp T - ContinuousLinearMap.id 𝕜 E) + R.comp K) := by
      ext x; simp; abel
    rw [heq]
    exact rieszSchauder_id_add_compact (hRT_comp.add (hK.clm_comp R))
  have hTKR_RS : IsFredholm ((T + K).comp R) ∧ fredholmIndex ((T + K).comp R) = 0 := by
    have heq : (T + K).comp R =
        (1 : F →L[𝕜] F) + ((T.comp R - ContinuousLinearMap.id 𝕜 F) + K.comp R) := by
      ext y; simp; abel
    rw [heq]
    exact rieszSchauder_id_add_compact (hTR_comp.add (hK.comp_clm R))
  have hTK_fred : IsFredholm (T + K) := by
    have := hRTK_RS.1.finDimKer
    have := hTKR_RS.1.finDimCoker
    have hker_le : LinearMap.ker (T + K).toLinearMap ≤ LinearMap.ker (R.comp (T + K)).toLinearMap := fun x hx => by
      change R ((T + K) x) = 0
      have hx' : (T + K) x = 0 := hx
      rw [hx', map_zero]
    have hrange_le : LinearMap.range ((T + K).comp R).toLinearMap ≤ LinearMap.range (T + K).toLinearMap := by
      rintro _ ⟨y, rfl⟩; exact ⟨R y, rfl⟩
    have hK_TK : FiniteDimensional 𝕜 (LinearMap.ker (T + K).toLinearMap) :=
      Module.Finite.of_injective (Submodule.inclusion hker_le) (Submodule.inclusion_injective hker_le)
    have hC_TK : FiniteDimensional 𝕜 (F ⧸ LinearMap.range (T + K).toLinearMap) :=
      Module.Finite.of_surjective (Submodule.factor hrange_le) (Submodule.factor_surjective hrange_le)
    exact ⟨hK_TK, hC_TK, closedRange_of_finiteDimensional_coker (T + K)⟩
  have h1 : fredholmIndex R + fredholmIndex (T + K) = 0 := by
    rw [← fredholmIndex_comp hR_fred hTK_fred, hRTK_RS.2]
  have h2 : fredholmIndex R + fredholmIndex T = 0 := by
    rw [← fredholmIndex_comp hR_fred hT, hRT_RS.2]
  exact ⟨hTK_fred, by linarith⟩

/-- **Global Instance:** `CompactFredholmTheory 𝕜` is now unconditionally discharged. -/
instance instCompactFredholmTheory : CompactFredholmTheory.{u} 𝕜 where
  add_compact hT hK := fredholm_add_compact hT hK

end ParametrixReduction

end Signals.SatoGrassmannian
