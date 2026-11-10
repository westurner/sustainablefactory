"""
Tequila Quantum Simulation Backend in Rust (`PyO3` / `maturin`) and Python,
powered by Complex Grassmannians $\\mathrm{Gr}_{\\mathbb{C}}(k,n)$, Layer-Coded Plabic
Vector-Relation Configurations (`VRC`), Madelung / DDF / Turner Plücker $\\mathcal{Q}_4$
Hydrodynamics, Quantum Causal Inference (`QCI`), Jeffrey's Probability Kinematics,
and McWeeny Cubic Idempotency Purification.
"""

from __future__ import annotations

from pathlib import Path
import sys
import types
from typing import Any, Union

import numpy as np

ROOT_DIR = Path(__file__).resolve().parent.parent
TEQUILA_SRC = ROOT_DIR / "src" / "tequila" / "src"
if TEQUILA_SRC.exists() and str(TEQUILA_SRC) not in sys.path:
    sys.path.insert(0, str(TEQUILA_SRC))

import signals_numerical_adapter as sna
import tequila as tq
from tequila import BitNumbering, BitString, QubitWaveFunction, TequilaException
from tequila.circuit._gates_impl import (
    ExponentialPauliGateImpl,
    PhaseGateImpl,
    RotationGateImpl,
)
from tequila.circuit.gates import QubitExcitationImpl
from tequila.simulators import simulator_api
from tequila.simulators.simulator_api import BackendTypes
from tequila.simulators.simulator_base import (
    BackendBraKet,
    BackendCircuit,
    BackendExpectationValue,
)
from tequila.utils.bitstrings import reverse_int_bits
from tequila.utils.keymap import KeyMapRegisterToSubregister
from tequila.wavefunction.density_matrix import DensityMatrix


class TequilaSignalsException(TequilaException):
    def __str__(self) -> str:
        return "Error in signals Rust/PyO3 backend: " + self.message


