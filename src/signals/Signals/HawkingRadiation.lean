import Architect
import Signals.DDF

namespace Signals.HawkingRadiation

open Complex Signals.Geometry Signals.Huygens Signals.Scattering Signals.QEDGravity Signals.DDF

/-! # Hawking Radiation, Gordon Acoustic Metrics, Splat Fracture Mechanics, and WGSL Eigen/Quaternion Algebra (With and Without DDF, With and Without Splats)

This module separates black-hole horizon thermodynamics, Hawking radiation, analog
acoustic metrics, and quantum-fracture tensor-splat mechanics from the flat-space
post-Minkowskian QED/gauge scattering double copy in `Signals.QEDGravity`:

1. **Quadrant I (`Without DDF, Without Splats`): Semiclassical Schwarzschild Horizon Thermodynamics, Photon-Sphere Diffraction, & Sgr A* / S301 Kerr Order Hierarchy**:
   - Schwarzschild gravitational radius $r_S = \frac{2 G M}{c^2}$, photon-sphere radius
     $r_{\mathrm{ph}} = \frac{3 G M}{c^2} = \frac{3}{2} r_S$, and the microscopic black-hole
     ray-optics vs. wave-optics diffraction criterion $\lambda \le 2 r_{\mathrm{ph}} = 3 r_S$
     (`_Airy-Beams-and-Communications-and-Illumination.md`, lines 780–805).
   - Semiclassical Hawking (1975) temperature $T_H = \frac{\hbar\kappa_S}{2\pi k_B c} = \frac{\hbar c^3}{8\pi G M k_B}$,
     Bekenstein–Hawking entropy $S_{\mathrm{BH}} = \frac{k_B A_S}{4\ell_P^2}$, Gauss–Smarr
     bulk mass recovery $\frac{\kappa_S A_S}{4\pi G} = M$, First-Law product
     $T_H S_{\mathrm{BH}} = \frac{\hbar c r_S}{4\ell_P^2} = \frac{G M \hbar}{2 c \ell_P^2}$,
     and continuum $Gr_{\mathbb{C}}(2,4)$ Schwarzschild lapse $|w_A^{\mathbb{C}}(M_S)|^2|w_B^{\mathbb{C}}(M_S)|^2 = 1 - r_S / r$.
   - Sgr A* / S301 relativistic pericenter velocity hierarchy (`Superfluid-Quantum-Gravity-and-Hawking-Radiation.md`,
     lines 2925–2985): dominant Schwarzschild redshift/precession order $\beta^2 = (v/c)^2$
     vs. Kerr spin frame-dragging order $\beta^3 = (v/c)^3$ ($0 < \beta^3 < \beta^2 < \beta < 1$,
     with $\beta_{\mathrm{S301}} = 1/12 \implies \beta^2 = 1/144, \beta^3 = 1/1728$).
