//! Polariton (Hopfield Bogoliubov mixing, Vacuum Rabi anticrossing, Lyddane–Sachs–Teller
//! Reststrahlen dispersion) and Surface Plasmon Polariton (SPP) mechanics in unified
//! complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ and Dilatant Dark Fluid (DDF) mechanics,
//! both **without splats** (splat-free continuum dispersion, Plücker skin-depth duality,
//! and spatial propagation semigroup) and **with Normed 2D Anisotropic Tensor Gaussian Splats**
//! (sub-wavelength hotspot mode-area compression, Bohm quantum pressure enhancement,
//! and Ohmic-thermal splat relaxation).
//!
//! Matches the machine-checked Lean 4 theorems in `Signals.Scattering` and `Signals.DDF`:
//! - `Signals.Scattering.polariton_hopfield_rabi_and_lst_identities`
//! - `Signals.DDF.MovingSheath.sppContinuum_gr24_and_semigroup_identities`
//! - `Signals.DDF.MovingSheath.sppTensorSplat_and_thermal_identities`

use crate::double_slit::{complex_gr24_channel_matrix, two_row_minor_complex, Complex64};
use crate::orbital_splat::{NormedTensorGaussianSplat2D, SplatRole};
use crate::thermal_inelastic::DdfGrassmannianThermalTransport;
use crate::{require_nonnegative, require_positive, ValidationError};

/// Microcavity / bulk polariton model governed by Hopfield Bogoliubov photon–matter
/// hybridization and vacuum Rabi splitting, matching `polaritonEffectiveRabiSplitting`,
/// `upperPolaritonFreq`, `lowerPolaritonFreq`, and `hopfieldBarycentricShift` in
/// `Signals.Scattering`.
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct PolaritonHopfieldModel {
    pub omega_ph: f64,
    pub omega_ex: f64,
    pub rabi_coupling: f64,
}

impl PolaritonHopfieldModel {
    pub fn validate(&self) -> Result<(), ValidationError> {
        require_positive("omega_ph", self.omega_ph)?;
        require_positive("omega_ex", self.omega_ex)?;
        require_positive("rabi_coupling", self.rabi_coupling)?;
        Ok(())
    }

    /// Photon–matter detuning $\Delta_{\mathrm{pol}} = \omega_{\mathrm{ph}} - \omega_{\mathrm{ex}}$.
    pub fn detuning(&self) -> f64 {
        self.omega_ph - self.omega_ex
    }

    /// Effective Rabi splitting $\Omega_{\mathrm{eff}} = \sqrt{\Delta_{\mathrm{pol}}^2 + 4 g^2}$.
    pub fn effective_rabi_splitting(&self) -> f64 {
        let delta = self.detuning();
        (delta * delta + 4.0 * self.rabi_coupling * self.rabi_coupling).sqrt()
    }

    /// Upper polariton (UP) eigenfrequency $\omega_{\mathrm{UP}} = \frac{1}{2}(\omega_{\mathrm{ph}} + \omega_{\mathrm{ex}} + \Omega_{\mathrm{eff}})$.
    pub fn upper_polariton_freq(&self) -> f64 {
        0.5 * (self.omega_ph + self.omega_ex + self.effective_rabi_splitting())
    }

    /// Lower polariton (LP) eigenfrequency $\omega_{\mathrm{LP}} = \frac{1}{2}(\omega_{\mathrm{ph}} + \omega_{\mathrm{ex}} - \Omega_{\mathrm{eff}})$.
    pub fn lower_polariton_freq(&self) -> f64 {
        0.5 * (self.omega_ph + self.omega_ex - self.effective_rabi_splitting())
    }

    /// Inverse polariton spectroscopy: reconstructs $g^2 = \omega_{\mathrm{ph}}\omega_{\mathrm{ex}} - \omega_{\mathrm{UP}}\omega_{\mathrm{LP}}$,
    /// matching `reconstructPolaritonRabiCouplingSq` in `Signals.Scattering`.
    pub fn reconstruct_rabi_coupling_sq(
        omega_ph: f64,
        omega_ex: f64,
        omega_up: f64,
        omega_lp: f64,
    ) -> f64 {
        omega_ph * omega_ex - omega_up * omega_lp
    }

    /// Normalized Hopfield barycentric photon–matter asymmetry
    /// $d_{\mathrm{Hopfield}} = \Delta_{\mathrm{pol}} / \Omega_{\mathrm{eff}} \in (-1, 1)$.
    pub fn hopfield_barycentric_shift(&self) -> f64 {
        self.detuning() / self.effective_rabi_splitting()
    }

    /// Upper-branch Hopfield photon fraction $|C|^2 = (1 + d_{\mathrm{Hopfield}}) / 2$.
    pub fn hopfield_photon_weight(&self) -> f64 {
        0.5 * (1.0 + self.hopfield_barycentric_shift())
    }

    /// Upper-branch Hopfield matter (exciton/phonon) fraction $|X|^2 = (1 - d_{\mathrm{Hopfield}}) / 2$.
    pub fn hopfield_matter_weight(&self) -> f64 {
        0.5 * (1.0 - self.hopfield_barycentric_shift())
    }

    /// Complex $Gr_{\mathbb{C}}(2,4)$ Plücker channel invariants for the Hopfield polariton state:
    /// returns $(|w_A^{\mathbb{C}}|^2, |w_B^{\mathbb{C}}|^2, d_{\mathrm{Hopfield}}, |w_A^{\mathbb{C}}|^2 |w_B^{\mathbb{C}}|^2 = 4|C|^2|X|^2 = 1 - d_{\mathrm{Hopfield}}^2)$.
    pub fn gr24_hopfield_invariants(&self, theta: f64) -> (f64, f64, f64, f64) {
        let d_hop = self.hopfield_barycentric_shift();
        DdfGrassmannianThermalTransport::gr24_characteristic_invariants(d_hop, theta)
    }

    /// Lyddane–Sachs–Teller (LST) polariton dielectric function
    /// $\varepsilon_{\mathrm{pol}}(\omega) = \varepsilon_\infty \frac{\omega^2 - \omega_{\mathrm{LO}}^2}{\omega^2 - \omega_{\mathrm{TO}}^2}$,
    /// matching `lyddaneSachsTellerPermittivity` in `Signals.Scattering`.
    pub fn lyddane_sachs_teller_permittivity(
        eps_inf: f64,
        omega_to: f64,
        omega_lo: f64,
        omega: f64,
    ) -> f64 {
        eps_inf * (omega * omega - omega_lo * omega_lo) / (omega * omega - omega_to * omega_to)
    }
}

/// Surface Plasmon Polariton (SPP) model at a planar dielectric ($\varepsilon_d > 0$) and
/// conductor ($\varepsilon_m = -|\varepsilon_m| < -\varepsilon_d < 0$) interface, supporting
/// both **splat-free continuum** and **normed 2D anisotropic Tensor Gaussian Splat** evaluation.
/// Matches `MovingSheath.sppContinuum_gr24_and_semigroup_identities` and
/// `MovingSheath.sppTensorSplat_and_thermal_identities` in `Signals.DDF`.
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct SurfacePlasmonPolaritonModel {
    pub eps_d: f64,
    pub abs_eps_m: f64,
    pub wavelength_0: f64,
    pub gamma_spp: f64,
    pub alpha1: f64,
    pub alpha2: f64,
}

impl SurfacePlasmonPolaritonModel {
    pub fn validate(&self) -> Result<(), ValidationError> {
        require_positive("eps_d", self.eps_d)?;
        require_positive("abs_eps_m", self.abs_eps_m)?;
        require_positive("wavelength_0", self.wavelength_0)?;
        require_nonnegative("gamma_spp", self.gamma_spp)?;
        require_nonnegative("alpha1", self.alpha1)?;
        require_nonnegative("alpha2", self.alpha2)?;
        if self.abs_eps_m <= self.eps_d {
            return Err(ValidationError::NonPositive("abs_eps_m - eps_d"));
        }
        Ok(())
    }

    /// Effective SPP refractive index squared
    /// $n_{\mathrm{SPP}}^2 = \frac{\varepsilon_d |\varepsilon_m|}{|\varepsilon_m| - \varepsilon_d} > \varepsilon_d$,
    /// matching `sppEffectiveIndexSq` in `Signals.DDF`.
    pub fn effective_index_sq(&self) -> f64 {
        (self.eps_d * self.abs_eps_m) / (self.abs_eps_m - self.eps_d)
    }

    /// Effective SPP refractive index $n_{\mathrm{SPP}} = \sqrt{n_{\mathrm{SPP}}^2}$.
    pub fn effective_index(&self) -> f64 {
        self.effective_index_sq().sqrt()
    }

    /// Dimensionless SPP permittivity contrast
    /// $\chi_{\mathrm{SPP}} = \frac{|\varepsilon_m| - \varepsilon_d}{|\varepsilon_m| + \varepsilon_d} \in (0, 1)$,
    /// matching `sppPermittivityContrast` in `Signals.DDF`.
    pub fn permittivity_contrast(&self) -> f64 {
        (self.abs_eps_m - self.eps_d) / (self.abs_eps_m + self.eps_d)
    }

    /// Normal evanescent decay constant ratio $\kappa_{\mathrm{ratio}} = \frac{\kappa_m}{\kappa_d} = \frac{\delta_d}{\delta_m} = \frac{|\varepsilon_m|}{\varepsilon_d} > 1$.
    pub fn skin_depth_ratio(&self) -> f64 {
        self.abs_eps_m / self.eps_d
    }

    /// Inverse reconstruction of $|\varepsilon_m| / \varepsilon_d = (1 + \chi_{\mathrm{SPP}}) / (1 - \chi_{\mathrm{SPP}})$,
    /// matching `reconstructSppPermittivityRatio` in `Signals.DDF`.
    pub fn reconstruct_permittivity_ratio(chi_spp: f64) -> f64 {
        (1.0 + chi_spp) / (1.0 - chi_spp)
    }

    /// Splat-free $Gr_{\mathbb{C}}(2,4)$ Plücker invariants for the SPP interface state:
    /// returns $(|w_A^{\mathbb{C}}|^2, |w_B^{\mathbb{C}}|^2, |w_A^{\mathbb{C}}|^2 / |w_B^{\mathbb{C}}|^2, |w_A^{\mathbb{C}}|^2 |w_B^{\mathbb{C}}|^2)$.
    pub fn gr24_spp_invariants(&self, theta: f64) -> (f64, f64, f64, f64) {
        let chi = self.permittivity_contrast();
        let a = (1.0 + chi).sqrt();
        let b = (1.0 - chi).sqrt();
        let (c, s) = (theta.cos(), theta.sin());
        let z1 = Complex64::new(a * c, a * s);
        let z2 = Complex64::new(b * c, -b * s);
        let m = complex_gr24_channel_matrix(z1, z2);
        let w_a = two_row_minor_complex(&m, 0, 1)
            .mul(two_row_minor_complex(&m, 2, 3))
            .norm_sq();
        let w_b = two_row_minor_complex(&m, 0, 3)
            .mul(two_row_minor_complex(&m, 1, 2))
            .norm_sq();
        (w_a, w_b, w_a / w_b, w_a * w_b)
    }

