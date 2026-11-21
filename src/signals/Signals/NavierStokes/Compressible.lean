import Mathlib.Analysis.Calculus.Deriv.Basic
import Mathlib.Analysis.Calculus.Deriv.Add
import Mathlib.Analysis.Calculus.Deriv.Mul
import Mathlib.Analysis.Calculus.Deriv.Comp
import Mathlib.Analysis.Calculus.IteratedDeriv.Lemmas
import Mathlib.Analysis.SpecialFunctions.Trigonometric.DerivHyp
import Signals.DDF
import Signals.SatoGrassmannian.DualSchubertQFIM
import Signals.NavierStokes.PluckerFrame

open scoped InnerProductSpace

namespace Signals.NavierStokes.Compressible

open Signals.SatoGrassmannian.DualSchubertQFIM

/-!
# Compressible Navier–Stokes & Navier–Stokes–Korteweg via Dual-Schubert QFIM

Formalizes compressible Navier–Stokes and Navier–Stokes–Korteweg (NSK) fluid mechanics
within the Three-Channel Plücker–Madelung and Six-Channel Dual-Schubert QFIM (`F_μν = 4 g_FS_μν`)
framework:

1. **3D Compressible Viscous Stress Tensor & Dissipation Positivity:** Proves exact
   deviatoric–volumetric splitting and `Φ_visc ≥ 0` for `μ ≥ 0, ζ ≥ 0`, plus Stokes'
   hypothesis `ζ = 0 ↔ λ = -(2/3) μ`.
2. **Exact Korteweg Capillary Stress Divergence Identity:** Proves
   `-(ρ / m) ∂_x Q = ∂_x K_{xx}` with `K_{xx} = (ℏ² / (4 m²)) (ρ_{xx} - ρ_x² / ρ)`,
   putting Bohmian quantum pressure into exact conservation-law flux form.
3. **Bresch–Desjardins (BD) Dual-Schubert QFIM Equivalence:** For density-dependent
   viscosity `μ(ρ) = ν ρ`, proves that the forward/backward BD effective velocities
   `v_± = v ± ν (ρ_x / ρ)` satisfy `(1/2) ρ (v_+² + v_-²) = ρ v² + ν² ρ_x² / ρ` and
   identifies the BD osmotic energy with Channel 2 of `three_channel_plucker_madelung_qfim`
   at the quantum kinematic viscosity `ν = ℏ / (2 m)`.
4. **Cole–Hopf Linearization & Exact Viscous Burgers Tanh Shock PDE:** Proves both the
   pointwise Cole–Hopf heat-to-Burgers identity and full `deriv` / `iteratedDeriv 2` PDE
   satisfaction for the moving viscous Burgers shock `v(x,t) = c - a tanh((a/(2ν))(x - ct))`.
5. **Linearized Compressible Stokes Acoustic Dispersion:** Proves exact complex dispersion
   `ω² + i δ k² ω - c_s² k² = 0` with sound diffusivity `δ = (4/3) ν + ζ / ρ₀` and causal
   damping rate `Im(ω) = -(1/2) δ k² ≤ 0`.
-/

/-! ### Section 1: 3D Compressible Viscous Stress Tensor & Dissipation Positivity -/

/-- Lamé second viscosity `λ = ζ - (2/3) μ` in terms of bulk viscosity `ζ` and shear viscosity `μ`. -/
noncomputable def lameSecondViscosity (μ ζ : ℝ) : ℝ := ζ - (2 / 3) * μ

/-- 3D compressible viscous dissipation rate `Φ_visc = τ_{ij} S_{ij}` for symmetric strain-rate
components `(s11, s22, s33, s12, s13, s23)`, shear viscosity `μ`, and bulk viscosity `ζ`. -/
noncomputable def compressibleViscousDissipation
    (μ ζ s11 s22 s33 s12 s13 s23 : ℝ) : ℝ :=
  let divV := s11 + s22 + s33
  let lam := lameSecondViscosity μ ζ
  (2 * μ * s11 + lam * divV) * s11 +
  (2 * μ * s22 + lam * divV) * s22 +
  (2 * μ * s33 + lam * divV) * s33 +
  2 * ((2 * μ * s12) * s12 + (2 * μ * s13) * s13 + (2 * μ * s23) * s23)

/-- **Theorem 1.1 (3D Compressible Viscous Dissipation Positivity & Stokes Hypothesis):**
1. `Φ_visc` splits into deviatoric shear squares plus bulk dilatation square:
   `Φ_visc = (2μ/3)((s11-s22)² + (s22-s33)² + (s33-s11)²) + 4μ(s12² + s13² + s23²) + ζ(s11+s22+s33)²`.
