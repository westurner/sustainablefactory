import Mathlib.Analysis.InnerProductSpace.PiL2
import Mathlib.Analysis.InnerProductSpace.ProdL2
import Mathlib.Analysis.Calculus.Deriv.Basic
import Mathlib.Analysis.Calculus.Deriv.Mul
import Mathlib.Analysis.Calculus.IteratedDeriv.Lemmas
import Mathlib.Analysis.SpecialFunctions.Trigonometric.DerivHyp
import Mathlib.Data.Matrix.Basic
import Signals.SatoGrassmannian.KPFlow
import Signals.SatoGrassmannian.LaxPair

open scoped InnerProductSpace

namespace Signals.SatoGrassmannian.AKNS

open Signals.SatoGrassmannian Signals.SatoGrassmannian.CircleL2
open Signals.SatoGrassmannian.KPFlow Signals.SatoGrassmannian.LaxPair

/-! ### Section 1: 2-Component Polarized Hilbert Space `L²(S¹, ℂ²)` & Pauli Loop Flow -/

/-- Two-component loop Hilbert space `H⁽²⁾ = L²(S¹, ℂ) ⊕ L²(S¹, ℂ)` (`WithLp 2`). -/
noncomputable abbrev HCircle2 := WithLp 2 (HCircle × HCircle)

private noncomputable def toProdCLE : HCircle2 ≃L[ℂ] (HCircle × HCircle) :=
  WithLp.prodContinuousLinearEquiv 2 ℂ HCircle HCircle

/-- Positive Hardy subspace `H₊⁽²⁾ = H₊ × H₊ ≤ H⁽²⁾`. -/
noncomputable def hardyPlus2 : Submodule ℂ HCircle2 where
  carrier := { v | v.ofLp.1 ∈ hardyPlus ∧ v.ofLp.2 ∈ hardyPlus }
  add_mem' ha hb := ⟨hardyPlus.add_mem ha.1 hb.1, hardyPlus.add_mem ha.2 hb.2⟩
  zero_mem' := ⟨hardyPlus.zero_mem, hardyPlus.zero_mem⟩
  smul_mem' c _ ha := ⟨hardyPlus.smul_mem c ha.1, hardyPlus.smul_mem c ha.2⟩

/-- Negative frequency subspace `H₋⁽²⁾ = (H₊⁽²⁾)ᗮ = H₋ × H₋`. -/
noncomputable def hardyMinus2 : Submodule ℂ HCircle2 := hardyPlus2ᗮ

lemma mem_hardyMinus2_iff (v : HCircle2) :
    v ∈ hardyMinus2 ↔ v.ofLp.1 ∈ hardyMinus ∧ v.ofLp.2 ∈ hardyMinus := by
  constructor
  · intro hv
    refine ⟨fun x hx => ?_, fun y hy => ?_⟩
    · have h0 := hv (WithLp.toLp 2 (x, (0 : HCircle))) ⟨hx, hardyPlus.zero_mem⟩
      simpa [WithLp.prod_inner_apply] using h0
    · have h0 := hv (WithLp.toLp 2 ((0 : HCircle), y)) ⟨hardyPlus.zero_mem, hy⟩
      simpa [WithLp.prod_inner_apply] using h0
  · rintro ⟨h1, h2⟩ u hu
    rw [WithLp.prod_inner_apply, h1 u.ofLp.1 hu.1, h2 u.ofLp.2 hu.2, add_zero]

/-- **Theorem 2.1 (2-Component Polarized Hilbert Space):** `L²(S¹, ℂ²) = H₊⁽²⁾ ⊕ H₋⁽²⁾`. -/
noncomputable def aknsPolarization : PolarizedHilbertSpace ℂ HCircle2 where
  HPlus := hardyPlus2
  HMinus := hardyMinus2
  complete_HPlus := by
    have hclosed : IsClosed (hardyPlus2 : Set HCircle2) := by
      have heq : (hardyPlus2 : Set HCircle2) =
          (fun v : HCircle2 => (toProdCLE v).1) ⁻¹' (hardyPlus : Set HCircle) ∩
          (fun v : HCircle2 => (toProdCLE v).2) ⁻¹' (hardyPlus : Set HCircle) := rfl
      rw [heq]
      exact (hardyPlus_isClosed.preimage (continuous_fst.comp toProdCLE.continuous)).inter
        (hardyPlus_isClosed.preimage (continuous_snd.comp toProdCLE.continuous))
    exact hclosed.completeSpace_coe
  complete_HMinus := hardyPlus2.isClosed_orthogonal.completeSpace_coe
  ortho_eq := rfl

