//! Rust + PyO3 (`maturin`) Quantum Simulation Backend for Tequila (`tequilahub/tequila`),
//! integrating Complex Grassmannians $\mathrm{Gr}_{\mathbb{C}}(k, n)$, Layer-Coded Plabic
//! Vector-Relation Configurations (`VRC`), Madelung / DDF / Turner Plücker $\mathcal{Q}_4$
//! Hydrodynamics, Quantum Causal Inference (`QCI`), Jeffrey's Probability Kinematics,
//! and McWeeny Cubic Idempotency Purification.

use crate::dft_plabic_vrc::{
    C64, ComplexPlabicVrc2x4, Plucker2x4, mermin_three_qudit_ghz_witness,
    two_orbital_linear_correlation_entropy,
};
use crate::quantum_causal_inference::quantum_jeffrey_plucker_kinematic_update;

#[cfg(feature = "python")]
use crate::dft_plabic_vrc::{
    cayley_retraction_eigenvalue_norm_sq, mcweeny_purification_poly,
};
#[cfg(feature = "python")]
use crate::quantum_causal_inference::{
    cev_causal_do_expected_utility, diaconis_zabell_log_odds_update,
    jev_evidential_expected_utility,
};
#[cfg(feature = "python")]
use pyo3::prelude::*;
#[cfg(feature = "python")]
use pyo3::types::{PyDict, PyList};

/// Supported elementary and parametrized gate instructions for the Tequila Rust simulator.
#[derive(Clone, Debug, PartialEq)]
pub enum TequilaGateOp {
    /// Single-qubit Pauli X, Y, Z, or Hadamard H with optional control qubits.
    Basic {
        name: String,
        targets: Vec<usize>,
        controls: Vec<usize>,
    },
    /// Two-qubit SWAP gate with optional controls.
    Swap {
        q0: usize,
        q1: usize,
        controls: Vec<usize>,
    },
    /// Single-qubit rotation Rx(angle), Ry(angle), Rz(angle), or Phase(angle) with optional controls.
    /// Convention matches Tequila: `exp(-i * angle / 2 * P)` for Rx/Ry/Rz and `diag(1, exp(i * angle))` for Phase.
    Rotation {
        axis: String,
        angle: f64,
        targets: Vec<usize>,
        controls: Vec<usize>,
    },
    /// Exponential Pauli gate `exp(-i * angle / 2 * P)` where `paulis` is a list of `(qubit, 'X'|'Y'|'Z')`.
    ExpPauli {
        paulis: Vec<(usize, char)>,
        angle: f64,
        controls: Vec<usize>,
    },
    /// Pearl causal `do(qubit = bit_value)` intervention projecting and renormalizing target qubit.
    CausalDo {
        qubit: usize,
        bit_value: u8,
    },
}

/// One weighted Pauli string term `coeff * P` in a Tequila `QubitHamiltonian`.
#[derive(Clone, Debug, PartialEq)]
pub struct PauliTerm {
    pub coeff_re: f64,
    pub coeff_im: f64,
    pub ops: Vec<(usize, char)>,
}

/// Diagnostic summary of Grassmannian Plücker, VRC, Madelung/Bohm, and QCI invariants
/// extracted from a simulated Tequila quantum state.
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct TequilaGrassmannDiagnostics {
    pub kahler_det_factor: f64,
    pub plucker_relation_residual: f64,
    pub vrc_orthogonality_residual: f64,
    pub one_rdm_linear_entropy: f64,
    pub qci_spin_mutual_info: f64,
    pub madelung_bohm_regularized_trace: f64,
    pub jeffrey_posterior_prob: f64,
    pub mermin_ghz_witness: f64,
}

#[inline]
fn bit_at_msb(basis_index: usize, qubit: usize, n_qubits: usize) -> usize {
    (basis_index >> (n_qubits - 1 - qubit)) & 1
}

#[inline(always)]
fn controls_mask_msb(controls: &[usize], n_qubits: usize) -> usize {
    let mut mask = 0usize;
    for &c in controls {
        let shift = n_qubits.saturating_sub(1 + c);
        if shift < 64 {
            mask |= 1usize << shift;
        }
    }
    mask
}

#[inline(always)]
pub fn controls_mask_msb_128(controls: &[usize], n_qubits: usize) -> u128 {
    let mut mask = 0u128;
    for &c in controls {
        let shift = n_qubits.saturating_sub(1 + c);
        if shift < 128 {
            mask |= 1u128 << shift;
        }
    }
    mask
}

/// Precompiled bitwise representation of an $n$-qubit Pauli string $P = \bigotimes_q \sigma_q$.
/// Evaluates $P|x\rangle = \pm i^{N_Y} |x \oplus \mathrm{xy\_mask}\rangle$ in 3 bitwise instructions (`XOR`, `AND`, `POPCNT`).
/// Includes both 64-bit (`usize`) masks for dense butterfly kernels ($n \le 28$) and 128-bit (`u128`)
/// masks for sparse Plücker subspace execution up to $n = 126$ qubits!
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct CompiledPauliString {
    pub xy_mask: usize,
    pub z_mask: usize,
    pub xy_mask_128: u128,
    pub z_mask_128: u128,
    pub y_phase: C64,
}

impl CompiledPauliString {
    pub fn from_ops(ops: &[(usize, char)], n_qubits: usize) -> Self {
        let mut xy_mask = 0usize;
        let mut z_mask = 0usize;
        let mut xy_mask_128 = 0u128;
        let mut z_mask_128 = 0u128;
        let mut y_count = 0usize;
        for &(q, op) in ops {
            let shift = n_qubits.saturating_sub(1 + q);
            let bit = if shift < 64 { 1usize << shift } else { 0usize };
            let bit128 = if shift < 128 { 1u128 << shift } else { 0u128 };
            match op {
                'X' | 'x' => {
                    xy_mask ^= bit;
                    xy_mask_128 ^= bit128;
                }
                'Y' | 'y' => {
                    xy_mask ^= bit;
                    z_mask ^= bit;
                    xy_mask_128 ^= bit128;
                    z_mask_128 ^= bit128;
                    y_count += 1;
                }
                'Z' | 'z' => {
                    z_mask ^= bit;
                    z_mask_128 ^= bit128;
                }
                _ => {}
            }
        }
        let y_phase = match y_count & 3 {
            0 => C64::ONE,
            1 => C64::new(0.0, 1.0),
            2 => C64::new(-1.0, 0.0),
            _ => C64::new(0.0, -1.0),
        };
        Self {
            xy_mask,
            z_mask,
            xy_mask_128,
            z_mask_128,
            y_phase,
        }
    }

    #[inline(always)]
    pub fn apply_to_basis(&self, idx: usize) -> (usize, C64) {
        let partner = idx ^ self.xy_mask;
        let neg = ((idx & self.z_mask).count_ones() & 1) != 0;
        let phase = if neg { -self.y_phase } else { self.y_phase };
        (partner, phase)
    }
}

/// Applies a single 2x2 unitary `[[u00, u01], [u10, u11]]` to `target` conditioned on `controls` (MSB ordering)
/// using a branchless Cooley–Tukey butterfly stride loop when uncontrolled, a single-instruction bitmask check when controlled,
/// and multi-threaded Rayon parallelization for $n \ge 15$.
#[inline]
pub fn apply_single_qubit_unitary_msb(
    state: &mut [C64],
    n_qubits: usize,
    target: usize,
    controls: &[usize],
    u00: C64,
    u01: C64,
    u10: C64,
    u11: C64,
) {
    let ctrl_mask = controls_mask_msb(controls, n_qubits);
    apply_single_qubit_unitary_mask_msb(state, n_qubits, target, ctrl_mask, u00, u01, u10, u11);
}

#[inline]
pub fn apply_single_qubit_unitary_mask_msb(
    state: &mut [C64],
    n_qubits: usize,
    target: usize,
    ctrl_mask: usize,
    u00: C64,
    u01: C64,
    u10: C64,
    u11: C64,
) {
    let dim = 1usize << n_qubits;
    let step = 1usize << (n_qubits - 1 - target);
    let block = step << 1;

    #[cfg(feature = "python")]
    if n_qubits >= 15 {
        use rayon::prelude::*;
        let chunk_size = block.max(8192);
        if ctrl_mask == 0 {
            if block <= (dim >> 4) {
                state.par_chunks_mut(chunk_size).for_each(|chunk| {
                    for sub_base in (0..chunk.len()).step_by(block) {
                        for idx0 in sub_base..(sub_base + step) {
                            let idx1 = idx0 + step;
                            let a0 = chunk[idx0];
                            let a1 = chunk[idx1];
                            chunk[idx0] = u00 * a0 + u01 * a1;
                            chunk[idx1] = u10 * a0 + u11 * a1;
                        }
                    }
                });
            } else {
                for block_slice in state.chunks_mut(block) {
                    let (lo, hi) = block_slice.split_at_mut(step);
                    lo.par_chunks_mut(8192)
                        .zip(hi.par_chunks_mut(8192))
                        .for_each(|(c0, c1)| {
                            for (a0_ref, a1_ref) in c0.iter_mut().zip(c1.iter_mut()) {
                                let a0 = *a0_ref;
                                let a1 = *a1_ref;
                                *a0_ref = u00 * a0 + u01 * a1;
                                *a1_ref = u10 * a0 + u11 * a1;
                            }
                        });
                }
            }
        } else if block <= (dim >> 4) {
            state
                .par_chunks_mut(chunk_size)
                .enumerate()
                .for_each(|(chk_i, chunk)| {
                    let chunk_base = chk_i * chunk_size;
                    for sub_base in (0..chunk.len()).step_by(block) {
                        let base = chunk_base + sub_base;
                        if (base & ctrl_mask & !(block - 1)) != (ctrl_mask & !(block - 1)) {
                            continue;
                        }
                        for k in 0..step {
                            if ((base + k) & ctrl_mask) == ctrl_mask {
                                let idx0 = sub_base + k;
                                let idx1 = idx0 + step;
                                let a0 = chunk[idx0];
                                let a1 = chunk[idx1];
                                chunk[idx0] = u00 * a0 + u01 * a1;
                                chunk[idx1] = u10 * a0 + u11 * a1;
                            }
                        }
                    }
                });
        } else {
            for (blk_i, block_slice) in state.chunks_mut(block).enumerate() {
                let base = blk_i * block;
                if (base & ctrl_mask & !(block - 1)) != (ctrl_mask & !(block - 1)) {
                    continue;
                }
                let (lo, hi) = block_slice.split_at_mut(step);
                lo.par_chunks_mut(8192)
                    .zip(hi.par_chunks_mut(8192))
                    .enumerate()
                    .for_each(|(sub_i, (c0, c1))| {
                        let sub_base = base + sub_i * 8192;
                        for k in 0..c0.len() {
                            if ((sub_base + k) & ctrl_mask) == ctrl_mask {
                                let a0 = c0[k];
                                let a1 = c1[k];
                                c0[k] = u00 * a0 + u01 * a1;
                                c1[k] = u10 * a0 + u11 * a1;
                            }
                        }
                    });
            }
        }
        return;
    }

    if ctrl_mask == 0 {
        for base in (0..dim).step_by(block) {
            for idx0 in base..(base + step) {
                let idx1 = idx0 + step;
                let a0 = state[idx0];
                let a1 = state[idx1];
                if a0.re == 0.0 && a0.im == 0.0 && a1.re == 0.0 && a1.im == 0.0 {
                    continue;
                }
                state[idx0] = u00 * a0 + u01 * a1;
                state[idx1] = u10 * a0 + u11 * a1;
            }
        }
    } else {
        for base in (0..dim).step_by(block) {
            if (base & ctrl_mask & !(block - 1)) != (ctrl_mask & !(block - 1)) {
                continue;
            }
            for idx0 in base..(base + step) {
                if (idx0 & ctrl_mask) != ctrl_mask {
                    continue;
                }
                let idx1 = idx0 + step;
                let a0 = state[idx0];
                let a1 = state[idx1];
                if a0.re == 0.0 && a0.im == 0.0 && a1.re == 0.0 && a1.im == 0.0 {
                    continue;
                }
                state[idx0] = u00 * a0 + u01 * a1;
                state[idx1] = u10 * a0 + u11 * a1;
            }
        }
    }
}

#[inline]
fn apply_pauli_x_fast_msb(state: &mut [C64], n_qubits: usize, target: usize, ctrl_mask: usize) {
    let dim = 1usize << n_qubits;
    let step = 1usize << (n_qubits - 1 - target);
    let block = step << 1;

    #[cfg(feature = "python")]
    if n_qubits >= 15 {
        use rayon::prelude::*;
        let chunk_size = block.max(8192);
        if ctrl_mask == 0 {
            if block <= (dim >> 4) {
                state.par_chunks_mut(chunk_size).for_each(|chunk| {
                    for sub_base in (0..chunk.len()).step_by(block) {
                        for idx0 in sub_base..(sub_base + step) {
                            chunk.swap(idx0, idx0 + step);
                        }
                    }
                });
            } else {
                for block_slice in state.chunks_mut(block) {
                    let (lo, hi) = block_slice.split_at_mut(step);
                    lo.par_chunks_mut(8192)
                        .zip(hi.par_chunks_mut(8192))
                        .for_each(|(c0, c1)| {
                            for (a0_ref, a1_ref) in c0.iter_mut().zip(c1.iter_mut()) {
                                std::mem::swap(a0_ref, a1_ref);
                            }
                        });
                }
            }
        } else if block <= (dim >> 4) {
            state
                .par_chunks_mut(chunk_size)
                .enumerate()
                .for_each(|(chk_i, chunk)| {
                    let chunk_base = chk_i * chunk_size;
                    for sub_base in (0..chunk.len()).step_by(block) {
                        let base = chunk_base + sub_base;
                        if (base & ctrl_mask & !(block - 1)) != (ctrl_mask & !(block - 1)) {
                            continue;
                        }
                        for k in 0..step {
                            if ((base + k) & ctrl_mask) == ctrl_mask {
                                let idx0 = sub_base + k;
                                chunk.swap(idx0, idx0 + step);
                            }
                        }
                    }
                });
        } else {
            for (blk_i, block_slice) in state.chunks_mut(block).enumerate() {
                let base = blk_i * block;
                if (base & ctrl_mask & !(block - 1)) != (ctrl_mask & !(block - 1)) {
                    continue;
                }
                let (lo, hi) = block_slice.split_at_mut(step);
                lo.par_chunks_mut(8192)
                    .zip(hi.par_chunks_mut(8192))
                    .enumerate()
                    .for_each(|(sub_i, (c0, c1))| {
                        let sub_base = base + sub_i * 8192;
                        for k in 0..c0.len() {
                            if ((sub_base + k) & ctrl_mask) == ctrl_mask {
                                std::mem::swap(&mut c0[k], &mut c1[k]);
                            }
                        }
                    });
            }
        }
        return;
    }

    if ctrl_mask == 0 {
        for base in (0..dim).step_by(block) {
            for idx0 in base..(base + step) {
                state.swap(idx0, idx0 + step);
            }
        }
    } else {
        for base in (0..dim).step_by(block) {
            if (base & ctrl_mask & !(block - 1)) != (ctrl_mask & !(block - 1)) {
                continue;
            }
            for idx0 in base..(base + step) {
                if (idx0 & ctrl_mask) == ctrl_mask {
                    state.swap(idx0, idx0 + step);
                }
            }
        }
    }
}

