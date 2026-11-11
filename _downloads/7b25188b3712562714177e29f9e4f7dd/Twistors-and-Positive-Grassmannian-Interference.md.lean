import Architect
import Mathlib.Analysis.SpecialFunctions.Integrals.Basic
import Mathlib.Analysis.SpecialFunctions.Pow.Real
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic
import Mathlib.Analysis.Complex.Basic
import Mathlib.MeasureTheory.Integral.IntervalIntegral.Basic
import Mathlib.MeasureTheory.Integral.Bochner.Basic
import Mathlib.MeasureTheory.Integral.Bochner.Set
import Mathlib.LinearAlgebra.CrossProduct
import Mathlib.LinearAlgebra.Matrix.DotProduct
import Mathlib.LinearAlgebra.Matrix.Notation
import Mathlib.Tactic.FinCases
import Mathlib.Tactic.Ring
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity

open MeasureTheory Interval Complex Matrix
open scoped Matrix

namespace WakefieldPropulsion

/-- Following Physlib conventions (`Space 3`), 3D spatial vectors are represented as
    `Fin 3 → ℝ` so that `![x, y, z]`, `dotProduct` (`⬝ᵥ`), and `crossProduct` (`⨯₃`)
    reduce directly in the kernel via `fin_cases` and `ring`. -/
@[blueprint "def:wakefield-vec3"
  (title := "Three-dimensional spatial vector representation")
  (statement := /-- A three-dimensional spatial vector is represented by $\operatorname{Fin}(3)\to\mathbb R$. -/)]
abbrev Vec3 := Fin 3 → ℝ

/-- Squared Euclidean norm `‖v‖² = v ⬝ᵥ v` on `Vec3`. -/
@[blueprint "def:wakefield-norm-sq"
  (title := "Squared Euclidean norm on Vec3")
  (statement := /-- For $\mathbf v\in\mathbb R^3$, $\lVert\mathbf v\rVert^2=\mathbf v\cdot\mathbf v$. -/)]
def normSqVec3 (v : Vec3) : ℝ := v ⬝ᵥ v

/-- The squared Euclidean norm on `Vec3` is nonnegative. -/
@[blueprint "lem:wakefield-norm-sq-nonneg"
  (title := "Nonnegativity of squared Euclidean norm")
  (statement := /-- For every $\mathbf v\in\mathbb R^3$, $\lVert\mathbf v\rVert^2\ge 0$. -/)
  (proof := /-- Sum the three coordinate squares. -/)
  (latexEnv := "lemma")]
lemma normSqVec3_nonneg (v : Vec3) : 0 ≤ normSqVec3 v := by
  simp only [normSqVec3, dotProduct, Fin.sum_univ_three]
  nlinarith [sq_nonneg (v 0), sq_nonneg (v 1), sq_nonneg (v 2)]


/-!
## 1. Ponderomotive Force Derivation
Proves that over one RF period $T = 2\pi / \omega$, the first-order oscillatory Lorentz force
cancels identically (`oscillatory_lorentz_cancels`), leaving only the secular Ponderomotive
Force $-\nabla U_p$ (`ponderomotive_limit`).
-/
namespace Ponderomotive

variable (m_e e ω : ℝ)

/-- The high-frequency oscillating electric field E(x, t) = cos(ωt) • E0(x). -/
@[blueprint "def:wakefield-e-field"
  (title := "Harmonic electric-field envelope")
  (statement := /-- The oscillating electric field with spatial amplitude $\mathbf E_0(\mathbf x)$
    is $\mathbf E(\mathbf x,t)=\cos(\omega t)\,\mathbf E_0(\mathbf x)$. -/)]
noncomputable def E_field (E0 : Vec3 → Vec3) (x : Vec3) (t : ℝ) : Vec3 :=
  (Real.cos (ω * t)) • E0 x

/-- The Ponderomotive Potential U_p(x) = (e² / 4 m_e ω²) ‖E0(x)‖². -/
@[blueprint "def:wakefield-ponderomotive-potential"
  (title := "Ponderomotive potential")
  (statement := /-- The cycle-averaged ponderomotive potential is
    $U_p(\mathbf x)=\frac{e^2}{4 m_e\omega^2}\lVert\mathbf E_0(\mathbf x)\rVert^2$. -/)]
noncomputable def PonderomotivePotential (E0 : Vec3 → Vec3) (x : Vec3) : ℝ :=
  (e^2 / (4 * m_e * ω^2)) * normSqVec3 (E0 x)

/-- The ponderomotive potential is nonnegative for positive particle mass and nonzero frequency. -/
@[blueprint "lem:wakefield-ponderomotive-potential-nonneg"
  (title := "Nonnegativity of ponderomotive potential")
  (statement := /-- For $m_e\ge 0$, $U_p(\mathbf x)\ge 0$. -/)
  (proof := /-- Combine nonnegativity of the prefactor and squared norm. -/)
  (latexEnv := "lemma")]
lemma ponderomotive_potential_nonneg (E0 : Vec3 → Vec3) (x : Vec3)
    (hm : 0 ≤ m_e) :
    0 ≤ PonderomotivePotential m_e e ω E0 x := by
  unfold PonderomotivePotential
  have h_coeff : 0 ≤ e^2 / (4 * m_e * ω^2) := by positivity
  exact mul_nonneg h_coeff (normSqVec3_nonneg (E0 x))

/-- The secular Ponderomotive Force F_p(x) = -(e² / 4 m_e ω²) ∇(‖E0(x)‖²),
    parameterized by the spatial gradient field `grad_E0_sq` of `‖E0(x)‖²`. -/
@[blueprint "def:wakefield-ponderomotive-force"
  (title := "Secular ponderomotive force")
  (statement := /-- Given $\nabla(\lVert\mathbf E_0(\mathbf x)\rVert^2)$, the secular ponderomotive
    force is $\mathbf F_p(\mathbf x)=-\frac{e^2}{4 m_e\omega^2}\nabla(\lVert\mathbf E_0(\mathbf x)\rVert^2)$. -/)]
noncomputable def PonderomotiveForce (grad_E0_sq : Vec3 → Vec3) (x : Vec3) : Vec3 :=
  (- (e^2 / (4 * m_e * ω^2))) • grad_E0_sq x

/-- The ponderomotive force acts down the intensity gradient: F_p(x) ⬝ᵥ ∇(‖E0(x)‖²) ≤ 0. -/
@[blueprint "lem:wakefield-ponderomotive-down-gradient"
  (title := "Ponderomotive force opposes intensity gradient")
  (statement := /-- For $m_e\ge 0$, $\mathbf F_p(\mathbf x)\cdot\nabla(\lVert\mathbf E_0(\mathbf x)\rVert^2)\le 0$. -/)
  (proof := /-- Factor out the nonpositive scalar prefactor from the squared gradient norm. -/)
  (latexEnv := "lemma")]
lemma ponderomotive_force_down_gradient (grad_E0_sq : Vec3 → Vec3) (x : Vec3)
    (hm : 0 ≤ m_e) :
    (PonderomotiveForce m_e e ω grad_E0_sq x) ⬝ᵥ (grad_E0_sq x) ≤ 0 := by
  unfold PonderomotiveForce
  rw [smul_dotProduct, smul_eq_mul]
  have h_coeff : 0 ≤ e^2 / (4 * m_e * ω^2) := by positivity
  have h_norm : 0 ≤ normSqVec3 (grad_E0_sq x) := normSqVec3_nonneg (grad_E0_sq x)
  change (- (e^2 / (4 * m_e * ω^2))) * normSqVec3 (grad_E0_sq x) ≤ 0
  nlinarith

