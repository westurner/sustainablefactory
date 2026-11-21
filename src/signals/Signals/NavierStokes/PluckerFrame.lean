import Mathlib.Analysis.InnerProductSpace.PiL2
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Deriv
import Mathlib.Data.Matrix.Basic
import Signals.SatoGrassmannian.DualSchubertQFIM

open scoped InnerProductSpace Matrix

namespace Signals.NavierStokes.PluckerFrame

open Signals.SatoGrassmannian.DualSchubertQFIM

/-!
# Plücker 1-Jet Stiefel Frame, Clebsch Spinor Vorticity, & Bateman Viscous Audit

Formalizes the geometric foundation of Navier–Stokes within the Three-Channel
Plücker–Madelung and Six-Channel Dual-Schubert QFIM (`F_μν = 4 g_FS_μν`) framework,
auditing and repairing two algebraic defects identified in
`data/chats/bohmian-mechanics-and-navier-stokes-and-nonlinearity.md`:

1. **4×2 1-Jet Stiefel Frame & Klein Quadric Singularity Cancellation** (Chat Defect #1,
   lines 57–71): builds a genuine `4 × 2` complex matrix whose 6 Plücker minors satisfy
   `p₀₁ p₂₃ - p₀₂ p₁₃ + p₀₃ p₁₂ = 0`, cancels the `1 / p₀₁²` Madelung denominator into
   `p₂₃ / p₀₁`, and establishes the smooth Schubert chart transition `Ω₀ ↔ Ω₀₂` across
   the nodal divisor `Σ₁ = {p₀₁ = 0}`.
2. **2-Component Clebsch Spinor Lift & Nonzero Continuous Vorticity**: embeds a unit
   2-spinor `ψ̂ = (cos(θ/2) e^{iφ₁}, sin(θ/2) e^{iφ₂})` into `Plucker6`, proves exact
   `F_μν = 4 g_FS_μν`, and proves that its Berry curvature yields nonzero continuous
   vorticity `ω_z = (ℏ / 2m) sin θ (∂_x θ ∂_y(φ₂ - φ₁) - ∂_y θ ∂_x(φ₂ - φ₁))`.
3. **Hermitian vs. Bateman Doubled Viscous Operator** (Chat Defect #2, lines 99–101):
   proves that the chat's off-diagonal `± i ℏ ν ∇²` block is **Hermitian** (zero net
   dissipation), whereas the corrected Bateman / Keldysh doubled diagonal operator
   `diag(-i ℏ ν k², +i ℏ ν k²)` dissipates primal energy at rate `-2 ν k² ‖ψ‖²` while
   conserving the primal–dual pairing `conj(ψ̃) · ψ` identically.
-/

/-! ### Section 1: 4×2 1-Jet Stiefel Frame, Klein Quadric, & Schubert Chart Transitions -/

/-- Complex `4 × 2` Stiefel frame matrix representing a 2-plane in `ℂ⁴` (`Gr_ℂ(2, 4)`). -/
abbrev Stiefel4x2 := Matrix (Fin 4) (Fin 2) ℂ

/-- Plücker `2 × 2` minor `p_{ij}(Z) = z_{i,0} z_{j,1} - z_{i,1} z_{j,0}`. -/
def pluckerMinor (Z : Stiefel4x2) (i j : Fin 4) : ℂ :=
  Z i 0 * Z j 1 - Z i 1 * Z j 0

/-- Explicit `4 × 2` 1-jet Stiefel frame repairing Chat Defect #1 (lines 57–71):
upper `2 × 2` block stores primal/dual spinor components `(ψ₁, ψ̃₁; ψ₂, ψ̃₂)` and lower
`2 × 2` block stores their covariant spatial derivatives `(D₁ ψ₁, D₁ ψ̃₁; D₂ ψ₂, D₂ ψ̃₂)`. -/
def jetFrame (ψ₁ ψ₂ ψ₁t ψ₂t dψ₁ dψ₂ dψ₁t dψ₂t : ℂ) : Stiefel4x2 :=
  !![ψ₁, ψ₁t;
     ψ₂, ψ₂t;
     dψ₁, dψ₁t;
     dψ₂, dψ₂t]

