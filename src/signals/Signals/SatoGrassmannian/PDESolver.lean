import Mathlib.Analysis.Calculus.Deriv.Basic
import Mathlib.Analysis.Calculus.Deriv.Inv
import Mathlib.Analysis.Calculus.Deriv.Mul
import Mathlib.Analysis.Calculus.Deriv.Pow
import Mathlib.Analysis.Calculus.IteratedDeriv.Lemmas
import Mathlib.Analysis.SpecialFunctions.Trigonometric.DerivHyp
import Signals.SatoGrassmannian.KPFlow
import Signals.SatoGrassmannian.HirotaKP
import Signals.SatoGrassmannian.KP2Nonlinear

open scoped BigOperators

namespace Signals.SatoGrassmannian.PDESolver

open Signals.SatoGrassmannian Signals.SatoGrassmannian.CircleL2
open Signals.SatoGrassmannian.Gr24Truncation Signals.SatoGrassmannian.KPFlow
open Signals.SatoGrassmannian.HirotaKP Signals.SatoGrassmannian.KP2Nonlinear

/-! ============================================================================
## Section 1: Sato's `r`-Reduction Theorem on `Gr_res(L²(S¹))` (KdV, Boussinesq, GD_r)
============================================================================ -/

/-- **Theorem 1 (Sato `r`-Reduction on `Gr_res(L²(S¹))`):**
If `W ∈ Gr_res(L²(S¹))` is invariant under multiplication by `z^r` (`S^r(W) ⊆ W`),
then the entire `r`-th KP flow `exp(s z^r)` fixes `W` identically:
- `r = 2`: `t₂`-independence (KdV hierarchy),
- `r = 3`: `t₃`-independence (Boussinesq hierarchy). -/
theorem kpFlow_fixed_of_shiftPow_invariant (r : ℕ+) (W : SatoGr hardyPolarization)
    (hInv : ∀ f ∈ W.1, (shiftOp ^ (r : ℕ)) f ∈ W.1) (s : ℂ) :
    kpFlow (lp.single 1 r s) • W = W := by
  have hMap : ∀ (c : ℂ) {f : HCircle}, f ∈ W.1 → (kpFlow (lp.single 1 r c)).1 f ∈ W.1 := by
    intro c f hf
    have hgen : kpGenerator (lp.single 1 r c) = c • shiftOp ^ (r : ℕ) := kpGenerator_single r c
    have hpow : ∀ k : ℕ, (kpGenerator (lp.single 1 r c) ^ k) f ∈ W.1 := by
      intro k
      induction k with
      | zero => exact hf
      | succ k ih =>
        rw [pow_succ', mul_apply_eq_comp]
        nth_rw 1 [hgen]
        rw [smul_apply]
        exact W.1.smul_mem c (hInv _ ih)
    have htsum : HasSum
        (fun k : ℕ => ((k.factorial : ℂ)⁻¹ • kpGenerator (lp.single 1 r c) ^ k) f)
        ((kpFlow (lp.single 1 r c)).1 f) :=
      (hasSum_exp_terms (kpGenerator (lp.single 1 r c))).map
        (ContinuousLinearMap.apply ℂ HCircle f).toAddMonoidHom
        (ContinuousLinearMap.apply ℂ HCircle f).continuous
    refine W.2.1.mem_of_tendsto htsum ?_
    filter_upwards with t
    exact Submodule.sum_mem _ fun k _ => W.1.smul_mem _ (hpow k)
  apply Subtype.ext
  ext f
  change f ∈ W.1.map ((kpFlow (lp.single 1 r s)).1 : HCircle →L[ℂ] HCircle).toLinearMap ↔ f ∈ W.1
  constructor
  · rintro ⟨g, hg, rfl⟩
    exact hMap s hg
  · intro hf
    refine ⟨(kpFlow (lp.single 1 r (-s))).1 f, hMap (-s) hf, ?_⟩
    have hneg : lp.single (E := fun _ : ℕ+ => ℂ) 1 r (-s) = -(lp.single 1 r s) := by
      ext n
      by_cases hn : n = r
      · subst hn; simp [lp.single_apply]
      · simp [lp.single_apply, hn]
    rw [hneg]
    have hmul : (kpFlow (lp.single 1 r s) * kpFlow (-(lp.single 1 r s))).1 f = f := by
      rw [← kpFlow_add, add_neg_cancel, kpFlow_zero]; rfl
    exact hmul

/-! ============================================================================
## Section 2: General Hirota Exponential Dispersion Calculus (Arbitrary `N`-Solitons)
============================================================================ -/

/-- General finite exponential `τ`-function `∑_{i ∈ S} c_i exp(α_i t₁ + β_i t₂ + γ_i t₃)`. -/
noncomputable def expSum {ι : Type*} (S : Finset ι) (c α β γ : ι → ℂ) (t₁ t₂ t₃ : ℂ) : ℂ :=
  ∑ i ∈ S, c i * Complex.exp (α i * t₁ + β i * t₂ + γ i * t₃)

/-- Hirota KP dispersion polynomial `(α₁ - α₂)⁴ - 4 (α₁ - α₂)(γ₁ - γ₂) + 3 (β₁ - β₂)²`. -/
def kpDispersion (α₁ β₁ γ₁ α₂ β₂ γ₂ : ℂ) : ℂ :=
  (α₁ - α₂) ^ 4 - 4 * (α₁ - α₂) * (γ₁ - γ₂) + 3 * (β₁ - β₂) ^ 2

lemma kpDispersion_self (α β γ : ℂ) : kpDispersion α β γ α β γ = 0 := by
  unfold kpDispersion; ring

lemma kpDispersion_shared (a b c : ℂ) :
    kpDispersion (a + b) (a ^ 2 + b ^ 2) (a ^ 3 + b ^ 3)
                 (a + c) (a ^ 2 + c ^ 2) (a ^ 3 + c ^ 3) = 0 := by
  unfold kpDispersion; ring

lemma kpDispersion_disjoint (a b c d : ℂ) :
    kpDispersion (a + b) (a ^ 2 + b ^ 2) (a ^ 3 + b ^ 3)
                 (c + d) (c ^ 2 + d ^ 2) (c ^ 3 + d ^ 3) =
      12 * (a - c) * (a - d) * (b - c) * (b - d) := by
  unfold kpDispersion; ring

lemma hasDerivAt_finset_cexp {κ : Type*} (T : Finset κ) (w a : κ → ℂ) (k : ℕ) (y : ℂ) :
    HasDerivAt (fun u => ∑ p ∈ T, w p * a p ^ k * Complex.exp (a p * u))
      (∑ p ∈ T, w p * a p ^ (k + 1) * Complex.exp (a p * y)) y := by
  refine HasDerivAt.fun_sum fun p _ => ?_
  have h1 : HasDerivAt (fun u : ℂ => a p * u) (a p) y := by
    convert (hasDerivAt_id y).const_mul (a p) using 1
    · rfl
    · ring
  have h2 := ((Complex.hasDerivAt_exp (a p * y)).comp y h1).const_mul (w p * a p ^ k)
  convert h2 using 1
  · rfl
  · rw [pow_succ]; ring

lemma iteratedDeriv_finset_cexp {κ : Type*} (T : Finset κ) (w a : κ → ℂ) (n : ℕ) (y : ℂ) :
    iteratedDeriv n (fun u => ∑ p ∈ T, w p * Complex.exp (a p * u)) y =
      ∑ p ∈ T, w p * a p ^ n * Complex.exp (a p * y) := by
  induction n generalizing y with
  | zero => simp
  | succ n ih =>
    rw [iteratedDeriv_succ]
    have hfun : iteratedDeriv n (fun u => ∑ p ∈ T, w p * Complex.exp (a p * u)) =
        fun u => ∑ p ∈ T, w p * a p ^ n * Complex.exp (a p * u) := funext ih
    rw [hfun]
    exact (hasDerivAt_finset_cexp T w a n y).deriv

/-- **Theorem 2 (Exact Hirota Dispersion Formula for Exponential `τ`-Functions):**
For any finite exponential sum `τ = ∑_{i ∈ S} c_i E_i(t)`,
`(D₁⁴ - 4 D₁ D₃ + 3 D₂²)(τ · τ) = ∑_{i, j ∈ S} c_i c_j E_i E_j · kpDispersion(i, j)`. -/
theorem hirotaKP_expSum {ι : Type*} (S : Finset ι) (c α β γ : ι → ℂ) (t₁ t₂ t₃ : ℂ) :
    let E : ι → ℂ := fun i => Complex.exp (α i * t₁ + β i * t₂ + γ i * t₃)
    hirotaKP (expSum S c α β γ) t₁ t₂ t₃ =
      ∑ p ∈ S ×ˢ S, c p.1 * c p.2 * E p.1 * E p.2 *
        kpDispersion (α p.1) (β p.1) (γ p.1) (α p.2) (β p.2) (γ p.2) := by
  intro E
  let W : ι × ι → ℂ := fun p => c p.1 * c p.2 * E p.1 * E p.2
  have h1_eq : (fun y => expSum S c α β γ (t₁ + y) t₂ t₃ * expSum S c α β γ (t₁ - y) t₂ t₃) =
      fun y => ∑ p ∈ S ×ˢ S, W p * Complex.exp ((α p.1 - α p.2) * y) := by
    ext y
    unfold expSum
    rw [Finset.sum_mul_sum, ← Finset.sum_product']
    refine Finset.sum_congr rfl fun p _ => ?_
    dsimp [W, E]
    have hexp : Complex.exp (α p.1 * (t₁ + y) + β p.1 * t₂ + γ p.1 * t₃) *
        Complex.exp (α p.2 * (t₁ - y) + β p.2 * t₂ + γ p.2 * t₃) =
        Complex.exp (α p.1 * t₁ + β p.1 * t₂ + γ p.1 * t₃) *
        Complex.exp (α p.2 * t₁ + β p.2 * t₂ + γ p.2 * t₃) *
        Complex.exp ((α p.1 - α p.2) * y) := by
      rw [← Complex.exp_add, ← Complex.exp_add, ← Complex.exp_add]; congr 1; ring
    calc c p.1 * Complex.exp (α p.1 * (t₁ + y) + β p.1 * t₂ + γ p.1 * t₃) *
          (c p.2 * Complex.exp (α p.2 * (t₁ - y) + β p.2 * t₂ + γ p.2 * t₃))
        = c p.1 * c p.2 *
            (Complex.exp (α p.1 * (t₁ + y) + β p.1 * t₂ + γ p.1 * t₃) *
             Complex.exp (α p.2 * (t₁ - y) + β p.2 * t₂ + γ p.2 * t₃)) := by ring
      _ = _ := by rw [hexp]; ring
  have hD1 : hirotaD1 4 (expSum S c α β γ) (expSum S c α β γ) t₁ t₂ t₃ =
      ∑ p ∈ S ×ˢ S, W p * (α p.1 - α p.2) ^ 4 := by
    unfold hirotaD1
    rw [h1_eq, iteratedDeriv_finset_cexp]
    simp
  have h2_eq : (fun y => expSum S c α β γ t₁ (t₂ + y) t₃ * expSum S c α β γ t₁ (t₂ - y) t₃) =
      fun y => ∑ p ∈ S ×ˢ S, W p * Complex.exp ((β p.1 - β p.2) * y) := by
    ext y
    unfold expSum
    rw [Finset.sum_mul_sum, ← Finset.sum_product']
    refine Finset.sum_congr rfl fun p _ => ?_
    dsimp [W, E]
    have hexp : Complex.exp (α p.1 * t₁ + β p.1 * (t₂ + y) + γ p.1 * t₃) *
        Complex.exp (α p.2 * t₁ + β p.2 * (t₂ - y) + γ p.2 * t₃) =
        Complex.exp (α p.1 * t₁ + β p.1 * t₂ + γ p.1 * t₃) *
        Complex.exp (α p.2 * t₁ + β p.2 * t₂ + γ p.2 * t₃) *
        Complex.exp ((β p.1 - β p.2) * y) := by
      rw [← Complex.exp_add, ← Complex.exp_add, ← Complex.exp_add]; congr 1; ring
    calc c p.1 * Complex.exp (α p.1 * t₁ + β p.1 * (t₂ + y) + γ p.1 * t₃) *
          (c p.2 * Complex.exp (α p.2 * t₁ + β p.2 * (t₂ - y) + γ p.2 * t₃))
        = c p.1 * c p.2 *
            (Complex.exp (α p.1 * t₁ + β p.1 * (t₂ + y) + γ p.1 * t₃) *
             Complex.exp (α p.2 * t₁ + β p.2 * (t₂ - y) + γ p.2 * t₃)) := by ring
      _ = _ := by rw [hexp]; ring
  have hD2 : hirotaD2 2 (expSum S c α β γ) (expSum S c α β γ) t₁ t₂ t₃ =
      ∑ p ∈ S ×ˢ S, W p * (β p.1 - β p.2) ^ 2 := by
    unfold hirotaD2
    rw [h2_eq, iteratedDeriv_finset_cexp]
    simp
  have h13_inner : ∀ y₁ : ℂ,
      (fun y₃ => expSum S c α β γ (t₁ + y₁) t₂ (t₃ + y₃) * expSum S c α β γ (t₁ - y₁) t₂ (t₃ - y₃)) =
      fun y₃ => ∑ p ∈ S ×ˢ S, (W p * Complex.exp ((α p.1 - α p.2) * y₁)) *
        Complex.exp ((γ p.1 - γ p.2) * y₃) := by
    intro y₁; ext y₃
    unfold expSum
    rw [Finset.sum_mul_sum, ← Finset.sum_product']
    refine Finset.sum_congr rfl fun p _ => ?_
    dsimp [W, E]
    have hexp : Complex.exp (α p.1 * (t₁ + y₁) + β p.1 * t₂ + γ p.1 * (t₃ + y₃)) *
        Complex.exp (α p.2 * (t₁ - y₁) + β p.2 * t₂ + γ p.2 * (t₃ - y₃)) =
        Complex.exp (α p.1 * t₁ + β p.1 * t₂ + γ p.1 * t₃) *
        Complex.exp (α p.2 * t₁ + β p.2 * t₂ + γ p.2 * t₃) *
        Complex.exp ((α p.1 - α p.2) * y₁) * Complex.exp ((γ p.1 - γ p.2) * y₃) := by
      rw [← Complex.exp_add, ← Complex.exp_add, ← Complex.exp_add, ← Complex.exp_add]; congr 1; ring
    calc c p.1 * Complex.exp (α p.1 * (t₁ + y₁) + β p.1 * t₂ + γ p.1 * (t₃ + y₃)) *
          (c p.2 * Complex.exp (α p.2 * (t₁ - y₁) + β p.2 * t₂ + γ p.2 * (t₃ - y₃)))
        = c p.1 * c p.2 *
            (Complex.exp (α p.1 * (t₁ + y₁) + β p.1 * t₂ + γ p.1 * (t₃ + y₃)) *
             Complex.exp (α p.2 * (t₁ - y₁) + β p.2 * t₂ + γ p.2 * (t₃ - y₃))) := by ring
      _ = _ := by rw [hexp]; ring
  have hD13 : hirotaD1D3 (expSum S c α β γ) (expSum S c α β γ) t₁ t₂ t₃ =
      ∑ p ∈ S ×ˢ S, W p * ((α p.1 - α p.2) * (γ p.1 - γ p.2)) := by
    unfold hirotaD1D3
    have hinner : (fun y₁ => deriv (fun y₃ =>
        expSum S c α β γ (t₁ + y₁) t₂ (t₃ + y₃) * expSum S c α β γ (t₁ - y₁) t₂ (t₃ - y₃)) 0) =
        fun y₁ => ∑ p ∈ S ×ˢ S, (W p * (γ p.1 - γ p.2)) * Complex.exp ((α p.1 - α p.2) * y₁) := by
      ext y₁
      rw [h13_inner y₁]
      have hd := (hasDerivAt_finset_cexp (S ×ˢ S)
        (fun p => W p * Complex.exp ((α p.1 - α p.2) * y₁))
        (fun p => γ p.1 - γ p.2) 0 0).deriv
      simpa [mul_right_comm, mul_assoc] using hd
    rw [hinner]
    have hd2 := (hasDerivAt_finset_cexp (S ×ˢ S)
      (fun p => W p * (γ p.1 - γ p.2)) (fun p => α p.1 - α p.2) 0 0).deriv
    simpa [mul_comm, mul_left_comm, mul_assoc] using hd2
  unfold hirotaKP kpDispersion
  rw [hD1, hD2, hD13, Finset.mul_sum, Finset.mul_sum, ← Finset.sum_sub_distrib,
      ← Finset.sum_add_distrib]
  refine Finset.sum_congr rfl fun p _ => ?_
  dsimp [W]; ring

/-! ============================================================================
## Section 3: Kodama–Williams `Gr_ℂ(2, 4)` Multi-Soliton Solver & `Gr_≥0(2, 4)` Smoothness
============================================================================ -/

/-- Canonical enumeration of the 6 index pairs `0 ≤ i < j ≤ 3`. -/
def pairIdx : Fin 6 → Fin 4 × Fin 4
  | 0 => (0, 1)
  | 1 => (0, 2)
  | 2 => (0, 3)
  | 3 => (1, 2)
  | 4 => (1, 3)
  | 5 => (2, 3)

/-- Vandermonde determinant `Δ(κ) = ∏_{0 ≤ i < j ≤ 3} (κ_j - κ_i)`. -/
def vandermonde4 (κ : C4) : ℂ :=
  (κ 1 - κ 0) * (κ 2 - κ 0) * (κ 3 - κ 0) * (κ 2 - κ 1) * (κ 3 - κ 1) * (κ 3 - κ 2)

/-- General 6-Plücker exponential `τ`-function for wavenumbers `κ : Fin 4 → ℂ`. -/
noncomputable def solitonTauGeneral (κ : C4) (p01 p02 p03 p12 p13 p23 : ℂ) (t₁ t₂ t₃ : ℂ) : ℂ :=
  let coeff : Fin 6 → ℂ := fun r => match r with
    | 0 => p01 * (κ 1 - κ 0)
    | 1 => p02 * (κ 2 - κ 0)
    | 2 => p03 * (κ 3 - κ 0)
    | 3 => p12 * (κ 2 - κ 1)
    | 4 => p13 * (κ 3 - κ 1)
    | 5 => p23 * (κ 3 - κ 2)
  let α : Fin 6 → ℂ := fun r => κ (pairIdx r).1 + κ (pairIdx r).2
  let β : Fin 6 → ℂ := fun r => κ (pairIdx r).1 ^ 2 + κ (pairIdx r).2 ^ 2
  let γ : Fin 6 → ℂ := fun r => κ (pairIdx r).1 ^ 3 + κ (pairIdx r).2 ^ 3
  expSum Finset.univ coeff α β γ t₁ t₂ t₃

/-- Frame-based Wronskian `τ`-function `τ_{κ, v, w}(t₁, t₂, t₃)` for `(v, w)` in `Gr_ℂ(2, 4)`. -/
noncomputable def solitonTau (κ v w : C4) (t₁ t₂ t₃ : ℂ) : ℂ :=
  solitonTauGeneral κ
    (pluckerCoord v w 0 1) (pluckerCoord v w 0 2) (pluckerCoord v w 0 3)
    (pluckerCoord v w 1 2) (pluckerCoord v w 1 3) (pluckerCoord v w 2 3)
    t₁ t₂ t₃

/-- **Theorem 3.1 (Cauchy–Binet Wronskian Identity):**
`solitonTau κ v w = f₁ * f₂' - f₁' * f₂` for the linear heat/Airy waves
`f₁(t) = ∑ v_j e^{κ_j t₁ + κ_j² t₂ + κ_j³ t₃}`, `f₂(t) = ∑ w_j e^{κ_j t₁ + κ_j² t₂ + κ_j³ t₃}`. -/
theorem solitonTau_eq_wronskian (κ v w : C4) (t₁ t₂ t₃ : ℂ) :
    let E : Fin 4 → ℂ := fun j => Complex.exp (κ j * t₁ + κ j ^ 2 * t₂ + κ j ^ 3 * t₃)
    let f1 : ℂ := ∑ j : Fin 4, v j * E j
    let f1x : ℂ := ∑ j : Fin 4, v j * κ j * E j
    let f2 : ℂ := ∑ j : Fin 4, w j * E j
    let f2x : ℂ := ∑ j : Fin 4, w j * κ j * E j
    solitonTau κ v w t₁ t₂ t₃ = f1 * f2x - f1x * f2 := by
  intro E f1 f1x f2 f2x
  unfold solitonTau solitonTauGeneral expSum pluckerCoord
  simp only [Fin.sum_univ_six, Fin.sum_univ_four, pairIdx, f1, f1x, f2, f2x]
  have hE : ∀ i j : Fin 4,
      Complex.exp ((κ i + κ j) * t₁ + (κ i ^ 2 + κ j ^ 2) * t₂ + (κ i ^ 3 + κ j ^ 3) * t₃) =
      E i * E j := by
    intro i j; dsimp [E]; rw [← Complex.exp_add]; congr 1; ring
  simp only [hE]
  ring

/-- **Theorem 3.2 (Exact Klein-Quadric Factorization of `hirotaKP (solitonTauGeneral)`):**
`(D₁⁴ - 4 D₁ D₃ + 3 D₂²)(τ · τ) = 24 Δ(κ) E₀ E₁ E₂ E₃ (p₀₁ p₂₃ - p₀₂ p₁₃ + p₀₃ p₁₂)`. -/
theorem hirotaKP_solitonTauGeneral_eq (κ : C4) (p01 p02 p03 p12 p13 p23 : ℂ) (t₁ t₂ t₃ : ℂ) :
    let E : Fin 4 → ℂ := fun j => Complex.exp (κ j * t₁ + κ j ^ 2 * t₂ + κ j ^ 3 * t₃)
    hirotaKP (solitonTauGeneral κ p01 p02 p03 p12 p13 p23) t₁ t₂ t₃ =
      24 * vandermonde4 κ * (E 0 * E 1 * E 2 * E 3) *
        (p01 * p23 - p02 * p13 + p03 * p12) := by
  intro E
  unfold solitonTauGeneral
  rw [hirotaKP_expSum]
  have hE : ∀ i j : Fin 4,
      Complex.exp ((κ i + κ j) * t₁ + (κ i ^ 2 + κ j ^ 2) * t₂ + (κ i ^ 3 + κ j ^ 3) * t₃) =
      E i * E j := by
    intro i j; dsimp [E]; rw [← Complex.exp_add]; congr 1; ring
  simp only [Finset.sum_product, Fin.sum_univ_six, pairIdx, hE]
  have hS := fun a b c : ℂ => kpDispersion_shared a b c
  have hS' : ∀ a b c : ℂ,
      kpDispersion (a + b) (a ^ 2 + b ^ 2) (a ^ 3 + b ^ 3)
                   (c + a) (c ^ 2 + a ^ 2) (c ^ 3 + a ^ 3) = 0 := fun a b c => by
    rw [add_comm c a, add_comm (c ^ 2) (a ^ 2), add_comm (c ^ 3) (a ^ 3)]; exact hS a b c
  have hS'' : ∀ a b c : ℂ,
      kpDispersion (b + a) (b ^ 2 + a ^ 2) (b ^ 3 + a ^ 3)
                   (a + c) (a ^ 2 + c ^ 2) (a ^ 3 + c ^ 3) = 0 := fun a b c => by
    rw [add_comm b a, add_comm (b ^ 2) (a ^ 2), add_comm (b ^ 3) (a ^ 3)]; exact hS a b c
  have hS''' : ∀ a b c : ℂ,
      kpDispersion (b + a) (b ^ 2 + a ^ 2) (b ^ 3 + a ^ 3)
                   (c + a) (c ^ 2 + a ^ 2) (c ^ 3 + a ^ 3) = 0 := fun a b c => by
    rw [add_comm b a, add_comm (b ^ 2) (a ^ 2), add_comm (b ^ 3) (a ^ 3),
        add_comm c a, add_comm (c ^ 2) (a ^ 2), add_comm (c ^ 3) (a ^ 3)]; exact hS a b c
  simp only [kpDispersion_self, hS, hS', hS'', hS''', kpDispersion_disjoint,
    mul_zero, add_zero, zero_add]
  unfold vandermonde4
  ring

/-- **Theorem 3.3 (Exact KP-II Multi-Soliton Solver):**
For every 2-plane frame `(v, w)` and wavenumbers `κ`, `solitonTau κ v w` solves the
Hirota bilinear KP PDE identically on `ℂ³` as a direct consequence of `kleinQuadric_relation`. -/
theorem hirotaKP_solitonTau_eq_zero (κ v w : C4) (t₁ t₂ t₃ : ℂ) :
    hirotaKP (solitonTau κ v w) t₁ t₂ t₃ = 0 := by
  unfold solitonTau
  rw [hirotaKP_solitonTauGeneral_eq, kleinQuadric_relation v w, mul_zero]

/-- **Theorem 3.4 (Kodama–Williams Global Smoothness from Total Positivity `Gr_≥0(2, 4)`):**
If `κ₀ < κ₁ < κ₂ < κ₃` are real and all 6 Plücker minors `p_{ij}(v, w) ≥ 0` with at least one
strictly positive, then `τ_{κ, v, w}(t₁, t₂, t₃) > 0` for ALL `(t₁, t₂, t₃) ∈ ℝ³`—
guaranteeing globally smooth, singularity-free KP-II multi-solitons. -/
theorem solitonTau_pos_of_totallyNonneg (κ v w : Fin 4 → ℝ)
    (hκ : StrictMono κ)
    (hNN : ∀ i j : Fin 4, i < j → 0 ≤ v i * w j - v j * w i)
    (hPos : ∃ i j : Fin 4, i < j ∧ 0 < v i * w j - v j * w i)
    (t₁ t₂ t₃ : ℝ) :
    let κC : C4 := fun i => (κ i : ℂ)
    let vC : C4 := fun i => (v i : ℂ)
    let wC : C4 := fun i => (w i : ℂ)
    0 < (solitonTau κC vC wC (t₁ : ℂ) (t₂ : ℂ) (t₃ : ℂ)).re ∧
    solitonTau κC vC wC (t₁ : ℂ) (t₂ : ℂ) (t₃ : ℂ) ≠ 0 := by
  intro κC vC wC
  let term : Fin 6 → ℝ := fun r =>
    let i := (pairIdx r).1
    let j := (pairIdx r).2
    (v i * w j - v j * w i) * (κ j - κ i) *
      Real.exp ((κ i + κ j) * t₁ + (κ i ^ 2 + κ j ^ 2) * t₂ + (κ i ^ 3 + κ j ^ 3) * t₃)
  have hRe : (solitonTau κC vC wC (t₁ : ℂ) (t₂ : ℂ) (t₃ : ℂ)).re = ∑ r : Fin 6, term r := by
    unfold solitonTau solitonTauGeneral expSum pluckerCoord
    rw [Complex.re_sum]
    simp only [Fin.sum_univ_six, pairIdx, term, κC, vC, wC]
    have hcast : ∀ a b : ℝ, (((a : ℂ) * Complex.exp (b : ℂ)).re) = a * Real.exp b := fun a b => by
      rw [← Complex.ofReal_exp, ← Complex.ofReal_mul, Complex.ofReal_re]
    have hEq : ∀ (i j : Fin 4),
        (((κ i : ℂ) + (κ j : ℂ)) * (t₁ : ℂ) + ((κ i : ℂ) ^ 2 + (κ j : ℂ) ^ 2) * (t₂ : ℂ) +
         ((κ i : ℂ) ^ 3 + (κ j : ℂ) ^ 3) * (t₃ : ℂ)) =
        (((κ i + κ j) * t₁ + (κ i ^ 2 + κ j ^ 2) * t₂ + (κ i ^ 3 + κ j ^ 3) * t₃ : ℝ) : ℂ) := by
      intro i j; push_cast; ring
    simp only [hEq]
    have hpre : ∀ (i j : Fin 4),
        ((v i : ℂ) * (w j : ℂ) - (v j : ℂ) * (w i : ℂ)) * ((κ j : ℂ) - (κ i : ℂ)) =
        (((v i * w j - v j * w i) * (κ j - κ i) : ℝ) : ℂ) := by
      intro i j; push_cast; ring
    simp only [hpre, hcast]
  have hNonneg : ∀ r : Fin 6, 0 ≤ term r := by
    intro r
    have hlt : (pairIdx r).1 < (pairIdx r).2 := by fin_cases r <;> decide
    exact mul_nonneg (mul_nonneg (hNN _ _ hlt) (sub_pos.mpr (hκ hlt)).le) (Real.exp_pos _).le
  have hExistsPos : ∃ r : Fin 6, 0 < term r := by
    rcases hPos with ⟨i, j, hlt, hp⟩
    have hex : ∃ r : Fin 6, pairIdx r = (i, j) := by
      fin_cases i <;> fin_cases j <;> simp at hlt
      · exact ⟨0, rfl⟩
      · exact ⟨1, rfl⟩
      · exact ⟨2, rfl⟩
      · exact ⟨3, rfl⟩
      · exact ⟨4, rfl⟩
      · exact ⟨5, rfl⟩
    rcases hex with ⟨r, hr⟩
    refine ⟨r, ?_⟩
    dsimp [term]
    rw [hr]
    exact mul_pos (mul_pos hp (sub_pos.mpr (hκ hlt))) (Real.exp_pos _)
  obtain ⟨r₀, hr₀⟩ := hExistsPos
  have hSumPos : 0 < ∑ r : Fin 6, term r :=
    Finset.sum_pos' (fun r _ => hNonneg r) ⟨r₀, Finset.mem_univ r₀, hr₀⟩
  rw [hRe]
  refine ⟨hSumPos, fun h0 => ?_⟩
  rw [h0, Complex.zero_re] at hRe
  linarith

/-! ============================================================================
## Section 4: Exponential Gauge Invariance, KdV 2-Soliton & Exact `sech²` KdV PDE
============================================================================ -/

/-- **Theorem 4.1 (Exponential Gauge Invariance of `u = 2 ∂₁² log τ`):**
Multiplying `τ` by `exp(a t₁ + b t₂ + c t₃)` leaves the KP potential `kpU τ` unchanged. -/
theorem kpU_mul_cexp_linear {τ : ℂ → ℂ → ℂ → ℂ} {d1 : ℂ → ℂ} {d2 : ℂ}
    (a b c t₁ t₂ t₃ : ℂ)
    (h1 : ∀ x, HasDerivAt (fun u => τ u t₂ t₃) (d1 x) x)
    (h2 : HasDerivAt d1 d2 t₁)
    (hτ : τ t₁ t₂ t₃ ≠ 0) :
    let τ' : ℂ → ℂ → ℂ → ℂ := fun x y z => Complex.exp (a * x + b * y + c * z) * τ x y z
    kpU τ' t₁ t₂ t₃ = kpU τ t₁ t₂ t₃ := by
  intro τ'
  let E : ℂ → ℂ := fun u => Complex.exp (a * u + b * t₂ + c * t₃)
  have hE : ∀ u, HasDerivAt E (a * E u) u := fun u => by
    have hlin : HasDerivAt (fun s => a * s + b * t₂ + c * t₃) a u := by
      have h := (((hasDerivAt_id u).const_mul a).add (hasDerivAt_const u (b * t₂))).add
        (hasDerivAt_const u (c * t₃))
      convert h using 1
      · funext s; simp only [Pi.add_apply, id_eq]
      · ring
    have hc := (Complex.hasDerivAt_exp (a * u + b * t₂ + c * t₃)).comp u hlin
    convert hc using 1
    · rfl
    · dsimp [E]; ring
  have hτ'1 : ∀ u, HasDerivAt (fun s => τ' s t₂ t₃) (a * E u * τ u t₂ t₃ + E u * d1 u) u :=
    fun u => by convert (hE u).mul (h1 u) using 1
  have hτ'2 : HasDerivAt (fun u => a * E u * τ u t₂ t₃ + E u * d1 u)
      (a ^ 2 * E t₁ * τ t₁ t₂ t₃ + 2 * a * E t₁ * d1 t₁ + E t₁ * d2) t₁ := by
    have ha := ((hE t₁).const_mul a).mul (h1 t₁)
    have hb := (hE t₁).mul h2
    convert ha.add hb using 1
    ring
  have hd1_orig : deriv (fun u => τ u t₂ t₃) = d1 := funext fun u => (h1 u).deriv
  have hd2_orig : iteratedDeriv 2 (fun u => τ u t₂ t₃) t₁ = d2 := by
    rw [iteratedDeriv_succ, iteratedDeriv_one, hd1_orig]; exact h2.deriv
  have hd1_new : deriv (fun u => τ' u t₂ t₃) = fun u => a * E u * τ u t₂ t₃ + E u * d1 u :=
    funext fun u => (hτ'1 u).deriv
  have hd2_new : iteratedDeriv 2 (fun u => τ' u t₂ t₃) t₁ =
      a ^ 2 * E t₁ * τ t₁ t₂ t₃ + 2 * a * E t₁ * d1 t₁ + E t₁ * d2 := by
    rw [iteratedDeriv_succ, iteratedDeriv_one, hd1_new]; exact hτ'2.deriv
  unfold kpU
  rw [hd2_new, hd2_orig, congrFun hd1_new t₁, congrFun hd1_orig t₁]
  change 2 * ((E t₁ * τ t₁ t₂ t₃) * (a ^ 2 * E t₁ * τ t₁ t₂ t₃ + 2 * a * E t₁ * d1 t₁ + E t₁ * d2) -
    (a * E t₁ * τ t₁ t₂ t₃ + E t₁ * d1 t₁) ^ 2) / (E t₁ * τ t₁ t₂ t₃) ^ 2 =
    2 * (τ t₁ t₂ t₃ * d2 - d1 t₁ ^ 2) / τ t₁ t₂ t₃ ^ 2
  have hEne : E t₁ ≠ 0 := Complex.exp_ne_zero _
  field_simp [hEne, hτ]
  ring

/-- **Theorem 4.2 (Globally Smooth KdV 2-Soliton in `Gr_≥0(2, 4)`):**
With symmetric wavenumbers `κ = (-k₂, -k₁, k₁, k₂)` (`0 < k₁ < k₂`) and positive phase
parameters `c₁, c₂ > 0`, the `Gr_≥0(2, 4)` frame `v = (1, 0, 0, -c₂)`, `w = (0, 1, c₁, 0)`
produces a globally nonvanishing `τ`-function on `ℝ³` whose KP-II potential `u` is
strictly independent of `y` (reducing KP-II to KdV). -/
theorem kdv2Soliton_y_invariant_and_smooth {k₁ k₂ c₁ c₂ : ℝ}
    (hk₁ : 0 < k₁) (hk12 : k₁ < k₂) (hc₁ : 0 < c₁) (hc₂ : 0 < c₂) :
    let κR : Fin 4 → ℝ := ![-k₂, -k₁, k₁, k₂]
    let vR : Fin 4 → ℝ := ![1, 0, 0, -c₂]
    let wR : Fin 4 → ℝ := ![0, 1, c₁, 0]
    let τ := solitonTau (fun i => (κR i : ℂ)) (fun i => (vR i : ℂ)) (fun i => (wR i : ℂ))
    (∀ x y t : ℝ, 0 < (τ x y t).re ∧ τ x y t ≠ 0) ∧
    (∀ x y t : ℂ, τ x y t = Complex.exp (((k₁ ^ 2 + k₂ ^ 2 : ℝ) : ℂ) * y) * τ x 0 t) := by
  intro κR vR wR τ
  refine ⟨fun x y t => ?_, fun x y t => ?_⟩
  · refine solitonTau_pos_of_totallyNonneg κR vR wR ?_ ?_ ?_ x y t
    · intro i j hlt
      fin_cases i <;> fin_cases j <;> simp at hlt ⊢ <;> dsimp [κR] <;> linarith
    · intro i j hlt
      fin_cases i <;> fin_cases j <;> simp at hlt ⊢ <;> dsimp [vR, wR] <;> nlinarith
    · exact ⟨0, 1, by decide, by simp [vR, wR]⟩
  · unfold τ solitonTau solitonTauGeneral expSum pluckerCoord
    simp only [Fin.sum_univ_six, pairIdx, κR, vR, wR, Matrix.cons_val_zero,
      Matrix.cons_val_one, Matrix.cons_val_two, Matrix.cons_val_three,
      Matrix.head_cons, Matrix.tail_cons]
    push_cast
    have hfac : ∀ (a b : ℂ),
        Complex.exp (a * x + (((k₁ ^ 2 + k₂ ^ 2 : ℝ) : ℂ) * y) + b * t) =
        Complex.exp (((k₁ ^ 2 + k₂ ^ 2 : ℝ) : ℂ) * y) * Complex.exp (a * x + 0 + b * t) := by
      intro a b; rw [← Complex.exp_add]; congr 1; ring
    have hsq1 : (-(k₂ : ℂ)) ^ 2 + (-(k₁ : ℂ)) ^ 2 = ((k₁ ^ 2 + k₂ ^ 2 : ℝ) : ℂ) := by push_cast; ring
    have hsq2 : (-(k₂ : ℂ)) ^ 2 + (k₁ : ℂ) ^ 2 = ((k₁ ^ 2 + k₂ ^ 2 : ℝ) : ℂ) := by push_cast; ring
    have hsq3 : (-(k₁ : ℂ)) ^ 2 + (k₂ : ℂ) ^ 2 = ((k₁ ^ 2 + k₂ ^ 2 : ℝ) : ℂ) := by push_cast; ring
    have hsq4 : (k₁ : ℂ) ^ 2 + (k₂ : ℂ) ^ 2 = ((k₁ ^ 2 + k₂ ^ 2 : ℝ) : ℂ) := by push_cast; ring
    simp only [hsq1, hsq2, hsq3, hsq4, mul_zero, zero_mul, sub_zero, zero_sub, sub_self,
      add_zero, hfac]
    ring

/-- The classic 1-soliton wave `u(x, t) = 2 k² / cosh²(k x + k³ t)` of the KdV equation. -/
noncomputable def kdvOneSoliton (k x t : ℝ) : ℝ :=
  2 * k ^ 2 / Real.cosh (k * x + k ^ 3 * t) ^ 2

/-- **Theorem 4.3 (Exact Nonlinear KdV 1-Soliton PDE):**
`u(x, t) = 2 k² sech²(k x + k³ t)` satisfies `4 u_t - u_{xxx} - 6 u u_x = 0`
for all `k, x, t ∈ ℝ`. -/
theorem kdv_oneSoliton_pde (k x t : ℝ) :
    4 * deriv (fun s => kdvOneSoliton k x s) t -
    iteratedDeriv 3 (fun r => kdvOneSoliton k r t) x -
    6 * kdvOneSoliton k x t * deriv (fun r => kdvOneSoliton k r t) x = 0 := by
  let θ : ℝ → ℝ → ℝ := fun r s => k * r + k ^ 3 * s
  have hCpos : ∀ r s : ℝ, Real.cosh (θ r s) ≠ 0 := fun r s => (Real.cosh_pos _).ne'
  have hCsq : ∀ r s : ℝ, Real.cosh (θ r s) ^ 2 - Real.sinh (θ r s) ^ 2 = 1 :=
    fun r s => Real.cosh_sq_sub_sinh_sq (θ r s)
  have hInvCosh : ∀ (n : ℕ) (r : ℝ),
      HasDerivAt (fun u => (Real.cosh (θ u t) ^ n)⁻¹)
        (-(n : ℝ) * k * Real.sinh (θ r t) / Real.cosh (θ r t) ^ (n + 1)) r := by
    intro n r
    have hθ : HasDerivAt (fun u => θ u t) k r := by
      have h := ((hasDerivAt_id r).const_mul k).add (hasDerivAt_const r (k ^ 3 * t))
      convert h using 1
      · funext u; simp only [θ, Pi.add_apply, id_eq]
      · ring
    have hc : HasDerivAt (fun u => Real.cosh (θ u t)) (Real.sinh (θ r t) * k) r :=
      (Real.hasDerivAt_cosh _).comp r hθ
    have hp : HasDerivAt (fun u => Real.cosh (θ u t) ^ n)
        ((n : ℝ) * Real.cosh (θ r t) ^ (n - 1) * (Real.sinh (θ r t) * k)) r := by
      convert hc.pow n using 1
    have hinv := hp.inv (pow_ne_zero n (hCpos r t))
    convert hinv using 1
    rcases n with _ | n
    · simp
    · have hne := hCpos r t
      simp only [Nat.add_sub_cancel]
      field_simp [hne]; ring
  have hut : HasDerivAt (fun s => kdvOneSoliton k x s)
      (-4 * k ^ 5 * Real.sinh (θ x t) / Real.cosh (θ x t) ^ 3) t := by
    have hθt : HasDerivAt (fun s => θ x s) (k ^ 3) t := by
      have h := (hasDerivAt_const t (k * x)).add ((hasDerivAt_id t).const_mul (k ^ 3))
      convert h using 1
      · funext s; simp only [θ, Pi.add_apply, id_eq]
      · ring
    have hct : HasDerivAt (fun s => Real.cosh (θ x s)) (Real.sinh (θ x t) * k ^ 3) t :=
      (Real.hasDerivAt_cosh _).comp t hθt
    have hpt : HasDerivAt (fun s => Real.cosh (θ x s) ^ 2)
        (2 * Real.cosh (θ x t) * (Real.sinh (θ x t) * k ^ 3)) t := by
      convert hct.pow 2 using 1
      norm_num
    have hdiv := (hasDerivAt_const t (2 * k ^ 2)).div hpt (pow_ne_zero 2 (hCpos x t))
    convert hdiv using 1
    · funext s; rfl
    · have hne := hCpos x t
      field_simp [hne]; ring
  have hux : ∀ r, HasDerivAt (fun u => kdvOneSoliton k u t)
      (-4 * k ^ 3 * Real.sinh (θ r t) / Real.cosh (θ r t) ^ 3) r := fun r => by
    have h := (hInvCosh 2 r).const_mul (2 * k ^ 2)
    have hfun : (fun u => 2 * k ^ 2 * (Real.cosh (θ u t) ^ 2)⁻¹) = fun u => kdvOneSoliton k u t := by
      ext u; unfold kdvOneSoliton; rw [div_eq_mul_inv]
    rw [hfun] at h
    convert h using 1; ring
  have huxx : ∀ r, HasDerivAt (fun u => -4 * k ^ 3 * Real.sinh (θ u t) / Real.cosh (θ u t) ^ 3)
      (4 * k ^ 4 * (2 * (Real.cosh (θ r t) ^ 2)⁻¹ - 3 * (Real.cosh (θ r t) ^ 4)⁻¹)) r := fun r => by
    have hθ : HasDerivAt (fun u => θ u t) k r := by
      have h := ((hasDerivAt_id r).const_mul k).add (hasDerivAt_const r (k ^ 3 * t))
      convert h using 1
      · funext u; simp only [θ, Pi.add_apply, id_eq]
      · ring
    have hs : HasDerivAt (fun u => Real.sinh (θ u t)) (Real.cosh (θ r t) * k) r :=
      (Real.hasDerivAt_sinh _).comp r hθ
    have hprod := (hs.const_mul (-4 * k ^ 3)).mul (hInvCosh 3 r)
    convert hprod using 1
    · funext u; simp only [Pi.mul_apply, div_eq_mul_inv]
    · have hne := hCpos r t
      have hsinh : Real.sinh (θ r t) ^ 2 = Real.cosh (θ r t) ^ 2 - 1 := by linarith [hCsq r t]
      field_simp [hne]
      ring_nf
      rw [hsinh]
      ring
  have huxxx : HasDerivAt
      (fun r => 4 * k ^ 4 * (2 * (Real.cosh (θ r t) ^ 2)⁻¹ - 3 * (Real.cosh (θ r t) ^ 4)⁻¹))
      (-16 * k ^ 5 * Real.sinh (θ x t) / Real.cosh (θ x t) ^ 3 +
       48 * k ^ 5 * Real.sinh (θ x t) / Real.cosh (θ x t) ^ 5) x := by
    have h := (((hInvCosh 2 x).const_mul 2).sub ((hInvCosh 4 x).const_mul 3)).const_mul (4 * k ^ 4)
    convert h using 1
    have hne := hCpos x t
    field_simp [hne]; ring
  have hd1 : deriv (fun r => kdvOneSoliton k r t) =
      fun r => -4 * k ^ 3 * Real.sinh (θ r t) / Real.cosh (θ r t) ^ 3 :=
    funext fun r => (hux r).deriv
  have hd2 : iteratedDeriv 2 (fun r => kdvOneSoliton k r t) =
      fun r => 4 * k ^ 4 * (2 * (Real.cosh (θ r t) ^ 2)⁻¹ - 3 * (Real.cosh (θ r t) ^ 4)⁻¹) := by
    ext r
    rw [iteratedDeriv_succ, iteratedDeriv_one, hd1]; exact (huxx r).deriv
  have hd3 : iteratedDeriv 3 (fun r => kdvOneSoliton k r t) x =
      -16 * k ^ 5 * Real.sinh (θ x t) / Real.cosh (θ x t) ^ 3 +
       48 * k ^ 5 * Real.sinh (θ x t) / Real.cosh (θ x t) ^ 5 := by
    rw [iteratedDeriv_succ, hd2]; exact huxxx.deriv
  rw [hut.deriv, hd3, congrFun hd1 x]
  unfold kdvOneSoliton
  have hne := hCpos x t
  dsimp [θ] at hne ⊢
  field_simp [hne]
  ring

end Signals.SatoGrassmannian.PDESolver