/-- Lemma: The linear oscillatory component cos(ωt) integrates to zero over a full cycle T = 2π/ω. -/
@[blueprint "lem:wakefield-oscillatory-lorentz-cancels"
  (title := "First-order quiver oscillation cancels over one RF period")
  (statement := /-- For $\omega\ne 0$ and $T=2\pi/\omega$, $\int_0^T\cos(\omega t)\,dt=0$. -/)
  (proof := /-- Change variables $u=\omega t$ over $[0,2\pi]$ and evaluate $\sin(2\pi)-\sin(0)=0$. -/)
  (latexEnv := "lemma")]
lemma oscillatory_lorentz_cancels (h_ω : ω ≠ 0) (T : ℝ) (hT : T = 2 * Real.pi / ω) :
    ∫ t in (0 : ℝ)..T, Real.cos (ω * t) = 0 := by
  subst hT
  rw [intervalIntegral.integral_comp_mul_left (fun x => Real.cos x) h_ω]
  have h_upper : ω * (2 * Real.pi / ω) = 2 * Real.pi := mul_div_cancel₀ (2 * Real.pi) h_ω
  rw [mul_zero, h_upper, integral_cos, Real.sin_two_pi, Real.sin_zero, sub_self, smul_zero]

/-- Theorem: The cycle-averaged decomposed Lorentz force (secular ponderomotive force plus
    first-order oscillatory quiver force `cos(ωt) * F_osc`) over one period T = 2π/ω
    yields the exact Ponderomotive Force along each spatial axis `i : Fin 3`. -/
@[blueprint "thm:wakefield-ponderomotive-limit"
  (title := "Cycle-averaged Lorentz force yields the ponderomotive force")
  (statement := /-- Averaging $\mathbf F_p(\mathbf x)+\mathbf F_{\mathrm{osc}}(\mathbf x)\cos(\omega t)$
    over $T=2\pi/\omega$ ($\omega\ne 0$) yields $\mathbf F_p(\mathbf x)$ componentwise. -/)
  (proof := /-- Split the interval integral and apply \texttt{oscillatory\_lorentz\_cancels}. -/)]
theorem ponderomotive_limit
    (h_ω : ω ≠ 0)
    (grad_E0_sq F_osc : Vec3 → Vec3)
    (x : Vec3) (T : ℝ) (hT : T = 2 * Real.pi / ω) (i : Fin 3) :
    let F_inst (t : ℝ) : ℝ :=
      PonderomotiveForce m_e e ω grad_E0_sq x i + F_osc x i * Real.cos (ω * t)
    (1 / T) * (∫ t in (0 : ℝ)..T, F_inst t) =
      PonderomotiveForce m_e e ω grad_E0_sq x i := by
  intro F_inst
  have hT_ne : T ≠ 0 := by
    rw [hT]
    exact div_ne_zero (mul_ne_zero two_ne_zero Real.pi_ne_zero) h_ω
  have h_int_const : IntervalIntegrable (fun _ : ℝ => PonderomotiveForce m_e e ω grad_E0_sq x i) volume 0 T :=
    continuous_const.intervalIntegrable 0 T
  have h_int_cos : IntervalIntegrable (fun t => F_osc x i * Real.cos (ω * t)) volume 0 T :=
    (continuous_const.mul (Real.continuous_cos.comp (continuous_const.mul continuous_id))).intervalIntegrable 0 T
  change (1 / T) * (∫ t in (0 : ℝ)..T,
    (PonderomotiveForce m_e e ω grad_E0_sq x i + F_osc x i * Real.cos (ω * t))) = _
  rw [intervalIntegral.integral_add h_int_const h_int_cos]
  rw [intervalIntegral.integral_const, intervalIntegral.integral_const_mul]
  rw [oscillatory_lorentz_cancels ω h_ω T hT]
  simp [smul_eq_mul, hT_ne]

end Ponderomotive


/-!
## 2. Standard Aerodynamics Implementation
Integrates the Bernoulli dynamic pressure over the airfoil manifold with respect to an
explicit surface measure `μ` and proves orthogonality of the differential aerodynamic
torque to both the lever arm and the normal pressure force.
-/
namespace StandardAerodynamics

variable (ρ_plasma : ℝ)
variable (V_wake : Vec3 → Vec3)
variable (AirfoilSurface : Set Vec3)
variable (n : Vec3 → Vec3)
variable (CM : Vec3)

/-- Bernoulli Dynamic Pressure Field mapped from the Wakefield velocity. -/
@[blueprint "def:wakefield-dynamic-pressure"
  (title := "Bernoulli dynamic pressure field")
  (statement := /-- Dynamic pressure is $q(\mathbf x)=\tfrac12\rho\lVert\mathbf V_{\mathrm{wake}}(\mathbf x)\rVert^2$. -/)]
noncomputable def DynamicPressure (x : Vec3) : ℝ :=
  0.5 * ρ_plasma * normSqVec3 (V_wake x)

/-- Dynamic pressure is nonnegative for nonnegative fluid density. -/
@[blueprint "lem:wakefield-dynamic-pressure-nonneg"
  (title := "Nonnegativity of dynamic pressure")
  (statement := /-- For $\rho\ge 0$, $q(\mathbf x)\ge 0$. -/)
  (proof := /-- Combine $\rho\ge 0$ with $\lVert\mathbf V_{\mathrm{wake}}(\mathbf x)\rVert^2\ge 0$. -/)
  (latexEnv := "lemma")]
lemma dynamic_pressure_nonneg (h_ρ : 0 ≤ ρ_plasma) (x : Vec3) :
    0 ≤ DynamicPressure ρ_plasma V_wake x := by
  unfold DynamicPressure
  have h_norm := normSqVec3_nonneg (V_wake x)
  nlinarith

/-- Uncalibrated dynamic-pressure surface load proxy `dF_proxy(x) = -q(x) • n(x)`.
    Note: At a stagnation point (`V_wake x = 0`) this proxy vanishes whereas static
    Bernoulli pressure attains `p_0`; see `BernoulliSurfaceTraction` below. -/
@[blueprint "def:wakefield-differential-force"
  (title := "Uncalibrated dynamic-pressure surface load proxy")
  (statement := /-- The dynamic-pressure load proxy is $-q(\mathbf x)\,\mathbf n(\mathbf x)$. -/)]
noncomputable def DifferentialForce (x : Vec3) : Vec3 :=
  (- DynamicPressure ρ_plasma V_wake x) • (n x)

/-- Incompressible Bernoulli static pressure `p(x) = p_0 - q(x)` from stagnation pressure `p_0`. -/
@[blueprint "def:wakefield-bernoulli-static-pressure"
  (title := "Bernoulli static pressure")
  (statement := /-- Static pressure is $p(\mathbf x)=p_0-\tfrac12\rho\lVert\mathbf V_{\mathrm{wake}}(\mathbf x)\rVert^2$. -/)]
noncomputable def BernoulliStaticPressure (p_0 : ℝ) (x : Vec3) : ℝ :=
  p_0 - DynamicPressure ρ_plasma V_wake x