class BackendCircuitSignals(BackendCircuit):
    """
    Compiled Tequila circuit backed by the native Rust/PyO3 `signals_numerical_adapter`
    statevector, Grassmannian Plücker $\\mathrm{Gr}_{\\mathbb{C}}(k,n)$, Complex Plabic VRC,
    and Quantum Causal Inference (`QCI`) engine.
    """

    compiler_arguments = {
        "trotterized": True,
        "swap": False,
        "multitarget": True,
        "controlled_rotation": False,
        "generalized_rotation": True,
        "exponential_pauli": False,
        "controlled_exponential_pauli": False,
        "phase": False,
        "power": True,
        "hadamard_power": True,
        "controlled_power": True,
        "controlled_phase": False,
        "toffoli": False,
        "phase_to_z": False,
        "cc_max": False,
    }

    numbering = BitNumbering.MSB
    supports_sampling_initialization = True
    supports_generic_initialization = True

    def __init__(
        self,
        abstract_circuit,
        variables=None,
        qubit_map=None,
        noise=None,
        device=None,
        mcweeny_passes: int = 0,
        seed: int = 1337,
        *args,
        **kwargs,
    ):
        self.measurements = None
        self.mcweeny_passes = int(mcweeny_passes)
        self.seed = int(seed)
        self._rust_circuit = None
        self._param_callables: list = []
        self._current_angles: list[float] = []
        super().__init__(
            abstract_circuit=abstract_circuit,
            variables=variables,
            qubit_map=qubit_map,
            noise=noise,
            device=device,
            *args,
            **kwargs,
        )

    def initialize_circuit(self, *args, **kwargs) -> list[dict]:
        return []

    def create_circuit(
        self, abstract_circuit=None, circuit=None, variables=None, *args, **kwargs
    ):
        if abstract_circuit is None:
            abstract_circuit = self.abstract_circuit

        is_primary = circuit is None and abstract_circuit is self.abstract_circuit
        if is_primary:
            self._rust_circuit = sna.RustFastCircuit(int(self.n_qubits))
            self._param_callables = []
            self._current_angles = []

        result = (
            circuit
            if circuit is not None
            else self.initialize_circuit(*args, **kwargs)
        )
        for g in abstract_circuit.gates:
            self._compile_single_gate(
                g,
                result,
                variables=variables,
                rust_circuit=self._rust_circuit if is_primary else None,
            )
        return result

    def update_variables(self, variables) -> None:
        if variables is None:
            return
        if self._rust_circuit is not None:
            self._current_angles = [
                self._resolve_angle(fn, variables) for fn in self._param_callables
            ]
        else:
            self.circuit = self.create_circuit(
                abstract_circuit=self.abstract_circuit, variables=variables
            )

    def _resolve_angle(self, param, variables) -> float:
        if isinstance(param, (int, float, np.number)):
            return float(param)
        if callable(param):
            return float(param(variables))
        if variables is not None and param in variables:
            return float(variables[param])
        return float(param)

    def _register_angle(
        self, param, variables, rust_circuit
    ) -> tuple[float, int | None]:
        val = self._resolve_angle(param, variables)
        if rust_circuit is None:
            return val, None
        if isinstance(param, (int, float, np.number)):
            return val, None
        idx = len(self._param_callables)
        self._param_callables.append(param)
        self._current_angles.append(val)
        return val, idx

    def _mapped_targets(self, gate) -> list[int]:
        return [int(self.qubit(t)) for t in gate.target]

    def _mapped_controls(self, gate) -> list[int]:
        if not gate.is_controlled():
            return []
        return [int(self.qubit(c)) for c in gate.control]

    def _compile_single_gate(
        self, gate, circuit: list[dict], variables=None, rust_circuit=None
    ) -> None:
        if isinstance(gate, QubitExcitationImpl):
            compiled = gate.compile(exponential_pauli=True)
            for sub in compiled.abstract_circuit.gates:
                self._compile_single_gate(
                    sub, circuit, variables=variables, rust_circuit=rust_circuit
                )
            return

        controls = self._mapped_controls(gate)
        if isinstance(gate, ExponentialPauliGateImpl):
            angle, param_idx = self._register_angle(
                gate.parameter, variables, rust_circuit
            )
            paulis = [
                (int(self.qubit(q)), str(op).upper())
                for q, op in gate.paulistring.items()
            ]
            if rust_circuit is not None:
                rust_circuit.add_exp_pauli(paulis, controls, angle, param_idx)
            circuit.append(
                {
                    "kind": "exp_pauli",
                    "paulis": paulis,
                    "angle": angle,
                    "controls": controls,
                }
            )
            return

        targets = self._mapped_targets(gate)
        if isinstance(gate, RotationGateImpl):
            angle, param_idx = self._register_angle(
                gate.parameter, variables, rust_circuit
            )
            axis_upper = str(gate.name).upper()
            if rust_circuit is not None:
                rust_circuit.add_rotation(
                    axis_upper, targets, controls, angle, param_idx
                )
            circuit.append(
                {
                    "kind": "rotation",
                    "axis": axis_upper,
                    "angle": angle,
                    "targets": targets,
                    "controls": controls,
                }
            )
            return

        if isinstance(gate, PhaseGateImpl):
            angle, param_idx = self._register_angle(
                gate.parameter, variables, rust_circuit
            )
            if rust_circuit is not None:
                rust_circuit.add_rotation("PHASE", targets, controls, angle, param_idx)
            circuit.append(
                {
                    "kind": "rotation",
                    "axis": "PHASE",
                    "angle": angle,
                    "targets": targets,
                    "controls": controls,
                }
            )
            return

        name_upper = str(gate.name).upper()
        if name_upper == "SWAP":
            if rust_circuit is not None and len(targets) >= 2:
                rust_circuit.add_swap(targets[0], targets[1], controls)
            circuit.append(
                {
                    "kind": "swap",
                    "targets": targets,
                    "controls": controls,
                }
            )
        else:
            if rust_circuit is not None:
                rust_circuit.add_basic(name_upper, targets, controls)
            circuit.append(
                {
                    "kind": "basic",
                    "name": name_upper,
                    "targets": targets,
                    "controls": controls,
                }
            )

    def add_basic_gate(self, gate, circuit: list[dict], *args, **kwargs) -> None:
        self._compile_single_gate(
            gate, circuit, variables=kwargs.get("variables", {}), rust_circuit=None
        )

    def add_parametrized_gate(self, gate, circuit: list[dict], *args, **kwargs) -> None:
        self._compile_single_gate(
            gate, circuit, variables=kwargs.get("variables", {}), rust_circuit=None
        )

    def add_measurement(self, circuit, target_qubits, *args, **kwargs):
        self.measurements = sorted(target_qubits)
        return circuit

    def _build_initial_state_re_im(
        self, initial_state: Union[int, QubitWaveFunction] = 0
    ) -> list[tuple[float, float]]:
        dim = 1 << self.n_qubits
        if isinstance(initial_state, QubitWaveFunction):
            arr = initial_state.to_array(out_numbering=BitNumbering.MSB)
            return [(float(np.real(c)), float(np.imag(c))) for c in arr]
        if isinstance(initial_state, BitString):
            idx = (
                reverse_int_bits(initial_state.integer, initial_state.nbits)
                if initial_state.numbering != BitNumbering.MSB
                else int(initial_state.integer)
            )
        else:
            idx = int(initial_state)
        if idx == 0:
            return []
        init = [(0.0, 0.0)] * dim
        init[idx] = (1.0, 0.0)
        return init

    def _resolve_initial_state_fast(
        self, initial_state: Union[int, QubitWaveFunction] = 0
    ) -> tuple[int, list[float] | None]:
        if isinstance(initial_state, QubitWaveFunction):
            arr = initial_state.to_array(out_numbering=BitNumbering.MSB)
            flat = np.ascontiguousarray(arr, dtype=np.complex128).view(np.float64)
            return 0, flat.tolist()
        if isinstance(initial_state, BitString):
            idx = (
                reverse_int_bits(initial_state.integer, initial_state.nbits)
                if initial_state.numbering != BitNumbering.MSB
                else int(initial_state.integer)
            )
            return int(idx), None
        return int(initial_state), None

    def simulate_statevector_re_im(
        self,
        variables=None,
        initial_state: Union[int, QubitWaveFunction] = 0,
        circuit_override: list[dict] | None = None,
    ) -> list[tuple[float, float]]:
        self.update_variables(variables)
        if circuit_override is None and self._rust_circuit is not None:
            init_idx, init_flat = self._resolve_initial_state_fast(initial_state)
            flat = self._rust_circuit.simulate_flat_f64(
                self._current_angles, init_idx, init_flat
            )
            it = iter(flat)
            return list(zip(it, it))
        ops = circuit_override if circuit_override is not None else self.circuit
        init_re_im = self._build_initial_state_re_im(initial_state)
        return sna.py_simulate_circuit_msb(
            int(self.n_qubits),
            ops,
            init_re_im if init_re_im else None,
        )

    def do_simulate(
        self,
        variables,
        initial_state: Union[int, QubitWaveFunction] = 0,
        *args,
        **kwargs,
    ) -> QubitWaveFunction:
        self.update_variables(variables)
        if self._rust_circuit is not None:
            init_idx, init_flat = self._resolve_initial_state_fast(initial_state)
            if self.n_qubits > 20 and init_flat is None:
                sparse_triples = self._rust_circuit.simulate_sparse_plucker(
                    self._current_angles, init_idx
                )
                if len(sparse_triples) <= 262144:
                    wfn = QubitWaveFunction(
                        int(self.n_qubits), numbering=self.numbering, dense=False
                    )
                    wfn._state = {
                        int(idx): complex(re, im) for idx, re, im in sparse_triples
                    }
                    return wfn
            flat = self._rust_circuit.simulate_flat_f64(
                self._current_angles, init_idx, init_flat
            )
            arr = np.asarray(flat, dtype=np.float64).view(np.complex128).copy()
            return QubitWaveFunction.from_array(
                array=arr, numbering=self.numbering, copy=False
            )
        re_im = self.simulate_statevector_re_im(
            variables=variables, initial_state=initial_state
        )
        arr = np.array([complex(r, i) for r, i in re_im], dtype=complex)
        return QubitWaveFunction.from_array(array=arr, numbering=self.numbering)

    def do_sample(
        self,
        samples: int,
        circuit,
        noise_model=None,
        initial_state: Union[int, QubitWaveFunction] = 0,
        *args,
        **kwargs,
    ) -> QubitWaveFunction:
        override = None if circuit is self.circuit else circuit
        if noise_model is not None or self.noise is not None:
            active_noise = noise_model if noise_model is not None else self.noise
            dm = self.do_simulate_density(
                variables=kwargs.get("variables", None),
                initial_state=initial_state,
                noise_model=active_noise,
                circuit_override=override,
            )
            diag_probs = np.clip(np.real(np.diag(dm.get_density_as_array())), 0.0, 1.0)
            msb_re_im = [
                (
                    float(
                        np.sqrt(
                            diag_probs[reverse_int_bits(idx, int(self.n_qubits))]
                        )
                    ),
                    0.0,
                )
                for idx in range(1 << self.n_qubits)
            ]
            sampled_pairs = sna.py_sample_statevector_msb(
                msb_re_im, int(samples), int(self.seed)
            )
        else:
            re_im = self.simulate_statevector_re_im(
                variables=kwargs.get("variables", None),
                initial_state=initial_state,
                circuit_override=override,
            )
            sampled_pairs = sna.py_sample_statevector_msb(
                re_im, int(samples), int(self.seed)
            )

        result = QubitWaveFunction(self.n_qubits, self.numbering)
        for basis_idx, count in sampled_pairs:
            result[int(basis_idx)] = complex(float(count), 0.0)

        if self.measurements is not None and len(self.measurements) < self.n_qubits:
            mapped_target = [self.qubit_map[q].number for q in self.measurements]
            mapped_full = [self.qubit_map[q].number for q in self.abstract_qubits]
            keymap = KeyMapRegisterToSubregister(
                subregister=mapped_target, register=mapped_full
            )
            result = QubitWaveFunction.from_wavefunction(
                result, keymap, n_qubits=len(self.measurements)
            )

        return result

    def do_simulate_density(
        self,
        variables=None,
        initial_state: Union[int, QubitWaveFunction] = 0,
        noise_model=None,
        circuit_override: list[dict] | None = None,
        mcweeny_passes: int | None = None,
        *args,
        **kwargs,
    ) -> DensityMatrix:
        self.update_variables(variables)
        ops = circuit_override if circuit_override is not None else self.circuit
        active_noise = noise_model if noise_model is not None else self.noise
        noise_channels: list[tuple[str, int, float]] = []
        if active_noise is not None and hasattr(active_noise, "noises"):
            for n in active_noise.noises:
                prob = float(n.probs[0]) if len(n.probs) > 0 else 0.0
                for q in range(int(self.n_qubits)):
                    noise_channels.append((str(n.name), int(q), prob))

        passes = (
            int(mcweeny_passes)
            if mcweeny_passes is not None
            else int(self.mcweeny_passes)
        )
        rho_re_im = sna.py_simulate_noisy_density_msb(
            int(self.n_qubits), ops, noise_channels, passes
        )
        dim = 1 << int(self.n_qubits)
        rho_msb = np.array([complex(r, i) for r, i in rho_re_im], dtype=complex).reshape(
            (dim, dim)
        )
        return DensityMatrix.from_array(
            density_matrix=rho_msb,
            n_qubits=int(self.n_qubits),
            numbering=BitNumbering.MSB,
        )

    def analyze_grassmann_qci(
        self,
        variables=None,
        initial_state: Union[int, QubitWaveFunction] = 0,
        soft_evidence_q: float = 0.80,
        prior_p: float = 0.50,
    ) -> dict[str, float]:
        """
        Extracts the Complex Grassmannian Plücker $\\mathrm{Gr}_{\\mathbb{C}}(2,4)$,
        Homogeneous Complex VRC, Madelung/Bohm quantum pressure, QCI spin mutual
        information, and Quantum Jeffrey Plücker kinematic diagnostics in Rust.
        """
        re_im = self.simulate_statevector_re_im(
            variables=variables, initial_state=initial_state
        )
        return dict(
            sna.py_analyze_grassmann_qci_state(
                int(self.n_qubits), re_im, float(soft_evidence_q), float(prior_p)
            )
        )


