//! CLI utility to generate the KiCAD v8 footprint (`.kicad_mod`) and binary
//! GDSII lithography mask (`.gds`) for the `rGO-polyCBD-SS-Lignin` Hyperbolic SFG
//! Cannon Lens and run Design-Rule Checks (DRC) + binary round-trip verification.

use std::env;
use std::path::PathBuf;
use std::process;

use signals_numerical_adapter::cannon_mask_cad::{
    DenisovPitchMode, ProcaCannonMaskSpec, export_gdsii_file, export_kicad_footprint_file,
    generate_mask_polygons, parse_gdsii_bytes, verify_mask_drc,
};

fn main() {
    let mut out_dir = PathBuf::from(".");
    let mut pitch_mode = DenisovPitchMode::ForwardFirstOrder;

    let mut args = env::args().skip(1);
    while let Some(arg) = args.next() {
        match arg.as_str() {
            "--out-dir" => {
                if let Some(dir) = args.next() {
                    out_dir = PathBuf::from(dir);
                } else {
                    eprintln!("--out-dir requires a directory path");
                    process::exit(2);
                }
            }
            "--bragg-pitch" => {
                pitch_mode = DenisovPitchMode::BraggBackReflection;
            }
            "--forward-pitch" => {
                pitch_mode = DenisovPitchMode::ForwardFirstOrder;
            }
            "--help" | "-h" => {
                println!(
                    "Usage: cannon-mask-cad [--out-dir <dir>] [--forward-pitch | --bragg-pitch]"
                );
                return;
            }
            other => {
                eprintln!("unknown argument: {other}");
                process::exit(2);
            }
        }
    }

    if let Err(err) = std::fs::create_dir_all(&out_dir) {
        eprintln!("failed to create output directory {}: {err}", out_dir.display());
        process::exit(1);
    }

    let spec = ProcaCannonMaskSpec {
        pitch_mode,
        ..ProcaCannonMaskSpec::default()
    };
    let features = generate_mask_polygons(&spec);
    let drc = verify_mask_drc(&spec, &features);

    let kicad_path = out_dir.join(format!("{}.kicad_mod", spec.name));
    let gds_path = out_dir.join("polycbd_proca_cannon_800ghz.gds");

    if let Err(err) = export_kicad_footprint_file(&spec, &kicad_path) {
        eprintln!("failed to write KiCAD footprint: {err}");
        process::exit(1);
    }
    let poly_count = match export_gdsii_file(&spec, &gds_path) {
        Ok(c) => c,
        Err(err) => {
            eprintln!("failed to write GDSII mask: {err}");
            process::exit(1);
        }
    };

    let gds_bytes = std::fs::read(&gds_path).expect("read generated GDSII file");
    let parsed = parse_gdsii_bytes(&gds_bytes).expect("round-trip parse generated GDSII file");

    println!(
        "Exported KiCAD v8 footprint: {} ({} polygons)\n\
         Exported GDSII v6.0 stream:  {} ({} bytes, {} boundaries verified)\n\
         DRC: all_positive_area={}, berry_winding_rad={:.6}, \
         bragg_pitch_um={:.2}, forward_pitch_um={:.2}, \
         f_ENZ_400={:.6}, f_ENZ_800={:.6}",
        kicad_path.display(),
        drc.total_polygons,
        gds_path.display(),
        gds_bytes.len(),
        parsed.boundaries.len(),
        drc.all_polygons_have_positive_area,
        drc.berry_phase_winding_rad,
        drc.denisov_bragg_pitch_um,
        drc.denisov_forward_pitch_um,
        drc.zone1_exact_enz_fill,
        drc.zone3_exact_enz_fill,
    );
    assert_eq!(poly_count, parsed.boundaries.len());
}
