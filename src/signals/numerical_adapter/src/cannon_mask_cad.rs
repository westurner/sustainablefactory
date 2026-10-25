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
    /// matching `Signals.DDF.denisovForwardGratingPitch`.
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
}
