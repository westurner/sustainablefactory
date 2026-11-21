//! PSD-verified regularized Slavnov–Gram Determinantal Point Process (DPP) utilities.
//!
//! Computes exact Cholesky factorizations, log-determinants, matrix inverses, and
//! analytical gradients for `G_ε = Xᵀ X + ε I_K`, plus deterministic seeded diversity
//! selection trials benchmarked against the exact constraint oracles in
//! `finite_constraint_solvers`.
//!
//! No universal `100% Cov@K` theorem is asserted; empirical coverage is reported with
//! explicit seeds and oracle counts.

use crate::finite_constraint_solvers::{
    d4_orbit_boards, enumerate_graph_colorings, enumerate_nqueens_solutions,
};

/// Errors returned by PSD Gram / Cholesky DPP routines.
#[derive(Clone, Debug, Eq, PartialEq)]
pub enum DppError {
    EmptyFeatures,
    RaggedFeatures,
    InvalidRegularization,
    NotPositiveDefinite,
    InvalidSelectionCount,
}

/// Output of evaluating `log det(Xᵀ X + ε I_K)` and its gradient w.r.t. `X`.
#[derive(Clone, Debug)]
pub struct GramDppEvaluation {
    /// Regularized `K × K` Gram matrix `G_ε = Xᵀ X + ε I_K`.
    pub gram: Vec<Vec<f64>>,
    /// Exact `log det(G_ε)` via Cholesky (`2 * Σ ln L_ii`).
    pub log_det: f64,
    /// Exact inverse `G_ε⁻¹`.
    pub inverse: Vec<Vec<f64>>,
    /// Analytical gradient `∂ log det(Xᵀ X + ε I_K) / ∂ X = 2 X G_ε⁻¹` (shape `K × D`, row-major per item).
    pub grad_features: Vec<Vec<f64>>,
    /// Ratio `(max L_ii / min L_ii)^2` as a lower-bound condition indicator.
    pub cholesky_diag_ratio_sq: f64,
}

/// Compute symmetric `K × K` regularized Gram matrix `G_ε = Xᵀ X + ε I_K`
/// where `features` has `K` rows of dimension `D`.
pub fn build_regularized_gram(features: &[Vec<f64>], eps: f64) -> Result<Vec<Vec<f64>>, DppError> {
    if features.is_empty() {
        return Err(DppError::EmptyFeatures);
    }
    let dim = features[0].len();
    if dim == 0 || features.iter().any(|row| row.len() != dim) {
        return Err(DppError::RaggedFeatures);
    }
    if !eps.is_finite() || eps < 0.0 {
        return Err(DppError::InvalidRegularization);
    }
    let k = features.len();
    let mut gram = vec![vec![0.0; k]; k];
    for i in 0..k {
        for j in i..k {
            let dot: f64 = features[i]
                .iter()
                .zip(features[j].iter())
                .map(|(a, b)| a * b)
                .sum();
            let val = if i == j { dot + eps } else { dot };
            gram[i][j] = val;
            gram[j][i] = val;
        }
    }
    Ok(gram)
}

/// Lower-triangular Cholesky factorization `G = L Lᵀ`.
pub fn cholesky_lower(gram: &[Vec<f64>]) -> Result<Vec<Vec<f64>>, DppError> {
    let k = gram.len();
    if k == 0 || gram.iter().any(|row| row.len() != k) {
        return Err(DppError::RaggedFeatures);
    }
    let mut l = vec![vec![0.0; k]; k];
    for i in 0..k {
        for j in 0..=i {
            let mut sum = gram[i][j];
            for m in 0..j {
                sum -= l[i][m] * l[j][m];
            }
            if i == j {
                if !(sum > 0.0) || !sum.is_finite() {
                    return Err(DppError::NotPositiveDefinite);
                }
                l[i][j] = sum.sqrt();
            } else {
                l[i][j] = sum / l[j][j];
            }
        }
    }
    Ok(l)
}

