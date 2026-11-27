//! Native numerical diagnostics for the Signals Pending boundary.
//!
//! This crate computes finite summaries and validates input metadata.

use std::fmt;

pub mod antimatter_gravity;
pub mod arc_dsl;
pub mod cannon_mask_cad;
pub mod finite_constraint_solvers;
pub mod dft_plabic_vrc;
pub mod double_slit;
pub mod ebr_benchmark;
pub mod layer_groups;
pub mod madelung_lagrangian;
pub mod multi_array_imaging;
pub mod multi_reference_noci;
pub mod navier_stokes;
pub mod orbital_splat;
pub mod photoelectric;
pub mod polariton_spp;
pub mod quantum_causal_inference;
pub mod quantum_trajectories;
pub mod riemann_spectral;
pub mod sato_grassmannian;
pub mod slavnov_dpp;
pub mod tequila_simulator;
pub mod thermal_inelastic;
pub mod yang_mills_higgs_cpt;

#[cfg(feature = "python")]
use pyo3::exceptions::PyValueError;
#[cfg(feature = "python")]
use pyo3::prelude::*;
#[cfg(feature = "python")]
use pyo3::types::{PyDict, PyList};

#[cfg(feature = "python")]
#[pyfunction]
fn py_verify_layer_group<'py>(py: Python<'py>, number: u8) -> PyResult<Bound<'py, PyDict>> {
    let v = layer_groups::verify_layer_group(number)
        .ok_or_else(|| PyValueError::new_err(format!("layer group number must be 1..=80, got {number}")))?;
    let d = PyDict::new(py);
    d.set_item("number", v.number)?;
    d.set_item("symbol", v.symbol)?;
    d.set_item("crystal_system", v.crystal_system)?;
    d.set_item("wallpaper_projection", v.wallpaper_projection)?;
    d.set_item("expected_order", v.expected_order)?;
    d.set_item("actual_order", v.actual_order)?;
    d.set_item("wallpaper_order", v.wallpaper_order)?;
    d.set_item("has_identity", v.has_identity)?;
    d.set_item("closed_under_composition", v.closed_under_composition)?;
    d.set_item("all_have_inverses", v.all_have_inverses)?;
    d.set_item("order_matches", v.order_matches)?;
    Ok(d)
}

#[cfg(feature = "python")]
#[pyfunction]
fn py_verify_all_80_layer_groups<'py>(py: Python<'py>) -> PyResult<Bound<'py, PyList>> {
    let list = PyList::empty(py);
    for num in 1u8..=80 {
        list.append(py_verify_layer_group(py, num)?)?;
    }
    Ok(list)
}

#[cfg(feature = "python")]
#[pyfunction]
fn py_layer_group_orbit(number: u8, u: f64, v: f64, z: f64) -> PyResult<Vec<(f64, f64, f64)>> {
    layer_groups::layer_group_orbit(number, u, v, z)
        .ok_or_else(|| PyValueError::new_err(format!("layer group number must be 1..=80, got {number}")))
}

#[cfg(feature = "python")]
#[pyfunction]
fn py_evaluate_gram_dpp<'py>(
    py: Python<'py>,
    features: Vec<Vec<f64>>,
    eps: f64,
) -> PyResult<Bound<'py, PyDict>> {
    let ev = slavnov_dpp::evaluate_gram_dpp(&features, eps)
        .map_err(|e| PyValueError::new_err(format!("DPP error: {e:?}")))?;
    let d = PyDict::new(py);
    d.set_item("gram", ev.gram)?;
    d.set_item("log_det", ev.log_det)?;
    d.set_item("inverse", ev.inverse)?;
    d.set_item("grad_features", ev.grad_features)?;
    d.set_item("cholesky_diag_ratio_sq", ev.cholesky_diag_ratio_sq)?;
    Ok(d)
}

#[cfg(feature = "python")]
#[pyfunction]
fn py_nqueens_oracle_dpp_coverage<'py>(
    py: Python<'py>,
    size: usize,
    select_k: usize,
    eps: f64,
    orbifold_quotient: bool,
) -> PyResult<Bound<'py, PyDict>> {
    let rep = if orbifold_quotient {
        slavnov_dpp::nqueens_orbifold_dpp_coverage(size, select_k, eps)
    } else {
        slavnov_dpp::nqueens_oracle_dpp_coverage(size, select_k, eps)
    }
    .map_err(|e| PyValueError::new_err(format!("DPP error: {e:?}")))?;
    let d = PyDict::new(py);
    d.set_item("problem", rep.problem)?;
    d.set_item("total_exact_solutions", rep.total_exact_solutions)?;
    d.set_item("requested_k", rep.requested_k)?;
    d.set_item("selected_distinct_solutions", rep.selected_distinct_solutions)?;
    d.set_item("selected_distinct_d4_orbits", rep.selected_distinct_d4_orbits)?;
    d.set_item("final_log_det", rep.final_log_det)?;
    Ok(d)
}

#[cfg(feature = "python")]
#[pyfunction]
fn py_solve_noci_generalized<'py>(
    py: Python<'py>,
    hamiltonian: Vec<Vec<f64>>,
    overlap: Vec<Vec<f64>>,
    overlap_cutoff: f64,
) -> PyResult<Bound<'py, PyDict>> {
    let sol = multi_reference_noci::solve_noci_generalized(&hamiltonian, &overlap, overlap_cutoff)
        .map_err(|e| PyValueError::new_err(format!("NOCI error: {e:?}")))?;
    let d = PyDict::new(py);
    d.set_item("eigenvalues", sol.eigenvalues)?;
    d.set_item("eigenvectors", sol.eigenvectors)?;
    d.set_item("overlap_eigenvalues", sol.overlap_eigenvalues)?;
    d.set_item("retained_rank", sol.retained_rank)?;
    d.set_item("overlap_condition_number", sol.overlap_condition_number)?;
    Ok(d)
}

#[cfg(feature = "python")]
#[pyfunction]
fn py_benchmark_stretched_h2_noci<'py>(
    py: Python<'py>,
    hopping_t: f64,
    onsite_u: f64,
) -> PyResult<Bound<'py, PyDict>> {
    let b = multi_reference_noci::benchmark_stretched_h2_noci(hopping_t, onsite_u)
        .map_err(|e| PyValueError::new_err(format!("NOCI benchmark error: {e:?}")))?;
    let d = PyDict::new(py);
    d.set_item("hopping_t", b.hopping_t)?;
    d.set_item("onsite_u", b.onsite_u)?;
    d.set_item("rhf_energy", b.rhf_energy)?;
    d.set_item("uhf_energy", b.uhf_energy)?;
    d.set_item("uhf_s_squared", b.uhf_s_squared)?;
    d.set_item("noci_2state_energy", b.noci_2state_energy)?;
    d.set_item("noci_2state_s_squared", b.noci_2state_s_squared)?;
    d.set_item("noci_3state_energy", b.noci_3state_energy)?;
    d.set_item("noci_3state_s_squared", b.noci_3state_s_squared)?;
    d.set_item("fci_ground_energy", b.fci_ground_energy)?;
    d.set_item("noci_3state_minus_fci_error", b.noci_3state_minus_fci_error)?;
    d.set_item("tequila_pauli_noci_energy", b.tequila_pauli_noci_energy)?;
    d.set_item("overlap_s01", b.overlap_s01)?;
    Ok(d)
}

#[cfg(feature = "python")]
#[pyfunction]
#[pyo3(signature = (size, trajectories=12, max_steps=120, step_size=0.15, grad_tol=1e-4, dpp_weight=0.02, seed=42))]
fn py_run_ebr_nqueens_benchmark<'py>(
    py: Python<'py>,
    size: usize,
    trajectories: usize,
    max_steps: usize,
    step_size: f64,
    grad_tol: f64,
    dpp_weight: f64,
    seed: u64,
) -> PyResult<Bound<'py, PyDict>> {
    let r = ebr_benchmark::run_ebr_nqueens_benchmark(
        size,
        trajectories,
        max_steps,
        step_size,
        grad_tol,
        dpp_weight,
        seed,
    );
    let d = PyDict::new(py);
    d.set_item("problem", r.problem)?;
    d.set_item("seed", r.seed)?;
    d.set_item("trajectories", r.trajectories)?;
    d.set_item("max_steps", r.max_steps)?;
    d.set_item("dpp_weight", r.dpp_weight)?;
    d.set_item("valid_trajectories", r.valid_trajectories)?;
    d.set_item("pass_at_1", r.pass_at_1)?;
    d.set_item("distinct_valid_solutions", r.distinct_valid_solutions)?;
    d.set_item("distinct_d4_orbits", r.distinct_d4_orbits)?;
    d.set_item("exact_oracle_solutions", r.exact_oracle_solutions)?;
    d.set_item("mean_halting_steps", r.mean_halting_steps)?;
    d.set_item("wall_time_ms", r.wall_time_ms)?;
    Ok(d)
}

#[cfg(feature = "python")]
#[pyfunction]
fn py_extract_grid_objects<'py>(
    py: Python<'py>,
    grid: Vec<Vec<u8>>,
) -> PyResult<Bound<'py, PyList>> {
    let objs = arc_dsl::extract_objects(&grid);
    let list = PyList::empty(py);
    for o in objs {
        let d = PyDict::new(py);
        d.set_item("color", o.color)?;
        d.set_item("area", o.area())?;
        d.set_item("min_row", o.min_row)?;
        d.set_item("max_row", o.max_row)?;
        d.set_item("min_col", o.min_col)?;
        d.set_item("max_col", o.max_col)?;
        d.set_item("aspect_ratio", o.aspect_ratio)?;
        d.set_item("bbox_fill_density", o.bbox_fill_density)?;
        d.set_item("cov_det_2d", o.cov_det_2d)?;
        d.set_item("principal_angle_rad", o.principal_angle_rad)?;
        list.append(d)?;
    }
    Ok(list)
}

#[cfg(feature = "python")]
#[pyfunction]
fn py_apply_d4_grid_op_tequila(grid: Vec<Vec<u8>>, op_name: &str) -> PyResult<Vec<Vec<u16>>> {
    let op = match op_name {
        "rotate90" => arc_dsl::GridOp::Rotate90,
        "rotate180" => arc_dsl::GridOp::Rotate180,
        "rotate270" => arc_dsl::GridOp::Rotate270,
        "flip_horizontal" => arc_dsl::GridOp::FlipHorizontal,
        "flip_vertical" => arc_dsl::GridOp::FlipVertical,
        "transpose" => arc_dsl::GridOp::Transpose,
        other => {
            return Err(PyValueError::new_err(format!(
                "unsupported D4 op_name: {other}"
            )))
        }
    };
    let out = arc_dsl::apply_grid_op_via_tequila_circuit(&grid, &op).ok_or_else(|| {
        PyValueError::new_err("grid must be a non-empty square power-of-two (2^m x 2^m) grid")
    })?;
    Ok(out
        .into_iter()
        .map(|row| row.into_iter().map(u16::from).collect())
        .collect())
}

#[cfg(feature = "python")]
#[pyfunction]
fn py_synthesize_grid_program(
    train_pairs: Vec<(Vec<Vec<u8>>, Vec<Vec<u8>>)>,
    test_input: Vec<Vec<u8>>,
    max_depth: usize,
) -> PyResult<(Vec<String>, Vec<Vec<u16>>)> {
    let prog = arc_dsl::synthesize_grid_program(&train_pairs, max_depth)
        .ok_or_else(|| PyValueError::new_err("no compositional program found within max_depth"))?;
    let op_names: Vec<String> = prog.ops.iter().map(|op| format!("{op:?}")).collect();
    let test_out = arc_dsl::apply_program(&test_input, &prog)
        .into_iter()
        .map(|row| row.into_iter().map(u16::from).collect())
        .collect();
    Ok((op_names, test_out))
}

#[cfg(feature = "python")]
#[pyfunction]
fn py_find_first_n_riemann_zeros<'py>(
    py: Python<'py>,
    count: usize,
) -> PyResult<Bound<'py, PyList>> {
    let zeros = riemann_spectral::find_first_n_riemann_zeros(count);
    let list = PyList::empty(py);
    for z in zeros {
        let d = PyDict::new(py);
        d.set_item("index", z.index)?;
        d.set_item("gamma", z.gamma)?;
        d.set_item("hardy_z_exact", z.hardy_z_exact)?;
        d.set_item("hardy_z_riemann_siegel_c2", z.hardy_z_riemann_siegel_c2)?;
        d.set_item("hardy_z_riemann_siegel_c4", z.hardy_z_riemann_siegel_c4)?;
        d.set_item("zeta_abs", z.zeta_abs)?;
        d.set_item("borwein_zeta_abs", z.borwein_zeta_abs)?;
        d.set_item("z_prime", z.z_prime)?;
        d.set_item("jensen_polya_j", z.jensen_polya_j)?;
        list.append(d)?;
    }
    Ok(list)
}

#[cfg(feature = "python")]
#[pyfunction]
fn py_audit_madelung_bohm_jensen_polya<'py>(
    py: Python<'py>,
    gamma: f64,
) -> PyResult<Bound<'py, PyDict>> {
    let a = riemann_spectral::evaluate_madelung_bohm_jensen_polya(gamma);
    let d = PyDict::new(py);
    d.set_item("gamma", a.gamma)?;
    d.set_item("z0", a.z0)?;
    d.set_item("z_prime", a.z_prime)?;
    d.set_item("z_double_prime", a.z_double_prime)?;
    d.set_item("j_osmotic", a.j_osmotic)?;
    d.set_item("j_bohm", a.j_bohm)?;
    d.set_item("j_total", a.j_total)?;
    d.set_item("bohm_ratio", a.bohm_ratio)?;
    Ok(d)
}

#[cfg(feature = "python")]
#[pyfunction]
fn py_audit_gram_law_and_lehmer<'py>(py: Python<'py>) -> PyResult<Bound<'py, PyDict>> {
    let grams = riemann_spectral::audit_gram_law_window();
    let gram_list = PyList::empty(py);
    for g in grams {
        let gd = PyDict::new(py);
        gd.set_item("gram_index", g.gram_index)?;
        gd.set_item("gram_holds", g.gram_holds)?;
        gd.set_item("gamma", g.point.gamma)?;
        gd.set_item("z0", g.point.z0)?;
        gd.set_item("z_prime", g.point.z_prime)?;
        gd.set_item("z_double_prime", g.point.z_double_prime)?;
        gd.set_item("j_osmotic", g.point.j_osmotic)?;
        gd.set_item("j_bohm", g.point.j_bohm)?;
        gd.set_item("j_total", g.point.j_total)?;
        gd.set_item("bohm_ratio", g.point.bohm_ratio)?;
        gram_list.append(gd)?;
    }
    let lehmer = riemann_spectral::audit_lehmer_1956_pair();
    let ld = PyDict::new(py);
    ld.set_item("gamma_left", lehmer.gamma_left)?;
    ld.set_item("gamma_right", lehmer.gamma_right)?;
    ld.set_item("gap", lehmer.gap)?;
    ld.set_item("extremum_gamma", lehmer.extremum.gamma)?;
    ld.set_item("z0", lehmer.extremum.z0)?;
    ld.set_item("z_prime", lehmer.extremum.z_prime)?;
    ld.set_item("z_double_prime", lehmer.extremum.z_double_prime)?;
    ld.set_item("j_osmotic", lehmer.extremum.j_osmotic)?;
    ld.set_item("j_bohm", lehmer.extremum.j_bohm)?;
    ld.set_item("j_total", lehmer.extremum.j_total)?;
    ld.set_item("bohm_ratio", lehmer.extremum.bohm_ratio)?;

    let out = PyDict::new(py);
    out.set_item("gram_window", gram_list)?;
    out.set_item("lehmer_1956", ld)?;
    Ok(out)
}