class BackendExpectationValueSignals(BackendExpectationValue):
    """
    Rayon-parallelized Rust/PyO3 ExpectationValue evaluator for Tequila.
    """

    BackendCircuitType = BackendCircuitSignals
    use_mapping = True

    def initialize_hamiltonian(self, hamiltonians: tuple) -> tuple:
        converted = []
        raw_hams = []
        for H in hamiltonians:
            terms = []
            for ps in H.paulistrings:
                coeff = complex(ps.coeff)
                ops = [
                    (int(self.U.qubit(q)), str(op).upper()) for q, op in ps.items()
                ]
                terms.append((float(np.real(coeff)), float(np.imag(coeff)), ops))
            converted.append((H, terms))
            raw_hams.append(terms)
        self._rust_ham_set = sna.RustFastHamiltonianSet(int(self.n_qubits), raw_hams)
        return tuple(converted)

    def simulate(
        self,
        variables,
        initial_state: Union[int, QubitWaveFunction] = 0,
        *args,
        **kwargs,
    ) -> np.ndarray:
        self.U.update_variables(variables)
        if self.U._rust_circuit is not None and hasattr(self, "_rust_ham_set"):
            init_idx, init_flat = self.U._resolve_initial_state_fast(initial_state)
            vals = self.U._rust_circuit.expectation_compiled(
                self.U._current_angles,
                init_idx,
                init_flat,
                self._rust_ham_set,
            )
            return np.asarray(vals, dtype=float)

        ket_re_im = self.U.simulate_statevector_re_im(
            variables=variables, initial_state=initial_state
        )
        results = []
        for _H_orig, rust_terms in self.H:
            re_val, _im_val = sna.py_expectation_pauli_hamiltonian_msb(
                int(self.n_qubits), ket_re_im, ket_re_im, rust_terms
            )
            results.append(float(re_val))
        return np.asarray(results, dtype=float)


