import Architect
import Mathlib.Analysis.Complex.Basic
import Mathlib.Analysis.SpecialFunctions.Complex.Arg
import Mathlib.Analysis.SpecialFunctions.Integrals.Basic
import Mathlib.Analysis.SpecialFunctions.Pow.Real
import Mathlib.Analysis.Real.Sqrt
import Mathlib.Basic.Real.Basic
import Mathlib.MeasureTheory.Integral.IntervalIntegral.Basic
import Mathlib.Tactic

namespace Signals.DDF

open MeasureTheory Interval Complex

/-! # Dilatant Dark Fluid (DDF) Quantum-Hydrodynamic Model

This module formalizes the core mathematical framework of the Dilatant Dark Fluid
(DDF) proposed by Marco Fedi (2026), *Dilatant Dark Fluid: Toward a Unified
Quantum-Hydrodynamic Origin of Lorentz Invariance, Gravity, and Cosmological
Phenomenology* (SSRN Preprint 7406660).

The framework models spacetime and gravitation as emergent phenomena of a
two-component quantum-hydrodynamic substrate:
1. `Continuous Superfluid Phase (ϕ)`: A coherent BEC supporting quantized vortices
   (matter particles) and circulatory Bernoulli pressure/enthalpy deficits (gravity).
2. `Dispersed Dilatant Phase (φ)`: A heavier dispersed phase exhibiting
   shear-thickening and shear-jamming. In the saturated state, it supports transverse
   phonons propagating at speed `c` (identified with photons).
3. `Constitutive Lorentz Factor`: Moving bodies experience longitudinal sheath
   compression `Λ_∥(v) = γ_φ(v) = 1/√(1 - v²/c²)`, yielding relativistic kinetic energy,
   clock dilation, and the operational Minkowski interval.
4. `Painlevé-Gullstrand River Geometry`: Inflow superflow `v_r = -√(2GM/r)` encodes
   Schwarzschild exterior geometry with acoustic horizon at `r_H = 2GM/c²`, and dipolar
   swirl encodes Kerr-Lense-Thirring dragging.
5. `Galactic Isothermal Regime`: Superfluid isothermal barotrope yields flat rotation
   curves `v_flat = √(q_ρ) * c_ϕ` without dark matter halos.
6. `Decisive Discriminator`: Radiation active gravitational sourcing parameter
   `η_act^γ = 0` in DDF versus `1` in GR.
-/

/-- The two-component Dilatant Dark Fluid substrate parameters. -/
structure DDFSubstrate where
  m_phi : ℝ
  m_phi_pos : 0 < m_phi
  m_varphi : ℝ
  m_varphi_pos : 0 < m_varphi
  rho_phi_0 : ℝ
  rho_phi_0_pos : 0 < rho_phi_0
  rho_max_varphi : ℝ
  rho_max_varphi_pos : 0 < rho_max_varphi
  j_min_varphi : ℝ
  j_min_varphi_pos : 0 < j_min_varphi

/-- The transverse phonon propagation speed (emergent speed of light).
    c = 1 / √(ϱ_max^φ * j_min^φ). -/
noncomputable def DDFSubstrate.c (sub : DDFSubstrate) : ℝ :=
  (Real.sqrt (sub.rho_max_varphi * sub.j_min_varphi))⁻¹

/-- The emergent speed of light is strictly positive. -/
lemma DDFSubstrate.c_pos (sub : DDFSubstrate) : 0 < sub.c := by
  dsimp [DDFSubstrate.c]
  apply inv_pos.mpr
  apply Real.sqrt_pos.mpr
  exact mul_pos sub.rho_max_varphi_pos sub.j_min_varphi_pos

/-- Saturated product ϱ_max^φ * j_min^φ is positive. -/
lemma DDFSubstrate.product_pos (sub : DDFSubstrate) :
    0 < sub.rho_max_varphi * sub.j_min_varphi :=
  mul_pos sub.rho_max_varphi_pos sub.j_min_varphi_pos

/-- The squared speed of light matches (ϱ_max * j_min)⁻¹. -/
lemma DDFSubstrate.c_sq (sub : DDFSubstrate) :
    sub.c ^ 2 = (sub.rho_max_varphi * sub.j_min_varphi)⁻¹ := by
  dsimp [DDFSubstrate.c]
  have h_pos := sub.product_pos
  have h_sqrt_pos := Real.sqrt_pos.mpr h_pos
  rw [inv_pow, Real.sq_sqrt (le_of_lt h_pos)]

