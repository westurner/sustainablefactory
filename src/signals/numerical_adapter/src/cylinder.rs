use memmap2::Mmap;
use rayon::prelude::*;
use std::fmt;
use std::fs::File;
use std::path::Path;

const MAGIC: &[u8; 8] = b"SFLOW01\0";
const HEADER_SIZE: usize = 144;

#[derive(Debug)]
pub enum CylinderError {
    Io(std::io::Error),
    InvalidFormat(String),
    InvalidParameter(String),
}

impl fmt::Display for CylinderError {
    fn fmt(&self, formatter: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::Io(error) => write!(formatter, "I/O error: {error}"),
            Self::InvalidFormat(message) => write!(formatter, "invalid cylinder flow: {message}"),
            Self::InvalidParameter(message) => {
                write!(formatter, "invalid cylinder parameter: {message}")
            }
        }
    }
}

impl std::error::Error for CylinderError {}

impl From<std::io::Error> for CylinderError {
    fn from(error: std::io::Error) -> Self {
        Self::Io(error)
    }
}

#[derive(Clone, Copy, Debug)]
struct Header {
    rows: usize,
    columns: usize,
    frames: usize,
    time_step: f64,
    x0: f64,
    dx: f64,
    y0: f64,
    dy: f64,
    u_offset: usize,
    v_offset: usize,
}

#[derive(Debug)]
pub struct CylinderFlow {
    mapping: Mmap,
    header: Header,
}

#[derive(Clone, Debug, PartialEq)]
pub struct FtleField {
    pub values: Vec<f64>,
    pub rows: usize,
    pub columns: usize,
    pub time_window: f64,
    pub seed_spacing: [f64; 2],
    pub valid_count: usize,
    pub invalid_count: usize,
}

impl CylinderFlow {
    pub fn open<P: AsRef<Path>>(path: P) -> Result<Self, CylinderError> {
        let file = File::open(path)?;
        let file_len = usize::try_from(file.metadata()?.len()).map_err(|_| {
            CylinderError::InvalidFormat("file is too large for this platform".into())
        })?;
        if file_len < HEADER_SIZE {
            return Err(CylinderError::InvalidFormat(
                "file is shorter than the header".into(),
            ));
        }
        // The mapped file owns the read-only backing storage for all worker threads.
        let mapping = unsafe { Mmap::map(&file)? };
        let header = parse_header(&mapping[..HEADER_SIZE])?;
        let plane_values = header
            .rows
            .checked_mul(header.columns)
            .ok_or_else(|| CylinderError::InvalidFormat("spatial shape overflows usize".into()))?;
        let frame_values = plane_values
            .checked_mul(header.frames)
            .ok_or_else(|| CylinderError::InvalidFormat("frame shape overflows usize".into()))?;
        let data_bytes = frame_values
            .checked_mul(std::mem::size_of::<f32>())
            .ok_or_else(|| CylinderError::InvalidFormat("data size overflows usize".into()))?;
        let expected_end = header
            .v_offset
            .checked_add(data_bytes)
            .ok_or_else(|| CylinderError::InvalidFormat("file offsets overflow usize".into()))?;
        if header.u_offset < HEADER_SIZE
            || header.v_offset < header.u_offset
            || expected_end > mapping.len()
        {
            return Err(CylinderError::InvalidFormat(
                "data offsets do not match file length".into(),
            ));
        }
        if header.rows < 3 || header.columns < 3 || header.frames < 2 {
            return Err(CylinderError::InvalidFormat(
                "need at least 3x3 spatial points and two frames".into(),
            ));
        }
        if !header.time_step.is_finite()
            || header.time_step <= 0.0
            || !header.x0.is_finite()
            || !header.dx.is_finite()
            || header.dx == 0.0
            || !header.y0.is_finite()
            || !header.dy.is_finite()
            || header.dy == 0.0
        {
            return Err(CylinderError::InvalidFormat(
                "non-finite or zero grid/time spacing".into(),
            ));
        }
        Ok(Self { mapping, header })
    }

    pub fn rows(&self) -> usize {
        self.header.rows
    }

    pub fn columns(&self) -> usize {
        self.header.columns
    }

    pub fn frames(&self) -> usize {
        self.header.frames
    }

    pub fn time_step(&self) -> f64 {
        self.header.time_step
    }

    pub fn x0(&self) -> f64 {
        self.header.x0
    }

