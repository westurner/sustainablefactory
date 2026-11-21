import Mathlib.Analysis.Fourier.AddCircle
import Mathlib.Analysis.Normed.Lp.lpSpace
import Signals.SatoGrassmannian.Base
import Signals.SatoGrassmannian.RieszSchauder

open scoped InnerProductSpace
open MeasureTheory

namespace Signals.SatoGrassmannian.CircleL2

open Signals.SatoGrassmannian

local instance : Fact (0 < (1 : ℝ)) := ⟨by norm_num⟩

/-- The complex Hilbert space `L²(S¹, ℂ)` with normalized Haar measure on `AddCircle 1`. -/
noncomputable abbrev HCircle := Lp ℂ 2 (AddCircle.haarAddCircle (T := (1 : ℝ)))

/-- The orthonormal Fourier basis `{ eₙ : n ∈ ℤ }` of `L²(S¹, ℂ)`. -/
noncomputable abbrev eBasis : HilbertBasis ℤ ℂ HCircle :=
  fourierBasis (T := (1 : ℝ))

/-! ### Hardy Polarization `HCircle = H₊ ⊕ H₋` -/

/-- The Hardy space `H₊ = closure span { eₙ | n ≥ 0 }`. -/
noncomputable def hardyPlus : Submodule ℂ HCircle :=
  (Submodule.span ℂ (Set.range (fun n : ℕ => eBasis (n : ℤ)))).topologicalClosure

/-- The negative-frequency space `H₋ = H₊ᗮ`. -/
noncomputable def hardyMinus : Submodule ℂ HCircle :=
  hardyPlusᗮ

lemma hardyPlus_isClosed : IsClosed (hardyPlus : Set HCircle) :=
  Submodule.isClosed_topologicalClosure _

lemma hardyMinus_isClosed : IsClosed (hardyMinus : Set HCircle) :=
  hardyPlus.isClosed_orthogonal

instance instCompleteSpaceHardyPlus : CompleteSpace hardyPlus :=
  hardyPlus_isClosed.completeSpace_coe

instance instCompleteSpaceHardyMinus : CompleteSpace hardyMinus :=
  hardyMinus_isClosed.completeSpace_coe

/-- **Instantiation:** `L²(S¹, ℂ)` as a `PolarizedHilbertSpace`. -/
noncomputable def hardyPolarization : PolarizedHilbertSpace ℂ HCircle where
  HPlus := hardyPlus
  HMinus := hardyMinus
  complete_HPlus := instCompleteSpaceHardyPlus
  complete_HMinus := instCompleteSpaceHardyMinus
  ortho_eq := rfl

lemma mem_hardyPlus_basis (n : ℕ) : eBasis (n : ℤ) ∈ hardyPlus :=
  Submodule.le_topologicalClosure _ (Submodule.subset_span ⟨n, rfl⟩)

/-- Fourier coefficient characterization of `H₊`: `f ∈ H₊ ↔ ∀ n < 0, f̂(n) = 0`. -/
theorem mem_hardyPlus_iff (f : HCircle) :
    f ∈ hardyPlus ↔ ∀ n : ℤ, n < 0 → eBasis.repr f n = 0 := by
  constructor
  · intro hf n hn
    let ker_n : Submodule ℂ HCircle :=
      LinearMap.ker (innerSL ℂ (eBasis n)).toLinearMap
    have hclosed : IsClosed (ker_n : Set HCircle) :=
      isClosed_singleton.preimage (innerSL ℂ (eBasis n)).continuous
    have hspan_le : Submodule.span ℂ (Set.range (fun k : ℕ => eBasis (k : ℤ))) ≤ ker_n := by
      rw [Submodule.span_le]
      rintro _ ⟨k, rfl⟩
      change ⟪eBasis n, eBasis (k : ℤ)⟫_ℂ = 0
      rw [eBasis.orthonormal.inner_eq_zero]
      omega
    have hle : hardyPlus ≤ ker_n :=
      Submodule.topologicalClosure_minimal _ hspan_le hclosed
    rw [HilbertBasis.repr_apply_apply]
    exact hle hf
  · intro hneg
    have hsum : HasSum (fun n : ℤ => eBasis.repr f n • eBasis n) f :=
      eBasis.hasSum_repr f
    refine hardyPlus_isClosed.mem_of_tendsto hsum ?_
    filter_upwards with s
    refine Submodule.sum_mem _ fun n _ => ?_
    by_cases hn : 0 ≤ n
    · lift n to ℕ using hn
      exact hardyPlus.smul_mem _ (mem_hardyPlus_basis n)
    · push Not at hn
      rw [hneg n hn, zero_smul]
      exact hardyPlus.zero_mem

