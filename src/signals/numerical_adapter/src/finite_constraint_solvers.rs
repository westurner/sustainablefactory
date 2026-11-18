//! Exact finite baselines for constraint tasks referenced by the G-EBR chat blocks.
//!
//! These routines provide correctness fixtures for small N-Queens, graph-coloring,
//! Sudoku, and grid-symmetry problems. They do not implement or benchmark EBR/DPP.

use std::collections::BTreeSet;

/// Input or size errors for the finite reference solvers in this module.
#[derive(Clone, Debug, Eq, PartialEq)]
pub enum ConstraintError {
    EmptyBoard,
    BoardTooLarge(usize),
    InvalidColorCount,
    InvalidGraph,
    InvalidSolutionLimit,
    InvalidGrid,
    InvalidPermutation,
    InvalidPalette,
    InvalidMatrix,
    InvalidSudokuDigit(u8),
    InvalidSudokuPuzzle,
}

/// Count attacking pairs in a row-indexed N-Queens board.
///
/// The vector position is the queen's row and the value is its column.
pub fn count_nqueens_conflicts(queens: &[usize]) -> usize {
    let mut conflicts = 0;
    for first_row in 0..queens.len() {
        for second_row in (first_row + 1)..queens.len() {
            let row_distance = second_row - first_row;
            let column_distance = queens[first_row].abs_diff(queens[second_row]);
            if queens[first_row] == queens[second_row] || row_distance == column_distance {
                conflicts += 1;
            }
        }
    }
    conflicts
}

/// Enumerate every N-Queens solution for board sizes 1 through 12.
pub fn enumerate_nqueens_solutions(size: usize) -> Result<Vec<Vec<usize>>, ConstraintError> {
    if size == 0 {
        return Err(ConstraintError::EmptyBoard);
    }
    if size > 12 {
        return Err(ConstraintError::BoardTooLarge(size));
    }

    let mut solutions = Vec::new();
    let mut board = vec![0; size];
    let mut columns = vec![false; size];
    let mut descending_diagonals = vec![false; 2 * size - 1];
    let mut ascending_diagonals = vec![false; 2 * size - 1];
    enumerate_queens_from_row(
        0,
        &mut board,
        &mut columns,
        &mut descending_diagonals,
        &mut ascending_diagonals,
        &mut solutions,
    );
    Ok(solutions)
}

fn enumerate_queens_from_row(
    row: usize,
    board: &mut [usize],
    columns: &mut [bool],
    descending_diagonals: &mut [bool],
    ascending_diagonals: &mut [bool],
    solutions: &mut Vec<Vec<usize>>,
) {
    if row == board.len() {
        solutions.push(board.to_vec());
        return;
    }

    let board_size = board.len();
    for column in 0..board_size {
        let descending = row + column;
        let ascending = row + board_size - 1 - column;
        if columns[column] || descending_diagonals[descending] || ascending_diagonals[ascending] {
            continue;
        }

        board[row] = column;
        columns[column] = true;
        descending_diagonals[descending] = true;
        ascending_diagonals[ascending] = true;
        enumerate_queens_from_row(
            row + 1,
            board,
            columns,
            descending_diagonals,
            ascending_diagonals,
            solutions,
        );
        columns[column] = false;
        descending_diagonals[descending] = false;
        ascending_diagonals[ascending] = false;
    }
}

/// Return the D4 orbit of a row-indexed permutation board, deduplicated and sorted.
pub fn d4_orbit_boards(board: &[usize]) -> Result<Vec<Vec<usize>>, ConstraintError> {
    let size = board.len();
    if size == 0 {
        return Err(ConstraintError::EmptyBoard);
    }
    let mut seen_columns = vec![false; size];
    for &column in board {
        if column >= size || seen_columns[column] {
            return Err(ConstraintError::InvalidPermutation);
        }
        seen_columns[column] = true;
    }

    let mut orbit = BTreeSet::new();
    for rotations in 0..4 {
        for reflected in [false, true] {
            let mut transformed = vec![0; size];
            for (row, &column) in board.iter().enumerate() {
                let mut mapped_row = row;
                let mut mapped_column = column;
                for _ in 0..rotations {
                    (mapped_row, mapped_column) = (mapped_column, size - 1 - mapped_row);
                }
                if reflected {
                    mapped_column = size - 1 - mapped_column;
                }
                transformed[mapped_row] = mapped_column;
            }
            orbit.insert(transformed);
        }
    }
    Ok(orbit.into_iter().collect())
}