    /// Splat-free continuum SPP propagation-length attenuation $I(x + L) = I_0 \exp(-\gamma_{\mathrm{SPP}} L)$,
    /// matching `evolveContinuumSppPropagation` in `Signals.DDF`.
    pub fn evolve_continuum_spp_propagation(&self, length: f64, i0: f64) -> f64 {
        i0 * (-self.gamma_spp * length).exp()
    }

    /// Splat-free continuum evanescent Bohm quantum potentials $(Q_d, Q_m)$ in the dielectric
    /// and conductor for dielectric decay constant $\kappa_d > 0$, matching
    /// `continuumBohmPotentialMode` in `Signals.DDF`.
    pub fn continuum_evanescent_bohm_potentials(
        &self,
        m_boson: f64,
        hbar: f64,
        kappa_d: f64,
    ) -> (f64, f64) {
        let kappa_m = self.skin_depth_ratio() * kappa_d;
        let q_d = DdfGrassmannianThermalTransport::continuum_bohm_potential_mode(
            m_boson, hbar, kappa_d,
        );
        let q_m = DdfGrassmannianThermalTransport::continuum_bohm_potential_mode(
            m_boson, hbar, kappa_m,
        );
        (q_d, q_m)
    }

    /// Constructs the normed 2D anisotropic Tensor Gaussian Splat for a sub-wavelength
    /// SPP hotspot (`sppHotspotTensorSplat` in `Signals.DDF`) with
    /// $\sigma_1 = \lambda_0 / n_{\mathrm{SPP}}$ and $\sigma_2 = \lambda_0 / (n_{\mathrm{SPP}} \kappa_{\mathrm{ratio}})$.
    pub fn hotspot_tensor_splat(
        &self,
        cx: f64,
        cy: f64,
        weight: f64,
        orientation_angle: f64,
    ) -> NormedTensorGaussianSplat2D {
        let n_spp = self.effective_index();
        let kappa_ratio = self.skin_depth_ratio();
        NormedTensorGaussianSplat2D {
            center_x: cx,
            center_y: cy,
            weight,
            sigma1: self.wavelength_0 / n_spp,
            sigma2: self.wavelength_0 / (n_spp * kappa_ratio),
            orientation_angle,
            role: SplatRole::DdfMovingSheathField,
        }
    }

    /// Evolves an SPP hotspot splat under Ohmic-thermal diffusion $(\alpha_1, \alpha_2)$
    /// over elapsed time $\Delta t \ge 0$, matching `NormedTensorGaussianSplat2D.evolveThermal`.
    pub fn evolve_ohmic_thermal_splat(
        &self,
        splat: &NormedTensorGaussianSplat2D,
        dt: f64,
    ) -> NormedTensorGaussianSplat2D {
        let dt_clamped = dt.max(0.0);
        NormedTensorGaussianSplat2D {
            center_x: splat.center_x,
            center_y: splat.center_y,
            weight: splat.weight,
            sigma1: (splat.sigma1 * splat.sigma1 + 2.0 * self.alpha1 * dt_clamped).sqrt(),
            sigma2: (splat.sigma2 * splat.sigma2 + 2.0 * self.alpha2 * dt_clamped).sqrt(),
            orientation_angle: splat.orientation_angle,
            role: splat.role,
        }
    }
}

/// WebAssembly C-ABI export: upper polariton eigenfrequency $\omega_{\mathrm{UP}}$.
#[unsafe(no_mangle)]
pub extern "C" fn wasm_polariton_upper_freq(
    omega_ph: f64,
    omega_ex: f64,
    rabi_coupling: f64,
) -> f64 {
    let model = PolaritonHopfieldModel {
        omega_ph,
        omega_ex,
        rabi_coupling,
    };
    model.upper_polariton_freq()
}

/// WebAssembly C-ABI export: lower polariton eigenfrequency $\omega_{\mathrm{LP}}$.
#[unsafe(no_mangle)]
pub extern "C" fn wasm_polariton_lower_freq(
    omega_ph: f64,
    omega_ex: f64,
    rabi_coupling: f64,
) -> f64 {
    let model = PolaritonHopfieldModel {
        omega_ph,
        omega_ex,
        rabi_coupling,
    };
    model.lower_polariton_freq()
}

/// WebAssembly C-ABI export: effective Surface Plasmon Polariton refractive index $n_{\mathrm{SPP}}$.
#[unsafe(no_mangle)]
pub extern "C" fn wasm_spp_effective_index(eps_d: f64, abs_eps_m: f64) -> f64 {
    let model = SurfacePlasmonPolaritonModel {
        eps_d,
        abs_eps_m,
        wavelength_0: 1.0,
        gamma_spp: 0.0,
        alpha1: 0.0,
        alpha2: 0.0,
    };
    model.effective_index()
}

/// WebAssembly C-ABI export: core Bohm quantum potential $Q_{\mathrm{core}}(\Sigma_{\mathrm{SPP}})$
/// of a sub-wavelength SPP hotspot splat.
#[unsafe(no_mangle)]
pub extern "C" fn wasm_spp_hotspot_bohm_potential(
    eps_d: f64,
    abs_eps_m: f64,
    wavelength_0: f64,
    m_boson: f64,
    hbar: f64,
) -> f64 {
    let model = SurfacePlasmonPolaritonModel {
        eps_d,
        abs_eps_m,
        wavelength_0,
        gamma_spp: 0.0,
        alpha1: 0.0,
        alpha2: 0.0,
    };
    let splat = model.hotspot_tensor_splat(0.0, 0.0, 1.0, 0.0);
    splat.core_bohm_potential(m_boson, hbar)
}

/// Coherent Synchrotron Radiation (CSR) on cylindrical SPP microtubes/CNTs (Lei et al. 2025,
/// `10.1103/cnym-16hc`), Cavity QED cooperativity (`arXiv:2403.19745`), Cherenkov–Proca
/// longitudinal phase matching, Graphene THz-eV Dirac plasmon scaling (Zhang et al. 2022),
/// low-symmetry shear polaritons (`arXiv:2312.06805`), and Grover state carving (`10.1103/s3vs-xz7w`).
/// Matches `csr_spp_cherenkov_cavity_and_grover_identities` in `Signals.Scattering`.
pub struct CsrSppCherenkovCavityModel;

impl CsrSppCherenkovCavityModel {
    /// CSR bunching intensity $I_{\mathrm{CSR}} = (N_e + N_e(N_e - 1) f_{\mathrm{bunch}}^2) I_{\mathrm{single}}$,
    /// matching `csrBunchingIntensity` in `Signals.Scattering`.
    pub fn csr_bunching_intensity(n_e: f64, f_bunch: f64, i_single: f64) -> f64 {
        (n_e + n_e * (n_e - 1.0) * f_bunch * f_bunch) * i_single
    }

    /// Relativistic synchrotron critical frequency $\omega_c^{\mathrm{CSR}} = \frac{3}{2} \omega_{\mathrm{rot}} \gamma_e^3$,
    /// matching `csrCriticalFrequency` in `Signals.Scattering`.
    pub fn csr_critical_frequency(omega_rot: f64, gamma_e: f64) -> f64 {
        1.5 * omega_rot * gamma_e.powi(3)
    }

    /// Single-emitter Cavity QED cooperativity $C_1 = 4 g_0^2 / (\kappa_{\mathrm{cav}} \gamma_{\mathrm{emit}})$,
    /// matching `cavityQEDCooperativity` in `Signals.Scattering`.
    pub fn cavity_qed_cooperativity(g_single: f64, kappa_cav: f64, gamma_emit: f64) -> f64 {
        (4.0 * g_single * g_single) / (kappa_cav * gamma_emit)
    }

    /// Superluminal transverse plasma phase velocity squared
    /// $v_{\mathrm{ph},\perp}^2 = c^2 \omega^2 / (\omega^2 - \omega_p^2) > c^2$,
    /// matching `transversePlasmaPhaseVelSq` in `Signals.Scattering`.
    pub fn transverse_plasma_phase_vel_sq(c: f64, omega: f64, omega_p: f64) -> f64 {
        (c * c * omega * omega) / (omega * omega - omega_p * omega_p)
    }

    /// Subluminal longitudinal Bohm–Gross / effective-mass plasma phase velocity squared
    /// $v_{\mathrm{ph},\parallel}^2 = \omega_p^2 / k^2 + 3 v_{\mathrm{th}}^2$,
    /// matching `longitudinalPlasmaPhaseVelSq` in `Signals.Scattering`.
    pub fn longitudinal_plasma_phase_vel_sq(v_th: f64, omega_p: f64, k: f64) -> f64 {
        (omega_p * omega_p) / (k * k) + 3.0 * v_th * v_th
    }

    /// Cherenkov phase-matching cosine $\cos\theta_C = v_{\mathrm{ph}} / v_e$,
    /// matching `cherenkovCosine` in `Signals.Scattering`.
    pub fn cherenkov_cosine(v_phase: f64, v_electron: f64) -> f64 {
        v_phase / v_electron
    }

    /// Normalized 2D Dirac graphene plasmon squared frequency $\omega_{\mathrm{GPP}}^2 = E_F q$,
    /// matching `grapheneDiracPlasmonFreqSq` in `Signals.Scattering`.
    pub fn graphene_dirac_plasmon_freq_sq(e_fermi: f64, q_wave: f64) -> f64 {
        e_fermi * q_wave
    }

    /// Single-step Grover quantum state-carving amplitude $\sin(3\theta) = \sin\theta (3 - 4\sin^2\theta)$,
    /// matching `groverSuccessAmplitude` in `Signals.Scattering`.
    pub fn grover_success_amplitude(sin_theta: f64) -> f64 {
        sin_theta * (3.0 - 4.0 * sin_theta * sin_theta)
    }

    /// Low-symmetry monoclinic/trigonal phonon-polariton dielectric shear coupling
    /// $\varepsilon_{xy} = (\varepsilon_1 - \varepsilon_2)\sin\phi\cos\phi$,
    /// matching `lowSymmetryShearCoupling` in `Signals.DDF`.
    pub fn low_symmetry_shear_coupling(eps1: f64, eps2: f64, shear_angle: f64) -> f64 {
        (eps1 - eps2) * shear_angle.sin() * shear_angle.cos()
    }
}

/// 't Hooft–Susskind–Bekenstein–Hawking Holographic Principle on a DDF `RiverExterior`
/// acoustic horizon and $Gr_{\mathbb{C}}(2,4)$ Anti-Amplituhedron destructive phase cancellation
/// (both **without splats** and **with Planck-scale Normed Tensor Gaussian Splats**),
/// matching `RiverExterior.holographic_gr24_ddf_and_antiAmplituhedron_identities` in `Signals.DDF`.
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct HolographicDdfGr24Model {
    pub g_phi: f64,
    pub source_mass: f64,
    pub speed_of_light: f64,
    pub k_b: f64,
    pub l_planck: f64,
}

impl HolographicDdfGr24Model {
    pub fn validate(&self) -> Result<(), ValidationError> {
        require_positive("g_phi", self.g_phi)?;
        require_positive("source_mass", self.source_mass)?;
        require_positive("speed_of_light", self.speed_of_light)?;
        require_positive("k_b", self.k_b)?;
        require_positive("l_planck", self.l_planck)?;
        Ok(())
    }

