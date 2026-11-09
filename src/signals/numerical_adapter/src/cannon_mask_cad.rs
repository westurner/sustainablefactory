//! Parametric KiCAD v8 (`.kicad_mod`) and IEEE/Calma GDSII Stream v6.0 (`.gds`)
//! Lithography Mask Generator, Binary Parser, and Design-Rule Checker (DRC) for
//! the 3-Zone `rGO-polyCBD-SS-Lignin` Hyperbolic SFG & Denisov Mode-Conversion Lens.
//!
//! This module implements a self-contained, zero-dependency, WASM-compatible CAD
//! synthesis and verification engine in pure Rust:
//! 1. **Open GDSII v6.0 Binary Stream Writer & Round-Trip Reader (`GdsLibrary`)**:
//!    Implements exact IBM System/370 excess-64 hexadecimal 64-bit floating-point
//!    encoding/decoding (`encode_gds_real8` / `decode_gds_real8`), `HEADER`,
//!    `BGNLIB`, `LIBNAME`, `UNITS`, `BGNSTR`, `STRNAME`, `BOUNDARY`, `LAYER`,
//!    `DATATYPE`, `XY` (closed polygon loops in integer nanometers), `ENDEL`,
//!    `ENDSTR`, and `ENDLIB` records, plus a full binary parser (`parse_gdsii_bytes`)
//!    for round-trip verification.
//! 2. **Open KiCAD v8 S-Expression Footprint Exporter (`export_kicad_footprint_str`)**:
//!    Generates a valid `.kicad_mod` footprint with `F.Fab` polygons for Layer 1
//!    azimuthal `polyCBD-CNC` Bragg grating sectors ($q = 1/2$), `F.Cu` polygons
//!    for Layer 2 `rGO-polyCBD-SS-Lignin` Denisov phased-array electrode rings,
//!    and numbered SMD `F.Cu` / `F.Mask` pads for Layer 3 N-LIG disulfide bus contacts.
//! 3. **Audit Fixes Over the Chat Python Prototype (`generate_polycbd_cannon_mask.py`)**:
//!    - Supports both the chat's standing-wave Bragg pitch
//!      $\Lambda_{\mathrm{Bragg}} = \frac{\lambda_0}{2\sin\theta_{\mathrm{Denisov}}}$
//!      (`DenisovPitchMode::BraggBackReflection`, $\approx 1011.61\text{ }\mu\text{m}$)
//!      and the corrected 1st-order forward grating coupler pitch
//!      $\Lambda_{\mathrm{forward}} = \frac{\lambda_0}{\sin\theta_{\mathrm{Denisov}}} = 2\Lambda_{\mathrm{Bragg}}$
//!      (`DenisovPitchMode::ForwardFirstOrder`, $\approx 2023.21\text{ }\mu\text{m}$).
//!    - Computes exact Zone 1 ($400\text{ GHz}$) and Zone 3 ($800\text{ GHz}$) ENZ
//!      fill fractions ($f_{\mathrm{ENZ,400}} = 141/5641 \approx 2.4996\%$ and
//!      $f_{\mathrm{ENZ,800}} = 141/1516 \approx 9.3008\%$, correcting the detuned
//!      $9.88\%$ table value).
//!    - Provides multi-band presets (`FireSuppressionBandPreset`) comparing the
//!      $400 \to 800\text{ GHz}$ SFG design against the true $1.667\text{ GHz}$
//!      $\cdot\mathrm{OH}$ $\Lambda$-doubling hyperfine resonance and the
//!      $915 \to 1830\text{ GHz}$ ($1.83\text{ THz}$) rotational transition.

use std::f64::consts::PI;
use std::fmt::Write as _;
use std::fs;
use std::io;
use std::path::Path;

/// Speed of light in vacuum ($\text{m/s}$).
pub const C_LIGHT_M_S: f64 = 299_792_458.0;

/// GDSII record type constants (Calma GDSII Stream Format v6.0).
pub mod gds_record_type {
    pub const HEADER: u8 = 0x00;
    pub const BGNLIB: u8 = 0x01;
    pub const LIBNAME: u8 = 0x02;
    pub const UNITS: u8 = 0x03;
    pub const ENDLIB: u8 = 0x04;
    pub const BGNSTR: u8 = 0x05;
    pub const STRNAME: u8 = 0x06;
    pub const ENDSTR: u8 = 0x07;
    pub const BOUNDARY: u8 = 0x08;
    pub const LAYER: u8 = 0x0D;
    pub const DATATYPE: u8 = 0x0E;
    pub const XY: u8 = 0x10;
    pub const ENDEL: u8 = 0x11;
}

/// GDSII data type constants.
pub mod gds_data_type {
    pub const NO_DATA: u8 = 0x00;
    pub const INT2: u8 = 0x02;
    pub const INT4: u8 = 0x03;
    pub const REAL8: u8 = 0x05;
    pub const ASCII: u8 = 0x06;
}

/// Selection between the chat's standing-wave Bragg electrode pitch
/// $\Lambda_{\mathrm{Bragg}} = \frac{\lambda_0}{2\sin\theta}$ and the corrected
/// first-order forward diffraction grating coupler pitch
/// $\Lambda_{\mathrm{forward}} = \frac{\lambda_0}{\sin\theta}$.
#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum DenisovPitchMode {
    /// Standing-wave / Bragg back-reflection pitch $\lambda_0 / (2\sin\theta)$,
    /// matching `ProcaCannonMaskSpec.denisov_electrode_pitch_um` in the chat script.
    BraggBackReflection,
    /// First-order forward surface-launch grating coupler pitch $\lambda_0 / \sin\theta$,
    /// matching `Signals.denisovForwardGratingPitch`.
    ForwardFirstOrder,
}

/// Multi-band frequency presets for electromagnetic/acoustic fire-suppression and
/// radical-spectroscopy evaluation.
#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum FireSuppressionBandPreset {
    /// Chat baseline: $400\text{ GHz}$ pump $\to 800\text{ GHz}$ SFG.
    ChatBaseline400To800GHz,
    /// True ground-state $\cdot\mathrm{OH}$ ($X^2\Pi_{3/2}, J=3/2$) $\Lambda$-doubling
    /// hyperfine transition at $1.667\text{ GHz}$ ($18\text{ cm}$ L-band microwave).
    OhLambdaDoubling1667MHz,
    /// Sub-THz / far-IR rotational excitation: $915\text{ GHz}$ pump $\to 1830\text{ GHz}$
    /// ($1.83\text{ THz}$) rotational transition.
    Rotational915To1830GHz,
}

/// Parametric CAD specification for the `rGO-polyCBD-SS-Lignin` Hyperbolic SFG
/// Cannon Lens & Azimuthal Chiral Bragg Grating Mask.
#[derive(Clone, Debug, PartialEq)]
pub struct ProcaCannonMaskSpec {
    pub name: String,
    pub outer_radius_um: f64,
    pub inner_core_radius_um: f64,
    pub bragg_radial_pitch_um: f64,
    pub bragg_duty_cycle: f64,
    pub topological_charge_q: f64,
    pub azimuthal_sectors: usize,
    pub denisov_angle_deg: f64,
    pub pump_freq_ghz: f64,
    pub num_bus_pads: usize,
    pub pad_width_um: f64,
    pub pitch_mode: DenisovPitchMode,
}

impl Default for ProcaCannonMaskSpec {
    fn default() -> Self {
        Self {
            name: "PolyCBD_800GHz_Proca_Lens".to_string(),
            outer_radius_um: 12_000.0,
            inner_core_radius_um: 612.0,
            bragg_radial_pitch_um: 612.0,
            bragg_duty_cycle: 0.50,
            topological_charge_q: 0.5,
            azimuthal_sectors: 36,
            denisov_angle_deg: 21.74,
            pump_freq_ghz: 400.0,
            num_bus_pads: 8,
            pad_width_um: 1_200.0,
            pitch_mode: DenisovPitchMode::BraggBackReflection,
        }
    }
}

impl ProcaCannonMaskSpec {
    /// Construct a preset specification for a chosen frequency band and Denisov pitch mode.
    pub fn from_preset(preset: FireSuppressionBandPreset, pitch_mode: DenisovPitchMode) -> Self {
        match preset {
            FireSuppressionBandPreset::ChatBaseline400To800GHz => Self {
                pitch_mode,
                ..Self::default()
            },
            FireSuppressionBandPreset::OhLambdaDoubling1667MHz => Self {
                name: "PolyCBD_1667MHz_OH_LambdaDoubling_Lens".to_string(),
                outer_radius_um: 180_000.0,
                inner_core_radius_um: 9_000.0,
                bragg_radial_pitch_um: 18_000.0,
                bragg_duty_cycle: 0.50,
                topological_charge_q: 0.5,
                azimuthal_sectors: 36,
                denisov_angle_deg: 21.74,
                pump_freq_ghz: 1.667,
                num_bus_pads: 8,
                pad_width_um: 5_000.0,
                pitch_mode,
            },
            FireSuppressionBandPreset::Rotational915To1830GHz => Self {
                name: "PolyCBD_1830GHz_Rotational_SFG_Lens".to_string(),
                outer_radius_um: 6_000.0,
                inner_core_radius_um: 268.0,
                bragg_radial_pitch_um: 268.0,
                bragg_duty_cycle: 0.50,
                topological_charge_q: 0.5,
                azimuthal_sectors: 36,
                denisov_angle_deg: 21.74,
                pump_freq_ghz: 915.0,
                num_bus_pads: 8,
                pad_width_um: 600.0,
                pitch_mode,
            },
        }
    }

    /// Free-space pump wavelength $\lambda_0 = c / f_{\mathrm{pump}}$ in micrometers ($\mu\text{m}$).
    #[inline]
    pub fn lambda_pump_um(&self) -> f64 {
        (C_LIGHT_M_S / (self.pump_freq_ghz * 1.0e9)) * 1.0e6
    }

    /// Standing-wave Bragg grating pitch $\Lambda_{\mathrm{Bragg}} = \frac{\lambda_0}{2\sin\theta_{\mathrm{Denisov}}}$ in $\mu\text{m}$.
    #[inline]
    pub fn denisov_bragg_pitch_um(&self) -> f64 {
        let sin_theta = self.denisov_angle_deg.to_radians().sin();
        self.lambda_pump_um() / (2.0 * sin_theta)
    }

    /// Corrected 1st-order forward diffraction grating coupler pitch
    /// $\Lambda_{\mathrm{forward}} = \frac{\lambda_0}{\sin\theta_{\mathrm{Denisov}}} = 2\,\Lambda_{\mathrm{Bragg}}$ in $\mu\text{m}$.
    #[inline]
    pub fn denisov_forward_pitch_um(&self) -> f64 {
        let sin_theta = self.denisov_angle_deg.to_radians().sin();
        self.lambda_pump_um() / sin_theta
    }

    /// Active Denisov electrode ring pitch ($\mu\text{m}$) according to `self.pitch_mode`.
    #[inline]
    pub fn active_denisov_electrode_pitch_um(&self) -> f64 {
        match self.pitch_mode {
            DenisovPitchMode::BraggBackReflection => self.denisov_bragg_pitch_um(),
            DenisovPitchMode::ForwardFirstOrder => self.denisov_forward_pitch_um(),
        }
    }

    /// Exact Zone 1 ($400\text{ GHz}$) and Zone 3 ($800\text{ GHz}$) critical ENZ
    /// rGO volume fill fractions $(f_{\mathrm{ENZ,400}}, f_{\mathrm{ENZ,800}})$
    /// for $\varepsilon_d = 2.82$, $|\varepsilon_m(400\text{ GHz})| = 110$, and
    /// $|\varepsilon_m(800\text{ GHz})| = 27.5$.
    #[inline]
    pub fn exact_zone1_and_zone3_enz_fill_fractions() -> (f64, f64) {
        let eps_d = 2.82_f64;
        let f_enz_400 = eps_d / (eps_d + 110.0);
        let f_enz_800 = eps_d / (eps_d + 27.5);
        (f_enz_400, f_enz_800)
    }
}

/// A single closed 2D polygon feature on a GDSII / KiCAD mask layer.
#[derive(Clone, Debug, PartialEq)]
pub struct PolygonFeature {
    pub layer: i16,
    pub datatype: i16,
    pub points_um: Vec<(f64, f64)>,
    pub tag: String,
    pub local_director_rad: f64,
}

impl PolygonFeature {
    /// Returns the signed shoelace area of the polygon in $\mu\text{m}^2$.
    pub fn signed_area_um2(&self) -> f64 {
        if self.points_um.len() < 3 {
            return 0.0;
        }
        let mut sum = 0.0;
        for i in 0..self.points_um.len() {
            let (x0, y0) = self.points_um[i];
            let (x1, y1) = self.points_um[(i + 1) % self.points_um.len()];
            sum += x0 * y1 - x1 * y0;
        }
        0.5 * sum
    }
}

/// Design-Rule Check (DRC) and topological verification summary for a generated mask.
#[derive(Clone, Debug, PartialEq)]
pub struct MaskDrcReport {
    pub total_polygons: usize,
    pub layer1_bragg_polygons: usize,
    pub layer2_denisov_polygons: usize,
    pub layer3_pad_polygons: usize,
    pub all_polygons_have_positive_area: bool,
    pub berry_phase_winding_rad: f64,
    pub denisov_bragg_pitch_um: f64,
    pub denisov_forward_pitch_um: f64,
    pub zone1_exact_enz_fill: f64,
    pub zone3_exact_enz_fill: f64,
}

/// Generate all closed polygon features (in $\mu\text{m}$) for Layers 1, 2, and 3:
/// - **Layer 1**: Concentric azimuthal `polyCBD-CNC` Bragg grating sectors ($q = 1/2$)
/// - **Layer 2**: Concentric interdigitated `rGO-polyCBD-SS-Lignin` Denisov electrode rings
/// - **Layer 3**: Perimeter N-LIG disulfide solderless WASM bus contact pads
pub fn generate_mask_polygons(spec: &ProcaCannonMaskSpec) -> Vec<PolygonFeature> {
    let mut features = Vec::new();

    // -----------------------------------------------------------------
    // LAYER 1: Concentric Azimuthal polyCBD-CNC Bragg Rings (q = 1/2)
    // -----------------------------------------------------------------
    let radial_span = (spec.outer_radius_um - spec.inner_core_radius_um).max(0.0);
    let num_bragg_rings = (radial_span / spec.bragg_radial_pitch_um).floor() as usize;
    let ridge_width_um = spec.bragg_radial_pitch_um * spec.bragg_duty_cycle;
    let d_phi = (2.0 * PI) / (spec.azimuthal_sectors as f64);

    for r_idx in 0..num_bragg_rings {
        let r_in = spec.inner_core_radius_um + (r_idx as f64) * spec.bragg_radial_pitch_um;
        let r_out = r_in + ridge_width_um;

        for s_idx in 0..spec.azimuthal_sectors {
            let phi_start = (s_idx as f64) * d_phi;
            let phi_end = phi_start + d_phi * 0.92; // 8% isolation gap between sectors
            let phi_mid = 0.5 * (phi_start + phi_end);

            // Pancharatnam-Berry fast-axis director angle: psi(phi) = q * phi
            let psi_director = spec.topological_charge_q * phi_mid;

            // 4-cornered sheared annular sector tilted by local director modulation
            let shear_um = 0.15 * ridge_width_um * (2.0 * psi_director).cos();
            let p1 = (
                (r_in - shear_um) * phi_start.cos(),
                (r_in - shear_um) * phi_start.sin(),
            );
            let p2 = (
                (r_out - shear_um) * phi_start.cos(),
                (r_out - shear_um) * phi_start.sin(),
            );
            let p3 = (
                (r_out + shear_um) * phi_end.cos(),
                (r_out + shear_um) * phi_end.sin(),
            );
            let p4 = (
                (r_in + shear_um) * phi_end.cos(),
                (r_in + shear_um) * phi_end.sin(),
            );

            features.push(PolygonFeature {
                layer: 1,
                datatype: 0,
                points_um: vec![p1, p2, p3, p4],
                tag: format!("BRAGG_R{r_idx}_S{s_idx}"),
                local_director_rad: psi_director,
            });
        }
    }

    // -----------------------------------------------------------------
    // LAYER 2: rGO-polyCBD-SS-Lignin Denisov Phased-Array Electrode Rings
    // -----------------------------------------------------------------
    let denisov_pitch = spec.active_denisov_electrode_pitch_um();
    let electrode_width_um = 180.0_f64.min(0.4 * denisov_pitch);
    let num_electrodes = (radial_span / denisov_pitch).floor() as usize;
    let arc_steps: usize = 48;

    for e_idx in 0..num_electrodes {
        let r_elec_in = spec.inner_core_radius_um + (e_idx as f64) * denisov_pitch;
        let r_elec_out = r_elec_in + electrode_width_um;

        let gap_offset = if e_idx % 2 == 0 { 0.0 } else { PI };
        let theta_0 = gap_offset + 5.0_f64.to_radians();
        let theta_1 = gap_offset + 2.0 * PI - 5.0_f64.to_radians();

        let mut pts = Vec::with_capacity(2 * (arc_steps + 1));
        for i in 0..=arc_steps {
            let frac = (i as f64) / (arc_steps as f64);
            let ang = theta_0 + (theta_1 - theta_0) * frac;
            pts.push((r_elec_out * ang.cos(), r_elec_out * ang.sin()));
        }
        for i in 0..=arc_steps {
            let frac = (i as f64) / (arc_steps as f64);
            let ang = theta_1 - (theta_1 - theta_0) * frac;
            pts.push((r_elec_in * ang.cos(), r_elec_in * ang.sin()));
        }

        features.push(PolygonFeature {
            layer: 2,
            datatype: 0,
            points_um: pts,
            tag: format!("DENISOV_ELEC_{e_idx}"),
            local_director_rad: 0.0,
        });
    }

    // -----------------------------------------------------------------
    // LAYER 3: Perimeter N-LIG Disulfide Solderless Bus Pads
    // -----------------------------------------------------------------
    let pad_radius = spec.outer_radius_um + 900.0;
    let half_w = spec.pad_width_um / 2.0;
    for pad_idx in 0..spec.num_bus_pads {
        let angle = (pad_idx as f64) * (2.0 * PI / (spec.num_bus_pads as f64));
        let cx = pad_radius * angle.cos();
        let cy = pad_radius * angle.sin();
        let rect = vec![
            (cx - half_w, cy - half_w),
            (cx + half_w, cy - half_w),
            (cx + half_w, cy + half_w),
            (cx - half_w, cy + half_w),
        ];
        features.push(PolygonFeature {
            layer: 3,
            datatype: 0,
            points_um: rect,
            tag: format!("NLIG_PAD_{}", pad_idx + 1),
            local_director_rad: 0.0,
        });
    }

    features
}