/// Count distinct N-Queens solutions modulo rotations and reflections.
pub fn nqueens_fundamental_solution_count(solutions: &[Vec<usize>]) -> Result<usize, ConstraintError> {
    let mut representatives = BTreeSet::new();
    for solution in solutions {
        let orbit = d4_orbit_boards(solution)?;
        representatives.insert(orbit[0].clone());
    }
    Ok(representatives.len())
}

/// Count conflicts in a graph coloring; invalid edge endpoints are ignored here.
pub fn count_graph_coloring_conflicts(coloring: &[usize], edges: &[(usize, usize)]) -> usize {
    edges
        .iter()
        .filter_map(|&(left, right)| coloring.get(left).zip(coloring.get(right)))
        .filter(|(left_color, right_color)| left_color == right_color)
        .count()
}

/// Enumerate up to `solution_limit` proper colorings of a finite graph.
pub fn enumerate_graph_colorings(
    vertex_count: usize,
    color_count: usize,
    edges: &[(usize, usize)],
    solution_limit: usize,
) -> Result<Vec<Vec<usize>>, ConstraintError> {
    if vertex_count == 0 {
        return Err(ConstraintError::EmptyBoard);
    }
    if color_count == 0 {
        return Err(ConstraintError::InvalidColorCount);
    }
    if solution_limit == 0 {
        return Err(ConstraintError::InvalidSolutionLimit);
    }
    if edges
        .iter()
        .any(|&(left, right)| left >= vertex_count || right >= vertex_count || left == right)
    {
        return Err(ConstraintError::InvalidGraph);
    }

    let mut vertex_order: Vec<usize> = (0..vertex_count).collect();
    vertex_order.sort_by(|left, right| {
        let left_degree = edges
            .iter()
            .filter(|&&(first, second)| first == *left || second == *left)
            .count();
        let right_degree = edges
            .iter()
            .filter(|&&(first, second)| first == *right || second == *right)
            .count();
        right_degree.cmp(&left_degree).then_with(|| left.cmp(right))
    });

    let mut coloring = vec![usize::MAX; vertex_count];
    let mut solutions = Vec::new();
    enumerate_colorings_from_vertex(
        0,
        &vertex_order,
        color_count,
        edges,
        solution_limit,
        &mut coloring,
        &mut solutions,
    );
    Ok(solutions)
}

fn enumerate_colorings_from_vertex(
    order_index: usize,
    vertex_order: &[usize],
    color_count: usize,
    edges: &[(usize, usize)],
    solution_limit: usize,
    coloring: &mut [usize],
    solutions: &mut Vec<Vec<usize>>,
) {
    if solutions.len() >= solution_limit {
        return;
    }
    if order_index == vertex_order.len() {
        solutions.push(coloring.to_vec());
        return;
    }

    let vertex = vertex_order[order_index];
    for color in 0..color_count {
        let conflicts = edges.iter().any(|&(left, right)| {
            if left == vertex {
                coloring[right] == color
            } else if right == vertex {
                coloring[left] == color
            } else {
                false
            }
        });
        if conflicts {
            continue;
        }
        coloring[vertex] = color;
        enumerate_colorings_from_vertex(
            order_index + 1,
            vertex_order,
            color_count,
            edges,
            solution_limit,
            coloring,
            solutions,
        );
        coloring[vertex] = usize::MAX;
        if solutions.len() >= solution_limit {
            return;
        }
    }
}

/// A finite square-grid transform from the chat's D4/glide/palette hypothesis family.
#[derive(Clone, Copy, Debug, Eq, Ord, PartialEq, PartialOrd)]
pub struct GridTransform {
    pub clockwise_quarter_turns: u8,
    pub reflect_vertical: bool,
    pub half_grid_glide: bool,
    pub invert_palette: bool,
}

/// A transform and its exact cell-mismatch count across demonstration pairs.
#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub struct GridTransformScore {
    pub transform: GridTransform,
    pub mismatches: usize,
}

