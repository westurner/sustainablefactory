//! Planetary orbital mechanics, Mercury perihelion precession, $N$-body sink-flow
//! dynamics, complex $Gr_{\mathbb{C}}(2, 4)$ orbital twistor matrices, and normed 2D
//! anisotropic Tensor Gaussian Splatting for $Gr_{\mathbb{C}}(2, 4)$ and Dilatant
//! Dark Fluid (DDF) fields, with WebAssembly C-ABI exports and WebGL2 GLSL shaders.
//!
//! Mirrors the machine-checked Lean 4 theorems in `Signals.DDF` and `Signals.Geometry`.

use crate::double_slit::{
    Complex64, complex_gr2n_channel_matrix, complex_gr24_channel_matrix, two_row_minor_complex,
    two_row_minor_complex_slice,
};
use crate::{ValidationError, require_finite, require_nonnegative, require_positive};
use std::f64::consts::PI;

/// Embedded WebGL2 (`#version 300 es`) vertex shader for orbital & tensor splat visualization.
pub const GLSL_ORBITAL_SPLAT_VERTEX_SHADER: &str =
    include_str!("shaders/orbital_splat.vert.glsl");

/// Embedded WebGL2 (`#version 300 es`) fragment shader rendering normed Tensor Gaussian
/// Splats for $Gr_{\mathbb{C}}(2, 4)$ orbital fields, DDF shear-jammed sheaths, and
/// gravitating bodies/attractors/sinks/sources.
pub const GLSL_ORBITAL_SPLAT_FRAGMENT_SHADER: &str =
    include_str!("shaders/orbital_splat.frag.glsl");

/// Astronomical Unit in kilometers ($1\text{ AU} = 149,597,870.7\text{ km}$).
pub const AU_KM: f64 = 149_597_870.7;

/// Solar DDF acoustic horizon / Schwarzschild radius $r_{H,\odot} = 2 G M_\odot / c^2$ in km.
pub const SOLAR_HORIZON_RADIUS_KM: f64 = 2.953_250_08;

/// Days per Julian century ($36,525\text{ days}$).
pub const DAYS_PER_JULIAN_CENTURY: f64 = 36_525.0;

/// Canonical solar-system orbiting bodies used for relativistic / QFT / DDF validation.
#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum SolarSystemBody {
    Mercury,
    Venus,
    Earth,
    Mars,
    Icarus,
}

/// Keplerian and post-Minkowskian / DDF orbital parameters for a bound planetary orbit,
/// matching `Signals.DDF.PlanetaryOrbit`.
#[repr(C)]
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct PlanetaryOrbitParams {
    /// Semi-major axis $a > 0$ in Astronomical Units (AU).
    pub semi_major_axis_au: f64,
    /// Orbital eccentricity $e \in [0, 1)$.
    pub eccentricity: f64,
    /// Sidereal orbital period $T > 0$ in days.
    pub orbital_period_days: f64,
    /// Central mass acoustic horizon radius $r_H = 2 G_\phi M / c^2 > 0$ in km.
    pub central_horizon_radius_km: f64,
    /// Secular Newtonian $N$-body planetary perturbation rate in arcseconds per Julian century.
    pub newtonian_nbody_arcsec_per_century: f64,
}

impl PlanetaryOrbitParams {
    /// Construct canonical validated parameters for a solar-system body.
    pub fn from_solar_system_body(body: SolarSystemBody) -> Self {
        match body {
            SolarSystemBody::Mercury => Self {
                semi_major_axis_au: 0.387_098_93,
                eccentricity: 0.205_630_69,
                orbital_period_days: 87.9691,
                central_horizon_radius_km: SOLAR_HORIZON_RADIUS_KM,
                newtonian_nbody_arcsec_per_century: 531.63,
            },
            SolarSystemBody::Venus => Self {
                semi_major_axis_au: 0.723_331_99,
                eccentricity: 0.006_773_23,
                orbital_period_days: 224.701,
                central_horizon_radius_km: SOLAR_HORIZON_RADIUS_KM,
                newtonian_nbody_arcsec_per_century: 0.0,
            },
            SolarSystemBody::Earth => Self {
                semi_major_axis_au: 1.000_000_11,
                eccentricity: 0.016_710_22,
                orbital_period_days: 365.256_36,
                central_horizon_radius_km: SOLAR_HORIZON_RADIUS_KM,
                newtonian_nbody_arcsec_per_century: 0.0,
            },
            SolarSystemBody::Mars => Self {
                semi_major_axis_au: 1.523_662_31,
                eccentricity: 0.093_412_33,
                orbital_period_days: 686.980,
                central_horizon_radius_km: SOLAR_HORIZON_RADIUS_KM,
                newtonian_nbody_arcsec_per_century: 0.0,
            },
            SolarSystemBody::Icarus => Self {
                semi_major_axis_au: 1.0779,
                eccentricity: 0.8268,
                orbital_period_days: 408.78,
                central_horizon_radius_km: SOLAR_HORIZON_RADIUS_KM,
                newtonian_nbody_arcsec_per_century: 0.0,
            },
        }
    }

    pub fn validate(&self) -> Result<(), ValidationError> {
        require_positive("semi_major_axis_au", self.semi_major_axis_au)?;
        require_nonnegative("eccentricity", self.eccentricity)?;
        if self.eccentricity >= 1.0 {
            return Err(ValidationError::ResidualTooLarge("eccentricity >= 1"));
        }
        require_positive("orbital_period_days", self.orbital_period_days)?;
        require_positive("central_horizon_radius_km", self.central_horizon_radius_km)?;
        require_finite(
            "newtonian_nbody_arcsec_per_century",
            self.newtonian_nbody_arcsec_per_century,
        )?;
        Ok(())
    }

    /// Semi-latus rectum $p = a(1 - e^2)$ in AU (`PlanetaryOrbit.semiLatusRectum`).
    #[inline]
    pub fn semi_latus_rectum_au(&self) -> f64 {
        self.semi_major_axis_au * (1.0 - self.eccentricity * self.eccentricity)
    }

    /// Semi-latus rectum $p = a(1 - e^2)$ in km.
    #[inline]
    pub fn semi_latus_rectum_km(&self) -> f64 {
        self.semi_latus_rectum_au() * AU_KM
    }

    /// Perihelion radius $r_{\min} = a(1 - e)$ in AU (`PlanetaryOrbit.perihelionRadius`).
    #[inline]
    pub fn perihelion_radius_au(&self) -> f64 {
        self.semi_major_axis_au * (1.0 - self.eccentricity)
    }

    /// Aphelion radius $r_{\max} = a(1 + e)$ in AU (`PlanetaryOrbit.aphelionRadius`).
    #[inline]
    pub fn aphelion_radius_au(&self) -> f64 {
        self.semi_major_axis_au * (1.0 + self.eccentricity)
    }

    /// Dimensionless precession rate parameter $\eta_{\mathrm{prec}} = \frac{3 r_H}{2 p}$.
    #[inline]
    pub fn eta_precession(&self) -> f64 {
        1.5 * self.central_horizon_radius_km / self.semi_latus_rectum_km()
    }