/-- Quantized circulation quantum of the ϕ superfluid: κ_ϕ = 2πℏ / m_ϕ. -/
noncomputable def DDFSubstrate.circulationQuantum (sub : DDFSubstrate) (hbar : ℝ) : ℝ :=
  2 * Real.pi * hbar / sub.m_phi

/-! ## Moving Sheath and Jamming-Based Lorentz Kinematics -/

/-- A massive configuration translating through the dispersed φ background
    at a subluminal relative speed. -/
structure MovingSheath (sub : DDFSubstrate) where
  velocity : ℝ
  velocity_nonneg : 0 ≤ velocity
  subluminal : velocity < sub.c

/-- The speed ratio squared β² = (v / c)². -/
noncomputable def MovingSheath.betaSq {sub : DDFSubstrate} (s : MovingSheath sub) : ℝ :=
  s.velocity ^ 2 / sub.c ^ 2

/-- The factor 1 - v²/c² is strictly positive for subluminal motion. -/
lemma MovingSheath.one_sub_betaSq_pos {sub : DDFSubstrate} (s : MovingSheath sub) :
    0 < 1 - s.betaSq := by
  dsimp [MovingSheath.betaSq]
  have hc := sub.c_pos
  have h_v := s.velocity_nonneg
  have h_sub := s.subluminal
  have h1 : s.velocity ^ 2 < sub.c ^ 2 := by
    nlinarith [h_v, h_sub, hc]
  have h2 : s.velocity ^ 2 / sub.c ^ 2 < 1 := by
    exact (div_lt_one (by nlinarith [hc])).mpr h1
  linarith

/-- The speed-dependent constitutive jamming factor γ_φ(v) = 1 / √(1 - v²/c²). -/
noncomputable def MovingSheath.jammingFactor {sub : DDFSubstrate} (s : MovingSheath sub) : ℝ :=
  1 / Real.sqrt (1 - s.betaSq)

/-- The jamming factor is strictly positive. -/
lemma MovingSheath.jammingFactor_pos {sub : DDFSubstrate} (s : MovingSheath sub) :
    0 < s.jammingFactor := by
  dsimp [MovingSheath.jammingFactor]
  apply div_pos (by norm_num)
  exact Real.sqrt_pos.mpr s.one_sub_betaSq_pos

/-- Profile closure theorem: The longitudinal compression scale factor Λ_∥(v)
    satisfying Λ_∥² * (1 - v²/c²) = 1 is uniquely the jamming factor γ_φ(v). -/
theorem profile_closure_jamming_factor {sub : DDFSubstrate} (s : MovingSheath sub)
    (Lambda : ℝ) (h_Lambda_pos : 0 < Lambda)
    (h_closure : Lambda ^ 2 * (1 - s.betaSq) = 1) :
    Lambda = s.jammingFactor := by
  have h_pos := s.one_sub_betaSq_pos
  have h_sqrt_pos := Real.sqrt_pos.mpr h_pos
  have h_div : Lambda ^ 2 = 1 / (1 - s.betaSq) := by
    exact eq_one_div_of_mul_eq_one_left h_closure
  have h_jam_sq : s.jammingFactor ^ 2 = 1 / (1 - s.betaSq) := by
    dsimp [MovingSheath.jammingFactor]
    rw [div_pow, one_pow, Real.sq_sqrt (le_of_lt h_pos)]
  have h_sq_eq : Lambda ^ 2 = s.jammingFactor ^ 2 := by
    rw [h_div, h_jam_sq]
  have h_jam_pos := s.jammingFactor_pos
  nlinarith [h_Lambda_pos, h_jam_pos, h_sq_eq]

/-- Reversible kinetic energy stored in the shear-thickened and compressed sheath:
    K_D(v) = mc²(γ_φ(v) - 1). -/
noncomputable def MovingSheath.kineticEnergy {sub : DDFSubstrate}
    (s : MovingSheath sub) (restMass : ℝ) : ℝ :=
  restMass * sub.c ^ 2 * (s.jammingFactor - 1)

/-- Total material energy E_φ(v) = mc² + K_D(v) = γ_φ(v)mc². -/
theorem MovingSheath.total_energy_eq {sub : DDFSubstrate}
    (s : MovingSheath sub) (restMass : ℝ) :
    restMass * sub.c ^ 2 + s.kineticEnergy restMass =
      s.jammingFactor * restMass * sub.c ^ 2 := by
  dsimp [MovingSheath.kineticEnergy]
  ring

/-- Derivation of the operational Minkowski metric interval:
    From action-derived clock proper time dτ_D = dt / γ_φ(v),
    the invariant interval satisfies c² dτ_D² = c² dt² - (v dt)². -/