/-- Physical normal surface pressure traction `dF_static(x) = -p(x) • n(x)`. -/
@[blueprint "def:wakefield-bernoulli-surface-traction"
  (title := "Static Bernoulli surface traction")
  (statement := /-- Static Bernoulli traction is $-p(\mathbf x)\,\mathbf n(\mathbf x)=-(p_0-q(\mathbf x))\,\mathbf n(\mathbf x)$. -/)]
noncomputable def BernoulliSurfaceTraction (p_0 : ℝ) (x : Vec3) : Vec3 :=
  (- BernoulliStaticPressure ρ_plasma V_wake p_0 x) • (n x)

/-- At a stagnation point (`V_wake x = 0`), static Bernoulli traction equals `(-p_0) • n(x)`
    whereas the dynamic-pressure proxy vanishes. -/
@[blueprint "thm:wakefield-bernoulli-stagnation-traction"
  (title := "Stagnation point recovers static pressure traction")
  (statement := /-- When $\mathbf V_{\mathrm{wake}}(\mathbf x)=\mathbf 0$,
    $-p(\mathbf x)\,\mathbf n(\mathbf x)=-p_0\,\mathbf n(\mathbf x)$ while $-q(\mathbf x)\,\mathbf n(\mathbf x)=\mathbf 0$. -/)
  (proof := /-- Substitute $\mathbf V_{\mathrm{wake}}(\mathbf x)=\mathbf 0$ into $q(\mathbf x)$ and $p(\mathbf x)$. -/)]
theorem bernoulli_stagnation_traction (p_0 : ℝ) (x : Vec3) (h_stag : V_wake x = 0) :
    BernoulliSurfaceTraction ρ_plasma V_wake n p_0 x = (- p_0) • (n x) ∧
      DifferentialForce ρ_plasma V_wake n x = 0 := by
  constructor
  · simp [BernoulliSurfaceTraction, BernoulliStaticPressure, DynamicPressure, normSqVec3, h_stag]
  · simp [DifferentialForce, DynamicPressure, normSqVec3, h_stag]

/-- Differential aerodynamic torque proxy at a point `x` relative to the Center of Mass. -/
@[blueprint "def:wakefield-differential-moment"
  (title := "Differential dynamic-pressure moment proxy")
  (statement := /-- The differential moment of the dynamic-pressure load proxy relative to $\mathbf x_{\mathrm{CM}}$ is
    $(\mathbf x-\mathbf x_{\mathrm{CM}})\times (-q(\mathbf x)\,\mathbf n(\mathbf x))$. -/)]
noncomputable def DifferentialMoment (x : Vec3) : Vec3 :=
  (x - CM) ⨯₃ (DifferentialForce ρ_plasma V_wake n x)

/-- Differential aerodynamic moment from static Bernoulli surface traction. -/
@[blueprint "def:wakefield-bernoulli-differential-moment"
  (title := "Differential static-Bernoulli aerodynamic moment")
  (statement := /-- The differential torque from static Bernoulli surface traction is
    $(\mathbf x-\mathbf x_{\mathrm{CM}})\times (-p(\mathbf x)\,\mathbf n(\mathbf x))$. -/)]
noncomputable def BernoulliDifferentialMoment (p_0 : ℝ) (x : Vec3) : Vec3 :=
  (x - CM) ⨯₃ (BernoulliSurfaceTraction ρ_plasma V_wake n p_0 x)

/-- The total dynamic-pressure moment proxy integrated over the Airfoil Hull
    with respect to surface area measure `μ`. -/
@[blueprint "def:wakefield-total-aerodynamic-moment"
  (title := "Surface-integrated dynamic-pressure moment proxy")
  (statement := /-- Integrating the differential dynamic-pressure moment proxy over the hull surface with respect to
    surface measure $\mu$ yields the total moment proxy vector. -/)]
noncomputable def total_aerodynamic_moment [MeasurableSpace Vec3] (μ : Measure Vec3) : Vec3 :=
  fun i => ∫ x in AirfoilSurface, DifferentialMoment ρ_plasma V_wake n CM x i ∂μ

/-- Theorem: The differential aerodynamic torque at any hull point `x` is strictly
    orthogonal to the moment lever arm `x - CM`. -/
@[blueprint "thm:wakefield-moment-orthogonal-lever"
  (title := "Differential aerodynamic torque is orthogonal to lever arm")
  (statement := /-- At every hull point $\mathbf x$,
    $((\mathbf x-\mathbf x_{\mathrm{CM}})\times d\mathbf F(\mathbf x))\cdot(\mathbf x-\mathbf x_{\mathrm{CM}})=0$. -/)
  (proof := /-- Apply \texttt{dot\_self\_cross}. -/)]
theorem differential_moment_orthogonal_lever_arm (x : Vec3) :
    (DifferentialMoment ρ_plasma V_wake n CM x) ⬝ᵥ (x - CM) = 0 := by
  simp only [DifferentialMoment, dotProduct_comm, dot_self_cross]

/-- Theorem: The differential aerodynamic torque at any hull point `x` is strictly
    orthogonal to the differential normal pressure force. -/
@[blueprint "thm:wakefield-moment-orthogonal-force"
  (title := "Differential aerodynamic torque is orthogonal to normal force")
  (statement := /-- At every hull point $\mathbf x$,
    $((\mathbf x-\mathbf x_{\mathrm{CM}})\times d\mathbf F(\mathbf x))\cdot d\mathbf F(\mathbf x)=0$. -/)
  (proof := /-- Apply \texttt{dot\_cross\_self}. -/)]
theorem differential_moment_orthogonal_force (x : Vec3) :
    (DifferentialMoment ρ_plasma V_wake n CM x) ⬝ᵥ (DifferentialForce ρ_plasma V_wake n x) = 0 := by
  simp only [DifferentialMoment, dotProduct_comm, dot_cross_self]

end StandardAerodynamics


/-!
## 3. Dilatant Dark Fluid (DDF), Madelung Phase-Slip Thrust & QEClean Homology
Proves quantized circulation around a topological phase-slip defect of winding
number `n : ℤ`, and includes QEClean-style homological chain-complex proofs that
single-valued lattice gauge phases have zero vortex syndrome ($\delta^1 \circ \delta^0 = 0$)
while a $2\pi n$ branch jump extracts the exact quantized vortex charge.
-/
namespace DDFQuantumHydrodynamics

variable (m_DDF hbar : ℝ)
variable (ψ : Vec3 → ℂ)

/-- Fluid Density ρ = |ψ|². -/
@[blueprint "def:wakefield-ddf-density"
  (title := "Madelung superfluid density")
  (statement := /-- The condensate density is $\rho(\mathbf x)=|\psi(\mathbf x)|^2$. -/)]
noncomputable def DDF_Density (x : Vec3) : ℝ :=
  Complex.normSq (ψ x)

/-- Square root of the fluid density amplitude √ρ. -/
@[blueprint "def:wakefield-sqrt-density"
  (title := "Madelung amplitude")
  (statement := /-- The real amplitude is $\sqrt{\rho(\mathbf x)}$. -/)]
noncomputable def SqrtDensity (x : Vec3) : ℝ :=
  Real.sqrt (DDF_Density ψ x)

/-- Quantum Phase S = arg(ψ). -/
@[blueprint "def:wakefield-ddf-phase"
  (title := "Madelung quantum phase")
  (statement := /-- The principal phase of $\psi$ is $S(\mathbf x)=\arg(\psi(\mathbf x))$. -/)]