2. **Gordon Acoustic Metric, Quartic GPE Self-Interaction Pressure $|\psi|^4$, & Penrose Spinor/Twistor 4-Periodicity (`_Special-Relativity-Geometry-vs.-Fluid.md`, lines 790–945)**:
   - Gordon acoustic metric temporal component $g_{00}^{\mathrm{Gordon}}(\rho_0, c_s, v) = -\frac{\rho_0}{c_s}(c_s^2 - v^2)$,
     its sonic horizon root at $v^2 = c_s^2$, and its exact equivalence to the DDF
     Painlevé–Gullstrand lapse $1 - r_H / r = |w_A^{\mathbb{C}}(M_{\mathrm{holo}}(r))|^2|w_B^{\mathbb{C}}(M_{\mathrm{holo}}(r))|^2$.
   - Quartic Gross–Pitaevskii self-interaction pressure $P_{\mathrm{GPE}}(g, \rho) = \frac{g}{2}\rho^2 = \frac{g}{2}|\psi|^4$.
   - Spinor phase 4-periodicity ($i^2 = -1$, $i^4 = 1$) and Penrose's Hermitian Pauli
     spacetime spinor matrix $X^{AA'}(t, x, y, z) \in \mathbb{C}^{2 \times 2}$ satisfying
     $\det X^{AA'}(t, x, y, z) = \frac{1}{2}(t^2 - x^2 - y^2 - z^2)$.
3. **Quadrant III (`With DDF, Without Splats`): DDF Acoustic Hawking Temperature, Hydrodynamic `iGPE` Potential Unwinding, & S301 Test-Star Pericenter Stress Wake**:
   - `RiverExterior.hawkingTemperature` and its dispersed-phase $(\varrho_{\max}^\varphi j_{\min}^\varphi)^{-3}$ scaling.
   - Hydrodynamic `iGPE` / Madelung inverse potential reconstruction `madelungInversePotentialReconstruction`,
     zeroing `quantumHamiltonJacobiResidual` and unwinding `RiverExterior` to $-m_\phi G_\phi M / r$.
   - S301 test-star pericenter vs. aphelion velocity factor and stress-wake amplification (`testStarWakeStress`).
4. **Quadrant IV (`With DDF, With Splats`): 2D & 3D Splat Quantum Fracture ($90^\circ$ Snap & Isotropic Trace Swell), Vieta $3 \times 3$ Cubic Invariants, and WGSL Matrix-to-Quaternion / Instance-Matrix Volume Preservation**:
   - 2D (`rotateOrthogonal90`, `isotropicTraceSwell`) and 3D (`snapOrthogonalXZ`, `isotropicTraceSwell3D`)
     tensor-splat topological fracture, right-handed eigenvector swap determinant $+1$ vs.
     unnegated swap determinant $-1$, AM–GM covariance determinant expansion, and core
     Bohm quantum-potential burst release $\Delta Q_{\mathrm{core}} > 0$.
   - Vieta $3 \times 3$ symmetric eigenvalue trace conservation and WGSL unit-quaternion
     $4 \times 4$ `compose_instance_matrix` determinant $\det M_{\mathrm{inst}}^{(3\times 3)} = s_x s_y s_z (q_x^2 + q_y^2 + q_z^2 + q_w^2)^3$.
-/

/-! ## Section 1: Semiclassical Schwarzschild Horizon Thermodynamics, Photon Sphere, & S301 Kerr Hierarchy (Without DDF) -/

/-- Schwarzschild gravitational radius $r_S = \frac{2 G M}{c^2}$ (without DDF). -/
@[blueprint "def:signals-hawking-schwarzschild-radius"
  (title := "Schwarzschild gravitational radius r_S = 2 G M / c² (without DDF)")
  (statement := /-- For gravitational constant $G$, mass $M$, and speed of light $c$, define
    $r_S(G,M,c) = \frac{2 G M}{c^2}$. -/)]
noncomputable def schwarzschildRadius (G M c : ℝ) : ℝ :=
  2 * G * M / c ^ 2

alias schwarzschildRadiusPM := schwarzschildRadius

/-- Relativistic photon-sphere radius $r_{\mathrm{ph}} = \frac{3 G M}{c^2} = \frac{3}{2} r_S$
where null geodesics orbit in a circle (`_Airy-Beams-and-Communications-and-Illumination.md`, lines 780–795). -/
@[blueprint "def:signals-hawking-photon-sphere-radius"
  (title := "Relativistic photon-sphere radius r_ph = 3 G M / c² = (3/2) r_S")
  (statement := /-- Define $r_{\mathrm{ph}}(G,M,c) = \frac{3 G M}{c^2}$. -/)]
noncomputable def photonSphereRadius (G M c : ℝ) : ℝ :=
  3 * G * M / c ^ 2

/-- Ray-optics reflection vs. wave-optics diffraction criterion for a black-hole photon sphere:
electromagnetic radiation of wavelength $\lambda$ resolves the photon-sphere diameter
$2 r_{\mathrm{ph}} = 3 r_S$ in the ray-optics regime iff $\lambda \le 2 r_{\mathrm{ph}}$
(`_Airy-Beams-and-Communications-and-Illumination.md`, lines 785–805). -/
def photonSphereRayOpticsResolved (wavelength G M c : ℝ) : Prop :=
  wavelength ≤ 2 * photonSphereRadius G M c

/-- 2D Schwarzschild event-horizon screen area $A_S = 4\pi r_S^2$ (without DDF). -/
@[blueprint "def:signals-hawking-schwarzschild-horizon-area"
  (title := "Schwarzschild horizon screen area A_S = 4π r_S² (without DDF)")
  (statement := /-- Define $A_S(G,M,c) = 4\pi\,r_S(G,M,c)^2$. -/)]
noncomputable def schwarzschildHorizonArea (G M c : ℝ) : ℝ :=
  4 * Real.pi * (schwarzschildRadius G M c) ^ 2

alias schwarzschildHorizonAreaPM := schwarzschildHorizonArea

/-- Schwarzschild horizon surface gravity $\kappa_S = \frac{c^2}{2 r_S} = \frac{c^4}{4 G M}$ (without DDF). -/
@[blueprint "def:signals-hawking-schwarzschild-surface-gravity"
  (title := "Schwarzschild horizon surface gravity κ_S = c² / (2 r_S) (without DDF)")
  (statement := /-- Define $\kappa_S(G,M,c) = \frac{c^2}{2\,r_S(G,M,c)}$. -/)]
noncomputable def schwarzschildSurfaceGravity (G M c : ℝ) : ℝ :=
  c ^ 2 / (2 * schwarzschildRadius G M c)

alias schwarzschildSurfaceGravityPM := schwarzschildSurfaceGravity

/-- Semiclassical Hawking (1975) horizon temperature
$T_H = \frac{\hbar\,\kappa_S}{2\pi\,k_B\,c} = \frac{\hbar\,c^3}{8\pi\,G\,M\,k_B}$ (without DDF). -/
@[blueprint "def:signals-hawking-temperature-semiclassical"
  (title := "Semiclassical Hawking horizon temperature T_H = ℏ κ_S / (2π k_B c) (without DDF)")
  (statement := /-- Define $T_H(\hbar,k_B,G,M,c) = \frac{\hbar\,\kappa_S(G,M,c)}{2\pi\,k_B\,c}$. -/)]
noncomputable def hawkingTemperature (hbar k_B G M c : ℝ) : ℝ :=
  hbar * schwarzschildSurfaceGravity G M c / (2 * Real.pi * k_B * c)

alias hawkingTemperaturePM := hawkingTemperature

/-- Bekenstein–Hawking (1973/1975) horizon entropy
$S_{\mathrm{BH}} = \frac{k_B\,A_S}{4\,\ell_P^2} = \frac{\pi\,k_B\,r_S^2}{\ell_P^2}$ (without DDF). -/
@[blueprint "def:signals-hawking-bekenstein-hawking-entropy-semiclassical"
  (title := "Bekenstein-Hawking horizon entropy S_BH = k_B A_S / (4 ℓ_P²) (without DDF)")
  (statement := /-- Define $S_{\mathrm{BH}}(k_B,\ell_P,G,M,c) = \frac{k_B\,A_S(G,M,c)}{4\ell_P^2}$. -/)]
noncomputable def bekensteinHawkingEntropy (k_B l_planck G M c : ℝ) : ℝ :=
  k_B * schwarzschildHorizonArea G M c / (4 * l_planck ^ 2)

alias bekensteinHawkingEntropyPM := bekensteinHawkingEntropy

/-- Dominant Schwarzschild relativistic correction order $\beta^2 = (v/c)^2$
(gravitational redshift, transverse Doppler effect, and prograde Schwarzschild precession;
`Superfluid-Quantum-Gravity-and-Hawking-Radiation.md`, lines 2925–2940). -/
def schwarzschildRelativisticOrder (beta : ℝ) : ℝ :=
  beta ^ 2

/-- Subleading Kerr / Lense–Thirring spin frame-dragging correction order $\beta^3 = (v/c)^3$
probed by high-pericenter-velocity stars such as S301 around Sgr A*
(`Superfluid-Quantum-Gravity-and-Hawking-Radiation.md`, lines 2925–2985). -/
def kerrSpinFrameDraggingOrder (beta : ℝ) : ℝ :=
  beta ^ 3

/-- **Master Theorem for Semiclassical Hawking Thermodynamics, Photon Sphere, S301 Kerr Hierarchy, & $Gr_{\mathbb{C}}(2,4)$ Schwarzschild Lapse (Without DDF, Without Splats)**:
For positive physical constants $G, M, c, \hbar, k_B, \ell_P > 0$, exterior radius $r > r_S(G, M, c)$,
and subluminal stellar speed ratio $\beta \in (0, 1)$:
1. **Positivity, Photon-Sphere Ratio, & Explicit Hawking (1975) Temperature Law**:
   $$0 < r_S, \quad r_{\mathrm{ph}} = \frac{3}{2}r_S > r_S, \quad 0 < \kappa_S, \quad 0 < T_H, \quad 0 < S_{\mathrm{BH}},$$
   $$T_H = \frac{\hbar\,c^3}{8\pi\,G\,M\,k_B}, \qquad T_H \cdot M = \frac{\hbar\,c^3}{8\pi\,G\,k_B},$$
2. **Gauss–Smarr 2D-to-3D Bulk Mass Recovery & First-Law Product (Without DDF)**:
   $$\frac{\kappa_S\,A_S}{4\pi\,G} = M, \qquad
   T_H \cdot S_{\mathrm{BH}} = \frac{\hbar\,c\,r_S}{4\,\ell_P^2} = \frac{G\,M\,\hbar}{2\,c\,\ell_P^2},$$
3. **Splat-Free Continuum $Gr_{\mathbb{C}}(2,4)$ Schwarzschild Redshift Lapse (Without DDF)**:
   For $\beta_S = \sqrt{r_S / r} \in (0, 1)$ and $M_S = \operatorname{complexGr24ChannelMatrix}\bigl(\sqrt{1+\beta_S}e^{i\theta}, \sqrt{1-\beta_S}e^{-i\theta}\bigr)$,
   $$\bigl|w_A^{\mathbb{C}}(M_S)\bigr|^2\,\bigl|w_B^{\mathbb{C}}(M_S)\bigr|^2 = 1 - \frac{r_S}{r} > 0,$$
4. **S301 / Sgr A* Kerr Frame-Dragging ($\beta^3$) vs. Schwarzschild ($\beta^2$) Hierarchy**:
   $$0 < \beta^3 < \beta^2 < \beta < 1, \qquad
   \operatorname{schwarzschildRelativisticOrder}(1/12) = \frac{1}{144}, \qquad
   \operatorname{kerrSpinFrameDraggingOrder}(1/12) = \frac{1}{1728}.$$ -/
@[blueprint "thm:signals-hawking-thermodynamics-without-ddf"
  (title := "Semiclassical Hawking temperature T_H = ℏ c³ / (8π G M k_B), photon sphere, S301 Kerr β³ hierarchy, and Gr_C(2,4) Schwarzschild lapse (without DDF, without splats)")
  (statement := /-- For $G,M,c,\hbar,k_B,\ell_P > 0$, $r > r_S(G,M,c)$, and $0 < \beta < 1$:
    (1) $0 < r_S$, $r_{\mathrm{ph}} = \frac{3}{2}r_S$, $r_S < r_{\mathrm{ph}}$, $0 < \kappa_S$, $0 < T_H$, $0 < S_{\mathrm{BH}}$,
    $T_H = \frac{\hbar c^3}{8\pi G M k_B}$, and $T_H \cdot M = \frac{\hbar c^3}{8\pi G k_B}$;
    (2) $\frac{\kappa_S A_S}{4\pi G} = M$ and $T_H \cdot S_{\mathrm{BH}} = \frac{\hbar c\,r_S}{4\ell_P^2} = \frac{G M \hbar}{2 c \ell_P^2}$;
    (3) for $\beta_S = \sqrt{r_S/r}$ and $M_S = M_{\mathbb C}(\sqrt{1+\beta_S}e^{i\theta}, \sqrt{1-\beta_S}e^{-i\theta})$,
    $|w_A^{\mathbb C}(M_S)|^2|w_B^{\mathbb C}(M_S)|^2 = 1 - r_S / r > 0$;
    (4) $0 < \beta^3 < \beta^2 < \beta$, $(1/12)^2 = 1/144$, and $(1/12)^3 = 1/1728$. -/)
  (proof := /-- Expand \texttt{schwarzschildRadius}, \texttt{photonSphereRadius}, \texttt{schwarzschildSurfaceGravity},
    \texttt{hawkingTemperature}, and \texttt{bekensteinHawkingEntropy}, clear nonzero denominators,
    evaluate \texttt{complexGr24ChannelMatrix\_minors} at $\beta_S = \sqrt{r_S/r}$, and close $\beta^3 < \beta^2$ by \texttt{nlinarith}. -/)]
theorem hawking_thermodynamics_without_ddf_identities
    (G M c hbar k_B l_planck r θ beta : ℝ)
    (hG : 0 < G) (hM : 0 < M) (hc : 0 < c)
    (hhbar : 0 < hbar) (hkB : 0 < k_B) (hlp : 0 < l_planck)
    (hr_gt : schwarzschildRadius G M c < r)
    (hbeta_pos : 0 < beta) (hbeta_lt : beta < 1) :
    let r_S := schwarzschildRadius G M c
    let r_ph := photonSphereRadius G M c
    let A_S := schwarzschildHorizonArea G M c
    let κ_S := schwarzschildSurfaceGravity G M c
    let T_H := hawkingTemperature hbar k_B G M c
    let S_BH := bekensteinHawkingEntropy k_B l_planck G M c
    let beta_S := Real.sqrt (r_S / r)
    let z1 : ℂ := ↑(Real.sqrt (1 + beta_S) * Real.cos θ) +
      Complex.I * ↑(Real.sqrt (1 + beta_S) * Real.sin θ)
    let z2 : ℂ := ↑(Real.sqrt (1 - beta_S) * Real.cos θ) -
      Complex.I * ↑(Real.sqrt (1 - beta_S) * Real.sin θ)
    let M_S := complexGr24ChannelMatrix z1 z2
    0 < r_S ∧
      r_ph = (3 / 2 : ℝ) * r_S ∧
      r_S < r_ph ∧
      0 < κ_S ∧
      0 < T_H ∧
      0 < S_BH ∧
      T_H = hbar * c ^ 3 / (8 * Real.pi * G * M * k_B) ∧
      T_H * M = hbar * c ^ 3 / (8 * Real.pi * G * k_B) ∧
      (κ_S * A_S) / (4 * Real.pi * G) = M ∧
      T_H * S_BH = hbar * c * r_S / (4 * l_planck ^ 2) ∧
      T_H * S_BH = G * M * hbar / (2 * c * l_planck ^ 2) ∧
      Complex.normSq (complexPluckerSinkAmplitudeA M_S) *
          Complex.normSq (complexPluckerSinkAmplitudeB M_S) =
        1 - r_S / r ∧
      0 < Complex.normSq (complexPluckerSinkAmplitudeA M_S) *
          Complex.normSq (complexPluckerSinkAmplitudeB M_S) ∧
      0 < kerrSpinFrameDraggingOrder beta ∧
      kerrSpinFrameDraggingOrder beta < schwarzschildRelativisticOrder beta ∧
      schwarzschildRelativisticOrder (1 / 12) = 1 / 144 ∧
      kerrSpinFrameDraggingOrder (1 / 12) = 1 / 1728 := by
  intro r_S r_ph A_S κ_S T_H S_BH beta_S z1 z2 M_S
  have hpi_pos : 0 < Real.pi := Real.pi_pos
  have hpi_ne : Real.pi ≠ 0 := ne_of_gt hpi_pos
  have hG_ne : G ≠ 0 := ne_of_gt hG
  have hM_ne : M ≠ 0 := ne_of_gt hM
  have hc_ne : c ≠ 0 := ne_of_gt hc
  have hkB_ne : k_B ≠ 0 := ne_of_gt hkB
  have hlp_ne : l_planck ≠ 0 := ne_of_gt hlp
  have hrS_pos : 0 < r_S := by
    dsimp [r_S, schwarzschildRadius]
    positivity
  have hrS_ne : r_S ≠ 0 := ne_of_gt hrS_pos
  have hrph_eq : r_ph = (3 / 2 : ℝ) * r_S := by
    dsimp [r_ph, r_S, photonSphereRadius, schwarzschildRadius]
    ring
  have hrph_gt : r_S < r_ph := by linarith
  have hκ_pos : 0 < κ_S := by
    dsimp [κ_S, schwarzschildSurfaceGravity]
    positivity
  have hTH_pos : 0 < T_H := by
    dsimp [T_H, hawkingTemperature]
    positivity
  have hSBH_pos : 0 < S_BH := by
    dsimp [S_BH, bekensteinHawkingEntropy, schwarzschildHorizonArea]
    positivity
  have hTH_eq : T_H = hbar * c ^ 3 / (8 * Real.pi * G * M * k_B) := by
    dsimp [T_H, hawkingTemperature, schwarzschildSurfaceGravity, schwarzschildRadius]
    field_simp [hpi_ne, hG_ne, hM_ne, hc_ne, hkB_ne]
    ring
  have hTH_M : T_H * M = hbar * c ^ 3 / (8 * Real.pi * G * k_B) := by
    rw [hTH_eq]
    field_simp [hpi_ne, hG_ne, hM_ne, hkB_ne]
  have h_smarr_mass : (κ_S * A_S) / (4 * Real.pi * G) = M := by
    dsimp [κ_S, A_S, schwarzschildSurfaceGravity, schwarzschildHorizonArea,
      schwarzschildRadius]
    field_simp [hpi_ne, hG_ne, hM_ne, hc_ne]
  have h_ts_1 : T_H * S_BH = hbar * c * r_S / (4 * l_planck ^ 2) := by
    dsimp [T_H, S_BH, r_S, hawkingTemperature, bekensteinHawkingEntropy,
      schwarzschildSurfaceGravity, schwarzschildHorizonArea]
    field_simp [hpi_ne, hkB_ne, hc_ne, hlp_ne, hrS_ne]
    ring
  have h_ts_2 : T_H * S_BH = G * M * hbar / (2 * c * l_planck ^ 2) := by
    rw [h_ts_1]
    dsimp [r_S, schwarzschildRadius]
    field_simp [hc_ne, hlp_ne]
    ring
  have hr_pos : 0 < r := lt_trans hrS_pos hr_gt
  have h_ratio_pos : 0 < r_S / r := div_pos hrS_pos hr_pos
  have h_ratio_lt : r_S / r < 1 := (div_lt_one hr_pos).mpr hr_gt
  have h_beta_pos : 0 < beta_S := Real.sqrt_pos.mpr h_ratio_pos
  have h_beta_sq : beta_S ^ 2 = r_S / r := Real.sq_sqrt (le_of_lt h_ratio_pos)
  have h_beta_lt : beta_S < 1 := by nlinarith
  have h1p : 0 ≤ 1 + beta_S := by linarith
  have h1m : 0 ≤ 1 - beta_S := by linarith
  have h_minors := complexGr24ChannelMatrix_minors z1 z2
  have h_wA : Complex.normSq (complexPluckerSinkAmplitudeA M_S) = 1 + beta_S := by
    dsimp [M_S, complexPluckerSinkAmplitudeA]
    rw [h_minors.1]
    dsimp [z1]
    simp only [Complex.normSq_apply, Complex.add_re, Complex.add_im, Complex.mul_re,
      Complex.mul_im, Complex.ofReal_re, Complex.ofReal_im, Complex.I_re, Complex.I_im]
    calc
      _ = (Real.sqrt (1 + beta_S)) ^ 2 * ((Real.cos θ) ^ 2 + (Real.sin θ) ^ 2) := by ring
      _ = 1 + beta_S := by rw [Real.sq_sqrt h1p, Real.cos_sq_add_sin_sq, mul_one]
  have h_wB : Complex.normSq (complexPluckerSinkAmplitudeB M_S) = 1 - beta_S := by
    dsimp [M_S, complexPluckerSinkAmplitudeB]
    rw [h_minors.2.1]
    dsimp [z2]
    simp only [Complex.normSq_apply, Complex.sub_re, Complex.sub_im, Complex.mul_re,
      Complex.mul_im, Complex.ofReal_re, Complex.ofReal_im, Complex.I_re, Complex.I_im]
    calc
      _ = (Real.sqrt (1 - beta_S)) ^ 2 * ((Real.cos θ) ^ 2 + (Real.sin θ) ^ 2) := by ring
      _ = 1 - beta_S := by rw [Real.sq_sqrt h1m, Real.cos_sq_add_sin_sq, mul_one]
  have h_lapse :
      Complex.normSq (complexPluckerSinkAmplitudeA M_S) *
          Complex.normSq (complexPluckerSinkAmplitudeB M_S) =
        1 - r_S / r := by
    rw [h_wA, h_wB]
    calc
      (1 + beta_S) * (1 - beta_S) = 1 - beta_S ^ 2 := by ring
      _ = 1 - r_S / r := by rw [h_beta_sq]
  have h_lapse_pos :
      0 < Complex.normSq (complexPluckerSinkAmplitudeA M_S) *
          Complex.normSq (complexPluckerSinkAmplitudeB M_S) := by
    rw [h_lapse]
    linarith
  have h_kerr_pos : 0 < kerrSpinFrameDraggingOrder beta := by
    unfold kerrSpinFrameDraggingOrder
    positivity
  have h_kerr_lt : kerrSpinFrameDraggingOrder beta < schwarzschildRelativisticOrder beta := by
    unfold kerrSpinFrameDraggingOrder schwarzschildRelativisticOrder
    have hb2 : 0 < beta ^ 2 := sq_pos_of_pos hbeta_pos
    nlinarith
  have h_s301_2 : schwarzschildRelativisticOrder (1 / 12) = 1 / 144 := by
    unfold schwarzschildRelativisticOrder
    norm_num
  have h_s301_3 : kerrSpinFrameDraggingOrder (1 / 12) = 1 / 1728 := by
    unfold kerrSpinFrameDraggingOrder
    norm_num
  exact ⟨hrS_pos, hrph_eq, hrph_gt, hκ_pos, hTH_pos, hSBH_pos, hTH_eq, hTH_M,
    h_smarr_mass, h_ts_1, h_ts_2, h_lapse, h_lapse_pos,
    h_kerr_pos, h_kerr_lt, h_s301_2, h_s301_3⟩

/-! ## Section 2: Gordon Acoustic Metric, Quartic GPE Pressure $|\psi|^4$, & Penrose Spinor/Twistor 4-Periodicity -/

/-- Temporal component $g_{00}^{\mathrm{Gordon}}(\rho_0, c_s, v) = -\frac{\rho_0}{c_s}(c_s^2 - v^2)$
of the Gordon / Unruh acoustic metric $ds^2 = \frac{\rho_0}{c_s}[-(c_s^2 - v^2)dt^2 - 2 v_i dx^i dt + d\mathbf{x}^2]$
(`_Special-Relativity-Geometry-vs.-Fluid.md`, lines 790–825). -/
@[blueprint "def:signals-hawking-gordon-acoustic-metric-g00"
  (title := "Gordon acoustic metric temporal component g_00^Gordon = -(ρ_0 / c_s)(c_s² - v²)")
  (statement := /-- Define $\operatorname{gordonAcousticMetricG00}(\rho_0,c_s,v) = -(\rho_0/c_s)(c_s^2 - v^2)$. -/)]
noncomputable def gordonAcousticMetricG00 (rho0 c_s v : ℝ) : ℝ :=
  -(rho0 / c_s) * (c_s ^ 2 - v ^ 2)

/-- Quartic Gross–Pitaevskii two-body contact self-interaction pressure
$P_{\mathrm{GPE}}(g, \rho) = \frac{g}{2}\rho^2 = \frac{g}{2}|\psi|^4$
(`_Special-Relativity-Geometry-vs.-Fluid.md`, lines 815–910). -/
@[blueprint "def:signals-hawking-quartic-gpe-pressure"
  (title := "Quartic Gross-Pitaevskii self-interaction pressure P_GPE = (g / 2) ρ² = (g / 2) |ψ|⁴")
  (statement := /-- Define $\operatorname{quarticGPESelfInteractionPressure}(g,\rho) = (g/2)\rho^2$. -/)]
noncomputable def quarticGPESelfInteractionPressure (g rho : ℝ) : ℝ :=
  (g / 2) * rho ^ 2

/-- Penrose Hermitian $2 \times 2$ Pauli spinor spacetime matrix
$$X^{AA'}(t, x, y, z) = \frac{1}{\sqrt{2}}\begin{pmatrix} t + z & x - i y \\ x + i y & t - z \end{pmatrix} \in \mathbb{C}^{2 \times 2}$$
whose determinant is half the 4D Minkowski interval $\frac{1}{2}(t^2 - x^2 - y^2 - z^2)$
(`_Special-Relativity-Geometry-vs.-Fluid.md`, lines 912–940). -/
@[blueprint "def:signals-hawking-pauli-spacetime-spinor-matrix"
  (title := "Penrose 2×2 Hermitian Pauli spinor spacetime matrix X^{AA'}(t, x, y, z)")
  (statement := /-- Define $X^{AA'}(t,x,y,z) = \frac{1}{\sqrt{2}}\begin{pmatrix} t+z & x-iy \\ x+iy & t-z \end{pmatrix} \in \mathbb C^{2\times 2}$. -/)]
noncomputable def pauliSpacetimeSpinorMatrix (t x y z : ℝ) : Matrix (Fin 2) (Fin 2) ℂ :=
  let s := Real.sqrt 2
  !![((t + z) / s : ℝ), ↑(x / s) - Complex.I * ↑(y / s);
     ↑(x / s) + Complex.I * ↑(y / s), ((t - z) / s : ℝ)]

/-- **Gordon Acoustic Metric, Quartic $|\psi|^4$ Self-Interaction Pressure, & Penrose Spinor $i^4 = 1$ / $\det X^{AA'}$ Theorem**:
For any `sub : DDFSubstrate`, `re : RiverExterior sub`, exterior radius $r > re.\mathrm{horizonRadius}$,
background density $\rho_0 > 0$, amplitude $A > 0$, coupling $g$, and spacetime coordinates $(t, x, y, z) \in \mathbb{R}^4$:
1. **Gordon Acoustic Horizon Sign Change & $Gr_{\mathbb{C}}(2,4)$ Painlevé–Gullstrand Equivalence**:
   - At the sonic horizon ($v = \pm sub.c$), `gordonAcousticMetricG00 rho0 sub.c sub.c = 0`,
   - In the exterior river flow ($r > r_H$), normalizing `gordonAcousticMetricG00 rho0 sub.c (re.velocity r)`
     by $-\rho_0\,sub.c$ yields the exact Painlevé–Gullstrand redshift lapse and uncrossed
     $Gr_{\mathbb{C}}(2,4)$ Plücker channel product:
     $$\frac{\operatorname{gordonAcousticMetricG00}\bigl(\rho_0, sub.c, re.\mathrm{velocity}(r)\bigr)}{-\rho_0\,sub.c}
     = 1 - \frac{re.\mathrm{horizonRadius}}{r}
     = \bigl|w_A^{\mathbb{C}}(M_{\mathrm{holo}}(r))\bigr|^2\,\bigl|w_B^{\mathbb{C}}(M_{\mathrm{holo}}(r))\bigr|^2 > 0,$$
2. **Quartic $|\psi|^4$ Self-Interaction Pressure Identity**:
   For $\psi = \operatorname{madelungPolarWavefunction}(A, \theta)$,
   $$\operatorname{quarticGPESelfInteractionPressure}\bigl(g, \operatorname{Complex.normSq}(\psi)\bigr) = \frac{g}{2}\,A^4,$$
3. **Spinor Phase 4-Periodicity ($i^2 = -1, i^4 = 1$) & Penrose Pauli Determinant ($\det X^{AA'} = \frac{1}{2}s^2$)**:
   $$\mathrm{Complex.I}^2 = -1, \qquad \mathrm{Complex.I}^4 = 1, \qquad
   \det\bigl(\operatorname{pauliSpacetimeSpinorMatrix}(t, x, y, z)\bigr)
   = \left(\frac{1}{2}\bigl(t^2 - x^2 - y^2 - z^2\bigr) : \mathbb{C}\right).$$ -/
@[blueprint "thm:signals-hawking-gordon-quartic-and-penrose-spinor"
  (title := "Gordon acoustic metric lapse equivalence, quartic |ψ|⁴ GPE pressure, and Penrose spinor i⁴ = 1 / det X^{AA'} theorem")
  (statement := /-- For \texttt{re : RiverExterior sub}, $r > re.\mathrm{horizonRadius}$, $\rho_0 > 0$, and $(t,x,y,z)\in\mathbb R^4$:
    (1) $\operatorname{gordonAcousticMetricG00}(\rho_0, sub.c, sub.c) = 0$ and
    $\operatorname{gordonAcousticMetricG00}(\rho_0, sub.c, re.\mathrm{velocity}(r))/(-\rho_0\,sub.c) = 1 - re.\mathrm{horizonRadius}/r = |w_A^{\mathbb C}(M_{\mathrm{holo}}(r))|^2|w_B^{\mathbb C}(M_{\mathrm{holo}}(r))|^2 > 0$;
    (2) $\operatorname{quarticGPESelfInteractionPressure}(g, |\psi(A,\theta)|^2) = (g/2)A^4$;
    (3) $i^2 = -1$, $i^4 = 1$, and $\det X^{AA'}(t,x,y,z) = \frac{1}{2}(t^2 - x^2 - y^2 - z^2)$. -/)
  (proof := /-- Expand \texttt{gordonAcousticMetricG00} and \texttt{RiverExterior.velocity},
    use \texttt{holographic\_gr24\_ddf\_and\_antiAmplituhedron\_identities} for the Plücker product,
    and expand \texttt{Matrix.det\_fin\_two} on \texttt{pauliSpacetimeSpinorMatrix} using $(\sqrt{2})^2 = 2$. -/)]
theorem gordon_metric_quartic_gpe_and_penrose_spinor_identities
    {sub : DDFSubstrate} (re : RiverExterior sub)
    (rho0 g A r θ t x y z : ℝ)
    (hrho0 : 0 < rho0) (hr_gt : re.horizonRadius < r) :
    let ψ := madelungPolarWavefunction A θ
    let M_holo := ddfThermalGr24Matrix (re.inflowBeta r) θ
    gordonAcousticMetricG00 rho0 sub.c sub.c = 0 ∧
      gordonAcousticMetricG00 rho0 sub.c (re.velocity r) / (-rho0 * sub.c) =
        1 - re.horizonRadius / r ∧
      gordonAcousticMetricG00 rho0 sub.c (re.velocity r) / (-rho0 * sub.c) =
        Complex.normSq (complexPluckerSinkAmplitudeA M_holo) *
          Complex.normSq (complexPluckerSinkAmplitudeB M_holo) ∧
      quarticGPESelfInteractionPressure g (Complex.normSq ψ) = (g / 2) * A ^ 4 ∧
      (Complex.I : ℂ) ^ 2 = -1 ∧
      (Complex.I : ℂ) ^ 4 = 1 ∧
      (pauliSpacetimeSpinorMatrix t x y z).det =
        (((1 / 2 : ℝ) * (t ^ 2 - x ^ 2 - y ^ 2 - z ^ 2) : ℝ) : ℂ) := by
  intro ψ M_holo
  have hc_pos : 0 < sub.c := sub.c_pos
  have hc_ne : sub.c ≠ 0 := ne_of_gt hc_pos
  have hrho0_ne : rho0 ≠ 0 := ne_of_gt hrho0
  have hrH_pos : 0 < re.horizonRadius := re.horizonRadius_pos
  have hr_pos : 0 < r := lt_trans hrH_pos hr_gt
  have hr_ne : r ≠ 0 := ne_of_gt hr_pos
  have hG_pos : 0 < re.G_phi := re.G_phi_pos
  have hM_pos : 0 < re.sourceMass := re.sourceMass_pos
  have h_gordon_zero : gordonAcousticMetricG00 rho0 sub.c sub.c = 0 := by
    unfold gordonAcousticMetricG00
    ring
  have h_vel_sq : (re.velocity r) ^ 2 = 2 * re.G_phi * re.sourceMass / r := by
    unfold RiverExterior.velocity
    have h_arg_nonneg : 0 ≤ 2 * re.G_phi * re.sourceMass / r := by positivity
    rw [neg_sq, Real.sq_sqrt h_arg_nonneg]
  have h_gordon_lapse :
      gordonAcousticMetricG00 rho0 sub.c (re.velocity r) / (-rho0 * sub.c) =
        1 - re.horizonRadius / r := by
    unfold gordonAcousticMetricG00 RiverExterior.horizonRadius
    rw [h_vel_sq]
    field_simp [hrho0_ne, hc_ne, hr_ne]
  have h_holo := re.holographic_gr24_ddf_and_antiAmplituhedron_identities
    1 1 1 0 r 1 (1 / 2) 0 0 1 1 1 θ hr_gt
    (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  have h_gordon_plucker :
      gordonAcousticMetricG00 rho0 sub.c (re.velocity r) / (-rho0 * sub.c) =
        Complex.normSq (complexPluckerSinkAmplitudeA M_holo) *
          Complex.normSq (complexPluckerSinkAmplitudeB M_holo) := by
    rw [h_gordon_lapse, ← h_holo.2.2.2.2.2.2.2.2.1]
  have h_norm_psi : Complex.normSq ψ = A ^ 2 := by
    dsimp [ψ, madelungPolarWavefunction]
    simp only [Complex.normSq_apply, Complex.add_re, Complex.add_im, Complex.mul_re,
      Complex.mul_im, Complex.ofReal_re, Complex.ofReal_im, Complex.I_re, Complex.I_im]
    calc
      _ = A ^ 2 * (Real.cos θ ^ 2 + Real.sin θ ^ 2) := by ring
      _ = A ^ 2 := by rw [Real.cos_sq_add_sin_sq, mul_one]
  have h_quartic :
      quarticGPESelfInteractionPressure g (Complex.normSq ψ) = (g / 2) * A ^ 4 := by
    rw [h_norm_psi]
    unfold quarticGPESelfInteractionPressure
    ring
  have h_i2 : (Complex.I : ℂ) ^ 2 = -1 := Complex.I_sq
  have h_i4 : (Complex.I : ℂ) ^ 4 = 1 := by
    calc
      (Complex.I : ℂ) ^ 4 = ((Complex.I : ℂ) ^ 2) ^ 2 := by ring
      _ = (-1 : ℂ) ^ 2 := by rw [h_i2]
      _ = 1 := by ring
  have h_pauli :
      (pauliSpacetimeSpinorMatrix t x y z).det =
        (((1 / 2 : ℝ) * (t ^ 2 - x ^ 2 - y ^ 2 - z ^ 2) : ℝ) : ℂ) := by
    unfold pauliSpacetimeSpinorMatrix
    rw [Matrix.det_fin_two]
    dsimp
    have h_s2 : ((Real.sqrt 2 : ℂ)) ^ 2 = 2 := by
      norm_cast
      exact Real.sq_sqrt (by norm_num)
    push_cast
    calc
      (((t : ℂ) + z) / ↑(Real.sqrt 2)) * (((t : ℂ) - z) / ↑(Real.sqrt 2)) -
          ((x : ℂ) / ↑(Real.sqrt 2) - Complex.I * (y / ↑(Real.sqrt 2))) *
            ((x : ℂ) / ↑(Real.sqrt 2) + Complex.I * (y / ↑(Real.sqrt 2))) =
        ((t : ℂ) ^ 2 - z ^ 2 - x ^ 2 + Complex.I ^ 2 * y ^ 2) / (↑(Real.sqrt 2)) ^ 2 := by ring
      _ = (1 / 2 : ℂ) * ((t : ℂ) ^ 2 - x ^ 2 - y ^ 2 - z ^ 2) := by
        rw [h_i2, h_s2]
        ring
  exact ⟨h_gordon_zero, h_gordon_lapse, h_gordon_plucker, h_quartic, h_i2, h_i4, h_pauli⟩

/-! ## Section 3: Acoustic Hawking Radiation With DDF, Hydrodynamic `iGPE` Potential Unwinding, & S301 Test-Star Wake -/

/-- Acoustic Hawking / Unruh horizon temperature
$T_H^{\mathrm{DDF}} = \frac{\hbar\,\kappa_H}{2\pi\,k_B\,c} = \frac{\hbar\,c}{4\pi\,k_B\,r_H}$
on a DDF `RiverExterior` sonic horizon. -/
@[blueprint "def:signals-ddf-hawking-temperature"
  (title := "DDF acoustic Hawking horizon temperature T_H^DDF = ℏ κ_H / (2π k_B c)")
  (statement := /-- For \texttt{re : RiverExterior sub}, $\hbar$, and $k_B$, define
    $re.\mathrm{hawkingTemperature}\;\hbar\;k_B = \frac{\hbar \cdot re.\mathrm{horizonSurfaceGravity}}{2\pi\,k_B\,sub.c}$. -/)]
noncomputable def _root_.Signals.DDF.RiverExterior.hawkingTemperature {sub : DDFSubstrate}
    (re : RiverExterior sub) (hbar k_B : ℝ) : ℝ :=
  hbar * re.horizonSurfaceGravity / (2 * Real.pi * k_B * sub.c)

alias RiverExterior.hawkingTemperature :=
  _root_.Signals.DDF.RiverExterior.hawkingTemperature

/-- Hydrodynamic Inverse Gross–Pitaevskii (`iGPE`) external-potential reconstruction
$V_{\mathrm{ext}} = -\partial_t S - \frac{1}{2}m_\phi v_\phi^2 - g_\phi A^2 + \frac{\hbar^2}{2 m_\phi}\frac{\Delta A}{A}$
from the polar Madelung amplitude $A = \sqrt{\rho} > 0$, phase time derivative $\partial_t S$,
and superfluid velocity $v_\phi = \nabla S / m_\phi$ (`Superfluid-Quantum-Gravity-and-Hawking-Radiation.md`, lines 2730–2760). -/
@[blueprint "def:signals-ddf-madelung-inverse-potential-reconstruction"
  (title := "Hydrodynamic iGPE / Madelung inverse potential reconstruction V_ext = -∂_t S - ½ m_ϕ v_ϕ² - g_ϕ A² + (ℏ²/2m_ϕ)(ΔA/A)")
  (statement := /-- Define $\operatorname{madelungInversePotentialReconstruction}(m_\phi,\hbar,g_\phi,A,\Delta A,\partial_t S,v_\phi)
    = -\partial_t S - \frac{1}{2}m_\phi v_\phi^2 - g_\phi A^2 + \frac{\hbar^2}{2m_\phi}\frac{\Delta A}{A}$. -/)]
noncomputable def madelungInversePotentialReconstruction
    (m_phi hbar g_phi A laplacian_A S_t v_phi : ℝ) : ℝ :=
  - S_t - (1 / 2) * m_phi * v_phi ^ 2 - g_phi * A ^ 2 +
    (hbar ^ 2 / (2 * m_phi)) * (laplacian_A / A)

/-- S301 test-star orbital velocity amplification factor
$\mathcal{F}_v(r_\star, \epsilon_{\mathrm{soft}}) = \frac{1}{r_\star + \epsilon_{\mathrm{soft}}}$
(`SqgBlackHoleSim.jsx` in `Superfluid-Quantum-Gravity-and-Hawking-Radiation.md`, lines 3180–3185). -/
noncomputable def testStarVelocityFactor (starDistToCenter softening : ℝ) : ℝ :=
  1 / (starDistToCenter + softening)

/-- Macroscopic stress-riser wake induced by an eccentric test star (S301 analog)
passing within distance $d < R_{\mathrm{wake}}$ of a superfluid condensate splat:
$\sigma_{\mathrm{wake}} = (R_{\mathrm{wake}} - d)\,\mathcal{F}_v(r_\star, \epsilon_{\mathrm{soft}})\,G_{\mathrm{wake}}$
(`SqgBlackHoleSim.jsx`, lines 3190–3198). -/
noncomputable def testStarWakeStress
    (wakeRadius distToStar starDistToCenter softening wakeGain : ℝ) : ℝ :=
  (wakeRadius - distToStar) * testStarVelocityFactor starDistToCenter softening * wakeGain

/-- **S301 Test-Star Pericenter vs. Aphelion Stress-Wake & $Gr_{\mathbb{C}}(2,4)$ Vis-Viva Ratio Theorem**:
For any eccentric orbit `orb : PlanetaryOrbit` with $0 < orb.\mathrm{eccentricity}$,
softening $\epsilon_{\mathrm{soft}} \ge 0$, splat distance $d < R_{\mathrm{wake}}$,
and wake gain $G_{\mathrm{wake}} > 0$:
1. $orb.\mathrm{perihelionRadius} < orb.\mathrm{aphelionRadius}$,
2. $\operatorname{testStarVelocityFactor}(orb.\mathrm{aphelionRadius}, \epsilon_{\mathrm{soft}}) < \operatorname{testStarVelocityFactor}(orb.\mathrm{perihelionRadius}, \epsilon_{\mathrm{soft}})$,
3. $\operatorname{testStarWakeStress}(R_{\mathrm{wake}}, d, orb.\mathrm{aphelionRadius}, \epsilon_{\mathrm{soft}}, G_{\mathrm{wake}}) < \operatorname{testStarWakeStress}(R_{\mathrm{wake}}, d, orb.\mathrm{perihelionRadius}, \epsilon_{\mathrm{soft}}, G_{\mathrm{wake}})$, and
4. For $M_{\mathbb{C}}^{\mathrm{orb}} = orb.\mathrm{gr24PrecessionMatrix}\,\Delta\varpi$,
   $$\frac{orb.\mathrm{aphelionRadius}}{orb.\mathrm{perihelionRadius}}
   = \frac{1 + orb.\mathrm{eccentricity}}{1 - orb.\mathrm{eccentricity}}
   = \frac{\bigl|w_A^{\mathbb{C}}(M_{\mathbb{C}}^{\mathrm{orb}})\bigr|^2}{\bigl|w_B^{\mathbb{C}}(M_{\mathbb{C}}^{\mathrm{orb}})\bigr|^2} > 1.$$ -/
@[blueprint "thm:signals-hawking-s301-pericenter-wake-and-gr24-ratio"
  (title := "S301 test-star pericenter vs. aphelion stress-wake amplification and Gr_C(2,4) vis-viva ratio theorem")
  (statement := /-- For \texttt{orb : PlanetaryOrbit} with $0 < e$, $\epsilon_{\mathrm{soft}} \ge 0$, $d < R_{\mathrm{wake}}$, and $G_{\mathrm{wake}} > 0$:
    (1) $r_{\min} < r_{\max}$,
    (2) $\mathcal{F}_v(r_{\max}, \epsilon_{\mathrm{soft}}) < \mathcal{F}_v(r_{\min}, \epsilon_{\mathrm{soft}})$,
    (3) $\sigma_{\mathrm{wake}}(r_{\max}) < \sigma_{\mathrm{wake}}(r_{\min})$, and
    (4) $r_{\max}/r_{\min} = (1+e)/(1-e) = |w_A^{\mathbb C}(M_{\mathbb C}^{\mathrm{orb}})|^2 / |w_B^{\mathbb C}(M_{\mathbb C}^{\mathrm{orb}})|^2 > 1$. -/)
  (proof := /-- Use $0 < a$ and $0 < e < 1$ to show $0 < r_{\min} + \epsilon_{\mathrm{soft}} < r_{\max} + \epsilon_{\mathrm{soft}}$,
    apply \texttt{one\_div\_lt\_one\_div\_of\_lt}, and combine with \texttt{gr24PrecessionMatrix\_orbital\_identities}. -/)]
theorem s301_pericenter_vs_aphelion_wake_identities
    (orb : PlanetaryOrbit) (he_pos : 0 < orb.eccentricity)
    (wakeRadius distToStar softening wakeGain deltaVarpi : ℝ)
    (h_dist : distToStar < wakeRadius) (h_soft : 0 ≤ softening) (h_gain : 0 < wakeGain) :
    let M_orb := orb.gr24PrecessionMatrix deltaVarpi
    orb.perihelionRadius < orb.aphelionRadius ∧
      testStarVelocityFactor orb.aphelionRadius softening <
        testStarVelocityFactor orb.perihelionRadius softening ∧
      testStarWakeStress wakeRadius distToStar orb.aphelionRadius softening wakeGain <
        testStarWakeStress wakeRadius distToStar orb.perihelionRadius softening wakeGain ∧
      orb.aphelionRadius / orb.perihelionRadius =
        (1 + orb.eccentricity) / (1 - orb.eccentricity) ∧
      orb.aphelionRadius / orb.perihelionRadius =
        Complex.normSq (complexPluckerSinkAmplitudeA M_orb) /
          Complex.normSq (complexPluckerSinkAmplitudeB M_orb) ∧
      1 < orb.aphelionRadius / orb.perihelionRadius := by
  intro M_orb
  have ha_pos := orb.semiMajorAxis_pos
  have ha_ne : orb.semiMajorAxis ≠ 0 := ne_of_gt ha_pos
  have he_lt := orb.eccentricity_lt_one
  have h_rmin_pos : 0 < orb.perihelionRadius := (orb.radii_identities).2.2.1
  have h_rmin_lt_rmax : orb.perihelionRadius < orb.aphelionRadius := by
    unfold PlanetaryOrbit.perihelionRadius PlanetaryOrbit.aphelionRadius
    nlinarith
  have h_den_min_pos : 0 < orb.perihelionRadius + softening := by linarith
  have h_den_lt : orb.perihelionRadius + softening < orb.aphelionRadius + softening := by
    linarith
  have h_vf_lt :
      testStarVelocityFactor orb.aphelionRadius softening <
        testStarVelocityFactor orb.perihelionRadius softening := by
    unfold testStarVelocityFactor
    exact one_div_lt_one_div_of_lt h_den_min_pos h_den_lt
  have h_wake_lt :
      testStarWakeStress wakeRadius distToStar orb.aphelionRadius softening wakeGain <
        testStarWakeStress wakeRadius distToStar orb.perihelionRadius softening wakeGain := by
    unfold testStarWakeStress
    have h_rad_pos : 0 < wakeRadius - distToStar := sub_pos.mpr h_dist
    have h_prod_pos : 0 < (wakeRadius - distToStar) * wakeGain := mul_pos h_rad_pos h_gain
    nlinarith
  have h_1me_pos : 0 < 1 - orb.eccentricity := by linarith
  have h_1me_ne : 1 - orb.eccentricity ≠ 0 := ne_of_gt h_1me_pos
  have h_ratio_e :
      orb.aphelionRadius / orb.perihelionRadius =
        (1 + orb.eccentricity) / (1 - orb.eccentricity) := by
    unfold PlanetaryOrbit.aphelionRadius PlanetaryOrbit.perihelionRadius
    exact mul_div_mul_left (1 + orb.eccentricity) (1 - orb.eccentricity) ha_ne
  have h_orb_id := orb.gr24PrecessionMatrix_orbital_identities deltaVarpi
  have h_ratio_gr24 :
      orb.aphelionRadius / orb.perihelionRadius =
        Complex.normSq (complexPluckerSinkAmplitudeA M_orb) /
          Complex.normSq (complexPluckerSinkAmplitudeB M_orb) := by
    dsimp [M_orb]
    rw [h_orb_id.1, h_orb_id.2.1, div_div_div_cancel_right₀ ha_ne]
  have h_gt_one : 1 < orb.aphelionRadius / orb.perihelionRadius := by
    rw [h_ratio_e, one_lt_div h_1me_pos]
    linarith
  exact ⟨h_rmin_lt_rmax, h_vf_lt, h_wake_lt, h_ratio_e, h_ratio_gr24, h_gt_one⟩

/-! ## Section 4: 2D & 3D Splat Quantum Fracture ($90^\circ$ Snap & Isotropic Trace Swell), Vieta $3 \times 3$ Cubic Invariants, and WGSL Matrix-to-Quaternion Volume Laws -/

/-- **2D Topological $90^\circ$ Orthogonal Eigenvector Snap (`rotateOrthogonal90`)**:
Swaps the principal widths $\sigma_1 \leftrightarrow \sigma_2$ and rotates the orientation
angle by $\pi/2$ (`Superfluid-Quantum-Gravity-and-Hawking-Radiation.md`, lines 1246–1286). -/
@[blueprint "def:signals-ddf-splat2d-rotate-orthogonal90"
  (title := "90-degree orthogonal eigenvector snap of a 2D Tensor Gaussian Splat")
  (statement := /-- For \texttt{splat : NormedTensorGaussianSplat2D}, swap $\sigma_1\leftrightarrow\sigma_2$
    and advance $\theta\mapsto\theta+\pi/2$. -/)]
noncomputable def _root_.Signals.DDF.NormedTensorGaussianSplat2D.rotateOrthogonal90
    (splat : NormedTensorGaussianSplat2D) : NormedTensorGaussianSplat2D :=
  { centerX := splat.centerX
    centerY := splat.centerY
    weight := splat.weight
    weight_nonneg := splat.weight_nonneg
    sigma1 := splat.sigma2
    sigma1_pos := splat.sigma2_pos
    sigma2 := splat.sigma1
    sigma2_pos := splat.sigma1_pos
    orientationAngle := splat.orientationAngle + Real.pi / 2 }

alias NormedTensorGaussianSplat2D.rotateOrthogonal90 :=
  _root_.Signals.DDF.NormedTensorGaussianSplat2D.rotateOrthogonal90

/-- **2D Transformation-Toughening Isotropic Metric Swell (`isotropicTraceSwell`)**:
Collapses an anisotropic sheared 2D Tensor Gaussian Splat into a trace-preserving
isotropic Gaussian sphere with principal variance $\sigma_{\mathrm{swell}}^2 = \frac{\sigma_1^2 + \sigma_2^2}{2} = \frac{\operatorname{Tr}\Sigma}{2}$
(`Superfluid-Quantum-Gravity-and-Hawking-Radiation.md`, lines 1280–1312). -/
@[blueprint "def:signals-ddf-splat2d-isotropic-trace-swell"
  (title := "Trace-preserving isotropic metric swell of a 2D Tensor Gaussian Splat")
  (statement := /-- For \texttt{splat : NormedTensorGaussianSplat2D}, construct an isotropic
    2D tensor Gaussian splat with $\sigma_1 = \sigma_2 = \sqrt{(\sigma_1^2 + \sigma_2^2)/2}$. -/)]
noncomputable def _root_.Signals.DDF.NormedTensorGaussianSplat2D.isotropicTraceSwell
    (splat : NormedTensorGaussianSplat2D) : NormedTensorGaussianSplat2D :=
  let h_pos : 0 < (splat.sigma1 ^ 2 + splat.sigma2 ^ 2) / 2 := by
    have hs1 := splat.sigma1_pos
    have hs2 := splat.sigma2_pos
    positivity
  { centerX := splat.centerX
    centerY := splat.centerY
    weight := splat.weight
    weight_nonneg := splat.weight_nonneg
    sigma1 := Real.sqrt ((splat.sigma1 ^ 2 + splat.sigma2 ^ 2) / 2)
    sigma1_pos := Real.sqrt_pos.mpr h_pos
    sigma2 := Real.sqrt ((splat.sigma1 ^ 2 + splat.sigma2 ^ 2) / 2)
    sigma2_pos := Real.sqrt_pos.mpr h_pos
    orientationAngle := splat.orientationAngle + Real.pi / 2 }

alias NormedTensorGaussianSplat2D.isotropicTraceSwell :=
  _root_.Signals.DDF.NormedTensorGaussianSplat2D.isotropicTraceSwell

/-- **3D Topological $90^\circ$ Primary-Tertiary Eigenvector Snap (`snapOrthogonalXZ`)**:
Swaps the primary ($X$, $\sigma_1$) and tertiary ($Z$, $\sigma_3$) widths of a
`NormedTensorGaussianSplat3D` (`apply_quantum_fracture` in WGSL,
`Superfluid-Quantum-Gravity-and-Hawking-Radiation.md`, lines 1255–1272). -/
@[blueprint "def:signals-hawking-splat3d-snap-orthogonal-xz"
  (title := "3D 90-degree primary-tertiary (X ↔ Z) eigenvector snap of a NormedTensorGaussianSplat3D")
  (statement := /-- For \texttt{splat : NormedTensorGaussianSplat3D}, swap $\sigma_1 \leftrightarrow \sigma_3$
    and advance $\theta \mapsto \theta + \pi/2$. -/)]
noncomputable def _root_.Signals.DDF.NormedTensorGaussianSplat3D.snapOrthogonalXZ
    (splat : NormedTensorGaussianSplat3D) : NormedTensorGaussianSplat3D :=
  { centerX := splat.centerX
    centerY := splat.centerY
    centerZ := splat.centerZ
    weight := splat.weight
    weight_nonneg := splat.weight_nonneg
    sigma1 := splat.sigma3
    sigma1_pos := splat.sigma3_pos
    sigma2 := splat.sigma2
    sigma2_pos := splat.sigma2_pos
    sigma3 := splat.sigma1
    sigma3_pos := splat.sigma1_pos
    orientationAngle := splat.orientationAngle + Real.pi / 2
    pitchAngle := splat.pitchAngle }

alias NormedTensorGaussianSplat3D.snapOrthogonalXZ :=
  _root_.Signals.DDF.NormedTensorGaussianSplat3D.snapOrthogonalXZ

/-- **3D Transformation-Toughening Isotropic Metric Swell (`isotropicTraceSwell3D`)**:
Collapses a 3D anisotropic sheared `NormedTensorGaussianSplat3D` into a trace-preserving
isotropic 3D Gaussian sphere with principal variance
$\sigma_{\mathrm{swell,3D}}^2 = \frac{\sigma_1^2 + \sigma_2^2 + \sigma_3^2}{3} = \frac{\operatorname{Tr}\Sigma_{\mathrm{3D}}}{3}$
(`mean_pressure = (eig1 + eig2 + eig3) / 3.0` in WGSL, `Superfluid-Quantum-Gravity-and-Hawking-Radiation.md`, lines 1272–1282). -/
@[blueprint "def:signals-hawking-splat3d-isotropic-trace-swell"
  (title := "3D trace-preserving isotropic metric swell of a NormedTensorGaussianSplat3D")
  (statement := /-- For \texttt{splat : NormedTensorGaussianSplat3D}, construct an isotropic
    3D tensor Gaussian splat with $\sigma_1 = \sigma_2 = \sigma_3 = \sqrt{(\sigma_1^2 + \sigma_2^2 + \sigma_3^2)/3}$. -/)]
noncomputable def _root_.Signals.DDF.NormedTensorGaussianSplat3D.isotropicTraceSwell3D
    (splat : NormedTensorGaussianSplat3D) : NormedTensorGaussianSplat3D :=
  let h_pos : 0 < (splat.sigma1 ^ 2 + splat.sigma2 ^ 2 + splat.sigma3 ^ 2) / 3 := by
    have hs1 := splat.sigma1_pos
    have hs2 := splat.sigma2_pos
    have hs3 := splat.sigma3_pos
    positivity
  { centerX := splat.centerX
    centerY := splat.centerY
    centerZ := splat.centerZ
    weight := splat.weight
    weight_nonneg := splat.weight_nonneg
    sigma1 := Real.sqrt ((splat.sigma1 ^ 2 + splat.sigma2 ^ 2 + splat.sigma3 ^ 2) / 3)
    sigma1_pos := Real.sqrt_pos.mpr h_pos
    sigma2 := Real.sqrt ((splat.sigma1 ^ 2 + splat.sigma2 ^ 2 + splat.sigma3 ^ 2) / 3)
    sigma2_pos := Real.sqrt_pos.mpr h_pos
    sigma3 := Real.sqrt ((splat.sigma1 ^ 2 + splat.sigma2 ^ 2 + splat.sigma3 ^ 2) / 3)
    sigma3_pos := Real.sqrt_pos.mpr h_pos
    orientationAngle := splat.orientationAngle + Real.pi / 2
    pitchAngle := splat.pitchAngle }

alias NormedTensorGaussianSplat3D.isotropicTraceSwell3D :=
  _root_.Signals.DDF.NormedTensorGaussianSplat3D.isotropicTraceSwell3D

/-- Right-handed $90^\circ$ primary-tertiary ($X \leftrightarrow Z$) eigenvector column-swap matrix
$(v_0, v_1, v_2) \mapsto (v_2, v_1, -v_0)$ with determinant $+1$, preserving right-handed
orientation (`(*eigen_sys).vectors[2] = -temp_vec` in WGSL, `Superfluid-Quantum-Gravity-and-Hawking-Radiation.md`, lines 1260–1268). -/
def rightHandedEigenvectorSwapMatrix : Matrix (Fin 3) (Fin 3) ℝ :=
  !![0, 0, -1;
     0, 1,  0;
     1, 0,  0]

/-- Unnegated primary-tertiary ($X \leftrightarrow Z$) column-swap matrix
$(v_0, v_1, v_2) \mapsto (v_2, v_1, v_0)$ with determinant $-1$ (which inverts the
splat orientation inside-out if the sign flip is omitted). -/
def unnegatedEigenvectorSwapMatrix : Matrix (Fin 3) (Fin 3) ℝ :=
  !![0, 0, 1;
     0, 1, 0;
     1, 0, 0]

/-- Vieta's trigonometric cubic root $\lambda_1 = q + 2 p \cos\phi$ for a $3 \times 3$
symmetric tensor (`eigen_decompose_3x3` in WGSL, `Superfluid-Quantum-Gravity-and-Hawking-Radiation.md`, lines 730–755). -/
noncomputable def vietaEigenvalue1 (q p φ : ℝ) : ℝ :=
  q + 2 * p * Real.cos φ

/-- Vieta's trigonometric cubic root $\lambda_3 = q + 2 p \cos(\phi + 2\pi/3)$. -/
noncomputable def vietaEigenvalue3 (q p φ : ℝ) : ℝ :=
  q + 2 * p * Real.cos (φ + 2 * Real.pi / 3)

/-- Vieta's trace-recovered middle root $\lambda_2 = 3 q - \lambda_1 - \lambda_3$. -/
noncomputable def vietaEigenvalue2 (q p φ : ℝ) : ℝ :=
  3 * q - vietaEigenvalue1 q p φ - vietaEigenvalue3 q p φ

/-- $3 \times 3$ upper-left linear block of the WGSL Three.js `compose_instance_matrix(position, q, scale)`
constructed from quaternion $(q_x, q_y, q_z, q_w)$ and principal scales $(s_x, s_y, s_z)$
(`Superfluid-Quantum-Gravity-and-Hawking-Radiation.md`, lines 1385–1405). -/
@[blueprint "def:signals-hawking-wgsl-instance-matrix-3x3"
  (title := "WGSL Three.js compose_instance_matrix 3×3 quaternion-scale linear block")
  (statement := /-- For quaternion $(q_x,q_y,q_z,q_w)$ and scales $(s_x,s_y,s_z)$, define the
    $3\times 3$ instance linear block $M_{\mathrm{inst}}^{(3\times 3)}(q, s) = R(q)\,\operatorname{diag}(s_x, s_y, s_z)$. -/)]
def wgslInstanceMatrix3x3 (qx qy qz qw sx sy sz : ℝ) : Matrix (Fin 3) (Fin 3) ℝ :=
  let x2 := qx + qx
  let y2 := qy + qy
  let z2 := qz + qz
  let xx := qx * x2
  let xy := qx * y2
  let xz := qx * z2
  let yy := qy * y2
  let yz := qy * z2
  let zz := qz * z2
  let wx := qw * x2
  let wy := qw * y2
  let wz := qw * z2
  fun row col =>
    if row = 0 then
      if col = 0 then (1 - (yy + zz)) * sx
      else if col = 1 then (xy - wz) * sy
      else (xz + wy) * sz
    else if row = 1 then
      if col = 0 then (xy + wz) * sx
      else if col = 1 then (1 - (xx + zz)) * sy
      else (yz - wx) * sz
    else
      if col = 0 then (xz - wy) * sx
      else if col = 1 then (yz + wx) * sy
      else (1 - (xx + yy)) * sz

/-- **Master Theorem for Hawking Radiation With DDF, iGPE / Madelung Potential Unwinding, S301 Stress Wake, 2D/3D Splat Fracture, Vieta Cubic Roots, & WGSL Quaternion Instance Matrices**:
For any `sub : DDFSubstrate`, `re : RiverExterior sub`, `s : MovingSheath sub`,
`orb : PlanetaryOrbit`, `splat : NormedTensorGaussianSplat2D`, `splat3d : NormedTensorGaussianSplat3D`,
and positive parameters $\hbar, k_B, \ell_P, m_\phi, A, r, \sigma_0 > 0$:
1. **With DDF, Without Splats (Acoustic Hawking Temperature, Dispersed-Phase $(\varrho_{\max}^\varphi j_{\min}^\varphi)^3$ Scaling, & First-Law Product)**:
   - $0 < re.\mathrm{hawkingTemperature}\;\hbar\;k_B = \frac{\hbar\,sub.c}{4\pi\,k_B\,re.\mathrm{horizonRadius}}$,
   - $(re.\mathrm{hawkingTemperature}\;\hbar\;k_B) \cdot (re.\mathrm{bekensteinHawkingEntropy}\;k_B\;\ell_P) = \frac{\hbar\,sub.c\,re.\mathrm{horizonRadius}}{4\,\ell_P^2}$,
   - $(re.\mathrm{hawkingTemperature}\;\hbar\;k_B)^2 = \frac{\hbar^2}{64\pi^2 k_B^2 re.G_\phi^2 re.\mathrm{sourceMass}^2 (sub.\mathrm{rho\_max\_varphi}\cdot sub.\mathrm{j\_min\_varphi})^3}$,
2. **With DDF, Without Splats (Hydrodynamic iGPE Potential Reconstruction, Stationary `RiverExterior` Unwinding, & S301 Pericenter Wake)**:
   - Substituting $V_{\mathrm{ext}} = \operatorname{madelungInversePotentialReconstruction}(m_\phi, \hbar, g_\phi, A, \Delta A, \partial_t S, v_\phi)$
     into `quantumHamiltonJacobiResidual` yields $0$ identically,
   - In the stationary `RiverExterior` flow,
     $\operatorname{madelungInversePotentialReconstruction}(m_\phi, \hbar, 0, A, 0, 0, re.\mathrm{velocity}(r)) = m_\phi \cdot re.\mathrm{bernoulliPotential}(r) = -\frac{m_\phi\,re.G_\phi\,re.\mathrm{sourceMass}}{r}$,
   - When $0 < orb.\mathrm{eccentricity}$ and $d < R_{\mathrm{wake}}$, the S301 test-star wake stress at pericenter ($r_{\min}$) strictly exceeds that at aphelion ($r_{\max}$),
3. **With DDF, With 2D & 3D Normed Tensor Gaussian Splats ($90^\circ$ Topological Snap & Transformation-Toughening Isotropic Swell)**:
   - 2D `splat.rotateOrthogonal90` preserves $\mathrm{covDet}, \mathrm{covTrace}, \mathrm{coreBohmPotential}$,
   - 2D `splat_swell := splat.isotropicTraceSwell` conserves $\mathrm{covTrace}$, expands $\mathrm{covDet}$ by $\bigl(\frac{\sigma_1^2 - \sigma_2^2}{2}\bigr)^2 \ge 0$, and releases core Bohm potential $\Delta Q_{\mathrm{core}} = \frac{\hbar^2(\sigma_1^2 - \sigma_2^2)^2}{4 m_\phi \sigma_1^2\sigma_2^2(\sigma_1^2 + \sigma_2^2)} \ge 0$,
   - 3D `splat3d.snapOrthogonalXZ` preserves $\mathrm{covDet}, \mathrm{covTrace}, \mathrm{coreBohmPotential}$, and `splat3d.isotropicTraceSwell3D` conserves 3D $\mathrm{covTrace}$ while releasing nonnegative 3D core Bohm potential:
     $$Q_{\mathrm{core,3D}}(\Sigma_{\mathrm{3D}}) - Q_{\mathrm{core,3D}}(\Sigma_{\mathrm{swell,3D}})
     = \frac{\hbar^2\,\bigl((\sigma_1^2 - \sigma_2^2)^2\sigma_3^2 + (\sigma_2^2 - \sigma_3^2)^2\sigma_1^2 + (\sigma_3^2 - \sigma_1^2)^2\sigma_2^2\bigr)}{4 m_\phi\,\sigma_1^2\,\sigma_2^2\,\sigma_3^2\,\bigl(\sigma_1^2 + \sigma_2^2 + \sigma_3^2\bigr)} \ge 0,$$
4. **WGSL Right-Handed Eigenvector Swap, Vieta $3 \times 3$ Trace, & Quaternion `compose_instance_matrix` Determinant**:
   - $\det(R \cdot \mathrm{rightHandedEigenvectorSwapMatrix}) = \det R$ vs. $\det(R \cdot \mathrm{unnegatedEigenvectorSwapMatrix}) = -\det R$,
   - $\lambda_1(q, p, \phi) + \lambda_2(q, p, \phi) + \lambda_3(q, p, \phi) = 3 q$,
   - $\det\bigl(\operatorname{wgslInstanceMatrix3x3}(q_x, q_y, q_z, q_w, s_x, s_y, s_z)\bigr) = s_x\,s_y\,s_z\,\bigl(q_x^2 + q_y^2 + q_z^2 + q_w^2\bigr)^3$. -/
@[blueprint "thm:signals-ddf-hawking-radiation-and-splat-fracture"
  (title := "Master theorem for Hawking radiation with DDF, Madelung iGPE potential unwinding, S301 wake, 2D/3D splat fracture, Vieta roots, and WGSL quaternion instance matrices")
  (statement := /-- For \texttt{re : RiverExterior sub}, \texttt{s : MovingSheath sub}, \texttt{splat : NormedTensorGaussianSplat2D},
    \texttt{splat3d : NormedTensorGaussianSplat3D}, and $\hbar, k_B, \ell_P, m_\phi, A, r, \sigma_0 > 0$:
    (1) $0 < re.\mathrm{hawkingTemperature}\;\hbar\;k_B = \frac{\hbar\,sub.c}{4\pi k_B\,re.\mathrm{horizonRadius}}$,
    $(re.\mathrm{hawkingTemperature}\;\hbar\;k_B)(re.\mathrm{bekensteinHawkingEntropy}\;k_B\;\ell_P) = \frac{\hbar\,sub.c\,re.\mathrm{horizonRadius}}{4\ell_P^2}$, and
    $(re.\mathrm{hawkingTemperature}\;\hbar\;k_B)^2 = \frac{\hbar^2}{64\pi^2 k_B^2 re.G_\phi^2 re.\mathrm{sourceMass}^2 (sub.\mathrm{rho\_max\_varphi}\cdot sub.\mathrm{j\_min\_varphi})^3}$;
    (2) $\operatorname{quantumHamiltonJacobiResidual}(m_\phi,\hbar,g_\phi,\operatorname{madelungInversePotentialReconstruction}(m_\phi,\hbar,g_\phi,A,\Delta A,\partial_t S,v_\phi),A,\Delta A,\partial_t S,v_\phi) = 0$ and
    $\operatorname{madelungInversePotentialReconstruction}(m_\phi,\hbar,0,A,0,0,re.\mathrm{velocity}(r)) = m_\phi\cdot re.\mathrm{bernoulliPotential}(r) = -m_\phi re.G_\phi re.\mathrm{sourceMass}/r$;
    (3) 2D and 3D $90^\circ$ snaps preserve $\mathrm{covDet}, \mathrm{covTrace}, \mathrm{coreBohmPotential}$, while 2D and 3D isotropic trace swells conserve $\mathrm{covTrace}$, expand $\mathrm{covDet}$, and release $\Delta Q_{\mathrm{core}} \ge 0$;
    (4) $\det(R\cdot\mathrm{rightHandedEigenvectorSwapMatrix}) = \det R$, $\lambda_1+\lambda_2+\lambda_3 = 3q$, and $\det(\operatorname{wgslInstanceMatrix3x3}) = s_x s_y s_z (q_x^2+q_y^2+q_z^2+q_w^2)^3$. -/)
  (proof := /-- Expand \texttt{RiverExterior.hawkingTemperature} and \texttt{sub.c\_sq},
    unfold \texttt{madelungInversePotentialReconstruction}, use \texttt{Real.sq\_sqrt} on
    $(\sigma_1^2+\sigma_2^2)/2 > 0$ and $(\sigma_1^2+\sigma_2^2+\sigma_3^2)/3 > 0$,
    and expand the $3\times 3$ determinants by \texttt{Matrix.det\_fin\_three} and \texttt{ring}. -/)]
theorem _root_.Signals.DDF.RiverExterior.hawking_radiation_ddf_and_splat_fracture_identities
    {sub : DDFSubstrate} (re : RiverExterior sub) (s : MovingSheath sub)
    (splat : NormedTensorGaussianSplat2D) (splat3d : NormedTensorGaussianSplat3D)
    (hbar k_B l_planck m_phi g_phi A laplacian_A S_t v_phi r weight sigma0 θ
      q_vieta p_vieta φ_vieta qx qy qz qw sx sy sz : ℝ)
    (R_mat : Matrix (Fin 3) (Fin 3) ℝ)
    (hhbar : 0 < hbar) (hkB : 0 < k_B) (hlp : 0 < l_planck)
    (hm_phi : 0 < m_phi) (_hA : 0 < A) (hr : 0 < r)
    (hw : 0 ≤ weight) (h_sigma0 : 0 < sigma0)
    (hq_unit : qx ^ 2 + qy ^ 2 + qz ^ 2 + qw ^ 2 = 1) :
    let V_rec := madelungInversePotentialReconstruction m_phi hbar g_phi A laplacian_A S_t v_phi
    let splat_rot := splat.rotateOrthogonal90
    let splat_swell := splat.isotropicTraceSwell
    let splat_ddf := s.ddfTensorSplat 0 0 weight sigma0 hw h_sigma0 θ
    let splat3d_snap := splat3d.snapOrthogonalXZ
    let splat3d_swell := splat3d.isotropicTraceSwell3D
    0 < re.hawkingTemperature hbar k_B ∧
      re.hawkingTemperature hbar k_B =
        hbar * sub.c / (4 * Real.pi * k_B * re.horizonRadius) ∧
      re.hawkingTemperature hbar k_B * re.bekensteinHawkingEntropy k_B l_planck =
        hbar * sub.c * re.horizonRadius / (4 * l_planck ^ 2) ∧
      (re.hawkingTemperature hbar k_B) ^ 2 =
        hbar ^ 2 /
          (64 * Real.pi ^ 2 * k_B ^ 2 * re.G_phi ^ 2 * re.sourceMass ^ 2 *
            (sub.rho_max_varphi * sub.j_min_varphi) ^ 3) ∧
      quantumHamiltonJacobiResidual m_phi hbar g_phi V_rec A laplacian_A S_t v_phi = 0 ∧
      madelungInversePotentialReconstruction m_phi hbar 0 A 0 0 (re.velocity r) =
        m_phi * re.bernoulliPotential r ∧
      madelungInversePotentialReconstruction m_phi hbar 0 A 0 0 (re.velocity r) =
        - (m_phi * re.G_phi * re.sourceMass / r) ∧
      splat_rot.covDet = splat.covDet ∧
      splat_rot.covTrace = splat.covTrace ∧
      splat_rot.coreBohmPotential m_phi hbar = splat.coreBohmPotential m_phi hbar ∧
      splat_swell.covTrace = splat.covTrace ∧
      splat_swell.covDet - splat.covDet =
        ((splat.sigma1 ^ 2 - splat.sigma2 ^ 2) / 2) ^ 2 ∧
      splat.covDet ≤ splat_swell.covDet ∧
      (splat.sigma1 ^ 2 ≠ splat.sigma2 ^ 2 → splat.covDet < splat_swell.covDet) ∧
      splat.coreBohmPotential m_phi hbar - splat_swell.coreBohmPotential m_phi hbar =
        (hbar ^ 2 * (splat.sigma1 ^ 2 - splat.sigma2 ^ 2) ^ 2) /
          (4 * m_phi * splat.sigma1 ^ 2 * splat.sigma2 ^ 2 *
            (splat.sigma1 ^ 2 + splat.sigma2 ^ 2)) ∧
      splat_swell.coreBohmPotential m_phi hbar ≤ splat.coreBohmPotential m_phi hbar ∧
      (splat.sigma1 ^ 2 ≠ splat.sigma2 ^ 2 →
        splat_swell.coreBohmPotential m_phi hbar < splat.coreBohmPotential m_phi hbar) ∧
      splat_ddf.isotropicTraceSwell.covDet - splat_ddf.covDet =
        (sigma0 ^ 4 * s.betaSq ^ 2) / 4 ∧
      splat3d_snap.covDet = splat3d.covDet ∧
      splat3d_snap.covTrace = splat3d.covTrace ∧
      splat3d_snap.coreBohmPotential m_phi hbar = splat3d.coreBohmPotential m_phi hbar ∧
      splat3d_swell.covTrace = splat3d.covTrace ∧
      splat3d.coreBohmPotential m_phi hbar - splat3d_swell.coreBohmPotential m_phi hbar =
        (hbar ^ 2 *
          ((splat3d.sigma1 ^ 2 - splat3d.sigma2 ^ 2) ^ 2 * splat3d.sigma3 ^ 2 +
            (splat3d.sigma2 ^ 2 - splat3d.sigma3 ^ 2) ^ 2 * splat3d.sigma1 ^ 2 +
            (splat3d.sigma3 ^ 2 - splat3d.sigma1 ^ 2) ^ 2 * splat3d.sigma2 ^ 2)) /
          (4 * m_phi * splat3d.sigma1 ^ 2 * splat3d.sigma2 ^ 2 * splat3d.sigma3 ^ 2 *
            (splat3d.sigma1 ^ 2 + splat3d.sigma2 ^ 2 + splat3d.sigma3 ^ 2)) ∧
      splat3d_swell.coreBohmPotential m_phi hbar ≤ splat3d.coreBohmPotential m_phi hbar ∧
      (R_mat * rightHandedEigenvectorSwapMatrix).det = R_mat.det ∧
      (R_mat * unnegatedEigenvectorSwapMatrix).det = -R_mat.det ∧
      vietaEigenvalue1 q_vieta p_vieta φ_vieta +
        vietaEigenvalue2 q_vieta p_vieta φ_vieta +
        vietaEigenvalue3 q_vieta p_vieta φ_vieta = 3 * q_vieta ∧
      (wgslInstanceMatrix3x3 qx qy qz qw sx sy sz).det =
        sx * sy * sz *
          (1 + 4 * (qx ^ 2 + qy ^ 2 + qz ^ 2) *
            (qx ^ 2 + qy ^ 2 + qz ^ 2 + qw ^ 2 - 1)) ∧
      (wgslInstanceMatrix3x3 qx qy qz qw sx sy sz).det = sx * sy * sz := by
  intro V_rec splat_rot splat_swell splat_ddf splat3d_snap splat3d_swell
  have hpi_pos : 0 < Real.pi := Real.pi_pos
  have hpi_ne : Real.pi ≠ 0 := ne_of_gt hpi_pos
  have hkB_ne : k_B ≠ 0 := ne_of_gt hkB
  have hlp_ne : l_planck ≠ 0 := ne_of_gt hlp
  have hm_ne : m_phi ≠ 0 := ne_of_gt hm_phi
  have hc_pos : 0 < sub.c := sub.c_pos
  have hc_ne : sub.c ≠ 0 := ne_of_gt hc_pos
  have hG_pos : 0 < re.G_phi := re.G_phi_pos
  have hG_ne : re.G_phi ≠ 0 := ne_of_gt hG_pos
  have hM_pos : 0 < re.sourceMass := re.sourceMass_pos
  have hM_ne : re.sourceMass ≠ 0 := ne_of_gt hM_pos
  have hrH_pos : 0 < re.horizonRadius := re.horizonRadius_pos
  have hrH_ne : re.horizonRadius ≠ 0 := ne_of_gt hrH_pos
  have h_ks_pos : 0 < re.horizonSurfaceGravity := by
    unfold RiverExterior.horizonSurfaceGravity
    positivity
  have h_th_pos : 0 < re.hawkingTemperature hbar k_B := by
    unfold _root_.Signals.DDF.RiverExterior.hawkingTemperature
    positivity
  have h_th_eq :
      re.hawkingTemperature hbar k_B =
        hbar * sub.c / (4 * Real.pi * k_B * re.horizonRadius) := by
    unfold _root_.Signals.DDF.RiverExterior.hawkingTemperature
      RiverExterior.horizonSurfaceGravity
    field_simp [hpi_ne, hkB_ne, hc_ne, hrH_ne]
    ring
  have h_th_sbh :
      re.hawkingTemperature hbar k_B * re.bekensteinHawkingEntropy k_B l_planck =
        hbar * sub.c * re.horizonRadius / (4 * l_planck ^ 2) := by
    rw [h_th_eq]
    unfold RiverExterior.bekensteinHawkingEntropy RiverExterior.horizonArea
    field_simp [hpi_ne, hkB_ne, hlp_ne, hrH_ne]
  have h_th_sq :
      (re.hawkingTemperature hbar k_B) ^ 2 =
        hbar ^ 2 /
          (64 * Real.pi ^ 2 * k_B ^ 2 * re.G_phi ^ 2 * re.sourceMass ^ 2 *
            (sub.rho_max_varphi * sub.j_min_varphi) ^ 3) := by
    rw [h_th_eq]
    unfold RiverExterior.horizonRadius
    have h_alg :
        (hbar * sub.c / (4 * Real.pi * k_B * (2 * re.G_phi * re.sourceMass / sub.c ^ 2))) ^ 2 =
          (hbar ^ 2 * (sub.c ^ 2) ^ 3) /
            (64 * Real.pi ^ 2 * k_B ^ 2 * re.G_phi ^ 2 * re.sourceMass ^ 2) := by
      field_simp [hpi_ne, hkB_ne, hG_ne, hM_ne, hc_ne]
      ring
    rw [h_alg, sub.c_sq, inv_pow, div_eq_mul_inv]
    ring
  have h_qhj_zero :
      quantumHamiltonJacobiResidual m_phi hbar g_phi V_rec A laplacian_A S_t v_phi = 0 := by
    dsimp [V_rec, madelungInversePotentialReconstruction, quantumHamiltonJacobiResidual]
    ring
  have h_inv_bern :
      madelungInversePotentialReconstruction m_phi hbar 0 A 0 0 (re.velocity r) =
        m_phi * re.bernoulliPotential r := by
    unfold madelungInversePotentialReconstruction RiverExterior.bernoulliPotential
    ring
  have h_inv_newt :
      madelungInversePotentialReconstruction m_phi hbar 0 A 0 0 (re.velocity r) =
        - (m_phi * re.G_phi * re.sourceMass / r) := by
    rw [h_inv_bern, re.bernoulli_potential_eq r hr]
    ring
  have h_rot_det : splat_rot.covDet = splat.covDet := by
    dsimp [splat_rot, _root_.Signals.DDF.NormedTensorGaussianSplat2D.rotateOrthogonal90,
      NormedTensorGaussianSplat2D.covDet]
    ring
  have h_rot_tr : splat_rot.covTrace = splat.covTrace := by
    dsimp [splat_rot, _root_.Signals.DDF.NormedTensorGaussianSplat2D.rotateOrthogonal90,
      NormedTensorGaussianSplat2D.covTrace]
    ring
  have h_rot_bohm : splat_rot.coreBohmPotential m_phi hbar = splat.coreBohmPotential m_phi hbar := by
    dsimp [splat_rot, _root_.Signals.DDF.NormedTensorGaussianSplat2D.rotateOrthogonal90,
      NormedTensorGaussianSplat2D.coreBohmPotential]
    ring
  have hs1_pos : 0 < splat.sigma1 := splat.sigma1_pos
  have hs2_pos : 0 < splat.sigma2 := splat.sigma2_pos
  have hs1_sq_ne : splat.sigma1 ^ 2 ≠ 0 := pow_ne_zero 2 (ne_of_gt hs1_pos)
  have hs2_sq_ne : splat.sigma2 ^ 2 ≠ 0 := pow_ne_zero 2 (ne_of_gt hs2_pos)
  have h_sum_pos : 0 < splat.sigma1 ^ 2 + splat.sigma2 ^ 2 := by positivity
  have h_sum_ne : splat.sigma1 ^ 2 + splat.sigma2 ^ 2 ≠ 0 := ne_of_gt h_sum_pos
  have h_avg_nonneg : 0 ≤ (splat.sigma1 ^ 2 + splat.sigma2 ^ 2) / 2 := by positivity
  have h_swell_sq :
      (Real.sqrt ((splat.sigma1 ^ 2 + splat.sigma2 ^ 2) / 2)) ^ 2 =
        (splat.sigma1 ^ 2 + splat.sigma2 ^ 2) / 2 :=
    Real.sq_sqrt h_avg_nonneg
  have h_swell_tr : splat_swell.covTrace = splat.covTrace := by
    dsimp [splat_swell, _root_.Signals.DDF.NormedTensorGaussianSplat2D.isotropicTraceSwell,
      NormedTensorGaussianSplat2D.covTrace]
    rw [h_swell_sq]
    ring
  have h_swell_det_diff :
      splat_swell.covDet - splat.covDet =
        ((splat.sigma1 ^ 2 - splat.sigma2 ^ 2) / 2) ^ 2 := by
    dsimp [splat_swell, _root_.Signals.DDF.NormedTensorGaussianSplat2D.isotropicTraceSwell,
      NormedTensorGaussianSplat2D.covDet]
    rw [h_swell_sq]
    ring
  have h_swell_det_le : splat.covDet ≤ splat_swell.covDet := by
    have h_sq_nonneg : 0 ≤ ((splat.sigma1 ^ 2 - splat.sigma2 ^ 2) / 2) ^ 2 := sq_nonneg _
    linarith [h_swell_det_diff]
  have h_swell_det_lt : splat.sigma1 ^ 2 ≠ splat.sigma2 ^ 2 → splat.covDet < splat_swell.covDet := by
    intro h_ne
    have h_diff_ne : (splat.sigma1 ^ 2 - splat.sigma2 ^ 2) / 2 ≠ 0 :=
      div_ne_zero (sub_ne_zero.mpr h_ne) (by norm_num)
    have h_sq_pos : 0 < ((splat.sigma1 ^ 2 - splat.sigma2 ^ 2) / 2) ^ 2 :=
      sq_pos_of_ne_zero h_diff_ne
    linarith [h_swell_det_diff]
  have h_swell_bohm_diff :
      splat.coreBohmPotential m_phi hbar - splat_swell.coreBohmPotential m_phi hbar =
        (hbar ^ 2 * (splat.sigma1 ^ 2 - splat.sigma2 ^ 2) ^ 2) /
          (4 * m_phi * splat.sigma1 ^ 2 * splat.sigma2 ^ 2 *
            (splat.sigma1 ^ 2 + splat.sigma2 ^ 2)) := by
    dsimp [splat_swell, _root_.Signals.DDF.NormedTensorGaussianSplat2D.isotropicTraceSwell,
      NormedTensorGaussianSplat2D.coreBohmPotential]
    rw [h_swell_sq]
    field_simp [hm_ne, hs1_sq_ne, hs2_sq_ne, h_sum_ne]
    ring
  have h_swell_bohm_le :
      splat_swell.coreBohmPotential m_phi hbar ≤ splat.coreBohmPotential m_phi hbar := by
    have h_rhs_nonneg :
        0 ≤ (hbar ^ 2 * (splat.sigma1 ^ 2 - splat.sigma2 ^ 2) ^ 2) /
          (4 * m_phi * splat.sigma1 ^ 2 * splat.sigma2 ^ 2 *
            (splat.sigma1 ^ 2 + splat.sigma2 ^ 2)) := by positivity
    linarith [h_swell_bohm_diff]
  have h_swell_bohm_lt :
      splat.sigma1 ^ 2 ≠ splat.sigma2 ^ 2 →
        splat_swell.coreBohmPotential m_phi hbar < splat.coreBohmPotential m_phi hbar := by
    intro h_ne
    have h_diff_sq_pos : 0 < (splat.sigma1 ^ 2 - splat.sigma2 ^ 2) ^ 2 :=
      sq_pos_of_ne_zero (sub_ne_zero.mpr h_ne)
    have h_rhs_pos :
        0 < (hbar ^ 2 * (splat.sigma1 ^ 2 - splat.sigma2 ^ 2) ^ 2) /
          (4 * m_phi * splat.sigma1 ^ 2 * splat.sigma2 ^ 2 *
            (splat.sigma1 ^ 2 + splat.sigma2 ^ 2)) := by positivity
    linarith [h_swell_bohm_diff]
  have h_ddf_swell :
      splat_ddf.isotropicTraceSwell.covDet - splat_ddf.covDet =
        (sigma0 ^ 4 * s.betaSq ^ 2) / 4 := by
    have h_vis_sq : s.coherenceVisibility ^ 2 = 1 - s.betaSq :=
      Real.sq_sqrt (le_of_lt s.one_sub_betaSq_pos)
    have h_s1_ddf : splat_ddf.sigma1 ^ 2 = sigma0 ^ 2 * (1 - s.betaSq) := by
      dsimp [splat_ddf, MovingSheath.ddfTensorSplat]
      calc
        (sigma0 * s.coherenceVisibility) ^ 2 = sigma0 ^ 2 * s.coherenceVisibility ^ 2 := by ring
        _ = sigma0 ^ 2 * (1 - s.betaSq) := by rw [h_vis_sq]
    have h_s2_ddf : splat_ddf.sigma2 ^ 2 = sigma0 ^ 2 := rfl
    have h_avg_ddf :
        (Real.sqrt ((splat_ddf.sigma1 ^ 2 + splat_ddf.sigma2 ^ 2) / 2)) ^ 2 =
          (splat_ddf.sigma1 ^ 2 + splat_ddf.sigma2 ^ 2) / 2 := by
      apply Real.sq_sqrt
      have hs1_d := splat_ddf.sigma1_pos
      have hs2_d := splat_ddf.sigma2_pos
      positivity
    dsimp [_root_.Signals.DDF.NormedTensorGaussianSplat2D.isotropicTraceSwell,
      NormedTensorGaussianSplat2D.covDet]
    rw [h_avg_ddf, h_s1_ddf, h_s2_ddf]
    ring
  have h3d_snap_det : splat3d_snap.covDet = splat3d.covDet := by
    dsimp [splat3d_snap, _root_.Signals.DDF.NormedTensorGaussianSplat3D.snapOrthogonalXZ,
      NormedTensorGaussianSplat3D.covDet]
    ring
  have h3d_snap_tr : splat3d_snap.covTrace = splat3d.covTrace := by
    dsimp [splat3d_snap, _root_.Signals.DDF.NormedTensorGaussianSplat3D.snapOrthogonalXZ,
      NormedTensorGaussianSplat3D.covTrace]
    ring
  have h3d_snap_bohm :
      splat3d_snap.coreBohmPotential m_phi hbar = splat3d.coreBohmPotential m_phi hbar := by
    dsimp [splat3d_snap, _root_.Signals.DDF.NormedTensorGaussianSplat3D.snapOrthogonalXZ,
      NormedTensorGaussianSplat3D.coreBohmPotential]
    ring
  have hs3_1_pos : 0 < splat3d.sigma1 := splat3d.sigma1_pos
  have hs3_2_pos : 0 < splat3d.sigma2 := splat3d.sigma2_pos
  have hs3_3_pos : 0 < splat3d.sigma3 := splat3d.sigma3_pos
  have hs3_1_ne : splat3d.sigma1 ^ 2 ≠ 0 := pow_ne_zero 2 (ne_of_gt hs3_1_pos)
  have hs3_2_ne : splat3d.sigma2 ^ 2 ≠ 0 := pow_ne_zero 2 (ne_of_gt hs3_2_pos)
  have hs3_3_ne : splat3d.sigma3 ^ 2 ≠ 0 := pow_ne_zero 2 (ne_of_gt hs3_3_pos)
  have h3_sum_pos : 0 < splat3d.sigma1 ^ 2 + splat3d.sigma2 ^ 2 + splat3d.sigma3 ^ 2 := by
    positivity
  have h3_sum_ne : splat3d.sigma1 ^ 2 + splat3d.sigma2 ^ 2 + splat3d.sigma3 ^ 2 ≠ 0 :=
    ne_of_gt h3_sum_pos
  have h3_avg_nonneg :
      0 ≤ (splat3d.sigma1 ^ 2 + splat3d.sigma2 ^ 2 + splat3d.sigma3 ^ 2) / 3 := by
    positivity
  have h3_swell_sq :
      (Real.sqrt ((splat3d.sigma1 ^ 2 + splat3d.sigma2 ^ 2 + splat3d.sigma3 ^ 2) / 3)) ^ 2 =
        (splat3d.sigma1 ^ 2 + splat3d.sigma2 ^ 2 + splat3d.sigma3 ^ 2) / 3 :=
    Real.sq_sqrt h3_avg_nonneg
  have h3d_swell_tr : splat3d_swell.covTrace = splat3d.covTrace := by
    dsimp [splat3d_swell, _root_.Signals.DDF.NormedTensorGaussianSplat3D.isotropicTraceSwell3D,
      NormedTensorGaussianSplat3D.covTrace]
    rw [h3_swell_sq]
    ring
  have h3d_swell_bohm_diff :
      splat3d.coreBohmPotential m_phi hbar - splat3d_swell.coreBohmPotential m_phi hbar =
        (hbar ^ 2 *
          ((splat3d.sigma1 ^ 2 - splat3d.sigma2 ^ 2) ^ 2 * splat3d.sigma3 ^ 2 +
            (splat3d.sigma2 ^ 2 - splat3d.sigma3 ^ 2) ^ 2 * splat3d.sigma1 ^ 2 +
            (splat3d.sigma3 ^ 2 - splat3d.sigma1 ^ 2) ^ 2 * splat3d.sigma2 ^ 2)) /
          (4 * m_phi * splat3d.sigma1 ^ 2 * splat3d.sigma2 ^ 2 * splat3d.sigma3 ^ 2 *
            (splat3d.sigma1 ^ 2 + splat3d.sigma2 ^ 2 + splat3d.sigma3 ^ 2)) := by
    dsimp [splat3d_swell, _root_.Signals.DDF.NormedTensorGaussianSplat3D.isotropicTraceSwell3D,
      NormedTensorGaussianSplat3D.coreBohmPotential]
    rw [h3_swell_sq]
    field_simp [hm_ne, hs3_1_ne, hs3_2_ne, hs3_3_ne, h3_sum_ne]
    ring
  have h3d_swell_bohm_le :
      splat3d_swell.coreBohmPotential m_phi hbar ≤ splat3d.coreBohmPotential m_phi hbar := by
    have h_rhs3_nonneg :
        0 ≤ (hbar ^ 2 *
          ((splat3d.sigma1 ^ 2 - splat3d.sigma2 ^ 2) ^ 2 * splat3d.sigma3 ^ 2 +
            (splat3d.sigma2 ^ 2 - splat3d.sigma3 ^ 2) ^ 2 * splat3d.sigma1 ^ 2 +
            (splat3d.sigma3 ^ 2 - splat3d.sigma1 ^ 2) ^ 2 * splat3d.sigma2 ^ 2)) /
          (4 * m_phi * splat3d.sigma1 ^ 2 * splat3d.sigma2 ^ 2 * splat3d.sigma3 ^ 2 *
            (splat3d.sigma1 ^ 2 + splat3d.sigma2 ^ 2 + splat3d.sigma3 ^ 2)) := by positivity
    linarith [h3d_swell_bohm_diff]
  have h_swap_rh : (R_mat * rightHandedEigenvectorSwapMatrix).det = R_mat.det := by
    rw [Matrix.det_mul]
    have h_det_one : rightHandedEigenvectorSwapMatrix.det = 1 := by
      unfold rightHandedEigenvectorSwapMatrix
      rw [Matrix.det_fin_three]
      norm_num
    rw [h_det_one, mul_one]
  have h_swap_unneg : (R_mat * unnegatedEigenvectorSwapMatrix).det = -R_mat.det := by
    rw [Matrix.det_mul]
    have h_det_neg : unnegatedEigenvectorSwapMatrix.det = -1 := by
      unfold unnegatedEigenvectorSwapMatrix
      rw [Matrix.det_fin_three]
      norm_num
    rw [h_det_neg]
    ring
  have h_vieta_tr :
      vietaEigenvalue1 q_vieta p_vieta φ_vieta +
        vietaEigenvalue2 q_vieta p_vieta φ_vieta +
        vietaEigenvalue3 q_vieta p_vieta φ_vieta = 3 * q_vieta := by
    unfold vietaEigenvalue2
    ring
  have h_wgsl_poly :
      (wgslInstanceMatrix3x3 qx qy qz qw sx sy sz).det =
        sx * sy * sz *
          (1 + 4 * (qx ^ 2 + qy ^ 2 + qz ^ 2) *
            (qx ^ 2 + qy ^ 2 + qz ^ 2 + qw ^ 2 - 1)) := by
    rw [Matrix.det_fin_three]
    simp [wgslInstanceMatrix3x3]
    ring
  have h_wgsl_det :
      (wgslInstanceMatrix3x3 qx qy qz qw sx sy sz).det = sx * sy * sz := by
    rw [h_wgsl_poly, hq_unit]
    ring
  exact ⟨h_th_pos, h_th_eq, h_th_sbh, h_th_sq, h_qhj_zero,
    h_inv_bern, h_inv_newt, h_rot_det, h_rot_tr, h_rot_bohm,
    h_swell_tr, h_swell_det_diff, h_swell_det_le, h_swell_det_lt,
    h_swell_bohm_diff, h_swell_bohm_le, h_swell_bohm_lt, h_ddf_swell,
    h3d_snap_det, h3d_snap_tr, h3d_snap_bohm, h3d_swell_tr,
    h3d_swell_bohm_diff, h3d_swell_bohm_le,
    h_swap_rh, h_swap_unneg, h_vieta_tr, h_wgsl_poly, h_wgsl_det⟩

alias RiverExterior.hawking_radiation_ddf_and_splat_fracture_identities :=
  _root_.Signals.DDF.RiverExterior.hawking_radiation_ddf_and_splat_fracture_identities

end Signals.HawkingRadiation
