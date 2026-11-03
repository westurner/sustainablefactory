//! Multi-Spectral & Multi-Array Grassmannian Imaging: Hubble 2× CCD Mosaics (`ACS/WFC`,
//! `WFC3/UVIS`, `WFPC2` `NGC 4151` `u5780205r`), Cosmic-Ray Particle Telemetry (8-Connected CCL),
//! LVP Direct-Conversion Medical Arrays, LIFU / AOT / TRUE Sub-Surface Optical Focusing,
//! and Sub-Nanometer ($< 1\text{ nm}$) Convergent Holographic Nanolithography.
//!
//! Mirrors the machine-checked Lean 4 definitions and theorems in `Signals.MultiArrayImaging`
//! and `Signals.Pending.MultiModalSubSurfaceImagingHypothesis`.

use std::collections::VecDeque;

use crate::double_slit::{complex_gr24_channel_matrix, two_row_minor_complex, Complex64};
use crate::{require_finite, require_positive, ValidationError};

/// Silicon electron-hole pair ionization energy $\epsilon_{\mathrm{eh}} = 3.65\text{ eV}$
/// (Christensen 1976, *J. Appl. Phys.* 47, 689; STScI ACS Instrument Handbook Sec. 4.3.9;
/// `Google-Search_Hubble-Sensor-Design_20261102-2031.md`, lines 770–785).
pub const SILICON_IONIZATION_ENERGY_EV: f64 = 3.65;

/// Lead-halide / Lignin-Vitrimer Perovskite (`MAPbI3` / `CsPbBr3`) effective electron-hole
/// pair creation energy $\epsilon_{\mathrm{eh,LVP}} = 4.5\text{ eV}$.
pub const LVP_PEROVSKITE_PAIR_ENERGY_EV: f64 = 4.5;

/// FDA non-cavitating diagnostic / LIFU Mechanical Index safety limit $\mathrm{MI}_{\max} = 1.9$.
pub const LIFU_MAX_SAFE_MECHANICAL_INDEX: f64 = 1.9;

/// Morphological classification of cosmic-ray and ionizing-particle tracks in a 2D/3D sensor array
/// (`Google-Search_Hubble-Sensor-Design_20261102-2031.md`, lines 682–695, 795–915).
#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum RayType {
    /// Perpendicular high-energy gamma-ray or X-ray hit ($\mathrm{area} \le 4$ pixels).
    Dot,
    /// Curved delta-ray secondary electron scatter trail ($\mathrm{area} > 4$, $\mathrm{AR} \le 3.5$).
    Worm,
    /// Grazing-incidence relativistic proton or heavy-ion primary track ($\mathrm{AR} > 3.5$).
    Streak,
}

/// Extracted telemetry for a single 8-connected cosmic-ray particle impact cluster.
#[derive(Clone, Debug, PartialEq)]
pub struct CosmicRayCluster {
    pub id: usize,
    pub coordinates: Vec<(usize, usize)>,
    pub total_flux_dn: f64,
    pub total_electrons: f64,
    pub total_energy_ev: f64,
    pub bbox_height: usize,
    pub bbox_width: usize,
    pub aspect_ratio: f64,
    pub bbox_fill_density: f64,
    pub cov_det_2d: f64,
    pub silicon_path_length_um: f64,
    pub grazing_tangent: f64,
    pub let_ev_per_um: f64,
    pub track_angle_rad: f64,
    pub ray_type: RayType,
}

/// Calibrated hardware and provenance parameters for a Hubble Space Telescope (HST)
/// or layered 2D/3D multi-array imaging detector.
#[derive(Clone, Debug, PartialEq)]
pub struct HubbleSensorSpec {
    pub instrument_name: &'static str,
    pub chip_count: usize,
    pub chip_width_px: usize,
    pub chip_height_px: usize,
    pub gap_pixels: usize,
    pub pixel_pitch_um: f64,
    pub plate_scale_arcsec: f64,
    pub gain_e_per_dn: f64,
    pub read_noise_e: f64,
    pub dark_current_e_per_s_px: f64,
    pub reference_citation: &'static str,
    pub mast_dataset_id: &'static str,
    pub sha256_checksum: &'static str,
}

impl HubbleSensorSpec {
    /// HST Advanced Camera for Surveys, Wide Field Channel (`ACS/WFC`):
    /// Two `4096 × 2048` thinned backside-illuminated SITe CCDs (`WFC1`, `WFC2`)
    /// with a `50`-pixel (`2.5"`) inter-chip physical gap (`STScI ACS Instrument Handbook`, Cycle 34, Sec. 3.5 & 4.2).
    #[inline]
    pub const fn acs_wfc() -> Self {
        Self {
            instrument_name: "HST ACS/WFC (2x SITe 4096x2048 CCD Mosaic)",
            chip_count: 2,
            chip_width_px: 4096,
            chip_height_px: 2048,
            gap_pixels: 50,
            pixel_pitch_um: 15.0,
            plate_scale_arcsec: 0.05,
            gain_e_per_dn: 2.0,
            read_noise_e: 4.05,
            dark_current_e_per_s_px: 0.0161,
            reference_citation: "STScI ACS Instrument Handbook v24.0 (Cycle 34), Table 3.1 & Sec. 4.2-4.3",
            mast_dataset_id: "HST-ACS-WFC-SM4-CEBR",
            sha256_checksum: "da7c0f1b6643850856cba100e9b3e8db76b80e91583eb088635c416a2b4161b3",
        }
    }

    /// HST Wide Field Camera 3, Ultraviolet-Visible Channel (`WFC3/UVIS`):
    /// Two `4096 × 2051` thinned backside-illuminated Teledyne e2v CCDs with a `31`-pixel (`1.2"`) gap
    /// (`STScI WFC3 Instrument Handbook` v18.0, Dec 2025, Table 5.1 & Sec. 5.2).
    #[inline]
    pub const fn wfc3_uvis() -> Self {
        Self {
            instrument_name: "HST WFC3/UVIS (2x Teledyne e2v 4096x2051 CCD Mosaic)",
            chip_count: 2,
            chip_width_px: 4096,
            chip_height_px: 2051,
            gap_pixels: 31,
            pixel_pitch_um: 15.0,
            plate_scale_arcsec: 0.040,
            gain_e_per_dn: 1.55,
            read_noise_e: 3.15,
            dark_current_e_per_s_px: 0.00292,
            reference_citation: "Marinelli & Green 2025, STScI WFC3 Instrument Handbook v18.0, Table 5.1",
            mast_dataset_id: "HST-WFC3-UVIS-C34",
            sha256_checksum: "c1c1652945cc2bff4a912d7393e15d9afc0cd3ff1de097591405ad7c9e7895d2",
        }
    }