#[cfg(feature = "python")]
#[pyfunction]
fn py_compare_rs_c2_vs_c4<'py>(py: Python<'py>, t: f64) -> PyResult<Bound<'py, PyDict>> {
    let c2 = riemann_spectral::hardy_z_riemann_siegel(t);
    let c4_jet = riemann_spectral::hardy_z_riemann_siegel_c4_jet(t);
    let d = PyDict::new(py);
    d.set_item("t", t)?;
    d.set_item("z_rs_c2", c2)?;
    d.set_item("z_rs_c4", c4_jet.v)?;
    d.set_item("z_prime_rs_c4", c4_jet.d1)?;
    d.set_item("z_double_prime_rs_c4", c4_jet.d2)?;
    Ok(d)
}

#[cfg(feature = "python")]
#[pyfunction]
fn py_audit_regular_graphs_bass_ihara<'py>(py: Python<'py>) -> PyResult<Bound<'py, PyList>> {
    let graphs = [
        riemann_spectral::k33_graph_6(),
        riemann_spectral::petersen_graph_10(),
        riemann_spectral::heawood_graph_14(),
        riemann_spectral::mobius_kantor_graph_16(),
        riemann_spectral::barbell_non_ramanujan_14(),
    ];
    let list = PyList::empty(py);
    for (name, deg, adj) in &graphs {
        let rep = riemann_spectral::analyze_regular_graph_bass_ihara(name, *deg, adj);
        let d = PyDict::new(py);
        d.set_item("name", rep.name)?;
        d.set_item("vertices", rep.vertices)?;
        d.set_item("degree", rep.degree)?;
        d.set_item("q", rep.q)?;
        d.set_item("is_regular", rep.is_regular)?;
        d.set_item("is_connected", rep.is_connected)?;
        d.set_item("ramanujan_bound", rep.ramanujan_bound)?;
        d.set_item("eigenvalues", rep.eigenvalues)?;
        d.set_item(
            "max_nontrivial_abs_eigenvalue",
            rep.max_nontrivial_abs_eigenvalue,
        )?;
        d.set_item("markov_spectral_gap", rep.markov_spectral_gap)?;
        d.set_item("ramanujan_margin", rep.ramanujan_margin)?;
        d.set_item("is_ramanujan", rep.is_ramanujan)?;
        d.set_item("nontrivial_off_circle_count", rep.nontrivial_off_circle_count)?;
        let roots_list = PyList::empty(py);
        for r in rep.roots {
            let rd = PyDict::new(py);
            rd.set_item("eigenvalue", r.eigenvalue)?;
            rd.set_item("u_re", r.u_re)?;
            rd.set_item("u_im", r.u_im)?;
            rd.set_item("modulus_sq", r.modulus_sq)?;
            rd.set_item("is_trivial", r.is_trivial)?;
            rd.set_item("on_critical_circle", r.on_critical_circle)?;
            roots_list.append(rd)?;
        }
        d.set_item("roots", roots_list)?;
        list.append(d)?;
    }
    Ok(list)
}

#[cfg(feature = "python")]
#[pyfunction]
#[pyo3(signature = (critical_gammas, max_n, off_line_sigma_dev=None, off_line_gamma=None))]
fn py_li_partial_coefficients(
    critical_gammas: Vec<f64>,
    max_n: usize,
    off_line_sigma_dev: Option<f64>,
    off_line_gamma: Option<f64>,
) -> Vec<f64> {
    let quartet = match (off_line_sigma_dev, off_line_gamma) {
        (Some(s), Some(g)) => Some((s, g)),
        _ => None,
    };
    riemann_spectral::li_partial_coefficients(&critical_gammas, max_n, quartet)
}

#[cfg(feature = "python")]
#[pyfunction]
fn py_audit_celestial_holography_and_turner_graviton<'py>(
    py: Python<'py>,
) -> PyResult<Bound<'py, PyDict>> {
    let rep = riemann_spectral::audit_celestial_holography_and_turner_graviton();
    let d = PyDict::new(py);
    d.set_item("plancherel_bose_max_diff", rep.plancherel_bose_max_diff)?;
    d.set_item("m1_quadrature", rep.m1_quadrature)?;
    d.set_item("m1_exact", rep.m1_exact)?;
    d.set_item("m1_abs_error", rep.m1_abs_error)?;
    d.set_item("m2_quadrature", rep.m2_quadrature)?;
    d.set_item("m2_exact", rep.m2_exact)?;
    d.set_item("m2_abs_error", rep.m2_abs_error)?;
    d.set_item("m3_quadrature", rep.m3_quadrature)?;
    d.set_item("m3_reference", rep.m3_reference)?;
    d.set_item("m3_abs_error", rep.m3_abs_error)?;
    d.set_item("m3_upper_bound", rep.m3_upper_bound)?;
    d.set_item("m3_even_part", rep.m3_even_part)?;
    d.set_item("m3_odd_excess", rep.m3_odd_excess)?;
    d.set_item(
        "plancherel_two_loop_deficit_coeff",
        rep.plancherel_two_loop_deficit_coeff,
    )?;
    d.set_item(
        "googly_principal_series_rel_err",
        rep.googly_principal_series_rel_err,
    )?;
    d.set_item(
        "googly_off_line_symmetry_breaking",
        rep.googly_off_line_symmetry_breaking,
    )?;
    d.set_item("gr24_f2_points", rep.gr24_f2_points)?;
    d.set_item("gr24_f3_points", rep.gr24_f3_points)?;
    d.set_item("gr24_f5_points", rep.gr24_f5_points)?;
    d.set_item("gr24_f7_points", rep.gr24_f7_points)?;
    d.set_item("gr24_rref_matches_polynomial", rep.gr24_rref_matches_polynomial)?;
    d.set_item("cesaro_at_half", rep.cesaro_at_half)?;
    d.set_item("cesaro_at_quarter", rep.cesaro_at_quarter)?;
    d.set_item("cesaro_at_three_quarters", rep.cesaro_at_three_quarters)?;
    d.set_item("cesaro_even_symmetry_diff", rep.cesaro_even_symmetry_diff)?;
    d.set_item(
        "turner_model15_mercury_arcsec_century",
        rep.turner_model15_mercury_arcsec_century,
    )?;
    d.set_item("turner_model15_rel_err_vs_gr", rep.turner_model15_rel_err_vs_gr)?;
    d.set_item(
        "turner_model15_solar_light_bending_arcsec",
        rep.turner_model15_solar_light_bending_arcsec,
    )?;
    d.set_item(
        "turner_model15_cayley_shadow_norm_at_half",
        rep.turner_model15_cayley_shadow_norm_at_half,
    )?;
    d.set_item(
        "turner_model15_cayley_shadow_norm_at_one",
        rep.turner_model15_cayley_shadow_norm_at_one,
    )?;
    d.set_item(
        "turner_model15a_active_laser_deflection",
        rep.turner_model15a_active_laser_deflection,
    )?;
    d.set_item(
        "turner_model15b_active_laser_deflection",
        rep.turner_model15b_active_laser_deflection,
    )?;
    Ok(d)
}

#[cfg(feature = "python")]
#[pyfunction]
fn py_audit_ba_lax_pair<'py>(
    py: Python<'py>,
    k: f64,
    z_re: f64,
    z_im: f64,
    x: f64,
    y: f64,
    t: f64,
) -> PyResult<Bound<'py, PyDict>> {
    let a = sato_grassmannian::evaluate_ba_lax_pair(k, z_re, z_im, x, y, t);
    let d = PyDict::new(py);
    d.set_item("u", a.u)?;
    d.set_item("psi_re", a.psi_re)?;
    d.set_item("psi_im", a.psi_im)?;
    d.set_item("b2_residual_abs", a.b2_residual_abs)?;
    d.set_item("b3_residual_abs", a.b3_residual_abs)?;
    Ok(d)
}

#[cfg(feature = "python")]
#[pyfunction]
fn py_audit_akns_solitons<'py>(
    py: Python<'py>,
    amp: f64,
    x: f64,
    t: f64,
) -> PyResult<Bound<'py, PyDict>> {
    let a = sato_grassmannian::evaluate_akns_solitons(amp, x, t);
    let d = PyDict::new(py);
    d.set_item("bright_abs", a.bright_abs)?;
    d.set_item("bright_nls_residual_abs", a.bright_nls_residual_abs)?;
    d.set_item("dark_abs", a.dark_abs)?;
    d.set_item("dark_gpe_residual_abs", a.dark_gpe_residual_abs)?;
    Ok(d)
}

#[cfg(feature = "python")]
#[pyfunction]
fn py_audit_dual_schubert_qfim<'py>(
    py: Python<'py>,
    rho_fwd: [f64; 6],
    drho_fwd: [f64; 6],
    dphi_fwd: [f64; 6],
    rho_dual: [f64; 6],
    drho_dual: [f64; 6],
    dphi_dual: [f64; 6],
) -> PyResult<Bound<'py, PyDict>> {
    let a = sato_grassmannian::evaluate_dual_schubert_qfim(
        rho_fwd, drho_fwd, dphi_fwd, rho_dual, drho_dual, dphi_dual,
    );
    let d = PyDict::new(py);
    d.set_item("fq_forward", a.fq_forward)?;
    d.set_item("bohm_forward", a.bohm_forward)?;
    d.set_item("phase_forward", a.phase_forward)?;
    d.set_item("geometric_forward", a.geometric_forward)?;
    d.set_item("forward_identity_residual", a.forward_identity_residual)?;
    d.set_item("fq_dual", a.fq_dual)?;
    d.set_item("bohm_dual", a.bohm_dual)?;
    d.set_item("phase_dual", a.phase_dual)?;
    d.set_item("geometric_dual", a.geometric_dual)?;
    d.set_item("fq_total_six_channel", a.fq_total_six_channel)?;
    d.set_item("total_identity_residual", a.total_identity_residual)?;
    Ok(d)
}

#[cfg(feature = "python")]
#[pyfunction]
fn py_audit_sharoglazova_klaers_evanescent_qfim<'py>(
    py: Python<'py>,
    hbar: f64,
    mass: f64,
    e_abs: f64,
    j0: f64,
    x: f64,
) -> PyResult<Bound<'py, PyDict>> {
    let a = sato_grassmannian::evaluate_sharoglazova_klaers_evanescent_qfim(hbar, mass, e_abs, j0, x)
        .map_err(pyo3::exceptions::PyValueError::new_err)?;
    let d = PyDict::new(py);
    d.set_item("kappa_bar", a.kappa_bar)?;
    d.set_item("delta_kappa", a.delta_kappa)?;
    d.set_item("fubini_study_xx", a.fubini_study_xx)?;
    d.set_item("qfim_xx", a.qfim_xx)?;
    d.set_item("ch1_bohm_speed_sq", a.ch1_bohm_speed_sq)?;
    d.set_item("ch2_osmotic_speed_sq", a.ch2_osmotic_speed_sq)?;
    d.set_item("ch3_qfim_speed_sq", a.ch3_qfim_speed_sq)?;
    d.set_item("total_v_eff_sq", a.total_v_eff_sq)?;
    d.set_item("theoretical_v_eff_sq", a.theoretical_v_eff_sq)?;
    d.set_item("speed_law_residual", a.speed_law_residual)?;
    Ok(d)
}

#[cfg(feature = "python")]
#[pyfunction]
fn py_audit_carleman_euler_products<'py>(
    py: Python<'py>,
    sigma: f64,
    t: f64,
    prime_limit: usize,
) -> PyResult<Bound<'py, PyDict>> {
    let a = sato_grassmannian::evaluate_carleman_euler_products(sigma, t, prime_limit);
    let d = PyDict::new(py);
    d.set_item("prime_count", a.prime_count)?;
    d.set_item("det1_abs", a.det1_abs)?;
    d.set_item("det2_abs", a.det2_abs)?;
    d.set_item("det3_abs", a.det3_abs)?;
    d.set_item("det3_re", a.det3_re)?;
    d.set_item("det3_im", a.det3_im)?;
    d.set_item("sum_p_neg_2sigma", a.sum_p_neg_2sigma)?;
    d.set_item("sum_p_neg_3sigma", a.sum_p_neg_3sigma)?;
    d.set_item(
        "det2_multiplicative_anomaly_residual",
        a.det2_multiplicative_anomaly_residual,
    )?;
    Ok(d)
}

#[cfg(feature = "python")]
#[pyfunction]
fn py_audit_weil_gaussian_quad_form<'py>(
    py: Python<'py>,
    zeros: Vec<(f64, f64, u32)>,
    coeffs: Vec<f64>,
    shifts: Vec<f64>,
    off_line_gamma: f64,
    off_line_eta: f64,
) -> PyResult<Bound<'py, PyDict>> {
    let a = sato_grassmannian::evaluate_weil_gaussian_quad_form(
        &zeros,
        &coeffs,
        &shifts,
        off_line_gamma,
        off_line_eta,
    );
    let d = PyDict::new(py);
    d.set_item("quad_form_re", a.quad_form_re)?;
    d.set_item("quad_form_im", a.quad_form_im)?;
    d.set_item("off_line_witness_value", a.off_line_witness_value)?;
    d.set_item("theoretical_neg_4pi_bound", a.theoretical_neg_4pi_bound)?;
    Ok(d)
}

#[cfg(feature = "python")]
#[pyfunction]
fn py_audit_segal_wilson_gr24_tau<'py>(
    py: Python<'py>,
    v: [f64; 4],
    w: [f64; 4],
    t1: f64,
    t2: f64,
    t3: f64,
) -> PyResult<Bound<'py, PyDict>> {
    let a = sato_grassmannian::evaluate_segal_wilson_gr24_tau(v, w, t1, t2, t3)
        .map_err(PyValueError::new_err)?;
    let d = PyDict::new(py);
    d.set_item("det_fredholm_re", a.det_fredholm_re)?;
    d.set_item("det_fredholm_im", a.det_fredholm_im)?;
    d.set_item("tau_u_over_p23_re", a.tau_u_over_p23_re)?;
    d.set_item("tau_u_over_p23_im", a.tau_u_over_p23_im)?;
    d.set_item("mismatch_abs", a.mismatch_abs)?;
    Ok(d)
}

#[cfg(feature = "python")]
#[pyfunction]
fn py_audit_riemann_spectral_bridge<'py>(
    py: Python<'py>,
    sigma_dev: f64,
    gamma: f64,
    z0: f64,
    t: f64,
    dz: f64,
    a0: f64,
    a1: f64,
    a2: f64,
) -> PyResult<Bound<'py, PyDict>> {
    let a = sato_grassmannian::evaluate_riemann_spectral_bridge(
        sigma_dev, gamma, z0, t, dz, a0, a1, a2,
    );
    let d = PyDict::new(py);
    d.set_item("li_modulus_sq", a.li_modulus_sq)?;
    d.set_item("cayley_norm_sq", a.cayley_norm_sq)?;
    d.set_item("li_cayley_mismatch", a.li_cayley_mismatch)?;
    d.set_item("dbn_quad_heat", a.dbn_quad_heat)?;
    d.set_item("neg_local_double_zero_re", a.neg_local_double_zero_re)?;
    d.set_item("dbn_mismatch", a.dbn_mismatch)?;
    d.set_item("jensen_turan", a.jensen_turan)?;
    d.set_item("madelung_osmotic_plus_bohm", a.madelung_osmotic_plus_bohm)?;
    d.set_item("jensen_mismatch", a.jensen_mismatch)?;
    Ok(d)
}

