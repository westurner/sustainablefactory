use signals_numerical_adapter::cylinder::{CylinderError, CylinderFlow, FtleField};
use std::env;
use std::fs::File;
use std::io::{BufWriter, Write};
use std::path::{Path, PathBuf};

fn main() {
    if let Err(error) = run() {
        eprintln!("cylinder-ftle failed: {error}");
        std::process::exit(1);
    }
}

fn run() -> Result<(), CylinderError> {
    let arguments: Vec<String> = env::args().collect();
    let input = required_path(&arguments, "--input")?;
    let output = required_path(&arguments, "--output")?;
    let start_frame = optional_usize(&arguments, "--start-frame")?.unwrap_or(0);
    let frame_count = optional_usize(&arguments, "--frame-count")?;
    let flow = CylinderFlow::open(&input)?;
    let selected_count = frame_count.unwrap_or(flow.frames() - start_frame);
    let result = flow.compute_ftle(start_frame, selected_count)?;
    write_csv(&output, &flow, &result, start_frame)?;
    write_manifest(&output, &input, &flow, &result, start_frame, selected_count)?;
    let finite_values: Vec<f64> = result
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
        "cylinder FTLE computed: frames={}..{}, window={} s, valid={}, invalid={}, min={}, max={}, mean={}",
        start_frame,
        start_frame + selected_count - 1,
        result.time_window,
        result.valid_count,
        result.invalid_count,
        min,
        max,
        mean
    );
    Ok(())
}

fn write_csv(
    output: &PathBuf,
    flow: &CylinderFlow,
    result: &FtleField,
    start_frame: usize,
) -> Result<(), CylinderError> {
    let file = File::create(output)?;
    let mut writer = BufWriter::new(file);
    writeln!(writer, "row,column,x,y,ftle").map_err(CylinderError::Io)?;
    for row in 0..result.rows {
        for column in 0..result.columns {
            let index = row * result.columns + column;
            let x = flow.x0() + row as f64 * flow.dx();
            let y = flow.y0() + column as f64 * flow.dy();
            writeln!(writer, "{row},{column},{x},{y},{}", result.values[index])
                .map_err(CylinderError::Io)?;
        }
    }
    writer.flush().map_err(CylinderError::Io)?;
    println!(
        "wrote FTLE CSV for start frame {start_frame}: {}",
        output.display()
    );
    Ok(())
}

fn write_manifest(
    output: &Path,
    input: &Path,
    flow: &CylinderFlow,
    result: &FtleField,
    start_frame: usize,
    frame_count: usize,
) -> Result<(), CylinderError> {
    let manifest_path = output.with_extension("manifest.json");
    let interior_count = (result.rows - 2) * (result.columns - 2);
    let status = if result.valid_count == interior_count {
        "computed"
    } else {
        "incomplete"
    };
    let coverage = result.valid_count as f64 / interior_count as f64;
    let mut writer = BufWriter::new(File::create(&manifest_path)?);
    writeln!(writer, "{{").map_err(CylinderError::Io)?;
    writeln!(writer, "  \"format\": \"cylinder-ftle-v1\",").map_err(CylinderError::Io)?;
    writeln!(writer, "  \"status\": \"{status}\",").map_err(CylinderError::Io)?;
    writeln!(writer, "  \"input\": {:?},", input.display()).map_err(CylinderError::Io)?;
    writeln!(writer, "  \"output\": {:?},", output.display()).map_err(CylinderError::Io)?;
    writeln!(writer, "  \"start_frame\": {start_frame},").map_err(CylinderError::Io)?;
    writeln!(writer, "  \"frame_count\": {frame_count},").map_err(CylinderError::Io)?;
    writeln!(writer, "  \"rows\": {},", result.rows).map_err(CylinderError::Io)?;
    writeln!(writer, "  \"columns\": {},", result.columns).map_err(CylinderError::Io)?;
    writeln!(writer, "  \"sampling_hz\": {},", 1.0 / flow.time_step())
        .map_err(CylinderError::Io)?;
    writeln!(writer, "  \"time_window\": {},", result.time_window).map_err(CylinderError::Io)?;
    writeln!(
        writer,
        "  \"seed_spacing\": [{}, {}],",
        result.seed_spacing[0], result.seed_spacing[1]
    )
    .map_err(CylinderError::Io)?;
    writeln!(writer, "  \"valid_count\": {},", result.valid_count).map_err(CylinderError::Io)?;
    writeln!(writer, "  \"invalid_count\": {},", result.invalid_count)
        .map_err(CylinderError::Io)?;
    writeln!(writer, "  \"interior_count\": {interior_count},").map_err(CylinderError::Io)?;
    writeln!(writer, "  \"coverage_fraction\": {coverage},").map_err(CylinderError::Io)?;
    writeln!(writer, "  \"spatial_interpolation\": \"bilinear\",").map_err(CylinderError::Io)?;
    writeln!(
        writer,
        "  \"temporal_interpolation\": \"linear midpoint between adjacent frames\","
    )
    .map_err(CylinderError::Io)?;
    writeln!(writer, "  \"trajectory_integrator\": \"RK2 midpoint\",")
        .map_err(CylinderError::Io)?;
    writeln!(
        writer,
        "  \"deformation_method\": \"centered finite differences on seed grid\","
    )
    .map_err(CylinderError::Io)?;
    writeln!(writer, "  \"integration_error\": null,").map_err(CylinderError::Io)?;
    writeln!(writer, "  \"interpolation_error\": null,").map_err(CylinderError::Io)?;
    writeln!(writer, "  \"convergence_delta\": null").map_err(CylinderError::Io)?;
    writeln!(writer, "}}").map_err(CylinderError::Io)?;
    writer.flush().map_err(CylinderError::Io)?;
    println!("wrote FTLE manifest: {}", manifest_path.display());
    Ok(())
}

fn required_path(arguments: &[String], flag: &str) -> Result<PathBuf, CylinderError> {
    arguments
        .iter()
        .position(|argument| argument == flag)
        .and_then(|index| arguments.get(index + 1))
        .map(PathBuf::from)
        .ok_or_else(|| CylinderError::InvalidParameter(format!("missing {flag} <path>")))
}

fn optional_usize(arguments: &[String], flag: &str) -> Result<Option<usize>, CylinderError> {
    let Some(index) = arguments.iter().position(|argument| argument == flag) else {
        return Ok(None);
    };
    let value = arguments
        .get(index + 1)
        .ok_or_else(|| CylinderError::InvalidParameter(format!("missing value after {flag}")))?;
    value
        .parse::<usize>()
        .map(Some)
        .map_err(|error| CylinderError::InvalidParameter(format!("{flag}: {error}")))
}
