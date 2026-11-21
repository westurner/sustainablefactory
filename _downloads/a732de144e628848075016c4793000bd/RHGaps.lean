import Mathlib.Analysis.Calculus.Deriv.Basic
import Mathlib.Analysis.Calculus.Deriv.Pow
import Mathlib.Analysis.Complex.Basic
import Mathlib.Analysis.InnerProductSpace.Basic
import Mathlib.Analysis.Normed.Operator.Compact.Basic
import Mathlib.Analysis.PSeries
import Mathlib.Data.Nat.Factorization.Basic
import Mathlib.Data.Nat.Prime.Basic
import Mathlib.Data.Nat.Sqrt
import Signals.SatoGrassmannian.KPFlow

open scoped InnerProductSpace BigOperators

namespace Signals.SatoGrassmannian.RHGaps

open Signals.SatoGrassmannian Signals.SatoGrassmannian.KPFlow

/-! ============================================================================
## Part 1: de Bruijn–Newman Backward Heat Flow & Collision Gap
============================================================================ -/

section DeBruijnNewman

/-- A function `f : ℂ → ℂ` has only real zeros. -/
def AllRealZeros (f : ℂ → ℂ) : Prop :=
  ∀ z : ℂ, f z = 0 → z.im = 0

/-- Abstract de Bruijn–Newman threshold `Λ = inf { t ∈ ℝ | ∀ s ≥ t, AllRealZeros (H s) }`. -/
noncomputable def dBNConstant (H : ℝ → ℂ → ℂ) : ℝ :=
  sInf { t : ℝ | ∀ s : ℝ, t ≤ s → AllRealZeros (H s) }