theorem material_minkowski_interval {sub : DDFSubstrate} (s : MovingSheath sub)
    (dt : ℝ) (dtau : ℝ) (h_dtau : dtau = dt / s.jammingFactor) :
    sub.c ^ 2 * dtau ^ 2 = sub.c ^ 2 * dt ^ 2 - (s.velocity * dt) ^ 2 := by
  have h_pos := s.one_sub_betaSq_pos
  have h_jam_sq : s.jammingFactor ^ 2 = 1 / (1 - s.betaSq) := by
    dsimp [MovingSheath.jammingFactor]
    rw [div_pow, one_pow, Real.sq_sqrt (le_of_lt h_pos)]
  have h_c_pos := sub.c_pos
  have h_c_sq_pos : 0 < sub.c ^ 2 := by nlinarith [h_c_pos]
  have h_jam_pos := s.jammingFactor_pos
  have h_dtau_sq : dtau ^ 2 = dt ^ 2 * (1 - s.betaSq) := by
    rw [h_dtau, div_pow]
    have h_inv : (s.jammingFactor ^ 2)⁻¹ = 1 - s.betaSq := by
      rw [h_jam_sq, inv_div, div_one]
    calc
      dt ^ 2 / s.jammingFactor ^ 2 = dt ^ 2 * (s.jammingFactor ^ 2)⁻¹ := by ring
      _ = dt ^ 2 * (1 - s.betaSq) := by rw [h_inv]
  dsimp [MovingSheath.betaSq] at h_dtau_sq
  calc
    sub.c ^ 2 * dtau ^ 2 = sub.c ^ 2 * (dt ^ 2 * (1 - s.velocity ^ 2 / sub.c ^ 2)) := by
      rw [h_dtau_sq]
    _ = sub.c ^ 2 * dt ^ 2 - (s.velocity * dt) ^ 2 := by
      have h_cancel : sub.c ^ 2 * (dt ^ 2 * (s.velocity ^ 2 / sub.c ^ 2)) = (s.velocity * dt) ^ 2 := by
        calc
          sub.c ^ 2 * (dt ^ 2 * (s.velocity ^ 2 / sub.c ^ 2))
            = (sub.c ^ 2 / sub.c ^ 2) * (dt ^ 2 * s.velocity ^ 2) := by ring
          _ = 1 * (dt ^ 2 * s.velocity ^ 2) := by
            rw [div_self (ne_of_gt h_c_sq_pos)]
          _ = (s.velocity * dt) ^ 2 := by ring
      calc
        sub.c ^ 2 * (dt ^ 2 * (1 - s.velocity ^ 2 / sub.c ^ 2))
          = sub.c ^ 2 * dt ^ 2 - sub.c ^ 2 * (dt ^ 2 * (s.velocity ^ 2 / sub.c ^ 2)) := by ring
        _ = sub.c ^ 2 * dt ^ 2 - (s.velocity * dt) ^ 2 := by rw [h_cancel]

/-! ## Superfluid Bernoulli Gravity & Painlevé-Gullstrand River Geometry -/

/-- A stationary, spherically symmetric exterior river flow generated by
    the coarse-grained persistent quantized-vortex population of mass M. -/
structure RiverExterior (sub : DDFSubstrate) where
  G_phi : ℝ
  G_phi_pos : 0 < G_phi
  sourceMass : ℝ
  sourceMass_pos : 0 < sourceMass

/-- Radial river superflow velocity: v_ϕ(r) = -√(2 G_ϕ M / r). -/
noncomputable def RiverExterior.velocity {sub : DDFSubstrate}
    (re : RiverExterior sub) (r : ℝ) : ℝ :=
  - Real.sqrt (2 * re.G_phi * re.sourceMass / r)

/-- Bernoulli enthalpy potential: Φ_ϕ = - |v_ϕ|² / 2. -/
noncomputable def RiverExterior.bernoulliPotential {sub : DDFSubstrate}
    (re : RiverExterior sub) (r : ℝ) : ℝ :=
  - ((re.velocity r) ^ 2 / 2)

/-- The Bernoulli first integral recovers the Newtonian gravitational potential:
    Φ_ϕ(r) = - G_ϕ M / r. -/
