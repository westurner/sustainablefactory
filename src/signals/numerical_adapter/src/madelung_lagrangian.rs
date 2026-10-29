//! Superfluid Gross–Pitaevskii Action, Madelung Polar Substitution ($\psi = \sqrt{\rho} e^{i S / \hbar}$),
//! Euler–Lagrange Continuity & Quantum Hamilton–Jacobi (QHJ) Equations, and
//! Dilatant-Phase ($\varphi$) Jamming Recovery in Unified $Gr_{\mathbb{C}}(2,4)$ and DDF Mechanics.
//!
//! Matches the machine-checked Lean 4 definitions and theorems in `Signals.DDF` and `Signals.Pending`:
//! - `Signals.DDF.madelungPolarWavefunction`
//! - `Signals.DDF.madelungPolarDerivative`
//! - `Signals.DDF.grossPitaevskiiTemporalSymplecticTerm`
//! - `Signals.DDF.grossPitaevskiiPolarLagrangianDensity`
//! - `Signals.DDF.madelungAmplitudeLagrangianDensity`
//! - `Signals.DDF.madelungHydrodynamicLagrangianDensity`
//! - `Signals.DDF.madelungPhaseEulerLagrangeResidual` & `madelungContinuityResidual`
//! - `Signals.DDF.madelungAmplitudeEulerLagrangeResidual` & `quantumHamiltonJacobiResidual`
//! - `Signals.DDF.MovingSheath.sheathCompressionResidual` & `sheathVariationalExcess`
//! - `Signals.DDF.MovingSheath.dilatantLagrangian`, `dilatantCanonicalMomentum`, `dilatantHamiltonian`, & `actionProperTime`
//! - `Signals.DDF.standardBogoliubovPhaseVelSq` & `dilatantBogoliubovPhaseVelSq`
//! - `Signals.DDF.MovingSheath.madelung_lagrangian_variational_and_dilatant_jamming_identities`
//! - `Signals.Pending.MadelungDilatantVariationalHypothesis`

use crate::double_slit::{complex_gr24_channel_matrix, two_row_minor_complex, Complex64};
use crate::orbital_splat::{NormedTensorGaussianSplat2D, SplatRole};
use crate::{require_finite, require_nonnegative, require_positive, ValidationError};

/// Superfluid Gross–Pitaevskii / Madelung variational action model for a bosonic
/// condensate of mass $m_\phi > 0$, reduced Planck constant $\hbar > 0$, and contact
/// self-interaction coupling $g_\phi$.
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct MadelungVariationalActionModel {
    pub m_phi: f64,
    pub hbar: f64,
    pub g_phi: f64,
}

impl MadelungVariationalActionModel {
    pub fn validate(&self) -> Result<(), ValidationError> {
        require_positive("m_phi", self.m_phi)?;
        require_positive("hbar", self.hbar)?;
        require_finite("g_phi", self.g_phi)?;
        Ok(())
    }

    /// Polar complex order parameter $\psi(A, \theta) = A(\cos\theta + i\sin\theta) = A e^{i\theta}$,
    /// matching `Signals.DDF.madelungPolarWavefunction`.
    #[inline]
    pub fn polar_wavefunction(amplitude: f64, theta: f64) -> Complex64 {
        Complex64::new(amplitude * theta.cos(), amplitude * theta.sin())
    }

    /// Chain-rule derivative $\partial_\mu\psi = (\partial_\mu A + i A\,\partial_\mu\theta)e^{i\theta}$,
    /// matching `Signals.DDF.madelungPolarDerivative`.
    #[inline]
    pub fn polar_derivative(amplitude: f64, d_amplitude: f64, theta: f64, d_theta: f64) -> Complex64 {
        let (c, s) = (theta.cos(), theta.sin());
        Complex64::new(
            d_amplitude * c - amplitude * d_theta * s,
            d_amplitude * s + amplitude * d_theta * c,
        )
    }

    /// Real temporal symplectic term $\frac{i\hbar}{2}(\psi^*\dot{\psi} - \psi\dot{\psi}^*) = -\hbar\,\operatorname{Im}(\psi^*\dot{\psi})$,
    /// matching `Signals.DDF.grossPitaevskiiTemporalSymplecticTerm`.
    #[inline]
    pub fn gp_temporal_symplectic_term(&self, psi: Complex64, psi_dot: Complex64) -> f64 {
        let prod = psi.conj().mul(psi_dot);
        -self.hbar * prod.im
    }

    /// Full Gross–Pitaevskii / NLS Lagrangian density evaluated on complex polar field values
    /// $(\psi, \partial_t\psi, \nabla\psi)$, matching `Signals.DDF.grossPitaevskiiPolarLagrangianDensity`.
    #[inline]
    pub fn gp_polar_lagrangian_density(
        &self,
        v_ext: f64,
        psi: Complex64,
        psi_t: Complex64,
        psi_x: Complex64,
    ) -> f64 {
        let rho = psi.norm_sq();
        self.gp_temporal_symplectic_term(psi, psi_t)
            - (self.hbar * self.hbar / (2.0 * self.m_phi)) * psi_x.norm_sq()
            - v_ext * rho
            - 0.5 * self.g_phi * rho * rho
    }