#[cfg(feature = "python")]
#[pyfunction]
fn py_audit_carleman_det3_anomaly<'py>(
    py: Python<'py>,
    sigma: f64,
    t: f64,
    prime_limit: usize,
) -> PyResult<Bound<'py, PyDict>> {
    let a = sato_grassmannian::evaluate_carleman_det3_anomaly(sigma, t, prime_limit);
    let d = PyDict::new(py);
    d.set_item("prime_count", a.prime_count)?;
    d.set_item("det1_mul_residual", a.det1_mul_residual)?;
    d.set_item("det3_anomaly_residual", a.det3_anomaly_residual)?;
    d.set_item("det3_a_abs", a.det3_a_abs)?;
    d.set_item("det3_b_abs", a.det3_b_abs)?;
    d.set_item("det3_ab_abs", a.det3_ab_abs)?;
    d.set_item("anomaly_exp_abs", a.anomaly_exp_abs)?;
    Ok(d)
}

#[cfg(feature = "python")]
#[pyfunction]
fn py_audit_weil_infinite_tail<'py>(
    py: Python<'py>,
    gammas: Vec<f64>,
    off_line_gamma: f64,
    off_line_eta: f64,
) -> PyResult<Bound<'py, PyDict>> {
    let a = sato_grassmannian::evaluate_weil_infinite_tail_audit(
        &gammas,
        off_line_gamma,
        off_line_eta,
    );
    let d = PyDict::new(py);
    d.set_item("core_witness_re", a.core_witness_re)?;
    d.set_item("tail_abs_sum", a.tail_abs_sum)?;
    d.set_item("tail_re_sum", a.tail_re_sum)?;
    d.set_item("full_sum_re", a.full_sum_re)?;
    d.set_item("theoretical_neg_4pi_bound", a.theoretical_neg_4pi_bound)?;
    Ok(d)
}

#[cfg(feature = "python")]
#[pyfunction]
fn py_audit_finite_dim_fredholm_det<'py>(
    py: Python<'py>,
    a: f64,
    b: f64,
    c: f64,
    d_val: f64,
    shear: f64,
    rot_theta: f64,
) -> PyResult<Bound<'py, PyDict>> {
    let r = sato_grassmannian::evaluate_finite_dim_fredholm_det(a, b, c, d_val, shear, rot_theta);
    let d = PyDict::new(py);
    d.set_item("nilpotent_shear_det_re", r.nilpotent_shear_det_re)?;
    d.set_item("nilpotent_shear_err", r.nilpotent_shear_err)?;
    d.set_item("block_lower_det_re", r.block_lower_det_re)?;
    d.set_item("expected_ad_minus_bc", r.expected_ad_minus_bc)?;
    d.set_item("block_lower_err", r.block_lower_err)?;
    d.set_item("conj_invariance_err", r.conj_invariance_err)?;
    Ok(d)
}

#[cfg(feature = "python")]
#[pyfunction]
fn py_audit_finite_rank_invariant_det<'py>(
    py: Python<'py>,
    v: [f64; 4],
    w: [f64; 4],
    t1: f64,
    t2: f64,
    t3: f64,
) -> PyResult<Bound<'py, PyDict>> {
    let r = sato_grassmannian::evaluate_finite_rank_invariant_det(v, w, t1, t2, t3)
        .map_err(PyValueError::new_err)?;
    let d = PyDict::new(py);
    d.set_item("ambient_dim", r.ambient_dim)?;
    d.set_item("invariant_dim", r.invariant_dim)?;
    d.set_item("invariance_residual", r.invariance_residual)?;
    d.set_item("orth_ker_residual", r.orth_ker_residual)?;
    d.set_item("det_v_re", r.det_v_re)?;
    d.set_item("det_w_re", r.det_w_re)?;
    d.set_item("tau_over_p23_re", r.tau_over_p23_re)?;
    d.set_item("subspace_indep_err", r.subspace_indep_err)?;
    d.set_item("det_vs_tau_err", r.det_vs_tau_err)?;
    Ok(d)
}

#[cfg(feature = "python")]
#[pyfunction]
fn py_audit_strip_gaussian_combo_decay<'py>(
    py: Python<'py>,
    gammas: Vec<f64>,
    coeffs: Vec<f64>,
    delta: f64,
    strip_b: f64,
) -> PyResult<Bound<'py, PyDict>> {
    let r = sato_grassmannian::evaluate_strip_gaussian_combo_decay(
        &gammas, &coeffs, delta, strip_b,
    );
    let d = PyDict::new(py);
    d.set_item("strip_constant", r.strip_constant)?;
    d.set_item("max_bound_ratio", r.max_bound_ratio)?;
    d.set_item("subgaussian_density_sum", r.subgaussian_density_sum)?;
    d.set_item("weil_strip_re", r.weil_strip_re)?;
    Ok(d)
}

#[cfg(feature = "python")]
#[pyfunction]
fn py_audit_schubert_chart_transition_vortex<'py>(
    py: Python<'py>,
    eps: f64,
    x: f64,
    y: f64,
) -> PyResult<Bound<'py, PyDict>> {
    let a = navier_stokes::evaluate_schubert_chart_transition_vortex(eps, x, y);
    let d = PyDict::new(py);
    d.set_item("p01_abs", a.p01_abs)?;
    d.set_item("p02_abs", a.p02_abs)?;
    d.set_item("klein_quadric_residual", a.klein_quadric_residual)?;
    d.set_item("cancellation_residual", a.cancellation_residual)?;
    d.set_item("omega02_u01_abs", a.omega02_u01_abs)?;
    d.set_item("omega02_u13_identity_residual", a.omega02_u13_identity_residual)?;
    d.set_item("qfim_regularized_at_node", a.qfim_regularized_at_node)?;
    d.set_item("chart_switched_to_omega02", a.chart_switched_to_omega02)?;
    Ok(d)
}

#[cfg(feature = "python")]
#[pyfunction]
#[allow(clippy::too_many_arguments)]
fn py_audit_bateman_vs_chat_heff<'py>(
    py: Python<'py>,
    e_val: f64,
    hbar: f64,
    nu: f64,
    k: f64,
    psi_re: f64,
    psi_im: f64,
    psit_re: f64,
    psit_im: f64,
) -> PyResult<Bound<'py, PyDict>> {
    let a = navier_stokes::evaluate_bateman_vs_chat_heff(
        e_val, hbar, nu, k, psi_re, psi_im, psit_re, psit_im,
    )
    .map_err(PyValueError::new_err)?;
    let d = PyDict::new(py);
    d.set_item("chat_hermiticity_residual", a.chat_hermiticity_residual)?;
    d.set_item("chat_total_norm_rate", a.chat_total_norm_rate)?;
    d.set_item("bateman_primal_norm_rate", a.bateman_primal_norm_rate)?;
    d.set_item("bateman_expected_primal_rate", a.bateman_expected_primal_rate)?;
    d.set_item("bateman_dual_norm_rate", a.bateman_dual_norm_rate)?;
    d.set_item("bateman_pairing_rate_abs", a.bateman_pairing_rate_abs)?;
    Ok(d)
}

#[cfg(feature = "python")]
#[pyfunction]
#[allow(clippy::too_many_arguments)]
fn py_audit_clebsch_spinor_vorticity<'py>(
    py: Python<'py>,
    hbar: f64,
    mass: f64,
    theta: f64,
    dtheta_x: f64,
    dtheta_y: f64,
    dphi1_x: f64,
    dphi1_y: f64,
    dphi2_x: f64,
    dphi2_y: f64,
) -> PyResult<Bound<'py, PyDict>> {
    let a = navier_stokes::evaluate_clebsch_spinor_vorticity(
        hbar, mass, theta, dtheta_x, dtheta_y, dphi1_x, dphi1_y, dphi2_x, dphi2_y,
    )
    .map_err(PyValueError::new_err)?;
    let d = PyDict::new(py);
    d.set_item("unit_norm_residual", a.unit_norm_residual)?;
    d.set_item("berry_velocity_x", a.berry_velocity_x)?;
    d.set_item("berry_velocity_y", a.berry_velocity_y)?;
    d.set_item("qfim_xx", a.qfim_xx)?;
    d.set_item("fubini_study_xx", a.fubini_study_xx)?;
    d.set_item("qfim_identity_residual", a.qfim_identity_residual)?;
    d.set_item("vorticity_z", a.vorticity_z)?;
    Ok(d)
}

#[cfg(feature = "python")]
#[pyfunction]
#[allow(clippy::too_many_arguments)]
fn py_audit_taylor_green_2d<'py>(
    py: Python<'py>,
    rho0: f64,
    u0: f64,
    nu: f64,
    k: f64,
    x: f64,
    y: f64,
    t: f64,
) -> PyResult<Bound<'py, PyDict>> {
    let a = navier_stokes::evaluate_taylor_green_2d(rho0, u0, nu, k, x, y, t)
        .map_err(PyValueError::new_err)?;
    let d = PyDict::new(py);
    d.set_item("u", a.u)?;
    d.set_item("v", a.v)?;
    d.set_item("pressure", a.pressure)?;
    d.set_item("vorticity", a.vorticity)?;
    d.set_item("div_residual", a.div_residual)?;
    d.set_item("mom_x_residual", a.mom_x_residual)?;
    d.set_item("mom_y_residual", a.mom_y_residual)?;
    d.set_item("energy", a.energy)?;
    d.set_item("enstrophy", a.enstrophy)?;
    d.set_item("energy_enstrophy_decay_residual", a.energy_enstrophy_decay_residual)?;
    d.set_item("ch2_osmotic_energy", a.ch2_osmotic_energy)?;
    Ok(d)
}

#[cfg(feature = "python")]
#[pyfunction]
fn py_audit_lamb_oseen_2d<'py>(
    py: Python<'py>,
    gamma: f64,
    nu: f64,
    x: f64,
    y: f64,
    t: f64,
) -> PyResult<Bound<'py, PyDict>> {
    let a = navier_stokes::evaluate_lamb_oseen_2d(gamma, nu, x, y, t)
        .map_err(PyValueError::new_err)?;
    let d = PyDict::new(py);
    d.set_item("vorticity", a.vorticity)?;
    d.set_item("peak_core_vorticity", a.peak_core_vorticity)?;
    d.set_item("heat_pde_residual", a.heat_pde_residual)?;
    Ok(d)
}

#[cfg(feature = "python")]
#[pyfunction]
#[allow(clippy::too_many_arguments)]
fn py_audit_beltrami_abc_3d<'py>(
    py: Python<'py>,
    rho0: f64,
    a_amp: f64,
    b_amp: f64,
    c_amp: f64,
    nu: f64,
    k: f64,
    x: f64,
    y: f64,
    z: f64,
    t: f64,
) -> PyResult<Bound<'py, PyDict>> {
    let a = navier_stokes::evaluate_beltrami_abc_3d(rho0, a_amp, b_amp, c_amp, nu, k, x, y, z, t)
        .map_err(PyValueError::new_err)?;
    let d = PyDict::new(py);
    d.set_item("eigen_curl_residual", a.eigen_curl_residual)?;
    d.set_item("laplacian_residual", a.laplacian_residual)?;
    d.set_item("momentum_max_residual", a.momentum_max_residual)?;
    d.set_item("helicity", a.helicity)?;
    Ok(d)
}

#[cfg(feature = "python")]
#[pyfunction]
fn py_audit_viscous_burgers_cole_hopf<'py>(
    py: Python<'py>,
    c: f64,
    a_amp: f64,
    nu: f64,
    x: f64,
    t: f64,
) -> PyResult<Bound<'py, PyDict>> {
    let a = navier_stokes::evaluate_viscous_burgers_cole_hopf(c, a_amp, nu, x, t)
        .map_err(PyValueError::new_err)?;
    let d = PyDict::new(py);
    d.set_item("velocity", a.velocity)?;
    d.set_item("burgers_pde_residual", a.burgers_pde_residual)?;
    d.set_item("cole_hopf_tau_heat_residual", a.cole_hopf_tau_heat_residual)?;
    d.set_item("cole_hopf_velocity_residual", a.cole_hopf_velocity_residual)?;
    Ok(d)
}

#[cfg(feature = "python")]
#[pyfunction]
#[allow(clippy::too_many_arguments)]
fn py_audit_compressible_nsk_korteweg_bd<'py>(
    py: Python<'py>,
    hbar: f64,
    mass: f64,
    mu: f64,
    zeta: f64,
    rho: f64,
    rho_x: f64,
    rho_xx: f64,
    rho_xxx: f64,
    s11: f64,
    s22: f64,
    s33: f64,
    s12: f64,
    s13: f64,
    s23: f64,
    v: f64,
    cs: f64,
    k: f64,
) -> PyResult<Bound<'py, PyDict>> {
    let a = navier_stokes::evaluate_compressible_nsk_korteweg_bd(
        hbar, mass, mu, zeta, rho, rho_x, rho_xx, rho_xxx, s11, s22, s33, s12, s13, s23, v, cs, k,
    )
    .map_err(PyValueError::new_err)?;
    let d = PyDict::new(py);
    d.set_item("viscous_dissipation", a.viscous_dissipation)?;
    d.set_item("dissipation_split_residual", a.dissipation_split_residual)?;
    d.set_item("korteweg_force_residual", a.korteweg_force_residual)?;
    d.set_item("bd_dual_schubert_residual", a.bd_dual_schubert_residual)?;
    d.set_item("stokes_omega_re", a.stokes_omega_re)?;
    d.set_item("stokes_omega_im", a.stokes_omega_im)?;
    d.set_item("stokes_dispersion_residual", a.stokes_dispersion_residual)?;
    Ok(d)
}

#[cfg(feature = "python")]
#[pyfunction]
fn py_audit_riccati_grassmann_projection<'py>(
    py: Python<'py>,
    e_val: f64,
    hbar: f64,
    nu: f64,
    k: f64,
    theta: f64,
) -> PyResult<Bound<'py, PyDict>> {
    let a = navier_stokes::evaluate_riccati_grassmann_projection(e_val, hbar, nu, k, theta)
        .map_err(PyValueError::new_err)?;
    let d = PyDict::new(py);
    d.set_item("orthonormality_residual", a.orthonormality_residual)?;
    d.set_item(
        "horizontal_orthogonality_residual",
        a.horizontal_orthogonality_residual,
    )?;
    d.set_item("gram_rate_residual", a.gram_rate_residual)?;
    Ok(d)
}

#[cfg(feature = "python")]
#[pyfunction]
#[allow(clippy::too_many_arguments)]
fn py_audit_bogoliubov_korteweg_stokes_and_rh<'py>(
    py: Python<'py>,
    hbar: f64,
    mass: f64,
    g0: f64,
    rho0: f64,
    nu: f64,
    zeta: f64,
    k: f64,
    gamma_vort: f64,
    r_vort: f64,
    t_vort: f64,
    div_f_qfim: f64,
    rho_l: f64,
    u_l: f64,
    rho_r: f64,
    u_r: f64,
) -> PyResult<Bound<'py, PyDict>> {
    let a = navier_stokes::evaluate_bogoliubov_korteweg_stokes_and_rh(
        hbar, mass, g0, rho0, nu, zeta, k, gamma_vort, r_vort, t_vort, div_f_qfim, rho_l, u_l,
        rho_r, u_r,
    )
    .map_err(PyValueError::new_err)?;
    let d = PyDict::new(py);
    d.set_item("bogoliubov_stokes_omega_re", a.bogoliubov_stokes_omega_re)?;
    d.set_item("bogoliubov_stokes_omega_im", a.bogoliubov_stokes_omega_im)?;
    d.set_item(
        "bogoliubov_stokes_dispersion_residual",
        a.bogoliubov_stokes_dispersion_residual,
    )?;
    d.set_item("ddf_bogoliubov_bridge_residual", a.ddf_bogoliubov_bridge_residual)?;
    d.set_item("lamb_oseen_curl_residual", a.lamb_oseen_curl_residual)?;
    d.set_item("isf_spin_tension_gap", a.isf_spin_tension_gap)?;
    d.set_item("rh_shock_speed", a.rh_shock_speed)?;
    d.set_item("rh_mass_flux_residual", a.rh_mass_flux_residual)?;
    d.set_item("rh_momentum_flux_residual", a.rh_momentum_flux_residual)?;
    Ok(d)
}