    /// Anomalous perihelion precession in radians per orbit:
    /// $\Delta\varpi = \frac{3\pi r_H}{p} = \frac{6\pi G_\phi M}{c^2 a(1 - e^2)}$,
    /// matching `Signals.DDF.RiverExterior.perihelionPrecessionRad`.
    #[inline]
    pub fn anomalous_precession_rad_per_orbit(&self) -> f64 {
        3.0 * PI * self.central_horizon_radius_km / self.semi_latus_rectum_km()
    }

    /// Anomalous perihelion precession in arcseconds per orbit via the $\pi$-free law
    /// $\Delta\varpi_{\mathrm{arcsec}} = \frac{1,944,000\,r_H}{p}$,
    /// matching `Signals.DDF.RiverExterior.perihelionPrecessionArcsecPerOrbit_eq`.
    #[inline]
    pub fn anomalous_precession_arcsec_per_orbit(&self) -> f64 {
        1_944_000.0 * self.central_horizon_radius_km / self.semi_latus_rectum_km()
    }

    /// Number of sidereal revolutions per Julian century ($36,525 / T_{\mathrm{days}}$).
    #[inline]
    pub fn orbits_per_julian_century(&self) -> f64 {
        DAYS_PER_JULIAN_CENTURY / self.orbital_period_days
    }

    /// Anomalous relativistic / QFT / DDF perihelion advance in arcseconds per Julian century.
    #[inline]
    pub fn anomalous_precession_arcsec_per_century(&self) -> f64 {
        self.anomalous_precession_arcsec_per_orbit() * self.orbits_per_julian_century()
    }

    /// Total inertial perihelion advance (relativistic + Newtonian $N$-body) in arcseconds per century.
    #[inline]
    pub fn total_precession_arcsec_per_century(&self) -> f64 {
        self.anomalous_precession_arcsec_per_century() + self.newtonian_nbody_arcsec_per_century
    }

    /// Precessing polar conic radius $r(\varphi; \eta_{\mathrm{prec}}) = \frac{p}{1 + e\cos((1 - \eta_{\mathrm{prec}})\varphi)}$
    /// in AU, matching `Signals.DDF.PlanetaryOrbit.precessingRadius`.
    #[inline]
    pub fn precessing_radius_au(&self, eta_override: Option<f64>, phi: f64) -> f64 {
        let eta = eta_override.unwrap_or_else(|| self.eta_precession());
        self.semi_latus_rectum_au() / (1.0 + self.eccentricity * ((1.0 - eta) * phi).cos())
    }

    /// Cartesian $(x, y)$ position in AU along the precessing polar conic at azimuth $\varphi$.
    #[inline]
    pub fn precessing_cartesian_au(&self, eta_override: Option<f64>, phi: f64) -> [f64; 2] {
        let r = self.precessing_radius_au(eta_override, phi);
        [r * phi.cos(), r * phi.sin()]
    }

    /// Canonical $Gr_{\mathbb{C}}(2, 4)$ planetary orbital precession twistor matrix
    /// $M_{\mathbb{C}}^{\mathrm{orb}}(\mathrm{orb}, \Delta\varpi)$, matching
    /// `Signals.DDF.PlanetaryOrbit.gr24PrecessionMatrix`.
    pub fn gr24_precession_matrix(&self, delta_varpi_override: Option<f64>) -> [[Complex64; 4]; 2] {
        let dv = delta_varpi_override.unwrap_or_else(|| self.anomalous_precession_rad_per_orbit());
        let theta = 0.5 * dv;
        let a = (1.0 + self.eccentricity).max(0.0).sqrt();
        let b = (1.0 - self.eccentricity).max(0.0).sqrt();
        let z_aph = Complex64::from_polar(a, theta);
        let z_per = Complex64::from_polar(b, -theta);
        complex_gr24_channel_matrix(z_aph, z_per)
    }
}

/// Summary of the $Gr_{\mathbb{C}}(2, 4)$ orbital invariants for a planetary orbit,
/// matching `Signals.DDF.PlanetaryOrbit.gr24PrecessionMatrix_orbital_identities`.
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct Gr24OrbitalInvariants {
    pub madelung_aphelion_ratio: f64,
    pub madelung_perihelion_ratio: f64,
    pub madelung_eccentricity: f64,
    pub madelung_semi_latus_ratio: f64,
    pub crossing_minor_norm_sq: f64,
    pub bcj_jacobi_residual_norm_sq: f64,
}

impl Gr24OrbitalInvariants {
    pub fn evaluate(orbit: &PlanetaryOrbitParams, delta_varpi_override: Option<f64>) -> Self {
        let mat = orbit.gr24_precession_matrix(delta_varpi_override);
        let n_s = two_row_minor_complex(&mat, 0, 1).mul(two_row_minor_complex(&mat, 2, 3));
        let n_t_pos = two_row_minor_complex(&mat, 0, 2).mul(two_row_minor_complex(&mat, 1, 3));
        let n_u = two_row_minor_complex(&mat, 0, 3).mul(two_row_minor_complex(&mat, 1, 2));
        let bcj_jacobi = n_s.sub(n_t_pos).add(n_u);

        let w_a_sq = n_s.norm_sq();
        let w_b_sq = n_u.norm_sq();
        Self {
            madelung_aphelion_ratio: w_a_sq,
            madelung_perihelion_ratio: w_b_sq,
            madelung_eccentricity: 0.5 * (w_a_sq - w_b_sq),
            madelung_semi_latus_ratio: w_a_sq * w_b_sq,
            crossing_minor_norm_sq: n_t_pos.norm_sq(),
            bcj_jacobi_residual_norm_sq: bcj_jacobi.norm_sq(),
        }
    }
}

/// Symplectic Velocity-Verlet state for a planet orbiting in the 1-loop QFT / DDF
/// effective potential $V_{\mathrm{eff}}(r) = -\frac{\mu}{r}\bigl(1 + \frac{3 h^2}{c^2 r^2}\bigr)$.
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct RelativisticOrbitState {
    pub position: [f64; 2],
    pub velocity: [f64; 2],
    pub gm_central: f64,
    pub c_speed: f64,
}

impl RelativisticOrbitState {
    /// Specific angular momentum $h = x v_y - y v_x$.
    #[inline]
    pub fn specific_angular_momentum(&self) -> f64 {
        self.position[0] * self.velocity[1] - self.position[1] * self.velocity[0]
    }

    /// Radial distance $r = \sqrt{x^2 + y^2}$.
    #[inline]
    pub fn radius(&self) -> f64 {
        (self.position[0] * self.position[0] + self.position[1] * self.position[1]).sqrt()
    }

    /// Specific conservative mechanical energy
    /// $\mathcal{E} = \frac{1}{2}|\mathbf{v}|^2 - \frac{\mu}{r}\bigl(1 + \frac{3 h^2}{c^2 r^2}\bigr)$.
    pub fn specific_mechanical_energy(&self) -> f64 {
        let v_sq = self.velocity[0] * self.velocity[0] + self.velocity[1] * self.velocity[1];
        let r = self.radius().max(1e-12);
        let h = self.specific_angular_momentum();
        let rel_corr = 1.0 + (3.0 * h * h) / (self.c_speed * self.c_speed * r * r);
        0.5 * v_sq - (self.gm_central / r) * rel_corr
    }

