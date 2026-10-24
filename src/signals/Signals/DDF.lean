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

namespace Signals.DDF

open MeasureTheory Interval Complex Signals.Geometry Signals.Huygens

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

end Signals.DDF