#[cfg(feature = "python")]
#[pyfunction]
#[allow(clippy::too_many_arguments)]
fn py_audit_einstein_photoelectric<'py>(
    py: Python<'py>,
    h_planck: f64,
    nu: f64,
    e_vac: f64,
    e_fermi: f64,
    intensity: f64,
    area_atom: f64,
    occ_lambda: f64,
) -> PyResult<Bound<'py, PyDict>> {
    let a = photoelectric::evaluate_einstein_photoelectric(
        h_planck, nu, e_vac, e_fermi, intensity, area_atom, occ_lambda,
    )
    .map_err(PyValueError::new_err)?;
    let d = PyDict::new(py);
    d.set_item("work_function", a.work_function)?;
    d.set_item("threshold_frequency", a.threshold_frequency)?;
    d.set_item("kinetic_energy_max", a.kinetic_energy_max)?;
    d.set_item("emits_electron", a.emits_electron)?;
    d.set_item("classical_rayleigh_delay", a.classical_rayleigh_delay)?;
    d.set_item("mcweeny_purified_occupancy", a.mcweeny_purified_occupancy)?;
    d.set_item("mcweeny_defect_at_half", a.mcweeny_defect_at_half)?;
    Ok(d)
}

#[cfg(feature = "python")]
#[pyfunction]
#[allow(clippy::too_many_arguments)]
fn py_audit_keldysh_strong_field<'py>(
    py: Python<'py>,
    phi_w: f64,
    q_charge: f64,
    e0_amp: f64,
    mass_e: f64,
    omega: f64,
    hbar: f64,
    n_photons: f64,
    s_ati: f64,
    j0: f64,
    x_tunnel: f64,
) -> PyResult<Bound<'py, PyDict>> {
    let a = photoelectric::evaluate_keldysh_strong_field(
        phi_w, q_charge, e0_amp, mass_e, omega, hbar, n_photons, s_ati, j0, x_tunnel,
    )
    .map_err(PyValueError::new_err)?;
    let d = PyDict::new(py);
    d.set_item("ponderomotive_energy", a.ponderomotive_energy)?;
    d.set_item("keldysh_gamma_sq", a.keldysh_gamma_sq)?;
    d.set_item("keldysh_gamma", a.keldysh_gamma)?;
    d.set_item("ati_peak_energy", a.ati_peak_energy)?;
    d.set_item("tunneling_width", a.tunneling_width)?;
    d.set_item("barrier_kappa", a.barrier_kappa)?;
    d.set_item("osmotic_speed_sq", a.osmotic_speed_sq)?;
    d.set_item("bohm_relative_error", a.bohm_relative_error)?;
    d.set_item("plucker_qfim_relative_error", a.plucker_qfim_relative_error)?;
    d.set_item("coupled_ch1_bohm_speed_sq", a.coupled_ch1_bohm_speed_sq)?;
    d.set_item("coupled_ch3_qfim_speed_sq", a.coupled_ch3_qfim_speed_sq)?;
    d.set_item("coupled_speed_law_residual", a.coupled_speed_law_residual)?;
    Ok(d)
}

#[cfg(feature = "python")]
#[pyfunction]
#[allow(clippy::too_many_arguments)]
fn py_audit_enz_oam_photoemission<'py>(
    py: Python<'py>,
    eps_air: f64,
    eps_enz: f64,
    e0_field: f64,
    theta_rad: f64,
    l_in: i64,
    sigma_sam: i64,
    n_probes: f64,
    f_transverse: f64,
    dp_z: f64,
    p_z: f64,
) -> PyResult<Bound<'py, PyDict>> {
    let a = photoelectric::evaluate_enz_oam_photoemission(
        eps_air,
        eps_enz,
        e0_field,
        theta_rad,
        l_in,
        sigma_sam,
        n_probes,
        f_transverse,
        dp_z,
        p_z,
    )
    .map_err(PyValueError::new_err)?;
    let d = PyDict::new(py);
    d.set_item("enz_intensity_enhancement", a.enz_intensity_enhancement)?;
    d.set_item("debye_wolf_ez_amplitude", a.debye_wolf_ez_amplitude)?;
    d.set_item("paraxial_jones_ez_rel_error", a.paraxial_jones_ez_rel_error)?;
    d.set_item("total_oam_charge_z", a.total_oam_charge_z)?;
    d.set_item("oam_fubini_study_phi", a.oam_fubini_study_phi)?;
    d.set_item("oam_qfim_phi", a.oam_qfim_phi)?;
    d.set_item("qcrb_variance_at_l", a.qcrb_variance_at_l)?;
    d.set_item("qcrb_variance_at_l1", a.qcrb_variance_at_l1)?;
    d.set_item("euler_gimbal_lock_det_pi_half", a.euler_gimbal_lock_det_pi_half)?;
    d.set_item("poincare_qfim_theta", a.poincare_qfim_theta)?;
    d.set_item("poincare_fs_theta", a.poincare_fs_theta)?;
    d.set_item("vectorial_3d_fisher", a.vectorial_3d_fisher)?;
    Ok(d)
}

#[cfg(feature = "python")]
#[pyfunction]
#[allow(clippy::too_many_arguments)]
fn py_audit_soliton_two_pathway_photoemission<'py>(
    py: Python<'py>,
    amp_nls: f64,
    x: f64,
    t: f64,
    q_charge: f64,
    mass_e: f64,
    omega: f64,
    phi_w: f64,
    p1: f64,
    p2: f64,
    dp1: f64,
    dphi1: f64,
    dphi2: f64,
) -> PyResult<Bound<'py, PyDict>> {
    let a = photoelectric::evaluate_soliton_two_pathway_photoemission(
        amp_nls, x, t, q_charge, mass_e, omega, phi_w, p1, p2, dp1, dphi1, dphi2,
    )
    .map_err(PyValueError::new_err)?;
    let d = PyDict::new(py);
    d.set_item("nls_bright_abs_sq", a.nls_bright_abs_sq)?;
    d.set_item("nls_bright_pde_residual", a.nls_bright_pde_residual)?;
    d.set_item("gpe_dark_pde_residual", a.gpe_dark_pde_residual)?;
    d.set_item("soliton_peak_ponderomotive", a.soliton_peak_ponderomotive)?;
    d.set_item("soliton_local_ponderomotive", a.soliton_local_ponderomotive)?;
    d.set_item("soliton_peak_keldysh_gamma", a.soliton_peak_keldysh_gamma)?;
    d.set_item("coherent_two_pathway_yield", a.coherent_two_pathway_yield)?;
    d.set_item("unphased_gr_pos_yield", a.unphased_gr_pos_yield)?;
    d.set_item("unphased_rel_error", a.unphased_rel_error)?;
    d.set_item("coherent_rel_error", a.coherent_rel_error)?;
    d.set_item("two_channel_phase_variance_val", a.two_channel_phase_variance_val)?;
    d.set_item("qfim_simplex_total", a.qfim_simplex_total)?;
    d.set_item("fubini_study_simplex_total", a.fubini_study_simplex_total)?;
    Ok(d)
}

#[cfg(feature = "python")]
#[pyfunction]
#[allow(clippy::too_many_arguments)]
fn py_audit_polariton_plasmon_photoemission<'py>(
    py: Python<'py>,
    eps_d: f64,
    abs_eps_m: f64,
    wavelength_0: f64,
    q_charge: f64,
    e0_amp: f64,
    mass_e: f64,
    omega: f64,
    phi_w: f64,
    h_nu: f64,
    m_plasmon: f64,
    hbar_wp: f64,
    omega_ph: f64,
    omega_ex: f64,
    rabi_g: f64,
    eps_inf: f64,
    omega_to: f64,
    omega_lo: f64,
    omega_rest: f64,
    x1: f64,
    x2: f64,
) -> PyResult<Bound<'py, PyDict>> {
    let a = photoelectric::evaluate_polariton_plasmon_photoemission(
        eps_d,
        abs_eps_m,
        wavelength_0,
        q_charge,
        e0_amp,
        mass_e,
        omega,
        phi_w,
        h_nu,
        m_plasmon,
        hbar_wp,
        omega_ph,
        omega_ex,
        rabi_g,
        eps_inf,
        omega_to,
        omega_lo,
        omega_rest,
        x1,
        x2,
    )
    .map_err(PyValueError::new_err)?;
    let d = PyDict::new(py);
    d.set_item("spp_effective_index_sq", a.spp_effective_index_sq)?;
    d.set_item("spp_skin_depth_ratio", a.spp_skin_depth_ratio)?;
    d.set_item("spp_gr24_channel_ratio", a.spp_gr24_channel_ratio)?;
    d.set_item(
        "spp_conductor_to_dielectric_bohm_ratio",
        a.spp_conductor_to_dielectric_bohm_ratio,
    )?;
    d.set_item("spp_mode_area_compression", a.spp_mode_area_compression)?;
    d.set_item("spp_keldysh_gamma_sq", a.spp_keldysh_gamma_sq)?;
    d.set_item("free_keldysh_gamma_sq", a.free_keldysh_gamma_sq)?;
    d.set_item("bulk_plasmon_enz_permittivity", a.bulk_plasmon_enz_permittivity)?;
    d.set_item(
        "plasmon_satellite_kinetic_energy",
        a.plasmon_satellite_kinetic_energy,
    )?;
    d.set_item("polariton_up_lp_splitting", a.polariton_up_lp_splitting)?;
    d.set_item(
        "polariton_hopfield_photon_weight",
        a.polariton_hopfield_photon_weight,
    )?;
    d.set_item(
        "polariton_hopfield_matter_weight",
        a.polariton_hopfield_matter_weight,
    )?;
    d.set_item("lst_enz_permittivity_lo", a.lst_enz_permittivity_lo)?;
    d.set_item(
        "lst_reststrahlen_permittivity",
        a.lst_reststrahlen_permittivity,
    )?;
    d.set_item("vrc_resonant_norm_sq", a.vrc_resonant_norm_sq)?;
    d.set_item("vrc_resonant_fs_x1", a.vrc_resonant_fs_x1)?;
    d.set_item("vrc_resonant_qfim_x1", a.vrc_resonant_qfim_x1)?;
    Ok(d)
}

#[cfg(feature = "python")]
#[pyfunction]
fn py_audit_antimatter_alpha_g<'py>(py: Python<'py>) -> PyResult<Bound<'py, PyDict>> {
    let suite = antimatter_gravity::evaluate_alpha_g_model_suite()
        .map_err(PyValueError::new_err)?;
    let d = PyDict::new(py);
    d.set_item("total_sigma", suite.total_sigma)?;
    d.set_item("calibrated_sigma_b", suite.calibrated_sigma_b)?;
    d.set_item("e_gamma_kev", suite.e_gamma_kev)?;
    d.set_item("two_photon_invariant_mass_kev", suite.two_photon_invariant_mass_kev)?;
    d.set_item(
        "witten_gamma_conf_2sigma_upper_bound_inv_m",
        suite.witten_gamma_conf_2sigma_upper_bound_inv_m,
    )?;
    d.set_item(
        "witten_gamma_conf_2sigma_lower_bound_inv_m",
        suite.witten_gamma_conf_2sigma_lower_bound_inv_m,
    )?;
    d.set_item("bias_scan_g", suite.bias_scan_g)?;
    d.set_item("p_down_normal_wep", suite.p_down_normal_wep)?;
    d.set_item("p_down_zero_g", suite.p_down_zero_g)?;
    d.set_item("p_down_antigravity", suite.p_down_antigravity)?;
    let model_list = PyList::empty(py);
    for m_eval in suite.models {
        let md = PyDict::new(py);
        md.set_item("model_name", m_eval.model_name)?;
        md.set_item("predicted_a_over_g0", m_eval.predicted_a_over_g0)?;
        md.set_item("eta_act_gamma", m_eval.eta_act_gamma)?;
        md.set_item(
            "active_mass_deficit_fraction",
            m_eval.active_mass_deficit_fraction,
        )?;
        md.set_item("z_score", m_eval.z_score)?;
        md.set_item("chi_sq", m_eval.chi_sq)?;
        md.set_item("consistent_within_2sigma", m_eval.consistent_within_2sigma)?;
        md.set_item("active_mass_conserved", m_eval.active_mass_conserved)?;
        md.set_item(
            "zero_bias_downward_fraction",
            m_eval.zero_bias_downward_fraction,
        )?;
        model_list.append(md)?;
    }
    d.set_item("models", model_list)?;
    Ok(d)
}

#[cfg(feature = "python")]
#[pyfunction]
fn py_audit_celestial_ir_and_turner_model16<'py>(py: Python<'py>) -> PyResult<Bound<'py, PyDict>> {
    let rep = riemann_spectral::audit_celestial_ir_and_turner_model16();
    let d = PyDict::new(py);
    d.set_item("rg_sigma_dev_su3", rep.rg_sigma_dev_su3)?;
    d.set_item("rg_casimir_im_nonzero", rep.rg_casimir_im_nonzero)?;
    d.set_item("k_ir_uv_at_zero", rep.k_ir_uv_at_zero)?;
    d.set_item("k_ir_uv_at_one", rep.k_ir_uv_at_one)?;
    d.set_item("k_ir_uv_unreg_limit_diff", rep.k_ir_uv_unreg_limit_diff)?;
    d.set_item("kl_mellin_mgap_1", rep.kl_mellin_mgap_1)?;
    d.set_item("kl_mellin_mgap_0_vs_gamma", rep.kl_mellin_mgap_0_vs_gamma)?;
    d.set_item("kl_mellin_delta1_mgap_half", rep.kl_mellin_delta1_mgap_half)?;
    d.set_item(
        "yukawa_mellin_quad_vs_gamma_diff",
        rep.yukawa_mellin_quad_vs_gamma_diff,
    )?;
    d.set_item("s_ir_zero", rep.s_ir_zero)?;
    d.set_item("s_ir_half", rep.s_ir_half)?;
    d.set_item(
        "s_ir_quadratic_margin_half",
        rep.s_ir_quadratic_margin_half,
    )?;
    d.set_item(
        "model16_uv_core_vs_ir_gap_ordering",
        rep.model16_uv_core_vs_ir_gap_ordering,
    )?;
    d.set_item("g16_classical", rep.g16_classical)?;
    d.set_item("g16_off_line_positive", rep.g16_off_line_positive)?;
    d.set_item(
        "model16a_mercury_arcsec_cy",
        rep.model16a_mercury_arcsec_cy,
    )?;
    d.set_item(
        "model16b_mercury_arcsec_cy",
        rep.model16b_mercury_arcsec_cy,
    )?;
    d.set_item("model16_rel_err_vs_gr", rep.model16_rel_err_vs_gr)?;
    d.set_item(
        "model16_solar_light_bending_arcsec",
        rep.model16_solar_light_bending_arcsec,
    )?;
    d.set_item("model16a_gw_below_gap", rep.model16a_gw_below_gap)?;
    d.set_item("model16b_gw_gapless_ratio", rep.model16b_gw_gapless_ratio)?;
    d.set_item(
        "model16a_active_laser_deflection",
        rep.model16a_active_laser_deflection,
    )?;
    d.set_item(
        "model16b_active_laser_deflection",
        rep.model16b_active_laser_deflection,
    )?;
    d.set_item("d_cft_4d_re_delta", rep.d_cft_4d_re_delta)?;
    Ok(d)
}

