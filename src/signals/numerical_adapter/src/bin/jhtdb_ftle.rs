use signals_numerical_adapter::jhtdb::{
    JhtdbCutout, JhtdbError, JhtdbFlowMapResult, JhtdbFtleField,
};
use std::env;
use std::fs::File;
use std::io::{BufWriter, Write};
use std::path::{Path, PathBuf};

struct SensitivityOptions<'a> {
    source_time_stride: usize,
    spatial_stride: usize,
    spatial_reference: Option<&'a Path>,
}

fn main() {
    if let Err(error) = run() {
        eprintln!("jhtdb-ftle failed: {error}");
        std::process::exit(1);
    }
}

fn run() -> Result<(), JhtdbError> {
    let arguments: Vec<String> = env::args().collect();
    let input = required_path(&arguments, "--input")?;
    let output = required_path(&arguments, "--output")?;
    let expected_sha256 = optional_string(&arguments, "--expected-sha256")?;
    let coarse_substeps = optional_usize(&arguments, "--substeps")?.unwrap_or(1);
    let source_time_stride = optional_usize(&arguments, "--source-time-stride")?.unwrap_or(1);
    let spatial_stride = optional_usize(&arguments, "--spatial-stride")?.unwrap_or(1);
    let spatial_reference = optional_path(&arguments, "--spatial-reference")?;
    let spatial_reference_sha256 = optional_string(&arguments, "--spatial-reference-sha256")?;
    let physical_time_step = optional_f64(&arguments, "--physical-time-step")?;
    let cutout = JhtdbCutout::open(&input, expected_sha256.as_deref())?;
    let cutout = match physical_time_step {
        Some(step) => cutout.with_physical_time_step(step)?,
        None => cutout,
    };
    let common_dataset = cutout.to_vector_field_dataset()?;
    let mut result = cutout.compute_sensitivities(
        coarse_substeps,
        source_time_stride,
        if spatial_reference.is_some() {
            1
        } else {
            spatial_stride
        },
    )?;
    if let Some(spatial_reference) = spatial_reference.as_ref() {
        let spatial_cutout =
            JhtdbCutout::open(spatial_reference, spatial_reference_sha256.as_deref())?;
        let spatial_cutout = match physical_time_step {
            Some(step) => spatial_cutout.with_physical_time_step(step)?,
            None => spatial_cutout,
        };
        if spatial_cutout.times() != cutout.times() {
            return Err(JhtdbError::InvalidParameter(
                "spatial reference must have the same calibrated time coordinates".into(),
            ));
        }
        let spatial_field = spatial_cutout.compute_ftle(result.field.substeps_per_interval)?;
        result.spatial_sensitivity =
            Some(cutout.compare_spatial_resolution(&result.field, &spatial_cutout, &spatial_field));
    }
    write_csv(&output, &cutout, &result.field)?;
    write_manifest(
        &output,
        &input,
        &cutout,
        &common_dataset,
        &result,
        SensitivityOptions {
            source_time_stride,
            spatial_stride,
            spatial_reference: spatial_reference.as_deref(),
        },
    )?;

    let finite_values: Vec<f64> = result
        .field
        .values
        .iter()
        .copied()
        .filter(|value| value.is_finite())
        .collect();
    let min = finite_values.iter().copied().fold(f64::INFINITY, f64::min);
    let max = finite_values
        .iter()
        .copied()
        .fold(f64::NEG_INFINITY, f64::max);
    let mean = if finite_values.is_empty() {
        f64::NAN
    } else {
        finite_values.iter().sum::<f64>() / finite_values.len() as f64
    };
    println!(
        "JHTDB FTLE computed: dimensions={:?}, window={} s, valid={}, invalid={}, trajectory_valid={}, trajectory_invalid={}, max_refinement_delta={}, estimated_fine_error={}, min={}, max={}, mean={}",
        result.field.dimensions,
        result.field.time_window,
        result.field.valid_count,
        result.field.invalid_count,
        result.field.trajectory_valid_count,
        result.field.trajectory_invalid_count,
        optional_value(result.convergence.max_abs_ftle_delta),
        optional_value(result.convergence.estimated_fine_error),
        min,
        max,
        mean
    );
    Ok(())
}