/// Run geometric Design-Rule Checks (DRC) and Berry-phase winding verification on a mask.
pub fn verify_mask_drc(spec: &ProcaCannonMaskSpec, features: &[PolygonFeature]) -> MaskDrcReport {
    let layer1_bragg_polygons = features.iter().filter(|f| f.layer == 1).count();
    let layer2_denisov_polygons = features.iter().filter(|f| f.layer == 2).count();
    let layer3_pad_polygons = features.iter().filter(|f| f.layer == 3).count();

    let all_polygons_have_positive_area = features
        .iter()
        .all(|f| f.points_um.len() >= 4 && f.signed_area_um2().abs() > 1e-3);

    let ring0: Vec<&PolygonFeature> = features
        .iter()
        .filter(|f| f.tag.starts_with("BRAGG_R0_"))
        .collect();
    let berry_phase_winding_rad = if ring0.len() >= 2 {
        ring0.last().unwrap().local_director_rad - ring0.first().unwrap().local_director_rad
    } else {
        0.0
    };

    let (zone1_exact_enz_fill, zone3_exact_enz_fill) =
        ProcaCannonMaskSpec::exact_zone1_and_zone3_enz_fill_fractions();

    MaskDrcReport {
        total_polygons: features.len(),
        layer1_bragg_polygons,
        layer2_denisov_polygons,
        layer3_pad_polygons,
        all_polygons_have_positive_area,
        berry_phase_winding_rad,
        denisov_bragg_pitch_um: spec.denisov_bragg_pitch_um(),
        denisov_forward_pitch_um: spec.denisov_forward_pitch_um(),
        zone1_exact_enz_fill,
        zone3_exact_enz_fill,
    }
}

/// Export the parametric mask into a KiCAD v8 S-expression (`.kicad_mod`) string
/// (coordinates converted from $\mu\text{m}$ to $\text{mm}$).
pub fn export_kicad_footprint_str(spec: &ProcaCannonMaskSpec) -> String {
    let features = generate_mask_polygons(spec);
    let mut out = String::with_capacity(features.len() * 160 + 512);

    let ref_y = (spec.outer_radius_um + 2500.0) / 1000.0;
    let _ = writeln!(
        out,
        "(footprint \"{}\" (version 20240108) (generator \"signals_proca_cad_rs\")",
        spec.name
    );
    let _ = writeln!(out, "  (layer \"F.Cu\")");
    let _ = writeln!(
        out,
        "  (descr \"400-to-800 GHz Hyperbolic rGO-polyCBD-SS-Lignin SFG Cannon Lens & Azimuthal Bragg Mask\")"
    );
    let _ = writeln!(out, "  (attr board_only exclude_from_pos_files)");
    let _ = writeln!(
        out,
        "  (fp_text reference \"REF**\" (at 0 -{ref_y:.3}) (layer \"F.SilkS\")"
    );
    let _ = writeln!(out, "    (effects (font (size 1 1) (thickness 0.15)))");
    let _ = writeln!(out, "  )");
    let _ = writeln!(
        out,
        "  (fp_text value \"{}\" (at 0 {ref_y:.3}) (layer \"F.Fab\")",
        spec.name
    );
    let _ = writeln!(out, "    (effects (font (size 1 1) (thickness 0.15)))");
    let _ = writeln!(out, "  )");

    let mut pad_counter = 1usize;
    for feat in &features {
        if feat.layer == 3 {
            let n = feat.points_um.len() as f64;
            let cx: f64 = feat.points_um.iter().map(|p| p.0 / 1000.0).sum::<f64>() / n;
            let cy: f64 = feat.points_um.iter().map(|p| p.1 / 1000.0).sum::<f64>() / n;
            let w_mm = spec.pad_width_um / 1000.0;
            let _ = writeln!(
                out,
                "  (pad \"{pad_counter}\" smd rect (at {cx:.4} {cy:.4}) (size {w_mm:.4} {w_mm:.4}) (layers \"F.Cu\" \"F.Mask\"))"
            );
            pad_counter += 1;
        } else {
            let kicad_layer = if feat.layer == 1 { "F.Fab" } else { "F.Cu" };
            let _ = write!(out, "  (fp_poly (pts");
            for (x_um, y_um) in &feat.points_um {
                let _ = write!(out, " (xy {:.4} {:.4})", x_um / 1000.0, y_um / 1000.0);
            }
            let _ = writeln!(
                out,
                ") (stroke (width 0.01) (type solid)) (fill solid) (layer \"{kicad_layer}\"))"
            );
        }
    }
    let _ = writeln!(out, ")");
    out
}

/// Write the KiCAD v8 footprint (`.kicad_mod`) to `output_path`.
pub fn export_kicad_footprint_file(
    spec: &ProcaCannonMaskSpec,
    output_path: &Path,
) -> io::Result<String> {
    let content = export_kicad_footprint_str(spec);
    fs::write(output_path, content.as_bytes())?;
    Ok(content)
}

/// Encode an IEEE 754 `f64` into GDSII's 8-byte excess-64 hexadecimal floating-point
/// format (`REAL8`, IBM System/370 format: 1 sign bit, 7-bit base-16 exponent biased
/// by 64, and 56-bit normalized mantissa in $[1/16, 1)$).
pub fn encode_gds_real8(value: f64) -> [u8; 8] {
    if value == 0.0 {
        return [0u8; 8];
    }
    let sign_bit: u8 = if value.is_sign_negative() { 0x80 } else { 0x00 };
    let mut abs_val = value.abs();

    // Normalize so that 1/16 <= abs_val < 1.0 in base 16
    let mut exp16: i32 = 64;
    while abs_val >= 1.0 && exp16 < 127 {
        abs_val /= 16.0;
        exp16 += 1;
    }
    while abs_val < (1.0 / 16.0) && exp16 > 0 {
        abs_val *= 16.0;
        exp16 -= 1;
    }

    let mantissa = (abs_val * ((1u64 << 56) as f64)).round() as u64;
    let mut bytes = [0u8; 8];
    bytes[0] = sign_bit | ((exp16 as u8) & 0x7F);
    for i in 1..8 {
        bytes[i] = ((mantissa >> (8 * (7 - i))) & 0xFF) as u8;
    }
    bytes
}

/// Decode a GDSII 8-byte excess-64 hexadecimal float (`REAL8`) back to `f64`.
pub fn decode_gds_real8(bytes: [u8; 8]) -> f64 {
    if bytes == [0u8; 8] {
        return 0.0;
    }
    let negative = (bytes[0] & 0x80) != 0;
    let exp16 = (bytes[0] & 0x7F) as i32 - 64;
    let mut mantissa: u64 = 0;
    for b in &bytes[1..8] {
        mantissa = (mantissa << 8) | (*b as u64);
    }
    let frac = (mantissa as f64) / ((1u64 << 56) as f64);
    let val = frac * 16.0_f64.powi(exp16);
    if negative { -val } else { val }
}

fn push_gds_record(stream: &mut Vec<u8>, record_type: u8, data_type: u8, payload: &[u8]) {
    let length = (4 + payload.len()) as u16;
    stream.extend_from_slice(&length.to_be_bytes());
    stream.push(record_type);
    stream.push(data_type);
    stream.extend_from_slice(payload);
}

fn gds_ascii_padded(text: &str) -> Vec<u8> {
    let mut raw = text.as_bytes().to_vec();
    if raw.len() % 2 == 1 {
        raw.push(0);
    }
    raw
}

/// Export the parametric mask into a binary GDSII v6.0 stream (`Vec<u8>`) with
/// $1\text{ nm}$ database resolution ($1000\text{ database units} = 1\text{ }\mu\text{m}$).
pub fn export_gdsii_bytes(spec: &ProcaCannonMaskSpec) -> (Vec<u8>, usize) {
    let features = generate_mask_polygons(spec);
    let mut stream = Vec::with_capacity(features.len() * 64 + 256);

    // HEADER (0x00, INT2 = version 600)
    push_gds_record(
        &mut stream,
        gds_record_type::HEADER,
        gds_data_type::INT2,
        &600i16.to_be_bytes(),
    );

    // BGNLIB (0x01, 12x INT2 timestamps: 2026-10-03 21:30:00)
    let ts_vals: [i16; 12] = [2026, 10, 3, 21, 30, 0, 2026, 10, 3, 21, 30, 0];
    let mut ts_bytes = Vec::with_capacity(24);
    for v in ts_vals {
        ts_bytes.extend_from_slice(&v.to_be_bytes());
    }
    push_gds_record(
        &mut stream,
        gds_record_type::BGNLIB,
        gds_data_type::INT2,
        &ts_bytes,
    );

    // LIBNAME (0x02, ASCII)
    push_gds_record(
        &mut stream,
        gds_record_type::LIBNAME,
        gds_data_type::ASCII,
        &gds_ascii_padded(&spec.name),
    );

    // UNITS (0x03, two REAL8 values: 1e-3 user unit per db unit = 1 nm/um, 1e-9 m per db unit)
    let mut units_payload = Vec::with_capacity(16);
    units_payload.extend_from_slice(&encode_gds_real8(1.0e-3));
    units_payload.extend_from_slice(&encode_gds_real8(1.0e-9));
    push_gds_record(
        &mut stream,
        gds_record_type::UNITS,
        gds_data_type::REAL8,
        &units_payload,
    );

    // BGNSTR (0x05) + STRNAME (0x06)
    push_gds_record(
        &mut stream,
        gds_record_type::BGNSTR,
        gds_data_type::INT2,
        &ts_bytes,
    );
    push_gds_record(
        &mut stream,
        gds_record_type::STRNAME,
        gds_data_type::ASCII,
        &gds_ascii_padded(&spec.name),
    );

    for feat in &features {
        // Close polygon loop as required by GDSII BOUNDARY specification
        let mut xy_bytes = Vec::with_capacity((feat.points_um.len() + 1) * 8);
        for (x_um, y_um) in feat.points_um.iter().chain(feat.points_um.first()) {
            let x_nm = (x_um * 1000.0).round() as i32;
            let y_nm = (y_um * 1000.0).round() as i32;
            xy_bytes.extend_from_slice(&x_nm.to_be_bytes());
            xy_bytes.extend_from_slice(&y_nm.to_be_bytes());
        }

        push_gds_record(
            &mut stream,
            gds_record_type::BOUNDARY,
            gds_data_type::NO_DATA,
            &[],
        );
        push_gds_record(
            &mut stream,
            gds_record_type::LAYER,
            gds_data_type::INT2,
            &feat.layer.to_be_bytes(),
        );
        push_gds_record(
            &mut stream,
            gds_record_type::DATATYPE,
            gds_data_type::INT2,
            &feat.datatype.to_be_bytes(),
        );
        push_gds_record(
            &mut stream,
            gds_record_type::XY,
            gds_data_type::INT4,
            &xy_bytes,
        );
        push_gds_record(
            &mut stream,
            gds_record_type::ENDEL,
            gds_data_type::NO_DATA,
            &[],
        );
    }

    push_gds_record(
        &mut stream,
        gds_record_type::ENDSTR,
        gds_data_type::NO_DATA,
        &[],
    );
    push_gds_record(
        &mut stream,
        gds_record_type::ENDLIB,
        gds_data_type::NO_DATA,
        &[],
    );

    (stream, features.len())
}

/// Write the binary GDSII mask (`.gds`) to `output_path`.
pub fn export_gdsii_file(spec: &ProcaCannonMaskSpec, output_path: &Path) -> io::Result<usize> {
    let (bytes, count) = export_gdsii_bytes(spec);
    fs::write(output_path, &bytes)?;
    Ok(count)
}

/// Parsed GDSII boundary element recovered by `parse_gdsii_bytes`.
#[derive(Clone, Debug, Eq, PartialEq)]
pub struct ParsedGdsBoundary {
    pub layer: i16,
    pub datatype: i16,
    pub xy_nm: Vec<(i32, i32)>,
}

/// Parsed GDSII library summary recovered by `parse_gdsii_bytes`.
#[derive(Clone, Debug, PartialEq)]
pub struct ParsedGdsLibrary {
    pub version: i16,
    pub lib_name: String,
    pub str_name: String,
    pub user_unit: f64,
    pub db_unit_m: f64,
    pub boundaries: Vec<ParsedGdsBoundary>,
}

/// Parse and validate a binary GDSII stream, verifying record framing, `REAL8`
/// units, and closed polygon loops (`first == last` on every `BOUNDARY`).
pub fn parse_gdsii_bytes(bytes: &[u8]) -> Result<ParsedGdsLibrary, String> {
    let mut cursor = 0usize;
    let mut version: Option<i16> = None;
    let mut lib_name = String::new();
    let mut str_name = String::new();
    let mut user_unit = 0.0;
    let mut db_unit_m = 0.0;
    let mut boundaries = Vec::new();

    let mut in_boundary = false;
    let mut cur_layer: i16 = 0;
    let mut cur_datatype: i16 = 0;
    let mut cur_xy: Vec<(i32, i32)> = Vec::new();
    let mut saw_endlib = false;

    while cursor < bytes.len() {
        if cursor + 4 > bytes.len() {
            return Err("truncated GDSII record header".to_string());
        }
        let rec_len = u16::from_be_bytes([bytes[cursor], bytes[cursor + 1]]) as usize;
        if rec_len < 4 || cursor + rec_len > bytes.len() {
            return Err(format!("invalid GDSII record length {rec_len} at offset {cursor}"));
        }
        let rec_type = bytes[cursor + 2];
        let _data_type = bytes[cursor + 3];
        let payload = &bytes[cursor + 4..cursor + rec_len];
        cursor += rec_len;

        match rec_type {
            gds_record_type::HEADER => {
                if payload.len() != 2 {
                    return Err("invalid HEADER payload length".to_string());
                }
                version = Some(i16::from_be_bytes([payload[0], payload[1]]));
            }
            gds_record_type::LIBNAME => {
                let trimmed = payload.split(|b| *b == 0).next().unwrap_or(payload);
                lib_name = String::from_utf8_lossy(trimmed).into_owned();
            }
            gds_record_type::STRNAME => {
                let trimmed = payload.split(|b| *b == 0).next().unwrap_or(payload);
                str_name = String::from_utf8_lossy(trimmed).into_owned();
            }
            gds_record_type::UNITS => {
                if payload.len() != 16 {
                    return Err("invalid UNITS payload length".to_string());
                }
                let mut u0 = [0u8; 8];
                let mut u1 = [0u8; 8];
                u0.copy_from_slice(&payload[0..8]);
                u1.copy_from_slice(&payload[8..16]);
                user_unit = decode_gds_real8(u0);
                db_unit_m = decode_gds_real8(u1);
            }
            gds_record_type::BOUNDARY => {
                in_boundary = true;
                cur_layer = 0;
                cur_datatype = 0;
                cur_xy.clear();
            }
            gds_record_type::LAYER if in_boundary => {
                if payload.len() != 2 {
                    return Err("invalid LAYER payload".to_string());
                }
                cur_layer = i16::from_be_bytes([payload[0], payload[1]]);
            }
            gds_record_type::DATATYPE if in_boundary => {
                if payload.len() != 2 {
                    return Err("invalid DATATYPE payload".to_string());
                }
                cur_datatype = i16::from_be_bytes([payload[0], payload[1]]);
            }
            gds_record_type::XY if in_boundary => {
                if payload.len() % 8 != 0 || payload.len() < 32 {
                    return Err("invalid XY payload length".to_string());
                }
                for chunk in payload.chunks_exact(8) {
                    let x = i32::from_be_bytes([chunk[0], chunk[1], chunk[2], chunk[3]]);
                    let y = i32::from_be_bytes([chunk[4], chunk[5], chunk[6], chunk[7]]);
                    cur_xy.push((x, y));
                }
            }
            gds_record_type::ENDEL if in_boundary => {
                if cur_xy.first() != cur_xy.last() {
                    return Err("unclosed GDSII BOUNDARY polygon loop".to_string());
                }
                boundaries.push(ParsedGdsBoundary {
                    layer: cur_layer,
                    datatype: cur_datatype,
                    xy_nm: cur_xy.clone(),
                });
                in_boundary = false;
            }
            gds_record_type::ENDLIB => {
                saw_endlib = true;
                break;
            }
            _ => {}
        }
    }

    if !saw_endlib {
        return Err("missing GDSII ENDLIB record".to_string());
    }
    Ok(ParsedGdsLibrary {
        version: version.ok_or_else(|| "missing GDSII HEADER".to_string())?,
        lib_name,
        str_name,
        user_unit,
        db_unit_m,
        boundaries,
    })
}

/// WebAssembly entrypoint: compute the corrected 1st-order forward Denisov surface-launch
/// grating pitch $\Lambda_{\mathrm{forward}} = \lambda_0 / \sin\theta_{\mathrm{Denisov}}$ in $\mu\text{m}$.
#[unsafe(no_mangle)]
pub extern "C" fn wasm_proca_cannon_denisov_forward_pitch_um(
    pump_freq_ghz: f64,
    denisov_angle_deg: f64,
) -> f64 {
    let spec = ProcaCannonMaskSpec {
        pump_freq_ghz,
        denisov_angle_deg,
        ..ProcaCannonMaskSpec::default()
    };
    spec.denisov_forward_pitch_um()
}