fn solve_cholesky_rhs(l: &[Vec<f64>], rhs: &[f64]) -> Vec<f64> {
    let k = l.len();
    let mut y = vec![0.0; k];
    for i in 0..k {
        let mut s = rhs[i];
        for j in 0..i {
            s -= l[i][j] * y[j];
        }
        y[i] = s / l[i][i];
    }
    let mut x = vec![0.0; k];
    for i in (0..k).rev() {
        let mut s = y[i];
        for j in (i + 1)..k {
            s -= l[j][i] * x[j];
        }
        x[i] = s / l[i][i];
    }
    x
}

/// Evaluate exact Cholesky `log det(Xᵀ X + ε I_K)`, `G_ε⁻¹`, and analytical gradient `2 X G_ε⁻¹`.
pub fn evaluate_gram_dpp(features: &[Vec<f64>], eps: f64) -> Result<GramDppEvaluation, DppError> {
    let gram = build_regularized_gram(features, eps)?;
    let l = cholesky_lower(&gram)?;
    let k = gram.len();
    let dim = features[0].len();

    let mut log_det = 0.0;
    let mut min_d = f64::INFINITY;
    let mut max_d = 0.0f64;
    for i in 0..k {
        let d = l[i][i];
        log_det += 2.0 * d.ln();
        min_d = min_d.min(d);
        max_d = max_d.max(d);
    }

    let mut inverse = vec![vec![0.0; k]; k];
    for col in 0..k {
        let mut e = vec![0.0; k];
        e[col] = 1.0;
        let inv_col = solve_cholesky_rhs(&l, &e);
        for row in 0..k {
            inverse[row][col] = inv_col[row];
        }
    }

    // grad_features[i][d] = 2 * sum_j inverse[i][j] * features[j][d]
    let mut grad_features = vec![vec![0.0; dim]; k];
    for i in 0..k {
        for j in 0..k {
            let factor = 2.0 * inverse[i][j];
            for d in 0..dim {
                grad_features[i][d] += factor * features[j][d];
            }
        }
    }

    Ok(GramDppEvaluation {
        gram,
        log_det,
        inverse,
        grad_features,
        cholesky_diag_ratio_sq: (max_d / min_d).powi(2),
    })
}

/// Greedy MAP DPP subset selection maximizing `log det(L_S + ε I)` over `select_k` items.
pub fn greedy_dpp_select(
    features: &[Vec<f64>],
    select_k: usize,
    eps: f64,
) -> Result<(Vec<usize>, f64), DppError> {
    if features.is_empty() {
        return Err(DppError::EmptyFeatures);
    }
    if select_k == 0 || select_k > features.len() {
        return Err(DppError::InvalidSelectionCount);
    }
    let mut chosen: Vec<usize> = Vec::with_capacity(select_k);
    let mut used = vec![false; features.len()];
    let mut best_log_det = f64::NEG_INFINITY;

    for _ in 0..select_k {
        let mut best_idx = None;
        let mut step_best = f64::NEG_INFINITY;
        for idx in 0..features.len() {
            if used[idx] {
                continue;
            }
            let mut trial: Vec<Vec<f64>> = chosen.iter().map(|&c| features[c].clone()).collect();
            trial.push(features[idx].clone());
            let eval = evaluate_gram_dpp(&trial, eps)?;
            if eval.log_det > step_best {
                step_best = eval.log_det;
                best_idx = Some(idx);
            }
        }
        let picked = best_idx.ok_or(DppError::InvalidSelectionCount)?;
        used[picked] = true;
        chosen.push(picked);
        best_log_det = step_best;
    }

    Ok((chosen, best_log_det))
}

/// Empirical coverage summary comparing greedy Gram-DPP selection against an exact finite oracle.
#[derive(Clone, Debug)]
pub struct OracleDppCoverageReport {
    pub problem: String,
    pub total_exact_solutions: usize,
    pub requested_k: usize,
    pub selected_distinct_solutions: usize,
    pub selected_distinct_d4_orbits: usize,
    pub final_log_det: f64,
}

