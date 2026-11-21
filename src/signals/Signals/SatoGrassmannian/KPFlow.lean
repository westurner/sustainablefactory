import Mathlib.Analysis.Normed.Algebra.Exponential
import Mathlib.Analysis.Normed.Lp.lpSpace
import Mathlib.Analysis.Normed.Operator.Compact.Basic
import Mathlib.Analysis.Calculus.Deriv.Basic
import Mathlib.Analysis.SpecialFunctions.ExpDeriv
import Signals.SatoGrassmannian.Base
import Signals.SatoGrassmannian.RieszSchauder
import Signals.SatoGrassmannian.CircleL2
import Signals.SatoGrassmannian.Gr24Truncation

open scoped InnerProductSpace

namespace Signals.SatoGrassmannian.KPFlow

open Signals.SatoGrassmannian Signals.SatoGrassmannian.CircleL2 Signals.SatoGrassmannian.Gr24Truncation

universe u

/-! ### Section 1: Norm-Closedness of Compact Operators & Restricted Banach Subalgebra -/

section RestrictedSubalgebra

variable {𝕜 : Type*} [RCLike 𝕜]
variable {E F : Type u}
  [NormedAddCommGroup E] [NormedSpace 𝕜 E]
  [NormedAddCommGroup F] [NormedSpace 𝕜 F] [CompleteSpace F]

