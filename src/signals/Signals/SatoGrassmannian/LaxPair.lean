import Mathlib.Analysis.Calculus.Deriv.Basic
import Mathlib.Analysis.Calculus.Deriv.Mul
import Mathlib.Analysis.Calculus.Deriv.Pow
import Mathlib.Analysis.Calculus.IteratedDeriv.Lemmas
import Mathlib.Analysis.SpecialFunctions.Complex.Log
import Mathlib.Analysis.SpecialFunctions.Trigonometric.DerivHyp
import Signals.SatoGrassmannian.PDESolver

namespace Signals.SatoGrassmannian.LaxPair

open Signals.SatoGrassmannian.PDESolver

noncomputable section

/-! ### Section 1: Zakharov–Shabat Zero-Curvature Equivalence with KP-II -/

/-- Local jet data of `u`, `w`, and a test wave function `ψ` at a point `(x, y, t)`. -/
structure KPJet where
  u : ℂ
  u_x : ℂ
  u_xx : ℂ
  u_xxx : ℂ
  u_y : ℂ
  u_xy : ℂ
  u_xxy : ℂ
  u_yy : ℂ
  u_t : ℂ
  u_xt : ℂ
  u_xxxx : ℂ
  w : ℂ
  w_x : ℂ
  w_xx : ℂ
  w_y : ℂ
  w_xy : ℂ
  ψ : ℂ
  ψ_x : ℂ
  ψ_xx : ℂ
  ψ_xxx : ℂ
  ψ_xxxx : ℂ
  ψ_xxxxx : ℂ

/-- Action of `B₂ = ∂_x² + u` and `B₃ = ∂_x³ + (3/2) u ∂_x + w` on the jet. -/
def B2_of_B3 (J : KPJet) : ℂ :=
  J.ψ_xxxxx + (5 / 2 : ℂ) * J.u * J.ψ_xxx + (3 * J.u_x + J.w) * J.ψ_xx +
  ((3 / 2 : ℂ) * J.u_xx + 2 * J.w_x + (3 / 2 : ℂ) * J.u ^ 2) * J.ψ_x +
  (J.w_xx + J.u * J.w) * J.ψ

def B3_of_B2 (J : KPJet) : ℂ :=
  J.ψ_xxxxx + (5 / 2 : ℂ) * J.u * J.ψ_xxx + (3 * J.u_x + J.w) * J.ψ_xx +
  (3 * J.u_xx + (3 / 2 : ℂ) * J.u ^ 2) * J.ψ_x +
  (J.u_xxx + (3 / 2 : ℂ) * J.u * J.u_x + J.u * J.w) * J.ψ

/-- The Zakharov–Shabat operator commutator `[∂_y - B₂, ∂_t - B₃](ψ) = (B_{2,t} - B_{3,y} + [B₂, B₃])(ψ)`. -/
def zakharovShabatComm (J : KPJet) : ℂ :=
  (J.u_t * J.ψ) - ((3 / 2 : ℂ) * J.u_y * J.ψ_x + J.w_y * J.ψ) + (B2_of_B3 J - B3_of_B2 J)

/-- **Theorem 1.1 (Exact Commutator Collapse):** All terms of order `≥ 2` in `∂_x ψ` cancel identically,
leaving a first-order operator in `ψ_x` and `ψ`. -/
theorem zakharovShabatComm_eq (J : KPJet) :
    zakharovShabatComm J =
      (2 * J.w_x - (3 / 2 : ℂ) * J.u_xx - (3 / 2 : ℂ) * J.u_y) * J.ψ_x +
      (J.u_t - J.w_y + J.w_xx - J.u_xxx - (3 / 2 : ℂ) * J.u * J.u_x) * J.ψ := by
  unfold zakharovShabatComm B2_of_B3 B3_of_B2
  ring

