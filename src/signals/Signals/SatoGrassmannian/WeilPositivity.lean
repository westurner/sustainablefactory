import Mathlib.Analysis.Complex.Basic
import Mathlib.LinearAlgebra.Lagrange
import Mathlib.MeasureTheory.Group.Integral
import Mathlib.MeasureTheory.Integral.Bochner.Basic
import Mathlib.MeasureTheory.Integral.Prod
import Mathlib.MeasureTheory.Measure.Haar.Unique
import Signals.SatoGrassmannian.RHGaps
import Signals.SatoGrassmannian.RemainingGaps

/-!
# Weil Positivity Criterion & Explicit-Formula Spectral Bridge

Ported from `data/chats/Gemini_Formalizing-Sato-Grassmannian-in-Lean_20261120-2337.md`
(block 013). Formalizes:
1. Weil involution `f̃(x) = conj(f(-x))`, convolution `f * f̃`, and the Mellin–Fourier
   convolution–involution identity `M_{f * f̃}(z) = M_f(z) conj(M_f(conj z))`.
2. Hermitian reality and the bidirectional Weil Positivity Criterion on finite
   conjugation-invariant zero sets (`weilPositivity_iff_allRealZeros`).
3. Prime-power and pole distributions (`weilPrimeDist`, `weilPoleDist`), abstract
   `WeilExplicitPairing`, and conditional positivity from a Kato–Rellich spectral
   realization (`weilExplicit_positivity_of_spectral_realization`).
-/

open scoped BigOperators InnerProductSpace
open MeasureTheory

namespace Signals.SatoGrassmannian.WeilPositivity

open Signals.SatoGrassmannian.RHGaps Signals.SatoGrassmannian.RemainingGaps

/-! ### Section 1: Test-Function Involution, Convolution & Mellin–Fourier Transform -/

/-- Weil involution `f̃(x) = conj(f(-x))` on `ℝ → ℂ`. -/
def weilInvol (f : ℝ → ℂ) (x : ℝ) : ℂ :=
  starRingEnd ℂ (f (-x))

/-- Additive convolution `(f * g)(x) = ∫ y, f(y) g(x - y) dy`. -/
noncomputable def weilConv (f g : ℝ → ℂ) (x : ℝ) : ℂ :=
  ∫ y : ℝ, f y * g (x - y)

/-- Spectral Mellin–Fourier transform `M_h(z) = ∫ h(x) exp(i z x) dx` (`s = 1/2 + i z`). -/
noncomputable def mellinTransform (h : ℝ → ℂ) (z : ℂ) : ℂ :=
  ∫ x : ℝ, h x * Complex.exp (Complex.I * z * (x : ℂ))