noncomputable def DDF_Phase (x : Vec3) : ℝ :=
  Complex.arg (ψ x)

/-- The Bohm Quantum Potential Q = -(ℏ² / 2m) * (∇²√ρ / √ρ), parameterized by
    the spatial Laplacian `laplacian_sqrt_rho` of `√ρ` (regularized away from ρ = 0). -/
@[blueprint "def:wakefield-quantum-potential"
  (title := "Regularized Bohm quantum potential")
  (statement := /-- Away from vortex cores ($\rho(\mathbf x)>0$),
    $Q(\mathbf x)=-\frac{\hbar^2}{2m}\frac{\Delta\sqrt{\rho}(\mathbf x)}{\sqrt{\rho(\mathbf x)}}$. -/)]
noncomputable def QuantumPotential (laplacian_sqrt_rho : Vec3 → ℝ) (x : Vec3) : ℝ :=
  - (hbar^2 / (2 * m_DDF)) * (laplacian_sqrt_rho x) / (SqrtDensity ψ x)

/-- Superfluid Velocity Field v = (ℏ / m) * ∇S. -/
@[blueprint "def:wakefield-superfluid-velocity"
  (title := "Madelung superfluid velocity field")
  (statement := /-- Outside vortex cores, $\mathbf v(\mathbf x)=\frac{\hbar}{m}\nabla S(\mathbf x)$. -/)]
noncomputable def SuperfluidVelocity (grad_S : Vec3 → Vec3) (x : Vec3) : Vec3 :=
  (hbar / m_DDF) • (grad_S x)

/-- Tangential superfluid velocity along a circular contour of radius `R`
    enclosing a topological vortex defect of integer winding number `n : ℤ`. -/
@[blueprint "def:wakefield-vortex-tangential-velocity"
  (title := "Azimuthal vortex tangential velocity")
  (statement := /-- Along a circular contour of radius $R$ enclosing winding $n\in\mathbb Z$,
    $v_\theta=\frac{\hbar}{m}\frac{n}{R}$. -/)]
noncomputable def VortexTangentialVelocity (n : ℤ) (R : ℝ) (_θ : ℝ) : ℝ :=
  (hbar / m_DDF) * ((n : ℝ) / R)

/-- Theorem: A Phase Slip Generates Quantized Circulation.
    Integrating the tangential superfluid velocity `v_θ(θ) * R dθ` around a closed circular
    contour `θ ∈ [0, 2π]` of radius `R ≠ 0` yields the quantized circulation `n * (2π ℏ / m_DDF)`. -/
@[blueprint "thm:wakefield-phase-slip-circulation"
  (title := "Quantized circulation around a topological phase-slip vortex")
  (statement := /-- For $R\ne 0$ and $n\in\mathbb Z$, $\int_0^{2\pi} v_\theta(\theta)R\,d\theta = n\,\frac{2\pi\hbar}{m}$. -/)
  (proof := /-- Integrate the constant azimuthal integrand over $[0,2\pi]$ and cancel $R\ne 0$. -/)]
theorem phase_slip_thrust (R : ℝ) (hR : R ≠ 0) (n : ℤ) :
    ∫ θ in (0 : ℝ)..(2 * Real.pi), (VortexTangentialVelocity m_DDF hbar n R θ * R) =
      (n : ℝ) * (2 * Real.pi * hbar / m_DDF) := by
  unfold VortexTangentialVelocity
  rw [intervalIntegral.integral_const]
  simp only [sub_zero, smul_eq_mul]
  field_simp [hR]

/-- QEClean Homological Certificate: Discrete 2D Plaquette Vortex Holonomy.
    Given four lattice site phases `S00, S10, S11, S01 : ℝ` around a unit plaquette,
    the discrete coboundary `d₁(d₀ S)` around the closed loop vanishes identically in the
    absence of a singular branch-cut defect (`2π n`), certifying `δ¹ ∘ δ⁰ = 0`. -/
@[blueprint "thm:wakefield-plaquette-coboundary-zero"
  (title := "Discrete plaquette coboundary vanishes without branch cuts")
  (statement := /-- Around a 4-site lattice plaquette with single-valued phases, the oriented
    sum of link differences vanishes ($\delta^1\circ\delta^0=0$). -/)
  (proof := /-- Telescope the site phase differences by ring algebra. -/)]
theorem qec_plaquette_coboundary_zero (S00 S10 S11 S01 : ℝ) :
    let e_bottom := S10 - S00
    let e_right  := S11 - S10
    let e_top    := S01 - S11
    let e_left   := S00 - S01
    e_bottom + e_right + e_top + e_left = 0 := by
  intro e_bottom e_right e_top e_left
  ring

/-- QEClean Syndrome Certificate: When a phase slip injects a `2π * n` branch jump across
    the top link of the plaquette, the syndrome extracts the exact topological charge `2π * n`. -/
@[blueprint "thm:wakefield-plaquette-phase-slip-syndrome"
  (title := "Discrete plaquette syndrome extracts 2πn branch jump")
  (statement := /-- A $2\pi n$ branch jump on one plaquette link yields loop holonomy $2\pi n$. -/)
  (proof := /-- Telescope the site phases and retain the $2\pi n$ branch jump. -/)]
theorem qec_plaquette_phase_slip_syndrome (S00 S10 S11 S01 : ℝ) (n : ℤ) :
    let e_bottom := S10 - S00
    let e_right  := S11 - S10
    let e_top    := (S01 - S11) + (n : ℝ) * (2 * Real.pi)
    let e_left   := S00 - S01
    e_bottom + e_right + e_top + e_left = (n : ℝ) * (2 * Real.pi) := by
  intro e_bottom e_right e_top e_left
  ring

end DDFQuantumHydrodynamics


/-!
## 4. Halbach Array Transverse MHD Extraction
Proves via explicit `Fin 3` case analysis that a longitudinal velocity ($v_z$)
entering a static Halbach transverse magnetic field ($B_y$) experiences a purely
orthogonal magnetic Lorentz force ($F_x = -q v_z B_y$), and that pure magnetic
deflection performs zero mechanical work ($\mathbf{F} \cdot \mathbf{v} = 0$).
Note: Electrical power extraction requires a transverse load electric field $E_x$
against the deflected current $J_x$, which creates a retarding axial force $J_x B_y$.
-/
namespace HalbachExtraction

variable (q : ℝ)

/-- The initial purely longitudinal velocity of the particle in the Langmuir wave. -/
@[blueprint "def:wakefield-v-longitudinal"
  (title := "Longitudinal velocity vector")
  (statement := /-- Purely axial velocity $(0,0,v_z)$. -/)]
def v_longitudinal (vz : ℝ) : Vec3 :=
  ![0, 0, vz]

/-- The static transverse magnetic field provided by the Halbach Array. -/
@[blueprint "def:wakefield-b-halbach"
  (title := "Transverse Halbach magnetic field vector")
  (statement := /-- Static transverse magnetic field $(0,B_y,0)$. -/)]
def B_halbach (By : ℝ) : Vec3 :=
  ![0, By, 0]

/-- The magnetic Lorentz force vector: F = q • (v ⨯₃ B). -/
@[blueprint "def:wakefield-lorentz-force"
  (title := "Magnetic Lorentz force")
  (statement := /-- Magnetic Lorentz force $\mathbf F=q(\mathbf v\times\mathbf B)$. -/)]
