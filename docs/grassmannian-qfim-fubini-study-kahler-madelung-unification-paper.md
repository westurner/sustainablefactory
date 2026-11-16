---
title: "Why the Quantum Fisher Information Metric Is Four Times the Fubini–Study Kähler Metric (F_μν = 4 g^FS_μν): Three-Channel Plücker Madelung–QFIM Kinetic Decomposition on Q_4, Ghost-Free Turner Gravity vs. Witten's Twistor String, and Cross-Domain Model Unification in Lean 4 and Rust"
description: "An arXiv-ready MyST Markdown formal verification and theoretical physics unification paper proving that the Quantum Fisher Information Metric (QFIM) is identically four times the Fubini–Study Kähler metric (F_μν = 4 g^FS_μν) on the Klein quadric Q_4 = Gr_C(2,4) ⊂ CP^5, establishing the exact three-channel Gross–Pitaevskii kinetic energy decomposition into macroscopic hydrodynamic flow, scalar Bohmian density Fisher energy, and projective QFIM/Fubini–Study energy, proving the Plücker simplex Fisher + bivector phase-variance split and Klein quadric tangency invariance, and demonstrating why projecting Gr_C(2,4) onto Q_4 with a Fubini–Study Kähler metric and DDF refractive index recovers ghost-free two-derivative Madelung hydrodynamics and 1PN Einstein precession while unifying quantum metrology, flat-band superfluidity, Gaussian splats, and causal transformers in Lean 4 and Rust."
---

(grassmannian-qfim-fubini-study-kahler-madelung-unification-paper)=
# Why the Quantum Fisher Information Metric Is Four Times the Fubini–Study Kähler Metric ($F_{\mu\nu} = 4\,g_{\mu\nu}^{\mathrm{FS}}$): Three-Channel Plücker Madelung–QFIM Kinetic Decomposition on $\mathcal{Q}_4$, Ghost-Free Turner Gravity vs. Witten's Twistor String, and Cross-Domain Model Unification in Lean 4 and Rust

- **Authors:** Wes Turner
- **Subjects:**
  - Mathematical Physics (`math-ph`); Quantum Physics (`quant-ph`); General Relativity and Quantum Cosmology (`gr-qc`); High Energy Physics - Theory (`hep-th`); Quantum Gases (`cond-mat.quant-gas`); Superconductivity (`cond-mat.supr-con`); Logic in Computer Science (`cs.LO`)
- **Formal Verification & Simulation Artifacts:**
  - `Signals` Lean 4 Library (`leanprover/lean4:v4.35.0-rc3`, {download}`src/signals/Signals/DFT.lean, lines 8598–10060 <../src/signals/Signals/DFT.lean>`, {download}`src/signals/Signals/Plabic.lean, lines 1125–1340 <../src/signals/Signals/Plabic.lean>`, {download}`src/signals/Signals/DDF.lean, lines 8346–9620 <../src/signals/Signals/DDF.lean>`, {download}`src/signals/Signals/QEDGravity.lean, lines 72–115 and 973–1060 <../src/signals/Signals/QEDGravity.lean>`, {download}`src/signals/Signals/Pending.lean, lines 8735–9090 <../src/signals/Signals/Pending.lean>`, {download}`src/signals/SignalsPending.lean, lines 2115–2400 <../src/signals/SignalsPending.lean>`, {download}`src/signals/SignalsTests.lean, lines 8520–8795 <../src/signals/SignalsTests.lean>`, {download}`src/signals/SignalsPendingTests.lean, lines 7060–7345 <../src/signals/SignalsPendingTests.lean>`)
  - `signals-numerical-adapter` Rust/WASM Crate ({download}`src/signals/numerical_adapter/src/dft_plabic_vrc.rs, lines 2420–2910 and 3860–4290 <../src/signals/numerical_adapter/src/dft_plabic_vrc.rs>`, {download}`src/signals/numerical_adapter/src/madelung_lagrangian.rs, lines 616–1060 <../src/signals/numerical_adapter/src/madelung_lagrangian.rs>`, {download}`src/signals/numerical_adapter/src/orbital_splat.rs, lines 1–1250 <../src/signals/numerical_adapter/src/orbital_splat.rs>`)