class BackendBraKetSignals(BackendBraKet):
    """
    Native Rust/PyO3 BraKet overlap `<bra | ket>` and transition element `<bra | O | ket>` evaluator.
    """

    BackendCircuitType = BackendCircuitSignals

    def simulate(
        self,
        variables,
        initial_state: Union[int, QubitWaveFunction] = 0,
        *args,
        **kwargs,
    ) -> complex:
        self.update_variables(variables)
        ket_re_im = self.U_ket.simulate_statevector_re_im(
            variables=variables, initial_state=initial_state
        )
        if self.U_bra is self.U_ket:
            bra_re_im = ket_re_im
        else:
            bra_re_im = self.U_bra.simulate_statevector_re_im(
                variables=variables, initial_state=initial_state
            )

        if self.operator is None:
            re_val, im_val = sna.py_expectation_pauli_hamiltonian_msb(
                int(self.n_qubits),
                bra_re_im,
                ket_re_im,
                [(1.0, 0.0, [])],
            )
            return complex(re_val, im_val)

        rust_terms = []
        for ps in self.operator.paulistrings:
            coeff = complex(ps.coeff)
            ops = [
                (int(self.U_ket.qubit(q)), str(op).upper()) for q, op in ps.items()
            ]
            rust_terms.append((float(np.real(coeff)), float(np.imag(coeff)), ops))

        re_val, im_val = sna.py_expectation_pauli_hamiltonian_msb(
            int(self.n_qubits), bra_re_im, ket_re_im, rust_terms
        )
        return complex(re_val, im_val)