/-- Pauli-`σ₃` diagonal loop flow `diag(kpFlow t, kpFlow (-t))` on `L²(S¹, ℂ²)`. -/
noncomputable def aknsFlowCLE (t : KPTime) : HCircle2 ≃L[ℂ] HCircle2 where
  toLinearEquiv :=
    { toFun := fun v => WithLp.toLp 2 ((kpFlow t).1 v.ofLp.1, (kpFlow (-t)).1 v.ofLp.2)
      invFun := fun v => WithLp.toLp 2 ((kpFlow (-t)).1 v.ofLp.1, (kpFlow t).1 v.ofLp.2)
      left_inv := fun v => by
        apply toProdCLE.injective
        apply Prod.ext
        · change (kpFlow (-t) * kpFlow t).1 v.ofLp.1 = v.ofLp.1
          rw [← kpFlow_add, neg_add_cancel, kpFlow_zero]; rfl
        · change (kpFlow t * kpFlow (-t)).1 v.ofLp.2 = v.ofLp.2
          rw [← kpFlow_add, add_neg_cancel, kpFlow_zero]; rfl
      right_inv := fun v => by
        apply toProdCLE.injective
        apply Prod.ext
        · change (kpFlow t * kpFlow (-t)).1 v.ofLp.1 = v.ofLp.1
          rw [← kpFlow_add, add_neg_cancel, kpFlow_zero]; rfl
        · change (kpFlow (-t) * kpFlow t).1 v.ofLp.2 = v.ofLp.2
          rw [← kpFlow_add, neg_add_cancel, kpFlow_zero]; rfl
      map_add' := fun u v => by
        apply toProdCLE.injective
        apply Prod.ext
        · exact map_add (kpFlow t).1 u.ofLp.1 v.ofLp.1
        · exact map_add (kpFlow (-t)).1 u.ofLp.2 v.ofLp.2
      map_smul' := fun c v => by
        apply toProdCLE.injective
        apply Prod.ext
        · exact map_smul (kpFlow t).1 c v.ofLp.1
        · exact map_smul (kpFlow (-t)).1 c v.ofLp.2 }
  continuous_toFun :=
    toProdCLE.symm.continuous.comp
      (((kpFlow t).1.continuous.comp (continuous_fst.comp toProdCLE.continuous)).prodMk
        ((kpFlow (-t)).1.continuous.comp (continuous_snd.comp toProdCLE.continuous)))
  continuous_invFun :=
    toProdCLE.symm.continuous.comp
      (((kpFlow (-t)).1.continuous.comp (continuous_fst.comp toProdCLE.continuous)).prodMk
        ((kpFlow t).1.continuous.comp (continuous_snd.comp toProdCLE.continuous)))