/-- Fourier coefficient characterization of `H₋`: `f ∈ H₋ ↔ ∀ n ≥ 0, f̂(n) = 0`. -/
theorem mem_hardyMinus_iff (f : HCircle) :
    f ∈ hardyMinus ↔ ∀ n : ℤ, 0 ≤ n → eBasis.repr f n = 0 := by
  constructor
  · intro hf n hn
    lift n to ℕ using hn
    rw [HilbertBasis.repr_apply_apply]
    exact hf (eBasis (n : ℤ)) (mem_hardyPlus_basis n)
  · intro hnonneg g hg
    have hinner : ⟪g, f⟫_ℂ = ∑' n : ℤ, ⟪g, eBasis n⟫_ℂ * ⟪eBasis n, f⟫_ℂ :=
      (eBasis.hasSum_inner_mul_inner g f).tsum_eq.symm
    rw [hinner]
    have hzero : (fun n : ℤ => ⟪g, eBasis n⟫_ℂ * ⟪eBasis n, f⟫_ℂ) = fun _ => 0 := by
      funext n
      by_cases hn : 0 ≤ n
      · have hfn : ⟪eBasis n, f⟫_ℂ = 0 := by
          rw [← HilbertBasis.repr_apply_apply]; exact hnonneg n hn
        rw [hfn, mul_zero]
      · push Not at hn
        have hgn : ⟪g, eBasis n⟫_ℂ = 0 := by
          rw [← inner_conj_symm, ← HilbertBasis.repr_apply_apply,
            (mem_hardyPlus_iff g).mp hg n hn, map_zero]
        rw [hgn, zero_mul]
    rw [hzero, tsum_zero]

/-- `H₋` equals the closed span of the strictly negative Fourier modes `{ eₙ | n < 0 }`. -/
theorem hardyMinus_eq_closure_neg :
    hardyMinus = (Submodule.span ℂ { v : HCircle | ∃ n : ℤ, n < 0 ∧ v = eBasis n }).topologicalClosure := by
  apply le_antisymm
  · intro f hf
    have hsum : HasSum (fun n : ℤ => eBasis.repr f n • eBasis n) f := eBasis.hasSum_repr f
    refine (Submodule.isClosed_topologicalClosure _).mem_of_tendsto hsum ?_
    filter_upwards with s
    refine Submodule.sum_mem _ fun n _ => ?_
    by_cases hn : n < 0
    · exact Submodule.smul_mem _ _ (Submodule.le_topologicalClosure _
        (Submodule.subset_span ⟨n, hn, rfl⟩))
    · push Not at hn
      rw [(mem_hardyMinus_iff f).mp hf n hn, zero_smul]
      exact Submodule.zero_mem _
  · refine Submodule.topologicalClosure_minimal _ ?_ hardyPlus.isClosed_orthogonal
    rw [Submodule.span_le]
    rintro _ ⟨n, hn, rfl⟩
    change eBasis n ∈ hardyMinus
    rw [mem_hardyMinus_iff]
    intro k hk
    rw [HilbertBasis.repr_apply_apply, eBasis.orthonormal.inner_eq_zero]
    omega

/-- Orthogonal projection onto `H₊` preserves all Fourier coefficients with `n ≥ 0`. -/
lemma repr_projPlus_of_nonneg (x : HCircle) {n : ℤ} (hn : 0 ≤ n) :
    eBasis.repr (hardyPlus.orthogonalProjectionOnto x : HCircle) n = eBasis.repr x n := by
  lift n to ℕ using hn
  rw [HilbertBasis.repr_apply_apply, HilbertBasis.repr_apply_apply]
  have hortho : x - (hardyPlus.orthogonalProjectionOnto x : HCircle) ∈ hardyPlusᗮ :=
    Submodule.sub_starProjection_mem_orthogonal x
  have h0 : ⟪eBasis (n : ℤ), x - (hardyPlus.orthogonalProjectionOnto x : HCircle)⟫_ℂ = 0 :=
    hortho (eBasis (n : ℤ)) (mem_hardyPlus_basis n)
  rw [inner_sub_right] at h0
  exact (sub_eq_zero.mp h0).symm

/-! ### Unitary Shift Operator `M_z : L²(S¹) ≃ₗᵢ L²(S¹)` (`eₙ ↦ e_{n+1}`) -/