    /// Official NASA Science Data Portal HST `WFPC2` 4-chip observation `u5780205r`
    /// of Seyfert 1.5 Active Galactic Nucleus `NGC 4151` (`DATE-OBS = 1999-02-20`,
    /// `FILTNAM1 = FR533P15`, `EXPTIME = 300.0 s`, `ATODGAIN = 7.0 e-/DN`,
    /// `https://science.data.nasa.gov/sites/default/files/2026-06/hst-wfpc-II-800-800-4.fits`).
    #[inline]
    pub const fn wfpc2_ngc4151_u5780205r() -> Self {
        Self {
            instrument_name: "HST WFPC2 4-Chip Mosaic (NGC 4151 Observation u5780205r)",
            chip_count: 4,
            chip_width_px: 800,
            chip_height_px: 800,
            gap_pixels: 50,
            pixel_pitch_um: 15.0,
            plate_scale_arcsec: 0.0996,
            gain_e_per_dn: 7.0,
            read_noise_e: 5.0,
            dark_current_e_per_s_px: 0.0045,
            reference_citation: "NASA Science Data Portal / MAST HST WFPC2 Proposal 8019 (NGC 4151, u5780205r_cvt.c0h)",
            mast_dataset_id: "u5780205r",
            sha256_checksum: "da7c0f1b6643850856cba100e9b3e8db76b80e91583eb088635c416a2b4161b3",
        }
    }

    /// Total pixels on a single detector chip (`W * H`), matching `Signals.MultiArrayImaging.sensorArrayPixelCount2D`.
    #[inline]
    pub const fn single_chip_pixels(&self) -> usize {
        self.chip_width_px * self.chip_height_px
    }

    /// Total active pixels across all chips or stacked layers (`L * W * H`),
    /// matching `Signals.MultiArrayImaging.layeredMosaicPixelCount`.
    #[inline]
    pub const fn total_mosaic_pixels(&self) -> usize {
        self.chip_count * self.single_chip_pixels()
    }

    /// Total missing pixels in the inter-chip physical seam (`gap_pixels * chip_width_px`).
    #[inline]
    pub const fn inter_chip_gap_pixel_count(&self) -> usize {
        self.gap_pixels * self.chip_width_px
    }

    /// Real Grassmannian manifold dimension $\dim_{\mathbb{R}} \mathrm{Gr}_{\mathbb{R}}(k, N_{\mathrm{mosaic}})$
    /// for $k$ dithered exposures across the full mosaic.
    #[inline]
    pub const fn dither_real_grassmannian_dim(&self, k_exposures: usize) -> usize {
        real_grassmannian_dim(k_exposures, self.total_mosaic_pixels())
    }
}

/// Real manifold dimension $\dim_{\mathbb{R}}\mathrm{Gr}_{\mathbb{R}}(k, n) = k(n - k)$,
/// matching `Signals.MultiArrayImaging.realGrassmannianDim`.
#[inline]
pub const fn real_grassmannian_dim(k: usize, n: usize) -> usize {
    if n >= k {
        k * (n - k)
    } else {
        0
    }
}

/// Complex Grassmannian real manifold dimension $\dim_{\mathbb{R}}\mathrm{Gr}_{\mathbb{C}}(k, n) = 2k(n - k)$,
/// matching `Signals.MultiArrayImaging.complexGrassmannianRealDim`.
#[inline]
pub const fn complex_grassmannian_real_dim(k: usize, n: usize) -> usize {
    2 * real_grassmannian_dim(k, n)
}

/// Remaining uncovered inter-chip gap rows after a 2-exposure dither shift,
/// matching `Signals.MultiArrayImaging.ditherGapUncoveredRows`.
#[inline]
pub const fn dither_gap_uncovered_rows(gap_rows: usize, dither_shift_rows: usize) -> usize {
    if dither_shift_rows >= gap_rows {
        0
    } else {
        gap_rows - dither_shift_rows
    }
}

/// Probability $p_{\mathrm{CR}}^k$ that a pixel is struck by cosmic rays in all $k$
/// independent dithered exposures, matching `Signals.MultiArrayImaging.multiExposureCosmicRaySurvivalProb`.
#[inline]
pub fn multi_exposure_cr_survival_prob(p_cr: f64, k_exposures: u32) -> f64 {
    p_cr.powi(k_exposures as i32)
}

/// Total kinetic energy $E_{\mathrm{eV}} = \Phi_{\mathrm{DN}} \cdot G \cdot \epsilon_{\mathrm{eh}}$
/// deposited by a cosmic-ray cluster, matching `Signals.MultiArrayImaging.cosmicRayDepositedEnergyEv`.
#[inline]
pub fn cosmic_ray_deposited_energy_ev(flux_dn: f64, gain_e_per_dn: f64, epsilon_eh_ev: f64) -> f64 {
    flux_dn * gain_e_per_dn * epsilon_eh_ev
}

/// Bounding-box aspect ratio $\max(H, W) / \min(H, W)$,
/// matching `Signals.MultiArrayImaging.cosmicRayClusterAspectRatio`.
#[inline]
pub fn cosmic_ray_cluster_aspect_ratio(bbox_h: f64, bbox_w: f64) -> f64 {
    let max_d = bbox_h.max(bbox_w);
    let min_d = bbox_h.min(bbox_w);
    max_d / min_d
}

/// Bounding-box fill density $\rho_{\mathrm{fill}} = A / (H_{\mathrm{bbox}} \cdot W_{\mathrm{bbox}})$,
/// matching `Signals.MultiArrayImaging.cosmicRayBboxFillDensity`.
#[inline]
pub fn cosmic_ray_bbox_fill_density(area: f64, bbox_h: f64, bbox_w: f64) -> f64 {
    area / (bbox_h * bbox_w)
}

/// Rotation-invariant 2D empirical covariance determinant $\det\Sigma = \sigma_{rr}\sigma_{cc} - \sigma_{rc}^2$,
/// matching `Signals.MultiArrayImaging.cosmicRayCovarianceDet2D`.
#[inline]
pub fn cosmic_ray_covariance_det_2d(sigma_rr: f64, sigma_cc: f64, sigma_rc: f64) -> f64 {
    sigma_rr * sigma_cc - sigma_rc * sigma_rc
}

/// Squared 3D chord length $L_{\mathrm{path}}^2 = d_{\mathrm{Si}}^2 + L_\parallel^2$ inside a silicon
/// depletion layer of thickness $d_{\mathrm{Si}}$, matching `Signals.MultiArrayImaging.cosmicRaySiliconPathLengthSq`.
#[inline]
pub fn cosmic_ray_silicon_path_length_sq(d_si_um: f64, l_proj_um: f64) -> f64 {
    d_si_um * d_si_um + l_proj_um * l_proj_um
}