/// Apply one D4 transform, an optional periodic half-grid shift, and optional palette inversion.
pub fn apply_grid_transform(
    grid: &[Vec<u8>],
    transform: GridTransform,
    max_color: u8,
) -> Result<Vec<Vec<u8>>, ConstraintError> {
    let size = grid.len();
    if size == 0 || grid.iter().any(|row| row.len() != size) {
        return Err(ConstraintError::InvalidGrid);
    }
    if grid.iter().flatten().any(|&color| color > max_color) {
        return Err(ConstraintError::InvalidPalette);
    }

    let mut output = vec![vec![0; size]; size];
    for (row, values) in grid.iter().enumerate() {
        for (column, &color) in values.iter().enumerate() {
            let mut mapped_row = row;
            let mut mapped_column = column;
            for _ in 0..(transform.clockwise_quarter_turns % 4) {
                (mapped_row, mapped_column) = (mapped_column, size - 1 - mapped_row);
            }
            if transform.reflect_vertical {
                mapped_column = size - 1 - mapped_column;
            }
            if transform.half_grid_glide {
                let half_size = size / 2;
                mapped_row = (mapped_row + half_size) % size;
                mapped_column = (mapped_column + half_size) % size;
            }
            let output_color = if transform.invert_palette {
                max_color - color
            } else {
                color
            };
            output[mapped_row][mapped_column] = output_color;
        }
    }
    Ok(output)
}

/// Score all 32 transforms in the finite hypothesis family against demonstration grids.
pub fn score_grid_transforms(
    demo_inputs: &[Vec<Vec<u8>>],
    demo_outputs: &[Vec<Vec<u8>>],
    max_color: u8,
) -> Result<Vec<GridTransformScore>, ConstraintError> {
    if demo_inputs.is_empty() || demo_inputs.len() != demo_outputs.len() {
        return Err(ConstraintError::InvalidGrid);
    }
    if demo_inputs.iter().zip(demo_outputs).any(|(input, output)| {
        input.is_empty()
            || input.len() != output.len()
            || input.iter().any(|row| row.len() != input.len())
            || output.iter().any(|row| row.len() != input.len())
    }) {
        return Err(ConstraintError::InvalidGrid);
    }

    let mut scores = Vec::new();
    for quarter_turns in 0..4 {
        for reflect_vertical in [false, true] {
            for half_grid_glide in [false, true] {
                for invert_palette in [false, true] {
                    let transform = GridTransform {
                        clockwise_quarter_turns: quarter_turns,
                        reflect_vertical,
                        half_grid_glide,
                        invert_palette,
                    };
                    let mut mismatches = 0;
                    for (input, expected) in demo_inputs.iter().zip(demo_outputs) {
                        let actual = apply_grid_transform(input, transform, max_color)?;
                        mismatches += actual
                            .iter()
                            .zip(expected)
                            .map(|(actual_row, expected_row)| {
                                actual_row
                                    .iter()
                                    .zip(expected_row)
                                    .filter(|(actual_cell, expected_cell)| actual_cell != expected_cell)
                                    .count()
                            })
                            .sum::<usize>();
                    }
                    scores.push(GridTransformScore { transform, mismatches });
                }
            }
        }
    }
    scores.sort_by_key(|score| (score.mismatches, score.transform));
    Ok(scores)
}

/// Solve a standard 9-by-9 Sudoku, preserving all supplied clues.
pub fn solve_sudoku(puzzle: [[u8; 9]; 9]) -> Result<Option<[[u8; 9]; 9]>, ConstraintError> {
    let mut row_masks = [0u16; 9];
    let mut column_masks = [0u16; 9];
    let mut box_masks = [0u16; 9];
    let mut board = puzzle;

    for row in 0..9 {
        for column in 0..9 {
            let digit = board[row][column];
            if digit == 0 {
                continue;
            }
            if digit > 9 {
                return Err(ConstraintError::InvalidSudokuDigit(digit));
            }
            let bit = 1u16 << digit;
            let box_index = (row / 3) * 3 + column / 3;
            if row_masks[row] & bit != 0
                || column_masks[column] & bit != 0
                || box_masks[box_index] & bit != 0
            {
                return Err(ConstraintError::InvalidSudokuPuzzle);
            }
            row_masks[row] |= bit;
            column_masks[column] |= bit;
            box_masks[box_index] |= bit;
        }
    }

    let solved = solve_sudoku_backtracking(&mut board, &mut row_masks, &mut column_masks, &mut box_masks);
    Ok(solved.then_some(board))
}

