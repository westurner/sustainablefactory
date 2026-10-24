//! Inelastic Scattering (Inverse Compton & Stokes/Anti-Stokes Raman) and
//! Thermal Transport (Fourier, Cattaneo–Vernotte, and Unified Grassmannian $Gr_{\mathbb{C}}(2,4)$–DDF)
//! for Rust and `wasm32-unknown-unknown`.
//!
//! Mirrors the machine-checked Lean 4 definitions and theorems in:
//! - `Signals.Scattering` (`inverseComptonDopplerRatio`, `inverseComptonKleinNishinaRatio`,
//!   `inverseCompton_thomson_and_recoil_identities`, `ramanStokesFreq`, `ramanAntiStokesFreq`,
//!   `ramanNormalizedShift`, `ramanAntiStokesToStokesThermalRatio`,
//!   `raman_stokes_antiStokes_gr24_identities`), and
//! - `Signals.DDF` (`MovingSheath.inverseCompton_gr24_identities`, `FourierHeatModel`,
//!   `CattaneoVernotteHeatModel`, `MovingSheath.ddfSecondSoundSpeed`,
//!   `MovingSheath.ddfLongitudinalDiffusivity`, `NormedTensorGaussianSplat2D.evolveThermal`,
//!   `MovingSheath.ddfThermalTransport_and_splat_identities`).

use crate::double_slit::{
    Complex64, MultiSlitParams, complex_gr24_channel_matrix, ddf_gr24_twistor_matrix,
    two_row_minor_complex,
};
use crate::orbital_splat::NormedTensorGaussianSplat2D;
use crate::{ValidationError, require_finite, require_nonnegative, require_positive};

// ============================================================================
// 1. Inverse Compton Scattering (Thomson Doppler vs. Klein–Nishina Recoil)
// ============================================================================

/// Head-on relativistic Inverse Compton frequency upshift ratio in the Thomson
/// (negligible-recoil) regime:
/// $$\frac{\omega_{\max}^{\mathrm{ICS}}}{\omega_0} = \frac{1 + \beta}{1 - \beta} = \gamma_\varphi(v)^2 (1 + \beta)^2,$$
/// matching `Signals.Scattering.inverseComptonDopplerRatio`.
#[inline]
pub fn inverse_compton_doppler_ratio(beta: f64) -> f64 {
    (1.0 + beta) / (1.0 - beta)
}

/// Relativistic Inverse Compton frequency upshift ratio with dimensionless
/// Klein–Nishina quantum recoil parameter $\epsilon_{\mathrm{rec}} \ge 0$:
/// $$\frac{\omega_{\mathrm{KN}}^{\mathrm{ICS}}}{\omega_0} = \frac{(1 + \beta)/(1 - \beta)}{1 + \epsilon_{\mathrm{rec}}},$$
/// matching `Signals.Scattering.inverseComptonKleinNishinaRatio`.
#[inline]
pub fn inverse_compton_klein_nishina_ratio(beta: f64, epsilon_rec: f64) -> f64 {
    inverse_compton_doppler_ratio(beta) / (1.0 + epsilon_rec)
}

/// Angle-averaged relativistic Inverse Compton power boost factor
/// $$\frac{P_{\mathrm{ICS}}}{P_{\mathrm{Thomson}}} = \frac{4}{3}(\gamma^2 - 1) = \frac{4}{3}\gamma^2\beta^2,$$
/// matching the third identity in `Signals.DDF.MovingSheath.inverseCompton_gr24_identities`.
#[inline]
pub fn inverse_compton_angle_averaged_power_boost(beta: f64) -> f64 {
    let gamma_sq = 1.0 / (1.0 - beta * beta);
    (4.0 / 3.0) * (gamma_sq - 1.0)
}

/// Inverse reconstruction of reduced velocity $\beta = \frac{D - 1}{D + 1}$ from the
/// head-on Thomson Inverse Compton Doppler ratio $D = \frac{1 + \beta}{1 - \beta}$,
/// matching `Signals.Scattering.reconstructInverseComptonBeta`.
#[inline]
pub fn reconstruct_inverse_compton_beta(doppler_ratio: f64) -> f64 {
    (doppler_ratio - 1.0) / (doppler_ratio + 1.0)
}

/// Inverse reconstruction of the dimensionless Klein–Nishina quantum recoil parameter
/// $\epsilon_{\mathrm{rec}} = \frac{D}{R_{\mathrm{KN}}} - 1$, matching
/// `Signals.Scattering.reconstructKleinNishinaRecoil`.
#[inline]
pub fn reconstruct_klein_nishina_recoil(doppler_ratio: f64, kn_ratio: f64) -> f64 {
    (doppler_ratio / kn_ratio) - 1.0
}

/// Evaluate the forward ($|w_A^{\mathbb{C}}|^2 = 1 + \beta$), backward ($|w_B^{\mathbb{C}}|^2 = 1 - \beta$),
/// and ratio ($|w_A^{\mathbb{C}}|^2 / |w_B^{\mathbb{C}}|^2 = (1 + \beta)/(1 - \beta)$) invariants
/// directly from the DDF moving-sheath $Gr_{\mathbb{C}}(2,4)$ twistor matrix.
pub fn ddf_sheath_inverse_compton_gr24_invariants(
    beta: f64,
    separation_d: f64,
    wavelength: f64,
    screen_distance_l: f64,
    delta_oam: i32,
    azimuth_phi: f64,
    x: f64,
) -> (f64, f64, f64) {
    let params = MultiSlitParams {
        num_slits: 2,
        single_slit_scale: 1.0,
        slit_width: 1.0,
        slit_height: 1.0,
        slit_separation: separation_d,
        wavelength,
        screen_distance: screen_distance_l,
        visibility: (1.0 - beta * beta).max(0.0).sqrt(),
        delta_oam,
        azimuth_phi,
        barycentric_shift: beta,
        decoherence_rate: 0.0,
        non_equilibrium_residual: 0.0,
        oam_decoherence_rate: 0.0,
    };
    let m_c = ddf_gr24_twistor_matrix(beta, &params, x);
    let w_a = two_row_minor_complex(&m_c, 0, 1).mul(two_row_minor_complex(&m_c, 2, 3));
    let w_b = two_row_minor_complex(&m_c, 0, 3).mul(two_row_minor_complex(&m_c, 1, 2));
    let norm_a = w_a.norm_sq();
    let norm_b = w_b.norm_sq();
    (norm_a, norm_b, norm_a / norm_b)
}

