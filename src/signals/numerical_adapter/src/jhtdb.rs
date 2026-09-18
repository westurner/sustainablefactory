use crate::{
    DatasetMetadata, FlowDataOrigin, ValidationError, VectorFieldDataset, VectorFieldFrame,
};
use hdf5_pure::{AttrValue, File};
use rayon::prelude::*;
use sha2::{Digest, Sha256};
use std::collections::HashMap;
use std::fmt;
use std::fs::File as StdFile;
use std::io::{Read, Write};
use std::path::Path;

const VELOCITY_PREFIX: &str = "velocity_";
const DIMENSION_COUNT: usize = 3;
const COMPONENT_COUNT: usize = 3;

#[derive(Debug)]
pub enum JhtdbError {
    Io(std::io::Error),
    Hdf5(String),
    InvalidFormat(String),
    InvalidParameter(String),
    Validation(ValidationError),
}

impl fmt::Display for JhtdbError {
    fn fmt(&self, formatter: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::Io(error) => write!(formatter, "I/O error: {error}"),
            Self::Hdf5(error) => write!(formatter, "HDF5 error: {error}"),
            Self::InvalidFormat(message) => write!(formatter, "invalid JHTDB cutout: {message}"),
            Self::InvalidParameter(message) => {
                write!(formatter, "invalid JHTDB parameter: {message}")
            }
            Self::Validation(error) => write!(formatter, "validation error: {error}"),
        }
    }
}

impl std::error::Error for JhtdbError {}

impl From<std::io::Error> for JhtdbError {
    fn from(error: std::io::Error) -> Self {
        Self::Io(error)
    }
}

impl From<ValidationError> for JhtdbError {
    fn from(error: ValidationError) -> Self {
        Self::Validation(error)
    }
}

#[derive(Clone, Debug, PartialEq)]
pub struct JhtdbCutout {
    dataset_name: String,
    artifact_sha256: String,
    metadata: DatasetMetadata,
    time_calibration: String,
    time_index_step: f64,
    x: Vec<f64>,
    y: Vec<f64>,
    z: Vec<f64>,
    times: Vec<f64>,
    frames: Vec<Vec<[f64; COMPONENT_COUNT]>>,
}

#[derive(Clone, Debug, PartialEq)]
pub struct JhtdbFtleField {
    pub values: Vec<f64>,
    pub dimensions: [usize; DIMENSION_COUNT],
    pub time_window: f64,
    pub seed_spacing: [f64; DIMENSION_COUNT],
    pub substeps_per_interval: usize,
    pub valid_count: usize,
    pub invalid_count: usize,
    pub interior_count: usize,
    pub trajectory_valid_count: usize,
    pub trajectory_invalid_count: usize,
}

#[derive(Clone, Debug, PartialEq)]
pub struct JhtdbConvergence {
    pub coarse_substeps: usize,
    pub fine_substeps: usize,
    pub compared_count: usize,
    pub max_abs_ftle_delta: Option<f64>,
    pub mean_abs_ftle_delta: Option<f64>,
    pub rmse_ftle_delta: Option<f64>,
    pub estimated_fine_error: Option<f64>,
    pub coarse_valid_count: usize,
    pub fine_valid_count: usize,
}

#[derive(Clone, Debug, PartialEq)]
pub struct JhtdbFlowMapResult {
    pub field: JhtdbFtleField,
    pub convergence: JhtdbConvergence,
}