/-- **Theorem 1.1 (Klein Quadric Identity for Any `4 × 2` Frame):**
The six Plücker minors satisfy `p₀₁ p₂₃ - p₀₂ p₁₃ + p₀₃ p₁₂ = 0` identically. -/
theorem stiefel4x2_klein_quadric (Z : Stiefel4x2) :
    pluckerMinor Z 0 1 * pluckerMinor Z 2 3 -
    pluckerMinor Z 0 2 * pluckerMinor Z 1 3 +
    pluckerMinor Z 0 3 * pluckerMinor Z 1 2 = 0 := by
  unfold pluckerMinor
  ring

/-- **Theorem 1.2 (Madelung `1 / p₀₁²` Denominator Cancellation via Klein Quadric):**
On the big Schubert cell `Ω₀ = {p₀₁ ≠ 0}`, the quadratic combination
`(p₀₂ p₁₃ - p₀₃ p₁₂) / p₀₁²` collapses identically to the linear stress ratio `p₂₃ / p₀₁`. -/
theorem jetFrame_klein_quadric_cancellation (Z : Stiefel4x2)
    (h01 : pluckerMinor Z 0 1 ≠ 0) :
    (pluckerMinor Z 0 2 * pluckerMinor Z 1 3 - pluckerMinor Z 0 3 * pluckerMinor Z 1 2) /
      pluckerMinor Z 0 1 ^ 2 =
    pluckerMinor Z 2 3 / pluckerMinor Z 0 1 := by
  have hq : pluckerMinor Z 0 2 * pluckerMinor Z 1 3 - pluckerMinor Z 0 3 * pluckerMinor Z 1 2 =
      pluckerMinor Z 0 1 * pluckerMinor Z 2 3 := by
    linear_combination -stiefel4x2_klein_quadric Z
  rw [hq]
  field_simp [h01]

/-- **Theorem 1.3 (Schubert Divisor & Smooth Chart Transition `Ω₀ ↔ Ω₀₂`):**
1. At a primal density node (`p₀₁ = 0`, crossing the codimension-1 Schubert divisor `Σ₁`),
   the Klein quadric enforces `p₀₂ p₁₃ = p₀₃ p₁₂`.
2. Whenever `p₀₂ ≠ 0`, the adjacent Schubert chart `Ω₀₂` coordinates `(p₀₁/p₀₂, p₀₃/p₀₂,
   p₁₂/p₀₂, p₁₃/p₀₂, p₂₃/p₀₂)` remain finite across `p₀₁ = 0` and satisfy
   `u₁₃ = u₀₃ u₁₂ + u₀₁ u₂₃`.
3. On the overlap `Ω₀ ∩ Ω₀₂`, the `Ω₀` ratio `p₂₃ / p₀₁` and the `Ω₀₂` ratios satisfy
   the exact smooth rational transition law `(p₂₃ / p₀₂) / (p₀₁ / p₀₂) = p₂₃ / p₀₁`. -/
theorem schubert_chart_transition_omega0_to_omega02 (Z : Stiefel4x2)
    (h02 : pluckerMinor Z 0 2 ≠ 0) :
    (pluckerMinor Z 0 1 = 0 →
      pluckerMinor Z 0 2 * pluckerMinor Z 1 3 = pluckerMinor Z 0 3 * pluckerMinor Z 1 2) ∧
    (pluckerMinor Z 1 3 / pluckerMinor Z 0 2 =
      (pluckerMinor Z 0 3 / pluckerMinor Z 0 2) * (pluckerMinor Z 1 2 / pluckerMinor Z 0 2) *
        pluckerMinor Z 0 2 / pluckerMinor Z 0 2 +
      (pluckerMinor Z 0 1 / pluckerMinor Z 0 2) * (pluckerMinor Z 2 3 / pluckerMinor Z 0 2)) ∧
    (pluckerMinor Z 0 1 ≠ 0 →
      (pluckerMinor Z 2 3 / pluckerMinor Z 0 2) / (pluckerMinor Z 0 1 / pluckerMinor Z 0 2) =
        pluckerMinor Z 2 3 / pluckerMinor Z 0 1) := by
  have hq := stiefel4x2_klein_quadric Z
  refine ⟨?_, ?_, ?_⟩
  · intro h01
    rw [h01, zero_mul, zero_sub] at hq
    linear_combination -hq
  · field_simp [h02]
    linear_combination -hq
  · intro h01
    field_simp [h01, h02]