omit [CompleteSpace F] in
/-- Every compact bounded operator maps the unit closed ball to a totally bounded set. -/
lemma isCompactOperator_totallyBounded_image_closedBall {T : E →L[𝕜] F}
    (hT : IsCompactOperator (T : E → F)) :
    TotallyBounded ((T : E → F) '' Metric.closedBall 0 1) := by
  rcases hT with ⟨s, hs_comp, hpre⟩
  obtain ⟨r, hr, hrs⟩ := Metric.mem_nhds_iff.mp hpre
  have hr2 : 0 < r / 2 := half_pos hr
  have hsub : (T : E → F) '' Metric.closedBall 0 (r / 2) ⊆ s := by
    rintro _ ⟨x, hx, rfl⟩
    apply hrs
    rw [Metric.mem_closedBall, dist_zero_right] at hx
    rw [Metric.mem_ball, dist_zero_right]
    exact lt_of_le_of_lt hx (half_lt_self hr)
  have htb_small : TotallyBounded ((T : E → F) '' Metric.closedBall 0 (r / 2)) :=
    hs_comp.totallyBounded.subset hsub
  let c : 𝕜 := ((2 / r : ℝ) : 𝕜)
  have hscale : (T : E → F) '' Metric.closedBall 0 1 =
      (fun y : F => c • y) '' ((T : E → F) '' Metric.closedBall 0 (r / 2)) := by
    ext y
    constructor
    · rintro ⟨x, hx, rfl⟩
      let x' : E := (((r / 2 : ℝ) : 𝕜) • x)
      refine ⟨T x', ⟨x', ?_, rfl⟩, ?_⟩
      · rw [Metric.mem_closedBall, dist_zero_right] at hx ⊢
        rw [norm_smul, RCLike.norm_ofReal, abs_of_pos hr2]
        calc (r / 2) * ‖x‖ ≤ (r / 2) * 1 := mul_le_mul_of_nonneg_left hx hr2.le
          _ = r / 2 := mul_one _
      · dsimp only
        rw [map_smul, smul_smul]
        have hmul : c * ((r / 2 : ℝ) : 𝕜) = 1 := by
          dsimp [c]; norm_cast; field_simp [hr.ne']
        rw [hmul, one_smul]
    · rintro ⟨_, ⟨x', hx', rfl⟩, rfl⟩
      refine ⟨c • x', ?_, map_smul T c x'⟩
      rw [Metric.mem_closedBall, dist_zero_right] at hx' ⊢
      rw [norm_smul, RCLike.norm_ofReal, abs_of_pos (div_pos two_pos hr)]
      calc (2 / r) * ‖x'‖ ≤ (2 / r) * (r / 2) :=
            mul_le_mul_of_nonneg_left hx' (div_pos two_pos hr).le
        _ = 1 := by field_simp [hr.ne']
  rw [hscale]
  exact htb_small.image (uniformContinuous_const_smul c)

/-- **Norm-Closedness of Compact Operators:** The ideal of compact operators `E →L[𝕜] F`
into a Banach space `F` is closed in the operator norm topology. -/
theorem isClosed_isCompactOperator :
    IsClosed { K : E →L[𝕜] F | IsCompactOperator (K : E → F) } := by
  rw [← closure_subset_iff_isClosed]
  intro K hK
  have htb : TotallyBounded ((K : E → F) '' Metric.closedBall 0 1) := by
    rw [Metric.totallyBounded_iff]
    intro ε hε
    obtain ⟨T, hT_mem, hTK⟩ := Metric.mem_closure_iff.mp hK (ε / 2) (half_pos hε)
    obtain ⟨t, ht_fin, hcover⟩ :=
      Metric.totallyBounded_iff.mp (isCompactOperator_totallyBounded_image_closedBall hT_mem)
        (ε / 2) (half_pos hε)
    refine ⟨t, ht_fin, ?_⟩
    rintro _ ⟨x, hx, rfl⟩
    have hTx : T x ∈ ⋃ y ∈ t, Metric.ball y (ε / 2) := hcover ⟨x, hx, rfl⟩
    rcases Set.mem_iUnion₂.mp hTx with ⟨y, hyt, hy⟩
    refine Set.mem_iUnion₂.mpr ⟨y, hyt, ?_⟩
    rw [Metric.mem_ball] at hy ⊢
    rw [Metric.mem_closedBall, dist_zero_right] at hx
    have hdiff : dist (K x) (T x) < ε / 2 := by
      rw [dist_eq_norm, ← sub_apply]
      calc ‖(K - T) x‖ ≤ ‖K - T‖ * ‖x‖ := (K - T).le_opNorm x
        _ ≤ ‖K - T‖ * 1 := mul_le_mul_of_nonneg_left hx (norm_nonneg _)
        _ = dist K T := by rw [mul_one, dist_eq_norm]
        _ < ε / 2 := hTK
    exact lt_of_le_of_lt (dist_triangle (K x) (T x) y) (by linarith)
  refine ⟨closure ((K : E → F) '' Metric.closedBall 0 1),
    isCompact_iff_totallyBounded_isComplete.mpr ⟨htb.closure, isClosed_closure.isComplete⟩, ?_⟩
  exact Filter.mem_of_superset (Metric.closedBall_mem_nhds 0 zero_lt_one)
    fun x hx => subset_closure ⟨x, hx, rfl⟩

variable {H : Type u} [NormedAddCommGroup H] [InnerProductSpace ℂ H] [CompleteSpace H]

/-- The restricted operator algebra `𝒜_res(H) = { A : H →L[ℂ] H | [J, A] compact }`. -/
noncomputable def resAlg (P : PolarizedHilbertSpace ℂ H) : Subalgebra ℂ (H →L[ℂ] H) where
  carrier := { A | IsCompactOperator
    (((polarizationJ P).comp A - A.comp (polarizationJ P) : H →L[ℂ] H) : H → H) }
  one_mem' := by
    change IsCompactOperator (((polarizationJ P).comp (ContinuousLinearMap.id ℂ H) -
      (ContinuousLinearMap.id ℂ H).comp (polarizationJ P) : H →L[ℂ] H) : H → H)
    simp [isCompactOperator_zero]
  zero_mem' := by
    change IsCompactOperator (((polarizationJ P).comp 0 -
      (0 : H →L[ℂ] H).comp (polarizationJ P) : H →L[ℂ] H) : H → H)
    simp [isCompactOperator_zero]
  add_mem' := fun {A B} hA hB => by
    have heq : (polarizationJ P).comp (A + B) - (A + B).comp (polarizationJ P) =
        ((polarizationJ P).comp A - A.comp (polarizationJ P)) +
        ((polarizationJ P).comp B - B.comp (polarizationJ P)) := by
      ext x; simp; abel
    change IsCompactOperator (((polarizationJ P).comp (A + B) -
      (A + B).comp (polarizationJ P) : H →L[ℂ] H) : H → H)
    rw [heq]; exact hA.add hB
  mul_mem' := fun {A B} hA hB => by
    have hderiv : (polarizationJ P).comp (A.comp B) - (A.comp B).comp (polarizationJ P) =
        ((polarizationJ P).comp A - A.comp (polarizationJ P)).comp B +
        A.comp ((polarizationJ P).comp B - B.comp (polarizationJ P)) := by
      ext x; simp [ContinuousLinearMap.comp_apply]
    change IsCompactOperator (((polarizationJ P).comp (A.comp B) -
      (A.comp B).comp (polarizationJ P) : H →L[ℂ] H) : H → H)
    rw [hderiv]; exact (hA.comp_clm B).add (hB.clm_comp A)
  algebraMap_mem' := fun c => by
    have heq : (polarizationJ P).comp (algebraMap ℂ (H →L[ℂ] H) c) -
        (algebraMap ℂ (H →L[ℂ] H) c).comp (polarizationJ P) = 0 := by
      ext x; simp [Algebra.algebraMap_eq_smul_one]
    change IsCompactOperator (((polarizationJ P).comp (algebraMap ℂ (H →L[ℂ] H) c) -
      (algebraMap ℂ (H →L[ℂ] H) c).comp (polarizationJ P) : H →L[ℂ] H) : H → H)
    rw [heq]; exact isCompactOperator_zero

/-- `𝒜_res(H)` is norm-closed in `H →L[ℂ] H`. -/
theorem isClosed_resAlg (P : PolarizedHilbertSpace ℂ H) :
    IsClosed (resAlg P : Set (H →L[ℂ] H)) := by
  let commJ : (H →L[ℂ] H) → (H →L[ℂ] H) :=
    fun A => (polarizationJ P).comp A - A.comp (polarizationJ P)
  have hcont : Continuous commJ :=
    (continuous_const.mul continuous_id).sub (continuous_id.mul continuous_const)
  exact isClosed_isCompactOperator.preimage hcont

/-- Exact `HasSum` for the complex Banach-algebra exponential series `∑ (k!)⁻¹ • X^k = exp X`. -/
lemma hasSum_exp_terms {A : Type*} [NormedRing A] [NormedAlgebra ℂ A] [CompleteSpace A] (X : A) :
    HasSum (fun k : ℕ => (k.factorial : ℂ)⁻¹ • X ^ k) (NormedSpace.exp X) := by
  have h := (NormedSpace.expSeries_summable (𝕂 := ℂ) X).hasSum
  simp_rw [NormedSpace.expSeries_apply_eq] at h
  have heq : ∑' k : ℕ, (k.factorial : ℂ)⁻¹ • X ^ k = NormedSpace.exp X := by
    rw [congrFun (NormedSpace.exp_eq_tsum (𝕂 := ℂ) (𝔸 := A)) X]
  rwa [heq] at h

/-- The Banach-algebra exponential preserves `𝒜_res(H)`. -/
theorem exp_mem_resAlg (P : PolarizedHilbertSpace ℂ H) {A : H →L[ℂ] H} (hA : A ∈ resAlg P) :
    NormedSpace.exp A ∈ resAlg P := by
  refine (isClosed_resAlg P).mem_of_tendsto (hasSum_exp_terms A) ?_
  filter_upwards with s
  exact Subalgebra.sum_mem (resAlg P) fun k _ =>
    Subalgebra.smul_mem (resAlg P) (Subalgebra.pow_mem (resAlg P) hA k) _

/-- Exponential law for commuting bounded operators on a complex Banach space. -/
lemma clm_exp_add_of_commute {E : Type*} [NormedAddCommGroup E] [NormedSpace ℂ E] [CompleteSpace E]
    {A B : E →L[ℂ] E} (h : Commute A B) :
    NormedSpace.exp (A + B) = NormedSpace.exp A * NormedSpace.exp B := by
  let _ : NormedAlgebra ℚ (E →L[ℂ] E) := NormedAlgebra.restrictScalars ℚ ℂ (E →L[ℂ] E)
  exact NormedSpace.exp_add_of_commute h

/-- Exponential map `exp : (H →L[ℂ] H) → (H ≃L[ℂ] H)`. -/
noncomputable def expCLE {E : Type*} [NormedAddCommGroup E] [NormedSpace ℂ E] [CompleteSpace E]
    (A : E →L[ℂ] E) : E ≃L[ℂ] E where
  toFun := (NormedSpace.exp A : E →L[ℂ] E)
  invFun := (NormedSpace.exp (-A) : E →L[ℂ] E)
  left_inv := fun x => by
    change ((NormedSpace.exp (-A) : E →L[ℂ] E) * (NormedSpace.exp A : E →L[ℂ] E)) x = x
    rw [← clm_exp_add_of_commute (Commute.neg_left (Commute.refl A)), neg_add_cancel,
      NormedSpace.exp_zero]; rfl
  right_inv := fun x => by
    change ((NormedSpace.exp A : E →L[ℂ] E) * (NormedSpace.exp (-A) : E →L[ℂ] E)) x = x
    rw [← clm_exp_add_of_commute (Commute.neg_right (Commute.refl A)), add_neg_cancel,
      NormedSpace.exp_zero]; rfl
  map_add' := fun x y => map_add (NormedSpace.exp A : E →L[ℂ] E) x y
  map_smul' := fun c x => map_smul (NormedSpace.exp A : E →L[ℂ] E) c x
  continuous_toFun := (NormedSpace.exp A : E →L[ℂ] E).continuous
  continuous_invFun := (NormedSpace.exp (-A) : E →L[ℂ] E).continuous

@[simp]
lemma coe_expCLE {E : Type*} [NormedAddCommGroup E] [NormedSpace ℂ E] [CompleteSpace E]
    (A : E →L[ℂ] E) : (expCLE A : E →L[ℂ] E) = NormedSpace.exp A := by
  ext x; rfl

/-- Exponential map `𝒜_res(H) → GL_res(H)`. -/
noncomputable def expGLRes (P : PolarizedHilbertSpace ℂ H) (A : H →L[ℂ] H) (hA : A ∈ resAlg P) :
    GLRes P :=
  ⟨expCLE A, by
    change IsCompactOperator (blockPM P (expCLE A : H →L[ℂ] H)) ∧
      IsCompactOperator (blockMP P (expCLE A : H →L[ℂ] H))
    rw [coe_expCLE]
    exact (isCompact_commutator_J_iff P (NormedSpace.exp A)).mp (exp_mem_resAlg P hA)⟩

end RestrictedSubalgebra

/-! ### Section 2: KP Time Space `ℓ¹(ℕ₊, ℂ)` & Positive Loop Group `Γ₊ ≤ GL_res(L²(S¹))` -/

/-- The KP hierarchy time space `t = (t₁, t₂, …) ∈ ℓ¹(ℕ₊, ℂ)`. -/
noncomputable abbrev KPTime := lp (fun _ : ℕ+ => ℂ) 1

/-- The bilateral shift operator `S = M_z : L²(S¹) →L[ℂ] L²(S¹)`. -/
noncomputable abbrev shiftOp : HCircle →L[ℂ] HCircle :=
  (shiftCLE : HCircle →L[ℂ] HCircle)

lemma opNorm_shiftOp_le : ‖shiftOp‖ ≤ 1 :=
  ContinuousLinearMap.opNorm_le_bound shiftOp zero_le_one fun f => by
    simp [shiftOp, shiftCLE]

lemma opNorm_shiftOp_pow_le (n : ℕ) : ‖shiftOp ^ n‖ ≤ 1 := by
  induction n with
  | zero =>
    calc ‖(1 : HCircle →L[ℂ] HCircle)‖ ≤ 1 := ContinuousLinearMap.norm_id_le
  | succ n ih =>
    rw [pow_succ]
    calc ‖shiftOp ^ n * shiftOp‖ ≤ ‖shiftOp ^ n‖ * ‖shiftOp‖ := ContinuousLinearMap.opNorm_comp_le _ _
      _ ≤ 1 * 1 := mul_le_mul ih opNorm_shiftOp_le (norm_nonneg _) zero_le_one
      _ = 1 := one_mul 1

lemma summable_kpTerms (t : KPTime) :
    Summable (fun n : ℕ+ => (t n : ℂ) • shiftOp ^ (n : ℕ)) := by
  have ht : Summable (fun n : ℕ+ => ‖(t n : ℂ)‖) := by
    have h := (memℓp_gen_iff (by norm_num : (0 : ℝ) < (1 : ENNReal).toReal)).mp (lp.memℓp t)
    simpa using h
  refine Summable.of_norm_bounded ht fun n => ?_
  rw [norm_smul]
  calc ‖(t n : ℂ)‖ * ‖shiftOp ^ (n : ℕ)‖ ≤ ‖(t n : ℂ)‖ * 1 :=
        mul_le_mul_of_nonneg_left (opNorm_shiftOp_pow_le (n : ℕ)) (norm_nonneg _)
    _ = ‖(t n : ℂ)‖ := mul_one _

/-- The KP generator `ξ(t) = ∑_{n ≥ 1} t_n S^n ∈ 𝒜_res(L²(S¹))`. -/
noncomputable def kpGenerator (t : KPTime) : HCircle →L[ℂ] HCircle :=
  ∑' n : ℕ+, (t n : ℂ) • shiftOp ^ (n : ℕ)

lemma kpGenerator_zero : kpGenerator 0 = 0 := by
  unfold kpGenerator
  have h0 : (fun n : ℕ+ => ((0 : KPTime) n : ℂ) • shiftOp ^ (n : ℕ)) = fun _ => 0 := by
    funext n
    change (0 : ℂ) • shiftOp ^ (n : ℕ) = 0
    exact zero_smul ℂ (shiftOp ^ (n : ℕ))
  rw [h0, tsum_zero]

lemma kpGenerator_add (t₁ t₂ : KPTime) :
    kpGenerator (t₁ + t₂) = kpGenerator t₁ + kpGenerator t₂ := by
  unfold kpGenerator
  have hfun : (fun n : ℕ+ => ((t₁ + t₂) n : ℂ) • shiftOp ^ (n : ℕ)) =
      fun n : ℕ+ => (t₁ n : ℂ) • shiftOp ^ (n : ℕ) + (t₂ n : ℂ) • shiftOp ^ (n : ℕ) := by
    funext n
    change ((t₁ n : ℂ) + (t₂ n : ℂ)) • shiftOp ^ (n : ℕ) = _
    exact add_smul (t₁ n : ℂ) (t₂ n : ℂ) (shiftOp ^ (n : ℕ))
  rw [hfun, (summable_kpTerms t₁).tsum_add (summable_kpTerms t₂)]

lemma kpGenerator_neg (t : KPTime) : kpGenerator (-t) = -kpGenerator t := by
  unfold kpGenerator
  have hfun : (fun n : ℕ+ => ((-t) n : ℂ) • shiftOp ^ (n : ℕ)) =
      fun n : ℕ+ => -((t n : ℂ) • shiftOp ^ (n : ℕ)) := by
    funext n
    change (-(t n : ℂ)) • shiftOp ^ (n : ℕ) = _
    exact neg_smul (t n : ℂ) (shiftOp ^ (n : ℕ))
  rw [hfun, tsum_neg]

lemma kpGenerator_single (n : ℕ+) (s : ℂ) :
    kpGenerator (lp.single 1 n s) = s • shiftOp ^ (n : ℕ) := by
  unfold kpGenerator
  rw [tsum_eq_single n]
  · simp [lp.single_apply]
  · intro m hm
    change ((lp.single (E := fun _ : ℕ+ => ℂ) 1 n s) m : ℂ) • shiftOp ^ (m : ℕ) = 0
    rw [lp.single_apply_ne _ _ _ hm]
    exact zero_smul ℂ (shiftOp ^ (m : ℕ))

lemma kpGenerator_commute (t₁ t₂ : KPTime) :
    Commute (kpGenerator t₁) (kpGenerator t₂) := by
  let compL := ContinuousLinearMap.compL ℂ HCircle HCircle HCircle
  have hpow : ∀ m : ℕ, Commute (shiftOp ^ m) (kpGenerator t₂) := by
    intro m
    have hsum := (summable_kpTerms t₂).hasSum
    have hL : HasSum (fun n : ℕ+ => shiftOp ^ m * ((t₂ n : ℂ) • shiftOp ^ (n : ℕ)))
        (shiftOp ^ m * kpGenerator t₂) :=
      hsum.map (compL (shiftOp ^ m)).toAddMonoidHom (compL (shiftOp ^ m)).continuous
    have hR : HasSum (fun n : ℕ+ => ((t₂ n : ℂ) • shiftOp ^ (n : ℕ)) * shiftOp ^ m)
        (kpGenerator t₂ * shiftOp ^ m) :=
      hsum.map (compL.flip (shiftOp ^ m)).toAddMonoidHom (compL.flip (shiftOp ^ m)).continuous
    have heq : (fun n : ℕ+ => shiftOp ^ m * ((t₂ n : ℂ) • shiftOp ^ (n : ℕ))) =
        fun n : ℕ+ => ((t₂ n : ℂ) • shiftOp ^ (n : ℕ)) * shiftOp ^ m := by
      funext n
      apply ContinuousLinearMap.ext; intro f
      simp only [mul_apply_eq_comp, smul_apply, map_smul]
      rw [← mul_apply_eq_comp, ← mul_apply_eq_comp, (Commute.pow_pow rfl m (n : ℕ)).eq]
    rw [heq] at hL
    exact hL.unique hR
  have hsum1 := (summable_kpTerms t₁).hasSum
  have hL : HasSum (fun m : ℕ+ => ((t₁ m : ℂ) • shiftOp ^ (m : ℕ)) * kpGenerator t₂)
      (kpGenerator t₁ * kpGenerator t₂) :=
    hsum1.map (compL.flip (kpGenerator t₂)).toAddMonoidHom (compL.flip (kpGenerator t₂)).continuous
  have hR : HasSum (fun m : ℕ+ => kpGenerator t₂ * ((t₁ m : ℂ) • shiftOp ^ (m : ℕ)))
      (kpGenerator t₂ * kpGenerator t₁) :=
    hsum1.map (compL (kpGenerator t₂)).toAddMonoidHom (compL (kpGenerator t₂)).continuous
  have heq : (fun m : ℕ+ => ((t₁ m : ℂ) • shiftOp ^ (m : ℕ)) * kpGenerator t₂) =
      fun m : ℕ+ => kpGenerator t₂ * ((t₁ m : ℂ) • shiftOp ^ (m : ℕ)) := by
    funext m
    apply ContinuousLinearMap.ext; intro f
    simp only [mul_apply_eq_comp, smul_apply, map_smul]
    rw [← mul_apply_eq_comp, ← mul_apply_eq_comp, (hpow (m : ℕ)).eq]
  rw [heq] at hL
  exact hL.unique hR

lemma kpGenerator_mem_resAlg (t : KPTime) :
    kpGenerator t ∈ resAlg hardyPolarization := by
  have hS : shiftOp ∈ resAlg hardyPolarization :=
    (isCompact_commutator_J_iff hardyPolarization shiftOp).mpr shiftGLRes.2
  refine (isClosed_resAlg hardyPolarization).mem_of_tendsto (summable_kpTerms t).hasSum ?_
  filter_upwards with s
  exact Subalgebra.sum_mem _ fun n _ =>
    Subalgebra.smul_mem _ (Subalgebra.pow_mem _ hS (n : ℕ)) _

/-- **Definition (KP Hierarchy Flow):** `g(t) = exp(∑_{n ≥ 1} t_n z^n) ∈ GL_res(L²(S¹))`. -/
noncomputable def kpFlow (t : KPTime) : GLRes hardyPolarization :=
  expGLRes hardyPolarization (kpGenerator t) (kpGenerator_mem_resAlg t)

@[simp]
lemma coe_kpFlow (t : KPTime) :
    ((kpFlow t).1 : HCircle →L[ℂ] HCircle) = NormedSpace.exp (kpGenerator t) := by
  ext f; rfl

/-- **Theorem 7 (Abelian Group Law / Zero-Curvature Commutation):**
`g(0) = 1`, `g(t₁ + t₂) = g(t₁) g(t₂)`, and `g(t₁) g(t₂) = g(t₂) g(t₁)`. -/
theorem kpFlow_zero : kpFlow 0 = 1 := by
  apply Subtype.ext
  exact ContinuousLinearEquiv.ext (funext fun f => by
    change (NormedSpace.exp (kpGenerator 0) : HCircle →L[ℂ] HCircle) f = f
    rw [kpGenerator_zero, NormedSpace.exp_zero]; rfl)

theorem kpFlow_add (t₁ t₂ : KPTime) : kpFlow (t₁ + t₂) = kpFlow t₁ * kpFlow t₂ := by
  apply Subtype.ext
  exact ContinuousLinearEquiv.ext (funext fun f => by
    change (NormedSpace.exp (kpGenerator (t₁ + t₂)) : HCircle →L[ℂ] HCircle) f =
      ((NormedSpace.exp (kpGenerator t₁) : HCircle →L[ℂ] HCircle) *
        (NormedSpace.exp (kpGenerator t₂) : HCircle →L[ℂ] HCircle)) f
    rw [kpGenerator_add, clm_exp_add_of_commute (kpGenerator_commute t₁ t₂)])

theorem kpFlow_neg (t : KPTime) : kpFlow (-t) = (kpFlow t)⁻¹ := by
  apply eq_inv_of_mul_eq_one_left
  rw [← kpFlow_add, neg_add_cancel, kpFlow_zero]

theorem kpFlow_comm (t₁ t₂ : KPTime) : kpFlow t₁ * kpFlow t₂ = kpFlow t₂ * kpFlow t₁ := by
  rw [← kpFlow_add, add_comm, kpFlow_add]

/-! ### Section 3: Invariance of `H₊`, Virtual Dimension Conservation & Sato PDE -/

lemma shiftOp_pow_mem_hardyPlus (n : ℕ) {f : HCircle} (hf : f ∈ hardyPlus) :
    (shiftOp ^ n) f ∈ hardyPlus := by
  induction n with
  | zero => exact hf
  | succ n ih =>
    rw [pow_succ', mul_apply_eq_comp]
    exact shiftL2_mem_hardyPlus ih

lemma kpGenerator_mem_hardyPlus (t : KPTime) {f : HCircle} (hf : f ∈ hardyPlus) :
    kpGenerator t f ∈ hardyPlus := by
  have heval : HasSum (fun n : ℕ+ => (t n • shiftOp ^ (n : ℕ)) f) (kpGenerator t f) :=
    (summable_kpTerms t).hasSum.map (ContinuousLinearMap.apply ℂ HCircle f).toAddMonoidHom
      (ContinuousLinearMap.apply ℂ HCircle f).continuous
  refine hardyPlus_isClosed.mem_of_tendsto heval ?_
  filter_upwards with s
  exact Submodule.sum_mem _ fun n _ =>
    hardyPlus.smul_mem _ (shiftOp_pow_mem_hardyPlus (n : ℕ) hf)

lemma kpFlow_mem_hardyPlus (t : KPTime) {f : HCircle} (hf : f ∈ hardyPlus) :
    (kpFlow t).1 f ∈ hardyPlus := by
  have hpow : ∀ k : ℕ, (kpGenerator t ^ k) f ∈ hardyPlus := by
    intro k
    induction k with
    | zero => exact hf
    | succ k ih =>
      rw [pow_succ', mul_apply_eq_comp]
      exact kpGenerator_mem_hardyPlus t ih
  have htsum : HasSum (fun k : ℕ => ((k.factorial : ℂ)⁻¹ • kpGenerator t ^ k) f)
      ((kpFlow t).1 f) :=
    (hasSum_exp_terms (kpGenerator t)).map (ContinuousLinearMap.apply ℂ HCircle f).toAddMonoidHom
      (ContinuousLinearMap.apply ℂ HCircle f).continuous
  refine hardyPlus_isClosed.mem_of_tendsto htsum ?_
  filter_upwards with s
  exact Submodule.sum_mem _ fun k _ => hardyPlus.smul_mem _ (hpow k)

/-- **Theorem 8 (Zero Index & Virtual Dimension Conservation):**
`ind(g(t)_{++}) = 0` and `vdim(g(t) • W) = vdim(W)` for all `t ∈ ℓ¹(ℕ₊, ℂ)` and `W ∈ Gr_res`. -/
theorem glResIndex_kpFlow (t : KPTime) :
    glResIndex hardyPolarization (kpFlow t) = 0 := by
  let ePlus : hardyPolarization.HPlus ≃L[ℂ] hardyPolarization.HPlus :=
    { toFun := fun f => ⟨(kpFlow t).1 f.1, kpFlow_mem_hardyPlus t f.2⟩
      invFun := fun f => ⟨(kpFlow (-t)).1 f.1, kpFlow_mem_hardyPlus (-t) f.2⟩
      left_inv := fun f => by
        apply Subtype.ext
        have hmul : (kpFlow (-t) * kpFlow t).1 f.1 = f.1 := by
          rw [← kpFlow_add, neg_add_cancel, kpFlow_zero]; rfl
        exact hmul
      right_inv := fun f => by
        apply Subtype.ext
        have hmul : (kpFlow t * kpFlow (-t)).1 f.1 = f.1 := by
          rw [← kpFlow_add, add_neg_cancel, kpFlow_zero]; rfl
        exact hmul
      map_add' := fun u v => by apply Subtype.ext; exact map_add (kpFlow t).1 u.1 v.1
      map_smul' := fun c u => by apply Subtype.ext; exact map_smul (kpFlow t).1 c u.1
      continuous_toFun := ((kpFlow t).1.continuous.comp continuous_subtype_val).subtype_mk _
      continuous_invFun := ((kpFlow (-t)).1.continuous.comp continuous_subtype_val).subtype_mk _ }
  have hblock : blockPP hardyPolarization ((kpFlow t).1 : HCircle →L[ℂ] HCircle) =
      (ePlus : hardyPolarization.HPlus →L[ℂ] hardyPolarization.HPlus) := by
    apply ContinuousLinearMap.ext; intro f
    apply Subtype.ext
    change (hardyPlus.orthogonalProjectionOnto ((kpFlow t).1 f.1) : HCircle) = (kpFlow t).1 f.1
    exact congrArg Subtype.val
      (Submodule.orthogonalProjectionOnto_mem_subspace_eq_self ⟨(kpFlow t).1 f.1, kpFlow_mem_hardyPlus t f.2⟩)
  unfold glResIndex
  rw [hblock]
  exact fredholmIndex_of_equiv ePlus

theorem virtualDim_kpFlow_smul (t : KPTime) (W : SatoGr hardyPolarization) :
    virtualDim (kpFlow t • W) = virtualDim W := by
  rw [virtualDim_smul, glResIndex_kpFlow, zero_add]

/-- The vacuum basepoint `H₊` is fixed by the entire positive KP flow `Γ₊`. -/
theorem kpFlow_smul_basepoint (t : KPTime) :
    kpFlow t • basepoint hardyPolarization = basepoint hardyPolarization := by
  apply Subtype.ext
  ext f
  change f ∈ hardyPlus.map ((kpFlow t).1 : HCircle →L[ℂ] HCircle).toLinearMap ↔ f ∈ hardyPlus
  constructor
  · rintro ⟨g, hg, rfl⟩
    exact kpFlow_mem_hardyPlus t hg
  · intro hf
    refine ⟨(kpFlow (-t)).1 f, kpFlow_mem_hardyPlus (-t) hf, ?_⟩
    have hmul : (kpFlow t * kpFlow (-t)).1 f = f := by
      rw [← kpFlow_add, add_neg_cancel, kpFlow_zero]; rfl
    exact hmul

/-- **Theorem 9 (Infinitesimal Sato Evolution Equation):**
Along the `n`-th KP time coordinate `t_n`, `d/ds exp(s z^n) = z^n exp(s z^n)`. -/
theorem hasDerivAt_kpFlow_single (n : ℕ+) (s : ℂ) :
    HasDerivAt (fun r : ℂ => ((kpFlow (lp.single 1 n r)).1 : HCircle →L[ℂ] HCircle))
      (shiftOp ^ (n : ℕ) * ((kpFlow (lp.single 1 n s)).1 : HCircle →L[ℂ] HCircle)) s := by
  have hval : ∀ r : ℂ, ((kpFlow (lp.single 1 n r)).1 : HCircle →L[ℂ] HCircle) =
      NormedSpace.exp (r • shiftOp ^ (n : ℕ)) := fun r => by
    rw [coe_kpFlow, kpGenerator_single]
  have heq : (fun r : ℂ => ((kpFlow (lp.single 1 n r)).1 : HCircle →L[ℂ] HCircle)) =
      fun r : ℂ => NormedSpace.exp (r • shiftOp ^ (n : ℕ)) := funext hval
  rw [heq, hval s]
  have hcomm0 : Commute (shiftOp ^ (n : ℕ)) (s • shiftOp ^ (n : ℕ)) := by
    apply ContinuousLinearMap.ext; intro f
    simp only [mul_apply_eq_comp, smul_apply, map_smul]
  have hcomm : Commute (shiftOp ^ (n : ℕ)) (NormedSpace.exp (s • shiftOp ^ (n : ℕ))) :=
    hcomm0.exp_right
  rw [hcomm.eq]
  exact hasDerivAt_exp_smul_const (shiftOp ^ (n : ℕ)) s

/-! ### Section 4: Bridge Theorem — Equivariance of `Gr_ℂ(2, 4) ↪ Gr_res(L²(S¹))` under KP Flow -/

/-- The 4×4 nilpotent shift matrix `N` on `ℂ⁴` (`N(u₀, u₁, u₂, u₃) = (0, u₀, u₁, u₂)`). -/
noncomputable def nilpShift4 : C4 →L[ℂ] C4 :=
  LinearMap.toContinuousLinearMap
    { toFun := fun u i => match i with
        | 0 => 0
        | 1 => u 0
        | 2 => u 1
        | 3 => u 2
      map_add' := fun u v => by ext i; fin_cases i <;> simp
      map_smul' := fun c u => by ext i; fin_cases i <;> simp }

lemma nilpShift4_pow_four : nilpShift4 ^ 4 = 0 := by
  ext u i
  fin_cases i <;> simp [pow_succ, mul_apply_eq_comp, nilpShift4]

/-- The finite-dimensional KP matrix generator `t₁ N + t₂ N² + t₃ N³` on `ℂ⁴`. -/
noncomputable def kpGen4 (t : KPTime) : C4 →L[ℂ] C4 :=
  t ⟨1, by norm_num⟩ • nilpShift4 +
  t ⟨2, by norm_num⟩ • nilpShift4 ^ 2 +
  t ⟨3, by norm_num⟩ • nilpShift4 ^ 3

/-- The finite-dimensional KP matrix flow `exp(t₁ N + t₂ N² + t₃ N³) ∈ GL(ℂ⁴)`. -/
noncomputable def kpMatrix4 (t : KPTime) : C4 ≃L[ℂ] C4 :=
  expCLE (kpGen4 t)

/-- The closed subspace `V_≥-2 = { f ∈ L²(S¹) | ∀ n < -2, f̂(n) = 0 } = V₄ ⊕ H_{≥ 2}`. -/
noncomputable def hardyGeNeg2 : Submodule ℂ HCircle where
  carrier := { f : HCircle | ∀ n : ℤ, n < -2 → eBasis.repr f n = 0 }
  add_mem' ha hb n hn := by simp [ha n hn, hb n hn]
  zero_mem' _ _ := by simp
  smul_mem' c _ ha n hn := by simp [ha n hn]

lemma hardyGeNeg2_isClosed : IsClosed (hardyGeNeg2 : Set HCircle) := by
  have heq : (hardyGeNeg2 : Set HCircle) =
      ⋂ n : ℤ, ⋂ _ : n < -2, (innerSL ℂ (eBasis n)) ⁻¹' {0} := by
    ext f; simp [hardyGeNeg2, HilbertBasis.repr_apply_apply]
  rw [heq]
  exact isClosed_iInter fun n => isClosed_iInter fun _ =>
    isClosed_singleton.preimage (innerSL ℂ (eBasis n)).continuous

lemma shiftOp_mem_hardyGeNeg2 {f : HCircle} (hf : f ∈ hardyGeNeg2) :
    shiftOp f ∈ hardyGeNeg2 := fun n hn => by
  rw [show shiftOp f = shiftL2 f from rfl, repr_shiftL2]
  exact hf (n - 1) (by omega)

lemma shiftOp_pow_mem_hardyGeNeg2 (n : ℕ) {f : HCircle} (hf : f ∈ hardyGeNeg2) :
    (shiftOp ^ n) f ∈ hardyGeNeg2 := by
  induction n with
  | zero => exact hf
  | succ n ih =>
    rw [pow_succ', mul_apply_eq_comp]
    exact shiftOp_mem_hardyGeNeg2 ih

lemma windowEval_shiftOp {f : HCircle} (hf : f ∈ hardyGeNeg2) :
    windowEval (shiftOp f) = nilpShift4 (windowEval f) := by
  ext i
  fin_cases i
  · rw [windowEval_apply, show shiftOp f = shiftL2 f from rfl, repr_shiftL2]
    exact hf (-3) (by norm_num)
  · simp [windowEval_apply, shiftOp, shiftCLE, repr_shiftL2, nilpShift4]
  · simp [windowEval_apply, shiftOp, shiftCLE, repr_shiftL2, nilpShift4]
  · simp [windowEval_apply, shiftOp, shiftCLE, repr_shiftL2, nilpShift4]

lemma windowEval_shiftOp_pow (k : ℕ) {f : HCircle} (hf : f ∈ hardyGeNeg2) :
    windowEval ((shiftOp ^ k) f) = (nilpShift4 ^ k) (windowEval f) := by
  induction k with
  | zero => rfl
  | succ k ih =>
    rw [pow_succ', pow_succ', mul_apply_eq_comp, mul_apply_eq_comp,
      windowEval_shiftOp (shiftOp_pow_mem_hardyGeNeg2 k hf), ih]

lemma kpFlow_mem_hardyGeNeg2 (t : KPTime) {f : HCircle} (hf : f ∈ hardyGeNeg2) :
    (kpFlow t).1 f ∈ hardyGeNeg2 := by
  have hgen : ∀ {g : HCircle}, g ∈ hardyGeNeg2 → kpGenerator t g ∈ hardyGeNeg2 := by
    intro g hg
    have heval : HasSum (fun n : ℕ+ => (t n • shiftOp ^ (n : ℕ)) g) (kpGenerator t g) :=
      (summable_kpTerms t).hasSum.map (ContinuousLinearMap.apply ℂ HCircle g).toAddMonoidHom
        (ContinuousLinearMap.apply ℂ HCircle g).continuous
    refine hardyGeNeg2_isClosed.mem_of_tendsto heval ?_
    filter_upwards with s
    exact Submodule.sum_mem _ fun n _ =>
      hardyGeNeg2.smul_mem _ (shiftOp_pow_mem_hardyGeNeg2 (n : ℕ) hg)
  have hpow : ∀ k : ℕ, (kpGenerator t ^ k) f ∈ hardyGeNeg2 := by
    intro k
    induction k with
    | zero => exact hf
    | succ k ih => rw [pow_succ', mul_apply_eq_comp]; exact hgen ih
  have htsum : HasSum (fun k : ℕ => ((k.factorial : ℂ)⁻¹ • kpGenerator t ^ k) f) ((kpFlow t).1 f) :=
    (hasSum_exp_terms (kpGenerator t)).map (ContinuousLinearMap.apply ℂ HCircle f).toAddMonoidHom
      (ContinuousLinearMap.apply ℂ HCircle f).continuous
  refine hardyGeNeg2_isClosed.mem_of_tendsto htsum ?_
  filter_upwards with s
  exact Submodule.sum_mem _ fun k _ => hardyGeNeg2.smul_mem _ (hpow k)

lemma windowEval_kpGenerator (t : KPTime) {f : HCircle} (hf : f ∈ hardyGeNeg2) :
    windowEval (kpGenerator t f) = kpGen4 t (windowEval f) := by
  have h1 : HasSum (fun n : ℕ+ => windowEval ((t n • shiftOp ^ (n : ℕ)) f))
      (windowEval (kpGenerator t f)) :=
    ((summable_kpTerms t).hasSum.map (ContinuousLinearMap.apply ℂ HCircle f).toAddMonoidHom
      (ContinuousLinearMap.apply ℂ HCircle f).continuous).map
      windowEval.toAddMonoidHom windowEval.continuous
  have hterms : ∀ n : ℕ+, windowEval ((t n • shiftOp ^ (n : ℕ)) f) =
      t n • (nilpShift4 ^ (n : ℕ)) (windowEval f) := fun n => by
    rw [smul_apply, map_smul, windowEval_shiftOp_pow (n : ℕ) hf]
  let n1 : ℕ+ := ⟨1, by norm_num⟩
  let n2 : ℕ+ := ⟨2, by norm_num⟩
  let n3 : ℕ+ := ⟨3, by norm_num⟩
  have hzero : ∀ n : ℕ+, n ∉ ({n1, n2, n3} : Finset ℕ+) →
      windowEval ((t n • shiftOp ^ (n : ℕ)) f) = 0 := by
    intro n hn
    rw [hterms n]
    have hge4 : 4 ≤ (n : ℕ) := by
      have h1 : n ≠ n1 := fun h => hn (by simp [h])
      have h2 : n ≠ n2 := fun h => hn (by simp [h])
      have h3 : n ≠ n3 := fun h => hn (by simp [h])
      have hpos : 0 < (n : ℕ) := n.2
      have h1' : (n : ℕ) ≠ 1 := fun h => h1 (Subtype.ext h)
      have h2' : (n : ℕ) ≠ 2 := fun h => h2 (Subtype.ext h)
      have h3' : (n : ℕ) ≠ 3 := fun h => h3 (Subtype.ext h)
      omega
    obtain ⟨d, hd⟩ := Nat.exists_eq_add_of_le hge4
    rw [hd, pow_add, nilpShift4_pow_four, zero_mul, zero_apply, smul_zero]
  have hsum_fin : HasSum (fun n : ℕ+ => windowEval ((t n • shiftOp ^ (n : ℕ)) f))
      (∑ n ∈ ({n1, n2, n3} : Finset ℕ+), windowEval ((t n • shiftOp ^ (n : ℕ)) f)) :=
    hasSum_sum_of_ne_finset_zero hzero
  rw [h1.unique hsum_fin]
  have h12 : n1 ∉ ({n2, n3} : Finset ℕ+) := by simp [n1, n2, n3]
  have h23 : n2 ∉ ({n3} : Finset ℕ+) := by simp [n2, n3]
  rw [Finset.sum_insert h12, Finset.sum_insert h23, Finset.sum_singleton,
    hterms n1, hterms n2, hterms n3]
  simp only [n1, n2, n3, kpGen4, add_apply, smul_apply]
  abel

lemma windowEval_kpFlow (t : KPTime) {f : HCircle} (hf : f ∈ hardyGeNeg2) :
    windowEval ((kpFlow t).1 f) = kpMatrix4 t (windowEval f) := by
  have hpow : ∀ k : ℕ, windowEval ((kpGenerator t ^ k) f) = (kpGen4 t ^ k) (windowEval f) ∧
      (kpGenerator t ^ k) f ∈ hardyGeNeg2 := by
    intro k
    induction k with
    | zero => exact ⟨rfl, hf⟩
    | succ k ih =>
      refine ⟨?_, ?_⟩
      · rw [pow_succ', pow_succ', mul_apply_eq_comp, mul_apply_eq_comp,
          windowEval_kpGenerator t ih.2, ih.1]
      · have heval : HasSum (fun n : ℕ+ => (t n • shiftOp ^ (n : ℕ)) ((kpGenerator t ^ k) f))
            (kpGenerator t ((kpGenerator t ^ k) f)) :=
          (summable_kpTerms t).hasSum.map
            (ContinuousLinearMap.apply ℂ HCircle _).toAddMonoidHom
            (ContinuousLinearMap.apply ℂ HCircle _).continuous
        rw [pow_succ', mul_apply_eq_comp]
        refine hardyGeNeg2_isClosed.mem_of_tendsto heval ?_
        filter_upwards with s
        exact Submodule.sum_mem _ fun n _ =>
          hardyGeNeg2.smul_mem _ (shiftOp_pow_mem_hardyGeNeg2 (n : ℕ) ih.2)
  have hL : HasSum (fun k : ℕ => (k.factorial : ℂ)⁻¹ • (kpGen4 t ^ k) (windowEval f))
      (windowEval ((kpFlow t).1 f)) := by
    have h' := ((hasSum_exp_terms (kpGenerator t)).map (ContinuousLinearMap.apply ℂ HCircle f).toAddMonoidHom
      (ContinuousLinearMap.apply ℂ HCircle f).continuous).map
      windowEval.toAddMonoidHom windowEval.continuous
    refine h'.congr_fun fun k => ?_
    change (k.factorial : ℂ)⁻¹ • (kpGen4 t ^ k) (windowEval f) =
      windowEval (((k.factorial : ℂ)⁻¹ • kpGenerator t ^ k) f)
    rw [smul_apply, map_smul, (hpow k).1]
  have hR : HasSum (fun k : ℕ => (k.factorial : ℂ)⁻¹ • (kpGen4 t ^ k) (windowEval f))
      (kpMatrix4 t (windowEval f)) :=
    (hasSum_exp_terms (kpGen4 t)).map (ContinuousLinearMap.apply ℂ C4 (windowEval f)).toAddMonoidHom
      (ContinuousLinearMap.apply ℂ C4 (windowEval f)).continuous
  exact hL.unique hR

/-- **Theorem 10 (Truncation Equivariance of the KP Flow):**
The infinite-dimensional KP flow `g(t) = exp(∑ t_n z^n)` restricts to `Gr_ℂ(2, 4)`
as the nilpotent Jordan-block flow `exp(t₁ N + t₂ N² + t₃ N³)`. -/
theorem kpFlow_smul_truncEmbed (t : KPTime) (U : Gr24) :
    kpFlow t • truncEmbed U =
      truncEmbed ⟨U.1.map (kpMatrix4 t : C4 →L[ℂ] C4).toLinearMap, by
        have hEq : U.1 ≃ₗ[ℂ] U.1.map (kpMatrix4 t : C4 →L[ℂ] C4).toLinearMap :=
          (kpMatrix4 t : C4 ≃ₗ[ℂ] C4).submoduleMap U.1
        rw [← hEq.finrank_eq, U.2]⟩ := by
  apply Subtype.ext
  ext f
  change f ∈ (truncSubspace U.1).map ((kpFlow t).1 : HCircle →L[ℂ] HCircle).toLinearMap ↔
    f ∈ truncSubspace (U.1.map (kpMatrix4 t : C4 →L[ℂ] C4).toLinearMap)
  constructor
  · rintro ⟨w, ⟨hw_neg, hw_win⟩, rfl⟩
    refine ⟨kpFlow_mem_hardyGeNeg2 t hw_neg, ?_⟩
    change windowEval ((kpFlow t).1 w) ∈ _
    rw [windowEval_kpFlow t hw_neg]
    exact ⟨windowEval w, hw_win, rfl⟩
  · rintro ⟨hf_neg, ⟨u, hu, hu_eq⟩⟩
    refine ⟨(kpFlow (-t)).1 f, ⟨kpFlow_mem_hardyGeNeg2 (-t) hf_neg, ?_⟩, ?_⟩
    · rw [windowEval_kpFlow (-t) hf_neg, ← hu_eq]
      have hgen_neg : kpGen4 (-t) = -kpGen4 t := by
        ext v i; simp [kpGen4]; ring
      have hback : kpMatrix4 (-t) (kpMatrix4 t u) = u := by
        change ((NormedSpace.exp (kpGen4 (-t)) : C4 →L[ℂ] C4) *
          (NormedSpace.exp (kpGen4 t) : C4 →L[ℂ] C4)) u = u
        rw [hgen_neg, ← clm_exp_add_of_commute (Commute.neg_left (Commute.refl (kpGen4 t))),
          neg_add_cancel, NormedSpace.exp_zero]; rfl
      change kpMatrix4 (-t) (kpMatrix4 t u) ∈ U.1
      rwa [hback]
    · have hmul : (kpFlow t * kpFlow (-t)).1 f = f := by
        rw [← kpFlow_add, add_neg_cancel, kpFlow_zero]; rfl
      exact hmul

end Signals.SatoGrassmannian.KPFlow