/// Embed an N-Queens board into a normalized `N × N` binary feature vector and select `k`
/// maximally diverse boards from the exact oracle via greedy Gram-DPP.
///
/// Note: Because symmetry-equivalent boards in the same `D_4` orbit can be mutually
/// orthogonal in `ℝ^(N²)`, raw-board Gram-DPP maximizes coordinate orthogonality and
/// does not guarantee distinct `D_4` orbits without explicit orbifold quotienting.
pub fn nqueens_oracle_dpp_coverage(
    size: usize,
    select_k: usize,
    eps: f64,
) -> Result<OracleDppCoverageReport, DppError> {
    let solutions = enumerate_nqueens_solutions(size).map_err(|_| DppError::EmptyFeatures)?;
    let inv_norm = 1.0 / (size as f64).sqrt();
    let features: Vec<Vec<f64>> = solutions
        .iter()
        .map(|board| {
            let mut vec = vec![0.0; size * size];
            for (r, &c) in board.iter().enumerate() {
                vec[r * size + c] = inv_norm;
            }
            vec
        })
        .collect();
    let (chosen, log_det) = greedy_dpp_select(&features, select_k, eps)?;
    let mut distinct = std::collections::BTreeSet::new();
    let mut orbits = std::collections::BTreeSet::new();
    for idx in chosen {
        distinct.insert(solutions[idx].clone());
        if let Ok(orb) = d4_orbit_boards(&solutions[idx]) {
            orbits.insert(orb[0].clone());
        }
    }
    Ok(OracleDppCoverageReport {
        problem: format!("{size}-Queens (raw)"),
        total_exact_solutions: solutions.len(),
        requested_k: select_k,
        selected_distinct_solutions: distinct.len(),
        selected_distinct_d4_orbits: orbits.len(),
        final_log_det: log_det,
    })
}

/// Quotient the exact N-Queens oracle by `D_4` first, then run greedy Gram-DPP on the
/// canonical fundamental-domain representatives.
pub fn nqueens_orbifold_dpp_coverage(
    size: usize,
    select_k: usize,
    eps: f64,
) -> Result<OracleDppCoverageReport, DppError> {
    let solutions = enumerate_nqueens_solutions(size).map_err(|_| DppError::EmptyFeatures)?;
    let mut reps_set = std::collections::BTreeSet::new();
    for sol in &solutions {
        if let Ok(orb) = d4_orbit_boards(sol) {
            reps_set.insert(orb[0].clone());
        }
    }
    let reps: Vec<Vec<usize>> = reps_set.into_iter().collect();
    let inv_norm = 1.0 / (size as f64).sqrt();
    let features: Vec<Vec<f64>> = reps
        .iter()
        .map(|board| {
            let mut vec = vec![0.0; size * size];
            for (r, &c) in board.iter().enumerate() {
                vec[r * size + c] = inv_norm;
            }
            vec
        })
        .collect();
    let (chosen, log_det) = greedy_dpp_select(&features, select_k, eps)?;
    let distinct: std::collections::BTreeSet<_> =
        chosen.iter().map(|&idx| reps[idx].clone()).collect();
    Ok(OracleDppCoverageReport {
        problem: format!("{size}-Queens (D4-orbifold)"),
        total_exact_solutions: reps.len(),
        requested_k: select_k,
        selected_distinct_solutions: distinct.len(),
        selected_distinct_d4_orbits: distinct.len(),
        final_log_det: log_det,
    })
}

