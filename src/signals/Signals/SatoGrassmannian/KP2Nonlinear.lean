import Mathlib.Analysis.Calculus.Deriv.Basic
import Mathlib.Analysis.Calculus.Deriv.Inv
import Mathlib.Analysis.Calculus.Deriv.Mul
import Mathlib.Analysis.Calculus.Deriv.Pow
import Mathlib.Analysis.Calculus.IteratedDeriv.Lemmas
import Signals.SatoGrassmannian.Gr24Truncation
import Signals.SatoGrassmannian.HirotaKP

namespace Signals.SatoGrassmannian.KP2Nonlinear

open Signals.SatoGrassmannian.Gr24Truncation Signals.SatoGrassmannian.HirotaKP

/-- The KP potential `u = 2 ∂₁² log τ = 2 (τ τ₁₁ - τ₁²) / τ²` defined via Mathlib's
analytic `deriv` and `iteratedDeriv`. -/
noncomputable def kpU (τ : ℂ → ℂ → ℂ → ℂ) (t₁ t₂ t₃ : ℂ) : ℂ :=
  2 * (τ t₁ t₂ t₃ * iteratedDeriv 2 (fun x => τ x t₂ t₃) t₁ -
    deriv (fun x => τ x t₂ t₃) t₁ ^ 2) / τ t₁ t₂ t₃ ^ 2

