"""End-to-end SymPy and Rust/PyO3 verification for `Signals.Photoelectric`."""

import math
from pathlib import Path
import re

import pytest
import signals_numerical_adapter as sna

from sustainablefactory.photoelectric import (
    TEST_DATA_CITATIONS,
    run_pyo3_photoelectric_benchmark_suite,
    verify_symbolic_photoelectric_identities,
)


def test_photoelectric_test_data_citations_exist_in_bibtex():
    bib_text = Path("docs/citations.bib").read_text(encoding="utf-8")
    bib_keys = set(re.findall(r"@\w+\{([^,\s]+)", bib_text))
    assert len(TEST_DATA_CITATIONS) >= 9
    for section, meta in TEST_DATA_CITATIONS.items():
        keys = [k.strip() for k in meta["bibtex_keys"].split(",") if k.strip()]
        assert keys, f"Missing bibtex_keys for {section}"
        for key in keys:
            assert key in bib_keys, f"Citation key {key!r} from {section} missing in docs/citations.bib"


def test_symbolic_photoelectric_identities():
    res = verify_symbolic_photoelectric_identities()
    assert len(res) == 21
    for name, ok in res.items():
        assert ok, f"Symbolic photoelectric identity failed: {name}"


def test_pyo3_photoelectric_auditors_and_check_figures():
    bench = run_pyo3_photoelectric_benchmark_suite()
    assert bench["ein_below_kmax"] == 0.0
    assert math.isclose(bench["ein_above_kmax"], 2.5, rel_tol=1e-14)
    assert math.isclose(bench["mcweeny_purified_075"], 27.0 / 32.0, rel_tol=1e-14)
    assert math.isclose(bench["keldysh_gamma"], 1.0, rel_tol=1e-14)
    assert math.isclose(bench["keldysh_bohm_rel_err"], 1.0, rel_tol=1e-14)
    assert bench["keldysh_plucker_qfim_rel_err"] < 1e-14
    assert bench["keldysh_coupled_speed_res"] < 1e-14
    assert math.isclose(bench["enz_enhancement"], 400.0, rel_tol=1e-12)
    assert math.isclose(bench["oam_qfim_phi"], 36.0, rel_tol=1e-14)
    assert math.isclose(bench["oam_qcrb_ratio"], 9.0, rel_tol=1e-14)
    assert abs(bench["euler_gimbal_lock_det"]) < 1e-15
    assert bench["soliton_nls_pde_res"] < 1e-12
    assert bench["soliton_gpe_pde_res"] < 1e-12
    assert math.isclose(bench["unphased_two_path_err"], 0.5, rel_tol=1e-14)
    assert math.isclose(bench["qfim_over_fs_simplex"], 4.0, rel_tol=1e-14)
    assert math.isclose(bench["spp_effective_index_sq"], 4.0 / 3.0, rel_tol=1e-14)
    assert math.isclose(bench["spp_gr24_channel_ratio"], 4.0, rel_tol=1e-14)
    assert math.isclose(bench["spp_bohm_ratio"], 16.0, rel_tol=1e-13)
    assert math.isclose(bench["spp_keldysh_compression"], 16.0 / 3.0, rel_tol=1e-14)
    assert abs(bench["bulk_plasmon_enz"]) < 1e-15
    assert math.isclose(bench["polariton_up_lp_split"], 0.2, rel_tol=1e-14)
    assert math.isclose(bench["vrc_resonant_qfim_x1"], 2.0, rel_tol=1e-14)
    # Literature-parameterized benchmarks (W, Au@800nm, Al plasmon 15.0 eV, GaAs microcavity 3.5 meV)
    assert math.isclose(bench["lit_w_uv_kmax"], 16.67, rel_tol=1e-12)
    assert math.isclose(bench["lit_au_spp_n_sq"], 24.1 / 23.1, rel_tol=1e-12)
    assert math.isclose(bench["lit_al_plasmon_sat_kmax"], 1.94, rel_tol=1e-12)
    assert math.isclose(bench["lit_gaas_rabi_split_ev"], 0.0035, rel_tol=1e-12)


def test_pyo3_photoelectric_sato_soliton_envelope_and_invalid_inputs():
    sol_peak = sna.py_audit_soliton_two_pathway_photoemission(
        2.0, 0.0, 0.5, 1.0, 1.0, 0.5, 4.5, 1.0, 1.0, 0.0, 1.0, -1.0
    )
    sol_wing = sna.py_audit_soliton_two_pathway_photoemission(
        2.0, 1.5, 0.5, 1.0, 1.0, 0.5, 4.5, 1.0, 1.0, 0.0, 1.0, -1.0
    )
    assert math.isclose(sol_peak["soliton_local_ponderomotive"], sol_peak["soliton_peak_ponderomotive"])
    assert sol_wing["soliton_local_ponderomotive"] < sol_peak["soliton_peak_ponderomotive"]
    assert sol_wing["nls_bright_pde_residual"] < 1e-12

    with pytest.raises(ValueError):
        sna.py_audit_einstein_photoelectric(1.0, 5.0, 2.0, 4.5, 1.0, 1e-19, 0.5)
    with pytest.raises(ValueError):
        sna.py_audit_keldysh_strong_field(4.5, 1.0, 1.5, 1.0, 0.5, 1.0, 1.0, 0.0, 5.0, 0.25)
    with pytest.raises(ValueError):
        sna.py_audit_enz_oam_photoemission(1.0, 0.0, 1.0, 0.5, 1, 1, 10.0, 1.0, 0.2, 0.5)
    with pytest.raises(ValueError):
        sna.py_audit_polariton_plasmon_photoemission(
            4.0, 2.0, 800.0, 1.0, 1.5, 1.0, 0.5, 4.5, 25.0, 1.0, 15.0, 2.0, 2.0, 0.1, 1.0, 1.0,
            3.0, 2.0, 0.0, 0.0
        )