impl JhtdbCutout {
    pub fn open<P: AsRef<Path>>(
        path: P,
        expected_sha256: Option<&str>,
    ) -> Result<Self, JhtdbError> {
        let path = path.as_ref();
        let artifact_sha256 = sha256_file(path)?;
        if let Some(expected) = expected_sha256 {
            let expected = expected.strip_prefix("sha256:").unwrap_or(expected);
            if !expected.eq_ignore_ascii_case(&artifact_sha256) {
                return Err(JhtdbError::InvalidFormat(format!(
                    "SHA-256 mismatch: expected {expected}, got {artifact_sha256}"
                )));
            }
        }

        let file = File::open(path).map_err(|error| JhtdbError::Hdf5(error.to_string()))?;
        let attributes = file
            .root()
            .attrs()
            .map_err(|error| JhtdbError::Hdf5(error.to_string()))?;
        let dataset_name = attr_string(&attributes, "dataset").unwrap_or_else(|| "channel".into());
        let t_start = attr_number(&attributes, "t_start")?
            .ok_or_else(|| JhtdbError::InvalidFormat("missing root attribute t_start".into()))?;
        let t_end = attr_number(&attributes, "t_end")?
            .ok_or_else(|| JhtdbError::InvalidFormat("missing root attribute t_end".into()))?;
        let t_step = attr_number(&attributes, "t_step")?
            .ok_or_else(|| JhtdbError::InvalidFormat("missing root attribute t_step".into()))?;
        if !t_start.is_finite() || !t_end.is_finite() || !t_step.is_finite() || t_step <= 0.0 {
            return Err(JhtdbError::InvalidFormat(
                "time attributes must be finite with positive t_step".into(),
            ));
        }
        let interval_count = (t_end - t_start) / t_step;
        if interval_count < 1.0 || (interval_count - interval_count.round()).abs() > 1e-9 {
            return Err(JhtdbError::InvalidFormat(
                "time attributes do not define at least two equally spaced frames".into(),
            ));
        }
        let frame_count = interval_count.round() as usize + 1;

        let x = read_axis(&file, "xcoor")?;
        let y = read_axis(&file, "ycoor")?;
        let z = read_axis(&file, "zcoor")?;
        validate_axis("xcoor", &x)?;
        validate_axis("ycoor", &y)?;
        validate_axis("zcoor", &z)?;

        let mut times = Vec::with_capacity(frame_count);
        let mut frames = Vec::with_capacity(frame_count);
        for frame_offset in 0..frame_count {
            let frame_index = t_start + frame_offset as f64 * t_step;
            if (frame_index - frame_index.round()).abs() > 1e-9 || frame_index < 0.0 {
                return Err(JhtdbError::InvalidFormat(
                    "velocity dataset indices must be nonnegative integers".into(),
                ));
            }
            let frame_index = frame_index.round() as usize;
            let dataset_path = format!("{VELOCITY_PREFIX}{frame_index:04}");
            let dataset = file
                .dataset(&dataset_path)
                .map_err(|error| JhtdbError::Hdf5(format!("{dataset_path}: {error}")))?;
            let shape = dataset
                .shape()
                .map_err(|error| JhtdbError::Hdf5(format!("{dataset_path} shape: {error}")))?;
            let expected_shape = vec![z.len() as u64, y.len() as u64, x.len() as u64, 3];
            if shape != expected_shape {
                return Err(JhtdbError::InvalidFormat(format!(
                    "{dataset_path} has shape {shape:?}, expected {expected_shape:?}"
                )));
            }
            let raw = dataset
                .read_f32()
                .map_err(|error| JhtdbError::Hdf5(format!("{dataset_path} values: {error}")))?;
            let expected_values = x.len() * y.len() * z.len() * COMPONENT_COUNT;
            if raw.len() != expected_values {
                return Err(JhtdbError::InvalidFormat(format!(
                    "{dataset_path} has {} values, expected {expected_values}",
                    raw.len()
                )));
            }
            let (chunks, remainder) = raw.as_chunks::<COMPONENT_COUNT>();
            if !remainder.is_empty() {
                return Err(JhtdbError::InvalidFormat(format!(
                    "{dataset_path} has a non-vector remainder of {} values",
                    remainder.len()
                )));
            }
            let values = chunks
                .iter()
                .map(|components| {
                    [
                        components[0] as f64,
                        components[1] as f64,
                        components[2] as f64,
                    ]
                })
                .collect();
            times.push(t_start + frame_offset as f64 * t_step);
            frames.push(values);
        }

        let metadata = DatasetMetadata {
            artifact_reference: format!("JHTDB channel HDF5 cutout: {}", path.display()),
            artifact_checksum: format!("sha256:{artifact_sha256}"),
            license_reference: "https://opendatacommons.org/licenses/by/".into(),
            unit_convention: "JHTDB channel coordinates and velocity values as returned; time index units from cutout attributes".into(),
            calibration_reference: "solver-produced DNS; no experimental calibration".into(),
            execution_context: format!(
                "JHTDB {dataset_name} HDF5 cutout; dimensions={}x{}x{}; frames={frame_count}; storage order z,y,x,vector",
                x.len(),
                y.len(),
                z.len()
            ),
        };
        metadata.validate()?;
        Ok(Self {
            dataset_name,
            artifact_sha256,
            metadata,
            time_calibration: "HDF5 cutout time indices; physical interval not embedded".into(),
            time_index_step: t_step,
            x,
            y,
            z,
            times,
            frames,
        })
    }

