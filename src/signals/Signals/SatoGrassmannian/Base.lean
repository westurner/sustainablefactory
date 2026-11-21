import Mathlib.Analysis.InnerProductSpace.Projection.Basic
import Mathlib.Analysis.InnerProductSpace.Spectrum
import Mathlib.Analysis.Normed.Operator.Banach
import Mathlib.Analysis.Normed.Operator.Compact.Basic
import Mathlib.Analysis.Normed.Module.FiniteDimension
import Mathlib.Analysis.Normed.Group.Quotient
import Mathlib.LinearAlgebra.Dimension.Finrank

open scoped InnerProductSpace

namespace Signals.SatoGrassmannian

universe u

/-! ## Section 1: Fredholm Operators, Kato's Lemma, and Index Additivity -/

section FredholmTheory

variable {𝕜 : Type*} [RCLike 𝕜]
variable {E F G : Type*}
  [NormedAddCommGroup E] [NormedSpace 𝕜 E]
  [NormedAddCommGroup F] [NormedSpace 𝕜 F]
  [NormedAddCommGroup G] [NormedSpace 𝕜 G]

/-- A bounded linear operator is Fredholm if its kernel and cokernel are
finite-dimensional and its range is closed. -/
structure IsFredholm (T : E →L[𝕜] F) : Prop where
  finDimKer : FiniteDimensional 𝕜 (LinearMap.ker T.toLinearMap)
  finDimCoker : FiniteDimensional 𝕜 (F ⧸ LinearMap.range T.toLinearMap)
  closedRange : IsClosed (LinearMap.range T.toLinearMap : Set F)

/-- The Fredholm index `dim(ker T) - dim(coker T) ∈ ℤ`. -/
noncomputable def fredholmIndex (T : E →L[𝕜] F) : ℤ :=
  (Module.finrank 𝕜 (LinearMap.ker T.toLinearMap) : ℤ) -
    (Module.finrank 𝕜 (F ⧸ LinearMap.range T.toLinearMap) : ℤ)

/-- Every topological linear isomorphism is Fredholm. -/
theorem isFredholm_of_equiv (e : E ≃L[𝕜] F) : IsFredholm (e : E →L[𝕜] F) where
  finDimKer := by
    change FiniteDimensional 𝕜 (LinearMap.ker (e : E ≃ₗ[𝕜] F).toLinearMap)
    rw [LinearEquiv.ker (e : E ≃ₗ[𝕜] F)]
    infer_instance
  finDimCoker := by
    change FiniteDimensional 𝕜 (F ⧸ LinearMap.range (e : E ≃ₗ[𝕜] F).toLinearMap)
    rw [LinearEquiv.range (e : E ≃ₗ[𝕜] F)]
    have : Subsingleton (F ⧸ (⊤ : Submodule 𝕜 F)) :=
      Submodule.Quotient.subsingleton_iff.mpr rfl
    infer_instance
  closedRange := by
    change IsClosed (LinearMap.range (e : E ≃ₗ[𝕜] F).toLinearMap : Set F)
    rw [LinearEquiv.range (e : E ≃ₗ[𝕜] F)]
    exact isClosed_univ

/-- Every topological linear isomorphism has Fredholm index `0`. -/
theorem fredholmIndex_of_equiv (e : E ≃L[𝕜] F) : fredholmIndex (e : E →L[𝕜] F) = 0 := by
  unfold fredholmIndex
  change (Module.finrank 𝕜 (LinearMap.ker (e : E ≃ₗ[𝕜] F).toLinearMap) : ℤ) -
    (Module.finrank 𝕜 (F ⧸ LinearMap.range (e : E ≃ₗ[𝕜] F).toLinearMap) : ℤ) = 0
  rw [LinearEquiv.ker (e : E ≃ₗ[𝕜] F), LinearEquiv.range (e : E ≃ₗ[𝕜] F)]
  have : Subsingleton (F ⧸ (⊤ : Submodule 𝕜 F)) :=
    Submodule.Quotient.subsingleton_iff.mpr rfl
  rw [finrank_bot, Module.finrank_zero_of_subsingleton]
  simp

/-- If both kernel and range of a linear map are finite-dimensional, so is its domain. -/
lemma finiteDimensional_of_ker_range {V W : Type*} [AddCommGroup V] [Module 𝕜 V]
    [AddCommGroup W] [Module 𝕜 W] (f : V →ₗ[𝕜] W)
    [FiniteDimensional 𝕜 (LinearMap.ker f)]
    [FiniteDimensional 𝕜 (LinearMap.range f)] :
    FiniteDimensional 𝕜 V := by
  have : FiniteDimensional 𝕜 (V ⧸ LinearMap.ker f) :=
    f.quotKerEquivRange.symm.finiteDimensional
  exact Module.Finite.of_submodule_quotient (LinearMap.ker f)

