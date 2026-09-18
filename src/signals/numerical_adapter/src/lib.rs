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
}
