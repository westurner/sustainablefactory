import Mathlib.Algebra.Order.BigOperators.Group.Finset
import Mathlib.Analysis.Normed.Algebra.Exponential
import Signals.SatoGrassmannian.CircleL2
import Signals.SatoGrassmannian.Gr24Truncation
import Signals.SatoGrassmannian.KPFlow
import Signals.SatoGrassmannian.HirotaKP
import Signals.SatoGrassmannian.SchwingerCocycle
import Signals.SatoGrassmannian.DeterminantBundle

/-!
# Segal–Wilson `det_Fr` = Finite `Gr_ℂ(2, 4)` Schur `τ`-Function

Ported from `data/chats/Gemini_Formalizing-Sato-Grassmannian-in-Lean_20261120-2337.md`
(block 016). Proves:
1. Exponential closure of `gl_(2)(H)` (`exp_mem_gl2ResAlg`) with explicit Hilbert–Schmidt
   norm bound `‖[J, exp A]‖₂² ≤ exp(2 max(1, ‖A‖)) ‖[J, A]‖₂²`.
2. Unipotent shear determinant `det_Fr(I + N) = 1` (`detFr_rankOne_nilpotent_eq_one`) and
   exact 2×2 block lower-triangular reduction `det_Fr(blockLower2) = a d - b c`
   (`detFr_blockLowerTriangular_two`) using only the 4 axioms of `FredholmDetTheory`.
3. Hardy negative basis `hardyMinusBasis`, 3-time KP flow `kpFlow3GL2 ∈ GL_(2)⁰(L²(S¹))`,
   exact big-cell graph realization `graphSubspace (gr24GraphOp v w) = truncSubspace (span {v, w})`,
   and the Segal–Wilson theorem `segalWilson_tau_gr24_eq_tauU`:
   `det_Fr(1 + g(t)₊₋ T_U g(t)₊₊⁻¹) = tauU v w t₁ t₂ t₃ / p₂₃`.
-/

open scoped InnerProductSpace BigOperators

namespace Signals.SatoGrassmannian.SegalWilsonGr24

open Signals.SatoGrassmannian Signals.SatoGrassmannian.CircleL2
open Signals.SatoGrassmannian.Gr24Truncation Signals.SatoGrassmannian.KPFlow
open Signals.SatoGrassmannian.HirotaKP Signals.SatoGrassmannian.SchwingerCocycle
open Signals.SatoGrassmannian.DeterminantBundle

/-! ### Section 1: Exponential Closure of `gl_(2)(H)` -/

section ExpGL2

variable {ιP ιM : Type*} {H : Type*}
  [NormedAddCommGroup H] [InnerProductSpace ℂ H] [CompleteSpace H]

omit [CompleteSpace H] in
lemma tsum_norm_sq_comp_left {ι : Type*} (e : HilbertBasis ι ℂ H) (A T : H →L[ℂ] H)
    (hT : IsHS e T) :
    ∑' i : ι, ‖(A.comp T) (e i)‖ ^ 2 ≤ ‖A‖ ^ 2 * ∑' i : ι, ‖T (e i)‖ ^ 2 := by
  rw [← tsum_mul_left]
  refine Summable.tsum_le_tsum (fun i => ?_) (hT.comp_left A) (hT.mul_left (‖A‖ ^ 2))
  calc ‖A (T (e i))‖ ^ 2 ≤ (‖A‖ * ‖T (e i)‖) ^ 2 :=
        pow_le_pow_left₀ (norm_nonneg _) (A.le_opNorm _) 2
    _ = ‖A‖ ^ 2 * ‖T (e i)‖ ^ 2 := mul_pow _ _ 2

lemma tsum_norm_sq_adjoint {ι : Type*} (e : HilbertBasis ι ℂ H) (T : H →L[ℂ] H) (hT : IsHS e T) :
    ∑' i : ι, ‖ContinuousLinearMap.adjoint T (e i)‖ ^ 2 = ∑' i : ι, ‖T (e i)‖ ^ 2 := by
  let g : ι → ι → ℝ := fun i j => ‖⟪e j, T (e i)⟫_ℂ‖ ^ 2
  have hg_nn : ∀ p : ι × ι, 0 ≤ g.uncurry p := fun _ => sq_nonneg _
  have hg_summ : Summable g.uncurry := by
    rw [summable_prod_of_nonneg hg_nn]
    exact ⟨fun i => (hasSum_norm_inner_sq e (T (e i))).summable,
      hT.congr fun i => (hasSum_norm_inner_sq e (T (e i))).tsum_eq.symm⟩
  have hL : ∑' i : ι, ‖T (e i)‖ ^ 2 = ∑' i : ι, ∑' j : ι, g i j :=
    tsum_congr fun i => (hasSum_norm_inner_sq e (T (e i))).tsum_eq.symm
  have hR : ∑' j : ι, ‖ContinuousLinearMap.adjoint T (e j)‖ ^ 2 = ∑' j : ι, ∑' i : ι, g i j := by
    refine tsum_congr fun j => ?_
    rw [← (hasSum_norm_inner_sq e (ContinuousLinearMap.adjoint T (e j))).tsum_eq]
    refine tsum_congr fun i => ?_
    dsimp [g]
    rw [ContinuousLinearMap.adjoint_inner_right, ← inner_conj_symm (T (e i)) (e j), RCLike.norm_conj]
  rw [hL, hR]
  let b : ι → ι → ℝ := fun j i => g i j
  have hJoint' : Summable b.uncurry :=
    (hg_summ.comp_injective (Equiv.prodComm ι ι).injective).congr fun ⟨_, _⟩ => rfl
  exact (Summable.tsum_comm' (f := b) hJoint'
    (fun j => ((hasSum_norm_inner_sq e (ContinuousLinearMap.adjoint T (e j))).summable).congr fun i => by
      dsimp [b, g]
      rw [ContinuousLinearMap.adjoint_inner_right, ← inner_conj_symm (T (e i)) (e j), RCLike.norm_conj])
    (fun i => (hasSum_norm_inner_sq e (T (e i))).summable)).symm

lemma tsum_norm_sq_comp_right {ι : Type*} (e : HilbertBasis ι ℂ H) (T B : H →L[ℂ] H)
    (hT : IsHS e T) :
    ∑' i : ι, ‖(T.comp B) (e i)‖ ^ 2 ≤ ‖B‖ ^ 2 * ∑' i : ι, ‖T (e i)‖ ^ 2 := by
  have hTB : IsHS e (T.comp B) := hT.comp_right (eF := e) B
  rw [← tsum_norm_sq_adjoint e (T.comp B) hTB, ContinuousLinearMap.adjoint_comp]
  calc ∑' i : ι, ‖((ContinuousLinearMap.adjoint B).comp (ContinuousLinearMap.adjoint T)) (e i)‖ ^ 2
      ≤ ‖ContinuousLinearMap.adjoint B‖ ^ 2 * ∑' i : ι, ‖ContinuousLinearMap.adjoint T (e i)‖ ^ 2 :=
        tsum_norm_sq_comp_left e _ _ (hT.adjoint (eF := e))
    _ = ‖B‖ ^ 2 * ∑' i : ι, ‖T (e i)‖ ^ 2 := by
        rw [LinearIsometryEquiv.norm_map, tsum_norm_sq_adjoint e T hT]

omit [CompleteSpace H] in
/-- Derivation formula for powers: `[J, A^k] = ∑_{r < k} A^r [J, A] A^{k-1-r}`. -/
lemma comm_pow_eq_sum (J A : H →L[ℂ] H) (k : ℕ) :
    J * A ^ k - A ^ k * J =
      ∑ r ∈ Finset.range k, A ^ r * (J * A - A * J) * A ^ (k - 1 - r) := by
  induction k with
  | zero => simp
  | succ k ih =>
    rw [Finset.sum_range_succ, Nat.add_sub_cancel, Nat.sub_self, pow_zero, mul_one]
    have hshift : ∑ r ∈ Finset.range k, A ^ r * (J * A - A * J) * A ^ (k - r) =
        (∑ r ∈ Finset.range k, A ^ r * (J * A - A * J) * A ^ (k - 1 - r)) * A := by
      rw [Finset.sum_mul]
      refine Finset.sum_congr rfl fun r hr => ?_
      have hlt : r < k := Finset.mem_range.mp hr
      have hexp : k - r = (k - 1 - r) + 1 := by omega
      rw [hexp, pow_succ]
      noncomm_ring
    rw [hshift, ← ih, pow_succ]
    noncomm_ring

