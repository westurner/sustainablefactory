import Mathlib.Analysis.Calculus.Deriv.Basic
import Mathlib.Analysis.Calculus.Deriv.Mul
import Mathlib.Analysis.Calculus.Deriv.Pow
import Mathlib.Analysis.Calculus.IteratedDeriv.Lemmas
import Mathlib.Analysis.Normed.Algebra.Exponential
import Signals.SatoGrassmannian.Gr24Truncation
import Signals.SatoGrassmannian.KPFlow

namespace Signals.SatoGrassmannian.HirotaKP

open Signals.SatoGrassmannian Signals.SatoGrassmannian.CircleL2
open Signals.SatoGrassmannian.Gr24Truncation Signals.SatoGrassmannian.KPFlow

noncomputable section

/-! ### Section 1: Elementary Schur Polynomials & Explicit Evaluation of `kpMatrix4` -/

/-- Canonical indices `1, 2, 3 ∈ ℕ+` for the first three KP times. -/
def idx1 : ℕ+ := ⟨1, by norm_num⟩
def idx2 : ℕ+ := ⟨2, by norm_num⟩
def idx3 : ℕ+ := ⟨3, by norm_num⟩

/-- Embed `(t₁, t₂, t₃) ∈ ℂ³` into `KPTime = ℓ¹(ℕ₊, ℂ)`. -/
def kpTime3 (t₁ t₂ t₃ : ℂ) : KPTime :=
  lp.single 1 idx1 t₁ + lp.single 1 idx2 t₂ + lp.single 1 idx3 t₃

lemma kpTime3_idx1 (t₁ t₂ t₃ : ℂ) : kpTime3 t₁ t₂ t₃ idx1 = t₁ := by
  have h12 : idx1 ≠ idx2 := by decide
  have h13 : idx1 ≠ idx3 := by decide
  simp [kpTime3, lp.single_apply, h12, h13]

lemma kpTime3_idx2 (t₁ t₂ t₃ : ℂ) : kpTime3 t₁ t₂ t₃ idx2 = t₂ := by
  have h21 : idx2 ≠ idx1 := by decide
  have h23 : idx2 ≠ idx3 := by decide
  simp [kpTime3, lp.single_apply, h21, h23]

lemma kpTime3_idx3 (t₁ t₂ t₃ : ℂ) : kpTime3 t₁ t₂ t₃ idx3 = t₃ := by
  have h31 : idx3 ≠ idx1 := by decide
  have h32 : idx3 ≠ idx2 := by decide
  simp [kpTime3, lp.single_apply, h31, h32]

/-- Elementary Schur polynomials `p₁, p₂, p₃` defined by `exp(t₁ z + t₂ z² + t₃ z³) = ∑ pₙ zⁿ`. -/
def elemSchur1 (t₁ _t₂ _t₃ : ℂ) : ℂ := t₁
def elemSchur2 (t₁ t₂ _t₃ : ℂ) : ℂ := t₂ + (1 / 2 : ℂ) * t₁ ^ 2
def elemSchur3 (t₁ t₂ t₃ : ℂ) : ℂ := t₃ + t₁ * t₂ + (1 / 6 : ℂ) * t₁ ^ 3

lemma kpGen4_apply_val (t : KPTime) (u : C4) :
    kpGen4 t u 0 = 0 ∧
    kpGen4 t u 1 = t idx1 * u 0 ∧
    kpGen4 t u 2 = t idx1 * u 1 + t idx2 * u 0 ∧
    kpGen4 t u 3 = t idx1 * u 2 + t idx2 * u 1 + t idx3 * u 0 := by
  refine ⟨?_, ?_, ?_, ?_⟩ <;>
    simp [kpGen4, idx1, idx2, idx3, pow_succ, mul_apply_eq_comp, nilpShift4]

lemma kpGen4_pow_two_apply (t : KPTime) (u : C4) :
    (kpGen4 t ^ 2) u 0 = 0 ∧
    (kpGen4 t ^ 2) u 1 = 0 ∧
    (kpGen4 t ^ 2) u 2 = t idx1 ^ 2 * u 0 ∧
    (kpGen4 t ^ 2) u 3 = t idx1 ^ 2 * u 1 + 2 * t idx1 * t idx2 * u 0 := by
  have h1 := kpGen4_apply_val t u
  have h2 := kpGen4_apply_val t (kpGen4 t u)
  rw [sq, mul_apply_eq_comp]
  refine ⟨by rw [h2.1], by rw [h2.2.1, h1.1, mul_zero], ?_, ?_⟩
  · rw [h2.2.2.1, h1.2.1, h1.1]; ring
  · rw [h2.2.2.2, h1.2.2.1, h1.2.1, h1.1]; ring

