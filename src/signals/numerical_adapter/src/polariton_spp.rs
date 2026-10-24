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
