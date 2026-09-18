//! Native numerical diagnostics for the Signals Pending boundary.
//!
//! This crate computes finite summaries and validates input metadata. It does
//! not prove a physical fracture, solve a complete GP model, or identify a
//! new propagation mechanism.

use std::fmt;

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

fn require_finite(name: &'static str, value: f64) -> Result<(), ValidationError> {
    if value.is_finite() {
        Ok(())
    } else {
        Err(ValidationError::NonFinite(name))
    }
}

fn require_positive(name: &'static str, value: f64) -> Result<(), ValidationError> {
    require_finite(name, value)?;
    if value > 0.0 {
        Ok(())
    } else {
        Err(ValidationError::NonPositive(name))
    }
}

fn require_nonnegative(name: &'static str, value: f64) -> Result<(), ValidationError> {
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