    /// Conservative radial acceleration
    /// $\mathbf{a}(\mathbf{r}) = -\frac{\mu}{r^3}\bigl(1 + \frac{9 h^2}{c^2 r^2}\bigr)\mathbf{r}$
    /// (with fixed specific angular momentum $h$).
    pub fn acceleration(&self, pos: [f64; 2], h: f64) -> [f64; 2] {
        let r_sq = (pos[0] * pos[0] + pos[1] * pos[1]).max(1e-18);
        let r = r_sq.sqrt();
        let r_cubed = r_sq * r;
        let factor =
            -(self.gm_central / r_cubed) * (1.0 + (9.0 * h * h) / (self.c_speed * self.c_speed * r_sq));
        [factor * pos[0], factor * pos[1]]
    }

    /// Advance one time step `dt` using the symplectic Velocity-Verlet integrator.
    pub fn step_velocity_verlet(&mut self, dt: f64) {
        let h = self.specific_angular_momentum();
        let a0 = self.acceleration(self.position, h);
        let half_vx = self.velocity[0] + 0.5 * dt * a0[0];
        let half_vy = self.velocity[1] + 0.5 * dt * a0[1];
        let next_pos = [
            self.position[0] + dt * half_vx,
            self.position[1] + dt * half_vy,
        ];
        let a1 = self.acceleration(next_pos, h);
        self.position = next_pos;
        self.velocity = [half_vx + 0.5 * dt * a1[0], half_vy + 0.5 * dt * a1[1]];
    }
}

/// Evaluate the $N$-body superfluid Bernoulli sink potential
/// $\Phi_\phi^{(N)} = -\sum_{j=0}^{N-1} \frac{G_\phi M_j}{r_j}$ via the $Gr_{\mathbb{C}}(2, N+2)$
/// Madelung channel sum (`Signals.DDF.nBodyBernoulliPotential_eq_neg_gr2N_madelung_sum`).
pub fn nbody_bernoulli_potential_gr2n(
    g_phi: f64,
    masses: &[f64],
    distances: &[f64],
    phases: &[f64],
) -> (f64, f64) {
    let n = masses.len().min(distances.len()).min(phases.len());
    let mut direct_potential = 0.0;
    let mut z_vec = Vec::with_capacity(n);
    for j in 0..n {
        let w_j = (g_phi * masses[j] / distances[j]).max(0.0);
        direct_potential -= w_j;
        z_vec.push(Complex64::from_polar(w_j.sqrt(), phases[j]));
    }
    let m_c = complex_gr2n_channel_matrix(&z_vec);
    let mut gr2n_madelung_sum = 0.0;
    for j in 0..n {
        let minor = two_row_minor_complex_slice(&m_c, 0, j + 2);
        gr2n_madelung_sum += minor.norm_sq();
    }
    (direct_potential, -gr2n_madelung_sum)
}

// ============================================================================
// Normed 2D Anisotropic Tensor Gaussian Splatting (Gr_C(2,4), DDF, & Sinks)
// ============================================================================

/// Physical/geometric role of a normed 2D Tensor Gaussian Splat primitive.
#[repr(i32)]
#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum SplatRole {
    /// 0: Gravitating body / attractor / superfluid sink ($\Phi_\phi < 0$) or source.
    BodySinkSource = 0,
    /// 1: Complex $Gr_{\mathbb{C}}(2, 4)$ orbital field splat ($\sigma_1 = \sigma_0\sqrt{1+e}$, $\sigma_2 = \sigma_0\sqrt{1-e}$).
    Gr24OrbitalField = 1,
    /// 2: DDF shear-jammed moving-sheath splat ($\sigma_1 = \sigma_0 / \gamma_\varphi(v)$, $\sigma_2 = \sigma_0$).
    DdfMovingSheathField = 2,
    /// 3: Gravitomagnetic / Kerr–Lense–Thirring vortex swirl splat.
    VortexSwirlField = 3,
}

/// Normed 2D anisotropic Tensor Gaussian Splat primitive, matching
/// `Signals.DDF.NormedTensorGaussianSplat2D`.
#[repr(C)]
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct NormedTensorGaussianSplat2D {
    pub center_x: f64,
    pub center_y: f64,
    pub weight: f64,
    pub sigma1: f64,
    pub sigma2: f64,
    pub orientation_angle: f64,
    pub role: SplatRole,
}

impl NormedTensorGaussianSplat2D {
    /// Construct a body / attractor / sink / source splat.
    pub fn body_sink_source(
        center_x: f64,
        center_y: f64,
        weight: f64,
        sigma1: f64,
        sigma2: f64,
        orientation_angle: f64,
    ) -> Self {
        Self {
            center_x,
            center_y,
            weight: weight.max(0.0),
            sigma1: sigma1.max(1e-9),
            sigma2: sigma2.max(1e-9),
            orientation_angle,
            role: SplatRole::BodySinkSource,
        }
    }

    /// Construct a complex $Gr_{\mathbb{C}}(2, 4)$ planetary orbital field splat with
    /// $\sigma_1 = \sigma_0 \sqrt{1 + e} = \sigma_0 |w_A^{\mathbb{C}}|$ and
    /// $\sigma_2 = \sigma_0 \sqrt{1 - e} = \sigma_0 |w_B^{\mathbb{C}}|$, matching
    /// `Signals.DDF.PlanetaryOrbit.gr24TensorSplat`.
    pub fn from_gr24_orbit(
        orbit: &PlanetaryOrbitParams,
        center_x: f64,
        center_y: f64,
        weight: f64,
        sigma0: f64,
        varpi_angle: f64,
    ) -> Self {
        let e = orbit.eccentricity.clamp(0.0, 0.999_999);
        let s0 = sigma0.max(1e-9);
        Self {
            center_x,
            center_y,
            weight: weight.max(0.0),
            sigma1: s0 * (1.0 + e).sqrt(),
            sigma2: s0 * (1.0 - e).sqrt(),
            orientation_angle: varpi_angle,
            role: SplatRole::Gr24OrbitalField,
        }
    }

    /// Construct a DDF moving-sheath tensor splat with longitudinal Lorentz/jamming
    /// contraction $\sigma_1 = \sigma_0 \sqrt{1 - \beta^2} = \sigma_0 \gamma_\varphi(v)^{-1}$
    /// and transverse width $\sigma_2 = \sigma_0$, matching
    /// `Signals.DDF.MovingSheath.ddfTensorSplat`.
    pub fn from_ddf_moving_sheath(
        center_x: f64,
        center_y: f64,
        weight: f64,
        sigma0: f64,
        beta: f64,
        velocity_angle: f64,
    ) -> Self {
        let clamped_beta = beta.clamp(0.0, 0.999_999);
        let visibility = (1.0 - clamped_beta * clamped_beta).max(1e-12).sqrt();
        let s0 = sigma0.max(1e-9);
        Self {
            center_x,
            center_y,
            weight: weight.max(0.0),
            sigma1: s0 * visibility,
            sigma2: s0,
            orientation_angle: velocity_angle,
            role: SplatRole::DdfMovingSheathField,
        }
    }