/-- **Theorem 3.1 (Weil Convolution–Involution Identity):**
`M_{f * f̃}(z) = M_f(z) * conj(M_f(conj z))` for every `f` whose shifted exponentials are integrable. -/
theorem mellinTransform_weilConv_invol {f : ℝ → ℂ} {z : ℂ}
    (hf1 : Integrable (fun y : ℝ => f y * Complex.exp (Complex.I * z * (y : ℂ))) volume)
    (hf2 : Integrable (fun u : ℝ => f u * Complex.exp (Complex.I * starRingEnd ℂ z * (u : ℂ))) volume) :
    mellinTransform (weilConv f (weilInvol f)) z =
      mellinTransform f z * starRingEnd ℂ (mellinTransform f (starRingEnd ℂ z)) := by
  let g₁ : ℝ → ℂ := fun y => f y * Complex.exp (Complex.I * z * (y : ℂ))
  let g₂ : ℝ → ℂ := fun u => starRingEnd ℂ (f u * Complex.exp (Complex.I * starRingEnd ℂ z * (u : ℂ)))
  have hg₂_int : Integrable g₂ volume := Complex.conjCLE.toContinuousLinearMap.integrable_comp hf2
  have hfactor : ∀ x y : ℝ,
      f y * weilInvol f (x - y) * Complex.exp (Complex.I * z * (x : ℂ)) =
        g₁ y * g₂ (y - x) := by
    intro x y
    dsimp [weilInvol, g₁, g₂]
    rw [show -(x - y) = y - x by ring, map_mul, ← Complex.exp_conj]
    simp only [map_mul, Complex.conj_I, RingHomCompTriple.comp_apply, RingHom.id_apply,
      Complex.conj_ofReal]
    have hexp : Complex.exp (Complex.I * z * (y : ℂ)) *
        Complex.exp (-Complex.I * z * ((y - x : ℝ) : ℂ)) =
        Complex.exp (Complex.I * z * (x : ℂ)) := by
      rw [← Complex.exp_add]; congr 1; push_cast; ring
    calc f y * starRingEnd ℂ (f (y - x)) * Complex.exp (Complex.I * z * (x : ℂ))
        = f y * starRingEnd ℂ (f (y - x)) *
            (Complex.exp (Complex.I * z * (y : ℂ)) *
             Complex.exp (-Complex.I * z * ((y - x : ℝ) : ℂ))) := by rw [hexp]
      _ = (f y * Complex.exp (Complex.I * z * (y : ℂ))) *
            (starRingEnd ℂ (f (y - x)) * Complex.exp (-Complex.I * z * ((y - x : ℝ) : ℂ))) := by ring
  let Φ : ℝ × ℝ ≃ᵐ ℝ × ℝ :=
    { toFun := fun p => (p.2, p.2 - p.1)
      invFun := fun q => (q.1 - q.2, q.1)
      left_inv := fun ⟨x, y⟩ => Prod.ext (by ring) rfl
      right_inv := fun ⟨y, u⟩ => Prod.ext rfl (by ring)
      measurable_toFun := measurable_snd.prodMk (measurable_snd.sub measurable_fst)
      measurable_invFun := (measurable_fst.sub measurable_snd).prodMk measurable_fst }
  have hΦ_mp : MeasurePreserving Φ (volume.prod volume) (volume.prod volume) := by
    classical
    refine ⟨Φ.measurable, ?_⟩
    symm
    refine Measure.prod_eq fun s t hs ht => ?_
    rw [Measure.map_apply Φ.measurable (hs.prod ht), Measure.prod_apply_symm (Φ.measurable (hs.prod ht))]
    have hsect : ∀ y : ℝ, volume ((fun x : ℝ => (x, y)) ⁻¹' (Φ ⁻¹' (s ×ˢ t))) =
        s.indicator (fun _ => volume t) y := by
      intro y
      by_cases hy : y ∈ s
      · rw [Set.indicator_of_mem hy]
        have hpre : (fun x : ℝ => (x, y)) ⁻¹' (Φ ⁻¹' (s ×ˢ t)) = (fun x : ℝ => y - x) ⁻¹' t := by
          ext x; simp [Φ, hy]
        rw [hpre]
        exact (Measure.measurePreserving_sub_left volume y).measure_preimage ht.nullMeasurableSet
      · rw [Set.indicator_of_notMem hy]
        have hpre : (fun x : ℝ => (x, y)) ⁻¹' (Φ ⁻¹' (s ×ˢ t)) = ∅ := by
          ext x; simp [Φ, hy]
        rw [hpre, measure_empty]
    simp_rw [hsect]
    rw [lintegral_indicator_const hs, mul_comm]
  have hProd : Integrable (fun q : ℝ × ℝ => g₁ q.1 * g₂ q.2) (volume.prod volume) :=
    hf1.mul_prod hg₂_int
  have hJoint : Integrable (fun p : ℝ × ℝ => g₁ p.2 * g₂ (p.2 - p.1)) (volume.prod volume) :=
    hΦ_mp.integrable_comp_emb Φ.measurableEmbedding |>.mpr hProd
  unfold mellinTransform weilConv
  have hpull : (fun x : ℝ => (∫ y : ℝ, f y * weilInvol f (x - y)) *
      Complex.exp (Complex.I * z * (x : ℂ))) =
      fun x : ℝ => ∫ y : ℝ, g₁ y * g₂ (y - x) := by
    ext x
    rw [← MeasureTheory.integral_mul_const]
    exact MeasureTheory.integral_congr_ae (Filter.Eventually.of_forall fun y => hfactor x y)
  rw [hpull, MeasureTheory.integral_integral_swap hJoint]
  have hinner : (fun y : ℝ => ∫ x : ℝ, g₁ y * g₂ (y - x)) =
      fun y : ℝ => g₁ y * (∫ u : ℝ, g₂ u) := by
    ext y
    rw [MeasureTheory.integral_const_mul, MeasureTheory.integral_sub_left_eq_self g₂ volume y]
  rw [hinner, MeasureTheory.integral_mul_const]
  congr 1
  exact integral_conj