#[cfg(feature = "python")]
#[pyfunction]
fn py_audit_yang_mills_higgs_cpt<'py>(py: Python<'py>) -> PyResult<Bound<'py, PyDict>> {
    let rep = yang_mills_higgs_cpt::audit_yang_mills_higgs_cpt();
    let d = PyDict::new(py);
    d.set_item("su3_beta0", rep.su3_beta0)?;
    d.set_item("lambda_ym_gev", rep.lambda_ym_gev)?;
    d.set_item("toupin_m1_mev", rep.toupin_m1_mev)?;
    d.set_item("toupin_sugawara_m1_mev", rep.toupin_sugawara_m1_mev)?;
    d.set_item(
        "casimir_suppression_c2_3_over_c2_0",
        rep.casimir_suppression_c2_3_over_c2_0,
    )?;
    d.set_item(
        "strong_coupling_gap_lower_bound",
        rep.strong_coupling_gap_lower_bound,
    )?;
    d.set_item("haar_projector_idemp_err", rep.haar_projector_idemp_err)?;
    d.set_item("haar_projector_herm_err", rep.haar_projector_herm_err)?;
    d.set_item(
        "haar_projector_nonsinglet_max",
        rep.haar_projector_nonsinglet_max,
    )?;
    d.set_item(
        "s3_haar_projector_idemp_err",
        rep.s3_haar_projector_idemp_err,
    )?;
    d.set_item("s3_haar_projector_trace", rep.s3_haar_projector_trace)?;
    d.set_item(
        "s3_haar_projector_2d_irrep_res",
        rep.s3_haar_projector_2d_irrep_res,
    )?;
    d.set_item("vev_gev", rep.higgs_ssb.vev_gev)?;
    d.set_item("m_h_gev", rep.higgs_ssb.m_h_gev)?;
    d.set_item("m_w_gev", rep.higgs_ssb.m_w_gev)?;
    d.set_item("m_z_gev", rep.higgs_ssb.m_z_gev)?;
    d.set_item("sin_sq_theta_w", rep.higgs_ssb.sin_sq_theta_w)?;
    d.set_item("rho_ew", rep.higgs_ssb.rho_ew)?;
    d.set_item(
        "tadpole_expansion_residual",
        rep.higgs_ssb.tadpole_expansion_residual,
    )?;
    d.set_item("jarlskog_sm", rep.jarlskog_sm)?;
    d.set_item("jarlskog_degenerate_zero", rep.jarlskog_degenerate_zero)?;
    d.set_item(
        "jarlskog_physical_splitting_nonzero",
        rep.jarlskog_physical_splitting_nonzero,
    )?;
    d.set_item("higgs_cp_asym_sm", rep.higgs_cp_asym_sm)?;
    d.set_item("higgs_cp_asym_bsm", rep.higgs_cp_asym_bsm)?;
    d.set_item(
        "sakharov_equilibrium_baryon_trace",
        rep.sakharov_equilibrium_baryon_trace,
    )?;
    d.set_item(
        "sakharov_out_of_equilibrium_baryon_trace",
        rep.sakharov_out_of_equilibrium_baryon_trace,
    )?;
    d.set_item("jost_antiunitary_err", rep.jost_antiunitary_err)?;
    d.set_item("jost_involution_sign", rep.jost_involution_sign)?;
    d.set_item("jost_involution_err", rep.jost_involution_err)?;
    d.set_item("jost_cpt_commutator_err", rep.jost_cpt_commutator_err)?;
    d.set_item("jost_mass_equality_err", rep.jost_mass_equality_err)?;
    d.set_item(
        "jost_fermionic_kramers_mass_err",
        rep.jost_fermionic_kramers_mass_err,
    )?;
    d.set_item(
        "cp_violation_norm_when_delta_nonzero",
        rep.cp_violation_norm_when_delta_nonzero,
    )?;
    d.set_item(
        "t_violation_norm_when_delta_nonzero",
        rep.t_violation_norm_when_delta_nonzero,
    )?;
    d.set_item(
        "cp_t_commutator_zero_when_delta_zero",
        rep.cp_t_commutator_zero_when_delta_zero,
    )?;
    d.set_item("lattice_spacing_beta58", rep.lattice_spacing_beta58)?;
    d.set_item("lattice_spacing_beta62", rep.lattice_spacing_beta62)?;
    d.set_item(
        "lattice_spacing_two_loop_beta62",
        rep.lattice_spacing_two_loop_beta62,
    )?;
    d.set_item(
        "strong_coupling_breakdown_at_18",
        rep.strong_coupling_breakdown_at_18,
    )?;
    d.set_item(
        "os_reflection_factorization_err",
        rep.os_reflection_factorization_err,
    )?;
    d.set_item("os_reflection_min_quad", rep.os_reflection_min_quad)?;
    d.set_item("os_min_principal_minor", rep.os_min_principal_minor)?;
    d.set_item("os_effective_mass_gev", rep.os_effective_mass_gev)?;
    d.set_item("os_clustering_excess", rep.os_clustering_excess)?;
    d.set_item(
        "toupin_gko_max_mev_at_220",
        rep.toupin_gko_max_mev_at_220,
    )?;
    d.set_item(
        "toupin_k_eff_for_lattice_1610",
        rep.toupin_k_eff_for_lattice_1610,
    )?;
    d.set_item("toupin_k_eff_mass_err", rep.toupin_k_eff_mass_err)?;
    d.set_item(
        "atlas_higgs_cp_max_kappatilde",
        rep.atlas_higgs_cp_max_kappatilde,
    )?;
    d.set_item("ewpt_sm_phic_over_tc", rep.ewpt_sm_phic_over_tc)?;
    d.set_item("ewpt_bsm_phic_over_tc", rep.ewpt_bsm_phic_over_tc)?;
    d.set_item("ewpt_bsm_degeneracy_err", rep.ewpt_bsm_degeneracy_err)?;
    d.set_item(
        "ewpt_bsm_barrier_height_over_tc4",
        rep.ewpt_bsm_barrier_height_over_tc4,
    )?;
    Ok(d)
}

#[cfg(feature = "python")]
#[pyfunction]
fn py_audit_qci_one_shot_sysid<'py>(py: Python<'py>) -> PyResult<Bound<'py, PyDict>> {
    let (cb_gram_det, cb_plucker_sq) = quantum_causal_inference::osid_cauchy_binet_2x3_gram_and_plucker(
        [1.2, -0.5, 2.3],
        [0.4, 1.7, -0.9],
    );
    let ac = quantum_causal_inference::audit_osid_allen_cahn_pde();
    let lor = quantum_causal_inference::audit_osid_lorenz_ode();
    let mat = quantum_causal_inference::audit_osid_matrix_circulant_hankel_and_switch();
    let qjl = quantum_causal_inference::audit_osid_noisy_jeffrey_qfim_landauer();
    let d = PyDict::new(py);
    d.set_item("cb_gram_det", cb_gram_det)?;
    d.set_item("cb_plucker_sq", cb_plucker_sq)?;
    d.set_item("ac_generic_rank", ac.generic_rank)?;
    d.set_item("ac_generic_coeffs", ac.generic_coeffs.to_vec())?;
    d.set_item("ac_generic_max_coeff_err", ac.generic_max_coeff_err)?;
    d.set_item("ac_generic_sigma_min", ac.generic_sigma_min)?;
    d.set_item("ac_generic_gram_det", ac.generic_gram_det)?;
    d.set_item("ac_degenerate_rank", ac.degenerate_rank)?;
    d.set_item("ac_degenerate_sigma_min", ac.degenerate_sigma_min)?;
    d.set_item("ac_degenerate_gram_det", ac.degenerate_gram_det)?;
    d.set_item("ac_cross_lag_q4_residual", ac.cross_lag_q4_residual)?;
    d.set_item("lorenz_rank", lor.rank)?;
    d.set_item("lorenz_recovered_sigma", lor.recovered_sigma)?;
    d.set_item("lorenz_recovered_rho", lor.recovered_rho)?;
    d.set_item("lorenz_recovered_beta", lor.recovered_beta)?;
    d.set_item("lorenz_max_param_err", lor.max_param_err)?;
    d.set_item("lorenz_sigma_min", lor.sigma_min)?;
    d.set_item("lorenz_obs_confounded_slope", lor.obs_confounded_slope)?;
    d.set_item("lorenz_do_deconfounded_slope", lor.do_deconfounded_slope)?;
    d.set_item("lorenz_abduced_exogenous_u", lor.abduced_exogenous_u)?;
    d.set_item("circulant_rank_1shot", mat.circulant_rank_1shot)?;
    d.set_item("circulant_max_err", mat.circulant_max_err)?;
    d.set_item("circulant_gram_det", mat.circulant_gram_det)?;
    d.set_item("hankel_1shot_rows", mat.hankel_1shot_rows)?;
    d.set_item("hankel_1shot_cols", mat.hankel_1shot_cols)?;
    d.set_item("hankel_1shot_rank", mat.hankel_1shot_rank)?;
    d.set_item("hankel_2shot_rank", mat.hankel_2shot_rank)?;
    d.set_item("hankel_2shot_max_err", mat.hankel_2shot_max_err)?;
    d.set_item("hankel_2x2_two_probe_det", mat.hankel_2x2_two_probe_det)?;
    d.set_item("switch_e_sym", mat.switch_e_sym)?;
    d.set_item("switch_e_anti", mat.switch_e_anti)?;
    d.set_item("switch_plucker_ratio", mat.switch_plucker_ratio)?;
    d.set_item("vrc_destructive_minor", mat.vrc_destructive_minor)?;
    d.set_item("jeffrey_do_estimate", qjl.jeffrey_do_estimate)?;
    d.set_item("quantum_jeffrey_phase_avg", qjl.quantum_jeffrey_phase_avg)?;
    d.set_item("qfim", qjl.qfim)?;
    d.set_item("qcrb_1shot_var_bound", qjl.qcrb_1shot_var_bound)?;
    d.set_item("qcrb_4shot_var_bound", qjl.qcrb_4shot_var_bound)?;
    d.set_item("landauer_1shot_closed_heat", qjl.landauer_1shot_closed_heat)?;
    d.set_item("landauer_10shot_closed_heat", qjl.landauer_10shot_closed_heat)?;
    Ok(d)
}

#[cfg(feature = "python")]
#[pyfunction]
fn py_audit_qci_one_shot_sysid_literature_benchmarks<'py>(
    py: Python<'py>,
) -> PyResult<Bound<'py, PyDict>> {
    let duf = quantum_causal_inference::audit_osid_duffing_oscillator();
    let pdes = quantum_causal_inference::audit_osid_2d_pdes_allen_cahn_elliptic_ns();
    let qr = quantum_causal_inference::audit_osid_qi_ranard_hamiltonian();
    let zg = quantum_causal_inference::audit_osid_zhao_and_goswami_literature_benchmarks();
    let d = PyDict::new(py);
    d.set_item("duffing_rank", duf.rank)?;
    d.set_item("duffing_theta_udd", duf.theta_udd)?;
    d.set_item("duffing_alpha", duf.recovered_alpha)?;
    d.set_item("duffing_delta", duf.recovered_delta)?;
    d.set_item("duffing_beta", duf.recovered_beta)?;
    d.set_item("duffing_gamma", duf.recovered_gamma)?;
    d.set_item("duffing_max_coeff_err", duf.max_coeff_err)?;
    d.set_item("duffing_sigma_min", duf.sigma_min)?;
    d.set_item("allen_cahn_2d_rank", pdes.allen_cahn_2d_rank)?;
    d.set_item("allen_cahn_2d_max_coeff_err", pdes.allen_cahn_2d_max_coeff_err)?;
    d.set_item("elliptic_coprime_rank", pdes.elliptic_coprime_rank)?;
    d.set_item("elliptic_coprime_gram_det", pdes.elliptic_coprime_gram_det)?;
    d.set_item("elliptic_coprime_ray_residual", pdes.elliptic_coprime_ray_residual)?;
    d.set_item("elliptic_multimode_rank", pdes.elliptic_multimode_rank)?;
    d.set_item("elliptic_multimode_max_err", pdes.elliptic_multimode_max_err)?;
    d.set_item("ns_continuity_rank", pdes.ns_continuity_rank)?;
    d.set_item("ns_continuity_sigma4", pdes.ns_continuity_sigma4)?;
    d.set_item("ns_continuity_max_coeff_err", pdes.ns_continuity_max_coeff_err)?;
    d.set_item("qi_ranard_num_qubits", qr.num_qubits)?;
    d.set_item("qi_ranard_local_basis_dim", qr.local_basis_dim)?;
    d.set_item("qi_ranard_hilbert_dim", qr.hilbert_dim)?;
    d.set_item("qi_ranard_lambda1", qr.correlation_lambda1)?;
    d.set_item("qi_ranard_lambda2", qr.correlation_lambda2)?;
    d.set_item("qi_ranard_angle_err_rad", qr.projective_angle_err_rad)?;
    d.set_item("qi_ranard_max_scaled_coeff_err", qr.max_scaled_coeff_err)?;
    d.set_item("bairey_commutator_residual", qr.bairey_commutator_residual)?;
    d.set_item("zhao_n5_switch_fisher", zg.zhao_n5_switch_fisher)?;
    d.set_item("zhao_n5_switch_rmse_ideal", zg.zhao_n5_switch_rmse_ideal)?;
    d.set_item("zhao_n5_switch_rmse_het", zg.zhao_n5_switch_rmse_het)?;
    d.set_item("zhao_n5_fixed_heisenberg_bound", zg.zhao_n5_fixed_heisenberg_bound)?;
    d.set_item("zhao_n15_switch_fisher", zg.zhao_n15_switch_fisher)?;
    d.set_item("zhao_n15_switch_rmse_ideal", zg.zhao_n15_switch_rmse_ideal)?;
    d.set_item("zhao_n15_fixed_heisenberg_bound", zg.zhao_n15_fixed_heisenberg_bound)?;
    d.set_item("zhao_n15_advantage_ratio", zg.zhao_n15_advantage_ratio)?;
    d.set_item("goswami_ideal_witness", zg.goswami_ideal_witness)?;
    d.set_item("goswami_exp_witness", zg.goswami_exp_witness)?;
    d.set_item("goswami_sigma", zg.goswami_sigma)?;
    d.set_item("goswami_z_ideal_bound", zg.goswami_z_ideal_bound)?;
    d.set_item("goswami_z_misaligned_bound", zg.goswami_z_misaligned_bound)?;
    Ok(d)
}

