import Mathlib.Analysis.SpecialFunctions.Gaussian.FourierTransform
import Mathlib.Analysis.SpecialFunctions.Gaussian.GaussianIntegral
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Bounds
import Mathlib.LinearAlgebra.Lagrange
import Mathlib.MeasureTheory.Group.Integral
import Signals.SatoGrassmannian.WeilPositivity

/-!
# Upgraded Weil Positivity Criterion on Genuine `L¹(ℝ)` Shifted-Gaussian Test Functions

Ported from `data/chats/Gemini_Formalizing-Sato-Grassmannian-in-Lean_20261120-2337.md`
(block 017). Upgrades `weilPositivity_iff_allRealZeros` from polynomial test functions
to genuine `L¹(ℝ)` shifted-Gaussian linear combinations `f_{δ, P} = ∑ P_j g_{jδ}` with
exact Mellin–Fourier transform `(2π)^(1/2) exp(-z²/2) P(exp(i δ z))` and explicit
`-4π m(z₀) < 0` negativity witness for any off-line zero `z₀`.
-/

open scoped BigOperators
open MeasureTheory

namespace Signals.SatoGrassmannian.WeilGaussianL1

open Signals.SatoGrassmannian.WeilPositivity

/-- Shifted Gaussian test atom `g_a(x) = exp(-(x - a)² / 2)` on `ℝ`. -/
noncomputable def shiftedGaussian (a : ℝ) (x : ℝ) : ℂ :=
  Complex.exp (-(1 / 2 : ℂ) * ((x : ℂ) - (a : ℂ)) ^ 2)

/-- **Lemma 3.1 (Exponentially-Weighted Integrability):**
For every `a ∈ ℝ` and `z ∈ ℂ`, `x ↦ g_a(x) * exp(i z x)` belongs to `L¹(ℝ)`. -/
theorem integrable_shiftedGaussian_mul_cexp (a : ℝ) (z : ℂ) :
    Integrable (fun x : ℝ => shiftedGaussian a x * Complex.exp (Complex.I * z * (x : ℂ))) volume := by
  let c : ℝ := Real.exp (z.im ^ 2 / 2 - z.im * a)
  let maj : ℝ → ℝ := fun x => c * Real.exp (-(1 / 2 : ℝ) * (x - (a - z.im)) ^ 2)
  have hMaj : Integrable maj volume :=
    ((integrable_exp_neg_mul_sq (by norm_num : (0 : ℝ) < 1 / 2)).comp_sub_right (a - z.im)).const_mul c
  refine hMaj.mono' ?_ (Filter.Eventually.of_forall fun x => ?_)
  · refine Continuous.aestronglyMeasurable ?_
    unfold shiftedGaussian
    exact (Complex.continuous_exp.comp
      (continuous_const.mul ((Complex.continuous_ofReal.sub continuous_const).pow 2))).mul
      (Complex.continuous_exp.comp (continuous_const.mul Complex.continuous_ofReal))
  · unfold shiftedGaussian
    rw [norm_mul, Complex.norm_exp, Complex.norm_exp]
    have hre1 : (-(1 / 2 : ℂ) * ((x : ℂ) - (a : ℂ)) ^ 2).re = -(1 / 2 : ℝ) * (x - a) ^ 2 := by
      have : -(1 / 2 : ℂ) * ((x : ℂ) - (a : ℂ)) ^ 2 = ((-(1 / 2 : ℝ) * (x - a) ^ 2 : ℝ) : ℂ) := by
        push_cast; ring
      rw [this, Complex.ofReal_re]
    have hre2 : (Complex.I * z * (x : ℂ)).re = -z.im * x := by
      simp [Complex.mul_re]
    rw [hre1, hre2, ← Real.exp_add]
    dsimp [maj, c]
    rw [← Real.exp_add]
    exact le_of_eq (congrArg Real.exp (by ring))

