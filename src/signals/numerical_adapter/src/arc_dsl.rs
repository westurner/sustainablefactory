//! Typed compositional grid transformation DSL and bounded program synthesis
//! prototype for multi-step object/color/spatial grid tasks.
//!
//! Reuses:
//! - `multi_array_imaging` (Paper 17): rotation-invariant 2D covariance determinant,
//!   aspect ratio, bounding-box fill density, and signed PCA orientation angle for every
//!   extracted `GridObject`.
//! - `layer_groups` (WS-3): exact `D_4 ⊂ L_55 (p4mm)` affine operations for spatial
//!   rotations and reflections.
//! - `tequila_simulator` (Paper 44 / `src/tequila`): exact reversible `TequilaGateOp`
//!   quantum-circuit compilation (`X`, `SWAP`) of spatial flips, rotations, and transposes
//!   on `2^m × 2^m` grids executed by `simulate_circuit_msb`.
//!
//! This module extends the 32-element finite symmetry-rule finder in
//! `finite_constraint_solvers.rs` with connected-component object extraction,
//! morphology invariants, cropping, color remapping, tiling, mirroring, and bounded
//! compositional search. It is an auditable compositional DSL prototype, not
//! a claim of general ARC-AGI benchmark performance.

use std::collections::{BTreeMap, BTreeSet, VecDeque};

use crate::dft_plabic_vrc::C64;
use crate::layer_groups::LayerOp;
use crate::multi_array_imaging::{
    cosmic_ray_bbox_fill_density, cosmic_ray_cluster_aspect_ratio, cosmic_ray_covariance_det_2d,
    cosmic_ray_principal_axis_angle_rad,
};
use crate::tequila_simulator::{TequilaGateOp, simulate_circuit_msb};

pub type Grid = Vec<Vec<u8>>;

/// A 4-connected non-background component inside a 2D integer grid, enriched with
/// rotation-invariant PCA morphology descriptors reused from `multi_array_imaging`.
#[derive(Clone, Debug, PartialEq)]
pub struct GridObject {
    pub color: u8,
    pub cells: Vec<(usize, usize)>,
    pub min_row: usize,
    pub max_row: usize,
    pub min_col: usize,
    pub max_col: usize,
    pub aspect_ratio: f64,
    pub bbox_fill_density: f64,
    pub cov_det_2d: f64,
    pub principal_angle_rad: f64,
}

impl GridObject {
    pub fn area(&self) -> usize {
        self.cells.len()
    }
}

/// Compositional grid primitive operations.
#[derive(Clone, Debug, Eq, Ord, PartialEq, PartialOrd)]
pub enum GridOp {
    Rotate90,
    Rotate180,
    Rotate270,
    FlipHorizontal,
    FlipVertical,
    Transpose,
    CropNonZero,
    ExtractLargestObject,
    ExtractSmallestObject,
    Recolor { from: u8, to: u8 },
    Translate { dr: isize, dc: isize, fill: u8 },
    Tile { rows: usize, cols: usize },
    MirrorHorizontalConcat,
    MirrorVerticalConcat,
    FillBoundingBox { color: u8 },
}

/// A multi-step compositional program applied sequentially left-to-right.
#[derive(Clone, Debug, Eq, PartialEq)]
pub struct GridProgram {
    pub ops: Vec<GridOp>,
}