fn write_csv(
    output: &Path,
    cutout: &JhtdbCutout,
    field: &JhtdbFtleField,
) -> Result<(), JhtdbError> {
    let file = File::create(output)?;
    let mut writer = BufWriter::new(file);
    writeln!(writer, "x_index,y_index,z_index,x,y,z,ftle").map_err(JhtdbError::Io)?;
    for z_index in 0..field.dimensions[2] {
        for y_index in 0..field.dimensions[1] {
            for x_index in 0..field.dimensions[0] {
                let index =
                    (z_index * field.dimensions[1] + y_index) * field.dimensions[0] + x_index;
                writeln!(
                    writer,
                    "{x_index},{y_index},{z_index},{},{},{},{}",
                    cutout.x()[x_index],
                    cutout.y()[y_index],
                    cutout.z()[z_index],
                    field.values[index]
                )
                .map_err(JhtdbError::Io)?;
            }
        }
    }
    writer.flush().map_err(JhtdbError::Io)?;
    println!("wrote JHTDB FTLE CSV: {}", output.display());
    Ok(())
}

fn write_manifest(
    output: &Path,
    input: &Path,
    cutout: &JhtdbCutout,
    common_dataset: &signals_numerical_adapter::VectorFieldDataset,
    result: &JhtdbFlowMapResult,
    sensitivity: SensitivityOptions<'_>,
) -> Result<(), JhtdbError> {
    let manifest_path = output.with_extension("manifest.json");
    let field = &result.field;
    let convergence = &result.convergence;
    let status = if field.valid_count == field.interior_count {
        "computed"
    } else {
        "incomplete"
    };
    let coverage = field.valid_count as f64 / field.interior_count as f64;
    let mut writer = BufWriter::new(File::create(&manifest_path)?);
    writeln!(writer, "{{").map_err(JhtdbError::Io)?;
    writeln!(writer, "  \"format\": \"jhtdb-ftle-v1\",").map_err(JhtdbError::Io)?;
    writeln!(writer, "  \"status\": \"{status}\",").map_err(JhtdbError::Io)?;
    writeln!(writer, "  \"input\": {:?},", input.display()).map_err(JhtdbError::Io)?;
    writeln!(
        writer,
        "  \"input_sha256\": \"{}\",",
        cutout.artifact_sha256()
    )
    .map_err(JhtdbError::Io)?;
    writeln!(writer, "  \"dataset\": {:?},", cutout.dataset_name()).map_err(JhtdbError::Io)?;
    writeln!(
        writer,
        "  \"dimensions\": [{}, {}, {}],",
        field.dimensions[0], field.dimensions[1], field.dimensions[2]
    )
    .map_err(JhtdbError::Io)?;
    writeln!(writer, "  \"frame_count\": {},", cutout.times().len()).map_err(JhtdbError::Io)?;
    writeln!(
        writer,
        "  \"source_time_stride\": {},",
        sensitivity.source_time_stride
    )
    .map_err(JhtdbError::Io)?;
    writeln!(
        writer,
        "  \"spatial_stride\": {},",
        sensitivity.spatial_stride
    )
    .map_err(JhtdbError::Io)?;
    writeln!(
        writer,
        "  \"spatial_reference\": {},",
        sensitivity
            .spatial_reference
            .map_or_else(|| "null".into(), |path| format!("{:?}", path.display()))
    )
    .map_err(JhtdbError::Io)?;
    writeln!(
        writer,
        "  \"time_index_step\": {},",
        cutout.time_index_step()
    )
    .map_err(JhtdbError::Io)?;
    writeln!(writer, "  \"times\": {:?},", cutout.times()).map_err(JhtdbError::Io)?;
    writeln!(
        writer,
        "  \"time_calibration\": {:?},",
        cutout.time_calibration()
    )
    .map_err(JhtdbError::Io)?;
    writeln!(writer, "  \"time_window\": {},", field.time_window).map_err(JhtdbError::Io)?;
    writeln!(
        writer,
        "  \"seed_spacing\": [{}, {}, {}],",
        field.seed_spacing[0], field.seed_spacing[1], field.seed_spacing[2]
    )
    .map_err(JhtdbError::Io)?;
    writeln!(writer, "  \"valid_count\": {},", field.valid_count).map_err(JhtdbError::Io)?;
    writeln!(writer, "  \"invalid_count\": {},", field.invalid_count).map_err(JhtdbError::Io)?;
    writeln!(writer, "  \"interior_count\": {},", field.interior_count).map_err(JhtdbError::Io)?;
    writeln!(writer, "  \"coverage_fraction\": {},", coverage).map_err(JhtdbError::Io)?;
    writeln!(
        writer,
        "  \"trajectory_valid_count\": {},",
        field.trajectory_valid_count
    )
    .map_err(JhtdbError::Io)?;
    writeln!(
        writer,
        "  \"trajectory_invalid_count\": {},",
        field.trajectory_invalid_count
    )
    .map_err(JhtdbError::Io)?;
    writeln!(
        writer,
        "  \"substeps_per_interval\": {},",
        field.substeps_per_interval
    )
    .map_err(JhtdbError::Io)?;
    writeln!(writer, "  \"spatial_interpolation\": \"trilinear\",").map_err(JhtdbError::Io)?;
    writeln!(
        writer,
        "  \"temporal_interpolation\": \"linear between HDF5 frames\","
    )
    .map_err(JhtdbError::Io)?;
    writeln!(writer, "  \"trajectory_integrator\": \"RK2 midpoint\",").map_err(JhtdbError::Io)?;
    writeln!(
        writer,
        "  \"deformation_method\": \"centered finite differences; 3D Cauchy-Green eigenvalue\","
    )
    .map_err(JhtdbError::Io)?;
    writeln!(
        writer,
        "  \"convergence_method\": \"temporal substep refinement from N to 2N\","
    )
    .map_err(JhtdbError::Io)?;
    writeln!(writer, "  \"convergence\": {{").map_err(JhtdbError::Io)?;
    writeln!(
        writer,
        "    \"coarse_substeps\": {},",
        convergence.coarse_substeps
    )
    .map_err(JhtdbError::Io)?;
    writeln!(
        writer,
        "    \"fine_substeps\": {},",
        convergence.fine_substeps
    )
    .map_err(JhtdbError::Io)?;
    writeln!(
        writer,
        "    \"compared_count\": {},",
        convergence.compared_count
    )
    .map_err(JhtdbError::Io)?;
    writeln!(
        writer,
        "    \"max_abs_ftle_delta\": {},",
        optional_value(convergence.max_abs_ftle_delta)
    )
    .map_err(JhtdbError::Io)?;
    writeln!(
        writer,
        "    \"mean_abs_ftle_delta\": {},",
        optional_value(convergence.mean_abs_ftle_delta)
    )
    .map_err(JhtdbError::Io)?;
    writeln!(
        writer,
        "    \"rmse_ftle_delta\": {},",
        optional_value(convergence.rmse_ftle_delta)
    )
    .map_err(JhtdbError::Io)?;
    writeln!(
        writer,
        "    \"estimated_fine_error\": {},",
        optional_value(convergence.estimated_fine_error)
    )
    .map_err(JhtdbError::Io)?;
    writeln!(
        writer,
        "    \"coarse_valid_count\": {},",
        convergence.coarse_valid_count
    )
    .map_err(JhtdbError::Io)?;
    writeln!(
        writer,
        "    \"fine_valid_count\": {}",
        convergence.fine_valid_count
    )
    .map_err(JhtdbError::Io)?;
    writeln!(writer, "  }},").map_err(JhtdbError::Io)?;
    write_sensitivity(
        &mut writer,
        "source_time_sensitivity",
        result.source_time_sensitivity.as_ref(),
    )?;
    writeln!(writer, ",").map_err(JhtdbError::Io)?;
    write_sensitivity(
        &mut writer,
        "spatial_sensitivity",
        result.spatial_sensitivity.as_ref(),
    )?;
    writeln!(writer, ",").map_err(JhtdbError::Io)?;
    writeln!(
        writer,
        "  \"common_vector_field_points\": {},",
        common_dataset.points.len()
    )
    .map_err(JhtdbError::Io)?;
    writeln!(
        writer,
        "  \"common_vector_field_frames\": {},",
        common_dataset.frames.len()
    )
    .map_err(JhtdbError::Io)?;
    writeln!(writer, "  \"ftle_computed\": {}", field.valid_count > 0).map_err(JhtdbError::Io)?;
    writeln!(writer, "}}\n").map_err(JhtdbError::Io)?;
    writer.flush().map_err(JhtdbError::Io)?;
    println!("wrote JHTDB FTLE manifest: {}", manifest_path.display());
    Ok(())
}