    pub fn from_parts_for_test(
        x: Vec<f64>,
        y: Vec<f64>,
        z: Vec<f64>,
        times: Vec<f64>,
        frames: Vec<Vec<[f64; COMPONENT_COUNT]>>,
    ) -> Result<Self, JhtdbError> {
        validate_axes_and_frames(&x, &y, &z, &times, &frames)?;
        Ok(Self {
            dataset_name: "test".into(),
            artifact_sha256: "test".into(),
            metadata: DatasetMetadata {
                artifact_reference: "synthetic://jhtdb-cutout".into(),
                artifact_checksum: "sha256:test".into(),
                license_reference: "synthetic".into(),
                unit_convention: "SI".into(),
                calibration_reference: "analytic".into(),
                execution_context: "unit fixture".into(),
            },
            time_calibration: "synthetic physical time units".into(),
            time_index_step: 1.0,
            x,
            y,
            z,
            times,
            frames,
        })
    }

    pub fn dataset_name(&self) -> &str {
        &self.dataset_name
    }

    pub fn artifact_sha256(&self) -> &str {
        &self.artifact_sha256
    }

    pub fn metadata(&self) -> &DatasetMetadata {
        &self.metadata
    }

    pub fn time_calibration(&self) -> &str {
        &self.time_calibration
    }

    pub fn time_index_step(&self) -> f64 {
        self.time_index_step
    }

    pub fn with_physical_time_step(&self, physical_time_step: f64) -> Result<Self, JhtdbError> {
        if !physical_time_step.is_finite() || physical_time_step <= 0.0 {
            return Err(JhtdbError::InvalidParameter(
                "physical_time_step must be finite and positive".into(),
            ));
        }
        let mut calibrated = self.clone();
        calibrated.times = (0..self.times.len())
            .map(|index| index as f64 * physical_time_step * self.time_index_step)
            .collect();
        calibrated.time_calibration = format!(
            "explicit physical interval {physical_time_step} per HDF5 index with stride {}; origin reset to zero",
            self.time_index_step
        );
        Ok(calibrated)
    }

    pub fn x(&self) -> &[f64] {
        &self.x
    }

    pub fn y(&self) -> &[f64] {
        &self.y
    }

    pub fn z(&self) -> &[f64] {
        &self.z
    }

    pub fn times(&self) -> &[f64] {
        &self.times
    }

    pub fn dimensions(&self) -> [usize; DIMENSION_COUNT] {
        [self.x.len(), self.y.len(), self.z.len()]
    }

    pub fn to_vector_field_dataset(&self) -> Result<VectorFieldDataset, JhtdbError> {
        let mut points = Vec::with_capacity(self.x.len() * self.y.len() * self.z.len());
        for z in &self.z {
            for y in &self.y {
                for x in &self.x {
                    points.push([*x, *y, *z]);
                }
            }
        }
        let frames = self
            .frames
            .iter()
            .zip(&self.times)
            .map(|(velocity, time)| VectorFieldFrame {
                time: *time,
                velocity: velocity.clone(),
                pressure: None,
                velocity_gradient: None,
                valid_mask: Some(
                    velocity
                        .iter()
                        .map(|value| value.iter().all(|component| component.is_finite()))
                        .collect(),
                ),
            })
            .collect();
        let dataset = VectorFieldDataset {
            origin: FlowDataOrigin::Simulated,
            case_name: format!("JHTDB {} channel cutout", self.dataset_name),
            source_label: "Johns Hopkins Turbulence Database channel DNS".into(),
            metadata: self.metadata.clone(),
            points,
            times: self.times.clone(),
            frames,
            spatial_interpolation: "trilinear over cutout nodes".into(),
            temporal_interpolation: "linear between HDF5 frames".into(),
        };
        dataset.validate(1e-12)?;
        Ok(dataset)
    }