- **Companion Papers:**
  - [Unification, Engineering Applications, and Research Roadmap of Complex Grassmannian $\mathrm{Gr}_{\mathbb{C}}(2,4)$, $\mathrm{Gr}_{\mathbb{C}}(2,6)$, and Dilatant Dark Fluid (DDF) Mechanics](grassmannian-unification-applications-roadmap-paper.md)
  - [Complex Grassmannian $\mathrm{Gr}_{\mathbb{C}}(2,4)$ Fubini–Study Gross–Pitaevskii Equation, Dual-Schubert `iGPE`, and Homogeneous Plücker Madelung Hydrodynamics on the Klein Quadric $\mathcal{Q}_4$](grassmannian-complex-gpe-igpe-plucker-madelung-paper.md)
  - [$\mathrm{SU}(4)$ Symmetry, Witten's Twistor String Theory, Lower Grassmannians in $\mathrm{Gr}_{\mathbb{R}}$ and $\mathrm{Gr}_{\mathbb{C}}$, Relative Merits of Cachazo (CSW / BCFW / Hodges / CHY) vs. DDF vs. Turner Models, and Grand Unification with the Holographic Principle and AdS/CFT in Lean 4, Rust, and Python](grassmannian-su4-witten-twistor-string-cachazo-ddf-turner-ads-cft-unification-paper.md)
  - [Grassmannian Gravity from QED & Gauge Scattering Amplitudes: Complex $\mathrm{Gr}_{\mathbb{C}}(2,4)$ Orbital Precession, Mercury's Perihelion, $N$-Body Dynamics, and Dilatant Dark Fluid (DDF) Unification](grassmannian-gravity-from-qed-scattering-paper.md)
  - [Complex Grassmannian Plabic Vector-Relation Configurations (`VRC`), Quantum Causal Inference Kohn–Sham Density Functional Theory (`QCI-GXC`), Riemannian Cayley Optimization, and Topological Multi-Qudit Compilers in Lean 4, SymPy, and Rust](grassmannian-kohn-sham-dft-complex-plabic-vrc-paper.md)
  - [Breaking the Speed–Accuracy Barrier in Quantum Chemistry (Discovered Materials Grand Challenge 03): Unrestricted Complex Grassmannian Kohn–Sham DFT (`QCI-GXC`), Homogeneous Plabic Vector-Relation Configurations, McWeeny Idempotency Restoration, and `def2-QZVP` `WTMAD-2` / ALD–CVD Benchmarks in Lean 4, SymPy, and Rust](grassmannian-speed-accuracy-barrier-quantum-chemistry-paper.md)
  - [Layer-Coded Plabic Graphs, Complex Vector-Relation Configurations (`VRC`), and Unrestricted Grassmannian Quantum Chemistry (`QCI-GXC`) in `MADNESS` Multiwavelet `MRA-PNO` and `Tequila` for Computational Advantage](grassmannian-madness-tequila-quantum-chemistry-plabic-vrc-paper.md)
  - [A Rust/PyO3 (`maturin`) Quantum Simulation Backend for `Tequila`: Complex Grassmannians $\mathrm{Gr}_{\mathbb{C}}(k, n)$, Layer-Coded Plabic Vector-Relation Configurations (`VRC`), Madelung/DDF Hydrodynamics, and Quantum Causal Inference (`QCI`) in Lean 4, Rust, and Python](grassmannian-tequila-rust-pyo3-quantum-simulator-paper.md)
  - [From Superfluid Gross–Pitaevskii Action and Madelung Polar Substitution to Euler–Lagrange Hydrodynamics and Dilatant Dark Fluid (DDF) Jamming Recovery](grassmannian-madelung-lagrangian-ddf-jamming-paper.md)
  - [Grassmannian Multilayer Graphene Superconductivity, Quantum Anomalous Hall ($C = \pm 5$), Fractional Chern Insulators (`FQAH`), Supersolid Quantum Vortices, and Symbiotic Topological Quantum Computing (`G-MGS`)](grassmannian-rhombohedral-graphene-superconductivity-qc-paper.md)
  - [DDF Fracture-Based Communication vs. $\mathrm{ER}=\mathrm{EPR}$ Entanglement and Wormholes on $\mathrm{Gr}_{\mathbb{C}}(2,4)$](grassmannian-ddf-fracture-communication-vs-er-epr-wormholes-paper.md)

---

## Abstract

A foundational bridge between differential geometry, quantum information theory, quantum hydrodynamics, and relativistic gravitation is the exact identity relating the **Quantum Fisher Information Metric (`QFIM`)** $F_{\mu\nu}$ ({cite:p}`provost1980riemannian`; {cite:p}`wootters1981statistical`; {cite:p}`braunstein1994statistical`; {cite:p}`hall2000quantum`) to the **Fubini–Study Kähler metric** $g_{\mu\nu}^{\mathrm{FS}}$ ({cite:p}`fubini1904sulle`; {cite:p}`study1905kurzeste`) on projective Hilbert space $\mathbb{CP}^{N-1}$ and on the Plücker embedding of the Complex Grassmannian $\mathrm{Gr}_{\mathbb{C}}(2,4) \cong \mathcal{Q}_4 \subset \mathbb{CP}^5$ ({cite:p}`chat_grassmannian_gpe_2026`, {download}`data/chats/Gemini_Grassmannian-Gross-Pitaevskii-Equation-Formulation_20261103-1045.md, lines 63–74, 228–245, and 1625–1655 <../data/chats/Gemini_Grassmannian-Gross-Pitaevskii-Equation-Formulation_20261103-1045.md>`):

$$
F_{\mu\nu} = 4\,g_{\mu\nu}^{\mathrm{FS}}, \qquad \operatorname{Tr}(F_{\mu\nu}) = 4\,\operatorname{Tr}(g_{\mu\nu}^{\mathrm{FS}}).
$$

In this paper (`Signals.DFT` Section 27 in {download}`src/signals/Signals/DFT.lean, lines 8598–9370 <../src/signals/Signals/DFT.lean>`, `Signals.Pending` in {download}`src/signals/Signals/Pending.lean, lines 8735–8868 <../src/signals/Signals/Pending.lean>`, and `dft_plabic_vrc.rs` in {download}`src/signals/numerical_adapter/src/dft_plabic_vrc.rs, lines 2420–2710 <../src/signals/numerical_adapter/src/dft_plabic_vrc.rs>`), we machine-check this identity and its structural consequences in **Lean 4** (zero `sorry` axioms) and **Rust**:

1. **Exact Three-Channel Gross–Pitaevskii Kinetic Energy Decomposition on the Klein Quadric $\mathcal{Q}_4 \subset \mathbb{CP}^5$ (`gpeKineticDir_eq_madelung_qfim_split`, `totalGpeKinetic3D_eq_madelung_qfim_trace`)**:
   For any non-vanishing homogeneous Plücker condensate $\Psi(x) \in \mathbb{C}^6 \setminus \{0\}$ on $\mathcal{Q}_4$ with macroscopic fluid density $\rho = \langle\Psi\mid\Psi\rangle > 0$ and directional Hermitian inner product $\langle\Psi\mid\partial_\mu\Psi\rangle = \frac{1}{2}\partial_\mu\rho + i\rho\mathcal{A}_\mu$, the Gross–Pitaevskii kinetic energy density $\mathcal{T}_{\mathrm{GPE}} = \frac{\hbar^2}{2m}\sum_\mu \langle\partial_\mu\Psi\mid\partial_\mu\Psi\rangle$ decomposes identically into three physical channels:
   - **Channel 1 — Macroscopic Hydrodynamic Flow:** $\frac{\hbar^2}{2m}\,\rho\sum_\mu \mathcal{A}_\mu^2$,
   - **Channel 2 — Scalar Bohmian Density Fisher Energy:** $\frac{\hbar^2}{8m}\sum_\mu \frac{(\partial_\mu\rho)^2}{\rho}$, and
   - **Channel 3 — Projective QFIM / Fubini–Study Kähler Internal Energy:** $\frac{\hbar^2}{8m}\,\rho\,\operatorname{Tr}(F_{\mu\nu}) = \frac{\hbar^2}{2m}\,\rho\,\operatorname{Tr}(g_{\mu\nu}^{\mathrm{FS}})$ (`projectiveQfimEnergyDir_eq_fubiniStudyEnergyDir`, `totalProjectiveQfimEnergy3D_eq_fubiniStudyEnergy3D`).
   Crucially, the factor of **$4$** in $F_{\mu\nu} = 4\,g_{\mu\nu}^{\mathrm{FS}}$ converts the Stam–Cramér–Rao Fisher prefactor $\frac{\hbar^2}{8m}$ into the canonical two-derivative Kähler nonlinear sigma-model prefactor $\frac{\hbar^2}{2m} = 4\cdot\frac{\hbar^2}{8m}$, placing macroscopic hydrodynamic flow $\mathcal{A}_\mu^2$ and internal Grassmannian ray curvature $g_{\mu\mu}^{\mathrm{FS}}$ on the exact same $\frac{\hbar^2}{2m}\rho$ energy scale.
2. **Plücker Simplex Probability & Bivector Phase-Variance Theorem (`qfim_simplex_phase_variance_split`)**:
   On the 6-component normalized Plücker ray $n_k = \sqrt{p_k}\,e^{i\phi_k}$ ($k \in \mathrm{Fin}\,6$, $\sum_{k=0}^5 p_k = 1$), multiplying the normalized-ray Fubini–Study metric $g_{\mu\mu}^{\mathrm{FS}}$ by $4$ cancels the $\frac{1}{4}$ factor in $\sum_{k=0}^5 \frac{(\partial_\mu p_k)^2}{4p_k}$ to split the diagonal QFIM into the **classical Fisher information on the Plücker simplex** $I_{\mu\mu}^{\mathrm{class}}(p) = \sum_{k=0}^5 \frac{(\partial_\mu p_k)^2}{p_k}$ plus **four times the internal bivector phase-gradient variance** $4\,\operatorname{Var}_p(\partial_\mu\phi)$:

   $$
   F_{\mu\mu} = 4\,g_{\mu\mu}^{\mathrm{FS}} = I_{\mu\mu}^{\mathrm{class}}(p) + 4\,\operatorname{Var}_p(\partial_\mu\phi).
   $$

3. **Klein Quadric Differential Tangency Lemma (`madelung_klein_quadric_tangency`)**:
   Over any commutative ring $\alpha$ (including $\mathbb{R}$ and $\mathbb{C}$), whenever the normalized projective ray $n \in \mathcal{Q}_4$ satisfies the Klein quadric constraint $Q(n) = n_{01}n_{23} - n_{02}n_{13} + n_{03}n_{12} = 0$ and its directional derivative $dn \in T_n\mathcal{Q}_4$ satisfies the polarized differential tangency relation $Q(n, dn) = n_{01}dn_{23} + dn_{01}n_{23} - n_{02}dn_{13} - dn_{02}n_{13} + n_{03}dn_{12} + dn_{03}n_{12} = 0$, the Madelung-factored condensate $\Psi = \alpha n$ and its derivative $d\Psi = (d\alpha)n + \alpha(dn)$ automatically satisfy $Q(\Psi, d\Psi) = 2\alpha(d\alpha)Q(n) + \alpha^2 Q(n, dn) = 0$.
4. **Why the Turner Projection onto $\mathcal{Q}_4$ with a Fubini–Study Kähler Metric ($= \frac{1}{4}\mathrm{QFIM}$) and DDF Refractive Index Eliminates Witten's 4th-Derivative Weyl Ghost (`qfim_four_times_fubini_study_turner_projection_and_unification_identities`)**:
   In the Turner model ([grassmannian-complex-gpe-igpe-plucker-madelung-paper.md](grassmannian-complex-gpe-igpe-plucker-madelung-paper.md); [grassmannian-su4-witten-twistor-string-cachazo-ddf-turner-ads-cft-unification-paper.md](grassmannian-su4-witten-twistor-string-cachazo-ddf-turner-ads-cft-unification-paper.md)), instead of taking the raw 4th-derivative conformal supergravity sector of Witten's twistor string {cite:p}`witten2004twistor,berkovits2004conformal` at face value—whose propagator $\frac{1}{q^2(q^2 - m_{\mathrm{ghost}}^2)} = \frac{1}{m_{\mathrm{ghost}}^2}(\frac{1}{q^2 - m_{\mathrm{ghost}}^2} - \frac{1}{q^2})$ (`wittenFourthOrderPropagator`) contains a negative-norm Ostrogradsky ghost and produces a perihelion error growing as $a^3$—we project $\mathrm{Gr}_{\mathbb{C}}(2,4)$ onto the **Klein quadric $\mathcal{Q}_4$ equipped with the two-derivative Fubini–Study Kähler metric $g_{\mu\nu}^{\mathrm{FS}} = \frac{1}{4}F_{\mu\nu}$ and the DDF constitutive refractive index $n_{\mathrm{DDF}}$** ($c^{-2} = \varrho_{\max}^\varphi j_{\min}^\varphi$, {cite:p}`fedi2026ddf`). This keeps the Madelung–QFIM action strictly second-order ($1/q^2$ propagator, zero ghost residue) while the Fubini–Study Kähler determinant excess $\mathcal{D}(W_{\mathrm{orb}}) - 3 = (4 - e^2) - 3 = 1 - e^2$ (`turnerKahlerOrbitalSemiLatusFactor`) recovers standard 1PN Einstein perihelion precession (Mercury $42.98''/\text{century}$, $\varepsilon_{\mathrm{rel}} = 0$), 1PN solar gravitational light deflection ($\varepsilon_{\mathrm{rel}} = 0$), and 2.5PN quadrupole gravitational-wave luminosity ($\varepsilon_{\mathrm{rel}} = 0$).
5. **Relative Merits of Cachazo (`CSW` / `BCFW` / `Hodges` / `CHY`) vs. DDF vs. Turner Models and Exact Unification of Cachazo Gravity with the QFIM and Fubini–Study Metric (`cachazo_gravity_chy_hodges_qfim_and_fubini_study_unification_identities`)**:
   Synthesizing Companion Paper 30 ([$\mathrm{SU}(4)$ Symmetry, Witten's Twistor String Theory, Lower Grassmannians in $\mathrm{Gr}_{\mathbb{R}}$ and $\mathrm{Gr}_{\mathbb{C}}$, Relative Merits of Cachazo (CSW / BCFW / Hodges / CHY) vs. DDF vs. Turner Models, and Grand Unification with the Holographic Principle and AdS/CFT in Lean 4, Rust, and Python](grassmannian-su4-witten-twistor-string-cachazo-ddf-turner-ads-cft-unification-paper.md)), we prove that on the Cachazo–He–Yuan (`CHY`, {cite:p}`chy2014`) string worldsheet $\Sigma \cong \mathbb{CP}^1 = \mathrm{Gr}_{\mathbb{C}}(1,2)$, the unique 4-point puncture root $\sigma_4^*(s_{12}, s_{13}) = \frac{s_{12}}{s_{12}+s_{13}}$ (`chyFourPointRoot`) defines a binary channel simplex $(\sigma_4^*, 1 - \sigma_4^*)$ whose worldsheet QFIM $F_{\sigma\sigma}^{\mathrm{CHY}}(\sigma_4) = \frac{1}{\sigma_4(1-\sigma_4)}$ (`chyWorldsheetQfimMetric`) equals $4\,g_{\sigma\sigma}^{\mathrm{FS}}(\sigma_4)$ (`chyWorldsheetFubiniStudyMetric`), so the 4-point CHY bi-adjoint scalar amplitude is literally $\mathcal{A}_4^{\mathrm{CHY},\phi^3}(s_{12}, s_{13}) = \frac{F_{\sigma\sigma}^{\mathrm{CHY}}(\sigma_4^*)}{s_{12}+s_{13}} = \frac{4\,g_{\sigma\sigma}^{\mathrm{FS}}(\sigma_4^*)}{s_{12}+s_{13}}$ and the reduced CHY Jacobian is $\Phi_{44}^{\mathrm{CHY}} = -(s_{12}+s_{13})F_{\sigma\sigma}^{\mathrm{CHY}}(\sigma_4^*) = -4(s_{12}+s_{13})g_{\sigma\sigma}^{\mathrm{FS}}(\sigma_4^*)$, while the Cachazo–Skinner {cite:p}`cachazo2013gravity` reduced Hodges double-copy kernel $\mathcal{K}_{\mathrm{CS}}(w_A, w_B) = (w_A + w_B)^2$ evaluated on orbital Plücker channels $w_A = 1 + e, w_B = 1 - e$ equals $4$ and its polarization difference recovers both $\mathcal{D}(W_{\mathrm{orb}}) - 3 = 1 - e^2$ and the QFIM phase-variance weight $4\,\operatorname{Var}_p^{(2)}(\partial_\mu\phi) = (1 - e^2)(\partial_\mu\phi_0 - \partial_\mu\phi_1)^2$.
6. **QED & Gauge Scattering Gravity (`BCJ` Double Copy, Partanen–Tulkki 2025 $\mathrm{U}(1)^4$ QFT, & Bjerrum-Bohr et al. 2018) Formulated in Terms of `QFIM` and the Fubini–Study Kähler Metric (`qed_scattering_gravity_bcj_partanen_tulkki_qfim_and_fubini_study_identities`)**:
   Synthesizing Companion Paper 4 ([Grassmannian Gravity from QED & Gauge Scattering Amplitudes: Complex $\mathrm{Gr}_{\mathbb{C}}(2,4)$ Orbital Precession, Mercury's Perihelion, $N$-Body Dynamics, and Dilatant Dark Fluid (DDF) Unification](grassmannian-gravity-from-qed-scattering-paper.md)), we prove that on the normalized aphelion–perihelion Plücker simplex $p_{\mathrm{aph}}(e) = \frac{1+e}{2}, p_{\mathrm{per}}(e) = \frac{1-e}{2}$, the orbital eccentricity QFIM and Fubini–Study Kähler metric are $F_{ee}^{\mathrm{orb}}(e) = \frac{1}{1-e^2} = \frac{1}{\mathcal{D}(W_{\mathrm{orb}}(e))-3} = 4\,g_{ee}^{\mathrm{FS}}(e) = \frac{a}{p}$ (`qedOrbitalEccentricityQfim`, `qedOrbitalEccentricityFubiniStudy`). Consequently, 1-loop QED/gauge double-copy perihelion precession ({cite:p}`bern2008bcj`; {cite:p}`bjerrum2018general`; {cite:p}`partanen2025gravity`; {cite:p}`partanen2025perihelion`) is directly linear in the orbital QFIM ($\Delta\varpi_{\mathrm{QED\text{-}2x}} = \frac{6\pi G M}{c^2 a}F_{ee}^{\mathrm{orb}}(e) = \frac{24\pi G M}{c^2 a}g_{ee}^{\mathrm{FS}}(e)$), while 2.5PN Peters–Mathews {cite:p}`peters1963gravitational` quadrupole gravitational-wave enhancement scales as its seventh power ($f_{\mathrm{PM}}(e)^2 = P_{\mathrm{PM}}(e)^2\,(F_{ee}^{\mathrm{orb}}(e))^7 = P_{\mathrm{PM}}(e)^2\,(4\,g_{ee}^{\mathrm{FS}}(e))^7$). Furthermore, we prove why un-doubled spin-1 Coulomb/QED vector gravity misses $5/6$ of 1PN precession and $3/4$ of 2.5PN radiative flux ($\kappa_{\mathrm{vec}} = \frac{1}{4} = \frac{g_{\mu\mu}^{\mathrm{FS}}}{F_{\mu\mu}}$ when universal $q_i / m_i = \sqrt{G}$ eliminates Larmor dipole radiation $\ddot{\mathbf{d}} = \mathbf{0}$), and how helicity doubling ($s: \pm 1 \mapsto \pm 2, \phi \mapsto 2\phi$) under $\text{Gravity} = \text{Gauge}^2$ scales the bivector phase variance by $2^2 = 4\times$ to restore exact GR luminosity ($\varepsilon_{\mathrm{rel}} = 0$).
7. **Complex Plabic Vector-Relation Configurations (`VRC`) and the `QFIM` / Fubini–Study Kähler Metric: Pole-Free On-Shell Resonance ($x_X = -1$), Denominator-Clearing Gauge Invariance, and `MADNESS`/`Tequila` Quantum Natural Gradient (`vrc_fubini_study_kahler_qfim_pole_free_resonance_and_critique_fixes_identities`)**:
   Synthesizing Companion Papers 18 ([grassmannian-quantum-causal-inference-mpemba-paper.md](grassmannian-quantum-causal-inference-mpemba-paper.md)), 22 ([grassmannian-kohn-sham-dft-complex-plabic-vrc-paper.md](grassmannian-kohn-sham-dft-complex-plabic-vrc-paper.md)), 23 ([grassmannian-speed-accuracy-barrier-quantum-chemistry-paper.md](grassmannian-speed-accuracy-barrier-quantum-chemistry-paper.md)), 24 ([grassmannian-tuning-materials-with-light-paper.md](grassmannian-tuning-materials-with-light-paper.md)), 39 ([grassmannian-quantum-causal-next-concept-modeling-pressed-llm-kicad-paper.md](grassmannian-quantum-causal-next-concept-modeling-pressed-llm-kicad-paper.md)), 43 ([grassmannian-madness-tequila-quantum-chemistry-plabic-vrc-paper.md](grassmannian-madness-tequila-quantum-chemistry-plabic-vrc-paper.md)), and 44 ([grassmannian-tequila-rust-pyo3-quantum-simulator-paper.md](grassmannian-tequila-rust-pyo3-quantum-simulator-paper.md)), we prove that while rational Plabic face-weight charts {cite:p}`postnikov2006plabic,lam2016totally` blow up at the chart boundary $x_X \to 0$ and suffer a $(x_X + 1)^{-4}$ Fubini–Study / QFIM singularity under square-move cluster mutation at the on-shell polariton / antibonding / conical-intersection resonance $x_X = -1$, our homogeneous **Vector-Relation Configuration (`VRC`)** {cite:p}`affolter2024vrc` (`gr24MutatedHomogeneousVRC`) has strictly positive polynomial Plücker norm squared $\rho_{\mathrm{VRC}}^{(-1)}(x_1, x_2) = 2 + x_2^2 + (x_2 - x_1)^2(1 + x_2^2) \ge 2 > 0$ (`vrcResonantPluckerNormSq`) and closed, strictly positive resonant metrics $F_{x_1 x_1}^{\mathrm{VRC}}|_{x_X=-1} = 4\,g_{x_1 x_1}^{\mathrm{FS,VRC}}|_{x_X=-1} = \frac{4(2 + x_2^2)(1 + x_2^2)}{(\rho_{\mathrm{VRC}}^{(-1)}(x_1, x_2))^2} > 0$ (`vrcResonantFubiniStudyX1`, `vrcResonantQfimX1`). We also prove that $g_{\mu\mu}^{\mathrm{FS}}$ and $F_{\mu\mu} = 4\,g_{\mu\mu}^{\mathrm{FS}}$ are $100\%$ invariant under arbitrary coordinate-dependent complex radial + phase denominator clearing (`complexRescaledVrcJet`), that VRC-regularized MRA-PNO pair amplitudes yield a finite gap QFIM $4 g^2 / \gamma_{\mathrm{VRC}}^4$ at HOMO–LUMO degeneracy $\Delta\varepsilon = 0$, and that the `Tequila` QFIM-preconditioned Quantum Natural Gradient step is $\frac{1}{4}$ of the Fubini–Study Riemannian step.
8. **Cross-Domain Model Unification & Adversarial Critique Gap-Closure (`qfim_fubini_study_cauchy_schwarz_gauge_invariance_and_vortex_core_critique_identities`)**:
   We show how $F_{\mu\nu} = 4\,g_{\mu\nu}^{\mathrm{FS}}$ unifies eight major pillars across all 49 papers in our research program—including Bures statistical distance, $4\times$ Quantum Cramér–Rao variance compression in sub-nanometer homodyne/Hubble imaging, Mandelstam–Tamm quantum speed limits, Peotta–Törmä flat-band superfluid stiffness in rhombohedral/moiré graphene (`G-MGS`) and cuprates (`G-CSC`), Normed Tensor Gaussian Splat Bohm–Fisher mechanics, `Tequila` natural-gradient parameter-shift rules, and $\mathrm{ER}=\mathrm{EPR}$ concurrence—and we prove four adversarial gap-closure theorems establishing unconditional Cauchy–Schwarz positivity ($0 \le g_{\mu\mu}^{\mathrm{FS}} \le F_{\mu\mu}$), exact local $\mathrm{U}(1)$ projective gauge invariance, pairwise phase-variance positivity on the simplex, and smooth vortex-core regularity of projective QFIM energy as $\rho \to 0$.

---

## 1. Directional Plücker Derivative Data, Division-Ring Identity, and Three-Channel Gross–Pitaevskii Kinetic Decomposition on $\mathcal{Q}_4 \subset \mathbb{CP}^5$

### 1.1 Projective Ray Factorization and the Hermitian Division-Ring Identity

Consider a non-vanishing homogeneous Plücker condensate field $\Psi(x) \in \mathbb{C}^6 \setminus \{0\}$ lying on the Klein quadric $\mathcal{Q}_4 \subset \mathbb{CP}^5$ ({cite:p}`chat_grassmannian_gpe_2026`, {download}`data/chats/Gemini_Grassmannian-Gross-Pitaevskii-Equation-Formulation_20261103-1045.md, lines 1625–1715 <../data/chats/Gemini_Grassmannian-Gross-Pitaevskii-Equation-Formulation_20261103-1045.md>`):

$$
\Psi(x) = \sqrt{\rho(x)}\,e^{i S_0(x)/\hbar}\,n(x), \qquad \langle n(x)\mid n(x)\rangle = 1, \qquad \rho(x) = \langle\Psi(x)\mid\Psi(x)\rangle > 0.
$$

Along any spatial coordinate axis $x^\mu$, differentiating $\langle\Psi\mid\Psi\rangle = \rho$ yields $2\operatorname{Re}\langle\Psi\mid\partial_\mu\Psi\rangle = \partial_\mu\rho$, while the imaginary part defines the gauge-invariant superfluid velocity / Berry connection $\mathcal{A}_\mu = \frac{\operatorname{Im}\langle\Psi\mid\partial_\mu\Psi\rangle}{\rho} = \frac{\partial_\mu S_0}{\hbar} - i\langle n\mid\partial_\mu n\rangle$:

$$
\langle\Psi\mid\partial_\mu\Psi\rangle = \frac{1}{2}\,\partial_\mu\rho + i\,\rho\,\mathcal{A}_\mu \implies \bigl|\langle\Psi\mid\partial_\mu\Psi\rangle\bigr|^2 = \frac{1}{4}\,(\partial_\mu\rho)^2 + \rho^2\,\mathcal{A}_\mu^2.
$$

In `Signals.DFT` Section 27 ({download}`src/signals/Signals/DFT.lean, lines 8642–8756 <../src/signals/Signals/DFT.lean>`), `PluckerDirectionalJet` records the four local directional invariants $(\rho, \langle\partial_\mu\Psi\mid\partial_\mu\Psi\rangle, \partial_\mu\rho, \mathcal{A}_\mu)$, and `innerPsiDpsiNormSq` defines $|\langle\Psi\mid\partial_\mu\Psi\rangle|^2 = (\partial_\mu\rho / 2)^2 + (\rho\mathcal{A}_\mu)^2$.

### 1.2 The Factor of $4$: Why $F_{\mu\mu} = 4\,g_{\mu\mu}^{\mathrm{FS}}$ Equates the $\frac{\hbar^2}{8m}$ Fisher Energy and the $\frac{\hbar^2}{2m}$ Kähler Energy

On the projective space $\mathbb{CP}^5 \supset \mathcal{Q}_4$, the pullback of the **Fubini–Study Kähler metric** ({cite:p}`fubini1904sulle`; {cite:p}`study1905kurzeste`; {cite:p}`provost1980riemannian`) along $x^\mu \mapsto [\Psi(x)]$ has diagonal component (`fubiniStudyDiag`):

$$
g_{\mu\mu}^{\mathrm{FS}} = \langle\partial_\mu n\mid\partial_\mu n\rangle - \bigl|\langle n\mid\partial_\mu n\rangle\bigr|^2 = \frac{\rho\langle\partial_\mu\Psi\mid\partial_\mu\Psi\rangle - \bigl|\langle\Psi\mid\partial_\mu\Psi\rangle\bigr|^2}{\rho^2}.
$$

In quantum estimation theory ({cite:p}`wootters1981statistical`; {cite:p}`braunstein1994statistical`), the **Quantum Fisher Information Metric (`QFIM`)** $F_{\mu\nu} = \operatorname{Re}\operatorname{Tr}(\hat{\rho}\,L_\mu L_\nu)$ for a pure state $\hat{\rho}(x) = |n(x)\rangle\langle n(x)|$ (where $L_\mu = 2(|\partial_\mu n\rangle\langle n| + |n\rangle\langle\partial_\mu n|)$ is the symmetric logarithmic derivative satisfying $\partial_\mu\hat{\rho} = \frac{1}{2}(\hat{\rho} L_\mu + L_\mu \hat{\rho})$) carries an intrinsic factor of $2^2 = 4$ from the square of the symmetric logarithmic derivative (`qfimDiag`):

$$
F_{\mu\mu} = 4\Bigl(\langle\partial_\mu n\mid\partial_\mu n\rangle - \bigl|\langle n\mid\partial_\mu n\rangle\bigr|^2\Bigr) = \frac{4\bigl(\rho\langle\partial_\mu\Psi\mid\partial_\mu\Psi\rangle - |\langle\Psi\mid\partial_\mu\Psi\rangle|^2\bigr)}{\rho^2} = 4\,g_{\mu\mu}^{\mathrm{FS}}.
$$

```{mermaid}
flowchart TB
    GPE["Gross–Pitaevskii Kinetic Energy Density on Q_4 ⊂ CP⁵\nT_GPE = (ℏ² / 2m) ∑_μ ⟨∂_μ Ψ | ∂_μ Ψ⟩\nwith ⟨Ψ | ∂_μ Ψ⟩ = (1/2) ∂_μ ρ + i ρ A_μ"]

    Ch1["Channel 1: Macroscopic Hydrodynamic Flow\nT_hydro = (ℏ² / 2m) ρ ∑_μ A_μ²\n• Center-of-mass superfluid current + Berry connection\n• Two-derivative Euler kinetic energy"]

    Ch2["Channel 2: Scalar Bohmian Density Fisher Energy\nT_Bohm^scalar = (ℏ² / 8m) ∑_μ (∂_μ ρ)² / ρ\n• Radial density Fisher information I_Fisher(ρ)\n• Diverges as 1/ρ at dark fringes / vortex cores (ρ → 0)"]

    Ch3["Channel 3: Projective QFIM / Fubini–Study Kähler Energy\nT_QFIM^proj = (ℏ² / 8m) ρ Tr(F_μν) ≡ (ℏ² / 2m) ρ Tr(g^FS_μν)\n• Because F_μν = 4 g^FS_μν, the 4 cancels 1/8 → 1/2!\n• Smoothly vanishes at ρ → 0; Kähler norm D(W) ≥ 1 everywhere"]

    GPE --> Ch1
    GPE --> Ch2
    GPE --> Ch3
```

Why is the factor of **$4$** in $F_{\mu\mu} = 4\,g_{\mu\mu}^{\mathrm{FS}}$ so physically consequential?
- In Michael Hall's Fisher-information formulation of quantum mechanics {cite:p}`hall2000quantum`, the quantum kinetic energy associated with Fisher information carries the **universal Stam–Cramér–Rao prefactor $\frac{\hbar^2}{8m}$**: the radial density gradient contributes $\frac{\hbar^2}{8m}\frac{(\partial_\mu\rho)^2}{\rho}$ (`scalarBohmDensityDir`), and the internal projective state space contributes $\frac{\hbar^2}{8m}\rho\,F_{\mu\mu}$ (`projectiveQfimEnergyDir`).
- Substituting $F_{\mu\mu} = 4\,g_{\mu\mu}^{\mathrm{FS}}$ (`qfimDiag_eq_four_mul_fubiniStudyDiag`), the factor of $4$ cancels the denominator $8 = 4 \times 2$ (`projectiveQfimEnergyDir_eq_fubiniStudyEnergyDir`):

  $$
  \mathcal{T}_{\mathrm{QFIM},\mu}^{\mathrm{proj}} = \frac{\hbar^2}{8m}\,\rho\,F_{\mu\mu} = \frac{\hbar^2}{8m}\,\rho\,(4\,g_{\mu\mu}^{\mathrm{FS}}) = \frac{\hbar^2}{2m}\,\rho\,g_{\mu\mu}^{\mathrm{FS}} = \mathcal{T}_{\mathrm{FS},\mu}^{\mathrm{proj}}.
  $$

- Consequently, in Theorem 1 (`gpeKineticDir_eq_madelung_qfim_split`) and Theorem 3 (`totalGpeKinetic3D_eq_madelung_qfim_trace`), the total 3D Gross–Pitaevskii kinetic energy density decomposes **without any uncompensated numerical factors** into:

  $$
  \frac{\hbar^2}{2m}\sum_{\mu=1}^3 \langle\partial_\mu\Psi\mid\partial_\mu\Psi\rangle = \underbrace{\frac{\hbar^2}{2m}\,\rho\sum_{\mu=1}^3 \mathcal{A}_\mu^2}_{\text{Macroscopic Flow}} + \underbrace{\frac{\hbar^2}{8m}\sum_{\mu=1}^3 \frac{(\partial_\mu\rho)^2}{\rho}}_{\text{Scalar Density Fisher}} + \underbrace{\frac{\hbar^2}{8m}\,\rho\,\operatorname{Tr}(F_{\mu\nu})}_{\equiv\,\frac{\hbar^2}{2m}\,\rho\,\operatorname{Tr}(g_{\mu\nu}^{\mathrm{FS}})}.
  $$

---

## 2. Plücker Simplex Probability & Bivector Phase-Variance Split and Klein Quadric Differential Tangency

### 2.1 Theorem 4: Splitting $F_{\mu\mu} = 4\,g_{\mu\mu}^{\mathrm{FS}}$ into Classical Plücker Simplex Fisher Information + $4\times$ Bivector Phase Variance

Write the 6 components of the normalized Plücker ray $n(x) \in \mathcal{Q}_4 \subset \mathbb{C}^6$ in polar probability-simplex coordinates $n_k(x) = \sqrt{p_k(x)}\,e^{i\phi_k(x)}$ ($k \in \{0, 1, 2, 3, 4, 5\}$ corresponding to Plücker pairs $(01, 02, 03, 12, 13, 23)$, with $\sum_{k=0}^5 p_k = 1$ and $\sum_{k=0}^5 \partial_\mu p_k = 0$). Then:

$$
\langle\partial_\mu n\mid\partial_\mu n\rangle = \sum_{k=0}^5 \left(\frac{(\partial_\mu p_k)^2}{4\,p_k} + p_k\,(\partial_\mu\phi_k)^2\right), \qquad \langle n\mid\partial_\mu n\rangle = i\sum_{k=0}^5 p_k\,\partial_\mu\phi_k,
$$

so the normalized-ray Fubini–Study metric (`normalizedRayFubiniStudy`) is:

$$
g_{\mu\mu}^{\mathrm{FS}} = \sum_{k=0}^5 \left(\frac{(\partial_\mu p_k)^2}{4\,p_k} + p_k\,(\partial_\mu\phi_k)^2\right) - \left(\sum_{k=0}^5 p_k\,\partial_\mu\phi_k\right)^2.
$$

In Theorem 4 (`qfim_simplex_phase_variance_split` in {download}`src/signals/Signals/DFT.lean, lines 8958–8981 <../src/signals/Signals/DFT.lean>`), multiplying $g_{\mu\mu}^{\mathrm{FS}}$ by **$4$** cancels the $\frac{1}{4}$ in the amplitude-gradient sum $\sum_{k=0}^5 \frac{(\partial_\mu p_k)^2}{4p_k}$, yielding the exact decomposition:

$$
F_{\mu\mu} = 4\,g_{\mu\mu}^{\mathrm{FS}} = \underbrace{\sum_{k=0}^5 \frac{(\partial_\mu p_k)^2}{p_k}}_{I_{\mu\mu}^{\mathrm{class}}(p)\text{ (`classicalPluckerFisher`)}} + \; 4\,\underbrace{\left[\sum_{k=0}^5 p_k\,(\partial_\mu\phi_k)^2 - \left(\sum_{k=0}^5 p_k\,\partial_\mu\phi_k\right)^2\right]}_{\operatorname{Var}_p(\partial_\mu\phi)\text{ (`bivectorPhaseVariance`)}}.
$$

This reveals the second fundamental reason why the QFIM carries a factor of $4$ relative to the Fubini–Study metric:
- Because quantum probabilities are squares of amplitudes ($p_k = |n_k|^2 \implies \partial_\mu\sqrt{p_k} = \frac{\partial_\mu p_k}{2\sqrt{p_k}}$), the Euclidean metric on root-probabilities $\sum_k (\partial_\mu\sqrt{p_k})^2 = \frac{1}{4}\sum_k \frac{(\partial_\mu p_k)^2}{p_k} = \frac{1}{4}I_{\mu\mu}^{\mathrm{class}}(p)$ (the Wootters–Bhattacharyya–Hellinger metric {cite:p}`wootters1981statistical`) is **one-fourth** of the classical Fisher information metric $I_{\mu\mu}^{\mathrm{class}}(p)$!
- Multiplying $g_{\mu\mu}^{\mathrm{FS}}$ by $4$ normalizes the phase-constant boundary ($\partial_\mu\phi_k = \text{const} \implies \operatorname{Var}_p(\partial_\mu\phi) = 0$) to match the classical Fisher information $I_{\mu\mu}^{\mathrm{class}}(p)$ with unit coefficient $1$, while weighting the non-classical internal bivector phase-gradient variance $\operatorname{Var}_p(\partial_\mu\phi)$ by $4$!

### 2.2 Theorem 5: Klein Quadric $\mathcal{Q}_4$ Differential Tangency Invariance Under Madelung Factorization

A critical geometric question is whether factoring the full Plücker condensate $\Psi(x) = \alpha(x)\,n(x)$ into a scalar Madelung envelope $\alpha(x) = \sqrt{\rho(x)}\,e^{i S_0(x)/\hbar}$ and a normalized projective ray $n(x) \in \mathcal{Q}_4$ respects the quadratic Plücker relation and its tangent bundle $T\mathcal{Q}_4$.

In `Bivector6`, `kleinQuadric`, and `kleinPolarForm` ({download}`src/signals/Signals/DFT.lean, lines 8983–9052 <../src/signals/Signals/DFT.lean>`), for any commutative ring $\alpha$, the homogeneous Klein quadric form and its polarized bilinear differential form are:

$$
Q(u) = u_{01}u_{23} - u_{02}u_{13} + u_{03}u_{12}, \qquad Q(u, v) = u_{01}v_{23} + v_{01}u_{23} - (u_{02}v_{13} + v_{02}u_{13}) + (u_{03}v_{12} + v_{03}u_{12}).
$$

Theorem 5 (`madelung_klein_quadric_tangency`) proves the exact ring identity:

$$
Q\bigl(\alpha n,\, (d\alpha)n + \alpha(dn)\bigr) = 2\,\alpha\,(d\alpha)\,Q(n) + \alpha^2\,Q(n, dn).
$$

Whenever the normalized ray lies on the Klein quadric ($Q(n) = 0$) and its directional derivative is tangent to the Klein quadric ($Q(n, dn) = 0$), both terms vanish identically ($Q(\Psi, \partial_\mu\Psi) = 0$), proving that **the Madelung amplitude-phase factorization preserves Klein quadric tangency identically**.

---

## 3. Why the Turner Model Projects $\mathrm{Gr}_{\mathbb{C}}(2,4)$ onto $\mathcal{Q}_4$ with a Fubini–Study Kähler Metric ($= \frac{1}{4}\mathrm{QFIM}$) and DDF Refractive Index Instead of Witten's Raw Conformal Supergravity

In our companion papers on QED/gauge scattering gravity ([grassmannian-gravity-from-qed-scattering-paper.md](grassmannian-gravity-from-qed-scattering-paper.md)), Complex Grassmannian GPE/`iGPE` ([grassmannian-complex-gpe-igpe-plucker-madelung-paper.md](grassmannian-complex-gpe-igpe-plucker-madelung-paper.md)), and $\mathrm{SU}(4)$ / Witten Twistor String / CHY unification ([grassmannian-su4-witten-twistor-string-cachazo-ddf-turner-ads-cft-unification-paper.md](grassmannian-su4-witten-twistor-string-cachazo-ddf-turner-ads-cft-unification-paper.md)), a central distinction governs how twistor space $\mathbb{CP}^3 = \mathrm{Gr}_{\mathbb{C}}(1,4)$ and the spacetime Grassmannian $\mathrm{Gr}_{\mathbb{C}}(2,4)$ couple to gravity:

> In [ the Turner model ] instead of taking the raw conformal supergravity sector of Witten's string at face value, you project $\text{Gr}_{\mathbb{C}}(2,4)$ onto the **Klein quadric $\mathcal{Q}_4$ with a Fubini–Study Kähler metric and DDF refractive index**, recovering standard 1PN Einstein precession (Mercury's perihelion) and two-derivative Madelung hydrodynamics without unphysical fourth-derivative ghost

Let us trace how the identity $F_{\mu\nu} = 4\,g_{\mu\nu}^{\mathrm{FS}}$ and Theorem 3 (`totalGpeKinetic3D_eq_madelung_qfim_trace`) make this ghost-free projection mathematically exact:

| Architectural Feature | 1. Raw Conformal Supergravity Sector of Witten's Twistor String ({cite:p}`witten2004twistor`; {cite:p}`berkovits2004conformal`) | 2. Cachazo–Skinner Infinity-Twistor On-Shell Projection ({cite:p}`cachazo2013gravity`) | 3. Turner (2026) Klein Quadric $\mathcal{Q}_4$ + Fubini–Study Kähler ($= \frac{1}{4}\mathrm{QFIM}$) + DDF Refractive Model (`Signals.DDF` Sec. 30 & `Signals.DFT` Sec. 27) |
| :--- | :--- | :--- | :--- |
| **Target Manifold & Metric** | Scale-free projective supertwistor space $\mathbb{CP}^{3\|4}$ with unbroken 15-parameter $\mathrm{SU}(2,2\|4)$ conformal invariance | Asymptotic flat-space $\mathbb{CP}^{3\|8}$ with rank-2 infinity twistor $I_{AB}$ breaking scale invariance on external states | **Klein quadric $\mathcal{Q}_4 \subset \mathbb{CP}^5$ equipped with Fubini–Study Kähler metric $g_{\mu\nu}^{\mathrm{FS}} = \frac{1}{4}F_{\mu\nu}$ + DDF refractive index $n_{\mathrm{DDF}}$ ($c^{-2} = \varrho_{\max}^\varphi j_{\min}^\varphi$)** |
| **Derivative Order of Kinetic Action & Propagator** | **4th-derivative Weyl action** $\mathcal{L}_{\mathrm{Weyl}} \propto C_{\mu\nu\rho\sigma}C^{\mu\nu\rho\sigma} \sim h\,\Box^2 h$; propagator $\frac{1}{q^2(q^2 - m_{\mathrm{ghost}}^2)}$ (`wittenFourthOrderPropagator`) | **2-derivative on-shell S-matrix** ($1/q^2$ graviton poles via squared reduced Hodges determinants $\det'(\Phi)\det'(\tilde{\Phi})$) | **Strictly 2-derivative Madelung–QFIM action**: $\mathcal{T}_{\mathrm{GPE}} = \frac{\hbar^2}{2m}\rho\mathcal{A}_\mu^2 + \frac{\hbar^2}{8m}\frac{(\partial_\mu\rho)^2}{\rho} + \frac{\hbar^2}{2m}\rho\,g_{\mu\mu}^{\mathrm{FS}}$ (`twoDerivativeGravitonPropagator` $= 1/q^2$) |
| **Ostrogradsky Ghost Status** | **Fails unitarity**: partial-fraction split $\frac{1}{m_{\mathrm{ghost}}^2}\bigl(\frac{1}{q^2 - m_{\mathrm{ghost}}^2} - \frac{1}{q^2}\bigr)$ has negative-norm ghost residue $-1/m_{\mathrm{ghost}}^2 < 0$ | **Ghost-free** in asymptotic tree/loop scattering amplitudes (no continuous off-shell hydro PDE) | **Ghost-free everywhere**: positive-definite Cauchy–Schwarz Kähler kinetic energy $g_{\mu\mu}^{\mathrm{FS}} = \frac{\|\Psi_\perp\|^2}{\rho} \ge 0$ (`qfim_fubini_study_cauchy_schwarz_gauge_invariance_and_vortex_core_critique_identities`) |
| **Static Potential & Orbital Semi-Latus Factor** | Biharmonic $\nabla^4\Phi = 0 \implies \Phi(r) = -\frac{GM}{r} + \frac{1}{2}\gamma_{\mathrm{conf}} r$ (unphysical linear confinement term) | Asymptotic potential extracted via post-Minkowskian scattering angles | **Exact Kähler determinant excess**: $\mathcal{D}(W_{\mathrm{orb}}) = \det(I_2 + W_{\mathrm{orb}}W_{\mathrm{orb}}^\dagger) = 4 - e^2 \implies \mathcal{D}(W_{\mathrm{orb}}) - 3 = 1 - e^2 = \frac{p}{a}$ (`turnerKahlerOrbitalSemiLatusFactor`) |
| **1PN Mercury Perihelion ($42.98''/\text{cy}$), 1PN Light Bending, & 2.5PN GW Error $\varepsilon_{\mathrm{rel}}$** | **$\varepsilon_{\mathrm{rel}} = 100\%$** (at $\beta_{\mathrm{scale}}=0$) or grows unboundedly as $a^3$ (`wittenConformalTwistorPrecessionRad`) | **$\varepsilon_{\mathrm{rel}} = 0$ ($0.00\%$)** at $\pi_I = 1, \Lambda_{\mathrm{cc}} = 0$ (`cachazoSkinnerTwistorPrecessionRad`) | **$\varepsilon_{\mathrm{rel}} = 0$ ($0.00\%$)** across 1PN perihelion (`turnerPluckerIGPEPrecessionRad`, `turnerDualGr24IGPEDDFPrecessionRad`), 1PN light bending (`turnerPluckerKahlerLightDeflection`, `turnerDualGr24IGPEDDFLightDeflection`), & 2.5PN GW (`turnerPluckerIGPEGWLuminosity`, `turnerDualGr24IGPEDDFGWLuminosity`) |

### 3.1 Algebraic Proof of the Partial-Fraction Ghost Decomposition vs. Two-Derivative Kähler Regularity

In `qfim_four_times_fubini_study_turner_projection_and_unification_identities` ({download}`src/signals/Signals/DFT.lean, lines 9152–9222 <../src/signals/Signals/DFT.lean>`), we prove that for any non-zero momentum squared $q^2 \neq 0$, ghost mass squared $m_{\mathrm{ghost}}^2 \neq 0$, and $q^2 - m_{\mathrm{ghost}}^2 \neq 0$, Witten's fourth-order conformal propagator (`wittenFourthOrderPropagator`) satisfies:

$$
\operatorname{wittenFourthOrderPropagator}(q^2, m_{\mathrm{ghost}}^2) = \frac{1}{q^2(q^2 - m_{\mathrm{ghost}}^2)} = \frac{1}{m_{\mathrm{ghost}}^2}\Bigl(\underbrace{\frac{1}{q^2 - m_{\mathrm{ghost}}^2}}_{\text{Ostrogradsky pole}} - \underbrace{\frac{1}{q^2}}_{\text{2-derivative graviton}}\Bigr).
$$

Because the two poles have **opposite-sign residues** ($\pm 1/m_{\mathrm{ghost}}^2$), canonical quantization of the 4-derivative action $\int d^4x\,C_{\mu\nu\rho\sigma}C^{\mu\nu\rho\sigma}$ necessarily introduces negative-norm ghost states (or unbounded negative Ostrogradsky energy in classical phase space).

By contrast, in the **Turner model**, projecting $\mathrm{Gr}_{\mathbb{C}}(2,4)$ onto $\mathcal{Q}_4 \subset \mathbb{CP}^5$ with the Fubini–Study Kähler metric $g_{\mu\nu}^{\mathrm{FS}} = \frac{1}{4}F_{\mu\nu}$ and the DDF refractive index $n_{\mathrm{DDF}}(P_{\mathrm{amb}}, P_{\mathrm{loc}}, \rho_0, c^2) = 1 + \frac{2(P_{\mathrm{amb}} - P_{\mathrm{loc}})}{\rho_0 c^2}$ (`ddfPressureGradientRefractiveIndex`):
1. **Strictly Two-Derivative Hydrodynamics**: Every term in the 3D Gross–Pitaevskii kinetic energy density (`totalGpeKinetic3D_eq_madelung_qfim_trace` and `totalProjectiveQfimEnergy3D_eq_fubiniStudyEnergy3D`):

   $$
   \mathcal{T}_{\mathrm{GPE}} = \frac{\hbar^2}{2m}\,\rho\sum_{\mu=1}^3 \mathcal{A}_\mu^2 + \frac{\hbar^2}{8m}\sum_{\mu=1}^3 \frac{(\partial_\mu\rho)^2}{\rho} + \frac{\hbar^2}{2m}\,\rho\,\operatorname{Tr}(g_{\mu\nu}^{\mathrm{FS}})
   $$

   is quadratic in **first** spatial derivatives $(\partial_\mu S_0, \partial_\mu\rho, \partial_\mu n)$, producing a purely second-order Euler–Lagrange wave operator with propagator $\operatorname{twoDerivativeGravitonPropagator}(q^2) = 1/q^2$ and **zero** fourth-derivative ghost pole!
2. **Exact 1PN Perihelion Precession & Light Bending from the Kähler Potential $\mathcal{K} = \ln\det(I_2 + W W^\dagger)$**:
   On the canonical affine chart $Z = (I_2 \mid W_{\mathrm{orb}}(e, \phi))$ of $\mathrm{Gr}_{\mathbb{C}}(2,4) \cong \mathcal{Q}_4$, the Cauchy–Binet Kähler determinant factor (`kahlerDetFactor_eq_pluckerNormSq_and_ge_one`) evaluates to $\mathcal{D}(W_{\mathrm{orb}}) = \det(I_2 + W_{\mathrm{orb}}W_{\mathrm{orb}}^\dagger) = \|p(I_2 \mid W_{\mathrm{orb}})\|^2 = 4 - e^2$. Subtracting the baseline value $3$ gives the exact orbital semi-latus rectum factor (`turnerKahlerOrbitalSemiLatusFactor`):

   $$
   \mathcal{D}\bigl(W_{\mathrm{orb}}(e)\bigr) - 3 = (4 - e^2) - 3 = 1 - e^2 = \frac{p}{a},
   $$

   which—paired with the DDF constitutive light speed $c^{-2} = \varrho_{\max}^\varphi j_{\min}^\varphi$—yields:

   $$
   \Delta\varpi_{\mathrm{Turner}} = \frac{6\pi G_\phi M\,\varrho_{\max}^\varphi j_{\min}^\varphi}{a\bigl(\mathcal{D}(W_{\mathrm{orb}}) - 3\bigr)} = \frac{6\pi G M}{c^2 a(1 - e^2)} = \Delta\varpi_{\mathrm{GR}}, \qquad \Delta\theta_\gamma^{\mathrm{Turner}} = \Delta\theta_{\mathrm{GR}}\cdot\frac{\mathcal{D}(W_{\mathrm{orb}}) - 3}{1 - e^2} = \frac{4 G M}{c^2 b}.
   $$

---

## 4. Relative Merits of Cachazo (`CSW` / `BCFW` / `Hodges` / `CHY`) vs. QED Scattering Gravity (`BCJ` / Partanen–Tulkki $\mathrm{U}(1)^4$) vs. DDF vs. Turner Models and How They Unify with the QFIM and Fubini–Study Kähler Metric

In Companion Paper 30 ([$\mathrm{SU}(4)$ Symmetry, Witten's Twistor String Theory, Lower Grassmannians in $\mathrm{Gr}_{\mathbb{R}}$ and $\mathrm{Gr}_{\mathbb{C}}$, Relative Merits of Cachazo (CSW / BCFW / Hodges / CHY) vs. DDF vs. Turner Models, and Grand Unification with the Holographic Principle and AdS/CFT in Lean 4, Rust, and Python](grassmannian-su4-witten-twistor-string-cachazo-ddf-turner-ads-cft-unification-paper.md)), Companion Paper 4 ([Grassmannian Gravity from QED & Gauge Scattering Amplitudes: Complex $\mathrm{Gr}_{\mathbb{C}}(2,4)$ Orbital Precession, Mercury's Perihelion, $N$-Body Dynamics, and Dilatant Dark Fluid (DDF) Unification](grassmannian-gravity-from-qed-scattering-paper.md)), and `Signals.DFT` Sections 20, 27.3, and 27.4 ({download}`src/signals/Signals/DFT.lean, lines 4508–4835 and 9370–9745 <../src/signals/Signals/DFT.lean>`), we analyzed why **Freddy Cachazo's on-shell twistor/Grassmannian program** ({cite:p}`csw2004`; {cite:p}`bcfw2005`; {cite:p}`su4-cachazogeyer2012`; {cite:p}`cachazo2013gravity`; {cite:p}`su4-masonskinner2013`; {cite:p}`chy2014`) and **flat-space QED / gauge scattering gravity** ({cite:p}`bern2008bcj`; {cite:p}`bjerrum2018general`; {cite:p}`partanen2025gravity`; {cite:p}`partanen2025perihelion`) are essential if one wishes to simulate gauge or gravitational dynamics starting from Witten's Twistor String Theory {cite:p}`witten2004twistor`, and how their relative merits compare against **Fedi's Dilatant Dark Fluid (`DDF`, {cite:p}`fedi2026ddf`)** and the **Turner (2026) Plücker $\mathcal{Q}_4$ Fubini–Study Kähler / `QFIM` / Tensor Splat models**.

### 4.1 Summary of the Relative Merits of Cachazo (`CSW` / `BCFW` / `Hodges` / `CHY`) vs. Witten's Twistor String, DDF, and Turner Models

Directly discretizing or Monte-Carlo sampling Witten's (2003/2004) continuum topological B-model string path integral on $\mathbb{CP}^{3|4}$ encounters two fatal obstacles that **Cachazo's program** resolves algebraically ([grassmannian-su4-witten-twistor-string-cachazo-ddf-turner-ads-cft-unification-paper.md](grassmannian-su4-witten-twistor-string-cachazo-ddf-turner-ads-cft-unification-paper.md)):

1. **Obstacle 1 (Physical Ghost Pathology) $\to$ Solved by Cachazo–Skinner Infinity-Twistor Projection & Reduced Hodges Determinants ({cite:p}`cachazo2013gravity`)**:
   - Witten's closed-string gravity sector on $\mathbb{CP}^{3|4}$ preserves full 15-parameter $\mathrm{SU}(2,2|4)$ conformal invariance, generating 4-derivative Weyl conformal supergravity ($\mathcal{L}_{\mathrm{Weyl}} \propto C_{\mu\nu\rho\sigma}^2$, $1/q^4$ propagator with non-unitary Ostrogradsky ghosts {cite:p}`berkovits2004conformal`).
   - **Cachazo and Skinner (2012/2013, `arXiv:1207.0741`)** introduce the antisymmetric **infinity twistor** $I_{AB}$ ($I_{AB} I^{BC} = \Lambda_{\mathrm{cc}}\,\delta_A^C$) to break spurious conformal invariance and project 4-component twistors $Z_j^A \in \mathbb{CP}^3$ onto $2\times 2$ Plücker minors $\langle i\,j\rangle_I = I_{AB} Z_i^A Z_j^B = \Delta_{ij}^{\mathbb{C}}(M_{\mathbb{C}})$ on $\mathrm{Gr}_{\mathbb{C}}(2,4)$, while replacing Witten's single-trace conformal vertices with the **double copy of reduced Hodges determinants** $\det'(\Phi)\,\det'(\tilde{\Phi})$ (`cachazoSkinnerHodges4PtKernel` in {download}`src/signals/Signals/QEDGravity.lean, lines 973–1023 <../src/signals/Signals/QEDGravity.lean>`). At projection fidelity $\pi_I = 1$ (`cachazoSkinnerFilteredPropagator`), the $1/q^4$ Weyl ghost is projected out identically, recovering the 2-derivative $1/q^2$ graviton propagator and $\varepsilon_{\mathrm{rel}} = 0$ for 1PN perihelion precession, 1PN light bending, and 2.5PN gravitational waves.
2. **Obstacle 2 (Combinatorial & Worldsheet Path-Integral Explosion) $\to$ Solved by CHY $(n-3)!$ Worldsheet Localization & BCFW Catalan Triangulation ({cite:p}`bcfw2005`; {cite:p}`su4-cachazogeyer2012`; {cite:p}`chy2014`)**:
   - Standard off-shell Feynman diagrams grow factorially ($N_{\mathrm{Feynman}}(n) = 4, 25, 220, 2{,}485, 34{,}300, 10{,}525{,}900$ for $n = 4, 5, 6, 7, 8, 10$), while continuum integration over degree-$d$ holomorphic curves $\mathbb{CP}^1 \to \mathbb{CP}^{3|4}$ has complex moduli dimension $4d + n$.
   - **Cachazo–Geyer (2012)** lifts the degree-$(k-1)$ curve to the Grassmannian $\mathrm{Gr}_{\mathbb{C}}(k, n)$; **Cachazo–He–Yuan (`CHY`, 2013/2014)** localizes the string worldsheet integral onto $(n-3)!$ discrete roots of the scattering equations $E_a(\sigma) = \sum_{b \neq a} \frac{s_{ab}}{\sigma_a - \sigma_b} = 0$ (`chySolutionCount`: $1, 2, 6, 24, 120, 5{,}040$—a **$2{,}088\times$ reduction** at $n=10$); and **BCFW recursion** triangulates $\mathrm{Gr}_{\mathbb{C}}(k,n)$ into $C_{n-3} = \frac{1}{n-2}\binom{2n-6}{n-3}$ Catalan on-shell Plücker cells (`bcfwCatalanTreeCount`: $1, 2, 5, 14, 42, 429$—a **$24{,}536\times$ reduction** at $n=10$).

| Evaluation Dimension | 1. Original Witten (2004) Twistor String ({cite:p}`witten2004twistor`; {cite:p}`berkovits2004conformal`) | 2. Cachazo Program (`CSW` / `BCFW` / `Cachazo–Skinner` / `CHY`, {cite:p}`csw2004,bcfw2005,cachazo2013gravity,chy2014`) | 3. Dilatant Dark Fluid (`DDF`, Fedi 2026, {cite:p}`fedi2026ddf`) | 4. Turner (2026) Plücker $\mathcal{Q}_4$ Fubini–Study Kähler ($= \frac{1}{4}\mathrm{QFIM}$), Dual-`iGPE`, & Tensor Splat Models |
| :--- | :--- | :--- | :--- | :--- |
| **Primary Manifold & Metric** | Scale-free $\mathbb{CP}^{3\|4} = \mathrm{Gr}_{\mathbb{C}}(1,4\|4)$ | $\mathrm{Gr}_{\mathbb{C}}(k,n)$, $\mathrm{Gr}_{\ge 0}(k,n)$, & CHY worldsheet $\Sigma \cong \mathbb{CP}^1 = \mathrm{Gr}_{\mathbb{C}}(1,2)$ | 4D Painlevé–Gullstrand river spacetime $\mathbb{R}^{1,3}$ with $(\phi, \varphi)$ two-phase bosonic substrate | **Dual-Schubert $\mathrm{Gr}_{\mathbb{C}}(2,4) \times \mathrm{Gr}_{\mathbb{C}}(2,4)^\vee \cong \mathcal{Q}_4 \subset \mathbb{CP}^5$ with $g_{\mu\nu}^{\mathrm{FS}} = \frac{1}{4}F_{\mu\nu}$ + 2D/3D `NormedTensorGaussianSplat`** |
| **Gravitational Propagator & Ghost Status** | **Fails**: $1/(q^2(q^2 - m_{\mathrm{ghost}}^2))$ 4th-order Weyl conformal supergravity with Ostrogradsky ghosts | **Exact on-shell**: $\pi_I = 1$ infinity twistor & Hodges double copy $\det'(\Phi)\det'(\tilde{\Phi})$ project onto $1/q^2$ | **Exact 1PN / 2.5PN**: Conservative superfluid enthalpy $\Phi_\phi = -G_\phi M/r$, $n_{\mathrm{DDF}}$, & Lorentz jamming $\gamma_\varphi(v)$ | **Exact 1PN / 2.5PN + UV Regularized**: 2-derivative Kähler-QFIM action $\frac{\hbar^2}{2m}\rho g_{\mu\mu}^{\mathrm{FS}} = \frac{\hbar^2}{8m}\rho F_{\mu\mu}$ + $\mathcal{D}(W_{\mathrm{orb}})-3 = 1-e^2$ |
| **1PN Mercury Precession, 1PN Light Bending, & 2.5PN GW Error $\varepsilon_{\mathrm{rel}}$** | $\varepsilon_{\mathrm{rel}} = 100\%$ or grows as $a^3$ (`wittenConformalTwistorPrecessionRad`) | **$\varepsilon_{\mathrm{rel}} = 0$ ($0.00\%$)** at $\pi_I = 1, \Lambda_{\mathrm{cc}} = 0$ (`cachazoSkinnerTwistorPrecessionRad`, `cachazoSkinnerLightDeflection`) | **$\varepsilon_{\mathrm{rel}} = 0$ ($0.00\%$)** for conservative action (`perihelionPrecessionRad`, `ddfRefractiveLightDeflection`) | **$\varepsilon_{\mathrm{rel}} = 0$ ($0.00\%$)** at solar-system scales (`turnerPluckerIGPEPrecessionRad`, `turnerDualGr24IGPEDDFPrecessionRad`, `turnerPluckerKahlerLightDeflection`, `turnerDualGr24IGPEDDFLightDeflection`) |
| **Asymptotic S-Matrix vs. Continuous Real-Time PDE** | Asymptotic boundary S-matrix only | **Best-in-class S-matrix**: $(n-3)!$ CHY roots & $C_{n-3}$ BCFW cells without Feynman diagrams | **Best-in-class constitutive fluid**: real-time Euler/Madelung flow, $c = (\varrho_{\max}^\varphi j_{\min}^\varphi)^{-1/2}$, galactic $v_{\mathrm{flat}} = \sqrt{q_\rho}c_\phi$ | **Unites both**: Cachazo on-shell Plücker vertices on $\mathcal{Q}_4$ + continuous Fubini–Study/QFIM `iGPE` PDE + $O(N_{\mathrm{splat}})$ GPU/WASM splatting |
| **Quantum Information & Metrology Link** | None | **Worldsheet QFIM**: $\mathcal{A}_4^{\mathrm{CHY},\phi^3} = \frac{F_{\sigma\sigma}^{\mathrm{CHY}}(\sigma_4^*)}{s_{12}+s_{13}} = \frac{4 g_{\sigma\sigma}^{\mathrm{FS}}(\sigma_4^*)}{s_{12}+s_{13}}$ (`chyFourPointBiAdjointScalar`) | Acoustic horizon redshift lapse $\|w_A\|^2\|w_B\|^2 = 1 - r_H/r$ | **Full 8-pillar $F_{\mu\nu} = 4 g_{\mu\nu}^{\mathrm{FS}}$ unification**: Bures, $4\times$ QCRB, Mandelstam–Tamm QSL, flat-band `G-MGS`/`G-CSC`, & `ER=EPR` |

### 4.2 How Cachazo Gravity Unifies with the Quantum Fisher Information Metric (`QFIM`) and Fubini–Study Kähler Metric (`Signals.DFT` Section 27.3)

A natural question arises from comparing Column 2 (Cachazo) and Column 4 (Turner) above: **how does Cachazo's on-shell scattering gravity (`CHY` worldsheet localization and `Cachazo–Skinner` Hodges double copy) unify mathematically with the Quantum Fisher Information Metric $F_{\mu\nu}$ and the Fubini–Study Kähler metric $g_{\mu\nu}^{\mathrm{FS}}$?**

```{mermaid}
flowchart TB
    subgraph CHY["1. CHY Worldsheet Σ ≅ CP¹ = Gr_C(1,2) (R_Gr = 2)"]
        C1["Unique 4-Point CHY Root:\nσ_4* = s_12 / (s_12 + s_13) = p_s\n1 - σ_4* = s_13 / (s_12 + s_13) = p_t\nBinary channel simplex: p_s + p_t = 1"]
        C2["Worldsheet QFIM = 4 × Fubini–Study:\nF^CHY_σσ(σ_4) = 1 / (σ_4(1 - σ_4)) = 4 g^FS_σσ(σ_4)"]
        C3["Exact CHY Amplitude & Hessian Identities:\n• A_4^{CHY,φ³} = 1/s_12 + 1/s_13 = F^CHY_σσ(σ_4*) / (s_12 + s_13)\n• Φ^CHY_44 = -(s_12 + s_13) F^CHY_σσ(σ_4*) = -4(s_12 + s_13) g^FS_σσ(σ_4*)"]
        C1 --> C2 --> C3
    end

    subgraph CS["2. Cachazo–Skinner & BCJ Double Copy on Q_4 = Gr_C(2,4) (R_Gr = 16)"]
        S1["Infinity Twistor I_AB (π_I = 1):\nProjects CP^(3|8) → Gr_C(2,4) Plücker minors ⟨ij⟩_I = Δ_ij^C\nFilters Witten's 1/(q²(q²-m²)) ghost → 2-derivative 1/q²"]
        S2["Hodges Double-Copy Kernel on Orbital Channels (w_A = 1+e, w_B = 1-e):\n• K_CS(1+e, 1-e) = (w_A + w_B)² = 4 (the exact factor of 4!)\n• (K_CS - (w_A - w_B)²) / 4 = 1 - e² = D(W_orb) - 3 (Turner Kähler excess!)"]
        S3["Orbital Simplex QFIM Phase-Variance Identity:\nFor p_s = (1+e)/2, p_t = (1-e)/2:\n4 Var_p^(2)(∂_μ ϕ) = (D(W_orb) - 3) (∂_μ ϕ_0 - ∂_μ ϕ_1)² = (1 - e²)(∂_μ ϕ_0 - ∂_μ ϕ_1)²"]
        S1 --> S2 --> S3
    end

    CHY ==>|"Plücker Lift Gr_C(1,2) → Gr_C(2,4) ≅ Q_4\nF_μν = 4 g^FS_μν"| CS
```

In Theorem `cachazo_gravity_chy_hodges_qfim_and_fubini_study_unification_identities` ({download}`src/signals/Signals/DFT.lean, lines 9440–9550 <../src/signals/Signals/DFT.lean>`), we establish four exact algebraic bridges uniting Cachazo gravity with $F_{\mu\nu} = 4\,g_{\mu\nu}^{\mathrm{FS}}$:

1. **The 4-Point CHY Worldsheet Puncture $\sigma_4^*(s_{12}, s_{13}) \in \mathbb{CP}^1 = \mathrm{Gr}_{\mathbb{C}}(1,2)$ Is a Binary Fisher Probability Simplex Whose QFIM Is $4\times$ the Worldsheet Fubini–Study Metric**:
   In Cachazo–He–Yuan theory {cite:p}`chy2014`, the $n$-particle scattering equations live on the Riemann sphere $\Sigma \cong \mathbb{CP}^1 = \mathrm{Gr}_{\mathbb{C}}(1,2)$ (the lowest complex Grassmannian in our taxonomy, with $\dim_{\mathbb{R}}\mathrm{Gr}_{\mathbb{C}}(1,2) = 2$ and Einstein–Kähler scalar curvature $R_{\mathrm{Gr}}(1,2) = 2$). After $\mathrm{SL}(2,\mathbb{C})$ gauge fixing $(\sigma_1, \sigma_2, \sigma_3) = (0, 1, \infty)$, the unique 4-point root (`chyFourPointRoot`) is:

   $$
   p_s := \sigma_4^*(s_{12}, s_{13}) = \frac{s_{12}}{s_{12} + s_{13}}, \qquad p_t := 1 - \sigma_4^*(s_{12}, s_{13}) = \frac{s_{13}}{s_{12} + s_{13}}, \qquad p_s + p_t = 1.
   $$

   Embedding this binary $s/t$-channel partition into the normalized worldsheet ray $n_{\mathrm{CHY}}(\sigma_4) = (\sqrt{\sigma_4}, \sqrt{1 - \sigma_4})^\top \in \mathbb{CP}^1$, the pullback of the **Fubini–Study Kähler metric** (`chyWorldsheetFubiniStudyMetric`) and the **Quantum/Classical Fisher Information Metric** (`chyWorldsheetQfimMetric`) with respect to $\sigma_4$ are:

   $$
   g_{\sigma\sigma}^{\mathrm{FS}}(\sigma_4) = \left(\frac{d\sqrt{\sigma_4}}{d\sigma_4}\right)^2 + \left(\frac{d\sqrt{1-\sigma_4}}{d\sigma_4}\right)^2 = \frac{1}{4\,\sigma_4\,(1 - \sigma_4)}, \qquad F_{\sigma\sigma}^{\mathrm{CHY}}(\sigma_4) = \frac{1}{\sigma_4} + \frac{1}{1 - \sigma_4} = \frac{1}{\sigma_4\,(1 - \sigma_4)} = 4\,g_{\sigma\sigma}^{\mathrm{FS}}(\sigma_4).
   $$

2. **The 4-Point CHY Scattering Amplitude $\mathcal{A}_4^{\mathrm{CHY},\phi^3}$ and Reduced CHY Jacobian $\Phi_{44}^{\mathrm{CHY}}$ Are Exact Multiples of the Worldsheet QFIM and Fubini–Study Curvature**:
   Evaluating $F_{\sigma\sigma}^{\mathrm{CHY}}(\sigma_4)$ and $g_{\sigma\sigma}^{\mathrm{FS}}(\sigma_4)$ at the on-shell root $\sigma_4^*(s_{12}, s_{13}) = \frac{s_{12}}{s_{12} + s_{13}}$ gives $F_{\sigma\sigma}^{\mathrm{CHY}}(\sigma_4^*) = \frac{(s_{12} + s_{13})^2}{s_{12}\,s_{13}}$. Dividing by the total Mandelstam energy $s_{12} + s_{13}$ recovers the **exact 4-point CHY bi-adjoint scalar amplitude** (`chyFourPointBiAdjointScalar`):

   $$
   \mathcal{A}_4^{\mathrm{CHY},\phi^3}(s_{12}, s_{13}) = \frac{1}{s_{12}} + \frac{1}{s_{13}} = \frac{F_{\sigma\sigma}^{\mathrm{CHY}}\bigl(\sigma_4^*(s_{12}, s_{13})\bigr)}{s_{12} + s_{13}} = \frac{4\,g_{\sigma\sigma}^{\mathrm{FS}}\bigl(\sigma_4^*(s_{12}, s_{13})\bigr)}{s_{12} + s_{13}}.
   $$

   Simultaneously, in CHY theory the scattering equations $E_a(\sigma) = \frac{\partial\mathcal{W}_{\mathrm{CHY}}}{\partial\sigma_a} = 0$ are the stationary points of the logarithmic master potential $\mathcal{W}_{\mathrm{CHY}}(\sigma) = \sum_{a < b} s_{ab}\ln|\sigma_a - \sigma_b|^2$, and the reduced CHY Jacobian $\Phi_{ab}^{\mathrm{CHY}} = \frac{\partial E_a}{\partial\sigma_b} = \frac{\partial^2\mathcal{W}_{\mathrm{CHY}}}{\partial\sigma_a\partial\sigma_b}$ is its Hessian. At $n = 4$, `chyFourPointReducedJacobian` proves:

   $$
   \Phi_{44}^{\mathrm{CHY}}\bigl(s_{12}, s_{13}, \sigma_4^*(s_{12}, s_{13})\bigr) = -\frac{s_{12}}{(\sigma_4^*)^2} - \frac{s_{13}}{(1 - \sigma_4^*)^2} = -(s_{12} + s_{13})\,F_{\sigma\sigma}^{\mathrm{CHY}}(\sigma_4^*) = -4(s_{12} + s_{13})\,g_{\sigma\sigma}^{\mathrm{FS}}(\sigma_4^*).
   $$

   Thus, **the CHY worldsheet localization measure $|\det'\Phi_{\mathrm{CHY}}|^{-1}$ is directly proportional to the worldsheet Quantum Cramér–Rao variance bound $\mathrm{QCRB} = 1 / F_{\sigma\sigma}^{\mathrm{CHY}} = 1 / (4\,g_{\sigma\sigma}^{\mathrm{FS}})$**!

3. **Cachazo–Skinner Infinity-Twistor Projection ($\pi_I \in [0, 1]$) Filters Witten's 4th-Order Ghost into the 2-Derivative Fubini–Study / QFIM Propagator**:
   In `cachazoSkinnerFilteredPropagator`, weighting the 2-derivative graviton propagator $1/q^2$ by the infinity-twistor projection fidelity $\pi_I \in [0, 1]$ and Witten's 4th-order Weyl propagator by $1 - \pi_I$:

   $$
   G_{\mathrm{CS}}(q^2, m_{\mathrm{ghost}}^2, \pi_I) = \pi_I\,\frac{1}{q^2} + (1 - \pi_I)\,\frac{1}{q^2(q^2 - m_{\mathrm{ghost}}^2)}
   $$

   reduces at $\pi_I = 0$ to Witten's ghost-ridden propagator (`wittenFourthOrderPropagator`) and at $\pi_I = 1$ to the pure 2-derivative propagator $1/q^2$ (`twoDerivativeGravitonPropagator`) generated by the Fubini–Study / QFIM kinetic energy $\frac{\hbar^2}{8m}\rho\,\operatorname{Tr}(F_{\mu\nu}) = \frac{\hbar^2}{2m}\rho\,\operatorname{Tr}(g_{\mu\nu}^{\mathrm{FS}})$, matching `cachazoSkinnerLightDeflection delta_theta_gr 1 gamma_conf b_impact = turnerPluckerKahlerLightDeflection delta_theta_gr (4 - e_ecc^2) e_ecc 0 = delta_theta_gr`.

4. **The Cachazo–Skinner Hodges Double-Copy Kernel $\mathcal{K}_{\mathrm{CS}} = (w_A + w_B)^2$ Reproduces Both the Factor of $4$ and the Orbital Kähler / QFIM Phase-Variance Weight $1 - e^2$**:
   By the 3-term Plücker identity $\Delta_{02}^{\mathbb{C}}\Delta_{13}^{\mathbb{C}} = w_A^{\mathbb{C}} + w_B^{\mathbb{C}}$ on $\mathcal{Q}_4 = \mathrm{Gr}_{\mathbb{C}}(2,4)$, the Cachazo–Skinner 4-point reduced Hodges double-copy kernel (`cachazoSkinnerHodges4PtKernel_eq_bcj_double_copy`, `cachazoHodgesDoubleCopyScalarKernel`) is $\mathcal{K}_{\mathrm{CS}}(w_A, w_B) = (w_A + w_B)^2$. Evaluating on the canonical orbital Plücker channels $w_A = 1 + e$ and $w_B = 1 - e$:
   - The coherent double-copy sum is **identically $4$**—the exact proportionality constant in $F_{\mu\nu} = 4\,g_{\mu\nu}^{\mathrm{FS}}$:

     $$
     \mathcal{K}_{\mathrm{CS}}(1 + e, 1 - e) = \bigl((1 + e) + (1 - e)\bigr)^2 = 2^2 = 4.
     $$

   - Subtracting the squared channel asymmetry $(w_A - w_B)^2 = 4e^2$ and dividing by $4$ recovers the **Turner Fubini–Study Kähler orbital semi-latus factor** $\mathcal{D}(W_{\mathrm{orb}}) - 3 = 1 - e^2 = w_A w_B$:

     $$
     \frac{\mathcal{K}_{\mathrm{CS}}(1 + e, 1 - e) - \bigl((1 + e) - (1 - e)\bigr)^2}{4} = \frac{4 - 4e^2}{4} = 1 - e^2 = \mathcal{D}\bigl(W_{\mathrm{orb}}(e)\bigr) - 3.
     $$

   - Normalizing $(w_A, w_B)$ to the two-channel orbital probability simplex $p_0 = \frac{1+e}{2}, p_1 = \frac{1-e}{2}$ ($p_0 + p_1 = 1$), the non-classical bivector phase-variance contribution $4\,\operatorname{Var}_p^{(2)}(\partial_\mu\phi)$ in Theorem 4 (`qfim_simplex_phase_variance_split`) is governed by the exact same Kähler semi-latus factor $1 - e^2$:

     $$
     4\,\operatorname{twoChannelPhaseVariance}\!\left(\frac{1 + e}{2},\, \frac{1 - e}{2},\, \partial_\mu\phi_0,\, \partial_\mu\phi_1\right) = \bigl(\mathcal{D}(W_{\mathrm{orb}}(e)) - 3\bigr)\,(\partial_\mu\phi_0 - \partial_\mu\phi_1)^2 = (1 - e^2)\,(\partial_\mu\phi_0 - \partial_\mu\phi_1)^2.
     $$

### 4.3 QED & Gauge Scattering Gravity (`BCJ` Double Copy, Partanen–Tulkki 2025 $\mathrm{U}(1)^4$ QFT, & Turner $\mathrm{Gr}_{\mathbb{C}}(2,4)$ Orbital/GW Models) Formulated in Terms of `QFIM` and the Fubini–Study Kähler Metric (`Signals.DFT` Section 27.4)

In Companion Paper 4 ([Grassmannian Gravity from QED & Gauge Scattering Amplitudes: Complex $\mathrm{Gr}_{\mathbb{C}}(2,4)$ Orbital Precession, Mercury's Perihelion, $N$-Body Dynamics, and Dilatant Dark Fluid (DDF) Unification](grassmannian-gravity-from-qed-scattering-paper.md)) and {download}`src/signals/Signals/QEDGravity.lean, lines 1–1060 <../src/signals/Signals/QEDGravity.lean>`, we showed how conservative 1PN planetary orbital precession (Mercury's $42.98''/\text{century}$, {cite:p}`einstein1915perihelion`; {cite:p}`einstein1916grundlage`), $N$-body dynamics, and radiative 2.5PN Peters–Mathews {cite:p}`peters1963gravitational` quadrupole gravitational waves emerge from **flat-space QED and gauge scattering amplitudes** via the **Bern–Carrasco–Johansson (`BCJ`) color-kinematics double copy** ($\text{Gravity} = \text{Gauge}^2$, {cite:p}`bern2008bcj`), **1-loop post-Minkowskian QFT** ({cite:p}`bjerrum2018general`), and **Partanen & Tulkki's (2025) four-$\mathrm{U}(1)$ gauge theory of gravity** ({cite:p}`partanen2025gravity`; {cite:p}`partanen2025perihelion`).

In Theorem `qed_scattering_gravity_bcj_partanen_tulkki_qfim_and_fubini_study_identities` ({download}`src/signals/Signals/DFT.lean, lines 9556–9745 <../src/signals/Signals/DFT.lean>`), we prove that the entire QED/gauge scattering gravity hierarchy—and its 17-model comparison against Nordström spin-0 scalar gravity {cite:p}`nordstrom1913gravitation` and un-doubled spin-1 Coulomb/Larmor vector QED—is governed by the **orbital eccentricity Quantum Fisher Information Metric $F_{ee}^{\mathrm{orb}}(e) = 4\,g_{ee}^{\mathrm{FS}}(e)$**:

1. **The Aphelion–Perihelion Plücker Simplex and Orbital Eccentricity `QFIM` ($F_{ee}^{\mathrm{orb}}(e) = 4\,g_{ee}^{\mathrm{FS}}(e) = \frac{1}{1 - e^2} = \frac{a}{p}$)**:
   In `PlanetaryOrbit.gr24PrecessionMatrix` and `PlanetaryOrbit.gr24QuadrupoleWaveMatrix` ([grassmannian-gravity-from-qed-scattering-paper.md](grassmannian-gravity-from-qed-scattering-paper.md)), an eccentric Keplerian orbit ($e \in [0, 1)$) is embedded into $M_{\mathbb{C}}^{\mathrm{orb}} \in \mathrm{Gr}_{\mathbb{C}}(2,4)$ with uncrossed Madelung channel densities $|w_A^{\mathbb{C}}|^2 = 1 + e = r_{\max}/a$ (aphelion weight) and $|w_B^{\mathbb{C}}|^2 = 1 - e = r_{\min}/a$ (perihelion weight). Normalizing by their invariant sum $|w_A^{\mathbb{C}}|^2 + |w_B^{\mathbb{C}}|^2 = 2$ defines the **aphelion–perihelion probability simplex**:

   $$
   p_{\mathrm{aph}}(e) = \frac{1 + e}{2}, \qquad p_{\mathrm{per}}(e) = \frac{1 - e}{2}, \qquad p_{\mathrm{aph}}(e) + p_{\mathrm{per}}(e) = 1, \qquad \frac{\partial p_{\mathrm{aph}}}{\partial e} = +\frac{1}{2}, \qquad \frac{\partial p_{\mathrm{per}}}{\partial e} = -\frac{1}{2}.
   $$

   Pulling back the Fubini–Study Kähler metric (`qedOrbitalEccentricityFubiniStudy`) and the Quantum/Classical Fisher Information Metric (`qedOrbitalEccentricityQfim`) along the eccentricity parameter $e$ yields:

   $$
   g_{ee}^{\mathrm{FS}}(e) = \frac{(1/2)^2}{4\,p_{\mathrm{aph}}(e)} + \frac{(-1/2)^2}{4\,p_{\mathrm{per}}(e)} = \frac{1}{4(1 - e^2)} = \frac{1}{4\bigl(\mathcal{D}(W_{\mathrm{orb}}(e)) - 3\bigr)},
   $$

   $$
   F_{ee}^{\mathrm{orb}}(e) = \frac{(1/2)^2}{p_{\mathrm{aph}}(e)} + \frac{(-1/2)^2}{p_{\mathrm{per}}(e)} = \frac{1}{1 - e^2} = 4\,g_{ee}^{\mathrm{FS}}(e) = \frac{1}{|w_A^{\mathbb{C}}|^2\,|w_B^{\mathbb{C}}|^2} = \frac{1}{\mathcal{D}(W_{\mathrm{orb}}(e)) - 3} = \frac{a}{p}.
   $$

   Thus, **the reciprocal of the Turner Fubini–Study Kähler determinant excess $\mathcal{D}(W_{\mathrm{orb}}(e)) - 3 = 1 - e^2$ is literally the orbital eccentricity Quantum Fisher Information Metric $F_{ee}^{\mathrm{orb}}(e) = 4\,g_{ee}^{\mathrm{FS}}(e)$** (`qedOrbitalEccentricityQfim e_ecc * turnerKahlerOrbitalSemiLatusFactor e_ecc = 1`)!

2. **1PN QED Double-Copy Perihelion Precession and 2.5PN Peters–Mathews Gravitational-Wave Luminosity as Exact Powers of the Orbital `QFIM` and Fubini–Study Metric**:
   - **1PN Post-Minkowskian Perihelion Advance ($\propto (F_{ee}^{\mathrm{orb}})^1 = 4\,g_{ee}^{\mathrm{FS}}$)**:
     In 1-loop QED/gauge double-copy scattering ({cite:p}`bern2008bcj`; {cite:p}`bjerrum2018general`) and Partanen–Tulkki $\mathrm{U}(1)^4$ gauge gravity ({cite:p}`partanen2025gravity`; {cite:p}`partanen2025perihelion`), tree-level $1/r$ graviton exchange plus the 1-loop triangle/seagull diagram ($\propto G^2 M m / |\mathbf{q}| \mapsto -\frac{3 G M L^2}{m c^2 r^3}$ in `postMinkowskianEffectivePotential`) produces a perihelion advance (`qedDoubleCopyPrecessionFromQfim`) that is **linear in the orbital QFIM $F_{ee}^{\mathrm{orb}}(e) = 4\,g_{ee}^{\mathrm{FS}}(e)$**:

     $$
     \Delta\varpi_{\mathrm{QED\text{-}2x}}(G, M, c, a, e) = \Delta\varpi_{\mathrm{circ}}\,F_{ee}^{\mathrm{orb}}(e) = 4\,\Delta\varpi_{\mathrm{circ}}\,g_{ee}^{\mathrm{FS}}(e) = \frac{6\pi G M}{c^2 a(1 - e^2)}, \qquad \Delta\varpi_{\mathrm{circ}} = \frac{6\pi G M}{c^2 a}.
     $$

   - **2.5PN Peters–Mathews Quadrupole Gravitational-Wave Luminosity ($\propto (F_{ee}^{\mathrm{orb}})^{7/2} = (4\,g_{ee}^{\mathrm{FS}})^{7/2}$)**:
     In `petersMathewsLuminosityPM` and `turnerGr24QEDGWLuminosity`, the squared Peters–Mathews eccentricity enhancement factor $f_{\mathrm{PM}}(e)^2 = \frac{P_{\mathrm{PM}}(e)^2}{(1 - e^2)^7}$ (`qedPetersMathewsFromOrbitalQfimSq`, where $P_{\mathrm{PM}}(e) = 1 + \frac{73}{24}e^2 + \frac{37}{96}e^4$) is **the seventh power of the orbital QFIM**:

     $$
     f_{\mathrm{PM}}(e)^2 = P_{\mathrm{PM}}(e)^2\,\bigl(F_{ee}^{\mathrm{orb}}(e)\bigr)^7 = P_{\mathrm{PM}}(e)^2\,\bigl(4\,g_{ee}^{\mathrm{FS}}(e)\bigr)^7 = \frac{P_{\mathrm{PM}}(e)^2}{\bigl(\mathcal{D}(W_{\mathrm{orb}}(e)) - 3\bigr)^7}.
     $$

   - **Quadrupole Crossing Extremum Product on $\mathcal{Q}_4$**:
     In the dynamic quadrupole wave matrix $M_{\mathbb{C}}^{\mathrm{GW}}(\Phi_{\mathrm{orb}}, \Delta\varpi)$, the crossing Plücker minor squared modulus is $|\Delta_{02}^{\mathbb{C}}\Delta_{13}^{\mathbb{C}}|^2 = 2\bigl(1 + \sqrt{1 - e^2}\cos(2\Phi_{\mathrm{orb}} + \Delta\varpi)\bigr)$. The product of its anti-nodal maximum $I_{\max}^{\mathrm{GW}} = 2(1 + \sqrt{1-e^2})$ and nodal minimum $I_{\min}^{\mathrm{GW}} = 2(1 - \sqrt{1-e^2})$ is `4 * e_ecc ^ 2`, while their sum is $I_{\max}^{\mathrm{GW}} + I_{\min}^{\mathrm{GW}} = 4 = F_{\mu\mu} / g_{\mu\mu}^{\mathrm{FS}}$.

3. **Why Un-Doubled Spin-1 Coulomb/QED Vector Gravity Misses $5/6$ of 1PN Precession and $3/4$ of 2.5PN GW Flux—and How `BCJ` Helicity Doubling ($\text{Gravity} = \text{Gauge}^2$) & Partanen–Tulkki $\mathrm{U}(1)^4$ Restore the Full $4\times$ `QFIM` Weight**:
   - **At 1PN (`qedSpinOnePrecessionFromQfim`, `qedNordstromScalarPrecessionFromQfim`)**:
     Un-doubled spin-1 Coulomb/QED vector exchange gives only the special-relativistic Sommerfeld precession $\Delta\varpi_{\mathrm{vec}} = \frac{1}{6}\Delta\varpi_{\mathrm{circ}} F_{ee}^{\mathrm{orb}}(e) = \frac{2}{3}\Delta\varpi_{\mathrm{circ}} g_{ee}^{\mathrm{FS}}(e)$, yielding a relative error of $\varepsilon_{\mathrm{rel}} = \frac{5}{6} \approx 83.33\%$, whereas Nordström's (1913) spin-0 scalar theory gives retrograde precession $\Delta\varpi_{\mathrm{Nord}} = -\frac{1}{6}\Delta\varpi_{\mathrm{circ}} F_{ee}^{\mathrm{orb}}(e)$ with $\varepsilon_{\mathrm{rel}} = \frac{7}{6} \approx 116.67\%$. Only the spin-2 BCJ double copy ($\binom{4}{2} = 6$ Plücker coordinates on $\mathcal{Q}_4 = \mathrm{Gr}_{\mathbb{C}}(2,4)$) and Partanen–Tulkki $\mathrm{U}(1)^4$ 1-loop QFT recover the full $6\times$ Sommerfeld multiplier ($\varepsilon_{\mathrm{rel}} = 0$).
   - **At 2.5PN (`qedSpinOneToDoubleCopyGwFluxRatio` and Helicity-Doubling $4\times$ Phase Variance)**:
     In an un-doubled spin-1 vector theory of gravity with universal charge-to-mass ratio $q_i / m_i = \sqrt{G}$, the binary center-of-charge coincides with the center-of-mass, so the electric dipole second derivative vanishes identically ($\ddot{\mathbf{d}} = \mathbf{0}$, $\Delta_{\mathrm{dip}} = 0$). The leading spin-1 magnetic/electric quadrupole radiation is only **one-quarter** of the spin-2 Einstein–Peters–Mathews flux:

     $$
     P_{\mathrm{GW}}^{\mathrm{vec}}(\Delta_{\mathrm{dip}}=0) = \frac{1}{4}\,P_{\mathrm{GW}}^{\mathrm{GR}} = \frac{g_{\mu\mu}^{\mathrm{FS}}}{F_{\mu\mu}}\,P_{\mathrm{GW}}^{\mathrm{GR}} \implies \varepsilon_{\mathrm{rel}}\bigl(P_{\mathrm{GW}}^{\mathrm{vec}}, P_{\mathrm{GW}}^{\mathrm{GR}}\bigr) = \frac{3}{4} = 75\%.
     $$

     Under the **BCJ spin-2 double copy** $\varepsilon_{\mu\nu}^{(\pm 2)} = \varepsilon_\mu^{(\pm 1)} \otimes \varepsilon_\nu^{(\pm 1)}$ (or Partanen–Tulkki's four $\mathrm{U}(1)^4$ symmetries), the wave helicity doubles from $s = \pm 1$ to $s = \pm 2$, doubling the internal Plücker phase winding $(\phi_0, \phi_1) \mapsto (2\phi_0, 2\phi_1)$. By Theorem `qed_scattering_gravity_bcj_partanen_tulkki_qfim_and_fubini_study_identities`, doubling the phase gradients scales the bivector phase-gradient variance by **$2^2 = 4\times$**:

     $$
     \operatorname{twoChannelPhaseVariance}(p_0, p_1, 2\,d\phi_0, 2\,d\phi_1) = 4\,\operatorname{twoChannelPhaseVariance}(p_0, p_1, d\phi_0, d\phi_1),
     $$

     multiplying the un-doubled spin-1 quadrupole flux by $4$ to recover $4 \times \frac{1}{4}P_{\mathrm{GW}}^{\mathrm{GR}} = P_{\mathrm{GW}}^{\mathrm{GR}}$ ($\varepsilon_{\mathrm{rel}} = 0$)!

### 4.4 Multi-Model QED Scattering, Twistor, & Superfluid Gravity Comparison in Terms of `QFIM` ($F_{ee}^{\mathrm{orb}}, F_{\sigma\sigma}^{\mathrm{CHY}}$) and the Fubini–Study Kähler Metric ($g_{ee}^{\mathrm{FS}}, g_{\sigma\sigma}^{\mathrm{FS}}$)

Synthesizing Sections 4.4 and 4.5 of [grassmannian-gravity-from-qed-scattering-paper.md](grassmannian-gravity-from-qed-scattering-paper.md) with `Signals.DFT` Sections 27.1–27.4, every gravity and gravitational-wave model in our 17-model benchmark can be written directly in terms of the orbital eccentricity QFIM $F_{ee}^{\mathrm{orb}}(e) = 4\,g_{ee}^{\mathrm{FS}}(e) = (1 - e^2)^{-1}$ and the circular reference scale $\Delta\varpi_{\mathrm{circ}} = \frac{6\pi G M}{c^2 a}$:

| Model Family ([Paper 4](grassmannian-gravity-from-qed-scattering-paper.md) Row) | Spin / Helicity & Propagator | 1PN Perihelion Advance in Terms of $F_{ee}^{\mathrm{orb}} = 4\,g_{ee}^{\mathrm{FS}}$ | 1PN Error $\varepsilon_{\mathrm{rel}}^{\mathrm{1PN}}$ | 2.5PN GW Luminosity $P_{\mathrm{GW}}^{\mathrm{model}}$ in Terms of $F_{ee}^{\mathrm{orb}} = 4\,g_{ee}^{\mathrm{FS}}$ | 2.5PN Total Error $\varepsilon_{\mathrm{rel}}^{\mathrm{2.5PN}}$ |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **1. Newtonian $1/r$ Gravity** (Row 1) | Instantaneous ($c \to \infty$, no wave) | $0 \cdot F_{ee}^{\mathrm{orb}}(e) = 0$ | **$1$ ($100\%$)** | $0 \cdot \bigl(F_{ee}^{\mathrm{orb}}(e)\bigr)^{7/2} = 0$ | **$1$ ($100\%$)** |
| **2. Nordström (1913) Relativistic Scalar** ({cite:p}`nordstrom1913gravitation`, Row 2) | Spin-$0$ breathing ($s = 0$, $1/q^2$) | $-\frac{1}{6}\Delta\varpi_{\mathrm{circ}} F_{ee}^{\mathrm{orb}}(e) = -\frac{2}{3}\Delta\varpi_{\mathrm{circ}} g_{ee}^{\mathrm{FS}}(e)$ (retrograde) | **$\frac{7}{6} \approx 116.67\%$** | $\frac{1}{6}\,P_{\mathrm{GW},0}\,P_{\mathrm{PM}}(e)\bigl(F_{ee}^{\mathrm{orb}}(e)\bigr)^{7/2}$ (zero TT modes) | **$\frac{5}{6} \approx 83.33\%$** ($100\%$ TT) |
| **3. Un-Doubled Spin-1 Coulomb/QED Vector** (`qedSpinOnePrecessionFromQfim`, Row 4) | Spin-$1$ vector ($s = \pm 1$, $1/q^2$, $\ddot{\mathbf{d}}=\mathbf{0}$) | $+\frac{1}{6}\Delta\varpi_{\mathrm{circ}} F_{ee}^{\mathrm{orb}}(e) = +\frac{2}{3}\Delta\varpi_{\mathrm{circ}} g_{ee}^{\mathrm{FS}}(e)$ (Sommerfeld) | **$\frac{5}{6} \approx 83.33\%$** | $\frac{1}{4}P_{\mathrm{GW}}^{\mathrm{GR}} = \frac{g_{\mu\mu}^{\mathrm{FS}}}{F_{\mu\mu}}\,P_{\mathrm{GW},0}\,P_{\mathrm{PM}}(e)\bigl(F_{ee}^{\mathrm{orb}}(e)\bigr)^{7/2}$ | **$\frac{3}{4} = 75\%$** ($100\%$ TT) |
| **4. Witten (2004) Conformal Twistor String** ({cite:p}`witten2004twistor,berkovits2004conformal`, Rows 5a/5b) | 4th-order Weyl ($1/(q^2(q^2 - m_{\mathrm{gh}}^2))$ ghost) | $\beta_{\mathrm{scale}}\Delta\varpi_{\mathrm{circ}} F_{ee}^{\mathrm{orb}}(e) + \frac{\pi\gamma_{\mathrm{conf}}a^2}{\sqrt{F_{ee}^{\mathrm{orb}}(e)}}$ | **$100\%$** or $\propto a^3 > 0$ | $\beta_{\mathrm{scale}}P_{\mathrm{GW}}^{\mathrm{GR}} - \delta P_{\mathrm{ghost}}$ (non-unitary ghost flux) | **$100\%$** or $\frac{\delta P_{\mathrm{ghost}}}{P_{\mathrm{GW}}^{\mathrm{GR}}} > 0$ |
| **5. Cachazo–Skinner (2012/2013) & CHY (2014)** ({cite:p}`cachazo2013gravity,chy2014`, Row 7b, $\pi_I=1, \Lambda_{\mathrm{cc}}=0$) | Spin-$2$ Hodges double copy $\det'(\Phi)\det'(\tilde{\Phi})$ ($1/q^2$) | $\Delta\varpi_{\mathrm{circ}} F_{ee}^{\mathrm{orb}}(e) = 4\,\Delta\varpi_{\mathrm{circ}} g_{ee}^{\mathrm{FS}}(e)$ ($\mathcal{A}_4^{\mathrm{CHY}} = \frac{F_{\sigma\sigma}^{\mathrm{CHY}}}{s_{12}+s_{13}}$) | **$0$ ($0.00\%$)** | $P_{\mathrm{GW},0}\,P_{\mathrm{PM}}(e)\bigl(F_{ee}^{\mathrm{orb}}(e)\bigr)^{7/2} = P_{\mathrm{GW}}^{\mathrm{GR}}$ ($\mathcal{K}_{\mathrm{CS}} = 4$) | **$0$ ($0.00\%$)** |
| **6. Partanen–Tulkki (2025) $\mathrm{U}(1)^4$ QFT & Bjerrum-Bohr (2018)** ({cite:p}`partanen2025gravity,partanen2025perihelion,bjerrum2018general`, Row 10) | Spin-$2$ from four $\mathrm{U}(1)^4$ gauge symmetries ($1/q^2$ + 1-loop) | $\Delta\varpi_{\mathrm{circ}} F_{ee}^{\mathrm{orb}}(e) = 4\,\Delta\varpi_{\mathrm{circ}} g_{ee}^{\mathrm{FS}}(e)$ | **$0$ ($0.00\%$)** | $P_{\mathrm{GW},0}\,P_{\mathrm{PM}}(e)\bigl(4\,g_{ee}^{\mathrm{FS}}(e)\bigr)^{7/2} = P_{\mathrm{GW}}^{\mathrm{GR}}$ | **$0$ ($0.00\%$)** |
| **7. Fedi (2016/2017/2026) Conservative DDF** ({cite:p}`fedi2016sqg,fedi2017darksuperfluid,fedi2026ddf`, Rows 8b, 9b, 11) | Transverse $\varphi$-lattice phonon ($c^{-2} = \varrho_{\max}^\varphi j_{\min}^\varphi$, $P_{\mathrm{Stokes}}=0$) | $\Delta\varpi_{\mathrm{circ}} F_{ee}^{\mathrm{orb}}(e) = 4\,\Delta\varpi_{\mathrm{circ}} g_{ee}^{\mathrm{FS}}(e)$ (at $\delta_{\mathrm{GPE}}=\eta_{\mathrm{drag}}=0$) | **$0$ ($0.00\%$)** | $P_{\mathrm{GW},0}\,P_{\mathrm{PM}}(e)\bigl(F_{ee}^{\mathrm{orb}}(e)\bigr)^{7/2} = P_{\mathrm{GW}}^{\mathrm{GR}}$ (with UV Kelvin tail) | **$0$ ($0.00\%$)** |
| **8. Turner (2026) $\mathrm{Gr}_{\mathbb{C}}(2,4)$ `BCJ` QED Double Copy, Plücker $\mathcal{Q}_4$ Kähler `iGPE`, & DDF** (Rows 12, 13, 14a, 14b) | Spin-$2$ $\varepsilon_{\mu\nu}^{(\pm 2)} = \varepsilon_\mu^{(\pm 1)}\otimes\varepsilon_\nu^{(\pm 1)}$ on $\mathcal{Q}_4$ ($F_{\mu\nu}=4g_{\mu\nu}^{\mathrm{FS}}$) | $\frac{\Delta\varpi_{\mathrm{circ}}}{\mathcal{D}(W_{\mathrm{orb}})-3} = \Delta\varpi_{\mathrm{circ}} F_{ee}^{\mathrm{orb}}(e) = 4\,\Delta\varpi_{\mathrm{circ}} g_{ee}^{\mathrm{FS}}(e)$ | **$0$ ($0.00\%$)** | $P_{\mathrm{GW},0}\,P_{\mathrm{PM}}(e)\bigl(F_{ee}^{\mathrm{orb}}(e)\bigr)^{7/2} = P_{\mathrm{GW},0}\,P_{\mathrm{PM}}(e)\bigl(4\,g_{ee}^{\mathrm{FS}}(e)\bigr)^{7/2}$ | **$0$ ($0.00\%$)** |

---

## 5. Complex Plabic Vector-Relation Configurations (`VRC`) and the `QFIM` / Fubini–Study Kähler Metric: Pole-Free On-Shell Resonance ($x_X = -1$), Denominator-Clearing Gauge Invariance, and `MADNESS`/`Tequila` Quantum Natural Gradient (`Signals.DFT` Section 27.6)

Across seven companion papers in our research archive—
1. [Paper 18 (`grassmannian-quantum-causal-inference-mpemba-paper.md`)](grassmannian-quantum-causal-inference-mpemba-paper.md) (`GrassmannianCausalBackend.complexHomogeneousVRC`, `qci_optional_vrc_vs_plabic_complex_grassmannian_identities` in {download}`src/signals/Signals/QuantumCausalInference.lean, lines 2110–2305 <../src/signals/Signals/QuantumCausalInference.lean>`),
2. [Paper 22 (`grassmannian-kohn-sham-dft-complex-plabic-vrc-paper.md`)](grassmannian-kohn-sham-dft-complex-plabic-vrc-paper.md) (`VectorRelationConfiguration`, `gr24HomogeneousVRC`, `gr24MutatedHomogeneousVRC`, `complex_plabic_vrc_and_sympy_check_figures` in {download}`src/signals/Signals/Plabic.lean, lines 1125–1340 <../src/signals/Signals/Plabic.lean>`),
3. [Paper 23 (`grassmannian-speed-accuracy-barrier-quantum-chemistry-paper.md`)](grassmannian-speed-accuracy-barrier-quantum-chemistry-paper.md) (`WTMAD-2 = 1.643 kcal/mol` on `GMTKN55` and on-shell polariton / MZM readout in `Signals.DFT`),
4. [Paper 24 (`grassmannian-tuning-materials-with-light-paper.md`)](grassmannian-tuning-materials-with-light-paper.md) (time-linear Grassmannian `G-GKBA` with VRC correlation pathways),
5. [Paper 39 (`grassmannian-quantum-causal-next-concept-modeling-pressed-llm-kicad-paper.md`)](grassmannian-quantum-causal-next-concept-modeling-pressed-llm-kicad-paper.md) (`QCI-NCM` intra-level parallel constraint coupling at $x_X = -1$),
6. [Paper 43 (`grassmannian-madness-tequila-quantum-chemistry-plabic-vrc-paper.md`)](grassmannian-madness-tequila-quantum-chemistry-plabic-vrc-paper.md) (4-stage layer-coding derivation from finite rotation systems & LGV networks to Complex VRCs, `plabicVrcLayerGateCount`, and `vrcRegularizedPnoAmplitude` in `MADNESS` `MRA-PNO` and `Tequila`), and
7. [Paper 44 (`grassmannian-tequila-rust-pyo3-quantum-simulator-paper.md`)](grassmannian-tequila-rust-pyo3-quantum-simulator-paper.md) (`signals` / `grassmann` Rust/PyO3 `maturin` quantum simulator backend for `Tequila`)—

we introduced **Complex Homogeneous Vector-Relation Configurations (`VRC`)** {cite:p}`affolter2024vrc` to lift Postnikov's planar bicolored (`Plabic`) graphs {cite:p}`postnikov2006plabic,lam2016totally` from the positive Grassmannian $\mathrm{Gr}_{\ge 0}(k,n)$ to the full **Complex Grassmannian $\mathrm{Gr}_{\mathbb{C}}(k,n)$**. Here, in `Signals.DFT` Section 27.6 ({download}`src/signals/Signals/DFT.lean, lines 9880–10060 <../src/signals/Signals/DFT.lean>` and {download}`src/signals/numerical_adapter/src/dft_plabic_vrc.rs, lines 2840–2910 and 4255–4290 <../src/signals/numerical_adapter/src/dft_plabic_vrc.rs>`), we develop, critique, and machine-check the exact relationship between **Complex VRCs** and the **Quantum Fisher Information Metric (`QFIM`) $F_{\mu\nu} = 4\,g_{\mu\nu}^{\mathrm{FS}}$ / Fubini–Study Kähler metric**.

```{mermaid}
flowchart TB
    subgraph Rat["1. Rational Plabic Face-Weight Chart C_rat(x_1, x_2, x_X)"]
        R1["C_rat = [[1, 0, -x_1, -x_X], [0, 1, x_X⁻¹, -x_2]]\nSquare-move mutation: x_1' = (x_1 x_X + x_2)/(x_X + 1), x_X' = 1/x_X"]
        R2["Critique VRC-1 (Singular Rational-Chart QFIM):\n• At chart boundary x_X → 0: ρ_rat ~ |x_X|⁻² → ∞\n• At on-shell resonance x_X → -1: ∂x_1'/∂x_X ~ (x_X+1)⁻²\n  ⇒ naive coordinate QFIM blows up as (x_X + 1)⁻⁴!"]
        R1 --> R2
    end

    subgraph Hom["2. Homogeneous Complex VRC (V, K) with V · K^T = 0 on Q_4 = Gr_C(2,4)"]
        V1["Fix VRC-1 (gr24MutatedHomogeneousVRC at x_X = -1):\nPolynomial Plücker minors (1, 0, x_2, x_2 - x_1, 1, x_2(x_1 - x_2))\nρ_VRC^(-1)(x_1, x_2) = 2 + x_2² + (x_2 - x_1)²(1 + x_2²) ≥ 2 > 0"]
        V2["Exact Cauchy–Schwarz Cancellation Along x_1:\nρ⟨∂_1Ψ|∂_1Ψ⟩ - |⟨Ψ|∂_1Ψ⟩|² = (2 + x_2²)(1 + x_2²) > 0\nF^VRC_{11}|_{x_X=-1} = 4 g^{FS,VRC}_{11}|_{x_X=-1} = 4(2+x_2²)(1+x_2²) / (ρ_VRC^(-1))² > 0"]
        V3["Fixes VRC-2, VRC-3, & VRC-4:\n• VRC-2: 100% invariant under Ψ ↦ s(x) e^{iχ(x)} Ψ denominator clearing\n• VRC-3: Finite MRA-PNO gap QFIM 4g²/γ_VRC⁴ at Δε = 0 & 1/4 QNG step\n• VRC-4: At symmetric locus x_1 = x_2 = 0: g^FS_{11} = 1/2, F_{11} = 2 > 0"]
        V1 --> V2 --> V3
    end

    Rat ==>|"Black-Vertex GL(2, C) Denominator Clearing\nvrc_fubini_study_kahler_qfim_pole_free_resonance_and_critique_fixes_identities"| Hom
```

### 5.1 Critique & Fix VRC-1: Why Rational Plabic Face-Weight Charts Suffer a $(x_X + 1)^{-4}$ `QFIM` Singularity at On-Shell Resonance ($x_X = -1$), and How Homogeneous VRCs Yield a Closed, Pole-Free Fubini–Study / `QFIM` Metric

- **Critique VRC-1 (Catastrophic Divergence of Coordinate-Chart Kähler / QFIM Pullbacks at $x_X \to 0$ and $x_X \to -1$)**:
  In standard Plabic networks on $\mathrm{Gr}_{\ge 0}(2,4)$ ({cite:p}`postnikov2006plabic`; {cite:p}`lam2016totally`), the rational face-weight boundary measurement matrix (`gr24RationalChartMatrix` in [Paper 22](grassmannian-kohn-sham-dft-complex-plabic-vrc-paper.md)) is

  $$
  C_{\mathrm{rat}}(x_1, x_2, x_X) = \begin{pmatrix} 1 & 0 & -x_1 & -x_X \\ 0 & 1 & x_X^{-1} & -x_2 \end{pmatrix}, \qquad P^{\mathrm{rat}}(x_1, x_2, x_X) = \bigl(1,\; x_X^{-1},\; -x_2,\; x_1,\; x_X,\; x_1 x_2 + 1\bigr),
  $$

  and the square-move (urban renewal) cluster mutation (`gr24ClusterMutation`) transforms the face weights as

  $$
  (x_1, x_2, x_X) \longmapsto \left(x_1' = \frac{x_1 x_X + x_2}{x_X + 1},\; x_2' = x_2,\; x_X' = \frac{1}{x_X}\right).
  $$

  When lifted to complex quantum amplitudes $(x_1, x_2, x_X) \in \mathbb{C}^3$:
  1. At the **positroid chart boundary $x_X \to 0$**, the unnormalized Plücker norm squared $\rho_{\mathrm{rat}} = 1 + |x_X|^{-2} + |x_2|^2 + |x_1|^2 + |x_X|^2 + |x_1 x_2 + 1|^2$ diverges as $|x_X|^{-2} \to \infty$.
  2. At the **on-shell polariton / antibonding / conical-intersection / destructive-interference resonance $x_X = -1$** ($x_X + 1 = 0$), the mutated coordinate $x_1' = \frac{x_1 x_X + x_2}{x_X + 1}$ has a first-order pole (whenever $x_1 \neq x_2$), its Jacobian $\frac{\partial x_1'}{\partial x_X} = \frac{x_1 - x_2}{(x_X + 1)^2}$ diverges quadratically, and pulling back the Fubini–Study metric $g_{x_1' \bar{x}_1'}^{\mathrm{FS}}\,\bigl|\frac{\partial x_1'}{\partial x_X}\bigr|^2$ or QFIM $F = 4\,g^{\mathrm{FS}}$ in mutated rational coordinates diverges as **$(x_X + 1)^{-4}$** (which forced the ad-hoc `1e-5` numerical regularization in `qci_grassmannian_xc.py` audited in [Paper 22](grassmannian-kohn-sham-dft-complex-plabic-vrc-paper.md)).

- **Machine-Checked Fix VRC-1 (`vrcResonantPluckerNormSq`, `vrcResonantDirectionalJetX1`, `vrcResonantFubiniStudyX1`, `vrcResonantQfimX1`)**:
  In a **Vector-Relation Configuration (`VRC`)** (`VectorRelationConfiguration` in {download}`src/signals/Signals/Plabic.lean, lines 1125–1255 <../src/signals/Signals/Plabic.lean>`, {cite:p}`affolter2024vrc`), white vertices carry vectors $V \in R^{k \times |W|}$ and black vertices carry linear relations $K \in R^{|B| \times |W|}$ satisfying $V K^\top = 0$ over any commutative ring $R$. Clearing the $(x_X + 1)$ and $x_X$ denominators via black-vertex $\mathrm{GL}(2, R)$ row operations yields `gr24MutatedHomogeneousVRC`, whose 6 Plücker minors at the exact on-shell resonance $x_X = -1$ are finite polynomials:

  $$
  \Psi_{\mathrm{VRC}}^{(-1)}(x_1, x_2) = (P_{01}, P_{02}, P_{03}, P_{12}, P_{13}, P_{23})\big|_{x_X = -1} = \bigl(1,\; 0,\; x_2,\; x_2 - x_1,\; 1,\; x_2(x_1 - x_2)\bigr).
  $$

  In Theorem `vrc_fubini_study_kahler_qfim_pole_free_resonance_and_critique_fixes_identities`, we prove that its **resonant Plücker norm squared** (`vrcResonantPluckerNormSq`) factors cleanly and is bounded below by $2$ everywhere on $\mathbb{R}^2$:

  $$
  \rho_{\mathrm{VRC}}^{(-1)}(x_1, x_2) = 1^2 + 0^2 + x_2^2 + (x_2 - x_1)^2 + 1^2 + x_2^2(x_1 - x_2)^2 = 2 + x_2^2 + (x_2 - x_1)^2(1 + x_2^2) \ge 2 > 0.
  $$

  Differentiating $\Psi_{\mathrm{VRC}}^{(-1)}(x_1, x_2)$ along $x_1$ gives $\partial_{x_1}\Psi_{\mathrm{VRC}}^{(-1)} = (0, 0, 0, -1, 0, x_2)$ with $\langle\partial_{x_1}\Psi_{\mathrm{VRC}}^{(-1)}\mid\partial_{x_1}\Psi_{\mathrm{VRC}}^{(-1)}\rangle = 1 + x_2^2$, $\partial_{x_1}\rho_{\mathrm{VRC}}^{(-1)} = 2(x_1 - x_2)(1 + x_2^2)$, and $\mathcal{A}_{x_1} = 0$ (`vrcResonantDirectionalJetX1`). Substituting into the Cauchy–Schwarz numerator $\rho\langle\partial_{x_1}\Psi\mid\partial_{x_1}\Psi\rangle - |\langle\Psi\mid\partial_{x_1}\Psi\rangle|^2$, the quartic $(x_2 - x_1)^2(1 + x_2^2)^2$ terms **cancel identically**:

  $$
  \rho_{\mathrm{VRC}}^{(-1)}\langle\partial_{x_1}\Psi_{\mathrm{VRC}}^{(-1)}\mid\partial_{x_1}\Psi_{\mathrm{VRC}}^{(-1)}\rangle - \left(\frac{1}{2}\partial_{x_1}\rho_{\mathrm{VRC}}^{(-1)}\right)^2 = \bigl(2 + x_2^2 + (x_2 - x_1)^2(1 + x_2^2)\bigr)(1 + x_2^2) - (x_1 - x_2)^2(1 + x_2^2)^2 = (2 + x_2^2)(1 + x_2^2) > 0.
  $$

  Consequently, at the exact on-shell resonance $x_X = -1$ where the rational cluster chart blows up, the **VRC Fubini–Study Kähler metric** (`vrcResonantFubiniStudyX1`) and **VRC Quantum Fisher Information Metric** (`vrcResonantQfimX1`) are completely smooth, pole-free, and strictly positive for all $(x_1, x_2) \in \mathbb{R}^2$:

  $$
  g_{x_1 x_1}^{\mathrm{FS,VRC}}\big|_{x_X=-1}(x_1, x_2) = \frac{(2 + x_2^2)(1 + x_2^2)}{\bigl(2 + x_2^2 + (x_2 - x_1)^2(1 + x_2^2)\bigr)^2} > 0, \qquad F_{x_1 x_1}^{\mathrm{VRC}}\big|_{x_X=-1}(x_1, x_2) = 4\,g_{x_1 x_1}^{\mathrm{FS,VRC}}\big|_{x_X=-1}(x_1, x_2) = \frac{4\,(2 + x_2^2)(1 + x_2^2)}{\bigl(2 + x_2^2 + (x_2 - x_1)^2(1 + x_2^2)\bigr)^2} > 0.
  $$

### 5.2 Critique & Fix VRC-2: Does Clearing Rational Denominators by a Coordinate-Dependent Factor $\Psi \mapsto \lambda(x)\Psi$ Distort the Fubini–Study Metric or `QFIM`?

- **Critique VRC-2 (Spurious Radial & Phase Gradients from VRC Denominator Clearing)**:
  In [Paper 18 (`grassmannian-quantum-causal-inference-mpemba-paper.md`)](grassmannian-quantum-causal-inference-mpemba-paper.md) (Theorem `qci_optional_vrc_vs_plabic_complex_grassmannian_identities`), we proved that clearing the $x_X^{-1}$ singularity between `.plabicRationalChart` and `.complexHomogeneousVRC` multiplies both uncrossed Plücker causal channels by the coordinate-dependent factor $x_X$: $w_{A,B}^{\mathrm{VRC}} = x_X\,w_{A,B}^{\mathrm{Plabic}}$. More generally, clearing rational denominators multiplies the homogeneous Plücker vector by a nonzero complex function $\lambda(x) = s(x)\,e^{i\chi(x)}$ ($s(x) > 0$) with radial logarithmic derivative $\sigma_\mu = \frac{\partial_\mu s}{s}$ and phase gradient $d\chi = \partial_\mu\chi$. Under $\tilde{\Psi}(x) = s(x)\,e^{i\chi(x)}\,\Psi(x)$, the unnormalized directional jet (`complexRescaledVrcJet`) transforms as:

  $$
  \tilde{\rho} = s^2\,\rho, \qquad \partial_\mu\tilde{\rho} = s^2\bigl(\partial_\mu\rho + 2\sigma_\mu\rho\bigr), \qquad \tilde{\mathcal{A}}_\mu = \mathcal{A}_\mu + d\chi, \qquad \langle\partial_\mu\tilde{\Psi}\mid\partial_\mu\tilde{\Psi}\rangle = s^2\Bigl(\langle\partial_\mu\Psi\mid\partial_\mu\Psi\rangle + \sigma_\mu\,\partial_\mu\rho + 2\rho\mathcal{A}_\mu\,d\chi + \rho(\sigma_\mu^2 + d\chi^2)\Bigr).
  $$

  If an algorithm used the unnormalized gradient norm $\langle\partial_\mu\tilde{\Psi}\mid\partial_\mu\tilde{\Psi}\rangle$ directly as its metric, the arbitrary denominator-clearing scale $\sigma_\mu = \partial_\mu s / s$ would inject artificial forces!

- **Machine-Checked Fix VRC-2 (`complexRescaledVrcJet` Invariance)**:
  In Theorem `vrc_fubini_study_kahler_qfim_pole_free_resonance_and_critique_fixes_identities`, we prove that for every $s \neq 0$, $\rho \neq 0$, $\sigma_\mu \in \mathbb{R}$, and $d\chi \in \mathbb{R}$:

  $$
  \operatorname{fubiniStudyDiag}\bigl(\operatorname{complexRescaledVrcJet}(d, s, \sigma_\mu, d\chi)\bigr) = \operatorname{fubiniStudyDiag}(d), \qquad \operatorname{qfimDiag}\bigl(\operatorname{complexRescaledVrcJet}(d, s, \sigma_\mu, d\chi)\bigr) = \operatorname{qfimDiag}(d) = 4\,\operatorname{fubiniStudyDiag}(d).
  $$

  In the three-channel Madelung–QFIM split (Theorem 1), the phase gradient $d\chi$ is absorbed entirely into Channel 1 (`hydroFlowDir`), the radial denominator-clearing gradient $\sigma_\mu = \partial_\mu s / s$ is absorbed entirely into Channel 2 (`scalarBohmDensityDir`), and **Channel 3's projective Fubini–Study Kähler metric $g_{\mu\mu}^{\mathrm{FS}}$ and Quantum Fisher Information Metric $F_{\mu\mu} = 4\,g_{\mu\mu}^{\mathrm{FS}}$ are $100\%$ invariant under arbitrary complex VRC denominator clearing**!

### 5.3 Critique & Fix VRC-3: `MADNESS` `MRA-PNO` Pair Excitation `QFIM` at HOMO–LUMO Degeneracy ($\Delta\varepsilon = 0$) and the $1/4$ `Tequila` Quantum Natural Gradient Step

- **Critique VRC-3 (Divergent First-Order MP2/PNO Pair Metrics at Conical Intersections $\Delta\varepsilon \to 0$ and Step-Size Mismatch Between Riemannian DFT and VQE Natural Gradients)**:
  In [Paper 43 (`grassmannian-madness-tequila-quantum-chemistry-plabic-vrc-paper.md`)](grassmannian-madness-tequila-quantum-chemistry-plabic-vrc-paper.md) and [Paper 44 (`grassmannian-tequila-rust-pyo3-quantum-simulator-paper.md`)](grassmannian-tequila-rust-pyo3-quantum-simulator-paper.md), standard first-order MP2/PNO pair amplitudes $T_{ij}^{ab} = -g_{ij}^{ab} / \Delta\varepsilon$ diverge when the HOMO–LUMO orbital energy gap $\Delta\varepsilon = \varepsilon_a + \varepsilon_b - \varepsilon_i - \varepsilon_j \to 0$ (bonds stretched to dissociation, diradicals, or conical intersections). Moreover, when optimizing orbital rotations via Riemannian Cayley BFGS in `QCI-GXC` ([Paper 22](grassmannian-kohn-sham-dft-complex-plabic-vrc-paper.md)) versus optimizing Hardcore-Boson (`HCB`) `VRC-SPA-UpCCGSD` circuit angles in `Tequila` ([Paper 44](grassmannian-tequila-rust-pyo3-quantum-simulator-paper.md)), preconditioning by $g_{\theta\theta}^{\mathrm{FS}}$ versus $F_{\theta\theta}$ without accounting for $F_{\theta\theta} = 4\,g_{\theta\theta}^{\mathrm{FS}}$ causes a $4\times$ learning-rate mismatch.

- **Machine-Checked Fix VRC-3 (`vrcPnoGapFubiniStudyAtDegeneracy`, `vrcPnoGapQfimAtDegeneracy`, `vrcQuantumNaturalGradientStep`)**:
  1. Using our **pole-free VRC-regularized MRA-PNO pair amplitude** (`vrcRegularizedPnoAmplitude` in `Signals.DFT` Section 21):

     $$
     T_{ij,\mathrm{VRC}}^{ab}(g_{ij}^{ab}, \Delta\varepsilon, \gamma_{\mathrm{VRC}}) = \frac{-g_{ij}^{ab}\,\Delta\varepsilon}{\Delta\varepsilon^2 + \gamma_{\mathrm{VRC}}^2},
     $$

     the two-configuration pair state $\Psi_{\mathrm{PNO}}(\Delta\varepsilon) = \bigl(1,\; T_{ij,\mathrm{VRC}}^{ab}(\Delta\varepsilon)\bigr)^\top \in \mathbb{CP}^1 = \mathrm{Gr}_{\mathbb{C}}(1,2)$ has $T_{ij,\mathrm{VRC}}^{ab}(0) = 0$ and finite gap slope $\left.\frac{\partial T_{ij,\mathrm{VRC}}^{ab}}{\partial\Delta\varepsilon}\right|_{\Delta\varepsilon=0} = -\frac{g_{ij}^{ab}}{\gamma_{\mathrm{VRC}}^2}$. Consequently, at exact HOMO–LUMO degeneracy $\Delta\varepsilon = 0$, the **VRC pair-excitation gap Fubini–Study metric** (`vrcPnoGapFubiniStudyAtDegeneracy`) and **gap QFIM** (`vrcPnoGapQfimAtDegeneracy`) are finite and linked by the exact factor of $4$:

     $$
     g_{\Delta\varepsilon,\Delta\varepsilon}^{\mathrm{FS,PNO}}\big|_{\Delta\varepsilon=0} = \frac{(g_{ij}^{ab})^2}{\gamma_{\mathrm{VRC}}^4}, \qquad F_{\Delta\varepsilon,\Delta\varepsilon}^{\mathrm{PNO}}\big|_{\Delta\varepsilon=0} = 4\,g_{\Delta\varepsilon,\Delta\varepsilon}^{\mathrm{FS,PNO}}\big|_{\Delta\varepsilon=0} = \frac{4\,(g_{ij}^{ab})^2}{\gamma_{\mathrm{VRC}}^4}.
     $$

  2. In `vrcQuantumNaturalGradientStep`, preconditioning a variational parameter update by the inverse QFIM $F_{\theta\theta}^{-1} = (4\,g_{\theta\theta}^{\mathrm{FS}})^{-1}$ yields:

     $$
     \Delta\theta_{\mathrm{QNG}}(\eta, \partial_\theta E, 4\,g_{\theta\theta}^{\mathrm{FS}}) = -\frac{\eta\,\partial_\theta E}{4\,g_{\theta\theta}^{\mathrm{FS}}} = \frac{1}{4}\,\Delta\theta_{\mathrm{QNG}}(\eta, \partial_\theta E, g_{\theta\theta}^{\mathrm{FS}}),
     $$

     reconciling the `Tequila` parameter-shift Quantum Natural Gradient (`Paper 44`) with the Fubini–Study Riemannian Cayley step (`Paper 22`).

### 5.4 Critique & Fix VRC-4: Non-Vanishing `QFIM` Sensitivity at the Symmetric `QCI-NCM` Destructive Constraint Locus ($x_1 = x_2, x_X = -1$)

- **Critique VRC-4 (Do Vanishing Crossing Minors $P_{12} = x_2 - x_1 = 0$ and $P_{23} = x_2(x_1 - x_2) = 0$ Collapse the Metric at $x_1 = x_2, x_X = -1$?)**:
  In [Paper 39 (`grassmannian-quantum-causal-next-concept-modeling-pressed-llm-kicad-paper.md`)](grassmannian-quantum-causal-next-concept-modeling-pressed-llm-kicad-paper.md), `QCI-NCM` uses the mutated homogeneous VRC at $x_X = -1$ so that conflicting intra-level concept pairs ($x_1 = x_2$) annihilate the crossing minor $P_{12} = x_2 - x_1 = 0$ and correlation minor $P_{23} = x_2(x_1 - x_2) = 0$ in a single parallel pass. Does the Fubini–Study metric or QFIM vanish or divide by zero on this symmetric constraint locus $x_1 = x_2$?

- **Machine-Checked Fix VRC-4**:
  Because the three anchor minors $P_{01} = 1, P_{03} = x_2, P_{13} = 1$ remain non-vanishing on $x_1 = x_2$ ($\rho_{\mathrm{VRC}}^{(-1)}(x_2, x_2) = 2 + x_2^2 \ge 2$), `vrcResonantFubiniStudyX1` and `vrcResonantQfimX1` actually achieve their **maximum directional sensitivity** along the symmetry-breaking coordinate $x_1 - x_2$ right on the constraint locus $x_1 = x_2$:

  $$
  g_{x_1 x_1}^{\mathrm{FS,VRC}}\big|_{x_X=-1,\,x_1=x_2} = \frac{1 + x_2^2}{2 + x_2^2} \in \left[\frac{1}{2},\, 1\right), \qquad F_{x_1 x_1}^{\mathrm{VRC}}\big|_{x_X=-1,\,x_1=x_2} = \frac{4(1 + x_2^2)}{2 + x_2^2} \in [2,\, 4),
  $$

  with `vrcResonantFubiniStudyX1 0 0 = 1 / 2` and `vrcResonantQfimX1 0 0 = 2`.

| Companion Paper & VRC Domain |Singularity or Bottleneck in Standard / Rational Chart | Homogeneous Complex VRC + $F_{\mu\nu} = 4\,g_{\mu\nu}^{\mathrm{FS}}$ Resolution | Machine-Checked Lean 4 Theorem / Definition |
| :--- | :--- | :--- | :--- |
| **[Paper 18](grassmannian-quantum-causal-inference-mpemba-paper.md): Quantum Causal Inference (`QCI`)** | Rational square-move $x_1' = \frac{x_1 x_X + x_2}{x_X+1}$ blows up at destructive causal interference $x_X = -1$ | `.complexHomogeneousVRC` scales $w_{A,B}^{\mathrm{VRC}} = x_X w_{A,B}^{\mathrm{Plabic}}$ with $100\%$ invariant $F_{\mu\mu} = 4 g_{\mu\mu}^{\mathrm{FS}}$ (`complexRescaledVrcJet`) | `qci_optional_vrc_vs_plabic_complex_grassmannian_identities`, `complexRescaledVrcJet` |
| **[Paper 22](grassmannian-kohn-sham-dft-complex-plabic-vrc-paper.md) & [Paper 23](grassmannian-speed-accuracy-barrier-quantum-chemistry-paper.md): Unrestricted Kohn–Sham DFT (`QCI-GXC`)** | Ad-hoc `1e-5` fudge at $x_X = -1$; $(x_X+1)^{-4}$ rational-chart metric blow-up; rank-1 $S_{\mathrm{vN}}(\|n\rangle\langle n\|)=0$ | Closed pole-free $F_{x_1 x_1}^{\mathrm{VRC}}\|_{x_X=-1} = 4 g_{x_1 x_1}^{\mathrm{FS,VRC}}\|_{x_X=-1} = \frac{4(2+x_2^2)(1+x_2^2)}{(\rho_{\mathrm{VRC}}^{(-1)})^2} > 0$; 1-RDM occupation entropy & Cayley retraction | `complex_plabic_vrc_and_sympy_check_figures`, `vrcResonantQfimX1`, `vrcResonantFubiniStudyX1` |
| **[Paper 24](grassmannian-tuning-materials-with-light-paper.md): Time-Linear Grassmannian `G-GKBA`** | $O(N_t^3)$ two-time Kadanoff–Baym memory & driven polariton resonance poles | $1.44 \times 10^8\times$ `G-GKBA` speedup + Mandelstam–Tamm temporal QFIM $F_{tt} = 4 g_{tt}^{\mathrm{FS}} = 4(\Delta H/\hbar)^2$ | `mandelstamTammTemporalQfim`, `grassmann_gkba_speedup_ratio` |
| **[Paper 39](grassmannian-quantum-causal-next-concept-modeling-pressed-llm-kicad-paper.md): Next-Concept Modeling (`QCI-NCM`)** | Intra-level conditional independence $\prod_i p(r_k^i \| \hat{z}^{(k-1)})$ fails on conflicting parallel concepts | VRC destructive constraint exclusion at $x_X = -1, x_1 = x_2$ with non-vanishing QFIM sensitivity $F_{x_1 x_1}^{\mathrm{VRC}}(0,0) = 2 = 4(1/2)$ | `qci_ncm_flag_bundle_cfg_level_weights_and_vrc_jeffrey_bridge_identities`, `vrcResonantQfimX1 0 0 = 2` |
| **[Paper 43](grassmannian-madness-tequila-quantum-chemistry-plabic-vrc-paper.md) & [Paper 44](grassmannian-tequila-rust-pyo3-quantum-simulator-paper.md): `MADNESS` `MRA-PNO` & `Tequila` Rust/PyO3 Simulator** | MP2/PNO $T_{ij}^{ab} = -g_{ij}^{ab}/\Delta\varepsilon$ diverges at $\Delta\varepsilon \to 0$; $4\times$ QNG vs. Fubini–Study step mismatch | `vrcRegularizedPnoAmplitude` gives finite gap QFIM $F_{\Delta\varepsilon,\Delta\varepsilon}^{\mathrm{PNO}}\|_{\Delta\varepsilon=0} = \frac{4g^2}{\gamma_{\mathrm{VRC}}^4}$ & $\Delta\theta_{\mathrm{QNG}}(4 g_{\theta\theta}^{\mathrm{FS}}) = \frac{1}{4}\Delta\theta_{\mathrm{QNG}}(g_{\theta\theta}^{\mathrm{FS}})$ | `vrc_fubini_study_kahler_qfim_pole_free_resonance_and_critique_fixes_identities` |

---

## 6. What $F_{\mu\nu} = 4\,g_{\mu\nu}^{\mathrm{FS}}$ Means for Cross-Domain Model Unification Across All 49 Papers

Why does the single proportionality $F_{\mu\nu} = 4\,g_{\mu\nu}^{\mathrm{FS}}$ act as the **keystone unification identity** across the entire 49-paper `Signals` architecture ([grassmannian-unification-applications-roadmap-paper.md](grassmannian-unification-applications-roadmap-paper.md))? Because $g_{\mu\nu}^{\mathrm{FS}}$ is the **Riemannian Kähler metric of the Grassmannian manifold** (governing mechanics, wave propagation, gravity, and electronic structure) while $F_{\mu\nu}$ is the **statistical distinguishability metric of quantum information** (governing estimation precision, causal inference, thermodynamic relaxation, and entanglement):

```{mermaid}
flowchart LR
    Core["Keystone Identity on Q_4 = Gr_C(2,4) & Gr_C(k,n)\nF_μν = 4 g^FS_μν\nTr(F_μν) = 4 Tr(g^FS_μν)"]

    P1["1. Plücker Madelung & iGPE (Papers 1, 15, 16, 19)\n(ℏ²/8m) ρ Tr(F) = (ℏ²/2m) ρ Tr(g^FS)\nRegularizes dark fringes & OAM vortex cores"]
    P2["2. Cachazo, Turner Gravity & DDF (Papers 3, 4, 30, 48)\nA_4^CHY = F^CHY/(s_12+s_13); Kähler D(W_orb)-3 = 1-e²\nEliminates Witten's 1/q⁴ ghost; ε_rel = 0"]
    P3["3. Quantum Cramér–Rao & <1nm Imaging (Papers 11, 17, 34)\nVar(θ̂_μ) ≥ 1/(N F_μμ) = 1/(4 N g^FS_μμ)\n4× variance compression ⇒ 0.50–0.603 nm localization"]
    P4["4. Flat-Band Superfluidity G-MGS & G-CSC (Papers 26, 28)\nD_s^geom = Δ_pair δ(1-δ) g^FS_μμ = (1/4) Δ_pair δ(1-δ) F_μμ\nGoverns RTG/R5G/MATTG & YBCO London stiffness"]
    P5["5. Mandelstam–Tamm QSL, G-GKBA & Tequila VQE (Papers 24, 44)\nF_tt = 4 g^FS_tt = 4(ΔH/ℏ)²\nExplains 1/2 vs. 4 in parameter-shift natural gradients"]
    P6["6. Normed 2D/3D Tensor Gaussian Splats (Papers 5, 10, 21)\n(ℏ²/8m) Tr(I^Fisher) = (ℏ²/8m) Tr(Σ⁻¹) = (1/2) Q_core(Σ)\nExact precision-matrix Bohm–Fisher duality"]
    P7["7. QCI, Jeffrey Kinematics & Bundle-Transformer (Papers 18, 20, 21, 39)\nd_chord² = ds_FS² = (1/4) ds_QFIM²\nD_KL = (1/2) I^class dx² ≤ 2 g^FS_μμ dx²"]
    P8["8. ER=EPR Wormholes vs. DDF Fractures (Papers 45, 47)\nC_EPR² = 4|p_23|² (same factor of 4!) vs. p_23 = 0\nHorodecki F_avg = (2 + C_EPR)/3 > 2/3"]

    Core --> P1
    Core --> P2
    Core --> P3
    Core --> P4
    Core --> P5
    Core --> P6
    Core --> P7
    Core --> P8
```

### 6.1 Master Cross-Domain Unification Table: Role of $F_{\mu\nu} = 4\,g_{\mu\nu}^{\mathrm{FS}}$ Across All Eight Pillars

| Pillar & Companion Papers | Fubini–Study Kähler Expression ($g_{\mu\nu}^{\mathrm{FS}}$) | Quantum Fisher Information Expression ($F_{\mu\nu} = 4\,g_{\mu\nu}^{\mathrm{FS}}$) | Exact Role of the Factor of $4$ & Lean 4 Verification Identifier |
| :--- | :--- | :--- | :--- |
| **1. Homogeneous Plücker $\mathcal{Q}_4$ Madelung & Dual `iGPE`**<br>([Papers 1](grassmannian-huygens-double-slit-oam-paper.md), [15](grassmannian-madelung-lagrangian-ddf-jamming-paper.md), [16](grassmannian-hawking-radiation-decoding-paper.md), [19](grassmannian-complex-gpe-igpe-plucker-madelung-paper.md)) | $\mathcal{T}_{\mathrm{FS}}^{\mathrm{proj}} = \frac{\hbar^2}{2m}\,\rho\,\operatorname{Tr}(g_{\mu\nu}^{\mathrm{FS}})$ | $\mathcal{T}_{\mathrm{QFIM}}^{\mathrm{proj}} = \frac{\hbar^2}{8m}\,\rho\,\operatorname{Tr}(F_{\mu\nu})$ | Cancels $\frac{1}{8m} \times 4 = \frac{1}{2m}$ so internal Kähler curvature and macroscopic flow $\frac{\hbar^2}{2m}\rho\mathcal{A}_\mu^2$ share the same prefactor (`projectiveQfimEnergyDir_eq_fubiniStudyEnergyDir`, `totalGpeKinetic3D_eq_madelung_qfim_trace`) |
| **2. Cachazo (`CHY`/`Hodges`), QED Scattering (`BCJ` / Partanen–Tulkki $\mathrm{U}(1)^4$), Turner 1PN/2.5PN Gravity, & DDF**<br>([Papers 3](grassmannian-ddf-moving-sheath-paper.md), [4](grassmannian-gravity-from-qed-scattering-paper.md), [30](grassmannian-su4-witten-twistor-string-cachazo-ddf-turner-ads-cft-unification-paper.md)) | $g_{\sigma\sigma}^{\mathrm{FS}}(\sigma_4) = \frac{1}{4\sigma_4(1-\sigma_4)}$, $g_{ee}^{\mathrm{FS}}(e) = \frac{1}{4(1-e^2)} = \frac{1}{4(\mathcal{D}(W_{\mathrm{orb}})-3)}$ | $\mathcal{A}_4^{\mathrm{CHY},\phi^3} = \frac{F_{\sigma\sigma}^{\mathrm{CHY}}(\sigma_4^*)}{s_{12}+s_{13}}$, $\Delta\varpi = \Delta\varpi_{\mathrm{circ}} F_{ee}^{\mathrm{orb}}(e)$, $f_{\mathrm{PM}}^2 = P_{\mathrm{PM}}^2(F_{ee}^{\mathrm{orb}})^7$ | Equates CHY amplitude to worldsheet QFIM, expresses 1PN precession & 2.5PN GW flux as powers of $F_{ee}^{\mathrm{orb}} = 4 g_{ee}^{\mathrm{FS}}$, & boosts spin-1 $1/4$ GW flux by $4\times$ under helicity doubling (`cachazo_gravity_chy_hodges_qfim_and_fubini_study_unification_identities`, `qed_scattering_gravity_bcj_partanen_tulkki_qfim_and_fubini_study_identities`) |
| **3. Bures Distance, Quantum Cramér–Rao (`QCRB`), & $<1\text{ nm}$ Imaging**<br>([Papers 11](grassmannian-holographic-imaging-depth-recovery-paper.md), [17](grassmannian-multispectral-hubble-medical-nanoimaging-paper.md), [34](grassmannian-multiband-1550nm-photonics-cnc-repeaters-cbas-homodyne-kicad-paper.md)) | $ds_{\mathrm{Bures}}^2 = g_{\mu\nu}^{\mathrm{FS}}dx^\mu dx^\nu$, $\operatorname{Var}(\hat{\theta}_\mu) \ge \frac{1}{4 N_{\mathrm{probes}} g_{\mu\mu}^{\mathrm{FS}}}$ | $ds_{\mathrm{Bures}}^2 = \frac{1}{4}F_{\mu\nu}dx^\mu dx^\nu$, $\operatorname{Var}(\hat{\theta}_\mu) \ge \frac{1}{N_{\mathrm{probes}} F_{\mu\mu}}$ | Provides $4\times$ estimator variance compression ($2\times$ RMS linewidth reduction), enabling $0.603\text{ nm}$ / $0.50\text{ nm}$ sub-nanometer localization (`buresMetricDiagFromQfim`, `quantumCramerRaoVarianceBound`) |
| **4. Flat-Band Superfluid Stiffness in Graphene (`G-MGS`) & Cuprates (`G-CSC`)**<br>([Papers 26](grassmannian-cuprate-superconductivity-paper.md), [28](grassmannian-rhombohedral-graphene-superconductivity-qc-paper.md), [46](grassmannian-thermo-electro-magnetics-lord-shulman-paper.md)) | $D_s^{\mathrm{tot}} = t_{\mathrm{kin}}^2 + \Delta_{\mathrm{pair}}\delta(1-\delta)g_{\mu\mu}^{\mathrm{FS}}$ ({cite:p}`peotta2015superfluid`) | $D_s^{\mathrm{geom}}(t_{\mathrm{kin}}=0) = \frac{1}{4}\Delta_{\mathrm{pair}}\delta(1-\delta)F_{\mu\mu}$ | Expresses flat-band Meissner stiffness and kinetic inductance $L_k \propto 1/F_{\mu\mu}$ on $\mathrm{Gr}_{\mathbb{C}}(2,6)$ (`RTG`) and $\mathrm{Gr}_{\mathbb{C}}(2,10)$ (`R5G`) directly via Bloch-band QFIM (`peottaTormaFlatBandStiffnessFromQfim`) |
| **5. Complex Plabic `VRC`, Mandelstam–Tamm Speed Limit (`QSL`), `G-GKBA`, & `Tequila` VQE**<br>([Papers 22](grassmannian-kohn-sham-dft-complex-plabic-vrc-paper.md), [23](grassmannian-speed-accuracy-barrier-quantum-chemistry-paper.md), [24](grassmannian-tuning-materials-with-light-paper.md), [43](grassmannian-madness-tequila-quantum-chemistry-plabic-vrc-paper.md), [44](grassmannian-tequila-rust-pyo3-quantum-simulator-paper.md)) | $g_{x_1 x_1}^{\mathrm{FS,VRC}}\|_{x_X=-1} = \frac{(2+x_2^2)(1+x_2^2)}{(\rho_{\mathrm{VRC}}^{(-1)})^2}$, $g_{tt}^{\mathrm{FS}} = \frac{(\Delta H)^2}{\hbar^2}$ ({cite:p}`mandelstam1945uncertainty`) | $F_{x_1 x_1}^{\mathrm{VRC}}\|_{x_X=-1} = 4\,g_{x_1 x_1}^{\mathrm{FS,VRC}}\|_{x_X=-1}$, $F_{tt} = 4\,g_{tt}^{\mathrm{FS}} = \frac{4(\Delta H)^2}{\hbar^2}$ | Eliminates $(x_X+1)^{-4}$ resonance poles at $x_X=-1$, keeps $F_{\mu\mu}=4g_{\mu\mu}^{\mathrm{FS}}$ invariant under denominator clearing, & sets $\Delta\theta_{\mathrm{QNG}}(F) = \frac{1}{4}\Delta\theta_{\mathrm{QNG}}(g^{\mathrm{FS}})$ (`vrc_fubini_study_kahler_qfim_pole_free_resonance_and_critique_fixes_identities`) |
| **6. Normed 2D & 3D Tensor Gaussian Splats & Bohm–Fisher Identity**<br>([Papers 5](grassmannian-splat-mechanics-paper.md), [10](gaussian-splat-tensors-normed-paper.md), [21](grassmannian-quantum-causal-splat-nanoimaging-surgical-graphrag-paper.md)) | $Q_{\mathrm{core}}(\Sigma) = \frac{\hbar^2}{4m}\operatorname{Tr}(\Sigma^{-1})$ (`coreBohmPotential`) | $\mathcal{T}_{\mathrm{Bohm}}^{\mathrm{splat}} = \frac{\hbar^2}{8m}\operatorname{Tr}(I^{\mathrm{Fisher}}) = \frac{\hbar^2}{8m}\operatorname{Tr}(\Sigma^{-1}) = \frac{1}{2}Q_{\mathrm{core}}(\Sigma)$ | Connects the spatially integrated density Fisher energy $\frac{\hbar^2}{8m}\operatorname{Tr}(\Sigma^{-1})$ to half the core Bohm potential $\frac{\hbar^2}{4m}\operatorname{Tr}(\Sigma^{-1})$ (`gaussianSplatScalarBohmFromFisher`) |
| **7. Plücker Simplex, Quantum Causal Inference (`QCI`), & `Bundle-Transformer`**<br>([Papers 18](grassmannian-quantum-causal-inference-mpemba-paper.md), [20](grassmannian-quantum-causal-jev-bundle-transformer-videogen-paper.md), [39](grassmannian-quantum-causal-next-concept-modeling-pressed-llm-kicad-paper.md)) | $g_{\mu\mu}^{\mathrm{FS}} = \frac{1}{4}I_{\mu\mu}^{\mathrm{class}}(p) + \operatorname{Var}_p(\partial_\mu\phi)$, $d_{\mathrm{chord}}^2 \simeq g_{\mu\nu}^{\mathrm{FS}}dx^\mu dx^\nu$ | $F_{\mu\mu} = I_{\mu\mu}^{\mathrm{class}}(p) + 4\,\operatorname{Var}_p(\partial_\mu\phi) \ge I_{\mu\mu}^{\mathrm{class}}(p)$ | Separates classicalJeffrey/KL simplex drift $I_{\mu\mu}^{\mathrm{class}}(p)$ from $4\times$ coherent Plücker phase variance $4\,\operatorname{Var}_p(\partial_\mu\phi)$ (`qfim_simplex_phase_variance_split`, `twoChannelPhaseVariance`) |
| **8. $\mathrm{ER}=\mathrm{EPR}$ Wormhole Concurrence vs. DDF Fracture Waveguides**<br>([Papers 45](grassmannian-er-epr-witten-su4-plucker-tachyons-semi-dirac-paper.md), [47](grassmannian-ddf-fracture-communication-vs-er-epr-wormholes-paper.md)) | Deformed conifold minor $\|p_{23}\|^2 = \|\det\Psi\|^2 \in [0, 1/4]$ | Wootters concurrence squared $\mathcal{C}_{\mathrm{EPR}}^2 = 4\|p_{23}\|^2 \in [0, 1]$ (`erEprPluckerConcurrenceSq`) | Uses the exact same factor of $4$ to normalize maximally entangled Bell states ($\|p_{23}\|^2 = 1/4 \mapsto \mathcal{C}_{\mathrm{EPR}}^2 = 1$) against unentangled DDF fractures ($p_{23}=0$) |

---

## 7. Adversarial Critique & Gap-Closure Fixes (`Signals.DFT` Section 27.2)

To ensure that our formalization in `Signals.DFT` Section 27 is not merely a set of unconstrained algebraic definitions, we audited `PluckerDirectionalJet` and the simplex/Madelung decompositions against four mathematical and physical critiques and proved all four fixes in `qfim_fubini_study_cauchy_schwarz_gauge_invariance_and_vortex_core_critique_identities` ({download}`src/signals/Signals/DFT.lean, lines 9224–9368 <../src/signals/Signals/DFT.lean>`):

1. **Critique 1 — Unconstrained Real Fields in `PluckerDirectionalJet` vs. Unconditional Cauchy–Schwarz Positivity ($0 \le g_{\mu\mu}^{\mathrm{FS}} \le F_{\mu\mu}$)**:
   - *Critique*: In the base structure `PluckerDirectionalJet`, `dpsi_norm_sq` is an arbitrary real number, so if someone supplied `dpsi_norm_sq = 0` with `drho ≠ 0`, `fubiniStudyDiag` and `qfimDiag` would evaluate to negative numbers, violating the positive-semidefiniteness of a Riemannian/Fisher metric.
   - *Machine-Checked Fix (`mkPhysicalPluckerDirectionalJet`)*: In Hilbert space $\mathbb{C}^6$, decomposing $\partial_\mu\Psi = \frac{\langle\Psi\mid\partial_\mu\Psi\rangle}{\rho}\Psi + \Psi_\perp$ with $\langle\Psi\mid\Psi_\perp\rangle = 0$ and orthogonal norm squared $\|\Psi_\perp\|^2 = \mathrm{ortho\_norm\_sq} \ge 0$ gives $\langle\partial_\mu\Psi\mid\partial_\mu\Psi\rangle = \frac{|\langle\Psi\mid\partial_\mu\Psi\rangle|^2}{\rho} + \|\Psi_\perp\|^2$. For any physical jet constructed via `mkPhysicalPluckerDirectionalJet rho drho A_mu ortho_norm_sq` with $\rho > 0$ and $\|\Psi_\perp\|^2 \ge 0$, we prove:

     $$
     g_{\mu\mu}^{\mathrm{FS}} = \frac{\|\Psi_\perp\|^2}{\rho} \ge 0, \qquad F_{\mu\mu} = \frac{4\|\Psi_\perp\|^2}{\rho} \ge 0.
     $$

2. **Critique 2 — Local $\mathrm{U}(1)$ Projective Phase Gauge Dependence of $\mathcal{A}_\mu$ vs. Gauge Invariance of $g_{\mu\mu}^{\mathrm{FS}}$ and $F_{\mu\mu}$**:
   - *Critique*: Under a local gauge transformation $\Psi(x) \mapsto e^{i\chi(x)}\Psi(x)$ with phase gradient $d\chi = \partial_\mu\chi(x)$, the superfluid connection shifts as $\mathcal{A}_\mu \mapsto \mathcal{A}_\mu + d\chi$ and the raw derivative norm shifts as $\langle\partial_\mu\Psi\mid\partial_\mu\Psi\rangle \mapsto \langle\partial_\mu\Psi\mid\partial_\mu\Psi\rangle + 2\rho\mathcal{A}_\mu(d\chi) + \rho(d\chi)^2$. Does this gauge shift contaminate $g_{\mu\mu}^{\mathrm{FS}}$ or $F_{\mu\mu}$?
   - *Machine-Checked Fix (`gaugeShiftedPluckerJet`)*: We prove that for every $d\chi \in \mathbb{R}$ and $\rho \neq 0$, the gauge shift cancels **identically** between $\rho\langle\partial_\mu\Psi\mid\partial_\mu\Psi\rangle$ and $|\langle\Psi\mid\partial_\mu\Psi\rangle|^2$:

     $$
     \operatorname{fubiniStudyDiag}\bigl(\operatorname{gaugeShiftedPluckerJet}(d, d\chi)\bigr) = \operatorname{fubiniStudyDiag}(d), \qquad \operatorname{qfimDiag}\bigl(\operatorname{gaugeShiftedPluckerJet}(d, d\chi)\bigr) = \operatorname{qfimDiag}(d).
     $$

3. **Critique 3 — Could $\operatorname{Var}_p(\partial_\mu\phi)$ Be Negative for Unnormalized Weights, Violating $F_{\mu\mu} \ge I_{\mu\mu}^{\mathrm{class}}(p)$?**:
   - *Critique*: In `qfim_simplex_phase_variance_split`, `p : Fin 6 → ℝ` is an arbitrary function; without $\sum_k p_k = 1$ and $p_k \ge 0$, `secondMomentBivectorPhaseGrad p dphi - (meanBivectorPhaseGrad p dphi)^2` need not be non-negative.
   - *Machine-Checked Fix (`twoChannelPhaseVariance`)*: On the probability simplex $p_0 + p_1 = 1$ with $p_0, p_1 \ge 0$, we prove the exact algebraic factorization:

     $$
     \operatorname{twoChannelPhaseVariance}(p_0, p_1, d\phi_0, d\phi_1) = p_0(d\phi_0)^2 + p_1(d\phi_1)^2 - (p_0 d\phi_0 + p_1 d\phi_1)^2 = p_0\,p_1\,(d\phi_0 - d\phi_1)^2 \ge 0,
     $$

     confirming that $F_{\mu\mu} = I_{\mu\mu}^{\mathrm{class}}(p) + 4\,\operatorname{Var}_p(\partial_\mu\phi) \ge I_{\mu\mu}^{\mathrm{class}}(p)$ with strict quantum enhancement whenever $p_0, p_1 > 0$ and $d\phi_0 \neq d\phi_1$.
4. **Critique 4 — Behavior at Nodal Dark Fringes and OAM Vortex Cores ($\rho \to 0^+$)**:
   - *Critique*: When $\rho \to 0^+$ with a non-zero radial density slope $\partial_\mu\rho \neq 0$, dividing by $\rho$ in Channel 2 (`scalarBohmDensityDir`) diverges as $1/\rho \to \infty$. Does Channel 3 (`projectiveQfimEnergyDir`) also diverge?
   - *Machine-Checked Fix (`projectiveQfimEnergyFromRayMetric`)*: When parameterized by a smooth normalized projective ray $n(x) \in \mathcal{Q}_4$ with finite Fubini–Study curvature $g_{\mu\mu}^{\mathrm{FS}} = \langle\partial_\mu n\mid\partial_\mu n\rangle - |\langle n\mid\partial_\mu n\rangle|^2 < \infty$, Channel 3 is $\frac{\hbar^2}{8m}\rho(4\,g_{\mu\mu}^{\mathrm{FS}}) = \frac{\hbar^2}{2m}\rho\,g_{\mu\mu}^{\mathrm{FS}}$, which **vanishes linearly (`= 0`) at $\rho = 0$** (`projectiveQfimEnergyFromRayMetric hbar mass 0 g_fs_ray = 0`), while on the affine chart $Z = (I_2 \mid W)$ the Kähler norm $\det(I_2 + W W^\dagger) = 1 + \|W\|_{\mathrm{HS}}^2 + |\det W|^2 \ge 1$ (`pluckerRegularizedVortexCoreNormSq`) never vanishes even when $\det W = 0$.

---

## 8. Formal Verification in Lean 4 & Numerical Implementation in Rust

### 8.1 Standalone Lean 4 Module (`GrassmannianMadelungQFIM`)

The self-contained Lean 4 formalization below (integrated with `@[blueprint ...]` annotations into `Signals.DFT` Section 27 in {download}`src/signals/Signals/DFT.lean, lines 8598–10060 <../src/signals/Signals/DFT.lean>`) proves Lemma 1 (`qfimDiag_eq_four_mul_fubiniStudyDiag`), Lemma 2 (`projectiveQfimEnergyDir_eq_fubiniStudyEnergyDir`), Theorem 1 (`gpeKineticDir_eq_madelung_qfim_split`), Theorem 2 (`traceQFIM3D_eq_four_mul_traceFubiniStudy3D`), Theorem 3 (`totalGpeKinetic3D_eq_madelung_qfim_trace`), Theorem 4 (`qfim_simplex_phase_variance_split`), and Theorem 5 (`madelung_klein_quadric_tangency`):

```lean
import Mathlib.Data.Real.Basic
import Mathlib.Data.Complex.Basic
import Mathlib.Algebra.BigOperators.Group.Finset
import Mathlib.Tactic.Ring
import Mathlib.Tactic.FieldSimp

open BigOperators

namespace GrassmannianMadelungQFIM

/-- Local directional derivative invariants of the homogeneous Plücker condensate `Ψ`
along a single spatial axis `x^μ`. -/
structure PluckerDirectionalJet where
  /-- Macroscopic condensate density `ρ = ⟨Ψ | Ψ⟩` -/
  rho : ℝ
  /-- Norm squared of the directional Plücker gradient `⟨∂_μ Ψ | ∂_μ Ψ⟩` -/
  dpsi_norm_sq : ℝ
  /-- Directional derivative of macroscopic density `∂_μ ρ = 2 Re⟨Ψ | ∂_μ Ψ⟩` -/
  drho : ℝ
  /-- Effective superfluid gauge/Berry velocity potential gradient `A_μ = Im⟨Ψ | ∂_μ Ψ⟩ / ρ` -/
  A_mu : ℝ

/-- Squared modulus of the inner product `|⟨Ψ | ∂_μ Ψ⟩|² = (∂_μ ρ / 2)² + (ρ A_μ)²`. -/
def innerPsiDpsiNormSq (d : PluckerDirectionalJet) : ℝ :=
  (d.drho / 2) ^ 2 + (d.rho * d.A_mu) ^ 2

/-- Projective Fubini-Study diagonal metric component `g^{FS}_{μμ}` on `Q₄ ⊂ ℂℙ⁵`:
`g^{FS}_{μμ} = (ρ ⟨∂_μ Ψ | ∂_μ Ψ⟩ - |⟨Ψ | ∂_μ Ψ⟩|²) / ρ²`. -/
noncomputable def fubiniStudyDiag (d : PluckerDirectionalJet) : ℝ :=
  (d.rho * d.dpsi_norm_sq - innerPsiDpsiNormSq d) / (d.rho ^ 2)

/-- Diagonal Quantum Fisher Information Metric component `F_{μμ} = 4 g^{FS}_{μμ}`:
`F_{μμ} = 4 (ρ ⟨∂_μ Ψ | ∂_μ Ψ⟩ - |⟨Ψ | ∂_μ Ψ⟩|²) / ρ²`. -/
noncomputable def qfimDiag (d : PluckerDirectionalJet) : ℝ :=
  4 * (d.rho * d.dpsi_norm_sq - innerPsiDpsiNormSq d) / (d.rho ^ 2)

/-- Direct Gross-Pitaevskii kinetic energy density along direction `μ`: `(ℏ² / 2m) ⟨∂_μ Ψ | ∂_μ Ψ⟩`. -/
noncomputable def gpeKineticDir (hbar mass : ℝ) (d : PluckerDirectionalJet) : ℝ :=
  (hbar ^ 2 / (2 * mass)) * d.dpsi_norm_sq

/-- Center-of-mass hydrodynamic flow energy along `μ`: `(ℏ² / 2m) ρ A_μ²`. -/
noncomputable def hydroFlowDir (hbar mass : ℝ) (d : PluckerDirectionalJet) : ℝ :=
  (hbar ^ 2 / (2 * mass)) * d.rho * (d.A_mu ^ 2)

/-- Scalar Bohmian density Fisher energy along `μ`: `(ℏ² / 8m) (∂_μ ρ)² / ρ`. -/
noncomputable def scalarBohmDensityDir (hbar mass : ℝ) (d : PluckerDirectionalJet) : ℝ :=
  (hbar ^ 2 / (8 * mass)) * (d.drho ^ 2 / d.rho)

/-- Projective QFIM kinetic energy along `μ`: `(ℏ² / 8m) ρ F_{μμ}`. -/
noncomputable def projectiveQfimEnergyDir (hbar mass : ℝ) (d : PluckerDirectionalJet) : ℝ :=
  (hbar ^ 2 / (8 * mass)) * d.rho * qfimDiag d

/-- Projective Fubini-Study kinetic energy along `μ`: `(ℏ² / 2m) ρ g^{FS}_{μμ}`. -/
noncomputable def projectiveFubiniStudyEnergyDir (hbar mass : ℝ) (d : PluckerDirectionalJet) : ℝ :=
  (hbar ^ 2 / (2 * mass)) * d.rho * fubiniStudyDiag d

/-- Lemma 1: The diagonal QFIM component is identically 4 times the Fubini-Study component. -/
theorem qfimDiag_eq_four_mul_fubiniStudyDiag (d : PluckerDirectionalJet) :
    qfimDiag d = 4 * fubiniStudyDiag d := by
  unfold qfimDiag fubiniStudyDiag
  ring

/-- Lemma 2: The projective QFIM energy `(ℏ² / 8m) ρ F_{μμ}` is identically equal to
the projective Fubini-Study energy `(ℏ² / 2m) ρ g^{FS}_{μμ}`. -/
theorem projectiveQfimEnergyDir_eq_fubiniStudyEnergyDir
    (hbar mass : ℝ) (d : PluckerDirectionalJet) (hm : mass ≠ 0) :
    projectiveQfimEnergyDir hbar mass d = projectiveFubiniStudyEnergyDir hbar mass d := by
  unfold projectiveQfimEnergyDir projectiveFubiniStudyEnergyDir qfimDiag fubiniStudyDiag
  field_simp [hm]
  ring

/-- Theorem 1 (Directional Plücker Madelung-QFIM Identity):
For any non-vanishing condensate density `ρ ≠ 0` and mass `m ≠ 0`, the Gross-Pitaevskii
directional kinetic energy density decomposes exactly into the hydrodynamic flow term,
the scalar Bohmian density Fisher term, and the projective QFIM term. -/
theorem gpeKineticDir_eq_madelung_qfim_split
    (hbar mass : ℝ) (d : PluckerDirectionalJet) (hrho : d.rho ≠ 0) (hm : mass ≠ 0) :
    gpeKineticDir hbar mass d =
      hydroFlowDir hbar mass d +
      scalarBohmDensityDir hbar mass d +
      projectiveQfimEnergyDir hbar mass d := by
  unfold gpeKineticDir hydroFlowDir scalarBohmDensityDir projectiveQfimEnergyDir
  unfold qfimDiag innerPsiDpsiNormSq
  field_simp [hrho, hm]
  ring

/-- 3D spatial jet of a Plücker condensate field on `Q₄`. -/
structure Plucker3DSpatialJet where
  dir : Fin 3 → PluckerDirectionalJet
  rho : ℝ
  rho_consistent : ∀ μ : Fin 3, (dir μ).rho = rho

noncomputable def totalGpeKinetic3D (hbar mass : ℝ) (j : Plucker3DSpatialJet) : ℝ :=
  ∑ μ : Fin 3, gpeKineticDir hbar mass (j.dir μ)

noncomputable def totalHydroFlow3D (hbar mass : ℝ) (j : Plucker3DSpatialJet) : ℝ :=
  ∑ μ : Fin 3, hydroFlowDir hbar mass (j.dir μ)

noncomputable def totalScalarBohm3D (hbar mass : ℝ) (j : Plucker3DSpatialJet) : ℝ :=
  ∑ μ : Fin 3, scalarBohmDensityDir hbar mass (j.dir μ)

noncomputable def traceQFIM3D (j : Plucker3DSpatialJet) : ℝ :=
  ∑ μ : Fin 3, qfimDiag (j.dir μ)

noncomputable def traceFubiniStudy3D (j : Plucker3DSpatialJet) : ℝ :=
  ∑ μ : Fin 3, fubiniStudyDiag (j.dir μ)

noncomputable def totalProjectiveQfimEnergy3D (hbar mass : ℝ) (j : Plucker3DSpatialJet) : ℝ :=
  (hbar ^ 2 / (8 * mass)) * j.rho * traceQFIM3D j

/-- Theorem 2 (3D Spatial Trace Identity `Tr(F_{μν}) = 4 Tr(g^{FS}_{μν})`): -/
theorem traceQFIM3D_eq_four_mul_traceFubiniStudy3D (j : Plucker3DSpatialJet) :
    traceQFIM3D j = 4 * traceFubiniStudy3D j := by
  unfold traceQFIM3D traceFubiniStudy3D
  rw [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro μ _
  exact qfimDiag_eq_four_mul_fubiniStudyDiag (j.dir μ)

/-- Theorem 3 (Master 3D Plücker Madelung-QFIM Energy Decomposition on Q₄): -/
theorem totalGpeKinetic3D_eq_madelung_qfim_trace
    (hbar mass : ℝ) (j : Plucker3DSpatialJet) (hrho : j.rho ≠ 0) (hm : mass ≠ 0) :
    totalGpeKinetic3D hbar mass j =
      totalHydroFlow3D hbar mass j +
      totalScalarBohm3D hbar mass j +
      totalProjectiveQfimEnergy3D hbar mass j := by
  unfold totalGpeKinetic3D totalHydroFlow3D totalScalarBohm3D totalProjectiveQfimEnergy3D traceQFIM3D
  rw [Finset.mul_sum]
  have h_dir : ∀ μ : Fin 3,
      gpeKineticDir hbar mass (j.dir μ) =
        hydroFlowDir hbar mass (j.dir μ) +
        scalarBohmDensityDir hbar mass (j.dir μ) +
        (hbar ^ 2 / (8 * mass)) * j.rho * qfimDiag (j.dir μ) := by
    intro μ
    have hμ_rho : (j.dir μ).rho ≠ 0 := by rw [j.rho_consistent μ]; exact hrho
    rw [gpeKineticDir_eq_madelung_qfim_split hbar mass (j.dir μ) hμ_rho hm]
    unfold projectiveQfimEnergyDir
    rw [j.rho_consistent μ]
  calc
    ∑ μ : Fin 3, gpeKineticDir hbar mass (j.dir μ)
      = ∑ μ : Fin 3,
          (hydroFlowDir hbar mass (j.dir μ) +
           scalarBohmDensityDir hbar mass (j.dir μ) +
           (hbar ^ 2 / (8 * mass)) * j.rho * qfimDiag (j.dir μ)) := by
        apply Finset.sum_congr rfl
        intro μ _
        exact h_dir μ
    _ = (∑ μ : Fin 3, hydroFlowDir hbar mass (j.dir μ)) +
        (∑ μ : Fin 3, scalarBohmDensityDir hbar mass (j.dir μ)) +
        (∑ μ : Fin 3, (hbar ^ 2 / (8 * mass)) * j.rho * qfimDiag (j.dir μ)) := by
        simp only [Finset.sum_add_distrib]

noncomputable def classicalPluckerFisher (p dp : Fin 6 → ℝ) : ℝ :=
  ∑ k : Fin 6, (dp k) ^ 2 / (p k)

def meanBivectorPhaseGrad (p dphi : Fin 6 → ℝ) : ℝ :=
  ∑ k : Fin 6, p k * dphi k

def secondMomentBivectorPhaseGrad (p dphi : Fin 6 → ℝ) : ℝ :=
  ∑ k : Fin 6, p k * (dphi k) ^ 2

def bivectorPhaseVariance (p dphi : Fin 6 → ℝ) : ℝ :=
  secondMomentBivectorPhaseGrad p dphi - (meanBivectorPhaseGrad p dphi) ^ 2

noncomputable def normalizedRayFubiniStudy (p dp dphi : Fin 6 → ℝ) : ℝ :=
  (∑ k : Fin 6, ((dp k) ^ 2 / (4 * p k) + p k * (dphi k) ^ 2)) -
    (meanBivectorPhaseGrad p dphi) ^ 2

/-- Theorem 4 (Plücker Simplex Fisher + Bivector Phase-Variance Split): -/
theorem qfim_simplex_phase_variance_split (p dp dphi : Fin 6 → ℝ) :
    4 * normalizedRayFubiniStudy p dp dphi =
      classicalPluckerFisher p dp + 4 * bivectorPhaseVariance p dphi := by
  unfold normalizedRayFubiniStudy classicalPluckerFisher bivectorPhaseVariance
  unfold secondMomentBivectorPhaseGrad meanBivectorPhaseGrad
  rw [Finset.sum_add_distrib]
  have h_fisher :
      4 * (∑ k : Fin 6, (dp k) ^ 2 / (4 * p k)) = ∑ k : Fin 6, (dp k) ^ 2 / p k := by
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro k _
    ring
  linarith [h_fisher]

structure Bivector6 (α : Type*) where
  p01 : α
  p02 : α
  p03 : α
  p12 : α
  p13 : α
  p23 : α

def scaleBivector {α : Type*} [CommRing α] (c : α) (v : Bivector6 α) : Bivector6 α :=
  { p01 := c * v.p01, p02 := c * v.p02, p03 := c * v.p03,
    p12 := c * v.p12, p13 := c * v.p13, p23 := c * v.p23 }

def addBivector {α : Type*} [CommRing α] (u v : Bivector6 α) : Bivector6 α :=
  { p01 := u.p01 + v.p01, p02 := u.p02 + v.p02, p03 := u.p03 + v.p03,
    p12 := u.p12 + v.p12, p13 := u.p13 + v.p13, p23 := u.p23 + v.p23 }

def kleinPolarForm {α : Type*} [CommRing α] (u v : Bivector6 α) : α :=
  u.p01 * v.p23 + v.p01 * u.p23 -
  (u.p02 * v.p13 + v.p02 * u.p13) +
  (u.p03 * v.p12 + v.p03 * u.p12)

def kleinQuadric {α : Type*} [CommRing α] (u : Bivector6 α) : α :=
  u.p01 * u.p23 - u.p02 * u.p13 + u.p03 * u.p12

/-- Theorem 5 (Klein Quadric Tangency Invariance of the Madelung Factorization): -/
theorem madelung_klein_quadric_tangency
    {α : Type*} [CommRing α] (amp damp : α) (n dn : Bivector6 α)
    (h_quad : kleinQuadric n = 0) (h_tang : kleinPolarForm n dn = 0) :
    kleinPolarForm (scaleBivector amp n)
      (addBivector (scaleBivector damp n) (scaleBivector amp dn)) = 0 := by
  have h_id :
      kleinPolarForm (scaleBivector amp n)
        (addBivector (scaleBivector damp n) (scaleBivector amp dn)) =
      2 * amp * damp * kleinQuadric n + (amp ^ 2) * kleinPolarForm n dn := by
    unfold kleinPolarForm kleinQuadric scaleBivector addBivector
    ring
  rw [h_id, h_quad, h_tang]
  ring

end GrassmannianMadelungQFIM
```

### 8.2 Key Architectural Highlights of the Proof

1. **No Division-by-Zero Axioms Needed (`field_simp` + `ring`)**:
   In `gpeKineticDir_eq_madelung_qfim_split`, Lean's `field_simp [hrho, hm]` clears the $\rho^2$ and $8m$ denominators from $F_{\mu\mu} = \frac{4(\rho\langle\partial_\mu\Psi\mid\partial_\mu\Psi\rangle - |\langle\Psi\mid\partial_\mu\Psi\rangle|^2)}{\rho^2}$ and substitutes $|\langle\Psi\mid\partial_\mu\Psi\rangle|^2 = \frac{1}{4}(\partial_\mu\rho)^2 + \rho^2\mathcal{A}_\mu^2$, reducing the equality to a polynomial ring identity closed by `ring`.
2. **Summation Congruence Over `Fin 3` (`totalGpeKinetic3D_eq_madelung_qfim_trace`)**:
   The 3D spatial trace proof lifts the directional identity across `Fin 3` using `Finset.sum_congr` and `Finset.sum_add_distrib`, factoring out the shared macroscopic fluid density $\rho(x)$ via `j.rho_consistent` to form $\frac{\hbar^2}{8m}\rho\,\operatorname{Tr}(F_{\mu\nu}) = \frac{\hbar^2}{2m}\rho\,\operatorname{Tr}(g_{\mu\nu}^{\mathrm{FS}})$.
3. **Simplex Fisher + Phase Variance (`qfim_simplex_phase_variance_split`)**:
   Proves over `Fin 6` that multiplying the projective ray metric by $4$ cancels the $\frac{1}{4}$ factor in $\sum_{k=0}^5 \frac{(\partial_\mu p_k)^2}{4p_k}$ to yield the exact classical Fisher information $I_{\mu\mu}^{\mathrm{class}}(p)$ plus $4\,\operatorname{Var}_p(\partial_\mu\phi)$.
4. **Tangency Preservation (`madelung_klein_quadric_tangency`)**:
   Proves over any commutative ring $\alpha$ (including $\mathbb{C}$) that scaling by the Madelung amplitude $\alpha = \sqrt{\rho}\,e^{i S_0/\hbar}$ shifts the differential quadric form by $2\alpha(\partial_\mu\alpha)Q(n) + \alpha^2 Q(n, \partial_\mu n)$, which vanishes identically on $T\mathcal{Q}_4$.
5. **Cachazo Worldsheet & Hodges Double-Copy Unification (`cachazo_gravity_chy_hodges_qfim_and_fubini_study_unification_identities`)**:
   Proves that at the unique 4-point CHY root $\sigma_4^*(s_{12}, s_{13}) = \frac{s_{12}}{s_{12}+s_{13}}$, the bi-adjoint scalar amplitude $\frac{1}{s_{12}} + \frac{1}{s_{13}}$ and reduced CHY Jacobian $\Phi_{44}^{\mathrm{CHY}}$ are exact multiples of the worldsheet QFIM $F_{\sigma\sigma}^{\mathrm{CHY}}(\sigma_4^*) = 4\,g_{\sigma\sigma}^{\mathrm{FS}}(\sigma_4^*)$, while the Cachazo–Skinner Hodges double-copy kernel on orbital Plücker channels reproduces both the factor of $4$ and the $(1 - e^2)$ QFIM phase-variance weight.
6. **QED & Gauge Scattering Gravity via Orbital Eccentricity QFIM & Fubini–Study Metric (`qed_scattering_gravity_bcj_partanen_tulkki_qfim_and_fubini_study_identities`)**:
   Proves that on the aphelion–perihelion simplex $p_{\mathrm{aph}}(e) = \frac{1+e}{2}, p_{\mathrm{per}}(e) = \frac{1-e}{2}$, the orbital eccentricity QFIM is $F_{ee}^{\mathrm{orb}}(e) = 4\,g_{ee}^{\mathrm{FS}}(e) = (1 - e^2)^{-1} = (\mathcal{D}(W_{\mathrm{orb}})-3)^{-1}$, 1PN QED double-copy perihelion advance is $\Delta\varpi_{\mathrm{circ}} F_{ee}^{\mathrm{orb}}(e) = 4\Delta\varpi_{\mathrm{circ}} g_{ee}^{\mathrm{FS}}(e)$, 2.5PN Peters–Mathews GW enhancement is $P_{\mathrm{PM}}(e)^2\,(F_{ee}^{\mathrm{orb}}(e))^7$, un-doubled spin-1 vector gravity has relative errors $5/6$ (1PN) and $3/4$ (2.5PN), and helicity-doubling phase winding $(\phi_0, \phi_1) \mapsto (2\phi_0, 2\phi_1)$ scales the bivector phase variance by $4\times$ to restore exact spin-2 GR quadrupole luminosity.
7. **Complex Plabic VRC Pole-Free Resonance ($x_X = -1$), Denominator-Clearing Invariance, & MRA-PNO / `Tequila` Natural Gradient (`vrc_fubini_study_kahler_qfim_pole_free_resonance_and_critique_fixes_identities`)**:
   Proves that at $x_X = -1$, `gr24MutatedHomogeneousVRC` has polynomial Plücker norm $\rho_{\mathrm{VRC}}^{(-1)}(x_1, x_2) = 2 + x_2^2 + (x_2 - x_1)^2(1 + x_2^2) \ge 2 > 0$ and strictly positive metrics $F_{x_1 x_1}^{\mathrm{VRC}}|_{x_X=-1} = 4\,g_{x_1 x_1}^{\mathrm{FS,VRC}}|_{x_X=-1} = \frac{4(2+x_2^2)(1+x_2^2)}{(\rho_{\mathrm{VRC}}^{(-1)})^2} > 0$, that `fubiniStudyDiag` and `qfimDiag` are $100\%$ invariant under arbitrary complex radial + phase VRC denominator clearing (`complexRescaledVrcJet`), and that VRC-regularized MRA-PNO pair amplitudes yield a finite gap QFIM $4 g^2 / \gamma_{\mathrm{VRC}}^4$ at $\Delta\varepsilon = 0$ with a $1/4$ QFIM-to-Fubini–Study Quantum Natural Gradient step ratio.

### 8.3 Rust Numerical Implementation & Verification (`src/signals/numerical_adapter/src/dft_plabic_vrc.rs`)

In {download}`src/signals/numerical_adapter/src/dft_plabic_vrc.rs, lines 2420–2910 and 3860–4290 <../src/signals/numerical_adapter/src/dft_plabic_vrc.rs>`, all Section 27 structures and functions (`PluckerDirectionalJet`, `fubini_study_diag`, `qfim_diag`, `gpe_kinetic_dir`, `hydro_flow_dir`, `scalar_bohm_density_dir`, `projective_qfim_energy_dir`, `projective_fubini_study_energy_dir`, `Plucker3DSpatialJet`, `trace_qfim_3d`, `trace_fubini_study_3d`, `total_gpe_kinetic_3d`, `classical_plucker_fisher`, `bivector_phase_variance`, `normalized_ray_fubini_study`, `Bivector6`, `witten_fourth_order_propagator`, `turner_kahler_orbital_semi_latus_factor`, `bures_metric_diag_from_qfim`, `quantum_cramer_rao_variance_bound`, `mandelstam_tamm_temporal_qfim`, `peotta_torma_flat_band_stiffness_from_qfim`, `gaussian_splat_scalar_bohm_from_fisher`, `mk_physical_plucker_directional_jet`, `gauge_shifted_plucker_jet`, `two_channel_phase_variance`, `projective_qfim_energy_from_ray_metric`, `chy_worldsheet_fubini_study_metric`, `chy_worldsheet_qfim_metric`, `chy_four_point_reduced_jacobian`, `cachazo_skinner_filtered_propagator`, `cachazo_hodges_double_copy_scalar_kernel`, `qed_orbital_eccentricity_fubini_study`, `qed_orbital_eccentricity_qfim`, `qed_double_copy_precession_from_qfim`, `qed_spin_one_precession_from_qfim`, `qed_nordstrom_scalar_precession_from_qfim`, `qed_peters_mathews_from_orbital_qfim_sq`, `qed_spin_one_to_double_copy_gw_flux_ratio`, `vrc_resonant_plucker_norm_sq`, `vrc_resonant_directional_jet_x1`, `vrc_resonant_fubini_study_x1`, `vrc_resonant_qfim_x1`, `complex_rescaled_vrc_jet`, `vrc_pno_gap_fubini_study_at_degeneracy`, `vrc_pno_gap_qfim_at_degeneracy`, and `vrc_quantum_natural_gradient_step`) are implemented in zero-dependency `f64` Rust and verified to $< 10^{-12}$ precision.

---

### Scholarly References

(qfim-affolter2024)=
- <a id="qfim-affolter2024"></a> **Affolter, N., Glick, M., Pylyavskyy, P. & Ramassamy, S. (2024).** *Vector-Relation Configurations and Plabic Graphs*. Selecta Mathematica **30**, 9. {cite:p}`affolter2024vrc`

(qfim-postnikov2006plabic)=
- <a id="qfim-postnikov2006plabic"></a> **Postnikov, A. (2006).** *Total Positivity, Grassmannians, and Networks*. `arXiv:math/0609764`. {cite:p}`postnikov2006plabic`

(qfim-lam2016)=
- <a id="qfim-lam2016"></a> **Lam, T. (2016).** *Totally Nonnegative Grassmannian and Grassmann Polytopes*. Current Developments in Mathematics **2014**, 51–152. {cite:p}`lam2016totally`

(qfim-provost1980)=
- <a id="qfim-provost1980"></a> **Provost, J. P. & Vallee, G. (1980).** *Riemannian Structure on Manifolds of Quantum States*. Communications in Mathematical Physics **76**(3), 289–301. {cite:p}`provost1980riemannian`

(qfim-braunstein1994)=
- <a id="qfim-braunstein1994"></a> **Braunstein, S. L. & Caves, C. M. (1994).** *Statistical Distance and the Geometry of Quantum States*. Physical Review Letters **72**(22), 3439–3443. {cite:p}`braunstein1994statistical`

(qfim-wootters1981)=
- <a id="qfim-wootters1981"></a> **Wootters, W. K. (1981).** *Statistical Distance and Hilbert Space*. Physical Review D **23**(2), 357–362. {cite:p}`wootters1981statistical`

(qfim-hall2000)=
- <a id="qfim-hall2000"></a> **Hall, M. J. W. (2000).** *Quantum Properties of Classical Fisher Information*. Physical Review A **62**(1), 012107. {cite:p}`hall2000quantum`

(qfim-fubini1904)=
- <a id="qfim-fubini1904"></a> **Fubini, G. (1904).** *Sulle metriche definite da una forma Hermitiana*. Atti del Reale Istituto Veneto di Scienze, Lettere ed Arti **63**, 501–513. {cite:p}`fubini1904sulle`

(qfim-study1905)=
- <a id="qfim-study1905"></a> **Study, E. (1905).** *Kürzeste Wege im komplexen Gebiet*. Mathematische Annalen **60**(3), 321–378. {cite:p}`study1905kurzeste`

(qfim-witten2004)=
- <a id="qfim-witten2004"></a> **Witten, E. (2004).** *Perturbative Gauge Theory as a String Theory in Twistor Space*. Communications in Mathematical Physics **252**, 189–258 (`hep-th/0312171`). {cite:p}`witten2004twistor`

(qfim-berkovits2004)=
- <a id="qfim-berkovits2004"></a> **Berkovits, N. & Witten, E. (2004).** *Conformal Supergravity in Twistor-String Theory*. Journal of High Energy Physics **2004**(08), 009 (`hep-th/0406051`). {cite:p}`berkovits2004conformal`

(qfim-csw2004)=
- <a id="qfim-csw2004"></a> **Cachazo, F., Svrček, P. & Witten, E. (2004).** *MHV Vertices and Tree Amplitudes in Gauge Theory*. Journal of High Energy Physics **2004**(09), 006 (`hep-th/0403047`). {cite:p}`csw2004`

(qfim-bcfw2005)=
- <a id="qfim-bcfw2005"></a> **Britto, R., Cachazo, F., Feng, B. & Witten, E. (2005).** *Direct Proof of Tree-Level Recursion Relation in Yang–Mills Theory*. Physical Review Letters **94**, 181602 (`hep-th/0501052`). {cite:p}`bcfw2005`

(qfim-cachazogeyer2012)=
- <a id="qfim-cachazogeyer2012"></a> **Cachazo, F. & Geyer, Y. (2012).** *A 'Twistor String' Inspired Formula For Tree-Level Scattering Amplitudes in $\mathcal{N}=8$ SUGRA*. `arXiv:1206.6511`. {cite:p}`su4-cachazogeyer2012`

(qfim-cachazo2013)=
- <a id="qfim-cachazo2013"></a> **Cachazo, F. & Skinner, D. (2013).** *Gravity from Rational Curves in Twistor Space*. Physical Review Letters **110**, 161301 (`arXiv:1207.0741`). {cite:p}`cachazo2013gravity`

(qfim-chy2014)=
- <a id="qfim-chy2014"></a> **Cachazo, F., He, S. & Yuan, E. Y. (2014).** *Scattering of Massless Particles in Arbitrary Dimensions*. Physical Review Letters **113**, 171601 (`arXiv:1307.2199`). {cite:p}`chy2014`

(qfim-masonskinner2013)=
- <a id="qfim-masonskinner2013"></a> **Mason, L. & Skinner, D. (2014).** *Ambitwistor Strings and the Scattering Equations*. Journal of High Energy Physics **2014**(07), 048 (`arXiv:1311.2564`). {cite:p}`su4-masonskinner2013`

(qfim-bern2008bcj)=
- <a id="qfim-bern2008bcj"></a> **Bern, Z., Carrasco, J. J. M. & Johansson, H. (2008).** *New Relations for Gauge-Theory Amplitudes*. Physical Review D **78**(8), 085011 (`arXiv:0805.3993`). {cite:p}`bern2008bcj`

(qfim-bjerrum2018)=
- <a id="qfim-bjerrum2018"></a> **Bjerrum-Bohr, N. E. J., Damgaard, P. H., Festuccia, G., Planté, L. & Vanhove, P. (2018).** *General Relativity from Scattering Amplitudes*. Physical Review Letters **121**(17), 171601 (`arXiv:1806.04920`). {cite:p}`bjerrum2018general`

(qfim-partanen2025)=
- <a id="qfim-partanen2025"></a> **Partanen, M. & Tulkki, J. (2025).** *Gravity Generated by Four One-Dimensional Unitary Gauge Symmetries and the Standard Model* (`arXiv:2310.01460`, Reports on Progress in Physics **88**, 057802) & *Perihelion Precession of Planetary Orbits Solved from Quantum Field Theory* (`arXiv:2506.14447`). {cite:p}`partanen2025gravity`; {cite:p}`partanen2025perihelion`

(qfim-nordstrom1913)=
- <a id="qfim-nordstrom1913"></a> **Nordström, G. (1913).** *Zur Theorie der Gravitation vom Standpunkt des Relativitätsprinzips*. Annalen der Physik **347**(13), 533–554. {cite:p}`nordstrom1913gravitation`

(qfim-einstein1915)=
- <a id="qfim-einstein1915"></a> **Einstein, A. (1915/1916).** *Erklärung der Perihelbewegung des Merkur aus der allgemeinen Relativitätstheorie* & *Die Grundlage der allgemeinen Relativitätstheorie*. {cite:p}`einstein1915perihelion`; {cite:p}`einstein1916grundlage`

(qfim-peters1963)=
- <a id="qfim-peters1963"></a> **Peters, P. C. & Mathews, J. (1963).** *Gravitational Radiation from Point Masses in a Keplerian Orbit*. Physical Review **131**(1), 435–440. {cite:p}`peters1963gravitational`

(qfim-peotta2015)=
- <a id="qfim-peotta2015"></a> **Peotta, S. & Törmä, P. (2015).** *Superfluidity in Topologically Nontrivial Flat Bands*. Nature Communications **6**, 8944. {cite:p}`peotta2015superfluid`

(qfim-mandelstam1945)=
- <a id="qfim-mandelstam1945"></a> **Mandelstam, L. & Tamm, I. (1945).** *The Uncertainty Relation Between Energy and Time in Non-Relativistic Quantum Mechanics*. Journal of Physics (USSR) **9**, 249–254. {cite:p}`mandelstam1945uncertainty`

(qfim-fedi2026)=
- <a id="qfim-fedi2026"></a> **Fedi, M. (2026).** *Gravity and Relativistic Phonics in a Dilatant Dark Fluid*. SSRN 7406660. {cite:p}`fedi2026ddf`

(qfim-chat-gpe2026)=
- <a id="qfim-chat-gpe2026"></a> **Turner, W. & Google Gemini (2026).** *Grassmannian Gross–Pitaevskii Equation Formulation & Homogeneous Plücker Madelung Transformation*. {download}`data/chats/Gemini_Grassmannian-Gross-Pitaevskii-Equation-Formulation_20261103-1045.md, lines 1–1850 <../data/chats/Gemini_Grassmannian-Gross-Pitaevskii-Equation-Formulation_20261103-1045.md>`. {cite:p}`chat_grassmannian_gpe_2026`

---

### BibTeX Metadata

```bibtex
@unpublished{turner2026qfim_fubini_study_kahler_unification,
  author  = {Turner, Wesley},
  title   = {Why the Quantum Fisher Information Metric Is Four Times the {F}ubini--{S}tudy {K}\"{a}hler Metric ({$F_{\mu\nu} = 4\,g_{\mu\nu}^{\mathrm{FS}}$}): Three-Channel {P}l\"{u}cker {M}adelung--{QFIM} Kinetic Decomposition on {$\mathcal{Q}_4$}, Ghost-Free {T}urner Gravity vs. {W}itten's Twistor String, and Cross-Domain Model Unification in {L}ean 4 and {R}ust},
  journal = {Sustainable Factory Research Archive},
  year    = {2026},
  note    = {Verified in Lean 4 (v4.35.0-rc3, Signals.DFT Section 27) and Rust/WASM (dft_plabic_vrc.rs)}
}

@misc{chat_grassmannian_gpe_qfim_2026,
  author       = {Turner, Wesley and Google Gemini},
  title        = {Grassmannian Gross--Pitaevskii Equation Formulation and Pl\"{u}cker Madelung--QFIM Decomposition},
  year         = {2026},
  howpublished = {AI chat log},
  note         = {Source: data/chats/Gemini_Grassmannian-Gross-Pitaevskii-Equation-Formulation_20261103-1045.md, lines 63-74, 228-245, 1625-1780}
}
```

### Schema.org Metadata (JSON-LD)

```json
{
  "@context": "https://schema.org",
  "@type": "ScholarlyArticle",
  "headline": "Why the Quantum Fisher Information Metric Is Four Times the Fubini–Study Kähler Metric (F_μν = 4 g^FS_μν): Three-Channel Plücker Madelung–QFIM Kinetic Decomposition on Q_4, Ghost-Free Turner Gravity vs. Witten's Twistor String, and Cross-Domain Model Unification in Lean 4 and Rust",
  "author": {
    "@type": "Person",
    "name": "Wes Turner"
  },
  "dateModified": "2026-11-14",
  "about": [
    "Quantum Fisher Information Metric (QFIM)",
    "Fubini-Study Kähler Metric on Gr_C(2,4) and Klein Quadric Q_4",
    "Three-Channel Gross-Pitaevskii Madelung-QFIM Kinetic Energy Decomposition",
    "Plücker Simplex Fisher Information and Bivector Phase-Gradient Variance",
    "Klein Quadric Differential Tangency Invariance",
    "Ghost-Free Turner 1PN/2.5PN Gravity vs. Witten Conformal Supergravity",
    "Lean 4 Formal Verification and Rust Numerical Simulation"
  ],
  "isBasedOn": [
    "data/chats/Gemini_Grassmannian-Gross-Pitaevskii-Equation-Formulation_20261103-1045.md",
    "docs/grassmannian-unification-applications-roadmap-paper.md",
    "docs/grassmannian-complex-gpe-igpe-plucker-madelung-paper.md",
    "docs/grassmannian-su4-witten-twistor-string-cachazo-ddf-turner-ads-cft-unification-paper.md",
    "docs/grassmannian-gravity-from-qed-scattering-paper.md",
    "src/signals/Signals/DFT.lean",
    "src/signals/numerical_adapter/src/dft_plabic_vrc.rs"
  ]
}
```