// ============================================================================
// 2. Stokes & Anti-Stokes Raman Scattering & Thermometry
// ============================================================================

/// Stokes and anti-Stokes Raman scattering channel model and $Gr_{\mathbb{C}}(2,4)$
/// Plücker channel thermometer, matching `Signals.Scattering.raman_*`.
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct RamanChannelModel {
    pub omega_pump: f64,
    pub omega_vib: f64,
}

impl RamanChannelModel {
    pub fn validate(&self) -> Result<(), ValidationError> {
        require_positive("omega_pump", self.omega_pump)?;
        require_nonnegative("omega_vib", self.omega_vib)?;
        if self.omega_vib >= self.omega_pump {
            return Err(ValidationError::NonPositive("omega_pump - omega_vib"));
        }
        Ok(())
    }

    /// Stokes scattered frequency $\omega_S = \omega_L - \Omega_v$ (`ramanStokesFreq`).
    #[inline]
    pub fn stokes_freq(&self) -> f64 {
        self.omega_pump - self.omega_vib
    }

    /// Anti-Stokes scattered frequency $\omega_{AS} = \omega_L + \Omega_v$ (`ramanAntiStokesFreq`).
    #[inline]
    pub fn anti_stokes_freq(&self) -> f64 {
        self.omega_pump + self.omega_vib
    }

    /// Normalized Raman shift $\delta_R = \Omega_v / \omega_L \in [0, 1)$ (`ramanNormalizedShift`),
    /// acting as the $Gr_{\mathbb{C}}(2,4)$ barycentric shift $d_{\mathrm{bary}}$.
    #[inline]
    pub fn normalized_shift(&self) -> f64 {
        self.omega_vib / self.omega_pump
    }

    /// Inverse recovery of $(\omega_L, \Omega_v)$ from $(\omega_{AS}, \omega_S)$,
    /// matching `reconstructSpectralDiff` and `reconstructYangCoupling`.
    #[inline]
    pub fn reconstruct_pump_and_vib(omega_anti_stokes: f64, omega_stokes: f64) -> (f64, f64) {
        (
            0.5 * (omega_anti_stokes + omega_stokes),
            0.5 * (omega_anti_stokes - omega_stokes),
        )
    }

    /// Canonical $Gr_{\mathbb{C}}(2,4)$ twistor matrix for the Raman anti-Stokes ($1 + \delta_R$)
    /// and Stokes ($1 - \delta_R$) channels at coherent phase $\theta$.
    pub fn gr24_twistor_matrix(&self, phase_theta: f64) -> [[Complex64; 4]; 2] {
        let delta_r = self.normalized_shift();
        let a = (1.0 + delta_r).max(0.0).sqrt();
        let b = (1.0 - delta_r).max(0.0).sqrt();
        let (s, c) = phase_theta.sin_cos();
        let z1 = Complex64::new(a * c, a * s);
        let z2 = Complex64::new(b * c, -b * s);
        complex_gr24_channel_matrix(z1, z2)
    }

    /// Coherent $Gr_{\mathbb{C}}(2,4)$ Plücker channel ratio
    /// $\frac{|w_A^{\mathbb{C}}|^2}{|w_B^{\mathbb{C}}|^2} = \frac{1 + \delta_R}{1 - \delta_R} = \frac{\omega_{AS}}{\omega_S}$.
    #[inline]
    pub fn gr24_plucker_ratio(&self) -> f64 {
        let d = self.normalized_shift();
        (1.0 + d) / (1.0 - d)
    }

    /// Bose–Einstein thermal phonon occupation number
    /// $\bar{n}_{\mathrm{BE}}(\xi) = \frac{1}{\exp(\xi) - 1}$, matching
    /// `Signals.Scattering.boseEinsteinOccupancy`.
    #[inline]
    pub fn bose_einstein_occupancy(boltzmann_exponent_xi: f64) -> f64 {
        1.0 / (boltzmann_exponent_xi.exp() - 1.0)
    }

    /// Thermal Anti-Stokes to Stokes Raman intensity ratio
    /// $R_{AS/S}(\xi) = \left(\frac{\omega_{AS}}{\omega_S}\right)^4 \exp(-\xi)$ for
    /// Boltzmann exponent $\xi = \frac{\hbar\Omega_v}{k_B T} > 0$,
    /// matching `Signals.Scattering.ramanAntiStokesToStokesThermalRatio`.
    #[inline]
    pub fn anti_stokes_to_stokes_thermal_ratio(&self, boltzmann_exponent_xi: f64) -> f64 {
        self.gr24_plucker_ratio().powi(4) * (-boltzmann_exponent_xi).exp()
    }

    /// Reconstruct the dimensionless Boltzmann exponent $\xi = \frac{\hbar\Omega_v}{k_B T}$
    /// from a measured Anti-Stokes/Stokes intensity ratio $R_{AS/S} > 0$:
    /// $\xi = 4\ln(\omega_{AS}/\omega_S) - \ln(R_{AS/S})$.
    #[inline]
    pub fn reconstruct_boltzmann_exponent(&self, measured_ratio: f64) -> f64 {
        4.0 * self.gr24_plucker_ratio().ln() - measured_ratio.ln()
    }

    /// Reconstruct physical absolute temperature $T = \frac{\Theta_v}{\xi}$ (in Kelvin)
    /// from characteristic vibrational temperature $\Theta_v = \frac{\hbar\Omega_v}{k_B}$
    /// and measured Anti-Stokes/Stokes intensity ratio $R_{AS/S} > 0$, matching
    /// `Signals.Scattering.reconstructRamanTemperature`.
    #[inline]
    pub fn reconstruct_temperature_kelvin(
        &self,
        char_temp_theta_v: f64,
        measured_ratio: f64,
    ) -> f64 {
        char_temp_theta_v / self.reconstruct_boltzmann_exponent(measured_ratio)
    }
}