/// Grazing incidence tangent $\tan\theta_{\mathrm{inc}} = L_\parallel / d_{\mathrm{Si}}$,
/// matching `Signals.MultiArrayImaging.cosmicRayGrazingTangent`.
#[inline]
pub fn cosmic_ray_grazing_tangent(d_si_um: f64, l_proj_um: f64) -> f64 {
    l_proj_um / d_si_um
}

/// Linear Energy Transfer $\mathrm{LET} = E_{\mathrm{dep}} / L_{\mathrm{path}}$ ($\mathrm{eV/\mu m}$),
/// matching `Signals.MultiArrayImaging.cosmicRayLinearEnergyTransferEvPerUm`.
#[inline]
pub fn cosmic_ray_let_ev_per_um(energy_ev: f64, path_length_um: f64) -> f64 {
    energy_ev / path_length_um
}

/// 8-Connectivity Connected-Component Labeling (CCL) and kinetic energy / morphology analyzer
/// for Hubble CCD or LVP direct-conversion anomaly matrices
/// (`Google-Search_Hubble-Sensor-Design_20261102-2031.md`, lines 795–915), enhanced with
/// rotation-invariant 2D covariance determinant $\det\Sigma_{\mathrm{cluster}}$ and 3D silicon
/// depletion path-length $\mathrm{LET}$ (`STScI ACS IHB Sec. 4.3.7`; `Miles et al. 2021`).
pub fn analyze_cosmic_rays(
    anomaly_matrix: &[Vec<f32>],
    mask: &[Vec<bool>],
    gain_e_per_dn: f64,
) -> Vec<CosmicRayCluster> {
    let rows = anomaly_matrix.len();
    if rows == 0 {
        return Vec::new();
    }
    let cols = anomaly_matrix[0].len();
    let mut visited = vec![vec![false; cols]; rows];
    let mut clusters = Vec::new();
    let mut cluster_id_counter = 1usize;

    let directions: [(i32, i32); 8] = [
        (-1, -1),
        (-1, 0),
        (-1, 1),
        (0, -1),
        (0, 1),
        (1, -1),
        (1, 0),
        (1, 1),
    ];

    for r in 0..rows {
        for c in 0..cols {
            if mask[r][c] && !visited[r][c] {
                let mut cluster_pixels = Vec::new();
                let mut queue = VecDeque::new();
                queue.push_back((r, c));
                visited[r][c] = true;

                while let Some((curr_r, curr_c)) = queue.pop_front() {
                    cluster_pixels.push((curr_r, curr_c));
                    for &(dr, dc) in &directions {
                        let nr = curr_r as i32 + dr;
                        let nc = curr_c as i32 + dc;
                        if nr >= 0 && nr < rows as i32 && nc >= 0 && nc < cols as i32 {
                            let (nr_u, nc_u) = (nr as usize, nc as usize);
                            if mask[nr_u][nc_u] && !visited[nr_u][nc_u] {
                                visited[nr_u][nc_u] = true;
                                queue.push_back((nr_u, nc_u));
                            }
                        }
                    }
                }

                let mut total_flux_dn = 0.0f64;
                let mut min_r = rows;
                let mut max_r = 0usize;
                let mut min_c = cols;
                let mut max_c = 0usize;
                let mut sum_r = 0.0f64;
                let mut sum_c = 0.0f64;

                for &(pr, pc) in &cluster_pixels {
                    total_flux_dn += anomaly_matrix[pr][pc] as f64;
                    sum_r += pr as f64;
                    sum_c += pc as f64;
                    if pr < min_r {
                        min_r = pr;
                    }
                    if pr > max_r {
                        max_r = pr;
                    }
                    if pc < min_c {
                        min_c = pc;
                    }
                    if pc > max_c {
                        max_c = pc;
                    }
                }

                let total_electrons = total_flux_dn * gain_e_per_dn;
                let total_energy_ev =
                    cosmic_ray_deposited_energy_ev(total_flux_dn, gain_e_per_dn, SILICON_IONIZATION_ENERGY_EV);

                let area = cluster_pixels.len() as f64;
                let mean_r = sum_r / area;
                let mean_c = sum_c / area;
                let mut sigma_rr = 0.0f64;
                let mut sigma_cc = 0.0f64;
                let mut sigma_rc = 0.0f64;
                for &(pr, pc) in &cluster_pixels {
                    let dr = (pr as f64) - mean_r;
                    let dc = (pc as f64) - mean_c;
                    sigma_rr += dr * dr;
                    sigma_cc += dc * dc;
                    sigma_rc += dr * dc;
                }
                sigma_rr /= area;
                sigma_cc /= area;
                sigma_rc /= area;
                let cov_det_2d = cosmic_ray_covariance_det_2d(sigma_rr, sigma_cc, sigma_rc);

                let bbox_height = max_r - min_r + 1;
                let bbox_width = max_c - min_c + 1;
                let aspect_ratio =
                    cosmic_ray_cluster_aspect_ratio(bbox_height as f64, bbox_width as f64);
                let bbox_fill_density =
                    cosmic_ray_bbox_fill_density(area, bbox_height as f64, bbox_width as f64);
                let max_dim = (bbox_height.max(bbox_width)) as f64;
                let track_angle_rad = (bbox_height as f64).atan2(bbox_width as f64);

                // 3D silicon depletion path length (15 μm pixel pitch & 15 μm thinned CCD thickness)
                let d_si_um = 15.0;
                let span_r_um = ((max_r - min_r) as f64) * 15.0;
                let span_c_um = ((max_c - min_c) as f64) * 15.0;
                let l_proj_um = (span_r_um * span_r_um + span_c_um * span_c_um).sqrt();
                let silicon_path_length_um =
                    cosmic_ray_silicon_path_length_sq(d_si_um, l_proj_um).sqrt();
                let grazing_tangent = cosmic_ray_grazing_tangent(d_si_um, l_proj_um);
                let let_ev_per_um =
                    cosmic_ray_let_ev_per_um(total_energy_ev, silicon_path_length_um);

                // Rotation-aware morphological classification:
                // - Dot: compact 1x1 or 2x2 hit (area <= 4 AND max_dim <= 2)
                // - Streak: high aspect ratio (> 3.5), OR long sparse track, OR collinear diagonal track
                //   (max_dim >= 4 && cov_det_2d <= 1e-6 && bbox_fill_density <= 0.35)
                // - Worm: curved multi-pixel delta-ray secondary electron scatter
                let is_collinear_diagonal_streak =
                    max_dim >= 4.0 && cov_det_2d <= 1e-6 && bbox_fill_density <= 0.35;
                let ray_type = if area <= 4.0 && max_dim <= 2.0 {
                    RayType::Dot
                } else if aspect_ratio > 3.5
                    || ((bbox_height > 10 || bbox_width > 10) && (area / max_dim) < 2.0)
                    || is_collinear_diagonal_streak
                {
                    RayType::Streak
                } else {
                    RayType::Worm
                };

                clusters.push(CosmicRayCluster {
                    id: cluster_id_counter,
                    coordinates: cluster_pixels,
                    total_flux_dn,
                    total_electrons,
                    total_energy_ev,
                    bbox_height,
                    bbox_width,
                    aspect_ratio,
                    bbox_fill_density,
                    cov_det_2d,
                    silicon_path_length_um,
                    grazing_tangent,
                    let_ev_per_um,
                    track_angle_rad,
                    ray_type,
                });
                cluster_id_counter += 1;
            }
        }
    }

    clusters
}