    pub fn validate(&self) -> Result<(), ValidationError> {
        require_finite("center_x", self.center_x)?;
        require_finite("center_y", self.center_y)?;
        require_nonnegative("weight", self.weight)?;
        require_positive("sigma1", self.sigma1)?;
        require_positive("sigma2", self.sigma2)?;
        require_finite("orientation_angle", self.orientation_angle)?;
        Ok(())
    }

    /// Covariance determinant $\det \Sigma = \sigma_1^2 \sigma_2^2$ (`NormedTensorGaussianSplat2D.covDet`).
    #[inline]
    pub fn cov_det(&self) -> f64 {
        (self.sigma1 * self.sigma1) * (self.sigma2 * self.sigma2)
    }

    /// Covariance trace $\operatorname{Tr} \Sigma = \sigma_1^2 + \sigma_2^2$ (`NormedTensorGaussianSplat2D.covTrace`).
    #[inline]
    pub fn cov_trace(&self) -> f64 {
        self.sigma1 * self.sigma1 + self.sigma2 * self.sigma2
    }

    /// Exact 2D $L^1(\mathbb{R}^2)$ normalization factor $\mathcal{N}(\Sigma) = \frac{1}{2\pi \sigma_1 \sigma_2}$
    /// (`NormedTensorGaussianSplat2D.normFactor`).
    #[inline]
    pub fn norm_factor(&self) -> f64 {
        1.0 / (2.0 * PI * self.sigma1 * self.sigma2)
    }

    /// Symmetric $2 \times 2$ covariance matrix $\Sigma = R(\theta)\operatorname{diag}(\sigma_1^2, \sigma_2^2)R(\theta)^T$.
    pub fn covariance_matrix_2x2(&self) -> [[f64; 2]; 2] {
        let c = self.orientation_angle.cos();
        let s = self.orientation_angle.sin();
        let l1 = self.sigma1 * self.sigma1;
        let l2 = self.sigma2 * self.sigma2;
        let s_xx = l1 * c * c + l2 * s * s;
        let s_xy = (l1 - l2) * c * s;
        let s_yy = l1 * s * s + l2 * c * c;
        [[s_xx, s_xy], [s_xy, s_yy]]
    }

    /// Symmetric $2 \times 2$ precision matrix (inverse covariance)
    /// $\Sigma^{-1} = R(\theta)\operatorname{diag}(\sigma_1^{-2}, \sigma_2^{-2})R(\theta)^T = -\nabla\nabla \ln G(x, y)$.
    pub fn precision_matrix_2x2(&self) -> [[f64; 2]; 2] {
        let c = self.orientation_angle.cos();
        let s = self.orientation_angle.sin();
        let p1 = 1.0 / (self.sigma1 * self.sigma1);
        let p2 = 1.0 / (self.sigma2 * self.sigma2);
        let p_xx = p1 * c * c + p2 * s * s;
        let p_xy = (p1 - p2) * c * s;
        let p_yy = p1 * s * s + p2 * c * c;
        [[p_xx, p_xy], [p_xy, p_yy]]
    }

    /// Rotated Mahalanobis distance squared $Q_\Sigma(x, y) = (u_1/\sigma_1)^2 + (u_2/\sigma_2)^2$,
    /// matching `Signals.DDF.NormedTensorGaussianSplat2D.mahalanobisSq`.
    #[inline]
    pub fn mahalanobis_sq(&self, x: f64, y: f64) -> f64 {
        let dx = x - self.center_x;
        let dy = y - self.center_y;
        let c = self.orientation_angle.cos();
        let s = self.orientation_angle.sin();
        let u1 = dx * c + dy * s;
        let u2 = -dx * s + dy * c;
        let q1 = u1 / self.sigma1;
        let q2 = u2 / self.sigma2;
        q1 * q1 + q2 * q2
    }

    /// Evaluate the $L^1$-normed 2D Gaussian splat at $(x, y)$, matching
    /// `Signals.DDF.NormedTensorGaussianSplat2D.eval`.
    #[inline]
    pub fn eval(&self, x: f64, y: f64) -> f64 {
        self.weight * self.norm_factor() * (-0.5 * self.mahalanobis_sq(x, y)).exp()
    }

    /// Evaluate the complex $Gr_{\mathbb{C}}(2, 4)$ twistor wavepacket
    /// $\Psi_{\mathrm{splat}}(M_{\mathbb{C}}; x, y) = \sqrt{G(x, y)}\,(w_A^{\mathbb{C}}(M_{\mathbb{C}}) + w_B^{\mathbb{C}}(M_{\mathbb{C}}))$,
    /// matching `Signals.DDF.NormedTensorGaussianSplat2D.complexTwistorWavepacket`.
    pub fn complex_twistor_wavepacket(
        &self,
        m_c: &[[Complex64; 4]; 2],
        x: f64,
        y: f64,
    ) -> Complex64 {
        let g = self.eval(x, y).max(0.0).sqrt();
        let w_a = two_row_minor_complex(m_c, 0, 1).mul(two_row_minor_complex(m_c, 2, 3));
        let w_b = two_row_minor_complex(m_c, 0, 3).mul(two_row_minor_complex(m_c, 1, 2));
        let sum = w_a.add(w_b);
        Complex64::new(g * sum.re, g * sum.im)
    }

    /// Evaluate the Madelung intensity $I_{\mathrm{splat}}(M_{\mathbb{C}}; x, y) = |\Psi_{\mathrm{splat}}|^2$
    /// of a complex $Gr_{\mathbb{C}}(2, 4)$ twistor Gaussian splat, matching
    /// `Signals.DDF.NormedTensorGaussianSplat2D.complexTwistorIntensity`.
    pub fn complex_twistor_intensity(
        &self,
        m_c: &[[Complex64; 4]; 2],
        x: f64,
        y: f64,
    ) -> f64 {
        self.complex_twistor_wavepacket(m_c, x, y).norm_sq()
    }

    /// Repulsive core Bohm quantum potential
    /// $Q_{\mathrm{core}}(\Sigma) = \frac{\hbar^2}{4m}(\sigma_1^{-2} + \sigma_2^{-2}) = \frac{\hbar^2 \operatorname{Tr}\Sigma}{4m \det\Sigma}$,
    /// matching `Signals.DDF.NormedTensorGaussianSplat2D.coreBohmPotential`.
    #[inline]
    pub fn core_bohm_potential(&self, m_boson: f64, hbar: f64) -> f64 {
        let s1_sq = self.sigma1 * self.sigma1;
        let s2_sq = self.sigma2 * self.sigma2;
        ((hbar * hbar) / (4.0 * m_boson)) * (1.0 / s1_sq + 1.0 / s2_sq)
    }

    /// Principal longitudinal component $\Pi_{11}(x, y) = \frac{\hbar^2}{4m^2 \sigma_1^2} G(x, y)$
    /// of the Madelung quantum pressure tensor, matching
    /// `Signals.DDF.NormedTensorGaussianSplat2D.quantumPressurePrincipal1`.
    #[inline]
    pub fn quantum_pressure_principal1(&self, m_boson: f64, hbar: f64, x: f64, y: f64) -> f64 {
        let pref = (hbar * hbar) / (4.0 * m_boson * m_boson * self.sigma1 * self.sigma1);
        pref * self.eval(x, y)
    }