/// WebAssembly entrypoint: compute the standing-wave Bragg Denisov pitch
/// $\Lambda_{\mathrm{Bragg}} = \lambda_0 / (2\sin\theta_{\mathrm{Denisov}})$ in $\mu\text{m}$.
#[unsafe(no_mangle)]
pub extern "C" fn wasm_proca_cannon_denisov_bragg_pitch_um(
    pump_freq_ghz: f64,
    denisov_angle_deg: f64,
) -> f64 {
    let spec = ProcaCannonMaskSpec {
        pump_freq_ghz,
        denisov_angle_deg,
        ..ProcaCannonMaskSpec::default()
    };
    spec.denisov_bragg_pitch_um()
}

/// WebAssembly entrypoint: return the total number of polygons generated for a given
/// outer radius ($\mu\text{m}$) and pitch mode (`0` = Bragg, `1` = ForwardFirstOrder).
#[unsafe(no_mangle)]
pub extern "C" fn wasm_proca_cannon_mask_polygon_count(
    outer_radius_um: f64,
    pitch_mode: u32,
) -> u32 {
    let mode = if pitch_mode == 0 {
        DenisovPitchMode::BraggBackReflection
    } else {
        DenisovPitchMode::ForwardFirstOrder
    };
    let spec = ProcaCannonMaskSpec {
        outer_radius_um,
        pitch_mode: mode,
        ..ProcaCannonMaskSpec::default()
    };
    generate_mask_polygons(&spec).len() as u32
}

// =========================================================================
// PART 2: 3D HOLOGRAPHIC CARBON NANOLITHOGRAPHY (405 nm + 532 nm),
//         `.kicad_vol` VOLUMETRIC EDA, & 6-STAGE LINUX RISC-V (CVA6 / IBEX)
// =========================================================================

/// Synthesized carbon / polymer material phases in 3D holographic longitudinal
/// nanolithography (`data/chats/IQ-Sampling-for-Signal-Phase.md`, lines 9875–9965).
#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum CarbonMaterial {
    /// $n$-type Nitrogen-doped Laser-Induced Graphene (`n_lig`, $sp^2$ conductor, Layer 10).
    NLigSp2,
    /// $p$-type Sulfur-doped Laser-Induced Graphene (`s_lig`, complementary logic gate, Layer 11).
    SLigPType,
    /// Wide-bandgap ($5.5\text{ eV}$) $sp^3$ diamond ballistic phonon router & tunneling armor (`sp3_diamond`, Layer 12).
    Sp3DiamondPhononBus,
    /// High-$k$ Oxygen-Functionalized Carbon Nanotube (`o_cnt`) crosstalk shield & Sendust-analogue core (Layer 13).
    OCntHighKShield,
    /// Strained `polyCBD-CNC` chiral Bragg reflector / waveguide ($405\text{ nm}$ / $532\text{ nm}$, Layer 14).
    PolyCbdBraggGrating,
}

impl CarbonMaterial {
    pub fn as_kicad_vol_token(&self) -> &'static str {
        match self {
            Self::NLigSp2 => "n_lig",
            Self::SLigPType => "s_lig",
            Self::Sp3DiamondPhononBus => "sp3_diamond",
            Self::OCntHighKShield => "o_cnt",
            Self::PolyCbdBraggGrating => "polycbd_bragg",
        }
    }

    pub fn gds_layer(&self) -> i16 {
        match self {
            Self::NLigSp2 => 10,
            Self::SLigPType => 11,
            Self::Sp3DiamondPhononBus => 12,
            Self::OCntHighKShield => 13,
            Self::PolyCbdBraggGrating => 14,
        }
    }

    pub fn emmo_class(&self) -> &'static str {
        match self {
            Self::NLigSp2 => "emmo:NitrogenDopedGrapheneSp2",
            Self::SLigPType => "emmo:SulfurDopedGrapheneSp2",
            Self::Sp3DiamondPhononBus => "emmo:CrystallineDiamondSp3",
            Self::OCntHighKShield => "emmo:OxygenFunctionalizedCNT",
            Self::PolyCbdBraggGrating => "emmo:ChiralPolyCBDCarbonate",
        }
    }
}

/// Open-source RISC-V core architectures cloned in `src/` and targeted for
/// $405\text{ nm} / 532\text{ nm}$ carbon-based holographic nanolithography.
#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum RiscVCorePreset {
    /// OpenHW CORE-V `CVA6` (`CV64A60AX` / Ariane, `src/core-v-cores` & `src/cva6-cheri`):
    /// 6-stage (`PC_GEN`, `IF`, `ID`, `ISSUE`, `EX`, `COMMIT`), RV64GC, M/S/U privilege modes,
    /// hardware PTW + ITLB/DTLB (Sv39 MMU) capable of running Linux.
    Cva6Linux6StageRv64gc,
    /// Capabilities-Limited / lowRISC `CHERI-CVA6` (`src/cheri-cva6` & `src/cva6-cheri`):
    /// 6-stage Linux-capable RV64GC + RVY CHERI v0.9.3 (128-bit capability bounds + tag bit
    /// in `core/cheri_unit.sv` for hardware compartmentalization of `ansiblers` / `LayerVirt`).
    CheriCva6Linux6StageRvy,
    /// lowRISC `Ibex` (`src/ibex`): 3-stage (`IF`, `ID_EX`, `WB_LOCKSTEP`) RV32IMCB + CHERIoT
    /// (`rtl/ibex_cheriot_ex.sv`, `rtl/ibex_trvk.sv`) + 1oo2 redundant lockstep comparator
    /// (`rtl/ibex_lockstep.sv`) for the $150\text{ }\mu\text{s}$ SIL-4 MHD switchover controller.
    IbexCheriotLockstep3StageRv32imcb,
}

/// Dual-wavelength $405\text{ nm}$ (longitudinal $E_z$ excitation) + $532\text{ nm}$
/// (helical doughnut $\sigma\cdot\ell = +1$ depletion, Laser Compression Shock, and
/// fiducial alignment) holographic nanolithography specification.
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct HolographicLaserLithoSpec {
    /// Primary longitudinal $E_z$ writing wavelength ($\text{nm}$), nominal $405.0\text{ nm}$.
    pub write_wavelength_nm: f64,
    /// Secondary helical doughnut ($\sigma\cdot\ell = +1$) depletion & LCS wavelength ($\text{nm}$), nominal $532.0\text{ nm}$.
    pub depletion_wavelength_nm: f64,
    /// Immersion objective numerical aperture ($\mathrm{NA}$), nominal $1.4$.
    pub numerical_aperture: f64,
    /// Depletion saturation ratio $\zeta_{532} = I_{532} / I_{\mathrm{sat}} \ge 0$, nominal $63.0$.
    pub sted_saturation_ratio: f64,
    /// Mean refractive index $\bar{n}$ of `polyCBD-SS-Lignin` at $532\text{ nm}$, nominal $1.59$.
    pub polycbd_mean_index: f64,
    /// Normalized metric-squeeze threshold $A_{sp3}$ above which constructive interference
    /// accidentally synthesizes insulating $sp^3$ diamond (`IQ-Sampling-for-Signal-Phase.md`, line 9883).
    pub sp3_diamond_squeeze_threshold: f64,
    /// Maximum orthogonal holographic flashes per block, nominal $12$.
    pub max_orthogonal_flashes: u8,
}

impl Default for HolographicLaserLithoSpec {
    fn default() -> Self {
        Self {
            write_wavelength_nm: 405.0,
            depletion_wavelength_nm: 532.0,
            numerical_aperture: 1.4,
            sted_saturation_ratio: 63.0,
            polycbd_mean_index: 1.59,
            sp3_diamond_squeeze_threshold: 2.0,
            max_orthogonal_flashes: 12,
        }
    }
}

impl HolographicLaserLithoSpec {
    /// Unconstrained Abbe diffraction spot width $w_0 = \frac{\lambda_{405}}{2\,\mathrm{NA}}$ ($\text{nm}$).
    #[inline]
    pub fn abbe_diffraction_linewidth_nm(&self) -> f64 {
        self.write_wavelength_nm / (2.0 * self.numerical_aperture)
    }

    /// Dual-beam $405\text{ nm} + 532\text{ nm}$ STED-depleted feature linewidth
    /// $w_{\mathrm{STED}} = \frac{\lambda_{405}}{2\,\mathrm{NA}\sqrt{1 + \zeta_{532}}}$ ($\text{nm}$),
    /// matching `Signals.stedDepletedLinewidthSq`.
    #[inline]
    pub fn sted_depleted_linewidth_nm(&self) -> f64 {
        self.abbe_diffraction_linewidth_nm() / (1.0 + self.sted_saturation_ratio).sqrt()
    }

    /// $532\text{ nm}$ Laser Compression Shock (LCS) Bragg grating period
    /// $d_{\mathrm{Bragg,532}} = \frac{\lambda_{532}}{2\,\bar{n}}$ ($\text{nm}$).
    #[inline]
    pub fn lcs_green_bragg_pitch_nm(&self) -> f64 {
        self.depletion_wavelength_nm / (2.0 * self.polycbd_mean_index)
    }
}

/// A 3D topological spline in `.kicad_vol` format (`IQ-Sampling-for-Signal-Phase.md`, line 9875).
#[derive(Clone, Debug, PartialEq)]
pub struct VolumetricSpline3D {
    pub id: String,
    pub stage_name: String,
    pub rtl_source: String,
    pub material: CarbonMaterial,
    pub flash_index: u8,
    pub wave_amplitude: f64,
    pub width_nm: f64,
    pub points_um: Vec<(f64, f64, f64)>,
}

/// Volumetric Metric Interference DRC report for a 3D `.kicad_vol` module.
#[derive(Clone, Debug, PartialEq)]
pub struct VolumetricDrcReport {
    pub module_name: String,
    pub pipeline_stages: usize,
    pub total_splines_3d: usize,
    pub total_floorplan_polygons_2d: usize,
    pub abbe_linewidth_nm: f64,
    pub sted_linewidth_nm: f64,
    pub lcs_532_bragg_pitch_nm: f64,
    pub single_flash_over_squeeze_hazards: usize,
    pub orthogonal_multi_flash_hazards: usize,
    pub orthogonal_flashes_used: u8,
}

/// Synthesize the 2D GDSII/KiCAD floorplan polygons and 3D `.kicad_vol` splines for
/// `CVA6` (6-stage Linux RV64GC), `CHERI-CVA6` (6-stage Linux + 128-bit CHERI RVY),
/// or `Ibex` (3-stage CHERIoT + 1oo2 SIL-4 Lockstep).
pub fn generate_riscv_holographic_module(
    preset: RiscVCorePreset,
    litho: &HolographicLaserLithoSpec,
) -> (String, Vec<PolygonFeature>, Vec<VolumetricSpline3D>) {
    let (module_name, stages): (&str, Vec<(&str, &str, f64)>) = match preset {
        RiscVCorePreset::Cva6Linux6StageRv64gc => (
            "CVA6_RV64GC_Linux_6Stage_Carbon_SoC",
            vec![
                ("1_PC_GEN", "core/frontend/bht.sv + btb.sv + ras.sv + instr_realign.sv", 120.0),
                ("2_IF_ITLB_PTW", "core/cache_subsystem + core/cva6_mmu/cva6_tlb.sv + cva6_ptw.sv", 180.0),
                ("3_ID_DECODE", "core/id_stage.sv + decoder.sv + compressed_decoder.sv", 110.0),
                ("4_ISSUE_SCOREBOARD", "core/issue_stage.sv + scoreboard.sv + ariane_regfile_ff.sv", 150.0),
                ("5_EX_ALU_FPU_LSU", "core/ex_stage.sv + alu.sv + mult.sv + cvfpu + load_store_unit.sv", 220.0),
                ("6_COMMIT_CSR_PMP", "core/commit_stage.sv + csr_regfile.sv + store_buffer.sv + pmp/", 140.0),
            ],
        ),
        RiscVCorePreset::CheriCva6Linux6StageRvy => (
            "CHERI_CVA6_RV64GC_RVY_Purecap_6Stage_Carbon_SoC",
            vec![
                ("1_PC_GEN_PCC", "core/frontend/instr_realign.sv (128-bit PCC capability fetch)", 130.0),
                ("2_IF_ITLB_CAP_MMU", "core/cva6_mmu/cva6_tlb.sv + cva6_ptw.sv (Sv39 + Cap Tag bits)", 190.0),
                ("3_ID_CHERI_DECODE", "core/id_stage.sv + decoder.sv + macro_decoder.sv", 120.0),
                ("4_ISSUE_CAP_REGFILE", "core/issue_stage.sv + scoreboard.sv + 32x129-bit Cap Regfile", 170.0),
                ("5_EX_CHERI_ALU_LSU", "core/ex_stage.sv + cheri_unit.sv + load_store_unit.sv + cvfpu", 250.0),
                ("6_COMMIT_CAP_CSR_PMP", "core/commit_stage.sv + csr_regfile.sv + amo_buffer.sv + pmp/", 150.0),
            ],
        ),
        RiscVCorePreset::IbexCheriotLockstep3StageRv32imcb => (
            "Ibex_RV32IMCB_CHERIoT_1oo2_Lockstep_SIL4_SoC",
            vec![
                ("1_IF_PREFETCH_ICACHE", "rtl/ibex_if_stage.sv + ibex_prefetch_buffer.sv + ibex_icache.sv", 90.0),
                ("2_ID_EX_CHERIOT_TRVK", "rtl/ibex_id_stage.sv + ibex_ex_block.sv + ibex_cheriot_ex.sv + ibex_trvk.sv", 130.0),
                ("3_WB_CSR_1OO2_LOCKSTEP", "rtl/ibex_wb_stage.sv + ibex_cs_registers.sv + ibex_pmp.sv + ibex_lockstep.sv", 110.0),
            ],
        ),
    };

    let mut polygons = Vec::new();
    let mut splines = Vec::new();
    let linewidth_nm = litho.sted_depleted_linewidth_nm();

    let mut x_cursor_um = 0.0_f64;
    let stage_height_um = 160.0_f64;
    let stage_gap_um = 18.0_f64;

    for (idx, (stage_label, rtl_ref, width_um)) in stages.iter().enumerate() {
        let x0 = x_cursor_um;
        let x1 = x0 + *width_um;
        let y0 = 0.0;
        let y1 = stage_height_um;

        // 1. N-LIG logic block boundary (Layer 10)
        polygons.push(PolygonFeature {
            layer: CarbonMaterial::NLigSp2.gds_layer(),
            datatype: idx as i16,
            points_um: vec![(x0, y0), (x1, y0), (x1, y1), (x0, y1)],
            tag: format!("STAGE_{stage_label}_NLIG"),
            local_director_rad: 0.0,
        });

        // 2. S-LIG complementary p-type active well inside the stage (Layer 11)
        polygons.push(PolygonFeature {
            layer: CarbonMaterial::SLigPType.gds_layer(),
            datatype: idx as i16,
            points_um: vec![
                (x0 + 10.0, y0 + 20.0),
                (x1 - 10.0, y0 + 20.0),
                (x1 - 10.0, y0 + 70.0),
                (x0 + 10.0, y0 + 70.0),
            ],
            tag: format!("STAGE_{stage_label}_SLIG"),
            local_director_rad: 0.0,
        });

        // 3. sp3 Diamond fractal heat-siphon trunk under the stage (Layer 12)
        polygons.push(PolygonFeature {
            layer: CarbonMaterial::Sp3DiamondPhononBus.gds_layer(),
            datatype: idx as i16,
            points_um: vec![
                (x0 + 5.0, y0 - 15.0),
                (x1 - 5.0, y0 - 15.0),
                (x1 - 5.0, y0 - 5.0),
                (x0 + 5.0, y0 - 5.0),
            ],
            tag: format!("STAGE_{stage_label}_DIAMOND_SIPHON"),
            local_director_rad: 0.0,
        });

        // 4. O-CNT high-k crosstalk isolation trench between stages (Layer 13)
        polygons.push(PolygonFeature {
            layer: CarbonMaterial::OCntHighKShield.gds_layer(),
            datatype: idx as i16,
            points_um: vec![
                (x1 + 2.0, y0 - 10.0),
                (x1 + stage_gap_um - 2.0, y0 - 10.0),
                (x1 + stage_gap_um - 2.0, y1 + 10.0),
                (x1 + 2.0, y1 + 10.0),
            ],
            tag: format!("STAGE_{stage_label}_OCNT_SHIELD"),
            local_director_rad: 0.0,
        });

        // 5. 532 nm LCS polyCBD Bragg optical clock-distribution mirror (Layer 14)
        polygons.push(PolygonFeature {
            layer: CarbonMaterial::PolyCbdBraggGrating.gds_layer(),
            datatype: idx as i16,
            points_um: vec![
                (x0 + 15.0, y1 + 6.0),
                (x1 - 15.0, y1 + 6.0),
                (x1 - 15.0, y1 + 16.0),
                (x0 + 15.0, y1 + 16.0),
            ],
            tag: format!("STAGE_{stage_label}_BRAGG_532NM"),
            local_director_rad: 0.0,
        });

        // 3D `.kicad_vol` splines with Orthogonal Volume Decomposition flash assignment:
        // Alternate odd/even pipeline stages across Flash 1 and Flash 2 so adjacent stage
        // interconnects never constructively interfere above the sp3 diamond threshold!
        let flash_nlig = if idx % 2 == 0 { 1 } else { 2 };
        let z_base_um = 10.0 + (idx as f64) * 2.5;

        splines.push(VolumetricSpline3D {
            id: format!("spline_{stage_label}_nlig_bus"),
            stage_name: (*stage_label).to_string(),
            rtl_source: (*rtl_ref).to_string(),
            material: CarbonMaterial::NLigSp2,
            flash_index: flash_nlig,
            wave_amplitude: 0.80,
            width_nm: linewidth_nm,
            points_um: vec![
                (x0, 0.5 * stage_height_um, z_base_um),
                (0.5 * (x0 + x1), 0.5 * stage_height_um, z_base_um + 4.0),
                (x1 + stage_gap_um, 0.5 * stage_height_um, z_base_um),
            ],
        });

        splines.push(VolumetricSpline3D {
            id: format!("spline_{stage_label}_slig_pn_gate"),
            stage_name: (*stage_label).to_string(),
            rtl_source: (*rtl_ref).to_string(),
            material: CarbonMaterial::SLigPType,
            flash_index: flash_nlig + 2,
            wave_amplitude: 0.78,
            width_nm: linewidth_nm,
            points_um: vec![
                (x0 + 10.0, 45.0, z_base_um + 1.4),
                (x1 - 10.0, 45.0, z_base_um + 1.4),
            ],
        });

        splines.push(VolumetricSpline3D {
            id: format!("spline_{stage_label}_sp3_diamond_tree"),
            stage_name: (*stage_label).to_string(),
            rtl_source: (*rtl_ref).to_string(),
            material: CarbonMaterial::Sp3DiamondPhononBus,
            flash_index: 5,
            wave_amplitude: 1.55,
            width_nm: 45.0,
            points_um: vec![
                (0.5 * (x0 + x1), 0.5 * stage_height_um, z_base_um - 2.0),
                (0.5 * (x0 + x1), -10.0, 2.0),
                (0.5 * (x0 + x1), -25.0, 0.0),
            ],
        });

        splines.push(VolumetricSpline3D {
            id: format!("spline_{stage_label}_ocnt_isolation"),
            stage_name: (*stage_label).to_string(),
            rtl_source: (*rtl_ref).to_string(),
            material: CarbonMaterial::OCntHighKShield,
            flash_index: 6,
            wave_amplitude: 0.65,
            width_nm: 30.0,
            points_um: vec![
                (x1 + 0.5 * stage_gap_um, 0.0, z_base_um - 3.0),
                (x1 + 0.5 * stage_gap_um, stage_height_um, z_base_um + 5.0),
            ],
        });

        x_cursor_um = x1 + stage_gap_um;
    }

    // Add 8 perimeter N-LIG solderless topological docking pads on Layer 3
    for pad_idx in 0..8 {
        let px = (pad_idx as f64) * (x_cursor_um / 8.0) + 20.0;
        let py = -45.0;
        polygons.push(PolygonFeature {
            layer: 3,
            datatype: 0,
            points_um: vec![
                (px - 15.0, py - 15.0),
                (px + 15.0, py - 15.0),
                (px + 15.0, py + 15.0),
                (px - 15.0, py + 15.0),
            ],
            tag: format!("RISCV_IO_PAD_{}", pad_idx + 1),
            local_director_rad: 0.0,
        });
    }

    (module_name.to_string(), polygons, splines)
}