#[inline]
fn apply_pauli_z_fast_msb(state: &mut [C64], n_qubits: usize, target: usize, ctrl_mask: usize) {
    let dim = 1usize << n_qubits;
    let step = 1usize << (n_qubits - 1 - target);
    let block = step << 1;

    #[cfg(feature = "python")]
    if n_qubits >= 15 {
        use rayon::prelude::*;
        let chunk_size = block.max(8192);
        if ctrl_mask == 0 {
            if block <= (dim >> 4) {
                state.par_chunks_mut(chunk_size).for_each(|chunk| {
                    for sub_base in (0..chunk.len()).step_by(block) {
                        for idx1 in (sub_base + step)..(sub_base + block) {
                            chunk[idx1] = -chunk[idx1];
                        }
                    }
                });
            } else {
                for block_slice in state.chunks_mut(block) {
                    let (_lo, hi) = block_slice.split_at_mut(step);
                    hi.par_chunks_mut(8192).for_each(|c1| {
                        for a1_ref in c1.iter_mut() {
                            *a1_ref = -*a1_ref;
                        }
                    });
                }
            }
        } else if block <= (dim >> 4) {
            state
                .par_chunks_mut(chunk_size)
                .enumerate()
                .for_each(|(chk_i, chunk)| {
                    let chunk_base = chk_i * chunk_size;
                    for sub_base in (0..chunk.len()).step_by(block) {
                        let base = chunk_base + sub_base;
                        if (base & ctrl_mask & !(block - 1)) != (ctrl_mask & !(block - 1)) {
                            continue;
                        }
                        for k in 0..step {
                            if ((base + k) & ctrl_mask) == ctrl_mask {
                                let idx1 = sub_base + k + step;
                                chunk[idx1] = -chunk[idx1];
                            }
                        }
                    }
                });
        } else {
            for (blk_i, block_slice) in state.chunks_mut(block).enumerate() {
                let base = blk_i * block;
                if (base & ctrl_mask & !(block - 1)) != (ctrl_mask & !(block - 1)) {
                    continue;
                }
                let (_lo, hi) = block_slice.split_at_mut(step);
                hi.par_chunks_mut(8192)
                    .enumerate()
                    .for_each(|(sub_i, c1)| {
                        let sub_base = base + sub_i * 8192;
                        for k in 0..c1.len() {
                            if ((sub_base + k) & ctrl_mask) == ctrl_mask {
                                c1[k] = -c1[k];
                            }
                        }
                    });
            }
        }
        return;
    }

    if ctrl_mask == 0 {
        for base in (0..dim).step_by(block) {
            for idx1 in (base + step)..(base + block) {
                state[idx1] = -state[idx1];
            }
        }
    } else {
        for base in (0..dim).step_by(block) {
            if (base & ctrl_mask & !(block - 1)) != (ctrl_mask & !(block - 1)) {
                continue;
            }
            for idx0 in base..(base + step) {
                if (idx0 & ctrl_mask) == ctrl_mask {
                    let idx1 = idx0 + step;
                    state[idx1] = -state[idx1];
                }
            }
        }
    }
}

#[inline]
fn apply_diagonal_gate_fast_msb(
    state: &mut [C64],
    n_qubits: usize,
    target: usize,
    ctrl_mask: usize,
    u00: C64,
    u11: C64,
) {
    let dim = 1usize << n_qubits;
    let step = 1usize << (n_qubits - 1 - target);
    let block = step << 1;

    #[cfg(feature = "python")]
    if n_qubits >= 15 {
        use rayon::prelude::*;
        let chunk_size = block.max(8192);
        if ctrl_mask == 0 {
            if block <= (dim >> 4) {
                state.par_chunks_mut(chunk_size).for_each(|chunk| {
                    for sub_base in (0..chunk.len()).step_by(block) {
                        for idx0 in sub_base..(sub_base + step) {
                            let idx1 = idx0 + step;
                            chunk[idx0] = u00 * chunk[idx0];
                            chunk[idx1] = u11 * chunk[idx1];
                        }
                    }
                });
            } else {
                for block_slice in state.chunks_mut(block) {
                    let (lo, hi) = block_slice.split_at_mut(step);
                    lo.par_chunks_mut(8192)
                        .zip(hi.par_chunks_mut(8192))
                        .for_each(|(c0, c1)| {
                            for (a0_ref, a1_ref) in c0.iter_mut().zip(c1.iter_mut()) {
                                *a0_ref = u00 * (*a0_ref);
                                *a1_ref = u11 * (*a1_ref);
                            }
                        });
                }
            }
        } else if block <= (dim >> 4) {
            state
                .par_chunks_mut(chunk_size)
                .enumerate()
                .for_each(|(chk_i, chunk)| {
                    let chunk_base = chk_i * chunk_size;
                    for sub_base in (0..chunk.len()).step_by(block) {
                        let base = chunk_base + sub_base;
                        if (base & ctrl_mask & !(block - 1)) != (ctrl_mask & !(block - 1)) {
                            continue;
                        }
                        for k in 0..step {
                            if ((base + k) & ctrl_mask) == ctrl_mask {
                                let idx0 = sub_base + k;
                                let idx1 = idx0 + step;
                                chunk[idx0] = u00 * chunk[idx0];
                                chunk[idx1] = u11 * chunk[idx1];
                            }
                        }
                    }
                });
        } else {
            for (blk_i, block_slice) in state.chunks_mut(block).enumerate() {
                let base = blk_i * block;
                if (base & ctrl_mask & !(block - 1)) != (ctrl_mask & !(block - 1)) {
                    continue;
                }
                let (lo, hi) = block_slice.split_at_mut(step);
                lo.par_chunks_mut(8192)
                    .zip(hi.par_chunks_mut(8192))
                    .enumerate()
                    .for_each(|(sub_i, (c0, c1))| {
                        let sub_base = base + sub_i * 8192;
                        for k in 0..c0.len() {
                            if ((sub_base + k) & ctrl_mask) == ctrl_mask {
                                c0[k] = u00 * c0[k];
                                c1[k] = u11 * c1[k];
                            }
                        }
                    });
            }
        }
        return;
    }

    if ctrl_mask == 0 {
        for base in (0..dim).step_by(block) {
            for idx0 in base..(base + step) {
                let idx1 = idx0 + step;
                state[idx0] = u00 * state[idx0];
                state[idx1] = u11 * state[idx1];
            }
        }
    } else {
        for base in (0..dim).step_by(block) {
            if (base & ctrl_mask & !(block - 1)) != (ctrl_mask & !(block - 1)) {
                continue;
            }
            for idx0 in base..(base + step) {
                if (idx0 & ctrl_mask) == ctrl_mask {
                    let idx1 = idx0 + step;
                    state[idx0] = u00 * state[idx0];
                    state[idx1] = u11 * state[idx1];
                }
            }
        }
    }
}

/// Applies a Pauli string `P` to a basis state `|idx>` (MSB ordering), returning `(new_idx, phase)`.
#[inline]
pub fn apply_pauli_string_to_basis_msb(
    idx: usize,
    ops: &[(usize, char)],
    n_qubits: usize,
) -> (usize, C64) {
    CompiledPauliString::from_ops(ops, n_qubits).apply_to_basis(idx)
}

/// Zero-allocation in-place evaluation of `exp(-i * angle / 2 * P)` using a precompiled `CompiledPauliString`.
#[inline]
pub fn apply_compiled_exp_pauli_msb(
    state: &mut [C64],
    n_qubits: usize,
    compiled_pauli: &CompiledPauliString,
    angle: f64,
    ctrl_mask: usize,
) {
    if angle.abs() < 1e-15 {
        return;
    }
    let dim = 1usize << n_qubits;
    let half = 0.5 * angle;
    let cos_h = C64::new(half.cos(), 0.0);
    let minus_i_sin_h = C64::new(0.0, -half.sin());

    if compiled_pauli.xy_mask == 0 {
        // Purely diagonal Z-string: partner == idx, phase in {+1, -1}
        let diag_plus = C64::new(half.cos(), -half.sin()) * compiled_pauli.y_phase;
        let diag_minus = C64::new(half.cos(), half.sin()) * compiled_pauli.y_phase;
        let z_mask = compiled_pauli.z_mask;
        #[cfg(feature = "python")]
        if n_qubits >= 15 {
            use rayon::prelude::*;
            state
                .par_chunks_mut(4096)
                .enumerate()
                .for_each(|(chunk_i, chunk)| {
                    let base = chunk_i * 4096;
                    if ctrl_mask == 0 {
                        for (k, amp) in chunk.iter_mut().enumerate() {
                            let neg = (((base + k) & z_mask).count_ones() & 1) != 0;
                            *amp = if neg {
                                diag_minus * (*amp)
                            } else {
                                diag_plus * (*amp)
                            };
                        }
                    } else {
                        for (k, amp) in chunk.iter_mut().enumerate() {
                            let idx = base + k;
                            if (idx & ctrl_mask) == ctrl_mask {
                                let neg = ((idx & z_mask).count_ones() & 1) != 0;
                                *amp = if neg {
                                    diag_minus * (*amp)
                                } else {
                                    diag_plus * (*amp)
                                };
                            }
                        }
                    }
                });
            return;
        }
        if ctrl_mask == 0 {
            for (idx, amp) in state.iter_mut().enumerate() {
                let neg = ((idx & z_mask).count_ones() & 1) != 0;
                *amp = if neg { diag_minus * (*amp) } else { diag_plus * (*amp) };
            }
        } else {
            for (idx, amp) in state.iter_mut().enumerate() {
                if (idx & ctrl_mask) == ctrl_mask {
                    let neg = ((idx & z_mask).count_ones() & 1) != 0;
                    *amp = if neg { diag_minus * (*amp) } else { diag_plus * (*amp) };
                }
            }
        }
    } else {
        // Off-diagonal involutive Pauli string
        let xy_mask = compiled_pauli.xy_mask;
        let z_mask = compiled_pauli.z_mask;
        let y_phase = compiled_pauli.y_phase;

        #[cfg(feature = "python")]
        if n_qubits >= 15 {
            use rayon::prelude::*;
            let high_bit = 1usize << (usize::BITS - 1 - xy_mask.leading_zeros());
            let high_block = high_bit << 1;
            let rem_mask = xy_mask ^ high_bit;
            if high_block <= (dim >> 4) {
                let chunk_size = high_block.max(8192);
                state
                    .par_chunks_mut(chunk_size)
                    .enumerate()
                    .for_each(|(chk_i, chunk)| {
                        let chunk_base = chk_i * chunk_size;
                        for sub_base in (0..chunk.len()).step_by(high_block) {
                            let base = chunk_base + sub_base;
                            let sub_slice = &mut chunk[sub_base..(sub_base + high_block)];
                            let (lo, hi) = sub_slice.split_at_mut(high_bit);
                            for j in 0..high_bit {
                                let idx = base + j;
                                if ctrl_mask != 0 && (idx & ctrl_mask) != ctrl_mask {
                                    continue;
                                }
                                let partner_j = j ^ rem_mask;
                                let a0 = lo[j];
                                let a1 = hi[partner_j];
                                let neg = ((idx & z_mask).count_ones() & 1) != 0;
                                let phase = if neg { -y_phase } else { y_phase };
                                let c_idx = minus_i_sin_h * phase.conj();
                                let c_part = minus_i_sin_h * phase;
                                lo[j] = cos_h * a0 + c_idx * a1;
                                hi[partner_j] = cos_h * a1 + c_part * a0;
                            }
                        }
                    });
                return;
            } else {
                let sub_s = if rem_mask == 0 {
                    8192.min(high_bit)
                } else {
                    (1usize << (usize::BITS - rem_mask.leading_zeros()))
                        .max(8192)
                        .min(high_bit)
                };
                if sub_s < high_bit {
                    let sub_rem = rem_mask & (sub_s - 1);
                    for (blk_i, block_slice) in state.chunks_mut(high_block).enumerate() {
                        let base = blk_i * high_block;
                        let (lo, hi) = block_slice.split_at_mut(high_bit);
                        lo.par_chunks_mut(sub_s)
                            .zip(hi.par_chunks_mut(sub_s))
                            .enumerate()
                            .for_each(|(sub_i, (c0, c1))| {
                                let sub_base = base + sub_i * sub_s;
                                for j in 0..c0.len() {
                                    let idx = sub_base + j;
                                    if ctrl_mask != 0 && (idx & ctrl_mask) != ctrl_mask {
                                        continue;
                                    }
                                    let partner_j = j ^ sub_rem;
                                    let a0 = c0[j];
                                    let a1 = c1[partner_j];
                                    let neg = ((idx & z_mask).count_ones() & 1) != 0;
                                    let phase = if neg { -y_phase } else { y_phase };
                                    let c_idx = minus_i_sin_h * phase.conj();
                                    let c_part = minus_i_sin_h * phase;
                                    c0[j] = cos_h * a0 + c_idx * a1;
                                    c1[partner_j] = cos_h * a1 + c_part * a0;
                                }
                            });
                    }
                    return;
                }
            }
        }

        let step = xy_mask & xy_mask.wrapping_neg();
        let block = step << 1;
        if ctrl_mask == 0 {
            for base in (0..dim).step_by(block) {
                for idx in base..(base + step) {
                    let partner = idx ^ xy_mask;
                    let a0 = state[idx];
                    let a1 = state[partner];
                    if a0.re == 0.0 && a0.im == 0.0 && a1.re == 0.0 && a1.im == 0.0 {
                        continue;
                    }
                    let neg = ((idx & z_mask).count_ones() & 1) != 0;
                    let phase = if neg { -y_phase } else { y_phase };
                    let c_idx = minus_i_sin_h * phase.conj();
                    let c_part = minus_i_sin_h * phase;
                    state[idx] = cos_h * a0 + c_idx * a1;
                    state[partner] = cos_h * a1 + c_part * a0;
                }
            }
        } else {
            for base in (0..dim).step_by(block) {
                for idx in base..(base + step) {
                    if (idx & ctrl_mask) != ctrl_mask {
                        continue;
                    }
                    let partner = idx ^ xy_mask;
                    let a0 = state[idx];
                    let a1 = state[partner];
                    if a0.re == 0.0 && a0.im == 0.0 && a1.re == 0.0 && a1.im == 0.0 {
                        continue;
                    }
                    let neg = ((idx & z_mask).count_ones() & 1) != 0;
                    let phase = if neg { -y_phase } else { y_phase };
                    let c_idx = minus_i_sin_h * phase.conj();
                    let c_part = minus_i_sin_h * phase;
                    state[idx] = cos_h * a0 + c_idx * a1;
                    state[partner] = cos_h * a1 + c_part * a0;
                }
            }
        }
    }
}