2. For all `μ ≥ 0, ζ ≥ 0`, viscous dissipation is everywhere nonnegative (`0 ≤ Φ_visc`).
3. Stokes' hypothesis: `ζ = 0 ↔ lameSecondViscosity μ ζ = -(2/3) μ`. -/
theorem compressible_viscous_dissipation_nonneg
    {μ ζ : ℝ} (hμ : 0 ≤ μ) (hζ : 0 ≤ ζ) (s11 s22 s33 s12 s13 s23 : ℝ) :
    compressibleViscousDissipation μ ζ s11 s22 s33 s12 s13 s23 =
      (2 * μ / 3) * ((s11 - s22) ^ 2 + (s22 - s33) ^ 2 + (s33 - s11) ^ 2) +
      4 * μ * (s12 ^ 2 + s13 ^ 2 + s23 ^ 2) +
      ζ * (s11 + s22 + s33) ^ 2 ∧
    0 ≤ compressibleViscousDissipation μ ζ s11 s22 s33 s12 s13 s23 ∧
    (ζ = 0 ↔ lameSecondViscosity μ ζ = -(2 / 3) * μ) := by
  have hsplit : compressibleViscousDissipation μ ζ s11 s22 s33 s12 s13 s23 =
      (2 * μ / 3) * ((s11 - s22) ^ 2 + (s22 - s33) ^ 2 + (s33 - s11) ^ 2) +
      4 * μ * (s12 ^ 2 + s13 ^ 2 + s23 ^ 2) +
      ζ * (s11 + s22 + s33) ^ 2 := by
    unfold compressibleViscousDissipation lameSecondViscosity
    ring
  refine ⟨hsplit, ?_, ?_⟩
  · rw [hsplit]
    positivity
  · unfold lameSecondViscosity
    constructor <;> intro h <;> linarith

/-! ### Section 2: Exact Korteweg Capillary Stress Tensor Divergence Identity -/

/-- Bohmian quantum potential `Q = -(ℏ² / (4 m)) (ρ_xx / ρ - ρ_x² / (2 ρ²))` expressed directly
in terms of density `ρ` and its derivatives `(ρ_x, ρ_xx)`. -/
noncomputable def bohmQuantumPotential1D (ℏ m ρ ρ_x ρ_xx : ℝ) : ℝ :=
  -(ℏ ^ 2 / (4 * m)) * (ρ_xx / ρ - ρ_x ^ 2 / (2 * ρ ^ 2))

/-- Spatial gradient `∂_x Q` of the 1D Bohmian quantum potential. -/
noncomputable def bohmQuantumPotentialGrad1D (ℏ m ρ ρ_x ρ_xx ρ_xxx : ℝ) : ℝ :=
  -(ℏ ^ 2 / (4 * m)) * (ρ_xxx / ρ - 2 * ρ_x * ρ_xx / ρ ^ 2 + ρ_x ^ 3 / ρ ^ 3)

/-- 1D Korteweg capillary stress tensor component `K_{xx} = (ℏ² / (4 m²)) (ρ_xx - ρ_x² / ρ)`. -/
noncomputable def kortewegStress1D (ℏ m ρ ρ_x ρ_xx : ℝ) : ℝ :=
  (ℏ ^ 2 / (4 * m ^ 2)) * (ρ_xx - ρ_x ^ 2 / ρ)

/-- Spatial divergence `∂_x K_{xx}` of the 1D Korteweg capillary stress tensor. -/
noncomputable def kortewegStressDiv1D (ℏ m ρ ρ_x ρ_xx ρ_xxx : ℝ) : ℝ :=
  (ℏ ^ 2 / (4 * m ^ 2)) * (ρ_xxx - 2 * ρ_x * ρ_xx / ρ + ρ_x ^ 3 / ρ ^ 2)

/-- **Theorem 2.1 (Exact Korteweg Capillary Stress Divergence = Bohmian Quantum Force):**
For any `m ≠ 0` and `ρ ≠ 0`, the non-conservative Bohmian quantum force `-(ρ / m) ∂_x Q`
equals the exact conservative divergence `∂_x K_{xx}` of the Korteweg capillary stress tensor. -/
theorem korteweg_stress_div_eq_quantum_force
    {m ρ : ℝ} (hm : m ≠ 0) (hρ : ρ ≠ 0) (ℏ ρ_x ρ_xx ρ_xxx : ℝ) :
    -(ρ / m) * bohmQuantumPotentialGrad1D ℏ m ρ ρ_x ρ_xx ρ_xxx =
      kortewegStressDiv1D ℏ m ρ ρ_x ρ_xx ρ_xxx := by
  unfold bohmQuantumPotentialGrad1D kortewegStressDiv1D
  field_simp [hm, hρ]