/// Run the `kicad-volumetric` Metric Interference DRC (`IQ-Sampling-for-Signal-Phase.md`,
/// lines 9880–9976), comparing single-flash constructive wave overlap $(A_1 + A_2)^2$
/// against orthogonal multi-flash decomposition across `splines`.
pub fn verify_volumetric_metric_interference_drc(
    module_name: &str,
    pipeline_stages: usize,
    polygons: &[PolygonFeature],
    splines: &[VolumetricSpline3D],
    litho: &HolographicLaserLithoSpec,
) -> VolumetricDrcReport {
    let nlig_splines: Vec<&VolumetricSpline3D> = splines
        .iter()
        .filter(|s| s.material == CarbonMaterial::NLigSp2)
        .collect();

    let mut single_flash_hazards = 0usize;
    let mut multi_flash_hazards = 0usize;

    for i in 0..nlig_splines.len() {
        for j in (i + 1)..nlig_splines.len() {
            let s1 = nlig_splines[i];
            let s2 = nlig_splines[j];
            // Check if consecutive stage splines meet at the stage boundary
            if j == i + 1 {
                let constructive_peak = (s1.wave_amplitude + s2.wave_amplitude).powi(2);
                if constructive_peak >= litho.sp3_diamond_squeeze_threshold {
                    single_flash_hazards += 1;
                    if s1.flash_index == s2.flash_index {
                        multi_flash_hazards += 1;
                    }
                }
            }
        }
    }

    let max_flash = splines.iter().map(|s| s.flash_index).max().unwrap_or(1);

    VolumetricDrcReport {
        module_name: module_name.to_string(),
        pipeline_stages,
        total_splines_3d: splines.len(),
        total_floorplan_polygons_2d: polygons.len(),
        abbe_linewidth_nm: litho.abbe_diffraction_linewidth_nm(),
        sted_linewidth_nm: litho.sted_depleted_linewidth_nm(),
        lcs_532_bragg_pitch_nm: litho.lcs_green_bragg_pitch_nm(),
        single_flash_over_squeeze_hazards: single_flash_hazards,
        orthogonal_multi_flash_hazards: multi_flash_hazards,
        orthogonal_flashes_used: max_flash,
    }
}

/// Export a 3D `.kicad_vol` S-expression file (`IQ-Sampling-for-Signal-Phase.md`, line 9875)
/// encoding the dual-beam $405\text{ nm} / 532\text{ nm}$ optical recipe, orthogonal flash
/// schedule, and 3D topological splines.
pub fn export_kicad_volumetric_str(
    module_name: &str,
    litho: &HolographicLaserLithoSpec,
    splines: &[VolumetricSpline3D],
) -> String {
    let mut out = String::with_capacity(splines.len() * 220 + 512);
    let _ = writeln!(
        out,
        "(kicad_vol (version 20261025) (generator \"signals_kicad_volumetric_rs\")"
    );
    let _ = writeln!(out, "  (module \"{module_name}\")");
    let _ = writeln!(
        out,
        "  (laser_recipe (write_uv_nm {:.1}) (depletion_green_nm {:.1}) (na {:.2}) (sted_sat_ratio {:.1}) (sted_linewidth_nm {:.2}) (lcs_bragg_pitch_nm {:.2}))",
        litho.write_wavelength_nm,
        litho.depletion_wavelength_nm,
        litho.numerical_aperture,
        litho.sted_saturation_ratio,
        litho.sted_depleted_linewidth_nm(),
        litho.lcs_green_bragg_pitch_nm(),
    );
    for s in splines {
        let _ = write!(
            out,
            "  (spline (id \"{}\") (stage \"{}\") (material {}) (flash {}) (width_nm {:.2}) (rtl \"{}\") (points",
            s.id,
            s.stage_name,
            s.material.as_kicad_vol_token(),
            s.flash_index,
            s.width_nm,
            s.rtl_source,
        );
        for (x, y, z) in &s.points_um {
            let _ = write!(out, " (xyz {:.3} {:.3} {:.3})", x, y, z);
        }
        let _ = writeln!(out, "))");
    }
    let _ = writeln!(out, ")");
    out
}

/// Export an arbitrary polygon list (`&[PolygonFeature]`) into a binary GDSII v6.0 stream.
pub fn export_polygons_to_gdsii_bytes(lib_name: &str, features: &[PolygonFeature]) -> Vec<u8> {
    let mut stream = Vec::with_capacity(features.len() * 64 + 256);
    push_gds_record(
        &mut stream,
        gds_record_type::HEADER,
        gds_data_type::INT2,
        &600i16.to_be_bytes(),
    );
    let ts_vals: [i16; 12] = [2026, 10, 25, 6, 0, 0, 2026, 10, 25, 6, 0, 0];
    let mut ts_bytes = Vec::with_capacity(24);
    for v in ts_vals {
        ts_bytes.extend_from_slice(&v.to_be_bytes());
    }
    push_gds_record(
        &mut stream,
        gds_record_type::BGNLIB,
        gds_data_type::INT2,
        &ts_bytes,
    );
    push_gds_record(
        &mut stream,
        gds_record_type::LIBNAME,
        gds_data_type::ASCII,
        &gds_ascii_padded(lib_name),
    );
    let mut units_payload = Vec::with_capacity(16);
    units_payload.extend_from_slice(&encode_gds_real8(1.0e-3));
    units_payload.extend_from_slice(&encode_gds_real8(1.0e-9));
    push_gds_record(
        &mut stream,
        gds_record_type::UNITS,
        gds_data_type::REAL8,
        &units_payload,
    );
    push_gds_record(
        &mut stream,
        gds_record_type::BGNSTR,
        gds_data_type::INT2,
        &ts_bytes,
    );
    push_gds_record(
        &mut stream,
        gds_record_type::STRNAME,
        gds_data_type::ASCII,
        &gds_ascii_padded(lib_name),
    );

    for feat in features {
        let mut xy_bytes = Vec::with_capacity((feat.points_um.len() + 1) * 8);
        for (x_um, y_um) in feat.points_um.iter().chain(feat.points_um.first()) {
            let x_nm = (x_um * 1000.0).round() as i32;
            let y_nm = (y_um * 1000.0).round() as i32;
            xy_bytes.extend_from_slice(&x_nm.to_be_bytes());
            xy_bytes.extend_from_slice(&y_nm.to_be_bytes());
        }
        push_gds_record(&mut stream, gds_record_type::BOUNDARY, gds_data_type::NO_DATA, &[]);
        push_gds_record(
            &mut stream,
            gds_record_type::LAYER,
            gds_data_type::INT2,
            &feat.layer.to_be_bytes(),
        );
        push_gds_record(
            &mut stream,
            gds_record_type::DATATYPE,
            gds_data_type::INT2,
            &feat.datatype.to_be_bytes(),
        );
        push_gds_record(&mut stream, gds_record_type::XY, gds_data_type::INT4, &xy_bytes);
        push_gds_record(&mut stream, gds_record_type::ENDEL, gds_data_type::NO_DATA, &[]);
    }

    push_gds_record(&mut stream, gds_record_type::ENDSTR, gds_data_type::NO_DATA, &[]);
    push_gds_record(&mut stream, gds_record_type::ENDLIB, gds_data_type::NO_DATA, &[]);
    stream
}

/// Export an IOF / EMMO / W3C PROV-O / QUDT Cryptographic Bill of Materials (CBOM)
/// in YAML-LD format (`IQ-Sampling-for-Signal-Phase.md`, lines 12048–12115).
pub fn export_iof_prov_cbom_yaml_ld(
    module_name: &str,
    litho: &HolographicLaserLithoSpec,
    splines: &[VolumetricSpline3D],
) -> String {
    let mut out = String::with_capacity(1024);
    let _ = writeln!(out, "# {module_name}_CBOM.yaml-ld");
    let _ = writeln!(out, "\"@context\":");
    let _ = writeln!(
        out,
        "  iof: \"https://spec.industrialontologies.org/ontology/core/Core/\""
    );
    let _ = writeln!(out, "  emmo: \"http://emmo.info/emmo#\"");
    let _ = writeln!(out, "  prov: \"http://www.w3.org/ns/prov#\"");
    let _ = writeln!(out, "  qudt: \"http://qudt.org/schema/qudt/\"");
    let _ = writeln!(out, "  ligno: \"https://lignolux.github.io/schema#\"");
    let _ = writeln!(out, "\"@id\": \"ligno:{module_name}\"");
    let _ = writeln!(out, "\"@type\": [\"iof:MaterialArtifact\", \"prov:Entity\"]");
    let _ = writeln!(
        out,
        "prov:wasInformedBy: \"Signals.holographic_405_532_nanolithography_kicad_vol_and_cva6_pipeline_identities\""
    );
    let _ = writeln!(out, "ligno:opticalRecipe:");
    let _ = writeln!(out, "  writeWavelengthNm: {:.1}", litho.write_wavelength_nm);
    let _ = writeln!(
        out,
        "  depletionWavelengthNm: {:.1}",
        litho.depletion_wavelength_nm
    );
    let _ = writeln!(
        out,
        "  stedDepletedLinewidthNm: {:.2}",
        litho.sted_depleted_linewidth_nm()
    );
    let _ = writeln!(out, "  cooling_delay_ms: 15.0");
    let _ = writeln!(out, "iof:hasProcessFunction:");
    for s in splines.iter().take(6) {
        let _ = writeln!(out, "  - \"@id\": \"ligno:{}\"", s.id);
        let _ = writeln!(
            out,
            "    \"@type\": [\"iof:ManufacturingOperation\", \"prov:Activity\"]"
        );
        let _ = writeln!(out, "    ligno:flashIndex: {}", s.flash_index);
        let _ = writeln!(out, "    ligno:stage: \"{}\"", s.stage_name);
        let _ = writeln!(out, "    iof:yields: \"{}\"", s.material.emmo_class());
    }
    out
}

// =========================================================================
// PART 3: SEMI-DIRAC FERMION ENGINEERING & QUANTUM APPLICATIONS (1-4)
//         & PHASE-VARYING LASING OF CARBON-BASED QUDITS IN KICAD / GDSII
// =========================================================================

/// The 4 Semi-Dirac Fermion Engineering & Quantum Application presets from
/// Section 3.1 of `docs/grassmannian-semi-dirac-fermions-ddf-paper.md`, synthesized
/// via $405\text{ nm} / 532\text{ nm}$ strain-engineered holographic nanolithography
/// and phase-varying lasing for carbon-based qudits.
#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum SemiDiracApplicationPreset {
    /// **Application 1**: Ballistic Directional Klein Diode & Dual-Gate Transistor
    /// ($T_y = 1$ massless $\hat{y}$ ballistic interconnect vs. $T_x = 1/(1 + (\kappa_x L)^2) = 1/101$
    /// massive $\hat{x}$ WKB gate pinch-off at $w_{\mathrm{STED}} = 18.08\text{ nm}$).
    BallisticKleinDiodeTransistor,
    /// **Application 2**: Lithography-Free In-Plane Hyperbolic Polariton & $400\text{–}800\text{ GHz}$
    /// Polarization-Sensitive THz Bolometer ($\varepsilon_{xx} = 3/4 > 0, \varepsilon_{yy} = -3 < 0$,
    /// $\tan^2\theta_{\mathrm{canal}} = 1/4$, polarization contrast $\mathcal{C}_{\mathrm{THz}} = 9/11$).
    HyperbolicThzBolometer,
    /// **Application 3**: Orthogonal-Axis Thermoelectric Energy Harvester ($ZT$ Enhancement)
    /// (decoupling heavy $m_x^*$ Seebeck thermopower $S_{yy}$ and phonon blocking $\kappa_{\mathrm{ph},xx}$
    /// from massless $\hat{y}$ high electrical conductivity $\sigma_{yy}$ with $sp^3$ diamond heat sinks).
    OrthogonalThermoelectricHarvester,
    /// **Application 4**: Etch-Free 1D Topological Majorana ($\mathrm{MZM}$), $\mathbb{Z}_6$
    /// Parafermion ($d=6$), $\mathrm{Gr}_{\mathbb{C}}(2,6)$ Plücker ($d=15$), and Phase-Steered
    /// 3D Helical `N-LIG` OAM ($d=100$) Carbon Qudit Waveguide Bus ($v_{g,x}(0, m_x^*) = 0$,
    /// $100\times$ sidewall $D_{\mathrm{it}}$ suppression vs. RIE etching, and $\Delta\Phi(\ell,\phi)=\ell\phi$
    /// phase-varying lasing).
    EtchFreeMajoranaParafermionQuditBus,
    /// **Application 5 (Paper 33)**: Revised Semi-Dirac & $\mathrm{Gr}_{\mathbb{C}}(2,4)/\mathrm{Gr}_{\mathbb{C}}(2,6)$
    /// Soliton Bus with Slow-Light `N-LIG` CROW Delay Line ($n_g = 300 \implies 24\text{ mm}$),
    /// $\mathrm{CO}_2$-Carbonate $5\times$ $\chi^{(3)}$ `CPHASE`/`CNOT` Gate, $C_8$ Star-Via Ancilla Hub,
    /// and Tiered 128-to-64-Bit QNIC RDMA LUT-CORDIC QRAM (`37.5%` PWM 4K Cryo Budget).
    SemiDiracSolitonBusCrowRdmaQram,
    /// **Application 6 (Paper 34)**: Integrated Multi-Band Classical & Quantum Photonics
    /// ($405\text{–}1550\text{ nm}$ & $400\text{–}800\text{ GHz}$) with Periodic $10\text{ m}$ / $100\text{ m}$
    /// Cellulose Nanocrystal (CNC) $\chi^{(2)}$ PSA Signal Boosters ($0\text{ dB}$ NF), $590\text{ nm}$
    /// $n$-Adamantane NV Purcell Dowsing ($F_P \approx 75.99 > 12$), and Inverted 3D Adiabatic
    /// Scarf-Joint $c\text{-BAs}$ Plasmonic-Slot Balanced Homodyne Detector ($\eta = 98.5\%$).
    MultiBand1550nmCncRepeaterCBAsHomodyne,
    /// **Application 7 (Paper 35)**: Laser-Induced $sp^2/sp^3$ Nanodiamond & Teal Carbon Synthesis
    /// ($12\text{ GPa}$ PET Endogenous Oxygen Shock vs. $30\text{ GPa}$ Hydrocarbon, $-\$0.47/\text{kg}$
    /// Methane Pyrolysis Credit), H-Terminated Nanodiamond 2D Hole Gas (`2DHG`) FET (`Walker et al. 2026`),
    /// and Biodegradable `P-CQD` ($590\text{ nm}$, $\tau_{\mathrm{Purcell}} = 100\text{ ps}$) + `Ox-s-CNT`
    /// ($R_{\mathrm{butt}} \approx 0.105\% < 12.15\%$) Replacements for $n$-Adamantane & Toxic $c\text{-BAs}$.
    Nanodiamond2DhgBiodegradableCarbonPhotonics,
    /// **Application 8 (Paper 36)**: 3D Helical `VortexVia` ($\Delta\ell = 1$, $L_{\mathrm{arc}}^2 = h^2 + (2\pi R\Delta\ell)^2$)
    /// & 8-Branch `StarVortexVia` Inter-Layer Interconnects, Second-Harmonic Resonant Optical
    /// Amplification (`Dean et al., Nature 2025`, $21\text{ mW}$ pump, $17.25\text{ dB}$ gain), and
    /// Lignolux Active-Q Modulator (`AQM`) with 4-Wire Kelvin $\sqrt{u_k}$ Heater Linearization + CBF Clamp.
    VortexViaShgOpaAqmInterconnect,
    /// **Application 9 (Paper 37)**: Lignolux Holographic Archival Tape (`LHAT`, $12\text{ }\mu\text{m} \times 10\text{ km}$,
    /// $3{,}000\times$ OAM-Bragg-Polarization Multiplexing, $720\text{ TB}$ Raw / $480\text{ TB}$ Usable vs.
    /// $18\text{ TB}$ LTO-9) with Log-Polar $64\times 64$ Zero-Iteration $O(1)$ Registration and
    /// $182\text{ fs}$ `VACNT` Kapitza Thermal Quench ($\Delta T_{\mathrm{QFT-RK}} = 34.8^\circ\text{C} < 60^\circ\text{C}$).
    LhatHolographicArchivalTapeCartridge,
    /// **Application 10 (Paper 38)**: Pressed / Mask-Locked LLM on Holographic Archival Tape (`LHAT`)
    /// with 1-Trillion-Parameter Passive Optical `MVM` ($W_{ij} \in \{+1, 0, -1\}$ via $\Delta\phi \in \{0, \pi\}$
    /// Bragg Phase Voxels), Soliton/OAM QRAM, and Active `N-LIG`/`B-LIG` LoRA Steering Layer
    /// ($Y_i = \sum_j W_{ij}^{\mathrm{pressed}} X_j + \sum_r A_{ir}^{\mathrm{steer}} B_{rj}^{\mathrm{steer}} X_j$).
    PressedLlmHolographicTapeSolitonQramSteering,
    /// **Application 11 (Paper 39)**: Quantum Causal Next-Concept Modeling (`QCI-NCM`, `arXiv:2610.14162`)
    /// Coarse-to-Fine Parallel LLM Accelerator on Pressed `LHAT` Bragg Tape with Multiscale Residual
    /// VQ Codebook Depth Layers, Plücker/VRC Destructive Constraint Exclusion ($x_X = -1$),
    /// Scale-Selective `N-LIG`/`B-LIG` Coarse/Fine Steering, and OAM-Parallel MBR Decoding.
    QuantumCausalNextConceptPressedLlmAccelerator,
    /// **Application 12 (Paper 40)**: `rGO-Vitrimer` Active Metamaterial (`300-400 nm` Pauli-Blocked
    /// Gires–Tournois Etalon + `4 ns` `A-CNT` Reset), Bistable `Vector Reflect` (`CNS`/`rGO`) &
    /// `rGO-Bio-TPU` Failsafe E-Paper (`25 ms` Video-Rate), Chiral `CNC` `Bio-Bragg` RGB Stack, and
    /// Nanodiamond (`SHG` $590\text{ nm}$ Insect-Blind Amber / RGB + `NV`/`n-Adamantane` ODMR) Quantum Display.
    RgoVitrimerMetamaterialEpaperNanodiamondDisplay,
}