/-- **Theorem 3.1 (Exact Mellin–Fourier Transform of a Shifted Gaussian):**
`M_{g_a}(z) = (2π)^(1/2) * exp(-z² / 2) * exp(i a z)`. -/
theorem mellinTransform_shiftedGaussian (a : ℝ) (z : ℂ) :
    mellinTransform (shiftedGaussian a) z =
      ((Real.pi / (1 / 2 : ℂ)) ^ (1 / 2 : ℂ)) *
        Complex.exp (-z ^ 2 / 2) * Complex.exp (Complex.I * z * (a : ℂ)) := by
  unfold mellinTransform shiftedGaussian
  have hshift := MeasureTheory.integral_add_right_eq_self (μ := volume)
    (fun u : ℝ => Complex.exp (-(1 / 2 : ℂ) * ((u : ℂ) - (a : ℂ)) ^ 2) *
      Complex.exp (Complex.I * z * (u : ℂ))) a
  rw [← hshift]
  have hfactor : (fun u : ℝ =>
      Complex.exp (-(1 / 2 : ℂ) * (((u + a : ℝ) : ℂ) - (a : ℂ)) ^ 2) *
        Complex.exp (Complex.I * z * ((u + a : ℝ) : ℂ))) =
      fun u : ℝ => (Complex.exp (Complex.I * z * (u : ℂ)) *
        Complex.exp (-(1 / 2 : ℂ) * (u : ℂ) ^ 2)) *
        Complex.exp (Complex.I * z * (a : ℂ)) := by
    ext u
    have h1 : ((u + a : ℝ) : ℂ) - (a : ℂ) = (u : ℂ) := by push_cast; ring
    have h2 : Complex.I * z * ((u + a : ℝ) : ℂ) = Complex.I * z * (u : ℂ) + Complex.I * z * (a : ℂ) := by
      push_cast; ring
    rw [h1, h2, Complex.exp_add]; ring
  rw [hfactor, MeasureTheory.integral_mul_const]
  have hG := fourierIntegral_gaussian (b := (1 / 2 : ℂ)) (by norm_num) z
  rw [hG, show (4 : ℂ) * (1 / 2 : ℂ) = 2 by norm_num]

/-- Finite shifted-Gaussian test function `f_{δ, P}(x) = ∑_{j ≤ deg P} P_j · g_{jδ}(x)`. -/
noncomputable def gaussianCombo (δ : ℝ) (P : Polynomial ℂ) (x : ℝ) : ℂ :=
  ∑ j ∈ Finset.range (P.natDegree + 1), P.coeff j * shiftedGaussian ((j : ℝ) * δ) x

theorem integrable_gaussianCombo_mul_cexp (δ : ℝ) (P : Polynomial ℂ) (z : ℂ) :
    Integrable (fun x : ℝ => gaussianCombo δ P x * Complex.exp (Complex.I * z * (x : ℂ))) volume := by
  have heq : (fun x : ℝ => gaussianCombo δ P x * Complex.exp (Complex.I * z * (x : ℂ))) =
      fun x : ℝ => ∑ j ∈ Finset.range (P.natDegree + 1),
        P.coeff j * (shiftedGaussian ((j : ℝ) * δ) x * Complex.exp (Complex.I * z * (x : ℂ))) := by
    ext x; unfold gaussianCombo; rw [Finset.sum_mul]
    exact Finset.sum_congr rfl fun j _ => mul_assoc _ _ _
  rw [heq]
  exact integrable_finsetSum (Finset.range (P.natDegree + 1)) fun j _ =>
    (integrable_shiftedGaussian_mul_cexp ((j : ℝ) * δ) z).const_mul (P.coeff j)

/-- Exact Mellin–Fourier transform of `gaussianCombo δ P`:
`M_{f_{δ, P}}(z) = (2π)^(1/2) * exp(-z²/2) * P(exp(i δ z))`. -/
theorem mellinTransform_gaussianCombo (δ : ℝ) (P : Polynomial ℂ) (z : ℂ) :
    mellinTransform (gaussianCombo δ P) z =
      ((Real.pi / (1 / 2 : ℂ)) ^ (1 / 2 : ℂ)) * Complex.exp (-z ^ 2 / 2) *
        P.eval (Complex.exp (Complex.I * z * (δ : ℂ))) := by
  unfold mellinTransform gaussianCombo
  have hpull : (fun x : ℝ =>
      (∑ j ∈ Finset.range (P.natDegree + 1), P.coeff j * shiftedGaussian ((j : ℝ) * δ) x) *
        Complex.exp (Complex.I * z * (x : ℂ))) =
      fun x : ℝ => ∑ j ∈ Finset.range (P.natDegree + 1),
        P.coeff j * (shiftedGaussian ((j : ℝ) * δ) x * Complex.exp (Complex.I * z * (x : ℂ))) := by
    ext x; rw [Finset.sum_mul]; exact Finset.sum_congr rfl fun j _ => mul_assoc _ _ _
  rw [hpull, MeasureTheory.integral_finsetSum (Finset.range (P.natDegree + 1)) fun j _ =>
    (integrable_shiftedGaussian_mul_cexp ((j : ℝ) * δ) z).const_mul (P.coeff j)]
  have hterm : ∀ j ∈ Finset.range (P.natDegree + 1),
      (∫ x : ℝ, P.coeff j * (shiftedGaussian ((j : ℝ) * δ) x * Complex.exp (Complex.I * z * (x : ℂ)))) =
      ((Real.pi / (1 / 2 : ℂ)) ^ (1 / 2 : ℂ)) * Complex.exp (-z ^ 2 / 2) *
        (P.coeff j * (Complex.exp (Complex.I * z * (δ : ℂ))) ^ j) := by
    intro j _
    rw [MeasureTheory.integral_const_mul]
    change P.coeff j * mellinTransform (shiftedGaussian ((j : ℝ) * δ)) z = _
    rw [mellinTransform_shiftedGaussian ((j : ℝ) * δ) z, ← Complex.exp_nat_mul]
    have hexp : Complex.I * z * (((j : ℝ) * δ : ℝ) : ℂ) = (j : ℂ) * (Complex.I * z * (δ : ℂ)) := by
      push_cast; ring
    rw [hexp]; ring
  rw [Finset.sum_congr rfl hterm, ← Finset.mul_sum, Polynomial.eval_eq_sum_range]