    /// Acoustic event horizon radius $r_H = 2 G_\phi M / c^2$, matching `RiverExterior.horizonRadius`.
    pub fn horizon_radius(&self) -> f64 {
        2.0 * self.g_phi * self.source_mass / (self.speed_of_light * self.speed_of_light)
    }

    /// 2D holographic screen area $A_H = 4\pi r_H^2$, matching `RiverExterior.horizonArea`.
    pub fn horizon_area(&self) -> f64 {
        let r_h = self.horizon_radius();
        4.0 * std::f64::consts::PI * r_h * r_h
    }

    /// 't Hooft–Susskind–Bekenstein–Hawking horizon entropy $S_{\mathrm{BH}} = k_B A_H / (4\ell_P^2)$,
    /// matching `RiverExterior.bekensteinHawkingEntropy`.
    pub fn bekenstein_hawking_entropy(&self) -> f64 {
        self.k_b * self.horizon_area() / (4.0 * self.l_planck * self.l_planck)
    }

    /// Acoustic horizon surface gravity $\kappa_H = c^2 / (2 r_H)$, matching `RiverExterior.horizonSurfaceGravity`.
    pub fn horizon_surface_gravity(&self) -> f64 {
        (self.speed_of_light * self.speed_of_light) / (2.0 * self.horizon_radius())
    }

    /// Gauss–Smarr 2D-boundary-to-3D-bulk mass recovery $\frac{\kappa_H A_H}{4\pi G_\phi} = M$.
    pub fn smarr_recovered_mass(&self) -> f64 {
        (self.horizon_surface_gravity() * self.horizon_area())
            / (4.0 * std::f64::consts::PI * self.g_phi)
    }

    /// Dimensionless DDF river inflow speed ratio $\beta_\phi(r) = \sqrt{r_H / r}$ for $r > r_H$.
    pub fn inflow_beta(&self, r: f64) -> f64 {
        (self.horizon_radius() / r).sqrt()
    }

    /// Splat-free continuum $Gr_{\mathbb{C}}(2,4)$ holographic lapse invariants at $r > r_H$:
    /// returns $(|w_A^{\mathbb{C}}|^2, |w_B^{\mathbb{C}}|^2, |w_A^{\mathbb{C}}|^2 |w_B^{\mathbb{C}}|^2 = 1 - r_H / r)$.
    pub fn gr24_holographic_lapse_invariants(&self, r: f64, theta: f64) -> (f64, f64, f64) {
        let beta_r = self.inflow_beta(r);
        let (wa_sq, wb_sq, _, prod) =
            DdfGrassmannianThermalTransport::gr24_characteristic_invariants(beta_r, theta);
        (wa_sq, wb_sq, prod)
    }

    /// Planck-scale `NormedTensorGaussianSplat2D` tile on the 2D holographic screen
    /// (`holographicPlanckSplat` in `Signals.DDF`).
    pub fn planck_splat(
        &self,
        cx: f64,
        cy: f64,
        weight: f64,
        orientation_angle: f64,
    ) -> NormedTensorGaussianSplat2D {
        NormedTensorGaussianSplat2D {
            center_x: cx,
            center_y: cy,
            weight,
            sigma1: self.l_planck,
            sigma2: self.l_planck,
            orientation_angle,
            role: SplatRole::BodySinkSource,
        }
    }

    /// Complex $Gr_{\mathbb{C}}(2,4)$ Anti-Amplituhedron destructive phase-cancellation invariants
    /// (`antiAmplituhedronGr24Matrix` in `Signals.DDF`):
    /// returns $(w_A^{\mathbb{C}}.\mathrm{re}, w_B^{\mathbb{C}}.\mathrm{re}, |\Delta_{02}^{\mathbb{C}} \Delta_{13}^{\mathbb{C}}|^2 = 0)$.
    pub fn anti_amplituhedron_invariants(amplitude: f64) -> (f64, f64, f64) {
        let z1 = Complex64::new(amplitude, 0.0);
        let z2 = Complex64::new(-amplitude, 0.0);
        let m = complex_gr24_channel_matrix(z1, z2);
        let w_a = two_row_minor_complex(&m, 0, 1).mul(two_row_minor_complex(&m, 2, 3));
        let w_b = two_row_minor_complex(&m, 0, 3).mul(two_row_minor_complex(&m, 1, 2));
        let cross = two_row_minor_complex(&m, 0, 2).mul(two_row_minor_complex(&m, 1, 3));
        (w_a.re, w_b.re, cross.norm_sq())
    }
}

/// WebAssembly C-ABI export: Coherent Synchrotron Radiation (CSR) bunching intensity.
#[unsafe(no_mangle)]
pub extern "C" fn wasm_csr_bunching_intensity(n_e: f64, f_bunch: f64, i_single: f64) -> f64 {
    CsrSppCherenkovCavityModel::csr_bunching_intensity(n_e, f_bunch, i_single)
}

/// WebAssembly C-ABI export: 't Hooft–Susskind–Bekenstein–Hawking holographic horizon entropy.
#[unsafe(no_mangle)]
pub extern "C" fn wasm_bekenstein_hawking_entropy(
    g_phi: f64,
    source_mass: f64,
    speed_of_light: f64,
    k_b: f64,
    l_planck: f64,
) -> f64 {
    let model = HolographicDdfGr24Model {
        g_phi,
        source_mass,
        speed_of_light,
        k_b,
        l_planck,
    };
    model.bekenstein_hawking_entropy()
}

/// Low-power integrated Optical Parametric Amplifier (OPA) via Second-Harmonic ($\chi^{(2)}$)
/// Resonance (Dean et al., 2025, *Nature*, `10.1038/s41586-025-09959-z`), supporting both
/// **splat-free continuum** quadrature/Bohm evaluation and **symplectic OPA-squeezed
/// `NormedTensorGaussianSplat2D`** evaluation.
/// Matches `second_harmonic_opa_and_centrosymmetry_identities` in `Signals.Scattering`
/// and `opaSqueezed_splat_and_continuum_identities` in `Signals.DDF`.
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct SecondHarmonicResonantOpaModel {
    pub fundamental_freq_hz: f64,
    pub finesse_buildup: f64,
    pub single_pass_sh_power_w: f64,
    pub g_opa: f64,
    pub r_squeeze: f64,
}

impl SecondHarmonicResonantOpaModel {
    pub fn validate(&self) -> Result<(), ValidationError> {
        require_positive("fundamental_freq_hz", self.fundamental_freq_hz)?;
        require_positive("finesse_buildup", self.finesse_buildup)?;
        require_nonnegative("single_pass_sh_power_w", self.single_pass_sh_power_w)?;
        require_nonnegative("g_opa", self.g_opa)?;
        require_nonnegative("r_squeeze", self.r_squeeze)?;
        if self.finesse_buildup < 1.0 {
            return Err(ValidationError::NonPositive("finesse_buildup - 1"));
        }
        Ok(())
    }

    /// Second-harmonic resonance frequency $2\omega_0$, matching `SecondHarmonicResonance` in `Signals.ActiveOptics`.
    pub fn second_harmonic_freq_hz(&self) -> f64 {
        2.0 * self.fundamental_freq_hz
    }

    /// Second-order nonlinear polarization $P^{(2)} = \chi^{(2)} E^2$, matching `secondOrderPolarization`.
    pub fn second_order_polarization(chi2: f64, electric_field: f64) -> f64 {
        chi2 * electric_field * electric_field
    }

    /// Recirculated intracavity second-harmonic power $P_{2\omega}^{\mathrm{intracav}} = F_{\mathrm{SH}} P_{2\omega}$,
    /// matching `shgResonantIntracavityPower`.
    pub fn intracavity_sh_power(&self) -> f64 {
        self.finesse_buildup * self.single_pass_sh_power_w
    }

    /// Required single-pass second-harmonic power $P_{\mathrm{thresh}} / F_{\mathrm{SH}}$ to reach
    /// intracavity threshold $P_{\mathrm{thresh}}$.
    pub fn required_input_power_for_threshold(&self, threshold_power: f64) -> f64 {
        threshold_power / self.finesse_buildup
    }

    /// Phase-mismatched net squared parametric gain rate $g_{\mathrm{net}}^2 = g_{\mathrm{OPA}}^2 - (\Delta k / 2)^2$,
    /// matching `opaNetGainSq`.
    pub fn net_gain_sq(&self, delta_k: f64) -> f64 {
        self.g_opa * self.g_opa - 0.25 * delta_k * delta_k
    }

    /// Phase-sensitive amplified in-phase quadrature variance $\exp(2 r_{\mathrm{sq}})$,
    /// matching `opaAmplifiedQuadratureGain`.
    pub fn amplified_quadrature_gain(&self) -> f64 {
        (2.0 * self.r_squeeze).exp()
    }

    /// Phase-sensitive squeezed anti-phase quadrature variance $\exp(-2 r_{\mathrm{sq}})$,
    /// matching `opaSqueezedQuadratureGain`.
    pub fn squeezed_quadrature_gain(&self) -> f64 {
        (-2.0 * self.r_squeeze).exp()
    }

    /// Splat-free continuum Bohm quantum potential of the squeezed quadrature mode
    /// $\kappa = \kappa_0 \exp(r_{\mathrm{sq}})$, matching `continuumBohmPotentialMode`.
    pub fn continuum_squeezed_bohm_potential(
        &self,
        m_boson: f64,
        hbar: f64,
        kappa0: f64,
    ) -> f64 {
        DdfGrassmannianThermalTransport::continuum_bohm_potential_mode(
            m_boson,
            hbar,
            kappa0 * self.r_squeeze.exp(),
        )
    }

    /// Symplectic OPA-squeezed `NormedTensorGaussianSplat2D` (`opaSqueezedTensorSplat` in `Signals.DDF`)
    /// with $\sigma_1 = \sigma_0 \exp(r_{\mathrm{sq}})$ and $\sigma_2 = \sigma_0 \exp(-r_{\mathrm{sq}})$.
    pub fn opa_squeezed_tensor_splat(
        &self,
        cx: f64,
        cy: f64,
        weight: f64,
        sigma0: f64,
        orientation_angle: f64,
    ) -> NormedTensorGaussianSplat2D {
        NormedTensorGaussianSplat2D {
            center_x: cx,
            center_y: cy,
            weight,
            sigma1: sigma0 * self.r_squeeze.exp(),
            sigma2: sigma0 * (-self.r_squeeze).exp(),
            orientation_angle,
            role: SplatRole::Gr24OrbitalField,
        }
    }

    /// Coupled electro-thermal-optical phase mismatch
    /// $\Delta k(T, V) = \Delta k_0 + \kappa_{\mathrm{th}} \Delta T + \kappa_{\mathrm{eo}} V$
    /// and net squared parametric gain $g_{\mathrm{net}}^2(T, V) = g_{\mathrm{OPA}}^2 - \frac{1}{4}\Delta k(T, V)^2$.
    pub fn coupled_electro_thermal_net_gain_sq(
        &self,
        delta_k0: f64,
        thermo_optic_coeff: f64,
        delta_temp_k: f64,
        electro_optic_coeff: f64,
        gate_voltage_v: f64,
    ) -> (f64, f64) {
        let delta_k_eff =
            delta_k0 + thermo_optic_coeff * delta_temp_k + electro_optic_coeff * gate_voltage_v;
        (delta_k_eff, self.net_gain_sq(delta_k_eff))
    }
}

