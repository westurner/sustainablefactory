import Mathlib.Analysis.Calculus.Deriv.Basic
import Mathlib.Analysis.Calculus.Deriv.Mul
import Mathlib.Analysis.Calculus.Deriv.Pow
import Mathlib.Analysis.Complex.Basic
import Mathlib.Analysis.Normed.Algebra.Exponential
import Mathlib.Analysis.PSeries
import Mathlib.Analysis.SpecialFunctions.Complex.Log
import Mathlib.Analysis.SpecialFunctions.Complex.LogDeriv
import Mathlib.Analysis.SpecialFunctions.Pow.Complex
import Mathlib.MeasureTheory.Integral.IntervalIntegral.FundThmCalculus
import Mathlib.Topology.Algebra.InfiniteSum.Basic
import Mathlib.Topology.Algebra.InfiniteSum.Group
import Signals.SatoGrassmannian.KPFlow
import Signals.SatoGrassmannian.RemainingGaps

open scoped BigOperators

namespace Signals.SatoGrassmannian.CarlemanWeierstrass

open Signals.SatoGrassmannian Signals.SatoGrassmannian.KPFlow
open Signals.SatoGrassmannian.RemainingGaps

/-! ============================================================================
## Section 1: Commuting Exponential Differentiation in a Complex Banach Algebra
============================================================================ -/

section BanachExpDeriv

variable {A : Type*} [NormedRing A] [NormedAlgebra ℂ A] [CompleteSpace A]

/-- Norm bound `‖exp X‖ ≤ exp ‖X‖` in any complete complex normed algebra with `‖1‖ ≤ 1`. -/
lemma norm_exp_le_exp_norm (h1 : ‖(1 : A)‖ ≤ 1) (X : A) :
    ‖NormedSpace.exp X‖ ≤ Real.exp ‖X‖ := by
  have hExp : Summable (fun n : ℕ => ‖X‖ ^ n / (n.factorial : ℝ)) :=
    Real.summable_pow_div_factorial ‖X‖
  have hTermLe : ∀ n : ℕ, ‖(n.factorial : ℂ)⁻¹ • X ^ n‖ ≤ ‖X‖ ^ n / (n.factorial : ℝ) := fun n => by
    rw [norm_smul, norm_inv, Complex.norm_natCast, inv_mul_eq_div]
    refine div_le_div_of_nonneg_right ?_ (Nat.cast_nonneg _)
    rcases Nat.eq_zero_or_pos n with rfl | hpos
    · simpa using h1
    · exact norm_pow_le' X hpos
  have hSummNorm : Summable (fun n : ℕ => ‖(n.factorial : ℂ)⁻¹ • X ^ n‖) :=
    Summable.of_nonneg_of_le (fun _ => norm_nonneg _) hTermLe hExp
  rw [← (hasSum_exp_terms X).tsum_eq]
  calc ‖∑' n : ℕ, (n.factorial : ℂ)⁻¹ • X ^ n‖
      ≤ ∑' n : ℕ, ‖(n.factorial : ℂ)⁻¹ • X ^ n‖ := norm_tsum_le_tsum_norm hSummNorm
    _ ≤ ∑' n : ℕ, ‖X‖ ^ n / (n.factorial : ℝ) :=
        Summable.tsum_le_tsum hTermLe hSummNorm hExp
    _ = Real.exp ‖X‖ := by rw [Real.exp_eq_exp_ℝ, NormedSpace.exp_eq_tsum_div]