theorem RiverExterior.bernoulli_potential_eq {sub : DDFSubstrate}
    (re : RiverExterior sub) (r : ℝ) (hr : 0 < r) :
    re.bernoulliPotential r = - (re.G_phi * re.sourceMass / r) := by
  dsimp [RiverExterior.bernoulliPotential, RiverExterior.velocity]
  have h_arg_pos : 0 < 2 * re.G_phi * re.sourceMass / r := by
    apply div_pos
    · have h1 := re.G_phi_pos
      have h2 := re.sourceMass_pos
      nlinarith
    · exact hr
  have h_sq : (- Real.sqrt (2 * re.G_phi * re.sourceMass / r)) ^ 2 =
      2 * re.G_phi * re.sourceMass / r := by
    rw [neg_sq, Real.sq_sqrt (le_of_lt h_arg_pos)]
  rw [h_sq]
  ring

/-- Acoustic horizon radius where the river inflow velocity matches the transverse
    wave speed c: r_H = 2 G_ϕ M / c². -/
noncomputable def RiverExterior.horizonRadius {sub : DDFSubstrate}
    (re : RiverExterior sub) : ℝ :=
  2 * re.G_phi * re.sourceMass / sub.c ^ 2

/-- The acoustic event horizon radius is strictly positive. -/
lemma RiverExterior.horizonRadius_pos {sub : DDFSubstrate}
    (re : RiverExterior sub) : 0 < re.horizonRadius := by
  dsimp [RiverExterior.horizonRadius]
  apply div_pos
  · have h1 := re.G_phi_pos
    have h2 := re.sourceMass_pos
    nlinarith
  · have hc := sub.c_pos
    nlinarith

/-- At the acoustic horizon r = r_H, the river inflow speed equals c:
    v_ϕ(r_H) = -c. -/
theorem RiverExterior.horizon_velocity_matches_c {sub : DDFSubstrate}
    (re : RiverExterior sub) :
    re.velocity re.horizonRadius = - sub.c := by
  dsimp [RiverExterior.velocity, RiverExterior.horizonRadius]
  have h_c_pos := sub.c_pos
  have h_num_pos : 0 < 2 * re.G_phi * re.sourceMass := by
    have h1 := re.G_phi_pos
    have h2 := re.sourceMass_pos
    nlinarith
  have h_quot : (2 * re.G_phi * re.sourceMass) / (2 * re.G_phi * re.sourceMass / sub.c ^ 2) = sub.c ^ 2 := by
    rw [div_div_eq_mul_div, mul_comm, mul_div_assoc, div_self (ne_of_gt h_num_pos), mul_one]
  rw [h_quot, Real.sqrt_sq (le_of_lt h_c_pos)]

/-- Leading dipolar swirl velocity encoding the Kerr/Lense-Thirring frame dragging:
    v_ϕ,swirl(r) = (2 G_ϕ J) / (c² r²). -/
noncomputable def RiverExterior.swirlVelocity {sub : DDFSubstrate}
    (re : RiverExterior sub) (angularMomentum : ℝ) (r : ℝ) : ℝ :=
  2 * re.G_phi * angularMomentum / (sub.c ^ 2 * r ^ 2)

/-! ## Galactic Dynamics & MOND-like Isothermal Profiles -/

/-- Parameters for the isothermal regime of the ϕ superfluid in low-acceleration
    outer galactic regions (|g_ϕ| ≲ a_iso). -/
structure IsothermalGalacticRegime (sub : DDFSubstrate) where
  c_phi : ℝ
  c_phi_pos : 0 < c_phi
  q_rho : ℝ
  q_rho_pos : 0 < q_rho
  a_iso : ℝ
  a_iso_pos : 0 < a_iso

/-- Asymptotic flat galactic orbital speed: v_flat = √(q_ρ) * c_ϕ. -/
noncomputable def IsothermalGalacticRegime.v_flat {sub : DDFSubstrate}
    (reg : IsothermalGalacticRegime sub) : ℝ :=
  Real.sqrt reg.q_rho * reg.c_phi

/-- The flat rotation speed is strictly positive. -/
lemma IsothermalGalacticRegime.v_flat_pos {sub : DDFSubstrate}
    (reg : IsothermalGalacticRegime sub) : 0 < reg.v_flat := by
  dsimp [IsothermalGalacticRegime.v_flat]
  exact mul_pos (Real.sqrt_pos.mpr reg.q_rho_pos) reg.c_phi_pos

/-- For the standard isothermal sphere benchmark q_ρ = 2, the plateau velocity
    is v_flat = √2 * c_ϕ. -/
theorem isothermal_sphere_flat_velocity {sub : DDFSubstrate}
    (reg : IsothermalGalacticRegime sub) (h_sphere : reg.q_rho = 2) :
    reg.v_flat = Real.sqrt 2 * reg.c_phi := by
  dsimp [IsothermalGalacticRegime.v_flat]
  rw [h_sphere]