/// Extract all 4-connected non-zero (foreground) objects of uniform color.
pub fn extract_objects(grid: &Grid) -> Vec<GridObject> {
    if grid.is_empty() || grid[0].is_empty() {
        return Vec::new();
    }
    let h = grid.len();
    let w = grid[0].len();
    let mut visited = vec![vec![false; w]; h];
    let mut objects = Vec::new();

    for r in 0..h {
        for c in 0..w {
            let color = grid[r][c];
            if color == 0 || visited[r][c] {
                continue;
            }
            let mut queue = VecDeque::new();
            let mut cells = Vec::new();
            visited[r][c] = true;
            queue.push_back((r, c));
            let (mut min_r, mut max_r, mut min_c, mut max_c) = (r, r, c, c);

            while let Some((cr, cc)) = queue.pop_front() {
                cells.push((cr, cc));
                min_r = min_r.min(cr);
                max_r = max_r.max(cr);
                min_c = min_c.min(cc);
                max_c = max_c.max(cc);
                let neighbors = [
                    (cr.wrapping_sub(1), cc),
                    (cr + 1, cc),
                    (cr, cc.wrapping_sub(1)),
                    (cr, cc + 1),
                ];
                for (nr, nc) in neighbors {
                    if nr < h && nc < w && !visited[nr][nc] && grid[nr][nc] == color {
                        visited[nr][nc] = true;
                        queue.push_back((nr, nc));
                    }
                }
            }
            let area = cells.len() as f64;
            let bbox_h = (max_r - min_r + 1) as f64;
            let bbox_w = (max_c - min_c + 1) as f64;
            let mean_r = cells.iter().map(|&(pr, _)| pr as f64).sum::<f64>() / area;
            let mean_c = cells.iter().map(|&(_, pc)| pc as f64).sum::<f64>() / area;
            let mut sigma_rr = 0.0;
            let mut sigma_cc = 0.0;
            let mut sigma_rc = 0.0;
            for &(pr, pc) in &cells {
                let dr = pr as f64 - mean_r;
                let dc = pc as f64 - mean_c;
                sigma_rr += dr * dr;
                sigma_cc += dc * dc;
                sigma_rc += dr * dc;
            }
            sigma_rr /= area;
            sigma_cc /= area;
            sigma_rc /= area;

            objects.push(GridObject {
                color,
                cells,
                min_row: min_r,
                max_row: max_r,
                min_col: min_c,
                max_col: max_c,
                aspect_ratio: cosmic_ray_cluster_aspect_ratio(bbox_h, bbox_w),
                bbox_fill_density: cosmic_ray_bbox_fill_density(area, bbox_h, bbox_w),
                cov_det_2d: cosmic_ray_covariance_det_2d(sigma_rr, sigma_cc, sigma_rc),
                principal_angle_rad: cosmic_ray_principal_axis_angle_rad(
                    sigma_rr, sigma_cc, sigma_rc,
                ),
            });
        }
    }
    objects
}

/// Map a spatial `GridOp` into its exact `D_4 ⊂ L_55 (p4mm)` `LayerOp` matrix from `layer_groups`.
pub fn grid_op_to_layer_op(op: &GridOp) -> Option<LayerOp> {
    match op {
        GridOp::Rotate90 => Some(LayerOp::new(0, -1, 1, 0, 1, 0, 0)),
        GridOp::Rotate180 => Some(LayerOp::new(-1, 0, 0, -1, 1, 0, 0)),
        GridOp::Rotate270 => Some(LayerOp::new(0, 1, -1, 0, 1, 0, 0)),
        GridOp::FlipHorizontal => Some(LayerOp::new(1, 0, 0, -1, 1, 0, 0)),
        GridOp::FlipVertical => Some(LayerOp::new(-1, 0, 0, 1, 1, 0, 0)),
        GridOp::Transpose => Some(LayerOp::new(0, 1, 1, 0, 1, 0, 0)),
        _ => None,
    }
}

/// Compile a `D_4` spatial `GridOp` on a `2^m × 2^m` grid into exact reversible `TequilaGateOp`
/// instructions (`X` and `SWAP` on `2m` MSB address qubits: `0..m` = row, `m..2m` = col).
pub fn grid_op_to_tequila_gates(op: &GridOp, log2_side: usize) -> Option<Vec<TequilaGateOp>> {
    let m = log2_side;
    if m == 0 {
        return Some(Vec::new());
    }
    let flip_v = TequilaGateOp::Basic {
        name: "X".to_string(),
        targets: (0..m).collect(),
        controls: Vec::new(),
    };
    let flip_h = TequilaGateOp::Basic {
        name: "X".to_string(),
        targets: (m..(2 * m)).collect(),
        controls: Vec::new(),
    };
    let transpose_gates: Vec<TequilaGateOp> = (0..m)
        .map(|i| TequilaGateOp::Swap {
            q0: i,
            q1: m + i,
            controls: Vec::new(),
        })
        .collect();

    match op {
        GridOp::FlipVertical => Some(vec![flip_v]),
        GridOp::FlipHorizontal => Some(vec![flip_h]),
        GridOp::Rotate180 => Some(vec![flip_v, flip_h]),
        GridOp::Transpose => Some(transpose_gates),
        GridOp::Rotate90 => {
            // (r, c) -> (c, 2^m - 1 - r): Transpose then FlipHorizontal
            let mut g = transpose_gates;
            g.push(flip_h);
            Some(g)
        }
        GridOp::Rotate270 => {
            // (r, c) -> (2^m - 1 - c, r): FlipHorizontal then Transpose
            let mut g = vec![flip_h];
            g.extend(transpose_gates);
            Some(g)
        }
        _ => None,
    }
}