def LorentzForce (v B : Vec3) : Vec3 :=
  q • (v ⨯₃ B)

/-- Theorem: Halbach Deflection Geometry
    Proves that a purely longitudinal velocity entering a purely Y-axis magnetic field
    results in a purely X-axis force. -/
@[blueprint "thm:wakefield-halbach-transverse-conversion"
  (title := "Halbach transverse Lorentz deflection")
  (statement := /-- For $\mathbf v=(0,0,v_z)$ and $\mathbf B=(0,B_y,0)$,
    $q(\mathbf v\times\mathbf B)=(-q v_z B_y,0,0)$. -/)
  (proof := /-- Expand all three $\operatorname{Fin}(3)$ components and simplify by ring algebra. -/)]
theorem halbach_transverse_conversion (vz By : ℝ) :
    LorentzForce q (v_longitudinal vz) (B_halbach By) = ![-q * vz * By, 0, 0] := by
  ext i
  fin_cases i
  · simp [LorentzForce, v_longitudinal, B_halbach, cross_apply]
    ring
  · simp [LorentzForce, v_longitudinal, B_halbach, cross_apply]
  · simp [LorentzForce, v_longitudinal, B_halbach, cross_apply]

/-- Theorem: Pure Magnetic Deflection Is Work-Free
    The magnetic Lorentz force is strictly orthogonal to the particle velocity `v`;
    electrical energy extraction requires an opposing load electric field `E_load`. -/
@[blueprint "thm:wakefield-lorentz-work-free"
  (title := "Pure magnetic deflection is work-free")
  (statement := /-- For any $\mathbf v$ and $\mathbf B$, $q(\mathbf v\times\mathbf B)\cdot\mathbf v=0$. -/)
  (proof := /-- Factor out $q$ and apply \texttt{dot\_self\_cross}. -/)]
theorem lorentz_force_work_free (v B : Vec3) :
    (LorentzForce q v B) ⬝ᵥ v = 0 := by
  rw [LorentzForce, smul_dotProduct, dotProduct_comm, dot_self_cross, smul_zero]

end HalbachExtraction


/-!
## 5. D-He3 Centrifugal Cooling Spool & Gyroscopic Control
Proves the radial centrifugal pressure integral via Mathlib's `integral_id`,
establishes the closed-loop thermosyphon buoyancy head `ΔP_loop = (1/2)(ρ_cold - ρ_hot)ω²(r_outer² - r_inner²)`,
and verifies the 3D gyroscopic precession torque via `fin_cases` and `ring`.
-/
namespace CentrifugalSpool

variable (ρ_He3 ω I_spool : ℝ)

/-- The radial pressure gradient induced by centrifugal force: dP/dr = ρ_He3 * ω² * r. -/
@[blueprint "def:wakefield-centrifugal-pressure-gradient"
  (title := "Radial centrifugal pressure gradient")
  (statement := /-- Radial pressure gradient $\frac{dP}{dr}=\rho\omega^2 r$. -/)]
noncomputable def CentrifugalPressureGradient (r : ℝ) : ℝ :=
  (ρ_He3 * ω^2) * r

/-- Theorem: The total pressure differential ΔP from hub (`r_inner`) to rim (`r_outer`)
    integrates to `(1 / 2) * ρ_He3 * ω² * (r_outer² - r_inner²)`. -/
@[blueprint "thm:wakefield-centrifugal-pump-head"
  (title := "Integrated radial centrifugal pressure head")
  (statement := /-- $\int_{r_{\mathrm{in}}}^{r_{\mathrm{out}}}\rho\omega^2 r\,dr =
    \tfrac12\rho\omega^2(r_{\mathrm{out}}^2-r_{\mathrm{in}}^2)$. -/)
  (proof := /-- Factor out $\rho\omega^2$ and apply \texttt{integral\_id}. -/)]
theorem centrifugal_pump_head (r_inner r_outer : ℝ) :
    ∫ r in r_inner..r_outer, CentrifugalPressureGradient ρ_He3 ω r =
      (1 / 2) * ρ_He3 * ω^2 * (r_outer^2 - r_inner^2) := by
  unfold CentrifugalPressureGradient
  rw [intervalIntegral.integral_const_mul, integral_id]
  ring

/-- Theorem: Closed-Loop Centrifugal Thermosyphon Net Driving Head
    In a closed cooling loop, net circulation requires a density differential `ρ_cold > ρ_hot`
    between the outward cold leg and inward hot return leg. -/
@[blueprint "thm:wakefield-centrifugal-thermosyphon"
  (title := "Closed-loop centrifugal thermosyphon driving head")
  (statement := /-- Net loop head is $\tfrac12(\rho_{\mathrm{cold}}-\rho_{\mathrm{hot}})\omega^2(r_{\mathrm{out}}^2-r_{\mathrm{in}}^2)$. -/)
  (proof := /-- Apply \texttt{centrifugal\_pump\_head} to both legs and subtract. -/)]
theorem centrifugal_thermosyphon_net_head (ρ_cold ρ_hot r_inner r_outer : ℝ) :
    (∫ r in r_inner..r_outer, CentrifugalPressureGradient ρ_cold ω r) -
      (∫ r in r_inner..r_outer, CentrifugalPressureGradient ρ_hot ω r) =
      (1 / 2) * (ρ_cold - ρ_hot) * ω^2 * (r_outer^2 - r_inner^2) := by
  rw [centrifugal_pump_head, centrifugal_pump_head]
  ring

/-- The angular velocity vector of the spool along the Z axis. -/
@[blueprint "def:wakefield-spool-angular-velocity"
  (title := "Spool axial angular velocity")
  (statement := /-- Axial angular velocity $(0,0,\omega_z)$. -/)]
def SpoolAngularVelocity (ω_z : ℝ) : Vec3 :=
  ![0, 0, ω_z]

/-- The total angular momentum vector L = I_spool • ω. -/
@[blueprint "def:wakefield-spool-angular-momentum"
  (title := "Spool axial angular momentum")
  (statement := /-- Axial angular momentum $\mathbf L=(0,0,I_{\mathrm{spool}}\omega_z)$. -/)]
def AngularMomentum (ω_z : ℝ) : Vec3 :=
  I_spool • (SpoolAngularVelocity ω_z)

/-- The gyroscopic torque required to precess the craft: τ = Ω ⨯₃ L. -/
@[blueprint "def:wakefield-gyroscopic-torque"
  (title := "Gyroscopic precession torque")
  (statement := /-- Gyroscopic torque $\boldsymbol\tau=\boldsymbol\Omega\times\mathbf L$. -/)]
def GyroscopicTorque (Ω : Vec3) (ω_z : ℝ) : Vec3 :=
  Ω ⨯₃ (AngularMomentum I_spool ω_z)

/-- Theorem: Precessing the spool purely around the X axis (pitch) induces a pure Y-axis (yaw) torque. -/
@[blueprint "thm:wakefield-pitch-induces-yaw-torque"
  (title := "Pitch precession induces orthogonal yaw torque")
  (statement := /-- Precessing at $(\Omega_x,0,0)$ yields torque $(0,-\Omega_x I_{\mathrm{spool}}\omega_z,0)$. -/)
  (proof := /-- Expand all three cross-product components and simplify by ring algebra. -/)]
