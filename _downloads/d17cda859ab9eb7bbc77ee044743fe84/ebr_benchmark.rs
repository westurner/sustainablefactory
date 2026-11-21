//! Continuous-relaxation Energy-Based Reasoning (EBR) benchmark harness with
//! adaptive gradient-norm halting and optional Slavnov–Gram DPP repulsion.
//!
//! Deliberately separated from the exact backtracking oracles in
//! `finite_constraint_solvers.rs` so empirical `Pass@1`, `Cov@K`, halting steps,
//! and wall-clock timings are reported transparently from seeded runs rather than
//! extrapolated from synthetic FLOP ratios.

use std::collections::BTreeSet;
use std::time::Instant;

use crate::finite_constraint_solvers::{
    count_nqueens_conflicts, d4_orbit_boards, enumerate_nqueens_solutions, mcweeny_scalar_sharpen,
    sinkhorn_birkhoff_project,
};
use crate::slavnov_dpp::evaluate_gram_dpp;

/// Deterministic splitmix64 PRNG so all benchmark runs are 100% reproducible from their seed.
struct SplitMix64 {
    state: u64,
}

impl SplitMix64 {
    fn new(seed: u64) -> Self {
        Self { state: seed }
    }

    fn next_u64(&mut self) -> u64 {
        self.state = self.state.wrapping_add(0x9e3779b97f4a7c15);
        let mut z = self.state;
        z = (z ^ (z >> 30)).wrapping_mul(0xbf58476d1ce4e5b9);
        z = (z ^ (z >> 27)).wrapping_mul(0x94d049bb133111eb);
        z ^ (z >> 31)
    }

    fn next_f64(&mut self) -> f64 {
        (self.next_u64() >> 11) as f64 / ((1u64 << 53) as f64)
    }
}

/// Frobenius norm `‖P² - P‖_F` checking projector idempotency.
pub fn projector_idempotency_residual(p: &[Vec<f64>]) -> f64 {
    let n = p.len();
    let mut sum_sq = 0.0;
    for i in 0..n {
        for j in 0..n {
            let mut p2_ij = 0.0;
            for k in 0..n {
                p2_ij += p[i][k] * p[k][j];
            }
            let diff = p2_ij - p[i][j];
            sum_sq += diff * diff;
        }
    }
    sum_sq.sqrt()
}

/// Continuous relaxation energy for N-Queens over a nonnegative `n × n` matrix `P`:
/// `E(P) = 0.5 Σ_r (Σ_c P_rc - 1)^2 + 0.5 Σ_c (Σ_r P_rc - 1)^2`
///       `+ 0.5 Σ_d max(0, Σ_{(r,c)∈d} P_rc - 1)^2` (both diagonal families).
pub fn nqueens_continuous_energy_and_grad(p: &[Vec<f64>]) -> (f64, Vec<Vec<f64>>) {
    let n = p.len();
    let mut energy = 0.0;
    let mut grad = vec![vec![0.0; n]; n];

    // Row sums
    for r in 0..n {
        let sum: f64 = p[r].iter().sum();
        let diff = sum - 1.0;
        energy += 0.5 * diff * diff;
        for c in 0..n {
            grad[r][c] += diff;
        }
    }
    // Col sums
    for c in 0..n {
        let sum: f64 = (0..n).map(|r| p[r][c]).sum();
        let diff = sum - 1.0;
        energy += 0.5 * diff * diff;
        for r in 0..n {
            grad[r][c] += diff;
        }
    }
    // Descending diagonals (r + c = d)
    for d in 0..(2 * n - 1) {
        let mut sum = 0.0;
        for r in 0..n {
            if d >= r && d - r < n {
                sum += p[r][d - r];
            }
        }
        if sum > 1.0 {
            let excess = sum - 1.0;
            energy += 0.5 * excess * excess;
            for r in 0..n {
                if d >= r && d - r < n {
                    grad[r][d - r] += excess;
                }
            }
        }
    }
    // Ascending diagonals (r + n - 1 - c = d)
    for d in 0..(2 * n - 1) {
        let mut sum = 0.0;
        for r in 0..n {
            let c_plus = r + n - 1;
            if c_plus >= d && c_plus - d < n {
                sum += p[r][c_plus - d];
            }
        }
        if sum > 1.0 {
            let excess = sum - 1.0;
            energy += 0.5 * excess * excess;
            for r in 0..n {
                let c_plus = r + n - 1;
                if c_plus >= d && c_plus - d < n {
                    grad[r][c_plus - d] += excess;
                }
            }
        }
    }

    (energy, grad)
}

fn round_matrix_to_board(p: &[Vec<f64>]) -> Vec<usize> {
    let n = p.len();
    let mut board = vec![0usize; n];
    for r in 0..n {
        let mut best_c = 0;
        let mut best_v = f64::NEG_INFINITY;
        for c in 0..n {
            if p[r][c] > best_v {
                best_v = p[r][c];
                best_c = c;
            }
        }
        board[r] = best_c;
    }
    board
}

/// Transparent empirical report from seeded EBR + adaptive halting (+ optional DPP) runs.
#[derive(Clone, Debug)]
pub struct EbrBenchmarkReport {
    pub problem: String,
    pub seed: u64,
    pub trajectories: usize,
    pub max_steps: usize,
    pub dpp_weight: f64,
    pub valid_trajectories: usize,
    pub pass_at_1: f64,
    pub distinct_valid_solutions: usize,
    pub distinct_d4_orbits: usize,
    pub exact_oracle_solutions: usize,
    pub mean_halting_steps: f64,
    pub wall_time_ms: f64,
}