impl SemiDiracApplicationPreset {
    pub fn all() -> [Self; 12] {
        [
            Self::BallisticKleinDiodeTransistor,
            Self::HyperbolicThzBolometer,
            Self::OrthogonalThermoelectricHarvester,
            Self::EtchFreeMajoranaParafermionQuditBus,
            Self::SemiDiracSolitonBusCrowRdmaQram,
            Self::MultiBand1550nmCncRepeaterCBAsHomodyne,
            Self::Nanodiamond2DhgBiodegradableCarbonPhotonics,
            Self::VortexViaShgOpaAqmInterconnect,
            Self::LhatHolographicArchivalTapeCartridge,
            Self::PressedLlmHolographicTapeSolitonQramSteering,
            Self::QuantumCausalNextConceptPressedLlmAccelerator,
            Self::RgoVitrimerMetamaterialEpaperNanodiamondDisplay,
        ]
    }

    pub fn module_name(&self) -> &'static str {
        match self {
            Self::BallisticKleinDiodeTransistor => {
                "SemiDirac_App1_Ballistic_Klein_Diode_Transistor"
            }
            Self::HyperbolicThzBolometer => {
                "SemiDirac_App2_Hyperbolic_400_800GHz_THz_Bolometer"
            }
            Self::OrthogonalThermoelectricHarvester => {
                "SemiDirac_App3_Orthogonal_ZT_Thermoelectric_Harvester"
            }
            Self::EtchFreeMajoranaParafermionQuditBus => {
                "SemiDirac_App4_EtchFree_MZM_Parafermion_OAM_Qudit_Bus"
            }
            Self::SemiDiracSolitonBusCrowRdmaQram => {
                "SolitonBus_SemiDirac_CROW_StarVia_RDMA_QRAM"
            }
            Self::MultiBand1550nmCncRepeaterCBAsHomodyne => {
                "IntegratedPhotonics_MultiBand_1550nm_CNC_Repeater_cBAs_Homodyne"
            }
            Self::Nanodiamond2DhgBiodegradableCarbonPhotonics => {
                "Nanodiamond_2DHG_FET_Biodegradable_PCQD_OxsCNT_Photonics"
            }
            Self::VortexViaShgOpaAqmInterconnect => {
                "VortexVia_StarVortexVia_SHG_OPA_Kelvin_AQM_Interconnect"
            }
            Self::LhatHolographicArchivalTapeCartridge => {
                "LHAT_720TB_Holographic_Archival_Tape_LogPolar_VACNT_Drive"
            }
            Self::PressedLlmHolographicTapeSolitonQramSteering => {
                "Pressed_LLM_1T_LHAT_Tape_Soliton_QRAM_NLIG_BLIG_Steering"
            }
            Self::QuantumCausalNextConceptPressedLlmAccelerator => {
                "QCI_NCM_CoarseToFine_Pressed_LLM_LHAT_Steering"
            }
            Self::RgoVitrimerMetamaterialEpaperNanodiamondDisplay => {
                "RGO_Vitrimer_Active_Metamaterial_EPaper_Nanodiamond_Display"
            }
        }
    }

    pub fn description(&self) -> &'static str {
        match self {
            Self::BallisticKleinDiodeTransistor => {
                "Semi-Dirac App 1: Ballistic Directional Klein Diode & Transistor (T_y=1, R_Klein=101, w_STED=18.08nm)"
            }
            Self::HyperbolicThzBolometer => {
                "Semi-Dirac App 2: Lithography-Free In-Plane Hyperbolic Polariton & 400-800 GHz THz Bolometer (eps_xx=0.75, eps_yy=-3.0)"
            }
            Self::OrthogonalThermoelectricHarvester => {
                "Semi-Dirac App 3: Orthogonal-Axis Thermoelectric ZT Harvester (Heavy m_x* Seebeck S_yy + Massless v_y Conductivity sigma_yy)"
            }
            Self::EtchFreeMajoranaParafermionQuditBus => {
                "Semi-Dirac App 4: Etch-Free 1D MZM, Z6 Parafermion (d=6), Gr_C(2,6) Plucker (d=15) & Phase-Steered Helical N-LIG OAM (d=100) Carbon Qudit Bus"
            }
            Self::SemiDiracSolitonBusCrowRdmaQram => {
                "Paper 33: Revised Semi-Dirac & Gr_C(2,4)/Gr_C(2,6) Soliton Bus with Slow-Light N-LIG CROW Delay, CO2-Carbonate chi^(3) CNOT, C8 Star-Via & 128-to-64b RDMA LUT-CORDIC QRAM"
            }
            Self::MultiBand1550nmCncRepeaterCBAsHomodyne => {
                "Paper 34: Integrated Multi-Band (405-1550nm & 400-800GHz) Photonics with Periodic 10m CNC chi^(2) PSA Signal Boosters, 590nm NV Purcell Dowsing & Adiabatic Scarf-Taper c-BAs Homodyne"
            }
            Self::Nanodiamond2DhgBiodegradableCarbonPhotonics => {
                "Paper 35: Laser-Induced sp2/sp3 Nanodiamond & Teal Carbon, H-Terminated 2DHG FET, and Biodegradable P-CQD (590nm) + Ox-s-CNT (1550nm) Replacements for n-Adamantane & Toxic c-BAs"
            }
            Self::VortexViaShgOpaAqmInterconnect => {
                "Paper 36: 3D Helical VortexVia & 8-Branch StarVortexVia Interconnects, Second-Harmonic Resonant Optical Amplification (Dean et al. Nature 2025), and 4-Wire Kelvin + CBF Active-Q Modulator"
            }
            Self::LhatHolographicArchivalTapeCartridge => {
                "Paper 37: Lignolux Holographic Archival Tape (LHAT 12um x 10km, 720TB Raw / 480TB Usable vs 18TB LTO-9) with Log-Polar O(1) Registration and 182fs VACNT Kapitza Thermal Quench"
            }
            Self::PressedLlmHolographicTapeSolitonQramSteering => {
                "Paper 38: Pressed / Mask-Locked 1T-Parameter LLM on LHAT Holographic Tape with Passive Bragg MVM, Soliton/OAM QRAM, and Active N-LIG/B-LIG LoRA Steering Layer"
            }
            Self::QuantumCausalNextConceptPressedLlmAccelerator => {
                "Paper 39: Quantum Causal Next-Concept Modeling (QCI-NCM, arXiv:2610.14162) Coarse-to-Fine Parallel LLM on Pressed LHAT Tape with VRC Plucker Coupling & Scale-Selective Steering"
            }
            Self::RgoVitrimerMetamaterialEpaperNanodiamondDisplay => {
                "Paper 40: rGO-Vitrimer Active Metamaterial (Pauli-Blocked GTE & 4ns A-CNT Reset), Vector Reflect CNS / rGO-Bio-TPU Failsafe E-Paper, Chiral CNC Bio-Bragg RGB, & Nanodiamond SHG/NV Quantum Display"
            }
        }
    }

    pub fn pin_names(&self) -> [&'static str; 4] {
        match self {
            Self::BallisticKleinDiodeTransistor => ["Y_SOURCE", "Y_DRAIN", "X_GATE_TOP", "GND"],
            Self::HyperbolicThzBolometer => ["THZ_ANT_Y", "IF_READOUT", "LO_REF_X", "GND"],
            Self::OrthogonalThermoelectricHarvester => {
                ["TEG_VOUT_P", "HOT_COLLECTOR", "BIAS_SENSE", "GND"]
            }
            Self::EtchFreeMajoranaParafermionQuditBus => {
                ["QUDIT_BUS_IN", "QUDIT_BUS_OUT", "HOMODYNE_READ", "GND"]
            }
            Self::SemiDiracSolitonBusCrowRdmaQram => {
                ["SOLITON_BUS_IN", "SOLITON_BUS_OUT", "RDMA_64B_CLK", "GND"]
            }
            Self::MultiBand1550nmCncRepeaterCBAsHomodyne => {
                ["OPT_1550_IN", "DIFF_HOMO_OUT", "CNC_PSA_PUMP", "GND"]
            }
            Self::Nanodiamond2DhgBiodegradableCarbonPhotonics => {
                ["2DHG_DRAIN", "OXSCNT_HOMO_OUT", "PCQD_590_GATE", "GND"]
            }
            Self::VortexViaShgOpaAqmInterconnect => {
                ["VORTEX_VIA_IN", "STAR_VORTEX_OUT", "KELVIN_AQM_DRV", "GND"]
            }
            Self::LhatHolographicArchivalTapeCartridge => {
                ["LHAT_OPT_READ", "LOGPOLAR_SYNC", "QFT_RK_ERASE", "GND"]
            }
            Self::PressedLlmHolographicTapeSolitonQramSteering => {
                ["SOLITON_PROMPT_IN", "STEERED_LOGIT_OUT", "BLIG_LORA_CTRL", "GND"]
            }
            Self::QuantumCausalNextConceptPressedLlmAccelerator => {
                ["NCM_CONCEPT_IN", "QCI_MBR_TOKEN_OUT", "SCALE_STEER_CTRL", "GND"]
            }
            Self::RgoVitrimerMetamaterialEpaperNanodiamondDisplay => {
                ["RGO_GTE_PHASE_IN", "BRAGG_RGB_AMBER_OUT", "EPAPER_OAM_GATE", "GND"]
            }
        }
    }
}

/// Export an arbitrary polygon list (`&[PolygonFeature]`) into a KiCAD v8 `.kicad_mod`
/// footprint string (coordinates converted from $\mu\text{m}$ to $\text{mm}$).
pub fn export_polygons_to_kicad_footprint_str(
    module_name: &str,
    description: &str,
    pad_width_um: f64,
    features: &[PolygonFeature],
) -> String {
    let mut out = String::with_capacity(features.len() * 160 + 512);
    let _ = writeln!(
        out,
        "(footprint \"{module_name}\" (version 20240108) (generator \"signals_semi_dirac_cad_rs\")"
    );
    let _ = writeln!(out, "  (layer \"F.Cu\")");
    let _ = writeln!(out, "  (descr \"{description}\")");
    let _ = writeln!(out, "  (attr smd)");
    let _ = writeln!(
        out,
        "  (fp_text reference \"REF**\" (at 0 -0.25) (layer \"F.SilkS\")"
    );
    let _ = writeln!(out, "    (effects (font (size 0.5 0.5) (thickness 0.1)))");
    let _ = writeln!(out, "  )");
    let _ = writeln!(
        out,
        "  (fp_text value \"{module_name}\" (at 0 0.35) (layer \"F.Fab\")"
    );
    let _ = writeln!(out, "    (effects (font (size 0.5 0.5) (thickness 0.1)))");
    let _ = writeln!(out, "  )");

    let mut pad_counter = 1usize;
    for feat in features {
        if feat.layer == 3 {
            let n = feat.points_um.len() as f64;
            let cx: f64 = feat.points_um.iter().map(|p| p.0 / 1000.0).sum::<f64>() / n;
            let cy: f64 = feat.points_um.iter().map(|p| p.1 / 1000.0).sum::<f64>() / n;
            let w_mm = pad_width_um / 1000.0;
            let _ = writeln!(
                out,
                "  (pad \"{pad_counter}\" smd rect (at {cx:.4} {cy:.4}) (size {w_mm:.4} {w_mm:.4}) (layers \"F.Cu\" \"F.Mask\"))"
            );
            pad_counter += 1;
        } else {
            let kicad_layer = match feat.layer {
                10 => "F.Cu",
                11 => "B.Cu",
                12 => "Eco1.User",
                13 => "Eco2.User",
                _ => "F.Fab",
            };
            let _ = write!(out, "  (fp_poly (pts");
            for (x_um, y_um) in &feat.points_um {
                let _ = write!(out, " (xy {:.4} {:.4})", x_um / 1000.0, y_um / 1000.0);
            }
            let _ = writeln!(
                out,
                ") (stroke (width 0.005) (type solid)) (fill solid) (layer \"{kicad_layer}\"))"
            );
        }
    }
    let _ = writeln!(out, ")");
    out
}