/// Execute a `D_4` spatial `GridOp` on a `2^m × 2^m` grid via `tequila_simulator::simulate_circuit_msb`
/// by encoding cell values as computational basis amplitudes `ψ[r * 2^m + c] = grid[r][c]`.
pub fn apply_grid_op_via_tequila_circuit(grid: &Grid, op: &GridOp) -> Option<Grid> {
    let side = grid.len();
    if side == 0 || !side.is_power_of_two() || grid.iter().any(|r| r.len() != side) {
        return None;
    }
    let m = side.trailing_zeros() as usize;
    let gates = grid_op_to_tequila_gates(op, m)?;
    let n_qubits = 2 * m;
    let mut init = Vec::with_capacity(side * side);
    for row in grid {
        for &val in row {
            init.push(C64::new(val as f64, 0.0));
        }
    }
    let evolved = simulate_circuit_msb(n_qubits, &init, &gates);
    let mut out = vec![vec![0u8; side]; side];
    for r in 0..side {
        for c in 0..side {
            out[r][c] = evolved[r * side + c].re.round().clamp(0.0, 255.0) as u8;
        }
    }
    Some(out)
}

fn render_object_bbox(obj: &GridObject) -> Grid {
    let h = obj.max_row - obj.min_row + 1;
    let w = obj.max_col - obj.min_col + 1;
    let mut out = vec![vec![0u8; w]; h];
    for &(r, c) in &obj.cells {
        out[r - obj.min_row][c - obj.min_col] = obj.color;
    }
    out
}

/// Apply one `GridOp` to a rectangular grid.
pub fn apply_op(grid: &Grid, op: &GridOp) -> Grid {
    if grid.is_empty() || grid[0].is_empty() {
        return grid.clone();
    }
    let h = grid.len();
    let w = grid[0].len();
    match op {
        GridOp::Rotate90 => {
            let mut out = vec![vec![0u8; h]; w];
            for r in 0..h {
                for c in 0..w {
                    out[c][h - 1 - r] = grid[r][c];
                }
            }
            out
        }
        GridOp::Rotate180 => {
            let mut out = vec![vec![0u8; w]; h];
            for r in 0..h {
                for c in 0..w {
                    out[h - 1 - r][w - 1 - c] = grid[r][c];
                }
            }
            out
        }
        GridOp::Rotate270 => {
            let mut out = vec![vec![0u8; h]; w];
            for r in 0..h {
                for c in 0..w {
                    out[w - 1 - c][r] = grid[r][c];
                }
            }
            out
        }
        GridOp::FlipHorizontal => grid
            .iter()
            .map(|row| row.iter().rev().copied().collect())
            .collect(),
        GridOp::FlipVertical => grid.iter().rev().cloned().collect(),
        GridOp::Transpose => {
            let mut out = vec![vec![0u8; h]; w];
            for r in 0..h {
                for c in 0..w {
                    out[c][r] = grid[r][c];
                }
            }
            out
        }
        GridOp::CropNonZero => {
            let (mut min_r, mut max_r, mut min_c, mut max_c) = (h, 0, w, 0);
            let mut any = false;
            for r in 0..h {
                for c in 0..w {
                    if grid[r][c] != 0 {
                        any = true;
                        min_r = min_r.min(r);
                        max_r = max_r.max(r);
                        min_c = min_c.min(c);
                        max_c = max_c.max(c);
                    }
                }
            }
            if !any {
                return grid.clone();
            }
            (min_r..=max_r)
                .map(|r| grid[r][min_c..=max_c].to_vec())
                .collect()
        }
        GridOp::ExtractLargestObject => {
            let objs = extract_objects(grid);
            if let Some(best) = objs.iter().max_by_key(|o| o.area()) {
                render_object_bbox(best)
            } else {
                grid.clone()
            }
        }
        GridOp::ExtractSmallestObject => {
            let objs = extract_objects(grid);
            if let Some(best) = objs.iter().min_by_key(|o| o.area()) {
                render_object_bbox(best)
            } else {
                grid.clone()
            }
        }
        GridOp::Recolor { from, to } => grid
            .iter()
            .map(|row| row.iter().map(|&v| if v == *from { *to } else { v }).collect())
            .collect(),
        GridOp::Translate { dr, dc, fill } => {
            let mut out = vec![vec![*fill; w]; h];
            for r in 0..h {
                for c in 0..w {
                    let nr = r as isize + dr;
                    let nc = c as isize + dc;
                    if nr >= 0 && (nr as usize) < h && nc >= 0 && (nc as usize) < w {
                        out[nr as usize][nc as usize] = grid[r][c];
                    }
                }
            }
            out
        }
        GridOp::Tile { rows, cols } => {
            let rr = (*rows).max(1);
            let cc = (*cols).max(1);
            let mut out = vec![vec![0u8; w * cc]; h * rr];
            for r in 0..(h * rr) {
                for c in 0..(w * cc) {
                    out[r][c] = grid[r % h][c % w];
                }
            }
            out
        }
        GridOp::MirrorHorizontalConcat => grid
            .iter()
            .map(|row| {
                let mut combined = row.clone();
                combined.extend(row.iter().rev().copied());
                combined
            })
            .collect(),
        GridOp::MirrorVerticalConcat => {
            let mut out = grid.clone();
            out.extend(grid.iter().rev().cloned());
            out
        }
        GridOp::FillBoundingBox { color } => {
            let mut out = grid.clone();
            let (mut min_r, mut max_r, mut min_c, mut max_c) = (h, 0, w, 0);
            let mut any = false;
            for r in 0..h {
                for c in 0..w {
                    if grid[r][c] != 0 {
                        any = true;
                        min_r = min_r.min(r);
                        max_r = max_r.max(r);
                        min_c = min_c.min(c);
                        max_c = max_c.max(c);
                    }
                }
            }
            if any {
                for r in min_r..=max_r {
                    for c in min_c..=max_c {
                        if out[r][c] == 0 {
                            out[r][c] = *color;
                        }
                    }
                }
            }
            out
        }
    }
}