    /// Madelung amplitude-phase Lagrangian density $\mathcal{L}_{\mathrm{Mad}}(A, \nabla A, \partial_t S, \nabla S)$,
    /// matching `Signals.DDF.madelungAmplitudeLagrangianDensity`.
    #[inline]
    pub fn madelung_amplitude_lagrangian_density(
        &self,
        v_ext: f64,
        amplitude: f64,
        grad_a: f64,
        s_t: f64,
        grad_s: f64,
    ) -> f64 {
        let a2 = amplitude * amplitude;
        -a2 * (s_t + (grad_s * grad_s) / (2.0 * self.m_phi) + v_ext)
            - 0.5 * self.g_phi * a2 * a2
            - (self.hbar * self.hbar / (2.0 * self.m_phi)) * grad_a * grad_a
    }

    /// Madelung hydrodynamic density-phase Lagrangian density $\mathcal{L}_{\mathrm{Mad}}^\rho(\rho, \nabla\rho, \partial_t S, \nabla S)$,
    /// matching `Signals.DDF.madelungHydrodynamicLagrangianDensity`.
    #[inline]
    pub fn madelung_hydrodynamic_lagrangian_density(
        &self,
        v_ext: f64,
        rho: f64,
        grad_rho: f64,
        s_t: f64,
        grad_s: f64,
    ) -> f64 {
        -rho * (s_t + (grad_s * grad_s) / (2.0 * self.m_phi) + v_ext + 0.5 * self.g_phi * rho)
            - (self.hbar * self.hbar / (8.0 * self.m_phi)) * (grad_rho * grad_rho / rho)
    }

    /// Canonical momentum $\pi_S = \frac{\partial\mathcal{L}_{\mathrm{Mad}}}{\partial(\partial_t S)} = -\rho$,
    /// matching `Signals.DDF.madelungPhaseCanonicalMomentum`.
    #[inline]
    pub fn phase_canonical_momentum(rho: f64) -> f64 {
        -rho
    }

    /// Spatial canonical flux $J_S = \frac{\partial\mathcal{L}_{\mathrm{Mad}}}{\partial(\nabla S)} = -\rho\frac{\nabla S}{m_\phi} = -\rho v_\phi$,
    /// matching `Signals.DDF.madelungPhaseSpatialFlux`.
    #[inline]
    pub fn phase_spatial_flux(&self, rho: f64, grad_s: f64) -> f64 {
        -rho * (grad_s / self.m_phi)
    }

    /// Euler–Lagrange residual $\mathcal{E}_S = -\partial_t\pi_S - \nabla\cdot J_S$ for variation with respect to $S$,
    /// matching `Signals.DDF.madelungPhaseEulerLagrangeResidual`.
    #[inline]
    pub fn phase_euler_lagrange_residual(dt_pi_s: f64, div_j_s: f64) -> f64 {
        -dt_pi_s - div_j_s
    }

    /// Compressible continuity equation residual $\partial_t\rho + \nabla\cdot(\rho v_\phi)$,
    /// matching `Signals.DDF.madelungContinuityResidual`.
    #[inline]
    pub fn continuity_residual(dt_rho: f64, div_rho_v: f64) -> f64 {
        dt_rho + div_rho_v
    }

    /// Euler–Lagrange residual $\mathcal{E}_A = \frac{\partial\mathcal{L}_{\mathrm{Mad}}}{\partial A} - \nabla\cdot\frac{\partial\mathcal{L}_{\mathrm{Mad}}}{\partial(\nabla A)}$
    /// for variation with respect to $A = \sqrt{\rho}$, matching `Signals.DDF.madelungAmplitudeEulerLagrangeResidual`.
    #[inline]
    pub fn amplitude_euler_lagrange_residual(
        &self,
        v_ext: f64,
        amplitude: f64,
        laplacian_a: f64,
        s_t: f64,
        grad_s: f64,
    ) -> f64 {
        let partial_l = -2.0
            * amplitude
            * (s_t
                + (grad_s * grad_s) / (2.0 * self.m_phi)
                + v_ext
                + self.g_phi * amplitude * amplitude);
        let div_flux = -(self.hbar * self.hbar / self.m_phi) * laplacian_a;
        partial_l - div_flux
    }

    /// Regularized Bohm quantum potential $Q(\rho) = -\frac{\hbar^2}{2 m_\phi}\frac{\Delta A}{A}$ ($A = \sqrt{\rho}$).
    #[inline]
    pub fn bohm_quantum_potential(&self, amplitude: f64, laplacian_a: f64) -> f64 {
        -(self.hbar * self.hbar / (2.0 * self.m_phi)) * (laplacian_a / amplitude)
    }