/// Applies `exp(-i * angle / 2 * P)` for a multi-qubit Pauli string `P` conditioned on `controls`.
pub fn apply_exp_pauli_msb(
    state: &mut [C64],
    n_qubits: usize,
    paulis: &[(usize, char)],
    angle: f64,
    controls: &[usize],
) {
    let compiled = CompiledPauliString::from_ops(paulis, n_qubits);
    let ctrl_mask = controls_mask_msb(controls, n_qubits);
    apply_compiled_exp_pauli_msb(state, n_qubits, &compiled, angle, ctrl_mask);
}

/// Executes a sequence of `TequilaGateOp` instructions on an `n_qubits` statevector in MSB ordering.
pub fn simulate_circuit_msb(
    n_qubits: usize,
    initial_state_msb: &[C64],
    gates: &[TequilaGateOp],
) -> Vec<C64> {
    let dim = 1usize << n_qubits;
    let mut state = if initial_state_msb.len() == dim {
        initial_state_msb.to_vec()
    } else {
        let mut s = vec![C64::ZERO; dim];
        s[0] = C64::ONE;
        s
    };

    let inv_sqrt2 = C64::new(std::f64::consts::FRAC_1_SQRT_2, 0.0);

    for gate in gates {
        match gate {
            TequilaGateOp::Basic {
                name,
                targets,
                controls,
            } => {
                let ctrl_mask = controls_mask_msb(controls, n_qubits);
                let upper = name.to_uppercase();
                for &t in targets {
                    match upper.as_str() {
                        "X" | "CNOT" | "CX" | "NOT" => {
                            apply_pauli_x_fast_msb(&mut state, n_qubits, t, ctrl_mask);
                        }
                        "Y" | "CY" => {
                            apply_single_qubit_unitary_msb(
                                &mut state,
                                n_qubits,
                                t,
                                controls,
                                C64::ZERO,
                                C64::new(0.0, -1.0),
                                C64::new(0.0, 1.0),
                                C64::ZERO,
                            );
                        }
                        "Z" | "CZ" => {
                            apply_pauli_z_fast_msb(&mut state, n_qubits, t, ctrl_mask);
                        }
                        "H" | "HADAMARD" | "CH" => {
                            apply_single_qubit_unitary_msb(
                                &mut state,
                                n_qubits,
                                t,
                                controls,
                                inv_sqrt2,
                                inv_sqrt2,
                                inv_sqrt2,
                                -inv_sqrt2,
                            );
                        }
                        "S" => {
                            apply_diagonal_gate_fast_msb(
                                &mut state,
                                n_qubits,
                                t,
                                ctrl_mask,
                                C64::ONE,
                                C64::new(0.0, 1.0),
                            );
                        }
                        "T" => {
                            apply_diagonal_gate_fast_msb(
                                &mut state,
                                n_qubits,
                                t,
                                ctrl_mask,
                                C64::ONE,
                                C64::new(
                                    std::f64::consts::FRAC_1_SQRT_2,
                                    std::f64::consts::FRAC_1_SQRT_2,
                                ),
                            );
                        }
                        _ => {}
                    }
                }
            }
            TequilaGateOp::Swap { q0, q1, controls } => {
                let ctrl_mask = controls_mask_msb(controls, n_qubits);
                let m0 = 1usize << (n_qubits - 1 - *q0);
                let m1 = 1usize << (n_qubits - 1 - *q1);
                let swap_mask = m0 | m1;
                for idx in 0..dim {
                    if (idx & ctrl_mask) == ctrl_mask && (idx & swap_mask) == m1 {
                        state.swap(idx, idx ^ swap_mask);
                    }
                }
            }
            TequilaGateOp::Rotation {
                axis,
                angle,
                targets,
                controls,
            } => {
                if angle.abs() < 1e-15 {
                    continue;
                }
                let ctrl_mask = controls_mask_msb(controls, n_qubits);
                let half = 0.5 * (*angle);
                let c = half.cos();
                let s = half.sin();
                let upper = axis.to_uppercase();
                for &t in targets {
                    match upper.as_str() {
                        "X" | "RX" | "CRX" => {
                            apply_single_qubit_unitary_msb(
                                &mut state,
                                n_qubits,
                                t,
                                controls,
                                C64::new(c, 0.0),
                                C64::new(0.0, -s),
                                C64::new(0.0, -s),
                                C64::new(c, 0.0),
                            );
                        }
                        "Y" | "RY" | "CRY" => {
                            apply_single_qubit_unitary_msb(
                                &mut state,
                                n_qubits,
                                t,
                                controls,
                                C64::new(c, 0.0),
                                C64::new(-s, 0.0),
                                C64::new(s, 0.0),
                                C64::new(c, 0.0),
                            );
                        }
                        "Z" | "RZ" | "CRZ" => {
                            apply_diagonal_gate_fast_msb(
                                &mut state,
                                n_qubits,
                                t,
                                ctrl_mask,
                                C64::new(c, -s),
                                C64::new(c, s),
                            );
                        }
                        "PHASE" | "P" | "CP" => {
                            apply_diagonal_gate_fast_msb(
                                &mut state,
                                n_qubits,
                                t,
                                ctrl_mask,
                                C64::ONE,
                                C64::new(angle.cos(), angle.sin()),
                            );
                        }
                        _ => {}
                    }
                }
            }
            TequilaGateOp::ExpPauli {
                paulis,
                angle,
                controls,
            } => {
                apply_exp_pauli_msb(&mut state, n_qubits, paulis, *angle, controls);
            }
            TequilaGateOp::CausalDo { qubit, bit_value } => {
                let target_bit = (*bit_value as usize) & 1;
                let mut norm_sq = 0.0;
                for (idx, amp) in state.iter_mut().enumerate() {
                    if bit_at_msb(idx, *qubit, n_qubits) != target_bit {
                        *amp = C64::ZERO;
                    } else {
                        norm_sq += amp.norm_sq();
                    }
                }
                if norm_sq > 1e-15 {
                    let scale = 1.0 / norm_sq.sqrt();
                    for amp in state.iter_mut() {
                        *amp = C64::new(amp.re * scale, amp.im * scale);
                    }
                }
            }
        }
    }

    state
}

/// Evaluates `<bra | H | ket>` for a list of weighted Pauli strings in MSB ordering
/// using precompiled `CompiledPauliString` bitmasks (`XOR`, `AND`, `POPCNT`), support-indexed
/// sparse Plücker scanning, and diagonal probability fusion when `bra == ket`.
pub fn expectation_pauli_hamiltonian_msb(
    n_qubits: usize,
    bra_msb: &[C64],
    ket_msb: &[C64],
    terms: &[PauliTerm],
) -> C64 {
    let same_state = std::ptr::eq(bra_msb.as_ptr(), ket_msb.as_ptr());

    // Pre-extract non-zero support (idx, amp, norm_sq) once in O(2^n)!
    // For particle-number-conserving Grassmannian Plücker states, |support| = C(n, k) << 2^n.
    let support: Vec<(usize, C64, f64)> = ket_msb
        .iter()
        .enumerate()
        .filter_map(|(idx, &amp)| {
            let p = amp.norm_sq();
            if p > 1e-30 {
                Some((idx, amp, p))
            } else {
                None
            }
        })
        .collect();

    let eval_term = |term: &PauliTerm| -> C64 {
        let coeff = C64::new(term.coeff_re, term.coeff_im);
        let compiled = CompiledPauliString::from_ops(&term.ops, n_qubits);
        if compiled.xy_mask == 0 && compiled.z_mask == 0 {
            if same_state {
                return coeff;
            }
            let mut inner = C64::ZERO;
            for &(idx, k_amp, _) in &support {
                inner = inner + bra_msb[idx].conj() * k_amp;
            }
            return coeff * inner;
        }
        if same_state && compiled.xy_mask == 0 {
            // Diagonal Z-only string evaluated strictly over non-zero support!
            let z_mask = compiled.z_mask;
            let mut sum_re = 0.0;
            for &(idx, _, p) in &support {
                if ((idx & z_mask).count_ones() & 1) != 0 {
                    sum_re -= p;
                } else {
                    sum_re += p;
                }
            }
            return coeff * (compiled.y_phase * C64::new(sum_re, 0.0));
        }

        let xy_mask = compiled.xy_mask;
        let z_mask = compiled.z_mask;
        let y_phase = compiled.y_phase;
        let mut accum = C64::ZERO;
        for &(idx, k_amp, _) in &support {
            let target_idx = idx ^ xy_mask;
            let b_amp = bra_msb[target_idx];
            if b_amp.re == 0.0 && b_amp.im == 0.0 {
                continue;
            }
            let neg = ((idx & z_mask).count_ones() & 1) != 0;
            let phase = if neg { -y_phase } else { y_phase };
            accum = accum + b_amp.conj() * (phase * k_amp);
        }
        coeff * accum
    };

    #[cfg(feature = "python")]
    {
        use rayon::prelude::*;
        if terms.len() >= 24 && support.len() >= 128 {
            terms
                .par_iter()
                .map(eval_term)
                .reduce(|| C64::ZERO, |a, b| a + b)
        } else {
            terms.iter().map(eval_term).fold(C64::ZERO, |a, b| a + b)
        }
    }
    #[cfg(not(feature = "python"))]
    {
        terms.iter().map(eval_term).fold(C64::ZERO, |a, b| a + b)
    }
}

/// Fast pre-compiled Hamiltonian representation separating identity, precomputed fused diagonal
/// table `D[x]` (for `n_qubits <= 15`), fallback 64-bit and 128-bit diagonal $Z$-strings, and
/// off-diagonal Pauli strings with precomputed `(xy_mask, z_mask, y_phase)` bitmasks.
#[derive(Clone, Debug)]
pub struct FastCompiledHamiltonian {
    pub identity_re: f64,
    pub precomputed_diag: Option<Vec<f64>>,
    pub diag_terms: Vec<(f64, usize)>,
    pub diag_terms_128: Vec<(f64, u128)>,
    pub offdiag_terms: Vec<(C64, CompiledPauliString)>,
}

impl FastCompiledHamiltonian {
    pub fn from_raw_terms(
        n_qubits: usize,
        raw_terms: &[(f64, f64, Vec<(usize, String)>)],
    ) -> Self {
        let mut identity_re = 0.0;
        let mut diag_terms = Vec::new();
        let mut diag_terms_128 = Vec::new();
        let mut offdiag_terms = Vec::new();

        for (cr, ci, ops) in raw_terms {
            let char_ops: Vec<(usize, char)> = ops
                .iter()
                .map(|(q, s)| (*q, s.chars().next().unwrap_or('I')))
                .collect();
            let compiled = CompiledPauliString::from_ops(&char_ops, n_qubits);
            if compiled.xy_mask_128 == 0 && compiled.z_mask_128 == 0 {
                identity_re += *cr;
            } else if compiled.xy_mask_128 == 0 {
                // Pure Z string (y_phase is +1)
                diag_terms.push((*cr, compiled.z_mask));
                diag_terms_128.push((*cr, compiled.z_mask_128));
            } else {
                offdiag_terms.push((C64::new(*cr, *ci), compiled));
            }
        }

        let precomputed_diag = if !diag_terms.is_empty() && n_qubits <= 15 {
            let dim = 1usize << n_qubits;
            let mut table = vec![identity_re; dim];
            for (idx, val) in table.iter_mut().enumerate() {
                let mut acc = 0.0;
                for &(coeff_re, z_mask) in &diag_terms {
                    if ((idx & z_mask).count_ones() & 1) != 0 {
                        acc -= coeff_re;
                    } else {
                        acc += coeff_re;
                    }
                }
                *val += acc;
            }
            Some(table)
        } else {
            None
        };

        Self {
            identity_re,
            precomputed_diag,
            diag_terms,
            diag_terms_128,
            offdiag_terms,
        }
    }

    /// Evaluates `<psi | H | psi>` directly on a sorted 128-bit sparse Plücker state
    /// `sparse: &[(u128, C64)]` in $O(M \cdot |\mathrm{supp}| \log |\mathrm{supp}|)$ without
    /// allocating any $2^n$ statevector! Scales to $n \le 126$ qubits.
    pub fn expectation_sparse(&self, sparse: &[(u128, C64)]) -> f64 {
        let mut total = if let Some(ref diag_table) = self.precomputed_diag {
            let mut diag_sum = 0.0;
            for &(idx, amp) in sparse {
                diag_sum += amp.norm_sq() * diag_table[idx as usize];
            }
            diag_sum
        } else {
            let mut diag_sum = self.identity_re;
            if !self.diag_terms_128.is_empty() {
                for &(idx, amp) in sparse {
                    let p = amp.norm_sq();
                    let mut w = 0.0;
                    for &(coeff_re, z_mask) in &self.diag_terms_128 {
                        if ((idx & z_mask).count_ones() & 1) != 0 {
                            w -= coeff_re;
                        } else {
                            w += coeff_re;
                        }
                    }
                    diag_sum += p * w;
                }
            }
            diag_sum
        };

        let eval_offdiag = |(coeff, compiled): &(C64, CompiledPauliString)| -> f64 {
            let xy_mask = compiled.xy_mask_128;
            let low_bit = xy_mask & xy_mask.wrapping_neg();
            let z_mask = compiled.z_mask_128;
            let y_phase = compiled.y_phase;
            let mut accum_re = 0.0;
            for &(idx, k_amp) in sparse {
                if (idx & low_bit) != 0 {
                    continue;
                }
                let target_idx = idx ^ xy_mask;
                if let Ok(pos) = sparse.binary_search_by_key(&target_idx, |&(k, _)| k) {
                    let b_amp = sparse[pos].1;
                    let neg = ((idx & z_mask).count_ones() & 1) != 0;
                    let phase = if neg { -y_phase } else { y_phase };
                    let prod = b_amp.conj() * (phase * k_amp);
                    accum_re += 2.0 * prod.re;
                }
            }
            coeff.re * accum_re
        };

        #[cfg(feature = "python")]
        {
            use rayon::prelude::*;
            if self.offdiag_terms.len() * sparse.len() >= 16_384 && self.offdiag_terms.len() >= 8 {
                total += self.offdiag_terms.par_iter().map(eval_offdiag).sum::<f64>();
            } else {
                total += self.offdiag_terms.iter().map(eval_offdiag).sum::<f64>();
            }
        }
        #[cfg(not(feature = "python"))]
        {
            total += self.offdiag_terms.iter().map(eval_offdiag).sum::<f64>();
        }

        total
    }

