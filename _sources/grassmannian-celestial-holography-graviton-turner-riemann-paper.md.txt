---
title: "Celestial Holography, the Canonical Dictionary (Δ = 2s), Plancherel–Unruh Graviton Loop Weights (M_1 = 1/8, M_2 = 1/90), and Integrated Turner Models 15a & 15b for Gravitons and Riemann Spectral Bridges in Lean 4, Rust/PyO3, and SymPy"
description: "An arXiv-ready MyST Markdown formal verification and physics synthesis paper auditing Daniel Toupin's Celestial Holography monograph (TOUQGA-2.pdf) against our recent Riemann Hypothesis spectral papers and Turner gravity models, proving the canonical dictionary Δ = 2s, Gr(2,4)(F_q) Hasse–Weil factorization, Plancherel–Unruh blackbody loop weights (M_1 = 1/8, M_2 = 1/90, M_3 ≈ 0.0010280205), and Googly shadow-Jost T-involution in Lean 4, Rust/PyO3, and SymPy/mpmath, developing the Integrated Turner Models 15a & 15b for gravitons, and isolating the exact analytical gaps in Pathways 1–5."
---

(grassmannian-celestial-holography-graviton-turner-riemann-paper)=
# Celestial Holography, the Canonical Dictionary ($\Delta = 2s$), Plancherel–Unruh Graviton Loop Weights ($M_1 = 1/8, M_2 = 1/90$), and Integrated Turner Models 15a & 15b for Gravitons and Riemann Spectral Bridges in Lean 4, Rust/PyO3, and SymPy

- **Authors:** Wes Turner
- **Subjects:**
  - High Energy Physics - Theory (`hep-th`); General Relativity and Quantum Cosmology (`gr-qc`); Number Theory (`math.NT`); Mathematical Physics (`math-ph`); Logic & Formal Verification (`cs.LO`)
- **Epistemic Status & Scope Declaration:**
  - **Verified Mathematical & Physical Core (Machine-Checked in Lean 4, Rust/PyO3, and SymPy/`mpmath`):** We verify and formalize in `Signals.RiemannSpectral` (Section 11) and `Signals.DDF` (Section 30.7) the exact mathematical core of Celestial Holography {cite:p}`pasterski2017celestial,strominger2018,toupin2025quantum`: **(1)** uniqueness of the canonical celestial–arithmetic dictionary $\Delta = (d - 2)s = 2s$ in $d = 4$ spacetime dimensions (`celestialDictionaryUnique_two_s_and_dim_four`), **(2)** reality of the chiral $\mathfrak{sl}(2, \mathbb{C})$ Casimir $h(h-1) = s(s-1)$ on $\operatorname{Re}(s) = 1/2$ (`celestialChiralCasimir_im_eq_zero_iff_critical_line`), **(3)** the Hasse–Weil point-count polynomial $\lvert\mathrm{Gr}(2,4)(\mathbb{F}_q)\rvert = 1 + q + 2q^2 + q^3 + q^4 = (1+q^2)(1+q+q^2)$ and Poincaré self-duality (`gr24FiniteFieldPointCount_factorization_and_poincare_duality`), **(4)** the Planck / Bisognano–Wichmann Rindler boost identity $P(\lambda) = \frac{\pi\lambda}{\sinh(\pi\lambda)} = 2\pi\lambda\bigl[n_B(\pi\lambda) - n_B(2\pi\lambda)\bigr]$, exact Bernoulli rational 1-loop and 2-loop bare weights $M_1 = 1/8$ and $M_2 = 1/90$, and the $A_{L-1}$ complete-graph vs. ladder path-graph edge deficit $\binom{L}{2} - (L - 1) = \frac{(L-1)(L-2)}{2} = 0 \iff L \in \{1, 2\}$ (`celestial_plancherel_blackbody_and_loop_dichotomy_identities`), **(5)** a new compact-interval convolution identity reducing the 3-loop integral $M_3 = 0.0010280204768206812\dots < (1/8)^3$ to a 1D/2D integral with zero tail truncation, and **(6)** **Integrated Turner Models 15a (Without DDF) & 15b (With DDF)** (`turner_model_15_celestial_plucker_ddf_graviton_unification`).
  - **Open Millennium-Problem Boundary (`Signals.Pending.ToupinCelestialMillenniumPendingBoundary`):** This paper does **not** claim that Celestial Holography closes the classical Riemann Hypothesis {cite:p}`bombieri2000rh`, the Birch and Swinnerton-Dyer Conjecture, or the 4D Yang–Mills Mass Gap. Our tri-language audit identifies four specific technical and analytical gaps in Chapters 5 and 8 and Appendix B of {cite:p}`toupin2025quantum` (Section 3) and proves in `Signals.Pending.celestial_dictionary_and_cesaro_norm_do_not_close_millennium_bridges` that $\Delta = 2s$, $N_{\mathrm{reg}}(1/2) = 1$, and $M_1 = 1/8, M_2 = 1/90$ do not by themselves discharge the four global `RB-6` bridges.