/-- The squared flat rotation velocity satisfies v_flat² = q_ρ * c_ϕ². -/
theorem IsothermalGalacticRegime.v_flat_sq {sub : DDFSubstrate}
    (reg : IsothermalGalacticRegime sub) :
    reg.v_flat ^ 2 = reg.q_rho * reg.c_phi ^ 2 := by
  dsimp [IsothermalGalacticRegime.v_flat]
  rw [mul_pow, Real.sq_sqrt (le_of_lt reg.q_rho_pos)]

/-! ## Experimental Discriminators: Active Photon Sourcing -/

/-- Active gravitational sourcing hypothesis parameter for freely propagating radiation:
    - `generalRelativity`: η_act^γ = 1 (radiation curves spacetime)
    - `dilatantDarkFluid`: η_act^γ = 0 (gravity is solely vortex Bernoulli pressure deficits). -/
inductive ActiveRadiationSourcing
  | generalRelativity
  | dilatantDarkFluid
  deriving DecidableEq, Repr

/-- Sourcing coupling constant η_act^γ. -/
def ActiveRadiationSourcing.eta : ActiveRadiationSourcing → ℝ
  | ActiveRadiationSourcing.generalRelativity => 1
  | ActiveRadiationSourcing.dilatantDarkFluid => 0

/-- Mutual gravitational deflection angle between two non-co-propagating laser beams
    with minimum lateral separation b and pulse/beam energy E:
    α_1←2 = η_act^γ * (K * G * E / (c⁴ * b)). -/
noncomputable def mutualPhotonDeflection (model : ActiveRadiationSourcing)
    (G c beamEnergy impactParameter kernel : ℝ) : ℝ :=
  model.eta * (kernel * G * beamEnergy / (c ^ 4 * impactParameter))

/-- DDF Discriminator Theorem: In the DDF framework, freely propagating on-shell photons
    carry zero active Bernoulli source charge (η_act^γ = 0), predicting an exact
    null mutual gravitational deflection. -/
theorem ddf_photon_deflection_null (G c beamEnergy impactParameter kernel : ℝ) :
    mutualPhotonDeflection ActiveRadiationSourcing.dilatantDarkFluid G c beamEnergy impactParameter kernel = 0 := by
  dsimp [mutualPhotonDeflection, ActiveRadiationSourcing.eta]
  ring

/-- GR comparison: General Relativity predicts a non-zero mutual gravitational deflection
    scaling as (kernel * G * E) / (c⁴ * b). -/
theorem gr_photon_deflection_active (G c beamEnergy impactParameter kernel : ℝ) :
    mutualPhotonDeflection ActiveRadiationSourcing.generalRelativity G c beamEnergy impactParameter kernel =
      kernel * G * beamEnergy / (c ^ 4 * impactParameter) := by
  dsimp [mutualPhotonDeflection, ActiveRadiationSourcing.eta]
  ring

/-! ## Madelung Quantum Hydrodynamics, Quantized Vortex Circulation, & Plaquette Holonomy

Formalizes the Madelung amplitude-phase decomposition of a complex superfluid
order parameter `ψ : (Fin 3 → ℝ) → ℂ`, the regularized Bohm quantum potential,
continuous circulation quantization around a vortex of integer winding `n : ℤ`,
and discrete 2D lattice plaquette coboundary and branch-cut syndrome identities.

Note: These theorems check the mathematical consequences of the Madelung
decomposition and circulation integral; they do not establish that a physical
spacecraft can generate propellantless thrust from vacuum phase slips.
-/

/-- Three-component real spatial coordinate vector (`Fin 3 → ℝ`). -/
@[blueprint "def:signals-ddf-vec3"
  (title := "DDF three-dimensional coordinate vector")
  (statement := /-- A spatial coordinate in the DDF substrate is represented by $\operatorname{Fin}(3)\to\mathbb R$. -/)]
abbrev DDFVec3 := Fin 3 → ℝ

/-- Madelung number/probability density `ρ(x) = |ψ(x)|²` of the complex wavefunction. -/
@[blueprint "def:signals-madelung-density"
  (title := "Madelung condensate density")
  (statement := /-- For a complex order parameter $\psi:\mathbb R^3\to\mathbb C$, the Madelung
    density is $\rho(\mathbf x)=|\psi(\mathbf x)|^2$. -/)]
noncomputable def madelungDensity (ψ : DDFVec3 → ℂ) (x : DDFVec3) : ℝ :=
  Complex.normSq (ψ x)