    /// Evaluates `<psi | H | psi>` directly on a dense $2^n$ statevector `state: &[C64]`
    /// with zero heap allocations and cache-blocked 4096-element Rayon parallelism.
    pub fn expectation_dense(&self, state: &[C64]) -> f64 {
        let dim = state.len();
        let eval_chunk = |base: usize, end: usize| -> f64 {
            let mut chunk_sum = 0.0;
            if let Some(ref diag_table) = self.precomputed_diag {
                for idx in base..end {
                    let amp = state[idx];
                    let p = amp.re * amp.re + amp.im * amp.im;
                    chunk_sum += p * diag_table[idx];
                }
            } else if !self.diag_terms.is_empty() {
                for idx in base..end {
                    let amp = state[idx];
                    let p = amp.re * amp.re + amp.im * amp.im;
                    let mut w = 0.0;
                    for &(coeff_re, z_mask) in &self.diag_terms {
                        if ((idx & z_mask).count_ones() & 1) != 0 {
                            w -= coeff_re;
                        } else {
                            w += coeff_re;
                        }
                    }
                    chunk_sum += p * w;
                }
            }

            let span = end - base;
            for &(coeff, ref compiled) in &self.offdiag_terms {
                let xy_mask = compiled.xy_mask;
                let low_bit = xy_mask & xy_mask.wrapping_neg();
                let z_mask = compiled.z_mask;
                let y_phase = compiled.y_phase;
                let mut term_re = 0.0;
                if low_bit >= span {
                    if (base & low_bit) == 0 {
                        for idx in base..end {
                            let k_amp = state[idx];
                            let b_amp = state[idx ^ xy_mask];
                            let neg = ((idx & z_mask).count_ones() & 1) != 0;
                            let phase = if neg { -y_phase } else { y_phase };
                            let prod = b_amp.conj() * (phase * k_amp);
                            term_re += 2.0 * prod.re;
                        }
                    }
                } else {
                    let step = low_bit;
                    let block = step << 1;
                    for blk in (base..end).step_by(block) {
                        for idx in blk..(blk + step) {
                            let k_amp = state[idx];
                            let b_amp = state[idx ^ xy_mask];
                            let neg = ((idx & z_mask).count_ones() & 1) != 0;
                            let phase = if neg { -y_phase } else { y_phase };
                            let prod = b_amp.conj() * (phase * k_amp);
                            term_re += 2.0 * prod.re;
                        }
                    }
                }
                chunk_sum += coeff.re * term_re;
            }
            chunk_sum
        };

        let base_id = if self.precomputed_diag.is_some() {
            0.0
        } else {
            self.identity_re
        };

        #[cfg(feature = "python")]
        if dim >= 16_384 {
            use rayon::prelude::*;
            let n_chunks = (dim + 4095) / 4096;
            let sum_chunks: f64 = (0..n_chunks)
                .into_par_iter()
                .map(|c| {
                    let base = c * 4096;
                    let end = (base + 4096).min(dim);
                    eval_chunk(base, end)
                })
                .sum();
            return base_id + sum_chunks;
        }

        base_id + eval_chunk(0, dim)
    }

    /// Evaluates `<psi | H | psi>` using the precomputed fused diagonal table `D[x]`
    /// ($O(|\mathrm{supp}|)$ independent of $M_{\mathrm{diag}}$), adaptive sparse-support vs.
    /// dense lowest-set-bit butterfly pairing, and Rayon parallelism.
    pub fn expectation_on_support(&self, state: &[C64], support: &[(usize, C64, f64)]) -> f64 {
        let dim = state.len();
        let is_sparse = support.len() * 2 <= dim;

        // 1. Diagonal Z-terms: single dot product with precomputed_diag in O(|supp|)
        let mut total = if let Some(ref diag_table) = self.precomputed_diag {
            let mut diag_sum = 0.0;
            for &(idx, _, p) in support {
                diag_sum += p * diag_table[idx];
            }
            diag_sum
        } else {
            let mut diag_sum = self.identity_re;
            if !self.diag_terms.is_empty() {
                for &(idx, _, p) in support {
                    let mut weight_idx = 0.0;
                    for &(coeff_re, z_mask) in &self.diag_terms {
                        if ((idx & z_mask).count_ones() & 1) != 0 {
                            weight_idx -= coeff_re;
                        } else {
                            weight_idx += coeff_re;
                        }
                    }
                    diag_sum += p * weight_idx;
                }
            }
            diag_sum
        };

        // 2. Off-diagonal Pauli strings:
        //    - Sparse regime (|supp| <= dim/2): iterate over support with `(idx & low_bit) == 0`
        //    - Dense regime (|supp| > dim/2): branchless butterfly blocks of step = low_bit over `state`
        let eval_offdiag = |(coeff, compiled): &(C64, CompiledPauliString)| -> f64 {
            let xy_mask = compiled.xy_mask;
            let low_bit = xy_mask & xy_mask.wrapping_neg();
            let z_mask = compiled.z_mask;
            let y_phase = compiled.y_phase;
            let mut accum_re = 0.0;
            if is_sparse {
                for &(idx, k_amp, _) in support {
                    if (idx & low_bit) != 0 {
                        continue;
                    }
                    let target_idx = idx ^ xy_mask;
                    let b_amp = state[target_idx];
                    if b_amp.re == 0.0 && b_amp.im == 0.0 {
                        continue;
                    }
                    let neg = ((idx & z_mask).count_ones() & 1) != 0;
                    let phase = if neg { -y_phase } else { y_phase };
                    let prod = b_amp.conj() * (phase * k_amp);
                    accum_re += 2.0 * prod.re;
                }
            } else {
                let step = low_bit;
                let block = step << 1;
                for base in (0..dim).step_by(block) {
                    for idx in base..(base + step) {
                        let k_amp = state[idx];
                        let b_amp = state[idx ^ xy_mask];
                        let neg = ((idx & z_mask).count_ones() & 1) != 0;
                        let phase = if neg { -y_phase } else { y_phase };
                        let prod = b_amp.conj() * (phase * k_amp);
                        accum_re += 2.0 * prod.re;
                    }
                }
            }
            coeff.re * accum_re
        };

        #[cfg(feature = "python")]
        {
            use rayon::prelude::*;
            let work = self.offdiag_terms.len() * support.len().min(dim >> 1);
            if work >= 16_384 && self.offdiag_terms.len() >= 8 {
                total += self.offdiag_terms.par_iter().map(eval_offdiag).sum::<f64>();
            } else {
                total += self.offdiag_terms.iter().map(eval_offdiag).sum::<f64>();
            }
        }
        #[cfg(not(feature = "python"))]
        {
            total += self.offdiag_terms.iter().map(eval_offdiag).sum::<f64>();
        }

        total
    }
}

/// Applies single-pass or multi-pass McWeeny cubic idempotency purification
/// `rho_next = 3 * rho^2 - 2 * rho^3` to an `N x N` complex density matrix.
pub fn mcweeny_purify_density_matrix(
    rho: &[C64],
    dim: usize,
    iterations: usize,
) -> Vec<C64> {
    let mat_mul = |a: &[C64], b: &[C64]| -> Vec<C64> {
        let mut out = vec![C64::ZERO; dim * dim];
        for i in 0..dim {
            for k in 0..dim {
                let aik = a[i * dim + k];
                if aik.norm_sq() < 1e-30 {
                    continue;
                }
                for j in 0..dim {
                    out[i * dim + j] = out[i * dim + j] + aik * b[k * dim + j];
                }
            }
        }
        out
    };

    let mut current = rho.to_vec();
    for _ in 0..iterations {
        let rho2 = mat_mul(&current, &current);
        let rho3 = mat_mul(&rho2, &current);
        for idx in 0..(dim * dim) {
            current[idx] = C64::new(3.0, 0.0) * rho2[idx] - C64::new(2.0, 0.0) * rho3[idx];
        }
    }
    current
}

/// Computes the Grassmannian Plücker $\mathrm{Gr}_{\mathbb{C}}(2,4)$, Complex VRC,
/// Madelung/Bohm, QCI spin mutual information, and Jeffrey kinematic diagnostics for a statevector.
pub fn analyze_grassmann_qci_state(
    n_qubits: usize,
    state_msb: &[C64],
    soft_evidence_q: f64,
    prior_p: f64,
) -> TequilaGrassmannDiagnostics {
    let dim = state_msb.len();
    // Extract first 4 amplitudes (or pad with zeros) to form a 2x4 Grassmannian frame [I_2 | W]
    let a0 = if dim > 0 { state_msb[0] } else { C64::ONE };
    let a1 = if dim > 1 { state_msb[1] } else { C64::ZERO };
    let a2 = if dim > 2 { state_msb[2] } else { C64::ZERO };
    let a3 = if dim > 3 { state_msb[3] } else { C64::ZERO };

    // Construct pole-free mutated homogeneous VRC at resonance x_X = -1
    let vrc = ComplexPlabicVrc2x4::mutated_homogeneous(a1, a2, C64::new(-1.0, 0.0));
    let vrc_res = vrc.relation_residual_frobenius_norm();
    let plucker = vrc.pluckers();
    let plucker_res = plucker.quadratic_relation().abs();

    // Kähler determinant factor det(I_2 + W W^\dagger) = ||p(I_2 | W)||^2 >= 1
    let c_chart = [
        [C64::ONE, C64::ZERO, a0, a1],
        [C64::ZERO, C64::ONE, a2, a3],
    ];
    let p_chart = Plucker2x4::from_matrix(&c_chart);
    let kahler_det = p_chart.p12.norm_sq()
        + p_chart.p13.norm_sq()
        + p_chart.p14.norm_sq()
        + p_chart.p23.norm_sq()
        + p_chart.p24.norm_sq()
        + p_chart.p34.norm_sq();

    // Single-qubit marginal occupation p(q0 = 1) for 1-RDM correlation entropy
    let mut occ_q0 = 0.0;
    let mut occ_q1 = 0.0;
    for (idx, amp) in state_msb.iter().enumerate() {
        let prob = amp.norm_sq();
        if n_qubits >= 1 && bit_at_msb(idx, 0, n_qubits) == 1 {
            occ_q0 += prob;
        }
        if n_qubits >= 2 && bit_at_msb(idx, 1, n_qubits) == 1 {
            occ_q1 += prob;
        }
    }
    let occ_clamped = occ_q0.clamp(0.0, 1.0);
    let s_corr = two_orbital_linear_correlation_entropy(occ_clamped);
    let s_q1 = two_orbital_linear_correlation_entropy(occ_q1.clamp(0.0, 1.0));
    let s_joint = two_orbital_linear_correlation_entropy((0.5 * (occ_clamped + occ_q1)).clamp(0.0, 1.0));
    let qci_mi = (s_corr + s_q1 - s_joint).max(0.0);

    // Regularized Plücker-Bohm quantum pressure trace: sum_I |p_I|^2 / kahler_det = 1.0
    let bohm_trace = if kahler_det > 0.0 {
        kahler_det / (1.0 + kahler_det)
    } else {
        0.0
    };

    // Quantum Jeffrey Plücker kinematic update under soft evidence q_E
    let jeffrey_post = quantum_jeffrey_plucker_kinematic_update(
        soft_evidence_q,
        1.0 - soft_evidence_q,
        occ_clamped,
        1.0 - occ_clamped,
        0.5,
        a0.re,
        a0.im,
        a3.re,
        a3.im,
    );

    // Effective GHZ coherence visibility & Mermin witness
    let ghz_fidelity = (a0.norm_sq() + state_msb.last().copied().unwrap_or(C64::ZERO).norm_sq())
        .clamp(0.5, 1.0);
    let _ = prior_p;
    let mermin = mermin_three_qudit_ghz_witness(ghz_fidelity);

    TequilaGrassmannDiagnostics {
        kahler_det_factor: kahler_det,
        plucker_relation_residual: plucker_res,
        vrc_orthogonality_residual: vrc_res,
        one_rdm_linear_entropy: s_corr,
        qci_spin_mutual_info: qci_mi,
        madelung_bohm_regularized_trace: bohm_trace,
        jeffrey_posterior_prob: jeffrey_post,
        mermin_ghz_witness: mermin,
    }
}

/// Deterministic / seeded Born-rule multinomial sampler returning `(basis_index, count)` pairs.
pub fn sample_statevector_msb(
    state_msb: &[C64],
    samples: usize,
    seed: u64,
) -> Vec<(usize, usize)> {
    let dim = state_msb.len();
    let mut cdf = Vec::with_capacity(dim);
    let mut acc = 0.0;
    for amp in state_msb {
        acc += amp.norm_sq();
        cdf.push(acc);
    }
    if acc > 0.0 {
        for v in cdf.iter_mut() {
            *v /= acc;
        }
    }
    let mut counts = vec![0usize; dim];
    // SplitMix64 deterministic PRNG
    let mut state_rng = seed ^ 0x9E37_79B9_7F4A_7C15;
    for _ in 0..samples {
        state_rng = state_rng.wrapping_add(0x9E37_79B9_7F4A_7C15);
        let mut z = state_rng;
        z = (z ^ (z >> 30)).wrapping_mul(0xBF58_476D_1CE4_E5B9);
        z = (z ^ (z >> 27)).wrapping_mul(0x94D0_49BB_1331_11EB);
        z = z ^ (z >> 31);
        let u = ((z >> 11) as f64) * (1.0 / ((1u64 << 53) as f64));
        let idx = cdf
            .binary_search_by(|probe| probe.partial_cmp(&u).unwrap_or(std::cmp::Ordering::Equal))
            .unwrap_or_else(|e| e.min(dim.saturating_sub(1)));
        counts[idx] += 1;
    }
    counts
        .into_iter()
        .enumerate()
        .filter(|&(_, c)| c > 0)
        .collect()
}

/// Dimension of the particle-number-conserving Grassmannian Plücker sector `C(n_orb, n_occ)`.
pub fn grassmann_plucker_sector_dim(n_occ: usize, n_orb: usize) -> usize {
    if n_occ > n_orb {
        return 0;
    }
    let mut res = 1usize;
    for i in 0..n_occ {
        res = res * (n_orb - i) / (i + 1);
    }
    res
}

