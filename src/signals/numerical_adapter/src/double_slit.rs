//! Multi-slit ($N > 0$) and double-slit ($N = 2$) wave superposition models,
//! complex $Gr_{\mathbb{C}}(2, 4)$ Plücker channel evaluation, WASM C-ABI exports,
//! and WebGL2 GLSL shader sources.
//!
//! This module mirrors the Lean 4 formalizations in `Signals.Geometry`,
//! `Signals.Coherence`, `Signals.Huygens`, `Signals.DDF`, and `Signals.OAM`.

use crate::{ValidationError, require_finite, require_nonnegative, require_positive};
use std::f64::consts::PI;

/// Embedded WebGL2 (`#version 300 es`) vertex shader for multi-slit rendering.
pub const GLSL_DOUBLE_SLIT_VERTEX_SHADER: &str =
    include_str!("shaders/double_slit.vert.glsl");

/// Embedded WebGL2 (`#version 300 es`) fragment shader implementing all
/// double-slit and $N$-slit ($N > 0$) superposition models and error maps.
pub const GLSL_DOUBLE_SLIT_FRAGMENT_SHADER: &str =
    include_str!("shaders/double_slit.frag.glsl");

/// Minimal complex number over `f64` for $Gr_{\mathbb{C}}(2, 4)$ Plücker minors
/// and $\mathbb{C}^4$ twistor channel amplitudes (zero external dependencies for WASM).
#[repr(C)]
#[derive(Clone, Copy, Debug, Default, PartialEq)]
pub struct Complex64 {
    pub re: f64,
    pub im: f64,
}

impl Complex64 {
    #[inline]
    pub const fn new(re: f64, im: f64) -> Self {
        Self { re, im }
    }

    #[inline]
    pub fn from_polar(r: f64, theta: f64) -> Self {
        Self {
            re: r * theta.cos(),
            im: r * theta.sin(),
        }
    }

    #[inline]
    pub fn conj(self) -> Self {
        Self {
            re: self.re,
            im: -self.im,
        }
    }

    #[inline]
    pub fn norm_sq(self) -> f64 {
        self.re * self.re + self.im * self.im
    }

    #[inline]
    pub fn add(self, other: Self) -> Self {
        Self {
            re: self.re + other.re,
            im: self.im + other.im,
        }
    }

    #[inline]
    pub fn sub(self, other: Self) -> Self {
        Self {
            re: self.re - other.re,
            im: self.im - other.im,
        }
    }

    #[inline]
    pub fn mul(self, other: Self) -> Self {
        Self {
            re: self.re * other.re - self.im * other.im,
            im: self.re * other.im + self.im * other.re,
        }
    }
}

/// Enumeration of the double-slit / multi-slit ($N > 0$) superposition models.
#[repr(i32)]
#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum SlitModelKind {
    /// 1. Coherent Fraunhofer $N$-slit reference ($I_{\mathrm{F}}^{(N)}$).
    Fraunhofer = 0,
    /// 2. Huygens–Steiner parallel-axis barycentric coherence ($I_{\mathrm{HS}}^{(N)}$, Qian & Izadi 2023).
    HuygensSteiner = 1,
    /// 3a. Real $Gr(2, 4)$ Plücker channel model with barycentric shift $d_{\mathrm{bary}}$.
    Gr24RealPlucker = 2,
    /// 3b. Complex $Gr_{\mathbb{C}}(2, 4)$ twistor crossing-minor evaluator $|\Delta_{02}^{\mathbb{C}}\Delta_{13}^{\mathbb{C}}|^2$.
    Gr24ComplexTwistor = 3,
    /// 4. De Broglie–Bohm / Madelung Pilot-Wave hydrodynamic model ($I_{\mathrm{PW}}^{(N)}$).
    PilotWave = 4,
    /// 5. Wigner phase-space marginal model ($I_{\mathrm{Wigner}}^{(N)}$).
    Wigner = 5,
    /// 6. Real positive Grassmannian $Gr_{\ge 0}(2, 4)$ unphased crossing-minor proxy ($\mathcal{V} = 0$).
    Gr24Unphased = 6,
}

impl SlitModelKind {
    pub fn from_code(code: i32) -> Option<Self> {
        match code {
            0 => Some(Self::Fraunhofer),
            1 => Some(Self::HuygensSteiner),
            2 => Some(Self::Gr24RealPlucker),
            3 => Some(Self::Gr24ComplexTwistor),
            4 => Some(Self::PilotWave),
            5 => Some(Self::Wigner),
            6 => Some(Self::Gr24Unphased),
            _ => None,
        }
    }
}

/// Complete physical and geometric parameter set for $N$-slit ($N > 0$) and OAM interference.
#[repr(C)]
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct MultiSlitParams {
    /// Number of slits $N > 0$ (`num_slits >= 1`).
    pub num_slits: u32,
    /// Single-slit reference intensity scale $I_0 > 0$.
    pub single_slit_scale: f64,
    /// Rectangular slit width $a > 0$ (along $x$).
    pub slit_width: f64,
    /// Rectangular slit height $b > 0$ (along $y$).
    pub slit_height: f64,
    /// Center-to-center distance $d > 0$ between adjacent slits.
    pub slit_separation: f64,
    /// Optical wavelength $\lambda > 0$.
    pub wavelength: f64,
    /// Propagation distance $L > 0$ from aperture plane to detector screen.
    pub screen_distance: f64,
    /// Huygens–Steiner / Plücker barycentric parallel-axis shift $d_{\mathrm{bary}} \in [-1, 1]$.
    pub barycentric_shift: f64,
    /// Mutual coherence / fringe visibility $\mathcal{V} \in [0, 1]$.
    pub visibility: f64,
    /// De Broglie–Bohm non-equilibrium density offset $\delta_{\mathrm{neq}}$.
    pub non_equilibrium_residual: f64,
    /// Wigner spatial phase-space decoherence rate $\gamma_{\mathrm{dec}} \ge 0$.
    pub decoherence_rate: f64,
    /// Wigner rotational OAM phase-space decoherence rate $\gamma_{\mathrm{OAM}} \ge 0$.
    pub oam_decoherence_rate: f64,
    /// Differential OAM topological charge $\Delta\ell \in \mathbb{Z}$ between adjacent slits.
    pub delta_oam: i32,
    /// Azimuthal angle $\phi \in \mathbb{R}$ (radians).
    pub azimuth_phi: f64,
}

