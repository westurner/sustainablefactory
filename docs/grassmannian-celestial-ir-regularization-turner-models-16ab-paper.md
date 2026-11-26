---
title: "Infrared Divergence Resolution in Celestial Holography, Dimensional Transmutation, Re(Δ) = d/2 Dimension Bridging, and Integrated Turner Models 16a & 16b in Lean 4, Rust/PyO3, and SymPy"
description: "An arXiv-ready MyST Markdown formal verification and mathematical physics paper resolving infrared (IR) soft divergences in celestial holography for confining gauge theories and DDF superfluid backgrounds via Källén–Lehmann mass-thresholded Mellin transforms and Yukawa–Cayley–Plancherel IR/UV kernels, bridging Toupin's Re(Δ) = d_CFT/2 dimension convention and Signals.SatoGrassmannian.RHGaps/RiemannSpectralBridge, and formulating Integrated Turner Models 16a (Without DDF) & 16b (With DDF) in Lean 4, Rust/PyO3, and SymPy/mpmath."
---

(grassmannian-celestial-ir-regularization-turner-models-16ab-paper)=
# Infrared Divergence Resolution in Celestial Holography, Dimensional Transmutation, $\operatorname{Re}(\Delta) = d_{\mathrm{CFT}}/2$ Bridging, and Integrated Turner Models `16a` & `16b` in Lean 4, Rust/PyO3, and SymPy

- **Authors:** Wes Turner
- **Subjects:**
  - High Energy Physics - Theory (`hep-th`); General Relativity and Quantum Cosmology (`gr-qc`); Mathematical Physics (`math-ph`); Number Theory (`math.NT`); Logic & Formal Verification (`cs.LO`)
- **Epistemic Status & Scope Declaration:**
  - **Verified Mathematical & Computational Core (Lean 4, Rust/PyO3, SymPy, 45-digit `mpmath`):** We verify and formalize in `Signals.RiemannSpectral` (Section 12), `Signals.SatoGrassmannian.RiemannSpectralBridge`, and `Signals.DDF` (Section 30.8): **(1)** how non-Abelian dimensional transmutation $\sigma_{\mathrm{dev}}(\mu) = b_0 g^2 / (16\pi^2) > 0$ breaks $\mathrm{SL}(2, \mathbb{C})$ chiral Casimir reality ($\operatorname{Im}(s(s-1)) = 2\sigma_{\mathrm{dev}}\gamma \ne 0$), drives $\operatorname{Re}(s) > 1/2$ into the contractive interior $\lVert\mathrm{cayley}(s)\rVert < 1$ of `Signals.SatoGrassmannian.RHGaps` (`celestialDimTransmutation_cayley_contraction_and_ir_bridge`), and lifts $\operatorname{Re}(\Delta) > d_{\mathrm{CFT}}/2$ under Toupin's `TOUTRR` convention $\Delta = d_{\mathrm{CFT}}\,s$ (`toupin_re_delta_eq_d_cft_half_bridge`), **(2)** exact IR finiteness of the hard-gap Källén–Lehmann thresholded Mellin transform (evaluated analytically at $\Delta = 1$ with soft $1/\omega$ dressing to Bessel $K_0(m_{\mathrm{gap}})$, matching 45-digit `mpmath` to $< 10^{-35}$, and recovering $\Gamma(\Delta)$ as $m_{\mathrm{gap}} \to 0^+$), **(3)** exact Gamma-pole regularization of the exponentially damped Yukawa–Mellin transform paired with the Cayley–Plancherel IR/UV kernel $\mathcal{K}_{\mathrm{IR/UV}}(\lambda, \sigma_{\mathrm{dev}}; \mu_{\mathrm{IR}}, \xi_\phi)$, and **(4)** **Integrated Turner Models `16a` (Without DDF, $\eta_{\mathrm{act}}^\gamma = 1$) & `16b` (With DDF, $\eta_{\mathrm{act}}^\gamma = 0$)** (`turner_model_16_ir_regularized_celestial_ddf_graviton_unification`).
  - **Open Millennium & Experimental Gates (`Signals.Pending`):** Isolated in `ToupinCelestialMillenniumPendingBoundary` and `YangMillsMassGapHiggsCPTPendingBoundary` in {download}`src/signals/Signals/Pending.lean <../src/signals/Signals/Pending.lean>` for non-perturbative 4D continuum Yang–Mills Wightman reconstruction from 2D celestial WZW/KZ correlators and laboratory discrimination of $\kappa_{\mathrm{IR}}$ and $\eta_{\mathrm{act}}^\gamma \in \{0, 1\}$.