/-- **Kato's Closed-Range Lemma:** Any bounded linear operator between Banach spaces
with finite-dimensional cokernel automatically has closed range. -/
theorem closedRange_of_finiteDimensional_coker [CompleteSpace E] [CompleteSpace F]
    (A : E →L[𝕜] F) [FiniteDimensional 𝕜 (F ⧸ LinearMap.range A.toLinearMap)] :
    IsClosed (LinearMap.range A.toLinearMap : Set F) := by
  have hkerClosed : IsClosed (LinearMap.ker A.toLinearMap : Set E) :=
    isClosed_singleton.preimage A.continuous
  have : IsClosed (LinearMap.ker A.toLinearMap : Set E) := hkerClosed
  obtain ⟨N, hN⟩ := Submodule.exists_isCompl (LinearMap.range A.toLinearMap)
  have : FiniteDimensional 𝕜 N :=
    LinearEquiv.finiteDimensional
      (Submodule.quotientEquivOfIsCompl (LinearMap.range A.toLinearMap) N hN)
  have : CompleteSpace N := FiniteDimensional.complete 𝕜 N
  let qA : (E ⧸ LinearMap.ker A.toLinearMap) →L[𝕜] F :=
    { toLinearMap := (LinearMap.ker A.toLinearMap).liftQ A.toLinearMap le_rfl
      cont := isQuotientMap_quotient_mk'.continuous_iff.mpr A.continuous }
  let Φ : ((E ⧸ LinearMap.ker A.toLinearMap) × N) →L[𝕜] F :=
    qA.comp (ContinuousLinearMap.fst 𝕜 _ _) + N.subtypeL.comp (ContinuousLinearMap.snd 𝕜 _ _)
  have hΦ_inj : Function.Injective Φ := by
    rw [injective_iff_map_eq_zero]
    rintro ⟨q, n⟩ hqn
    obtain ⟨x, rfl⟩ := Submodule.Quotient.mk_surjective _ q
    have hsum : A x + (n : F) = 0 := hqn
    have hAx_mem : A x ∈ LinearMap.range A.toLinearMap := ⟨x, rfl⟩
    have hn_mem : (n : F) ∈ LinearMap.range A.toLinearMap := by
      have : (n : F) = -(A x) := eq_neg_of_add_eq_zero_right hsum
      rw [this]
      exact (LinearMap.range A.toLinearMap).neg_mem hAx_mem
    have hn0 : (n : F) = 0 := by
      have hmem : (n : F) ∈ LinearMap.range A.toLinearMap ⊓ N := ⟨hn_mem, n.2⟩
      rwa [hN.inf_eq_bot, Submodule.mem_bot] at hmem
    have hAx0 : A x = 0 := by simpa [hn0] using hsum
    ext
    · exact (Submodule.Quotient.mk_eq_zero _).mpr hAx0
    · exact hn0
  have hΦ_surj : Function.Surjective Φ := by
    intro y
    have hy : y ∈ LinearMap.range A.toLinearMap ⊔ N := by
      rw [hN.sup_eq_top]
      trivial
    obtain ⟨u, ⟨x, rfl⟩, v, hv, rfl⟩ := Submodule.mem_sup.mp hy
    exact ⟨(Submodule.Quotient.mk x, ⟨v, hv⟩), rfl⟩
  let e : ((E ⧸ LinearMap.ker A.toLinearMap) × N) ≃L[𝕜] F :=
    ContinuousLinearEquiv.ofBijective Φ (LinearMap.ker_eq_bot.mpr hΦ_inj)
      (LinearMap.range_eq_top.mpr hΦ_surj)
  have hrange_eq : (LinearMap.range A.toLinearMap : Set F) =
      e '' (Set.univ ×ˢ ({0} : Set N)) := by
    ext y
    constructor
    · rintro ⟨x, rfl⟩
      exact ⟨(Submodule.Quotient.mk x, 0), ⟨trivial, rfl⟩, by simp [e, Φ, qA]⟩
    · rintro ⟨⟨q, n⟩, ⟨_, hn⟩, rfl⟩
      obtain ⟨x, rfl⟩ := Submodule.Quotient.mk_surjective _ q
      simp only [Set.mem_singleton_iff] at hn
      subst hn
      exact ⟨x, by simp [e, Φ, qA]⟩
  rw [hrange_eq]
  exact e.toHomeomorph.isClosedMap _ (isClosed_univ.prod isClosed_singleton)

/-- **Purely Algebraic Index Additivity (6-Term Exact Sequence):**
Proves finite-dimensionality of `ker (S ∘ T)` and `coker (S ∘ T)` together with
`ind(S ∘ T) = ind(S) + ind(T)` using only linear algebra. -/
theorem fredholm_comp_algebraic (S : F →L[𝕜] G) (T : E →L[𝕜] F)
    [hKT : FiniteDimensional 𝕜 (LinearMap.ker T.toLinearMap)]
    [hKS : FiniteDimensional 𝕜 (LinearMap.ker S.toLinearMap)]
    [hCT : FiniteDimensional 𝕜 (F ⧸ LinearMap.range T.toLinearMap)]
    [hCS : FiniteDimensional 𝕜 (G ⧸ LinearMap.range S.toLinearMap)] :
    FiniteDimensional 𝕜 (LinearMap.ker (S.comp T).toLinearMap) ∧
    FiniteDimensional 𝕜 (G ⧸ LinearMap.range (S.comp T).toLinearMap) ∧
    fredholmIndex (S.comp T) = fredholmIndex S + fredholmIndex T := by
  let f₁ : LinearMap.ker (S.comp T).toLinearMap →ₗ[𝕜] LinearMap.ker S.toLinearMap :=
    { toFun := fun x => ⟨T x.1, x.2⟩
      map_add' := fun x y => by ext; exact map_add T x.1 y.1
      map_smul' := fun c x => by ext; exact map_smul T c x.1 }
  let eKer₁ : LinearMap.ker f₁ ≃ₗ[𝕜] LinearMap.ker T.toLinearMap :=
    { toFun := fun x => ⟨x.1.1, by
        have hx : f₁ x.1 = 0 := x.2
        exact congrArg Subtype.val hx⟩
      invFun := fun x => ⟨⟨x.1, by
        change S (T x.1) = 0
        have hx : T x.1 = 0 := x.2
        rw [hx, map_zero]⟩, by
        ext
        exact x.2⟩
      left_inv := fun ⟨⟨_, _⟩, _⟩ => rfl
      right_inv := fun ⟨_, _⟩ => rfl
      map_add' := fun _ _ => rfl
      map_smul' := fun _ _ => rfl }
  have : FiniteDimensional 𝕜 (LinearMap.ker f₁) := eKer₁.symm.finiteDimensional
  have : FiniteDimensional 𝕜 (LinearMap.range f₁) := inferInstance
  have hKST : FiniteDimensional 𝕜 (LinearMap.ker (S.comp T).toLinearMap) :=
    finiteDimensional_of_ker_range f₁
  have h1 : Module.finrank 𝕜 (LinearMap.range f₁) + Module.finrank 𝕜 (LinearMap.ker T.toLinearMap) =
      Module.finrank 𝕜 (LinearMap.ker (S.comp T).toLinearMap) := by
    rw [← eKer₁.finrank_eq]
    exact LinearMap.finrank_range_add_finrank_ker f₁
  let f₂ : LinearMap.ker S.toLinearMap →ₗ[𝕜] (F ⧸ LinearMap.range T.toLinearMap) :=
    (LinearMap.range T.toLinearMap).mkQ.comp (LinearMap.ker S.toLinearMap).subtype
  have hker2 : LinearMap.ker f₂ = LinearMap.range f₁ := by
    ext ⟨y, hy⟩
    simp only [LinearMap.mem_ker, LinearMap.comp_apply, Submodule.coe_subtype,
      Submodule.mkQ_apply, Submodule.Quotient.mk_eq_zero, LinearMap.mem_range, f₂, f₁]
    constructor
    · rintro ⟨x, rfl⟩
      exact ⟨⟨x, hy⟩, rfl⟩
    · rintro ⟨⟨x, _⟩, hxy⟩
      exact ⟨x, congrArg Subtype.val hxy⟩
  have h2 : Module.finrank 𝕜 (LinearMap.range f₂) + Module.finrank 𝕜 (LinearMap.range f₁) =
      Module.finrank 𝕜 (LinearMap.ker S.toLinearMap) := by
    rw [← hker2]
    exact LinearMap.finrank_range_add_finrank_ker f₂
  have hmap_le : LinearMap.range T.toLinearMap ≤ (LinearMap.range (S.comp T).toLinearMap).comap S.toLinearMap := by
    rintro _ ⟨x, rfl⟩
    exact ⟨x, rfl⟩
  let f₃ : (F ⧸ LinearMap.range T.toLinearMap) →ₗ[𝕜] (G ⧸ LinearMap.range (S.comp T).toLinearMap) :=
    Submodule.mapQ (LinearMap.range T.toLinearMap) (LinearMap.range (S.comp T).toLinearMap) S.toLinearMap hmap_le
  have hker3 : LinearMap.ker f₃ = LinearMap.range f₂ := by
    ext q
    obtain ⟨y, rfl⟩ := Submodule.Quotient.mk_surjective _ q
    simp only [LinearMap.mem_ker, LinearMap.mem_range, f₃, f₂, Submodule.mapQ_apply,
      Submodule.Quotient.mk_eq_zero, LinearMap.comp_apply, Submodule.coe_subtype,
      Submodule.mkQ_apply]
    constructor
    · rintro ⟨x, hx⟩
      have hST : S (T x) = S y := hx
      have hsub : y - T x ∈ LinearMap.ker S.toLinearMap := by
        change S (y - T x) = 0
        rw [map_sub, hST, sub_self]
      refine ⟨⟨y - T x, hsub⟩, ?_⟩
      rw [Submodule.Quotient.eq]
      have : (y - T x) - y = -(T x) := by abel
      rw [this]
      exact (LinearMap.range T.toLinearMap).neg_mem ⟨x, rfl⟩
    · rintro ⟨⟨z, hz⟩, hzy⟩
      rw [Submodule.Quotient.eq] at hzy
      obtain ⟨x, hx⟩ := (LinearMap.range T.toLinearMap).neg_mem hzy
      refine ⟨x, ?_⟩
      have hTx : T x = y - z := by
        have h1 : -(z - y) = T x := hx.symm
        rw [← h1]; abel
      have hyz : y = z + T x := by rw [hTx]; abel
      change S (T x) = S y
      have hSz : S z = 0 := hz
      rw [hyz, map_add, hSz, zero_add]
  have h3 : Module.finrank 𝕜 (LinearMap.range f₃) + Module.finrank 𝕜 (LinearMap.range f₂) =
      Module.finrank 𝕜 (F ⧸ LinearMap.range T.toLinearMap) := by
    rw [← hker3]
    exact LinearMap.finrank_range_add_finrank_ker f₃
  have hsub_le : LinearMap.range (S.comp T).toLinearMap ≤ LinearMap.range S.toLinearMap := by
    rintro _ ⟨x, rfl⟩
    exact ⟨T x, rfl⟩
  let f₄ : (G ⧸ LinearMap.range (S.comp T).toLinearMap) →ₗ[𝕜] (G ⧸ LinearMap.range S.toLinearMap) :=
    Submodule.factor hsub_le
  have hker4 : LinearMap.ker f₄ = LinearMap.range f₃ := by
    ext q
    obtain ⟨z, rfl⟩ := Submodule.Quotient.mk_surjective _ q
    change (Submodule.Quotient.mk z : G ⧸ LinearMap.range S.toLinearMap) = 0 ↔
      ∃ q', f₃ q' = Submodule.Quotient.mk z
    rw [Submodule.Quotient.mk_eq_zero]
    constructor
    · rintro ⟨y, rfl⟩
      exact ⟨Submodule.Quotient.mk y, rfl⟩
    · rintro ⟨q', hq'⟩
      obtain ⟨y, rfl⟩ := Submodule.Quotient.mk_surjective _ q'
      simp only [f₃, Submodule.mapQ_apply] at hq'
      rw [Submodule.Quotient.eq] at hq'
      obtain ⟨x, hx⟩ := hq'
      refine ⟨y - T x, ?_⟩
      have hST : S (T x) = S y - z := hx
      change S (y - T x) = z
      rw [map_sub, hST]
      abel
  have hrange4 : LinearMap.range f₄ = ⊤ :=
    LinearMap.range_eq_top.mpr (Submodule.factor_surjective hsub_le)
  have : FiniteDimensional 𝕜 (LinearMap.range f₃) :=
    Module.Finite.range f₃
  have : FiniteDimensional 𝕜 (LinearMap.ker f₄) := by
    rw [hker4]; infer_instance
  have : FiniteDimensional 𝕜 (LinearMap.range f₄) := by
    rw [hrange4]; exact (Submodule.topEquiv).symm.finiteDimensional
  have hCST : FiniteDimensional 𝕜 (G ⧸ LinearMap.range (S.comp T).toLinearMap) :=
    finiteDimensional_of_ker_range f₄
  have h4 : Module.finrank 𝕜 (G ⧸ LinearMap.range S.toLinearMap) + Module.finrank 𝕜 (LinearMap.range f₃) =
      Module.finrank 𝕜 (G ⧸ LinearMap.range (S.comp T).toLinearMap) := by
    have hr := LinearMap.finrank_range_add_finrank_ker f₄
    rw [hrange4, finrank_top, hker4] at hr
    exact hr
  refine ⟨hKST, hCST, ?_⟩
  unfold fredholmIndex
  omega

/-- **Theorem 1 (Fredholm Composition):** The composition of two Fredholm operators
between Banach spaces is Fredholm. -/
theorem IsFredholm.comp [CompleteSpace E] [CompleteSpace F] [CompleteSpace G]
    {S : F →L[𝕜] G} {T : E →L[𝕜] F} (hS : IsFredholm S) (hT : IsFredholm T) :
    IsFredholm (S.comp T) := by
  have := hT.finDimKer
  have := hS.finDimKer
  have := hT.finDimCoker
  have := hS.finDimCoker
  obtain ⟨hK, hC, _⟩ := fredholm_comp_algebraic S T
  have := hC
  exact ⟨hK, hC, closedRange_of_finiteDimensional_coker (S.comp T)⟩

/-- **Theorem 2 (Fredholm Index Additivity):** `ind(S ∘ T) = ind(S) + ind(T)`. -/
theorem fredholmIndex_comp {S : F →L[𝕜] G} {T : E →L[𝕜] F}
    (hS : IsFredholm S) (hT : IsFredholm T) :
    fredholmIndex (S.comp T) = fredholmIndex S + fredholmIndex T := by
  have := hT.finDimKer
  have := hS.finDimKer
  have := hT.finDimCoker
  have := hS.finDimCoker
  exact (fredholm_comp_algebraic S T).2.2

/-! ## Section 2: Compact Perturbation Interface & Atkinson's Theorem -/

/-- Minimal analytic input (Riesz–Schauder / Dieudonné compact-perturbation stability):
adding a compact operator preserves the Fredholm property and its index. -/
class CompactFredholmTheory.{v} (𝕜 : Type*) [RCLike 𝕜] : Prop where
  add_compact : ∀ {E F : Type v}
    [NormedAddCommGroup E] [NormedSpace 𝕜 E] [CompleteSpace E]
    [NormedAddCommGroup F] [NormedSpace 𝕜 F] [CompleteSpace F]
    {T K : E →L[𝕜] F},
    IsFredholm T → IsCompactOperator (K : E → F) →
    IsFredholm (T + K) ∧ fredholmIndex (T + K) = fredholmIndex T

/-- **Theorem 3 (Atkinson's Parametrix Sufficiency — Derived):**
If `T` is invertible modulo compact operators, then `T` is Fredholm. -/
theorem isFredholm_of_parametrix [CompactFredholmTheory.{u} 𝕜]
    {E F : Type u} [NormedAddCommGroup E] [NormedSpace 𝕜 E] [CompleteSpace E]
    [NormedAddCommGroup F] [NormedSpace 𝕜 F] [CompleteSpace F]
    {T : E →L[𝕜] F} {L R : F →L[𝕜] E}
    (hL : IsCompactOperator ((L.comp T - ContinuousLinearMap.id 𝕜 E : E →L[𝕜] E) : E → E))
    (hR : IsCompactOperator ((T.comp R - ContinuousLinearMap.id 𝕜 F : F →L[𝕜] F) : F → F)) :
    IsFredholm T := by
  have hLT : IsFredholm (L.comp T) := by
    have heq : L.comp T = ContinuousLinearMap.id 𝕜 E + (L.comp T - ContinuousLinearMap.id 𝕜 E) := by
      abel
    rw [heq]
    exact (CompactFredholmTheory.add_compact (𝕜 := 𝕜)
      (isFredholm_of_equiv (ContinuousLinearEquiv.refl 𝕜 E)) hL).1
  have hker_le : LinearMap.ker T.toLinearMap ≤ LinearMap.ker (L.comp T).toLinearMap := by
    intro x hx
    change L (T x) = 0
    have hx' : T x = 0 := hx
    rw [hx', map_zero]
  have := hLT.finDimKer
  have hFinKer : FiniteDimensional 𝕜 (LinearMap.ker T.toLinearMap) :=
    Module.Finite.of_injective (Submodule.inclusion hker_le)
      (Submodule.inclusion_injective hker_le)
  have hTR : IsFredholm (T.comp R) := by
    have heq : T.comp R = ContinuousLinearMap.id 𝕜 F + (T.comp R - ContinuousLinearMap.id 𝕜 F) := by
      abel
    rw [heq]
    exact (CompactFredholmTheory.add_compact (𝕜 := 𝕜)
      (isFredholm_of_equiv (ContinuousLinearEquiv.refl 𝕜 F)) hR).1
  have hrange_le : LinearMap.range (T.comp R).toLinearMap ≤ LinearMap.range T.toLinearMap := by
    rintro _ ⟨y, rfl⟩
    exact ⟨R y, rfl⟩
  have := hTR.finDimCoker
  have hFinCoker : FiniteDimensional 𝕜 (F ⧸ LinearMap.range T.toLinearMap) :=
    Module.Finite.of_surjective (Submodule.factor hrange_le)
      (Submodule.factor_surjective hrange_le)
  exact ⟨hFinKer, hFinCoker, closedRange_of_finiteDimensional_coker T⟩

end FredholmTheory

/-! ## Section 3: Polarized Hilbert Space & Restricted General Linear Group `GL_res(H)` -/

/-- A complex Hilbert space equipped with an orthogonal polarization `H = H₊ ⊕ H₋`. -/
structure PolarizedHilbertSpace (𝕜 : Type*) [RCLike 𝕜] (H : Type u)
    [NormedAddCommGroup H] [InnerProductSpace 𝕜 H] [CompleteSpace H] where
  HPlus : Submodule 𝕜 H
  HMinus : Submodule 𝕜 H
  complete_HPlus : CompleteSpace HPlus
  complete_HMinus : CompleteSpace HMinus
  ortho_eq : HMinus = HPlusᗮ

attribute [instance] PolarizedHilbertSpace.complete_HPlus
attribute [instance] PolarizedHilbertSpace.complete_HMinus

section BlockCalculus

variable {𝕜 : Type*} [RCLike 𝕜] {H : Type u}
  [NormedAddCommGroup H] [InnerProductSpace 𝕜 H] [CompleteSpace H]

noncomputable def PPlus (P : PolarizedHilbertSpace 𝕜 H) : H →L[𝕜] H :=
  P.HPlus.subtypeL.comp P.HPlus.orthogonalProjectionOnto

noncomputable def PMinus (P : PolarizedHilbertSpace 𝕜 H) : H →L[𝕜] H :=
  P.HMinus.subtypeL.comp P.HMinus.orthogonalProjectionOnto

/-- The polarization involution `J = P₊ - P₋`. -/
noncomputable def polarizationJ (P : PolarizedHilbertSpace 𝕜 H) : H →L[𝕜] H :=
  PPlus P - PMinus P

/-- The 2×2 block components of `A : H →L[𝕜] H` relative to `H = H₊ ⊕ H₋`. -/
noncomputable def blockPP (P : PolarizedHilbertSpace 𝕜 H) (A : H →L[𝕜] H) : P.HPlus →L[𝕜] P.HPlus :=
  P.HPlus.orthogonalProjectionOnto.comp (A.comp P.HPlus.subtypeL)

noncomputable def blockPM (P : PolarizedHilbertSpace 𝕜 H) (A : H →L[𝕜] H) : P.HMinus →L[𝕜] P.HPlus :=
  P.HPlus.orthogonalProjectionOnto.comp (A.comp P.HMinus.subtypeL)

noncomputable def blockMP (P : PolarizedHilbertSpace 𝕜 H) (A : H →L[𝕜] H) : P.HPlus →L[𝕜] P.HMinus :=
  P.HMinus.orthogonalProjectionOnto.comp (A.comp P.HPlus.subtypeL)

noncomputable def blockMM (P : PolarizedHilbertSpace 𝕜 H) (A : H →L[𝕜] H) : P.HMinus →L[𝕜] P.HMinus :=
  P.HMinus.orthogonalProjectionOnto.comp (A.comp P.HMinus.subtypeL)

lemma pPlus_add_pMinus (P : PolarizedHilbertSpace 𝕜 H) (x : H) :
    PPlus P x + PMinus P x = x := by
  simp [PPlus, PMinus, P.ortho_eq]

lemma orthoProj_plus_of_mem_minus (P : PolarizedHilbertSpace 𝕜 H) (y : P.HMinus) :
    P.HPlus.orthogonalProjectionOnto (y : H) = 0 := by
  have hy : (y : H) ∈ P.HPlusᗮ := P.ortho_eq ▸ y.2
  exact Submodule.orthogonalProjectionOnto_eq_zero_iff.mpr hy

lemma orthoProj_minus_of_mem_plus (P : PolarizedHilbertSpace 𝕜 H) (x : P.HPlus) :
    P.HMinus.orthogonalProjectionOnto (x : H) = 0 := by
  have hx : (x : H) ∈ P.HMinusᗮ := by
    rw [P.ortho_eq]
    exact Submodule.le_orthogonal_orthogonal P.HPlus x.2
  exact Submodule.orthogonalProjectionOnto_eq_zero_iff.mpr hx

/-- Block multiplication law `(A ∘ B)₊₊ = A₊₊ B₊₊ + A₊₋ B₋₊`. -/
theorem blockPP_comp (P : PolarizedHilbertSpace 𝕜 H) (A B : H →L[𝕜] H) :
    blockPP P (A.comp B) =
      (blockPP P A).comp (blockPP P B) + (blockPM P A).comp (blockMP P B) := by
  ext x
  have hBx : B (x : H) =
      ((blockPP P B x : P.HPlus) : H) + ((blockMP P B x : P.HMinus) : H) :=
    (pPlus_add_pMinus P (B (x : H))).symm
  change (P.HPlus.orthogonalProjectionOnto (A (B (x : H))) : H) =
    (P.HPlus.orthogonalProjectionOnto (A ((blockPP P B x : P.HPlus) : H)) : H) +
    (P.HPlus.orthogonalProjectionOnto (A ((blockMP P B x : P.HMinus) : H)) : H)
  conv_lhs => rw [hBx, map_add, map_add]
  rfl

lemma blockPP_id (P : PolarizedHilbertSpace 𝕜 H) :
    blockPP P (ContinuousLinearMap.id 𝕜 H) = ContinuousLinearMap.id 𝕜 P.HPlus := by
  ext x
  simp [blockPP]

/-- Exact block formula for the commutator `[J, A] = J A - A J`. -/
theorem commutator_J_eq (P : PolarizedHilbertSpace 𝕜 H) (A : H →L[𝕜] H) :
    (polarizationJ P).comp A - A.comp (polarizationJ P) =
      (2 : 𝕜) • (P.HPlus.subtypeL.comp ((blockPM P A).comp P.HMinus.orthogonalProjectionOnto) -
                 P.HMinus.subtypeL.comp ((blockMP P A).comp P.HPlus.orthogonalProjectionOnto)) := by
  ext x
  set xp : P.HPlus := P.HPlus.orthogonalProjectionOnto x
  set xm : P.HMinus := P.HMinus.orthogonalProjectionOnto x
  have hx : x = (xp : H) + (xm : H) := (pPlus_add_pMinus P x).symm
  have hJ_plus : ∀ u : P.HPlus, polarizationJ P (u : H) = (u : H) := fun u => by
    change (P.HPlus.orthogonalProjectionOnto (u : H) : H) -
      (P.HMinus.orthogonalProjectionOnto (u : H) : H) = (u : H)
    rw [Submodule.orthogonalProjectionOnto_mem_subspace_eq_self u,
      orthoProj_minus_of_mem_plus P u]
    simp
  have hJ_minus : ∀ v : P.HMinus, polarizationJ P (v : H) = -(v : H) := fun v => by
    change (P.HPlus.orthogonalProjectionOnto (v : H) : H) -
      (P.HMinus.orthogonalProjectionOnto (v : H) : H) = -(v : H)
    rw [orthoProj_plus_of_mem_minus P v,
      Submodule.orthogonalProjectionOnto_mem_subspace_eq_self v]
    simp
  have hJx : polarizationJ P x = (xp : H) - (xm : H) := by
    conv_lhs => rw [hx, map_add, hJ_plus xp, hJ_minus xm]
    abel
  have hAp : A (xp : H) =
      ((blockPP P A xp : P.HPlus) : H) + ((blockMP P A xp : P.HMinus) : H) :=
    (pPlus_add_pMinus P (A (xp : H))).symm
  have hAm : A (xm : H) =
      ((blockPM P A xm : P.HPlus) : H) + ((blockMM P A xm : P.HMinus) : H) :=
    (pPlus_add_pMinus P (A (xm : H))).symm
  change polarizationJ P (A x) - A (polarizationJ P x) =
    (2 : 𝕜) • (((blockPM P A xm : P.HPlus) : H) - ((blockMP P A xp : P.HMinus) : H))
  rw [hJx]
  conv_lhs => rw [hx]
  rw [map_add, map_sub, map_add, hAp, hAm, map_add, map_add,
    hJ_plus (blockPP P A xp), hJ_minus (blockMP P A xp),
    hJ_plus (blockPM P A xm), hJ_minus (blockMM P A xm), two_smul]
  abel

/-- `g ∈ GL_res(H)` iff its commutator with `J` is compact. -/
theorem isCompact_commutator_J_iff (P : PolarizedHilbertSpace 𝕜 H) (A : H →L[𝕜] H) :
    IsCompactOperator (((polarizationJ P).comp A - A.comp (polarizationJ P) : H →L[𝕜] H) : H → H) ↔
    IsCompactOperator ((blockPM P A : P.HMinus →L[𝕜] P.HPlus) : P.HMinus → P.HPlus) ∧
    IsCompactOperator ((blockMP P A : P.HPlus →L[𝕜] P.HMinus) : P.HPlus → P.HMinus) := by
  have h2ne : (2 : 𝕜) ≠ 0 := two_ne_zero
  constructor
  · intro hC
    have hPM_eq : (2 : 𝕜) • blockPM P A =
        P.HPlus.orthogonalProjectionOnto.comp
          (((polarizationJ P).comp A - A.comp (polarizationJ P)).comp P.HMinus.subtypeL) := by
      rw [commutator_J_eq]
      ext y
      simp [orthoProj_plus_of_mem_minus, smul_sub]
    have hMP_eq : (-(2 : 𝕜)) • blockMP P A =
        P.HMinus.orthogonalProjectionOnto.comp
          (((polarizationJ P).comp A - A.comp (polarizationJ P)).comp P.HPlus.subtypeL) := by
      rw [commutator_J_eq]
      ext x
      simp [orthoProj_minus_of_mem_plus, smul_sub]
    have hPM : IsCompactOperator ((blockPM P A : P.HMinus →L[𝕜] P.HPlus) : P.HMinus → P.HPlus) := by
      have hscaled : IsCompactOperator (((2 : 𝕜) • blockPM P A : P.HMinus →L[𝕜] P.HPlus) : P.HMinus → P.HPlus) := by
        rw [hPM_eq]
        exact (hC.comp_clm P.HMinus.subtypeL).clm_comp P.HPlus.orthogonalProjectionOnto
      simpa [inv_smul_smul₀ h2ne] using hscaled.smul (2 : 𝕜)⁻¹
    have hMP : IsCompactOperator ((blockMP P A : P.HPlus →L[𝕜] P.HMinus) : P.HPlus → P.HMinus) := by
      have hscaled : IsCompactOperator (((-(2 : 𝕜)) • blockMP P A : P.HPlus →L[𝕜] P.HMinus) : P.HPlus → P.HMinus) := by
        rw [hMP_eq]
        exact (hC.comp_clm P.HPlus.subtypeL).clm_comp P.HMinus.orthogonalProjectionOnto
      have hneg2 : (-(2 : 𝕜)) ≠ 0 := neg_ne_zero.mpr h2ne
      simpa [inv_smul_smul₀ hneg2] using hscaled.smul (-(2 : 𝕜))⁻¹
    exact ⟨hPM, hMP⟩
  · rintro ⟨hPM, hMP⟩
    rw [commutator_J_eq]
    have h1 : IsCompactOperator
        ((P.HPlus.subtypeL.comp ((blockPM P A).comp P.HMinus.orthogonalProjectionOnto) : H →L[𝕜] H) : H → H) :=
      (hPM.comp_clm P.HMinus.orthogonalProjectionOnto).clm_comp P.HPlus.subtypeL
    have h2 : IsCompactOperator
        ((P.HMinus.subtypeL.comp ((blockMP P A).comp P.HPlus.orthogonalProjectionOnto) : H →L[𝕜] H) : H → H) :=
      (hMP.comp_clm P.HPlus.orthogonalProjectionOnto).clm_comp P.HMinus.subtypeL
    exact (h1.sub h2).smul (2 : 𝕜)

/-- **Theorem 4:** The restricted general linear group `GL_res(H)` as a subgroup of `GL(H)`. -/
noncomputable def GLRes (P : PolarizedHilbertSpace 𝕜 H) : Subgroup (H ≃L[𝕜] H) where
  carrier := { g |
    IsCompactOperator ((blockPM P (g : H →L[𝕜] H) : P.HMinus →L[𝕜] P.HPlus) : P.HMinus → P.HPlus) ∧
    IsCompactOperator ((blockMP P (g : H →L[𝕜] H) : P.HPlus →L[𝕜] P.HMinus) : P.HPlus → P.HMinus) }
  one_mem' := by
    change IsCompactOperator ((blockPM P ((1 : H ≃L[𝕜] H) : H →L[𝕜] H) : P.HMinus →L[𝕜] P.HPlus) : P.HMinus → P.HPlus) ∧
      IsCompactOperator ((blockMP P ((1 : H ≃L[𝕜] H) : H →L[𝕜] H) : P.HPlus →L[𝕜] P.HMinus) : P.HPlus → P.HMinus)
    rw [← isCompact_commutator_J_iff]
    change IsCompactOperator (((polarizationJ P).comp (ContinuousLinearMap.id 𝕜 H) -
      (ContinuousLinearMap.id 𝕜 H).comp (polarizationJ P) : H →L[𝕜] H) : H → H)
    simp [isCompactOperator_zero]
  mul_mem' := by
    intro g h hg hh
    change IsCompactOperator ((blockPM P (g : H →L[𝕜] H) : P.HMinus →L[𝕜] P.HPlus) : P.HMinus → P.HPlus) ∧
      IsCompactOperator ((blockMP P (g : H →L[𝕜] H) : P.HPlus →L[𝕜] P.HMinus) : P.HPlus → P.HMinus) at hg
    change IsCompactOperator ((blockPM P (h : H →L[𝕜] H) : P.HMinus →L[𝕜] P.HPlus) : P.HMinus → P.HPlus) ∧
      IsCompactOperator ((blockMP P (h : H →L[𝕜] H) : P.HPlus →L[𝕜] P.HMinus) : P.HPlus → P.HMinus) at hh
    change IsCompactOperator ((blockPM P ((g * h : H ≃L[𝕜] H) : H →L[𝕜] H) : P.HMinus →L[𝕜] P.HPlus) : P.HMinus → P.HPlus) ∧
      IsCompactOperator ((blockMP P ((g * h : H ≃L[𝕜] H) : H →L[𝕜] H) : P.HPlus →L[𝕜] P.HMinus) : P.HPlus → P.HMinus)
    rw [← isCompact_commutator_J_iff] at hg hh ⊢
    have hderiv :
        (polarizationJ P).comp ((g : H →L[𝕜] H).comp (h : H →L[𝕜] H)) -
          ((g : H →L[𝕜] H).comp (h : H →L[𝕜] H)).comp (polarizationJ P) =
        ((polarizationJ P).comp (g : H →L[𝕜] H) - (g : H →L[𝕜] H).comp (polarizationJ P)).comp
          (h : H →L[𝕜] H) +
        (g : H →L[𝕜] H).comp
          ((polarizationJ P).comp (h : H →L[𝕜] H) - (h : H →L[𝕜] H).comp (polarizationJ P)) := by
      ext x; simp [ContinuousLinearMap.comp_apply]
    change IsCompactOperator (((polarizationJ P).comp ((g : H →L[𝕜] H).comp (h : H →L[𝕜] H)) -
      ((g : H →L[𝕜] H).comp (h : H →L[𝕜] H)).comp (polarizationJ P) : H →L[𝕜] H) : H → H)
    rw [hderiv]
    exact (hg.comp_clm (h : H →L[𝕜] H)).add (hh.clm_comp (g : H →L[𝕜] H))
  inv_mem' := by
    intro g hg
    change IsCompactOperator ((blockPM P (g : H →L[𝕜] H) : P.HMinus →L[𝕜] P.HPlus) : P.HMinus → P.HPlus) ∧
      IsCompactOperator ((blockMP P (g : H →L[𝕜] H) : P.HPlus →L[𝕜] P.HMinus) : P.HPlus → P.HMinus) at hg
    change IsCompactOperator ((blockPM P ((g⁻¹ : H ≃L[𝕜] H) : H →L[𝕜] H) : P.HMinus →L[𝕜] P.HPlus) : P.HMinus → P.HPlus) ∧
      IsCompactOperator ((blockMP P ((g⁻¹ : H ≃L[𝕜] H) : H →L[𝕜] H) : P.HPlus →L[𝕜] P.HMinus) : P.HPlus → P.HMinus)
    rw [← isCompact_commutator_J_iff] at hg ⊢
    have hinv :
        (polarizationJ P).comp (g.symm : H →L[𝕜] H) -
          (g.symm : H →L[𝕜] H).comp (polarizationJ P) =
        -((g.symm : H →L[𝕜] H).comp
          (((polarizationJ P).comp (g : H →L[𝕜] H) - (g : H →L[𝕜] H).comp (polarizationJ P)).comp
            (g.symm : H →L[𝕜] H))) := by
      ext x
      simp only [sub_apply, ContinuousLinearMap.comp_apply,
        neg_apply, map_sub, ContinuousLinearEquiv.coe_coe,
        ContinuousLinearEquiv.apply_symm_apply, ContinuousLinearEquiv.symm_apply_apply]
      abel
    change IsCompactOperator (((polarizationJ P).comp (g.symm : H →L[𝕜] H) -
      (g.symm : H →L[𝕜] H).comp (polarizationJ P) : H →L[𝕜] H) : H → H)
    rw [hinv]
    exact ((hg.comp_clm (g.symm : H →L[𝕜] H)).clm_comp (g.symm : H →L[𝕜] H)).neg

/-- For every `g ∈ GL_res(H)`, its upper-left block `g₊₊ : H₊ → H₊` is Fredholm. -/
theorem blockPP_isFredholm [CompactFredholmTheory.{u} 𝕜]
    (P : PolarizedHilbertSpace 𝕜 H) (g : GLRes P) :
    IsFredholm (blockPP P (g.1 : H →L[𝕜] H)) := by
  have hgInv : g.1⁻¹ ∈ GLRes P := (GLRes P).inv_mem g.2
  have hLeft :
      (blockPP P (g.1.symm : H →L[𝕜] H)).comp (blockPP P (g.1 : H →L[𝕜] H)) -
        ContinuousLinearMap.id 𝕜 P.HPlus =
      -((blockPM P (g.1.symm : H →L[𝕜] H)).comp (blockMP P (g.1 : H →L[𝕜] H))) := by
    have hmul := blockPP_comp P (g.1.symm : H →L[𝕜] H) (g.1 : H →L[𝕜] H)
    have hid : (g.1.symm : H →L[𝕜] H).comp (g.1 : H →L[𝕜] H) = ContinuousLinearMap.id 𝕜 H := by
      ext x; simp
    rw [hid, blockPP_id] at hmul
    exact eq_neg_of_add_eq_zero_left (by rw [hmul]; abel)
  have hRight :
      (blockPP P (g.1 : H →L[𝕜] H)).comp (blockPP P (g.1.symm : H →L[𝕜] H)) -
        ContinuousLinearMap.id 𝕜 P.HPlus =
      -((blockPM P (g.1 : H →L[𝕜] H)).comp (blockMP P (g.1.symm : H →L[𝕜] H))) := by
    have hmul := blockPP_comp P (g.1 : H →L[𝕜] H) (g.1.symm : H →L[𝕜] H)
    have hid : (g.1 : H →L[𝕜] H).comp (g.1.symm : H →L[𝕜] H) = ContinuousLinearMap.id 𝕜 H := by
      ext x; simp
    rw [hid, blockPP_id] at hmul
    exact eq_neg_of_add_eq_zero_left (by rw [hmul]; abel)
  refine isFredholm_of_parametrix (L := blockPP P (g.1.symm : H →L[𝕜] H))
    (R := blockPP P (g.1.symm : H →L[𝕜] H)) ?_ ?_
  · rw [hLeft]
    exact (hgInv.1.comp_clm (blockMP P (g.1 : H →L[𝕜] H))).neg
  · rw [hRight]
    exact (g.2.1.comp_clm (blockMP P (g.1.symm : H →L[𝕜] H))).neg

/-- The Fredholm index invariant `g ↦ ind(g₊₊) ∈ ℤ` on `GL_res(H)`. -/
noncomputable def glResIndex (P : PolarizedHilbertSpace 𝕜 H) (g : GLRes P) : ℤ :=
  fredholmIndex (blockPP P (g.1 : H →L[𝕜] H))

/-- **Theorem 5 (Index Homomorphism):** `ind((gh)₊₊) = ind(g₊₊) + ind(h₊₊)`. -/
theorem glResIndex_mul [CompactFredholmTheory.{u} 𝕜]
    (P : PolarizedHilbertSpace 𝕜 H) (g h : GLRes P) :
    glResIndex P (g * h) = glResIndex P g + glResIndex P h := by
  unfold glResIndex
  change fredholmIndex (blockPP P ((g.1 : H →L[𝕜] H).comp (h.1 : H →L[𝕜] H))) = _
  rw [blockPP_comp]
  have hFred := (blockPP_isFredholm P g).comp (blockPP_isFredholm P h)
  have hComp : IsCompactOperator
      (((blockPM P (g.1 : H →L[𝕜] H)).comp (blockMP P (h.1 : H →L[𝕜] H)) :
        P.HPlus →L[𝕜] P.HPlus) : P.HPlus → P.HPlus) :=
    g.2.1.comp_clm (blockMP P (h.1 : H →L[𝕜] H))
  rw [(CompactFredholmTheory.add_compact (𝕜 := 𝕜) hFred hComp).2]
  exact fredholmIndex_comp (blockPP_isFredholm P g) (blockPP_isFredholm P h)

end BlockCalculus

/-! ## Section 4: Sato Grassmannian, Basepoint, Big-Cell Graph Chart & `GL_res(H)` Action -/

section GroupAction

variable {𝕜 : Type*} [RCLike 𝕜] {H : Type u}
  [NormedAddCommGroup H] [InnerProductSpace 𝕜 H] [CompleteSpace H]

noncomputable def projPlus (P : PolarizedHilbertSpace 𝕜 H) (W : Submodule 𝕜 H) :
    W →L[𝕜] P.HPlus :=
  P.HPlus.orthogonalProjectionOnto.comp W.subtypeL

noncomputable def projMinus (P : PolarizedHilbertSpace 𝕜 H) (W : Submodule 𝕜 H) :
    W →L[𝕜] P.HMinus :=
  P.HMinus.orthogonalProjectionOnto.comp W.subtypeL

/-- Membership predicate for the Sato (restricted) Grassmannian `Gr_res(H)`. -/
def MemSatoGrassmannian (P : PolarizedHilbertSpace 𝕜 H) (W : Submodule 𝕜 H) : Prop :=
  IsClosed (W : Set H) ∧ IsFredholm (projPlus P W) ∧ IsCompactOperator (projMinus P W)

/-- The Sato Grassmannian `Gr_res(H)` as a subtype of closed subspaces of `H`. -/
def SatoGr (P : PolarizedHilbertSpace 𝕜 H) :=
  { W : Submodule 𝕜 H // MemSatoGrassmannian P W }

/-- The virtual dimension (Fredholm index of `p₊`) of a point `W ∈ Gr_res(H)`. -/
noncomputable def virtualDim {P : PolarizedHilbertSpace 𝕜 H} (W : SatoGr P) : ℤ :=
  fredholmIndex (projPlus P W.1)

theorem projPlus_HPlus_eq_id (P : PolarizedHilbertSpace 𝕜 H) :
    projPlus P P.HPlus = ContinuousLinearMap.id 𝕜 P.HPlus := by
  ext x
  simp [projPlus]

theorem projMinus_HPlus_eq_zero (P : PolarizedHilbertSpace 𝕜 H) :
    projMinus P P.HPlus = 0 := by
  ext x
  exact congrArg Subtype.val (orthoProj_minus_of_mem_plus P x)

/-- **Canonical Basepoint:** `H₊` belongs to `Gr_res(H)`. -/
theorem basepoint_mem (P : PolarizedHilbertSpace 𝕜 H) :
    MemSatoGrassmannian P P.HPlus := by
  refine ⟨(completeSpace_coe_iff_isComplete.mp P.complete_HPlus).isClosed, ?_, ?_⟩
  · rw [projPlus_HPlus_eq_id]
    exact isFredholm_of_equiv (ContinuousLinearEquiv.refl 𝕜 P.HPlus)
  · rw [projMinus_HPlus_eq_zero]
    exact isCompactOperator_zero

/-- The canonical basepoint `H₊` packaged as an element of `SatoGr P`. -/
def basepoint (P : PolarizedHilbertSpace 𝕜 H) : SatoGr P :=
  ⟨P.HPlus, basepoint_mem P⟩

/-- The virtual dimension of the canonical basepoint `H₊` is `0`. -/
theorem virtualDim_basepoint (P : PolarizedHilbertSpace 𝕜 H) :
    virtualDim (basepoint P) = 0 := by
  unfold virtualDim basepoint
  rw [projPlus_HPlus_eq_id]
  exact fredholmIndex_of_equiv (ContinuousLinearEquiv.refl 𝕜 P.HPlus)

/-- The graph map `Φ_T : H₊ →L[𝕜] H` sending `x ↦ x + T x`. -/
noncomputable def graphMap (P : PolarizedHilbertSpace 𝕜 H) (T : P.HPlus →L[𝕜] P.HMinus) :
    P.HPlus →L[𝕜] H :=
  P.HPlus.subtypeL + P.HMinus.subtypeL.comp T

/-- The graph subspace `Γ(T) = { x + T x | x ∈ H₊ } ≤ H`. -/
noncomputable def graphSubspace (P : PolarizedHilbertSpace 𝕜 H) (T : P.HPlus →L[𝕜] P.HMinus) :
    Submodule 𝕜 H :=
  LinearMap.range (graphMap P T).toLinearMap

lemma projPlus_graphMap (P : PolarizedHilbertSpace 𝕜 H) (T : P.HPlus →L[𝕜] P.HMinus) (x : P.HPlus) :
    P.HPlus.orthogonalProjectionOnto (graphMap P T x) = x := by
  change P.HPlus.orthogonalProjectionOnto ((x : H) + ((T x : P.HMinus) : H)) = x
  rw [map_add, Submodule.orthogonalProjectionOnto_mem_subspace_eq_self x,
    orthoProj_plus_of_mem_minus P (T x), add_zero]

lemma projMinus_graphMap (P : PolarizedHilbertSpace 𝕜 H) (T : P.HPlus →L[𝕜] P.HMinus) (x : P.HPlus) :
    P.HMinus.orthogonalProjectionOnto (graphMap P T x) = T x := by
  change P.HMinus.orthogonalProjectionOnto ((x : H) + ((T x : P.HMinus) : H)) = T x
  rw [map_add, orthoProj_minus_of_mem_plus P x,
    Submodule.orthogonalProjectionOnto_mem_subspace_eq_self (T x), zero_add]

/-- On the graph subspace `Γ(T)`, `p₊ : Γ(T) ≃L[𝕜] H₊` is a topological isomorphism. -/
noncomputable def graphProjPlusEquiv (P : PolarizedHilbertSpace 𝕜 H) (T : P.HPlus →L[𝕜] P.HMinus) :
    graphSubspace P T ≃L[𝕜] P.HPlus where
  toLinearEquiv :=
    { toFun := projPlus P (graphSubspace P T)
      invFun := fun x => ⟨graphMap P T x, ⟨x, rfl⟩⟩
      left_inv := by
        rintro ⟨w, ⟨x, rfl⟩⟩
        ext
        simp [projPlus, projPlus_graphMap]
      right_inv := fun x => projPlus_graphMap P T x
      map_add' := fun u v => map_add _ u v
      map_smul' := fun c u => map_smul _ c u }
  continuous_toFun := (projPlus P (graphSubspace P T)).continuous
  continuous_invFun := (graphMap P T).continuous.subtype_mk _

lemma graphSubspace_isClosed (P : PolarizedHilbertSpace 𝕜 H) (T : P.HPlus →L[𝕜] P.HMinus) :
    IsClosed (graphSubspace P T : Set H) := by
  have heq : (graphSubspace P T : Set H) =
      { w : H | w = graphMap P T (P.HPlus.orthogonalProjectionOnto w) } := by
    ext w
    constructor
    · rintro ⟨x, rfl⟩
      simp [projPlus_graphMap]
    · intro hw
      exact ⟨P.HPlus.orthogonalProjectionOnto w, hw.symm⟩
  rw [heq]
  exact isClosed_eq continuous_id
    ((graphMap P T).continuous.comp P.HPlus.orthogonalProjectionOnto.continuous)

/-- **Big Cell Chart:** For any compact operator `T : H₊ →L[𝕜] H₋`,
the graph subspace `Γ(T)` lies in `Gr_res(H)` and has virtual dimension `0`. -/
theorem graphSubspace_mem_bigCell (P : PolarizedHilbertSpace 𝕜 H) (T : P.HPlus →L[𝕜] P.HMinus)
    (hT : IsCompactOperator (T : P.HPlus → P.HMinus)) :
    ∃ (W : SatoGr P), W.1 = graphSubspace P T ∧ virtualDim W = 0 := by
  have hFred : IsFredholm (projPlus P (graphSubspace P T)) :=
    isFredholm_of_equiv (graphProjPlusEquiv P T)
  have hComp : IsCompactOperator (projMinus P (graphSubspace P T)) := by
    have hfactor : projMinus P (graphSubspace P T) =
        T.comp (graphProjPlusEquiv P T : graphSubspace P T →L[𝕜] P.HPlus) := by
      ext ⟨w, ⟨x, rfl⟩⟩
      simp [projMinus, projMinus_graphMap, graphProjPlusEquiv, projPlus, projPlus_graphMap]
    rw [hfactor]
    exact hT.comp_clm _
  refine ⟨⟨graphSubspace P T, graphSubspace_isClosed P T, hFred, hComp⟩, rfl, ?_⟩
  exact fredholmIndex_of_equiv (graphProjPlusEquiv P T)

end GroupAction

/-- The topological isomorphism `W ≃L[𝕜] g(W)` obtained by restricting `g : H ≃L[𝕜] H`. -/
noncomputable def restrictEquiv {𝕜 : Type*} [RCLike 𝕜] {H : Type u}
    [NormedAddCommGroup H] [NormedSpace 𝕜 H]
    (g : H ≃L[𝕜] H) (W : Submodule 𝕜 H) :
    W ≃L[𝕜] (W.map (g : H →L[𝕜] H).toLinearMap) :=
  { toFun := fun x => ⟨g x.1, ⟨x.1, x.2, rfl⟩⟩
    invFun := fun y =>
      ⟨g.symm y.1, by
        rcases y.2 with ⟨x, hx, hgx⟩
        change g x = y.1 at hgx
        rw [← hgx, g.symm_apply_apply]
        exact hx⟩
    left_inv := fun x => Subtype.ext (g.symm_apply_apply x.1)
    right_inv := fun y => Subtype.ext (g.apply_symm_apply y.1)
    map_add' := fun x y => Subtype.ext (map_add g x.1 y.1)
    map_smul' := fun c x => Subtype.ext (map_smul g c x.1)
    continuous_toFun := (g.continuous.comp continuous_subtype_val).subtype_mk _
    continuous_invFun := (g.symm.continuous.comp continuous_subtype_val).subtype_mk _ }

section GroupActionCont

variable {𝕜 : Type*} [RCLike 𝕜] {H : Type u}
  [NormedAddCommGroup H] [InnerProductSpace 𝕜 H] [CompleteSpace H]

lemma projPlus_restrictEquiv (P : PolarizedHilbertSpace 𝕜 H) (g : H ≃L[𝕜] H)
    (W : Submodule 𝕜 H) :
    (projPlus P (W.map (g : H →L[𝕜] H).toLinearMap)).comp (restrictEquiv g W : W →L[𝕜] _) =
      (blockPP P (g : H →L[𝕜] H)).comp (projPlus P W) +
      (blockPM P (g : H →L[𝕜] H)).comp (projMinus P W) := by
  ext x
  have hx : (x : H) =
      ((projPlus P W x : P.HPlus) : H) + ((projMinus P W x : P.HMinus) : H) :=
    (pPlus_add_pMinus P (x : H)).symm
  change (P.HPlus.orthogonalProjectionOnto (g (x : H)) : H) =
    (P.HPlus.orthogonalProjectionOnto (g ((projPlus P W x : P.HPlus) : H)) : H) +
    (P.HPlus.orthogonalProjectionOnto (g ((projMinus P W x : P.HMinus) : H)) : H)
  conv_lhs => rw [hx, map_add, map_add]
  rfl

lemma projMinus_restrictEquiv (P : PolarizedHilbertSpace 𝕜 H) (g : H ≃L[𝕜] H)
    (W : Submodule 𝕜 H) :
    (projMinus P (W.map (g : H →L[𝕜] H).toLinearMap)).comp (restrictEquiv g W : W →L[𝕜] _) =
      (blockMP P (g : H →L[𝕜] H)).comp (projPlus P W) +
      (blockMM P (g : H →L[𝕜] H)).comp (projMinus P W) := by
  ext x
  have hx : (x : H) =
      ((projPlus P W x : P.HPlus) : H) + ((projMinus P W x : P.HMinus) : H) :=
    (pPlus_add_pMinus P (x : H)).symm
  change (P.HMinus.orthogonalProjectionOnto (g (x : H)) : H) =
    (P.HMinus.orthogonalProjectionOnto (g ((projPlus P W x : P.HPlus) : H)) : H) +
    (P.HMinus.orthogonalProjectionOnto (g ((projMinus P W x : P.HMinus) : H)) : H)
  conv_lhs => rw [hx, map_add, map_add]
  rfl

/-- **Theorem 6 (Action Closure & Virtual Dimension Shift):**
`GL_res(H)` preserves `Gr_res(H)` and shifts virtual dimension by `ind(g₊₊)`. -/
theorem glRes_smul_mem_and_vdim [CompactFredholmTheory.{u} 𝕜]
    (P : PolarizedHilbertSpace 𝕜 H) (g : GLRes P) (W : SatoGr P) :
    MemSatoGrassmannian P (W.1.map (g.1 : H →L[𝕜] H).toLinearMap) ∧
    fredholmIndex (projPlus P (W.1.map (g.1 : H →L[𝕜] H).toLinearMap)) =
      glResIndex P g + virtualDim W := by
  let W' := W.1.map (g.1 : H →L[𝕜] H).toLinearMap
  let e : W.1 ≃L[𝕜] W' := restrictEquiv g.1 W.1
  have hClosed : IsClosed (W' : Set H) := by
    have himg : (W' : Set H) = g.1 '' (W.1 : Set H) := rfl
    rw [himg]
    exact g.1.toHomeomorph.isClosedMap _ W.2.1
  have : CompleteSpace W.1 := W.2.1.completeSpace_coe
  have : CompleteSpace W' := hClosed.completeSpace_coe
  have hCompMinus : IsCompactOperator (projMinus P W') := by
    have hfactor : projMinus P W' =
        ((blockMP P (g.1 : H →L[𝕜] H)).comp (projPlus P W.1) +
         (blockMM P (g.1 : H →L[𝕜] H)).comp (projMinus P W.1)).comp (e.symm : W' →L[𝕜] W.1) := by
      rw [← projMinus_restrictEquiv P g.1 W.1]
      ext y
      change (projMinus P W' y : H) = (projMinus P W' (e (e.symm y)) : H)
      rw [e.apply_symm_apply]
    rw [hfactor]
    have h1 := g.2.2.comp_clm (projPlus P W.1)
    have h2 := W.2.2.2.clm_comp (blockMM P (g.1 : H →L[𝕜] H))
    exact (h1.add h2).comp_clm (e.symm : W' →L[𝕜] W.1)
  have hMainFred : IsFredholm ((blockPP P (g.1 : H →L[𝕜] H)).comp (projPlus P W.1)) :=
    (blockPP_isFredholm P g).comp W.2.2.1
  have hPertComp : IsCompactOperator
      (((blockPM P (g.1 : H →L[𝕜] H)).comp (projMinus P W.1) : W.1 →L[𝕜] P.HPlus) : W.1 → P.HPlus) :=
    g.2.1.comp_clm (projMinus P W.1)
  have hSum := CompactFredholmTheory.add_compact (𝕜 := 𝕜) hMainFred hPertComp
  have hCompFred : IsFredholm ((projPlus P W').comp (e : W.1 →L[𝕜] W')) := by
    rw [projPlus_restrictEquiv]
    exact hSum.1
  have hFredPlus : IsFredholm (projPlus P W') := by
    have hfactor : projPlus P W' =
        ((projPlus P W').comp (e : W.1 →L[𝕜] W')).comp (e.symm : W' →L[𝕜] W.1) := by
      ext y; simp
    rw [hfactor]
    exact hCompFred.comp (isFredholm_of_equiv e.symm)
  have hIdx : fredholmIndex (projPlus P W') = glResIndex P g + virtualDim W := by
    have h1 : fredholmIndex ((projPlus P W').comp (e : W.1 →L[𝕜] W')) =
        fredholmIndex (projPlus P W') := by
      rw [fredholmIndex_comp hFredPlus (isFredholm_of_equiv e),
          fredholmIndex_of_equiv e, add_zero]
    rw [← h1, projPlus_restrictEquiv, hSum.2]
    exact fredholmIndex_comp (blockPP_isFredholm P g) W.2.2.1
  exact ⟨⟨hClosed, hFredPlus, hCompMinus⟩, hIdx⟩

/-- The group action `MulAction (GLRes P) (SatoGr P)`. -/
noncomputable instance instMulActionGLRes [CompactFredholmTheory.{u} 𝕜]
    (P : PolarizedHilbertSpace 𝕜 H) :
    MulAction (GLRes P) (SatoGr P) where
  smul g W := ⟨W.1.map (g.1 : H →L[𝕜] H).toLinearMap, (glRes_smul_mem_and_vdim P g W).1⟩
  one_smul W := by
    apply Subtype.ext
    ext x
    change x ∈ W.1.map LinearMap.id ↔ x ∈ W.1
    simp
  mul_smul g h W := by
    apply Subtype.ext
    ext x
    change x ∈ W.1.map ((g.1 : H →L[𝕜] H).toLinearMap.comp (h.1 : H →L[𝕜] H).toLinearMap) ↔
      x ∈ (W.1.map (h.1 : H →L[𝕜] H).toLinearMap).map (g.1 : H →L[𝕜] H).toLinearMap
    rw [Submodule.map_comp]

/-- **Corollary (Virtual Dimension Equivariance):**
`vdim(g • W) = ind(g₊₊) + vdim(W)`. -/
theorem virtualDim_smul [CompactFredholmTheory.{u} 𝕜]
    (P : PolarizedHilbertSpace 𝕜 H) (g : GLRes P) (W : SatoGr P) :
    virtualDim (g • W) = glResIndex P g + virtualDim W :=
  (glRes_smul_mem_and_vdim P g W).2

end GroupActionCont

end Signals.SatoGrassmannian
