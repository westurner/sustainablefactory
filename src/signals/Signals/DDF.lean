import Mathlib.Analysis.SpecialFunctions.Pow.Real
import Mathlib.Analysis.Real.Sqrt
import Mathlib.Data.Real.Basic
import Mathlib.Tactic

namespace Signals.DDF

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

end Signals.DDF