impl MultiSlitParams {
    /// Construct a coherent symmetric double-slit ($N = 2$) configuration matching
    /// the Lean `SignalsTests.lean` benchmark ($I_0 = 3, a = 2, b = 4, d = 6, \lambda = 1, L = 5$).
    pub fn canonical_double_slit() -> Self {
        Self {
            num_slits: 2,
            single_slit_scale: 3.0,
            slit_width: 2.0,
            slit_height: 4.0,
            slit_separation: 6.0,
            wavelength: 1.0,
            screen_distance: 5.0,
            barycentric_shift: 0.0,
            visibility: 1.0,
            non_equilibrium_residual: 0.0,
            decoherence_rate: 0.0,
            oam_decoherence_rate: 0.0,
            delta_oam: 0,
            azimuth_phi: 0.0,
        }
    }

    /// Update the number of slits ($N > 0$), slit width $a$, and distance between slits $d$.
    pub fn with_geometry(mut self, num_slits: u32, slit_width: f64, slit_separation: f64) -> Self {
        self.num_slits = num_slits;
        self.slit_width = slit_width;
        self.slit_separation = slit_separation;
        self
    }

    /// Set the Qian–Izadi / Plücker barycentric parallel-axis shift $d_{\mathrm{bary}} \in [-1, 1]$
    /// and synchronize $\mathcal{V} = \sqrt{1 - d_{\mathrm{bary}}^2}$.
    pub fn with_barycentric_shift(mut self, d_bary: f64) -> Self {
        let clamped = d_bary.clamp(-1.0, 1.0);
        self.barycentric_shift = clamped;
        self.visibility = (1.0 - clamped * clamped).max(0.0).sqrt();
        self
    }

    /// Validate that $N > 0$ and all optical/geometric scales are positive and finite.
    pub fn validate(&self) -> Result<(), ValidationError> {
        if self.num_slits == 0 {
            return Err(ValidationError::NonPositive("num_slits"));
        }
        require_positive("single_slit_scale", self.single_slit_scale)?;
        require_positive("slit_width", self.slit_width)?;
        require_positive("slit_height", self.slit_height)?;
        require_positive("slit_separation", self.slit_separation)?;
        require_positive("wavelength", self.wavelength)?;
        require_positive("screen_distance", self.screen_distance)?;
        require_finite("barycentric_shift", self.barycentric_shift)?;
        if !(-1.0..=1.0).contains(&self.barycentric_shift) {
            return Err(ValidationError::ResidualTooLarge("barycentric_shift out of [-1, 1]"));
        }
        require_nonnegative("visibility", self.visibility)?;
        if self.visibility > 1.0 {
            return Err(ValidationError::ResidualTooLarge("visibility > 1"));
        }
        require_finite("non_equilibrium_residual", self.non_equilibrium_residual)?;
        require_nonnegative("decoherence_rate", self.decoherence_rate)?;
        require_nonnegative("oam_decoherence_rate", self.oam_decoherence_rate)?;
        require_finite("azimuth_phi", self.azimuth_phi)?;
        Ok(())
    }

    /// Adjacent-slit optical phase half-step $\beta = \frac{\pi d x}{\lambda L} + \frac{\Delta\ell\,\phi}{2}$.
    #[inline]
    pub fn phase_half_step(&self, x: f64) -> f64 {
        (PI * self.slit_separation * x) / (self.wavelength * self.screen_distance)
            + 0.5 * (self.delta_oam as f64) * self.azimuth_phi
    }

    /// Coherent $N$-slit on-axis Fraunhofer peak intensity $N^2 I_0$.
    #[inline]
    pub fn coherent_on_axis_peak(&self) -> f64 {
        let n = f64::from(self.num_slits);
        n * n * self.single_slit_scale
    }
}

/// Unnormalized sinc function $\operatorname{sinc}(u) = \sin(u)/u$ with $\operatorname{sinc}(0) = 1$,
/// matching `Signals.Huygens.unnormalizedSinc`.
#[inline]
pub fn unnormalized_sinc(u: f64) -> f64 {
    if u == 0.0 {
        1.0
    } else if u.abs() < 1e-8 {
        1.0 - (u * u) / 6.0 + (u * u * u * u) / 120.0
    } else {
        u.sin() / u
    }
}

/// Single-slit 2D rectangular Fraunhofer diffraction envelope
/// $E_{\mathrm{slit}}(x, y) = \operatorname{sinc}^2(\pi a x / (\lambda L))\,\operatorname{sinc}^2(\pi b y / (\lambda L))$,
/// matching `Signals.Huygens.rectangularSlitEnvelope`.
#[inline]
pub fn rectangular_slit_envelope(
    slit_width: f64,
    slit_height: f64,
    wavelength: f64,
    screen_distance: f64,
    x: f64,
    y: f64,
) -> f64 {
    let denom = wavelength * screen_distance;
    let sx = unnormalized_sinc(PI * slit_width * x / denom);
    let sy = unnormalized_sinc(PI * slit_height * y / denom);
    (sx * sx) * (sy * sy)
}

/// $2 \times 2$ minor $\Delta_{c_0 c_1}(M)$ of a real $2 \times 4$ Grassmannian matrix,
/// matching `Signals.Geometry.twoRowMinor`.
#[inline]
pub fn two_row_minor_real(matrix: &[[f64; 4]; 2], c0: usize, c1: usize) -> f64 {
    matrix[0][c0] * matrix[1][c1] - matrix[0][c1] * matrix[1][c0]
}

/// $2 \times 2$ minor $\Delta_{c_0 c_1}^{\mathbb{C}}(M_{\mathbb{C}})$ of a complex $2 \times 4$
/// Grassmannian matrix, matching `Signals.Geometry.complexTwoRowMinor`.
#[inline]
pub fn two_row_minor_complex(matrix: &[[Complex64; 4]; 2], c0: usize, c1: usize) -> Complex64 {
    matrix[0][c0]
        .mul(matrix[1][c1])
        .sub(matrix[0][c1].mul(matrix[1][c0]))
}

/// Three-term Plücker identity residual $\Delta_{01}\Delta_{23} - \Delta_{02}\Delta_{13} + \Delta_{03}\Delta_{12}$
/// on a real $2 \times 4$ matrix (identically $0$ by `Signals.Geometry.twoRowMinor_pluecker`).
#[inline]
pub fn plucker_three_term_residual_real(matrix: &[[f64; 4]; 2]) -> f64 {
    two_row_minor_real(matrix, 0, 1) * two_row_minor_real(matrix, 2, 3)
        - two_row_minor_real(matrix, 0, 2) * two_row_minor_real(matrix, 1, 3)
        + two_row_minor_real(matrix, 0, 3) * two_row_minor_real(matrix, 1, 2)
}