def ensure_tequila_signals_backend_registered() -> list[str]:
    """
    Ensures that the Rust/PyO3 `signals` and `grassmann` backends are registered
    in `tequila.simulators.simulator_api` for wavefunction simulation, shot sampling,
    noisy sampling, and density-matrix simulation.
    """
    for name in ("grassmann", "signals"):
        if name in simulator_api.SUPPORTED_BACKENDS:
            simulator_api.SUPPORTED_BACKENDS.remove(name)
        simulator_api.SUPPORTED_BACKENDS.insert(0, name)
        if name in simulator_api.SUPPORTED_DENSITY_BACKENDS:
            simulator_api.SUPPORTED_DENSITY_BACKENDS.remove(name)
        simulator_api.SUPPORTED_DENSITY_BACKENDS.insert(0, name)
        if name in simulator_api.SUPPORTED_NOISE_BACKENDS:
            simulator_api.SUPPORTED_NOISE_BACKENDS.remove(name)
        simulator_api.SUPPORTED_NOISE_BACKENDS.insert(0, name)
        btypes = BackendTypes(
            CircType=BackendCircuitSignals,
            ExpValueType=BackendExpectationValueSignals,
            BraKetType=BackendBraKetSignals,
        )
        simulator_api.INSTALLED_SIMULATORS[name] = btypes
        simulator_api.INSTALLED_SAMPLERS[name] = btypes
        simulator_api.INSTALLED_NOISE_SAMPLERS[name] = btypes
        simulator_api.INSTALLED_BACKENDS = {
            **simulator_api.INSTALLED_SIMULATORS,
            **simulator_api.INSTALLED_SAMPLERS,
        }
    return list(simulator_api.INSTALLED_SIMULATORS.keys())