    /// Principal transverse component $\Pi_{22}(x, y) = \frac{\hbar^2}{4m^2 \sigma_2^2} G(x, y)$
    /// of the Madelung quantum pressure tensor, matching
    /// `Signals.DDF.NormedTensorGaussianSplat2D.quantumPressurePrincipal2`.
    #[inline]
    pub fn quantum_pressure_principal2(&self, m_boson: f64, hbar: f64, x: f64, y: f64) -> f64 {
        let pref = (hbar * hbar) / (4.0 * m_boson * m_boson * self.sigma2 * self.sigma2);
        pref * self.eval(x, y)
    }

    /// Full $2 \times 2$ Madelung quantum pressure tensor
    /// $\Pi_{ij}(x, y) = -\frac{\hbar^2}{4m^2} G(x, y) \partial_i \partial_j \ln G(x, y) = \frac{\hbar^2}{4m^2} G(x, y) (\Sigma^{-1})_{ij}$.
    pub fn quantum_pressure_tensor_2x2(
        &self,
        m_boson: f64,
        hbar: f64,
        x: f64,
        y: f64,
    ) -> [[f64; 2]; 2] {
        let scale = ((hbar * hbar) / (4.0 * m_boson * m_boson)) * self.eval(x, y);
        let prec = self.precision_matrix_2x2();
        [
            [scale * prec[0][0], scale * prec[0][1]],
            [scale * prec[1][0], scale * prec[1][1]],
        ]
    }

    /// Trace $\operatorname{Tr}\Pi(x, y) = \Pi_{11}(x, y) + \Pi_{22}(x, y) = \frac{1}{m} Q_{\mathrm{core}}(\Sigma) G(x, y)$,
    /// matching `Signals.DDF.NormedTensorGaussianSplat2D.quantumPressureTrace`.
    #[inline]
    pub fn quantum_pressure_trace(&self, m_boson: f64, hbar: f64, x: f64, y: f64) -> f64 {
        self.quantum_pressure_principal1(m_boson, hbar, x, y)
            + self.quantum_pressure_principal2(m_boson, hbar, x, y)
    }

    /// Determinant $\det\Pi(x, y) = \Pi_{11}(x, y)\Pi_{22}(x, y) = (\frac{\hbar^2}{4m^2})^2 \frac{G(x, y)^2}{\det\Sigma}$,
    /// matching `Signals.DDF.NormedTensorGaussianSplat2D.quantumPressureDet`.
    #[inline]
    pub fn quantum_pressure_det(&self, m_boson: f64, hbar: f64, x: f64, y: f64) -> f64 {
        self.quantum_pressure_principal1(m_boson, hbar, x, y)
            * self.quantum_pressure_principal2(m_boson, hbar, x, y)
    }

    /// Exact $L^1$-conserving anisotropic thermal evolution over elapsed time `dt >= 0`
    /// with principal diffusivities `alpha1 >= 0` and `alpha2 >= 0`:
    /// $\sigma_i(t + \Delta t) = \sqrt{\sigma_i(t)^2 + 2\alpha_i \Delta t}$,
    /// matching `Signals.DDF.NormedTensorGaussianSplat2D.evolveThermal`.
    pub fn evolve_thermal(&self, alpha1: f64, alpha2: f64, dt: f64) -> Self {
        let a1 = alpha1.max(0.0);
        let a2 = alpha2.max(0.0);
        let step_dt = dt.max(0.0);
        Self {
            center_x: self.center_x,
            center_y: self.center_y,
            weight: self.weight,
            sigma1: (self.sigma1 * self.sigma1 + 2.0 * a1 * step_dt).sqrt(),
            sigma2: (self.sigma2 * self.sigma2 + 2.0 * a2 * step_dt).sqrt(),
            orientation_angle: self.orientation_angle,
            role: self.role,
        }
    }

    /// Principal aspect ratio $\max(\sigma_1, \sigma_2) / \min(\sigma_1, \sigma_2) \ge 1$.
    #[inline]
    pub fn aspect_ratio(&self) -> f64 {
        let hi = self.sigma1.max(self.sigma2);
        let lo = self.sigma1.min(self.sigma2).max(1e-12);
        hi / lo
    }

    /// Adaptive $L^1$-conserving two-child Gaussian splat splitting along the major
    /// principal axis when `self.aspect_ratio() > max_aspect_ratio`.
    /// Preserves total $L^1$ weight ($w_+ + w_- = w$), center of mass
    /// ($\frac{1}{2}(\mathbf{c}_+ + \mathbf{c}_-) = \mathbf{c}$), and total second-moment
    /// variance along the major axis ($\tilde{\sigma}_{\mathrm{maj}}^2 + \delta^2 = \sigma_{\mathrm{maj}}^2$
    /// with $\tilde{\sigma}_{\mathrm{maj}} = \sigma_{\mathrm{maj}} / 2$ and $\delta = \frac{\sqrt{3}}{2}\sigma_{\mathrm{maj}}$).
    pub fn split_if_anisotropic(&self, max_aspect_ratio: f64) -> Vec<Self> {
        if self.aspect_ratio() <= max_aspect_ratio.max(1.0) {
            return vec![*self];
        }
        let half_w = 0.5 * self.weight;
        let sqrt3_half = 0.5 * 3.0_f64.sqrt();
        let c = self.orientation_angle.cos();
        let s = self.orientation_angle.sin();
        if self.sigma1 >= self.sigma2 {
            let delta = sqrt3_half * self.sigma1;
            let new_sigma1 = 0.5 * self.sigma1;
            let dx = delta * c;
            let dy = delta * s;
            vec![
                Self {
                    center_x: self.center_x - dx,
                    center_y: self.center_y - dy,
                    weight: half_w,
                    sigma1: new_sigma1,
                    sigma2: self.sigma2,
                    orientation_angle: self.orientation_angle,
                    role: self.role,
                },
                Self {
                    center_x: self.center_x + dx,
                    center_y: self.center_y + dy,
                    weight: half_w,
                    sigma1: new_sigma1,
                    sigma2: self.sigma2,
                    orientation_angle: self.orientation_angle,
                    role: self.role,
                },
            ]
        } else {
            let delta = sqrt3_half * self.sigma2;
            let new_sigma2 = 0.5 * self.sigma2;
            let dx = -delta * s;
            let dy = delta * c;
            vec![
                Self {
                    center_x: self.center_x - dx,
                    center_y: self.center_y - dy,
                    weight: half_w,
                    sigma1: self.sigma1,
                    sigma2: new_sigma2,
                    orientation_angle: self.orientation_angle,
                    role: self.role,
                },
                Self {
                    center_x: self.center_x + dx,
                    center_y: self.center_y + dy,
                    weight: half_w,
                    sigma1: self.sigma1,
                    sigma2: new_sigma2,
                    orientation_angle: self.orientation_angle,
                    role: self.role,
                },
            ]
        }
    }

    /// Pack into the two `vec4` (`[f32; 4]`) uniform slots expected by `orbital_splat.frag.glsl`.
    pub fn to_glsl_uniform_pair(&self) -> ([f32; 4], [f32; 4]) {
        (
            [
                self.center_x as f32,
                self.center_y as f32,
                self.weight as f32,
                (self.role as i32) as f32,
            ],
            [
                self.sigma1 as f32,
                self.sigma2 as f32,
                self.orientation_angle as f32,
                self.norm_factor() as f32,
            ],
        )
    }
}