    pub fn compute_ftle(&self, substeps_per_interval: usize) -> Result<JhtdbFtleField, JhtdbError> {
        if substeps_per_interval == 0 {
            return Err(JhtdbError::InvalidParameter(
                "substeps_per_interval must be positive".into(),
            ));
        }
        let dimensions = self.dimensions();
        let interior_count = (dimensions[0] - 2) * (dimensions[1] - 2) * (dimensions[2] - 2);
        let seed_count = dimensions[0] * dimensions[1] * dimensions[2];
        let final_positions: Vec<Option<[f64; 3]>> = (0..seed_count)
            .into_par_iter()
            .map(|seed| {
                let x_index = seed % dimensions[0];
                let y_index = (seed / dimensions[0]) % dimensions[1];
                let z_index = seed / (dimensions[0] * dimensions[1]);
                let initial = [self.x[x_index], self.y[y_index], self.z[z_index]];
                self.advect(initial, substeps_per_interval)
            })
            .collect();

        let time_window = self.times[self.times.len() - 1] - self.times[0];
        let mut values = vec![f64::NAN; seed_count];
        let mut valid_count = 0;
        for z_index in 1..dimensions[2] - 1 {
            for y_index in 1..dimensions[1] - 1 {
                for x_index in 1..dimensions[0] - 1 {
                    let index = self.flat_index(x_index, y_index, z_index);
                    let Some(center) = final_positions[index] else {
                        continue;
                    };
                    let Some(left) =
                        final_positions[self.flat_index(x_index - 1, y_index, z_index)]
                    else {
                        continue;
                    };
                    let Some(right) =
                        final_positions[self.flat_index(x_index + 1, y_index, z_index)]
                    else {
                        continue;
                    };
                    let Some(down) =
                        final_positions[self.flat_index(x_index, y_index - 1, z_index)]
                    else {
                        continue;
                    };
                    let Some(up) = final_positions[self.flat_index(x_index, y_index + 1, z_index)]
                    else {
                        continue;
                    };
                    let Some(back) =
                        final_positions[self.flat_index(x_index, y_index, z_index - 1)]
                    else {
                        continue;
                    };
                    let Some(front) =
                        final_positions[self.flat_index(x_index, y_index, z_index + 1)]
                    else {
                        continue;
                    };
                    let derivative_x =
                        difference(right, left, self.x[x_index + 1] - self.x[x_index - 1]);
                    let derivative_y =
                        difference(up, down, self.y[y_index + 1] - self.y[y_index - 1]);
                    let derivative_z =
                        difference(front, back, self.z[z_index + 1] - self.z[z_index - 1]);
                    let deformation = [
                        [derivative_x[0], derivative_y[0], derivative_z[0]],
                        [derivative_x[1], derivative_y[1], derivative_z[1]],
                        [derivative_x[2], derivative_y[2], derivative_z[2]],
                    ];
                    let lambda_max = max_symmetric_eigenvalue(cauchy_green(deformation));
                    if center.iter().all(|value| value.is_finite())
                        && lambda_max.is_finite()
                        && lambda_max > 0.0
                        && time_window > 0.0
                    {
                        values[index] = 0.5 * lambda_max.ln() / time_window;
                        valid_count += 1;
                    }
                }
            }
        }
        let trajectory_valid_count = final_positions
            .iter()
            .filter(|value| value.is_some())
            .count();
        Ok(JhtdbFtleField {
            values,
            dimensions,
            time_window,
            seed_spacing: [
                minimum_spacing(&self.x),
                minimum_spacing(&self.y),
                minimum_spacing(&self.z),
            ],
            substeps_per_interval,
            valid_count,
            invalid_count: interior_count - valid_count,
            interior_count,
            trajectory_valid_count,
            trajectory_invalid_count: seed_count - trajectory_valid_count,
        })
    }