class SignalsTequilaGrassmannSimulator:
    """
    High-level interface to the Rust/PyO3 (`signals_numerical_adapter`) Grassmannian,
    Plabic VRC, Madelung/DDF, and Quantum Causal Inference backend for Tequila.
    """

    @staticmethod
    def simulate_plucker_hcb_wavefunction(
        n_occ: int,
        n_orb: int,
        rotations: list[tuple[int, int, float]],
        fermionic_jw_sign: bool = True,
    ) -> QubitWaveFunction:
        """
        Evolves a particle-number-conserving $k$-pair / $k$-fermion state on
        $\\mathrm{Gr}_{\\mathbb{C}}(n_{\\mathrm{occ}}, n_{\\mathrm{orb}})$ in Rust and returns
        a Tequila `QubitWaveFunction` populated on the $\\binom{n_{\\mathrm{orb}}}{n_{\\mathrm{occ}}}$
        Plücker basis states. When `fermionic_jw_sign=True`, evaluates the antisymmetric
        Cauchy–Binet Slater determinant $\\det C[:, I]$; when `False`, evaluates the
        symmetric Hard-Core Boson permanent $\\operatorname{perm} C[:, I]$.
        """
        sparse_amps = sna.py_simulate_grassmann_plucker_hcb(
            int(n_occ), int(n_orb), list(rotations), bool(fermionic_jw_sign)
        )
        wfn = QubitWaveFunction(n_qubits=int(n_orb), numbering=BitNumbering.MSB)
        for basis_idx, re_val, im_val in sparse_amps:
            wfn[int(basis_idx)] = complex(float(re_val), float(im_val))
        return wfn

    @staticmethod
    def evaluate_vqe_mra_pno_surrogate(
        h_tensor: np.ndarray,
        g_tensor: np.ndarray,
        pairinfo: list[tuple[int, ...]],
        occinfo: list[float],
        nuclear_repulsion: float = 0.0,
        datadir: str | Path = ".tmp/tequila_signals_vqe",
        name: str = "beh2_signals",
    ) -> dict[str, Any]:
        """
        Runs an end-to-end MADNESS MRA-PNO surrogate + Tequila `HCB-SPA` circuit
        simulation and VQE energy evaluation using the Rust/PyO3 `signals` backend.
        """
        from sustainablefactory.qci_grassmannian_dft import (
            MadnessTequilaVRCQuantumChemistryEngine,
        )

        ensure_tequila_signals_backend_registered()
        MadnessTequilaVRCQuantumChemistryEngine.export_and_load_madness_tequila_surrogate(
            name=name,
            datadir=datadir,
            h_tensor=h_tensor,
            g_tensor=g_tensor,
            nuclear_repulsion=nuclear_repulsion,
            pairinfo=pairinfo,
            occinfo=occinfo,
        )
        mol = tq.Molecule(
            geometry="Be 0.0 0.0 0.0\nH 0.0 0.0 1.33\nH 0.0 0.0 -1.33",
            name=name,
            datadir=str(datadir),
            n_pno="read",
        )
        H_hcb = mol.make_hardcore_boson_hamiltonian()
        U_spa = mol.make_spa_ansatz(hcb=True)
        E_obj = tq.ExpectationValue(H=H_hcb, U=U_spa)

        vars_zero = {v: 0.0 for v in E_obj.extract_variables()}
        vars_corr = {v: 0.25 for v in E_obj.extract_variables()}

        e_hf_signals = float(tq.simulate(E_obj, variables=vars_zero, backend="signals"))
        e_hf_symbolic = float(
            tq.simulate(E_obj, variables=vars_zero, backend="symbolic")
        )
        e_corr_signals = float(
            tq.simulate(E_obj, variables=vars_corr, backend="signals")
        )
        e_corr_symbolic = float(
            tq.simulate(E_obj, variables=vars_corr, backend="symbolic")
        )

        compiled_u = tq.compile(U_spa, variables=vars_corr, backend="signals")
        diagnostics = compiled_u.analyze_grassmann_qci(variables=vars_corr)

        return {
            "e_hf_signals": e_hf_signals,
            "e_hf_symbolic": e_hf_symbolic,
            "e_corr_signals": e_corr_signals,
            "e_corr_symbolic": e_corr_symbolic,
            "hf_abs_diff": abs(e_hf_signals - e_hf_symbolic),
            "corr_abs_diff": abs(e_corr_signals - e_corr_symbolic),
            "diagnostics": diagnostics,
        }