/-- **Theorem 1.2 (Zakharov–Shabat Zero-Curvature Equivalence with KP-II):**
`[∂_y - B₂, ∂_t - B₃] = 0` on all jets `ψ` iff `4 w_x = 3(u_{xx} + u_y)` and
`4 u_t - u_{xxx} - 6 u u_x = 4 w_y - 3 u_{xy}`; differentiating once in `x`
eliminates `w` to yield the KP-II PDE `∂_x(4 u_t - u_{xxx} - 6 u u_x) = 3 u_{yy}`. -/
theorem zakharovShabat_kpII_iff
    (u u_x u_xx u_xxx u_y u_xy u_xxy u_yy u_t u_xt u_xxxx w w_x w_xx w_y w_xy : ℂ) :
    (∀ ψ ψ_x ψ_xx ψ_xxx ψ_xxxx ψ_xxxxx : ℂ,
      zakharovShabatComm ⟨u, u_x, u_xx, u_xxx, u_y, u_xy, u_xxy, u_yy, u_t, u_xt, u_xxxx,
        w, w_x, w_xx, w_y, w_xy, ψ, ψ_x, ψ_xx, ψ_xxx, ψ_xxxx, ψ_xxxxx⟩ = 0) ↔
    (4 * w_x = 3 * (u_xx + u_y) ∧
     u_t - w_y + w_xx - u_xxx - (3 / 2 : ℂ) * u * u_x = 0) := by
  constructor
  · intro h
    have h0 := h 1 0 0 0 0 0
    have h1 := h 0 1 0 0 0 0
    rw [zakharovShabatComm_eq] at h0 h1
    simp only [mul_zero, zero_add, add_zero, mul_one] at h0 h1
    exact ⟨by linear_combination 2 * h1, h0⟩
  · rintro ⟨h1, h2⟩ ψ ψ_x ψ_xx ψ_xxx ψ_xxxx ψ_xxxxx
    rw [zakharovShabatComm_eq]
    have h1' : 2 * w_x - (3 / 2 : ℂ) * u_xx - (3 / 2 : ℂ) * u_y = 0 := by linear_combination h1 / 2
    rw [h1', h2]; ring

/-- Eliminating `w` from the differentiated compatibility relations yields KP-II. -/
theorem kpII_of_zakharovShabat
    {u u_x u_xx u_xxx _u_y u_xy u_xxy u_yy u_t u_xt u_xxxx w_xx w_y w_xy : ℂ}
    (_hCompat : u_t - w_y + w_xx - u_xxx - (3 / 2 : ℂ) * u * u_x = 0)
    (_hDiff1 : 4 * w_xx = 3 * (u_xxx + u_xy))
    (hDiff2 : 4 * w_xy = 3 * (u_xxy + u_yy))
    (hDiff3 : 4 * u_xt - u_xxxx - 6 * (u_x ^ 2 + u * u_xx) = 4 * w_xy - 3 * u_xxy) :
    4 * u_xt - u_xxxx - 6 * (u_x ^ 2 + u * u_xx) = 3 * u_yy := by
  linear_combination hDiff3 + hDiff2

/-! ### Section 2: Analytic 1-Soliton Baker–Akhiezer Wave Function Solving `B₂` and `B₃` -/

/-- Unnormalized 1-soliton Baker–Akhiezer wave function
`ψ_BA(x, y, t; z) = (z - k tanh(k x + k³ t)) exp(z x + z² y + z³ t)`. -/
def bakerAkhiezer1Soliton (k z : ℂ) (x y t : ℝ) : ℂ :=
  (z - k * (Real.tanh (k.re * x + k.re ^ 3 * t) : ℂ)) *
    Complex.exp (z * (x : ℂ) + z ^ 2 * (y : ℂ) + z ^ 3 * (t : ℂ))

/-- Real-wavenumber specialization `k ∈ ℝ`, `z ∈ ℂ` paired with `u(x, t) = 2 k² sech²(k x + k³ t)`
and `w(x, t) = (3/4) u_x = -3 k³ sech²(θ) tanh(θ)`. -/
def baWave (k : ℝ) (z : ℂ) (x y t : ℝ) : ℂ :=
  (z - (k : ℂ) * (Real.tanh (k * x + k ^ 3 * t) : ℂ)) *
    Complex.exp (z * (x : ℂ) + z ^ 2 * (y : ℂ) + z ^ 3 * (t : ℂ))

lemma hasDerivAt_real_tanh (k t r : ℝ) :
    HasDerivAt (fun s : ℝ => Real.tanh (k * s + k ^ 3 * t))
      (k / Real.cosh (k * r + k ^ 3 * t) ^ 2) r := by
  have hθ : HasDerivAt (fun s : ℝ => k * s + k ^ 3 * t) k r := by
    have h := ((hasDerivAt_id r).const_mul k).add (hasDerivAt_const r (k ^ 3 * t))
    convert h using 1
    · funext s; simp only [Pi.add_apply, id_eq]
    · ring
  have hne : Real.cosh (k * r + k ^ 3 * t) ≠ 0 := (Real.cosh_pos _).ne'
  have hdiv : HasDerivAt (fun s : ℝ => Real.sinh (k * s + k ^ 3 * t) / Real.cosh (k * s + k ^ 3 * t))
      ((Real.cosh (k * r + k ^ 3 * t) * k * Real.cosh (k * r + k ^ 3 * t) -
        Real.sinh (k * r + k ^ 3 * t) * (Real.sinh (k * r + k ^ 3 * t) * k)) /
        Real.cosh (k * r + k ^ 3 * t) ^ 2) r :=
    ((Real.hasDerivAt_sinh _).comp r hθ).div ((Real.hasDerivAt_cosh _).comp r hθ) hne
  have hfun : (fun s : ℝ => Real.sinh (k * s + k ^ 3 * t) / Real.cosh (k * s + k ^ 3 * t)) =
      fun s => Real.tanh (k * s + k ^ 3 * t) := by ext s; exact (Real.tanh_eq_sinh_div_cosh _).symm
  rw [hfun] at hdiv
  convert hdiv using 1
  set a := k * r + k ^ 3 * t
  have hid := Real.cosh_sq_sub_sinh_sq a
  field_simp [hne]
  linear_combination -k * hid

/-- **Theorem 1.3 (Analytic Baker–Akhiezer Lax Equations):**
For all `k, x, y, t ∈ ℝ` and `z ∈ ℂ`, `ψ = baWave k z` simultaneously satisfies:
1. `∂_y ψ = (∂_x² + u) ψ` (`B₂` Lax equation), and
2. `∂_t ψ = (∂_x³ + (3/2) u ∂_x + (3/4) u_x) ψ` (`B₃` Lax equation). -/
theorem baWave_lax_equations (k : ℝ) (z : ℂ) (x y t : ℝ) :
    let ψ := baWave k z
    let u : ℂ := (kdvOneSoliton k x t : ℂ)
    let w : ℂ := ((-3 * k ^ 3 * Real.tanh (k * x + k ^ 3 * t) /
      Real.cosh (k * x + k ^ 3 * t) ^ 2 : ℝ) : ℂ)
    deriv (fun s : ℝ => ψ x s t) y =
      iteratedDeriv 2 (fun r : ℝ => ψ r y t) x + u * ψ x y t ∧
    deriv (fun s : ℝ => ψ x y s) t =
      iteratedDeriv 3 (fun r : ℝ => ψ r y t) x +
      (3 / 2 : ℂ) * u * deriv (fun r : ℝ => ψ r y t) x + w * ψ x y t := by
  intro ψ u w
  let θ : ℝ → ℝ → ℝ := fun r s => k * r + k ^ 3 * s
  let E : ℝ → ℝ → ℝ → ℂ := fun r p s => Complex.exp (z * (r : ℂ) + z ^ 2 * (p : ℂ) + z ^ 3 * (s : ℂ))
  let T : ℝ → ℝ → ℂ := fun r s => (Real.tanh (θ r s) : ℂ)
  let S2 : ℝ → ℝ → ℂ := fun r s => ((Real.cosh (θ r s) ^ 2 : ℝ) : ℂ)⁻¹
  have hS2_id : ∀ r s : ℝ, S2 r s + T r s ^ 2 = 1 := fun r s => by
    dsimp [S2, T]
    have hne := (Real.cosh_pos (θ r s)).ne'
    have hR : (Real.cosh (θ r s) ^ 2)⁻¹ + Real.tanh (θ r s) ^ 2 = 1 := by
      rw [Real.tanh_eq_sinh_div_cosh, div_pow]
      have hid := Real.cosh_sq_sub_sinh_sq (θ r s)
      field_simp [hne]; linarith
    exact_mod_cast hR
  have hTx : ∀ r : ℝ, HasDerivAt (fun r' => T r' t) ((k : ℂ) * S2 r t) r := fun r => by
    have h := Complex.ofRealCLM.hasFDerivAt.comp_hasDerivAt r (hasDerivAt_real_tanh k t r)
    convert h using 1
    · funext r'; rfl
    · dsimp [S2, θ]; push_cast; rw [div_eq_mul_inv]
  have hS2x : ∀ r : ℝ, HasDerivAt (fun r' => S2 r' t) (-2 * (k : ℂ) * S2 r t * T r t) r := fun r => by
    have hθ : HasDerivAt (fun r' => θ r' t) k r := by
      have h := ((hasDerivAt_id r).const_mul k).add (hasDerivAt_const r (k ^ 3 * t))
      convert h using 1
      · funext r'; simp only [θ, Pi.add_apply, id_eq]
      · ring
    have hc := (Real.hasDerivAt_cosh _).comp r hθ
    have hp := hc.pow 2
    have hinv := hp.inv (pow_ne_zero 2 (Real.cosh_pos (θ r t)).ne')
    have hC := Complex.ofRealCLM.hasFDerivAt.comp_hasDerivAt r hinv
    convert hC using 1
    · funext r'; dsimp [S2]; simp
    · have hne := (Real.cosh_pos (θ r t)).ne'
      have hR : -(2 * Real.cosh (θ r t) ^ 1 * (Real.sinh (θ r t) * k)) / (Real.cosh (θ r t) ^ 2) ^ 2 =
          -2 * k * (Real.cosh (θ r t) ^ 2)⁻¹ * Real.tanh (θ r t) := by
        rw [Real.tanh_eq_sinh_div_cosh]; field_simp [hne]
      dsimp [S2, T]
      have hC' := congrArg (fun a : ℝ => (a : ℂ)) hR
      simpa using hC'.symm
  have hEx : ∀ r : ℝ, HasDerivAt (fun r' => E r' y t) (z * E r y t) r := fun r => by
    have hlin : HasDerivAt (fun r' : ℝ => z * (r' : ℂ) + z ^ 2 * (y : ℂ) + z ^ 3 * (t : ℂ)) z r := by
      have h := (((Complex.ofRealCLM.hasDerivAt (x := r)).const_mul z).add
        (hasDerivAt_const r (z ^ 2 * (y : ℂ)))).add (hasDerivAt_const r (z ^ 3 * (t : ℂ)))
      convert h using 1
      · funext r'; simp only [Pi.add_apply]; rfl
      · simp only [Complex.ofRealCLM_apply, Complex.ofReal_one]; ring
    convert (Complex.hasDerivAt_exp _).comp r hlin using 1
    · rfl
    · dsimp [E]; ring
  have hψ1 : ∀ r : ℝ, HasDerivAt (fun r' => ψ r' y t)
      ((-(k : ℂ) ^ 2 * S2 r t + z * (z - (k : ℂ) * T r t)) * E r y t) r := fun r => by
    have hf := (hasDerivAt_const r z).sub ((hTx r).const_mul (k : ℂ))
    convert hf.mul (hEx r) using 1
    · funext r'; simp only [ψ, baWave, T, E, θ, Pi.mul_apply, Pi.sub_apply]
    · simp only [Pi.sub_apply]; ring
  have hψ2 : ∀ r : ℝ, HasDerivAt
      (fun r' => (-(k : ℂ) ^ 2 * S2 r' t + z * (z - (k : ℂ) * T r' t)) * E r' y t)
      ((z ^ 2 * (z - (k : ℂ) * T r t) - 2 * (k : ℂ) ^ 2 * S2 r t * (z - (k : ℂ) * T r t)) * E r y t) r := fun r => by
    have hf := ((hS2x r).const_mul (-(k : ℂ) ^ 2)).add
      (((hasDerivAt_const r z).sub ((hTx r).const_mul (k : ℂ))).const_mul z)
    convert hf.mul (hEx r) using 1
    simp only [Pi.add_apply, Pi.sub_apply]; ring
  have hψ3 : HasDerivAt
      (fun r' => (z ^ 2 * (z - (k : ℂ) * T r' t) - 2 * (k : ℂ) ^ 2 * S2 r' t * (z - (k : ℂ) * T r' t)) * E r' y t)
      ((z ^ 3 * (z - (k : ℂ) * T x t) - 3 * z ^ 2 * (k : ℂ) ^ 2 * S2 x t +
        2 * (k : ℂ) ^ 4 * S2 x t ^ 2 +
        6 * z * (k : ℂ) ^ 3 * S2 x t * T x t -
        4 * (k : ℂ) ^ 4 * S2 x t * T x t ^ 2) * E x y t) x := by
    have hf1 := ((hasDerivAt_const x z).sub ((hTx x).const_mul (k : ℂ))).const_mul (z ^ 2)
    have hf2 := ((hS2x x).const_mul (2 * (k : ℂ) ^ 2)).mul
      ((hasDerivAt_const x z).sub ((hTx x).const_mul (k : ℂ)))
    convert (hf1.sub hf2).mul (hEx x) using 1
    simp only [Pi.sub_apply, Pi.mul_apply]; ring
  have hψy : HasDerivAt (fun s : ℝ => ψ x s t) (z ^ 2 * ψ x y t) y := by
    have hlin : HasDerivAt (fun s : ℝ => z * (x : ℂ) + z ^ 2 * (s : ℂ) + z ^ 3 * (t : ℂ)) (z ^ 2) y := by
      have h := ((hasDerivAt_const y (z * (x : ℂ))).add
        ((Complex.ofRealCLM.hasDerivAt (x := y)).const_mul (z ^ 2))).add
        (hasDerivAt_const y (z ^ 3 * (t : ℂ)))
      convert h using 1
      · funext s; simp only [Pi.add_apply]; rfl
      · simp only [Complex.ofRealCLM_apply, Complex.ofReal_one]; ring
    have hEy := (Complex.hasDerivAt_exp _).comp y hlin
    convert hEy.const_mul (z - (k : ℂ) * T x t) using 1
    · funext s; rfl
    · dsimp [ψ, baWave, T, E]; ring
  have hψt : HasDerivAt (fun s : ℝ => ψ x y s)
      ((-(k : ℂ) ^ 4 * S2 x t + z ^ 3 * (z - (k : ℂ) * T x t)) * E x y t) t := by
    have hθt : HasDerivAt (fun s : ℝ => θ x s) (k ^ 3) t := by
      have h := (hasDerivAt_const t (k * x)).add ((hasDerivAt_id t).const_mul (k ^ 3))
      convert h using 1
      · funext s; simp only [θ, Pi.add_apply, id_eq]
      · ring
    have hTt : HasDerivAt (fun s : ℝ => T x s) ((k : ℂ) ^ 3 * S2 x t) t := by
      have hne := (Real.cosh_pos (θ x t)).ne'
      have hdiv : HasDerivAt (fun s : ℝ => Real.sinh (θ x s) / Real.cosh (θ x s))
          (k ^ 3 / Real.cosh (θ x t) ^ 2) t := by
        convert ((Real.hasDerivAt_sinh _).comp t hθt).div
          ((Real.hasDerivAt_cosh _).comp t hθt) hne using 1
        · funext s; rfl
        · simp only [Function.comp_apply]
          set a := θ x t
          have hid := Real.cosh_sq_sub_sinh_sq a
          field_simp [hne]; linear_combination -k ^ 3 * hid
      have hfun : (fun s => Real.sinh (θ x s) / Real.cosh (θ x s)) = fun s => Real.tanh (θ x s) := by
        ext s; exact (Real.tanh_eq_sinh_div_cosh _).symm
      rw [hfun] at hdiv
      have hC := Complex.ofRealCLM.hasFDerivAt.comp_hasDerivAt t hdiv
      convert hC using 1
      · funext s; rfl
      · dsimp [S2]; push_cast; rw [div_eq_mul_inv]
    have hEt : HasDerivAt (fun s : ℝ => E x y s) (z ^ 3 * E x y t) t := by
      have hlin : HasDerivAt (fun s : ℝ => z * (x : ℂ) + z ^ 2 * (y : ℂ) + z ^ 3 * (s : ℂ)) (z ^ 3) t := by
        have h := ((hasDerivAt_const t (z * (x : ℂ))).add
          (hasDerivAt_const t (z ^ 2 * (y : ℂ)))).add
          ((Complex.ofRealCLM.hasDerivAt (x := t)).const_mul (z ^ 3))
        convert h using 1
        · funext s; simp only [Pi.add_apply]; rfl
        · simp only [Complex.ofRealCLM_apply, Complex.ofReal_one]; ring
      convert (Complex.hasDerivAt_exp _).comp t hlin using 1
      · rfl
      · dsimp [E]; ring
    have hf := (hasDerivAt_const t z).sub (hTt.const_mul (k : ℂ))
    convert hf.mul hEt using 1
    · funext s; simp only [ψ, baWave, T, E, θ, Pi.mul_apply, Pi.sub_apply]
    · simp only [Pi.sub_apply]; ring
  have hd1 : deriv (fun r : ℝ => ψ r y t) =
      fun r => (-(k : ℂ) ^ 2 * S2 r t + z * (z - (k : ℂ) * T r t)) * E r y t :=
    funext fun r => (hψ1 r).deriv
  have hd2 : iteratedDeriv 2 (fun r : ℝ => ψ r y t) =
      fun r => (z ^ 2 * (z - (k : ℂ) * T r t) - 2 * (k : ℂ) ^ 2 * S2 r t * (z - (k : ℂ) * T r t)) * E r y t := by
    ext r; rw [iteratedDeriv_succ, iteratedDeriv_one, hd1]; exact (hψ2 r).deriv
  have hd3 : iteratedDeriv 3 (fun r : ℝ => ψ r y t) x =
      (z ^ 3 * (z - (k : ℂ) * T x t) - 3 * z ^ 2 * (k : ℂ) ^ 2 * S2 x t +
        2 * (k : ℂ) ^ 4 * S2 x t ^ 2 +
        6 * z * (k : ℂ) ^ 3 * S2 x t * T x t -
        4 * (k : ℂ) ^ 4 * S2 x t * T x t ^ 2) * E x y t := by
    rw [iteratedDeriv_succ, hd2]; exact hψ3.deriv
  have hu_eq : u = 2 * (k : ℂ) ^ 2 * S2 x t := by
    dsimp [u, kdvOneSoliton, S2, θ]; push_cast; rw [div_eq_mul_inv]
  have hw_eq : w = -3 * (k : ℂ) ^ 3 * S2 x t * T x t := by
    dsimp [w, S2, T, θ]; push_cast; rw [div_eq_mul_inv]; ring
  refine ⟨?_, ?_⟩
  · rw [hψy.deriv, congrFun hd2 x, hu_eq]
    dsimp [ψ, baWave, T, E]; ring
  · rw [hψt.deriv, hd3, congrFun hd1 x, hu_eq, hw_eq]
    dsimp [ψ, baWave, T, E]
    have hid := hS2_id x t
    linear_combination ((k : ℂ) ^ 4 * S2 x t * E x y t) * hid

end

end Signals.SatoGrassmannian.LaxPair