/// WebAssembly C-ABI export: core Bohm quantum potential of a second-harmonic OPA-squeezed splat.
#[unsafe(no_mangle)]
pub extern "C" fn wasm_shg_opa_squeezed_bohm_potential(
    sigma0: f64,
    r_squeeze: f64,
    m_boson: f64,
    hbar: f64,
) -> f64 {
    let model = SecondHarmonicResonantOpaModel {
        fundamental_freq_hz: 400.0e9,
        finesse_buildup: 10.0,
        single_pass_sh_power_w: 0.1,
        g_opa: 1.0,
        r_squeeze,
    };
    let splat = model.opa_squeezed_tensor_splat(0.0, 0.0, 1.0, sigma0, 0.0);
    splat.core_bohm_potential(m_boson, hbar)
}

/// AdS/CFT Correspondence (Maldacena 1998, GKPW 1998, KSS 2005, Ryu–Takayanagi 2006),
/// Planar Integrability (Beisert et al. 2012, `arXiv:1012.3982`), Secret Symmetries
/// (de Leeuw, Matsumoto, Moriyama, Regelskis & Torrielli 2012, `arXiv:1204.2366`),
/// and Complex $Gr_{\mathbb{C}}(2,4)$ / DDF Holographic Unification (With and Without Splats).
/// Matches `ads_cft_integrability_and_secret_symmetry_identities` in `Signals.Scattering`
/// and `RiverExterior.grassmannian_ads_cft_ddf_and_secret_symmetry_unification` in `Signals.DDF`.
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct AdsCftIntegrabilitySecretModel {
    pub d_boundary: f64,
    pub m_sq_r_sq: f64,
    pub r_ads: f64,
    pub g_n3: f64,
    pub lam_thooft: f64,
    pub m_bound: f64,
}

impl AdsCftIntegrabilitySecretModel {
    pub fn validate(&self) -> Result<(), ValidationError> {
        require_positive("d_boundary", self.d_boundary)?;
        require_positive("r_ads", self.r_ads)?;
        require_positive("g_n3", self.g_n3)?;
        require_nonnegative("lam_thooft", self.lam_thooft)?;
        require_positive("m_bound", self.m_bound)?;
        if self.m_sq_r_sq < Self::breitenlohner_freedman_bound(self.d_boundary) {
            return Err(ValidationError::NonPositive("m_sq_r_sq - m_BF^2"));
        }
        Ok(())
    }

    /// Planar 't Hooft coupling $\lambda = g_{\mathrm{YM}}^2 N_c$, matching `adsTftHooftCoupling`.
    pub fn thooft_coupling(g_ym: f64, n_c: f64) -> f64 {
        g_ym * g_ym * n_c
    }

    /// AdS/CFT coupling–tension dictionary $\lambda = 4\pi^2 T_{\mathrm{str}}^2$,
    /// matching `adsCouplingFromStringTension` (`arXiv:1012.3982`).
    pub fn coupling_from_string_tension(t_str: f64) -> f64 {
        4.0 * std::f64::consts::PI * std::f64::consts::PI * t_str * t_str
    }

    /// Breitenlohner–Freedman stability bound $m_{\mathrm{BF}}^2 R_{\mathrm{AdS}}^2 = -d^2 / 4$,
    /// matching `adsBreitenlohnerFreedmanBound`.
    pub fn breitenlohner_freedman_bound(d: f64) -> f64 {
        -0.25 * d * d
    }

    /// GKPW normalizable scaling dimension $\Delta_+ = d/2 + \sqrt{(d/2)^2 + m^2 R_{\mathrm{AdS}}^2}$,
    /// matching `adsCftScalingDimensionPlus`.
    pub fn scaling_dimension_plus(&self) -> f64 {
        0.5 * self.d_boundary + (0.25 * self.d_boundary * self.d_boundary + self.m_sq_r_sq).sqrt()
    }

    /// GKPW shadow scaling dimension $\Delta_- = d/2 - \sqrt{(d/2)^2 + m^2 R_{\mathrm{AdS}}^2}$,
    /// matching `adsCftScalingDimensionMinus`.
    pub fn scaling_dimension_minus(&self) -> f64 {
        0.5 * self.d_boundary - (0.25 * self.d_boundary * self.d_boundary + self.m_sq_r_sq).sqrt()
    }

    /// Kovtun–Son–Starinets (KSS) holographic viscosity bound $(\eta/s)_{\mathrm{KSS}} = \hbar / (4\pi k_B)$,
    /// matching `kssShearViscosityEntropyBound`.
    pub fn kss_viscosity_entropy_bound(hbar: f64, k_b: f64) -> f64 {
        hbar / (4.0 * std::f64::consts::PI * k_b)
    }

    /// Brown–Henneaux $\text{AdS}_3/\text{CFT}_2$ central charge $c_{\mathrm{BH}} = 3 R_{\mathrm{AdS}} / (2 G_N^{(3)})$,
    /// matching `brownHenneauxCentralCharge`.
    pub fn brown_henneaux_central_charge(&self) -> f64 {
        (3.0 * self.r_ads) / (2.0 * self.g_n3)
    }

    /// Ryu–Takayanagi $\text{AdS}_3/\text{CFT}_2$ entanglement entropy
    /// $S_{\mathrm{EE}}(\ell, \epsilon_{\mathrm{UV}}) = \frac{R_{\mathrm{AdS}}}{2 G_N^{(3)}}\ln(\ell / \epsilon_{\mathrm{UV}})$,
    /// matching `ryuTakayanagiEntanglementEntropyAdS3`.
    pub fn ryu_takayanagi_ee_ads3(&self, l_interval: f64, eps_uv: f64) -> f64 {
        (self.r_ads / (2.0 * self.g_n3)) * (l_interval / eps_uv).ln()
    }

    /// All-loop $\mathfrak{psu}(2|2)^2 \ltimes \mathbb{R}^3$ bound-state magnon squared dispersion
    /// $E^2(M, \lambda, p) = M^2 + (\lambda / \pi^2)\sin^2(p/2)$, matching `adsMagnonDispersionSq`.
    pub fn magnon_dispersion_sq(&self, p: f64) -> f64 {
        let sin_half = (0.5 * p).sin();
        self.m_bound * self.m_bound
            + (self.lam_thooft / (std::f64::consts::PI * std::f64::consts::PI))
                * sin_half
                * sin_half
    }

    /// All-loop bound-state magnon energy $E(M, \lambda, p)$, matching `adsMagnonDispersion`.
    pub fn magnon_dispersion(&self, p: f64) -> f64 {
        self.magnon_dispersion_sq(p).sqrt()
    }

    /// One-loop planar Bethe magnon anomalous dimension $\delta D_1(\lambda, u) = \frac{\lambda}{8\pi^2(u^2 + 1/4)}$,
    /// matching `betheOneLoopMagnonEnergy`.
    pub fn bethe_one_loop_magnon_energy(&self, u: f64) -> f64 {
        (self.lam_thooft / (8.0 * std::f64::consts::PI * std::f64::consts::PI))
            / (u * u + 0.25)
    }

    /// Konishi one-loop anomalous dimension $\delta D_{\mathrm{Konishi}}^{(1)}(\lambda) = \frac{3\lambda}{4\pi^2}$,
    /// matching `konishiOneLoopAnomalousDim`.
    pub fn konishi_one_loop_anomalous_dim(&self) -> f64 {
        (3.0 * self.lam_thooft) / (4.0 * std::f64::consts::PI * std::f64::consts::PI)
    }

    /// Three-loop weak-coupling cusp anomalous dimension check figure (`arXiv:1012.3982`, Sec. III.4):
    /// $D_{\mathrm{cusp}}^{\mathrm{weak}}(\lambda) = \frac{\lambda}{2\pi^2} - \frac{\lambda^2}{96\pi^2} + \frac{11\lambda^3}{23040\pi^2}$.
    pub fn cusp_anomalous_dim_weak_3loop(&self) -> f64 {
        let pi2 = std::f64::consts::PI * std::f64::consts::PI;
        let l = self.lam_thooft;
        l / (2.0 * pi2) - (l * l) / (96.0 * pi2) + (11.0 * l * l * l) / (23040.0 * pi2)
    }

    /// Strong-coupling cusp anomalous dimension check figure (`arXiv:1012.3982`, Sec. III.4):
    /// $D_{\mathrm{cusp}}^{\mathrm{strong}}(\lambda) = \frac{\sqrt{\lambda}}{\pi} - \frac{3\ln 2}{\pi}$.
    pub fn cusp_anomalous_dim_strong_leading(&self) -> f64 {
        (self.lam_thooft.sqrt() - 3.0 * 2.0_f64.ln()) / std::f64::consts::PI
    }

    /// Braided central charge $\mathbb{C}(p) = e^{ip} - 1$ of $\mathfrak{psl}(2|2)_c$,
    /// matching `psl22BraidedCentralChargeC` (`arXiv:1204.2366`, Eq. (2.4)).
    pub fn psl22_braided_central_charge_c(p: f64) -> Complex64 {
        Complex64::new(p.cos() - 1.0, p.sin())
    }

    /// Conjugate braided central charge $\mathbb{C}^\dagger(p) = e^{-ip} - 1$,
    /// matching `psl22BraidedCentralChargeCDag` (`arXiv:1204.2366`, Eq. (2.4)).
    pub fn psl22_braided_central_charge_cdag(p: f64) -> Complex64 {
        Complex64::new(p.cos() - 1.0, -p.sin())
    }

    /// Quasi-cocommutative braided coproduct $\Delta(\mathbb{C})(C_1, C_2) = C_1 + C_2 + C_1 C_2$,
    /// matching `psl22BraidedCoproductC` (`arXiv:1204.2366`, Eq. (2.5)).
    pub fn psl22_braided_coproduct_c(c1: Complex64, c2: Complex64) -> Complex64 {
        c1.add(c2).add(c1.mul(c2))
    }

    /// Typical (long) $\mathfrak{gl}(2|2)$ representation dimension $16(2 j_1 + 1)(2 j_2 + 1)$,
    /// matching `gl22LongRepDim` (`arXiv:1204.2366`, Sec. 2.3).
    pub fn gl22_long_rep_dim(j1: f64, j2: f64) -> f64 {
        16.0 * (2.0 * j1 + 1.0) * (2.0 * j2 + 1.0)
    }

    /// Atypical (short) $\mathfrak{psl}(2|2)_c$ bound-state representation dimension $4 M$,
    /// matching `psl22ShortBoundStateDim` (`arXiv:1204.2366`, Sec. 2.3).
    pub fn psl22_short_bound_state_dim(m_bound: f64) -> f64 {
        4.0 * m_bound
    }

    /// Ordinary trace ($0$) and $(2|2)$-graded supertrace ($4 B_0$) of the indented Yangian
    /// secret symmetry generator $\widehat{\mathbb{B}} = B_0 \operatorname{diag}(1, 1, -1, -1)$
    /// (`arXiv:1204.2366`, Eq. (3.2) & Sec. 3.4).
    pub fn secret_symmetry_trace_and_supertrace(b0: f64) -> (f64, f64) {
        (0.0, 4.0 * b0)
    }