/// Synthesize the 2D KiCAD/GDSII polygons and 3D `.kicad_vol` holographic splines
/// (including phase-varying lasing $\Delta\Phi(\ell,\phi) = \ell\phi$ for carbon-based
/// qudits) for any of the 4 Semi-Dirac Engineering & Quantum Applications.
pub fn generate_semi_dirac_application_module(
    preset: SemiDiracApplicationPreset,
    litho: &HolographicLaserLithoSpec,
) -> (String, Vec<PolygonFeature>, Vec<VolumetricSpline3D>) {
    let mod_name = preset.module_name().to_string();
    let stages: Vec<(&str, &str, f64)> = match preset {
        SemiDiracApplicationPreset::BallisticKleinDiodeTransistor => vec![
            (
                "1_LCS_STRAIN_CLAMP_WEST",
                "Signals.semiDiracStrainMergingGap(Delta0, beta, eps_xx* = Delta0/beta) = 0",
                90.0,
            ),
            (
                "2_MASSLESS_Y_KLEIN_BUS",
                "Signals.DFT.semiDiracKleinTunnelingY = 1 (k_x = 0 ballistic y-channel)",
                140.0,
            ),
            (
                "3_MASSIVE_X_WKB_GATE",
                "Signals.semiDiracKleinRectificationRatio(10) = 101 (w_STED = 18.08 nm x-pinch)",
                110.0,
            ),
            (
                "4_LCS_STRAIN_CLAMP_EAST",
                "Signals.DFT.semiDiracEnergySq(k_x, k_y, m_x*, v_y, 0)",
                90.0,
            ),
        ],
        SemiDiracApplicationPreset::HyperbolicThzBolometer => vec![
            (
                "1_BOWTIE_THZ_COLLECTOR_Y",
                "Signals.semiDiracDrudeAnisotropySq(c, m_x*, v_y, E_F) -> D_yy / D_xx >> 1",
                120.0,
            ),
            (
                "2_HYPERBOLIC_CANAL_SHEET",
                "Signals.semiDiracHyperbolicCanalizationTanSq(3/4, -3) = 1/4 (400-800 GHz)",
                160.0,
            ),
            (
                "3_SLIG_HOMODYNE_BOLOMETER",
                "Signals.semiDiracBolometerPolarizationContrast(10, 1) = 9/11",
                120.0,
            ),
            (
                "4_DIAMOND_PHONON_ISOLATOR",
                "Signals.DDF.rgo_polycbd_enz_hyperbolic_and_plasma_metamaterial_identities",
                100.0,
            ),
        ],
        SemiDiracApplicationPreset::OrthogonalThermoelectricHarvester => vec![
            (
                "1_DIAMOND_HOT_COLLECTOR",
                "Signals.DFT.gtbcHarmonicPlusAnharmonicConductance (Hot-side sp3 phonon bus)",
                110.0,
            ),
            (
                "2_NLIG_SEMI_DIRAC_N_LEG",
                "Signals.semiDiracThermoelectricZT (Heavy m_x* Seebeck S_yy + Massless v_y sigma_yy)",
                150.0,
            ),
            (
                "3_SLIG_SEMI_DIRAC_P_LEG",
                "Signals.semiDiracThermoelectricZT (Complementary p-type S-LIG pi-couple)",
                150.0,
            ),
            (
                "4_DIAMOND_COLD_PHONON_SINK",
                "Signals.DDF.CattaneoVernotteHeatModel (Cold-side phonon siphon)",
                110.0,
            ),
        ],
        SemiDiracApplicationPreset::EtchFreeMajoranaParafermionQuditBus => vec![
            (
                "1_SPP_PHASE_VARYING_LASER_IN",
                "Signals.helicalPhaseLasingAzimuthalShift(l, phi) = l*phi + spiralPhasePlateStepHeight",
                125.0,
            ),
            (
                "2_ETCH_FREE_SC1_MZM_Y_CHANNEL",
                "Signals.semiDiracTransverseGroupVelocityX(0, m_x*) = 0 (D_it gain = 100x vs RIE)",
                165.0,
            ),
            (
                "3_Z6_PARAFERMION_GR26_PLUCKER_CORE",
                "Signals.oamCarbonQuditHilbertDim (d=6 parafermion, d=15 Gr_C(2,6), d=100 OAM)",
                165.0,
            ),
            (
                "4_KERR_HOMODYNE_QND_READOUT",
                "Signals.Homodyne + Nondestructive Kerr Cross-Phase Parity Readout",
                125.0,
            ),
        ],
        SemiDiracApplicationPreset::SemiDiracSolitonBusCrowRdmaQram => vec![
            (
                "1_QNIC_128_TO_64_RDMA_INGRESS",
                "Signals.SolitonBus.tieredQnicStrippedPayloadBits(128, 64) = 64",
                130.0,
            ),
            (
                "2_NLIG_CROW_SLOW_LIGHT_DELAY",
                "Signals.SolitonBus.crowSlowLightDelayLength(12, 0.5, 0.3, 300) = 0.024 m (24 mm)",
                160.0,
            ),
            (
                "3_SEMI_DIRAC_RING_CORE_CO2_CNOT",
                "Signals.SolitonBus.co2CarbonateChi3CphaseLength(lambda, 5*n2, I_ctrl) = L_0 / 5",
                170.0,
            ),
            (
                "4_C8_STAR_VIA_LUT_CORDIC_QRAM",
                "Signals.SolitonBus.lutPlusCordicOamPhase + nligInternalPumpAvgPowerMw (37.5% PWM)",
                140.0,
            ),
        ],
        SemiDiracApplicationPreset::MultiBand1550nmCncRepeaterCBAsHomodyne => vec![
            (
                "1_MULTIBAND_405_1550NM_WDM_OAM_IN",
                "Signals.SolitonBus.multiBandThirdHarmonicWavelengthNm(1550) = 516.67 nm THG",
                135.0,
            ),
            (
                "2_CNC_10M_CHI2_PSA_SIGNAL_BOOSTER",
                "Signals.SolitonBus.cncPeriodicBoosterNetLinkGainDb(L, 10, alpha, 10*alpha) = 0 dB",
                165.0,
            ),
            (
                "3_NV_590NM_ADAMANTANE_PURCELL_DOWSER",
                "Signals.SolitonBus.nvPurcellFactorNormalized(100, 0.10, 3.14) = 75.99 > 12",
                145.0,
            ),
            (
                "4_SCARF_TAPER_CBAS_SLOT_HOMODYNE",
                "Signals.SolitonBus.adiabaticScarfTaperLoss (1.5%) < fresnelButtJointReflectance (12.1%)",
                155.0,
            ),
        ],
        SemiDiracApplicationPreset::Nanodiamond2DhgBiodegradableCarbonPhotonics => vec![
            (
                "1_PET_TEAL_CARBON_12GPA_NANODIAMOND",
                "Signals.SolitonBus.petEndogenousOxygenShockThresholdGPa(12) < hydrocarbon(30) & -$0.47/kg",
                140.0,
            ),
            (
                "2_H_TERMINATED_2DHG_DIAMOND_FET",
                "Signals.SolitonBus.h2PlasmaSp2ToSp3EtchSelectivity(100) + Walker et al. (2026) 2DHG p-FET",
                155.0,
            ),
            (
                "3_BIODEGRADABLE_PCQD_590NM_EMITTER",
                "Signals.SolitonBus.phosphorusCqdPurcellLifetimeNs(1.5, 15) = 0.10 ns (replaces n-Adamantane)",
                145.0,
            ),
            (
                "4_BIODEGRADABLE_OX_SCNT_HOMODYNE",
                "Signals.SolitonBus.biodegradableOxScntButtJointReflectance(1.55, 1.65) = 0.105% (replaces c-BAs)",
                160.0,
            ),
        ],
        SemiDiracApplicationPreset::VortexViaShgOpaAqmInterconnect => vec![
            (
                "1_VORTEX_VIA_HELICAL_OAM_STEP",
                "Signals.SolitonBus.vortexViaOamChargeStep(l, 1) + vortexViaHelicalArcFactorSq",
                135.0,
            ),
            (
                "2_STAR_VORTEX_VIA_8BRANCH_SPLITTER",
                "8-Branch C8 StarVortexVia Broadcast & OAM Mode-Sorting Inter-Layer Hub",
                155.0,
            ),
            (
                "3_DEAN_2025_SHG_RESONANT_OPA_CORE",
                "Signals.DDF.SecondHarmonicResonantOPA (Dean et al. Nature 2025: 21 mW pump, 17.25 dB gain)",
                165.0,
            ),
            (
                "4_KELVIN_SQRT_CBF_AQM_MODULATOR",
                "Signals.SolitonBus.aqmKelvinLinearizedVoltageSq + aqmCbfSafeHeaterPower (T_max = 80 C < 85 C)",
                145.0,
            ),
        ],
        SemiDiracApplicationPreset::LhatHolographicArchivalTapeCartridge => vec![
            (
                "1_LHAT_3000X_OAM_BRAGG_TAPE_WEB",
                "Signals.SolitonBus.lhatVolumetricMultiplexFactor(10,30,10)=3000 & lhatCartridgeCapacityTb=720TB",
                155.0,
            ),
            (
                "2_LOG_POLAR_O1_OPTICAL_TRACKING",
                "Signals.SolitonBus.logPolarUnwrappedPhase (64x64 2D FFT Zero-Iteration Scale/Rotation Lock)",
                145.0,
            ),
            (
                "3_VACNT_182FS_KAPITZA_THERMAL_SINK",
                "Signals.SolitonBus.vacntKapitzaCoolingTimePs(1.3e-8, 1.4e-3, 100) = 0.182 ps (182 fs)",
                150.0,
            ),
            (
                "4_QFT_RK_635NM_SELECTIVE_ERASE",
                "Signals.SolitonBus.qftRkRequiredTempDelta(155,25,95.2)=34.8 C < 60 C (Zero-Neighbor-Bleed)",
                150.0,
            ),
        ],
        SemiDiracApplicationPreset::PressedLlmHolographicTapeSolitonQramSteering => vec![
            (
                "1_PRESSED_1T_LLM_BRAGG_WEIGHT_TAPE",
                "Mask-Locked Ternary W_ij in {+1, 0, -1} via {0, pi} Bragg Phase Voxels on LHAT Tape",
                155.0,
            ),
            (
                "2_SOLITON_OAM_QRAM_PROMPT_BUS",
                "Signals.SolitonBus.lutPlusCordicOamPhase + Passive Mach-Zehnder Homodyne Optical MVM",
                150.0,
            ),
            (
                "3_NLIG_BLIG_ACTIVE_LORA_STEERING",
                "Signals.SolitonBus.pressedLlmSteeredActivation(W_pressed, delta_W_steer) = W_pressed + delta_W",
                160.0,
            ),
            (
                "4_OXSCNT_HOMODYNE_LOGIT_READOUT",
                "Zero-Tox Biodegradable Ox-s-CNT + VACNT Balanced Homodyne Token Logit Decoder",
                135.0,
            ),
        ],
        SemiDiracApplicationPreset::QuantumCausalNextConceptPressedLlmAccelerator => vec![
            (
                "1_MULTISCALE_RESIDUAL_VQ_BRAGG_STACK",
                "Signals.QuantumCausalInference.ncmCumulativeReconstructionStep + Nested-Dropout Bragg Depth Layers",
                155.0,
            ),
            (
                "2_QCI_VRC_PLUCKER_PARALLEL_LEVEL_GEN",
                "Signals.QuantumCausalInference.qciNcmCoherentPairwiseCodeProb (x_X = -1 Constraint Exclusion, 27,962x Speedup)",
                155.0,
            ),
            (
                "3_SCALE_SELECTIVE_NLIG_BLIG_STEERING",
                "Signals.QuantumCausalInference.ncmPressedTwoScaleSteeredLatent (Coarse Concept + Fine Lexical LoRA)",
                155.0,
            ),
            (
                "4_OAM_PARALLEL_MBR_OXSCNT_DECODER",
                "Signals.QuantumCausalInference.ncmOamParallelMbrLatencySteps (K Steps vs M_cand*K) + Ox-s-CNT Readout",
                135.0,
            ),
        ],
        SemiDiracApplicationPreset::RgoVitrimerMetamaterialEpaperNanodiamondDisplay => vec![
            (
                "1_RGO_VITRIMER_PAULI_GTE_METASURFACE",
                "Signals.SolitonBus.rgoPauliBlockedAbsorption + giresTournoisPhaseEnhancementFactor (300nm Pitch, 4ns A-CNT Reset)",
                150.0,
            ),
            (
                "2_VECTOR_REFLECT_CNS_BIO_TPU_EPAPER",
                "Signals.SolitonBus.epaperElectrophoreticSwitchTimeMs (25ms Video-Rate) + rgoBioTpuClearSignTransmittance (Brownian Failsafe)",
                150.0,
            ),
            (
                "3_CHIRAL_CNC_BIO_BRAGG_RGB_STACK",
                "Signals.SolitonBus.cncChiralBraggWavelengthNm (450/540/660nm Strain-Tuned RGB, >90% Transparent AR/TV)",
                155.0,
            ),
            (
                "4_NANODIAMOND_SHG_590NM_NV_ODMR_PIXEL",
                "Signals.SolitonBus.nanodiamondShgDisplayWavelengthNm (590nm Insect-Blind Amber & RGB) + nvDiamondOdmrSplittingMhz",
                145.0,
            ),
        ],
    };

    let mut polygons = Vec::new();
    let mut splines = Vec::new();
    let linewidth_nm = litho.sted_depleted_linewidth_nm();
    let mut x_cursor_um = 0.0_f64;
    let stage_height_um = 140.0_f64;
    let stage_gap_um = 16.0_f64;

    for (idx, (stage_label, rtl_ref, width_um)) in stages.iter().enumerate() {
        let x0 = x_cursor_um;
        let x1 = x0 + *width_um;
        let y0 = 0.0;
        let y1 = stage_height_um;

        // 1. N-LIG semi-Dirac massless y-axis channel / waveguide (Layer 10)
        polygons.push(PolygonFeature {
            layer: CarbonMaterial::NLigSp2.gds_layer(),
            datatype: idx as i16,
            points_um: vec![(x0, y0), (x1, y0), (x1, y1), (x0, y1)],
            tag: format!("SD_{stage_label}_NLIG"),
            local_director_rad: 0.0,
        });

        // 2. S-LIG complementary gate / bolometer / thermoelectric p-leg (Layer 11)
        polygons.push(PolygonFeature {
            layer: CarbonMaterial::SLigPType.gds_layer(),
            datatype: idx as i16,
            points_um: vec![
                (x0 + 8.0, y0 + 18.0),
                (x1 - 8.0, y0 + 18.0),
                (x1 - 8.0, y0 + 62.0),
                (x0 + 8.0, y0 + 62.0),
            ],
            tag: format!("SD_{stage_label}_SLIG"),
            local_director_rad: 0.0,
        });

        // 3. sp3 Diamond phonon router & thermal isolator (Layer 12)
        polygons.push(PolygonFeature {
            layer: CarbonMaterial::Sp3DiamondPhononBus.gds_layer(),
            datatype: idx as i16,
            points_um: vec![
                (x0 + 5.0, y0 - 14.0),
                (x1 - 5.0, y0 - 14.0),
                (x1 - 5.0, y0 - 4.0),
                (x0 + 5.0, y0 - 4.0),
            ],
            tag: format!("SD_{stage_label}_DIAMOND"),
            local_director_rad: 0.0,
        });

        // 4. O-CNT high-k gate dielectric & braiding shield (Layer 13)
        polygons.push(PolygonFeature {
            layer: CarbonMaterial::OCntHighKShield.gds_layer(),
            datatype: idx as i16,
            points_um: vec![
                (x1 + 2.0, y0 - 8.0),
                (x1 + stage_gap_um - 2.0, y0 - 8.0),
                (x1 + stage_gap_um - 2.0, y1 + 8.0),
                (x1 + 2.0, y1 + 8.0),
            ],
            tag: format!("SD_{stage_label}_OCNT"),
            local_director_rad: 0.0,
        });

        // 5. 532 nm LCS polyCBD uniaxial strain-locking Bragg clamp (Layer 14)
        polygons.push(PolygonFeature {
            layer: CarbonMaterial::PolyCbdBraggGrating.gds_layer(),
            datatype: idx as i16,
            points_um: vec![
                (x0 + 12.0, y1 + 5.0),
                (x1 - 12.0, y1 + 5.0),
                (x1 - 12.0, y1 + 15.0),
                (x0 + 12.0, y1 + 15.0),
            ],
            tag: format!("SD_{stage_label}_LCS_STRAIN_532NM"),
            local_director_rad: 0.0,
        });

        // Orthogonal flash assignment (Flash 1 for even stages, Flash 2 for odd stages)
        let flash_nlig = if idx % 2 == 0 { 1 } else { 2 };
        let z_base_um = 12.0 + (idx as f64) * 3.0;

        // For Application 4..10 (phase-steered OAM qudit / soliton bus / multi-band photonics /
        // biodegradable nanodiamond / VortexVia SHG-AQM / LHAT tape / Pressed-LLM QRAM),
        // vary the lasing phase ΔΦ(ℓ, φ) = ℓ φ along a 3D helical corkscrew spline
        let points_3d = if matches!(
            preset,
            SemiDiracApplicationPreset::EtchFreeMajoranaParafermionQuditBus
                | SemiDiracApplicationPreset::SemiDiracSolitonBusCrowRdmaQram
                | SemiDiracApplicationPreset::MultiBand1550nmCncRepeaterCBAsHomodyne
                | SemiDiracApplicationPreset::Nanodiamond2DhgBiodegradableCarbonPhotonics
                | SemiDiracApplicationPreset::VortexViaShgOpaAqmInterconnect
                | SemiDiracApplicationPreset::LhatHolographicArchivalTapeCartridge
                | SemiDiracApplicationPreset::PressedLlmHolographicTapeSolitonQramSteering
                | SemiDiracApplicationPreset::QuantumCausalNextConceptPressedLlmAccelerator
        ) {
            let l_charge = (idx as f64) + 1.0;
            let helix_radius_um = 6.0;
            (0..=8)
                .map(|step| {
                    let frac = (step as f64) / 8.0;
                    let x = x0 + frac * (*width_um + stage_gap_um);
                    let phi = 2.0 * PI * frac;
                    let phase_shift = l_charge * phi;
                    let y = 0.5 * stage_height_um + helix_radius_um * phase_shift.cos();
                    let z = z_base_um + helix_radius_um * phase_shift.sin();
                    (x, y, z)
                })
                .collect()
        } else {
            vec![
                (x0, 0.5 * stage_height_um, z_base_um),
                (0.5 * (x0 + x1), 0.5 * stage_height_um, z_base_um + 3.5),
                (x1 + stage_gap_um, 0.5 * stage_height_um, z_base_um),
            ]
        };

        splines.push(VolumetricSpline3D {
            id: format!("spline_sd_{stage_label}_nlig"),
            stage_name: (*stage_label).to_string(),
            rtl_source: (*rtl_ref).to_string(),
            material: CarbonMaterial::NLigSp2,
            flash_index: flash_nlig,
            wave_amplitude: 0.80,
            width_nm: linewidth_nm,
            points_um: points_3d,
        });

        splines.push(VolumetricSpline3D {
            id: format!("spline_sd_{stage_label}_slig"),
            stage_name: (*stage_label).to_string(),
            rtl_source: (*rtl_ref).to_string(),
            material: CarbonMaterial::SLigPType,
            flash_index: flash_nlig + 2,
            wave_amplitude: 0.78,
            width_nm: linewidth_nm,
            points_um: vec![
                (x0 + 8.0, 40.0, z_base_um + 1.4),
                (x1 - 8.0, 40.0, z_base_um + 1.4),
            ],
        });

        splines.push(VolumetricSpline3D {
            id: format!("spline_sd_{stage_label}_sp3_diamond"),
            stage_name: (*stage_label).to_string(),
            rtl_source: (*rtl_ref).to_string(),
            material: CarbonMaterial::Sp3DiamondPhononBus,
            flash_index: 5,
            wave_amplitude: 1.55,
            width_nm: 45.0,
            points_um: vec![
                (0.5 * (x0 + x1), 0.5 * stage_height_um, z_base_um - 2.0),
                (0.5 * (x0 + x1), -12.0, 0.0),
            ],
        });

        splines.push(VolumetricSpline3D {
            id: format!("spline_sd_{stage_label}_polycbd_lcs_strain"),
            stage_name: (*stage_label).to_string(),
            rtl_source: (*rtl_ref).to_string(),
            material: CarbonMaterial::PolyCbdBraggGrating,
            flash_index: 6,
            wave_amplitude: 0.70,
            width_nm: litho.lcs_green_bragg_pitch_nm(),
            points_um: vec![
                (x0 + 12.0, y1 + 10.0, z_base_um + 2.0),
                (x1 - 12.0, y1 + 10.0, z_base_um + 2.0),
            ],
        });

        x_cursor_um = x1 + stage_gap_um;
    }

    // Add 4 SMD contact pads on Layer 3
    for pad_idx in 0..4 {
        let px = (pad_idx as f64) * (x_cursor_um / 4.0) + 35.0;
        let py = -40.0;
        polygons.push(PolygonFeature {
            layer: 3,
            datatype: 0,
            points_um: vec![
                (px - 20.0, py - 20.0),
                (px + 20.0, py - 20.0),
                (px + 20.0, py + 20.0),
                (px - 20.0, py + 20.0),
            ],
            tag: format!("SD_IO_PAD_{}", pad_idx + 1),
            local_director_rad: 0.0,
        });
    }

    (mod_name, polygons, splines)
}