/-- **Theorem 2.2 (AKNS Loop Group Membership & Virtual Dimension Conservation):**
The Pauli-`σ₃` loop flow `g_AKNS(t) = exp(∑ t_n z^n σ₃)` preserves `H₊⁽²⁾`, lies in
`GL_res(L²(S¹, ℂ²))`, and has Fredholm index `0`. -/
noncomputable def aknsFlowGLRes (t : KPTime) : GLRes aknsPolarization :=
  ⟨aknsFlowCLE t, by
    let π₁ : aknsPolarization.HMinus →L[ℂ] hardyPolarization.HMinus :=
      { toLinearMap :=
          { toFun := fun v => ⟨v.1.ofLp.1, ((mem_hardyMinus2_iff v.1).mp v.2).1⟩
            map_add' := fun _ _ => rfl
            map_smul' := fun _ _ => rfl }
        cont := (continuous_fst.comp (toProdCLE.continuous.comp continuous_subtype_val)).subtype_mk _ }
    let π₂ : aknsPolarization.HMinus →L[ℂ] hardyPolarization.HMinus :=
      { toLinearMap :=
          { toFun := fun v => ⟨v.1.ofLp.2, ((mem_hardyMinus2_iff v.1).mp v.2).2⟩
            map_add' := fun _ _ => rfl
            map_smul' := fun _ _ => rfl }
        cont := (continuous_snd.comp (toProdCLE.continuous.comp continuous_subtype_val)).subtype_mk _ }
    let j₁ : hardyPolarization.HPlus →L[ℂ] aknsPolarization.HPlus :=
      { toLinearMap :=
          { toFun := fun x => ⟨WithLp.toLp 2 (x.1, 0), ⟨x.2, hardyPlus.zero_mem⟩⟩
            map_add' := fun _ _ => by
              apply Subtype.ext; apply toProdCLE.injective; apply Prod.ext <;> simp [toProdCLE]
            map_smul' := fun _ _ => by
              apply Subtype.ext; apply toProdCLE.injective; apply Prod.ext <;> simp [toProdCLE] }
        cont := (toProdCLE.symm.continuous.comp (continuous_subtype_val.prodMk continuous_const)).subtype_mk _ }
    let j₂ : hardyPolarization.HPlus →L[ℂ] aknsPolarization.HPlus :=
      { toLinearMap :=
          { toFun := fun y => ⟨WithLp.toLp 2 (0, y.1), ⟨hardyPlus.zero_mem, y.2⟩⟩
            map_add' := fun _ _ => by
              apply Subtype.ext; apply toProdCLE.injective; apply Prod.ext <;> simp [toProdCLE]
            map_smul' := fun _ _ => by
              apply Subtype.ext; apply toProdCLE.injective; apply Prod.ext <;> simp [toProdCLE] }
        cont := (toProdCLE.symm.continuous.comp (continuous_const.prodMk continuous_subtype_val)).subtype_mk _ }
    have hPM_eq : blockPM aknsPolarization (aknsFlowCLE t : HCircle2 →L[ℂ] HCircle2) =
        j₁.comp ((blockPM hardyPolarization ((kpFlow t).1 : HCircle →L[ℂ] HCircle)).comp π₁) +
        j₂.comp ((blockPM hardyPolarization ((kpFlow (-t)).1 : HCircle →L[ℂ] HCircle)).comp π₂) := by
      apply ContinuousLinearMap.ext; intro v
      apply Subtype.ext
      let x : HCircle2 := aknsFlowCLE t v.1
      let y : HCircle2 :=
        ((j₁ ((blockPM hardyPolarization ((kpFlow t).1 : HCircle →L[ℂ] HCircle)) (π₁ v)) +
          j₂ ((blockPM hardyPolarization ((kpFlow (-t)).1 : HCircle →L[ℂ] HCircle)) (π₂ v)) :
            aknsPolarization.HPlus) : HCircle2)
      have hmem_rhs : y ∈ aknsPolarization.HPlus := (j₁ _ + j₂ _).2
      have hsub : x - y ∈ aknsPolarization.HPlusᗮ := by
        intro u hu
        rw [WithLp.prod_inner_apply]
        have h1 := Submodule.sub_starProjection_mem_orthogonal ((kpFlow t).1 v.1.ofLp.1) (K := hardyPlus) u.ofLp.1 hu.1
        have h2 := Submodule.sub_starProjection_mem_orthogonal ((kpFlow (-t)).1 v.1.ofLp.2) (K := hardyPlus) u.ofLp.2 hu.2
        change ⟪u.ofLp.1, (kpFlow t).1 v.1.ofLp.1 - ((hardyPlus.starProjection ((kpFlow t).1 v.1.ofLp.1)) + 0)⟫_ℂ +
          ⟪u.ofLp.2, (kpFlow (-t)).1 v.1.ofLp.2 - (0 + (hardyPlus.starProjection ((kpFlow (-t)).1 v.1.ofLp.2)))⟫_ℂ = 0
        simp only [add_zero, zero_add]
        rw [h1, h2, add_zero]
      have hdiff_mem : y - (aknsPolarization.HPlus.orthogonalProjectionOnto x : HCircle2) ∈ aknsPolarization.HPlus :=
        aknsPolarization.HPlus.sub_mem hmem_rhs (aknsPolarization.HPlus.orthogonalProjectionOnto x).2
      have hdiff_orth : y - (aknsPolarization.HPlus.orthogonalProjectionOnto x : HCircle2) ∈ aknsPolarization.HPlusᗮ := by
        have hsub_eq : y - (aknsPolarization.HPlus.orthogonalProjectionOnto x : HCircle2) =
            (x - (aknsPolarization.HPlus.orthogonalProjectionOnto x : HCircle2)) - (x - y) := by abel
        rw [hsub_eq]
        exact aknsPolarization.HPlusᗮ.sub_mem (Submodule.sub_starProjection_mem_orthogonal x) hsub
      have hzero : y - (aknsPolarization.HPlus.orthogonalProjectionOnto x : HCircle2) = 0 :=
        inner_self_eq_zero.mp (hdiff_orth _ hdiff_mem)
      exact (sub_eq_zero.mp hzero).symm
    have hMP_zero : blockMP aknsPolarization (aknsFlowCLE t : HCircle2 →L[ℂ] HCircle2) = 0 := by
      apply ContinuousLinearMap.ext; intro v
      have hmem : aknsFlowCLE t v.1 ∈ aknsPolarization.HPlus :=
        ⟨kpFlow_mem_hardyPlus t v.2.1, kpFlow_mem_hardyPlus (-t) v.2.2⟩
      apply Subtype.ext
      change (aknsPolarization.HMinus.orthogonalProjectionOnto (aknsFlowCLE t v.1) : HCircle2) = 0
      rw [← inner_self_eq_zero (𝕜 := ℂ)]
      have horth := Submodule.sub_starProjection_mem_orthogonal (K := aknsPolarization.HMinus) (aknsFlowCLE t v.1)
      have hmemM := (aknsPolarization.HMinus.orthogonalProjectionOnto (aknsFlowCLE t v.1)).2
      have h0 : ⟪(aknsPolarization.HMinus.orthogonalProjectionOnto (aknsFlowCLE t v.1) : HCircle2),
          aknsFlowCLE t v.1 - (aknsPolarization.HMinus.orthogonalProjectionOnto (aknsFlowCLE t v.1) : HCircle2)⟫_ℂ = 0 :=
        horth _ hmemM
      have h1 : ⟪(aknsPolarization.HMinus.orthogonalProjectionOnto (aknsFlowCLE t v.1) : HCircle2),
          aknsFlowCLE t v.1⟫_ℂ = 0 := by
        rw [← inner_conj_symm]
        have hM : (aknsPolarization.HMinus.orthogonalProjectionOnto (aknsFlowCLE t v.1) : HCircle2) ∈
            aknsPolarization.HPlusᗮ := hmemM
        rw [hM _ hmem, map_zero]
      rw [inner_sub_right, h1, zero_sub, neg_eq_zero] at h0
      exact h0
    refine ⟨?_, by rw [hMP_zero]; exact isCompactOperator_zero⟩
    rw [hPM_eq]
    exact (((kpFlow t).2.1.comp_clm π₁).clm_comp j₁).add (((kpFlow (-t)).2.1.comp_clm π₂).clm_comp j₂)⟩

theorem glResIndex_aknsFlow (t : KPTime) :
    glResIndex aknsPolarization (aknsFlowGLRes t) = 0 := by
  let ePlus2 : aknsPolarization.HPlus ≃L[ℂ] aknsPolarization.HPlus :=
    { toLinearEquiv :=
        { toFun := fun v => ⟨aknsFlowCLE t v.1, ⟨kpFlow_mem_hardyPlus t v.2.1, kpFlow_mem_hardyPlus (-t) v.2.2⟩⟩
          invFun := fun v => ⟨(aknsFlowCLE t).symm v.1, ⟨kpFlow_mem_hardyPlus (-t) v.2.1,
            kpFlow_mem_hardyPlus t v.2.2⟩⟩
          left_inv := fun v => by apply Subtype.ext; exact (aknsFlowCLE t).symm_apply_apply v.1
          right_inv := fun v => by apply Subtype.ext; exact (aknsFlowCLE t).apply_symm_apply v.1
          map_add' := fun _ _ => by apply Subtype.ext; exact map_add (aknsFlowCLE t) _ _
          map_smul' := fun _ _ => by apply Subtype.ext; exact map_smul (aknsFlowCLE t) _ _ }
      continuous_toFun := ((aknsFlowCLE t).continuous.comp continuous_subtype_val).subtype_mk _
      continuous_invFun := ((aknsFlowCLE t).symm.continuous.comp continuous_subtype_val).subtype_mk _ }
  have hblk : blockPP aknsPolarization (aknsFlowCLE t : HCircle2 →L[ℂ] HCircle2) =
      (ePlus2 : aknsPolarization.HPlus →L[ℂ] aknsPolarization.HPlus) := by
    apply ContinuousLinearMap.ext; intro v
    exact Submodule.orthogonalProjectionOnto_mem_subspace_eq_self (ePlus2 v)
  unfold glResIndex
  change fredholmIndex (blockPP aknsPolarization (aknsFlowCLE t : HCircle2 →L[ℂ] HCircle2)) = 0
  rw [hblk]; exact fredholmIndex_of_equiv ePlus2

/-! ### Section 2: 2×2 AKNS Zero-Curvature Equation `∂_t U - ∂_x V + [U, V] = 0` -/

/-- Spectral Lax matrix `U(λ) = [[-iλ, q], [r, iλ]]`. -/
def aknsU (q r lam : ℂ) : Matrix (Fin 2) (Fin 2) ℂ :=
  !![-Complex.I * lam, q; r, Complex.I * lam]

/-- Time-evolution Lax matrix `V(λ) = [[-2iλ² - iqr, 2λq + i q_x], [2λr - i r_x, 2iλ² + iqr]]`. -/
def aknsV (q q_x r r_x lam : ℂ) : Matrix (Fin 2) (Fin 2) ℂ :=
  !![-2 * Complex.I * lam ^ 2 - Complex.I * q * r, 2 * lam * q + Complex.I * q_x;
     2 * lam * r - Complex.I * r_x, 2 * Complex.I * lam ^ 2 + Complex.I * q * r]

/-- **Theorem 2.3 (AKNS Zero-Curvature Equivalence):**
`U_t - V_x + U V - V U = 0` holds for all spectral parameters `λ ∈ ℂ` if and only if
`(q, r)` solves the coupled AKNS / 1D cubic NLS hierarchy:
`i q_t + q_{xx} - 2 q² r = 0` and `-i r_t + r_{xx} - 2 r² q = 0`. -/
theorem akns_zero_curvature_iff (q q_x q_xx q_t r r_x r_xx r_t : ℂ) :
    let Ut : Matrix (Fin 2) (Fin 2) ℂ := !![0, q_t; r_t, 0]
    let Vx : ℂ → Matrix (Fin 2) (Fin 2) ℂ := fun lam =>
      !![-Complex.I * (q_x * r + q * r_x), 2 * lam * q_x + Complex.I * q_xx;
         2 * lam * r_x - Complex.I * r_xx, Complex.I * (q_x * r + q * r_x)]
    (∀ lam : ℂ, Ut - Vx lam + aknsU q r lam * aknsV q q_x r r_x lam -
      aknsV q q_x r r_x lam * aknsU q r lam = 0) ↔
    (Complex.I * q_t + q_xx - 2 * q ^ 2 * r = 0 ∧
     -Complex.I * r_t + r_xx - 2 * r ^ 2 * q = 0) := by
  intro Ut Vx
  have hentries : ∀ lam : ℂ,
      Ut - Vx lam + aknsU q r lam * aknsV q q_x r r_x lam - aknsV q q_x r r_x lam * aknsU q r lam =
      !![0, -Complex.I * (Complex.I * q_t + q_xx - 2 * q ^ 2 * r);
         Complex.I * (-Complex.I * r_t + r_xx - 2 * r ^ 2 * q), 0] := by
    intro lam
    ext i j
    fin_cases i <;> fin_cases j <;>
      simp [Ut, Vx, aknsU, aknsV] <;>
      ring_nf <;> simp [Complex.I_sq]
  constructor
  · intro h
    have h0 := h 0
    rw [hentries 0] at h0
    have h01 : -Complex.I * (Complex.I * q_t + q_xx - 2 * q ^ 2 * r) = 0 := by
      simpa using congrFun (congrFun h0 0) 1
    have h10 : Complex.I * (-Complex.I * r_t + r_xx - 2 * r ^ 2 * q) = 0 := by
      simpa using congrFun (congrFun h0 1) 0
    exact ⟨(mul_eq_zero.mp h01).resolve_left (neg_ne_zero.mpr Complex.I_ne_zero),
           (mul_eq_zero.mp h10).resolve_left Complex.I_ne_zero⟩
  · rintro ⟨hq, hr⟩ lam
    rw [hentries lam, hq, hr]
    ext i j; fin_cases i <;> fin_cases j <;> simp

/-! ### Section 3: Exact Focusing Bright Soliton & Defocusing (1D GPE) Dark Soliton -/

/-- Focusing 1D cubic NLS bright soliton `q(x, t) = A sech(A x) exp(i A² t)`. -/
noncomputable def brightSoliton (A x t : ℝ) : ℂ :=
  ((A / Real.cosh (A * x) : ℝ) : ℂ) * Complex.exp (Complex.I * ((A ^ 2 * t : ℝ) : ℂ))

/-- Defocusing 1D cubic NLS / 1D GPE dark soliton `q(x, t) = A tanh(A x) exp(-2 i A² t)`. -/
noncomputable def darkSoliton (A x t : ℝ) : ℂ :=
  ((A * Real.tanh (A * x) : ℝ) : ℂ) * Complex.exp (-2 * Complex.I * ((A ^ 2 * t : ℝ) : ℂ))

/-- **Theorem 2.4 (Focusing 1D Cubic NLS Bright Soliton):**
`i q_t + q_{xx} + 2 |q|² q = 0` identically for all `A, x, t ∈ ℝ`. -/
theorem brightSoliton_nls_pde (A x t : ℝ) :
    Complex.I * deriv (fun s => brightSoliton A x s) t +
    iteratedDeriv 2 (fun r => brightSoliton A r t) x +
    2 * ((‖brightSoliton A x t‖ ^ 2 : ℝ) : ℂ) * brightSoliton A x t = 0 := by
  let E : ℂ := Complex.exp (Complex.I * ((A ^ 2 * t : ℝ) : ℂ))
  have hCpos : ∀ r : ℝ, Real.cosh (A * r) ≠ 0 := fun r => (Real.cosh_pos _).ne'
  have hqt : HasDerivAt (fun s : ℝ => brightSoliton A x s)
      (Complex.I * ((A ^ 2 : ℝ) : ℂ) * brightSoliton A x t) t := by
    have hlin : HasDerivAt (fun s : ℝ => Complex.I * ((A ^ 2 * s : ℝ) : ℂ))
        (Complex.I * ((A ^ 2 : ℝ) : ℂ)) t := by
      have h := Complex.ofRealCLM.hasFDerivAt.comp_hasDerivAt t ((hasDerivAt_id t).const_mul (A ^ 2))
      convert h.const_mul Complex.I using 1
      · funext s; rfl
      · simp [Complex.ofRealCLM_apply]
    have hE := (Complex.hasDerivAt_exp _).comp t hlin
    convert hE.const_mul ((A / Real.cosh (A * x) : ℝ) : ℂ) using 1
    · funext s; rfl
    · unfold brightSoliton; ring
  have hqx : ∀ r : ℝ, HasDerivAt (fun r' => brightSoliton A r' t)
      (((-A ^ 2 * Real.sinh (A * r) / Real.cosh (A * r) ^ 2 : ℝ) : ℂ) * E) r := fun r => by
    have hlin : HasDerivAt (fun r' => A * r') A r := by
      convert (hasDerivAt_id r).const_mul A using 1
      · rfl
      · ring
    have hdiv := (hasDerivAt_const r A).div ((Real.hasDerivAt_cosh _).comp r hlin) (hCpos r)
    have hC := (Complex.ofRealCLM.hasFDerivAt.comp_hasDerivAt r hdiv).mul_const E
    convert hC using 1
    · funext r'; rfl
    · have hR : (0 * Real.cosh (A * r) - A * (Real.sinh (A * r) * A)) / Real.cosh (A * r) ^ 2 =
          -A ^ 2 * Real.sinh (A * r) / Real.cosh (A * r) ^ 2 := by ring
      simp only [Complex.ofRealCLM_apply, Function.comp_apply]
      rw [hR]
  have hqxx : HasDerivAt
      (fun r => ((-A ^ 2 * Real.sinh (A * r) / Real.cosh (A * r) ^ 2 : ℝ) : ℂ) * E)
      (((A ^ 3 / Real.cosh (A * x) - 2 * A ^ 3 / Real.cosh (A * x) ^ 3 : ℝ) : ℂ) * E) x := by
    have hlin : HasDerivAt (fun r => A * r) A x := by
      convert (hasDerivAt_id x).const_mul A using 1
      · rfl
      · ring
    have hnum := ((Real.hasDerivAt_sinh _).comp x hlin).const_mul (-A ^ 2)
    have hden := ((Real.hasDerivAt_cosh _).comp x hlin).pow 2
    have hdiv := hnum.div hden (pow_ne_zero 2 (hCpos x))
    have hC := (Complex.ofRealCLM.hasFDerivAt.comp_hasDerivAt x hdiv).mul_const E
    convert hC using 1
    · funext r; rfl
    · have hne := hCpos x
      have hsinh : Real.sinh (A * x) ^ 2 = Real.cosh (A * x) ^ 2 - 1 := by
        linarith [Real.cosh_sq_sub_sinh_sq (A * x)]
      have hR : (-A ^ 2 * (Real.cosh (A * x) * A) * Real.cosh (A * x) ^ 2 -
          -A ^ 2 * Real.sinh (A * x) * (2 * Real.cosh (A * x) ^ 1 * (Real.sinh (A * x) * A))) /
          (Real.cosh (A * x) ^ 2) ^ 2 =
          A ^ 3 / Real.cosh (A * x) - 2 * A ^ 3 / Real.cosh (A * x) ^ 3 := by
        field_simp [hne]; ring_nf; rw [hsinh]; ring
      simp only [Complex.ofRealCLM_apply, Function.comp_apply, Pi.pow_apply, Nat.cast_ofNat,
        Nat.reduceSub]
      rw [hR]
  have hd1 : deriv (fun r => brightSoliton A r t) =
      fun r => ((-A ^ 2 * Real.sinh (A * r) / Real.cosh (A * r) ^ 2 : ℝ) : ℂ) * E :=
    funext fun r => (hqx r).deriv
  have hd2 : iteratedDeriv 2 (fun r => brightSoliton A r t) x =
      (((A ^ 3 / Real.cosh (A * x) - 2 * A ^ 3 / Real.cosh (A * x) ^ 3 : ℝ) : ℂ) * E) := by
    rw [iteratedDeriv_succ, iteratedDeriv_one, hd1]; exact hqxx.deriv
  have hnorm : ‖brightSoliton A x t‖ ^ 2 = (A / Real.cosh (A * x)) ^ 2 := by
    unfold brightSoliton
    rw [norm_mul, Complex.norm_real, Real.norm_eq_abs, Complex.norm_exp_I_mul_ofReal,
      mul_one, sq_abs]
  rw [hqt.deriv, hd2, hnorm]
  unfold brightSoliton
  dsimp only [E]
  have hne : ((Real.cosh (A * x) : ℝ) : ℂ) ≠ 0 := by exact_mod_cast hCpos x
  push_cast at hne ⊢
  field_simp [hne]
  ring_nf; simp [Complex.I_sq]

/-- **Theorem 2.5 (Defocusing 1D Cubic NLS / 1D GPE Dark Soliton):**
`i q_t + q_{xx} - 2 |q|² q = 0` identically for all `A, x, t ∈ ℝ`. -/
theorem darkSoliton_gpe_pde (A x t : ℝ) :
    Complex.I * deriv (fun s => darkSoliton A x s) t +
    iteratedDeriv 2 (fun r => darkSoliton A r t) x -
    2 * ((‖darkSoliton A x t‖ ^ 2 : ℝ) : ℂ) * darkSoliton A x t = 0 := by
  let E : ℂ := Complex.exp (-2 * Complex.I * ((A ^ 2 * t : ℝ) : ℂ))
  have hCpos : ∀ r : ℝ, Real.cosh (A * r) ≠ 0 := fun r => (Real.cosh_pos _).ne'
  have hqt : HasDerivAt (fun s : ℝ => darkSoliton A x s)
      ((-2 * Complex.I * ((A ^ 2 : ℝ) : ℂ)) * darkSoliton A x t) t := by
    have hlin : HasDerivAt (fun s : ℝ => -2 * Complex.I * ((A ^ 2 * s : ℝ) : ℂ))
        (-2 * Complex.I * ((A ^ 2 : ℝ) : ℂ)) t := by
      have h := Complex.ofRealCLM.hasFDerivAt.comp_hasDerivAt t ((hasDerivAt_id t).const_mul (A ^ 2))
      convert h.const_mul (-2 * Complex.I) using 1
      · funext s; rfl
      · simp [Complex.ofRealCLM_apply]
    have hE := (Complex.hasDerivAt_exp _).comp t hlin
    convert hE.const_mul ((A * Real.tanh (A * x) : ℝ) : ℂ) using 1
    · funext s; rfl
    · unfold darkSoliton; ring
  have hqx : ∀ r : ℝ, HasDerivAt (fun r' => darkSoliton A r' t)
      (((A ^ 2 / Real.cosh (A * r) ^ 2 : ℝ) : ℂ) * E) r := fun r => by
    have h0 := hasDerivAt_real_tanh A 0 r
    simp only [mul_zero, add_zero] at h0
    have hC := (Complex.ofRealCLM.hasFDerivAt.comp_hasDerivAt r (h0.const_mul A)).mul_const E
    convert hC using 1
    · funext r'; rfl
    · simp only [Complex.ofRealCLM_apply]; push_cast; ring
  have hqxx : HasDerivAt
      (fun r => ((A ^ 2 / Real.cosh (A * r) ^ 2 : ℝ) : ℂ) * E)
      (((-2 * A ^ 3 * Real.tanh (A * x) / Real.cosh (A * x) ^ 2 : ℝ) : ℂ) * E) x := by
    have hlin : HasDerivAt (fun r => A * r) A x := by
      convert (hasDerivAt_id x).const_mul A using 1
      · rfl
      · ring
    have hden := ((Real.hasDerivAt_cosh _).comp x hlin).pow 2
    have hdiv := (hasDerivAt_const x (A ^ 2)).div hden (pow_ne_zero 2 (hCpos x))
    have hC := (Complex.ofRealCLM.hasFDerivAt.comp_hasDerivAt x hdiv).mul_const E
    convert hC using 1
    · funext r; rfl
    · have hne := hCpos x
      have hR : (0 * Real.cosh (A * x) ^ 2 -
          A ^ 2 * (2 * Real.cosh (A * x) ^ 1 * (Real.sinh (A * x) * A))) /
          (Real.cosh (A * x) ^ 2) ^ 2 =
          -2 * A ^ 3 * Real.tanh (A * x) / Real.cosh (A * x) ^ 2 := by
        rw [Real.tanh_eq_sinh_div_cosh]; field_simp [hne]; ring
      simp only [Complex.ofRealCLM_apply, Function.comp_apply, Pi.pow_apply, Nat.cast_ofNat,
        Nat.reduceSub]
      rw [hR]
  have hd1 : deriv (fun r => darkSoliton A r t) =
      fun r => ((A ^ 2 / Real.cosh (A * r) ^ 2 : ℝ) : ℂ) * E :=
    funext fun r => (hqx r).deriv
  have hd2 : iteratedDeriv 2 (fun r => darkSoliton A r t) x =
      (((-2 * A ^ 3 * Real.tanh (A * x) / Real.cosh (A * x) ^ 2 : ℝ) : ℂ) * E) := by
    rw [iteratedDeriv_succ, iteratedDeriv_one, hd1]; exact hqxx.deriv
  have hnorm : ‖darkSoliton A x t‖ ^ 2 = (A * Real.tanh (A * x)) ^ 2 := by
    unfold darkSoliton
    rw [norm_mul, Complex.norm_real, Real.norm_eq_abs,
      show -2 * Complex.I * ((A ^ 2 * t : ℝ) : ℂ) = Complex.I * (((-2 * A ^ 2 * t : ℝ) : ℂ)) by
        push_cast; ring,
      Complex.norm_exp_I_mul_ofReal, mul_one, sq_abs]
  rw [hqt.deriv, hd2, hnorm]
  unfold darkSoliton
  dsimp only [E]
  have hne := hCpos x
  have hTsq : (Real.cosh (A * x) ^ 2)⁻¹ + Real.tanh (A * x) ^ 2 = 1 := by
    rw [Real.tanh_eq_sinh_div_cosh, div_pow]
    have hid := Real.cosh_sq_sub_sinh_sq (A * x)
    field_simp [hne]; linarith
  have hTsqC : (((Real.cosh (A * x) ^ 2 : ℝ) : ℂ))⁻¹ + ((Real.tanh (A * x) : ℝ) : ℂ) ^ 2 = 1 := by
    exact_mod_cast hTsq
  push_cast at hTsqC ⊢
  rw [div_eq_mul_inv]
  linear_combination (-2 * (A : ℂ) ^ 3 * Complex.tanh ((A : ℂ) * (x : ℂ)) *
    Complex.exp (-2 * Complex.I * ((A : ℂ) ^ 2 * (t : ℂ)))) * hTsqC
    - (2 * (A : ℂ) ^ 3 * Complex.tanh ((A : ℂ) * (x : ℂ)) *
    Complex.exp (-2 * Complex.I * ((A : ℂ) ^ 2 * (t : ℂ)))) * (by simp [Complex.I_sq] : Complex.I ^ 2 + 1 = 0)

end Signals.SatoGrassmannian.AKNS
