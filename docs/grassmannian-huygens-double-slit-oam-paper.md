---
title: "Huygens–Steiner Barycentric Coherence, Complex Gr_C(2,4) Plücker Channels, and Multi-Model Double-Slit & OAM Relative Predictive Error in Lean 4"
description: "An arXiv-ready formal verification paper uniting Qian–Izadi Huygens–Steiner parallel-axis coherence, complex Gr_C(2,4) Plücker double-slit interference, de Broglie–Bohm pilot-wave hydrodynamics, Wigner phase-space marginals, and Orbital Angular Momentum (OAM) relative predictive error in Lean 4."
---

(grassmannian-huygens-double-slit-oam-paper)=
# Huygens–Steiner Barycentric Coherence, Complex $Gr_{\mathbb{C}}(2,4)$ Plücker Channels, and Multi-Model Double-Slit & OAM Relative Predictive Error in Lean 4

**Authors:** Wes Turner
**Subjects:** Optics (`physics.optics`); Quantum Physics (`quant-ph`); Mathematical Physics (`math-ph`); Logic in Computer Science (`cs.LO`)
**Formal Verification Artifact:** `Signals` Lean 4 Library (`leanprover/lean4:v4.35.0-rc3`, Mathlib `v4.35.0-rc3`)
**Companion Paper:** [Grassmannian Geometry of the Quantum Inverse Scattering Method, Algebraic Bethe Ansatz, and Inverse Scattering Metrology in Lean 4](grassmannian-qism-bethe-ansatz-paper.myst.md)

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

