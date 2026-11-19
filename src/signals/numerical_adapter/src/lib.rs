//! Native numerical diagnostics for the Signals Pending boundary.
//!
//! This crate computes finite summaries and validates input metadata.

use std::fmt;

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
pub mod orbital_splat;
pub mod polariton_spp;
pub mod quantum_causal_inference;
pub mod quantum_trajectories;
pub mod riemann_spectral;
pub mod slavnov_dpp;
pub mod tequila_simulator;
pub mod thermal_inelastic;

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
fn py_audit_regular_graphs_bass_ihara<'py>(py: Python<'py>) -> PyResult<Bound<'py, PyList>> {
    let graphs = [
        riemann_spectral::petersen_graph_10(),
        riemann_spectral::heawood_graph_14(),
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
    m.add_function(wrap_pyfunction!(py_audit_madelung_bohm_jensen_polya, m)?)?;
    m.add_function(wrap_pyfunction!(py_audit_gram_law_and_lehmer, m)?)?;
    m.add_function(wrap_pyfunction!(py_audit_regular_graphs_bass_ihara, m)?)?;
    m.add_function(wrap_pyfunction!(py_li_partial_coefficients, m)?)?;
    m.add_class::<tequila_simulator::RustFastCircuit>()?;
    m.add_class::<tequila_simulator::RustFastHamiltonianSet>()?;
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