/-- **Theorem 2.1 (Exponential Closure of `gl_(2)(H)`):**
For every `A ∈ gl_(2)(H)`, `exp(A) ∈ gl_(2)(H)` with explicit HS bound
`‖[J, exp A]‖₂² ≤ exp(2 max(1, ‖A‖)) ‖[J, A]‖₂²`. -/
theorem exp_mem_gl2ResAlg (P : PolarizedHilbertSpace ℂ H)
    (eP : HilbertBasis ιP ℂ P.HPlus) (eM : HilbertBasis ιM ℂ P.HMinus)
    {A : H →L[ℂ] H} (hA : A ∈ gl2ResAlg P eP eM) :
    NormedSpace.exp A ∈ gl2ResAlg P eP eM := by
  let _ : NormedAlgebra ℚ (H →L[ℂ] H) := NormedAlgebra.restrictScalars ℚ ℂ (H →L[ℂ] H)
  let eH := polarizedBasis P eP eM
  let J := polarizationJ P
  let C := J * A - A * J
  have hC : IsHS eH C := (isHS_commutator_J_iff P eP eM A).mpr hA
  let SC : ℝ := ∑' i, ‖C (eH i)‖ ^ 2
  have hSC_nn : 0 ≤ SC := tsum_nonneg fun _ => sq_nonneg _
  let R : ℝ := max 1 ‖A‖
  have hR1 : 1 ≤ R := le_max_left 1 ‖A‖
  have hR_pos : 0 < R := lt_of_lt_of_le zero_lt_one hR1
  have hA_le : ‖A‖ ≤ R := le_max_right 1 ‖A‖
  have hPowNorm : ∀ m : ℕ, ‖A ^ m‖ ≤ R ^ m := by
    intro m
    rcases Nat.eq_zero_or_pos m with rfl | hpos
    · rw [pow_zero, pow_zero]
      exact ContinuousLinearMap.norm_id_le (𝕜 := ℂ) (E := H)
    · exact le_trans (norm_pow_le' A hpos) (pow_le_pow_left₀ (norm_nonneg A) hA_le m)
  let Ck : ℕ → (H →L[ℂ] H) := fun k => J * A ^ k - A ^ k * J
  have hCk_HS : ∀ k : ℕ, IsHS eH (Ck k) := by
    intro k
    have hpow : A ^ k ∈ gl2ResAlg P eP eM := Subalgebra.pow_mem _ hA k
    exact (isHS_commutator_J_iff P eP eM (A ^ k)).mpr hpow
  have hCk_bound : ∀ k : ℕ, 1 ≤ k →
      ∑' i, ‖Ck k (eH i)‖ ^ 2 ≤ (k : ℝ) ^ 2 * R ^ (2 * (k - 1)) * SC := by
    intro k hk
    let Tr : ℕ → H →L[ℂ] H := fun r => A ^ r * C * A ^ (k - 1 - r)
    have hpoint : ∀ i, ‖Ck k (eH i)‖ ^ 2 ≤
        (k : ℝ) * ∑ r ∈ Finset.range k, ‖Tr r (eH i)‖ ^ 2 := by
      intro i
      have heq : Ck k (eH i) = ∑ r ∈ Finset.range k, Tr r (eH i) := by
        dsimp [Ck, Tr, C]
        rw [comm_pow_eq_sum J A k, sum_apply]
      rw [heq]
      have htri : ‖∑ r ∈ Finset.range k, Tr r (eH i)‖ ≤
          ∑ r ∈ Finset.range k, ‖Tr r (eH i)‖ := norm_sum_le _ _
      have hcs := Finset.sum_mul_sq_le_sq_mul_sq (Finset.range k) (fun _ => (1 : ℝ))
        (fun r => ‖Tr r (eH i)‖)
      simp only [one_mul, one_pow, Finset.sum_const, Finset.card_range, nsmul_eq_mul, mul_one] at hcs
      calc ‖∑ r ∈ Finset.range k, Tr r (eH i)‖ ^ 2
          ≤ (∑ r ∈ Finset.range k, ‖Tr r (eH i)‖) ^ 2 :=
            pow_le_pow_left₀ (norm_nonneg _) htri 2
        _ ≤ (k : ℝ) * ∑ r ∈ Finset.range k, ‖Tr r (eH i)‖ ^ 2 := hcs
    have hterm_HS : ∀ r, Summable (fun i => ‖Tr r (eH i)‖ ^ 2) := fun r =>
      (hC.comp_left (A ^ r)).comp_right (eF := eH) (A ^ (k - 1 - r))
    have hfin_HS : ∀ s : Finset ℕ, Summable (fun i => ∑ r ∈ s, ‖Tr r (eH i)‖ ^ 2) := by
      intro s
      classical
      induction s using Finset.induction_on with
      | empty => simp
      | @insert r s hr ih =>
        exact ((hterm_HS r).add ih).congr fun i =>
          (Finset.sum_insert (f := fun r' => ‖Tr r' (eH i)‖ ^ 2) hr).symm
    have htsum_swap : ∀ s : Finset ℕ,
        ∑' i, (∑ r ∈ s, ‖Tr r (eH i)‖ ^ 2) = ∑ r ∈ s, ∑' i, ‖Tr r (eH i)‖ ^ 2 := by
      intro s
      classical
      induction s using Finset.induction_on with
      | empty => simp
      | @insert r s hr ih =>
        have h1 : (fun i => ∑ r' ∈ insert r s, ‖Tr r' (eH i)‖ ^ 2) =
            fun i => ‖Tr r (eH i)‖ ^ 2 + ∑ r' ∈ s, ‖Tr r' (eH i)‖ ^ 2 := by
          funext i; exact Finset.sum_insert hr
        rw [h1, (hterm_HS r).tsum_add (hfin_HS s), ih, Finset.sum_insert hr]
    have hSumHS : Summable (fun i => (k : ℝ) * ∑ r ∈ Finset.range k, ‖Tr r (eH i)‖ ^ 2) :=
      (hfin_HS (Finset.range k)).mul_left (k : ℝ)
    calc ∑' i, ‖Ck k (eH i)‖ ^ 2
        ≤ ∑' i, ((k : ℝ) * ∑ r ∈ Finset.range k, ‖Tr r (eH i)‖ ^ 2) :=
          Summable.tsum_le_tsum hpoint (hCk_HS k) hSumHS
      _ = (k : ℝ) * ∑ r ∈ Finset.range k, ∑' i, ‖Tr r (eH i)‖ ^ 2 := by
          rw [tsum_mul_left, htsum_swap (Finset.range k)]
      _ ≤ (k : ℝ) * ∑ r ∈ Finset.range k, R ^ (2 * (k - 1)) * SC := by
          refine mul_le_mul_of_nonneg_left (Finset.sum_le_sum fun r hr => ?_) (Nat.cast_nonneg k)
          have hlt : r < k := Finset.mem_range.mp hr
          have h1 := tsum_norm_sq_comp_right eH (A ^ r * C) (A ^ (k - 1 - r)) (hC.comp_left (A ^ r))
          have h2 := tsum_norm_sq_comp_left eH (A ^ r) C hC
          have hexp : 2 * (k - 1 - r) + 2 * r = 2 * (k - 1) := by omega
          calc ∑' i, ‖Tr r (eH i)‖ ^ 2
              ≤ ‖A ^ (k - 1 - r)‖ ^ 2 * (‖A ^ r‖ ^ 2 * SC) :=
                le_trans h1 (mul_le_mul_of_nonneg_left h2 (sq_nonneg _))
            _ ≤ (R ^ (k - 1 - r)) ^ 2 * ((R ^ r) ^ 2 * SC) := by
                refine mul_le_mul (pow_le_pow_left₀ (norm_nonneg _) (hPowNorm _) 2)
                  (mul_le_mul_of_nonneg_right (pow_le_pow_left₀ (norm_nonneg _) (hPowNorm _) 2) hSC_nn)
                  (by positivity) (by positivity)
            _ = R ^ (2 * (k - 1)) * SC := by
                rw [← mul_assoc, ← pow_mul, ← pow_mul, mul_comm (k - 1 - r) 2, mul_comm r 2,
                  ← pow_add, hexp]
      _ = (k : ℝ) ^ 2 * R ^ (2 * (k - 1)) * SC := by
          rw [Finset.sum_const, Finset.card_range, nsmul_eq_mul]; ring
  change IsHS eM _ ∧ IsHS eP _
  rw [← isHS_commutator_J_iff]
  refine summable_of_sum_le (c := Real.exp (2 * R) * SC) (fun _ => sq_nonneg _) fun s => ?_
  let F : ℕ → H →L[ℂ] H := fun N => ∑ k ∈ Finset.Ico 1 (N + 1), (k.factorial : ℂ)⁻¹ • Ck k
  have hFtend : Filter.Tendsto (fun N => ∑ i ∈ s, ‖F N (eH i)‖ ^ 2) Filter.atTop
      (nhds (∑ i ∈ s, ‖(J * NormedSpace.exp A - NormedSpace.exp A * J) (eH i)‖ ^ 2)) := by
    have hExp : HasSum (fun k : ℕ => (k.factorial : ℂ)⁻¹ • A ^ k) (NormedSpace.exp A) :=
      hasSum_exp_terms A
    have hComm : HasSum (fun k : ℕ => (k.factorial : ℂ)⁻¹ • Ck k)
        (J * NormedSpace.exp A - NormedSpace.exp A * J) := by
      have h := (hExp.mul_left J).sub (hExp.mul_right J)
      refine h.congr_fun fun k => ?_
      dsimp [Ck]; rw [Algebra.mul_smul_comm, Algebra.smul_mul_assoc, ← smul_sub]
    have hF_op : Filter.Tendsto F Filter.atTop (nhds (J * NormedSpace.exp A - NormedSpace.exp A * J)) := by
      have h0 : ((0 : ℕ).factorial : ℂ)⁻¹ • Ck 0 = 0 := by simp [Ck]
      have heq : ∀ N, F N = ∑ k ∈ Finset.range (N + 1), (k.factorial : ℂ)⁻¹ • Ck k := by
        intro N; dsimp [F]
        rw [Finset.range_eq_Ico, Finset.sum_eq_sum_Ico_succ_bot (Nat.succ_pos N), h0, zero_add]
      have hF_fun : F = fun N => ∑ k ∈ Finset.range (N + 1), (k.factorial : ℂ)⁻¹ • Ck k :=
        funext heq
      rw [hF_fun]
      exact hComm.tendsto_sum_nat.comp (Filter.tendsto_add_atTop_nat 1)
    refine tendsto_finsetSum s fun i _ => ?_
    have hev := ((ContinuousLinearMap.apply ℂ H (eH i)).continuous.tendsto _).comp hF_op
    exact (continuous_norm.pow 2).continuousAt.tendsto.comp hev
  refine le_of_tendsto hFtend (Filter.Eventually.of_forall fun N => ?_)
  let a : ℕ → ℝ := fun k => R ^ (k - 1) / ((k - 1).factorial : ℝ)
  have ha_pos : ∀ k, 0 < a k := fun k => div_pos (pow_pos hR_pos _) (by exact_mod_cast Nat.factorial_pos _)
  have ha_sum_le : ∑ k ∈ Finset.Ico 1 (N + 1), a k ≤ Real.exp R := by
    have hshift : ∑ k ∈ Finset.Ico 1 (N + 1), a k = ∑ m ∈ Finset.range N, R ^ m / (m.factorial : ℝ) := by
      refine Finset.sum_bij (fun k _ => k - 1) (fun k hk => Finset.mem_range.mpr (by
        have := Finset.mem_Ico.mp hk; omega))
        (fun k₁ hk₁ k₂ hk₂ h => by
          have := Finset.mem_Ico.mp hk₁; have := Finset.mem_Ico.mp hk₂; omega)
        (fun m hm => ⟨m + 1, Finset.mem_Ico.mpr ⟨by omega, by
          have := Finset.mem_range.mp hm; omega⟩, by simp⟩)
        (fun k _ => rfl)
    rw [hshift, Real.exp_eq_exp_ℝ, NormedSpace.exp_eq_tsum_div]
    exact (Real.summable_pow_div_factorial R).sum_le_tsum (Finset.range N) (fun m _ => by positivity)
  have hpoint_N : ∀ i, ‖F N (eH i)‖ ^ 2 ≤
      Real.exp R * ∑ k ∈ Finset.Ico 1 (N + 1),
        (1 / (a k * (k.factorial : ℝ) ^ 2)) * ‖Ck k (eH i)‖ ^ 2 := by
    intro i
    have hF_eval : F N (eH i) = ∑ k ∈ Finset.Ico 1 (N + 1), (k.factorial : ℂ)⁻¹ • Ck k (eH i) := by
      simp [F]
    rw [hF_eval]
    have htri : ‖∑ k ∈ Finset.Ico 1 (N + 1), (k.factorial : ℂ)⁻¹ • Ck k (eH i)‖ ≤
        ∑ k ∈ Finset.Ico 1 (N + 1), (k.factorial : ℝ)⁻¹ * ‖Ck k (eH i)‖ := by
      refine le_trans (norm_sum_le _ _) (le_of_eq (Finset.sum_congr rfl fun k _ => ?_))
      rw [norm_smul, norm_inv, Complex.norm_natCast]
    have hcs := Finset.sum_mul_sq_le_sq_mul_sq (Finset.Ico 1 (N + 1))
      (fun k => Real.sqrt (a k))
      (fun k => ((k.factorial : ℝ)⁻¹ * ‖Ck k (eH i)‖) / Real.sqrt (a k))
    have hsimpL : ∑ k ∈ Finset.Ico 1 (N + 1),
        Real.sqrt (a k) * (((k.factorial : ℝ)⁻¹ * ‖Ck k (eH i)‖) / Real.sqrt (a k)) =
        ∑ k ∈ Finset.Ico 1 (N + 1), (k.factorial : ℝ)⁻¹ * ‖Ck k (eH i)‖ :=
      Finset.sum_congr rfl fun k _ => mul_div_cancel₀ _ (Real.sqrt_pos.mpr (ha_pos k)).ne'
    have hsimpR1 : ∑ k ∈ Finset.Ico 1 (N + 1), Real.sqrt (a k) ^ 2 =
        ∑ k ∈ Finset.Ico 1 (N + 1), a k :=
      Finset.sum_congr rfl fun k _ => Real.sq_sqrt (ha_pos k).le
    have hsimpR2 : ∑ k ∈ Finset.Ico 1 (N + 1),
        (((k.factorial : ℝ)⁻¹ * ‖Ck k (eH i)‖) / Real.sqrt (a k)) ^ 2 =
        ∑ k ∈ Finset.Ico 1 (N + 1), (1 / (a k * (k.factorial : ℝ) ^ 2)) * ‖Ck k (eH i)‖ ^ 2 :=
      Finset.sum_congr rfl fun k _ => by
        rw [div_pow, mul_pow, inv_pow, Real.sq_sqrt (ha_pos k).le]; ring
    rw [hsimpL, hsimpR1, hsimpR2] at hcs
    calc ‖∑ k ∈ Finset.Ico 1 (N + 1), (k.factorial : ℂ)⁻¹ • Ck k (eH i)‖ ^ 2
        ≤ (∑ k ∈ Finset.Ico 1 (N + 1), (k.factorial : ℝ)⁻¹ * ‖Ck k (eH i)‖) ^ 2 :=
          pow_le_pow_left₀ (norm_nonneg _) htri 2
      _ ≤ (∑ k ∈ Finset.Ico 1 (N + 1), a k) *
            ∑ k ∈ Finset.Ico 1 (N + 1), (1 / (a k * (k.factorial : ℝ) ^ 2)) * ‖Ck k (eH i)‖ ^ 2 := hcs
      _ ≤ Real.exp R *
            ∑ k ∈ Finset.Ico 1 (N + 1), (1 / (a k * (k.factorial : ℝ) ^ 2)) * ‖Ck k (eH i)‖ ^ 2 := by
          refine mul_le_mul_of_nonneg_right ha_sum_le (Finset.sum_nonneg fun k _ => ?_)
          have := ha_pos k; positivity
  calc ∑ i ∈ s, ‖F N (eH i)‖ ^ 2
      ≤ ∑ i ∈ s, Real.exp R * ∑ k ∈ Finset.Ico 1 (N + 1),
          (1 / (a k * (k.factorial : ℝ) ^ 2)) * ‖Ck k (eH i)‖ ^ 2 :=
        Finset.sum_le_sum fun i _ => hpoint_N i
    _ = Real.exp R * ∑ k ∈ Finset.Ico 1 (N + 1),
          (1 / (a k * (k.factorial : ℝ) ^ 2)) * ∑ i ∈ s, ‖Ck k (eH i)‖ ^ 2 := by
        rw [← Finset.mul_sum, Finset.sum_comm]
        congr 1; exact Finset.sum_congr rfl fun k _ => (Finset.mul_sum _ _ _).symm
    _ ≤ Real.exp R * ∑ k ∈ Finset.Ico 1 (N + 1), a k * SC := by
        refine mul_le_mul_of_nonneg_left (Finset.sum_le_sum fun k hk => ?_) (Real.exp_pos R).le
        have hk1 : 1 ≤ k := (Finset.mem_Ico.mp hk).1
        have htsum_le : ∑ i ∈ s, ‖Ck k (eH i)‖ ^ 2 ≤ (k : ℝ) ^ 2 * R ^ (2 * (k - 1)) * SC :=
          le_trans ((hCk_HS k).sum_le_tsum s (fun _ _ => sq_nonneg _)) (hCk_bound k hk1)
        have hcoeff_nn : 0 ≤ 1 / (a k * (k.factorial : ℝ) ^ 2) := by
          have := ha_pos k; positivity
        calc (1 / (a k * (k.factorial : ℝ) ^ 2)) * ∑ i ∈ s, ‖Ck k (eH i)‖ ^ 2
            ≤ (1 / (a k * (k.factorial : ℝ) ^ 2)) * ((k : ℝ) ^ 2 * R ^ (2 * (k - 1)) * SC) :=
              mul_le_mul_of_nonneg_left htsum_le hcoeff_nn
          _ = a k * SC := by
              have hfac : (k.factorial : ℝ) = (k : ℝ) * ((k - 1).factorial : ℝ) := by
                exact_mod_cast (Nat.mul_factorial_pred (show k ≠ 0 by omega)).symm
              have hk_ne : (k : ℝ) ≠ 0 := by exact_mod_cast (show k ≠ 0 by omega)
              have hkf_ne : ((k - 1).factorial : ℝ) ≠ 0 := by exact_mod_cast Nat.factorial_ne_zero _
              have hRp_ne : R ^ (k - 1) ≠ 0 := pow_ne_zero _ hR_pos.ne'
              dsimp [a]; rw [hfac, pow_mul' R 2 (k - 1)]
              field_simp [hk_ne, hkf_ne, hRp_ne]
    _ = Real.exp R * ((∑ k ∈ Finset.Ico 1 (N + 1), a k) * SC) := by rw [Finset.sum_mul]
    _ ≤ Real.exp R * (Real.exp R * SC) := by
        refine mul_le_mul_of_nonneg_left (mul_le_mul_of_nonneg_right ha_sum_le hSC_nn) (Real.exp_pos R).le
    _ = Real.exp (2 * R) * SC := by rw [← mul_assoc, ← Real.exp_add, two_mul]

end ExpGL2

/-! ### Section 2: `det_Fr` of Block Lower-Triangular Rank-2 Perturbations (Zero Extra Axioms) -/

section BlockLowerTriangularDet

variable {ιM : Type*} {H : Type*}
  [NormedAddCommGroup H] [InnerProductSpace ℂ H] [CompleteSpace H]

/-- **Lemma 2.1 (Unipotent Shear Determinant = 1):**
For any `j : ℕ` and vector `v ⊥ e_j`, `det_Fr(I + ⟨e_j, ·⟩ v) = 1`, derived solely
from the 4 axioms of `FredholmDetTheory`. -/
theorem detFr_rankOne_nilpotent_eq_one {P : PolarizedHilbertSpace ℂ H}
    {eP : HilbertBasis ℕ ℂ P.HPlus} {eM : HilbertBasis ιM ℂ P.HMinus}
    [FredholmDetTheory P eP eM] (j : ℕ) (v : P.HPlus) (hv : ⟪eP j, v⟫_ℂ = 0) :
    let N : P.HPlus →L[ℂ] P.HPlus := (innerSL ℂ (eP j)).smulRight v
    have hMem : ContinuousLinearMap.id ℂ P.HPlus + N ∈ TraceClassMonoid P eP eM := by
      change (ContinuousLinearMap.id ℂ P.HPlus + N) - ContinuousLinearMap.id ℂ P.HPlus ∈ TraceClassIdeal P eP eM
      rw [add_sub_cancel_left]
      have hle : LinearMap.range N.toLinearMap ≤ Submodule.span ℂ ({v} : Set P.HPlus) := by
        rintro _ ⟨x, rfl⟩; exact Submodule.smul_mem _ _ (Submodule.subset_span rfl)
      have : FiniteDimensional ℂ (Submodule.span ℂ ({v} : Set P.HPlus)) :=
        FiniteDimensional.span_of_finite ℂ (Set.finite_singleton v)
      have : FiniteDimensional ℂ (LinearMap.range N.toLinearMap) :=
        FiniteDimensional.of_injective (Submodule.inclusion hle) (Submodule.inclusion_injective hle)
      exact TraceClassIdeal.of_finiteDimensional_range N
    FredholmDetTheory.detFr ⟨ContinuousLinearMap.id ℂ P.HPlus + N, hMem⟩ = 1 := by
  intro N hMem
  have hN2 : N * N = 0 := by
    apply ContinuousLinearMap.ext; intro x
    change N (N x) = 0
    simp only [N, ContinuousLinearMap.smulRight_apply, innerSL_apply_apply,
      inner_smul_right, hv, mul_zero, zero_smul]
  have hBij : Function.Bijective (ContinuousLinearMap.id ℂ P.HPlus + N) := by
    refine Function.bijective_iff_has_inverse.mpr ⟨ContinuousLinearMap.id ℂ P.HPlus - N, ?_, ?_⟩
    · intro x
      change ((1 - N) * (1 + N)) x = x
      have h1 : (1 - N) * (1 + N) = (1 : P.HPlus →L[ℂ] P.HPlus) := by
        rw [sub_mul, one_mul, mul_add, mul_one, hN2, add_zero, add_sub_cancel_right]
      rw [h1]; rfl
    · intro x
      change ((1 + N) * (1 - N)) x = x
      have h1 : (1 + N) * (1 - N) = (1 : P.HPlus →L[ℂ] P.HPlus) := by
        rw [add_mul, one_mul, mul_sub, mul_one, hN2, sub_zero, sub_add_cancel]
      rw [h1]; rfl
  have hNe : FredholmDetTheory.detFr ⟨ContinuousLinearMap.id ℂ P.HPlus + N, hMem⟩ ≠ 0 :=
    (FredholmDetTheory.detFr_ne_zero_iff _).mpr hBij
  let cHalf : ℂˣ := Units.mk0 (1 / 2 : ℂ) (by norm_num)
  let q : P.HPlus ≃L[ℂ] P.HPlus := (rankOneTraceClassEquiv P eP eM j cHalf).1
  have hjj : ⟪eP j, eP j⟫_ℂ = 1 := by
    rw [inner_self_eq_norm_sq_to_K, eP.orthonormal.1 j]; norm_num
  have hConjEq : (q : P.HPlus →L[ℂ] P.HPlus) * (ContinuousLinearMap.id ℂ P.HPlus + N) *
      (q.symm : P.HPlus →L[ℂ] P.HPlus) =
      (ContinuousLinearMap.id ℂ P.HPlus + N) * (ContinuousLinearMap.id ℂ P.HPlus + N) := by
    apply ContinuousLinearMap.ext; intro x
    have hq_v : q v = v := by
      simp [q, rankOneTraceClassEquiv, rankOneScale, hv]
    have hq_inv : ⟪eP j, q.symm x⟫_ℂ = 2 * ⟪eP j, x⟫_ℂ := by
      have hcinv : ((cHalf⁻¹ : ℂˣ) : ℂ) = 2 := by
        rw [Units.val_inv_eq_inv_val]; norm_num [cHalf]
      change ⟪eP j, rankOneScale P eP j ((cHalf⁻¹ : ℂˣ) : ℂ) x⟫_ℂ = _
      rw [hcinv]
      simp only [rankOneScale, add_apply, ContinuousLinearMap.id_apply, smul_apply,
        ContinuousLinearMap.smulRight_apply, innerSL_apply_apply, inner_add_right,
        inner_smul_right, hjj, mul_one]
      ring
    have hLHS : ((q : P.HPlus →L[ℂ] P.HPlus) * (ContinuousLinearMap.id ℂ P.HPlus + N) *
        (q.symm : P.HPlus →L[ℂ] P.HPlus)) x = x + (2 * ⟪eP j, x⟫_ℂ) • v := by
      change q (q.symm x + N (q.symm x)) = _
      rw [map_add, q.apply_symm_apply]
      simp only [N, ContinuousLinearMap.smulRight_apply, innerSL_apply_apply, map_smul, hq_v, hq_inv]
    have hRHS : ((ContinuousLinearMap.id ℂ P.HPlus + N) * (ContinuousLinearMap.id ℂ P.HPlus + N)) x =
        x + (2 * ⟪eP j, x⟫_ℂ) • v := by
      have hsq : (1 + N) * (1 + N) = (1 : P.HPlus →L[ℂ] P.HPlus) + (2 : ℂ) • N := by
        have h1 : (1 + N) * (1 + N) = (1 : P.HPlus →L[ℂ] P.HPlus) + N + N + N * N := by noncomm_ring
        rw [h1, hN2, add_zero, add_assoc, ← two_smul ℂ N]
      change ((1 + N) * (1 + N)) x = _
      rw [hsq]
      simp [N, smul_smul]
    rw [hLHS, hRHS]
  have hDetSq : FredholmDetTheory.detFr ⟨ContinuousLinearMap.id ℂ P.HPlus + N, hMem⟩ =
      FredholmDetTheory.detFr ⟨ContinuousLinearMap.id ℂ P.HPlus + N, hMem⟩ *
      FredholmDetTheory.detFr ⟨ContinuousLinearMap.id ℂ P.HPlus + N, hMem⟩ := by
    have hc := FredholmDetTheory.detFr_conj q ⟨ContinuousLinearMap.id ℂ P.HPlus + N, hMem⟩
    have hm := (FredholmDetTheory.detFr (P := P) (eP := eP) (eM := eM)).map_mul
      ⟨ContinuousLinearMap.id ℂ P.HPlus + N, hMem⟩ ⟨ContinuousLinearMap.id ℂ P.HPlus + N, hMem⟩
    calc FredholmDetTheory.detFr ⟨ContinuousLinearMap.id ℂ P.HPlus + N, hMem⟩
        = FredholmDetTheory.detFr
            ⟨(q : P.HPlus →L[ℂ] P.HPlus) * (ContinuousLinearMap.id ℂ P.HPlus + N) *
              (q.symm : P.HPlus →L[ℂ] P.HPlus),
              traceClassMonoid_conj P eP eM q hMem⟩ := hc.symm
      _ = FredholmDetTheory.detFr
            (⟨ContinuousLinearMap.id ℂ P.HPlus + N, hMem⟩ *
             ⟨ContinuousLinearMap.id ℂ P.HPlus + N, hMem⟩) :=
          congrArg _ (Subtype.ext hConjEq)
      _ = _ := hm
  exact mul_left_cancel₀ hNe (by simpa [mul_one] using hDetSq.symm)

/-- Block lower-triangular perturbation of `I` supported on `span {e₀, e₁} → H₊`:
`L(a, b, c, d, b₀, b₁) x = x + ⟨e₀, x⟩ ((a-1)e₀ + c e₁ + b₀) + ⟨e₁, x⟩ (b e₀ + (d-1)e₁ + b₁)`. -/
noncomputable def blockLower2 {P : PolarizedHilbertSpace ℂ H} (eP : HilbertBasis ℕ ℂ P.HPlus)
    (a b c d : ℂ) (b₀ b₁ : P.HPlus) : P.HPlus →L[ℂ] P.HPlus :=
  ContinuousLinearMap.id ℂ P.HPlus +
    (innerSL ℂ (eP 0)).smulRight ((a - 1) • eP 0 + c • eP 1 + b₀) +
    (innerSL ℂ (eP 1)).smulRight (b • eP 0 + (d - 1) • eP 1 + b₁)

lemma blockLower2_mem_monoid {P : PolarizedHilbertSpace ℂ H}
    {eP : HilbertBasis ℕ ℂ P.HPlus} {eM : HilbertBasis ιM ℂ P.HMinus}
    (a b c d : ℂ) (b₀ b₁ : P.HPlus) :
    blockLower2 eP a b c d b₀ b₁ ∈ TraceClassMonoid P eP eM := by
  let v₀ := (a - 1) • eP 0 + c • eP 1 + b₀
  let v₁ := b • eP 0 + (d - 1) • eP 1 + b₁
  let F : P.HPlus →L[ℂ] P.HPlus := (innerSL ℂ (eP 0)).smulRight v₀ + (innerSL ℂ (eP 1)).smulRight v₁
  have hsub : blockLower2 eP a b c d b₀ b₁ - ContinuousLinearMap.id ℂ P.HPlus = F := by
    unfold blockLower2; dsimp [F, v₀, v₁]; abel
  change blockLower2 eP a b c d b₀ b₁ - ContinuousLinearMap.id ℂ P.HPlus ∈ TraceClassIdeal P eP eM
  rw [hsub]
  have hle : LinearMap.range F.toLinearMap ≤ Submodule.span ℂ ({v₀, v₁} : Set P.HPlus) := by
    rintro _ ⟨x, rfl⟩
    exact Submodule.add_mem _
      (Submodule.smul_mem _ _ (Submodule.subset_span (Set.mem_insert v₀ _)))
      (Submodule.smul_mem _ _ (Submodule.subset_span (Set.mem_insert_of_mem v₀ rfl)))
  have : FiniteDimensional ℂ (Submodule.span ℂ ({v₀, v₁} : Set P.HPlus)) :=
    FiniteDimensional.span_of_finite ℂ ((Set.finite_singleton v₁).insert v₀)
  have : FiniteDimensional ℂ (LinearMap.range F.toLinearMap) :=
    FiniteDimensional.of_injective (Submodule.inclusion hle) (Submodule.inclusion_injective hle)
  exact TraceClassIdeal.of_finiteDimensional_range F

lemma blockLower2_mul_zero {P : PolarizedHilbertSpace ℂ H} (eP : HilbertBasis ℕ ℂ P.HPlus)
    (a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂ : ℂ) :
    blockLower2 eP a₁ b₁ c₁ d₁ 0 0 * blockLower2 eP a₂ b₂ c₂ d₂ 0 0 =
      blockLower2 eP (a₁ * a₂ + b₁ * c₂) (a₁ * b₂ + b₁ * d₂)
                     (c₁ * a₂ + d₁ * c₂) (c₁ * b₂ + d₁ * d₂) 0 0 := by
  have h00 : ⟪eP 0, eP 0⟫_ℂ = 1 := by simpa using orthonormal_iff_ite.mp eP.orthonormal 0 0
  have h11 : ⟪eP 1, eP 1⟫_ℂ = 1 := by simpa using orthonormal_iff_ite.mp eP.orthonormal 1 1
  have h01 : ⟪eP 0, eP 1⟫_ℂ = 0 := by simpa using orthonormal_iff_ite.mp eP.orthonormal 0 1
  have h10 : ⟪eP 1, eP 0⟫_ℂ = 0 := by simpa using orthonormal_iff_ite.mp eP.orthonormal 1 0
  apply ContinuousLinearMap.ext; intro x
  change blockLower2 eP a₁ b₁ c₁ d₁ 0 0 (blockLower2 eP a₂ b₂ c₂ d₂ 0 0 x) = _
  simp only [blockLower2, add_apply, ContinuousLinearMap.id_apply,
    ContinuousLinearMap.smulRight_apply, innerSL_apply_apply,
    add_zero, inner_add_right, inner_smul_right, h00, h11, h01, h10, mul_one, mul_zero,
    zero_add]
  module

/-- **Theorem 2.2 (Exact 2×2 Block Reduction of `det_Fr`):**
For any `a, b, c, d ∈ ℂ` and `b₀, b₁ ⊥ {e₀, e₁}`,
`det_Fr(blockLower2 eP a b c d b₀ b₁) = a * d - b * c`. -/
theorem detFr_blockLowerTriangular_two {P : PolarizedHilbertSpace ℂ H}
    {eP : HilbertBasis ℕ ℂ P.HPlus} {eM : HilbertBasis ιM ℂ P.HMinus}
    [FredholmDetTheory P eP eM]
    (a b c d : ℂ) (b₀ b₁ : P.HPlus)
    (hb00 : ⟪eP 0, b₀⟫_ℂ = 0) (hb10 : ⟪eP 1, b₀⟫_ℂ = 0)
    (hb01 : ⟪eP 0, b₁⟫_ℂ = 0) (hb11 : ⟪eP 1, b₁⟫_ℂ = 0) :
    FredholmDetTheory.detFr (P := P) (eP := eP) (eM := eM)
      ⟨blockLower2 eP a b c d b₀ b₁, blockLower2_mem_monoid a b c d b₀ b₁⟩ =
      a * d - b * c := by
  have h00 : ⟪eP 0, eP 0⟫_ℂ = 1 := by simpa using orthonormal_iff_ite.mp eP.orthonormal 0 0
  have h11 : ⟪eP 1, eP 1⟫_ℂ = 1 := by simpa using orthonormal_iff_ite.mp eP.orthonormal 1 1
  have h01 : ⟪eP 0, eP 1⟫_ℂ = 0 := by simpa using orthonormal_iff_ite.mp eP.orthonormal 0 1
  have h10 : ⟪eP 1, eP 0⟫_ℂ = 0 := by simpa using orthonormal_iff_ite.mp eP.orthonormal 1 0
  let detF := FredholmDetTheory.detFr (P := P) (eP := eP) (eM := eM)
  have hDiag : ∀ lam₀ lam₁ : ℂ,
      detF ⟨blockLower2 eP lam₀ 0 0 lam₁ 0 0, blockLower2_mem_monoid _ _ _ _ _ _⟩ =
        lam₀ * lam₁ := by
    intro lam₀ lam₁
    have heq : blockLower2 eP lam₀ 0 0 lam₁ 0 0 = rankOneScale P eP 0 lam₀ * rankOneScale P eP 1 lam₁ := by
      apply ContinuousLinearMap.ext; intro x
      change blockLower2 eP lam₀ 0 0 lam₁ 0 0 x = rankOneScale P eP 0 lam₀ (rankOneScale P eP 1 lam₁ x)
      simp only [blockLower2, rankOneScale, add_apply, ContinuousLinearMap.id_apply, smul_apply,
        ContinuousLinearMap.smulRight_apply, innerSL_apply_apply, zero_smul, add_zero, zero_add,
        inner_add_right, inner_smul_right, h01, mul_zero, smul_smul]
      module
    have hmul := detF.map_mul
      ⟨rankOneScale P eP 0 lam₀, rankOneScale_mem_monoid P eP eM 0 lam₀⟩
      ⟨rankOneScale P eP 1 lam₁, rankOneScale_mem_monoid P eP eM 1 lam₁⟩
    rw [show detF ⟨rankOneScale P eP 0 lam₀, _⟩ = lam₀ from FredholmDetTheory.detFr_rankOne 0 lam₀,
        show detF ⟨rankOneScale P eP 1 lam₁, _⟩ = lam₁ from FredholmDetTheory.detFr_rankOne 1 lam₁] at hmul
    convert hmul using 1; congr 1; exact Subtype.ext heq
  have hLowerShear : ∀ α : ℂ,
      detF ⟨blockLower2 eP 1 0 α 1 0 0, blockLower2_mem_monoid _ _ _ _ _ _⟩ = 1 := by
    intro α
    have heq : blockLower2 eP 1 0 α 1 0 0 =
        ContinuousLinearMap.id ℂ P.HPlus + (innerSL ℂ (eP 0)).smulRight (α • eP 1) := by
      apply ContinuousLinearMap.ext; intro x; simp [blockLower2]
    have hv : ⟪eP 0, α • eP 1⟫_ℂ = 0 := by rw [inner_smul_right, h01, mul_zero]
    convert detFr_rankOne_nilpotent_eq_one (P := P) (eP := eP) (eM := eM) 0 (α • eP 1) hv using 1
    congr 1; exact Subtype.ext heq
  have hUpperShear : ∀ β : ℂ,
      detF ⟨blockLower2 eP 1 β 0 1 0 0, blockLower2_mem_monoid _ _ _ _ _ _⟩ = 1 := by
    intro β
    have heq : blockLower2 eP 1 β 0 1 0 0 =
        ContinuousLinearMap.id ℂ P.HPlus + (innerSL ℂ (eP 1)).smulRight (β • eP 0) := by
      apply ContinuousLinearMap.ext; intro x; simp [blockLower2]
    have hv : ⟪eP 1, β • eP 0⟫_ℂ = 0 := by rw [inner_smul_right, h10, mul_zero]
    convert detFr_rankOne_nilpotent_eq_one (P := P) (eP := eP) (eM := eM) 1 (β • eP 0) hv using 1
    congr 1; exact Subtype.ext heq
  have hOffBlock : ∀ (u₀ u₁ : P.HPlus),
      ⟪eP 0, u₀⟫_ℂ = 0 → ⟪eP 0, u₁⟫_ℂ = 0 → ⟪eP 1, u₁⟫_ℂ = 0 →
      detF ⟨blockLower2 eP 1 0 0 1 u₀ u₁, blockLower2_mem_monoid _ _ _ _ _ _⟩ = 1 := by
    intro u₀ u₁ hu00 hu01 hu11
    have hfac : blockLower2 eP 1 0 0 1 u₀ u₁ =
        (ContinuousLinearMap.id ℂ P.HPlus + (innerSL ℂ (eP 0)).smulRight u₀) *
        (ContinuousLinearMap.id ℂ P.HPlus + (innerSL ℂ (eP 1)).smulRight u₁) := by
      apply ContinuousLinearMap.ext; intro x
      change blockLower2 eP 1 0 0 1 u₀ u₁ x =
        (ContinuousLinearMap.id ℂ P.HPlus + (innerSL ℂ (eP 0)).smulRight u₀)
          ((ContinuousLinearMap.id ℂ P.HPlus + (innerSL ℂ (eP 1)).smulRight u₁) x)
      simp only [blockLower2, add_apply, ContinuousLinearMap.id_apply,
        ContinuousLinearMap.smulRight_apply, innerSL_apply_apply,
        sub_self, zero_smul, add_zero, zero_add, inner_add_right, inner_smul_right, hu01,
        mul_zero]
      abel
    have h0 := detFr_rankOne_nilpotent_eq_one (P := P) (eP := eP) (eM := eM) 0 u₀ hu00
    have h1 := detFr_rankOne_nilpotent_eq_one (P := P) (eP := eP) (eM := eM) 1 u₁ hu11
    have hEq0 : ContinuousLinearMap.id ℂ P.HPlus + (innerSL ℂ (eP 0)).smulRight u₀ =
        blockLower2 eP 1 0 0 1 u₀ 0 := by
      apply ContinuousLinearMap.ext; intro x; simp [blockLower2]
    have hEq1 : ContinuousLinearMap.id ℂ P.HPlus + (innerSL ℂ (eP 1)).smulRight u₁ =
        blockLower2 eP 1 0 0 1 0 u₁ := by
      apply ContinuousLinearMap.ext; intro x; simp [blockLower2]
    have hfac' : blockLower2 eP 1 0 0 1 u₀ u₁ =
        blockLower2 eP 1 0 0 1 u₀ 0 * blockLower2 eP 1 0 0 1 0 u₁ := by
      rw [hfac, hEq0, hEq1]
    have h0' : detF ⟨blockLower2 eP 1 0 0 1 u₀ 0, blockLower2_mem_monoid _ _ _ _ _ _⟩ = 1 := by
      convert h0 using 1; congr 1; exact Subtype.ext hEq0.symm
    have h1' : detF ⟨blockLower2 eP 1 0 0 1 0 u₁, blockLower2_mem_monoid _ _ _ _ _ _⟩ = 1 := by
      convert h1 using 1; congr 1; exact Subtype.ext hEq1.symm
    calc detF ⟨blockLower2 eP 1 0 0 1 u₀ u₁, blockLower2_mem_monoid _ _ _ _ _ _⟩
        = detF (⟨blockLower2 eP 1 0 0 1 u₀ 0, blockLower2_mem_monoid _ _ _ _ _ _⟩ *
                ⟨blockLower2 eP 1 0 0 1 0 u₁, blockLower2_mem_monoid _ _ _ _ _ _⟩) := by
          congr 1; exact Subtype.ext hfac'
      _ = 1 * 1 := by rw [map_mul, h0', h1']
      _ = 1 := mul_one 1
  by_cases hdet : a * d - b * c = 0
  · rw [hdet]
    by_contra hne
    have hBij := (FredholmDetTheory.detFr_ne_zero_iff (P := P) (eP := eP) (eM := eM) _).mp hne
    have hSing : ∃ c₀ c₁ : ℂ, (c₀ ≠ 0 ∨ c₁ ≠ 0) ∧
        a * c₀ + b * c₁ = 0 ∧ c * c₀ + d * c₁ = 0 := by
      by_cases hab : a = 0 ∧ b = 0
      · by_cases hd : d = 0
        · exact ⟨0, 1, Or.inr one_ne_zero, by simp [hab.1, hab.2], by simp [hd]⟩
        · exact ⟨-d, c, Or.inl (neg_ne_zero.mpr hd), by simp [hab.1, hab.2], by ring⟩
      · by_cases hb : b = 0
        · have ha : a ≠ 0 := fun h => hab ⟨h, hb⟩
          have hd : d = 0 := (mul_eq_zero.mp (by linear_combination hdet + hb * c)).resolve_left ha
          exact ⟨0, 1, Or.inr one_ne_zero, by simp [hb], by simp [hd]⟩
        · exact ⟨-b, a, Or.inl (neg_ne_zero.mpr hb), by ring, by linear_combination hdet⟩
    obtain ⟨c₀, c₁, hnz, heq1, heq2⟩ := hSing
    let x : P.HPlus := c₀ • eP 0 + c₁ • eP 1 - c₀ • b₀ - c₁ • b₁
    have hx0 : ⟪eP 0, x⟫_ℂ = c₀ := by
      simp only [x, inner_sub_right, inner_add_right, inner_smul_right, h00, h01, hb00, hb01]
      ring
    have hx1 : ⟪eP 1, x⟫_ℂ = c₁ := by
      simp only [x, inner_sub_right, inner_add_right, inner_smul_right, h10, h11, hb10, hb11]
      ring
    have hLx : blockLower2 eP a b c d b₀ b₁ x = 0 := by
      simp only [blockLower2, add_apply, ContinuousLinearMap.id_apply,
        ContinuousLinearMap.smulRight_apply, innerSL_apply_apply, hx0, hx1]
      dsimp [x]
      have hvec : c₀ • eP 0 + c₁ • eP 1 - c₀ • b₀ - c₁ • b₁ +
          c₀ • ((a - 1) • eP 0 + c • eP 1 + b₀) +
          c₁ • (b • eP 0 + (d - 1) • eP 1 + b₁) =
          (a * c₀ + b * c₁) • eP 0 + (c * c₀ + d * c₁) • eP 1 := by module
      rw [hvec, heq1, heq2, zero_smul, zero_smul, add_zero]
    have hx_zero : x = 0 := hBij.1 (by rw [hLx, map_zero])
    rw [hx_zero, inner_zero_right] at hx0 hx1
    exact hnz.elim (fun h => h hx0.symm) (fun h => h hx1.symm)
  · let Δ := a * d - b * c
    let u₀ : P.HPlus := (d / Δ) • b₀ + (-c / Δ) • b₁
    let u₁ : P.HPlus := (-b / Δ) • b₀ + (a / Δ) • b₁
    have hSplitB : blockLower2 eP a b c d b₀ b₁ =
        blockLower2 eP 1 0 0 1 u₀ u₁ * blockLower2 eP a b c d 0 0 := by
      apply ContinuousLinearMap.ext; intro x
      change blockLower2 eP a b c d b₀ b₁ x =
        blockLower2 eP 1 0 0 1 u₀ u₁ (blockLower2 eP a b c d 0 0 x)
      simp only [blockLower2, add_apply, ContinuousLinearMap.id_apply,
        ContinuousLinearMap.smulRight_apply, innerSL_apply_apply,
        sub_self, zero_smul, add_zero, zero_add, inner_add_right, inner_smul_right,
        h00, h11, h01, h10, mul_one, mul_zero]
      dsimp [u₀, u₁]
      have hc0 : a * (d / Δ) + c * (-b / Δ) = 1 := by dsimp [Δ]; field_simp [hdet]; ring
      have hc1 : b * (d / Δ) + d * (-b / Δ) = 0 := by dsimp [Δ]; field_simp [hdet]; ring
      have hd0 : a * (-c / Δ) + c * (a / Δ) = 0 := by dsimp [Δ]; field_simp [hdet]; ring
      have hd1 : b * (-c / Δ) + d * (a / Δ) = 1 := by dsimp [Δ]; field_simp [hdet]; ring
      set α0 : ℂ := ⟪eP 0, x⟫_ℂ
      set α1 : ℂ := ⟪eP 1, x⟫_ℂ
      change x + α0 • ((a - 1) • eP 0 + c • eP 1 + b₀) + α1 • (b • eP 0 + (d - 1) • eP 1 + b₁) =
        x + α0 • ((a - 1) • eP 0 + c • eP 1) + α1 • (b • eP 0 + (d - 1) • eP 1) +
        (α0 + α0 * (a - 1) + α1 * b) • ((d / Δ) • b₀ + (-c / Δ) • b₁) +
        (α1 + α0 * c + α1 * (d - 1)) • ((-b / Δ) • b₀ + (a / Δ) • b₁)
      have hcomb :
          α0 • b₀ + α1 • b₁ =
          (a * α0 + b * α1) • ((d / Δ) • b₀ + (-c / Δ) • b₁) +
          (c * α0 + d * α1) • ((-b / Δ) • b₀ + (a / Δ) • b₁) := by
        have h1 : (a * α0 + b * α1) * (d / Δ) + (c * α0 + d * α1) * (-b / Δ) = α0 := by
          linear_combination α0 * hc0 + α1 * hc1
        have h2 : (a * α0 + b * α1) * (-c / Δ) + (c * α0 + d * α1) * (a / Δ) = α1 := by
          linear_combination α0 * hd0 + α1 * hd1
        calc α0 • b₀ + α1 • b₁
            = ((a * α0 + b * α1) * (d / Δ) + (c * α0 + d * α1) * (-b / Δ)) • b₀ +
              ((a * α0 + b * α1) * (-c / Δ) + (c * α0 + d * α1) * (a / Δ)) • b₁ := by rw [h1, h2]
          _ = _ := by module
      have hrearr :
          x + α0 • ((a - 1) • eP 0 + c • eP 1 + b₀) + α1 • (b • eP 0 + (d - 1) • eP 1 + b₁) =
          (x + α0 • ((a - 1) • eP 0 + c • eP 1) + α1 • (b • eP 0 + (d - 1) • eP 1)) +
          (α0 • b₀ + α1 • b₁) := by module
      rw [hrearr, hcomb]; module
    have hDetB : detF ⟨blockLower2 eP 1 0 0 1 u₀ u₁, blockLower2_mem_monoid _ _ _ _ _ _⟩ = 1 :=
      hOffBlock u₀ u₁ (by simp [u₀, inner_add_right, inner_smul_right, hb00, hb01])
        (by simp [u₁, inner_add_right, inner_smul_right, hb00, hb01])
        (by simp [u₁, inner_add_right, inner_smul_right, hb10, hb11])
    have hDetM : detF ⟨blockLower2 eP a b c d 0 0, blockLower2_mem_monoid _ _ _ _ _ _⟩ = Δ := by
      by_cases ha : a = 0
      · have hb : b ≠ 0 := by intro h0; apply hdet; rw [ha, h0]; ring
        have hfac : blockLower2 eP a b c d 0 0 =
            blockLower2 eP 1 0 (d / b) 1 0 0 *
            (blockLower2 eP 1 1 0 1 0 0 *
            (blockLower2 eP 1 0 (-1) 1 0 0 *
            (blockLower2 eP 1 1 0 1 0 0 * blockLower2 eP (-c) 0 0 b 0 0))) := by
          simp only [blockLower2_mul_zero]
          congr 1 <;> [ (rw [ha]; ring); ring; ring; (field_simp [hb]; ring) ]
        have hEq : detF ⟨blockLower2 eP a b c d 0 0, blockLower2_mem_monoid _ _ _ _ _ _⟩ =
            1 * (1 * (1 * (1 * (-c * b)))) := by
          calc _ = detF
                (⟨blockLower2 eP 1 0 (d / b) 1 0 0, blockLower2_mem_monoid _ _ _ _ _ _⟩ *
                (⟨blockLower2 eP 1 1 0 1 0 0, blockLower2_mem_monoid _ _ _ _ _ _⟩ *
                (⟨blockLower2 eP 1 0 (-1) 1 0 0, blockLower2_mem_monoid _ _ _ _ _ _⟩ *
                (⟨blockLower2 eP 1 1 0 1 0 0, blockLower2_mem_monoid _ _ _ _ _ _⟩ *
                 ⟨blockLower2 eP (-c) 0 0 b 0 0, blockLower2_mem_monoid _ _ _ _ _ _⟩)))) := by
                congr 1; exact Subtype.ext hfac
            _ = _ := by
                simp only [map_mul, hLowerShear, hUpperShear, hDiag]
        rw [hEq]; dsimp [Δ]; rw [ha]; ring
      · have hfac : blockLower2 eP a b c d 0 0 =
            blockLower2 eP 1 0 (c / a) 1 0 0 *
            (blockLower2 eP a 0 0 (Δ / a) 0 0 * blockLower2 eP 1 (b / a) 0 1 0 0) := by
          simp only [blockLower2_mul_zero]
          congr 1 <;> [ ring; (field_simp [ha]; ring); (field_simp [ha]; ring); (dsimp [Δ]; field_simp [ha]; ring) ]
        have hEq : detF ⟨blockLower2 eP a b c d 0 0, blockLower2_mem_monoid _ _ _ _ _ _⟩ =
            1 * ((a * (Δ / a)) * 1) := by
          calc _ = detF
                (⟨blockLower2 eP 1 0 (c / a) 1 0 0, blockLower2_mem_monoid _ _ _ _ _ _⟩ *
                (⟨blockLower2 eP a 0 0 (Δ / a) 0 0, blockLower2_mem_monoid _ _ _ _ _ _⟩ *
                 ⟨blockLower2 eP 1 (b / a) 0 1 0 0, blockLower2_mem_monoid _ _ _ _ _ _⟩)) := by
                congr 1; exact Subtype.ext hfac
            _ = _ := by simp only [map_mul, hLowerShear, hUpperShear, hDiag]
        rw [hEq]; field_simp [ha]
    calc detF ⟨blockLower2 eP a b c d b₀ b₁, blockLower2_mem_monoid _ _ _ _ _ _⟩
        = detF
            (⟨blockLower2 eP 1 0 0 1 u₀ u₁, blockLower2_mem_monoid _ _ _ _ _ _⟩ *
             ⟨blockLower2 eP a b c d 0 0, blockLower2_mem_monoid _ _ _ _ _ _⟩) := by
          congr 1; exact Subtype.ext hSplitB
      _ = 1 * Δ := by rw [map_mul, hDetB, hDetM]
      _ = Δ := one_mul Δ

end BlockLowerTriangularDet

/-! ### Section 3: Reduction of Segal–Wilson `det_Fr` to `tauU v w t₁ t₂ t₃ / p₂₃` on `L²(S¹)` -/

section CircleSegalWilsonReduction

/-- Orthonormal basis `{ e_{-(n+1)} | n ∈ ℕ }` of `H₋ ≤ L²(S¹)`. -/
noncomputable def hardyMinusBasis : HilbertBasis ℕ ℂ hardyPolarization.HMinus := by
  let v : ℕ → hardyPolarization.HMinus := fun n =>
    ⟨eBasis (-(n : ℤ) - 1), by
      change eBasis (-(n : ℤ) - 1) ∈ hardyMinus
      rw [mem_hardyMinus_iff]; intro k hk
      rw [HilbertBasis.repr_apply_apply, eBasis.orthonormal.inner_eq_zero]; omega⟩
  have hortho : Orthonormal ℂ v := by
    rw [orthonormal_iff_ite]
    intro m n
    change ⟪eBasis (-(m : ℤ) - 1), eBasis (-(n : ℤ) - 1)⟫_ℂ = if m = n then 1 else 0
    have h := orthonormal_iff_ite.mp eBasis.orthonormal (-(m : ℤ) - 1) (-(n : ℤ) - 1)
    by_cases heq : m = n
    · subst heq; simpa using h
    · have hne : (-(m : ℤ) - 1) ≠ (-(n : ℤ) - 1) := by omega
      simpa [heq, hne] using h
  have hdense : ⊤ ≤ (Submodule.span ℂ (Set.range v)).topologicalClosure := by
    rintro ⟨f, hf⟩ _
    have hsum : HasSum (fun k : ℤ => hardyMinus.orthogonalProjectionOnto (eBasis.repr f k • eBasis k))
        (hardyMinus.orthogonalProjectionOnto f) :=
      (eBasis.hasSum_repr f).map hardyMinus.orthogonalProjectionOnto.toAddMonoidHom
        hardyMinus.orthogonalProjectionOnto.continuous
    have hself : hardyMinus.orthogonalProjectionOnto f = ⟨f, hf⟩ :=
      Submodule.orthogonalProjectionOnto_mem_subspace_eq_self ⟨f, hf⟩
    rw [hself] at hsum
    have hzero : ∀ k : ℤ, k ∉ Set.range (fun n : ℕ => -(n : ℤ) - 1) →
        hardyMinus.orthogonalProjectionOnto (eBasis.repr f k • eBasis k) = 0 := by
      intro k hk
      have hge : 0 ≤ k := by
        by_contra hlt; push Not at hlt
        refine hk ⟨(-k - 1).toNat, ?_⟩
        dsimp only
        omega
      rw [(mem_hardyMinus_iff f).mp hf k hge, zero_smul, map_zero]
    have hnat := (hasSum_subtype_iff_of_support_subset
      (s := Set.range (fun n : ℕ => -(n : ℤ) - 1))
      (f := fun k : ℤ => hardyMinus.orthogonalProjectionOnto (eBasis.repr f k • eBasis k))
      (fun k hk => by by_contra hnot; exact hk (hzero k hnot))).mpr hsum
    let eNeg : ℕ ≃ Set.range (fun n : ℕ => -(n : ℤ) - 1) :=
      Equiv.ofBijective (fun n : ℕ => ⟨-(n : ℤ) - 1, ⟨n, rfl⟩⟩)
        ⟨fun a b h => by
          have h' : -(a : ℤ) - 1 = -(b : ℤ) - 1 := congrArg Subtype.val h
          omega,
         fun ⟨_, n, rfl⟩ => ⟨n, rfl⟩⟩
    have hnat' : HasSum (fun n : ℕ => eBasis.repr f (-(n : ℤ) - 1) • v n) ⟨f, hf⟩ := by
      refine ((eNeg.hasSum_iff).mpr hnat).congr_fun fun n => ?_
      symm
      change hardyMinus.orthogonalProjectionOnto (eBasis.repr f (-(n : ℤ) - 1) • eBasis (-(n : ℤ) - 1)) = _
      rw [map_smul]; congr 1
      exact Submodule.orthogonalProjectionOnto_mem_subspace_eq_self (v n)
    have hclosed : IsClosed ((Submodule.span ℂ (Set.range v)).topologicalClosure : Set hardyPolarization.HMinus) :=
      isClosed_closure
    refine hclosed.mem_of_tendsto hnat' ?_
    filter_upwards with s
    exact Submodule.sum_mem _ fun n _ =>
      Submodule.smul_mem _ _ (Submodule.le_topologicalClosure _ (Submodule.subset_span ⟨n, rfl⟩))
  exact HilbertBasis.mk hortho hdense

/-- Membership of the 3-time KP flow in `GL_(2)(L²(S¹))` (opaque `lemma` for fast kernel checking). -/
lemma kpFlow3_mem_gl2 (t₁ t₂ t₃ : ℂ) :
    (kpFlow (kpTime3 t₁ t₂ t₃)).1 ∈ GL2Res hardyPolarization hardyPlusBasis hardyMinusBasis := by
  have hS_mem : shiftOp ∈ gl2ResAlg hardyPolarization hardyPlusBasis hardyMinusBasis := by
    refine ⟨?_, ?_⟩
    · have hle : LinearMap.range (blockPM hardyPolarization shiftOp).toLinearMap ≤
          Submodule.span ℂ ({e0} : Set hardyPolarization.HPlus) := by
        rintro _ ⟨f, rfl⟩
        change blockPM hardyPolarization (shiftCLE : HCircle →L[ℂ] HCircle) f ∈ _
        rw [blockPM_shift_eq_rankOne]
        exact Submodule.smul_mem _ _ (Submodule.subset_span rfl)
      have : FiniteDimensional ℂ (Submodule.span ℂ ({e0} : Set hardyPolarization.HPlus)) :=
        FiniteDimensional.span_of_finite ℂ (Set.finite_singleton e0)
      have : FiniteDimensional ℂ (LinearMap.range (blockPM hardyPolarization shiftOp).toLinearMap) :=
        FiniteDimensional.of_injective (Submodule.inclusion hle) (Submodule.inclusion_injective hle)
      exact isHS_of_finiteDimensional_range hardyMinusBasis _
    · change IsHS hardyPlusBasis (blockMP hardyPolarization (shiftCLE : HCircle →L[ℂ] HCircle))
      rw [blockMP_shift_eq_zero]; exact IsHS.zero _
  have hgen_eq : kpGenerator (kpTime3 t₁ t₂ t₃) =
      t₁ • shiftOp + t₂ • shiftOp ^ 2 + t₃ • shiftOp ^ 3 := by
    unfold kpTime3
    rw [kpGenerator_add, kpGenerator_add, kpGenerator_single, kpGenerator_single,
      kpGenerator_single]
    simp [idx1, idx2, idx3]
  have hgen_mem : kpGenerator (kpTime3 t₁ t₂ t₃) ∈
      gl2ResAlg hardyPolarization hardyPlusBasis hardyMinusBasis := by
    rw [hgen_eq]
    exact Subalgebra.add_mem _ (Subalgebra.add_mem _
      (Subalgebra.smul_mem _ hS_mem t₁)
      (Subalgebra.smul_mem _ (Subalgebra.pow_mem _ hS_mem 2) t₂))
      (Subalgebra.smul_mem _ (Subalgebra.pow_mem _ hS_mem 3) t₃)
  exact exp_mem_gl2ResAlg hardyPolarization hardyPlusBasis hardyMinusBasis hgen_mem

/-- The 3-time KP flow `g(t₁, t₂, t₃) = exp(t₁ S + t₂ S² + t₃ S³)` lies in `GL_(2)⁰(L²(S¹))`. -/
noncomputable def kpFlow3GL2 (t₁ t₂ t₃ : ℂ) :
    GL2Res0 hardyPolarization hardyPlusBasis hardyMinusBasis :=
  ⟨⟨(kpFlow (kpTime3 t₁ t₂ t₃)).1, kpFlow3_mem_gl2 t₁ t₂ t₃⟩,
   glResIndex_kpFlow (kpTime3 t₁ t₂ t₃)⟩

/-- Big-cell graph operator `T_U : H₊ →L[ℂ] H₋` for a frame `(v, w)` with `p₂₃ ≠ 0`:
`T_U(e₀) = (p₀₃/p₂₃) e₋₂ + (p₁₃/p₂₃) e₋₁`, `T_U(e₁) = -(p₀₂/p₂₃) e₋₂ - (p₁₂/p₂₃) e₋₁`. -/
noncomputable def gr24GraphOp (v w : C4) :
    hardyPolarization.HPlus →L[ℂ] hardyPolarization.HMinus :=
  let p23 := pluckerCoord v w 2 3
  let u0 : hardyPolarization.HMinus :=
    (pluckerCoord v w 0 3 / p23) • hardyMinusBasis 1 +
    (pluckerCoord v w 1 3 / p23) • hardyMinusBasis 0
  let u1 : hardyPolarization.HMinus :=
    (-pluckerCoord v w 0 2 / p23) • hardyMinusBasis 1 +
    (-pluckerCoord v w 1 2 / p23) • hardyMinusBasis 0
  (innerSL ℂ (hardyPlusBasis 0)).smulRight u0 + (innerSL ℂ (hardyPlusBasis 1)).smulRight u1

lemma gr24GraphOp_isHS (v w : C4) : IsHS hardyPlusBasis (gr24GraphOp v w) := by
  let p23 := pluckerCoord v w 2 3
  let u0 := (pluckerCoord v w 0 3 / p23) • hardyMinusBasis 1 +
    (pluckerCoord v w 1 3 / p23) • hardyMinusBasis 0
  let u1 := (-pluckerCoord v w 0 2 / p23) • hardyMinusBasis 1 +
    (-pluckerCoord v w 1 2 / p23) • hardyMinusBasis 0
  have hle : LinearMap.range (gr24GraphOp v w).toLinearMap ≤
      Submodule.span ℂ ({u0, u1} : Set hardyPolarization.HMinus) := by
    rintro _ ⟨x, rfl⟩
    exact Submodule.add_mem _
      (Submodule.smul_mem _ _ (Submodule.subset_span (Set.mem_insert u0 _)))
      (Submodule.smul_mem _ _ (Submodule.subset_span (Set.mem_insert_of_mem u0 rfl)))
  have : FiniteDimensional ℂ (Submodule.span ℂ ({u0, u1} : Set hardyPolarization.HMinus)) :=
    FiniteDimensional.span_of_finite ℂ ((Set.finite_singleton u1).insert u0)
  have : FiniteDimensional ℂ (LinearMap.range (gr24GraphOp v w).toLinearMap) :=
    FiniteDimensional.of_injective (Submodule.inclusion hle) (Submodule.inclusion_injective hle)
  exact isHS_of_finiteDimensional_range hardyPlusBasis (gr24GraphOp v w)

lemma repr_graphMap_gr24 (v w : C4) (x : hardyPolarization.HPlus) (n : ℤ) :
    eBasis.repr (graphMap hardyPolarization (gr24GraphOp v w) x) n =
      eBasis.repr x.1 n +
      (eBasis.repr x.1 0 * (pluckerCoord v w 0 3 / pluckerCoord v w 2 3) +
       eBasis.repr x.1 1 * (-pluckerCoord v w 0 2 / pluckerCoord v w 2 3)) *
        (if n = -2 then 1 else 0) +
      (eBasis.repr x.1 0 * (pluckerCoord v w 1 3 / pluckerCoord v w 2 3) +
       eBasis.repr x.1 1 * (-pluckerCoord v w 1 2 / pluckerCoord v w 2 3)) *
        (if n = -1 then 1 else 0) := by
  have hb0 : (hardyPlusBasis 0 : HCircle) = eBasis 0 := by simp [hardyPlusBasis]
  have hb1 : (hardyPlusBasis 1 : HCircle) = eBasis 1 := by simp [hardyPlusBasis]
  have hm0 : (hardyMinusBasis 0 : HCircle) = eBasis (-1) := by simp [hardyMinusBasis]
  have hm1 : (hardyMinusBasis 1 : HCircle) = eBasis (-2) := by simp [hardyMinusBasis]
  have hx0 : ⟪hardyPlusBasis 0, x⟫_ℂ = eBasis.repr x.1 0 := by
    change ⟪(hardyPlusBasis 0 : HCircle), x.1⟫_ℂ = _
    rw [hb0, HilbertBasis.repr_apply_apply]
  have hx1 : ⟪hardyPlusBasis 1, x⟫_ℂ = eBasis.repr x.1 1 := by
    change ⟪(hardyPlusBasis 1 : HCircle), x.1⟫_ℂ = _
    rw [hb1, HilbertBasis.repr_apply_apply]
  have hval : graphMap hardyPolarization (gr24GraphOp v w) x =
      x.1 +
      (eBasis.repr x.1 0 • ((pluckerCoord v w 0 3 / pluckerCoord v w 2 3) • eBasis (-2) +
                            (pluckerCoord v w 1 3 / pluckerCoord v w 2 3) • eBasis (-1)) +
       eBasis.repr x.1 1 • ((-pluckerCoord v w 0 2 / pluckerCoord v w 2 3) • eBasis (-2) +
                            (-pluckerCoord v w 1 2 / pluckerCoord v w 2 3) • eBasis (-1))) := by
    change x.1 + ((gr24GraphOp v w x : hardyPolarization.HMinus) : HCircle) = _
    simp only [gr24GraphOp, add_apply, ContinuousLinearMap.smulRight_apply, innerSL_apply_apply,
      hx0, hx1, Submodule.coe_add, Submodule.coe_smul, hm0, hm1]
  rw [hval]
  simp only [map_add, map_smul, lp.coeFn_add, lp.coeFn_smul, Pi.add_apply, Pi.smul_apply,
    smul_eq_mul, HilbertBasis.repr_self, lp.single_apply]
  by_cases h2 : n = -2
  · subst h2; simp
  · by_cases h1 : n = -1
    · subst h1; simp
    · simp [h2, h1]

/-- **Theorem 2.3 (Exact Graph Realization of `Ψ(U)` on the Big Cell):**
When `p₂₃(v, w) ≠ 0`, `graphSubspace (gr24GraphOp v w) = truncSubspace (span {v, w})`. -/
theorem graphSubspace_gr24GraphOp_eq (v w : C4) (hp23 : pluckerCoord v w 2 3 ≠ 0) :
    graphSubspace hardyPolarization (gr24GraphOp v w) =
      truncSubspace (Submodule.span ℂ ({v, w} : Set C4)) := by
  ext f
  constructor
  · rintro ⟨x, rfl⟩
    refine ⟨?_, ?_⟩
    · intro n hn
      have hx_n : eBasis.repr x.1 n = 0 := (mem_hardyPlus_iff x.1).mp x.2 n (by omega)
      simp only [ContinuousLinearMap.coe_coe]
      rw [repr_graphMap_gr24, hx_n]
      have hne1 : n ≠ -1 := by omega
      have hne2 : n ≠ -2 := by omega
      simp [hne1, hne2]
    · rw [Submodule.mem_span_pair]
      set c0 := eBasis.repr x.1 0
      set c1 := eBasis.repr x.1 1
      set p23 := pluckerCoord v w 2 3
      refine ⟨(c0 * w 3 - c1 * w 2) / p23, (c1 * v 2 - c0 * v 3) / p23, ?_⟩
      ext j
      simp only [ContinuousLinearMap.coe_coe]
      rw [windowEval_apply, repr_graphMap_gr24]
      have hx_neg : ∀ n : ℤ, n < 0 → eBasis.repr x.1 n = 0 := (mem_hardyPlus_iff x.1).mp x.2
      have hp23' : v 2 * w 3 - v 3 * w 2 ≠ 0 := hp23
      fin_cases j
      · change ((c0 * w 3 - c1 * w 2) / p23) * v 0 + ((c1 * v 2 - c0 * v 3) / p23) * w 0 = _
        simp only [Nat.cast_zero, zero_sub, hx_neg (-2) (by norm_num),
          zero_add, ↓reduceIte, show (-2 : ℤ) ≠ -1 by norm_num, mul_one, mul_zero, add_zero]
        dsimp [p23, pluckerCoord, c0, c1]; field_simp [hp23']; ring
      · change ((c0 * w 3 - c1 * w 2) / p23) * v 1 + ((c1 * v 2 - c0 * v 3) / p23) * w 1 = _
        simp only [Nat.cast_one, show (1 : ℤ) - 2 = -1 by norm_num,
          hx_neg (-1) (by norm_num), zero_add, ↓reduceIte, show (-1 : ℤ) ≠ -2 by norm_num,
          mul_one, mul_zero]
        dsimp [p23, pluckerCoord, c0, c1]; field_simp [hp23']; ring
      · change ((c0 * w 3 - c1 * w 2) / p23) * v 2 + ((c1 * v 2 - c0 * v 3) / p23) * w 2 = _
        simp only [Nat.cast_ofNat, sub_self, show (0 : ℤ) ≠ -2 by norm_num,
          show (0 : ℤ) ≠ -1 by norm_num, ↓reduceIte, mul_zero, add_zero]
        dsimp [p23, pluckerCoord, c0, c1]
        rw [div_mul_eq_mul_div, div_mul_eq_mul_div, ← add_div, div_eq_iff hp23']; ring
      · change ((c0 * w 3 - c1 * w 2) / p23) * v 3 + ((c1 * v 2 - c0 * v 3) / p23) * w 3 =
          (eBasis.repr x.1 1 + (eBasis.repr x.1 0 * (pluckerCoord v w 0 3 / pluckerCoord v w 2 3) +
            eBasis.repr x.1 1 * (-pluckerCoord v w 0 2 / pluckerCoord v w 2 3)) *
              (if (1 : ℤ) = -2 then 1 else 0)) +
          (eBasis.repr x.1 0 * (pluckerCoord v w 1 3 / pluckerCoord v w 2 3) +
            eBasis.repr x.1 1 * (-pluckerCoord v w 1 2 / pluckerCoord v w 2 3)) *
              (if (1 : ℤ) = -1 then 1 else 0)
        simp only [show (1 : ℤ) ≠ -2 by norm_num, show (1 : ℤ) ≠ -1 by norm_num,
          ↓reduceIte, mul_zero, add_zero]
        dsimp [p23, pluckerCoord, c0, c1]
        rw [div_mul_eq_mul_div, div_mul_eq_mul_div, ← add_div, div_eq_iff hp23']; ring
  · rintro ⟨hf_neg, hf_win⟩
    rw [Submodule.mem_span_pair] at hf_win
    obtain ⟨α, β, hαβ⟩ := hf_win
    refine ⟨hardyPlus.orthogonalProjectionOnto f, ?_⟩
    apply eBasis.repr.injective
    apply lp.ext; funext n
    simp only [ContinuousLinearMap.coe_coe]
    have hrepr := repr_graphMap_gr24 v w (hardyPlus.orthogonalProjectionOnto f) n
    rw [hrepr]
    have hpx : ∀ m : ℤ, 0 ≤ m → eBasis.repr (hardyPlus.orthogonalProjectionOnto f : HCircle) m = eBasis.repr f m :=
      fun m hm => repr_projPlus_of_nonneg f hm
    have hpx_neg : ∀ m : ℤ, m < 0 → eBasis.repr (hardyPlus.orthogonalProjectionOnto f : HCircle) m = 0 :=
      (mem_hardyPlus_iff _).mp (hardyPlus.orthogonalProjectionOnto f).2
    have hfj : ∀ j : Fin 4, eBasis.repr f ((j : ℤ) - 2) = α * v j + β * w j := fun j => by
      have := congrFun hαβ j; simpa [windowEval_apply] using this.symm
    have hp23' : v 2 * w 3 - v 3 * w 2 ≠ 0 := hp23
    rw [hpx 0 le_rfl, hpx 1 zero_le_one]
    by_cases hge : 0 ≤ n
    · have hn2 : n ≠ -2 := by omega
      have hn1 : n ≠ -1 := by omega
      rw [hpx n hge]
      simp [hn2, hn1]
    · push Not at hge
      by_cases hm2 : n = -2
      · subst hm2
        have h_m2 := hfj 0; have h_0 := hfj 2; have h_1 := hfj 3
        simp only [Fin.val_zero, Nat.cast_zero, zero_sub, Fin.val_two, Nat.cast_ofNat, sub_self,
          show ((3 : Fin 4) : ℤ) - 2 = 1 by norm_num] at h_m2 h_0 h_1
        rw [hpx_neg (-2) (by norm_num)]
        simp only [zero_add, ↓reduceIte, show (-2 : ℤ) ≠ -1 by norm_num,
          mul_one, mul_zero, add_zero, h_m2, h_0, h_1]
        unfold pluckerCoord
        rw [mul_div_assoc', mul_div_assoc', ← add_div, div_eq_iff hp23']; ring
      · by_cases hm1' : n = -1
        · subst hm1'
          have h_m1 := hfj 1; have h_0 := hfj 2; have h_1 := hfj 3
          simp only [Fin.val_one, Nat.cast_one, show (1 : ℤ) - 2 = -1 by norm_num,
            Fin.val_two, Nat.cast_ofNat, sub_self, show ((3 : Fin 4) : ℤ) - 2 = 1 by norm_num] at h_m1 h_0 h_1
          rw [hpx_neg (-1) (by norm_num)]
          simp only [zero_add, ↓reduceIte, show (-1 : ℤ) ≠ -2 by norm_num,
            mul_one, mul_zero, h_m1, h_0, h_1]
          unfold pluckerCoord
          rw [mul_div_assoc', mul_div_assoc', ← add_div, div_eq_iff hp23']; ring
        · have hlt : n < -2 := by omega
          rw [hpx_neg n hge, hf_neg n hlt]
          simp [hm2, hm1']

private lemma segalWilson_gr24_det_poly
    (p01 p02 p03 p12 p13 p23 t₁ t₂ t₃ : ℂ) (hp23 : p23 ≠ 0)
    (hQ : p01 * p23 - p02 * p13 + p03 * p12 = 0) :
    let p1 := elemSchur1 t₁ t₂ t₃
    let p2 := elemSchur2 t₁ t₂ t₃
    let p3 := elemSchur3 t₁ t₂ t₃
    (1 + ((p03 / p23) * p2 + (p13 / p23) * p1 - p1 * ((-p02 / p23) * p2 + (-p12 / p23) * p1))) *
      (1 + ((-p02 / p23) * p3 + (-p12 / p23) * p2)) -
      ((-p02 / p23) * p2 + (-p12 / p23) * p1) *
      ((p03 / p23) * p3 + (p13 / p23) * p2 - p1 * ((-p02 / p23) * p3 + (-p12 / p23) * p2)) =
    schurTau p01 p02 p03 p12 p13 p23 t₁ t₂ t₃ / p23 := by
  intro p1 p2 p3
  unfold schurTau schurEmpty schur1 schur2 schur11 schur21 schur22
  dsimp [p1, p2, p3, elemSchur1, elemSchur2, elemSchur3]
  field_simp [hp23]
  linear_combination (-72 * t₁ ^ 4 - 864 * t₂ ^ 2 + 864 * t₁ * t₃) * hQ

/-- Invertible upper-left block `g(t)₊₊ : H₊ ≃L[ℂ] H₊` for the 3-time KP flow. -/
noncomputable def kpFlow3PlusEquiv (t₁ t₂ t₃ : ℂ) :
    hardyPolarization.HPlus ≃L[ℂ] hardyPolarization.HPlus :=
  let t := kpTime3 t₁ t₂ t₃
  { toLinearEquiv :=
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
        map_add' := fun a b => by apply Subtype.ext; exact map_add (kpFlow t).1 a.1 b.1
        map_smul' := fun c a => by apply Subtype.ext; exact map_smul (kpFlow t).1 c a.1 }
    continuous_toFun := ((kpFlow t).1.continuous.comp continuous_subtype_val).subtype_mk _
    continuous_invFun := ((kpFlow (-t)).1.continuous.comp continuous_subtype_val).subtype_mk _ }

/-- Generic `1 + K ∈ 1 + ℐ₁` helper avoiding kernel unfolding of concrete Hilbert spaces. -/
private lemma traceClassMonoid_id_add {ιP ιM : Type*} {H : Type*}
    [NormedAddCommGroup H] [InnerProductSpace ℂ H] [CompleteSpace H]
    {P : PolarizedHilbertSpace ℂ H} {eP : HilbertBasis ιP ℂ P.HPlus} {eM : HilbertBasis ιM ℂ P.HMinus}
    {K : P.HPlus →L[ℂ] P.HPlus} (hK : K ∈ TraceClassIdeal P eP eM) :
    ContinuousLinearMap.id ℂ P.HPlus + K ∈ TraceClassMonoid P eP eM := by
  change (ContinuousLinearMap.id ℂ P.HPlus + K) - ContinuousLinearMap.id ℂ P.HPlus ∈
    TraceClassIdeal P eP eM
  rw [add_sub_cancel_left]
  exact hK

private lemma kpFlow3_blockPM_isHS (t₁ t₂ t₃ : ℂ) :
    IsHS hardyMinusBasis
      (blockPM hardyPolarization ((kpFlow (kpTime3 t₁ t₂ t₃)).1 : HCircle →L[ℂ] HCircle)) :=
  (kpFlow3_mem_gl2 t₁ t₂ t₃).1

/-- Trace-class monoid membership of `1 + g(t)₊₋ T_U g(t)₊₊⁻¹` for the big-cell `Gr_ℂ(2, 4)` operator. -/
lemma segalWilson_gr24_op_mem (v w : C4) (t₁ t₂ t₃ : ℂ) :
    ContinuousLinearMap.id ℂ hardyPolarization.HPlus +
      ((blockPM hardyPolarization ((kpFlow (kpTime3 t₁ t₂ t₃)).1 : HCircle →L[ℂ] HCircle)).comp
        (gr24GraphOp v w)).comp
        ((kpFlow3PlusEquiv t₁ t₂ t₃).symm : hardyPolarization.HPlus →L[ℂ] hardyPolarization.HPlus) ∈
      TraceClassMonoid hardyPolarization hardyPlusBasis hardyMinusBasis :=
  traceClassMonoid_id_add
    (TraceClassIdeal.comp_right
      (TraceClassIdeal.of_hs_cross (kpFlow3_blockPM_isHS t₁ t₂ t₃) (gr24GraphOp_isHS v w)) _)

/-- **Theorem 2.4 (Segal–Wilson `det_Fr` = Finite `Gr_ℂ(2, 4)` Schur `τ`-Function):**
On the big cell (`p₂₃ ≠ 0`), the infinite-dimensional Segal–Wilson Fredholm determinant
`det_Fr(1 + g(t)₊₋ T_U g(t)₊₊⁻¹)` from `segalWilson_tau_bigCell` reduces identically to
`tauU v w t₁ t₂ t₃ / pluckerCoord v w 2 3`. -/
theorem segalWilson_tau_gr24_eq_tauU
    [FredholmDetTheory hardyPolarization hardyPlusBasis hardyMinusBasis]
    (v w : C4) (hp23 : pluckerCoord v w 2 3 ≠ 0) (t₁ t₂ t₃ : ℂ) :
    FredholmDetTheory.detFr ⟨_, segalWilson_gr24_op_mem v w t₁ t₂ t₃⟩ =
      tauU v w t₁ t₂ t₃ / pluckerCoord v w 2 3 := by
  let t := kpTime3 t₁ t₂ t₃
  let T := gr24GraphOp v w
  let q := kpFlow3PlusEquiv t₁ t₂ t₃
  let p1 := elemSchur1 t₁ t₂ t₃
  let p2 := elemSchur2 t₁ t₂ t₃
  let p3 := elemSchur3 t₁ t₂ t₃
  let p01 := pluckerCoord v w 0 1
  let p02 := pluckerCoord v w 0 2
  let p03 := pluckerCoord v w 0 3
  let p12 := pluckerCoord v w 1 2
  let p13 := pluckerCoord v w 1 3
  let p23 := pluckerCoord v w 2 3
  have hb0 : (hardyPlusBasis 0 : HCircle) = eBasis 0 := by simp [hardyPlusBasis]
  have hb1 : (hardyPlusBasis 1 : HCircle) = eBasis 1 := by simp [hardyPlusBasis]
  have hm0 : (hardyMinusBasis 0 : HCircle) = eBasis (-1) := by simp [hardyMinusBasis]
  have hm1 : (hardyMinusBasis 1 : HCircle) = eBasis (-2) := by simp [hardyMinusBasis]
  have hgeNeg2_m2 : (hardyMinusBasis 1 : HCircle) ∈ hardyGeNeg2 := by
    intro n hn; rw [hm1, HilbertBasis.repr_self, lp.single_apply]; simp [show n ≠ -2 by omega]
  have hgeNeg2_m1 : (hardyMinusBasis 0 : HCircle) ∈ hardyGeNeg2 := by
    intro n hn; rw [hm0, HilbertBasis.repr_self, lp.single_apply]; simp [show n ≠ -1 by omega]
  let w_m2 : hardyPolarization.HPlus :=
    blockPM hardyPolarization ((kpFlow t).1 : HCircle →L[ℂ] HCircle) (hardyMinusBasis 1)
  let w_m1 : hardyPolarization.HPlus :=
    blockPM hardyPolarization ((kpFlow t).1 : HCircle →L[ℂ] HCircle) (hardyMinusBasis 0)
  have hwin_m2 : windowEval (hardyMinusBasis 1 : HCircle) = ![1, 0, 0, 0] := by
    rw [hm1]; ext j; rw [windowEval_apply, HilbertBasis.repr_self]
    fin_cases j <;> simp [lp.single_apply]
  have hwin_m1 : windowEval (hardyMinusBasis 0 : HCircle) = ![0, 1, 0, 0] := by
    rw [hm0]; ext j; rw [windowEval_apply, HilbertBasis.repr_self]
    fin_cases j <;> simp [lp.single_apply]
  have hwm2_0 : ⟪hardyPlusBasis 0, w_m2⟫_ℂ = p2 := by
    change ⟪(hardyPlusBasis 0 : HCircle), (hardyPlus.orthogonalProjectionOnto ((kpFlow t).1 (hardyMinusBasis 1 : HCircle)) : HCircle)⟫_ℂ = p2
    rw [hb0, ← HilbertBasis.repr_apply_apply, repr_projPlus_of_nonneg _ le_rfl]
    have h := congrFun (windowEval_kpFlow t hgeNeg2_m2) 2
    have hM := (kpMatrix4_apply_eq t ![1, 0, 0, 0]).2.2.1
    rw [kpTime3_idx1, kpTime3_idx2, kpTime3_idx3] at hM
    simpa [windowEval_apply, hwin_m2, p2, hM] using h
  have hwm2_1 : ⟪hardyPlusBasis 1, w_m2⟫_ℂ = p3 := by
    change ⟪(hardyPlusBasis 1 : HCircle), (hardyPlus.orthogonalProjectionOnto ((kpFlow t).1 (hardyMinusBasis 1 : HCircle)) : HCircle)⟫_ℂ = p3
    rw [hb1, ← HilbertBasis.repr_apply_apply, repr_projPlus_of_nonneg _ zero_le_one]
    have h := congrFun (windowEval_kpFlow t hgeNeg2_m2) 3
    have hM := (kpMatrix4_apply_eq t ![1, 0, 0, 0]).2.2.2
    rw [kpTime3_idx1, kpTime3_idx2, kpTime3_idx3] at hM
    simpa [windowEval_apply, hwin_m2, p3, hM] using h
  have hwm1_0 : ⟪hardyPlusBasis 0, w_m1⟫_ℂ = p1 := by
    change ⟪(hardyPlusBasis 0 : HCircle), (hardyPlus.orthogonalProjectionOnto ((kpFlow t).1 (hardyMinusBasis 0 : HCircle)) : HCircle)⟫_ℂ = p1
    rw [hb0, ← HilbertBasis.repr_apply_apply, repr_projPlus_of_nonneg _ le_rfl]
    have h := congrFun (windowEval_kpFlow t hgeNeg2_m1) 2
    have hM := (kpMatrix4_apply_eq t ![0, 1, 0, 0]).2.2.1
    rw [kpTime3_idx1, kpTime3_idx2, kpTime3_idx3] at hM
    simpa [windowEval_apply, hwin_m1, p1, hM] using h
  have hwm1_1 : ⟪hardyPlusBasis 1, w_m1⟫_ℂ = p2 := by
    change ⟪(hardyPlusBasis 1 : HCircle), (hardyPlus.orthogonalProjectionOnto ((kpFlow t).1 (hardyMinusBasis 0 : HCircle)) : HCircle)⟫_ℂ = p2
    rw [hb1, ← HilbertBasis.repr_apply_apply, repr_projPlus_of_nonneg _ zero_le_one]
    have h := congrFun (windowEval_kpFlow t hgeNeg2_m1) 3
    have hM := (kpMatrix4_apply_eq t ![0, 1, 0, 0]).2.2.2
    rw [kpTime3_idx1, kpTime3_idx2, kpTime3_idx3] at hM
    simpa [windowEval_apply, hwin_m1, p2, hM] using h
  have hqinv_coords : ∀ f : hardyPolarization.HPlus,
      ⟪hardyPlusBasis 0, q.symm f⟫_ℂ = ⟪hardyPlusBasis 0, f⟫_ℂ ∧
      ⟪hardyPlusBasis 1, q.symm f⟫_ℂ = ⟪hardyPlusBasis 1, f⟫_ℂ - p1 * ⟪hardyPlusBasis 0, f⟫_ℂ := by
    intro f
    have hf_ge : f.1 ∈ hardyGeNeg2 := fun n hn => (mem_hardyPlus_iff f.1).mp f.2 n (by omega)
    have hwin0 : windowEval f.1 0 = 0 := by rw [windowEval_apply]; exact (mem_hardyPlus_iff f.1).mp f.2 (-2) (by norm_num)
    have hwin1 : windowEval f.1 1 = 0 := by rw [windowEval_apply]; exact (mem_hardyPlus_iff f.1).mp f.2 (-1) (by norm_num)
    have h2 := congrFun (windowEval_kpFlow (-t) hf_ge) 2
    have h3 := congrFun (windowEval_kpFlow (-t) hf_ge) 3
    have hM := kpMatrix4_apply_eq (-t) (windowEval f.1)
    have ht1 : (-t) idx1 = -t₁ := by simp [t, kpTime3_idx1]
    constructor
    · change ⟪(hardyPlusBasis 0 : HCircle), (kpFlow (-t)).1 f.1⟫_ℂ = ⟪(hardyPlusBasis 0 : HCircle), f.1⟫_ℂ
      rw [hb0, ← HilbertBasis.repr_apply_apply, ← HilbertBasis.repr_apply_apply]
      have h2' : eBasis.repr ((kpFlow (-t)).1 f.1) 0 = kpMatrix4 (-t) (windowEval f.1) 2 := by
        simpa [windowEval_apply] using h2
      rw [h2', hM.2.2.1, hwin0, hwin1, windowEval_apply]; simp
    · change ⟪(hardyPlusBasis 1 : HCircle), (kpFlow (-t)).1 f.1⟫_ℂ =
        ⟪(hardyPlusBasis 1 : HCircle), f.1⟫_ℂ - p1 * ⟪(hardyPlusBasis 0 : HCircle), f.1⟫_ℂ
      rw [hb1, hb0, ← HilbertBasis.repr_apply_apply, ← HilbertBasis.repr_apply_apply, ← HilbertBasis.repr_apply_apply]
      have h3' : eBasis.repr ((kpFlow (-t)).1 f.1) 1 = kpMatrix4 (-t) (windowEval f.1) 3 := by
        simpa [windowEval_apply] using h3
      rw [h3', hM.2.2.2, hwin0, hwin1, windowEval_apply, windowEval_apply]
      simp [elemSchur1, p1, ht1]; ring
  let v0 : hardyPolarization.HPlus :=
    (p03 / p23) • w_m2 + (p13 / p23) • w_m1 - p1 • ((-p02 / p23) • w_m2 + (-p12 / p23) • w_m1)
  let v1 : hardyPolarization.HPlus :=
    (-p02 / p23) • w_m2 + (-p12 / p23) • w_m1
  let a : ℂ := 1 + ⟪hardyPlusBasis 0, v0⟫_ℂ
  let b : ℂ := ⟪hardyPlusBasis 0, v1⟫_ℂ
  let c : ℂ := ⟪hardyPlusBasis 1, v0⟫_ℂ
  let d : ℂ := 1 + ⟪hardyPlusBasis 1, v1⟫_ℂ
  let b₀ : hardyPolarization.HPlus :=
    v0 - ⟪hardyPlusBasis 0, v0⟫_ℂ • hardyPlusBasis 0 - ⟪hardyPlusBasis 1, v0⟫_ℂ • hardyPlusBasis 1
  let b₁ : hardyPolarization.HPlus :=
    v1 - ⟪hardyPlusBasis 0, v1⟫_ℂ • hardyPlusBasis 0 - ⟪hardyPlusBasis 1, v1⟫_ℂ • hardyPlusBasis 1
  have hOpEq : ContinuousLinearMap.id ℂ hardyPolarization.HPlus +
      ((blockPM hardyPolarization ((kpFlow t).1 : HCircle →L[ℂ] HCircle)).comp T).comp
        (q.symm : hardyPolarization.HPlus →L[ℂ] hardyPolarization.HPlus) =
      blockLower2 hardyPlusBasis a b c d b₀ b₁ := by
    apply ContinuousLinearMap.ext; intro f
    have hq0 := (hqinv_coords f).1
    have hq1 := (hqinv_coords f).2
    simp only [add_apply, ContinuousLinearMap.id_apply, ContinuousLinearMap.comp_apply,
      T, gr24GraphOp, ContinuousLinearMap.smulRight_apply, innerSL_apply_apply,
      ContinuousLinearEquiv.coe_coe, hq0, hq1, map_add, map_smul, blockLower2]
    change f + (⟪hardyPlusBasis 0, f⟫_ℂ • ((p03 / p23) • w_m2 + (p13 / p23) • w_m1) +
        (⟪hardyPlusBasis 1, f⟫_ℂ - p1 * ⟪hardyPlusBasis 0, f⟫_ℂ) •
          ((-p02 / p23) • w_m2 + (-p12 / p23) • w_m1)) =
        f + ⟪hardyPlusBasis 0, f⟫_ℂ • ((a - 1) • hardyPlusBasis 0 + c • hardyPlusBasis 1 + b₀) +
            ⟪hardyPlusBasis 1, f⟫_ℂ • (b • hardyPlusBasis 0 + (d - 1) • hardyPlusBasis 1 + b₁)
    have hv0 : (a - 1) • hardyPlusBasis 0 + c • hardyPlusBasis 1 + b₀ = v0 := by
      dsimp [a, c, b₀]; module
    have hv1 : b • hardyPlusBasis 0 + (d - 1) • hardyPlusBasis 1 + b₁ = v1 := by
      dsimp [b, d, b₁]; module
    rw [hv0, hv1]; dsimp [v0, v1]; module
  have h00 : ⟪hardyPlusBasis 0, hardyPlusBasis 0⟫_ℂ = 1 := by
    simpa using orthonormal_iff_ite.mp hardyPlusBasis.orthonormal 0 0
  have h11 : ⟪hardyPlusBasis 1, hardyPlusBasis 1⟫_ℂ = 1 := by
    simpa using orthonormal_iff_ite.mp hardyPlusBasis.orthonormal 1 1
  have h01 : ⟪hardyPlusBasis 0, hardyPlusBasis 1⟫_ℂ = 0 := by
    simpa using orthonormal_iff_ite.mp hardyPlusBasis.orthonormal 0 1
  have h10 : ⟪hardyPlusBasis 1, hardyPlusBasis 0⟫_ℂ = 0 := by
    simpa using orthonormal_iff_ite.mp hardyPlusBasis.orthonormal 1 0
  have hDet := detFr_blockLowerTriangular_two (P := hardyPolarization) (eP := hardyPlusBasis)
    (eM := hardyMinusBasis) a b c d b₀ b₁
    (by simp only [b₀, inner_sub_right, inner_smul_right, h00, h01]; ring)
    (by simp only [b₀, inner_sub_right, inner_smul_right, h10, h11]; ring)
    (by simp only [b₁, inner_sub_right, inner_smul_right, h00, h01]; ring)
    (by simp only [b₁, inner_sub_right, inner_smul_right, h10, h11]; ring)
  have hEqDet : FredholmDetTheory.detFr ⟨_, segalWilson_gr24_op_mem v w t₁ t₂ t₃⟩ = a * d - b * c := by
    rw [← hDet]; congr 1; exact Subtype.ext hOpEq
  rw [hEqDet, tauU_eq_schurTau]
  have ha : a = 1 + ((p03 / p23) * p2 + (p13 / p23) * p1 - p1 * ((-p02 / p23) * p2 + (-p12 / p23) * p1)) := by
    change 1 + ⟪hardyPlusBasis 0, (p03 / p23) • w_m2 + (p13 / p23) • w_m1 -
      p1 • ((-p02 / p23) • w_m2 + (-p12 / p23) • w_m1)⟫_ℂ = _
    simp only [inner_sub_right, inner_add_right, inner_smul_right, hwm2_0, hwm1_0]
  have hb : b = (-p02 / p23) * p2 + (-p12 / p23) * p1 := by
    change ⟪hardyPlusBasis 0, (-p02 / p23) • w_m2 + (-p12 / p23) • w_m1⟫_ℂ = _
    simp only [inner_add_right, inner_smul_right, hwm2_0, hwm1_0]
  have hc : c = (p03 / p23) * p3 + (p13 / p23) * p2 - p1 * ((-p02 / p23) * p3 + (-p12 / p23) * p2) := by
    change ⟪hardyPlusBasis 1, (p03 / p23) • w_m2 + (p13 / p23) • w_m1 -
      p1 • ((-p02 / p23) • w_m2 + (-p12 / p23) • w_m1)⟫_ℂ = _
    simp only [inner_sub_right, inner_add_right, inner_smul_right, hwm2_1, hwm1_1]
  have hd : d = 1 + ((-p02 / p23) * p3 + (-p12 / p23) * p2) := by
    change 1 + ⟪hardyPlusBasis 1, (-p02 / p23) • w_m2 + (-p12 / p23) • w_m1⟫_ℂ = _
    simp only [inner_add_right, inner_smul_right, hwm2_1, hwm1_1]
  rw [ha, hb, hc, hd]
  have hQ : p01 * p23 - p02 * p13 + p03 * p12 = 0 := kleinQuadric_relation v w
  exact segalWilson_gr24_det_poly p01 p02 p03 p12 p13 p23 t₁ t₂ t₃ hp23 hQ

end CircleSegalWilsonReduction

end Signals.SatoGrassmannian.SegalWilsonGr24
