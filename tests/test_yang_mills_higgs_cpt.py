"""
Tri-language verification suite (SymPy + 45-digit mpmath + Rust/PyO3 `signals_numerical_adapter`)
for `Signals.YangMillsHiggsCPT` and `docs/grassmannian-yang-mills-mass-gap-higgs-cp-cpt-paper.md`.
"""

from sustainablefactory.yang_mills_higgs_cpt import (
    audit_yang_mills_higgs_cpt_high_precision,
    verify_symbolic_yang_mills_higgs_cpt_identities,
)


def test_symbolic_yang_mills_higgs_cp_jost_cpt_identities():
    sym_res = verify_symbolic_yang_mills_higgs_cpt_identities()
    assert len(sym_res) == 9
    assert all(sym_res.values()), f"Failed symbolic checks: {sym_res}"


def test_pyo3_and_mpmath_yang_mills_higgs_cp_jost_cpt_audit():
    rep = audit_yang_mills_higgs_cpt_high_precision(dps=45)
    assert rep["ym_mass_gap_sym_ok"]
    assert rep["s3_nonabelian_haar_sym_ok"]
    assert rep["higgs_ssb_sym_ok"]
    assert rep["cp_sakharov_sym_ok"]
    assert rep["jarlskog_and_neq_sakharov_sym_ok"]
    assert rep["jost_cpt_4x4_sym_ok"]
    assert rep["os_reflection_sym_ok"]
    assert rep["gko_running_level_and_ewpt_sym_ok"]
    assert rep["higgs_eft_cp_sym_ok"]
    assert rep["lambda_ym_diff"] < 1e-14
    assert rep["m_w_diff"] < 1e-13
    assert rep["m_z_diff"] < 1e-13
    assert rep["rho_ew_diff"] < 1e-14
    assert rep["jarlskog_diff"] < 1e-16
    assert rep["lattice_a62_diff"] < 1e-16
    assert rep["atlas_kt_diff"] < 1e-15

    rust = rep["rust_report"]
    assert abs(rust["su3_beta0"] - 11.0) < 1e-12
    assert abs(rust["toupin_m1_mev"] - 300.0) < 1e-12
    assert abs(rust["toupin_sugawara_m1_mev"] - 150.0) < 1e-12
    assert rust["casimir_suppression_c2_3_over_c2_0"] < 0.1
    assert rust["strong_coupling_gap_lower_bound"] > 0.99
    assert rust["haar_projector_idemp_err"] < 1e-15
    assert rust["haar_projector_herm_err"] < 1e-15
    assert rust["haar_projector_nonsinglet_max"] < 1e-14
    assert rust["s3_haar_projector_idemp_err"] < 1e-15
    assert abs(rust["s3_haar_projector_trace"] - 1.0) < 1e-15
    assert rust["s3_haar_projector_2d_irrep_res"] < 1e-15
    assert abs(rust["rho_ew"] - 1.0) < 1e-14
    assert rust["tadpole_expansion_residual"] < 1e-7
    assert rust["jarlskog_degenerate_zero"] == 0.0
    assert rust["jarlskog_physical_splitting_nonzero"] > 1e9
    assert rust["higgs_cp_asym_sm"] == 0.0
    assert rust["higgs_cp_asym_bsm"] > 0.1
    assert abs(rust["sakharov_equilibrium_baryon_trace"]) < 1e-15
    assert abs(rust["sakharov_out_of_equilibrium_baryon_trace"]) > 0.01
    assert rust["jost_antiunitary_err"] < 1e-14
    assert rust["jost_involution_err"] < 1e-14
    assert rust["jost_cpt_commutator_err"] < 1e-14
    assert rust["jost_mass_equality_err"] < 1e-14
    assert rust["jost_fermionic_kramers_mass_err"] < 1e-14
    assert abs(rust["cp_violation_norm_when_delta_nonzero"] - rust["t_violation_norm_when_delta_nonzero"]) < 1e-14
    assert rust["cp_violation_norm_when_delta_nonzero"] > 0.1
    assert rust["cp_t_commutator_zero_when_delta_zero"] < 1e-15
    assert 0.0 < rust["lattice_spacing_beta62"] < rust["lattice_spacing_beta58"] < 1.0
    assert rust["strong_coupling_breakdown_at_18"] == 0.0
    assert rust["os_reflection_factorization_err"] < 1e-15
    assert rust["os_reflection_min_quad"] > 0.0
    assert rust["os_clustering_excess"] <= 1e-15
    assert abs(rust["toupin_gko_max_mev_at_220"] - 440.0) < 1e-12
    assert rust["toupin_k_eff_for_lattice_1610"] < 0.0
    assert rust["toupin_k_eff_mass_err"] < 1e-11
    assert rust["ewpt_sm_phic_over_tc"] < 0.25
    assert rust["ewpt_bsm_phic_over_tc"] >= 1.0
    assert rust["ewpt_bsm_degeneracy_err"] < 1e-8
