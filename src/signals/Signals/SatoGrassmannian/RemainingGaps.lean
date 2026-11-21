import Mathlib.Analysis.Complex.Basic
import Mathlib.Analysis.Calculus.Deriv.Basic
import Mathlib.Analysis.Calculus.Deriv.Mul
import Mathlib.Analysis.Calculus.MeanValue
import Mathlib.Analysis.Normed.Algebra.Exponential
import Mathlib.Analysis.PSeries
import Mathlib.Analysis.SpecialFunctions.Complex.Log
import Mathlib.Analysis.SpecialFunctions.ExpDeriv
import Mathlib.MeasureTheory.Integral.IntervalIntegral.FundThmCalculus
import Signals.SatoGrassmannian.KPFlow
import Signals.SatoGrassmannian.RHGaps

open scoped InnerProductSpace BigOperators

namespace Signals.SatoGrassmannian.RemainingGaps

open Signals.SatoGrassmannian Signals.SatoGrassmannian.KPFlow
open Signals.SatoGrassmannian.RHGaps

/-! ============================================================================
## Gap 1: Hilbert–Schmidt Ideal & Carleman Regularization `det₂` for `Re(s) > 1/2`
============================================================================ -/

section CarlemanDet2

/-- Scalar Taylor coefficients `c_k = (-1)^(k+1) * (k + 1) / (k + 2)!` of
`((1 + z) exp(-z) - 1) / z² = ∑_{k=0}^∞ c_k z^k`. -/
noncomputable def carlemanCoeff (k : ℕ) : ℂ :=
  ((-1 : ℂ) ^ (k + 1) * ((k + 1 : ℕ) : ℂ)) / ((k + 2).factorial : ℂ)

lemma norm_carlemanCoeff_le (k : ℕ) :
    ‖carlemanCoeff k‖ ≤ (1 / 2 : ℝ) * ((k.factorial : ℝ)⁻¹) := by
  unfold carlemanCoeff
  rw [norm_div, norm_mul, norm_pow, norm_neg, norm_one, one_pow, one_mul,
    Complex.norm_natCast, Complex.norm_natCast]
  have hfac : ((k + 2).factorial : ℝ) = ((k + 2 : ℕ) : ℝ) * ((k + 1 : ℕ) : ℝ) * (k.factorial : ℝ) := by
    rw [Nat.factorial_succ, Nat.factorial_succ]
    push_cast; ring
  have hk1 : (0 : ℝ) < ((k + 1 : ℕ) : ℝ) := by positivity
  have hkf : (0 : ℝ) < (k.factorial : ℝ) := by exact_mod_cast Nat.factorial_pos k
  have hk2 : (2 : ℝ) ≤ ((k + 2 : ℕ) : ℝ) := by exact_mod_cast Nat.le_add_left 2 k
  rw [hfac]
  have hcancel : ((k + 1 : ℕ) : ℝ) / (((k + 2 : ℕ) : ℝ) * ((k + 1 : ℕ) : ℝ) * (k.factorial : ℝ)) =
      1 / (((k + 2 : ℕ) : ℝ) * (k.factorial : ℝ)) := by
    field_simp [hk1.ne', hkf.ne']
  rw [hcancel]
  rw [show (1 / 2 : ℝ) * (k.factorial : ℝ)⁻¹ = 1 / (2 * (k.factorial : ℝ)) by ring]
  exact one_div_le_one_div_of_le (by positivity) (by nlinarith)

section BanachAlgebraCarleman

variable {A : Type*} [NormedRing A] [NormedAlgebra ℂ A] [CompleteSpace A]

/-- The Carleman regularized operator remainder `R₂(K) = (1 + K) exp(-K) - 1`. -/
noncomputable def carlemanRemainder (K : A) : A :=
  (1 + K) * NormedSpace.exp (-K) - 1

/-- Analytic tail `S(K) = ∑_{k=0}^∞ c_k K^k` satisfying `R₂(K) = K² S(K) = S(K) K²`. -/
noncomputable def carlemanTail (K : A) : A :=
  ∑' k : ℕ, carlemanCoeff k • K ^ k

lemma summable_carlemanTail_terms (K : A) :
    Summable (fun k : ℕ => carlemanCoeff k • K ^ k) := by
  have hExp : Summable (fun k : ℕ => (1 / 2 : ℝ) * (‖K‖ ^ k / (k.factorial : ℝ))) :=
    (Real.summable_pow_div_factorial ‖K‖).mul_left (1 / 2)
  rw [← summable_nat_add_iff 1] at hExp ⊢
  refine Summable.of_norm_bounded hExp fun k => ?_
  rw [norm_smul]
  have hpow : ‖K ^ (k + 1)‖ ≤ ‖K‖ ^ (k + 1) := norm_pow_le' K (Nat.succ_pos k)
  calc ‖carlemanCoeff (k + 1)‖ * ‖K ^ (k + 1)‖
      ≤ ((1 / 2 : ℝ) * ((k + 1).factorial : ℝ)⁻¹) * ‖K‖ ^ (k + 1) :=
        mul_le_mul (norm_carlemanCoeff_le (k + 1)) hpow (norm_nonneg _) (by positivity)
    _ = (1 / 2 : ℝ) * (‖K‖ ^ (k + 1) / ((k + 1).factorial : ℝ)) := by ring