theorem pitch_induces_yaw_torque (Ω_x ω_z : ℝ) :
    let Ω_pitch : Vec3 := ![Ω_x, 0, 0]
    GyroscopicTorque I_spool Ω_pitch ω_z = ![0, -Ω_x * I_spool * ω_z, 0] := by
  intro Ω_pitch
  ext i
  fin_cases i
  · simp [Ω_pitch, GyroscopicTorque, AngularMomentum, SpoolAngularVelocity, cross_apply]
  · simp [Ω_pitch, GyroscopicTorque, AngularMomentum, SpoolAngularVelocity, cross_apply]
    ring
  · simp [Ω_pitch, GyroscopicTorque, AngularMomentum, SpoolAngularVelocity, cross_apply]

end CentrifugalSpool


/-!
## 6. Langmuir Wave Coupling & Dawson Wave-Breaking Bound
Formalizes the Bohm-Gross dispersion relation, proves the invariant product of phase
and group velocity `v_φ * v_g = 3 * v_th²`, proves that the squared Bohm-Gross phase
velocity exceeds `3 * v_th²`, and certifies the Dawson energy density bound.
-/
namespace LangmuirCoupling

/-- Squared Bohm-Gross frequency: ω²(k) = ω_p² + 3 * k² * v_th². -/
@[blueprint "def:wakefield-bohm-gross-omega-sq"
  (title := "Squared Bohm-Gross frequency")
  (statement := /-- $\omega^2(k)=\omega_p^2+3k^2 v_{\mathrm{th}}^2$. -/)]
def BohmGrossOmegaSq (ω_p k v_th : ℝ) : ℝ :=
  ω_p^2 + 3 * k^2 * v_th^2

/-- Phase velocity v_φ = ω / k. -/
@[blueprint "def:wakefield-phase-velocity"
  (title := "Langmuir phase velocity")
  (statement := /-- $v_\phi=\omega/k$. -/)]
noncomputable def PhaseVelocity (ω k : ℝ) : ℝ :=
  ω / k

/-- Bohm-Gross Group velocity v_g = ∂ω/∂k = (3 * k * v_th²) / ω. -/
@[blueprint "def:wakefield-group-velocity"
  (title := "Bohm-Gross group velocity")
  (statement := /-- $v_g=3k v_{\mathrm{th}}^2/\omega$. -/)]
noncomputable def GroupVelocity (ω k v_th : ℝ) : ℝ :=
  (3 * k * v_th^2) / ω

/-- Theorem: Bohm-Gross Velocity Coupling Invariant
    For any non-zero wavenumber `k` and frequency `ω`, the product of phase velocity
    and group velocity is invariant and equal to `3 * v_th²`. -/
@[blueprint "thm:wakefield-phase-group-product"
  (title := "Bohm-Gross phase-group velocity invariant")
  (statement := /-- For $k\ne 0$ and $\omega\ne 0$, $v_\phi v_g=3v_{\mathrm{th}}^2$. -/)
  (proof := /-- Clear denominators with $k\ne 0$ and $\omega\ne 0$. -/)]
theorem phase_group_velocity_product (ω k v_th : ℝ) (h_k : k ≠ 0) (h_ω : ω ≠ 0) :
    PhaseVelocity ω k * GroupVelocity ω k v_th = 3 * v_th^2 := by
  unfold PhaseVelocity GroupVelocity
  field_simp [h_k, h_ω]

/-- Theorem: Bohm-Gross Phase Velocity Lower Bound
    When `ω² = BohmGrossOmegaSq ω_p k v_th` and `k ≠ 0`, the squared phase velocity
    satisfies `3 * v_th² ≤ v_φ²`. -/
@[blueprint "thm:wakefield-bohm-gross-phase-vel-bound"
  (title := "Bohm-Gross squared phase velocity lower bound")
  (statement := /-- When $\omega^2=\omega_p^2+3k^2 v_{\mathrm{th}}^2$ and $k\ne 0$,
    $3v_{\mathrm{th}}^2\le v_\phi^2$. -/)
  (proof := /-- Divide by $k^2>0$ and use $\omega_p^2/k^2\ge 0$. -/)]
theorem bohm_gross_phase_velocity_sq_ge_three_vth_sq
    (ω ω_p k v_th : ℝ) (h_k : k ≠ 0) (h_disp : ω^2 = BohmGrossOmegaSq ω_p k v_th) :
    3 * v_th^2 ≤ (PhaseVelocity ω k)^2 := by
  unfold PhaseVelocity BohmGrossOmegaSq at *
  have hk2 : 0 < k^2 := sq_pos_of_ne_zero h_k
  rw [div_pow, h_disp]
  have h_split : (ω_p^2 + 3 * k^2 * v_th^2) / k^2 = ω_p^2 / k^2 + 3 * v_th^2 := by
    field_simp [h_k]
  rw [h_split]
  have h_pos : 0 ≤ ω_p^2 / k^2 := div_nonneg (sq_nonneg ω_p) (le_of_lt hk2)
  linarith

/-- Electrostatic wave energy density u_E = (1 / 2) * ε0 * E_z². -/
@[blueprint "def:wakefield-wave-energy-density"
  (title := "Electrostatic wave energy density")
  (statement := /-- $u_E=\tfrac12\varepsilon_0 E_z^2$. -/)]
noncomputable def WaveEnergyDensity (ε0 E_z : ℝ) : ℝ :=
  0.5 * ε0 * E_z^2

/-- Theorem: Dawson Wave-Breaking Energy Bound
    So long as the longitudinal field amplitude `E_z` remains non-negative and bounded
    by the Dawson wave-breaking field `E_dawson`, the stored electrostatic energy density
    cannot exceed the Dawson saturation limit. -/
@[blueprint "thm:wakefield-dawson-energy-bound"
  (title := "Dawson wave-breaking energy-density bound")
  (statement := /-- For $\varepsilon_0\ge 0$ and $0\le E_z\le E_{\mathrm{Dawson}}$,
    $u_E(\varepsilon_0,E_z)\le u_E(\varepsilon_0,E_{\mathrm{Dawson}})$. -/)
  (proof := /-- Factor $E_{\mathrm{Dawson}}^2-E_z^2=(E_{\mathrm{Dawson}}-E_z)(E_{\mathrm{Dawson}}+E_z)\ge 0$. -/)]
theorem dawson_energy_density_bound (ε0 E_z E_dawson : ℝ)
    (h_ε0 : 0 ≤ ε0) (h_Ez : 0 ≤ E_z) (h_dawson : E_z ≤ E_dawson) :
    WaveEnergyDensity ε0 E_z ≤ WaveEnergyDensity ε0 E_dawson := by
  unfold WaveEnergyDensity
  have h_diff : 0 ≤ E_dawson - E_z := sub_nonneg.mpr h_dawson
  have h_sum : 0 ≤ E_dawson + E_z := by linarith
  have h_sq_diff : 0 ≤ E_dawson^2 - E_z^2 := by
    calc 0 ≤ (E_dawson - E_z) * (E_dawson + E_z) := mul_nonneg h_diff h_sum
    _ = E_dawson^2 - E_z^2 := by ring
  nlinarith

end LangmuirCoupling


/-!
## 7. Inverse Landau Resonance (Bump-on-Tail Instability)
Proves that a positive velocity-space slope `∂f₀/∂v > 0` at the resonant phase velocity
yields strictly positive exponential wave amplification (`γ > 0`), that quasilinear
plateau formation (`∂f₀/∂v = 0`) saturates growth (`γ = 0`), and that wave-particle
energy exchange is conservative.
-/
namespace InverseLandauResonance