/-- **Theorem 2.2 (Full Calculus Proof of Korteweg Stress Divergence via `deriv`):**
For any smooth positive density field `ρ : ℝ → ℝ` with `HasDerivAt ρ (ρ' x) x`,
`HasDerivAt ρ' (ρ'' x) x`, and `HasDerivAt ρ'' (ρ''' x) x` (`ρ x ≠ 0, m ≠ 0`):
1. `deriv (Q ∘ ρ) x = bohmQuantumPotentialGrad1D ℏ m (ρ x) (ρ' x) (ρ'' x) (ρ''' x)`;
2. `deriv (K_{xx} ∘ ρ) x = kortewegStressDiv1D ℏ m (ρ x) (ρ' x) (ρ'' x) (ρ''' x)`;
3. `-(ρ x / m) * deriv (Q ∘ ρ) x = deriv (K_{xx} ∘ ρ) x` identically. -/
theorem korteweg_stress_div_eq_quantum_force_calculus
    {ℏ m x : ℝ} (hm : m ≠ 0)
    {ρ ρ' ρ'' ρ''' : ℝ → ℝ} (hρ_ne : ρ x ≠ 0)
    (h1 : HasDerivAt ρ (ρ' x) x)
    (h2 : HasDerivAt ρ' (ρ'' x) x)
    (h3 : HasDerivAt ρ'' (ρ''' x) x) :
    deriv (fun s => bohmQuantumPotential1D ℏ m (ρ s) (ρ' s) (ρ'' s)) x =
      bohmQuantumPotentialGrad1D ℏ m (ρ x) (ρ' x) (ρ'' x) (ρ''' x) ∧
    deriv (fun s => kortewegStress1D ℏ m (ρ s) (ρ' s) (ρ'' s)) x =
      kortewegStressDiv1D ℏ m (ρ x) (ρ' x) (ρ'' x) (ρ''' x) ∧
    -(ρ x / m) * deriv (fun s => bohmQuantumPotential1D ℏ m (ρ s) (ρ' s) (ρ'' s)) x =
      deriv (fun s => kortewegStress1D ℏ m (ρ s) (ρ' s) (ρ'' s)) x := by
  have h2ρ2_ne : 2 * ρ x ^ 2 ≠ 0 := mul_ne_zero two_ne_zero (pow_ne_zero 2 hρ_ne)
  have hd_q : HasDerivAt (fun s => bohmQuantumPotential1D ℏ m (ρ s) (ρ' s) (ρ'' s))
      (bohmQuantumPotentialGrad1D ℏ m (ρ x) (ρ' x) (ρ'' x) (ρ''' x)) x := by
    unfold bohmQuantumPotential1D bohmQuantumPotentialGrad1D
    have hterm1 : HasDerivAt (fun s => ρ'' s / ρ s)
        ((ρ''' x * ρ x - ρ'' x * ρ' x) / ρ x ^ 2) x := h3.div h1 hρ_ne
    have hnum2 : HasDerivAt (fun s => ρ' s ^ 2) ((2 : ℕ) * ρ' x ^ (2 - 1) * ρ'' x) x := h2.pow 2
    have hden2 : HasDerivAt (fun s => 2 * ρ s ^ 2) (2 * ((2 : ℕ) * ρ x ^ (2 - 1) * ρ' x)) x :=
      (h1.pow 2).const_mul 2
    have hterm2 := hnum2.div hden2 h2ρ2_ne
    convert (hterm1.sub hterm2).const_mul (-(ℏ ^ 2 / (4 * m))) using 1
    field_simp [hm, hρ_ne]
    ring
  have hd_k : HasDerivAt (fun s => kortewegStress1D ℏ m (ρ s) (ρ' s) (ρ'' s))
      (kortewegStressDiv1D ℏ m (ρ x) (ρ' x) (ρ'' x) (ρ''' x)) x := by
    unfold kortewegStress1D kortewegStressDiv1D
    have hnum : HasDerivAt (fun s => ρ' s ^ 2) ((2 : ℕ) * ρ' x ^ (2 - 1) * ρ'' x) x := h2.pow 2
    have hterm := hnum.div h1 hρ_ne
    convert (h3.sub hterm).const_mul (ℏ ^ 2 / (4 * m ^ 2)) using 1
    field_simp [hm, hρ_ne]
    ring
  refine ⟨hd_q.deriv, hd_k.deriv, ?_⟩
  rw [hd_q.deriv, hd_k.deriv]
  exact korteweg_stress_div_eq_quantum_force hm hρ_ne ℏ (ρ' x) (ρ'' x) (ρ''' x)

/-! ### Section 3: Bresch–Desjardins (BD) Dual-Schubert Velocity & QFIM Equivalence -/

/-- Forward Bresch–Desjardins effective velocity `v_+ = v + ν (ρ_x / ρ)`. -/
noncomputable def bdVelocityPlus (v ν ρ ρ_x : ℝ) : ℝ := v + ν * (ρ_x / ρ)

/-- Backward (dual) Bresch–Desjardins effective velocity `v_- = v - ν (ρ_x / ρ)`. -/
noncomputable def bdVelocityMinus (v ν ρ ρ_x : ℝ) : ℝ := v - ν * (ρ_x / ρ)

/-- **Theorem 3.1 (Bresch–Desjardins Dual-Schubert Kinetic+Fisher Split & Three-Channel QFIM Bridge):**
1. For any `ρ > 0` and density-dependent viscosity `μ(ρ) = ν ρ`, the mean kinetic energy of
   the Dual-Schubert BD pair `(v_+, v_-)` splits orthogonally into macroscopic kinetic energy
   plus BD Fisher / osmotic energy:
   `(1/2) ρ (v_+² + v_-²) = ρ v² + ν² (ρ_x² / ρ)`.
2. At the quantum kinematic viscosity `ν = ℏ / (2 m)` with `v = (ℏ / m) Im ⟪p, dp⟫`,
   the BD Dual-Schubert kinetic energy plus projective QFIM energy `(ℏ² / (8 m)) ρ QFIM(p, dp)`
   recovers the exact Plücker–Madelung kinetic energy `(ℏ² / (2 m)) ‖dΨ‖²`. -/
theorem breschDesjardins_dual_schubert_qfim_split
    {ℏ m ρ dρ : ℝ} (hℏ : 0 < ℏ) (hm : 0 < m) (hρ : 0 < ρ)
    (ν v : ℝ) {p dp : Plucker6} (hp : ‖p‖ = 1) (htang : (⟪p, dp⟫_ℂ).re = 0) :
    let dΨ : Plucker6 := (((dρ / (2 * Real.sqrt ρ) : ℝ) : ℂ) • p) + ((Real.sqrt ρ : ℂ) • dp)
    let v_q : ℝ := (ℏ / m) * (⟪p, dp⟫_ℂ).im
    let ν_q : ℝ := ℏ / (2 * m)
    ((1 / 2 : ℝ) * ρ * (bdVelocityPlus v ν ρ dρ ^ 2 + bdVelocityMinus v ν ρ dρ ^ 2) =
      ρ * v ^ 2 + ν ^ 2 * (dρ ^ 2 / ρ)) ∧
    ((m / 2) * ((1 / 2 : ℝ) * ρ *
        (bdVelocityPlus v_q ν_q ρ dρ ^ 2 + bdVelocityMinus v_q ν_q ρ dρ ^ 2)) +
      (ℏ ^ 2 / (8 * m)) * ρ * qfim p dp =
      (ℏ ^ 2 / (2 * m)) * ‖dΨ‖ ^ 2) := by
  intro dΨ v_q ν_q
  have hpara : ∀ (v' ν' : ℝ),
      (1 / 2 : ℝ) * ρ * (bdVelocityPlus v' ν' ρ dρ ^ 2 + bdVelocityMinus v' ν' ρ dρ ^ 2) =
      ρ * v' ^ 2 + ν' ^ 2 * (dρ ^ 2 / ρ) := fun v' ν' => by
    unfold bdVelocityPlus bdVelocityMinus
    field_simp [hρ.ne']; ring
  refine ⟨hpara v ν, ?_⟩
  rw [hpara v_q ν_q, three_channel_plucker_madelung_qfim hρ hp htang]
  dsimp only [v_q, ν_q]
  field_simp [hℏ.ne', hm.ne', hρ.ne']
  ring

/-! ### Section 4: Cole–Hopf Linearization & Exact Viscous Burgers Tanh Shock PDE -/

/-- **Theorem 4.1 (Pointwise Cole–Hopf Transformation: 1D Heat Equation ⇒ 1D Viscous Burgers PDE):**
If `τ ≠ 0` obeys the 1D heat equation `τ_t = ν τ_xx` (with spatial derivative `τ_xt = ν τ_xxx`),
then `v = -2 ν τ_x / τ` obeys the exact 1D nonlinear viscous Burgers equation
`v_t + v v_x - ν v_xx = 0`. -/
theorem coleHopf_heat_implies_viscous_burgers
    {τ : ℝ} (hτ : τ ≠ 0) (ν τ_x τ_xx τ_xxx : ℝ) :
    let τ_t := ν * τ_xx
    let τ_xt := ν * τ_xxx
    let v := -2 * ν * τ_x / τ
    let v_x := -2 * ν * (τ_xx / τ - τ_x ^ 2 / τ ^ 2)
    let v_xx := -2 * ν * (τ_xxx / τ - 3 * τ_x * τ_xx / τ ^ 2 + 2 * τ_x ^ 3 / τ ^ 3)
    let v_t := -2 * ν * (τ_xt / τ - τ_x * τ_t / τ ^ 2)
    v_t + v * v_x - ν * v_xx = 0 := by
  intro τ_t τ_xt v v_x v_xx v_t
  dsimp only [τ_t, τ_xt, v, v_x, v_xx, v_t]
  field_simp [hτ]; ring

/-- Moving 1D viscous Burgers shock wave `v(x, t) = c - a tanh((a / (2 ν))(x - c t))`. -/
noncomputable def burgersTanhShock (c a ν x t : ℝ) : ℝ :=
  c - a * Real.tanh ((a / (2 * ν)) * (x - c * t))

/-- **Theorem 4.2 (Exact Moving Viscous Burgers Tanh Shock PDE — Full Calculus Proof):**
For `ν ≠ 0` and all `(c, a, x, t) ∈ ℝ⁴`, `burgersTanhShock` satisfies the exact nonlinear
viscous Burgers equation `∂_t v + v ∂_x v = ν ∂_x² v` identically via `deriv` and `iteratedDeriv 2`. -/
theorem burgers_tanh_shock_solves_pde
    {ν : ℝ} (hν : ν ≠ 0) (c a x t : ℝ) :
    let v := burgersTanhShock c a ν x t
    let v_x := deriv (fun s => burgersTanhShock c a ν s t) x
    let v_xx := iteratedDeriv 2 (fun s => burgersTanhShock c a ν s t) x
    let v_t := deriv (fun s => burgersTanhShock c a ν x s) t
    v_t + v * v_x - ν * v_xx = 0 := by
  intro v v_x v_xx v_t
  have hcosh_ne : ∀ u : ℝ, Real.cosh u ≠ 0 := fun u => (Real.cosh_pos u).ne'
  have htanh_deriv : ∀ u : ℝ, HasDerivAt Real.tanh (1 - Real.tanh u ^ 2) u := fun u => by
    have hfun : Real.tanh = fun s => Real.sinh s / Real.cosh s := by
      ext s; exact Real.tanh_eq_sinh_div_cosh s
    rw [hfun]
    convert (Real.hasDerivAt_sinh u).div (Real.hasDerivAt_cosh u) (hcosh_ne u) using 1
    field_simp [hcosh_ne u]
  have hdx : ∀ x', HasDerivAt (fun s => burgersTanhShock c a ν s t)
      (-(a ^ 2 / (2 * ν)) * (1 - Real.tanh ((a / (2 * ν)) * (x' - c * t)) ^ 2)) x' := fun x' => by
    unfold burgersTanhShock
    have harg : HasDerivAt (fun s => (a / (2 * ν)) * (s - c * t)) (a / (2 * ν)) x' := by
      have hsub : HasDerivAt (fun s => s - c * t) 1 x' := by
        simpa using (hasDerivAt_id x').sub_const (c * t)
      convert hsub.const_mul (a / (2 * ν)) using 1; ring
    have ht := (htanh_deriv ((a / (2 * ν)) * (x' - c * t))).comp x' harg
    have hfull : HasDerivAt (fun s => c - a * Real.tanh ((a / (2 * ν)) * (s - c * t))) _ x' :=
      (hasDerivAt_const x' c).sub (ht.const_mul a)
    convert hfull using 1; field_simp [hν]; ring
  have hv_x_eq : v_x = -(a ^ 2 / (2 * ν)) * (1 - Real.tanh ((a / (2 * ν)) * (x - c * t)) ^ 2) :=
    (hdx x).deriv
  have hv_xx_eq : v_xx =
      (a ^ 3 / (2 * ν ^ 2)) * Real.tanh ((a / (2 * ν)) * (x - c * t)) *
        (1 - Real.tanh ((a / (2 * ν)) * (x - c * t)) ^ 2) := by
    dsimp only [v_xx]; rw [iteratedDeriv_succ, iteratedDeriv_one]
    have hfn : deriv (fun s => burgersTanhShock c a ν s t) =
        fun s => -(a ^ 2 / (2 * ν)) * (1 - Real.tanh ((a / (2 * ν)) * (s - c * t)) ^ 2) := by
      ext s; exact (hdx s).deriv
    rw [hfn]
    have harg : HasDerivAt (fun s => (a / (2 * ν)) * (s - c * t)) (a / (2 * ν)) x := by
      have hsub : HasDerivAt (fun s => s - c * t) 1 x := by
        simpa using (hasDerivAt_id x).sub_const (c * t)
      convert hsub.const_mul (a / (2 * ν)) using 1; ring
    have ht := (htanh_deriv ((a / (2 * ν)) * (x - c * t))).comp x harg
    have ht2 := ht.pow 2
    have h1sub : HasDerivAt (fun s => -(a ^ 2 / (2 * ν)) *
        (1 - Real.tanh ((a / (2 * ν)) * (s - c * t)) ^ 2)) _ x :=
      ((hasDerivAt_const x (1 : ℝ)).sub ht2).const_mul (-(a ^ 2 / (2 * ν)))
    rw [h1sub.deriv]
    simp only [Function.comp_apply]
    field_simp [hν]; ring
  have hv_t_eq : v_t =
      (c * a ^ 2 / (2 * ν)) * (1 - Real.tanh ((a / (2 * ν)) * (x - c * t)) ^ 2) := by
    dsimp only [v_t]; unfold burgersTanhShock
    have harg : HasDerivAt (fun s => (a / (2 * ν)) * (x - c * s)) (-(c * a / (2 * ν))) t := by
      have hcs : HasDerivAt (fun s => c * s) c t := by simpa using (hasDerivAt_id t).const_mul c
      have hsub : HasDerivAt (fun s => x - c * s) (0 - c) t := (hasDerivAt_const t x).sub hcs
      convert hsub.const_mul (a / (2 * ν)) using 1; ring
    have ht := (htanh_deriv ((a / (2 * ν)) * (x - c * t))).comp t harg
    have hfull : HasDerivAt (fun s => c - a * Real.tanh ((a / (2 * ν)) * (x - c * s))) _ t :=
      (hasDerivAt_const t c).sub (ht.const_mul a)
    rw [hfull.deriv]; field_simp [hν]; ring
  rw [hv_t_eq, hv_x_eq, hv_xx_eq]
  unfold v burgersTanhShock
  field_simp [hν]; ring

/-! ### Section 5: Linearized Compressible Stokes Acoustic Dispersion & Attenuation -/

/-- Diffusivity of sound `δ = (4/3) ν + ζ / ρ₀` for a compressible Newtonian fluid. -/
noncomputable def stokesSoundDiffusivity (ν ζ ρ₀ : ℝ) : ℝ :=
  (4 / 3 : ℝ) * ν + ζ / ρ₀

/-- Underdamped complex acoustic frequency `ω₊(k) = √(c_s² k² - δ² k⁴ / 4) - i (δ k² / 2)`. -/
noncomputable def stokesAcousticOmega (c_s δ k : ℝ) : ℂ :=
  ((Real.sqrt (c_s ^ 2 * k ^ 2 - δ ^ 2 * k ^ 4 / 4) : ℝ) : ℂ) -
    ((δ * k ^ 2 / 2 : ℝ) : ℂ) * Complex.I

/-- **Theorem 5.1 (Linearized Compressible Stokes Acoustic Dispersion & Causal Attenuation):**
In the underdamped regime `δ² k⁴ / 4 ≤ c_s² k²` with `δ ≥ 0`:
1. `ω₊` solves the exact complex compressible Stokes dispersion relation
   `ω₊² + i δ k² ω₊ - c_s² k² = 0`;
2. The attenuation rate satisfies `Im(ω₊) = -(1/2) δ k² ≤ 0` (causal viscous damping);
3. In the inviscid Euler / superfluid limit `δ = 0`, `ω₊ = |c_s k|` (undamped acoustic speed `c_s`). -/
theorem stokes_acoustic_attenuation_dispersion
    {c_s δ k : ℝ} (hδ : 0 ≤ δ) (hunder : δ ^ 2 * k ^ 4 / 4 ≤ c_s ^ 2 * k ^ 2) :
    let ω := stokesAcousticOmega c_s δ k
    ω ^ 2 + ((δ * k ^ 2 : ℝ) : ℂ) * Complex.I * ω - ((c_s ^ 2 * k ^ 2 : ℝ) : ℂ) = 0 ∧
    ω.im = -(δ * k ^ 2 / 2) ∧
    ω.im ≤ 0 ∧
    (δ = 0 → stokesAcousticOmega c_s δ k = ((|c_s * k| : ℝ) : ℂ)) := by
  intro ω
  have hdisc : 0 ≤ c_s ^ 2 * k ^ 2 - δ ^ 2 * k ^ 4 / 4 := by linarith
  have hsq : Real.sqrt (c_s ^ 2 * k ^ 2 - δ ^ 2 * k ^ 4 / 4) ^ 2 =
      c_s ^ 2 * k ^ 2 - δ ^ 2 * k ^ 4 / 4 := Real.sq_sqrt hdisc
  have hI2 : Complex.I ^ 2 = -1 := Complex.I_sq
  have hdisp : ω ^ 2 + ((δ * k ^ 2 : ℝ) : ℂ) * Complex.I * ω - ((c_s ^ 2 * k ^ 2 : ℝ) : ℂ) = 0 := by
    dsimp only [ω, stokesAcousticOmega]
    have hsqC : ((Real.sqrt (c_s ^ 2 * k ^ 2 - δ ^ 2 * k ^ 4 / 4) : ℝ) : ℂ) ^ 2 =
        ((c_s ^ 2 * k ^ 2 - δ ^ 2 * k ^ 4 / 4 : ℝ) : ℂ) := by
      norm_cast
    push_cast at hsqC ⊢
    linear_combination hsqC + (((δ : ℂ) ^ 2 * (k : ℂ) ^ 4 / 4) - ((δ : ℂ) * (k : ℂ) ^ 2) *
      ((δ : ℂ) * (k : ℂ) ^ 2 / 2)) * hI2
  have him : ω.im = -(δ * k ^ 2 / 2) := by
    dsimp only [ω, stokesAcousticOmega]
    simp only [Complex.sub_im, Complex.ofReal_im, Complex.mul_im, Complex.ofReal_re,
      Complex.I_re, Complex.I_im, mul_one, mul_zero, add_zero, zero_sub]
  have hnonpos : ω.im ≤ 0 := by
    rw [him]
    have : 0 ≤ δ * k ^ 2 / 2 := by positivity
    linarith
  refine ⟨hdisp, him, hnonpos, ?_⟩
  intro hδ0
  unfold stokesAcousticOmega
  rw [hδ0]
  simp only [zero_pow two_ne_zero, zero_mul, zero_div, sub_zero, Complex.ofReal_zero]
  have hmul : c_s ^ 2 * k ^ 2 = (c_s * k) ^ 2 := by ring
  rw [hmul, Real.sqrt_sq_eq_abs]

/-! ### Section 6: Unified Bogoliubov–Korteweg–Stokes Dispersion (`Signals.DDF` Bridge) & Rankine–Hugoniot Jump -/

/-- Underdamped complex acoustic-capillary frequency for compressible Navier–Stokes–Korteweg (NSK):
`ω₊(k) = √(c_s² k² + κ_K k⁴ - δ² k⁴ / 4) - i (δ k² / 2)`. -/
noncomputable def bogoliubovStokesOmega (c_s κ_K δ k : ℝ) : ℂ :=
  ((Real.sqrt (c_s ^ 2 * k ^ 2 + κ_K * k ^ 4 - δ ^ 2 * k ^ 4 / 4) : ℝ) : ℂ) -
    ((δ * k ^ 2 / 2 : ℝ) : ℂ) * Complex.I

/-- **Theorem 6.1 (Unified Bogoliubov–Korteweg–Stokes Dispersion & `Signals.DDF` Bridge):**
For a compressible NSK fluid with sound speed `c_s`, Korteweg capillarity `κ_K ≥ 0`, and
sound diffusivity `δ ≥ 0` in the underdamped regime `δ² k⁴ / 4 ≤ c_s² k² + κ_K k⁴`:
1. `ω₊` solves the exact coupled NSK dispersion relation
   `ω₊² + i δ k² ω₊ - (c_s² k² + κ_K k⁴) = 0`;
2. Setting `κ_K = 0` recovers `stokesAcousticOmega c_s δ k` identically;
3. Setting `δ = 0`, `κ_K = ℏ² / (4 m²)`, and `c_s² = g₀ ρ₀ / m` (`k ≠ 0`) recovers the exact
   `Signals.DDF.standardBogoliubovPhaseVelSq m g₀ ρ₀ ℏ k` squared phase velocity;
4. Positive Korteweg capillarity (`κ_K > 0`, `k ≠ 0`) strictly increases the underdamped
   stability discriminant over pure Stokes acoustics (`κ_K = 0`). -/
theorem compressible_nsk_bogoliubov_stokes_dispersion
    {c_s κ_K δ k : ℝ} (hδ : 0 ≤ δ) (hunder : δ ^ 2 * k ^ 4 / 4 ≤ c_s ^ 2 * k ^ 2 + κ_K * k ^ 4) :
    let ω := bogoliubovStokesOmega c_s κ_K δ k
    ω ^ 2 + ((δ * k ^ 2 : ℝ) : ℂ) * Complex.I * ω -
      ((c_s ^ 2 * k ^ 2 + κ_K * k ^ 4 : ℝ) : ℂ) = 0 ∧
    ω.im = -(δ * k ^ 2 / 2) ∧
    ω.im ≤ 0 ∧
    (κ_K = 0 → bogoliubovStokesOmega c_s κ_K δ k = stokesAcousticOmega c_s δ k) ∧
    (∀ m g₀ ρ₀ ℏ : ℝ, k ≠ 0 → δ = 0 → κ_K = ℏ ^ 2 / (4 * m ^ 2) → c_s ^ 2 = g₀ * ρ₀ / m →
      (bogoliubovStokesOmega c_s κ_K δ k).re ^ 2 / k ^ 2 =
        Signals.DDF.standardBogoliubovPhaseVelSq m g₀ ρ₀ ℏ k) ∧
    (0 < κ_K → k ≠ 0 →
      c_s ^ 2 * k ^ 2 - δ ^ 2 * k ^ 4 / 4 < c_s ^ 2 * k ^ 2 + κ_K * k ^ 4 - δ ^ 2 * k ^ 4 / 4) := by
  intro ω
  have hdisc : 0 ≤ c_s ^ 2 * k ^ 2 + κ_K * k ^ 4 - δ ^ 2 * k ^ 4 / 4 := by linarith
  have hsq : Real.sqrt (c_s ^ 2 * k ^ 2 + κ_K * k ^ 4 - δ ^ 2 * k ^ 4 / 4) ^ 2 =
      c_s ^ 2 * k ^ 2 + κ_K * k ^ 4 - δ ^ 2 * k ^ 4 / 4 := Real.sq_sqrt hdisc
  have hI2 : Complex.I ^ 2 = -1 := Complex.I_sq
  have hdisp : ω ^ 2 + ((δ * k ^ 2 : ℝ) : ℂ) * Complex.I * ω -
      ((c_s ^ 2 * k ^ 2 + κ_K * k ^ 4 : ℝ) : ℂ) = 0 := by
    dsimp only [ω, bogoliubovStokesOmega]
    have hsqC : ((Real.sqrt (c_s ^ 2 * k ^ 2 + κ_K * k ^ 4 - δ ^ 2 * k ^ 4 / 4) : ℝ) : ℂ) ^ 2 =
        ((c_s ^ 2 * k ^ 2 + κ_K * k ^ 4 - δ ^ 2 * k ^ 4 / 4 : ℝ) : ℂ) := by
      norm_cast
    push_cast at hsqC ⊢
    linear_combination hsqC + (((δ : ℂ) ^ 2 * (k : ℂ) ^ 4 / 4) - ((δ : ℂ) * (k : ℂ) ^ 2) *
      ((δ : ℂ) * (k : ℂ) ^ 2 / 2)) * hI2
  have him : ω.im = -(δ * k ^ 2 / 2) := by
    dsimp only [ω, bogoliubovStokesOmega]
    simp only [Complex.sub_im, Complex.ofReal_im, Complex.mul_im, Complex.ofReal_re,
      Complex.I_re, Complex.I_im, mul_one, mul_zero, add_zero, zero_sub]
  have hnonpos : ω.im ≤ 0 := by
    rw [him]
    have : 0 ≤ δ * k ^ 2 / 2 := by positivity
    linarith
  refine ⟨hdisp, him, hnonpos, ?_, ?_, ?_⟩
  · intro hκ0
    unfold bogoliubovStokesOmega stokesAcousticOmega
    rw [hκ0, zero_mul, add_zero]
  · intro m g₀ ρ₀ ℏ hk hδ0 hκ hcs
    have hre : (bogoliubovStokesOmega c_s κ_K δ k).re =
        Real.sqrt (c_s ^ 2 * k ^ 2 + κ_K * k ^ 4 - δ ^ 2 * k ^ 4 / 4) := by
      unfold bogoliubovStokesOmega
      simp only [Complex.sub_re, Complex.ofReal_re, Complex.mul_re, Complex.ofReal_im,
        Complex.I_re, Complex.I_im, mul_zero]
      ring
    rw [hre, hsq, hδ0, hκ, hcs]
    unfold Signals.DDF.standardBogoliubovPhaseVelSq
    have hk2 : k ^ 2 ≠ 0 := pow_ne_zero 2 hk
    field_simp [hk2]
    ring
  · intro hκ_pos hk
    have hk4 : 0 < k ^ 4 := by positivity
    nlinarith

/-- **Theorem 6.2 (1D Compressible Rankine–Hugoniot Mass & Momentum Shock Jump):**
Across a 1D shock moving at speed `s = (ρ_R u_R - ρ_L u_L) / (ρ_R - ρ_L)` (`ρ_R ≠ ρ_L`),
the shock-frame mass flux `J = ρ_L (u_L - s) = ρ_R (u_R - s)` is conserved identically,
and lab-frame momentum jump `s (ρ_R u_R - ρ_L u_L) = (ρ_R u_R² + P_R) - (ρ_L u_L² + P_L)`
is equivalent to shock-frame total momentum-flux balance
`ρ_R (u_R - s)² + P_R = ρ_L (u_L - s)² + P_L`. -/
theorem rankine_hugoniot_compressible_jump
    {ρ_L ρ_R : ℝ} (hdiff : ρ_R - ρ_L ≠ 0) (u_L u_R P_L P_R : ℝ) :
    let s : ℝ := (ρ_R * u_R - ρ_L * u_L) / (ρ_R - ρ_L)
    ρ_R * (u_R - s) = ρ_L * (u_L - s) ∧
    (s * (ρ_R * u_R - ρ_L * u_L) = (ρ_R * u_R ^ 2 + P_R) - (ρ_L * u_L ^ 2 + P_L) ↔
      ρ_R * (u_R - s) ^ 2 + P_R = ρ_L * (u_L - s) ^ 2 + P_L) := by
  intro s
  have hmass : ρ_R * (u_R - s) = ρ_L * (u_L - s) := by
    dsimp only [s]
    field_simp [hdiff]
    ring
  have hs_mass : s * (ρ_R - ρ_L) = ρ_R * u_R - ρ_L * u_L := by
    dsimp only [s]
    field_simp [hdiff]
  refine ⟨hmass, ?_⟩
  have hdiff_id : (ρ_R * (u_R - s) ^ 2 + P_R) - (ρ_L * (u_L - s) ^ 2 + P_L) =
      ((ρ_R * u_R ^ 2 + P_R) - (ρ_L * u_L ^ 2 + P_L)) - s * (ρ_R * u_R - ρ_L * u_L) := by
    linear_combination s * hs_mass
  constructor <;> intro h <;> linarith

end Signals.NavierStokes.Compressible