    /// Maximum entrywise residual of the $16 \times 16$ $\mathfrak{psl}(2|2)_c$ worldsheet
    /// $R$-matrix and full Yangian secret coproduct intertwining equation
    /// $\Delta_{\mathrm{full}}^{\mathrm{op}}(\widehat{\mathbb{B}})\,R_{16} - R_{16}\,\Delta_{\mathrm{full}}(\widehat{\mathbb{B}}) = 0$
    /// (`arXiv:1204.2366`, Eq. (3.1)–(3.3); `psl22_rmatrix16_secret_coproduct_intertwining` in `Signals.Scattering`).
    pub fn psl22_rmatrix16_full_secret_intertwining_max_residual(
        b1: f64,
        b2: f64,
        a_b: f64,
        b_b: f64,
        d_f: f64,
        e_f: f64,
        g_bf: f64,
        l_bf: f64,
    ) -> f64 {
        let parity = |idx: usize| if idx < 2 { 1.0 } else { -1.0 };
        let tau = (b1 - b2) * l_bf;
        let mut r_mat = [[0.0_f64; 16]; 16];
        let mut d_full = [[0.0_f64; 16]; 16];
        let mut d_op = [[0.0_f64; 16]; 16];

        for i in 0..16 {
            let a = i / 4;
            let b = i % 4;
            let swap_i = 4 * b + a;
            let p_a = parity(a);
            let p_b = parity(b);

            d_full[i][i] = g_bf * (b1 * p_a + b2 * p_b);
            d_op[i][i] = g_bf * (b2 * p_a + b1 * p_b);
            let tail = tau * 0.5 * (p_a - p_b);
            d_full[i][swap_i] += tail;
            d_op[i][swap_i] += tail;

            if a < 2 && b < 2 {
                r_mat[i][i] += a_b;
                r_mat[i][swap_i] += b_b;
            } else if a >= 2 && b >= 2 {
                r_mat[i][i] += d_f;
                r_mat[i][swap_i] += e_f;
            } else {
                r_mat[i][i] += l_bf;
                r_mat[i][swap_i] += g_bf;
            }
        }

        let mut max_res = 0.0_f64;
        for i in 0..16 {
            for j in 0..16 {
                let mut lhs = 0.0;
                let mut rhs = 0.0;
                for k in 0..16 {
                    lhs += d_op[i][k] * r_mat[k][j];
                    rhs += r_mat[i][k] * d_full[k][j];
                }
                max_res = max_res.max((lhs - rhs).abs());
            }
        }
        max_res
    }

    /// Complex $Gr_{\mathbb{C}}(2,4)$ embedding of the $\mathfrak{psl}(2|2)_c$ secret-symmetry
    /// outer automorphism (`psl22SecretAutomorphismGr24Matrix` in `Signals.DDF`):
    /// returns $(\Delta_{01}^{\mathbb{C}}, \Delta_{23}^{\mathbb{C}}, \Delta_{03}^{\mathbb{C}}, \Delta_{12}^{\mathbb{C}}, \Delta_{02}^{\mathbb{C}}\Delta_{13}^{\mathbb{C}})$.
    pub fn psl22_secret_automorphism_gr24_minors(
        a: Complex64,
        b: Complex64,
        c: Complex64,
        d: Complex64,
    ) -> (Complex64, Complex64, Complex64, Complex64, Complex64) {
        let neg = |z: Complex64| Complex64::new(-z.re, -z.im);
        let m = [[a, b, a, neg(b)], [c, d, neg(c), d]];
        let d01 = two_row_minor_complex(&m, 0, 1);
        let d23 = two_row_minor_complex(&m, 2, 3);
        let d03 = two_row_minor_complex(&m, 0, 3);
        let d12 = two_row_minor_complex(&m, 1, 2);
        let d02_13 = two_row_minor_complex(&m, 0, 2).mul(two_row_minor_complex(&m, 1, 3));
        (d01, d23, d03, d12, d02_13)
    }

    /// Poincaré $\text{AdS}_{d+1}$ planar black-brane emblackening factor $1 - (z / z_H)^d$,
    /// matching `adsPlanarBlackBraneEmblackening` in `Signals.DDF`.
    pub fn ads_planar_black_brane_emblackening(z: f64, z_h: f64, d: i32) -> f64 {
        1.0 - (z / z_h).powi(d)
    }

    /// Splat-free $Gr_{\mathbb{C}}(2,4)$ Plücker channel invariants for an $\text{AdS}_5$ ($d=4$)
    /// planar black brane at bulk depth $z \in (0, z_H)$:
    /// returns $(|w_A^{\mathbb{C}}|^2, |w_B^{\mathbb{C}}|^2, |w_A^{\mathbb{C}}|^2 |w_B^{\mathbb{C}}|^2 = 1 - (z/z_H)^4)$.
    pub fn gr24_ads5_black_brane_invariants(z: f64, z_h: f64, theta: f64) -> (f64, f64, f64) {
        let beta_ads5 = (z / z_h).powi(2);
        let (wa_sq, wb_sq, _, prod) =
            DdfGrassmannianThermalTransport::gr24_characteristic_invariants(beta_ads5, theta);
        (wa_sq, wb_sq, prod)
    }

    /// Holographic RG `NormedTensorGaussianSplat2D` wavepacket with coarse-graining width
    /// $\sigma_1 = \sigma_2 = z_{\mathrm{rg}}$, matching `adsHolographicRGSplat` in `Signals.DDF`.
    pub fn ads_holographic_rg_splat(
        cx: f64,
        cy: f64,
        weight: f64,
        z_rg: f64,
        orientation_angle: f64,
    ) -> NormedTensorGaussianSplat2D {
        NormedTensorGaussianSplat2D {
            center_x: cx,
            center_y: cy,
            weight,
            sigma1: z_rg,
            sigma2: z_rg,
            orientation_angle,
            role: SplatRole::BodySinkSource,
        }
    }
}

/// WebAssembly C-ABI export: GKPW normalizable scaling dimension $\Delta_+(d, m^2 R_{\mathrm{AdS}}^2)$.
#[unsafe(no_mangle)]
pub extern "C" fn wasm_ads_cft_scaling_dimension_plus(d: f64, m_sq_r_sq: f64) -> f64 {
    0.5 * d + (0.25 * d * d + m_sq_r_sq).sqrt()
}

/// WebAssembly C-ABI export: All-loop AdS/CFT bound-state magnon dispersion $E(M, \lambda, p)$.
#[unsafe(no_mangle)]
pub extern "C" fn wasm_ads_magnon_dispersion(m_bound: f64, lam_thooft: f64, p: f64) -> f64 {
    let model = AdsCftIntegrabilitySecretModel {
        d_boundary: 4.0,
        m_sq_r_sq: 0.0,
        r_ads: 1.0,
        g_n3: 1.0,
        lam_thooft,
        m_bound,
    };
    model.magnon_dispersion(p)
}

/// Effective Medium Theory (EMT) & Cold-Plasma evaluator for `rGO-polyCBD-SS-Lignin`
/// ENZ and Hyperbolic Metamaterials, Magnetized Argon/Ionosphere Trivelpiece–Gould modes,
/// Denisov mode conversion, and CPA-TNSA $p\text{-}^{11}\text{B}$ / $s\text{CO}_2$ power ledgers
/// (`Signals.DDF.rgo_polycbd_enz_hyperbolic_and_plasma_metamaterial_identities` and
/// `Signals.DDF.argon_ion_acoustic_tnsa_enz_polycbd_and_sco2_ledger_identities`).
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct RgoPolyCbdHyperbolicMetamaterial {
    pub eps_d: f64,
    pub abs_eps_m: f64,
}

impl RgoPolyCbdHyperbolicMetamaterial {
    /// Critical ENZ volume fill fraction $f_{\mathrm{ENZ}} = \varepsilon_d / (\varepsilon_d + |\varepsilon_m|)$.
    #[inline]
    pub fn critical_enz_fill_fraction(&self) -> f64 {
        self.eps_d / (self.eps_d + self.abs_eps_m)
    }

    /// Out-of-plane pole fill fraction $f_{\perp,\mathrm{pole}} = |\varepsilon_m| / (\varepsilon_d + |\varepsilon_m|)$.
    #[inline]
    pub fn perpendicular_pole_fill_fraction(&self) -> f64 {
        self.abs_eps_m / (self.eps_d + self.abs_eps_m)
    }

    /// In-plane EMT permittivity $\varepsilon_\parallel(f) = -f|\varepsilon_m| + (1 - f)\varepsilon_d$.
    #[inline]
    pub fn epsilon_parallel(&self, f: f64) -> f64 {
        -f * self.abs_eps_m + (1.0 - f) * self.eps_d
    }

    /// Out-of-plane EMT permittivity $\varepsilon_\perp(f) = \frac{-|\varepsilon_m|\varepsilon_d}{-(1 - f)|\varepsilon_m| + f\varepsilon_d}$.
    #[inline]
    pub fn epsilon_perp(&self, f: f64) -> f64 {
        (-self.abs_eps_m * self.eps_d) / (-(1.0 - f) * self.abs_eps_m + f * self.eps_d)
    }

    /// Disulfide $90^\circ$ flake-rotation switch $(\varepsilon_\parallel, \varepsilon_\perp) \mapsto (\varepsilon_\perp, \varepsilon_\parallel)$.
    #[inline]
    pub fn rotated90_tensor(&self, f: f64) -> (f64, f64) {
        (self.epsilon_perp(f), self.epsilon_parallel(f))
    }

    /// Squared axial wavevector $k_z^2(k_x) = \varepsilon_\perp(\omega_c^2 + k_x^2 / |\varepsilon_\parallel|)$
    /// in the Type-II hyperbolic regime.
    #[inline]
    pub fn type2_hyperbolic_kz_sq(omega_c: f64, eps_perp: f64, abs_eps_par: f64, kx: f64) -> f64 {
        eps_perp * (omega_c * omega_c + (kx * kx) / abs_eps_par)
    }

    /// Magnetized cold-plasma dielectric tensor $(\varepsilon_\parallel(\omega), \varepsilon_\perp(\omega))$.
    #[inline]
    pub fn cold_plasma_tensor(omega: f64, omega_pe: f64, omega_ce: f64) -> (f64, f64) {
        let eps_par = 1.0 - (omega_pe / omega).powi(2);
        let eps_perp = 1.0 - (omega_pe * omega_pe) / (omega * omega - omega_ce * omega_ce);
        (eps_par, eps_perp)
    }

    /// Denisov linear mode-conversion parameter $\tau_D = (k_0 L_n)^{1/3} \sin\theta_{\mathrm{in}}$.
    #[inline]
    pub fn denisov_param(k0: f64, l_n: f64, theta_in_rad: f64) -> f64 {
        (k0 * l_n).cbrt() * theta_in_rad.sin()
    }