lemma summable_carlemanRemainder_terms (K : A) :
    Summable (fun k : ℕ => carlemanCoeff k • K ^ (k + 2)) := by
  have hExp : Summable (fun k : ℕ => (1 / 2 : ℝ) * ‖K‖ ^ 2 * (‖K‖ ^ k / (k.factorial : ℝ))) :=
    (Real.summable_pow_div_factorial ‖K‖).mul_left ((1 / 2 : ℝ) * ‖K‖ ^ 2)
  refine Summable.of_norm_bounded hExp fun k => ?_
  rw [norm_smul]
  have hpow : ‖K ^ (k + 2)‖ ≤ ‖K‖ ^ (k + 2) := norm_pow_le' K (Nat.succ_pos _)
  calc ‖carlemanCoeff k‖ * ‖K ^ (k + 2)‖
      ≤ ((1 / 2 : ℝ) * (k.factorial : ℝ)⁻¹) * ‖K‖ ^ (k + 2) :=
        mul_le_mul (norm_carlemanCoeff_le k) hpow (norm_nonneg _) (by positivity)
    _ = (1 / 2 : ℝ) * ‖K‖ ^ 2 * (‖K‖ ^ k / (k.factorial : ℝ)) := by
        rw [pow_add]; ring

/-- **Theorem 1.1 (Exact Counterterm Cancellation Series):**
`(1 + K) exp(-K) - 1 = ∑_{k=0}^∞ c_k K^(k+2)` — the linear `O(K)` term cancels identically. -/
theorem hasSum_carlemanRemainder (K : A) :
    HasSum (fun k : ℕ => carlemanCoeff k • K ^ (k + 2)) (carlemanRemainder K) := by
  have hExp : HasSum (fun n : ℕ => (n.factorial : ℂ)⁻¹ • (-K) ^ n) (NormedSpace.exp (-K)) :=
    hasSum_exp_terms (-K)
  have hA : HasSum (fun k : ℕ => ((k + 2).factorial : ℂ)⁻¹ • (-K) ^ (k + 2))
      (NormedSpace.exp (-K) - (1 - K)) := by
    have h2 := (hasSum_nat_add_iff' 2).mpr hExp
    have hsum2 : ∑ i ∈ Finset.range 2, (i.factorial : ℂ)⁻¹ • (-K) ^ i = 1 - K := by
      simp [Finset.sum_range_succ, sub_eq_add_neg]
    rwa [hsum2] at h2
  have hB : HasSum (fun k : ℕ => K * (((k + 1).factorial : ℂ)⁻¹ • (-K) ^ (k + 1)))
      (K * (NormedSpace.exp (-K) - 1)) := by
    have h1 := (hasSum_nat_add_iff' 1).mpr hExp
    have hsum1 : ∑ i ∈ Finset.range 1, (i.factorial : ℂ)⁻¹ • (-K) ^ i = 1 := by
      simp
    rw [hsum1] at h1
    exact h1.mul_left K
  have hAdd := hA.add hB
  have hLim : (NormedSpace.exp (-K) - (1 - K)) + K * (NormedSpace.exp (-K) - 1) =
      carlemanRemainder K := by
    unfold carlemanRemainder
    noncomm_ring
  rw [hLim] at hAdd
  refine hAdd.congr_fun fun k => ?_
  have hneg : ∀ m : ℕ, (-K) ^ m = (-1 : ℂ) ^ m • K ^ m := by
    intro m
    rw [show -K = (-1 : ℂ) • K by simp, smul_pow]
  rw [hneg (k + 2), hneg (k + 1), Algebra.mul_smul_comm, Algebra.mul_smul_comm,
    ← pow_succ', smul_smul, smul_smul, ← add_smul]
  congr 1
  unfold carlemanCoeff
  have hfac : ((k + 2).factorial : ℂ) = ((k + 2 : ℕ) : ℂ) * ((k + 1).factorial : ℂ) := by
    rw [Nat.factorial_succ]; push_cast; ring
  have hk2_ne : ((k + 2 : ℕ) : ℂ) ≠ 0 := by exact_mod_cast Nat.succ_ne_zero (k + 1)
  have hkf_ne : ((k + 1).factorial : ℂ) ≠ 0 := by exact_mod_cast Nat.factorial_ne_zero (k + 1)
  rw [hfac, pow_succ]
  field_simp [hk2_ne, hkf_ne]
  push_cast; ring

/-- **Theorem 1.2 (Factorization `R₂(K) = S(K) * K * K`):**
Every Carleman remainder factors through `K²` with bounded commuting tail `S(K)`. -/
theorem carlemanRemainder_eq_tail_mul_sq (K : A) :
    carlemanRemainder K = (carlemanTail K * K) * K := by
  have hTail : HasSum (fun k : ℕ => carlemanCoeff k • K ^ k) (carlemanTail K) :=
    (summable_carlemanTail_terms K).hasSum
  have hMul : HasSum (fun k : ℕ => ((carlemanCoeff k • K ^ k) * K) * K)
      ((carlemanTail K * K) * K) :=
    (hTail.mul_right K).mul_right K
  have hCon : (fun k : ℕ => ((carlemanCoeff k • K ^ k) * K) * K) =
      fun k : ℕ => carlemanCoeff k • K ^ (k + 2) := by
    funext k
    rw [Algebra.smul_mul_assoc, Algebra.smul_mul_assoc, ← pow_succ, ← pow_succ]
  rw [hCon] at hMul
  exact (hasSum_carlemanRemainder K).unique hMul

/-- **Theorem 1.3 (Universal Quadratic Carleman Bound):**
In any complex Banach algebra (both `ℂ` and `H →L[ℂ] H`),
`‖(1 + K) exp(-K) - 1‖ ≤ (1 / 2) * ‖K‖² * exp(‖K‖)`. -/
theorem norm_carlemanRemainder_le (K : A) :
    ‖carlemanRemainder K‖ ≤ (1 / 2 : ℝ) * ‖K‖ ^ 2 * Real.exp ‖K‖ := by
  have hEq : carlemanRemainder K = ∑' k : ℕ, carlemanCoeff k • K ^ (k + 2) :=
    (hasSum_carlemanRemainder K).tsum_eq.symm
  have hExp : Summable (fun k : ℕ => (1 / 2 : ℝ) * ‖K‖ ^ 2 * (‖K‖ ^ k / (k.factorial : ℝ))) :=
    (Real.summable_pow_div_factorial ‖K‖).mul_left ((1 / 2 : ℝ) * ‖K‖ ^ 2)
  have hTermLe : ∀ k : ℕ, ‖carlemanCoeff k • K ^ (k + 2)‖ ≤
      (1 / 2 : ℝ) * ‖K‖ ^ 2 * (‖K‖ ^ k / (k.factorial : ℝ)) := fun k => by
    rw [norm_smul]
    have hpow : ‖K ^ (k + 2)‖ ≤ ‖K‖ ^ (k + 2) := norm_pow_le' K (Nat.succ_pos _)
    calc ‖carlemanCoeff k‖ * ‖K ^ (k + 2)‖
        ≤ ((1 / 2 : ℝ) * (k.factorial : ℝ)⁻¹) * ‖K‖ ^ (k + 2) :=
          mul_le_mul (norm_carlemanCoeff_le k) hpow (norm_nonneg _) (by positivity)
      _ = (1 / 2 : ℝ) * ‖K‖ ^ 2 * (‖K‖ ^ k / (k.factorial : ℝ)) := by
          rw [pow_add]; ring
  have hSummNorm : Summable (fun k : ℕ => ‖carlemanCoeff k • K ^ (k + 2)‖) :=
    Summable.of_nonneg_of_le (fun _ => norm_nonneg _) hTermLe hExp
  rw [hEq]
  calc ‖∑' k : ℕ, carlemanCoeff k • K ^ (k + 2)‖
      ≤ ∑' k : ℕ, ‖carlemanCoeff k • K ^ (k + 2)‖ := norm_tsum_le_tsum_norm hSummNorm
    _ ≤ ∑' k : ℕ, (1 / 2 : ℝ) * ‖K‖ ^ 2 * (‖K‖ ^ k / (k.factorial : ℝ)) :=
        Summable.tsum_le_tsum hTermLe hSummNorm hExp
    _ = (1 / 2 : ℝ) * ‖K‖ ^ 2 * ∑' k : ℕ, ‖K‖ ^ k / (k.factorial : ℝ) := tsum_mul_left
    _ = (1 / 2 : ℝ) * ‖K‖ ^ 2 * Real.exp ‖K‖ := by rw [Real.exp_eq_exp_ℝ, NormedSpace.exp_eq_tsum_div]

end BanachAlgebraCarleman

section HilbertSchmidtAndAdelicConvergence

variable {ι : Type*} {H : Type*}
  [NormedAddCommGroup H] [InnerProductSpace ℂ H] [CompleteSpace H]

/-- An operator `T : H →L[ℂ] H` is Hilbert–Schmidt relative to an orthonormal basis `e`
if `∑_i ‖T(e_i)‖² < ∞`. -/
def IsHilbertSchmidt (e : HilbertBasis ι ℂ H) (T : H →L[ℂ] H) : Prop :=
  Summable (fun i : ι => ‖T (e i)‖ ^ 2)

/-- Schatten trace-class ideal `ℐ₁ = ℐ₂ · ℐ₂`: products of two Hilbert–Schmidt operators. -/
def IsTraceClass (e : HilbertBasis ι ℂ H) (T : H →L[ℂ] H) : Prop :=
  ∃ A B : H →L[ℂ] H, IsHilbertSchmidt e A ∧ IsHilbertSchmidt e B ∧ T = A * B

omit [CompleteSpace H] in
/-- Left ideal closure of Hilbert–Schmidt operators under bounded composition. -/
theorem IsHilbertSchmidt.mul_left {e : HilbertBasis ι ℂ H} {T : H →L[ℂ] H}
    (hT : IsHilbertSchmidt e T) (A : H →L[ℂ] H) :
    IsHilbertSchmidt e (A * T) := by
  refine Summable.of_nonneg_of_le (fun i => sq_nonneg _) (fun i => ?_)
    (Summable.mul_left (‖A‖ ^ 2) hT)
  calc ‖(A * T) (e i)‖ ^ 2
      ≤ (‖A‖ * ‖T (e i)‖) ^ 2 := by
        exact pow_le_pow_left₀ (norm_nonneg _) (A.le_opNorm (T (e i))) 2
    _ = ‖A‖ ^ 2 * ‖T (e i)‖ ^ 2 := mul_pow _ _ 2

/-- **Theorem 1.4 (Carleman Trace-Class Lifting):**
For any Hilbert–Schmidt operator `K ∈ ℐ₂`, the Carleman remainder
`(1 + K) exp(-K) - 1` lies in the trace-class ideal `ℐ₁`. -/
theorem carlemanRemainder_isTraceClass {e : HilbertBasis ι ℂ H} {K : H →L[ℂ] H}
    (hK : IsHilbertSchmidt e K) :
    IsTraceClass e (carlemanRemainder K) :=
  ⟨carlemanTail K * K, K, hK.mul_left (carlemanTail K), hK,
    carlemanRemainder_eq_tail_mul_sq K⟩

/-- **Theorem 1.5 (Bypassing the `σ = 1` Barrier — Adelic Carleman Convergence for `Re(s) > 1/2`):**
Whereas raw prime transfers diverge in trace norm for `1/2 < σ ≤ 1` (`not_summable_primes_inv`),
their Carleman regularized remainders `(1 + K_p) exp(-K_p) - 1` converge unconditionally
in operator norm inside the restricted Sato algebra `𝒜_res(H)` for every `σ > 1/2`. -/
theorem adelicCarleman_summable_mem_resAlg
    (P : PolarizedHilbertSpace ℂ H) (K : ℕ → (H →L[ℂ] H))
    {C σ : ℝ} (hC : 0 ≤ C) (hσ : (1 / 2 : ℝ) < σ)
    (hMem : ∀ n, K n ∈ resAlg P)
    (hZero : K 0 = 0)
    (hBound : ∀ n : ℕ, 0 < n → ‖K n‖ ≤ C * ((n : ℝ) ^ σ)⁻¹) :
    Summable (fun n : ℕ => carlemanRemainder (K n)) ∧
    (∑' n : ℕ, carlemanRemainder (K n)) ∈ resAlg P := by
  have h2σ : 1 < 2 * σ := by linarith
  let M : ℝ := (1 / 2 : ℝ) * C ^ 2 * Real.exp C
  have hPSeries : Summable (fun n : ℕ => M * ((n : ℝ) ^ (2 * σ))⁻¹) :=
    (Real.summable_nat_rpow_inv.mpr h2σ).mul_left M
  have hSumm : Summable (fun n : ℕ => carlemanRemainder (K n)) := by
    refine Summable.of_norm_bounded hPSeries fun n => ?_
    rcases Nat.eq_zero_or_pos n with rfl | hpos
    · have hR0 : carlemanRemainder (K 0) = 0 := by
        rw [hZero]; unfold carlemanRemainder; simp
      rw [hR0, norm_zero]
      exact mul_nonneg (by positivity) (inv_nonneg.mpr (Real.rpow_nonneg (Nat.cast_nonneg 0) _))
    · have hn1 : (1 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hpos
      have hn_rpow_ge1 : (1 : ℝ) ≤ (n : ℝ) ^ σ := Real.one_le_rpow hn1 (by linarith)
      have hKn_le_C : ‖K n‖ ≤ C := by
        calc ‖K n‖ ≤ C * ((n : ℝ) ^ σ)⁻¹ := hBound n hpos
          _ ≤ C * 1 := mul_le_mul_of_nonneg_left (inv_le_one_of_one_le₀ hn_rpow_ge1) hC
          _ = C := mul_one C
      have hKn_sq : ‖K n‖ ^ 2 ≤ C ^ 2 * ((n : ℝ) ^ (2 * σ))⁻¹ := by
        calc ‖K n‖ ^ 2
            ≤ (C * ((n : ℝ) ^ σ)⁻¹) ^ 2 := pow_le_pow_left₀ (norm_nonneg _) (hBound n hpos) 2
          _ = C ^ 2 * (((n : ℝ) ^ σ) ^ 2)⁻¹ := by rw [mul_pow, inv_pow]
          _ = C ^ 2 * ((n : ℝ) ^ (2 * σ))⁻¹ := by
              congr 2
              rw [← Real.rpow_natCast ((n : ℝ) ^ σ) 2, ← Real.rpow_mul (Nat.cast_nonneg n),
                Nat.cast_ofNat, mul_comm]
      calc ‖carlemanRemainder (K n)‖
          ≤ (1 / 2 : ℝ) * ‖K n‖ ^ 2 * Real.exp ‖K n‖ := norm_carlemanRemainder_le (K n)
        _ ≤ (1 / 2 : ℝ) * (C ^ 2 * ((n : ℝ) ^ (2 * σ))⁻¹) * Real.exp C := by
            refine mul_le_mul ?_ (Real.exp_le_exp.mpr hKn_le_C) (Real.exp_pos _).le (by positivity)
            exact mul_le_mul_of_nonneg_left hKn_sq (by norm_num)
        _ = M * ((n : ℝ) ^ (2 * σ))⁻¹ := by dsimp [M]; ring
  refine ⟨hSumm, ?_⟩
  refine (isClosed_resAlg P).mem_of_tendsto hSumm.hasSum ?_
  filter_upwards with s
  refine Subalgebra.sum_mem (resAlg P) fun n _ => ?_
  unfold carlemanRemainder
  exact Subalgebra.sub_mem (resAlg P)
    (Subalgebra.mul_mem (resAlg P)
      (Subalgebra.add_mem (resAlg P) (Subalgebra.one_mem _) (hMem n))
      (exp_mem_resAlg P (Subalgebra.neg_mem (resAlg P) (hMem n))))
    (Subalgebra.one_mem _)

end HilbertSchmidtAndAdelicConvergence

end CarlemanDet2

/-! ============================================================================
## Gap 2: Archimedean Cutoff Dilation Operator `D_Λ` on `[Λ⁻¹, Λ]` (via `[-L, L]`)
============================================================================ -/

section ArchimedeanDilation

/-- **Theorem 2.1 (Log-Coordinate Unitary Conjugation):**
Under the isometry `(U f)(u) = e^(u/2) f(e^u)` mapping `L²([e⁻ᴸ, eᴸ], dx)` to `L²([-L, L], du)`,
the Berry–Keating / Connes dilation operator `-i (x d/dx + 1/2)` conjugates exactly to `-i d/du`. -/
theorem dilation_log_conjugation {f : ℝ → ℂ} {f' : ℂ} (u : ℝ)
    (hf : HasDerivAt f f' (Real.exp u)) :
    HasDerivAt (fun t : ℝ => (Real.exp (t / 2) : ℂ) * f (Real.exp t))
      ((Real.exp (u / 2) : ℂ) * ((Real.exp u : ℂ) * f' + (1 / 2 : ℂ) * f (Real.exp u))) u := by
  have hhalf : HasDerivAt (fun t : ℝ => Real.exp (t / 2)) (Real.exp (u / 2) * (1 / 2)) u := by
    have h1 := (Real.hasDerivAt_exp (u / 2)).comp u ((hasDerivAt_id u).div_const 2)
    exact h1
  have hhalfC : HasDerivAt (fun t : ℝ => (Real.exp (t / 2) : ℂ))
      ((Real.exp (u / 2) : ℂ) * (1 / 2 : ℂ)) u := by
    convert Complex.ofRealCLM.hasFDerivAt.comp_hasDerivAt u hhalf using 1
    · funext t; rfl
    · simp [Complex.ofRealCLM_apply]
  have hfcomp : HasDerivAt (fun t : ℝ => f (Real.exp t)) (f' * (Real.exp u : ℂ)) u := by
    have h := hf.scomp u (Real.hasDerivAt_exp u)
    convert h using 1
    · funext t; rfl
    · simp [Complex.real_smul, mul_comm]
  convert hhalfC.mul hfcomp using 1
  ring

/-- **Theorem 2.2 (Green's Boundary Identity for `P_L = -i d/du` on `[-L, L]`):**
`∫_{-L}^L conj(-i φ') ψ - ∫_{-L}^L conj(φ) (-i ψ') = i (conj(φ(L)) ψ(L) - conj(φ(-L)) ψ(-L))`. -/
theorem greens_boundary_identity {L : ℝ} {φ φ' ψ ψ' : ℝ → ℂ}
    (hφ : ∀ u ∈ Set.uIcc (-L) L, HasDerivAt φ (φ' u) u)
    (hψ : ∀ u ∈ Set.uIcc (-L) L, HasDerivAt ψ (ψ' u) u)
    (hInt1 : IntervalIntegrable (fun u => starRingEnd ℂ (-Complex.I * φ' u) * ψ u)
      MeasureTheory.volume (-L) L)
    (hInt2 : IntervalIntegrable (fun u => starRingEnd ℂ (φ u) * (-Complex.I * ψ' u))
      MeasureTheory.volume (-L) L) :
    (∫ u in (-L)..L, starRingEnd ℂ (-Complex.I * φ' u) * ψ u) -
    (∫ u in (-L)..L, starRingEnd ℂ (φ u) * (-Complex.I * ψ' u)) =
      Complex.I * (starRingEnd ℂ (φ L) * ψ L - starRingEnd ℂ (φ (-L)) * ψ (-L)) := by
  have hDiff : ∀ u ∈ Set.uIcc (-L) L,
      HasDerivAt (fun t : ℝ => Complex.I * (starRingEnd ℂ (φ t) * ψ t))
        (starRingEnd ℂ (-Complex.I * φ' u) * ψ u - starRingEnd ℂ (φ u) * (-Complex.I * ψ' u)) u := by
    intro u hu
    have hconj : HasDerivAt (fun t : ℝ => starRingEnd ℂ (φ t)) (starRingEnd ℂ (φ' u)) u :=
      Complex.conjCLE.toContinuousLinearMap.hasFDerivAt.comp_hasDerivAt u (hφ u hu)
    have hprod := (hconj.mul (hψ u hu)).const_mul Complex.I
    convert hprod using 1
    simp only [map_mul, map_neg, Complex.conj_I]
    ring
  rw [← intervalIntegral.integral_sub hInt1 hInt2]
  have hFTC := intervalIntegral.integral_eq_sub_of_hasDerivAt hDiff (hInt1.sub hInt2)
  rw [hFTC]
  ring

/-- **Theorem 2.3 (Exact `U(1)` Classification of Self-Adjoint Boundary Conditions):**
The boundary form `conj(φ(L)) ψ(L) - conj(φ(-L)) ψ(-L)` vanishes for all `φ, ψ` obeying
`f(L) = α f(-L)` if and only if `‖α‖ = 1` (`α ∈ U(1)`). -/
theorem boundary_symmetric_iff_unit_circle (α : ℂ) :
    (∀ a b : ℂ, starRingEnd ℂ (α * a) * (α * b) - starRingEnd ℂ a * b = 0) ↔ ‖α‖ = 1 := by
  constructor
  · intro h
    have h1 := h 1 1
    simp only [mul_one, map_one, sub_eq_zero] at h1
    have hsq : (‖α‖ : ℂ) ^ 2 = 1 := by
      have hm := Complex.mul_conj α
      rw [Complex.normSq_eq_norm_sq] at hm
      rw [mul_comm] at h1
      simpa [hm] using h1
    have hsqR : ‖α‖ ^ 2 = 1 := by exact_mod_cast hsq
    nlinarith [norm_nonneg α]
  · intro hα a b
    have hmul : starRingEnd ℂ α * α = 1 := by
      rw [mul_comm, Complex.mul_conj, Complex.normSq_eq_norm_sq, hα]
      simp
    calc starRingEnd ℂ (α * a) * (α * b) - starRingEnd ℂ a * b
        = (starRingEnd ℂ α * α) * (starRingEnd ℂ a * b) - starRingEnd ℂ a * b := by
          simp only [map_mul]; ring
      _ = 1 * (starRingEnd ℂ a * b) - starRingEnd ℂ a * b := by rw [hmul]
      _ = 0 := by ring

/-- Uniqueness of the first-order complex ODE `ψ'(u) = c · ψ(u)` on `ℝ`. -/
lemma ode_exp_unique {ψ : ℝ → ℂ} {c : ℂ}
    (hψ : ∀ u : ℝ, HasDerivAt ψ (c * ψ u) u) (u : ℝ) :
    ψ u = ψ 0 * Complex.exp (c * (u : ℂ)) := by
  let h : ℝ → ℂ := fun t => Complex.exp (-c * (t : ℂ)) * ψ t
  have hderiv : ∀ t : ℝ, HasDerivAt h 0 t := by
    intro t
    have hlin : HasDerivAt (fun s : ℝ => -c * (s : ℂ)) (-c) t := by
      convert (Complex.ofRealCLM.hasDerivAt (x := t)).const_mul (-c) using 1
      · funext s; rfl
      · simp [Complex.ofRealCLM_apply]
    have hexp : HasDerivAt (fun s : ℝ => Complex.exp (-c * (s : ℂ)))
        (Complex.exp (-c * (t : ℂ)) * (-c)) t :=
      (Complex.hasDerivAt_exp _).comp t hlin
    convert hexp.mul (hψ t) using 1
    ring
  have hconst : h u = h 0 :=
    is_const_of_deriv_eq_zero (fun t => (hderiv t).differentiableAt)
      (fun t => (hderiv t).deriv) u 0
  simp only [h, Complex.ofReal_zero, mul_zero, Complex.exp_zero, one_mul] at hconst
  calc ψ u = Complex.exp (c * (u : ℂ)) * (Complex.exp (-c * (u : ℂ)) * ψ u) := by
        rw [← mul_assoc, ← Complex.exp_add]
        have : c * (u : ℂ) + -c * (u : ℂ) = 0 := by ring
        rw [this, Complex.exp_zero, one_mul]
    _ = Complex.exp (c * (u : ℂ)) * ψ 0 := by rw [hconst]
    _ = ψ 0 * Complex.exp (c * (u : ℂ)) := mul_comm _ _

/-- **Theorem 2.4 (Deficiency Index `n₊ = 1`):**
Every smooth solution to `-i ψ' = +i ψ` on `[-L, L]` lies in the 1-dimensional span of `e^(-u)`. -/
theorem deficiency_plus_unique {ψ : ℝ → ℂ}
    (hψ : ∀ u : ℝ, HasDerivAt ψ (-(ψ u)) u) (u : ℝ) :
    ψ u = ψ 0 * Complex.exp (-(u : ℂ)) := by
  have h := ode_exp_unique (c := (-1 : ℂ)) (fun t => by simpa using hψ t) u
  simpa using h

/-- **Theorem 2.5 (Deficiency Index `n₋ = 1`):**
Every smooth solution to `-i ψ' = -i ψ` on `[-L, L]` lies in the 1-dimensional span of `e^(+u)`. -/
theorem deficiency_minus_unique {ψ : ℝ → ℂ}
    (hψ : ∀ u : ℝ, HasDerivAt ψ (ψ u) u) (u : ℝ) :
    ψ u = ψ 0 * Complex.exp (u : ℂ) := by
  have h := ode_exp_unique (c := (1 : ℂ)) (fun t => by simpa using hψ t) u
  simpa using h

/-- **Theorem 2.6 (Exact Discrete Real Spectrum of the `U(1)` Extension `P_{L,θ}`):**
For cutoff `L = log Λ > 0` and phase `θ ∈ ℝ`, `lam ∈ ℂ` admits a nonzero eigenfunction
`-i ψ' = lam ψ` obeying `ψ(L) = e^(iθ) ψ(-L)` iff `lam = (2πk + θ) / (2L) ∈ ℝ` for some `k ∈ ℤ`. -/
theorem eigenvalue_spectrum_iff {L θ : ℝ} (hL : 0 < L) (lam : ℂ) :
    (∃ ψ : ℝ → ℂ, ψ ≠ 0 ∧
      (∀ u : ℝ, HasDerivAt ψ (Complex.I * lam * ψ u) u) ∧
      ψ L = Complex.exp (Complex.I * (θ : ℂ)) * ψ (-L)) ↔
    ∃ k : ℤ, lam = (((2 * Real.pi * (k : ℝ) + θ) / (2 * L) : ℝ) : ℂ) := by
  constructor
  · rintro ⟨ψ, hne, hode, hbc⟩
    have hψ0 : ψ 0 ≠ 0 := by
      intro h0
      apply hne
      ext u
      rw [ode_exp_unique hode u, h0, zero_mul]; rfl
    rw [ode_exp_unique hode L, ode_exp_unique hode (-L)] at hbc
    have hexp_eq : Complex.exp (Complex.I * lam * (L : ℂ)) =
        Complex.exp (Complex.I * (θ : ℂ)) * Complex.exp (Complex.I * lam * ((-L : ℝ) : ℂ)) := by
      apply mul_left_cancel₀ hψ0
      calc ψ 0 * Complex.exp (Complex.I * lam * (L : ℂ))
          = Complex.exp (Complex.I * (θ : ℂ)) * (ψ 0 * Complex.exp (Complex.I * lam * ((-L : ℝ) : ℂ))) := hbc
        _ = ψ 0 * (Complex.exp (Complex.I * (θ : ℂ)) * Complex.exp (Complex.I * lam * ((-L : ℝ) : ℂ))) := by ring
    have hexp1 : Complex.exp (Complex.I * (2 * lam * (L : ℂ) - (θ : ℂ))) = 1 := by
      have harg : Complex.I * (2 * lam * (L : ℂ) - (θ : ℂ)) =
          Complex.I * lam * (L : ℂ) + (-(Complex.I * (θ : ℂ)) + -(Complex.I * lam * ((-L : ℝ) : ℂ))) := by
        push_cast; ring
      rw [harg, Complex.exp_add, Complex.exp_add, Complex.exp_neg, Complex.exp_neg, hexp_eq]
      have h1 : Complex.exp (Complex.I * (θ : ℂ)) ≠ 0 := Complex.exp_ne_zero _
      have h2 : Complex.exp (Complex.I * lam * ((-L : ℝ) : ℂ)) ≠ 0 := Complex.exp_ne_zero _
      field_simp [h1, h2]
    obtain ⟨k, hk⟩ := Complex.exp_eq_one_iff.mp hexp1
    refine ⟨k, ?_⟩
    have hcancel : 2 * lam * (L : ℂ) - (θ : ℂ) = (k : ℂ) * (2 * (Real.pi : ℂ)) := by
      apply mul_left_cancel₀ Complex.I_ne_zero
      calc Complex.I * (2 * lam * (L : ℂ) - (θ : ℂ))
          = (k : ℂ) * (2 * (Real.pi : ℂ) * Complex.I) := hk
        _ = Complex.I * ((k : ℂ) * (2 * (Real.pi : ℂ))) := by ring
    have hLne : (L : ℂ) ≠ 0 := by exact_mod_cast hL.ne'
    push_cast
    field_simp [hLne]
    linear_combination hcancel
  · rintro ⟨k, rfl⟩
    let lam₀ : ℂ := (((2 * Real.pi * (k : ℝ) + θ) / (2 * L) : ℝ) : ℂ)
    refine ⟨fun u => Complex.exp (Complex.I * lam₀ * (u : ℂ)), ?_, ?_, ?_⟩
    · intro h0
      have := congrFun h0 0
      simp at this
    · intro u
      have hlin : HasDerivAt (fun t : ℝ => Complex.I * lam₀ * (t : ℂ)) (Complex.I * lam₀) u := by
        convert (Complex.ofRealCLM.hasDerivAt (x := u)).const_mul (Complex.I * lam₀) using 1
        · funext t; rfl
        · simp [Complex.ofRealCLM_apply]
      have h := (Complex.hasDerivAt_exp _).comp u hlin
      convert h using 1
      · rfl
      · dsimp [lam₀]; ring
    · rw [← Complex.exp_add]
      have hdiff : Complex.I * lam₀ * (L : ℂ) =
          (Complex.I * (θ : ℂ) + Complex.I * lam₀ * ((-L : ℝ) : ℂ)) +
            (k : ℂ) * (2 * (Real.pi : ℂ) * Complex.I) := by
        have hLne : (L : ℂ) ≠ 0 := by exact_mod_cast hL.ne'
        dsimp [lam₀]; push_cast
        field_simp [hLne]
        ring
      change Complex.exp (Complex.I * lam₀ * (L : ℂ)) = _
      rw [hdiff, Complex.exp_add, Complex.exp_int_mul_two_pi_mul_I, mul_one]

end ArchimedeanDilation

/-! ============================================================================
## Gap 3: Conditional Spectral–Determinant Bridge to RH, `Λ_dBN = 0`, and Li Positivity
============================================================================ -/

section SpectralDeterminantBridge

variable {H : Type*} [NormedAddCommGroup H] [InnerProductSpace ℂ H] [CompleteSpace H]

/-- Abstract Hilbert–Pólya / Connes spectral realization hypothesis:
every zero `z ∈ ℂ` of `Ξ(z) = ξ(1/2 + i z)` is an eigenvalue of the symmetric operator `D`. -/
def SpectralRealization (D : SymmetricOp H) (Ξ : ℂ → ℂ) : Prop :=
  ∀ z : ℂ, Ξ z = 0 → ∃ x : D.dom, (x : H) ≠ 0 ∧ D.op x = z • (x : H)

omit [CompleteSpace H] in
/-- **Theorem 3.1 (All-Real-Zeros Consequence):**
A symmetric spectral realization forces every zero of `Ξ` to be real. -/
theorem allRealZeros_of_spectral_realization {D : SymmetricOp H} {Ξ : ℂ → ℂ}
    (hSpec : SpectralRealization D Ξ) :
    AllRealZeros Ξ := by
  intro z hz
  obtain ⟨x, hx, heig⟩ := hSpec z hz
  exact D.eigenvalue_im_eq_zero hx heig

omit [CompleteSpace H] in
/-- **Theorem 3.2 (Critical-Line Consequence — RH):**
Every zero `ρ` of `ξ(ρ) := Ξ(-i (ρ - 1/2))` lies on `Re(ρ) = 1/2`. -/
theorem re_eq_half_of_spectral_realization {D : SymmetricOp H} {Ξ : ℂ → ℂ}
    (hSpec : SpectralRealization D Ξ) {ρ : ℂ}
    (hzero : Ξ (-Complex.I * (ρ - (1 / 2 : ℂ))) = 0) :
    ρ.re = 1 / 2 := by
  have him := allRealZeros_of_spectral_realization hSpec _ hzero
  simp only [Complex.mul_im, Complex.I_re, Complex.sub_im,
    Complex.neg_im, Complex.I_im, Complex.sub_re, zero_mul, zero_add, neg_mul, one_mul,
    neg_eq_zero] at him
  have hhalf : ((1 / 2 : ℂ)).re = (1 / 2 : ℝ) := by norm_num
  linarith

omit [CompleteSpace H] in
/-- **Theorem 3.3 (Global Li Positivity Consequence):**
Every finite Li sum over nonzero zeros of `ξ` is non-negative for all `n ≥ 1`. -/
theorem liSum_nonneg_of_spectral_realization {D : SymmetricOp H} {Ξ : ℂ → ℂ}
    (hSpec : SpectralRealization D Ξ) (S : Finset ℂ)
    (hZeros : ∀ ρ ∈ S, ρ ≠ 0 ∧ Ξ (-Complex.I * (ρ - (1 / 2 : ℂ))) = 0) (n : ℕ) :
    0 ≤ ∑ ρ ∈ S, liSummand ρ n := by
  refine Finset.sum_nonneg fun ρ hρ => ?_
  obtain ⟨hne, hz⟩ := hZeros ρ hρ
  have hre := re_eq_half_of_spectral_realization hSpec hz
  exact liSummand_nonneg_of_re_ge_half hne hre.ge n

omit [CompleteSpace H] in
/-- **Theorem 3.4 (de Bruijn–Newman Upper Bound `Λ ≤ 0` & Sandwich `Λ = 0`):**
Given a heat-flow family `H_t` with `H_0 = Ξ` that preserves real-rootedness forward in `t`
(Pólya–de Bruijn) and obeys Rodgers–Tao (`0 ≤ Λ`), a spectral realization pins `Λ = 0`. -/
theorem dBN_eq_zero_of_spectral_realization {D : SymmetricOp H} {Ξ : ℂ → ℂ}
    {Flow : ℝ → ℂ → ℂ}
    (hSpec : SpectralRealization D Ξ)
    (hInit : Flow 0 = Ξ)
    (hForward : AllRealZeros (Flow 0) → ∀ s : ℝ, 0 ≤ s → AllRealZeros (Flow s))
    (hRT : 0 ≤ dBNConstant Flow)
    (hBdd : BddBelow { t : ℝ | ∀ s : ℝ, t ≤ s → AllRealZeros (Flow s) }) :
    dBNConstant Flow ≤ 0 ∧ dBNConstant Flow = 0 := by
  have h0_mem : (0 : ℝ) ∈ { t : ℝ | ∀ s : ℝ, t ≤ s → AllRealZeros (Flow s) } := by
    refine hForward ?_
    rw [hInit]
    exact allRealZeros_of_spectral_realization hSpec
  have hUpper : dBNConstant Flow ≤ 0 := csInf_le hBdd h0_mem
  exact ⟨hUpper, le_antisymm hUpper hRT⟩

/-- **Theorem 3.5 (Unified Kato–Rellich Spectral Bridge):**
Combines `katoRellich_closure` for an archimedean self-adjoint generator `D_∞` plus a
relatively bounded symmetric non-archimedean coupling `V_fin` (`a < 1`) with a spectral
realization of `Ξ`, deducing simultaneously:
1. Essential/domain self-adjointness of `D_∞ + V_fin` at all `|μ| > b / (1 - a)`,
2. `AllRealZeros Ξ` (RH),
3. `dBNConstant Flow = 0`, and
4. Non-negativity of all finite Li sums for every `n`. -/
theorem katoRellich_spectral_bridge
    (D_inf : SymmetricOp H) (hD_inf : D_inf.IsSelfAdjoint)
    (V_fin : D_inf.dom →ₗ[ℂ] H)
    (hVsymm : ∀ x y : D_inf.dom, ⟪V_fin x, (y : H)⟫_ℂ = ⟪(x : H), V_fin y⟫_ℂ)
    {a b : ℝ} (ha0 : 0 ≤ a) (ha1 : a < 1) (hb : 0 ≤ b)
    (hRel : ∀ x : D_inf.dom, ‖V_fin x‖ ≤ a * ‖D_inf.op x‖ + b * ‖(x : H)‖)
    {Ξ : ℂ → ℂ} {Flow : ℝ → ℂ → ℂ}
    (hSpec : SpectralRealization (D_inf.addCoupling V_fin hVsymm) Ξ)
    (hInit : Flow 0 = Ξ)
    (hForward : AllRealZeros (Flow 0) → ∀ s : ℝ, 0 ≤ s → AllRealZeros (Flow s))
    (hRT : 0 ≤ dBNConstant Flow)
    (hBdd : BddBelow { t : ℝ | ∀ s : ℝ, t ≤ s → AllRealZeros (Flow s) }) :
    (∀ μ : ℝ, b / (1 - a) < |μ| →
      Function.Bijective (fun x : (D_inf.addCoupling V_fin hVsymm).dom =>
        (D_inf.addCoupling V_fin hVsymm).op x + ((μ : ℂ) * Complex.I) • (x : H))) ∧
    AllRealZeros Ξ ∧
    dBNConstant Flow = 0 ∧
    (∀ (S : Finset ℂ) (n : ℕ),
      (∀ ρ ∈ S, ρ ≠ 0 ∧ Ξ (-Complex.I * (ρ - (1 / 2 : ℂ))) = 0) →
      0 ≤ ∑ ρ ∈ S, liSummand ρ n) :=
  ⟨fun _ hμ => katoRellich_closure D_inf hD_inf V_fin hVsymm ha0 ha1 hb hRel hμ,
   allRealZeros_of_spectral_realization hSpec,
   (dBN_eq_zero_of_spectral_realization hSpec hInit hForward hRT hBdd).2,
   fun S n hZ => liSum_nonneg_of_spectral_realization hSpec S hZ n⟩

end SpectralDeterminantBridge

end Signals.SatoGrassmannian.RemainingGaps
