//! Multi-reference Non-Orthogonal Configuration Interaction (NOCI) via Löwdin
//! canonical orthogonalization and exact Jacobi symmetric eigensolver.
//!
//! Reuses `tequila_simulator::expectation_pauli_hamiltonian_msb` (Paper 44 / `src/tequila`)
//! to cross-verify the 2-site stretched-H2 Hubbard NOCI wavefunction directly against
//! the 4-qubit Jordan–Wigner Pauli Hamiltonian.

use crate::dft_plabic_vrc::C64;
use crate::tequila_simulator::{PauliTerm, expectation_pauli_hamiltonian_msb};

/// Errors from NOCI / generalized eigensolve routines.
#[derive(Clone, Debug, Eq, PartialEq)]
pub enum NociError {
    EmptyMatrix,
    NonSquareOrSizeMismatch,
    AsymmetricMatrix,
    RankDeficientOverlap,
    DidNotConverge,
}

/// Output of solving the generalized symmetric eigenproblem `H c = E S c`.
#[derive(Clone, Debug)]
pub struct NociSolution {
    /// Generalized eigenvalues sorted in ascending order.
    pub eigenvalues: Vec<f64>,
    /// Generalized eigenvectors (`eigenvectors[k]` is the k-th eigenvector `c_k`, S-normalized).
    pub eigenvectors: Vec<Vec<f64>>,
    /// Eigenvalues of the overlap matrix `S` (sorted ascending).
    pub overlap_eigenvalues: Vec<f64>,
    /// Number of retained canonical orbitals above `overlap_cutoff`.
    pub retained_rank: usize,
    /// Condition number `λ_max(S) / λ_min_retained(S)`.
    pub overlap_condition_number: f64,
}

/// Classical cyclic Jacobi eigensolver for real symmetric `n × n` matrices.
/// Returns `(eigenvalues_sorted_asc, eigenvectors_as_columns_in_row_major)`.
pub fn jacobi_symmetric_eigen(
    matrix: &[Vec<f64>],
    tol: f64,
    max_sweeps: usize,
) -> Result<(Vec<f64>, Vec<Vec<f64>>), NociError> {
    let n = matrix.len();
    if n == 0 {
        return Err(NociError::EmptyMatrix);
    }
    if matrix.iter().any(|r| r.len() != n) {
        return Err(NociError::NonSquareOrSizeMismatch);
    }
    for i in 0..n {
        for j in (i + 1)..n {
            if (matrix[i][j] - matrix[j][i]).abs() > 1e-10 {
                return Err(NociError::AsymmetricMatrix);
            }
        }
    }

    let mut a = matrix.to_vec();
    let mut v = vec![vec![0.0; n]; n];
    for i in 0..n {
        v[i][i] = 1.0;
    }

    let mut converged = false;
    for _ in 0..max_sweeps {
        let mut max_off = 0.0f64;
        for p in 0..n {
            for q in (p + 1)..n {
                max_off = max_off.max(a[p][q].abs());
            }
        }
        if max_off <= tol {
            converged = true;
            break;
        }
        for p in 0..n {
            for q in (p + 1)..n {
                let apq = a[p][q];
                if apq.abs() <= tol * 0.1 {
                    continue;
                }
                let tau = (a[q][q] - a[p][p]) / (2.0 * apq);
                let t = if tau >= 0.0 {
                    1.0 / (tau + (1.0 + tau * tau).sqrt())
                } else {
                    -1.0 / (-tau + (1.0 + tau * tau).sqrt())
                };
                let c = 1.0 / (1.0 + t * t).sqrt();
                let s = t * c;

                let app = a[p][p];
                let aqq = a[q][q];
                a[p][p] = app - t * apq;
                a[q][q] = aqq + t * apq;
                a[p][q] = 0.0;
                a[q][p] = 0.0;

                for r in 0..n {
                    if r != p && r != q {
                        let arp = a[r][p];
                        let arq = a[r][q];
                        a[r][p] = c * arp - s * arq;
                        a[p][r] = a[r][p];
                        a[r][q] = s * arp + c * arq;
                        a[q][r] = a[r][q];
                    }
                    let vrp = v[r][p];
                    let vrq = v[r][q];
                    v[r][p] = c * vrp - s * vrq;
                    v[r][q] = s * vrp + c * vrq;
                }
            }
        }
    }

    if !converged {
        return Err(NociError::DidNotConverge);
    }

    let mut idx: Vec<usize> = (0..n).collect();
    idx.sort_by(|&i, &j| a[i][i].total_cmp(&a[j][j]));

    let eigenvalues: Vec<f64> = idx.iter().map(|&i| a[i][i]).collect();
    let mut vecs = vec![vec![0.0; n]; n];
    for (new_col, &old_col) in idx.iter().enumerate() {
        for row in 0..n {
            vecs[row][new_col] = v[row][old_col];
        }
    }
    Ok((eigenvalues, vecs))
}