/// Empirical Gram-DPP diversity report over exact 3-colorings of the 10-vertex Petersen graph.
pub fn petersen_coloring_oracle_dpp_coverage(
    pool_limit: usize,
    select_k: usize,
    eps: f64,
) -> Result<OracleDppCoverageReport, DppError> {
    let edges: Vec<(usize, usize)> = vec![
        (0, 1), (1, 2), (2, 3), (3, 4), (4, 0),
        (5, 7), (7, 9), (9, 6), (6, 8), (8, 5),
        (0, 5), (1, 6), (2, 7), (3, 8), (4, 9),
    ];
    let colorings = enumerate_graph_colorings(10, 3, &edges, pool_limit)
        .map_err(|_| DppError::EmptyFeatures)?;
    let inv_norm = 1.0 / (10.0f64).sqrt();
    let features: Vec<Vec<f64>> = colorings
        .iter()
        .map(|col| {
            let mut v = vec![0.0; 30];
            for (vertex, &c) in col.iter().enumerate() {
                v[vertex * 3 + c] = inv_norm;
            }
            v
        })
        .collect();
    let (chosen, log_det) = greedy_dpp_select(&features, select_k, eps)?;
    let distinct: std::collections::BTreeSet<_> =
        chosen.iter().map(|&idx| colorings[idx].clone()).collect();
    Ok(OracleDppCoverageReport {
        problem: "Petersen-10v-3Color".to_string(),
        total_exact_solutions: colorings.len(),
        requested_k: select_k,
        selected_distinct_solutions: distinct.len(),
        selected_distinct_d4_orbits: distinct.len(),
        final_log_det: log_det,
    })
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn analytical_gradient_matches_central_finite_differences() {
        let features = vec![
            vec![0.8, 0.3, -0.5, 0.2],
            vec![-0.4, 0.9, 0.1, 0.7],
            vec![0.2, -0.6, 0.7, 0.5],
        ];
        let eps = 0.05;
        let eval = evaluate_gram_dpp(&features, eps).unwrap();

        // Verify G * G^-1 == I
        for i in 0..3 {
            for j in 0..3 {
                let prod: f64 = (0..3).map(|m| eval.gram[i][m] * eval.inverse[m][j]).sum();
                let target = if i == j { 1.0 } else { 0.0 };
                assert!((prod - target).abs() < 1e-12);
            }
        }

        // Central finite differences on every feature entry
        let h = 1e-6;
        for i in 0..3 {
            for d in 0..4 {
                let mut plus = features.clone();
                let mut minus = features.clone();
                plus[i][d] += h;
                minus[i][d] -= h;
                let fd = (evaluate_gram_dpp(&plus, eps).unwrap().log_det
                    - evaluate_gram_dpp(&minus, eps).unwrap().log_det)
                    / (2.0 * h);
                assert!(
                    (fd - eval.grad_features[i][d]).abs() < 1e-7,
                    "grad mismatch at ({i},{d}): fd={fd}, exact={}",
                    eval.grad_features[i][d]
                );
            }
        }
    }

    #[test]
    fn duplicate_features_fail_unregularized_cholesky_and_succeed_with_eps() {
        let dup = vec![vec![1.0, 2.0, -1.0], vec![1.0, 2.0, -1.0]];
        assert_eq!(evaluate_gram_dpp(&dup, 0.0).unwrap_err(), DppError::NotPositiveDefinite);
        let reg = evaluate_gram_dpp(&dup, 1e-3).unwrap();
        assert!(reg.log_det.is_finite());
        assert!(reg.cholesky_diag_ratio_sq > 1.0);
    }

    #[test]
    fn nqueens_and_petersen_oracle_dpp_coverage_trials() {
        let q8_raw = nqueens_oracle_dpp_coverage(8, 12, 1e-4).unwrap();
        assert_eq!(q8_raw.total_exact_solutions, 92);
        assert_eq!(q8_raw.selected_distinct_solutions, 12);
        // Raw coordinate DPP selects orthogonal symmetry copies across fewer than 12 D4 orbits.
        assert!(q8_raw.selected_distinct_d4_orbits < 12);

        let q8_orb = nqueens_orbifold_dpp_coverage(8, 12, 1e-4).unwrap();
        assert_eq!(q8_orb.total_exact_solutions, 12);
        assert_eq!(q8_orb.selected_distinct_d4_orbits, 12);

        let pet = petersen_coloring_oracle_dpp_coverage(40, 10, 1e-4).unwrap();
        assert_eq!(pet.total_exact_solutions, 40);
        assert_eq!(pet.selected_distinct_solutions, 10);
    }
}
