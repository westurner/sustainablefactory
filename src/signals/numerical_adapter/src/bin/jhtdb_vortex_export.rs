use signals_numerical_adapter::jhtdb::{JhtdbCutout, JhtdbError};
use std::env;
use std::fs::File;
use std::io::Write;
use std::path::{Path, PathBuf};

#[cfg(feature = "vortex")]
use vortex::VortexSessionDefault;
#[cfg(feature = "vortex")]
use vortex::array::IntoArray;
#[cfg(feature = "vortex")]
use vortex::array::arrays::PrimitiveArray;
#[cfg(feature = "vortex")]
use vortex::array::validity::Validity;
#[cfg(feature = "vortex")]
use vortex::file::WriteOptionsSessionExt;
#[cfg(feature = "vortex")]
use vortex::io::session::RuntimeSessionExt;
#[cfg(feature = "vortex")]
use vortex::session::VortexSession;

fn main() {
    if let Err(error) = run() {
        eprintln!("jhtdb-vortex-export failed: {error}");
        std::process::exit(1);
    }
}

fn run() -> Result<(), JhtdbError> {
    let arguments: Vec<String> = env::args().collect();
    let input = required_path(&arguments, "--input")?;
    let output = required_path(&arguments, "--output")?;
    let manifest = required_path(&arguments, "--manifest")?;
    let expected_sha256 = optional_string(&arguments, "--expected-sha256")?;
    let cutout = JhtdbCutout::open(&input, expected_sha256.as_deref())?;
    let values = cutout.flattened_velocity_f32();
    write_vortex(&output, values)?;
    write_manifest(&manifest, &input, &output, &cutout)?;
    Ok(())
}

#[cfg(feature = "vortex")]
fn write_vortex(output: &Path, values: Vec<f32>) -> Result<(), JhtdbError> {
    let runtime = tokio::runtime::Runtime::new()
        .map_err(|error| JhtdbError::InvalidFormat(error.to_string()))?;
    runtime.block_on(async {
        let session = VortexSession::default().with_tokio();
        let array = PrimitiveArray::new(values, Validity::NonNullable);
        let writer = tokio::fs::File::create(output)
            .await
            .map_err(JhtdbError::Io)?;
        session
            .write_options()
            .write(writer, array.into_array().to_array_stream())
            .await
            .map_err(|error| JhtdbError::InvalidFormat(error.to_string()))?;
        Ok(())
    })
}

#[cfg(not(feature = "vortex"))]
fn write_vortex(_output: &Path, _values: Vec<f32>) -> Result<(), JhtdbError> {
    Err(JhtdbError::InvalidParameter(
        "the vortex feature is required".into(),
    ))
}

fn write_manifest(
    manifest: &Path,
    input: &Path,
    output: &Path,
    cutout: &JhtdbCutout,
) -> Result<(), JhtdbError> {
    let mut file = File::create(manifest)?;
    writeln!(file, "{{")?;
    writeln!(file, "  \"format\": \"jhtdb-velocity-vortex-v1\",")?;
    writeln!(file, "  \"input\": {:?},", input.display())?;
    writeln!(file, "  \"input_sha256\": {:?},", cutout.artifact_sha256())?;
    writeln!(file, "  \"output\": {:?},", output.display())?;
    writeln!(file, "  \"dtype\": \"little-endian f32\",")?;
    writeln!(
        file,
        "  \"layout\": \"frame-major, z-major, y-major, x-major, vector components\","
    )?;
    writeln!(
        file,
        "  \"dimensions\": [{}, {}, {}, {}, 3],",
        cutout.times().len(),
        cutout.z().len(),
        cutout.y().len(),
        cutout.x().len()
    )?;
    writeln!(file, "  \"times\": {:?},", cutout.times())?;
    writeln!(file, "  \"time_index_step\": {},", cutout.time_index_step())?;
    writeln!(
        file,
        "  \"time_calibration\": {:?},",
        cutout.time_calibration()
    )?;
    writeln!(file, "  \"coordinates\": {{")?;
    writeln!(file, "    \"x\": {:?},", cutout.x())?;
    writeln!(file, "    \"y\": {:?},", cutout.y())?;
    writeln!(file, "    \"z\": {:?}", cutout.z())?;
    writeln!(file, "  }},")?;
    writeln!(file, "  \"source\": \"JHTDB channel velocity HDF5 cutout\"")?;
    writeln!(file, "}}")?;
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