// ============================================================================
// 3. The Heat Problem: Fourier, Cattaneo–Vernotte, and Unified Grassmannian–DDF
// ============================================================================

/// Classical parabolic Fourier heat conduction model, matching
/// `Signals.DDF.FourierHeatModel`.
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct FourierHeatModel {
    pub thermal_conductivity: f64,
    pub volumetric_heat_capacity: f64,
}

impl FourierHeatModel {
    pub fn validate(&self) -> Result<(), ValidationError> {
        require_positive("thermal_conductivity", self.thermal_conductivity)?;
        require_positive("volumetric_heat_capacity", self.volumetric_heat_capacity)
    }

    /// Thermal diffusivity $\alpha = k_{\mathrm{th}} / (\rho c_v)$ (`FourierHeatModel.diffusivity`).
    #[inline]
    pub fn diffusivity(&self) -> f64 {
        self.thermal_conductivity / self.volumetric_heat_capacity
    }

    /// Classical Fourier heat flux $q_{\mathrm{Fourier}} = -k_{\mathrm{th}}\,\nabla T$ (`FourierHeatModel.fourierFlux`).
    #[inline]
    pub fn fourier_flux(&self, grad_t: f64) -> f64 {
        -self.thermal_conductivity * grad_t
    }

    /// Squared harmonic phase velocity $v_{\mathrm{phase}}^2(\omega) = 2\alpha\omega$
    /// (`FourierHeatModel.highFreqPhaseSpeedSq`).
    #[inline]
    pub fn high_freq_phase_speed_sq(&self, omega: f64) -> f64 {
        2.0 * self.diffusivity() * omega
    }

    /// Witness angular frequency $\omega_* = \frac{V^2}{2\alpha} + 1 > 0$ at which the parabolic
    /// Fourier phase speed strictly exceeds any speed ceiling $V \ge 0$ (including $c$),
    /// matching `FourierHeatModel.diffusivity_pos_and_acausal_speed`.
    #[inline]
    pub fn acausal_witness_frequency(&self, speed_ceiling_v: f64) -> f64 {
        (speed_ceiling_v * speed_ceiling_v) / (2.0 * self.diffusivity()) + 1.0
    }

    /// One explicit 1D parabolic finite-difference step on a periodic ring of spacing `dx`.
    /// Preserves the discrete spatial sum $\sum_i T_i$ to machine precision.
    pub fn step_1d_periodic(&self, temp: &[f64], dx: f64, dt: f64) -> Vec<f64> {
        let n = temp.len();
        if n == 0 {
            return Vec::new();
        }
        let r = self.diffusivity() * dt / (dx * dx);
        let mut next = vec![0.0; n];
        for i in 0..n {
            let left = temp[(i + n - 1) % n];
            let right = temp[(i + 1) % n];
            next[i] = temp[i] + r * (left - 2.0 * temp[i] + right);
        }
        next
    }
}

/// Hyperbolic Cattaneo–Vernotte heat conduction model, matching
/// `Signals.DDF.CattaneoVernotteHeatModel`.
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct CattaneoVernotteHeatModel {
    pub fourier: FourierHeatModel,
    pub relaxation_time: f64,
}

impl CattaneoVernotteHeatModel {
    pub fn validate(&self) -> Result<(), ValidationError> {
        self.fourier.validate()?;
        require_positive("relaxation_time", self.relaxation_time)
    }

    /// Squared second-sound wave speed $c_{\mathrm{CV}}^2 = \alpha / \tau_r$
    /// (`CattaneoVernotteHeatModel.secondSoundSpeedSq`).
    #[inline]
    pub fn second_sound_speed_sq(&self) -> f64 {
        self.fourier.diffusivity() / self.relaxation_time
    }

    /// Second-sound wave speed $c_{\mathrm{CV}} = \sqrt{\alpha / \tau_r}$
    /// (`CattaneoVernotteHeatModel.secondSoundSpeed`).
    #[inline]
    pub fn second_sound_speed(&self) -> f64 {
        self.second_sound_speed_sq().sqrt()
    }

    /// Constitutive heat-flux residual $\tau_r \partial_t q + q - q_{\mathrm{Fourier}}(\nabla T)$
    /// (`CattaneoVernotteHeatModel.cattaneoFluxResidual`).
    #[inline]
    pub fn cattaneo_flux_residual(&self, q: f64, dq_dt: f64, grad_t: f64) -> f64 {
        self.relaxation_time * dq_dt + q - self.fourier.fourier_flux(grad_t)
    }

    /// Hyperbolic telegrapher PDE residual $\tau_r \partial_t^2 T + \partial_t T - \alpha \partial_x^2 T$
    /// (`CattaneoVernotteHeatModel.telegrapherResidual`).
    #[inline]
    pub fn telegrapher_residual(&self, d2t_dt2: f64, dt_dt: f64, d2t_dx2: f64) -> f64 {
        self.relaxation_time * d2t_dt2 + dt_dt - self.fourier.diffusivity() * d2t_dx2
    }

    /// Symplectic/leapfrog 1D hyperbolic step for coupled temperature `temp` and heat flux `flux`
    /// on a periodic ring of spacing `dx`:
    /// $\partial_t q = -\frac{1}{\tau_r}(q + k_{\mathrm{th}} \partial_x T)$,
    /// $\partial_t T = -\frac{1}{\rho c_v}\partial_x q$.
    pub fn step_1d_periodic(
        &self,
        temp: &[f64],
        flux: &[f64],
        dx: f64,
        dt: f64,
    ) -> (Vec<f64>, Vec<f64>) {
        let n = temp.len();
        if n == 0 || flux.len() != n {
            return (Vec::new(), Vec::new());
        }
        let mut next_flux = vec![0.0; n];
        let mut next_temp = vec![0.0; n];
        for i in 0..n {
            let ip1 = (i + 1) % n;
            let grad_t = (temp[ip1] - temp[i]) / dx;
            let dq_dt = -(flux[i] + self.fourier.thermal_conductivity * grad_t) / self.relaxation_time;
            next_flux[i] = flux[i] + dt * dq_dt;
        }
        for i in 0..n {
            let im1 = (i + n - 1) % n;
            let div_q = (next_flux[i] - next_flux[im1]) / dx;
            next_temp[i] = temp[i] - (dt / self.fourier.volumetric_heat_capacity) * div_q;
        }
        (next_temp, next_flux)
    }
}