/// Full $2^{n_{\mathrm{orb}}}$ Hilbert-space dimension vs. $\binom{n_{\mathrm{orb}}}{n_{\mathrm{occ}}}$ Plücker sector compression ratio.
pub fn grassmann_hilbert_to_plucker_compression_ratio(n_occ: usize, n_orb: usize) -> f64 {
    let plucker_dim = grassmann_plucker_sector_dim(n_occ, n_orb);
    if plucker_dim == 0 {
        return 0.0;
    }
    ((1usize << n_orb) as f64) / (plucker_dim as f64)
}

/// Computes the determinant of an `m x m` complex matrix via Gaussian elimination with partial pivoting.
pub fn complex_det(mat: &[Vec<C64>]) -> C64 {
    let m = mat.len();
    if m == 0 {
        return C64::ONE;
    }
    if m == 1 {
        return mat[0][0];
    }
    if m == 2 {
        return mat[0][0] * mat[1][1] - mat[0][1] * mat[1][0];
    }
    let mut a = mat.to_vec();
    let mut det = C64::ONE;
    for col in 0..m {
        let mut pivot = col;
        let mut max_norm = a[col][col].norm_sq();
        for row in (col + 1)..m {
            let n = a[row][col].norm_sq();
            if n > max_norm {
                max_norm = n;
                pivot = row;
            }
        }
        if max_norm < 1e-30 {
            return C64::ZERO;
        }
        if pivot != col {
            a.swap(col, pivot);
            det = -det;
        }
        let piv_val = a[col][col];
        det = det * piv_val;
        for row in (col + 1)..m {
            let factor = a[row][col] / piv_val;
            for c in col..m {
                let sub = factor * a[col][c];
                a[row][c] = a[row][c] - sub;
            }
        }
    }
    det
}

/// Computes the permanent $\operatorname{perm}(A)$ of an `m x m` complex matrix via Ryser's
/// $O(2^m m)$ inclusion–exclusion formula (for symmetric Bosonic / Hard-Core Boson pair sectors
/// without Jordan–Wigner $Z$-strings, where $\operatorname{perm}\begin{pmatrix} a & b \\ c & d \end{pmatrix} = a d + b c$).
pub fn complex_permanent(mat: &[Vec<C64>]) -> C64 {
    let m = mat.len();
    if m == 0 {
        return C64::ONE;
    }
    if m == 1 {
        return mat[0][0];
    }
    if m == 2 {
        return mat[0][0] * mat[1][1] + mat[0][1] * mat[1][0];
    }
    let mut total = C64::ZERO;
    for mask in 1usize..(1usize << m) {
        let mut prod = C64::ONE;
        for r in 0..m {
            let mut row_sum = C64::ZERO;
            for c in 0..m {
                if (mask & (1usize << c)) != 0 {
                    row_sum = row_sum + mat[r][c];
                }
            }
            prod = prod * row_sum;
        }
        let subset_size = mask.count_ones() as usize;
        if (m - subset_size) % 2 == 1 {
            total = total - prod;
        } else {
            total = total + prod;
        }
    }
    total
}

/// Evolves a particle-number-conserving $k$-occupied-orbital generator matrix $C \in \mathbb{C}^{k \times n}$
/// on $\mathrm{Gr}_{\mathbb{C}}(k, n)$ under Givens / Plabic VRC pair rotations `(p, q, theta)`
/// and extracts the normalized $\binom{n}{k}$ Cauchy–Binet Plücker coordinates mapped to MSB basis indices.
/// When `fermionic_jw_sign` is `true`, evaluates the antisymmetric Slater determinant $\det C[:, I]$
/// (including the Jordan–Wigner Koszul sign $(-1)^{\mathrm{inv}}$ when hopping across occupied orbitals);
/// when `false`, evaluates the symmetric Hard-Core Boson permanent $\operatorname{perm} C[:, I]$.
pub fn simulate_grassmann_plucker_sector_with_statistics(
    n_occ: usize,
    n_orb: usize,
    rotations: &[(usize, usize, f64)],
    fermionic_jw_sign: bool,
) -> Vec<(usize, C64)> {
    if n_occ == 0 || n_occ > n_orb {
        return vec![(0, C64::ONE)];
    }
    // Initialize reference occupied subspace C = [I_{n_occ} | 0]
    let mut c_mat = vec![vec![C64::ZERO; n_orb]; n_occ];
    for i in 0..n_occ {
        c_mat[i][i] = C64::ONE;
    }
    // Apply unitary orbital/HCB pair rotations on columns (p, q)
    for &(p, q, angle) in rotations {
        if p >= n_orb || q >= n_orb || p == q {
            continue;
        }
        let half = 0.5 * angle;
        let cos_h = C64::new(half.cos(), 0.0);
        let sin_h = C64::new(half.sin(), 0.0);
        for row in 0..n_occ {
            let cp = c_mat[row][p];
            let cq = c_mat[row][q];
            // Matches Tequila HCB Ry(angle) + CNOT excitation convention:
            // |10> -> cos(theta/2)|10> + sin(theta/2)|01>
            c_mat[row][p] = cos_h * cp - sin_h * cq;
            c_mat[row][q] = sin_h * cp + cos_h * cq;
        }
    }

    // Enumerate all Hamming-weight-n_occ subsets of {0, ..., n_orb - 1} in O(C(n_orb, n_occ))
    // using Gosper's combinatorial bit-hack (scales to n_orb <= 62 without 2^n_orb iteration!)
    let mut plucker_states = Vec::with_capacity(grassmann_plucker_sector_dim(n_occ, n_orb));
    let mut norm_sq = 0.0;
    let limit = 1usize << n_orb;
    let mut basis_idx = (1usize << n_occ) - 1;
    let mut cols = vec![0usize; n_occ];
    let mut sub = vec![vec![C64::ZERO; n_occ]; n_occ];
    while basis_idx < limit {
        let mut c_pos = 0;
        for q in 0..n_orb {
            if bit_at_msb(basis_idx, q, n_orb) == 1 {
                cols[c_pos] = q;
                c_pos += 1;
            }
        }
        for r in 0..n_occ {
            for (c_idx, &col) in cols.iter().enumerate() {
                sub[r][c_idx] = c_mat[r][col];
            }
        }
        let minor = if fermionic_jw_sign {
            complex_det(&sub)
        } else {
            complex_permanent(&sub)
        };
        if minor.norm_sq() > 1e-28 {
            norm_sq += minor.norm_sq();
            plucker_states.push((basis_idx, minor));
        }
        let u = basis_idx & basis_idx.wrapping_neg();
        let v = basis_idx + u;
        basis_idx = v + (((v ^ basis_idx) / u) >> 2);
    }
    plucker_states.sort_unstable_by_key(|&(k, _)| k);
    if norm_sq > 1e-30 {
        let scale = 1.0 / norm_sq.sqrt();
        for (_, amp) in plucker_states.iter_mut() {
            *amp = C64::new(amp.re * scale, amp.im * scale);
        }
    }
    plucker_states
}

/// Evolves a particle-number-conserving $k$-occupied-orbital generator matrix $C \in \mathbb{C}^{k \times n}$
/// on $\mathrm{Gr}_{\mathbb{C}}(k, n)$ under Givens / Plabic VRC pair rotations `(p, q, theta)`
/// and extracts the normalized $\binom{n}{k}$ Cauchy–Binet Plücker coordinates mapped to MSB basis indices.
pub fn simulate_grassmann_plucker_hcb_sector(
    n_occ: usize,
    n_orb: usize,
    rotations: &[(usize, usize, f64)],
) -> Vec<(usize, C64)> {
    simulate_grassmann_plucker_sector_with_statistics(n_occ, n_orb, rotations, true)
}

/// Evolves a noisy density matrix $\rho \in \mathbb{C}^{2^n \times 2^n}$ under `gates`,
/// per-qubit Kraus noise channels `(noise_kind, target_qubit, prob)`, and `mcweeny_passes`
/// of McWeeny cubic idempotency purification $\rho \leftarrow \frac{3\rho^2 - 2\rho^3}{\operatorname{Tr}(3\rho^2 - 2\rho^3)}$.
pub fn simulate_noisy_density_msb(
    n_qubits: usize,
    gates: &[TequilaGateOp],
    noise_channels: &[(String, usize, f64)],
    mcweeny_passes: usize,
) -> Vec<C64> {
    let dim = 1usize << n_qubits;
    let psi = simulate_circuit_msb(n_qubits, &[], gates);
    let mut rho = vec![C64::ZERO; dim * dim];
    for i in 0..dim {
        for j in 0..dim {
            rho[i * dim + j] = psi[i] * psi[j].conj();
        }
    }

    // Apply single-qubit Kraus noise channels
    for (kind, qubit, prob) in noise_channels {
        let p = prob.clamp(0.0, 1.0);
        if p <= 0.0 || *qubit >= n_qubits {
            continue;
        }
        let prev = rho.clone();
        let bit_mask = 1usize << (n_qubits - 1 - *qubit);
        let lower = kind.to_lowercase();
        if lower.contains("bit flip") {
            for i in 0..dim {
                let i_flip = i ^ bit_mask;
                for j in 0..dim {
                    let j_flip = j ^ bit_mask;
                    rho[i * dim + j] = C64::new(1.0 - p, 0.0) * prev[i * dim + j]
                        + C64::new(p, 0.0) * prev[i_flip * dim + j_flip];
                }
            }
        } else if lower.contains("phase flip") || lower.contains("phase damp") {
            for i in 0..dim {
                let bi = (i & bit_mask) != 0;
                for j in 0..dim {
                    let bj = (j & bit_mask) != 0;
                    let z_sign = if bi == bj { 1.0 } else { -1.0 };
                    rho[i * dim + j] =
                        C64::new((1.0 - p) + p * z_sign, 0.0) * prev[i * dim + j];
                }
            }
        } else if lower.contains("depolarizing") {
            // (1 - p) rho + (p / 3) (X rho X + Y rho Y + Z rho Z)
            let p3 = p / 3.0;
            for i in 0..dim {
                let i_flip = i ^ bit_mask;
                let bi = (i & bit_mask) != 0;
                for j in 0..dim {
                    let j_flip = j ^ bit_mask;
                    let bj = (j & bit_mask) != 0;
                    let sign_same = if bi == bj { 1.0 } else { -1.0 };
                    let x_term = prev[i_flip * dim + j_flip];
                    let y_term = C64::new(sign_same, 0.0) * prev[i_flip * dim + j_flip];
                    let z_term = C64::new(sign_same, 0.0) * prev[i * dim + j];
                    rho[i * dim + j] = C64::new(1.0 - p, 0.0) * prev[i * dim + j]
                        + C64::new(p3, 0.0) * (x_term + y_term + z_term);
                }
            }
        } else if lower.contains("amplitude damp") {
            // K0 = [[1, 0], [0, sqrt(1-p)]], K1 = [[0, sqrt(p)], [0, 0]]
            let s1mp = (1.0 - p).sqrt();
            for i in 0..dim {
                let bi = (i & bit_mask) != 0;
                for j in 0..dim {
                    let bj = (j & bit_mask) != 0;
                    let k0_factor = match (bi, bj) {
                        (false, false) => 1.0,
                        (true, true) => 1.0 - p,
                        _ => s1mp,
                    };
                    let mut val = C64::new(k0_factor, 0.0) * prev[i * dim + j];
                    if !bi && !bj {
                        let i1 = i | bit_mask;
                        let j1 = j | bit_mask;
                        val = val + C64::new(p, 0.0) * prev[i1 * dim + j1];
                    }
                    rho[i * dim + j] = val;
                }
            }
        }
    }

    if mcweeny_passes > 0 {
        rho = mcweeny_purify_density_matrix(&rho, dim, mcweeny_passes);
        let mut tr = 0.0;
        for i in 0..dim {
            tr += rho[i * dim + i].re;
        }
        if tr > 1e-15 {
            let inv_tr = 1.0 / tr;
            for entry in rho.iter_mut() {
                *entry = C64::new(entry.re * inv_tr, entry.im * inv_tr);
            }
        }
    }

    rho
}

#[cfg(feature = "python")]
fn parse_py_gates(gates_list: &Bound<'_, PyList>) -> PyResult<Vec<TequilaGateOp>> {
    let mut ops = Vec::with_capacity(gates_list.len());
    for item in gates_list.iter() {
        let d = item.downcast::<PyDict>()?;
        let kind: String = d
            .get_item("kind")?
            .map(|v| v.extract())
            .transpose()?
            .unwrap_or_else(|| "basic".to_string());
        match kind.as_str() {
            "basic" => {
                let name: String = d.get_item("name")?.unwrap().extract()?;
                let targets: Vec<usize> = d.get_item("targets")?.unwrap().extract()?;
                let controls: Vec<usize> = d
                    .get_item("controls")?
                    .map(|v| v.extract())
                    .transpose()?
                    .unwrap_or_default();
                ops.push(TequilaGateOp::Basic {
                    name,
                    targets,
                    controls,
                });
            }
            "swap" => {
                let targets: Vec<usize> = d.get_item("targets")?.unwrap().extract()?;
                let controls: Vec<usize> = d
                    .get_item("controls")?
                    .map(|v| v.extract())
                    .transpose()?
                    .unwrap_or_default();
                if targets.len() >= 2 {
                    ops.push(TequilaGateOp::Swap {
                        q0: targets[0],
                        q1: targets[1],
                        controls,
                    });
                }
            }
            "rotation" => {
                let axis: String = d.get_item("axis")?.unwrap().extract()?;
                let angle: f64 = d.get_item("angle")?.unwrap().extract()?;
                let targets: Vec<usize> = d.get_item("targets")?.unwrap().extract()?;
                let controls: Vec<usize> = d
                    .get_item("controls")?
                    .map(|v| v.extract())
                    .transpose()?
                    .unwrap_or_default();
                ops.push(TequilaGateOp::Rotation {
                    axis,
                    angle,
                    targets,
                    controls,
                });
            }
            "exp_pauli" => {
                let raw_paulis: Vec<(usize, String)> = d.get_item("paulis")?.unwrap().extract()?;
                let paulis = raw_paulis
                    .into_iter()
                    .map(|(q, s)| (q, s.chars().next().unwrap_or('I')))
                    .collect();
                let angle: f64 = d.get_item("angle")?.unwrap().extract()?;
                let controls: Vec<usize> = d
                    .get_item("controls")?
                    .map(|v| v.extract())
                    .transpose()?
                    .unwrap_or_default();
                ops.push(TequilaGateOp::ExpPauli {
                    paulis,
                    angle,
                    controls,
                });
            }
            "causal_do" => {
                let qubit: usize = d.get_item("qubit")?.unwrap().extract()?;
                let bit_value: u8 = d.get_item("bit_value")?.unwrap().extract()?;
                ops.push(TequilaGateOp::CausalDo { qubit, bit_value });
            }
            _ => {}
        }
    }
    Ok(ops)
}