    /// Quantum Hamilton–Jacobi (QHJ) residual
    /// $\mathcal{R}_{\mathrm{QHJ}} = \partial_t S + \frac{1}{2}m_\phi v_\phi^2 + V_{\mathrm{ext}} + g_\phi A^2 + Q(\rho)$,
    /// matching `Signals.DDF.quantumHamiltonJacobiResidual`.
    #[inline]
    pub fn quantum_hamilton_jacobi_residual(
        &self,
        v_ext: f64,
        amplitude: f64,
        laplacian_a: f64,
        s_t: f64,
        v_phi: f64,
    ) -> f64 {
        s_t + 0.5 * self.m_phi * v_phi * v_phi
            + v_ext
            + self.g_phi * amplitude * amplitude
            + self.bohm_quantum_potential(amplitude, laplacian_a)
    }

    /// Positive-definite Madelung amplitude-phase Hamiltonian density
    /// $\mathcal{H}_{\mathrm{Mad}} = \pi_S\partial_t S - \mathcal{L}_{\mathrm{Mad}} = A^2\bigl((\nabla S)^2/(2m_\phi) + V_{\mathrm{ext}}\bigr) + \frac{g_\phi}{2}A^4 + \frac{\hbar^2}{2m_\phi}(\nabla A)^2$,
    /// matching `Signals.DDF.madelungAmplitudeHamiltonianDensity`.
    #[inline]
    pub fn madelung_amplitude_hamiltonian_density(
        &self,
        v_ext: f64,
        amplitude: f64,
        grad_a: f64,
        grad_s: f64,
    ) -> f64 {
        let a2 = amplitude * amplitude;
        a2 * ((grad_s * grad_s) / (2.0 * self.m_phi) + v_ext)
            + 0.5 * self.g_phi * a2 * a2
            + (self.hbar * self.hbar / (2.0 * self.m_phi)) * grad_a * grad_a
    }

    /// Hydrodynamic density-velocity Madelung Hamiltonian density
    /// $\mathcal{H}_{\mathrm{Mad}}^\rho = \frac{1}{2}m_\phi\rho v_\phi^2 + V_{\mathrm{ext}}\rho + \frac{g_\phi}{2}\rho^2 + \frac{\hbar^2}{8m_\phi}\frac{(\nabla\rho)^2}{\rho}$,
    /// matching `Signals.DDF.madelungHydrodynamicHamiltonianDensity`.
    #[inline]
    pub fn madelung_hydrodynamic_hamiltonian_density(
        &self,
        v_ext: f64,
        rho: f64,
        grad_rho: f64,
        v_phi: f64,
    ) -> f64 {
        0.5 * self.m_phi * rho * v_phi * v_phi
            + v_ext * rho
            + 0.5 * self.g_phi * rho * rho
            + (self.hbar * self.hbar / (8.0 * self.m_phi)) * (grad_rho * grad_rho / rho)
    }

    /// Compressible Madelung–Euler momentum residual
    /// $\mathcal{R}_{\mathrm{Euler}} = \partial_t v_\phi + v_\phi\nabla v_\phi + (\nabla V_{\mathrm{ext}} + g_\phi\nabla\rho + \nabla Q)/m_\phi$,
    /// matching `Signals.DDF.madelungEulerMomentumResidual`.
    #[inline]
    pub fn euler_momentum_residual(
        &self,
        dt_v_phi: f64,
        v_phi: f64,
        grad_v_phi: f64,
        grad_v_ext: f64,
        grad_rho: f64,
        grad_q: f64,
    ) -> f64 {
        dt_v_phi
            + v_phi * grad_v_phi
            + (grad_v_ext + self.g_phi * grad_rho + grad_q) / self.m_phi
    }

    /// Returns `(in_phase_density, quadrature_density)` for two superposed polar wavefunctions
    /// $\psi_1 = A_1 e^{i\theta}$ and $\psi_2 = A_2 e^{i(\theta + \Delta\theta)}$ ($\Delta\theta = 0$ vs. $\pi/2$),
    /// matching the nanolithography bridge in `Signals.DDF.madelung_hamiltonian_euler_ads_and_nanolithography_bridge_identities`.
    #[inline]
    pub fn two_spline_polar_superposition_densities(a1: f64, a2: f64, theta: f64) -> (f64, f64) {
        let psi1 = Self::polar_wavefunction(a1, theta);
        let psi2_in = Self::polar_wavefunction(a2, theta);
        let psi2_quad = Self::polar_wavefunction(a2, theta + std::f64::consts::FRAC_PI_2);
        let in_phase = Complex64::new(psi1.re + psi2_in.re, psi1.im + psi2_in.im).norm_sq();
        let quad = Complex64::new(psi1.re + psi2_quad.re, psi1.im + psi2_quad.im).norm_sq();
        (in_phase, quad)
    }

    /// Core Bohm quantum-confinement potential $Q_{\mathrm{STED}} = \frac{\hbar^2}{2 m_\phi w_{\mathrm{STED}}^2}$
    /// of a $532\text{ nm}$ STED-depleted nanolithography spot, matching `Signals.DDF.stedCoreBohmPotential`.
    #[inline]
    pub fn sted_core_bohm_potential(
        &self,
        lambda_write: f64,
        na: f64,
        sat_ratio: f64,
    ) -> f64 {
        let w0 = lambda_write / (2.0 * na);
        let w_sted_sq = (w0 * w0) / (1.0 + sat_ratio);
        (self.hbar * self.hbar) / (2.0 * self.m_phi * w_sted_sq)
    }