/// Run `trajectories` parallel EBR continuous-relaxation trajectories on `size`-Queens
/// with Sinkhorn doubly-stochastic projection, McWeeny sharpening, adaptive gradient-norm
/// halting (`‖∇E‖_2 < grad_tol` or 0 discrete conflicts), and optional Slavnov–Gram DPP repulsion.
pub fn run_ebr_nqueens_benchmark(
    size: usize,
    trajectories: usize,
    max_steps: usize,
    step_size: f64,
    grad_tol: f64,
    dpp_weight: f64,
    seed: u64,
) -> EbrBenchmarkReport {
    let start = Instant::now();
    let mut rng = SplitMix64::new(seed);
    let oracle_count = enumerate_nqueens_solutions(size)
        .map(|s| s.len())
        .unwrap_or(0);

    // Initialize K random doubly-stochastic matrices
    let mut states: Vec<Vec<Vec<f64>>> = (0..trajectories)
        .map(|_| {
            let raw: Vec<Vec<f64>> = (0..size)
                .map(|_| (0..size).map(|_| 0.05 + rng.next_f64()).collect())
                .collect();
            sinkhorn_birkhoff_project(&raw, 10).unwrap_or(raw)
        })
        .collect();

    let mut halted = vec![false; trajectories];
    let mut halt_steps = vec![max_steps; trajectories];

    for step in 1..=max_steps {
        // Optional DPP diversity gradient across active + halted trajectories
        let dpp_grads: Option<Vec<Vec<f64>>> = if dpp_weight > 0.0 && trajectories > 1 {
            let feats: Vec<Vec<f64>> = states
                .iter()
                .map(|mat| mat.iter().flat_map(|r| r.iter().copied()).collect())
                .collect();
            evaluate_gram_dpp(&feats, 1e-2).ok().map(|ev| ev.grad_features)
        } else {
            None
        };

        let mut all_halted = true;
        for k in 0..trajectories {
            if halted[k] {
                continue;
            }
            all_halted = false;
            let (_, grad) = nqueens_continuous_energy_and_grad(&states[k]);
            let mut grad_norm_sq = 0.0;
            for r in 0..size {
                for c in 0..size {
                    let g_dpp = dpp_grads
                        .as_ref()
                        .map(|dg| dg[k][r * size + c])
                        .unwrap_or(0.0);
                    // Minimize E - dpp_weight * log det(G_eps)
                    let total_g = grad[r][c] - dpp_weight * g_dpp;
                    grad_norm_sq += grad[r][c] * grad[r][c];
                    let updated = (states[k][r][c] - step_size * total_g).clamp(1e-6, 1.0);
                    states[k][r][c] = if step % 5 == 0 {
                        mcweeny_scalar_sharpen(updated).clamp(1e-6, 1.0)
                    } else {
                        updated
                    };
                }
            }
            if let Ok(proj) = sinkhorn_birkhoff_project(&states[k], 6) {
                states[k] = proj;
            }
            let board = round_matrix_to_board(&states[k]);
            if count_nqueens_conflicts(&board) == 0 || grad_norm_sq.sqrt() < grad_tol {
                halted[k] = true;
                halt_steps[k] = step;
            }
        }
        if all_halted {
            break;
        }
    }

    let mut valid_trajectories = 0usize;
    let mut distinct_solutions = BTreeSet::new();
    let mut distinct_orbits = BTreeSet::new();
    for state in &states {
        let board = round_matrix_to_board(state);
        if count_nqueens_conflicts(&board) == 0 {
            valid_trajectories += 1;
            distinct_solutions.insert(board.clone());
            if let Ok(orb) = d4_orbit_boards(&board) {
                distinct_orbits.insert(orb[0].clone());
            }
        }
    }

    let mean_steps = halt_steps.iter().sum::<usize>() as f64 / trajectories.max(1) as f64;
    let elapsed_ms = start.elapsed().as_secs_f64() * 1000.0;

    EbrBenchmarkReport {
        problem: format!("{size}-Queens"),
        seed,
        trajectories,
        max_steps,
        dpp_weight,
        valid_trajectories,
        pass_at_1: valid_trajectories as f64 / trajectories.max(1) as f64,
        distinct_valid_solutions: distinct_solutions.len(),
        distinct_d4_orbits: distinct_orbits.len(),
        exact_oracle_solutions: oracle_count,
        mean_halting_steps: mean_steps,
        wall_time_ms: elapsed_ms,
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn projector_idempotency_checks_exact_and_non_idempotent_matrices() {
        let proj = vec![vec![0.5, 0.5], vec![0.5, 0.5]];
        assert!(projector_idempotency_residual(&proj) < 1e-12);
        let non_proj = vec![vec![0.4, 0.2], vec![0.2, 0.4]];
        assert!(projector_idempotency_residual(&non_proj) > 0.1);
    }

    #[test]
    fn ebr_nqueens_benchmark_is_deterministic_and_reports_empirical_metrics() {
        let r1 = run_ebr_nqueens_benchmark(4, 10, 120, 0.15, 1e-4, 0.02, 42);
        let r2 = run_ebr_nqueens_benchmark(4, 10, 120, 0.15, 1e-4, 0.02, 42);
        assert_eq!(r1.valid_trajectories, r2.valid_trajectories);
        assert_eq!(r1.distinct_valid_solutions, r2.distinct_valid_solutions);
        assert_eq!(r1.exact_oracle_solutions, 2);
        assert!(r1.mean_halting_steps <= 120.0);
        assert!(r1.valid_trajectories >= 1, "4-Queens EBR should find at least one valid board");
    }
}