#[cfg(feature = "python")]
#[pymodule]
fn signals_numerical_adapter(m: &Bound<'_, PyModule>) -> PyResult<()> {
    m.add_function(wrap_pyfunction!(
        tequila_simulator::py_simulate_circuit_msb,
        m
    )?)?;
    m.add_function(wrap_pyfunction!(
        tequila_simulator::py_expectation_pauli_hamiltonian_msb,
        m
    )?)?;
    m.add_function(wrap_pyfunction!(
        tequila_simulator::py_sample_statevector_msb,
        m
    )?)?;
    m.add_function(wrap_pyfunction!(
        tequila_simulator::py_mcweeny_purify_density_matrix,
        m
    )?)?;
    m.add_function(wrap_pyfunction!(
        tequila_simulator::py_analyze_grassmann_qci_state,
        m
    )?)?;
    m.add_function(wrap_pyfunction!(
        tequila_simulator::py_simulate_grassmann_plucker_hcb,
        m
    )?)?;
    m.add_function(wrap_pyfunction!(
        tequila_simulator::py_simulate_noisy_density_msb,
        m
    )?)?;
    m.add_function(wrap_pyfunction!(
        tequila_simulator::py_simulate_quantum_trajectories_mcwf_msb,
        m
    )?)?;
    m.add_function(wrap_pyfunction!(py_verify_layer_group, m)?)?;
    m.add_function(wrap_pyfunction!(py_verify_all_80_layer_groups, m)?)?;
    m.add_function(wrap_pyfunction!(py_layer_group_orbit, m)?)?;
    m.add_function(wrap_pyfunction!(py_evaluate_gram_dpp, m)?)?;
    m.add_function(wrap_pyfunction!(py_nqueens_oracle_dpp_coverage, m)?)?;
    m.add_function(wrap_pyfunction!(py_solve_noci_generalized, m)?)?;
    m.add_function(wrap_pyfunction!(py_benchmark_stretched_h2_noci, m)?)?;
    m.add_function(wrap_pyfunction!(py_run_ebr_nqueens_benchmark, m)?)?;
    m.add_function(wrap_pyfunction!(py_extract_grid_objects, m)?)?;
    m.add_function(wrap_pyfunction!(py_apply_d4_grid_op_tequila, m)?)?;
    m.add_function(wrap_pyfunction!(py_synthesize_grid_program, m)?)?;
    m.add_function(wrap_pyfunction!(py_find_first_n_riemann_zeros, m)?)?;
    m.add_function(wrap_pyfunction!(py_compare_rs_c2_vs_c4, m)?)?;
    m.add_function(wrap_pyfunction!(py_audit_madelung_bohm_jensen_polya, m)?)?;
    m.add_function(wrap_pyfunction!(py_audit_gram_law_and_lehmer, m)?)?;
    m.add_function(wrap_pyfunction!(py_audit_regular_graphs_bass_ihara, m)?)?;
    m.add_function(wrap_pyfunction!(py_li_partial_coefficients, m)?)?;
    m.add_function(wrap_pyfunction!(
        py_audit_celestial_holography_and_turner_graviton,
        m
    )?)?;
    m.add_function(wrap_pyfunction!(py_audit_ba_lax_pair, m)?)?;
    m.add_function(wrap_pyfunction!(py_audit_akns_solitons, m)?)?;
    m.add_function(wrap_pyfunction!(py_audit_dual_schubert_qfim, m)?)?;
    m.add_function(wrap_pyfunction!(
        py_audit_sharoglazova_klaers_evanescent_qfim,
        m
    )?)?;
    m.add_function(wrap_pyfunction!(py_audit_carleman_euler_products, m)?)?;
    m.add_function(wrap_pyfunction!(py_audit_weil_gaussian_quad_form, m)?)?;
    m.add_function(wrap_pyfunction!(py_audit_segal_wilson_gr24_tau, m)?)?;
    m.add_function(wrap_pyfunction!(py_audit_riemann_spectral_bridge, m)?)?;
    m.add_function(wrap_pyfunction!(py_audit_carleman_det3_anomaly, m)?)?;
    m.add_function(wrap_pyfunction!(py_audit_weil_infinite_tail, m)?)?;
    m.add_function(wrap_pyfunction!(py_audit_finite_dim_fredholm_det, m)?)?;
    m.add_function(wrap_pyfunction!(py_audit_finite_rank_invariant_det, m)?)?;
    m.add_function(wrap_pyfunction!(py_audit_strip_gaussian_combo_decay, m)?)?;
    m.add_function(wrap_pyfunction!(
        py_audit_schubert_chart_transition_vortex,
        m
    )?)?;
    m.add_function(wrap_pyfunction!(py_audit_bateman_vs_chat_heff, m)?)?;
    m.add_function(wrap_pyfunction!(py_audit_clebsch_spinor_vorticity, m)?)?;
    m.add_function(wrap_pyfunction!(py_audit_taylor_green_2d, m)?)?;
    m.add_function(wrap_pyfunction!(py_audit_lamb_oseen_2d, m)?)?;
    m.add_function(wrap_pyfunction!(py_audit_beltrami_abc_3d, m)?)?;
    m.add_function(wrap_pyfunction!(py_audit_viscous_burgers_cole_hopf, m)?)?;
    m.add_function(wrap_pyfunction!(py_audit_compressible_nsk_korteweg_bd, m)?)?;
    m.add_function(wrap_pyfunction!(
        py_audit_riccati_grassmann_projection,
        m
    )?)?;
    m.add_function(wrap_pyfunction!(
        py_audit_bogoliubov_korteweg_stokes_and_rh,
        m
    )?)?;
    m.add_function(wrap_pyfunction!(py_audit_einstein_photoelectric, m)?)?;
    m.add_function(wrap_pyfunction!(py_audit_keldysh_strong_field, m)?)?;
    m.add_function(wrap_pyfunction!(py_audit_enz_oam_photoemission, m)?)?;
    m.add_function(wrap_pyfunction!(
        py_audit_soliton_two_pathway_photoemission,
        m
    )?)?;
    m.add_function(wrap_pyfunction!(
        py_audit_polariton_plasmon_photoemission,
        m
    )?)?;
    m.add_function(wrap_pyfunction!(py_audit_antimatter_alpha_g, m)?)?;
    m.add_function(wrap_pyfunction!(
        py_audit_celestial_ir_and_turner_model16,
        m
    )?)?;
    m.add_function(wrap_pyfunction!(py_audit_yang_mills_higgs_cpt, m)?)?;
    m.add_function(wrap_pyfunction!(py_audit_qci_one_shot_sysid, m)?)?;
    m.add_function(wrap_pyfunction!(
        py_audit_qci_one_shot_sysid_literature_benchmarks,
        m
    )?)?;
    m.add_class::<tequila_simulator::RustFastCircuit>()?;
    m.add_class::<tequila_simulator::RustFastHamiltonianSet>()?;
    m.add_class::<sato_grassmannian::Kp2Jet>()?;
    m.add_class::<sato_grassmannian::PlabicGr24Solver>()?;
    m.add_class::<navier_stokes::IncompressibleSnapshot2D>()?;
    m.add_class::<navier_stokes::IncompressibleDualSchubertSolver2D>()?;
    m.add_class::<navier_stokes::CompressibleSnapshot1D>()?;
    m.add_class::<navier_stokes::CompressibleNskDualSchubertSolver1D>()?;
    Ok(())
}

#[cfg(feature = "cylinder")]
pub mod cylinder;

#[cfg(feature = "jhtdb")]
pub mod jhtdb;

/// A finite measured or simulated data origin.
#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum FlowDataOrigin {
    Measured,
    Simulated,
}

/// One time-indexed flow snapshot retained by the numerical adapter.
#[derive(Clone, Debug, PartialEq)]
pub struct FlowSnapshot {
    pub time: f64,
    pub pressure: f64,
    pub diagnostic: MadelungSample,
}

impl FlowSnapshot {
    pub fn validate(&self, tolerance: f64) -> Result<(), ValidationError> {
        require_finite("time", self.time)?;
        require_finite("pressure", self.pressure)?;
        self.diagnostic.validate(tolerance)
    }
}

/// Provenance metadata required before an artifact enters the numerical path.
#[derive(Clone, Debug, Eq, PartialEq)]
pub struct DatasetMetadata {
    pub artifact_reference: String,
    pub artifact_checksum: String,
    pub license_reference: String,
    pub unit_convention: String,
    pub calibration_reference: String,
    pub execution_context: String,
}

impl DatasetMetadata {
    pub fn validate(&self) -> Result<(), ValidationError> {
        let fields = [
            ("artifact_reference", &self.artifact_reference),
            ("artifact_checksum", &self.artifact_checksum),
            ("license_reference", &self.license_reference),
            ("unit_convention", &self.unit_convention),
            ("calibration_reference", &self.calibration_reference),
            ("execution_context", &self.execution_context),
        ];
        for (name, value) in fields {
            if value.trim().is_empty() {
                return Err(ValidationError::MissingMetadata(name));
            }
        }
        Ok(())
    }
}

/// A validated finite measured or simulated flow dataset.
#[derive(Clone, Debug, PartialEq)]
pub struct FlowDataset {
    pub origin: FlowDataOrigin,
    pub case_name: String,
    pub source_label: String,
    pub metadata: DatasetMetadata,
    pub snapshots: Vec<FlowSnapshot>,
    pub affine_velocity_rate: [f64; 3],
    pub ftle_window: f64,
}

impl FlowDataset {
    pub fn validate(&self, tolerance: f64) -> Result<(), ValidationError> {
        self.metadata.validate()?;
        if self.case_name.trim().is_empty() {
            return Err(ValidationError::MissingMetadata("case_name"));
        }
        if self.source_label.trim().is_empty() {
            return Err(ValidationError::MissingMetadata("source_label"));
        }
        if self.snapshots.is_empty() {
            return Err(ValidationError::EmptyDataset);
        }
        require_positive("ftle_window", self.ftle_window)?;
        for rate in self.affine_velocity_rate {
            require_finite("affine_velocity_rate", rate)?;
        }
        let mut previous_time = None;
        for snapshot in &self.snapshots {
            snapshot.validate(tolerance)?;
            if let Some(previous) = previous_time
                && snapshot.time <= previous
            {
                return Err(ValidationError::NonMonotonicTime);
            }
            previous_time = Some(snapshot.time);
        }
        Ok(())
    }

    pub fn affine_ftle(&self) -> Result<f64, ValidationError> {
        diagonal_affine_ftle(self.affine_velocity_rate, self.ftle_window)
    }
}

/// The relationship between source time coordinates and stored field rows.
#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum TimeAxisPolicy {
    Exact,
    PrefixByOne,
}

/// One spatial row from an external compressible-flow field dataset.
#[derive(Clone, Debug, PartialEq)]
pub struct FlowFieldSnapshot {
    pub time: f64,
    pub density: Vec<f64>,
    pub pressure: Vec<f64>,
    pub velocity_x: Vec<f64>,
}

impl FlowFieldSnapshot {
    fn validate(&self, spatial_count: usize) -> Result<(), ValidationError> {
        require_finite("field_time", self.time)?;
        if self.density.len() != spatial_count
            || self.pressure.len() != spatial_count
            || self.velocity_x.len() != spatial_count
        {
            return Err(ValidationError::ShapeMismatch("flow snapshot fields"));
        }
        for value in &self.density {
            require_finite("density", *value)?;
        }
        for value in &self.pressure {
            require_finite("pressure", *value)?;
        }
        for value in &self.velocity_x {
            require_finite("velocity_x", *value)?;
        }
        Ok(())
    }
}

/// A validated external measured or solver-produced field dataset.
#[derive(Clone, Debug, PartialEq)]
pub struct FlowFieldDataset {
    pub origin: FlowDataOrigin,
    pub case_name: String,
    pub source_label: String,
    pub metadata: DatasetMetadata,
    pub coordinates: Vec<f64>,
    pub time_coordinates: Vec<f64>,
    pub snapshots: Vec<FlowFieldSnapshot>,
    pub time_axis_policy: TimeAxisPolicy,
}

impl FlowFieldDataset {
    pub fn validate(&self, tolerance: f64) -> Result<(), ValidationError> {
        self.metadata.validate()?;
        if self.case_name.trim().is_empty() {
            return Err(ValidationError::MissingMetadata("case_name"));
        }
        if self.source_label.trim().is_empty() {
            return Err(ValidationError::MissingMetadata("source_label"));
        }
        require_nonnegative("coordinate_tolerance", tolerance)?;
        if self.coordinates.is_empty()
            || self.time_coordinates.is_empty()
            || self.snapshots.is_empty()
        {
            return Err(ValidationError::EmptyDataset);
        }

        let mut previous_coordinate = None;
        for coordinate in &self.coordinates {
            require_finite("coordinate", *coordinate)?;
            if let Some(previous) = previous_coordinate
                && *coordinate <= previous
            {
                return Err(ValidationError::NonMonotonicCoordinate("x-coordinate"));
            }
            previous_coordinate = Some(*coordinate);
        }

        match self.time_axis_policy {
            TimeAxisPolicy::Exact if self.time_coordinates.len() != self.snapshots.len() => {
                return Err(ValidationError::CoordinateLengthMismatch("time-coordinate"));
            }
            TimeAxisPolicy::PrefixByOne
                if self.time_coordinates.len() != self.snapshots.len() + 1 =>
            {
                return Err(ValidationError::CoordinateLengthMismatch("time-coordinate"));
            }
            _ => {}
        }

        let mut previous_time = None;
        for (index, time) in self.time_coordinates.iter().enumerate() {
            require_finite("time-coordinate", *time)?;
            if let Some(previous) = previous_time
                && *time <= previous
            {
                return Err(ValidationError::NonMonotonicTime);
            }
            previous_time = Some(*time);
            if index < self.snapshots.len()
                && (self.snapshots[index].time - *time).abs() > tolerance
            {
                return Err(ValidationError::CoordinateMismatch("snapshot time"));
            }
        }

        let mut previous_snapshot_time = None;
        for snapshot in &self.snapshots {
            snapshot.validate(self.coordinates.len())?;
            if let Some(previous) = previous_snapshot_time
                && snapshot.time <= previous
            {
                return Err(ValidationError::NonMonotonicTime);
            }
            previous_snapshot_time = Some(snapshot.time);
        }
        Ok(())
    }

    pub fn spatial_count(&self) -> usize {
        self.coordinates.len()
    }

    pub fn snapshot_count(&self) -> usize {
        self.snapshots.len()
    }

    pub fn max_abs_velocity_x(&self) -> f64 {
        self.snapshots
            .iter()
            .flat_map(|snapshot| snapshot.velocity_x.iter())
            .map(|value| value.abs())
            .fold(0.0, f64::max)
    }
}

/// A vector field frame with optional pressure, velocity gradients, and mask.
#[derive(Clone, Debug, PartialEq)]
pub struct VectorFieldFrame {
    pub time: f64,
    pub velocity: Vec<[f64; 3]>,
    pub pressure: Option<Vec<f64>>,
    pub velocity_gradient: Option<Vec<[[f64; 3]; 3]>>,
    pub valid_mask: Option<Vec<bool>>,
}

/// A common summary boundary for measured or solver-produced vector fields.
#[derive(Clone, Debug, PartialEq)]
pub struct VectorFieldDataset {
    pub origin: FlowDataOrigin,
    pub case_name: String,
    pub source_label: String,
    pub metadata: DatasetMetadata,
    pub points: Vec<[f64; 3]>,
    pub times: Vec<f64>,
    pub frames: Vec<VectorFieldFrame>,
    pub spatial_interpolation: String,
    pub temporal_interpolation: String,
}