/// Three-term Plücker identity residual on a complex $2 \times 4$ matrix
/// (identically $0$ by `Signals.Geometry.complexTwoRowMinor_pluecker`).
#[inline]
pub fn plucker_three_term_residual_complex(matrix: &[[Complex64; 4]; 2]) -> Complex64 {
    let t1 = two_row_minor_complex(matrix, 0, 1).mul(two_row_minor_complex(matrix, 2, 3));
    let t2 = two_row_minor_complex(matrix, 0, 2).mul(two_row_minor_complex(matrix, 1, 3));
    let t3 = two_row_minor_complex(matrix, 0, 3).mul(two_row_minor_complex(matrix, 1, 2));
    t1.sub(t2).add(t3)
}

/// Plücker barycentric parallel-axis shift $d_{\mathrm{bary}}(M) = (\Delta_{01}\Delta_{23} - \Delta_{03}\Delta_{12}) / 2$,
/// matching `Signals.Geometry.gr24BarycentricShift`.
#[inline]
pub fn gr24_barycentric_shift(matrix: &[[f64; 4]; 2]) -> f64 {
    let w_a = two_row_minor_real(matrix, 0, 1) * two_row_minor_real(matrix, 2, 3);
    let w_b = two_row_minor_real(matrix, 0, 3) * two_row_minor_real(matrix, 1, 2);
    0.5 * (w_a - w_b)
}

/// Universal Pythagorean Plücker–Steiner residual
/// $d_{\mathrm{bary}}(M)^2 + w_A(M) w_B(M) - (\Delta_{02}(M)\Delta_{13}(M)/2)^2$
/// (identically $0$ by `Signals.Geometry.gr24_plucker_pythagorean_identity`).
#[inline]
pub fn gr24_pythagorean_residual(matrix: &[[f64; 4]; 2]) -> f64 {
    let d_bary = gr24_barycentric_shift(matrix);
    let w_a = two_row_minor_real(matrix, 0, 1) * two_row_minor_real(matrix, 2, 3);
    let w_b = two_row_minor_real(matrix, 0, 3) * two_row_minor_real(matrix, 1, 2);
    let w_cross_half = 0.5 * two_row_minor_real(matrix, 0, 2) * two_row_minor_real(matrix, 1, 3);
    (d_bary * d_bary + w_a * w_b) - (w_cross_half * w_cross_half)
}

/// Projectively normalized Plücker barycentric shift
/// $\widehat{d}_{\mathrm{bary}}(M) = (\Delta_{01}\Delta_{23} - \Delta_{03}\Delta_{12}) / (\Delta_{02}\Delta_{13})$,
/// matching `Signals.Geometry.gr24ProjectiveBarycentricShift` (invariant under arbitrary $GL(2, \mathbb{R})$
/// and non-symplectic compressive jamming).
#[inline]
pub fn gr24_projective_barycentric_shift(matrix: &[[f64; 4]; 2]) -> f64 {
    let w_a = two_row_minor_real(matrix, 0, 1) * two_row_minor_real(matrix, 2, 3);
    let w_b = two_row_minor_real(matrix, 0, 3) * two_row_minor_real(matrix, 1, 2);
    let w_cross = two_row_minor_real(matrix, 0, 2) * two_row_minor_real(matrix, 1, 3);
    (w_a - w_b) / w_cross
}

/// Projectively normalized Plücker visibility squared
/// $\widehat{\mathcal{V}}_{Gr(2,4)}(M)^2 = 4 \Delta_{01}\Delta_{23}\Delta_{03}\Delta_{12} / (\Delta_{02}\Delta_{13})^2$,
/// matching `Signals.Geometry.gr24ProjectiveVisibilitySq`.
#[inline]
pub fn gr24_projective_visibility_sq(matrix: &[[f64; 4]; 2]) -> f64 {
    let w_a = two_row_minor_real(matrix, 0, 1) * two_row_minor_real(matrix, 2, 3);
    let w_b = two_row_minor_real(matrix, 0, 3) * two_row_minor_real(matrix, 1, 2);
    let w_cross = two_row_minor_real(matrix, 0, 2) * two_row_minor_real(matrix, 1, 3);
    (4.0 * w_a * w_b) / (w_cross * w_cross)
}

/// Inverse DDF moving-sheath parameter recovery from the on-axis optical relative
/// predictive error $\varepsilon = (1 - \mathcal{V})/2 \in [0, 1/2)$, matching
/// `Signals.DDF.MovingSheath.inverse_recovery_from_relative_error` and
/// `Signals.DDF.MovingSheath.ddf_critique3_solved_substrate_parameter_recovery`.
#[repr(C)]
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct DdfSheathRecovery {
    pub relative_error: f64,
    pub visibility: f64,
    pub jamming_factor: f64,
    pub beta_sq: f64,
}

impl DdfSheathRecovery {
    /// Recover $(\mathcal{V}, \gamma_\varphi, \beta^2)$ from $\varepsilon \in [0, 0.5)$.
    pub fn from_relative_error(eps: f64) -> Option<Self> {
        if !eps.is_finite() || !(0.0..0.5).contains(&eps) {
            return None;
        }
        let visibility = 1.0 - 2.0 * eps;
        let jamming_factor = 1.0 / visibility;
        let beta_sq = 4.0 * eps * (1.0 - eps);
        Some(Self {
            relative_error: eps,
            visibility,
            jamming_factor,
            beta_sq,
        })
    }

    /// Recover the DDF dispersed-phase compressibility-density product
    /// $\varrho_{\max}^\varphi j_{\min}^\varphi = 4\varepsilon(1 - \varepsilon) / v^2$
    /// for a known nonzero sheath velocity $v \neq 0$.
    pub fn recover_substrate_product(&self, velocity: f64) -> Option<f64> {
        if !velocity.is_finite() || velocity == 0.0 {
            return None;
        }
        Some(self.beta_sq / (velocity * velocity))
    }
}