    /// 1D periodic Euler–Lagrange time-step evolving $(\rho_i, S_i)$ by the coupled
    /// Madelung continuity and Quantum Hamilton–Jacobi equations while conserving
    /// discrete total mass $\sum_i \rho_i$ by conservative flux differencing.
    pub fn step_1d_madelung_qhj_periodic(
        &self,
        rho: &[f64],
        s_phase: &[f64],
        v_ext: &[f64],
        dx: f64,
        dt: f64,
    ) -> (Vec<f64>, Vec<f64>) {
        let n = rho.len();
        if n == 0 || s_phase.len() != n || v_ext.len() != n || dx <= 0.0 {
            return (Vec::new(), Vec::new());
        }
        let amps: Vec<f64> = rho.iter().map(|r| r.max(1e-12).sqrt()).collect();
        let mut fluxes = vec![0.0; n];
        for i in 0..n {
            let ip1 = (i + 1) % n;
            let grad_s_edge = (s_phase[ip1] - s_phase[i]) / dx;
            let v_edge = grad_s_edge / self.m_phi;
            let rho_edge = 0.5 * (rho[i] + rho[ip1]);
            fluxes[i] = rho_edge * v_edge;
        }
        let mut next_rho = vec![0.0; n];
        let mut next_s = vec![0.0; n];
        for i in 0..n {
            let im1 = (i + n - 1) % n;
            let ip1 = (i + 1) % n;
            let div_rho_v = (fluxes[i] - fluxes[im1]) / dx;
            next_rho[i] = rho[i] - dt * div_rho_v;

            let grad_s = (s_phase[ip1] - s_phase[im1]) / (2.0 * dx);
            let v_phi = grad_s / self.m_phi;
            let lap_a = (amps[ip1] - 2.0 * amps[i] + amps[im1]) / (dx * dx);
            let q_bohm = self.bohm_quantum_potential(amps[i], lap_a);
            let ds_dt = -(0.5 * self.m_phi * v_phi * v_phi
                + v_ext[i]
                + self.g_phi * rho[i]
                + q_bohm);
            next_s[i] = s_phase[i] + dt * ds_dt;
        }
        (next_rho, next_s)
    }
}

/// Coupled two-phase ($\phi + \varphi$) Dilatant Dark Fluid (DDF) variational sheath
/// model recovering $\Lambda_\parallel(v) = \gamma_\varphi(v) = (1 - v^2/c^2)^{-1/2}$,
/// $L_{\mathrm{DDF}}(v) = -m c^2 / \gamma_\varphi(v)$, $H_{\mathrm{DDF}}(v) = \gamma_\varphi(v) m c^2$,
/// and action-derived proper time $d\tau_D = dt / \gamma_\varphi(v)$.
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct DdfDilatantVariationalSheath {
    pub rest_mass: f64,
    pub speed_of_light: f64,
    pub velocity: f64,
}

impl DdfDilatantVariationalSheath {
    pub fn validate(&self) -> Result<(), ValidationError> {
        require_positive("rest_mass", self.rest_mass)?;
        require_positive("speed_of_light", self.speed_of_light)?;
        require_nonnegative("velocity", self.velocity)?;
        if self.velocity >= self.speed_of_light {
            return Err(ValidationError::NonPositive("speed_of_light - velocity"));
        }
        Ok(())
    }

    /// Dimensionless speed ratio $\beta = v / c \in [0, 1)$.
    #[inline]
    pub fn beta(&self) -> f64 {
        self.velocity / self.speed_of_light
    }

    /// Squared speed ratio $\beta^2 = (v / c)^2 \in [0, 1)$.
    #[inline]
    pub fn beta_sq(&self) -> f64 {
        let b = self.beta();
        b * b
    }

    /// Constitutive Lorentz jamming factor $\gamma_\varphi(v) = (1 - v^2/c^2)^{-1/2}$,
    /// matching `Signals.DDF.MovingSheath.jammingFactor`.
    #[inline]
    pub fn jamming_factor(&self) -> f64 {
        1.0 / (1.0 - self.beta_sq()).sqrt()
    }

    /// Sheath-compression Euler–Lagrange stationary residual
    /// $\mathcal{R}_{\mathrm{sheath}}(\Lambda_\parallel) = \Lambda_\parallel(1 - \beta^2) - 1/\Lambda_\parallel$,
    /// matching `Signals.DDF.MovingSheath.sheathCompressionResidual`.
    #[inline]
    pub fn sheath_compression_residual(&self, lambda_parallel: f64) -> f64 {
        lambda_parallel * (1.0 - self.beta_sq()) - 1.0 / lambda_parallel
    }

    /// Convex variational excess energy
    /// $\Delta\mathcal{E}_{\mathrm{sheath}}(\Lambda_\parallel) = \frac{1}{2}m c^2(1 - \beta^2)(\Lambda_\parallel - \gamma_\varphi(v))^2 \ge 0$,
    /// matching `Signals.DDF.MovingSheath.sheathVariationalExcess`.
    #[inline]
    pub fn sheath_variational_excess(&self, lambda_parallel: f64) -> f64 {
        let diff = lambda_parallel - self.jamming_factor();
        0.5 * self.rest_mass
            * self.speed_of_light
            * self.speed_of_light
            * (1.0 - self.beta_sq())
            * diff
            * diff
    }