impl VectorFieldDataset {
    pub fn validate(&self, tolerance: f64) -> Result<(), ValidationError> {
        self.metadata.validate()?;
        if self.case_name.trim().is_empty() {
            return Err(ValidationError::MissingMetadata("case_name"));
        }
        if self.source_label.trim().is_empty() {
            return Err(ValidationError::MissingMetadata("source_label"));
        }
        if self.spatial_interpolation.trim().is_empty() {
            return Err(ValidationError::MissingMetadata("spatial_interpolation"));
        }
        if self.temporal_interpolation.trim().is_empty() {
            return Err(ValidationError::MissingMetadata("temporal_interpolation"));
        }
        require_nonnegative("vector_field_tolerance", tolerance)?;
        if self.points.is_empty() || self.times.is_empty() || self.frames.is_empty() {
            return Err(ValidationError::EmptyDataset);
        }
        if self.times.len() != self.frames.len() {
            return Err(ValidationError::ShapeMismatch(
                "vector field time/frame count",
            ));
        }
        for point in &self.points {
            for coordinate in point {
                require_finite("point_coordinate", *coordinate)?;
            }
        }
        let mut previous_time = None;
        for (index, time) in self.times.iter().enumerate() {
            require_finite("vector_field_time", *time)?;
            if let Some(previous) = previous_time
                && *time <= previous
            {
                return Err(ValidationError::NonMonotonicTime);
            }
            previous_time = Some(*time);
            if (self.frames[index].time - *time).abs() > tolerance {
                return Err(ValidationError::CoordinateMismatch("vector frame time"));
            }
            self.frames[index].validate(self.points.len())?;
        }
        Ok(())
    }
}

impl VectorFieldFrame {
    fn validate(&self, point_count: usize) -> Result<(), ValidationError> {
        require_finite("vector_field_frame_time", self.time)?;
        if self.velocity.len() != point_count {
            return Err(ValidationError::ShapeMismatch("velocity point count"));
        }
        if let Some(pressure) = &self.pressure
            && pressure.len() != point_count
        {
            return Err(ValidationError::ShapeMismatch("pressure point count"));
        }
        if let Some(gradient) = &self.velocity_gradient
            && gradient.len() != point_count
        {
            return Err(ValidationError::ShapeMismatch("gradient point count"));
        }
        if let Some(mask) = &self.valid_mask
            && mask.len() != point_count
        {
            return Err(ValidationError::ShapeMismatch("velocity mask point count"));
        }
        for index in 0..point_count {
            let valid = self.valid_mask.as_ref().is_none_or(|mask| mask[index]);
            if valid {
                for component in self.velocity[index] {
                    require_finite("velocity_component", component)?;
                }
                if let Some(pressure) = &self.pressure {
                    require_finite("pressure", pressure[index])?;
                }
                if let Some(gradient) = &self.velocity_gradient {
                    for row in gradient[index] {
                        for component in row {
                            require_finite("velocity_gradient", component)?;
                        }
                    }
                }
            }
        }
        Ok(())
    }
}

/// Status of a numerical diagnostic handoff.
#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum DiagnosticStatus {
    Computed,
    Incomplete,
    Invalid,
}

/// A finite-time FTLE result with its numerical provenance and error budget.
#[derive(Clone, Debug, PartialEq)]
pub struct FtleResult {
    pub status: DiagnosticStatus,
    pub values: Vec<f64>,
    pub time_window: f64,
    pub seed_spacing: f64,
    pub spatial_interpolation: String,
    pub temporal_interpolation: String,
    pub trajectory_integrator: String,
    pub deformation_method: String,
    pub integration_error: f64,
    pub interpolation_error: f64,
    pub convergence_delta: Option<f64>,
}

impl FtleResult {
    pub fn validate(&self) -> Result<(), ValidationError> {
        require_positive("ftle_time_window", self.time_window.abs())?;
        require_positive("ftle_seed_spacing", self.seed_spacing)?;
        require_nonnegative("ftle_integration_error", self.integration_error)?;
        require_nonnegative("ftle_interpolation_error", self.interpolation_error)?;
        if self.spatial_interpolation.trim().is_empty() {
            return Err(ValidationError::MissingMetadata(
                "ftle_spatial_interpolation",
            ));
        }
        if self.temporal_interpolation.trim().is_empty() {
            return Err(ValidationError::MissingMetadata(
                "ftle_temporal_interpolation",
            ));
        }
        if self.trajectory_integrator.trim().is_empty() {
            return Err(ValidationError::MissingMetadata(
                "ftle_trajectory_integrator",
            ));
        }
        if self.deformation_method.trim().is_empty() {
            return Err(ValidationError::MissingMetadata("ftle_deformation_method"));
        }
        if let Some(delta) = self.convergence_delta {
            require_nonnegative("ftle_convergence_delta", delta)?;
        }
        for value in &self.values {
            require_finite("ftle_value", *value)?;
        }
        if self.status == DiagnosticStatus::Computed && self.values.is_empty() {
            return Err(ValidationError::EmptyGrid);
        }
        Ok(())
    }

    pub fn is_converged(&self, tolerance: f64) -> Result<bool, ValidationError> {
        require_nonnegative("ftle_convergence_tolerance", tolerance)?;
        self.validate()?;
        Ok(self
            .convergence_delta
            .is_some_and(|delta| delta <= tolerance))
    }
}

#[cfg(feature = "hdf5")]
pub mod hdf5_io {
    use super::*;
    use hdf5_pure::File;
    use sha2::{Digest, Sha256};
    use std::path::Path;

    const PDEBENCH_SOD6_SHA256: &str =
        "43fe3a129579cd8bd38d5a84502a9f45ed307d8af55fdc631d8fba53998e4d74";

    /// Errors raised while opening or validating an external HDF5 artifact.
    #[derive(Clone, Debug, PartialEq)]
    pub enum Hdf5IngestionError {
        Read(String),
        Validation(ValidationError),
    }

    impl fmt::Display for Hdf5IngestionError {
        fn fmt(&self, formatter: &mut fmt::Formatter<'_>) -> fmt::Result {
            write!(formatter, "{self:?}")
        }
    }

    impl std::error::Error for Hdf5IngestionError {}

    impl From<ValidationError> for Hdf5IngestionError {
        fn from(error: ValidationError) -> Self {
            Self::Validation(error)
        }
    }

    /// Metadata for the public PDEBench/DaRUS Sod6 artifact.
    pub fn pdebench_sod6_metadata() -> DatasetMetadata {
        DatasetMetadata {
            artifact_reference:
                "https://darus.uni-stuttgart.de/api/access/datafile/133150".into(),
            artifact_checksum: "sha256:43fe3a129579cd8bd38d5a84502a9f45ed307d8af55fdc631d8fba53998e4d74;md5:adb2d95bf0d48e03bc0d8f4a2cbcd1c6".into(),
            license_reference: "https://creativecommons.org/licenses/by/4.0/".into(),
            unit_convention:
                "PDEBench dimensionless CFD variables; x/t coordinates as stored".into(),
            calibration_reference: "solver-produced; no experimental calibration".into(),
            execution_context:
                "PDEBench Sod6; HDF5; density/pressure/Vx; prefix 201 of 202 t-coordinate values"
                    .into(),
        }
    }

    /// Read the compact PDEBench Sod6 shock-tube artifact.
    pub fn read_pdebench_sod6<P: AsRef<Path>>(
        path: P,
    ) -> Result<FlowFieldDataset, Hdf5IngestionError> {
        let file = File::open(path).map_err(|error| Hdf5IngestionError::Read(error.to_string()))?;
        let actual_checksum = format!("{:x}", Sha256::digest(file.as_bytes()));
        if actual_checksum != PDEBENCH_SOD6_SHA256 {
            return Err(Hdf5IngestionError::Read(format!(
                "PDEBench Sod6 SHA-256 mismatch: expected {PDEBENCH_SOD6_SHA256}, got {actual_checksum}"
            )));
        }
        let (density_shape, density) = read_f64_dataset(&file, "density")?;
        let (pressure_shape, pressure) = read_f64_dataset(&file, "pressure")?;
        let (velocity_shape, velocity_x) = read_f64_dataset(&file, "Vx")?;
        let (coordinate_shape, coordinates) = read_f64_dataset(&file, "x-coordinate")?;
        let (time_shape, time_coordinates) = read_f64_dataset(&file, "t-coordinate")?;

        if density_shape.len() != 2
            || pressure_shape != density_shape
            || velocity_shape != density_shape
        {
            return Err(ValidationError::ShapeMismatch("PDEBench field arrays").into());
        }
        if coordinate_shape.len() != 1 || coordinate_shape[0] != density_shape[1] {
            return Err(ValidationError::ShapeMismatch("PDEBench x-coordinate").into());
        }
        if time_shape.len() != 1 {
            return Err(ValidationError::ShapeMismatch("PDEBench t-coordinate").into());
        }

        let snapshot_count = checked_dimension(density_shape[0], "snapshot")?;
        let spatial_count = checked_dimension(density_shape[1], "spatial")?;
        let expected_values = snapshot_count.checked_mul(spatial_count).ok_or_else(|| {
            Hdf5IngestionError::Read("PDEBench field shape overflows usize".into())
        })?;
        if density.len() != expected_values
            || pressure.len() != expected_values
            || velocity_x.len() != expected_values
        {
            return Err(ValidationError::ShapeMismatch("PDEBench field values").into());
        }

        let time_axis_policy = if time_coordinates.len() == snapshot_count {
            TimeAxisPolicy::Exact
        } else if time_coordinates.len() == snapshot_count + 1 {
            TimeAxisPolicy::PrefixByOne
        } else {
            return Err(ValidationError::CoordinateLengthMismatch("PDEBench t-coordinate").into());
        };

        let snapshots = (0..snapshot_count)
            .map(|row| {
                let start = row * spatial_count;
                let end = start + spatial_count;
                FlowFieldSnapshot {
                    time: time_coordinates[row],
                    density: density[start..end].to_vec(),
                    pressure: pressure[start..end].to_vec(),
                    velocity_x: velocity_x[start..end].to_vec(),
                }
            })
            .collect();
        let dataset = FlowFieldDataset {
            origin: FlowDataOrigin::Simulated,
            case_name: "PDEBench 1D CFD Sod6 shock tube".into(),
            source_label: "PDEBench / DaRUS / Sod6.hdf5".into(),
            metadata: pdebench_sod6_metadata(),
            coordinates,
            time_coordinates,
            snapshots,
            time_axis_policy,
        };
        dataset.validate(1e-12)?;
        Ok(dataset)
    }

    fn read_f64_dataset(
        file: &File,
        name: &'static str,
    ) -> Result<(Vec<u64>, Vec<f64>), Hdf5IngestionError> {
        let dataset = file
            .dataset(name)
            .map_err(|error| Hdf5IngestionError::Read(format!("{name}: {error}")))?;
        let shape = dataset
            .shape()
            .map_err(|error| Hdf5IngestionError::Read(format!("{name} shape: {error}")))?;
        let values = dataset
            .read_f64()
            .map_err(|error| Hdf5IngestionError::Read(format!("{name} values: {error}")))?;
        Ok((shape, values))
    }

    fn checked_dimension(value: u64, name: &'static str) -> Result<usize, Hdf5IngestionError> {
        usize::try_from(value)
            .map_err(|_| Hdf5IngestionError::Read(format!("{name} dimension exceeds usize")))
    }
}

/// A deterministic simulated fixture for adapter and Lean-handoff tests.
pub fn simulated_affine_fixture() -> FlowDataset {
    let metadata = DatasetMetadata {
        artifact_reference: "synthetic://signals/affine-flow-v1".into(),
        artifact_checksum: "sha256:signals-affine-flow-v1".into(),
        license_reference: "internal synthetic fixture".into(),
        unit_convention: "SI".into(),
        calibration_reference: "analytic-fixture-v1".into(),
        execution_context: "affine-flow; analytic-flow-map; no-solver".into(),
    };
    let covariance = [[1.0, 0.1, 0.0], [0.1, 2.0, 0.0], [0.0, 0.0, 0.5]];
    let diagnostic = |time: f64| MadelungSample {
        mass_density: 2.0,
        mean_velocity: [0.2 * time, 0.1 * time, 0.0],
        covariance,
        compressibility: 0.5,
        healing_length: 0.1,
        spatial_step: 0.01,
        time_step: 0.001,
        ftle_window: 1.0,
        ftle_indicator: 0.2,
    };
    FlowDataset {
        origin: FlowDataOrigin::Simulated,
        case_name: "affine flow validation case".into(),
        source_label: "analytic simulated fixture".into(),
        metadata,
        snapshots: vec![
            FlowSnapshot {
                time: 0.0,
                pressure: 101_325.0,
                diagnostic: diagnostic(0.0),
            },
            FlowSnapshot {
                time: 1.0,
                pressure: 101_325.0,
                diagnostic: diagnostic(1.0),
            },
        ],
        affine_velocity_rate: [0.2, 0.1, 0.0],
        ftle_window: 1.0,
    }
}

/// A finite weak trace and flux-jump result.
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct WeakTraceJump {
    pub left_trace: f64,
    pub right_trace: f64,
    pub prescribed_trace_jump: f64,
    pub trace_jump_tolerance: f64,
    pub left_flux: f64,
    pub right_flux: f64,
    pub prescribed_flux_jump: f64,
    pub flux_jump_tolerance: f64,
    pub weak_derivative_pairing: f64,
    pub test_function_boundary_term: f64,
    pub weak_balance_tolerance: f64,
}

impl WeakTraceJump {
    pub fn trace_jump(&self) -> f64 {
        self.right_trace - self.left_trace
    }

    pub fn flux_jump(&self) -> f64 {
        self.right_flux - self.left_flux
    }

    pub fn trace_jump_residual(&self) -> f64 {
        self.trace_jump() - self.prescribed_trace_jump
    }

    pub fn flux_jump_residual(&self) -> f64 {
        self.flux_jump() - self.prescribed_flux_jump
    }

    pub fn trace_jump_consistent(&self) -> bool {
        self.trace_jump_residual().abs() <= self.trace_jump_tolerance
    }

    pub fn flux_jump_consistent(&self) -> bool {
        self.flux_jump_residual().abs() <= self.flux_jump_tolerance
    }

    pub fn weak_balance_residual(&self) -> f64 {
        self.weak_derivative_pairing - self.test_function_boundary_term - self.flux_jump()
    }

    pub fn validate(&self) -> Result<(), ValidationError> {
        for (name, value) in [
            ("left_trace", self.left_trace),
            ("right_trace", self.right_trace),
            ("prescribed_trace_jump", self.prescribed_trace_jump),
            ("trace_jump_tolerance", self.trace_jump_tolerance),
            ("left_flux", self.left_flux),
            ("right_flux", self.right_flux),
            ("prescribed_flux_jump", self.prescribed_flux_jump),
            ("flux_jump_tolerance", self.flux_jump_tolerance),
            ("weak_derivative_pairing", self.weak_derivative_pairing),
            (
                "test_function_boundary_term",
                self.test_function_boundary_term,
            ),
            ("weak_balance_tolerance", self.weak_balance_tolerance),
        ] {
            require_finite(name, value)?;
        }
        require_nonnegative("weak_balance_tolerance", self.weak_balance_tolerance)?;
        require_nonnegative("trace_jump_tolerance", self.trace_jump_tolerance)?;
        require_nonnegative("flux_jump_tolerance", self.flux_jump_tolerance)?;
        Ok(())
    }
}

/// A finite Madelung/GP diagnostic sample.
#[derive(Clone, Debug, PartialEq)]
pub struct MadelungSample {
    pub mass_density: f64,
    pub mean_velocity: [f64; 3],
    pub covariance: [[f64; 3]; 3],
    pub compressibility: f64,
    pub healing_length: f64,
    pub spatial_step: f64,
    pub time_step: f64,
    pub ftle_window: f64,
    pub ftle_indicator: f64,
}