/// A multi-layer orbital and field visualization scene combining gravitating
/// bodies/attractors/sinks/sources, $Gr_{\mathbb{C}}(2, 4)$ orbital field splats,
/// and DDF moving-sheath splats.
#[derive(Clone, Debug, PartialEq)]
pub struct OrbitalSplatScene {
    pub splats: Vec<NormedTensorGaussianSplat2D>,
}

impl OrbitalSplatScene {
    /// Build a canonical inner-solar-system scene with the Sun central sink,
    /// Mercury/Venus/Earth attractors, $Gr_{\mathbb{C}}(2, 4)$ orbital field splats,
    /// and DDF shear-jammed moving-sheath splats.
    pub fn canonical_solar_system_scene() -> Self {
        let mercury = PlanetaryOrbitParams::from_solar_system_body(SolarSystemBody::Mercury);
        let venus = PlanetaryOrbitParams::from_solar_system_body(SolarSystemBody::Venus);
        let earth = PlanetaryOrbitParams::from_solar_system_body(SolarSystemBody::Earth);

        let merc_pos = mercury.precessing_cartesian_au(None, 0.0);
        let venus_pos = venus.precessing_cartesian_au(None, 0.5 * PI);
        let earth_pos = earth.precessing_cartesian_au(None, PI);

        let splats = vec![
            // 1. Central Solar Sink (Attractor)
            NormedTensorGaussianSplat2D::body_sink_source(0.0, 0.0, 10.0, 0.08, 0.08, 0.0),
            // 2. Mercury Body Sink + Gr_C(2,4) Orbital Field Splat + DDF Moving-Sheath Splat
            NormedTensorGaussianSplat2D::body_sink_source(
                merc_pos[0],
                merc_pos[1],
                1.0,
                0.03,
                0.03,
                0.0,
            ),
            NormedTensorGaussianSplat2D::from_gr24_orbit(&mercury, 0.0, 0.0, 2.0, 0.25, 0.0),
            NormedTensorGaussianSplat2D::from_ddf_moving_sheath(
                merc_pos[0],
                merc_pos[1],
                1.5,
                0.06,
                0.6,
                0.5 * PI,
            ),
            // 3. Venus Body Sink + Gr_C(2,4) Orbital Field Splat
            NormedTensorGaussianSplat2D::body_sink_source(
                venus_pos[0],
                venus_pos[1],
                1.2,
                0.035,
                0.035,
                0.0,
            ),
            NormedTensorGaussianSplat2D::from_gr24_orbit(
                &venus,
                0.0,
                0.0,
                2.0,
                0.45,
                0.25 * PI,
            ),
            // 4. Earth Body Sink + Gr_C(2,4) Orbital Field Splat
            NormedTensorGaussianSplat2D::body_sink_source(
                earth_pos[0],
                earth_pos[1],
                1.5,
                0.04,
                0.04,
                0.0,
            ),
            NormedTensorGaussianSplat2D::from_gr24_orbit(&earth, 0.0, 0.0, 2.5, 0.65, 0.0),
        ];
        Self { splats }
    }

    /// Conserved total $L^1(\mathbb{R}^2)$ mass/energy weight $\sum_i w_i$ across all splats.
    pub fn total_normed_weight(&self) -> f64 {
        self.splats.iter().map(|s| s.weight).sum()
    }

    /// Evaluate the summed field of all splats matching `role` at $(x, y)$.
    pub fn evaluate_field_by_role(&self, role: SplatRole, x: f64, y: f64) -> f64 {
        self.splats
            .iter()
            .filter(|s| s.role == role)
            .map(|s| s.eval(x, y))
            .sum()
    }

    /// Evaluate the total summed field across all splat layers at $(x, y)$.
    pub fn evaluate_total_field(&self, x: f64, y: f64) -> f64 {
        self.splats.iter().map(|s| s.eval(x, y)).sum()
    }

    /// Adaptively remesh all splats in the scene whose aspect ratio exceeds
    /// `max_aspect_ratio`, preserving total $L^1$ weight, center of mass, and
    /// second-moment variance along elongated Anosov or OPA-squeezed axes.
    pub fn adaptive_remesh(&self, max_aspect_ratio: f64) -> Self {
        let remeshed = self
            .splats
            .iter()
            .flat_map(|s| s.split_if_anisotropic(max_aspect_ratio))
            .collect();
        Self { splats: remeshed }
    }
}

// ============================================================================
// C-ABI WebAssembly (`wasm32-unknown-unknown`) & Native FFI Exports
// ============================================================================

/// Compute anomalous perihelion precession in arcseconds per Julian century.
#[unsafe(no_mangle)]
pub extern "C" fn signals_orbital_precession_arcsec_per_century(
    semi_major_axis_au: f64,
    eccentricity: f64,
    orbital_period_days: f64,
    central_horizon_radius_km: f64,
) -> f64 {
    let params = PlanetaryOrbitParams {
        semi_major_axis_au,
        eccentricity,
        orbital_period_days,
        central_horizon_radius_km,
        newtonian_nbody_arcsec_per_century: 0.0,
    };
    if params.validate().is_err() {
        return f64::NAN;
    }
    params.anomalous_precession_arcsec_per_century()
}

/// Evaluate the precessing polar conic radius $r(\varphi; \eta_{\mathrm{prec}})$ in AU.
#[unsafe(no_mangle)]
pub extern "C" fn signals_orbital_precessing_radius(
    semi_major_axis_au: f64,
    eccentricity: f64,
    eta_precession: f64,
    phi: f64,
) -> f64 {
    let params = PlanetaryOrbitParams {
        semi_major_axis_au,
        eccentricity,
        orbital_period_days: 1.0,
        central_horizon_radius_km: SOLAR_HORIZON_RADIUS_KM,
        newtonian_nbody_arcsec_per_century: 0.0,
    };
    if params.validate().is_err() {
        return f64::NAN;
    }
    params.precessing_radius_au(Some(eta_precession), phi)
}

/// Evaluate a normed 2D anisotropic Tensor Gaussian Splat at $(x, y)$.
#[unsafe(no_mangle)]
pub extern "C" fn signals_normed_tensor_splat_eval(
    center_x: f64,
    center_y: f64,
    weight: f64,
    sigma1: f64,
    sigma2: f64,
    orientation_angle: f64,
    x: f64,
    y: f64,
) -> f64 {
    let splat = NormedTensorGaussianSplat2D::body_sink_source(
        center_x,
        center_y,
        weight,
        sigma1,
        sigma2,
        orientation_angle,
    );
    if splat.validate().is_err() {
        return f64::NAN;
    }
    splat.eval(x, y)
}

/// Evaluate a DDF moving-sheath normed Tensor Gaussian Splat ($\sigma_1 = \sigma_0 / \gamma_\varphi(v)$) at $(x, y)$.
#[unsafe(no_mangle)]
pub extern "C" fn signals_ddf_sheath_splat_eval(
    center_x: f64,
    center_y: f64,
    weight: f64,
    sigma0: f64,
    beta: f64,
    velocity_angle: f64,
    x: f64,
    y: f64,
) -> f64 {
    let splat = NormedTensorGaussianSplat2D::from_ddf_moving_sheath(
        center_x,
        center_y,
        weight,
        sigma0,
        beta,
        velocity_angle,
    );
    splat.eval(x, y)
}