    pub fn compute_convergence(
        &self,
        coarse_substeps: usize,
    ) -> Result<JhtdbFlowMapResult, JhtdbError> {
        if coarse_substeps == 0 {
            return Err(JhtdbError::InvalidParameter(
                "coarse_substeps must be positive".into(),
            ));
        }
        let fine_substeps = coarse_substeps.checked_mul(2).ok_or_else(|| {
            JhtdbError::InvalidParameter("fine substep count overflows usize".into())
        })?;
        let coarse = self.compute_ftle(coarse_substeps)?;
        let fine = self.compute_ftle(fine_substeps)?;
        let deltas: Vec<f64> = coarse
            .values
            .iter()
            .zip(&fine.values)
            .filter_map(|(coarse, fine)| {
                if coarse.is_finite() && fine.is_finite() {
                    Some((fine - coarse).abs())
                } else {
                    None
                }
            })
            .collect();
        let (max_abs_ftle_delta, mean_abs_ftle_delta, rmse_ftle_delta, estimated_fine_error) =
            if deltas.is_empty() {
                (None, None, None, None)
            } else {
                let max_abs = deltas.iter().copied().fold(0.0, f64::max);
                let mean_abs = deltas.iter().sum::<f64>() / deltas.len() as f64;
                let rmse = (deltas.iter().map(|delta| delta * delta).sum::<f64>()
                    / deltas.len() as f64)
                    .sqrt();
                (
                    Some(max_abs),
                    Some(mean_abs),
                    Some(rmse),
                    Some(max_abs / 3.0),
                )
            };
        Ok(JhtdbFlowMapResult {
            field: fine.clone(),
            convergence: JhtdbConvergence {
                coarse_substeps,
                fine_substeps,
                compared_count: deltas.len(),
                max_abs_ftle_delta,
                mean_abs_ftle_delta,
                rmse_ftle_delta,
                estimated_fine_error,
                coarse_valid_count: coarse.valid_count,
                fine_valid_count: fine.valid_count,
            },
        })
    }

    fn flat_index(&self, x_index: usize, y_index: usize, z_index: usize) -> usize {
        (z_index * self.y.len() + y_index) * self.x.len() + x_index
    }

    fn advect(&self, mut position: [f64; 3], substeps_per_interval: usize) -> Option<[f64; 3]> {
        for interval in 0..self.times.len() - 1 {
            let interval_start = self.times[interval];
            let interval_end = self.times[interval + 1];
            let step = (interval_end - interval_start) / substeps_per_interval as f64;
            for substep in 0..substeps_per_interval {
                let time = interval_start + substep as f64 * step;
                let velocity = self.sample_velocity(time, position)?;
                let midpoint = add_scaled(position, velocity, 0.5 * step);
                let midpoint_velocity = self.sample_velocity(time + 0.5 * step, midpoint)?;
                position = add_scaled(position, midpoint_velocity, step);
            }
        }
        Some(position)
    }

    fn sample_velocity(&self, time: f64, position: [f64; 3]) -> Option<[f64; 3]> {
        let (lower_time, upper_time, time_fraction) = locate_coordinate(&self.times, time)?;
        let lower = self.sample_frame(lower_time, position)?;
        if lower_time == upper_time {
            return Some(lower);
        }
        let upper = self.sample_frame(upper_time, position)?;
        Some([
            lower[0] + time_fraction * (upper[0] - lower[0]),
            lower[1] + time_fraction * (upper[1] - lower[1]),
            lower[2] + time_fraction * (upper[2] - lower[2]),
        ])
    }

    fn sample_frame(&self, frame_index: usize, position: [f64; 3]) -> Option<[f64; 3]> {
        let (x0, x_fraction) = locate_axis(&self.x, position[0])?;
        let (y0, y_fraction) = locate_axis(&self.y, position[1])?;
        let (z0, z_fraction) = locate_axis(&self.z, position[2])?;
        let x1 = x0 + 1;
        let y1 = y0 + 1;
        let z1 = z0 + 1;
        let corners = [
            self.frames[frame_index][self.flat_index(x0, y0, z0)],
            self.frames[frame_index][self.flat_index(x1, y0, z0)],
            self.frames[frame_index][self.flat_index(x0, y1, z0)],
            self.frames[frame_index][self.flat_index(x1, y1, z0)],
            self.frames[frame_index][self.flat_index(x0, y0, z1)],
            self.frames[frame_index][self.flat_index(x1, y0, z1)],
            self.frames[frame_index][self.flat_index(x0, y1, z1)],
            self.frames[frame_index][self.flat_index(x1, y1, z1)],
        ];
        if corners
            .iter()
            .flat_map(|corner| corner.iter())
            .any(|value| !value.is_finite())
        {
            return None;
        }
        let mut result = [0.0; COMPONENT_COUNT];
        for component in 0..COMPONENT_COUNT {
            let lower_z = bilinear(
                corners[0][component],
                corners[1][component],
                corners[2][component],
                corners[3][component],
                x_fraction,
                y_fraction,
            );
            let upper_z = bilinear(
                corners[4][component],
                corners[5][component],
                corners[6][component],
                corners[7][component],
                x_fraction,
                y_fraction,
            );
            result[component] = lower_z + z_fraction * (upper_z - lower_z);
        }
        Some(result)
    }
}