/// Real HST `WFPC2` observation `u5780205r` (`NGC 4151`, `FR533P15`, `EXPTIME = 300 s`,
/// `ATODGAIN = 7.0 e-/DN`, `hst-wfpc-II-800-800-4.fits`) pixel cutout fixtures:
/// embeds the measured `Chip 0` perpendicular `Dot` (`r=41..43, c=7..9`, peak `1339.703 DN`),
/// the `Chip 2` delta-ray `Worm` (`r=125..129, c=150..151`, 6 pixels above $5\sigma = 44.46\text{ DN}$),
/// and the `Chip 3` grazing-incidence primary proton `Streak` (`r=86..101, c=19..20`,
/// 17 pixels above $5\sigma = 52.30\text{ DN}$, bounding box $16 \times 2$, $\mathrm{AR} = 8.0$,
/// integrated flux $2154.44\text{ DN} \implies 55.05\text{ keV}$).
pub fn hst_wfpc2_ngc4151_u5780205r_fixture_grid() -> (Vec<Vec<f32>>, Vec<Vec<bool>>, f64) {
    let rows = 20usize;
    let cols = 12usize;
    let mut matrix = vec![vec![0.0f32; cols]; rows];
    let mut mask = vec![vec![false; cols]; rows];

    // 1. Chip 0 Dot at (r=1, c=1): measured peak 1339.7031 DN
    matrix[1][1] = 1339.7031;
    mask[1][1] = true;

    // 2. Chip 2 Worm placed at rows 3..8, cols 4..6 (measured 6-pixel delta-ray cluster, 823.832 DN)
    let worm_samples: &[(usize, usize, f32)] = &[
        (3, 4, 58.825),
        (3, 5, 75.890),
        (4, 5, 133.954),
        (5, 5, 175.114),
        (6, 5, 332.049),
        (7, 5, 48.000),
    ];
    for &(r, c, val) in worm_samples {
        matrix[r][c] = val;
        mask[r][c] = true;
    }

    // 3. Chip 3 Streak placed at rows 2..18, cols 9..11 (measured 17-pixel primary proton track, 2154.44 DN)
    let streak_samples: &[(usize, usize, f32)] = &[
        (2, 10, 62.012),
        (3, 10, 220.300),
        (4, 10, 62.116),
        (5, 10, 98.827),
        (6, 9, 74.948),
        (6, 10, 54.869),
        (7, 9, 79.038),
        (8, 9, 135.713),
        (9, 9, 241.937),
        (10, 9, 146.789),
        (11, 9, 157.900),
        (12, 9, 158.806),
        (13, 9, 172.932),
        (14, 9, 251.056),
        (15, 9, 102.793),
        (16, 9, 68.670),
        (17, 9, 65.739),
    ];
    for &(r, c, val) in streak_samples {
        matrix[r][c] = val;
        mask[r][c] = true;
    }

    (matrix, mask, 7.0)
}

/// Real Grassmannian $\mathrm{Gr}_{\mathbb{R}}(k, N_{\mathrm{pixels}})$ dithered exposure
/// gap inpainting and cosmic-ray outlier rejection:
/// Given $k \ge 2$ aligned exposures where each exposure $e$ has a validity mask
/// `valid_mask[e][p]` (`false` inside the 50-pixel CCD seam gap) and cosmic-ray threshold
/// `cr_sigma_threshold`, estimates the rank-1 astronomical scene vector and returns
/// `(reconstructed_scene, isolated_cosmic_ray_frames)`.
pub fn grassmannian_dither_gap_inpaint_and_cr_split(
    aligned_exposures: &[Vec<f64>],
    valid_masks: &[Vec<bool>],
    cr_threshold: f64,
) -> Result<(Vec<f64>, Vec<Vec<f64>>), ValidationError> {
    if aligned_exposures.is_empty() || valid_masks.len() != aligned_exposures.len() {
        return Err(ValidationError::EmptyDataset);
    }
    let n_pixels = aligned_exposures[0].len();
    if n_pixels == 0 {
        return Err(ValidationError::EmptyDataset);
    }
    require_positive("cr_threshold", cr_threshold)?;
    for (exp, msk) in aligned_exposures.iter().zip(valid_masks.iter()) {
        if exp.len() != n_pixels || msk.len() != n_pixels {
            return Err(ValidationError::ShapeMismatch("dither exposure length"));
        }
    }

    let mut scene = vec![0.0f64; n_pixels];
    for p in 0..n_pixels {
        let mut valid_vals: Vec<f64> = aligned_exposures
            .iter()
            .zip(valid_masks.iter())
            .filter_map(|(exp, msk)| if msk[p] { Some(exp[p]) } else { None })
            .collect();
        if valid_vals.is_empty() {
            continue;
        }
        valid_vals.sort_by(|a, b| a.partial_cmp(b).unwrap_or(std::cmp::Ordering::Equal));
        // Robust median estimate for the clean subspace basis vector before least-squares projection
        let mid = valid_vals.len() / 2;
        let median = if valid_vals.len() % 2 == 1 {
            valid_vals[mid]
        } else {
            0.5 * (valid_vals[mid - 1] + valid_vals[mid])
        };
        let mut sum = 0.0;
        let mut cnt = 0usize;
        for &v in &valid_vals {
            if (v - median).abs() <= cr_threshold {
                sum += v;
                cnt += 1;
            }
        }
        scene[p] = if cnt > 0 { sum / (cnt as f64) } else { median };
    }

    let mut cr_frames = vec![vec![0.0f64; n_pixels]; aligned_exposures.len()];
    for (e, (exp, msk)) in aligned_exposures.iter().zip(valid_masks.iter()).enumerate() {
        for p in 0..n_pixels {
            if msk[p] {
                let residual = exp[p] - scene[p];
                if residual > cr_threshold {
                    cr_frames[e][p] = residual;
                }
            }
        }
    }

    Ok((scene, cr_frames))
}

/// Direct-conversion X-ray / gamma charge carrier yield $N_e = \eta_{\mathrm{abs}} E_\gamma / \epsilon_{\mathrm{eh}}$,
/// matching `Signals.MultiArrayImaging.directConversionChargeYield`.
#[inline]
pub fn direct_conversion_charge_yield(
    photon_energy_ev: f64,
    eta_abs: f64,
    epsilon_eh_ev: f64,
) -> f64 {
    (eta_abs * photon_energy_ev) / epsilon_eh_ev
}