/// Evaluate a $Gr_{\mathbb{C}}(2, 4)$ planetary orbital field normed Tensor Gaussian Splat at $(x, y)$.
#[unsafe(no_mangle)]
pub extern "C" fn signals_gr24_orbital_splat_eval(
    center_x: f64,
    center_y: f64,
    weight: f64,
    sigma0: f64,
    eccentricity: f64,
    varpi_angle: f64,
    x: f64,
    y: f64,
) -> f64 {
    let orbit = PlanetaryOrbitParams {
        semi_major_axis_au: 1.0,
        eccentricity: eccentricity.clamp(0.0, 0.999_999),
        orbital_period_days: 365.25,
        central_horizon_radius_km: SOLAR_HORIZON_RADIUS_KM,
        newtonian_nbody_arcsec_per_century: 0.0,
    };
    let splat = NormedTensorGaussianSplat2D::from_gr24_orbit(
        &orbit,
        center_x,
        center_y,
        weight,
        sigma0,
        varpi_angle,
    );
    splat.eval(x, y)
}

/// Return pointer to the embedded WebGL2 orbital splat vertex shader source.
#[unsafe(no_mangle)]
pub extern "C" fn signals_glsl_orbital_splat_vertex_shader_ptr() -> *const u8 {
    GLSL_ORBITAL_SPLAT_VERTEX_SHADER.as_ptr()
}

/// Return byte length of the embedded WebGL2 orbital splat vertex shader source.
#[unsafe(no_mangle)]
pub extern "C" fn signals_glsl_orbital_splat_vertex_shader_len() -> usize {
    GLSL_ORBITAL_SPLAT_VERTEX_SHADER.len()
}

/// Return pointer to the embedded WebGL2 orbital splat fragment shader source.
#[unsafe(no_mangle)]
pub extern "C" fn signals_glsl_orbital_splat_fragment_shader_ptr() -> *const u8 {
    GLSL_ORBITAL_SPLAT_FRAGMENT_SHADER.as_ptr()
}

/// Return byte length of the embedded WebGL2 orbital splat fragment shader source.
#[unsafe(no_mangle)]
pub extern "C" fn signals_glsl_orbital_splat_fragment_shader_len() -> usize {
    GLSL_ORBITAL_SPLAT_FRAGMENT_SHADER.len()
}

#[cfg(test)]
mod tests {
    use super::*;
    use rstest::rstest;

    #[rstest]
    #[case(SolarSystemBody::Mercury, 42.98, 0.02)]
    #[case(SolarSystemBody::Venus, 8.62, 0.03)]
    #[case(SolarSystemBody::Earth, 3.84, 0.02)]
    #[case(SolarSystemBody::Mars, 1.35, 0.02)]
    #[case(SolarSystemBody::Icarus, 10.05, 0.05)]
    fn parametric_solar_system_perihelion_precession_matches_ephemeris(
        #[case] body: SolarSystemBody,
        #[case] expected_arcsec_per_cy: f64,
        #[case] tolerance: f64,
    ) {
        let orbit = PlanetaryOrbitParams::from_solar_system_body(body);
        orbit.validate().unwrap();

        let predicted = orbit.anomalous_precession_arcsec_per_century();
        assert!(
            (predicted - expected_arcsec_per_cy).abs() <= tolerance,
            "{body:?}: predicted {predicted:.4}''/cy vs expected {expected_arcsec_per_cy:.4}''/cy"
        );

        // Verify harmonic mean 1/r_min + 1/r_max = 2/p and turning points
        let r_min = orbit.perihelion_radius_au();
        let r_max = orbit.aphelion_radius_au();
        let p = orbit.semi_latus_rectum_au();
        assert!(((1.0 / r_min + 1.0 / r_max) - (2.0 / p)).abs() < 1e-12);
        let eta = 1e-3;
        assert!((orbit.precessing_radius_au(Some(eta), 0.0) - r_min).abs() < 1e-12);
        assert!(
            (orbit.precessing_radius_au(Some(eta), PI / (1.0 - eta)) - r_max).abs() < 1e-12
        );

        // Verify Gr_C(2,4) orbital precession matrix invariants
        let inv = Gr24OrbitalInvariants::evaluate(&orbit, None);
        assert!(
            (inv.madelung_aphelion_ratio - (r_max / orbit.semi_major_axis_au)).abs() < 1e-12
        );
        assert!(
            (inv.madelung_perihelion_ratio - (r_min / orbit.semi_major_axis_au)).abs() < 1e-12
        );
        assert!((inv.madelung_eccentricity - orbit.eccentricity).abs() < 1e-12);
        assert!((inv.madelung_semi_latus_ratio - (p / orbit.semi_major_axis_au)).abs() < 1e-12);
        assert!(inv.bcj_jacobi_residual_norm_sq < 1e-24);
    }