/-- Quadratic remainder bound `‖exp u - 1 - u‖ ≤ ‖u‖² * exp ‖u‖` in any complex Banach algebra. -/
lemma norm_exp_sub_one_sub_le (u : A) :
    ‖NormedSpace.exp u - 1 - u‖ ≤ ‖u‖ ^ 2 * Real.exp ‖u‖ := by
  have hExp : HasSum (fun n : ℕ => (n.factorial : ℂ)⁻¹ • u ^ n) (NormedSpace.exp u) :=
    hasSum_exp_terms u
  have hTail : HasSum (fun k : ℕ => ((k + 2).factorial : ℂ)⁻¹ • u ^ (k + 2))
      (NormedSpace.exp u - (1 + u)) := by
    have h2 := (hasSum_nat_add_iff' 2).mpr hExp
    have hsum2 : ∑ i ∈ Finset.range 2, (i.factorial : ℂ)⁻¹ • u ^ i = 1 + u := by
      simp [Finset.sum_range_succ]
    rwa [hsum2] at h2
  have hBound : Summable (fun k : ℕ => ‖u‖ ^ 2 * (‖u‖ ^ k / (k.factorial : ℝ))) :=
    (Real.summable_pow_div_factorial ‖u‖).mul_left (‖u‖ ^ 2)
  have hTermLe : ∀ k : ℕ, ‖((k + 2).factorial : ℂ)⁻¹ • u ^ (k + 2)‖ ≤
      ‖u‖ ^ 2 * (‖u‖ ^ k / (k.factorial : ℝ)) := fun k => by
    rw [norm_smul, norm_inv, Complex.norm_natCast]
    have hfac : (k.factorial : ℝ) ≤ ((k + 2).factorial : ℝ) := by
      exact_mod_cast Nat.factorial_le (Nat.le_add_right k 2)
    have hkf : (0 : ℝ) < (k.factorial : ℝ) := by exact_mod_cast Nat.factorial_pos k
    have hpow : ‖u ^ (k + 2)‖ ≤ ‖u‖ ^ (k + 2) := norm_pow_le' u (Nat.succ_pos _)
    calc ((k + 2).factorial : ℝ)⁻¹ * ‖u ^ (k + 2)‖
        ≤ (k.factorial : ℝ)⁻¹ * ‖u‖ ^ (k + 2) :=
          mul_le_mul (inv_anti₀ hkf hfac) hpow (norm_nonneg _) (inv_nonneg.mpr hkf.le)
      _ = ‖u‖ ^ 2 * (‖u‖ ^ k / (k.factorial : ℝ)) := by rw [pow_add]; ring
  have hSummNorm : Summable (fun k : ℕ => ‖((k + 2).factorial : ℂ)⁻¹ • u ^ (k + 2)‖) :=
    Summable.of_nonneg_of_le (fun _ => norm_nonneg _) hTermLe hBound
  have hSub : NormedSpace.exp u - 1 - u = NormedSpace.exp u - (1 + u) := by abel
  rw [hSub, ← hTail.tsum_eq]
  calc ‖∑' k : ℕ, ((k + 2).factorial : ℂ)⁻¹ • u ^ (k + 2)‖
      ≤ ∑' k : ℕ, ‖((k + 2).factorial : ℂ)⁻¹ • u ^ (k + 2)‖ :=
        norm_tsum_le_tsum_norm hSummNorm
    _ ≤ ∑' k : ℕ, ‖u‖ ^ 2 * (‖u‖ ^ k / (k.factorial : ℝ)) :=
        Summable.tsum_le_tsum hTermLe hSummNorm hBound
    _ = ‖u‖ ^ 2 * ∑' k : ℕ, ‖u‖ ^ k / (k.factorial : ℝ) := tsum_mul_left
    _ = ‖u‖ ^ 2 * Real.exp ‖u‖ := by rw [Real.exp_eq_exp_ℝ, NormedSpace.exp_eq_tsum_div]

/-- Fréchet derivative of `NormedSpace.exp : A → A` at `0` over `ℝ` is the identity map. -/
lemma hasFDerivAt_exp_zero_real :
    HasFDerivAt (NormedSpace.exp : A → A) (ContinuousLinearMap.id ℝ A) 0 := by
  rw [hasFDerivAt_iff_isLittleO_nhds_zero]
  rw [Asymptotics.isLittleO_iff]
  intro c hc
  have hcont : Continuous (fun u : A => ‖u‖ * Real.exp ‖u‖) :=
    continuous_norm.mul (Real.continuous_exp.comp continuous_norm)
  have hzero : ‖(0 : A)‖ * Real.exp ‖(0 : A)‖ = 0 := by simp
  have hmem : { u : A | ‖u‖ * Real.exp ‖u‖ < c } ∈ nhds (0 : A) := by
    exact (isOpen_lt hcont continuous_const).mem_nhds (by simpa [hzero] using hc)
  filter_upwards [hmem] with u hu
  simp only [zero_add, NormedSpace.exp_zero, ContinuousLinearMap.id_apply]
  calc ‖NormedSpace.exp u - 1 - u‖
      ≤ ‖u‖ ^ 2 * Real.exp ‖u‖ := norm_exp_sub_one_sub_le u
    _ = (‖u‖ * Real.exp ‖u‖) * ‖u‖ := by ring
    _ ≤ c * ‖u‖ := mul_le_mul_of_nonneg_right hu.le (norm_nonneg u)

/-- Derivative of `t ↦ exp(g t)` along any commuting differentiable path `g : ℝ → A`. -/
lemma hasDerivAt_exp_commute {g : ℝ → A} {v : A} {t : ℝ}
    (hg : HasDerivAt g v t) (hcomm : ∀ s : ℝ, Commute (g s) (g t)) :
    HasDerivAt (fun s : ℝ => NormedSpace.exp (g s)) (v * NormedSpace.exp (g t)) t := by
  have hδ : HasDerivAt (fun s : ℝ => g s - g t) v t := hg.sub_const (g t)
  have hδ0 : g t - g t = 0 := sub_self (g t)
  have hcomp : HasDerivAt (fun s : ℝ => NormedSpace.exp (g s - g t)) v t := by
    have h := hasFDerivAt_exp_zero_real (A := A)
    rw [← hδ0] at h
    exact h.comp_hasDerivAt t hδ
  have hmul : HasDerivAt
      (fun s : ℝ => NormedSpace.exp (g s - g t) * NormedSpace.exp (g t))
      (v * NormedSpace.exp (g t)) t :=
    hcomp.mul_const (NormedSpace.exp (g t))
  refine hmul.congr_of_eventuallyEq (Filter.Eventually.of_forall fun s => ?_)
  dsimp only
  have hc : Commute (g s - g t) (g t) := (hcomm s).sub_left rfl
  let _ : NormedAlgebra ℚ A := NormedAlgebra.restrictScalars ℚ ℂ A
  rw [← NormedSpace.exp_add_of_commute hc, sub_add_cancel]

/-- Commutativity lifts through `NormedSpace.exp`. -/
lemma commute_exp_right {X Y : A} (h : Commute X Y) :
    Commute X (NormedSpace.exp Y) := by
  have hSum := hasSum_exp_terms Y
  have hL : HasSum (fun n : ℕ => X * ((n.factorial : ℂ)⁻¹ • Y ^ n)) (X * NormedSpace.exp Y) :=
    hSum.mul_left X
  have hR : HasSum (fun n : ℕ => ((n.factorial : ℂ)⁻¹ • Y ^ n) * X) (NormedSpace.exp Y * X) :=
    hSum.mul_right X
  have heq : (fun n : ℕ => X * ((n.factorial : ℂ)⁻¹ • Y ^ n)) =
      fun n : ℕ => ((n.factorial : ℂ)⁻¹ • Y ^ n) * X := by
    funext n
    rw [Algebra.mul_smul_comm, Algebra.smul_mul_assoc, (h.pow_right n).eq]
  rw [heq] at hL
  exact hL.unique hR

end BanachExpDeriv

/-! ============================================================================
## Section 2: Order-`k` Weierstrass–Carleman Factors `E_k(K)` & Sharp Bound
============================================================================ -/

section WeierstrassCarleman

variable {A : Type*} [NormedRing A] [NormedAlgebra ℂ A] [CompleteSpace A]

/-- Truncated logarithm polynomial `P_k(K) = ∑_{m=1}^{k-1} ((-1)^m / m) K^m`. -/
noncomputable def weierstrassPoly (k : ℕ) (K : A) : A :=
  ∑ m ∈ Finset.Ico 1 k, (((-1 : ℂ) ^ m / (m : ℂ)) • K ^ m)

/-- Derivative polynomial `P_k'(t, K) = ∑_{m=1}^{k-1} (-1)^m t^{m-1} K^m`. -/
noncomputable def weierstrassPolyDeriv (k : ℕ) (t : ℝ) (K : A) : A :=
  ∑ m ∈ Finset.Ico 1 k, (((-1 : ℂ) ^ m * (t : ℂ) ^ (m - 1)) • K ^ m)

/-- Order-`k` Weierstrass–Carleman factor `E_k(K) = (1 + K) exp(P_k(K))`. -/
noncomputable def weierstrassFactor (k : ℕ) (K : A) : A :=
  (1 + K) * NormedSpace.exp (weierstrassPoly k K)

/-- Order-`k` Carleman remainder `R_k(K) = E_k(K) - 1`. -/
noncomputable def weierstrassRemainder (k : ℕ) (K : A) : A :=
  weierstrassFactor k K - 1

/-- Real exponent majorant `Q_k(r) = ∑_{m=1}^{k-1} r^m / m`. -/
noncomputable def weierstrassExpBound (k : ℕ) (r : ℝ) : ℝ :=
  ∑ m ∈ Finset.Ico 1 k, r ^ m / (m : ℝ)

omit [CompleteSpace A] in
lemma weierstrassFactor_one (K : A) : weierstrassFactor 1 K = 1 + K := by
  simp [weierstrassFactor, weierstrassPoly]

omit [CompleteSpace A] in
lemma weierstrassFactor_two (K : A) :
    weierstrassFactor 2 K = (1 + K) * NormedSpace.exp (-K) := by
  unfold weierstrassFactor weierstrassPoly
  have hIco : Finset.Ico 1 2 = {1} := by decide
  rw [hIco, Finset.sum_singleton]
  simp

omit [CompleteSpace A] in
lemma weierstrassFactor_three (K : A) :
    weierstrassFactor 3 K = (1 + K) * NormedSpace.exp (-K + (1 / 2 : ℂ) • K ^ 2) := by
  unfold weierstrassFactor weierstrassPoly
  have hIco : Finset.Ico 1 3 = {1, 2} := by decide
  rw [hIco, Finset.sum_pair (by decide)]
  congr 2
  norm_num

omit [CompleteSpace A] in
lemma weierstrassPoly_smul (k : ℕ) (c : ℂ) (K : A) :
    weierstrassPoly k (c • K) =
      ∑ m ∈ Finset.Ico 1 k, (((-1 : ℂ) ^ m / (m : ℂ)) * c ^ m) • K ^ m := by
  unfold weierstrassPoly
  refine Finset.sum_congr rfl fun m _ => ?_
  rw [smul_pow, smul_smul]

omit [CompleteSpace A] in
lemma commute_weierstrassPoly_left (k : ℕ) (c : ℂ) (K : A) :
    Commute K (weierstrassPoly k (c • K)) := by
  rw [weierstrassPoly_smul]
  refine Commute.sum_right _ _ _ fun m _ => ?_
  exact (Commute.pow_right rfl m).smul_right _

omit [CompleteSpace A] in
lemma commute_weierstrassPoly_smul (k : ℕ) (c₁ c₂ : ℂ) (K : A) :
    Commute (weierstrassPoly k (c₁ • K)) (weierstrassPoly k (c₂ • K)) := by
  rw [weierstrassPoly_smul, weierstrassPoly_smul]
  refine Commute.sum_left _ _ _ fun m _ => Commute.sum_right _ _ _ fun n _ => ?_
  exact ((Commute.pow_pow rfl m n).smul_left _).smul_right _

omit [CompleteSpace A] in
/-- Exact telescoping algebraic identity:
`K + (1 + t K) P_k'(t, K) = (-1)^(k-1) t^(k-1) K^k` for all `k ≥ 1`. -/
lemma telescoping_weierstrassDeriv {k : ℕ} (hk : 1 ≤ k) (t : ℝ) (K : A) :
    K + (1 + (t : ℂ) • K) * weierstrassPolyDeriv k t K =
      ((-1 : ℂ) ^ (k - 1) * (t : ℂ) ^ (k - 1)) • K ^ k := by
  obtain ⟨n, rfl⟩ := Nat.exists_eq_add_of_le' hk
  induction n with
  | zero =>
    simp [weierstrassPolyDeriv]
  | succ n ih =>
    have hsplit : weierstrassPolyDeriv (n + 1 + 1) t K =
        weierstrassPolyDeriv (n + 1) t K +
          ((-1 : ℂ) ^ (n + 1) * (t : ℂ) ^ n) • K ^ (n + 1) := by
      unfold weierstrassPolyDeriv
      rw [Finset.sum_Ico_succ_top (by omega : 1 ≤ n + 1)]
      simp
    rw [hsplit, mul_add, ← add_assoc, ih (by omega)]
    have h1 : (1 + (t : ℂ) • K) * (((-1 : ℂ) ^ (n + 1) * (t : ℂ) ^ n) • K ^ (n + 1)) =
        ((-1 : ℂ) ^ (n + 1) * (t : ℂ) ^ n) • K ^ (n + 1) +
        ((-1 : ℂ) ^ (n + 1) * (t : ℂ) ^ (n + 1)) • K ^ (n + 1 + 1) := by
      rw [add_mul, one_mul, Algebra.smul_mul_assoc, Algebra.mul_smul_comm, smul_smul]
      congr 1
      have hpow : K * K ^ (n + 1) = K ^ (n + 1 + 1) := (pow_succ' K (n + 1)).symm
      rw [hpow]
      congr 1
      rw [pow_succ']; ring
    rw [h1, ← add_assoc, ← add_smul]
    have hcancel : (-1 : ℂ) ^ n * (t : ℂ) ^ n + (-1 : ℂ) ^ (n + 1) * (t : ℂ) ^ n = 0 := by
      rw [pow_succ]; ring
    simp [hcancel]

omit [CompleteSpace A] in
lemma hasDerivAt_weierstrassPoly_path (k : ℕ) (K : A) (t : ℝ) :
    HasDerivAt (fun s : ℝ => weierstrassPoly k ((s : ℂ) • K))
      (weierstrassPolyDeriv k t K) t := by
  have heq : (fun s : ℝ => weierstrassPoly k ((s : ℂ) • K)) =
      fun s : ℝ => ∑ m ∈ Finset.Ico 1 k, (((-1 : ℂ) ^ m / (m : ℂ)) * (s : ℂ) ^ m) • K ^ m := by
    funext s; exact weierstrassPoly_smul k (s : ℂ) K
  rw [heq]
  unfold weierstrassPolyDeriv
  refine HasDerivAt.fun_sum fun m hm => ?_
  have hm1 : 1 ≤ m := (Finset.mem_Ico.mp hm).1
  have hm_ne : (m : ℂ) ≠ 0 := by exact_mod_cast (show m ≠ 0 by omega)
  let L : ℂ →L[ℂ] A := ContinuousLinearMap.smulRight (1 : ℂ →L[ℂ] ℂ) (K ^ m)
  have hpow : HasDerivAt (fun s : ℝ => ((-1 : ℂ) ^ m / (m : ℂ)) * (s : ℂ) ^ m)
      (((-1 : ℂ) ^ m / (m : ℂ)) * ((m : ℂ) * (t : ℂ) ^ (m - 1))) t := by
    have h1 : HasDerivAt (fun s : ℝ => (s : ℂ) ^ m) ((m : ℂ) * (t : ℂ) ^ (m - 1)) t := by
      have h := (hasDerivAt_pow m (t : ℂ)).comp_ofReal
      simpa using h
    exact h1.const_mul ((-1 : ℂ) ^ m / (m : ℂ))
  have hcomp := (L.restrictScalars ℝ).hasFDerivAt.comp_hasDerivAt t hpow
  convert hcomp using 1
  · funext s; rfl
  · change ((-1 : ℂ) ^ m * (t : ℂ) ^ (m - 1)) • K ^ m =
      ((-1 : ℂ) ^ m / (m : ℂ) * ((m : ℂ) * (t : ℂ) ^ (m - 1))) • K ^ m
    congr 1
    field_simp [hm_ne]

/-- **Theorem 2.1 (Exact Order-`k` Weierstrass ODE):**
For `k ≥ 1`, `d/dt E_k(t K) = (-1)^(k-1) t^(k-1) exp(P_k(t K)) K^k`. -/
theorem hasDerivAt_weierstrassFactor_path {k : ℕ} (hk : 1 ≤ k) (K : A) (t : ℝ) :
    HasDerivAt (fun s : ℝ => weierstrassFactor k ((s : ℂ) • K))
      (((-1 : ℂ) ^ (k - 1) * (t : ℂ) ^ (k - 1)) •
        (NormedSpace.exp (weierstrassPoly k ((t : ℂ) • K)) * K ^ k)) t := by
  let L : ℂ →L[ℂ] A := ContinuousLinearMap.smulRight (1 : ℂ →L[ℂ] ℂ) K
  have hlin : HasDerivAt (fun s : ℝ => 1 + (s : ℂ) • K) K t := by
    have h1 := (L.restrictScalars ℝ).hasFDerivAt.comp_hasDerivAt t Complex.ofRealCLM.hasDerivAt
    have h2 := (hasDerivAt_const t (1 : A)).add h1
    convert h2 using 1
    · funext s; rfl
    · change K = 0 + (1 : ℂ) • K; simp
  have hexp : HasDerivAt (fun s : ℝ => NormedSpace.exp (weierstrassPoly k ((s : ℂ) • K)))
      (weierstrassPolyDeriv k t K * NormedSpace.exp (weierstrassPoly k ((t : ℂ) • K))) t :=
    hasDerivAt_exp_commute (hasDerivAt_weierstrassPoly_path k K t)
      (fun s => commute_weierstrassPoly_smul k (s : ℂ) (t : ℂ) K)
  have hprod := hlin.mul hexp
  convert hprod using 1
  · funext s; rfl
  · have hcomm : Commute (K ^ k) (NormedSpace.exp (weierstrassPoly k ((t : ℂ) • K))) :=
      commute_exp_right ((commute_weierstrassPoly_left k (t : ℂ) K).pow_left k)
    calc ((-1 : ℂ) ^ (k - 1) * (t : ℂ) ^ (k - 1)) •
          (NormedSpace.exp (weierstrassPoly k ((t : ℂ) • K)) * K ^ k)
        = ((-1 : ℂ) ^ (k - 1) * (t : ℂ) ^ (k - 1)) •
          (K ^ k * NormedSpace.exp (weierstrassPoly k ((t : ℂ) • K))) := by rw [hcomm.eq]
      _ = (((-1 : ℂ) ^ (k - 1) * (t : ℂ) ^ (k - 1)) • K ^ k) *
          NormedSpace.exp (weierstrassPoly k ((t : ℂ) • K)) := by rw [Algebra.smul_mul_assoc]
      _ = (K + (1 + (t : ℂ) • K) * weierstrassPolyDeriv k t K) *
          NormedSpace.exp (weierstrassPoly k ((t : ℂ) • K)) := by rw [telescoping_weierstrassDeriv hk t K]
      _ = K * NormedSpace.exp (weierstrassPoly k ((t : ℂ) • K)) +
          (1 + (t : ℂ) • K) *
            (weierstrassPolyDeriv k t K * NormedSpace.exp (weierstrassPoly k ((t : ℂ) • K))) := by
          rw [add_mul, mul_assoc]

/-- Integral tail operator `B_k(K) = (-1)^(k-1) ∫₀¹ t^(k-1) exp(P_k(t K)) dt`. -/
noncomputable def weierstrassTail (k : ℕ) (K : A) : A :=
  ∫ t in (0 : ℝ)..1,
    ((-1 : ℂ) ^ (k - 1) * (t : ℂ) ^ (k - 1)) • NormedSpace.exp (weierstrassPoly k ((t : ℂ) • K))

lemma continuous_weierstrassTail_integrand (k : ℕ) (K : A) :
    Continuous (fun t : ℝ =>
      ((-1 : ℂ) ^ (k - 1) * (t : ℂ) ^ (k - 1)) •
        NormedSpace.exp (weierstrassPoly k ((t : ℂ) • K))) := by
  have hpoly : Continuous (fun t : ℝ => weierstrassPoly k ((t : ℂ) • K)) := by
    have heq : (fun t : ℝ => weierstrassPoly k ((t : ℂ) • K)) =
        fun t : ℝ => ∑ m ∈ Finset.Ico 1 k, (((-1 : ℂ) ^ m / (m : ℂ)) * (t : ℂ) ^ m) • K ^ m := by
      funext t; exact weierstrassPoly_smul k (t : ℂ) K
    rw [heq]
    exact continuous_finsetSum _ fun m _ =>
      (continuous_const.mul (Complex.continuous_ofReal.pow m)).smul continuous_const
  let _ : NormedAlgebra ℚ A := NormedAlgebra.restrictScalars ℚ ℂ A
  exact (continuous_const.mul (Complex.continuous_ofReal.pow (k - 1))).smul
    (NormedSpace.exp_continuous.comp hpoly)

/-- **Theorem 2.2 (Exact `K^k` Factorization):**
For every `k ≥ 1`, `R_k(K) = B_k(K) * K^k`. -/
theorem weierstrassRemainder_eq_tail_mul_pow {k : ℕ} (hk : 1 ≤ k) (K : A) :
    weierstrassRemainder k K = weierstrassTail k K * K ^ k := by
  let mulRk : A →L[ℝ] A :=
    ((ContinuousLinearMap.mul ℂ A).flip (K ^ k)).restrictScalars ℝ
  have hInt : IntervalIntegrable (fun t : ℝ =>
      ((-1 : ℂ) ^ (k - 1) * (t : ℂ) ^ (k - 1)) •
        (NormedSpace.exp (weierstrassPoly k ((t : ℂ) • K)) * K ^ k))
      MeasureTheory.volume 0 1 := by
    have hcont : Continuous (fun t : ℝ =>
        mulRk (((-1 : ℂ) ^ (k - 1) * (t : ℂ) ^ (k - 1)) •
          NormedSpace.exp (weierstrassPoly k ((t : ℂ) • K)))) :=
      mulRk.continuous.comp (continuous_weierstrassTail_integrand k K)
    refine hcont.intervalIntegrable 0 1 |>.congr fun t _ => ?_
    simp [mulRk]
  have hFTC := intervalIntegral.integral_eq_sub_of_hasDerivAt
    (fun t _ => hasDerivAt_weierstrassFactor_path hk K t) hInt
  have h0 : weierstrassFactor k ((0 : ℂ) • K) = 1 := by
    unfold weierstrassFactor
    rw [weierstrassPoly_smul, zero_smul, add_zero, one_mul]
    have hzero : ∑ m ∈ Finset.Ico 1 k, (((-1 : ℂ) ^ m / (m : ℂ)) * (0 : ℂ) ^ m) • K ^ m = 0 := by
      refine Finset.sum_eq_zero fun m hm => ?_
      have hm1 : m ≠ 0 := by have := (Finset.mem_Ico.mp hm).1; omega
      simp [zero_pow hm1]
    rw [hzero, NormedSpace.exp_zero]
  have h1 : weierstrassFactor k ((1 : ℂ) • K) = weierstrassFactor k K := by rw [one_smul]
  have hLHS : weierstrassRemainder k K =
      ∫ t in (0 : ℝ)..1,
        mulRk (((-1 : ℂ) ^ (k - 1) * (t : ℂ) ^ (k - 1)) •
          NormedSpace.exp (weierstrassPoly k ((t : ℂ) • K))) := by
    unfold weierstrassRemainder
    rw [← h1, ← h0]
    simpa [mulRk, Algebra.smul_mul_assoc] using hFTC.symm
  rw [hLHS, mulRk.intervalIntegral_comp_comm
    ((continuous_weierstrassTail_integrand k K).intervalIntegrable 0 1)]
  rfl

/-- **Theorem 2.3 (Universal Sharp Order-`k` Carleman Norm Bound):**
For every `k ≥ 1` and `K ∈ A` (with `‖1‖ ≤ 1`),
`‖E_k(K) - 1‖ ≤ (1 / k) * ‖K‖^k * exp(∑_{m=1}^{k-1} ‖K‖^m / m)`. -/
theorem norm_weierstrassRemainder_le (h1 : ‖(1 : A)‖ ≤ 1) {k : ℕ} (hk : 1 ≤ k) (K : A) :
    ‖weierstrassRemainder k K‖ ≤
      (1 / (k : ℝ)) * ‖K‖ ^ k * Real.exp (weierstrassExpBound k ‖K‖) := by
  rw [weierstrassRemainder_eq_tail_mul_pow hk K]
  have hpow : ‖K ^ k‖ ≤ ‖K‖ ^ k := norm_pow_le' K (by omega)
  have hTailBound : ‖weierstrassTail k K‖ ≤
      (1 / (k : ℝ)) * Real.exp (weierstrassExpBound k ‖K‖) := by
    unfold weierstrassTail
    have hnorm_le : ‖∫ t in (0 : ℝ)..1,
        ((-1 : ℂ) ^ (k - 1) * (t : ℂ) ^ (k - 1)) •
          NormedSpace.exp (weierstrassPoly k ((t : ℂ) • K))‖ ≤
        ∫ t in (0 : ℝ)..1,
          ‖((-1 : ℂ) ^ (k - 1) * (t : ℂ) ^ (k - 1)) •
            NormedSpace.exp (weierstrassPoly k ((t : ℂ) • K))‖ :=
      intervalIntegral.norm_integral_le_integral_norm zero_le_one
    have hmono : ∫ t in (0 : ℝ)..1,
          ‖((-1 : ℂ) ^ (k - 1) * (t : ℂ) ^ (k - 1)) •
            NormedSpace.exp (weierstrassPoly k ((t : ℂ) • K))‖ ≤
        ∫ t in (0 : ℝ)..1, t ^ (k - 1) * Real.exp (weierstrassExpBound k ‖K‖) := by
      refine intervalIntegral.integral_mono_on zero_le_one
        ((continuous_weierstrassTail_integrand k K).norm.intervalIntegrable 0 1)
        (((continuous_id.pow (k - 1)).mul continuous_const).intervalIntegrable 0 1)
        fun t ht => ?_
      have ht0 : 0 ≤ t := ht.1
      have ht1 : t ≤ 1 := ht.2
      rw [norm_smul, norm_mul, norm_pow, norm_neg, norm_one, one_pow, one_mul,
        norm_pow, Complex.norm_real, Real.norm_eq_abs, abs_of_nonneg ht0]
      refine mul_le_mul_of_nonneg_left ?_ (pow_nonneg ht0 _)
      refine le_trans (norm_exp_le_exp_norm h1 _) (Real.exp_le_exp.mpr ?_)
      rw [weierstrassPoly_smul]
      unfold weierstrassExpBound
      refine le_trans (norm_sum_le _ _) (Finset.sum_le_sum fun m hm => ?_)
      have hm1 : 1 ≤ m := (Finset.mem_Ico.mp hm).1
      rw [norm_smul, norm_mul, norm_div, norm_pow, norm_neg, norm_one, one_pow,
        Complex.norm_natCast, norm_pow, Complex.norm_real, Real.norm_eq_abs, abs_of_nonneg ht0]
      have htm : t ^ m ≤ 1 := pow_le_one₀ ht0 ht1
      have hKm : ‖K ^ m‖ ≤ ‖K‖ ^ m := norm_pow_le' K (by omega)
      calc (1 / (m : ℝ)) * t ^ m * ‖K ^ m‖
          ≤ (1 / (m : ℝ)) * 1 * ‖K‖ ^ m := by
            refine mul_le_mul (mul_le_mul_of_nonneg_left htm (by positivity)) hKm
              (norm_nonneg _) (by positivity)
        _ = ‖K‖ ^ m / (m : ℝ) := by ring
    have hpow_int : ∫ t in (0 : ℝ)..1, t ^ (k - 1) * Real.exp (weierstrassExpBound k ‖K‖) =
        (1 / (k : ℝ)) * Real.exp (weierstrassExpBound k ‖K‖) := by
      rw [intervalIntegral.integral_mul_const]
      have hk1 : (k - 1) + 1 = k := by omega
      have hderiv : ∀ t ∈ Set.uIcc (0 : ℝ) 1,
          HasDerivAt (fun s : ℝ => s ^ k / (k : ℝ)) (t ^ (k - 1)) t := fun t _ => by
        have hk_ne : (k : ℝ) ≠ 0 := by exact_mod_cast (show k ≠ 0 by omega)
        convert (hasDerivAt_pow k t).div_const (k : ℝ) using 1
        field_simp [hk_ne]
      have hIntPow : ∫ t in (0 : ℝ)..1, t ^ (k - 1) = (1 / (k : ℝ)) := by
        rw [intervalIntegral.integral_eq_sub_of_hasDerivAt hderiv
          ((continuous_id.pow (k - 1)).intervalIntegrable 0 1)]
        rw [one_pow, zero_pow (by omega), zero_div, sub_zero]
      rw [hIntPow]
    linarith
  calc ‖weierstrassTail k K * K ^ k‖
      ≤ ‖weierstrassTail k K‖ * ‖K ^ k‖ := norm_mul_le _ _
    _ ≤ ((1 / (k : ℝ)) * Real.exp (weierstrassExpBound k ‖K‖)) * ‖K‖ ^ k :=
        mul_le_mul hTailBound hpow (norm_nonneg _) (by positivity)
    _ = (1 / (k : ℝ)) * ‖K‖ ^ k * Real.exp (weierstrassExpBound k ‖K‖) := by ring

end WeierstrassCarleman

section OperatorSchattenAndAdelic

variable {ι : Type*} {H : Type*}
  [NormedAddCommGroup H] [InnerProductSpace ℂ H] [CompleteSpace H]

omit [CompleteSpace H] in
/-- Left-ideal closure of trace-class operators `ℐ₁ = ℐ₂ · ℐ₂`. -/
lemma isTraceClass_mul_left {e : HilbertBasis ι ℂ H} {T : H →L[ℂ] H}
    (hT : IsTraceClass e T) (C : H →L[ℂ] H) :
    IsTraceClass e (C * T) := by
  rcases hT with ⟨A, B, hA, hB, rfl⟩
  exact ⟨C * A, B, hA.mul_left C, hB, (mul_assoc C A B).symm⟩

/-- **Theorem 2.4 (Schatten-`k` Trace-Class Lifting):**
Whenever `K^k ∈ ℐ₁` (which holds automatically for any Hilbert–Schmidt `K` when `k ≥ 2`),
the order-`k` Carleman remainder `E_k(K) - 1` lies in the trace-class ideal `ℐ₁`. -/
theorem weierstrassRemainder_isTraceClass {e : HilbertBasis ι ℂ H} {k : ℕ} (hk : 1 ≤ k)
    {K : H →L[ℂ] H} (hKk : IsTraceClass e (K ^ k)) :
    IsTraceClass e (weierstrassRemainder k K) := by
  rw [weierstrassRemainder_eq_tail_mul_pow hk K]
  exact isTraceClass_mul_left hKk (weierstrassTail k K)

/-- **Theorem 2.5 (Adelic Order-`k` Convergence in `𝒜_res(H)` for `Re(s) > 1/k`):**
For any `k ≥ 1` and any local prime transfer family `K_n ∈ 𝒜_res(H)` obeying
`‖K_n‖ ≤ C n^(-σ)` with `σ > 1/k`, the regularized sum `∑ (E_k(K_n) - 1)` converges
unconditionally in operator norm inside `𝒜_res(H)`. -/
theorem adelicWeierstrass_summable_mem_resAlg
    (P : PolarizedHilbertSpace ℂ H) (K : ℕ → (H →L[ℂ] H))
    {k : ℕ} (hk : 1 ≤ k) {C σ : ℝ} (hC : 0 ≤ C) (hσ : (1 / (k : ℝ)) < σ)
    (hMem : ∀ n, K n ∈ resAlg P)
    (hZero : K 0 = 0)
    (hBound : ∀ n : ℕ, 0 < n → ‖K n‖ ≤ C * ((n : ℝ) ^ σ)⁻¹) :
    Summable (fun n : ℕ => weierstrassRemainder k (K n)) ∧
    (∑' n : ℕ, weierstrassRemainder k (K n)) ∈ resAlg P := by
  have hk_pos : (0 : ℝ) < (k : ℝ) := by exact_mod_cast hk
  have hkσ : 1 < (k : ℝ) * σ := by
    have h1 := (div_lt_iff₀ hk_pos).mp hσ
    linarith
  have hσ_pos : 0 < σ := lt_trans (by positivity) hσ
  let M : ℝ := (1 / (k : ℝ)) * C ^ k * Real.exp (weierstrassExpBound k C)
  have hPSeries : Summable (fun n : ℕ => M * ((n : ℝ) ^ ((k : ℝ) * σ))⁻¹) :=
    (Real.summable_nat_rpow_inv.mpr hkσ).mul_left M
  have hSumm : Summable (fun n : ℕ => weierstrassRemainder k (K n)) := by
    refine Summable.of_norm_bounded hPSeries fun n => ?_
    rcases Nat.eq_zero_or_pos n with rfl | hpos
    · have hR0 : weierstrassRemainder k (K 0) = 0 := by
        rw [hZero]; unfold weierstrassRemainder weierstrassFactor weierstrassPoly
        have hsum0 : ∑ m ∈ Finset.Ico 1 k, (((-1 : ℂ) ^ m / (m : ℂ)) • (0 : H →L[ℂ] H) ^ m) = 0 := by
          refine Finset.sum_eq_zero fun m hm => ?_
          have hm0 : m ≠ 0 := by have := (Finset.mem_Ico.mp hm).1; omega
          simp [zero_pow hm0]
        rw [hsum0, NormedSpace.exp_zero]; simp
      rw [hR0, norm_zero]
      exact mul_nonneg (by positivity) (inv_nonneg.mpr (Real.rpow_nonneg (Nat.cast_nonneg 0) _))
    · have hn1 : (1 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hpos
      have hn_rpow_ge1 : (1 : ℝ) ≤ (n : ℝ) ^ σ := Real.one_le_rpow hn1 hσ_pos.le
      have hKn_le_C : ‖K n‖ ≤ C := by
        calc ‖K n‖ ≤ C * ((n : ℝ) ^ σ)⁻¹ := hBound n hpos
          _ ≤ C * 1 := mul_le_mul_of_nonneg_left (inv_le_one_of_one_le₀ hn_rpow_ge1) hC
          _ = C := mul_one C
      have hExp_mono : weierstrassExpBound k ‖K n‖ ≤ weierstrassExpBound k C :=
        Finset.sum_le_sum fun m _ =>
          div_le_div_of_nonneg_right (pow_le_pow_left₀ (norm_nonneg _) hKn_le_C m) (Nat.cast_nonneg _)
      have hKn_pow : ‖K n‖ ^ k ≤ C ^ k * ((n : ℝ) ^ ((k : ℝ) * σ))⁻¹ := by
        calc ‖K n‖ ^ k
            ≤ (C * ((n : ℝ) ^ σ)⁻¹) ^ k := pow_le_pow_left₀ (norm_nonneg _) (hBound n hpos) k
          _ = C ^ k * (((n : ℝ) ^ σ) ^ k)⁻¹ := by rw [mul_pow, inv_pow]
          _ = C ^ k * ((n : ℝ) ^ ((k : ℝ) * σ))⁻¹ := by
              congr 2
              rw [← Real.rpow_natCast ((n : ℝ) ^ σ) k, ← Real.rpow_mul (Nat.cast_nonneg n), mul_comm]
      calc ‖weierstrassRemainder k (K n)‖
          ≤ (1 / (k : ℝ)) * ‖K n‖ ^ k * Real.exp (weierstrassExpBound k ‖K n‖) :=
            norm_weierstrassRemainder_le ContinuousLinearMap.norm_id_le hk (K n)
        _ ≤ (1 / (k : ℝ)) * (C ^ k * ((n : ℝ) ^ ((k : ℝ) * σ))⁻¹) * Real.exp (weierstrassExpBound k C) := by
            refine mul_le_mul ?_ (Real.exp_le_exp.mpr hExp_mono) (Real.exp_pos _).le (by positivity)
            exact mul_le_mul_of_nonneg_left hKn_pow (by positivity)
        _ = M * ((n : ℝ) ^ ((k : ℝ) * σ))⁻¹ := by dsimp [M]; ring
  refine ⟨hSumm, ?_⟩
  refine (isClosed_resAlg P).mem_of_tendsto hSumm.hasSum ?_
  filter_upwards with s
  refine Subalgebra.sum_mem (resAlg P) fun n _ => ?_
  unfold weierstrassRemainder weierstrassFactor
  have hPolyMem : weierstrassPoly k (K n) ∈ resAlg P :=
    Subalgebra.sum_mem (resAlg P) fun m _ =>
      Subalgebra.smul_mem (resAlg P) (Subalgebra.pow_mem (resAlg P) (hMem n) m) _
  exact Subalgebra.sub_mem (resAlg P)
    (Subalgebra.mul_mem (resAlg P)
      (Subalgebra.add_mem (resAlg P) (Subalgebra.one_mem _) (hMem n))
      (exp_mem_resAlg P hPolyMem))
    (Subalgebra.one_mem _)

/-- **Corollary 2.6 (Critical-Line Convergence at `k = 3`):**
Order-3 Weierstrass–Carleman regularized transfers `(1 + K_n) exp(-K_n + K_n²/2) - 1`
converge unconditionally in operator norm inside `𝒜_res(H)` directly on the critical line `σ = 1/2`. -/
theorem adelicWeierstrass_critical_line_k3
    (P : PolarizedHilbertSpace ℂ H) (K : ℕ → (H →L[ℂ] H))
    {C : ℝ} (hC : 0 ≤ C)
    (hMem : ∀ n, K n ∈ resAlg P) (hZero : K 0 = 0)
    (hBound : ∀ n : ℕ, 0 < n → ‖K n‖ ≤ C * ((n : ℝ) ^ (1 / 2 : ℝ))⁻¹) :
    Summable (fun n : ℕ => weierstrassRemainder 3 (K n)) ∧
    (∑' n : ℕ, weierstrassRemainder 3 (K n)) ∈ resAlg P :=
  adelicWeierstrass_summable_mem_resAlg P K (k := 3) (by norm_num) hC
    (by norm_num : (1 / (3 : ℝ)) < 1 / 2) hMem hZero hBound

end OperatorSchattenAndAdelic

/-! ============================================================================
## Section 3: Complex Infinite Products `∏ (1 + a_i)` via FTC Log Bound
============================================================================ -/

section ComplexInfiniteProducts

/-- **Elementary Log Bound:** For `‖w‖ ≤ 1/2`, `‖Complex.log (1 + w)‖ ≤ 2 ‖w‖`. -/
lemma norm_log_one_add_le {w : ℂ} (hw : ‖w‖ ≤ 1 / 2) :
    ‖Complex.log (1 + w)‖ ≤ 2 * ‖w‖ := by
  have hre_ge : ∀ t ∈ Set.uIcc (0 : ℝ) 1, (1 / 2 : ℝ) ≤ (1 + (t : ℂ) * w).re := by
    intro t ht
    rw [Set.uIcc_of_le zero_le_one] at ht
    have hre_le : -‖w‖ ≤ w.re := neg_le.mp (le_trans (neg_le_abs w.re) (Complex.abs_re_le_norm w))
    simp only [Complex.add_re, Complex.one_re, Complex.mul_re, Complex.ofReal_re,
      Complex.ofReal_im, zero_mul, sub_zero]
    nlinarith [ht.1, ht.2, norm_nonneg w]
  have hnorm_ge : ∀ t ∈ Set.uIcc (0 : ℝ) 1, (1 / 2 : ℝ) ≤ ‖1 + (t : ℂ) * w‖ := fun t ht =>
    le_trans (hre_ge t ht) (Complex.re_le_norm _)
  have hderiv : ∀ t ∈ Set.uIcc (0 : ℝ) 1,
      HasDerivAt (fun s : ℝ => Complex.log (1 + (s : ℂ) * w)) (w / (1 + (t : ℂ) * w)) t := by
    intro t ht
    have hslit : 1 + (t : ℂ) * w ∈ Complex.slitPlane :=
      Or.inl (lt_of_lt_of_le (by norm_num) (hre_ge t ht))
    have hlin : HasDerivAt (fun s : ℝ => 1 + (s : ℂ) * w) w t := by
      have h := (hasDerivAt_const t (1 : ℂ)).add (Complex.ofRealCLM.hasDerivAt.mul_const w)
      convert h using 1
      · funext s; simp only [Pi.add_apply]; rfl
      · simp [Complex.ofRealCLM_apply]
    have hlog := (Complex.hasDerivAt_log hslit).comp t hlin
    convert hlog using 1
    · rfl
    · ring
  have hInt : IntervalIntegrable (fun t : ℝ => w / (1 + (t : ℂ) * w)) MeasureTheory.volume 0 1 := by
    refine ContinuousOn.intervalIntegrable ?_
    refine continuousOn_const.div
      ((continuous_const.add (Complex.continuous_ofReal.mul continuous_const)).continuousOn) ?_
    intro t ht
    exact norm_ne_zero_iff.mp (by linarith [hnorm_ge t ht])
  have hFTC := intervalIntegral.integral_eq_sub_of_hasDerivAt hderiv hInt
  simp only [Complex.ofReal_one, one_mul, Complex.ofReal_zero, zero_mul, add_zero,
    Complex.log_one, sub_zero] at hFTC
  rw [← hFTC]
  have hbound := intervalIntegral.norm_integral_le_of_norm_le_const (C := 2 * ‖w‖)
    (a := (0 : ℝ)) (b := 1) (f := fun t : ℝ => w / (1 + (t : ℂ) * w)) fun t ht => by
      have ht' : t ∈ Set.uIcc (0 : ℝ) 1 := by
        rw [Set.uIcc_of_le zero_le_one]
        rw [Set.mem_uIoc] at ht
        rcases ht with ⟨h0, h1⟩ | ⟨h0, h1⟩
        · exact ⟨h0.le, h1⟩
        · linarith
      rw [norm_div]
      have hpos : (0 : ℝ) < ‖1 + (t : ℂ) * w‖ := lt_of_lt_of_le (by norm_num) (hnorm_ge t ht')
      rw [div_le_iff₀ hpos]
      nlinarith [hnorm_ge t ht', norm_nonneg w]
  simpa using hbound

/-- **Theorem 3.1 (Absolute Convergence & Explicit Product Formula for `∏ (1 + a_i)`):**
If `∑ ‖a_i‖ < ∞`, then `∏ (1 + a_i)` converges to `(∏_{i ∈ F} (1 + a_i)) * exp(L)` for a
finite exceptional set `F`, and vanishes if and only if some factor `1 + a_i = 0`. -/
theorem hasProd_one_add_of_summable_norm {ι : Type*} {a : ι → ℂ}
    (ha : Summable (fun i : ι => ‖a i‖)) :
    ∃ (F : Finset ι) (L : ℂ),
      (∀ i ∉ F, 1 + a i ≠ 0) ∧
      HasProd (fun i : ι => 1 + a i) ((∏ i ∈ F, (1 + a i)) * Complex.exp L) := by
  classical
  have htend := ha.tendsto_cofinite_zero
  have hmem : Metric.closedBall (0 : ℝ) (1 / 2) ∈ nhds (0 : ℝ) :=
    Metric.closedBall_mem_nhds 0 (by norm_num)
  have hev : { i : ι | ‖a i‖ ≤ 1 / 2 } ∈ Filter.cofinite := by
    have hpre := htend hmem
    refine Filter.mem_of_superset hpre fun i hi => ?_
    simpa [Metric.mem_closedBall, Real.dist_eq, abs_of_nonneg (norm_nonneg _)] using hi
  have hFin : ({ i : ι | ¬ ‖a i‖ ≤ 1 / 2 }).Finite := by
    rwa [Filter.mem_cofinite] at hev
  let F : Finset ι := hFin.toFinset
  have hF_le : ∀ i ∉ F, ‖a i‖ ≤ 1 / 2 := by
    intro i hi
    by_contra hnot
    exact hi (hFin.mem_toFinset.mpr hnot)
  have hF_ne : ∀ i ∉ F, 1 + a i ≠ 0 := by
    intro i hi h0
    have ha_eq : a i = -1 := eq_neg_of_add_eq_zero_right h0
    have hle := hF_le i hi
    rw [ha_eq, norm_neg, norm_one] at hle
    norm_num at hle
  let g : ι → ℂ := fun i => if i ∈ F then 0 else Complex.log (1 + a i)
  have hg_summ : Summable g := by
    refine Summable.of_norm_bounded (ha.mul_left 2) fun i => ?_
    dsimp [g]
    split_ifs with hi
    · rw [norm_zero]; exact mul_nonneg (by norm_num) (norm_nonneg _)
    · exact norm_log_one_add_le (hF_le i hi)
  refine ⟨F, ∑' i : ι, g i, hF_ne, ?_⟩
  have hTend : Filter.Tendsto (fun s : Finset ι => (∏ i ∈ F, (1 + a i)) * Complex.exp (∑ i ∈ s, g i))
      Filter.atTop (nhds ((∏ i ∈ F, (1 + a i)) * Complex.exp (∑' i : ι, g i))) :=
    tendsto_const_nhds.mul ((Complex.continuous_exp.tendsto _).comp hg_summ.hasSum)
  refine hTend.congr' ?_
  filter_upwards [Filter.eventually_ge_atTop F] with s hs
  have hsplit : s = F ∪ (s \ F) := (Finset.union_sdiff_of_subset hs).symm
  have hdisj : Disjoint F (s \ F) := disjoint_sdiff_self_right
  have hexp_tail : Complex.exp (∑ i ∈ s, g i) = ∏ i ∈ s \ F, (1 + a i) := by
    have hsum_split : ∑ i ∈ s, g i = ∑ i ∈ F, g i + ∑ i ∈ s \ F, g i := by
      conv_lhs => rw [hsplit]
      exact Finset.sum_union hdisj
    rw [hsum_split, Complex.exp_add]
    have hFzero : ∑ i ∈ F, g i = 0 := Finset.sum_eq_zero fun i hi => by simp [g, hi]
    rw [hFzero, Complex.exp_zero, one_mul, Complex.exp_sum]
    refine Finset.prod_congr rfl fun i hi => ?_
    have hnotF : i ∉ F := (Finset.mem_sdiff.mp hi).2
    simp only [g, hnotF, ↓reduceIte]
    exact Complex.exp_log (hF_ne i hnotF)
  rw [hexp_tail, ← Finset.prod_union hdisj, ← hsplit]

theorem multipliable_one_add_of_summable_norm {ι : Type*} {a : ι → ℂ}
    (ha : Summable (fun i : ι => ‖a i‖)) :
    Multipliable (fun i : ι => 1 + a i) := by
  obtain ⟨F, L, _, hP⟩ := hasProd_one_add_of_summable_norm ha
  exact hP.multipliable

/-- **Theorem 3.2 (Non-Vanishing Criterion):** Under `∑ ‖a_i‖ < ∞`,
`∏' (1 + a_i) ≠ 0 ↔ ∀ i, 1 + a_i ≠ 0`. -/
theorem tprod_one_add_ne_zero_iff {ι : Type*} {a : ι → ℂ}
    (ha : Summable (fun i : ι => ‖a i‖)) :
    (∏' i : ι, (1 + a i)) ≠ 0 ↔ ∀ i : ι, 1 + a i ≠ 0 := by
  obtain ⟨F, L, hF_ne, hP⟩ := hasProd_one_add_of_summable_norm ha
  rw [hP.tprod_eq, mul_ne_zero_iff, and_iff_left (Complex.exp_ne_zero L), Finset.prod_ne_zero_iff]
  constructor
  · intro h i
    by_cases hi : i ∈ F
    · exact h i hi
    · exact hF_ne i hi
  · intro h i _
    exact h i

end ComplexInfiniteProducts

/-! ============================================================================
## Section 4: Scalar Carleman Determinants `det_k` & `det_2`, Anomaly, and Euler Primes
============================================================================ -/

section ScalarCarlemanDeterminant

/-- Scalar order-`k` Carleman determinant `det_k(I + diag(lam)) = ∏' E_k(lam_i)`. -/
noncomputable def detKDiag {ι : Type*} (k : ℕ) (lam : ι → ℂ) : ℂ :=
  ∏' i : ι, weierstrassFactor k (lam i)

/-- Scalar Hilbert–Schmidt Carleman determinant `det_2(I + diag(lam)) = ∏' (1 + lam_i) exp(-lam_i)`. -/
noncomputable abbrev det2Diag {ι : Type*} (lam : ι → ℂ) : ℂ :=
  detKDiag 2 lam

/-- Diagonal characterization of `IsHilbertSchmidt`. -/
theorem isHilbertSchmidt_of_diagonal {ι : Type*} {H : Type*}
    [NormedAddCommGroup H] [InnerProductSpace ℂ H] [CompleteSpace H]
    (e : HilbertBasis ι ℂ H) (K : H →L[ℂ] H) (lam : ι → ℂ)
    (hdiag : ∀ i : ι, K (e i) = lam i • e i) :
    IsHilbertSchmidt e K ↔ Summable (fun i : ι => ‖lam i‖ ^ 2) := by
  unfold IsHilbertSchmidt
  have hfun : (fun i : ι => ‖K (e i)‖ ^ 2) = fun i : ι => ‖lam i‖ ^ 2 := by
    funext i
    rw [hdiag i, norm_smul, e.orthonormal.1 i, mul_one]
  rw [hfun]

/-- **Theorem 4.1 (Summability of Scalar Order-`k` Remainders on `ℓ^k`):**
If `∑ ‖lam_i‖^k < ∞` (`k ≥ 1`), then `∑ ‖E_k(lam_i) - 1‖ < ∞`. -/
theorem summable_norm_weierstrassRemainder_of_lk {ι : Type*} {k : ℕ} (hk : 1 ≤ k)
    {lam : ι → ℂ} (hlam : Summable (fun i : ι => ‖lam i‖ ^ k)) :
    Summable (fun i : ι => ‖weierstrassRemainder k (lam i)‖) := by
  let S : ℝ := ∑' i : ι, ‖lam i‖ ^ k
  have hS_nonneg : 0 ≤ S := tsum_nonneg fun i => pow_nonneg (norm_nonneg _) k
  let B : ℝ := max 1 S
  have hB_ge1 : 1 ≤ B := le_max_left 1 S
  have hlam_le : ∀ i : ι, ‖lam i‖ ≤ B := by
    intro i
    have hpow : ‖lam i‖ ^ k ≤ B :=
      le_trans (hlam.le_tsum i fun j _ => pow_nonneg (norm_nonneg _) k) (le_max_right 1 S)
    by_cases h1 : ‖lam i‖ ≤ 1
    · exact le_trans h1 hB_ge1
    · push Not at h1
      exact le_trans (le_self_pow₀ h1.le (by omega)) hpow
  let C : ℝ := (1 / (k : ℝ)) * Real.exp (weierstrassExpBound k B)
  refine Summable.of_nonneg_of_le (fun i => norm_nonneg _) (fun i => ?_) (hlam.mul_left C)
  have hExp_mono : weierstrassExpBound k ‖lam i‖ ≤ weierstrassExpBound k B :=
    Finset.sum_le_sum fun m _ =>
      div_le_div_of_nonneg_right (pow_le_pow_left₀ (norm_nonneg _) (hlam_le i) m) (Nat.cast_nonneg _)
  calc ‖weierstrassRemainder k (lam i)‖
      ≤ (1 / (k : ℝ)) * ‖lam i‖ ^ k * Real.exp (weierstrassExpBound k ‖lam i‖) :=
        norm_weierstrassRemainder_le norm_one.le hk (lam i)
    _ ≤ (1 / (k : ℝ)) * ‖lam i‖ ^ k * Real.exp (weierstrassExpBound k B) :=
        mul_le_mul_of_nonneg_left (Real.exp_le_exp.mpr hExp_mono) (by positivity)
    _ = C * ‖lam i‖ ^ k := by dsimp [C]; ring

/-- **Theorem 4.2 (Convergence & Non-Vanishing of `det_k(I + diag(lam))`):**
For any `k ≥ 1` and `lam ∈ ℓ^k(ι, ℂ)`, the infinite product `detKDiag k lam` converges
and is nonzero iff `-1` is not an eigenvalue (`∀ i, lam i ≠ -1`). -/
theorem multipliable_weierstrassFactor_of_lk {ι : Type*} {k : ℕ} (hk : 1 ≤ k)
    {lam : ι → ℂ} (hlam : Summable (fun i : ι => ‖lam i‖ ^ k)) :
    Multipliable (fun i : ι => weierstrassFactor k (lam i)) := by
  have heq : (fun i : ι => weierstrassFactor k (lam i)) =
      fun i : ι => 1 + weierstrassRemainder k (lam i) := by
    funext i; unfold weierstrassRemainder; ring
  rw [heq]
  exact multipliable_one_add_of_summable_norm (summable_norm_weierstrassRemainder_of_lk hk hlam)

theorem detKDiag_ne_zero_iff {ι : Type*} {k : ℕ} (hk : 1 ≤ k)
    {lam : ι → ℂ} (hlam : Summable (fun i : ι => ‖lam i‖ ^ k)) :
    detKDiag k lam ≠ 0 ↔ ∀ i : ι, lam i ≠ -1 := by
  unfold detKDiag
  have heq : (fun i : ι => weierstrassFactor k (lam i)) =
      fun i : ι => 1 + weierstrassRemainder k (lam i) := by
    funext i; unfold weierstrassRemainder; ring
  rw [heq, tprod_one_add_ne_zero_iff (summable_norm_weierstrassRemainder_of_lk hk hlam)]
  refine forall_congr' fun i => ?_
  rw [show 1 + weierstrassRemainder k (lam i) = weierstrassFactor k (lam i) by
    unfold weierstrassRemainder; ring]
  unfold weierstrassFactor
  rw [mul_ne_zero_iff, and_iff_left (by rw [← Complex.exp_eq_exp_ℂ]; exact Complex.exp_ne_zero _)]
  constructor
  · intro h h1; apply h; rw [h1]; ring
  · intro h h0; apply h; exact eq_neg_of_add_eq_zero_right h0

/-- **Theorem 4.3 (Hilbert–Schmidt `det_2` Multiplicative Trace Anomaly):**
For commuting diagonal Hilbert–Schmidt operators `K₁ = diag(lam)` and `K₂ = diag(μ)`,
`det_2((I + K₁)(I + K₂)) = det_2(I + K₁) * det_2(I + K₂) * exp(-Tr(K₁ K₂))`. -/
theorem det2Diag_mul_anomaly {ι : Type*} {lam μ : ι → ℂ}
    (hlam : Summable (fun i : ι => ‖lam i‖ ^ 2))
    (hμ : Summable (fun i : ι => ‖μ i‖ ^ 2)) :
    Summable (fun i : ι => lam i * μ i) ∧
    det2Diag (fun i => lam i + μ i + lam i * μ i) =
      det2Diag lam * det2Diag μ * Complex.exp (-∑' i : ι, lam i * μ i) := by
  have hTr : Summable (fun i : ι => lam i * μ i) := by
    refine Summable.of_norm_bounded ((hlam.add hμ).mul_left (1 / 2)) fun i => ?_
    rw [norm_mul]
    nlinarith [sq_nonneg (‖lam i‖ - ‖μ i‖)]
  refine ⟨hTr, ?_⟩
  have hPlam : HasProd (fun i : ι => weierstrassFactor 2 (lam i)) (det2Diag lam) :=
    (multipliable_weierstrassFactor_of_lk (by norm_num) hlam).hasProd
  have hPμ : HasProd (fun i : ι => weierstrassFactor 2 (μ i)) (det2Diag μ) :=
    (multipliable_weierstrassFactor_of_lk (by norm_num) hμ).hasProd
  have hPexp : HasProd (fun i : ι => Complex.exp (-(lam i * μ i)))
      (Complex.exp (-∑' i : ι, lam i * μ i)) := by
    have hNeg : HasSum (fun i : ι => -(lam i * μ i)) (-∑' i : ι, lam i * μ i) :=
      hTr.hasSum.neg
    have hTend : Filter.Tendsto (fun s : Finset ι => Complex.exp (∑ i ∈ s, -(lam i * μ i)))
        Filter.atTop (nhds (Complex.exp (-∑' i : ι, lam i * μ i))) :=
      (Complex.continuous_exp.tendsto _).comp hNeg
    refine hTend.congr fun s => ?_
    rw [Complex.exp_sum]
  have hProd := (hPlam.mul hPμ).mul hPexp
  have hPointwise : (fun i : ι =>
      weierstrassFactor 2 (lam i) * weierstrassFactor 2 (μ i) * Complex.exp (-(lam i * μ i))) =
      fun i : ι => weierstrassFactor 2 (lam i + μ i + lam i * μ i) := by
    funext i
    rw [weierstrassFactor_two, weierstrassFactor_two, weierstrassFactor_two]
    simp only [← Complex.exp_eq_exp_ℂ]
    have hexp : Complex.exp (-(lam i)) * Complex.exp (-(μ i)) * Complex.exp (-(lam i * μ i)) =
        Complex.exp (-(lam i + μ i + lam i * μ i)) := by
      rw [← Complex.exp_add, ← Complex.exp_add]; congr 1; ring
    calc (1 + lam i) * Complex.exp (-(lam i)) * ((1 + μ i) * Complex.exp (-(μ i))) *
            Complex.exp (-(lam i * μ i))
        = ((1 + lam i) * (1 + μ i)) *
            (Complex.exp (-(lam i)) * Complex.exp (-(μ i)) * Complex.exp (-(lam i * μ i))) := by ring
      _ = (1 + (lam i + μ i + lam i * μ i)) * Complex.exp (-(lam i + μ i + lam i * μ i)) := by
          rw [hexp]; ring
  rw [hPointwise] at hProd
  exact hProd.tprod_eq

/-- **Theorem 4.4 (Euler Prime Product Convergence & Non-Vanishing for `Re(s) > 1/k`):**
For every `k ≥ 1` and `s ∈ ℂ` with `Re(s) > 1/k`, the Euler prime eigenvalues
`lam_p(s) = -p^(-s)` lie in `ℓ^k`, so `detKDiag k lam_p` converges absolutely and is nonzero. -/
theorem detKDiag_eulerPrimes_converges_and_ne_zero {k : ℕ} (hk : 1 ≤ k) {s : ℂ}
    (hs : (1 / (k : ℝ)) < s.re) :
    let lam : Nat.Primes → ℂ := fun p => -(((p : ℕ) : ℂ) ^ (-s))
    Summable (fun p : Nat.Primes => ‖lam p‖ ^ k) ∧
    Multipliable (fun p : Nat.Primes => weierstrassFactor k (lam p)) ∧
    detKDiag k lam ≠ 0 := by
  intro lam
  have hk_pos : (0 : ℝ) < (k : ℝ) := by exact_mod_cast hk
  have hks : 1 < (k : ℝ) * s.re := by
    have h1 := (div_lt_iff₀ hk_pos).mp hs
    linarith
  have hs_pos : 0 < s.re := lt_trans (by positivity) hs
  have hNorm : ∀ p : Nat.Primes, ‖lam p‖ = ((p : ℕ) : ℝ) ^ (-s.re) := by
    intro p
    dsimp [lam]
    have hp_pos : (0 : ℝ) < ((p : ℕ) : ℝ) := by exact_mod_cast p.2.pos
    rw [norm_neg, ← Complex.ofReal_natCast, Complex.norm_cpow_eq_rpow_re_of_pos hp_pos]
    simp
  have hLk : Summable (fun p : Nat.Primes => ‖lam p‖ ^ k) := by
    have hNat : Summable (fun n : ℕ => ((n : ℝ) ^ ((k : ℝ) * s.re))⁻¹) :=
      Real.summable_nat_rpow_inv.mpr hks
    have hSub : Summable (fun p : Nat.Primes => (((p : ℕ) : ℝ) ^ ((k : ℝ) * s.re))⁻¹) :=
      hNat.comp_injective Subtype.val_injective
    refine hSub.congr fun p => ?_
    rw [hNorm p, ← Real.rpow_natCast, ← Real.rpow_mul (Nat.cast_nonneg (p : ℕ)),
      ← Real.rpow_neg (Nat.cast_nonneg (p : ℕ))]
    congr 1; ring
  have hNe : ∀ p : Nat.Primes, lam p ≠ -1 := by
    intro p hEq
    have hNorm1 : ‖lam p‖ = 1 := by rw [hEq, norm_neg, norm_one]
    rw [hNorm p] at hNorm1
    have hp1 : (1 : ℝ) < ((p : ℕ) : ℝ) := by exact_mod_cast p.2.one_lt
    have hlt1 : ((p : ℕ) : ℝ) ^ (-s.re) < 1 :=
      Real.rpow_lt_one_of_one_lt_of_neg hp1 (neg_lt_zero.mpr hs_pos)
    linarith
  exact ⟨hLk, multipliable_weierstrassFactor_of_lk hk hLk,
    (detKDiag_ne_zero_iff hk hLk).mpr hNe⟩

/-- **Corollary 4.5 (Explicit `det_2` on `Re(s) > 1/2` and `det_3` on the Critical Line `Re(s) = 1/2`):** -/
theorem det2_eulerPrimes_re_gt_half {s : ℂ} (hs : (1 / 2 : ℝ) < s.re) :
    let lam : Nat.Primes → ℂ := fun p => -(((p : ℕ) : ℂ) ^ (-s))
    Multipliable (fun p : Nat.Primes => weierstrassFactor 2 (lam p)) ∧ det2Diag lam ≠ 0 :=
  let h := detKDiag_eulerPrimes_converges_and_ne_zero (k := 2) (by norm_num) (by simpa using hs)
  ⟨h.2.1, h.2.2⟩

theorem det3_eulerPrimes_critical_line (t : ℝ) :
    let s : ℂ := (1 / 2 : ℂ) + (t : ℂ) * Complex.I
    let lam : Nat.Primes → ℂ := fun p => -(((p : ℕ) : ℂ) ^ (-s))
    Multipliable (fun p : Nat.Primes => weierstrassFactor 3 (lam p)) ∧ detKDiag 3 lam ≠ 0 := by
  intro s lam
  have hs : (1 / (3 : ℝ)) < s.re := by
    simp [s]; norm_num
  have h := detKDiag_eulerPrimes_converges_and_ne_zero (k := 3) (by norm_num) hs
  exact ⟨h.2.1, h.2.2⟩

end ScalarCarlemanDeterminant

end Signals.SatoGrassmannian.CarlemanWeierstrass