fn solve_sudoku_backtracking(
    board: &mut [[u8; 9]; 9],
    row_masks: &mut [u16; 9],
    column_masks: &mut [u16; 9],
    box_masks: &mut [u16; 9],
) -> bool {
    let mut best_cell = None;
    let mut best_candidates = 0u16;
    let mut best_count = u32::MAX;

    for row in 0..9 {
        for column in 0..9 {
            if board[row][column] != 0 {
                continue;
            }
            let box_index = (row / 3) * 3 + column / 3;
            let used = row_masks[row] | column_masks[column] | box_masks[box_index];
            let candidates = 0x03feu16 & !used;
            let candidate_count = candidates.count_ones();
            if candidate_count == 0 {
                return false;
            }
            if candidate_count < best_count {
                best_cell = Some((row, column, box_index));
                best_candidates = candidates;
                best_count = candidate_count;
                if candidate_count == 1 {
                    break;
                }
            }
        }
        if best_count == 1 {
            break;
        }
    }

    let Some((row, column, box_index)) = best_cell else {
        return true;
    };
    let mut candidates = best_candidates;
    while candidates != 0 {
        let bit = candidates & candidates.wrapping_neg();
        candidates &= !bit;
        let digit = bit.trailing_zeros() as u8;
        board[row][column] = digit;
        row_masks[row] |= bit;
        column_masks[column] |= bit;
        box_masks[box_index] |= bit;

        if solve_sudoku_backtracking(board, row_masks, column_masks, box_masks) {
            return true;
        }

        board[row][column] = 0;
        row_masks[row] &= !bit;
        column_masks[column] &= !bit;
        box_masks[box_index] &= !bit;
    }
    false
}

/// Apply a finite number of alternating row/column normalizations to a square logit matrix.
pub fn sinkhorn_birkhoff_project(
    logits: &[Vec<f64>],
    iterations: usize,
) -> Result<Vec<Vec<f64>>, ConstraintError> {
    let size = logits.len();
    if size == 0
        || logits.iter().any(|row| row.len() != size)
        || logits.iter().flatten().any(|value| !value.is_finite())
    {
        return Err(ConstraintError::InvalidMatrix);
    }

    let mut matrix = Vec::with_capacity(size);
    for row in logits {
        let max_logit = row.iter().copied().fold(f64::NEG_INFINITY, f64::max);
        matrix.push(row.iter().map(|value| (value - max_logit).exp()).collect::<Vec<_>>());
    }

    for _ in 0..iterations {
        for row in &mut matrix {
            let sum = row.iter().sum::<f64>();
            if !sum.is_finite() || sum <= 0.0 {
                return Err(ConstraintError::InvalidMatrix);
            }
            for value in row {
                *value /= sum;
            }
        }
        for column in 0..size {
            let sum = matrix.iter().map(|row| row[column]).sum::<f64>();
            if !sum.is_finite() || sum <= 0.0 {
                return Err(ConstraintError::InvalidMatrix);
            }
            for row in &mut matrix {
                row[column] /= sum;
            }
        }
    }
    Ok(matrix)
}