/-- Bilateral right shift on `ℓ²(ℤ, ℂ)`: `(lpShift a) n = a (n - 1)`. -/
noncomputable def lpShift : lp (fun _ : ℤ => ℂ) 2 ≃ₗᵢ[ℂ] lp (fun _ : ℤ => ℂ) 2 where
  toLinearEquiv :=
    { toFun := fun a =>
        ⟨a ∘ Equiv.subRight (1 : ℤ),
          (memℓp_gen_iff (by norm_num : (0 : ℝ) < (2 : ENNReal).toReal)).mpr
            (((memℓp_gen_iff (by norm_num)).mp (lp.memℓp a)).comp_injective
              (Equiv.subRight (1 : ℤ)).injective)⟩
      invFun := fun a =>
        ⟨a ∘ Equiv.addRight (1 : ℤ),
          (memℓp_gen_iff (by norm_num : (0 : ℝ) < (2 : ENNReal).toReal)).mpr
            (((memℓp_gen_iff (by norm_num)).mp (lp.memℓp a)).comp_injective
              (Equiv.addRight (1 : ℤ)).injective)⟩
      left_inv := fun a => by ext n; simp [Equiv.subRight, Equiv.addRight]
      right_inv := fun a => by ext n; simp [Equiv.subRight, Equiv.addRight]
      map_add' := fun a b => by ext n; rfl
      map_smul' := fun c a => by ext n; rfl }
  norm_map' := fun a => by
    have hp : (0 : ℝ) < (2 : ENNReal).toReal := by norm_num
    rw [lp.norm_eq_tsum_rpow hp, lp.norm_eq_tsum_rpow hp]
    congr 1
    exact (Equiv.subRight (1 : ℤ)).tsum_eq (fun n => ‖a n‖ ^ (2 : ENNReal).toReal)

/-- Multiplication by `z = e^{2πiθ}` on `L²(S¹, ℂ)`, conjugated from `lpShift` via `eBasis.repr`. -/
noncomputable def shiftL2 : HCircle ≃ₗᵢ[ℂ] HCircle :=
  eBasis.repr.trans (lpShift.trans eBasis.repr.symm)

lemma repr_shiftL2 (f : HCircle) (n : ℤ) :
    eBasis.repr (shiftL2 f) n = eBasis.repr f (n - 1) := by
  simp [shiftL2, lpShift]

lemma repr_shiftL2_symm (f : HCircle) (n : ℤ) :
    eBasis.repr (shiftL2.symm f) n = eBasis.repr f (n + 1) := by
  simp [shiftL2]
  rfl

/-- On Fourier modes, `shiftL2` sends `eₙ ↦ e_{n+1}` (i.e., `z · zⁿ = z^{n+1}`). -/
theorem shiftL2_fourierBasis (n : ℤ) :
    shiftL2 (eBasis n) = eBasis (n + 1) := by
  apply eBasis.repr.injective
  ext m
  rw [repr_shiftL2, HilbertBasis.repr_self, HilbertBasis.repr_self]
  by_cases h : m = n + 1
  · subst h; simp
  · have h' : m - 1 ≠ n := by omega
    simp [lp.single_apply, h, h']

/-- Verify pointwise identity on `S¹`: `fourier 1 x * fourier n x = fourier (n + 1) x`. -/
theorem fourier_mul_shift (n : ℤ) (x : AddCircle (1 : ℝ)) :
    fourier 1 x * fourier n x = fourier (n + 1) x := by
  rw [← fourier_add, add_comm]

/-! ### Proof that `z ∈ GL_res(L²(S¹))` with Fredholm Index `-1` -/

noncomputable abbrev shiftCLE : HCircle ≃L[ℂ] HCircle :=
  shiftL2.toContinuousLinearEquiv

lemma shiftL2_mem_hardyPlus {f : HCircle} (hf : f ∈ hardyPlus) :
    shiftL2 f ∈ hardyPlus := by
  rw [mem_hardyPlus_iff] at hf ⊢
  intro n hn
  rw [repr_shiftL2]
  exact hf (n - 1) (by omega)

/-- The lower-left Hankel block `(M_z)_{-+}` vanishes identically. -/
theorem blockMP_shift_eq_zero :
    blockMP hardyPolarization (shiftCLE : HCircle →L[ℂ] HCircle) = 0 := by
  apply ContinuousLinearMap.ext
  intro f
  apply Subtype.ext
  change (hardyMinus.orthogonalProjectionOnto (shiftL2 f.1) : HCircle) = 0
  have hmem : shiftL2 f.1 ∈ hardyPlus := shiftL2_mem_hardyPlus f.2
  have h0 := orthoProj_minus_of_mem_plus hardyPolarization ⟨shiftL2 f.1, hmem⟩
  exact congrArg Subtype.val h0

/-- The constant mode `e₀ = 1 ∈ H₊`. -/
noncomputable def e0 : hardyPolarization.HPlus :=
  ⟨eBasis 0, mem_hardyPlus_basis 0⟩

/-- The upper-right Hankel block `(M_z)_{+-}` is the rank-1 operator `f ↦ f̂(-1) • e₀`. -/
theorem blockPM_shift_eq_rankOne (f : hardyPolarization.HMinus) :
    blockPM hardyPolarization (shiftCLE : HCircle →L[ℂ] HCircle) f =
      eBasis.repr (f : HCircle) (-1) • e0 := by
  apply Subtype.ext
  apply eBasis.repr.injective
  ext n
  by_cases hn : n < 0
  · have hL : eBasis.repr ((blockPM hardyPolarization (shiftCLE : HCircle →L[ℂ] HCircle) f : hardyPolarization.HPlus) : HCircle) n = 0 :=
      (mem_hardyPlus_iff _).mp (blockPM hardyPolarization (shiftCLE : HCircle →L[ℂ] HCircle) f).2 n hn
    have hR : eBasis.repr ((eBasis.repr (f : HCircle) (-1) • e0 : hardyPolarization.HPlus) : HCircle) n = 0 :=
      (mem_hardyPlus_iff _).mp (eBasis.repr (f : HCircle) (-1) • e0).2 n hn
    rw [hL, hR]
  · push Not at hn
    change eBasis.repr (hardyPlus.orthogonalProjectionOnto (shiftL2 f.1) : HCircle) n =
      eBasis.repr (eBasis.repr f.1 (-1) • eBasis 0) n
    rw [repr_projPlus_of_nonneg _ hn, repr_shiftL2, map_smul, lp.coeFn_smul,
      Pi.smul_apply, HilbertBasis.repr_self]
    by_cases h0 : n = 0
    · subst h0; simp
    · have hpos : 0 ≤ n - 1 := by omega
      have hzero := (mem_hardyMinus_iff f.1).mp f.2 (n - 1) hpos
      simp [hzero, lp.single_apply, h0]

/-- **Theorem (Shift Membership):** Multiplication by `z` belongs to `GL_res(L²(S¹))`. -/
noncomputable def shiftGLRes : GLRes hardyPolarization :=
  ⟨shiftCLE,
    by
      have hle : LinearMap.range (blockPM hardyPolarization (shiftCLE : HCircle →L[ℂ] HCircle)).toLinearMap ≤
          Submodule.span ℂ ({e0} : Set hardyPolarization.HPlus) := by
        rintro _ ⟨f, rfl⟩
        change blockPM hardyPolarization (shiftCLE : HCircle →L[ℂ] HCircle) f ∈ _
        rw [blockPM_shift_eq_rankOne]
        exact Submodule.smul_mem _ _ (Submodule.subset_span rfl)
      have : FiniteDimensional ℂ (Submodule.span ℂ ({e0} : Set hardyPolarization.HPlus)) :=
        FiniteDimensional.span_of_finite ℂ (Set.finite_singleton e0)
      have : FiniteDimensional ℂ
          (LinearMap.range (blockPM hardyPolarization (shiftCLE : HCircle →L[ℂ] HCircle)).toLinearMap) :=
        Module.Finite.of_injective (Submodule.inclusion hle) (Submodule.inclusion_injective hle)
      exact isCompactOperator_of_finiteDimensional_range _,
    by
      rw [blockMP_shift_eq_zero]
      exact isCompactOperator_zero⟩

lemma blockPP_shift_apply (f : hardyPolarization.HPlus) :
    (blockPP hardyPolarization (shiftCLE : HCircle →L[ℂ] HCircle) f : HCircle) = shiftL2 f.1 := by
  change (hardyPlus.orthogonalProjectionOnto (shiftL2 f.1) : HCircle) = shiftL2 f.1
  exact congrArg Subtype.val
    (Submodule.orthogonalProjectionOnto_mem_subspace_eq_self ⟨shiftL2 f.1, shiftL2_mem_hardyPlus f.2⟩)

/-- **Theorem (Shift Fredholm Index):** `ind((M_z)_{++}) = -1`. -/
theorem glResIndex_shift :
    glResIndex hardyPolarization shiftGLRes = -1 := by
  unfold glResIndex fredholmIndex
  let T := blockPP hardyPolarization (shiftCLE : HCircle →L[ℂ] HCircle)
  have hker : LinearMap.ker T.toLinearMap = ⊥ := by
    rw [Submodule.eq_bot_iff]
    intro f hf
    apply Subtype.ext
    apply shiftL2.injective
    change shiftL2 f.1 = shiftL2 0
    rw [map_zero, ← blockPP_shift_apply]
    exact congrArg Subtype.val hf
  let coeff0 : hardyPolarization.HPlus →ₗ[ℂ] ℂ :=
    { toFun := fun g => eBasis.repr (g : HCircle) 0
      map_add' := fun u v => by simp
      map_smul' := fun c u => by simp }
  have hrange : LinearMap.range T.toLinearMap = LinearMap.ker coeff0 := by
    ext g
    simp only [LinearMap.mem_range, LinearMap.mem_ker, coeff0, LinearMap.coe_mk, AddHom.coe_mk]
    constructor
    · rintro ⟨f, rfl⟩
      change eBasis.repr (T f : HCircle) 0 = 0
      rw [blockPP_shift_apply, repr_shiftL2]
      exact (mem_hardyPlus_iff f.1).mp f.2 (-1) (by norm_num)
    · intro hg0
      have hf_mem : shiftL2.symm g.1 ∈ hardyPlus := by
        rw [mem_hardyPlus_iff]
        intro n hn
        rw [repr_shiftL2_symm]
        by_cases hn1 : n = -1
        · subst hn1; simpa using hg0
        · exact (mem_hardyPlus_iff g.1).mp g.2 (n + 1) (by omega)
      refine ⟨⟨shiftL2.symm g.1, hf_mem⟩, ?_⟩
      apply Subtype.ext
      change (T ⟨shiftL2.symm g.1, hf_mem⟩ : HCircle) = g.1
      rw [blockPP_shift_apply]
      exact shiftL2.apply_symm_apply g.1
  have hsurj : Function.Surjective coeff0 := by
    intro c
    refine ⟨c • e0, ?_⟩
    change eBasis.repr (c • eBasis 0) 0 = c
    rw [map_smul, lp.coeFn_smul, Pi.smul_apply, HilbertBasis.repr_self, lp.single_apply]
    simp
  let eCoker : (hardyPolarization.HPlus ⧸ LinearMap.range T.toLinearMap) ≃ₗ[ℂ] ℂ :=
    (Submodule.quotEquivOfEq _ _ hrange).trans (coeff0.quotKerEquivOfSurjective hsurj)
  change (Module.finrank ℂ (LinearMap.ker T.toLinearMap) : ℤ) -
    (Module.finrank ℂ (hardyPolarization.HPlus ⧸ LinearMap.range T.toLinearMap) : ℤ) = -1
  rw [hker, finrank_bot, eCoker.finrank_eq, Module.finrank_self]
  norm_num

/-- **Corollary (Virtual Dimension Shift):** Multiplying any `W ∈ Gr_res(L²(S¹))` by `z`
decreases its virtual dimension by `1`. -/
theorem virtualDim_shift_smul (W : SatoGr hardyPolarization) :
    virtualDim (shiftGLRes • W) = virtualDim W - 1 := by
  rw [virtualDim_smul, glResIndex_shift]
  ring

/-- **Corollary (Winding Sector Bijection):** `z^k · H₊` lies in the connected component
of virtual dimension `-k` for every `k ∈ ℤ`. -/
theorem virtualDim_shift_zpow (k : ℤ) :
    virtualDim ((shiftGLRes ^ k) • basepoint hardyPolarization) = -k := by
  have hhom : ∀ n : ℤ, glResIndex hardyPolarization (shiftGLRes ^ n) = -n := by
    let φ : GLRes hardyPolarization →* Multiplicative ℤ :=
      { toFun := fun g => Multiplicative.ofAdd (glResIndex hardyPolarization g)
        map_one' := by
          change Multiplicative.ofAdd (fredholmIndex (blockPP hardyPolarization (ContinuousLinearMap.id ℂ HCircle))) = 1
          rw [blockPP_id]
          exact congrArg Multiplicative.ofAdd
            (fredholmIndex_of_equiv (ContinuousLinearEquiv.refl ℂ hardyPolarization.HPlus))
        map_mul' := fun g h => by
          change Multiplicative.ofAdd (glResIndex hardyPolarization (g * h)) =
            Multiplicative.ofAdd (glResIndex hardyPolarization g) *
            Multiplicative.ofAdd (glResIndex hardyPolarization h)
          rw [glResIndex_mul, ofAdd_add] }
    intro n
    have := map_zpow φ shiftGLRes n
    have hval := congrArg Multiplicative.toAdd this
    simp only [φ, MonoidHom.coe_mk, OneHom.coe_mk, toAdd_ofAdd, toAdd_zpow, glResIndex_shift] at hval
    simpa [zsmul_eq_mul] using hval
  rw [virtualDim_smul, hhom k, virtualDim_basepoint, add_zero]

end Signals.SatoGrassmannian.CircleL2