try:
    from tequila.simulators.simulator_signals import (  # noqa: E402
        DEFAULT_CHEMISTRY_CONFIGS,
        DEFAULT_DENSE_CONFIGS,
        DEFAULT_MEMORY_WALL_QUBITS,
        QUICK_CHEMISTRY_CONFIGS,
        QUICK_DENSE_CONFIGS,
        QUICK_MEMORY_WALL_QUBITS,
        benchmark_dense_expectation_scaling,
        benchmark_dense_memory_wall_limit,
        benchmark_grassmann_plucker_permanent_vs_determinant,
        benchmark_plucker_hcb_chemistry_scaling,
        benchmark_vqe_optimization_and_wavefunction,
        build_arg_parser,
        build_dense_benchmark_circuit_and_hamiltonian,
        build_plucker_hcb_chemistry_circuit_and_hamiltonian,
        format_benchmark_markdown_tables,
        main as _tequila_signals_main,
        run_all_benchmarks,
    )
except ImportError:  # pragma: no cover
    _mod = types.ModuleType("tequila.simulators.simulator_signals")
    _mod.BackendCircuitSignals = BackendCircuitSignals
    _mod.BackendExpectationValueSignals = BackendExpectationValueSignals
    _mod.BackendBraKetSignals = BackendBraKetSignals
    _mod.TequilaSignalsException = TequilaSignalsException
    sys.modules["tequila.simulators.simulator_signals"] = _mod


def main(argv: list[str] | None = None) -> int:
    """
    CLI entry point for `python -m sustainablefactory.tequila_signals_backend`
    and `python -m tequila.simulators.simulator_signals`.
    """
    ensure_tequila_signals_backend_registered()
    return _tequila_signals_main(argv)


SignalsTequilaGrassmannSimulator.benchmark_dense_expectation_scaling = staticmethod(
    benchmark_dense_expectation_scaling
)
SignalsTequilaGrassmannSimulator.benchmark_dense_memory_wall_limit = staticmethod(
    benchmark_dense_memory_wall_limit
)
SignalsTequilaGrassmannSimulator.benchmark_plucker_hcb_chemistry_scaling = staticmethod(
    benchmark_plucker_hcb_chemistry_scaling
)
SignalsTequilaGrassmannSimulator.benchmark_vqe_optimization_and_wavefunction = (
    staticmethod(benchmark_vqe_optimization_and_wavefunction)
)
SignalsTequilaGrassmannSimulator.benchmark_grassmann_plucker_permanent_vs_determinant = (
    staticmethod(benchmark_grassmann_plucker_permanent_vs_determinant)
)
SignalsTequilaGrassmannSimulator.run_all_benchmarks = staticmethod(run_all_benchmarks)


__all__ = [
    "BackendBraKetSignals",
    "BackendCircuitSignals",
    "BackendExpectationValueSignals",
    "DEFAULT_CHEMISTRY_CONFIGS",
    "DEFAULT_DENSE_CONFIGS",
    "DEFAULT_MEMORY_WALL_QUBITS",
    "QUICK_CHEMISTRY_CONFIGS",
    "QUICK_DENSE_CONFIGS",
    "QUICK_MEMORY_WALL_QUBITS",
    "SignalsTequilaGrassmannSimulator",
    "TequilaSignalsException",
    "benchmark_dense_expectation_scaling",
    "benchmark_dense_memory_wall_limit",
    "benchmark_grassmann_plucker_permanent_vs_determinant",
    "benchmark_plucker_hcb_chemistry_scaling",
    "benchmark_vqe_optimization_and_wavefunction",
    "build_arg_parser",
    "build_dense_benchmark_circuit_and_hamiltonian",
    "build_plucker_hcb_chemistry_circuit_and_hamiltonian",
    "ensure_tequila_signals_backend_registered",
    "format_benchmark_markdown_tables",
    "main",
    "run_all_benchmarks",
]


if __name__ == "__main__":
    raise SystemExit(main())