/// Scalar polynomial used for checking the McWeeny map; it is not a matrix projection.
pub fn mcweeny_scalar_sharpen(value: f64) -> f64 {
    3.0 * value * value - 2.0 * value * value * value
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::collections::BTreeMap;

    fn petersen_edges() -> Vec<(usize, usize)> {
        vec![
            (0, 1), (1, 2), (2, 3), (3, 4), (4, 0),
            (5, 7), (7, 9), (9, 6), (6, 8), (8, 5),
            (0, 5), (1, 6), (2, 7), (3, 8), (4, 9),
        ]
    }

    #[test]
    fn nqueens_counts_and_d4_orbits_are_exact_for_eight_and_ten() {
        let eight = enumerate_nqueens_solutions(8).unwrap();
        let ten = enumerate_nqueens_solutions(10).unwrap();
        assert_eq!(eight.len(), 92);
        assert_eq!(ten.len(), 724);
        assert_eq!(nqueens_fundamental_solution_count(&eight).unwrap(), 12);
        assert_eq!(nqueens_fundamental_solution_count(&ten).unwrap(), 92);
        assert!(eight.iter().all(|board| count_nqueens_conflicts(board) == 0));
        assert!(ten.iter().all(|board| count_nqueens_conflicts(board) == 0));

        let mut orbit_sizes = BTreeMap::new();
        for solution in &eight {
            let orbit = d4_orbit_boards(solution).unwrap();
            orbit_sizes.entry(orbit[0].clone()).or_insert(orbit.len());
        }
        let mut orbit_size_counts = BTreeMap::new();
        for orbit_size in orbit_sizes.values() {
            *orbit_size_counts.entry(*orbit_size).or_insert(0) += 1;
        }
        assert_eq!(orbit_size_counts.get(&4), Some(&1));
        assert_eq!(orbit_size_counts.get(&8), Some(&11));
    }

    #[test]
    fn graph_coloring_enumerator_returns_distinct_valid_petersen_colorings() {
        let edges = petersen_edges();
        let solutions = enumerate_graph_colorings(10, 3, &edges, 1000).unwrap();
        assert!(solutions.len() >= 20);
        let distinct: BTreeSet<_> = solutions.iter().collect();
        assert_eq!(distinct.len(), solutions.len());
        assert!(solutions
            .iter()
            .all(|coloring| count_graph_coloring_conflicts(coloring, &edges) == 0));
    }

    #[test]
    fn grid_transform_search_recovers_a_known_finite_rule() {
        let demo_input = vec![
            vec![1, 2, 0, 4],
            vec![0, 3, 1, 0],
            vec![5, 0, 2, 1],
            vec![0, 4, 0, 6],
        ];
        let rule = GridTransform {
            clockwise_quarter_turns: 2,
            reflect_vertical: false,
            half_grid_glide: true,
            invert_palette: true,
        };
        let demo_output = apply_grid_transform(&demo_input, rule, 9).unwrap();
        let scores = score_grid_transforms(&[demo_input], &[demo_output], 9).unwrap();
        assert_eq!(scores[0].mismatches, 0);
        assert!(scores.iter().any(|score| score.transform == rule && score.mismatches == 0));
    }

    #[test]
    fn sudoku_solver_preserves_clues_and_solves_the_reference_puzzle() {
        let puzzle = [
            [5, 3, 0, 0, 7, 0, 0, 0, 0],
            [6, 0, 0, 1, 9, 5, 0, 0, 0],
            [0, 9, 8, 0, 0, 0, 0, 6, 0],
            [8, 0, 0, 0, 6, 0, 0, 0, 3],
            [4, 0, 0, 8, 0, 3, 0, 0, 1],
            [7, 0, 0, 0, 2, 0, 0, 0, 6],
            [0, 6, 0, 0, 0, 0, 2, 8, 0],
            [0, 0, 0, 4, 1, 9, 0, 0, 5],
            [0, 0, 0, 0, 8, 0, 0, 7, 9],
        ];
        let solution = solve_sudoku(puzzle).unwrap().unwrap();
        assert_eq!(solution[0], [5, 3, 4, 6, 7, 8, 9, 1, 2]);
        for row in 0..9 {
            for column in 0..9 {
                assert!(puzzle[row][column] == 0 || puzzle[row][column] == solution[row][column]);
            }
        }
    }

    #[test]
    fn sinkhorn_and_mcweeny_helpers_match_their_scalar_contracts() {
        let logits = vec![vec![2.0, 0.0, -1.0], vec![0.0, 2.0, -1.0], vec![-1.0, 0.0, 2.0]];
        let matrix = sinkhorn_birkhoff_project(&logits, 80).unwrap();
        for row in &matrix {
            assert!((row.iter().sum::<f64>() - 1.0).abs() < 1e-10);
        }
        for column in 0..matrix.len() {
            assert!((matrix.iter().map(|row| row[column]).sum::<f64>() - 1.0).abs() < 1e-10);
        }
        assert_eq!(mcweeny_scalar_sharpen(0.0), 0.0);
        assert_eq!(mcweeny_scalar_sharpen(1.0), 1.0);
        assert!((mcweeny_scalar_sharpen(0.25) - 0.15625).abs() < 1e-12);
        assert_eq!(mcweeny_scalar_sharpen(0.5), 0.5);
    }
}