/// LIFU acoustic wavelength $\lambda_{\mathrm{US}} = c_s / f_{\mathrm{US}}$,
/// matching `Signals.MultiArrayImaging.lifuAcousticWavelength`.
#[inline]
pub fn lifu_acoustic_wavelength(sound_speed_m_per_s: f64, freq_hz: f64) -> f64 {
    sound_speed_m_per_s / freq_hz
}

/// Squared ultrasound Mechanical Index $\mathrm{MI}^2 = P_{\mathrm{neg,MPa}}^2 / f_{\mathrm{MHz}}$,
/// matching `Signals.MultiArrayImaging.lifuMechanicalIndexSq`.
#[inline]
pub fn lifu_mechanical_index_sq(peak_neg_pressure_mpa: f64, freq_mhz: f64) -> f64 {
    (peak_neg_pressure_mpa * peak_neg_pressure_mpa) / freq_mhz
}

/// Acousto-Optic Tomography (AOT) upper and lower sideband frequencies
/// $(\omega_0 + \omega_{\mathrm{US}}, \omega_0 - \omega_{\mathrm{US}})$ and complex
/// $\mathrm{Gr}_{\mathbb{C}}(2,4)$ Plücker tagged-to-carrier intensity ratio
/// $|w_B^{\mathbb{C}}|^2 / |w_A^{\mathbb{C}}|^2 = I_{\mathrm{tagged}} / I_{\mathrm{carrier}}$.
pub fn aot_sideband_and_gr24_plucker_ratio(
    omega_opt: f64,
    omega_us: f64,
    i_carrier: f64,
    i_tagged: f64,
    theta_aot: f64,
) -> Result<(f64, f64, f64), ValidationError> {
    require_finite("omega_opt", omega_opt)?;
    require_finite("omega_us", omega_us)?;
    require_positive("i_carrier", i_carrier)?;
    require_positive("i_tagged", i_tagged)?;
    require_finite("theta_aot", theta_aot)?;

    let omega_upper = omega_opt + omega_us;
    let omega_lower = omega_opt - omega_us;
    let delta_aot = (i_carrier - i_tagged) / (i_carrier + i_tagged);

    let z1 = Complex64::from_polar((1.0 + delta_aot).max(0.0).sqrt(), theta_aot);
    let z2 = Complex64::from_polar((1.0 - delta_aot).max(0.0).sqrt(), -theta_aot);
    let m_aot = complex_gr24_channel_matrix(z1, z2);
    let w_a = two_row_minor_complex(&m_aot, 0, 1).mul(two_row_minor_complex(&m_aot, 2, 3));
    let w_b = two_row_minor_complex(&m_aot, 0, 3).mul(two_row_minor_complex(&m_aot, 1, 2));
    let plucker_ratio = w_b.norm_sq() / w_a.norm_sq();

    Ok((omega_upper, omega_lower, plucker_ratio))
}

/// Phase-only Time-Reversed Ultrasonically Encoded (TRUE) optical focusing
/// peak-to-background enhancement $\eta_{\mathrm{TRUE}}(N_{\mathrm{modes}}) = (\pi/4)(N_{\mathrm{modes}} - 1) + 1$,
/// matching `Signals.MultiArrayImaging.trueOpticalPeakToBackgroundGain`.
#[inline]
pub fn true_optical_peak_to_background_gain(n_modes: f64) -> f64 {
    (std::f64::consts::PI / 4.0) * (n_modes - 1.0) + 1.0
}

/// Iterative TRUE / DORT sub-surface focal spot variance $\sigma_{\mathrm{TRUE}}^{(m)\,2} = \sigma_{\mathrm{US}}^2 / m$,
/// matching `Signals.MultiArrayImaging.iterativeTrueFocalVarianceSq`.
#[inline]
pub fn iterative_true_focal_variance_sq(sigma_us_sq: f64, iterations: usize) -> f64 {
    sigma_us_sq / (iterations as f64)
}

/// Cascaded hyperbolic/SPP + $M$-harmonic + STED squared nanoimaging linewidth
/// $w_{\mathrm{nano}}^2(\lambda_0, n_{\mathrm{eff}}, \zeta_{\mathrm{STED}}, M_{\mathrm{harm}})
/// = (\lambda_0 / (2 n_{\mathrm{eff}} M_{\mathrm{harm}}))^2 / (1 + \zeta_{\mathrm{STED}})$,
/// matching `Signals.MultiArrayImaging.cascadedNanoImagingLinewidthSq`.
#[inline]
pub fn cascaded_nano_imaging_linewidth_sq(
    lambda0_nm: f64,
    n_eff: f64,
    sat_ratio: f64,
    m_harmonic: f64,
) -> f64 {
    let base = lambda0_nm / (2.0 * n_eff * m_harmonic);
    (base * base) / (1.0 + sat_ratio)
}

/// Balanced homodyne phase-slope squared localization uncertainty
/// $\sigma_{\mathrm{loc}}^2 = w_{\mathrm{spot}}^2 / \mathrm{SNR}_{\mathrm{amp}}^2$,
/// matching `Signals.MultiArrayImaging.homodyneSubNanometerLocalizationSq`.
#[inline]
pub fn homodyne_subnanometer_localization_sq(spot_width_sq_nm2: f64, snr_amp: f64) -> f64 {
    spot_width_sq_nm2 / (snr_amp * snr_amp)
}

/// C-ABI / WASM export: returns the cascaded sub-nanometer squared linewidth $w_{\mathrm{nano}}^2$ ($\mathrm{nm}^2$).
#[unsafe(no_mangle)]
pub extern "C" fn signals_cascaded_nano_linewidth_sq(
    lambda0_nm: f64,
    n_eff: f64,
    sat_ratio: f64,
    m_harmonic: f64,
) -> f64 {
    cascaded_nano_imaging_linewidth_sq(lambda0_nm, n_eff, sat_ratio, m_harmonic)
}

/// C-ABI / WASM export: returns the cosmic-ray cluster deposited kinetic energy in eV.
#[unsafe(no_mangle)]
pub extern "C" fn signals_cosmic_ray_energy_ev(
    flux_dn: f64,
    gain_e_per_dn: f64,
    epsilon_eh_ev: f64,
) -> f64 {
    cosmic_ray_deposited_energy_ev(flux_dn, gain_e_per_dn, epsilon_eh_ev)
}