/-! ### Section 2: 2-Component Clebsch Spinor Lift, QFIM, & Nonzero Continuous Vorticity -/

/-- Embed a normalized 2-component Clebsch spinor
`ψ̂(θ, φ₁, φ₂) = (cos(θ/2) e^{i φ₁}, sin(θ/2) e^{i φ₂})` into `Plucker6`. -/
noncomputable def clebschSpinor (θ φ₁ φ₂ : ℝ) : Plucker6 :=
  WithLp.toLp 2 (fun i : Fin 6 =>
    if i = 0 then ((Real.cos (θ / 2) : ℝ) : ℂ) * Complex.exp ((φ₁ : ℂ) * Complex.I)
    else if i = 1 then ((Real.sin (θ / 2) : ℝ) : ℂ) * Complex.exp ((φ₂ : ℂ) * Complex.I)
    else 0)

/-- Directional derivative `∂_μ ψ̂` of the 2-component Clebsch spinor along `(dθ, dφ₁, dφ₂)`. -/
noncomputable def clebschSpinorDeriv (θ φ₁ φ₂ dθ dφ₁ dφ₂ : ℝ) : Plucker6 :=
  WithLp.toLp 2 (fun i : Fin 6 =>
    if i = 0 then
      ((-(dθ / 2) * Real.sin (θ / 2) : ℝ) + (Real.cos (θ / 2) * dφ₁ : ℝ) * Complex.I) *
        Complex.exp ((φ₁ : ℂ) * Complex.I)
    else if i = 1 then
      (((dθ / 2) * Real.cos (θ / 2) : ℝ) + (Real.sin (θ / 2) * dφ₂ : ℝ) * Complex.I) *
        Complex.exp ((φ₂ : ℂ) * Complex.I)
    else 0)

/-- Clebsch Berry connection `A_μ = Im ⟪ψ̂, ∂_μ ψ̂⟫ = cos²(θ/2) dφ₁ + sin²(θ/2) dφ₂`. -/
noncomputable def clebschBerryConnection (θ dφ₁ dφ₂ : ℝ) : ℝ :=
  Real.cos (θ / 2) ^ 2 * dφ₁ + Real.sin (θ / 2) ^ 2 * dφ₂

/-- Clebsch continuous vorticity component `ω_z = ∂_x v_y - ∂_y v_x` derived from the
Berry curvature `Ω_{xy} = ∂_x A_y - ∂_y A_x = (1/2) sin θ (∂_x θ ∂_y(φ₂ - φ₁) - ∂_y θ ∂_x(φ₂ - φ₁))`. -/
noncomputable def clebschBerryVorticityZ (ℏ m θ dθ_x dθ_y dφ_diff_x dφ_diff_y : ℝ) : ℝ :=
  (ℏ / (2 * m)) * Real.sin θ * (dθ_x * dφ_diff_y - dθ_y * dφ_diff_x)