/// Apply a compositional program sequentially.
pub fn apply_program(grid: &Grid, program: &GridProgram) -> Grid {
    program.ops.iter().fold(grid.clone(), |acc, op| apply_op(&acc, op))
}

/// Build a task-informed candidate primitive pool from training pairs.
fn candidate_ops_for_pairs(train_pairs: &[(Grid, Grid)]) -> Vec<GridOp> {
    let mut in_colors = BTreeSet::new();
    let mut out_colors = BTreeSet::new();
    for (inp, out) in train_pairs {
        for row in inp {
            for &v in row {
                if v != 0 {
                    in_colors.insert(v);
                }
            }
        }
        for row in out {
            for &v in row {
                if v != 0 {
                    out_colors.insert(v);
                }
            }
        }
    }

    let mut ops = vec![
        GridOp::Rotate90,
        GridOp::Rotate180,
        GridOp::Rotate270,
        GridOp::FlipHorizontal,
        GridOp::FlipVertical,
        GridOp::Transpose,
        GridOp::CropNonZero,
        GridOp::ExtractLargestObject,
        GridOp::ExtractSmallestObject,
        GridOp::MirrorHorizontalConcat,
        GridOp::MirrorVerticalConcat,
        GridOp::Tile { rows: 2, cols: 2 },
        GridOp::Tile { rows: 1, cols: 2 },
        GridOp::Tile { rows: 2, cols: 1 },
        GridOp::Translate { dr: 0, dc: 1, fill: 0 },
        GridOp::Translate { dr: 1, dc: 0, fill: 0 },
    ];
    for &c_in in &in_colors {
        for &c_out in &out_colors {
            if c_in != c_out {
                ops.push(GridOp::Recolor { from: c_in, to: c_out });
            }
        }
    }
    for &c_out in &out_colors {
        ops.push(GridOp::FillBoundingBox { color: c_out });
    }
    ops
}