/-- Corollary: On the critical line (`z = γ ∈ ℝ`), `M_{f * f̃}(γ) = ‖M_f(γ)‖² ≥ 0`. -/
theorem mellinTransform_weilConv_invol_real {f : ℝ → ℂ} (γ : ℝ)
    (hf : Integrable (fun y : ℝ => f y * Complex.exp (Complex.I * (γ : ℂ) * (y : ℂ))) volume) :
    mellinTransform (weilConv f (weilInvol f)) (γ : ℂ) =
      ((‖mellinTransform f (γ : ℂ)‖ ^ 2 : ℝ) : ℂ) := by
  have hf' : Integrable (fun u : ℝ => f u * Complex.exp (Complex.I * starRingEnd ℂ (γ : ℂ) * (u : ℂ))) volume := by
    simpa [Complex.conj_ofReal] using hf
  rw [mellinTransform_weilConv_invol hf hf', Complex.conj_ofReal, Complex.mul_conj,
    Complex.normSq_eq_norm_sq]

/-! ### Section 2: Spectral Weil Quadratic Form & Bidirectional Equivalence with RH -/

/-- Spectral Weil quadratic form on a finite zero set `Z ⊂ ℂ` with multiplicities `m`:
`Q_W(F) = ∑_{z ∈ Z} m(z) F(z) conj(F(conj z))`. -/
def weilQuadForm (Z : Finset ℂ) (m : ℂ → ℕ) (F : ℂ → ℂ) : ℂ :=
  ∑ z ∈ Z, (m z : ℂ) * (F z * starRingEnd ℂ (F (starRingEnd ℂ z)))

/-- **Theorem 3.2 (Hermitian Reality):** Whenever `(Z, m)` is conjugation-invariant,
`Q_W(F)` is strictly real for every `F : ℂ → ℂ`. -/
theorem weilQuadForm_im_eq_zero {Z : Finset ℂ} {m : ℂ → ℕ}
    (hZ : ∀ z ∈ Z, starRingEnd ℂ z ∈ Z)
    (hm : ∀ z ∈ Z, m (starRingEnd ℂ z) = m z) (F : ℂ → ℂ) :
    (weilQuadForm Z m F).im = 0 := by
  have hconj : starRingEnd ℂ (weilQuadForm Z m F) = weilQuadForm Z m F := by
    unfold weilQuadForm
    rw [map_sum]
    refine Finset.sum_bij (fun z _ => starRingEnd ℂ z)
      (fun z hz => hZ z hz)
      (fun a _ b _ h => by simpa using congrArg (starRingEnd ℂ) h)
      (fun w hw => ⟨starRingEnd ℂ w, hZ w hw, by simp⟩)
      (fun z hz => ?_)
    simp only [map_mul, map_natCast, hm z hz, RingHomCompTriple.comp_apply, RingHom.id_apply,
      mul_comm (starRingEnd ℂ (F z))]
  have him := congrArg Complex.im hconj
  simp only [Complex.conj_im] at him
  linarith