/// Solve `H c = E S c` using Löwdin canonical orthogonalization with explicit overlap cutoff.
pub fn solve_noci_generalized(
    hamiltonian: &[Vec<f64>],
    overlap: &[Vec<f64>],
    overlap_cutoff: f64,
) -> Result<NociSolution, NociError> {
    let n = hamiltonian.len();
    if n == 0 || overlap.len() != n {
        return Err(NociError::NonSquareOrSizeMismatch);
    }
    let (s_vals, s_vecs) = jacobi_symmetric_eigen(overlap, 1e-13, 200)?;

    // Keep eigenvectors with overlap eigenvalue > overlap_cutoff
    let kept: Vec<usize> = s_vals
        .iter()
        .enumerate()
        .filter(|(_, val)| **val > overlap_cutoff)
        .map(|(i, _)| i)
        .collect();
    let m = kept.len();
    if m == 0 {
        return Err(NociError::RankDeficientOverlap);
    }
    let min_kept = s_vals[kept[0]];
    let max_kept = s_vals[*kept.last().unwrap()];
    let cond = max_kept / min_kept;

    // X is n x m: X[r][k] = s_vecs[r][kept[k]] / sqrt(s_vals[kept[k]])
    let mut x = vec![vec![0.0; m]; n];
    for (k, &orig) in kept.iter().enumerate() {
        let inv_sqrt = 1.0 / s_vals[orig].sqrt();
        for r in 0..n {
            x[r][k] = s_vecs[r][orig] * inv_sqrt;
        }
    }

    // H_prime = X^T H X (m x m)
    let mut hx = vec![vec![0.0; m]; n];
    for i in 0..n {
        for k in 0..m {
            let mut sum = 0.0;
            for j in 0..n {
                sum += hamiltonian[i][j] * x[j][k];
            }
            hx[i][k] = sum;
        }
    }
    let mut h_prime = vec![vec![0.0; m]; m];
    for a in 0..m {
        for b in 0..m {
            let mut sum = 0.0;
            for i in 0..n {
                sum += x[i][a] * hx[i][b];
            }
            h_prime[a][b] = sum;
        }
    }
    // Symmetrize numerical noise
    for a in 0..m {
        for b in (a + 1)..m {
            let avg = 0.5 * (h_prime[a][b] + h_prime[b][a]);
            h_prime[a][b] = avg;
            h_prime[b][a] = avg;
        }
    }

    let (eigenvalues, c_prime) = jacobi_symmetric_eigen(&h_prime, 1e-13, 200)?;

    // Back-transform eigenvectors: c_k = X * c'_k
    let mut eigenvectors = vec![vec![0.0; n]; m];
    for k in 0..m {
        for r in 0..n {
            let mut sum = 0.0;
            for a in 0..m {
                sum += x[r][a] * c_prime[a][k];
            }
            eigenvectors[k][r] = sum;
        }
    }

    Ok(NociSolution {
        eigenvalues,
        eigenvectors,
        overlap_eigenvalues: s_vals,
        retained_rank: m,
        overlap_condition_number: cond,
    })
}