/// Unified Grassmannian $Gr_{\mathbb{C}}(2,4)$–DDF thermal transport model, matching
/// `MovingSheath.ddfSecondSoundSpeed`, `MovingSheath.ddfLongitudinalDiffusivity`, and
/// `MovingSheath.ddfThermalTransport_and_splat_identities` in `Signals.DDF`.
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct DdfGrassmannianThermalTransport {
    pub rest_second_sound_speed: f64,
    pub speed_of_light: f64,
    pub sheath_beta: f64,
    pub relaxation_time: f64,
}

impl DdfGrassmannianThermalTransport {
    pub fn validate(&self) -> Result<(), ValidationError> {
        require_positive("rest_second_sound_speed", self.rest_second_sound_speed)?;
        require_positive("speed_of_light", self.speed_of_light)?;
        require_nonnegative("sheath_beta", self.sheath_beta)?;
        require_positive("relaxation_time", self.relaxation_time)?;
        if self.rest_second_sound_speed > self.speed_of_light {
            return Err(ValidationError::NonPositive(
                "speed_of_light - rest_second_sound_speed",
            ));
        }
        if self.sheath_beta >= 1.0 {
            return Err(ValidationError::NonPositive("1 - sheath_beta"));
        }
        Ok(())
    }

    /// Coherence visibility $\mathcal{V}(s) = \sqrt{1 - \beta^2} = \gamma_\varphi(v)^{-1}$.
    #[inline]
    pub fn coherence_visibility(&self) -> f64 {
        (1.0 - self.sheath_beta * self.sheath_beta).max(0.0).sqrt()
    }

    /// Constitutive DDF Lorentz jamming factor $\gamma_\varphi(v) = (1 - \beta^2)^{-1/2}$.
    #[inline]
    pub fn jamming_factor(&self) -> f64 {
        1.0 / self.coherence_visibility()
    }

    /// Subluminal DDF longitudinal second-sound speed
    /// $c_{\mathrm{th}}^{\mathrm{DDF}}(s) = c_{\mathrm{th},0}\,\mathcal{V}(s) = c_{\mathrm{th},0}/\gamma_\varphi(v) \le c_{\mathrm{th},0} \le c$,
    /// matching `Signals.DDF.MovingSheath.ddfSecondSoundSpeed`.
    #[inline]
    pub fn ddf_second_sound_speed(&self) -> f64 {
        self.rest_second_sound_speed * self.coherence_visibility()
    }

    /// Rest-frame (or transverse) thermal diffusivity $\alpha_0 = c_{\mathrm{th},0}^2 \tau_r$.
    #[inline]
    pub fn rest_diffusivity(&self) -> f64 {
        self.rest_second_sound_speed * self.rest_second_sound_speed * self.relaxation_time
    }

    /// Lorentz-jammed longitudinal thermal diffusivity
    /// $\alpha_\parallel^{\mathrm{DDF}}(s) = \bigl(c_{\mathrm{th}}^{\mathrm{DDF}}(s)\bigr)^2 \tau_r = \alpha_0\,\gamma_\varphi(v)^{-2}$,
    /// matching `Signals.DDF.MovingSheath.ddfLongitudinalDiffusivity`.
    #[inline]
    pub fn ddf_longitudinal_diffusivity(&self) -> f64 {
        let c_ddf = self.ddf_second_sound_speed();
        c_ddf * c_ddf * self.relaxation_time
    }

    /// Splat-free continuum DDF hyperbolic telegrapher PDE residual
    /// $\mathcal{R}_{\mathrm{tele}}^{\mathrm{DDF}} = \tau_r \partial_t^2 T + \partial_t T - \alpha_\parallel^{\mathrm{DDF}}(s) \partial_x^2 T$,
    /// matching `Signals.DDF.MovingSheath.ddfTelegrapherResidual`.
    #[inline]
    pub fn ddf_telegrapher_residual(&self, d2t_dt2: f64, dt_dt: f64, d2t_dx2: f64) -> f64 {
        self.relaxation_time * d2t_dt2 + dt_dt - self.ddf_longitudinal_diffusivity() * d2t_dx2
    }

    /// Maximum causal ballistic heat flux $q_{\max}^{\mathrm{DDF}}(s) = \rho c_v c_{\mathrm{th}}^{\mathrm{DDF}}(s) T_0$,
    /// matching `Signals.DDF.MovingSheath.ddfMaxCausalHeatFlux`.
    #[inline]
    pub fn max_causal_heat_flux(&self, volumetric_heat_capacity: f64, ref_temp_t0: f64) -> f64 {
        volumetric_heat_capacity * self.ddf_second_sound_speed() * ref_temp_t0
    }

    /// Splat-free complex $Gr_{\mathbb{C}}(2,4)$ hyperbolic thermal characteristic
    /// (Riemann-invariant) matrix $M_{\mathbb{C}}^{\mathrm{th}}(j_q, \theta)$ for reduced heat flux
    /// $j_q = q / q_{\max}^{\mathrm{DDF}}(s) \in [-1, 1]$, matching `Signals.DDF.ddfThermalGr24Matrix`.
    pub fn gr24_characteristic_matrix(
        reduced_heat_flux_jq: f64,
        phase_theta: f64,
    ) -> [[Complex64; 4]; 2] {
        let jq = reduced_heat_flux_jq.clamp(-1.0, 1.0);
        let a = (1.0 + jq).max(0.0).sqrt();
        let b = (1.0 - jq).max(0.0).sqrt();
        let (s, c) = phase_theta.sin_cos();
        let z_plus = Complex64::new(a * c, a * s);
        let z_minus = Complex64::new(b * c, -b * s);
        complex_gr24_channel_matrix(z_plus, z_minus)
    }

