import Mathlib.Analysis.InnerProductSpace.PiL2
import Mathlib.Analysis.SpecialFunctions.Trigonometric.DerivHyp

open scoped InnerProductSpace BigOperators

namespace Signals.SatoGrassmannian.DualSchubertQFIM

/-- Ambient 6D complex Plücker space `ℂ⁶ ≅ ⋀² ℂ⁴` containing the Klein quadric `𝒬₄ ≅ Gr_ℂ(2, 4)`. -/
abbrev Plucker6 := EuclideanSpace ℂ (Fin 6)

/-- Projective Fubini–Study metric `g_FS(p, v) = ‖v‖² - ‖⟪p, v⟫‖²` on unit vectors `‖p‖ = 1`. -/
noncomputable def fubiniStudy (p v : Plucker6) : ℝ :=
  ‖v‖ ^ 2 - ‖⟪p, v⟫_ℂ‖ ^ 2

/-- Quantum Fisher Information Metric `F(p, v) = 4 g_FS(p, v)`. -/
noncomputable def qfim (p v : Plucker6) : ℝ :=
  4 * fubiniStudy p v

theorem qfim_eq_four_fubiniStudy (p v : Plucker6) :
    qfim p v = 4 * fubiniStudy p v := rfl

/-- Non-negativity of `g_FS` and `QFIM` on unit Plücker vectors via Cauchy–Schwarz. -/
theorem fubiniStudy_nonneg {p : Plucker6} (hp : ‖p‖ = 1) (v : Plucker6) :
    0 ≤ fubiniStudy p v := by
  unfold fubiniStudy
  have hcs := @norm_inner_le_norm ℂ Plucker6 _ _ _ p v
  rw [hp, one_mul] at hcs
  nlinarith [norm_nonneg (⟪p, v⟫_ℂ), norm_nonneg v]