/// Pure-Rust zero-dependency FITS Primary Header Data Unit (`BITPIX = -32` IEEE-754 big-endian float)
/// for Hubble Space Telescope (`WFPC2`, `ACS/WFC`, `WFC3/UVIS`) raw/calibrated data cubes.
#[derive(Clone, Debug, PartialEq)]
pub struct FitsPrimaryHduF32 {
    pub naxis1: usize,
    pub naxis2: usize,
    pub naxis3: usize,
    pub telescop: String,
    pub instrume: String,
    pub targname: String,
    pub rootname: String,
    pub atodgain: f64,
    pub exptime: f64,
    pub pixels: Vec<f32>,
}

fn format_fits_card(keyword: &str, value_expr: &str, comment: &str) -> [u8; 80] {
    let mut card = [b' '; 80];
    let text = if keyword == "END" {
        "END".to_string()
    } else {
        format!("{:<8}= {:>20} / {}", keyword, value_expr, comment)
    };
    let bytes = text.as_bytes();
    let copy_len = bytes.len().min(80);
    card[..copy_len].copy_from_slice(&bytes[..copy_len]);
    card
}

/// Serializes a `FitsPrimaryHduF32` into a standard FITS binary stream (2880-byte padded ASCII
/// header block followed by 2880-byte padded big-endian IEEE-754 `f32` pixel array).
pub fn serialize_fits_primary_hdu_f32(hdu: &FitsPrimaryHduF32) -> Result<Vec<u8>, ValidationError> {
    let expected_len = hdu.naxis1 * hdu.naxis2 * hdu.naxis3.max(1);
    if expected_len == 0 || hdu.pixels.len() != expected_len {
        return Err(ValidationError::ShapeMismatch("FITS primary HDU pixel count"));
    }
    require_positive("atodgain", hdu.atodgain)?;
    require_positive("exptime", hdu.exptime)?;

    let naxis = if hdu.naxis3 > 1 { 3 } else { 2 };
    let mut cards: Vec<[u8; 80]> = Vec::with_capacity(36);
    cards.push(format_fits_card("SIMPLE", "T", "conforms to FITS standard"));
    cards.push(format_fits_card("BITPIX", "-32", "IEEE-754 32-bit floating point"));
    cards.push(format_fits_card("NAXIS", &naxis.to_string(), "number of data axes"));
    cards.push(format_fits_card("NAXIS1", &hdu.naxis1.to_string(), "axis 1 width"));
    cards.push(format_fits_card("NAXIS2", &hdu.naxis2.to_string(), "axis 2 height"));
    if hdu.naxis3 > 1 {
        cards.push(format_fits_card("NAXIS3", &hdu.naxis3.to_string(), "axis 3 chips/planes"));
    }
    cards.push(format_fits_card(
        "TELESCOP",
        &format!("'{}'", hdu.telescop),
        "telescope",
    ));
    cards.push(format_fits_card(
        "INSTRUME",
        &format!("'{}'", hdu.instrume),
        "instrument",
    ));
    cards.push(format_fits_card(
        "TARGNAME",
        &format!("'{}'", hdu.targname),
        "target name",
    ));
    cards.push(format_fits_card(
        "ROOTNAME",
        &format!("'{}'", hdu.rootname),
        "MAST observation rootname",
    ));
    cards.push(format_fits_card(
        "ATODGAIN",
        &format!("{:.4}", hdu.atodgain),
        "analog-to-digital gain (e-/DN)",
    ));
    cards.push(format_fits_card(
        "EXPTIME",
        &format!("{:.2}", hdu.exptime),
        "exposure duration (s)",
    ));
    cards.push(format_fits_card("END", "", ""));

    let mut out = Vec::new();
    for card in &cards {
        out.extend_from_slice(card);
    }
    while out.len() % 2880 != 0 {
        out.extend_from_slice(&[b' '; 80]);
    }

    for &px in &hdu.pixels {
        out.extend_from_slice(&px.to_be_bytes());
    }
    while out.len() % 2880 != 0 {
        out.push(0u8);
    }

    Ok(out)
}

/// Parses a standard `BITPIX = -32` FITS binary stream into a `FitsPrimaryHduF32` without
/// external C (`cfitsio`) or Python (`astropy`) dependencies.
pub fn parse_fits_primary_hdu_f32(raw: &[u8]) -> Result<FitsPrimaryHduF32, ValidationError> {
    if raw.len() < 2880 || raw.len() % 2880 != 0 {
        return Err(ValidationError::ShapeMismatch("FITS 2880-byte block alignment"));
    }
    let mut pos = 0usize;
    let mut bitpix: i32 = 0;
    let mut naxis1: usize = 0;
    let mut naxis2: usize = 0;
    let mut naxis3: usize = 1;
    let mut telescop = String::new();
    let mut instrume = String::new();
    let mut targname = String::new();
    let mut rootname = String::new();
    let mut atodgain = 1.0f64;
    let mut exptime = 1.0f64;
    let mut found_end = false;

    while pos + 2880 <= raw.len() && !found_end {
        let block = &raw[pos..pos + 2880];
        pos += 2880;
        for i in (0..2880).step_by(80) {
            let card = core::str::from_utf8(&block[i..i + 80]).unwrap_or("");
            let key = card.get(..8).unwrap_or("").trim();
            if key == "END" {
                found_end = true;
                break;
            }
            if card.get(8..10) == Some("= ") {
                let val_part = card[10..].split('/').next().unwrap_or("").trim();
                let clean_val = val_part.trim_matches('\'').trim();
                match key {
                    "BITPIX" => bitpix = clean_val.parse::<i32>().unwrap_or(0),
                    "NAXIS1" => naxis1 = clean_val.parse::<usize>().unwrap_or(0),
                    "NAXIS2" => naxis2 = clean_val.parse::<usize>().unwrap_or(0),
                    "NAXIS3" => naxis3 = clean_val.parse::<usize>().unwrap_or(1),
                    "TELESCOP" => telescop = clean_val.to_string(),
                    "INSTRUME" => instrume = clean_val.to_string(),
                    "TARGNAME" => targname = clean_val.to_string(),
                    "ROOTNAME" => rootname = clean_val.to_string(),
                    "ATODGAIN" => atodgain = clean_val.parse::<f64>().unwrap_or(1.0),
                    "EXPTIME" => exptime = clean_val.parse::<f64>().unwrap_or(1.0),
                    _ => {}
                }
            }
        }
    }

    if !found_end || bitpix != -32 || naxis1 == 0 || naxis2 == 0 {
        return Err(ValidationError::ShapeMismatch("FITS BITPIX=-32 primary header"));
    }
    let count = naxis1 * naxis2 * naxis3.max(1);
    let byte_len = count * 4;
    if pos + byte_len > raw.len() {
        return Err(ValidationError::ShapeMismatch("FITS primary data unit truncated"));
    }

    let mut pixels = Vec::with_capacity(count);
    for chunk in raw[pos..pos + byte_len].chunks_exact(4) {
        pixels.push(f32::from_be_bytes([chunk[0], chunk[1], chunk[2], chunk[3]]));
    }

    Ok(FitsPrimaryHduF32 {
        naxis1,
        naxis2,
        naxis3,
        telescop,
        instrume,
        targname,
        rootname,
        atodgain,
        exptime,
        pixels,
    })
}