    /// Worldline dilatant Lagrangian $L_{\mathrm{DDF}}(v) = -m c^2 / \gamma_\varphi(v)$,
    /// matching `Signals.DDF.MovingSheath.dilatantLagrangian`.
    #[inline]
    pub fn dilatant_lagrangian(&self) -> f64 {
        -(self.rest_mass * self.speed_of_light * self.speed_of_light) / self.jamming_factor()
    }

    /// Relativistic canonical momentum $p_{\mathrm{DDF}}(v) = \gamma_\varphi(v) m v$,
    /// matching `Signals.DDF.MovingSheath.dilatantCanonicalMomentum`.
    #[inline]
    pub fn dilatant_canonical_momentum(&self) -> f64 {
        self.jamming_factor() * self.rest_mass * self.velocity
    }

    /// Legendre-transformed dilatant Hamiltonian $H_{\mathrm{DDF}}(v) = v\,p_{\mathrm{DDF}}(v) - L_{\mathrm{DDF}}(v)$,
    /// matching `Signals.DDF.MovingSheath.dilatantHamiltonian`.
    #[inline]
    pub fn dilatant_hamiltonian(&self) -> f64 {
        self.velocity * self.dilatant_canonical_momentum() - self.dilatant_lagrangian()
    }

    /// Reversible dilatant kinetic energy $K_D(v) = m c^2(\gamma_\varphi(v) - 1)$,
    /// matching `Signals.DDF.MovingSheath.kineticEnergy`.
    #[inline]
    pub fn reversible_kinetic_energy(&self) -> f64 {
        self.rest_mass * self.speed_of_light * self.speed_of_light * (self.jamming_factor() - 1.0)
    }

    /// Action-derived clock proper-time increment $d\tau_D = (-L_{\mathrm{DDF}}(v)/(m c^2))dt = dt / \gamma_\varphi(v)$,
    /// matching `Signals.DDF.MovingSheath.actionProperTime`.
    #[inline]
    pub fn action_proper_time(&self, dt: f64) -> f64 {
        let mc2 = self.rest_mass * self.speed_of_light * self.speed_of_light;
        (-self.dilatant_lagrangian() / mc2) * dt
    }

    /// Returns `(c^2 * dtau_D^2, c^2 * dt^2 - (v * dt)^2)` to verify the unconditional
    /// operational Minkowski interval directly from `action_proper_time`.
    #[inline]
    pub fn minkowski_interval_sq(&self, dt: f64) -> (f64, f64) {
        let c2 = self.speed_of_light * self.speed_of_light;
        let dtau = self.action_proper_time(dt);
        let lhs = c2 * dtau * dtau;
        let rhs = c2 * dt * dt - (self.velocity * dt).powi(2);
        (lhs, rhs)
    }

    /// Evaluates the 4-way equivalence between:
    /// 1. Squared normalized dilatant Lagrangian $(L_{\mathrm{DDF}}(v)/(-m c^2))^2$,
    /// 2. Complex $Gr_{\mathbb{C}}(2,4)$ uncrossed Plücker product $|w_A^{\mathbb{C}}|^2 |w_B^{\mathbb{C}}|^2$,
    /// 3. Normalized covariance determinant $\det\Sigma_{\mathrm{DDF}} / \sigma_0^4$ of `NormedTensorGaussianSplat2D`,
    /// 4. Inverse squared jamming factor $\gamma_\varphi(v)^{-2} = 1 - \beta^2$.
    pub fn gr24_plucker_and_splat_invariants(
        &self,
        sigma0: f64,
        theta: f64,
    ) -> (f64, f64, f64, f64) {
        let mc2 = self.rest_mass * self.speed_of_light * self.speed_of_light;
        let lag_sq = (self.dilatant_lagrangian() / (-mc2)).powi(2);

        let beta = self.beta();
        let a = (1.0 + beta).sqrt();
        let b = (1.0 - beta).sqrt();
        let (c, s) = (theta.cos(), theta.sin());
        let z1 = Complex64::new(a * c, a * s);
        let z2 = Complex64::new(b * c, -b * s);
        let m_gr24 = complex_gr24_channel_matrix(z1, z2);
        let w_a_sq = two_row_minor_complex(&m_gr24, 0, 1)
            .mul(two_row_minor_complex(&m_gr24, 2, 3))
            .norm_sq();
        let w_b_sq = two_row_minor_complex(&m_gr24, 0, 3)
            .mul(two_row_minor_complex(&m_gr24, 1, 2))
            .norm_sq();
        let plucker_prod = w_a_sq * w_b_sq;

        let splat = NormedTensorGaussianSplat2D {
            center_x: 0.0,
            center_y: 0.0,
            weight: 1.0,
            sigma1: sigma0 / self.jamming_factor(),
            sigma2: sigma0,
            orientation_angle: theta,
            role: SplatRole::DdfMovingSheathField,
        };
        let splat_det_ratio = splat.cov_det() / sigma0.powi(4);
        let inv_jam_sq = 1.0 - self.beta_sq();
        (lag_sq, plucker_prod, splat_det_ratio, inv_jam_sq)
    }