    /// Splat-free $Gr_{\mathbb{C}}(2,4)$ Plücker characteristic invariants
    /// `(|w_A|^2, |w_B|^2, (|w_A|^2 - |w_B|^2)/2, |w_A|^2 * |w_B|^2)` = `(1 + j_q, 1 - j_q, j_q, 1 - j_q^2)`,
    /// matching `MovingSheath.ddfThermalTransport_continuum_identities`.
    pub fn gr24_characteristic_invariants(
        reduced_heat_flux_jq: f64,
        phase_theta: f64,
    ) -> (f64, f64, f64, f64) {
        let m_th = Self::gr24_characteristic_matrix(reduced_heat_flux_jq, phase_theta);
        let w_a = two_row_minor_complex(&m_th, 0, 1)
            .mul(two_row_minor_complex(&m_th, 2, 3))
            .norm_sq();
        let w_b = two_row_minor_complex(&m_th, 0, 3)
            .mul(two_row_minor_complex(&m_th, 1, 2))
            .norm_sq();
        (w_a, w_b, 0.5 * (w_a - w_b), w_a * w_b)
    }

    /// Splat-free continuum thermal mode evolution
    /// $\mathcal{S}_{\mathrm{mode}}(\alpha_\parallel^{\mathrm{DDF}}(s), k, \Delta t)(A) = A\,\exp(-\alpha_\parallel^{\mathrm{DDF}}(s) k^2 \Delta t)$,
    /// matching `Signals.DDF.evolveContinuumThermalMode`.
    #[inline]
    pub fn evolve_continuum_thermal_mode(&self, wavenumber: f64, dt: f64, amplitude: f64) -> f64 {
        let alpha = self.ddf_longitudinal_diffusivity();
        amplitude * (-alpha * wavenumber * wavenumber * dt).exp()
    }

    /// Splat-free continuum Cattaneo–Vernotte / DDF reduced heat-flux relaxation
    /// $j_q(t + \Delta t) = j_q\,\exp(-\Delta t / \tau_r)$,
    /// matching `Signals.DDF.evolveContinuumReducedHeatFlux`.
    #[inline]
    pub fn evolve_continuum_reduced_heat_flux(&self, dt: f64, reduced_heat_flux_jq: f64) -> f64 {
        reduced_heat_flux_jq * (-dt / self.relaxation_time).exp()
    }

    /// Splat-free continuum Bohm quantum potential scale
    /// $Q_{\mathrm{cont}}(m, \hbar, \kappa) = \frac{\hbar^2 \kappa^2}{2m}$,
    /// matching `Signals.DDF.continuumBohmPotentialMode`.
    #[inline]
    pub fn continuum_bohm_potential_mode(m_boson: f64, hbar: f64, kappa: f64) -> f64 {
        (hbar * hbar * kappa * kappa) / (2.0 * m_boson)
    }

    /// Splat-free 1D continuum hyperbolic Grassmannian–DDF step on a periodic ring
    /// of spacing `dx`, enforcing the $Gr_{\mathbb{C}}(2,4)$ Plücker characteristic flux limiter
    /// $|q| \le q_{\max}^{\mathrm{DDF}}(s)$ (`1 - j_q^2 >= 0`) and conserving total thermal energy $\sum_i T_i$.
    pub fn step_1d_continuum_periodic(
        &self,
        volumetric_heat_capacity: f64,
        ref_temp_t0: f64,
        temp: &[f64],
        flux: &[f64],
        dx: f64,
        dt: f64,
    ) -> (Vec<f64>, Vec<f64>) {
        let n = temp.len();
        if n == 0 || flux.len() != n {
            return (Vec::new(), Vec::new());
        }
        let k_ddf = volumetric_heat_capacity * self.ddf_longitudinal_diffusivity();
        let q_max = self
            .max_causal_heat_flux(volumetric_heat_capacity, ref_temp_t0)
            .abs();
        let mut next_flux = vec![0.0; n];
        let mut next_temp = vec![0.0; n];
        for i in 0..n {
            let ip1 = (i + 1) % n;
            let grad_t = (temp[ip1] - temp[i]) / dx;
            let dq_dt = -(flux[i] + k_ddf * grad_t) / self.relaxation_time;
            let raw_q = flux[i] + dt * dq_dt;
            next_flux[i] = if q_max > 0.0 {
                raw_q.clamp(-q_max, q_max)
            } else {
                raw_q
            };
        }
        for i in 0..n {
            let im1 = (i + n - 1) % n;
            let div_q = (next_flux[i] - next_flux[im1]) / dx;
            next_temp[i] = temp[i] - (dt / volumetric_heat_capacity) * div_q;
        }
        (next_temp, next_flux)
    }

    /// Evolve a DDF normed 2D tensor Gaussian splat over elapsed time `dt >= 0`
    /// using the anisotropic DDF thermal diffusivities $(\alpha_\parallel^{\mathrm{DDF}}(s), \alpha_0)$.
    pub fn evolve_ddf_thermal_splat(
        &self,
        splat: &NormedTensorGaussianSplat2D,
        dt: f64,
    ) -> NormedTensorGaussianSplat2D {
        splat.evolve_thermal(
            self.ddf_longitudinal_diffusivity(),
            self.rest_diffusivity(),
            dt,
        )
    }
}

// ============================================================================
// 4. WebAssembly (`wasm32-unknown-unknown`) C-ABI Entrypoints
// ============================================================================

/// WASM entrypoint: relativistic Inverse Compton Klein–Nishina frequency upshift ratio.
#[unsafe(no_mangle)]
pub extern "C" fn wasm_inverse_compton_klein_nishina_ratio(beta: f64, epsilon_rec: f64) -> f64 {
    if require_finite("beta", beta).is_err() || !(0.0..1.0).contains(&beta) || epsilon_rec < 0.0 {
        return f64::NAN;
    }
    inverse_compton_klein_nishina_ratio(beta, epsilon_rec)
}

/// WASM entrypoint: thermal Anti-Stokes to Stokes Raman intensity ratio.
#[unsafe(no_mangle)]
pub extern "C" fn wasm_raman_antistokes_to_stokes_ratio(
    omega_pump: f64,
    omega_vib: f64,
    boltzmann_exponent_xi: f64,
) -> f64 {
    let model = RamanChannelModel {
        omega_pump,
        omega_vib,
    };
    if model.validate().is_err() || require_finite("xi", boltzmann_exponent_xi).is_err() {
        return f64::NAN;
    }
    model.anti_stokes_to_stokes_thermal_ratio(boltzmann_exponent_xi)
}