/-- **Theorem 4.1 (Three-Channel Plücker–Madelung–QFIM Kinetic Decomposition):**
For `Ψ = √ρ · p̂` (`ρ > 0`, `‖p̂‖ = 1`) with derivative `dΨ = (dρ / (2√ρ)) p̂ + √ρ dp̂`
and unit-norm tangent condition `Re ⟪p̂, dp̂⟫ = 0`:
`‖dΨ‖² = ρ (Im ⟪p̂, dp̂⟫)² + (dρ)² / (4 ρ) + ρ · (QFIM(p̂, dp̂) / 4)`. -/
theorem three_channel_plucker_madelung_qfim
    {ρ dρ : ℝ} (hρ : 0 < ρ) {p dp : Plucker6}
    (hp : ‖p‖ = 1) (htang : (⟪p, dp⟫_ℂ).re = 0) :
    let dΨ : Plucker6 := (((dρ / (2 * Real.sqrt ρ) : ℝ) : ℂ) • p) + ((Real.sqrt ρ : ℂ) • dp)
    ‖dΨ‖ ^ 2 =
      ρ * (⟪p, dp⟫_ℂ).im ^ 2 +
      dρ ^ 2 / (4 * ρ) +
      ρ * (qfim p dp / 4) := by
  intro dΨ
  have hsqrt_pos : 0 < Real.sqrt ρ := Real.sqrt_pos.mpr hρ
  have hsqrt_sq : Real.sqrt ρ ^ 2 = ρ := Real.sq_sqrt hρ.le
  have hpp : ⟪p, p⟫_ℂ = 1 := by
    rw [inner_self_eq_norm_sq_to_K, hp]; simp
  have hdp_dp : ⟪dp, dp⟫_ℂ = ((‖dp‖ ^ 2 : ℝ) : ℂ) := by
    rw [inner_self_eq_norm_sq_to_K]; norm_cast
  have hcross : ⟪p, dp⟫_ℂ + ⟪dp, p⟫_ℂ = 0 := by
    rw [← inner_conj_symm dp p, Complex.add_conj, htang]; simp
  have hC : (‖dΨ‖ ^ 2 : ℂ) =
      (((dρ ^ 2 / (4 * ρ) + ρ * ‖dp‖ ^ 2 : ℝ)) : ℂ) := by
    have hnorm : (‖dΨ‖ ^ 2 : ℂ) = ⟪dΨ, dΨ⟫_ℂ := by
      rw [inner_self_eq_norm_sq_to_K]; norm_cast
    rw [hnorm]
    let a : ℂ := ((dρ / (2 * Real.sqrt ρ) : ℝ) : ℂ)
    let b : ℂ := (Real.sqrt ρ : ℂ)
    have hdΨ : dΨ = a • p + b • dp := rfl
    rw [hdΨ, inner_add_left, inner_add_right, inner_add_right,
        inner_smul_left, inner_smul_right, inner_smul_left, inner_smul_right,
        inner_smul_left, inner_smul_right, inner_smul_left, inner_smul_right,
        hpp, hdp_dp]
    simp only [a, b, Complex.conj_ofReal, mul_one]
    have hcross_scaled :
        ((dρ / (2 * Real.sqrt ρ) : ℝ) : ℂ) * ((Real.sqrt ρ : ℂ) * ⟪p, dp⟫_ℂ) +
        (Real.sqrt ρ : ℂ) * (((dρ / (2 * Real.sqrt ρ) : ℝ) : ℂ) * ⟪dp, p⟫_ℂ) = 0 := by
      have hfac : ((dρ / (2 * Real.sqrt ρ) : ℝ) : ℂ) * ((Real.sqrt ρ : ℂ) * ⟪p, dp⟫_ℂ) +
          (Real.sqrt ρ : ℂ) * (((dρ / (2 * Real.sqrt ρ) : ℝ) : ℂ) * ⟪dp, p⟫_ℂ) =
          (((dρ / (2 * Real.sqrt ρ) : ℝ) : ℂ) * (Real.sqrt ρ : ℂ)) * (⟪p, dp⟫_ℂ + ⟪dp, p⟫_ℂ) := by ring
      rw [hfac, hcross, mul_zero]
    have h1 : ((dρ / (2 * Real.sqrt ρ) : ℝ) : ℂ) * ((dρ / (2 * Real.sqrt ρ) : ℝ) : ℂ) =
        ((dρ ^ 2 / (4 * ρ) : ℝ) : ℂ) := by
      norm_cast
      have hne : Real.sqrt ρ ≠ 0 := hsqrt_pos.ne'
      field_simp [hne, hρ.ne']
      nlinarith [hsqrt_sq]
    have h2 : (Real.sqrt ρ : ℂ) * ((Real.sqrt ρ : ℂ) * ((‖dp‖ ^ 2 : ℝ) : ℂ)) =
        ((ρ * ‖dp‖ ^ 2 : ℝ) : ℂ) := by
      norm_cast
      rw [← mul_assoc, ← sq, hsqrt_sq]
    push_cast at hcross_scaled h1 h2 ⊢
    linear_combination hcross_scaled + h1 + h2
  have hR : ‖dΨ‖ ^ 2 = dρ ^ 2 / (4 * ρ) + ρ * ‖dp‖ ^ 2 := by exact_mod_cast hC
  have hnorm_inner : ‖⟪p, dp⟫_ℂ‖ ^ 2 = (⟪p, dp⟫_ℂ).im ^ 2 := by
    rw [Complex.sq_norm, Complex.normSq_apply, htang]; ring
  rw [hR, qfim, fubiniStudy, hnorm_inner]
  ring

/-- **Theorem 4.2 (Dual-Schubert `Gr_ℂ(2, 4) × Gr_ℂ(2, 4)∨` Six-Channel Identity):**
Summing primal (`Ψ₊`) and dual (`Ψ₋`) Plücker spinors splits total kinetic energy
orthogonally into primal + dual hydrodynamic, Fisher, and QFIM channels. -/
theorem dual_schubert_six_channel_decomposition
    {ρ₁ dρ₁ ρ₂ dρ₂ : ℝ} (hρ₁ : 0 < ρ₁) (hρ₂ : 0 < ρ₂)
    {p₁ dp₁ p₂ dp₂ : Plucker6}
    (hp₁ : ‖p₁‖ = 1) (hp₂ : ‖p₂‖ = 1)
    (ht₁ : (⟪p₁, dp₁⟫_ℂ).re = 0) (ht₂ : (⟪p₂, dp₂⟫_ℂ).re = 0) :
    let dΨ₁ : Plucker6 := (((dρ₁ / (2 * Real.sqrt ρ₁) : ℝ) : ℂ) • p₁) + ((Real.sqrt ρ₁ : ℂ) • dp₁)
    let dΨ₂ : Plucker6 := (((dρ₂ / (2 * Real.sqrt ρ₂) : ℝ) : ℂ) • p₂) + ((Real.sqrt ρ₂ : ℂ) • dp₂)
    ‖dΨ₁‖ ^ 2 + ‖dΨ₂‖ ^ 2 =
      (ρ₁ * (⟪p₁, dp₁⟫_ℂ).im ^ 2 + ρ₂ * (⟪p₂, dp₂⟫_ℂ).im ^ 2) +
      (dρ₁ ^ 2 / (4 * ρ₁) + dρ₂ ^ 2 / (4 * ρ₂)) +
      (ρ₁ * (qfim p₁ dp₁ / 4) + ρ₂ * (qfim p₂ dp₂ / 4)) := by
  intro dΨ₁ dΨ₂
  rw [three_channel_plucker_madelung_qfim hρ₁ hp₁ ht₁,
      three_channel_plucker_madelung_qfim hρ₂ hp₂ ht₂]
  ring

/-- **Theorem 4.3 (Exact Sharoglazova–Klaers Evanescent Speed Law from Three-Channel QFIM):**
For the coupled-waveguide stationary evanescent state `Ψ(x) = e^{-κ̄ x} (cosh(δκ x), sinh(δκ x))`
embedded into `Plucker6` (`κ_± = √(2m(|E_kin| ∓ ℏ J₀)) / ℏ`, `κ̄ = (κ₋ + κ₊)/2`, `δκ = (κ₋ - κ₊)/2`):
1. Channel 1 (Bohmian phase velocity `v_S`) vanishes identically for all `x ∈ ℝ`.
2. Channel 2 (scalar Fisher / osmotic speed²) equals `(ℏ/m)² (-κ̄ + δκ tanh(2 δκ x))²`.
3. Channel 3 (projective QFIM speed²) equals `(ℏ/m)² (δκ)² / cosh²(2 δκ x) > 0` (`F_{xx}(0) = 4 δκ²`).
4. Total effective speed² obeys `v_eff²(x) = (2/m)(|E_kin| - ℏ J₀ tanh(2 δκ x))`,
   yielding `v_eff²(0) = 2 |E_kin| / m` identically at injection `x = 0`. -/
theorem sharoglazova_klaers_evanescent_speed_law
    {ℏ m E_abs J₀ κ_plus κ_minus : ℝ} (hℏ : 0 < ℏ) (hm : 0 < m)
    (hkp : κ_plus ^ 2 = 2 * m * (E_abs - ℏ * J₀) / ℏ ^ 2)
    (hkm : κ_minus ^ 2 = 2 * m * (E_abs + ℏ * J₀) / ℏ ^ 2) (x : ℝ) :
    let κbar : ℝ := (κ_minus + κ_plus) / 2
    let δκ : ℝ := (κ_minus - κ_plus) / 2
    let ρ : ℝ := Real.exp (-2 * κbar * x) * Real.cosh (2 * δκ * x)
    let dρ : ℝ := 2 * ρ * (-κbar + δκ * Real.tanh (2 * δκ * x))
    let r : ℝ := Real.sqrt (Real.cosh (2 * δκ * x))
    let p : Plucker6 := WithLp.toLp 2 (fun i : Fin 6 =>
      if i = 0 then ((Real.cosh (δκ * x) / r : ℝ) : ℂ)
      else if i = 1 then ((Real.sinh (δκ * x) / r : ℝ) : ℂ)
      else 0)
    let dp : Plucker6 := WithLp.toLp 2 (fun i : Fin 6 =>
      if i = 0 then ((-(δκ * Real.sinh (δκ * x)) / (r * Real.cosh (2 * δκ * x)) : ℝ) : ℂ)
      else if i = 1 then (((δκ * Real.cosh (δκ * x)) / (r * Real.cosh (2 * δκ * x)) : ℝ) : ℂ)
      else 0)
    ‖p‖ = 1 ∧
    (⟪p, dp⟫_ℂ) = 0 ∧
    fubiniStudy p dp = δκ ^ 2 / Real.cosh (2 * δκ * x) ^ 2 ∧
    (ℏ / m) ^ 2 * ((⟪p, dp⟫_ℂ).im ^ 2 + (dρ / (2 * ρ)) ^ 2 + qfim p dp / 4) =
      (2 / m) * (E_abs - ℏ * J₀ * Real.tanh (2 * δκ * x)) := by
  intro κbar δκ ρ dρ r p dp
  have hC2_pos : 0 < Real.cosh (2 * δκ * x) := Real.cosh_pos _
  have hC2_ne : Real.cosh (2 * δκ * x) ≠ 0 := hC2_pos.ne'
  have hr_pos : 0 < r := Real.sqrt_pos.mpr hC2_pos
  have hr_sq : r ^ 2 = Real.cosh (2 * δκ * x) := Real.sq_sqrt hC2_pos.le
  have hρ_pos : 0 < ρ := mul_pos (Real.exp_pos _) hC2_pos
  have hcosh2 : Real.cosh (δκ * x) ^ 2 + Real.sinh (δκ * x) ^ 2 = Real.cosh (2 * δκ * x) := by
    rw [show 2 * δκ * x = δκ * x + δκ * x by ring, Real.cosh_add]; ring
  have hp_norm_sq : ‖p‖ ^ 2 = 1 := by
    rw [EuclideanSpace.norm_sq_eq]
    simp only [Fin.sum_univ_six, p, Fin.isValue, ↓reduceIte,
      Fin.reduceEq, Complex.norm_real, Real.norm_eq_abs, sq_abs, norm_zero, zero_pow two_ne_zero,
      add_zero]
    rw [div_pow, div_pow, ← add_div, hcosh2, hr_sq, div_self hC2_ne]
  have hp_norm : ‖p‖ = 1 := by nlinarith [norm_nonneg p]
  have hinner0 : ⟪p, dp⟫_ℂ = 0 := by
    rw [PiLp.inner_apply]
    simp only [Fin.sum_univ_six, p, dp, Fin.isValue, ↓reduceIte,
      Fin.reduceEq, RCLike.inner_apply, Complex.conj_ofReal, zero_mul, add_zero]
    norm_cast
    ring
  have hgFS : fubiniStudy p dp = δκ ^ 2 / Real.cosh (2 * δκ * x) ^ 2 := by
    unfold fubiniStudy
    rw [hinner0, norm_zero, zero_pow two_ne_zero, sub_zero, EuclideanSpace.norm_sq_eq]
    simp only [Fin.sum_univ_six, dp, Fin.isValue, ↓reduceIte,
      Fin.reduceEq, Complex.norm_real, Real.norm_eq_abs, sq_abs, norm_zero, zero_pow two_ne_zero,
      add_zero]
    rw [div_pow, div_pow, ← add_div]
    calc ((-(δκ * Real.sinh (δκ * x))) ^ 2 + (δκ * Real.cosh (δκ * x)) ^ 2) /
            (r * Real.cosh (2 * δκ * x)) ^ 2
        = (δκ ^ 2 * (Real.cosh (δκ * x) ^ 2 + Real.sinh (δκ * x) ^ 2)) /
            (r ^ 2 * Real.cosh (2 * δκ * x) ^ 2) := by ring
      _ = (δκ ^ 2 * Real.cosh (2 * δκ * x)) /
            (Real.cosh (2 * δκ * x) * Real.cosh (2 * δκ * x) ^ 2) := by rw [hcosh2, hr_sq]
      _ = δκ ^ 2 / Real.cosh (2 * δκ * x) ^ 2 := by field_simp [hC2_ne]
  have hsum_sq : κbar ^ 2 + δκ ^ 2 = 2 * m * E_abs / ℏ ^ 2 := by
    dsimp [κbar, δκ]
    have h1 : ((κ_minus + κ_plus) / 2) ^ 2 + ((κ_minus - κ_plus) / 2) ^ 2 =
        (κ_minus ^ 2 + κ_plus ^ 2) / 2 := by ring
    rw [h1, hkm, hkp]; ring
  have hprod : κbar * δκ = m * J₀ / ℏ := by
    dsimp [κbar, δκ]
    have h1 : ((κ_minus + κ_plus) / 2) * ((κ_minus - κ_plus) / 2) =
        (κ_minus ^ 2 - κ_plus ^ 2) / 4 := by ring
    rw [h1, hkm, hkp]; field_simp [hℏ.ne']; ring
  have hTanh_id : Real.tanh (2 * δκ * x) ^ 2 + 1 / Real.cosh (2 * δκ * x) ^ 2 = 1 := by
    rw [Real.tanh_eq_sinh_div_cosh, div_pow]
    have hid := Real.cosh_sq_sub_sinh_sq (2 * δκ * x)
    field_simp [hC2_ne]; linarith
  refine ⟨hp_norm, hinner0, hgFS, ?_⟩
  rw [hinner0, Complex.zero_im, zero_pow two_ne_zero, zero_add, qfim, hgFS]
  have hdρ_simp : dρ / (2 * ρ) = -κbar + δκ * Real.tanh (2 * δκ * x) := by
    dsimp [dρ]; field_simp [hρ_pos.ne']
  rw [hdρ_simp]
  have hinner_sum : (-κbar + δκ * Real.tanh (2 * δκ * x)) ^ 2 +
      4 * (δκ ^ 2 / Real.cosh (2 * δκ * x) ^ 2) / 4 =
      (κbar ^ 2 + δκ ^ 2) - 2 * (κbar * δκ) * Real.tanh (2 * δκ * x) := by
    linear_combination (δκ ^ 2) * hTanh_id
  rw [hinner_sum, hsum_sq, hprod]
  field_simp [hℏ.ne', hm.ne']

end Signals.SatoGrassmannian.DualSchubertQFIM