/-- **Theorem 2.1 (Clebsch Spinor Unit Norm, Berry Connection, & Exact `QFIM = 4 g_FS`):**
For any smooth 2-component Clebsch spinor `ψ̂(θ, φ₁, φ₂)` embedded in `Plucker6`:
1. `‖ψ̂‖ = 1` everywhere (no nodal denominator blowup);
2. `⟪ψ̂, ∂_μ ψ̂⟫ = i (cos²(θ/2) dφ₁ + sin²(θ/2) dφ₂)` (purely imaginary tangency);
3. `g_FS(ψ̂, ∂_μ ψ̂) = (1/4) (dθ² + sin² θ (dφ₁ - dφ₂)²)`;
4. `QFIM(ψ̂, ∂_μ ψ̂) = 4 g_FS(ψ̂, ∂_μ ψ̂) = dθ² + sin² θ (dφ₁ - dφ₂)²`. -/
theorem clebsch_spinor_berry_and_qfim (θ φ₁ φ₂ dθ dφ₁ dφ₂ : ℝ) :
    let p := clebschSpinor θ φ₁ φ₂
    let dp := clebschSpinorDeriv θ φ₁ φ₂ dθ dφ₁ dφ₂
    ‖p‖ = 1 ∧
    (⟪p, dp⟫_ℂ).re = 0 ∧
    (⟪p, dp⟫_ℂ).im = clebschBerryConnection θ dφ₁ dφ₂ ∧
    fubiniStudy p dp = (dθ ^ 2 + Real.sin θ ^ 2 * (dφ₁ - dφ₂) ^ 2) / 4 ∧
    qfim p dp = dθ ^ 2 + Real.sin θ ^ 2 * (dφ₁ - dφ₂) ^ 2 := by
  intro p dp
  have hcs : Real.cos (θ / 2) ^ 2 + Real.sin (θ / 2) ^ 2 = 1 := Real.cos_sq_add_sin_sq (θ / 2)
  have hsin2 : Real.sin θ = 2 * Real.sin (θ / 2) * Real.cos (θ / 2) := by
    have h := Real.sin_two_mul (θ / 2)
    have h2 : 2 * (θ / 2) = θ := by ring
    rwa [h2] at h
  have hexp_norm : ∀ φ : ℝ, ‖Complex.exp ((φ : ℂ) * Complex.I)‖ = 1 := fun φ => by
    simp [mul_comm]
  have hexp_conj_mul : ∀ φ : ℝ,
      starRingEnd ℂ (Complex.exp ((φ : ℂ) * Complex.I)) * Complex.exp ((φ : ℂ) * Complex.I) = 1 :=
    fun φ => by
      rw [← Complex.exp_conj]
      simp only [map_mul, Complex.conj_ofReal, Complex.conj_I]
      rw [← Complex.exp_add]
      have h0 : (φ : ℂ) * -Complex.I + (φ : ℂ) * Complex.I = 0 := by ring
      rw [h0, Complex.exp_zero]
  have hp_sq : ‖p‖ ^ 2 = 1 := by
    rw [EuclideanSpace.norm_sq_eq]
    simp only [Fin.sum_univ_six, p, clebschSpinor, Fin.isValue, ↓reduceIte, Fin.reduceEq,
      norm_mul, hexp_norm, mul_one, Complex.norm_real, Real.norm_eq_abs, sq_abs,
      norm_zero, zero_pow two_ne_zero, add_zero]
    exact hcs
  have hp_norm : ‖p‖ = 1 := by nlinarith [norm_nonneg p]
  have hinner : ⟪p, dp⟫_ℂ = ((clebschBerryConnection θ dφ₁ dφ₂ : ℝ) : ℂ) * Complex.I := by
    rw [PiLp.inner_apply]
    simp only [Fin.sum_univ_six, p, dp, clebschSpinor, clebschSpinorDeriv, Fin.isValue, ↓reduceIte,
      Fin.reduceEq, RCLike.inner_apply, zero_mul, add_zero]
    have hterm : ∀ (a b c φ : ℝ),
        (((b : ℂ) + (c : ℂ) * Complex.I) * Complex.exp ((φ : ℂ) * Complex.I)) *
          starRingEnd ℂ ((a : ℂ) * Complex.exp ((φ : ℂ) * Complex.I)) =
        ((a * b : ℝ) : ℂ) + ((a * c : ℝ) : ℂ) * Complex.I := by
      intro a b c φ
      rw [map_mul, Complex.conj_ofReal]
      have hrearr :
          (((b : ℂ) + (c : ℂ) * Complex.I) * Complex.exp ((φ : ℂ) * Complex.I)) *
            ((a : ℂ) * starRingEnd ℂ (Complex.exp ((φ : ℂ) * Complex.I))) =
          ((a : ℂ) * ((b : ℂ) + (c : ℂ) * Complex.I)) *
            (starRingEnd ℂ (Complex.exp ((φ : ℂ) * Complex.I)) *
              Complex.exp ((φ : ℂ) * Complex.I)) := by ring
      rw [hrearr, hexp_conj_mul φ, mul_one]
      push_cast
      ring
    rw [hterm (Real.cos (θ / 2)) (-(dθ / 2) * Real.sin (θ / 2)) (Real.cos (θ / 2) * dφ₁) φ₁,
        hterm (Real.sin (θ / 2)) ((dθ / 2) * Real.cos (θ / 2)) (Real.sin (θ / 2) * dφ₂) φ₂]
    unfold clebschBerryConnection
    push_cast
    ring
  have hre : (⟪p, dp⟫_ℂ).re = 0 := by rw [hinner]; simp
  have him : (⟪p, dp⟫_ℂ).im = clebschBerryConnection θ dφ₁ dφ₂ := by rw [hinner]; simp
  have hdp_sq : ‖dp‖ ^ 2 =
      dθ ^ 2 / 4 + Real.cos (θ / 2) ^ 2 * dφ₁ ^ 2 + Real.sin (θ / 2) ^ 2 * dφ₂ ^ 2 := by
    rw [EuclideanSpace.norm_sq_eq]
    simp only [Fin.sum_univ_six, dp, clebschSpinorDeriv, Fin.isValue, ↓reduceIte, Fin.reduceEq,
      norm_mul, hexp_norm, mul_one, norm_zero, zero_pow two_ne_zero, add_zero]
    have hnorm_ab : ∀ (a b : ℝ), ‖(a : ℂ) + (b : ℂ) * Complex.I‖ ^ 2 = a ^ 2 + b ^ 2 := by
      intro a b
      rw [Complex.sq_norm, Complex.normSq_apply]
      simp [sq]
    rw [hnorm_ab, hnorm_ab]
    nlinarith [hcs]
  have hinner_sq : ‖⟪p, dp⟫_ℂ‖ ^ 2 = clebschBerryConnection θ dφ₁ dφ₂ ^ 2 := by
    rw [hinner, norm_mul, Complex.norm_I, mul_one, Complex.norm_real, Real.norm_eq_abs, sq_abs]
  have hgfs : fubiniStudy p dp = (dθ ^ 2 + Real.sin θ ^ 2 * (dφ₁ - dφ₂) ^ 2) / 4 := by
    unfold fubiniStudy
    rw [hdp_sq, hinner_sq, hsin2]
    unfold clebschBerryConnection
    nlinarith [hcs, sq_nonneg (Real.cos (θ / 2) ^ 2), sq_nonneg (Real.sin (θ / 2) ^ 2)]
  refine ⟨hp_norm, hre, him, hgfs, ?_⟩
  rw [qfim, hgfs]
  ring