    /// Standard uncoupled superfluid Bogoliubov squared phase velocity
    /// $v_p^2(k) = \frac{\hbar^2 k^2}{4 m_\phi^2} + \frac{g_0 \rho_0}{m_\phi}$,
    /// matching `Signals.DDF.standardBogoliubovPhaseVelSq`.
    #[inline]
    pub fn standard_bogoliubov_phase_vel_sq(
        m_phi: f64,
        g0: f64,
        rho0: f64,
        hbar: f64,
        k: f64,
    ) -> f64 {
        (hbar * hbar * k * k) / (4.0 * m_phi * m_phi) + (g0 * rho0) / m_phi
    }

    /// Strain-thickened dilatant Bogoliubov squared phase velocity
    /// $v_{p,\mathrm{DDF}}^2(k) = \frac{\hbar^2 k^2}{4 m_\phi^2} + \frac{g_0(1 + \gamma_{\mathrm{dil}} k^2)\rho_0}{m_\phi}$,
    /// matching `Signals.DDF.dilatantBogoliubovPhaseVelSq`.
    #[inline]
    pub fn dilatant_bogoliubov_phase_vel_sq(
        m_phi: f64,
        g0: f64,
        rho0: f64,
        gamma_dil: f64,
        hbar: f64,
        k: f64,
    ) -> f64 {
        (hbar * hbar * k * k) / (4.0 * m_phi * m_phi)
            + (g0 * (1.0 + gamma_dil * k * k) * rho0) / m_phi
    }
}

// ============================================================================
// WebAssembly (`wasm32-unknown-unknown`) C-ABI Entrypoints
// ============================================================================

/// WASM entrypoint: Madelung hydrodynamic Lagrangian density $\mathcal{L}_{\mathrm{Mad}}^\rho$.
#[unsafe(no_mangle)]
pub extern "C" fn wasm_madelung_hydrodynamic_lagrangian_density(
    m_phi: f64,
    hbar: f64,
    g_phi: f64,
    v_ext: f64,
    rho: f64,
    grad_rho: f64,
    s_t: f64,
    grad_s: f64,
) -> f64 {
    let model = MadelungVariationalActionModel { m_phi, hbar, g_phi };
    if model.validate().is_err() || rho <= 0.0 {
        return f64::NAN;
    }
    model.madelung_hydrodynamic_lagrangian_density(v_ext, rho, grad_rho, s_t, grad_s)
}

/// WASM entrypoint: Quantum Hamilton–Jacobi (QHJ) residual $\mathcal{R}_{\mathrm{QHJ}}$.
#[unsafe(no_mangle)]
pub extern "C" fn wasm_quantum_hamilton_jacobi_residual(
    m_phi: f64,
    hbar: f64,
    g_phi: f64,
    v_ext: f64,
    amplitude: f64,
    laplacian_a: f64,
    s_t: f64,
    v_phi: f64,
) -> f64 {
    let model = MadelungVariationalActionModel { m_phi, hbar, g_phi };
    if model.validate().is_err() || amplitude <= 0.0 {
        return f64::NAN;
    }
    model.quantum_hamilton_jacobi_residual(v_ext, amplitude, laplacian_a, s_t, v_phi)
}

/// WASM entrypoint: Legendre-transformed dilatant Hamiltonian $H_{\mathrm{DDF}}(v) = \gamma_\varphi(v) m c^2$.
#[unsafe(no_mangle)]
pub extern "C" fn wasm_ddf_dilatant_hamiltonian(
    rest_mass: f64,
    speed_of_light: f64,
    velocity: f64,
) -> f64 {
    let sheath = DdfDilatantVariationalSheath {
        rest_mass,
        speed_of_light,
        velocity,
    };
    if sheath.validate().is_err() {
        return f64::NAN;
    }
    sheath.dilatant_hamiltonian()
}

/// WASM entrypoint: strain-thickened dilatant Bogoliubov squared phase velocity $v_{p,\mathrm{DDF}}^2(k)$.
#[unsafe(no_mangle)]
pub extern "C" fn wasm_ddf_dilatant_bogoliubov_phase_vel_sq(
    m_phi: f64,
    g0: f64,
    rho0: f64,
    gamma_dil: f64,
    hbar: f64,
    k: f64,
) -> f64 {
    if m_phi <= 0.0 || g0 <= 0.0 || rho0 <= 0.0 || gamma_dil < 0.0 || hbar <= 0.0 {
        return f64::NAN;
    }
    DdfDilatantVariationalSheath::dilatant_bogoliubov_phase_vel_sq(
        m_phi, g0, rho0, gamma_dil, hbar, k,
    )
}