/-- Madelung density is everywhere nonnegative. -/
@[blueprint "lem:signals-madelung-density-nonneg"
  (title := "Nonnegativity of Madelung density")
  (statement := /-- For every point $\mathbf x$, $\rho(\mathbf x)=|\psi(\mathbf x)|^2\ge 0$. -/)
  (proof := /-- Apply \texttt{Complex.normSq\_nonneg}. -/)
  (latexEnv := "lemma")]
lemma madelungDensity_nonneg (ψ : DDFVec3 → ℂ) (x : DDFVec3) :
    0 ≤ madelungDensity ψ x :=
  Complex.normSq_nonneg (ψ x)

/-- Square-root amplitude `√ρ(x) = √(|ψ(x)|²)` of the Madelung wavefunction. -/
@[blueprint "def:signals-madelung-amplitude"
  (title := "Madelung square-root amplitude")
  (statement := /-- The real amplitude of the condensate wavefunction is
    $\sqrt{\rho(\mathbf x)}=\sqrt{|\psi(\mathbf x)|^2}$. -/)]
noncomputable def madelungAmplitude (ψ : DDFVec3 → ℂ) (x : DDFVec3) : ℝ :=
  Real.sqrt (madelungDensity ψ x)

/-- Principal quantum phase `S(x) = arg(ψ(x))`. -/
@[blueprint "def:signals-madelung-phase"
  (title := "Principal Madelung quantum phase")
  (statement := /-- The principal quantum phase of $\psi$ is $S(\mathbf x)=\arg(\psi(\mathbf x))$. -/)]
noncomputable def madelungPhase (ψ : DDFVec3 → ℂ) (x : DDFVec3) : ℝ :=
  Complex.arg (ψ x)

/-- Regularized Bohm quantum potential `Q(x) = -(ℏ² / (2 m)) * (∇²√ρ(x) / √ρ(x))`,
parameterized by the supplied spatial Laplacian `laplacian_sqrt_rho` at non-core points. -/
@[blueprint "def:signals-bohm-quantum-potential"
  (title := "Regularized Bohm quantum potential")
  (statement := /-- Outside vortex cores ($\rho(\mathbf x)>0$), given the spatial Laplacian
    $\Delta\sqrt{\rho}(\mathbf x)$, the Bohm quantum potential is
    $Q(\mathbf x)=-\frac{\hbar^2}{2m}\frac{\Delta\sqrt{\rho}(\mathbf x)}{\sqrt{\rho(\mathbf x)}}$. -/)]
noncomputable def bohmQuantumPotential
    (m_DDF hbar : ℝ) (ψ : DDFVec3 → ℂ) (laplacian_sqrt_rho : DDFVec3 → ℝ) (x : DDFVec3) : ℝ :=
  - (hbar ^ 2 / (2 * m_DDF)) * (laplacian_sqrt_rho x) / (madelungAmplitude ψ x)

/-- Superfluid velocity field `v(x) = (ℏ / m) • ∇S(x)` outside vortex cores. -/
@[blueprint "def:signals-superfluid-velocity"
  (title := "Madelung superfluid velocity field")
  (statement := /-- Given the phase gradient $\nabla S(\mathbf x)$, the superfluid velocity is
    $\mathbf v(\mathbf x)=\frac{\hbar}{m}\nabla S(\mathbf x)$. -/)]
noncomputable def superfluidVelocity
    (m_DDF hbar : ℝ) (grad_S : DDFVec3 → DDFVec3) (x : DDFVec3) : DDFVec3 :=
  (hbar / m_DDF) • (grad_S x)

/-- Azimuthal superfluid velocity `v_θ = (ℏ / m) * (n / R)` along a circular contour
of radius `R` enclosing a vortex defect of integer winding number `n : ℤ`. -/
@[blueprint "def:signals-vortex-tangential-velocity"
  (title := "Azimuthal vortex tangential velocity")
  (statement := /-- Along a circle of radius $R$ enclosing a vortex of integer winding number
    $n\in\mathbb Z$, the tangential superfluid velocity is $v_\theta=\frac{\hbar}{m}\frac{n}{R}$. -/)]
noncomputable def vortexTangentialVelocity (m_DDF hbar : ℝ) (n : ℤ) (R : ℝ) (_θ : ℝ) : ℝ :=
  (hbar / m_DDF) * ((n : ℝ) / R)