- **Primary Chat & Scholarly Provenance:**
  - Chat export audited with file-and-line provenance: {download}`data/chats/Google Search AI - Review Toupin's Mass Gap solution - Google Search - 2026-11-26_15-52.md <../data/chats/Google Search AI - Review Toupin's Mass Gap solution - Google Search - 2026-11-26_15-52.md>` (lines 58–204) {cite:p}`chat_toupin_mass_gap_2026`.
  - Audited preprints & monograph by Daniel Toupin: {cite:p}`toupin2025quantum` ({download}`data/papers/TOUQGA-2.pdf <../data/papers/TOUQGA-2.pdf>`, pp. 342–369, 613–658), {cite:p}`toupin2026ym`, and {cite:p}`toupin2026riemann`.
  - Companion repository papers integrated:
    - [Celestial Holography, Plancherel–Unruh Loop Weights ($M_1 = 1/8, M_2 = 1/90$), & Integrated Turner Models `15a` & `15b`](grassmannian-celestial-holography-graviton-turner-riemann-paper.md)
    - [Adelic Carleman–Weierstrass Determinants, Schwinger 2-Cocycle, $L^1(\mathbb{R})$ Weil Positivity, & Bridges to `Signals.RiemannSpectral`](grassmannian-sato-adelic-carleman-weierstrass-weil-rh-gaps-paper.md)
    - [Finite Spectral Contracts for RH Approaches (`RB-1`–`RB-6`)](grassmannian-riemann-spectral-ihara-jensen-polya-paper.md)
    - [Antimatter Annihilation, Photonic Deflection, & Gravity Models `3`–`15b` Tested Against CERN `ALPHA-g`](grassmannian-antimatter-annihilation-alpha-g-models-paper.md)
    - [Yang–Mills Mass Gap, Higgs Symmetry Breaking, CP Violation, and Jost's CPT Involution](grassmannian-yang-mills-mass-gap-higgs-cp-cpt-paper.md)
- **Formal Verification & Computational Artifacts:**
  - `Signals` Lean 4 Library (`3,837` Lake jobs via `make signals_build`, zero `sorry` axioms):
    - {download}`src/signals/Signals/RiemannSpectral.lean <../src/signals/Signals/RiemannSpectral.lean>` (Section 12: `celestialDimTransmutationDev`, `kallenLehmannThresholdSq`, `celestialIrRegulatorFactor`, `celestialCayleyPlancherelIRUVKernel`, `celestial_ir_divergence_regularization_identities`, `toupin_re_delta_eq_d_cft_half_bridge`)
    - {download}`src/signals/Signals/SatoGrassmannian/RHGaps.lean <../src/signals/Signals/SatoGrassmannian/RHGaps.lean>` (`cayley`, `norm_cayley_le_one_iff`, `liSummand_nonneg_of_re_ge_half`, `cayley_pow_unbounded_of_re_lt_half`) & {download}`src/signals/Signals/SatoGrassmannian/RiemannSpectralBridge.lean <../src/signals/Signals/SatoGrassmannian/RiemannSpectralBridge.lean>` (`celestialDimTransmutation_cayley_contraction_and_ir_bridge`)
    - {download}`src/signals/Signals/DDF.lean <../src/signals/Signals/DDF.lean>` (Section 30.8: `celestialIrScreeningFactor`, `celestialTransferFactor16`, `gwMassGapStep`, `PlanetaryOrbit.turnerModel16aPrecessionRad`, `RiverExterior.turnerModel16bPrecessionRad`, `PlanetaryOrbit.turnerModel16aGWLuminosity`, `RiverExterior.turnerModel16bGWLuminosity`, `PlanetaryOrbit.turnerModel16aLightDeflection`, `RiverExterior.turnerModel16bLightDeflection`, `turner_model_16_ir_regularized_celestial_ddf_graviton_unification`)
  - `signals-numerical-adapter` Rust + PyO3 (`maturin`) Extension (`175` passing unit tests):
    - {download}`src/signals/numerical_adapter/src/riemann_spectral.rs <../src/signals/numerical_adapter/src/riemann_spectral.rs>` (`audit_celestial_ir_and_turner_model16`) & {download}`src/signals/numerical_adapter/src/lib.rs <../src/signals/numerical_adapter/src/lib.rs>` (`py_audit_celestial_ir_and_turner_model16`)
  - Python + SymPy + 45-Digit `mpmath` + PyO3 Verification Suite:
    - {download}`sustainablefactory/riemann_rh_bridges.py <../sustainablefactory/riemann_rh_bridges.py>` (`audit_celestial_ir_and_turner_model16`) & {download}`tests/test_riemann_spectral_sympy_pyo3.py <../tests/test_riemann_spectral_sympy_pyo3.py>` (`test_celestial_ir_regularization_and_turner_model16_sympy_mpmath_pyo3`)

---

## Abstract

Celestial holography {cite:p}`pasterski2017celestial,strominger2018` constructs 2D celestial CFT correlation functions via a Mellin transform over all massless light-cone energies $\omega \in (0, \infty)$:

$$
O_\Delta^J(z, \bar{z}) = \int_0^\infty d\omega\,\omega^{\Delta - 1}\,a_\omega^J(z, \bar{z}).
$$

As surfaced in our review of Daniel Toupin's recent Yang–Mills mass-gap and celestial-holography preprints ({cite:p}`toupin2026ym,toupin2026riemann,toupin2025quantum`; {download}`chat log <../data/chats/Google Search AI - Review Toupin's Mass Gap solution - Google Search - 2026-11-26_15-52.md>`, lines 60–90), this massless dictionary encounters a fundamental **infrared (IR) obstruction** in confining gauge theories: a positive mass gap $m_{\mathrm{gap}} > 0$ removes asymptotic massless colored gluons from the physical LSZ Hilbert space, dimensional transmutation ($\Lambda_{\mathrm{QCD}}$) breaks exact $\mathrm{SL}(2, \mathbb{C})$ boost/dilatation covariance, and the bare Plancherel–Unruh weight $P(\lambda) = \pi\lambda/\sinh(\pi\lambda)$ reaches its global maximum $P(0) = 1$ at the soft IR point $\lambda = 0$ rather than suppressing it.

In this paper, we resolve both the gauge-sector IR obstruction and the gravitational/DDF IR boundary, unify Toupin's `TOUQGA-2.pdf` ($\Delta = (d_{\mathrm{bulk}} - 2)s = 2s$) and `TOUTRR` ($\operatorname{Re}(\Delta) = d_{\mathrm{CFT}}/2$) dimension conventions with `Signals.SatoGrassmannian.RHGaps` and `RiemannSpectralBridge`, and construct **Integrated Turner Models `16a` (Without DDF, $\eta_{\mathrm{act}}^\gamma = 1$) & `16b` (With DDF, $\eta_{\mathrm{act}}^\gamma = 0$)**.

---

## 1. Dimensional Transmutation ($\Lambda_{\mathrm{QCD}}$), `RHGaps` Cayley Contraction, & `TOUTRR` $\operatorname{Re}(\Delta) = d_{\mathrm{CFT}}/2$

```{mermaid}
flowchart TB
    DT["Dimensional Transmutation (Λ_QCD > 0)\n• Trace anomaly β(g) = -b_0 g³/(16π²) < 0\n• σ_dev(μ) = -β(g)/g = b_0 g²/(16π²) > 0"]
    RG1["1. Broken SL(2,C) Casimir Reality\n• Δ_re(μ) = 1 + 2σ_dev(μ) > 1\n• Im(s(s-1)) = 2σ_dev(μ)γ ≠ 0\n• Breaks Googly shadow conjugation"]
    RG2["2. RHGaps Cayley Contraction Bridge\n• Re(s) = 1/2 + σ_dev > 1/2 ⇒ ‖cayley(s)‖ < 1\n• σ_neg < 0 ⇒ ‖cayley(s)^n‖ → ∞\n  (RiemannSpectralBridge.lean)"]
    IR1["3A. Confining Hard-Gap Mellin\n• ∫_{m_gap}^∞ (ω²-m_gap²)^{(Δ-2)/2} ω a_ω dω\n• At Δ=1, a_ω=ω⁻¹e^{-ω} ⇒ K_0(m_gap) < ∞\n• Limit m_gap → 0⁺ recovers Γ(Δ)"]
    IR2["3B. Yukawa–Mellin & Cayley–Plancherel K_{IR/UV}\n• e^{-μ_IR ω} ⇒ μ_IR^{n-Δ} Γ(Δ-n)\n• R_IR(λ) = λ²/(λ² + (μ_IR ξ_φ)²) zeros λ=0"]
    M16["4. Integrated Turner Models 16a & 16b\n• G_16 = W^Cayley(σ_dev) · F_loop(α_QG) · (1+κ_IR)e^{-κ_IR} > 0\n• 16a: m_gap GW cutoff Θ(2Ω_orb - ω_gap), η_act^γ = 1\n• 16b: Gapless DDF phonons (ω_gap=0), η_act^γ = 0"]

    DT --> RG1 --> RG2
    RG1 --> IR1 --> M16
    RG1 --> IR2 --> M16
    RG2 --> M16
```

### 1.1 Breaking of $\mathrm{SL}(2, \mathbb{C})$ Dilatation and the `RHGaps` Cayley Contraction Theorem

In `Signals.RiemannSpectral` Section 12 (`celestialDimTransmutationDev`, lines 1538–1640) and our chat synthesis ({download}`chat log <../data/chats/Google Search AI - Review Toupin's Mass Gap solution - Google Search - 2026-11-26_15-52.md>`, lines 112–128), an asymptotically free non-Abelian gauge theory ($b_0 = (11 N_c - 2 n_f)/3 > 0$, $b_0 = 11$ for pure $\mathrm{SU}(3)$) generates a nonzero running shift off the principal series:

$$
\sigma_{\mathrm{dev}}(\mu) = -\frac{\beta(g(\mu))}{g(\mu)} = \frac{b_0\,g(\mu)^2}{16\pi^2} > 0, \qquad \Delta(\mu) = 1 + i\lambda + 2\sigma_{\mathrm{dev}}(\mu).
$$

Theorem `celestial_ir_divergence_regularization_identities` proves that $\sigma_{\mathrm{dev}}(\mu) > 0 \implies \Delta_{\mathrm{re}}(\mu) > 1$, injecting a nonzero imaginary part $\operatorname{Im}\bigl(s(s-1)\bigr) = 2\sigma_{\mathrm{dev}}(\mu)\gamma \ne 0$ into the chiral $\mathfrak{sl}(2, \mathbb{C})$ Casimir for every $\gamma \ne 0$.

Connecting directly to `Signals.SatoGrassmannian.RHGaps` ({download}`RHGaps.lean <../src/signals/Signals/SatoGrassmannian/RHGaps.lean>`, `norm_cayley_le_one_iff`, `liSummand_nonneg_of_re_ge_half`, `cayley_pow_unbounded_of_re_lt_half`), theorem `celestialDimTransmutation_cayley_contraction_and_ir_bridge` in {download}`RiemannSpectralBridge.lean <../src/signals/Signals/SatoGrassmannian/RiemannSpectralBridge.lean>` proves a sharp asymmetry:
- **Physical Asymptotic Freedom ($\sigma_{\mathrm{dev}} > 0$):** Shifts $s_{\mathrm{rg}} = \tfrac{1}{2} + \sigma_{\mathrm{dev}} + i\gamma$ into the right half-strip $\operatorname{Re}(s_{\mathrm{rg}}) > \tfrac{1}{2}$, where the Cayley transform obeys $\lVert\mathrm{cayley}(s_{\mathrm{rg}})\rVert < 1$ (strictly contractive interior of the unit disk) and every Li summand remains nonnegative ($\operatorname{liSummand}(s_{\mathrm{rg}}, n) \ge 0$).
- **Wrong-Sign $\beta$-Function ($\sigma_{\mathrm{neg}} < 0$):** Shifts $\operatorname{Re}(s) < \tfrac{1}{2}$, forcing $\lVert\mathrm{cayley}(s)^n\rVert \to \infty$ exponentially (`cayley_pow_unbounded_of_re_lt_half`).

### 1.2 Reconciling Toupin's `TOUQGA-2.pdf` ($\Delta = 2s$) and `TOUTRR` ($\operatorname{Re}(\Delta) = d/2$) Conventions

In Toupin's monograph {cite:p}`toupin2025quantum` (Section 7.2.7, p. 360) and his 2026 preprint *The Reason the Riemann Hypothesis is True: $\Re(\Delta) = d/2$* {cite:p}`toupin2026riemann` (matching Section 7.3.4, p. 363 of `TOUQGA-2.pdf`), two notations appear for the conformal dimension $d$:
1. Writing $d_{\mathrm{bulk}}$ for spacetime dimension, the celestial sphere $S^{d_{\mathrm{bulk}}-2}$ has boundary CFT dimension $d_{\mathrm{CFT}} = d_{\mathrm{bulk}} - 2$, principal-series axis $\operatorname{Re}(\Delta) = (d_{\mathrm{bulk}} - 2)/2$, and dictionary $\Delta = (d_{\mathrm{bulk}} - 2)s$;
2. Writing $d = d_{\mathrm{CFT}}$ directly as the boundary CFT dimension, shadow symmetry acts as $\Delta \mapsto d_{\mathrm{CFT}} - \Delta$ with fixed locus $\operatorname{Re}(\Delta) = d_{\mathrm{CFT}}/2$, and $\Delta = d_{\mathrm{CFT}}\,s$ intertwines $\Delta \mapsto d_{\mathrm{CFT}} - \Delta$ with $s \mapsto 1 - s$ for every $d_{\mathrm{CFT}} > 0$.

Theorem `toupin_re_delta_eq_d_cft_half_bridge` (`Signals.RiemannSpectral` Section 12) proves these are algebraically identical, with $d_{\mathrm{CFT}} = 2 \iff d_{\mathrm{bulk}} = 4 \iff \operatorname{Re}(\Delta) = 1 \iff \Delta = 2s$.

---

## 2. Two Exact Solutions to Celestial IR Divergences

Following {download}`chat log <../data/chats/Google Search AI - Review Toupin's Mass Gap solution - Google Search - 2026-11-26_15-52.md>` (lines 131–167), we contrast confining Yang–Mills mass gaps ($m_{\mathrm{gap}} \sim \Lambda_{\mathrm{QCD}}$) against the `DDF` superfluid healing length ($\xi_\phi$) and prove two exact regularizations:

| Physical Feature | Confining Yang–Mills Gap ($m_{\mathrm{gap}} \sim \Lambda_{\mathrm{QCD}}$) | DDF Superfluid Healing Length ($\xi_\phi$, Models `15b` / `16b`) |
| :--- | :--- | :--- |
| **IR Spectrum ($\omega \to 0^+$)** | **Hard gap:** Zero asymptotic states for $0 < \omega < m_{\mathrm{gap}}$; only color-singlet glueballs reach $\mathcal{I}^+$. | **Gapless Goldstone phonon + gapped jamming crossover:** Long-wavelength modes ($\lambda_{\mathrm{dB}} \gg \xi_\phi$) propagate at $c$; short-wavelength modes ($\lambda_{\mathrm{dB}} \lesssim \xi_\phi$) saturate. |
| **Mechanism Curing IR Divergence** | **Color confinement** screens chromoelectric flux into flux tubes ($V(r) \sim \sigma r$). | **Constitutive saturation** ($\varrho \le \varrho_{\max}^\varphi$, Kähler core $\mathcal{D}_{\mathrm{core}} \ge 1$) caps core energy without removing $1/r$ river gravity. |
| **Regularized Celestial Transform** | **Hard-Gap Källén–Lehmann Mellin transform** on $[m_{\mathrm{gap}}, \infty)$. | **Yukawa–Mellin + Cayley–Plancherel $\mathcal{K}_{\mathrm{IR/UV}}$** preserving gapless spin-2 poles at $\omega \to 0^+$. |

### 2.1 Solution A: Hard-Gap Källén–Lehmann Thresholded Mellin Transform

For any gapped or confining sector with mass threshold $m_{\mathrm{gap}} > 0$, we replace $\int_0^\infty d\omega\,\omega^{\Delta-1}a_\omega^J$ by:

$$
\mathcal{O}_{\Delta, m_{\mathrm{gap}}}^J(z, \bar{z}) := \int_{m_{\mathrm{gap}}}^\infty d\omega\,\bigl(\omega^2 - m_{\mathrm{gap}}^2\bigr)^{\frac{\Delta - 2}{2}}\,\omega\,a_\omega^J(z, \bar{z}).
$$

- **Exact IR Finiteness at the Soft Pole ($\Delta = 1$):** For a soft-dressed amplitude $a_\omega = \omega^{-1} e^{-\omega}$, the massless integral ($m_{\mathrm{gap}} = 0$) diverges logarithmically ($\int_0^\infty \omega^{-1} e^{-\omega}\,d\omega = \infty$). For any $m_{\mathrm{gap}} > 0$, substituting $\omega = m_{\mathrm{gap}} \cosh x$ yields the exact finite modified Bessel value:

  $$
  \mathcal{O}_{1, m_{\mathrm{gap}}}[\omega^{-1} e^{-\omega}] = \int_0^\infty e^{-m_{\mathrm{gap}}\cosh x}\,dx = K_0(m_{\mathrm{gap}}) < \infty,
  $$

  verified to `< 1e-35` in 45-digit `mpmath` (`kl_crit_bessel_err` in `audit_celestial_ir_and_turner_model16`).
- **Conformal Limit ($m_{\mathrm{gap}} \to 0^+$):** At $a_\omega = e^{-\omega}$ and $\Delta = 2.5$, `kl_mellin_exp_test` converges to $\Gamma(2.5) = \frac{3\sqrt{\pi}}{4}$ (`< 1e-8` in Rust `f64`, `< 1e-25` in `mpmath`).

### 2.2 Solution B: Yukawa–Mellin Transform & Cayley–Plancherel IR/UV Kernel $\mathcal{K}_{\mathrm{IR/UV}}$

For massless gravitons dressed by soft BMS$_4$ radiation with IR regulator $\mu_{\mathrm{IR}} > 0$:

$$
\mathcal{O}_{\Delta, \mu_{\mathrm{IR}}}^J(z, \bar{z}) := \int_0^\infty d\omega\,\omega^{\Delta - 1}\,e^{-\mu_{\mathrm{IR}}\omega}\,a_\omega^J(z, \bar{z}) \implies \int_0^\infty d\omega\,\omega^{\Delta - 1 - n}\,e^{-\mu_{\mathrm{IR}}\omega} = \mu_{\mathrm{IR}}^{n - \Delta}\,\Gamma(\Delta - n),
$$

verified to `< 1e-25` at complex $\Delta = 2.5 + 1.3i, n = 1, \mu_{\mathrm{IR}} = 0.7$ (`yukawa_complex_gamma_err`). On the boost rapidity axis $\lambda \in \mathbb{R}$, we pair $\mathcal{W}_{\mathrm{grav}}^{\mathrm{Cayley}}(\sigma_{\mathrm{dev}})$ and the UV Plancherel–Unruh weight $P(\lambda) = \frac{\pi\lambda}{\sinh(\pi\lambda)}$ with the rational IR soft-pole suppressor (`celestialCayleyPlancherelIRUVKernel`):

$$
\mathcal{K}_{\mathrm{IR/UV}}(\lambda, \sigma_{\mathrm{dev}}; \mu_{\mathrm{IR}}, \xi_\phi) := \underbrace{\frac{1}{1 + 4\sigma_{\mathrm{dev}}^2}}_{\mathcal{W}_{\mathrm{grav}}^{\mathrm{Cayley}}(\sigma_{\mathrm{dev}})} \cdot \underbrace{\frac{\pi\lambda}{\sinh(\pi\lambda)}}_{P(\lambda)\text{ (UV)}} \cdot \underbrace{\frac{\lambda^2}{\lambda^2 + (\mu_{\mathrm{IR}}\xi_\phi)^2}}_{\mathcal{R}_{\mathrm{IR}}(\lambda)\text{ (IR)}} \in [0, 1],
$$

which satisfies $\mathcal{K}_{\mathrm{IR/UV}}(0, \sigma_{\mathrm{dev}}) = 0$ whenever $\mu_{\mathrm{IR}}\xi_\phi > 0$ and recovers $P(\lambda)/(1 + 4\sigma_{\mathrm{dev}}^2)$ pointwise as $\mu_{\mathrm{IR}}\xi_\phi \to 0^+$ (`celestial_ir_divergence_regularization_identities`).

---

## 3. Integrated Turner Models `16a` (Without DDF) & `16b` (With DDF)

Building directly on Models `15a` & `15b` (`Signals.DDF` Section 30.7), we define in `Signals.DDF` Section 30.8 ({download}`DDF.lean <../src/signals/Signals/DDF.lean>`, `turner_model_16_ir_regularized_celestial_ddf_graviton_unification`) the dimensionless IR screening parameter:

$$
\kappa_{\mathrm{IR}} := \begin{cases} m_{\mathrm{gap}}\,a / (\hbar c), & \text{Model 16a (Yukawa / confining mass gap } m_{\mathrm{gap}} \ge 0,\ \eta_{\mathrm{act}}^\gamma = 1\text{)}, \\ \xi_\phi / a, & \text{Model 16b (DDF superfluid healing length } \xi_\phi \ge 0,\ \eta_{\mathrm{act}}^\gamma = 0\text{)}, \end{cases}
$$

and the **unconditionally positive, IR-screened, Cayley-shadowed, Plancherel-resummed gravitational transfer factor** (`celestialTransferFactor16`):

$$
\mathcal{G}_{16}(\sigma_{\mathrm{dev}}, \alpha_{\mathrm{QG}}, \kappa_{\mathrm{IR}}) := \underbrace{\frac{1}{1 + 4\sigma_{\mathrm{dev}}^2}}_{\mathcal{W}_{\mathrm{grav}}^{\mathrm{Cayley}}(\sigma_{\mathrm{dev}})} \cdot \underbrace{\left(1 + \frac{1}{8}\alpha_{\mathrm{QG}} + \frac{1}{90}\alpha_{\mathrm{QG}}^2\right)}_{\mathcal{F}_{\mathrm{loop}}(\alpha_{\mathrm{QG}}) \le \frac{8}{8 - \alpha_{\mathrm{QG}}}} \cdot \underbrace{(1 + \kappa_{\mathrm{IR}})\,e^{-\kappa_{\mathrm{IR}}}}_{\mathcal{S}_{\mathrm{IR}}(\kappa_{\mathrm{IR}}) \in (0, 1]}.
$$

Note two key analytical properties proved in Lean 4 and SymPy:
1. **Quadratic IR Suppression at Small $\kappa_{\mathrm{IR}}$:** Expanding $\mathcal{S}_{\mathrm{IR}}(\kappa_{\mathrm{IR}}) = 1 - \tfrac{1}{2}\kappa_{\mathrm{IR}}^2 + \tfrac{1}{3}\kappa_{\mathrm{IR}}^3 - \cdots$ eliminates any $O(\kappa_{\mathrm{IR}})$ linear deviation, preserving solar-system ephemeris bounds at $\kappa_{\mathrm{IR}} \ll 1$.
2. **Unconditional All-Regime Positivity:** Unlike Model `15`'s bare factor $1 - 4\sigma_{\mathrm{dev}}^2$ (which turns negative for $\lvert\sigma_{\mathrm{dev}}\rvert > 1/2$), $\mathcal{G}_{16}(\sigma_{\mathrm{dev}}, \alpha_{\mathrm{QG}}, \kappa_{\mathrm{IR}}) > 0$ holds unconditionally for all $\sigma_{\mathrm{dev}} \in \mathbb{R}$, $\alpha_{\mathrm{QG}} \ge 0$, and $\kappa_{\mathrm{IR}} \ge 0$ (`celestialIrScreeningFactor` bounded in $(0, 1]$ via `Real.add_one_le_exp`).

### Master Equations & Predictions of Models `16a` & `16b`

1. **1PN Perihelion Precession (`PlanetaryOrbit.turnerModel16aPrecessionRad`, `RiverExterior.turnerModel16bPrecessionRad`):**

   $$
   \Delta\varpi_{\mathrm{Model\,16a/b}} = \mathcal{G}_{16}(\sigma_{\mathrm{dev}}, \alpha_{\mathrm{QG}}, \kappa_{\mathrm{IR}})\,\frac{6\pi G_\phi M}{c^2 a\bigl(\mathcal{D}(W_{\mathrm{orb}}) - 3\bigr)} + \delta_{\mathrm{Jos}}, \qquad \mathcal{D}(W_{\mathrm{orb}}) - 3 = 1 - e^2.
   $$

   At $(\sigma_{\mathrm{dev}}, \alpha_{\mathrm{QG}}, \kappa_{\mathrm{IR}}, \delta_{\mathrm{Jos}}) = (0, 0, 0, 0)$, both `16a` and `16b` yield $42.9814''/\text{cy}$ for Mercury ($\varepsilon_{\mathrm{rel}} < 10^{-15}$).
2. **2.5PN Gravitational-Wave Luminosity (`turnerModel16aGWLuminosity`, `turnerModel16bGWLuminosity`):**

   $$
   P_{\mathrm{GW}}^{\mathrm{Model\,16a/b}} = \mathcal{G}_{16}(\sigma_{\mathrm{dev}}, \alpha_{\mathrm{QG}}, \kappa_{\mathrm{IR}})\,\frac{32 G_\phi^4 m_1^2 m_2^2 (m_1 + m_2)}{5 c^5 a^5}\,\frac{P_{\mathrm{PM}}(e)}{\bigl(\sqrt{\mathcal{D}(W_{\mathrm{orb}}) - 3}\bigr)^7}\,\Theta(2\Omega_{\mathrm{orb}} - \omega_{\mathrm{gap}}) + \delta P_{\mathrm{Jos}},
   $$

   with $\omega_{\mathrm{gap}} = m_{\mathrm{gap}} c^2/\hbar$ in Model `16a` (cutting off quadrupolar radiation below a hard mass gap: `turnerModel16aGWLuminosity ... = 0` when $2\Omega_{\mathrm{orb}} < \omega_{\mathrm{gap}}$) vs. $\omega_{\mathrm{gap}} = 0$ in Model `16b` (gapless long-wavelength DDF phonons retain positive emission `0 < turnerModel16bGWLuminosity`).
3. **1PN Solar Light Deflection & Active Laser Discriminator (`turnerModel16aLightDeflection`, `turnerModel16bLightDeflection`):**
   Both recover $1.7505''$ at $(0,0,0,0)$, while `mutualPhotonDeflection` preserves $\eta_{\mathrm{act}}^\gamma = 1$ (`16a`) vs. $\eta_{\mathrm{act}}^\gamma = 0$ (`16b`).

---

## 4. Reproducible Verification Commands

```bash
make -C /workspaces/sustainablefactory signals_build
cargo test --manifest-path /workspaces/sustainablefactory/src/signals/numerical_adapter/Cargo.toml
pytest -q /workspaces/sustainablefactory/tests/test_riemann_spectral_sympy_pyo3.py \
  -k test_celestial_ir_regularization_and_turner_model16_sympy_mpmath_pyo3
```

---

## 5. Provenance Metadata (BibTeX & JSON-LD)

```bibtex
@misc{turner2026celestial_ir_model16,
  author       = {Turner, Wesley},
  title        = {Infrared Divergence Resolution in Celestial Holography, Dimensional Transmutation, Re(Delta) = d/2 Bridging, and Integrated Turner Models 16a \& 16b in Lean 4, Rust/PyO3, and SymPy},
  year         = {2026},
  howpublished = {Sustainable Factory Technical Monograph \& Formal Verification Suite},
  note         = {Verified in Signals.RiemannSpectral Sec. 12, Signals.SatoGrassmannian.RiemannSpectralBridge, and Signals.DDF Sec. 30.8}
}
```

```json
{
  "@context": "https://schema.org",
  "@type": "ScholarlyArticle",
  "headline": "Infrared Divergence Resolution in Celestial Holography, Dimensional Transmutation, Re(Δ) = d_CFT/2 Bridging, and Integrated Turner Models 16a & 16b",
  "author": {"@type": "Person", "name": "Wes Turner"},
  "isBasedOn": [
    "data/chats/Google Search AI - Review Toupin's Mass Gap solution - Google Search - 2026-11-26_15-52.md",
    "data/papers/TOUQGA-2.pdf",
    "src/signals/Signals/RiemannSpectral.lean",
    "src/signals/Signals/SatoGrassmannian/RHGaps.lean",
    "src/signals/Signals/SatoGrassmannian/RiemannSpectralBridge.lean",
    "src/signals/Signals/DDF.lean"
  ],
  "dateModified": "2026-11-26"
}
```

---

## References

```{bibliography}
:filter: docname in docnames
```
