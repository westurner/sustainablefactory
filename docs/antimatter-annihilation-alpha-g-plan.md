---
title: "Written Plan: Antimatter Annihilation, Electron & Gravity Mechanics Across GR, Cachazo–Witten Twistor Strings, QED Scattering Gravity, DDF, and Turner Models 3–15b — Tested Against CERN ALPHA-g Data"
description: "Phased implementation and formal verification plan evaluating whether electron–positron and antihydrogen annihilation correspond with or contradict the electron and gravity mechanics in our papers (GR, Cachazo infinity-twistor correction to Witten's twistor string theory, QED scattering gravity, DDF, and Turner Models 3, 6, 12, 13, 14a, 14b, 15a, and 15b), tested quantitatively against CERN ALPHA-g (Nature 2023) antihydrogen free-fall data in Lean 4, Rust/PyO3, SymPy, and MyST Markdown."
---

(antimatter-annihilation-alpha-g-plan)=
# Written Plan: Antimatter Annihilation, Electron & Gravity Mechanics Across GR, Cachazo–Witten Twistor Strings, QED Scattering Gravity, DDF, and Turner Models 3–15b — Tested Against CERN `ALPHA-g` Data

- **Author:** Wes Turner
- **Planned Owning Paper:** `docs/grassmannian-antimatter-annihilation-alpha-g-models-paper.md`
- **Companion Papers Reused (Gravity, Photonic Deflection, & Electron Models):**
  - [Grassmannian Gravity from QED & Gauge Scattering Amplitudes: Complex $Gr_{\mathbb{C}}(2,4)$ Orbital Precession, Mercury's Perihelion, $N$-Body Dynamics, and Dilatant Dark Fluid (DDF) Unification](grassmannian-gravity-from-qed-scattering-paper.md) (BCJ double copy, Partanen–Tulkki $\mathrm{U}(1)^4$, Witten vs. Cachazo–Skinner, Turner Models `12` & `13`, and the $\eta_{\mathrm{act}}^\gamma \in \{0,1\}$ photon–photon active deflection discriminator)
  - [Complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ & $N$-ary $Gr_{\mathbb{C}}(2, N+2)$ Unification with Dilatant Dark Fluid (DDF) Moving Sheaths, Plücker Sink Fluxes, Anosov Invariance, and Sorkin Triple-Slit Interferometry](grassmannian-ddf-moving-sheath-paper.md) (`DDFSubstrate`, $c^{-2} = \varrho_{\max}^\varphi j_{\min}^\varphi$, `MovingSheath`, `RiverExterior`)
  - [The Holographic Principle in Complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ and Dilatant Dark Fluid (DDF) Mechanics](grassmannian-holographic-principle-paper.md) (Painlevé–Gullstrand horizon lapse $|w_A^{\mathbb{C}}|^2|w_B^{\mathbb{C}}|^2 = 1 - r_H/r$)
  - [AdS/CFT Correspondence, Planar Integrability, and Secret Symmetries in Unified Complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ and Dilatant Dark Fluid (DDF) Mechanics](grassmannian-ads-cft-ddf-paper.md) (`gr_photon_deflection_active` vs. `ddf_photon_deflection_null` active photon–photon deflection boundary)
  - [$\mathrm{SU}(4)$ Symmetry, Witten's Twistor String Theory, Lower Grassmannians in $\mathrm{Gr}_{\mathbb{R}}$ and $\mathrm{Gr}_{\mathbb{C}}$, Relative Merits of Cachazo (CSW / BCFW / Hodges / CHY) vs. DDF vs. Turner Models, and Grand Unification with the Holographic Principle and AdS/CFT](grassmannian-su4-witten-twistor-string-cachazo-ddf-turner-ads-cft-unification-paper.md)
  - [Complex Grassmannian $\mathrm{Gr}_{\mathbb{C}}(2,4)$ Fubini–Study Gross–Pitaevskii Equation, Dual-Schubert `iGPE`, and Homogeneous Plücker Madelung Hydrodynamics on the Klein Quadric $\mathcal{Q}_4$](grassmannian-complex-gpe-igpe-plucker-madelung-paper.md) (Turner Models `6`, `14a`, & `14b` and $\eta_{\mathrm{act}}^\gamma = 0$ discriminator)
  - [Celestial Holography, the Canonical Dictionary ($\Delta = 2s$), Plancherel–Unruh Graviton Loop Weights ($M_1 = 1/8, M_2 = 1/90$), and Integrated Turner Models 15a & 15b for Gravitons and Riemann Spectral Bridges](grassmannian-celestial-holography-graviton-turner-riemann-paper.md) (Integrated Turner Models `15a` & `15b`, $1.750539''$ solar light deflection, and `mutualPhotonDeflection` separation)
  - [Maxwell Electromagnetic Theory Across Pre-Tensor Quaternions, Modern Vectors (and Gimbal Lock), Relativistic Tensors, and Penrose Twistors](grassmannian-maxwell-electromagnetism-twistors-ez-oam-solitons-gravity-models-paper.md) (Multi-model solar light deflection `Sec. 3.1–3.8`, 1-loop QED Euler–Heisenberg $e^+e^-$ photon–photon scattering, active laser–laser deflection $\eta_{\mathrm{act}}^\gamma$, and soft-photon `TRUE` synthesis)
  - [Why the Quantum Fisher Information Metric Is Four Times the Fubini–Study Kähler Metric ($F_{\mu\nu} = 4\,g_{\mu\nu}^{\mathrm{FS}}$)](grassmannian-qfim-fubini-study-kahler-madelung-unification-paper.md) (Ghost-free Turner $\mathcal{Q}_4$ Kähler projection, Cachazo `CHY`/`Hodges` QFIM, and QED orbital QFIM light bending)
  - [Unification, Engineering Applications, and Research Roadmap of Complex Grassmannian $Gr_{\mathbb{C}}(2,4)$, $Gr_{\mathbb{C}}(2,6)$, and Dilatant Dark Fluid (DDF) Mechanics](grassmannian-unification-applications-roadmap-paper.md) (Cross-corpus synthesis and laboratory crossed-laser discriminator)
  - [$\mathrm{ER}=\mathrm{EPR}$ in Witten's $\mathrm{SU}(4)$ Twistor Theory and Plücker Coordinates on $\mathrm{Gr}_{\mathbb{C}}(2,4)$](grassmannian-er-epr-witten-su4-plucker-tachyons-semi-dirac-paper.md)
  - [The Photoelectric Effect Reimagined: From Einstein's Quanta to `QCI-GXC` Electronic Density, Twistor Longitudinal $E_z$ & OAM Light, Strong-Field Keldysh Tunneling, `AKNS` Solitons, and `QFIM` $= 4\,g^{\mathrm{FS}}$](grassmannian-photoelectric-effect-qci-gxc-twistors-solitons-qfim-paper.md)

---

## 1. Scientific Questions & Core Diagnostic Thesis

This plan addresses two coupled questions:

1. **Correspondence vs. Contradiction Question:**
   Does antimatter annihilation ($e^- + e^+ \to 2\gamma / 3\gamma$ and $\bar{\mathrm{H}} \to \pi^\pm/\pi^0/e^+e^-$) **correspond with** or **contradict** the electron and gravity mechanics formalized across our corpus?
   - **Einstein General Relativity ($\gamma_{\mathrm{PPN}} = 1, \beta_{\mathrm{PPN}} = 1$):** **Corresponds.** Universal stress-energy coupling $G_{\mu\nu} = \frac{8\pi G}{c^4} T_{\mu\nu}$ guarantees both Weak Equivalence Principle (`WEP`) downward fall $a_{\bar{g}} = +1\,g_0$ for antihydrogen $\bar{\mathrm{H}}$ and exact conservation of active gravitational mass-energy across $e^- + e^+ \to 2\gamma$ ($\eta_{\mathrm{act}}^\gamma = 1$), even though the 4D electromagnetic stress trace vanishes ($T^\mu{}_\mu(d=4) = 0$).
   - **Raw Witten (2004) Twistor String vs. Cachazo–Skinner (2012) Infinity-Twistor Correction:**
     - **Raw Witten (2004) Conformal Supergravity ($\pi_I = 0$):** **Contradicted.** Its $1/q^4$ propagator carries negative-norm Ostrogradsky ghosts that break optical-theorem unitarity in $e^- e^+ \to 2\gamma$ / graviton loops, its scale-free limit ($\beta_{\mathrm{scale}} = 0$) yields $a_{\bar{g}} = 0$ (rejected by `ALPHA-g` at $> 3.6\sigma$), and its linear Rindler term $+\frac{1}{2}\gamma_{\mathrm{conf}} c^2 r$ induces an unphysical vertical offset $-\frac{1}{2}\gamma_{\mathrm{conf}} c^2$ unless $|\gamma_{\mathrm{conf}}| \ll 10^{-17}\text{ m}^{-1}$.
     - **Cachazo–Skinner ($\pi_I = 1, \Lambda_{\mathrm{cc}} = 0$) + `CHY` / `BCFW`:** **Corresponds.** Breaking conformal symmetry via the rank-2 infinity twistor $I_{AB}$ projects out the $C_{\mu\nu\rho\sigma}^2$ Weyl ghosts, restores $1/q^2$ unitary crossing symmetry on $\mathrm{Gr}_{\mathbb{C}}(2,4)$ between Compton scattering $e^-\gamma \to e^-\gamma$ and pair annihilation $e^- e^+ \to 2\gamma$, predicts $a_{\bar{g}} = +1\,g_0$, and preserves $\eta_{\mathrm{act}}^\gamma = 1$.
   - **QED Scattering Gravity (`BCJ` Double Copy & Partanen–Tulkki 2025 $\mathrm{U}(1)^4$ QFT):** **Corresponds.** Pair annihilation $e^- e^+ \to 2\gamma$ is the native crossing channel of QED scattering; Partanen–Tulkki's 8-spinor $\mathrm{U}(1)^4$ QFT explicitly unifies Dirac $e^\pm$ spinors with a spin-2 emergent field ($\eta_{\mathrm{act}}^\gamma = 1$, $a_{\bar{g}} = +1\,g_0$). By contrast, **Nordström scalar gravity** ($\gamma_{\mathrm{PPN}} = -1$) **contradicts** mass-energy conservation across $e^- e^+ \to 2\gamma$ because $T^\mu{}_\mu$ drops from $2 m_e c^2 > 0$ to $0$, and **repulsive spin-1 vector gravity** ($q_g(\bar{\mathrm{H}}) = -q_g(\mathrm{H})$) predicts $a_{\bar{g}} = -1\,g_0$ (ruled out by `ALPHA-g` at $> 8\sigma$).
   - **Dilatant Dark Fluid (`DDF`: Fedi 2016 `SQG`, Fedi 2017 Dark Superfluid, Fedi 2026 `DDF`):** **Split verdict (corresponds on passive `ALPHA-g` fall if $m_g = +m_i > 0$, but creates a sharp tension/contradiction on active gravity after annihilation):**
     1. *Passive free fall (`ALPHA-g`):* Because `DDF` reversible jamming energy $K_D(v) = m c^2(\gamma_\varphi(v) - 1)$ and Bernoulli enthalpy $\Phi_\phi(r) = -G_\phi M_\oplus / r$ depend on positive inertial mass $m > 0$ independent of charge conjugation, conservative `DDF` predicts $a_{\bar{g}} = +1\,g_0$, **corresponding** with `ALPHA-g`. Conversely, any speculative "antimatter = fluid anti-sink" hypothesis ($m_g = -m_i \implies a_{\bar{g}} = -1\,g_0$) is **contradicted and falsified at $> 8\sigma$** by `ALPHA-g`.
     2. *Active gravity across $e^- + e^+ \to 2\gamma$ ($\eta_{\mathrm{act}}^\gamma = 0$):* **Sharp theoretical tension / contradiction** if $\eta_{\mathrm{act}}^\gamma = 0$ holds strictly without photon–substrate backreaction: converting two massive $\phi$-sinks ($2 m_e > 0$) into two pure $\varphi$-shear phonons drops the active gravitational mass of an isolated cavity from $2 m_e$ to $0$ ($\Delta M_{\mathrm{act}} = -2 m_e \neq 0$), contradicting ADM energy–gravity conservation and radiation-era Friedmann sourcing unless nonlinear $\varphi$-to-$\phi$ cavity coupling restores $\eta_{\mathrm{act}}^\gamma = 1$ in trapped/confined regimes. Moreover, naive non-relativistic `GPE` particle-number conservation must be promoted to crossing-symmetric Fock/Dual-Grassmannian channels.
   - **Each Turner (2026) Model:**
     - **Model 3 ($\mathrm{Gr}_{\mathbb{C}}(2,4)$ Crossing-Minor Superposition) & Model 6 ($\mathcal{Q}_4$ Plücker Madelung & Dual-`iGPE`):** **Correspond** for coherent matter/antimatter wavepacket interference and `ALPHA-g` escape-fraction probability modeling ($\varepsilon_{\mathrm{rel}} = 0$ vs. $50\%$ error in unphased $\mathrm{Gr}_{\ge 0}(2,4)$), provided pair annihilation $e^- e^+ \to 2\gamma$ is modeled as a two-channel Fock/Dual-Grassmannian transition rather than static single-particle norm preservation.
     - **Model 12 ($\mathrm{Gr}_{\mathbb{C}}(2,4)$ `BCJ` + 1-Loop PM QFT + 3D Splats, No DDF):** **Corresponds fully** ($a_{\bar{g}} = +1\,g_0$, $\eta_{\mathrm{act}}^\gamma = 1$, crossing symmetry preserved).
     - **Model 13 ($\mathrm{Gr}_{\mathbb{C}}(2,4)$ + Conservative DDF + 3D Splats):** **Corresponds on `ALPHA-g`** ($a_{\bar{g}} = +1\,g_0$ for positive-inertia $\bar{\mathrm{H}}$), but **inherits the `DDF` $\eta_{\mathrm{act}}^\gamma = 0$ active-gravity tension** across $e^- e^+ \to 2\gamma$.
     - **Model 14a ($\mathcal{Q}_4$ Kähler + Dual-`iGPE`, No DDF):** **Corresponds fully** ($a_{\bar{g}} = +1\,g_0$ at $\delta_{\mathrm{Jos}} = 0$, $\eta_{\mathrm{act}}^\gamma = 1$, and Dual-Schubert CPT/Jost symmetry $s_{\mathrm{dual}} = s_{\mathrm{real}}$).
     - **Model 14b ($\mathcal{Q}_4$ Kähler + Dual-`iGPE` + DDF):** **Corresponds on `ALPHA-g`** ($a_{\bar{g}} = +1\,g_0$ at $\delta_{\mathrm{Jos}} = 0$), **inherits the $\eta_{\mathrm{act}}^\gamma = 0$ active-gravity tension** across $e^- e^+ \to 2\gamma$.
     - **Integrated Model 15a (Celestial $O_\Delta^{\pm 2}$ + $\mathcal{Q}_4$ Kähler + Plancherel–Unruh Loops, No DDF):** **Corresponds fully** (boundary Jost/CPT involution $\Theta|_{\mathcal{I}} = T \implies \sigma_{\mathrm{dev}} = 0 \implies \mathcal{W}_{\mathrm{grav}}(0) = 1$, $\eta_{\mathrm{act}}^\gamma = 1$, negligible Plancherel loop term at `ALPHA-g` energy $(E/M_P)^2 \sim 10^{-38}$, $a_{\bar{g}} = +1\,g_0$).
     - **Integrated Model 15b (Celestial $O_\Delta^{\pm 2}$ + $\mathcal{Q}_4$ Kähler + Plancherel–Unruh Loops + DDF):** **Corresponds on `ALPHA-g`** ($a_{\bar{g}} = +1\,g_0$), **inherits the $\eta_{\mathrm{act}}^\gamma = 0$ active-gravity tension** across $e^- e^+ \to 2\gamma$.

2. **Experimental Test With CERN `ALPHA-g` Data (Anderson et al., *Nature* 621, 716–722, 2023):**
   - Benchmark every model above against the published CERN `ALPHA-g` result:

     $$
     a_{\bar{g}} / g_0 = 0.75 \pm 0.13\,(\mathrm{stat.}+\mathrm{syst.}) \pm 0.16\,(\mathrm{sim.}) \implies \sigma_{\mathrm{tot}} = \sqrt{0.13^2 + 0.16^2} \approx 0.2062\,g_0,
     $$

     computing exact $z$-scores, $\chi^2$, $p$-values, and parameter bounds (on Witten $\gamma_{\mathrm{conf}}$, DDF Stokes drag $\eta_{\mathrm{drag}}$, and Dual-Schubert $\delta_{\mathrm{Jos}}^{\bar{\mathrm{H}}}$), alongside a calibrated 7-point bias-scan trap-escape forward curve $P_{\mathrm{down}}(b; a_{\bar{g}}) = \bigl(1 + \exp(-(b + a_{\bar{g}}/g_0)/\sigma_b)\bigr)^{-1}$ anchored to $P_{\mathrm{down}}(0; +1g_0) \approx 0.80$ vs. `0.50` (`0g`) and `0.20` (`-1g`).

3. **Photonic Deflection Bridge (Passive Solar Lensing vs. Active Photon–Photon Beam Deflection $\eta_{\mathrm{act}}^\gamma \in \{0, 1\}$):**
   - Connect our `ALPHA-g` and $e^- + e^+ \to 2\gamma$ active-mass audit directly to the two photonic-deflection regimes developed across our `docs/grass*.md` papers:
     1. *Passive gravitational lensing in a baryonic mass field* (`gravitationalLightDeflectionPPN`, `wittenConformalLightDeflection`, `cachazoSkinnerLightDeflection`, `ddfRefractiveLightDeflection`, `turnerPluckerKahlerLightDeflection`, `turnerDualGr24IGPEDDFLightDeflection`, `PlanetaryOrbit.turnerCelestialPluckerGravitonLightDeflection`, `RiverExterior.turnerCelestialDualGr24DDFGravitonLightDeflection` in [grassmannian-maxwell-electromagnetism-twistors-ez-oam-solitons-gravity-models-paper.md](grassmannian-maxwell-electromagnetism-twistors-ez-oam-solitons-gravity-models-paper.md), [grassmannian-qfim-fubini-study-kahler-madelung-unification-paper.md](grassmannian-qfim-fubini-study-kahler-madelung-unification-paper.md), and [grassmannian-celestial-holography-graviton-turner-riemann-paper.md](grassmannian-celestial-holography-graviton-turner-riemann-paper.md)): recovers $\Delta\theta_{\mathrm{GR}} = \frac{4GM}{c^2 b} \approx 1.7505''$ at $\varepsilon_{\mathrm{rel}} = 0$ for GR, Cachazo–Skinner ($\pi_I = 1$), QED double copy / Partanen–Tulkki $\mathrm{U}(1)^4$, DDF ($c^{-2} = \varrho_{\max}^\varphi j_{\min}^\varphi$), and Turner Models `12`–`15b`, while rejecting Newtonian/spin-1 ($50\%$ error), Nordström scalar ($100\%$ error via `maxwellStressEnergyTraceInDim 4 = 0`), and unbroken Witten conformal string ($\pi_I = 0$).
     2. *Active photon–photon gravitational deflection* (`Signals.DDF.ActiveRadiationSourcing`, `mutualPhotonDeflection`, `gr_photon_deflection_active` vs. `ddf_photon_deflection_null` in [grassmannian-gravity-from-qed-scattering-paper.md](grassmannian-gravity-from-qed-scattering-paper.md), [grassmannian-ads-cft-ddf-paper.md](grassmannian-ads-cft-ddf-paper.md), [grassmannian-su4-witten-twistor-string-cachazo-ddf-turner-ads-cft-unification-paper.md](grassmannian-su4-witten-twistor-string-cachazo-ddf-turner-ads-cft-unification-paper.md), [grassmannian-complex-gpe-igpe-plucker-madelung-paper.md](grassmannian-complex-gpe-igpe-plucker-madelung-paper.md), [grassmannian-maxwell-electromagnetism-twistors-ez-oam-solitons-gravity-models-paper.md](grassmannian-maxwell-electromagnetism-twistors-ez-oam-solitons-gravity-models-paper.md), [grassmannian-celestial-holography-graviton-turner-riemann-paper.md](grassmannian-celestial-holography-graviton-turner-riemann-paper.md), and [grassmannian-unification-applications-roadmap-paper.md](grassmannian-unification-applications-roadmap-paper.md)): prove in `Signals.AntimatterGravity` that the exact same active sourcing parameter $\eta_{\mathrm{act}}^\gamma \in \{0, 1\}$ governs both mutual crossed-laser deflection $\alpha_{1\leftarrow 2} = \eta_{\mathrm{act}}^\gamma \frac{\mathcal{K} G E_{\mathrm{beam}}}{c^4 b}$ and active gravitational mass conservation across $e^- + e^+ \to 2\gamma$, separating Models `12`/`14a`/`15a` ($\eta_{\mathrm{act}}^\gamma = 1 \implies \Delta M_{\mathrm{act}} = 0$ and $\alpha_{1\leftarrow 2} > 0$) from Models `13`/`14b`/`15b` ($\eta_{\mathrm{act}}^\gamma = 0 \implies \Delta M_{\mathrm{act}} = 2 m_e$ and $\alpha_{1\leftarrow 2} = 0$), alongside the 1-loop QED Euler–Heisenberg virtual $e^+e^-$ box mechanism for non-gravitational vacuum photon–photon scattering.

---

## 2. Epistemic Scope & `Signals.Pending` Contract

All formal theorems prove mathematical, kinematic, and statistical consequences of the supplied model equations and published `ALPHA-g` summary statistics. They do **not** claim:
- sub-$1\%$ `ALPHA-g` WEP precision (beyond the published $0.75 \pm 0.21\,g_0$ uncertainty),
- direct experimental measurement of positronium ($e^+e^-$) gravitational free fall,
- laboratory resolution of $\eta_{\mathrm{act}}^\gamma = 0$ vs. $1$ in crossed-laser or sealed annihilation cavities, or
- an experimental test of Plancherel–Unruh quantum-gravity loops at $(E/M_P)^2 \sim 10^{-38}$.

All unmeasured experimental gates will be explicitly isolated in `Signals.Pending.AntimatterAnnihilationAlphaGPendingBoundary`.

---

## 3. Phased Workstreams (`AG-1` Through `AG-5`)

### `AG-1`: Lean 4 Formalization (`Signals.AntimatterGravity` & `Signals.Pending`)
- **Files:**
  - `src/signals/Signals/AntimatterGravity.lean` (imported in `src/signals/Signals.lean`)
  - `src/signals/Signals/Pending.lean` (`AntimatterAnnihilationAlphaGPendingBoundary`)
  - `src/signals/SignalsPending.lean`, `src/signals/SignalsTests.lean`, `src/signals/SignalsPendingTests.lean`
- **Core Definitions & Zero-`sorry` Theorems:**
  1. **Electron–Positron Annihilation Kinematics & Twistor Crossing (`annihilationPhotonEnergy`, `twoTwistorMassSq`, `pluckerCrossingPairAnnihilationResidual`):** proves $2 m_e c^2 \to 2 E_\gamma$ energy conservation, zero photon invariant mass $k_1^2 = k_2^2 = 0$, $2 k_1 \cdot k_2 = (2 m_e c^2)^2$, two-twistor $\mathrm{Gr}_{\mathbb{C}}(2,4)$ momentum conservation, and crossing-channel Plücker relation `s + t + u` balance.
  2. **Active Gravitational Mass Conservation Across $e^- e^+ \to 2\gamma$ (`activeGravitationalMassBeforeAnnihilation`, `activeGravitationalMassAfterAnnihilation`, `annihilationActiveMassDeficit`):** proves exact conservation $\Delta M_{\mathrm{act}} = 0$ for $\eta_{\mathrm{act}}^\gamma = 1$ (**GR, Cachazo–Skinner, QED Scattering Gravity, and Turner Models 12, 14a, 15a**), vs. $\Delta M_{\mathrm{act}} = 2 m_e > 0$ deficit for Nordström scalar gravity ($T^\mu{}_\mu = 0$) and strict uncoupled `DDF` ($\eta_{\mathrm{act}}^\gamma = 0$, **Fedi 2026 `DDF`, Turner Models 13, 14b, 15b**).
  3. **CERN `ALPHA-g` Acceleration & Hypothesis Test Evaluators Across Every Model:**
     - `alphaGAntihydrogenMeasuredRatio = 3/4` ($0.75\,g_0$), `alphaGTotalSigmaSq = (13/100)^2 + (16/100)^2` ($\sigma_{\mathrm{tot}}^2 = 17/400 = 0.0425$), `alphaGChiSq(a_pred)`.
     - Proves exact separation on `ALPHA-g`:
       - Normal WEP ($a_{\bar{g}}/g_0 = 1$, **GR, Cachazo–Skinner, QED/PT2025, DDF positive-sink, Turner 12/13/14a/14b/15a/15b**): $\chi^2(1) = \frac{1/16}{17/400} = \frac{25}{17} \approx 1.4706 < 4$ ($|z| \approx 1.21\sigma$, **consistent**).
       - Zero-gravity / Witten scale-free ($\beta_{\mathrm{scale}} = 0 \implies a_{\bar{g}}/g_0 = 0$): $\chi^2(0) = \frac{9/16}{17/400} = \frac{225}{17} \approx 13.235 > 9$ ($|z| \approx 3.64\sigma$, **rejected $> 3.6\sigma$**).
       - Repulsive antigravity / DDF anti-sink / odd-C vector ($a_{\bar{g}}/g_0 = -1$): $\chi^2(-1) = \frac{49/16}{17/400} = \frac{1225}{17} \approx 72.059 > 64$ ($|z| \approx 8.49\sigma$, **rejected $> 8\sigma$**!).
     - Connects Model 3 / Model 6 coherent escape probability on $\mathcal{Q}_4$ (`pluckerMadelungSuperpositionOAMDoubleSlit` / complex $\mathrm{Gr}_{\mathbb{C}}(2,4)$) vs. $50\%$ unphased error, and Model 14a/14b/15a/15b Jost/CPT symmetry ($\sigma_{\mathrm{dev}} = 0, \delta_{\mathrm{Jos}} = 0 \implies a_{\bar{g}}/g_0 = 1$).
  4. **Photonic Deflection Bridge (`annihilation_and_photonic_deflection_bridge`):** proves directly from `Signals.DDF.ActiveRadiationSourcing` and `Signals.DFT` light-bending laws that:
     - passive solar lensing ($\Delta\theta_{\mathrm{GR}} = \frac{4GM}{c^2 b}$) holds at $\varepsilon_{\mathrm{rel}} = 0$ for GR, Cachazo–Skinner ($\pi_I = 1$), DDF ($c^{-2} = \varrho_{\max}^\varphi j_{\min}^\varphi$), and Turner Models `14a`/`14b`/`15a`/`15b`, while Newtonian/spin-1 ($50\%$) and Nordström ($100\%$) fail;
     - active photon–photon deflection `mutualPhotonDeflection` vanishes identically when and only when $\eta_{\mathrm{act}}^\gamma = 0$ (`ActiveRadiationSourcing.dilatantDarkFluid`), which is the exact same parameter regime where `annihilationActiveMassDeficit m_e (ActiveRadiationSourcing.dilatantDarkFluid.eta) = 2 * m_e > 0`, whereas `ActiveRadiationSourcing.generalRelativity` gives both `0 < mutualPhotonDeflection` and `annihilationActiveMassDeficit m_e (ActiveRadiationSourcing.generalRelativity.eta) = 0`; and
     - Model 15a/15b solar light deflection (`PlanetaryOrbit.turnerCelestialPluckerGravitonLightDeflection`, `RiverExterior.turnerCelestialDualGr24DDFGravitonLightDeflection`) both equal $\Delta\theta_{\mathrm{GR}} = \frac{4 G_\phi M}{c^2 b}$, linking passive solar lensing with the $\eta_{\mathrm{act}}^\gamma \in \{0, 1\}$ active photon–photon discriminator.
- **Verification Gate:** `make signals_build` passes with zero errors and zero `sorry`.

### `AG-2`: Rust + PyO3 Numerical Auditor (`antimatter_gravity.rs`)
- **Files:** `src/signals/numerical_adapter/src/antimatter_gravity.rs`, `src/signals/numerical_adapter/src/lib.rs`
- **Deliverables:**
  1. Pure-Rust `f64` evaluators for $e^- e^+ \to 2\gamma$ kinematics, active gravitational mass deficit across $\eta_{\mathrm{act}}^\gamma \in \{0, 1\}$, `ALPHA-g` 2023 hypothesis testing ($\chi^2$, $z$-score, $p$-value, $2\sigma$ bounds on $\gamma_{\mathrm{conf}}$, $\eta_{\mathrm{drag}}$, $\delta_{\mathrm{Jos}}$), and 7-point bias-scan logistic trap-escape probabilities across all models.
  2. Unit tests (`cargo test ... antimatter_gravity`) + PyO3 `py_audit_antimatter_alpha_g` binding compiled via `maturin develop`.

### `AG-3`: SymPy Exact Proofs & `pytest` CERN `ALPHA-g` Suite
- **Files:** `sustainablefactory/antimatter_gravity.py`, `tests/test_antimatter_gravity_alpha_g.py`
- **Deliverables:**
  1. `verify_symbolic_antimatter_gravity_identities()`: SymPy symbolic verification of Dirac annihilation 4-momentum invariants, $\mathrm{Gr}_{\mathbb{C}}(2,4)$ Plücker crossing duality, active-mass conservation ($\eta_{\mathrm{act}}^\gamma = 1$ vs. $0$ and Nordström $T^\mu{}_\mu = 0$), and exact rational `ALPHA-g` $\chi^2$ values ($25/17$, $225/17$, $1225/17$).
  2. `pytest` suite cross-checking Rust/PyO3 outputs against SymPy and verifying every model row (GR, Witten vs. Cachazo, QED/Partanen–Tulkki, Nordström, Spin-1, DDF sink vs. anti-sink, Turner 3, 6, 12, 13, 14a, 14b, 15a, 15b).

### `AG-4`: MyST Markdown Paper & Documentation Integration
- **Files:**
  - `docs/grassmannian-antimatter-annihilation-alpha-g-models-paper.md`
  - `docs/citations.bib` (verified BibTeX entries for Anderson et al. 2023 `ALPHA-g`, Ahmadi et al. 2016 `ALPHA`, Borchert et al. 2022 `BASE`, Dirac 1928/1930, plus existing keys `witten2004twistor`, `cachazo2013gravity`, `partanen2025gravity`, `fedi2026ddf`, etc.)
  - `docs/_toc.yml` and `docs/plan-index.md`
- **Gate:** Zero findings from `fix_markdown_table_math_pipes.py` and `fix_markdown_display_math_spacing.py`, zero Sphinx warnings on plan & paper, `git diff --check` clean, and browser inspection confirms clean MathJax rendering and zero console errors.