/// WASM entrypoint: positive-definite Madelung hydrodynamic Hamiltonian density $\mathcal{H}_{\mathrm{Mad}}^\rho$.
#[unsafe(no_mangle)]
pub extern "C" fn wasm_madelung_hydrodynamic_hamiltonian_density(
    m_phi: f64,
    hbar: f64,
    g_phi: f64,
    v_ext: f64,
    rho: f64,
    grad_rho: f64,
    v_phi: f64,
) -> f64 {
    let model = MadelungVariationalActionModel { m_phi, hbar, g_phi };
    if model.validate().is_err() || rho <= 0.0 {
        return f64::NAN;
    }
    model.madelung_hydrodynamic_hamiltonian_density(v_ext, rho, grad_rho, v_phi)
}

/// WASM entrypoint: STED-depleted nanolithography focal spot core Bohm quantum potential $Q_{\mathrm{STED}}$.
#[unsafe(no_mangle)]
pub extern "C" fn wasm_sted_core_bohm_potential(
    m_phi: f64,
    hbar: f64,
    lambda_write: f64,
    na: f64,
    sat_ratio: f64,
) -> f64 {
    let model = MadelungVariationalActionModel {
        m_phi,
        hbar,
        g_phi: 0.0,
    };
    if model.validate().is_err() || lambda_write <= 0.0 || na <= 0.0 || sat_ratio < 0.0 {
        return f64::NAN;
    }
    model.sted_core_bohm_potential(lambda_write, na, sat_ratio)
}

#[cfg(test)]
mod tests {
    use super::*;
    use rstest::rstest;

    #[rstest]
    #[case(1.0, 2.0, 5.0, 7.0, 3.0, 1.5, 4.0, -2.0, 6.0, -3.0, 1.2)]
    #[case(2.5, 1.0, 0.8, -1.5, 2.0, -0.4, 0.5, 3.0, 1.5, 2.0, -0.7)]
    fn parametric_gp_polar_to_madelung_lagrangian_and_euler_lagrange(
        #[case] m_phi: f64,
        #[case] hbar: f64,
        #[case] g_phi: f64,
        #[case] v_ext: f64,
        #[case] amplitude: f64,
        #[case] a_dot: f64,
        #[case] grad_a: f64,
        #[case] lap_a: f64,
        #[case] s_val: f64,
        #[case] s_t: f64,
        #[case] grad_s: f64,
    ) {
        let model = MadelungVariationalActionModel { m_phi, hbar, g_phi };
        model.validate().unwrap();

        let theta = s_val / hbar;
        let psi = MadelungVariationalActionModel::polar_wavefunction(amplitude, theta);
        let psi_t =
            MadelungVariationalActionModel::polar_derivative(amplitude, a_dot, theta, s_t / hbar);
        let psi_x = MadelungVariationalActionModel::polar_derivative(
            amplitude,
            grad_a,
            theta,
            grad_s / hbar,
        );

        let rho = amplitude * amplitude;
        let grad_rho = 2.0 * amplitude * grad_a;

        assert!((psi.norm_sq() - rho).abs() < 1e-12);
        assert!((model.gp_temporal_symplectic_term(psi, psi_t) - (-rho * s_t)).abs() < 1e-12);
        assert!(
            (psi_x.norm_sq() - (grad_a * grad_a + rho * (grad_s / hbar).powi(2))).abs() < 1e-12
        );

        let l_gp = model.gp_polar_lagrangian_density(v_ext, psi, psi_t, psi_x);
        let l_amp = model.madelung_amplitude_lagrangian_density(v_ext, amplitude, grad_a, s_t, grad_s);
        let l_hydro =
            model.madelung_hydrodynamic_lagrangian_density(v_ext, rho, grad_rho, s_t, grad_s);
        assert!((l_gp - l_amp).abs() < 1e-11);
        assert!((l_hydro - l_amp).abs() < 1e-11);

        // Continuity Euler-Lagrange identity
        let dt_rho = 0.75;
        let div_rho_v = -0.75;
        let el_s =
            MadelungVariationalActionModel::phase_euler_lagrange_residual(-dt_rho, -div_rho_v);
        let cont = MadelungVariationalActionModel::continuity_residual(dt_rho, div_rho_v);
        assert!((el_s - cont).abs() < 1e-15);
        assert!(el_s.abs() < 1e-15);

        // Amplitude Euler-Lagrange to QHJ identity
        let el_a =
            model.amplitude_euler_lagrange_residual(v_ext, amplitude, lap_a, s_t, grad_s);
        let qhj = model.quantum_hamilton_jacobi_residual(
            v_ext,
            amplitude,
            lap_a,
            s_t,
            grad_s / m_phi,
        );
        assert!((el_a / (-2.0 * amplitude) - qhj).abs() < 1e-12);

        // Field Legendre transformation: pi_S * S_t - L_Mad = H_Mad = H_Mad^rho
        let pi_s = MadelungVariationalActionModel::phase_canonical_momentum(rho);
        let h_amp = model.madelung_amplitude_hamiltonian_density(v_ext, amplitude, grad_a, grad_s);
        let h_hydro = model.madelung_hydrodynamic_hamiltonian_density(
            v_ext,
            rho,
            grad_rho,
            grad_s / m_phi,
        );
        assert!(((pi_s * s_t - l_amp) - h_amp).abs() < 1e-11);
        assert!((h_hydro - h_amp).abs() < 1e-11);
        if v_ext >= 0.0 && g_phi >= 0.0 {
            assert!(h_amp >= 0.0);
        }

        // QHJ spatial gradient to Euler momentum residual
        let dt_v = 0.4;
        let v_phi = grad_s / m_phi;
        let grad_v = -0.3;
        let grad_v_ext = 1.1;
        let grad_q = -0.25;
        let qhj_grad_div_m = ((m_phi * dt_v)
            + (m_phi * v_phi * grad_v)
            + grad_v_ext
            + g_phi * grad_rho
            + grad_q)
            / m_phi;
        let euler_res =
            model.euler_momentum_residual(dt_v, v_phi, grad_v, grad_v_ext, grad_rho, grad_q);
        assert!((qhj_grad_div_m - euler_res).abs() < 1e-12);

        // Two-spline polar superposition & 532nm STED Bohm confinement
        let (in_phase, quad) =
            MadelungVariationalActionModel::two_spline_polar_superposition_densities(0.8, 0.8, theta);
        assert!((in_phase - 2.56).abs() < 1e-12);
        assert!((quad - 1.28).abs() < 1e-12);
        assert!(quad < 2.0 && 2.0 < in_phase);

        let q_abbe = model.sted_core_bohm_potential(405.0, 1.4, 0.0);
        let q_sted = model.sted_core_bohm_potential(405.0, 1.4, 63.0);
        assert!((q_sted - 64.0 * q_abbe).abs() < 1e-12);
    }