fn read_axis(file: &File, name: &str) -> Result<Vec<f64>, JhtdbError> {
    let dataset = file
        .dataset(name)
        .map_err(|error| JhtdbError::Hdf5(format!("{name}: {error}")))?;
    let shape = dataset
        .shape()
        .map_err(|error| JhtdbError::Hdf5(format!("{name} shape: {error}")))?;
    if shape != vec![shape.first().copied().unwrap_or(0)] || shape.is_empty() {
        return Err(JhtdbError::InvalidFormat(format!(
            "{name} must be a one-dimensional coordinate vector, got {shape:?}"
        )));
    }
    dataset
        .read_f64()
        .map_err(|error| JhtdbError::Hdf5(format!("{name} values: {error}")))
}

fn validate_axes_and_frames(
    x: &[f64],
    y: &[f64],
    z: &[f64],
    times: &[f64],
    frames: &[Vec<[f64; COMPONENT_COUNT]>],
) -> Result<(), JhtdbError> {
    validate_axis("x", x)?;
    validate_axis("y", y)?;
    validate_axis("z", z)?;
    if times.len() < 2 || frames.len() != times.len() {
        return Err(JhtdbError::InvalidFormat(
            "need at least two time frames with matching times".into(),
        ));
    }
    let point_count = x.len() * y.len() * z.len();
    for (index, time) in times.iter().enumerate() {
        if !time.is_finite() || (index > 0 && *time <= times[index - 1]) {
            return Err(JhtdbError::InvalidFormat(
                "time coordinates must be finite and strictly increasing".into(),
            ));
        }
        if frames[index].len() != point_count {
            return Err(JhtdbError::InvalidFormat(format!(
                "frame {index} has {} points, expected {point_count}",
                frames[index].len()
            )));
        }
    }
    Ok(())
}

fn validate_axis(name: &str, axis: &[f64]) -> Result<(), JhtdbError> {
    if axis.len() < 3 {
        return Err(JhtdbError::InvalidFormat(format!(
            "{name} axis needs at least three points"
        )));
    }
    for (index, value) in axis.iter().enumerate() {
        if !value.is_finite() || (index > 0 && *value <= axis[index - 1]) {
            return Err(JhtdbError::InvalidFormat(format!(
                "{name} axis must be finite and strictly increasing"
            )));
        }
    }
    Ok(())
}

fn attr_number(
    attributes: &HashMap<String, AttrValue>,
    name: &str,
) -> Result<Option<f64>, JhtdbError> {
    let Some(value) = attributes.get(name) else {
        return Ok(None);
    };
    let number = match value {
        AttrValue::F32(value) => Some(*value as f64),
        AttrValue::F32Array(values) => values.first().map(|value| *value as f64),
        AttrValue::F64(value) => Some(*value),
        AttrValue::F64Array(values) => values.first().copied(),
        AttrValue::I8(value) => Some(*value as f64),
        AttrValue::I8Array(values) => values.first().map(|value| *value as f64),
        AttrValue::I16(value) => Some(*value as f64),
        AttrValue::I16Array(values) => values.first().map(|value| *value as f64),
        AttrValue::I32(value) => Some(*value as f64),
        AttrValue::I32Array(values) => values.first().map(|value| *value as f64),
        AttrValue::I64(value) => Some(*value as f64),
        AttrValue::I64Array(values) => values.first().map(|value| *value as f64),
        AttrValue::U8(value) => Some(*value as f64),
        AttrValue::U8Array(values) => values.first().map(|value| *value as f64),
        AttrValue::U16(value) => Some(*value as f64),
        AttrValue::U16Array(values) => values.first().map(|value| *value as f64),
        AttrValue::U32(value) => Some(*value as f64),
        AttrValue::U32Array(values) => values.first().map(|value| *value as f64),
        AttrValue::U64(value) => Some(*value as f64),
        AttrValue::U64Array(values) => values.first().map(|value| *value as f64),
        _ => None,
    };
    Ok(number)
}