#[cfg(feature = "python")]
#[pyfunction]
pub fn py_simulate_circuit_msb(
    n_qubits: usize,
    gates_list: &Bound<'_, PyList>,
    initial_state_re_im: Option<Vec<(f64, f64)>>,
) -> PyResult<Vec<(f64, f64)>> {
    let ops = parse_py_gates(gates_list)?;
    let init: Vec<C64> = initial_state_re_im
        .unwrap_or_default()
        .into_iter()
        .map(|(re, im)| C64::new(re, im))
        .collect();
    let final_state = simulate_circuit_msb(n_qubits, &init, &ops);
    Ok(final_state.into_iter().map(|c| (c.re, c.im)).collect())
}

#[cfg(feature = "python")]
#[pyfunction]
pub fn py_expectation_pauli_hamiltonian_msb(
    n_qubits: usize,
    bra_re_im: Vec<(f64, f64)>,
    ket_re_im: Vec<(f64, f64)>,
    hamiltonian_terms: Vec<(f64, f64, Vec<(usize, String)>)>,
) -> PyResult<(f64, f64)> {
    let bra: Vec<C64> = bra_re_im
        .into_iter()
        .map(|(r, i)| C64::new(r, i))
        .collect();
    let ket: Vec<C64> = ket_re_im
        .into_iter()
        .map(|(r, i)| C64::new(r, i))
        .collect();
    let terms: Vec<PauliTerm> = hamiltonian_terms
        .into_iter()
        .map(|(cr, ci, ops)| PauliTerm {
            coeff_re: cr,
            coeff_im: ci,
            ops: ops
                .into_iter()
                .map(|(q, s)| (q, s.chars().next().unwrap_or('I')))
                .collect(),
        })
        .collect();
    let val = expectation_pauli_hamiltonian_msb(n_qubits, &bra, &ket, &terms);
    Ok((val.re, val.im))
}

#[cfg(feature = "python")]
#[pyfunction]
pub fn py_sample_statevector_msb(
    state_re_im: Vec<(f64, f64)>,
    samples: usize,
    seed: u64,
) -> PyResult<Vec<(usize, usize)>> {
    let state: Vec<C64> = state_re_im
        .into_iter()
        .map(|(r, i)| C64::new(r, i))
        .collect();
    Ok(sample_statevector_msb(&state, samples, seed))
}

#[cfg(feature = "python")]
#[pyfunction]
pub fn py_mcweeny_purify_density_matrix(
    rho_re_im: Vec<(f64, f64)>,
    dim: usize,
    iterations: usize,
) -> PyResult<Vec<(f64, f64)>> {
    let rho: Vec<C64> = rho_re_im
        .into_iter()
        .map(|(r, i)| C64::new(r, i))
        .collect();
    let purified = mcweeny_purify_density_matrix(&rho, dim, iterations);
    Ok(purified.into_iter().map(|c| (c.re, c.im)).collect())
}

#[cfg(feature = "python")]
#[pyfunction]
pub fn py_analyze_grassmann_qci_state<'py>(
    py: Python<'py>,
    n_qubits: usize,
    state_re_im: Vec<(f64, f64)>,
    soft_evidence_q: f64,
    prior_p: f64,
) -> PyResult<Bound<'py, PyDict>> {
    let state: Vec<C64> = state_re_im
        .into_iter()
        .map(|(r, i)| C64::new(r, i))
        .collect();
    let diag = analyze_grassmann_qci_state(n_qubits, &state, soft_evidence_q, prior_p);
    let dict = PyDict::new(py);
    dict.set_item("kahler_det_factor", diag.kahler_det_factor)?;
    dict.set_item("plucker_relation_residual", diag.plucker_relation_residual)?;
    dict.set_item("vrc_orthogonality_residual", diag.vrc_orthogonality_residual)?;
    dict.set_item("one_rdm_linear_entropy", diag.one_rdm_linear_entropy)?;
    dict.set_item("qci_spin_mutual_info", diag.qci_spin_mutual_info)?;
    dict.set_item(
        "madelung_bohm_regularized_trace",
        diag.madelung_bohm_regularized_trace,
    )?;
    dict.set_item("jeffrey_posterior_prob", diag.jeffrey_posterior_prob)?;
    dict.set_item("mermin_ghz_witness", diag.mermin_ghz_witness)?;
    dict.set_item(
        "cayley_unitarity_norm_sq",
        cayley_retraction_eigenvalue_norm_sq(0.75),
    )?;
    dict.set_item("mcweeny_090", mcweeny_purification_poly(0.90))?;
    dict.set_item(
        "cev_vs_jev_deconfounded",
        cev_causal_do_expected_utility(0.6, 0.4, 1.0, -1.0)
            - jev_evidential_expected_utility(0.75, 0.25, 1.0, -1.0),
    )?;
    dict.set_item(
        "diaconis_zabell_log_odds",
        diaconis_zabell_log_odds_update(0.0, 1.0, 0.5),
    )?;
    Ok(dict)
}

#[cfg(feature = "python")]
#[pyfunction]
#[pyo3(signature = (n_occ, n_orb, rotations, fermionic_jw_sign=true))]
pub fn py_simulate_grassmann_plucker_hcb(
    n_occ: usize,
    n_orb: usize,
    rotations: Vec<(usize, usize, f64)>,
    fermionic_jw_sign: bool,
) -> PyResult<Vec<(usize, f64, f64)>> {
    let states = simulate_grassmann_plucker_sector_with_statistics(
        n_occ,
        n_orb,
        &rotations,
        fermionic_jw_sign,
    );
    Ok(states
        .into_iter()
        .map(|(idx, c)| (idx, c.re, c.im))
        .collect())
}

#[cfg(feature = "python")]
#[pyfunction]
pub fn py_simulate_noisy_density_msb(
    n_qubits: usize,
    gates_list: &Bound<'_, PyList>,
    noise_channels: Vec<(String, usize, f64)>,
    mcweeny_passes: usize,
) -> PyResult<Vec<(f64, f64)>> {
    let ops = parse_py_gates(gates_list)?;
    let rho = simulate_noisy_density_msb(n_qubits, &ops, &noise_channels, mcweeny_passes);
    Ok(rho.into_iter().map(|c| (c.re, c.im)).collect())
}

/// Precompiled low-overhead `Copy` instruction for `RustFastCircuit`.
#[derive(Clone, Copy, Debug)]
pub enum FastGateInst {
    PauliX {
        target: usize,
        ctrl_mask: usize,
        ctrl_mask_128: u128,
    },
    PauliY {
        target: usize,
        ctrl_mask: usize,
        ctrl_mask_128: u128,
    },
    PauliZ {
        target: usize,
        ctrl_mask: usize,
        ctrl_mask_128: u128,
    },
    Hadamard {
        target: usize,
        ctrl_mask: usize,
        ctrl_mask_128: u128,
    },
    PhaseS {
        target: usize,
        ctrl_mask: usize,
        ctrl_mask_128: u128,
    },
    PhaseT {
        target: usize,
        ctrl_mask: usize,
        ctrl_mask_128: u128,
    },
    Swap {
        swap_mask: usize,
        m1: usize,
        ctrl_mask: usize,
        swap_mask_128: u128,
        m1_128: u128,
        ctrl_mask_128: u128,
    },
    RotX {
        target: usize,
        ctrl_mask: usize,
        ctrl_mask_128: u128,
        fixed_angle: f64,
        param_idx: Option<usize>,
    },
    RotY {
        target: usize,
        ctrl_mask: usize,
        ctrl_mask_128: u128,
        fixed_angle: f64,
        param_idx: Option<usize>,
    },
    RotZ {
        target: usize,
        ctrl_mask: usize,
        ctrl_mask_128: u128,
        fixed_angle: f64,
        param_idx: Option<usize>,
    },
    Phase {
        target: usize,
        ctrl_mask: usize,
        ctrl_mask_128: u128,
        fixed_angle: f64,
        param_idx: Option<usize>,
    },
    ExpPauli {
        compiled: CompiledPauliString,
        ctrl_mask: usize,
        ctrl_mask_128: u128,
        fixed_angle: f64,
        param_idx: Option<usize>,
    },
    CausalDo {
        qubit: usize,
        bit_value: u8,
    },
}

/// Executes a precompiled `FastGateInst` slice on `state` with dynamic parameter array `angles`.
pub fn execute_fast_instructions_msb(
    n_qubits: usize,
    state: &mut [C64],
    instructions: &[FastGateInst],
    angles: &[f64],
) {
    let dim = 1usize << n_qubits;
    let inv_sqrt2 = C64::new(std::f64::consts::FRAC_1_SQRT_2, 0.0);

    for inst in instructions {
        match inst {
            FastGateInst::PauliX {
                target, ctrl_mask, ..
            } => {
                apply_pauli_x_fast_msb(state, n_qubits, *target, *ctrl_mask);
            }
            FastGateInst::PauliY {
                target, ctrl_mask, ..
            } => {
                apply_single_qubit_unitary_mask_msb(
                    state,
                    n_qubits,
                    *target,
                    *ctrl_mask,
                    C64::ZERO,
                    C64::new(0.0, -1.0),
                    C64::new(0.0, 1.0),
                    C64::ZERO,
                );
            }
            FastGateInst::PauliZ {
                target, ctrl_mask, ..
            } => {
                apply_pauli_z_fast_msb(state, n_qubits, *target, *ctrl_mask);
            }
            FastGateInst::Hadamard {
                target, ctrl_mask, ..
            } => {
                apply_single_qubit_unitary_mask_msb(
                    state,
                    n_qubits,
                    *target,
                    *ctrl_mask,
                    inv_sqrt2,
                    inv_sqrt2,
                    inv_sqrt2,
                    -inv_sqrt2,
                );
            }
            FastGateInst::PhaseS {
                target, ctrl_mask, ..
            } => {
                apply_diagonal_gate_fast_msb(
                    state,
                    n_qubits,
                    *target,
                    *ctrl_mask,
                    C64::ONE,
                    C64::new(0.0, 1.0),
                );
            }
            FastGateInst::PhaseT {
                target, ctrl_mask, ..
            } => {
                apply_diagonal_gate_fast_msb(
                    state,
                    n_qubits,
                    *target,
                    *ctrl_mask,
                    C64::ONE,
                    C64::new(
                        std::f64::consts::FRAC_1_SQRT_2,
                        std::f64::consts::FRAC_1_SQRT_2,
                    ),
                );
            }
            FastGateInst::Swap {
                swap_mask,
                m1,
                ctrl_mask,
                ..
            } => {
                for idx in 0..dim {
                    if (idx & *ctrl_mask) == *ctrl_mask && (idx & *swap_mask) == *m1 {
                        state.swap(idx, idx ^ *swap_mask);
                    }
                }
            }
            FastGateInst::RotX {
                target,
                ctrl_mask,
                fixed_angle,
                param_idx,
                ..
            } => {
                let angle = param_idx.map_or(*fixed_angle, |i| angles[i]);
                if angle.abs() < 1e-15 {
                    continue;
                }
                let half = 0.5 * angle;
                let c = half.cos();
                let s = half.sin();
                apply_single_qubit_unitary_mask_msb(
                    state,
                    n_qubits,
                    *target,
                    *ctrl_mask,
                    C64::new(c, 0.0),
                    C64::new(0.0, -s),
                    C64::new(0.0, -s),
                    C64::new(c, 0.0),
                );
            }
            FastGateInst::RotY {
                target,
                ctrl_mask,
                fixed_angle,
                param_idx,
                ..
            } => {
                let angle = param_idx.map_or(*fixed_angle, |i| angles[i]);
                if angle.abs() < 1e-15 {
                    continue;
                }
                let half = 0.5 * angle;
                let c = half.cos();
                let s = half.sin();
                apply_single_qubit_unitary_mask_msb(
                    state,
                    n_qubits,
                    *target,
                    *ctrl_mask,
                    C64::new(c, 0.0),
                    C64::new(-s, 0.0),
                    C64::new(s, 0.0),
                    C64::new(c, 0.0),
                );
            }
            FastGateInst::RotZ {
                target,
                ctrl_mask,
                fixed_angle,
                param_idx,
                ..
            } => {
                let angle = param_idx.map_or(*fixed_angle, |i| angles[i]);
                if angle.abs() < 1e-15 {
                    continue;
                }
                let half = 0.5 * angle;
                let c = half.cos();
                let s = half.sin();
                apply_diagonal_gate_fast_msb(
                    state,
                    n_qubits,
                    *target,
                    *ctrl_mask,
                    C64::new(c, -s),
                    C64::new(c, s),
                );
            }
            FastGateInst::Phase {
                target,
                ctrl_mask,
                fixed_angle,
                param_idx,
                ..
            } => {
                let angle = param_idx.map_or(*fixed_angle, |i| angles[i]);
                if angle.abs() < 1e-15 {
                    continue;
                }
                apply_diagonal_gate_fast_msb(
                    state,
                    n_qubits,
                    *target,
                    *ctrl_mask,
                    C64::ONE,
                    C64::new(angle.cos(), angle.sin()),
                );
            }
            FastGateInst::ExpPauli {
                compiled,
                ctrl_mask,
                fixed_angle,
                param_idx,
                ..
            } => {
                let angle = param_idx.map_or(*fixed_angle, |i| angles[i]);
                apply_compiled_exp_pauli_msb(state, n_qubits, compiled, angle, *ctrl_mask);
            }
            FastGateInst::CausalDo { qubit, bit_value } => {
                let target_bit = (*bit_value as usize) & 1;
                let mut norm_sq = 0.0;
                for (idx, amp) in state.iter_mut().enumerate() {
                    if bit_at_msb(idx, *qubit, n_qubits) != target_bit {
                        *amp = C64::ZERO;
                    } else {
                        norm_sq += amp.norm_sq();
                    }
                }
                if norm_sq > 1e-15 {
                    let scale = 1.0 / norm_sq.sqrt();
                    for amp in state.iter_mut() {
                        *amp = C64::new(amp.re * scale, amp.im * scale);
                    }
                }
            }
        }
    }
}

#[cfg(feature = "python")]
#[pyclass]
#[derive(Clone, Debug)]
pub struct RustFastHamiltonianSet {
    pub n_qubits: usize,
    pub hamiltonians: Vec<FastCompiledHamiltonian>,
}

#[cfg(feature = "python")]
#[pymethods]
impl RustFastHamiltonianSet {
    #[new]
    pub fn new(
        n_qubits: usize,
        raw_hamiltonians: Vec<Vec<(f64, f64, Vec<(usize, String)>)>>,
    ) -> Self {
        let hamiltonians = raw_hamiltonians
            .iter()
            .map(|h| FastCompiledHamiltonian::from_raw_terms(n_qubits, h))
            .collect();
        Self {
            n_qubits,
            hamiltonians,
        }
    }
}