/-- **Lemma 3.2 (Frequency Separation on Finite Zero Sets):**
For any finite set `Z ⊂ ℂ`, there exists `δ > 0` such that `z ↦ exp(i δ z)` is injective on `Z`. -/
lemma exists_delta_exp_injOn (Z : Finset ℂ) :
    ∃ δ : ℝ, 0 < δ ∧ Set.InjOn (fun z : ℂ => Complex.exp (Complex.I * z * (δ : ℂ))) (Z : Set ℂ) := by
  let R : ℝ := ∑ z ∈ Z, ‖z‖
  have hR_nn : 0 ≤ R := Finset.sum_nonneg fun _ _ => norm_nonneg _
  let δ : ℝ := 1 / (R + 1)
  have hδ_pos : 0 < δ := by positivity
  refine ⟨δ, hδ_pos, fun z₁ hz₁ z₂ hz₂ hEq => ?_⟩
  dsimp only at hEq
  have hz₁_le : ‖z₁‖ ≤ R := Finset.single_le_sum (f := fun z : ℂ => ‖z‖) (fun _ _ => norm_nonneg _) hz₁
  have hz₂_le : ‖z₂‖ ≤ R := Finset.single_le_sum (f := fun z : ℂ => ‖z‖) (fun _ _ => norm_nonneg _) hz₂
  have hdiff_lt : ‖Complex.I * z₁ * (δ : ℂ) - Complex.I * z₂ * (δ : ℂ)‖ < 2 * Real.pi := by
    have hfac : Complex.I * z₁ * (δ : ℂ) - Complex.I * z₂ * (δ : ℂ) =
        Complex.I * (δ : ℂ) * (z₁ - z₂) := by ring
    rw [hfac, norm_mul, norm_mul, Complex.norm_I, one_mul, Complex.norm_real,
      Real.norm_eq_abs, abs_of_pos hδ_pos]
    have htri : ‖z₁ - z₂‖ ≤ 2 * R := by
      calc ‖z₁ - z₂‖ ≤ ‖z₁‖ + ‖z₂‖ := norm_sub_le z₁ z₂
        _ ≤ R + R := add_le_add hz₁_le hz₂_le
        _ = 2 * R := by ring
    have hlt2 : δ * ‖z₁ - z₂‖ < 2 := by
      calc δ * ‖z₁ - z₂‖ ≤ (1 / (R + 1)) * (2 * R) :=
            mul_le_mul_of_nonneg_left htri hδ_pos.le
        _ < 2 := by
            rw [div_mul_eq_mul_div, div_lt_iff₀ (by linarith : 0 < R + 1)]
            linarith
    linarith [Real.two_le_pi]
  have hdiv : Complex.exp (Complex.I * z₁ * (δ : ℂ) - Complex.I * z₂ * (δ : ℂ)) = 1 := by
    rw [Complex.exp_sub, hEq, div_self (Complex.exp_ne_zero _)]
  obtain ⟨k, hk⟩ := Complex.exp_eq_one_iff.mp hdiv
  have hk0 : k = 0 := by
    by_contra hne
    have hge1 : (1 : ℝ) ≤ |(k : ℝ)| := by exact_mod_cast Int.one_le_abs hne
    rw [hk, norm_mul, norm_mul, Complex.norm_intCast, norm_mul, Complex.norm_ofNat,
      Complex.norm_real, Real.norm_eq_abs, abs_of_pos Real.pi_pos, Complex.norm_I, mul_one] at hdiff_lt
    nlinarith [Real.pi_pos]
  rw [hk0, Int.cast_zero, zero_mul] at hk
  have hsub0 : Complex.I * (δ : ℂ) * (z₁ - z₂) = 0 := by linear_combination hk
  have hId_ne : Complex.I * (δ : ℂ) ≠ 0 :=
    mul_ne_zero Complex.I_ne_zero (by exact_mod_cast hδ_pos.ne')
  exact sub_eq_zero.mp ((mul_eq_zero.mp hsub0).resolve_left hId_ne)

/-- Admissible `L¹(ℝ)` test function class: functions `f : ℝ → ℂ` for which `x ↦ f(x) exp(i z x)`
is integrable at every spectral point `z ∈ Z`. -/
def AdmissibleL1 (Z : Finset ℂ) (f : ℝ → ℂ) : Prop :=
  ∀ z ∈ Z, Integrable (fun x : ℝ => f x * Complex.exp (Complex.I * z * (x : ℂ))) volume

/-- Globally admissible `L¹(ℝ)` test function class: `x ↦ f(x) exp(i z x)` is integrable
for every complex spectral point `z ∈ ℂ` (satisfied by every finite `gaussianCombo`). -/
def AdmissibleL1All (f : ℝ → ℂ) : Prop :=
  ∀ z : ℂ, Integrable (fun x : ℝ => f x * Complex.exp (Complex.I * z * (x : ℂ))) volume

lemma admissibleL1All_gaussianCombo (δ : ℝ) (P : Polynomial ℂ) :
    AdmissibleL1All (gaussianCombo δ P) :=
  fun z => integrable_gaussianCombo_mul_cexp δ P z

/-- **Strip Super-Gaussian Decay Bound:**
On any horizontal strip `|z.im| ≤ B`, the Mellin–Fourier transform of `shiftedGaussian a`
decays super-exponentially in `z.re`:
`‖mellinTransform (shiftedGaussian a) z‖ ≤ √(2π) * exp(-z.re² / 2 + B² / 2 + |a| B)`. -/
theorem norm_mellinTransform_shiftedGaussian_strip (a : ℝ) {B : ℝ}
    {z : ℂ} (hz : |z.im| ≤ B) :
    ‖mellinTransform (shiftedGaussian a) z‖ ≤
      Real.sqrt (2 * Real.pi) * Real.exp (-(z.re ^ 2 / 2) + B ^ 2 / 2 + |a| * B) := by
  rw [mellinTransform_shiftedGaussian a z, norm_mul, norm_mul]
  let C0 : ℂ := (Real.pi / (1 / 2 : ℂ)) ^ (1 / 2 : ℂ)
  have hC0_real : C0 = ((Real.sqrt (2 * Real.pi) : ℝ) : ℂ) := by
    have hpos : (0 : ℝ) < 2 * Real.pi := by positivity
    dsimp [C0]
    rw [show (Real.pi : ℂ) / (1 / 2 : ℂ) = ((2 * Real.pi : ℝ) : ℂ) by push_cast; ring,
      show (1 / 2 : ℂ) = ((1 / 2 : ℝ) : ℂ) by norm_num,
      ← Complex.ofReal_cpow hpos.le, Real.sqrt_eq_rpow]
  have hC0_norm : ‖C0‖ = Real.sqrt (2 * Real.pi) := by
    rw [hC0_real, Complex.norm_real, Real.norm_eq_abs, abs_of_nonneg (Real.sqrt_nonneg _)]
  have hexp1 : ‖Complex.exp (-z ^ 2 / 2)‖ = Real.exp (-(z.re ^ 2 / 2) + z.im ^ 2 / 2) := by
    rw [Complex.norm_exp]
    have hre : (-z ^ 2 / 2).re = -(z.re ^ 2 / 2) + z.im ^ 2 / 2 := by
      have : (-z ^ 2 / 2).re = -(z ^ 2).re / 2 := by simp
      rw [this, sq, Complex.mul_re]
      ring
    rw [hre]
  have hexp2 : ‖Complex.exp (Complex.I * z * (a : ℂ))‖ = Real.exp (-z.im * a) := by
    rw [Complex.norm_exp]
    have hre : (Complex.I * z * (a : ℂ)).re = -z.im * a := by
      simp [Complex.mul_re]
    rw [hre]
  change ‖C0‖ * ‖Complex.exp (-z ^ 2 / 2)‖ * ‖Complex.exp (Complex.I * z * (a : ℂ))‖ ≤ _
  rw [hC0_norm, hexp1, hexp2, mul_assoc, ← Real.exp_add]
  refine mul_le_mul_of_nonneg_left (Real.exp_le_exp.mpr ?_) (Real.sqrt_nonneg _)
  have hzim_sq : z.im ^ 2 ≤ B ^ 2 := by
    have h1 : |z.im| ^ 2 ≤ B ^ 2 := pow_le_pow_left₀ (abs_nonneg _) hz 2
    simpa [sq_abs] using h1
  have ha_im : -z.im * a ≤ |a| * B := by
    calc -z.im * a ≤ |-z.im * a| := le_abs_self _
      _ = |z.im| * |a| := by rw [abs_mul, abs_neg]
      _ = |a| * |z.im| := mul_comm _ _
      _ ≤ |a| * B := mul_le_mul_of_nonneg_left hz (abs_nonneg a)
  linarith

/-- Reusable shifted-Gaussian Lagrange witness on any finite conjugation-invariant zero set `Z`
containing an off-line zero `z₀` (`z₀.im ≠ 0`). -/
theorem exists_gaussianCombo_offline_finite_witness {Z : Finset ℂ} {m : ℂ → ℕ}
    (hZ : ∀ z ∈ Z, starRingEnd ℂ z ∈ Z)
    (hm_symm : ∀ z ∈ Z, m (starRingEnd ℂ z) = m z)
    {z₀ : ℂ} (hz₀ : z₀ ∈ Z) (him_ne : z₀.im ≠ 0) :
    ∃ (δ : ℝ) (P : Polynomial ℂ), 0 < δ ∧
      let f : ℝ → ℂ := gaussianCombo δ P
      AdmissibleL1All f ∧
      ∑ z ∈ Z, (m z : ℂ) * mellinTransform (weilConv f (weilInvol f)) z =
        -4 * (Real.pi : ℂ) * (m z₀ : ℂ) := by
  classical
  let z₀c : ℂ := starRingEnd ℂ z₀
  have hz₀c : z₀c ∈ Z := hZ z₀ hz₀
  have hne : z₀c ≠ z₀ := by
    intro hEq
    have him := congrArg Complex.im hEq
    simp only [z₀c, Complex.conj_im] at him
    exact him_ne (by linarith)
  obtain ⟨δ, hδ_pos, hInj⟩ := exists_delta_exp_injOn Z
  let node : { z : ℂ // z ∈ Z } → ℂ := fun z => Complex.exp (Complex.I * z.1 * (δ : ℂ))
  have hNodeInj : Set.InjOn node ((Finset.univ : Finset { z : ℂ // z ∈ Z }) : Set { z : ℂ // z ∈ Z }) := by
    intro a _ b _ hEq
    exact Subtype.ext (hInj a.2 b.2 hEq)
  let r : { z : ℂ // z ∈ Z } → ℂ := fun z =>
    if z.1 = z₀ then Complex.exp (z₀ ^ 2 / 2)
    else if z.1 = z₀c then -Complex.exp (z₀c ^ 2 / 2)
    else 0
  let P : Polynomial ℂ := Lagrange.interpolate Finset.univ node r
  refine ⟨δ, P, hδ_pos, admissibleL1All_gaussianCombo δ P, ?_⟩
  let f : ℝ → ℂ := gaussianCombo δ P
  have hf_adm : AdmissibleL1 Z f := fun z _ => integrable_gaussianCombo_mul_cexp δ P z
  let C0 : ℂ := (Real.pi / (1 / 2 : ℂ)) ^ (1 / 2 : ℂ)
  have hC0_sq : C0 * starRingEnd ℂ C0 = ((2 * Real.pi : ℝ) : ℂ) := by
    have hpos : (0 : ℝ) < 2 * Real.pi := by positivity
    have hC0_real : C0 = ((Real.sqrt (2 * Real.pi) : ℝ) : ℂ) := by
      dsimp [C0]
      rw [show (Real.pi : ℂ) / (1 / 2 : ℂ) = ((2 * Real.pi : ℝ) : ℂ) by push_cast; ring,
        show (1 / 2 : ℂ) = ((1 / 2 : ℝ) : ℂ) by norm_num,
        ← Complex.ofReal_cpow hpos.le, Real.sqrt_eq_rpow]
    rw [hC0_real, Complex.conj_ofReal]
    norm_cast
    exact Real.mul_self_sqrt hpos.le
  have hMf : ∀ z ∈ Z, mellinTransform f z =
      if z = z₀ then C0 else if z = z₀c then -C0 else 0 := by
    intro z hz
    dsimp [f]
    rw [mellinTransform_gaussianCombo δ P z]
    have heval : P.eval (node ⟨z, hz⟩) = r ⟨z, hz⟩ :=
      Lagrange.eval_interpolate_at_node r hNodeInj (Finset.mem_univ (⟨z, hz⟩ : { z : ℂ // z ∈ Z }))
    change C0 * Complex.exp (-z ^ 2 / 2) * P.eval (node ⟨z, hz⟩) = _
    rw [heval]
    dsimp [r]
    by_cases h1 : z = z₀
    · subst h1
      simp only [↓reduceIte]
      rw [mul_assoc, ← Complex.exp_add]
      have : -z ^ 2 / 2 + z ^ 2 / 2 = 0 := by ring
      rw [this, Complex.exp_zero, mul_one]
    · simp only [h1, ↓reduceIte]
      by_cases h2 : z = z₀c
      · subst h2
        simp only [↓reduceIte, mul_neg]
        rw [mul_assoc, ← Complex.exp_add]
        have : -z₀c ^ 2 / 2 + z₀c ^ 2 / 2 = 0 := by ring
        rw [this, Complex.exp_zero, mul_one]
      · simp only [h2, ↓reduceIte, mul_zero]
  have hconv : ∀ z ∈ Z, mellinTransform (weilConv f (weilInvol f)) z =
      mellinTransform f z * starRingEnd ℂ (mellinTransform f (starRingEnd ℂ z)) := fun z hz =>
    mellinTransform_weilConv_invol (hf_adm z hz) (hf_adm (starRingEnd ℂ z) (hZ z hz))
  rw [Finset.sum_congr rfl fun z hz => by rw [hconv z hz]]
  have hSub : ({z₀, z₀c} : Finset ℂ) ⊆ Z := by
    intro w hw; simp only [Finset.mem_insert, Finset.mem_singleton] at hw
    rcases hw with rfl | rfl <;> assumption
  rw [← Finset.sum_subset hSub]
  · rw [Finset.sum_pair hne.symm]
    have hcc : starRingEnd ℂ z₀c = z₀ := Complex.conj_conj z₀
    rw [hMf z₀ hz₀, hMf z₀c hz₀c, hcc, hMf z₀ hz₀, hm_symm z₀ hz₀]
    simp only [↓reduceIte, hne, map_neg]
    calc (m z₀ : ℂ) * (C0 * -starRingEnd ℂ C0) + (m z₀ : ℂ) * (-C0 * starRingEnd ℂ C0)
        = -2 * (m z₀ : ℂ) * (C0 * starRingEnd ℂ C0) := by ring
      _ = -2 * (m z₀ : ℂ) * ((2 * Real.pi : ℝ) : ℂ) := by rw [hC0_sq]
      _ = -4 * (Real.pi : ℂ) * (m z₀ : ℂ) := by push_cast; ring
  · intro w hw hnot
    simp only [Finset.mem_insert, Finset.mem_singleton, not_or] at hnot
    rw [hMf w hw]
    simp only [hnot.1, hnot.2, ↓reduceIte, zero_mul, mul_zero]

/-- **Theorem 3.2 (Upgraded Weil Positivity Criterion on Genuine `L¹(ℝ)` Test Functions):**
For any finite conjugation-invariant zero set `Z ⊂ ℂ` with positive symmetric multiplicities `m`,
every zero in `Z` is real **if and only if**
`Re (∑_{z ∈ Z} m(z) M_{f * f̃}(z)) ≥ 0` for every admissible test function `f ∈ L¹(ℝ)`. -/
theorem weilPositivity_L1_iff_allRealZeros {Z : Finset ℂ} {m : ℂ → ℕ}
    (hZ : ∀ z ∈ Z, starRingEnd ℂ z ∈ Z)
    (hm_symm : ∀ z ∈ Z, m (starRingEnd ℂ z) = m z)
    (hm_pos : ∀ z ∈ Z, 0 < m z) :
    (∀ z ∈ Z, z.im = 0) ↔
      (∀ f : ℝ → ℂ, AdmissibleL1 Z f →
        0 ≤ (∑ z ∈ Z, (m z : ℂ) * mellinTransform (weilConv f (weilInvol f)) z).re) := by
  classical
  constructor
  · intro hReal f hf
    rw [Complex.re_sum]
    refine Finset.sum_nonneg fun z hz => ?_
    have him : z.im = 0 := hReal z hz
    have hzR : z = (z.re : ℂ) := Complex.ext rfl (by simp [him])
    have hfR : Integrable (fun y : ℝ => f y * Complex.exp (Complex.I * (z.re : ℂ) * (y : ℂ))) volume := by
      simpa [← hzR] using hf z hz
    rw [hzR, mellinTransform_weilConv_invol_real z.re hfR]
    have hre : ((m (z.re : ℂ) : ℂ) * ((‖mellinTransform f (z.re : ℂ)‖ ^ 2 : ℝ) : ℂ)).re =
        (m (z.re : ℂ) : ℝ) * ‖mellinTransform f (z.re : ℂ)‖ ^ 2 := by norm_cast
    rw [hre]
    exact mul_nonneg (Nat.cast_nonneg _) (sq_nonneg _)
  · intro hPos z₀ hz₀
    by_contra him_ne
    obtain ⟨δ, P, _, hf_all, hSum⟩ :=
      exists_gaussianCombo_offline_finite_witness hZ hm_symm hz₀ him_ne
    have hNonneg := hPos (gaussianCombo δ P) (fun z _ => hf_all z)
    rw [hSum] at hNonneg
    have hre : (-4 * (Real.pi : ℂ) * (m z₀ : ℂ)).re = -4 * Real.pi * (m z₀ : ℝ) := by norm_cast
    rw [hre] at hNonneg
    have hpos_m : (0 : ℝ) < (m z₀ : ℝ) := by exact_mod_cast hm_pos z₀ hz₀
    nlinarith [Real.pi_pos]

/-- Infinite-series Weil quadratic form over a countably infinite zero sequence `(z, m)`. -/
noncomputable def weilInfiniteSum (z : ℕ → ℂ) (m : ℕ → ℕ) (f : ℝ → ℂ) : ℂ :=
  ∑' n : ℕ, (m n : ℂ) * mellinTransform (weilConv f (weilInvol f)) (z n)

/-- **Theorem 3.3 (Infinite-Zero Critical-Line Weil Positivity):**
For any countably infinite zero sequence `z : ℕ → ℂ` lying entirely on `ℝ` (`∀ n, (z n).im = 0`)
and any globally admissible `L¹(ℝ)` function `f` whose Weil series converges, the infinite Weil
sum is real and nonnegative. -/
theorem weilInfiniteSum_nonneg_of_allRealZeros (z : ℕ → ℂ) (m : ℕ → ℕ)
    (hReal : ∀ n : ℕ, (z n).im = 0) {f : ℝ → ℂ} (hf : AdmissibleL1All f)
    (hSumm : Summable (fun n : ℕ => (m n : ℝ) * ‖mellinTransform f (z n)‖ ^ 2)) :
    0 ≤ (weilInfiniteSum z m f).re ∧ (weilInfiniteSum z m f).im = 0 := by
  have hterm : (fun n : ℕ => (m n : ℂ) * mellinTransform (weilConv f (weilInvol f)) (z n)) =
      fun n : ℕ => (((m n : ℝ) * ‖mellinTransform f (z n)‖ ^ 2 : ℝ) : ℂ) := by
    funext n
    have hzR : z n = ((z n).re : ℂ) := Complex.ext rfl (by simp [hReal n])
    have hfR : Integrable (fun y : ℝ => f y * Complex.exp (Complex.I * ((z n).re : ℂ) * (y : ℂ))) volume := by
      simpa [← hzR] using hf (z n)
    rw [hzR, mellinTransform_weilConv_invol_real (z n).re hfR]
    push_cast
    rfl
  have hSummC : Summable (fun n : ℕ => (m n : ℂ) * mellinTransform (weilConv f (weilInvol f)) (z n)) := by
    rw [hterm]
    exact Complex.summable_ofReal.mpr hSumm
  unfold weilInfiniteSum
  rw [Complex.re_tsum hSummC, Complex.im_tsum hSummC]
  have hre : (fun n : ℕ => ((m n : ℂ) * mellinTransform (weilConv f (weilInvol f)) (z n)).re) =
      fun n : ℕ => (m n : ℝ) * ‖mellinTransform f (z n)‖ ^ 2 := by
    funext n
    rw [congrFun hterm n, Complex.ofReal_re]
  have him : (fun n : ℕ => ((m n : ℂ) * mellinTransform (weilConv f (weilInvol f)) (z n)).im) =
      fun _ => (0 : ℝ) := by
    funext n
    rw [congrFun hterm n, Complex.ofReal_im]
  rw [hre, him, tsum_zero]
  exact ⟨tsum_nonneg fun n => mul_nonneg (Nat.cast_nonneg _) (sq_nonneg _), rfl⟩

/-- **Theorem 3.4 (Tail-Dominated Infinite-Zero Off-Line Weil Disproof Witness):**
For any countably infinite zero sequence `(z : ℕ → ℂ, m : ℕ → ℕ)` containing an injective,
conjugation-invariant finite core `F : Finset ℕ` with an off-line zero `n₀ ∈ F` (`(z n₀).im ≠ 0`,
`0 < m n₀`), there exists an explicit globally admissible shifted-Gaussian `L¹(ℝ)` test function
`f = gaussianCombo δ P` whose core Weil sum equals `-4π m(n₀)`, and whenever the infinite tail
sum has real part `< 4π m(n₀)`, the full infinite Weil sum `weilInfiniteSum z m f` is strictly
negative (`< 0`). -/
theorem weilInfiniteSum_neg_of_offline_pair_tail_lt
    (z : ℕ → ℂ) (m : ℕ → ℕ) (F : Finset ℕ)
    (hInj : Set.InjOn z (F : Set ℕ))
    (hConj : ∀ n ∈ F, ∃ k ∈ F, z k = starRingEnd ℂ (z n) ∧ m k = m n)
    {n₀ : ℕ} (hn₀ : n₀ ∈ F) (him_ne : (z n₀).im ≠ 0) :
    ∃ f : ℝ → ℂ,
      AdmissibleL1All f ∧
      (∑ n ∈ F, (m n : ℂ) * mellinTransform (weilConv f (weilInvol f)) (z n) =
        -4 * (Real.pi : ℂ) * (m n₀ : ℂ)) ∧
      (Summable (fun n : ℕ => (m n : ℂ) * mellinTransform (weilConv f (weilInvol f)) (z n)) →
        (∑' k : ↑(F : Set ℕ)ᶜ,
          ((m k.1 : ℂ) * mellinTransform (weilConv f (weilInvol f)) (z k.1)).re) <
            4 * Real.pi * (m n₀ : ℝ) →
        (weilInfiniteSum z m f).re < 0) := by
  classical
  let Z : Finset ℂ := F.image z
  let mZ : ℂ → ℕ := fun w => ∑ n ∈ F, if z n = w then m n else 0
  have hZ_conj : ∀ w ∈ Z, starRingEnd ℂ w ∈ Z := by
    intro w hw
    obtain ⟨n, hn, rfl⟩ := Finset.mem_image.mp hw
    obtain ⟨k, hk, hzk, _⟩ := hConj n hn
    exact Finset.mem_image.mpr ⟨k, hk, hzk⟩
  have hmZ_at : ∀ n ∈ F, mZ (z n) = m n := by
    intro n hn
    dsimp [mZ]
    rw [Finset.sum_eq_single n]
    · simp
    · intro k hk hkn
      simp only [ite_eq_right_iff]
      intro heq
      exact absurd (hInj hk hn heq) hkn
    · intro hnot; exact absurd hn hnot
  have hmZ_symm : ∀ w ∈ Z, mZ (starRingEnd ℂ w) = mZ w := by
    intro w hw
    obtain ⟨n, hn, rfl⟩ := Finset.mem_image.mp hw
    obtain ⟨k, hk, hzk, hmk⟩ := hConj n hn
    rw [← hzk, hmZ_at k hk, hmZ_at n hn, hmk]
  have hz₀_mem : z n₀ ∈ Z := Finset.mem_image.mpr ⟨n₀, hn₀, rfl⟩
  obtain ⟨δ, P, _, hf_all, hSumZ⟩ :=
    exists_gaussianCombo_offline_finite_witness hZ_conj hmZ_symm hz₀_mem him_ne
  let f : ℝ → ℂ := gaussianCombo δ P
  have hSumF : ∑ n ∈ F, (m n : ℂ) * mellinTransform (weilConv f (weilInvol f)) (z n) =
      -4 * (Real.pi : ℂ) * (m n₀ : ℂ) := by
    have hImg : ∑ w ∈ Z, (mZ w : ℂ) * mellinTransform (weilConv f (weilInvol f)) w =
        ∑ n ∈ F, (mZ (z n) : ℂ) * mellinTransform (weilConv f (weilInvol f)) (z n) :=
      Finset.sum_image (fun a ha b hb hab => hInj ha hb hab)
    have hEqF : ∑ n ∈ F, (mZ (z n) : ℂ) * mellinTransform (weilConv f (weilInvol f)) (z n) =
        ∑ n ∈ F, (m n : ℂ) * mellinTransform (weilConv f (weilInvol f)) (z n) :=
      Finset.sum_congr rfl fun n hn => by rw [hmZ_at n hn]
    rw [← hEqF, ← hImg, hSumZ, hmZ_at n₀ hn₀]
  refine ⟨f, hf_all, hSumF, fun hSumm hTail => ?_⟩
  unfold weilInfiniteSum
  have hSplit := hSumm.sum_add_tsum_compl (s := F)
  have hReSplit :
      (∑' n : ℕ, (m n : ℂ) * mellinTransform (weilConv f (weilInvol f)) (z n)).re =
      (∑ n ∈ F, (m n : ℂ) * mellinTransform (weilConv f (weilInvol f)) (z n)).re +
      (∑' k : ↑(F : Set ℕ)ᶜ, (m k.1 : ℂ) * mellinTransform (weilConv f (weilInvol f)) (z k.1)).re := by
    rw [← hSplit, Complex.add_re]
  have hTailSumm : Summable (fun k : ↑(F : Set ℕ)ᶜ =>
      (m k.1 : ℂ) * mellinTransform (weilConv f (weilInvol f)) (z k.1)) :=
    hSumm.subtype _
  rw [hReSplit, hSumF, Complex.re_tsum hTailSumm]
  have hCoreRe : (-4 * (Real.pi : ℂ) * (m n₀ : ℂ)).re = -4 * Real.pi * (m n₀ : ℝ) := by norm_cast
  rw [hCoreRe]
  linarith

end Signals.SatoGrassmannian.WeilGaussianL1