/// Bounded BFS synthesis of the shortest compositional `GridProgram` up to `max_depth`
/// that reproduces every `(input, output)` training pair exactly.
pub fn synthesize_grid_program(
    train_pairs: &[(Grid, Grid)],
    max_depth: usize,
) -> Option<GridProgram> {
    if train_pairs.is_empty() {
        return None;
    }
    if train_pairs.iter().all(|(i, o)| i == o) {
        return Some(GridProgram { ops: Vec::new() });
    }
    let primitives = candidate_ops_for_pairs(train_pairs);
    let mut seen_states: BTreeMap<Vec<Grid>, usize> = BTreeMap::new();
    let initial_states: Vec<Grid> = train_pairs.iter().map(|(i, _)| i.clone()).collect();
    let target_states: Vec<Grid> = train_pairs.iter().map(|(_, o)| o.clone()).collect();

    let mut queue: VecDeque<(Vec<GridOp>, Vec<Grid>)> = VecDeque::new();
    seen_states.insert(initial_states.clone(), 0);
    queue.push_back((Vec::new(), initial_states));

    while let Some((ops, states)) = queue.pop_front() {
        if ops.len() >= max_depth {
            continue;
        }
        for prim in &primitives {
            let next_states: Vec<Grid> = states.iter().map(|g| apply_op(g, prim)).collect();
            // Guard against unbounded growth during tiling
            if next_states.iter().any(|g| g.len() > 30 || g.first().map(|r| r.len()).unwrap_or(0) > 30) {
                continue;
            }
            let mut next_ops = ops.clone();
            next_ops.push(prim.clone());
            if next_states == target_states {
                return Some(GridProgram { ops: next_ops });
            }
            let next_depth = next_ops.len();
            if next_depth < max_depth && !seen_states.contains_key(&next_states) {
                seen_states.insert(next_states.clone(), next_depth);
                queue.push_back((next_ops, next_states));
            }
        }
    }
    None
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn synthesizes_multistep_object_extraction_recolor_and_mirror_program() {
        // Task: extract largest object, recolor 2 -> 5, then mirror horizontally.
        let train1_in = vec![
            vec![0, 1, 0, 0, 0],
            vec![0, 0, 0, 2, 2],
            vec![0, 0, 0, 2, 0],
            vec![0, 0, 0, 0, 0],
        ];
        let train1_out = vec![
            vec![5, 5, 5, 5],
            vec![5, 0, 0, 5],
        ];
        let train2_in = vec![
            vec![3, 0, 0, 0],
            vec![0, 2, 2, 0],
            vec![0, 0, 2, 0],
        ];
        let train2_out = vec![
            vec![5, 5, 5, 5],
            vec![0, 5, 5, 0],
        ];

        let prog = synthesize_grid_program(&[(train1_in, train1_out), (train2_in, train2_out)], 3)
            .expect("should synthesize 3-step compositional program");
        assert!(prog.ops.len() <= 3);

        // Held-out evaluation grid
        let test_in = vec![
            vec![0, 0, 4, 0],
            vec![2, 0, 0, 0],
            vec![2, 2, 0, 0],
        ];
        let test_expected = vec![
            vec![5, 0, 0, 5],
            vec![5, 5, 5, 5],
        ];
        assert_eq!(apply_program(&test_in, &prog), test_expected);
    }

    #[test]
    fn synthesizes_crop_and_tile_program() {
        let inp = vec![
            vec![0, 0, 0, 0],
            vec![0, 3, 1, 0],
            vec![0, 0, 0, 0],
        ];
        let out = vec![
            vec![3, 1, 3, 1],
            vec![3, 1, 3, 1],
        ];
        let prog = synthesize_grid_program(&[(inp.clone(), out.clone())], 2).unwrap();
        assert_eq!(apply_program(&inp, &prog), out);
    }

    #[test]
    fn tequila_quantum_circuit_matches_all_d4_grid_ops_and_object_invariants() {
        let grid = vec![
            vec![1, 2, 0, 0],
            vec![0, 2, 0, 3],
            vec![0, 0, 4, 3],
            vec![5, 0, 0, 0],
        ];
        let d4_ops = [
            GridOp::Rotate90,
            GridOp::Rotate180,
            GridOp::Rotate270,
            GridOp::FlipHorizontal,
            GridOp::FlipVertical,
            GridOp::Transpose,
        ];
        let orig_objs = extract_objects(&grid);
        let orig_l_obj = orig_objs.iter().find(|o| o.color == 2).unwrap();

        for op in &d4_ops {
            let classical = apply_op(&grid, op);
            let quantum = apply_grid_op_via_tequila_circuit(&grid, op)
                .expect("4x4 grid should compile to 4-qubit Tequila circuit");
            assert_eq!(classical, quantum, "Tequila circuit mismatch for {op:?}");
            assert!(grid_op_to_layer_op(op).is_some());

            // Rotation/flip invariance of multi_array_imaging PCA determinant & aspect ratio
            let rot_objs = extract_objects(&quantum);
            let rot_l_obj = rot_objs.iter().find(|o| o.color == 2).unwrap();
            assert!((orig_l_obj.cov_det_2d - rot_l_obj.cov_det_2d).abs() < 1e-12);
            assert!((orig_l_obj.aspect_ratio - rot_l_obj.aspect_ratio).abs() < 1e-12);
            assert!((orig_l_obj.bbox_fill_density - rot_l_obj.bbox_fill_density).abs() < 1e-12);
        }
    }
}
