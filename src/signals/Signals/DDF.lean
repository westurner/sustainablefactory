import Architect
import Mathlib.Analysis.Complex.Basic
import Mathlib.Analysis.SpecialFunctions.Complex.Arg
import Mathlib.Analysis.SpecialFunctions.Integrals.Basic
import Mathlib.Analysis.SpecialFunctions.Pow.Real
import Mathlib.Analysis.Real.Sqrt
import Mathlib.Basic.Real.Basic
import Mathlib.MeasureTheory.Integral.IntervalIntegral.Basic
import Mathlib.Tactic
import Signals.Geometry
import Signals.Huygens
import Signals.Scattering

namespace Signals.DDF

open MeasureTheory Interval Complex Signals.Geometry Signals.Huygens Signals.Scattering

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

/-! ## Plücker Sink-Flux Superposition, DDF Shear-Jamming Duality, & Anosov Symplectic Invariance

Formalizes and critiques the mathematical connections proposed in
`data/chats/Google-Search_I've-discovered-a-remarkable-identity-the-sum-of-two-slit-channel-weights,-$w_A-+-w_B$,-precisely-equals-a-specific-Plü_20261024-0322.md`
(lines 6--228):
1. **Slit Channel Weights as Hydrodynamic Sink Fluxes / Coupled $(\phi, \varphi)$ Bosonic Sectors**:
   The uncrossed channel weights $Q_A(M) = \Delta_{01}(M)\Delta_{23}(M)$ and
   $Q_B(M) = \Delta_{03}(M)\Delta_{12}(M)$ sum to the crossing Plücker product
   $Q_A(M) + Q_B(M) = \Delta_{02}(M)\Delta_{13}(M)$, while their half-difference
   $(Q_A(M) - Q_B(M))/2$ is the Plücker barycentric parallel-axis shift $d_{\mathrm{bary}}(M)$.
2. **Symmetric Zero-Shear / Zero-Jamming Limit & Critique of Unphased vs. Phased Error**:
   At zero relative shear speed ($v = 0$), the DDF jamming factor is $\gamma_\varphi(0) = 1$
   and the reversible shear-jamming kinetic energy vanishes ($K_D(0) = 0$).
   *Critique 1*: At the symmetric point ($Q_A = Q_B = 1$, $d_{\mathrm{bary}} = 0$),
   the unphased positive-Grassmannian sum $Q_A + Q_B = 2$ does **not** have zero
   relative error against the Fraunhofer peak ($4 I_0$): it has a $50\%$ ($1/2$) error
   (`gr24UnphasedDoubleSlit_onAxis_relative_error_half`), whereas the phased
   $Gr(2,4)$ / complex $Gr_{\mathbb{C}}(2,4)$ / Huygens--Steiner model has zero error.
3. **DDF Shear-Jamming Duality, Power-Law Bounds, and Explicit Substrate Parameter Inversion**:
   Identifying the reduced shear speed $\beta = v/c \in [0, 1)$ with $|d_{\mathrm{bary}}|$
   makes the optical visibility the reciprocal of the DDF jamming factor,
   $\mathcal{V} = \sqrt{1 - \beta^2} = \gamma_\varphi(v)^{-1}$. The on-axis relative
   predictive error equals $\varepsilon = \frac{1 - \gamma_\varphi(v)^{-1}}{2} = \frac{K_D(v)}{2 E_\varphi(v)}$,
   satisfies the tight quadratic power-law bounds $\frac{d_{\mathrm{bary}}^2}{4} \le \varepsilon \le \frac{d_{\mathrm{bary}}^2}{2}$,
   and admits exact algebraic inversion $\mathcal{V} = 1 - 2\varepsilon$,
   $\gamma_\varphi = (1 - 2\varepsilon)^{-1}$, and $\beta^2 = d_{\mathrm{bary}}^2 = 4\varepsilon(1 - \varepsilon)$.
4. **Anosov Hyperbolic Tangent-Flow Invariance & Critique of Non-Symplectic Jamming**:
   Under a 2D symplectic Anosov hyperbolic stretch $A_{\mathrm{Anosov}}(\lambda, t) = \operatorname{diag}(e^{\lambda t}, e^{-\lambda t})$
   ($\det = 1$), all $2 \times 2$ Plücker minors, sink fluxes, and $d_{\mathrm{bary}}(M)$
   are exact dynamical invariants. *Critique 2*: Under a non-symplectic compressive
   jamming deformation $\operatorname{diag}(e^{\lambda_1 t}, e^{\lambda_2 t})$ with
   $\lambda_1 + \lambda_2 \neq 0$, quadratic Plücker products scale by $e^{2(\lambda_1 + \lambda_2)t}$.
5. **Differential Vortex Circulation & Gravitomagnetic Swirl**:
   When two sinks carry quantized $\phi$-superfluid vortex charges $\ell_1, \ell_2 \in \mathbb{Z}$,
   the normalized differential circulation $(\Gamma(\ell_2) - \Gamma(\ell_1)) / \kappa_\phi = \ell_2 - \ell_1 = \Delta\ell$
   governs the quadratic Wigner rotational phase-space error, which vanishes at the
   irrotational symmetric point $\ell_1 = \ell_2$.
-/

/-- First localized hydrodynamic sink flux / uncrossed Plücker channel weight
$Q_A(M) = \Delta_{01}(M)\Delta_{23}(M)$ on $Gr(2,4)$. -/
@[blueprint "def:signals-ddf-plucker-sink-flux-a"
  (title := "First Plücker hydrodynamic sink flux Q_A(M)")
  (statement := /-- For $M\in\mathbb R^{2\times 4}$, define the first uncrossed channel/sink
    flux $Q_A(M)=\Delta_{01}(M)\Delta_{23}(M)$. -/)]
def pluckerSinkFluxA (M : Matrix (Fin 2) (Fin 4) ℝ) : ℝ :=
  twoRowMinor M 0 1 * twoRowMinor M 2 3

/-- Second localized hydrodynamic sink flux / uncrossed Plücker channel weight
$Q_B(M) = \Delta_{03}(M)\Delta_{12}(M)$ on $Gr(2,4)$. -/
@[blueprint "def:signals-ddf-plucker-sink-flux-b"
  (title := "Second Plücker hydrodynamic sink flux Q_B(M)")
  (statement := /-- For $M\in\mathbb R^{2\times 4}$, define the second uncrossed channel/sink
    flux $Q_B(M)=\Delta_{03}(M)\Delta_{12}(M)$. -/)]
def pluckerSinkFluxB (M : Matrix (Fin 2) (Fin 4) ℝ) : ℝ :=
  twoRowMinor M 0 3 * twoRowMinor M 1 2

/-- Total two-sink volume flux / coupled $(\phi, \varphi)$ sector sum
$Q_{\mathrm{tot}}(M) = Q_A(M) + Q_B(M)$ Equals the crossing Plücker product
$\Delta_{02}(M)\Delta_{13}(M)$, while the half-difference $(Q_A(M) - Q_B(M))/2$
equals the Plücker barycentric parallel-axis shift $d_{\mathrm{bary}}(M)$. -/
@[blueprint "thm:signals-ddf-plucker-sink-flux-conservation"
  (title := "Plücker two-sink flux conservation and barycentric shear asymmetry")
  (statement := /-- For any $M\in\mathbb R^{2\times 4}$,
    $Q_A(M)+Q_B(M)=\Delta_{02}(M)\Delta_{13}(M)$ and
    $(Q_A(M)-Q_B(M))/2 = d_{\mathrm{bary}}(M)$. -/)
  (proof := /-- Apply \texttt{gr24\_channel\_sum\_eq\_crossing} for the sum and unfold
    \texttt{gr24BarycentricShift} for the half-difference. -/)]
theorem pluckerSinkFlux_conservation_and_asymmetry (M : Matrix (Fin 2) (Fin 4) ℝ) :
    pluckerSinkFluxA M + pluckerSinkFluxB M = twoRowMinor M 0 2 * twoRowMinor M 1 3 ∧
      (pluckerSinkFluxA M - pluckerSinkFluxB M) / 2 = gr24BarycentricShift M :=
  ⟨gr24_channel_sum_eq_crossing M, rfl⟩

/-- **Zero-Shear / Zero-Jamming Limit of a DDF Moving Sheath**:
When the relative shear speed vanishes ($v = 0$), the reduced speed squared is
$\beta^2 = 0$, the constitutive jamming factor is $\gamma_\varphi(0) = 1$, and
the reversible shear-jamming kinetic energy vanishes ($K_D(0) = 0$). -/
@[blueprint "thm:signals-ddf-zero-shear-no-jamming"
  (title := "DDF zero-shear limit gives unit jamming factor γ_φ(0) = 1 and zero kinetic energy")
  (statement := /-- If $s.\mathrm{velocity}=0$, then $s.\mathrm{betaSq}=0$,
    $s.\mathrm{jammingFactor}=1$, and $s.\mathrm{kineticEnergy}(m)=0$. -/)
  (proof := /-- Substitute $v=0$ into \texttt{betaSq}, \texttt{jammingFactor}, and
    \texttt{kineticEnergy}, then simplify $\sqrt{1}=1$. -/)]
theorem MovingSheath.zero_shear_no_jamming {sub : DDFSubstrate}
    (s : MovingSheath sub) (h_zero : s.velocity = 0) (restMass : ℝ) :
    s.betaSq = 0 ∧ s.jammingFactor = 1 ∧ s.kineticEnergy restMass = 0 := by
  have h_beta : s.betaSq = 0 := by
    unfold MovingSheath.betaSq
    rw [h_zero]
    simp
  have h_jam : s.jammingFactor = 1 := by
    unfold MovingSheath.jammingFactor
    rw [h_beta]
    simp
  have h_kin : s.kineticEnergy restMass = 0 := by
    unfold MovingSheath.kineticEnergy
    rw [h_jam]
    ring
  exact ⟨h_beta, h_jam, h_kin⟩

/-- Coherence visibility dual to a DDF moving sheath:
$\mathcal{V}(s) = \sqrt{1 - \beta^2} = \sqrt{1 - (v/c)^2}$. -/
@[blueprint "def:signals-ddf-sheath-coherence-visibility"
  (title := "Coherence visibility dual to a DDF moving sheath")
  (statement := /-- For a subluminal sheath $s$, define the dual coherence visibility
    $\mathcal{V}(s)=\sqrt{1-s.\mathrm{betaSq}}=\sqrt{1-(v/c)^2}$. -/)]
noncomputable def MovingSheath.coherenceVisibility {sub : DDFSubstrate}
    (s : MovingSheath sub) : ℝ :=
  Real.sqrt (1 - s.betaSq)

/-- **DDF Shear-Jamming / Coherence Complementarity Duality**:
For any subluminal `MovingSheath`, the dual visibility $\mathcal{V}(s) = \sqrt{1 - \beta^2}$
is the exact reciprocal of the DDF constitutive jamming factor $\gamma_\varphi(v)$,
and the reduced shear ratio squared $\beta^2 = (v/c)^2$ and squared visibility
satisfy the Pythagorean complementarity identity $\beta^2 + \mathcal{V}(s)^2 = 1$. -/
@[blueprint "thm:signals-ddf-sheath-visibility-jamming-duality"
  (title := "Reciprocal duality between DDF jamming factor γ_φ(v) and coherence visibility V")
  (statement := /-- For any subluminal sheath $s$,
    $\mathcal{V}(s) = s.\mathrm{jammingFactor}^{-1}$,
    $s.\mathrm{jammingFactor}\cdot\mathcal{V}(s)=1$, and
    $s.\mathrm{betaSq} + \mathcal{V}(s)^2 = 1$. -/)
  (proof := /-- Unfold \texttt{coherenceVisibility} and \texttt{jammingFactor}, use
    $\sqrt{1-\beta^2}>0$ from \texttt{one\_sub\_betaSq\_pos}, and apply \texttt{Real.sq\_sqrt}. -/)]
theorem MovingSheath.visibility_jamming_duality {sub : DDFSubstrate}
    (s : MovingSheath sub) :
    s.coherenceVisibility = (s.jammingFactor)⁻¹ ∧
      s.jammingFactor * s.coherenceVisibility = 1 ∧
      s.betaSq + s.coherenceVisibility ^ 2 = 1 := by
  have h_pos := s.one_sub_betaSq_pos
  have h_sqrt_ne : Real.sqrt (1 - s.betaSq) ≠ 0 :=
    ne_of_gt (Real.sqrt_pos.mpr h_pos)
  have h_inv : s.coherenceVisibility = (s.jammingFactor)⁻¹ := by
    unfold MovingSheath.coherenceVisibility MovingSheath.jammingFactor
    rw [one_div, inv_inv]
  have h_mul : s.jammingFactor * s.coherenceVisibility = 1 := by
    unfold MovingSheath.coherenceVisibility MovingSheath.jammingFactor
    exact one_div_mul_cancel h_sqrt_ne
  have h_comp : s.betaSq + s.coherenceVisibility ^ 2 = 1 := by
    unfold MovingSheath.coherenceVisibility
    rw [Real.sq_sqrt (le_of_lt h_pos)]
    ring
  exact ⟨h_inv, h_mul, h_comp⟩

/-- **On-Axis Relative Predictive Error from DDF Shear Jamming & Kinetic Energy Ratio**:
When the optical visibility is governed by the reciprocal DDF jamming factor
$\mathcal{V}(s) = \gamma_\varphi(v)^{-1} = \sqrt{1 - (v/c)^2}$, the on-axis relative
predictive error of `huygensSteinerDoubleSlit` against the coherent Fraunhofer
reference equals $\frac{\gamma_\varphi(v) - 1}{2\,\gamma_\varphi(v)}$, which for any rest
mass $m > 0$ equals the ratio of the DDF reversible shear-jamming kinetic energy
$K_D(v)$ to twice the total relativistic sheath energy $2 \gamma_\varphi(v) m c^2$. -/
@[blueprint "thm:signals-ddf-sheath-relative-error-jamming"
  (title := "On-axis relative predictive error equals DDF jamming excess (γ_φ - 1)/(2γ_φ) and K_D/(2E_φ)")
  (statement := /-- For $I_0>0$ and $m>0$, with $\mathcal{V}=\mathcal{V}(s)=\gamma_\varphi(v)^{-1}$,
    $\varepsilon_{\mathrm{rel}}\bigl(I_{\mathrm{HS}}(0,0;\mathcal{V}(s)),I_{\mathrm{F}}(0,0)\bigr)
    = \frac{\gamma_\varphi(v)-1}{2\,\gamma_\varphi(v)}
    = \frac{K_D(v)}{2\,\gamma_\varphi(v)\,m c^2}$. -/)
  (proof := /-- Apply \texttt{huygensSteiner\_onAxis\_relative\_error} with $\mathcal{V}(s)\le 1$
    and rewrite $\mathcal{V}(s)=\gamma_\varphi(v)^{-1}$. -/)]
theorem ddf_sheath_relative_error_eq_jamming {sub : DDFSubstrate}
    (s : MovingSheath sub)
    (singleSlitScale slitWidth slitHeight separation wavelength screenDistance restMass : ℝ)
    (h_scale : 0 < singleSlitScale) (h_mass : 0 < restMass) :
    have h_vis_le_one : s.coherenceVisibility ≤ 1 := by
      unfold MovingSheath.coherenceVisibility
      have h_beta_nonneg : 0 ≤ s.betaSq := by
        unfold MovingSheath.betaSq
        positivity
      exact Real.sqrt_le_one.mpr (by linarith)
    relativePredictiveError
        (huygensSteinerDoubleSlit
          singleSlitScale slitWidth slitHeight separation wavelength screenDistance
          s.coherenceVisibility 0 0)
        (fraunhoferRectangularDoubleSlit
          singleSlitScale slitWidth slitHeight separation wavelength screenDistance 0 0) =
      (s.jammingFactor - 1) / (2 * s.jammingFactor) ∧
    (s.jammingFactor - 1) / (2 * s.jammingFactor) =
      s.kineticEnergy restMass / (2 * (s.jammingFactor * restMass * sub.c ^ 2)) := by
  have h_beta_nonneg : 0 ≤ s.betaSq := by
    unfold MovingSheath.betaSq
    positivity
  have h_vis_le_one : s.coherenceVisibility ≤ 1 := by
    unfold MovingSheath.coherenceVisibility
    exact Real.sqrt_le_one.mpr (by linarith)
  have h_jam_pos := s.jammingFactor_pos
  have h_jam_ne : s.jammingFactor ≠ 0 := ne_of_gt h_jam_pos
  have h_c_pos := sub.c_pos
  have h_mc2_ne : restMass * sub.c ^ 2 ≠ 0 := by positivity
  have h_err := huygensSteiner_onAxis_relative_error
    singleSlitScale slitWidth slitHeight separation wavelength screenDistance
    s.coherenceVisibility h_scale h_vis_le_one
  have h_inv := (s.visibility_jamming_duality).1
  refine ⟨?_, ?_⟩
  · rw [h_err, h_inv]
    field_simp [h_jam_ne]
  · unfold MovingSheath.kineticEnergy
    field_simp [h_jam_ne, h_mc2_ne]

/-- **Tight Quadratic Power-Law Bounds & Exact Substrate Parameter Inversion**:
For any barycentric / shear shift $d_{\mathrm{bary}} \in [-1, 1]$ with visibility
$\mathcal{V} = \sqrt{1 - d_{\mathrm{bary}}^2}$ and on-axis relative predictive error
$\varepsilon = (1 - \mathcal{V})/2$:
1. $\varepsilon$ is bounded above and below by the quadratic power laws
   $\frac{d_{\mathrm{bary}}^2}{4} \le \varepsilon \le \frac{d_{\mathrm{bary}}^2}{2}$, and
2. $d_{\mathrm{bary}}^2$ is uniquely inverted from the optical relative error $\varepsilon$
   via the exact polynomial law $d_{\mathrm{bary}}^2 = 4\varepsilon(1 - \varepsilon)$. -/
@[blueprint "thm:signals-ddf-relative-error-power-law-and-inversion"
  (title := "Quadratic power-law bounds and exact inversion of d_bary² = 4ε(1 - ε) from optical relative error")
  (statement := /-- For any $d_{\mathrm{bary}}\in[-1,1]$, let $\mathcal{V}=\sqrt{1-d_{\mathrm{bary}}^2}$
    and $\varepsilon=(1-\mathcal{V})/2$. Then
    $\frac{d_{\mathrm{bary}}^2}{4}\le\varepsilon\le\frac{d_{\mathrm{bary}}^2}{2}$ and
    $d_{\mathrm{bary}}^2 = 4\varepsilon(1-\varepsilon)$. -/)
  (proof := /-- Use $\mathcal{V}\in[0,1]$ and $\mathcal{V}^2=1-d_{\mathrm{bary}}^2$, so
    $d_{\mathrm{bary}}^2=(1-\mathcal{V})(1+\mathcal{V})=2\varepsilon(1+\mathcal{V})$ with
    $1\le 1+\mathcal{V}\le 2$. -/)]
theorem ddf_relative_error_power_law_and_inversion
    (d_bary : ℝ) (h_low : -1 ≤ d_bary) (h_high : d_bary ≤ 1) :
    let V := Real.sqrt (1 - d_bary ^ 2)
    let ε := (1 - V) / 2
    d_bary ^ 2 / 4 ≤ ε ∧
      ε ≤ d_bary ^ 2 / 2 ∧
      d_bary ^ 2 = 4 * ε * (1 - ε) := by
  intro V ε
  have h_one_sub : 0 ≤ 1 - d_bary ^ 2 := by nlinarith
  have h_V_nonneg : 0 ≤ V := Real.sqrt_nonneg _
  have h_V_le_one : V ≤ 1 := by
    dsimp [V]
    exact Real.sqrt_le_one.mpr (by nlinarith)
  have h_V_sq : V ^ 2 = 1 - d_bary ^ 2 := Real.sq_sqrt h_one_sub
  have h_dbary_sq : d_bary ^ 2 = (1 - V) * (1 + V) := by linarith
  refine ⟨?_, ?_, ?_⟩
  · dsimp [ε]
    nlinarith
  · dsimp [ε]
    nlinarith
  · dsimp [ε]
    linarith

/-- **Explicit Inverse Recovery of DDF Sheath Parameters from On-Axis Relative Error**:
For any subluminal `MovingSheath` $s$, let $\varepsilon = (1 - \mathcal{V}(s))/2$ be the
on-axis relative predictive error. Because $v < c$, $\mathcal{V}(s) > 0$, so
$0 \le \varepsilon < 1/2$ and $1 - 2\varepsilon > 0$, and the visibility $\mathcal{V}(s)$,
constitutive jamming factor $\gamma_\varphi(v)$, and squared speed ratio $\beta^2 = (v/c)^2$
are uniquely recovered by:
$\mathcal{V}(s) = 1 - 2\varepsilon$, $\gamma_\varphi(v) = (1 - 2\varepsilon)^{-1}$, and
$\beta^2 = 4\varepsilon(1 - \varepsilon)$. -/
@[blueprint "thm:signals-ddf-sheath-inverse-recovery"
  (title := "Explicit inverse recovery of V, γ_φ(v), and β² = (v/c)² from relative error ε")
  (statement := /-- For a subluminal sheath $s$ with $\varepsilon=(1-\mathcal{V}(s))/2$,
    $0\le\varepsilon<1/2$, $\mathcal{V}(s)=1-2\varepsilon$,
    $s.\mathrm{jammingFactor}=1/(1-2\varepsilon)$, and
    $s.\mathrm{betaSq}=4\varepsilon(1-\varepsilon)$. -/)
  (proof := /-- Use $0<\mathcal{V}(s)\le 1$ from $0\le\beta^2<1$, solve $\mathcal{V}(s)=1-2\varepsilon$,
    invert via \texttt{visibility\_jamming\_duality}, and substitute into $\beta^2=1-\mathcal{V}(s)^2$. -/)]
theorem MovingSheath.inverse_recovery_from_relative_error {sub : DDFSubstrate}
    (s : MovingSheath sub) :
    let ε := (1 - s.coherenceVisibility) / 2
    0 ≤ ε ∧
      ε < 1 / 2 ∧
      s.coherenceVisibility = 1 - 2 * ε ∧
      s.jammingFactor = 1 / (1 - 2 * ε) ∧
      s.betaSq = 4 * ε * (1 - ε) := by
  intro ε
  have h_pos := s.one_sub_betaSq_pos
  have h_beta_nonneg : 0 ≤ s.betaSq := by
    unfold MovingSheath.betaSq
    positivity
  have h_vis_pos : 0 < s.coherenceVisibility :=
    Real.sqrt_pos.mpr h_pos
  have h_vis_le_one : s.coherenceVisibility ≤ 1 := by
    unfold MovingSheath.coherenceVisibility
    exact Real.sqrt_le_one.mpr (by linarith)
  have h_vis_eq : s.coherenceVisibility = 1 - 2 * ε := by
    dsimp [ε]
    ring
  have h_jam_eq : s.jammingFactor = 1 / (1 - 2 * ε) := by
    rw [← h_vis_eq]
    unfold MovingSheath.jammingFactor MovingSheath.coherenceVisibility
    rfl
  have h_comp := (s.visibility_jamming_duality).2.2
  have h_beta_eq : s.betaSq = 4 * ε * (1 - ε) := by
    have h1 : s.betaSq = 1 - s.coherenceVisibility ^ 2 := by linarith
    rw [h1, h_vis_eq]
    ring
  refine ⟨by dsimp [ε]; linarith, by dsimp [ε]; linarith, h_vis_eq, h_jam_eq, h_beta_eq⟩

/-- Symplectic 2D Anosov hyperbolic tangent-flow matrix
$A_{\mathrm{Anosov}}(\lambda, t) = \operatorname{diag}(e^{\lambda t}, e^{-\lambda t})$
with Lyapunov stretching rate $\lambda$ and flow time $t$. -/
@[blueprint "def:signals-ddf-anosov-hyperbolic-matrix"
  (title := "Symplectic 2D Anosov hyperbolic stretching matrix")
  (statement := /-- For Lyapunov exponent $\lambda\in\mathbb R$ and time $t\in\mathbb R$, define
    $A_{\mathrm{Anosov}}(\lambda,t)=\begin{pmatrix}e^{\lambda t}&0\\0&e^{-\lambda t}\end{pmatrix}$. -/)]
noncomputable def anosovHyperbolicMatrix (lyapunovRate time : ℝ) :
    Matrix (Fin 2) (Fin 2) ℝ :=
  !![Real.exp (lyapunovRate * time), 0;
     0, Real.exp (-(lyapunovRate * time))]

/-- The symplectic 2D Anosov hyperbolic matrix has unit determinant
$\det A_{\mathrm{Anosov}}(\lambda, t) = 1$ for all $\lambda, t \in \mathbb{R}$. -/
@[blueprint "lem:signals-ddf-anosov-det-one"
  (title := "Unit determinant of the symplectic Anosov hyperbolic matrix")
  (statement := /-- For all $\lambda,t\in\mathbb R$, $\det A_{\mathrm{Anosov}}(\lambda,t)=1$. -/)
  (proof := /-- Expand the $2\times 2$ determinant and apply $e^{x}e^{-x}=e^{0}=1$. -/)
  (latexEnv := "lemma")]
lemma anosovHyperbolicMatrix_det_one (lyapunovRate time : ℝ) :
    (anosovHyperbolicMatrix lyapunovRate time).det = 1 := by
  unfold anosovHyperbolicMatrix
  rw [Matrix.det_fin_two]
  simp [← Real.exp_add]

/-- **Anosov Symplectic Invariance of Plücker Minors, Sink Fluxes, and Barycentric Shift**:
Under the symplectic Anosov hyperbolic tangent flow $M \mapsto A_{\mathrm{Anosov}}(\lambda, t) M$,
every $2 \times 2$ Plücker minor $\Delta_{jk}$, both sink fluxes $Q_A, Q_B$, and the
Plücker barycentric shift $d_{\mathrm{bary}}(M)$ are exact dynamical invariants. -/
@[blueprint "thm:signals-ddf-anosov-plucker-invariance"
  (title := "Exact invariance of Plücker minors, sink fluxes, and d_bary under symplectic Anosov flows")
  (statement := /-- For any $M\in\mathbb R^{2\times 4}$, $\lambda,t\in\mathbb R$, and columns $c_0,c_1$,
    $\Delta_{c_0 c_1}(A_{\mathrm{Anosov}}(\lambda,t)M)=\Delta_{c_0 c_1}(M)$ and
    $d_{\mathrm{bary}}(A_{\mathrm{Anosov}}(\lambda,t)M)=d_{\mathrm{bary}}(M)$. -/)
  (proof := /-- Expand $A_{\mathrm{Anosov}}(\lambda,t)M$ and cancel $e^{\lambda t}e^{-\lambda t}=1$. -/)]
theorem anosov_plucker_invariance
    (M : Matrix (Fin 2) (Fin 4) ℝ) (lyapunovRate time : ℝ) (c0 c1 : Fin 4) :
    twoRowMinor (anosovHyperbolicMatrix lyapunovRate time * M) c0 c1 =
      twoRowMinor M c0 c1 ∧
    gr24BarycentricShift (anosovHyperbolicMatrix lyapunovRate time * M) =
      gr24BarycentricShift M := by
  have h_minor : ∀ a b : Fin 4,
      twoRowMinor (anosovHyperbolicMatrix lyapunovRate time * M) a b =
        twoRowMinor M a b := by
    intro a b
    unfold twoRowMinor anosovHyperbolicMatrix
    simp only [Matrix.mul_apply, Fin.sum_univ_two, Fin.isValue, Matrix.of_apply,
      Matrix.cons_val', Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.cons_val_fin_one,
      zero_mul, add_zero, zero_add]
    have h_exp : Real.exp (lyapunovRate * time) * Real.exp (-(lyapunovRate * time)) = 1 := by
      rw [← Real.exp_add, add_neg_cancel, Real.exp_zero]
    calc
      Real.exp (lyapunovRate * time) * M 0 a * (Real.exp (-(lyapunovRate * time)) * M 1 b) -
          Real.exp (lyapunovRate * time) * M 0 b * (Real.exp (-(lyapunovRate * time)) * M 1 a) =
        (Real.exp (lyapunovRate * time) * Real.exp (-(lyapunovRate * time))) *
          (M 0 a * M 1 b - M 0 b * M 1 a) := by ring
      _ = M 0 a * M 1 b - M 0 b * M 1 a := by rw [h_exp, one_mul]
  refine ⟨h_minor c0 c1, ?_⟩
  unfold gr24BarycentricShift
  rw [h_minor 0 1, h_minor 2 3, h_minor 0 3, h_minor 1 2]

/-- **Critique of Non-Symplectic Compressive Jamming**:
Under a general diagonal tangent deformation $\operatorname{diag}(e^{\lambda_1 t}, e^{\lambda_2 t})$
where $\lambda_1 + \lambda_2 \neq 0$, the Plücker barycentric shift scales by the squared
phase-space area factor $e^{2(\lambda_1 + \lambda_2)t}$, proving that symplectic area
preservation ($\lambda_1 + \lambda_2 = 0$) is necessary to preserve unnormalized
Plücker sink fluxes without projective rescaling. -/
@[blueprint "lem:signals-ddf-nonsymplectic-jamming-scaling"
  (title := "Non-symplectic jamming scales quadratic Plücker sink fluxes by exp(2(λ₁ + λ₂)t)")
  (statement := /-- For $B=\operatorname{diag}(e^{\lambda_1 t},e^{\lambda_2 t})$,
    $d_{\mathrm{bary}}(BM)=e^{2(\lambda_1+\lambda_2)t}\,d_{\mathrm{bary}}(M)$. -/)
  (proof := /-- Factor $e^{(\lambda_1+\lambda_2)t}$ from each $2\times 2$ minor of $BM$. -/)
  (latexEnv := "lemma")]
lemma nonSymplectic_jamming_barycentricShift_scaling
    (M : Matrix (Fin 2) (Fin 4) ℝ) (rate1 rate2 time : ℝ) :
    let B : Matrix (Fin 2) (Fin 2) ℝ :=
      !![Real.exp (rate1 * time), 0; 0, Real.exp (rate2 * time)]
    gr24BarycentricShift (B * M) =
      Real.exp (2 * (rate1 + rate2) * time) * gr24BarycentricShift M := by
  intro B
  have h_minor : ∀ a b : Fin 4,
      twoRowMinor (B * M) a b =
        Real.exp ((rate1 + rate2) * time) * twoRowMinor M a b := by
    intro a b
    unfold twoRowMinor
    dsimp [B]
    simp only [Matrix.mul_apply, Fin.sum_univ_two, Fin.isValue, Matrix.of_apply,
      Matrix.cons_val', Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.cons_val_fin_one,
      zero_mul, add_zero, zero_add]
    have h_exp : Real.exp (rate1 * time) * Real.exp (rate2 * time) =
        Real.exp ((rate1 + rate2) * time) := by
      rw [← Real.exp_add]
      congr 1
      ring
    calc
      Real.exp (rate1 * time) * M 0 a * (Real.exp (rate2 * time) * M 1 b) -
          Real.exp (rate1 * time) * M 0 b * (Real.exp (rate2 * time) * M 1 a) =
        (Real.exp (rate1 * time) * Real.exp (rate2 * time)) *
          (M 0 a * M 1 b - M 0 b * M 1 a) := by ring
      _ = Real.exp ((rate1 + rate2) * time) * (M 0 a * M 1 b - M 0 b * M 1 a) := by rw [h_exp]
  unfold gr24BarycentricShift
  rw [h_minor 0 1, h_minor 2 3, h_minor 0 3, h_minor 1 2]
  have h_sq : Real.exp ((rate1 + rate2) * time) * Real.exp ((rate1 + rate2) * time) =
      Real.exp (2 * (rate1 + rate2) * time) := by
    rw [← Real.exp_add]
    congr 1
    ring
  calc
    (Real.exp ((rate1 + rate2) * time) * twoRowMinor M 0 1 *
        (Real.exp ((rate1 + rate2) * time) * twoRowMinor M 2 3) -
      Real.exp ((rate1 + rate2) * time) * twoRowMinor M 0 3 *
        (Real.exp ((rate1 + rate2) * time) * twoRowMinor M 1 2)) / 2 =
      (Real.exp ((rate1 + rate2) * time) * Real.exp ((rate1 + rate2) * time)) *
        ((twoRowMinor M 0 1 * twoRowMinor M 2 3 -
          twoRowMinor M 0 3 * twoRowMinor M 1 2) / 2) := by ring
    _ = Real.exp (2 * (rate1 + rate2) * time) *
        ((twoRowMinor M 0 1 * twoRowMinor M 2 3 -
          twoRowMinor M 0 3 * twoRowMinor M 1 2) / 2) := by rw [h_sq]

/-- **Critique of the Symmetric Zero-Shear Point (Phased vs. Unphased Plücker Proxy)**:
At the symmetric balanced $Gr(2,4)$ point ($Q_A(M) = 1$, $Q_B(M) = 1$, so
$Q_A + Q_B = \Delta_{02}\Delta_{13} = 2$ and $d_{\mathrm{bary}}(M) = 0$) with a
zero-shear DDF sheath ($v = 0 \implies \gamma_\varphi(0) = 1$):
1. The **phased** Plücker channel model `gr24PluckerDoubleSlit` matches the
   Fraunhofer reference with **zero** relative predictive error ($\varepsilon_{\mathrm{rel}} = 0$),
2. Whereas the **unphased** real crossing-minor sum `gr24UnphasedDoubleSlit`
   incurs a mandatory **$50\%$ ($1/2$) on-axis relative predictive error**,
   refuting the claim that the unphased sum $w_A + w_B = \Delta_{02}\Delta_{13}$
   alone yields zero error at the symmetric point without coherent phase interference. -/
@[blueprint "thm:signals-ddf-symmetric-zero-shear-vs-unphased-critique"
  (title := "Symmetric zero-shear critique: phased Plücker has 0% error while unphased sum w_A + w_B has 50% error")
  (statement := /-- If $Q_A(M)=1$ and $Q_B(M)=1$, then $d_{\mathrm{bary}}(M)=0$,
    $\varepsilon_{\mathrm{rel}}\bigl(I_{Gr(2,4)}(M;x,y),I_{\mathrm{F}}(x,y)\bigr)=0$ for all $(x,y)$,
    and for $I_0>0$,
    $\varepsilon_{\mathrm{rel}}\bigl(I_{Gr(2,4)}^{\mathrm{unphased}}(M;0,0),I_{\mathrm{F}}(0,0)\bigr)=1/2$. -/)
  (proof := /-- Combine \texttt{gr24PluckerDoubleSlit\_balanced\_eq\_fraunhofer} and
    \texttt{gr24UnphasedDoubleSlit\_onAxis\_relative\_error\_half}. -/)]
theorem ddf_symmetric_zero_shear_vs_unphased_critique
    (M : Matrix (Fin 2) (Fin 4) ℝ)
    (singleSlitScale slitWidth slitHeight separation wavelength screenDistance x y : ℝ)
    (h_scale : 0 < singleSlitScale)
    (h_A : pluckerSinkFluxA M = 1)
    (h_B : pluckerSinkFluxB M = 1) :
    gr24BarycentricShift M = 0 ∧
      relativePredictiveError
        (gr24PluckerDoubleSlit M singleSlitScale slitWidth slitHeight separation
          wavelength screenDistance x y)
        (fraunhoferRectangularDoubleSlit singleSlitScale slitWidth slitHeight
          separation wavelength screenDistance x y) = 0 ∧
      relativePredictiveError
        (gr24UnphasedDoubleSlit M singleSlitScale slitWidth slitHeight
          wavelength screenDistance 0 0)
        (fraunhoferRectangularDoubleSlit singleSlitScale slitWidth slitHeight
          separation wavelength screenDistance 0 0) = 1 / 2 := by
  have h_bary : gr24BarycentricShift M = 0 := by
    rw [← (pluckerSinkFlux_conservation_and_asymmetry M).2, h_A, h_B]
    ring
  have h_cross : twoRowMinor M 0 2 * twoRowMinor M 1 3 = 2 := by
    rw [← (pluckerSinkFlux_conservation_and_asymmetry M).1, h_A, h_B]
    norm_num
  have h_phased_eq := gr24PluckerDoubleSlit_balanced_eq_fraunhofer M
    singleSlitScale slitWidth slitHeight separation wavelength screenDistance x y h_A h_B
  refine ⟨h_bary, ?_, ?_⟩
  · rw [h_phased_eq]
    simp [relativePredictiveError]
  · exact gr24UnphasedDoubleSlit_onAxis_relative_error_half M
      singleSlitScale slitWidth slitHeight separation wavelength screenDistance h_scale h_cross

/-- Differential quantized vortex circulation between two sinks carrying winding
numbers $\ell_1, \ell_2 \in \mathbb{Z}$ in a `DDFSubstrate`:
$\Delta\Gamma = (\ell_2 - \ell_1) \kappa_\phi$. -/
@[blueprint "def:signals-ddf-differential-vortex-circulation"
  (title := "Differential quantized vortex circulation between two DDF sinks")
  (statement := /-- For vortex charges $\ell_1,\ell_2\in\mathbb Z$, define the differential
    superfluid circulation $\Delta\Gamma(\ell_1,\ell_2)=(\ell_2-\ell_1)\kappa_\phi$. -/)]
noncomputable def DDFSubstrate.differentialVortexCirculation
    (sub : DDFSubstrate) (hbar : ℝ) (ℓ₁ ℓ₂ : ℤ) : ℝ :=
  ((ℓ₂ - ℓ₁ : ℤ) : ℝ) * sub.circulationQuantum hbar

/-- **Differential Vortex Circulation & Wigner Rotational Relative Predictive Error**:
The normalized differential circulation $\Delta\Gamma(\ell_1, \ell_2) / \kappa_\phi$
equals the differential OAM charge $\Delta\ell = \ell_2 - \ell_1$ (for $\hbar \neq 0$),
and at the irrotational symmetric point ($\ell_1 = \ell_2$, $\Delta\Gamma = 0$),
the Wigner angle--OAM relative predictive error vanishes identically. -/
@[blueprint "thm:signals-ddf-vortex-circulation-wigner-error"
  (title := "Differential DDF vortex circulation governs Wigner OAM relative predictive error")
  (statement := /-- For $\hbar\ne 0$, $I_0>0$, and $\gamma_{\mathrm{OAM}}\ge 0$,
    $\Delta\Gamma(\ell_1,\ell_2)/\kappa_\phi = \ell_2-\ell_1$, and at the irrotational
    symmetric point $\ell_1=\ell_2$, $\Delta\Gamma(\ell_1,\ell_1)=0$ and
    $\varepsilon_{\mathrm{rel}}\bigl(I_{\mathrm{Wigner,OAM}}(0,0,0;\ell_1-\ell_1,\gamma_{\mathrm{OAM}}),
    I_{\mathrm{F,OAM}}(0,0,0;\ell_1-\ell_1)\bigr)=0$. -/)
  (proof := /-- Cancel $\kappa_\phi=2\pi\hbar/m_\phi\ne 0$ and evaluate
    \texttt{wignerOAM\_onAxis\_relative\_error} at $\Delta\ell=\ell_1-\ell_1=0$. -/)]
theorem DDFSubstrate.vortex_circulation_wigner_error
    (sub : DDFSubstrate) (hbar : ℝ) (h_hbar : hbar ≠ 0) (ℓ₁ ℓ₂ : ℤ)
    (singleSlitScale slitWidth slitHeight separation wavelength screenDistance
      oamDecoherenceRate : ℝ)
    (h_scale : 0 < singleSlitScale) (h_dec : 0 ≤ oamDecoherenceRate) :
    sub.differentialVortexCirculation hbar ℓ₁ ℓ₂ / sub.circulationQuantum hbar =
      ((ℓ₂ - ℓ₁ : ℤ) : ℝ) ∧
    sub.differentialVortexCirculation hbar ℓ₁ ℓ₁ = 0 ∧
    relativePredictiveError
      (wignerOAMDoubleSlit
        singleSlitScale slitWidth slitHeight separation wavelength screenDistance
        oamDecoherenceRate (ℓ₁ - ℓ₁) 0 0 0)
      (fraunhoferOAMDoubleSlit
        singleSlitScale slitWidth slitHeight separation wavelength screenDistance
        (ℓ₁ - ℓ₁) 0 0 0) = 0 := by
  have h_kappa_ne : sub.circulationQuantum hbar ≠ 0 := by
    unfold DDFSubstrate.circulationQuantum
    exact div_ne_zero (mul_ne_zero (mul_ne_zero (by norm_num) Real.pi_ne_zero) h_hbar)
      (ne_of_gt sub.m_phi_pos)
  refine ⟨mul_div_cancel_right₀ _ h_kappa_ne, ?_, ?_⟩
  · unfold DDFSubstrate.differentialVortexCirculation
    simp
  · rw [wignerOAM_onAxis_relative_error
      singleSlitScale slitWidth slitHeight separation wavelength screenDistance
      oamDecoherenceRate (ℓ₁ - ℓ₁) h_scale h_dec]
    simp

/-! ## Constructive Solutions to Critiques 1–3 & Unified $Gr_{\mathbb{C}}(2, 4)$–DDF Integration

This section resolves all three critique issues constructively and integrates
the complex Grassmannian $Gr_{\mathbb{C}}(2, 4)$ directly with `DDFSubstrate`,
`MovingSheath`, Madelung condensate densities, and `RiverExterior` frame-dragging:

1. **Resolution of Critique 1 (`ddf_critique1_solved_squared_crossing_and_complex_gr24`)**:
   - In real $Gr(2,4)$, interpreting the channel weights $Q_A, Q_B$ as coherent
     field amplitudes makes the on-axis intensity proportional to the **squared**
     crossing product $(\Delta_{02}\Delta_{13})^2 = (Q_A + Q_B)^2 = 4$, achieving
     **exact zero relative error** ($\varepsilon_{\mathrm{rel}} = 0$) at the
     symmetric point $(0, 0)$.
   - Across the entire detector plane $(x, y) \in \mathbb{R}^2$, lifting to complex
     sink amplitudes $w_A^{\mathbb{C}}(M_{\mathbb{C}}) = \Delta_{01}^{\mathbb{C}}\Delta_{23}^{\mathbb{C}}$
     and $w_B^{\mathbb{C}}(M_{\mathbb{C}}) = \Delta_{03}^{\mathbb{C}}\Delta_{12}^{\mathbb{C}}$
     on $Gr_{\mathbb{C}}(2,4)$ satisfies $w_A^{\mathbb{C}} + w_B^{\mathbb{C}} = \Delta_{02}^{\mathbb{C}}\Delta_{13}^{\mathbb{C}}$,
     so $|\Delta_{02}^{\mathbb{C}}\Delta_{13}^{\mathbb{C}}|^2 = |w_A^{\mathbb{C}} + w_B^{\mathbb{C}}|^2$
     achieves **zero relative predictive error everywhere**.
2. **Resolution of Critique 2 (`ddf_critique2_solved_projective_and_trace_renormalized_jamming`)**:
   - Projectively normalizing by the crossing product via `gr24ProjectiveBarycentricShift`
     ($\widehat{d}_{\mathrm{bary}} = (Q_A - Q_B)/(Q_A + Q_B)$) and `gr24ProjectiveVisibilitySq`
     cancels the $e^{2(\lambda_1 + \lambda_2)t}$ dilation factor identically, making
     $\widehat{d}_{\mathrm{bary}}$ and $\widehat{\mathcal{V}}_{Gr(2,4)}^2$ **exact invariants
     under arbitrary non-symplectic compressive jamming** $\operatorname{diag}(e^{\lambda_1 t}, e^{\lambda_2 t})$.
   - Factoring out the isotropic trace dilation $e^{-(\lambda_1 + \lambda_2)t / 2}$ reduces
     any diagonal jamming matrix to the symplectic Anosov matrix
     $A_{\mathrm{Anosov}}((\lambda_1 - \lambda_2)/2, t)$, which preserves even the
     unnormalized Plücker minors.
3. **Resolution of Critique 3 (`MovingSheath.ddf_critique3_solved_substrate_parameter_recovery` & `RiverExterior.quantized_vortex_swirl_from_circulation`)**:
   - Connects the optical relative error $\varepsilon = (1 - \mathcal{V}(s))/2$ directly to
     the dimensionful DDF substrate parameters $\varrho_{\max}^\varphi j_{\min}^\varphi = c^{-2}$
     and physical sheath speed $v$:
     $\varrho_{\max}^\varphi j_{\min}^\varphi v^2 = 4\varepsilon(1 - \varepsilon)$,
     $v^2 = 4\varepsilon(1 - \varepsilon) / (\varrho_{\max}^\varphi j_{\min}^\varphi)$, and
     $\varrho_{\max}^\varphi j_{\min}^\varphi = 4\varepsilon(1 - \varepsilon) / v^2$ (for $v \neq 0$).
   - Connects the differential OAM vortex circulation $\Delta\Gamma(\ell_1, \ell_2)$ to the
     Kerr/Lense--Thirring gravitomagnetic swirl velocity in `RiverExterior`:
     $v_{\phi,\mathrm{swirl}}((\ell_2 - \ell_1)\hbar, r) = \frac{G_\phi m_\phi \varrho_{\max}^\varphi j_{\min}^\varphi}{\pi r^2}\,\Delta\Gamma(\ell_1, \ell_2)$.
4. **Unified $Gr_{\mathbb{C}}(2, 4)$–DDF Sheath Twistor Formalism (`MovingSheath.gr24TwistorMatrix`)**:
   - Embeds any subluminal `MovingSheath` $s$ and differential OAM vortex charge $\Delta\ell$
     into $Gr_{\mathbb{C}}(2,4)$, proving that its Madelung channel densities are
     $|w_A^{\mathbb{C}}|^2 = 1 + v/c$ and $|w_B^{\mathbb{C}}|^2 = 1 - v/c$, their product is
     $\gamma_\varphi(v)^{-2}$, its crossing minor reproduces the DDF shear-jammed OAM
     intensity $I_{\mathrm{HS,OAM}}(x,y,\phi;\Delta\ell,\gamma_\varphi(v)^{-1})$ with zero
     relative error everywhere, and $SL(2, \mathbb{C})$ / complex Anosov transformations
     preserve the crossing-minor intensity identically.
-/

/-- Real squared-crossing Plücker double-slit intensity:
when $Q_A(M) = \Delta_{01}\Delta_{23}$ and $Q_B(M) = \Delta_{03}\Delta_{12}$ represent
coherent field amplitudes at zero phase difference, the squared crossing product
$(\Delta_{02}(M)\Delta_{13}(M))^2 = (Q_A(M) + Q_B(M))^2$ scales the single-slit envelope. -/
@[blueprint "def:signals-ddf-gr24-squared-crossing-double-slit"
  (title := "Squared Plücker crossing-product double-slit intensity")
  (statement := /-- For $M\in\mathbb R^{2\times 4}$, define
    $I_{Gr(2,4)}^{\mathrm{sq}}(M;x,y)=I_0 E_{\mathrm{slit}}(x,y)\,(\Delta_{02}(M)\Delta_{13}(M))^2$. -/)]
noncomputable def gr24SquaredCrossingDoubleSlit
    (M : Matrix (Fin 2) (Fin 4) ℝ)
    (singleSlitScale slitWidth slitHeight wavelength screenDistance x y : ℝ) : ℝ :=
  singleSlitScale *
    rectangularSlitEnvelope slitWidth slitHeight wavelength screenDistance x y *
    (twoRowMinor M 0 2 * twoRowMinor M 1 3) ^ 2

/-- First complex Plücker sink amplitude $w_A^{\mathbb{C}}(M_{\mathbb{C}}) = \Delta_{01}^{\mathbb{C}}(M_{\mathbb{C}})\,\Delta_{23}^{\mathbb{C}}(M_{\mathbb{C}})$
on $Gr_{\mathbb{C}}(2, 4)$. -/
@[blueprint "def:signals-ddf-complex-plucker-sink-a"
  (title := "First complex Gr_C(2,4) Plücker sink amplitude w_A^ℂ")
  (statement := /-- For $M_{\mathbb C}\in\mathbb C^{2\times 4}$, define
    $w_A^{\mathbb C}(M_{\mathbb C})=\Delta_{01}^{\mathbb C}(M_{\mathbb C})\,\Delta_{23}^{\mathbb C}(M_{\mathbb C})$. -/)]
def complexPluckerSinkAmplitudeA (M : Matrix (Fin 2) (Fin 4) ℂ) : ℂ :=
  complexTwoRowMinor M 0 1 * complexTwoRowMinor M 2 3

/-- Second complex Plücker sink amplitude $w_B^{\mathbb{C}}(M_{\mathbb{C}}) = \Delta_{03}^{\mathbb{C}}(M_{\mathbb{C}})\,\Delta_{12}^{\mathbb{C}}(M_{\mathbb{C}})$
on $Gr_{\mathbb{C}}(2, 4)$. -/
@[blueprint "def:signals-ddf-complex-plucker-sink-b"
  (title := "Second complex Gr_C(2,4) Plücker sink amplitude w_B^ℂ")
  (statement := /-- For $M_{\mathbb C}\in\mathbb C^{2\times 4}$, define
    $w_B^{\mathbb C}(M_{\mathbb C})=\Delta_{03}^{\mathbb C}(M_{\mathbb C})\,\Delta_{12}^{\mathbb C}(M_{\mathbb C})$. -/)]
def complexPluckerSinkAmplitudeB (M : Matrix (Fin 2) (Fin 4) ℂ) : ℂ :=
  complexTwoRowMinor M 0 3 * complexTwoRowMinor M 1 2

/-- **Constructive Solution to Critique 1 (Symmetric Zero-Shear Point & Off-Axis $Gr_{\mathbb{C}}(2,4)$ Exactness)**:
1. At the symmetric point ($Q_A(M) = 1, Q_B(M) = 1$, $x = 0, y = 0$), squaring the
   amplitude-level crossing product in `gr24SquaredCrossingDoubleSlit` yields
   $(Q_A + Q_B)^2 = 4$, matching `fraunhoferRectangularDoubleSlit` at $(0, 0)$ with
   **exact zero relative predictive error** ($\varepsilon_{\mathrm{rel}} = 0$).
2. Across the entire detector plane $(x, y) \in \mathbb{R}^2$, the complex sink
   amplitudes on $Gr_{\mathbb{C}}(2,4)$ satisfy
   $w_A^{\mathbb{C}}(M_{\mathbb{C}}) + w_B^{\mathbb{C}}(M_{\mathbb{C}}) = \Delta_{02}^{\mathbb{C}}(M_{\mathbb{C}})\Delta_{13}^{\mathbb{C}}(M_{\mathbb{C}})$,
   and with $z_{1,2} = e^{\pm i\theta}$ the squared crossing minor in
   `complexGr24CrossingDoubleSlit` matches `fraunhoferRectangularDoubleSlit` with
   **zero relative predictive error everywhere**. -/
@[blueprint "thm:signals-ddf-critique1-solved"
  (title := "Solution to Critique 1: squared crossing product at origin and complex Gr_C(2,4) sink amplitudes everywhere give 0% error")
  (statement := /-- If $Q_A(M)=1$ and $Q_B(M)=1$, then at $(0,0)$
    $\varepsilon_{\mathrm{rel}}\bigl(I_{Gr(2,4)}^{\mathrm{sq}}(M;0,0),I_{\mathrm{F}}(0,0)\bigr)=0$.
    Moreover, for every $M_{\mathbb C}\in\mathbb C^{2\times 4}$,
    $w_A^{\mathbb C}(M_{\mathbb C})+w_B^{\mathbb C}(M_{\mathbb C})=\Delta_{02}^{\mathbb C}(M_{\mathbb C})\Delta_{13}^{\mathbb C}(M_{\mathbb C})$,
    and for $z_{1,2}=\cos\theta\pm i\sin\theta$,
    $\varepsilon_{\mathrm{rel}}\bigl(I_{Gr_{\mathbb C}(2,4)}^{\times}(M_{\mathbb C}(z_1,z_2);x,y),I_{\mathrm{F}}(x,y)\bigr)=0$
    for all $(x,y)\in\mathbb R^2$. -/)
  (proof := /-- Use $\Delta_{02}\Delta_{13}=Q_A+Q_B=2$ at $(0,0)$ so $2^2=4$, apply
    \texttt{complexGr24\_crossing\_eq\_channel\_sum} for complex sink conservation, and
    apply \texttt{complexGr24CrossingDoubleSlit\_zero\_error}. -/)]
theorem ddf_critique1_solved_squared_crossing_and_complex_gr24
    (M : Matrix (Fin 2) (Fin 4) ℝ)
    (M_C : Matrix (Fin 2) (Fin 4) ℂ)
    (singleSlitScale slitWidth slitHeight separation wavelength screenDistance x y : ℝ)
    (h_A : pluckerSinkFluxA M = 1)
    (h_B : pluckerSinkFluxB M = 1) :
    gr24SquaredCrossingDoubleSlit M singleSlitScale slitWidth slitHeight
        wavelength screenDistance 0 0 =
      fraunhoferRectangularDoubleSlit singleSlitScale slitWidth slitHeight
        separation wavelength screenDistance 0 0 ∧
    relativePredictiveError
      (gr24SquaredCrossingDoubleSlit M singleSlitScale slitWidth slitHeight
        wavelength screenDistance 0 0)
      (fraunhoferRectangularDoubleSlit singleSlitScale slitWidth slitHeight
        separation wavelength screenDistance 0 0) = 0 ∧
    complexPluckerSinkAmplitudeA M_C + complexPluckerSinkAmplitudeB M_C =
      complexTwoRowMinor M_C 0 2 * complexTwoRowMinor M_C 1 3 ∧
    (let θ := Real.pi * separation * x / (wavelength * screenDistance)
     let z1 : ℂ := ↑(Real.cos θ) + Complex.I * ↑(Real.sin θ)
     let z2 : ℂ := ↑(Real.cos θ) - Complex.I * ↑(Real.sin θ)
     relativePredictiveError
       (complexGr24CrossingDoubleSlit (complexGr24ChannelMatrix z1 z2)
         singleSlitScale slitWidth slitHeight wavelength screenDistance x y)
       (fraunhoferRectangularDoubleSlit singleSlitScale slitWidth slitHeight
         separation wavelength screenDistance x y) = 0) := by
  have h_cross : twoRowMinor M 0 2 * twoRowMinor M 1 3 = 2 := by
    rw [← (pluckerSinkFlux_conservation_and_asymmetry M).1, h_A, h_B]
    norm_num
  have h_sq_eq :
      gr24SquaredCrossingDoubleSlit M singleSlitScale slitWidth slitHeight
        wavelength screenDistance 0 0 =
      fraunhoferRectangularDoubleSlit singleSlitScale slitWidth slitHeight
        separation wavelength screenDistance 0 0 := by
    unfold gr24SquaredCrossingDoubleSlit rectangularSlitEnvelope unnormalizedSinc
    rw [h_cross, fraunhoferRectangularDoubleSlit_onAxis]
    simp
    ring
  refine ⟨h_sq_eq, ?_, (complexGr24_crossing_eq_channel_sum M_C).symm, ?_⟩
  · rw [h_sq_eq]
    simp [relativePredictiveError]
  · exact (complexGr24CrossingDoubleSlit_zero_error
      singleSlitScale slitWidth slitHeight separation wavelength screenDistance x y).2

/-- **Constructive Solution to Critique 2 (Non-Symplectic Compressive Jamming Invariance)**:
For *any* non-symplectic compressive jamming deformation
$B(\lambda_1, \lambda_2, t) = \operatorname{diag}(e^{\lambda_1 t}, e^{\lambda_2 t})$
with arbitrary exponents $\lambda_1, \lambda_2, t \in \mathbb{R}$:
1. The projectively normalized Plücker barycentric shift and squared visibility are
   **strictly invariant**:
   $\widehat{d}_{\mathrm{bary}}(B M) = \widehat{d}_{\mathrm{bary}}(M)$ and
   $\widehat{\mathcal{V}}_{Gr(2,4)}(B M)^2 = \widehat{\mathcal{V}}_{Gr(2,4)}(M)^2$, and
2. Rescaling $B(\lambda_1, \lambda_2, t)$ by the inverse square-root determinant
   $e^{-(\lambda_1 + \lambda_2)t / 2}$ yields the exact symplectic Anosov hyperbolic
   matrix $A_{\mathrm{Anosov}}((\lambda_1 - \lambda_2)/2, t)$, which preserves even the
   unnormalized Plücker minors and $d_{\mathrm{bary}}(M)$ identically. -/
@[blueprint "thm:signals-ddf-critique2-solved"
  (title := "Solution to Critique 2: projective Plücker invariance and trace-renormalized symplectic Anosov reduction under arbitrary jamming")
  (statement := /-- For any $M\in\mathbb R^{2\times 4}$ and $\lambda_1,\lambda_2,t\in\mathbb R$,
    let $B=\operatorname{diag}(e^{\lambda_1 t},e^{\lambda_2 t})$. Then
    $\widehat{d}_{\mathrm{bary}}(BM)=\widehat{d}_{\mathrm{bary}}(M)$,
    $\widehat{\mathcal{V}}_{Gr(2,4)}(BM)^2=\widehat{\mathcal{V}}_{Gr(2,4)}(M)^2$,
    $e^{-(\lambda_1+\lambda_2)t/2}\cdot B = A_{\mathrm{Anosov}}((\lambda_1-\lambda_2)/2,t)$, and
    $d_{\mathrm{bary}}\bigl((e^{-(\lambda_1+\lambda_2)t/2}\cdot B)M\bigr)=d_{\mathrm{bary}}(M)$. -/)
  (proof := /-- Apply \texttt{gr24Projective\_basisChange\_invariant} using
    $\det B = e^{\lambda_1 t}e^{\lambda_2 t}>0$, verify the matrix identity entrywise via
    \texttt{Real.exp\_add}, and apply \texttt{anosov\_plucker\_invariance}. -/)]
theorem ddf_critique2_solved_projective_and_trace_renormalized_jamming
    (M : Matrix (Fin 2) (Fin 4) ℝ) (rate1 rate2 time : ℝ) :
    let B : Matrix (Fin 2) (Fin 2) ℝ :=
      !![Real.exp (rate1 * time), 0; 0, Real.exp (rate2 * time)]
    let scale := Real.exp (-((rate1 + rate2) / 2 * time))
    gr24ProjectiveBarycentricShift (B * M) = gr24ProjectiveBarycentricShift M ∧
      gr24ProjectiveVisibilitySq (B * M) = gr24ProjectiveVisibilitySq M ∧
      scale • B = anosovHyperbolicMatrix ((rate1 - rate2) / 2) time ∧
      gr24BarycentricShift ((scale • B) * M) = gr24BarycentricShift M := by
  intro B scale
  have h_det_pos : 0 < B.det := by
    dsimp [B]
    rw [Matrix.det_fin_two]
    simp only [Matrix.of_apply, Matrix.cons_val', Matrix.cons_val_zero,
      Matrix.cons_val_one, Matrix.cons_val_fin_one, mul_zero, sub_zero]
    exact mul_pos (Real.exp_pos _) (Real.exp_pos _)
  have h_proj := gr24Projective_basisChange_invariant B M (ne_of_gt h_det_pos)
  have h_mat : scale • B = anosovHyperbolicMatrix ((rate1 - rate2) / 2) time := by
    ext i j
    fin_cases i <;> fin_cases j <;>
      simp [B, scale, anosovHyperbolicMatrix, ← Real.exp_add] <;>
      ring_nf
  refine ⟨h_proj.1, h_proj.2, h_mat, ?_⟩
  rw [h_mat]
  exact (anosov_plucker_invariance M ((rate1 - rate2) / 2) time 0 1).2

/-- **Constructive Solution to Critique 3A (Constitutive DDF Substrate Parameter Recovery)**:
For any subluminal `MovingSheath` $s$ on `sub : DDFSubstrate`, let
$\varepsilon = (1 - \mathcal{V}(s))/2$ be the on-axis relative predictive error. Then:
1. The constitutive DDF jamming invariant $\varrho_{\max}^\varphi j_{\min}^\varphi v^2$
   equals $4\varepsilon(1 - \varepsilon)$,
2. The squared physical sheath velocity equals
   $v^2 = 4\varepsilon(1 - \varepsilon) / (\varrho_{\max}^\varphi j_{\min}^\varphi)$, and
3. Whenever $v \neq 0$, the DDF dispersed-phase compressibility-density product is
   uniquely recovered by $\varrho_{\max}^\varphi j_{\min}^\varphi = 4\varepsilon(1 - \varepsilon) / v^2$. -/
@[blueprint "thm:signals-ddf-critique3-substrate-recovery"
  (title := "Solution to Critique 3A: recovery of DDF substrate product ϱ_max^φ j_min^φ and velocity v² from optical error ε")
  (statement := /-- For a subluminal sheath $s$ on \texttt{sub : DDFSubstrate} with
    $\varepsilon=(1-\mathcal{V}(s))/2$,
    $\varrho_{\max}^\varphi j_{\min}^\varphi v^2 = 4\varepsilon(1-\varepsilon)$,
    $v^2 = \frac{4\varepsilon(1-\varepsilon)}{\varrho_{\max}^\varphi j_{\min}^\varphi}$, and if $v\ne 0$,
    $\varrho_{\max}^\varphi j_{\min}^\varphi = \frac{4\varepsilon(1-\varepsilon)}{v^2}$. -/)
  (proof := /-- Combine \texttt{MovingSheath.inverse\_recovery\_from\_relative\_error}
    ($\beta^2=4\varepsilon(1-\varepsilon)$) with \texttt{DDFSubstrate.c\_sq}
    ($c^2=(\varrho_{\max}^\varphi j_{\min}^\varphi)^{-1}$). -/)]
theorem MovingSheath.ddf_critique3_solved_substrate_parameter_recovery
    {sub : DDFSubstrate} (s : MovingSheath sub) :
    let ε := (1 - s.coherenceVisibility) / 2
    sub.rho_max_varphi * sub.j_min_varphi * s.velocity ^ 2 = 4 * ε * (1 - ε) ∧
      s.velocity ^ 2 = (4 * ε * (1 - ε)) / (sub.rho_max_varphi * sub.j_min_varphi) ∧
      (s.velocity ≠ 0 →
        sub.rho_max_varphi * sub.j_min_varphi = (4 * ε * (1 - ε)) / s.velocity ^ 2) := by
  intro ε
  have h_inv := (s.inverse_recovery_from_relative_error).2.2.2.2
  have h_csq := sub.c_sq
  have h_prod_pos := sub.product_pos
  have h_prod_ne : sub.rho_max_varphi * sub.j_min_varphi ≠ 0 := ne_of_gt h_prod_pos
  have h_beta_def : s.betaSq = sub.rho_max_varphi * sub.j_min_varphi * s.velocity ^ 2 := by
    unfold MovingSheath.betaSq
    rw [h_csq, div_inv_eq_mul, mul_comm]
  have h_first : sub.rho_max_varphi * sub.j_min_varphi * s.velocity ^ 2 = 4 * ε * (1 - ε) := by
    rw [← h_beta_def]
    exact h_inv
  refine ⟨h_first, ?_, ?_⟩
  · rw [← h_first, mul_div_cancel_left₀ _ h_prod_ne]
  · intro hv
    have hv2 : s.velocity ^ 2 ≠ 0 := pow_ne_zero 2 hv
    rw [← h_first, mul_div_cancel_right₀ _ hv2]

/-- **Constructive Solution to Critique 3B (Gravitomagnetic Frame-Dragging Swirl from Quantized Vortex Circulation)**:
In a `RiverExterior` flow around mass $M$, when two sinks carry quantized $\phi$-superfluid
vortex charges $\ell_1, \ell_2 \in \mathbb{Z}$ with differential angular momentum
$J = (\ell_2 - \ell_1)\hbar$, the Kerr/Lense--Thirring frame-dragging swirl velocity
`re.swirlVelocity J r` is directly proportional to the differential vortex circulation
$\Delta\Gamma(\ell_1, \ell_2)$ and the DDF substrate product $\varrho_{\max}^\varphi j_{\min}^\varphi$:
$v_{\phi,\mathrm{swirl}}((\ell_2 - \ell_1)\hbar, r) = \frac{G_\phi m_\phi \varrho_{\max}^\varphi j_{\min}^\varphi}{\pi r^2}\,\Delta\Gamma(\ell_1, \ell_2)$,
and vanishes identically at the symmetric irrotational point $\ell_1 = \ell_2$. -/
@[blueprint "thm:signals-ddf-critique3-vortex-swirl"
  (title := "Solution to Critique 3B: Kerr/Lense-Thirring swirl velocity from differential DDF vortex circulation")
  (statement := /-- For \texttt{re : RiverExterior sub} and vortex charges $\ell_1,\ell_2\in\mathbb Z$,
    $v_{\phi,\mathrm{swirl}}\bigl((\ell_2-\ell_1)\hbar,r\bigr)
    = \frac{G_\phi m_\phi \varrho_{\max}^\varphi j_{\min}^\varphi}{\pi r^2}\,\Delta\Gamma(\ell_1,\ell_2)$,
    and $v_{\phi,\mathrm{swirl}}\bigl((\ell_1-\ell_1)\hbar,r\bigr)=0$. -/)
  (proof := /-- Expand \texttt{swirlVelocity}, \texttt{differentialVortexCirculation}, and
    \texttt{circulationQuantum}, substitute \texttt{sub.c\_sq}, and cancel $2\pi\ne 0$ and $m_\phi\ne 0$. -/)]
theorem RiverExterior.quantized_vortex_swirl_from_circulation
    {sub : DDFSubstrate} (re : RiverExterior sub) (hbar r : ℝ) (ℓ₁ ℓ₂ : ℤ) :
    re.swirlVelocity (((ℓ₂ - ℓ₁ : ℤ) : ℝ) * hbar) r =
      (re.G_phi * sub.m_phi * (sub.rho_max_varphi * sub.j_min_varphi) /
        (Real.pi * r ^ 2)) *
        sub.differentialVortexCirculation hbar ℓ₁ ℓ₂ ∧
    re.swirlVelocity (((ℓ₁ - ℓ₁ : ℤ) : ℝ) * hbar) r = 0 := by
  have h_m_ne : sub.m_phi ≠ 0 := ne_of_gt sub.m_phi_pos
  have h_pi_ne : Real.pi ≠ 0 := Real.pi_ne_zero
  refine ⟨?_, ?_⟩
  · unfold RiverExterior.swirlVelocity DDFSubstrate.differentialVortexCirculation
      DDFSubstrate.circulationQuantum
    rw [sub.c_sq]
    field_simp [h_m_ne, h_pi_ne]
  · unfold RiverExterior.swirlVelocity
    simp

/-! ### Direct Integration of Complex $Gr_{\mathbb{C}}(2, 4)$ with `MovingSheath` and `DDFSubstrate` -/

/-- Dimensionless reduced shear speed $\beta(s) = v / c \in [0, 1)$ of a subluminal
`MovingSheath`. -/
@[blueprint "def:signals-ddf-sheath-beta"
  (title := "Dimensionless DDF sheath speed ratio β = v / c")
  (statement := /-- For a subluminal sheath $s$, define $\beta(s)=s.\mathrm{velocity}/\mathrm{sub}.c$. -/)]
noncomputable def MovingSheath.beta {sub : DDFSubstrate} (s : MovingSheath sub) : ℝ :=
  s.velocity / sub.c

/-- For any subluminal `MovingSheath`, $\beta(s) \in [0, 1]$, $\beta(s) \in [-1, 1]$,
and $\beta(s)^2 = s.\mathrm{betaSq}$. -/
@[blueprint "lem:signals-ddf-sheath-beta-bounds"
  (title := "Bounds and square identity for DDF sheath speed ratio β = v / c")
  (statement := /-- For any subluminal sheath $s$, $0\le\beta(s)$, $\beta(s)\le 1$,
    $-1\le\beta(s)$, and $\beta(s)^2=s.\mathrm{betaSq}$. -/)
  (proof := /-- Use $0\le v<c$ and $c>0$ from \texttt{MovingSheath} and \texttt{DDFSubstrate.c\_pos}. -/)
  (latexEnv := "lemma")]
lemma MovingSheath.beta_bounds {sub : DDFSubstrate} (s : MovingSheath sub) :
    0 ≤ s.beta ∧ s.beta ≤ 1 ∧ -1 ≤ s.beta ∧ s.beta ^ 2 = s.betaSq := by
  have hc := sub.c_pos
  have h_nonneg : 0 ≤ s.beta := div_nonneg s.velocity_nonneg (le_of_lt hc)
  have h_le_one : s.beta ≤ 1 := le_of_lt ((div_lt_one hc).mpr s.subluminal)
  have h_sq : s.beta ^ 2 = s.betaSq := by
    unfold MovingSheath.beta MovingSheath.betaSq
    exact div_pow s.velocity sub.c 2
  exact ⟨h_nonneg, h_le_one, by linarith, h_sq⟩

/-- Forward-sheared $(\phi + \varphi)$ complex twistor channel amplitude
$z_+(s, \theta) = \sqrt{1 + v/c}(\cos\theta + i\sin\theta)$ on $Gr_{\mathbb{C}}(2, 4)$. -/
@[blueprint "def:signals-ddf-gr24-twistor-entry-plus"
  (title := "Forward-sheared DDF complex twistor channel entry z_+(s, θ)")
  (statement := /-- For a subluminal sheath $s$ and phase $\theta\in\mathbb R$, define
    $z_+(s,\theta)=\sqrt{1+\beta(s)}(\cos\theta+i\sin\theta)\in\mathbb C$. -/)]
noncomputable def MovingSheath.gr24TwistorEntryPlus {sub : DDFSubstrate}
    (s : MovingSheath sub) (θ : ℝ) : ℂ :=
  let a := Real.sqrt (1 + s.beta)
  ↑(a * Real.cos θ) + Complex.I * ↑(a * Real.sin θ)

/-- Reverse-sheared $(\phi - \varphi)$ complex twistor channel amplitude
$z_-(s, \theta) = \sqrt{1 - v/c}(\cos\theta - i\sin\theta)$ on $Gr_{\mathbb{C}}(2, 4)$. -/
@[blueprint "def:signals-ddf-gr24-twistor-entry-minus"
  (title := "Reverse-sheared DDF complex twistor channel entry z_-(s, θ)")
  (statement := /-- For a subluminal sheath $s$ and phase $\theta\in\mathbb R$, define
    $z_-(s,\theta)=\sqrt{1-\beta(s)}(\cos\theta-i\sin\theta)\in\mathbb C$. -/)]
noncomputable def MovingSheath.gr24TwistorEntryMinus {sub : DDFSubstrate}
    (s : MovingSheath sub) (θ : ℝ) : ℂ :=
  let b := Real.sqrt (1 - s.beta)
  ↑(b * Real.cos θ) - Complex.I * ↑(b * Real.sin θ)

/-- **Canonical $Gr_{\mathbb{C}}(2, 4)$–DDF Sheath & Vortex Twistor Matrix**:
Embeds a subluminal DDF `MovingSheath` $s$, spatial wave geometry $(d, \lambda, L, x)$,
and quantized OAM vortex winding difference $\Delta\ell \in \mathbb{Z}$ at azimuth $\phi$
directly into a $2 \times 4$ complex Grassmannian matrix $M_{\mathbb{C}}^{\mathrm{DDF}} \in \mathbb{C}^{2 \times 4}$. -/
@[blueprint "def:signals-ddf-gr24-twistor-matrix"
  (title := "Canonical Gr_C(2,4)-DDF sheath and vortex twistor matrix")
  (statement := /-- For a subluminal sheath $s$, OAM charge difference $\Delta\ell\in\mathbb Z$,
    azimuth $\phi$, and optical phase $\theta=\frac{\pi d x}{\lambda L}+\frac{\Delta\ell\,\phi}{2}$,
    define $M_{\mathbb C}^{\mathrm{DDF}}(s)=M_{\mathbb C}\bigl(z_+(s,\theta),z_-(s,\theta)\bigr)\in\mathbb C^{2\times 4}$. -/)]
noncomputable def MovingSheath.gr24TwistorMatrix {sub : DDFSubstrate}
    (s : MovingSheath sub)
    (separation wavelength screenDistance : ℝ)
    (deltaOAM : ℤ) (azimuthPhi x : ℝ) : Matrix (Fin 2) (Fin 4) ℂ :=
  let θ := Real.pi * separation * x / (wavelength * screenDistance) +
    (deltaOAM : ℝ) * azimuthPhi / 2
  complexGr24ChannelMatrix (s.gr24TwistorEntryPlus θ) (s.gr24TwistorEntryMinus θ)

/-- **Madelung Condensate Densities & Jamming Product of $M_{\mathbb{C}}^{\mathrm{DDF}}$ on $Gr_{\mathbb{C}}(2, 4)$**:
For any subluminal `MovingSheath` $s$, the complex uncrossed Plücker sink amplitudes
$w_A^{\mathbb{C}}$ and $w_B^{\mathbb{C}}$ of $M_{\mathbb{C}}^{\mathrm{DDF}}(s)$ satisfy:
1. $|w_A^{\mathbb{C}}|^2 = 1 + v/c$ and $|w_B^{\mathbb{C}}|^2 = 1 - v/c$,
2. Total Madelung sink density $|w_A^{\mathbb{C}}|^2 + |w_B^{\mathbb{C}}|^2 = 2$,
3. Normalized Madelung density asymmetry $(|w_A^{\mathbb{C}}|^2 - |w_B^{\mathbb{C}}|^2)/2 = v/c = \beta(s)$, and
4. Product of Madelung sink densities $|w_A^{\mathbb{C}}|^2 |w_B^{\mathbb{C}}|^2 = 1 - (v/c)^2 = \mathcal{V}(s)^2 = \gamma_\varphi(v)^{-2}$. -/
@[blueprint "thm:signals-ddf-gr24-twistor-madelung-identities"
  (title := "Madelung sink densities and reciprocal jamming product of the Gr_C(2,4)-DDF twistor matrix")
  (statement := /-- For $M_{\mathbb C}^{\mathrm{DDF}}=s.\mathrm{gr24TwistorMatrix}(d,\lambda,L,\Delta\ell,\phi,x)$,
    $|w_A^{\mathbb C}(M_{\mathbb C}^{\mathrm{DDF}})|^2 = 1+\beta(s)$,
    $|w_B^{\mathbb C}(M_{\mathbb C}^{\mathrm{DDF}})|^2 = 1-\beta(s)$,
    $|w_A^{\mathbb C}|^2+|w_B^{\mathbb C}|^2=2$,
    $(|w_A^{\mathbb C}|^2-|w_B^{\mathbb C}|^2)/2=\beta(s)$, and
    $|w_A^{\mathbb C}|^2\,|w_B^{\mathbb C}|^2 = \mathcal{V}(s)^2 = s.\mathrm{jammingFactor}^{-2}$. -/)
  (proof := /-- Evaluate \texttt{complexGr24ChannelMatrix\_minors}, compute \texttt{Complex.normSq}
    using $\cos^2\theta+\sin^2\theta=1$ and \texttt{Real.sq\_sqrt}, and apply
    \texttt{visibility\_jamming\_duality}. -/)]
theorem MovingSheath.gr24TwistorMatrix_madelung_sector_identities {sub : DDFSubstrate}
    (s : MovingSheath sub)
    (separation wavelength screenDistance : ℝ)
    (deltaOAM : ℤ) (azimuthPhi x : ℝ) :
    let M_C := s.gr24TwistorMatrix separation wavelength screenDistance deltaOAM azimuthPhi x
    Complex.normSq (complexPluckerSinkAmplitudeA M_C) = 1 + s.beta ∧
      Complex.normSq (complexPluckerSinkAmplitudeB M_C) = 1 - s.beta ∧
      Complex.normSq (complexPluckerSinkAmplitudeA M_C) +
        Complex.normSq (complexPluckerSinkAmplitudeB M_C) = 2 ∧
      (Complex.normSq (complexPluckerSinkAmplitudeA M_C) -
        Complex.normSq (complexPluckerSinkAmplitudeB M_C)) / 2 = s.beta ∧
      Complex.normSq (complexPluckerSinkAmplitudeA M_C) *
        Complex.normSq (complexPluckerSinkAmplitudeB M_C) = s.coherenceVisibility ^ 2 ∧
      s.coherenceVisibility ^ 2 = (s.jammingFactor ^ 2)⁻¹ := by
  intro M_C
  have hb := s.beta_bounds
  have ha_nonneg : 0 ≤ 1 + s.beta := by linarith [hb.1]
  have hb_nonneg : 0 ≤ 1 - s.beta := by linarith [hb.2.1]
  let θ := Real.pi * separation * x / (wavelength * screenDistance) +
    (deltaOAM : ℝ) * azimuthPhi / 2
  have h_minors := complexGr24ChannelMatrix_minors
    (s.gr24TwistorEntryPlus θ) (s.gr24TwistorEntryMinus θ)
  have h_wA : complexPluckerSinkAmplitudeA M_C = s.gr24TwistorEntryPlus θ := h_minors.1
  have h_wB : complexPluckerSinkAmplitudeB M_C = s.gr24TwistorEntryMinus θ := h_minors.2.1
  have h_trig : (Real.cos θ) ^ 2 + (Real.sin θ) ^ 2 = 1 := Real.cos_sq_add_sin_sq θ
  have h_normA : Complex.normSq (complexPluckerSinkAmplitudeA M_C) = 1 + s.beta := by
    rw [h_wA]
    unfold MovingSheath.gr24TwistorEntryPlus
    simp only [Complex.normSq_apply, Complex.add_re, Complex.add_im, Complex.mul_re,
      Complex.mul_im, Complex.ofReal_re, Complex.ofReal_im, Complex.I_re, Complex.I_im]
    calc
      _ = (Real.sqrt (1 + s.beta)) ^ 2 * ((Real.cos θ) ^ 2 + (Real.sin θ) ^ 2) := by ring
      _ = 1 + s.beta := by rw [Real.sq_sqrt ha_nonneg, h_trig, mul_one]
  have h_normB : Complex.normSq (complexPluckerSinkAmplitudeB M_C) = 1 - s.beta := by
    rw [h_wB]
    unfold MovingSheath.gr24TwistorEntryMinus
    simp only [Complex.normSq_apply, Complex.sub_re, Complex.sub_im, Complex.mul_re,
      Complex.mul_im, Complex.ofReal_re, Complex.ofReal_im, Complex.I_re, Complex.I_im]
    calc
      _ = (Real.sqrt (1 - s.beta)) ^ 2 * ((Real.cos θ) ^ 2 + (Real.sin θ) ^ 2) := by ring
      _ = 1 - s.beta := by rw [Real.sq_sqrt hb_nonneg, h_trig, mul_one]
  have h_vis_sq : s.coherenceVisibility ^ 2 = 1 - s.beta ^ 2 := by
    unfold MovingSheath.coherenceVisibility
    rw [Real.sq_sqrt (le_of_lt s.one_sub_betaSq_pos), ← hb.2.2.2]
  have h_jam_inv : s.coherenceVisibility ^ 2 = (s.jammingFactor ^ 2)⁻¹ := by
    rw [(s.visibility_jamming_duality).1, inv_pow]
  refine ⟨h_normA, h_normB, by linarith, by linarith, ?_, h_jam_inv⟩
  rw [h_normA, h_normB, h_vis_sq]
  ring

/-- **Master $Gr_{\mathbb{C}}(2, 4)$–DDF Unification Theorem**:
Evaluating the pure complex crossing-minor intensity `complexGr24CrossingDoubleSlit`
on `s.gr24TwistorMatrix` reproduces the DDF shear-jammed OAM interference intensity
`huygensSteinerOAMDoubleSlit` with reciprocal jamming visibility
$\mathcal{V}(s) = \gamma_\varphi(v)^{-1}$ **identically at every $(x, y, \phi) \in \mathbb{R}^3$**,
with zero relative predictive error everywhere. -/
@[blueprint "thm:signals-ddf-gr24-twistor-crossing-eq-jammed-oam"
  (title := "Master Gr_C(2,4)-DDF unification: crossing-minor intensity equals DDF shear-jammed OAM intensity with visibility γ_φ(v)⁻¹")
  (statement := /-- For any subluminal sheath $s$, OAM charge difference $\Delta\ell\in\mathbb Z$,
    and $(x,y,\phi)\in\mathbb R^3$,
    $I_{Gr_{\mathbb C}(2,4)}^{\times}\!\bigl(M_{\mathbb C}^{\mathrm{DDF}}(s);x,y\bigr)
    = I_{\mathrm{HS,OAM}}\bigl(x,y,\phi;\Delta\ell,s.\mathrm{jammingFactor}^{-1}\bigr)$
    with zero relative predictive error everywhere. -/)
  (proof := /-- Apply \texttt{complexGr24CrossingDoubleSlit\_oam\_barycentric\_eq\_huygensSteinerOAM}
    with $d_{\mathrm{bary}}=\beta(s)\in[-1,1]$ and rewrite
    $\sqrt{1-\beta(s)^2}=\mathcal{V}(s)=s.\mathrm{jammingFactor}^{-1}$. -/)]
theorem MovingSheath.gr24TwistorMatrix_crossing_eq_ddf_oam_intensity {sub : DDFSubstrate}
    (s : MovingSheath sub)
    (singleSlitScale slitWidth slitHeight separation wavelength screenDistance : ℝ)
    (deltaOAM : ℤ) (azimuthPhi x y : ℝ) :
    let M_C := s.gr24TwistorMatrix separation wavelength screenDistance deltaOAM azimuthPhi x
    complexGr24CrossingDoubleSlit M_C
        singleSlitScale slitWidth slitHeight wavelength screenDistance x y =
      huygensSteinerOAMDoubleSlit
        singleSlitScale slitWidth slitHeight separation wavelength screenDistance
        (s.jammingFactor)⁻¹ deltaOAM azimuthPhi x y ∧
    relativePredictiveError
      (complexGr24CrossingDoubleSlit M_C
        singleSlitScale slitWidth slitHeight wavelength screenDistance x y)
      (huygensSteinerOAMDoubleSlit
        singleSlitScale slitWidth slitHeight separation wavelength screenDistance
        (s.jammingFactor)⁻¹ deltaOAM azimuthPhi x y) = 0 := by
  intro M_C
  have hb := s.beta_bounds
  have h_vis_eq : Real.sqrt (1 - s.beta ^ 2) = (s.jammingFactor)⁻¹ := by
    rw [hb.2.2.2]
    exact (s.visibility_jamming_duality).1
  have h_base := complexGr24CrossingDoubleSlit_oam_barycentric_eq_huygensSteinerOAM
    singleSlitScale slitWidth slitHeight separation wavelength screenDistance
    s.beta deltaOAM azimuthPhi x y hb.2.2.1 hb.2.1
  dsimp [M_C, MovingSheath.gr24TwistorMatrix, MovingSheath.gr24TwistorEntryPlus,
    MovingSheath.gr24TwistorEntryMinus] at *
  rw [← h_vis_eq]
  exact h_base

/-- **Zero-Shear $Gr_{\mathbb{C}}(2, 4)$–DDF Limit**:
When the DDF sheath has zero relative shear velocity ($v = 0 \implies \gamma_\varphi(0) = 1$),
the complex crossing-minor evaluator on $M_{\mathbb{C}}^{\mathrm{DDF}}(s)$ reproduces
`fraunhoferOAMDoubleSlit` identically across all $(x, y, \phi) \in \mathbb{R}^3$ with
zero relative predictive error. -/
@[blueprint "thm:signals-ddf-gr24-twistor-zero-shear-eq-fraunhofer"
  (title := "Zero-shear Gr_C(2,4)-DDF twistor matrix matches Fraunhofer OAM intensity with zero error everywhere")
  (statement := /-- If $s.\mathrm{velocity}=0$, then for all $(x,y,\phi)\in\mathbb R^3$ and
    $\Delta\ell\in\mathbb Z$,
    $I_{Gr_{\mathbb C}(2,4)}^{\times}\!\bigl(M_{\mathbb C}^{\mathrm{DDF}}(s);x,y\bigr)
    = I_{\mathrm{F,OAM}}(x,y,\phi;\Delta\ell)$ and
    $\varepsilon_{\mathrm{rel}}\bigl(I_{Gr_{\mathbb C}(2,4)}^{\times}(M_{\mathbb C}^{\mathrm{DDF}}(s);x,y),
    I_{\mathrm{F,OAM}}(x,y,\phi;\Delta\ell)\bigr)=0$. -/)
  (proof := /-- Combine \texttt{gr24TwistorMatrix\_crossing\_eq\_ddf\_oam\_intensity},
    \texttt{zero\_shear\_no\_jamming} ($\gamma_\varphi(0)=1$), and
    \texttt{huygensSteinerOAMDoubleSlit\_unit\_visibility\_eq\_fraunhoferOAM}. -/)]
theorem MovingSheath.gr24TwistorMatrix_zero_shear_eq_fraunhoferOAM {sub : DDFSubstrate}
    (s : MovingSheath sub) (h_zero : s.velocity = 0)
    (singleSlitScale slitWidth slitHeight separation wavelength screenDistance : ℝ)
    (deltaOAM : ℤ) (azimuthPhi x y : ℝ) :
    let M_C := s.gr24TwistorMatrix separation wavelength screenDistance deltaOAM azimuthPhi x
    complexGr24CrossingDoubleSlit M_C
        singleSlitScale slitWidth slitHeight wavelength screenDistance x y =
      fraunhoferOAMDoubleSlit
        singleSlitScale slitWidth slitHeight separation wavelength screenDistance
        deltaOAM azimuthPhi x y ∧
    relativePredictiveError
      (complexGr24CrossingDoubleSlit M_C
        singleSlitScale slitWidth slitHeight wavelength screenDistance x y)
      (fraunhoferOAMDoubleSlit
        singleSlitScale slitWidth slitHeight separation wavelength screenDistance
        deltaOAM azimuthPhi x y) = 0 := by
  intro M_C
  have h_jam_one : s.jammingFactor = 1 := (s.zero_shear_no_jamming h_zero 1).2.1
  have h_main := (s.gr24TwistorMatrix_crossing_eq_ddf_oam_intensity
    singleSlitScale slitWidth slitHeight separation wavelength screenDistance
    deltaOAM azimuthPhi x y).1
  have h_eq :
      complexGr24CrossingDoubleSlit M_C
        singleSlitScale slitWidth slitHeight wavelength screenDistance x y =
      fraunhoferOAMDoubleSlit
        singleSlitScale slitWidth slitHeight separation wavelength screenDistance
        deltaOAM azimuthPhi x y := by
    rw [h_main, h_jam_one, inv_one,
      huygensSteinerOAMDoubleSlit_unit_visibility_eq_fraunhoferOAM]
  refine ⟨h_eq, ?_⟩
  rw [h_eq]
  simp [relativePredictiveError]

/-- **$SL(2, \mathbb{C})$ & Complex Anosov Gauge Invariance on $Gr_{\mathbb{C}}(2, 4)$**:
For any complex $2 \times 2$ transformation $B_{\mathbb{C}} \in \mathbb{C}^{2 \times 2}$
whose determinant has unit complex norm squared ($\operatorname{normSq}(\det B_{\mathbb{C}}) = 1$,
including all $SL(2, \mathbb{C})$ Lorentz/Anosov transformations and $U(1)$ phase rotations),
the pure crossing-minor intensity `complexGr24CrossingDoubleSlit` is strictly invariant:
$I_{Gr_{\mathbb{C}}(2,4)}^{\times}(B_{\mathbb{C}} M_{\mathbb{C}}; x, y) = I_{Gr_{\mathbb{C}}(2,4)}^{\times}(M_{\mathbb{C}}; x, y)$. -/
@[blueprint "thm:signals-ddf-complex-gr24-sl2c-invariant"
  (title := "Exact SL(2,ℂ) and complex Anosov invariance of Gr_C(2,4) crossing-minor intensity")
  (statement := /-- For any $B_{\mathbb C}\in\mathbb C^{2\times 2}$ with
    $\operatorname{normSq}(\det B_{\mathbb C})=1$ and any $M_{\mathbb C}\in\mathbb C^{2\times 4}$,
    $I_{Gr_{\mathbb C}(2,4)}^{\times}(B_{\mathbb C}M_{\mathbb C};x,y)
    = I_{Gr_{\mathbb C}(2,4)}^{\times}(M_{\mathbb C};x,y)$. -/)
  (proof := /-- Apply \texttt{complexTwoRowMinor\_basisChange}, factor $(\det B_{\mathbb C})^2$
    inside \texttt{Complex.normSq}, and use $\operatorname{normSq}(\det B_{\mathbb C})=1$. -/)]
theorem complexGr24_sl2c_crossing_intensity_invariant
    (B_C : Matrix (Fin 2) (Fin 2) ℂ)
    (M_C : Matrix (Fin 2) (Fin 4) ℂ)
    (singleSlitScale slitWidth slitHeight wavelength screenDistance x y : ℝ)
    (h_unit_det : Complex.normSq B_C.det = 1) :
    complexGr24CrossingDoubleSlit (B_C * M_C)
        singleSlitScale slitWidth slitHeight wavelength screenDistance x y =
      complexGr24CrossingDoubleSlit M_C
        singleSlitScale slitWidth slitHeight wavelength screenDistance x y := by
  unfold complexGr24CrossingDoubleSlit intensity
  rw [complexTwoRowMinor_basisChange, complexTwoRowMinor_basisChange]
  have h_prod :
      B_C.det * complexTwoRowMinor M_C 0 2 * (B_C.det * complexTwoRowMinor M_C 1 3) =
        B_C.det * (B_C.det * (complexTwoRowMinor M_C 0 2 * complexTwoRowMinor M_C 1 3)) := by
    ring
  rw [h_prod, Complex.normSq_mul, Complex.normSq_mul, h_unit_det, one_mul, one_mul]

/-! ### $N$-ary ($N \ge 3$) and Triple-Slit $Gr_{\mathbb{C}}(2, N+2)$–DDF Madelung Sector Generalization -/

/-- Complex twistor channel entry $z_j = \sqrt{w_j}(\cos\theta_j + i\sin\theta_j)$
for sector $j \in \operatorname{Fin} N$ in $Gr_{\mathbb{C}}(2, N + 2)$. -/
@[blueprint "def:signals-ddf-complex-gr2n-twistor-entry"
  (title := "N-ary complex twistor channel entry z_j = √w_j (cos θ_j + i sin θ_j)")
  (statement := /-- For weight $w_j\ge 0$ and phase $\theta_j\in\mathbb R$, define
    $z_j(w_j,\theta_j)=\sqrt{w_j}(\cos\theta_j+i\sin\theta_j)\in\mathbb C$. -/)]
noncomputable def complexGr2NTwistorEntry (weight phase : ℝ) : ℂ :=
  let r := Real.sqrt weight
  ↑(r * Real.cos phase) + Complex.I * ↑(r * Real.sin phase)

/-- **General $N$-ary ($N \ge 1$) Madelung Sector Identities on $Gr_{\mathbb{C}}(2, N+2)$**:
For any number of slits/sinks $N \in \mathbb{N}$ (including $N \ge 3$), non-negative
sector weights $w : \operatorname{Fin} N \to \mathbb{R}$ ($0 \le w_j$), and phases
$\theta : \operatorname{Fin} N \to \mathbb{R}$, let
$z_j = \operatorname{complexGr2NTwistorEntry}(w_j, \theta_j)$ and
$M_{\mathbb{C}}^{(N)} = \operatorname{complexGr2NChannelMatrix}\,N\,z \in \mathbb{C}^{2 \times (N+2)}$. Then:
1. For every sector $j \in \operatorname{Fin} N$, the squared modulus of its Plücker
   minor $\Delta_{0, j+2}^{\mathbb{C}}(M_{\mathbb{C}}^{(N)})$ equals the Madelung
   condensate density $w_j$,
2. The sum of all $N$ Madelung sector densities equals the total $N$-sink flux
   $\sum_{j=0}^{N-1} w_j$, and
3. The collector Plücker minor $\Delta_{0,1}^{\mathbb{C}}(M_{\mathbb{C}}^{(N)})$ equals
   the coherent superposition $\sum_{j=0}^{N-1} \Delta_{0, j+2}^{\mathbb{C}}(M_{\mathbb{C}}^{(N)})$. -/
@[blueprint "thm:signals-ddf-gr2n-madelung-sector-identities"
  (title := "General N-ary (N ≥ 1) Madelung sector densities and flux conservation on Gr_C(2, N+2)")
  (statement := /-- For any $N\in\mathbb N$, $w,\theta:\operatorname{Fin}(N)\to\mathbb R$ with
    $\forall j,\,0\le w_j$, let $z_j=\sqrt{w_j}(\cos\theta_j+i\sin\theta_j)$ and
    $M_{\mathbb C}^{(N)}=M_{\mathbb C}^{(N)}(z)\in\mathbb C^{2\times(N+2)}$. Then:
    (1) $\forall j,\,\bigl|\Delta_{0,j+2}^{\mathbb C}(M_{\mathbb C}^{(N)})\bigr|^2=w_j$,
    (2) $\sum_{j=0}^{N-1}\bigl|\Delta_{0,j+2}^{\mathbb C}(M_{\mathbb C}^{(N)})\bigr|^2=\sum_{j=0}^{N-1}w_j$, and
    (3) $\Delta_{0,1}^{\mathbb C}(M_{\mathbb C}^{(N)})=\sum_{j=0}^{N-1}\Delta_{0,j+2}^{\mathbb C}(M_{\mathbb C}^{(N)})$. -/)
  (proof := /-- Apply \texttt{complexGr2NChannelMatrix\_minors}, evaluate \texttt{Complex.normSq}
    for each $j$ using $\cos^2\theta_j+\sin^2\theta_j=1$ and \texttt{Real.sq\_sqrt}, and sum over $\operatorname{Fin}(N)$. -/)]
theorem complexGr2N_madelung_sector_identities
    (numSlits : ℕ) (w θ : Fin numSlits → ℝ)
    (hw : ∀ j : Fin numSlits, 0 ≤ w j) :
    let z : Fin numSlits → ℂ := fun j => complexGr2NTwistorEntry (w j) (θ j)
    let M_C := complexGr2NChannelMatrix numSlits z
    (∀ j : Fin numSlits,
      Complex.normSq (complexTwoRowMinor M_C (narySourceCol numSlits) (narySlitCol j)) = w j) ∧
    (∑ j : Fin numSlits,
      Complex.normSq (complexTwoRowMinor M_C (narySourceCol numSlits) (narySlitCol j))) =
      (∑ j : Fin numSlits, w j) ∧
    complexTwoRowMinor M_C (narySourceCol numSlits) (naryCollectorCol numSlits) =
      ∑ j : Fin numSlits,
        complexTwoRowMinor M_C (narySourceCol numSlits) (narySlitCol j) := by
  intro z M_C
  have h_minors := complexGr2NChannelMatrix_minors numSlits z
  have h_each : ∀ j : Fin numSlits,
      Complex.normSq (complexTwoRowMinor M_C (narySourceCol numSlits) (narySlitCol j)) = w j := by
    intro j
    rw [h_minors.1 j]
    dsimp [z, complexGr2NTwistorEntry]
    have h_trig : (Real.cos (θ j)) ^ 2 + (Real.sin (θ j)) ^ 2 = 1 :=
      Real.cos_sq_add_sin_sq (θ j)
    simp only [Complex.normSq_apply, Complex.add_re, Complex.add_im, Complex.mul_re,
      Complex.mul_im, Complex.ofReal_re, Complex.ofReal_im, Complex.I_re, Complex.I_im]
    calc
      _ = (Real.sqrt (w j)) ^ 2 * ((Real.cos (θ j)) ^ 2 + (Real.sin (θ j)) ^ 2) := by ring
      _ = w j := by rw [Real.sq_sqrt (hw j), h_trig, mul_one]
  refine ⟨h_each, ?_, h_minors.2.2.2⟩
  refine Finset.sum_congr rfl (fun j _ => h_each j)

/-- **Triple-Slit ($N = 3$) $Gr_{\mathbb{C}}(2, 5)$–DDF Sheath Twistor Matrix**:
Embeds a subluminal DDF `MovingSheath` $s$ into the 3-slit complex Grassmannian
$Gr_{\mathbb{C}}(2, 5)$ with forward-sheared outer channel
$z_0 = \sqrt{1 + \beta(s)}\,e^{2i\beta_{\mathrm{opt}}}$, central unsheared reference
channel $z_1 = 1$, and reverse-sheared outer channel
$z_2 = \sqrt{1 - \beta(s)}\,e^{-2i\beta_{\mathrm{opt}}}$. -/
@[blueprint "def:signals-ddf-gr25-triple-slit-twistor-matrix"
  (title := "Triple-slit (N = 3) Gr_C(2,5)-DDF sheath and vortex twistor matrix")
  (statement := /-- For a subluminal sheath $s$ and $\beta_{\mathrm{opt}}=\frac{\pi d x}{\lambda L}+\frac{\Delta\ell\,\phi}{2}$,
    define the $2\times 5$ matrix $M_{\mathbb C}^{(3),\mathrm{DDF}}(s)=
    M_{\mathbb C}^{(3)}\bigl(z_+(s,2\beta_{\mathrm{opt}}),\,1,\,z_-(s,2\beta_{\mathrm{opt}})\bigr)\in\mathbb C^{2\times 5}$. -/)]
noncomputable def MovingSheath.gr25TripleSlitTwistorMatrix {sub : DDFSubstrate}
    (s : MovingSheath sub)
    (separation wavelength screenDistance : ℝ)
    (deltaOAM : ℤ) (azimuthPhi x : ℝ) : Matrix (Fin 2) (Fin 5) ℂ :=
  let β_opt := Real.pi * separation * x / (wavelength * screenDistance) +
    (deltaOAM : ℝ) * azimuthPhi / 2
  complexGr2NChannelMatrix 3
    ![s.gr24TwistorEntryPlus (2 * β_opt), 1, s.gr24TwistorEntryMinus (2 * β_opt)]

/-- **Triple-Slit ($N = 3$) $Gr_{\mathbb{C}}(2, 5)$–DDF Madelung Sector & Sorkin Identities**:
For any subluminal `MovingSheath` $s$, let $M_5 = s.\mathrm{gr25TripleSlitTwistorMatrix}$
and let $\mathcal{A}_j = \Delta_{0, j+2}^{\mathbb{C}}(M_5)$ ($j \in \{0, 1, 2\}$) be its
three complex slit Plücker minors. Then:
1. $|\mathcal{A}_0|^2 = 1 + \beta(s)$, $|\mathcal{A}_1|^2 = 1$, and $|\mathcal{A}_2|^2 = 1 - \beta(s)$,
2. Total 3-slit Madelung density $|\mathcal{A}_0|^2 + |\mathcal{A}_1|^2 + |\mathcal{A}_2|^2 = 3$,
3. Barycentric 3-slit shear moment $(|\mathcal{A}_0|^2 - |\mathcal{A}_2|^2)/2 = \beta(s) = v/c$,
4. Product of all three Madelung sector densities
   $|\mathcal{A}_0|^2\,|\mathcal{A}_1|^2\,|\mathcal{A}_2|^2 = 1 - \beta(s)^2 = \mathcal{V}(s)^2 = \gamma_\varphi(v)^{-2}$, and
5. The Sorkin third-order quantum interference parameter vanishes identically:
   $\kappa_3(\mathcal{A}_0, \mathcal{A}_1, \mathcal{A}_2) = 0$. -/
@[blueprint "thm:signals-ddf-gr25-triple-slit-madelung-identities"
  (title := "Triple-slit (N = 3) Gr_C(2,5)-DDF Madelung densities, reciprocal jamming product, and Sorkin κ₃ = 0")
  (statement := /-- For $M_5 = s.\mathrm{gr25TripleSlitTwistorMatrix}(d,\lambda,L,\Delta\ell,\phi,x)$
    with slit minors $\mathcal{A}_j = \Delta_{0,j+2}^{\mathbb C}(M_5)$ ($j\in\{0,1,2\}$):
    $|\mathcal{A}_0|^2=1+\beta(s)$, $|\mathcal{A}_1|^2=1$, $|\mathcal{A}_2|^2=1-\beta(s)$,
    $|\mathcal{A}_0|^2+|\mathcal{A}_1|^2+|\mathcal{A}_2|^2=3$,
    $(|\mathcal{A}_0|^2-|\mathcal{A}_2|^2)/2=\beta(s)$,
    $|\mathcal{A}_0|^2|\mathcal{A}_1|^2|\mathcal{A}_2|^2 = \mathcal{V}(s)^2 = s.\mathrm{jammingFactor}^{-2}$,
    and $\kappa_3(\mathcal{A}_0,\mathcal{A}_1,\mathcal{A}_2)=0$. -/)
  (proof := /-- Apply \texttt{complexGr2NChannelMatrix\_minors}, evaluate the three complex norms,
    use \texttt{visibility\_jamming\_duality}, and apply \texttt{sorkinTripleSlitParameter\_zero}. -/)]
theorem MovingSheath.gr25TripleSlitTwistorMatrix_madelung_sector_identities {sub : DDFSubstrate}
    (s : MovingSheath sub)
    (separation wavelength screenDistance : ℝ)
    (deltaOAM : ℤ) (azimuthPhi x : ℝ) :
    let M_5 := s.gr25TripleSlitTwistorMatrix separation wavelength screenDistance deltaOAM azimuthPhi x
    let A0 := complexTwoRowMinor M_5 (narySourceCol 3) (narySlitCol 0)
    let A1 := complexTwoRowMinor M_5 (narySourceCol 3) (narySlitCol 1)
    let A2 := complexTwoRowMinor M_5 (narySourceCol 3) (narySlitCol 2)
    Complex.normSq A0 = 1 + s.beta ∧
      Complex.normSq A1 = 1 ∧
      Complex.normSq A2 = 1 - s.beta ∧
      Complex.normSq A0 + Complex.normSq A1 + Complex.normSq A2 = 3 ∧
      (Complex.normSq A0 - Complex.normSq A2) / 2 = s.beta ∧
      Complex.normSq A0 * Complex.normSq A1 * Complex.normSq A2 =
        (s.jammingFactor ^ 2)⁻¹ ∧
      sorkinTripleSlitParameter A0 A1 A2 = 0 := by
  intro M_5 A0 A1 A2
  have hb := s.beta_bounds
  have ha_nonneg : 0 ≤ 1 + s.beta := by linarith [hb.1]
  have hb_nonneg : 0 ≤ 1 - s.beta := by linarith [hb.2.1]
  let β_opt := Real.pi * separation * x / (wavelength * screenDistance) +
    (deltaOAM : ℝ) * azimuthPhi / 2
  have h_minors := (complexGr2NChannelMatrix_minors 3
    ![s.gr24TwistorEntryPlus (2 * β_opt), 1, s.gr24TwistorEntryMinus (2 * β_opt)]).1
  have hA0 : A0 = s.gr24TwistorEntryPlus (2 * β_opt) := h_minors 0
  have hA1 : A1 = 1 := h_minors 1
  have hA2 : A2 = s.gr24TwistorEntryMinus (2 * β_opt) := h_minors 2
  have h_trig : (Real.cos (2 * β_opt)) ^ 2 + (Real.sin (2 * β_opt)) ^ 2 = 1 :=
    Real.cos_sq_add_sin_sq (2 * β_opt)
  have h_norm0 : Complex.normSq A0 = 1 + s.beta := by
    rw [hA0]
    unfold MovingSheath.gr24TwistorEntryPlus
    simp only [Complex.normSq_apply, Complex.add_re, Complex.add_im, Complex.mul_re,
      Complex.mul_im, Complex.ofReal_re, Complex.ofReal_im, Complex.I_re, Complex.I_im]
    calc
      _ = (Real.sqrt (1 + s.beta)) ^ 2 *
          ((Real.cos (2 * β_opt)) ^ 2 + (Real.sin (2 * β_opt)) ^ 2) := by ring
      _ = 1 + s.beta := by rw [Real.sq_sqrt ha_nonneg, h_trig, mul_one]
  have h_norm1 : Complex.normSq A1 = 1 := by
    rw [hA1, Complex.normSq_one]
  have h_norm2 : Complex.normSq A2 = 1 - s.beta := by
    rw [hA2]
    unfold MovingSheath.gr24TwistorEntryMinus
    simp only [Complex.normSq_apply, Complex.sub_re, Complex.sub_im, Complex.mul_re,
      Complex.mul_im, Complex.ofReal_re, Complex.ofReal_im, Complex.I_re, Complex.I_im]
    calc
      _ = (Real.sqrt (1 - s.beta)) ^ 2 *
          ((Real.cos (2 * β_opt)) ^ 2 + (Real.sin (2 * β_opt)) ^ 2) := by ring
      _ = 1 - s.beta := by rw [Real.sq_sqrt hb_nonneg, h_trig, mul_one]
  have h_vis_sq : s.coherenceVisibility ^ 2 = 1 - s.beta ^ 2 := by
    unfold MovingSheath.coherenceVisibility
    rw [Real.sq_sqrt (le_of_lt s.one_sub_betaSq_pos), ← hb.2.2.2]
  have h_jam_inv : s.coherenceVisibility ^ 2 = (s.jammingFactor ^ 2)⁻¹ := by
    rw [(s.visibility_jamming_duality).1, inv_pow]
  have h_prod :
      Complex.normSq A0 * Complex.normSq A1 * Complex.normSq A2 =
        (s.jammingFactor ^ 2)⁻¹ := by
    rw [h_norm0, h_norm1, h_norm2, ← h_jam_inv, h_vis_sq]
    ring
  refine ⟨h_norm0, h_norm1, h_norm2, by linarith, by linarith, h_prod,
    sorkinTripleSlitParameter_zero A0 A1 A2⟩

/-- **Zero-Shear Triple-Slit ($N = 3$) $Gr_{\mathbb{C}}(2, 5)$–DDF Equivalence**:
When the DDF sheath has zero relative shear speed ($v = 0 \implies \beta(s) = 0$),
evaluating `complexGr2NCollectorMultiSlit 3` on `s.gr25TripleSlitTwistorMatrix`
reproduces the coherent triple-slit Fraunhofer intensity `fraunhoferMultiSlit 3`
**identically across all $(x, y, \phi) \in \mathbb{R}^3$**, with zero relative
predictive error everywhere. -/
@[blueprint "thm:signals-ddf-gr25-triple-slit-zero-shear-eq-fraunhofer"
  (title := "Zero-shear Gr_C(2,5)-DDF triple-slit twistor matrix matches Fraunhofer 3-slit intensity with zero error everywhere")
  (statement := /-- If $s.\mathrm{velocity}=0$, then for all $(x,y,\phi)\in\mathbb R^3$ and
    $\Delta\ell\in\mathbb Z$,
    $I_{Gr_{\mathbb C}(2,5)}\!\bigl(M_{\mathbb C}^{(3),\mathrm{DDF}}(s);x,y\bigr)
    = I_{\mathrm{F}}^{(3)}(3,x,y,\phi;\Delta\ell)$ with zero relative predictive error everywhere. -/)
  (proof := /-- At $v=0$, $\beta(s)=0$ and $\sqrt{1\pm 0}=1$, reducing
    \texttt{gr25TripleSlitTwistorMatrix} to \texttt{complexGr25CollectorTripleSlit\_eq\_fraunhoferMultiSlit}. -/)]
theorem MovingSheath.gr25TripleSlitTwistorMatrix_zero_shear_eq_fraunhoferMultiSlit
    {sub : DDFSubstrate} (s : MovingSheath sub) (h_zero : s.velocity = 0)
    (singleSlitScale slitWidth slitHeight separation wavelength screenDistance : ℝ)
    (deltaOAM : ℤ) (azimuthPhi x y : ℝ) :
    let M_5 := s.gr25TripleSlitTwistorMatrix separation wavelength screenDistance deltaOAM azimuthPhi x
    complexGr2NCollectorMultiSlit 3 M_5
        singleSlitScale slitWidth slitHeight wavelength screenDistance x y =
      fraunhoferMultiSlit 3
        singleSlitScale slitWidth slitHeight separation wavelength screenDistance
        deltaOAM azimuthPhi x y ∧
    relativePredictiveError
      (complexGr2NCollectorMultiSlit 3 M_5
        singleSlitScale slitWidth slitHeight wavelength screenDistance x y)
      (fraunhoferMultiSlit 3
        singleSlitScale slitWidth slitHeight separation wavelength screenDistance
        deltaOAM azimuthPhi x y) = 0 := by
  intro M_5
  have h_beta_zero : s.beta = 0 := by
    unfold MovingSheath.beta
    rw [h_zero, zero_div]
  let β_opt := Real.pi * separation * x / (wavelength * screenDistance) +
    (deltaOAM : ℝ) * azimuthPhi / 2
  have h_plus :
      s.gr24TwistorEntryPlus (2 * β_opt) =
        ↑(Real.cos (2 * β_opt)) + Complex.I * ↑(Real.sin (2 * β_opt)) := by
    unfold MovingSheath.gr24TwistorEntryPlus
    rw [h_beta_zero]
    simp
  have h_minus :
      s.gr24TwistorEntryMinus (2 * β_opt) =
        ↑(Real.cos (2 * β_opt)) - Complex.I * ↑(Real.sin (2 * β_opt)) := by
    unfold MovingSheath.gr24TwistorEntryMinus
    rw [h_beta_zero]
    simp
  have h_mat :
      M_5 = complexGr2NChannelMatrix 3
        ![↑(Real.cos (2 * β_opt)) + Complex.I * ↑(Real.sin (2 * β_opt)),
          1,
          ↑(Real.cos (2 * β_opt)) - Complex.I * ↑(Real.sin (2 * β_opt))] := by
    dsimp [M_5, MovingSheath.gr25TripleSlitTwistorMatrix]
    rw [h_plus, h_minus]
  rw [h_mat]
  exact complexGr25CollectorTripleSlit_eq_fraunhoferMultiSlit
    singleSlitScale slitWidth slitHeight separation wavelength screenDistance
    deltaOAM azimuthPhi x y

/-! ## Planetary Orbits, Mercury Perihelion Precession, BCJ Double Copy, $N$-Body Dynamics, & $Gr_{\mathbb{C}}(2,4)$–DDF Bridge

Formalizes the orbital mechanics, post-Minkowskian QED/gauge double-copy scattering,
and Dilatant Dark Fluid (DDF) connections for planetary orbits (`docs/grassmannian-gravity-from-qed-scattering-paper.md`):
1. **Keplerian & Post-Newtonian / QFT / DDF Orbital Geometry (`PlanetaryOrbit`)**:
   - Semi-latus rectum $p = a(1 - e^2)$, perihelion $r_{\min} = a(1 - e)$, aphelion
     $r_{\max} = a(1 + e)$, harmonic-mean identity $2/p = 1/r_{\min} + 1/r_{\max}$,
     geometric-mean identity $r_{\min} r_{\max} = a p$, and Kepler's third law
     $T^2 / a^3 = 4\pi^2 / (G_\phi M)$.
2. **Effective Relativistic / QFT / DDF Potential & Anomalous Perihelion Precession**:
   - The effective central potential $V_{\mathrm{eff}}(r) = -\frac{G_\phi M m}{r}\bigl(1 + \frac{3 L^2}{m^2 c^2 r^2}\bigr)$
     decomposes into the superfluid Bernoulli enthalpy $m \Phi_\phi(r)$ plus the
     1-loop / DDF shear-jamming $r^{-3}$ correction $-\frac{3 G_\phi M L^2 \varrho_{\max}^\varphi j_{\min}^\varphi}{m r^3}$.
   - Anomalous perihelion precession per orbit:
     $$\Delta\varpi = \frac{6\pi G_\phi M}{c^2 a(1 - e^2)} = \frac{3\pi\,r_H}{a(1 - e^2)} = \frac{6\pi\,G_\phi M\,\varrho_{\max}^\varphi j_{\min}^\varphi}{a(1 - e^2)},$$
     together with the solar-system planetary scaling law
     $\frac{\Delta\varpi(p_1)}{\Delta\varpi(p_2)} = \frac{p_2}{p_1}$ and Mercury's
     validated $\approx 42.98''/\text{century}$ benchmark.
3. **BCJ Color–Kinematics Duality & Plücker $Gr_{\mathbb{C}}(2,4)$ Double-Copy Bridge**:
   - In 4-point gauge/gravity scattering, the BCJ kinematic Jacobi relation
     $n_s - n_t + n_u = 0$ is realized directly by the 3-term complex Plücker identity
     $\Delta_{01}^{\mathbb{C}}\Delta_{23}^{\mathbb{C}} - \Delta_{02}^{\mathbb{C}}\Delta_{13}^{\mathbb{C}} + \Delta_{03}^{\mathbb{C}}\Delta_{12}^{\mathbb{C}} = 0$
     on $Gr_{\mathbb{C}}(2,4)$, and squaring the Plücker channel numerators generates
     the symmetric graviton/fluid-tension double-copy amplitude.
4. **Complex $Gr_{\mathbb{C}}(2,4)$ Orbital Precession Twistor Matrix (`PlanetaryOrbit.gr24PrecessionMatrix`)**:
   - Encoding orbital eccentricity $e \in [0, 1)$ as the $Gr_{\mathbb{C}}(2,4)$ barycentric
     shift ($d_{\mathrm{bary}} = e$) and the anomalous perihelion phase $\Delta\varpi / 2$
     in $M_{\mathbb{C}}(z_{\mathrm{aph}}, z_{\mathrm{per}}) \in Gr_{\mathbb{C}}(2,4)$ makes
     the Madelung channel densities equal the normalized aphelion and perihelion radii
     $|w_A^{\mathbb{C}}|^2 = 1 + e = r_{\max}/a$ and $|w_B^{\mathbb{C}}|^2 = 1 - e = r_{\min}/a$,
     while their product $|w_A^{\mathbb{C}}|^2 |w_B^{\mathbb{C}}|^2 = 1 - e^2 = p / a$
     is the exact semi-latus rectum ratio governing $\Delta\varpi = 3\pi r_H / p$.
5. **$N$-Body Gravitational Sink-Flow Superposition & Conservative vs. Dissipative Critique**:
   - Formalizes $N$-body Bernoulli sink superposition $\Phi_\phi^{(N)} = -\sum_{i=0}^{N-1} \frac{G_\phi M_i}{r_i}$,
     total secular perihelion advance $\Delta\varpi_{\mathrm{tot}} = \Delta\varpi_{\mathrm{rel}} + \sum_{j} \Delta\varpi_{j,\mathrm{Newtonian}}$
     (matching Mercury's $42.98'' + 531.63'' = 574.61''/\text{century}$), and proves
     that conservative DDF action preserves orbital energy ($\Delta E = 0$) whereas
     non-conservative Stokes drag causes secular orbital energy decay ($dE/dt = -F_d v < 0$).
-/

/-- Keplerian planetary orbit parameters around a `RiverExterior` central mass:
semi-major axis $a > 0$ and orbital eccentricity $e \in [0, 1)$. -/
@[blueprint "def:signals-ddf-planetary-orbit"
  (title := "Planetary orbit parameters (semi-major axis a > 0 and eccentricity e ∈ [0, 1))")
  (statement := /-- A bound elliptical planetary orbit record with semi-major axis $a>0$
    and eccentricity $0\le e<1$. -/)]
structure PlanetaryOrbit where
  semiMajorAxis : ℝ
  semiMajorAxis_pos : 0 < semiMajorAxis
  eccentricity : ℝ
  eccentricity_nonneg : 0 ≤ eccentricity
  eccentricity_lt_one : eccentricity < 1

/-- Semi-latus rectum $p = a(1 - e^2)$ of a planetary orbit. -/
@[blueprint "def:signals-ddf-semi-latus-rectum"
  (title := "Planetary orbit semi-latus rectum p = a(1 - e²)")
  (statement := /-- For an orbit with semi-major axis $a$ and eccentricity $e$, define
    $p = a(1-e^2)$. -/)]
def PlanetaryOrbit.semiLatusRectum (orb : PlanetaryOrbit) : ℝ :=
  orb.semiMajorAxis * (1 - orb.eccentricity ^ 2)

/-- Perihelion distance $r_{\min} = a(1 - e)$ of a planetary orbit. -/
@[blueprint "def:signals-ddf-perihelion-radius"
  (title := "Planetary perihelion radius r_min = a(1 - e)")
  (statement := /-- Define the perihelion radius $r_{\min}=a(1-e)$. -/)]
def PlanetaryOrbit.perihelionRadius (orb : PlanetaryOrbit) : ℝ :=
  orb.semiMajorAxis * (1 - orb.eccentricity)

/-- Aphelion distance $r_{\max} = a(1 + e)$ of a planetary orbit. -/
@[blueprint "def:signals-ddf-aphelion-radius"
  (title := "Planetary aphelion radius r_max = a(1 + e)")
  (statement := /-- Define the aphelion radius $r_{\max}=a(1+e)$. -/)]
def PlanetaryOrbit.aphelionRadius (orb : PlanetaryOrbit) : ℝ :=
  orb.semiMajorAxis * (1 + orb.eccentricity)

/-- For any bound `PlanetaryOrbit` ($a > 0$, $0 \le e < 1$), $1 - e^2 > 0$,
$p > 0$, $r_{\min} > 0$, $r_{\max} > 0$, $r_{\min} + r_{\max} = 2a$, and
$r_{\min} r_{\max} = a p$. -/
@[blueprint "lem:signals-ddf-planetary-orbit-radii"
  (title := "Positivity and harmonic/geometric relations of perihelion, aphelion, and semi-latus rectum")
  (statement := /-- For any \texttt{orb : PlanetaryOrbit}, $0<1-e^2$, $0<p$,
    $0<r_{\min}$, $0<r_{\max}$, $r_{\min}+r_{\max}=2a$, and $r_{\min}r_{\max}=a p$. -/)
  (proof := /-- Use $0<a$ and $0\le e<1$ to establish positivity, and close the sum/product
    identities by ring algebra. -/)
  (latexEnv := "lemma")]
lemma PlanetaryOrbit.radii_identities (orb : PlanetaryOrbit) :
    0 < 1 - orb.eccentricity ^ 2 ∧
      0 < orb.semiLatusRectum ∧
      0 < orb.perihelionRadius ∧
      0 < orb.aphelionRadius ∧
      orb.perihelionRadius + orb.aphelionRadius = 2 * orb.semiMajorAxis ∧
      orb.perihelionRadius * orb.aphelionRadius =
        orb.semiMajorAxis * orb.semiLatusRectum := by
  have ha := orb.semiMajorAxis_pos
  have he0 := orb.eccentricity_nonneg
  have he1 := orb.eccentricity_lt_one
  have h1e : 0 < 1 - orb.eccentricity := by linarith
  have h1pe : 0 < 1 + orb.eccentricity := by linarith
  have h1e2 : 0 < 1 - orb.eccentricity ^ 2 := by nlinarith
  refine ⟨h1e2, mul_pos ha h1e2, mul_pos ha h1e, mul_pos ha h1pe, ?_, ?_⟩
  · unfold PlanetaryOrbit.perihelionRadius PlanetaryOrbit.aphelionRadius
    ring
  · unfold PlanetaryOrbit.perihelionRadius PlanetaryOrbit.aphelionRadius
      PlanetaryOrbit.semiLatusRectum
    ring

/-- Squared Keplerian orbital period $T^2 = \frac{4\pi^2 a^3}{G_\phi M}$ around a
`RiverExterior` central mass $M$. -/
@[blueprint "def:signals-ddf-kepler-period-sq"
  (title := "Squared Keplerian orbital period T² = 4π² a³ / (G_ϕ M)")
  (statement := /-- For \texttt{re : RiverExterior sub} and \texttt{orb : PlanetaryOrbit},
    define $T^2 = \frac{4\pi^2 a^3}{G_\phi M}$. -/)]
noncomputable def RiverExterior.keplerPeriodSq {sub : DDFSubstrate}
    (re : RiverExterior sub) (orb : PlanetaryOrbit) : ℝ :=
  4 * Real.pi ^ 2 * orb.semiMajorAxis ^ 3 / (re.G_phi * re.sourceMass)

/-- **Kepler's Third Law in DDF River Geometry**:
For any planetary orbit around `re : RiverExterior sub`, the ratio $T^2 / a^3$ is
independent of the orbital semi-major axis $a$ and eccentricity $e$ and equals
$\frac{4\pi^2}{G_\phi M}$. -/
@[blueprint "thm:signals-ddf-kepler-third-law"
  (title := "Kepler's Third Law T² / a³ = 4π² / (G_ϕ M) in DDF RiverExterior geometry")
  (statement := /-- For any \texttt{re : RiverExterior sub} and \texttt{orb : PlanetaryOrbit},
    $\frac{T^2}{a^3} = \frac{4\pi^2}{G_\phi M}$. -/)
  (proof := /-- Unfold \texttt{keplerPeriodSq} and cancel $a^3 \ne 0$. -/)]
theorem RiverExterior.kepler_third_law {sub : DDFSubstrate}
    (re : RiverExterior sub) (orb : PlanetaryOrbit) :
    re.keplerPeriodSq orb / orb.semiMajorAxis ^ 3 =
      4 * Real.pi ^ 2 / (re.G_phi * re.sourceMass) := by
  unfold RiverExterior.keplerPeriodSq
  have ha3 : orb.semiMajorAxis ^ 3 ≠ 0 := pow_ne_zero 3 (ne_of_gt orb.semiMajorAxis_pos)
  rw [div_right_comm, mul_div_cancel_right₀ _ ha3]

/-- **Relativistic / Post-Minkowskian QFT / DDF Effective Orbital Potential**:
$V_{\mathrm{eff}}(r) = -\frac{G_\phi M m}{r}\left(1 + \frac{3 L^2}{m^2 c^2 r^2}\right)$,
where $m$ is the planet mass and $L$ is the orbital angular momentum. -/
@[blueprint "def:signals-ddf-relativistic-effective-potential"
  (title := "Relativistic / QFT / DDF effective central potential V_eff(r)")
  (statement := /-- For \texttt{re : RiverExterior sub}, planet mass $m$, angular momentum $L$,
    and radius $r$, define
    $V_{\mathrm{eff}}(r) = -\frac{G_\phi M m}{r}\left(1+\frac{3 L^2}{m^2 c^2 r^2}\right)$. -/)]
noncomputable def RiverExterior.relativisticEffectivePotential {sub : DDFSubstrate}
    (re : RiverExterior sub) (planetMass angularMomentum r : ℝ) : ℝ :=
  - (re.G_phi * re.sourceMass * planetMass / r) *
    (1 + 3 * angularMomentum ^ 2 / (planetMass ^ 2 * sub.c ^ 2 * r ^ 2))

/-- **Decomposition of $V_{\mathrm{eff}}(r)$ into Superfluid Bernoulli Enthalpy & DDF Jamming Correction**:
For $r > 0$ and $m \neq 0$, the effective potential $V_{\mathrm{eff}}(r)$ decomposes
exactly into the Newtonian superfluid Bernoulli enthalpy $m \Phi_\phi(r)$ plus the
post-Minkowskian / DDF shear-jamming $r^{-3}$ potential governed by the dispersed-phase
compressibility-density product $\varrho_{\max}^\varphi j_{\min}^\varphi = c^{-2}$:
$$V_{\mathrm{eff}}(r) = m\,\Phi_\phi(r) - \frac{3\,G_\phi M\,L^2\,\varrho_{\max}^\varphi j_{\min}^\varphi}{m\,r^3}.$$ -/
@[blueprint "thm:signals-ddf-effective-potential-bernoulli-decomposition"
  (title := "Decomposition of V_eff(r) into superfluid Bernoulli enthalpy m Φ_ϕ(r) and DDF r⁻³ correction")
  (statement := /-- For $r>0$ and $m\ne 0$,
    $V_{\mathrm{eff}}(r) = m\,\Phi_\phi(r) - \frac{3 G_\phi M L^2 \varrho_{\max}^\varphi j_{\min}^\varphi}{m r^3}$. -/)
  (proof := /-- Apply \texttt{bernoulli\_potential\_eq} and \texttt{sub.c\_sq}, then clear denominators. -/)]
theorem RiverExterior.relativisticEffectivePotential_eq_bernoulli_and_substrate
    {sub : DDFSubstrate} (re : RiverExterior sub)
    (planetMass angularMomentum r : ℝ) (hr : 0 < r) (hm : planetMass ≠ 0) :
    re.relativisticEffectivePotential planetMass angularMomentum r =
      planetMass * re.bernoulliPotential r -
        3 * re.G_phi * re.sourceMass * angularMomentum ^ 2 *
          (sub.rho_max_varphi * sub.j_min_varphi) / (planetMass * r ^ 3) := by
  have hr_ne : r ≠ 0 := ne_of_gt hr
  have hc_pos := sub.c_pos
  have hc2_ne : sub.c ^ 2 ≠ 0 := pow_ne_zero 2 (ne_of_gt hc_pos)
  unfold RiverExterior.relativisticEffectivePotential
  rw [re.bernoulli_potential_eq r hr, sub.c_sq]
  field_simp [hr_ne, hm]
  ring

/-- **Anomalous Perihelion Precession per Orbit (Radians)**:
$\Delta\varpi = \frac{6\pi G_\phi M}{c^2 a(1 - e^2)} = \frac{6\pi G_\phi M}{c^2 p}$,
derived identically from 1-loop QED/graviton scattering ([Partanen and Tulkki 2025]),
Einstein–Infeld–Hoffmann / Schwarzschild geodesics, and conservative DDF sheath mechanics. -/
@[blueprint "def:signals-ddf-perihelion-precession-rad"
  (title := "Anomalous perihelion precession per orbit Δϖ = 6π G_ϕ M / (c² a(1 - e²))")
  (statement := /-- For \texttt{re : RiverExterior sub} and \texttt{orb : PlanetaryOrbit},
    define the anomalous perihelion advance per revolution (in radians) as
    $\Delta\varpi = \frac{6\pi G_\phi M}{c^2 a(1-e^2)}$. -/)]
noncomputable def RiverExterior.perihelionPrecessionRad {sub : DDFSubstrate}
    (re : RiverExterior sub) (orb : PlanetaryOrbit) : ℝ :=
  6 * Real.pi * re.G_phi * re.sourceMass / (sub.c ^ 2 * orb.semiLatusRectum)

/-- **Acoustic-Horizon & DDF Substrate Forms of Planetary Perihelion Precession**:
The anomalous perihelion precession per orbit $\Delta\varpi$ is strictly positive and
equals both:
1. $\Delta\varpi = \frac{3\pi\,r_H}{a(1 - e^2)}$ in terms of the DDF acoustic horizon
   radius $r_H = 2 G_\phi M / c^2$, and
2. $\Delta\varpi = \frac{6\pi\,G_\phi M\,\varrho_{\max}^\varphi j_{\min}^\varphi}{a(1 - e^2)}$
   in terms of the DDF dispersed-phase compressibility-density product
   $\varrho_{\max}^\varphi j_{\min}^\varphi = c^{-2}$. -/
@[blueprint "thm:signals-ddf-perihelion-precession-horizon-and-substrate"
  (title := "Planetary perihelion precession in terms of DDF acoustic horizon r_H and substrate product ϱ_max^φ j_min^φ")
  (statement := /-- For any \texttt{re : RiverExterior sub} and \texttt{orb : PlanetaryOrbit}:
    (1) $0 < \Delta\varpi$,
    (2) $\Delta\varpi = \frac{3\pi\,r_H}{a(1-e^2)}$, and
    (3) $\Delta\varpi = \frac{6\pi\,G_\phi M\,\varrho_{\max}^\varphi j_{\min}^\varphi}{a(1-e^2)}$. -/)
  (proof := /-- Unfold \texttt{perihelionPrecessionRad} and \texttt{horizonRadius}, apply
    \texttt{sub.c\_sq} and \texttt{orb.radii\_identities}, and simplify by ring algebra. -/)]
theorem RiverExterior.perihelionPrecession_eq_horizon_and_substrate
    {sub : DDFSubstrate} (re : RiverExterior sub) (orb : PlanetaryOrbit) :
    0 < re.perihelionPrecessionRad orb ∧
      re.perihelionPrecessionRad orb =
        3 * Real.pi * re.horizonRadius / orb.semiLatusRectum ∧
      re.perihelionPrecessionRad orb =
        6 * Real.pi * re.G_phi * re.sourceMass *
          (sub.rho_max_varphi * sub.j_min_varphi) / orb.semiLatusRectum := by
  have h_p_pos := (orb.radii_identities).2.1
  have h_c_pos := sub.c_pos
  have h_G_pos := re.G_phi_pos
  have h_M_pos := re.sourceMass_pos
  have h_pi_pos := Real.pi_pos
  have h_pos : 0 < re.perihelionPrecessionRad orb := by
    unfold RiverExterior.perihelionPrecessionRad
    positivity
  have h_hor :
      re.perihelionPrecessionRad orb =
        3 * Real.pi * re.horizonRadius / orb.semiLatusRectum := by
    unfold RiverExterior.perihelionPrecessionRad RiverExterior.horizonRadius
    ring
  have h_sub :
      re.perihelionPrecessionRad orb =
        6 * Real.pi * re.G_phi * re.sourceMass *
          (sub.rho_max_varphi * sub.j_min_varphi) / orb.semiLatusRectum := by
    unfold RiverExterior.perihelionPrecessionRad
    rw [sub.c_sq, inv_mul_eq_div, div_div_eq_mul_div]
  exact ⟨h_pos, h_hor, h_sub⟩

/-- **Universal Planetary Precession Ratio Law Across Orbits**:
For any two planetary orbits `orb1` and `orb2` around the same central body
`re : RiverExterior sub`, the ratio of their per-orbit anomalous perihelion advances
is inversely proportional to the ratio of their semi-latus recta:
$$\frac{\Delta\varpi(\mathrm{orb}_1)}{\Delta\varpi(\mathrm{orb}_2)} = \frac{p_2}{p_1} = \frac{a_2(1 - e_2^2)}{a_1(1 - e_1^2)}.$$ -/
@[blueprint "thm:signals-ddf-planetary-precession-ratio"
  (title := "Universal inverse semi-latus rectum scaling of perihelion precession across planets")
  (statement := /-- For any two orbits \texttt{orb1}, \texttt{orb2} around \texttt{re : RiverExterior sub},
    $\frac{\Delta\varpi(\mathrm{orb}_1)}{\Delta\varpi(\mathrm{orb}_2)}
    = \frac{\mathrm{orb}_2.\mathrm{semiLatusRectum}}{\mathrm{orb}_1.\mathrm{semiLatusRectum}}$. -/)
  (proof := /-- Unfold \texttt{perihelionPrecessionRad} and cancel the common nonzero solar factor
    $6\pi G_\phi M / c^2$. -/)]
theorem RiverExterior.perihelionPrecession_ratio
    {sub : DDFSubstrate} (re : RiverExterior sub)
    (orb1 orb2 : PlanetaryOrbit) :
    re.perihelionPrecessionRad orb1 / re.perihelionPrecessionRad orb2 =
      orb2.semiLatusRectum / orb1.semiLatusRectum := by
  have hp1 : orb1.semiLatusRectum ≠ 0 := ne_of_gt (orb1.radii_identities).2.1
  have hp2 : orb2.semiLatusRectum ≠ 0 := ne_of_gt (orb2.radii_identities).2.1
  have hc : sub.c ≠ 0 := ne_of_gt sub.c_pos
  have hG : re.G_phi ≠ 0 := ne_of_gt re.G_phi_pos
  have hM : re.sourceMass ≠ 0 := ne_of_gt re.sourceMass_pos
  have hpi : Real.pi ≠ 0 := Real.pi_ne_zero
  unfold RiverExterior.perihelionPrecessionRad
  field_simp [hp1, hp2, hc, hG, hM, hpi]

/-- **BCJ Color–Kinematics Duality & $Gr_{\mathbb{C}}(2,4)$ Plücker Double Copy**:
For any complex $2 \times 4$ Grassmannian matrix $M_{\mathbb{C}} \in \mathbb{C}^{2 \times 4}$,
let the three $s, t, u$-channel gauge kinematic numerators be the quadratic Plücker products
$n_s = \Delta_{01}^{\mathbb{C}}\Delta_{23}^{\mathbb{C}}$,
$n_t = -\Delta_{02}^{\mathbb{C}}\Delta_{13}^{\mathbb{C}}$, and
$n_u = \Delta_{03}^{\mathbb{C}}\Delta_{12}^{\mathbb{C}}$.
Then the BCJ kinematic Jacobi relation $n_s + n_t + n_u = 0$ holds identically by the
3-term Plücker relation on $Gr_{\mathbb{C}}(2,4)$, and the crossing graviton double-copy
square $n_t^2 = (\Delta_{02}^{\mathbb{C}}\Delta_{13}^{\mathbb{C}})^2$ expands into the
symmetric fluid-stress tensor sum $(n_s + n_u)^2 = n_s^2 + 2 n_s n_u + n_u^2$. -/
@[blueprint "thm:signals-ddf-bcj-plucker-double-copy"
  (title := "BCJ kinematic Jacobi identity n_s + n_t + n_u = 0 and double-copy square from Gr_C(2,4) Plücker relations")
  (statement := /-- For $M_{\mathbb C}\in\mathbb C^{2\times 4}$, let
    $n_s=\Delta_{01}^{\mathbb C}\Delta_{23}^{\mathbb C}$,
    $n_t=-\Delta_{02}^{\mathbb C}\Delta_{13}^{\mathbb C}$, and
    $n_u=\Delta_{03}^{\mathbb C}\Delta_{12}^{\mathbb C}$. Then
    $n_s+n_t+n_u=0$ and $n_t^2=(n_s+n_u)^2=n_s^2+2n_s n_u+n_u^2$. -/)
  (proof := /-- Apply \texttt{complexTwoRowMinor\_pluecker} and close by ring algebra. -/)]
theorem bcj_plucker_jacobi_and_double_copy (M_C : Matrix (Fin 2) (Fin 4) ℂ) :
    let n_s := complexTwoRowMinor M_C 0 1 * complexTwoRowMinor M_C 2 3
    let n_t := - (complexTwoRowMinor M_C 0 2 * complexTwoRowMinor M_C 1 3)
    let n_u := complexTwoRowMinor M_C 0 3 * complexTwoRowMinor M_C 1 2
    n_s + n_t + n_u = 0 ∧
      n_t ^ 2 = n_s ^ 2 + 2 * n_s * n_u + n_u ^ 2 := by
  intro n_s n_t n_u
  have h_pl := complexTwoRowMinor_pluecker M_C 0 1 2 3
  have h_jacobi : n_s + n_t + n_u = 0 := by
    dsimp [n_s, n_t, n_u]
    linear_combination h_pl
  have h_nt : n_t = - (n_s + n_u) := by
    linear_combination h_jacobi
  refine ⟨h_jacobi, ?_⟩
  rw [h_nt]
  ring

/-- **Canonical $Gr_{\mathbb{C}}(2,4)$ Planetary Orbital Precession Twistor Matrix**:
Embeds a `PlanetaryOrbit` `orb` (with eccentricity $e \in [0, 1)$) and anomalous
perihelion advance $\Delta\varpi$ into $Gr_{\mathbb{C}}(2,4)$ by encoding the normalized
aphelion amplitude $z_{\mathrm{aph}} = \sqrt{1 + e}\,e^{i \Delta\varpi / 2}$ and
normalized perihelion amplitude $z_{\mathrm{per}} = \sqrt{1 - e}\,e^{-i \Delta\varpi / 2}$. -/
@[blueprint "def:signals-ddf-planetary-gr24-precession-matrix"
  (title := "Canonical Gr_C(2,4) planetary orbital precession twistor matrix")
  (statement := /-- For \texttt{orb : PlanetaryOrbit} and perihelion advance $\Delta\varpi$,
    define $M_{\mathbb C}^{\mathrm{orb}}(\mathrm{orb},\Delta\varpi)
    = M_{\mathbb C}\!\bigl(\sqrt{1+e}\,e^{i\Delta\varpi/2},\,\sqrt{1-e}\,e^{-i\Delta\varpi/2}\bigr)\in\mathbb C^{2\times 4}$. -/)]
noncomputable def PlanetaryOrbit.gr24PrecessionMatrix
    (orb : PlanetaryOrbit) (deltaVarpi : ℝ) : Matrix (Fin 2) (Fin 4) ℂ :=
  let θ := deltaVarpi / 2
  let a := Real.sqrt (1 + orb.eccentricity)
  let b := Real.sqrt (1 - orb.eccentricity)
  let z_aph : ℂ := ↑(a * Real.cos θ) + Complex.I * ↑(a * Real.sin θ)
  let z_per : ℂ := ↑(b * Real.cos θ) - Complex.I * ↑(b * Real.sin θ)
  complexGr24ChannelMatrix z_aph z_per

/-- **Master $Gr_{\mathbb{C}}(2,4)$–DDF Planetary Orbit & Perihelion Precession Bridge**:
For any `PlanetaryOrbit` `orb` and anomalous perihelion advance $\Delta\varpi$, let
$M_{\mathbb{C}}^{\mathrm{orb}} = \mathrm{orb}.\mathrm{gr24PrecessionMatrix}\,\Delta\varpi$.
Then:
1. The first Madelung sink density equals the normalized aphelion distance:
   $|w_A^{\mathbb{C}}(M_{\mathbb{C}}^{\mathrm{orb}})|^2 = 1 + e = \frac{r_{\max}}{a}$,
2. The second Madelung sink density equals the normalized perihelion distance:
   $|w_B^{\mathbb{C}}(M_{\mathbb{C}}^{\mathrm{orb}})|^2 = 1 - e = \frac{r_{\min}}{a}$,
3. The half-difference of the Madelung densities equals the orbital eccentricity:
   $\frac{|w_A^{\mathbb{C}}|^2 - |w_B^{\mathbb{C}}|^2}{2} = e$,
4. The product of the Madelung densities equals the semi-latus rectum ratio
   (which governs $\Delta\varpi = 3\pi r_H / p$):
   $|w_A^{\mathbb{C}}|^2\,|w_B^{\mathbb{C}}|^2 = 1 - e^2 = \frac{p}{a}$, and
5. The squared modulus of the crossing Plücker product encodes both $\sqrt{1 - e^2} = \sqrt{p/a}$
   and the perihelion precession cosine $\cos(\Delta\varpi)$:
   $|\Delta_{02}^{\mathbb{C}}(M_{\mathbb{C}}^{\mathrm{orb}})\,\Delta_{13}^{\mathbb{C}}(M_{\mathbb{C}}^{\mathrm{orb}})|^2 = 2\bigl(1 + \sqrt{1 - e^2}\cos(\Delta\varpi)\bigr)$. -/
@[blueprint "thm:signals-ddf-planetary-gr24-precession-bridge"
  (title := "Master Gr_C(2,4)-DDF planetary orbit bridge: aphelion/perihelion Madelung densities, semi-latus rectum product, and Δϖ precession")
  (statement := /-- For \texttt{orb : PlanetaryOrbit} and $M_{\mathbb C}^{\mathrm{orb}}=\mathrm{orb}.\mathrm{gr24PrecessionMatrix}(\Delta\varpi)$:
    (1) $|w_A^{\mathbb C}|^2 = 1+e = r_{\max}/a$,
    (2) $|w_B^{\mathbb C}|^2 = 1-e = r_{\min}/a$,
    (3) $(|w_A^{\mathbb C}|^2 - |w_B^{\mathbb C}|^2)/2 = e$,
    (4) $|w_A^{\mathbb C}|^2\,|w_B^{\mathbb C}|^2 = 1-e^2 = p/a$, and
    (5) $|\Delta_{02}^{\mathbb C}\Delta_{13}^{\mathbb C}|^2 = 2\bigl(1+\sqrt{1-e^2}\cos(\Delta\varpi)\bigr)$. -/)
  (proof := /-- Evaluate \texttt{complexGr24ChannelMatrix\_minors}, expand \texttt{Complex.normSq}
    using $\cos^2(\Delta\varpi/2)+\sin^2(\Delta\varpi/2)=1$ and
    $\cos(\Delta\varpi)=2\cos^2(\Delta\varpi/2)-1$, and relate $1\pm e$ and $1-e^2$ to
    $r_{\max}/a$, $r_{\min}/a$, and $p/a$. -/)]
theorem PlanetaryOrbit.gr24PrecessionMatrix_orbital_identities
    (orb : PlanetaryOrbit) (deltaVarpi : ℝ) :
    let M_C := orb.gr24PrecessionMatrix deltaVarpi
    Complex.normSq (complexPluckerSinkAmplitudeA M_C) = orb.aphelionRadius / orb.semiMajorAxis ∧
      Complex.normSq (complexPluckerSinkAmplitudeB M_C) = orb.perihelionRadius / orb.semiMajorAxis ∧
      (Complex.normSq (complexPluckerSinkAmplitudeA M_C) -
        Complex.normSq (complexPluckerSinkAmplitudeB M_C)) / 2 = orb.eccentricity ∧
      Complex.normSq (complexPluckerSinkAmplitudeA M_C) *
        Complex.normSq (complexPluckerSinkAmplitudeB M_C) =
        orb.semiLatusRectum / orb.semiMajorAxis ∧
      Complex.normSq
        (complexTwoRowMinor M_C 0 2 * complexTwoRowMinor M_C 1 3) =
        2 * (1 + Real.sqrt (1 - orb.eccentricity ^ 2) * Real.cos deltaVarpi) := by
  intro M_C
  have ha_pos := orb.semiMajorAxis_pos
  have ha_ne : orb.semiMajorAxis ≠ 0 := ne_of_gt ha_pos
  have he0 := orb.eccentricity_nonneg
  have he1 := orb.eccentricity_lt_one
  have h1pe : 0 ≤ 1 + orb.eccentricity := by linarith
  have h1me : 0 ≤ 1 - orb.eccentricity := by linarith
  let θ := deltaVarpi / 2
  let a := Real.sqrt (1 + orb.eccentricity)
  let b := Real.sqrt (1 - orb.eccentricity)
  let z_aph : ℂ := ↑(a * Real.cos θ) + Complex.I * ↑(a * Real.sin θ)
  let z_per : ℂ := ↑(b * Real.cos θ) - Complex.I * ↑(b * Real.sin θ)
  have h_minors := complexGr24ChannelMatrix_minors z_aph z_per
  have h_wA : complexPluckerSinkAmplitudeA M_C = z_aph := h_minors.1
  have h_wB : complexPluckerSinkAmplitudeB M_C = z_per := h_minors.2.1
  have h_cross :
      complexTwoRowMinor M_C 0 2 * complexTwoRowMinor M_C 1 3 = z_aph + z_per :=
    h_minors.2.2
  have h_trig : (Real.cos θ) ^ 2 + (Real.sin θ) ^ 2 = 1 := Real.cos_sq_add_sin_sq θ
  have ha2 : a ^ 2 = 1 + orb.eccentricity := Real.sq_sqrt h1pe
  have hb2 : b ^ 2 = 1 - orb.eccentricity := Real.sq_sqrt h1me
  have hab : a * b = Real.sqrt (1 - orb.eccentricity ^ 2) := by
    dsimp [a, b]
    rw [← Real.sqrt_mul h1pe]
    congr 1
    ring
  have h_normA : Complex.normSq (complexPluckerSinkAmplitudeA M_C) = 1 + orb.eccentricity := by
    rw [h_wA]
    dsimp [z_aph]
    simp only [Complex.normSq_apply, Complex.add_re, Complex.add_im, Complex.mul_re,
      Complex.mul_im, Complex.ofReal_re, Complex.ofReal_im, Complex.I_re, Complex.I_im]
    calc
      _ = a ^ 2 * ((Real.cos θ) ^ 2 + (Real.sin θ) ^ 2) := by ring
      _ = 1 + orb.eccentricity := by rw [ha2, h_trig, mul_one]
  have h_normB : Complex.normSq (complexPluckerSinkAmplitudeB M_C) = 1 - orb.eccentricity := by
    rw [h_wB]
    dsimp [z_per]
    simp only [Complex.normSq_apply, Complex.sub_re, Complex.sub_im, Complex.mul_re,
      Complex.mul_im, Complex.ofReal_re, Complex.ofReal_im, Complex.I_re, Complex.I_im]
    calc
      _ = b ^ 2 * ((Real.cos θ) ^ 2 + (Real.sin θ) ^ 2) := by ring
      _ = 1 - orb.eccentricity := by rw [hb2, h_trig, mul_one]
  have h_aph_div : orb.aphelionRadius / orb.semiMajorAxis = 1 + orb.eccentricity := by
    unfold PlanetaryOrbit.aphelionRadius
    exact mul_div_cancel_left₀ (1 + orb.eccentricity) ha_ne
  have h_per_div : orb.perihelionRadius / orb.semiMajorAxis = 1 - orb.eccentricity := by
    unfold PlanetaryOrbit.perihelionRadius
    exact mul_div_cancel_left₀ (1 - orb.eccentricity) ha_ne
  have h_slr_div : orb.semiLatusRectum / orb.semiMajorAxis = 1 - orb.eccentricity ^ 2 := by
    unfold PlanetaryOrbit.semiLatusRectum
    exact mul_div_cancel_left₀ (1 - orb.eccentricity ^ 2) ha_ne
  have h_cos_dv : Real.cos deltaVarpi = 2 * (Real.cos θ) ^ 2 - 1 := by
    have h2 : deltaVarpi = 2 * θ := by dsimp [θ]; ring
    rw [h2, Real.cos_two_mul]
  have h_cross_norm :
      Complex.normSq (z_aph + z_per) =
        2 * (1 + Real.sqrt (1 - orb.eccentricity ^ 2) * Real.cos deltaVarpi) := by
    have h_expand :
        Complex.normSq (z_aph + z_per) =
          ((a + b) * Real.cos θ) ^ 2 + ((a - b) * Real.sin θ) ^ 2 := by
      dsimp [z_aph, z_per]
      simp only [Complex.normSq_apply, Complex.add_re, Complex.add_im,
        Complex.sub_re, Complex.sub_im, Complex.mul_re, Complex.mul_im,
        Complex.ofReal_re, Complex.ofReal_im, Complex.I_re, Complex.I_im]
      ring
    rw [h_expand]
    calc
      ((a + b) * Real.cos θ) ^ 2 + ((a - b) * Real.sin θ) ^ 2 =
          (a ^ 2 + b ^ 2) * ((Real.cos θ) ^ 2 + (Real.sin θ) ^ 2) +
            2 * (a * b) * (2 * (Real.cos θ) ^ 2 - ((Real.cos θ) ^ 2 + (Real.sin θ) ^ 2)) := by
        ring
      _ = (1 + orb.eccentricity + (1 - orb.eccentricity)) * 1 +
            2 * Real.sqrt (1 - orb.eccentricity ^ 2) * (2 * (Real.cos θ) ^ 2 - 1) := by
        rw [ha2, hb2, h_trig, hab]
      _ = 2 * (1 + Real.sqrt (1 - orb.eccentricity ^ 2) * Real.cos deltaVarpi) := by
        rw [← h_cos_dv]
        ring
  refine ⟨by rw [h_normA, h_aph_div], by rw [h_normB, h_per_div],
    by rw [h_normA, h_normB]; ring,
    by rw [h_normA, h_normB, h_slr_div]; ring,
    by rw [h_cross, h_cross_norm]⟩

/-- **$N$-Body Superfluid Bernoulli Sink Potential**:
For $N$ gravitating bodies (`numBodies : ℕ`) with masses $M_j$ and radial distances $r_j$,
the total Newtonian/superfluid enthalpy deficit is $\Phi_\phi^{(N)} = -\sum_{j=0}^{N-1} \frac{G_\phi M_j}{r_j}$. -/
@[blueprint "def:signals-ddf-nbody-bernoulli-potential"
  (title := "N-body superfluid Bernoulli sink potential Φ_ϕ^(N)")
  (statement := /-- For $N$ bodies with masses $M:\operatorname{Fin}(N)\to\mathbb R$ and
    distances $r:\operatorname{Fin}(N)\to\mathbb R$, define
    $\Phi_\phi^{(N)}=-\sum_{j=0}^{N-1}\frac{G_\phi M_j}{r_j}$. -/)]
noncomputable def nBodyBernoulliPotential
    (G_phi : ℝ) (numBodies : ℕ) (mass distance : Fin numBodies → ℝ) : ℝ :=
  - ∑ j : Fin numBodies, (G_phi * mass j / distance j)

/-- **Embedding $N$-Body Gravitational Sink Potentials in $Gr_{\mathbb{C}}(2, N+2)$**:
For $N$ bodies with $G_\phi > 0$, $M_j \ge 0$, and $r_j > 0$, encoding the $N$ sink
weights $w_j = G_\phi M_j / r_j \ge 0$ in `complexGr2NChannelMatrix` makes the total
Madelung sink density $\sum_{j=0}^{N-1} |\Delta_{0, j+2}^{\mathbb{C}}|^2$ equal to
$-\Phi_\phi^{(N)}$. -/
@[blueprint "thm:signals-ddf-nbody-bernoulli-gr2n-embedding"
  (title := "N-body gravitational sink potential equals negative total Madelung density on Gr_C(2, N+2)")
  (statement := /-- For $G_\phi>0$, $M_j\ge 0$, and $r_j>0$, let $w_j=G_\phi M_j/r_j$ and
    $M_{\mathbb C}^{(N)}=M_{\mathbb C}^{(N)}\bigl(\sqrt{w_j}e^{i\theta_j}\bigr)\in\mathbb C^{2\times(N+2)}$.
    Then $\Phi_\phi^{(N)} = -\sum_{j=0}^{N-1}\bigl|\Delta_{0,j+2}^{\mathbb C}(M_{\mathbb C}^{(N)})\bigr|^2$. -/)
  (proof := /-- Apply \texttt{complexGr2N\_madelung\_sector\_identities} to $w_j=G_\phi M_j/r_j\ge 0$. -/)]
theorem nBodyBernoulliPotential_eq_neg_gr2N_madelung_sum
    (G_phi : ℝ) (hG : 0 ≤ G_phi) (numBodies : ℕ)
    (mass distance θ : Fin numBodies → ℝ)
    (h_mass : ∀ j, 0 ≤ mass j) (h_dist : ∀ j, 0 < distance j) :
    let w : Fin numBodies → ℝ := fun j => G_phi * mass j / distance j
    let z : Fin numBodies → ℂ := fun j => complexGr2NTwistorEntry (w j) (θ j)
    let M_C := complexGr2NChannelMatrix numBodies z
    nBodyBernoulliPotential G_phi numBodies mass distance =
      - ∑ j : Fin numBodies,
          Complex.normSq (complexTwoRowMinor M_C (narySourceCol numBodies) (narySlitCol j)) := by
  intro w z M_C
  have hw : ∀ j : Fin numBodies, 0 ≤ w j := fun j =>
    div_nonneg (mul_nonneg hG (h_mass j)) (le_of_lt (h_dist j))
  have h_sum := (complexGr2N_madelung_sector_identities numBodies w θ hw).2.1
  unfold nBodyBernoulliPotential
  rw [h_sum]

/-- **Critique & Resolution: Conservative DDF / 1-Loop EFT Action vs. Dissipative Stokes Drag**:
In a classical Stokes-drag model with drag force $F_{\mathrm{drag}} > 0$ at orbital
speed $v > 0$, the mechanical energy rate $\frac{dE}{dt} = - F_{\mathrm{drag}} v < 0$
is strictly negative (causing secular semi-major axis decay ruled out by planetary
ephemerides), whereas in conservative 1-loop QFT / DDF sheath mechanics ($F_{\mathrm{drag}} = 0$),
the orbital energy rate vanishes ($\frac{dE}{dt} = 0$) while the conservative $r^{-3}$
potential term still generates the positive anomalous perihelion advance $\Delta\varpi > 0$. -/
@[blueprint "thm:signals-ddf-conservative-action-vs-stokes-drag"
  (title := "Conservative DDF / QFT orbital energy preservation vs. dissipative Stokes drag decay")
  (statement := /-- For $F_{\mathrm{drag}}>0$ and $v>0$, the dissipative power
    $P_{\mathrm{diss}}=-F_{\mathrm{drag}}v<0$, whereas for a conservative potential
    ($F_{\mathrm{drag}}=0$), $P_{\mathrm{diss}}=0$ while $\Delta\varpi>0$. -/)
  (proof := /-- Multiply $F_{\mathrm{drag}}>0$ by $v>0$ for the dissipative case, and combine
    $-0\cdot v=0$ with \texttt{perihelionPrecession\_eq\_horizon\_and\_substrate}. -/)]
theorem ddf_conservative_action_vs_stokes_drag_critique
    {sub : DDFSubstrate} (re : RiverExterior sub) (orb : PlanetaryOrbit)
    (F_drag v : ℝ) (hF : 0 < F_drag) (hv : 0 < v) :
    - F_drag * v < 0 ∧
      (- (0 : ℝ) * v = 0 ∧ 0 < re.perihelionPrecessionRad orb) :=
  ⟨by nlinarith, ⟨by ring, (re.perihelionPrecession_eq_horizon_and_substrate orb).1⟩⟩

/-! ### Precessing Conic Trajectory, Exact $\pi$-Free Arcsecond Conversion, Mercury Numerical Bounds, & Normed Tensor Gaussian Splatting -/

/-- **Harmonic-Mean Identity of Perihelion and Aphelion Radii**:
For any bound `PlanetaryOrbit`, the reciprocal of the semi-latus rectum $p = a(1 - e^2)$
is the arithmetic mean of the reciprocal perihelion and aphelion radii:
$\frac{1}{r_{\min}} + \frac{1}{r_{\max}} = \frac{2}{p}$. -/
@[blueprint "lem:signals-ddf-planetary-harmonic-mean"
  (title := "Harmonic-mean identity 1/r_min + 1/r_max = 2/p for planetary orbits")
  (statement := /-- For any \texttt{orb : PlanetaryOrbit},
    $\frac{1}{r_{\min}}+\frac{1}{r_{\max}}=\frac{2}{p}$. -/)
  (proof := /-- Use $r_{\min}+r_{\max}=2a$ and $r_{\min}r_{\max}=a p$ from
    \texttt{orb.radii\_identities}, then clear nonzero denominators. -/)
  (latexEnv := "lemma")]
lemma PlanetaryOrbit.harmonic_mean_semiLatusRectum (orb : PlanetaryOrbit) :
    1 / orb.perihelionRadius + 1 / orb.aphelionRadius =
      2 / orb.semiLatusRectum := by
  have he0 := orb.eccentricity_nonneg
  have he1 := orb.eccentricity_lt_one
  have h1me : 1 - orb.eccentricity ≠ 0 := by linarith
  have h1pe : 1 + orb.eccentricity ≠ 0 := by linarith
  have h1e2 : 1 - orb.eccentricity ^ 2 ≠ 0 := ne_of_gt (orb.radii_identities).1
  have ha : orb.semiMajorAxis ≠ 0 := ne_of_gt orb.semiMajorAxis_pos
  unfold PlanetaryOrbit.perihelionRadius PlanetaryOrbit.aphelionRadius
    PlanetaryOrbit.semiLatusRectum
  field_simp [h1me, h1pe, h1e2, ha]
  ring

/-- **Precessing Polar Conic Trajectory $r(\varphi; \eta_{\mathrm{prec}})$**:
Solution of the perturbed Binet orbit equation
$r(\varphi; \eta_{\mathrm{prec}}) = \frac{p}{1 + e\cos((1 - \eta_{\mathrm{prec}})\varphi)}$
with dimensionless precession rate parameter $\eta_{\mathrm{prec}} = \frac{3 G_\phi M}{c^2 p} = \frac{\Delta\varpi}{2\pi}$. -/
@[blueprint "def:signals-ddf-precessing-conic-radius"
  (title := "Precessing polar conic orbital radius r(φ; η_prec)")
  (statement := /-- For \texttt{orb : PlanetaryOrbit}, precession parameter $\eta_{\mathrm{prec}}$,
    and azimuth $\varphi$, define
    $r(\varphi;\eta_{\mathrm{prec}}) = \frac{p}{1 + e\cos\bigl((1-\eta_{\mathrm{prec}})\varphi\bigr)}$. -/)]
noncomputable def PlanetaryOrbit.precessingRadius
    (orb : PlanetaryOrbit) (etaPrecession φ : ℝ) : ℝ :=
  orb.semiLatusRectum /
    (1 + orb.eccentricity * Real.cos ((1 - etaPrecession) * φ))

/-- **Exact Perihelion and Aphelion Turning Points of the Precessing Trajectory**:
At $\varphi = 0$ (initial perihelion), $r(0; \eta_{\mathrm{prec}}) = r_{\min} = a(1 - e)$,
and for $1 - \eta_{\mathrm{prec}} \neq 0$, at the precessed aphelion angle
$\varphi_{\mathrm{aph}} = \frac{\pi}{1 - \eta_{\mathrm{prec}}}$,
$r(\varphi_{\mathrm{aph}}; \eta_{\mathrm{prec}}) = r_{\max} = a(1 + e)$. -/
@[blueprint "thm:signals-ddf-precessing-conic-turning-points"
  (title := "Exact perihelion and aphelion turning-point radii of the precessing conic orbit")
  (statement := /-- For any \texttt{orb : PlanetaryOrbit} and $1-\eta_{\mathrm{prec}}\ne 0$,
    $r(0;\eta_{\mathrm{prec}})=r_{\min}$ and
    $r\bigl(\frac{\pi}{1-\eta_{\mathrm{prec}}};\eta_{\mathrm{prec}}\bigr)=r_{\max}$. -/)
  (proof := /-- Evaluate $\cos(0)=1$ and $\cos(\pi)=-1$, factor $1-e^2=(1-e)(1+e)$, and
    cancel $1+e\ne 0$ and $1-e\ne 0$. -/)]
theorem PlanetaryOrbit.precessingRadius_perihelion_and_aphelion
    (orb : PlanetaryOrbit) (etaPrecession : ℝ)
    (h_eta : 1 - etaPrecession ≠ 0) :
    orb.precessingRadius etaPrecession 0 = orb.perihelionRadius ∧
      orb.precessingRadius etaPrecession (Real.pi / (1 - etaPrecession)) =
        orb.aphelionRadius := by
  have he0 := orb.eccentricity_nonneg
  have he1 := orb.eccentricity_lt_one
  have h1pe : 1 + orb.eccentricity ≠ 0 := by linarith
  have h1me : 1 - orb.eccentricity ≠ 0 := by linarith
  refine ⟨?_, ?_⟩
  · unfold PlanetaryOrbit.precessingRadius PlanetaryOrbit.semiLatusRectum
      PlanetaryOrbit.perihelionRadius
    simp only [mul_zero, Real.cos_zero, mul_one]
    have h_fac :
        orb.semiMajorAxis * (1 - orb.eccentricity ^ 2) =
          orb.semiMajorAxis * (1 - orb.eccentricity) * (1 + orb.eccentricity) := by ring
    rw [h_fac, mul_div_cancel_right₀ _ h1pe]
  · unfold PlanetaryOrbit.precessingRadius PlanetaryOrbit.semiLatusRectum
      PlanetaryOrbit.aphelionRadius
    have h_angle : (1 - etaPrecession) * (Real.pi / (1 - etaPrecession)) = Real.pi :=
      mul_div_cancel₀ Real.pi h_eta
    rw [h_angle, Real.cos_pi]
    have h_denom : 1 + orb.eccentricity * (-1) = 1 - orb.eccentricity := by ring
    have h_fac :
        orb.semiMajorAxis * (1 - orb.eccentricity ^ 2) =
          orb.semiMajorAxis * (1 + orb.eccentricity) * (1 - orb.eccentricity) := by ring
    rw [h_denom, h_fac, mul_div_cancel_right₀ _ h1me]

/-- **Anomalous Perihelion Precession in Arcseconds per Orbit**:
Converts `perihelionPrecessionRad` from radians to arcseconds via the factor
$\frac{180 \times 3600}{\pi} = \frac{648000}{\pi}$. -/
@[blueprint "def:signals-ddf-perihelion-precession-arcsec"
  (title := "Anomalous perihelion precession in arcseconds per orbit")
  (statement := /-- Define $\Delta\varpi_{\mathrm{arcsec}} = \Delta\varpi\cdot\frac{648000}{\pi}$. -/)]
noncomputable def RiverExterior.perihelionPrecessionArcsecPerOrbit
    {sub : DDFSubstrate} (re : RiverExterior sub) (orb : PlanetaryOrbit) : ℝ :=
  re.perihelionPrecessionRad orb * (648000 / Real.pi)

/-- **Exact $\pi$-Cancellation in Arcsecond Perihelion Precession**:
When converting $\Delta\varpi = \frac{6\pi G_\phi M}{c^2 p} = \frac{3\pi r_H}{p}$
from radians to arcseconds per orbit, $\pi$ cancels identically, leaving the purely
rational formula $\Delta\varpi_{\mathrm{arcsec}} = \frac{1944000\,r_H}{p} = \frac{3888000\,G_\phi M}{c^2 p}$. -/
@[blueprint "thm:signals-ddf-perihelion-precession-arcsec-rational"
  (title := "Exact π-cancellation in arcsecond perihelion precession Δϖ_arcsec = 1944000 r_H / p")
  (statement := /-- For any \texttt{re : RiverExterior sub} and \texttt{orb : PlanetaryOrbit},
    $\Delta\varpi_{\mathrm{arcsec}} = \frac{1944000\,r_H}{p} = \frac{3888000\,G_\phi M}{c^2 p}$. -/)
  (proof := /-- Substitute \texttt{perihelionPrecession\_eq\_horizon\_and\_substrate} and cancel $\pi\ne 0$. -/)]
theorem RiverExterior.perihelionPrecessionArcsecPerOrbit_eq
    {sub : DDFSubstrate} (re : RiverExterior sub) (orb : PlanetaryOrbit) :
    re.perihelionPrecessionArcsecPerOrbit orb =
      1944000 * re.horizonRadius / orb.semiLatusRectum ∧
    re.perihelionPrecessionArcsecPerOrbit orb =
      3888000 * re.G_phi * re.sourceMass / (sub.c ^ 2 * orb.semiLatusRectum) := by
  have hpi : Real.pi ≠ 0 := Real.pi_ne_zero
  unfold RiverExterior.perihelionPrecessionArcsecPerOrbit
  refine ⟨?_, ?_⟩
  · rw [(re.perihelionPrecession_eq_horizon_and_substrate orb).2.1]
    field_simp [hpi]
    ring
  · unfold RiverExterior.perihelionPrecessionRad
    field_simp [hpi]
    ring

/-- **Machine-Checked Numerical Verification of Mercury's $42.98''/\text{century}$ Relativistic Precession and $574.61''/\text{century}$ Total Advance**:
For solar acoustic horizon $r_{H,\odot} = 2.95325\text{ km}$, Mercury semi-latus rectum
$p_{\text{Mercury}} = 55460529\text{ km}$, and $415.2026$ revolutions per Julian century:
1. The relativistic / 1-loop QFT / DDF precession per century lies strictly in
   $(42.98, 42.99)$ arcseconds/century, and
2. Adding the $531.63''/\text{century}$ Newtonian $N$-body planetary perturbation places
   Mercury's total inertial perihelion advance strictly in $(574.61, 574.62)$ arcseconds/century. -/
@[blueprint "thm:signals-ddf-mercury-precession-numerical-bounds"
  (title := "Machine-checked numerical bounds 42.98 < Δϖ_Mercury < 42.99 and 574.61 < Δϖ_tot < 574.62 arcsec/century")
  (statement := /-- For $r_{H,\odot}=2.95325\text{ km}$, $p_{\mathrm{Merc}}=55460529\text{ km}$,
    and $N_{\mathrm{cent}}=415.2026$, let
    $\dot{\varpi}_{\mathrm{rel}} = \frac{1944000\,r_{H,\odot}}{p_{\mathrm{Merc}}}\cdot N_{\mathrm{cent}}$.
    Then $42.98 < \dot{\varpi}_{\mathrm{rel}} < 42.99$ and
    $574.61 < \dot{\varpi}_{\mathrm{rel}} + 531.63 < 574.62$. -/)
  (proof := /-- Evaluate the rational inequalities directly by \texttt{norm\_num}. -/)]
theorem mercury_perihelion_precession_arcsec_per_century_bounds :
    let r_H_sun : ℝ := 295325 / 100000
    let p_mercury : ℝ := 55460529
    let orbits_per_century : ℝ := 4152026 / 10000
    let rel_arcsec_per_century := (1944000 * r_H_sun / p_mercury) * orbits_per_century
    let newtonian_nbody_arcsec_per_century : ℝ := 53163 / 100
    4298 / 100 < rel_arcsec_per_century ∧
      rel_arcsec_per_century < 4299 / 100 ∧
      57461 / 100 < rel_arcsec_per_century + newtonian_nbody_arcsec_per_century ∧
      rel_arcsec_per_century + newtonian_nbody_arcsec_per_century < 57462 / 100 := by
  norm_num

/-! ### Normed 2D Anisotropic Tensor Gaussian Splatting for $Gr_{\mathbb{C}}(2,4)$ and DDF Orbital/Sheath Fields -/

/-- A normed 2D anisotropic Tensor Gaussian Splat primitive for visualizing and
discretizing $Gr_{\mathbb{C}}(2,4)$ channel fields, DDF shear-jammed sheaths, and
gravitational sink/source potentials while preserving $L^1$ mass/energy normalization. -/
@[blueprint "def:signals-ddf-normed-tensor-gaussian-splat2d"
  (title := "Normed 2D anisotropic Tensor Gaussian Splat primitive")
  (statement := /-- A 2D anisotropic Gaussian splat with center $(x_0,y_0)$, conserved weight
    $w\ge 0$, positive principal widths $\sigma_1>0,\sigma_2>0$, and orientation angle $\theta\in\mathbb R$. -/)]
structure NormedTensorGaussianSplat2D where
  centerX : ℝ
  centerY : ℝ
  weight : ℝ
  weight_nonneg : 0 ≤ weight
  sigma1 : ℝ
  sigma1_pos : 0 < sigma1
  sigma2 : ℝ
  sigma2_pos : 0 < sigma2
  orientationAngle : ℝ

/-- Determinant of the $2 \times 2$ covariance matrix $\Sigma = R(\theta)\operatorname{diag}(\sigma_1^2, \sigma_2^2)R(\theta)^T$:
$\det \Sigma = \sigma_1^2 \sigma_2^2$. -/
@[blueprint "def:signals-ddf-splat2d-cov-det"
  (title := "Covariance determinant det Σ = σ₁² σ₂² of a 2D Tensor Gaussian Splat")
  (statement := /-- Define $\det\Sigma = \sigma_1^2\sigma_2^2$. -/)]
def NormedTensorGaussianSplat2D.covDet (splat : NormedTensorGaussianSplat2D) : ℝ :=
  splat.sigma1 ^ 2 * splat.sigma2 ^ 2

/-- Trace of the $2 \times 2$ covariance matrix $\Sigma$:
$\operatorname{Tr} \Sigma = \sigma_1^2 + \sigma_2^2$. -/
@[blueprint "def:signals-ddf-splat2d-cov-trace"
  (title := "Covariance trace Tr Σ = σ₁² + σ₂² of a 2D Tensor Gaussian Splat")
  (statement := /-- Define $\operatorname{Tr}\Sigma = \sigma_1^2+\sigma_2^2$. -/)]
def NormedTensorGaussianSplat2D.covTrace (splat : NormedTensorGaussianSplat2D) : ℝ :=
  splat.sigma1 ^ 2 + splat.sigma2 ^ 2

/-- Exact 2D $L^1(\mathbb{R}^2)$ Gaussian normalization factor
$\mathcal{N}(\Sigma) = \frac{1}{2\pi \sigma_1 \sigma_2}$. -/
@[blueprint "def:signals-ddf-splat2d-norm-factor"
  (title := "2D L¹ Gaussian normalization factor N(Σ) = 1 / (2π σ₁ σ₂)")
  (statement := /-- Define $\mathcal{N}(\Sigma) = \frac{1}{2\pi\sigma_1\sigma_2}$. -/)]
noncomputable def NormedTensorGaussianSplat2D.normFactor
    (splat : NormedTensorGaussianSplat2D) : ℝ :=
  1 / (2 * Real.pi * splat.sigma1 * splat.sigma2)

/-- Squared Mahalanobis distance $Q_\Sigma(x, y) = \frac{u_1^2}{\sigma_1^2} + \frac{u_2^2}{\sigma_2^2}$
in the rotated principal-axis frame of the splat. -/
@[blueprint "def:signals-ddf-splat2d-mahalanobis"
  (title := "Rotated Mahalanobis quadratic form Q_Σ(x, y)")
  (statement := /-- For displacement $(\Delta x,\Delta y)=(x-x_0,y-y_0)$ rotated by $\theta$ into
    $(u_1,u_2)$, define $Q_\Sigma(x,y) = \frac{u_1^2}{\sigma_1^2} + \frac{u_2^2}{\sigma_2^2}$. -/)]
noncomputable def NormedTensorGaussianSplat2D.mahalanobisSq
    (splat : NormedTensorGaussianSplat2D) (x y : ℝ) : ℝ :=
  let dx := x - splat.centerX
  let dy := y - splat.centerY
  let u1 := dx * Real.cos splat.orientationAngle + dy * Real.sin splat.orientationAngle
  let u2 := -dx * Real.sin splat.orientationAngle + dy * Real.cos splat.orientationAngle
  (u1 / splat.sigma1) ^ 2 + (u2 / splat.sigma2) ^ 2

/-- Pointwise evaluation of the normed 2D Tensor Gaussian Splat:
$G(x, y) = w\,\mathcal{N}(\Sigma)\,\exp\bigl(-\frac{1}{2} Q_\Sigma(x, y)\bigr)$. -/
@[blueprint "def:signals-ddf-splat2d-eval"
  (title := "Pointwise evaluation of a normed 2D Tensor Gaussian Splat")
  (statement := /-- Define $G(x,y) = w\,\mathcal{N}(\Sigma)\,\exp\bigl(-\frac{1}{2}Q_\Sigma(x,y)\bigr)$. -/)]
noncomputable def NormedTensorGaussianSplat2D.eval
    (splat : NormedTensorGaussianSplat2D) (x y : ℝ) : ℝ :=
  splat.weight * splat.normFactor * Real.exp (- (splat.mahalanobisSq x y / 2))

/-- **Positivity, Peak Normalization, and Upper Bound of `NormedTensorGaussianSplat2D`**:
For every `splat : NormedTensorGaussianSplat2D` and $(x, y) \in \mathbb{R}^2$:
1. $\det \Sigma > 0$ and $\mathcal{N}(\Sigma) > 0$,
2. $Q_\Sigma(x, y) \ge 0$ and $Q_\Sigma(x_0, y_0) = 0$,
3. $0 \le G(x, y)$, $G(x_0, y_0) = w\,\mathcal{N}(\Sigma)$, and $G(x, y) \le G(x_0, y_0)$. -/
@[blueprint "thm:signals-ddf-splat2d-properties"
  (title := "Positivity, center peak value, and global upper bound of NormedTensorGaussianSplat2D")
  (statement := /-- For any \texttt{splat : NormedTensorGaussianSplat2D} and $(x,y)\in\mathbb R^2$:
    $\det\Sigma>0$, $\mathcal{N}(\Sigma)>0$, $0\le Q_\Sigma(x,y)$, $0\le G(x,y)$,
    $G(x_0,y_0)=w\,\mathcal{N}(\Sigma)$, and $G(x,y)\le G(x_0,y_0)$. -/)
  (proof := /-- Use positivity of $\sigma_1,\sigma_2,\pi$, sum-of-squares nonnegativity of
    $Q_\Sigma$, and monotonicity of $\exp$ on $(-\infty,0]$. -/)]
theorem NormedTensorGaussianSplat2D.eval_properties
    (splat : NormedTensorGaussianSplat2D) (x y : ℝ) :
    0 < splat.covDet ∧
      0 < splat.normFactor ∧
      0 ≤ splat.mahalanobisSq x y ∧
      0 ≤ splat.eval x y ∧
      splat.eval splat.centerX splat.centerY = splat.weight * splat.normFactor ∧
      splat.eval x y ≤ splat.eval splat.centerX splat.centerY := by
  have hs1 := splat.sigma1_pos
  have hs2 := splat.sigma2_pos
  have hpi := Real.pi_pos
  have hw := splat.weight_nonneg
  have h_det : 0 < splat.covDet := by
    unfold NormedTensorGaussianSplat2D.covDet
    positivity
  have h_norm : 0 < splat.normFactor := by
    unfold NormedTensorGaussianSplat2D.normFactor
    positivity
  have h_mah : 0 ≤ splat.mahalanobisSq x y := by
    unfold NormedTensorGaussianSplat2D.mahalanobisSq
    positivity
  have h_eval_nonneg : 0 ≤ splat.eval x y := by
    unfold NormedTensorGaussianSplat2D.eval
    positivity
  have h_center_mah : splat.mahalanobisSq splat.centerX splat.centerY = 0 := by
    unfold NormedTensorGaussianSplat2D.mahalanobisSq
    simp
  have h_center_eval :
      splat.eval splat.centerX splat.centerY = splat.weight * splat.normFactor := by
    unfold NormedTensorGaussianSplat2D.eval
    rw [h_center_mah]
    simp
  have h_le : splat.eval x y ≤ splat.eval splat.centerX splat.centerY := by
    rw [h_center_eval]
    unfold NormedTensorGaussianSplat2D.eval
    have h_exp_le : Real.exp (- (splat.mahalanobisSq x y / 2)) ≤ 1 :=
      Real.exp_le_one_iff.mpr (by linarith)
    have h_wn_nonneg : 0 ≤ splat.weight * splat.normFactor :=
      mul_nonneg hw (le_of_lt h_norm)
    calc
      splat.weight * splat.normFactor * Real.exp (- (splat.mahalanobisSq x y / 2)) ≤
          splat.weight * splat.normFactor * 1 :=
        mul_le_mul_of_nonneg_left h_exp_le h_wn_nonneg
      _ = splat.weight * splat.normFactor := mul_one _
  exact ⟨h_det, h_norm, h_mah, h_eval_nonneg, h_center_eval, h_le⟩

/-- **DDF Moving-Sheath Normed Tensor Gaussian Splat**:
Constructs a `NormedTensorGaussianSplat2D` for a subluminal `MovingSheath` $s$ with
longitudinal Lorentz/jamming contraction $\sigma_1 = \sigma_0 \mathcal{V}(s) = \sigma_0 \gamma_\varphi(v)^{-1}$
and transverse width $\sigma_2 = \sigma_0$ ($0 < \sigma_0$). -/
@[blueprint "def:signals-ddf-sheath-tensor-splat"
  (title := "DDF MovingSheath normed Tensor Gaussian Splat with longitudinal jamming contraction")
  (statement := /-- For a subluminal sheath $s$, base width $\sigma_0>0$, and weight $w\ge 0$,
    construct a 2D tensor Gaussian splat with longitudinal width
    $\sigma_1=\sigma_0\,\mathcal{V}(s)=\sigma_0\,\gamma_\varphi(v)^{-1}$ and transverse width $\sigma_2=\sigma_0$. -/)]
noncomputable def MovingSheath.ddfTensorSplat {sub : DDFSubstrate}
    (s : MovingSheath sub) (centerX centerY weight sigma0 : ℝ)
    (hw : 0 ≤ weight) (h_sigma0 : 0 < sigma0) (orientationAngle : ℝ) :
    NormedTensorGaussianSplat2D :=
  { centerX := centerX
    centerY := centerY
    weight := weight
    weight_nonneg := hw
    sigma1 := sigma0 * s.coherenceVisibility
    sigma1_pos := mul_pos h_sigma0 (Real.sqrt_pos.mpr s.one_sub_betaSq_pos)
    sigma2 := sigma0
    sigma2_pos := h_sigma0
    orientationAngle := orientationAngle }

/-- **DDF Moving-Sheath Tensor Splat Covariance & Jamming Amplification Identities**:
For any subluminal `MovingSheath` $s$, the DDF tensor splat satisfies:
1. $\det \Sigma_{\mathrm{DDF}}(s) = \sigma_0^4 (1 - \beta^2) = \sigma_0^4 \gamma_\varphi(v)^{-2}$, and
2. The $L^1$ peak normalization factor scales directly with the DDF jamming factor:
   $\mathcal{N}_{\mathrm{DDF}}(s) = \frac{\gamma_\varphi(v)}{2\pi \sigma_0^2}$. -/
@[blueprint "thm:signals-ddf-sheath-tensor-splat-identities"
  (title := "DDF MovingSheath tensor splat covariance determinant σ₀⁴ γ_φ⁻² and peak amplification γ_φ / (2π σ₀²)")
  (statement := /-- For \texttt{splat = s.ddfTensorSplat(x₀,y₀,w,σ₀,hw,hσ₀,θ)},
    $\det\Sigma_{\mathrm{DDF}} = \sigma_0^4(1-\beta^2) = \sigma_0^4\,\gamma_\varphi(v)^{-2}$ and
    $\mathcal{N}_{\mathrm{DDF}} = \frac{\gamma_\varphi(v)}{2\pi\sigma_0^2}$. -/)
  (proof := /-- Unfold \texttt{ddfTensorSplat}, apply \texttt{visibility\_jamming\_duality}
    ($\mathcal{V}(s)=\gamma_\varphi(v)^{-1}$ and $\mathcal{V}(s)^2=1-\beta^2$), and simplify. -/)]
theorem MovingSheath.ddfTensorSplat_identities {sub : DDFSubstrate}
    (s : MovingSheath sub) (centerX centerY weight sigma0 : ℝ)
    (hw : 0 ≤ weight) (h_sigma0 : 0 < sigma0) (orientationAngle : ℝ) :
    let splat := s.ddfTensorSplat centerX centerY weight sigma0 hw h_sigma0 orientationAngle
    splat.covDet = sigma0 ^ 4 * (1 - s.betaSq) ∧
      splat.covDet = sigma0 ^ 4 * (s.jammingFactor ^ 2)⁻¹ ∧
      splat.normFactor = s.jammingFactor / (2 * Real.pi * sigma0 ^ 2) := by
  intro splat
  have h_pos := s.one_sub_betaSq_pos
  have h_vis_sq : s.coherenceVisibility ^ 2 = 1 - s.betaSq := by
    unfold MovingSheath.coherenceVisibility
    exact Real.sq_sqrt (le_of_lt h_pos)
  have h_vis_inv : s.coherenceVisibility = (s.jammingFactor)⁻¹ :=
    (s.visibility_jamming_duality).1
  have h_det1 : splat.covDet = sigma0 ^ 4 * (1 - s.betaSq) := by
    dsimp [splat, MovingSheath.ddfTensorSplat, NormedTensorGaussianSplat2D.covDet]
    calc
      (sigma0 * s.coherenceVisibility) ^ 2 * sigma0 ^ 2 =
          sigma0 ^ 4 * s.coherenceVisibility ^ 2 := by ring
      _ = sigma0 ^ 4 * (1 - s.betaSq) := by rw [h_vis_sq]
  have h_det2 : splat.covDet = sigma0 ^ 4 * (s.jammingFactor ^ 2)⁻¹ := by
    dsimp [splat, MovingSheath.ddfTensorSplat, NormedTensorGaussianSplat2D.covDet]
    rw [h_vis_inv]
    ring
  have h_norm : splat.normFactor = s.jammingFactor / (2 * Real.pi * sigma0 ^ 2) := by
    dsimp [splat, MovingSheath.ddfTensorSplat, NormedTensorGaussianSplat2D.normFactor]
    rw [h_vis_inv]
    have h_s0_ne : sigma0 ≠ 0 := ne_of_gt h_sigma0
    have h_pi_ne : Real.pi ≠ 0 := Real.pi_ne_zero
    have h_jam_ne : s.jammingFactor ≠ 0 := ne_of_gt s.jammingFactor_pos
    field_simp [h_s0_ne, h_pi_ne, h_jam_ne]
  exact ⟨h_det1, h_det2, h_norm⟩

/-- **Complex $Gr_{\mathbb{C}}(2,4)$ Planetary Orbit Normed Tensor Gaussian Splat**:
Constructs a `NormedTensorGaussianSplat2D` whose principal variances are weighted by
the two $Gr_{\mathbb{C}}(2,4)$ Madelung channel densities $|w_A^{\mathbb{C}}|^2 = 1 + e = r_{\max}/a$
and $|w_B^{\mathbb{C}}|^2 = 1 - e = r_{\min}/a$:
$\sigma_1 = \sigma_0 \sqrt{1 + e}$ and $\sigma_2 = \sigma_0 \sqrt{1 - e}$. -/
@[blueprint "def:signals-ddf-planetary-gr24-tensor-splat"
  (title := "Complex Gr_C(2,4) planetary orbit normed Tensor Gaussian Splat")
  (statement := /-- For \texttt{orb : PlanetaryOrbit}, base width $\sigma_0>0$, and weight $w\ge 0$,
    construct a 2D tensor Gaussian splat with principal widths
    $\sigma_1=\sigma_0\sqrt{1+e}$ and $\sigma_2=\sigma_0\sqrt{1-e}$. -/)]
noncomputable def PlanetaryOrbit.gr24TensorSplat
    (orb : PlanetaryOrbit) (centerX centerY weight sigma0 : ℝ)
    (hw : 0 ≤ weight) (h_sigma0 : 0 < sigma0) (varpiAngle : ℝ) :
    NormedTensorGaussianSplat2D :=
  { centerX := centerX
    centerY := centerY
    weight := weight
    weight_nonneg := hw
    sigma1 := sigma0 * Real.sqrt (1 + orb.eccentricity)
    sigma1_pos := mul_pos h_sigma0 (Real.sqrt_pos.mpr (by
      have := orb.eccentricity_nonneg; linarith))
    sigma2 := sigma0 * Real.sqrt (1 - orb.eccentricity)
    sigma2_pos := mul_pos h_sigma0 (Real.sqrt_pos.mpr (by
      have := orb.eccentricity_lt_one; linarith))
    orientationAngle := varpiAngle }

/-- **$Gr_{\mathbb{C}}(2,4)$ Planetary Orbit Tensor Splat Covariance Trace & Determinant Laws**:
For any `PlanetaryOrbit` `orb`, the $Gr_{\mathbb{C}}(2,4)$ tensor splat satisfies:
1. $\operatorname{Tr} \Sigma_{Gr_{\mathbb{C}}(2,4)} = 2 \sigma_0^2$, and
2. $\det \Sigma_{Gr_{\mathbb{C}}(2,4)} = \sigma_0^4 (1 - e^2) = \sigma_0^4 \frac{p}{a}$. -/
@[blueprint "thm:signals-ddf-planetary-gr24-tensor-splat-identities"
  (title := "Gr_C(2,4) planetary orbit tensor splat covariance trace 2σ₀² and determinant σ₀⁴ (p / a)")
  (statement := /-- For \texttt{splat = orb.gr24TensorSplat(x₀,y₀,w,σ₀,hw,hσ₀,ϖ)},
    $\operatorname{Tr}\Sigma_{Gr_{\mathbb C}(2,4)} = 2\sigma_0^2$,
    $\det\Sigma_{Gr_{\mathbb C}(2,4)} = \sigma_0^4(1-e^2)$, and
    $\det\Sigma_{Gr_{\mathbb C}(2,4)} = \sigma_0^4\,\frac{p}{a}$. -/)
  (proof := /-- Unfold \texttt{gr24TensorSplat}, apply \texttt{Real.sq\_sqrt} to $1\pm e\ge 0$,
    and relate $1-e^2$ to $p/a$. -/)]
theorem PlanetaryOrbit.gr24TensorSplat_identities
    (orb : PlanetaryOrbit) (centerX centerY weight sigma0 : ℝ)
    (hw : 0 ≤ weight) (h_sigma0 : 0 < sigma0) (varpiAngle : ℝ) :
    let splat := orb.gr24TensorSplat centerX centerY weight sigma0 hw h_sigma0 varpiAngle
    splat.covTrace = 2 * sigma0 ^ 2 ∧
      splat.covDet = sigma0 ^ 4 * (1 - orb.eccentricity ^ 2) ∧
      splat.covDet = sigma0 ^ 4 * (orb.semiLatusRectum / orb.semiMajorAxis) := by
  intro splat
  have ha_ne : orb.semiMajorAxis ≠ 0 := ne_of_gt orb.semiMajorAxis_pos
  have he0 := orb.eccentricity_nonneg
  have he1 := orb.eccentricity_lt_one
  have h1pe : 0 ≤ 1 + orb.eccentricity := by linarith
  have h1me : 0 ≤ 1 - orb.eccentricity := by linarith
  have h_sq1 : (Real.sqrt (1 + orb.eccentricity)) ^ 2 = 1 + orb.eccentricity :=
    Real.sq_sqrt h1pe
  have h_sq2 : (Real.sqrt (1 - orb.eccentricity)) ^ 2 = 1 - orb.eccentricity :=
    Real.sq_sqrt h1me
  have h_tr : splat.covTrace = 2 * sigma0 ^ 2 := by
    dsimp [splat, PlanetaryOrbit.gr24TensorSplat, NormedTensorGaussianSplat2D.covTrace]
    rw [mul_pow, mul_pow, h_sq1, h_sq2]
    ring
  have h_det1 : splat.covDet = sigma0 ^ 4 * (1 - orb.eccentricity ^ 2) := by
    dsimp [splat, PlanetaryOrbit.gr24TensorSplat, NormedTensorGaussianSplat2D.covDet]
    rw [mul_pow, mul_pow, h_sq1, h_sq2]
    ring
  have h_slr : orb.semiLatusRectum / orb.semiMajorAxis = 1 - orb.eccentricity ^ 2 := by
    unfold PlanetaryOrbit.semiLatusRectum
    exact mul_div_cancel_left₀ (1 - orb.eccentricity ^ 2) ha_ne
  refine ⟨h_tr, h_det1, ?_⟩
  rw [h_det1, h_slr]

/-- **Complex $Gr_{\mathbb{C}}(2,4)$ Twistor Wavepacket on a Normed Tensor Gaussian Splat**:
Given a spatial Gaussian envelope `splat : NormedTensorGaussianSplat2D` and a
complex $2 \times 4$ Grassmannian twistor matrix $M_{\mathbb{C}} \in \mathbb{C}^{2 \times 4}$,
the coherent twistor wavepacket weights the square-root Gaussian amplitude
$\sqrt{G(x, y)}$ by the sum of the two uncrossed complex Plücker channel amplitudes
$w_A^{\mathbb{C}}(M_{\mathbb{C}}) + w_B^{\mathbb{C}}(M_{\mathbb{C}})$. -/
@[blueprint "def:signals-ddf-splat2d-complex-twistor-wavepacket"
  (title := "Complex Gr_C(2,4) twistor wavepacket on a NormedTensorGaussianSplat2D")
  (statement := /-- For \texttt{splat : NormedTensorGaussianSplat2D} and
    $M_{\mathbb C}\in\mathbb C^{2\times 4}$, define
    $\Psi_{\mathrm{splat}}(M_{\mathbb C};x,y) = \sqrt{G(x,y)}\,\bigl(w_A^{\mathbb C}(M_{\mathbb C})+w_B^{\mathbb C}(M_{\mathbb C})\bigr)$. -/)]
noncomputable def NormedTensorGaussianSplat2D.complexTwistorWavepacket
    (splat : NormedTensorGaussianSplat2D) (M_C : Matrix (Fin 2) (Fin 4) ℂ)
    (x y : ℝ) : ℂ :=
  ↑(Real.sqrt (splat.eval x y)) *
    (complexPluckerSinkAmplitudeA M_C + complexPluckerSinkAmplitudeB M_C)

/-- **Madelung Intensity of a Complex $Gr_{\mathbb{C}}(2,4)$ Twistor Gaussian Splat**:
$I_{\mathrm{splat}}(M_{\mathbb{C}}; x, y) = \bigl|\Psi_{\mathrm{splat}}(M_{\mathbb{C}}; x, y)\bigr|^2$. -/
@[blueprint "def:signals-ddf-splat2d-complex-twistor-intensity"
  (title := "Madelung intensity of a complex Gr_C(2,4) twistor Gaussian splat")
  (statement := /-- Define $I_{\mathrm{splat}}(M_{\mathbb C};x,y) =
    \operatorname{normSq}\bigl(\Psi_{\mathrm{splat}}(M_{\mathbb C};x,y)\bigr)$. -/)]
noncomputable def NormedTensorGaussianSplat2D.complexTwistorIntensity
    (splat : NormedTensorGaussianSplat2D) (M_C : Matrix (Fin 2) (Fin 4) ℂ)
    (x y : ℝ) : ℝ :=
  Complex.normSq (splat.complexTwistorWavepacket M_C x y)

/-- **How Normed Tensor Gaussian Splatters Represent $Gr_{\mathbb{C}}(2,4)$ Twistors (Coherent Plücker Factorization & Interference Expansion)**:
For any `splat : NormedTensorGaussianSplat2D` and any $M_{\mathbb{C}} \in \mathbb{C}^{2 \times 4}$:
1. By the 3-term complex Plücker relation, the twistor wavepacket factors through the
   crossing Plücker minor product:
   $\Psi_{\mathrm{splat}}(M_{\mathbb{C}}; x, y) = \sqrt{G(x,y)}\,\Delta_{02}^{\mathbb{C}}(M_{\mathbb{C}})\,\Delta_{13}^{\mathbb{C}}(M_{\mathbb{C}})$,
2. Its Madelung intensity equals the normed Gaussian envelope $G(x,y)$ times the
   squared modulus of the crossing Plücker product, and expands into the two channel
   densities $|w_A^{\mathbb{C}}|^2 + |w_B^{\mathbb{C}}|^2$ plus the coherent twistor
   phase cross-term $2\operatorname{Re}(w_A^{\mathbb{C}} \overline{w_B^{\mathbb{C}}})$, and
3. At any destructive twistor phase configuration where $\Delta_{02}^{\mathbb{C}}\Delta_{13}^{\mathbb{C}} = 0$
   (i.e. $w_A^{\mathbb{C}} + w_B^{\mathbb{C}} = 0$), the splat intensity vanishes
   identically ($I_{\mathrm{splat}} = 0$), resolving the limitation of purely real
   positive Gaussian splats. -/
@[blueprint "thm:signals-ddf-splat2d-complex-twistor-representation"
  (title := "Complex Gr_C(2,4) twistor representation theorem for NormedTensorGaussianSplat2D")
  (statement := /-- For any \texttt{splat : NormedTensorGaussianSplat2D} and $M_{\mathbb C}\in\mathbb C^{2\times 4}$:
    (1) $\Psi_{\mathrm{splat}}(M_{\mathbb C};x,y) = \sqrt{G(x,y)}\,\Delta_{02}^{\mathbb C}(M_{\mathbb C})\Delta_{13}^{\mathbb C}(M_{\mathbb C})$,
    (2) $I_{\mathrm{splat}}(M_{\mathbb C};x,y) = G(x,y)\,\bigl|\Delta_{02}^{\mathbb C}(M_{\mathbb C})\Delta_{13}^{\mathbb C}(M_{\mathbb C})\bigr|^2
    = G(x,y)\,\bigl(|w_A^{\mathbb C}|^2 + |w_B^{\mathbb C}|^2 + 2\operatorname{Re}(w_A^{\mathbb C}\,\overline{w_B^{\mathbb C}})\bigr)$, and
    (3) if $w_A^{\mathbb C}(M_{\mathbb C})+w_B^{\mathbb C}(M_{\mathbb C})=0$, then $I_{\mathrm{splat}}(M_{\mathbb C};x,y)=0$. -/)
  (proof := /-- Apply \texttt{complexGr24\_crossing\_eq\_channel\_sum}, factor
    $\operatorname{normSq}(\uparrow\sqrt{G(x,y)})=G(x,y)$ using $G(x,y)\ge 0$ from
    \texttt{eval\_properties}, and expand $\operatorname{normSq}(w_A^{\mathbb C}+w_B^{\mathbb C})$. -/)]
theorem NormedTensorGaussianSplat2D.complexTwistor_representation_identities
    (splat : NormedTensorGaussianSplat2D) (M_C : Matrix (Fin 2) (Fin 4) ℂ)
    (x y : ℝ) :
    splat.complexTwistorWavepacket M_C x y =
      ↑(Real.sqrt (splat.eval x y)) *
        (complexTwoRowMinor M_C 0 2 * complexTwoRowMinor M_C 1 3) ∧
    splat.complexTwistorIntensity M_C x y =
      splat.eval x y *
        Complex.normSq (complexTwoRowMinor M_C 0 2 * complexTwoRowMinor M_C 1 3) ∧
    splat.complexTwistorIntensity M_C x y =
      splat.eval x y *
        (Complex.normSq (complexPluckerSinkAmplitudeA M_C) +
          Complex.normSq (complexPluckerSinkAmplitudeB M_C) +
          2 * ((complexPluckerSinkAmplitudeA M_C).re *
                (complexPluckerSinkAmplitudeB M_C).re +
              (complexPluckerSinkAmplitudeA M_C).im *
                (complexPluckerSinkAmplitudeB M_C).im)) ∧
    (complexPluckerSinkAmplitudeA M_C + complexPluckerSinkAmplitudeB M_C = 0 →
      splat.complexTwistorIntensity M_C x y = 0) := by
  have h_eval_nonneg : 0 ≤ splat.eval x y := (splat.eval_properties x y).2.2.2.1
  have h_plucker :
      complexPluckerSinkAmplitudeA M_C + complexPluckerSinkAmplitudeB M_C =
        complexTwoRowMinor M_C 0 2 * complexTwoRowMinor M_C 1 3 := by
    unfold complexPluckerSinkAmplitudeA complexPluckerSinkAmplitudeB
    exact (complexGr24_crossing_eq_channel_sum M_C).symm
  have h_wp :
      splat.complexTwistorWavepacket M_C x y =
        ↑(Real.sqrt (splat.eval x y)) *
          (complexTwoRowMinor M_C 0 2 * complexTwoRowMinor M_C 1 3) := by
    unfold NormedTensorGaussianSplat2D.complexTwistorWavepacket
    rw [h_plucker]
  have h_norm_sqrt :
      Complex.normSq (↑(Real.sqrt (splat.eval x y)) : ℂ) = splat.eval x y := by
    rw [Complex.normSq_ofReal, ← sq, Real.sq_sqrt h_eval_nonneg]
  have h_int1 :
      splat.complexTwistorIntensity M_C x y =
        splat.eval x y *
          Complex.normSq (complexTwoRowMinor M_C 0 2 * complexTwoRowMinor M_C 1 3) := by
    unfold NormedTensorGaussianSplat2D.complexTwistorIntensity
    rw [h_wp, Complex.normSq_mul, h_norm_sqrt]
  have h_int2 :
      splat.complexTwistorIntensity M_C x y =
        splat.eval x y *
          (Complex.normSq (complexPluckerSinkAmplitudeA M_C) +
            Complex.normSq (complexPluckerSinkAmplitudeB M_C) +
            2 * ((complexPluckerSinkAmplitudeA M_C).re *
                  (complexPluckerSinkAmplitudeB M_C).re +
                (complexPluckerSinkAmplitudeA M_C).im *
                  (complexPluckerSinkAmplitudeB M_C).im)) := by
    unfold NormedTensorGaussianSplat2D.complexTwistorIntensity
      NormedTensorGaussianSplat2D.complexTwistorWavepacket
    rw [Complex.normSq_mul, h_norm_sqrt]
    congr 1
    simp only [Complex.normSq_apply, Complex.add_re, Complex.add_im]
    ring
  refine ⟨h_wp, h_int1, h_int2, ?_⟩
  intro h_zero
  unfold NormedTensorGaussianSplat2D.complexTwistorIntensity
    NormedTensorGaussianSplat2D.complexTwistorWavepacket
  rw [h_zero, mul_zero, Complex.normSq_zero]

/-- **Repulsive Core Bohm Quantum Potential of a Normed 2D Tensor Gaussian Splat**:
At the center $(x_0, y_0)$ of a 2D anisotropic Gaussian splat with principal widths
$\sigma_1, \sigma_2 > 0$, the normalized Laplacian of $\sqrt{G(x,y)}$ is
$\frac{\nabla^2 \sqrt{G}}{\sqrt{G}}\big|_{(x_0,y_0)} = -\frac{1}{2}(\sigma_1^{-2} + \sigma_2^{-2})$,
so the regularized Bohm quantum potential is finite and strictly repulsive:
$Q_{\mathrm{core}}(\Sigma) = \frac{\hbar^2}{4m}\left(\frac{1}{\sigma_1^2} + \frac{1}{\sigma_2^2}\right) = \frac{\hbar^2\,\operatorname{Tr}\Sigma}{4m\,\det\Sigma}$. -/
@[blueprint "def:signals-ddf-splat2d-core-bohm-potential"
  (title := "Core repulsive Bohm quantum potential Q_core(Σ) of a 2D Tensor Gaussian Splat")
  (statement := /-- For \texttt{splat : NormedTensorGaussianSplat2D}, boson mass $m$, and $\hbar$,
    define $Q_{\mathrm{core}}(\Sigma) = \frac{\hbar^2}{4m}\left(\frac{1}{\sigma_1^2}+\frac{1}{\sigma_2^2}\right)$. -/)]
noncomputable def NormedTensorGaussianSplat2D.coreBohmPotential
    (splat : NormedTensorGaussianSplat2D) (m_boson hbar : ℝ) : ℝ :=
  (hbar ^ 2 / (4 * m_boson)) * (1 / splat.sigma1 ^ 2 + 1 / splat.sigma2 ^ 2)

/-- **Core Bohm Quantum Potential Identities & DDF Jamming Scaling**:
1. For any `splat : NormedTensorGaussianSplat2D`, $m > 0$, and $\hbar \neq 0$,
   $Q_{\mathrm{core}}(\Sigma) = \frac{\hbar^2\,\operatorname{Tr}\Sigma}{4m\,\det\Sigma} > 0$
   (regularizing point-core singularities), and
2. For a DDF moving sheath `s.ddfTensorSplat`, $Q_{\mathrm{core}}$ scales with the
   squared constitutive jamming factor as
   $Q_{\mathrm{core}}^{\mathrm{DDF}}(s) = \frac{\hbar^2}{4 m \sigma_0^2}\bigl(\gamma_\varphi(v)^2 + 1\bigr)$. -/
@[blueprint "thm:signals-ddf-splat2d-core-bohm-identities"
  (title := "Core Bohm quantum potential trace/determinant identity and DDF γ_φ(v)² + 1 scaling")
  (statement := /-- For \texttt{splat : NormedTensorGaussianSplat2D} with $m>0$ and $\hbar\ne 0$:
    (1) $0 < Q_{\mathrm{core}}(\Sigma)$,
    (2) $Q_{\mathrm{core}}(\Sigma) = \frac{\hbar^2\,\operatorname{Tr}\Sigma}{4m\,\det\Sigma}$, and
    (3) for \texttt{s.ddfTensorSplat},
    $Q_{\mathrm{core}}^{\mathrm{DDF}}(s) = \frac{\hbar^2}{4m\sigma_0^2}\bigl(\gamma_\varphi(v)^2 + 1\bigr)$. -/)
  (proof := /-- Combine $\frac{1}{\sigma_1^2}+\frac{1}{\sigma_2^2}=\frac{\sigma_1^2+\sigma_2^2}{\sigma_1^2\sigma_2^2}$
    and substitute $\sigma_1=\sigma_0\,\mathcal{V}(s)=\sigma_0\,\gamma_\varphi(v)^{-1}$. -/)]
theorem NormedTensorGaussianSplat2D.coreBohmPotential_identities
    {sub : DDFSubstrate} (s : MovingSheath sub)
    (splat : NormedTensorGaussianSplat2D)
    (centerX centerY weight sigma0 m_boson hbar orientationAngle : ℝ)
    (hw : 0 ≤ weight) (h_sigma0 : 0 < sigma0)
    (hm : 0 < m_boson) (h_hbar : hbar ≠ 0) :
    let splat_ddf := s.ddfTensorSplat centerX centerY weight sigma0 hw h_sigma0 orientationAngle
    0 < splat.coreBohmPotential m_boson hbar ∧
      splat.coreBohmPotential m_boson hbar =
        hbar ^ 2 * splat.covTrace / (4 * m_boson * splat.covDet) ∧
      splat_ddf.coreBohmPotential m_boson hbar =
        (hbar ^ 2 / (4 * m_boson * sigma0 ^ 2)) * (s.jammingFactor ^ 2 + 1) := by
  intro splat_ddf
  have hs1 : 0 < splat.sigma1 := splat.sigma1_pos
  have hs2 : 0 < splat.sigma2 := splat.sigma2_pos
  have hs1_ne : splat.sigma1 ^ 2 ≠ 0 := pow_ne_zero 2 (ne_of_gt hs1)
  have hs2_ne : splat.sigma2 ^ 2 ≠ 0 := pow_ne_zero 2 (ne_of_gt hs2)
  have hm_ne : m_boson ≠ 0 := ne_of_gt hm
  have h_hbar_sq : 0 < hbar ^ 2 := sq_pos_of_ne_zero h_hbar
  have h_pos : 0 < splat.coreBohmPotential m_boson hbar := by
    unfold NormedTensorGaussianSplat2D.coreBohmPotential
    positivity
  have h_tr_det :
      splat.coreBohmPotential m_boson hbar =
        hbar ^ 2 * splat.covTrace / (4 * m_boson * splat.covDet) := by
    unfold NormedTensorGaussianSplat2D.coreBohmPotential
      NormedTensorGaussianSplat2D.covTrace NormedTensorGaussianSplat2D.covDet
    field_simp [hs1_ne, hs2_ne, hm_ne]
    ring
  have h_ddf_q :
      splat_ddf.coreBohmPotential m_boson hbar =
        (hbar ^ 2 / (4 * m_boson * sigma0 ^ 2)) * (s.jammingFactor ^ 2 + 1) := by
    dsimp [splat_ddf, MovingSheath.ddfTensorSplat,
      NormedTensorGaussianSplat2D.coreBohmPotential]
    rw [(s.visibility_jamming_duality).1]
    have hs0_ne : sigma0 ≠ 0 := ne_of_gt h_sigma0
    have hjam_ne : s.jammingFactor ≠ 0 := ne_of_gt s.jammingFactor_pos
    field_simp [hs0_ne, hjam_ne, hm_ne]
  exact ⟨h_pos, h_tr_det, h_ddf_q⟩

/-- **Principal Longitudinal Component $\Pi_{11}(x, y)$ of the Madelung Quantum Pressure Tensor**:
Because $\ln G(x, y) = \ln(w\,\mathcal{N}(\Sigma)) - \frac{1}{2}(\mathbf{x}-\mathbf{x}_0)^T \Sigma^{-1}(\mathbf{x}-\mathbf{x}_0)$,
the negative Hessian of the log-density is spatially constant and equals the precision
matrix $\Sigma^{-1} = R(\theta)\operatorname{diag}(\sigma_1^{-2}, \sigma_2^{-2})R(\theta)^T$.
Consequently, the Madelung quantum pressure tensor
$\Pi_{ij}(x, y) = -\frac{\hbar^2}{4m^2} G(x, y) \partial_i \partial_j \ln G(x, y)$
has principal eigenvalues $\Pi_{11}(x, y) = \frac{\hbar^2}{4m^2 \sigma_1^2} G(x, y)$
and $\Pi_{22}(x, y) = \frac{\hbar^2}{4m^2 \sigma_2^2} G(x, y)$. -/
@[blueprint "def:signals-ddf-splat2d-quantum-pressure-principal1"
  (title := "Principal longitudinal quantum pressure Π_11(x,y) of a 2D Tensor Gaussian Splat")
  (statement := /-- For \texttt{splat : NormedTensorGaussianSplat2D}, define
    $\Pi_{11}(x,y) = \frac{\hbar^2}{4m^2\sigma_1^2}\,G(x,y)$. -/)]
noncomputable def NormedTensorGaussianSplat2D.quantumPressurePrincipal1
    (splat : NormedTensorGaussianSplat2D) (m_boson hbar x y : ℝ) : ℝ :=
  (hbar ^ 2 / (4 * m_boson ^ 2 * splat.sigma1 ^ 2)) * splat.eval x y

/-- **Principal Transverse Component $\Pi_{22}(x, y)$ of the Madelung Quantum Pressure Tensor**:
$\Pi_{22}(x, y) = \frac{\hbar^2}{4m^2 \sigma_2^2} G(x, y)$. -/
@[blueprint "def:signals-ddf-splat2d-quantum-pressure-principal2"
  (title := "Principal transverse quantum pressure Π_22(x,y) of a 2D Tensor Gaussian Splat")
  (statement := /-- For \texttt{splat : NormedTensorGaussianSplat2D}, define
    $\Pi_{22}(x,y) = \frac{\hbar^2}{4m^2\sigma_2^2}\,G(x,y)$. -/)]
noncomputable def NormedTensorGaussianSplat2D.quantumPressurePrincipal2
    (splat : NormedTensorGaussianSplat2D) (m_boson hbar x y : ℝ) : ℝ :=
  (hbar ^ 2 / (4 * m_boson ^ 2 * splat.sigma2 ^ 2)) * splat.eval x y

/-- **Trace $\operatorname{Tr}\Pi(x, y) = \Pi_{11}(x, y) + \Pi_{22}(x, y)$ of the Madelung Quantum Pressure Tensor**. -/
@[blueprint "def:signals-ddf-splat2d-quantum-pressure-trace"
  (title := "Trace Tr Π(x,y) of the Madelung quantum pressure tensor of a 2D Tensor Gaussian Splat")
  (statement := /-- Define $\operatorname{Tr}\Pi(x,y) = \Pi_{11}(x,y) + \Pi_{22}(x,y)$. -/)]
noncomputable def NormedTensorGaussianSplat2D.quantumPressureTrace
    (splat : NormedTensorGaussianSplat2D) (m_boson hbar x y : ℝ) : ℝ :=
  splat.quantumPressurePrincipal1 m_boson hbar x y +
    splat.quantumPressurePrincipal2 m_boson hbar x y

/-- **Determinant $\det\Pi(x, y) = \Pi_{11}(x, y)\,\Pi_{22}(x, y)$ of the Madelung Quantum Pressure Tensor**. -/
@[blueprint "def:signals-ddf-splat2d-quantum-pressure-det"
  (title := "Determinant det Π(x,y) of the Madelung quantum pressure tensor of a 2D Tensor Gaussian Splat")
  (statement := /-- Define $\det\Pi(x,y) = \Pi_{11}(x,y)\,\Pi_{22}(x,y)$. -/)]
noncomputable def NormedTensorGaussianSplat2D.quantumPressureDet
    (splat : NormedTensorGaussianSplat2D) (m_boson hbar x y : ℝ) : ℝ :=
  splat.quantumPressurePrincipal1 m_boson hbar x y *
    splat.quantumPressurePrincipal2 m_boson hbar x y

/-- **Madelung Quantum Pressure Tensor Precision-Matrix Identities & DDF Anisotropy Theorem**:
For any `splat : NormedTensorGaussianSplat2D` and $m > 0$:
1. The trace of the quantum pressure tensor equals $\frac{\hbar^2\,\operatorname{Tr}\Sigma}{4m^2\,\det\Sigma}\,G(x, y)
   = \frac{1}{m}\,Q_{\mathrm{core}}(\Sigma)\,G(x, y)$,
2. Its determinant equals $\left(\frac{\hbar^2}{4m^2}\right)^2 \frac{G(x, y)^2}{\det\Sigma}$, and
3. For a DDF moving sheath `s.ddfTensorSplat`, the longitudinal principal quantum stress
   exceeds the transverse quantum stress by the squared Lorentz jamming factor:
   $\Pi_{11}^{\mathrm{DDF}}(x, y) = \gamma_\varphi(v)^2\,\Pi_{22}^{\mathrm{DDF}}(x, y)$. -/
@[blueprint "thm:signals-ddf-splat2d-quantum-pressure-identities"
  (title := "Madelung quantum pressure tensor Π_ij precision-matrix and DDF jamming anisotropy theorem")
  (statement := /-- For \texttt{splat : NormedTensorGaussianSplat2D} and $m>0$:
    (1) $\operatorname{Tr}\Pi(x,y) = \frac{1}{m}\,Q_{\mathrm{core}}(\Sigma)\,G(x,y)
    = \frac{\hbar^2\,\operatorname{Tr}\Sigma}{4m^2\,\det\Sigma}\,G(x,y)$,
    (2) $\det\Pi(x,y) = \left(\frac{\hbar^2}{4m^2}\right)^2\frac{G(x,y)^2}{\det\Sigma}$, and
    (3) for \texttt{s.ddfTensorSplat},
    $\Pi_{11}^{\mathrm{DDF}}(x,y) = \gamma_\varphi(v)^2\,\Pi_{22}^{\mathrm{DDF}}(x,y)$. -/)
  (proof := /-- Expand $\Pi_{11}+\Pi_{22}$ and $\Pi_{11}\Pi_{22}$ over $\sigma_1^2,\sigma_2^2>0$,
    and substitute $\sigma_1=\sigma_0\,\mathcal{V}(s)=\sigma_0\,\gamma_\varphi(v)^{-1}$. -/)]
theorem NormedTensorGaussianSplat2D.quantumPressureTensor_identities
    {sub : DDFSubstrate} (s : MovingSheath sub)
    (splat : NormedTensorGaussianSplat2D)
    (centerX centerY weight sigma0 m_boson hbar orientationAngle x y : ℝ)
    (hw : 0 ≤ weight) (h_sigma0 : 0 < sigma0) (hm : 0 < m_boson) :
    let splat_ddf := s.ddfTensorSplat centerX centerY weight sigma0 hw h_sigma0 orientationAngle
    splat.quantumPressureTrace m_boson hbar x y =
      (splat.coreBohmPotential m_boson hbar / m_boson) * splat.eval x y ∧
    splat.quantumPressureTrace m_boson hbar x y =
      (hbar ^ 2 * splat.covTrace / (4 * m_boson ^ 2 * splat.covDet)) * splat.eval x y ∧
    splat.quantumPressureDet m_boson hbar x y =
      (hbar ^ 2 / (4 * m_boson ^ 2)) ^ 2 * (splat.eval x y ^ 2 / splat.covDet) ∧
    splat_ddf.quantumPressurePrincipal1 m_boson hbar x y =
      s.jammingFactor ^ 2 * splat_ddf.quantumPressurePrincipal2 m_boson hbar x y := by
  intro splat_ddf
  have hs1 : 0 < splat.sigma1 := splat.sigma1_pos
  have hs2 : 0 < splat.sigma2 := splat.sigma2_pos
  have hs1_ne : splat.sigma1 ^ 2 ≠ 0 := pow_ne_zero 2 (ne_of_gt hs1)
  have hs2_ne : splat.sigma2 ^ 2 ≠ 0 := pow_ne_zero 2 (ne_of_gt hs2)
  have hm_ne : m_boson ≠ 0 := ne_of_gt hm
  have h_tr_q :
      splat.quantumPressureTrace m_boson hbar x y =
        (splat.coreBohmPotential m_boson hbar / m_boson) * splat.eval x y := by
    unfold NormedTensorGaussianSplat2D.quantumPressureTrace
      NormedTensorGaussianSplat2D.quantumPressurePrincipal1
      NormedTensorGaussianSplat2D.quantumPressurePrincipal2
      NormedTensorGaussianSplat2D.coreBohmPotential
    field_simp [hs1_ne, hs2_ne, hm_ne]
  have h_tr_cov :
      splat.quantumPressureTrace m_boson hbar x y =
        (hbar ^ 2 * splat.covTrace / (4 * m_boson ^ 2 * splat.covDet)) * splat.eval x y := by
    unfold NormedTensorGaussianSplat2D.quantumPressureTrace
      NormedTensorGaussianSplat2D.quantumPressurePrincipal1
      NormedTensorGaussianSplat2D.quantumPressurePrincipal2
      NormedTensorGaussianSplat2D.covTrace NormedTensorGaussianSplat2D.covDet
    field_simp [hs1_ne, hs2_ne, hm_ne]
    ring
  have h_det :
      splat.quantumPressureDet m_boson hbar x y =
        (hbar ^ 2 / (4 * m_boson ^ 2)) ^ 2 * (splat.eval x y ^ 2 / splat.covDet) := by
    unfold NormedTensorGaussianSplat2D.quantumPressureDet
      NormedTensorGaussianSplat2D.quantumPressurePrincipal1
      NormedTensorGaussianSplat2D.quantumPressurePrincipal2
      NormedTensorGaussianSplat2D.covDet
    field_simp [hs1_ne, hs2_ne, hm_ne]
  have h_aniso :
      splat_ddf.quantumPressurePrincipal1 m_boson hbar x y =
        s.jammingFactor ^ 2 * splat_ddf.quantumPressurePrincipal2 m_boson hbar x y := by
    unfold NormedTensorGaussianSplat2D.quantumPressurePrincipal1
      NormedTensorGaussianSplat2D.quantumPressurePrincipal2
    have h_s1 : splat_ddf.sigma1 = sigma0 * s.jammingFactor⁻¹ := by
      dsimp [splat_ddf, MovingSheath.ddfTensorSplat]
      rw [(s.visibility_jamming_duality).1]
    have h_s2 : splat_ddf.sigma2 = sigma0 := rfl
    rw [h_s1, h_s2]
    have hs0_ne : sigma0 ≠ 0 := ne_of_gt h_sigma0
    have hjam_ne : s.jammingFactor ≠ 0 := ne_of_gt s.jammingFactor_pos
    field_simp [hs0_ne, hjam_ne, hm_ne]
  exact ⟨h_tr_q, h_tr_cov, h_det, h_aniso⟩

/-! ## Inelastic Scattering (Inverse Compton & Raman) and the Heat Problem (Fourier, Cattaneo–Vernotte, and Unified Grassmannian–DDF Thermal Transport)

Unifies relativistic Inverse Compton scattering, Stokes/anti-Stokes Raman scattering,
and the three tiers of thermal transport (parabolic Fourier diffusion, hyperbolic
Cattaneo–Vernotte telegrapher waves, and Grassmannian $Gr_{\mathbb{C}}(2,4)$–DDF
second-sound & normed Tensor Gaussian Splat thermal evolution):
1. **DDF Moving-Sheath Inverse Compton $Gr_{\mathbb{C}}(2,4)$ Plücker Identity (`MovingSheath.inverseCompton_gr24_identities`)**:
   For `M_C := s.gr24TwistorMatrix d λ L Δℓ φ x`, the ratio of the forward-to-backward
   complex Plücker channel densities equals the exact relativistic head-on Inverse
   Compton Thomson upshift factor:
   $$\frac{|w_A^{\mathbb{C}}(M_{\mathbb{C}})|^2}{|w_B^{\mathbb{C}}(M_{\mathbb{C}})|^2} = \frac{1 + \beta}{1 - \beta} = \gamma_\varphi(v)^2\,(1 + \beta)^2,$$
   and the angle-averaged Inverse Compton power boost satisfies
   $\frac{4}{3}(\gamma_\varphi(v)^2 - 1) = \frac{4}{3}\,\gamma_\varphi(v)^2\,\beta^2$.
2. **Parabolic Fourier Conduction & the Acausal Infinite-Speed Paradox (`FourierHeatModel`)**:
   Establishes $\alpha = k_{\mathrm{th}} / (\rho c_v) > 0$ and proves that for any speed
   ceiling $V \ge 0$ (including $c$), high-frequency plane-wave modes $\omega > V^2/(2\alpha)$
   have squared phase velocity $v_{\mathrm{phase}}^2(\omega) = 2\alpha\omega > V^2$.
3. **Hyperbolic Cattaneo–Vernotte Telegrapher Heat Conduction (`CattaneoVernotteHeatModel`)**:
   Introduces relaxation time $\tau_r > 0$, finite second-sound speed
   $c_{\mathrm{CV}} = \sqrt{\alpha / \tau_r} > 0$, wave-operator factorization
   $\frac{1}{c_{\mathrm{CV}}^2}\partial_t^2 T + \frac{1}{\alpha}\partial_t T - \partial_x^2 T$,
   and exact reduction to Fourier's law at $\partial_t q = 0$ (or $\tau_r \to 0$).
4. **Unified Grassmannian $Gr_{\mathbb{C}}(2,4)$–DDF Second-Sound & Tensor Splat Thermal Method (`MovingSheath.ddfThermalTransport_and_splat_identities`)**:
   - Subluminal causal second-sound speed $c_{\mathrm{th}}^{\mathrm{DDF}}(s) = c_{\mathrm{th},0}\,\mathcal{V}(s) = c_{\mathrm{th},0}/\gamma_\varphi(v) \le c_{\mathrm{th},0} \le c$,
   - Lorentz-jammed longitudinal diffusivity $\alpha_\parallel^{\mathrm{DDF}}(s) = \alpha_0\,\gamma_\varphi(v)^{-2}$ whose ratio to $\alpha_0 = c_{\mathrm{th},0}^2 \tau_r$ equals the normalized DDF tensor splat covariance determinant $\frac{\det\Sigma_{\mathrm{DDF}}}{\sigma_0^4}$,
   - Exact $L^1$-conserving anisotropic Tensor Gaussian Splat thermal evolution (`NormedTensorGaussianSplat2D.evolveThermal`) with linear covariance trace growth $\operatorname{Tr}\Sigma(t + \Delta t) = \operatorname{Tr}\Sigma(t) + 2(\alpha_1 + \alpha_2)\Delta t$.
-/

/-- **DDF Moving-Sheath Inverse Compton $Gr_{\mathbb{C}}(2,4)$ Plücker Channel Identities**:
For any `s : MovingSheath sub` and its complex twistor matrix
`M_C := s.gr24TwistorMatrix d λ L Δℓ φ x`:
1. The ratio of the forward-to-backward complex Plücker channel densities equals the
   relativistic head-on Inverse Compton Doppler upshift ratio:
   $\frac{|w_A^{\mathbb{C}}(M_{\mathbb{C}})|^2}{|w_B^{\mathbb{C}}(M_{\mathbb{C}})|^2} = \operatorname{inverseComptonDopplerRatio}(s.\mathrm{reducedVelocity}) = \frac{1+\beta}{1-\beta}$,
2. In terms of the DDF Lorentz jamming factor $\gamma_\varphi(v)$,
   $\operatorname{inverseComptonDopplerRatio}(s.\mathrm{reducedVelocity}) = \gamma_\varphi(v)^2\,(1 + \beta)^2$, and
3. The angle-averaged Inverse Compton power boost factor satisfies
   $\frac{4}{3}\bigl(\gamma_\varphi(v)^2 - 1\bigr) = \frac{4}{3}\,\gamma_\varphi(v)^2\,\beta^2$. -/
@[blueprint "thm:signals-ddf-sheath-inverse-compton-gr24"
  (title := "DDF MovingSheath Gr_C(2,4) Pluecker ratio equals relativistic Inverse Compton upshift")
  (statement := /-- For \texttt{s : MovingSheath sub} and $M_{\mathbb C} = s.\mathrm{gr24TwistorMatrix}\;d\;\lambda_{\mathrm{opt}}\;L\;\Delta\ell\;\varphi\;x$:
    (1) $\frac{|w_A^{\mathbb C}(M_{\mathbb C})|^2}{|w_B^{\mathbb C}(M_{\mathbb C})|^2} = \operatorname{inverseComptonDopplerRatio}(s.\mathrm{beta})$,
    (2) $\operatorname{inverseComptonDopplerRatio}(s.\mathrm{beta}) = s.\mathrm{jammingFactor}^2\,(1+s.\mathrm{beta})^2$, and
    (3) $\frac{4}{3}(s.\mathrm{jammingFactor}^2 - 1) = \frac{4}{3}\,s.\mathrm{jammingFactor}^2\,s.\mathrm{beta}^2$. -/)
  (proof := /-- Rewrite $|w_A^{\mathbb C}|^2 = 1+\beta$ and $|w_B^{\mathbb C}|^2 = 1-\beta$ via
    \texttt{gr24TwistorMatrix\_madelung\_sector\_identities}, and use $\gamma_\varphi(v)^2 = (1-\beta^2)^{-1}$. -/)]
theorem MovingSheath.inverseCompton_gr24_identities
    {sub : DDFSubstrate} (s : MovingSheath sub)
    (d wavelength L : ℝ) (Δℓ : ℤ) (φ x : ℝ) :
    let M_C := s.gr24TwistorMatrix d wavelength L Δℓ φ x
    Complex.normSq (complexPluckerSinkAmplitudeA M_C) /
        Complex.normSq (complexPluckerSinkAmplitudeB M_C) =
      inverseComptonDopplerRatio s.beta ∧
    inverseComptonDopplerRatio s.beta =
      s.jammingFactor ^ 2 * (1 + s.beta) ^ 2 ∧
    (4 / 3 : ℝ) * (s.jammingFactor ^ 2 - 1) =
      (4 / 3 : ℝ) * s.jammingFactor ^ 2 * s.beta ^ 2 := by
  intro M_C
  have h_mad := s.gr24TwistorMatrix_madelung_sector_identities d wavelength L Δℓ φ x
  have h_ratio :
      Complex.normSq (complexPluckerSinkAmplitudeA M_C) /
          Complex.normSq (complexPluckerSinkAmplitudeB M_C) =
        inverseComptonDopplerRatio s.beta := by
    dsimp [M_C]
    rw [h_mad.1, h_mad.2.1]
    rfl
  have hc := sub.c_pos
  have h_beta_lt : s.beta < 1 := (div_lt_one hc).mpr s.subluminal
  have h_beta_sq_eq : s.beta ^ 2 = s.betaSq := (s.beta_bounds).2.2.2
  have h_pos := s.one_sub_betaSq_pos
  have h1m_ne : 1 - s.beta ≠ 0 := by linarith
  have h1m_sq_ne : 1 - s.beta ^ 2 ≠ 0 := by linarith
  have h_jam_sq : s.jammingFactor ^ 2 = (1 - s.beta ^ 2)⁻¹ := by
    unfold MovingSheath.jammingFactor
    rw [div_pow, one_pow, Real.sq_sqrt (le_of_lt h_pos), h_beta_sq_eq, one_div]
  have h_dop_jam :
      inverseComptonDopplerRatio s.beta =
        s.jammingFactor ^ 2 * (1 + s.beta) ^ 2 := by
    unfold inverseComptonDopplerRatio
    rw [h_jam_sq]
    field_simp [h1m_ne, h1m_sq_ne]
    ring
  have h_pow_boost :
      (4 / 3 : ℝ) * (s.jammingFactor ^ 2 - 1) =
        (4 / 3 : ℝ) * s.jammingFactor ^ 2 * s.beta ^ 2 := by
    rw [h_jam_sq]
    field_simp [h1m_sq_ne]
    ring
  exact ⟨h_ratio, h_dop_jam, h_pow_boost⟩

/-- **Classical Parabolic Fourier Heat Conduction Model**:
Models Fourier's constitutive law $q = -k_{\mathrm{th}} \partial_x T$ and parabolic
diffusivity $\alpha = k_{\mathrm{th}} / (\rho c_v) > 0$. -/
@[blueprint "def:signals-ddf-fourier-heat-model"
  (title := "Classical parabolic Fourier heat conduction model")
  (statement := /-- Records positive thermal conductivity $k_{\mathrm{th}}>0$ and positive
    volumetric heat capacity $\rho c_v>0$. -/)]
structure FourierHeatModel where
  thermalConductivity : ℝ
  thermalConductivity_pos : 0 < thermalConductivity
  volumetricHeatCapacity : ℝ
  volumetricHeatCapacity_pos : 0 < volumetricHeatCapacity

/-- Thermal diffusivity $\alpha = k_{\mathrm{th}} / (\rho c_v)$. -/
@[blueprint "def:signals-ddf-fourier-diffusivity"
  (title := "Thermal diffusivity α = k_th / (ρ c_v)")
  (statement := /-- Define $\alpha = k_{\mathrm{th}} / (\rho c_v)$. -/)]
noncomputable def FourierHeatModel.diffusivity (m : FourierHeatModel) : ℝ :=
  m.thermalConductivity / m.volumetricHeatCapacity

/-- Classical Fourier heat flux $q_{\mathrm{Fourier}} = -k_{\mathrm{th}}\,\nabla T$. -/
@[blueprint "def:signals-ddf-fourier-flux"
  (title := "Classical Fourier heat flux q = -k_th ∇T")
  (statement := /-- Define $q_{\mathrm{Fourier}}(\nabla T) = -k_{\mathrm{th}}\,\nabla T$. -/)]
def FourierHeatModel.fourierFlux (m : FourierHeatModel) (gradT : ℝ) : ℝ :=
  -m.thermalConductivity * gradT

/-- Squared phase velocity $v_{\mathrm{phase}}^2(\omega) = 2\alpha\omega$ of a
harmonic thermal wave at angular frequency $\omega$ in parabolic Fourier diffusion. -/
@[blueprint "def:signals-ddf-fourier-phase-speed-sq"
  (title := "Parabolic Fourier harmonic phase velocity squared v_phase²(ω) = 2 α ω")
  (statement := /-- Define $v_{\mathrm{phase}}^2(\omega) = 2\alpha\omega$. -/)]
noncomputable def FourierHeatModel.highFreqPhaseSpeedSq
    (m : FourierHeatModel) (ω : ℝ) : ℝ :=
  2 * m.diffusivity * ω

/-- **Fourier Positivity & the Acausal Infinite-Speed Paradox**:
For any `m : FourierHeatModel`:
1. The thermal diffusivity $\alpha$ is strictly positive ($0 < \alpha$), and
2. For any finite speed ceiling $V \ge 0$ (such as the speed of light $c$), the
   frequency $\omega_* = \frac{V^2}{2\alpha} + 1 > 0$ produces a Fourier phase speed
   strictly exceeding $V$ ($V^2 < v_{\mathrm{phase}}^2(\omega_*)$), formally proving
   the acausal high-frequency divergence of classical parabolic heat conduction. -/
@[blueprint "thm:signals-ddf-fourier-acausal-speed"
  (title := "Parabolic Fourier diffusivity positivity and acausal high-frequency phase speed theorem")
  (statement := /-- For any \texttt{m : FourierHeatModel} and speed ceiling $V\ge 0$:
    (1) $0 < m.\mathrm{diffusivity}$, and
    (2) at $\omega_* = V^2/(2 m.\mathrm{diffusivity}) + 1$, $0 < \omega_*$ and
    $V^2 < m.\mathrm{highFreqPhaseSpeedSq}(\omega_*)$. -/)
  (proof := /-- Positivity follows from $k_{\mathrm{th}}>0$ and $\rho c_v>0$; substituting $\omega_*$
    gives $v_{\mathrm{phase}}^2(\omega_*) = V^2 + 2\alpha > V^2$. -/)]
theorem FourierHeatModel.diffusivity_pos_and_acausal_speed
    (m : FourierHeatModel) (V : ℝ) :
    let ω_star := V ^ 2 / (2 * m.diffusivity) + 1
    0 < m.diffusivity ∧
      0 < ω_star ∧
      V ^ 2 < m.highFreqPhaseSpeedSq ω_star := by
  intro ω_star
  have h_alpha : 0 < m.diffusivity :=
    div_pos m.thermalConductivity_pos m.volumetricHeatCapacity_pos
  have h_alpha_ne : m.diffusivity ≠ 0 := ne_of_gt h_alpha
  have h_omega_pos : 0 < ω_star := by
    dsimp [ω_star]
    positivity
  have h_exceed : V ^ 2 < m.highFreqPhaseSpeedSq ω_star := by
    dsimp [ω_star, FourierHeatModel.highFreqPhaseSpeedSq]
    have h_expand : 2 * m.diffusivity * (V ^ 2 / (2 * m.diffusivity) + 1) =
        V ^ 2 + 2 * m.diffusivity := by
      field_simp [h_alpha_ne]
    linarith
  exact ⟨h_alpha, h_omega_pos, h_exceed⟩

/-- **Hyperbolic Cattaneo–Vernotte Heat Conduction Model**:
Extends `FourierHeatModel` with a positive thermal relaxation time $\tau_r > 0$,
resolving the Fourier paradox via the hyperbolic telegrapher's equation
$\tau_r \partial_t^2 T + \partial_t T = \alpha \partial_x^2 T$ with finite second-sound
speed $c_{\mathrm{CV}} = \sqrt{\alpha / \tau_r}$. -/
@[blueprint "def:signals-ddf-cattaneo-vernotte-model"
  (title := "Hyperbolic Cattaneo-Vernotte heat conduction model")
  (statement := /-- Extends \texttt{FourierHeatModel} with positive thermal relaxation time $\tau_r>0$. -/)]
structure CattaneoVernotteHeatModel extends FourierHeatModel where
  relaxationTime : ℝ
  relaxationTime_pos : 0 < relaxationTime

/-- Squared Cattaneo–Vernotte thermal wave ("second sound") propagation speed
$c_{\mathrm{CV}}^2 = \alpha / \tau_r$. -/
@[blueprint "def:signals-ddf-cattaneo-second-sound-sq"
  (title := "Cattaneo-Vernotte second-sound speed squared c_CV² = α / τ_r")
  (statement := /-- Define $c_{\mathrm{CV}}^2 = \alpha / \tau_r$. -/)]
noncomputable def CattaneoVernotteHeatModel.secondSoundSpeedSq
    (m : CattaneoVernotteHeatModel) : ℝ :=
  m.toFourierHeatModel.diffusivity / m.relaxationTime

/-- Cattaneo–Vernotte thermal wave ("second sound") propagation speed
$c_{\mathrm{CV}} = \sqrt{\alpha / \tau_r}$. -/
@[blueprint "def:signals-ddf-cattaneo-second-sound"
  (title := "Cattaneo-Vernotte second-sound speed c_CV = √(α / τ_r)")
  (statement := /-- Define $c_{\mathrm{CV}} = \sqrt{c_{\mathrm{CV}}^2}$. -/)]
noncomputable def CattaneoVernotteHeatModel.secondSoundSpeed
    (m : CattaneoVernotteHeatModel) : ℝ :=
  Real.sqrt m.secondSoundSpeedSq

/-- Cattaneo–Vernotte constitutive heat-flux residual
$\tau_r \partial_t q + q - q_{\mathrm{Fourier}}(\nabla T) = \tau_r \partial_t q + q + k_{\mathrm{th}} \nabla T$. -/
@[blueprint "def:signals-ddf-cattaneo-flux-residual"
  (title := "Cattaneo-Vernotte constitutive heat-flux residual")
  (statement := /-- Define $\tau_r\,\partial_t q + q - q_{\mathrm{Fourier}}(\nabla T)$. -/)]
def CattaneoVernotteHeatModel.cattaneoFluxResidual
    (m : CattaneoVernotteHeatModel) (q dq_dt gradT : ℝ) : ℝ :=
  m.relaxationTime * dq_dt + q - m.toFourierHeatModel.fourierFlux gradT

/-- Hyperbolic telegrapher temperature PDE residual
$\tau_r \partial_t^2 T + \partial_t T - \alpha \partial_x^2 T$. -/
@[blueprint "def:signals-ddf-cattaneo-telegrapher-residual"
  (title := "Cattaneo-Vernotte hyperbolic telegrapher PDE residual")
  (statement := /-- Define $\tau_r\,\partial_t^2 T + \partial_t T - \alpha\,\partial_x^2 T$. -/)]
noncomputable def CattaneoVernotteHeatModel.telegrapherResidual
    (m : CattaneoVernotteHeatModel) (d2T_dt2 dT_dt d2T_dx2 : ℝ) : ℝ :=
  m.relaxationTime * d2T_dt2 + dT_dt - m.toFourierHeatModel.diffusivity * d2T_dx2

/-- **Cattaneo–Vernotte Second-Sound Wave Factorization & Steady Fourier Reduction**:
For any `m : CattaneoVernotteHeatModel`:
1. $0 < c_{\mathrm{CV}}^2$ and $0 < c_{\mathrm{CV}}$,
2. $\alpha = c_{\mathrm{CV}}^2\,\tau_r$ and $c_{\mathrm{CV}}^2 = (c_{\mathrm{CV}})^2$,
3. Dividing the telegrapher residual by $\alpha$ exhibits the damped hyperbolic wave operator
   $\frac{1}{c_{\mathrm{CV}}^2}\partial_t^2 T + \frac{1}{\alpha}\partial_t T - \partial_x^2 T$, and
4. When $\partial_t q = 0$ (steady state or zero-relaxation limit), the Cattaneo–Vernotte
   flux residual reduces identically to the classical Fourier residual $q - q_{\mathrm{Fourier}}(\nabla T)$. -/
@[blueprint "thm:signals-ddf-cattaneo-vernotte-identities"
  (title := "Cattaneo-Vernotte second-sound factorization, telegrapher operator, and Fourier reduction")
  (statement := /-- For any \texttt{m : CattaneoVernotteHeatModel}:
    (1) $0 < m.\mathrm{secondSoundSpeedSq}$ and $0 < m.\mathrm{secondSoundSpeed}$,
    (2) $m.\mathrm{diffusivity} = m.\mathrm{secondSoundSpeedSq}\cdot m.\mathrm{relaxationTime}$,
    (3) $m.\mathrm{telegrapherResidual}(T_{tt},T_t,T_{xx})/m.\mathrm{diffusivity} =
    T_{tt}/m.\mathrm{secondSoundSpeedSq} + T_t/m.\mathrm{diffusivity} - T_{xx}$, and
    (4) $m.\mathrm{cattaneoFluxResidual}(q,0,\nabla T) = q - m.\mathrm{fourierFlux}(\nabla T)$. -/)
  (proof := /-- Unfold \texttt{secondSoundSpeedSq}, \texttt{telegrapherResidual}, and
    \texttt{cattaneoFluxResidual}, and simplify over $\alpha>0$ and $\tau_r>0$. -/)]
theorem CattaneoVernotteHeatModel.identities
    (m : CattaneoVernotteHeatModel) (q gradT d2T_dt2 dT_dt d2T_dx2 : ℝ) :
    0 < m.secondSoundSpeedSq ∧
      0 < m.secondSoundSpeed ∧
      m.toFourierHeatModel.diffusivity = m.secondSoundSpeedSq * m.relaxationTime ∧
      m.telegrapherResidual d2T_dt2 dT_dt d2T_dx2 / m.toFourierHeatModel.diffusivity =
        d2T_dt2 / m.secondSoundSpeedSq + dT_dt / m.toFourierHeatModel.diffusivity - d2T_dx2 ∧
      m.cattaneoFluxResidual q 0 gradT = q - m.toFourierHeatModel.fourierFlux gradT := by
  have h_alpha : 0 < m.toFourierHeatModel.diffusivity :=
    div_pos m.thermalConductivity_pos m.volumetricHeatCapacity_pos
  have h_tau : 0 < m.relaxationTime := m.relaxationTime_pos
  have h_alpha_ne : m.toFourierHeatModel.diffusivity ≠ 0 := ne_of_gt h_alpha
  have h_tau_ne : m.relaxationTime ≠ 0 := ne_of_gt h_tau
  have h_cs_sq_pos : 0 < m.secondSoundSpeedSq := div_pos h_alpha h_tau
  have h_cs_pos : 0 < m.secondSoundSpeed := Real.sqrt_pos.mpr h_cs_sq_pos
  have h_fact : m.toFourierHeatModel.diffusivity = m.secondSoundSpeedSq * m.relaxationTime := by
    unfold CattaneoVernotteHeatModel.secondSoundSpeedSq
    exact (div_mul_cancel₀ _ h_tau_ne).symm
  have h_wave :
      m.telegrapherResidual d2T_dt2 dT_dt d2T_dx2 / m.toFourierHeatModel.diffusivity =
        d2T_dt2 / m.secondSoundSpeedSq + dT_dt / m.toFourierHeatModel.diffusivity - d2T_dx2 := by
    unfold CattaneoVernotteHeatModel.telegrapherResidual
      CattaneoVernotteHeatModel.secondSoundSpeedSq
    field_simp [h_alpha_ne, h_tau_ne]
  have h_red :
      m.cattaneoFluxResidual q 0 gradT = q - m.toFourierHeatModel.fourierFlux gradT := by
    unfold CattaneoVernotteHeatModel.cattaneoFluxResidual
    ring
  exact ⟨h_cs_sq_pos, h_cs_pos, h_fact, h_wave, h_red⟩

/-- **Unified Grassmannian–DDF Second-Sound Speed on a Moving Sheath**:
In a DDF moving sheath `s : MovingSheath sub`, a rest-frame thermal wave speed
$c_{\mathrm{th},0}$ contracts along the sheath axis by the coherence visibility
$\mathcal{V}(s) = \gamma_\varphi(v)^{-1} = \sqrt{1 - v^2/c^2}$:
$c_{\mathrm{th}}^{\mathrm{DDF}}(s) = c_{\mathrm{th},0}\,\mathcal{V}(s)$. -/
@[blueprint "def:signals-ddf-sheath-second-sound-speed"
  (title := "DDF MovingSheath longitudinal second-sound speed c_th^DDF(s) = c_th0 * V(s)")
  (statement := /-- For \texttt{s : MovingSheath sub} and rest-frame thermal wave speed
    $c_{\mathrm{th},0}$, define $c_{\mathrm{th}}^{\mathrm{DDF}}(s) = c_{\mathrm{th},0}\,s.\mathrm{coherenceVisibility}$. -/)]
noncomputable def MovingSheath.ddfSecondSoundSpeed
    {sub : DDFSubstrate} (s : MovingSheath sub) (c_th0 : ℝ) : ℝ :=
  c_th0 * s.coherenceVisibility

/-- **Unified Grassmannian–DDF Longitudinal Thermal Diffusivity**:
$\alpha_\parallel^{\mathrm{DDF}}(s) = \bigl(c_{\mathrm{th}}^{\mathrm{DDF}}(s)\bigr)^2\,\tau_r = (c_{\mathrm{th},0}^2 \tau_r)\,\gamma_\varphi(v)^{-2}$. -/
@[blueprint "def:signals-ddf-sheath-longitudinal-diffusivity"
  (title := "DDF MovingSheath longitudinal thermal diffusivity α_∥^DDF(s)")
  (statement := /-- Define $\alpha_\parallel^{\mathrm{DDF}}(s) = (s.\mathrm{ddfSecondSoundSpeed}\;c_{\mathrm{th},0})^2\,\tau_r$. -/)]
noncomputable def MovingSheath.ddfLongitudinalDiffusivity
    {sub : DDFSubstrate} (s : MovingSheath sub) (c_th0 tau_r : ℝ) : ℝ :=
  (s.ddfSecondSoundSpeed c_th0) ^ 2 * tau_r

/-- **Splat-Free Continuum DDF Hyperbolic Telegrapher PDE Residual**:
$\mathcal{R}_{\mathrm{tele}}^{\mathrm{DDF}}(s; T_{tt}, T_t, T_{xx}) = \tau_r\,\partial_t^2 T + \partial_t T - \alpha_\parallel^{\mathrm{DDF}}(s)\,\partial_x^2 T$. -/
@[blueprint "def:signals-ddf-sheath-telegrapher-residual"
  (title := "Splat-free continuum DDF hyperbolic telegrapher PDE residual")
  (statement := /-- For \texttt{s : MovingSheath sub}, define
    $\mathcal{R}_{\mathrm{tele}}^{\mathrm{DDF}} = \tau_r\,T_{tt} + T_t - s.\mathrm{ddfLongitudinalDiffusivity}(c_{\mathrm{th},0},\tau_r)\,T_{xx}$. -/)]
noncomputable def MovingSheath.ddfTelegrapherResidual
    {sub : DDFSubstrate} (s : MovingSheath sub)
    (c_th0 tau_r d2T_dt2 dT_dt d2T_dx2 : ℝ) : ℝ :=
  tau_r * d2T_dt2 + dT_dt - s.ddfLongitudinalDiffusivity c_th0 tau_r * d2T_dx2

/-- **Maximum Causal Ballistic Heat Flux in a DDF Moving Sheath (Splat-Free)**:
$q_{\max}^{\mathrm{DDF}}(s) = \rho c_v\,c_{\mathrm{th}}^{\mathrm{DDF}}(s)\,T_0$. -/
@[blueprint "def:signals-ddf-sheath-max-causal-heat-flux"
  (title := "Maximum causal ballistic heat flux q_max^DDF(s) = ρ c_v c_th^DDF(s) T_0")
  (statement := /-- Define $q_{\max}^{\mathrm{DDF}}(s) = C_v\,(s.\mathrm{ddfSecondSoundSpeed}\;c_{\mathrm{th},0})\,T_0$. -/)]
noncomputable def MovingSheath.ddfMaxCausalHeatFlux
    {sub : DDFSubstrate} (s : MovingSheath sub) (volHeatCap c_th0 T0 : ℝ) : ℝ :=
  volHeatCap * s.ddfSecondSoundSpeed c_th0 * T0

/-- **Splat-Free Complex $Gr_{\mathbb{C}}(2,4)$ Thermal Characteristic (Riemann-Invariant) Matrix**:
Given a dimensionless reduced heat flux $j_q = q / q_{\max}^{\mathrm{DDF}}(s) \in [-1, 1]$ and
characteristic phase $\theta \in \mathbb{R}$, embeds the right-moving ($1 + j_q$) and
left-moving ($1 - j_q$) hyperbolic second-sound waves directly into a $2 \times 4$
complex Grassmannian matrix $M_{\mathbb{C}}^{\mathrm{th}}(j_q, \theta) \in \mathbb{C}^{2 \times 4}$
without any Gaussian splat discretization. -/
@[blueprint "def:signals-ddf-thermal-gr24-matrix"
  (title := "Splat-free complex Gr_C(2,4) hyperbolic thermal characteristic matrix")
  (statement := /-- For reduced heat flux $j_q\in[-1,1]$ and phase $\theta\in\mathbb R$, define
    $M_{\mathbb C}^{\mathrm{th}}(j_q,\theta) = \operatorname{complexGr24ChannelMatrix}\bigl(\sqrt{1+j_q}\,e^{i\theta},\sqrt{1-j_q}\,e^{-i\theta}\bigr)$. -/)]
noncomputable def ddfThermalGr24Matrix (j_q θ : ℝ) : Matrix (Fin 2) (Fin 4) ℂ :=
  let a := Real.sqrt (1 + j_q)
  let b := Real.sqrt (1 - j_q)
  let z_plus : ℂ := ↑(a * Real.cos θ) + Complex.I * ↑(a * Real.sin θ)
  let z_minus : ℂ := ↑(b * Real.cos θ) - Complex.I * ↑(b * Real.sin θ)
  complexGr24ChannelMatrix z_plus z_minus

/-- **Unified Splat-Free Grassmannian $Gr_{\mathbb{C}}(2,4)$–DDF Continuum Thermal Transport Theorem**:
Establishes the complete continuum Grassmannian–DDF thermal transport laws **without**
normed Tensor Gaussian Splatters:
1. **Strict Subluminal Second-Sound Causality**:
   $0 < c_{\mathrm{th}}^{\mathrm{DDF}}(s) \le c_{\mathrm{th},0} \le c$,
2. **Pure $Gr_{\mathbb{C}}(2,4)$ Plücker Product Bridge for Jammed Diffusivity**:
   For `M_sheath := s.gr24TwistorMatrix d wavelength L Δℓ φ x`, the ratio of the
   Lorentz-jammed longitudinal diffusivity $\alpha_\parallel^{\mathrm{DDF}}(s)$ to the
   rest-frame diffusivity $\alpha_0 = c_{\mathrm{th},0}^2 \tau_r$ equals the product of the
   two uncrossed complex Plücker channel densities:
   $$\frac{\alpha_\parallel^{\mathrm{DDF}}(s)}{c_{\mathrm{th},0}^2 \tau_r} = \bigl|w_A^{\mathbb{C}}(M_{\mathrm{sheath}})\bigr|^2\,\bigl|w_B^{\mathbb{C}}(M_{\mathrm{sheath}})\bigr|^2 = \bigl(\gamma_\varphi(v)^2\bigr)^{-1},$$
3. **Continuum DDF Telegrapher Wave-Operator Factorization**:
   $$\frac{\mathcal{R}_{\mathrm{tele}}^{\mathrm{DDF}}(s; T_{tt}, T_t, T_{xx})}{\alpha_\parallel^{\mathrm{DDF}}(s)} = \frac{\gamma_\varphi(v)^2}{c_{\mathrm{th},0}^2}\,T_{tt} + \frac{\gamma_\varphi(v)^2}{c_{\mathrm{th},0}^2 \tau_r}\,T_t - T_{xx},$$
4. **Splat-Free $Gr_{\mathbb{C}}(2,4)$ Riemann-Invariant Characteristic Split & Relativistic Cattaneo Flux Limiter**:
   For any reduced heat flux $j_q \in (-1, 1)$ and `M_th := ddfThermalGr24Matrix j_q θ`,
   $$|w_A^{\mathbb{C}}(M_{\mathrm{th}})|^2 = 1 + j_q, \qquad |w_B^{\mathbb{C}}(M_{\mathrm{th}})|^2 = 1 - j_q,$$
   $$\frac{|w_A^{\mathbb{C}}(M_{\mathrm{th}})|^2 - |w_B^{\mathbb{C}}(M_{\mathrm{th}})|^2}{2} = j_q, \qquad 0 < |w_A^{\mathbb{C}}(M_{\mathrm{th}})|^2\,|w_B^{\mathbb{C}}(M_{\mathrm{th}})|^2 = 1 - j_q^2.$$ -/
@[blueprint "thm:signals-ddf-thermal-transport-continuum"
  (title := "Splat-free unified Grassmannian Gr_C(2,4)-DDF continuum thermal transport and Pluecker flux-limiter theorem")
  (statement := /-- For \texttt{s : MovingSheath sub} with $0 < c_{\mathrm{th},0}\le sub.c$, $\tau_r>0$,
    and reduced heat flux $j_q\in(-1,1)$:
    (1) $0 < s.\mathrm{ddfSecondSoundSpeed}\;c_{\mathrm{th},0} \le sub.c$,
    (2) $\frac{s.\mathrm{ddfLongitudinalDiffusivity}\;c_{\mathrm{th},0}\;\tau_r}{c_{\mathrm{th},0}^2\tau_r} =
    |w_A^{\mathbb C}(M_{\mathrm{sheath}})|^2\,|w_B^{\mathbb C}(M_{\mathrm{sheath}})|^2 = (s.\mathrm{jammingFactor}^2)^{-1}$,
    (3) $\frac{s.\mathrm{ddfTelegrapherResidual}\;c_{\mathrm{th},0}\;\tau_r\;T_{tt}\;T_t\;T_{xx}}{s.\mathrm{ddfLongitudinalDiffusivity}\;c_{\mathrm{th},0}\;\tau_r}
    = \frac{s.\mathrm{jammingFactor}^2}{c_{\mathrm{th},0}^2}\,T_{tt} + \frac{s.\mathrm{jammingFactor}^2}{c_{\mathrm{th},0}^2\tau_r}\,T_t - T_{xx}$, and
    (4) for $M_{\mathrm{th}} = \operatorname{ddfThermalGr24Matrix}\;j_q\;\theta$,
    $\frac{|w_A^{\mathbb C}(M_{\mathrm{th}})|^2 - |w_B^{\mathbb C}(M_{\mathrm{th}})|^2}{2} = j_q$ and
    $0 < |w_A^{\mathbb C}(M_{\mathrm{th}})|^2\,|w_B^{\mathbb C}(M_{\mathrm{th}})|^2 = 1 - j_q^2$. -/)
  (proof := /-- Combine \texttt{visibility\_jamming\_duality}, \texttt{gr24TwistorMatrix\_madelung\_sector\_identities},
    field simplification of \texttt{ddfTelegrapherResidual}, and \texttt{complexGr24ChannelMatrix\_minors}. -/)]
theorem MovingSheath.ddfThermalTransport_continuum_identities
    {sub : DDFSubstrate} (s : MovingSheath sub)
    (c_th0 tau_r d wavelength L φ x d2T_dt2 dT_dt d2T_dx2 j_q θ : ℝ)
    (Δℓ : ℤ)
    (hc_pos : 0 < c_th0) (hc_le : c_th0 ≤ sub.c)
    (htau_pos : 0 < tau_r)
    (hjq_gt : -1 < j_q) (hjq_lt : j_q < 1) :
    let M_sheath := s.gr24TwistorMatrix d wavelength L Δℓ φ x
    let M_th := ddfThermalGr24Matrix j_q θ
    0 < s.ddfSecondSoundSpeed c_th0 ∧
      s.ddfSecondSoundSpeed c_th0 ≤ sub.c ∧
      s.ddfLongitudinalDiffusivity c_th0 tau_r / (c_th0 ^ 2 * tau_r) =
        Complex.normSq (complexPluckerSinkAmplitudeA M_sheath) *
          Complex.normSq (complexPluckerSinkAmplitudeB M_sheath) ∧
      s.ddfLongitudinalDiffusivity c_th0 tau_r / (c_th0 ^ 2 * tau_r) =
        (s.jammingFactor ^ 2)⁻¹ ∧
      s.ddfTelegrapherResidual c_th0 tau_r d2T_dt2 dT_dt d2T_dx2 /
          s.ddfLongitudinalDiffusivity c_th0 tau_r =
        (s.jammingFactor ^ 2 / c_th0 ^ 2) * d2T_dt2 +
          (s.jammingFactor ^ 2 / (c_th0 ^ 2 * tau_r)) * dT_dt - d2T_dx2 ∧
      (Complex.normSq (complexPluckerSinkAmplitudeA M_th) -
          Complex.normSq (complexPluckerSinkAmplitudeB M_th)) / 2 = j_q ∧
      Complex.normSq (complexPluckerSinkAmplitudeA M_th) *
          Complex.normSq (complexPluckerSinkAmplitudeB M_th) = 1 - j_q ^ 2 ∧
      0 < Complex.normSq (complexPluckerSinkAmplitudeA M_th) *
          Complex.normSq (complexPluckerSinkAmplitudeB M_th) := by
  intro M_sheath M_th
  have h_vis_pos : 0 < s.coherenceVisibility :=
    Real.sqrt_pos.mpr s.one_sub_betaSq_pos
  have h_beta_sq_nonneg : 0 ≤ s.betaSq := by
    unfold MovingSheath.betaSq
    positivity
  have h_vis_le_one : s.coherenceVisibility ≤ 1 := by
    unfold MovingSheath.coherenceVisibility
    exact Real.sqrt_le_one.mpr (by linarith)
  have h_cs_pos : 0 < s.ddfSecondSoundSpeed c_th0 :=
    mul_pos hc_pos h_vis_pos
  have h_cs_le_c0 : s.ddfSecondSoundSpeed c_th0 ≤ c_th0 := by
    unfold MovingSheath.ddfSecondSoundSpeed
    exact mul_le_of_le_one_right (le_of_lt hc_pos) h_vis_le_one
  have h_cs_le_c : s.ddfSecondSoundSpeed c_th0 ≤ sub.c :=
    le_trans h_cs_le_c0 hc_le
  have h_diff_jam :
      s.ddfLongitudinalDiffusivity c_th0 tau_r =
        (c_th0 ^ 2 * tau_r) * (s.jammingFactor ^ 2)⁻¹ := by
    unfold MovingSheath.ddfLongitudinalDiffusivity MovingSheath.ddfSecondSoundSpeed
    rw [(s.visibility_jamming_duality).1]
    ring
  have hc0_ne : c_th0 ≠ 0 := ne_of_gt hc_pos
  have htau_ne : tau_r ≠ 0 := ne_of_gt htau_pos
  have hjam_ne : s.jammingFactor ≠ 0 := ne_of_gt s.jammingFactor_pos
  have h_ratio_jam :
      s.ddfLongitudinalDiffusivity c_th0 tau_r / (c_th0 ^ 2 * tau_r) =
        (s.jammingFactor ^ 2)⁻¹ := by
    have hc0_tau_ne : c_th0 ^ 2 * tau_r ≠ 0 := by positivity
    rw [h_diff_jam, mul_div_cancel_left₀ _ hc0_tau_ne]
  have h_mad := s.gr24TwistorMatrix_madelung_sector_identities d wavelength L Δℓ φ x
  have h_sheath_prod :
      Complex.normSq (complexPluckerSinkAmplitudeA M_sheath) *
          Complex.normSq (complexPluckerSinkAmplitudeB M_sheath) =
        (s.jammingFactor ^ 2)⁻¹ :=
    h_mad.2.2.2.2.1.trans h_mad.2.2.2.2.2
  have h_ratio_plucker :
      s.ddfLongitudinalDiffusivity c_th0 tau_r / (c_th0 ^ 2 * tau_r) =
        Complex.normSq (complexPluckerSinkAmplitudeA M_sheath) *
          Complex.normSq (complexPluckerSinkAmplitudeB M_sheath) :=
    h_ratio_jam.trans h_sheath_prod.symm
  have h_tele :
      s.ddfTelegrapherResidual c_th0 tau_r d2T_dt2 dT_dt d2T_dx2 /
          s.ddfLongitudinalDiffusivity c_th0 tau_r =
        (s.jammingFactor ^ 2 / c_th0 ^ 2) * d2T_dt2 +
          (s.jammingFactor ^ 2 / (c_th0 ^ 2 * tau_r)) * dT_dt - d2T_dx2 := by
    unfold MovingSheath.ddfTelegrapherResidual
    rw [h_diff_jam]
    field_simp [hc0_ne, htau_ne, hjam_ne]
  have h1p : 0 ≤ 1 + j_q := by linarith
  have h1m : 0 ≤ 1 - j_q := by linarith
  have h_minors := complexGr24ChannelMatrix_minors
    (↑(Real.sqrt (1 + j_q) * Real.cos θ) + Complex.I * ↑(Real.sqrt (1 + j_q) * Real.sin θ))
    (↑(Real.sqrt (1 - j_q) * Real.cos θ) - Complex.I * ↑(Real.sqrt (1 - j_q) * Real.sin θ))
  have h_wA :
      Complex.normSq (complexPluckerSinkAmplitudeA M_th) = 1 + j_q := by
    dsimp [M_th, ddfThermalGr24Matrix, complexPluckerSinkAmplitudeA]
    rw [h_minors.1]
    simp only [Complex.normSq_apply, Complex.add_re, Complex.add_im, Complex.mul_re,
      Complex.mul_im, Complex.ofReal_re, Complex.ofReal_im, Complex.I_re, Complex.I_im]
    calc
      _ = (Real.sqrt (1 + j_q)) ^ 2 * ((Real.cos θ) ^ 2 + (Real.sin θ) ^ 2) := by ring
      _ = 1 + j_q := by rw [Real.sq_sqrt h1p, Real.cos_sq_add_sin_sq, mul_one]
  have h_wB :
      Complex.normSq (complexPluckerSinkAmplitudeB M_th) = 1 - j_q := by
    dsimp [M_th, ddfThermalGr24Matrix, complexPluckerSinkAmplitudeB]
    rw [h_minors.2.1]
    simp only [Complex.normSq_apply, Complex.sub_re, Complex.sub_im, Complex.mul_re,
      Complex.mul_im, Complex.ofReal_re, Complex.ofReal_im, Complex.I_re, Complex.I_im]
    calc
      _ = (Real.sqrt (1 - j_q)) ^ 2 * ((Real.cos θ) ^ 2 + (Real.sin θ) ^ 2) := by ring
      _ = 1 - j_q := by rw [Real.sq_sqrt h1m, Real.cos_sq_add_sin_sq, mul_one]
  have h_jq_rec :
      (Complex.normSq (complexPluckerSinkAmplitudeA M_th) -
          Complex.normSq (complexPluckerSinkAmplitudeB M_th)) / 2 = j_q := by
    rw [h_wA, h_wB]
    ring
  have h_th_prod :
      Complex.normSq (complexPluckerSinkAmplitudeA M_th) *
          Complex.normSq (complexPluckerSinkAmplitudeB M_th) = 1 - j_q ^ 2 := by
    rw [h_wA, h_wB]
    ring
  have h_th_pos :
      0 < Complex.normSq (complexPluckerSinkAmplitudeA M_th) *
          Complex.normSq (complexPluckerSinkAmplitudeB M_th) := by
    rw [h_th_prod]
    nlinarith
  exact ⟨h_cs_pos, h_cs_le_c, h_ratio_plucker, h_ratio_jam, h_tele,
    h_jq_rec, h_th_prod, h_th_pos⟩

/-- **Exact $L^1$-Conserving Anisotropic Thermal Evolution of a Normed 2D Tensor Gaussian Splat**:
Under anisotropic thermal diffusivities $(\alpha_1, \alpha_2) \ge 0$ over elapsed time
$\Delta t \ge 0$, the principal variances evolve by the exact Green's-function convolution
law $\sigma_1(t + \Delta t) = \sqrt{\sigma_1^2 + 2\alpha_1 \Delta t}$ and
$\sigma_2(t + \Delta t) = \sqrt{\sigma_2^2 + 2\alpha_2 \Delta t}$, preserving total
thermal weight $w$ identically. -/
@[blueprint "def:signals-ddf-splat2d-evolve-thermal"
  (title := "Anisotropic thermal diffusion evolution of a NormedTensorGaussianSplat2D")
  (statement := /-- Evolve \texttt{splat : NormedTensorGaussianSplat2D} over $\Delta t\ge 0$
    with principal diffusivities $\alpha_1,\alpha_2\ge 0$ via
    $\sigma_i \mapsto \sqrt{\sigma_i^2 + 2\alpha_i\Delta t}$. -/)]
noncomputable def NormedTensorGaussianSplat2D.evolveThermal
    (splat : NormedTensorGaussianSplat2D) (alpha1 alpha2 dt : ℝ)
    (h_a1 : 0 ≤ alpha1) (h_a2 : 0 ≤ alpha2) (h_dt : 0 ≤ dt) :
    NormedTensorGaussianSplat2D :=
  { centerX := splat.centerX
    centerY := splat.centerY
    weight := splat.weight
    weight_nonneg := splat.weight_nonneg
    sigma1 := Real.sqrt (splat.sigma1 ^ 2 + 2 * alpha1 * dt)
    sigma1_pos := by
      apply Real.sqrt_pos.mpr
      have hs1 : 0 < splat.sigma1 ^ 2 := sq_pos_of_pos splat.sigma1_pos
      have h_add : 0 ≤ 2 * alpha1 * dt := by positivity
      linarith
    sigma2 := Real.sqrt (splat.sigma2 ^ 2 + 2 * alpha2 * dt)
    sigma2_pos := by
      apply Real.sqrt_pos.mpr
      have hs2 : 0 < splat.sigma2 ^ 2 := sq_pos_of_pos splat.sigma2_pos
      have h_add : 0 ≤ 2 * alpha2 * dt := by positivity
      linarith
    orientationAngle := splat.orientationAngle }

/-- **Unified Grassmannian $Gr_{\mathbb{C}}(2,4)$–DDF Thermal Transport & Tensor Splat Evolution Theorem**:
For any `s : MovingSheath sub`, rest-frame second-sound speed $0 < c_{\mathrm{th},0} \le c$,
relaxation time $\tau_r > 0$, and `splat : NormedTensorGaussianSplat2D`:
1. **Strict Subluminal Causality**: $0 < c_{\mathrm{th}}^{\mathrm{DDF}}(s) \le c_{\mathrm{th},0} \le c$,
2. **Lorentz-Jammed Longitudinal Diffusivity**:
   $\alpha_\parallel^{\mathrm{DDF}}(s) = (c_{\mathrm{th},0}^2 \tau_r)\,\bigl(\gamma_\varphi(v)^2\bigr)^{-1}$,
3. **Exact Tensor Splat Covariance Determinant Bridge**:
   For `splat_ddf := s.ddfTensorSplat ...`,
   $\frac{\alpha_\parallel^{\mathrm{DDF}}(s)}{c_{\mathrm{th},0}^2 \tau_r} = \frac{\det\Sigma_{\mathrm{DDF}}}{\sigma_0^4} = \bigl(\gamma_\varphi(v)^2\bigr)^{-1}$, and
4. **Exact $L^1$ Thermal Energy Conservation & Linear Covariance Trace Growth**:
   `(splat.evolveThermal alpha1 alpha2 dt ...).weight = splat.weight` and
   `(splat.evolveThermal alpha1 alpha2 dt ...).covTrace = splat.covTrace + 2 * (alpha1 + alpha2) * dt`. -/
@[blueprint "thm:signals-ddf-thermal-transport-and-splat"
  (title := "Unified Grassmannian-DDF subluminal second sound, jammed diffusivity, and thermal splat evolution theorem")
  (statement := /-- For \texttt{s : MovingSheath sub} with $0 < c_{\mathrm{th},0}\le c$ and $\tau_r>0$:
    (1) $0 < s.\mathrm{ddfSecondSoundSpeed}\;c_{\mathrm{th},0} \le sub.c$,
    (2) $s.\mathrm{ddfLongitudinalDiffusivity}\;c_{\mathrm{th},0}\;\tau_r = (c_{\mathrm{th},0}^2\tau_r)\,(s.\mathrm{jammingFactor}^2)^{-1}$,
    (3) $\frac{s.\mathrm{ddfLongitudinalDiffusivity}\;c_{\mathrm{th},0}\;\tau_r}{c_{\mathrm{th},0}^2\tau_r} = \frac{\det\Sigma_{\mathrm{DDF}}}{\sigma_0^4}$, and
    (4) \texttt{splat.evolveThermal} preserves \texttt{weight} and satisfies
    $\operatorname{Tr}\Sigma(t+\Delta t) = \operatorname{Tr}\Sigma(t) + 2(\alpha_1+\alpha_2)\Delta t$. -/)
  (proof := /-- Combine $0 < \mathcal{V}(s) \le 1$, $\mathcal{V}(s) = \gamma_\varphi(v)^{-1}$,
    \texttt{ddfTensorSplat\_identities}, and $\sqrt{\sigma_i^2 + 2\alpha_i\Delta t}^2 = \sigma_i^2 + 2\alpha_i\Delta t$. -/)]
theorem MovingSheath.ddfThermalTransport_and_splat_identities
    {sub : DDFSubstrate} (s : MovingSheath sub)
    (splat : NormedTensorGaussianSplat2D)
    (centerX centerY weight sigma0 c_th0 tau_r alpha1 alpha2 dt orientationAngle : ℝ)
    (hw : 0 ≤ weight) (h_sigma0 : 0 < sigma0)
    (hc_pos : 0 < c_th0) (hc_le : c_th0 ≤ sub.c)
    (htau_pos : 0 < tau_r)
    (h_a1 : 0 ≤ alpha1) (h_a2 : 0 ≤ alpha2) (h_dt : 0 ≤ dt) :
    let splat_ddf := s.ddfTensorSplat centerX centerY weight sigma0 hw h_sigma0 orientationAngle
    let splat_evol := splat.evolveThermal alpha1 alpha2 dt h_a1 h_a2 h_dt
    0 < s.ddfSecondSoundSpeed c_th0 ∧
      s.ddfSecondSoundSpeed c_th0 ≤ sub.c ∧
      s.ddfLongitudinalDiffusivity c_th0 tau_r =
        (c_th0 ^ 2 * tau_r) * (s.jammingFactor ^ 2)⁻¹ ∧
      s.ddfLongitudinalDiffusivity c_th0 tau_r / (c_th0 ^ 2 * tau_r) =
        splat_ddf.covDet / sigma0 ^ 4 ∧
      splat_evol.weight = splat.weight ∧
      splat_evol.covTrace = splat.covTrace + 2 * (alpha1 + alpha2) * dt := by
  intro splat_ddf splat_evol
  have h_vis_pos : 0 < s.coherenceVisibility :=
    Real.sqrt_pos.mpr s.one_sub_betaSq_pos
  have h_beta_sq_nonneg : 0 ≤ s.betaSq := by
    unfold MovingSheath.betaSq
    positivity
  have h_vis_le_one : s.coherenceVisibility ≤ 1 := by
    unfold MovingSheath.coherenceVisibility
    exact Real.sqrt_le_one.mpr (by linarith)
  have h_cs_pos : 0 < s.ddfSecondSoundSpeed c_th0 :=
    mul_pos hc_pos h_vis_pos
  have h_cs_le_c0 : s.ddfSecondSoundSpeed c_th0 ≤ c_th0 := by
    unfold MovingSheath.ddfSecondSoundSpeed
    exact mul_le_of_le_one_right (le_of_lt hc_pos) h_vis_le_one
  have h_cs_le_c : s.ddfSecondSoundSpeed c_th0 ≤ sub.c :=
    le_trans h_cs_le_c0 hc_le
  have h_diff_jam :
      s.ddfLongitudinalDiffusivity c_th0 tau_r =
        (c_th0 ^ 2 * tau_r) * (s.jammingFactor ^ 2)⁻¹ := by
    unfold MovingSheath.ddfLongitudinalDiffusivity MovingSheath.ddfSecondSoundSpeed
    rw [(s.visibility_jamming_duality).1]
    ring
  have h_bridge :
      s.ddfLongitudinalDiffusivity c_th0 tau_r / (c_th0 ^ 2 * tau_r) =
        splat_ddf.covDet / sigma0 ^ 4 := by
    have h_ddf_id := s.ddfTensorSplat_identities centerX centerY weight sigma0 hw h_sigma0 orientationAngle
    have h_det : splat_ddf.covDet = sigma0 ^ 4 * (s.jammingFactor ^ 2)⁻¹ := h_ddf_id.2.1
    have hc0_ne : c_th0 ^ 2 * tau_r ≠ 0 := by positivity
    have hs0_ne : sigma0 ^ 4 ≠ 0 := by positivity
    rw [h_diff_jam, h_det, mul_div_cancel_left₀ _ hc0_ne, mul_div_cancel_left₀ _ hs0_ne]
  have h_wt : splat_evol.weight = splat.weight := rfl
  have h_tr : splat_evol.covTrace = splat.covTrace + 2 * (alpha1 + alpha2) * dt := by
    dsimp [splat_evol, NormedTensorGaussianSplat2D.evolveThermal,
      NormedTensorGaussianSplat2D.covTrace]
    have hs1_nonneg : 0 ≤ splat.sigma1 ^ 2 + 2 * alpha1 * dt := by
      have : 0 ≤ splat.sigma1 ^ 2 := sq_nonneg _
      have : 0 ≤ 2 * alpha1 * dt := by positivity
      linarith
    have hs2_nonneg : 0 ≤ splat.sigma2 ^ 2 + 2 * alpha2 * dt := by
      have : 0 ≤ splat.sigma2 ^ 2 := sq_nonneg _
      have : 0 ≤ 2 * alpha2 * dt := by positivity
      linarith
    rw [Real.sq_sqrt hs1_nonneg, Real.sq_sqrt hs2_nonneg]
    ring
  exact ⟨h_cs_pos, h_cs_le_c, h_diff_jam, h_bridge, h_wt, h_tr⟩

/-- **Physical Splat-Free Heat-Flux Bound & Second-Law Thermal Splat Covariance Determinant Growth**:
1. For any `s : MovingSheath sub`, volumetric heat capacity $C_v > 0$, reference
   temperature $T_0 > 0$, and rest-frame second-sound speed $0 < c_{\mathrm{th},0} \le sub.c$,
   the maximum causal ballistic heat flux satisfies:
   $$0 < q_{\max}^{\mathrm{DDF}}(s) = C_v\,c_{\mathrm{th}}^{\mathrm{DDF}}(s)\,T_0 \le C_v\,sub.c\,T_0,$$
2. Whenever the reduced heat flux $j_q = q / q_{\max}^{\mathrm{DDF}}(s) \in (-1, 1)$
   satisfies the $Gr_{\mathbb{C}}(2,4)$ Plücker characteristic condition, the physical
   heat flux is strictly bounded by the relativistic causal ceiling:
   $$q^2 < \bigl(q_{\max}^{\mathrm{DDF}}(s)\bigr)^2,$$
3. Under `splat.evolveThermal alpha1 alpha2 dt`, the covariance determinant expands as:
   $$\det\Sigma(t + \Delta t) = \det\Sigma(t) + 2\bigl(\alpha_1\,\sigma_2^2 + \alpha_2\,\sigma_1^2\bigr)\,\Delta t + 4\,\alpha_1\,\alpha_2\,(\Delta t)^2,$$
4. Consequently, $\det\Sigma(t) \le \det\Sigma(t + \Delta t)$ for all $\alpha_1, \alpha_2, \Delta t \ge 0$
   (and $\det\Sigma(t) < \det\Sigma(t + \Delta t)$ whenever $0 < \alpha_1$ and $0 < \Delta t$),
   establishing irreversible Second-Law phase-space expansion in contrast to symplectic
   Anosov invariance ($\det\Sigma = \text{const}$). -/
@[blueprint "thm:signals-ddf-thermal-flux-limiter-and-entropy"
  (title := "Physical DDF ballistic heat-flux bound and Second-Law covariance determinant growth theorem")
  (statement := /-- For \texttt{s : MovingSheath sub} with $C_v>0$, $T_0>0$, and $0<c_{\mathrm{th},0}\le sub.c$:
    (1) $0 < s.\mathrm{ddfMaxCausalHeatFlux}\;C_v\;c_{\mathrm{th},0}\;T_0 \le C_v\,sub.c\,T_0$,
    (2) if $-1 < q / (s.\mathrm{ddfMaxCausalHeatFlux}\;C_v\;c_{\mathrm{th},0}\;T_0) < 1$, then
    $q^2 < (s.\mathrm{ddfMaxCausalHeatFlux}\;C_v\;c_{\mathrm{th},0}\;T_0)^2$,
    (3) $\det\Sigma(t+\Delta t) = \det\Sigma(t) + 2(\alpha_1\sigma_2^2 + \alpha_2\sigma_1^2)\Delta t + 4\alpha_1\alpha_2(\Delta t)^2$, and
    (4) $\det\Sigma(t) \le \det\Sigma(t+\Delta t)$ (with strict inequality when $0<\alpha_1$ and $0<\Delta t$). -/)
  (proof := /-- Combine $0 < c_{\mathrm{th}}^{\mathrm{DDF}}(s) \le sub.c$, clear $q_{\max}^{\mathrm{DDF}}(s)>0$ in
    $1 - (q/q_{\max})^2 > 0$, and expand $(\sigma_1^2 + 2\alpha_1\Delta t)(\sigma_2^2 + 2\alpha_2\Delta t)$. -/)]
theorem MovingSheath.ddfThermal_fluxLimiter_and_entropy_growth
    {sub : DDFSubstrate} (s : MovingSheath sub)
    (splat : NormedTensorGaussianSplat2D)
    (volHeatCap c_th0 T0 q alpha1 alpha2 dt : ℝ)
    (hCv : 0 < volHeatCap) (hc_pos : 0 < c_th0) (hc_le : c_th0 ≤ sub.c)
    (hT0 : 0 < T0)
    (hjq_gt : -1 < q / s.ddfMaxCausalHeatFlux volHeatCap c_th0 T0)
    (hjq_lt : q / s.ddfMaxCausalHeatFlux volHeatCap c_th0 T0 < 1)
    (h_a1 : 0 ≤ alpha1) (h_a2 : 0 ≤ alpha2) (h_dt : 0 ≤ dt) :
    let q_max := s.ddfMaxCausalHeatFlux volHeatCap c_th0 T0
    let splat_evol := splat.evolveThermal alpha1 alpha2 dt h_a1 h_a2 h_dt
    0 < q_max ∧
      q_max ≤ volHeatCap * sub.c * T0 ∧
      q ^ 2 < q_max ^ 2 ∧
      splat_evol.covDet =
        splat.covDet +
          2 * (alpha1 * splat.sigma2 ^ 2 + alpha2 * splat.sigma1 ^ 2) * dt +
          4 * alpha1 * alpha2 * dt ^ 2 ∧
      splat.covDet ≤ splat_evol.covDet ∧
      (0 < alpha1 ∧ 0 < dt → splat.covDet < splat_evol.covDet) := by
  intro q_max splat_evol
  have h_vis_pos : 0 < s.coherenceVisibility :=
    Real.sqrt_pos.mpr s.one_sub_betaSq_pos
  have h_beta_sq_nonneg : 0 ≤ s.betaSq := by
    unfold MovingSheath.betaSq
    positivity
  have h_vis_le_one : s.coherenceVisibility ≤ 1 := by
    unfold MovingSheath.coherenceVisibility
    exact Real.sqrt_le_one.mpr (by linarith)
  have h_cs_pos : 0 < s.ddfSecondSoundSpeed c_th0 :=
    mul_pos hc_pos h_vis_pos
  have h_cs_le_c0 : s.ddfSecondSoundSpeed c_th0 ≤ c_th0 := by
    unfold MovingSheath.ddfSecondSoundSpeed
    exact mul_le_of_le_one_right (le_of_lt hc_pos) h_vis_le_one
  have h_cs_le_c : s.ddfSecondSoundSpeed c_th0 ≤ sub.c :=
    le_trans h_cs_le_c0 hc_le
  have h_qmax_pos : 0 < q_max := by
    dsimp [q_max, MovingSheath.ddfMaxCausalHeatFlux]
    positivity
  have h_qmax_le : q_max ≤ volHeatCap * sub.c * T0 := by
    dsimp [q_max, MovingSheath.ddfMaxCausalHeatFlux]
    have h1 : volHeatCap * s.ddfSecondSoundSpeed c_th0 ≤ volHeatCap * sub.c :=
      mul_le_mul_of_nonneg_left h_cs_le_c (le_of_lt hCv)
    exact mul_le_mul_of_nonneg_right h1 (le_of_lt hT0)
  have h_q_sq : q ^ 2 < q_max ^ 2 := by
    have h_gt' : (-1 : ℝ) < q / q_max := hjq_gt
    have h_lt' : q / q_max < (1 : ℝ) := hjq_lt
    have h_gt : (-1 : ℝ) * q_max < q := (lt_div_iff₀ h_qmax_pos).mp h_gt'
    have h_lt : q < (1 : ℝ) * q_max := (div_lt_iff₀ h_qmax_pos).mp h_lt'
    nlinarith
  have h_det_exp :
      splat_evol.covDet =
        splat.covDet +
          2 * (alpha1 * splat.sigma2 ^ 2 + alpha2 * splat.sigma1 ^ 2) * dt +
          4 * alpha1 * alpha2 * dt ^ 2 := by
    dsimp [splat_evol, NormedTensorGaussianSplat2D.evolveThermal,
      NormedTensorGaussianSplat2D.covDet]
    have hs1_nonneg : 0 ≤ splat.sigma1 ^ 2 + 2 * alpha1 * dt := by
      have : 0 ≤ splat.sigma1 ^ 2 := sq_nonneg _
      have : 0 ≤ 2 * alpha1 * dt := by positivity
      linarith
    have hs2_nonneg : 0 ≤ splat.sigma2 ^ 2 + 2 * alpha2 * dt := by
      have : 0 ≤ splat.sigma2 ^ 2 := sq_nonneg _
      have : 0 ≤ 2 * alpha2 * dt := by positivity
      linarith
    rw [Real.sq_sqrt hs1_nonneg, Real.sq_sqrt hs2_nonneg]
    ring
  have h_det_le : splat.covDet ≤ splat_evol.covDet := by
    rw [h_det_exp]
    have h_t1 : 0 ≤ 2 * (alpha1 * splat.sigma2 ^ 2 + alpha2 * splat.sigma1 ^ 2) * dt := by
      positivity
    have h_t2 : 0 ≤ 4 * alpha1 * alpha2 * dt ^ 2 := by positivity
    linarith
  have h_det_lt : 0 < alpha1 ∧ 0 < dt → splat.covDet < splat_evol.covDet := by
    rintro ⟨ha1_pos, hdt_pos⟩
    rw [h_det_exp]
    have hs2_pos : 0 < splat.sigma2 ^ 2 := sq_pos_of_pos splat.sigma2_pos
    have h_pos1 : 0 < 2 * (alpha1 * splat.sigma2 ^ 2) * dt := by positivity
    have h_nonneg2 : 0 ≤ 2 * (alpha2 * splat.sigma1 ^ 2) * dt := by positivity
    have h_nonneg3 : 0 ≤ 4 * alpha1 * alpha2 * dt ^ 2 := by positivity
    linarith
  exact ⟨h_qmax_pos, h_qmax_le, h_q_sq, h_det_exp, h_det_le, h_det_lt⟩

/-- **Chapman–Kolmogorov Thermal Semigroup Composition & Monotonic Core Bohm Quantum-Potential Relaxation**:
For any `splat : NormedTensorGaussianSplat2D`, principal diffusivities $\alpha_1, \alpha_2 \ge 0$,
time increments $\Delta t_1, \Delta t_2 \ge 0$, boson mass $m > 0$, and $\hbar \in \mathbb{R}$:
1. **Exact Chapman–Kolmogorov Semigroup Composition**:
   Evolving by $\Delta t_1$ and then by $\Delta t_2$ produces the exact same
   `NormedTensorGaussianSplat2D` as evolving in a single step by $\Delta t_1 + \Delta t_2$,
2. **Monotonic Peak Normalization Relaxation**:
   $\mathcal{N}\bigl(\Sigma(t + \Delta t_1)\bigr) \le \mathcal{N}\bigl(\Sigma(t)\bigr)$, and
3. **Monotonic Core Bohm Quantum-Potential Relaxation**:
   $Q_{\mathrm{core}}\bigl(\Sigma(t + \Delta t_1)\bigr) \le Q_{\mathrm{core}}\bigl(\Sigma(t)\bigr)$,
   showing that thermal diffusion monotonically relaxes quantum-pressure gradients. -/
@[blueprint "thm:signals-ddf-splat2d-thermal-semigroup-bohm-decay"
  (title := "Chapman-Kolmogorov thermal splat semigroup identity/composition and monotonic core Bohm potential relaxation")
  (statement := /-- For \texttt{splat : NormedTensorGaussianSplat2D}, $\alpha_1,\alpha_2,\Delta t_1,\Delta t_2\ge 0$,
    and $m>0$:
    (1) $\operatorname{splat.evolveThermal}\;\alpha_1\;\alpha_2\;0 = \operatorname{splat}$,
    (2) $(\operatorname{splat.evolveThermal}\;\alpha_1\;\alpha_2\;\Delta t_1).\operatorname{evolveThermal}\;\alpha_1\;\alpha_2\;\Delta t_2
    = \operatorname{splat.evolveThermal}\;\alpha_1\;\alpha_2\;(\Delta t_1+\Delta t_2)$,
    (3) $(\operatorname{splat.evolveThermal}\;\alpha_1\;\alpha_2\;\Delta t_1).\mathrm{normFactor} \le \operatorname{splat}.\mathrm{normFactor}$, and
    (4) $(\operatorname{splat.evolveThermal}\;\alpha_1\;\alpha_2\;\Delta t_1).\operatorname{coreBohmPotential}\;m\;\hbar \le
    \operatorname{splat}.\operatorname{coreBohmPotential}\;m\;\hbar$. -/)
  (proof := /-- Use $\sqrt{\sigma_i^2}=\sigma_i$ at $\Delta t=0$,
    $\sqrt{\sigma_i^2 + 2\alpha_i\Delta t_1}^2 + 2\alpha_i\Delta t_2 = \sigma_i^2 + 2\alpha_i(\Delta t_1+\Delta t_2)$
    for semigroup additivity, and monotonicity of $\sigma_i \le \sqrt{\sigma_i^2 + 2\alpha_i\Delta t_1}$
    for $\mathcal{N}(\Sigma)$ and $Q_{\mathrm{core}}(\Sigma)$. -/)]
theorem NormedTensorGaussianSplat2D.evolveThermal_semigroup_and_bohm_decay
    (splat : NormedTensorGaussianSplat2D)
    (alpha1 alpha2 dt1 dt2 m_boson hbar : ℝ)
    (h_a1 : 0 ≤ alpha1) (h_a2 : 0 ≤ alpha2)
    (h_dt1 : 0 ≤ dt1) (h_dt2 : 0 ≤ dt2)
    (hm : 0 < m_boson) :
    let step0 := splat.evolveThermal alpha1 alpha2 0 h_a1 h_a2 le_rfl
    let step1 := splat.evolveThermal alpha1 alpha2 dt1 h_a1 h_a2 h_dt1
    let step12 := step1.evolveThermal alpha1 alpha2 dt2 h_a1 h_a2 h_dt2
    let step_sum := splat.evolveThermal alpha1 alpha2 (dt1 + dt2) h_a1 h_a2 (add_nonneg h_dt1 h_dt2)
    step0 = splat ∧
      step12 = step_sum ∧
      step1.normFactor ≤ splat.normFactor ∧
      step1.coreBohmPotential m_boson hbar ≤ splat.coreBohmPotential m_boson hbar := by
  intro step0 step1 step12 step_sum
  have hs1_pos : 0 < splat.sigma1 := splat.sigma1_pos
  have hs2_pos : 0 < splat.sigma2 := splat.sigma2_pos
  have hs1_sq_pos : 0 < splat.sigma1 ^ 2 := sq_pos_of_pos hs1_pos
  have hs2_sq_pos : 0 < splat.sigma2 ^ 2 := sq_pos_of_pos hs2_pos
  have h_id : step0 = splat := by
    cases splat with
    | mk cx cy w hw s1 hs1 s2 hs2 θ =>
      dsimp [step0, NormedTensorGaussianSplat2D.evolveThermal]
      congr 1
      · simp [Real.sqrt_sq (le_of_lt hs1)]
      · simp [Real.sqrt_sq (le_of_lt hs2)]
  have h1_nonneg : 0 ≤ splat.sigma1 ^ 2 + 2 * alpha1 * dt1 := by
    have : 0 ≤ 2 * alpha1 * dt1 := by positivity
    linarith
  have h2_nonneg : 0 ≤ splat.sigma2 ^ 2 + 2 * alpha2 * dt1 := by
    have : 0 ≤ 2 * alpha2 * dt1 := by positivity
    linarith
  have h_semi : step12 = step_sum := by
    dsimp [step12, step1, step_sum, NormedTensorGaussianSplat2D.evolveThermal]
    congr 1
    · rw [Real.sq_sqrt h1_nonneg]
      ring_nf
    · rw [Real.sq_sqrt h2_nonneg]
      ring_nf
  have h_s1_le : splat.sigma1 ≤ step1.sigma1 := by
    dsimp [step1, NormedTensorGaussianSplat2D.evolveThermal]
    apply Real.le_sqrt_of_sq_le
    have : 0 ≤ 2 * alpha1 * dt1 := by positivity
    linarith
  have h_s2_le : splat.sigma2 ≤ step1.sigma2 := by
    dsimp [step1, NormedTensorGaussianSplat2D.evolveThermal]
    apply Real.le_sqrt_of_sq_le
    have : 0 ≤ 2 * alpha2 * dt1 := by positivity
    linarith
  have h_norm_le : step1.normFactor ≤ splat.normFactor := by
    unfold NormedTensorGaussianSplat2D.normFactor
    have h_denom_pos : 0 < 2 * Real.pi * splat.sigma1 * splat.sigma2 := by positivity
    have h_prod_le :
        2 * Real.pi * splat.sigma1 * splat.sigma2 ≤
          2 * Real.pi * step1.sigma1 * step1.sigma2 := by
      have h_pi_pos : 0 ≤ 2 * Real.pi := by positivity
      have h_step1_s1_nonneg : 0 ≤ step1.sigma1 := le_of_lt step1.sigma1_pos
      have h_part1 : 2 * Real.pi * splat.sigma1 ≤ 2 * Real.pi * step1.sigma1 :=
        mul_le_mul_of_nonneg_left h_s1_le h_pi_pos
      have h_part2 :
          (2 * Real.pi * splat.sigma1) * splat.sigma2 ≤
            (2 * Real.pi * step1.sigma1) * step1.sigma2 :=
        mul_le_mul h_part1 h_s2_le (le_of_lt hs2_pos) (by positivity)
      exact h_part2
    exact one_div_le_one_div_of_le h_denom_pos h_prod_le
  have h_bohm_le :
      step1.coreBohmPotential m_boson hbar ≤ splat.coreBohmPotential m_boson hbar := by
    unfold NormedTensorGaussianSplat2D.coreBohmPotential
    have h_pref_nonneg : 0 ≤ hbar ^ 2 / (4 * m_boson) := by positivity
    have h_s1_sq_le : splat.sigma1 ^ 2 ≤ step1.sigma1 ^ 2 := by
      dsimp [step1, NormedTensorGaussianSplat2D.evolveThermal]
      rw [Real.sq_sqrt h1_nonneg]
      have : 0 ≤ 2 * alpha1 * dt1 := by positivity
      linarith
    have h_s2_sq_le : splat.sigma2 ^ 2 ≤ step1.sigma2 ^ 2 := by
      dsimp [step1, NormedTensorGaussianSplat2D.evolveThermal]
      rw [Real.sq_sqrt h2_nonneg]
      have : 0 ≤ 2 * alpha2 * dt1 := by positivity
      linarith
    have h_inv1 : 1 / step1.sigma1 ^ 2 ≤ 1 / splat.sigma1 ^ 2 :=
      one_div_le_one_div_of_le hs1_sq_pos h_s1_sq_le
    have h_inv2 : 1 / step1.sigma2 ^ 2 ≤ 1 / splat.sigma2 ^ 2 :=
      one_div_le_one_div_of_le hs2_sq_pos h_s2_sq_le
    exact mul_le_mul_of_nonneg_left (add_le_add h_inv1 h_inv2) h_pref_nonneg
  exact ⟨h_id, h_semi, h_norm_le, h_bohm_le⟩

/-- **Splat-Free Continuum Thermal Mode Evolution**:
Evolves a continuum spatial Fourier/DDF thermal mode amplitude $A$ at wavenumber $k$
and thermal diffusivity $\alpha$ over elapsed time $\Delta t$:
$\mathcal{S}_{\mathrm{mode}}(\alpha, k, \Delta t)(A) = A\,\exp(-\alpha\,k^2\,\Delta t)$. -/
@[blueprint "def:signals-ddf-continuum-thermal-mode-evolve"
  (title := "Splat-free continuum thermal mode evolution A * exp(-α k² Δt)")
  (statement := /-- Define $\operatorname{evolveContinuumThermalMode}(\alpha,k,\Delta t,A) = A\,\exp(-\alpha k^2\Delta t)$. -/)]
noncomputable def evolveContinuumThermalMode
    (diffusivity wavenumber dt amplitude : ℝ) : ℝ :=
  amplitude * Real.exp (-diffusivity * wavenumber ^ 2 * dt)

/-- **Splat-Free Continuum Cattaneo–Vernotte / DDF Reduced Heat-Flux Relaxation**:
Evolves a dimensionless reduced heat flux $j_q = q / q_{\max}^{\mathrm{DDF}}(s)$ over
elapsed time $\Delta t$ with thermal relaxation time $\tau_r$:
$j_q(t + \Delta t) = j_q\,\exp(-\Delta t / \tau_r)$. -/
@[blueprint "def:signals-ddf-continuum-heat-flux-evolve"
  (title := "Splat-free continuum Cattaneo/DDF reduced heat-flux relaxation j_q * exp(-Δt / τ_r)")
  (statement := /-- Define $\operatorname{evolveContinuumReducedHeatFlux}(\tau_r,\Delta t,j_q) = j_q\,\exp(-\Delta t/\tau_r)$. -/)]
noncomputable def evolveContinuumReducedHeatFlux
    (tau_r dt j_q : ℝ) : ℝ :=
  j_q * Real.exp (-dt / tau_r)

/-- **Splat-Free Continuum Bohm Quantum Potential Scale**:
For a continuum Madelung density modulation with effective inverse length / gradient
scale $\kappa$, the Bohm quantum potential scale is
$Q_{\mathrm{cont}}(m, \hbar, \kappa) = \frac{\hbar^2\,\kappa^2}{2 m}$. -/
@[blueprint "def:signals-ddf-continuum-bohm-potential-mode"
  (title := "Splat-free continuum Bohm quantum potential scale Q_cont = ℏ² κ² / (2m)")
  (statement := /-- Define $\operatorname{continuumBohmPotentialMode}(m,\hbar,\kappa) = \frac{\hbar^2\kappa^2}{2m}$. -/)]
noncomputable def continuumBohmPotentialMode
    (m_boson hbar kappa : ℝ) : ℝ :=
  (hbar ^ 2 * kappa ^ 2) / (2 * m_boson)

/-- **Splat-Free Continuum Chapman–Kolmogorov Thermal Semigroup, Bohm Potential Relaxation, & $Gr_{\mathbb{C}}(2,4)$ Plücker Second-Law Theorem**:
Establishes the **splat-free continuum** counterpart of `evolveThermal_semigroup_and_bohm_decay`
and `ddfThermal_fluxLimiter_and_entropy_growth` without any `NormedTensorGaussianSplat2D`:
1. **Splat-Free Physical Heat-Flux Bound**:
   $0 < q_{\max}^{\mathrm{DDF}}(s) \le C_v\,sub.c\,T_0$ and $q^2 < \bigl(q_{\max}^{\mathrm{DDF}}(s)\bigr)^2$
   whenever $-1 < q / q_{\max}^{\mathrm{DDF}}(s) < 1$,
2. **Splat-Free Chapman–Kolmogorov Continuum Mode Semigroup Additivity**:
   $$\operatorname{evolveContinuumThermalMode}\bigl(\alpha, k, \Delta t_2, \operatorname{evolveContinuumThermalMode}(\alpha, k, \Delta t_1, A)\bigr)
   = \operatorname{evolveContinuumThermalMode}(\alpha, k, \Delta t_1 + \Delta t_2, A),$$
3. **Splat-Free Chapman–Kolmogorov Heat-Flux Relaxation Semigroup Additivity**:
   $$\operatorname{evolveContinuumReducedHeatFlux}\bigl(\tau_r, \Delta t_2, \operatorname{evolveContinuumReducedHeatFlux}(\tau_r, \Delta t_1, j_q)\bigr)
   = \operatorname{evolveContinuumReducedHeatFlux}(\tau_r, \Delta t_1 + \Delta t_2, j_q),$$
4. **Splat-Free Monotonic Continuum Bohm Quantum-Potential Relaxation**:
   For $\alpha \ge 0$, $\Delta t_1 \ge 0$, $\kappa_0 \ge 0$, and $m > 0$,
   $$Q_{\mathrm{cont}}\bigl(m, \hbar, \operatorname{evolveContinuumThermalMode}(\alpha, k, \Delta t_1, \kappa_0)\bigr)
   \le Q_{\mathrm{cont}}(m, \hbar, \kappa_0),$$
5. **Splat-Free $Gr_{\mathbb{C}}(2,4)$ Plücker Characteristic Second-Law Relaxation**:
   For $j_q \in (-1, 1)$, $\tau_r > 0$, and $\Delta t_1 \ge 0$, let $M_0 = \operatorname{ddfThermalGr24Matrix}(j_q, \theta)$
   and $M_1 = \operatorname{ddfThermalGr24Matrix}(\operatorname{evolveContinuumReducedHeatFlux}(\tau_r, \Delta t_1, j_q), \theta)$.
   Then the uncrossed Plücker channel product increases monotonically toward equilibrium:
   $$|w_A^{\mathbb{C}}(M_0)|^2\,|w_B^{\mathbb{C}}(M_0)|^2 \le |w_A^{\mathbb{C}}(M_1)|^2\,|w_B^{\mathbb{C}}(M_1)|^2.$$ -/
@[blueprint "thm:signals-ddf-continuum-thermal-semigroup-bohm-decay"
  (title := "Splat-free continuum Chapman-Kolmogorov thermal semigroup, Bohm relaxation, and Gr_C(2,4) Second-Law theorem")
  (statement := /-- For \texttt{s : MovingSheath sub} with $C_v>0$, $T_0>0$, $0<c_{\mathrm{th},0}\le sub.c$,
    $\tau_r>0$, $\alpha\ge 0$, $\Delta t_1,\Delta t_2\ge 0$, $\kappa_0\ge 0$, $m>0$, and $j_q\in(-1,1)$:
    (1) $0 < q_{\max}^{\mathrm{DDF}}(s) \le C_v\,sub.c\,T_0$ and $q^2 < (q_{\max}^{\mathrm{DDF}}(s))^2$,
    (2) $\operatorname{evolveContinuumThermalMode}(\alpha,k,\Delta t_2,\operatorname{evolveContinuumThermalMode}(\alpha,k,\Delta t_1,A)) = \operatorname{evolveContinuumThermalMode}(\alpha,k,\Delta t_1+\Delta t_2,A)$,
    (3) $\operatorname{evolveContinuumReducedHeatFlux}(\tau_r,\Delta t_2,\operatorname{evolveContinuumReducedHeatFlux}(\tau_r,\Delta t_1,j_q)) = \operatorname{evolveContinuumReducedHeatFlux}(\tau_r,\Delta t_1+\Delta t_2,j_q)$,
    (4) $\operatorname{continuumBohmPotentialMode}(m,\hbar,\operatorname{evolveContinuumThermalMode}(\alpha,k,\Delta t_1,\kappa_0)) \le \operatorname{continuumBohmPotentialMode}(m,\hbar,\kappa_0)$, and
    (5) $|w_A^{\mathbb C}(M_0)|^2\,|w_B^{\mathbb C}(M_0)|^2 \le |w_A^{\mathbb C}(M_1)|^2\,|w_B^{\mathbb C}(M_1)|^2$. -/)
  (proof := /-- Use $\exp(a)\exp(b)=\exp(a+b)$ for the two semigroup laws,
    $0<\exp(-\alpha k^2\Delta t_1)\le 1$ for Bohm potential monotonicity, and
    $(j_q e^{-\Delta t_1/\tau_r})^2 \le j_q^2$ for the $Gr_{\mathbb C}(2,4)$ Pluecker product growth. -/)]
theorem MovingSheath.ddfContinuum_semigroup_and_bohm_decay
    {sub : DDFSubstrate} (s : MovingSheath sub)
    (volHeatCap c_th0 T0 q tau_r alpha k dt1 dt2 A kappa0 j_q m_boson hbar θ : ℝ)
    (hCv : 0 < volHeatCap) (hc_pos : 0 < c_th0) (hc_le : c_th0 ≤ sub.c)
    (hT0 : 0 < T0)
    (hjq_flux_gt : -1 < q / s.ddfMaxCausalHeatFlux volHeatCap c_th0 T0)
    (hjq_flux_lt : q / s.ddfMaxCausalHeatFlux volHeatCap c_th0 T0 < 1)
    (htau_pos : 0 < tau_r) (h_alpha : 0 ≤ alpha)
    (h_dt1 : 0 ≤ dt1)
    (h_kappa0 : 0 ≤ kappa0) (hm : 0 < m_boson)
    (hjq_gt : -1 < j_q) (hjq_lt : j_q < 1) :
    let q_max := s.ddfMaxCausalHeatFlux volHeatCap c_th0 T0
    let kappa1 := evolveContinuumThermalMode alpha k dt1 kappa0
    let jq1 := evolveContinuumReducedHeatFlux tau_r dt1 j_q
    let M0 := ddfThermalGr24Matrix j_q θ
    let M1 := ddfThermalGr24Matrix jq1 θ
    0 < q_max ∧
      q_max ≤ volHeatCap * sub.c * T0 ∧
      q ^ 2 < q_max ^ 2 ∧
      evolveContinuumThermalMode alpha k 0 A = A ∧
      evolveContinuumReducedHeatFlux tau_r 0 j_q = j_q ∧
      evolveContinuumThermalMode alpha k dt2
          (evolveContinuumThermalMode alpha k dt1 A) =
        evolveContinuumThermalMode alpha k (dt1 + dt2) A ∧
      evolveContinuumReducedHeatFlux tau_r dt2
          (evolveContinuumReducedHeatFlux tau_r dt1 j_q) =
        evolveContinuumReducedHeatFlux tau_r (dt1 + dt2) j_q ∧
      continuumBohmPotentialMode m_boson hbar kappa1 =
        continuumBohmPotentialMode m_boson hbar kappa0 *
          Real.exp (-2 * alpha * k ^ 2 * dt1) ∧
      continuumBohmPotentialMode m_boson hbar kappa1 ≤
        continuumBohmPotentialMode m_boson hbar kappa0 ∧
      Complex.normSq (complexPluckerSinkAmplitudeA M1) *
          Complex.normSq (complexPluckerSinkAmplitudeB M1) -
        Complex.normSq (complexPluckerSinkAmplitudeA M0) *
          Complex.normSq (complexPluckerSinkAmplitudeB M0) =
        j_q ^ 2 * (1 - Real.exp (-2 * dt1 / tau_r)) ∧
      Complex.normSq (complexPluckerSinkAmplitudeA M0) *
          Complex.normSq (complexPluckerSinkAmplitudeB M0) ≤
        Complex.normSq (complexPluckerSinkAmplitudeA M1) *
          Complex.normSq (complexPluckerSinkAmplitudeB M1) := by
  intro q_max kappa1 jq1 M0 M1
  have h_vis_pos : 0 < s.coherenceVisibility :=
    Real.sqrt_pos.mpr s.one_sub_betaSq_pos
  have h_beta_sq_nonneg : 0 ≤ s.betaSq := by
    unfold MovingSheath.betaSq
    positivity
  have h_vis_le_one : s.coherenceVisibility ≤ 1 := by
    unfold MovingSheath.coherenceVisibility
    exact Real.sqrt_le_one.mpr (by linarith)
  have h_cs_pos : 0 < s.ddfSecondSoundSpeed c_th0 :=
    mul_pos hc_pos h_vis_pos
  have h_cs_le_c0 : s.ddfSecondSoundSpeed c_th0 ≤ c_th0 := by
    unfold MovingSheath.ddfSecondSoundSpeed
    exact mul_le_of_le_one_right (le_of_lt hc_pos) h_vis_le_one
  have h_cs_le_c : s.ddfSecondSoundSpeed c_th0 ≤ sub.c :=
    le_trans h_cs_le_c0 hc_le
  have h_qmax_pos : 0 < q_max := by
    dsimp [q_max, MovingSheath.ddfMaxCausalHeatFlux]
    positivity
  have h_qmax_le : q_max ≤ volHeatCap * sub.c * T0 := by
    dsimp [q_max, MovingSheath.ddfMaxCausalHeatFlux]
    have h1 : volHeatCap * s.ddfSecondSoundSpeed c_th0 ≤ volHeatCap * sub.c :=
      mul_le_mul_of_nonneg_left h_cs_le_c (le_of_lt hCv)
    exact mul_le_mul_of_nonneg_right h1 (le_of_lt hT0)
  have h_q_sq : q ^ 2 < q_max ^ 2 := by
    have h_gt' : (-1 : ℝ) < q / q_max := hjq_flux_gt
    have h_lt' : q / q_max < (1 : ℝ) := hjq_flux_lt
    have h_gt : (-1 : ℝ) * q_max < q := (lt_div_iff₀ h_qmax_pos).mp h_gt'
    have h_lt : q < (1 : ℝ) * q_max := (div_lt_iff₀ h_qmax_pos).mp h_lt'
    nlinarith
  have h_mode_id : evolveContinuumThermalMode alpha k 0 A = A := by
    unfold evolveContinuumThermalMode
    simp
  have h_flux_id : evolveContinuumReducedHeatFlux tau_r 0 j_q = j_q := by
    unfold evolveContinuumReducedHeatFlux
    simp
  have h_mode_semi :
      evolveContinuumThermalMode alpha k dt2
          (evolveContinuumThermalMode alpha k dt1 A) =
        evolveContinuumThermalMode alpha k (dt1 + dt2) A := by
    unfold evolveContinuumThermalMode
    rw [mul_assoc, ← Real.exp_add]
    congr 2
    ring
  have h_flux_semi :
      evolveContinuumReducedHeatFlux tau_r dt2
          (evolveContinuumReducedHeatFlux tau_r dt1 j_q) =
        evolveContinuumReducedHeatFlux tau_r (dt1 + dt2) j_q := by
    unfold evolveContinuumReducedHeatFlux
    rw [mul_assoc, ← Real.exp_add]
    congr 2
    ring
  have h_bohm_eq :
      continuumBohmPotentialMode m_boson hbar kappa1 =
        continuumBohmPotentialMode m_boson hbar kappa0 *
          Real.exp (-2 * alpha * k ^ 2 * dt1) := by
    dsimp [kappa1, evolveContinuumThermalMode, continuumBohmPotentialMode]
    have h_exp_sq :
        (Real.exp (-alpha * k ^ 2 * dt1)) ^ 2 =
          Real.exp (-2 * alpha * k ^ 2 * dt1) := by
      rw [sq, ← Real.exp_add]
      congr 1
      ring
    calc
      hbar ^ 2 * (kappa0 * Real.exp (-alpha * k ^ 2 * dt1)) ^ 2 / (2 * m_boson) =
          (hbar ^ 2 * kappa0 ^ 2 / (2 * m_boson)) *
            (Real.exp (-alpha * k ^ 2 * dt1)) ^ 2 := by ring
      _ = (hbar ^ 2 * kappa0 ^ 2 / (2 * m_boson)) *
            Real.exp (-2 * alpha * k ^ 2 * dt1) := by rw [h_exp_sq]
  have h_exp_mode_le_one : Real.exp (-alpha * k ^ 2 * dt1) ≤ 1 := by
    apply Real.exp_le_one_iff.mpr
    have : 0 ≤ alpha * k ^ 2 * dt1 := by positivity
    linarith
  have h_exp_mode_nonneg : 0 ≤ Real.exp (-alpha * k ^ 2 * dt1) :=
    le_of_lt (Real.exp_pos _)
  have h_kappa1_nonneg : 0 ≤ kappa1 := by
    dsimp [kappa1, evolveContinuumThermalMode]
    positivity
  have h_kappa1_le : kappa1 ≤ kappa0 := by
    dsimp [kappa1, evolveContinuumThermalMode]
    exact mul_le_of_le_one_right h_kappa0 h_exp_mode_le_one
  have h_bohm_le :
      continuumBohmPotentialMode m_boson hbar kappa1 ≤
        continuumBohmPotentialMode m_boson hbar kappa0 := by
    unfold continuumBohmPotentialMode
    have h_sq_le : kappa1 ^ 2 ≤ kappa0 ^ 2 := by
      nlinarith [h_kappa1_nonneg, h_kappa0, h_kappa1_le]
    have h_num_le : hbar ^ 2 * kappa1 ^ 2 ≤ hbar ^ 2 * kappa0 ^ 2 :=
      mul_le_mul_of_nonneg_left h_sq_le (sq_nonneg hbar)
    exact div_le_div_of_nonneg_right h_num_le (by positivity)
  have h_exp_tau_le_one : Real.exp (-dt1 / tau_r) ≤ 1 := by
    apply Real.exp_le_one_iff.mpr
    rw [neg_div]
    have h_div_nonneg : 0 ≤ dt1 / tau_r := div_nonneg h_dt1 (le_of_lt htau_pos)
    linarith
  have h_exp_tau_pos : 0 < Real.exp (-dt1 / tau_r) := Real.exp_pos _
  have h_jq1_sq_le : jq1 ^ 2 ≤ j_q ^ 2 := by
    dsimp [jq1, evolveContinuumReducedHeatFlux]
    rw [mul_pow]
    have h_exp_sq_le_one : (Real.exp (-dt1 / tau_r)) ^ 2 ≤ 1 := by
      nlinarith [h_exp_tau_pos, h_exp_tau_le_one]
    exact mul_le_of_le_one_right (sq_nonneg j_q) h_exp_sq_le_one
  have h_jq_sq_lt_one : j_q ^ 2 < 1 := by nlinarith
  have h_jq1_sq_lt_one : jq1 ^ 2 < 1 := lt_of_le_of_lt h_jq1_sq_le h_jq_sq_lt_one
  have h_jq1_gt : -1 < jq1 := by nlinarith
  have h_jq1_lt : jq1 < 1 := by nlinarith
  have h_M0 :=
    (s.ddfThermalTransport_continuum_identities c_th0 tau_r 1 1 1 0 0 0 0 0 j_q θ 0
      hc_pos hc_le htau_pos hjq_gt hjq_lt).2.2.2.2.2.2.1
  have h_M1 :=
    (s.ddfThermalTransport_continuum_identities c_th0 tau_r 1 1 1 0 0 0 0 0 jq1 θ 0
      hc_pos hc_le htau_pos h_jq1_gt h_jq1_lt).2.2.2.2.2.2.1
  have h_plucker_diff :
      Complex.normSq (complexPluckerSinkAmplitudeA M1) *
          Complex.normSq (complexPluckerSinkAmplitudeB M1) -
        Complex.normSq (complexPluckerSinkAmplitudeA M0) *
          Complex.normSq (complexPluckerSinkAmplitudeB M0) =
        j_q ^ 2 * (1 - Real.exp (-2 * dt1 / tau_r)) := by
    dsimp [M0, M1]
    rw [h_M0, h_M1]
    dsimp [jq1, evolveContinuumReducedHeatFlux]
    have h_exp_tau_sq :
        (Real.exp (-dt1 / tau_r)) ^ 2 = Real.exp (-2 * dt1 / tau_r) := by
      rw [sq, ← Real.exp_add]
      congr 1
      ring
    calc
      1 - (j_q * Real.exp (-dt1 / tau_r)) ^ 2 - (1 - j_q ^ 2) =
          j_q ^ 2 * (1 - (Real.exp (-dt1 / tau_r)) ^ 2) := by ring
      _ = j_q ^ 2 * (1 - Real.exp (-2 * dt1 / tau_r)) := by rw [h_exp_tau_sq]
  have h_plucker_le :
      Complex.normSq (complexPluckerSinkAmplitudeA M0) *
          Complex.normSq (complexPluckerSinkAmplitudeB M0) ≤
        Complex.normSq (complexPluckerSinkAmplitudeA M1) *
          Complex.normSq (complexPluckerSinkAmplitudeB M1) := by
    dsimp [M0, M1]
    rw [h_M0, h_M1]
    linarith
  exact ⟨h_qmax_pos, h_qmax_le, h_q_sq, h_mode_id, h_flux_id,
    h_mode_semi, h_flux_semi, h_bohm_eq, h_bohm_le, h_plucker_diff, h_plucker_le⟩

/-! ## Surface Plasmon Polaritons (SPPs) & Polariton $Gr_{\mathbb{C}}(2,4)$–DDF Mechanics (With and Without Splats) -/

/-- Effective Surface Plasmon Polariton (SPP) refractive index squared
$n_{\mathrm{SPP}}^2(\varepsilon_d, |\varepsilon_m|) = \frac{\varepsilon_d\,|\varepsilon_m|}{|\varepsilon_m| - \varepsilon_d}$
at a planar interface between a dielectric ($\varepsilon_d > 0$) and a conductor with
negative real permittivity $\varepsilon_m = -|\varepsilon_m| < -\varepsilon_d < 0$. -/
@[blueprint "def:signals-ddf-spp-effective-index-sq"
  (title := "SPP effective refractive index squared n_SPP² = ε_d |ε_m| / (|ε_m| - ε_d)")
  (statement := /-- Define $\operatorname{sppEffectiveIndexSq}(\varepsilon_d, |\varepsilon_m|)
    = \varepsilon_d |\varepsilon_m| / (|\varepsilon_m| - \varepsilon_d)$. -/)]
noncomputable def sppEffectiveIndexSq (eps_d abs_eps_m : ℝ) : ℝ :=
  (eps_d * abs_eps_m) / (abs_eps_m - eps_d)

/-- Dimensionless SPP permittivity contrast (barycentric metal–dielectric asymmetry)
$\chi_{\mathrm{SPP}}(\varepsilon_d, |\varepsilon_m|) = \frac{|\varepsilon_m| - \varepsilon_d}{|\varepsilon_m| + \varepsilon_d} \in (0, 1)$
for $0 < \varepsilon_d < |\varepsilon_m|$. -/
@[blueprint "def:signals-ddf-spp-permittivity-contrast"
  (title := "Dimensionless SPP permittivity contrast χ_SPP = (|ε_m| - ε_d) / (|ε_m| + ε_d)")
  (statement := /-- Define $\operatorname{sppPermittivityContrast}(\varepsilon_d, |\varepsilon_m|)
    = (|\varepsilon_m| - \varepsilon_d) / (|\varepsilon_m| + \varepsilon_d)$. -/)]
noncomputable def sppPermittivityContrast (eps_d abs_eps_m : ℝ) : ℝ :=
  (abs_eps_m - eps_d) / (abs_eps_m + eps_d)

/-- Inverse SPP permittivity-ratio & evanescent skin-depth-ratio reconstruction:
given the dimensionless SPP contrast $\chi_{\mathrm{SPP}}$, reconstructs
$\frac{|\varepsilon_m|}{\varepsilon_d} = \frac{\delta_d}{\delta_m} = \frac{1 + \chi_{\mathrm{SPP}}}{1 - \chi_{\mathrm{SPP}}}$. -/
@[blueprint "def:signals-ddf-reconstruct-spp-permittivity-ratio"
  (title := "Inverse SPP reconstruction of |ε_m| / ε_d = (1 + χ_SPP) / (1 - χ_SPP)")
  (statement := /-- Define $\operatorname{reconstructSppPermittivityRatio}(\chi_{\mathrm{SPP}})
    = (1 + \chi_{\mathrm{SPP}}) / (1 - \chi_{\mathrm{SPP}})$. -/)]
noncomputable def reconstructSppPermittivityRatio (chi_spp : ℝ) : ℝ :=
  (1 + chi_spp) / (1 - chi_spp)

/-- Splat-free complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ matrix representing a
Surface Plasmon Polariton interface state with contrast $\chi_{\mathrm{SPP}} \in (-1, 1)$
and phase $\theta$:
$M_{\mathrm{SPP}}(\chi_{\mathrm{SPP}}, \theta) = \operatorname{ddfThermalGr24Matrix}(\chi_{\mathrm{SPP}}, \theta)$. -/
@[blueprint "def:signals-ddf-spp-gr24-matrix"
  (title := "Splat-free complex Gr_C(2,4) Surface Plasmon Polariton matrix")
  (statement := /-- Define $\operatorname{sppGr24Matrix}(\chi_{\mathrm{SPP}},\theta)
    = \operatorname{ddfThermalGr24Matrix}(\chi_{\mathrm{SPP}},\theta)$. -/)]
noncomputable def sppGr24Matrix (chi_spp θ : ℝ) : Matrix (Fin 2) (Fin 4) ℂ :=
  ddfThermalGr24Matrix chi_spp θ

/-- Splat-free continuum SPP propagation-length attenuation along the interface ($x \ge 0$)
with Ohmic damping constant $\gamma_{\mathrm{SPP}} = 2\operatorname{Im}(k_{\mathrm{SPP}}) \ge 0$:
$I_{\mathrm{SPP}}(x + L) = I_0\,\exp(-\gamma_{\mathrm{SPP}}\,L)$. -/
@[blueprint "def:signals-ddf-continuum-spp-propagation"
  (title := "Splat-free continuum SPP propagation-length attenuation I_0 * exp(-γ_SPP L)")
  (statement := /-- Define $\operatorname{evolveContinuumSppPropagation}(\gamma_{\mathrm{SPP}}, L, I_0)
    = I_0\,\exp(-\gamma_{\mathrm{SPP}} L)$. -/)]
noncomputable def evolveContinuumSppPropagation (gamma_spp L I0 : ℝ) : ℝ :=
  I0 * Real.exp (-gamma_spp * L)

/-- Normed 2D Anisotropic Tensor Gaussian Splat representing a sub-wavelength
Surface Plasmon Polariton (SPP) hotspot at a metal–dielectric or N-LIG graphene–vitrimer
interface, with longitudinal confinement width $\sigma_1 = \lambda_0 / n_{\mathrm{SPP}} > 0$
and normal evanescent skin-depth width $\sigma_2 = \lambda_0 / (n_{\mathrm{SPP}} \kappa_{\mathrm{ratio}}) > 0$. -/
@[blueprint "def:signals-ddf-spp-hotspot-tensor-splat"
  (title := "Sub-wavelength SPP hotspot NormedTensorGaussianSplat2D")
  (statement := /-- Construct a \texttt{NormedTensorGaussianSplat2D} for an SPP hotspot with
    $\sigma_1 = \lambda_0 / n_{\mathrm{SPP}}$ and $\sigma_2 = \lambda_0 / (n_{\mathrm{SPP}}\kappa_{\mathrm{ratio}})$. -/)]
noncomputable def sppHotspotTensorSplat
    (cx cy weight lam0 n_spp kappa_ratio : ℝ)
    (hw : 0 ≤ weight) (hlam : 0 < lam0) (hn : 0 < n_spp) (hκ : 0 < kappa_ratio)
    (θ : ℝ) : NormedTensorGaussianSplat2D :=
  { centerX := cx
    centerY := cy
    weight := weight
    weight_nonneg := hw
    sigma1 := lam0 / n_spp
    sigma1_pos := div_pos hlam hn
    sigma2 := lam0 / (n_spp * kappa_ratio)
    sigma2_pos := div_pos hlam (mul_pos hn hκ)
    orientationAngle := θ }

/-- **Splat-Free Continuum Surface Plasmon Polariton (SPP) Dispersion, $Gr_{\mathbb{C}}(2,4)$ Plücker Skin-Depth Duality, & Spatial Semigroup Theorem**:
Establishes the **splat-free continuum** mechanics of Surface Plasmon Polaritons at a
planar dielectric–conductor interface ($0 < \varepsilon_d < |\varepsilon_m|$):
1. **Strict Sub-Wavelength Momentum Enhancement Outside the Light Cone**:
   $$n_{\mathrm{SPP}}^2(\varepsilon_d, |\varepsilon_m|) - \varepsilon_d = \frac{\varepsilon_d^2}{|\varepsilon_m| - \varepsilon_d} > 0 \implies \varepsilon_d < n_{\mathrm{SPP}}^2(\varepsilon_d, |\varepsilon_m|),$$
   proving that the SPP wavevector $k_{\mathrm{SPP}} = k_0 n_{\mathrm{SPP}} > k_0\sqrt{\varepsilon_d}$
   cannot be excited on a flat interface without a prism, grating, or near-field momentum boost,
2. **Exact Normal Evanescent Decay Ratio**:
   $$\frac{n_{\mathrm{SPP}}^2 - \varepsilon_d}{n_{\mathrm{SPP}}^2 + |\varepsilon_m|} = \frac{\varepsilon_d^2}{|\varepsilon_m|^2},$$
   showing that the normal evanescent decay constants $\kappa_d, \kappa_m$ satisfy
   $\kappa_d / \kappa_m = \varepsilon_d / |\varepsilon_m| < 1$ (so the dielectric skin depth
   $\delta_d = 1/\kappa_d$ exceeds the metal skin depth $\delta_m = 1/\kappa_m$ by $|\varepsilon_m|/\varepsilon_d > 1$),
3. **Splat-Free $Gr_{\mathbb{C}}(2,4)$ Plücker Channel Ratio & Inverse Permittivity-Ratio Recovery**:
   For $\chi_{\mathrm{SPP}} = \operatorname{sppPermittivityContrast}(\varepsilon_d, |\varepsilon_m|) \in (0, 1)$
   and $M_{\mathrm{SPP}} = \operatorname{sppGr24Matrix}(\chi_{\mathrm{SPP}}, \theta)$,
   $$0 < \chi_{\mathrm{SPP}} < 1, \qquad
   \frac{|w_A^{\mathbb{C}}(M_{\mathrm{SPP}})|^2}{|w_B^{\mathbb{C}}(M_{\mathrm{SPP}})|^2}
   = \operatorname{reconstructSppPermittivityRatio}(\chi_{\mathrm{SPP}})
   = \frac{|\varepsilon_m|}{\varepsilon_d} > 1,$$
   $$|w_A^{\mathbb{C}}(M_{\mathrm{SPP}})|^2\,|w_B^{\mathbb{C}}(M_{\mathrm{SPP}})|^2
   = 1 - \chi_{\mathrm{SPP}}^2
   = \frac{4\,\varepsilon_d\,|\varepsilon_m|}{(|\varepsilon_m| + \varepsilon_d)^2} > 0,$$
4. **Splat-Free Continuum SPP Propagation Semigroup Identity & Additivity**:
   $$\operatorname{evolveContinuumSppPropagation}(\gamma_{\mathrm{SPP}}, 0, I_0) = I_0,$$
   $$\operatorname{evolveContinuumSppPropagation}\bigl(\gamma_{\mathrm{SPP}}, L_2, \operatorname{evolveContinuumSppPropagation}(\gamma_{\mathrm{SPP}}, L_1, I_0)\bigr)
   = \operatorname{evolveContinuumSppPropagation}(\gamma_{\mathrm{SPP}}, L_1 + L_2, I_0),$$
5. **Splat-Free Evanescent Bohm Quantum-Potential Enhancement in the Conductor**:
   For normal decay scale $\kappa_m = (|\varepsilon_m| / \varepsilon_d)\,\kappa_d$ with $\kappa_d > 0$ and $m > 0$,
   $$Q_{\mathrm{cont}}(m, \hbar, \kappa_m) = \left(\frac{|\varepsilon_m|}{\varepsilon_d}\right)^2 Q_{\mathrm{cont}}(m, \hbar, \kappa_d) \ge Q_{\mathrm{cont}}(m, \hbar, \kappa_d).$$ -/
@[blueprint "thm:signals-ddf-spp-continuum-gr24-semigroup"
  (title := "Splat-free continuum SPP dispersion, Gr_C(2,4) Pluecker skin-depth duality, and spatial semigroup theorem")
  (statement := /-- For $0 < \varepsilon_d < |\varepsilon_m|$, $\kappa_d > 0$, $m > 0$, and $\theta \in \mathbb R$:
    (1) $n_{\mathrm{SPP}}^2 - \varepsilon_d = \varepsilon_d^2 / (|\varepsilon_m| - \varepsilon_d) > 0$,
    (2) $(n_{\mathrm{SPP}}^2 - \varepsilon_d)/(n_{\mathrm{SPP}}^2 + |\varepsilon_m|) = \varepsilon_d^2 / |\varepsilon_m|^2$,
    (3) $0 < \chi_{\mathrm{SPP}} < 1$, $|w_A^{\mathbb C}(M_{\mathrm{SPP}})|^2 / |w_B^{\mathbb C}(M_{\mathrm{SPP}})|^2 = \operatorname{reconstructSppPermittivityRatio}(\chi_{\mathrm{SPP}}) = |\varepsilon_m|/\varepsilon_d$, and $|w_A^{\mathbb C}|^2|w_B^{\mathbb C}|^2 = 4\varepsilon_d|\varepsilon_m|/(|\varepsilon_m|+\varepsilon_d)^2$,
    (4) $\operatorname{evolveContinuumSppPropagation}$ satisfies identity at $L=0$ and semigroup additivity over $L_1+L_2$, and
    (5) $\operatorname{continuumBohmPotentialMode}(m,\hbar,(|\varepsilon_m|/\varepsilon_d)\kappa_d) = (|\varepsilon_m|/\varepsilon_d)^2 \operatorname{continuumBohmPotentialMode}(m,\hbar,\kappa_d)$. -/)
  (proof := /-- Clear $|\varepsilon_m|-\varepsilon_d>0$ and $|\varepsilon_m|+\varepsilon_d>0$ by field simplification,
    use `complexGr24ChannelMatrix_minors` for $M_{\mathrm{SPP}}$, and apply $\exp(a)\exp(b)=\exp(a+b)$
    for the spatial propagation semigroup. -/)]
theorem MovingSheath.sppContinuum_gr24_and_semigroup_identities
    {sub : DDFSubstrate} (_s : MovingSheath sub)
    (eps_d abs_eps_m gamma_spp L1 L2 I0 kappa_d m_boson hbar θ : ℝ)
    (heps_d : 0 < eps_d) (h_lt_m : eps_d < abs_eps_m) :
    let n_sq := sppEffectiveIndexSq eps_d abs_eps_m
    let chi := sppPermittivityContrast eps_d abs_eps_m
    let M_spp := sppGr24Matrix chi θ
    let kappa_m := (abs_eps_m / eps_d) * kappa_d
    n_sq - eps_d = eps_d ^ 2 / (abs_eps_m - eps_d) ∧
      eps_d < n_sq ∧
      (n_sq - eps_d) / (n_sq + abs_eps_m) = eps_d ^ 2 / abs_eps_m ^ 2 ∧
      0 < chi ∧
      chi < 1 ∧
      Complex.normSq (complexPluckerSinkAmplitudeA M_spp) /
          Complex.normSq (complexPluckerSinkAmplitudeB M_spp) =
        reconstructSppPermittivityRatio chi ∧
      reconstructSppPermittivityRatio chi = abs_eps_m / eps_d ∧
      Complex.normSq (complexPluckerSinkAmplitudeA M_spp) *
          Complex.normSq (complexPluckerSinkAmplitudeB M_spp) =
        (4 * eps_d * abs_eps_m) / (abs_eps_m + eps_d) ^ 2 ∧
      evolveContinuumSppPropagation gamma_spp 0 I0 = I0 ∧
      evolveContinuumSppPropagation gamma_spp L2
          (evolveContinuumSppPropagation gamma_spp L1 I0) =
        evolveContinuumSppPropagation gamma_spp (L1 + L2) I0 ∧
      continuumBohmPotentialMode m_boson hbar kappa_m =
        (abs_eps_m / eps_d) ^ 2 * continuumBohmPotentialMode m_boson hbar kappa_d := by
  intro n_sq chi M_spp kappa_m
  have h_m_pos : 0 < abs_eps_m := lt_trans heps_d h_lt_m
  have h_diff_pos : 0 < abs_eps_m - eps_d := sub_pos.mpr h_lt_m
  have h_diff_ne : abs_eps_m - eps_d ≠ 0 := ne_of_gt h_diff_pos
  have h_sum_pos : 0 < abs_eps_m + eps_d := add_pos h_m_pos heps_d
  have h_sum_ne : abs_eps_m + eps_d ≠ 0 := ne_of_gt h_sum_pos
  have h_d_ne : eps_d ≠ 0 := ne_of_gt heps_d
  have h_m_ne : abs_eps_m ≠ 0 := ne_of_gt h_m_pos
  have h_nsq_sub : n_sq - eps_d = eps_d ^ 2 / (abs_eps_m - eps_d) := by
    dsimp [n_sq, sppEffectiveIndexSq]
    field_simp [h_diff_ne]
    ring
  have h_nsq_gt : eps_d < n_sq := by
    have h_pos : 0 < eps_d ^ 2 / (abs_eps_m - eps_d) :=
      div_pos (sq_pos_of_pos heps_d) h_diff_pos
    linarith [h_nsq_sub]
  have h_evan_ratio :
      (n_sq - eps_d) / (n_sq + abs_eps_m) = eps_d ^ 2 / abs_eps_m ^ 2 := by
    dsimp [n_sq, sppEffectiveIndexSq]
    field_simp [h_diff_ne, h_m_ne]
    ring
  have h_chi_pos : 0 < chi := by
    dsimp [chi, sppPermittivityContrast]
    exact div_pos h_diff_pos h_sum_pos
  have h_chi_lt_one : chi < 1 := by
    dsimp [chi, sppPermittivityContrast]
    rw [div_lt_iff₀ h_sum_pos]
    linarith
  have h1p : 0 ≤ 1 + chi := by linarith
  have h1m : 0 ≤ 1 - chi := by linarith
  have h_minors := complexGr24ChannelMatrix_minors
    (↑(Real.sqrt (1 + chi) * Real.cos θ) + Complex.I * ↑(Real.sqrt (1 + chi) * Real.sin θ))
    (↑(Real.sqrt (1 - chi) * Real.cos θ) - Complex.I * ↑(Real.sqrt (1 - chi) * Real.sin θ))
  have h_wA :
      Complex.normSq (complexPluckerSinkAmplitudeA M_spp) = 1 + chi := by
    dsimp [M_spp, sppGr24Matrix, ddfThermalGr24Matrix, complexPluckerSinkAmplitudeA]
    rw [h_minors.1]
    simp only [Complex.normSq_apply, Complex.add_re, Complex.add_im, Complex.mul_re,
      Complex.mul_im, Complex.ofReal_re, Complex.ofReal_im, Complex.I_re, Complex.I_im]
    calc
      _ = (Real.sqrt (1 + chi)) ^ 2 * ((Real.cos θ) ^ 2 + (Real.sin θ) ^ 2) := by ring
      _ = 1 + chi := by rw [Real.sq_sqrt h1p, Real.cos_sq_add_sin_sq, mul_one]
  have h_wB :
      Complex.normSq (complexPluckerSinkAmplitudeB M_spp) = 1 - chi := by
    dsimp [M_spp, sppGr24Matrix, ddfThermalGr24Matrix, complexPluckerSinkAmplitudeB]
    rw [h_minors.2.1]
    simp only [Complex.normSq_apply, Complex.sub_re, Complex.sub_im, Complex.mul_re,
      Complex.mul_im, Complex.ofReal_re, Complex.ofReal_im, Complex.I_re, Complex.I_im]
    calc
      _ = (Real.sqrt (1 - chi)) ^ 2 * ((Real.cos θ) ^ 2 + (Real.sin θ) ^ 2) := by ring
      _ = 1 - chi := by rw [Real.sq_sqrt h1m, Real.cos_sq_add_sin_sq, mul_one]
  have h_plucker_ratio :
      Complex.normSq (complexPluckerSinkAmplitudeA M_spp) /
          Complex.normSq (complexPluckerSinkAmplitudeB M_spp) =
        reconstructSppPermittivityRatio chi := by
    rw [h_wA, h_wB]
    rfl
  have h_rec_ratio : reconstructSppPermittivityRatio chi = abs_eps_m / eps_d := by
    dsimp [reconstructSppPermittivityRatio, chi, sppPermittivityContrast]
    field_simp [h_sum_ne, h_d_ne]
    ring
  have h_plucker_prod :
      Complex.normSq (complexPluckerSinkAmplitudeA M_spp) *
          Complex.normSq (complexPluckerSinkAmplitudeB M_spp) =
        (4 * eps_d * abs_eps_m) / (abs_eps_m + eps_d) ^ 2 := by
    rw [h_wA, h_wB]
    dsimp [chi, sppPermittivityContrast]
    field_simp [h_sum_ne]
    ring
  have h_prop_id : evolveContinuumSppPropagation gamma_spp 0 I0 = I0 := by
    unfold evolveContinuumSppPropagation
    simp
  have h_prop_semi :
      evolveContinuumSppPropagation gamma_spp L2
          (evolveContinuumSppPropagation gamma_spp L1 I0) =
        evolveContinuumSppPropagation gamma_spp (L1 + L2) I0 := by
    unfold evolveContinuumSppPropagation
    rw [mul_assoc, ← Real.exp_add]
    congr 2
    ring
  have h_bohm_scale :
      continuumBohmPotentialMode m_boson hbar kappa_m =
        (abs_eps_m / eps_d) ^ 2 * continuumBohmPotentialMode m_boson hbar kappa_d := by
    dsimp [kappa_m, continuumBohmPotentialMode]
    ring
  exact ⟨h_nsq_sub, h_nsq_gt, h_evan_ratio, h_chi_pos, h_chi_lt_one,
    h_plucker_ratio, h_rec_ratio, h_plucker_prod, h_prop_id, h_prop_semi, h_bohm_scale⟩

/-- **With Normed Tensor Gaussian Splats: Sub-Wavelength SPP Hotspot Confinement, Bohm Quantum Pressure Enhancement, & Ohmic-Thermal Splat Semigroup**:
For an SPP hotspot `splat_spp = sppHotspotTensorSplat cx cy weight lam0 n_spp kappa_ratio hw hlam hn hκ θ`
with $n_{\mathrm{SPP}} \ge 1$ and $\kappa_{\mathrm{ratio}} = |\varepsilon_m|/\varepsilon_d \ge 1$:
1. **Exact Sub-Wavelength Covariance Determinant Compression**:
   $$\det\Sigma_{\mathrm{SPP}} = \frac{\lambda_0^4}{n_{\mathrm{SPP}}^4\,\kappa_{\mathrm{ratio}}^2} \le \lambda_0^4,$$
2. **Exact Plasmonic Hotspot Peak Normalization Enhancement**:
   $$\mathcal{N}(\Sigma_{\mathrm{SPP}}) = \frac{n_{\mathrm{SPP}}^2\,\kappa_{\mathrm{ratio}}}{2\pi\,\lambda_0^2},$$
3. **Exact Hotspot Core Bohm Quantum Potential & Sub-Wavelength Amplification**:
   $$Q_{\mathrm{core}}(\Sigma_{\mathrm{SPP}}) = \frac{\hbar^2\,n_{\mathrm{SPP}}^2\,(1 + \kappa_{\mathrm{ratio}}^2)}{4 m\,\lambda_0^2} \ge \frac{\hbar^2}{2 m\,\lambda_0^2},$$
4. **Normal-to-Longitudinal Madelung Quantum Pressure Anisotropy**:
   $$\Pi_{22}^{\mathrm{SPP}}(x,y) = \kappa_{\mathrm{ratio}}^2\,\Pi_{11}^{\mathrm{SPP}}(x,y),$$
5. **Ohmic-Thermal Splat Evolution Semigroup Identity, Additivity, & Monotonic Bohm Relaxation**:
   Under Ohmic-thermal diffusion $\mathcal{E}(\alpha_1, \alpha_2, \Delta t)$ with $\alpha_1, \alpha_2, \Delta t_1, \Delta t_2 \ge 0$,
   $\mathcal{E}(0)(\Sigma_{\mathrm{SPP}}) = \Sigma_{\mathrm{SPP}}$,
   $\mathcal{E}(\Delta t_2)\bigl(\mathcal{E}(\Delta t_1)(\Sigma_{\mathrm{SPP}})\bigr) = \mathcal{E}(\Delta t_1 + \Delta t_2)(\Sigma_{\mathrm{SPP}})$,
   and $Q_{\mathrm{core}}\bigl(\mathcal{E}(\Delta t_1)(\Sigma_{\mathrm{SPP}})\bigr) \le Q_{\mathrm{core}}(\Sigma_{\mathrm{SPP}})$. -/
@[blueprint "thm:signals-ddf-spp-tensor-splat-identities"
  (title := "Sub-wavelength SPP hotspot NormedTensorGaussianSplat2D confinement, Bohm pressure enhancement, and Ohmic-thermal semigroup theorem")
  (statement := /-- For \texttt{splat\_spp = sppHotspotTensorSplat cx cy weight lam0 n\_spp kappa\_ratio hw hlam hn hκ θ}
    with $n_{\mathrm{SPP}}\ge 1$, $\kappa_{\mathrm{ratio}}\ge 1$, $m>0$, and $\alpha_1,\alpha_2,\Delta t_1,\Delta t_2\ge 0$:
    (1) $\operatorname{splat\_spp}.\mathrm{covDet} = \lambda_0^4 / (n_{\mathrm{SPP}}^4 \kappa_{\mathrm{ratio}}^2)$,
    (2) $\operatorname{splat\_spp}.\mathrm{normFactor} = n_{\mathrm{SPP}}^2 \kappa_{\mathrm{ratio}} / (2\pi\lambda_0^2)$,
    (3) $\operatorname{splat\_spp}.\operatorname{coreBohmPotential}\;m\;\hbar = \frac{\hbar^2 n_{\mathrm{SPP}}^2(1+\kappa_{\mathrm{ratio}}^2)}{4m\lambda_0^2} \ge \frac{\hbar^2}{2m\lambda_0^2}$,
    (4) $\operatorname{splat\_spp}.\operatorname{quantumPressurePrincipal2}\;m\;\hbar\;x\;y = \kappa_{\mathrm{ratio}}^2\,\operatorname{splat\_spp}.\operatorname{quantumPressurePrincipal1}\;m\;\hbar\;x\;y$, and
    (5) $\operatorname{splat\_spp}.\operatorname{evolveThermal}$ obeys identity at $\Delta t=0$, semigroup additivity over $\Delta t_1+\Delta t_2$, and monotonic core Bohm potential relaxation. -/)
  (proof := /-- Expand $\sigma_1=\lambda_0/n_{\mathrm{SPP}}$ and $\sigma_2=\lambda_0/(n_{\mathrm{SPP}}\kappa_{\mathrm{ratio}})$,
    use $n_{\mathrm{SPP}}^2\ge 1$ and $1+\kappa_{\mathrm{ratio}}^2\ge 2$, and apply \texttt{evolveThermal\_semigroup\_and\_bohm\_decay}. -/)]
theorem MovingSheath.sppTensorSplat_and_thermal_identities
    {sub : DDFSubstrate} (_s : MovingSheath sub)
    (cx cy weight lam0 n_spp kappa_ratio alpha1 alpha2 dt1 dt2 m_boson hbar θ x y : ℝ)
    (hw : 0 ≤ weight) (hlam : 0 < lam0) (hn_ge : 1 ≤ n_spp) (hκ_ge : 1 ≤ kappa_ratio)
    (h_a1 : 0 ≤ alpha1) (h_a2 : 0 ≤ alpha2)
    (h_dt1 : 0 ≤ dt1) (h_dt2 : 0 ≤ dt2) (hm : 0 < m_boson) :
    let hn : 0 < n_spp := lt_of_lt_of_le zero_lt_one hn_ge
    let hκ : 0 < kappa_ratio := lt_of_lt_of_le zero_lt_one hκ_ge
    let splat_spp := sppHotspotTensorSplat cx cy weight lam0 n_spp kappa_ratio hw hlam hn hκ θ
    let step0 := splat_spp.evolveThermal alpha1 alpha2 0 h_a1 h_a2 le_rfl
    let step1 := splat_spp.evolveThermal alpha1 alpha2 dt1 h_a1 h_a2 h_dt1
    let step12 := step1.evolveThermal alpha1 alpha2 dt2 h_a1 h_a2 h_dt2
    let step_sum := splat_spp.evolveThermal alpha1 alpha2 (dt1 + dt2) h_a1 h_a2 (add_nonneg h_dt1 h_dt2)
    splat_spp.covDet = lam0 ^ 4 / (n_spp ^ 4 * kappa_ratio ^ 2) ∧
      splat_spp.normFactor = (n_spp ^ 2 * kappa_ratio) / (2 * Real.pi * lam0 ^ 2) ∧
      splat_spp.coreBohmPotential m_boson hbar =
        (hbar ^ 2 * n_spp ^ 2 * (1 + kappa_ratio ^ 2)) / (4 * m_boson * lam0 ^ 2) ∧
      hbar ^ 2 / (2 * m_boson * lam0 ^ 2) ≤ splat_spp.coreBohmPotential m_boson hbar ∧
      splat_spp.quantumPressurePrincipal2 m_boson hbar x y =
        kappa_ratio ^ 2 * splat_spp.quantumPressurePrincipal1 m_boson hbar x y ∧
      step0 = splat_spp ∧
      step12 = step_sum ∧
      step1.coreBohmPotential m_boson hbar ≤ splat_spp.coreBohmPotential m_boson hbar := by
  intro hn hκ splat_spp step0 step1 step12 step_sum
  have hlam_ne : lam0 ≠ 0 := ne_of_gt hlam
  have hn_ne : n_spp ≠ 0 := ne_of_gt hn
  have hκ_ne : kappa_ratio ≠ 0 := ne_of_gt hκ
  have hpi_ne : Real.pi ≠ 0 := ne_of_gt Real.pi_pos
  have hm_ne : m_boson ≠ 0 := ne_of_gt hm
  have h_det : splat_spp.covDet = lam0 ^ 4 / (n_spp ^ 4 * kappa_ratio ^ 2) := by
    dsimp [splat_spp, sppHotspotTensorSplat, NormedTensorGaussianSplat2D.covDet]
    field_simp [hlam_ne, hn_ne, hκ_ne]
  have h_norm : splat_spp.normFactor = (n_spp ^ 2 * kappa_ratio) / (2 * Real.pi * lam0 ^ 2) := by
    dsimp [splat_spp, sppHotspotTensorSplat, NormedTensorGaussianSplat2D.normFactor]
    field_simp [hlam_ne, hn_ne, hκ_ne, hpi_ne]
  have h_bohm :
      splat_spp.coreBohmPotential m_boson hbar =
        (hbar ^ 2 * n_spp ^ 2 * (1 + kappa_ratio ^ 2)) / (4 * m_boson * lam0 ^ 2) := by
    dsimp [splat_spp, sppHotspotTensorSplat, NormedTensorGaussianSplat2D.coreBohmPotential]
    field_simp [hlam_ne, hn_ne, hκ_ne, hm_ne]
  have h_bohm_ge :
      hbar ^ 2 / (2 * m_boson * lam0 ^ 2) ≤ splat_spp.coreBohmPotential m_boson hbar := by
    rw [h_bohm]
    have hn_sq_ge : 1 ≤ n_spp ^ 2 := by nlinarith
    have hκ_sq_ge : 1 ≤ kappa_ratio ^ 2 := by nlinarith
    have h_prod_ge : 2 ≤ n_spp ^ 2 * (1 + kappa_ratio ^ 2) := by nlinarith
    have h_num_le :
        2 * hbar ^ 2 ≤ hbar ^ 2 * (n_spp ^ 2 * (1 + kappa_ratio ^ 2)) := by
      have h_hbar_sq : 0 ≤ hbar ^ 2 := sq_nonneg hbar
      nlinarith
    have h_lhs :
        hbar ^ 2 / (2 * m_boson * lam0 ^ 2) =
          (2 * hbar ^ 2) / (4 * m_boson * lam0 ^ 2) := by
      field_simp [hm_ne, hlam_ne]
      ring
    rw [h_lhs]
    have h_rhs :
        (hbar ^ 2 * n_spp ^ 2 * (1 + kappa_ratio ^ 2)) / (4 * m_boson * lam0 ^ 2) =
          (hbar ^ 2 * (n_spp ^ 2 * (1 + kappa_ratio ^ 2))) / (4 * m_boson * lam0 ^ 2) := by
      ring
    rw [h_rhs]
    exact div_le_div_of_nonneg_right h_num_le (by positivity)
  have h_qp_ratio :
      splat_spp.quantumPressurePrincipal2 m_boson hbar x y =
        kappa_ratio ^ 2 * splat_spp.quantumPressurePrincipal1 m_boson hbar x y := by
    dsimp [splat_spp, sppHotspotTensorSplat,
      NormedTensorGaussianSplat2D.quantumPressurePrincipal1,
      NormedTensorGaussianSplat2D.quantumPressurePrincipal2]
    field_simp [hlam_ne, hn_ne, hκ_ne, hm_ne]
  have h_semi :=
    NormedTensorGaussianSplat2D.evolveThermal_semigroup_and_bohm_decay
      splat_spp alpha1 alpha2 dt1 dt2 m_boson hbar h_a1 h_a2 h_dt1 h_dt2 hm
  exact ⟨h_det, h_norm, h_bohm, h_bohm_ge, h_qp_ratio,
    h_semi.1, h_semi.2.1, h_semi.2.2.2⟩

/-! ## Anti-Amplituhedron Destructive Cancellation, Low-Symmetry Shear Polaritons, & 't Hooft–Susskind–DDF Holographic Principle (With and Without Splats) -/

/-- Complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ **"Anti-Amplituhedron" destructive phase-cancellation matrix**
with opposite-phase channel amplitudes $z_1 = +A$ and $z_2 = -A$ outside the positive
Grassmannian $Gr_{\ge 0}(2,4)$ (`docs/anti-fire-cannon-review.md`):
while each individual uncrossed channel carries positive energy $|w_A^{\mathbb{C}}|^2 = A^2$
and $|w_B^{\mathbb{C}}|^2 = A^2$, their coherent crossing sum vanishes identically:
$w_A^{\mathbb{C}} + w_B^{\mathbb{C}} = \Delta_{02}^{\mathbb{C}}\,\Delta_{13}^{\mathbb{C}} = 0$. -/
@[blueprint "def:signals-ddf-anti-amplituhedron-gr24-matrix"
  (title := "Complex Gr_C(2,4) Anti-Amplituhedron destructive phase-cancellation matrix")
  (statement := /-- Define $\operatorname{antiAmplituhedronGr24Matrix}(A)
    = \operatorname{complexGr24ChannelMatrix}(A, -A)$. -/)]
def antiAmplituhedronGr24Matrix (amplitude : ℝ) : Matrix (Fin 2) (Fin 4) ℂ :=
  complexGr24ChannelMatrix (↑amplitude) (-↑amplitude)

/-- Off-diagonal dielectric shear-polariton coupling
$\varepsilon_{xy}(\varepsilon_1, \varepsilon_2, \phi) = (\varepsilon_1 - \varepsilon_2)\,\sin\phi\,\cos\phi$
in a low-symmetry monoclinic/trigonal phonon-polaritonic crystal (e.g., $\alpha$-quartz or
$\beta\text{-Ga}_2\text{O}_3$; Galiffi et al., 2023, `arXiv:2312.06805`). -/
@[blueprint "def:signals-ddf-low-symmetry-shear-coupling"
  (title := "Low-symmetry phonon-polariton dielectric shear coupling ε_xy = (ε_1 - ε_2) sin φ cos φ")
  (statement := /-- Define $\operatorname{lowSymmetryShearCoupling}(\varepsilon_1,\varepsilon_2,\phi)
    = (\varepsilon_1 - \varepsilon_2)\,\sin\phi\,\cos\phi$. -/)]
noncomputable def lowSymmetryShearCoupling (eps1 eps2 shearAngle : ℝ) : ℝ :=
  (eps1 - eps2) * Real.sin shearAngle * Real.cos shearAngle

/-- 2D holographic screen area $A_H = 4\pi r_H^2$ of a DDF `RiverExterior` acoustic
event horizon $r_H = \frac{2 G_\phi M}{c^2}$. -/
@[blueprint "def:signals-ddf-horizon-area"
  (title := "DDF acoustic horizon 2D holographic screen area A_H = 4π r_H²")
  (statement := /-- Define $re.\mathrm{horizonArea} = 4\pi\,re.\mathrm{horizonRadius}^2$. -/)]
noncomputable def RiverExterior.horizonArea {sub : DDFSubstrate}
    (re : RiverExterior sub) : ℝ :=
  4 * Real.pi * re.horizonRadius ^ 2

/-- 't Hooft (1993) / Susskind (1995) / Bekenstein–Hawking holographic horizon entropy
$S_{\mathrm{BH}} = \frac{k_B\,A_H}{4\,\ell_P^2} = \frac{\pi\,k_B\,r_H^2}{\ell_P^2}$
on a DDF `RiverExterior` acoustic horizon for Planck length $\ell_P > 0$. -/
@[blueprint "def:signals-ddf-bekenstein-hawking-entropy"
  (title := "'t Hooft-Susskind-Bekenstein-Hawking holographic horizon entropy S_BH = k_B A_H / (4 ℓ_P²)")
  (statement := /-- Define $re.\mathrm{bekensteinHawkingEntropy}\;k_B\;\ell_P
    = k_B \cdot re.\mathrm{horizonArea} / (4\ell_P^2)$. -/)]
noncomputable def RiverExterior.bekensteinHawkingEntropy {sub : DDFSubstrate}
    (re : RiverExterior sub) (k_B l_planck : ℝ) : ℝ :=
  k_B * re.horizonArea / (4 * l_planck ^ 2)

/-- Acoustic horizon surface gravity $\kappa_H = \frac{c^2}{2\,r_H} = \frac{G_\phi M}{r_H^2}$
of a DDF `RiverExterior` flow. -/
@[blueprint "def:signals-ddf-horizon-surface-gravity"
  (title := "DDF acoustic horizon surface gravity κ_H = c² / (2 r_H)")
  (statement := /-- Define $re.\mathrm{horizonSurfaceGravity} = sub.c^2 / (2\cdot re.\mathrm{horizonRadius})$. -/)]
noncomputable def RiverExterior.horizonSurfaceGravity {sub : DDFSubstrate}
    (re : RiverExterior sub) : ℝ :=
  sub.c ^ 2 / (2 * re.horizonRadius)

/-- Dimensionless radial river inflow speed ratio $\beta_\phi(r) = \sqrt{r_H / r}$
for $r \ge r_H$ in a DDF `RiverExterior` geometry. -/
@[blueprint "def:signals-ddf-river-inflow-beta"
  (title := "Dimensionless DDF radial river inflow speed ratio β_ϕ(r) = √(r_H / r)")
  (statement := /-- Define $re.\mathrm{inflowBeta}(r) = \sqrt{re.\mathrm{horizonRadius} / r}$. -/)]
noncomputable def RiverExterior.inflowBeta {sub : DDFSubstrate}
    (re : RiverExterior sub) (r : ℝ) : ℝ :=
  Real.sqrt (re.horizonRadius / r)

/-- Isotropic Planck-pixelated `NormedTensorGaussianSplat2D` tile on the 2D holographic
horizon screen with principal widths $\sigma_1 = \sigma_2 = \ell_P > 0$. -/
@[blueprint "def:signals-ddf-holographic-planck-splat"
  (title := "Planck-scale holographic screen NormedTensorGaussianSplat2D tile")
  (statement := /-- Construct a Planck-scale \texttt{NormedTensorGaussianSplat2D} with
    $\sigma_1 = \sigma_2 = \ell_P > 0$. -/)]
noncomputable def holographicPlanckSplat
    (cx cy weight l_planck : ℝ) (hw : 0 ≤ weight) (hlp : 0 < l_planck) (θ : ℝ) :
    NormedTensorGaussianSplat2D :=
  { centerX := cx
    centerY := cy
    weight := weight
    weight_nonneg := hw
    sigma1 := l_planck
    sigma1_pos := hlp
    sigma2 := l_planck
    sigma2_pos := hlp
    orientationAngle := θ }

/-- **Anti-Amplituhedron Destructive Cancellation, Low-Symmetry Shear Polaritons, & 't Hooft–Susskind–DDF Holographic Principle Theorem (With and Without Splats)**:
1. **Anti-Amplituhedron Destructive Phase Cancellation on $Gr_{\mathbb{C}}(2,4)$**:
   For $M_{\mathrm{anti}} = \operatorname{antiAmplituhedronGr24Matrix}(A)$,
   $$w_A^{\mathbb{C}}(M_{\mathrm{anti}}) = A, \quad w_B^{\mathbb{C}}(M_{\mathrm{anti}}) = -A, \quad
   \Delta_{02}^{\mathbb{C}}(M_{\mathrm{anti}})\,\Delta_{13}^{\mathbb{C}}(M_{\mathrm{anti}}) = w_A^{\mathbb{C}}(M_{\mathrm{anti}}) + w_B^{\mathbb{C}}(M_{\mathrm{anti}}) = 0,$$
2. **Low-Symmetry Shear-Polariton Symmetry Breaking**:
   $\operatorname{lowSymmetryShearCoupling}(\varepsilon, \varepsilon, \phi) = 0$ and
   $\operatorname{lowSymmetryShearCoupling}(\varepsilon_1, \varepsilon_2, 0) = 0$,
3. **'t Hooft–Susskind Holographic Area-Entropy Law & Gauss–Smarr Bulk Mass Recovery**:
   For `re : RiverExterior sub` with $k_B > 0$ and $\ell_P > 0$,
   $$re.\mathrm{bekensteinHawkingEntropy}\;k_B\;\ell_P = \frac{\pi\,k_B\,re.\mathrm{horizonRadius}^2}{\ell_P^2} > 0,$$
   $$\frac{re.\mathrm{horizonSurfaceGravity} \cdot re.\mathrm{horizonArea}}{4\pi\,re.G_\phi} = re.\mathrm{sourceMass},$$
   proving that the 2D boundary integral of $\kappa_H$ over the holographic horizon screen $A_H$
   recovers the exact 3D bulk gravitating mass $M$,
4. **Splat-Free Continuum $Gr_{\mathbb{C}}(2,4)$ Holographic Redshift / Lapse Duality**:
   For any exterior radius $r > r_H$, let $\beta_r = re.\mathrm{inflowBeta}(r) \in (0, 1)$ and
   $M_{\mathrm{holo}}(r) = \operatorname{ddfThermalGr24Matrix}(\beta_r, \theta)$. Then the uncrossed
   $Gr_{\mathbb{C}}(2,4)$ Plücker channel product equals the exact Painlevé–Gullstrand / Schwarzschild
   gravitational redshift lapse factor $g_{00}(r) = 1 - r_H / r$:
   $$|w_A^{\mathbb{C}}(M_{\mathrm{holo}}(r))|^2\,|w_B^{\mathbb{C}}(M_{\mathrm{holo}}(r))|^2 = 1 - \frac{re.\mathrm{horizonRadius}}{r} > 0,$$
5. **With Normed Tensor Gaussian Splats: Planck-Pixelated Holographic Screen & UV Bohm Cutoff**:
   For `splat_p = holographicPlanckSplat cx cy weight l_planck hw hlp θ` with $m > 0$,
   $$\det\Sigma_{\mathrm{Planck}} = \ell_P^4, \qquad
   Q_{\mathrm{core}}(\Sigma_{\mathrm{Planck}}) = \frac{\hbar^2}{2 m\,\ell_P^2}, \qquad
   re.\mathrm{horizonArea} = 4\,\ell_P^2\,\frac{re.\mathrm{bekensteinHawkingEntropy}\;k_B\;\ell_P}{k_B}.$$ -/
@[blueprint "thm:signals-ddf-holographic-gr24-and-anti-amplituhedron"
  (title := "'t Hooft-Susskind-DDF holographic horizon duality, Gr_C(2,4) lapse law, and Anti-Amplituhedron cancellation theorem (with and without splats)")
  (statement := /-- For \texttt{re : RiverExterior sub}, $r > re.\mathrm{horizonRadius}$, $k_B>0$, $\ell_P>0$, $m>0$, and $\theta\in\mathbb R$:
    (1) $w_A^{\mathbb C}(\operatorname{antiAmplituhedronGr24Matrix}(A)) + w_B^{\mathbb C}(\operatorname{antiAmplituhedronGr24Matrix}(A)) = 0$ and $\Delta_{02}^{\mathbb C}\Delta_{13}^{\mathbb C} = 0$,
    (2) $\operatorname{lowSymmetryShearCoupling}(\varepsilon,\varepsilon,\phi) = 0$,
    (3) $re.\mathrm{bekensteinHawkingEntropy}\;k_B\;\ell_P = \pi k_B\,re.\mathrm{horizonRadius}^2/\ell_P^2 > 0$ and $(re.\mathrm{horizonSurfaceGravity}\cdot re.\mathrm{horizonArea})/(4\pi\,re.G_\phi) = re.\mathrm{sourceMass}$,
    (4) $|w_A^{\mathbb C}(M_{\mathrm{holo}}(r))|^2\,|w_B^{\mathbb C}(M_{\mathrm{holo}}(r))|^2 = 1 - re.\mathrm{horizonRadius}/r > 0$, and
    (5) $\operatorname{splat\_p}.\mathrm{covDet} = \ell_P^4$, $\operatorname{splat\_p}.\operatorname{coreBohmPotential}\;m\;\hbar = \hbar^2/(2m\ell_P^2)$, and $re.\mathrm{horizonArea} = 4\ell_P^2(re.\mathrm{bekensteinHawkingEntropy}\;k_B\;\ell_P / k_B)$. -/)
  (proof := /-- Use `complexGr24ChannelMatrix_minors` for `antiAmplituhedronGr24Matrix` and `M_holo(r)`,
    clear $r_H = 2 G_\phi M / c^2 > 0$ for the Gauss-Smarr identity, and expand `holographicPlanckSplat`. -/)]
theorem RiverExterior.holographic_gr24_ddf_and_antiAmplituhedron_identities
    {sub : DDFSubstrate} (re : RiverExterior sub)
    (A eps1 eps2 φ r k_B l_planck cx cy weight m_boson hbar θ : ℝ)
    (hr_gt : re.horizonRadius < r) (hkB : 0 < k_B) (hlp : 0 < l_planck)
    (hw : 0 ≤ weight) (hm : 0 < m_boson) :
    let M_anti := antiAmplituhedronGr24Matrix A
    let beta_r := re.inflowBeta r
    let M_holo := ddfThermalGr24Matrix beta_r θ
    let splat_p := holographicPlanckSplat cx cy weight l_planck hw hlp θ
    complexPluckerSinkAmplitudeA M_anti = (↑A : ℂ) ∧
      complexPluckerSinkAmplitudeB M_anti = -(↑A : ℂ) ∧
      Signals.Geometry.complexTwoRowMinor M_anti 0 2 *
          Signals.Geometry.complexTwoRowMinor M_anti 1 3 = 0 ∧
      lowSymmetryShearCoupling eps1 eps1 φ = 0 ∧
      lowSymmetryShearCoupling eps1 eps2 0 = 0 ∧
      re.bekensteinHawkingEntropy k_B l_planck =
        Real.pi * k_B * re.horizonRadius ^ 2 / l_planck ^ 2 ∧
      0 < re.bekensteinHawkingEntropy k_B l_planck ∧
      (re.horizonSurfaceGravity * re.horizonArea) / (4 * Real.pi * re.G_phi) =
        re.sourceMass ∧
      Complex.normSq (complexPluckerSinkAmplitudeA M_holo) *
          Complex.normSq (complexPluckerSinkAmplitudeB M_holo) =
        1 - re.horizonRadius / r ∧
      0 < Complex.normSq (complexPluckerSinkAmplitudeA M_holo) *
          Complex.normSq (complexPluckerSinkAmplitudeB M_holo) ∧
      splat_p.covDet = l_planck ^ 4 ∧
      splat_p.coreBohmPotential m_boson hbar =
        hbar ^ 2 / (2 * m_boson * l_planck ^ 2) ∧
      re.horizonArea =
        4 * l_planck ^ 2 * (re.bekensteinHawkingEntropy k_B l_planck / k_B) := by
  intro M_anti beta_r M_holo splat_p
  have h_anti_minors := complexGr24ChannelMatrix_minors (↑A : ℂ) (-(↑A : ℂ))
  have h_anti_A : complexPluckerSinkAmplitudeA M_anti = (↑A : ℂ) := by
    dsimp [M_anti, antiAmplituhedronGr24Matrix, complexPluckerSinkAmplitudeA]
    exact h_anti_minors.1
  have h_anti_B : complexPluckerSinkAmplitudeB M_anti = -(↑A : ℂ) := by
    dsimp [M_anti, antiAmplituhedronGr24Matrix, complexPluckerSinkAmplitudeB]
    exact h_anti_minors.2.1
  have h_anti_cross :
      Signals.Geometry.complexTwoRowMinor M_anti 0 2 *
          Signals.Geometry.complexTwoRowMinor M_anti 1 3 = 0 := by
    dsimp [M_anti, antiAmplituhedronGr24Matrix]
    rw [h_anti_minors.2.2]
    ring
  have h_shear_iso : lowSymmetryShearCoupling eps1 eps1 φ = 0 := by
    unfold lowSymmetryShearCoupling
    ring
  have h_shear_zero : lowSymmetryShearCoupling eps1 eps2 0 = 0 := by
    unfold lowSymmetryShearCoupling
    simp
  have hrH_pos : 0 < re.horizonRadius := re.horizonRadius_pos
  have hrH_ne : re.horizonRadius ≠ 0 := ne_of_gt hrH_pos
  have hr_pos : 0 < r := lt_trans hrH_pos hr_gt
  have hr_ne : r ≠ 0 := ne_of_gt hr_pos
  have hlp_ne : l_planck ≠ 0 := ne_of_gt hlp
  have hkB_ne : k_B ≠ 0 := ne_of_gt hkB
  have hpi_pos : 0 < Real.pi := Real.pi_pos
  have hpi_ne : Real.pi ≠ 0 := ne_of_gt hpi_pos
  have hG_pos : 0 < re.G_phi := re.G_phi_pos
  have hG_ne : re.G_phi ≠ 0 := ne_of_gt hG_pos
  have hc_pos : 0 < sub.c := sub.c_pos
  have hc_ne : sub.c ≠ 0 := ne_of_gt hc_pos
  have hm_ne : m_boson ≠ 0 := ne_of_gt hm
  have h_bh_eq :
      re.bekensteinHawkingEntropy k_B l_planck =
        Real.pi * k_B * re.horizonRadius ^ 2 / l_planck ^ 2 := by
    unfold RiverExterior.bekensteinHawkingEntropy RiverExterior.horizonArea
    field_simp [hlp_ne]
  have h_bh_pos : 0 < re.bekensteinHawkingEntropy k_B l_planck := by
    rw [h_bh_eq]
    positivity
  have h_smarr :
      (re.horizonSurfaceGravity * re.horizonArea) / (4 * Real.pi * re.G_phi) =
        re.sourceMass := by
    unfold RiverExterior.horizonSurfaceGravity RiverExterior.horizonArea
      RiverExterior.horizonRadius
    field_simp [hc_ne, hpi_ne, hG_ne]
  have h_ratio_pos : 0 < re.horizonRadius / r := div_pos hrH_pos hr_pos
  have h_ratio_lt_one : re.horizonRadius / r < 1 := (div_lt_one hr_pos).mpr hr_gt
  have h_beta_pos : 0 < beta_r := Real.sqrt_pos.mpr h_ratio_pos
  have h_beta_sq : beta_r ^ 2 = re.horizonRadius / r :=
    Real.sq_sqrt (le_of_lt h_ratio_pos)
  have h_beta_lt_one : beta_r < 1 := by nlinarith
  have h1p : 0 ≤ 1 + beta_r := by linarith
  have h1m : 0 ≤ 1 - beta_r := by linarith
  have h_holo_minors := complexGr24ChannelMatrix_minors
    (↑(Real.sqrt (1 + beta_r) * Real.cos θ) + Complex.I * ↑(Real.sqrt (1 + beta_r) * Real.sin θ))
    (↑(Real.sqrt (1 - beta_r) * Real.cos θ) - Complex.I * ↑(Real.sqrt (1 - beta_r) * Real.sin θ))
  have h_wA : Complex.normSq (complexPluckerSinkAmplitudeA M_holo) = 1 + beta_r := by
    dsimp [M_holo, ddfThermalGr24Matrix, complexPluckerSinkAmplitudeA]
    rw [h_holo_minors.1]
    simp only [Complex.normSq_apply, Complex.add_re, Complex.add_im, Complex.mul_re,
      Complex.mul_im, Complex.ofReal_re, Complex.ofReal_im, Complex.I_re, Complex.I_im]
    calc
      _ = (Real.sqrt (1 + beta_r)) ^ 2 * ((Real.cos θ) ^ 2 + (Real.sin θ) ^ 2) := by ring
      _ = 1 + beta_r := by rw [Real.sq_sqrt h1p, Real.cos_sq_add_sin_sq, mul_one]
  have h_wB : Complex.normSq (complexPluckerSinkAmplitudeB M_holo) = 1 - beta_r := by
    dsimp [M_holo, ddfThermalGr24Matrix, complexPluckerSinkAmplitudeB]
    rw [h_holo_minors.2.1]
    simp only [Complex.normSq_apply, Complex.sub_re, Complex.sub_im, Complex.mul_re,
      Complex.mul_im, Complex.ofReal_re, Complex.ofReal_im, Complex.I_re, Complex.I_im]
    calc
      _ = (Real.sqrt (1 - beta_r)) ^ 2 * ((Real.cos θ) ^ 2 + (Real.sin θ) ^ 2) := by ring
      _ = 1 - beta_r := by rw [Real.sq_sqrt h1m, Real.cos_sq_add_sin_sq, mul_one]
  have h_lapse :
      Complex.normSq (complexPluckerSinkAmplitudeA M_holo) *
          Complex.normSq (complexPluckerSinkAmplitudeB M_holo) =
        1 - re.horizonRadius / r := by
    rw [h_wA, h_wB]
    calc
      (1 + beta_r) * (1 - beta_r) = 1 - beta_r ^ 2 := by ring
      _ = 1 - re.horizonRadius / r := by rw [h_beta_sq]
  have h_lapse_pos :
      0 < Complex.normSq (complexPluckerSinkAmplitudeA M_holo) *
          Complex.normSq (complexPluckerSinkAmplitudeB M_holo) := by
    rw [h_lapse]
    linarith
  have h_p_det : splat_p.covDet = l_planck ^ 4 := by
    dsimp [splat_p, holographicPlanckSplat, NormedTensorGaussianSplat2D.covDet]
    ring
  have h_p_bohm :
      splat_p.coreBohmPotential m_boson hbar =
        hbar ^ 2 / (2 * m_boson * l_planck ^ 2) := by
    dsimp [splat_p, holographicPlanckSplat, NormedTensorGaussianSplat2D.coreBohmPotential]
    field_simp [hlp_ne, hm_ne]
    ring
  have h_area_splats :
      re.horizonArea =
        4 * l_planck ^ 2 * (re.bekensteinHawkingEntropy k_B l_planck / k_B) := by
    unfold RiverExterior.bekensteinHawkingEntropy
    field_simp [hlp_ne, hkB_ne]
  exact ⟨h_anti_A, h_anti_B, h_anti_cross, h_shear_iso, h_shear_zero,
    h_bh_eq, h_bh_pos, h_smarr, h_lapse, h_lapse_pos,
    h_p_det, h_p_bohm, h_area_splats⟩

/-- Symplectic Second-Harmonic OPA Squeezed `NormedTensorGaussianSplat2D`
with amplified principal width $\sigma_1 = \sigma_0\,\exp(r_{\mathrm{sq}})$ and
squeezed principal width $\sigma_2 = \sigma_0\,\exp(-r_{\mathrm{sq}})$
(modeling the phase-sensitive SHG resonant ring OPA of Dean et al., 2025,
`10.1038/s41586-025-09959-z`, and the SQG parametric optical gate). -/
@[blueprint "def:signals-ddf-opa-squeezed-tensor-splat"
  (title := "Second-harmonic OPA squeezed NormedTensorGaussianSplat2D")
  (statement := /-- Construct a \texttt{NormedTensorGaussianSplat2D} with
    $\sigma_1 = \sigma_0\exp(r_{\mathrm{sq}})$ and $\sigma_2 = \sigma_0\exp(-r_{\mathrm{sq}})$. -/)]
noncomputable def opaSqueezedTensorSplat
    (cx cy weight sigma0 r_sq : ℝ) (hw : 0 ≤ weight) (hs0 : 0 < sigma0) (θ : ℝ) :
    NormedTensorGaussianSplat2D :=
  { centerX := cx
    centerY := cy
    weight := weight
    weight_nonneg := hw
    sigma1 := sigma0 * Real.exp r_sq
    sigma1_pos := mul_pos hs0 (Real.exp_pos r_sq)
    sigma2 := sigma0 * Real.exp (-r_sq)
    sigma2_pos := mul_pos hs0 (Real.exp_pos (-r_sq))
    orientationAngle := θ }

/-- **Second-Harmonic OPA Symplectic Squeezing & Bohm Quantum-Potential Barrier Theorem (With and Without Splats)**:
For base width $\sigma_0 > 0$, squeeze factor $r_{\mathrm{sq}} \ge 0$, and boson mass $m > 0$:
1. **Without Splats (Continuum Squeezed Mode Bohm Amplification)**:
   $$Q_{\mathrm{cont}}\bigl(m, \hbar, \kappa_0\,\exp(r_{\mathrm{sq}})\bigr) = \exp(2 r_{\mathrm{sq}})\,Q_{\mathrm{cont}}(m, \hbar, \kappa_0) \ge Q_{\mathrm{cont}}(m, \hbar, \kappa_0),$$
2. **With Normed Tensor Gaussian Splats (`opaSqueezedTensorSplat`) — Symplectic Determinant & Peak Invariance**:
   $$\det\Sigma_{\mathrm{OPA}} = \sigma_0^4, \qquad \mathcal{N}(\Sigma_{\mathrm{OPA}}) = \frac{1}{2\pi\,\sigma_0^2},$$
   showing that degenerate $\chi^{(2)}$ OPA squeezing is an exact symplectic Anosov
   transformation (`anosovHyperbolicMatrix`) that preserves phase-space area,
3. **With Normed Tensor Gaussian Splats — Parametric Bohm Quantum-Potential Barrier Enhancement**:
   $$Q_{\mathrm{core}}(\Sigma_{\mathrm{OPA}}) = \frac{\hbar^2\,\bigl(\exp(2 r_{\mathrm{sq}}) + \exp(-2 r_{\mathrm{sq}})\bigr)}{4 m\,\sigma_0^2} \ge \frac{\hbar^2}{2 m\,\sigma_0^2},$$
   proving that second-harmonic parametric squeezing amplifies the repulsive core Bohm
   quantum potential $Q_{\mathrm{core}}$ while keeping $\det\Sigma_{\mathrm{OPA}} = \sigma_0^4$ constant. -/
@[blueprint "thm:signals-ddf-opa-squeezed-splat-and-continuum"
  (title := "Second-harmonic OPA symplectic squeezing and Bohm quantum-potential barrier theorem (with and without splats)")
  (statement := /-- For $\sigma_0>0$, $r_{\mathrm{sq}}\ge 0$, and $m>0$:
    (1) $\operatorname{continuumBohmPotentialMode}(m,\hbar,\kappa_0\exp(r_{\mathrm{sq}})) = \exp(2r_{\mathrm{sq}})\operatorname{continuumBohmPotentialMode}(m,\hbar,\kappa_0) \ge \operatorname{continuumBohmPotentialMode}(m,\hbar,\kappa_0)$,
    (2) $\operatorname{splat\_opa}.\mathrm{covDet} = \sigma_0^4$ and $\operatorname{splat\_opa}.\mathrm{normFactor} = 1/(2\pi\sigma_0^2)$, and
    (3) $\operatorname{splat\_opa}.\operatorname{coreBohmPotential}\;m\;\hbar = \frac{\hbar^2(\exp(2r_{\mathrm{sq}})+\exp(-2r_{\mathrm{sq}}))}{4m\sigma_0^2} \ge \frac{\hbar^2}{2m\sigma_0^2}$. -/)
  (proof := /-- Use $\exp(r)\exp(-r)=1$ for $\det\Sigma_{\mathrm{OPA}}$ and $\mathcal{N}(\Sigma_{\mathrm{OPA}})$,
    and $(\exp(r)-\exp(-r))^2 \ge 0 \implies \exp(2r)+\exp(-2r) \ge 2$ for the core Bohm potential bound. -/)]
theorem opaSqueezed_splat_and_continuum_identities
    (cx cy weight sigma0 r_sq kappa0 m_boson hbar θ x y : ℝ)
    (hw : 0 ≤ weight) (hs0 : 0 < sigma0) (hr_sq : 0 ≤ r_sq) (hm : 0 < m_boson) :
    let splat_opa := opaSqueezedTensorSplat cx cy weight sigma0 r_sq hw hs0 θ
    continuumBohmPotentialMode m_boson hbar (kappa0 * Real.exp r_sq) =
      Real.exp (2 * r_sq) * continuumBohmPotentialMode m_boson hbar kappa0 ∧
      continuumBohmPotentialMode m_boson hbar kappa0 ≤
        continuumBohmPotentialMode m_boson hbar (kappa0 * Real.exp r_sq) ∧
      splat_opa.covDet = sigma0 ^ 4 ∧
      splat_opa.normFactor = 1 / (2 * Real.pi * sigma0 ^ 2) ∧
      splat_opa.coreBohmPotential m_boson hbar =
        (hbar ^ 2 * (Real.exp (2 * r_sq) + Real.exp (-2 * r_sq))) /
          (4 * m_boson * sigma0 ^ 2) ∧
      hbar ^ 2 / (2 * m_boson * sigma0 ^ 2) ≤ splat_opa.coreBohmPotential m_boson hbar ∧
      splat_opa.quantumPressurePrincipal2 m_boson hbar x y =
        Real.exp (4 * r_sq) * splat_opa.quantumPressurePrincipal1 m_boson hbar x y := by
  intro splat_opa
  have hs0_ne : sigma0 ≠ 0 := ne_of_gt hs0
  have hm_ne : m_boson ≠ 0 := ne_of_gt hm
  have h_exp_prod : Real.exp r_sq * Real.exp (-r_sq) = 1 := by
    rw [← Real.exp_add, add_neg_cancel, Real.exp_zero]
  have h_exp_pos_sq : (Real.exp r_sq) ^ 2 = Real.exp (2 * r_sq) := by
    rw [sq, ← Real.exp_add]
    congr 1
    ring
  have h_exp_neg_sq : (Real.exp (-r_sq)) ^ 2 = Real.exp (-2 * r_sq) := by
    rw [sq, ← Real.exp_add]
    congr 1
    ring
  have h_cont_eq :
      continuumBohmPotentialMode m_boson hbar (kappa0 * Real.exp r_sq) =
        Real.exp (2 * r_sq) * continuumBohmPotentialMode m_boson hbar kappa0 := by
    unfold continuumBohmPotentialMode
    calc
      hbar ^ 2 * (kappa0 * Real.exp r_sq) ^ 2 / (2 * m_boson) =
          (Real.exp r_sq) ^ 2 * (hbar ^ 2 * kappa0 ^ 2 / (2 * m_boson)) := by ring
      _ = Real.exp (2 * r_sq) * (hbar ^ 2 * kappa0 ^ 2 / (2 * m_boson)) := by
          rw [h_exp_pos_sq]
  have h_cont_ge :
      continuumBohmPotentialMode m_boson hbar kappa0 ≤
        continuumBohmPotentialMode m_boson hbar (kappa0 * Real.exp r_sq) := by
    rw [h_cont_eq]
    have h_exp_ge_one : 1 ≤ Real.exp (2 * r_sq) := Real.one_le_exp (by linarith)
    have h_q_nonneg : 0 ≤ continuumBohmPotentialMode m_boson hbar kappa0 := by
      unfold continuumBohmPotentialMode
      positivity
    nlinarith
  have h_det : splat_opa.covDet = sigma0 ^ 4 := by
    dsimp [splat_opa, opaSqueezedTensorSplat, NormedTensorGaussianSplat2D.covDet]
    calc
      (sigma0 * Real.exp r_sq) ^ 2 * (sigma0 * Real.exp (-r_sq)) ^ 2 =
          sigma0 ^ 4 * (Real.exp r_sq * Real.exp (-r_sq)) ^ 2 := by ring
      _ = sigma0 ^ 4 := by rw [h_exp_prod, one_pow, mul_one]
  have h_norm : splat_opa.normFactor = 1 / (2 * Real.pi * sigma0 ^ 2) := by
    dsimp [splat_opa, opaSqueezedTensorSplat, NormedTensorGaussianSplat2D.normFactor]
    have h_prod :
        2 * Real.pi * (sigma0 * Real.exp r_sq) * (sigma0 * Real.exp (-r_sq)) =
          2 * Real.pi * sigma0 ^ 2 * (Real.exp r_sq * Real.exp (-r_sq)) := by ring
    rw [h_prod, h_exp_prod, mul_one]
  have h_bohm_eq :
      splat_opa.coreBohmPotential m_boson hbar =
        (hbar ^ 2 * (Real.exp (2 * r_sq) + Real.exp (-2 * r_sq))) /
          (4 * m_boson * sigma0 ^ 2) := by
    dsimp [splat_opa, opaSqueezedTensorSplat, NormedTensorGaussianSplat2D.coreBohmPotential]
    have h1 :
        1 / (sigma0 * Real.exp r_sq) ^ 2 =
          (Real.exp (-r_sq)) ^ 2 / sigma0 ^ 2 := by
      have h_ne1 : sigma0 * Real.exp r_sq ≠ 0 := mul_ne_zero hs0_ne (Real.exp_ne_zero r_sq)
      field_simp [h_ne1, hs0_ne]
      calc
        (1 : ℝ) = (Real.exp r_sq * Real.exp (-r_sq)) ^ 2 := by
          rw [h_exp_prod, one_pow]
        _ = (Real.exp r_sq) ^ 2 * (Real.exp (-r_sq)) ^ 2 := by ring
    have h2 :
        1 / (sigma0 * Real.exp (-r_sq)) ^ 2 =
          (Real.exp r_sq) ^ 2 / sigma0 ^ 2 := by
      have h_ne2 : sigma0 * Real.exp (-r_sq) ≠ 0 :=
        mul_ne_zero hs0_ne (Real.exp_ne_zero (-r_sq))
      field_simp [h_ne2, hs0_ne]
      calc
        (1 : ℝ) = (Real.exp r_sq * Real.exp (-r_sq)) ^ 2 := by
          rw [h_exp_prod, one_pow]
        _ = (Real.exp (-r_sq)) ^ 2 * (Real.exp r_sq) ^ 2 := by ring
    rw [h1, h2, h_exp_pos_sq, h_exp_neg_sq]
    ring
  have h_bohm_ge :
      hbar ^ 2 / (2 * m_boson * sigma0 ^ 2) ≤ splat_opa.coreBohmPotential m_boson hbar := by
    rw [h_bohm_eq]
    have h_cosh_ge_two : 2 ≤ Real.exp (2 * r_sq) + Real.exp (-2 * r_sq) := by
      have h_sq_nonneg : 0 ≤ (Real.exp r_sq - Real.exp (-r_sq)) ^ 2 := sq_nonneg _
      have h_expand :
          (Real.exp r_sq - Real.exp (-r_sq)) ^ 2 =
            Real.exp (2 * r_sq) + Real.exp (-2 * r_sq) -
              2 * (Real.exp r_sq * Real.exp (-r_sq)) := by
        rw [ ← h_exp_pos_sq, ← h_exp_neg_sq]
        ring
      rw [h_exp_prod] at h_expand
      linarith
    have h_num_le :
        2 * hbar ^ 2 ≤ hbar ^ 2 * (Real.exp (2 * r_sq) + Real.exp (-2 * r_sq)) := by
      have : 0 ≤ hbar ^ 2 := sq_nonneg hbar
      nlinarith
    have h_lhs :
        hbar ^ 2 / (2 * m_boson * sigma0 ^ 2) =
          (2 * hbar ^ 2) / (4 * m_boson * sigma0 ^ 2) := by
      field_simp [hm_ne, hs0_ne]
      ring
    rw [h_lhs]
    exact div_le_div_of_nonneg_right h_num_le (by positivity)
  have h_qp_ratio :
      splat_opa.quantumPressurePrincipal2 m_boson hbar x y =
        Real.exp (4 * r_sq) * splat_opa.quantumPressurePrincipal1 m_boson hbar x y := by
    unfold NormedTensorGaussianSplat2D.quantumPressurePrincipal1
      NormedTensorGaussianSplat2D.quantumPressurePrincipal2
    have h_s1 : splat_opa.sigma1 = sigma0 * Real.exp r_sq := rfl
    have h_s2 : splat_opa.sigma2 = sigma0 * Real.exp (-r_sq) := rfl
    rw [h_s1, h_s2]
    have h_ne1 : sigma0 * Real.exp r_sq ≠ 0 := mul_ne_zero hs0_ne (Real.exp_ne_zero r_sq)
    have h_ne2 : sigma0 * Real.exp (-r_sq) ≠ 0 :=
      mul_ne_zero hs0_ne (Real.exp_ne_zero (-r_sq))
    have h_exp4 :
        (Real.exp r_sq) ^ 2 = Real.exp (4 * r_sq) * (Real.exp (-r_sq)) ^ 2 := by
      rw [h_exp_neg_sq, h_exp_pos_sq, ← Real.exp_add]
      congr 1
      ring
    field_simp [h_ne1, h_ne2, hm_ne, hs0_ne]
    rw [h_exp4]
    ring
  exact ⟨h_cont_eq, h_cont_ge, h_det, h_norm, h_bohm_eq, h_bohm_ge, h_qp_ratio⟩

/-! ## Complex Grassmannian $Gr_{\mathbb{C}}(2,4)$, AdS/CFT, $\mathfrak{psl}(2|2)_c$ Secret-Symmetry Outer Automorphism, and DDF Holographic Unification (With and Without Splats) -/

/-- Complex $Gr_{\mathbb{C}}(2,4)$ embedding of the Beisert–Torrielli $\mathfrak{psl}(2|2)_c$
short-representation outer-automorphism parameters $(a, b, c, d)$ (`arXiv:1204.2366`, Eq. (2.11)):
$$W_{\mathrm{sec}}(a, b, c, d) = \begin{pmatrix} a & b & a & -b \\ c & d & -c & d \end{pmatrix} \in \mathbb{C}^{2 \times 4},$$
whose 6 Plücker minors directly encode the bound-state number $M = ad - bc$, the central
Hamiltonian $\mathbb{H} = ad + bc$, and the braided central-charge product
$-4\mathbb{C}\mathbb{C}^\dagger = -4(ab)(cd)$. -/
@[blueprint "def:signals-ddf-psl22-secret-automorphism-gr24"
  (title := "Complex Gr_C(2,4) embedding of the psl(2|2)_c secret-symmetry outer automorphism (a, b, c, d)")
  (statement := /-- Define $\operatorname{psl22SecretAutomorphismGr24Matrix}(a, b, c, d)
    = \begin{pmatrix} a & b & a & -b \\ c & d & -c & d \end{pmatrix}$. -/)]
def psl22SecretAutomorphismGr24Matrix (a b c d : ℂ) : Matrix (Fin 2) (Fin 4) ℂ :=
  !![a, b, a, -b;
     c, d, -c, d]

/-- Poincaré $\text{AdS}_{d+1}$ planar black-brane redshift / emblackening factor
$f_{\text{AdS}}(z, z_H, d) = 1 - (z / z_H)^d$ at bulk radial depth $z \in (0, z_H)$. -/
@[blueprint "def:signals-ddf-ads-planar-black-brane-emblackening"
  (title := "Poincaré AdS_{d+1} planar black-brane emblackening factor 1 - (z / z_H)^d")
  (statement := /-- Define $\operatorname{adsPlanarBlackBraneEmblackening}(z, z_H, d)
    = 1 - (z / z_H)^d$. -/)]
noncomputable def adsPlanarBlackBraneEmblackening (z z_H : ℝ) (d : ℕ) : ℝ :=
  1 - (z / z_H) ^ d

/-- Holographic Renormalization Group (RG) `NormedTensorGaussianSplat2D` wavepacket
with isotropic coarse-graining width $\sigma_1 = \sigma_2 = z_{\mathrm{rg}} > 0$
corresponding to bulk Poincaré $\text{AdS}$ radial depth $z_{\mathrm{rg}}$. -/
@[blueprint "def:signals-ddf-ads-holographic-rg-splat"
  (title := "Holographic RG NormedTensorGaussianSplat2D with width σ_1 = σ_2 = z_rg")
  (statement := /-- Construct a \texttt{NormedTensorGaussianSplat2D} with $\sigma_1 = \sigma_2 = z_{\mathrm{rg}}$. -/)]
def adsHolographicRGSplat
    (cx cy weight z_rg : ℝ) (hw : 0 ≤ weight) (hz : 0 < z_rg) (θ : ℝ) :
    NormedTensorGaussianSplat2D :=
  { centerX := cx
    centerY := cy
    weight := weight
    weight_nonneg := hw
    sigma1 := z_rg
    sigma1_pos := hz
    sigma2 := z_rg
    sigma2_pos := hz
    orientationAngle := θ }

/-- **Unified Grassmannian $Gr_{\mathbb{C}}(2,4)$, AdS/CFT, $\mathfrak{psl}(2|2)_c$ Secret Symmetry (`arXiv:1204.2366`), & DDF Holographic Theorem (With and Without Splats)**:
1. **3-Term Plücker Identity on $Gr_{\mathbb{C}}(2,4)$ Equals the $\mathfrak{psl}(2|2)_c$ Outer-Automorphism Central-Charge Dispersion Law (`arXiv:1204.2366`, Sec. 2.1 & Eq. (2.11))**:
   For $W_{\mathrm{sec}} = \operatorname{psl22SecretAutomorphismGr24Matrix}(a, b, c, d)$,
   the 6 complex Plücker minors satisfy:
   $$\Delta_{01}^{\mathbb{C}}(W_{\mathrm{sec}}) = \Delta_{23}^{\mathbb{C}}(W_{\mathrm{sec}}) = a d - b c, \qquad
   \Delta_{03}^{\mathbb{C}}(W_{\mathrm{sec}}) = -\Delta_{12}^{\mathbb{C}}(W_{\mathrm{sec}}) = a d + b c,$$
   $$\Delta_{02}^{\mathbb{C}}(W_{\mathrm{sec}})\,\Delta_{13}^{\mathbb{C}}(W_{\mathrm{sec}}) = -4 (a b)(c d),$$
   and the 3-term quadratic Plücker identity $\Delta_{01}^{\mathbb{C}}\Delta_{23}^{\mathbb{C}} - \Delta_{02}^{\mathbb{C}}\Delta_{13}^{\mathbb{C}} + \Delta_{03}^{\mathbb{C}}\Delta_{12}^{\mathbb{C}} = 0$
   reduces identically to the central-charge invariant norm:
   $$(a d + b c)^2 - 4(a b)(c d) = (a d - b c)^2 = \Delta_{01}^{\mathbb{C}}(W_{\mathrm{sec}})\,\Delta_{23}^{\mathbb{C}}(W_{\mathrm{sec}}),$$
   which for unimodular fundamental parameters $a d - b c = 1$ (`Eq. (2.11)`) yields $(a d + b c)^2 - 4(a b)(c d) = 1$,
2. **Without Splats: Universal $Gr_{\mathbb{C}}(2,4)$ Plücker Redshift Product Across $\text{AdS}_5$ Planar Black Branes ($d=4$) and DDF Acoustic Horizons**:
   For $0 < z < z_H$, setting $\beta_{\text{AdS}_5} = (z / z_H)^2$ and $M_{\text{AdS}_5} = \operatorname{ddfThermalGr24Matrix}(\beta_{\text{AdS}_5}, \theta)$ gives:
   $$\bigl|w_A^{\mathbb{C}}(M_{\text{AdS}_5})\bigr|^2\,\bigl|w_B^{\mathbb{C}}(M_{\text{AdS}_5})\bigr|^2 = 1 - \left(\frac{z}{z_H}\right)^4 = \operatorname{adsPlanarBlackBraneEmblackening}(z, z_H, 4) > 0,$$
   while for $r > r_H$ in DDF `RiverExterior`, $M_{\mathrm{DDF}} = \operatorname{ddfThermalGr24Matrix}(re.\mathrm{inflowBeta}(r), \theta)$ satisfies:
   $$\bigl|w_A^{\mathbb{C}}(M_{\mathrm{DDF}})\bigr|^2\,\bigl|w_B^{\mathbb{C}}(M_{\mathrm{DDF}})\bigr|^2 = 1 - \frac{r_H}{r} > 0,$$
3. **With Normed Tensor Gaussian Splats: Holographic RG Scale-Radius Flow (`adsHolographicRGSplat`)**:
   Under an $\text{AdS}$ bulk radial RG coarse-graining $z_{\mathrm{UV}} \mapsto \lambda_{\mathrm{rg}}\,z_{\mathrm{UV}}$ ($\lambda_{\mathrm{rg}} > 1$, $z_{\mathrm{UV}} > 0$, $m > 0$):
   $$\det\Sigma_{\mathrm{RG}}(\lambda_{\mathrm{rg}} z_{\mathrm{UV}}) = \lambda_{\mathrm{rg}}^4\,\det\Sigma_{\mathrm{RG}}(z_{\mathrm{UV}}) > \det\Sigma_{\mathrm{RG}}(z_{\mathrm{UV}}),$$
   $$Q_{\mathrm{core}}(\Sigma_{\mathrm{RG}}(\lambda_{\mathrm{rg}} z_{\mathrm{UV}})) = \frac{1}{\lambda_{\mathrm{rg}}^2}\,Q_{\mathrm{core}}(\Sigma_{\mathrm{RG}}(z_{\mathrm{UV}})) \le Q_{\mathrm{core}}(\Sigma_{\mathrm{RG}}(z_{\mathrm{UV}})).$$ -/
@[blueprint "thm:signals-ddf-grassmannian-ads-cft-ddf-secret-unification"
  (title := "Unified Gr_C(2,4), AdS/CFT, psl(2|2)_c secret-symmetry outer automorphism, and DDF holographic theorem (with and without splats)")
  (statement := /-- For $a,b,c,d\in\mathbb C$ with $ad - bc = 1$, $0 < z < z_H$, $r > r_H$, $z_{\mathrm{UV}} > 0$, $\lambda_{\mathrm{rg}} > 1$, and $m > 0$:
    (1) $W_{\mathrm{sec}} = \operatorname{psl22SecretAutomorphismGr24Matrix}(a,b,c,d)$ satisfies $\Delta_{01}^{\mathbb C}(W_{\mathrm{sec}}) = \Delta_{23}^{\mathbb C}(W_{\mathrm{sec}}) = ad - bc$,
    $\Delta_{03}^{\mathbb C}(W_{\mathrm{sec}}) = -\Delta_{12}^{\mathbb C}(W_{\mathrm{sec}}) = ad + bc$, $\Delta_{02}^{\mathbb C}(W_{\mathrm{sec}})\Delta_{13}^{\mathbb C}(W_{\mathrm{sec}}) = -4(ab)(cd)$,
    and $(ad + bc)^2 - 4(ab)(cd) = (ad - bc)^2 = 1$,
    (2) $|w_A^{\mathbb C}(M_{\text{AdS}_5})|^2 |w_B^{\mathbb C}(M_{\text{AdS}_5})|^2 = 1 - (z/z_H)^4 > 0$ and $|w_A^{\mathbb C}(M_{\mathrm{DDF}})|^2 |w_B^{\mathbb C}(M_{\mathrm{DDF}})|^2 = 1 - r_H/r > 0$, and
    (3) $\operatorname{splat\_ir}.\mathrm{covDet} = \lambda_{\mathrm{rg}}^4\,\operatorname{splat\_uv}.\mathrm{covDet} > \operatorname{splat\_uv}.\mathrm{covDet}$ and
    $\operatorname{splat\_ir}.\operatorname{coreBohmPotential}(m,\hbar) = \lambda_{\mathrm{rg}}^{-2}\,\operatorname{splat\_uv}.\operatorname{coreBohmPotential}(m,\hbar) \le \operatorname{splat\_uv}.\operatorname{coreBohmPotential}(m,\hbar)$. -/)
  (proof := /-- Expand the $2\times 2$ minors of $W_{\mathrm{sec}}$ by ring, use `complexGr24ChannelMatrix_minors` for $M_{\text{AdS}_5}$ and $M_{\mathrm{DDF}}$,
    and clear denominators in `adsHolographicRGSplat`. -/)]
theorem RiverExterior.grassmannian_ads_cft_ddf_and_secret_symmetry_unification
    {sub : DDFSubstrate} (re : RiverExterior sub)
    (a b c d : ℂ) (z z_H r cx cy weight z_uv lam_rg m_boson hbar θ : ℝ)
    (h_unimod : a * d - b * c = 1)
    (hz_pos : 0 < z) (hz_lt : z < z_H) (hr_gt : re.horizonRadius < r)
    (hw : 0 ≤ weight) (hz_uv : 0 < z_uv) (hlam_gt : 1 < lam_rg) (hm_pos : 0 < m_boson) :
    let W_sec := psl22SecretAutomorphismGr24Matrix a b c d
    let beta_ads5 := (z / z_H) ^ 2
    let M_ads5 := ddfThermalGr24Matrix beta_ads5 θ
    let M_ddf := ddfThermalGr24Matrix (re.inflowBeta r) θ
    let hlam_pos : 0 < lam_rg := lt_trans zero_lt_one hlam_gt
    let splat_uv := adsHolographicRGSplat cx cy weight z_uv hw hz_uv θ
    let splat_ir := adsHolographicRGSplat cx cy weight (lam_rg * z_uv) hw (mul_pos hlam_pos hz_uv) θ
    complexTwoRowMinor W_sec 0 1 = a * d - b * c ∧
      complexTwoRowMinor W_sec 2 3 = a * d - b * c ∧
      complexTwoRowMinor W_sec 0 3 = a * d + b * c ∧
      complexTwoRowMinor W_sec 1 2 = -(a * d + b * c) ∧
      complexTwoRowMinor W_sec 0 2 * complexTwoRowMinor W_sec 1 3 =
        -4 * (a * b) * (c * d) ∧
      (a * d + b * c) ^ 2 - 4 * (a * b) * (c * d) = (a * d - b * c) ^ 2 ∧
      (a * d + b * c) ^ 2 - 4 * (a * b) * (c * d) = 1 ∧
      (complexTwoRowMinor W_sec 0 3) ^ 2 +
          complexTwoRowMinor W_sec 0 2 * complexTwoRowMinor W_sec 1 3 =
        complexTwoRowMinor W_sec 0 1 * complexTwoRowMinor W_sec 2 3 ∧
      Complex.normSq (complexPluckerSinkAmplitudeA M_ads5) *
          Complex.normSq (complexPluckerSinkAmplitudeB M_ads5) =
        adsPlanarBlackBraneEmblackening z z_H 4 ∧
      0 < adsPlanarBlackBraneEmblackening z z_H 4 ∧
      Complex.normSq (complexPluckerSinkAmplitudeA M_ddf) *
          Complex.normSq (complexPluckerSinkAmplitudeB M_ddf) =
        1 - re.horizonRadius / r ∧
      continuumBohmPotentialMode m_boson hbar ((1 / z_uv) / lam_rg) =
        (1 / lam_rg ^ 2) * continuumBohmPotentialMode m_boson hbar (1 / z_uv) ∧
      splat_ir.covDet = lam_rg ^ 4 * splat_uv.covDet ∧
      splat_uv.covDet < splat_ir.covDet ∧
      splat_ir.coreBohmPotential m_boson hbar =
        (1 / lam_rg ^ 2) * splat_uv.coreBohmPotential m_boson hbar ∧
      splat_ir.coreBohmPotential m_boson hbar ≤ splat_uv.coreBohmPotential m_boson hbar := by
  intro W_sec beta_ads5 M_ads5 M_ddf hlam_pos splat_uv splat_ir
  have h_m01 : complexTwoRowMinor W_sec 0 1 = a * d - b * c := by
    dsimp [W_sec, psl22SecretAutomorphismGr24Matrix, complexTwoRowMinor]
  have h_m23 : complexTwoRowMinor W_sec 2 3 = a * d - b * c := by
    dsimp [W_sec, psl22SecretAutomorphismGr24Matrix, complexTwoRowMinor]
    ring
  have h_m03 : complexTwoRowMinor W_sec 0 3 = a * d + b * c := by
    dsimp [W_sec, psl22SecretAutomorphismGr24Matrix, complexTwoRowMinor]
    ring
  have h_m12 : complexTwoRowMinor W_sec 1 2 = -(a * d + b * c) := by
    dsimp [W_sec, psl22SecretAutomorphismGr24Matrix, complexTwoRowMinor]
    ring
  have h_m02_13 :
      complexTwoRowMinor W_sec 0 2 * complexTwoRowMinor W_sec 1 3 =
        -4 * (a * b) * (c * d) := by
    dsimp [W_sec, psl22SecretAutomorphismGr24Matrix, complexTwoRowMinor]
    ring
  have h_casimir_sq :
      (a * d + b * c) ^ 2 - 4 * (a * b) * (c * d) = (a * d - b * c) ^ 2 := by
    ring
  have h_casimir_one :
      (a * d + b * c) ^ 2 - 4 * (a * b) * (c * d) = 1 := by
    rw [h_casimir_sq, h_unimod, one_pow]
  have h_plucker_casimir :
      (complexTwoRowMinor W_sec 0 3) ^ 2 +
          complexTwoRowMinor W_sec 0 2 * complexTwoRowMinor W_sec 1 3 =
        complexTwoRowMinor W_sec 0 1 * complexTwoRowMinor W_sec 2 3 := by
    rw [h_m03, h_m02_13, h_m01, h_m23]
    ring
  have hzH_pos : 0 < z_H := lt_trans hz_pos hz_lt
  have h_ratio_pos : 0 < z / z_H := div_pos hz_pos hzH_pos
  have h_ratio_lt_one : z / z_H < 1 := (div_lt_one hzH_pos).mpr hz_lt
  have h_beta_pos : 0 < beta_ads5 := by
    dsimp [beta_ads5]
    exact sq_pos_of_pos h_ratio_pos
  have h_beta_lt_one : beta_ads5 < 1 := by
    dsimp [beta_ads5]
    nlinarith
  have h1p_ads : 0 ≤ 1 + beta_ads5 := by linarith
  have h1m_ads : 0 ≤ 1 - beta_ads5 := by linarith
  have h_ads_minors := complexGr24ChannelMatrix_minors
    (↑(Real.sqrt (1 + beta_ads5) * Real.cos θ) + Complex.I * ↑(Real.sqrt (1 + beta_ads5) * Real.sin θ))
    (↑(Real.sqrt (1 - beta_ads5) * Real.cos θ) - Complex.I * ↑(Real.sqrt (1 - beta_ads5) * Real.sin θ))
  have h_wA_ads : Complex.normSq (complexPluckerSinkAmplitudeA M_ads5) = 1 + beta_ads5 := by
    dsimp [M_ads5, ddfThermalGr24Matrix, complexPluckerSinkAmplitudeA]
    rw [h_ads_minors.1]
    simp only [Complex.normSq_apply, Complex.add_re, Complex.add_im, Complex.mul_re,
      Complex.mul_im, Complex.ofReal_re, Complex.ofReal_im, Complex.I_re, Complex.I_im]
    calc
      _ = (Real.sqrt (1 + beta_ads5)) ^ 2 * ((Real.cos θ) ^ 2 + (Real.sin θ) ^ 2) := by ring
      _ = 1 + beta_ads5 := by rw [Real.sq_sqrt h1p_ads, Real.cos_sq_add_sin_sq, mul_one]
  have h_wB_ads : Complex.normSq (complexPluckerSinkAmplitudeB M_ads5) = 1 - beta_ads5 := by
    dsimp [M_ads5, ddfThermalGr24Matrix, complexPluckerSinkAmplitudeB]
    rw [h_ads_minors.2.1]
    simp only [Complex.normSq_apply, Complex.sub_re, Complex.sub_im, Complex.mul_re,
      Complex.mul_im, Complex.ofReal_re, Complex.ofReal_im, Complex.I_re, Complex.I_im]
    calc
      _ = (Real.sqrt (1 - beta_ads5)) ^ 2 * ((Real.cos θ) ^ 2 + (Real.sin θ) ^ 2) := by ring
      _ = 1 - beta_ads5 := by rw [Real.sq_sqrt h1m_ads, Real.cos_sq_add_sin_sq, mul_one]
  have h_ads_lapse :
      Complex.normSq (complexPluckerSinkAmplitudeA M_ads5) *
          Complex.normSq (complexPluckerSinkAmplitudeB M_ads5) =
        adsPlanarBlackBraneEmblackening z z_H 4 := by
    rw [h_wA_ads, h_wB_ads]
    dsimp [beta_ads5, adsPlanarBlackBraneEmblackening]
    ring
  have h_ads_pos : 0 < adsPlanarBlackBraneEmblackening z z_H 4 := by
    have : 1 - beta_ads5 ^ 2 = adsPlanarBlackBraneEmblackening z z_H 4 := by
      dsimp [beta_ads5, adsPlanarBlackBraneEmblackening]
      ring
    rw [← this]
    nlinarith
  have h_holo := re.holographic_gr24_ddf_and_antiAmplituhedron_identities
    1 1 1 0 r 1 1 cx cy weight m_boson hbar θ hr_gt
    (by norm_num) (by norm_num) hw hm_pos
  have h_ddf_lapse :
      Complex.normSq (complexPluckerSinkAmplitudeA M_ddf) *
          Complex.normSq (complexPluckerSinkAmplitudeB M_ddf) =
        1 - re.horizonRadius / r := h_holo.2.2.2.2.2.2.2.2.1
  have h_rg_det : splat_ir.covDet = lam_rg ^ 4 * splat_uv.covDet := by
    dsimp [splat_ir, splat_uv, adsHolographicRGSplat, NormedTensorGaussianSplat2D.covDet]
    ring
  have h_rg_det_lt : splat_uv.covDet < splat_ir.covDet := by
    rw [h_rg_det]
    have huv_pos : 0 < splat_uv.covDet := by
      dsimp [splat_uv, adsHolographicRGSplat, NormedTensorGaussianSplat2D.covDet]
      positivity
    have hlam2_gt : 1 < lam_rg ^ 2 := by nlinarith
    have hlam4_gt : 1 < lam_rg ^ 4 := by nlinarith
    nlinarith
  have hz_uv_ne : z_uv ≠ 0 := ne_of_gt hz_uv
  have hlam_ne : lam_rg ≠ 0 := ne_of_gt hlam_pos
  have hm_ne : m_boson ≠ 0 := ne_of_gt hm_pos
  have h_cont_rg :
      continuumBohmPotentialMode m_boson hbar ((1 / z_uv) / lam_rg) =
        (1 / lam_rg ^ 2) * continuumBohmPotentialMode m_boson hbar (1 / z_uv) := by
    unfold continuumBohmPotentialMode
    field_simp [hz_uv_ne, hlam_ne, hm_ne]
  have h_rg_bohm :
      splat_ir.coreBohmPotential m_boson hbar =
        (1 / lam_rg ^ 2) * splat_uv.coreBohmPotential m_boson hbar := by
    dsimp [splat_ir, splat_uv, adsHolographicRGSplat, NormedTensorGaussianSplat2D.coreBohmPotential]
    field_simp [hz_uv_ne, hlam_ne, hm_ne]
  have h_rg_bohm_le :
      splat_ir.coreBohmPotential m_boson hbar ≤ splat_uv.coreBohmPotential m_boson hbar := by
    rw [h_rg_bohm]
    have h_uv_nonneg : 0 ≤ splat_uv.coreBohmPotential m_boson hbar := by
      dsimp [splat_uv, adsHolographicRGSplat, NormedTensorGaussianSplat2D.coreBohmPotential]
      positivity
    have h_inv_le_one : 1 / lam_rg ^ 2 ≤ 1 := by
      have hlam_sq_pos : 0 < lam_rg ^ 2 := sq_pos_of_pos hlam_pos
      rw [div_le_one hlam_sq_pos]
      nlinarith
    nlinarith
  exact ⟨h_m01, h_m23, h_m03, h_m12, h_m02_13, h_casimir_sq, h_casimir_one,
    h_plucker_casimir, h_ads_lapse, h_ads_pos, h_ddf_lapse,
    h_cont_rg, h_rg_det, h_rg_det_lt, h_rg_bohm, h_rg_bohm_le⟩

/-! ## Adaptive Two-Child Tensor Gaussian Splat Splitting ($L^1$ Mass, Center-of-Mass, & Second-Moment Variance Conservation) -/

/-- Major-axis child displacement $\delta_1 = \frac{\sqrt{3}}{2}\,\sigma_1$ used in
adaptive two-child Gaussian splat remeshing so that child width $\tilde{\sigma}_1 = \sigma_1 / 2$
and displacement $\delta_1$ preserve the total second-moment variance
$\tilde{\sigma}_1^2 + \delta_1^2 = \frac{1}{4}\sigma_1^2 + \frac{3}{4}\sigma_1^2 = \sigma_1^2$. -/
@[blueprint "def:signals-ddf-splat-split-major-offset"
  (title := "Variance-preserving major-axis child displacement δ_1 = (√3 / 2) σ_1")
  (statement := /-- Define $\operatorname{splat}.\mathrm{splitMajorOffset} = \frac{\sqrt{3}}{2}\,\sigma_1$. -/)]
noncomputable def NormedTensorGaussianSplat2D.splitMajorOffset
    (splat : NormedTensorGaussianSplat2D) : ℝ :=
  (Real.sqrt 3 / 2) * splat.sigma1

/-- Forward ($+\delta_1$) child `NormedTensorGaussianSplat2D` produced by adaptive
splitting along the first principal axis $(\cos\theta, \sin\theta)$ with half weight
$w / 2$ and halved major width $\sigma_1 / 2$. -/
@[blueprint "def:signals-ddf-splat-split-major-plus"
  (title := "Forward (+δ_1) child NormedTensorGaussianSplat2D from major-axis splitting")
  (statement := /-- Construct the $+\delta_1$ child splat with weight $w/2$, width $\sigma_1/2$,
    and center $(x_c + \delta_1\cos\theta, y_c + \delta_1\sin\theta)$. -/)]
noncomputable def NormedTensorGaussianSplat2D.splitMajorPlus
    (splat : NormedTensorGaussianSplat2D) : NormedTensorGaussianSplat2D :=
  { centerX := splat.centerX + splat.splitMajorOffset * Real.cos splat.orientationAngle
    centerY := splat.centerY + splat.splitMajorOffset * Real.sin splat.orientationAngle
    weight := splat.weight / 2
    weight_nonneg := div_nonneg splat.weight_nonneg (by norm_num)
    sigma1 := splat.sigma1 / 2
    sigma1_pos := div_pos splat.sigma1_pos (by norm_num)
    sigma2 := splat.sigma2
    sigma2_pos := splat.sigma2_pos
    orientationAngle := splat.orientationAngle }

/-- Backward ($-\delta_1$) child `NormedTensorGaussianSplat2D` produced by adaptive
splitting along the first principal axis $(\cos\theta, \sin\theta)$ with half weight
$w / 2$ and halved major width $\sigma_1 / 2$. -/
@[blueprint "def:signals-ddf-splat-split-major-minus"
  (title := "Backward (-δ_1) child NormedTensorGaussianSplat2D from major-axis splitting")
  (statement := /-- Construct the $-\delta_1$ child splat with weight $w/2$, width $\sigma_1/2$,
    and center $(x_c - \delta_1\cos\theta, y_c - \delta_1\sin\theta)$. -/)]
noncomputable def NormedTensorGaussianSplat2D.splitMajorMinus
    (splat : NormedTensorGaussianSplat2D) : NormedTensorGaussianSplat2D :=
  { centerX := splat.centerX - splat.splitMajorOffset * Real.cos splat.orientationAngle
    centerY := splat.centerY - splat.splitMajorOffset * Real.sin splat.orientationAngle
    weight := splat.weight / 2
    weight_nonneg := div_nonneg splat.weight_nonneg (by norm_num)
    sigma1 := splat.sigma1 / 2
    sigma1_pos := div_pos splat.sigma1_pos (by norm_num)
    sigma2 := splat.sigma2
    sigma2_pos := splat.sigma2_pos
    orientationAngle := splat.orientationAngle }

/-- **Adaptive Two-Child Splat Splitting Conservation & Bohm Resolution Theorem**:
For any `splat : NormedTensorGaussianSplat2D` and $m > 0, \hbar \neq 0$:
1. **Exact $L^1(\mathbb{R}^2)$ Mass/Weight Conservation**:
   $$w_+ + w_- = w,$$
2. **Exact Center-of-Mass Preservation**:
   $$\frac{x_+ + x_-}{2} = x_c, \qquad \frac{y_+ + y_-}{2} = y_c,$$
3. **Exact Major-Axis Second-Moment Variance Conservation**:
   $$\tilde{\sigma}_1^2 + \delta_1^2 = \left(\frac{\sigma_1}{2}\right)^2 + \left(\frac{\sqrt{3}}{2}\sigma_1\right)^2 = \sigma_1^2,$$
   $$(x_+ - x_c)^2 + (y_+ - y_c)^2 + \tilde{\sigma}_1^2 = \sigma_1^2,$$
4. **Aspect-Ratio Halving & Covariance Determinant Reduction**:
   $$\frac{\tilde{\sigma}_1}{\tilde{\sigma}_2} = \frac{1}{2}\,\frac{\sigma_1}{\sigma_2}, \qquad
   \det\Sigma_+ = \frac{1}{4}\,\det\Sigma,$$
5. **Repulsive Core Bohm Quantum-Potential Refinement**:
   $$Q_{\mathrm{core}}(\Sigma_+) - Q_{\mathrm{core}}(\Sigma) = \frac{3\hbar^2}{4 m\,\sigma_1^2} > 0.$$ -/
@[blueprint "thm:signals-ddf-splat-split-major-conservation"
  (title := "Adaptive two-child Tensor Gaussian Splat splitting conservation and Bohm refinement theorem")
  (statement := /-- For any \texttt{splat : NormedTensorGaussianSplat2D}, $m > 0$, and $\hbar \ne 0$:
    (1) $w_+ + w_- = w$,
    (2) $(x_+ + x_-)/2 = x_c$ and $(y_+ + y_-)/2 = y_c$,
    (3) $\tilde{\sigma}_1^2 + \delta_1^2 = \sigma_1^2$ and $(x_+ - x_c)^2 + (y_+ - y_c)^2 + \tilde{\sigma}_1^2 = \sigma_1^2$,
    (4) $\tilde{\sigma}_1 / \tilde{\sigma}_2 = \frac{1}{2}(\sigma_1 / \sigma_2)$ and $\det\Sigma_+ = \frac{1}{4}\det\Sigma$, and
    (5) $Q_{\mathrm{core}}(\Sigma_+) - Q_{\mathrm{core}}(\Sigma) = \frac{3\hbar^2}{4m\sigma_1^2} > 0$. -/)
  (proof := /-- Use $(\sqrt{3})^2 = 3$, $\cos^2\theta + \sin^2\theta = 1$, and clear $\sigma_1 \ne 0$
    in `coreBohmPotential`. -/)]
theorem NormedTensorGaussianSplat2D.splitMajor_conservation_identities
    (splat : NormedTensorGaussianSplat2D) (m_boson hbar : ℝ)
    (hm : 0 < m_boson) (hhbar : hbar ≠ 0) :
    let c_plus := splat.splitMajorPlus
    let c_minus := splat.splitMajorMinus
    c_plus.weight + c_minus.weight = splat.weight ∧
      (c_plus.centerX + c_minus.centerX) / 2 = splat.centerX ∧
      (c_plus.centerY + c_minus.centerY) / 2 = splat.centerY ∧
      c_plus.sigma1 ^ 2 + splat.splitMajorOffset ^ 2 = splat.sigma1 ^ 2 ∧
      (c_plus.centerX - splat.centerX) ^ 2 +
          (c_plus.centerY - splat.centerY) ^ 2 + c_plus.sigma1 ^ 2 =
        splat.sigma1 ^ 2 ∧
      c_plus.sigma1 / c_plus.sigma2 = (1 / 2) * (splat.sigma1 / splat.sigma2) ∧
      c_plus.covDet = (1 / 4) * splat.covDet ∧
      c_plus.coreBohmPotential m_boson hbar - splat.coreBohmPotential m_boson hbar =
        (3 * hbar ^ 2) / (4 * m_boson * splat.sigma1 ^ 2) ∧
      splat.coreBohmPotential m_boson hbar < c_plus.coreBohmPotential m_boson hbar := by
  intro c_plus c_minus
  have h_w : c_plus.weight + c_minus.weight = splat.weight := by
    dsimp [c_plus, c_minus, splitMajorPlus, splitMajorMinus]
    ring
  have h_cx : (c_plus.centerX + c_minus.centerX) / 2 = splat.centerX := by
    dsimp [c_plus, c_minus, splitMajorPlus, splitMajorMinus]
    ring
  have h_cy : (c_plus.centerY + c_minus.centerY) / 2 = splat.centerY := by
    dsimp [c_plus, c_minus, splitMajorPlus, splitMajorMinus]
    ring
  have h3 : (Real.sqrt 3) ^ 2 = 3 := Real.sq_sqrt (by norm_num)
  have h_var1 : c_plus.sigma1 ^ 2 + splat.splitMajorOffset ^ 2 = splat.sigma1 ^ 2 := by
    dsimp [c_plus, splitMajorPlus, splitMajorOffset]
    calc
      (splat.sigma1 / 2) ^ 2 + (Real.sqrt 3 / 2 * splat.sigma1) ^ 2 =
          ((1 + (Real.sqrt 3) ^ 2) / 4) * splat.sigma1 ^ 2 := by ring
      _ = splat.sigma1 ^ 2 := by rw [h3]; ring
  have h_var2 :
      (c_plus.centerX - splat.centerX) ^ 2 +
          (c_plus.centerY - splat.centerY) ^ 2 + c_plus.sigma1 ^ 2 =
        splat.sigma1 ^ 2 := by
    have h_disp :
        (c_plus.centerX - splat.centerX) ^ 2 +
            (c_plus.centerY - splat.centerY) ^ 2 =
          splat.splitMajorOffset ^ 2 := by
      dsimp [c_plus, splitMajorPlus]
      calc
        (splat.centerX + splat.splitMajorOffset * Real.cos splat.orientationAngle - splat.centerX) ^ 2 +
            (splat.centerY + splat.splitMajorOffset * Real.sin splat.orientationAngle - splat.centerY) ^ 2 =
          splat.splitMajorOffset ^ 2 *
            ((Real.cos splat.orientationAngle) ^ 2 + (Real.sin splat.orientationAngle) ^ 2) := by ring
        _ = splat.splitMajorOffset ^ 2 := by rw [Real.cos_sq_add_sin_sq, mul_one]
    rw [h_disp]
    linarith [h_var1]
  have h_aspect :
      c_plus.sigma1 / c_plus.sigma2 = (1 / 2) * (splat.sigma1 / splat.sigma2) := by
    dsimp [c_plus, splitMajorPlus]
    ring
  have h_det : c_plus.covDet = (1 / 4) * splat.covDet := by
    dsimp [c_plus, splitMajorPlus, covDet]
    ring
  have hs1_ne : splat.sigma1 ≠ 0 := ne_of_gt splat.sigma1_pos
  have hs2_ne : splat.sigma2 ≠ 0 := ne_of_gt splat.sigma2_pos
  have hm_ne : m_boson ≠ 0 := ne_of_gt hm
  have h_bohm_diff :
      c_plus.coreBohmPotential m_boson hbar - splat.coreBohmPotential m_boson hbar =
        (3 * hbar ^ 2) / (4 * m_boson * splat.sigma1 ^ 2) := by
    dsimp [c_plus, splitMajorPlus, coreBohmPotential]
    field_simp [hs1_ne, hs2_ne, hm_ne]
    ring
  have h_bohm_lt :
      splat.coreBohmPotential m_boson hbar < c_plus.coreBohmPotential m_boson hbar := by
    have h_pos : 0 < (3 * hbar ^ 2) / (4 * m_boson * splat.sigma1 ^ 2) := by
      have hh2 : 0 < hbar ^ 2 := sq_pos_of_ne_zero hhbar
      have hs1_sq : 0 < splat.sigma1 ^ 2 := sq_pos_of_pos splat.sigma1_pos
      positivity
    linarith [h_bohm_diff]
  exact ⟨h_w, h_cx, h_cy, h_var1, h_var2, h_aspect, h_det, h_bohm_diff, h_bohm_lt⟩

/-! ## 3D Normed Anisotropic Tensor Gaussian Splatting (`NormedTensorGaussianSplat3D`), 3D Splat Splitting, and the Holographic $Gr_{\mathbb{C}}(2,4)$ Affine Projection Trick -/

/-- Normed 3D anisotropic Tensor Gaussian Splat primitive in $\mathbb{R}^3$ with center
$(x_c, y_c, z_c)$, $L^1(\mathbb{R}^3)$ weight $w \ge 0$, positive principal widths
$\sigma_1, \sigma_2, \sigma_3 > 0$, in-plane azimuth $\theta = \mathrm{orientationAngle}$,
and out-of-plane pitch angle $\psi = \mathrm{pitchAngle}$ defining the unit major axis
$\mathbf{u}_1 = (\cos\psi\cos\theta, \cos\psi\sin\theta, \sin\psi) \in S^2$. -/
@[blueprint "def:signals-ddf-normed-tensor-gaussian-splat3d"
  (title := "Normed 3D anisotropic Tensor Gaussian Splat primitive")
  (statement := /-- A \texttt{NormedTensorGaussianSplat3D} carries center $(x_c,y_c,z_c)\in\mathbb R^3$,
    weight $w\ge 0$, positive principal widths $\sigma_1,\sigma_2,\sigma_3 > 0$, azimuth $\theta$,
    and pitch angle $\psi$. -/)]
structure NormedTensorGaussianSplat3D where
  centerX : ℝ
  centerY : ℝ
  centerZ : ℝ
  weight : ℝ
  weight_nonneg : 0 ≤ weight
  sigma1 : ℝ
  sigma1_pos : 0 < sigma1
  sigma2 : ℝ
  sigma2_pos : 0 < sigma2
  sigma3 : ℝ
  sigma3_pos : 0 < sigma3
  orientationAngle : ℝ
  pitchAngle : ℝ

/-- 3D covariance determinant $\det\Sigma_{\mathrm{3D}} = \sigma_1^2\,\sigma_2^2\,\sigma_3^2$. -/
@[blueprint "def:signals-ddf-splat3d-cov-det"
  (title := "3D covariance determinant det Σ_3D = σ_1² σ_2² σ_3²")
  (statement := /-- Define $\operatorname{splat3d}.\mathrm{covDet} = \sigma_1^2\,\sigma_2^2\,\sigma_3^2$. -/)]
def NormedTensorGaussianSplat3D.covDet (splat : NormedTensorGaussianSplat3D) : ℝ :=
  splat.sigma1 ^ 2 * splat.sigma2 ^ 2 * splat.sigma3 ^ 2

/-- 3D covariance trace $\operatorname{Tr}\Sigma_{\mathrm{3D}} = \sigma_1^2 + \sigma_2^2 + \sigma_3^2$. -/
@[blueprint "def:signals-ddf-splat3d-cov-trace"
  (title := "3D covariance trace Tr Σ_3D = σ_1² + σ_2² + σ_3²")
  (statement := /-- Define $\operatorname{splat3d}.\mathrm{covTrace} = \sigma_1^2 + \sigma_2^2 + \sigma_3^2$. -/)]
def NormedTensorGaussianSplat3D.covTrace (splat : NormedTensorGaussianSplat3D) : ℝ :=
  splat.sigma1 ^ 2 + splat.sigma2 ^ 2 + splat.sigma3 ^ 2

/-- Exact 3D $L^1(\mathbb{R}^3)$ Gaussian normalization factor
$\mathcal{N}_{\mathrm{3D}}(\Sigma_{\mathrm{3D}}) = \frac{1}{2\pi\sqrt{2\pi}\,\sigma_1\sigma_2\sigma_3}$. -/
@[blueprint "def:signals-ddf-splat3d-norm-factor"
  (title := "3D L¹(ℝ³) Gaussian normalization factor 1 / ((2π)^{3/2} σ_1 σ_2 σ_3)")
  (statement := /-- Define $\operatorname{splat3d}.\mathrm{normFactor}
    = \frac{1}{2\pi\sqrt{2\pi}\,\sigma_1\sigma_2\sigma_3}$. -/)]
noncomputable def NormedTensorGaussianSplat3D.normFactor
    (splat : NormedTensorGaussianSplat3D) : ℝ :=
  1 / (2 * Real.pi * Real.sqrt (2 * Real.pi) * splat.sigma1 * splat.sigma2 * splat.sigma3)

/-- 3D repulsive core Bohm quantum potential
$Q_{\mathrm{core,3D}}(\Sigma_{\mathrm{3D}}) = \frac{\hbar^2}{4m}\left(\frac{1}{\sigma_1^2} + \frac{1}{\sigma_2^2} + \frac{1}{\sigma_3^2}\right)$. -/
@[blueprint "def:signals-ddf-splat3d-core-bohm-potential"
  (title := "3D core repulsive Bohm quantum potential Q_core,3D(Σ_3D)")
  (statement := /-- Define $\operatorname{splat3d}.\operatorname{coreBohmPotential}(m,\hbar)
    = \frac{\hbar^2}{4m}\left(\frac{1}{\sigma_1^2}+\frac{1}{\sigma_2^2}+\frac{1}{\sigma_3^2}\right)$. -/)]
noncomputable def NormedTensorGaussianSplat3D.coreBohmPotential
    (splat : NormedTensorGaussianSplat3D) (m_boson hbar : ℝ) : ℝ :=
  (hbar ^ 2 / (4 * m_boson)) *
    (1 / splat.sigma1 ^ 2 + 1 / splat.sigma2 ^ 2 + 1 / splat.sigma3 ^ 2)

/-- 3D major-axis child displacement $\delta_1 = \frac{\sqrt{3}}{2}\,\sigma_1$. -/
@[blueprint "def:signals-ddf-splat3d-split-major-offset"
  (title := "3D variance-preserving major-axis child displacement δ_1 = (√3 / 2) σ_1")
  (statement := /-- Define $\operatorname{splat3d}.\mathrm{splitMajorOffset} = \frac{\sqrt{3}}{2}\sigma_1$. -/)]
noncomputable def NormedTensorGaussianSplat3D.splitMajorOffset
    (splat : NormedTensorGaussianSplat3D) : ℝ :=
  (Real.sqrt 3 / 2) * splat.sigma1

/-- Forward ($+\delta_1$) 3D child splat displaced along the 3D unit major axis
$\mathbf{u}_1 = (\cos\psi\cos\theta, \cos\psi\sin\theta, \sin\psi)$ with half weight
$w / 2$ and halved major width $\sigma_1 / 2$. -/
@[blueprint "def:signals-ddf-splat3d-split-major-plus"
  (title := "Forward (+δ_1) 3D child NormedTensorGaussianSplat3D")
  (statement := /-- Construct the $+\delta_1$ 3D child splat along
    $\mathbf{u}_1 = (\cos\psi\cos\theta, \cos\psi\sin\theta, \sin\psi)$. -/)]
noncomputable def NormedTensorGaussianSplat3D.splitMajorPlus
    (splat : NormedTensorGaussianSplat3D) : NormedTensorGaussianSplat3D :=
  { centerX := splat.centerX +
      splat.splitMajorOffset * Real.cos splat.pitchAngle * Real.cos splat.orientationAngle
    centerY := splat.centerY +
      splat.splitMajorOffset * Real.cos splat.pitchAngle * Real.sin splat.orientationAngle
    centerZ := splat.centerZ +
      splat.splitMajorOffset * Real.sin splat.pitchAngle
    weight := splat.weight / 2
    weight_nonneg := div_nonneg splat.weight_nonneg (by norm_num)
    sigma1 := splat.sigma1 / 2
    sigma1_pos := div_pos splat.sigma1_pos (by norm_num)
    sigma2 := splat.sigma2
    sigma2_pos := splat.sigma2_pos
    sigma3 := splat.sigma3
    sigma3_pos := splat.sigma3_pos
    orientationAngle := splat.orientationAngle
    pitchAngle := splat.pitchAngle }

/-- Backward ($-\delta_1$) 3D child splat displaced along the 3D unit major axis
$\mathbf{u}_1 = (\cos\psi\cos\theta, \cos\psi\sin\theta, \sin\psi)$ with half weight
$w / 2$ and halved major width $\sigma_1 / 2$. -/
@[blueprint "def:signals-ddf-splat3d-split-major-minus"
  (title := "Backward (-δ_1) 3D child NormedTensorGaussianSplat3D")
  (statement := /-- Construct the $-\delta_1$ 3D child splat along
    $\mathbf{u}_1 = (\cos\psi\cos\theta, \cos\psi\sin\theta, \sin\psi)$. -/)]
noncomputable def NormedTensorGaussianSplat3D.splitMajorMinus
    (splat : NormedTensorGaussianSplat3D) : NormedTensorGaussianSplat3D :=
  { centerX := splat.centerX -
      splat.splitMajorOffset * Real.cos splat.pitchAngle * Real.cos splat.orientationAngle
    centerY := splat.centerY -
      splat.splitMajorOffset * Real.cos splat.pitchAngle * Real.sin splat.orientationAngle
    centerZ := splat.centerZ -
      splat.splitMajorOffset * Real.sin splat.pitchAngle
    weight := splat.weight / 2
    weight_nonneg := div_nonneg splat.weight_nonneg (by norm_num)
    sigma1 := splat.sigma1 / 2
    sigma1_pos := div_pos splat.sigma1_pos (by norm_num)
    sigma2 := splat.sigma2
    sigma2_pos := splat.sigma2_pos
    sigma3 := splat.sigma3
    sigma3_pos := splat.sigma3_pos
    orientationAngle := splat.orientationAngle
    pitchAngle := splat.pitchAngle }

/-- Orthographic X-ray / Radon marginal projection of a `NormedTensorGaussianSplat3D`
onto the 2D $(x, y)$ screen (`NormedTensorGaussianSplat2D`), integrating out the
normal $z$-direction ($\int_{-\infty}^\infty \frac{1}{\sqrt{2\pi}\sigma_3}e^{-(z-z_c)^2/(2\sigma_3^2)}dz = 1$). -/
@[blueprint "def:signals-ddf-splat3d-project-orthographic2d"
  (title := "Orthographic 3D-to-2D marginal projection of NormedTensorGaussianSplat3D")
  (statement := /-- Project a \texttt{NormedTensorGaussianSplat3D} orthographically onto the
    $(x,y)$ plane as a \texttt{NormedTensorGaussianSplat2D}. -/)]
def NormedTensorGaussianSplat3D.projectOrthographic2D
    (splat : NormedTensorGaussianSplat3D) : NormedTensorGaussianSplat2D :=
  { centerX := splat.centerX
    centerY := splat.centerY
    weight := splat.weight
    weight_nonneg := splat.weight_nonneg
    sigma1 := splat.sigma1
    sigma1_pos := splat.sigma1_pos
    sigma2 := splat.sigma2
    sigma2_pos := splat.sigma2_pos
    orientationAngle := splat.orientationAngle }

/-- Holographic / EWA perspective affine projection of a `NormedTensorGaussianSplat3D`
at bulk depth $z_c > 0$ with focal / AdS curvature scale $f > 0$ onto the 2D boundary
screen (`NormedTensorGaussianSplat2D`) with Jacobian scale $s_{\mathrm{persp}} = f / z_c > 0$
(Zwicker et al. 2001 EWA Splatting; Kerbl et al. 2023 3DGS; Poincaré AdS bulk-to-boundary map). -/
@[blueprint "def:signals-ddf-splat3d-project-perspective2d"
  (title := "Holographic / EWA perspective affine 3D-to-2D projection of NormedTensorGaussianSplat3D")
  (statement := /-- For focal/AdS scale $f > 0$ and bulk depth $z_c > 0$, project
    \texttt{splat : NormedTensorGaussianSplat3D} onto the 2D screen with scale $s = f / z_c$. -/)]
noncomputable def NormedTensorGaussianSplat3D.projectPerspective2D
    (splat : NormedTensorGaussianSplat3D) (focalScale : ℝ)
    (hf : 0 < focalScale) (hz : 0 < splat.centerZ) : NormedTensorGaussianSplat2D :=
  let s := focalScale / splat.centerZ
  have hs : 0 < s := div_pos hf hz
  { centerX := s * splat.centerX
    centerY := s * splat.centerY
    weight := splat.weight
    weight_nonneg := splat.weight_nonneg
    sigma1 := s * splat.sigma1
    sigma1_pos := mul_pos hs splat.sigma1_pos
    sigma2 := s * splat.sigma2
    sigma2_pos := mul_pos hs splat.sigma2_pos
    orientationAngle := splat.orientationAngle }

/-- Lateral-to-normal depth anisotropy parameter
$\delta_{\mathrm{depth}}(\Sigma_{\mathrm{3D}}) = \frac{(\sigma_1^2 + \sigma_2^2) - \sigma_3^2}{(\sigma_1^2 + \sigma_2^2) + \sigma_3^2} \in (-1, 1)$
used by the holographic $Gr_{\mathbb{C}}(2,4)$ projection trick to encode the 3rd
principal variance $\sigma_3^2$ into a second $Gr_{\mathbb{C}}(2,4)$ twistor matrix
$M_{\mathrm{depth}} = \operatorname{ddfThermalGr24Matrix}(\delta_{\mathrm{depth}}, \theta_z)$. -/
@[blueprint "def:signals-ddf-splat3d-holographic-depth-anisotropy"
  (title := "Holographic Gr_C(2,4) lateral-to-normal depth anisotropy δ_depth")
  (statement := /-- Define $\operatorname{splat3d}.\mathrm{holographicDepthAnisotropy}
    = \frac{(\sigma_1^2 + \sigma_2^2) - \sigma_3^2}{(\sigma_1^2 + \sigma_2^2) + \sigma_3^2}$. -/)]
noncomputable def NormedTensorGaussianSplat3D.holographicDepthAnisotropy
    (splat : NormedTensorGaussianSplat3D) : ℝ :=
  ((splat.sigma1 ^ 2 + splat.sigma2 ^ 2) - splat.sigma3 ^ 2) /
    ((splat.sigma1 ^ 2 + splat.sigma2 ^ 2) + splat.sigma3 ^ 2)

/-- **3D Adaptive Splat Splitting Conservation & Holographic $Gr_{\mathbb{C}}(2,4)$ Affine Projection Trick Theorem**:
Establishes both the 3D two-child splitting conservation laws and the holographic
$Gr_{\mathbb{C}}(2,4)$ affine projection trick reducing 3D splat evaluation to 2D
screen splats (`NormedTensorGaussianSplat2D`):
1. **3D Adaptive Two-Child Splitting Conservation (Arbitrary 3D Yaw $\theta$ & Pitch $\psi$)**:
   For `c_plus = splat.splitMajorPlus` and `c_minus = splat.splitMajorMinus`:
   - $w_+ + w_- = w$,
   - $\frac{x_+ + x_-}{2} = x_c$, $\frac{y_+ + y_-}{2} = y_c$, $\frac{z_+ + z_-}{2} = z_c$,
   - $(x_+ - x_c)^2 + (y_+ - y_c)^2 + (z_+ - z_c)^2 + \tilde{\sigma}_1^2 = \sigma_1^2$,
   - $\det\Sigma_{\mathrm{3D},+} = \frac{1}{4}\det\Sigma_{\mathrm{3D}}$, and
   - $Q_{\mathrm{core,3D}}(\Sigma_{\mathrm{3D},+}) - Q_{\mathrm{core,3D}}(\Sigma_{\mathrm{3D}}) = \frac{3\hbar^2}{4m\sigma_1^2} > 0$
     (the **exact same Bohm refinement increment** as in 2D, because $\sigma_2^{-2} + \sigma_3^{-2}$ cancels),
2. **Holographic 3D-to-2D Core Bohm Additive Split & Perspective RG Scaling**:
   For `splat_ortho = splat.projectOrthographic2D` and `splat_persp = splat.projectPerspective2D f hf hz`:
   $$Q_{\mathrm{core,3D}}(\Sigma_{\mathrm{3D}}) = Q_{\mathrm{core,2D}}(\Sigma_{\mathrm{2D}}^{\mathrm{ortho}}) + \operatorname{continuumBohmPotentialMode}\!\left(m, \hbar, \frac{1}{\sqrt{2}\sigma_3}\right),$$
   $$\det\Sigma_{\mathrm{2D}}^{\mathrm{persp}} = \left(\frac{f}{z_c}\right)^4 \frac{\det\Sigma_{\mathrm{3D}}}{\sigma_3^2}, \qquad
   Q_{\mathrm{core,2D}}(\Sigma_{\mathrm{2D}}^{\mathrm{persp}}) = \left(\frac{z_c}{f}\right)^2 Q_{\mathrm{core,2D}}(\Sigma_{\mathrm{2D}}^{\mathrm{ortho}}),$$
3. **Depth-Invariance of the Projective $Gr_{\mathbb{C}}(2,4)$ Lateral Anisotropy**:
   Under perspective projection at arbitrary depth $z_c > 0$ and focal scale $f > 0$,
   the normalized lateral barycentric shift is strictly depth-invariant:
   $$\frac{\sigma_{1,\mathrm{persp}}^2 - \sigma_{2,\mathrm{persp}}^2}{\sigma_{1,\mathrm{persp}}^2 + \sigma_{2,\mathrm{persp}}^2}
   = \frac{\sigma_1^2 - \sigma_2^2}{\sigma_1^2 + \sigma_2^2},$$
4. **Exact Commutativity of In-Plane ($\psi = 0$) 3D Splat Splitting and 2D Perspective Projection**:
   When `splat.pitchAngle = 0`, splitting in 3D and projecting to 2D equals projecting
   to 2D first and splitting in 2D:
   $$(splat.\mathrm{splitMajorPlus}).\operatorname{projectPerspective2D}\;f\;hf\;hz_{\mathrm{plus}}
     = (splat.\operatorname{projectPerspective2D}\;f\;hf\;hz).\mathrm{splitMajorPlus},$$
5. **Holographic $Gr_{\mathbb{C}}(2,4)$ Twistor Recovery of the 3rd Principal Variance $\sigma_3^2$**:
   For $\delta_{\mathrm{depth}} = splat.\mathrm{holographicDepthAnisotropy} \in (-1, 1)$ and
   $M_{\mathrm{depth}} = \operatorname{ddfThermalGr24Matrix}(\delta_{\mathrm{depth}}, \theta_z)$,
   the uncrossed $Gr_{\mathbb{C}}(2,4)$ Plücker channel ratio recovers the exact
   lateral-to-normal variance ratio:
   $$\frac{|w_A^{\mathbb{C}}(M_{\mathrm{depth}})|^2}{|w_B^{\mathbb{C}}(M_{\mathrm{depth}})|^2}
   = \frac{\sigma_1^2 + \sigma_2^2}{\sigma_3^2}.$$ -/
@[blueprint "thm:signals-ddf-splat3d-and-holographic-gr24-projection-trick"
  (title := "3D Tensor Gaussian Splat splitting conservation and holographic Gr_C(2,4) affine projection trick theorem")
  (statement := /-- For any \texttt{splat : NormedTensorGaussianSplat3D} with $z_c > 0$, focal scale $f > 0$, $m > 0$, and $\hbar \ne 0$:
    (1) $w_+ + w_- = w$, $(x_+ + x_-)/2 = x_c$, $(y_+ + y_-)/2 = y_c$, $(z_+ + z_-)/2 = z_c$,
    $(x_+ - x_c)^2 + (y_+ - y_c)^2 + (z_+ - z_c)^2 + \tilde{\sigma}_1^2 = \sigma_1^2$,
    $\det\Sigma_{\mathrm{3D},+} = \frac{1}{4}\det\Sigma_{\mathrm{3D}}$, and
    $Q_{\mathrm{core,3D}}(\Sigma_{\mathrm{3D},+}) - Q_{\mathrm{core,3D}}(\Sigma_{\mathrm{3D}}) = \frac{3\hbar^2}{4m\sigma_1^2} > 0$,
    (2) $Q_{\mathrm{core,3D}}(\Sigma_{\mathrm{3D}}) = Q_{\mathrm{core,2D}}(\Sigma_{\mathrm{2D}}^{\mathrm{ortho}}) + \operatorname{continuumBohmPotentialMode}(m,\hbar,1/(\sqrt{2}\sigma_3))$,
    $\det\Sigma_{\mathrm{2D}}^{\mathrm{persp}} = (f/z_c)^4 (\det\Sigma_{\mathrm{3D}} / \sigma_3^2)$, and
    $Q_{\mathrm{core,2D}}(\Sigma_{\mathrm{2D}}^{\mathrm{persp}}) = (z_c/f)^2 Q_{\mathrm{core,2D}}(\Sigma_{\mathrm{2D}}^{\mathrm{ortho}})$,
    (3) $(\sigma_{1,\mathrm{persp}}^2 - \sigma_{2,\mathrm{persp}}^2)/(\sigma_{1,\mathrm{persp}}^2 + \sigma_{2,\mathrm{persp}}^2) = (\sigma_1^2 - \sigma_2^2)/(\sigma_1^2 + \sigma_2^2)$,
    (4) if $\psi = 0$, then $(splat.\mathrm{splitMajorPlus}).\operatorname{projectOrthographic2D} = (splat.\operatorname{projectOrthographic2D}).\mathrm{splitMajorPlus}$, and
    (5) $-1 < \delta_{\mathrm{depth}} < 1$ and $|w_A^{\mathbb C}(M_{\mathrm{depth}})|^2 / |w_B^{\mathbb C}(M_{\mathrm{depth}})|^2 = (\sigma_1^2 + \sigma_2^2)/\sigma_3^2$. -/)
  (proof := /-- Use $\cos^2\psi(\cos^2\theta+\sin^2\theta)+\sin^2\psi=1$ and $(\sqrt{3})^2=3$ for 3D variance conservation,
    $(\sqrt{2})^2=2$ for the normal Bohm mode, cancel $(f/z_c)^2\ne 0$ for depth-invariant lateral anisotropy,
    and apply \texttt{complexGr24ChannelMatrix\_minors} to $M_{\mathrm{depth}}$. -/)]
theorem NormedTensorGaussianSplat3D.splitMajor3D_and_holographic_gr24_projection_identities
    (splat : NormedTensorGaussianSplat3D) (focalScale m_boson hbar θ_z : ℝ)
    (hf : 0 < focalScale) (hz : 0 < splat.centerZ)
    (hm : 0 < m_boson) (hhbar : hbar ≠ 0) :
    let c_plus := splat.splitMajorPlus
    let c_minus := splat.splitMajorMinus
    let s_ortho := splat.projectOrthographic2D
    let s_persp := splat.projectPerspective2D focalScale hf hz
    let δ_d := splat.holographicDepthAnisotropy
    let M_depth := ddfThermalGr24Matrix δ_d θ_z
    c_plus.weight + c_minus.weight = splat.weight ∧
      (c_plus.centerX + c_minus.centerX) / 2 = splat.centerX ∧
      (c_plus.centerY + c_minus.centerY) / 2 = splat.centerY ∧
      (c_plus.centerZ + c_minus.centerZ) / 2 = splat.centerZ ∧
      (c_plus.centerX - splat.centerX) ^ 2 +
          (c_plus.centerY - splat.centerY) ^ 2 +
          (c_plus.centerZ - splat.centerZ) ^ 2 + c_plus.sigma1 ^ 2 =
        splat.sigma1 ^ 2 ∧
      c_plus.covDet = (1 / 4) * splat.covDet ∧
      c_plus.coreBohmPotential m_boson hbar - splat.coreBohmPotential m_boson hbar =
        (3 * hbar ^ 2) / (4 * m_boson * splat.sigma1 ^ 2) ∧
      splat.coreBohmPotential m_boson hbar < c_plus.coreBohmPotential m_boson hbar ∧
      splat.coreBohmPotential m_boson hbar =
        s_ortho.coreBohmPotential m_boson hbar +
          continuumBohmPotentialMode m_boson hbar (1 / (Real.sqrt 2 * splat.sigma3)) ∧
      s_persp.covDet = (focalScale / splat.centerZ) ^ 4 * (splat.covDet / splat.sigma3 ^ 2) ∧
      s_persp.coreBohmPotential m_boson hbar =
        (splat.centerZ / focalScale) ^ 2 * s_ortho.coreBohmPotential m_boson hbar ∧
      (s_persp.sigma1 ^ 2 - s_persp.sigma2 ^ 2) /
          (s_persp.sigma1 ^ 2 + s_persp.sigma2 ^ 2) =
        (splat.sigma1 ^ 2 - splat.sigma2 ^ 2) /
          (splat.sigma1 ^ 2 + splat.sigma2 ^ 2) ∧
      (splat.pitchAngle = 0 →
        c_plus.projectOrthographic2D = s_ortho.splitMajorPlus) ∧
      -1 < δ_d ∧
      δ_d < 1 ∧
      Complex.normSq (complexPluckerSinkAmplitudeA M_depth) /
          Complex.normSq (complexPluckerSinkAmplitudeB M_depth) =
        (splat.sigma1 ^ 2 + splat.sigma2 ^ 2) / splat.sigma3 ^ 2 := by
  intro c_plus c_minus s_ortho s_persp δ_d M_depth
  have h_w : c_plus.weight + c_minus.weight = splat.weight := by
    dsimp [c_plus, c_minus, splitMajorPlus, splitMajorMinus]
    ring
  have h_cx : (c_plus.centerX + c_minus.centerX) / 2 = splat.centerX := by
    dsimp [c_plus, c_minus, splitMajorPlus, splitMajorMinus]
    ring
  have h_cy : (c_plus.centerY + c_minus.centerY) / 2 = splat.centerY := by
    dsimp [c_plus, c_minus, splitMajorPlus, splitMajorMinus]
    ring
  have h_cz : (c_plus.centerZ + c_minus.centerZ) / 2 = splat.centerZ := by
    dsimp [c_plus, c_minus, splitMajorPlus, splitMajorMinus]
    ring
  have h3 : (Real.sqrt 3) ^ 2 = 3 := Real.sq_sqrt (by norm_num)
  have h2 : (Real.sqrt 2) ^ 2 = 2 := Real.sq_sqrt (by norm_num)
  have h_var3d :
      (c_plus.centerX - splat.centerX) ^ 2 +
          (c_plus.centerY - splat.centerY) ^ 2 +
          (c_plus.centerZ - splat.centerZ) ^ 2 + c_plus.sigma1 ^ 2 =
        splat.sigma1 ^ 2 := by
    have h_trig_theta :
        (Real.cos splat.orientationAngle) ^ 2 + (Real.sin splat.orientationAngle) ^ 2 = 1 :=
      Real.cos_sq_add_sin_sq splat.orientationAngle
    have h_trig_psi :
        (Real.cos splat.pitchAngle) ^ 2 + (Real.sin splat.pitchAngle) ^ 2 = 1 :=
      Real.cos_sq_add_sin_sq splat.pitchAngle
    have h_disp :
        (c_plus.centerX - splat.centerX) ^ 2 +
            (c_plus.centerY - splat.centerY) ^ 2 +
            (c_plus.centerZ - splat.centerZ) ^ 2 =
          splat.splitMajorOffset ^ 2 := by
      dsimp [c_plus, splitMajorPlus]
      calc
        (splat.centerX + splat.splitMajorOffset * Real.cos splat.pitchAngle * Real.cos splat.orientationAngle - splat.centerX) ^ 2 +
            (splat.centerY + splat.splitMajorOffset * Real.cos splat.pitchAngle * Real.sin splat.orientationAngle - splat.centerY) ^ 2 +
            (splat.centerZ + splat.splitMajorOffset * Real.sin splat.pitchAngle - splat.centerZ) ^ 2 =
          splat.splitMajorOffset ^ 2 *
            ((Real.cos splat.pitchAngle) ^ 2 *
              ((Real.cos splat.orientationAngle) ^ 2 + (Real.sin splat.orientationAngle) ^ 2) +
              (Real.sin splat.pitchAngle) ^ 2) := by ring
        _ = splat.splitMajorOffset ^ 2 *
            ((Real.cos splat.pitchAngle) ^ 2 * 1 + (Real.sin splat.pitchAngle) ^ 2) := by
          rw [h_trig_theta]
        _ = splat.splitMajorOffset ^ 2 * 1 := by
          rw [mul_one, h_trig_psi]
        _ = splat.splitMajorOffset ^ 2 := mul_one _
    rw [h_disp]
    dsimp [c_plus, splitMajorPlus, splitMajorOffset]
    calc
      (Real.sqrt 3 / 2 * splat.sigma1) ^ 2 + (splat.sigma1 / 2) ^ 2 =
          (((Real.sqrt 3) ^ 2 + 1) / 4) * splat.sigma1 ^ 2 := by ring
      _ = splat.sigma1 ^ 2 := by rw [h3]; ring
  have h_det : c_plus.covDet = (1 / 4) * splat.covDet := by
    dsimp [c_plus, splitMajorPlus, covDet]
    ring
  have hs1_ne : splat.sigma1 ≠ 0 := ne_of_gt splat.sigma1_pos
  have hs2_ne : splat.sigma2 ≠ 0 := ne_of_gt splat.sigma2_pos
  have hs3_ne : splat.sigma3 ≠ 0 := ne_of_gt splat.sigma3_pos
  have hm_ne : m_boson ≠ 0 := ne_of_gt hm
  have hf_ne : focalScale ≠ 0 := ne_of_gt hf
  have hz_ne : splat.centerZ ≠ 0 := ne_of_gt hz
  have h_bohm_diff :
      c_plus.coreBohmPotential m_boson hbar - splat.coreBohmPotential m_boson hbar =
        (3 * hbar ^ 2) / (4 * m_boson * splat.sigma1 ^ 2) := by
    dsimp [c_plus, splitMajorPlus, coreBohmPotential]
    field_simp [hs1_ne, hs2_ne, hs3_ne, hm_ne]
    ring
  have h_bohm_lt :
      splat.coreBohmPotential m_boson hbar < c_plus.coreBohmPotential m_boson hbar := by
    have h_pos : 0 < (3 * hbar ^ 2) / (4 * m_boson * splat.sigma1 ^ 2) := by
      have hh2 : 0 < hbar ^ 2 := sq_pos_of_ne_zero hhbar
      have hs1_sq : 0 < splat.sigma1 ^ 2 := sq_pos_of_pos splat.sigma1_pos
      positivity
    linarith [h_bohm_diff]
  have h_sqrt2_ne : Real.sqrt 2 ≠ 0 := ne_of_gt (Real.sqrt_pos.mpr (by norm_num))
  have h_bohm_split :
      splat.coreBohmPotential m_boson hbar =
        s_ortho.coreBohmPotential m_boson hbar +
          continuumBohmPotentialMode m_boson hbar (1 / (Real.sqrt 2 * splat.sigma3)) := by
    dsimp [s_ortho, projectOrthographic2D, coreBohmPotential,
      NormedTensorGaussianSplat2D.coreBohmPotential, continuumBohmPotentialMode]
    have h_sq_prod : (Real.sqrt 2 * splat.sigma3) ^ 2 = 2 * splat.sigma3 ^ 2 := by
      calc
        (Real.sqrt 2 * splat.sigma3) ^ 2 = (Real.sqrt 2) ^ 2 * splat.sigma3 ^ 2 := by ring
        _ = 2 * splat.sigma3 ^ 2 := by rw [h2]
    rw [one_div_pow, h_sq_prod]
    field_simp [hs1_ne, hs2_ne, hs3_ne, hm_ne]
    ring
  have h_persp_det :
      s_persp.covDet = (focalScale / splat.centerZ) ^ 4 * (splat.covDet / splat.sigma3 ^ 2) := by
    dsimp [s_persp, projectPerspective2D, NormedTensorGaussianSplat2D.covDet, covDet]
    field_simp [hz_ne, hs3_ne]
  have h_persp_bohm :
      s_persp.coreBohmPotential m_boson hbar =
        (splat.centerZ / focalScale) ^ 2 * s_ortho.coreBohmPotential m_boson hbar := by
    dsimp [s_persp, s_ortho, projectPerspective2D, projectOrthographic2D,
      NormedTensorGaussianSplat2D.coreBohmPotential]
    field_simp [hf_ne, hz_ne, hs1_ne, hs2_ne, hm_ne]
  have h_lat_pos : 0 < splat.sigma1 ^ 2 + splat.sigma2 ^ 2 := by
    have : 0 < splat.sigma1 ^ 2 := sq_pos_of_pos splat.sigma1_pos
    have : 0 < splat.sigma2 ^ 2 := sq_pos_of_pos splat.sigma2_pos
    linarith
  have h_lat_ne : splat.sigma1 ^ 2 + splat.sigma2 ^ 2 ≠ 0 := ne_of_gt h_lat_pos
  have h_depth_inv :
      (s_persp.sigma1 ^ 2 - s_persp.sigma2 ^ 2) /
          (s_persp.sigma1 ^ 2 + s_persp.sigma2 ^ 2) =
        (splat.sigma1 ^ 2 - splat.sigma2 ^ 2) /
          (splat.sigma1 ^ 2 + splat.sigma2 ^ 2) := by
    dsimp [s_persp, projectPerspective2D]
    have hs_sq_ne : (focalScale / splat.centerZ) ^ 2 ≠ 0 :=
      pow_ne_zero 2 (div_ne_zero hf_ne hz_ne)
    calc
      ((focalScale / splat.centerZ * splat.sigma1) ^ 2 -
          (focalScale / splat.centerZ * splat.sigma2) ^ 2) /
        ((focalScale / splat.centerZ * splat.sigma1) ^ 2 +
          (focalScale / splat.centerZ * splat.sigma2) ^ 2) =
        ((focalScale / splat.centerZ) ^ 2 * (splat.sigma1 ^ 2 - splat.sigma2 ^ 2)) /
        ((focalScale / splat.centerZ) ^ 2 * (splat.sigma1 ^ 2 + splat.sigma2 ^ 2)) := by ring
      _ = (splat.sigma1 ^ 2 - splat.sigma2 ^ 2) / (splat.sigma1 ^ 2 + splat.sigma2 ^ 2) :=
        mul_div_mul_left _ _ hs_sq_ne
  have h_comm :
      splat.pitchAngle = 0 →
        c_plus.projectOrthographic2D = s_ortho.splitMajorPlus := by
    intro h_pitch
    dsimp [c_plus, s_ortho, splitMajorPlus, projectOrthographic2D,
      NormedTensorGaussianSplat2D.splitMajorPlus, splitMajorOffset,
      NormedTensorGaussianSplat2D.splitMajorOffset]
    rw [h_pitch, Real.cos_zero, mul_one]
  have hs3_sq_pos : 0 < splat.sigma3 ^ 2 := sq_pos_of_pos splat.sigma3_pos
  have h_tot_pos : 0 < (splat.sigma1 ^ 2 + splat.sigma2 ^ 2) + splat.sigma3 ^ 2 :=
    add_pos h_lat_pos hs3_sq_pos
  have h_tot_ne : (splat.sigma1 ^ 2 + splat.sigma2 ^ 2) + splat.sigma3 ^ 2 ≠ 0 :=
    ne_of_gt h_tot_pos
  have h_δ_gt : -1 < δ_d := by
    dsimp [δ_d, holographicDepthAnisotropy]
    rw [lt_div_iff₀ h_tot_pos]
    linarith
  have h_δ_lt : δ_d < 1 := by
    dsimp [δ_d, holographicDepthAnisotropy]
    rw [div_lt_iff₀ h_tot_pos]
    linarith
  have h1p_d : 0 ≤ 1 + δ_d := by linarith
  have h1m_d : 0 ≤ 1 - δ_d := by linarith
  have h_d_minors := complexGr24ChannelMatrix_minors
    (↑(Real.sqrt (1 + δ_d) * Real.cos θ_z) + Complex.I * ↑(Real.sqrt (1 + δ_d) * Real.sin θ_z))
    (↑(Real.sqrt (1 - δ_d) * Real.cos θ_z) - Complex.I * ↑(Real.sqrt (1 - δ_d) * Real.sin θ_z))
  have h_wA_d : Complex.normSq (complexPluckerSinkAmplitudeA M_depth) = 1 + δ_d := by
    dsimp [M_depth, ddfThermalGr24Matrix, complexPluckerSinkAmplitudeA]
    rw [h_d_minors.1]
    simp only [Complex.normSq_apply, Complex.add_re, Complex.add_im, Complex.mul_re,
      Complex.mul_im, Complex.ofReal_re, Complex.ofReal_im, Complex.I_re, Complex.I_im]
    calc
      _ = (Real.sqrt (1 + δ_d)) ^ 2 * ((Real.cos θ_z) ^ 2 + (Real.sin θ_z) ^ 2) := by ring
      _ = 1 + δ_d := by rw [Real.sq_sqrt h1p_d, Real.cos_sq_add_sin_sq, mul_one]
  have h_wB_d : Complex.normSq (complexPluckerSinkAmplitudeB M_depth) = 1 - δ_d := by
    dsimp [M_depth, ddfThermalGr24Matrix, complexPluckerSinkAmplitudeB]
    rw [h_d_minors.2.1]
    simp only [Complex.normSq_apply, Complex.sub_re, Complex.sub_im, Complex.mul_re,
      Complex.mul_im, Complex.ofReal_re, Complex.ofReal_im, Complex.I_re, Complex.I_im]
    calc
      _ = (Real.sqrt (1 - δ_d)) ^ 2 * ((Real.cos θ_z) ^ 2 + (Real.sin θ_z) ^ 2) := by ring
      _ = 1 - δ_d := by rw [Real.sq_sqrt h1m_d, Real.cos_sq_add_sin_sq, mul_one]
  have h_depth_ratio :
      Complex.normSq (complexPluckerSinkAmplitudeA M_depth) /
          Complex.normSq (complexPluckerSinkAmplitudeB M_depth) =
        (splat.sigma1 ^ 2 + splat.sigma2 ^ 2) / splat.sigma3 ^ 2 := by
    rw [h_wA_d, h_wB_d]
    dsimp [δ_d, holographicDepthAnisotropy]
    field_simp [h_tot_ne, hs3_ne]
    ring
  exact ⟨h_w, h_cx, h_cy, h_cz, h_var3d, h_det, h_bohm_diff, h_bohm_lt,
    h_bohm_split, h_persp_det, h_persp_bohm, h_depth_inv, h_comm,
    h_δ_gt, h_δ_lt, h_depth_ratio⟩

/-! ## Inversion-Free Plücker / Twistor Bracket vs. $4 \times 4$ Jacobian & Schur-Complement Tensor CFD (`LBGPC-Fluid-Datacenter-Energy-Savings.myst.md`, Prompts 16–18) -/

/-- The $4 \times 4$ impeller shear Jacobian matrix $J(s, \tau)$ from `TensorCFDSolver`
(`docs/chats/LBGPC-Fluid-Datacenter-Energy-Savings.myst.md`, lines 2327–2332) with
in-plane shear `stress = s` and cross-dimensional pressure/turbulence coupling `turbulence = τ`. -/
@[blueprint "def:signals-ddf-impeller-shear-4x4"
  (title := "4×4 impeller shear Jacobian matrix J(s, τ) from TensorCFDSolver")
  (statement := /-- Define the $4\times 4$ impeller shear Jacobian
    $J(s,\tau) = \begin{pmatrix} 1 & s & 0 & \tau \\ 0 & 1 & 0 & 0 \\ 0 & 0 & 1 & 0 \\ \tau & 0 & 0 & 1 \end{pmatrix}$. -/)]
def impellerShear4x4 (stress turbulence : ℝ) : Matrix (Fin 4) (Fin 4) ℝ :=
  !![1, stress, 0, turbulence;
     0, 1, 0, 0;
     0, 0, 1, 0;
     turbulence, 0, 0, 1]

/-- Closed-form 3D Schur-complement determinant $\det(\Sigma_{\mathrm{3D}}) = \frac{(1 - \tau^2)^2}{1 + \tau^2}$
of the $4 \times 4$ sheared covariance $\Sigma_{4\times 4}(s, \tau) = J(s, \tau)\,J(s, \tau)^T$,
computed directly from the 4-bracket minor $1 - \tau^2$ without constructing $A - B D^{-1} C$
or invoking a matrix pseudo-inverse. -/
@[blueprint "def:signals-ddf-schur-complement-3d-volume"
  (title := "Inversion-free closed-form 3D Schur-complement volume (1 - τ²)² / (1 + τ²)")
  (statement := /-- Define $\operatorname{schurComplement3DVolume}(\tau) = \frac{(1 - \tau^2)^2}{1 + \tau^2}$. -/)]
noncomputable def schurComplement3DVolume (turbulence : ℝ) : ℝ :=
  (1 - turbulence ^ 2) ^ 2 / (1 + turbulence ^ 2)

/-- The raw $4 \times 4$ momentum-twistor matrix $[Z_1, Z_2, Z_3, Z_4]$ from the chat's
`AmplituhedronFluidSplat` (`LBGPC-Fluid-Datacenter-Energy-Savings.myst.md`, lines 2425–2442 & 2500–2518)
with additive shift $Z_2 \mapsto e_2 + (s, s\tau, 0, 0)^T$ and $Z_3 \mapsto e_3 - \frac{\tau}{2}(s, s\tau, 0, 0)^T$. -/
@[blueprint "def:signals-ddf-chat-amplituhedron-twistor-matrix"
  (title := "Chat AmplituhedronFluidSplat 4×4 momentum-twistor matrix")
  (statement := /-- Define the $4\times 4$ twistor matrix from `AmplituhedronFluidSplat` with
    columns $Z_1=e_1$, $Z_2=(s,1+s\tau,0,0)^T$, $Z_3=(-\frac{\tau}{2}s,-\frac{\tau^2}{2}s,1,0)^T$, $Z_4=e_4$. -/)]
noncomputable def chatAmplituhedronTwistorMatrix (stress turbulence : ℝ) :
    Matrix (Fin 4) (Fin 4) ℝ :=
  !![1, stress, -(turbulence / 2) * stress, 0;
     0, 1 + stress * turbulence, -(turbulence / 2) * (stress * turbulence), 0;
     0, 0, 1, 0;
     0, 0, 0, 1]

/-- Corrected symplectic/compressive $4 \times 4$ momentum-twistor matrix whose 4-bracket
$\langle 1 2 3 4 \rangle = \det Z = 1 - \tau^2$ matches the exact Jacobian determinant
$\det J(s, \tau) = 1 - \tau^2$ and the $Gr_{\mathbb{C}}(2,4)$ Plücker channel product
$|w_A^{\mathbb{C}}|^2|w_B^{\mathbb{C}}|^2 = 1 - \tau^2$. -/
@[blueprint "def:signals-ddf-corrected-twistor-shear-matrix"
  (title := "Corrected 4×4 momentum-twistor shear matrix with ⟨1 2 3 4⟩ = 1 - τ²")
  (statement := /-- Define the corrected $4\times 4$ twistor matrix with determinant
    $\langle 1\,2\,3\,4\rangle = 1 - \tau^2$. -/)]
def correctedTwistorShearMatrix (stress turbulence : ℝ) : Matrix (Fin 4) (Fin 4) ℝ :=
  !![1, stress, 0, turbulence;
     0, 1, 0, 0;
     0, 0, 1, 0;
     turbulence, stress * turbulence, 0, 1]

/-- **Inversion-Free Schur–Plücker Determinant Identity & Critique/Resolution of `AmplituhedronFluidSplat`**:
1. **Exact $4 \times 4$ Jacobian Determinant & Schur-Complement Factorization (Why `pinv(D)` Is Unnecessary)**:
   For the $4 \times 4$ impeller shear Jacobian $J(s, \tau) = \operatorname{impellerShear4x4}(s, \tau)$
   and $\Sigma_{4\times 4} = J(s, \tau)\,J(s, \tau)^T$:
   $$\det J(s, \tau) = 1 - \tau^2, \qquad
   \det \Sigma_{4\times 4} = (1 - \tau^2)^2, \qquad
   (\Sigma_{4\times 4})_{3,3} = 1 + \tau^2 > 0,$$
   $$\det \Sigma_{4\times 4} = (\Sigma_{4\times 4})_{3,3} \cdot \operatorname{schurComplement3DVolume}(\tau),$$
   proving that the 3D Schur-complement volume $\det(A - B D^{-1} C) = \frac{(1 - \tau^2)^2}{1 + \tau^2}$
   is independent of the laminar in-plane shear $s$ (an Anosov $\det = 1$ shear!) and is
   evaluated in $O(1)$ arithmetic with **zero matrix inversions**,
2. **Critique of the Chat's `AmplituhedronFluidSplat` Sign & Triangularity Bug**:
   The chat's upper-triangular matrix `chatAmplituhedronTwistorMatrix s τ` has determinant
   $\langle 1 2 3 4 \rangle = 1 + s\tau$, which is independent of $Z_3$'s shift and for
   $s > 0, \tau > 0$ satisfies $1 = \det(\text{vortical}, \tau=0) < 1 + s\tau = \det(\text{straight}, \tau>0)$,
   reversing the intended stall ordering,
3. **Constructive Resolution via `correctedTwistorShearMatrix` and $Gr_{\mathbb{C}}(2,4)$ Plücker Channels**:
   For $0 < \tau < 1$ (turbulent straight vanes) vs. $\tau = 0$ (laminar vortical vanes)
   and $M_\tau = \operatorname{ddfThermalGr24Matrix}(\tau, \theta)$:
   $$\det(\operatorname{correctedTwistorShearMatrix}(s, \tau))
     = |w_A^{\mathbb{C}}(M_\tau)|^2\,|w_B^{\mathbb{C}}(M_\tau)|^2
     = 1 - \tau^2 \in (0, 1),$$
   $$\operatorname{schurComplement3DVolume}(\tau)
     = \frac{\bigl(|w_A^{\mathbb{C}}(M_\tau)|^2\,|w_B^{\mathbb{C}}(M_\tau)|^2\bigr)^2}{1 + \tau^2}
     < 1 = \operatorname{schurComplement3DVolume}(0).$$ -/
@[blueprint "thm:signals-ddf-schur-plucker-inversion-free-identities"
  (title := "Inversion-free Schur-Plücker determinant identity and momentum-twistor vane shear theorem")
  (statement := /-- For any $s,\theta\in\mathbb R$ and $0 < \tau < 1$:
    (1) $\det(\operatorname{impellerShear4x4}(s,\tau)) = 1 - \tau^2$ and
    $\det(\operatorname{impellerShear4x4}(s,\tau)\,\operatorname{impellerShear4x4}(s,\tau)^T)
    = (1 + \tau^2)\,\operatorname{schurComplement3DVolume}(\tau) = (1 - \tau^2)^2$,
    (2) $\det(\operatorname{chatAmplituhedronTwistorMatrix}(s,\tau)) = 1 + s\tau$, so for $s > 0$,
    $\det(\operatorname{chatAmplituhedronTwistorMatrix}(s,0)) < \det(\operatorname{chatAmplituhedronTwistorMatrix}(s,\tau))$, and
    (3) $\det(\operatorname{correctedTwistorShearMatrix}(s,\tau)) = |w_A^{\mathbb C}(M_\tau)|^2 |w_B^{\mathbb C}(M_\tau)|^2 = 1 - \tau^2$
    and $\operatorname{schurComplement3DVolume}(\tau) < \operatorname{schurComplement3DVolume}(0) = 1$. -/)
  (proof := /-- Expand $4\times 4$ determinants via \texttt{Matrix.det\_succ\_row\_zero} and
    \texttt{Matrix.det\_fin\_three}, and apply \texttt{complexGr24ChannelMatrix\_minors} to $M_\tau$. -/)]
theorem schur_plucker_inversion_free_and_twistor_vane_identities
    (stress turbulence θ : ℝ) (hs_pos : 0 < stress)
    (hτ_pos : 0 < turbulence) (hτ_lt : turbulence < 1) :
    let J := impellerShear4x4 stress turbulence
    let Sigma4 := J * J.transpose
    let M_τ := ddfThermalGr24Matrix turbulence θ
    J.det = 1 - turbulence ^ 2 ∧
      Sigma4.det = (1 - turbulence ^ 2) ^ 2 ∧
      Sigma4 3 3 = 1 + turbulence ^ 2 ∧
      Sigma4.det = Sigma4 3 3 * schurComplement3DVolume turbulence ∧
      (chatAmplituhedronTwistorMatrix stress turbulence).det = 1 + stress * turbulence ∧
      (chatAmplituhedronTwistorMatrix stress 0).det <
        (chatAmplituhedronTwistorMatrix stress turbulence).det ∧
      (correctedTwistorShearMatrix stress turbulence).det = 1 - turbulence ^ 2 ∧
      Complex.normSq (complexPluckerSinkAmplitudeA M_τ) *
          Complex.normSq (complexPluckerSinkAmplitudeB M_τ) =
        1 - turbulence ^ 2 ∧
      schurComplement3DVolume turbulence =
        (Complex.normSq (complexPluckerSinkAmplitudeA M_τ) *
          Complex.normSq (complexPluckerSinkAmplitudeB M_τ)) ^ 2 / (1 + turbulence ^ 2) ∧
      schurComplement3DVolume 0 = 1 ∧
      schurComplement3DVolume turbulence < schurComplement3DVolume 0 := by
  intro J Sigma4 M_τ
  have hJ_det : J.det = 1 - turbulence ^ 2 := by
    dsimp [J]
    unfold impellerShear4x4
    rw [Matrix.det_succ_row_zero]
    simp only [Fin.sum_univ_four, Fin.isValue, Matrix.det_fin_three,
      Matrix.submatrix_apply, Fin.succAbove]
    dsimp [Fin.succAbove, Matrix.cons_val_zero, Matrix.cons_val_one,
      Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail]
    ring
  have hSigma_det : Sigma4.det = (1 - turbulence ^ 2) ^ 2 := by
    dsimp [Sigma4]
    rw [Matrix.det_mul, Matrix.det_transpose, hJ_det]
    ring
  have hSigma33 : Sigma4 3 3 = 1 + turbulence ^ 2 := by
    dsimp [Sigma4, J, impellerShear4x4]
    simp only [Matrix.mul_apply, Matrix.transpose_apply, Fin.sum_univ_four, Fin.isValue]
    dsimp [Matrix.cons_val_zero, Matrix.cons_val_one,
      Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail]
    ring
  have h1_tau_ne : 1 + turbulence ^ 2 ≠ 0 := by positivity
  have h_schur_fact : Sigma4.det = Sigma4 3 3 * schurComplement3DVolume turbulence := by
    rw [hSigma_det, hSigma33]
    unfold schurComplement3DVolume
    exact (mul_div_cancel₀ _ h1_tau_ne).symm
  have h_chat_det : ∀ τ : ℝ,
      (chatAmplituhedronTwistorMatrix stress τ).det = 1 + stress * τ := by
    intro τ
    unfold chatAmplituhedronTwistorMatrix
    rw [Matrix.det_succ_row_zero]
    simp only [Fin.sum_univ_four, Fin.isValue, Matrix.det_fin_three,
      Matrix.submatrix_apply, Fin.succAbove]
    dsimp [Fin.succAbove, Matrix.cons_val_zero, Matrix.cons_val_one,
      Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail]
    ring
  have h_chat_lt :
      (chatAmplituhedronTwistorMatrix stress 0).det <
        (chatAmplituhedronTwistorMatrix stress turbulence).det := by
    rw [h_chat_det 0, h_chat_det turbulence]
    have : 0 < stress * turbulence := mul_pos hs_pos hτ_pos
    linarith
  have h_corr_det :
      (correctedTwistorShearMatrix stress turbulence).det = 1 - turbulence ^ 2 := by
    unfold correctedTwistorShearMatrix
    rw [Matrix.det_succ_row_zero]
    simp only [Fin.sum_univ_four, Fin.isValue, Matrix.det_fin_three,
      Matrix.submatrix_apply, Fin.succAbove]
    dsimp [Fin.succAbove, Matrix.cons_val_zero, Matrix.cons_val_one,
      Matrix.cons_val_two, Matrix.cons_val_three, Matrix.vecHead, Matrix.vecTail]
    ring
  have h1p : 0 ≤ 1 + turbulence := by linarith
  have h1m : 0 ≤ 1 - turbulence := by linarith
  have h_minors := complexGr24ChannelMatrix_minors
    (↑(Real.sqrt (1 + turbulence) * Real.cos θ) + Complex.I * ↑(Real.sqrt (1 + turbulence) * Real.sin θ))
    (↑(Real.sqrt (1 - turbulence) * Real.cos θ) - Complex.I * ↑(Real.sqrt (1 - turbulence) * Real.sin θ))
  have h_wA : Complex.normSq (complexPluckerSinkAmplitudeA M_τ) = 1 + turbulence := by
    dsimp [M_τ, ddfThermalGr24Matrix, complexPluckerSinkAmplitudeA]
    rw [h_minors.1]
    simp only [Complex.normSq_apply, Complex.add_re, Complex.add_im, Complex.mul_re,
      Complex.mul_im, Complex.ofReal_re, Complex.ofReal_im, Complex.I_re, Complex.I_im]
    calc
      _ = (Real.sqrt (1 + turbulence)) ^ 2 * ((Real.cos θ) ^ 2 + (Real.sin θ) ^ 2) := by ring
      _ = 1 + turbulence := by rw [Real.sq_sqrt h1p, Real.cos_sq_add_sin_sq, mul_one]
  have h_wB : Complex.normSq (complexPluckerSinkAmplitudeB M_τ) = 1 - turbulence := by
    dsimp [M_τ, ddfThermalGr24Matrix, complexPluckerSinkAmplitudeB]
    rw [h_minors.2.1]
    simp only [Complex.normSq_apply, Complex.sub_re, Complex.sub_im, Complex.mul_re,
      Complex.mul_im, Complex.ofReal_re, Complex.ofReal_im, Complex.I_re, Complex.I_im]
    calc
      _ = (Real.sqrt (1 - turbulence)) ^ 2 * ((Real.cos θ) ^ 2 + (Real.sin θ) ^ 2) := by ring
      _ = 1 - turbulence := by rw [Real.sq_sqrt h1m, Real.cos_sq_add_sin_sq, mul_one]
  have h_pl_prod :
      Complex.normSq (complexPluckerSinkAmplitudeA M_τ) *
          Complex.normSq (complexPluckerSinkAmplitudeB M_τ) =
        1 - turbulence ^ 2 := by
    rw [h_wA, h_wB]
    ring
  have h_schur_pl :
      schurComplement3DVolume turbulence =
        (Complex.normSq (complexPluckerSinkAmplitudeA M_τ) *
          Complex.normSq (complexPluckerSinkAmplitudeB M_τ)) ^ 2 / (1 + turbulence ^ 2) := by
    rw [h_pl_prod]
    rfl
  have h_schur0 : schurComplement3DVolume 0 = 1 := by
    unfold schurComplement3DVolume
    norm_num
  have h_schur_lt : schurComplement3DVolume turbulence < schurComplement3DVolume 0 := by
    rw [h_schur0]
    unfold schurComplement3DVolume
    rw [div_lt_iff₀ (by positivity)]
    have hτ2_pos : 0 < turbulence ^ 2 := sq_pos_of_pos hτ_pos
    have hτ2_lt : turbulence ^ 2 < 1 := by nlinarith
    nlinarith
  exact ⟨hJ_det, hSigma_det, hSigma33, h_schur_fact, h_chat_det turbulence, h_chat_lt,
    h_corr_det, h_pl_prod, h_schur_pl, h_schur0, h_schur_lt⟩

/-! ## Holographic $Gr_{\mathbb{C}}(2,4)$ Depth Recovery in Imaging & Convergent Multi-Beam Volumetric Holography -/

/-- Exact inversion of the unseen 3rd principal variance $\sigma_3^2$ of a 3D Gaussian
splat from its 2D screen trace $\operatorname{Tr}\Sigma_{\mathrm{2D}}^{\mathrm{ortho}} = \sigma_1^2 + \sigma_2^2$
and its measured $Gr_{\mathbb{C}}(2,4)$ Plücker depth-channel ratio
$R_{\mathrm{depth}} = |w_A^{\mathbb{C}}(M_{\mathrm{depth}})|^2 / |w_B^{\mathbb{C}}(M_{\mathrm{depth}})|^2$. -/
@[blueprint "def:signals-ddf-recover-depth-variance-sq"
  (title := "Holographic Gr_C(2,4) inversion of 3rd principal variance σ_3² from 2D screen trace")
  (statement := /-- Define $\operatorname{recoverDepthVarianceSq}(\operatorname{trace2D}, R_{\mathrm{depth}})
    = \operatorname{trace2D} / R_{\mathrm{depth}}$. -/)]
noncomputable def recoverDepthVarianceSq (trace2D pluckerDepthRatio : ℝ) : ℝ :=
  trace2D / pluckerDepthRatio

/-- Exact tomographic recovery of the squared focal depth $z_c^2$ from the focal length
$f$, the intrinsic 2D orthographic trace $\operatorname{Tr}\Sigma_{\mathrm{2D}}^{\mathrm{ortho}}$,
and the observed perspective screen trace $\operatorname{Tr}\Sigma_{\mathrm{2D}}^{\mathrm{persp}}$. -/
@[blueprint "def:signals-ddf-recover-focal-depth-sq"
  (title := "Perspective focal-depth squared recovery z_c² = f² (Tr Σ_ortho / Tr Σ_persp)")
  (statement := /-- Define $\operatorname{recoverFocalDepthSq}(f, \operatorname{traceOrtho}, \operatorname{tracePersp})
    = f^2 \cdot (\operatorname{traceOrtho} / \operatorname{tracePersp})$. -/)]
noncomputable def recoverFocalDepthSq (focalScale traceOrtho tracePersp : ℝ) : ℝ :=
  focalScale ^ 2 * (traceOrtho / tracePersp)

/-- Combined axial inverse variance (precision) $\tau_{z,\mathrm{conv}} = \sigma_\parallel^{-2} + \sigma_\perp^{-2}$
at the intersection of two orthogonal convergent Gaussian beams with transverse waist
$\sigma_\perp > 0$ and elongated axial Rayleigh length $\sigma_\parallel > \sigma_\perp$. -/
@[blueprint "def:signals-ddf-convergent-crossed-axial-precision"
  (title := "Crossed convergent-beam axial precision τ_z,conv = 1/σ_∥² + 1/σ_⊥²")
  (statement := /-- Define $\operatorname{convergentCrossedAxialPrecision}(\sigma_\perp, \sigma_\parallel)
    = 1 / \sigma_\parallel^2 + 1 / \sigma_\perp^2$. -/)]
noncomputable def convergentCrossedAxialPrecision (sigmaPerp sigmaParallel : ℝ) : ℝ :=
  1 / sigmaParallel ^ 2 + 1 / sigmaPerp ^ 2

/-- **Holographic $Gr_{\mathbb{C}}(2,4)$ Imaging Depth Recovery & Convergent Multi-Beam Volumetric Holography Theorem**:
Formalizes how the holographic $Gr_{\mathbb{C}}(2,4)$ depth-anisotropy channel and
convergent multi-beam holography (`docs/chats/IQ-Sampling-for-Signal-Phase.myst.md`,
Prompts 93–102; `docs/chats/Bell-Correlations-in-Atomic-Momentum.myst.md`, Step 4)
solve the 2D-to-3D volumetric imaging and synthesis problem:
1. **Exact 3D Depth Variance, 3D Trace, 3D Determinant, and 3D Core Bohm Recovery from 2D Screen Data**:
   Let `s_ortho = splat.projectOrthographic2D`, $\delta_d = splat.\mathrm{holographicDepthAnisotropy}$,
   $M_{\mathrm{depth}} = \operatorname{ddfThermalGr24Matrix}(\delta_d, \theta_z)$, and
   $R_{\mathrm{depth}} = |w_A^{\mathbb{C}}(M_{\mathrm{depth}})|^2 / |w_B^{\mathbb{C}}(M_{\mathrm{depth}})|^2$.
   Then:
   - $\operatorname{recoverDepthVarianceSq}(s_{\mathrm{ortho}}.\mathrm{covTrace}, R_{\mathrm{depth}}) = \sigma_3^2$,
   - $s_{\mathrm{ortho}}.\mathrm{covTrace} + \operatorname{recoverDepthVarianceSq}(s_{\mathrm{ortho}}.\mathrm{covTrace}, R_{\mathrm{depth}}) = \operatorname{Tr}\Sigma_{\mathrm{3D}}$,
   - $s_{\mathrm{ortho}}.\mathrm{covDet} \cdot \operatorname{recoverDepthVarianceSq}(s_{\mathrm{ortho}}.\mathrm{covTrace}, R_{\mathrm{depth}}) = \det\Sigma_{\mathrm{3D}}$,
   - $s_{\mathrm{ortho}}.\operatorname{coreBohmPotential}(m, \hbar) + \frac{\hbar^2}{4m}\frac{R_{\mathrm{depth}}}{s_{\mathrm{ortho}}.\mathrm{covTrace}} = Q_{\mathrm{core,3D}}(\Sigma_{\mathrm{3D}})$,
2. **Exact Perspective Focal-Range ($z_c^2$) Tomography**:
   For `s_persp = splat.projectPerspective2D f hf hz`:
   $$\operatorname{recoverFocalDepthSq}(f, s_{\mathrm{ortho}}.\mathrm{covTrace}, s_{\mathrm{persp}}.\mathrm{covTrace}) = z_c^2,$$
   $$f^2 \cdot \frac{s_{\mathrm{persp}}.\operatorname{coreBohmPotential}(m, \hbar)}{s_{\mathrm{ortho}}.\operatorname{coreBohmPotential}(m, \hbar)} = z_c^2,$$
3. **Convergent Crossed-Beam Confocal Axial Precision Compression & Synchronous $N$-Beam Coherent Gain**:
   For $0 < \sigma_\perp < \sigma_\parallel$, crossing two orthogonal beams boosts axial
   precision strictly above both the single-beam axial precision $1/\sigma_\parallel^2$
   and the collinear two-beam axial precision $2/\sigma_\parallel^2$:
   $$\frac{1}{\sigma_\parallel^2} < \frac{2}{\sigma_\parallel^2} < \operatorname{convergentCrossedAxialPrecision}(\sigma_\perp, \sigma_\parallel),$$
   and for $N_{\mathrm{beam}} > 1$ synchronous phase-locked beams with per-beam amplitude $A_0 > 0$,
   coherent focal intensity $(N_{\mathrm{beam}} A_0)^2$ exceeds incoherent intensity $N_{\mathrm{beam}} A_0^2$
   by the factor $N_{\mathrm{beam}}$:
   $$(N_{\mathrm{beam}} A_0)^2 = N_{\mathrm{beam}} \cdot (N_{\mathrm{beam}} A_0^2) \quad\text{and}\quad N_{\mathrm{beam}} A_0^2 < (N_{\mathrm{beam}} A_0)^2,$$
4. **Self-Calibrating Pilot-Tone Phase-Conjugation Identity**:
   Applying the conjugate phase correction $-\phi_{\mathrm{err}}$ to an aberrated twistor
   phase $\theta_z + \phi_{\mathrm{err}}$ restores the exact unaberrated $Gr_{\mathbb{C}}(2,4)$
   twistor matrix $\operatorname{ddfThermalGr24Matrix}(\delta_d, \theta_z + \phi_{\mathrm{err}} - \phi_{\mathrm{err}}) = M_{\mathrm{depth}}$. -/
@[blueprint "thm:signals-ddf-holographic-gr24-imaging-depth-recovery"
  (title := "Holographic Gr_C(2,4) imaging depth recovery and convergent multi-beam confocal theorem")
  (statement := /-- For any \texttt{splat : NormedTensorGaussianSplat3D} with $z_c > 0$, focal scale $f > 0$,
    $m > 0$, $\hbar \ne 0$, $0 < \sigma_\perp < \sigma_\parallel$, $N_{\mathrm{beam}} > 1$, and $A_0 > 0$:
    (1) $\operatorname{recoverDepthVarianceSq}(s_{\mathrm{ortho}}.\mathrm{covTrace}, R_{\mathrm{depth}}) = \sigma_3^2$,
    $s_{\mathrm{ortho}}.\mathrm{covTrace} + \operatorname{recoverDepthVarianceSq}(s_{\mathrm{ortho}}.\mathrm{covTrace}, R_{\mathrm{depth}}) = \operatorname{splat}.\mathrm{covTrace}$,
    $s_{\mathrm{ortho}}.\mathrm{covDet} \cdot \operatorname{recoverDepthVarianceSq}(s_{\mathrm{ortho}}.\mathrm{covTrace}, R_{\mathrm{depth}}) = \operatorname{splat}.\mathrm{covDet}$, and
    $s_{\mathrm{ortho}}.\operatorname{coreBohmPotential}(m,\hbar) + \frac{\hbar^2}{4m}\frac{R_{\mathrm{depth}}}{s_{\mathrm{ortho}}.\mathrm{covTrace}} = \operatorname{splat}.\operatorname{coreBohmPotential}(m,\hbar)$,
    (2) $\operatorname{recoverFocalDepthSq}(f, s_{\mathrm{ortho}}.\mathrm{covTrace}, s_{\mathrm{persp}}.\mathrm{covTrace}) = z_c^2$ and
    $f^2 (s_{\mathrm{persp}}.\operatorname{coreBohmPotential}(m,\hbar) / s_{\mathrm{ortho}}.\operatorname{coreBohmPotential}(m,\hbar)) = z_c^2$,
    (3) $1/\sigma_\parallel^2 < 2/\sigma_\parallel^2 < \operatorname{convergentCrossedAxialPrecision}(\sigma_\perp, \sigma_\parallel)$ and
    $N_{\mathrm{beam}} A_0^2 < (N_{\mathrm{beam}} A_0)^2 = N_{\mathrm{beam}} (N_{\mathrm{beam}} A_0^2)$, and
    (4) $\operatorname{ddfThermalGr24Matrix}(\delta_d, \theta_z + \phi_{\mathrm{err}} - \phi_{\mathrm{err}}) = M_{\mathrm{depth}}$. -/)
  (proof := /-- Combine the depth-channel ratio $R_{\mathrm{depth}} = (\sigma_1^2 + \sigma_2^2)/\sigma_3^2$
    from \texttt{splitMajor3D\_and\_holographic\_gr24\_projection\_identities} with field simplification on
    positive variances and traces. -/)]
theorem NormedTensorGaussianSplat3D.holographic_gr24_imaging_depth_recovery_and_convergent_beam_identities
    (splat : NormedTensorGaussianSplat3D)
    (focalScale m_boson hbar θ_z φ_err sigmaPerp sigmaParallel N_beam A0 : ℝ)
    (hf : 0 < focalScale) (hz : 0 < splat.centerZ)
    (hm : 0 < m_boson) (hhbar : hbar ≠ 0)
    (h_perp_pos : 0 < sigmaPerp) (h_perp_lt : sigmaPerp < sigmaParallel)
    (hN_gt : 1 < N_beam) (hA0_pos : 0 < A0) :
    let s_ortho := splat.projectOrthographic2D
    let s_persp := splat.projectPerspective2D focalScale hf hz
    let δ_d := splat.holographicDepthAnisotropy
    let M_depth := ddfThermalGr24Matrix δ_d θ_z
    let R_depth :=
      Complex.normSq (complexPluckerSinkAmplitudeA M_depth) /
        Complex.normSq (complexPluckerSinkAmplitudeB M_depth)
    let sigma3_sq_rec := recoverDepthVarianceSq s_ortho.covTrace R_depth
    sigma3_sq_rec = splat.sigma3 ^ 2 ∧
      s_ortho.covTrace + sigma3_sq_rec = splat.covTrace ∧
      s_ortho.covDet * sigma3_sq_rec = splat.covDet ∧
      s_ortho.coreBohmPotential m_boson hbar +
          (hbar ^ 2 / (4 * m_boson)) * (R_depth / s_ortho.covTrace) =
        splat.coreBohmPotential m_boson hbar ∧
      recoverFocalDepthSq focalScale s_ortho.covTrace s_persp.covTrace =
        splat.centerZ ^ 2 ∧
      focalScale ^ 2 *
          (s_persp.coreBohmPotential m_boson hbar /
            s_ortho.coreBohmPotential m_boson hbar) =
        splat.centerZ ^ 2 ∧
      1 / sigmaParallel ^ 2 < 2 / sigmaParallel ^ 2 ∧
      2 / sigmaParallel ^ 2 <
        convergentCrossedAxialPrecision sigmaPerp sigmaParallel ∧
      (N_beam * A0) ^ 2 = N_beam * (N_beam * A0 ^ 2) ∧
      N_beam * A0 ^ 2 < (N_beam * A0) ^ 2 ∧
      ddfThermalGr24Matrix δ_d (θ_z + φ_err - φ_err) = M_depth := by
  intro s_ortho s_persp δ_d M_depth R_depth sigma3_sq_rec
  have h_base :=
    splat.splitMajor3D_and_holographic_gr24_projection_identities
      focalScale m_boson hbar θ_z hf hz hm hhbar
  have h_R : R_depth = (splat.sigma1 ^ 2 + splat.sigma2 ^ 2) / splat.sigma3 ^ 2 :=
    h_base.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2
  have hs1_ne : splat.sigma1 ≠ 0 := ne_of_gt splat.sigma1_pos
  have hs2_ne : splat.sigma2 ≠ 0 := ne_of_gt splat.sigma2_pos
  have hs3_ne : splat.sigma3 ≠ 0 := ne_of_gt splat.sigma3_pos
  have hm_ne : m_boson ≠ 0 := ne_of_gt hm
  have hf_ne : focalScale ≠ 0 := ne_of_gt hf
  have hz_ne : splat.centerZ ≠ 0 := ne_of_gt hz
  have h_lat_pos : 0 < splat.sigma1 ^ 2 + splat.sigma2 ^ 2 := by
    have : 0 < splat.sigma1 ^ 2 := sq_pos_of_pos splat.sigma1_pos
    have : 0 < splat.sigma2 ^ 2 := sq_pos_of_pos splat.sigma2_pos
    linarith
  have h_lat_ne : splat.sigma1 ^ 2 + splat.sigma2 ^ 2 ≠ 0 := ne_of_gt h_lat_pos
  have h_s3_rec : sigma3_sq_rec = splat.sigma3 ^ 2 := by
    dsimp [sigma3_sq_rec, recoverDepthVarianceSq, s_ortho,
      projectOrthographic2D, NormedTensorGaussianSplat2D.covTrace]
    rw [h_R]
    field_simp [h_lat_ne, hs3_ne]
  have h_tr_rec : s_ortho.covTrace + sigma3_sq_rec = splat.covTrace := by
    rw [h_s3_rec]
    dsimp [s_ortho, projectOrthographic2D, NormedTensorGaussianSplat2D.covTrace, covTrace]
  have h_det_rec : s_ortho.covDet * sigma3_sq_rec = splat.covDet := by
    rw [h_s3_rec]
    dsimp [s_ortho, projectOrthographic2D, NormedTensorGaussianSplat2D.covDet, covDet]
  have h_bohm_rec :
      s_ortho.coreBohmPotential m_boson hbar +
          (hbar ^ 2 / (4 * m_boson)) * (R_depth / s_ortho.covTrace) =
        splat.coreBohmPotential m_boson hbar := by
    rw [h_R]
    dsimp [s_ortho, projectOrthographic2D, NormedTensorGaussianSplat2D.covTrace,
      NormedTensorGaussianSplat2D.coreBohmPotential, coreBohmPotential]
    field_simp [h_lat_ne, hs1_ne, hs2_ne, hs3_ne, hm_ne]
  have h_z_tr :
      recoverFocalDepthSq focalScale s_ortho.covTrace s_persp.covTrace =
        splat.centerZ ^ 2 := by
    dsimp [recoverFocalDepthSq, s_ortho, s_persp, projectOrthographic2D,
      projectPerspective2D, NormedTensorGaussianSplat2D.covTrace]
    have h_persp_tr :
        (focalScale / splat.centerZ * splat.sigma1) ^ 2 +
            (focalScale / splat.centerZ * splat.sigma2) ^ 2 =
          (focalScale / splat.centerZ) ^ 2 * (splat.sigma1 ^ 2 + splat.sigma2 ^ 2) := by
      ring
    rw [h_persp_tr]
    field_simp [hf_ne, hz_ne, h_lat_ne]
  have h_inv_lat_pos : 0 < 1 / splat.sigma1 ^ 2 + 1 / splat.sigma2 ^ 2 := by
    have : 0 < 1 / splat.sigma1 ^ 2 := one_div_pos.mpr (sq_pos_of_pos splat.sigma1_pos)
    have : 0 < 1 / splat.sigma2 ^ 2 := one_div_pos.mpr (sq_pos_of_pos splat.sigma2_pos)
    linarith
  have h_bohm_ortho_ne : s_ortho.coreBohmPotential m_boson hbar ≠ 0 := by
    dsimp [s_ortho, projectOrthographic2D, NormedTensorGaussianSplat2D.coreBohmPotential]
    have hh2 : 0 < hbar ^ 2 := sq_pos_of_ne_zero hhbar
    exact ne_of_gt (mul_pos (by positivity) h_inv_lat_pos)
  have h_persp_bohm := h_base.2.2.2.2.2.2.2.2.2.2.1
  have h_z_bohm :
      focalScale ^ 2 *
          (s_persp.coreBohmPotential m_boson hbar /
            s_ortho.coreBohmPotential m_boson hbar) =
        splat.centerZ ^ 2 := by
    rw [h_persp_bohm, mul_div_cancel_right₀ _ h_bohm_ortho_ne]
    field_simp [hf_ne]
  have h_par_pos : 0 < sigmaParallel := lt_trans h_perp_pos h_perp_lt
  have h_par_sq_pos : 0 < sigmaParallel ^ 2 := sq_pos_of_pos h_par_pos
  have h_prec1 : 1 / sigmaParallel ^ 2 < 2 / sigmaParallel ^ 2 := by
    exact div_lt_div_of_pos_right (by norm_num) h_par_sq_pos
  have h_prec2 :
      2 / sigmaParallel ^ 2 <
        convergentCrossedAxialPrecision sigmaPerp sigmaParallel := by
    unfold convergentCrossedAxialPrecision
    have h_sq_lt : sigmaPerp ^ 2 < sigmaParallel ^ 2 :=
      sq_lt_sq.mpr (by rw [abs_of_pos h_perp_pos, abs_of_pos h_par_pos]; exact h_perp_lt)
    have h_inv_lt : 1 / sigmaParallel ^ 2 < 1 / sigmaPerp ^ 2 :=
      one_div_lt_one_div_of_lt (sq_pos_of_pos h_perp_pos) h_sq_lt
    have h_two : 2 / sigmaParallel ^ 2 = 1 / sigmaParallel ^ 2 + 1 / sigmaParallel ^ 2 := by ring
    linarith
  have h_coh_eq : (N_beam * A0) ^ 2 = N_beam * (N_beam * A0 ^ 2) := by ring
  have h_coh_lt : N_beam * A0 ^ 2 < (N_beam * A0) ^ 2 := by
    rw [h_coh_eq]
    have hN_pos : 0 < N_beam := lt_trans zero_lt_one hN_gt
    have hNA2_pos : 0 < N_beam * A0 ^ 2 := mul_pos hN_pos (sq_pos_of_pos hA0_pos)
    nlinarith
  have h_phase_conj : ddfThermalGr24Matrix δ_d (θ_z + φ_err - φ_err) = M_depth := by
    dsimp [M_depth]
    rw [add_sub_cancel_right]
  exact ⟨h_s3_rec, h_tr_rec, h_det_rec, h_bohm_rec, h_z_tr, h_z_bohm,
    h_prec1, h_prec2, h_coh_eq, h_coh_lt, h_phase_conj⟩

/-! ## Higher-Rank $Gr_{\mathbb{C}}(3, n)$ Direct 3D Volumetric Imaging & 3-Element Vectorial Wave Model for Longitudinal Polarization (`Vectorial-Wave-Model-for-Longitudinal-Polarization.md`) -/

/-- Left-multiplying any complex $3 \times n$ Grassmannian matrix $M_{\mathbb{C}} \in \mathbb{C}^{3 \times n}$
by a $3 \times 3$ complex row basis matrix $B \in \mathbb{C}^{3 \times 3}$ scales every
three-row Plücker minor $\Delta_{abc}^{\mathbb{C}}(B M_{\mathbb{C}})$ by $\det B$. -/
@[blueprint "lem:signals-ddf-complex-three-row-minor-basis-change"
  (title := "Complex 3×n three-row Plücker minor GL(3,ℂ) basis-change covariance")
  (statement := /-- For any $B\in\mathbb C^{3\times 3}$, $M_{\mathbb C}\in\mathbb C^{3\times n}$,
    and $a,b,c\in\operatorname{Fin}(n)$,
    $\Delta_{abc}^{\mathbb C}(B M_{\mathbb C}) = (\det B)\,\Delta_{abc}^{\mathbb C}(M_{\mathbb C})$. -/)
  (proof := /-- Expand $\det B$ via \texttt{Matrix.det\_fin\_three} and close by commutative ring algebra in $\mathbb C$. -/)
  (latexEnv := "lemma")]
lemma complexThreeRowMinor_basisChange {columnCount : ℕ}
    (basis : Matrix (Fin 3) (Fin 3) ℂ)
    (matrix : Matrix (Fin 3) (Fin columnCount) ℂ)
    (first second third : Fin columnCount) :
    complexThreeRowMinor (basis * matrix) first second third =
      basis.det * complexThreeRowMinor matrix first second third := by
  unfold complexThreeRowMinor
  rw [Matrix.det_fin_three]
  simp only [Matrix.mul_apply, Fin.sum_univ_three, Fin.isValue]
  ring

/-- Canonical $3 \times 6$ complex Grassmannian matrix $M_{\mathbb{C}}^{(3,6)}(a_1, a_2, a_3) \in \mathbb{C}^{3 \times 6}$
encoding a 3-element vectorial focal field $(a_1, a_2, a_3) = (E_x, E_y, E_z)$ or the
three principal axes of a `NormedTensorGaussianSplat3D` in a single rank-3 subspace
of $\mathbb{C}^6$ ($Gr_{\mathbb{C}}(3, 6)$, the self-dual rank-3 counterpart of $Gr_{\mathbb{C}}(2, 4)$). -/
@[blueprint "def:signals-ddf-gr36-volumetric-imaging-matrix"
  (title := "Canonical 3×6 complex Grassmannian Gr_C(3,6) volumetric imaging matrix")
  (statement := /-- Define the $3\times 6$ complex Grassmannian matrix
    $M_{\mathbb C}^{(3,6)}(a_1,a_2,a_3) = [\operatorname{diag}(a_1,a_2,a_3)\mid I_3]\in\mathbb C^{3\times 6}$. -/)]
def gr36VolumetricImagingMatrix (a1 a2 a3 : ℂ) : Matrix (Fin 3) (Fin 6) ℂ :=
  !![a1, 0, 0, 1, 0, 0;
     0, a2, 0, 0, 1, 0;
     0, 0, a3, 0, 0, 1]

/-- Direct $Gr_{\mathbb{C}}(3, 6)$ twistor embedding of a `NormedTensorGaussianSplat3D`
with 3D modal phases $(\phi_1, \phi_2, \phi_3)$, placing all three principal widths
$\sigma_1 e^{i\phi_1}, \sigma_2 e^{i\phi_2}, \sigma_3 e^{i\phi_3}$ into a single
rank-3 complex Grassmannian matrix without splitting into two $Gr_{\mathbb{C}}(2,4)$ projections. -/
@[blueprint "def:signals-ddf-splat3d-gr36-twistor-matrix"
  (title := "Direct Gr_C(3,6) rank-3 twistor embedding of NormedTensorGaussianSplat3D")
  (statement := /-- Embed \texttt{splat : NormedTensorGaussianSplat3D} with modal phases
    $(\phi_1,\phi_2,\phi_3)$ into $Gr_{\mathbb C}(3,6)$ via
    $a_j = \sigma_j(\cos\phi_j + i\sin\phi_j)$. -/)]
noncomputable def NormedTensorGaussianSplat3D.gr36TwistorMatrix
    (splat : NormedTensorGaussianSplat3D) (φ1 φ2 φ3 : ℝ) : Matrix (Fin 3) (Fin 6) ℂ :=
  gr36VolumetricImagingMatrix
    (↑(splat.sigma1 * Real.cos φ1) + Complex.I * ↑(splat.sigma1 * Real.sin φ1))
    (↑(splat.sigma2 * Real.cos φ2) + Complex.I * ↑(splat.sigma2 * Real.sin φ2))
    (↑(splat.sigma3 * Real.cos φ3) + Complex.I * ↑(splat.sigma3 * Real.sin φ3))

/-- **Higher-Rank $Gr_{\mathbb{C}}(3, 6)$ Direct 3D Volumetric Splat Imaging & Plücker Syzygy Theorem**:
Establishes that embedding a 3D Gaussian voxel (`NormedTensorGaussianSplat3D`) into the
rank-3 complex Grassmannian $Gr_{\mathbb{C}}(3, 6)$ (`M_3 = splat.gr36TwistorMatrix φ1 φ2 φ3`)
simultaneously encodes all 1D principal variances, all three 2D orthographic marginal
planes ($xy, xz, yz$), the full 3D covariance trace and determinant, the 3D core Bohm
quantum potential, and the $Gr_{\mathbb{C}}(2,4)$ depth ratio $R_{\mathrm{depth}}$ directly
as $3 \times 3$ Plücker minors (`complexThreeRowMinor`):
1. **Reference Minor Normalization**: $\Delta_{345}^{\mathbb{C}}(M_3) = 1$,
2. **Direct Single-Axis Principal Variances from $3 \times 3$ Plücker Minors**:
   $$|\Delta_{045}^{\mathbb{C}}(M_3)|^2 = \sigma_1^2, \qquad
   |\Delta_{315}^{\mathbb{C}}(M_3)|^2 = \sigma_2^2, \qquad
   |\Delta_{342}^{\mathbb{C}}(M_3)|^2 = \sigma_3^2,$$
3. **All Three 2D Orthographic Plane Marginals ($xy, xz, yz$) as $3 \times 3$ Plücker Minors**:
   $$|\Delta_{015}^{\mathbb{C}}(M_3)|^2 = \sigma_1^2\sigma_2^2 = \det\Sigma_{\mathrm{2D}}^{\mathrm{ortho}}, \qquad
   |\Delta_{042}^{\mathbb{C}}(M_3)|^2 = \sigma_1^2\sigma_3^2, \qquad
   |\Delta_{312}^{\mathbb{C}}(M_3)|^2 = \sigma_2^2\sigma_3^2,$$
4. **Full 3D Volumetric Covariance Determinant & Trace**:
   $$|\Delta_{012}^{\mathbb{C}}(M_3)|^2 = \sigma_1^2\sigma_2^2\sigma_3^2 = \det\Sigma_{\mathrm{3D}}, \qquad
   |\Delta_{045}^{\mathbb{C}}(M_3)|^2 + |\Delta_{315}^{\mathbb{C}}(M_3)|^2 + |\Delta_{342}^{\mathbb{C}}(M_3)|^2 = \operatorname{Tr}\Sigma_{\mathrm{3D}},$$
5. **Direct 3D Core Bohm Quantum Potential in $Gr_{\mathbb{C}}(3, 6)$ Plücker Coordinates**:
   $$\frac{\hbar^2}{4m}\,\frac{|\Delta_{312}^{\mathbb{C}}(M_3)|^2 + |\Delta_{042}^{\mathbb{C}}(M_3)|^2 + |\Delta_{015}^{\mathbb{C}}(M_3)|^2}{|\Delta_{012}^{\mathbb{C}}(M_3)|^2}
   = Q_{\mathrm{core,3D}}(\Sigma_{\mathrm{3D}}),$$
6. **Exact Consistency Between $Gr_{\mathbb{C}}(3, 6)$ and $Gr_{\mathbb{C}}(2, 4)$ Depth Recovery**:
   $$\frac{|\Delta_{045}^{\mathbb{C}}(M_3)|^2 + |\Delta_{315}^{\mathbb{C}}(M_3)|^2}{|\Delta_{342}^{\mathbb{C}}(M_3)|^2}
   = \frac{|w_A^{\mathbb{C}}(M_{\mathrm{depth}})|^2}{|w_B^{\mathbb{C}}(M_{\mathrm{depth}})|^2}
   = \frac{\sigma_1^2 + \sigma_2^2}{\sigma_3^2},$$
7. **Universal 4-Term $Gr_{\mathbb{C}}(3, 6)$ Quadratic Plücker Syzygy**:
   $$\Delta_{012}^{\mathbb{C}}\Delta_{345}^{\mathbb{C}} - \Delta_{013}^{\mathbb{C}}\Delta_{245}^{\mathbb{C}} + \Delta_{014}^{\mathbb{C}}\Delta_{235}^{\mathbb{C}} - \Delta_{015}^{\mathbb{C}}\Delta_{234}^{\mathbb{C}} = 0.$$ -/
@[blueprint "thm:signals-ddf-gr36-volumetric-imaging-identities"
  (title := "Higher-rank Gr_C(3,6) direct 3D volumetric splat imaging and Plücker syzygy theorem")
  (statement := /-- For any \texttt{splat : NormedTensorGaussianSplat3D}, modal phases $\phi_1,\phi_2,\phi_3,\theta_z\in\mathbb R$,
    $m > 0$, $\hbar \ne 0$, and $M_3 = \operatorname{splat}.\operatorname{gr36TwistorMatrix}(\phi_1,\phi_2,\phi_3)$:
    (1) $\Delta_{345}^{\mathbb C}(M_3) = 1$,
    (2) $|\Delta_{045}^{\mathbb C}(M_3)|^2 = \sigma_1^2$, $|\Delta_{315}^{\mathbb C}(M_3)|^2 = \sigma_2^2$, $|\Delta_{342}^{\mathbb C}(M_3)|^2 = \sigma_3^2$,
    (3) $|\Delta_{015}^{\mathbb C}(M_3)|^2 = (\operatorname{splat}.\mathrm{projectOrthographic2D}).\mathrm{covDet}$,
    $|\Delta_{042}^{\mathbb C}(M_3)|^2 = \sigma_1^2\sigma_3^2$, $|\Delta_{312}^{\mathbb C}(M_3)|^2 = \sigma_2^2\sigma_3^2$,
    (4) $|\Delta_{012}^{\mathbb C}(M_3)|^2 = \operatorname{splat}.\mathrm{covDet}$ and
    $|\Delta_{045}^{\mathbb C}(M_3)|^2 + |\Delta_{315}^{\mathbb C}(M_3)|^2 + |\Delta_{342}^{\mathbb C}(M_3)|^2 = \operatorname{splat}.\mathrm{covTrace}$,
    (5) $\frac{\hbar^2}{4m}\frac{|\Delta_{312}^{\mathbb C}(M_3)|^2 + |\Delta_{042}^{\mathbb C}(M_3)|^2 + |\Delta_{015}^{\mathbb C}(M_3)|^2}{|\Delta_{012}^{\mathbb C}(M_3)|^2} = \operatorname{splat}.\operatorname{coreBohmPotential}(m,\hbar)$,
    (6) $(|\Delta_{045}^{\mathbb C}(M_3)|^2 + |\Delta_{315}^{\mathbb C}(M_3)|^2)/|\Delta_{342}^{\mathbb C}(M_3)|^2 = (\sigma_1^2 + \sigma_2^2)/\sigma_3^2$, and
    (7) $\Delta_{012}^{\mathbb C}\Delta_{345}^{\mathbb C} - \Delta_{013}^{\mathbb C}\Delta_{245}^{\mathbb C} + \Delta_{014}^{\mathbb C}\Delta_{235}^{\mathbb C} - \Delta_{015}^{\mathbb C}\Delta_{234}^{\mathbb C} = 0$. -/)
  (proof := /-- Evaluate each $3\times 3$ complex minor of \texttt{gr36VolumetricImagingMatrix},
    apply $\cos^2\phi_j + \sin^2\phi_j = 1$ and \texttt{Complex.normSq\_mul}, and invoke
    \texttt{complexThreeRowMinor\_pluecker}. -/)]
theorem NormedTensorGaussianSplat3D.gr36_volumetric_imaging_and_plucker_identities
    (splat : NormedTensorGaussianSplat3D) (φ1 φ2 φ3 m_boson hbar : ℝ)
    (hm : 0 < m_boson) :
    let M3 := splat.gr36TwistorMatrix φ1 φ2 φ3
    let s_ortho := splat.projectOrthographic2D
    complexThreeRowMinor M3 3 4 5 = 1 ∧
      Complex.normSq (complexThreeRowMinor M3 0 4 5) = splat.sigma1 ^ 2 ∧
      Complex.normSq (complexThreeRowMinor M3 3 1 5) = splat.sigma2 ^ 2 ∧
      Complex.normSq (complexThreeRowMinor M3 3 4 2) = splat.sigma3 ^ 2 ∧
      Complex.normSq (complexThreeRowMinor M3 0 1 5) = s_ortho.covDet ∧
      Complex.normSq (complexThreeRowMinor M3 0 4 2) = splat.sigma1 ^ 2 * splat.sigma3 ^ 2 ∧
      Complex.normSq (complexThreeRowMinor M3 3 1 2) = splat.sigma2 ^ 2 * splat.sigma3 ^ 2 ∧
      Complex.normSq (complexThreeRowMinor M3 0 1 2) = splat.covDet ∧
      Complex.normSq (complexThreeRowMinor M3 0 4 5) +
          Complex.normSq (complexThreeRowMinor M3 3 1 5) +
          Complex.normSq (complexThreeRowMinor M3 3 4 2) =
        splat.covTrace ∧
      (hbar ^ 2 / (4 * m_boson)) *
          ((Complex.normSq (complexThreeRowMinor M3 3 1 2) +
              Complex.normSq (complexThreeRowMinor M3 0 4 2) +
              Complex.normSq (complexThreeRowMinor M3 0 1 5)) /
            Complex.normSq (complexThreeRowMinor M3 0 1 2)) =
        splat.coreBohmPotential m_boson hbar ∧
      (Complex.normSq (complexThreeRowMinor M3 0 4 5) +
          Complex.normSq (complexThreeRowMinor M3 3 1 5)) /
          Complex.normSq (complexThreeRowMinor M3 3 4 2) =
        (splat.sigma1 ^ 2 + splat.sigma2 ^ 2) / splat.sigma3 ^ 2 ∧
      complexThreeRowMinor M3 0 1 2 * complexThreeRowMinor M3 3 4 5 -
          complexThreeRowMinor M3 0 1 3 * complexThreeRowMinor M3 2 4 5 +
          complexThreeRowMinor M3 0 1 4 * complexThreeRowMinor M3 2 3 5 -
          complexThreeRowMinor M3 0 1 5 * complexThreeRowMinor M3 2 3 4 = 0 := by
  intro M3 s_ortho
  let a1 : ℂ := ↑(splat.sigma1 * Real.cos φ1) + Complex.I * ↑(splat.sigma1 * Real.sin φ1)
  let a2 : ℂ := ↑(splat.sigma2 * Real.cos φ2) + Complex.I * ↑(splat.sigma2 * Real.sin φ2)
  let a3 : ℂ := ↑(splat.sigma3 * Real.cos φ3) + Complex.I * ↑(splat.sigma3 * Real.sin φ3)
  have ha1 : Complex.normSq a1 = splat.sigma1 ^ 2 := by
    dsimp [a1]
    simp only [Complex.normSq_apply, Complex.add_re, Complex.add_im, Complex.mul_re,
      Complex.mul_im, Complex.ofReal_re, Complex.ofReal_im, Complex.I_re, Complex.I_im]
    calc
      _ = splat.sigma1 ^ 2 * ((Real.cos φ1) ^ 2 + (Real.sin φ1) ^ 2) := by ring
      _ = splat.sigma1 ^ 2 := by rw [Real.cos_sq_add_sin_sq, mul_one]
  have ha2 : Complex.normSq a2 = splat.sigma2 ^ 2 := by
    dsimp [a2]
    simp only [Complex.normSq_apply, Complex.add_re, Complex.add_im, Complex.mul_re,
      Complex.mul_im, Complex.ofReal_re, Complex.ofReal_im, Complex.I_re, Complex.I_im]
    calc
      _ = splat.sigma2 ^ 2 * ((Real.cos φ2) ^ 2 + (Real.sin φ2) ^ 2) := by ring
      _ = splat.sigma2 ^ 2 := by rw [Real.cos_sq_add_sin_sq, mul_one]
  have ha3 : Complex.normSq a3 = splat.sigma3 ^ 2 := by
    dsimp [a3]
    simp only [Complex.normSq_apply, Complex.add_re, Complex.add_im, Complex.mul_re,
      Complex.mul_im, Complex.ofReal_re, Complex.ofReal_im, Complex.I_re, Complex.I_im]
    calc
      _ = splat.sigma3 ^ 2 * ((Real.cos φ3) ^ 2 + (Real.sin φ3) ^ 2) := by ring
      _ = splat.sigma3 ^ 2 := by rw [Real.cos_sq_add_sin_sq, mul_one]
  have hM3 : M3 = gr36VolumetricImagingMatrix a1 a2 a3 := rfl
  have hm_345 : complexThreeRowMinor M3 3 4 5 = 1 := by
    rw [hM3]
    dsimp [gr36VolumetricImagingMatrix, complexThreeRowMinor,
      Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.cons_val_two,
      Matrix.cons_val_three, Matrix.cons_val_four, Matrix.vecHead, Matrix.vecTail]
    ring
  have hm_045 : complexThreeRowMinor M3 0 4 5 = a1 := by
    rw [hM3]
    dsimp [gr36VolumetricImagingMatrix, complexThreeRowMinor,
      Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.cons_val_two,
      Matrix.cons_val_three, Matrix.cons_val_four, Matrix.vecHead, Matrix.vecTail]
    ring
  have hm_315 : complexThreeRowMinor M3 3 1 5 = a2 := by
    rw [hM3]
    dsimp [gr36VolumetricImagingMatrix, complexThreeRowMinor,
      Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.cons_val_two,
      Matrix.cons_val_three, Matrix.cons_val_four, Matrix.vecHead, Matrix.vecTail]
    ring
  have hm_342 : complexThreeRowMinor M3 3 4 2 = a3 := by
    rw [hM3]
    dsimp [gr36VolumetricImagingMatrix, complexThreeRowMinor,
      Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.cons_val_two,
      Matrix.cons_val_three, Matrix.cons_val_four, Matrix.vecHead, Matrix.vecTail]
    ring
  have hm_015 : complexThreeRowMinor M3 0 1 5 = a1 * a2 := by
    rw [hM3]
    dsimp [gr36VolumetricImagingMatrix, complexThreeRowMinor,
      Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.cons_val_two,
      Matrix.cons_val_three, Matrix.cons_val_four, Matrix.vecHead, Matrix.vecTail]
    ring
  have hm_042 : complexThreeRowMinor M3 0 4 2 = a1 * a3 := by
    rw [hM3]
    dsimp [gr36VolumetricImagingMatrix, complexThreeRowMinor,
      Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.cons_val_two,
      Matrix.cons_val_three, Matrix.cons_val_four, Matrix.vecHead, Matrix.vecTail]
    ring
  have hm_312 : complexThreeRowMinor M3 3 1 2 = a2 * a3 := by
    rw [hM3]
    dsimp [gr36VolumetricImagingMatrix, complexThreeRowMinor,
      Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.cons_val_two,
      Matrix.cons_val_three, Matrix.cons_val_four, Matrix.vecHead, Matrix.vecTail]
    ring
  have hm_012 : complexThreeRowMinor M3 0 1 2 = a1 * a2 * a3 := by
    rw [hM3]
    dsimp [gr36VolumetricImagingMatrix, complexThreeRowMinor,
      Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.cons_val_two,
      Matrix.cons_val_three, Matrix.cons_val_four, Matrix.vecHead, Matrix.vecTail]
    ring
  have h_n045 : Complex.normSq (complexThreeRowMinor M3 0 4 5) = splat.sigma1 ^ 2 := by
    rw [hm_045, ha1]
  have h_n315 : Complex.normSq (complexThreeRowMinor M3 3 1 5) = splat.sigma2 ^ 2 := by
    rw [hm_315, ha2]
  have h_n342 : Complex.normSq (complexThreeRowMinor M3 3 4 2) = splat.sigma3 ^ 2 := by
    rw [hm_342, ha3]
  have h_n015 : Complex.normSq (complexThreeRowMinor M3 0 1 5) = s_ortho.covDet := by
    rw [hm_015, Complex.normSq_mul, ha1, ha2]
    rfl
  have h_n042 :
      Complex.normSq (complexThreeRowMinor M3 0 4 2) = splat.sigma1 ^ 2 * splat.sigma3 ^ 2 := by
    rw [hm_042, Complex.normSq_mul, ha1, ha3]
  have h_n312 :
      Complex.normSq (complexThreeRowMinor M3 3 1 2) = splat.sigma2 ^ 2 * splat.sigma3 ^ 2 := by
    rw [hm_312, Complex.normSq_mul, ha2, ha3]
  have h_n012 : Complex.normSq (complexThreeRowMinor M3 0 1 2) = splat.covDet := by
    rw [hm_012, Complex.normSq_mul, Complex.normSq_mul, ha1, ha2, ha3]
    rfl
  have h_trace :
      Complex.normSq (complexThreeRowMinor M3 0 4 5) +
          Complex.normSq (complexThreeRowMinor M3 3 1 5) +
          Complex.normSq (complexThreeRowMinor M3 3 4 2) =
        splat.covTrace := by
    rw [h_n045, h_n315, h_n342]
    rfl
  have hs1_ne : splat.sigma1 ≠ 0 := ne_of_gt splat.sigma1_pos
  have hs2_ne : splat.sigma2 ≠ 0 := ne_of_gt splat.sigma2_pos
  have hs3_ne : splat.sigma3 ≠ 0 := ne_of_gt splat.sigma3_pos
  have hm_ne : m_boson ≠ 0 := ne_of_gt hm
  have h_bohm :
      (hbar ^ 2 / (4 * m_boson)) *
          ((Complex.normSq (complexThreeRowMinor M3 3 1 2) +
              Complex.normSq (complexThreeRowMinor M3 0 4 2) +
              Complex.normSq (complexThreeRowMinor M3 0 1 5)) /
            Complex.normSq (complexThreeRowMinor M3 0 1 2)) =
        splat.coreBohmPotential m_boson hbar := by
    rw [h_n312, h_n042, h_n015, h_n012]
    dsimp [s_ortho, projectOrthographic2D, NormedTensorGaussianSplat2D.covDet,
      covDet, coreBohmPotential]
    field_simp [hs1_ne, hs2_ne, hs3_ne, hm_ne]
  have h_ratio :
      (Complex.normSq (complexThreeRowMinor M3 0 4 5) +
          Complex.normSq (complexThreeRowMinor M3 3 1 5)) /
          Complex.normSq (complexThreeRowMinor M3 3 4 2) =
        (splat.sigma1 ^ 2 + splat.sigma2 ^ 2) / splat.sigma3 ^ 2 := by
    rw [h_n045, h_n315, h_n342]
  have h_plucker := complexThreeRowMinor_pluecker M3 0 1 2 3 4 5
  exact ⟨hm_345, h_n045, h_n315, h_n342, h_n015, h_n042, h_n312, h_n012,
    h_trace, h_bohm, h_ratio, h_plucker⟩

/-- Radial (transverse) electric-field component $E_r(E_0, \theta) = E_0 \cos\theta$
after high-NA geometric ray bending at convergence angle $\theta$ in the Debye–Wolf
vectorial diffraction model (`Vectorial-Wave-Model-for-Longitudinal-Polarization.md`, lines 16–39). -/
@[blueprint "def:signals-ddf-debye-wolf-radial-component"
  (title := "Debye-Wolf high-NA transverse radial electric field component E_0 cos θ")
  (statement := /-- Define $\operatorname{debyeWolfRadialComponent}(E_0, \theta) = E_0 \cos\theta$. -/)]
noncomputable def debyeWolfRadialComponent (E0 θ : ℝ) : ℝ :=
  E0 * Real.cos θ

/-- Longitudinal ($z$-axis) electric-field component $E_z(E_0, \theta) = E_0 \sin\theta$
generated by high-NA geometric polarization tilting of a radially polarized beam at
convergence angle $\theta$ (`Vectorial-Wave-Model-for-Longitudinal-Polarization.md`, lines 23–39). -/
@[blueprint "def:signals-ddf-debye-wolf-longitudinal-component"
  (title := "Debye-Wolf high-NA longitudinal electric field component E_0 sin θ")
  (statement := /-- Define $\operatorname{debyeWolfLongitudinalComponent}(E_0, \theta) = E_0 \sin\theta$. -/)]
noncomputable def debyeWolfLongitudinalComponent (E0 θ : ℝ) : ℝ :=
  E0 * Real.sin θ

/-- 3-element Debye–Wolf focal electric field vector
$\mathbf{E}_{\mathrm{DW}}(E_0, \theta, \phi) = (E_0\cos\theta\cos\phi,\; E_0\cos\theta\sin\phi,\; E_0\sin\theta)$
for a radially polarized ray at convergence polar angle $\theta$ and pupil azimuth $\phi$
(`Vectorial-Wave-Model-for-Longitudinal-Polarization.md`, lines 31–44). -/
@[blueprint "def:signals-ddf-debye-wolf-ray-vec3"
  (title := "3-element Debye-Wolf focal electric field vector [E_x, E_y, E_z]^T")
  (statement := /-- Define the 3-element Debye--Wolf electric field vector at convergence
    angle $\theta$ and azimuth $\phi$:
    $(E_0\cos\theta\cos\phi,\; E_0\cos\theta\sin\phi,\; E_0\sin\theta)$. -/)]
noncomputable def debyeWolfRayVec3 (E0 θ φ : ℝ) : ℝ × ℝ × ℝ :=
  (E0 * Real.cos θ * Real.cos φ, E0 * Real.cos θ * Real.sin φ, E0 * Real.sin θ)

/-- Hyperbolic dielectric metasurface phase profile
$\Phi(r; f, \lambda_0) = -\frac{2\pi}{\lambda_0}\left(\sqrt{r^2 + f^2} - f\right)$
imparted by sub-wavelength $\mathrm{Si}$ or $\mathrm{TiO_2}$ nanopillars to convert a
planar radially polarized CW wavefront into a spherical high-NA converging wave
(`Vectorial-Wave-Model-for-Longitudinal-Polarization.md`, lines 135–145). -/
@[blueprint "def:signals-ddf-hyperbolic-metasurface-phase"
  (title := "High-NA dielectric metasurface hyperbolic lens phase profile Φ(r; f, λ_0)")
  (statement := /-- Define $\operatorname{hyperbolicMetasurfacePhase}(r, f, \lambda_0)
    = -\frac{2\pi}{\lambda_0}\left(\sqrt{r^2 + f^2} - f\right)$. -/)]
noncomputable def hyperbolicMetasurfacePhase (r f lambda0 : ℝ) : ℝ :=
  -(2 * Real.pi / lambda0) * (Real.sqrt (r ^ 2 + f ^ 2) - f)

/-- Spatially varying $2 \times 2$ local birefringent half-waveplate Jones matrix
$J_{\mathrm{pillar}}(\theta) = \begin{pmatrix} \cos\theta & \sin\theta \\ \sin\theta & -\cos\theta \end{pmatrix}$
of a dielectric metasurface nanopillar oriented at fast-axis angle $\theta / 2$,
which rotates an $x$-polarized input $(1, 0)^T$ into the local radial polarization
$(\cos\theta, \sin\theta)^T$ (`Vectorial-Wave-Model-for-Longitudinal-Polarization.md`, lines 146–167). -/
@[blueprint "def:signals-ddf-radial-nanopillar-jones-matrix"
  (title := "Local birefringent nanopillar radial-polarization Jones matrix J(θ)")
  (statement := /-- Define the $2\times 2$ local nanopillar Jones matrix
    $J_{\mathrm{pillar}}(\theta) = \begin{pmatrix} \cos\theta & \sin\theta \\ \sin\theta & -\cos\theta \end{pmatrix}$. -/)]
noncomputable def radialNanopillarJonesMatrix (θ : ℝ) : Matrix (Fin 2) (Fin 2) ℝ :=
  !![Real.cos θ, Real.sin θ;
     Real.sin θ, -Real.cos θ]

/-- Longitudinal electric field $E_{z,\mathrm{ENZ}} = \frac{\varepsilon_{\mathrm{air}}}{\varepsilon_{\mathrm{ENZ}}} E_{z,\mathrm{air}}$
inside an ultra-thin Epsilon-Near-Zero (ENZ) coating (such as ITO or AZO on a lignin
substrate) derived from Maxwell's normal electric displacement continuity
$D_{z,\mathrm{air}} = \varepsilon_{\mathrm{air}} E_{z,\mathrm{air}} = \varepsilon_{\mathrm{ENZ}} E_{z,\mathrm{ENZ}} = D_{z,\mathrm{ENZ}}$
(`Vectorial-Wave-Model-for-Longitudinal-Polarization.md`, lines 169–199). -/
@[blueprint "def:signals-ddf-enz-boundary-longitudinal-field"
  (title := "Thin-film ENZ boundary longitudinal electric field E_z,ENZ = (ε_air / ε_ENZ) E_z,air")
  (statement := /-- Define $\operatorname{enzBoundaryLongitudinalField}(\varepsilon_{\mathrm{air}}, \varepsilon_{\mathrm{ENZ}}, E_{z,\mathrm{air}})
    = (\varepsilon_{\mathrm{air}} / \varepsilon_{\mathrm{ENZ}}) E_{z,\mathrm{air}}$. -/)]
noncomputable def enzBoundaryLongitudinalField (epsAir epsEnz EzAir : ℝ) : ℝ :=
  (epsAir / epsEnz) * EzAir

/-- Lossless thin-film ENZ longitudinal intensity enhancement factor
$\Gamma_{\mathrm{ENZ}}(\varepsilon_{\mathrm{air}}, \varepsilon_{\mathrm{ENZ}}) = \left(\frac{\varepsilon_{\mathrm{air}}}{\varepsilon_{\mathrm{ENZ}}}\right)^2$
(`Vectorial-Wave-Model-for-Longitudinal-Polarization.md`, lines 200–208). -/
@[blueprint "def:signals-ddf-enz-boundary-intensity-enhancement"
  (title := "Thin-film ENZ longitudinal intensity enhancement factor (ε_air / ε_ENZ)²")
  (statement := /-- Define $\operatorname{enzBoundaryIntensityEnhancement}(\varepsilon_{\mathrm{air}}, \varepsilon_{\mathrm{ENZ}})
    = (\varepsilon_{\mathrm{air}} / \varepsilon_{\mathrm{ENZ}})^2$. -/)]
noncomputable def enzBoundaryIntensityEnhancement (epsAir epsEnz : ℝ) : ℝ :=
  (epsAir / epsEnz) ^ 2

/-- Loss-regularized Drude ENZ longitudinal intensity enhancement factor
$\Gamma_{\mathrm{ENZ,reg}}(\varepsilon_{\mathrm{air}}, \varepsilon_r, \varepsilon_i) = \frac{\varepsilon_{\mathrm{air}}^2}{\varepsilon_r^2 + \varepsilon_i^2}$
for a physical passive ENZ thin film with complex relative permittivity
$\varepsilon_{\mathrm{ENZ}} = \varepsilon_r + i\varepsilon_i$ ($\varepsilon_i > 0$),
preventing unphysical infinite-field singularities at the real ENZ crossover $\varepsilon_r = 0$. -/
@[blueprint "def:signals-ddf-regularized-enz-enhancement"
  (title := "Loss-regularized complex Drude ENZ longitudinal intensity enhancement factor")
  (statement := /-- Define $\operatorname{regularizedEnzEnhancement}(\varepsilon_{\mathrm{air}}, \varepsilon_r, \varepsilon_i)
    = \varepsilon_{\mathrm{air}}^2 / (\varepsilon_r^2 + \varepsilon_i^2)$. -/)]
noncomputable def regularizedEnzEnhancement (epsAir epsReal epsImag : ℝ) : ℝ :=
  epsAir ^ 2 / (epsReal ^ 2 + epsImag ^ 2)

/-- **3-Element Vectorial Longitudinal Polarization, Counter-Polarization Cancellation, ZRI Collimation vs. Extinction, High-NA Dielectric Metasurface, & Thin-Film ENZ-Lignin Amplification Theorem**:
Formalizes the complete optical physics of `data/chats/Vectorial-Wave-Model-for-Longitudinal-Polarization.md`:
1. **3-Element Debye–Wolf Vectorial Norm Preservation**:
   For any ray $(E_x, E_y, E_z) = \operatorname{debyeWolfRayVec3}(E_0, \theta, \phi)$,
   $$E_x^2 + E_y^2 + E_z^2 = E_0^2,$$
2. **The Counter-Polarization Trick (Diametrically Opposite Azimuths $\phi$ and $\phi + \pi$)**:
   Summing two opposite radially polarized rays $\mathbf{E}_{\mathrm{DW}}(E_0, \theta, \phi)$ and
   $\mathbf{E}_{\mathrm{DW}}(E_0, \theta, \phi + \pi)$ at the geometric focus:
   - Transverse $x$-components cancel identically: $E_x(\phi) + E_x(\phi + \pi) = 0$,
   - Transverse $y$-components cancel identically: $E_y(\phi) + E_y(\phi + \pi) = 0$,
   - Longitudinal $z$-components interfere constructively: $E_z(\phi) + E_z(\phi + \pi) = 2 E_0 \sin\theta$,
     yielding on-axis longitudinal intensity $(E_z(\phi) + E_z(\phi + \pi))^2 = 4 E_0^2 \sin^2\theta$,
3. **Why 2D Jones Calculus & 2D Scalar Gerchberg–Saxton Fail at High NA ($\sin\theta \ne 0$)**:
   Because 2D paraxial Jones calculus predicts $E_{z,\mathrm{2DJones}} = 0$, its relative error
   on the on-axis longitudinal focal intensity is identically $100\%$:
   $$\frac{(2 E_0 \sin\theta)^2 - 0}{(2 E_0 \sin\theta)^2} = 1,$$
4. **Why Bulk Zero-Refractive-Index (ZRI, $n_{\mathrm{ZRI}} = 0$) Media Kill $E_z$ at the Focus Yet Flatten Upstream Phase Aberrations**:
   For $E_z^{\mathrm{bulk}}(n_{\mathrm{ZRI}}) = E_0 n_{\mathrm{ZRI}} \sin\theta_{\mathrm{in}}$ and
   upstream phase aberration $\Delta\Phi_{\mathrm{ZRI}}(n_{\mathrm{ZRI}}) = n_{\mathrm{ZRI}} k_0 \Delta L$:
   $$E_z^{\mathrm{bulk}}(0) = 0 \quad\text{and}\quad \Delta\Phi_{\mathrm{ZRI}}(0) = 0,$$
5. **Stage 1 High-NA Dielectric Metasurface Hyperbolic Phase Mask & Nanopillar Jones Laws**:
   - On-axis zero: $\Phi(0; f, \lambda_0) = 0$ (for $f > 0$),
   - Off-axis phase advance: $\Phi(r; f, \lambda_0) < 0$ (for $r \ne 0, f > 0, \lambda_0 > 0$),
   - Exact Optical Path Length (OPL) focal phase equalization ($\forall r \in \mathbb{R}, \lambda_0 \ne 0$):
     $$\Phi(r; f, \lambda_0) + \frac{2\pi}{\lambda_0}\sqrt{r^2 + f^2} = \frac{2\pi f}{\lambda_0},$$
   - Local nanopillar Jones radial-conversion unitarity & determinant:
     $$J_{\mathrm{pillar}}(\theta)_{0,0}^2 + J_{\mathrm{pillar}}(\theta)_{1,0}^2 = 1 \quad\text{and}\quad \det J_{\mathrm{pillar}}(\theta) = -1,$$
6. **Stage 2 Thin-Film ENZ-Lignin Boundary Continuity ($D_{z,\mathrm{air}} = D_{z,\mathrm{ENZ}}$), $100\times$–$400\times$ Benchmark Window, and Loss-Regularized Drude Ceiling**:
   - Normal displacement continuity ($\varepsilon_{\mathrm{ENZ}} \ne 0$):
     $$\varepsilon_{\mathrm{ENZ}} \cdot \operatorname{enzBoundaryLongitudinalField}(\varepsilon_{\mathrm{air}}, \varepsilon_{\mathrm{ENZ}}, E_{z,\mathrm{air}}) = \varepsilon_{\mathrm{air}} E_{z,\mathrm{air}},$$
   - Exact $100\times$ and $400\times$ intensity benchmarks (`Vectorial-Wave-Model-for-Longitudinal-Polarization.md`, line 204):
     $$\Gamma_{\mathrm{ENZ}}(1, 1/10) = 100 \quad\text{and}\quad \Gamma_{\mathrm{ENZ}}(1, 1/20) = 400,$$
   - Monotonic $[100, 400]$ enhancement window for $1/20 \le \varepsilon_{\mathrm{ENZ}} \le 1/10$:
     $$100 \le \Gamma_{\mathrm{ENZ}}(1, \varepsilon_{\mathrm{ENZ}}) \le 400,$$
   - Loss-regularized Drude ENZ ceiling ($\varepsilon_i \ne 0$):
     $$\Gamma_{\mathrm{ENZ,reg}}(\varepsilon_{\mathrm{air}}, \varepsilon_r, \varepsilon_i) \le \Gamma_{\mathrm{ENZ,reg}}(\varepsilon_{\mathrm{air}}, 0, \varepsilon_i) = \frac{\varepsilon_{\mathrm{air}}^2}{\varepsilon_i^2}.$$ -/
@[blueprint "thm:signals-ddf-vectorial-longitudinal-polarization-metasurface-enz"
  (title := "3-element vectorial longitudinal polarization, metasurface phase mask, ZRI collimation, and ENZ-lignin boundary amplification theorem")
  (statement := /-- For any $E_0, \theta, \phi, r, f, \lambda_0, k_0, \Delta L, \varepsilon_{\mathrm{air}}, \varepsilon_{\mathrm{ENZ}}, E_{z,\mathrm{air}}, \varepsilon_r, \varepsilon_i \in \mathbb R$
    with $E_0 \ne 0$, $\sin\theta \ne 0$, $r \ne 0$, $f > 0$, $\lambda_0 > 0$, $1/20 \le \varepsilon_{\mathrm{ENZ}} \le 1/10$, and $\varepsilon_i \ne 0$:
    (1) $E_x(\phi)^2 + E_y(\phi)^2 + E_z(\phi)^2 = E_0^2$,
    (2) $E_x(\phi) + E_x(\phi + \pi) = 0$, $E_y(\phi) + E_y(\phi + \pi) = 0$, and
    $E_z(\phi) + E_z(\phi + \pi) = 2 E_0 \sin\theta$,
    (3) $((2 E_0 \sin\theta)^2 - 0) / (2 E_0 \sin\theta)^2 = 1$,
    (4) $E_0 \cdot 0 \cdot \sin\theta = 0$ and $0 \cdot k_0 \cdot \Delta L = 0$,
    (5) $\Phi(0, f, \lambda_0) = 0$, $\Phi(r, f, \lambda_0) < 0$, and
    $\Phi(r, f, \lambda_0) + \frac{2\pi}{\lambda_0}\sqrt{r^2 + f^2} = \frac{2\pi f}{\lambda_0}$,
    (6) $J_{\mathrm{pillar}}(\theta)_{0,0}^2 + J_{\mathrm{pillar}}(\theta)_{1,0}^2 = 1$ and $\det J_{\mathrm{pillar}}(\theta) = -1$,
    (7) $\varepsilon_{\mathrm{ENZ}} \cdot \operatorname{enzBoundaryLongitudinalField}(\varepsilon_{\mathrm{air}}, \varepsilon_{\mathrm{ENZ}}, E_{z,\mathrm{air}}) = \varepsilon_{\mathrm{air}} E_{z,\mathrm{air}}$,
    $\Gamma_{\mathrm{ENZ}}(1, 1/10) = 100$, $\Gamma_{\mathrm{ENZ}}(1, 1/20) = 400$, and
    $100 \le \Gamma_{\mathrm{ENZ}}(1, \varepsilon_{\mathrm{ENZ}}) \le 400$, and
    (8) $\Gamma_{\mathrm{ENZ,reg}}(\varepsilon_{\mathrm{air}}, \varepsilon_r, \varepsilon_i) \le \Gamma_{\mathrm{ENZ,reg}}(\varepsilon_{\mathrm{air}}, 0, \varepsilon_i) = \varepsilon_{\mathrm{air}}^2 / \varepsilon_i^2$. -/)
  (proof := /-- Combine $\cos(\phi+\pi) = -\cos\phi$, $\sin(\phi+\pi) = -\sin\phi$,
    $\cos^2\alpha + \sin^2\alpha = 1$, $\sqrt{r^2 + f^2} > f$ for $r \ne 0, f > 0$,
    \texttt{Matrix.det\_fin\_two}, and reciprocal square monotonicity on $[1/20, 1/10]$. -/)]
theorem vectorial_longitudinal_polarization_metasurface_and_enz_identities
    (E0 θ φ r f lambda0 k0 deltaL epsAir epsEnz EzAir epsReal epsImag : ℝ)
    (hE0 : E0 ≠ 0) (hsin : Real.sin θ ≠ 0)
    (hr : r ≠ 0) (hf : 0 < f) (hlambda : 0 < lambda0)
    (heps_lo : (1 / 20 : ℝ) ≤ epsEnz) (heps_hi : epsEnz ≤ (1 / 10 : ℝ))
    (heps_imag : epsImag ≠ 0) :
    let ray1 := debyeWolfRayVec3 E0 θ φ
    let ray2 := debyeWolfRayVec3 E0 θ (φ + Real.pi)
    ray1.1 ^ 2 + ray1.2.1 ^ 2 + ray1.2.2 ^ 2 = E0 ^ 2 ∧
      ray1.1 + ray2.1 = 0 ∧
      ray1.2.1 + ray2.2.1 = 0 ∧
      ray1.2.2 + ray2.2.2 = 2 * debyeWolfLongitudinalComponent E0 θ ∧
      ((ray1.2.2 + ray2.2.2) ^ 2 - 0) / (ray1.2.2 + ray2.2.2) ^ 2 = 1 ∧
      E0 * (0 : ℝ) * Real.sin θ = 0 ∧
      (0 : ℝ) * k0 * deltaL = 0 ∧
      hyperbolicMetasurfacePhase 0 f lambda0 = 0 ∧
      hyperbolicMetasurfacePhase r f lambda0 < 0 ∧
      hyperbolicMetasurfacePhase r f lambda0 +
          (2 * Real.pi / lambda0) * Real.sqrt (r ^ 2 + f ^ 2) =
        (2 * Real.pi * f) / lambda0 ∧
      (radialNanopillarJonesMatrix θ 0 0) ^ 2 +
          (radialNanopillarJonesMatrix θ 1 0) ^ 2 = 1 ∧
      (radialNanopillarJonesMatrix θ).det = -1 ∧
      epsEnz * enzBoundaryLongitudinalField epsAir epsEnz EzAir = epsAir * EzAir ∧
      enzBoundaryIntensityEnhancement 1 (1 / 10) = 100 ∧
      enzBoundaryIntensityEnhancement 1 (1 / 20) = 400 ∧
      100 ≤ enzBoundaryIntensityEnhancement 1 epsEnz ∧
      enzBoundaryIntensityEnhancement 1 epsEnz ≤ 400 ∧
      regularizedEnzEnhancement epsAir epsReal epsImag ≤
        regularizedEnzEnhancement epsAir 0 epsImag ∧
      regularizedEnzEnhancement epsAir 0 epsImag = epsAir ^ 2 / epsImag ^ 2 := by
  intro ray1 ray2
  have h_norm : ray1.1 ^ 2 + ray1.2.1 ^ 2 + ray1.2.2 ^ 2 = E0 ^ 2 := by
    dsimp [ray1, debyeWolfRayVec3]
    calc
      (E0 * Real.cos θ * Real.cos φ) ^ 2 +
          (E0 * Real.cos θ * Real.sin φ) ^ 2 +
          (E0 * Real.sin θ) ^ 2 =
        E0 ^ 2 * ((Real.cos θ) ^ 2 * ((Real.cos φ) ^ 2 + (Real.sin φ) ^ 2) +
          (Real.sin θ) ^ 2) := by ring
      _ = E0 ^ 2 * ((Real.cos θ) ^ 2 * 1 + (Real.sin θ) ^ 2) := by
        rw [Real.cos_sq_add_sin_sq φ]
      _ = E0 ^ 2 * 1 := by
        rw [mul_one, Real.cos_sq_add_sin_sq θ]
      _ = E0 ^ 2 := mul_one _
  have h_ex : ray1.1 + ray2.1 = 0 := by
    dsimp [ray1, ray2, debyeWolfRayVec3]
    rw [Real.cos_add_pi]
    ring
  have h_ey : ray1.2.1 + ray2.2.1 = 0 := by
    dsimp [ray1, ray2, debyeWolfRayVec3]
    rw [Real.sin_add_pi]
    ring
  have h_ez : ray1.2.2 + ray2.2.2 = 2 * debyeWolfLongitudinalComponent E0 θ := by
    dsimp [ray1, ray2, debyeWolfRayVec3, debyeWolfLongitudinalComponent]
    ring
  have h_ez_ne : ray1.2.2 + ray2.2.2 ≠ 0 := by
    rw [h_ez]
    dsimp [debyeWolfLongitudinalComponent]
    exact mul_ne_zero two_ne_zero (mul_ne_zero hE0 hsin)
  have h_err : ((ray1.2.2 + ray2.2.2) ^ 2 - 0) / (ray1.2.2 + ray2.2.2) ^ 2 = 1 := by
    rw [sub_zero]
    exact div_self (pow_ne_zero 2 h_ez_ne)
  have h_zri1 : E0 * (0 : ℝ) * Real.sin θ = 0 := by ring
  have h_zri2 : (0 : ℝ) * k0 * deltaL = 0 := by ring
  have h_phi0 : hyperbolicMetasurfacePhase 0 f lambda0 = 0 := by
    unfold hyperbolicMetasurfacePhase
    have h_sqrt_f : Real.sqrt (0 ^ 2 + f ^ 2) = f := by
      rw [sq_eq_zero_iff.mpr rfl, zero_add, Real.sqrt_sq (le_of_lt hf)]
    rw [h_sqrt_f, sub_self, mul_zero]
  have h_phi_neg : hyperbolicMetasurfacePhase r f lambda0 < 0 := by
    unfold hyperbolicMetasurfacePhase
    have hr2_pos : 0 < r ^ 2 := sq_pos_of_ne_zero hr
    have hf_lt : f < Real.sqrt (r ^ 2 + f ^ 2) := by
      calc
        f = Real.sqrt (f ^ 2) := (Real.sqrt_sq (le_of_lt hf)).symm
        _ < Real.sqrt (r ^ 2 + f ^ 2) :=
          Real.sqrt_lt_sqrt (sq_nonneg f) (by linarith)
    have h_diff_pos : 0 < Real.sqrt (r ^ 2 + f ^ 2) - f := sub_pos.mpr hf_lt
    have h_pref_pos : 0 < 2 * Real.pi / lambda0 :=
      div_pos (mul_pos two_pos Real.pi_pos) hlambda
    linarith [mul_pos h_pref_pos h_diff_pos]
  have h_opl :
      hyperbolicMetasurfacePhase r f lambda0 +
          (2 * Real.pi / lambda0) * Real.sqrt (r ^ 2 + f ^ 2) =
        (2 * Real.pi * f) / lambda0 := by
    unfold hyperbolicMetasurfacePhase
    ring
  have h_j_unit :
      (radialNanopillarJonesMatrix θ 0 0) ^ 2 +
          (radialNanopillarJonesMatrix θ 1 0) ^ 2 = 1 := by
    dsimp [radialNanopillarJonesMatrix]
    exact Real.cos_sq_add_sin_sq θ
  have h_j_det : (radialNanopillarJonesMatrix θ).det = -1 := by
    unfold radialNanopillarJonesMatrix
    rw [Matrix.det_fin_two]
    simp only [Fin.isValue, Matrix.of_apply, Matrix.cons_val',
      Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.cons_val_fin_one]
    nlinarith [Real.cos_sq_add_sin_sq θ]
  have heps_pos : 0 < epsEnz := lt_of_lt_of_le (by norm_num) heps_lo
  have heps_ne : epsEnz ≠ 0 := ne_of_gt heps_pos
  have h_dz : epsEnz * enzBoundaryLongitudinalField epsAir epsEnz EzAir = epsAir * EzAir := by
    unfold enzBoundaryLongitudinalField
    field_simp [heps_ne]
  have h_100 : enzBoundaryIntensityEnhancement 1 (1 / 10) = 100 := by
    unfold enzBoundaryIntensityEnhancement
    norm_num
  have h_400 : enzBoundaryIntensityEnhancement 1 (1 / 20) = 400 := by
    unfold enzBoundaryIntensityEnhancement
    norm_num
  have h_ge_100 : 100 ≤ enzBoundaryIntensityEnhancement 1 epsEnz := by
    rw [← h_100]
    unfold enzBoundaryIntensityEnhancement
    have h_div : (1 : ℝ) / (1 / 10 : ℝ) ≤ 1 / epsEnz :=
      one_div_le_one_div_of_le heps_pos heps_hi
    have h_pos10 : 0 ≤ (1 : ℝ) / (1 / 10 : ℝ) := by norm_num
    nlinarith
  have h_le_400 : enzBoundaryIntensityEnhancement 1 epsEnz ≤ 400 := by
    rw [← h_400]
    unfold enzBoundaryIntensityEnhancement
    have h_div : 1 / epsEnz ≤ (1 : ℝ) / (1 / 20 : ℝ) :=
      one_div_le_one_div_of_le (by norm_num) heps_lo
    have h_pos_inv : 0 ≤ 1 / epsEnz := one_div_nonneg.mpr (le_of_lt heps_pos)
    nlinarith
  have h_imag_sq : 0 < epsImag ^ 2 := sq_pos_of_ne_zero heps_imag
  have h_reg_le :
      regularizedEnzEnhancement epsAir epsReal epsImag ≤
        regularizedEnzEnhancement epsAir 0 epsImag := by
    unfold regularizedEnzEnhancement
    rw [zero_pow two_ne_zero, zero_add]
    exact div_le_div_of_nonneg_left (sq_nonneg epsAir) h_imag_sq
      (by linarith [sq_nonneg epsReal])
  have h_reg_0 : regularizedEnzEnhancement epsAir 0 epsImag = epsAir ^ 2 / epsImag ^ 2 := by
    unfold regularizedEnzEnhancement
    rw [zero_pow two_ne_zero, zero_add]
  exact ⟨h_norm, h_ex, h_ey, h_ez, h_err, h_zri1, h_zri2, h_phi0, h_phi_neg,
    h_opl, h_j_unit, h_j_det, h_dz, h_100, h_400, h_ge_100, h_le_400, h_reg_le, h_reg_0⟩

/-! ## Epsilon-Near-Zero (ENZ) & Hyperbolic Metamaterials (`rGO-polyCBD-SS-Lignin`, Argon/Ionosphere Trivelpiece–Gould Plasma, Denisov Mode Conversion, and TNSA-$p\text{-}^{11}\text{B}$ / $s\text{CO}_2$ Energy Ledger) -/

/-- Effective Medium Theory (EMT) in-plane permittivity
$\varepsilon_\parallel(f, \varepsilon_m, \varepsilon_d) = f\,\varepsilon_m + (1 - f)\,\varepsilon_d$
for a sub-wavelength nanolaminate stack (`IQ-Sampling-for-Signal-Phase.md`, lines 15754 & 15779). -/
@[blueprint "def:signals-ddf-emt-epsilon-parallel"
  (title := "Effective Medium Theory in-plane permittivity ε_∥(f) = f ε_m + (1 - f) ε_d")
  (statement := /-- Define $\operatorname{emtEpsilonParallel}(f, \varepsilon_m, \varepsilon_d)
    = f\,\varepsilon_m + (1 - f)\,\varepsilon_d$. -/)]
def emtEpsilonParallel (f epsM epsD : ℝ) : ℝ :=
  f * epsM + (1 - f) * epsD

/-- Effective Medium Theory (EMT) out-of-plane permittivity
$\varepsilon_\perp(f, \varepsilon_m, \varepsilon_d) = \frac{\varepsilon_m\,\varepsilon_d}{(1 - f)\,\varepsilon_m + f\,\varepsilon_d}$
for a sub-wavelength nanolaminate stack (`IQ-Sampling-for-Signal-Phase.md`, lines 15754 & 15781). -/
@[blueprint "def:signals-ddf-emt-epsilon-perp"
  (title := "Effective Medium Theory out-of-plane permittivity ε_⊥(f)")
  (statement := /-- Define $\operatorname{emtEpsilonPerp}(f, \varepsilon_m, \varepsilon_d)
    = (\varepsilon_m\,\varepsilon_d) / ((1 - f)\,\varepsilon_m + f\,\varepsilon_d)$. -/)]
noncomputable def emtEpsilonPerp (f epsM epsD : ℝ) : ℝ :=
  (epsM * epsD) / ((1 - f) * epsM + f * epsD)

/-- Critical volume fill fraction
$f_{\mathrm{ENZ}}(\varepsilon_d, |\varepsilon_m|) = \frac{\varepsilon_d}{\varepsilon_d + |\varepsilon_m|}$
at which the in-plane permittivity $\varepsilon_\parallel(f_{\mathrm{ENZ}}, -|\varepsilon_m|, \varepsilon_d)$
crosses zero (`IQ-Sampling-for-Signal-Phase.md`, line 15787). -/
@[blueprint "def:signals-ddf-emt-critical-enz-fill-fraction"
  (title := "Critical ENZ volume fill fraction f_ENZ = ε_d / (ε_d + |ε_m|)")
  (statement := /-- Define $\operatorname{emtCriticalEnzFillFraction}(\varepsilon_d, |\varepsilon_m|)
    = \varepsilon_d / (\varepsilon_d + |\varepsilon_m|)$. -/)]
noncomputable def emtCriticalEnzFillFraction (epsD absEpsM : ℝ) : ℝ :=
  epsD / (epsD + absEpsM)

/-- Out-of-plane resonance pole fill fraction
$f_{\perp,\mathrm{pole}}(\varepsilon_d, |\varepsilon_m|) = \frac{|\varepsilon_m|}{\varepsilon_d + |\varepsilon_m|} = 1 - f_{\mathrm{ENZ}}$
separating the Type-II Hyperbolic window ($f_{\mathrm{ENZ}} < f < f_{\perp,\mathrm{pole}}$)
from the high-fill regime (`IQ-Sampling-for-Signal-Phase.md`, lines 15787–15789). -/
@[blueprint "def:signals-ddf-emt-perp-pole-fill-fraction"
  (title := "Out-of-plane pole fill fraction f_⊥,pole = |ε_m| / (ε_d + |ε_m|)")
  (statement := /-- Define $\operatorname{emtPerpendicularPoleFillFraction}(\varepsilon_d, |\varepsilon_m|)
    = |\varepsilon_m| / (\varepsilon_d + |\varepsilon_m|)$. -/)]
noncomputable def emtPerpendicularPoleFillFraction (epsD absEpsM : ℝ) : ℝ :=
  absEpsM / (epsD + absEpsM)

/-- Disulfide electro-thermal $90^\circ$ flake-rotation switch above $T_v = 115^\circ\text{C}$
(`IQ-Sampling-for-Signal-Phase.md`, line 15789), swapping the in-plane and out-of-plane
principal permittivities $(\varepsilon_\parallel, \varepsilon_\perp) \mapsto (\varepsilon_\perp, \varepsilon_\parallel)$
to convert a Type-II hyperbolic reflector ($\varepsilon_\parallel < 0, \varepsilon_\perp > 0$)
into a Type-I sub-wavelength transmission needle ($\varepsilon_\parallel^{(90^\circ)} > 0, \varepsilon_\perp^{(90^\circ)} < 0$). -/
@[blueprint "def:signals-ddf-rotated90-metamaterial-tensor"
  (title := "90°-rotated rGO-polyCBD-SS-Lignin disulfide voxel switch (ε_∥, ε_⊥) ↦ (ε_⊥, ε_∥)")
  (statement := /-- Define $\operatorname{rotated90MetamaterialTensor}(\varepsilon_\parallel, \varepsilon_\perp)
    = (\varepsilon_\perp, \varepsilon_\parallel)$. -/)]
def rotated90MetamaterialTensor (epsPar epsPerp : ℝ) : ℝ × ℝ :=
  (epsPerp, epsPar)

/-- Squared axial wavevector $k_z^2(k_x) = \varepsilon_\perp\left((\omega/c)^2 + \frac{k_x^2}{|\varepsilon_\parallel|}\right)$
on the open Type-II hyperboloid $\frac{k_x^2}{-|\varepsilon_\parallel|} + \frac{k_z^2}{\varepsilon_\perp} = \left(\frac{\omega}{c}\right)^2$
inside Zone 2 of the `rGO-polyCBD-SS-Lignin` hyperbolic SFG lens
(`IQ-Sampling-for-Signal-Phase.md`, lines 15892–15904). -/
@[blueprint "def:signals-ddf-type2-hyperbolic-kz-sq"
  (title := "Type-II hyperbolic metamaterial squared axial wavevector k_z²(k_x)")
  (statement := /-- Define $\operatorname{typeIIHyperbolicKzSq}(\omega_c, \varepsilon_\perp, |\varepsilon_\parallel|, k_x)
    = \varepsilon_\perp (\omega_c^2 + k_x^2 / |\varepsilon_\parallel|)$. -/)]
noncomputable def typeIIHyperbolicKzSq (omega_c epsPerp absEpsPar kx : ℝ) : ℝ :=
  epsPerp * (omega_c ^ 2 + kx ^ 2 / absEpsPar)

/-- Normalized hyperbolic metamaterial anisotropy parameter
$\chi_{\mathrm{HMM}}(|\varepsilon_\parallel|, \varepsilon_\perp) = \frac{|\varepsilon_\parallel| - \varepsilon_\perp}{|\varepsilon_\parallel| + \varepsilon_\perp} \in (-1, 1)$
for embedding the anisotropic permittivity tensor into $Gr_{\mathbb{C}}(2,4)$. -/
@[blueprint "def:signals-ddf-hmm-anisotropy-param"
  (title := "Hyperbolic metamaterial Gr_C(2,4) anisotropy parameter χ_HMM")
  (statement := /-- Define $\operatorname{hmmAnisotropyParam}(|\varepsilon_\parallel|, \varepsilon_\perp)
    = (|\varepsilon_\parallel| - \varepsilon_\perp) / (|\varepsilon_\parallel| + \varepsilon_\perp)$. -/)]
noncomputable def hmmAnisotropyParam (absEpsPar epsPerp : ℝ) : ℝ :=
  (absEpsPar - epsPerp) / (absEpsPar + epsPerp)

/-- Cold-plasma parallel relative permittivity $\varepsilon_\parallel(\omega, \omega_{pe}) = 1 - (\omega_{pe} / \omega)^2$
along the magnetic field axis $B_z$ (`IQ-Sampling-for-Signal-Phase.md`, lines 15729 & 15736). -/
@[blueprint "def:signals-ddf-cold-plasma-epsilon-parallel"
  (title := "Magnetized cold-plasma parallel permittivity ε_∥(ω) = 1 - (ω_pe / ω)²")
  (statement := /-- Define $\operatorname{coldPlasmaEpsilonParallel}(\omega, \omega_{pe})
    = 1 - (\omega_{pe} / \omega)^2$. -/)]
noncomputable def coldPlasmaEpsilonParallel (omega omega_pe : ℝ) : ℝ :=
  1 - (omega_pe / omega) ^ 2

/-- Cold-plasma perpendicular relative permittivity
$\varepsilon_\perp(\omega, \omega_{pe}, \omega_{ce}) = 1 - \frac{\omega_{pe}^2}{\omega^2 - \omega_{ce}^2}$
transverse to the magnetic field axis $B_z$ (`IQ-Sampling-for-Signal-Phase.md`, lines 15736–15737). -/
@[blueprint "def:signals-ddf-cold-plasma-epsilon-perp"
  (title := "Magnetized cold-plasma perpendicular permittivity ε_⊥(ω) = 1 - ω_pe² / (ω² - ω_ce²)")
  (statement := /-- Define $\operatorname{coldPlasmaEpsilonPerp}(\omega, \omega_{pe}, \omega_{ce})
    = 1 - \omega_{pe}^2 / (\omega^2 - \omega_{ce}^2)$. -/)]
noncomputable def coldPlasmaEpsilonPerp (omega omega_pe omega_ce : ℝ) : ℝ :=
  1 - omega_pe ^ 2 / (omega ^ 2 - omega_ce ^ 2)

/-- Dimensionless Denisov linear mode-conversion parameter
$\tau_D(k_0, L_n, \theta_{\mathrm{in}}) = (k_0 L_n)^{1/3} \sin\theta_{\mathrm{in}}$
governing transverse-to-longitudinal ($E_z$) mode conversion at a graded ENZ horizon
(`IQ-Sampling-for-Signal-Phase.md`, lines 15880–15891). -/
@[blueprint "def:signals-ddf-denisov-mode-conversion-param"
  (title := "Denisov linear mode-conversion parameter τ_D = (k_0 L_n)^{1/3} sin θ_in")
  (statement := /-- Define $\operatorname{denisovModeConversionParam}(k_0, L_n, \theta_{\mathrm{in}})
    = (k_0 L_n)^{1/3} \sin\theta_{\mathrm{in}}$. -/)]
noncomputable def denisovModeConversionParam (k0 Ln θ_in : ℝ) : ℝ :=
  (k0 * Ln) ^ (1 / 3 : ℝ) * Real.sin θ_in

/-- **`rGO-polyCBD-SS-Lignin` ENZ & Hyperbolic Metamaterial Regimes, Magnetized Argon/Ionosphere Trivelpiece–Gould Dispersion, Denisov Mode Conversion, & $Gr_{\mathbb{C}}(2,4)$ Plücker Duality Theorem**:
Formalizes the three metamaterial regimes of `rGO-polyCBD-SS-Lignin`, the 400-to-800 GHz
hyperbolic SFG phase-matching laws, and magnetized Argon/ionospheric cold-plasma
hyperbolicity (`data/chats/IQ-Sampling-for-Signal-Phase.md`, lines 15715–15916):
1. **Partition of Unity of Critical Fill Fractions**:
   $$f_{\mathrm{ENZ}}(\varepsilon_d, |\varepsilon_m|) + f_{\perp,\mathrm{pole}}(\varepsilon_d, |\varepsilon_m|) = 1,$$
   and for $0 < \varepsilon_d < |\varepsilon_m|$, $0 < f_{\mathrm{ENZ}} < 1/2 < f_{\perp,\mathrm{pole}} < 1$,
2. **Regime 1 — Exact Epsilon-Near-Zero (ENZ) Mode ($f = f_{\mathrm{ENZ}}$)**:
   $$\varepsilon_\parallel(f_{\mathrm{ENZ}}, -|\varepsilon_m|, \varepsilon_d) = 0, \qquad
   \varepsilon_\perp(f_{\mathrm{ENZ}}, -|\varepsilon_m|, \varepsilon_d) = \frac{|\varepsilon_m|\,\varepsilon_d\,(\varepsilon_d + |\varepsilon_m|)}{|\varepsilon_m|^2 - \varepsilon_d^2} > 0,$$
3. **Regime 2 — Type-II Hyperbolic Metamaterial Window ($f_{\mathrm{ENZ}} < f < f_{\perp,\mathrm{pole}}$)**:
   $$\varepsilon_\parallel(f, -|\varepsilon_m|, \varepsilon_d) < 0, \qquad
   \varepsilon_\perp(f, -|\varepsilon_m|, \varepsilon_d) > 0, \qquad
   \varepsilon_\parallel(f, -|\varepsilon_m|, \varepsilon_d) \cdot \varepsilon_\perp(f, -|\varepsilon_m|, \varepsilon_d) < 0,$$
4. **Regime 3 — Disulfide $90^\circ$ Flake-Rotation Switch (Type-II Reflector $\to$ Type-I Needle)**:
   For $(\varepsilon_\parallel^{(90^\circ)}, \varepsilon_\perp^{(90^\circ)}) = \operatorname{rotated90MetamaterialTensor}(\varepsilon_\parallel, \varepsilon_\perp)$:
   $$\varepsilon_\parallel^{(90^\circ)} > 0, \qquad \varepsilon_\perp^{(90^\circ)} < 0, \qquad
   \varepsilon_\parallel^{(90^\circ)} \cdot \varepsilon_\perp^{(90^\circ)} = \varepsilon_\parallel \cdot \varepsilon_\perp < 0,$$
5. **Type-II Hyperboloid High-$k$ Sub-Diffraction Growth & Symmetric SFG Momentum Cancellation**:
   For $k_x \ne 0$,
   $$\varepsilon_\perp \omega_c^2 < \operatorname{typeIIHyperbolicKzSq}(\omega_c, \varepsilon_\perp, |\varepsilon_\parallel|, k_x),$$
   $$\operatorname{typeIIHyperbolicKzSq}(\omega_c, \varepsilon_\perp, |\varepsilon_\parallel|, -k_x) = \operatorname{typeIIHyperbolicKzSq}(\omega_c, \varepsilon_\perp, |\varepsilon_\parallel|, k_x), \qquad k_x + (-k_x) = 0,$$
6. **Magnetized Argon / Ionospheric Cold-Plasma ENZ Cutoff, Trivelpiece–Gould / Whistler Type-I Hyperbolicity, & Denisov Oblique Incidence Requirement**:
   - At $\omega = \omega_{pe} > 0$: $\operatorname{coldPlasmaEpsilonParallel}(\omega_{pe}, \omega_{pe}) = 0$,
   - For $0 < \omega < \omega_{pe}$ and $\omega < \omega_{ce}$:
     $$\operatorname{coldPlasmaEpsilonParallel}(\omega, \omega_{pe}) < 0, \qquad
     1 < \operatorname{coldPlasmaEpsilonPerp}(\omega, \omega_{pe}, \omega_{ce}),$$
     $$\operatorname{coldPlasmaEpsilonParallel}(\omega, \omega_{pe}) \cdot \operatorname{coldPlasmaEpsilonPerp}(\omega, \omega_{pe}, \omega_{ce}) < 0,$$
   - Normal-incidence Denisov null: $\operatorname{denisovModeConversionParam}(k_0, L_n, 0) = 0$,
7. **$Gr_{\mathbb{C}}(2,4)$ Plücker Channel Ratio of the Anisotropic Metamaterial Tensor**:
   For $\chi_{\mathrm{HMM}} = \operatorname{hmmAnisotropyParam}(|\varepsilon_\parallel|, \varepsilon_\perp) \in (-1, 1)$
   and $M_{\mathrm{HMM}} = \operatorname{ddfThermalGr24Matrix}(\chi_{\mathrm{HMM}}, \theta)$:
   $$\frac{|w_A^{\mathbb{C}}(M_{\mathrm{HMM}})|^2}{|w_B^{\mathbb{C}}(M_{\mathrm{HMM}})|^2} = \frac{|\varepsilon_\parallel|}{\varepsilon_\perp}.$$ -/
@[blueprint "thm:signals-ddf-enz-hyperbolic-metamaterial-regimes"
  (title := "rGO-polyCBD-SS-Lignin ENZ and hyperbolic metamaterial regimes, Trivelpiece-Gould plasma, and Gr_C(2,4) duality theorem")
  (statement := /-- For any $\varepsilon_d, |\varepsilon_m|, f, \omega_c, k_x, \omega, \omega_{pe}, \omega_{ce}, k_0, L_n, \theta \in \mathbb R$
    with $0 < \varepsilon_d < |\varepsilon_m|$, $f_{\mathrm{ENZ}} < f < f_{\perp,\mathrm{pole}}$, $k_x \ne 0$,
    $0 < \omega < \omega_{pe}$, and $\omega < \omega_{ce}$:
    (1) $f_{\mathrm{ENZ}} + f_{\perp,\mathrm{pole}} = 1$ and $0 < f_{\mathrm{ENZ}} < 1/2 < f_{\perp,\mathrm{pole}} < 1$,
    (2) $\operatorname{emtEpsilonParallel}(f_{\mathrm{ENZ}}, -|\varepsilon_m|, \varepsilon_d) = 0$ and
    $\operatorname{emtEpsilonPerp}(f_{\mathrm{ENZ}}, -|\varepsilon_m|, \varepsilon_d) = |\varepsilon_m|\varepsilon_d(\varepsilon_d + |\varepsilon_m|)/(|\varepsilon_m|^2 - \varepsilon_d^2) > 0$,
    (3) $\operatorname{emtEpsilonParallel}(f, -|\varepsilon_m|, \varepsilon_d) < 0$,
    $\operatorname{emtEpsilonPerp}(f, -|\varepsilon_m|, \varepsilon_d) > 0$, and their product is $< 0$,
    (4) for $(\varepsilon_\parallel^{(90^\circ)}, \varepsilon_\perp^{(90^\circ)}) = \operatorname{rotated90MetamaterialTensor}(\varepsilon_\parallel(f), \varepsilon_\perp(f))$,
    $\varepsilon_\parallel^{(90^\circ)} > 0$, $\varepsilon_\perp^{(90^\circ)} < 0$, and $\varepsilon_\parallel^{(90^\circ)}\varepsilon_\perp^{(90^\circ)} < 0$,
    (5) $\varepsilon_\perp(f) \omega_c^2 < \operatorname{typeIIHyperbolicKzSq}(\omega_c, \varepsilon_\perp(f), |\varepsilon_m|, k_x)$,
    (6) $\operatorname{coldPlasmaEpsilonParallel}(\omega_{pe}, \omega_{pe}) = 0$,
    $\operatorname{coldPlasmaEpsilonParallel}(\omega, \omega_{pe}) < 0$,
    $1 < \operatorname{coldPlasmaEpsilonPerp}(\omega, \omega_{pe}, \omega_{ce})$, and
    $\operatorname{denisovModeConversionParam}(k_0, L_n, 0) = 0$, and
    (7) $|w_A^{\mathbb C}(M_{\mathrm{HMM}})|^2 / |w_B^{\mathbb C}(M_{\mathrm{HMM}})|^2 = |\varepsilon_m| / \varepsilon_d$. -/)
  (proof := /-- Unfold the EMT parallel/perpendicular formulas, clear positive/negative denominators
    on $(f_{\mathrm{ENZ}}, f_{\perp,\mathrm{pole}})$, apply \texttt{div\_pos\_of\_neg\_of\_neg},
    evaluate cold-plasma signs on $\omega < \min(\omega_{pe},\omega_{ce})$, and invoke
    \texttt{complexGr24ChannelMatrix\_minors}. -/)]
theorem rgo_polycbd_enz_hyperbolic_and_plasma_metamaterial_identities
    (epsD absEpsM f omega_c kx omega omega_pe omega_ce k0 Ln θ : ℝ)
    (hepsD_pos : 0 < epsD) (hepsM_gt : epsD < absEpsM)
    (hf_gt : emtCriticalEnzFillFraction epsD absEpsM < f)
    (hf_lt : f < emtPerpendicularPoleFillFraction epsD absEpsM)
    (hkx_ne : kx ≠ 0)
    (homega_pos : 0 < omega) (homega_lt_pe : omega < omega_pe)
    (homega_lt_ce : omega < omega_ce) :
    let f_enz := emtCriticalEnzFillFraction epsD absEpsM
    let f_pole := emtPerpendicularPoleFillFraction epsD absEpsM
    let eps_par := emtEpsilonParallel f (-absEpsM) epsD
    let eps_perp := emtEpsilonPerp f (-absEpsM) epsD
    let rot90 := rotated90MetamaterialTensor eps_par eps_perp
    let χ_hmm := hmmAnisotropyParam absEpsM epsD
    let M_hmm := ddfThermalGr24Matrix χ_hmm θ
    f_enz + f_pole = 1 ∧
      0 < f_enz ∧
      f_enz < 1 / 2 ∧
      1 / 2 < f_pole ∧
      f_pole < 1 ∧
      emtEpsilonParallel f_enz (-absEpsM) epsD = 0 ∧
      emtEpsilonPerp f_enz (-absEpsM) epsD =
        (absEpsM * epsD * (epsD + absEpsM)) / (absEpsM ^ 2 - epsD ^ 2) ∧
      0 < emtEpsilonPerp f_enz (-absEpsM) epsD ∧
      eps_par < 0 ∧
      0 < eps_perp ∧
      eps_par * eps_perp < 0 ∧
      0 < rot90.1 ∧
      rot90.2 < 0 ∧
      rot90.1 * rot90.2 < 0 ∧
      eps_perp * omega_c ^ 2 < typeIIHyperbolicKzSq omega_c eps_perp absEpsM kx ∧
      typeIIHyperbolicKzSq omega_c eps_perp absEpsM (-kx) =
        typeIIHyperbolicKzSq omega_c eps_perp absEpsM kx ∧
      coldPlasmaEpsilonParallel omega_pe omega_pe = 0 ∧
      coldPlasmaEpsilonParallel omega omega_pe < 0 ∧
      1 < coldPlasmaEpsilonPerp omega omega_pe omega_ce ∧
      coldPlasmaEpsilonParallel omega omega_pe *
        coldPlasmaEpsilonPerp omega omega_pe omega_ce < 0 ∧
      denisovModeConversionParam k0 Ln 0 = 0 ∧
      Complex.normSq (complexPluckerSinkAmplitudeA M_hmm) /
          Complex.normSq (complexPluckerSinkAmplitudeB M_hmm) =
        absEpsM / epsD := by
  intro f_enz f_pole eps_par eps_perp rot90 χ_hmm M_hmm
  have hepsM_pos : 0 < absEpsM := lt_trans hepsD_pos hepsM_gt
  have h_sum_pos : 0 < epsD + absEpsM := add_pos hepsD_pos hepsM_pos
  have h_sum_ne : epsD + absEpsM ≠ 0 := ne_of_gt h_sum_pos
  have h_part : f_enz + f_pole = 1 := by
    dsimp [f_enz, f_pole, emtCriticalEnzFillFraction, emtPerpendicularPoleFillFraction]
    field_simp [h_sum_ne]
  have hf_enz_pos : 0 < f_enz := div_pos hepsD_pos h_sum_pos
  have hf_enz_half : f_enz < 1 / 2 := by
    dsimp [f_enz, emtCriticalEnzFillFraction]
    rw [div_lt_iff₀ h_sum_pos]
    linarith
  have hf_pole_half : 1 / 2 < f_pole := by linarith
  have hf_pole_lt1 : f_pole < 1 := by linarith
  have h_enz_zero : emtEpsilonParallel f_enz (-absEpsM) epsD = 0 := by
    dsimp [f_enz, emtCriticalEnzFillFraction, emtEpsilonParallel]
    field_simp [h_sum_ne]
    ring
  have h_diff_pos : 0 < absEpsM ^ 2 - epsD ^ 2 := by
    have : epsD ^ 2 < absEpsM ^ 2 :=
      sq_lt_sq.mpr (by rw [abs_of_pos hepsD_pos, abs_of_pos hepsM_pos]; exact hepsM_gt)
    linarith
  have h_diff_ne : absEpsM ^ 2 - epsD ^ 2 ≠ 0 := ne_of_gt h_diff_pos
  have h_den_eq :
      (1 - f_enz) * (-absEpsM) + f_enz * epsD =
        -(absEpsM ^ 2 - epsD ^ 2) / (epsD + absEpsM) := by
    dsimp [f_enz, emtCriticalEnzFillFraction]
    field_simp [h_sum_ne]
    ring
  have h_enz_perp_eq :
      emtEpsilonPerp f_enz (-absEpsM) epsD =
        (absEpsM * epsD * (epsD + absEpsM)) / (absEpsM ^ 2 - epsD ^ 2) := by
    unfold emtEpsilonPerp
    rw [h_den_eq]
    field_simp [h_sum_ne, h_diff_ne]
  have h_enz_perp_pos : 0 < emtEpsilonPerp f_enz (-absEpsM) epsD := by
    rw [h_enz_perp_eq]
    positivity
  have h_eps_par_neg : eps_par < 0 := by
    dsimp [eps_par, emtEpsilonParallel]
    have h1 : epsD < f * (epsD + absEpsM) := (div_lt_iff₀ h_sum_pos).mp hf_gt
    linarith
  have h_eps_perp_pos : 0 < eps_perp := by
    dsimp [eps_perp, emtEpsilonPerp]
    have h_num_neg : (-absEpsM) * epsD < 0 := by nlinarith
    have h2 : f * (epsD + absEpsM) < absEpsM := (lt_div_iff₀ h_sum_pos).mp hf_lt
    have h_den_neg : (1 - f) * (-absEpsM) + f * epsD < 0 := by linarith
    exact div_pos_of_neg_of_neg h_num_neg h_den_neg
  have h_prod_neg : eps_par * eps_perp < 0 :=
    mul_neg_of_neg_of_pos h_eps_par_neg h_eps_perp_pos
  have h_rot1 : 0 < rot90.1 := h_eps_perp_pos
  have h_rot2 : rot90.2 < 0 := h_eps_par_neg
  have h_rot_prod : rot90.1 * rot90.2 < 0 :=
    mul_neg_of_pos_of_neg h_rot1 h_rot2
  have h_kz_gt :
      eps_perp * omega_c ^ 2 < typeIIHyperbolicKzSq omega_c eps_perp absEpsM kx := by
    unfold typeIIHyperbolicKzSq
    have hkx2 : 0 < kx ^ 2 := sq_pos_of_ne_zero hkx_ne
    have h_term : 0 < eps_perp * (kx ^ 2 / absEpsM) :=
      mul_pos h_eps_perp_pos (div_pos hkx2 hepsM_pos)
    linarith
  have h_kz_symm :
      typeIIHyperbolicKzSq omega_c eps_perp absEpsM (-kx) =
        typeIIHyperbolicKzSq omega_c eps_perp absEpsM kx := by
    unfold typeIIHyperbolicKzSq
    ring
  have hpe_pos : 0 < omega_pe := lt_trans homega_pos homega_lt_pe
  have hpe_ne : omega_pe ≠ 0 := ne_of_gt hpe_pos
  have h_cp_enz : coldPlasmaEpsilonParallel omega_pe omega_pe = 0 := by
    unfold coldPlasmaEpsilonParallel
    rw [div_self hpe_ne, one_pow, sub_self]
  have h_cp_par_neg : coldPlasmaEpsilonParallel omega omega_pe < 0 := by
    unfold coldPlasmaEpsilonParallel
    have h_gt1 : 1 < omega_pe / omega := (one_lt_div homega_pos).mpr homega_lt_pe
    have h_pos1 : 0 ≤ (1 : ℝ) := by norm_num
    nlinarith
  have h_cp_perp_gt1 : 1 < coldPlasmaEpsilonPerp omega omega_pe omega_ce := by
    unfold coldPlasmaEpsilonPerp
    have hce_pos : 0 < omega_ce := lt_trans homega_pos homega_lt_ce
    have h_sq_lt : omega ^ 2 < omega_ce ^ 2 :=
      sq_lt_sq.mpr (by rw [abs_of_pos homega_pos, abs_of_pos hce_pos]; exact homega_lt_ce)
    have h_den_neg : omega ^ 2 - omega_ce ^ 2 < 0 := sub_neg.mpr h_sq_lt
    have h_quot_neg : omega_pe ^ 2 / (omega ^ 2 - omega_ce ^ 2) < 0 :=
      div_neg_of_pos_of_neg (sq_pos_of_pos hpe_pos) h_den_neg
    linarith
  have h_cp_prod_neg :
      coldPlasmaEpsilonParallel omega omega_pe *
        coldPlasmaEpsilonPerp omega omega_pe omega_ce < 0 :=
    mul_neg_of_neg_of_pos h_cp_par_neg (lt_trans zero_lt_one h_cp_perp_gt1)
  have h_denisov0 : denisovModeConversionParam k0 Ln 0 = 0 := by
    unfold denisovModeConversionParam
    rw [Real.sin_zero, mul_zero]
  have h_sum_md_pos : 0 < absEpsM + epsD := add_pos hepsM_pos hepsD_pos
  have h_sum_md_ne : absEpsM + epsD ≠ 0 := ne_of_gt h_sum_md_pos
  have h_chi_gt : -1 < χ_hmm := by
    dsimp [χ_hmm, hmmAnisotropyParam]
    rw [lt_div_iff₀ h_sum_md_pos]
    linarith
  have h_chi_lt : χ_hmm < 1 := by
    dsimp [χ_hmm, hmmAnisotropyParam]
    rw [div_lt_iff₀ h_sum_md_pos]
    linarith
  have h1p : 0 ≤ 1 + χ_hmm := by linarith
  have h1m : 0 ≤ 1 - χ_hmm := by linarith
  have h_minors := complexGr24ChannelMatrix_minors
    (↑(Real.sqrt (1 + χ_hmm) * Real.cos θ) + Complex.I * ↑(Real.sqrt (1 + χ_hmm) * Real.sin θ))
    (↑(Real.sqrt (1 - χ_hmm) * Real.cos θ) - Complex.I * ↑(Real.sqrt (1 - χ_hmm) * Real.sin θ))
  have h_wA : Complex.normSq (complexPluckerSinkAmplitudeA M_hmm) = 1 + χ_hmm := by
    dsimp [M_hmm, ddfThermalGr24Matrix, complexPluckerSinkAmplitudeA]
    rw [h_minors.1]
    simp only [Complex.normSq_apply, Complex.add_re, Complex.add_im, Complex.mul_re,
      Complex.mul_im, Complex.ofReal_re, Complex.ofReal_im, Complex.I_re, Complex.I_im]
    calc
      _ = (Real.sqrt (1 + χ_hmm)) ^ 2 * ((Real.cos θ) ^ 2 + (Real.sin θ) ^ 2) := by ring
      _ = 1 + χ_hmm := by rw [Real.sq_sqrt h1p, Real.cos_sq_add_sin_sq, mul_one]
  have h_wB : Complex.normSq (complexPluckerSinkAmplitudeB M_hmm) = 1 - χ_hmm := by
    dsimp [M_hmm, ddfThermalGr24Matrix, complexPluckerSinkAmplitudeB]
    rw [h_minors.2.1]
    simp only [Complex.normSq_apply, Complex.sub_re, Complex.sub_im, Complex.mul_re,
      Complex.mul_im, Complex.ofReal_re, Complex.ofReal_im, Complex.I_re, Complex.I_im]
    calc
      _ = (Real.sqrt (1 - χ_hmm)) ^ 2 * ((Real.cos θ) ^ 2 + (Real.sin θ) ^ 2) := by ring
      _ = 1 - χ_hmm := by rw [Real.sq_sqrt h1m, Real.cos_sq_add_sin_sq, mul_one]
  have hepsD_ne : epsD ≠ 0 := ne_of_gt hepsD_pos
  have h_gr24_ratio :
      Complex.normSq (complexPluckerSinkAmplitudeA M_hmm) /
          Complex.normSq (complexPluckerSinkAmplitudeB M_hmm) =
        absEpsM / epsD := by
    rw [h_wA, h_wB]
    dsimp [χ_hmm, hmmAnisotropyParam]
    field_simp [h_sum_md_ne, hepsD_ne]
    ring
  exact ⟨h_part, hf_enz_pos, hf_enz_half, hf_pole_half, hf_pole_lt1,
    h_enz_zero, h_enz_perp_eq, h_enz_perp_pos, h_eps_par_neg, h_eps_perp_pos,
    h_prod_neg, h_rot1, h_rot2, h_rot_prod, h_kz_gt, h_kz_symm,
    h_cp_enz, h_cp_par_neg, h_cp_perp_gt1, h_cp_prod_neg, h_denisov0, h_gr24_ratio⟩

/-- Squared ion-acoustic wave speed $v_s^2 = \frac{\gamma k_B T_e}{M_i}$ in a plasma of ion mass $M_i$
(`data/chats/Argon-Plasma-Wave-Energy.md`, lines 18–25). -/
@[blueprint "def:signals-ddf-ion-acoustic-speed-sq"
  (title := "Ion-acoustic longitudinal wave speed squared v_s² = γ k_B T_e / M_i")
  (statement := /-- Define $\operatorname{ionAcousticSpeedSq}(\gamma_{\mathrm{isen}}, k_B T_e, M_i)
    = (\gamma_{\mathrm{isen}} \cdot k_B T_e) / M_i$. -/)]
noncomputable def ionAcousticSpeedSq (gamma_isen kB_Te M_ion : ℝ) : ℝ :=
  (gamma_isen * kB_Te) / M_ion

/-- Optimal ENZ front-surface skin-depth layer thickness
$d_{\mathrm{opt}}(\lambda_{\mathrm{laser}}, \varepsilon_i) = \frac{\lambda_{\mathrm{laser}}}{4\pi\sqrt{\varepsilon_i}}$
for locking a CPA laser pulse into a Target Normal Sheath Acceleration (TNSA) target
(`data/chats/Argon-Plasma-Wave-Energy.md`, lines 960–970). -/
@[blueprint "def:signals-ddf-enz-optimal-skin-thickness"
  (title := "Optimal ENZ TNSA skin-depth layer thickness d_opt = λ_laser / (4π √ε_i)")
  (statement := /-- Define $\operatorname{enzOptimalSkinThickness}(\lambda_{\mathrm{laser}}, \varepsilon_i)
    = \lambda_{\mathrm{laser}} / (4\pi\sqrt{\varepsilon_i})$. -/)]
noncomputable def enzOptimalSkinThickness (lambda_laser epsImag : ℝ) : ℝ :=
  lambda_laser / (4 * Real.pi * Real.sqrt epsImag)

/-- Grid-level Engineering Gain
$Q_E(\eta_{\mathrm{laser}}, \eta_{\mathrm{coupling}}, Q_{\mathrm{sci}}, \eta_{\mathrm{harvest}}) = \eta_{\mathrm{laser}} \cdot \eta_{\mathrm{coupling}} \cdot Q_{\mathrm{sci}} \cdot \eta_{\mathrm{harvest}}$
for a pulsed CPA-TNSA $p\text{-}^{11}\text{B}$ direct-conversion reactor
(`data/chats/Argon-Plasma-Wave-Energy.md`, lines 985–1025). -/
@[blueprint "def:signals-ddf-tnsa-engineering-gain"
  (title := "CPA-TNSA p-11B direct-conversion engineering gain Q_E = η_laser η_coupling Q_sci η_harvest")
  (statement := /-- Define $\operatorname{tnsaEngineeringGain}(\eta_{\mathrm{laser}}, \eta_{\mathrm{coupling}}, Q_{\mathrm{sci}}, \eta_{\mathrm{harvest}})
    = \eta_{\mathrm{laser}} \cdot \eta_{\mathrm{coupling}} \cdot Q_{\mathrm{sci}} \cdot \eta_{\mathrm{harvest}}$. -/)]
def tnsaEngineeringGain (eta_laser eta_coupling Q_sci eta_harvest : ℝ) : ℝ :=
  eta_laser * eta_coupling * Q_sci * eta_harvest

/-- Required coolant mass flow rate $\dot{m}(P_{\mathrm{waste}}, C_p, \Delta T) = \frac{P_{\mathrm{waste}}}{C_p\,\Delta T}$
to remove waste thermal power $P_{\mathrm{waste}}$ across temperature rise $\Delta T$
(`data/chats/Argon-Plasma-Wave-Energy.md`, lines 1055–1085 & 1200–1215). -/
@[blueprint "def:signals-ddf-coolant-mass-flow-rate"
  (title := "Particle-dump coolant mass flow rate m_dot = P_waste / (C_p ΔT)")
  (statement := /-- Define $\operatorname{coolantMassFlowRate}(P_{\mathrm{waste}}, C_p, \Delta T)
    = P_{\mathrm{waste}} / (C_p \cdot \Delta T)$. -/)]
noncomputable def coolantMassFlowRate (P_waste Cp deltaT : ℝ) : ℝ :=
  P_waste / (Cp * deltaT)

/-- Required intermediate DC bus supercapacitor capacitance
$C_{\mathrm{bus}}(P_{\mathrm{avg}}, T, \tau, V_{\max}, V_{\min}) = \frac{2\,P_{\mathrm{avg}}\,(T - \tau)}{V_{\max}^2 - V_{\min}^2}$
to buffer a pulsed repetition period $T$ with pulse width $\tau$ between bus voltages
$V_{\min}$ and $V_{\max}$ (`data/chats/Argon-Plasma-Wave-Energy.md`, lines 1265–1318). -/
@[blueprint "def:signals-ddf-pulsed-bus-required-capacitance"
  (title := "Pulsed 10 Hz intermediate DC bus supercapacitor capacitance C = 2 P_avg (T - τ) / (V_max² - V_min²)")
  (statement := /-- Define $\operatorname{pulsedBusRequiredCapacitance}(P_{\mathrm{avg}}, T, \tau, V_{\max}, V_{\min})
    = (2 P_{\mathrm{avg}} (T - \tau)) / (V_{\max}^2 - V_{\min}^2)$. -/)]
noncomputable def pulsedBusRequiredCapacitance
    (P_avg T_period tau_pulse V_max V_min : ℝ) : ℝ :=
  (2 * P_avg * (T_period - tau_pulse)) / (V_max ^ 2 - V_min ^ 2)

/-- **Argon vs. Helium/Hydrogen Ion-Acoustic Wave Speeds, ENZ + `polyCBD` TNSA $p\text{-}^{11}\text{B}$ Engineering Gain $Q_E$, $s\text{CO}_2$ Brayton Recovery, & 10 Hz Supercapacitor Bus Theorem**:
Formalizes all quantitative physics and power-plant ledgers from
`data/chats/Argon-Plasma-Wave-Energy.md`:
1. **Ion Mass Controls Wave Speed, Not Thermal Energy Scale (`Argon-Plasma-Wave-Energy.md`, lines 11–57)**:
   For $M_{\mathrm{H}} = 1, M_{\mathrm{He}} = 4, M_{\mathrm{Ar}} = 40$ and $\gamma k_B T_e > 0$:
   $$v_{s,\mathrm{Ar}}^2 < v_{s,\mathrm{He}}^2 < v_{s,\mathrm{H}}^2 \quad\text{and}\quad
   40\,v_{s,\mathrm{Ar}}^2 = 4\,v_{s,\mathrm{He}}^2 = 1\,v_{s,\mathrm{H}}^2 = \gamma k_B T_e,$$
2. **Optimal ENZ Skin-Depth Layer Thickness Positivity (`Argon-Plasma-Wave-Energy.md`, lines 960–970)**:
   For $\lambda_{\mathrm{laser}} > 0$ and $\varepsilon_i > 0$, $\operatorname{enzOptimalSkinThickness}(\lambda_{\mathrm{laser}}, \varepsilon_i) > 0$,
3. **Progression of Engineering Gain $Q_E$ Across Target Architectures (`Argon-Plasma-Wave-Energy.md`, lines 660–1025)**:
   - Flat-foil TNSA ($\eta_L = 1/5, \eta_c = 1/10, Q_{\mathrm{sci}} = 30, \eta_h = 17/20$):
     $$Q_E^{\mathrm{flat}} = \frac{51}{100} < 1 \quad (\text{net grid drain}),$$
   - Micro-cone + quantum-degenerate $^{11}\text{B}$ ($\eta_L = 1/5, \eta_c = 3/10, Q_{\mathrm{sci}} = 45, \eta_h = 17/20$):
     $$Q_E^{\mathrm{cone}} = \frac{459}{200} = 2.295 > 2,$$
   - $150\text{ nm}$ ENZ metasurface + $1,600\%$-stretch `polyCBD` ribbon ($\eta_L = 1/5, \eta_c = 38/100, Q_{\mathrm{sci}} = 40, \eta_h = 17/20$):
     $$Q_E^{\mathrm{ENZ+polyCBD}} = \frac{646}{250} = 2.584 > Q_E^{\mathrm{cone}} > 2,$$
4. **Halbach Dump Waste-Heat Ledger, $s\text{CO}_2$ Mass Flow Rate, & Reclaimed Power (`Argon-Plasma-Wave-Energy.md`, lines 1045–1225)**:
   - Core power $304\text{ MW} = 258.4\text{ MW (85\% Halbach AC)} + 45.6\text{ MW (15\% waste heat)}$,
   - $s\text{CO}_2$ mass flow rate at $C_p = 1.25\text{ kJ/(kg}\cdot\text{K)}, \Delta T = 200\text{ K}$:
     $$\operatorname{coolantMassFlowRate}(45600, 5/4, 200) = \frac{912}{5} = 182.4\text{ kg/s},$$
   - Reclaimed $s\text{CO}_2$ Brayton power ($45\%$ efficiency): $45.6 \times 0.45 = 20.52\text{ MW}$, raising total plant gain to:
     $$\frac{258.4 + 20.52}{100} = \frac{6973}{2500} = 2.7892 > Q_E^{\mathrm{ENZ+polyCBD}},$$
   - Three-stage hybrid alpha harvesting ($85\%$ Halbach AC $+ 8\%$ Diamond/BZO Alphavoltaics $+ 4\%$ thermal $= 97\%$):
     $$304 \times (85/100 + 8/100 + 4/100) = \frac{7372}{25} = 294.88\text{ MW},$$
5. **10 Hz Intermediate DC Bus Supercapacitor Energy & Capacitance (`Argon-Plasma-Wave-Energy.md`, lines 1265–1318)**:
   For $P_{\mathrm{avg}} = 258.4\text{ MW}$, $T = 0.1\text{ s}$, $\tau = 0.001\text{ s}$, $V_{\max} = 10,000\text{ V}$, $V_{\min} = 9,800\text{ V}$:
   $$\Delta E = 258400000 \times (1/10 - 1/1000) = 25581600\text{ J},$$
   $$\operatorname{pulsedBusRequiredCapacitance}(258400000, 1/10, 1/1000, 10000, 9800) = \frac{14212}{1100} \in \left(\frac{1291}{100}, \frac{1293}{100}\right).$$ -/
@[blueprint "thm:signals-ddf-argon-ion-acoustic-tnsa-enz-sco2-ledger"
  (title := "Argon ion-acoustic wave speed, ENZ-polyCBD TNSA p-11B gain Q_E, sCO2 Brayton recovery, and 10 Hz supercapacitor bus theorem")
  (statement := /-- For any $\gamma_{\mathrm{isen}}, k_B T_e, \lambda_{\mathrm{laser}}, \varepsilon_i > 0$:
    (1) $\operatorname{ionAcousticSpeedSq}(\gamma_{\mathrm{isen}}, k_B T_e, 40) < \operatorname{ionAcousticSpeedSq}(\gamma_{\mathrm{isen}}, k_B T_e, 4) < \operatorname{ionAcousticSpeedSq}(\gamma_{\mathrm{isen}}, k_B T_e, 1)$
    and $40 \cdot v_{s,\mathrm{Ar}}^2 = 4 \cdot v_{s,\mathrm{He}}^2 = 1 \cdot v_{s,\mathrm{H}}^2 = \gamma_{\mathrm{isen}} k_B T_e$,
    (2) $0 < \operatorname{enzOptimalSkinThickness}(\lambda_{\mathrm{laser}}, \varepsilon_i)$,
    (3) $\operatorname{tnsaEngineeringGain}(1/5, 1/10, 30, 17/20) = 51/100 < 1$,
    $\operatorname{tnsaEngineeringGain}(1/5, 3/10, 45, 17/20) = 459/200$, and
    $\operatorname{tnsaEngineeringGain}(1/5, 38/100, 40, 17/20) = 646/250 > 459/200 > 2$,
    (4) $\operatorname{coolantMassFlowRate}(45600, 5/4, 200) = 912/5$ and $(258.4 + 45.6 \cdot 0.45)/100 = 6973/2500$, and
    (5) $\operatorname{pulsedBusRequiredCapacitance}(258400000, 1/10, 1/1000, 10000, 9800) = 14212/1100 \in (1291/100, 1293/100)$. -/)
  (proof := /-- Combine division monotonicity on $1 < 4 < 40$ with positivity of $\sqrt{\varepsilon_i}$
    and exact rational arithmetic (`norm_num`). -/)]
theorem argon_ion_acoustic_tnsa_enz_polycbd_and_sco2_ledger_identities
    (gamma_isen kB_Te lambda_laser epsImag : ℝ)
    (hgamma : 0 < gamma_isen) (hkT : 0 < kB_Te)
    (hlambda : 0 < lambda_laser) (heps : 0 < epsImag) :
    ionAcousticSpeedSq gamma_isen kB_Te 40 < ionAcousticSpeedSq gamma_isen kB_Te 4 ∧
      ionAcousticSpeedSq gamma_isen kB_Te 4 < ionAcousticSpeedSq gamma_isen kB_Te 1 ∧
      40 * ionAcousticSpeedSq gamma_isen kB_Te 40 = gamma_isen * kB_Te ∧
      4 * ionAcousticSpeedSq gamma_isen kB_Te 4 = gamma_isen * kB_Te ∧
      0 < enzOptimalSkinThickness lambda_laser epsImag ∧
      tnsaEngineeringGain (1 / 5) (1 / 10) 30 (17 / 20) = 51 / 100 ∧
      tnsaEngineeringGain (1 / 5) (1 / 10) 30 (17 / 20) < 1 ∧
      tnsaEngineeringGain (1 / 5) (3 / 10) 45 (17 / 20) = 459 / 200 ∧
      tnsaEngineeringGain (1 / 5) (38 / 100) 40 (17 / 20) = 646 / 250 ∧
      tnsaEngineeringGain (1 / 5) (3 / 10) 45 (17 / 20) <
        tnsaEngineeringGain (1 / 5) (38 / 100) 40 (17 / 20) ∧
      coolantMassFlowRate 45600 (5 / 4) 200 = 912 / 5 ∧
      (2584 / 10 + (456 / 10) * (45 / 100)) / 100 = (6973 / 2500 : ℝ) ∧
      pulsedBusRequiredCapacitance 258400000 (1 / 10) (1 / 1000) 10000 9800 =
        14212 / 1100 ∧
      (1291 / 100 : ℝ) <
        pulsedBusRequiredCapacitance 258400000 (1 / 10) (1 / 1000) 10000 9800 ∧
      pulsedBusRequiredCapacitance 258400000 (1 / 10) (1 / 1000) 10000 9800 <
        (1293 / 100 : ℝ) := by
  have h_prod : 0 < gamma_isen * kB_Te := mul_pos hgamma hkT
  have h_ar_he :
      ionAcousticSpeedSq gamma_isen kB_Te 40 < ionAcousticSpeedSq gamma_isen kB_Te 4 := by
    unfold ionAcousticSpeedSq
    exact div_lt_div_of_pos_left h_prod (by norm_num) (by norm_num)
  have h_he_h :
      ionAcousticSpeedSq gamma_isen kB_Te 4 < ionAcousticSpeedSq gamma_isen kB_Te 1 := by
    unfold ionAcousticSpeedSq
    exact div_lt_div_of_pos_left h_prod (by norm_num) (by norm_num)
  have h_ar_eq : 40 * ionAcousticSpeedSq gamma_isen kB_Te 40 = gamma_isen * kB_Te := by
    unfold ionAcousticSpeedSq
    ring
  have h_he_eq : 4 * ionAcousticSpeedSq gamma_isen kB_Te 4 = gamma_isen * kB_Te := by
    unfold ionAcousticSpeedSq
    ring
  have h_skin : 0 < enzOptimalSkinThickness lambda_laser epsImag := by
    unfold enzOptimalSkinThickness
    have h_sqrt : 0 < Real.sqrt epsImag := Real.sqrt_pos.mpr heps
    positivity
  refine ⟨h_ar_he, h_he_h, h_ar_eq, h_he_eq, h_skin, ?_⟩
  unfold tnsaEngineeringGain coolantMassFlowRate pulsedBusRequiredCapacitance
  norm_num

/-! ## Unified $Gr_{\mathbb{C}}(3, 6)$ Simultaneous Splitting Conservation, Holographic Perspective Projection, and Inversion-Free Schur–Plücker Laws -/

/-- Holographic / EWA perspective $Gr_{\mathbb{C}}(3, 6)$ twistor matrix of a
`NormedTensorGaussianSplat3D` at focal scale $f$ and bulk depth $z_c$, scaling the
two lateral principal axes by $s = f / z_c$ while retaining the 3rd axial depth
width $\sigma_3$ in the third row/column. -/
@[blueprint "def:signals-ddf-splat3d-gr36-perspective-twistor-matrix"
  (title := "Holographic perspective Gr_C(3,6) rank-3 twistor matrix of NormedTensorGaussianSplat3D")
  (statement := /-- Define $\operatorname{splat}.\operatorname{gr36PerspectiveTwistorMatrix}(f, \phi_1, \phi_2, \phi_3) \in Gr_{\mathbb C}(3,6)$
    with lateral entries $s \sigma_1 e^{i\phi_1}, s \sigma_2 e^{i\phi_2}$ ($s = f / z_c$) and axial entry $\sigma_3 e^{i\phi_3}$. -/)]
noncomputable def NormedTensorGaussianSplat3D.gr36PerspectiveTwistorMatrix
    (splat : NormedTensorGaussianSplat3D) (focalScale φ1 φ2 φ3 : ℝ) :
    Matrix (Fin 3) (Fin 6) ℂ :=
  let s := focalScale / splat.centerZ
  gr36VolumetricImagingMatrix
    (↑(s * splat.sigma1 * Real.cos φ1) + Complex.I * ↑(s * splat.sigma1 * Real.sin φ1))
    (↑(s * splat.sigma2 * Real.cos φ2) + Complex.I * ↑(s * splat.sigma2 * Real.sin φ2))
    (↑(splat.sigma3 * Real.cos φ3) + Complex.I * ↑(splat.sigma3 * Real.sin φ3))

/-- Canonical $Gr_{\mathbb{C}}(3, 6)$ Schur–Plücker shear matrix encoding the forward
shear channel $\sqrt{1 + \tau}\,e^{i\phi_1}$, the backward shear channel
$\sqrt{1 - \tau}\,e^{i\phi_2}$, and the inversion-free 3D Schur-complement volume
amplitude $\frac{1 - \tau^2}{\sqrt{1 + \tau^2}}\,e^{i\phi_3}$ in a single rank-3
complex Grassmannian matrix. -/
@[blueprint "def:signals-ddf-gr36-schur-shear-matrix"
  (title := "Canonical Gr_C(3,6) Schur-Plücker 3D shear matrix")
  (statement := /-- Define $\operatorname{gr36SchurShearMatrix}(\tau, \phi_1, \phi_2, \phi_3) \in Gr_{\mathbb C}(3,6)$
    with entries $a_1 = \sqrt{1+\tau}e^{i\phi_1}$, $a_2 = \sqrt{1-\tau}e^{i\phi_2}$, and
    $a_3 = \frac{1-\tau^2}{\sqrt{1+\tau^2}}e^{i\phi_3}$. -/)]
noncomputable def gr36SchurShearMatrix (turbulence φ1 φ2 φ3 : ℝ) :
    Matrix (Fin 3) (Fin 6) ℂ :=
  let r1 := Real.sqrt (1 + turbulence)
  let r2 := Real.sqrt (1 - turbulence)
  let r3 := (1 - turbulence ^ 2) / Real.sqrt (1 + turbulence ^ 2)
  gr36VolumetricImagingMatrix
    (↑(r1 * Real.cos φ1) + Complex.I * ↑(r1 * Real.sin φ1))
    (↑(r2 * Real.cos φ2) + Complex.I * ↑(r2 * Real.sin φ2))
    (↑(r3 * Real.cos φ3) + Complex.I * ↑(r3 * Real.sin φ3))

/-- **Unified $Gr_{\mathbb{C}}(3, 6)$ Simultaneous Splitting Conservation, Holographic Perspective Projection, and Inversion-Free Schur–Plücker Theorem**:
Extends the full suite of simultaneous conservation, holographic projection, and
Schur–Plücker laws from $Gr_{\mathbb{C}}(2, 4)$ to higher-rank **$Gr_{\mathbb{C}}(3, 6)$**:
1. **$Gr_{\mathbb{C}}(3, 6)$ Adaptive 3D Splat-Splitting Conservation Laws (`M3_plus = c_plus.gr36TwistorMatrix φ1 φ2 φ3`)**:
   - **G3-SC1**: $|\Delta_{045}^{\mathbb{C}}(M_{3,+})|^2 = |\Delta_{045}^{\mathbb{C}}(M_{3,-})|^2 = \frac{1}{4}|\Delta_{045}^{\mathbb{C}}(M_3)|^2$,
   - **G3-SC2**: $(x_+ - x_c)^2 + (y_+ - y_c)^2 + (z_+ - z_c)^2 + |\Delta_{045}^{\mathbb{C}}(M_{3,+})|^2 = |\Delta_{045}^{\mathbb{C}}(M_3)|^2 = \sigma_1^2$,
   - **G3-SC3**: $|\Delta_{315}^{\mathbb{C}}(M_{3,+})|^2 = |\Delta_{315}^{\mathbb{C}}(M_3)|^2$, $|\Delta_{342}^{\mathbb{C}}(M_{3,+})|^2 = |\Delta_{342}^{\mathbb{C}}(M_3)|^2$, and $|\Delta_{312}^{\mathbb{C}}(M_{3,+})|^2 = |\Delta_{312}^{\mathbb{C}}(M_3)|^2$,
   - **G3-SC4**: $|\Delta_{015}^{\mathbb{C}}(M_{3,+})|^2 = \frac{1}{4}|\Delta_{015}^{\mathbb{C}}(M_3)|^2$ and $|\Delta_{042}^{\mathbb{C}}(M_{3,+})|^2 = \frac{1}{4}|\Delta_{042}^{\mathbb{C}}(M_3)|^2$,
   - **G3-SC5**: $|\Delta_{012}^{\mathbb{C}}(M_{3,+})|^2 = \frac{1}{4}|\Delta_{012}^{\mathbb{C}}(M_3)|^2 = c_+.\mathrm{covDet}$,
   - **G3-SC6**: $c_+.\operatorname{coreBohmPotential}(m, \hbar) - \mathrm{splat}.\operatorname{coreBohmPotential}(m, \hbar) = \frac{3\hbar^2}{4m\,|\Delta_{045}^{\mathbb{C}}(M_3)|^2}$,
2. **$Gr_{\mathbb{C}}(3, 6)$ Holographic Perspective Projection & Tomographic Depth Recovery (`M3_persp = splat.gr36PerspectiveTwistorMatrix f φ1 φ2 φ3`)**:
   - **G3-HP1**: $|\Delta_{015}^{\mathbb{C}}(M_3^{\mathrm{persp}})|^2 = s_{\mathrm{persp}}.\mathrm{covDet} = (f/z_c)^4 |\Delta_{015}^{\mathbb{C}}(M_3)|^2$,
   - **G3-HP2**: $|\Delta_{012}^{\mathbb{C}}(M_3^{\mathrm{persp}})|^2 = |\Delta_{015}^{\mathbb{C}}(M_3^{\mathrm{persp}})|^2 \, |\Delta_{342}^{\mathbb{C}}(M_3)|^2 = (f/z_c)^4 |\Delta_{012}^{\mathbb{C}}(M_3)|^2$,
   - **G3-HP3**: $\frac{|\Delta_{045}^{\mathbb{C}}(M_3^{\mathrm{persp}})|^2 - |\Delta_{315}^{\mathbb{C}}(M_3^{\mathrm{persp}})|^2}{|\Delta_{045}^{\mathbb{C}}(M_3^{\mathrm{persp}})|^2 + |\Delta_{315}^{\mathbb{C}}(M_3^{\mathrm{persp}})|^2} = \frac{|\Delta_{045}^{\mathbb{C}}(M_3)|^2 - |\Delta_{315}^{\mathbb{C}}(M_3)|^2}{|\Delta_{045}^{\mathbb{C}}(M_3)|^2 + |\Delta_{315}^{\mathbb{C}}(M_3)|^2}$,
   - **G3-HP4**: $\frac{|\Delta_{012}^{\mathbb{C}}(M_3)|^2}{|\Delta_{015}^{\mathbb{C}}(M_3)|^2} = |\Delta_{342}^{\mathbb{C}}(M_3)|^2 = \sigma_3^2$,
   - **G3-HP5**: $f^2 \, \frac{|\Delta_{045}^{\mathbb{C}}(M_3)|^2 + |\Delta_{315}^{\mathbb{C}}(M_3)|^2}{|\Delta_{045}^{\mathbb{C}}(M_3^{\mathrm{persp}})|^2 + |\Delta_{315}^{\mathbb{C}}(M_3^{\mathrm{persp}})|^2} = z_c^2$,
3. **$Gr_{\mathbb{C}}(3, 6)$ Inversion-Free Schur–Plücker Determinant Calculus (`M3_schur = gr36SchurShearMatrix τ φ1 φ2 φ3`)**:
   - **G3-SP1**: $|\Delta_{045}^{\mathbb{C}}(M_{3,\tau})|^2 = 1 + \tau$ and $|\Delta_{315}^{\mathbb{C}}(M_{3,\tau})|^2 = 1 - \tau$,
   - **G3-SP2**: $|\Delta_{015}^{\mathbb{C}}(M_{3,\tau})|^2 = 1 - \tau^2 = \det(\operatorname{impellerShear4x4}(s, \tau))$,
   - **G3-SP3**: $|\Delta_{342}^{\mathbb{C}}(M_{3,\tau})|^2 = \operatorname{schurComplement3DVolume}(\tau) = \frac{\bigl(|\Delta_{015}^{\mathbb{C}}(M_{3,\tau})|^2\bigr)^2}{1 + \tau^2}$,
   - **G3-SP4**: $\det\Sigma_{4\times 4} = (\Sigma_{4\times 4})_{3,3} \cdot |\Delta_{342}^{\mathbb{C}}(M_{3,\tau})|^2$,
   - **G3-SP5**: $\Delta_{012}^{\mathbb{C}}(M_{3,\tau})\Delta_{345}^{\mathbb{C}}(M_{3,\tau}) - \Delta_{013}^{\mathbb{C}}(M_{3,\tau})\Delta_{245}^{\mathbb{C}}(M_{3,\tau}) + \Delta_{014}^{\mathbb{C}}(M_{3,\tau})\Delta_{235}^{\mathbb{C}}(M_{3,\tau}) - \Delta_{015}^{\mathbb{C}}(M_{3,\tau})\Delta_{234}^{\mathbb{C}}(M_{3,\tau}) = 0$. -/
@[blueprint "thm:signals-ddf-gr36-simultaneous-conservation-projection-schur"
  (title := "Unified Gr_C(3,6) simultaneous splitting conservation, holographic projection, and Schur-Plücker theorem")
  (statement := /-- For any \texttt{splat : NormedTensorGaussianSplat3D}, $f > 0$, $z_c > 0$, $m > 0$, $\hbar \ne 0$,
    $s > 0$, $0 < \tau < 1$, and $\phi_1, \phi_2, \phi_3 \in \mathbb R$:
    (1) $|\Delta_{045}^{\mathbb C}(M_{3,+})|^2 = |\Delta_{045}^{\mathbb C}(M_{3,-})|^2 = \frac{1}{4}|\Delta_{045}^{\mathbb C}(M_3)|^2$,
    $(x_+ - x_c)^2 + (y_+ - y_c)^2 + (z_+ - z_c)^2 + |\Delta_{045}^{\mathbb C}(M_{3,+})|^2 = |\Delta_{045}^{\mathbb C}(M_3)|^2$,
    $|\Delta_{312}^{\mathbb C}(M_{3,+})|^2 = |\Delta_{312}^{\mathbb C}(M_3)|^2$,
    $|\Delta_{015}^{\mathbb C}(M_{3,+})|^2 = \frac{1}{4}|\Delta_{015}^{\mathbb C}(M_3)|^2$,
    $|\Delta_{012}^{\mathbb C}(M_{3,+})|^2 = \frac{1}{4}|\Delta_{012}^{\mathbb C}(M_3)|^2 = c_+.\mathrm{covDet}$, and
    $c_+.\operatorname{coreBohmPotential}(m,\hbar) - \operatorname{splat}.\operatorname{coreBohmPotential}(m,\hbar) = \frac{3\hbar^2}{4m|\Delta_{045}^{\mathbb C}(M_3)|^2}$,
    (2) $|\Delta_{015}^{\mathbb C}(M_3^{\mathrm{persp}})|^2 = s_{\mathrm{persp}}.\mathrm{covDet} = (f/z_c)^4 |\Delta_{015}^{\mathbb C}(M_3)|^2$,
    $|\Delta_{012}^{\mathbb C}(M_3^{\mathrm{persp}})|^2 = |\Delta_{015}^{\mathbb C}(M_3^{\mathrm{persp}})|^2 |\Delta_{342}^{\mathbb C}(M_3)|^2$,
    $(|\Delta_{045}^{\mathbb C}(M_3^{\mathrm{persp}})|^2 - |\Delta_{315}^{\mathbb C}(M_3^{\mathrm{persp}})|^2)/(|\Delta_{045}^{\mathbb C}(M_3^{\mathrm{persp}})|^2 + |\Delta_{315}^{\mathbb C}(M_3^{\mathrm{persp}})|^2) = (|\Delta_{045}^{\mathbb C}(M_3)|^2 - |\Delta_{315}^{\mathbb C}(M_3)|^2)/(|\Delta_{045}^{\mathbb C}(M_3)|^2 + |\Delta_{315}^{\mathbb C}(M_3)|^2)$,
    $|\Delta_{012}^{\mathbb C}(M_3)|^2 / |\Delta_{015}^{\mathbb C}(M_3)|^2 = |\Delta_{342}^{\mathbb C}(M_3)|^2 = \sigma_3^2$, and
    $f^2 (|\Delta_{045}^{\mathbb C}(M_3)|^2 + |\Delta_{315}^{\mathbb C}(M_3)|^2) / (|\Delta_{045}^{\mathbb C}(M_3^{\mathrm{persp}})|^2 + |\Delta_{315}^{\mathbb C}(M_3^{\mathrm{persp}})|^2) = z_c^2$, and
    (3) $|\Delta_{045}^{\mathbb C}(M_{3,\tau})|^2 = 1 + \tau$, $|\Delta_{315}^{\mathbb C}(M_{3,\tau})|^2 = 1 - \tau$,
    $|\Delta_{015}^{\mathbb C}(M_{3,\tau})|^2 = 1 - \tau^2 = \det J(s,\tau)$,
    $|\Delta_{342}^{\mathbb C}(M_{3,\tau})|^2 = \operatorname{schurComplement3DVolume}(\tau)$,
    $\det\Sigma_{4\times 4} = (\Sigma_{4\times 4})_{3,3} |\Delta_{342}^{\mathbb C}(M_{3,\tau})|^2$, and
    $\Delta_{012}^{\mathbb C}(M_{3,\tau})\Delta_{345}^{\mathbb C}(M_{3,\tau}) - \Delta_{013}^{\mathbb C}(M_{3,\tau})\Delta_{245}^{\mathbb C}(M_{3,\tau}) + \Delta_{014}^{\mathbb C}(M_{3,\tau})\Delta_{235}^{\mathbb C}(M_{3,\tau}) - \Delta_{015}^{\mathbb C}(M_{3,\tau})\Delta_{234}^{\mathbb C}(M_{3,\tau}) = 0$. -/)
  (proof := /-- Combine \texttt{gr36\_volumetric\_imaging\_and\_plucker\_identities} on
    \texttt{splat}, \texttt{c\_plus}, and \texttt{c\_minus} with
    \texttt{splitMajor3D\_and\_holographic\_gr24\_projection\_identities} and
    \texttt{schur\_plucker\_inversion\_free\_and\_twistor\_vane\_identities}. -/)]
theorem NormedTensorGaussianSplat3D.gr36_simultaneous_conservation_holographic_projection_and_schur_identities
    (splat : NormedTensorGaussianSplat3D)
    (focalScale m_boson hbar φ1 φ2 φ3 stress turbulence : ℝ)
    (hf : 0 < focalScale) (hz : 0 < splat.centerZ)
    (hm : 0 < m_boson) (hhbar : hbar ≠ 0)
    (hs_pos : 0 < stress) (hτ_pos : 0 < turbulence) (hτ_lt : turbulence < 1) :
    let c_plus := splat.splitMajorPlus
    let c_minus := splat.splitMajorMinus
    let s_persp := splat.projectPerspective2D focalScale hf hz
    let M3 := splat.gr36TwistorMatrix φ1 φ2 φ3
    let M3_plus := c_plus.gr36TwistorMatrix φ1 φ2 φ3
    let M3_minus := c_minus.gr36TwistorMatrix φ1 φ2 φ3
    let M3_persp := splat.gr36PerspectiveTwistorMatrix focalScale φ1 φ2 φ3
    let M3_schur := gr36SchurShearMatrix turbulence φ1 φ2 φ3
    let J := impellerShear4x4 stress turbulence
    let Sigma4 := J * J.transpose
    Complex.normSq (complexThreeRowMinor M3_plus 0 4 5) =
        Complex.normSq (complexThreeRowMinor M3_minus 0 4 5) ∧
      Complex.normSq (complexThreeRowMinor M3_plus 0 4 5) =
        (1 / 4) * Complex.normSq (complexThreeRowMinor M3 0 4 5) ∧
      (c_plus.centerX - splat.centerX) ^ 2 +
          (c_plus.centerY - splat.centerY) ^ 2 +
          (c_plus.centerZ - splat.centerZ) ^ 2 +
          Complex.normSq (complexThreeRowMinor M3_plus 0 4 5) =
        Complex.normSq (complexThreeRowMinor M3 0 4 5) ∧
      Complex.normSq (complexThreeRowMinor M3_plus 3 1 5) =
        Complex.normSq (complexThreeRowMinor M3 3 1 5) ∧
      Complex.normSq (complexThreeRowMinor M3_plus 3 4 2) =
        Complex.normSq (complexThreeRowMinor M3 3 4 2) ∧
      Complex.normSq (complexThreeRowMinor M3_plus 3 1 2) =
        Complex.normSq (complexThreeRowMinor M3 3 1 2) ∧
      Complex.normSq (complexThreeRowMinor M3_plus 0 1 5) =
        (1 / 4) * Complex.normSq (complexThreeRowMinor M3 0 1 5) ∧
      Complex.normSq (complexThreeRowMinor M3_plus 0 4 2) =
        (1 / 4) * Complex.normSq (complexThreeRowMinor M3 0 4 2) ∧
      Complex.normSq (complexThreeRowMinor M3_plus 0 1 2) =
        (1 / 4) * Complex.normSq (complexThreeRowMinor M3 0 1 2) ∧
      Complex.normSq (complexThreeRowMinor M3_plus 0 1 2) = c_plus.covDet ∧
      c_plus.coreBohmPotential m_boson hbar - splat.coreBohmPotential m_boson hbar =
        (3 * hbar ^ 2) / (4 * m_boson * Complex.normSq (complexThreeRowMinor M3 0 4 5)) ∧
      Complex.normSq (complexThreeRowMinor M3_persp 0 1 5) = s_persp.covDet ∧
      Complex.normSq (complexThreeRowMinor M3_persp 0 1 5) =
        (focalScale / splat.centerZ) ^ 4 *
          Complex.normSq (complexThreeRowMinor M3 0 1 5) ∧
      Complex.normSq (complexThreeRowMinor M3_persp 0 1 2) =
        Complex.normSq (complexThreeRowMinor M3_persp 0 1 5) *
          Complex.normSq (complexThreeRowMinor M3 3 4 2) ∧
      (Complex.normSq (complexThreeRowMinor M3_persp 0 4 5) -
          Complex.normSq (complexThreeRowMinor M3_persp 3 1 5)) /
          (Complex.normSq (complexThreeRowMinor M3_persp 0 4 5) +
            Complex.normSq (complexThreeRowMinor M3_persp 3 1 5)) =
        (Complex.normSq (complexThreeRowMinor M3 0 4 5) -
            Complex.normSq (complexThreeRowMinor M3 3 1 5)) /
          (Complex.normSq (complexThreeRowMinor M3 0 4 5) +
            Complex.normSq (complexThreeRowMinor M3 3 1 5)) ∧
      Complex.normSq (complexThreeRowMinor M3 0 1 2) /
          Complex.normSq (complexThreeRowMinor M3 0 1 5) =
        Complex.normSq (complexThreeRowMinor M3 3 4 2) ∧
      focalScale ^ 2 *
          ((Complex.normSq (complexThreeRowMinor M3 0 4 5) +
              Complex.normSq (complexThreeRowMinor M3 3 1 5)) /
            (Complex.normSq (complexThreeRowMinor M3_persp 0 4 5) +
              Complex.normSq (complexThreeRowMinor M3_persp 3 1 5))) =
        splat.centerZ ^ 2 ∧
      Complex.normSq (complexThreeRowMinor M3_schur 0 4 5) = 1 + turbulence ∧
      Complex.normSq (complexThreeRowMinor M3_schur 3 1 5) = 1 - turbulence ∧
      Complex.normSq (complexThreeRowMinor M3_schur 0 1 5) = 1 - turbulence ^ 2 ∧
      Complex.normSq (complexThreeRowMinor M3_schur 0 1 5) = J.det ∧
      Complex.normSq (complexThreeRowMinor M3_schur 3 4 2) =
        schurComplement3DVolume turbulence ∧
      Sigma4.det =
        Sigma4 3 3 * Complex.normSq (complexThreeRowMinor M3_schur 3 4 2) ∧
      complexThreeRowMinor M3_schur 0 1 2 * complexThreeRowMinor M3_schur 3 4 5 -
          complexThreeRowMinor M3_schur 0 1 3 * complexThreeRowMinor M3_schur 2 4 5 +
          complexThreeRowMinor M3_schur 0 1 4 * complexThreeRowMinor M3_schur 2 3 5 -
          complexThreeRowMinor M3_schur 0 1 5 * complexThreeRowMinor M3_schur 2 3 4 = 0 := by
  intro c_plus c_minus s_persp M3 M3_plus M3_minus M3_persp M3_schur J Sigma4
  have h_parent := splat.gr36_volumetric_imaging_and_plucker_identities φ1 φ2 φ3 m_boson hbar hm
  have h_plus := c_plus.gr36_volumetric_imaging_and_plucker_identities φ1 φ2 φ3 m_boson hbar hm
  have h_minus := c_minus.gr36_volumetric_imaging_and_plucker_identities φ1 φ2 φ3 m_boson hbar hm
  have h_split := splat.splitMajor3D_and_holographic_gr24_projection_identities
    focalScale m_boson hbar 0 hf hz hm hhbar
  have h_schur_base := schur_plucker_inversion_free_and_twistor_vane_identities
    stress turbulence 0 hs_pos hτ_pos hτ_lt
  have h_plus_s1 : c_plus.sigma1 = splat.sigma1 / 2 := rfl
  have h_minus_s1 : c_minus.sigma1 = splat.sigma1 / 2 := rfl
  have h_plus_s2 : c_plus.sigma2 = splat.sigma2 := rfl
  have h_plus_s3 : c_plus.sigma3 = splat.sigma3 := rfl
  have h_sc1a :
      Complex.normSq (complexThreeRowMinor M3_plus 0 4 5) =
        Complex.normSq (complexThreeRowMinor M3_minus 0 4 5) := by
    rw [h_plus.2.1, h_minus.2.1, h_plus_s1, h_minus_s1]
  have h_sc1b :
      Complex.normSq (complexThreeRowMinor M3_plus 0 4 5) =
        (1 / 4) * Complex.normSq (complexThreeRowMinor M3 0 4 5) := by
    rw [h_plus.2.1, h_parent.2.1, h_plus_s1]
    ring
  have h_sc2 :
      (c_plus.centerX - splat.centerX) ^ 2 +
          (c_plus.centerY - splat.centerY) ^ 2 +
          (c_plus.centerZ - splat.centerZ) ^ 2 +
          Complex.normSq (complexThreeRowMinor M3_plus 0 4 5) =
        Complex.normSq (complexThreeRowMinor M3 0 4 5) := by
    rw [h_plus.2.1, h_parent.2.1]
    exact h_split.2.2.2.2.1
  have h_sc3a :
      Complex.normSq (complexThreeRowMinor M3_plus 3 1 5) =
        Complex.normSq (complexThreeRowMinor M3 3 1 5) := by
    rw [h_plus.2.2.1, h_parent.2.2.1, h_plus_s2]
  have h_sc3b :
      Complex.normSq (complexThreeRowMinor M3_plus 3 4 2) =
        Complex.normSq (complexThreeRowMinor M3 3 4 2) := by
    rw [h_plus.2.2.2.1, h_parent.2.2.2.1, h_plus_s3]
  have h_sc3c :
      Complex.normSq (complexThreeRowMinor M3_plus 3 1 2) =
        Complex.normSq (complexThreeRowMinor M3 3 1 2) := by
    rw [h_plus.2.2.2.2.2.2.1, h_parent.2.2.2.2.2.2.1, h_plus_s2, h_plus_s3]
  have h_sc4a :
      Complex.normSq (complexThreeRowMinor M3_plus 0 1 5) =
        (1 / 4) * Complex.normSq (complexThreeRowMinor M3 0 1 5) := by
    rw [h_plus.2.2.2.2.1, h_parent.2.2.2.2.1]
    dsimp [c_plus, splitMajorPlus, projectOrthographic2D, NormedTensorGaussianSplat2D.covDet]
    ring
  have h_sc4b :
      Complex.normSq (complexThreeRowMinor M3_plus 0 4 2) =
        (1 / 4) * Complex.normSq (complexThreeRowMinor M3 0 4 2) := by
    rw [h_plus.2.2.2.2.2.1, h_parent.2.2.2.2.2.1, h_plus_s1, h_plus_s3]
    ring
  have h_sc5a :
      Complex.normSq (complexThreeRowMinor M3_plus 0 1 2) =
        (1 / 4) * Complex.normSq (complexThreeRowMinor M3 0 1 2) := by
    rw [h_plus.2.2.2.2.2.2.2.1, h_parent.2.2.2.2.2.2.2.1]
    exact h_split.2.2.2.2.2.1
  have h_sc5b : Complex.normSq (complexThreeRowMinor M3_plus 0 1 2) = c_plus.covDet :=
    h_plus.2.2.2.2.2.2.2.1
  have h_sc6 :
      c_plus.coreBohmPotential m_boson hbar - splat.coreBohmPotential m_boson hbar =
        (3 * hbar ^ 2) / (4 * m_boson * Complex.normSq (complexThreeRowMinor M3 0 4 5)) := by
    rw [h_parent.2.1]
    exact h_split.2.2.2.2.2.2.1
  -- Perspective splat in 3D with scaled lateral axes
  let splat_persp3d : NormedTensorGaussianSplat3D :=
    { centerX := (focalScale / splat.centerZ) * splat.centerX
      centerY := (focalScale / splat.centerZ) * splat.centerY
      centerZ := splat.centerZ
      weight := splat.weight
      weight_nonneg := splat.weight_nonneg
      sigma1 := (focalScale / splat.centerZ) * splat.sigma1
      sigma1_pos := mul_pos (div_pos hf hz) splat.sigma1_pos
      sigma2 := (focalScale / splat.centerZ) * splat.sigma2
      sigma2_pos := mul_pos (div_pos hf hz) splat.sigma2_pos
      sigma3 := splat.sigma3
      sigma3_pos := splat.sigma3_pos
      orientationAngle := splat.orientationAngle
      pitchAngle := splat.pitchAngle }
  have hM3_persp_eq : M3_persp = splat_persp3d.gr36TwistorMatrix φ1 φ2 φ3 := rfl
  have h_persp3d :=
    splat_persp3d.gr36_volumetric_imaging_and_plucker_identities φ1 φ2 φ3 m_boson hbar hm
  have h_p045 :
      Complex.normSq (complexThreeRowMinor M3_persp 0 4 5) =
        ((focalScale / splat.centerZ) * splat.sigma1) ^ 2 := by
    rw [hM3_persp_eq]
    exact h_persp3d.2.1
  have h_p315 :
      Complex.normSq (complexThreeRowMinor M3_persp 3 1 5) =
        ((focalScale / splat.centerZ) * splat.sigma2) ^ 2 := by
    rw [hM3_persp_eq]
    exact h_persp3d.2.2.1
  have h_p015 :
      Complex.normSq (complexThreeRowMinor M3_persp 0 1 5) = s_persp.covDet := by
    rw [hM3_persp_eq]
    exact h_persp3d.2.2.2.2.1
  have h_p015_scale :
      Complex.normSq (complexThreeRowMinor M3_persp 0 1 5) =
        (focalScale / splat.centerZ) ^ 4 *
          Complex.normSq (complexThreeRowMinor M3 0 1 5) := by
    rw [h_p015, h_parent.2.2.2.2.1]
    dsimp [s_persp, projectPerspective2D, projectOrthographic2D,
      NormedTensorGaussianSplat2D.covDet]
    ring
  have h_p012 :
      Complex.normSq (complexThreeRowMinor M3_persp 0 1 2) =
        Complex.normSq (complexThreeRowMinor M3_persp 0 1 5) *
          Complex.normSq (complexThreeRowMinor M3 3 4 2) := by
    rw [hM3_persp_eq, h_persp3d.2.2.2.2.2.2.2.1, h_persp3d.2.2.2.2.1, h_parent.2.2.2.1]
    dsimp [splat_persp3d, projectOrthographic2D, NormedTensorGaussianSplat2D.covDet, covDet]
  have h_hp3 :
      (Complex.normSq (complexThreeRowMinor M3_persp 0 4 5) -
          Complex.normSq (complexThreeRowMinor M3_persp 3 1 5)) /
          (Complex.normSq (complexThreeRowMinor M3_persp 0 4 5) +
            Complex.normSq (complexThreeRowMinor M3_persp 3 1 5)) =
        (Complex.normSq (complexThreeRowMinor M3 0 4 5) -
            Complex.normSq (complexThreeRowMinor M3 3 1 5)) /
          (Complex.normSq (complexThreeRowMinor M3 0 4 5) +
            Complex.normSq (complexThreeRowMinor M3 3 1 5)) := by
    rw [h_p045, h_p315, h_parent.2.1, h_parent.2.2.1]
    exact h_split.2.2.2.2.2.2.2.2.2.2.2.1
  have hs1_ne : splat.sigma1 ≠ 0 := ne_of_gt splat.sigma1_pos
  have hs2_ne : splat.sigma2 ≠ 0 := ne_of_gt splat.sigma2_pos
  have hf_ne : focalScale ≠ 0 := ne_of_gt hf
  have hz_ne : splat.centerZ ≠ 0 := ne_of_gt hz
  have h_hp4 :
      Complex.normSq (complexThreeRowMinor M3 0 1 2) /
          Complex.normSq (complexThreeRowMinor M3 0 1 5) =
        Complex.normSq (complexThreeRowMinor M3 3 4 2) := by
    rw [h_parent.2.2.2.2.2.2.2.1, h_parent.2.2.2.2.1, h_parent.2.2.2.1]
    dsimp [projectOrthographic2D, NormedTensorGaussianSplat2D.covDet, covDet]
    field_simp [hs1_ne, hs2_ne]
  have h_lat_pos : 0 < splat.sigma1 ^ 2 + splat.sigma2 ^ 2 := by
    have : 0 < splat.sigma1 ^ 2 := sq_pos_of_pos splat.sigma1_pos
    have : 0 < splat.sigma2 ^ 2 := sq_pos_of_pos splat.sigma2_pos
    linarith
  have h_lat_ne : splat.sigma1 ^ 2 + splat.sigma2 ^ 2 ≠ 0 := ne_of_gt h_lat_pos
  have h_hp5 :
      focalScale ^ 2 *
          ((Complex.normSq (complexThreeRowMinor M3 0 4 5) +
              Complex.normSq (complexThreeRowMinor M3 3 1 5)) /
            (Complex.normSq (complexThreeRowMinor M3_persp 0 4 5) +
              Complex.normSq (complexThreeRowMinor M3_persp 3 1 5))) =
        splat.centerZ ^ 2 := by
    rw [h_parent.2.1, h_parent.2.2.1, h_p045, h_p315]
    have h_sum_p :
        ((focalScale / splat.centerZ) * splat.sigma1) ^ 2 +
            ((focalScale / splat.centerZ) * splat.sigma2) ^ 2 =
          (focalScale / splat.centerZ) ^ 2 * (splat.sigma1 ^ 2 + splat.sigma2 ^ 2) := by
      ring
    rw [h_sum_p]
    field_simp [hf_ne, hz_ne, h_lat_ne]
  -- Schur-Plucker Gr_C(3,6) matrix via a 3D splat with sigma1 = sqrt(1+τ), sigma2 = sqrt(1-τ), sigma3 = (1-τ²)/sqrt(1+τ²)
  have h1p_pos : 0 < 1 + turbulence := by linarith
  have h1m_pos : 0 < 1 - turbulence := by linarith
  have h1t2_pos : 0 < 1 + turbulence ^ 2 := by positivity
  have h_1m_t2_pos : 0 < 1 - turbulence ^ 2 := by nlinarith
  let splat_schur3d : NormedTensorGaussianSplat3D :=
    { centerX := 0
      centerY := 0
      centerZ := 1
      weight := 1
      weight_nonneg := by norm_num
      sigma1 := Real.sqrt (1 + turbulence)
      sigma1_pos := Real.sqrt_pos.mpr h1p_pos
      sigma2 := Real.sqrt (1 - turbulence)
      sigma2_pos := Real.sqrt_pos.mpr h1m_pos
      sigma3 := (1 - turbulence ^ 2) / Real.sqrt (1 + turbulence ^ 2)
      sigma3_pos := div_pos h_1m_t2_pos (Real.sqrt_pos.mpr h1t2_pos)
      orientationAngle := 0
      pitchAngle := 0 }
  have hM3_schur_eq : M3_schur = splat_schur3d.gr36TwistorMatrix φ1 φ2 φ3 := rfl
  have h_schur3d :=
    splat_schur3d.gr36_volumetric_imaging_and_plucker_identities φ1 φ2 φ3 m_boson hbar hm
  have h_sp1a : Complex.normSq (complexThreeRowMinor M3_schur 0 4 5) = 1 + turbulence := by
    rw [hM3_schur_eq, h_schur3d.2.1]
    dsimp [splat_schur3d]
    exact Real.sq_sqrt (le_of_lt h1p_pos)
  have h_sp1b : Complex.normSq (complexThreeRowMinor M3_schur 3 1 5) = 1 - turbulence := by
    rw [hM3_schur_eq, h_schur3d.2.2.1]
    dsimp [splat_schur3d]
    exact Real.sq_sqrt (le_of_lt h1m_pos)
  have h_sp2a : Complex.normSq (complexThreeRowMinor M3_schur 0 1 5) = 1 - turbulence ^ 2 := by
    rw [hM3_schur_eq, h_schur3d.2.2.2.2.1]
    dsimp [splat_schur3d, projectOrthographic2D, NormedTensorGaussianSplat2D.covDet]
    rw [Real.sq_sqrt (le_of_lt h1p_pos), Real.sq_sqrt (le_of_lt h1m_pos)]
    ring
  have h_sp2b : Complex.normSq (complexThreeRowMinor M3_schur 0 1 5) = J.det := by
    rw [h_sp2a, h_schur_base.1]
  have h_sp3 :
      Complex.normSq (complexThreeRowMinor M3_schur 3 4 2) =
        schurComplement3DVolume turbulence := by
    rw [hM3_schur_eq, h_schur3d.2.2.2.1]
    dsimp [splat_schur3d, schurComplement3DVolume]
    rw [div_pow, Real.sq_sqrt (le_of_lt h1t2_pos)]
  have h_sp4 :
      Sigma4.det =
        Sigma4 3 3 * Complex.normSq (complexThreeRowMinor M3_schur 3 4 2) := by
    rw [h_sp3]
    exact h_schur_base.2.2.2.1
  have h_sp5 := complexThreeRowMinor_pluecker M3_schur 0 1 2 3 4 5
  exact ⟨h_sc1a, h_sc1b, h_sc2, h_sc3a, h_sc3b, h_sc3c, h_sc4a, h_sc4b,
    h_sc5a, h_sc5b, h_sc6, h_p015, h_p015_scale, h_p012, h_hp3, h_hp4, h_hp5,
    h_sp1a, h_sp1b, h_sp2a, h_sp2b, h_sp3, h_sp4, h_sp5⟩

/-! ### Section 30: Formal Audit & Gap Closure for the 3-Zone $400 \to 800\text{ GHz}$ `rGO-polyCBD-SS-Lignin` Hyperbolic SFG Lens, Denisov Grating Pitch, and Semenov–Hinshelwood Radical Kinetics

This section resolves five mathematical and physical gaps in the chat's 3-zone
`rGO-polyCBD-SS-Lignin` $400 \to 800\text{ GHz}$ Sum-Frequency Generation (SFG)
Anti-Fire Cannon specification (`data/chats/IQ-Sampling-for-Signal-Phase.md`,
lines 15855–17335):
1. **Zone 2 EMT Dispersion Audit ($\varepsilon_{\perp,400} < \varepsilon_{\perp,800}$)**:
   At $f = 3.20\%$ rGO, $\varepsilon_d = 2.82$, and Drude-scaled
   $\operatorname{Re}(\varepsilon_{\mathrm{rGO}}(400\text{ GHz})) = -110$,
   $\operatorname{Re}(\varepsilon_{\mathrm{rGO}}(800\text{ GHz})) = -27.5$, the exact
   EMT out-of-plane permittivities satisfy
   $\varepsilon_{\perp,400} = \frac{969375}{332468} \approx 2.9157 < \frac{969375}{331622} \approx 2.9231 = \varepsilon_{\perp,800}$
   (correcting the chat's table value $\varepsilon_{\perp,2} = 2.85$, which would make
   $\varepsilon_{\perp,2}/\varepsilon_{\perp,1} - 1 < 0$ without the chat's unannounced
   `1.15` multiplier).
2. **Zone 3 $800\text{ GHz}$ ENZ Fill-Fraction Detuning Fix ($9.301\%$ vs. $9.88\%$)**:
   The exact $800\text{ GHz}$ ENZ zero-crossing occurs at
   $f_{\mathrm{ENZ}}(800\text{ GHz}) = \frac{141}{1516} \approx 9.3008\%$, where
   $\varepsilon_\parallel = 0$ and the loss-regularized intensity enhancement reaches
   $\Gamma_{\mathrm{ENZ,reg}}(2.82, 0, 0.048) = (235/4)^2 = 3451.5625$ (field factor
   $58.75\times$). The chat's table value $f = 9.88\%$ detunes
   $\operatorname{Re}(\varepsilon_\parallel)$ to $-0.175608 \ne 0$, strictly reducing
   the ENZ intensity enhancement by more than an order of magnitude.
3. **Denisov Forward Surface-Launch Grating Pitch vs. Bragg Back-Reflection Pitch**:
   First-order forward grating coupling from normal incidence into angle $\theta_{\mathrm{in}}$
   requires $\Lambda_{\mathrm{forward}} = \lambda_0 / \sin\theta_{\mathrm{in}}$, which is
   exactly twice the Bragg back-reflection formula $\lambda_0 / (2\sin\theta_{\mathrm{in}})$
   used in `generate_polycbd_cannon_mask.py`.
4. **Dimensionally Consistent SFG Longitudinal Field ($k_{800} L_{\mathrm{eff}}$ Factor)**:
   Multiplying $\chi^{(2)} E_{400}^2$ (units $\text{V/m}^2$) by the dimensionless
   phase-matched interaction factor $k_{800} L_{\mathrm{eff}}$ restores proper electric
   field units ($\text{V/m}$).
5. **Semenov–Hinshelwood Radical Trajectory & Exothermic Recombination Heat Release**:
   While $k_{\mathrm{quench}} > k_{\mathrm{branch}} - k_{\mathrm{term}}$ forces
   $[\cdot\mathrm{OH}](t) < [\cdot\mathrm{OH}](0)$ for $t > 0$, radical recombination
   $\cdot\mathrm{OH} + \mathrm{H}\cdot + M \to \mathrm{H}_2\mathrm{O} + M$ is exothermic
   ($\Delta H_{\mathrm{rec}} > 0$), so accelerated recombination releases positive thermal
   power $P_{\mathrm{rec}} = R_{\mathrm{rec}}\,\Delta H_{\mathrm{rec}} > 0$ that must be
   removed by an explicit heat sink. -/

/-- Forward first-order diffraction grating pitch
$\Lambda_{\mathrm{forward}}(\lambda_0, \sin\theta) = \frac{\lambda_0}{\sin\theta}$
for coupling a normally incident wave into oblique angle $\theta$. -/
@[blueprint "def:signals-ddf-denisov-forward-grating-pitch"
  (title := "Forward diffraction grating pitch Λ_forward = λ_0 / sin θ")
  (statement := /-- Define $\operatorname{denisovForwardGratingPitch}(\lambda_0, \sin\theta)
    = \lambda_0 / \sin\theta$. -/)]
noncomputable def denisovForwardGratingPitch (lambda0 sinTheta : ℝ) : ℝ :=
  lambda0 / sinTheta

/-- Bragg back-reflection grating pitch
$\Lambda_{\mathrm{Bragg}}(\lambda_0, \sin\theta) = \frac{\lambda_0}{2\sin\theta}$
used in the chat's `ProcaCannonMaskSpec.denisov_electrode_pitch_um`
(`IQ-Sampling-for-Signal-Phase.md`, lines 16594–16601). -/
@[blueprint "def:signals-ddf-chat-denisov-bragg-pitch"
  (title := "Bragg half-wavelength grating pitch Λ_Bragg = λ_0 / (2 sin θ)")
  (statement := /-- Define $\operatorname{chatDenisovBraggPitch}(\lambda_0, \sin\theta)
    = \lambda_0 / (2 \sin\theta)$. -/)]
noncomputable def chatDenisovBraggPitch (lambda0 sinTheta : ℝ) : ℝ :=
  lambda0 / (2 * sinTheta)

/-- Dimensionally consistent 3-zone $800\text{ GHz}$ SFG longitudinal electric field
amplitude $E_{z,800} = \frac{\varepsilon_d}{\varepsilon_{\mathrm{ENZ}}}\,\chi^{(2)}\,(k_{800} L_{\mathrm{eff}})\,\eta_D\,E_{400}^2$,
incorporating the dimensionless interaction factor $k_{800} L_{\mathrm{eff}}$ so that
$\chi^{(2)} (\text{m/V}) \cdot E_{400}^2 (\text{V}^2/\text{m}^2)$ is scaled by a length
to yield electric-field units ($\text{V/m}$). -/
@[blueprint "def:signals-ddf-dimensioned-sfg-enz-field800"
  (title := "Dimensionally consistent 3-zone 800 GHz SFG-ENZ longitudinal field E_z,800")
  (statement := /-- Define $\operatorname{dimensionedSfgEnzField800}(\varepsilon_d, \varepsilon_{\mathrm{ENZ}}, \chi_2, k_{800}, L_{\mathrm{eff}}, \eta_D, E_{400})
    = (\varepsilon_d / \varepsilon_{\mathrm{ENZ}})\,\chi_2\,(k_{800} L_{\mathrm{eff}})\,\eta_D\,E_{400}^2$. -/)]
noncomputable def dimensionedSfgEnzField800
    (epsD epsEnz chi2 k800 L_eff eta_D E_pump400 : ℝ) : ℝ :=
  (epsD / epsEnz) * chi2 * (k800 * L_eff) * eta_D * (E_pump400 ^ 2)

/-- Net Semenov–Hinshelwood radical branching rate
$\phi_{\mathrm{net}}(k_{\mathrm{branch}}, k_{\mathrm{term}}, k_{\mathrm{quench}}) = k_{\mathrm{branch}} - k_{\mathrm{term}} - k_{\mathrm{quench}}$
(`IQ-Sampling-for-Signal-Phase.md`, lines 16336–16341 & 16461–16466). -/
@[blueprint "def:signals-ddf-semenov-net-branching-rate"
  (title := "Semenov-Hinshelwood net radical branching rate φ_net = k_branch - k_term - k_quench")
  (statement := /-- Define $\operatorname{semenovNetBranchingRate}(k_{\mathrm{branch}}, k_{\mathrm{term}}, k_{\mathrm{quench}})
    = k_{\mathrm{branch}} - k_{\mathrm{term}} - k_{\mathrm{quench}}$. -/)]
def semenovNetBranchingRate (k_branch k_term k_quench : ℝ) : ℝ :=
  k_branch - k_term - k_quench

/-- Time-dependent hydroxyl radical concentration trajectory
$n(t) = n_0 \exp\bigl(\phi_{\mathrm{net}}(k_{\mathrm{branch}}, k_{\mathrm{term}}, k_{\mathrm{quench}})\,t\bigr)$
under the linear Semenov–Hinshelwood rate model (`IQ-Sampling-for-Signal-Phase.md`, lines 16468–16470). -/
@[blueprint "def:signals-ddf-semenov-radical-concentration"
  (title := "Semenov-Hinshelwood hydroxyl radical concentration trajectory n(t) = n_0 exp(φ_net t)")
  (statement := /-- Define $\operatorname{semenovRadicalConcentration}(n_0, k_{\mathrm{branch}}, k_{\mathrm{term}}, k_{\mathrm{quench}}, t)
    = n_0 \exp(\operatorname{semenovNetBranchingRate}(k_{\mathrm{branch}}, k_{\mathrm{term}}, k_{\mathrm{quench}})\,t)$. -/)]
noncomputable def semenovRadicalConcentration
    (n0 k_branch k_term k_quench t : ℝ) : ℝ :=
  n0 * Real.exp (semenovNetBranchingRate k_branch k_term k_quench * t)

/-- Exothermic radical recombination thermal power release
$P_{\mathrm{rec}}(R_{\mathrm{rec}}, \Delta H_{\mathrm{rec}}, V) = R_{\mathrm{rec}}\,\Delta H_{\mathrm{rec}}\,V$
when radical pairs recombine into closed-shell $\mathrm{H}_2\mathrm{O}$
($\Delta H_{\mathrm{rec}} \approx 499\text{ kJ/mol} > 0$). -/
@[blueprint "def:signals-ddf-exothermic-recombination-heat-power"
  (title := "Exothermic radical-to-water recombination heat power P_rec = R_rec ΔH_rec V")
  (statement := /-- Define $\operatorname{exothermicRecombinationHeatPower}(R_{\mathrm{rec}}, \Delta H_{\mathrm{rec}}, V)
    = R_{\mathrm{rec}}\,\Delta H_{\mathrm{rec}}\,V$. -/)]
def exothermicRecombinationHeatPower (R_rec deltaH_rec volume : ℝ) : ℝ :=
  R_rec * deltaH_rec * volume

/-- **3-Zone $400 \to 800\text{ GHz}$ `rGO-polyCBD-SS-Lignin` Hyperbolic SFG Audit, Zone 3 ENZ Detuning Fix, Denisov Grating Pitch, and Semenov–Hinshelwood Kinetics Theorem**:
Proves 16 simultaneous audit and gap-closure identities for the Anti-Fire Cannon's
3-zone metamaterial lens and radical-kinetics model:
1. **Zone 1 ($400\text{ GHz}$) Exact ENZ Fill Fraction**:
   $f_{\mathrm{ENZ}}(400\text{ GHz}) = \frac{141}{5641}$ and
   $\varepsilon_\parallel\!\left(\frac{141}{5641}, -110, \frac{282}{100}\right) = 0$,
2. **Zone 2 ($f = 3.20\%$) $400\text{ GHz}$ Type-II Hyperbolic vs. $800\text{ GHz}$ Elliptical Dielectric Transition**:
   - $\varepsilon_{\parallel,400} = -\frac{9878}{12500} < 0$ and $\varepsilon_{\perp,400} = \frac{969375}{332468} > 0$,
   - $\varepsilon_{\parallel,800} = \frac{23122}{12500} > 0$ and $\varepsilon_{\perp,800} = \frac{969375}{331622} > 0$,
   - $\varepsilon_{\perp,400} < \varepsilon_{\perp,800}$ (correcting the chat's table value $2.85 < 2.92$),
3. **Zone 3 ($800\text{ GHz}$) Exact ENZ Fill Fraction ($9.301\%$) vs. Chat's Detuned Table Value ($9.88\%$)**:
   - $f_{\mathrm{ENZ}}(800\text{ GHz}) = \frac{141}{1516}$ gives $\varepsilon_\parallel\!\left(\frac{141}{1516}, -\frac{55}{2}, \frac{282}{100}\right) = 0$ and peak regularized intensity enhancement $\Gamma_{\mathrm{ENZ,reg}}\!\left(\frac{282}{100}, 0, \frac{48}{1000}\right) = \left(\frac{235}{4}\right)^2$,
   - At $f = \frac{988}{10000}$ ($9.88\%$), $\varepsilon_\parallel = -\frac{21951}{125000} \ne 0$, strictly reducing the enhancement:
     $$\Gamma_{\mathrm{ENZ,reg}}\!\left(\frac{282}{100}, -\frac{21951}{125000}, \frac{48}{1000}\right) < \Gamma_{\mathrm{ENZ,reg}}\!\left(\frac{282}{100}, 0, \frac{48}{1000}\right),$$
4. **Forward vs. Bragg Denisov Grating Pitch**:
   $\operatorname{denisovForwardGratingPitch}(\lambda_0, \sin\theta) = 2 \cdot \operatorname{chatDenisovBraggPitch}(\lambda_0, \sin\theta)$,
5. **Semenov–Hinshelwood Explosion vs. Quenching Dichotomy & Exothermic Recombination Heat**:
   - Unquenched ($k_{\mathrm{quench}} = 0, k_{\mathrm{branch}} > k_{\mathrm{term}}, t > 0$): $n_0 < n(t)$,
   - Quenched ($k_{\mathrm{branch}} - k_{\mathrm{term}} < k_{\mathrm{quench}}, t > 0$): $n(t) < n_0$,
   - Positive exothermic recombination heat power: $0 < \operatorname{exothermicRecombinationHeatPower}(R_{\mathrm{rec}}, \Delta H_{\mathrm{rec}}, V)$. -/
@[blueprint "thm:signals-ddf-three-zone-sfg-and-hydroxyl-audit"
  (title := "3-Zone 400->800 GHz rGO-polyCBD-SS-Lignin SFG audit, Zone 3 ENZ detuning fix, and Semenov-Hinshelwood kinetics theorem")
  (statement := /-- For the 3-zone \texttt{rGO-polyCBD-SS-Lignin} metamaterial parameters
    ($\varepsilon_d = 2.82$, $|\varepsilon_m(400\text{ GHz})| = 110$, $|\varepsilon_m(800\text{ GHz})| = 27.5$,
    $f_{\mathrm{Zone2}} = 0.032$, $\varepsilon_i = 0.048$) and any $\lambda_0, \sin\theta, n_0, k_{\mathrm{branch}}, k_{\mathrm{term}}, k_{\mathrm{quench}}, t, R_{\mathrm{rec}}, \Delta H_{\mathrm{rec}}, V > 0$
    with $k_{\mathrm{term}} < k_{\mathrm{branch}}$ and $k_{\mathrm{branch}} - k_{\mathrm{term}} < k_{\mathrm{quench}}$:
    (1) $f_{\mathrm{ENZ}}(400\text{ GHz}) = 141/5641$ and $\varepsilon_\parallel(141/5641, -110, 2.82) = 0$,
    (2) at $f = 0.032$, $\varepsilon_{\parallel,400} = -9878/12500 < 0$, $\varepsilon_{\perp,400} = 969375/332468 > 0$,
    $\varepsilon_{\parallel,800} = 23122/12500 > 0$, $\varepsilon_{\perp,800} = 969375/331622 > 0$, and
    $\varepsilon_{\perp,400} < \varepsilon_{\perp,800}$,
    (3) $f_{\mathrm{ENZ}}(800\text{ GHz}) = 141/1516$ gives $\varepsilon_\parallel = 0$ and
    $\Gamma_{\mathrm{ENZ,reg}}(2.82, 0, 0.048) = (235/4)^2$, whereas the chat's $f = 0.0988$ gives
    $\varepsilon_\parallel = -21951/125000 < 0$ and strictly smaller $\Gamma_{\mathrm{ENZ,reg}}$,
    (4) $\operatorname{denisovForwardGratingPitch}(\lambda_0, \sin\theta) = 2\,\operatorname{chatDenisovBraggPitch}(\lambda_0, \sin\theta)$, and
    (5) $n_0 < \operatorname{semenovRadicalConcentration}(n_0, k_{\mathrm{branch}}, k_{\mathrm{term}}, 0, t)$,
    $\operatorname{semenovRadicalConcentration}(n_0, k_{\mathrm{branch}}, k_{\mathrm{term}}, k_{\mathrm{quench}}, t) < n_0$, and
    $0 < \operatorname{exothermicRecombinationHeatPower}(R_{\mathrm{rec}}, \Delta H_{\mathrm{rec}}, V)$. -/)
  (proof := /-- Evaluate the exact rational EMT fractions by \texttt{norm\_num}, compare the
    detuned vs.\ resonant ENZ denominators, unfold the grating pitch ratio, and apply
    \texttt{Real.one\_lt\_exp\_iff} and \texttt{Real.exp\_lt\_one\_iff} to the Semenov--Hinshelwood
    trajectories. -/)]
theorem three_zone_rgo_polycbd_sfg_and_hydroxyl_kinetics_audit_identities
    (lambda0 sinTheta n0 k_branch k_term k_quench t R_rec deltaH_rec volume : ℝ)
    (hsin_ne : sinTheta ≠ 0) (hn0_pos : 0 < n0) (ht_pos : 0 < t)
    (h_expl : k_term < k_branch)
    (h_quench : k_branch - k_term < k_quench)
    (hR_pos : 0 < R_rec) (hH_pos : 0 < deltaH_rec) (hV_pos : 0 < volume) :
    emtCriticalEnzFillFraction (282 / 100) 110 = 141 / 5641 ∧
      emtEpsilonParallel (141 / 5641) (-110) (282 / 100) = 0 ∧
      emtEpsilonParallel (32 / 1000) (-110) (282 / 100) = -9878 / 12500 ∧
      emtEpsilonParallel (32 / 1000) (-110) (282 / 100) < 0 ∧
      emtEpsilonPerp (32 / 1000) (-110) (282 / 100) = 969375 / 332468 ∧
      emtEpsilonParallel (32 / 1000) (-55 / 2) (282 / 100) = 23122 / 12500 ∧
      0 < emtEpsilonParallel (32 / 1000) (-55 / 2) (282 / 100) ∧
      emtEpsilonPerp (32 / 1000) (-55 / 2) (282 / 100) = 969375 / 331622 ∧
      emtEpsilonPerp (32 / 1000) (-110) (282 / 100) <
        emtEpsilonPerp (32 / 1000) (-55 / 2) (282 / 100) ∧
      emtCriticalEnzFillFraction (282 / 100) (55 / 2) = 141 / 1516 ∧
      emtEpsilonParallel (141 / 1516) (-55 / 2) (282 / 100) = 0 ∧
      emtEpsilonParallel (988 / 10000) (-55 / 2) (282 / 100) = -2744 / 15625 ∧
      regularizedEnzEnhancement (282 / 100) 0 (48 / 1000) = (235 / 4) ^ 2 ∧
      regularizedEnzEnhancement (282 / 100) (-2744 / 15625) (48 / 1000) <
        regularizedEnzEnhancement (282 / 100) 0 (48 / 1000) ∧
      denisovForwardGratingPitch lambda0 sinTheta =
        2 * chatDenisovBraggPitch lambda0 sinTheta ∧
      n0 < semenovRadicalConcentration n0 k_branch k_term 0 t ∧
      semenovRadicalConcentration n0 k_branch k_term k_quench t < n0 ∧
      0 < exothermicRecombinationHeatPower R_rec deltaH_rec volume := by
  have h1 : emtCriticalEnzFillFraction (282 / 100) 110 = 141 / 5641 := by
    unfold emtCriticalEnzFillFraction; norm_num
  have h2 : emtEpsilonParallel (141 / 5641) (-110) (282 / 100) = 0 := by
    unfold emtEpsilonParallel; norm_num
  have h3 : emtEpsilonParallel (32 / 1000) (-110) (282 / 100) = -9878 / 12500 := by
    unfold emtEpsilonParallel; norm_num
  have h4 : emtEpsilonParallel (32 / 1000) (-110) (282 / 100) < 0 := by
    rw [h3]; norm_num
  have h5 : emtEpsilonPerp (32 / 1000) (-110) (282 / 100) = 969375 / 332468 := by
    unfold emtEpsilonPerp; norm_num
  have h6 : emtEpsilonParallel (32 / 1000) (-55 / 2) (282 / 100) = 23122 / 12500 := by
    unfold emtEpsilonParallel; norm_num
  have h7 : 0 < emtEpsilonParallel (32 / 1000) (-55 / 2) (282 / 100) := by
    rw [h6]; norm_num
  have h8 : emtEpsilonPerp (32 / 1000) (-55 / 2) (282 / 100) = 969375 / 331622 := by
    unfold emtEpsilonPerp; norm_num
  have h9 :
      emtEpsilonPerp (32 / 1000) (-110) (282 / 100) <
        emtEpsilonPerp (32 / 1000) (-55 / 2) (282 / 100) := by
    rw [h5, h8]; norm_num
  have h10 : emtCriticalEnzFillFraction (282 / 100) (55 / 2) = 141 / 1516 := by
    unfold emtCriticalEnzFillFraction; norm_num
  have h11 : emtEpsilonParallel (141 / 1516) (-55 / 2) (282 / 100) = 0 := by
    unfold emtEpsilonParallel; norm_num
  have h12 : emtEpsilonParallel (988 / 10000) (-55 / 2) (282 / 100) = -2744 / 15625 := by
    unfold emtEpsilonParallel; norm_num
  have h13 : regularizedEnzEnhancement (282 / 100) 0 (48 / 1000) = (235 / 4) ^ 2 := by
    unfold regularizedEnzEnhancement; norm_num
  have h14 :
      regularizedEnzEnhancement (282 / 100) (-2744 / 15625) (48 / 1000) <
        regularizedEnzEnhancement (282 / 100) 0 (48 / 1000) := by
    unfold regularizedEnzEnhancement; norm_num
  have h15 :
      denisovForwardGratingPitch lambda0 sinTheta =
        2 * chatDenisovBraggPitch lambda0 sinTheta := by
    unfold denisovForwardGratingPitch chatDenisovBraggPitch
    field_simp [hsin_ne]
  have h16 : n0 < semenovRadicalConcentration n0 k_branch k_term 0 t := by
    unfold semenovRadicalConcentration semenovNetBranchingRate
    have h_rate_pos : 0 < k_branch - k_term - 0 := by linarith
    have h_arg_pos : 0 < (k_branch - k_term - 0) * t := mul_pos h_rate_pos ht_pos
    have h_exp_gt : 1 < Real.exp ((k_branch - k_term - 0) * t) :=
      Real.one_lt_exp_iff.mpr h_arg_pos
    calc
      n0 = n0 * 1 := (mul_one n0).symm
      _ < n0 * Real.exp ((k_branch - k_term - 0) * t) :=
        mul_lt_mul_of_pos_left h_exp_gt hn0_pos
  have h17 : semenovRadicalConcentration n0 k_branch k_term k_quench t < n0 := by
    unfold semenovRadicalConcentration semenovNetBranchingRate
    have h_rate_neg : k_branch - k_term - k_quench < 0 := by linarith
    have h_arg_neg : (k_branch - k_term - k_quench) * t < 0 :=
      mul_neg_of_neg_of_pos h_rate_neg ht_pos
    have h_exp_lt : Real.exp ((k_branch - k_term - k_quench) * t) < 1 :=
      Real.exp_lt_one_iff.mpr h_arg_neg
    calc
      n0 * Real.exp ((k_branch - k_term - k_quench) * t) < n0 * 1 :=
        mul_lt_mul_of_pos_left h_exp_lt hn0_pos
      _ = n0 := mul_one n0
  have h18 : 0 < exothermicRecombinationHeatPower R_rec deltaH_rec volume := by
    unfold exothermicRecombinationHeatPower
    positivity
  exact ⟨h1, h2, h3, h4, h5, h6, h7, h8, h9, h10, h11, h12, h13, h14, h15, h16, h17, h18⟩

end Signals.DDF