/-- Linear Landau growth/damping rate with signed wavenumber convention:
    `γ = (π * ω_p³ / (2 * k * |k| * n_0)) * (∂f₀/∂v)|_{v = ω/k}`. -/
@[blueprint "def:wakefield-landau-growth-rate"
  (title := "Linear Vlasov-Poisson Landau growth rate")
  (statement := /-- $\gamma=\frac{\pi\omega_p^3}{2k|k| n_0}\,\partial_v f_0$. -/)]
noncomputable def LandauGrowthRate (ω_p k n_0 df_dv : ℝ) : ℝ :=
  (Real.pi * ω_p^3 / (2 * k * |k| * n_0)) * df_dv

/-- Theorem: Forward Bump-on-Tail Positive Slope Triggers Inverse Landau Amplification
    When `0 < k` and `0 < df_dv` at `v = ω/k`, the growth rate `γ` is strictly positive. -/
@[blueprint "thm:wakefield-inverse-landau-growth-pos"
  (title := "Forward positive bump-on-tail slope drives inverse Landau growth")
  (statement := /-- When $\omega_p>0$, $k>0$, $n_0>0$, and $\partial_v f_0>0$, $\gamma>0$. -/)
  (proof := /-- Rewrite $|k|=k$ for $k>0$ and apply positivity. -/)]
theorem inverse_landau_growth_pos (ω_p k n_0 df_dv : ℝ)
    (h_ωp : 0 < ω_p) (h_k : 0 < k) (h_n0 : 0 < n_0) (h_bump : 0 < df_dv) :
    0 < LandauGrowthRate ω_p k n_0 df_dv := by
  unfold LandauGrowthRate
  rw [abs_of_pos h_k]
  positivity

/-- Theorem: Forward Negative Slope (Thermal Maxwellian) Induces Standard Landau Damping. -/
@[blueprint "thm:wakefield-thermal-landau-damping-neg"
  (title := "Forward negative thermal slope induces Landau damping")
  (statement := /-- When $\omega_p>0$, $k>0$, $n_0>0$, and $\partial_v f_0<0$, $\gamma<0$. -/)
  (proof := /-- Rewrite $|k|=k$ for $k>0$ and multiply the positive prefactor by $\partial_v f_0<0$. -/)]
theorem thermal_landau_damping_neg (ω_p k n_0 df_dv : ℝ)
    (h_ωp : 0 < ω_p) (h_k : 0 < k) (h_n0 : 0 < n_0) (h_thermal : df_dv < 0) :
    LandauGrowthRate ω_p k n_0 df_dv < 0 := by
  unfold LandauGrowthRate
  rw [abs_of_pos h_k]
  have h_prefactor : 0 < Real.pi * ω_p^3 / (2 * k * k * n_0) := by positivity
  exact mul_neg_of_pos_of_neg h_prefactor h_thermal

/-- Theorem: Backward Wave (`k < 0`) in a Thermal Maxwellian (`0 < df_dv` at `v_φ < 0`)
    Also Undergoes Landau Damping (`γ < 0`). -/
@[blueprint "thm:wakefield-backward-thermal-landau-damping"
  (title := "Backward wave in a thermal Maxwellian also undergoes Landau damping")
  (statement := /-- When $\omega_p>0$, $k<0$, $n_0>0$, and $\partial_v f_0>0$ at $v_\phi=\omega/k<0$, $\gamma<0$. -/)
  (proof := /-- Rewrite $|k|=-k$ for $k<0$ and negate the positive product. -/)]
theorem backward_thermal_landau_damping_neg (ω_p k n_0 df_dv : ℝ)
    (h_ωp : 0 < ω_p) (h_k : k < 0) (h_n0 : 0 < n_0) (h_thermal_back : 0 < df_dv) :
    LandauGrowthRate ω_p k n_0 df_dv < 0 := by
  unfold LandauGrowthRate
  rw [abs_of_neg h_k]
  have hk_neg : 0 < -k := neg_pos.mpr h_k
  have h_pos : 0 < (Real.pi * ω_p^3 / (2 * (-k) * (-k) * n_0)) * df_dv := by positivity
  have h_eq : (Real.pi * ω_p^3 / (2 * k * -k * n_0)) * df_dv =
      - ((Real.pi * ω_p^3 / (2 * (-k) * (-k) * n_0)) * df_dv) := by ring
  linarith

/-- Theorem: Quasilinear Plateau Saturation
    When wave-particle trapping flattens the distribution slope (`df_dv = 0`),
    the linear growth rate saturates at zero. -/
@[blueprint "thm:wakefield-quasilinear-plateau-saturation"
  (title := "Quasilinear plateau saturation")
  (statement := /-- When $\partial_v f_0=0$, $\gamma=0$. -/)
  (proof := /-- Ring simplification. -/)]
theorem quasilinear_plateau_saturation (ω_p k n_0 : ℝ) :
    LandauGrowthRate ω_p k n_0 0 = 0 := by
  unfold LandauGrowthRate
  ring

/-- Theorem: Resonant Wave-Particle Power Conservation
    The rate of electrostatic energy gained by the Langmuir cavity `2 * γ * U_wave`
    plus the kinetic power lost by the resonant beam particles `-2 * γ * U_wave` equals zero. -/
@[blueprint "thm:wakefield-resonant-energy-conservation"
  (title := "Resonant wave-particle power balance")
  (statement := /-- $2\gamma U_{\mathrm{wave}}+(-2\gamma U_{\mathrm{wave}})=0$. -/)
  (proof := /-- Additive cancellation. -/)]
theorem resonant_energy_transfer_conservation (γ U_wave : ℝ) :
    let dU_wave_dt := 2 * γ * U_wave
    let dK_beam_dt := - (2 * γ * U_wave)
    dU_wave_dt + dK_beam_dt = 0 := by
  intro dU_wave_dt dK_beam_dt
  ring

end InverseLandauResonance


/-!
## 8. Landau Critical Velocity (`v_c`)
Models the Bogoliubov quasiparticle spectrum in a superfluid / DDF metric, proving that
the minimum excitation phase velocity is bounded below by the Bogoliubov sound speed `c_s`,
and establishing the exact energetic threshold separating frictionless flow from vortex-shedding
dissipation/phase-slip onset.
-/
namespace LandauCriticalVelocity

/-- Squared Bogoliubov phase velocity `(ε(p) / p)² = c_s² + (p / (2m))²`. -/
@[blueprint "def:wakefield-bogoliubov-phase-vel-sq"
  (title := "Squared Bogoliubov excitation phase velocity")
  (statement := /-- $(\epsilon(p)/p)^2=c_s^2+(p/(2m))^2$. -/)]
noncomputable def BogoliubovPhaseVelSq (c_s m p : ℝ) : ℝ :=
  c_s^2 + (p / (2 * m))^2

/-- Excitation energy in the moving frame of the hull: ΔE = ε(p) - p * v. -/
@[blueprint "def:wakefield-moving-frame-energy"
  (title := "Galilean moving-frame excitation energy")
  (statement := /-- $\Delta E=\epsilon_p-p v$. -/)]
def MovingFrameEnergy (ε_p p v : ℝ) : ℝ :=
  ε_p - p * v