fn attr_string(attributes: &HashMap<String, AttrValue>, name: &str) -> Option<String> {
    match attributes.get(name)? {
        AttrValue::String(value)
        | AttrValue::AsciiString(value)
        | AttrValue::StringSized { value, .. }
        | AttrValue::AsciiStringSized { value, .. } => Some(value.clone()),
        AttrValue::StringArray(values) | AttrValue::StringArraySized { values, .. } => {
            values.first().cloned()
        }
        _ => None,
    }
}

fn locate_axis(axis: &[f64], coordinate: f64) -> Option<(usize, f64)> {
    locate_coordinate(axis, coordinate).map(|(lower, _upper, fraction)| (lower, fraction))
}

fn locate_coordinate(axis: &[f64], coordinate: f64) -> Option<(usize, usize, f64)> {
    if !coordinate.is_finite() || coordinate < axis[0] || coordinate > axis[axis.len() - 1] {
        return None;
    }
    if coordinate == axis[axis.len() - 1] {
        let lower = axis.len() - 2;
        return Some((lower, lower + 1, 1.0));
    }
    let upper = axis.partition_point(|value| *value <= coordinate);
    let lower = upper - 1;
    let fraction = (coordinate - axis[lower]) / (axis[upper] - axis[lower]);
    Some((lower, upper, fraction))
}

fn bilinear(q00: f64, q10: f64, q01: f64, q11: f64, x_fraction: f64, y_fraction: f64) -> f64 {
    let lower = q00 + x_fraction * (q10 - q00);
    let upper = q01 + x_fraction * (q11 - q01);
    lower + y_fraction * (upper - lower)
}

fn add_scaled(
    left: [f64; COMPONENT_COUNT],
    right: [f64; COMPONENT_COUNT],
    scale: f64,
) -> [f64; COMPONENT_COUNT] {
    [
        left[0] + scale * right[0],
        left[1] + scale * right[1],
        left[2] + scale * right[2],
    ]
}

fn difference(
    right: [f64; COMPONENT_COUNT],
    left: [f64; COMPONENT_COUNT],
    denominator: f64,
) -> [f64; COMPONENT_COUNT] {
    [
        (right[0] - left[0]) / denominator,
        (right[1] - left[1]) / denominator,
        (right[2] - left[2]) / denominator,
    ]
}

fn cauchy_green(deformation: [[f64; 3]; 3]) -> [[f64; 3]; 3] {
    let mut result = [[0.0; 3]; 3];
    for row in 0..3 {
        for column in 0..3 {
            result[row][column] = (0..3)
                .map(|component| deformation[component][row] * deformation[component][column])
                .sum();
        }
    }
    result
}

fn max_symmetric_eigenvalue(mut matrix: [[f64; 3]; 3]) -> f64 {
    for _ in 0..32 {
        let (mut p, mut q) = (0, 1);
        let mut largest = matrix[0][1].abs();
        for (candidate_p, candidate_q) in [(0, 2), (1, 2)] {
            if matrix[candidate_p][candidate_q].abs() > largest {
                p = candidate_p;
                q = candidate_q;
                largest = matrix[p][q].abs();
            }
        }
        if largest <= 1e-14 {
            break;
        }
        let tau = (matrix[q][q] - matrix[p][p]) / (2.0 * matrix[p][q]);
        let tangent = if tau >= 0.0 {
            1.0 / (tau + (1.0 + tau * tau).sqrt())
        } else {
            -1.0 / (-tau + (1.0 + tau * tau).sqrt())
        };
        let cosine = 1.0 / (1.0 + tangent * tangent).sqrt();
        let sine = tangent * cosine;
        let pp = matrix[p][p];
        let qq = matrix[q][q];
        let pq = matrix[p][q];
        matrix[p][p] = cosine * cosine * pp - 2.0 * sine * cosine * pq + sine * sine * qq;
        matrix[q][q] = sine * sine * pp + 2.0 * sine * cosine * pq + cosine * cosine * qq;
        matrix[p][q] = 0.0;
        matrix[q][p] = 0.0;
        for index in [0, 1, 2] {
            if index == p || index == q {
                continue;
            }
            let ip = matrix[index][p];
            let iq = matrix[index][q];
            matrix[index][p] = cosine * ip - sine * iq;
            matrix[p][index] = matrix[index][p];
            matrix[index][q] = sine * ip + cosine * iq;
            matrix[q][index] = matrix[index][q];
        }
    }
    matrix[0][0].max(matrix[1][1]).max(matrix[2][2])
}