    #[rstest]
    #[case(5.0, 2.0, 1.0, 0.25)] // beta = 0.5, beta^2 = 0.25
    #[case(3.0, 5.0, 3.0, 0.36)] // beta = 0.6, beta^2 = 0.36, gamma = 1.25
    #[case(2.0, 10.0, 8.0, 0.64)] // beta = 0.8, beta^2 = 0.64, gamma = 5/3
    fn parametric_ddf_dilatant_variational_jamming_and_gr24_laws(
        #[case] rest_mass: f64,
        #[case] speed_of_light: f64,
        #[case] velocity: f64,
        #[case] expected_beta_sq: f64,
    ) {
        let sheath = DdfDilatantVariationalSheath {
            rest_mass,
            speed_of_light,
            velocity,
        };
        sheath.validate().unwrap();
        assert!((sheath.beta_sq() - expected_beta_sq).abs() < 1e-12);

        let gamma = sheath.jamming_factor();
        assert!(sheath.sheath_compression_residual(gamma).abs() < 1e-12);
        assert!(sheath.sheath_variational_excess(gamma).abs() < 1e-12);
        assert!(sheath.sheath_variational_excess(gamma + 0.5) > 0.0);

        let mc2 = rest_mass * speed_of_light * speed_of_light;
        let h_ddf = sheath.dilatant_hamiltonian();
        let p_ddf = sheath.dilatant_canonical_momentum();
        assert!((h_ddf - gamma * mc2).abs() < 1e-11);
        assert!((h_ddf - (mc2 + sheath.reversible_kinetic_energy())).abs() < 1e-11);
        assert!(
            ((h_ddf * h_ddf - speed_of_light * speed_of_light * p_ddf * p_ddf) - mc2 * mc2).abs()
                < 1e-9
        );

        let dt = 2.5;
        let (mink_lhs, mink_rhs) = sheath.minkowski_interval_sq(dt);
        assert!((mink_lhs - mink_rhs).abs() < 1e-11);

        let (lag_sq, plucker_prod, splat_det_ratio, inv_jam_sq) =
            sheath.gr24_plucker_and_splat_invariants(2.0, 0.4);
        assert!((lag_sq - inv_jam_sq).abs() < 1e-12);
        assert!((plucker_prod - inv_jam_sq).abs() < 1e-12);
        assert!((splat_det_ratio - inv_jam_sq).abs() < 1e-12);

        let vp_std =
            DdfDilatantVariationalSheath::standard_bogoliubov_phase_vel_sq(1.0, 2.0, 3.0, 2.0, 4.0);
        let vp_dil = DdfDilatantVariationalSheath::dilatant_bogoliubov_phase_vel_sq(
            1.0, 2.0, 3.0, 0.5, 2.0, 4.0,
        );
        assert!(vp_dil > vp_std);
        assert!((vp_dil - vp_std - 48.0).abs() < 1e-12);
    }

    #[test]
    fn madelung_1d_periodic_stepper_conserves_total_mass() {
        let model = MadelungVariationalActionModel {
            m_phi: 1.0,
            hbar: 1.0,
            g_phi: 0.5,
        };
        let rho0 = vec![1.0, 1.2, 0.9, 0.8, 1.1, 1.0];
        let s0 = vec![0.0, 0.1, 0.2, 0.1, 0.0, -0.1];
        let v_ext = vec![0.0; 6];
        let total_mass_before: f64 = rho0.iter().sum();
        let (rho1, s1) = model.step_1d_madelung_qhj_periodic(&rho0, &s0, &v_ext, 0.5, 0.01);
        let total_mass_after: f64 = rho1.iter().sum();
        assert_eq!(s1.len(), 6);
        assert!((total_mass_after - total_mass_before).abs() < 1e-12);
    }
}