impl MadelungSample {
    pub fn validate(&self, tolerance: f64) -> Result<(), ValidationError> {
        require_positive("mass_density", self.mass_density)?;
        require_nonnegative("compressibility", self.compressibility)?;
        require_positive("healing_length", self.healing_length)?;
        require_positive("spatial_step", self.spatial_step)?;
        require_positive("time_step", self.time_step)?;
        require_positive("ftle_window", self.ftle_window)?;
        require_finite("ftle_indicator", self.ftle_indicator)?;
        for value in self.mean_velocity {
            require_finite("mean_velocity", value)?;
        }
        for row in self.covariance {
            for value in row {
                require_finite("covariance", value)?;
            }
        }
        if !covariance_is_symmetric(&self.covariance, tolerance) {
            return Err(ValidationError::CovarianceNotSymmetric);
        }
        if !covariance_is_positive_semidefinite(&self.covariance, tolerance) {
            return Err(ValidationError::CovarianceNotPositiveSemidefinite);
        }
        Ok(())
    }
}

/// A finite indexed diagnostic grid.
#[derive(Clone, Debug, PartialEq)]
pub struct MadelungGrid {
    pub samples: Vec<MadelungSample>,
}

impl MadelungGrid {
    pub fn validate(&self, tolerance: f64) -> Result<(), ValidationError> {
        if self.samples.is_empty() {
            return Err(ValidationError::EmptyGrid);
        }
        for sample in &self.samples {
            sample.validate(tolerance)?;
        }
        Ok(())
    }
}

/// Compute FTLE from the largest singular value of a finite flow-map derivative.
pub fn ftle_from_singular_values(
    singular_values: [f64; 3],
    window: f64,
) -> Result<f64, ValidationError> {
    require_positive("ftle_window", window.abs())?;
    for value in singular_values {
        require_positive("singular_value", value)?;
    }
    let largest = singular_values
        .into_iter()
        .fold(f64::NEG_INFINITY, f64::max);
    Ok(largest.ln() / window.abs())
}

/// Exact FTLE magnitude for a diagonal affine flow-map rate over a positive window.
pub fn diagonal_affine_ftle(rates: [f64; 3], window: f64) -> Result<f64, ValidationError> {
    require_positive("ftle_window", window)?;
    let singular_values = rates.map(|rate| (rate * window).exp());
    ftle_from_singular_values(singular_values, window)
}

/// A compact deterministic self-check used by the native CLI.
pub fn self_check() -> Result<(), ValidationError> {
    let dataset = simulated_affine_fixture();
    dataset.validate(1e-12)?;
    if (dataset.affine_ftle()? - 0.2).abs() > 1e-12 {
        return Err(ValidationError::ResidualTooLarge("simulated affine FTLE"));
    }

    let metadata = DatasetMetadata {
        artifact_reference: "synthetic://uniform-flow".into(),
        artifact_checksum: "sha256:synthetic".into(),
        license_reference: "internal".into(),
        unit_convention: "SI".into(),
        calibration_reference: "fixture-v1".into(),
        execution_context: "analytic-affine-flow".into(),
    };
    metadata.validate()?;

    let jump = WeakTraceJump {
        left_trace: 1.0,
        right_trace: 3.0,
        prescribed_trace_jump: 2.0,
        trace_jump_tolerance: 1e-9,
        left_flux: 4.0,
        right_flux: 5.0,
        prescribed_flux_jump: 1.0,
        flux_jump_tolerance: 1e-9,
        weak_derivative_pairing: 7.0,
        test_function_boundary_term: 6.0,
        weak_balance_tolerance: 1e-9,
    };
    jump.validate()?;
    if jump.trace_jump_residual().abs() > 1e-9
        || jump.flux_jump_residual().abs() > 1e-9
        || jump.weak_balance_residual().abs() > 1e-9
        || !jump.trace_jump_consistent()
        || !jump.flux_jump_consistent()
    {
        return Err(ValidationError::ResidualTooLarge("weak trace"));
    }

    let covariance = [[1.0, 0.1, 0.0], [0.1, 2.0, 0.0], [0.0, 0.0, 0.5]];
    let sample = MadelungSample {
        mass_density: 2.0,
        mean_velocity: [0.0, 0.0, 0.0],
        covariance,
        compressibility: 0.5,
        healing_length: 0.1,
        spatial_step: 0.01,
        time_step: 0.001,
        ftle_window: 1.0,
        ftle_indicator: diagonal_affine_ftle([0.2, 0.1, 0.0], 1.0)?,
    };
    sample.validate(1e-12)?;
    let grid = MadelungGrid {
        samples: vec![sample],
    };
    grid.validate(1e-12)?;
    Ok(())
}

/// Validation failures at the numerical boundary.
#[derive(Clone, Debug, PartialEq)]
pub enum ValidationError {
    MissingMetadata(&'static str),
    NonFinite(&'static str),
    NonPositive(&'static str),
    Negative(&'static str),
    EmptyGrid,
    EmptyDataset,
    NonMonotonicTime,
    NonMonotonicCoordinate(&'static str),
    CoordinateLengthMismatch(&'static str),
    CoordinateMismatch(&'static str),
    ShapeMismatch(&'static str),
    CovarianceNotSymmetric,
    CovarianceNotPositiveSemidefinite,
    ResidualTooLarge(&'static str),
}

impl fmt::Display for ValidationError {
    fn fmt(&self, formatter: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(formatter, "{self:?}")
    }
}

impl std::error::Error for ValidationError {}

pub(crate) fn require_finite(name: &'static str, value: f64) -> Result<(), ValidationError> {
    if value.is_finite() {
        Ok(())
    } else {
        Err(ValidationError::NonFinite(name))
    }
}

pub(crate) fn require_positive(name: &'static str, value: f64) -> Result<(), ValidationError> {
    require_finite(name, value)?;
    if value > 0.0 {
        Ok(())
    } else {
        Err(ValidationError::NonPositive(name))
    }
}

pub(crate) fn require_nonnegative(name: &'static str, value: f64) -> Result<(), ValidationError> {
    require_finite(name, value)?;
    if value >= 0.0 {
        Ok(())
    } else {
        Err(ValidationError::Negative(name))
    }
}

fn covariance_is_symmetric(covariance: &[[f64; 3]; 3], tolerance: f64) -> bool {
    (0..3).all(|row| {
        (0..3).all(|column| (covariance[row][column] - covariance[column][row]).abs() <= tolerance)
    })
}

fn covariance_is_positive_semidefinite(covariance: &[[f64; 3]; 3], tolerance: f64) -> bool {
    let a = covariance;
    let minor_0 = a[0][0];
    let minor_1 = a[1][1];
    let minor_2 = a[2][2];
    let minor_01 = a[0][0] * a[1][1] - a[0][1] * a[1][0];
    let minor_02 = a[0][0] * a[2][2] - a[0][2] * a[2][0];
    let minor_12 = a[1][1] * a[2][2] - a[1][2] * a[2][1];
    let determinant = a[0][0] * (a[1][1] * a[2][2] - a[1][2] * a[2][1])
        - a[0][1] * (a[1][0] * a[2][2] - a[1][2] * a[2][0])
        + a[0][2] * (a[1][0] * a[2][1] - a[1][1] * a[2][0]);
    [
        minor_0,
        minor_1,
        minor_2,
        minor_01,
        minor_02,
        minor_12,
        determinant,
    ]
    .into_iter()
    .all(|minor| minor >= -tolerance)
}

#[cfg(feature = "vortex")]
pub mod vortex_io {
    use vortex::VortexSessionDefault;
    use vortex::array::arrays::PrimitiveArray;
    use vortex::array::validity::Validity;
    use vortex::array::{IntoArray, stream::ArrayStreamExt};
    use vortex::buffer::{ByteBufferMut, buffer};
    use vortex::file::{OpenOptionsSessionExt, WriteOptionsSessionExt};
    use vortex::session::VortexSession;

    /// Write and read a fixed scalar fixture through Vortex in memory.
    pub async fn round_trip_fixed_u64() -> Result<usize, String> {
        let session = VortexSession::default();
        let array = PrimitiveArray::new(buffer![0u64, 1, 2, 3, 4], Validity::NonNullable);
        let mut bytes = ByteBufferMut::empty();
        session
            .write_options()
            .write(&mut bytes, array.into_array().to_array_stream())
            .await
            .map_err(|error| error.to_string())?;
        let file = session
            .open_options()
            .open_buffer(bytes)
            .map_err(|error| error.to_string())?;
        let decoded = file
            .scan()
            .map_err(|error| error.to_string())?
            .into_array_stream()
            .map_err(|error| error.to_string())?
            .read_all()
            .await
            .map_err(|error| error.to_string())?;
        Ok(decoded.len())
    }

    #[cfg(test)]
    mod tests {
        #[tokio::test]
        async fn fixed_fixture_round_trips() {
            assert_eq!(super::round_trip_fixed_u64().await.unwrap(), 5);
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn metadata_rejects_missing_fields() {
        let metadata = DatasetMetadata {
            artifact_reference: String::new(),
            artifact_checksum: "sha256:test".into(),
            license_reference: "fixture".into(),
            unit_convention: "SI".into(),
            calibration_reference: "cal-v1".into(),
            execution_context: "analytic".into(),
        };
        assert_eq!(
            metadata.validate(),
            Err(ValidationError::MissingMetadata("artifact_reference"))
        );
    }

    #[test]
    fn simulated_fixture_validates_and_produces_ftle() {
        let dataset = simulated_affine_fixture();
        assert_eq!(dataset.origin, FlowDataOrigin::Simulated);
        dataset.validate(1e-12).unwrap();
        assert!((dataset.affine_ftle().unwrap() - 0.2).abs() < 1e-12);
        assert_eq!(dataset.snapshots.len(), 2);
    }

    #[test]
    fn dataset_rejects_non_monotonic_time() {
        let mut dataset = simulated_affine_fixture();
        dataset.snapshots[1].time = 0.0;
        assert_eq!(
            dataset.validate(1e-12),
            Err(ValidationError::NonMonotonicTime)
        );
    }

    #[test]
    fn weak_jump_and_balance_are_recovered() {
        let jump = WeakTraceJump {
            left_trace: 1.0,
            right_trace: 3.0,
            prescribed_trace_jump: 2.0,
            trace_jump_tolerance: 1e-12,
            left_flux: 4.0,
            right_flux: 5.0,
            prescribed_flux_jump: 1.0,
            flux_jump_tolerance: 1e-12,
            weak_derivative_pairing: 7.0,
            test_function_boundary_term: 6.0,
            weak_balance_tolerance: 1e-12,
        };
        jump.validate().unwrap();
        assert_eq!(jump.trace_jump(), 2.0);
        assert_eq!(jump.flux_jump(), 1.0);
        assert_eq!(jump.weak_balance_residual(), 0.0);
    }

    #[test]
    fn covariance_and_affine_ftle_are_validated() {
        let sample = MadelungSample {
            mass_density: 1.0,
            mean_velocity: [0.0; 3],
            covariance: [[1.0, 0.0, 0.0], [0.0, 2.0, 0.0], [0.0, 0.0, 3.0]],
            compressibility: 0.25,
            healing_length: 0.5,
            spatial_step: 0.01,
            time_step: 0.001,
            ftle_window: 1.0,
            ftle_indicator: diagonal_affine_ftle([0.25, 0.1, 0.0], 1.0).unwrap(),
        };
        sample.validate(1e-12).unwrap();
        assert!((sample.ftle_indicator - 0.25).abs() < 1e-12);
    }

    #[test]
    fn non_psd_covariance_is_rejected() {
        let sample = MadelungSample {
            mass_density: 1.0,
            mean_velocity: [0.0; 3],
            covariance: [[1.0, 2.0, 0.0], [2.0, 1.0, 0.0], [0.0, 0.0, 1.0]],
            compressibility: 0.25,
            healing_length: 0.5,
            spatial_step: 0.01,
            time_step: 0.001,
            ftle_window: 1.0,
            ftle_indicator: 0.0,
        };
        assert_eq!(
            sample.validate(1e-12),
            Err(ValidationError::CovarianceNotPositiveSemidefinite)
        );
    }

    #[test]
    fn vector_field_and_ftle_metadata_are_validated() {
        let metadata = DatasetMetadata {
            artifact_reference: "synthetic://vector-field".into(),
            artifact_checksum: "sha256:test".into(),
            license_reference: "internal".into(),
            unit_convention: "SI".into(),
            calibration_reference: "test".into(),
            execution_context: "finite-grid".into(),
        };
        let dataset = VectorFieldDataset {
            origin: FlowDataOrigin::Simulated,
            case_name: "vector control".into(),
            source_label: "unit fixture".into(),
            metadata,
            points: vec![[0.0, 0.0, 0.0], [1.0, 0.0, 0.0]],
            times: vec![0.0, 0.1],
            frames: vec![
                VectorFieldFrame {
                    time: 0.0,
                    velocity: vec![[1.0, 0.0, 0.0], [1.0, 0.0, 0.0]],
                    pressure: Some(vec![1.0, 1.0]),
                    velocity_gradient: None,
                    valid_mask: Some(vec![true, true]),
                },
                VectorFieldFrame {
                    time: 0.1,
                    velocity: vec![[1.0, 0.0, 0.0], [1.0, 0.0, 0.0]],
                    pressure: Some(vec![1.0, 1.0]),
                    velocity_gradient: None,
                    valid_mask: Some(vec![true, true]),
                },
            ],
            spatial_interpolation: "linear".into(),
            temporal_interpolation: "none".into(),
        };
        dataset.validate(1e-12).unwrap();

        let result = FtleResult {
            status: DiagnosticStatus::Computed,
            values: vec![0.0, 0.1],
            time_window: 0.1,
            seed_spacing: 1.0,
            spatial_interpolation: "linear".into(),
            temporal_interpolation: "none".into(),
            trajectory_integrator: "RK2".into(),
            deformation_method: "centered finite difference".into(),
            integration_error: 1e-6,
            interpolation_error: 2e-6,
            convergence_delta: Some(3e-6),
        };
        assert!(result.is_converged(1e-5).unwrap());
        result.validate().unwrap();
    }

    #[test]
    fn incomplete_ftle_result_may_have_no_values() {
        let result = FtleResult {
            status: DiagnosticStatus::Incomplete,
            values: Vec::new(),
            time_window: 0.1,
            seed_spacing: 1.0,
            spatial_interpolation: "unavailable".into(),
            temporal_interpolation: "unavailable".into(),
            trajectory_integrator: "not run".into(),
            deformation_method: "not run".into(),
            integration_error: 0.0,
            interpolation_error: 0.0,
            convergence_delta: None,
        };
        result.validate().unwrap();
    }

    #[cfg(feature = "hdf5")]
    #[test]
    fn pdebench_sod6_fixture_is_ingested_when_available() {
        let Some(path) = std::env::var_os("SIGNALS_PDEBENCH_SOD6") else {
            return;
        };
        let dataset = hdf5_io::read_pdebench_sod6(path).unwrap();
        assert_eq!(dataset.origin, FlowDataOrigin::Simulated);
        assert_eq!(dataset.spatial_count(), 1024);
        assert_eq!(dataset.snapshot_count(), 201);
        assert_eq!(dataset.time_coordinates.len(), 202);
        assert_eq!(dataset.time_axis_policy, TimeAxisPolicy::PrefixByOne);
        assert!((dataset.snapshots[0].density[0] - 1.4).abs() < 1e-6);
        assert_eq!(dataset.snapshots[0].pressure[0], 1.0);
        assert_eq!(dataset.max_abs_velocity_x(), 0.0);
        assert_eq!(
            dataset.metadata.license_reference,
            "https://creativecommons.org/licenses/by/4.0/"
        );
    }
}