/// WASM entrypoint: subluminal DDF longitudinal second-sound speed $c_{\mathrm{th}}^{\mathrm{DDF}}(s)$.
#[unsafe(no_mangle)]
pub extern "C" fn wasm_ddf_second_sound_speed(
    rest_second_sound_speed: f64,
    speed_of_light: f64,
    sheath_beta: f64,
    relaxation_time: f64,
) -> f64 {
    let model = DdfGrassmannianThermalTransport {
        rest_second_sound_speed,
        speed_of_light,
        sheath_beta,
        relaxation_time,
    };
    if model.validate().is_err() {
        return f64::NAN;
    }
    model.ddf_second_sound_speed()
}

// ============================================================================
// 5. Parametric Tests (`rstest`) and Snapshot Tests (`insta`)
// ============================================================================

#[cfg(test)]
mod tests {
    use super::*;
    use rstest::rstest;

    #[rstest]
    #[case(0.0, 0.1, 1.0, 1.0 / 1.1, 0.0)]
    #[case(0.6, 0.25, 4.0, 3.2, (4.0 / 3.0) * (1.5625 - 1.0))]
    #[case(0.8, 0.5, 9.0, 6.0, (4.0 / 3.0) * (1.0 / 0.36 - 1.0))]
    fn parametric_inverse_compton_gr24_and_klein_nishina_recoil(
        #[case] beta: f64,
        #[case] epsilon_rec: f64,
        #[case] expected_thomson_ratio: f64,
        #[case] expected_kn_ratio: f64,
        #[case] expected_power_boost: f64,
    ) {
        let thomson = inverse_compton_doppler_ratio(beta);
        let kn = inverse_compton_klein_nishina_ratio(beta, epsilon_rec);
        let kn_zero = inverse_compton_klein_nishina_ratio(beta, 0.0);
        let p_boost = inverse_compton_angle_averaged_power_boost(beta);

        assert!(thomson >= 1.0 - 1e-12);
        assert!((thomson - expected_thomson_ratio).abs() < 1e-12);
        assert!(((1.0 - beta * beta) * thomson - (1.0 + beta).powi(2)).abs() < 1e-12);
        assert!((kn_zero - thomson).abs() < 1e-12);
        assert!(kn < thomson);
        assert!((kn - expected_kn_ratio).abs() < 1e-12);
        assert!((p_boost - expected_power_boost).abs() < 1e-12);

        let (norm_a, norm_b, gr24_ratio) =
            ddf_sheath_inverse_compton_gr24_invariants(beta, 6.0, 1.0, 5.0, 2, 0.4, 0.3);
        assert!((norm_a - (1.0 + beta)).abs() < 1e-12);
        assert!((norm_b - (1.0 - beta)).abs() < 1e-12);
        assert!((gr24_ratio - thomson).abs() < 1e-12);
        assert!((reconstruct_inverse_compton_beta(thomson) - beta).abs() < 1e-12);
        assert!((reconstruct_klein_nishina_recoil(thomson, kn) - epsilon_rec).abs() < 1e-12);
    }

    #[rstest]
    #[case(563.0, 47.5, 0.8)] // 532 nm green laser pump (563 THz), CNT G-band ~1585 cm^-1 (47.5 THz)
    #[case(382.0, 40.5, 0.6)] // 785 nm NIR laser pump (382 THz), CNT D-band ~1350 cm^-1 (40.5 THz)
    #[case(193.4, 13.2, 0.25)] // 1550 nm telecom fiber pump (193.4 THz), silica Raman peak (13.2 THz)
    fn parametric_raman_stokes_antistokes_gr24_and_thermometry(
        #[case] omega_pump: f64,
        #[case] omega_vib: f64,
        #[case] xi: f64,
    ) {
        let model = RamanChannelModel {
            omega_pump,
            omega_vib,
        };
        model.validate().unwrap();
        let w_s = model.stokes_freq();
        let w_as = model.anti_stokes_freq();
        let delta_r = model.normalized_shift();
        let (rec_pump, rec_vib) = RamanChannelModel::reconstruct_pump_and_vib(w_as, w_s);
        assert!((rec_pump - omega_pump).abs() < 1e-12);
        assert!((rec_vib - omega_vib).abs() < 1e-12);
        assert!((w_s * w_as - omega_pump * omega_pump * (1.0 - delta_r * delta_r)).abs() < 1e-9);
        assert!(((w_as / w_s) - model.gr24_plucker_ratio()).abs() < 1e-12);

        let m_c = model.gr24_twistor_matrix(0.5);
        let ch_a = two_row_minor_complex(&m_c, 0, 1)
            .mul(two_row_minor_complex(&m_c, 2, 3))
            .norm_sq();
        let ch_b = two_row_minor_complex(&m_c, 0, 3)
            .mul(two_row_minor_complex(&m_c, 1, 2))
            .norm_sq();
        assert!(((ch_a / ch_b) - (w_as / w_s)).abs() < 1e-12);

        let n_be = RamanChannelModel::bose_einstein_occupancy(xi);
        assert!(n_be > 0.0);
        assert!(((n_be / (n_be + 1.0)) - (-xi).exp()).abs() < 1e-12);

        let r_therm = model.anti_stokes_to_stokes_thermal_ratio(xi);
        assert!(r_therm < model.gr24_plucker_ratio().powi(4));
        let theta_v = 2280.0; // e.g. CNT G-band characteristic temperature ~ 2280 K
        let temp_k = theta_v / xi;
        let rec_temp_k = model.reconstruct_temperature_kelvin(theta_v, r_therm);
        assert!((rec_temp_k - temp_k).abs() < 1e-9);
        let rec_xi = model.reconstruct_boltzmann_exponent(r_therm);
        assert!((rec_xi - xi).abs() < 1e-12);
    }