/-- **Theorem 2.2 (Calculus Derivation of Clebsch Berry Curvature `ω_z = (ℏ/m)(∂_x A_y - ∂_y A_x)`):**
Differentiating `A_μ = cos²(θ/2) ∂_μ φ₁ + sin²(θ/2) ∂_μ φ₂` with smooth mixed-partial symmetry
(`φ₁_xy = φ₁_yx`, `φ₂_xy = φ₂_yx`) cancels all second-order phase derivatives identically and
yields the exact continuous vorticity `clebschBerryVorticityZ`:
`(ℏ / m) (∂_x A_y - ∂_y A_x) = (ℏ / (2 m)) sin θ (∂_x θ ∂_y(φ₂ - φ₁) - ∂_y θ ∂_x(φ₂ - φ₁))`. -/
theorem clebsch_berry_curl_eq_vorticityZ
    (ℏ m θ θ_x θ_y φ₁_x φ₁_y φ₂_x φ₂_y φ₁_xy φ₂_xy : ℝ) :
    let dA_y_dx : ℝ :=
      (-Real.cos (θ / 2) * Real.sin (θ / 2) * θ_x) * φ₁_y + Real.cos (θ / 2) ^ 2 * φ₁_xy +
      (Real.sin (θ / 2) * Real.cos (θ / 2) * θ_x) * φ₂_y + Real.sin (θ / 2) ^ 2 * φ₂_xy
    let dA_x_dy : ℝ :=
      (-Real.cos (θ / 2) * Real.sin (θ / 2) * θ_y) * φ₁_x + Real.cos (θ / 2) ^ 2 * φ₁_xy +
      (Real.sin (θ / 2) * Real.cos (θ / 2) * θ_y) * φ₂_x + Real.sin (θ / 2) ^ 2 * φ₂_xy
    (ℏ / m) * (dA_y_dx - dA_x_dy) =
      clebschBerryVorticityZ ℏ m θ θ_x θ_y (φ₂_x - φ₁_x) (φ₂_y - φ₁_y) := by
  intro dA_y_dx dA_x_dy
  have hsin2 : Real.sin θ = 2 * Real.sin (θ / 2) * Real.cos (θ / 2) := by
    have h := Real.sin_two_mul (θ / 2)
    have h2 : 2 * (θ / 2) = θ := by ring
    rwa [h2] at h
  dsimp only [dA_y_dx, dA_x_dy]
  unfold clebschBerryVorticityZ
  rw [hsin2]
  ring