/// Construct the canonical $Gr_{\mathbb{C}}(2, 4)$–DDF sheath and vortex twistor matrix
/// $M_{\mathbb{C}}^{\mathrm{DDF}}(s)$ from reduced sheath speed $\beta = v/c \in [0, 1)$
/// and optical/OAM parameters, matching `Signals.DDF.MovingSheath.gr24TwistorMatrix`.
pub fn ddf_gr24_twistor_matrix(
    beta: f64,
    params: &MultiSlitParams,
    x: f64,
) -> [[Complex64; 4]; 2] {
    let clamped_beta = beta.clamp(-1.0, 1.0);
    let theta = params.phase_half_step(x);
    let a = (1.0 + clamped_beta).max(0.0).sqrt();
    let b = (1.0 - clamped_beta).max(0.0).sqrt();
    let z1 = Complex64::from_polar(a, theta);
    let z2 = Complex64::from_polar(b, -theta);
    complex_gr24_channel_matrix(z1, z2)
}

/// Construct the $2 \times (N + 2)$ complex Grassmannian channel matrix
/// $M_{\mathbb{C}}^{(N)}(z) \in \mathbb{C}^{2 \times (N + 2)}$ for $N$ slit amplitudes `z`,
/// matching `Signals.Geometry.complexGr2NChannelMatrix`.
pub fn complex_gr2n_channel_matrix(z: &[Complex64]) -> [Vec<Complex64>; 2] {
    let total_cols = z.len() + 2;
    let row0 = vec![Complex64::new(1.0, 0.0); total_cols];
    let mut sum = Complex64::new(0.0, 0.0);
    for &amp in z {
        sum = sum.add(amp);
    }
    let mut row1 = Vec::with_capacity(total_cols);
    row1.push(Complex64::new(0.0, 0.0));
    row1.push(sum);
    row1.extend_from_slice(z);
    [row0, row1]
}

/// $2 \times 2$ complex Plücker minor $\Delta_{c_0 c_1}^{\mathbb{C}}$ of a $2 \times (N + 2)$
/// complex Grassmannian matrix.
#[inline]
pub fn two_row_minor_complex_slice(matrix: &[Vec<Complex64>; 2], c0: usize, c1: usize) -> Complex64 {
    matrix[0][c0]
        .mul(matrix[1][c1])
        .sub(matrix[0][c1].mul(matrix[1][c0]))
}

/// Evaluate the $N$-ary complex Grassmannian collector Plücker minor intensity
/// $I_{Gr_{\mathbb{C}}(2, N+2)}(M_{\mathbb{C}}; x, y) = I_0 E_{\mathrm{slit}}(x, y) |\Delta_{0,1}^{\mathbb{C}}(M_{\mathbb{C}})|^2$,
/// matching `Signals.Huygens.complexGr2NCollectorMultiSlit`.
pub fn complex_gr2n_collector_multi_slit(
    matrix: &[Vec<Complex64>; 2],
    params: &MultiSlitParams,
    x: f64,
    y: f64,
) -> f64 {
    let env = rectangular_slit_envelope(
        params.slit_width,
        params.slit_height,
        params.wavelength,
        params.screen_distance,
        x,
        y,
    );
    let collector_minor = two_row_minor_complex_slice(matrix, 0, 1);
    params.single_slit_scale * env * collector_minor.norm_sq()
}

/// Sorkin third-order quantum interference parameter $\kappa_3(z_0, z_1, z_2)$ for a
/// triple-slit ($N = 3$) amplitude configuration, matching
/// `Signals.Geometry.sorkinTripleSlitParameter` (identically $0$ by `sorkinTripleSlitParameter_zero`).
#[inline]
pub fn sorkin_triple_slit_parameter(z0: Complex64, z1: Complex64, z2: Complex64) -> f64 {
    let i012 = z0.add(z1).add(z2).norm_sq();
    let i01 = z0.add(z1).norm_sq();
    let i02 = z0.add(z2).norm_sq();
    let i12 = z1.add(z2).norm_sq();
    let i0 = z0.norm_sq();
    let i1 = z1.norm_sq();
    let i2 = z2.norm_sq();
    i012 - (i01 + i02 + i12) + (i0 + i1 + i2)
}

/// Construct the triple-slit ($N = 3$) $Gr_{\mathbb{C}}(2, 5)$–DDF sheath twistor matrix,
/// matching `Signals.DDF.MovingSheath.gr25TripleSlitTwistorMatrix`.
pub fn ddf_gr25_triple_slit_twistor_matrix(
    beta: f64,
    params: &MultiSlitParams,
    x: f64,
) -> [Vec<Complex64>; 2] {
    let clamped_beta = beta.clamp(-1.0, 1.0);
    let beta_opt = params.phase_half_step(x);
    let a = (1.0 + clamped_beta).max(0.0).sqrt();
    let b = (1.0 - clamped_beta).max(0.0).sqrt();
    let z0 = Complex64::from_polar(a, 2.0 * beta_opt);
    let z1 = Complex64::new(1.0, 0.0);
    let z2 = Complex64::from_polar(b, -2.0 * beta_opt);
    complex_gr2n_channel_matrix(&[z0, z1, z2])
}

/// Canonical $2 \times 4$ complex Grassmannian channel matrix
/// $M_{\mathbb{C}}(z_1, z_2) = \begin{pmatrix} 1 & 1 & 0 & -1 \\ 0 & z_1 & 1 & z_2 \end{pmatrix}$,
/// matching `Signals.Huygens.complexGr24ChannelMatrix`.
#[inline]
pub const fn complex_gr24_channel_matrix(
    z1: Complex64,
    z2: Complex64,
) -> [[Complex64; 4]; 2] {
    [
        [
            Complex64::new(1.0, 0.0),
            Complex64::new(1.0, 0.0),
            Complex64::new(0.0, 0.0),
            Complex64::new(-1.0, 0.0),
        ],
        [
            Complex64::new(0.0, 0.0),
            z1,
            Complex64::new(1.0, 0.0),
            z2,
        ],
    ]
}

/// Multi-slit ($N > 0$) interference factor
/// $\mathcal{G}_N(\mathcal{V}, \beta) = N + 2\mathcal{V}\sum_{0 \le j < k < N}\cos(2(k-j)\beta)$,
/// matching `Signals.Huygens.multiSlitInterferenceFactor`.
pub fn multi_slit_interference_factor(num_slits: u32, visibility: f64, beta: f64) -> f64 {
    let n = num_slits.max(1);
    let mut pair_sum = 0.0;
    for j in 0..n {
        for k in (j + 1)..n {
            let step = f64::from(k - j);
            pair_sum += (2.0 * step * beta).cos();
        }
    }
    f64::from(n) + 2.0 * visibility * pair_sum
}