lemma kpGen4_pow_three_apply (t : KPTime) (u : C4) :
    (kpGen4 t ^ 3) u 0 = 0 ∧
    (kpGen4 t ^ 3) u 1 = 0 ∧
    (kpGen4 t ^ 3) u 2 = 0 ∧
    (kpGen4 t ^ 3) u 3 = t idx1 ^ 3 * u 0 := by
  have h2 := kpGen4_pow_two_apply t u
  have h3 := kpGen4_apply_val t ((kpGen4 t ^ 2) u)
  have hpow : kpGen4 t ^ 3 = kpGen4 t * kpGen4 t ^ 2 := by rw [pow_succ']
  rw [hpow, mul_apply_eq_comp]
  refine ⟨by rw [h3.1], by rw [h3.2.1, h2.1, mul_zero], ?_, ?_⟩
  · rw [h3.2.2.1, h2.2.1, h2.1]; ring
  · rw [h3.2.2.2, h2.2.2.1, h2.2.1, h2.1]; ring

lemma kpGen4_pow_four (t : KPTime) : kpGen4 t ^ 4 = 0 := by
  ext u i
  have h3 := kpGen4_pow_three_apply t u
  have h4 := kpGen4_apply_val t ((kpGen4 t ^ 3) u)
  have hpow : kpGen4 t ^ 4 = kpGen4 t * kpGen4 t ^ 3 := by rw [pow_succ']
  rw [hpow, mul_apply_eq_comp]
  fin_cases i
  · change (kpGen4 t) ((kpGen4 t ^ 3) u) 0 = 0; exact h4.1
  · change (kpGen4 t) ((kpGen4 t ^ 3) u) 1 = 0; rw [h4.2.1, h3.1]; simp
  · change (kpGen4 t) ((kpGen4 t ^ 3) u) 2 = 0; rw [h4.2.2.1, h3.2.1, h3.1]; simp
  · change (kpGen4 t) ((kpGen4 t ^ 3) u) 3 = 0; rw [h4.2.2.2, h3.2.2.1, h3.2.1, h3.1]; simp

lemma kpGen4_pow_eq_zero_of_ge_four (t : KPTime) {k : ℕ} (hk : 4 ≤ k) :
    kpGen4 t ^ k = 0 := by
  obtain ⟨d, rfl⟩ := Nat.exists_eq_add_of_le hk
  rw [pow_add, kpGen4_pow_four, zero_mul]

/-- Exact finite-sum expansion of `kpMatrix4 t = exp(kpGen4 t)` using nilpotency `A⁴ = 0`. -/
theorem kpMatrix4_eq_finiteSum (t : KPTime) :
    (kpMatrix4 t : C4 →L[ℂ] C4) =
      1 + kpGen4 t + (2 : ℂ)⁻¹ • kpGen4 t ^ 2 + (6 : ℂ)⁻¹ • kpGen4 t ^ 3 := by
  change NormedSpace.exp (kpGen4 t) = _
  rw [congrFun (NormedSpace.exp_eq_tsum (𝕂 := ℂ) (𝔸 := C4 →L[ℂ] C4)) (kpGen4 t)]
  rw [tsum_eq_sum (s := Finset.range 4)]
  · simp only [Finset.sum_range_succ, Finset.sum_range_zero, zero_add,
      Nat.factorial, pow_zero, pow_one, Nat.cast_one, inv_one, one_smul]
    norm_num
  · intro k hk
    have hge : 4 ≤ k := by simpa [Finset.mem_range] using hk
    rw [kpGen4_pow_eq_zero_of_ge_four t hge, smul_zero]

/-- Explicit coordinate formula for `kpMatrix4 t u` in terms of `elemSchur1, elemSchur2, elemSchur3`. -/
theorem kpMatrix4_apply_eq (t : KPTime) (u : C4) :
    let t₁ := t idx1; let t₂ := t idx2; let t₃ := t idx3
    kpMatrix4 t u 0 = u 0 ∧
    kpMatrix4 t u 1 = u 1 + elemSchur1 t₁ t₂ t₃ * u 0 ∧
    kpMatrix4 t u 2 = u 2 + elemSchur1 t₁ t₂ t₃ * u 1 + elemSchur2 t₁ t₂ t₃ * u 0 ∧
    kpMatrix4 t u 3 = u 3 + elemSchur1 t₁ t₂ t₃ * u 2 +
      elemSchur2 t₁ t₂ t₃ * u 1 + elemSchur3 t₁ t₂ t₃ * u 0 := by
  intro t₁ t₂ t₃
  have hM := congrArg (fun L : C4 →L[ℂ] C4 => L u) (kpMatrix4_eq_finiteSum t)
  have h1 := kpGen4_apply_val t u
  have h2 := kpGen4_pow_two_apply t u
  have h3 := kpGen4_pow_three_apply t u
  have hcoord : ∀ i : Fin 4, kpMatrix4 t u i =
      u i + kpGen4 t u i + (2 : ℂ)⁻¹ * (kpGen4 t ^ 2) u i + (6 : ℂ)⁻¹ * (kpGen4 t ^ 3) u i := by
    intro i
    simpa [add_apply, smul_apply] using congrFun hM i
  refine ⟨?_, ?_, ?_, ?_⟩
  · rw [hcoord 0, h1.1, h2.1, h3.1]; ring
  · rw [hcoord 1, h1.2.1, h2.2.1, h3.2.1]; unfold elemSchur1; ring
  · rw [hcoord 2, h1.2.2.1, h2.2.2.1, h3.2.2.1]; unfold elemSchur1 elemSchur2; ring
  · rw [hcoord 3, h1.2.2.2, h2.2.2.2, h3.2.2.2]; unfold elemSchur1 elemSchur2 elemSchur3; ring

/-! ### Section 2: Schur Polynomials `s_λ` (`λ ⊆ (2,2)`) & Sato `τ`-Function `τ_U` -/

def schurEmpty (_t₁ _t₂ _t₃ : ℂ) : ℂ := 1
def schur1 (t₁ _t₂ _t₃ : ℂ) : ℂ := t₁
def schur2 (t₁ t₂ _t₃ : ℂ) : ℂ := t₂ + (1 / 2 : ℂ) * t₁ ^ 2
def schur11 (t₁ t₂ _t₃ : ℂ) : ℂ := (1 / 2 : ℂ) * t₁ ^ 2 - t₂
def schur21 (t₁ _t₂ t₃ : ℂ) : ℂ := (1 / 3 : ℂ) * t₁ ^ 3 - t₃
def schur22 (t₁ t₂ t₃ : ℂ) : ℂ := (1 / 12 : ℂ) * t₁ ^ 4 + t₂ ^ 2 - t₁ * t₃

/-- Verification of the Jacobi–Trudi determinantal identities for all partitions `λ ⊆ (2,2)`. -/
theorem schur_jacobiTrudi (t₁ t₂ t₃ : ℂ) :
    schur11 t₁ t₂ t₃ = elemSchur1 t₁ t₂ t₃ ^ 2 - elemSchur2 t₁ t₂ t₃ ∧
    schur21 t₁ t₂ t₃ = elemSchur1 t₁ t₂ t₃ * elemSchur2 t₁ t₂ t₃ - elemSchur3 t₁ t₂ t₃ ∧
    schur22 t₁ t₂ t₃ = elemSchur2 t₁ t₂ t₃ ^ 2 - elemSchur1 t₁ t₂ t₃ * elemSchur3 t₁ t₂ t₃ := by
  unfold schur11 schur21 schur22 elemSchur1 elemSchur2 elemSchur3
  refine ⟨by ring, by ring, by ring⟩

/-- General Schur-polynomial linear combination parameterized by 6 projective coordinates. -/
def schurTau (p01 p02 p03 p12 p13 p23 : ℂ) (t₁ t₂ t₃ : ℂ) : ℂ :=
  p23 * schurEmpty t₁ t₂ t₃ +
  p13 * schur1 t₁ t₂ t₃ +
  p03 * schur2 t₁ t₂ t₃ +
  p12 * schur11 t₁ t₂ t₃ +
  p02 * schur21 t₁ t₂ t₃ +
  p01 * schur22 t₁ t₂ t₃

/-- The Sato `τ`-function of a 2-plane frame `(v, w)` under the KP flow:
`τ_U(t₁, t₂, t₃) = pluckerCoord (kpMatrix4 t v) (kpMatrix4 t w) 2 3`. -/
noncomputable def tauU (v w : C4) (t₁ t₂ t₃ : ℂ) : ℂ :=
  pluckerCoord (kpMatrix4 (kpTime3 t₁ t₂ t₃) v) (kpMatrix4 (kpTime3 t₁ t₂ t₃) w) 2 3

/-- **Theorem 1 (Schur Expansion of `τ_U`):**
For any full KP time `t ∈ ℓ¹(ℕ₊, ℂ)`, `pluckerCoord (kpMatrix4 t v) (kpMatrix4 t w) 2 3`
equals the Schur-polynomial expansion `schurTau` with the frame's Plücker coordinates. -/
theorem pluckerCoord_kpMatrix4_eq_schurTau (v w : C4) (t : KPTime) :
    pluckerCoord (kpMatrix4 t v) (kpMatrix4 t w) 2 3 =
      schurTau (pluckerCoord v w 0 1) (pluckerCoord v w 0 2) (pluckerCoord v w 0 3)
               (pluckerCoord v w 1 2) (pluckerCoord v w 1 3) (pluckerCoord v w 2 3)
               (t idx1) (t idx2) (t idx3) := by
  have hv := kpMatrix4_apply_eq t v
  have hw := kpMatrix4_apply_eq t w
  unfold pluckerCoord schurTau schurEmpty schur1 schur2 schur11 schur21 schur22
  rw [hv.2.2.1, hv.2.2.2, hw.2.2.1, hw.2.2.2]
  unfold elemSchur1 elemSchur2 elemSchur3
  ring

theorem tauU_eq_schurTau (v w : C4) (t₁ t₂ t₃ : ℂ) :
    tauU v w t₁ t₂ t₃ =
      schurTau (pluckerCoord v w 0 1) (pluckerCoord v w 0 2) (pluckerCoord v w 0 3)
               (pluckerCoord v w 1 2) (pluckerCoord v w 1 3) (pluckerCoord v w 2 3)
               t₁ t₂ t₃ := by
  unfold tauU
  rw [pluckerCoord_kpMatrix4_eq_schurTau, kpTime3_idx1, kpTime3_idx2, kpTime3_idx3]

/-- **Corollary (Big-Cell Nonvanishing):** `τ_U(0, 0, 0) ≠ 0` iff `Ψ(U)` lies in the
Sato big cell (`ker p₊ = ⊥`). -/
theorem tauU_zero_ne_zero_iff_bigCell (U : Gr24) (v w : C4)
    (hspan : U.1 = Submodule.span ℂ ({v, w} : Set C4))
    (hli : LinearIndependent ℂ ![v, w]) :
    tauU v w 0 0 0 ≠ 0 ↔
      LinearMap.ker (projPlus hardyPolarization (truncSubspace U.1)).toLinearMap = ⊥ := by
  rw [tauU_eq_schurTau, ker_projPlus_eq_bot_iff_plucker23_ne_zero U v w hspan hli]
  simp [schurTau, schurEmpty, schur1, schur2, schur11, schur21, schur22]

/-! ### Section 3: Analytic Hirota Bilinear Derivatives & Leibniz Expansions -/

/-- Analytic Hirota bilinear derivative `D₁ᵏ (f · g)(t) = (d/dy)ᵏ|_{y=0} f(t₁+y, t₂, t₃) g(t₁-y, t₂, t₃)`. -/
noncomputable def hirotaD1 (k : ℕ) (f g : ℂ → ℂ → ℂ → ℂ) (t₁ t₂ t₃ : ℂ) : ℂ :=
  iteratedDeriv k (fun y => f (t₁ + y) t₂ t₃ * g (t₁ - y) t₂ t₃) 0

/-- Analytic Hirota bilinear derivative `D₂ᵏ (f · g)(t) = (d/dy)ᵏ|_{y=0} f(t₁, t₂+y, t₃) g(t₁, t₂-y, t₃)`. -/
noncomputable def hirotaD2 (k : ℕ) (f g : ℂ → ℂ → ℂ → ℂ) (t₁ t₂ t₃ : ℂ) : ℂ :=
  iteratedDeriv k (fun y => f t₁ (t₂ + y) t₃ * g t₁ (t₂ - y) t₃) 0

/-- Analytic mixed Hirota bilinear derivative `D₁ D₃ (f · g)`. -/
noncomputable def hirotaD1D3 (f g : ℂ → ℂ → ℂ → ℂ) (t₁ t₂ t₃ : ℂ) : ℂ :=
  deriv (fun y₁ => deriv (fun y₃ =>
    f (t₁ + y₁) t₂ (t₃ + y₃) * g (t₁ - y₁) t₂ (t₃ - y₃)) 0) 0

/-- The Hirota bilinear KP operator `(D₁⁴ - 4 D₁ D₃ + 3 D₂²) (f · f)`. -/
noncomputable def hirotaKP (f : ℂ → ℂ → ℂ → ℂ) (t₁ t₂ t₃ : ℂ) : ℂ :=
  hirotaD1 4 f f t₁ t₂ t₃ - 4 * hirotaD1D3 f f t₁ t₂ t₃ + 3 * hirotaD2 2 f f t₁ t₂ t₃

/-- Core differentiation helper for shifted products `u ↦ a(x + u) * b(x - u)`. -/
lemma hasDerivAt_shift_mul {a a' b b' : ℂ → ℂ} {x y : ℂ}
    (ha : HasDerivAt a (a' (x + y)) (x + y))
    (hb : HasDerivAt b (b' (x - y)) (x - y)) :
    HasDerivAt (fun u => a (x + u) * b (x - u))
      (a' (x + y) * b (x - y) - a (x + y) * b' (x - y)) y := by
  have h1 : HasDerivAt (fun u => a (x + u)) (a' (x + y) * (0 + 1)) y :=
    ha.comp y ((hasDerivAt_const y x).add (hasDerivAt_id y))
  have h2 : HasDerivAt (fun u => b (x - u)) (b' (x - y) * (0 - 1)) y :=
    hb.comp y ((hasDerivAt_const y x).sub (hasDerivAt_id y))
  convert h1.mul h2 using 1
  ring

/-- General Leibniz formula: `D₂² (f · f) = 2 f f₂₂ - 2 f₂²`. -/
theorem hirotaD2_two_eq {f : ℂ → ℂ → ℂ → ℂ} {g₁ g₂ : ℂ → ℂ} {t₁ t₂ t₃ : ℂ}
    (h1 : ∀ y, HasDerivAt (fun u => f t₁ u t₃) (g₁ y) y)
    (h2 : ∀ y, HasDerivAt g₁ (g₂ y) y) :
    hirotaD2 2 f f t₁ t₂ t₃ = 2 * f t₁ t₂ t₃ * g₂ t₂ - 2 * g₁ t₂ ^ 2 := by
  let φ₀ : ℂ → ℂ := fun y => f t₁ (t₂ + y) t₃ * f t₁ (t₂ - y) t₃
  let φ₁ : ℂ → ℂ := fun y => g₁ (t₂ + y) * f t₁ (t₂ - y) t₃ - f t₁ (t₂ + y) t₃ * g₁ (t₂ - y)
  have hd1 : deriv φ₀ = φ₁ := by
    ext y
    exact (hasDerivAt_shift_mul (h1 (t₂ + y)) (h1 (t₂ - y))).deriv
  have hd2 : HasDerivAt φ₁
      (2 * f t₁ t₂ t₃ * g₂ t₂ - 2 * g₁ t₂ ^ 2) 0 := by
    have ha := hasDerivAt_shift_mul (h2 (t₂ + 0)) (h1 (t₂ - 0))
    have hb := hasDerivAt_shift_mul (h1 (t₂ + 0)) (h2 (t₂ - 0))
    convert ha.sub hb using 1
    simp only [add_zero, sub_zero]
    ring
  change iteratedDeriv (0 + 1 + 1) φ₀ 0 = _
  simp only [iteratedDeriv_succ, iteratedDeriv_zero, hd1]
  exact hd2.deriv

/-- General Leibniz formula: `D₁⁴ (f · f) = 2 f f₁₁₁₁ - 8 f₁ f₁₁₁ + 6 f₁₁²`. -/
theorem hirotaD1_four_eq {f : ℂ → ℂ → ℂ → ℂ} {g₁ g₂ g₃ g₄ : ℂ → ℂ} {t₁ t₂ t₃ : ℂ}
    (h1 : ∀ x, HasDerivAt (fun u => f u t₂ t₃) (g₁ x) x)
    (h2 : ∀ x, HasDerivAt g₁ (g₂ x) x)
    (h3 : ∀ x, HasDerivAt g₂ (g₃ x) x)
    (h4 : ∀ x, HasDerivAt g₃ (g₄ x) x) :
    hirotaD1 4 f f t₁ t₂ t₃ =
      2 * f t₁ t₂ t₃ * g₄ t₁ - 8 * g₁ t₁ * g₃ t₁ + 6 * g₂ t₁ ^ 2 := by
  let g₀ : ℂ → ℂ := fun u => f u t₂ t₃
  let φ₀ : ℂ → ℂ := fun y => g₀ (t₁ + y) * g₀ (t₁ - y)
  let φ₁ : ℂ → ℂ := fun y => g₁ (t₁ + y) * g₀ (t₁ - y) - g₀ (t₁ + y) * g₁ (t₁ - y)
  let φ₂ : ℂ → ℂ := fun y =>
    g₂ (t₁ + y) * g₀ (t₁ - y) - 2 * (g₁ (t₁ + y) * g₁ (t₁ - y)) + g₀ (t₁ + y) * g₂ (t₁ - y)
  let φ₃ : ℂ → ℂ := fun y =>
    g₃ (t₁ + y) * g₀ (t₁ - y) - 3 * (g₂ (t₁ + y) * g₁ (t₁ - y)) +
    3 * (g₁ (t₁ + y) * g₂ (t₁ - y)) - g₀ (t₁ + y) * g₃ (t₁ - y)
  have hd1 : deriv φ₀ = φ₁ := by
    ext y; exact (hasDerivAt_shift_mul (h1 _) (h1 _)).deriv
  have hd2 : deriv φ₁ = φ₂ := by
    ext y
    have h := (hasDerivAt_shift_mul (h2 (t₁ + y)) (h1 (t₁ - y))).sub
      (hasDerivAt_shift_mul (h1 (t₁ + y)) (h2 (t₁ - y)))
    have h' : HasDerivAt φ₁ (φ₂ y) y := by convert h using 1; dsimp [φ₂]; ring
    exact h'.deriv
  have hd3 : deriv φ₂ = φ₃ := by
    ext y
    have h := ((hasDerivAt_shift_mul (h3 (t₁ + y)) (h1 (t₁ - y))).sub
      ((hasDerivAt_shift_mul (h2 (t₁ + y)) (h2 (t₁ - y))).const_mul 2)).add
      (hasDerivAt_shift_mul (h1 (t₁ + y)) (h3 (t₁ - y)))
    have h' : HasDerivAt φ₂ (φ₃ y) y := by convert h using 1; dsimp [φ₃]; ring
    exact h'.deriv
  have hd4 : HasDerivAt φ₃
      (2 * g₀ t₁ * g₄ t₁ - 8 * g₁ t₁ * g₃ t₁ + 6 * g₂ t₁ ^ 2) 0 := by
    have h := (((hasDerivAt_shift_mul (h4 (t₁ + 0)) (h1 (t₁ - 0))).sub
      ((hasDerivAt_shift_mul (h3 (t₁ + 0)) (h2 (t₁ - 0))).const_mul 3)).add
      ((hasDerivAt_shift_mul (h2 (t₁ + 0)) (h3 (t₁ - 0))).const_mul 3)).sub
      (hasDerivAt_shift_mul (h1 (t₁ + 0)) (h4 (t₁ - 0)))
    convert h using 1
    simp only [add_zero, sub_zero]
    ring
  change iteratedDeriv (0 + 1 + 1 + 1 + 1) φ₀ 0 = _
  simp only [iteratedDeriv_succ, iteratedDeriv_zero, hd1, hd2, hd3]
  exact hd4.deriv

/-- General Leibniz formula: `D₁ D₃ (f · f) = 2 f f₁₃ - 2 f₁ f₃`. -/
theorem hirotaD1D3_eq {f : ℂ → ℂ → ℂ → ℂ} {f₁ : ℂ → ℂ} {f₃ : ℂ → ℂ → ℂ} {f₁₃ : ℂ → ℂ}
    {t₁ t₂ t₃ : ℂ}
    (h3 : ∀ x z, HasDerivAt (fun u => f x t₂ u) (f₃ x z) z)
    (h1 : ∀ x, HasDerivAt (fun u => f u t₂ t₃) (f₁ x) x)
    (h13 : ∀ x, HasDerivAt (fun u => f₃ u t₃) (f₁₃ x) x) :
    hirotaD1D3 f f t₁ t₂ t₃ = 2 * f t₁ t₂ t₃ * f₁₃ t₁ - 2 * f₁ t₁ * f₃ t₁ t₃ := by
  have hinner : (fun y₁ => deriv (fun y₃ =>
      f (t₁ + y₁) t₂ (t₃ + y₃) * f (t₁ - y₁) t₂ (t₃ - y₃)) 0) =
      fun y₁ => f₃ (t₁ + y₁) t₃ * f (t₁ - y₁) t₂ t₃ - f (t₁ + y₁) t₂ t₃ * f₃ (t₁ - y₁) t₃ := by
    ext y₁
    have h := hasDerivAt_shift_mul (a := fun u => f (t₁ + y₁) t₂ u)
      (b := fun u => f (t₁ - y₁) t₂ u) (x := t₃) (y := 0)
      (h3 (t₁ + y₁) (t₃ + 0)) (h3 (t₁ - y₁) (t₃ - 0))
    simpa [add_zero, sub_zero] using h.deriv
  unfold hirotaD1D3
  rw [hinner]
  have ha := hasDerivAt_shift_mul (a := fun u => f₃ u t₃) (b := fun u => f u t₂ t₃)
    (x := t₁) (y := 0) (h13 (t₁ + 0)) (h1 (t₁ - 0))
  have hb := hasDerivAt_shift_mul (a := fun u => f u t₂ t₃) (b := fun u => f₃ u t₃)
    (x := t₁) (y := 0) (h1 (t₁ + 0)) (h13 (t₁ - 0))
  have houter : HasDerivAt
      (fun y₁ => f₃ (t₁ + y₁) t₃ * f (t₁ - y₁) t₂ t₃ - f (t₁ + y₁) t₂ t₃ * f₃ (t₁ - y₁) t₃)
      (2 * f t₁ t₂ t₃ * f₁₃ t₁ - 2 * f₁ t₁ * f₃ t₁ t₃) 0 := by
    convert ha.sub hb using 1
    simp only [add_zero, sub_zero]
    ring
  exact houter.deriv

/-! ### Section 4: Analytic Partial Derivatives of `schurTau` & Main Hirota KP Theorem -/

section SchurDerivatives

variable (p01 p02 p03 p12 p13 p23 : ℂ)

def d1Tau (t₁ _t₂ t₃ : ℂ) : ℂ :=
  p13 + p03 * t₁ + p12 * t₁ + p02 * t₁ ^ 2 + p01 * ((1 / 3 : ℂ) * t₁ ^ 3 - t₃)

def d11Tau (t₁ : ℂ) : ℂ :=
  p03 + p12 + 2 * p02 * t₁ + p01 * t₁ ^ 2

def d111Tau (t₁ : ℂ) : ℂ :=
  2 * p02 + 2 * p01 * t₁

def d1111Tau : ℂ := 2 * p01

def d2Tau (t₂ : ℂ) : ℂ := p03 - p12 + 2 * p01 * t₂

def d22Tau : ℂ := 2 * p01

def d3Tau (t₁ : ℂ) : ℂ := -p02 - p01 * t₁

def d13Tau : ℂ := -p01

lemma hasDerivAt_schurTau_t1 (t₁ t₂ t₃ : ℂ) :
    HasDerivAt (fun x => schurTau p01 p02 p03 p12 p13 p23 x t₂ t₃)
      (d1Tau p01 p02 p03 p12 p13 t₁ t₂ t₃) t₁ := by
  unfold schurTau schurEmpty schur1 schur2 schur11 schur21 schur22 d1Tau
  have hc0 := (hasDerivAt_const t₁ (1 : ℂ)).const_mul p23
  have hc1 := (hasDerivAt_id t₁).const_mul p13
  have hc2 := ((hasDerivAt_const t₁ t₂).add ((hasDerivAt_pow 2 t₁).const_mul (1 / 2 : ℂ))).const_mul p03
  have hc11 := (((hasDerivAt_pow 2 t₁).const_mul (1 / 2 : ℂ)).sub (hasDerivAt_const t₁ t₂)).const_mul p12
  have hc21 := (((hasDerivAt_pow 3 t₁).const_mul (1 / 3 : ℂ)).sub (hasDerivAt_const t₁ t₃)).const_mul p02
  have hc22 := ((((hasDerivAt_pow 4 t₁).const_mul (1 / 12 : ℂ)).add (hasDerivAt_const t₁ (t₂ ^ 2))).sub
    ((hasDerivAt_id t₁).mul_const t₃)).const_mul p01
  convert ((((hc0.add hc1).add hc2).add hc11).add hc21).add hc22 using 1
  · funext x; simp only [Pi.add_apply, Pi.sub_apply, id_eq]
  · norm_num; ring

lemma hasDerivAt_d1Tau (t₁ t₂ t₃ : ℂ) :
    HasDerivAt (fun x => d1Tau p01 p02 p03 p12 p13 x t₂ t₃)
      (d11Tau p01 p02 p03 p12 t₁) t₁ := by
  unfold d1Tau d11Tau
  have h1 := hasDerivAt_const t₁ p13
  have h2 := (hasDerivAt_id t₁).const_mul p03
  have h3 := (hasDerivAt_id t₁).const_mul p12
  have h4 := (hasDerivAt_pow 2 t₁).const_mul p02
  have h5 := (((hasDerivAt_pow 3 t₁).const_mul (1 / 3 : ℂ)).sub (hasDerivAt_const t₁ t₃)).const_mul p01
  convert (((h1.add h2).add h3).add h4).add h5 using 1
  · funext x; simp only [Pi.add_apply, Pi.sub_apply, id_eq]
  · norm_num; ring

lemma hasDerivAt_d11Tau (t₁ : ℂ) :
    HasDerivAt (d11Tau p01 p02 p03 p12) (d111Tau p01 p02 t₁) t₁ := by
  unfold d11Tau d111Tau
  have h := ((hasDerivAt_const t₁ (p03 + p12)).add
    ((hasDerivAt_id t₁).const_mul (2 * p02))).add ((hasDerivAt_pow 2 t₁).const_mul p01)
  convert h using 1
  · funext x; simp only [Pi.add_apply, id_eq]
  · norm_num; ring

lemma hasDerivAt_d111Tau (t₁ : ℂ) :
    HasDerivAt (d111Tau p01 p02) (d1111Tau p01) t₁ := by
  unfold d111Tau d1111Tau
  have h := (hasDerivAt_const t₁ (2 * p02)).add ((hasDerivAt_id t₁).const_mul (2 * p01))
  convert h using 1
  · funext x; simp only [Pi.add_apply, id_eq]
  · ring

lemma hasDerivAt_schurTau_t2 (t₁ t₂ t₃ : ℂ) :
    HasDerivAt (fun y => schurTau p01 p02 p03 p12 p13 p23 t₁ y t₃)
      (d2Tau p01 p03 p12 t₂) t₂ := by
  unfold schurTau schurEmpty schur1 schur2 schur11 schur21 schur22 d2Tau
  have hc0 := (hasDerivAt_const t₂ (1 : ℂ)).const_mul p23
  have hc1 := (hasDerivAt_const t₂ t₁).const_mul p13
  have hc2 := ((hasDerivAt_id t₂).add (hasDerivAt_const t₂ ((1 / 2 : ℂ) * t₁ ^ 2))).const_mul p03
  have hc11 := ((hasDerivAt_const t₂ ((1 / 2 : ℂ) * t₁ ^ 2)).sub (hasDerivAt_id t₂)).const_mul p12
  have hc21 := (hasDerivAt_const t₂ ((1 / 3 : ℂ) * t₁ ^ 3 - t₃)).const_mul p02
  have hc22 := (((hasDerivAt_const t₂ ((1 / 12 : ℂ) * t₁ ^ 4)).add (hasDerivAt_pow 2 t₂)).sub
    (hasDerivAt_const t₂ (t₁ * t₃))).const_mul p01
  convert ((((hc0.add hc1).add hc2).add hc11).add hc21).add hc22 using 1
  · funext y; simp only [Pi.add_apply, Pi.sub_apply, id_eq]
  · norm_num; ring

lemma hasDerivAt_d2Tau (t₂ : ℂ) :
    HasDerivAt (d2Tau p01 p03 p12) (d22Tau p01) t₂ := by
  unfold d2Tau d22Tau
  have h := (hasDerivAt_const t₂ (p03 - p12)).add ((hasDerivAt_id t₂).const_mul (2 * p01))
  convert h using 1
  · funext y; simp only [Pi.add_apply, id_eq]
  · ring

lemma hasDerivAt_schurTau_t3 (t₁ t₂ t₃ : ℂ) :
    HasDerivAt (fun z => schurTau p01 p02 p03 p12 p13 p23 t₁ t₂ z)
      (d3Tau p01 p02 t₁) t₃ := by
  unfold schurTau schurEmpty schur1 schur2 schur11 schur21 schur22 d3Tau
  have hc0 := (hasDerivAt_const t₃ (1 : ℂ)).const_mul p23
  have hc1 := (hasDerivAt_const t₃ t₁).const_mul p13
  have hc2 := (hasDerivAt_const t₃ (t₂ + (1 / 2 : ℂ) * t₁ ^ 2)).const_mul p03
  have hc11 := (hasDerivAt_const t₃ ((1 / 2 : ℂ) * t₁ ^ 2 - t₂)).const_mul p12
  have hc21 := ((hasDerivAt_const t₃ ((1 / 3 : ℂ) * t₁ ^ 3)).sub (hasDerivAt_id t₃)).const_mul p02
  have hc22 := ((hasDerivAt_const t₃ ((1 / 12 : ℂ) * t₁ ^ 4 + t₂ ^ 2)).sub
    ((hasDerivAt_id t₃).const_mul t₁)).const_mul p01
  convert ((((hc0.add hc1).add hc2).add hc11).add hc21).add hc22 using 1
  · funext z; simp only [Pi.add_apply, Pi.sub_apply, id_eq]
  · ring

lemma hasDerivAt_d3Tau (t₁ : ℂ) :
    HasDerivAt (d3Tau p01 p02) (d13Tau p01) t₁ := by
  unfold d3Tau d13Tau
  have h := (hasDerivAt_const t₁ (-p02)).sub ((hasDerivAt_id t₁).const_mul p01)
  convert h using 1
  · funext x; simp only [Pi.sub_apply, id_eq]
  · ring

/-- **Theorem 2 (Master Klein-Quadric Factorization of the Hirota KP Equation):**
For arbitrary Plücker coordinates `(p₀₁, p₀₂, p₀₃, p₁₂, p₁₃, p₂₃) ∈ ℂ⁶`,
`(D₁⁴ - 4 D₁ D₃ + 3 D₂²)(τ · τ)(t₁, t₂, t₃) = 24 * (p₀₁ p₂₃ - p₀₂ p₁₃ + p₀₃ p₁₂)`. -/
theorem hirotaKP_schurTau_eq (t₁ t₂ t₃ : ℂ) :
    hirotaKP (schurTau p01 p02 p03 p12 p13 p23) t₁ t₂ t₃ =
      24 * (p01 * p23 - p02 * p13 + p03 * p12) := by
  unfold hirotaKP
  have hD1 := hirotaD1_four_eq
    (f := schurTau p01 p02 p03 p12 p13 p23)
    (g₁ := fun x => d1Tau p01 p02 p03 p12 p13 x t₂ t₃)
    (g₂ := d11Tau p01 p02 p03 p12)
    (g₃ := d111Tau p01 p02)
    (g₄ := fun _ => d1111Tau p01)
    (t₁ := t₁)
    (fun x => hasDerivAt_schurTau_t1 p01 p02 p03 p12 p13 p23 x t₂ t₃)
    (fun x => hasDerivAt_d1Tau p01 p02 p03 p12 p13 x t₂ t₃)
    (fun x => hasDerivAt_d11Tau p01 p02 p03 p12 x)
    (fun x => hasDerivAt_d111Tau p01 p02 x)
  have hD2 := hirotaD2_two_eq
    (f := schurTau p01 p02 p03 p12 p13 p23)
    (g₁ := d2Tau p01 p03 p12)
    (g₂ := fun _ => d22Tau p01)
    (t₂ := t₂)
    (fun y => hasDerivAt_schurTau_t2 p01 p02 p03 p12 p13 p23 t₁ y t₃)
    (fun y => hasDerivAt_d2Tau p01 p03 p12 y)
  have hD13 := hirotaD1D3_eq
    (f := schurTau p01 p02 p03 p12 p13 p23)
    (f₁ := fun x => d1Tau p01 p02 p03 p12 p13 x t₂ t₃)
    (f₃ := fun x _ => d3Tau p01 p02 x)
    (f₁₃ := fun _ => d13Tau p01)
    (t₁ := t₁) (t₃ := t₃)
    (fun x z => hasDerivAt_schurTau_t3 p01 p02 p03 p12 p13 p23 x t₂ z)
    (fun x => hasDerivAt_schurTau_t1 p01 p02 p03 p12 p13 p23 x t₂ t₃)
    (fun x => hasDerivAt_d3Tau p01 p02 x)
  rw [hD1, hD2, hD13]
  unfold schurTau schurEmpty schur1 schur2 schur11 schur21 schur22
    d1Tau d11Tau d111Tau d1111Tau d2Tau d22Tau d3Tau d13Tau
  ring

/-- **Theorem 3 (Exact Equivalence with the Klein Quadric `𝒬₄`):**
`schurTau` solves the Hirota bilinear KP PDE iff its coordinates lie on `𝒬₄`. -/
theorem hirotaKP_schurTau_eq_zero_iff :
    (∀ t₁ t₂ t₃ : ℂ, hirotaKP (schurTau p01 p02 p03 p12 p13 p23) t₁ t₂ t₃ = 0) ↔
      p01 * p23 - p02 * p13 + p03 * p12 = 0 := by
  constructor
  · intro h
    have h0 := h 0 0 0
    rw [hirotaKP_schurTau_eq] at h0
    exact (mul_eq_zero.mp h0).resolve_left (by norm_num)
  · intro hQ t₁ t₂ t₃
    rw [hirotaKP_schurTau_eq, hQ, mul_zero]

end SchurDerivatives

/-- **Theorem 4 (Main Result — Sato `τ_U` Solves the Hirota Bilinear KP Equation):**
For every 2-plane frame `(v, w)` in `ℂ⁴`, `τ_U(t₁, t₂, t₃) = pluckerCoord (kpMatrix4 t v) (kpMatrix4 t w) 2 3`
satisfies `(D₁⁴ - 4 D₁ D₃ + 3 D₂²)(τ_U · τ_U) = 0` as a direct consequence of `kleinQuadric_relation`. -/
theorem hirotaKP_tauU_eq_zero (v w : C4) (t₁ t₂ t₃ : ℂ) :
    hirotaKP (tauU v w) t₁ t₂ t₃ = 0 := by
  have hfun : tauU v w =
      schurTau (pluckerCoord v w 0 1) (pluckerCoord v w 0 2) (pluckerCoord v w 0 3)
               (pluckerCoord v w 1 2) (pluckerCoord v w 1 3) (pluckerCoord v w 2 3) := by
    funext x y z
    exact tauU_eq_schurTau v w x y z
  rw [hfun, hirotaKP_schurTau_eq, kleinQuadric_relation v w, mul_zero]

end

end Signals.SatoGrassmannian.HirotaKP