fn optional_value(value: Option<f64>) -> String {
    value.map_or_else(|| "null".into(), |value| value.to_string())
}

fn write_sensitivity(
    writer: &mut BufWriter<File>,
    name: &str,
    sensitivity: Option<&signals_numerical_adapter::jhtdb::JhtdbSensitivity>,
) -> Result<(), JhtdbError> {
    write!(writer, "  \"{name}\": ").map_err(JhtdbError::Io)?;
    let Some(sensitivity) = sensitivity else {
        write!(writer, "null").map_err(JhtdbError::Io)?;
        return Ok(());
    };
    write!(
        writer,
        "{{\"comparison\": {:?}, \"compared_count\": {}, \"max_abs_ftle_delta\": {}, \"mean_abs_ftle_delta\": {}, \"rmse_ftle_delta\": {}, \"reference_valid_count\": {}, \"comparison_valid_count\": {}}}",
        sensitivity.comparison,
        sensitivity.compared_count,
        optional_value(sensitivity.max_abs_ftle_delta),
        optional_value(sensitivity.mean_abs_ftle_delta),
        optional_value(sensitivity.rmse_ftle_delta),
        sensitivity.reference_valid_count,
        sensitivity.comparison_valid_count
    )
    .map_err(JhtdbError::Io)?;
    Ok(())
}