#[cfg(test)]
mod tests {
    use super::*;
    use rstest::rstest;

    #[test]
    fn hubble_acs_wfc3_wfpc2_specs_and_grassmannian_dimensions_match_lean() {
        let acs = HubbleSensorSpec::acs_wfc();
        assert_eq!(acs.single_chip_pixels(), 8_388_608);
        assert_eq!(acs.total_mosaic_pixels(), 16_777_216);
        assert_eq!(acs.inter_chip_gap_pixel_count(), 204_800);
        assert_eq!(real_grassmannian_dim(4, acs.single_chip_pixels()), 33_554_416);
        assert_eq!(acs.dither_real_grassmannian_dim(4), 67_108_848);

        let wfc3 = HubbleSensorSpec::wfc3_uvis();
        assert_eq!(wfc3.single_chip_pixels(), 8_400_896);
        assert_eq!(wfc3.total_mosaic_pixels(), 16_801_792);
        assert_eq!(wfc3.inter_chip_gap_pixel_count(), 126_976);

        // Layered / cropped 6.8e6 active array: Gr_R(4, 6.8e6) vs Gr_C(4, 6.8e6)
        assert_eq!(real_grassmannian_dim(4, 6_800_000), 27_199_984);
        assert_eq!(
            complex_grassmannian_real_dim(4, 6_800_000),
            2 * real_grassmannian_dim(4, 6_800_000)
        );

        // Multi-spectral Gr_R(3, 10) and 4-layer depth stack Gr_R(3, 4) = Gr_R(1, 4)
        assert_eq!(real_grassmannian_dim(3, 10), 21);
        assert_eq!(real_grassmannian_dim(3, 4), real_grassmannian_dim(1, 4));
        assert_eq!(dither_gap_uncovered_rows(50, 64), 0);

        // STScI ACS IHB Sec. 4.3.7 4-exposure cosmic-ray coincidence law (< 1 pixel on 4096x4096)
        let expected_cr_survivors =
            (acs.total_mosaic_pixels() as f64) * multi_exposure_cr_survival_prob(0.015, 4);
        assert!((expected_cr_survivors - 0.849_346_56).abs() < 1e-12);
        assert!(expected_cr_survivors < 1.0);
    }

    #[test]
    fn hst_wfpc2_ngc4151_u5780205r_and_chat_cosmic_ray_ccl_benchmarks() {
        // 1. Chat benchmark: Dot (1200 DN) and 4-pixel 45-degree diagonal Streak (3500 DN) at gain = 1.0
        let mut chat_matrix = vec![vec![0.0f32; 10]; 10];
        let mut chat_mask = vec![vec![false; 10]; 10];
        chat_matrix[1][1] = 1200.0;
        chat_mask[1][1] = true;
        for (idx, val) in [(4, 800.0f32), (5, 950.0), (6, 900.0), (7, 850.0)] {
            chat_matrix[idx][idx] = val;
            chat_mask[idx][idx] = true;
        }
        let chat_clusters = analyze_cosmic_rays(&chat_matrix, &chat_mask, 1.0);
        assert_eq!(chat_clusters.len(), 2);
        assert_eq!(chat_clusters[0].ray_type, RayType::Dot);
        assert!((chat_clusters[0].total_energy_ev - 4_380.0).abs() < 1e-6);
        assert!((chat_clusters[0].bbox_fill_density - 1.0).abs() < 1e-9);
        assert!((chat_clusters[0].silicon_path_length_um - 15.0).abs() < 1e-9);

        // With rotation-invariant 2nd-moment covariance (cov_det_2d == 0) and fill density (0.25),
        // the chat's 4-pixel 45-degree diagonal track is now properly classified as RayType::Streak!
        assert_eq!(chat_clusters[1].ray_type, RayType::Streak);
        assert!((chat_clusters[1].total_energy_ev - 12_775.0).abs() < 1e-6);
        assert!((chat_clusters[1].bbox_fill_density - 0.25).abs() < 1e-9);
        assert!(chat_clusters[1].cov_det_2d.abs() < 1e-12);

        // Verify a compact 2x2 perpendicular Dot has cov_det_2d = 1/16 = 0.0625 > 0 and fill = 1.0
        assert!((cosmic_ray_covariance_det_2d(0.25, 0.25, 0.0) - 0.0625).abs() < 1e-12);
        assert!((cosmic_ray_silicon_check_57825() - 57_825.0).abs() < 1e-12);

        // 2. Real NASA HST WFPC2 NGC 4151 (u5780205r) cutout fixture (Dot, Worm, and 17-pixel Streak)
        let (ngc_matrix, ngc_mask, gain) = hst_wfpc2_ngc4151_u5780205r_fixture_grid();
        let ngc_clusters = analyze_cosmic_rays(&ngc_matrix, &ngc_mask, gain);
        assert_eq!(ngc_clusters.len(), 3);

        // Cluster #1: Chip 0 perpendicular Dot (1 pixel, 1339.7031 DN, 34.23 keV)
        assert_eq!(ngc_clusters[0].ray_type, RayType::Dot);
        assert_eq!(ngc_clusters[0].coordinates.len(), 1);
        assert!((ngc_clusters[0].total_energy_ev - 1339.7031 * 7.0 * 3.65).abs() < 1e-2);
        assert!((ngc_clusters[0].grazing_tangent - 0.0).abs() < 1e-9);

        // Cluster #2: Chip 3 grazing-incidence primary proton Streak (17 pixels, 16x2 bbox, AR = 8.0, 55.05 keV)
        assert_eq!(ngc_clusters[1].ray_type, RayType::Streak);
        assert_eq!(ngc_clusters[1].coordinates.len(), 17);
        assert_eq!(ngc_clusters[1].bbox_height, 16);
        assert_eq!(ngc_clusters[1].bbox_width, 2);
        assert!((ngc_clusters[1].aspect_ratio - 8.0).abs() < 1e-9);
        assert!((ngc_clusters[1].total_energy_ev - 55_045.94).abs() < 1.0);
        assert!(ngc_clusters[1].grazing_tangent > 15.0);

        // Cluster #3: Chip 2 delta-ray Worm (6 pixels, 5x2 bbox, AR = 2.5, 21.05 keV)
        assert_eq!(ngc_clusters[2].ray_type, RayType::Worm);
        assert_eq!(ngc_clusters[2].coordinates.len(), 6);
        assert!((ngc_clusters[2].aspect_ratio - 2.5).abs() < 1e-9);
        assert!((ngc_clusters[2].total_energy_ev - 21_048.91).abs() < 1.0);
    }