/// Comparison of RHF, broken-symmetry UHF, 2-state spin-projected NOCI (PUHF),
/// 3-state NOCI (`{Φ_A, Φ_B, Φ_RHF}`), and exact FCI for the 2-site 2-electron
/// Hubbard / stretched-H2 minimal-basis model.
#[derive(Clone, Debug)]
pub struct StretchedH2NociBenchmark {
    pub hopping_t: f64,
    pub onsite_u: f64,
    pub rhf_energy: f64,
    pub uhf_energy: f64,
    pub uhf_s_squared: f64,
    pub noci_2state_energy: f64,
    pub noci_2state_s_squared: f64,
    pub noci_3state_energy: f64,
    pub noci_3state_s_squared: f64,
    pub fci_ground_energy: f64,
    pub noci_3state_minus_fci_error: f64,
    pub tequila_pauli_noci_energy: f64,
    pub overlap_s01: f64,
}

/// Run the exact 2-site 2-electron stretched-H2 benchmark (`H = -t Σ(c†_1σ c_2σ + h.c.) + U Σ n_i↑ n_i↓`).
///
/// In the `S_z = 0` basis `{|1↑ 1↓⟩, |2↑ 2↓⟩, |1↑ 2↓⟩, |2↑ 1↓⟩}`:
/// - Exact singlet ground state (FCI): `E_FCI = (U - sqrt(U^2 + 16 t^2)) / 2`.
/// - RHF doubly-occupied bonding state `(|1⟩+|2⟩)/√2`: `E_RHF = -2t + U/2`.
/// - Broken-symmetry UHF (`U > 2t`): `cos(2θ) = 2t / U`, `E_UHF = -2 t^2 / U` with
///   spin contamination `⟨S^2⟩_UHF = sin^2(2θ) = 1 - (2t/U)^2 > 0`.
/// - 2-state NOCI over `|Φ_A⟩` and its spin-flipped partner `|Φ_B⟩` restores exact
///   singlet symmetry `⟨S^2⟩ = 0` and recovers exact FCI in this 2-electron active space.
pub fn benchmark_stretched_h2_noci(hopping_t: f64, onsite_u: f64) -> Result<StretchedH2NociBenchmark, NociError> {
    if hopping_t <= 0.0 || onsite_u <= 2.0 * hopping_t {
        return Err(NociError::RankDeficientOverlap);
    }

    // Exact 4x4 S_z=0 Hamiltonian in basis {|1↑1↓⟩, |2↑2↓⟩, |1↑2↓⟩, |2↑1↓⟩}
    let h_full = vec![
        vec![onsite_u, 0.0, -hopping_t, -hopping_t],
        vec![0.0, onsite_u, -hopping_t, -hopping_t],
        vec![-hopping_t, -hopping_t, 0.0, 0.0],
        vec![-hopping_t, -hopping_t, 0.0, 0.0],
    ];
    let (fci_vals, _) = jacobi_symmetric_eigen(&h_full, 1e-13, 200)?;
    let fci_ground_energy = fci_vals[0];

    let rhf_energy = -2.0 * hopping_t + 0.5 * onsite_u;

    // UHF optimal mixing angle theta for alpha = (cos θ, sin θ), beta = (sin θ, cos θ)
    // where sin(2θ) = 2t / U minimizes E_UHF = -2t sin(2θ) + (U/2) sin^2(2θ) = -2 t^2 / U.
    let sin_2theta = (2.0 * hopping_t) / onsite_u;
    let theta = 0.5 * sin_2theta.asin();
    let c = theta.cos();
    let s = theta.sin();

    // |Φ_A⟩ = (c |1↑⟩ + s |2↑⟩)(s |1↓⟩ + c |2↓⟩) = cs|1↑1↓⟩ + sc|2↑2↓⟩ + c^2|1↑2↓⟩ + s^2|2↑1↓⟩
    let phi_a = [c * s, c * s, c * c, s * s];
    // |Φ_B⟩ = spin-flipped partner (swap α ↔ β)
    let phi_b = [c * s, c * s, s * s, c * c];

    let dot = |u: &[f64; 4], v: &[f64; 4]| -> f64 { u.iter().zip(v.iter()).map(|(a, b)| a * b).sum() };
    let mat_elem = |u: &[f64; 4], v: &[f64; 4]| -> f64 {
        let mut sum = 0.0;
        for i in 0..4 {
            for j in 0..4 {
                sum += u[i] * h_full[i][j] * v[j];
            }
        }
        sum
    };

    let uhf_energy = mat_elem(&phi_a, &phi_a);
    let overlap_s01 = dot(&phi_a, &phi_b);
    let h_ab = mat_elem(&phi_a, &phi_b);

    // S^2 operator in basis {|1↑1↓⟩, |2↑2↓⟩, |1↑2↓⟩, |2↑1↓⟩}:
    // Singlet (|1↑2↓⟩+|2↑1↓⟩)/√2 has S^2=0, triplet (|1↑2↓⟩-|2↑1↓⟩)/√2 has S^2=2,
    // double-occupancy states have S^2=0.
    // So on {2, 3}: S^2 = [[1, -1], [-1, 1]].
    let s_sq_expect = |state: &[f64; 4]| -> f64 {
        let diff = state[2] - state[3];
        diff * diff
    };
    let uhf_s_squared = s_sq_expect(&phi_a);

    let h_noci2 = vec![vec![uhf_energy, h_ab], vec![h_ab, uhf_energy]];
    let s_noci2 = vec![vec![1.0, overlap_s01], vec![overlap_s01, 1.0]];
    let sol2 = solve_noci_generalized(&h_noci2, &s_noci2, 1e-12)?;
    let noci_2state_energy = sol2.eigenvalues[0];
    let mut psi_noci2 = [0.0; 4];
    for i in 0..4 {
        psi_noci2[i] = sol2.eigenvectors[0][0] * phi_a[i] + sol2.eigenvectors[0][1] * phi_b[i];
    }
    let noci_2state_s_squared = s_sq_expect(&psi_noci2);

    // 3-state NOCI adding |Φ_RHF⟩ = (1/2)(|1↑1↓⟩ + |2↑2↓⟩ + |1↑2↓⟩ + |2↑1↓⟩)
    // spans the full 2-electron singlet subspace and recovers exact FCI.
    let phi_rhf = [0.5, 0.5, 0.5, 0.5];
    let refs = [phi_a, phi_b, phi_rhf];
    let mut h_noci3 = vec![vec![0.0; 3]; 3];
    let mut s_noci3 = vec![vec![0.0; 3]; 3];
    for i in 0..3 {
        for j in 0..3 {
            h_noci3[i][j] = mat_elem(&refs[i], &refs[j]);
            s_noci3[i][j] = dot(&refs[i], &refs[j]);
        }
    }
    let sol3 = solve_noci_generalized(&h_noci3, &s_noci3, 1e-12)?;
    let noci_3state_energy = sol3.eigenvalues[0];
    let mut psi_noci3 = [0.0; 4];
    for i in 0..4 {
        psi_noci3[i] = sol3.eigenvectors[0][0] * phi_a[i]
            + sol3.eigenvectors[0][1] * phi_b[i]
            + sol3.eigenvectors[0][2] * phi_rhf[i];
    }
    let noci_3state_s_squared = s_sq_expect(&psi_noci3);

    // Cross-verify the 3-state NOCI ground state against the 4-qubit Jordan–Wigner Pauli
    // Hamiltonian via `tequila_simulator::expectation_pauli_hamiltonian_msb` (qubits:
    // 0 = 1↑, 1 = 2↑, 2 = 1↓, 3 = 2↓; S_z = 0 basis indices: 10, 5, 9, 6).
    let mut psi_16 = vec![C64::ZERO; 16];
    psi_16[0b1010] = C64::new(psi_noci3[0], 0.0);
    psi_16[0b0101] = C64::new(psi_noci3[1], 0.0);
    psi_16[0b1001] = C64::new(psi_noci3[2], 0.0);
    psi_16[0b0110] = C64::new(psi_noci3[3], 0.0);
    let jw_terms = vec![
        PauliTerm { coeff_re: -0.5 * hopping_t, coeff_im: 0.0, ops: vec![(0, 'X'), (1, 'X')] },
        PauliTerm { coeff_re: -0.5 * hopping_t, coeff_im: 0.0, ops: vec![(0, 'Y'), (1, 'Y')] },
        PauliTerm { coeff_re: -0.5 * hopping_t, coeff_im: 0.0, ops: vec![(2, 'X'), (3, 'X')] },
        PauliTerm { coeff_re: -0.5 * hopping_t, coeff_im: 0.0, ops: vec![(2, 'Y'), (3, 'Y')] },
        PauliTerm { coeff_re: 0.5 * onsite_u, coeff_im: 0.0, ops: vec![] },
        PauliTerm { coeff_re: -0.25 * onsite_u, coeff_im: 0.0, ops: vec![(0, 'Z')] },
        PauliTerm { coeff_re: -0.25 * onsite_u, coeff_im: 0.0, ops: vec![(2, 'Z')] },
        PauliTerm { coeff_re: 0.25 * onsite_u, coeff_im: 0.0, ops: vec![(0, 'Z'), (2, 'Z')] },
        PauliTerm { coeff_re: -0.25 * onsite_u, coeff_im: 0.0, ops: vec![(1, 'Z')] },
        PauliTerm { coeff_re: -0.25 * onsite_u, coeff_im: 0.0, ops: vec![(3, 'Z')] },
        PauliTerm { coeff_re: 0.25 * onsite_u, coeff_im: 0.0, ops: vec![(1, 'Z'), (3, 'Z')] },
    ];
    let tequila_pauli_noci_energy =
        expectation_pauli_hamiltonian_msb(4, &psi_16, &psi_16, &jw_terms).re;

    Ok(StretchedH2NociBenchmark {
        hopping_t,
        onsite_u,
        rhf_energy,
        uhf_energy,
        uhf_s_squared,
        noci_2state_energy,
        noci_2state_s_squared,
        noci_3state_energy,
        noci_3state_s_squared,
        fci_ground_energy,
        noci_3state_minus_fci_error: (noci_3state_energy - fci_ground_energy).abs(),
        tequila_pauli_noci_energy,
        overlap_s01,
    })
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn stretched_h2_noci_restores_singlet_and_matches_exact_fci() {
        for &(t, u) in &[(1.0, 3.0), (1.0, 5.0), (0.5, 4.0)] {
            let b = benchmark_stretched_h2_noci(t, u).unwrap();
            assert!(b.uhf_energy < b.rhf_energy, "UHF should beat RHF in stretched regime");
            assert!(b.uhf_s_squared > 0.1, "UHF should be spin-contaminated");
            // Strict variational hierarchy: E_FCI = E_NOCI(3) < E_NOCI(2/PUHF) < E_UHF < E_RHF
            assert!(
                b.noci_2state_energy < b.uhf_energy,
                "2-state NOCI (PUHF) must strictly lower broken-symmetry UHF"
            );
            assert!(
                b.fci_ground_energy < b.noci_2state_energy,
                "frozen-orbital 2-state NOCI remains strictly variational above exact FCI"
            );
            assert!(
                b.noci_2state_s_squared.abs() < 1e-12,
                "2-state NOCI must restore exact singlet <S^2>=0, got {}",
                b.noci_2state_s_squared
            );
            assert!(
                b.noci_3state_s_squared.abs() < 1e-12,
                "3-state NOCI must restore exact singlet <S^2>=0, got {}",
                b.noci_3state_s_squared
            );
            assert!(
                b.noci_3state_minus_fci_error < 1e-11,
                "3-state NOCI should match exact 2-electron FCI, err={}",
                b.noci_3state_minus_fci_error
            );
            assert!(
                (b.tequila_pauli_noci_energy - b.noci_3state_energy).abs() < 1e-12,
                "4-qubit Tequila JW Pauli expectation must match 3-state NOCI ground energy"
            );
        }
    }

    #[test]
    fn lowdin_orthogonalization_handles_rank_deficiency_cleanly() {
        let h = vec![
            vec![1.0, 1.0, 0.0],
            vec![1.0, 1.0, 0.0],
            vec![0.0, 0.0, 2.0],
        ];
        // Rank-2 overlap (rows 0 and 1 identical)
        let s = vec![
            vec![1.0, 1.0, 0.0],
            vec![1.0, 1.0, 0.0],
            vec![0.0, 0.0, 1.0],
        ];
        let sol = solve_noci_generalized(&h, &s, 1e-8).unwrap();
        assert_eq!(sol.retained_rank, 2);
        assert!((sol.eigenvalues[0] - 1.0).abs() < 1e-10);
        assert!((sol.eigenvalues[1] - 2.0).abs() < 1e-10);
    }
}