/// Generate a complete KiCAD v8 Schematic (`.kicad_sch`) for a Semi-Dirac Application
/// module, compatible with `.agents/skills/kicad/scripts/analyze_schematic.py`.
pub fn export_semi_dirac_kicad_schematic_str(preset: SemiDiracApplicationPreset) -> String {
    let mod_name = preset.module_name();
    let descr = preset.description();
    let pins = preset.pin_names();
    format!(
        r#"(kicad_sch
  (version 20231120)
  (generator "signals_semi_dirac_cad_rs")
  (generator_version "8.0")
  (uuid "00000000-0000-4000-8000-000000000001")
  (paper "A4")
  (title_block
    (title "{mod_name}")
    (date "2026-11-08")
    (rev "1.0")
    (comment 1 "{descr}")
  )
  (lib_symbols
    (symbol "SemiDirac:{mod_name}"
      (in_bom yes)
      (on_board yes)
      (property "Reference" "U" (at 0 10.16 0) (effects (font (size 1.27 1.27))))
      (property "Value" "{mod_name}" (at 0 -10.16 0) (effects (font (size 1.27 1.27))))
      (property "Footprint" "SemiDirac:{mod_name}" (at 0 -12.7 0) (effects (font (size 1.27 1.27)) (hide yes)))
      (property "Description" "{descr}" (at 0 0 0) (effects (font (size 1.27 1.27)) (hide yes)))
      (symbol "{mod_name}_1_1"
        (pin bidirectional line (at -12.7 2.54 0) (length 2.54)
          (name "{p1}" (effects (font (size 1.27 1.27))))
          (number "1" (effects (font (size 1.27 1.27))))
        )
        (pin bidirectional line (at 12.7 2.54 180) (length 2.54)
          (name "{p2}" (effects (font (size 1.27 1.27))))
          (number "2" (effects (font (size 1.27 1.27))))
        )
        (pin input line (at -12.7 -2.54 0) (length 2.54)
          (name "{p3}" (effects (font (size 1.27 1.27))))
          (number "3" (effects (font (size 1.27 1.27))))
        )
        (pin power_in line (at 12.7 -2.54 180) (length 2.54)
          (name "{p4}" (effects (font (size 1.27 1.27))))
          (number "4" (effects (font (size 1.27 1.27))))
        )
      )
    )
    (symbol "Connector:Conn_01x04"
      (in_bom yes)
      (on_board yes)
      (property "Reference" "J" (at 0 7.62 0) (effects (font (size 1.27 1.27))))
      (property "Value" "Conn_01x04" (at 0 -7.62 0) (effects (font (size 1.27 1.27))))
      (symbol "Conn_01x04_1_1"
        (pin passive line (at -5.08 2.54 0) (length 2.54)
          (name "Pin_1" (effects (font (size 1.27 1.27))))
          (number "1" (effects (font (size 1.27 1.27))))
        )
        (pin passive line (at -5.08 0 0) (length 2.54)
          (name "Pin_2" (effects (font (size 1.27 1.27))))
          (number "2" (effects (font (size 1.27 1.27))))
        )
        (pin passive line (at -5.08 -2.54 0) (length 2.54)
          (name "Pin_3" (effects (font (size 1.27 1.27))))
          (number "3" (effects (font (size 1.27 1.27))))
        )
        (pin passive line (at -5.08 -5.08 0) (length 2.54)
          (name "Pin_4" (effects (font (size 1.27 1.27))))
          (number "4" (effects (font (size 1.27 1.27))))
        )
      )
    )
  )
  (symbol
    (lib_id "SemiDirac:{mod_name}")
    (at 100 100 0)
    (unit 1)
    (in_bom yes)
    (on_board yes)
    (uuid "00000000-0000-4000-8000-000000000010")
    (property "Reference" "U1" (at 100 89.84 0) (effects (font (size 1.27 1.27))))
    (property "Value" "{mod_name}" (at 100 110.16 0) (effects (font (size 1.27 1.27))))
    (property "Footprint" "SemiDirac:{mod_name}" (at 100 112.7 0) (effects (font (size 1.27 1.27)) (hide yes)))
    (property "MPN" "LIGNOLUX-{mod_name}" (at 100 115.0 0) (effects (font (size 1.27 1.27)) (hide yes)))
    (pin "1" (uuid "00000000-0000-4000-8000-000000000011"))
    (pin "2" (uuid "00000000-0000-4000-8000-000000000012"))
    (pin "3" (uuid "00000000-0000-4000-8000-000000000013"))
    (pin "4" (uuid "00000000-0000-4000-8000-000000000014"))
  )
  (symbol
    (lib_id "Connector:Conn_01x04")
    (at 140 100 0)
    (unit 1)
    (in_bom yes)
    (on_board yes)
    (uuid "00000000-0000-4000-8000-000000000020")
    (property "Reference" "J1" (at 140 92.38 0) (effects (font (size 1.27 1.27))))
    (property "Value" "Conn_01x04" (at 140 107.62 0) (effects (font (size 1.27 1.27))))
    (property "Footprint" "Connector:PinHeader_1x04_P2.54mm" (at 140 110.0 0) (effects (font (size 1.27 1.27)) (hide yes)))
    (property "MPN" "LIGNOLUX-CONN-1X4" (at 140 112.0 0) (effects (font (size 1.27 1.27)) (hide yes)))
    (pin "1" (uuid "00000000-0000-4000-8000-000000000021"))
    (pin "2" (uuid "00000000-0000-4000-8000-000000000022"))
    (pin "3" (uuid "00000000-0000-4000-8000-000000000023"))
    (pin "4" (uuid "00000000-0000-4000-8000-000000000024"))
  )
  (wire (pts (xy 87.3 97.46) (xy 80.0 97.46)) (uuid "00000000-0000-4000-8000-000000000031"))
  (wire (pts (xy 112.7 97.46) (xy 120.0 97.46)) (uuid "00000000-0000-4000-8000-000000000032"))
  (wire (pts (xy 87.3 102.54) (xy 80.0 102.54)) (uuid "00000000-0000-4000-8000-000000000033"))
  (wire (pts (xy 112.7 102.54) (xy 120.0 102.54)) (uuid "00000000-0000-4000-8000-000000000034"))
  (wire (pts (xy 134.92 97.46) (xy 128.0 97.46)) (uuid "00000000-0000-4000-8000-000000000035"))
  (wire (pts (xy 134.92 100.0) (xy 128.0 100.0)) (uuid "00000000-0000-4000-8000-000000000036"))
  (wire (pts (xy 134.92 102.54) (xy 128.0 102.54)) (uuid "00000000-0000-4000-8000-000000000037"))
  (wire (pts (xy 134.92 105.08) (xy 128.0 105.08)) (uuid "00000000-0000-4000-8000-000000000038"))
  (label "{p1}" (at 80.0 97.46 0) (effects (font (size 1.27 1.27))))
  (label "{p2}" (at 120.0 97.46 0) (effects (font (size 1.27 1.27))))
  (label "{p3}" (at 80.0 102.54 0) (effects (font (size 1.27 1.27))))
  (label "{p4}" (at 120.0 102.54 0) (effects (font (size 1.27 1.27))))
  (label "{p1}" (at 128.0 97.46 0) (effects (font (size 1.27 1.27))))
  (label "{p2}" (at 128.0 100.0 0) (effects (font (size 1.27 1.27))))
  (label "{p3}" (at 128.0 102.54 0) (effects (font (size 1.27 1.27))))
  (label "{p4}" (at 128.0 105.08 0) (effects (font (size 1.27 1.27))))
  (symbol_instances
    (path "/00000000-0000-4000-8000-000000000001/00000000-0000-4000-8000-000000000010"
      (reference "U1") (unit 1) (value "{mod_name}") (footprint "SemiDirac:{mod_name}")
    )
    (path "/00000000-0000-4000-8000-000000000001/00000000-0000-4000-8000-000000000020"
      (reference "J1") (unit 1) (value "Conn_01x04") (footprint "Connector:PinHeader_1x04_P2.54mm")
    )
  )
)
"#,
        p1 = pins[0],
        p2 = pins[1],
        p3 = pins[2],
        p4 = pins[3],
    )
}

/// Generate a complete KiCAD v8 PCB Layout (`.kicad_pcb`) for a Semi-Dirac Application
/// module with board `Edge.Cuts`, placed `U1` and `J1` footprints, and 100% routed
/// `F.Cu` segments, compatible with `.agents/skills/kicad/scripts/analyze_pcb.py`.
pub fn export_semi_dirac_kicad_pcb_str(preset: SemiDiracApplicationPreset) -> String {
    let mod_name = preset.module_name();
    let descr = preset.description();
    let pins = preset.pin_names();
    format!(
        r#"(kicad_pcb
  (version 20240108)
  (generator "signals_semi_dirac_cad_rs")
  (generator_version "8.0")
  (general (thickness 1.6) (legacy_teardrops no))
  (paper "A4")
  (title_block
    (title "{mod_name}")
    (date "2026-11-08")
    (rev "1.0")
    (comment 1 "{descr}")
  )
  (layers
    (0 "F.Cu" signal)
    (31 "B.Cu" signal)
    (36 "B.SilkS" user "B.Silkscreen")
    (37 "F.SilkS" user "F.Silkscreen")
    (38 "B.Mask" user)
    (39 "F.Mask" user)
    (44 "Edge.Cuts" user)
    (49 "F.Fab" user)
  )
  (setup
    (pad_to_mask_clearance 0)
  )
  (net 0 "")
  (net 1 "{p1}")
  (net 2 "{p2}")
  (net 3 "{p3}")
  (net 4 "{p4}")
  (gr_rect (start 90 90) (end 130 115) (stroke (width 0.15) (type default)) (fill none) (layer "Edge.Cuts"))
  (footprint "SemiDirac:{mod_name}"
    (layer "F.Cu")
    (at 102 102 0)
    (descr "{descr}")
    (attr smd)
    (property "Reference" "U1" (at 0 -4 0) (layer "F.SilkS") (effects (font (size 1 1) (thickness 0.15))))
    (property "Value" "{mod_name}" (at 0 5 0) (layer "F.Fab") (effects (font (size 1 1) (thickness 0.15))))
    (property "MPN" "LIGNOLUX-{mod_name}" (at 0 6 0) (layer "F.Fab") (hide yes))
    (pad "1" smd rect (at 0 -3) (size 1.0 0.8) (layers "F.Cu" "F.Mask") (net 1 "{p1}"))
    (pad "2" smd rect (at 0 -1) (size 1.0 0.8) (layers "F.Cu" "F.Mask") (net 2 "{p2}"))
    (pad "3" smd rect (at 0 1) (size 1.0 0.8) (layers "F.Cu" "F.Mask") (net 3 "{p3}"))
    (pad "4" smd rect (at 0 3) (size 1.0 0.8) (layers "F.Cu" "F.Mask") (net 4 "{p4}"))
  )
  (footprint "Connector:PinHeader_1x04_P2.54mm"
    (layer "F.Cu")
    (at 118 102 0)
    (attr through_hole)
    (property "Reference" "J1" (at 0 -5 0) (layer "F.SilkS") (effects (font (size 1 1) (thickness 0.15))))
    (property "Value" "Conn_01x04" (at 0 5 0) (layer "F.Fab") (effects (font (size 1 1) (thickness 0.15))))
    (property "MPN" "LIGNOLUX-CONN-1X4" (at 0 6 0) (layer "F.Fab") (hide yes))
    (pad "1" thru_hole circle (at 0 -3) (size 1.5 1.5) (drill 0.9) (layers "*.Cu" "*.Mask") (net 1 "{p1}"))
    (pad "2" thru_hole circle (at 0 -1) (size 1.5 1.5) (drill 0.9) (layers "*.Cu" "*.Mask") (net 2 "{p2}"))
    (pad "3" thru_hole circle (at 0 1) (size 1.5 1.5) (drill 0.9) (layers "*.Cu" "*.Mask") (net 3 "{p3}"))
    (pad "4" thru_hole circle (at 0 3) (size 1.5 1.5) (drill 0.9) (layers "*.Cu" "*.Mask") (net 4 "{p4}"))
  )
  (segment (start 102 99) (end 118 99) (width 0.25) (layer "F.Cu") (net 1))
  (segment (start 102 101) (end 118 101) (width 0.25) (layer "F.Cu") (net 2))
  (segment (start 102 103) (end 118 103) (width 0.25) (layer "F.Cu") (net 3))
  (segment (start 102 105) (end 118 105) (width 0.40) (layer "F.Cu") (net 4))
)
"#,
        p1 = pins[0],
        p2 = pins[1],
        p3 = pins[2],
        p4 = pins[3],
    )
}

// ---------------------------------------------------------------------------
// Paper 40: `rGO-Vitrimer` Active Metamaterials, Bistable & Elastomeric E-Paper,
//           Chiral `CNC` `Bio-Bragg` Projectors, & Nanodiamond Quantum Displays
//           (`Signals.SolitonBus` Section 9)
// ---------------------------------------------------------------------------

/// Sub-wavelength Nyquist pixel pitch `Lambda_max = lambda_nm / (2 * na)` (`rgoMetasurfaceNyquistPitchNm`).
#[inline]
pub fn rgo_metasurface_nyquist_pitch_nm(lambda_nm: f64, na: f64) -> f64 {
    lambda_nm / (2.0 * na)
}

/// Pauli-blocked interband absorption switch (`rgoPauliBlockedAbsorption`):
/// returns `0.0` when `2 * E_F > hbar * omega` (pure-phase GTE mode), else `alpha_inter`.
#[inline]
pub fn rgo_pauli_blocked_absorption(two_ef: f64, hbar_omega: f64, alpha_inter: f64) -> f64 {
    if hbar_omega < two_ef {
        0.0
    } else {
        alpha_inter
    }
}

/// Gires–Tournois Etalon (`GTE`, "Smart Mirror") resonant phase-slope enhancement factor
/// `(1 + r_top_amp) / (1 - r_top_amp)` (`giresTournoisPhaseEnhancementFactor`).
#[inline]
pub fn gires_tournois_phase_enhancement_factor(r_top_amp: f64) -> f64 {
    (1.0 + r_top_amp) / (1.0 - r_top_amp)
}

/// Temporal speckle whitening squared contrast `1 / (f_mod_hz * tau_int_s)` (`rgoSpeckleContrastSq`).
#[inline]
pub fn rgo_speckle_contrast_sq(f_mod_hz: f64, tau_int_s: f64) -> f64 {
    1.0 / (f_mod_hz * tau_int_s)
}

/// Flash-print thermal diffusion reset time in nanoseconds `l_mask_nm^2 / alpha_eff_nm2_per_ns`
/// (`rgoThermalDiffusionResetTimeNs`).
#[inline]
pub fn rgo_thermal_diffusion_reset_time_ns(l_mask_nm: f64, alpha_eff_nm2_per_ns: f64) -> f64 {
    (l_mask_nm * l_mask_nm) / alpha_eff_nm2_per_ns
}

/// Electrophoretic / electro-rotational e-paper switching time `d_gap_um^2 / (mu_ep * v_drive)` in ms
/// (`epaperElectrophoreticSwitchTimeMs`).
#[inline]
pub fn epaper_electrophoretic_switch_time_ms(d_gap_um: f64, mu_ep: f64, v_drive: f64) -> f64 {
    (d_gap_um * d_gap_um) / (mu_ep * v_drive)
}

/// `rGO-Bio-TPU` electro-rotational Clear Sign transmittance `t_max * (1 - alpha_ext * sin_theta_flake)`
/// (`rgoBioTpuClearSignTransmittance`).
#[inline]
pub fn rgo_bio_tpu_clear_sign_transmittance(
    t_max: f64,
    alpha_ext: f64,
    sin_theta_flake: f64,
) -> f64 {
    t_max * (1.0 - alpha_ext * sin_theta_flake)
}

/// Bistable `Vector Reflect` (`LIG`-coated `CNS` + `rGO`) annual energy consumption in kWh
/// (`vectorReflectBistableAnnualEnergyKwh`).
#[inline]
pub fn vector_reflect_bistable_annual_energy_kwh(
    p_hold_kw: f64,
    hours_per_year: f64,
    e_update_kwh: f64,
    n_updates: f64,
) -> f64 {
    p_hold_kw * hours_per_year + e_update_kwh * n_updates
}

/// Bilayer active (`rGO-Vitrimer`) / passive (`Pristine Vitrimer`) differential thermal curvature
/// (`bilayerVitrimerThermalCurvature`).
#[inline]
pub fn bilayer_vitrimer_thermal_curvature(
    alpha_active: f64,
    alpha_passive: f64,
    delta_t: f64,
    h_total: f64,
) -> f64 {
    6.0 * (alpha_active - alpha_passive) * delta_t / h_total
}

/// Strain-tuned chiral nematic `CNC` structural-color Bragg peak wavelength in nm
/// (`cncChiralBraggWavelengthNm`).
#[inline]
pub fn cnc_chiral_bragg_wavelength_nm(n_avg: f64, pitch_nm: f64, eps_strain: f64) -> f64 {
    n_avg * pitch_nm * (1.0 + eps_strain)
}