/-- **Rodgers–Tao + Upper-Bound Sandwich:** Combining `Λ ≤ 0` with `0 ≤ Λ` pins `Λ = 0`,
and implies `H 0` has only real zeros whenever the real-rootedness set is closed below
(Hurwitz's theorem on locally uniform limits of holomorphic functions). -/
theorem dBN_eq_zero_and_RH {H : ℝ → ℂ → ℂ}
    (hRT : 0 ≤ dBNConstant H) (hUpper : dBNConstant H ≤ 0)
    (hHurwitz : ∀ t : ℝ, (∀ s : ℝ, t < s → AllRealZeros (H s)) → AllRealZeros (H t))
    (hNonempty : { t : ℝ | ∀ s : ℝ, t ≤ s → AllRealZeros (H s) }.Nonempty) :
    dBNConstant H = 0 ∧ AllRealZeros (H 0) := by
  have hEq : dBNConstant H = 0 := le_antisymm hUpper hRT
  refine ⟨hEq, hHurwitz 0 fun s hs => ?_⟩
  have hlt : sInf { t : ℝ | ∀ r : ℝ, t ≤ r → AllRealZeros (H r) } < s := by
    rwa [← dBNConstant, hEq]
  obtain ⟨t₀, ht₀_mem, ht₀_lt⟩ := exists_lt_of_csInf_lt hNonempty hlt
  exact ht₀_mem s ht₀_lt.le

/-- Canonical local model of a real double zero under the de Bruijn–Newman backward heat flow:
`H_t(z) = z² - 2t` satisfies `∂_t H_t = -∂_z² H_t`. -/
def localDoubleZero (t : ℝ) (z : ℂ) : ℂ :=
  z ^ 2 - 2 * (t : ℂ)

/-- **Theorem 1.1 (Backward Heat Equation):** `∂_t (z² - 2t) = -∂_z² (z² - 2t)`. -/
theorem localDoubleZero_backward_heat_pde (t : ℝ) (z : ℂ) :
    deriv (fun s : ℝ => localDoubleZero s z) t =
      -deriv (fun w : ℂ => deriv (fun u : ℂ => localDoubleZero t u) w) z := by
  have hdt : HasDerivAt (fun s : ℝ => localDoubleZero s z) (-2 : ℂ) t := by
    unfold localDoubleZero
    have h1 := hasDerivAt_const t (z ^ 2)
    have h2 := (Complex.ofRealCLM.hasDerivAt (x := t)).const_mul (2 : ℂ)
    convert h1.sub h2 using 1
    · funext s; simp only [Pi.sub_apply]; rfl
    · simp [Complex.ofRealCLM_apply]
  have hdz1 : ∀ w : ℂ, HasDerivAt (fun u : ℂ => localDoubleZero t u) (2 * w) w := by
    intro w
    unfold localDoubleZero
    have h := (hasDerivAt_pow 2 w).sub (hasDerivAt_const w (2 * (t : ℂ)))
    convert h using 1
    norm_num
  have hdz1_eq : (fun w : ℂ => deriv (fun u : ℂ => localDoubleZero t u) w) = fun w => 2 * w := by
    ext w; exact (hdz1 w).deriv
  have hdz2 : HasDerivAt (fun w : ℂ => 2 * w) (2 : ℂ) z := by
    convert (hasDerivAt_id z).const_mul (2 : ℂ) using 1
    · rfl
    · ring
  rw [hdt.deriv, hdz1_eq, hdz2.deriv]

/-- **Theorem 1.2 (Forward Real-Rootedness vs. Backward Complex Splitting):**
`z² - 2t` has only real zeros iff `t ≥ 0`; for any `t < 0`, the double zero splits off
the real axis into `z = ± i √(-2t)`. -/
theorem localDoubleZero_allRealZeros_iff (t : ℝ) :
    AllRealZeros (localDoubleZero t) ↔ 0 ≤ t := by
  constructor
  · intro hReal
    by_contra hlt
    push Not at hlt
    let y : ℝ := Real.sqrt (-2 * t)
    have hy_pos : 0 < y := Real.sqrt_pos.mpr (by linarith)
    let z₀ : ℂ := (y : ℂ) * Complex.I
    have hzero : localDoubleZero t z₀ = 0 := by
      unfold localDoubleZero z₀
      have hy2 : (y : ℂ) ^ 2 = ((-2 * t : ℝ) : ℂ) := by
        have hR : y ^ 2 = -2 * t := Real.sq_sqrt (show (0 : ℝ) ≤ -2 * t by linarith)
        exact_mod_cast hR
      calc ((y : ℂ) * Complex.I) ^ 2 - 2 * (t : ℂ)
          = (y : ℂ) ^ 2 * Complex.I ^ 2 - 2 * (t : ℂ) := by ring
        _ = ((-2 * t : ℝ) : ℂ) * (-1) - 2 * (t : ℂ) := by rw [hy2, Complex.I_sq]
        _ = 0 := by push_cast; ring
    have him := hReal z₀ hzero
    simp only [z₀, Complex.mul_im, Complex.ofReal_re, Complex.I_im, mul_one,
      Complex.ofReal_im, Complex.I_re, mul_zero, add_zero] at him
    linarith
  · intro ht z hz
    unfold localDoubleZero at hz
    have hz2 : z ^ 2 = 2 * (t : ℂ) := sub_eq_zero.mp hz
    have hre : z.re ^ 2 - z.im ^ 2 = 2 * t := by
      have := congrArg Complex.re hz2
      simpa [sq, Complex.mul_re] using this
    have him : 2 * z.re * z.im = 0 := by
      have := congrArg Complex.im hz2
      have h1 : z.re * z.im + z.im * z.re = 0 := by
        simpa [sq, Complex.mul_im] using this
      linarith
    by_cases hzim : z.im = 0
    · exact hzim
    · have hzre : z.re = 0 := by
        have h1 : z.re * z.im = 0 := by linarith
        exact (mul_eq_zero.mp h1).resolve_right hzim
      rw [hzre, zero_pow two_ne_zero, zero_sub] at hre
      have hsq : 0 < z.im ^ 2 := sq_pos_of_ne_zero hzim
      linarith

end DeBruijnNewman

/-! ============================================================================
## Part 2: Adelic Sato Trace-Norm Convergence (`σ > 1`) vs. Critical-Line Barrier (`σ = 1/2`)
============================================================================ -/

section AdelicTraceNorm

/-- **Theorem 2.1 (Unconditional Convergence in `𝒜_res(H)` for `Re(s) > 1`):**
Any family of local prime transfers `K_p ∈ 𝒜_res(H)` obeying the Euler bound
`‖K_p‖ ≤ C · p^(-σ)` with `σ > 1` converges unconditionally in operator norm
to an element of the restricted Banach algebra `𝒜_res(H)`. -/
theorem adelicTransfer_summable_mem_resAlg {H : Type*}
    [NormedAddCommGroup H] [InnerProductSpace ℂ H] [CompleteSpace H]
    (P : PolarizedHilbertSpace ℂ H) (K : ℕ → (H →L[ℂ] H))
    {C σ : ℝ} (hC : 0 ≤ C) (hσ : 1 < σ)
    (hMem : ∀ n, K n ∈ resAlg P)
    (hZero : K 0 = 0)
    (hBound : ∀ n : ℕ, 0 < n → ‖K n‖ ≤ C * ((n : ℝ) ^ σ)⁻¹) :
    Summable K ∧ (∑' n : ℕ, K n) ∈ resAlg P := by
  have hPSeries : Summable (fun n : ℕ => C * ((n : ℝ) ^ σ)⁻¹) :=
    (Real.summable_nat_rpow_inv.mpr hσ).mul_left C
  have hSumm : Summable K := by
    refine Summable.of_norm_bounded hPSeries fun n => ?_
    rcases Nat.eq_zero_or_pos n with rfl | hpos
    · rw [hZero, norm_zero]
      exact mul_nonneg hC (inv_nonneg.mpr (Real.rpow_nonneg (Nat.cast_nonneg 0) σ))
    · exact hBound n hpos
  refine ⟨hSumm, ?_⟩
  refine (isClosed_resAlg P).mem_of_tendsto hSumm.hasSum ?_
  filter_upwards with s
  exact Subalgebra.sum_mem (resAlg P) fun n _ => hMem n

/-- **Theorem 2.2 (Erdős Elementary Proof — Critical-Line Hilbert–Schmidt Barrier `∑ 1/p = ∞`):**
The sum of reciprocals of primes diverges, so unrenormalized local prime transfers with
`‖K_p(1/2)‖₂² ≳ p⁻¹` cannot converge in Hilbert–Schmidt norm on `Re(s) = 1/2`. -/
theorem not_summable_primes_inv :
    ¬ Summable (fun p : Nat.Primes => ((p : ℕ) : ℝ)⁻¹) := by
  classical
  intro hs
  let f : Nat.Primes → ℝ := fun p => ((p : ℕ) : ℝ)⁻¹
  have hf_nonneg : ∀ p, 0 ≤ f p := fun p => inv_nonneg.mpr (Nat.cast_nonneg _)
  let L : ℝ := ∑' p : Nat.Primes, f p
  have hTend := Metric.tendsto_atTop.mp hs.hasSum (1 / 2) (by norm_num)
  obtain ⟨F, hF⟩ := hTend
  have hF_close : L - 1 / 2 < ∑ p ∈ F, f p := by
    have hd := hF F le_rfl
    rw [Real.dist_eq, abs_lt] at hd
    linarith
  have hDisj_lt : ∀ G : Finset Nat.Primes, Disjoint F G → ∑ p ∈ G, f p < 1 / 2 := by
    intro G hDisj
    have hUnion : ∑ p ∈ F ∪ G, f p ≤ L :=
      hs.sum_le_tsum (F ∪ G) (fun p _ => hf_nonneg p)
    rw [Finset.sum_union hDisj] at hUnion
    linarith
  let M : ℕ := F.card
  let K : ℕ := 2 ^ (M + 1) + 1
  let N : ℕ := K ^ 2
  have hSqrtN : Nat.sqrt N = K := by
    dsimp [N]; rw [sq]; exact Nat.sqrt_eq K
  let I := Finset.Icc 1 N
  let A := I.filter (fun n => ∃ p : Nat.Primes, p ∉ F ∧ (p : ℕ) ∣ n)
  let B := I.filter (fun n => ∀ p : Nat.Primes, (p : ℕ) ∣ n → p ∈ F)
  have hCover : I ⊆ A ∪ B := by
    intro n hn
    by_cases h : ∃ p : Nat.Primes, p ∉ F ∧ (p : ℕ) ∣ n
    · exact Finset.mem_union_left _ (Finset.mem_filter.mpr ⟨hn, h⟩)
    · push Not at h
      refine Finset.mem_union_right _ (Finset.mem_filter.mpr ⟨hn, fun p hp => ?_⟩)
      by_contra hpF
      exact h p hpF hp
  have hCard_le : N ≤ A.card + B.card := by
    calc N = I.card := by simp [I]
      _ ≤ (A ∪ B).card := Finset.card_le_card hCover
      _ ≤ A.card + B.card := Finset.card_union_le A B
  let G : Finset Nat.Primes :=
    ((Finset.Icc 1 N).filter Nat.Prime).attach.image
      (fun x => ⟨x.1, (Finset.mem_filter.mp x.2).2⟩) \ F
  have hG_disj : Disjoint F G := disjoint_sdiff_self_right
  have hA_sub : A ⊆ G.biUnion (fun p => I.filter (fun n => (p : ℕ) ∣ n)) := by
    intro n hn
    obtain ⟨hnI, ⟨p, hpF, hpdvd⟩⟩ := Finset.mem_filter.mp hn
    have hn1 : 1 ≤ n := (Finset.mem_Icc.mp hnI).1
    have hnN : n ≤ N := (Finset.mem_Icc.mp hnI).2
    have hp_le : (p : ℕ) ≤ N := le_trans (Nat.le_of_dvd (by omega) hpdvd) hnN
    have hp_ge : 1 ≤ (p : ℕ) := p.2.one_lt.le
    have hp_mem : (p : ℕ) ∈ (Finset.Icc 1 N).filter Nat.Prime :=
      Finset.mem_filter.mpr ⟨Finset.mem_Icc.mpr ⟨hp_ge, hp_le⟩, p.2⟩
    have hpG : p ∈ G := by
      refine Finset.mem_sdiff.mpr ⟨?_, hpF⟩
      exact Finset.mem_image.mpr ⟨⟨p.1, hp_mem⟩, Finset.mem_attach _ _, rfl⟩
    exact Finset.mem_biUnion.mpr ⟨p, hpG, Finset.mem_filter.mpr ⟨hnI, hpdvd⟩⟩
  have hMult_card : ∀ p : Nat.Primes, (I.filter (fun n => (p : ℕ) ∣ n)).card ≤ N / (p : ℕ) := by
    intro p
    have hp_pos : 0 < (p : ℕ) := p.2.pos
    have hInj : Set.InjOn (fun n : ℕ => n / (p : ℕ))
        (I.filter (fun n => (p : ℕ) ∣ n) : Set ℕ) := by
      intro x hx y hy hEq
      have hxd : (p : ℕ) ∣ x := (Finset.mem_filter.mp hx).2
      have hyd : (p : ℕ) ∣ y := (Finset.mem_filter.mp hy).2
      have hEq' : x / (p : ℕ) = y / (p : ℕ) := hEq
      calc x = (p : ℕ) * (x / (p : ℕ)) := (Nat.mul_div_cancel' hxd).symm
        _ = (p : ℕ) * (y / (p : ℕ)) := by rw [hEq']
        _ = y := Nat.mul_div_cancel' hyd
    have hMaps : Set.MapsTo (fun n : ℕ => n / (p : ℕ))
        (I.filter (fun n => (p : ℕ) ∣ n) : Set ℕ)
        (Finset.Icc 1 (N / (p : ℕ)) : Set ℕ) := by
      intro n hn
      obtain ⟨hnI, hnd⟩ := Finset.mem_filter.mp hn
      obtain ⟨hn1, hnN⟩ := Finset.mem_Icc.mp hnI
      refine Finset.mem_Icc.mpr ⟨?_, Nat.div_le_div_right hnN⟩
      have hp_le_n : (p : ℕ) ≤ n := Nat.le_of_dvd (by omega) hnd
      exact (Nat.le_div_iff_mul_le hp_pos).mpr (by simpa using hp_le_n)
    simpa using Finset.card_le_card_of_injOn _ hMaps hInj
  have hA_bound : (A.card : ℝ) < (N : ℝ) / 2 := by
    have h1 : A.card ≤ ∑ p ∈ G, (I.filter (fun n => (p : ℕ) ∣ n)).card :=
      le_trans (Finset.card_le_card hA_sub) Finset.card_biUnion_le
    have h2 : (A.card : ℝ) ≤ ∑ p ∈ G, (N : ℝ) * f p := by
      calc (A.card : ℝ)
          ≤ ∑ p ∈ G, ((I.filter (fun n => (p : ℕ) ∣ n)).card : ℝ) := by exact_mod_cast h1
        _ ≤ ∑ p ∈ G, ((N / (p : ℕ) : ℕ) : ℝ) :=
              Finset.sum_le_sum fun p _ => by exact_mod_cast hMult_card p
        _ ≤ ∑ p ∈ G, (N : ℝ) * f p := by
              refine Finset.sum_le_sum fun p _ => ?_
              rw [show (N : ℝ) * f p = (N : ℝ) / ((p : ℕ) : ℝ) by rfl]
              exact Nat.cast_div_le
    rw [← Finset.mul_sum] at h2
    have hNpos : (0 : ℝ) < (N : ℝ) := by
      have : 0 < K := Nat.succ_pos _
      exact_mod_cast pow_pos this 2
    have hlt := mul_lt_mul_of_pos_left (hDisj_lt G hG_disj) hNpos
    linarith
  let sfPart : ℕ → Finset Nat.Primes := fun n => F.filter (fun p => Odd (n.factorization p))
  let sqRoot : ℕ → ℕ := fun n => ∏ p ∈ F, (p : ℕ) ^ (n.factorization p / 2)
  have hFactor : ∀ n ∈ B, n = (∏ p ∈ sfPart n, (p : ℕ)) * (sqRoot n) ^ 2 := by
    intro n hn
    obtain ⟨hnI, hnSmooth⟩ := Finset.mem_filter.mp hn
    have hn0 : n ≠ 0 := by have := (Finset.mem_Icc.mp hnI).1; omega
    have hProd : ∏ p ∈ F, (p : ℕ) ^ (n.factorization p) = n := by
      have hSupp : n.factorization.support ⊆ F.image (fun p : Nat.Primes => (p : ℕ)) := by
        intro q hq
        rw [Nat.support_factorization, Nat.mem_primeFactors] at hq
        exact Finset.mem_image.mpr ⟨⟨q, hq.1⟩, hnSmooth ⟨q, hq.1⟩ hq.2.1, rfl⟩
      have hImg : ∏ q ∈ F.image (fun p : Nat.Primes => (p : ℕ)), q ^ (n.factorization q) =
          ∏ p ∈ F, (p : ℕ) ^ (n.factorization p) :=
        Finset.prod_image (fun a _ b _ hab => Subtype.ext hab)
      rw [← hImg, ← Finset.prod_subset hSupp (fun q _ hq => by
        rw [Finsupp.notMem_support_iff.mp hq, pow_zero])]
      exact Nat.prod_factorization_pow_eq_self hn0
    have hSplit : ∀ p ∈ F, (p : ℕ) ^ (n.factorization p) =
        (if Odd (n.factorization p) then (p : ℕ) else 1) * ((p : ℕ) ^ (n.factorization p / 2)) ^ 2 := by
      intro p _
      rw [← pow_mul]
      by_cases hodd : Odd (n.factorization p)
      · simp only [hodd, ↓reduceIte]
        rw [← pow_succ']
        congr 1
        have hmod := Nat.odd_iff.mp hodd
        omega
      · simp only [hodd, ↓reduceIte, one_mul]
        congr 1
        have heven : n.factorization p % 2 = 0 := by
          have := Nat.not_odd_iff_even.mp hodd
          exact Nat.even_iff.mp this
        omega
    calc n = ∏ p ∈ F, (p : ℕ) ^ (n.factorization p) := hProd.symm
      _ = ∏ p ∈ F, ((if Odd (n.factorization p) then (p : ℕ) else 1) *
            ((p : ℕ) ^ (n.factorization p / 2)) ^ 2) := Finset.prod_congr rfl hSplit
      _ = (∏ p ∈ F, if Odd (n.factorization p) then (p : ℕ) else 1) *
            ∏ p ∈ F, ((p : ℕ) ^ (n.factorization p / 2)) ^ 2 := Finset.prod_mul_distrib
      _ = (∏ p ∈ sfPart n, (p : ℕ)) * (sqRoot n) ^ 2 := by
            rw [Finset.prod_ite, Finset.prod_const_one, mul_one, Finset.prod_pow]
  have hB_bound : B.card ≤ 2 ^ M * K := by
    let φ : ℕ → Finset Nat.Primes × ℕ := fun n => (sfPart n, sqRoot n)
    have hInj : Set.InjOn φ (B : Set ℕ) := by
      intro x hx y hy hEq
      have h1 : sfPart x = sfPart y := congrArg Prod.fst hEq
      have h2 : sqRoot x = sqRoot y := congrArg Prod.snd hEq
      rw [hFactor x hx, hFactor y hy, h1, h2]
    have hMaps : Set.MapsTo φ (B : Set ℕ) (((F.powerset ×ˢ Finset.Icc 1 K) : Finset _) : Set _) := by
      intro n hn
      rw [Finset.mem_coe, Finset.mem_product]
      refine ⟨Finset.mem_powerset.mpr (Finset.filter_subset _ _), ?_⟩
      have hPos : 0 < sqRoot n := Finset.prod_pos fun p _ => pow_pos p.2.pos _
      have hSqLe : (sqRoot n) ^ 2 ≤ N := by
        have haPos : 1 ≤ ∏ p ∈ sfPart n, (p : ℕ) :=
          Finset.one_le_prod fun p _ => p.2.one_lt.le
        have hnN : n ≤ N := (Finset.mem_Icc.mp (Finset.mem_filter.mp hn).1).2
        calc (sqRoot n) ^ 2 ≤ (∏ p ∈ sfPart n, (p : ℕ)) * (sqRoot n) ^ 2 :=
              Nat.le_mul_of_pos_left _ haPos
          _ = n := (hFactor n hn).symm
          _ ≤ N := hnN
      refine Finset.mem_Icc.mpr ⟨hPos, ?_⟩
      rw [← hSqrtN]
      exact Nat.le_sqrt.mpr (by simpa [sq] using hSqLe)
    have hC := Finset.card_le_card_of_injOn φ hMaps hInj
    simpa [Finset.card_product, Finset.card_powerset, M] using hC
  have hTotal : (N : ℝ) < (N : ℝ) / 2 + (2 ^ M : ℝ) * (K : ℝ) := by
    have hCast : (N : ℝ) ≤ (A.card : ℝ) + (B.card : ℝ) := by exact_mod_cast hCard_le
    have hB' : (B.card : ℝ) ≤ (2 ^ M : ℝ) * (K : ℝ) := by exact_mod_cast hB_bound
    linarith
  have hKpos : (0 : ℝ) < (K : ℝ) := by exact_mod_cast Nat.succ_pos (2 ^ (M + 1))
  have hN_eq : (N : ℝ) = (K : ℝ) * (K : ℝ) := by dsimp [N]; push_cast; ring
  rw [hN_eq] at hTotal
  have hHalf : (K : ℝ) * (K : ℝ) < (2 ^ (M + 1) : ℝ) * (K : ℝ) := by
    have hpow' : (2 : ℝ) ^ (M + 1) = 2 * (2 : ℝ) ^ M := by rw [pow_succ']
    nlinarith [hpow', hTotal]
  have hKlt : (K : ℝ) < (2 ^ (M + 1) : ℝ) := lt_of_mul_lt_mul_right hHalf hKpos.le
  have hKeq : (K : ℝ) = (2 ^ (M + 1) : ℝ) + 1 := by dsimp [K]; push_cast; ring
  linarith

/-- **Corollary 2.3 (Critical-Line Trace-Norm Barrier `∑ p^(-1/2) = ∞`):**
Raw local prime transfers with trace norm `‖K_p(1/2)‖₁ ≳ p^(-1/2)` cannot converge
absolutely in trace norm `ℐ₁` as `p_max → ∞`. -/
theorem not_summable_primes_inv_sqrt :
    ¬ Summable (fun p : Nat.Primes => ((p : ℕ) : ℝ) ^ (-(1 / 2 : ℝ))) := by
  intro hs
  apply not_summable_primes_inv
  refine Summable.of_nonneg_of_le (fun p => inv_nonneg.mpr (Nat.cast_nonneg _)) (fun p => ?_) hs
  have hp1 : (1 : ℝ) ≤ ((p : ℕ) : ℝ) := by exact_mod_cast p.2.one_lt.le
  rw [← Real.rpow_neg_one]
  exact Real.rpow_le_rpow_of_exponent_le hp1 (by norm_num)

end AdelicTraceNorm

/-! ============================================================================
## Part 3: Global Li Criterion & Degree-2 Jensen–Pólya Positivity
============================================================================ -/

section LiAndJensenPolya

/-- The Cayley transform `w(ρ) = 1 - 1/ρ` mapping the critical line `Re(ρ) = 1/2`
onto the unit circle `|w| = 1`. -/
noncomputable def cayley (ρ : ℂ) : ℂ := 1 - ρ⁻¹

/-- **Theorem 3.1 (Exact Cayley Norm Identity):**
`‖1 - 1/ρ‖² - 1 = (1 - 2 Re(ρ)) / ‖ρ‖²`. -/
theorem norm_sq_cayley_sub_one {ρ : ℂ} (hρ : ρ ≠ 0) :
    ‖cayley ρ‖ ^ 2 - 1 = (1 - 2 * ρ.re) / ‖ρ‖ ^ 2 := by
  have hnorm_pos : ‖ρ‖ ^ 2 ≠ 0 := pow_ne_zero 2 (norm_ne_zero_iff.mpr hρ)
  have hEq : cayley ρ = (ρ - 1) / ρ := by
    unfold cayley; field_simp [hρ]
  rw [hEq, norm_div, div_pow]
  rw [Complex.sq_norm, Complex.sq_norm, Complex.normSq_apply, Complex.normSq_apply]
  have hpos' : ρ.re ^ 2 + ρ.im ^ 2 ≠ 0 := by
    have h1 : ρ.re * ρ.re + ρ.im * ρ.im ≠ 0 := by
      simpa [Complex.sq_norm, Complex.normSq_apply] using hnorm_pos
    simpa [sq] using h1
  simp only [Complex.sub_re, Complex.one_re, Complex.sub_im, Complex.one_im, sub_zero]
  rw [show ρ.re * ρ.re + ρ.im * ρ.im = ρ.re ^ 2 + ρ.im ^ 2 by ring]
  field_simp [hpos']
  ring

/-- `‖1 - 1/ρ‖ = 1 ↔ Re(ρ) = 1/2`. -/
theorem norm_cayley_eq_one_iff {ρ : ℂ} (hρ : ρ ≠ 0) :
    ‖cayley ρ‖ = 1 ↔ ρ.re = 1 / 2 := by
  have hpos : 0 < ‖ρ‖ ^ 2 := pow_pos (norm_pos_iff.mpr hρ) 2
  have hiff : ‖cayley ρ‖ = 1 ↔ ‖cayley ρ‖ ^ 2 - 1 = 0 := by
    constructor
    · intro h; rw [h]; norm_num
    · intro h; nlinarith [norm_nonneg (cayley ρ)]
  rw [hiff, norm_sq_cayley_sub_one hρ, div_eq_zero_iff]
  constructor
  · intro h
    have h0 := h.resolve_right hpos.ne'
    linarith
  · intro h
    left; linarith

/-- `‖1 - 1/ρ‖ ≤ 1 ↔ 1/2 ≤ Re(ρ)`. -/
theorem norm_cayley_le_one_iff {ρ : ℂ} (hρ : ρ ≠ 0) :
    ‖cayley ρ‖ ≤ 1 ↔ (1 / 2 : ℝ) ≤ ρ.re := by
  have hpos : 0 < ‖ρ‖ ^ 2 := pow_pos (norm_pos_iff.mpr hρ) 2
  have hiff : ‖cayley ρ‖ ≤ 1 ↔ ‖cayley ρ‖ ^ 2 - 1 ≤ 0 := by
    constructor
    · intro h; nlinarith [norm_nonneg (cayley ρ)]
    · intro h; nlinarith [norm_nonneg (cayley ρ)]
  rw [hiff, norm_sq_cayley_sub_one hρ, div_nonpos_iff]
  constructor
  · rintro (⟨h1, h2⟩ | ⟨h1, h2⟩)
    · linarith
    · linarith
  · intro h
    right; exact ⟨by linarith, hpos.le⟩

/-- Individual Li summand `Re(1 - (1 - 1/ρ)^n)`. -/
noncomputable def liSummand (ρ : ℂ) (n : ℕ) : ℝ :=
  (1 - (cayley ρ) ^ n).re

/-- **Theorem 3.2 (Li Positivity on the Critical Line / Right Half-Strip):**
If `Re(ρ) ≥ 1/2`, then every Li summand `Re(1 - (1 - 1/ρ)^n) ≥ 0` for all `n`. -/
theorem liSummand_nonneg_of_re_ge_half {ρ : ℂ} (hρ : ρ ≠ 0)
    (hre : (1 / 2 : ℝ) ≤ ρ.re) (n : ℕ) :
    0 ≤ liSummand ρ n := by
  unfold liSummand
  rw [Complex.sub_re, Complex.one_re]
  have hle1 : ‖cayley ρ‖ ≤ 1 := (norm_cayley_le_one_iff hρ).mpr hre
  have hre_le : ((cayley ρ) ^ n).re ≤ ‖(cayley ρ) ^ n‖ := Complex.re_le_norm _
  have hpow_le : ‖(cayley ρ) ^ n‖ ≤ 1 := by
    rw [norm_pow]
    exact pow_le_one₀ (norm_nonneg _) hle1
  linarith

/-- **Theorem 3.3 (Off-Line Exponential Blowup Gap):**
Any zero with `Re(ρ) < 1/2` satisfies `‖(1 - 1/ρ)^n‖ → ∞` exponentially. -/
theorem cayley_pow_unbounded_of_re_lt_half {ρ : ℂ} (hρ : ρ ≠ 0)
    (hre : ρ.re < 1 / 2) :
    Filter.Tendsto (fun n : ℕ => ‖(cayley ρ) ^ n‖) Filter.atTop Filter.atTop := by
  have hgt1 : 1 < ‖cayley ρ‖ := by
    by_contra hle
    push Not at hle
    have := (norm_cayley_le_one_iff hρ).mp hle
    linarith
  simpa only [norm_pow] using tendsto_pow_atTop_atTop_of_one_lt hgt1

/-- Degree-2 Jensen polynomial `J^{2,n}(X) = γ₀ + 2 γ₁ X + γ₂ X²`. -/
def jensen2 (γ₀ γ₁ γ₂ : ℝ) (z : ℂ) : ℂ :=
  (γ₀ : ℂ) + 2 * (γ₁ : ℂ) * z + (γ₂ : ℂ) * z ^ 2

/-- **Theorem 3.4 (Degree-2 Jensen–Pólya Hyperbolicity ↔ Turán Inequality):**
For `γ₂ > 0`, `J^{2,n}` has only real zeros iff `γ₁² - γ₀ γ₂ ≥ 0`. -/
theorem jensen2_allRealZeros_iff_turan {γ₀ γ₁ γ₂ : ℝ} (h2 : 0 < γ₂) :
    AllRealZeros (jensen2 γ₀ γ₁ γ₂) ↔ 0 ≤ γ₁ ^ 2 - γ₀ * γ₂ := by
  constructor
  · intro hReal
    by_contra hneg
    push Not at hneg
    let D : ℝ := γ₀ * γ₂ - γ₁ ^ 2
    have hD_pos : 0 < D := by linarith
    let y : ℝ := Real.sqrt D / γ₂
    have hy_pos : 0 < y := div_pos (Real.sqrt_pos.mpr hD_pos) h2
    let z₀ : ℂ := ((-γ₁ / γ₂ : ℝ) : ℂ) + (y : ℂ) * Complex.I
    have hz0 : jensen2 γ₀ γ₁ γ₂ z₀ = 0 := by
      unfold jensen2 z₀
      have hsq : (y : ℂ) ^ 2 = ((D : ℝ) : ℂ) / ((γ₂ : ℂ) ^ 2) := by
        dsimp [y]
        norm_cast
        rw [div_pow, Real.sq_sqrt hD_pos.le]
      have h2ne : (γ₂ : ℂ) ≠ 0 := by exact_mod_cast h2.ne'
      have hcalc : (((-γ₁ / γ₂ : ℝ) : ℂ) + (y : ℂ) * Complex.I) ^ 2 =
          ((γ₁ : ℂ) ^ 2 - (D : ℂ)) / (γ₂ : ℂ) ^ 2 -
            2 * (γ₁ : ℂ) * (y : ℂ) * Complex.I / (γ₂ : ℂ) := by
        calc (((-γ₁ / γ₂ : ℝ) : ℂ) + (y : ℂ) * Complex.I) ^ 2
            = (-(γ₁ : ℂ) / (γ₂ : ℂ)) ^ 2 +
                2 * (-(γ₁ : ℂ) / (γ₂ : ℂ)) * ((y : ℂ) * Complex.I) +
                (y : ℂ) ^ 2 * Complex.I ^ 2 := by push_cast; ring
          _ = (γ₁ : ℂ) ^ 2 / (γ₂ : ℂ) ^ 2 -
                2 * (γ₁ : ℂ) * (y : ℂ) * Complex.I / (γ₂ : ℂ) -
                (D : ℂ) / (γ₂ : ℂ) ^ 2 := by rw [hsq, Complex.I_sq]; ring
          _ = ((γ₁ : ℂ) ^ 2 - (D : ℂ)) / (γ₂ : ℂ) ^ 2 -
                2 * (γ₁ : ℂ) * (y : ℂ) * Complex.I / (γ₂ : ℂ) := by ring
      rw [hcalc]
      have hDcast : (D : ℂ) = (γ₀ : ℂ) * (γ₂ : ℂ) - (γ₁ : ℂ) ^ 2 := by
        dsimp [D]; push_cast; ring
      rw [hDcast]
      push_cast
      field_simp [h2ne]
      ring
    have him := hReal z₀ hz0
    simp only [z₀, Complex.add_im, Complex.ofReal_im, Complex.mul_im, Complex.ofReal_re,
      Complex.I_im, mul_one, Complex.I_re, mul_zero, add_zero, zero_add] at him
    linarith
  · intro hTuran z hz
    unfold jensen2 at hz
    have hre : γ₀ + 2 * γ₁ * z.re + γ₂ * (z.re ^ 2 - z.im ^ 2) = 0 := by
      have := congrArg Complex.re hz
      simpa [sq, Complex.mul_re] using this
    have him : 2 * z.im * (γ₁ + γ₂ * z.re) = 0 := by
      have := congrArg Complex.im hz
      have h1 : 2 * γ₁ * z.im + γ₂ * (z.re * z.im + z.im * z.re) = 0 := by
        simpa [sq, Complex.mul_im] using this
      linarith
    by_cases hzim : z.im = 0
    · exact hzim
    · have hlin : γ₁ + γ₂ * z.re = 0 := by
        have h1 : z.im * (γ₁ + γ₂ * z.re) = 0 := by linarith
        exact (mul_eq_zero.mp h1).resolve_left hzim
      have hre_val : z.re = -γ₁ / γ₂ := by
        have h2ne : γ₂ ≠ 0 := h2.ne'
        field_simp [h2ne]; linarith
      rw [hre_val] at hre
      have hsq_pos : 0 < z.im ^ 2 := sq_pos_of_ne_zero hzim
      have h2ne : γ₂ ≠ 0 := h2.ne'
      have hcomb : γ₂ * (γ₀ + 2 * γ₁ * (-γ₁ / γ₂) + γ₂ * ((-γ₁ / γ₂) ^ 2 - z.im ^ 2)) = 0 := by
        rw [hre, mul_zero]
      have hsimp : γ₀ * γ₂ - γ₁ ^ 2 - γ₂ ^ 2 * z.im ^ 2 = 0 := by
        field_simp [h2ne] at hcomb
        linarith
      nlinarith [mul_pos (pow_pos h2 2) hsq_pos]

end LiAndJensenPolya

/-! ============================================================================
## Part 4: Self-Adjoint Spectral Closure (Kato–Rellich Theorem for Archimedean + Finite Coupling)
============================================================================ -/

section KatoRellich

variable {H : Type*} [NormedAddCommGroup H] [InnerProductSpace ℂ H] [CompleteSpace H]

/-- An unbounded symmetric linear operator on a complex Hilbert space `H`. -/
structure SymmetricOp (H : Type*) [NormedAddCommGroup H] [InnerProductSpace ℂ H] where
  dom : Submodule ℂ H
  op : dom →ₗ[ℂ] H
  symm : ∀ x y : dom, ⟪op x, (y : H)⟫_ℂ = ⟪(x : H), op y⟫_ℂ

omit [CompleteSpace H] in
/-- **Theorem 4.1 (Pythagorean Identity / Resolvent Lower Bound):**
For any symmetric operator `D`, `μ ∈ ℝ`, and `x ∈ dom(D)`:
`‖D x + (i μ) x‖² = ‖D x‖² + μ² ‖x‖²`. -/
theorem SymmetricOp.norm_sq_add_smul_I (D : SymmetricOp H) (μ : ℝ) (x : D.dom) :
    ‖D.op x + ((μ : ℂ) * Complex.I) • (x : H)‖ ^ 2 =
      ‖D.op x‖ ^ 2 + μ ^ 2 * ‖(x : H)‖ ^ 2 := by
  have hcross : ⟪D.op x, ((μ : ℂ) * Complex.I) • (x : H)⟫_ℂ +
      ⟪((μ : ℂ) * Complex.I) • (x : H), D.op x⟫_ℂ = 0 := by
    rw [inner_smul_right, inner_smul_left, D.symm x x]
    simp only [map_mul, Complex.conj_ofReal, Complex.conj_I]
    ring
  have hnorm_inner : ∀ u : H, (‖u‖ ^ 2 : ℂ) = ⟪u, u⟫_ℂ := fun u => by
    rw [inner_self_eq_norm_sq_to_K]; norm_cast
  have hC : (‖D.op x + ((μ : ℂ) * Complex.I) • (x : H)‖ ^ 2 : ℂ) =
      (‖D.op x‖ ^ 2 + μ ^ 2 * ‖(x : H)‖ ^ 2 : ℝ) := by
    rw [hnorm_inner, inner_add_left, inner_add_right, inner_add_right]
    have h4 : ⟪((μ : ℂ) * Complex.I) • (x : H), ((μ : ℂ) * Complex.I) • (x : H)⟫_ℂ =
        ((μ ^ 2 * ‖(x : H)‖ ^ 2 : ℝ) : ℂ) := by
      rw [inner_smul_left, inner_smul_right, ← hnorm_inner]
      simp only [map_mul, Complex.conj_ofReal, Complex.conj_I]
      push_cast
      calc (μ : ℂ) * -Complex.I * ((μ : ℂ) * Complex.I * (‖(x : H)‖ : ℂ) ^ 2)
          = (μ : ℂ) ^ 2 * (-(Complex.I ^ 2)) * (‖(x : H)‖ : ℂ) ^ 2 := by ring
        _ = (μ : ℂ) ^ 2 * (‖(x : H)‖ : ℂ) ^ 2 := by rw [Complex.I_sq]; ring
    rw [← hnorm_inner (D.op x), h4]
    push_cast
    linear_combination hcross
  exact_mod_cast hC

omit [CompleteSpace H] in
/-- **Theorem 4.2 (Real Spectrum Theorem):** Every eigenvalue of a symmetric operator is real. -/
theorem SymmetricOp.eigenvalue_im_eq_zero (D : SymmetricOp H) {lam : ℂ} {x : D.dom}
    (hx : (x : H) ≠ 0) (heig : D.op x = lam • (x : H)) :
    lam.im = 0 := by
  have h1 := D.symm x x
  rw [heig, inner_smul_left, inner_smul_right] at h1
  have hxx : ⟪(x : H), (x : H)⟫_ℂ ≠ 0 := inner_self_ne_zero.mpr hx
  have hconj : starRingEnd ℂ lam = lam := mul_right_cancel₀ hxx h1
  have him := congrArg Complex.im hconj
  simp only [Complex.conj_im] at him
  linarith

/-- Basic Criterion of Self-Adjointness: `D ± i μ I : dom(D) → H` are surjective for all `μ ≠ 0`. -/
def SymmetricOp.IsSelfAdjoint (D : SymmetricOp H) : Prop :=
  ∀ μ : ℝ, μ ≠ 0 →
    Function.Surjective (fun x : D.dom => D.op x + ((μ : ℂ) * Complex.I) • (x : H))

/-- Self-contained Neumann series invertibility in `H →L[ℂ] H`: if `‖K‖ < 1`,
then `1 + K` is surjective onto `H`. -/
lemma neumann_one_add_surjective {K : H →L[ℂ] H} (hK : ‖K‖ < 1) :
    Function.Surjective ((1 : H →L[ℂ] H) + K) := by
  have hGeom : Summable (fun n : ℕ => ‖K‖ ^ n) :=
    summable_geometric_of_lt_one (norm_nonneg K) hK
  have hSumm : Summable (fun n : ℕ => (-K) ^ n) := by
    refine Summable.of_norm_bounded hGeom fun n => ?_
    rcases Nat.eq_zero_or_pos n with rfl | hpos
    · simp only [pow_zero]; exact ContinuousLinearMap.norm_id_le
    · calc ‖(-K) ^ n‖ ≤ ‖-K‖ ^ n := norm_pow_le' (-K) hpos
        _ = ‖K‖ ^ n := by rw [norm_neg]
  let S : H →L[ℂ] H := ∑' n : ℕ, (-K) ^ n
  let compL := ContinuousLinearMap.compL ℂ H H H
  have hMul : K * S = ∑' n : ℕ, K * (-K) ^ n := by
    have h := hSumm.hasSum.map (compL K).toAddMonoidHom (compL K).continuous
    exact h.tsum_eq.symm
  have hShift : S = 1 + ∑' n : ℕ, (-K) ^ (n + 1) := by
    simpa [S, pow_zero] using hSumm.tsum_eq_zero_add
  have hCancel : K * S = -(∑' n : ℕ, (-K) ^ (n + 1)) := by
    rw [hMul, ← tsum_neg]
    congr 1; funext n
    rw [pow_succ', neg_mul, neg_neg]
  have hId : ((1 : H →L[ℂ] H) + K) * S = 1 := by
    rw [add_mul, one_mul, hCancel, hShift]
    abel
  intro y
  refine ⟨S y, ?_⟩
  change (((1 : H →L[ℂ] H) + K) * S) y = y
  rw [hId]; rfl

/-- Sum of an archimedean symmetric operator `D` and a symmetric non-archimedean coupling `V`
defined on `D.dom`. -/
def SymmetricOp.addCoupling (D : SymmetricOp H) (V : D.dom →ₗ[ℂ] H)
    (hVsymm : ∀ x y : D.dom, ⟪V x, (y : H)⟫_ℂ = ⟪(x : H), V y⟫_ℂ) :
    SymmetricOp H where
  dom := D.dom
  op := D.op + V
  symm := fun x y => by
    simp only [LinearMap.add_apply, inner_add_left, inner_add_right]
    rw [D.symm x y, hVsymm x y]

/-- **Theorem 4.3 (Kato–Rellich Self-Adjoint Closure for Archimedean + Non-Archimedean Coupling):**
If `D` is self-adjoint and `V` is symmetric on `D.dom` with relative bound `a < 1`
(`‖V x‖ ≤ a ‖D x‖ + b ‖x‖`), then `D + V` is symmetric and `(D + V) + i μ I` is
bijective onto `H` for every `|μ| > b / (1 - a)`. -/
theorem katoRellich_closure (D : SymmetricOp H) (hD : D.IsSelfAdjoint)
    (V : D.dom →ₗ[ℂ] H)
    (hVsymm : ∀ x y : D.dom, ⟪V x, (y : H)⟫_ℂ = ⟪(x : H), V y⟫_ℂ)
    {a b : ℝ} (ha0 : 0 ≤ a) (ha1 : a < 1) (hb : 0 ≤ b)
    (hRel : ∀ x : D.dom, ‖V x‖ ≤ a * ‖D.op x‖ + b * ‖(x : H)‖)
    {μ : ℝ} (hμ : b / (1 - a) < |μ|) :
    Function.Bijective (fun x : (D.addCoupling V hVsymm).dom =>
      (D.addCoupling V hVsymm).op x + ((μ : ℂ) * Complex.I) • (x : H)) := by
  have hμ_pos : 0 < |μ| := lt_of_le_of_lt (div_nonneg hb (by linarith)) hμ
  have hμ_ne : μ ≠ 0 := abs_pos.mp hμ_pos
  let DV := D.addCoupling V hVsymm
  have hInj : Function.Injective (fun x : DV.dom => DV.op x + ((μ : ℂ) * Complex.I) • (x : H)) := by
    intro x y hEq
    dsimp only at hEq
    have hdiff : DV.op (x - y) + ((μ : ℂ) * Complex.I) • ((x - y : DV.dom) : H) = 0 := by
      simp only [map_sub, Submodule.coe_sub, smul_sub]
      rw [sub_add_sub_comm, hEq, sub_self]
    have hpyth := DV.norm_sq_add_smul_I μ (x - y)
    rw [hdiff, norm_zero, zero_pow two_ne_zero] at hpyth
    have hnorm0 : ‖((x - y : DV.dom) : H)‖ = 0 := by
      have hμ2 : 0 < μ ^ 2 := sq_pos_of_ne_zero hμ_ne
      have hsq0 : ‖((x - y : DV.dom) : H)‖ ^ 2 = 0 := by
        nlinarith [sq_nonneg ‖DV.op (x - y)‖, sq_nonneg ‖((x - y : DV.dom) : H)‖]
      exact sq_eq_zero_iff.mp hsq0
    have hsub0 : ((x - y : DV.dom) : H) = 0 := norm_eq_zero.mp hnorm0
    exact sub_eq_zero.mp (Subtype.ext hsub0)
  let eR : D.dom ≃ₗ[ℂ] H :=
    LinearEquiv.ofBijective
      { toFun := fun x : D.dom => D.op x + ((μ : ℂ) * Complex.I) • (x : H)
        map_add' := fun x y => by simp only [map_add, Submodule.coe_add, smul_add]; abel
        map_smul' := fun c x => by
          simp only [map_smul, SetLike.val_smul, smul_add, RingHom.id_apply]
          rw [smul_comm] }
      ⟨fun x y hEq => by
          have hEq' : D.op x + ((μ : ℂ) * Complex.I) • (x : H) =
              D.op y + ((μ : ℂ) * Complex.I) • (y : H) := hEq
          have hdiff : D.op (x - y) + ((μ : ℂ) * Complex.I) • ((x - y : D.dom) : H) = 0 := by
            simp only [map_sub, Submodule.coe_sub, smul_sub]
            rw [sub_add_sub_comm, hEq', sub_self]
          have hpyth := D.norm_sq_add_smul_I μ (x - y)
          rw [hdiff, norm_zero, zero_pow two_ne_zero] at hpyth
          have hμ2 : 0 < μ ^ 2 := sq_pos_of_ne_zero hμ_ne
          have hsq0 : ‖((x - y : D.dom) : H)‖ ^ 2 = 0 := by
            nlinarith [sq_nonneg ‖D.op (x - y)‖, sq_nonneg ‖((x - y : D.dom) : H)‖]
          exact sub_eq_zero.mp (Subtype.ext (norm_eq_zero.mp (sq_eq_zero_iff.mp hsq0))),
        hD μ hμ_ne⟩
  let Rlin : H →ₗ[ℂ] D.dom := eR.symm.toLinearMap
  have hR_right : ∀ y : H, D.op (Rlin y) + ((μ : ℂ) * Complex.I) • ((Rlin y : D.dom) : H) = y :=
    fun y => eR.apply_symm_apply y
  let q : ℝ := a + b / |μ|
  have hq_lt1 : q < 1 := by
    dsimp [q]
    have hmul : b / |μ| < 1 - a := by
      rw [div_lt_iff₀ hμ_pos]
      have h1 := (div_lt_iff₀ (by linarith : 0 < 1 - a)).mp hμ
      linarith
    linarith
  have hK_bound : ∀ y : H, ‖V (Rlin y)‖ ≤ q * ‖y‖ := by
    intro y
    have hpyth := D.norm_sq_add_smul_I μ (Rlin y)
    rw [hR_right y] at hpyth
    have hDx_le : ‖D.op (Rlin y)‖ ≤ ‖y‖ := by
      have hsq : ‖D.op (Rlin y)‖ ^ 2 ≤ ‖y‖ ^ 2 := by
        nlinarith [sq_nonneg μ, sq_nonneg ‖((Rlin y : D.dom) : H)‖]
      nlinarith [norm_nonneg (D.op (Rlin y)), norm_nonneg y]
    have hx_le : |μ| * ‖((Rlin y : D.dom) : H)‖ ≤ ‖y‖ := by
      have hsq : (|μ| * ‖((Rlin y : D.dom) : H)‖) ^ 2 ≤ ‖y‖ ^ 2 := by
        rw [mul_pow, sq_abs]
        nlinarith [sq_nonneg ‖D.op (Rlin y)‖]
      nlinarith [mul_nonneg hμ_pos.le (norm_nonneg ((Rlin y : D.dom) : H)), norm_nonneg y]
    have hx_div : ‖((Rlin y : D.dom) : H)‖ ≤ ‖y‖ / |μ| :=
      (le_div_iff₀' hμ_pos).mpr hx_le
    calc ‖V (Rlin y)‖
        ≤ a * ‖D.op (Rlin y)‖ + b * ‖((Rlin y : D.dom) : H)‖ := hRel (Rlin y)
      _ ≤ a * ‖y‖ + b * (‖y‖ / |μ|) :=
            add_le_add (mul_le_mul_of_nonneg_left hDx_le ha0) (mul_le_mul_of_nonneg_left hx_div hb)
      _ = q * ‖y‖ := by dsimp [q]; ring
  let K : H →L[ℂ] H := (V.comp Rlin).mkContinuous q hK_bound
  have hK_norm : ‖K‖ < 1 :=
    lt_of_le_of_lt (LinearMap.mkContinuous_norm_le _ (add_nonneg ha0 (div_nonneg hb hμ_pos.le)) hK_bound) hq_lt1
  have hSurj : Function.Surjective
      (fun x : DV.dom => DV.op x + ((μ : ℂ) * Complex.I) • (x : H)) := by
    intro y
    obtain ⟨z, hz⟩ := neumann_one_add_surjective hK_norm y
    refine ⟨Rlin z, ?_⟩
    have hstep : DV.op (Rlin z) + ((μ : ℂ) * Complex.I) • ((Rlin z : D.dom) : H) =
        ((1 : H →L[ℂ] H) + K) z := by
      change (D.op (Rlin z) + V (Rlin z)) + ((μ : ℂ) * Complex.I) • ((Rlin z : D.dom) : H) =
        z + V (Rlin z)
      rw [add_right_comm, hR_right z]
    exact hstep.trans hz
  exact ⟨hInj, hSurj⟩

end KatoRellich

end Signals.SatoGrassmannian.RHGaps