    #[rstest]
    #[case(0.0, 1.0, 1.0)]
    #[case(0.6, 0.8, 1.25)]
    #[case(0.8, 0.6, 1.0 / 0.6)]
    fn parametric_ddf_and_gr24_normed_tensor_splat_invariants(
        #[case] beta_or_e: f64,
        #[case] expected_vis: f64,
        #[case] expected_jamming: f64,
    ) {
        let sigma0 = 2.0;
        let weight = 5.0;
        let ddf_splat = NormedTensorGaussianSplat2D::from_ddf_moving_sheath(
            1.0, -0.5, weight, sigma0, beta_or_e, 0.35,
        );
        ddf_splat.validate().unwrap();
        assert!((ddf_splat.cov_det() - sigma0.powi(4) * expected_vis * expected_vis).abs() < 1e-12);
        let expected_norm = expected_jamming / (2.0 * PI * sigma0 * sigma0);
        assert!((ddf_splat.norm_factor() - expected_norm).abs() < 1e-12);
        assert!((ddf_splat.eval(1.0, -0.5) - weight * expected_norm).abs() < 1e-12);
        assert!(ddf_splat.eval(1.4, 0.2) <= ddf_splat.eval(1.0, -0.5));

        let orbit = PlanetaryOrbitParams {
            semi_major_axis_au: 2.0,
            eccentricity: beta_or_e,
            orbital_period_days: 365.25,
            central_horizon_radius_km: SOLAR_HORIZON_RADIUS_KM,
            newtonian_nbody_arcsec_per_century: 0.0,
        };
        let gr24_splat =
            NormedTensorGaussianSplat2D::from_gr24_orbit(&orbit, 0.0, 0.0, weight, sigma0, 0.7);
        assert!((gr24_splat.cov_trace() - 2.0 * sigma0 * sigma0).abs() < 1e-12);
        assert!(
            (gr24_splat.cov_det()
                - sigma0.powi(4) * (orbit.semi_latus_rectum_au() / orbit.semi_major_axis_au))
                .abs()
                < 1e-12
        );

        // Verify core Bohm quantum potential Q_core = (hbar^2 / (4 m sigma0^2)) * (gamma_phi^2 + 1)
        let q_core = ddf_splat.core_bohm_potential(1.0, 1.0);
        let expected_q = (1.0 / (4.0 * 1.0 * sigma0 * sigma0))
            * (expected_jamming * expected_jamming + 1.0);
        assert!((q_core - expected_q).abs() < 1e-12);

        // Verify complex Gr_C(2,4) twistor splat intensity matches G(x,y) * |Delta_02^C Delta_13^C|^2
        let m_c = orbit.gr24_precession_matrix(Some(0.42));
        let crossing =
            two_row_minor_complex(&m_c, 0, 2).mul(two_row_minor_complex(&m_c, 1, 3));
        let i_tw = gr24_splat.complex_twistor_intensity(&m_c, 0.25, -0.15);
        assert!((i_tw - gr24_splat.eval(0.25, -0.15) * crossing.norm_sq()).abs() < 1e-12);
        // Dark-fringe twistor configuration (z1 = 1, z2 = -1 => w_A + w_B = 0) gives zero splat intensity
        let m_dark = complex_gr24_channel_matrix(
            Complex64::new(1.0, 0.0),
            Complex64::new(-1.0, 0.0),
        );
        assert!(gr24_splat.complex_twistor_intensity(&m_dark, 0.0, 0.0).abs() < 1e-12);

        // Verify precision matrix Sigma * Sigma^{-1} = I_2 and Madelung Quantum Pressure Tensor identities
        let cov = ddf_splat.covariance_matrix_2x2();
        let prec = ddf_splat.precision_matrix_2x2();
        let prod_00 = cov[0][0] * prec[0][0] + cov[0][1] * prec[1][0];
        let prod_01 = cov[0][0] * prec[0][1] + cov[0][1] * prec[1][1];
        let prod_11 = cov[1][0] * prec[0][1] + cov[1][1] * prec[1][1];
        assert!((prod_00 - 1.0).abs() < 1e-12);
        assert!(prod_01.abs() < 1e-12);
        assert!((prod_11 - 1.0).abs() < 1e-12);

        let qp_tr = ddf_splat.quantum_pressure_trace(1.0, 1.0, 0.3, -0.2);
        let qp_det = ddf_splat.quantum_pressure_det(1.0, 1.0, 0.3, -0.2);
        let g_xy = ddf_splat.eval(0.3, -0.2);
        assert!((qp_tr - q_core * g_xy).abs() < 1e-12);
        let expected_qp_det = (0.25_f64).powi(2) * (g_xy * g_xy / ddf_splat.cov_det());
        assert!((qp_det - expected_qp_det).abs() < 1e-12);
        let pi_11 = ddf_splat.quantum_pressure_principal1(1.0, 1.0, 0.3, -0.2);
        let pi_22 = ddf_splat.quantum_pressure_principal2(1.0, 1.0, 0.3, -0.2);
        assert!((pi_11 - expected_jamming * expected_jamming * pi_22).abs() < 1e-12);
    }

    #[test]
    fn symplectic_verlet_and_nbody_gr2n_potential_preserve_invariants() {
        let (direct_pot, gr2n_pot) = nbody_bernoulli_potential_gr2n(
            2.0,
            &[10.0, 3.0, 1.5],
            &[1.0, 2.0, 3.0],
            &[0.1, 0.7, -0.4],
        );
        assert!((direct_pot - gr2n_pot).abs() < 1e-12);

        let mut state = RelativisticOrbitState {
            position: [0.3075, 0.0],
            velocity: [0.0, 1.60],
            gm_central: 1.0,
            c_speed: 100.0,
        };
        let h0 = state.specific_angular_momentum();
        let e0 = state.specific_mechanical_energy();
        for _ in 0..200 {
            state.step_velocity_verlet(1e-4);
        }
        let h1 = state.specific_angular_momentum();
        let e1 = state.specific_mechanical_energy();
        assert!((h1 - h0).abs() < 1e-9);
        assert!((e1 - e0).abs() < 1e-6);

        // Verify adaptive splat splitting preserves L^1 weight, center of mass, and major-axis variance
        let elongated = NormedTensorGaussianSplat2D {
            center_x: 1.0,
            center_y: -2.0,
            weight: 4.0,
            sigma1: 8.0,
            sigma2: 1.0,
            orientation_angle: 0.4,
            role: SplatRole::Gr24OrbitalField,
        };
        assert!((elongated.aspect_ratio() - 8.0).abs() < 1e-12);
        let children = elongated.split_if_anisotropic(3.0);
        assert_eq!(children.len(), 2);
        let w_sum = children[0].weight + children[1].weight;
        assert!((w_sum - elongated.weight).abs() < 1e-12);
        let cx_mean = 0.5 * (children[0].center_x + children[1].center_x);
        let cy_mean = 0.5 * (children[0].center_y + children[1].center_y);
        assert!((cx_mean - elongated.center_x).abs() < 1e-12);
        assert!((cy_mean - elongated.center_y).abs() < 1e-12);
        let dx = children[1].center_x - elongated.center_x;
        let dy = children[1].center_y - elongated.center_y;
        let delta_sq = dx * dx + dy * dy;
        let total_major_var = children[0].sigma1 * children[0].sigma1 + delta_sq;
        assert!((total_major_var - elongated.sigma1 * elongated.sigma1).abs() < 1e-11);
    }

    #[test]
    fn insta_snapshot_solar_system_precession_and_splat_scene() {
        let bodies = [
            SolarSystemBody::Mercury,
            SolarSystemBody::Venus,
            SolarSystemBody::Earth,
            SolarSystemBody::Mars,
            SolarSystemBody::Icarus,
        ];
        let summary: Vec<String> = bodies
            .into_iter()
            .map(|b| {
                let p = PlanetaryOrbitParams::from_solar_system_body(b);
                let inv = Gr24OrbitalInvariants::evaluate(&p, None);
                format!(
                    "{b:?}: p={:.6} AU, Gr24(p/a)={:.6}, rel={:.2}''/cy, tot={:.2}''/cy",
                    p.semi_latus_rectum_au(),
                    inv.madelung_semi_latus_ratio,
                    p.anomalous_precession_arcsec_per_century(),
                    p.total_precession_arcsec_per_century(),
                )
            })
            .collect();

        let scene = OrbitalSplatScene::canonical_solar_system_scene();
        let scene_summary = format!(
            "splats={}, total_weight={:.2}, origin_sink={:.4}, origin_gr24={:.4}, merc_ddf={:.4}",
            scene.splats.len(),
            scene.total_normed_weight(),
            scene.evaluate_field_by_role(SplatRole::BodySinkSource, 0.0, 0.0),
            scene.evaluate_field_by_role(SplatRole::Gr24OrbitalField, 0.0, 0.0),
            scene.evaluate_field_by_role(
                SplatRole::DdfMovingSheathField,
                PlanetaryOrbitParams::from_solar_system_body(SolarSystemBody::Mercury)
                    .perihelion_radius_au(),
                0.0
            ),
        );

        insta::assert_debug_snapshot!(
            "solar_system_precession_and_normed_splat_scene",
            (summary, scene_summary)
        );
    }
}