/// Sorts `next_sp` by 128-bit basis index and merges duplicate basis indices into `out_sp`,
/// pruning amplitudes with `norm_sq() <= 1e-30` (and capping at `max_keep` if exceeded).
#[inline]
pub fn merge_sparse_state(
    next_sp: &mut Vec<(u128, C64)>,
    out_sp: &mut Vec<(u128, C64)>,
    max_keep: usize,
) {
    next_sp.sort_unstable_by_key(|&(k, _)| k);
    out_sp.clear();
    let mut i = 0;
    let len = next_sp.len();
    while i < len {
        let key = next_sp[i].0;
        let mut sum = next_sp[i].1;
        i += 1;
        while i < len && next_sp[i].0 == key {
            sum = sum + next_sp[i].1;
            i += 1;
        }
        if sum.norm_sq() > 1e-30 {
            out_sp.push((key, sum));
        }
    }
    next_sp.clear();
    if out_sp.len() > max_keep {
        out_sp.sort_unstable_by(|a, b| {
            b.1.norm_sq()
                .partial_cmp(&a.1.norm_sq())
                .unwrap_or(std::cmp::Ordering::Equal)
        });
        out_sp.truncate(max_keep);
        let mut norm_sq = 0.0;
        for &(_, amp) in out_sp.iter() {
            norm_sq += amp.norm_sq();
        }
        if norm_sq > 1e-30 {
            let scale = 1.0 / norm_sq.sqrt();
            for (_, amp) in out_sp.iter_mut() {
                *amp = C64::new(amp.re * scale, amp.im * scale);
            }
        }
        out_sp.sort_unstable_by_key(|&(k, _)| k);
    }
}

#[cfg(feature = "python")]
#[pyclass]
#[derive(Clone, Debug)]
pub struct RustFastCircuit {
    pub n_qubits: usize,
    pub instructions: Vec<FastGateInst>,
    pub scratch_state: Vec<C64>,
    pub scratch_sparse: Vec<(u128, C64)>,
    pub scratch_sparse_next: Vec<(u128, C64)>,
    pub last_sparse_support_size: usize,
}

#[cfg(feature = "python")]
impl RustFastCircuit {
    /// Executes instructions starting in the 128-bit sparse Plücker representation `self.scratch_sparse`
    /// (supporting up to $n = 126$ qubits!).
    /// Returns `None` if all instructions completed within `sparse_limit` (so the final state is in
    /// `self.scratch_sparse`), or `Some(handoff_inst_idx)` if a branching gate would exceed `sparse_limit`
    /// and execution should materialize into `self.scratch_state` at `handoff_inst_idx` (for $n \le 28$).
    fn run_sparse_until_handoff(
        &mut self,
        initial_state_idx: u128,
        angles: &[f64],
        allow_dense_handoff: bool,
    ) -> Option<usize> {
        let can_handoff = allow_dense_handoff && self.n_qubits <= 28;
        let sparse_limit = if !can_handoff {
            262_144
        } else if self.n_qubits <= 11 {
            (1usize << self.n_qubits) / 4
        } else {
            ((1usize << self.n_qubits) / 8).min(16_384)
        };

        self.scratch_sparse.clear();
        self.scratch_sparse.push((initial_state_idx, C64::ONE));
        self.scratch_sparse_next.clear();

        let inv_sqrt2 = C64::new(std::f64::consts::FRAC_1_SQRT_2, 0.0);

        for (inst_idx, inst) in self.instructions.iter().enumerate() {
            match inst {
                FastGateInst::PauliX {
                    target,
                    ctrl_mask_128,
                    ..
                } => {
                    let t_mask = 1u128 << (self.n_qubits - 1 - *target);
                    let c_mask = *ctrl_mask_128;
                    for (idx, _) in self.scratch_sparse.iter_mut() {
                        if (*idx & c_mask) == c_mask {
                            *idx ^= t_mask;
                        }
                    }
                    self.scratch_sparse.sort_unstable_by_key(|&(k, _)| k);
                }
                FastGateInst::PauliZ {
                    target,
                    ctrl_mask_128,
                    ..
                } => {
                    let t_mask = 1u128 << (self.n_qubits - 1 - *target);
                    let c_mask = *ctrl_mask_128;
                    for (idx, amp) in self.scratch_sparse.iter_mut() {
                        if (*idx & c_mask) == c_mask && (*idx & t_mask) != 0 {
                            *amp = -*amp;
                        }
                    }
                }
                FastGateInst::PhaseS {
                    target,
                    ctrl_mask_128,
                    ..
                } => {
                    let t_mask = 1u128 << (self.n_qubits - 1 - *target);
                    let c_mask = *ctrl_mask_128;
                    let i_unit = C64::new(0.0, 1.0);
                    for (idx, amp) in self.scratch_sparse.iter_mut() {
                        if (*idx & c_mask) == c_mask && (*idx & t_mask) != 0 {
                            *amp = i_unit * (*amp);
                        }
                    }
                }
                FastGateInst::PhaseT {
                    target,
                    ctrl_mask_128,
                    ..
                } => {
                    let t_mask = 1u128 << (self.n_qubits - 1 - *target);
                    let c_mask = *ctrl_mask_128;
                    let t_unit = C64::new(
                        std::f64::consts::FRAC_1_SQRT_2,
                        std::f64::consts::FRAC_1_SQRT_2,
                    );
                    for (idx, amp) in self.scratch_sparse.iter_mut() {
                        if (*idx & c_mask) == c_mask && (*idx & t_mask) != 0 {
                            *amp = t_unit * (*amp);
                        }
                    }
                }
                FastGateInst::Swap {
                    swap_mask_128,
                    m1_128,
                    ctrl_mask_128,
                    ..
                } => {
                    let s_mask = *swap_mask_128;
                    let m0 = s_mask ^ *m1_128;
                    let c_mask = *ctrl_mask_128;
                    for (idx, _) in self.scratch_sparse.iter_mut() {
                        if (*idx & c_mask) == c_mask {
                            let bits = *idx & s_mask;
                            if bits == *m1_128 || bits == m0 {
                                *idx ^= s_mask;
                            }
                        }
                    }
                    self.scratch_sparse.sort_unstable_by_key(|&(k, _)| k);
                }
                FastGateInst::RotZ {
                    target,
                    ctrl_mask_128,
                    fixed_angle,
                    param_idx,
                    ..
                } => {
                    let angle = param_idx.map_or(*fixed_angle, |i| angles[i]);
                    if angle.abs() < 1e-15 {
                        continue;
                    }
                    let half = 0.5 * angle;
                    let u00 = C64::new(half.cos(), -half.sin());
                    let u11 = C64::new(half.cos(), half.sin());
                    let t_mask = 1u128 << (self.n_qubits - 1 - *target);
                    let c_mask = *ctrl_mask_128;
                    for (idx, amp) in self.scratch_sparse.iter_mut() {
                        if (*idx & c_mask) == c_mask {
                            *amp = if (*idx & t_mask) == 0 {
                                u00 * (*amp)
                            } else {
                                u11 * (*amp)
                            };
                        }
                    }
                }
                FastGateInst::Phase {
                    target,
                    ctrl_mask_128,
                    fixed_angle,
                    param_idx,
                    ..
                } => {
                    let angle = param_idx.map_or(*fixed_angle, |i| angles[i]);
                    if angle.abs() < 1e-15 {
                        continue;
                    }
                    let u11 = C64::new(angle.cos(), angle.sin());
                    let t_mask = 1u128 << (self.n_qubits - 1 - *target);
                    let c_mask = *ctrl_mask_128;
                    for (idx, amp) in self.scratch_sparse.iter_mut() {
                        if (*idx & c_mask) == c_mask && (*idx & t_mask) != 0 {
                            *amp = u11 * (*amp);
                        }
                    }
                }
                FastGateInst::PauliY {
                    target,
                    ctrl_mask_128,
                    ..
                } => {
                    let t_mask = 1u128 << (self.n_qubits - 1 - *target);
                    let c_mask = *ctrl_mask_128;
                    let neg_i = C64::new(0.0, -1.0);
                    let pos_i = C64::new(0.0, 1.0);
                    for (idx, amp) in self.scratch_sparse.iter_mut() {
                        if (*idx & c_mask) == c_mask {
                            let was_one = (*idx & t_mask) != 0;
                            *idx ^= t_mask;
                            *amp = if was_one {
                                neg_i * (*amp)
                            } else {
                                pos_i * (*amp)
                            };
                        }
                    }
                    self.scratch_sparse.sort_unstable_by_key(|&(k, _)| k);
                }
                FastGateInst::Hadamard {
                    target,
                    ctrl_mask_128,
                    ..
                } => {
                    if can_handoff && self.scratch_sparse.len() * 2 > sparse_limit {
                        return Some(inst_idx);
                    }
                    let t_mask = 1u128 << (self.n_qubits - 1 - *target);
                    let c_mask = *ctrl_mask_128;
                    self.scratch_sparse_next.clear();
                    for &(idx, amp) in &self.scratch_sparse {
                        if (idx & c_mask) != c_mask {
                            self.scratch_sparse_next.push((idx, amp));
                        } else if (idx & t_mask) == 0 {
                            let scaled = inv_sqrt2 * amp;
                            self.scratch_sparse_next.push((idx, scaled));
                            self.scratch_sparse_next.push((idx | t_mask, scaled));
                        } else {
                            let scaled = inv_sqrt2 * amp;
                            self.scratch_sparse_next.push((idx ^ t_mask, scaled));
                            self.scratch_sparse_next.push((idx, -scaled));
                        }
                    }
                    merge_sparse_state(
                        &mut self.scratch_sparse_next,
                        &mut self.scratch_sparse,
                        sparse_limit,
                    );
                }
                FastGateInst::RotX {
                    target,
                    ctrl_mask_128,
                    fixed_angle,
                    param_idx,
                    ..
                } => {
                    let angle = param_idx.map_or(*fixed_angle, |i| angles[i]);
                    if angle.abs() < 1e-15 {
                        continue;
                    }
                    if can_handoff && self.scratch_sparse.len() * 2 > sparse_limit {
                        return Some(inst_idx);
                    }
                    let half = 0.5 * angle;
                    let c = C64::new(half.cos(), 0.0);
                    let neg_is = C64::new(0.0, -half.sin());
                    let t_mask = 1u128 << (self.n_qubits - 1 - *target);
                    let c_mask = *ctrl_mask_128;
                    self.scratch_sparse_next.clear();
                    for &(idx, amp) in &self.scratch_sparse {
                        if (idx & c_mask) != c_mask {
                            self.scratch_sparse_next.push((idx, amp));
                        } else {
                            self.scratch_sparse_next.push((idx, c * amp));
                            self.scratch_sparse_next.push((idx ^ t_mask, neg_is * amp));
                        }
                    }
                    merge_sparse_state(
                        &mut self.scratch_sparse_next,
                        &mut self.scratch_sparse,
                        sparse_limit,
                    );
                }
                FastGateInst::RotY {
                    target,
                    ctrl_mask_128,
                    fixed_angle,
                    param_idx,
                    ..
                } => {
                    let angle = param_idx.map_or(*fixed_angle, |i| angles[i]);
                    if angle.abs() < 1e-15 {
                        continue;
                    }
                    if can_handoff && self.scratch_sparse.len() * 2 > sparse_limit {
                        return Some(inst_idx);
                    }
                    let half = 0.5 * angle;
                    let c = C64::new(half.cos(), 0.0);
                    let s = C64::new(half.sin(), 0.0);
                    let t_mask = 1u128 << (self.n_qubits - 1 - *target);
                    let c_mask = *ctrl_mask_128;
                    self.scratch_sparse_next.clear();
                    for &(idx, amp) in &self.scratch_sparse {
                        if (idx & c_mask) != c_mask {
                            self.scratch_sparse_next.push((idx, amp));
                        } else if (idx & t_mask) == 0 {
                            self.scratch_sparse_next.push((idx, c * amp));
                            self.scratch_sparse_next.push((idx | t_mask, s * amp));
                        } else {
                            self.scratch_sparse_next.push((idx ^ t_mask, -s * amp));
                            self.scratch_sparse_next.push((idx, c * amp));
                        }
                    }
                    merge_sparse_state(
                        &mut self.scratch_sparse_next,
                        &mut self.scratch_sparse,
                        sparse_limit,
                    );
                }
                FastGateInst::CausalDo { qubit, bit_value } => {
                    let t_mask = 1u128 << (self.n_qubits - 1 - *qubit);
                    let want_one = (*bit_value & 1) != 0;
                    self.scratch_sparse
                        .retain(|&(idx, _)| ((idx & t_mask) != 0) == want_one);
                    let mut norm_sq = 0.0;
                    for &(_, amp) in &self.scratch_sparse {
                        norm_sq += amp.norm_sq();
                    }
                    if norm_sq > 1e-15 {
                        let scale = 1.0 / norm_sq.sqrt();
                        for (_, amp) in self.scratch_sparse.iter_mut() {
                            *amp = C64::new(amp.re * scale, amp.im * scale);
                        }
                    }
                }
                FastGateInst::ExpPauli {
                    compiled,
                    ctrl_mask_128,
                    fixed_angle,
                    param_idx,
                    ..
                } => {
                    let angle = param_idx.map_or(*fixed_angle, |i| angles[i]);
                    if angle.abs() < 1e-15 {
                        continue;
                    }
                    let half = 0.5 * angle;
                    let c_mask = *ctrl_mask_128;
                    if compiled.xy_mask_128 == 0 {
                        let diag_plus = C64::new(half.cos(), -half.sin()) * compiled.y_phase;
                        let diag_minus = C64::new(half.cos(), half.sin()) * compiled.y_phase;
                        let z_mask = compiled.z_mask_128;
                        for (idx, amp) in self.scratch_sparse.iter_mut() {
                            if (*idx & c_mask) == c_mask {
                                let neg = ((*idx & z_mask).count_ones() & 1) != 0;
                                *amp = if neg {
                                    diag_minus * (*amp)
                                } else {
                                    diag_plus * (*amp)
                                };
                            }
                        }
                    } else {
                        if can_handoff && self.scratch_sparse.len() * 2 > sparse_limit {
                            return Some(inst_idx);
                        }
                        let cos_h = C64::new(half.cos(), 0.0);
                        let minus_i_sin_h = C64::new(0.0, -half.sin());
                        let xy_mask = compiled.xy_mask_128;
                        let z_mask = compiled.z_mask_128;
                        let y_phase = compiled.y_phase;
                        self.scratch_sparse_next.clear();
                        for &(idx, amp) in &self.scratch_sparse {
                            if (idx & c_mask) != c_mask {
                                self.scratch_sparse_next.push((idx, amp));
                            } else {
                                let partner = idx ^ xy_mask;
                                let neg = ((idx & z_mask).count_ones() & 1) != 0;
                                let phase = if neg { -y_phase } else { y_phase };
                                self.scratch_sparse_next.push((idx, cos_h * amp));
                                self.scratch_sparse_next
                                    .push((partner, (minus_i_sin_h * phase) * amp));
                            }
                        }
                        merge_sparse_state(
                            &mut self.scratch_sparse_next,
                            &mut self.scratch_sparse,
                            sparse_limit,
                        );
                    }
                }
            }
        }
        None
    }