    /// Evaluate the CPA-TNSA $p\text{-}^{11}\text{B}$ engineering gain $Q_E$, $s\text{CO}_2$
    /// mass flow rate, and 10 Hz intermediate DC bus supercapacitor capacitance.
    #[inline]
    pub fn tnsa_enz_polycbd_and_sco2_summary() -> (f64, f64, f64, f64, f64, f64) {
        let qe_flat = 0.20 * 0.10 * 30.0 * 0.85;
        let qe_cone = 0.20 * 0.30 * 45.0 * 0.85;
        let qe_enz_polycbd = 0.20 * 0.38 * 40.0 * 0.85;
        let mdot_sco2 = 45600.0 / (1.25 * 200.0);
        let qe_with_sco2 = (258.4 + 45.6 * 0.45) / 100.0;
        let cap_bus_farads =
            (2.0 * 258_400_000.0 * (0.1 - 0.001)) / (10_000.0_f64.powi(2) - 9_800.0_f64.powi(2));
        (
            qe_flat,
            qe_cone,
            qe_enz_polycbd,
            mdot_sco2,
            qe_with_sco2,
            cap_bus_farads,
        )
    }

    /// Audit the 3-zone $400 \to 800\text{ GHz}$ `rGO-polyCBD-SS-Lignin` hyperbolic SFG lens
    /// (`Signals.three_zone_rgo_polycbd_sfg_and_hydroxyl_kinetics_audit_identities`):
    /// returns $(f_{\mathrm{ENZ,400}},\; \varepsilon_{\perp,400}(0.032),\; \varepsilon_{\perp,800}(0.032),\; f_{\mathrm{ENZ,800}},\; \Gamma_{\mathrm{ENZ,reg}}(f_{\mathrm{ENZ,800}}),\; \Gamma_{\mathrm{ENZ,reg}}(0.0988))$.
    #[inline]
    pub fn three_zone_sfg_and_enz_audit_summary() -> [f64; 6] {
        let hmm_400 = Self {
            eps_d: 2.82,
            abs_eps_m: 110.0,
        };
        let hmm_800 = Self {
            eps_d: 2.82,
            abs_eps_m: 27.5,
        };
        let f_enz_400 = hmm_400.critical_enz_fill_fraction();
        let eps_perp_400 = hmm_400.epsilon_perp(0.032);
        let eps_perp_800 = hmm_800.epsilon_perp(0.032);
        let f_enz_800 = hmm_800.critical_enz_fill_fraction();
        let eps_i_800 = 0.048_f64;
        let gamma_exact_800 = 2.82_f64.powi(2) / (0.0_f64.powi(2) + eps_i_800.powi(2));
        let eps_par_detuned = hmm_800.epsilon_parallel(0.0988);
        let gamma_detuned_800 =
            2.82_f64.powi(2) / (eps_par_detuned.powi(2) + eps_i_800.powi(2));
        [
            f_enz_400,
            eps_perp_400,
            eps_perp_800,
            f_enz_800,
            gamma_exact_800,
            gamma_detuned_800,
        ]
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use rstest::rstest;

    #[rstest]
    #[case(7.0, 4.0, 2.0, 3.0, 4.0, 6.0, 5.0)]
    #[case(5.0, 5.0, 1.5, 2.5, 10.0, 15.0, 12.0)]
    #[case(12.0, 4.0, 3.0, 4.0, 20.0, 30.0, 25.0)]
    fn parametric_polariton_hopfield_rabi_and_lst_identities(
        #[case] omega_ph: f64,
        #[case] omega_ex: f64,
        #[case] g: f64,
        #[case] eps_inf: f64,
        #[case] omega_to: f64,
        #[case] omega_lo: f64,
        #[case] omega_rest: f64,
    ) {
        let model = PolaritonHopfieldModel {
            omega_ph,
            omega_ex,
            rabi_coupling: g,
        };
        model.validate().unwrap();
        let w_up = model.upper_polariton_freq();
        let w_lp = model.lower_polariton_freq();
        let omega_eff = model.effective_rabi_splitting();

        assert!(((w_up + w_lp) - (omega_ph + omega_ex)).abs() < 1e-12);
        assert!(((w_up - w_lp) - omega_eff).abs() < 1e-12);
        assert!(w_up - w_lp >= 2.0 * g - 1e-12);

        let rec_g_sq =
            PolaritonHopfieldModel::reconstruct_rabi_coupling_sq(omega_ph, omega_ex, w_up, w_lp);
        assert!((rec_g_sq - g * g).abs() < 1e-12);

        let d_hop = model.hopfield_barycentric_shift();
        let w_ph = model.hopfield_photon_weight();
        let w_ex = model.hopfield_matter_weight();
        assert!(d_hop > -1.0 && d_hop < 1.0);
        assert!(((w_ph + w_ex) - 1.0).abs() < 1e-12);
        assert!(((w_ph - w_ex) - d_hop).abs() < 1e-12);

        let (wa_sq, wb_sq, d_rec, prod) = model.gr24_hopfield_invariants(0.4);
        assert!((0.5 * wa_sq - w_ph).abs() < 1e-12);
        assert!((0.5 * wb_sq - w_ex).abs() < 1e-12);
        assert!((d_rec - d_hop).abs() < 1e-12);
        let expected_prod = (4.0 * g * g) / (model.detuning().powi(2) + 4.0 * g * g);
        assert!((prod - (4.0 * w_ph * w_ex)).abs() < 1e-12);
        assert!((prod - (1.0 - d_hop * d_hop)).abs() < 1e-12);
        assert!((prod - expected_prod).abs() < 1e-12);

        let eps_0 = PolaritonHopfieldModel::lyddane_sachs_teller_permittivity(
            eps_inf, omega_to, omega_lo, 0.0,
        );
        let expected_eps_0 = eps_inf * (omega_lo * omega_lo) / (omega_to * omega_to);
        assert!((eps_0 - expected_eps_0).abs() < 1e-12);
        let eps_lo = PolaritonHopfieldModel::lyddane_sachs_teller_permittivity(
            eps_inf, omega_to, omega_lo, omega_lo,
        );
        assert!(eps_lo.abs() < 1e-12);
        let eps_rest = PolaritonHopfieldModel::lyddane_sachs_teller_permittivity(
            eps_inf, omega_to, omega_lo, omega_rest,
        );
        assert!(eps_rest < 0.0);
    }

    #[rstest]
    #[case(2.0, 6.0, 1.55, 0.25, 1.0, 2.0)] // Dielectric-metal SPP at telecom 1.55 um
    #[case(2.25, 11.25, 0.8, 0.1, 0.5, 1.5)] //Quartzite/Au-like interface
    #[case(3.0, 300.0, 10.0, 0.05, 0.2, 0.4)] // Deep sub-wavelength THz/mid-IR N-LIG graphene SPP
    fn parametric_spp_continuum_and_tensor_splat_mechanics(
        #[case] eps_d: f64,
        #[case] abs_eps_m: f64,
        #[case] lam0: f64,
        #[case] gamma_spp: f64,
        #[case] alpha1: f64,
        #[case] alpha2: f64,
    ) {
        let spp = SurfacePlasmonPolaritonModel {
            eps_d,
            abs_eps_m,
            wavelength_0: lam0,
            gamma_spp,
            alpha1,
            alpha2,
        };
        spp.validate().unwrap();

        // 1. Splat-Free Continuum SPP Dispersion, Gr_C(2,4) Plucker Skin-Depth Duality, & Semigroup
        let n_sq = spp.effective_index_sq();
        assert!(n_sq > eps_d);
        assert!(
            ((n_sq - eps_d) - (eps_d * eps_d) / (abs_eps_m - eps_d)).abs() < 1e-11
        );
        let evan_ratio = (n_sq - eps_d) / (n_sq + abs_eps_m);
        assert!((evan_ratio - (eps_d * eps_d) / (abs_eps_m * abs_eps_m)).abs() < 1e-12);

        let chi = spp.permittivity_contrast();
        assert!(chi > 0.0 && chi < 1.0);
        let (wa_sq, wb_sq, ratio_plucker, prod_plucker) = spp.gr24_spp_invariants(0.35);
        let rec_ratio = SurfacePlasmonPolaritonModel::reconstruct_permittivity_ratio(chi);
        assert!((wa_sq - (1.0 + chi)).abs() < 1e-12);
        assert!((wb_sq - (1.0 - chi)).abs() < 1e-12);
        assert!((ratio_plucker - rec_ratio).abs() < 1e-12);
        assert!((rec_ratio - abs_eps_m / eps_d).abs() < 1e-12);
        let expected_prod = (4.0 * eps_d * abs_eps_m) / (abs_eps_m + eps_d).powi(2);
        assert!((prod_plucker - expected_prod).abs() < 1e-12);

        let i0 = 10.0;
        assert!((spp.evolve_continuum_spp_propagation(0.0, i0) - i0).abs() < 1e-12);
        let i_step1 = spp.evolve_continuum_spp_propagation(3.0, i0);
        let i_step12 = spp.evolve_continuum_spp_propagation(4.0, i_step1);
        let i_sum = spp.evolve_continuum_spp_propagation(3.0 + 4.0, i0);
        assert!((i_step12 - i_sum).abs() < 1e-12);

        let (q_d, q_m) = spp.continuum_evanescent_bohm_potentials(1.0, 1.0, 5.0);
        assert!((q_m - (abs_eps_m / eps_d).powi(2) * q_d).abs() < 1e-10);
        assert!(q_m > q_d);

        // 2. With Normed Tensor Gaussian Splats: Sub-Wavelength SPP Hotspot & Ohmic-Thermal Semigroup
        let splat = spp.hotspot_tensor_splat(0.0, 0.0, 5.0, 0.3);
        let n_spp = spp.effective_index();
        let kappa_ratio = spp.skin_depth_ratio();
        let expected_det = lam0.powi(4) / (n_spp.powi(4) * kappa_ratio.powi(2));
        assert!((splat.cov_det() - expected_det).abs() < 1e-12);
        let expected_norm =
            (n_spp * n_spp * kappa_ratio) / (2.0 * std::f64::consts::PI * lam0 * lam0);
        assert!((splat.norm_factor() - expected_norm).abs() < 1e-10);
        let expected_bohm =
            (n_spp * n_spp * (1.0 + kappa_ratio * kappa_ratio)) / (4.0 * lam0 * lam0);
        assert!((splat.core_bohm_potential(1.0, 1.0) - expected_bohm).abs() < 1e-10);
        if n_spp >= 1.0 {
            assert!(splat.core_bohm_potential(1.0, 1.0) >= 1.0 / (2.0 * lam0 * lam0) - 1e-12);
        }
        let qp1 = splat.quantum_pressure_principal1(1.0, 1.0, 0.1, -0.1);
        let qp2 = splat.quantum_pressure_principal2(1.0, 1.0, 0.1, -0.1);
        assert!((qp2 - kappa_ratio * kappa_ratio * qp1).abs() < 1e-9);

        let step0 = spp.evolve_ohmic_thermal_splat(&splat, 0.0);
        assert!((step0.sigma1 - splat.sigma1).abs() < 1e-12);
        assert!((step0.sigma2 - splat.sigma2).abs() < 1e-12);
        let step1 = spp.evolve_ohmic_thermal_splat(&splat, 3.0);
        let step12 = spp.evolve_ohmic_thermal_splat(&step1, 4.0);
        let step_sum = spp.evolve_ohmic_thermal_splat(&splat, 3.0 + 4.0);
        assert!((step12.sigma1 - step_sum.sigma1).abs() < 1e-12);
        assert!((step12.sigma2 - step_sum.sigma2).abs() < 1e-12);
        assert!(step1.core_bohm_potential(1.0, 1.0) <= splat.core_bohm_potential(1.0, 1.0) + 1e-12);
    }

    #[rstest]
    #[case(10.0, 0.5, 3.0, 2.0, 5.0, 2.0, 3.0, 5.0, 4.0, 0.5)]
    #[case(100.0, 0.8, 1.5, 4.0, 10.0, 3.0, 2.0, 4.0, 8.0, 0.25)]
    fn parametric_csr_spp_cherenkov_grover_and_holographic_identities(
        #[case] n_e: f64,
        #[case] f_bunch: f64,
        #[case] i_single: f64,
        #[case] omega_rot: f64,
        #[case] gamma_e: f64,
        #[case] g0: f64,
        #[case] v_ph: f64,
        #[case] v_e: f64,
        #[case] r_ext: f64,
        #[case] l_planck: f64,
    ) {
        let i_incoh = CsrSppCherenkovCavityModel::csr_bunching_intensity(n_e, 0.0, i_single);
        let i_super = CsrSppCherenkovCavityModel::csr_bunching_intensity(n_e, 1.0, i_single);
        let i_part = CsrSppCherenkovCavityModel::csr_bunching_intensity(n_e, f_bunch, i_single);
        assert!((i_incoh - n_e * i_single).abs() < 1e-12);
        assert!((i_super - n_e * n_e * i_single).abs() < 1e-10);
        assert!(i_part >= i_incoh - 1e-12 && i_part <= i_super + 1e-10);
        assert!(
            CsrSppCherenkovCavityModel::csr_critical_frequency(omega_rot, gamma_e)
                >= 1.5 * omega_rot
        );

        let c1 = CsrSppCherenkovCavityModel::cavity_qed_cooperativity(g0, 3.0, 5.0);
        let cn = CsrSppCherenkovCavityModel::cavity_qed_cooperativity(n_e.sqrt() * g0, 3.0, 5.0);
        assert!((cn - n_e * c1).abs() < 1e-10);

        let v_trans_sq = CsrSppCherenkovCavityModel::transverse_plasma_phase_vel_sq(2.0, 5.0, 3.0);
        assert!(v_trans_sq > 2.0 * 2.0);
        let v_long_sq = CsrSppCherenkovCavityModel::longitudinal_plasma_phase_vel_sq(0.5, 3.0, 2.0);
        assert!(v_long_sq < 2.0 * 2.0);
        let chi_c = CsrSppCherenkovCavityModel::cherenkov_cosine(v_ph, v_e);
        assert!(chi_c > 0.0 && chi_c < 1.0);
        assert!(1.0 - chi_c * chi_c > 0.0);

        let gpp1 = CsrSppCherenkovCavityModel::graphene_dirac_plasmon_freq_sq(2.0, 7.0);
        let gpp4 = CsrSppCherenkovCavityModel::graphene_dirac_plasmon_freq_sq(4.0 * 2.0, 7.0);
        assert!((gpp4 - 4.0 * gpp1).abs() < 1e-12);
        assert!((CsrSppCherenkovCavityModel::grover_success_amplitude(0.5) - 1.0).abs() < 1e-12);
        assert!(
            CsrSppCherenkovCavityModel::low_symmetry_shear_coupling(4.0, 4.0, 0.7).abs() < 1e-12
        );

        let (wa_anti, wb_anti, cross_anti) =
            HolographicDdfGr24Model::anti_amplituhedron_invariants(5.0);
        assert!((wa_anti - 5.0).abs() < 1e-12);
        assert!((wb_anti - (-5.0)).abs() < 1e-12);
        assert!(cross_anti.abs() < 1e-12);

        let holo = HolographicDdfGr24Model {
            g_phi: 1.0,
            source_mass: 2.0,
            speed_of_light: 2.0,
            k_b: 1.0,
            l_planck,
        };
        holo.validate().unwrap();
        assert!((holo.horizon_radius() - 1.0).abs() < 1e-12);
        assert!((holo.smarr_recovered_mass() - holo.source_mass).abs() < 1e-12);
        let (_, _, lapse_prod) = holo.gr24_holographic_lapse_invariants(r_ext, 0.3);
        assert!((lapse_prod - (1.0 - holo.horizon_radius() / r_ext)).abs() < 1e-12);
        let splat_p = holo.planck_splat(0.0, 0.0, 1.0, 0.0);
        assert!((splat_p.cov_det() - l_planck.powi(4)).abs() < 1e-12);
        assert!(
            (splat_p.core_bohm_potential(1.0, 1.0) - 1.0 / (2.0 * l_planck * l_planck)).abs()
                < 1e-12
        );
    }

    #[rstest]
    #[case(400.0e9, 15.0, 0.02, 4.0, 1.0, 2.0)]
    #[case(193.4e12, 25.0, 0.008, 6.0, 1.5, 3.0)]
    fn parametric_second_harmonic_resonant_opa_and_squeezed_splat_laws(
        #[case] f0: f64,
        #[case] f_sh: f64,
        #[case] p_sh: f64,
        #[case] g_opa: f64,
        #[case] r_sq: f64,
        #[case] sigma0: f64,
    ) {
        let opa = SecondHarmonicResonantOpaModel {
            fundamental_freq_hz: f0,
            finesse_buildup: f_sh,
            single_pass_sh_power_w: p_sh,
            g_opa,
            r_squeeze: r_sq,
        };
        opa.validate().unwrap();
        assert!((opa.second_harmonic_freq_hz() - 2.0 * f0).abs() < 1e-6);
        assert!(
            SecondHarmonicResonantOpaModel::second_order_polarization(0.0, 100.0).abs() < 1e-12
        );
        assert!(opa.intracavity_sh_power() >= p_sh - 1e-12);
        let req = opa.required_input_power_for_threshold(0.3);
        assert!((f_sh * req - 0.3).abs() < 1e-12);
        assert!((opa.net_gain_sq(0.0) - g_opa * g_opa).abs() < 1e-12);
        assert!(opa.net_gain_sq(1.5) <= g_opa * g_opa + 1e-12);
        assert!(opa.net_gain_sq(2.0 * g_opa).abs() < 1e-12);

        let g_plus = opa.amplified_quadrature_gain();
        let g_minus = opa.squeezed_quadrature_gain();
        assert!(g_plus >= 1.0 && g_minus <= 1.0);
        assert!((g_plus * g_minus - 1.0).abs() < 1e-12);

        let q_base =
            DdfGrassmannianThermalTransport::continuum_bohm_potential_mode(1.0, 1.0, 5.0);
        let q_sq = opa.continuum_squeezed_bohm_potential(1.0, 1.0, 5.0);
        assert!((q_sq - (2.0 * r_sq).exp() * q_base).abs() < 1e-10);
        assert!(q_sq >= q_base - 1e-12);

        let splat_opa = opa.opa_squeezed_tensor_splat(0.0, 0.0, 5.0, sigma0, 0.2);
        assert!((splat_opa.cov_det() - sigma0.powi(4)).abs() < 1e-12);
        let expected_norm = 1.0 / (2.0 * std::f64::consts::PI * sigma0 * sigma0);
        assert!((splat_opa.norm_factor() - expected_norm).abs() < 1e-12);
        let expected_bohm =
            ((2.0 * r_sq).exp() + (-2.0 * r_sq).exp()) / (4.0 * sigma0 * sigma0);
        assert!((splat_opa.core_bohm_potential(1.0, 1.0) - expected_bohm).abs() < 1e-12);
        assert!(splat_opa.core_bohm_potential(1.0, 1.0) >= 1.0 / (2.0 * sigma0 * sigma0) - 1e-12);
        let qp1 = splat_opa.quantum_pressure_principal1(1.0, 1.0, 0.1, -0.1);
        let qp2 = splat_opa.quantum_pressure_principal2(1.0, 1.0, 0.1, -0.1);
        assert!((qp2 - (4.0 * r_sq).exp() * qp1).abs() < 1e-10);

        let (dk_comp, gain_comp) =
            opa.coupled_electro_thermal_net_gain_sq(0.0, 0.5, 4.0, -1.0, 2.0);
        assert!(dk_comp.abs() < 1e-12);
        assert!((gain_comp - g_opa * g_opa).abs() < 1e-12);
    }

    #[rstest]
    #[case(4.0, 5.0, 6.0, 3.0, 16.0, 2.0, 0.7, 0.5, 2.0)]
    #[case(4.0, 0.0, 10.0, 2.5, 4.0 * std::f64::consts::PI * std::f64::consts::PI, 1.0, 1.2, 0.25, 3.0)]
    fn parametric_ads_cft_integrability_secret_symmetries_and_gr24_ddf_unification(
        #[case] d: f64,
        #[case] m_sq_r_sq: f64,
        #[case] r_ads: f64,
        #[case] g_n3: f64,
        #[case] lam: f64,
        #[case] m_bound: f64,
        #[case] p_mag: f64,
        #[case] z_uv: f64,
        #[case] lam_rg: f64,
    ) {
        let model = AdsCftIntegrabilitySecretModel {
            d_boundary: d,
            m_sq_r_sq,
            r_ads,
            g_n3,
            lam_thooft: lam,
            m_bound,
        };
        model.validate().unwrap();

        // 1. GKPW Mass-Dimension Dictionary & Breitenlohner-Freedman Bound
        let dp = model.scaling_dimension_plus();
        let dm = model.scaling_dimension_minus();
        assert!(((dp + dm) - d).abs() < 1e-12);
        assert!(((dp * dm) - (-m_sq_r_sq)).abs() < 1e-12);
        assert!(((dp * (dp - d)) - m_sq_r_sq).abs() < 1e-12);

        let bf = AdsCftIntegrabilitySecretModel::breitenlohner_freedman_bound(d);
        let dp_bf = wasm_ads_cft_scaling_dimension_plus(d, bf);
        assert!((dp_bf - 0.5 * d).abs() < 1e-12);

        // 2. Ryu-Takayanagi AdS_3/CFT_2 Entanglement Entropy & KSS Bound
        let c_bh = model.brown_henneaux_central_charge();
        let s_ee = model.ryu_takayanagi_ee_ads3(10.0, 2.0);
        assert!((s_ee - (c_bh / 3.0) * (10.0_f64 / 2.0).ln()).abs() < 1e-12);
        assert!(AdsCftIntegrabilitySecretModel::kss_viscosity_entropy_bound(1.0, 1.0) > 0.0);

        // 3. All-Loop Magnon Dispersion, Coupling-Tension Dictionary, Konishi & Cusp Check Figures
        assert!(
            (AdsCftIntegrabilitySecretModel::thooft_coupling(0.5, 64.0) - 16.0).abs() < 1e-12
        );
        let t_str = lam.sqrt() / (2.0 * std::f64::consts::PI);
        assert!(
            (AdsCftIntegrabilitySecretModel::coupling_from_string_tension(t_str) - lam).abs()
                < 1e-11
        );
        assert!((model.magnon_dispersion(0.0) - m_bound).abs() < 1e-12);
        assert!(
            (wasm_ads_magnon_dispersion(m_bound, lam, std::f64::consts::PI).powi(2)
                - (m_bound * m_bound + 4.0 * t_str * t_str))
            .abs()
                < 1e-10
        );
        assert!(model.magnon_dispersion_sq(p_mag) >= m_bound * m_bound - 1e-12);
        let u_konishi = 1.0 / (2.0 * 3.0_f64.sqrt());
        assert!(
            (2.0 * model.bethe_one_loop_magnon_energy(u_konishi)
                - model.konishi_one_loop_anomalous_dim())
            .abs()
                < 1e-12
        );
        assert!(model.cusp_anomalous_dim_weak_3loop().is_finite());
        assert!(model.cusp_anomalous_dim_strong_leading().is_finite());

        // 4. Secret Symmetries in AdS/CFT (arXiv:1204.2366)
        let c_p = AdsCftIntegrabilitySecretModel::psl22_braided_central_charge_c(p_mag);
        let cdag_p = AdsCftIntegrabilitySecretModel::psl22_braided_central_charge_cdag(p_mag);
        let braid_rel = c_p.mul(cdag_p).add(c_p).add(cdag_p);
        assert!(braid_rel.norm_sq() < 1e-24);

        let c_1 = AdsCftIntegrabilitySecretModel::psl22_braided_central_charge_c(0.4);
        let c_2 = AdsCftIntegrabilitySecretModel::psl22_braided_central_charge_c(0.9);
        let coprod_12 = AdsCftIntegrabilitySecretModel::psl22_braided_coproduct_c(c_1, c_2);
        let coprod_21 = AdsCftIntegrabilitySecretModel::psl22_braided_coproduct_c(c_2, c_1);
        assert!((coprod_12.re - coprod_21.re).abs() < 1e-12);
        assert!((coprod_12.im - coprod_21.im).abs() < 1e-12);

        assert!((AdsCftIntegrabilitySecretModel::gl22_long_rep_dim(0.0, 0.0) - 16.0).abs() < 1e-12);
        assert!(
            (AdsCftIntegrabilitySecretModel::psl22_short_bound_state_dim(1.0) - 4.0).abs() < 1e-12
        );
        assert!(
            AdsCftIntegrabilitySecretModel::psl22_short_bound_state_dim(m_bound)
                < AdsCftIntegrabilitySecretModel::gl22_long_rep_dim(0.5 * m_bound, 0.0)
        );
        let (tr_sec, str_sec) =
            AdsCftIntegrabilitySecretModel::secret_symmetry_trace_and_supertrace(2.5);
        assert!(tr_sec.abs() < 1e-12);
        assert!((str_sec - 10.0).abs() < 1e-12);

        let max_r16_res =
            AdsCftIntegrabilitySecretModel::psl22_rmatrix16_full_secret_intertwining_max_residual(
                1.7, -0.8, 3.0, 4.0, 5.0, 6.0, 2.5, 1.3,
            );
        assert!(max_r16_res < 1e-12);

        // 5. Gr_C(2,4) Realization of psl(2|2)_c Secret Automorphism & AdS_5/DDF Unification
        let a = Complex64::new(2.0, 0.0);
        let b = Complex64::new(1.0, 0.0);
        let c = Complex64::new(1.0, 0.0);
        let d_param = Complex64::new(1.0, 0.0);
        let (d01, d23, d03, d12, d02_13) =
            AdsCftIntegrabilitySecretModel::psl22_secret_automorphism_gr24_minors(
                a, b, c, d_param,
            );
        assert!((d01.re - 1.0).abs() < 1e-12 && (d23.re - 1.0).abs() < 1e-12);
        assert!((d03.re - 3.0).abs() < 1e-12 && (d12.re - (-3.0)).abs() < 1e-12);
        assert!((d02_13.re - (-8.0)).abs() < 1e-12);
        assert!(((d03.re * d03.re + d02_13.re) - d01.re * d23.re).abs() < 1e-12);

        let (_, _, prod_ads5) =
            AdsCftIntegrabilitySecretModel::gr24_ads5_black_brane_invariants(1.0, 2.0, 0.3);
        let expected_f =
            AdsCftIntegrabilitySecretModel::ads_planar_black_brane_emblackening(1.0, 2.0, 4);
        assert!((prod_ads5 - expected_f).abs() < 1e-12);
        assert!(prod_ads5 > 0.0);

        let q_cont_uv =
            DdfGrassmannianThermalTransport::continuum_bohm_potential_mode(1.0, 1.0, 1.0 / z_uv);
        let q_cont_ir = DdfGrassmannianThermalTransport::continuum_bohm_potential_mode(
            1.0,
            1.0,
            (1.0 / z_uv) / lam_rg,
        );
        assert!((q_cont_ir - (1.0 / (lam_rg * lam_rg)) * q_cont_uv).abs() < 1e-12);

        let splat_uv =
            AdsCftIntegrabilitySecretModel::ads_holographic_rg_splat(0.0, 0.0, 1.0, z_uv, 0.0);
        let splat_ir = AdsCftIntegrabilitySecretModel::ads_holographic_rg_splat(
            0.0,
            0.0,
            1.0,
            lam_rg * z_uv,
            0.0,
        );
        assert!((splat_ir.cov_det() - lam_rg.powi(4) * splat_uv.cov_det()).abs() < 1e-12);
        assert!(splat_ir.cov_det() > splat_uv.cov_det());
        assert!(
            (splat_ir.core_bohm_potential(1.0, 1.0)
                - (1.0 / (lam_rg * lam_rg)) * splat_uv.core_bohm_potential(1.0, 1.0))
            .abs()
                < 1e-12
        );

        // 6. rGO-polyCBD-SS-Lignin ENZ & Hyperbolic Metamaterial Regimes + TNSA/sCO2 Ledger
        let hmm = RgoPolyCbdHyperbolicMetamaterial {
            eps_d: 2.82,
            abs_eps_m: 110.0,
        };
        let f_enz = hmm.critical_enz_fill_fraction();
        let f_pole = hmm.perpendicular_pole_fill_fraction();
        assert!(((f_enz + f_pole) - 1.0).abs() < 1e-12);
        assert!(f_enz > 0.02 && f_enz < 0.03); // ~2.4995% inZone 1 ENZ horizon
        assert!(hmm.epsilon_parallel(f_enz).abs() < 1e-12);
        assert!(hmm.epsilon_perp(f_enz) > 0.0);

        let f_zone2 = 0.032; // 3.20% rGO in Zone 2 Type-II Hyperbolic SFG Core
        let eps_par_z2 = hmm.epsilon_parallel(f_zone2);
        let eps_perp_z2 = hmm.epsilon_perp(f_zone2);
        assert!(eps_par_z2 < 0.0 && eps_perp_z2 > 0.0 && eps_par_z2 * eps_perp_z2 < 0.0);
        let (rot_par, rot_perp) = hmm.rotated90_tensor(f_zone2);
        assert!(rot_par > 0.0 && rot_perp < 0.0 && rot_par * rot_perp < 0.0);
        let kz_sq = RgoPolyCbdHyperbolicMetamaterial::type2_hyperbolic_kz_sq(
            2.0,
            eps_perp_z2,
            eps_par_z2.abs(),
            5.0,
        );
        assert!(kz_sq > eps_perp_z2 * 4.0);

        let (cp_par, cp_perp) =
            RgoPolyCbdHyperbolicMetamaterial::cold_plasma_tensor(200.0, 400.0, 300.0);
        assert!(cp_par < 0.0 && cp_perp > 1.0 && cp_par * cp_perp < 0.0);
        assert!(RgoPolyCbdHyperbolicMetamaterial::denisov_param(10.0, 1.0, 0.0).abs() < 1e-12);

        let (qe_flat, qe_cone, qe_enz, mdot_sco2, qe_sco2, cap_bus) =
            RgoPolyCbdHyperbolicMetamaterial::tnsa_enz_polycbd_and_sco2_summary();
        assert!((qe_flat - 0.51).abs() < 1e-12 && qe_flat < 1.0);
        assert!((qe_cone - 2.295).abs() < 1e-12);
        assert!((qe_enz - 2.584).abs() < 1e-12 && qe_enz > qe_cone);
        assert!((mdot_sco2 - 182.4).abs() < 1e-12);
        assert!((qe_sco2 - 2.7892).abs() < 1e-12 && qe_sco2 > qe_enz);
        assert!(cap_bus > 12.91 && cap_bus < 12.93);

        // 7. 3-Zone 400->800 GHz SFG & Zone 3 ENZ Detuning Audit
        let audit = RgoPolyCbdHyperbolicMetamaterial::three_zone_sfg_and_enz_audit_summary();
        assert!((audit[0] - (141.0 / 5641.0)).abs() < 1e-12);
        assert!(audit[1] < audit[2]); // eps_perp(400 GHz) < eps_perp(800 GHz) at f = 3.2%
        assert!((audit[3] - (141.0 / 1516.0)).abs() < 1e-12); // ~9.3008%, not 9.88%
        assert!((audit[4].sqrt() - 58.75).abs() < 1e-12);
        assert!(audit[5] < audit[4]); // 9.88% table fill fraction detunes ENZ enhancement
    }

    #[test]
    fn insta_snapshot_polariton_and_spp_summary() {
        let pol = PolaritonHopfieldModel {
            omega_ph: 7.0,
            omega_ex: 4.0,
            rabi_coupling: 2.0,
        };
        let (_, _, d_hop, prod_hop) = pol.gr24_hopfield_invariants(0.25);
        let eps_rest =
            PolaritonHopfieldModel::lyddane_sachs_teller_permittivity(3.0, 4.0, 6.0, 5.0);

        let spp = SurfacePlasmonPolaritonModel {
            eps_d: 2.0,
            abs_eps_m: 6.0,
            wavelength_0: 1.0,
            gamma_spp: 0.5,
            alpha1: 1.0,
            alpha2: 2.0,
        };
        let (wa_spp, wb_spp, ratio_spp, prod_spp) = spp.gr24_spp_invariants(0.25);
        let splat = spp.hotspot_tensor_splat(0.0, 0.0, 5.0, 0.0);

        let summary = format!(
            "polariton(omega_up={:.6}, omega_lp={:.6}, d_hop={:.6}, w_ph={:.6}, w_ex={:.6}, gr24_prod={:.6}, eps_rest={:.6})\n\
             spp_continuum(n_spp_sq={:.6}, chi_spp={:.6}, wa_sq={:.6}, wb_sq={:.6}, skin_ratio={:.6}, gr24_prod={:.6})\n\
             spp_splat(sigma1={:.6}, sigma2={:.6}, cov_det={:.6}, norm_factor={:.6}, bohm_core={:.6})",
            pol.upper_polariton_freq(),
            pol.lower_polariton_freq(),
            d_hop,
            pol.hopfield_photon_weight(),
            pol.hopfield_matter_weight(),
            prod_hop,
            eps_rest,
            spp.effective_index_sq(),
            spp.permittivity_contrast(),
            wa_spp,
            wb_spp,
            ratio_spp,
            prod_spp,
            splat.sigma1,
            splat.sigma2,
            splat.cov_det(),
            splat.norm_factor(),
            splat.core_bohm_potential(1.0, 1.0),
        );
        insta::assert_snapshot!("polariton_and_spp_gr24_ddf_summary", summary);
    }
}