    #[rstest]
    #[case(0.0, 1.0, 1.0)]
    #[case(0.6, 0.8, 1.25)]
    #[case(0.8, 0.6, 1.0 / 0.6)]
    fn parametric_fourier_cattaneo_vernotte_and_ddf_thermal_splat_laws(
        #[case] sheath_beta: f64,
        #[case] expected_vis: f64,
        #[case] expected_jam: f64,
    ) {
        let fourier = FourierHeatModel {
            thermal_conductivity: 4.0,
            volumetric_heat_capacity: 2.0,
        };
        fourier.validate().unwrap();
        assert!((fourier.diffusivity() - 2.0).abs() < 1e-12);
        let v_ceil = 10.0;
        let omega_star = fourier.acausal_witness_frequency(v_ceil);
        assert!(omega_star > 0.0);
        assert!(fourier.high_freq_phase_speed_sq(omega_star) > v_ceil * v_ceil);

        let cv = CattaneoVernotteHeatModel {
            fourier,
            relaxation_time: 0.5,
        };
        cv.validate().unwrap();
        assert!((cv.second_sound_speed_sq() - 4.0).abs() < 1e-12);
        assert!((cv.second_sound_speed() - 2.0).abs() < 1e-12);
        assert!(
            (cv.cattaneo_flux_residual(7.0, 0.0, -2.0) - (7.0 - fourier.fourier_flux(-2.0))).abs()
                < 1e-12
        );
        let tel_res = cv.telegrapher_residual(3.0, 1.5, -0.5);
        let wave_op =
            3.0 / cv.second_sound_speed_sq() + 1.5 / fourier.diffusivity() - (-0.5);
        assert!((tel_res / fourier.diffusivity() - wave_op).abs() < 1e-12);

        let ddf_th = DdfGrassmannianThermalTransport {
            rest_second_sound_speed: 0.5,
            speed_of_light: 1.0,
            sheath_beta,
            relaxation_time: 0.5,
        };
        ddf_th.validate().unwrap();
        assert!((ddf_th.coherence_visibility() - expected_vis).abs() < 1e-12);
        assert!((ddf_th.jamming_factor() - expected_jam).abs() < 1e-12);
        assert!(ddf_th.ddf_second_sound_speed() > 0.0);
        assert!(ddf_th.ddf_second_sound_speed() <= ddf_th.speed_of_light);

        let sigma0 = 2.0;
        let splat_ddf = NormedTensorGaussianSplat2D::from_ddf_moving_sheath(
            0.0,
            0.0,
            5.0,
            sigma0,
            sheath_beta,
            0.25,
        );
        let ratio_diff = ddf_th.ddf_longitudinal_diffusivity() / ddf_th.rest_diffusivity();
        let ratio_cov = splat_ddf.cov_det() / sigma0.powi(4);
        assert!((ratio_diff - ratio_cov).abs() < 1e-12);

        let dt = 3.0;
        let splat_evol = ddf_th.evolve_ddf_thermal_splat(&splat_ddf, dt);
        assert!((splat_evol.weight - splat_ddf.weight).abs() < 1e-12);
        let a1 = ddf_th.ddf_longitudinal_diffusivity();
        let a2 = ddf_th.rest_diffusivity();
        let expected_trace = splat_ddf.cov_trace() + 2.0 * (a1 + a2) * dt;
        assert!((splat_evol.cov_trace() - expected_trace).abs() < 1e-12);
        let expected_det = splat_ddf.cov_det()
            + 2.0
                * (a1 * splat_ddf.sigma2 * splat_ddf.sigma2
                    + a2 * splat_ddf.sigma1 * splat_ddf.sigma1)
                * dt
            + 4.0 * a1 * a2 * dt * dt;
        assert!((splat_evol.cov_det() - expected_det).abs() < 1e-12);
        assert!(splat_evol.cov_det() > splat_ddf.cov_det());
        assert!(splat_evol.norm_factor() <= splat_ddf.norm_factor());
        assert!(splat_evol.core_bohm_potential(1.0, 1.0) <= splat_ddf.core_bohm_potential(1.0, 1.0));

        // Verify Chapman-Kolmogorov thermal semigroup identity (dt = 0) and additivity: evolve(dt1) then evolve(dt2) == evolve(dt1 + dt2)
        let step0 = ddf_th.evolve_ddf_thermal_splat(&splat_ddf, 0.0);
        assert!((step0.sigma1 - splat_ddf.sigma1).abs() < 1e-12);
        assert!((step0.sigma2 - splat_ddf.sigma2).abs() < 1e-12);
        let step12 = ddf_th.evolve_ddf_thermal_splat(&splat_evol, 4.0);
        let step_sum = ddf_th.evolve_ddf_thermal_splat(&splat_ddf, dt + 4.0);
        assert!((step12.sigma1 - step_sum.sigma1).abs() < 1e-12);
        assert!((step12.sigma2 - step_sum.sigma2).abs() < 1e-12);

        // Verify 1D periodic Fourier and Cattaneo-Vernotte PDE steppers conserve total thermal energy
        let init_temp = vec![1.0, 2.0, 5.0, 2.0, 1.0, 0.5];
        let init_sum: f64 = init_temp.iter().sum();
        let next_f = fourier.step_1d_periodic(&init_temp, 1.0, 0.05);
        let sum_f: f64 = next_f.iter().sum();
        assert!((sum_f - init_sum).abs() < 1e-12);

        let init_flux = vec![0.0; init_temp.len()];
        let (next_cv_t, _next_cv_q) = cv.step_1d_periodic(&init_temp, &init_flux, 1.0, 0.05);
        let sum_cv: f64 = next_cv_t.iter().sum();
        assert!((sum_cv - init_sum).abs() < 1e-12);

        // Verify splat-free continuum Grassmannian Gr_C(2,4)-DDF telegrapher operator,
        // sheath Plucker product bridge, and Riemann-invariant flux limiter
        let (norm_a_sh, norm_b_sh, _) =
            ddf_sheath_inverse_compton_gr24_invariants(sheath_beta, 6.0, 1.0, 5.0, 2, 0.0, 0.0);
        assert!((ratio_diff - norm_a_sh * norm_b_sh).abs() < 1e-12);

        let ddf_tel_res = ddf_th.ddf_telegrapher_residual(4.0, 2.0, -1.0);
        let ddf_wave_op = (expected_jam * expected_jam / (0.5 * 0.5)) * 4.0
            + (expected_jam * expected_jam / (0.5 * 0.5 * 0.5)) * 2.0
            - (-1.0);
        assert!((ddf_tel_res / ddf_th.ddf_longitudinal_diffusivity() - ddf_wave_op).abs() < 1e-12);

        let jq = 0.6;
        let (w_a_th, w_b_th, jq_rec, prod_th) =
            DdfGrassmannianThermalTransport::gr24_characteristic_invariants(jq, 0.35);
        assert!((w_a_th - (1.0 + jq)).abs() < 1e-12);
        assert!((w_b_th - (1.0 - jq)).abs() < 1e-12);
        assert!((jq_rec - jq).abs() < 1e-12);
        assert!((prod_th - (1.0 - jq * jq)).abs() < 1e-12);
        assert!(prod_th > 0.0);

        // Verify splat-free continuum Chapman-Kolmogorov thermal mode & heat-flux semigroup identity (dt = 0) & additivity,
        // exact splat-free continuum Bohm potential attenuation, and exact Gr_C(2,4) Plucker Second-Law increment
        let kappa0 = 5.0;
        let k_wave = 1.2;
        assert!((ddf_th.evolve_continuum_thermal_mode(k_wave, 0.0, kappa0) - kappa0).abs() < 1e-12);
        let kappa1 = ddf_th.evolve_continuum_thermal_mode(k_wave, dt, kappa0);
        let kappa12 = ddf_th.evolve_continuum_thermal_mode(k_wave, 4.0, kappa1);
        let kappa_sum = ddf_th.evolve_continuum_thermal_mode(k_wave, dt + 4.0, kappa0);
        assert!((kappa12 - kappa_sum).abs() < 1e-12);
        let q_bohm0 = DdfGrassmannianThermalTransport::continuum_bohm_potential_mode(1.0, 1.0, kappa0);
        let q_bohm1 = DdfGrassmannianThermalTransport::continuum_bohm_potential_mode(1.0, 1.0, kappa1);
        let expected_bohm1 =
            q_bohm0 * (-2.0 * ddf_th.ddf_longitudinal_diffusivity() * k_wave * k_wave * dt).exp();
        assert!((q_bohm1 - expected_bohm1).abs() < 1e-12);
        assert!(q_bohm1 <= q_bohm0);

        assert!((ddf_th.evolve_continuum_reduced_heat_flux(0.0, jq) - jq).abs() < 1e-12);
        let jq1 = ddf_th.evolve_continuum_reduced_heat_flux(dt, jq);
        let jq12 = ddf_th.evolve_continuum_reduced_heat_flux(4.0, jq1);
        let jq_sum = ddf_th.evolve_continuum_reduced_heat_flux(dt + 4.0, jq);
        assert!((jq12 - jq_sum).abs() < 1e-12);
        let (_, _, _, prod_th_1) =
            DdfGrassmannianThermalTransport::gr24_characteristic_invariants(jq1, 0.35);
        let expected_plucker_inc = jq * jq * (1.0 - (-2.0 * dt / ddf_th.relaxation_time).exp());
        assert!(((prod_th_1 - prod_th) - expected_plucker_inc).abs() < 1e-12);
        assert!(prod_th <= prod_th_1 + 1e-12);

        let (next_ddf_t, next_ddf_q) =
            ddf_th.step_1d_continuum_periodic(2.0, 10.0, &init_temp, &init_flux, 1.0, 0.05);
        let sum_ddf: f64 = next_ddf_t.iter().sum();
        assert!((sum_ddf - init_sum).abs() < 1e-12);
        let q_max = ddf_th.max_causal_heat_flux(2.0, 10.0);
        for &q_val in &next_ddf_q {
            assert!(q_val.abs() <= q_max + 1e-12);
        }
    }