/-- Continuous circulation quantization: integrating `v_θ(θ) * R` around `θ ∈ [0, 2π]`
for any non-zero radius `R ≠ 0` yields `n * (2π ℏ / m_DDF)`. -/
@[blueprint "thm:signals-quantized-vortex-circulation"
  (title := "Quantized superfluid circulation around a phase-slip vortex")
  (statement := /-- For any $R\ne 0$ and winding number $n\in\mathbb Z$, integrating
    $v_\theta(\theta)\,R$ over $\theta\in[0,2\pi]$ yields the quantized circulation
    $n\,\frac{2\pi\hbar}{m}$. -/)
  (proof := /-- Integrate the constant azimuthal integrand over $[0,2\pi]$ and cancel $R\ne 0$. -/)]
theorem quantized_vortex_circulation (m_DDF hbar R : ℝ) (hR : R ≠ 0) (n : ℤ) :
    ∫ θ in (0 : ℝ)..(2 * Real.pi), (vortexTangentialVelocity m_DDF hbar n R θ * R) =
      (n : ℝ) * (2 * Real.pi * hbar / m_DDF) := by
  unfold vortexTangentialVelocity
  rw [intervalIntegral.integral_const]
  simp only [sub_zero, smul_eq_mul]
  field_simp [hR]

/-- For a `DDFSubstrate`, the circular contour integral around a vortex of winding `n`
equals `(n : ℝ) * sub.circulationQuantum hbar`. -/
@[blueprint "thm:signals-ddf-substrate-circulation-eq"
  (title := "DDF substrate circulation quantum match")
  (statement := /-- Around a $\phi$-condensate vortex of winding $n$, the contour circulation equals
    $n\,\kappa_\phi=n\,\frac{2\pi\hbar}{m_\phi}$. -/)
  (proof := /-- Specialize \texttt{quantized\_vortex\_circulation} to $m_\phi$. -/)]
theorem DDFSubstrate.quantized_vortex_circulation_eq
    (sub : DDFSubstrate) (hbar R : ℝ) (hR : R ≠ 0) (n : ℤ) :
    ∫ θ in (0 : ℝ)..(2 * Real.pi), (vortexTangentialVelocity sub.m_phi hbar n R θ * R) =
      (n : ℝ) * sub.circulationQuantum hbar := by
  rw [quantized_vortex_circulation sub.m_phi hbar R hR n]
  rfl

/-- Discrete 2D plaquette coboundary identity (`δ¹ ∘ δ⁰ = 0`): for single-valued
lattice site phases `S00, S10, S11, S01`, the oriented sum of link phase differences
around the closed unit plaquette vanishes identically. -/
@[blueprint "thm:signals-plaquette-coboundary-zero"
  (title := "Discrete plaquette coboundary vanishes without branch cuts")
  (statement := /-- For single-valued lattice phases $S_{00},S_{10},S_{11},S_{01}$, the oriented
    plaquette sum $(S_{10}-S_{00})+(S_{11}-S_{10})+(S_{01}-S_{11})+(S_{00}-S_{01})=0$. -/)
  (proof := /-- Telescope the four oriented link differences by ring algebra. -/)]
theorem plaquette_coboundary_zero (S00 S10 S11 S01 : ℝ) :
    let e_bottom := S10 - S00
    let e_right  := S11 - S10
    let e_top    := S01 - S11
    let e_left   := S00 - S01
    e_bottom + e_right + e_top + e_left = 0 := by
  intro e_bottom e_right e_top e_left
  ring

/-- Discrete plaquette phase-slip syndrome: when a `2π * n` branch cut crosses
one link of the plaquette, the oriented loop sum extracts the exact quantized
vortex charge `(n : ℝ) * (2 * π)`. -/
@[blueprint "thm:signals-plaquette-phase-slip-syndrome"
  (title := "Discrete plaquette syndrome extracts 2πn branch jump")
  (statement := /-- When a branch jump $2\pi n$ crosses one link of a plaquette, the oriented
    loop coboundary sum equals $2\pi n$. -/)
  (proof := /-- Telescope the site phases and retain the $2\pi n$ branch term. -/)]
theorem plaquette_phase_slip_syndrome (S00 S10 S11 S01 : ℝ) (n : ℤ) :
    let e_bottom := S10 - S00
    let e_right  := S11 - S10
    let e_top    := (S01 - S11) + (n : ℝ) * (2 * Real.pi)
    let e_left   := S00 - S01
    e_bottom + e_right + e_top + e_left = (n : ℝ) * (2 * Real.pi) := by
  intro e_bottom e_right e_top e_left
  ring

/-! ## Bogoliubov Quasiparticle Spectrum & Landau Critical Velocity

Models the Bogoliubov dispersion relation `(ε(p)/p)² = c_s² + (p/(2m))²` and
the Galilean moving-frame excitation energy `ΔE = ε(p) - p * v`.
- Below the Landau critical velocity (`v < v_c = c_s`), every excitation with
  `ε(p) ≥ v_c * p` and `p > 0` has strictly positive moving-frame energy (`ΔE > 0`),
  forbidding spontaneous dissipative excitation.