/-- **Theorem 2.3 (Nonzero Continuous Clebsch Vorticity Witness):**
Unlike scalar Madelung flow (which is irrotational wherever `ρ > 0`), a smooth Clebsch
spinor with non-collinear `(∇θ, ∇(φ₂ - φ₁))` carries strictly positive vorticity
`ω_z = ℏ / (2 m) > 0` at `θ = π/2`. -/
theorem clebsch_berry_vorticity_nonzero {ℏ m : ℝ} (hℏ : 0 < ℏ) (hm : 0 < m) :
    clebschBerryVorticityZ ℏ m (Real.pi / 2) 1 0 0 1 = ℏ / (2 * m) ∧
    0 < clebschBerryVorticityZ ℏ m (Real.pi / 2) 1 0 0 1 := by
  unfold clebschBerryVorticityZ
  rw [Real.sin_pi_div_two]
  have hval : ℏ / (2 * m) * 1 * (1 * 1 - 0 * 0) = ℏ / (2 * m) := by ring
  rw [hval]
  exact ⟨rfl, div_pos hℏ (by linarith)⟩

/-- Grassmannian Riccati tangent-space projection `P_Z(H Z) = H Z - Z (Z† H Z)` for an
orthonormal `4 × 2` Stiefel frame `Z` (`Z† Z = I₂`), matching the gauge-fixing connection
`Z Λ(Z)` in `data/chats/bohmian-mechanics-and-navier-stokes-and-nonlinearity.md` (lines 102–104). -/
def riccatiTangentProj (H : Matrix (Fin 4) (Fin 4) ℂ) (Z : Stiefel4x2) : Stiefel4x2 :=
  H * Z - Z * (Zᴴ * H * Z)

/-- **Theorem 2.4 (Grassmannian Riccati Tangent Orthogonality & Orthonormality Preservation):**
For any orthonormal `4 × 2` Stiefel frame `Z` (`Z† Z = 1`) and **any** `4 × 4` operator `H`
(Hermitian or non-Hermitian), the Riccati-projected tangent vector `Ż = c • (H Z - Z (Z† H Z))`
satisfies exact horizontal orthogonality `Z† Ż = 0` and identically preserves the Gram matrix
`d/dt (Z† Z) = Ż† Z + Z† Ż = 0`. -/
theorem riccati_grassmann_projection_orthogonal
    (H : Matrix (Fin 4) (Fin 4) ℂ) (Z : Stiefel4x2) (hortho : Zᴴ * Z = 1) (c : ℂ) :
    let dZ : Stiefel4x2 := c • riccatiTangentProj H Z
    Zᴴ * dZ = 0 ∧
    dZᴴ * Z + Zᴴ * dZ = 0 := by
  intro dZ
  have h1 : Zᴴ * riccatiTangentProj H Z = 0 := by
    unfold riccatiTangentProj
    rw [Matrix.mul_sub, ← Matrix.mul_assoc, ← Matrix.mul_assoc, hortho, Matrix.one_mul,
        Matrix.mul_assoc, sub_self]
  have hz_dz : Zᴴ * dZ = 0 := by
    dsimp only [dZ]
    rw [Matrix.mul_smul, h1, smul_zero]
  have hdz_z : dZᴴ * Z = 0 := by
    have hconj : (Zᴴ * dZ)ᴴ = dZᴴ * Z := by
      rw [Matrix.conjTranspose_mul, Matrix.conjTranspose_conjTranspose]
    rw [← hconj, hz_dz, Matrix.conjTranspose_zero]
  exact ⟨hz_dz, by rw [hdz_z, hz_dz, add_zero]⟩

/-! ### Section 3: Audit of Chat Defect #2 — Hermitian `H_chat` vs. Bateman Viscous Operator -/