    #[test]
    fn insta_snapshot_thermal_inelastic_summary() {
        let raman_cnt = RamanChannelModel {
            omega_pump: 563.0,
            omega_vib: 47.5,
        };
        let cv = CattaneoVernotteHeatModel {
            fourier: FourierHeatModel {
                thermal_conductivity: 4.0,
                volumetric_heat_capacity: 2.0,
            },
            relaxation_time: 0.5,
        };
        let ddf_th = DdfGrassmannianThermalTransport {
            rest_second_sound_speed: 0.5,
            speed_of_light: 1.0,
            sheath_beta: 0.6,
            relaxation_time: 0.5,
        };
        let splat_ddf = NormedTensorGaussianSplat2D::from_ddf_moving_sheath(
            0.0, 0.0, 5.0, 2.0, 0.6, 0.0,
        );
        let splat_evol = ddf_th.evolve_ddf_thermal_splat(&splat_ddf, 2.0);
        let summary = (
            format!(
                "ICS(beta=0.6): thomson_ratio={:.4}, kn_ratio(eps=0.25)={:.4}, power_boost={:.4}",
                inverse_compton_doppler_ratio(0.6),
                inverse_compton_klein_nishina_ratio(0.6, 0.25),
                inverse_compton_angle_averaged_power_boost(0.6),
            ),
            format!(
                "Raman_CNT_Gband: stokes={:.2}THz, antistokes={:.2}THz, gr24_ratio={:.6}, R_AS_S(xi=0.8)={:.6}",
                raman_cnt.stokes_freq(),
                raman_cnt.anti_stokes_freq(),
                raman_cnt.gr24_plucker_ratio(),
                raman_cnt.anti_stokes_to_stokes_thermal_ratio(0.8),
            ),
            format!(
                "Heat: fourier_alpha={:.4}, cv_second_sound={:.4}, ddf_second_sound={:.4}, ddf_alpha_par={:.4}, splat_trace_0={:.4}, splat_trace_evol={:.4}",
                cv.fourier.diffusivity(),
                cv.second_sound_speed(),
                ddf_th.ddf_second_sound_speed(),
                ddf_th.ddf_longitudinal_diffusivity(),
                splat_ddf.cov_trace(),
                splat_evol.cov_trace(),
            ),
        );
        insta::assert_debug_snapshot!("thermal_inelastic_compton_raman_ddf_summary", summary);
    }
}