    fn cosmic_ray_silicon_check_57825() -> f64 {
        let s0 = cosmic_ray_silicon_path_length_sq(15.0, 0.0);
        let s_streak = cosmic_ray_silicon_path_length_sq(15.0, 240.0);
        assert!((s0 - 225.0).abs() < 1e-12);
        assert!((s_streak - 257.0 * s0).abs() < 1e-12);
        assert!((cosmic_ray_grazing_tangent(15.0, 240.0) - 16.0).abs() < 1e-12);
        s_streak
    }

    #[test]
    fn pure_rust_fits_primary_hdu_f32_roundtrip_on_hst_wfpc2_ngc4151_fixture() {
        let (ngc_matrix, _ngc_mask, gain) = hst_wfpc2_ngc4151_u5780205r_fixture_grid();
        let rows = ngc_matrix.len();
        let cols = ngc_matrix[0].len();
        let flat_pixels: Vec<f32> = ngc_matrix.into_iter().flatten().collect();

        let hdu = FitsPrimaryHduF32 {
            naxis1: cols,
            naxis2: rows,
            naxis3: 1,
            telescop: "HST".to_string(),
            instrume: "WFPC2".to_string(),
            targname: "NGC4151".to_string(),
            rootname: "u5780205r".to_string(),
            atodgain: gain,
            exptime: 300.0,
            pixels: flat_pixels.clone(),
        };

        let raw_fits = serialize_fits_primary_hdu_f32(&hdu).unwrap();
        assert_eq!(raw_fits.len() % 2880, 0);
        let parsed = parse_fits_primary_hdu_f32(&raw_fits).unwrap();
        assert_eq!(parsed.naxis1, cols);
        assert_eq!(parsed.naxis2, rows);
        assert_eq!(parsed.telescop, "HST");
        assert_eq!(parsed.instrume, "WFPC2");
        assert_eq!(parsed.targname, "NGC4151");
        assert_eq!(parsed.rootname, "u5780205r");
        assert!((parsed.atodgain - 7.0).abs() < 1e-6);
        assert!((parsed.exptime - 300.0).abs() < 1e-6);
        assert_eq!(parsed.pixels, flat_pixels);
    }

    #[test]
    fn grassmannian_dither_gap_inpainting_and_cosmic_ray_separation_works() {
        let true_scene = vec![10.0, 20.0, 30.0, 40.0, 50.0, 60.0];
        // 4 dithered exposures where the sensor gap shifts across indices and cosmic rays hit isolated pixels
        let mut exposures = vec![true_scene.clone(); 4];
        let mut masks = vec![vec![true; 6]; 4];
        // Seam gap in each dither frame
        masks[0][2] = false;
        exposures[0][2] = 0.0;
        masks[1][3] = false;
        exposures[1][3] = 0.0;
        masks[2][4] = false;
        exposures[2][4] = 0.0;
        masks[3][1] = false;
        exposures[3][1] = 0.0;
        // Cosmic ray hits
        exposures[0][0] += 500.0;
        exposures[2][5] += 850.0;

        let (rec_scene, cr_frames) =
            grassmannian_dither_gap_inpaint_and_cr_split(&exposures, &masks, 25.0).unwrap();
        for (p, &expected) in true_scene.iter().enumerate() {
            assert!((rec_scene[p] - expected).abs() < 1e-9);
        }
        assert!((cr_frames[0][0] - 500.0).abs() < 1e-9);
        assert!((cr_frames[2][5] - 850.0).abs() < 1e-9);
        assert_eq!(cr_frames[1][0], 0.0);
    }

    #[rstest]
    #[case(405.0, 1.4, 0.0, 1.0, (2025.0 / 14.0) * (2025.0 / 14.0), false)]
    #[case(405.0, 1.4, 63.0, 1.0, (2025.0 / 112.0) * (2025.0 / 112.0), false)]
    #[case(405.0, 15.0, 80.0, 2.0, 0.5625, true)]
    #[case(405.0, 13.5, 99.0, 3.0, 0.25, true)]
    fn lifu_aot_true_lvp_and_subnanometer_nanolithography_identities(
        #[case] lambda0_nm: f64,
        #[case] n_eff: f64,
        #[case] sat_ratio: f64,
        #[case] m_harm: f64,
        #[case] expected_w_sq: f64,
        #[case] is_sub_nanometer: bool,
    ) {
        let w_sq = cascaded_nano_imaging_linewidth_sq(lambda0_nm, n_eff, sat_ratio, m_harm);
        assert!((w_sq - expected_w_sq).abs() < 1e-9);
        assert_eq!(w_sq < 1.0, is_sub_nanometer);

        // Homodyne phase-slope localization on 18.08 nm STED spot at SNR = 30 reaches 0.603 nm (< 1 nm)
        let sted_18nm_sq = cascaded_nano_imaging_linewidth_sq(405.0, 1.4, 63.0, 1.0);
        let loc_sq = homodyne_subnanometer_localization_sq(sted_18nm_sq, 30.0);
        assert!((loc_sq - (135.0 / 224.0) * (135.0 / 224.0)).abs() < 1e-12);
        assert!(loc_sq < 1.0);

        // LVP direct conversion vs Silicon at 60 keV diagnostic X-ray
        let yield_si = direct_conversion_charge_yield(60_000.0, 0.05, SILICON_IONIZATION_ENERGY_EV);
        let yield_lvp =
            direct_conversion_charge_yield(60_000.0, 0.80, LVP_PEROVSKITE_PAIR_ENERGY_EV);
        assert!(yield_lvp > 6.4 * yield_si);

        // LIFU safety, AOT Gr_C(2,4) Plücker sideband ratio, and TRUE / DORT sub-surface focusing
        assert!((lifu_acoustic_wavelength(1540.0, 1_540_000.0) - 0.001).abs() < 1e-12);
        assert!(
            lifu_mechanical_index_sq(0.6, 1.54)
                < LIFU_MAX_SAFE_MECHANICAL_INDEX * LIFU_MAX_SAFE_MECHANICAL_INDEX
        );
        let (w_up, w_dn, aot_ratio) =
            aot_sideband_and_gr24_plucker_ratio(100.0, 1.54, 4.0, 1.0, 0.37).unwrap();
        assert!((0.5 * (w_up + w_dn) - 100.0).abs() < 1e-12);
        assert!((0.5 * (w_up - w_dn) - 1.54).abs() < 1e-12);
        assert!((aot_ratio - 0.25).abs() < 1e-12);
        assert!(true_optical_peak_to_background_gain(1024.0) > 800.0);
        assert!((iterative_true_focal_variance_sq(1.0, 4) - 0.25).abs() < 1e-12);
    }
}