/// Evaluate the complex $Gr_{\mathbb{C}}(2, 4)$ crossing-minor intensity
/// $I_{Gr_{\mathbb{C}}(2,4)}^{\times}(M_{\mathbb{C}}; x, y) = I_0 E_{\mathrm{slit}}(x, y) |\Delta_{02}^{\mathbb{C}} \Delta_{13}^{\mathbb{C}}|^2$,
/// matching `Signals.Huygens.complexGr24CrossingDoubleSlit`.
pub fn complex_gr24_crossing_double_slit(
    matrix: &[[Complex64; 4]; 2],
    params: &MultiSlitParams,
    x: f64,
    y: f64,
) -> f64 {
    let env = rectangular_slit_envelope(
        params.slit_width,
        params.slit_height,
        params.wavelength,
        params.screen_distance,
        x,
        y,
    );
    let delta_02 = two_row_minor_complex(matrix, 0, 2);
    let delta_13 = two_row_minor_complex(matrix, 1, 3);
    let crossing = delta_02.mul(delta_13);
    params.single_slit_scale * env * crossing.norm_sq()
}

/// Evaluate the intensity $I(x, y)$ of the selected multi-slit ($N > 0$) model.
pub fn evaluate_multi_slit_model(
    model: SlitModelKind,
    params: &MultiSlitParams,
    x: f64,
    y: f64,
) -> f64 {
    let n = params.num_slits.max(1);
    let env = rectangular_slit_envelope(
        params.slit_width,
        params.slit_height,
        params.wavelength,
        params.screen_distance,
        x,
        y,
    );
    let beta = params.phase_half_step(x);
    let d_bary = params.barycentric_shift.clamp(-1.0, 1.0);
    let v_bary = (1.0 - d_bary * d_bary).max(0.0).sqrt();

    match model {
        SlitModelKind::Fraunhofer => {
            params.single_slit_scale * env * multi_slit_interference_factor(n, 1.0, beta)
        }
        SlitModelKind::HuygensSteiner => {
            params.single_slit_scale
                * env
                * multi_slit_interference_factor(n, params.visibility, beta)
        }
        SlitModelKind::Gr24RealPlucker => {
            if n == 2 {
                let real_mat = [
                    [1.0, 1.0, 0.0, -1.0],
                    [0.0, 1.0 + d_bary, 1.0, 1.0 - d_bary],
                ];
                let w_a = two_row_minor_real(&real_mat, 0, 1) * two_row_minor_real(&real_mat, 2, 3);
                let w_b = two_row_minor_real(&real_mat, 0, 3) * two_row_minor_real(&real_mat, 1, 2);
                let w_cross =
                    two_row_minor_real(&real_mat, 0, 2) * two_row_minor_real(&real_mat, 1, 3);
                params.single_slit_scale
                    * env
                    * (w_cross + 2.0 * (w_a * w_b).max(0.0).sqrt() * (2.0 * beta).cos())
            } else {
                params.single_slit_scale * env * multi_slit_interference_factor(n, v_bary, beta)
            }
        }
        SlitModelKind::Gr24ComplexTwistor => {
            if n == 2 {
                let a = (1.0 + d_bary).max(0.0).sqrt();
                let b = (1.0 - d_bary).max(0.0).sqrt();
                let z1 = Complex64::from_polar(a, beta);
                let z2 = Complex64::from_polar(b, -beta);
                let mat = complex_gr24_channel_matrix(z1, z2);
                complex_gr24_crossing_double_slit(&mat, params, x, y)
            } else {
                params.single_slit_scale * env * multi_slit_interference_factor(n, v_bary, beta)
            }
        }
        SlitModelKind::PilotWave => {
            let i_fraun =
                params.single_slit_scale * env * multi_slit_interference_factor(n, 1.0, beta);
            i_fraun + params.non_equilibrium_residual
        }
        SlitModelKind::Wigner => {
            let oam_sq = f64::from(params.delta_oam) * f64::from(params.delta_oam);
            let v_wigner = (-(params.decoherence_rate + params.oam_decoherence_rate * oam_sq)).exp();
            params.single_slit_scale * env * multi_slit_interference_factor(n, v_wigner, beta)
        }
        SlitModelKind::Gr24Unphased => params.single_slit_scale * env * f64::from(n),
    }
}

/// Pointwise relative predictive error $|I_{\mathrm{cand}} - I_{\mathrm{ref}}| / |I_{\mathrm{ref}}|$,
/// matching `Signals.Huygens.relativePredictiveError`.
#[inline]
pub fn relative_predictive_error(candidate: f64, reference: f64) -> f64 {
    if reference == 0.0 {
        0.0
    } else {
        (candidate - reference).abs() / reference.abs()
    }
}

/// Peak-normalized relative error $|I_{\mathrm{cand}} - I_{\mathrm{ref}}| / (N^2 I_0)$,
/// matching `Signals.Huygens.peakNormalizedRelativeError` for $N = 2$.
#[inline]
pub fn peak_normalized_relative_error(
    candidate: f64,
    reference: f64,
    single_slit_scale: f64,
    num_slits: u32,
) -> f64 {
    let n = f64::from(num_slits.max(1));
    let peak = n * n * single_slit_scale;
    if peak == 0.0 {
        0.0
    } else {
        (candidate - reference).abs() / peak.abs()
    }
}

/// Theoretical on-axis ($x = 0, y = 0, \phi = 0$) relative predictive error against the
/// coherent $N$-slit Fraunhofer peak $N^2 I_0$.
pub fn theoretical_on_axis_relative_error(model: SlitModelKind, params: &MultiSlitParams) -> f64 {
    let n = f64::from(params.num_slits.max(1));
    let n_factor = (n - 1.0) / n;
    let d_bary = params.barycentric_shift.clamp(-1.0, 1.0);
    let v_bary = (1.0 - d_bary * d_bary).max(0.0).sqrt();

    match model {
        SlitModelKind::Fraunhofer => 0.0,
        SlitModelKind::HuygensSteiner => n_factor * (1.0 - params.visibility),
        SlitModelKind::Gr24RealPlucker | SlitModelKind::Gr24ComplexTwistor => {
            n_factor * (1.0 - v_bary)
        }
        SlitModelKind::PilotWave => {
            params.non_equilibrium_residual.abs() / (n * n * params.single_slit_scale)
        }
        SlitModelKind::Wigner => {
            let oam_sq = f64::from(params.delta_oam) * f64::from(params.delta_oam);
            let v_wigner = (-(params.decoherence_rate + params.oam_decoherence_rate * oam_sq)).exp();
            n_factor * (1.0 - v_wigner)
        }
        SlitModelKind::Gr24Unphased => n_factor,
    }
}