    pub fn dx(&self) -> f64 {
        self.header.dx
    }

    pub fn y0(&self) -> f64 {
        self.header.y0
    }

    pub fn dy(&self) -> f64 {
        self.header.dy
    }

    pub fn compute_ftle(
        &self,
        start_frame: usize,
        frame_count: usize,
    ) -> Result<FtleField, CylinderError> {
        if frame_count < 2 {
            return Err(CylinderError::InvalidParameter(
                "frame_count must be at least two".into(),
            ));
        }
        let end_frame = start_frame
            .checked_add(frame_count)
            .ok_or_else(|| CylinderError::InvalidParameter("frame range overflows usize".into()))?;
        if end_frame > self.frames() {
            return Err(CylinderError::InvalidParameter(format!(
                "frame range [{start_frame}, {end_frame}) exceeds {} frames",
                self.frames()
            )));
        }
        let seed_count = self.rows() * self.columns();
        let final_positions: Vec<Option<[f64; 2]>> = (0..seed_count)
            .into_par_iter()
            .map(|seed| {
                let row = seed / self.columns();
                let column = seed % self.columns();
                let initial = [
                    self.header.x0 + row as f64 * self.header.dx,
                    self.header.y0 + column as f64 * self.header.dy,
                ];
                self.advect(initial, start_frame, frame_count)
            })
            .collect();

        let time_window = self.header.time_step * (frame_count - 1) as f64;
        let mut values = vec![f64::NAN; seed_count];
        let mut valid_count = 0;
        for row in 1..self.rows() - 1 {
            for column in 1..self.columns() - 1 {
                let index = row * self.columns() + column;
                let Some(center) = final_positions[index] else {
                    continue;
                };
                let Some(left) = final_positions[index - self.columns()] else {
                    continue;
                };
                let Some(right) = final_positions[index + self.columns()] else {
                    continue;
                };
                let Some(down) = final_positions[index - 1] else {
                    continue;
                };
                let Some(up) = final_positions[index + 1] else {
                    continue;
                };
                let dphi_dx = [
                    (right[0] - left[0]) / (2.0 * self.header.dx),
                    (right[1] - left[1]) / (2.0 * self.header.dx),
                ];
                let dphi_dy = [
                    (up[0] - down[0]) / (2.0 * self.header.dy),
                    (up[1] - down[1]) / (2.0 * self.header.dy),
                ];
                let c00 = dphi_dx[0] * dphi_dx[0] + dphi_dx[1] * dphi_dx[1];
                let c01 = dphi_dx[0] * dphi_dy[0] + dphi_dx[1] * dphi_dy[1];
                let c11 = dphi_dy[0] * dphi_dy[0] + dphi_dy[1] * dphi_dy[1];
                let discriminant = ((c00 - c11) * (c00 - c11) + 4.0 * c01 * c01).sqrt();
                let lambda_max = 0.5 * (c00 + c11 + discriminant);
                if lambda_max.is_finite() && lambda_max > 0.0 && time_window > 0.0 {
                    values[index] = 0.5 * lambda_max.ln() / time_window;
                    valid_count += 1;
                }
                let _ = center;
            }
        }
        Ok(FtleField {
            values,
            rows: self.rows(),
            columns: self.columns(),
            time_window,
            seed_spacing: [self.header.dx.abs(), self.header.dy.abs()],
            valid_count,
            invalid_count: seed_count - valid_count,
        })
    }

    fn advect(
        &self,
        mut position: [f64; 2],
        start_frame: usize,
        frame_count: usize,
    ) -> Option<[f64; 2]> {
        let end_frame = start_frame + frame_count - 1;
        for frame in start_frame..end_frame {
            let velocity = self.sample_velocity(frame, position)?;
            let midpoint = [
                position[0] + 0.5 * self.header.time_step * velocity[0],
                position[1] + 0.5 * self.header.time_step * velocity[1],
            ];
            let midpoint_velocity = self.sample_velocity_midpoint(frame, midpoint)?;
            position[0] += self.header.time_step * midpoint_velocity[0];
            position[1] += self.header.time_step * midpoint_velocity[1];
        }
        Some(position)
    }

    fn sample_velocity(&self, frame: usize, position: [f64; 2]) -> Option<[f64; 2]> {
        Some([
            self.sample_component(self.header.u_offset, frame, position)?,
            self.sample_component(self.header.v_offset, frame, position)?,
        ])
    }