fn required_path(arguments: &[String], flag: &str) -> Result<PathBuf, JhtdbError> {
    arguments
        .iter()
        .position(|argument| argument == flag)
        .and_then(|index| arguments.get(index + 1))
        .map(PathBuf::from)
        .ok_or_else(|| JhtdbError::InvalidParameter(format!("missing {flag} <path>")))
}

fn optional_path(arguments: &[String], flag: &str) -> Result<Option<PathBuf>, JhtdbError> {
    let Some(index) = arguments.iter().position(|argument| argument == flag) else {
        return Ok(None);
    };
    arguments
        .get(index + 1)
        .map(|value| Some(PathBuf::from(value)))
        .ok_or_else(|| JhtdbError::InvalidParameter(format!("missing value after {flag}")))
}

fn optional_string(arguments: &[String], flag: &str) -> Result<Option<String>, JhtdbError> {
    let Some(index) = arguments.iter().position(|argument| argument == flag) else {
        return Ok(None);
    };
    arguments
        .get(index + 1)
        .cloned()
        .map(Some)
        .ok_or_else(|| JhtdbError::InvalidParameter(format!("missing value after {flag}")))
}

fn optional_usize(arguments: &[String], flag: &str) -> Result<Option<usize>, JhtdbError> {
    let Some(index) = arguments.iter().position(|argument| argument == flag) else {
        return Ok(None);
    };
    let value = arguments
        .get(index + 1)
        .ok_or_else(|| JhtdbError::InvalidParameter(format!("missing value after {flag}")))?;
    value
        .parse::<usize>()
        .map(Some)
        .map_err(|error| JhtdbError::InvalidParameter(format!("{flag}: {error}")))
}

fn optional_f64(arguments: &[String], flag: &str) -> Result<Option<f64>, JhtdbError> {
    let Some(index) = arguments.iter().position(|argument| argument == flag) else {
        return Ok(None);
    };
    let value = arguments
        .get(index + 1)
        .ok_or_else(|| JhtdbError::InvalidParameter(format!("missing value after {flag}")))?;
    value
        .parse::<f64>()
        .map(Some)
        .map_err(|error| JhtdbError::InvalidParameter(format!("{flag}: {error}")))
}