/-- Quotient-power differentiation helper: `d/dx (P / τ^(k+1)) = (P' τ - (k+1) P τ') / τ^(k+2)`. -/
lemma hasDerivAt_div_pow_succ {P τ : ℂ → ℂ} {P' τ' x : ℂ} (k : ℕ)
    (hP : HasDerivAt P P' x) (hτ : HasDerivAt τ τ' x) (hτ0 : τ x ≠ 0) :
    HasDerivAt (fun y => P y / τ y ^ (k + 1))
      ((P' * τ x - ((k + 1 : ℕ) : ℂ) * P x * τ') / τ x ^ (k + 2)) x := by
  have hpow : HasDerivAt (fun y => τ y ^ (k + 1)) (((k + 1 : ℕ) : ℂ) * τ x ^ k * τ') x := by
    convert hτ.pow (k + 1) using 1
    simp
  have hdiv := hP.div hpow (pow_ne_zero (k + 1) hτ0)
  convert hdiv using 1
  have hk1 : τ x ^ (k + 1) ≠ 0 := pow_ne_zero (k + 1) hτ0
  have hk2 : τ x ^ (k + 2) ≠ 0 := pow_ne_zero (k + 2) hτ0
  field_simp [hτ0, hk1, hk2]
  ring

noncomputable section SchurPotential

variable (p01 p02 p03 p12 p13 p23 : ℂ)

private abbrev τS (t₁ t₂ t₃ : ℂ) : ℂ := schurTau p01 p02 p03 p12 p13 p23 t₁ t₂ t₃
private abbrev τ₁ (t₁ t₂ t₃ : ℂ) : ℂ := d1Tau p01 p02 p03 p12 p13 t₁ t₂ t₃
private abbrev τ₁₁ (t₁ : ℂ) : ℂ := d11Tau p01 p02 p03 p12 t₁
private abbrev τ₁₁₁ (t₁ : ℂ) : ℂ := d111Tau p01 p02 t₁
private abbrev τ₁₁₁₁ : ℂ := d1111Tau p01
private abbrev τ₂ (t₂ : ℂ) : ℂ := d2Tau p01 p03 p12 t₂
private abbrev τ₂₂ : ℂ := d22Tau p01
private abbrev τ₃ (t₁ : ℂ) : ℂ := d3Tau p01 p02 t₁
private abbrev τ₁₃ : ℂ := d13Tau p01

/-- Explicit rational expressions for `u`, `u₁`, `u₁₁`, `u₂`, `u₂₂`, `u₃`, and `w₁₃, w₂₂`. -/
def uF (t₁ t₂ t₃ : ℂ) : ℂ :=
  2 * (τS p01 p02 p03 p12 p13 p23 t₁ t₂ t₃ * τ₁₁ p01 p02 p03 p12 t₁ -
    τ₁ p01 p02 p03 p12 p13 t₁ t₂ t₃ ^ 2) / τS p01 p02 p03 p12 p13 p23 t₁ t₂ t₃ ^ 2

def u1F (t₁ t₂ t₃ : ℂ) : ℂ :=
  2 * (τS p01 p02 p03 p12 p13 p23 t₁ t₂ t₃ ^ 2 * τ₁₁₁ p01 p02 t₁ -
    3 * τS p01 p02 p03 p12 p13 p23 t₁ t₂ t₃ * τ₁ p01 p02 p03 p12 p13 t₁ t₂ t₃ * τ₁₁ p01 p02 p03 p12 t₁ +
    2 * τ₁ p01 p02 p03 p12 p13 t₁ t₂ t₃ ^ 3) / τS p01 p02 p03 p12 p13 p23 t₁ t₂ t₃ ^ 3

def u11F (t₁ t₂ t₃ : ℂ) : ℂ :=
  2 * (τS p01 p02 p03 p12 p13 p23 t₁ t₂ t₃ ^ 3 * τ₁₁₁₁ p01 -
    4 * τS p01 p02 p03 p12 p13 p23 t₁ t₂ t₃ ^ 2 * τ₁ p01 p02 p03 p12 p13 t₁ t₂ t₃ * τ₁₁₁ p01 p02 t₁ -
    3 * τS p01 p02 p03 p12 p13 p23 t₁ t₂ t₃ ^ 2 * τ₁₁ p01 p02 p03 p12 t₁ ^ 2 +
    12 * τS p01 p02 p03 p12 p13 p23 t₁ t₂ t₃ * τ₁ p01 p02 p03 p12 p13 t₁ t₂ t₃ ^ 2 * τ₁₁ p01 p02 p03 p12 t₁ -
    6 * τ₁ p01 p02 p03 p12 p13 t₁ t₂ t₃ ^ 4) / τS p01 p02 p03 p12 p13 p23 t₁ t₂ t₃ ^ 4

def u2F (t₁ t₂ t₃ : ℂ) : ℂ :=
  2 * (-τS p01 p02 p03 p12 p13 p23 t₁ t₂ t₃ * τ₁₁ p01 p02 p03 p12 t₁ * τ₂ p01 p03 p12 t₂ +
    2 * τ₁ p01 p02 p03 p12 p13 t₁ t₂ t₃ ^ 2 * τ₂ p01 p03 p12 t₂) /
    τS p01 p02 p03 p12 p13 p23 t₁ t₂ t₃ ^ 3

def u22F (t₁ t₂ t₃ : ℂ) : ℂ :=
  2 * (-τS p01 p02 p03 p12 p13 p23 t₁ t₂ t₃ ^ 2 * τ₁₁ p01 p02 p03 p12 t₁ * τ₂₂ p01 +
    2 * τS p01 p02 p03 p12 p13 p23 t₁ t₂ t₃ * τ₁ p01 p02 p03 p12 p13 t₁ t₂ t₃ ^ 2 * τ₂₂ p01 +
    2 * τS p01 p02 p03 p12 p13 p23 t₁ t₂ t₃ * τ₁₁ p01 p02 p03 p12 t₁ * τ₂ p01 p03 p12 t₂ ^ 2 -
    6 * τ₁ p01 p02 p03 p12 p13 t₁ t₂ t₃ ^ 2 * τ₂ p01 p03 p12 t₂ ^ 2) /
    τS p01 p02 p03 p12 p13 p23 t₁ t₂ t₃ ^ 4

def u3F (t₁ t₂ t₃ : ℂ) : ℂ :=
  2 * (-τS p01 p02 p03 p12 p13 p23 t₁ t₂ t₃ * τ₁₁ p01 p02 p03 p12 t₁ * τ₃ p01 p02 t₁ -
    2 * τS p01 p02 p03 p12 p13 p23 t₁ t₂ t₃ * τ₁ p01 p02 p03 p12 p13 t₁ t₂ t₃ * τ₁₃ p01 +
    2 * τ₁ p01 p02 p03 p12 p13 t₁ t₂ t₃ ^ 2 * τ₃ p01 p02 t₁) /
    τS p01 p02 p03 p12 p13 p23 t₁ t₂ t₃ ^ 3

def w13F (t₁ t₂ t₃ : ℂ) : ℂ :=
  (τS p01 p02 p03 p12 p13 p23 t₁ t₂ t₃ * τ₁₃ p01 -
    τ₁ p01 p02 p03 p12 p13 t₁ t₂ t₃ * τ₃ p01 p02 t₁) / τS p01 p02 p03 p12 p13 p23 t₁ t₂ t₃ ^ 2

def w22F (t₁ t₂ t₃ : ℂ) : ℂ :=
  (τS p01 p02 p03 p12 p13 p23 t₁ t₂ t₃ * τ₂₂ p01 - τ₂ p01 p03 p12 t₂ ^ 2) /
    τS p01 p02 p03 p12 p13 p23 t₁ t₂ t₃ ^ 2

def w22d1F (t₁ t₂ t₃ : ℂ) : ℂ :=
  (-τS p01 p02 p03 p12 p13 p23 t₁ t₂ t₃ * τ₁ p01 p02 p03 p12 p13 t₁ t₂ t₃ * τ₂₂ p01 +
    2 * τ₁ p01 p02 p03 p12 p13 t₁ t₂ t₃ * τ₂ p01 p03 p12 t₂ ^ 2) /
    τS p01 p02 p03 p12 p13 p23 t₁ t₂ t₃ ^ 3

lemma kpU_schurTau_eq_uF (t₁ t₂ t₃ : ℂ) :
    kpU (schurTau p01 p02 p03 p12 p13 p23) t₁ t₂ t₃ = uF p01 p02 p03 p12 p13 p23 t₁ t₂ t₃ := by
  have hd1 : (fun x => deriv (fun r => τS p01 p02 p03 p12 p13 p23 r t₂ t₃) x) =
      fun x => τ₁ p01 p02 p03 p12 p13 x t₂ t₃ := by
    ext x; exact (hasDerivAt_schurTau_t1 p01 p02 p03 p12 p13 p23 x t₂ t₃).deriv
  have hd2 : iteratedDeriv 2 (fun x => τS p01 p02 p03 p12 p13 p23 x t₂ t₃) t₁ =
      τ₁₁ p01 p02 p03 p12 t₁ := by
    rw [iteratedDeriv_succ, iteratedDeriv_one]
    have hd1' : deriv (fun x => τS p01 p02 p03 p12 p13 p23 x t₂ t₃) =
        fun x => τ₁ p01 p02 p03 p12 p13 x t₂ t₃ := hd1
    rw [hd1']
    exact (hasDerivAt_d1Tau p01 p02 p03 p12 p13 t₁ t₂ t₃).deriv
  unfold kpU uF
  rw [hd2, congrFun hd1 t₁]

lemma hasDerivAt_uF_t1 {t₁ t₂ t₃ : ℂ} (hτ : τS p01 p02 p03 p12 p13 p23 t₁ t₂ t₃ ≠ 0) :
    HasDerivAt (fun x => uF p01 p02 p03 p12 p13 p23 x t₂ t₃)
      (u1F p01 p02 p03 p12 p13 p23 t₁ t₂ t₃) t₁ := by
  have h0 := hasDerivAt_schurTau_t1 p01 p02 p03 p12 p13 p23 t₁ t₂ t₃
  have h1 := hasDerivAt_d1Tau p01 p02 p03 p12 p13 t₁ t₂ t₃
  have h2 := hasDerivAt_d11Tau p01 p02 p03 p12 t₁
  have hnum := (((h0.mul h2).sub (h1.pow 2)).const_mul (2 : ℂ))
  convert hasDerivAt_div_pow_succ 1 hnum h0 hτ using 1
  · funext x; unfold uF; simp only [Pi.sub_apply, Pi.mul_apply, Pi.pow_apply]
  · unfold u1F; simp only [Pi.sub_apply, Pi.mul_apply, Pi.pow_apply]; norm_num; ring

lemma hasDerivAt_u1F_t1 {t₁ t₂ t₃ : ℂ} (hτ : τS p01 p02 p03 p12 p13 p23 t₁ t₂ t₃ ≠ 0) :
    HasDerivAt (fun x => u1F p01 p02 p03 p12 p13 p23 x t₂ t₃)
      (u11F p01 p02 p03 p12 p13 p23 t₁ t₂ t₃) t₁ := by
  have h0 := hasDerivAt_schurTau_t1 p01 p02 p03 p12 p13 p23 t₁ t₂ t₃
  have h1 := hasDerivAt_d1Tau p01 p02 p03 p12 p13 t₁ t₂ t₃
  have h2 := hasDerivAt_d11Tau p01 p02 p03 p12 t₁
  have h3 := hasDerivAt_d111Tau p01 p02 t₁
  have hnum := ((((h0.pow 2).mul h3).sub (((h0.const_mul 3).mul h1).mul h2)).add
    ((h1.pow 3).const_mul 2)).const_mul 2
  convert hasDerivAt_div_pow_succ 2 hnum h0 hτ using 1
  · funext x; unfold u1F; simp only [Pi.add_apply, Pi.sub_apply, Pi.mul_apply, Pi.pow_apply]
  · unfold u11F; simp only [Pi.add_apply, Pi.sub_apply, Pi.mul_apply, Pi.pow_apply]; norm_num; ring

lemma differentiableAt_u11F_t1 {t₁ t₂ t₃ : ℂ} (hτ : τS p01 p02 p03 p12 p13 p23 t₁ t₂ t₃ ≠ 0) :
    DifferentiableAt ℂ (fun x => u11F p01 p02 p03 p12 p13 p23 x t₂ t₃) t₁ := by
  have h0 := (hasDerivAt_schurTau_t1 p01 p02 p03 p12 p13 p23 t₁ t₂ t₃).differentiableAt
  have h1 := (hasDerivAt_d1Tau p01 p02 p03 p12 p13 t₁ t₂ t₃).differentiableAt
  have h2 := (hasDerivAt_d11Tau p01 p02 p03 p12 t₁).differentiableAt
  have h3 := (hasDerivAt_d111Tau p01 p02 t₁).differentiableAt
  unfold u11F
  refine DifferentiableAt.div ?_ (h0.pow 4) (pow_ne_zero 4 hτ)
  exact (((((h0.pow 3).mul_const _).sub (((h0.pow 2).const_mul 4 |>.mul h1).mul h3)).sub
    (((h0.pow 2).const_mul 3).mul (h2.pow 2))).add
    (((h0.const_mul 12).mul (h1.pow 2)).mul h2)).sub ((h1.pow 4).const_mul 6) |>.const_mul 2

lemma hasDerivAt_uF_t2 {t₁ t₂ t₃ : ℂ} (hτ : τS p01 p02 p03 p12 p13 p23 t₁ t₂ t₃ ≠ 0) :
    HasDerivAt (fun y => uF p01 p02 p03 p12 p13 p23 t₁ y t₃)
      (u2F p01 p02 p03 p12 p13 p23 t₁ t₂ t₃) t₂ := by
  have h0 := hasDerivAt_schurTau_t2 p01 p02 p03 p12 p13 p23 t₁ t₂ t₃
  have hnum := (((h0.mul_const (τ₁₁ p01 p02 p03 p12 t₁)).sub
    (hasDerivAt_const t₂ (τ₁ p01 p02 p03 p12 p13 t₁ t₂ t₃ ^ 2))).const_mul (2 : ℂ))
  convert hasDerivAt_div_pow_succ 1 hnum h0 hτ using 1
  · funext y; unfold uF; simp only [Pi.sub_apply, d1Tau]
  · unfold u2F; simp only [Pi.sub_apply]; norm_num; ring

lemma hasDerivAt_u2F_t2 {t₁ t₂ t₃ : ℂ} (hτ : τS p01 p02 p03 p12 p13 p23 t₁ t₂ t₃ ≠ 0) :
    HasDerivAt (fun y => u2F p01 p02 p03 p12 p13 p23 t₁ y t₃)
      (u22F p01 p02 p03 p12 p13 p23 t₁ t₂ t₃) t₂ := by
  have h0 := hasDerivAt_schurTau_t2 p01 p02 p03 p12 p13 p23 t₁ t₂ t₃
  have h2 := hasDerivAt_d2Tau p01 p03 p12 t₂
  have hnum := (((h0.neg.mul_const (τ₁₁ p01 p02 p03 p12 t₁)).mul h2).add
    (h2.const_mul (2 * τ₁ p01 p02 p03 p12 p13 t₁ t₂ t₃ ^ 2))).const_mul (2 : ℂ)
  convert hasDerivAt_div_pow_succ 2 hnum h0 hτ using 1
  · funext y; unfold u2F; simp only [Pi.add_apply, Pi.mul_apply, Pi.neg_apply, d1Tau]
  · unfold u22F; simp only [Pi.add_apply, Pi.mul_apply, Pi.neg_apply]; norm_num; ring

lemma hasDerivAt_uF_t3 {t₁ t₂ t₃ : ℂ} (hτ : τS p01 p02 p03 p12 p13 p23 t₁ t₂ t₃ ≠ 0) :
    HasDerivAt (fun z => uF p01 p02 p03 p12 p13 p23 t₁ t₂ z)
      (u3F p01 p02 p03 p12 p13 p23 t₁ t₂ t₃) t₃ := by
  have h0 := hasDerivAt_schurTau_t3 p01 p02 p03 p12 p13 p23 t₁ t₂ t₃
  have hd1_t3 : HasDerivAt (fun z => τ₁ p01 p02 p03 p12 p13 t₁ t₂ z) (τ₁₃ p01) t₃ := by
    change HasDerivAt (fun z => d1Tau p01 p02 p03 p12 p13 t₁ t₂ z) (d13Tau p01) t₃
    unfold d1Tau d13Tau
    have h := (hasDerivAt_const t₃ (p13 + p03 * t₁ + p12 * t₁ + p02 * t₁ ^ 2)).add
      (((hasDerivAt_const t₃ ((1 / 3 : ℂ) * t₁ ^ 3)).sub (hasDerivAt_id t₃)).const_mul p01)
    convert h using 1
    · funext z; simp only [Pi.add_apply, Pi.sub_apply, id_eq]
    · ring
  have hnum := (((h0.mul_const (τ₁₁ p01 p02 p03 p12 t₁)).sub (hd1_t3.pow 2)).const_mul (2 : ℂ))
  convert hasDerivAt_div_pow_succ 1 hnum h0 hτ using 1
  · funext z; unfold uF; simp only [Pi.sub_apply, Pi.pow_apply]
  · unfold u3F; simp only [Pi.sub_apply, Pi.pow_apply]; norm_num; ring

lemma hasDerivAt_w13F_t1 {t₁ t₂ t₃ : ℂ} (hτ : τS p01 p02 p03 p12 p13 p23 t₁ t₂ t₃ ≠ 0) :
    HasDerivAt (fun x => w13F p01 p02 p03 p12 p13 p23 x t₂ t₃)
      ((1 / 2 : ℂ) * u3F p01 p02 p03 p12 p13 p23 t₁ t₂ t₃) t₁ := by
  have h0 := hasDerivAt_schurTau_t1 p01 p02 p03 p12 p13 p23 t₁ t₂ t₃
  have h1 := hasDerivAt_d1Tau p01 p02 p03 p12 p13 t₁ t₂ t₃
  have h3 := hasDerivAt_d3Tau p01 p02 t₁
  have hnum := (h0.mul_const (τ₁₃ p01)).sub (h1.mul h3)
  convert hasDerivAt_div_pow_succ 1 hnum h0 hτ using 1
  · funext x; unfold w13F; simp only [Pi.sub_apply, Pi.mul_apply]
  · unfold u3F; simp only [Pi.sub_apply, Pi.mul_apply]; norm_num; ring

lemma hasDerivAt_w22F_t1 {t₁ t₂ t₃ : ℂ} (hτ : τS p01 p02 p03 p12 p13 p23 t₁ t₂ t₃ ≠ 0) :
    HasDerivAt (fun x => w22F p01 p02 p03 p12 p13 p23 x t₂ t₃)
      (w22d1F p01 p02 p03 p12 p13 p23 t₁ t₂ t₃) t₁ := by
  have h0 := hasDerivAt_schurTau_t1 p01 p02 p03 p12 p13 p23 t₁ t₂ t₃
  have hnum := (h0.mul_const (τ₂₂ p01)).sub (hasDerivAt_const t₁ (τ₂ p01 p03 p12 t₂ ^ 2))
  convert hasDerivAt_div_pow_succ 1 hnum h0 hτ using 1
  · funext x; unfold w22F; simp only [Pi.sub_apply]
  · unfold w22d1F; simp only [Pi.sub_apply]; norm_num; ring

lemma hasDerivAt_w22d1F_t1 {t₁ t₂ t₃ : ℂ} (hτ : τS p01 p02 p03 p12 p13 p23 t₁ t₂ t₃ ≠ 0) :
    HasDerivAt (fun x => w22d1F p01 p02 p03 p12 p13 p23 x t₂ t₃)
      ((1 / 2 : ℂ) * u22F p01 p02 p03 p12 p13 p23 t₁ t₂ t₃) t₁ := by
  have h0 := hasDerivAt_schurTau_t1 p01 p02 p03 p12 p13 p23 t₁ t₂ t₃
  have h1 := hasDerivAt_d1Tau p01 p02 p03 p12 p13 t₁ t₂ t₃
  have hnum := (((h0.neg.mul h1).mul_const (τ₂₂ p01)).add
    ((h1.const_mul 2).mul_const (τ₂ p01 p03 p12 t₂ ^ 2)))
  convert hasDerivAt_div_pow_succ 2 hnum h0 hτ using 1
  · funext x; unfold w22d1F; simp only [Pi.add_apply, Pi.mul_apply, Pi.neg_apply]
  · unfold u22F; simp only [Pi.add_apply, Pi.mul_apply, Pi.neg_apply]; norm_num; ring

/-- **Theorem 2.1 (Exact Hirota–Potential Bridge Identity):**
`u₁₁ + 3 u² - 8 w₁₃ + 6 w₂₂ = hirotaKP(τ) / τ²` everywhere `τ ≠ 0`. -/
theorem kp_potential_hirota_bridge {t₁ t₂ t₃ : ℂ}
    (hτ : τS p01 p02 p03 p12 p13 p23 t₁ t₂ t₃ ≠ 0) :
    u11F p01 p02 p03 p12 p13 p23 t₁ t₂ t₃ +
      3 * uF p01 p02 p03 p12 p13 p23 t₁ t₂ t₃ ^ 2 -
      8 * w13F p01 p02 p03 p12 p13 p23 t₁ t₂ t₃ +
      6 * w22F p01 p02 p03 p12 p13 p23 t₁ t₂ t₃ =
    hirotaKP (schurTau p01 p02 p03 p12 p13 p23) t₁ t₂ t₃ /
      τS p01 p02 p03 p12 p13 p23 t₁ t₂ t₃ ^ 2 := by
  rw [hirotaKP_schurTau_eq]
  unfold u11F uF w13F w22F
  have h2 : τS p01 p02 p03 p12 p13 p23 t₁ t₂ t₃ ^ 2 ≠ 0 := pow_ne_zero 2 hτ
  have h4 : τS p01 p02 p03 p12 p13 p23 t₁ t₂ t₃ ^ 4 ≠ 0 := pow_ne_zero 4 hτ
  field_simp [hτ, h2, h4]
  dsimp only [τS, τ₁, τ₁₁, τ₁₁₁, τ₁₁₁₁, τ₂, τ₂₂, τ₃, τ₁₃]
  unfold schurTau schurEmpty schur1 schur2 schur11 schur21 schur22
    d1Tau d11Tau d111Tau d1111Tau d2Tau d22Tau d3Tau d13Tau
  ring

end SchurPotential

/-- **Theorem 2.2 (Nonlinear KP-II PDE on the Big Cell):**
On the non-vanishing locus `τ_U(t₁, t₂, t₃) ≠ 0`, `u = 2 ∂₁² log τ_U` satisfies the
nonlinear KP-II PDE `∂₁(4 u₃ - u₁₁₁ - 6 u u₁) = 3 u₂₂` directly from `hirotaKP_tauU_eq_zero`. -/
theorem kpII_tauU_eq_zero (v w : C4) {t₁ t₂ t₃ : ℂ} (hτ : tauU v w t₁ t₂ t₃ ≠ 0) :
    let u := kpU (tauU v w)
    deriv (fun x =>
      4 * deriv (fun z => u x t₂ z) t₃ -
      iteratedDeriv 3 (fun r => u r t₂ t₃) x -
      6 * u x t₂ t₃ * deriv (fun r => u r t₂ t₃) x) t₁ =
    3 * iteratedDeriv 2 (fun y => u t₁ y t₃) t₂ := by
  intro u
  set p01 := pluckerCoord v w 0 1
  set p02 := pluckerCoord v w 0 2
  set p03 := pluckerCoord v w 0 3
  set p12 := pluckerCoord v w 1 2
  set p13 := pluckerCoord v w 1 3
  set p23 := pluckerCoord v w 2 3
  have hτ_fun : tauU v w = schurTau p01 p02 p03 p12 p13 p23 := by
    funext x y z; exact tauU_eq_schurTau v w x y z
  have hu_eq : u = uF p01 p02 p03 p12 p13 p23 := by
    funext x y z; dsimp [u]; rw [hτ_fun]; exact kpU_schurTau_eq_uF _ _ _ _ _ _ x y z
  have hτ' : τS p01 p02 p03 p12 p13 p23 t₁ t₂ t₃ ≠ 0 := by
    change schurTau p01 p02 p03 p12 p13 p23 t₁ t₂ t₃ ≠ 0
    rwa [← hτ_fun]
  let U₁ : Set ℂ := { x : ℂ | τS p01 p02 p03 p12 p13 p23 x t₂ t₃ ≠ 0 }
  have hU₁_open : IsOpen U₁ :=
    isOpen_ne.preimage (continuous_iff_continuousAt.mpr fun x =>
      (hasDerivAt_schurTau_t1 p01 p02 p03 p12 p13 p23 x t₂ t₃).continuousAt)
  have hU₁_nhds : U₁ ∈ nhds t₁ := hU₁_open.mem_nhds hτ'
  let U₂ : Set ℂ := { y : ℂ | τS p01 p02 p03 p12 p13 p23 t₁ y t₃ ≠ 0 }
  have hU₂_open : IsOpen U₂ :=
    isOpen_ne.preimage (continuous_iff_continuousAt.mpr fun y =>
      (hasDerivAt_schurTau_t2 p01 p02 p03 p12 p13 p23 t₁ y t₃).continuousAt)
  have hu22_eq : iteratedDeriv 2 (fun y => u t₁ y t₃) t₂ = u22F p01 p02 p03 p12 p13 p23 t₁ t₂ t₃ := by
    rw [hu_eq]
    have hd1 : deriv (fun y => uF p01 p02 p03 p12 p13 p23 t₁ y t₃) =ᶠ[nhds t₂]
        fun y => u2F p01 p02 p03 p12 p13 p23 t₁ y t₃ := by
      filter_upwards [hU₂_open.mem_nhds hτ'] with y hy
      exact (hasDerivAt_uF_t2 p01 p02 p03 p12 p13 p23 hy).deriv
    rw [iteratedDeriv_succ, iteratedDeriv_one, hd1.deriv_eq]
    exact (hasDerivAt_u2F_t2 p01 p02 p03 p12 p13 p23 hτ').deriv
  have hFirstDeriv : ∀ x ∈ U₁,
      4 * deriv (fun z => u x t₂ z) t₃ -
      iteratedDeriv 3 (fun r => u r t₂ t₃) x -
      6 * u x t₂ t₃ * deriv (fun r => u r t₂ t₃) x =
      6 * w22d1F p01 p02 p03 p12 p13 p23 x t₂ t₃ := by
    intro x hx
    rw [hu_eq]
    have hx_nhds : U₁ ∈ nhds x := hU₁_open.mem_nhds hx
    have hdu2 : iteratedDeriv 2 (fun r => uF p01 p02 p03 p12 p13 p23 r t₂ t₃) =ᶠ[nhds x]
        fun r => u11F p01 p02 p03 p12 p13 p23 r t₂ t₃ := by
      filter_upwards [hx_nhds] with r hr
      have hr_nhds : U₁ ∈ nhds r := hU₁_open.mem_nhds hr
      have hloc : deriv (fun s => uF p01 p02 p03 p12 p13 p23 s t₂ t₃) =ᶠ[nhds r]
          fun s => u1F p01 p02 p03 p12 p13 p23 s t₂ t₃ := by
        filter_upwards [hr_nhds] with s hs
        exact (hasDerivAt_uF_t1 p01 p02 p03 p12 p13 p23 hs).deriv
      rw [iteratedDeriv_succ, iteratedDeriv_one, hloc.deriv_eq]
      exact (hasDerivAt_u1F_t1 p01 p02 p03 p12 p13 p23 hr).deriv
    have hu3 : deriv (fun z => uF p01 p02 p03 p12 p13 p23 x t₂ z) t₃ =
        u3F p01 p02 p03 p12 p13 p23 x t₂ t₃ :=
      (hasDerivAt_uF_t3 p01 p02 p03 p12 p13 p23 hx).deriv
    have hu1 : deriv (fun r => uF p01 p02 p03 p12 p13 p23 r t₂ t₃) x =
        u1F p01 p02 p03 p12 p13 p23 x t₂ t₃ :=
      (hasDerivAt_uF_t1 p01 p02 p03 p12 p13 p23 hx).deriv
    have hu3_iter : iteratedDeriv 3 (fun r => uF p01 p02 p03 p12 p13 p23 r t₂ t₃) x =
        deriv (fun r => u11F p01 p02 p03 p12 p13 p23 r t₂ t₃) x := by
      rw [iteratedDeriv_succ]
      exact hdu2.deriv_eq
    let F : ℂ → ℂ := fun r =>
      u11F p01 p02 p03 p12 p13 p23 r t₂ t₃ +
      3 * uF p01 p02 p03 p12 p13 p23 r t₂ t₃ ^ 2 -
      8 * w13F p01 p02 p03 p12 p13 p23 r t₂ t₃ +
      6 * w22F p01 p02 p03 p12 p13 p23 r t₂ t₃
    have hF_zero : F =ᶠ[nhds x] fun _ => (0 : ℂ) := by
      filter_upwards [hx_nhds] with r hr
      dsimp [F]
      rw [kp_potential_hirota_bridge p01 p02 p03 p12 p13 p23 hr, ← hτ_fun,
        hirotaKP_tauU_eq_zero v w r t₂ t₃, zero_div]
    have hF_deriv0 : HasDerivAt F 0 x :=
      (hasDerivAt_const x (0 : ℂ)).congr_of_eventuallyEq hF_zero
    have hF_deriv : HasDerivAt F
        (deriv (fun r => u11F p01 p02 p03 p12 p13 p23 r t₂ t₃) x +
         6 * uF p01 p02 p03 p12 p13 p23 x t₂ t₃ * u1F p01 p02 p03 p12 p13 p23 x t₂ t₃ -
         4 * u3F p01 p02 p03 p12 p13 p23 x t₂ t₃ +
         6 * w22d1F p01 p02 p03 p12 p13 p23 x t₂ t₃) x := by
      have ha := (differentiableAt_u11F_t1 p01 p02 p03 p12 p13 p23 hx).hasDerivAt
      have hb := ((hasDerivAt_uF_t1 p01 p02 p03 p12 p13 p23 hx).pow 2).const_mul (3 : ℂ)
      have hc := (hasDerivAt_w13F_t1 p01 p02 p03 p12 p13 p23 hx).const_mul (8 : ℂ)
      have hd := (hasDerivAt_w22F_t1 p01 p02 p03 p12 p13 p23 hx).const_mul (6 : ℂ)
      convert ((ha.add hb).sub hc).add hd using 1
      ring
    have hEq0 := hF_deriv.unique hF_deriv0
    rw [hu3, hu1, hu3_iter]
    linear_combination -hEq0
  have hEv : (fun x =>
      4 * deriv (fun z => u x t₂ z) t₃ -
      iteratedDeriv 3 (fun r => u r t₂ t₃) x -
      6 * u x t₂ t₃ * deriv (fun r => u r t₂ t₃) x) =ᶠ[nhds t₁]
      fun x => 6 * w22d1F p01 p02 p03 p12 p13 p23 x t₂ t₃ := by
    filter_upwards [hU₁_nhds] with x hx
    exact hFirstDeriv x hx
  rw [hEv.deriv_eq, hu22_eq]
  have hfinal := (hasDerivAt_w22d1F_t1 p01 p02 p03 p12 p13 p23 hτ').const_mul (6 : ℂ)
  convert hfinal.deriv using 1
  ring

end Signals.SatoGrassmannian.KP2Nonlinear