/// Summary of all models evaluated at a single detector point $(x, y)$.
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct MultiSlitEvaluationReport {
    pub fraunhofer: f64,
    pub huygens_steiner: f64,
    pub gr24_real_plucker: f64,
    pub gr24_complex_twistor: f64,
    pub pilot_wave: f64,
    pub wigner: f64,
    pub gr24_unphased: f64,
}

impl MultiSlitEvaluationReport {
    pub fn evaluate(params: &MultiSlitParams, x: f64, y: f64) -> Self {
        Self {
            fraunhofer: evaluate_multi_slit_model(SlitModelKind::Fraunhofer, params, x, y),
            huygens_steiner: evaluate_multi_slit_model(SlitModelKind::HuygensSteiner, params, x, y),
            gr24_real_plucker: evaluate_multi_slit_model(
                SlitModelKind::Gr24RealPlucker,
                params,
                x,
                y,
            ),
            gr24_complex_twistor: evaluate_multi_slit_model(
                SlitModelKind::Gr24ComplexTwistor,
                params,
                x,
                y,
            ),
            pilot_wave: evaluate_multi_slit_model(SlitModelKind::PilotWave, params, x, y),
            wigner: evaluate_multi_slit_model(SlitModelKind::Wigner, params, x, y),
            gr24_unphased: evaluate_multi_slit_model(SlitModelKind::Gr24Unphased, params, x, y),
        }
    }
}

/// WebGL2 / WASM `f32` uniform buffer layout matching `double_slit.frag.glsl`.
#[repr(C)]
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct GlslUniformBlock {
    pub model_kind: i32,
    pub num_slits: i32,
    pub slit_width: f32,
    pub slit_height: f32,
    pub slit_separation: f32,
    pub wavelength: f32,
    pub screen_distance: f32,
    pub single_slit_scale: f32,
    pub barycentric_shift: f32,
    pub visibility: f32,
    pub non_equilibrium_residual: f32,
    pub decoherence_rate: f32,
    pub oam_decoherence_rate: f32,
    pub delta_oam: i32,
    pub azimuth_phi: f32,
}

impl GlslUniformBlock {
    pub fn from_params(model: SlitModelKind, params: &MultiSlitParams) -> Self {
        Self {
            model_kind: model as i32,
            num_slits: params.num_slits.max(1) as i32,
            slit_width: params.slit_width as f32,
            slit_height: params.slit_height as f32,
            slit_separation: params.slit_separation as f32,
            wavelength: params.wavelength as f32,
            screen_distance: params.screen_distance as f32,
            single_slit_scale: params.single_slit_scale as f32,
            barycentric_shift: params.barycentric_shift as f32,
            visibility: params.visibility as f32,
            non_equilibrium_residual: params.non_equilibrium_residual as f32,
            decoherence_rate: params.decoherence_rate as f32,
            oam_decoherence_rate: params.oam_decoherence_rate as f32,
            delta_oam: params.delta_oam,
            azimuth_phi: params.azimuth_phi as f32,
        }
    }
}

// ============================================================================
// C-ABI WebAssembly (`wasm32-unknown-unknown`) & Native FFI Exports
// ============================================================================

/// Evaluate any of the 7 multi-slit ($N > 0$) models from WASM or C FFI.
#[unsafe(no_mangle)]
pub extern "C" fn signals_multi_slit_intensity(
    model_code: i32,
    num_slits: u32,
    single_slit_scale: f64,
    slit_width: f64,
    slit_height: f64,
    slit_separation: f64,
    wavelength: f64,
    screen_distance: f64,
    barycentric_shift: f64,
    visibility: f64,
    non_equilibrium_residual: f64,
    decoherence_rate: f64,
    oam_decoherence_rate: f64,
    delta_oam: i32,
    azimuth_phi: f64,
    x: f64,
    y: f64,
) -> f64 {
    let Some(model) = SlitModelKind::from_code(model_code) else {
        return f64::NAN;
    };
    if num_slits == 0 {
        return f64::NAN;
    }
    let params = MultiSlitParams {
        num_slits,
        single_slit_scale,
        slit_width,
        slit_height,
        slit_separation,
        wavelength,
        screen_distance,
        barycentric_shift,
        visibility,
        non_equilibrium_residual,
        decoherence_rate,
        oam_decoherence_rate,
        delta_oam,
        azimuth_phi,
    };
    evaluate_multi_slit_model(model, &params, x, y)
}

/// Compute the pointwise relative predictive error of `model_code` against the
/// coherent $N$-slit Fraunhofer reference ($N > 0$).
#[unsafe(no_mangle)]
pub extern "C" fn signals_multi_slit_relative_error(
    model_code: i32,
    num_slits: u32,
    single_slit_scale: f64,
    slit_width: f64,
    slit_height: f64,
    slit_separation: f64,
    wavelength: f64,
    screen_distance: f64,
    barycentric_shift: f64,
    visibility: f64,
    non_equilibrium_residual: f64,
    decoherence_rate: f64,
    oam_decoherence_rate: f64,
    delta_oam: i32,
    azimuth_phi: f64,
    x: f64,
    y: f64,
) -> f64 {
    let candidate = signals_multi_slit_intensity(
        model_code,
        num_slits,
        single_slit_scale,
        slit_width,
        slit_height,
        slit_separation,
        wavelength,
        screen_distance,
        barycentric_shift,
        visibility,
        non_equilibrium_residual,
        decoherence_rate,
        oam_decoherence_rate,
        delta_oam,
        azimuth_phi,
        x,
        y,
    );
    let reference = signals_multi_slit_intensity(
        SlitModelKind::Fraunhofer as i32,
        num_slits,
        single_slit_scale,
        slit_width,
        slit_height,
        slit_separation,
        wavelength,
        screen_distance,
        barycentric_shift,
        1.0,
        0.0,
        0.0,
        0.0,
        delta_oam,
        azimuth_phi,
        x,
        y,
    );
    relative_predictive_error(candidate, reference)
}

/// Return pointer to the embedded WebGL2 GLSL vertex shader source (`double_slit.vert.glsl`).
#[unsafe(no_mangle)]
pub extern "C" fn signals_glsl_vertex_shader_ptr() -> *const u8 {
    GLSL_DOUBLE_SLIT_VERTEX_SHADER.as_ptr()
}