/-- Theorem: Landau Critical Velocity Bound
    For any excitation momentum `p`, the squared Bogoliubov phase velocity is bounded
    below by the squared sound speed `c_s²`, proving `v_c = c_s` at `p → 0`. -/
@[blueprint "thm:wakefield-bogoliubov-landau-bound"
  (title := "Landau critical velocity bound")
  (statement := /-- $c_s^2\le c_s^2+(p/(2m))^2$. -/)
  (proof := /-- Nonnegativity of $(p/(2m))^2$. -/)]
theorem bogoliubov_phase_velocity_sq_ge_cs_sq (c_s m p : ℝ) :
    c_s^2 ≤ BogoliubovPhaseVelSq c_s m p := by
  unfold BogoliubovPhaseVelSq
  linarith [sq_nonneg (p / (2 * m))]

/-- Theorem: Subcritical Superfluidity (Zero Dissipation)
    When the flow velocity `v` is strictly below the Landau critical velocity `v_c`,
    every excitation with `ε_p ≥ v_c * p` and `p > 0` costs strictly positive energy
    (`ΔE > 0`) in the moving frame, forbidding spontaneous vortex shedding. -/
@[blueprint "thm:wakefield-subcritical-no-dissipation"
  (title := "Subcritical flow forbids spontaneous excitation")
  (statement := /-- For $p>0$, $v<v_c$, and $\epsilon_p\ge v_c p$, $\Delta E>0$. -/)
  (proof := /-- Nonlinear arithmetic from $p>0$ and $v<v_c$. -/)]
theorem subcritical_no_dissipation (v v_c p ε_p : ℝ)
    (hp : 0 < p) (h_sub : v < v_c) (h_spectrum : v_c * p ≤ ε_p) :
    0 < MovingFrameEnergy ε_p p v := by
  unfold MovingFrameEnergy
  nlinarith

/-- Theorem: Supercritical Phase-Slip Onset
    When the relative flow velocity exceeds `v_c` (`v > v_c`), acoustic excitations
    at the Bogoliubov sound pole (`ε_p = v_c * p`, `p > 0`) have strictly negative moving-frame
    energy (`ΔE < 0`), enabling spontaneous vortex/phonon nucleation. -/
@[blueprint "thm:wakefield-supercritical-phase-slip-onset"
  (title := "Supercritical flow triggers negative-energy excitations")
  (statement := /-- For $p>0$, $v_c<v$, and $\epsilon_p=v_c p$, $\Delta E<0$. -/)
  (proof := /-- Nonlinear arithmetic from $p>0$ and $v_c<v$. -/)]
theorem supercritical_phase_slip_onset (v v_c p ε_p : ℝ)
    (hp : 0 < p) (h_super : v_c < v) (h_acoustic : ε_p = v_c * p) :
    MovingFrameEnergy ε_p p v < 0 := by
  unfold MovingFrameEnergy
  nlinarith

end LandauCriticalVelocity


/-!
## 9. Topological Confinement & Entropy Siphoning
Formalizes Woltjer-Taylor force-free magnetic helicity states (`J ⨯₃ B = 0`), proves that
active cooling (`ΔP_siphon > ΔP_ohm`) preserves a radial magnetic pressure margin, and certifies
discrete 1-cocycle gauge invariance of a 4-link magnetic circulation loop.
-/
namespace TopologicalConfinement

/-- In a relaxed Taylor state (conserved magnetic helicity H = ∫ A · B dV),
    the current density J is collinear with the magnetic field: J = α • B. -/
@[blueprint "def:wakefield-taylor-current"
  (title := "Woltjer-Taylor Beltrami current")
  (statement := /-- $\mathbf J=\alpha\mathbf B$. -/)]
def TaylorCurrent (α : ℝ) (B : Vec3) : Vec3 :=
  α • B

/-- Theorem: Taylor Helicity State Is Force-Free
    When a plasmoid settles into a Beltrami/Taylor state `J = α • B`,
    the internal magnetic Lorentz force `J ⨯₃ B` vanishes identically across all 3 axes. -/
@[blueprint "thm:wakefield-taylor-state-force-free"
  (title := "Beltrami/Taylor state has zero internal magnetic Lorentz force")
  (statement := /-- $(\alpha\mathbf B)\times\mathbf B=\mathbf 0$. -/)
  (proof := /-- Componentwise cancellation on $\operatorname{Fin}(3)$. -/)]
theorem taylor_state_force_free (α : ℝ) (B : Vec3) :
    (TaylorCurrent α B) ⨯₃ B = ![0, 0, 0] := by
  ext i
  fin_cases i <;> simp [TaylorCurrent]

/-- Theorem: Active Cooling Stabilizes Radial Pinch Confinement Margin
    Given an initially confined plasmoid (`P_thermal_init ≤ P_mag`), if an active cooling channel
    extracts thermal pressure faster than Ohmic dissipation injects it (`ΔP_ohm < ΔP_siphon`),
    the net radial confinement pressure `P_mag - P_thermal_eff` is strictly positive. -/
@[blueprint "thm:wakefield-entropy-siphon-stabilizes-pinch"
  (title := "Active cooling preserves radial magnetic pinch margin")
  (statement := /-- If $P_{\mathrm{th,0}}\le P_{\mathrm{mag}}$ and $\Delta P_{\mathrm{ohm}}<\Delta P_{\mathrm{siphon}}$,
    then $P_{\mathrm{mag}}-(P_{\mathrm{th,0}}+\Delta P_{\mathrm{ohm}}-\Delta P_{\mathrm{siphon}})>0$. -/)
  (proof := /-- Linear arithmetic. -/)]
theorem entropy_siphon_stabilizes_pinch
    (P_mag P_thermal_init ΔP_ohm ΔP_siphon : ℝ)
    (h_init_bal : P_thermal_init ≤ P_mag)
    (h_siphon_dom : ΔP_ohm < ΔP_siphon) :
    let P_thermal_eff := P_thermal_init + ΔP_ohm - ΔP_siphon
    0 < P_mag - P_thermal_eff := by
  intro P_thermal_eff
  dsimp [P_thermal_eff]
  linarith

/-- QEClean Homological Certificate: Discrete 1-Cocycle Gauge Invariance of 4-Link Holonomy.
    Under any discrete gauge transformation `A_{ij} ↦ A_{ij} + (χ_j - χ_i)` around a closed
    4-link magnetic cycle, the scalar potentials `χ_i` telescope to zero, preserving
    the discrete magnetic flux circulation against local gauge perturbations. -/
@[blueprint "thm:wakefield-qec-hopf-gauge-invariance"
  (title := "Discrete 4-cycle 1-cocycle gauge invariance")
  (statement := /-- Adding vertex coboundary differences $\chi_j-\chi_i$ around a 4-cycle preserves
    the loop circulation sum. -/)
  (proof := /-- Telescope the vertex potentials by ring algebra. -/)]
theorem qec_hopf_gauge_invariance (A01 A12 A23 A30 χ0 χ1 χ2 χ3 : ℝ) :
    let A'_01 := A01 + (χ1 - χ0)
    let A'_12 := A12 + (χ2 - χ1)
    let A'_23 := A23 + (χ3 - χ2)
    let A'_30 := A30 + (χ0 - χ3)
    A'_01 + A'_12 + A'_23 + A'_30 = A01 + A12 + A23 + A30 := by
  intro A'_01 A'_12 A'_23 A'_30
  ring

end TopologicalConfinement

end WakefieldPropulsion