- **Primary Source & Companion Papers Reviewed:**
  - Primary Audited Monograph: {cite:p}`toupin2025quantum` ({download}`data/papers/TOUQGA-2.pdf <../data/papers/TOUQGA-2.pdf>`, 970 pp., `sha256: 1546247c8104b3bf09f70f90d87de38c11fdcc986c37058935d6c8faec6d5fcc`)
  - Companion Papers Integrated:
    - [Finite Spectral Contracts for Riemann Hypothesis Approaches: The Bass–Ihara Ramanujan Dichotomy, Jensen–Pólya Transverse QFIM Stiffness, Mpemba–Trajectory–dBN Synthesis, and High-Precision Euler–Maclaurin / Riemann–Siegel $C_4(p)$ Jet Audits](grassmannian-riemann-spectral-ihara-jensen-polya-paper.md)
    - [Written Plan: Error Minimization, Mpemba–Trajectory Synthesis, and Phased Workstreams (`RB-1`–`RB-6`) for the Remaining Riemann Hypothesis Analytical Bridges](riemann-spectral-bridges-plan.md)
    - [Verified Finite Contracts for Grassmannian EBR, All 80 Crystallographic Layer Groups, PSD Slavnov–Gram DPPs, Multi-Reference NOCI, `Tequila`-Compiled Grid DSLs, and Finite-Graph Ihara–Selberg Zeta Functions](grassmannian-gebr-layer-groups-dpp-noci-arc-paper.md)
    - [Grassmannian Gravity from QED & Gauge Scattering Amplitudes: Complex $\mathrm{Gr}_{\mathbb{C}}(2,4)$ Orbital Precession, Mercury's Perihelion, $N$-Body Dynamics, and Dilatant Dark Fluid (`DDF`) Unification](grassmannian-gravity-from-qed-scattering-paper.md)
    - [Complex Grassmannian $\mathrm{Gr}_{\mathbb{C}}(2,4)$ Fubini–Study GPE, Dual-Schubert `iGPE`, Homogeneous Plücker $\mathcal{Q}_4$ Madelung Hydrodynamics, and Revised Turner (2026) Models for Superposition, Gravity, and Gravitational Waves](grassmannian-complex-gpe-igpe-plucker-madelung-paper.md)
    - [Why the Quantum Fisher Information Metric Is Four Times the Fubini–Study Kähler Metric ($F_{\mu\nu} = 4\,g_{\mu\nu}^{\mathrm{FS}}$): Three-Channel Plücker Madelung–QFIM Kinetic Decomposition on $\mathcal{Q}_4$ and Ghost-Free Turner Gravity vs. Witten's Twistor String](grassmannian-qfim-fubini-study-kahler-madelung-unification-paper.md)
    - [$\mathrm{SU}(4)$ Symmetry, Witten's Twistor String Theory, Lower Grassmannians in $\mathrm{Gr}_{\mathbb{R}}$ and $\mathrm{Gr}_{\mathbb{C}}$, Relative Merits of Cachazo vs. DDF vs. Turner Models, and Grand Unification with the Holographic Principle and AdS/CFT](grassmannian-su4-witten-twistor-string-cachazo-ddf-turner-ads-cft-unification-paper.md)
- **Formal Verification & Computational Artifacts:**
  - `Signals` Lean 4 Library (`3,632` Lake jobs, zero `sorry` axioms):
    - {download}`src/signals/Signals/RiemannSpectral.lean <../src/signals/Signals/RiemannSpectral.lean>` (Section 11: `celestialDictionaryUnique_two_s_and_dim_four`, `celestialChiralCasimir_im_eq_zero_iff_critical_line`, `gr24FiniteFieldPointCount_factorization_and_poincare_duality`, `celestial_plancherel_blackbody_and_loop_dichotomy_identities`, `adelic_cesaro_symmetry_and_offline_selfdual_counterexample`, `plancherel_fourier_sech4_and_schwartz_quartic_counterexample_identities`)
    - {download}`src/signals/Signals/DDF.lean <../src/signals/Signals/DDF.lean>` (Section 30.7: `celestialSpinTwoShadowNormFactor`, `celestialSpinTwoCayleyShadowFactor`, `celestialPlancherelLoopCorrectionFactor`, `celestialPlancherelAllLoopGeometricEnvelope`, `PlanetaryOrbit.turnerCelestialPluckerGravitonPrecessionRad`, `RiverExterior.turnerCelestialDualGr24DDFGravitonPrecessionRad`, `PlanetaryOrbit.turnerCelestialPluckerGravitonGWLuminosity`, `RiverExterior.turnerCelestialDualGr24DDFGravitonGWLuminosity`, `PlanetaryOrbit.turnerCelestialPluckerGravitonLightDeflection`, `RiverExterior.turnerCelestialDualGr24DDFGravitonLightDeflection`, `turner_model_15_celestial_plucker_ddf_graviton_unification`, `turner_model_15_critique_cayley_shadow_all_loop_and_light_deflection_identities`)
    - {download}`src/signals/Signals/Pending.lean <../src/signals/Signals/Pending.lean>` (`ToupinCelestialMillenniumPendingBoundary`, `ToupinCelestialMillenniumPendingBoundary.not_allMillenniumBridgesClosed_of_any_bridge_refuted`, `celestial_dictionary_and_cesaro_norm_do_not_close_millennium_bridges`)
    - {download}`src/signals/SignalsTests.lean <../src/signals/SignalsTests.lean>` & {download}`src/signals/SignalsPendingTests.lean <../src/signals/SignalsPendingTests.lean>`
  - `signals-numerical-adapter` Rust + PyO3 (`maturin`) Extension (`129` passing unit tests):
    - {download}`src/signals/numerical_adapter/src/riemann_spectral.rs <../src/signals/numerical_adapter/src/riemann_spectral.rs>` (`celestial_plancherel_weight`, `celestial_bose_difference_weight`, `celestial_half_line_convolution_f`, `celestial_spin_two_cayley_shadow_factor`, `celestial_plancherel_all_loop_envelope`, `gr24_hasse_weil_point_count`, `gr24_rref_subspace_count_fp`, `adelic_symmetric_cesaro_mean`, `audit_celestial_holography_and_turner_graviton`)
    - {download}`src/signals/numerical_adapter/src/lib.rs <../src/signals/numerical_adapter/src/lib.rs>` (`py_audit_celestial_holography_and_turner_graviton`)
  - Python + SymPy + 45-Digit `mpmath` + PyO3 Verification Suite:
    - {download}`sustainablefactory/riemann_rh_bridges.py <../sustainablefactory/riemann_rh_bridges.py>` (`audit_celestial_holography_toupin_and_turner_graviton`)
    - {download}`tests/test_riemann_spectral_sympy_pyo3.py <../tests/test_riemann_spectral_sympy_pyo3.py>` (`test_celestial_holography_toupin_and_turner_model15_sympy_mpmath_pyo3`)

---

## Abstract

We review Daniel Toupin's 970-page monograph *On the Nature of Nature: Celestial Holography to the Zeta Zeros* ({cite:p}`toupin2025quantum`, {download}`data/papers/TOUQGA-2.pdf <../data/papers/TOUQGA-2.pdf>`) alongside our recent Riemann Hypothesis spectral papers ([Finite Spectral Contracts for RH Approaches](grassmannian-riemann-spectral-ihara-jensen-polya-paper.md), [RH Analytical Bridges Plan `RB-1`–`RB-6`](riemann-spectral-bridges-plan.md), and [Grassmannian EBR & Finite-Graph Ihara–Selberg Zeta](grassmannian-gebr-layer-groups-dpp-noci-arc-paper.md)) and our Turner (2026) gravity models (`Signals.QEDGravity`, `Signals.DDF`, `Signals.DFT`). We ask two concrete scientific questions: **(1) What rigorous mathematical and physical structures can we learn from Celestial Holography and verify in Lean 4, Rust/PyO3, and SymPy/mpmath, and where do the Millennium-Prize arguments in {cite:p}`toupin2025quantum` encounter open analytical gaps?** and **(2) How does reviewing our Turner gravity models in regards to gravitons allow us to build a more integrated graviton model (`Turner Models 15a & 15b`)?**

Our tri-language investigation establishes five principal results:

1. **Five Machine-Checked Celestial–Arithmetic Theorems Extracted from {cite:p}`toupin2025quantum` (`Signals.RiemannSpectral` Section 11):**
   - **Canonical Dictionary $\Delta = 2s$ & Specialness of $d = 4$ Spacetime Dimensions (`celestialDictionaryUnique_two_s_and_dim_four`):** Intertwining the functional-equation reflection $s \mapsto 1 - s$ with the $d$-dimensional celestial shadow involution $\Delta \mapsto (d - 2) - \Delta$ and mapping the zeta pole $s = 1 \mapsto \Delta_T = d - 2$ uniquely selects $\Delta(s) = (d - 2)s$, whose slope $d - 2$ matches the $\mathrm{Gr}(2, d)$ Plücker exterior rank $k = 2$ **if and only if $d = 4$** ($\Delta = 2s$).
   - **Chiral $\mathfrak{sl}(2, \mathbb{C})$ Casimir Reality on the Critical Line (`celestialChiralCasimir_im_eq_zero_iff_critical_line`):** Under $h = \Delta(s)/2 = s = (\tfrac{1}{2} + \sigma_{\mathrm{dev}}) + i\gamma$, the chiral Casimir $h(h-1) = s(s-1)$ expands to $\bigl(-\tfrac{1}{4} + \sigma_{\mathrm{dev}}^2 - \gamma^2\bigr) + 2 i \sigma_{\mathrm{dev}}\gamma$, which for any $\gamma \ne 0$ is real **if and only if $\sigma_{\mathrm{dev}} = 0$** ($\operatorname{Re}(s) = 1/2$).
   - **Hasse–Weil $\mathrm{Gr}(2,4)(\mathbb{F}_q)$ Factorization & Self-Dual Middle Cohomology (`gr24FiniteFieldPointCount_factorization_and_poincare_duality`):** From the six Schubert cells $\mathbb{A}^{|\lambda|}$ ($\lambda \subseteq (2,2)$) with even Betti numbers $(b_0, b_2, b_4, b_6, b_8) = (1, 1, 2, 1, 1)$, $\lvert\mathrm{Gr}(2,4)(\mathbb{F}_q)\rvert = 1 + q + 2q^2 + q^3 + q^4 = (1+q^2)(1+q+q^2)$ satisfies exact palindromic Poincaré duality $q^4 P(1/q) = P(q)$, matching brute-force RREF subspace enumeration over $\mathbb{F}_2$ ($35$), $\mathbb{F}_3$ ($130$), and $\mathbb{F}_5$ ($806$) and factoring $\zeta_{\mathrm{Gr}(2,4)}(s) = \zeta(s)\zeta(s-1)\zeta(s-2)^2\zeta(s-3)\zeta(s-4)$ to $< 1.88 \times 10^{-46}$ across the first 15 primes.
   - **Plancherel–Unruh Blackbody Identity, Exact Rational $M_1 = 1/8, M_2 = 1/90$, and the $L \in \{1, 2\}$ vs. $L \ge 3$ Graph Dichotomy (`celestial_plancherel_blackbody_and_loop_dichotomy_identities`):** The $\mathrm{SL}(2, \mathbb{C})$ Plancherel weight $P(\lambda) = \lvert\Gamma(1+i\lambda)\rvert^2 = \frac{\pi\lambda}{\sinh(\pi\lambda)}$ equals the Rindler/Unruh boost Bose–Einstein difference $2\pi\lambda\bigl[n_B(\pi\lambda) - n_B(2\pi\lambda)\bigr]$ at $\beta_{\mathrm{BW}} = 2\pi$ {cite:p}`bisognano1975duality` (`2.22e-16` max residual). Its 1-loop and 2-loop bare ladder integrals evaluate to the exact Bernoulli rationals $M_1 = 1/8$ and $M_2 = 1/90 < M_1^2 = 1/64$, governed by the complete-graph vs. path-graph edge deficit $\binom{L}{2} - (L - 1) = \frac{(L-1)(L-2)}{2} = 0 \iff L \in \{1, 2\}$.
   - **Compact-Interval Reduction for the 3-Loop Weight $M_3$:** Using Fourier–Parseval differentiation of $\operatorname{sech}^4(k/2)$, we derive an exact compact-interval formula for the half-line Plancherel rung convolution $F(y) = \frac{1+y^2}{12}P(y) + \frac{y}{2\pi}\int_0^{1/2} P(uy)P((1-u)y)\,du$, reproducing Toupin's 44-digit 3-loop constant $M_3 = 0.0010280204768206812\dots < 1/512$ to $2.10 \times 10^{-15}$ in Rust `f64` and $2.58 \times 10^{-26}$ in `mpmath` while decomposing $M_3 = M_{3,\mathrm{even}} (0.0005990322) + M_{3,\mathrm{odd}} (0.0004289882)$.
2. **Constructive Epistemic Audit of Pathways 1–5 and Appendix B of {cite:p}`toupin2025quantum`:**
   - **Pathway 1 & 3 Cesàro Symmetry Correction (`adelic_cesaro_symmetry_and_offline_selfdual_counterexample`):** In `TOUQGA-2.pdf` Eq. (8.242) (p. 432) and Theorem 8.86 (p. 449), the symmetric Cesàro norm $N_{\mathrm{reg}}(\sigma)$ is claimed to vanish ($N_{\mathrm{reg}} = 0$, a "zero-norm ghost") for $\sigma < 1/2$ and diverge to $+\infty$ for $\sigma > 1/2$. We prove in Lean 4 and verify in Rust/Python that on the Haar measure $d^\times r = dr/r$, $N_{\mathrm{reg}}(\sigma, R) = \frac{\sinh((2\sigma-1)\ln R)}{(2\sigma-1)\ln R}$ is **strictly even** in $\sigma_{\mathrm{dev}} = \sigma - 1/2$ (`N_reg(0.25, 10^4) = N_reg(0.75, 10^4) = 10.856276 > 1 = N_reg(0.50, 10^4)`), diverging to $+\infty$ on **both** sides of $\sigma = 1/2$.
   - **Pathway 2 & 4 Meyer Fréchet-to-Hilbert Gap (`ToupinCelestialMillenniumPendingBoundary`):** While $N_{\mathrm{reg}}(\sigma) < \infty \iff \sigma = 1/2$ characterizes unitary characters on $L^2(\mathbb{A}^\times/\mathbb{Q}^\times)$ {cite:p}`tate1950fourier`, Meyer's unconditional spectral realization {cite:p}`meyer2005spectral` lives on a quotient of nuclear Fréchet spaces; assuming that every zero $\rho$ of $\zeta(s)$ descends to a normalizable state in the unitary GNS Hilbert space is equivalent to **Open Bridge 4** (`selfAdjointSpectralOperatorClosure`).
   - **Pathway 3 Biane–Pitman–Yor Kernel Slip & Off-Line Density Counterexample:** In `TOUQGA-2.pdf` Eqs. (8.277)–(8.281) (pp. 457–458), the alternating Kolmogorov–Smirnov series $2\sum_{k=1}^\infty (-1)^{k+1}e^{-2k^2\pi^2 v^2}$ is used in place of the Biane–Pitman–Yor Kuiper range tail $2\sum_{k=1}^\infty (2\pi k^2 v^2 - 1)e^{-\pi k^2 v^2}$ {cite:p}`biane2001probability`, producing a `0.963864` discrepancy against $2\xi(2)$ and introducing the Dirichlet eta factor $(1 - 2^{1-s})\zeta(s)$—whose own positive random variable $M = \sup_{0\le t\le 1}\lvert B_t\rvert > 0$ on the Brownian-bridge probability space has infinitely many Mellin zeros on $\operatorname{Re}(s) = 1 \ne 1/2$! We also construct an explicit smooth self-dual positive density $g(u) = (u^2 - 4)^2 e^{-u^2/2} \ge 0$ whose Mellin transform vanishes at $(s - 1/2)^2 = 1 \pm i\sqrt{10}$ ($\operatorname{Re}(s) \ne 1/2$).
   - **Appendix B.2 Central-Charge $c(\epsilon)$ Power-Counting Audit:** SymPy Laurent expansion shows that `compute_gamma_ratio(epsilon)` in `TOUQGA-2.pdf` Appendix B.2 (pp. 931–937) has leading pole $+8/\epsilon$ (rather than $-4/\epsilon$ on p. 934 or $+2/\epsilon$ on p. 936 because $\operatorname{Res}_{z=-2}\Gamma(z) = +1/2! = +1/2$), and `stress_tensor_ope_coefficient(epsilon)` divides by `shadow_norm = 1.0 / epsilon` instead of multiplying, forcing $c_{\mathrm{B.2}}(\epsilon) = 2 R(\epsilon)(\pi^2\epsilon)/(1/\epsilon) = 16\pi^2\epsilon + O(\epsilon^2) \to 0$ by an explicit $\epsilon^2$ factor.
3. **Review of Our Turner Gravity Models in Regards to "Gravitons" & Development of Integrated Turner Models 15a & 15b (`Signals.DDF` Section 30.7):**
   - Reviewing how gravitons are represented across all 14 existing models in `Signals.QEDGravity`, `Signals.DDF`, and `Signals.DFT`, we show that Toupin's resolution of Penrose's 50-year **Googly Problem** (Theorem 5.148: the shadow transform $(\Delta, J) \mapsto (2-\Delta, -J)$ is the boundary restriction of the Jost involution $\Theta|_{\mathcal{I}} = T$ {cite:p}`jost1957bemerkung`) provides the exact asymptotic boundary dual to our **Dual-Grassmannian $\mathrm{Gr}_{\mathbb{C}}(2,4) \times \mathrm{Gr}_{\mathbb{C}}(2,4)^\vee$ `iGPE` formulation** (where middle cohomology $b_4(\mathrm{Gr}(2,4)) = 2$ splits into self-dual $J = +2$ and anti-self-dual $J = -2$ Plücker sectors, locked at $T$-symmetric equilibrium when $s_{\mathrm{dual}} = s_{\mathrm{real}}$).
   - Combining the Klein-quadric Fubini–Study Kähler determinant excess $\mathcal{D}(W_{\mathrm{orb}}) - 3 = 1 - e^2 = p/a$ ($F_{\mu\nu} = 4\,g_{\mu\nu}^{\mathrm{FS}}$, matching the spin-2 graviton helicity square $J^2 = (\pm 2)^2 = 4$), the celestial principal-series shadow norm factor $\mathcal{W}_{\mathrm{grav}}(\sigma_{\mathrm{dev}}) = 1 - 4\sigma_{\mathrm{dev}}^2$, and the UV-finite Plancherel–Unruh loop factor $\mathcal{F}_{\mathrm{loop}}(\alpha_{\mathrm{QG}}) = 1 + \frac{1}{8}\alpha_{\mathrm{QG}} + \frac{1}{90}\alpha_{\mathrm{QG}}^2$ yields **Integrated Turner Model 15a (Without DDF, $\eta_{\mathrm{act}}^\gamma = 1$)** and **Integrated Turner Model 15b (With DDF, $\eta_{\mathrm{act}}^\gamma = 0$)**, proved in `turner_model_15_celestial_plucker_ddf_graviton_unification`.

---

## 1. Architecture: What We Learn from Celestial Holography (`TOUQGA-2.pdf`) vs. Our Recent Papers

```{mermaid}
flowchart TB
    subgraph Toupin["Celestial Holography Monograph (Toupin 2025/2026, TOUQGA-2.pdf)"]
        T1["1. Canonical Dictionary Δ = 2s (Ch. 7)\n• Plücker rank k = 2 on Gr(2,4)\n• d = 4 Plancherel ratio (d-2)/2 : 1/2 = 2\n• Chiral sl(2,C) Casimir h(h-1) = s(s-1)"]
        T2["2. Googly Resolution & Jost Θ|_I = T (Sec. 5.8)\n• Shadow (Δ, J) ↔ (2-Δ, -J) = Time Reversal T\n• Antiunitary MHV/anti-MHV equality on Δ = 1 + iλ\n• Gr(2,4)(F_q) Hasse–Weil b_4 = 2 SD/ASD split"]
        T3["3. Plancherel–Unruh Loop Measure (Sec. 5.8.5)\n• P(λ) = πλ/sinh(πλ) = 2πλ[n_B(πλ) - n_B(2πλ)]\n• All-loop UV bound M_L ≤ (1/8)^L\n• Exact M_1 = 1/8, M_2 = 1/90 vs. L ≥ 3 dichotomy"]
        T4["4. Five RH Pathways & Millennium Claims (Ch. 8–11)\n• Pathway 1: Adelic Cesàro N_reg(σ)\n• Pathway 2: Meyer–Stone spectral embedding\n• Pathway 3: Biane–Pitman–Yor Brownian bridge\n• Pathway 4: Celestial c = 0 BMS_4 partition function\n• Pathway 5: Yakaboylu Fermi–Dirac completeness"]
    end

    subgraph Verified["Machine-Checked Upgrades in Signals (Lean 4 + Rust/PyO3 + SymPy)"]
        V1["Signals.RiemannSpectral Sec. 11:\n• celestialDictionaryUnique_two_s_and_dim_four\n• celestialChiralCasimir_im_eq_zero_iff_critical_line\n• gr24FiniteFieldPointCount_factorization_and_poincare_duality"]
        V2["Signals.RiemannSpectral Sec. 11 & riemann_spectral.rs:\n• celestial_plancherel_blackbody_and_loop_dichotomy_identities\n• Compact 1D/2D convolution F(y) for M_3 (< 2.1e-15 in Rust)\n• Googly MHV shadow-conjugation check (0.0 vs. 0.949 off-line)"]
        V3["Signals.DDF Sec. 30.7 (Integrated Turner Models 15a & 15b):\n• turner_model_15_celestial_plucker_ddf_graviton_unification\n• Unites Q_4 Kähler (F = 4 g^FS, J² = 4), Dual-Gr(2,4) Googly T-lock,\n  Plancherel UV loop series 1 + α/8 + α²/90, & DDF η_act^γ ∈ {0,1}"]
    end

    subgraph Audit["Epistemic Audit & RB-6 Pending Gate (Signals.Pending)"]
        A1["1. Cesàro Symmetry Fix: N_reg(1/2 - δ) = N_reg(1/2 + δ) > 1\n   (refutes σ < 1/2 zero-norm claim in Eq. 8.242 / Thm. 8.86)\n2. BPY Kernel Fix: Eq. 8.277–8.281 used KS (1-2^{1-s})ζ(s) instead of\n   Kuiper 2ξ(s); KS density p_M > 0 has zeros on Re(s) = 1 ≠ 1/2!\n3. App. B.2 Fix: R(ε) ~ +8/ε and / (1/ε) creates O(ε) artifact\n4. ToupinCelestialMillenniumPendingBoundary gates RB-6 Bridges 1–4"]
    end

    T1 --> V1
    T2 --> V2
    T3 --> V2
    V1 --> V3
    V2 --> V3
    T4 --> Audit
```

---

## 2. Five Machine-Checked Mathematical & Physical Discoveries from Celestial Holography (`Signals.RiemannSpectral` Section 11)

### 2.1 Why $\Delta = 2s$ and Why Four Spacetime Dimensions ($d = 4$) Are Uniquely Selected

In celestial holography {cite:p}`pasterski2017celestial,strominger2018`, massless four-dimensional scattering amplitudes are Mellin-transformed over light-cone energy $\omega \in (0, \infty)$ into correlation functions of conformal primaries $O_\Delta^J(z, \bar{z})$ on the 2D celestial sphere $\mathcal{CS}^2 \cong \mathbb{CP}^1 = \mathrm{Gr}_{\mathbb{C}}(1,2)$:

$$
O_\Delta^J(z, \bar{z}) = \int_0^\infty d\omega\,\omega^{\Delta - 1}\,a_\omega^J(z, \bar{z}).
$$

In $d$ spacetime dimensions, the celestial sphere $S^{d-2}$ has dimension $d - 2$, the shadow transform acts as $\Delta \mapsto (d - 2) - \Delta$ with principal-series unitary axis $\operatorname{Re}(\Delta) = \rho_0^{\mathrm{cel}}(d) = \frac{d - 2}{2}$, and the stress tensor has conformal dimension $\Delta_T = d - 2$. On the arithmetic side {cite:p}`tate1950fourier`, the completed Riemann zeta function $\xi(s) = \xi(1 - s)$ has functional-equation involution $s \mapsto 1 - s$, critical line $\operatorname{Re}(s) = \rho_0^{\mathrm{ad}} = \frac{1}{2}$, and simple pole at $s = 1$.

In `Signals.RiemannSpectral.celestialDictionaryUnique_general_dim` and `celestialDictionaryUnique_two_s_and_dim_four` ({download}`src/signals/Signals/RiemannSpectral.lean <../src/signals/Signals/RiemannSpectral.lean>`), we prove Toupin's Theorem 7.1 / Lemma 7.3 ({cite:p}`toupin2025quantum`, pp. 342–348):

1. **Uniqueness of the Affine Intertwiner:** Any affine map $\varphi(s) = \alpha s + \beta$ satisfying

   $$
   \forall s \in \mathbb{R},\quad (d - 2) - (\alpha s + \beta) = \alpha(1 - s) + \beta \qquad\text{and}\qquad \varphi(1) = d - 2
   $$

   uniquely satisfies $\alpha = d - 2$ and $\beta = 0$, so $\Delta(s) = (d - 2)s$.
2. **Why $d = 4$ Is Uniquely Compatible with Plücker Geometry:** Under the Penrose–Ward correspondence {cite:p}`penrose1967twistor`, null rays in $d$-dimensional spacetime correspond to 2-planes in $\mathrm{Gr}(2, d)$, whose Plücker embedding $\mathrm{Gr}(2, d) \hookrightarrow \mathbb{P}(\bigwedge^2 \mathbb{C}^d)$ carries central $\mathrm{GL}(1)$ exterior weight $k = 2$ (reflecting $\omega = \lvert\kappa\rvert^2$ for a Weyl spinor $\kappa^\alpha$). The celestial Plancherel slope $\alpha(d) = d - 2$ equals the Plücker exterior rank $k = 2$ **if and only if $d = 4$**:

   $$
   \alpha(d) = d - 2 = 2 \iff d = 4 \implies \Delta = 2s, \qquad \rho_0^{\mathrm{cel}}(4) = 1 \in \mathbb{Z}.
   $$

| Spacetime Dimension $d$ | Celestial Sphere $S^{d-2}$ | Principal-Series Abscissa $\rho_0^{\mathrm{cel}}(d) = \frac{d-2}{2}$ | Dictionary Slope $\alpha(d) = d - 2$ | $\mathrm{Gr}(2,d)$ Plücker Rank $k$ | Self-Dual $\mathrm{Gr}(2,d) \cong \mathrm{Gr}(d-2,d)$? | Matches $\alpha(d) = k = 2$? |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| $d = 3$ | $S^1$ | $1/2$ (half-integer) | $1$ | $2$ | No ($\mathrm{Gr}(2,3) \cong \mathrm{Gr}(1,3)$) | No ($1 \ne 2$) |
| **$d = 4$** | **$S^2 \cong \mathbb{CP}^1$** | **$1$ (integer)** | **$2$ ($\Delta = 2s$)** | **$2$** | **Yes ($\mathrm{Gr}(2,4) \cong \mathrm{Gr}(2,4)^\vee$)** | **Yes ($2 = 2$)** |
| $d = 5$ | $S^3$ | $3/2$ (half-integer) | $3$ | $2$ | No ($\mathrm{Gr}(2,5) \cong \mathrm{Gr}(3,5)$) | No ($3 \ne 2$) |
| $d = 6$ | $S^4$ | $2$ (integer) | $4$ | $2$ | No ($\mathrm{Gr}(2,6) \cong \mathrm{Gr}(4,6)$) | No ($4 \ne 2$) |

### 2.2 Chiral $\mathfrak{sl}(2, \mathbb{C})$ Casimir Eigenvalue Reality on the Critical Line

For a scalar/chiral celestial block of weight $h = \Delta(s)/2 = s$ with $s = \bigl(\tfrac{1}{2} + \sigma_{\mathrm{dev}}\bigr) + i\gamma$, the quadratic $\mathfrak{sl}(2, \mathbb{C})$ Casimir eigenvalue is $h(h - 1) = s(s - 1) = -s(1 - s)$ ({cite:p}`toupin2025quantum`, Eq. 5.494, p. 263). Theorem `celestialChiralCasimir_im_eq_zero_iff_critical_line` in `Signals.RiemannSpectral` proves:

$$
s(s - 1) = \underbrace{\left(-\frac{1}{4} + \sigma_{\mathrm{dev}}^2 - \gamma^2\right)}_{\operatorname{Re}(s(s-1))} + i\,\underbrace{\left(2\,\sigma_{\mathrm{dev}}\,\gamma\right)}_{\operatorname{Im}(s(s-1))}.
$$

Consequently, for any non-zero spectral ordinate $\gamma \ne 0$:
1. The chiral $\mathfrak{sl}(2, \mathbb{C})$ Casimir eigenvalue $s(s - 1)$ is **real if and only if $\sigma_{\mathrm{dev}} = 0$** ($\operatorname{Re}(s) = 1/2 \iff \operatorname{Re}(\Delta) = 1$);
2. On the critical line ($\sigma_{\mathrm{dev}} = 0$), $s(s - 1) = -\frac{1}{4} - \gamma^2 \le -\frac{1}{4}$ (the Bargmann principal-series threshold), and the full 2D Casimir is $C_2(\Delta) = -\Delta(\Delta - 2) = -4s(s - 1) = 1 + 4\gamma^2 = 1 + \lambda^2 \ge 1$.

### 2.3 Hasse–Weil Zeta Factorization of $\mathrm{Gr}(2,4)$ Over $\mathbb{F}_q$ and Self-Dual Middle Cohomology ($b_4 = 2$)

Because $\mathrm{Gr}(2,4)$ is stratified by six affine Schubert cells $C_\lambda \cong \mathbb{A}^{|\lambda|}$ indexed by partitions $\lambda \subseteq (2, 2)$ of sizes $0, 1, 2, 2, 3, 4$, its even étale/singular Betti numbers are $(b_0, b_2, b_4, b_6, b_8) = (1, 1, 2, 1, 1)$ with Euler characteristic $\chi(\mathrm{Gr}(2,4)) = 6 = \binom{4}{2}$. Over any finite field $\mathbb{F}_q$, the number of $\mathbb{F}_q$-rational 2-planes in $\mathbb{F}_q^4$ is the Gaussian binomial coefficient (`gr24FiniteFieldPointCount` in `Signals.RiemannSpectral`):

$$
\left\lvert\mathrm{Gr}(2,4)(\mathbb{F}_q)\right\rvert = \binom{4}{2}_q = \frac{(q^4 - 1)(q^3 - 1)}{(q^2 - 1)(q - 1)} = 1 + q + 2q^2 + q^3 + q^4 = (1 + q^2)(1 + q + q^2).
$$

Theorem `gr24FiniteFieldPointCount_factorization_and_poincare_duality` proves in Lean 4 that this polynomial satisfies exact palindromic Poincaré / orthogonal-complement duality $q^4 P_{\mathrm{Gr}(2,4)}(1/q) = P_{\mathrm{Gr}(2,4)}(q)$, so the Hasse–Weil zeta function of $\mathrm{Gr}(2,4)$ over $\mathbb{Q}$ factors into shifted Riemann zeta functions ({cite:p}`toupin2025quantum`, Theorem 7.11, p. 350):

$$
\zeta_{\mathrm{Gr}(2,4)}(s) = \prod_{k=0}^4 \zeta(s - k)^{b_{2k}} = \zeta(s)\,\zeta(s - 1)\,\zeta(s - 2)^2\,\zeta(s - 3)\,\zeta(s - 4).
$$

- The trivial cohomology $H^0(\mathrm{Gr}(2,4))$ ($b_0 = 1$) contributes **$\zeta(s)$ itself**;
- The two-dimensional middle cohomology $H^4(\mathrm{Gr}(2,4), \mathbb{Z}) \cong \mathbb{Z}^2$ ($b_4 = 2$, spanned by the orthogonal Schubert classes $\sigma_{(2,0)}$ and $\sigma_{(1,1)}$) contributes the squared factor **$\zeta(s - 2)^2$**, which geometrically encodes the split-signature $(3,3)$ decomposition of $\bigwedge^2 \mathbb{C}^4$ into **self-dual ($J = +2$) and anti-self-dual ($J = -2$) graviton sectors**!
- In `riemann_spectral.rs` (`gr24_rref_subspace_count_fp`) and `riemann_rh_bridges.py`, we verify that RREF Schubert-cell subspace enumeration over $\mathbb{F}_p$ matches $1 + p + 2p^2 + p^3 + p^4$ identically ($\lvert\mathrm{Gr}(2,4)(\mathbb{F}_2)\rvert = 35$, $\lvert\mathrm{Gr}(2,4)(\mathbb{F}_3)\rvert = 130$, $\lvert\mathrm{Gr}(2,4)(\mathbb{F}_5)\rvert = 806$, $\lvert\mathrm{Gr}(2,4)(\mathbb{F}_7)\rvert = 2850$), and that the local Euler product matches $\prod_{k=0}^4 (1 - p^{k-s})^{-b_{2k}}$ to **$1.87 \times 10^{-46}$** at $s = 3.7 + 2.1i$.

### 2.4 The Plancherel–Unruh Blackbody Law, Rational $M_1 = 1/8, M_2 = 1/90$, and Compact-Interval 3-Loop $M_3$ Reduction

One of the strongest mathematical contributions in {cite:p}`toupin2025quantum` (Section 5.8.5, Theorems 5.179–5.186, pp. 256–263) is the analysis of the bare $L$-loop celestial ladder measure built from the $\mathrm{SL}(2, \mathbb{C})$ Plancherel weight:

$$
P(\lambda) = \lvert\Gamma(1 + i\lambda)\rvert^2 = \frac{\pi\lambda}{\sinh(\pi\lambda)} \in (0, 1], \qquad M_L = \frac{1}{(2\pi)^L}\int_{\mathbb{R}_{>0}^L} \left[\prod_{j=1}^L P(\lambda_j)\right]\left[\prod_{j=1}^{L-1} P(\lvert\lambda_j - \lambda_{j+1}\rvert)\right]d\lambda_1\cdots d\lambda_L.
$$

In `Signals.RiemannSpectral.celestial_plancherel_blackbody_and_loop_dichotomy_identities`, `riemann_spectral.rs`, and `riemann_rh_bridges.py`, we verify and extend four exact results:

1. **Planck / Bisognano–Wichmann Rindler Boost Identity ({cite:p}`bisognano1975duality`; {cite:p}`toupin2025quantum`, Theorem 5.183):**
   Because $\frac{1}{e^y - 1} - \frac{1}{e^{2y} - 1} = \frac{e^y}{e^{2y} - 1} = \frac{1}{2\sinh y}$, the Plancherel weight is identically the difference of two Bose–Einstein distributions at the Rindler wedge Unruh inverse temperature $\beta_{\mathrm{BW}} = 2\pi$ ($T_{\mathrm{Unruh}} = 1/(2\pi)$):

   $$
   P(\lambda) = \frac{\pi\lambda}{\sinh(\pi\lambda)} = 2\pi\lambda\bigl[n_B(\pi\lambda) - n_B(2\pi\lambda)\bigr] = 2\pi\lambda\sum_{n=0}^\infty e^{-2\pi\lambda(n + 1/2)},
   $$

   where the half-integer zero-point energies cancel between the shadow-doubled pair $\{\pi\lambda, 2\pi\lambda\}$ ($2\cdot\frac{\pi\lambda}{2} - \frac{2\pi\lambda}{2} = 0$) and remove the $p = 2$ Euler factor from the Stefan–Boltzmann moments:

   $$
   \mathcal{M}_s = \frac{1}{2\pi}\int_0^\infty \lambda^{s-1} P(\lambda)\,d\lambda = \pi^{-(s+1)}\bigl(1 - 2^{-(s+1)}\bigr)\Gamma(s+1)\zeta(s+1) = \pi^{-(s+1)}\Gamma(s+1)\eta(s+1).
   $$

2. **All-Loop UV Finiteness Bound $0 < M_L \le (1/8)^L$ and Rational 1-Loop / 2-Loop Weights ({cite:p}`toupin2025quantum`, Theorems 5.179–5.180):**
   Since $0 < P(\lambda_j - \lambda_{j+1}) \le 1$, discarding the $L - 1$ rung factors bounds $M_L \le M_1^L = (1/8)^L$ unconditionally for all $L \ge 1$. At $L = 1$ and $L = 2$:

   $$
   M_1 = \pi^{-2}\left(1 - 2^{-2}\right)\Gamma(2)\zeta(2) = \frac{3}{4}\cdot\frac{1}{6} = \frac{1}{8} = 0.125, \qquad M_2 = \frac{1}{3}\cdot\frac{1}{(2\pi)^2}\cdot\frac{2\pi^2}{15} = \frac{1}{90} \approx 0.011111111111111112 < \frac{1}{64}.
   $$

3. **Path-Graph vs. Complete-Graph Chamber Dichotomy ({cite:p}`toupin2025quantum`, Lemma 5.181 & Theorem 5.182):**
   Why does the $S_3$ ($A_2$) Weyl-chamber Parseval mechanism yield rational Bernoulli fractions at $L = 1, 2$ but fail for $L \ge 3$? Because the $L$-vertex ladder path graph has $L - 1$ edges whereas the complete graph $K_L$ ($A_{L-1}$ root system) has $\binom{L}{2}$ edges (`celestialLoopCompleteMinusPathEdges`):

   $$
   \binom{L}{2} - (L - 1) = \frac{(L - 1)(L - 2)}{2} = \begin{cases} 0, & L \in \{1, 2\}, \\ 1, & L = 3, \\ 3, & L = 4, \\ 6, & L = 5. \end{cases}
   $$

4. **New Compact-Interval Reduction for the 3-Loop Integral $M_3$ (`celestial_half_line_convolution_f`):**
   On the 3-vertex path graph $1 - 2 - 3$, the outer loop variables $\lambda_1, \lambda_3 \in (0, \infty)$ couple only to the middle variable $\lambda_2 = y > 0$, factoring the 3D integral into a 1D integral of the squared half-line convolution $F(y) := \frac{1}{2\pi}\int_0^\infty P(x)P(x - y)\,dx$:

   $$
   M_3 = \frac{1}{2\pi}\int_0^\infty P(y)\,\bigl[F(y)\bigr]^2\,dy.
   $$

   Furthermore, using the exact differential identity $\operatorname{sech}^4(k/2) = \frac{2}{3}\bigl(1 - \frac{d^2}{dk^2}\bigr)\operatorname{sech}^2(k/2)$ on the Fourier transform $\hat{P}(k) = \frac{\pi}{2}\operatorname{sech}^2(k/2)$, we prove that the full-line convolution equals $F(y) + F(-y) = \frac{1 + y^2}{6}P(y)$, while $F(y) - F(-y) = \frac{1}{2\pi}\int_0^y P(x)P(y - x)\,dx$. Averaging the two yields an **exact compact-interval representation** with zero infinite-tail truncation:

   $$
   F(y) = \underbrace{\frac{1 + y^2}{12}\,P(y)}_{A_{\mathrm{even}}(y)} + \underbrace{\frac{y}{2\pi}\int_0^{1/2} P(u y)\,P\bigl((1 - u)y\bigr)\,du}_{B_{\mathrm{odd}}(y)}.
   $$

   In Rust `f64` (`audit_celestial_holography_and_turner_graviton`), 8-point Gauss–Legendre quadrature evaluates $M_1, M_2, M_3$ in $< 0.2\text{ ms}$ to **$2.10 \times 10^{-15}$**, matching 45-digit `mpmath` and separating $M_3$ into its even $A_2$-chamber baseline $M_{3,\mathrm{even}} = 0.000599032245$ and its ordered-chamber excess $M_{3,\mathrm{odd}} = 0.000428988232$:

| Loop Order $L$ | Missing $K_L$ Edges $\frac{(L-1)(L-2)}{2}$ | Exact / 45-Digit `mpmath` Value $M_L$ | Rust `f64` Gauss–Legendre Value | Rust `f64` Absolute Error | All-Loop UV Bound $(1/8)^L$ |
| :---: | :---: | :--- | ---: | ---: | ---: |
| **$L = 1$** | `0` | $1/8 = 0.1250000000000000$ | `0.1249999999999969` | **`3.12e-15`** | `0.12500000` (saturated) |
| **$L = 2$** | `0` | $1/90 \approx 0.0111111111111111$ | `0.0111111111111151` | **`4.02e-15`** | `0.01562500` ($1/64$) |
| **$L = 3$** | **`1`** | `0.0010280204768207` (`diff = 2.58e-26`) | `0.0010280204768228` | **`2.10e-15`** | `0.001953125` ($1/512$) |

---

## 3. Constructive Epistemic Audit of the Five RH Pathways and Appendix B in `TOUQGA-2.pdf`

Following our research-evidence triage and `RB-6` formal verification protocol ([RH Analytical Bridges Plan](riemann-spectral-bridges-plan.md)), we audited every step of Chapters 5 and 8 and Appendix B of {cite:p}`toupin2025quantum`. Table 3.1 summarizes what is rigorously proved versus the exact technical or analytical gap in each pathway.

### Table 3.1: Epistemic Audit of the Five RH Pathways and Appendix B in {cite:p}`toupin2025quantum`

| Pathway / Section in `TOUQGA-2.pdf` | Validated Mathematical Core | Concrete Technical / Analytical Gap Identified by Tri-Language Audit | Corresponding `Signals` Formalization |
| :--- | :--- | :--- | :--- |
| **Pathway 1: Adelic Cesàro $L^2$ Norm** (Sec. 8.3, pp. 398–405; Sec. 8.4.3, pp. 430–433) | Unitary scaling characters $\lvert a\rvert^{s-1/2}$ on $\mathbb{R}_+^\times$ have finite Cesàro GNS norm $N_{\mathrm{reg}}(\sigma) = 1$ iff $\sigma = 1/2$ {cite:p}`tate1950fourier`. | **1.** Eq. (8.239)–(8.242) (p. 431–432) & Thm. 8.86 (p. 449) claim $N_{\mathrm{reg}}(\sigma) = 0$ ("zero-norm ghost") for $\sigma < 1/2$. On $d^\times r = dr/r$, $N_{\mathrm{reg}}(\sigma, R) = \frac{\sinh((2\sigma-1)\ln R)}{(2\sigma-1)\ln R}$ is **even** around $\sigma = 1/2$ (`N_reg(0.25) = N_reg(0.75) = 10.856 > 1`), diverging to $+\infty$ on **both** sides.<br>**2.** Proving that a character is unitary iff $\sigma = 1/2$ does not prove that zeta zeros $\rho$ produce unitary GNS eigenstates. | `adelic_cesaro_symmetry_and_offline_selfdual_counterexample`, `adelic_symmetric_cesaro_mean` |
| **Pathway 2: Meyer–Stone Spectral Rigidity** (Sec. 8.4, Thm. 8.55, pp. 420–442) | Stone's theorem makes $A = i\frac{d}{d\ln\lvert a\rvert}$ self-adjoint on the unitary GNS Hilbert space $\mathcal{H}_{\mathrm{GNS}}$. | In Meyer's unconditional theorem {cite:p}`meyer2005spectral`, the zero spectrum $\rho$ arises on a quotient of **nuclear Fréchet spaces** $\mathcal{S}_0(\mathbb{A}^\times/\mathbb{Q}^\times)'$, not inside $\mathcal{H}_{\mathrm{GNS}}$. Assuming $\mu_W = \mu_A$ on $\mathcal{H}_{\mathrm{GNS}}$ (Thm. 8.55(ii) / "Born Rule Bridge" Thm. 8.64) is equivalent to **Open Bridge 4**. | `ToupinCelestialMillenniumPendingBoundary.meyerFrechetToGnsHilbertBridge` |
| **Pathway 3: Biane–Pitman–Yor Brownian Bridge** (Sec. 8.5, Thm. 8.84–8.86, pp. 443–450) | Biane–Pitman–Yor {cite:p}`biane2001probability` proved $\mathbb{E}[V_{\mathrm{BPY}}^s] = 2\xi(s)$ for the rescaled Kuiper range of a Brownian bridge. | **1.** Eqs. (8.277)–(8.281) (pp. 457–458) substitute the **Kolmogorov–Smirnov** alternating series $2\sum (-1)^{k+1}e^{-2k^2\pi^2 v^2}$ for the Kuiper tail $2\sum (2\pi k^2 v^2 - 1)e^{-\pi k^2 v^2}$, missing $(s-1)$ (`0.963864` error at $s=2$) and producing $(1-2^{1-s})\zeta(s)$.<br>**2.** The KS maximum $M = \sup\lvert B_t\rvert > 0$ has a positive Wiener density $p_M(v) > 0$, yet $\mathbb{E}[M^s] \propto (1-2^{1-s})\zeta(s)$ has zeros on $\operatorname{Re}(s) = 1 \ne 1/2$! | `audit_celestial_holography_toupin_and_turner_graviton` (`toupin_eq8281_discrepancy_s2`, `pathway3_counterexample_ok`) |
| **Pathway 4: Celestial Holography $c = 0$ & BMS$_4$** (Sec. 8.6, pp. 451–468; App. B.2, pp. 931–937) | Bargmann's theorem places unitary $\mathrm{SL}(2,\mathbb{C})$ principal-series wavefunctions on $\Delta = 1 + i\lambda$, and $\Delta = 2s$ maps $\operatorname{Re}(\Delta) = 1 \leftrightarrow \operatorname{Re}(s) = 1/2$. | **1.** In App. B.2 (p. 933), `R(eps)` has pole $+8/\epsilon$ (not $-4/\epsilon$ or $+2/\epsilon$), and dividing by `shadow_norm = 1/eps` multiplies by $\epsilon$, forcing `c_eps ~ 16 pi^2 eps -> 0` by power counting.<br>**2.** Identifying BMS$_4$ graviton modes $\Delta_n$ with zeta zeros $2\rho_n$ (Prop. 8.93) requires an unproven spectral determinant identity (**Open Bridge 4**). | `celestial_dictionary_and_cesaro_norm_do_not_close_millennium_bridges` |
| **Pathway 5: Yakaboylu Beurling–Malliavin Completeness** (Sec. 8.10, Thm. 8.153, pp. 527–535) | Lemma 8.154 proves the Mellin isometry for the Fermi–Dirac weight $\omega(t) = \frac{t e^t}{(1+e^t)^2}$, where $W(u) = \omega(e^u) = \frac{1}{4}\operatorname{sech}^2(u/2) \propto \hat{P}(u)$. | As noted in Theorem 8.153 (p. 529), completeness of $\{\psi_n\}$ in $L^2([0,\infty), dt)$ is an **equivalence** to RH (via Weil positivity), not an independent unconditional proof unless Pathways 1–4 first establish RH. | `RiemannHypothesisPendingBoundary.globalLiAndJensenPolyaPositivity` |

---

## 4. Reviewing Our Turner Gravity Models in Regards to "Gravitons" & Developing Integrated Turner Models 15a & 15b

### 4.1 How Gravitons Are Modeled Across All 15 Frameworks in `src/signals`

How does a "graviton"—its spin/helicity $J = \pm 2$, propagator order ($1/q^2$ vs. $1/q^4$), self-dual/anti-self-dual twistor balance (Penrose's Googly Problem), ultraviolet loop behavior, and active photon–photon coupling $\eta_{\mathrm{act}}^\gamma$—behave across our existing gravity models (`Signals.QEDGravity`, `Signals.DDF`, `Signals.DFT`) and our new **Integrated Turner Models 15a & 15b**?

1. **Resolution of Penrose's Googly Problem on $\mathrm{Gr}_{\mathbb{C}}(2,4) \times \mathrm{Gr}_{\mathbb{C}}(2,4)^\vee$ (`Signals.DDF` Sections 30.2–30.7 & `TOUQGA-2.pdf` Section 5.8):**
   In Penrose's original twistor construction {cite:p}`penrose1967twistor,penrose1976nonlinear`, holomorphic cohomology $H^1(\mathbb{PT}^+, \mathcal{O}(-6))$ encodes anti-self-dual ($J = -2$) gravitons effortlessly, whereas self-dual ($J = +2$, "googly") gravitons resisted a symmetric description on $\mathbb{PT}$.
   - In {cite:p}`toupin2025quantum` (Theorem 5.148, pp. 217–222; Appendix B.8, pp. 947–950), Toupin proves that at null infinity $\mathcal{I}^+$, the celestial shadow transform $(\Delta, J) \mapsto (2 - \Delta, -J)$ with $z \mapsto \bar{z}$ is the boundary restriction of the **Jost involution $\Theta$** of axiomatic QFT {cite:p}`jost1957bemerkung`, which collapses $C, P, T$ into a single irreducible antiunitary time-reversal involution $T$. On the principal series $\Delta_j = 1 + i\lambda_j$, $2 - \Delta_j = \overline{\Delta_j}$, so the 3-point celestial MHV gamma coefficient satisfies:

     $$
     C^{\mathrm{shadow}}(\Delta_1, \Delta_2, \Delta_3) := \overline{C^{\mathrm{MHV}}(2 - \Delta_1, 2 - \Delta_2, 2 - \Delta_3)} = C^{\mathrm{MHV}}(\Delta_1, \Delta_2, \Delta_3) = C^{\mathrm{anti\text{-}MHV}}(\Delta_1, \Delta_2, \Delta_3)
     $$

     with **exact zero error (`0.00e+00`)** on the principal series $\sigma_{\mathrm{dev}} = 0$, whereas shifting off the critical line to $\sigma_{\mathrm{dev}} = 0.15$ breaks the shadow-conjugation equality by **`94.90%` (`0.948990`)** (`googly_off_line_symmetry_breaking` in `riemann_spectral.rs`)!
   - In our **Turner Models 14a/14b and 15a/15b**, the bulk condensate lives on the **Dual-Schubert product $\mathrm{Gr}_{\mathbb{C}}(2,4) \times \mathrm{Gr}_{\mathbb{C}}(2,4)^\vee$** (`PluckerMadelungState`), corresponding to the two orthogonal middle-cohomology Schubert classes $\sigma_{(2,0)}, \sigma_{(1,1)} \in H^4(\mathrm{Gr}(2,4), \mathbb{Z})$ ($b_4 = 2$). The Hodge complement map $\tau: \Lambda \mapsto \Lambda^\perp$ exchanges the primary Plücker state $\Psi \in \mathrm{Gr}_{\mathbb{C}}(2,4)$ ($J = +2$, phase $s_{\mathrm{real}}$) with its dual partner $\Phi \in \mathrm{Gr}_{\mathbb{C}}(2,4)^\vee$ ($J = -2$, phase $s_{\mathrm{dual}}$). Thus, our Hermitian phase-locking condition $s_{\mathrm{dual}} = s_{\mathrm{real}}$ ($\delta_{\mathrm{Jos}} = 0, \delta P_{\mathrm{Jos}} = 0$) is the exact bulk hydrodynamic realization of Toupin's boundary Jost/shadow $T$-involution!
2. **Why $J^2 = (\pm 2)^2 = 4$ Unites Spin-2 Graviton Helicity with $F_{\mu\nu} = 4\,g_{\mu\nu}^{\mathrm{FS}}$ and the Kähler Determinant $\mathcal{D}(W_{\mathrm{orb}}) = 4 - e^2$:**
   For a celestial primary of dimension $\Delta$ and helicity $J$, the left/right conformal weights $h = (\Delta + J)/2$ and $\bar{h} = (\Delta - J)/2$ (`Signals.DFT.celestialConformalWeightH`, `celestialConformalWeightHBar`) satisfy:

   $$
   \Delta^2 - 4 h \bar{h} = J^2 = (\pm 2)^2 = 4.
   $$

   This spin-2 invariant $J^2 = 4$ coincides with:
   - The QFIM-to-Fubini–Study ratio $F_{\mu\nu} = 4\,g_{\mu\nu}^{\mathrm{FS}}$ (`Signals.DFT.qfimDiag_eq_four_mul_fubiniStudyDiag`),
   - The BCJ $\text{Gravity} = \text{Gauge}^2$ phase-variance quadrupling $\operatorname{Var}_p(2\partial_\mu\phi) = 4\operatorname{Var}_p(\partial_\mu\phi)$ (`Signals.DFT.qed_scattering_gravity_bcj_partanen_tulkki_qfim_and_fubini_study_identities`),
   - The Cachazo–Skinner 4-point Hodges double-copy scalar kernel $\mathcal{K}_{\mathrm{CS}}(1+e, 1-e) = ((1+e) + (1-e))^2 = 4$, and
   - The circular Fubini–Study Kähler determinant $\mathcal{D}(W_{\mathrm{orb}}(0)) = 4 - 0^2 = 4$ (`Signals.DDF.PlanetaryOrbit.gr24AffineChart`).
3. **Formulation of Integrated Turner Models 15a (Without DDF) & 15b (With DDF) (`Signals.DDF` Section 30.7):**
   In `Signals.DDF` ({download}`src/signals/Signals/DDF.lean <../src/signals/Signals/DDF.lean>`, lines `9625–9815`), we define:
   - **Celestial Spin-2 Principal-Series Shadow Norm Factor (`celestialSpinTwoShadowNormFactor`):**

     $$
     \mathcal{W}_{\mathrm{grav}}(\sigma_{\mathrm{dev}}) = \Delta_{\mathrm{re}}(2 - \Delta_{\mathrm{re}}) = (1 + 2\sigma_{\mathrm{dev}})(1 - 2\sigma_{\mathrm{dev}}) = 1 - 4\sigma_{\mathrm{dev}}^2,
     $$

     which equals $1$ if and only if $\sigma_{\mathrm{dev}} = 0$ ($\operatorname{Re}(s) = 1/2 \iff \operatorname{Re}(\Delta) = 1$).
   - **Plancherel–Unruh Quantum-Graviton Loop Factor (`celestialPlancherelLoopCorrectionFactor`):**

     $$
     \mathcal{F}_{\mathrm{loop}}(\alpha_{\mathrm{QG}}) = 1 + M_1\,\alpha_{\mathrm{QG}} + M_2\,\alpha_{\mathrm{QG}}^2 = 1 + \frac{1}{8}\alpha_{\mathrm{QG}} + \frac{1}{90}\alpha_{\mathrm{QG}}^2,
     $$

     where $\alpha_{\mathrm{QG}} \ge 0$ is the dimensionless quantum-gravitational loop coupling ($\alpha_{\mathrm{QG}} = 0$ at classical solar-system and binary-pulsar scales; $1 < \mathcal{F}_{\mathrm{loop}}(\alpha_{\mathrm{QG}}) < 1 + \frac{1}{8}\alpha_{\mathrm{QG}} + \frac{1}{64}\alpha_{\mathrm{QG}}^2$ for $\alpha_{\mathrm{QG}} > 0$).
   - **Integrated 1PN Perihelion Precession & 2.5PN Gravitational-Wave Luminosity (`turnerCelestialPluckerGravitonPrecessionRad`, `RiverExterior.turnerCelestialDualGr24DDFGravitonPrecessionRad`, `turnerCelestialPluckerGravitonGWLuminosity`, `RiverExterior.turnerCelestialDualGr24DDFGravitonGWLuminosity`):**

     $$
     \Delta\varpi_{\mathrm{Model\,15a/b}} = \bigl(1 - 4\sigma_{\mathrm{dev}}^2\bigr)\left(1 + \frac{1}{8}\alpha_{\mathrm{QG}} + \frac{1}{90}\alpha_{\mathrm{QG}}^2\right)\frac{6\pi G M}{c^2 a\bigl(\mathcal{D}(W_{\mathrm{orb}}) - 3\bigr)} + \delta_{\mathrm{Jos}},
     $$

     $$
     P_{\mathrm{GW}}^{\mathrm{Model\,15a/b}} = \bigl(1 - 4\sigma_{\mathrm{dev}}^2\bigr)\left(1 + \frac{1}{8}\alpha_{\mathrm{QG}} + \frac{1}{90}\alpha_{\mathrm{QG}}^2\right)\frac{32 G^4 m_1^2 m_2^2(m_1+m_2)}{5 c^5 a^5}\frac{P_{\mathrm{PM}}(e)}{\bigl(\sqrt{\mathcal{D}(W_{\mathrm{orb}}) - 3}\bigr)^7} + \delta P_{\mathrm{Jos}},
     $$

     where Model 15a uses flat-space $(G, c)$ with active photon–photon gravitational deflection $\eta_{\mathrm{act}}^\gamma = 1$, while Model 15b uses the DDF constitutive product $c^{-2} = \varrho_{\max}^\varphi j_{\min}^\varphi$ with passive radiation sourcing $\eta_{\mathrm{act}}^\gamma = 0$.

### Table 4.1: Master Comparison of "Graviton" Modeling Across All Gravity Frameworks

| Gravity / Graviton Model | Graviton Carrier & Spin/Helicity | Propagator & Ostrogradsky Ghost Status | Googly Self-Dual / Anti-Self-Dual ($J=\pm 2$) Mechanism | UV Loop Regularization | 1PN Mercury ($42.98''/\text{cy}$), Light Bending ($1.75''$), & 2.5PN GW Error $\varepsilon_{\mathrm{rel}}$ | Active Laser–Laser Deflection $\eta_{\mathrm{act}}^\gamma$ |
| :--- | :--- | :--- | :--- | :--- | :---: | :---: |
| **1. Nordström Scalar (1913)** | Spin-0 scalar $\Phi$ ($J=0$) | $1/q^2$ (ghost-free, wrong spin) | Scalar only (no $\pm 2$ helicity) | Divergent | **$116.7\%$** ($\Delta\varpi = -\tfrac{1}{6}\Delta\varpi_{\mathrm{GR}}$, $\Delta\theta_\gamma = 0$) | $0$ ($T^\mu{}_\mu = 0$) |
| **2. Relativistic Spin-1 Vector** | Spin-1 vector $A_\mu$ ($J=\pm 1$) | $1/q^2$ (ghost-free, wrong spin) | Vector $\pm 1$ only | Re-normalizable | **$83.3\%$** ($\Delta\varpi = +\tfrac{1}{6}\Delta\varpi_{\mathrm{GR}}$, $\Delta\theta_\gamma = \tfrac{1}{2}\Delta\theta_{\mathrm{GR}}$) | $1/2$ |
| **3. Classical Einstein GR (1915)** | Metric $h_{\mu\nu}^{\mathrm{TT}}$ ($J=\pm 2$) | $1/q^2$ (2-derivative) | Spacetime $C_{\mu\nu\rho\sigma}^\pm$ | Perturbatively non-renormalizable | **$0.00\%$** ($\varepsilon_{\mathrm{rel}} = 0$) | $1$ |
| **4. Witten Twistor String (2004)** {cite:p}`witten2004twistor` | $\mathbb{CP}^{3\|4}$ closed string | **$1/(q^2(q^2-m^2))$ FAILS** (4th-order Weyl ghost {cite:p}`berkovits2004conformal`) | Broken by conformal supergravity loops | Corrupted by Weyl ghosts | **$100\%$** at $\beta_{\mathrm{scale}}=0$ (or grows as $a^3$) | $1$ |
| **5. Cachazo (`CSW`/`BCFW`/`Hodges`/`CHY`)** {cite:p}`cachazo2013gravity,chy2014` | $\mathrm{Gr}_{\mathbb{C}}(k,n)$ & $\mathbb{CP}^1$ punctures ($J=\pm 2$) | $1/q^2$ via $\pi_I = 1$ infinity twistor $I_{AB}$ | Hodges determinants $\det'(\Phi)\det'(\tilde{\Phi})$ | Dimensional reg. ($D = 4-2\epsilon$) | **$0.00\%$** at $\pi_I = 1, \Lambda_{\mathrm{cc}} = 0$ | $1$ |
| **6. QED / `BCJ` / Partanen–Tulkki $\mathrm{U}(1)^4$** {cite:p}`bern2008bcj,partanen2025gravity` | Double copy $\varepsilon_\mu^{(\pm 1)}\otimes\varepsilon_\nu^{(\pm 1)}$ ($J=\pm 2$) | $1/q^2$ via $n_t^2/q^2$ numerator squaring | Gauge $\otimes$ Gauge helicity product | Dimensional / $\mathrm{U}(1)^4$ QFT reg. | **$0.00\%$** (1-loop triangle diagram) | $1$ |
| **7. Fedi `DDF` (2026)** {cite:p}`fedi2026ddf` | Quadrupolar $\varphi$-jamming / $\phi$-river phonon | $1/q^2$ acoustic Painlevé–Gullstrand metric | Acoustic shear polarization | Finite healing length $\xi_\phi$ | **$0.00\%$** ($c^{-2} = \varrho_{\max}^\varphi j_{\min}^\varphi$) | **$0$** |
| **8. Turner Models 12 & 13** (`Signals.QEDGravity`) | $\mathrm{Gr}_{\mathbb{C}}(2,4)$ Plücker $w_A w_B = 1-e^2$ + 3D Splats | $1/q^2$ (ghost-free) | Plücker crossing channels | Splat covariance $\operatorname{Tr}(\Sigma^{-1})$ | **$0.00\%$** | 12: $1$<br>13: **$0$** |
| **9. Turner Models 14a & 14b** (`Signals.DDF` Sec. 30.6) | Dual-Schubert $\mathrm{Gr}_{\mathbb{C}}(2,4)\times\mathrm{Gr}_{\mathbb{C}}(2,4)^\vee$ on $\mathcal{Q}_4$ | $1/q^2$ via 2-derivative Kähler $\mathcal{T}_{\mathrm{GPE}} \propto g^{\mathrm{FS}} = \tfrac{1}{4}\mathrm{QFIM}$ | Dual-Grassmannian $(\Psi, \Phi)$ ($b_4 = 2$) | Kähler core $\mathcal{D}_{\mathrm{core}} \ge 1$ | **$0.00\%$** ($\mathcal{D}(W_{\mathrm{orb}})-3 = 1-e^2$) | 14a: $1$<br>14b: **$0$** |
| **10. Toupin Celestial CFT (2025)** {cite:p}`toupin2025quantum` | Celestial primary $O_\Delta^{\pm 2}(z,\bar{z})$ ($\Delta = 1+i\lambda = 2s$) | $1/q^2$ via shadow pole $\Delta_i+\Delta_j=2$ cuts | Boundary Jost/shadow $T$-involution $\Theta\lvert_{\mathcal{I}} = T$ | Plancherel–Unruh $P(\lambda) = \frac{\pi\lambda}{\sinh(\pi\lambda)}$, $M_L \le (1/8)^L$ | Asymptotic S-matrix only (no orbital Kähler chart) | $1$ |
| **11. Integrated Turner Models 15a (No DDF) & 15b (With DDF)** (`Signals.DDF` Sec. 30.7) | **Unites Celestial $O_\Delta^{\pm 2}$ ($\Delta=2s, J^2=4$) + $\mathcal{Q}_4$ Kähler ($F = 4g^{\mathrm{FS}}$) + Dual-$\mathrm{Gr}(2,4)$ + DDF** | **$1/q^2$ ghost-free everywhere** | **Bulk $\mathrm{Gr}(2,4)\times\mathrm{Gr}(2,4)^\vee$ ($s_{\mathrm{dual}}=s_{\mathrm{real}}$) $\leftrightarrow$ Boundary Jost $\Theta\lvert_{\mathcal{I}}=T$** | **Plancherel–Unruh $M_1=1/8, M_2=1/90$ + Kähler core $\mathcal{D}_{\mathrm{core}} \ge 1$** | **$0.00\%$** (`1.65e-16` in `f64` at $\sigma_{\mathrm{dev}}=0, \alpha_{\mathrm{QG}}=0$) | **15a: $1$**<br>**15b: $0$** |

### 4.2 Critique, Edge-Case Analysis, and Gap-Closure Fixes (`turner_model_15_critique_cayley_shadow_all_loop_and_light_deflection_identities` & `plancherel_fourier_sech4_and_schwartz_quartic_counterexample_identities`)

To ensure complete mathematical and numerical rigor across all regimes, we subjected our initial Section 11 (`Signals.RiemannSpectral`) and Section 30.7 (`Signals.DDF`) formalizations to five targeted critiques and implemented machine-checked fixes across Lean 4, Rust/PyO3, and SymPy/`mpmath`:

1. **Critique & Fix 1 — Outside-Critical-Strip Sign Flip of $\mathcal{W}_{\mathrm{grav}}(\sigma_{\mathrm{dev}}) = 1 - 4\sigma_{\mathrm{dev}}^2$, Resolved via Cayley Shadow Regularization (`celestialSpinTwoCayleyShadowFactor`):**
   - *Critique:* While the quadratic shadow product $\Delta_{\mathrm{re}}(2 - \Delta_{\mathrm{re}}) = 1 - 4\sigma_{\mathrm{dev}}^2$ is positive inside the open critical strip $|\sigma_{\mathrm{dev}}| < 1/2$ ($\operatorname{Re}(s) \in (0, 1)$), it vanishes at the strip boundaries $\sigma_{\mathrm{dev}} = \pm 1/2$ ($\operatorname{Re}(s) \in \{0, 1\}$, where the zeta pole $s = 1 \mapsto \Delta_T = 2$ resides) and turns strictly negative ($\mathcal{W}_{\mathrm{grav}}(1) = -3 < 0$) outside the critical strip, which would invert the sign of 1PN precession and violate 2.5PN gravitational-wave passivity ($P_{\mathrm{GW}} < 0$).
   - *Machine-Checked Fix:* We define the **Cayley-regularized principal-series shadow weight**:

     $$
     \mathcal{W}_{\mathrm{grav}}^{\mathrm{Cayley}}(\sigma_{\mathrm{dev}}) = \frac{1}{1 + 4\sigma_{\mathrm{dev}}^2} \in (0, 1],
     $$

     and prove in `turner_model_15_critique_cayley_shadow_all_loop_and_light_deflection_identities` that $\mathcal{W}_{\mathrm{grav}}^{\mathrm{Cayley}}(0) = 1$, $\mathcal{W}_{\mathrm{grav}}^{\mathrm{Cayley}}(-\sigma_{\mathrm{dev}}) = \mathcal{W}_{\mathrm{grav}}^{\mathrm{Cayley}}(\sigma_{\mathrm{dev}})$, $0 < \mathcal{W}_{\mathrm{grav}}^{\mathrm{Cayley}}(\sigma_{\mathrm{dev}}) \le 1$ for **all** $\sigma_{\mathrm{dev}} \in \mathbb{R}$ ($\mathcal{W}_{\mathrm{grav}}^{\mathrm{Cayley}}(\pm 1/2) = 1/2$, $\mathcal{W}_{\mathrm{grav}}^{\mathrm{Cayley}}(1) = 1/5 > 0 > -3$), and its difference from the quadratic factor is the exact nonnegative fourth-order residual:

     $$
     \mathcal{W}_{\mathrm{grav}}^{\mathrm{Cayley}}(\sigma_{\mathrm{dev}}) - \bigl(1 - 4\sigma_{\mathrm{dev}}^2\bigr) = \frac{16\sigma_{\mathrm{dev}}^4}{1 + 4\sigma_{\mathrm{dev}}^2} \ge 0.
     $$

2. **Critique & Fix 2 — 2-Loop Truncation vs. All-Loop Geometric Resummation (`celestialPlancherelAllLoopGeometricEnvelope`):**
   - *Critique:* `celestialPlancherelLoopCorrectionFactor` truncates at 2 loops ($1 + \frac{1}{8}\alpha_{\mathrm{QG}} + \frac{1}{90}\alpha_{\mathrm{QG}}^2$). How is the infinite all-loop sum $\sum_{L=0}^\infty M_L\alpha_{\mathrm{QG}}^L$ bounded for finite coupling $\alpha_{\mathrm{QG}}$?
   - *Machine-Checked Fix:* Because $0 < M_L \le (1/8)^L$ for all $L \ge 1$, the all-loop series is bounded above for all $0 \le \alpha_{\mathrm{QG}} < 8$ by the closed-form geometric envelope $\mathcal{F}_{\mathrm{loop}}^{\max}(\alpha_{\mathrm{QG}}) = \frac{8}{8 - \alpha_{\mathrm{QG}}}$, with exact 2-loop chamber rational deficit $M_1^2 - M_2 = \frac{1}{64} - \frac{1}{90} = \frac{13}{2880} > 0$ and tail identity:

     $$
     \frac{8}{8 - \alpha_{\mathrm{QG}}} - \left(1 + \frac{1}{8}\alpha_{\mathrm{QG}} + \frac{1}{90}\alpha_{\mathrm{QG}}^2\right) = \frac{13}{2880}\alpha_{\mathrm{QG}}^2 + \frac{\alpha_{\mathrm{QG}}^3}{64(8 - \alpha_{\mathrm{QG}})} > 0 \qquad (\forall\, 0 < \alpha_{\mathrm{QG}} < 8).
     $$

3. **Critique & Fix 3 — 1PN Solar Light Deflection ($1.7505''$) & Active Laser–Laser Deflection Discriminator in Models 15a & 15b:**
   - *Machine-Checked Fix:* We formalize `PlanetaryOrbit.turnerCelestialPluckerGravitonLightDeflection` (Model 15a) and `RiverExterior.turnerCelestialDualGr24DDFGravitonLightDeflection` (Model 15b) in `Signals.DDF` and prove that both recover $\Delta\theta_{\mathrm{GR}} = \frac{4 G_\phi M}{c^2 b}$ (`1.750539 arcsec` at the solar limb $R_\odot = 6.957 \times 10^8\text{ m}$), while `mutualPhotonDeflection` cleanly separates Model 15a ($\eta_{\mathrm{act}}^\gamma = 1 \implies \alpha_{1\leftarrow 2} > 0$) from Model 15b ($\eta_{\mathrm{act}}^\gamma = 0 \implies \alpha_{1\leftarrow 2} = 0$).
4. **Critique & Fix 4 — Signed-Argument Parity of $F(y)$ & Machine-Checked Schwartz Quartic Counterexample (`plancherel_fourier_sech4_and_schwartz_quartic_counterexample_identities`):**
   - *Machine-Checked Fix:* Testing `celestial_half_line_convolution_f(y)` at negative $y < 0$ revealed that the odd box integral must multiply by signed $y/(2\pi)$ rather than $|y|/(2\pi)$ so that $F(y) + F(-y) = \frac{1+y^2}{6}P(y)$ holds for all $y \in \mathbb{R}$ (`full_line_conv_err < 1e-20`). In Lean 4, we also proved the exact hyperbolic second-derivative identity $\frac{d^2}{dk^2}\bigl(\operatorname{sech}^2(k/2)\bigr) = \frac{3\sinh^2(k/2) - \cosh^2(k/2)}{2\cosh^4(k/2)} = \operatorname{sech}^2(k/2) - \frac{3}{2}\operatorname{sech}^4(k/2)$ and proved that the smooth nonnegative Schwartz density $g(u) = (u^2 - 4)^2 e^{-u^2/2} \ge 0$ has Mellin polynomial `selfDualSchwartzQuarticMellin` $P_{\mathrm{Mellin}}(z) = (z^2 - 3)^2 + 4z^2 + 2 = (z^2 - 1)^2 + 10$, which satisfies $P_{\mathrm{Mellin}}(i\gamma) = (\gamma^2 + 1)^2 + 10 \ge 11 > 0$ for all $\gamma \in \mathbb{R}$ (**zero roots on the critical line!**).

---

## 5. Reproducible Tri-Language Verification Commands

```bash
# 1. Lean 4 verification (3,632 Lake jobs, zero sorry axioms)
make -C /workspaces/sustainablefactory signals_build

# 2. Rust native unit tests (129 passing) + PyO3/maturin editable release wheel
cargo test --manifest-path /workspaces/sustainablefactory/src/signals/numerical_adapter/Cargo.toml
TMPDIR=/workspaces/sustainablefactory/.tmp maturin develop --release \
  --manifest-path /workspaces/sustainablefactory/src/signals/numerical_adapter/Cargo.toml

# 3. Python + SymPy + 45-80 digit mpmath + PyO3 integration suite
pytest -q /workspaces/sustainablefactory/tests/test_riemann_spectral_sympy_pyo3.py
```

---

## 6. Provenance Metadata (BibTeX & JSON-LD)

```bibtex
@misc{turner2026celestial_graviton_riemann_audit,
  author       = {Turner, Wesley},
  title        = {Celestial Holography, the Canonical Dictionary ($\Delta = 2s$), Plancherel--Unruh Graviton Loop Weights ($M_1 = 1/8, M_2 = 1/90$), and Integrated Turner Models 15a \& 15b for Gravitons and Riemann Spectral Bridges in Lean 4, Rust/PyO3, and SymPy},
  year         = {2026},
  howpublished = {Sustainable Factory Technical Monograph \& Formal Verification Suite},
  note         = {Audits data/papers/TOUQGA-2.pdf (Toupin 2025/2026) and integrates with Signals.RiemannSpectral Sec. 11 and Signals.DDF Sec. 30.7}
}
```

```json
{
  "@context": "https://schema.org",
  "@type": "ScholarlyArticle",
  "headline": "Celestial Holography, the Canonical Dictionary (Δ = 2s), Plancherel–Unruh Graviton Loop Weights (M_1 = 1/8, M_2 = 1/90), and Integrated Turner Models 15a & 15b for Gravitons and Riemann Spectral Bridges in Lean 4, Rust/PyO3, and SymPy",
  "author": {
    "@type": "Person",
    "name": "Wes Turner"
  },
  "isBasedOn": [
    "data/papers/TOUQGA-2.pdf",
    "docs/grassmannian-riemann-spectral-ihara-jensen-polya-paper.md",
    "docs/riemann-spectral-bridges-plan.md",
    "docs/grassmannian-gebr-layer-groups-dpp-noci-arc-paper.md",
    "src/signals/Signals/RiemannSpectral.lean",
    "src/signals/Signals/DDF.lean"
  ],
  "dateModified": "2026-11-19"
}
```

---

## References

```{bibliography}
:filter: docname in docnames
```