- Above `v_c` (`v > v_c`), acoustic excitations at `ε(p) = v_c * p` have negative
  moving-frame energy (`ΔE < 0`), marking the onset of superfluid drag and vortex
  nucleation. Producing net forward propulsion requires external work input.
-/

/-- Squared Bogoliubov excitation phase velocity `(ε(p) / p)² = c_s² + (p / (2m))²`. -/
@[blueprint "def:signals-bogoliubov-phase-vel-sq"
  (title := "Squared Bogoliubov excitation phase velocity")
  (statement := /-- For sound speed $c_s$, boson mass $m$, and momentum $p$, the squared
    quasiparticle phase velocity is $(\epsilon(p)/p)^2=c_s^2+(p/(2m))^2$. -/)]
noncomputable def bogoliubovPhaseVelSq (c_s m p : ℝ) : ℝ :=
  c_s ^ 2 + (p / (2 * m)) ^ 2

/-- Galilean moving-frame excitation energy `ΔE = ε(p) - p * v`. -/
@[blueprint "def:signals-moving-frame-excitation-energy"
  (title := "Galilean moving-frame excitation energy")
  (statement := /-- An excitation of energy $\epsilon_p$ and momentum $p$ in a fluid moving at
    speed $v$ has moving-frame energy $\Delta E=\epsilon_p-p v$. -/)]
def movingFrameExcitationEnergy (ε_p p v : ℝ) : ℝ :=
  ε_p - p * v

/-- Landau critical velocity bound: for any momentum `p`, the squared Bogoliubov
phase velocity is bounded below by the squared Bogoliubov sound speed `c_s²`. -/
@[blueprint "thm:signals-bogoliubov-landau-bound"
  (title := "Landau critical velocity bound for Bogoliubov excitations")
  (statement := /-- For all $c_s,m,p\in\mathbb R$, $c_s^2\le c_s^2+(p/(2m))^2$, so the minimum
    excitation phase speed occurs at the acoustic limit $v_c=c_s$. -/)
  (proof := /-- Add the nonnegative square $(p/(2m))^2\ge 0$ to $c_s^2$. -/)]
theorem bogoliubov_phase_velocity_sq_ge_cs_sq (c_s m p : ℝ) :
    c_s ^ 2 ≤ bogoliubovPhaseVelSq c_s m p := by
  unfold bogoliubovPhaseVelSq
  linarith [sq_nonneg (p / (2 * m))]

/-- Subcritical superfluidity (zero spontaneous dissipation): when `v < v_c` and
`v_c * p ≤ ε_p` for `0 < p`, the moving-frame excitation energy is strictly positive. -/
@[blueprint "thm:signals-subcritical-no-dissipation"
  (title := "Subcritical superflow forbids spontaneous excitation")
  (statement := /-- If $p>0$, $v<v_c$, and $\epsilon_p\ge v_c p$, then $\Delta E=\epsilon_p-p v>0$. -/)
  (proof := /-- From $v<v_c$ and $p>0$, $p v<v_c p\le\epsilon_p$. -/)]
theorem subcritical_no_dissipation (v v_c p ε_p : ℝ)
    (hp : 0 < p) (h_sub : v < v_c) (h_spectrum : v_c * p ≤ ε_p) :
    0 < movingFrameExcitationEnergy ε_p p v := by
  unfold movingFrameExcitationEnergy
  nlinarith

/-- Supercritical excitation onset: when `v_c < v` and `ε_p = v_c * p` for `0 < p`,
the moving-frame excitation energy becomes strictly negative (`ΔE < 0`). -/
@[blueprint "thm:signals-supercritical-excitation-onset"
  (title := "Supercritical flow triggers negative-energy acoustic excitations")
  (statement := /-- If $p>0$, $v_c<v$, and $\epsilon_p=v_c p$, then $\Delta E=\epsilon_p-p v<0$,
    marking the onset of vortex nucleation and superfluid drag. -/)
  (proof := /-- Substitute $\epsilon_p=v_c p$ and factor $p(v_c-v)<0$. -/)]
theorem supercritical_excitation_onset (v v_c p ε_p : ℝ)
    (hp : 0 < p) (h_super : v_c < v) (h_acoustic : ε_p = v_c * p) :
    movingFrameExcitationEnergy ε_p p v < 0 := by
  unfold movingFrameExcitationEnergy
  nlinarith

end Signals.DDF