*(Note: The companion application of the same verified $2 \times n$ Grassmannian Plücker kernel `Signals.Geometry.twoRowMinor_pluecker` to Baxter's $QQ$-system, $TQ$ Wronskians, and the Quantum Inverse Scattering Method is presented in the companion paper [Grassmannian Geometry of the Quantum Inverse Scattering Method, Algebraic Bethe Ansatz, and Inverse Scattering Metrology in Lean 4](grassmannian-qism-bethe-ansatz-paper.myst.md).)*

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
| **3. $Gr(2,4)$ / $Gr_{\mathbb{C}}(2,4)$ Plücker & Twistor OAM Shear** | `gr24PluckerDoubleSlit`, `complexGr24CrossingDoubleSlit`, `Signals.Geometry.AngularMomentumState.translate_angularMomentum` | Complex channel entries $z_{1,2} = \sqrt{1 \pm d_{\mathrm{bary}}}\,e^{\pm i(\theta + \Delta\ell\,\phi/2)}$ in $M_{\mathbb{C}}(z_1, z_2)$ | $\varepsilon_{\mathrm{rel}} = 0$ against $I_{\mathrm{HS,OAM}}$ for all $(x,y,\phi)$ and $d_{\mathrm{bary}} \in [-1,1]$; $\varepsilon_{\mathrm{rel}} = 1/2$ if real $Gr_{\ge 0}(2,4)$ omits the helical phase. |
| **4. Pilot-Wave / Madelung Vortex Hydrodynamics** | `pilotWaveDoubleSlit`, `Signals.DDF.vortexTangentialVelocity`, `Signals.DDF.quantized_vortex_circulation`, `Signals.DDF.plaquette_phase_slip_syndrome` | $I_{\mathrm{PW,OAM}} = I_{\mathrm{F,OAM}}(x,y,\phi;\Delta\ell) + \delta_{\mathrm{neq}}$, with azimuthal guiding velocity $v_\theta = \frac{\hbar \ell}{m R}$ and quantized circulation $\oint \mathbf{v}\cdot d\boldsymbol{\ell} = \ell\frac{2\pi\hbar}{m}$ | Exact ($\varepsilon_{\mathrm{rel}} = 0$) in quantum equilibrium ($\delta_{\mathrm{neq}} = 0$); Bohmian trajectories spiral around the $2\pi\Delta\ell$ plaquette phase-slip singularities, with $\varepsilon_{\mathrm{rel}}(0,0,0) = \frac{|\delta_{\mathrm{neq}}|}{4I_0}$. |
| **5. Wigner Angle–OAM Phase-Space Marginal** | `wignerOAMDoubleSlit`, `wignerOAM_onAxis_relative_error` | $I_{\mathrm{Wigner,OAM}}(x,y,\phi;\Delta\ell,\gamma_{\mathrm{OAM}}) = 2 I_0 E_{\mathrm{slit}}(x,y)\bigl(1 + e^{-\gamma_{\mathrm{OAM}}(\Delta\ell)^2}\cos(\frac{2\pi d x}{\lambda L} + \Delta\ell\,\phi)\bigr)$ | Rotational phase-space diffusion scales quadratically with $(\Delta\ell)^2$: $\varepsilon_{\mathrm{rel}}(0,0,0;\Delta\ell) = \frac{1 - e^{-\gamma_{\mathrm{OAM}}(\Delta\ell)^2}}{2}$, which vanishes for $\Delta\ell = 0$ or $\gamma_{\mathrm{OAM}} = 0$. |

```lean
-- 4. OAM vortex null at (Δℓ = 1, φ = π) and quadratic (Δℓ)² Wigner rotational error scaling
example (γ_oam : ℝ) (h_dec : 0 ≤ γ_oam) (Δℓ : ℤ) :
    fraunhoferOAMDoubleSlit 3 2 4 6 1 5 1 Real.pi 0 0 = 0 ∧
    relativePredictiveError
      (fraunhoferOAMDoubleSlit 3 2 4 6 1 5 1 Real.pi 0 0)
      (fraunhoferRectangularDoubleSlit 3 2 4 6 1 5 0 0) = 1 ∧
    relativePredictiveError
      (wignerOAMDoubleSlit 3 2 4 6 1 5 γ_oam Δℓ 0 0 0)
      (fraunhoferOAMDoubleSlit 3 2 4 6 1 5 Δℓ 0 0 0) =
      (1 - Real.exp (- (γ_oam * (Δℓ : ℝ) ^ 2))) / 2 :=
  ⟨(fraunhoferOAMDoubleSlit_vortex_null_at_pi 3 2 4 6 1 5 (by norm_num)).1,
    (fraunhoferOAMDoubleSlit_vortex_null_at_pi 3 2 4 6 1 5 (by norm_num)).2,
    wignerOAM_onAxis_relative_error 3 2 4 6 1 5 γ_oam Δℓ (by norm_num) h_dec⟩

end ArxivDoubleSlitPaperVerification
```

---

## 5. Conclusion & Reproducibility

By formalizing five-model double-slit and OAM superposition (`Signals.Geometry`, `Signals.Coherence`, `Signals.Huygens`, `Signals.DDF`, `Signals.OAM`) in Lean 4, we have demonstrated that:
1. The 3-term Plücker identity on $Gr(2,4)$ induces the universal Pythagorean Plücker–Steiner identity $d_{\mathrm{bary}}(M)^2 + \mathcal{V}_{Gr(2,4)}(M)^2 = (\Delta_{02}\Delta_{13}/2)^2$, directly connecting Grassmannian boundary channel weights to the barycentric parallel-axis coherence theorem of [Qian and Izadi (2023)](#qian-izadi2023).
2. Lifting from the real positive Grassmannian $Gr_{\ge 0}(2,4)$ to the complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ (carrying $\mathbb{C}^4$ twistor phases) eliminates the $50\%$ unphased crossing-minor error completely and matches the partially coherent Huygens–Steiner profile $I_{\mathrm{HS}}(x,y;\sqrt{1 - d_{\mathrm{bary}}^2})$ identically across the entire screen for all $d_{\mathrm{bary}} \in [-1, 1]$.

To reproduce all Lean proofs and blueprint artifacts from the repository root:

```bash
make signals_build
pushd src/signals
lake build :blueprint :blueprintJson
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

<a id="chat-grassmannian-huygens"></a>
5. Provenance Chat Log (2026). *Grassmannian Huygens Principle and Amplituhedron*. ({download}`data/chats/Grassmannian-Huygens-Principle-Amplituhedron.md, lines 9-520 <../data/chats/Grassmannian-Huygens-Principle-Amplituhedron.md>`).

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
    "Pilot-Wave Theory",
    "Wigner Function",
    "Lean 4 Formal Verification"
  ],
  "isBasedOn": [
    "data/papers/PhysRevResearch.5.033110.pdf",
    "data/chats/Grassmannian-Huygens-Principle-Amplituhedron.md",
    "src/signals/Signals/Geometry.lean",
    "src/signals/Signals/Coherence.lean",
    "src/signals/Signals/Huygens.lean",
    "src/signals/Signals/OAM.lean",
    "src/signals/Signals/DDF.lean"
  ]
}
```