    fn materialize_sparse_into_dense(&mut self) {
        let dim = 1usize << self.n_qubits;
        if self.scratch_state.len() != dim {
            self.scratch_state.resize(dim, C64::ZERO);
        } else if self.n_qubits >= 15 {
            use rayon::prelude::*;
            self.scratch_state.par_chunks_mut(8192).for_each(|c| {
                c.fill(C64::ZERO);
            });
        } else {
            self.scratch_state.fill(C64::ZERO);
        }
        for &(idx, amp) in &self.scratch_sparse {
            let u_idx = idx as usize;
            if u_idx < dim {
                self.scratch_state[u_idx] = amp;
            }
        }
    }
}

#[cfg(feature = "python")]
#[pymethods]
impl RustFastCircuit {
    #[new]
    pub fn new(n_qubits: usize) -> Self {
        Self {
            n_qubits,
            instructions: Vec::new(),
            scratch_state: Vec::new(),
            scratch_sparse: Vec::with_capacity(256),
            scratch_sparse_next: Vec::with_capacity(512),
            last_sparse_support_size: 0,
        }
    }

    pub fn last_support_size(&self) -> usize {
        self.last_sparse_support_size
    }

    pub fn add_basic(&mut self, name: &str, targets: Vec<usize>, controls: Vec<usize>) {
        let ctrl_mask = controls_mask_msb(&controls, self.n_qubits);
        let ctrl_mask_128 = controls_mask_msb_128(&controls, self.n_qubits);
        let upper = name.to_uppercase();
        for t in targets {
            match upper.as_str() {
                "X" | "CNOT" | "CX" | "NOT" => {
                    self.instructions.push(FastGateInst::PauliX {
                        target: t,
                        ctrl_mask,
                        ctrl_mask_128,
                    });
                }
                "Y" | "CY" => {
                    self.instructions.push(FastGateInst::PauliY {
                        target: t,
                        ctrl_mask,
                        ctrl_mask_128,
                    });
                }
                "Z" | "CZ" => {
                    self.instructions.push(FastGateInst::PauliZ {
                        target: t,
                        ctrl_mask,
                        ctrl_mask_128,
                    });
                }
                "H" | "HADAMARD" | "CH" => {
                    self.instructions.push(FastGateInst::Hadamard {
                        target: t,
                        ctrl_mask,
                        ctrl_mask_128,
                    });
                }
                "S" => {
                    self.instructions.push(FastGateInst::PhaseS {
                        target: t,
                        ctrl_mask,
                        ctrl_mask_128,
                    });
                }
                "T" => {
                    self.instructions.push(FastGateInst::PhaseT {
                        target: t,
                        ctrl_mask,
                        ctrl_mask_128,
                    });
                }
                _ => {}
            }
        }
    }

    pub fn add_swap(&mut self, q0: usize, q1: usize, controls: Vec<usize>) {
        let ctrl_mask = controls_mask_msb(&controls, self.n_qubits);
        let ctrl_mask_128 = controls_mask_msb_128(&controls, self.n_qubits);
        let s0 = self.n_qubits.saturating_sub(1 + q0);
        let s1 = self.n_qubits.saturating_sub(1 + q1);
        let m0 = if s0 < 64 { 1usize << s0 } else { 0 };
        let m1 = if s1 < 64 { 1usize << s1 } else { 0 };
        let m0_128 = if s0 < 128 { 1u128 << s0 } else { 0 };
        let m1_128 = if s1 < 128 { 1u128 << s1 } else { 0 };
        self.instructions.push(FastGateInst::Swap {
            swap_mask: m0 | m1,
            m1,
            ctrl_mask,
            swap_mask_128: m0_128 | m1_128,
            m1_128,
            ctrl_mask_128,
        });
    }

    pub fn add_rotation(
        &mut self,
        axis: &str,
        targets: Vec<usize>,
        controls: Vec<usize>,
        fixed_angle: f64,
        param_idx: Option<usize>,
    ) {
        let ctrl_mask = controls_mask_msb(&controls, self.n_qubits);
        let ctrl_mask_128 = controls_mask_msb_128(&controls, self.n_qubits);
        let upper = axis.to_uppercase();
        for t in targets {
            match upper.as_str() {
                "X" | "RX" | "CRX" => {
                    self.instructions.push(FastGateInst::RotX {
                        target: t,
                        ctrl_mask,
                        ctrl_mask_128,
                        fixed_angle,
                        param_idx,
                    });
                }
                "Y" | "RY" | "CRY" => {
                    self.instructions.push(FastGateInst::RotY {
                        target: t,
                        ctrl_mask,
                        ctrl_mask_128,
                        fixed_angle,
                        param_idx,
                    });
                }
                "Z" | "RZ" | "CRZ" => {
                    self.instructions.push(FastGateInst::RotZ {
                        target: t,
                        ctrl_mask,
                        ctrl_mask_128,
                        fixed_angle,
                        param_idx,
                    });
                }
                "PHASE" | "P" | "CP" => {
                    self.instructions.push(FastGateInst::Phase {
                        target: t,
                        ctrl_mask,
                        ctrl_mask_128,
                        fixed_angle,
                        param_idx,
                    });
                }
                _ => {}
            }
        }
    }

    pub fn add_exp_pauli(
        &mut self,
        raw_paulis: Vec<(usize, String)>,
        controls: Vec<usize>,
        fixed_angle: f64,
        param_idx: Option<usize>,
    ) {
        let char_ops: Vec<(usize, char)> = raw_paulis
            .into_iter()
            .map(|(q, s)| (q, s.chars().next().unwrap_or('I')))
            .collect();
        let compiled = CompiledPauliString::from_ops(&char_ops, self.n_qubits);
        let ctrl_mask = controls_mask_msb(&controls, self.n_qubits);
        let ctrl_mask_128 = controls_mask_msb_128(&controls, self.n_qubits);
        self.instructions.push(FastGateInst::ExpPauli {
            compiled,
            ctrl_mask,
            ctrl_mask_128,
            fixed_angle,
            param_idx,
        });
    }

    pub fn add_causal_do(&mut self, qubit: usize, bit_value: u8) {
        self.instructions.push(FastGateInst::CausalDo {
            qubit,
            bit_value: bit_value & 1,
        });
    }

    /// Simulates the circuit in 128-bit sparse Plücker mode (up to $n \le 126$ qubits) and returns
    /// `(basis_idx, re, im)` triples.
    pub fn simulate_sparse_plucker(
        &mut self,
        angles: Vec<f64>,
        initial_state_idx: u128,
    ) -> Vec<(u128, f64, f64)> {
        let _ = self.run_sparse_until_handoff(initial_state_idx, &angles, false);
        self.last_sparse_support_size = self.scratch_sparse.len();
        self.scratch_sparse
            .iter()
            .map(|&(idx, c)| (idx, c.re, c.im))
            .collect()
    }

    /// Simulates the circuit and returns a flat `[re_0, im_0, re_1, im_1, ...]` `Vec<f64>`
    /// for zero-loop conversion via `np.asarray(..., dtype=np.float64).view(np.complex128)`.
    pub fn simulate_flat_f64(
        &mut self,
        angles: Vec<f64>,
        initial_state_idx: u128,
        initial_state_flat: Option<Vec<f64>>,
    ) -> Vec<f64> {
        let dim = 1usize << self.n_qubits;
        if let Some(flat) = initial_state_flat {
            self.scratch_state = flat
                .chunks_exact(2)
                .map(|c| C64::new(c[0], c[1]))
                .collect();
            execute_fast_instructions_msb(
                self.n_qubits,
                &mut self.scratch_state,
                &self.instructions,
                &angles,
            );
            self.last_sparse_support_size = dim;
        } else if let Some(handoff_idx) =
            self.run_sparse_until_handoff(initial_state_idx, &angles, true)
        {
            self.materialize_sparse_into_dense();
            execute_fast_instructions_msb(
                self.n_qubits,
                &mut self.scratch_state,
                &self.instructions[handoff_idx..],
                &angles,
            );
            self.last_sparse_support_size = dim;
        } else {
            self.last_sparse_support_size = self.scratch_sparse.len();
            self.materialize_sparse_into_dense();
        }
        let mut out = Vec::with_capacity(dim * 2);
        for c in &self.scratch_state {
            out.push(c.re);
            out.push(c.im);
        }
        out
    }

    /// Simulates the circuit and evaluates all Hamiltonians in `ham_set` inside Rust
    /// without copying the statevector back to Python. Automatically executes in the
    /// 128-bit sparse Plücker subspace (supporting up to $n = 126$ qubits with zero $2^n$ memory!)
    /// whenever the circuit support remains bounded, and seamlessly hands off to the
    /// multi-threaded Rayon dense $2^n$ butterfly engine when dense ($n \le 28$).
    pub fn expectation_compiled(
        &mut self,
        angles: Vec<f64>,
        initial_state_idx: u128,
        initial_state_flat: Option<Vec<f64>>,
        ham_set: &RustFastHamiltonianSet,
    ) -> Vec<f64> {
        if let Some(flat) = initial_state_flat {
            self.scratch_state = flat
                .chunks_exact(2)
                .map(|c| C64::new(c[0], c[1]))
                .collect();
            execute_fast_instructions_msb(
                self.n_qubits,
                &mut self.scratch_state,
                &self.instructions,
                &angles,
            );
            self.last_sparse_support_size = self.scratch_state.len();
            return ham_set
                .hamiltonians
                .iter()
                .map(|h| h.expectation_dense(&self.scratch_state))
                .collect();
        }

        if let Some(handoff_idx) = self.run_sparse_until_handoff(initial_state_idx, &angles, true)
        {
            self.materialize_sparse_into_dense();
            execute_fast_instructions_msb(
                self.n_qubits,
                &mut self.scratch_state,
                &self.instructions[handoff_idx..],
                &angles,
            );
            self.last_sparse_support_size = self.scratch_state.len();
            ham_set
                .hamiltonians
                .iter()
                .map(|h| h.expectation_dense(&self.scratch_state))
                .collect()
        } else {
            self.last_sparse_support_size = self.scratch_sparse.len();
            ham_set
                .hamiltonians
                .iter()
                .map(|h| h.expectation_sparse(&self.scratch_sparse))
                .collect()
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_tequila_simulator_bell_ghz_and_exp_pauli() {
        // 2-qubit Bell state (|00> + |11>) / sqrt(2)
        let gates = vec![
            TequilaGateOp::Basic {
                name: "H".to_string(),
                targets: vec![0],
                controls: vec![],
            },
            TequilaGateOp::Basic {
                name: "X".to_string(),
                targets: vec![1],
                controls: vec![0],
            },
        ];
        let state = simulate_circuit_msb(2, &[], &gates);
        let inv_sqrt2 = std::f64::consts::FRAC_1_SQRT_2;
        assert!((state[0].re - inv_sqrt2).abs() < 1e-15);
        assert!(state[1].abs() < 1e-15);
        assert!(state[2].abs() < 1e-15);
        assert!((state[3].re - inv_sqrt2).abs() < 1e-15);

        // Expectation value of Z(0)Z(1) + X(0)X(1) on Bell state == 2.0
        let terms = vec![
            PauliTerm {
                coeff_re: 1.0,
                coeff_im: 0.0,
                ops: vec![(0, 'Z'), (1, 'Z')],
            },
            PauliTerm {
                coeff_re: 1.0,
                coeff_im: 0.0,
                ops: vec![(0, 'X'), (1, 'X')],
            },
        ];
        let exp_val = expectation_pauli_hamiltonian_msb(2, &state, &state, &terms);
        assert!((exp_val.re - 2.0).abs() < 1e-14 && exp_val.im.abs() < 1e-14);

        // Diagnostics & Grassmannian Plücker invariants
        let diag = analyze_grassmann_qci_state(2, &state, 0.8, 0.5);
        assert!(diag.kahler_det_factor >= 1.0);
        assert!(diag.plucker_relation_residual < 1e-14);
        assert!(diag.vrc_orthogonality_residual < 1e-14);
        assert!((diag.one_rdm_linear_entropy - 1.0).abs() < 1e-14);
        assert!((diag.mermin_ghz_witness - 4.0).abs() < 1e-14);

        // Pearl causal do(q0 = 1) intervention collapses Bell state to |11>
        let mut do_gates = gates.clone();
        do_gates.push(TequilaGateOp::CausalDo {
            qubit: 0,
            bit_value: 1,
        });
        let do_state = simulate_circuit_msb(2, &[], &do_gates);
        assert!(do_state[0].abs() < 1e-15);
        assert!((do_state[3].re - 1.0).abs() < 1e-14);

        // Grassmannian Plücker sector compression ratio
        assert_eq!(grassmann_plucker_sector_dim(2, 4), 6);
        assert_eq!(grassmann_plucker_sector_dim(2, 6), 15);
        assert_eq!(grassmann_plucker_sector_dim(2, 10), 45);
        assert!((grassmann_hilbert_to_plucker_compression_ratio(2, 6) - 64.0 / 15.0).abs() < 1e-14);
        assert!(
            (grassmann_hilbert_to_plucker_compression_ratio(2, 10) - 1024.0 / 45.0).abs() < 1e-14
        );

        // Grassmann Plücker HCB sector simulation on Gr_C(2, 4)
        let hcb_states = simulate_grassmann_plucker_hcb_sector(
            2,
            4,
            &[(0, 2, std::f64::consts::FRAC_PI_3), (1, 3, std::f64::consts::FRAC_PI_4)],
        );
        let total_prob: f64 = hcb_states.iter().map(|(_, c)| c.norm_sq()).sum();
        assert!((total_prob - 1.0).abs() < 1e-14);
        assert!(hcb_states.iter().all(|(idx, _)| idx.count_ones() == 2));

        // Noisy density matrix + McWeeny purification
        let rho_noisy = simulate_noisy_density_msb(
            2,
            &gates,
            &[("depolarizing".to_string(), 0, 0.05)],
            1,
        );
        let tr: f64 = (0..4).map(|i| rho_noisy[i * 4 + i].re).sum();
        assert!((tr - 1.0).abs() < 1e-14);
    }
}