    fn sample_velocity_midpoint(&self, frame: usize, position: [f64; 2]) -> Option<[f64; 2]> {
        let current = self.sample_velocity(frame, position)?;
        let next = self.sample_velocity(frame + 1, position)?;
        Some([0.5 * (current[0] + next[0]), 0.5 * (current[1] + next[1])])
    }

    fn sample_component(&self, offset: usize, frame: usize, position: [f64; 2]) -> Option<f64> {
        let row_coordinate = (position[0] - self.header.x0) / self.header.dx;
        let column_coordinate = (position[1] - self.header.y0) / self.header.dy;
        if !row_coordinate.is_finite()
            || !column_coordinate.is_finite()
            || row_coordinate < 0.0
            || column_coordinate < 0.0
            || row_coordinate > (self.rows() - 1) as f64
            || column_coordinate > (self.columns() - 1) as f64
        {
            return None;
        }
        let (row0, row_fraction) = interpolation_index(row_coordinate, self.rows());
        let (column0, column_fraction) = interpolation_index(column_coordinate, self.columns());
        let plane = self.rows() * self.columns();
        let base = offset + (frame * plane + row0 * self.columns() + column0) * 4;
        let stride = self.columns() * 4;
        let q00 = self.read_f32(base)? as f64;
        let q10 = self.read_f32(base + stride)? as f64;
        let q01 = self.read_f32(base + 4)? as f64;
        let q11 = self.read_f32(base + stride + 4)? as f64;
        if !(q00.is_finite() && q10.is_finite() && q01.is_finite() && q11.is_finite()) {
            return None;
        }
        let lower = q00 + row_fraction * (q10 - q00);
        let upper = q01 + row_fraction * (q11 - q01);
        Some(lower + column_fraction * (upper - lower))
    }

    fn read_f32(&self, offset: usize) -> Option<f32> {
        let bytes = self.mapping.get(offset..offset + 4)?;
        Some(f32::from_le_bytes(bytes.try_into().ok()?))
    }
}

fn interpolation_index(coordinate: f64, extent: usize) -> (usize, f64) {
    if coordinate >= (extent - 1) as f64 {
        (extent - 2, 1.0)
    } else {
        let lower = coordinate.floor() as usize;
        (lower, coordinate - lower as f64)
    }
}

fn parse_header(bytes: &[u8]) -> Result<Header, CylinderError> {
    if bytes.get(0..8) != Some(MAGIC) {
        return Err(CylinderError::InvalidFormat("bad SFLOW01 magic".into()));
    }
    let version = read_u32(bytes, 8)?;
    let header_size = read_u32(bytes, 12)? as usize;
    if version != 1 || header_size != HEADER_SIZE {
        return Err(CylinderError::InvalidFormat(
            "unsupported header version or size".into(),
        ));
    }
    Ok(Header {
        rows: read_u64(bytes, 16)? as usize,
        columns: read_u64(bytes, 24)? as usize,
        frames: read_u64(bytes, 32)? as usize,
        time_step: read_f64(bytes, 40)?,
        x0: read_f64(bytes, 48)?,
        dx: read_f64(bytes, 56)?,
        y0: read_f64(bytes, 64)?,
        dy: read_f64(bytes, 72)?,
        u_offset: read_u64(bytes, 80)? as usize,
        v_offset: read_u64(bytes, 88)? as usize,
    })
}

fn read_u32(bytes: &[u8], offset: usize) -> Result<u32, CylinderError> {
    let slice = bytes
        .get(offset..offset + 4)
        .ok_or_else(|| CylinderError::InvalidFormat("truncated header".into()))?;
    Ok(u32::from_le_bytes(slice.try_into().unwrap()))
}

fn read_u64(bytes: &[u8], offset: usize) -> Result<u64, CylinderError> {
    let slice = bytes
        .get(offset..offset + 8)
        .ok_or_else(|| CylinderError::InvalidFormat("truncated header".into()))?;
    Ok(u64::from_le_bytes(slice.try_into().unwrap()))
}

fn read_f64(bytes: &[u8], offset: usize) -> Result<f64, CylinderError> {
    let slice = bytes
        .get(offset..offset + 8)
        .ok_or_else(|| CylinderError::InvalidFormat("truncated header".into()))?;
    Ok(f64::from_le_bytes(slice.try_into().unwrap()))
}