/-- Fourier-mode representation (`-∇² ↦ k²`) of the chat's proposed off-diagonal viscous
operator (lines 99–101): `[[E, +i ℏ ν k²], [-i ℏ ν k², E]]`. -/
def chatOffdiagViscousMatrix (E ℏ ν k : ℝ) : Matrix (Fin 2) (Fin 2) ℂ :=
  !![(E : ℂ), ((ℏ * ν * k ^ 2 : ℝ) : ℂ) * Complex.I;
     -(((ℏ * ν * k ^ 2 : ℝ) : ℂ) * Complex.I), (E : ℂ)]

/-- Corrected Bateman / Keldysh doubled viscous operator in Fourier space:
`diag(E - i ℏ ν k², E + i ℏ ν k²)`, corresponding to `+i ℏ ν ∇²` on the primal channel
and `-i ℏ ν ∇²` on the dual channel. -/
def batemanDoubledViscousMatrix (E ℏ ν k : ℝ) : Matrix (Fin 2) (Fin 2) ℂ :=
  !![(E : ℂ) - ((ℏ * ν * k ^ 2 : ℝ) : ℂ) * Complex.I, 0;
     0, (E : ℂ) + ((ℏ * ν * k ^ 2 : ℝ) : ℂ) * Complex.I]

/-- **Theorem 3.1 (Chat Defect #2 Proof — Off-Diagonal `± i ℏ ν ∇²` Is Hermitian, Zero Dissipation):**
1. `chatOffdiagViscousMatrix E ℏ ν k` is strictly Hermitian (`H† = H`), NOT dissipative.
2. Under `i ℏ ∂_t Φ = H_chat Φ`, the total norm rate `d/dt (|ψ|² + |ψ̃|²)` vanishes
   identically for all `ν, k`. -/
theorem chat_offdiag_viscous_matrix_is_hermitian (E ℏ ν k : ℝ) :
    (chatOffdiagViscousMatrix E ℏ ν k)ᴴ = chatOffdiagViscousMatrix E ℏ ν k := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [chatOffdiagViscousMatrix, Matrix.conjTranspose_apply]

/-- Total norm rate `d/dt (‖ψ‖² + ‖ψ̃‖²) = 2 Re(conj(ψ) ψ_t + conj(ψ̃) ψ̃_t)` for a
general `2 × 2` Hamiltonian `i ℏ ∂_t Φ = H Φ` (scaled by `ℏ > 0`). -/
def twoChannelNormRateScaled (H : Matrix (Fin 2) (Fin 2) ℂ) (ψ ψt : ℂ) : ℝ :=
  let rhs0 := (-Complex.I) * (H 0 0 * ψ + H 0 1 * ψt)
  let rhs1 := (-Complex.I) * (H 1 0 * ψ + H 1 1 * ψt)
  2 * (starRingEnd ℂ ψ * rhs0 + starRingEnd ℂ ψt * rhs1).re

theorem chat_heff_conserves_norm_zero_dissipation (E ℏ ν k : ℝ) (ψ ψt : ℂ) :
    twoChannelNormRateScaled (chatOffdiagViscousMatrix E ℏ ν k) ψ ψt = 0 := by
  unfold twoChannelNormRateScaled chatOffdiagViscousMatrix
  simp only [Matrix.of_apply, Matrix.cons_val', Matrix.cons_val_zero, Matrix.cons_val_one]
  simp only [Complex.add_re, Complex.mul_re, Complex.mul_im, Complex.neg_re, Complex.neg_im,
    Complex.I_re, Complex.I_im, Complex.conj_re, Complex.conj_im, Complex.ofReal_re,
    Complex.ofReal_im, Complex.add_im]
  ring

/-- **Theorem 3.2 (Corrected Bateman Doubled Viscous Operator — Exact Dissipation & Pairing Conservation):**
Under `i ℏ ∂_t (ψ, ψ̃) = batemanDoubledViscousMatrix(E, ℏ, ν, k) (ψ, ψ̃)` (`ℏ > 0`):
1. Primal density dissipates at the exact Navier–Stokes viscous rate
   `d/dt |ψ|² = -2 ν k² |ψ|²` (`≤ 0` for `ν ≥ 0`);
2. Dual density grows symmetrically at `+2 ν k² |ψ̃|²`;
3. The indefinite Bateman / Keldysh bilinear pairing `conj(ψ̃) · ψ` has identically zero
   time derivative (`d/dt (conj(ψ̃) ψ) = 0`), conserving the doubled symplectic inner product. -/
theorem bateman_doubled_viscous_pairing_conserved_and_primal_dissipates
    {E ℏ ν k : ℝ} (hℏ : 0 < ℏ) (hν : 0 ≤ ν) (ψ ψt : ℂ) :
    let dψ : ℂ := ((-Complex.I) / (ℏ : ℂ)) *
      (batemanDoubledViscousMatrix E ℏ ν k 0 0 * ψ)
    let dψt : ℂ := ((-Complex.I) / (ℏ : ℂ)) *
      (batemanDoubledViscousMatrix E ℏ ν k 1 1 * ψt)
    2 * (starRingEnd ℂ ψ * dψ).re = -2 * ν * k ^ 2 * Complex.normSq ψ ∧
    2 * (starRingEnd ℂ ψt * dψt).re = 2 * ν * k ^ 2 * Complex.normSq ψt ∧
    2 * (starRingEnd ℂ ψ * dψ).re ≤ 0 ∧
    starRingEnd ℂ dψt * ψ + starRingEnd ℂ ψt * dψ = 0 := by
  intro dψ dψt
  have hℏne : (ℏ : ℂ) ≠ 0 := Complex.ofReal_ne_zero.mpr hℏ.ne'
  have hdψ : dψ = (-(ν * k ^ 2 : ℝ) - ((E / ℏ : ℝ) : ℂ) * Complex.I) * ψ := by
    dsimp only [dψ, batemanDoubledViscousMatrix]
    simp only [Matrix.of_apply, Matrix.cons_val', Matrix.cons_val_zero]
    have hI2 : Complex.I ^ 2 = -1 := Complex.I_sq
    push_cast
    field_simp [hℏne]
    linear_combination (ψ * (ℏ : ℂ) * (ν : ℂ) * (k : ℂ) ^ 2) * hI2
  have hdψt : dψt = ((ν * k ^ 2 : ℝ) - ((E / ℏ : ℝ) : ℂ) * Complex.I) * ψt := by
    dsimp only [dψt, batemanDoubledViscousMatrix]
    simp only [Matrix.of_apply, Matrix.cons_val', Matrix.cons_val_one]
    have hI2 : Complex.I ^ 2 = -1 := Complex.I_sq
    push_cast
    field_simp [hℏne]
    linear_combination (-(ψt * (ℏ : ℂ) * (ν : ℂ) * (k : ℂ) ^ 2)) * hI2
  have hprimal : 2 * (starRingEnd ℂ ψ * dψ).re = -2 * ν * k ^ 2 * Complex.normSq ψ := by
    rw [hdψ, Complex.normSq_apply]
    simp only [Complex.mul_re, Complex.mul_im, Complex.sub_re, Complex.sub_im,
      Complex.neg_re, Complex.neg_im, Complex.ofReal_re, Complex.ofReal_im,
      Complex.I_re, Complex.I_im, Complex.conj_re, Complex.conj_im]
    ring
  have hdual : 2 * (starRingEnd ℂ ψt * dψt).re = 2 * ν * k ^ 2 * Complex.normSq ψt := by
    rw [hdψt, Complex.normSq_apply]
    simp only [Complex.mul_re, Complex.mul_im, Complex.sub_re, Complex.sub_im,
      Complex.ofReal_re, Complex.ofReal_im, Complex.I_re, Complex.I_im,
      Complex.conj_re, Complex.conj_im]
    ring
  have hnonpos : 2 * (starRingEnd ℂ ψ * dψ).re ≤ 0 := by
    rw [hprimal]
    have h1 : 0 ≤ 2 * ν * k ^ 2 * Complex.normSq ψ :=
      mul_nonneg (mul_nonneg (mul_nonneg (by norm_num) hν) (sq_nonneg k)) (Complex.normSq_nonneg ψ)
    linarith
  have hpair : starRingEnd ℂ dψt * ψ + starRingEnd ℂ ψt * dψ = 0 := by
    rw [hdψ, hdψt, map_mul, map_sub, map_mul, Complex.conj_ofReal, Complex.conj_ofReal,
        Complex.conj_I]
    ring
  exact ⟨hprimal, hdual, hnonpos, hpair⟩

end Signals.NavierStokes.PluckerFrame