fn minimum_spacing(axis: &[f64]) -> f64 {
    axis.windows(2)
        .map(|window| window[1] - window[0])
        .fold(f64::INFINITY, f64::min)
}

fn sha256_file(path: &Path) -> Result<String, JhtdbError> {
    let mut file = StdFile::open(path)?;
    let mut digest = Sha256::new();
    let mut buffer = [0u8; 1024 * 1024];
    loop {
        let count = file.read(&mut buffer)?;
        if count == 0 {
            break;
        }
        digest.update(&buffer[..count]);
    }
    Ok(format!("{:x}", digest.finalize()))
}

pub fn write_convergence_summary<W: Write>(
    writer: &mut W,
    result: &JhtdbFlowMapResult,
) -> Result<(), std::io::Error> {
    writeln!(
        writer,
        "coarse_substeps={}",
        result.convergence.coarse_substeps
    )?;
    writeln!(writer, "fine_substeps={}", result.convergence.fine_substeps)?;
    writeln!(
        writer,
        "compared_count={}",
        result.convergence.compared_count
    )?;
    writeln!(
        writer,
        "max_abs_ftle_delta={:?}",
        result.convergence.max_abs_ftle_delta
    )?;
    writeln!(
        writer,
        "estimated_fine_error={:?}",
        result.convergence.estimated_fine_error
    )?;
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    fn uniform_cutout() -> JhtdbCutout {
        let x = vec![-1.0, 0.0, 1.0];
        let y = x.clone();
        let z = x.clone();
        let frames = vec![vec![[0.0, 0.0, 0.0]; 27], vec![[0.0, 0.0, 0.0]; 27]];
        JhtdbCutout::from_parts_for_test(x, y, z, vec![0.0, 1.0], frames).unwrap()
    }

    #[test]
    fn uniform_flow_has_zero_ftle_and_zero_refinement_delta() {
        let cutout = uniform_cutout();
        let result = cutout.compute_convergence(1).unwrap();
        assert_eq!(result.field.valid_count, 1);
        assert_eq!(result.convergence.compared_count, 1);
        assert!(
            result
                .field
                .values
                .iter()
                .all(|value| { !value.is_finite() || value.abs() < 1e-12 })
        );
        assert!(result.convergence.max_abs_ftle_delta.unwrap() < 1e-12);
        assert!(result.convergence.estimated_fine_error.unwrap() < 1e-12);
    }

    #[test]
    fn linear_flow_reports_temporal_refinement_difference() {
        let axis = vec![-2.0, -1.0, 0.0, 1.0, 2.0];
        let mut frame = Vec::with_capacity(125);
        for _z in &axis {
            for _y in &axis {
                for x in &axis {
                    frame.push([0.1 * x, 0.0, 0.0]);
                }
            }
        }
        let cutout = JhtdbCutout::from_parts_for_test(
            axis.clone(),
            axis.clone(),
            axis,
            vec![0.0, 0.5],
            vec![frame.clone(), frame],
        )
        .unwrap();
        let result = cutout.compute_convergence(1).unwrap();
        assert!(result.convergence.compared_count > 0);
        assert!(result.convergence.max_abs_ftle_delta.unwrap() > 0.0);
        assert!(result.convergence.estimated_fine_error.unwrap() > 0.0);
    }

    #[test]
    fn vector_field_handoff_preserves_masked_values() {
        let mut cutout = uniform_cutout();
        cutout.frames[0][0][0] = f64::NAN;
        let dataset = cutout.to_vector_field_dataset().unwrap();
        dataset.validate(1e-12).unwrap();
        assert!(!dataset.frames[0].valid_mask.as_ref().unwrap()[0]);
        assert!(dataset.frames[0].valid_mask.as_ref().unwrap()[1]);
    }

    #[test]
    fn physical_time_calibration_retimes_indexed_frames() {
        let cutout = uniform_cutout();
        let calibrated = cutout.with_physical_time_step(0.25).unwrap();
        assert_eq!(calibrated.times(), &[0.0, 0.25]);
        assert!(calibrated.time_calibration().contains("0.25"));
    }
}