/// Return byte length of the embedded WebGL2 GLSL vertex shader source.
#[unsafe(no_mangle)]
pub extern "C" fn signals_glsl_vertex_shader_len() -> usize {
    GLSL_DOUBLE_SLIT_VERTEX_SHADER.len()
}

/// Return pointer to the embedded WebGL2 GLSL fragment shader source (`double_slit.frag.glsl`).
#[unsafe(no_mangle)]
pub extern "C" fn signals_glsl_fragment_shader_ptr() -> *const u8 {
    GLSL_DOUBLE_SLIT_FRAGMENT_SHADER.as_ptr()
}

/// Return byte length of the embedded WebGL2 GLSL fragment shader source.
#[unsafe(no_mangle)]
pub extern "C" fn signals_glsl_fragment_shader_len() -> usize {
    GLSL_DOUBLE_SLIT_FRAGMENT_SHADER.len()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn rejects_zero_slits() {
        let mut params = MultiSlitParams::canonical_double_slit();
        params.num_slits = 0;
        assert_eq!(
            params.validate(),
            Err(ValidationError::NonPositive("num_slits"))
        );
        assert!(
            signals_multi_slit_intensity(
                0, 0, 3.0, 2.0, 4.0, 6.0, 1.0, 5.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.0
            )
            .is_nan()
        );
    }

    #[test]
    fn single_slit_and_multi_slit_reductions_match_lean_theorems() {
        let p1 = MultiSlitParams::canonical_double_slit().with_geometry(1, 2.0, 6.0);
        p1.validate().unwrap();
        // N = 1: huygensSteinerMultiSlit_one_slit
        for &(x, y) in &[(0.0, 0.0), (0.15, -0.25), (0.5, 0.3)] {
            let env = rectangular_slit_envelope(2.0, 4.0, 1.0, 5.0, x, y);
            let hs1 = evaluate_multi_slit_model(SlitModelKind::HuygensSteiner, &p1, x, y);
            let f1 = evaluate_multi_slit_model(SlitModelKind::Fraunhofer, &p1, x, y);
            assert!((hs1 - 3.0 * env).abs() < 1e-12);
            assert!((f1 - 3.0 * env).abs() < 1e-12);
        }

        // N = 3, 4, 5: coherent on-axis peak is N^2 * I_0
        for n in 1..=5 {
            let pn = MultiSlitParams::canonical_double_slit().with_geometry(n, 2.0, 6.0);
            let on_axis = evaluate_multi_slit_model(SlitModelKind::Fraunhofer, &pn, 0.0, 0.0);
            assert!((on_axis - pn.coherent_on_axis_peak()).abs() < 1e-12);
        }
    }

    #[test]
    fn complex_gr24_eliminates_50_percent_unphased_error_and_matches_huygens_steiner() {
        let params = MultiSlitParams::canonical_double_slit();
        // Unphased Gr_>=0(2,4) crossing-minor proxy has 50% (1/2) on-axis relative error
        let i_unphased = evaluate_multi_slit_model(SlitModelKind::Gr24Unphased, &params, 0.0, 0.0);
        let i_fraun = evaluate_multi_slit_model(SlitModelKind::Fraunhofer, &params, 0.0, 0.0);
        assert!((relative_predictive_error(i_unphased, i_fraun) - 0.5).abs() < 1e-12);

        // Complex Gr_C(2,4) with d_bary = 0 has zero relative error everywhere
        for &(x, y) in &[(0.0, 0.0), (0.12, -0.18), (5.0 / 12.0, 0.0)] {
            let report = MultiSlitEvaluationReport::evaluate(&params, x, y);
            assert!((report.gr24_complex_twistor - report.fraunhofer).abs() < 1e-12);
            assert!(relative_predictive_error(report.gr24_complex_twistor, report.fraunhofer) < 1e-12);
        }

        // Asymmetric barycentric shift d_bary = 3/5 (visibility V = 4/5):
        // complexGr24CrossingDoubleSlit_barycentric_eq_huygensSteiner
        let asym = MultiSlitParams::canonical_double_slit().with_barycentric_shift(0.6);
        assert!((asym.visibility - 0.8).abs() < 1e-12);
        for &(x, y) in &[(0.0, 0.0), (0.21, 0.11), (5.0 / 12.0, 0.0)] {
            let report = MultiSlitEvaluationReport::evaluate(&asym, x, y);
            assert!((report.gr24_complex_twistor - report.huygens_steiner).abs() < 1e-12);
            assert!((report.gr24_real_plucker - report.huygens_steiner).abs() < 1e-12);
        }
        // On-axis relative error against Fraunhofer at d_bary = 3/5, V = 4/5 is (1 - 4/5)/2 = 1/10
        let i_hs_0 = evaluate_multi_slit_model(SlitModelKind::HuygensSteiner, &asym, 0.0, 0.0);
        assert!((relative_predictive_error(i_hs_0, i_fraun) - 0.1).abs() < 1e-12);
        assert!(
            (theoretical_on_axis_relative_error(SlitModelKind::Gr24ComplexTwistor, &asym) - 0.1)
                .abs()
                < 1e-12
        );
    }

    #[test]
    fn gr24_plucker_and_pythagorean_steiner_identities_hold() {
        let asym_mat = [[1.0, 1.0, 0.0, -1.0], [0.0, 1.6, 1.0, 0.4]];
        assert!(plucker_three_term_residual_real(&asym_mat).abs() < 1e-12);
        assert!((gr24_barycentric_shift(&asym_mat) - 0.6).abs() < 1e-12);
        assert!(gr24_pythagorean_residual(&asym_mat).abs() < 1e-12);

        let z1 = Complex64::from_polar(1.6_f64.sqrt(), 0.73);
        let z2 = Complex64::from_polar(0.4_f64.sqrt(), -0.73);
        let cmat = complex_gr24_channel_matrix(z1, z2);
        assert!(plucker_three_term_residual_complex(&cmat).norm_sq() < 1e-24);
    }

    #[test]
    fn oam_vortex_null_and_wigner_quadratic_scaling_match_lean() {
        let mut oam_params = MultiSlitParams::canonical_double_slit();
        oam_params.delta_oam = 1;
        oam_params.azimuth_phi = PI;
        // At (Δℓ = 1, φ = π, x = 0, y = 0), Fraunhofer OAM intensity vanishes (vortex dark core)
        let i_vortex = evaluate_multi_slit_model(SlitModelKind::Fraunhofer, &oam_params, 0.0, 0.0);
        let i_planar = evaluate_multi_slit_model(
            SlitModelKind::Fraunhofer,
            &MultiSlitParams::canonical_double_slit(),
            0.0,
            0.0,
        );
        assert!(i_vortex.abs() < 1e-12);
        assert!((relative_predictive_error(i_vortex, i_planar) - 1.0).abs() < 1e-12);

        // Wigner quadratic (Δℓ)^2 scaling at φ = 0
        let mut wigner_params = MultiSlitParams::canonical_double_slit();
        wigner_params.oam_decoherence_rate = 0.25;
        wigner_params.delta_oam = 2;
        let i_wigner = evaluate_multi_slit_model(SlitModelKind::Wigner, &wigner_params, 0.0, 0.0);
        let i_f_oam =
            evaluate_multi_slit_model(SlitModelKind::Fraunhofer, &wigner_params, 0.0, 0.0);
        let expected_err = 0.5 * (1.0 - (-0.25 * 4.0_f64).exp());
        assert!((relative_predictive_error(i_wigner, i_f_oam) - expected_err).abs() < 1e-12);
    }

    #[test]
    fn glsl_shaders_are_non_empty_and_contain_all_uniforms() {
        assert!(GLSL_DOUBLE_SLIT_VERTEX_SHADER.contains("#version 300 es"));
        assert!(GLSL_DOUBLE_SLIT_FRAGMENT_SHADER.contains("uniform int u_num_slits;"));
        assert!(GLSL_DOUBLE_SLIT_FRAGMENT_SHADER.contains("uniform float u_slit_width;"));
        assert!(GLSL_DOUBLE_SLIT_FRAGMENT_SHADER.contains("uniform float u_slit_separation;"));
        assert!(GLSL_DOUBLE_SLIT_FRAGMENT_SHADER.contains("complex_gr24_crossing_factor"));
    }

    #[test]
    fn ddf_gr24_unification_and_projective_jamming_invariance_match_lean() {
        let asym_mat = [[1.0, 1.0, 0.0, -1.0], [0.0, 1.6, 1.0, 0.4]];
        // Critique 2 solution: projective barycentric shift & visibility are invariant under non-symplectic jamming
        let s1 = 0.7_f64.exp();
        let s2 = (-0.2_f64).exp();
        let jammed_mat = [
            [
                s1 * asym_mat[0][0],
                s1 * asym_mat[0][1],
                s1 * asym_mat[0][2],
                s1 * asym_mat[0][3],
            ],
            [
                s2 * asym_mat[1][0],
                s2 * asym_mat[1][1],
                s2 * asym_mat[1][2],
                s2 * asym_mat[1][3],
            ],
        ];
        let d_proj = gr24_projective_barycentric_shift(&asym_mat);
        let v_proj_sq = gr24_projective_visibility_sq(&asym_mat);
        assert!((d_proj - 0.6).abs() < 1e-12);
        assert!((v_proj_sq - 0.64).abs() < 1e-12);
        assert!((d_proj * d_proj + v_proj_sq - 1.0).abs() < 1e-12);
        assert!((gr24_projective_barycentric_shift(&jammed_mat) - d_proj).abs() < 1e-12);
        assert!((gr24_projective_visibility_sq(&jammed_mat) - v_proj_sq).abs() < 1e-12);

        // Critique 3 solution: DdfSheathRecovery at beta = 3/5 (eps = 0.1, V = 0.8, gamma_varphi = 1.25)
        let rec = DdfSheathRecovery::from_relative_error(0.1).unwrap();
        assert!((rec.visibility - 0.8).abs() < 1e-12);
        assert!((rec.jamming_factor - 1.25).abs() < 1e-12);
        assert!((rec.beta_sq - 0.36).abs() < 1e-12);
        assert!((rec.recover_substrate_product(1.2).unwrap() - 0.25).abs() < 1e-12);

        // Gr_C(2,4)-DDF unification: ddf_gr24_twistor_matrix matches Huygens-Steiner with V = 1 / gamma_varphi
        let mut params = MultiSlitParams::canonical_double_slit().with_barycentric_shift(0.6);
        params.delta_oam = 2;
        params.azimuth_phi = 0.45;
        for &(x, y) in &[(0.0, 0.0), (0.17, -0.22), (0.41, 0.09)] {
            let m_ddf = ddf_gr24_twistor_matrix(0.6, &params, x);
            let i_ddf = complex_gr24_crossing_double_slit(&m_ddf, &params, x, y);
            let i_hs = evaluate_multi_slit_model(SlitModelKind::HuygensSteiner, &params, x, y);
            assert!((i_ddf - i_hs).abs() < 1e-12);
        }

        // Triple-slit (N = 3) Gr_C(2,5)-DDF Madelung sector densities, Sorkin kappa_3 = 0, and zero-shear match
        let p3 = MultiSlitParams::canonical_double_slit().with_geometry(3, 2.0, 6.0);
        assert!((multi_slit_interference_factor(3, 1.0, 0.0) - 9.0).abs() < 1e-12);
        assert!(multi_slit_interference_factor(3, 1.0, PI / 3.0).abs() < 1e-12);
        let m5_sheared = ddf_gr25_triple_slit_twistor_matrix(0.6, &p3, 0.23);
        let a0 = two_row_minor_complex_slice(&m5_sheared, 0, 2);
        let a1 = two_row_minor_complex_slice(&m5_sheared, 0, 3);
        let a2 = two_row_minor_complex_slice(&m5_sheared, 0, 4);
        assert!((a0.norm_sq() + a1.norm_sq() + a2.norm_sq() - 3.0).abs() < 1e-12);
        assert!((0.5 * (a0.norm_sq() - a2.norm_sq()) - 0.6).abs() < 1e-12);
        assert!((a0.norm_sq() * a1.norm_sq() * a2.norm_sq() - 0.64).abs() < 1e-12);
        assert!(sorkin_triple_slit_parameter(a0, a1, a2).abs() < 1e-12);

        for &(x, y) in &[(0.0, 0.0), (0.19, -0.14), (5.0 / 18.0, 0.0)] {
            let m5_zero = ddf_gr25_triple_slit_twistor_matrix(0.0, &p3, x);
            let i_gr25 = complex_gr2n_collector_multi_slit(&m5_zero, &p3, x, y);
            let i_f3 = evaluate_multi_slit_model(SlitModelKind::Fraunhofer, &p3, x, y);
            assert!((i_gr25 - i_f3).abs() < 1e-12);
        }
    }
}