/// Nanodiamond Second-Harmonic Generation (`SHG`) display up-converted wavelength `lambda_fund_nm / 2`
/// (`nanodiamondShgDisplayWavelengthNm`).
#[inline]
pub fn nanodiamond_shg_display_wavelength_nm(lambda_fund_nm: f64) -> f64 {
    lambda_fund_nm / 2.0
}

/// Nocturnal flying-insect photoreceptor sensitivity cutoff (`0.0` for `lambda_nm > 500.0`, else `1.0`)
/// (`insectPhotoreceptorSensitivity`).
#[inline]
pub fn insect_photoreceptor_sensitivity(lambda_nm: f64) -> f64 {
    if lambda_nm > 500.0 {
        0.0
    } else {
        1.0
    }
}

/// Nanodiamond / `n-adamantane` NV-center ODMR Zeeman frequency splitting `2 * gamma_nv * B` in MHz
/// (`nvDiamondOdmrSplittingMhz`).
#[inline]
pub fn nv_diamond_odmr_splitting_mhz(gamma_nv_mhz_per_mt: f64, b_field_mt: f64) -> f64 {
    2.0 * gamma_nv_mhz_per_mt * b_field_mt
}

/// Gires–Tournois Etalon (`GTE`) all-phase unimodular reflectance norm squared
/// (`giresTournoisReflectanceNormSq`).
#[inline]
pub fn gires_tournois_reflectance_norm_sq(r_top: f64, cos_phi: f64, sin_phi: f64) -> f64 {
    ((r_top - cos_phi).powi(2) + sin_phi.powi(2))
        / ((1.0 - r_top * cos_phi).powi(2) + (r_top * sin_phi).powi(2))
}

/// Dynamic Virtual Mask (`DVM`) multi-strip overlap redundancy fidelity `1 - p_defect^n_strips`
/// (`dvmMultiStripMaskFidelity`).
#[inline]
pub fn dvm_multi_strip_mask_fidelity(p_defect: f64, n_strips: u32) -> f64 {
    1.0 - p_defect.powi(n_strips as i32)
}

/// `LBGPC` laminar fluid-bearing Reynolds number `rho * v * d_h / mu`
/// (`lbgpcLaminarReynoldsNumber`).
#[inline]
pub fn lbgpc_laminar_reynolds_number(
    rho_kg_m3: f64,
    v_m_s: f64,
    d_h_m: f64,
    mu_pa_s: f64,
) -> f64 {
    (rho_kg_m3 * v_m_s * d_h_m) / mu_pa_s
}

/// `rGO-Bio-TPU` passive Brownian rotational relaxation time in ms
/// (`rgoBioTpuBrownianResetTimeMs`).
#[inline]
pub fn rgo_bio_tpu_brownian_reset_time_ms(
    eta_mpas: f64,
    d_flake_um: f64,
    kbt_scale: f64,
) -> f64 {
    (eta_mpas * d_flake_um.powi(3)) / (6.0 * kbt_scale)
}

/// `rGO-Bio-TPU` active electro-rotational / dielectrophoretic alignment time in ms
/// (`rgoBioTpuElectroAlignmentTimeMs`).
#[inline]
pub fn rgo_bio_tpu_electro_alignment_time_ms(
    eta_mpas: f64,
    delta_chi_eff: f64,
    e_field_v_per_um: f64,
) -> f64 {
    eta_mpas / (delta_chi_eff * e_field_v_per_um.powi(2))
}

/// Chiral `CNC` `Bio-Bragg` oblique viewing-angle electro-strain pre-compensation `1 / cos_theta - 1`
/// (`cncObliqueViewingStrainCompensation`).
#[inline]
pub fn cnc_oblique_viewing_strain_compensation(cos_theta_int: f64) -> f64 {
    1.0 / cos_theta_int - 1.0
}

/// Oblique-angle chiral `CNC` Bragg reflection wavelength `n_avg * pitch_nm * (1 + eps_strain) * cos_theta_int`
/// (`cncObliqueCompensatedBraggWavelengthNm`).
#[inline]
pub fn cnc_oblique_compensated_bragg_wavelength_nm(
    n_avg: f64,
    pitch_nm: f64,
    eps_strain: f64,
    cos_theta_int: f64,
) -> f64 {
    n_avg * pitch_nm * (1.0 + eps_strain) * cos_theta_int
}

/// `NV`-diamond / `n-adamantane` `ODMR` closed-loop phase-drift residual
/// (`nvOdmrCalibratedPhaseResidual`).
#[inline]
pub fn nv_odmr_calibrated_phase_residual(
    delta_phi_raw: f64,
    gamma_phase_per_mhz: f64,
    delta_f_odmr_mhz: f64,
) -> f64 {
    delta_phi_raw - gamma_phase_per_mhz * delta_f_odmr_mhz
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn denisov_forward_and_bragg_pitch_invariants() {
        let spec_bragg = ProcaCannonMaskSpec::default();
        assert!((spec_bragg.bragg_radial_pitch_um - 612.0).abs() < 1e-9);
        let bragg_pitch = spec_bragg.denisov_bragg_pitch_um();
        let forward_pitch = spec_bragg.denisov_forward_pitch_um();
        assert!(bragg_pitch > 1010.0 && bragg_pitch < 1013.0);
        assert!((forward_pitch - 2.0 * bragg_pitch).abs() < 1e-12);
        assert!(
            (wasm_proca_cannon_denisov_forward_pitch_um(400.0, 21.74) - forward_pitch).abs()
                < 1e-12
        );
        assert!(
            (wasm_proca_cannon_denisov_bragg_pitch_um(400.0, 21.74) - bragg_pitch).abs() < 1e-12
        );
    }

    #[test]
    fn topological_charge_q_half_berry_phase_winding_and_drc() {
        let spec = ProcaCannonMaskSpec {
            outer_radius_um: 2000.0,
            azimuthal_sectors: 36,
            ..ProcaCannonMaskSpec::default()
        };
        let features = generate_mask_polygons(&spec);
        let drc = verify_mask_drc(&spec, &features);

        assert!(drc.all_polygons_have_positive_area);
        assert_eq!(drc.layer1_bragg_polygons, 2 * 36);
        assert_eq!(drc.layer3_pad_polygons, 8);
        let expected_span = 0.5 * (2.0 * PI) * (35.0 / 36.0);
        assert!((drc.berry_phase_winding_rad - expected_span).abs() < 1e-12);
        assert!((drc.zone1_exact_enz_fill - (141.0 / 5641.0)).abs() < 1e-12);
        assert!((drc.zone3_exact_enz_fill - (141.0 / 1516.0)).abs() < 1e-12);
    }

    #[test]
    fn gds_real8_roundtrip_and_binary_stream_parser() {
        for &val in &[1.0e-3, 1.0e-9, 0.0, -42.125, 612.0] {
            let enc = encode_gds_real8(val);
            let dec = decode_gds_real8(enc);
            if val == 0.0 {
                assert_eq!(dec, 0.0);
            } else {
                assert!(((dec - val) / val).abs() < 1e-12);
            }
        }

        let spec = ProcaCannonMaskSpec {
            outer_radius_um: 3000.0,
            pitch_mode: DenisovPitchMode::ForwardFirstOrder,
            ..ProcaCannonMaskSpec::default()
        };
        let kicad_text = export_kicad_footprint_str(&spec);
        assert!(kicad_text.contains("(footprint \"PolyCBD_800GHz_Proca_Lens\""));
        assert!(kicad_text.contains("(layer \"F.Fab\")"));
        assert!(kicad_text.contains("(pad \"8\" smd rect"));

        let (gds_bytes, poly_count) = export_gdsii_bytes(&spec);
        assert!(gds_bytes.len() > 1000);
        assert!(poly_count > 100);

        let parsed = parse_gdsii_bytes(&gds_bytes).expect("valid GDSII binary stream");
        assert_eq!(parsed.version, 600);
        assert_eq!(parsed.lib_name, "PolyCBD_800GHz_Proca_Lens");
        assert_eq!(parsed.str_name, "PolyCBD_800GHz_Proca_Lens");
        assert!(((parsed.user_unit - 1.0e-3) / 1.0e-3).abs() < 1e-12);
        assert!(((parsed.db_unit_m - 1.0e-9) / 1.0e-9).abs() < 1e-12);
        assert_eq!(parsed.boundaries.len(), poly_count);

        // Verify multi-band presets also synthesize and round-trip cleanly
        for preset in [
            FireSuppressionBandPreset::OhLambdaDoubling1667MHz,
            FireSuppressionBandPreset::Rotational915To1830GHz,
        ] {
            let p_spec =
                ProcaCannonMaskSpec::from_preset(preset, DenisovPitchMode::ForwardFirstOrder);
            let (p_bytes, p_count) = export_gdsii_bytes(&p_spec);
            let p_parsed = parse_gdsii_bytes(&p_bytes).expect("preset GDSII valid");
            assert_eq!(p_parsed.boundaries.len(), p_count);
        }
    }

    #[test]
    fn riscv_cva6_cheri_and_ibex_holographic_405_532_workflow() {
        let litho = HolographicLaserLithoSpec::default();
        assert!((litho.abbe_diffraction_linewidth_nm() - (2025.0 / 14.0)).abs() < 1e-11);
        assert!((litho.sted_depleted_linewidth_nm() - (2025.0 / 112.0)).abs() < 1e-11);
        assert!(litho.sted_depleted_linewidth_nm() < 20.0);
        assert!(litho.lcs_green_bragg_pitch_nm() > 165.0 && litho.lcs_green_bragg_pitch_nm() < 170.0);

        for (preset, expected_stages) in [
            (RiscVCorePreset::Cva6Linux6StageRv64gc, 6usize),
            (RiscVCorePreset::CheriCva6Linux6StageRvy, 6usize),
            (RiscVCorePreset::IbexCheriotLockstep3StageRv32imcb, 3usize),
        ] {
            let (mod_name, polys, splines) = generate_riscv_holographic_module(preset, &litho);
            let drc = verify_volumetric_metric_interference_drc(
                &mod_name,
                expected_stages,
                &polys,
                &splines,
                &litho,
            );
            assert_eq!(drc.pipeline_stages, expected_stages);
            // Single-flash exposure of adjacent stages triggers sp3 diamond over-squeeze hazards:
            assert_eq!(drc.single_flash_over_squeeze_hazards, expected_stages - 1);
            // Orthogonal multi-flash decomposition eliminates all over-squeeze hazards:
            assert_eq!(drc.orthogonal_multi_flash_hazards, 0);

            let gds_bytes = export_polygons_to_gdsii_bytes(&mod_name, &polys);
            let parsed = parse_gdsii_bytes(&gds_bytes).expect("valid RISC-V GDSII");
            assert_eq!(parsed.boundaries.len(), polys.len());

            let kicad_vol = export_kicad_volumetric_str(&mod_name, &litho, &splines);
            assert!(kicad_vol.contains("(kicad_vol (version 20261025)"));
            assert!(kicad_vol.contains("(write_uv_nm 405.0) (depletion_green_nm 532.0)"));
            assert!(kicad_vol.contains("(material sp3_diamond)"));

            let cbom = export_iof_prov_cbom_yaml_ld(&mod_name, &litho, &splines);
            assert!(cbom.contains("iof:ManufacturingOperation"));
            assert!(cbom.contains("cooling_delay_ms: 15.0"));
        }
    }

    #[test]
    fn semi_dirac_four_applications_kicad_gdsii_vol_and_cbom_workflow() {
        let litho = HolographicLaserLithoSpec::default();
        for preset in SemiDiracApplicationPreset::all() {
            let (mod_name, polys, splines) = generate_semi_dirac_application_module(preset, &litho);
            let drc = verify_volumetric_metric_interference_drc(&mod_name, 4, &polys, &splines, &litho);
            assert_eq!(drc.pipeline_stages, 4);
            assert_eq!(drc.single_flash_over_squeeze_hazards, 3);
            assert_eq!(drc.orthogonal_multi_flash_hazards, 0);

            let kicad_mod = export_polygons_to_kicad_footprint_str(
                &mod_name,
                preset.description(),
                40.0,
                &polys,
            );
            assert!(kicad_mod.contains(&format!("(footprint \"{mod_name}\"")));
            assert!(kicad_mod.contains("(pad \"4\" smd rect"));

            let kicad_sch = export_semi_dirac_kicad_schematic_str(preset);
            assert!(kicad_sch.contains("(kicad_sch"));
            assert!(kicad_sch.contains(&format!("LIGNOLUX-{mod_name}")));

            let kicad_pcb = export_semi_dirac_kicad_pcb_str(preset);
            assert!(kicad_pcb.contains("(kicad_pcb"));
            assert!(kicad_pcb.contains("(segment (start 102 99) (end 118 99)"));

            let gds_bytes = export_polygons_to_gdsii_bytes(&mod_name, &polys);
            let parsed = parse_gdsii_bytes(&gds_bytes).expect("valid Semi-Dirac GDSII");
            assert_eq!(parsed.boundaries.len(), polys.len());

            let kicad_vol = export_kicad_volumetric_str(&mod_name, &litho, &splines);
            assert!(kicad_vol.contains("(kicad_vol (version 20261025)"));
            assert!(kicad_vol.contains("(material polycbd_bragg)"));

            let cbom = export_iof_prov_cbom_yaml_ld(&mod_name, &litho, &splines);
            assert!(cbom.contains("iof:ManufacturingOperation"));
        }
    }

    #[test]
    fn rgo_vitrimer_active_metamaterial_epaper_and_nanodiamond_display_identities_hold() {
        assert!((rgo_metasurface_nyquist_pitch_nm(800.0, 1.0) - 400.0).abs() < 1e-12);
        assert!(rgo_pauli_blocked_absorption(3.0, 2.0, 0.023).abs() < 1e-12);
        assert!((rgo_pauli_blocked_absorption(1.0, 2.0, 0.023) - 0.023).abs() < 1e-12);
        assert!((gires_tournois_phase_enhancement_factor(0.5) - 3.0).abs() < 1e-12);
        assert!((rgo_speckle_contrast_sq(1.0e8, 0.01) - 1.0e-6).abs() < 1e-18);
        assert!((rgo_thermal_diffusion_reset_time_ns(200.0, 1.0e4) - 4.0).abs() < 1e-12);
        assert!((epaper_electrophoretic_switch_time_ms(40.0, 4.0, 1.0) - 400.0).abs() < 1e-12);
        assert!((epaper_electrophoretic_switch_time_ms(10.0, 4.0, 1.0) - 25.0).abs() < 1e-12);
        assert!((rgo_bio_tpu_clear_sign_transmittance(0.92, 1.0, 0.0) - 0.92).abs() < 1e-12);
        assert!(rgo_bio_tpu_clear_sign_transmittance(0.92, 1.0, 1.0).abs() < 1e-12);
        assert!(vector_reflect_bistable_annual_energy_kwh(0.0, 8760.0, 0.0, 0.0).abs() < 1e-12);
        assert!(
            vector_reflect_bistable_annual_energy_kwh(0.0, 8760.0, 0.01, 365.0)
                < vector_reflect_bistable_annual_energy_kwh(4.0, 8760.0, 0.0, 0.0)
        );
        assert!(bilayer_vitrimer_thermal_curvature(2.0e-4, 0.5e-4, 0.0, 100.0).abs() < 1e-15);
        assert!((cnc_chiral_bragg_wavelength_nm(3.0, 150.0, 0.0) - 450.0).abs() < 1e-12);
        assert!((cnc_chiral_bragg_wavelength_nm(3.0, 180.0, 0.0) - 540.0).abs() < 1e-12);
        assert!((cnc_chiral_bragg_wavelength_nm(3.0, 220.0, 0.0) - 660.0).abs() < 1e-12);
        assert!((nanodiamond_shg_display_wavelength_nm(1180.0) - 590.0).abs() < 1e-12);
        assert!((nanodiamond_shg_display_wavelength_nm(1270.0) - 635.0).abs() < 1e-12);
        assert!((nanodiamond_shg_display_wavelength_nm(1064.0) - 532.0).abs() < 1e-12);
        assert!((nanodiamond_shg_display_wavelength_nm(900.0) - 450.0).abs() < 1e-12);
        assert!(
            insect_photoreceptor_sensitivity(nanodiamond_shg_display_wavelength_nm(1180.0)).abs()
                < 1e-12
        );
        assert!((insect_photoreceptor_sensitivity(450.0) - 1.0).abs() < 1e-12);
        assert!((nv_diamond_odmr_splitting_mhz(28.0, 5.0) - 280.0).abs() < 1e-12);

        // Deep gap-closure checks:
        assert!((gires_tournois_reflectance_norm_sq(0.5, 0.6, 0.8) - 1.0).abs() < 1e-12);
        assert!((dvm_multi_strip_mask_fidelity(0.04, 2) - (624.0 / 625.0)).abs() < 1e-12);
        assert!(dvm_multi_strip_mask_fidelity(0.04, 2) > 0.998);
        assert!((lbgpc_laminar_reynolds_number(1200.0, 0.5, 1.0e-3, 3.0e-3) - 200.0).abs() < 1e-12);
        assert!((rgo_bio_tpu_electro_alignment_time_ms(12.0, 3.0, 2.0) - 1.0).abs() < 1e-12);
        assert!((rgo_bio_tpu_brownian_reset_time_ms(12.0, 2.0, 1.0) - 16.0).abs() < 1e-12);
        let eps_comp = cnc_oblique_viewing_strain_compensation(0.8);
        assert!(
            (cnc_oblique_compensated_bragg_wavelength_nm(3.0, 180.0, eps_comp, 0.8) - 540.0).abs()
                < 1e-12
        );
        assert!(
            nv_odmr_calibrated_phase_residual(0.01 * 280.0, 0.01, nv_diamond_odmr_splitting_mhz(28.0, 5.0))
                .abs()
                < 1e-12
        );
    }
}
