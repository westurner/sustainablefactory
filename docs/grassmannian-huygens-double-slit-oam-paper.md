---
title: "Huygens–Steiner Barycentric Coherence, Complex Gr_C(2,4) Plücker Channels, and Multi-Model Double-Slit & OAM Relative Predictive Error in Lean 4"
description: "An arXiv-ready formal verification paper uniting Qian–Izadi Huygens–Steiner parallel-axis coherence, complex Gr_C(2,4) Plücker double-slit interference, de Broglie–Bohm pilot-wave hydrodynamics, Wigner phase-space marginals, and Orbital Angular Momentum (OAM) relative predictive error in Lean 4."
---

(grassmannian-huygens-double-slit-oam-paper)=
# Huygens–Steiner Barycentric Coherence, Complex $Gr_{\mathbb{C}}(2,4)$ Plücker Channels, and Multi-Model Double-Slit & OAM Relative Predictive Error in Lean 4

**Authors:** Wes Turner
**Subjects:** Optics (`physics.optics`); Quantum Physics (`quant-ph`); Mathematical Physics (`math-ph`); Logic in Computer Science (`cs.LO`)
**Formal Verification Artifact:** `Signals` Lean 4 Library (`leanprover/lean4:v4.35.0-rc3`, Mathlib `v4.35.0-rc3`)
**Companion Papers:**
- [Grassmannian Geometry of the Quantum Inverse Scattering Method, Algebraic Bethe Ansatz, and Inverse Scattering Metrology in Lean 4](grassmannian-qism-bethe-ansatz-paper.md)
- [Complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ & $N$-ary $Gr_{\mathbb{C}}(2, N+2)$ Unification with Dilatant Dark Fluid (DDF) Moving Sheaths, Plücker Sink Fluxes, Anosov Invariance, and Sorkin Triple-Slit Interferometry in Lean 4](grassmannian-ddf-moving-sheath-paper.md)
- [Grassmannian Gravity from QED & Gauge Scattering Amplitudes: Complex $Gr_{\mathbb{C}}(2,4)$ Orbital Precession, Mercury's Perihelion, $N$-Body Dynamics, and Dilatant Dark Fluid (DDF) Unification in Lean 4](grassmannian-gravity-from-qed-scattering-paper.md)
- [Normed Tensor Gaussian Splat Mechanics for Complex $Gr_{\mathbb{C}}(2,4)$ Twistors: Advantages, Limitations, WebGL2/WASM Practicality, and Unification Across Double-Slit, QISM, DDF, and Planetary Gravity in Lean 4](grassmannian-splat-mechanics-paper.md)
- [Inelastic Scattering and the Heat Problem in Unified Grassmannian–DDF Mechanics: Inverse Compton, Stokes/Anti-Stokes Raman, Fourier vs. Cattaneo–Vernotte, and Subluminal Second-Sound Tensor Splatting in Lean 4](grassmannian-thermal-compton-raman-paper.md)

---

## Abstract

We present a machine-checked formalization in the Lean 4 theorem prover (`Signals.Geometry`, `Signals.Coherence`, `Signals.Huygens`, `Signals.DDF`, and `Signals.OAM`) comparing predicted interferometric intensities and relative predictive errors across five mathematical formulations of double-slit superposition—both for planar wavefronts and for vortex beams carrying Orbital Angular Momentum (OAM):

1. **Fraunhofer Far-Field Reference ($I_{\mathrm{F}}$ and $I_{\mathrm{F,OAM}}$)**,
2. **Huygens–Steiner Parallel-Axis Barycentric Coherence ($I_{\mathrm{HS}}$ and $I_{\mathrm{HS,OAM}}$)** ([Qian and Izadi 2023](#qian-izadi2023)),
3. **Real Positive $Gr_{\ge 0}(2,4)$ and Complex $Gr_{\mathbb{C}}(2,4)$ Plücker Channel Models ($I_{Gr(2,4)}$, $I_{Gr(2,4)}^{\mathrm{unphased}}$, and $I_{Gr_{\mathbb{C}}(2,4)}^{\times}$)**,
4. **De Broglie–Bohm / Madelung Pilot-Wave Hydrodynamics ($I_{\mathrm{PW}}$)**, and
5. **Wigner Phase-Space Quasi-Probability Marginals ($I_{\mathrm{Wigner}}$ and $I_{\mathrm{Wigner,OAM}}$)**.

Building on the $N$-dimensional polarization–entanglement complementarity relation $P_N^2 + K_N^2 = 1$ and the Huygens–Steiner parallel-axis theorem $I_O = I_M + m_{\mathrm{tot}} d_{\mathrm{bary}}^2$ of [Qian and Izadi (2023)](#qian-izadi2023), we prove the universal **Pythagorean Plücker–Steiner Identity** on $Gr(2,4)$:

$$
d_{\mathrm{bary}}(M)^2 + \Delta_{01}(M)\Delta_{23}(M)\,\Delta_{03}(M)\Delta_{12}(M) = \left(\frac{\Delta_{02}(M)\Delta_{13}(M)}{2}\right)^2.
$$

We prove that while an unphased crossing-minor proxy restricted to the real positive Grassmannian $Gr_{\ge 0}(2,4)$ incurs a mandatory $50\%$ ($1/2$) on-axis relative predictive error (and $100\%$ error at dark fringes), lifting to the complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ with $\mathbb{C}^4$ twistor phase entries $z_{1,2} = \sqrt{1 \pm d_{\mathrm{bary}}}\,e^{\pm i\theta}$ **eliminates the $50\%$ unphased error completely ($\varepsilon_{\mathrm{rel}} = 0$ everywhere)** and reproduces the partially coherent Huygens–Steiner profile $I_{\mathrm{HS}}\bigl(x,y;\sqrt{1 - d_{\mathrm{bary}}^2}\bigr)$ identically across the entire detector plane for every barycentric parallel-axis shift $d_{\mathrm{bary}} \in [-1, 1]$. For OAM beams with differential topological charge $\Delta\ell \in \mathbb{Z}$, we prove exact vortex dark-core cancellation at $(\Delta\ell = 1, \phi = \pi)$ ($100\%$ non-OAM relative error) and quadratic $(\Delta\ell)^2$ rotational decoherence scaling in the Wigner angle–OAM marginal.

---

## 1. Introduction & Epistemic Verification Boundary

Evaluating multi-aperture wave superposition across classical optics, positive geometry ([Postnikov 2006](#postnikov2006); [Arkani-Hamed and Trnka 2014](#arkani-hamed-trnka2014); [Arkani-Hamed et al. 2017](#arkani-hamed-bai-lam2017)), quantum coherence theory ([Qian and Izadi 2023](#qian-izadi2023)), Bohmian hydrodynamics, and Wigner phase-space tomography raises a precise quantitative question: **what is the exact pointwise and dark-fringe relative predictive error between these formulations, and what geometric data are required for a Grassmannian minor evaluator to match coherent interferometry without ad-hoc fitting?**

*(Note: The companion application of the same verified $2 \times n$ Grassmannian Plücker kernel `Signals.Geometry.twoRowMinor_pluecker` to Baxter's $QQ$-system, $TQ$ Wronskians, and the Quantum Inverse Scattering Method is presented in the companion paper [Grassmannian Geometry of the Quantum Inverse Scattering Method, Algebraic Bethe Ansatz, and Inverse Scattering Metrology in Lean 4](grassmannian-qism-bethe-ansatz-paper.md).)*

All theorems in this paper are machine-checked in Lean 4 without `sorry` or custom axioms, under a three-tier epistemic boundary:
1. **Checked Algebra & Analysis**: Exact polynomial, determinant, trigonometric, and measure-theoretic theorems proved in Lean (`Signals.Geometry`, `Signals.Coherence`, `Signals.Huygens`, `Signals.DDF`, `Signals.OAM`).
2. **Conditional Model Contracts**: Physical regime assumptions—such as paraxial Fraunhofer propagation, quantum equilibrium ($\delta_{\mathrm{neq}} = 0$), or non-vanishing reference denominators—are explicit hypotheses in the Lean theorem signatures.
3. **Experimental Validation**: Type-checking a formal proof certifies the mathematical consequences of the stated hypotheses; it does not substitute for calibrated optical measurements.

```lean
import Signals
import SignalsPending

namespace ArxivDoubleSlitPaperVerification

open Signals.Geometry
open Signals.Coherence
open Signals.Huygens

-- 1. Coherent / quantum-equilibrium / pure-state four-model unification (zero relative error everywhere)
example (x y : ℝ) :
    relativePredictiveError
        (huygensSteinerDoubleSlit 3 2 4 6 1 5 1 x y)
        (fraunhoferRectangularDoubleSlit 3 2 4 6 1 5 x y) = 0 ∧
      relativePredictiveError
        (pilotWaveDoubleSlit 3 2 4 6 1 5 0 x y)
        (fraunhoferRectangularDoubleSlit 3 2 4 6 1 5 x y) = 0 ∧
      relativePredictiveError
        (wignerDoubleSlit 3 2 4 6 1 5 0 x y)
        (fraunhoferRectangularDoubleSlit 3 2 4 6 1 5 x y) = 0 :=
  doubleSlit_four_model_zero_relative_error 3 2 4 6 1 5 x y
```

---

## 2. Qian–Izadi Coherence Complementarity & the Plücker–Steiner Barycentric Shift

### 2.1 Arbitrary-$N$ Coherence Spectra and the Huygens–Steiner Parallel-Axis Theorem

In [Qian and Izadi (2023)](#qian-izadi2023) ({download}`PhysRevResearch.5.033110.pdf, pp. 1-6 <../data/papers/PhysRevResearch.5.033110.pdf>`), an $N$-dimensional optical field with normalized coherence-matrix eigenvalues $m_i \ge 0$ ($\sum_{i=1}^N m_i = 1$, formalized as `Signals.Coherence.CoherenceSpectrum`) has squared degree of polarization $P_N^2$ and squared Schmidt-weight entanglement/coherence $K_N^2$:

$$
P_N^2 = \frac{N}{N-1}\sum_{i=1}^N m_i^2 - \frac{1}{N-1}, \qquad
K_N^2 = \frac{N}{N-1}\left(1 - \sum_{i=1}^N m_i^2\right), \qquad
P_N^2 + K_N^2 = 1.
$$

Mapping the eigenvalues $m_i$ to point masses at the vertices of a regular simplex with unit total mass ($m_{\mathrm{tot}} = 1$) identifies the squared polarization $P_N^2$ with the mechanical moment-of-inertia shift under the **Huygens–Steiner parallel-axis theorem** (`Signals.Coherence.HuygensSteinerMapping` in [src/signals/Signals/Coherence.lean](../src/signals/Signals/Coherence.lean#L194-L242)):

$$
I_O = I_M + m_{\mathrm{tot}} d_{\mathrm{bary}}^2 \quad \Longrightarrow \quad
P_N^2 = I_O - I_M = d_{\mathrm{bary}}^2, \qquad
K_N^2 = 1 - d_{\mathrm{bary}}^2 = \mathcal{V}^2.
$$

For a binary ($N = 2$) two-slit spectrum with normalized slit intensities $m_0 + m_1 = 1$, `CoherenceSpectrum.binary_polarization_and_entanglement` ([Coherence.lean](../src/signals/Signals/Coherence.lean#L244-L273)) proves:

$$
P_2^2 = (m_0 - m_1)^2 = d_{\mathrm{bary}}^2, \qquad
K_2^2 = 4 m_0 m_1 = \mathcal{V}^2.
$$

### 2.2 The Universal Pythagorean Plücker–Steiner Identity on $Gr(2,4)$

In a four-terminal $2 \times 4$ Grassmannian matrix $M \in \mathbb{R}^{2 \times 4}$ with columns $(0 = \text{Source}, 1 = \text{Slit } A, 2 = \text{Slit } B, 3 = \text{Detector})$, the two uncrossed boundary channel products are $w_A(M) = \Delta_{01}(M)\Delta_{23}(M)$ and $w_B(M) = \Delta_{03}(M)\Delta_{12}(M)$, and their sum equals the crossing minor product $w_\times(M) = \Delta_{02}(M)\Delta_{13}(M)$ by the 3-term Plücker relation (`gr24_channel_sum_eq_crossing`).

Defining the **Plücker barycentric parallel-axis shift** (`gr24BarycentricShift` in [src/signals/Signals/Geometry.lean](../src/signals/Signals/Geometry.lean#L969-L980)):

$$
d_{\mathrm{bary}}(M) = \frac{\Delta_{01}(M)\Delta_{23}(M) - \Delta_{03}(M)\Delta_{12}(M)}{2} = \frac{w_A(M) - w_B(M)}{2},
$$

we prove the universal **Pythagorean Plücker–Steiner Identity** (`gr24_plucker_pythagorean_identity` in [Geometry.lean](../src/signals/Signals/Geometry.lean#L982-L1005)):

$$
d_{\mathrm{bary}}(M)^2 + \underbrace{\Delta_{01}(M)\Delta_{23}(M)\,\Delta_{03}(M)\Delta_{12}(M)}_{\mathcal{V}_{Gr(2,4)}(M)^2} = \left(\frac{\Delta_{02}(M)\Delta_{13}(M)}{2}\right)^2.
$$

When the crossing Plücker product is normalized to $\Delta_{02}(M)\Delta_{13}(M) = 2$ (`gr24_barycentric_complementarity` in [src/signals/Signals/Huygens.lean](../src/signals/Signals/Huygens.lean#L1437-L1458)), this recovers the exact Qian–Izadi complementarity circle $d_{\mathrm{bary}}(M)^2 + \mathcal{V}_{Gr(2,4)}(M)^2 = 1$.

---

## 3. Five-Model Double-Slit Superposition & Lifting $Gr_{\ge 0}(2,4) \to Gr_{\mathbb{C}}(2,4)$

### 3.1 Why Real Positive $Gr_{\ge 0}(2,4)$ Crossing Minors Have a $50\%$ Unphased Error—and How Complex $Gr_{\mathbb{C}}(2,4)$ Eliminates It

In the strictly positive real Grassmannian $Gr_{\ge 0}(2,4)$, all ordered minors are nonnegative real numbers ($\Delta_{ab} \ge 0$), so $w_A \ge 0$ and $w_B \ge 0$. Consequently, the unphased crossing product $\Delta_{02}\Delta_{13} = w_A + w_B$ computes the *incoherent* sum $2 I_0 E_{\mathrm{slit}}(x,y)$ rather than the coherent Fraunhofer peak $4 I_0$, incurring a mandatory $50\%$ ($1/2$) on-axis relative predictive error (`gr24UnphasedDoubleSlit_onAxis_relative_error_half`) and $100\%$ error at dark fringes.

When we lift from $Gr_{\ge 0}(2,4)$ to the **complex Grassmannian $Gr_{\mathbb{C}}(2,4)$** (`complexTwoRowMinor_pluecker` in [Geometry.lean](../src/signals/Signals/Geometry.lean#L1007-L1055), induced by $\mathbb{C}^4$ twistors $Z = (\lambda_\alpha, \mu^{\dot{\alpha}}) \in \mathbb{C}^4$ carrying complex incidence phases $\mu^{\dot{\alpha}} = -i x^{\alpha\dot{\alpha}}\lambda_\alpha$), the pure crossing-minor intensity evaluator (`complexGr24CrossingDoubleSlit` in [Huygens.lean](../src/signals/Signals/Huygens.lean#L1336-L1350)):

$$
I_{Gr_{\mathbb{C}}(2,4)}^{\times}(M_{\mathbb{C}}; x, y) = I_0 E_{\mathrm{slit}}(x,y)\,\bigl|\Delta_{02}^{\mathbb{C}}(M_{\mathbb{C}})\,\Delta_{13}^{\mathbb{C}}(M_{\mathbb{C}})\bigr|^2
$$

**automatically generates the coherent interference cross-term** via the complex Plücker identity $\Delta_{02}^{\mathbb{C}}\Delta_{13}^{\mathbb{C}} = \mathcal{A}_1 + \mathcal{A}_2$ (`complexGr24_crossing_intensity_eq_superposition`):

$$
\bigl|\Delta_{02}^{\mathbb{C}}\Delta_{13}^{\mathbb{C}}\bigr|^2 = |\mathcal{A}_1|^2 + |\mathcal{A}_2|^2 + 2\operatorname{Re}(\mathcal{A}_1 \overline{\mathcal{A}_2}).
$$

For any barycentric parallel-axis shift $d_{\mathrm{bary}} \in [-1, 1]$ and interference phase $\theta = \pi d x / (\lambda L)$, encoding the two channel amplitudes in `complexGr24ChannelMatrix` as:

$$
M_{\mathbb{C}}(z_1, z_2) = \begin{pmatrix} 1 & 1 & 0 & -1 \\ 0 & z_1 & 1 & z_2 \end{pmatrix}, \qquad
z_1 = \sqrt{1 + d_{\mathrm{bary}}}\,e^{i\theta}, \qquad
z_2 = \sqrt{1 - d_{\mathrm{bary}}}\,e^{-i\theta},
$$

gives $\Delta_{02}^{\mathbb{C}}\Delta_{13}^{\mathbb{C}} = z_1 + z_2 = (\sqrt{1+d_{\mathrm{bary}}} + \sqrt{1-d_{\mathrm{bary}}})\cos\theta + i(\sqrt{1+d_{\mathrm{bary}}} - \sqrt{1-d_{\mathrm{bary}}})\sin\theta$. Theorem `complexGr24CrossingDoubleSlit_barycentric_eq_huygensSteiner` ([Huygens.lean](../src/signals/Signals/Huygens.lean#L1460-L1551)) proves that its squared modulus equals $2\bigl(1 + \sqrt{1 - d_{\mathrm{bary}}^2}\cos(2\theta)\bigr)$, reproducing the partially coherent Huygens–Steiner profile $I_{\mathrm{HS}}\bigl(x,y;\sqrt{1 - d_{\mathrm{bary}}^2}\bigr)$ **identically at every $(x,y) \in \mathbb{R}^2$** (and reducing to $I_{\mathrm{F}}(x,y)$ at $d_{\mathrm{bary}} = 0$ via `complexGr24CrossingDoubleSlit_zero_error`).

### 3.2 Master Table: Five-Model Double-Slit Superposition & Relative Predictive Error

| Double-Slit Formulation | Lean Definitions & Theorems | Intensity Law $I(x,y)$ | Relative Predictive Error vs. Fraunhofer ($I_{\mathrm{F}}$) |
|---|---|---|---|
| **1. Fraunhofer Reference** | `fraunhoferRectangularDoubleSlit`, `fraunhoferRectangularDoubleSlit_onAxis`, `fraunhoferRectangularDoubleSlit_dark_fringe` | $I_{\mathrm{F}}(x,y) = 4 I_0 E_{\mathrm{slit}}(x,y) \cos^2\!\left(\frac{\pi d x}{\lambda L}\right)$ | $0$ (reference baseline; vanishes at half-period dark fringes $x_{\mathrm{dark}} = \frac{\lambda L}{2d}$) |
| **2. Huygens–Steiner Parallel-Axis Coherence** ([Qian & Izadi 2023](#qian-izadi2023)) | `huygensSteinerDoubleSlit`, `HuygensSteinerMapping`, `CoherenceComplementarity`, `huygensSteiner_onAxis_relative_error`, `huygensSteiner_relative_error_eq_offset_sq_div`, `huygensSteiner_relative_error_from_coherenceComplementarity` | $I_{\mathrm{HS}}(x,y;\mathcal{V}) = 2 I_0 E_{\mathrm{slit}}(x,y)\bigl(1 + \mathcal{V}\cos\frac{2\pi d x}{\lambda L}\bigr)$, where $d_{\mathrm{bary}}^2 = I_O - I_M = P_N^2$ and $d_{\mathrm{bary}}^2 + \mathcal{V}^2 = 1$ | **Coherent ($d_{\mathrm{bary}}=0, \mathcal{V}=1$)**: $0$ everywhere<br>**On-axis**: $\varepsilon_{\mathrm{rel}}(0,0) = \frac{1-\mathcal{V}}{2} = \frac{d_{\mathrm{bary}}^2}{2(1+\mathcal{V})} = \frac{P_N^2}{2(1+K_N)}$<br>**Dark fringe**: $\varepsilon_{\mathrm{peak}}(x_{\mathrm{dark}},0) = \frac{1-\mathcal{V}}{2}\operatorname{sinc}^2\!\left(\frac{\pi a}{2d}\right)$ |
| **3. $Gr(2,4)$ & $Gr_{\mathbb{C}}(2,4)$ Plücker Channel Models** | `gr24PluckerDoubleSlit`, `gr24UnphasedDoubleSlit`, `gr24_plucker_pythagorean_identity`, `complexGr24CrossingDoubleSlit`, `complexGr24_crossing_intensity_eq_superposition`, `complexGr24CrossingDoubleSlit_zero_error`, `complexGr24CrossingDoubleSlit_barycentric_eq_huygensSteiner` | **Real $Gr_{\ge 0}(2,4)$**: $I_{Gr(2,4)} = I_0 E_{\mathrm{slit}}\bigl(\Delta_{02}\Delta_{13} + 2\sqrt{w_A w_B}\cos\frac{2\pi d x}{\lambda L}\bigr)$<br>**Complex $Gr_{\mathbb{C}}(2,4)$ ($\mathbb{C}^4$ twistors)**: $I_{Gr_{\mathbb{C}}(2,4)}^{\times} = I_0 E_{\mathrm{slit}}\bigl|\Delta_{02}^{\mathbb{C}}\Delta_{13}^{\mathbb{C}}\bigr|^2 = I_0 E_{\mathrm{slit}}|\mathcal{A}_1 + \mathcal{A}_2|^2$ | **Real unphased proxy ($\Delta_{02}\Delta_{13}=2 \in Gr_{\ge 0}$)**: $\varepsilon_{\mathrm{rel}}(0,0) = \frac{1}{2}$ ($50\%$), dark fringe $100\%$<br>**Complex $Gr_{\mathbb{C}}(2,4)$ ($d_{\mathrm{bary}}=0$)**: **$0$ everywhere** (eliminates $50\%$ error)<br>**Complex $Gr_{\mathbb{C}}(2,4)$ ($d_{\mathrm{bary}} \in [-1,1]$)**: **$0$ vs. $I_{\mathrm{HS}}(x,y;\sqrt{1-d_{\mathrm{bary}}^2})$**, and $\frac{d_{\mathrm{bary}}^2}{2(1+\mathcal{V})}$ vs. $I_{\mathrm{F}}(0,0)$ |
| **4. Pilot-Wave Theory (De Broglie–Bohm)** | `pilotWaveDoubleSlit`, `pilotWaveDoubleSlit_equilibrium_eq_fraunhofer`, `pilotWave_onAxis_relative_error` | $I_{\mathrm{PW}}(x,y;\delta_{\mathrm{neq}}) = I_{\mathrm{F}}(x,y) + \delta_{\mathrm{neq}}$ (equivariant guidance $\mathbf{v} = \frac{\hbar}{m}\nabla S$ + Bohm potential $Q$) | **Quantum equilibrium ($\delta_{\mathrm{neq}}=0$)**: $0$ everywhere<br>**Non-equilibrium ($\delta_{\mathrm{neq}} \neq 0$)**: $\varepsilon_{\mathrm{rel}}(0,0) = \frac{|\delta_{\mathrm{neq}}|}{4 I_0}$ |
| **5. Wigner Phase-Space Marginal** | `wignerDoubleSlit`, `wignerDoubleSlit_eq_huygensSteiner`, `wignerDoubleSlit_pure_eq_fraunhofer`, `wigner_onAxis_relative_error` | $I_{\mathrm{Wigner}}(x,y;\gamma_{\mathrm{dec}}) = 2 I_0 E_{\mathrm{slit}}(x,y)\bigl(1 + e^{-\gamma_{\mathrm{dec}}}\cos\frac{2\pi d x}{\lambda L}\bigr)$ | **Pure state ($\gamma_{\mathrm{dec}}=0$)**: $0$ everywhere<br>**Decohered ($\gamma_{\mathrm{dec}} > 0$)**: $\varepsilon_{\mathrm{rel}}(0,0) = \frac{1 - e^{-\gamma_{\mathrm{dec}}}}{2}$ (exact duality $\mathcal{V} = e^{-\gamma_{\mathrm{dec}}}$) |

```lean
-- 2. Universal Pythagorean Plücker-Steiner identity on Gr(2,4)
example (M : Matrix (Fin 2) (Fin 4) ℝ) :
    (gr24BarycentricShift M) ^ 2 +
      (twoRowMinor M 0 1 * twoRowMinor M 2 3) *
        (twoRowMinor M 0 3 * twoRowMinor M 1 2) =
    (twoRowMinor M 0 2 * twoRowMinor M 1 3 / 2) ^ 2 :=
  gr24_plucker_pythagorean_identity M

-- 3. Complex Gr_C(2,4) pure crossing-minor evaluator matches Huygens-Steiner for any d_bary ∈ [-1, 1]
example (d_bary x y : ℝ) (h_low : -1 ≤ d_bary) (h_high : d_bary ≤ 1) :
    let θ := Real.pi * 6 * x / (1 * 5)
    let a := Real.sqrt (1 + d_bary)
    let b := Real.sqrt (1 - d_bary)
    let z1 : ℂ := ↑(a * Real.cos θ) + Complex.I * ↑(a * Real.sin θ)
    let z2 : ℂ := ↑(b * Real.cos θ) - Complex.I * ↑(b * Real.sin θ)
    complexGr24CrossingDoubleSlit (complexGr24ChannelMatrix z1 z2) 3 2 4 1 5 x y =
      huygensSteinerDoubleSlit 3 2 4 6 1 5 (Real.sqrt (1 - d_bary ^ 2)) x y ∧
    relativePredictiveError
      (complexGr24CrossingDoubleSlit (complexGr24ChannelMatrix z1 z2) 3 2 4 1 5 x y)
      (huygensSteinerDoubleSlit 3 2 4 6 1 5 (Real.sqrt (1 - d_bary ^ 2)) x y) = 0 :=
  complexGr24CrossingDoubleSlit_barycentric_eq_huygensSteiner 3 2 4 6 1 5 d_bary x y h_low h_high
```

---

## 4. Orbital Angular Momentum (OAM) Double-Slit Superposition Across Formulations

When Slit $A$ and Slit $B$ carry helical OAM modes $e^{i\ell_1\phi}$ and $e^{i\ell_2\phi}$ with differential topological charge $\Delta\ell = \ell_2 - \ell_1 \in \mathbb{Z}$ and azimuthal angle $\phi \in \mathbb{R}$, the interference fringes twist by $\Delta\ell\,\phi$ (`fraunhoferOAMDoubleSlit`, `huygensSteinerOAMDoubleSlit`, `wignerOAMDoubleSlit` in [src/signals/Signals/Huygens.lean](../src/signals/Signals/Huygens.lean#L1553-L1735)):

| Method | OAM Representation & Lean Nodes | OAM Superposition Intensity Law $I_{\mathrm{OAM}}(x,y,\phi;\Delta\ell)$ | OAM Phase-Singularity & Relative Predictive Error Behavior |
|---|---|---|---|
| **1. Fraunhofer OAM Reference** | `fraunhoferOAMDoubleSlit`, `fraunhoferOAMDoubleSlit_zero_charge_eq_standard`, `fraunhoferOAMDoubleSlit_vortex_null_at_pi` | $I_{\mathrm{F,OAM}}(x,y,\phi;\Delta\ell) = 4 I_0 E_{\mathrm{slit}}(x,y)\cos^2\!\left(\frac{\pi d x}{\lambda L} + \frac{\Delta\ell\,\phi}{2}\right)$ | Reduces to $I_{\mathrm{F}}(x,y)$ when $\Delta\ell = 0$. At $\Delta\ell = 1, \phi = \pi$, forms an on-axis optical vortex dark core $I_{\mathrm{F,OAM}}(0,0,\pi;1) = 0$; omitting OAM gives $\varepsilon_{\mathrm{rel}} = 1$ ($100\%$). |
| **2. Huygens–Steiner Parallel-Axis & Barycentric OAM** | `huygensSteinerOAMDoubleSlit`, `huygensSteinerOAMDoubleSlit_unit_visibility_eq_fraunhoferOAM`, `Signals.OAM.Qudit`, `Signals.Geometry.orbitalBivector_translate` | $I_{\mathrm{HS,OAM}}(x,y,\phi;\Delta\ell,\mathcal{V}) = 2 I_0 E_{\mathrm{slit}}(x,y)\bigl(1 + \mathcal{V}\cos(\frac{2\pi d x}{\lambda L} + \Delta\ell\,\phi)\bigr)$; mechanical shift $L_{ab} \mapsto L_{ab} + (a \wedge p)_{ab}$ | Matches $I_{\mathrm{F,OAM}}$ at $\mathcal{V} = 1$. For partially overlapping $D$-mode OAM qudits (`Signals.OAM.Qudit D`), $\varepsilon_{\mathrm{rel}}(0,0,0) = \frac{1-\mathcal{V}}{2} = \frac{P_N^2}{2(1+K_N)}$; orthogonal azimuth-integrated modes ($\mathcal{V}=0$) have $\varepsilon_{\mathrm{rel}} = 1/2$. |
| **3. $Gr(2,4)$ / $Gr_{\mathbb{C}}(2,4)$ Plücker & Twistor OAM Shear** | `gr24PluckerDoubleSlit`, `complexGr24CrossingDoubleSlit`, `complexGr24CrossingDoubleSlit_oam_barycentric_eq_huygensSteinerOAM`, `Signals.Geometry.AngularMomentumState.translate_angularMomentum` | Complex channel entries $z_{1,2} = \sqrt{1 \pm d_{\mathrm{bary}}}\,e^{\pm i(\theta + \Delta\ell\,\phi/2)}$ in $M_{\mathbb{C}}(z_1, z_2)$ | $\varepsilon_{\mathrm{rel}} = 0$ against $I_{\mathrm{HS,OAM}}$ for all $(x,y,\phi)$, $\Delta\ell \in \mathbb{Z}$, and $d_{\mathrm{bary}} \in [-1,1]$ (`complexGr24CrossingDoubleSlit_oam_barycentric_eq_huygensSteinerOAM`); $\varepsilon_{\mathrm{rel}} = 1/2$ if real $Gr_{\ge 0}(2,4)$ omits the helical phase. |
| **4. Pilot-Wave / Madelung Vortex Hydrodynamics** | `pilotWaveOAMDoubleSlit`, `pilotWaveOAMDoubleSlit_equilibrium_eq_fraunhoferOAM`, `Signals.DDF.vortexTangentialVelocity`, `Signals.DDF.quantized_vortex_circulation`, `Signals.DDF.plaquette_phase_slip_syndrome` | $I_{\mathrm{PW,OAM}} = I_{\mathrm{F,OAM}}(x,y,\phi;\Delta\ell) + \delta_{\mathrm{neq}}$, with azimuthal guiding velocity $v_\theta = \frac{\hbar \ell}{m R}$ and quantized circulation $\oint \mathbf{v}\cdot d\boldsymbol{\ell} = \ell\frac{2\pi\hbar}{m}$ | Exact ($\varepsilon_{\mathrm{rel}} = 0$) in quantum equilibrium ($\delta_{\mathrm{neq}} = 0$); Bohmian trajectories spiral around the $2\pi\Delta\ell$ plaquette phase-slip singularities, with $\varepsilon_{\mathrm{rel}}(0,0,0) = \frac{|\delta_{\mathrm{neq}}|}{4I_0}$. |
| **5. Wigner Angle–OAM Phase-Space Marginal** | `wignerOAMDoubleSlit`, `wignerOAM_onAxis_relative_error` | $I_{\mathrm{Wigner,OAM}}(x,y,\phi;\Delta\ell,\gamma_{\mathrm{OAM}}) = 2 I_0 E_{\mathrm{slit}}(x,y)\bigl(1 + e^{-\gamma_{\mathrm{OAM}}(\Delta\ell)^2}\cos(\frac{2\pi d x}{\lambda L} + \Delta\ell\,\phi)\bigr)$ | Rotational phase-space diffusion scales quadratically with $(\Delta\ell)^2$: $\varepsilon_{\mathrm{rel}}(0,0,0;\Delta\ell) = \frac{1 - e^{-\gamma_{\mathrm{OAM}}(\Delta\ell)^2}}{2}$, which vanishes for $\Delta\ell = 0$ or $\gamma_{\mathrm{OAM}} = 0$. |

### 4.1 Multi-Slit ($N > 0$) & Triple-Slit ($N = 3$) Grating Generalization (`huygensSteinerMultiSlit`, `fraunhoferMultiSlit`, `complexGr2NCollectorMultiSlit`)

For an arbitrary positive number of slits $N > 0$ (`numSlits : ℕ`) with slit width $a$, height $b$, center-to-center pitch $d$, and adjacent-slit phase half-step $\beta = \frac{\pi d x}{\lambda L} + \frac{\Delta\ell\,\phi}{2}$, `multiSlitInterferenceFactor` and `huygensSteinerMultiSlit` sum the $N$ diagonal self-intensities and the $\binom{N}{2}$ off-diagonal pairwise interference cosines weighted by $\mathcal{V} = K_N = \sqrt{1 - d_{\mathrm{bary}}^2}$:

$$
I_{\mathrm{HS}}^{(N)}(N, x, y, \phi; \Delta\ell, \mathcal{V}) = I_0 E_{\mathrm{slit}}(x,y)\left( N + 2\mathcal{V}\sum_{j=0}^{N-1}\sum_{k=j+1}^{N-1}\cos\bigl(2(k - j)\beta\bigr)\right).
$$

- **Single-Slit ($N = 1$) & Double-Slit ($N = 2$) Reductions**: Theorem `huygensSteinerMultiSlit_one_slit` proves $I_{\mathrm{HS}}^{(1)} = I_0 E_{\mathrm{slit}}(x,y)$, and `huygensSteinerMultiSlit_two_slits_eq_huygensSteinerOAM` proves exact agreement with `huygensSteinerOAMDoubleSlit` for $N = 2$.
- **Triple-Slit ($N = 3$) Expansion, Secondary Null, Relative Error, and $Gr_{\mathbb{C}}(2,5)$ Collector Equivalence (`multiSlitInterferenceFactor_three`, `tripleSlit_peak_and_secondary_null`, `tripleSlit_onAxis_relative_error`, `complexGr25CollectorTripleSlit_eq_fraunhoferMultiSlit`)**:
  For $N = 3$ slits, $\mathcal{G}_3(\mathcal{V}, \beta) = 3 + 2\mathcal{V}(2\cos(2\beta) + \cos(4\beta))$ has coherent peak $\mathcal{G}_3(1, 0) = 9$, secondary-minimum null $\mathcal{G}_3(1, \pi/3) = 0$, on-axis relative predictive error $\varepsilon_{\mathrm{rel}}(0,0) = \frac{2}{3}(1 - \mathcal{V})$, and is reproduced with **zero relative error everywhere** by the collector Plücker minor $\Delta_{0,1}^{\mathbb{C}}$ of `complexGr2NChannelMatrix 3` in $Gr_{\mathbb{C}}(2,5)$, with vanishing Sorkin third-order parameter $\kappa_3 = 0$ (`sorkinTripleSlitParameter_zero`).

```lean
-- 4. OAM vortex null at (Δℓ = 1, φ = π), quadratic (Δℓ)² Wigner error, and N-slit (N = 1, 2, 3) & Sorkin κ₃ = 0 laws
example (γ_oam : ℝ) (h_dec : 0 ≤ γ_oam) (Δℓ : ℤ) (φ x y : ℝ) (z0 z1 z2 : ℂ) :
    fraunhoferOAMDoubleSlit 3 2 4 6 1 5 1 Real.pi 0 0 = 0 ∧
    relativePredictiveError
      (fraunhoferOAMDoubleSlit 3 2 4 6 1 5 1 Real.pi 0 0)
      (fraunhoferRectangularDoubleSlit 3 2 4 6 1 5 0 0) = 1 ∧
    relativePredictiveError
      (wignerOAMDoubleSlit 3 2 4 6 1 5 γ_oam Δℓ 0 0 0)
      (fraunhoferOAMDoubleSlit 3 2 4 6 1 5 Δℓ 0 0 0) =
      (1 - Real.exp (- (γ_oam * (Δℓ : ℝ) ^ 2))) / 2 ∧
    huygensSteinerMultiSlit 1 3 2 4 6 1 5 (4 / 5) Δℓ φ x y =
      3 * rectangularSlitEnvelope 2 4 1 5 x y ∧
    huygensSteinerMultiSlit 2 3 2 4 6 1 5 (4 / 5) Δℓ φ x y =
      huygensSteinerOAMDoubleSlit 3 2 4 6 1 5 (4 / 5) Δℓ φ x y ∧
    relativePredictiveError
      (huygensSteinerMultiSlit 3 3 2 4 6 1 5 (4 / 5) Δℓ 0 0 0)
      (fraunhoferMultiSlit 3 3 2 4 6 1 5 Δℓ 0 0 0) =
      (2 / 3) * (1 - 4 / 5) ∧
    sorkinTripleSlitParameter z0 z1 z2 = 0 :=
  ⟨(fraunhoferOAMDoubleSlit_vortex_null_at_pi 3 2 4 6 1 5 (by norm_num)).1,
    (fraunhoferOAMDoubleSlit_vortex_null_at_pi 3 2 4 6 1 5 (by norm_num)).2,
    wignerOAM_onAxis_relative_error 3 2 4 6 1 5 γ_oam Δℓ (by norm_num) h_dec,
    huygensSteinerMultiSlit_one_slit 3 2 4 6 1 5 (4 / 5) Δℓ φ x y,
    huygensSteinerMultiSlit_two_slits_eq_huygensSteinerOAM 3 2 4 6 1 5 (4 / 5) Δℓ φ x y,
    tripleSlit_onAxis_relative_error 3 2 4 6 1 5 (4 / 5) Δℓ (by norm_num) (by norm_num),
    sorkinTripleSlitParameter_zero z0 z1 z2⟩
```

---

## 5. Hydrodynamic Sink-Flux Superposition, DDF Shear-Jamming Duality, Anosov Symplectic Invariance, & Formal Critique

*(For the complete treatment of the $Gr_{\mathbb{C}}(2,4)$ and $N$-ary $Gr_{\mathbb{C}}(2, N+2)$ unification with `DDFSubstrate` and `MovingSheath`, see the companion paper [Complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ & $N$-ary $Gr_{\mathbb{C}}(2, N+2)$ Unification with Dilatant Dark Fluid (DDF) Moving Sheaths, Plücker Sink Fluxes, Anosov Invariance, and Sorkin Triple-Slit Interferometry in Lean 4](grassmannian-ddf-moving-sheath-paper.md).)*

In [src/signals/Signals/DDF.lean](../src/signals/Signals/DDF.lean#L648-L960), we formalize and critically audit the four-part correspondence proposed in [Provenance Chat Log: Plücker Channel Weights, Fluid Sinks, and DDF (2026)](#chat-plucker-sinks-ddf) (lines 6–228) connecting $Gr(2,4)$ Plücker channel weights to emergent hydrodynamic sink-flow models ([Partanen and Tulkki 2025](#partanen-tulkki2025)) and the Dilatant Dark Fluid (DDF) substrate ([Fedi 2026](#fedi2026)):

| Component | Grassmannian & Coherence Formulation | Emergent Fluid / Sink-Flow Limit | Fedi's Dilatant Dark Fluid (`Signals.DDF`) | Lean 4 Verification & Critique Nodes |
|---|---|---|---|---|
| **Channel States & Flux Sum** | Uncrossed weights $w_A = \Delta_{01}\Delta_{23}$, $w_B = \Delta_{03}\Delta_{12}$; sum $w_A + w_B = \Delta_{02}\Delta_{13}$ | Localized sink fluxes $Q_A, Q_B$; total drain $Q_A + Q_B = \Delta_{02}\Delta_{13}$; shear imbalance $(Q_A - Q_B)/2 = d_{\mathrm{bary}}$ | Coupled $(\phi, \varphi)$ bosonic sector densities across the interaction canvas | `pluckerSinkFluxA`, `pluckerSinkFluxB`, `pluckerSinkFlux_conservation_and_asymmetry` |
| **Symmetric Coordinate ($d_{\mathrm{bary}}=0$)** | Balanced channels $Q_A = Q_B = 1$, $\mathcal{V} = 1$, zero phased error ($\varepsilon_{\mathrm{rel}} = 0$) | Irrotational potential balance ($\Delta\ell = 0 \implies \Delta\Gamma = 0$, $\omega = 0$) | Zero relative shear ($v = 0$): no jamming ($\gamma_\varphi(0) = 1$, $K_D(0) = 0$) | `MovingSheath.zero_shear_no_jamming`, `ddf_symmetric_zero_shear_vs_unphased_critique` |
| **Asymmetric Shear & Power-Law Error** | Barycentric shift $d_{\mathrm{bary}} \in [-1,1]$, visibility $\mathcal{V} = \sqrt{1 - d_{\mathrm{bary}}^2}$ | Differential vortex circulation $\Delta\Gamma = (\ell_2 - \ell_1)\kappa_\phi$ & gravitomagnetic swirl | Reciprocal jamming duality $\mathcal{V} = \gamma_\varphi(v)^{-1}$; error $\varepsilon = \frac{\gamma_\varphi - 1}{2\gamma_\varphi} = \frac{K_D(v)}{2 E_\varphi(v)}$ | `MovingSheath.visibility_jamming_duality`, `ddf_sheath_relative_error_eq_jamming`, `ddf_relative_error_power_law_and_inversion`, `MovingSheath.inverse_recovery_from_relative_error` |
| **Anosov Tangent Stretching** | $2 \times 2$ basis transformation $M \mapsto A_{\mathrm{Anosov}}(\lambda,t) M$ | Hyperbolic stretching $\operatorname{diag}(e^{\lambda t}, e^{-\lambda t})$ on the unit tangent bundle | Symplectic area preservation ($\det = 1$) vs. non-symplectic compressive jamming ($\lambda_1 + \lambda_2 \neq 0$) | `anosovHyperbolicMatrix_det_one`, `anosov_plucker_invariance`, `nonSymplectic_jamming_barycentricShift_scaling` |

### 5.1 Exact DDF Jamming–Visibility Duality, Quadratic Power-Law Bounds, and Parameter Inversion

Identifying the reduced sheath speed $\beta = v/c \in [0, 1)$ of a `MovingSheath` with the Plücker barycentric shift magnitude $|d_{\mathrm{bary}}|$ establishes:
1. **Reciprocal Visibility–Jamming Duality (`MovingSheath.visibility_jamming_duality`)**:
   $$\mathcal{V}(s) = \sqrt{1 - \beta^2} = \frac{1}{\gamma_\varphi(v)}, \qquad \beta^2 + \mathcal{V}(s)^2 = 1.$$
2. **Kinetic-Energy Ratio for On-Axis Relative Error (`ddf_sheath_relative_error_eq_jamming`)**:
   $$\varepsilon_{\mathrm{rel}}(0,0) = \frac{1 - \gamma_\varphi(v)^{-1}}{2} = \frac{\gamma_\varphi(v) - 1}{2\,\gamma_\varphi(v)} = \frac{K_D(v)}{2\,\gamma_\varphi(v) m c^2}.$$
3. **Quadratic Power-Law Sandwich & Exact Parameter Inversion (`ddf_relative_error_power_law_and_inversion`, `MovingSheath.inverse_recovery_from_relative_error`)**:
   Answering the power-law and inverse-recovery question in [Provenance Chat Log (2026), lines 226–228](#chat-plucker-sinks-ddf), for every $d_{\mathrm{bary}} \in [-1, 1]$ the on-axis relative error $\varepsilon = (1 - \mathcal{V})/2$ satisfies:
   $$\frac{d_{\mathrm{bary}}^2}{4} \le \varepsilon \le \frac{d_{\mathrm{bary}}^2}{2}, \qquad \mathcal{V} = 1 - 2\varepsilon, \qquad \gamma_\varphi = \frac{1}{1 - 2\varepsilon}, \qquad \beta^2 = d_{\mathrm{bary}}^2 = 4\varepsilon(1 - \varepsilon).$$

### 5.2 Formal Critique & Constructive Resolutions of the Chat Claims

1. **Critique 1 & Resolution — Unphased Sum $w_A + w_B = \Delta_{02}\Delta_{13}$ vs. Squared Crossing Product & Complex $Gr_{\mathbb{C}}(2,4)$ Sink Amplitudes (`ddf_symmetric_zero_shear_vs_unphased_critique`, `ddf_critique1_solved_squared_crossing_and_complex_gr24`)**:
   - *Critique*: The chat prompt and response ([lines 12–30, 140–154](#chat-plucker-sinks-ddf)) state that $w_A + w_B = \Delta_{02}\Delta_{13}$ yields zero relative error against the Fraunhofer reference at the symmetric point $w_A = w_B = 1$. Theorem `ddf_symmetric_zero_shear_vs_unphased_critique` proves that if $w_A + w_B = 2$ is treated as an unphased intensity proxy (`gr24UnphasedDoubleSlit`), it gives $2 I_0$ instead of $4 I_0$ and incurs a $50\%$ ($1/2$) on-axis relative error.
   - *Constructive Resolution (`ddf_critique1_solved_squared_crossing_and_complex_gr24`)*: Treating $Q_A, Q_B$ as **coherent field amplitudes** makes the on-axis intensity proportional to the **squared** crossing product $(\Delta_{02}\Delta_{13})^2 = (Q_A + Q_B)^2 = 4$ (`gr24SquaredCrossingDoubleSlit`), which achieves **exact zero relative error ($\varepsilon_{\mathrm{rel}} = 0$) at $(0, 0)$**. Across the entire detector plane $(x, y) \in \mathbb{R}^2$, lifting to complex sink amplitudes $w_A^{\mathbb{C}}(M_{\mathbb{C}}) = \Delta_{01}^{\mathbb{C}}\Delta_{23}^{\mathbb{C}}$ and $w_B^{\mathbb{C}}(M_{\mathbb{C}}) = \Delta_{03}^{\mathbb{C}}\Delta_{12}^{\mathbb{C}}$ on $Gr_{\mathbb{C}}(2,4)$ satisfies $w_A^{\mathbb{C}} + w_B^{\mathbb{C}} = \Delta_{02}^{\mathbb{C}}\Delta_{13}^{\mathbb{C}}$, so $|\Delta_{02}^{\mathbb{C}}\Delta_{13}^{\mathbb{C}}|^2 = |w_A^{\mathbb{C}} + w_B^{\mathbb{C}}|^2$ achieves **zero relative predictive error everywhere**.
2. **Critique 2 & Resolution — Non-Symplectic Compressive Jamming Invariance via Projective Plücker Normalization & Trace Renormalization (`nonSymplectic_jamming_barycentricShift_scaling`, `gr24_projective_pythagorean_complementarity`, `ddf_critique2_solved_projective_and_trace_renormalized_jamming`)**:
   - *Critique*: While a symplectic Anosov hyperbolic stretch $A_{\mathrm{Anosov}}(\lambda, t) = \operatorname{diag}(e^{\lambda t}, e^{-\lambda t})$ ($\det = 1$) preserves all $2 \times 2$ minors (`anosov_plucker_invariance`), a non-symplectic compressive jamming deformation $B(\lambda_1, \lambda_2, t) = \operatorname{diag}(e^{\lambda_1 t}, e^{\lambda_2 t})$ ($\lambda_1 + \lambda_2 \neq 0$) scales the unnormalized shift $d_{\mathrm{bary}}(BM) = e^{2(\lambda_1 + \lambda_2)t} d_{\mathrm{bary}}(M)$ (`nonSymplectic_jamming_barycentricShift_scaling`).
   - *Constructive Resolution (`ddf_critique2_solved_projective_and_trace_renormalized_jamming`)*: Defining the projectively normalized Plücker barycentric shift and squared visibility (`gr24ProjectiveBarycentricShift`, `gr24ProjectiveVisibilitySq` in [Geometry.lean](../src/signals/Signals/Geometry.lean#L1057-L1168)):
     $$\widehat{d}_{\mathrm{bary}}(M) = \frac{\Delta_{01}\Delta_{23} - \Delta_{03}\Delta_{12}}{\Delta_{02}\Delta_{13}}, \qquad \widehat{\mathcal{V}}_{Gr(2,4)}(M)^2 = \frac{4\,\Delta_{01}\Delta_{23}\,\Delta_{03}\Delta_{12}}{(\Delta_{02}\Delta_{13})^2}, \qquad \widehat{d}_{\mathrm{bary}}(M)^2 + \widehat{\mathcal{V}}_{Gr(2,4)}(M)^2 = 1,$$
     cancels $(\det B)^2 = e^{2(\lambda_1 + \lambda_2)t} > 0$ identically, making $\widehat{d}_{\mathrm{bary}}(BM) = \widehat{d}_{\mathrm{bary}}(M)$ and $\widehat{\mathcal{V}}_{Gr(2,4)}(BM)^2 = \widehat{\mathcal{V}}_{Gr(2,4)}(M)^2$ **exact invariants under arbitrary non-symplectic jamming**. Moreover, factoring out the isotropic trace dilation $e^{-(\lambda_1 + \lambda_2)t/2}$ reduces $B(\lambda_1, \lambda_2, t)$ to $A_{\mathrm{Anosov}}((\lambda_1 - \lambda_2)/2, t)$, which preserves even the unnormalized Plücker minors.
3. **Critique 3 & Resolution — Constitutive DDF Substrate Parameter Recovery & Quantized Gravitomagnetic Swirl (`MovingSheath.ddf_critique3_solved_substrate_parameter_recovery`, `RiverExterior.quantized_vortex_swirl_from_circulation`)**:
   - *Constructive Resolution*: Using $c^2 = (\varrho_{\max}^\varphi j_{\min}^\varphi)^{-1}$ (`DDFSubstrate.c_sq`), `MovingSheath.ddf_critique3_solved_substrate_parameter_recovery` proves that the optical relative error $\varepsilon = (1 - \mathcal{V}(s))/2$ directly determines the constitutive DDF jamming invariant, physical sheath speed squared, and (for $v \neq 0$) the dispersed-phase compressibility-density product:
     $$\varrho_{\max}^\varphi\,j_{\min}^\varphi\,v^2 = 4\varepsilon(1 - \varepsilon), \qquad v^2 = \frac{4\varepsilon(1 - \varepsilon)}{\varrho_{\max}^\varphi\,j_{\min}^\varphi}, \qquad \varrho_{\max}^\varphi\,j_{\min}^\varphi = \frac{4\varepsilon(1 - \varepsilon)}{v^2}.$$
     In addition, `RiverExterior.quantized_vortex_swirl_from_circulation` proves that for quantized differential vortex angular momentum $J = (\ell_2 - \ell_1)\hbar$, the Kerr/Lense–Thirring frame-dragging swirl velocity is governed directly by the differential circulation $\Delta\Gamma(\ell_1, \ell_2)$ and $\varrho_{\max}^\varphi j_{\min}^\varphi$:
     $$v_{\phi,\mathrm{swirl}}\bigl((\ell_2 - \ell_1)\hbar, r\bigr) = \frac{G_\phi m_\phi \varrho_{\max}^\varphi j_{\min}^\varphi}{\pi r^2}\,\Delta\Gamma(\ell_1, \ell_2).$$

### 5.3 Unified Integration of Complex $Gr_{\mathbb{C}}(2,4)$ with DDF (`MovingSheath.gr24TwistorMatrix`)

In [src/signals/Signals/DDF.lean](../src/signals/Signals/DDF.lean#L1215-L1430), `MovingSheath.gr24TwistorMatrix` embeds any subluminal DDF `MovingSheath` $s$ ($\beta(s) = v/c \in [0, 1)$) and differential OAM vortex charge $\Delta\ell \in \mathbb{Z}$ directly into $Gr_{\mathbb{C}}(2,4)$ via the forward- and reverse-sheared $(\phi \pm \varphi)$ twistor channel entries:

$$
z_\pm(s, \theta) = \sqrt{1 \pm \beta(s)}\,e^{\pm i\theta}, \qquad
\theta = \frac{\pi d x}{\lambda L} + \frac{\Delta\ell\,\phi}{2}, \qquad
M_{\mathbb{C}}^{\mathrm{DDF}}(s) = \begin{pmatrix} 1 & 1 & 0 & -1 \\ 0 & z_+(s,\theta) & 1 & z_-(s,\theta) \end{pmatrix}.
$$

We prove four machine-checked unification theorems on $M_{\mathbb{C}}^{\mathrm{DDF}}(s)$:
1. **Madelung Sink-Sector Densities & Jamming Product (`MovingSheath.gr24TwistorMatrix_madelung_sector_identities`)**:
   The complex Plücker sink amplitudes $w_A^{\mathbb{C}}$ and $w_B^{\mathbb{C}}$ have Madelung densities $|w_A^{\mathbb{C}}|^2 = 1 + \beta(s)$ and $|w_B^{\mathbb{C}}|^2 = 1 - \beta(s)$, satisfying $|w_A^{\mathbb{C}}|^2 + |w_B^{\mathbb{C}}|^2 = 2$, $(|w_A^{\mathbb{C}}|^2 - |w_B^{\mathbb{C}}|^2)/2 = \beta(s)$, and
   $$|w_A^{\mathbb{C}}|^2\,|w_B^{\mathbb{C}}|^2 = 1 - \beta(s)^2 = \mathcal{V}(s)^2 = \frac{1}{\gamma_\varphi(v)^2}.$$
2. **Master $Gr_{\mathbb{C}}(2,4)$–DDF Crossing-Minor Unification (`MovingSheath.gr24TwistorMatrix_crossing_eq_ddf_oam_intensity`)**:
   Evaluating `complexGr24CrossingDoubleSlit` on $M_{\mathbb{C}}^{\mathrm{DDF}}(s)$ reproduces `huygensSteinerOAMDoubleSlit` with reciprocal jamming visibility $\gamma_\varphi(v)^{-1}$ **identically at every $(x, y, \phi) \in \mathbb{R}^3$** with **zero relative predictive error**.
3. **Zero-Shear Limit (`MovingSheath.gr24TwistorMatrix_zero_shear_eq_fraunhoferOAM`)**:
   When $v = 0$ ($\gamma_\varphi(0) = 1$), $M_{\mathbb{C}}^{\mathrm{DDF}}(s)$ reproduces `fraunhoferOAMDoubleSlit` with zero relative error everywhere.
4. **$SL(2, \mathbb{C})$ & Complex Anosov Gauge Invariance (`complexGr24_sl2c_crossing_intensity_invariant`)**:
   For any $B_{\mathbb{C}} \in \mathbb{C}^{2 \times 2}$ with $|\det B_{\mathbb{C}}|^2 = 1$, $I_{Gr_{\mathbb{C}}(2,4)}^{\times}(B_{\mathbb{C}} M_{\mathbb{C}}; x, y) = I_{Gr_{\mathbb{C}}(2,4)}^{\times}(M_{\mathbb{C}}; x, y)$.

```lean
open Signals.DDF

-- 5. Constructive Critique 1-3 solutions and Master Gr_C(2,4)-DDF Unification
example {sub : DDFSubstrate} (s : MovingSheath sub)
    (M : Matrix (Fin 2) (Fin 4) ℝ) (rate1 rate2 t φ x y : ℝ) (Δℓ : ℤ) :
    let B : Matrix (Fin 2) (Fin 2) ℝ :=
      !![Real.exp (rate1 * t), 0; 0, Real.exp (rate2 * t)]
    let M_C := s.gr24TwistorMatrix 6 1 5 Δℓ φ x
    (pluckerSinkFluxA M + pluckerSinkFluxB M = twoRowMinor M 0 2 * twoRowMinor M 1 3 ∧
      (pluckerSinkFluxA M - pluckerSinkFluxB M) / 2 = gr24BarycentricShift M) ∧
    gr24ProjectiveBarycentricShift (B * M) = gr24ProjectiveBarycentricShift M ∧
    gr24ProjectiveVisibilitySq (B * M) = gr24ProjectiveVisibilitySq M ∧
    Complex.normSq (complexPluckerSinkAmplitudeA M_C) *
      Complex.normSq (complexPluckerSinkAmplitudeB M_C) = (s.jammingFactor ^ 2)⁻¹ ∧
    complexGr24CrossingDoubleSlit M_C 3 2 4 1 5 x y =
      huygensSteinerOAMDoubleSlit 3 2 4 6 1 5 (s.jammingFactor)⁻¹ Δℓ φ x y ∧
    relativePredictiveError
      (complexGr24CrossingDoubleSlit M_C 3 2 4 1 5 x y)
      (huygensSteinerOAMDoubleSlit 3 2 4 6 1 5 (s.jammingFactor)⁻¹ Δℓ φ x y) = 0 := by
  intro B M_C
  have h_jam := ddf_critique2_solved_projective_and_trace_renormalized_jamming M rate1 rate2 t
  have h_mad := s.gr24TwistorMatrix_madelung_sector_identities 6 1 5 Δℓ φ x
  have h_unif := s.gr24TwistorMatrix_crossing_eq_ddf_oam_intensity 3 2 4 6 1 5 Δℓ φ x y
  exact ⟨pluckerSinkFlux_conservation_and_asymmetry M, h_jam.1, h_jam.2.1,
    h_mad.2.2.2.2.1.trans h_mad.2.2.2.2.2, h_unif.1, h_unif.2⟩

end ArxivDoubleSlitPaperVerification
```

---

## 6. Conclusion & Reproducibility

By formalizing five-model double-slit and OAM superposition (`Signals.Geometry`, `Signals.Coherence`, `Signals.Huygens`, `Signals.DDF`, `Signals.OAM`, `Signals.SolitonBus`) in Lean 4 and implementing all $N$-slit ($N > 0$) models in Rust, WebAssembly (`wasm32-unknown-unknown`), and WebGL2 GLSL (`src/signals/numerical_adapter/`), we have demonstrated that:
1. The 3-term Plücker identity on $Gr(2,4)$ induces the universal Pythagorean Plücker–Steiner identity $d_{\mathrm{bary}}(M)^2 + \mathcal{V}_{Gr(2,4)}(M)^2 = (\Delta_{02}\Delta_{13}/2)^2$, directly connecting Grassmannian boundary channel weights and hydrodynamic sink fluxes to the barycentric parallel-axis coherence theorem of [Qian and Izadi (2023)](#qian-izadi2023).
2. Lifting from the real positive Grassmannian $Gr_{\ge 0}(2,4)$ to the complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ (carrying $\mathbb{C}^4$ twistor phases) eliminates the $50\%$ unphased crossing-minor error completely and matches the partially coherent Huygens–Steiner profile $I_{\mathrm{HS}}(x,y;\sqrt{1 - d_{\mathrm{bary}}^2})$ (and its helical OAM generalization) identically across the entire screen for all $d_{\mathrm{bary}} \in [-1, 1]$.
3. Identifying $|d_{\mathrm{bary}}|$ with the reduced DDF shear speed $\beta = v/c$ yields the exact reciprocal duality $\mathcal{V} = \gamma_\varphi(v)^{-1}$, the tight quadratic error bounds $d_{\mathrm{bary}}^2 / 4 \le \varepsilon \le d_{\mathrm{bary}}^2 / 2$, the exact inversion $d_{\mathrm{bary}}^2 = 4\varepsilon(1 - \varepsilon)$, and symplectic Anosov hyperbolic invariance of all $2 \times 2$ Plücker minors.

To reproduce all Lean proofs, blueprint artifacts, and Rust/WASM builds from the repository root:

```bash
make signals_build
pushd src/signals
lake build :blueprint :blueprintJson
pushd numerical_adapter
cargo test
cargo build --lib --target wasm32-unknown-unknown --release
popd
popd
```

---

### Scholarly References

<a id="qian-izadi2023"></a>
1. Qian, X.-F., and Izadi, M. (2023). *Bridging Coherence Optics and Classical Mechanics: A Generic Light Polarization-Entanglement Complementary Relation*. Physical Review Research 5(3), 033110. [DOI: 10.1103/PhysRevResearch.5.033110](https://doi.org/10.1103/PhysRevResearch.5.033110). ({download}`Local PDF, pp. 1-6 <../data/papers/PhysRevResearch.5.033110.pdf>`).

<a id="postnikov2006"></a>
2. Postnikov, A. (2006). *Total Positivity, Grassmannians, and Networks*. [arXiv:math/0609764](https://arxiv.org/abs/math/0609764).

<a id="arkani-hamed-trnka2014"></a>
3. Arkani-Hamed, N., and Trnka, J. (2014). *The Amplituhedron*. Journal of High Energy Physics 2014(10), 030. [DOI: 10.1007/JHEP10(2014)030](https://doi.org/10.1007/JHEP10%282014%29030); [arXiv:1312.2007](https://arxiv.org/abs/1312.2007).

<a id="arkani-hamed-bai-lam2017"></a>
4. Arkani-Hamed, N., Bai, Y., and Lam, T. (2017). *Positive Geometries and Canonical Forms*. Journal of High Energy Physics 2017(11), 039. [DOI: 10.1007/JHEP11(2017)039](https://doi.org/10.1007/JHEP11%282017%29039); [arXiv:1703.04541](https://arxiv.org/abs/1703.04541).

<a id="partanen-tulkki2025"></a>
5. Partanen, M., and Tulkki, J. (2025). *Gravity Generated by Four One-Dimensional Unitary Gauge Symmetries and the Standard Model*. Reports on Progress in Physics 88, 057802; [arXiv:2506.14447](https://arxiv.org/abs/2506.14447).

<a id="fedi2026"></a>
6. Fedi, M. (2026). *Dilatant Dark Fluid: Toward a Unified Quantum-Hydrodynamic Origin of Lorentz Invariance, Gravity, and Cosmological Phenomenology*. SSRN Preprint 7406660.

<a id="chat-grassmannian-huygens"></a>
7. Provenance Chat Log (2026). *Grassmannian Huygens Principle and Amplituhedron*. ({download}`data/chats/Grassmannian-Huygens-Principle-Amplituhedron.md, lines 9-520 <../data/chats/Grassmannian-Huygens-Principle-Amplituhedron.md>`).

<a id="chat-plucker-sinks-ddf"></a>
8. Provenance Chat Log (2026). *Plücker Channel Weights, Hydrodynamic Sinks, Anosov Flows, and Dilatant Dark Fluid*. ({download}`data/chats/Google-Search_I've-discovered-a-remarkable-identity-the-sum-of-two-slit-channel-weights,-$w_A-+-w_B$,-precisely-equals-a-specific-Plü_20261024-0322.md, lines 6-228 <../data/chats/Google-Search_I've-discovered-a-remarkable-identity-the-sum-of-two-slit-channel-weights,-$w_A-+-w_B$,-precisely-equals-a-specific-Plü_20261024-0322.md>`).

---

### BibTeX Citations

```bibtex
@article{qian2023bridging,
  author  = {Qian, Xiao-Feng and Izadi, Misagh},
  title   = {Bridging Coherence Optics and Classical Mechanics: A Generic Light Polarization-Entanglement Complementary Relation},
  journal = {Physical Review Research},
  volume  = {5},
  number  = {3},
  pages   = {033110},
  year    = {2023},
  doi     = {10.1103/PhysRevResearch.5.033110}
}

@article{arkani2014amplituhedron,
  author  = {Arkani-Hamed, Nima and Trnka, Jaroslav},
  title   = {The {A}mplituhedron},
  journal = {Journal of High Energy Physics},
  volume  = {2014},
  number  = {10},
  pages   = {030},
  year    = {2014},
  doi     = {10.1007/JHEP10(2014)030}
}

@misc{chat_grassmannian_huygens_2026,
  author       = {{Unknown}},
  title        = {Grassmannian {H}uygens Principle and {A}mplituhedron},
  year         = {2026},
  howpublished = {AI chat log},
  note         = {Source: data/chats/Grassmannian-Huygens-Principle-Amplituhedron.md, lines 9-520}
}

@misc{chat_plucker_sinks_ddf_2026,
  author       = {{Unknown}},
  title        = {Pl{\"u}cker Channel Weights, Hydrodynamic Sinks, {A}nosov Flows, and {D}ilatant {D}ark {F}luid},
  year         = {2026},
  howpublished = {AI chat log},
  note         = {Source: data/chats/Google-Search_I've-discovered-a-remarkable-identity-the-sum-of-two-slit-channel-weights,-$w_A-+-w_B$,-precisely-equals-a-specific-Plü_20261024-0322.md, lines 6-228}
}
```

### Schema.org Metadata (JSON-LD)

```json
{
  "@context": "https://schema.org",
  "@type": "ScholarlyArticle",
  "headline": "Huygens-Steiner Barycentric Coherence, Complex Gr_C(2,4) Plucker Channels, and Multi-Model Double-Slit & OAM Relative Predictive Error in Lean 4",
  "author": {
    "@type": "Person",
    "name": "Wes Turner"
  },
  "dateModified": "2026-10-24",
  "about": [
    "Huygens-Steiner Parallel Axis Theorem",
    "Grassmannian Geometry",
    "Double-Slit Interference",
    "Orbital Angular Momentum",
    "Dilatant Dark Fluid",
    "Anosov Flows",
    "Pilot-Wave Theory",
    "Wigner Function",
    "Lean 4 Formal Verification"
  ],
  "isBasedOn": [
    "data/papers/PhysRevResearch.5.033110.pdf",
    "data/chats/Grassmannian-Huygens-Principle-Amplituhedron.md",
    "data/chats/Google-Search_I've-discovered-a-remarkable-identity-the-sum-of-two-slit-channel-weights,-$w_A-+-w_B$,-precisely-equals-a-specific-Plü_20261024-0322.md",
    "src/signals/Signals/Geometry.lean",
    "src/signals/Signals/Coherence.lean",
    "src/signals/Signals/Huygens.lean",
    "src/signals/Signals/OAM.lean",
    "src/signals/Signals/DDF.lean",
    "src/signals/Signals/SolitonBus.lean"
  ]
}
```