/-- **Theorem 3.3 (Weil Positivity Criterion — Full Bidirectional Equivalence):**
For any finite conjugation-invariant zero set `Z` with positive symmetric multiplicities `m`,
every zero in `Z` is real (RH) **if and only if** `Re Q_W(P) ≥ 0` for all complex polynomials `P`. -/
theorem weilPositivity_iff_allRealZeros {Z : Finset ℂ} {m : ℂ → ℕ}
    (hZ : ∀ z ∈ Z, starRingEnd ℂ z ∈ Z)
    (hm_symm : ∀ z ∈ Z, m (starRingEnd ℂ z) = m z)
    (hm_pos : ∀ z ∈ Z, 0 < m z) :
    (∀ z ∈ Z, z.im = 0) ↔
      (∀ P : Polynomial ℂ, 0 ≤ (weilQuadForm Z m (fun z => P.eval z)).re) := by
  classical
  constructor
  · intro hReal P
    unfold weilQuadForm
    rw [Complex.re_sum]
    refine Finset.sum_nonneg fun z hz => ?_
    have hcz : starRingEnd ℂ z = z := Complex.ext rfl (by simp [hReal z hz])
    rw [hcz, Complex.mul_conj, Complex.normSq_eq_norm_sq]
    have hre : ((m z : ℂ) * ((‖P.eval z‖ ^ 2 : ℝ) : ℂ)).re = (m z : ℝ) * ‖P.eval z‖ ^ 2 := by
      norm_cast
    rw [hre]
    exact mul_nonneg (Nat.cast_nonneg _) (sq_nonneg _)
  · intro hPos z₀ hz₀
    by_contra him_ne
    let z₀c : ℂ := starRingEnd ℂ z₀
    have hz₀c : z₀c ∈ Z := hZ z₀ hz₀
    have hne : z₀c ≠ z₀ := by
      intro hEq
      have him := congrArg Complex.im hEq
      simp only [z₀c, Complex.conj_im] at him
      exact him_ne (by linarith)
    let r : { z : ℂ // z ∈ Z } → ℂ := fun z =>
      if z.1 = z₀ then 1 else if z.1 = z₀c then -1 else 0
    let P : Polynomial ℂ :=
      Lagrange.interpolate (Finset.univ : Finset { z : ℂ // z ∈ Z }) Subtype.val r
    have hEval : ∀ z (hz : z ∈ Z), P.eval z = r ⟨z, hz⟩ := by
      intro z hz
      exact Lagrange.eval_interpolate_at_node r
        (Subtype.val_injective.injOn) (Finset.mem_univ ⟨z, hz⟩)
    have hSum : weilQuadForm Z m (fun z => P.eval z) = -2 * (m z₀ : ℂ) := by
      unfold weilQuadForm
      have hSub : ({z₀, z₀c} : Finset ℂ) ⊆ Z := by
        intro w hw
        simp only [Finset.mem_insert, Finset.mem_singleton] at hw
        rcases hw with rfl | rfl
        · exact hz₀
        · exact hz₀c
      rw [← Finset.sum_subset hSub]
      · rw [Finset.sum_pair hne.symm]
        dsimp only
        have h1 : P.eval z₀ = 1 := by rw [hEval z₀ hz₀]; simp [r]
        have h2 : P.eval z₀c = -1 := by rw [hEval z₀c hz₀c]; simp [r, hne]
        have hcc : starRingEnd ℂ z₀c = z₀ := Complex.conj_conj z₀
        rw [show starRingEnd ℂ z₀ = z₀c from rfl, hcc, h1, h2, hm_symm z₀ hz₀]
        simp; ring
      · intro w hw hnot
        dsimp only
        simp only [Finset.mem_insert, Finset.mem_singleton, not_or] at hnot
        rw [hEval w hw]
        simp [r, hnot.1, hnot.2]
    have hNonneg := hPos P
    rw [hSum] at hNonneg
    have hre : (-2 * (m z₀ : ℂ)).re = -2 * (m z₀ : ℝ) := by norm_cast
    rw [hre] at hNonneg
    have hpos_m : (0 : ℝ) < (m z₀ : ℝ) := by exact_mod_cast hm_pos z₀ hz₀
    linarith

/-! ### Section 3: Explicit Formula Structure & Spectral Bridge to Kato–Rellich -/

/-- Prime-power distribution (finite cutoff up to primes in `P` and powers `1 ≤ k ≤ M`):
`W_prime(h) = ∑_{p ∈ P} ∑_{1 ≤ k ≤ M} (log p / p^(k/2)) * (h(k log p) + h(-k log p))`. -/
noncomputable def weilPrimeDist (P : Finset Nat.Primes) (M : ℕ) (h : ℝ → ℂ) : ℂ :=
  ∑ p ∈ P, ∑ k ∈ Finset.Icc 1 M,
    ((Real.log (p : ℕ) / ((p : ℕ) : ℝ) ^ ((k : ℝ) / 2) : ℝ) : ℂ) *
      (h ((k : ℝ) * Real.log (p : ℕ)) + h (-((k : ℝ) * Real.log (p : ℕ))))

/-- Pole distribution `W_pole(h) = M_h(i/2) + M_h(-i/2)` corresponding to `s = 0, 1`. -/
noncomputable def weilPoleDist (h : ℝ → ℂ) : ℂ :=
  mellinTransform h (Complex.I / 2) + mellinTransform h (-(Complex.I / 2))

/-- Abstract Weil Explicit Formula pairing:
`∑_{z ∈ Z} m(z) M_h(z) = W_pole(h) + W_arch(h) - W_prime(h)` on an admissible class of test functions. -/
structure WeilExplicitPairing where
  zeros : Finset ℂ
  mult : ℂ → ℕ
  wArch : (ℝ → ℂ) → ℂ
  wPrime : (ℝ → ℂ) → ℂ
  explicit_formula : ∀ (h : ℝ → ℂ),
    (∑ z ∈ zeros, (mult z : ℂ) * mellinTransform h z) =
      weilPoleDist h + wArch h - wPrime h

/-- **Theorem 3.4 (Weil Positivity from Kato–Rellich Spectral Realization):**
If a Kato–Rellich self-adjoint operator `D_inf + V_fin` realizes the zeros of `Ξ` spectrally
and `E` is a Weil explicit pairing over those zeros, then for every admissible test function `f`,
`Re(W_pole(f * f̃) + W_arch(f * f̃) - W_prime(f * f̃)) ≥ 0`. -/
theorem weilExplicit_positivity_of_spectral_realization {H : Type*}
    [NormedAddCommGroup H] [InnerProductSpace ℂ H] [CompleteSpace H]
    (D_inf : SymmetricOp H) (V_fin : D_inf.dom →ₗ[ℂ] H)
    (hVsymm : ∀ x y : D_inf.dom, ⟪V_fin x, (y : H)⟫_ℂ = ⟪(x : H), V_fin y⟫_ℂ)
    {Ξ : ℂ → ℂ}
    (hSpec : SpectralRealization (D_inf.addCoupling V_fin hVsymm) Ξ)
    (E : WeilExplicitPairing)
    (hZeros : ∀ z ∈ E.zeros, Ξ z = 0)
    {f : ℝ → ℂ}
    (hf : ∀ z ∈ E.zeros,
      Integrable (fun y : ℝ => f y * Complex.exp (Complex.I * z * (y : ℂ))) volume) :
    0 ≤ (weilPoleDist (weilConv f (weilInvol f)) +
         E.wArch (weilConv f (weilInvol f)) -
         E.wPrime (weilConv f (weilInvol f))).re := by
  rw [← E.explicit_formula (weilConv f (weilInvol f)), Complex.re_sum]
  refine Finset.sum_nonneg fun z hz => ?_
  have him : z.im = 0 := allRealZeros_of_spectral_realization hSpec z (hZeros z hz)
  have hzR : z = (z.re : ℂ) := Complex.ext rfl (by simp [him])
  have hfR : Integrable (fun y : ℝ => f y * Complex.exp (Complex.I * (z.re : ℂ) * (y : ℂ))) volume := by
    simpa [← hzR] using hf z hz
  rw [hzR, mellinTransform_weilConv_invol_real z.re hfR]
  have hre : ((E.mult (z.re : ℂ) : ℂ) * ((‖mellinTransform f (z.re : ℂ)‖ ^ 2 : ℝ) : ℂ)).re =
      (E.mult (z.re : ℂ) : ℝ) * ‖mellinTransform f (z.re : ℂ)‖ ^ 2 := by
    norm_cast
  rw [hre]
  exact mul_nonneg (Nat.cast_nonneg _) (sq_nonneg _)

end Signals.SatoGrassmannian.WeilPositivity
