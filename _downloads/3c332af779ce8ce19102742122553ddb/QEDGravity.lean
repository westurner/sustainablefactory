import Architect
import Mathlib.Analysis.Complex.Basic
import Mathlib.Analysis.Real.Sqrt
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic
import Mathlib.Tactic
import Signals.Geometry
import Signals.Huygens

namespace Signals.QEDGravity

open Complex Signals.Geometry Signals.Huygens

/-! # QED & Gauge Scattering Amplitudes to Gravity & Gravitational Waves on $Gr_{\mathbb{C}}(2,4)$ (Without DDF)

This module formalizes the flat-space post-Minkowskian QED/gauge scattering double copy,
complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ and $Gr_{\mathbb{C}}(2, N+2)$ orbital mechanics,
anomalous perihelion precession, and quadrupole gravitational-wave radiation **without**
requiring either curved background geometry or the Dilatant Dark Fluid (DDF) substrate:

1. **BCJ Color–Kinematics Duality & Double Copy on $Gr_{\mathbb{C}}(2,4)$ (`bcj_plucker_jacobi_and_double_copy`)**:
   - The uncrossed Plücker channel amplitudes $w_A^{\mathbb{C}} = \Delta_{01}^{\mathbb{C}}\Delta_{23}^{\mathbb{C}}$
     (`complexPluckerSinkAmplitudeA`) and $w_B^{\mathbb{C}} = \Delta_{03}^{\mathbb{C}}\Delta_{12}^{\mathbb{C}}$
     (`complexPluckerSinkAmplitudeB`) together with the crossing product
     $n_t = -\Delta_{02}^{\mathbb{C}}\Delta_{13}^{\mathbb{C}}$ satisfy the BCJ kinematic
     Jacobi identity $n_s + n_t + n_u = 0$ identically via `complexTwoRowMinor_pluecker`,
     and squaring $n_t^2 = (n_s + n_u)^2 = n_s^2 + 2 n_s n_u + n_u^2$ realizes the
     $\text{Gravity} = \text{Gauge}^2$ double copy.
2. **Keplerian & 1-Loop Post-Minkowskian Orbital Geometry (`PlanetaryOrbit`)**:
   - Bound elliptical orbit geometry ($a > 0$, $e \in [0, 1)$), semi-latus rectum
     $p = a(1 - e^2)$, perihelion/aphelion radii $r_{\min/\max} = a(1 \mp e)$,
     harmonic-mean identity $\frac{1}{r_{\min}} + \frac{1}{r_{\max}} = \frac{2}{p}$,
     1-loop post-Minkowskian effective potential $V_{\mathrm{eff}}^{\mathrm{PM}}(r)$,
     precessing polar conic $r(\varphi; \eta_{\mathrm{prec}})$, and Mercury's
     machine-checked $42.98''/\text{century}$ and $574.61''/\text{century}$ bounds.
3. **Canonical & Dynamic $Gr_{\mathbb{C}}(2,4)$ Orbital/Quadrupole Twistor Matrices**:
   - `PlanetaryOrbit.gr24PrecessionMatrix` encodes $(e, \Delta\varpi)$ so that
     $|w_A^{\mathbb{C}}|^2 = 1 + e = r_{\max}/a$, $|w_B^{\mathbb{C}}|^2 = 1 - e = r_{\min}/a$,
     and $|w_A^{\mathbb{C}}|^2 |w_B^{\mathbb{C}}|^2 = 1 - e^2 = p/a$.
   - `PlanetaryOrbit.gr24QuadrupoleWaveMatrix` promotes the phase to the running orbital
     angle $\Phi_{\mathrm{orb}}(t) + \Delta\varpi/2$, so the crossing Plücker minor
     $|\Delta_{02}^{\mathbb{C}}\Delta_{13}^{\mathbb{C}}|^2$ oscillates directly at the
     quadrupole gravitational-wave carrier phase $2\Phi_{\mathrm{orb}}(t) + \Delta\varpi$.
4. **Gravitational Waves Without DDF (2.5PN Peters–Mathews Flux & $N$-Body Resonances)**:
   - Transverse-traceless $(+, \times)$ spin-2 polarization factors $F_+(\iota) = \frac{1+\cos^2\iota}{2}$
     and $F_\times(\iota) = \cos\iota$, flat-space strain amplitude
     $h_0 = \frac{4 G^2 m_1 m_2}{c^4 R a} = \frac{r_{S,1} r_{S,2}}{R a}$,
     Peters–Mathews eccentricity factor $f_{\mathrm{PM}}(e) = \frac{1 + \frac{73}{24}e^2 + \frac{37}{96}e^4}{(\sqrt{1-e^2})^7}$
     governed by the $-7/2$ power of the $Gr_{\mathbb{C}}(2,4)$ Madelung product
     $|w_A^{\mathbb{C}}|^2 |w_B^{\mathbb{C}}|^2 = 1 - e^2$, and $N$-body resonant beat locking.
-/

/-- First complex Plücker channel / sink amplitude
$w_A^{\mathbb{C}}(M_{\mathbb{C}}) = \Delta_{01}^{\mathbb{C}}(M_{\mathbb{C}})\,\Delta_{23}^{\mathbb{C}}(M_{\mathbb{C}})$
on $Gr_{\mathbb{C}}(2, 4)$. -/
@[blueprint "def:signals-ddf-complex-plucker-sink-a"
  (title := "First complex Gr_C(2,4) Plücker sink amplitude w_A^ℂ")
  (statement := /-- For $M_{\mathbb C}\in\mathbb C^{2\times 4}$, define
    $w_A^{\mathbb C}(M_{\mathbb C})=\Delta_{01}^{\mathbb C}(M_{\mathbb C})\,\Delta_{23}^{\mathbb C}(M_{\mathbb C})$. -/)]
def complexPluckerSinkAmplitudeA (M : Matrix (Fin 2) (Fin 4) ℂ) : ℂ :=
  complexTwoRowMinor M 0 1 * complexTwoRowMinor M 2 3

/-- Second complex Plücker channel / sink amplitude
$w_B^{\mathbb{C}}(M_{\mathbb{C}}) = \Delta_{03}^{\mathbb{C}}(M_{\mathbb{C}})\,\Delta_{12}^{\mathbb{C}}(M_{\mathbb{C}})$
on $Gr_{\mathbb{C}}(2, 4)$. -/
@[blueprint "def:signals-ddf-complex-plucker-sink-b"
  (title := "Second complex Gr_C(2,4) Plücker sink amplitude w_B^ℂ")
  (statement := /-- For $M_{\mathbb C}\in\mathbb C^{2\times 4}$, define
    $w_B^{\mathbb C}(M_{\mathbb C})=\Delta_{03}^{\mathbb C}(M_{\mathbb C})\,\Delta_{12}^{\mathbb C}(M_{\mathbb C})$. -/)]
def complexPluckerSinkAmplitudeB (M : Matrix (Fin 2) (Fin 4) ℂ) : ℂ :=
  complexTwoRowMinor M 0 3 * complexTwoRowMinor M 1 2

/-- **BCJ Color–Kinematics Duality & $Gr_{\mathbb{C}}(2,4)$ Plücker Double Copy**:
For any complex $2 \times 4$ Grassmannian matrix $M_{\mathbb{C}} \in \mathbb{C}^{2 \times 4}$,
let the three $s, t, u$-channel gauge kinematic numerators be the quadratic Plücker products
$n_s = \Delta_{01}^{\mathbb{C}}\Delta_{23}^{\mathbb{C}}$,
$n_t = -\Delta_{02}^{\mathbb{C}}\Delta_{13}^{\mathbb{C}}$, and
$n_u = \Delta_{03}^{\mathbb{C}}\Delta_{12}^{\mathbb{C}}$.
Then the BCJ kinematic Jacobi relation $n_s + n_t + n_u = 0$ holds identically by the
3-term Plücker relation on $Gr_{\mathbb{C}}(2,4)$, and the crossing graviton double-copy
square $n_t^2 = (\Delta_{02}^{\mathbb{C}}\Delta_{13}^{\mathbb{C}})^2$ expands into the
symmetric tensor sum $(n_s + n_u)^2 = n_s^2 + 2 n_s n_u + n_u^2$. -/
@[blueprint "thm:signals-ddf-bcj-plucker-double-copy"
  (title := "BCJ kinematic Jacobi identity n_s + n_t + n_u = 0 and double-copy square from Gr_C(2,4) Plücker relations")
  (statement := /-- For $M_{\mathbb C}\in\mathbb C^{2\times 4}$, let
    $n_s=\Delta_{01}^{\mathbb C}\Delta_{23}^{\mathbb C}$,
    $n_t=-\Delta_{02}^{\mathbb C}\Delta_{13}^{\mathbb C}$, and
    $n_u=\Delta_{03}^{\mathbb C}\Delta_{12}^{\mathbb C}$. Then
    $n_s+n_t+n_u=0$ and $n_t^2=(n_s+n_u)^2=n_s^2+2n_s n_u+n_u^2$. -/)
  (proof := /-- Apply \texttt{complexTwoRowMinor\_pluecker} and close by ring algebra. -/)]
theorem bcj_plucker_jacobi_and_double_copy (M_C : Matrix (Fin 2) (Fin 4) ℂ) :
    let n_s := complexTwoRowMinor M_C 0 1 * complexTwoRowMinor M_C 2 3
    let n_t := - (complexTwoRowMinor M_C 0 2 * complexTwoRowMinor M_C 1 3)
    let n_u := complexTwoRowMinor M_C 0 3 * complexTwoRowMinor M_C 1 2
    n_s + n_t + n_u = 0 ∧
      n_t ^ 2 = n_s ^ 2 + 2 * n_s * n_u + n_u ^ 2 := by
  intro n_s n_t n_u
  have h_pl := complexTwoRowMinor_pluecker M_C 0 1 2 3
  have h_jacobi : n_s + n_t + n_u = 0 := by
    dsimp [n_s, n_t, n_u]
    linear_combination h_pl
  have h_nt : n_t = - (n_s + n_u) := by
    linear_combination h_jacobi
  refine ⟨h_jacobi, ?_⟩
  rw [h_nt]
  ring

/-- Keplerian planetary orbit parameters around a central mass:
semi-major axis $a > 0$ and orbital eccentricity $e \in [0, 1)$. -/
@[blueprint "def:signals-ddf-planetary-orbit"
  (title := "Planetary orbit parameters (semi-major axis a > 0 and eccentricity e ∈ [0, 1))")
  (statement := /-- A bound elliptical planetary orbit record with semi-major axis $a>0$
    and eccentricity $0\le e<1$. -/)]
structure PlanetaryOrbit where
  semiMajorAxis : ℝ
  semiMajorAxis_pos : 0 < semiMajorAxis
  eccentricity : ℝ
  eccentricity_nonneg : 0 ≤ eccentricity
  eccentricity_lt_one : eccentricity < 1

/-- Semi-latus rectum $p = a(1 - e^2)$ of a planetary orbit. -/
@[blueprint "def:signals-ddf-semi-latus-rectum"
  (title := "Planetary orbit semi-latus rectum p = a(1 - e²)")
  (statement := /-- For an orbit with semi-major axis $a$ and eccentricity $e$, define
    $p = a(1-e^2)$. -/)]
def PlanetaryOrbit.semiLatusRectum (orb : PlanetaryOrbit) : ℝ :=
  orb.semiMajorAxis * (1 - orb.eccentricity ^ 2)

/-- Perihelion distance $r_{\min} = a(1 - e)$ of a planetary orbit. -/
@[blueprint "def:signals-ddf-perihelion-radius"
  (title := "Planetary perihelion radius r_min = a(1 - e)")
  (statement := /-- Define the perihelion radius $r_{\min}=a(1-e)$. -/)]
def PlanetaryOrbit.perihelionRadius (orb : PlanetaryOrbit) : ℝ :=
  orb.semiMajorAxis * (1 - orb.eccentricity)

/-- Aphelion distance $r_{\max} = a(1 + e)$ of a planetary orbit. -/
@[blueprint "def:signals-ddf-aphelion-radius"
  (title := "Planetary aphelion radius r_max = a(1 + e)")
  (statement := /-- Define the aphelion radius $r_{\max}=a(1+e)$. -/)]
def PlanetaryOrbit.aphelionRadius (orb : PlanetaryOrbit) : ℝ :=
  orb.semiMajorAxis * (1 + orb.eccentricity)

/-- For any bound `PlanetaryOrbit` ($a > 0$, $0 \le e < 1$), $1 - e^2 > 0$,
$p > 0$, $r_{\min} > 0$, $r_{\max} > 0$, $r_{\min} + r_{\max} = 2a$, and
$r_{\min} r_{\max} = a p$. -/
@[blueprint "lem:signals-ddf-planetary-orbit-radii"
  (title := "Positivity and harmonic/geometric relations of perihelion, aphelion, and semi-latus rectum")
  (statement := /-- For any \texttt{orb : PlanetaryOrbit}, $0<1-e^2$, $0<p$,
    $0<r_{\min}$, $0<r_{\max}$, $r_{\min}+r_{\max}=2a$, and $r_{\min}r_{\max}=a p$. -/)
  (proof := /-- Use $0<a$ and $0\le e<1$ to establish positivity, and close the sum/product
    identities by ring algebra. -/)
  (latexEnv := "lemma")]
lemma PlanetaryOrbit.radii_identities (orb : PlanetaryOrbit) :
    0 < 1 - orb.eccentricity ^ 2 ∧
      0 < orb.semiLatusRectum ∧
      0 < orb.perihelionRadius ∧
      0 < orb.aphelionRadius ∧
      orb.perihelionRadius + orb.aphelionRadius = 2 * orb.semiMajorAxis ∧
      orb.perihelionRadius * orb.aphelionRadius =
        orb.semiMajorAxis * orb.semiLatusRectum := by
  have ha := orb.semiMajorAxis_pos
  have he0 := orb.eccentricity_nonneg
  have he1 := orb.eccentricity_lt_one
  have h1e : 0 < 1 - orb.eccentricity := by linarith
  have h1pe : 0 < 1 + orb.eccentricity := by linarith
  have h1e2 : 0 < 1 - orb.eccentricity ^ 2 := by nlinarith
  refine ⟨h1e2, mul_pos ha h1e2, mul_pos ha h1e, mul_pos ha h1pe, ?_, ?_⟩
  · unfold PlanetaryOrbit.perihelionRadius PlanetaryOrbit.aphelionRadius
    ring
  · unfold PlanetaryOrbit.perihelionRadius PlanetaryOrbit.aphelionRadius
      PlanetaryOrbit.semiLatusRectum
    ring

/-- **Harmonic-Mean Identity of Perihelion and Aphelion Radii**:
For any bound `PlanetaryOrbit`, the reciprocal of the semi-latus rectum $p = a(1 - e^2)$
is the arithmetic mean of the reciprocal perihelion and aphelion radii:
$\frac{1}{r_{\min}} + \frac{1}{r_{\max}} = \frac{2}{p}$. -/
@[blueprint "lem:signals-ddf-planetary-harmonic-mean"
  (title := "Harmonic-mean identity 1/r_min + 1/r_max = 2/p for planetary orbits")
  (statement := /-- For any \texttt{orb : PlanetaryOrbit},
    $\frac{1}{r_{\min}}+\frac{1}{r_{\max}}=\frac{2}{p}$. -/)
  (proof := /-- Use $r_{\min}+r_{\max}=2a$ and $r_{\min}r_{\max}=a p$ from
    \texttt{orb.radii\_identities}, then clear nonzero denominators. -/)
  (latexEnv := "lemma")]
lemma PlanetaryOrbit.harmonic_mean_semiLatusRectum (orb : PlanetaryOrbit) :
    1 / orb.perihelionRadius + 1 / orb.aphelionRadius =
      2 / orb.semiLatusRectum := by
  have he0 := orb.eccentricity_nonneg
  have he1 := orb.eccentricity_lt_one
  have h1me : 1 - orb.eccentricity ≠ 0 := by linarith
  have h1pe : 1 + orb.eccentricity ≠ 0 := by linarith
  have h1e2 : 1 - orb.eccentricity ^ 2 ≠ 0 := ne_of_gt (orb.radii_identities).1
  have ha : orb.semiMajorAxis ≠ 0 := ne_of_gt orb.semiMajorAxis_pos
  unfold PlanetaryOrbit.perihelionRadius PlanetaryOrbit.aphelionRadius
    PlanetaryOrbit.semiLatusRectum
  field_simp [h1me, h1pe, h1e2, ha]
  ring

/-- **Precessing Polar Conic Trajectory $r(\varphi; \eta_{\mathrm{prec}})$**:
Solution of the perturbed Binet orbit equation
$r(\varphi; \eta_{\mathrm{prec}}) = \frac{p}{1 + e\cos((1 - \eta_{\mathrm{prec}})\varphi)}$
with dimensionless precession rate parameter $\eta_{\mathrm{prec}} = \frac{3 G M}{c^2 p} = \frac{\Delta\varpi}{2\pi}$. -/
@[blueprint "def:signals-ddf-precessing-conic-radius"
  (title := "Precessing polar conic orbital radius r(φ; η_prec)")
  (statement := /-- For \texttt{orb : PlanetaryOrbit}, precession parameter $\eta_{\mathrm{prec}}$,
    and azimuth $\varphi$, define
    $r(\varphi;\eta_{\mathrm{prec}}) = \frac{p}{1 + e\cos\bigl((1-\eta_{\mathrm{prec}})\varphi\bigr)}$. -/)]
noncomputable def PlanetaryOrbit.precessingRadius
    (orb : PlanetaryOrbit) (etaPrecession φ : ℝ) : ℝ :=
  orb.semiLatusRectum /
    (1 + orb.eccentricity * Real.cos ((1 - etaPrecession) * φ))

/-- **Exact Perihelion and Aphelion Turning Points of the Precessing Trajectory**:
At $\varphi = 0$ (initial perihelion), $r(0; \eta_{\mathrm{prec}}) = r_{\min} = a(1 - e)$,
and for $1 - \eta_{\mathrm{prec}} \neq 0$, at the precessed aphelion angle
$\varphi_{\mathrm{aph}} = \frac{\pi}{1 - \eta_{\mathrm{prec}}}$,
$r(\varphi_{\mathrm{aph}}; \eta_{\mathrm{prec}}) = r_{\max} = a(1 + e)$. -/
@[blueprint "thm:signals-ddf-precessing-conic-turning-points"
  (title := "Exact perihelion and aphelion turning-point radii of the precessing conic orbit")
  (statement := /-- For any \texttt{orb : PlanetaryOrbit} and $1-\eta_{\mathrm{prec}}\ne 0$,
    $r(0;\eta_{\mathrm{prec}})=r_{\min}$ and
    $r\bigl(\frac{\pi}{1-\eta_{\mathrm{prec}}};\eta_{\mathrm{prec}}\bigr)=r_{\max}$. -/)
  (proof := /-- Evaluate $\cos(0)=1$ and $\cos(\pi)=-1$, factor $1-e^2=(1-e)(1+e)$, and
    cancel $1+e\ne 0$ and $1-e\ne 0$. -/)]
theorem PlanetaryOrbit.precessingRadius_perihelion_and_aphelion
    (orb : PlanetaryOrbit) (etaPrecession : ℝ)
    (h_eta : 1 - etaPrecession ≠ 0) :
    orb.precessingRadius etaPrecession 0 = orb.perihelionRadius ∧
      orb.precessingRadius etaPrecession (Real.pi / (1 - etaPrecession)) =
        orb.aphelionRadius := by
  have he0 := orb.eccentricity_nonneg
  have he1 := orb.eccentricity_lt_one
  have h1pe : 1 + orb.eccentricity ≠ 0 := by linarith
  have h1me : 1 - orb.eccentricity ≠ 0 := by linarith
  refine ⟨?_, ?_⟩
  · unfold PlanetaryOrbit.precessingRadius PlanetaryOrbit.semiLatusRectum
      PlanetaryOrbit.perihelionRadius
    simp only [mul_zero, Real.cos_zero, mul_one]
    have h_fac :
        orb.semiMajorAxis * (1 - orb.eccentricity ^ 2) =
          orb.semiMajorAxis * (1 - orb.eccentricity) * (1 + orb.eccentricity) := by ring
    rw [h_fac, mul_div_cancel_right₀ _ h1pe]
  · unfold PlanetaryOrbit.precessingRadius PlanetaryOrbit.semiLatusRectum
      PlanetaryOrbit.aphelionRadius
    have h_angle : (1 - etaPrecession) * (Real.pi / (1 - etaPrecession)) = Real.pi :=
      mul_div_cancel₀ Real.pi h_eta
    rw [h_angle, Real.cos_pi]
    have h_denom : 1 + orb.eccentricity * (-1) = 1 - orb.eccentricity := by ring
    have h_fac :
        orb.semiMajorAxis * (1 - orb.eccentricity ^ 2) =
          orb.semiMajorAxis * (1 + orb.eccentricity) * (1 - orb.eccentricity) := by ring
    rw [h_denom, h_fac, mul_div_cancel_right₀ _ h1me]

/-- **1-Loop Post-Minkowskian QED/Graviton Effective Central Potential (Without DDF)**:
$V_{\mathrm{eff}}^{\mathrm{PM}}(G, M, m, c, L, r) = -\frac{G M m}{r}\left(1 + \frac{3 L^2}{m^2 c^2 r^2}\right)$,
derived by 3D Fourier inversion of the tree-level $O(G)$ and 1-loop triangle $O(G^2)$
scattering amplitudes in flat Minkowski space. -/
@[blueprint "def:signals-qed-post-minkowskian-effective-potential"
  (title := "Flat-space 1-loop post-Minkowskian effective potential V_eff^PM(r)")
  (statement := /-- Define $V_{\mathrm{eff}}^{\mathrm{PM}}(G,M,m,c,L,r)
    = -\frac{G M m}{r}\left(1 + \frac{3 L^2}{m^2 c^2 r^2}\right)$. -/)]
noncomputable def postMinkowskianEffectivePotential
    (G sourceMass planetMass c angularMomentum r : ℝ) : ℝ :=
  - (G * sourceMass * planetMass / r) *
    (1 + 3 * angularMomentum ^ 2 / (planetMass ^ 2 * c ^ 2 * r ^ 2))

/-- **Post-Minkowskian Anomalous Perihelion Precession per Orbit (Radians, Without DDF)**:
$\Delta\varpi_{\mathrm{PM}} = \frac{6\pi G M}{c^2 a(1 - e^2)} = \frac{6\pi G M}{c^2 p}$. -/
@[blueprint "def:signals-qed-perihelion-precession-rad-pm"
  (title := "Flat-space 1-loop post-Minkowskian perihelion precession Δϖ_PM = 6π G M / (c² p)")
  (statement := /-- For \texttt{orb : PlanetaryOrbit} and parameters $(G,M,c)$, define
    $\Delta\varpi_{\mathrm{PM}} = \frac{6\pi G M}{c^2 p}$. -/)]
noncomputable def PlanetaryOrbit.perihelionPrecessionRadPM
    (orb : PlanetaryOrbit) (G sourceMass c : ℝ) : ℝ :=
  6 * Real.pi * G * sourceMass / (c ^ 2 * orb.semiLatusRectum)

/-- **Canonical $Gr_{\mathbb{C}}(2,4)$ Planetary Orbital Precession Twistor Matrix**:
Embeds a `PlanetaryOrbit` `orb` (with eccentricity $e \in [0, 1)$) and anomalous
perihelion advance $\Delta\varpi$ into $Gr_{\mathbb{C}}(2,4)$ by encoding the normalized
aphelion amplitude $z_{\mathrm{aph}} = \sqrt{1 + e}\,e^{i \Delta\varpi / 2}$ and
normalized perihelion amplitude $z_{\mathrm{per}} = \sqrt{1 - e}\,e^{-i \Delta\varpi / 2}$. -/
@[blueprint "def:signals-ddf-planetary-gr24-precession-matrix"
  (title := "Canonical Gr_C(2,4) planetary orbital precession twistor matrix")
  (statement := /-- For \texttt{orb : PlanetaryOrbit} and perihelion advance $\Delta\varpi$,
    define $M_{\mathbb C}^{\mathrm{orb}}(\mathrm{orb},\Delta\varpi)
    = M_{\mathbb C}\!\bigl(\sqrt{1+e}\,e^{i\Delta\varpi/2},\,\sqrt{1-e}\,e^{-i\Delta\varpi/2}\bigr)\in\mathbb C^{2\times 4}$. -/)]
noncomputable def PlanetaryOrbit.gr24PrecessionMatrix
    (orb : PlanetaryOrbit) (deltaVarpi : ℝ) : Matrix (Fin 2) (Fin 4) ℂ :=
  let θ := deltaVarpi / 2
  let a := Real.sqrt (1 + orb.eccentricity)
  let b := Real.sqrt (1 - orb.eccentricity)
  let z_aph : ℂ := ↑(a * Real.cos θ) + Complex.I * ↑(a * Real.sin θ)
  let z_per : ℂ := ↑(b * Real.cos θ) - Complex.I * ↑(b * Real.sin θ)
  complexGr24ChannelMatrix z_aph z_per

/-- **Master $Gr_{\mathbb{C}}(2,4)$ Planetary Orbit & Perihelion Precession Bridge**:
For any `PlanetaryOrbit` `orb` and anomalous perihelion advance $\Delta\varpi$, let
$M_{\mathbb{C}}^{\mathrm{orb}} = \mathrm{orb}.\mathrm{gr24PrecessionMatrix}\,\Delta\varpi$.
Then:
1. The first Plücker channel density equals the normalized aphelion distance:
   $|w_A^{\mathbb{C}}(M_{\mathbb{C}}^{\mathrm{orb}})|^2 = 1 + e = \frac{r_{\max}}{a}$,
2. The second Plücker channel density equals the normalized perihelion distance:
   $|w_B^{\mathbb{C}}(M_{\mathbb{C}}^{\mathrm{orb}})|^2 = 1 - e = \frac{r_{\min}}{a}$,
3. The half-difference of the channel densities equals the orbital eccentricity:
   $\frac{|w_A^{\mathbb{C}}|^2 - |w_B^{\mathbb{C}}|^2}{2} = e$,
4. The product of the channel densities equals the semi-latus rectum ratio
   (which governs $\Delta\varpi = 6\pi G M / (c^2 p)$):
   $|w_A^{\mathbb{C}}|^2\,|w_B^{\mathbb{C}}|^2 = 1 - e^2 = \frac{p}{a}$, and
5. The squared modulus of the crossing Plücker product encodes both $\sqrt{1 - e^2} = \sqrt{p/a}$
   and the perihelion precession cosine $\cos(\Delta\varpi)$:
   $|\Delta_{02}^{\mathbb{C}}(M_{\mathbb{C}}^{\mathrm{orb}})\,\Delta_{13}^{\mathbb{C}}(M_{\mathbb{C}}^{\mathrm{orb}})|^2 = 2\bigl(1 + \sqrt{1 - e^2}\cos(\Delta\varpi)\bigr)$. -/
@[blueprint "thm:signals-ddf-planetary-gr24-precession-bridge"
  (title := "Master Gr_C(2,4)-DDF planetary orbit bridge: aphelion/perihelion Madelung densities, semi-latus rectum product, and Δϖ precession")
  (statement := /-- For \texttt{orb : PlanetaryOrbit} and $M_{\mathbb C}^{\mathrm{orb}}=\mathrm{orb}.\mathrm{gr24PrecessionMatrix}(\Delta\varpi)$:
    (1) $|w_A^{\mathbb C}|^2 = 1+e = r_{\max}/a$,
    (2) $|w_B^{\mathbb C}|^2 = 1-e = r_{\min}/a$,
    (3) $(|w_A^{\mathbb C}|^2 - |w_B^{\mathbb C}|^2)/2 = e$,
    (4) $|w_A^{\mathbb C}|^2\,|w_B^{\mathbb C}|^2 = 1-e^2 = p/a$, and
    (5) $|\Delta_{02}^{\mathbb C}\Delta_{13}^{\mathbb C}|^2 = 2\bigl(1+\sqrt{1-e^2}\cos(\Delta\varpi)\bigr)$. -/)
  (proof := /-- Evaluate \texttt{complexGr24ChannelMatrix\_minors}, expand \texttt{Complex.normSq}
    using $\cos^2(\Delta\varpi/2)+\sin^2(\Delta\varpi/2)=1$ and
    $\cos(\Delta\varpi)=2\cos^2(\Delta\varpi/2)-1$, and relate $1\pm e$ and $1-e^2$ to
    $r_{\max}/a$, $r_{\min}/a$, and $p/a$. -/)]
theorem PlanetaryOrbit.gr24PrecessionMatrix_orbital_identities
    (orb : PlanetaryOrbit) (deltaVarpi : ℝ) :
    let M_C := orb.gr24PrecessionMatrix deltaVarpi
    Complex.normSq (complexPluckerSinkAmplitudeA M_C) = orb.aphelionRadius / orb.semiMajorAxis ∧
      Complex.normSq (complexPluckerSinkAmplitudeB M_C) = orb.perihelionRadius / orb.semiMajorAxis ∧
      (Complex.normSq (complexPluckerSinkAmplitudeA M_C) -
        Complex.normSq (complexPluckerSinkAmplitudeB M_C)) / 2 = orb.eccentricity ∧
      Complex.normSq (complexPluckerSinkAmplitudeA M_C) *
        Complex.normSq (complexPluckerSinkAmplitudeB M_C) =
        orb.semiLatusRectum / orb.semiMajorAxis ∧
      Complex.normSq
        (complexTwoRowMinor M_C 0 2 * complexTwoRowMinor M_C 1 3) =
        2 * (1 + Real.sqrt (1 - orb.eccentricity ^ 2) * Real.cos deltaVarpi) := by
  intro M_C
  have ha_pos := orb.semiMajorAxis_pos
  have ha_ne : orb.semiMajorAxis ≠ 0 := ne_of_gt ha_pos
  have he0 := orb.eccentricity_nonneg
  have he1 := orb.eccentricity_lt_one
  have h1pe : 0 ≤ 1 + orb.eccentricity := by linarith
  have h1me : 0 ≤ 1 - orb.eccentricity := by linarith
  let θ := deltaVarpi / 2
  let a := Real.sqrt (1 + orb.eccentricity)
  let b := Real.sqrt (1 - orb.eccentricity)
  let z_aph : ℂ := ↑(a * Real.cos θ) + Complex.I * ↑(a * Real.sin θ)
  let z_per : ℂ := ↑(b * Real.cos θ) - Complex.I * ↑(b * Real.sin θ)
  have h_minors := complexGr24ChannelMatrix_minors z_aph z_per
  have h_wA : complexPluckerSinkAmplitudeA M_C = z_aph := h_minors.1
  have h_wB : complexPluckerSinkAmplitudeB M_C = z_per := h_minors.2.1
  have h_cross :
      complexTwoRowMinor M_C 0 2 * complexTwoRowMinor M_C 1 3 = z_aph + z_per :=
    h_minors.2.2
  have h_trig : (Real.cos θ) ^ 2 + (Real.sin θ) ^ 2 = 1 := Real.cos_sq_add_sin_sq θ
  have ha2 : a ^ 2 = 1 + orb.eccentricity := Real.sq_sqrt h1pe
  have hb2 : b ^ 2 = 1 - orb.eccentricity := Real.sq_sqrt h1me
  have hab : a * b = Real.sqrt (1 - orb.eccentricity ^ 2) := by
    dsimp [a, b]
    rw [← Real.sqrt_mul h1pe]
    congr 1
    ring
  have h_normA : Complex.normSq (complexPluckerSinkAmplitudeA M_C) = 1 + orb.eccentricity := by
    rw [h_wA]
    dsimp [z_aph]
    simp only [Complex.normSq_apply, Complex.add_re, Complex.add_im, Complex.mul_re,
      Complex.mul_im, Complex.ofReal_re, Complex.ofReal_im, Complex.I_re, Complex.I_im]
    calc
      _ = a ^ 2 * ((Real.cos θ) ^ 2 + (Real.sin θ) ^ 2) := by ring
      _ = 1 + orb.eccentricity := by rw [ha2, h_trig, mul_one]
  have h_normB : Complex.normSq (complexPluckerSinkAmplitudeB M_C) = 1 - orb.eccentricity := by
    rw [h_wB]
    dsimp [z_per]
    simp only [Complex.normSq_apply, Complex.sub_re, Complex.sub_im, Complex.mul_re,
      Complex.mul_im, Complex.ofReal_re, Complex.ofReal_im, Complex.I_re, Complex.I_im]
    calc
      _ = b ^ 2 * ((Real.cos θ) ^ 2 + (Real.sin θ) ^ 2) := by ring
      _ = 1 - orb.eccentricity := by rw [hb2, h_trig, mul_one]
  have h_aph_div : orb.aphelionRadius / orb.semiMajorAxis = 1 + orb.eccentricity := by
    unfold PlanetaryOrbit.aphelionRadius
    exact mul_div_cancel_left₀ (1 + orb.eccentricity) ha_ne
  have h_per_div : orb.perihelionRadius / orb.semiMajorAxis = 1 - orb.eccentricity := by
    unfold PlanetaryOrbit.perihelionRadius
    exact mul_div_cancel_left₀ (1 - orb.eccentricity) ha_ne
  have h_slr_div : orb.semiLatusRectum / orb.semiMajorAxis = 1 - orb.eccentricity ^ 2 := by
    unfold PlanetaryOrbit.semiLatusRectum
    exact mul_div_cancel_left₀ (1 - orb.eccentricity ^ 2) ha_ne
  have h_cos_dv : Real.cos deltaVarpi = 2 * (Real.cos θ) ^ 2 - 1 := by
    have h2 : deltaVarpi = 2 * θ := by dsimp [θ]; ring
    rw [h2, Real.cos_two_mul]
  have h_cross_norm :
      Complex.normSq (z_aph + z_per) =
        2 * (1 + Real.sqrt (1 - orb.eccentricity ^ 2) * Real.cos deltaVarpi) := by
    have h_expand :
        Complex.normSq (z_aph + z_per) =
          ((a + b) * Real.cos θ) ^ 2 + ((a - b) * Real.sin θ) ^ 2 := by
      dsimp [z_aph, z_per]
      simp only [Complex.normSq_apply, Complex.add_re, Complex.add_im,
        Complex.sub_re, Complex.sub_im, Complex.mul_re, Complex.mul_im,
        Complex.ofReal_re, Complex.ofReal_im, Complex.I_re, Complex.I_im]
      ring
    rw [h_expand]
    calc
      ((a + b) * Real.cos θ) ^ 2 + ((a - b) * Real.sin θ) ^ 2 =
          (a ^ 2 + b ^ 2) * ((Real.cos θ) ^ 2 + (Real.sin θ) ^ 2) +
            2 * (a * b) * (2 * (Real.cos θ) ^ 2 - ((Real.cos θ) ^ 2 + (Real.sin θ) ^ 2)) := by
        ring
      _ = (1 + orb.eccentricity + (1 - orb.eccentricity)) * 1 +
            2 * Real.sqrt (1 - orb.eccentricity ^ 2) * (2 * (Real.cos θ) ^ 2 - 1) := by
        rw [ha2, hb2, h_trig, hab]
      _ = 2 * (1 + Real.sqrt (1 - orb.eccentricity ^ 2) * Real.cos deltaVarpi) := by
        rw [← h_cos_dv]
        ring
  refine ⟨by rw [h_normA, h_aph_div], by rw [h_normB, h_per_div],
    by rw [h_normA, h_normB]; ring,
    by rw [h_normA, h_normB, h_slr_div]; ring,
    by rw [h_cross, h_cross_norm]⟩

/-- Complex twistor channel entry $z_j = \sqrt{w_j}(\cos\theta_j + i\sin\theta_j)$
for sector $j \in \operatorname{Fin} N$ in $Gr_{\mathbb{C}}(2, N + 2)$. -/
@[blueprint "def:signals-ddf-complex-gr2n-twistor-entry"
  (title := "N-ary complex twistor channel entry z_j = √w_j (cos θ_j + i sin θ_j)")
  (statement := /-- For weight $w_j\ge 0$ and phase $\theta_j\in\mathbb R$, define
    $z_j(w_j,\theta_j)=\sqrt{w_j}(\cos\theta_j+i\sin\theta_j)\in\mathbb C$. -/)]
noncomputable def complexGr2NTwistorEntry (weight phase : ℝ) : ℂ :=
  let r := Real.sqrt weight
  ↑(r * Real.cos phase) + Complex.I * ↑(r * Real.sin phase)

/-- **General $N$-ary ($N \ge 1$) Madelung Sector Identities on $Gr_{\mathbb{C}}(2, N+2)$**:
For any number of slits/sinks $N \in \mathbb{N}$ (including $N \ge 3$), non-negative
sector weights $w : \operatorname{Fin} N \to \mathbb{R}$ ($0 \le w_j$), and phases
$\theta : \operatorname{Fin} N \to \mathbb{R}$, let
$z_j = \operatorname{complexGr2NTwistorEntry}(w_j, \theta_j)$ and
$M_{\mathbb{C}}^{(N)} = \operatorname{complexGr2NChannelMatrix}\,N\,z \in \mathbb{C}^{2 \times (N+2)}$. Then:
1. For every sector $j \in \operatorname{Fin} N$, the squared modulus of its Plücker
   minor $\Delta_{0, j+2}^{\mathbb{C}}(M_{\mathbb{C}}^{(N)})$ equals the Madelung
   condensate density $w_j$,
2. The sum of all $N$ Madelung sector densities equals the total $N$-sink flux
   $\sum_{j=0}^{N-1} w_j$, and
3. The collector Plücker minor $\Delta_{0,1}^{\mathbb{C}}(M_{\mathbb{C}}^{(N)})$ equals
   the coherent superposition $\sum_{j=0}^{N-1} \Delta_{0, j+2}^{\mathbb{C}}(M_{\mathbb{C}}^{(N)})$. -/
@[blueprint "thm:signals-ddf-gr2n-madelung-sector-identities"
  (title := "General N-ary (N ≥ 1) Madelung sector densities and flux conservation on Gr_C(2, N+2)")
  (statement := /-- For any $N\in\mathbb N$, $w,\theta:\operatorname{Fin}(N)\to\mathbb R$ with
    $\forall j,\,0\le w_j$, let $z_j=\sqrt{w_j}(\cos\theta_j+i\sin\theta_j)$ and
    $M_{\mathbb C}^{(N)}=M_{\mathbb C}^{(N)}(z)\in\mathbb C^{2\times(N+2)}$. Then:
    (1) $\forall j,\,\bigl|\Delta_{0,j+2}^{\mathbb C}(M_{\mathbb C}^{(N)})\bigr|^2=w_j$,
    (2) $\sum_{j=0}^{N-1}\bigl|\Delta_{0,j+2}^{\mathbb C}(M_{\mathbb C}^{(N)})\bigr|^2=\sum_{j=0}^{N-1}w_j$, and
    (3) $\Delta_{0,1}^{\mathbb C}(M_{\mathbb C}^{(N)})=\sum_{j=0}^{N-1}\Delta_{0,j+2}^{\mathbb C}(M_{\mathbb C}^{(N)})$. -/)
  (proof := /-- Apply \texttt{complexGr2NChannelMatrix\_minors}, evaluate \texttt{Complex.normSq}
    for each $j$ using $\cos^2\theta_j+\sin^2\theta_j=1$ and \texttt{Real.sq\_sqrt}, and sum over $\operatorname{Fin}(N)$. -/)]
theorem complexGr2N_madelung_sector_identities
    (numSlits : ℕ) (w θ : Fin numSlits → ℝ)
    (hw : ∀ j : Fin numSlits, 0 ≤ w j) :
    let z : Fin numSlits → ℂ := fun j => complexGr2NTwistorEntry (w j) (θ j)
    let M_C := complexGr2NChannelMatrix numSlits z
    (∀ j : Fin numSlits,
      Complex.normSq (complexTwoRowMinor M_C (narySourceCol numSlits) (narySlitCol j)) = w j) ∧
    (∑ j : Fin numSlits,
      Complex.normSq (complexTwoRowMinor M_C (narySourceCol numSlits) (narySlitCol j))) =
      (∑ j : Fin numSlits, w j) ∧
    complexTwoRowMinor M_C (narySourceCol numSlits) (naryCollectorCol numSlits) =
      ∑ j : Fin numSlits,
        complexTwoRowMinor M_C (narySourceCol numSlits) (narySlitCol j) := by
  intro z M_C
  have h_minors := complexGr2NChannelMatrix_minors numSlits z
  have h_each : ∀ j : Fin numSlits,
      Complex.normSq (complexTwoRowMinor M_C (narySourceCol numSlits) (narySlitCol j)) = w j := by
    intro j
    rw [h_minors.1 j]
    dsimp [z, complexGr2NTwistorEntry]
    have h_trig : (Real.cos (θ j)) ^ 2 + (Real.sin (θ j)) ^ 2 = 1 :=
      Real.cos_sq_add_sin_sq (θ j)
    simp only [Complex.normSq_apply, Complex.add_re, Complex.add_im, Complex.mul_re,
      Complex.mul_im, Complex.ofReal_re, Complex.ofReal_im, Complex.I_re, Complex.I_im]
    calc
      _ = (Real.sqrt (w j)) ^ 2 * ((Real.cos (θ j)) ^ 2 + (Real.sin (θ j)) ^ 2) := by ring
      _ = w j := by rw [Real.sq_sqrt (hw j), h_trig, mul_one]
  refine ⟨h_each, ?_, h_minors.2.2.2⟩
  refine Finset.sum_congr rfl (fun j _ => h_each j)

/-- **$N$-Body Newtonian / Superfluid Bernoulli Sink Potential**:
For $N$ gravitating bodies (`numBodies : ℕ`) with masses $M_j$ and radial distances $r_j$,
the total Newtonian/superfluid enthalpy deficit is $\Phi_\phi^{(N)} = -\sum_{j=0}^{N-1} \frac{G_\phi M_j}{r_j}$. -/
@[blueprint "def:signals-ddf-nbody-bernoulli-potential"
  (title := "N-body superfluid Bernoulli sink potential Φ_ϕ^(N)")
  (statement := /-- For $N$ bodies with masses $M:\operatorname{Fin}(N)\to\mathbb R$ and
    distances $r:\operatorname{Fin}(N)\to\mathbb R$, define
    $\Phi_\phi^{(N)}=-\sum_{j=0}^{N-1}\frac{G_\phi M_j}{r_j}$. -/)]
noncomputable def nBodyBernoulliPotential
    (G_phi : ℝ) (numBodies : ℕ) (mass distance : Fin numBodies → ℝ) : ℝ :=
  - ∑ j : Fin numBodies, (G_phi * mass j / distance j)

/-- **Embedding $N$-Body Gravitational Sink Potentials in $Gr_{\mathbb{C}}(2, N+2)$**:
For $N$ bodies with $G_\phi > 0$, $M_j \ge 0$, and $r_j > 0$, encoding the $N$ sink
weights $w_j = G_\phi M_j / r_j \ge 0$ in `complexGr2NChannelMatrix` makes the total
Madelung sink density $\sum_{j=0}^{N-1} |\Delta_{0, j+2}^{\mathbb{C}}|^2$ equal to
$-\Phi_\phi^{(N)}$. -/
@[blueprint "thm:signals-ddf-nbody-bernoulli-gr2n-embedding"
  (title := "N-body gravitational sink potential equals negative total Madelung density on Gr_C(2, N+2)")
  (statement := /-- For $G_\phi>0$, $M_j\ge 0$, and $r_j>0$, let $w_j=G_\phi M_j/r_j$ and
    $M_{\mathbb C}^{(N)}=M_{\mathbb C}^{(N)}\bigl(\sqrt{w_j}e^{i\theta_j}\bigr)\in\mathbb C^{2\times(N+2)}$.
    Then $\Phi_\phi^{(N)} = -\sum_{j=0}^{N-1}\bigl|\Delta_{0,j+2}^{\mathbb C}(M_{\mathbb C}^{(N)})\bigr|^2$. -/)
  (proof := /-- Apply \texttt{complexGr2N\_madelung\_sector\_identities} to $w_j=G_\phi M_j/r_j\ge 0$. -/)]
theorem nBodyBernoulliPotential_eq_neg_gr2N_madelung_sum
    (G_phi : ℝ) (hG : 0 ≤ G_phi) (numBodies : ℕ)
    (mass distance θ : Fin numBodies → ℝ)
    (h_mass : ∀ j, 0 ≤ mass j) (h_dist : ∀ j, 0 < distance j) :
    let w : Fin numBodies → ℝ := fun j => G_phi * mass j / distance j
    let z : Fin numBodies → ℂ := fun j => complexGr2NTwistorEntry (w j) (θ j)
    let M_C := complexGr2NChannelMatrix numBodies z
    nBodyBernoulliPotential G_phi numBodies mass distance =
      - ∑ j : Fin numBodies,
          Complex.normSq (complexTwoRowMinor M_C (narySourceCol numBodies) (narySlitCol j)) := by
  intro w z M_C
  have hw : ∀ j : Fin numBodies, 0 ≤ w j := fun j =>
    div_nonneg (mul_nonneg hG (h_mass j)) (le_of_lt (h_dist j))
  have h_sum := (complexGr2N_madelung_sector_identities numBodies w θ hw).2.1
  unfold nBodyBernoulliPotential
  rw [h_sum]

/-- **Machine-Checked Numerical Verification of Mercury's $42.98''/\text{century}$ Relativistic Precession and $574.61''/\text{century}$ Total Advance**:
For solar Schwarzschild / acoustic horizon $r_{H,\odot} = 2.95325\text{ km}$, Mercury semi-latus rectum
$p_{\text{Mercury}} = 55460529\text{ km}$, and $415.2026$ revolutions per Julian century:
1. The relativistic / 1-loop QFT / DDF precession per century lies strictly in
   $(42.98, 42.99)$ arcseconds/century, and
2. Adding the $531.63''/\text{century}$ Newtonian $N$-body planetary perturbation places
   Mercury's total inertial perihelion advance strictly in $(574.61, 574.62)$ arcseconds/century. -/
@[blueprint "thm:signals-ddf-mercury-precession-numerical-bounds"
  (title := "Machine-checked numerical bounds 42.98 < Δϖ_Mercury < 42.99 and 574.61 < Δϖ_tot < 574.62 arcsec/century")
  (statement := /-- For $r_{H,\odot}=2.95325\text{ km}$, $p_{\mathrm{Merc}}=55460529\text{ km}$,
    and $N_{\mathrm{cent}}=415.2026$, let
    $\dot{\varpi}_{\mathrm{rel}} = \frac{1944000\,r_{H,\odot}}{p_{\mathrm{Merc}}}\cdot N_{\mathrm{cent}}$.
    Then $42.98 < \dot{\varpi}_{\mathrm{rel}} < 42.99$ and
    $574.61 < \dot{\varpi}_{\mathrm{rel}} + 531.63 < 574.62$. -/)
  (proof := /-- Evaluate the rational inequalities directly by \texttt{norm\_num}. -/)]
theorem mercury_perihelion_precession_arcsec_per_century_bounds :
    let r_H_sun : ℝ := 295325 / 100000
    let p_mercury : ℝ := 55460529
    let orbits_per_century : ℝ := 4152026 / 10000
    let rel_arcsec_per_century := (1944000 * r_H_sun / p_mercury) * orbits_per_century
    let newtonian_nbody_arcsec_per_century : ℝ := 53163 / 100
    4298 / 100 < rel_arcsec_per_century ∧
      rel_arcsec_per_century < 4299 / 100 ∧
      57461 / 100 < rel_arcsec_per_century + newtonian_nbody_arcsec_per_century ∧
      rel_arcsec_per_century + newtonian_nbody_arcsec_per_century < 57462 / 100 := by
  norm_num

/-! ## Gravitational Waves Without DDF: Spin-2 Double Copy, Dynamic $Gr_{\mathbb{C}}(2,4)$ Quadrupole Twistor Matrix, and 2.5PN Peters–Mathews Radiation -/

/-- Transverse-traceless plus ($+$) polarization angular factor
$F_+(\iota) = \frac{1 + \cos^2\iota}{2}$ for orbital inclination angle $\iota$. -/
@[blueprint "def:signals-qed-gw-plus-polarization-factor"
  (title := "Gravitational-wave plus (+) polarization angular factor F_+(ι) = (1 + cos² ι) / 2")
  (statement := /-- For binary inclination angle $\iota\in\mathbb R$, define
    $F_+(\iota) = \frac{1 + \cos^2\iota}{2}$. -/)]
noncomputable def gravitonPlusPolarizationFactor (inclination : ℝ) : ℝ :=
  (1 + (Real.cos inclination) ^ 2) / 2

/-- Transverse-traceless cross ($\times$) polarization angular factor
$F_\times(\iota) = \cos\iota$ for orbital inclination angle $\iota$. -/
@[blueprint "def:signals-qed-gw-cross-polarization-factor"
  (title := "Gravitational-wave cross (×) polarization angular factor F_×(ι) = cos ι")
  (statement := /-- For binary inclination angle $\iota\in\mathbb R$, define
    $F_\times(\iota) = \cos\iota$. -/)]
noncomputable def gravitonCrossPolarizationFactor (inclination : ℝ) : ℝ :=
  Real.cos inclination

/-- **Dynamic $Gr_{\mathbb{C}}(2,4)$ Radiative Quadrupole Twistor Matrix (`gr24QuadrupoleWaveMatrix`)**:
Promotes the static perihelion half-angle $\Delta\varpi / 2$ in `PlanetaryOrbit.gr24PrecessionMatrix`
to the running orbital phase $\theta(t) = \Phi_{\mathrm{orb}}(t) + \Delta\varpi / 2$
(corresponding to total quadrupole phase $2\Phi_{\mathrm{orb}}(t) + \Delta\varpi$). -/
@[blueprint "def:signals-qed-gw-gr24-quadrupole-wave-matrix"
  (title := "Dynamic Gr_C(2,4) radiative quadrupole twistor matrix M_C^GW(orb, Φ_orb, Δϖ)")
  (statement := /-- For \texttt{orb : PlanetaryOrbit}, orbital phase $\Phi_{\mathrm{orb}}$, and
    perihelion advance $\Delta\varpi$, define
    $M_{\mathbb C}^{\mathrm{GW}}(\mathrm{orb},\Phi_{\mathrm{orb}},\Delta\varpi)
    = \mathrm{orb}.\mathrm{gr24PrecessionMatrix}(2\Phi_{\mathrm{orb}}+\Delta\varpi)$. -/)]
noncomputable def PlanetaryOrbit.gr24QuadrupoleWaveMatrix
    (orb : PlanetaryOrbit) (orbitalPhase deltaVarpi : ℝ) : Matrix (Fin 2) (Fin 4) ℂ :=
  orb.gr24PrecessionMatrix (2 * orbitalPhase + deltaVarpi)

/-- Characteristic flat-space quadrupole gravitational-wave strain amplitude
$h_0 = \frac{4 G^2 m_1 m_2}{c^4 R a}$ at detector luminosity distance $R$. -/
@[blueprint "def:signals-qed-gw-quadrupole-strain-amplitude-pm"
  (title := "Flat-space quadrupole GW strain amplitude h_0 = 4 G² m₁ m₂ / (c⁴ R a)")
  (statement := /-- For \texttt{orb : PlanetaryOrbit}, gravitational constant $G$, masses $m_1,m_2$,
    speed of light $c$, and detector distance $R$, define
    $h_0 = \frac{4 G^2 m_1 m_2}{c^4 R a}$. -/)]
noncomputable def PlanetaryOrbit.quadrupoleStrainAmplitudePM
    (orb : PlanetaryOrbit) (G m1 m2 c R : ℝ) : ℝ :=
  4 * G ^ 2 * m1 * m2 / (c ^ 4 * R * orb.semiMajorAxis)

/-- Far-field plus-polarized ($h_+$) gravitational-wave strain waveform
$h_+(t) = -h_0\,F_+(\iota)\,\cos(2\Phi_{\mathrm{orb}}(t) + \Delta\varpi)$. -/
@[blueprint "def:signals-qed-gw-strain-plus"
  (title := "Far-field plus-polarized gravitational-wave strain h_+(t)")
  (statement := /-- Define $h_+(t) = -h_0\,F_+(\iota)\,\cos(2\Phi_{\mathrm{orb}}+\Delta\varpi)$. -/)]
noncomputable def PlanetaryOrbit.gwStrainPlus
    (orb : PlanetaryOrbit) (G m1 m2 c R inclination orbitalPhase deltaVarpi : ℝ) : ℝ :=
  - orb.quadrupoleStrainAmplitudePM G m1 m2 c R *
    gravitonPlusPolarizationFactor inclination *
    Real.cos (2 * orbitalPhase + deltaVarpi)

/-- Far-field cross-polarized ($h_\times$) gravitational-wave strain waveform
$h_\times(t) = -h_0\,F_\times(\iota)\,\sin(2\Phi_{\mathrm{orb}}(t) + \Delta\varpi)$. -/
@[blueprint "def:signals-qed-gw-strain-cross"
  (title := "Far-field cross-polarized gravitational-wave strain h_×(t)")
  (statement := /-- Define $h_\times(t) = -h_0\,F_\times(\iota)\,\sin(2\Phi_{\mathrm{orb}}+\Delta\varpi)$. -/)]
noncomputable def PlanetaryOrbit.gwStrainCross
    (orb : PlanetaryOrbit) (G m1 m2 c R inclination orbitalPhase deltaVarpi : ℝ) : ℝ :=
  - orb.quadrupoleStrainAmplitudePM G m1 m2 c R *
    gravitonCrossPolarizationFactor inclination *
    Real.sin (2 * orbitalPhase + deltaVarpi)

/-- Peters–Mathews eccentricity numerator polynomial
$P_{\mathrm{PM}}(e) = 1 + \frac{73}{24}e^2 + \frac{37}{96}e^4$. -/
@[blueprint "def:signals-qed-peters-mathews-polynomial"
  (title := "Peters-Mathews eccentricity polynomial P_PM(e) = 1 + (73/24)e² + (37/96)e⁴")
  (statement := /-- For \texttt{orb : PlanetaryOrbit}, define
    $P_{\mathrm{PM}}(e) = 1 + \frac{73}{24}e^2 + \frac{37}{96}e^4$. -/)]
noncomputable def PlanetaryOrbit.petersMathewsPolynomial (orb : PlanetaryOrbit) : ℝ :=
  1 + (73 / 24 : ℝ) * orb.eccentricity ^ 2 + (37 / 96 : ℝ) * orb.eccentricity ^ 4

/-- Peters–Mathews 2.5PN eccentricity enhancement factor
$f_{\mathrm{PM}}(e) = \frac{1 + \frac{73}{24}e^2 + \frac{37}{96}e^4}{(\sqrt{1 - e^2})^7}$. -/
@[blueprint "def:signals-qed-peters-mathews-factor"
  (title := "Peters-Mathews 2.5PN eccentricity enhancement factor f_PM(e)")
  (statement := /-- For \texttt{orb : PlanetaryOrbit}, define
    $f_{\mathrm{PM}}(e) = \frac{1 + \frac{73}{24}e^2 + \frac{37}{96}e^4}{(\sqrt{1-e^2})^7}$. -/)]
noncomputable def PlanetaryOrbit.petersMathewsFactor (orb : PlanetaryOrbit) : ℝ :=
  orb.petersMathewsPolynomial / (Real.sqrt (1 - orb.eccentricity ^ 2)) ^ 7

/-- Peters–Mathews 2.5PN ($O(G^3/c^5)$) gravitational-wave luminosity (radiated power)
$P_{\mathrm{GW}} = \frac{32}{5}\frac{G^4 m_1^2 m_2^2 (m_1 + m_2)}{c^5 a^5}\,f_{\mathrm{PM}}(e)$. -/
@[blueprint "def:signals-qed-peters-mathews-luminosity-pm"
  (title := "Peters-Mathews 2.5PN gravitational-wave luminosity P_GW")
  (statement := /-- For \texttt{orb : PlanetaryOrbit} and $(G,m_1,m_2,c)$, define
    $P_{\mathrm{GW}} = \frac{32}{5}\frac{G^4 m_1^2 m_2^2(m_1+m_2)}{c^5 a^5}\,f_{\mathrm{PM}}(e)$. -/)]
noncomputable def PlanetaryOrbit.petersMathewsLuminosityPM
    (orb : PlanetaryOrbit) (G m1 m2 c : ℝ) : ℝ :=
  (32 / 5 : ℝ) * G ^ 4 * m1 ^ 2 * m2 ^ 2 * (m1 + m2) /
    (c ^ 5 * orb.semiMajorAxis ^ 5) * orb.petersMathewsFactor

/-- Resonant $p:q$ mean-motion quadrupole beat frequency
$\omega_{\mathrm{res}}(p, q, \Omega_1, \Omega_2) = 2(p\,\Omega_1 - q\,\Omega_2)$
between two orbiting bodies in an $N$-body system. -/
@[blueprint "def:signals-qed-orbital-resonance-quadrupole-beat"
  (title := "N-body resonant p:q mean-motion quadrupole beat frequency 2(p Ω₁ - q Ω₂)")
  (statement := /-- For integers $p,q\in\mathbb N$ and mean motions $\Omega_1,\Omega_2\in\mathbb R$,
    define $\omega_{\mathrm{res}}(p,q,\Omega_1,\Omega_2) = 2(p\Omega_1 - q\Omega_2)$. -/)]
def orbitalResonanceQuadrupoleBeat (p q : ℕ) (omega1 omega2 : ℝ) : ℝ :=
  2 * ((p : ℝ) * omega1 - (q : ℝ) * omega2)

/-- **Master Theorem for Gravitational Waves Without DDF (Flat-Space QED/Gauge Double Copy, $Gr_{\mathbb{C}}(2,4)$ Quadrupole Wave Matrix, & 2.5PN Peters–Mathews Flux)**:
For any `orb : PlanetaryOrbit`, orbital phase $\Phi_{\mathrm{orb}}$, perihelion advance $\Delta\varpi$,
inclination $\iota$, and positive physical parameters $G, m_1, m_2, c, R > 0$:
1. **Spin-2 $(+, \times)$ Double-Copy Polarization Bounds**:
   - Face-on ($\iota = 0$): $F_+(0) = 1$, $F_\times(0) = 1$, and $F_+(0)^2 + F_\times(0)^2 = 2$ (circular polarization),
   - Edge-on ($\iota = \pi / 2$): $F_+(\pi / 2) = 1 / 2$ and $F_\times(\pi / 2) = 0$ (purely linear $+$-polarization),
   - Universal bounds: $1 / 2 \le F_+(\iota) \le 1$,
2. **Dynamic $Gr_{\mathbb{C}}(2,4)$ Quadrupole Wave Matrix (`gr24QuadrupoleWaveMatrix`)**:
   Let $M_{\mathbb{C}}^{\mathrm{GW}} = \mathrm{orb}.\mathrm{gr24QuadrupoleWaveMatrix}\,\Phi_{\mathrm{orb}}\,\Delta\varpi$.
   - The uncrossed Plücker channel densities are adiabatic orbital invariants:
     $|w_A^{\mathbb{C}}(M_{\mathbb{C}}^{\mathrm{GW}})|^2 = r_{\max}/a$,
     $|w_B^{\mathbb{C}}(M_{\mathbb{C}}^{\mathrm{GW}})|^2 = r_{\min}/a$, and
     $|w_A^{\mathbb{C}}(M_{\mathbb{C}}^{\mathrm{GW}})|^2\,|w_B^{\mathbb{C}}(M_{\mathbb{C}}^{\mathrm{GW}})|^2 = 1 - e^2 = p/a$,
   - The crossing Plücker minor oscillates at the quadrupole GW carrier phase $2\Phi_{\mathrm{orb}} + \Delta\varpi$:
     $|\Delta_{02}^{\mathbb{C}}(M_{\mathbb{C}}^{\mathrm{GW}})\,\Delta_{13}^{\mathbb{C}}(M_{\mathbb{C}}^{\mathrm{GW}})|^2 = 2\bigl(1 + \sqrt{1 - e^2}\cos(2\Phi_{\mathrm{orb}} + \Delta\varpi)\bigr)$,
3. **Schwarzschild Factorization & $(h_+, h_\times)$ Quadrature Envelope**:
   With $r_{S,1} = 2 G m_1 / c^2$ and $r_{S,2} = 2 G m_2 / c^2$,
   $$h_0 = \frac{r_{S,1}\,r_{S,2}}{R\,a} > 0, \qquad
   \left(\frac{h_+}{h_0 F_+(\iota)}\right)^2 + \left(\frac{h_\times}{h_0 F_\times(\iota)}\right)^2 = 1 \quad (\text{when } F_\times(\iota) \neq 0),$$
4. **2.5PN Peters–Mathews Eccentricity Factor & $Gr_{\mathbb{C}}(2,4)$ Product Scaling**:
   $$1 \le P_{\mathrm{PM}}(e), \qquad 0 < f_{\mathrm{PM}}(e), \qquad
   f_{\mathrm{PM}}(e)^2 = \frac{P_{\mathrm{PM}}(e)^2}{\bigl(|w_A^{\mathbb{C}}(M_{\mathbb{C}}^{\mathrm{GW}})|^2\,|w_B^{\mathbb{C}}(M_{\mathbb{C}}^{\mathrm{GW}})|^2\bigr)^7} = \frac{P_{\mathrm{PM}}(e)^2}{(p/a)^7},$$
   and the 2.5PN radiated power is strictly positive ($0 < P_{\mathrm{GW}}$), so radiative
   back-reaction strictly decreases orbital mechanical energy ($-P_{\mathrm{GW}} < 0$),
5. **$N$-Body $p:q$ Mean-Motion Resonance Beat Locking**:
   $\omega_{\mathrm{res}}(p, q, \Omega_1, \Omega_2) = 0 \iff (p : \mathbb{R})\Omega_1 = (q : \mathbb{R})\Omega_2$. -/
@[blueprint "thm:signals-qed-gw-without-ddf-master"
  (title := "Master theorem for gravitational waves without DDF: spin-2 polarizations, Gr_C(2,4) quadrupole wave matrix, and 2.5PN Peters-Mathews flux")
  (statement := /-- For \texttt{orb : PlanetaryOrbit}, $\Phi_{\mathrm{orb}},\Delta\varpi,\iota\in\mathbb R$,
    and $G,m_1,m_2,c,R>0$:
    (1) $F_+(0)=1$, $F_\times(0)=1$, $F_+(\pi/2)=1/2$, $F_\times(\pi/2)=0$, and $1/2\le F_+(\iota)\le 1$;
    (2) for $M_{\mathbb C}^{\mathrm{GW}}=\mathrm{orb}.\mathrm{gr24QuadrupoleWaveMatrix}(\Phi_{\mathrm{orb}},\Delta\varpi)$,
    $|w_A^{\mathbb C}|^2|w_B^{\mathbb C}|^2 = 1-e^2 = p/a$ and
    $|\Delta_{02}^{\mathbb C}\Delta_{13}^{\mathbb C}|^2 = 2\bigl(1+\sqrt{1-e^2}\cos(2\Phi_{\mathrm{orb}}+\Delta\varpi)\bigr)$;
    (3) $h_0 = \frac{(2Gm_1/c^2)(2Gm_2/c^2)}{R a} > 0$;
    (4) $1\le P_{\mathrm{PM}}(e)$, $0<f_{\mathrm{PM}}(e)$,
    $f_{\mathrm{PM}}(e)^2 = \frac{P_{\mathrm{PM}}(e)^2}{(|w_A^{\mathbb C}|^2|w_B^{\mathbb C}|^2)^7}$, and $0 < P_{\mathrm{GW}}$;
    (5) $\omega_{\mathrm{res}}(p,q,\Omega_1,\Omega_2)=0 \iff p\Omega_1 = q\Omega_2$. -/)
  (proof := /-- Apply \texttt{gr24PrecessionMatrix\_orbital\_identities} at $2\Phi_{\mathrm{orb}}+\Delta\varpi$,
    use $\cos^2\theta+\sin^2\theta=1$ and $\sqrt{1-e^2}^2 = 1-e^2 > 0$, and close positivity
    and rational identities by \texttt{positivity} and \texttt{ring}. -/)]
theorem PlanetaryOrbit.qed_gravitational_wave_without_ddf_identities
    (orb : PlanetaryOrbit) (orbitalPhase deltaVarpi inclination G m1 m2 c R : ℝ)
    (hG : 0 < G) (hm1 : 0 < m1) (hm2 : 0 < m2) (hc : 0 < c) (hR : 0 < R)
    (p q : ℕ) (omega1 omega2 : ℝ) :
    let M_GW := orb.gr24QuadrupoleWaveMatrix orbitalPhase deltaVarpi
    let r_S1 := 2 * G * m1 / c ^ 2
    let r_S2 := 2 * G * m2 / c ^ 2
    gravitonPlusPolarizationFactor 0 = 1 ∧
      gravitonCrossPolarizationFactor 0 = 1 ∧
      gravitonPlusPolarizationFactor (Real.pi / 2) = 1 / 2 ∧
      gravitonCrossPolarizationFactor (Real.pi / 2) = 0 ∧
      1 / 2 ≤ gravitonPlusPolarizationFactor inclination ∧
      gravitonPlusPolarizationFactor inclination ≤ 1 ∧
      Complex.normSq (complexPluckerSinkAmplitudeA M_GW) *
        Complex.normSq (complexPluckerSinkAmplitudeB M_GW) =
        orb.semiLatusRectum / orb.semiMajorAxis ∧
      Complex.normSq (complexTwoRowMinor M_GW 0 2 * complexTwoRowMinor M_GW 1 3) =
        2 * (1 + Real.sqrt (1 - orb.eccentricity ^ 2) *
          Real.cos (2 * orbitalPhase + deltaVarpi)) ∧
      0 < orb.quadrupoleStrainAmplitudePM G m1 m2 c R ∧
      orb.quadrupoleStrainAmplitudePM G m1 m2 c R =
        (r_S1 * r_S2) / (R * orb.semiMajorAxis) ∧
      1 ≤ orb.petersMathewsPolynomial ∧
      0 < orb.petersMathewsFactor ∧
      orb.petersMathewsFactor ^ 2 =
        orb.petersMathewsPolynomial ^ 2 /
          (Complex.normSq (complexPluckerSinkAmplitudeA M_GW) *
            Complex.normSq (complexPluckerSinkAmplitudeB M_GW)) ^ 7 ∧
      0 < orb.petersMathewsLuminosityPM G m1 m2 c ∧
      (orbitalResonanceQuadrupoleBeat p q omega1 omega2 = 0 ↔
        (p : ℝ) * omega1 = (q : ℝ) * omega2) := by
  intro M_GW r_S1 r_S2
  have ha_pos := orb.semiMajorAxis_pos
  have ha_ne : orb.semiMajorAxis ≠ 0 := ne_of_gt ha_pos
  have h1e2_pos : 0 < 1 - orb.eccentricity ^ 2 := (orb.radii_identities).1
  have h_sqrt_pos : 0 < Real.sqrt (1 - orb.eccentricity ^ 2) := Real.sqrt_pos.mpr h1e2_pos
  have h_orb := orb.gr24PrecessionMatrix_orbital_identities (2 * orbitalPhase + deltaVarpi)
  have h_fp0 : gravitonPlusPolarizationFactor 0 = 1 := by
    unfold gravitonPlusPolarizationFactor
    rw [Real.cos_zero]
    norm_num
  have h_fx0 : gravitonCrossPolarizationFactor 0 = 1 := by
    unfold gravitonCrossPolarizationFactor
    exact Real.cos_zero
  have h_fppi2 : gravitonPlusPolarizationFactor (Real.pi / 2) = 1 / 2 := by
    unfold gravitonPlusPolarizationFactor
    rw [Real.cos_pi_div_two]
    norm_num
  have h_fxpi2 : gravitonCrossPolarizationFactor (Real.pi / 2) = 0 := by
    unfold gravitonCrossPolarizationFactor
    exact Real.cos_pi_div_two
  have h_fp_lo : 1 / 2 ≤ gravitonPlusPolarizationFactor inclination := by
    unfold gravitonPlusPolarizationFactor
    have h_sq : 0 ≤ (Real.cos inclination) ^ 2 := sq_nonneg _
    linarith
  have h_fp_hi : gravitonPlusPolarizationFactor inclination ≤ 1 := by
    unfold gravitonPlusPolarizationFactor
    have h_sq : (Real.cos inclination) ^ 2 ≤ 1 := Real.cos_sq_le_one inclination
    linarith
  have h_h0_pos : 0 < orb.quadrupoleStrainAmplitudePM G m1 m2 c R := by
    unfold PlanetaryOrbit.quadrupoleStrainAmplitudePM
    positivity
  have h_h0_rs :
      orb.quadrupoleStrainAmplitudePM G m1 m2 c R =
        (r_S1 * r_S2) / (R * orb.semiMajorAxis) := by
    unfold PlanetaryOrbit.quadrupoleStrainAmplitudePM
    dsimp [r_S1, r_S2]
    have hc2_ne : c ^ 2 ≠ 0 := pow_ne_zero 2 (ne_of_gt hc)
    have hR_ne : R ≠ 0 := ne_of_gt hR
    field_simp [hc2_ne, hR_ne, ha_ne]
    ring
  have h_pm_poly : 1 ≤ orb.petersMathewsPolynomial := by
    unfold PlanetaryOrbit.petersMathewsPolynomial
    have he2 : 0 ≤ orb.eccentricity ^ 2 := sq_nonneg _
    have he4 : 0 ≤ orb.eccentricity ^ 4 := by positivity
    linarith
  have h_pm_pos : 0 < orb.petersMathewsFactor := by
    unfold PlanetaryOrbit.petersMathewsFactor
    have h_poly_pos : 0 < orb.petersMathewsPolynomial := by linarith
    positivity
  have h_slr_div : orb.semiLatusRectum / orb.semiMajorAxis = 1 - orb.eccentricity ^ 2 := by
    unfold PlanetaryOrbit.semiLatusRectum
    exact mul_div_cancel_left₀ (1 - orb.eccentricity ^ 2) ha_ne
  have h_prod_eq :
      Complex.normSq (complexPluckerSinkAmplitudeA M_GW) *
        Complex.normSq (complexPluckerSinkAmplitudeB M_GW) =
        1 - orb.eccentricity ^ 2 := by
    dsimp [M_GW, PlanetaryOrbit.gr24QuadrupoleWaveMatrix]
    rw [h_orb.2.2.2.1, h_slr_div]
  have h_pm_sq :
      orb.petersMathewsFactor ^ 2 =
        orb.petersMathewsPolynomial ^ 2 /
          (Complex.normSq (complexPluckerSinkAmplitudeA M_GW) *
            Complex.normSq (complexPluckerSinkAmplitudeB M_GW)) ^ 7 := by
    rw [h_prod_eq]
    unfold PlanetaryOrbit.petersMathewsFactor
    rw [div_pow]
    congr 1
    calc
      ((Real.sqrt (1 - orb.eccentricity ^ 2)) ^ 7) ^ 2 =
          ((Real.sqrt (1 - orb.eccentricity ^ 2)) ^ 2) ^ 7 := by ring
      _ = (1 - orb.eccentricity ^ 2) ^ 7 := by
          rw [Real.sq_sqrt (le_of_lt h1e2_pos)]
  have h_lum_pos : 0 < orb.petersMathewsLuminosityPM G m1 m2 c := by
    unfold PlanetaryOrbit.petersMathewsLuminosityPM
    positivity
  have h_res :
      orbitalResonanceQuadrupoleBeat p q omega1 omega2 = 0 ↔
        (p : ℝ) * omega1 = (q : ℝ) * omega2 := by
    unfold orbitalResonanceQuadrupoleBeat
    constructor
    · intro h
      linarith
    · intro h
      linarith
  exact ⟨h_fp0, h_fx0, h_fppi2, h_fxpi2, h_fp_lo, h_fp_hi,
    h_orb.2.2.2.1, h_orb.2.2.2.2, h_h0_pos, h_h0_rs,
    h_pm_poly, h_pm_pos, h_pm_sq, h_lum_pos, h_res⟩

/-! ## Multi-Model Gravity Comparison: Relative Predictive Error of Newtonian, Nordström Scalar, Einstein GR, Spin-1 Vector, Witten Conformal Twistor String, Cachazo–Skinner Infinity Twistor, Fedi (2016) SQG, Fedi (2017) Dark Superfluid, Partanen–Tulkki (2025) QFT, Fedi (2026) DDF, and Turner (2026) $Gr_{\mathbb{C}}(2,4)$ Models

| # | Gravity Model & Geometric / Field Mechanism | Anomalous 2-Body Perihelion Precession $\Delta\varpi_{\mathrm{model}}$ per Orbit | Mercury Rate $\dot{\varpi}_{\mathrm{rel}}$ ($''/\text{cy}$) | Relative Error $\varepsilon_{\mathrm{rel}}(\Delta\varpi, \Delta\varpi_{\mathrm{GR}})$ |
|---|---|---|---|---|
| **1** | **Newtonian $1/r$ Gravity** (`newtonianAnomalousPrecessionRad`) | $0$ | $0.00''$ | **$1$ ($100\%$)** |
| **2** | **Nordström Relativistic Scalar Gravity (1913)** (`nordstromScalarPrecessionRad`) | $-\frac{1}{6}\Delta\varpi_{\mathrm{GR}} = -\frac{\pi G_\phi M}{c^2 a(1-e^2)}$ (retrograde) | $-7.16''$ | **$\frac{7}{6} \approx 116.67\%$** |
| **3** | **Einstein's General Relativity (1915 / 1916)** (`einsteinGeneralRelativityPrecessionRad` at $\beta_{\mathrm{PPN}}=1, \gamma_{\mathrm{PPN}}=1$) | $\Delta\varpi_{\mathrm{EGR}}(1,1) = \frac{6\pi G_\phi M}{c^2 a(1-e^2)} = \frac{3\pi r_S}{p}$ | **$42.98''$** | **$0$ ($0\%$)** |
| **4** | **Special-Relativistic Spin-1 Vector / Un-Doubled Coulomb-QED** (`spinOneVectorPrecessionRad`) | $+\frac{1}{6}\Delta\varpi_{\mathrm{GR}} = +\frac{\pi G_\phi M}{c^2 a(1-e^2)}$ | $+7.16''$ | **$\frac{5}{6} \approx 83.33\%$** |
| **5a** | **Witten (2004) Twistor String (Pure Scale-Free Conformal Limit)** (`wittenConformalTwistorPrecessionRad` at $\beta_{\mathrm{scale}}=0, \gamma_{\mathrm{conf}}=0$) | $0$ (4th-order $1/q^4$ Weyl $C_{\mu\nu\rho\sigma}^2$) | $0.00''$ | **$1$ ($100\%$)** |
| **5b** | **Witten (2004) Twistor-String Conformal Gravity w/ Biharmonic Linear Potential** (`wittenConformalTwistorPrecessionRad` at $\beta_{\mathrm{scale}}=1, \gamma_{\mathrm{conf}}>0$) | $\Delta\varpi_{\mathrm{GR}} - \pi\gamma_{\mathrm{conf}} a^2\sqrt{1-e^2}$ | $42.98'' - \dot{\varpi}_\gamma(a^2)$ | **$\frac{\pi\gamma_{\mathrm{conf}}a^2\sqrt{1-e^2}}{\Delta\varpi_{\mathrm{GR}}} > 0$** |
| **6** | **Dissipative Viscous Stokes-Drag Fluid** (`ddf_conservative_action_vs_stokes_drag_critique`: $F_{\mathrm{drag}} > 0$) | Secular semi-major axis decay $\frac{da}{dt} < 0$ | Inspiral | **Non-conservative ($\frac{dE}{dt} = -F_{\mathrm{drag}}v < 0$)** |
| **7a** | **Cachazo–Skinner (2012) Infinity-Twistor w/ Cosmological Constant ($\Lambda_{\mathrm{cc}} > 0$)** (`cachazoSkinnerTwistorPrecessionRad` at $\pi_I=1, \Lambda_{\mathrm{cc}}>0$) | $\Delta\varpi_{\mathrm{GR}} + \frac{\pi c^2\Lambda_{\mathrm{cc}} a^3\sqrt{1-e^2}}{G_\phi M}$ | $42.98'' + \dot{\varpi}_\Lambda(a^3)$ | **$\frac{\pi c^2\Lambda_{\mathrm{cc}}a^3\sqrt{1-e^2}}{G_\phi M\Delta\varpi_{\mathrm{GR}}} > 0$** |
| **7b** | **Cachazo–Skinner (2012) Infinity-Twistor Rational Curves ($\Lambda_{\mathrm{cc}} = 0$)** (`cachazoSkinnerTwistorPrecessionRad` at $\pi_I=1, \Lambda_{\mathrm{cc}}=0$) | $\Delta\varpi_{\mathrm{CS}}(1,\gamma_{\mathrm{conf}},0) = \Delta\varpi_{\mathrm{GR}}$ ($\forall\,\gamma_{\mathrm{conf}}$) | **$42.98''$** | **$0$ ($0\%$)** |
| **8a** | **Fedi (2016) "Superfluid Quantum Gravity" (Pure Inviscid Bernoulli Sink Flow)** (`fediSQG2016PrecessionRad` at $\kappa_{\mathrm{rel}}=0, \delta_{\mathrm{GPE}}=0$) | $0$ (pure $-\nabla\Phi_\phi = -G_\phi M / r^2$) | $0.00''$ | **$1$ ($100\%$)** |
| **8b** | **Fedi (2016) "Superfluid Quantum Gravity" (Relativistic Acoustic Pressure + GPE Core)** (`fediSQG2016PrecessionRad` at $\kappa_{\mathrm{rel}}=1, \delta_{\mathrm{GPE}}\ge 0$) | $\Delta\varpi_{\mathrm{GR}} + \delta_{\mathrm{GPE}}$ ($\Delta\varpi_{\mathrm{GR}}$ at $\delta_{\mathrm{GPE}}=0$) | **$42.98''$** | **$0$ ($0\%$ at $\delta_{\mathrm{GPE}}=0$)**; $\frac{\delta_{\mathrm{GPE}}}{\Delta\varpi_{\mathrm{GR}}} > 0$ |
| **9a** | **Fedi (2017) "Hydrodynamics of the Dark Superfluid" (Dilatant $\gamma - 1$ w/ Pioneer Drag $\eta_{\mathrm{drag}} > 0$)** (`fediDarkSuperfluid2017PrecessionRad` at $\lambda_\gamma=1, \eta_{\mathrm{drag}}>0$) | $\Delta\varpi_{\mathrm{GR}} - 2\pi\eta_{\mathrm{drag}} a\sqrt{1-e^2}$ | $42.98'' - \dot{\varpi}_{\mathrm{drag}}$ | **$\frac{2\pi\eta_{\mathrm{drag}}a\sqrt{1-e^2}}{\Delta\varpi_{\mathrm{GR}}} > 0$** |
| **9b** | **Fedi (2017) "Hydrodynamics of the Dark Superfluid" (Conservative Dilatant $\gamma - 1$, $\eta_{\mathrm{drag}} = 0$)** (`fediDarkSuperfluid2017PrecessionRad` at $\lambda_\gamma=1, \eta_{\mathrm{drag}}=0$) | $\Delta\varpi_{\mathrm{dark,2017}}(1,0) = \Delta\varpi_{\mathrm{GR}}$ | **$42.98''$** | **$0$ ($0\%$)** |
| **10** | **Partanen & Tulkki (2025) Four-$\mathrm{U}(1)$ Gauge Gravity + 1-Loop Post-Minkowskian QFT (Without $Gr_{\mathbb{C}}(2,4)$)** (`partanenTulkki2025PrecessionRad`) | $\Delta\varpi_{\mathrm{PT,2025}} = \frac{6\pi G_\phi M}{c^2 a(1-e^2)}$ | **$42.98''$** | **$0$ ($0\%$)** |
| **11** | **Fedi (2026) Conservative Dilatant Dark Fluid (DDF, Without $Gr_{\mathbb{C}}(2,4)$)** (`fediDDF2026PrecessionRad`) | $\Delta\varpi_{\mathrm{DDF,2026}} = \frac{6\pi G_\phi M \varrho_{\max}^\varphi j_{\min}^\varphi}{a(1-e^2)} = \frac{3\pi r_H}{p}$ | **$42.98''$** | **$0$ ($0\%$)** |
| **12** | **Turner (2026) Flat-Space $Gr_{\mathbb{C}}(2,4)$ BCJ Double Copy + 1-Loop Post-Minkowskian QFT (Without DDF)** (`turnerGr24QEDPrecessionRad`) | $\frac{6\pi G_\phi M}{c^2 a(\|w_A^{\mathbb{C}}(M_{\mathbb{C}}^{\mathrm{orb}})\|^2\|w_B^{\mathbb{C}}(M_{\mathbb{C}}^{\mathrm{orb}})\|^2)} = \Delta\varpi_{\mathrm{GR}}$ | **$42.98''$** | **$0$ ($0\%$)** |
| **13** | **Turner (2026) Unified $Gr_{\mathbb{C}}(2,4)$ + Conservative Dilatant Dark Fluid (DDF) + 3D `NormedTensorGaussianSplat3D`** (`turnerGr24DDFPrecessionRad`) | $\frac{6\pi G_\phi M \varrho_{\max}^\varphi j_{\min}^\varphi}{a(\|w_A^{\mathbb{C}}(M_{\mathbb{C}}^{\mathrm{orb}})\|^2\|w_B^{\mathbb{C}}(M_{\mathbb{C}}^{\mathrm{orb}})\|^2)} = \frac{3\pi r_H}{a(\|w_A^{\mathbb{C}}\|^2\|w_B^{\mathbb{C}}\|^2)}$ | **$42.98''$** | **$0$ ($0\%$)** |
-/

/-- **Newtonian 2-Body Anomalous Perihelion Precession ($\Delta\varpi_{\mathrm{Newton}} = 0$)**:
In pure Newtonian $1/r$ gravity (tree-level $O(G)$ without 1-loop relativistic corrections),
bound 2-body Keplerian ellipses close exactly with zero anomalous perihelion advance. -/
@[blueprint "def:signals-qed-newtonian-anomalous-precession"
  (title := "Newtonian 2-body anomalous perihelion precession Δϖ_Newton = 0")
  (statement := /-- For any \texttt{orb : PlanetaryOrbit}, define $\Delta\varpi_{\mathrm{Newton}} = 0$. -/)]
def PlanetaryOrbit.newtonianAnomalousPrecessionRad (_orb : PlanetaryOrbit) : ℝ := 0

/-- **Nordström Relativistic Scalar (Spin-0) Gravity Precession ($\Delta\varpi_{\mathrm{scalar}} = -\frac{1}{6}\Delta\varpi_{\mathrm{PM}}$)**:
A relativistic spin-0 scalar gravitational field coupled to the stress-energy trace $T^\mu_\mu$
(Nordström 1913) predicts a **retrograde** perihelion advance equal to $-1/6$ of the
Einstein / 1-loop spin-2 value. -/
@[blueprint "def:signals-qed-nordstrom-scalar-precession"
  (title := "Nordström spin-0 scalar gravity perihelion precession Δϖ_scalar = -(1/6) Δϖ_PM")
  (statement := /-- For \texttt{orb : PlanetaryOrbit} and $(G,M,c)$, define
    $\Delta\varpi_{\mathrm{scalar}} = -\frac{1}{6}\Delta\varpi_{\mathrm{PM}}(G,M,c)$. -/)]
noncomputable def PlanetaryOrbit.nordstromScalarPrecessionRad
    (orb : PlanetaryOrbit) (G sourceMass c : ℝ) : ℝ :=
  - (1 / 6 : ℝ) * orb.perihelionPrecessionRadPM G sourceMass c

/-- **Einstein's General Relativity (1915 / 1916) Curved-Spacetime Geodesic & PPN Perihelion Precession**:
In Einstein's General Theory of Relativity (Einstein 1915, *Sitzungsber. Preuß. Akad. Wiss.*,
831–839; Einstein 1916, *Ann. Phys.* 354, 769–822), gravitation is the pseudo-Riemannian
curvature $G_{\mu\nu} = R_{\mu\nu} - \frac{1}{2}R g_{\mu\nu} = \frac{8\pi G}{c^4} T_{\mu\nu}$
of a 4D Lorentzian manifold. In the Eddington–Robertson Parameterized Post-Newtonian (PPN)
expansion of a static spherically symmetric metric with nonlinearity parameter $\beta_{\mathrm{PPN}}$
and spatial-curvature parameter $\gamma_{\mathrm{PPN}}$, the secular perihelion advance per
revolution is
$$\Delta\varpi_{\mathrm{EGR}}(\beta_{\mathrm{PPN}}, \gamma_{\mathrm{PPN}})
  = \frac{2 - \beta_{\mathrm{PPN}} + 2\gamma_{\mathrm{PPN}}}{3}\,\Delta\varpi_{\mathrm{PM}}(G, M, c).$$
For Einstein's General Relativity ($\beta_{\mathrm{PPN}} = 1, \gamma_{\mathrm{PPN}} = 1$),
the PPN prefactor equals $\frac{2 - 1 + 2}{3} = 1$, recovering the exact Schwarzschild
geodesic precession $\Delta\varpi_{\mathrm{EGR}}(1, 1) = \frac{6\pi G M}{c^2 a(1 - e^2)}$
($42.98''/\text{cy}$ for Mercury, $\varepsilon_{\mathrm{rel}} = 0$). -/
@[blueprint "def:signals-qed-einstein-gr-precession"
  (title := "Einstein's General Relativity (1915/1916) curved-spacetime PPN perihelion precession")
  (statement := /-- For \texttt{orb : PlanetaryOrbit}, $(G,M,c)$, and PPN parameters
    $(\beta_{\mathrm{PPN}},\gamma_{\mathrm{PPN}})$, define
    $\Delta\varpi_{\mathrm{EGR}}(\beta_{\mathrm{PPN}},\gamma_{\mathrm{PPN}})
    = \frac{2 - \beta_{\mathrm{PPN}} + 2\gamma_{\mathrm{PPN}}}{3}\,\Delta\varpi_{\mathrm{PM}}(G,M,c)$. -/)]
noncomputable def PlanetaryOrbit.einsteinGeneralRelativityPrecessionRad
    (orb : PlanetaryOrbit) (G sourceMass c betaPPN gammaPPN : ℝ) : ℝ :=
  ((2 - betaPPN + 2 * gammaPPN) / 3) * orb.perihelionPrecessionRadPM G sourceMass c

/-- **Special-Relativistic Spin-1 Vector (Un-Doubled Coulomb/QED) Precession ($\Delta\varpi_{\mathrm{vector}} = +\frac{1}{6}\Delta\varpi_{\mathrm{PM}}$)**:
A relativistic test mass in a spin-1 vector $1/r$ potential (without the BCJ $\text{Gravity} = \text{Gauge}^2$
spin-2 double copy and 1-loop graviton self-interaction) yields Sommerfeld's $+1/6$
perihelion advance, missing $5/6$ of the observed relativistic precession. -/
@[blueprint "def:signals-qed-spin-one-vector-precession"
  (title := "Spin-1 vector (un-doubled Coulomb/QED) perihelion precession Δϖ_vector = (1/6) Δϖ_PM")
  (statement := /-- For \texttt{orb : PlanetaryOrbit} and $(G,M,c)$, define
    $\Delta\varpi_{\mathrm{vector}} = \frac{1}{6}\Delta\varpi_{\mathrm{PM}}(G,M,c)$. -/)]
noncomputable def PlanetaryOrbit.spinOneVectorPrecessionRad
    (orb : PlanetaryOrbit) (G sourceMass c : ℝ) : ℝ :=
  (1 / 6 : ℝ) * orb.perihelionPrecessionRadPM G sourceMass c

/-- **Witten's Original Twistor String Theory ($\mathcal{N}=4$ Conformal Supergravity / Weyl $C_{\mu\nu\rho\sigma}^2$) Precession**:
Because projective supertwistor space $\mathbb{CP}^{3|4}$ is manifestly $\mathrm{SU}(2,2|4)$
superconformally invariant, the closed-string gravitational sector of Witten's original
twistor string theory (Witten 2004; Berkovits and Witten 2004) yields 4-derivative Weyl
conformal supergravity ($S_{\mathrm{Weyl}} \propto \int d^4x\sqrt{-g}\,C_{\mu\nu\rho\sigma}^2$,
biharmonic static field equation $\nabla^4 \Phi = 0$, and $1/q^4$ ghost propagator) rather
than 2-derivative Einstein General Relativity:
- In the pure scale-free conformal regime ($\beta_{\mathrm{scale}} = 0, \gamma_{\mathrm{conf}} = 0$),
  there is no intrinsic dimensionful Newton constant $G$, so the $1/p$ Einstein precession vanishes.
- Even when the $1/r$ coefficient is matched by hand ($\beta_{\mathrm{scale}} = 1$), the biharmonic
  Mannheim–Kazanas linear conformal potential $+\frac{1}{2}\gamma_{\mathrm{conf}} c^2 r$ induces an
  anomalous secular shift $-\pi\,\gamma_{\mathrm{conf}}\,a^2\sqrt{1 - e^2}$ growing as $a^2$. -/
@[blueprint "def:signals-qed-witten-conformal-twistor-precession"
  (title := "Witten 2004 twistor-string conformal supergravity (Weyl C² biharmonic) perihelion precession")
  (statement := /-- For \texttt{orb : PlanetaryOrbit}, $(G,M,c)$, dimensionless $1/r$ scale
    matching factor $\beta_{\mathrm{scale}}$, and linear conformal potential parameter
    $\gamma_{\mathrm{conf}}$, define
    $\Delta\varpi_{\mathrm{Weyl}}(\beta_{\mathrm{scale}},\gamma_{\mathrm{conf}})
    = \beta_{\mathrm{scale}}\,\Delta\varpi_{\mathrm{PM}}(G,M,c)
    - \pi\,\gamma_{\mathrm{conf}}\,a^2\sqrt{1-e^2}$. -/)]
noncomputable def PlanetaryOrbit.wittenConformalTwistorPrecessionRad
    (orb : PlanetaryOrbit) (G sourceMass c betaScale gammaConf : ℝ) : ℝ :=
  betaScale * orb.perihelionPrecessionRadPM G sourceMass c -
    Real.pi * gammaConf * orb.semiMajorAxis ^ 2 * Real.sqrt (1 - orb.eccentricity ^ 2)

/-- **Fedi (2016) Superfluid Quantum Gravity (SQG / Superfluid Quantum Space, HAL `hal-01248015v3`/`v4`) Precession**:
In Marco Fedi's 2016 *Superfluid Quantum Gravity* (SQG / Superfluid Quantum Space, SQS),
fermionic matter acts as a continuous hydrodynamic sink absorbing quanta from a Bose–Einstein
condensate vacuum, generating a radial Euler/Bernoulli inflow $v_r(r) = -\sqrt{2GM/r}$
and Newtonian pressure potential $\Phi_{\mathrm{SQS}}(r) = -\frac{1}{2}v_r(r)^2 = -\frac{GM}{r}$,
augmented by a Gross–Pitaevskii / Madelung Bohm quantum-potential core correction $\delta_{\mathrm{GPE}}$:
$$\Delta\varpi_{\mathrm{SQG,2016}}(\kappa_{\mathrm{rel}}, \delta_{\mathrm{GPE}})
  = \kappa_{\mathrm{rel}}\,\Delta\varpi_{\mathrm{PM}}(G, M, c) + \delta_{\mathrm{GPE}}.$$
- In the pure inviscid $1/r$ Bernoulli sink-flow regime without relativistic dilatant/acoustic
  curvature ($\kappa_{\mathrm{rel}} = 0, \delta_{\mathrm{GPE}} = 0$), the central force is strictly
  inverse-square ($-GM/r^2$), so $\Delta\varpi_{\mathrm{SQG,2016}}(0, 0) = 0$ ($\varepsilon_{\mathrm{rel}} = 1$,
  $100\%$ error on anomalous precession).
- With relativistic clock/pressure coupling ($\kappa_{\mathrm{rel}} = 1$) and non-zero GPE core
  residual $\delta_{\mathrm{GPE}} > 0$, $\varepsilon_{\mathrm{rel}} = \delta_{\mathrm{GPE}} / \Delta\varpi_{\mathrm{GR}} > 0$
  (vanishing at planetary scales $\delta_{\mathrm{GPE}} = 0$ where healing length $\xi \ll a$). -/
@[blueprint "def:signals-qed-fedi-sqg-2016-precession"
  (title := "Fedi (2016) Superfluid Quantum Gravity (SQG / SQS sink-flow + GPE) perihelion precession")
  (statement := /-- For \texttt{orb : PlanetaryOrbit}, $(G,M,c)$, relativistic pressure-coupling
    indicator $\kappa_{\mathrm{rel}}$, and GPE quantum-pressure core residual $\delta_{\mathrm{GPE}}$,
    define $\Delta\varpi_{\mathrm{SQG,2016}}(\kappa_{\mathrm{rel}},\delta_{\mathrm{GPE}})
    = \kappa_{\mathrm{rel}}\,\Delta\varpi_{\mathrm{PM}}(G,M,c) + \delta_{\mathrm{GPE}}$. -/)]
noncomputable def PlanetaryOrbit.fediSQG2016PrecessionRad
    (orb : PlanetaryOrbit) (G sourceMass c kappaRel deltaGPE : ℝ) : ℝ :=
  kappaRel * orb.perihelionPrecessionRadPM G sourceMass c + deltaGPE

/-- **Fedi (2017) "Hydrodynamics of the Dark Superfluid" (Dilatant Lorentz Viscosity $\gamma - 1$ & Mercury Perihelion) Precession**:
In Marco Fedi's 2017 *Hydrodynamics of the dark superfluid* (and subsequent 2018/2019 *Can. J. Phys.*
formulation), the dark superfluid vacuum is modeled as a non-Newtonian shear-thickening (dilatant)
quantum fluid whose apparent viscosity scales with the relativistic Lorentz factor
$\eta_{\mathrm{eff}}(v) \propto \gamma(v) - 1 = (1 - v^2/c^2)^{-1/2} - 1 \simeq \frac{1}{2}v^2/c^2$.
Substituting $\gamma - 1$ for viscosity in the solar dark-superfluid shear field with Lorentz
dilatancy coupling $\lambda_\gamma$ and baseline dissipative Stokes/Pioneer-anomaly drag parameter
$\eta_{\mathrm{drag}} \ge 0$ yields
$$\Delta\varpi_{\mathrm{dark,2017}}(\lambda_\gamma, \eta_{\mathrm{drag}})
  = \lambda_\gamma\,\Delta\varpi_{\mathrm{PM}}(G, M, c)
  - 2\pi\,\eta_{\mathrm{drag}}\,a\sqrt{1 - e^2}.$$
- In the frictionless / conservative dilatant Lorentz-factor regime ($\lambda_\gamma = 1, \eta_{\mathrm{drag}} = 0$),
  back-calculating Mercury's orbital shear reproduces the exact 1PN value
  $\Delta\varpi_{\mathrm{dark,2017}}(1, 0) = \frac{6\pi G M}{c^2 a(1 - e^2)}$ ($42.98''/\text{cy}$,
  $\varepsilon_{\mathrm{rel}} = 0$).
- When a non-zero baseline Stokes drag $\eta_{\mathrm{drag}} > 0$ is simultaneously invoked to fit
  the Pioneer 10/11 deceleration (double-counting the Turyshev et al. 2012 anisotropic RTG thermal
  recoil), it introduces a dissipative residual error
  $\varepsilon_{\mathrm{rel}} = \frac{2\pi\,\eta_{\mathrm{drag}}\,a\sqrt{1 - e^2}}{\Delta\varpi_{\mathrm{GR}}} > 0$. -/
@[blueprint "def:signals-qed-fedi-dark-superfluid-2017-precession"
  (title := "Fedi (2017) Hydrodynamics of the dark superfluid (dilatant γ - 1 Mercury perihelion) precession")
  (statement := /-- For \texttt{orb : PlanetaryOrbit}, $(G,M,c)$, Lorentz dilatant factor
    coupling $\lambda_\gamma$, and baseline Stokes/Pioneer drag parameter $\eta_{\mathrm{drag}}$,
    define $\Delta\varpi_{\mathrm{dark,2017}}(\lambda_\gamma,\eta_{\mathrm{drag}})
    = \lambda_\gamma\,\Delta\varpi_{\mathrm{PM}}(G,M,c) - 2\pi\,\eta_{\mathrm{drag}}\,a\sqrt{1-e^2}$. -/)]
noncomputable def PlanetaryOrbit.fediDarkSuperfluid2017PrecessionRad
    (orb : PlanetaryOrbit) (G sourceMass c lambdaGamma etaDrag : ℝ) : ℝ :=
  lambdaGamma * orb.perihelionPrecessionRadPM G sourceMass c -
    2 * Real.pi * etaDrag * orb.semiMajorAxis * Real.sqrt (1 - orb.eccentricity ^ 2)

/-- **Cachazo–Skinner (2012) Infinity-Twistor Projection & Reduced Hodges Worldsheet Double Copy on $Gr_{\mathbb{C}}(2,4)$**:
In Cachazo and Skinner's rational-curve formulation of $\mathcal{N}=8$ supergravity on
projective supertwistor space $\mathbb{CP}^{3|8}$ (Cachazo and Skinner 2013, *PRL* 110, 161301,
`arXiv:1207.0741`), $\mathrm{SU}(2,2|8)$ conformal invariance is explicitly broken by the
antisymmetric **infinity twistor** $I_{AB}$ (satisfying $I_{AB} I^{BC} = \Lambda_{\mathrm{cc}}\,\delta_A^C$).
In the flat-space limit ($\Lambda_{\mathrm{cc}} = 0$), $I_{AB}$ has rank 2 and projects each
4-component homogeneous twistor $Z_j^A = (\lambda_j^\alpha, \mu_{j\dot{\alpha}})^T \in \mathbb{C}^4$
onto its 2-component spinor rows $\lambda_j^\alpha = (M_{\mathbb{C}})_{0,j}, (M_{\mathbb{C}})_{1,j}$,
so the infinity-twistor skew bracket $\langle i\,j\rangle_I = I_{AB} Z_i^A Z_j^B$ is literally the
$2\times 2$ Plücker minor $\Delta_{ij}^{\mathbb{C}}(M_{\mathbb{C}})$ on $Gr_{\mathbb{C}}(2,4)$!
Rather than Witten's single-trace conformal supergravity vertex operators, Cachazo and Skinner
weight the worldsheet localization map by the product of **reduced Hodges determinants**
$\det'(\Phi)\,\det'(\tilde{\Phi})$. At 4 points, the infinity-twistor Hodges double-copy
numerator kernel is the crossing square $\bigl(\Delta_{02}^{\mathbb{C}}\Delta_{13}^{\mathbb{C}}\bigr)^2$. -/
@[blueprint "def:signals-qed-cachazo-skinner-hodges-kernel"
  (title := "Cachazo-Skinner (2012) infinity-twistor 4-point reduced Hodges double-copy kernel on Gr_C(2,4)")
  (statement := /-- For $M_{\mathbb C}\in\mathbb C^{2\times 4}$, define the infinity-twistor
    projected 4-point Hodges double-copy numerator kernel
    $\mathcal{K}_{\mathrm{CS}}(M_{\mathbb C}) = \bigl(\Delta_{02}^{\mathbb C}(M_{\mathbb C})\,\Delta_{13}^{\mathbb C}(M_{\mathbb C})\bigr)^2$. -/)]
def cachazoSkinnerHodges4PtKernel (M_C : Matrix (Fin 2) (Fin 4) ℂ) : ℂ :=
  (complexTwoRowMinor M_C 0 2 * complexTwoRowMinor M_C 1 3) ^ 2

/-- **Equivalence of the Cachazo–Skinner (2012) Infinity-Twistor Hodges Kernel and the $Gr_{\mathbb{C}}(2,4)$ BCJ Double Copy**:
For any $M_{\mathbb{C}} \in \mathbb{C}^{2\times 4}$, the Cachazo–Skinner infinity-twistor
4-point Hodges double-copy kernel $\mathcal{K}_{\mathrm{CS}}(M_{\mathbb{C}})$ equals the
BCJ double-copy square $n_t^2 = (w_A^{\mathbb{C}} + w_B^{\mathbb{C}})^2
= (w_A^{\mathbb{C}})^2 + 2 w_A^{\mathbb{C}} w_B^{\mathbb{C}} + (w_B^{\mathbb{C}})^2$
of the uncrossed Plücker sink channels on $Gr_{\mathbb{C}}(2,4)$. -/
@[blueprint "thm:signals-qed-cachazo-skinner-hodges-eq-bcj"
  (title := "Cachazo-Skinner (2012) infinity-twistor Hodges kernel equals the Gr_C(2,4) BCJ double-copy square")
  (statement := /-- For any $M_{\mathbb C}\in\mathbb C^{2\times 4}$,
    $\mathcal{K}_{\mathrm{CS}}(M_{\mathbb C}) = \bigl(w_A^{\mathbb C}(M_{\mathbb C}) + w_B^{\mathbb C}(M_{\mathbb C})\bigr)^2
    = w_A^{\mathbb C}(M_{\mathbb C})^2 + 2\,w_A^{\mathbb C}(M_{\mathbb C})\,w_B^{\mathbb C}(M_{\mathbb C}) + w_B^{\mathbb C}(M_{\mathbb C})^2$. -/)
  (proof := /-- Apply \texttt{bcj\_plucker\_jacobi\_and\_double\_copy} and close by ring algebra. -/)]
theorem cachazoSkinnerHodges4PtKernel_eq_bcj_double_copy (M_C : Matrix (Fin 2) (Fin 4) ℂ) :
    cachazoSkinnerHodges4PtKernel M_C =
      (complexPluckerSinkAmplitudeA M_C + complexPluckerSinkAmplitudeB M_C) ^ 2 ∧
    cachazoSkinnerHodges4PtKernel M_C =
      complexPluckerSinkAmplitudeA M_C ^ 2 +
        2 * complexPluckerSinkAmplitudeA M_C * complexPluckerSinkAmplitudeB M_C +
        complexPluckerSinkAmplitudeB M_C ^ 2 := by
  have h_bcj := (bcj_plucker_jacobi_and_double_copy M_C).2
  dsimp [cachazoSkinnerHodges4PtKernel, complexPluckerSinkAmplitudeA,
    complexPluckerSinkAmplitudeB] at h_bcj ⊢
  have h_neg_sq :
      (complexTwoRowMinor M_C 0 2 * complexTwoRowMinor M_C 1 3) ^ 2 =
        (- (complexTwoRowMinor M_C 0 2 * complexTwoRowMinor M_C 1 3)) ^ 2 := by ring
  rw [h_neg_sq, h_bcj]
  constructor
  · ring
  · ring

/-- **Cachazo–Skinner (2012) Infinity-Twistor Broken Twistor-String Perihelion Precession**:
In the Cachazo–Skinner twistor-string formulation of gravity (`arXiv:1207.0741`),
introducing the infinity twistor $I_{AB}$ with Weyl-projection fidelity $\pi_I \in [0, 1]$
and cosmological constant $\Lambda_{\mathrm{cc}}$ ($I_{AB} I^{BC} = \Lambda_{\mathrm{cc}}\,\delta_A^C$)
projects out the 4-derivative Weyl conformal $C_{\mu\nu\rho\sigma}^2$ modes by $(1 - \pi_I)$
while retaining the 2-derivative Einstein–Hilbert $1/q^2$ sector weighted by $\pi_I$ plus the
cosmological-constant de Sitter precession $\frac{\pi c^2 \Lambda_{\mathrm{cc}} a^3\sqrt{1 - e^2}}{G M}$:
$$\Delta\varpi_{\mathrm{CS}}(\pi_I, \gamma_{\mathrm{conf}}, \Lambda_{\mathrm{cc}})
  = \pi_I\,\Delta\varpi_{\mathrm{PM}}(G, M, c)
  - (1 - \pi_I)\,\pi\,\gamma_{\mathrm{conf}}\,a^2\sqrt{1 - e^2}
  + \frac{\pi c^2 \Lambda_{\mathrm{cc}}\,a^3\sqrt{1 - e^2}}{G M}.$$
- At exact flat-space infinity-twistor projection ($\pi_I = 1, \Lambda_{\mathrm{cc}} = 0$),
  the Weyl conformal contamination $-\pi\gamma_{\mathrm{conf}} a^2\sqrt{1-e^2}$ vanishes
  identically for all $\gamma_{\mathrm{conf}} \in \mathbb{R}$, recovering $\Delta\varpi_{\mathrm{PM}}$
  with zero relative error ($\varepsilon_{\mathrm{rel}} = 0$).
- In the unbroken conformal limit ($\pi_I = 0, \Lambda_{\mathrm{cc}} = 0$), it reverts to
  Witten's conformal twistor-string precession $\Delta\varpi_{\mathrm{Weyl}}(0, \gamma_{\mathrm{conf}})$. -/
@[blueprint "def:signals-qed-cachazo-skinner-twistor-precession"
  (title := "Cachazo-Skinner (2012) infinity-twistor broken twistor-string perihelion precession")
  (statement := /-- For \texttt{orb : PlanetaryOrbit}, $(G,M,c)$, infinity-twistor Weyl-projection
    parameter $\pi_I$, conformal linear parameter $\gamma_{\mathrm{conf}}$, and cosmological
    constant $\Lambda_{\mathrm{cc}}$, define
    $\Delta\varpi_{\mathrm{CS}}(\pi_I,\gamma_{\mathrm{conf}},\Lambda_{\mathrm{cc}})
    = \pi_I\,\Delta\varpi_{\mathrm{PM}}(G,M,c)
    - (1-\pi_I)\,\pi\,\gamma_{\mathrm{conf}}\,a^2\sqrt{1-e^2}
    + \frac{\pi c^2\Lambda_{\mathrm{cc}}\,a^3\sqrt{1-e^2}}{G M}$. -/)]
noncomputable def PlanetaryOrbit.cachazoSkinnerTwistorPrecessionRad
    (orb : PlanetaryOrbit) (G sourceMass c piInfinity gammaConf lambdaCC : ℝ) : ℝ :=
  piInfinity * orb.perihelionPrecessionRadPM G sourceMass c -
    (1 - piInfinity) * Real.pi * gammaConf * orb.semiMajorAxis ^ 2 *
      Real.sqrt (1 - orb.eccentricity ^ 2) +
    Real.pi * c ^ 2 * lambdaCC * orb.semiMajorAxis ^ 3 *
      Real.sqrt (1 - orb.eccentricity ^ 2) / (G * sourceMass)

/-- **Partanen and Tulkki (2025) Four-$\mathrm{U}(1)$ Gauge Gravity + 1-Loop Post-Minkowskian QFT Precession (Without $Gr_{\mathbb{C}}(2,4)$)**:
In Partanen and Tulkki's flat-space 8-spinor $\mathrm{U}(1)^4$ gauge gravity
(*Rep. Prog. Phys.* 88, 057802, `arXiv:2310.01460`) and 1-loop QFT perihelion derivation
(`arXiv:2506.14447`; cf. Bjerrum-Bohr et al. 2018, *PRL* 121, 171601), the 1-loop
post-Minkowskian triangle diagram over flat Minkowski space yields
$$\Delta\varpi_{\mathrm{PT,2025}}(G, M, c) = \frac{6\pi G M}{c^2 a(1 - e^2)} = \Delta\varpi_{\mathrm{PM}}(G, M, c)$$
without complex $Gr_{\mathbb{C}}(2,4)$ Plücker twistor coordinates ($\varepsilon_{\mathrm{rel}} = 0$). -/
@[blueprint "def:signals-qed-partanen-tulkki-2025-precession"
  (title := "Partanen & Tulkki (2025) 1-loop post-Minkowskian QFT perihelion precession (without Gr_C(2,4))")
  (statement := /-- For \texttt{orb : PlanetaryOrbit} and $(G,M,c)$, define
    $\Delta\varpi_{\mathrm{PT,2025}}(G,M,c) = \Delta\varpi_{\mathrm{PM}}(G,M,c)$. -/)]
noncomputable def PlanetaryOrbit.partanenTulkki2025PrecessionRad
    (orb : PlanetaryOrbit) (G sourceMass c : ℝ) : ℝ :=
  orb.perihelionPrecessionRadPM G sourceMass c

/-- **Fedi (2026) Conservative Dilatant Dark Fluid (DDF, SSRN 7406660) Perihelion Precession (Without $Gr_{\mathbb{C}}(2,4)$)**:
In Marco Fedi's 2026 *Dilatant Dark Fluid* (SSRN 7406660), the conservative $\gamma_\varphi(v) - 1$
sheath action (derived variationally from longitudinal sheath compression $\Lambda_\parallel(v)$
with zero baseline Stokes drag, $\lambda_\gamma = 1, \eta_{\mathrm{drag}} = 0$, and $c^{-2} = \varrho_{\max}^\varphi j_{\min}^\varphi$)
yields the identical conservative 1PN precession term as `fediDarkSuperfluid2017PrecessionRad G_phi sourceMass c 1 0`
(and `RiverExterior.perihelionPrecessionRad` in `Signals.DDF`):
$$\Delta\varpi_{\mathrm{DDF,2026}}(G_\phi, M, c)
  = \Delta\varpi_{\mathrm{dark,2017}}(G_\phi, M, c, 1, 0)
  = \frac{6\pi G_\phi M}{c^2 a(1 - e^2)}$$
without $Gr_{\mathbb{C}}(2,4)$ Plücker twistor coordinates ($\varepsilon_{\mathrm{rel}} = 0$). -/
@[blueprint "def:signals-qed-fedi-ddf-2026-precession"
  (title := "Fedi (2026) conservative Dilatant Dark Fluid (DDF) perihelion precession (without Gr_C(2,4))")
  (statement := /-- For \texttt{orb : PlanetaryOrbit} and $(G_\phi,M,c)$, define
    $\Delta\varpi_{\mathrm{DDF,2026}}(G_\phi,M,c)
    = \mathrm{orb}.\mathrm{fediDarkSuperfluid2017PrecessionRad}(G_\phi,M,c,1,0)$. -/)]
noncomputable def PlanetaryOrbit.fediDDF2026PrecessionRad
    (orb : PlanetaryOrbit) (G_phi sourceMass c : ℝ) : ℝ :=
  orb.fediDarkSuperfluid2017PrecessionRad G_phi sourceMass c 1 0

/-- **Turner (2026) Flat-Space $Gr_{\mathbb{C}}(2,4)$ BCJ Double Copy + 1-Loop Post-Minkowskian QFT Precession (`Signals.QEDGravity`)**:
Factors the 1-loop post-Minkowskian perihelion advance directly through the complex
$Gr_{\mathbb{C}}(2,4)$ orbital precession twistor matrix
$M_{\mathbb{C}}^{\mathrm{orb}} = \mathrm{orb}.\mathrm{gr24PrecessionMatrix}\,\Delta\varpi \in Gr_{\mathbb{C}}(2,4)$
via the product of its uncrossed Plücker channel densities
$|w_A^{\mathbb{C}}(M_{\mathbb{C}}^{\mathrm{orb}})|^2\,|w_B^{\mathbb{C}}(M_{\mathbb{C}}^{\mathrm{orb}})|^2 = 1 - e^2 = p/a$:
$$\Delta\varpi_{\mathrm{Turner,2026}}(G, M, c, \Delta\varpi)
  = \frac{6\pi G M}{c^2 a\bigl(|w_A^{\mathbb{C}}(M_{\mathbb{C}}^{\mathrm{orb}})|^2\,|w_B^{\mathbb{C}}(M_{\mathbb{C}}^{\mathrm{orb}})|^2\bigr)}.$$ -/
@[blueprint "def:signals-qed-turner-gr24-precession"
  (title := "Turner (2026) flat-space Gr_C(2,4) BCJ double-copy 1-loop QFT perihelion precession")
  (statement := /-- For \texttt{orb : PlanetaryOrbit} and $(G,M,c,\Delta\varpi)$ with
    $M_{\mathbb C}^{\mathrm{orb}} = \mathrm{orb}.\mathrm{gr24PrecessionMatrix}(\Delta\varpi)$, define
    $\Delta\varpi_{\mathrm{Turner,2026}}(G,M,c,\Delta\varpi)
    = \frac{6\pi G M}{c^2 a(|w_A^{\mathbb C}(M_{\mathbb C}^{\mathrm{orb}})|^2|w_B^{\mathbb C}(M_{\mathbb C}^{\mathrm{orb}})|^2)}$. -/)]
noncomputable def PlanetaryOrbit.turnerGr24QEDPrecessionRad
    (orb : PlanetaryOrbit) (G sourceMass c deltaVarpi : ℝ) : ℝ :=
  let M_C := orb.gr24PrecessionMatrix deltaVarpi
  6 * Real.pi * G * sourceMass /
    (c ^ 2 * orb.semiMajorAxis *
      (Complex.normSq (complexPluckerSinkAmplitudeA M_C) *
        Complex.normSq (complexPluckerSinkAmplitudeB M_C)))

/-- **Master Multi-Model Perihelion Precession & Relative Predictive Error Comparison Theorem**:
For any bound `orb : PlanetaryOrbit`, positive physical parameters $G, M, c > 0$,
positive Weyl conformal linear parameter $\gamma_{\mathrm{conf}} > 0$, positive
cosmological constant $\Lambda_{\mathrm{cc}} > 0$, positive GPE quantum-pressure core
residual $\delta_{\mathrm{GPE}} > 0$, and positive baseline Stokes/Pioneer drag parameter
$\eta_{\mathrm{drag}} > 0$, let
$\Delta\varpi_{\mathrm{GR}} = \mathrm{orb}.\mathrm{perihelionPrecessionRadPM}\,G\,M\,c$
be the reference 1PN Einstein / 1-loop QFT perihelion advance and
$M_{\mathbb{C}}^{\mathrm{orb}} = \mathrm{orb}.\mathrm{gr24PrecessionMatrix}\,\Delta\varpi_{\mathrm{GR}}$.
Then:
1. **Strict Positivity & Exact $Gr_{\mathbb{C}}(2,4)$ Plücker Product Factorization**:
   $$0 < \Delta\varpi_{\mathrm{GR}}, \qquad
   \Delta\varpi_{\mathrm{GR}} = \frac{6\pi G M}{c^2 a\bigl(|w_A^{\mathbb{C}}(M_{\mathbb{C}}^{\mathrm{orb}})|^2\,|w_B^{\mathbb{C}}(M_{\mathbb{C}}^{\mathrm{orb}})|^2\bigr)},$$
2. **Partanen & Tulkki (2025) 1-Loop Post-Minkowskian QFT (Without $Gr_{\mathbb{C}}(2,4)$) & Turner (2026) $Gr_{\mathbb{C}}(2,4)$ BCJ Double Copy**:
   $$\Delta\varpi_{\mathrm{PT,2025}} = \Delta\varpi_{\mathrm{GR}}, \qquad
   \varepsilon_{\mathrm{rel}}(\Delta\varpi_{\mathrm{PT,2025}}, \Delta\varpi_{\mathrm{GR}}) = 0,$$
   $$\Delta\varpi_{\mathrm{Turner,2026}}(G, M, c, \Delta\varpi_{\mathrm{GR}}) = \Delta\varpi_{\mathrm{GR}}, \qquad
   \varepsilon_{\mathrm{rel}}\bigl(\Delta\varpi_{\mathrm{Turner,2026}}(G, M, c, \Delta\varpi_{\mathrm{GR}}), \Delta\varpi_{\mathrm{GR}}\bigr) = 0,$$
3. **Newtonian $1/r$ Gravity ($O(G)$ Tree-Level Without 1-Loop Correction)**:
   $$\varepsilon_{\mathrm{rel}}(\Delta\varpi_{\mathrm{Newton}}, \Delta\varpi_{\mathrm{GR}}) = 1 \quad (100\%\text{ relative error}),$$
4. **Nordström Spin-0 Scalar Gravity (Retrograde Precession)**:
   $$\Delta\varpi_{\mathrm{scalar}} < 0, \qquad
   \varepsilon_{\mathrm{rel}}(\Delta\varpi_{\mathrm{scalar}}, \Delta\varpi_{\mathrm{GR}}) = \frac{7}{6} \quad (\approx 116.67\%\text{ relative error}),$$
5. **Einstein's General Relativity (1915 / 1916) Curved-Spacetime Geodesic ($\beta_{\mathrm{PPN}} = 1, \gamma_{\mathrm{PPN}} = 1$)**:
   $$\Delta\varpi_{\mathrm{EGR}}(1, 1) = \Delta\varpi_{\mathrm{GR}}, \qquad
   \varepsilon_{\mathrm{rel}}\bigl(\Delta\varpi_{\mathrm{EGR}}(1, 1), \Delta\varpi_{\mathrm{GR}}\bigr) = 0 \quad (0\%\text{ relative error}),$$
6. **Special-Relativistic Spin-1 Vector / Un-Doubled Coulomb-QED Model**:
   $$\varepsilon_{\mathrm{rel}}(\Delta\varpi_{\mathrm{vector}}, \Delta\varpi_{\mathrm{GR}}) = \frac{5}{6} \quad (\approx 83.33\%\text{ relative error}),$$
7. **Witten's Original Twistor String Theory ($\mathcal{N}=4$ Conformal Supergravity / Weyl $C_{\mu\nu\rho\sigma}^2$)**:
   - In the pure scale-free conformal limit ($\beta_{\mathrm{scale}} = 0, \gamma_{\mathrm{conf}} = 0$):
     $$\varepsilon_{\mathrm{rel}}\bigl(\Delta\varpi_{\mathrm{Weyl}}(0, 0), \Delta\varpi_{\mathrm{GR}}\bigr) = 1 \quad (100\%\text{ relative error}),$$
   - With matched $1/r$ scale ($\beta_{\mathrm{scale}} = 1$) and biharmonic linear conformal potential ($\gamma_{\mathrm{conf}} > 0$):
     $$\varepsilon_{\mathrm{rel}}\bigl(\Delta\varpi_{\mathrm{Weyl}}(1, \gamma_{\mathrm{conf}}), \Delta\varpi_{\mathrm{GR}}\bigr) = \frac{\pi\,\gamma_{\mathrm{conf}}\,a^2\sqrt{1 - e^2}}{\Delta\varpi_{\mathrm{GR}}} > 0,$$
8. **Fedi (2016) Superfluid Quantum Gravity (`fediSQG2016PrecessionRad`)**:
   - Pure inviscid $1/r$ Euler/Bernoulli quantum-sink inflow ($\kappa_{\mathrm{rel}} = 0, \delta_{\mathrm{GPE}} = 0$):
     $$\varepsilon_{\mathrm{rel}}\bigl(\Delta\varpi_{\mathrm{SQG,2016}}(0, 0), \Delta\varpi_{\mathrm{GR}}\bigr) = 1 \quad (100\%\text{ relative error}),$$
   - Relativistic acoustic/pressure coupling at planetary scales ($\kappa_{\mathrm{rel}} = 1, \delta_{\mathrm{GPE}} = 0$):
     $$\Delta\varpi_{\mathrm{SQG,2016}}(1, 0) = \Delta\varpi_{\mathrm{GR}}, \qquad
     \varepsilon_{\mathrm{rel}}\bigl(\Delta\varpi_{\mathrm{SQG,2016}}(1, 0), \Delta\varpi_{\mathrm{GR}}\bigr) = 0,$$
   - With non-zero GPE Bohm quantum-potential core residual ($\kappa_{\mathrm{rel}} = 1, \delta_{\mathrm{GPE}} > 0$):
     $$\varepsilon_{\mathrm{rel}}\bigl(\Delta\varpi_{\mathrm{SQG,2016}}(1, \delta_{\mathrm{GPE}}), \Delta\varpi_{\mathrm{GR}}\bigr)
       = \frac{\delta_{\mathrm{GPE}}}{\Delta\varpi_{\mathrm{GR}}} > 0,$$
9. **Fedi (2017) "Hydrodynamics of the Dark Superfluid" (`fediDarkSuperfluid2017PrecessionRad`) & Fedi (2026) Conservative DDF (`fediDDF2026PrecessionRad`, Without $Gr_{\mathbb{C}}(2,4)$)**:
   - Conservative dilatant Lorentz viscosity $\gamma - 1$ / DDF sheath closure ($\lambda_\gamma = 1, \eta_{\mathrm{drag}} = 0$):
     $$\Delta\varpi_{\mathrm{DDF,2026}} = \Delta\varpi_{\mathrm{dark,2017}}(1, 0) = \Delta\varpi_{\mathrm{GR}}, \qquad
     \varepsilon_{\mathrm{rel}}(\Delta\varpi_{\mathrm{DDF,2026}}, \Delta\varpi_{\mathrm{GR}}) = 0,$$
   - With non-zero baseline Stokes/Pioneer-anomaly drag ($\lambda_\gamma = 1, \eta_{\mathrm{drag}} > 0$):
     $$\varepsilon_{\mathrm{rel}}\bigl(\Delta\varpi_{\mathrm{dark,2017}}(1, \eta_{\mathrm{drag}}), \Delta\varpi_{\mathrm{GR}}\bigr)
       = \frac{2\pi\,\eta_{\mathrm{drag}}\,a\sqrt{1 - e^2}}{\Delta\varpi_{\mathrm{GR}}} > 0,$$
10. **Cachazo–Skinner (2012) Infinity-Twistor Broken Twistor String (`cachazoSkinnerTwistorPrecessionRad`)**:
   - At flat-space infinity-twistor projection ($\pi_I = 1, \Lambda_{\mathrm{cc}} = 0$), the Weyl conformal
     term is projected out identically for **all** $\gamma_{\mathrm{conf}}$:
     $$\Delta\varpi_{\mathrm{CS}}(1, \gamma_{\mathrm{conf}}, 0) = \Delta\varpi_{\mathrm{GR}}, \qquad
     \varepsilon_{\mathrm{rel}}\bigl(\Delta\varpi_{\mathrm{CS}}(1, \gamma_{\mathrm{conf}}, 0), \Delta\varpi_{\mathrm{GR}}\bigr) = 0,$$
   - With non-zero cosmological constant $I_{AB} I^{BC} = \Lambda_{\mathrm{cc}}\,\delta_A^C$ ($\pi_I = 1, \Lambda_{\mathrm{cc}} > 0$):
     $$\varepsilon_{\mathrm{rel}}\bigl(\Delta\varpi_{\mathrm{CS}}(1, \gamma_{\mathrm{conf}}, \Lambda_{\mathrm{cc}}), \Delta\varpi_{\mathrm{GR}}\bigr)
       = \frac{\pi c^2 \Lambda_{\mathrm{cc}}\,a^3\sqrt{1 - e^2}}{G M\,\Delta\varpi_{\mathrm{GR}}} > 0,$$
   - In the unbroken conformal limit ($\pi_I = 0, \Lambda_{\mathrm{cc}} = 0$), it reduces exactly to
     Witten's conformal twistor-string model $\Delta\varpi_{\mathrm{Weyl}}(0, \gamma_{\mathrm{conf}})$. -/
@[blueprint "thm:signals-qed-gravity-models-relative-error-comparison"
  (title := "Multi-model gravity relative predictive error comparison: Einstein GR, Partanen-Tulkki 2025 QFT, Fedi 2026 DDF, Turner 2026 Gr_C(2,4), Cachazo-Skinner infinity twistor, Fedi 2016 SQG, and Fedi 2017 dark superfluid vs. Witten conformal twistor string, spin-1 vector (5/6), Nordström scalar (7/6), and Newtonian (1)")
  (statement := /-- For \texttt{orb : PlanetaryOrbit} and $G,M,c,\gamma_{\mathrm{conf}},\Lambda_{\mathrm{cc}},\delta_{\mathrm{GPE}},\eta_{\mathrm{drag}}>0$, let
    $\Delta\varpi_{\mathrm{GR}}=\mathrm{orb}.\mathrm{perihelionPrecessionRadPM}(G,M,c)$ and
    $M_{\mathbb C}^{\mathrm{orb}}=\mathrm{orb}.\mathrm{gr24PrecessionMatrix}(\Delta\varpi_{\mathrm{GR}})$. Then:
    (1) $0<\Delta\varpi_{\mathrm{GR}}$ and
    $\Delta\varpi_{\mathrm{GR}}=\frac{6\pi G M}{c^2 a(|w_A^{\mathbb C}|^2|w_B^{\mathbb C}|^2)}$;
    (2) $\varepsilon_{\mathrm{rel}}(\Delta\varpi_{\mathrm{PM}},\Delta\varpi_{\mathrm{GR}})=0$;
    (3) $\varepsilon_{\mathrm{rel}}(\Delta\varpi_{\mathrm{Newton}},\Delta\varpi_{\mathrm{GR}})=1$;
    (4) $\Delta\varpi_{\mathrm{scalar}}<0$ and
    $\varepsilon_{\mathrm{rel}}(\Delta\varpi_{\mathrm{scalar}},\Delta\varpi_{\mathrm{GR}})=7/6$;
    (5) $\Delta\varpi_{\mathrm{EGR}}(1,1)=\Delta\varpi_{\mathrm{GR}}$ and
    $\varepsilon_{\mathrm{rel}}(\Delta\varpi_{\mathrm{EGR}}(1,1),\Delta\varpi_{\mathrm{GR}})=0$;
    (6) $\varepsilon_{\mathrm{rel}}(\Delta\varpi_{\mathrm{vector}},\Delta\varpi_{\mathrm{GR}})=5/6$;
    (7) $\varepsilon_{\mathrm{rel}}(\Delta\varpi_{\mathrm{Weyl}}(0,0),\Delta\varpi_{\mathrm{GR}})=1$ and
    $\varepsilon_{\mathrm{rel}}(\Delta\varpi_{\mathrm{Weyl}}(1,\gamma_{\mathrm{conf}}),\Delta\varpi_{\mathrm{GR}})
    = \frac{\pi\gamma_{\mathrm{conf}}a^2\sqrt{1-e^2}}{\Delta\varpi_{\mathrm{GR}}} > 0$;
    (8) $\varepsilon_{\mathrm{rel}}(\Delta\varpi_{\mathrm{SQG,2016}}(0,0),\Delta\varpi_{\mathrm{GR}})=1$,
    $\Delta\varpi_{\mathrm{SQG,2016}}(1,0)=\Delta\varpi_{\mathrm{GR}}$,
    $\varepsilon_{\mathrm{rel}}(\Delta\varpi_{\mathrm{SQG,2016}}(1,0),\Delta\varpi_{\mathrm{GR}})=0$, and
    $\varepsilon_{\mathrm{rel}}(\Delta\varpi_{\mathrm{SQG,2016}}(1,\delta_{\mathrm{GPE}}),\Delta\varpi_{\mathrm{GR}})
    = \frac{\delta_{\mathrm{GPE}}}{\Delta\varpi_{\mathrm{GR}}} > 0$;
    (9) $\Delta\varpi_{\mathrm{dark,2017}}(1,0)=\Delta\varpi_{\mathrm{GR}}$,
    $\varepsilon_{\mathrm{rel}}(\Delta\varpi_{\mathrm{dark,2017}}(1,0),\Delta\varpi_{\mathrm{GR}})=0$, and
    $\varepsilon_{\mathrm{rel}}(\Delta\varpi_{\mathrm{dark,2017}}(1,\eta_{\mathrm{drag}}),\Delta\varpi_{\mathrm{GR}})
    = \frac{2\pi\eta_{\mathrm{drag}}a\sqrt{1-e^2}}{\Delta\varpi_{\mathrm{GR}}} > 0$;
    (10) $\Delta\varpi_{\mathrm{CS}}(1,\gamma_{\mathrm{conf}},0)=\Delta\varpi_{\mathrm{GR}}$,
    $\varepsilon_{\mathrm{rel}}(\Delta\varpi_{\mathrm{CS}}(1,\gamma_{\mathrm{conf}},0),\Delta\varpi_{\mathrm{GR}})=0$,
    $\varepsilon_{\mathrm{rel}}(\Delta\varpi_{\mathrm{CS}}(1,\gamma_{\mathrm{conf}},\Lambda_{\mathrm{cc}}),\Delta\varpi_{\mathrm{GR}})
    = \frac{\pi c^2\Lambda_{\mathrm{cc}}a^3\sqrt{1-e^2}}{G M\Delta\varpi_{\mathrm{GR}}} > 0$, and
    $\Delta\varpi_{\mathrm{CS}}(0,\gamma_{\mathrm{conf}},0)=\Delta\varpi_{\mathrm{Weyl}}(0,\gamma_{\mathrm{conf}})$;
    (11) $\Delta\varpi_{\mathrm{PT,2025}}(G,M,c)=\Delta\varpi_{\mathrm{GR}}$,
    $\varepsilon_{\mathrm{rel}}(\Delta\varpi_{\mathrm{PT,2025}}(G,M,c),\Delta\varpi_{\mathrm{GR}})=0$,
    $\Delta\varpi_{\mathrm{DDF,2026}}(G,M,c)=\Delta\varpi_{\mathrm{GR}}$,
    $\varepsilon_{\mathrm{rel}}(\Delta\varpi_{\mathrm{DDF,2026}}(G,M,c),\Delta\varpi_{\mathrm{GR}})=0$,
    $\Delta\varpi_{\mathrm{Turner,2026}}(G,M,c,\Delta\varpi_{\mathrm{GR}})=\Delta\varpi_{\mathrm{GR}}$, and
    $\varepsilon_{\mathrm{rel}}(\Delta\varpi_{\mathrm{Turner,2026}}(G,M,c,\Delta\varpi_{\mathrm{GR}}),\Delta\varpi_{\mathrm{GR}})=0$. -/)
  (proof := /-- Establish $0<\Delta\varpi_{\mathrm{GR}}$ by \texttt{positivity}, apply
    \texttt{gr24PrecessionMatrix\_orbital\_identities} for the Plücker product denominator,
    and evaluate each \texttt{relativePredictiveError} ratio using $\Delta\varpi_{\mathrm{GR}}>0$. -/)]
theorem PlanetaryOrbit.gravity_models_relative_predictive_error_comparison
    (orb : PlanetaryOrbit) (G sourceMass c gammaConf lambdaCC deltaGPE etaDrag : ℝ)
    (hG : 0 < G) (hM : 0 < sourceMass) (hc : 0 < c)
    (hGamma : 0 < gammaConf) (hLambda : 0 < lambdaCC)
    (hDeltaGPE : 0 < deltaGPE) (hEtaDrag : 0 < etaDrag) :
    let Δϖ_GR := orb.perihelionPrecessionRadPM G sourceMass c
    let M_C := orb.gr24PrecessionMatrix Δϖ_GR
    0 < Δϖ_GR ∧
      Δϖ_GR =
        6 * Real.pi * G * sourceMass /
          (c ^ 2 * orb.semiMajorAxis *
            (Complex.normSq (complexPluckerSinkAmplitudeA M_C) *
              Complex.normSq (complexPluckerSinkAmplitudeB M_C))) ∧
      relativePredictiveError Δϖ_GR Δϖ_GR = 0 ∧
      relativePredictiveError orb.newtonianAnomalousPrecessionRad Δϖ_GR = 1 ∧
      orb.nordstromScalarPrecessionRad G sourceMass c < 0 ∧
      relativePredictiveError (orb.nordstromScalarPrecessionRad G sourceMass c) Δϖ_GR = 7 / 6 ∧
      orb.einsteinGeneralRelativityPrecessionRad G sourceMass c 1 1 = Δϖ_GR ∧
      relativePredictiveError
        (orb.einsteinGeneralRelativityPrecessionRad G sourceMass c 1 1) Δϖ_GR = 0 ∧
      relativePredictiveError (orb.spinOneVectorPrecessionRad G sourceMass c) Δϖ_GR = 5 / 6 ∧
      relativePredictiveError (orb.wittenConformalTwistorPrecessionRad G sourceMass c 0 0) Δϖ_GR = 1 ∧
      relativePredictiveError
        (orb.wittenConformalTwistorPrecessionRad G sourceMass c 1 gammaConf) Δϖ_GR =
        Real.pi * gammaConf * orb.semiMajorAxis ^ 2 *
          Real.sqrt (1 - orb.eccentricity ^ 2) / Δϖ_GR ∧
      0 < relativePredictiveError
        (orb.wittenConformalTwistorPrecessionRad G sourceMass c 1 gammaConf) Δϖ_GR ∧
      relativePredictiveError (orb.fediSQG2016PrecessionRad G sourceMass c 0 0) Δϖ_GR = 1 ∧
      orb.fediSQG2016PrecessionRad G sourceMass c 1 0 = Δϖ_GR ∧
      relativePredictiveError (orb.fediSQG2016PrecessionRad G sourceMass c 1 0) Δϖ_GR = 0 ∧
      relativePredictiveError
        (orb.fediSQG2016PrecessionRad G sourceMass c 1 deltaGPE) Δϖ_GR =
        deltaGPE / Δϖ_GR ∧
      0 < relativePredictiveError
        (orb.fediSQG2016PrecessionRad G sourceMass c 1 deltaGPE) Δϖ_GR ∧
      orb.fediDarkSuperfluid2017PrecessionRad G sourceMass c 1 0 = Δϖ_GR ∧
      relativePredictiveError
        (orb.fediDarkSuperfluid2017PrecessionRad G sourceMass c 1 0) Δϖ_GR = 0 ∧
      relativePredictiveError
        (orb.fediDarkSuperfluid2017PrecessionRad G sourceMass c 1 etaDrag) Δϖ_GR =
        2 * Real.pi * etaDrag * orb.semiMajorAxis *
          Real.sqrt (1 - orb.eccentricity ^ 2) / Δϖ_GR ∧
      0 < relativePredictiveError
        (orb.fediDarkSuperfluid2017PrecessionRad G sourceMass c 1 etaDrag) Δϖ_GR ∧
      orb.cachazoSkinnerTwistorPrecessionRad G sourceMass c 1 gammaConf 0 = Δϖ_GR ∧
      relativePredictiveError
        (orb.cachazoSkinnerTwistorPrecessionRad G sourceMass c 1 gammaConf 0) Δϖ_GR = 0 ∧
      relativePredictiveError
        (orb.cachazoSkinnerTwistorPrecessionRad G sourceMass c 1 gammaConf lambdaCC) Δϖ_GR =
        Real.pi * c ^ 2 * lambdaCC * orb.semiMajorAxis ^ 3 *
          Real.sqrt (1 - orb.eccentricity ^ 2) / (G * sourceMass) / Δϖ_GR ∧
      0 < relativePredictiveError
        (orb.cachazoSkinnerTwistorPrecessionRad G sourceMass c 1 gammaConf lambdaCC) Δϖ_GR ∧
      orb.cachazoSkinnerTwistorPrecessionRad G sourceMass c 0 gammaConf 0 =
        orb.wittenConformalTwistorPrecessionRad G sourceMass c 0 gammaConf ∧
      orb.partanenTulkki2025PrecessionRad G sourceMass c = Δϖ_GR ∧
      relativePredictiveError (orb.partanenTulkki2025PrecessionRad G sourceMass c) Δϖ_GR = 0 ∧
      orb.fediDDF2026PrecessionRad G sourceMass c = Δϖ_GR ∧
      relativePredictiveError (orb.fediDDF2026PrecessionRad G sourceMass c) Δϖ_GR = 0 ∧
      orb.turnerGr24QEDPrecessionRad G sourceMass c Δϖ_GR = Δϖ_GR ∧
      relativePredictiveError
        (orb.turnerGr24QEDPrecessionRad G sourceMass c Δϖ_GR) Δϖ_GR = 0 := by
  intro Δϖ_GR M_C
  have ha_pos := orb.semiMajorAxis_pos
  have ha_ne : orb.semiMajorAxis ≠ 0 := ne_of_gt ha_pos
  have h1e2_pos : 0 < 1 - orb.eccentricity ^ 2 := (orb.radii_identities).1
  have hp_pos : 0 < orb.semiLatusRectum := (orb.radii_identities).2.1
  have h_sqrt_pos : 0 < Real.sqrt (1 - orb.eccentricity ^ 2) := Real.sqrt_pos.mpr h1e2_pos
  have hpi_pos : 0 < Real.pi := Real.pi_pos
  have h_gr_pos : 0 < Δϖ_GR := by
    dsimp [Δϖ_GR]
    unfold PlanetaryOrbit.perihelionPrecessionRadPM
    positivity
  have h_gr_ne : Δϖ_GR ≠ 0 := ne_of_gt h_gr_pos
  have h_abs_gr : |Δϖ_GR| = Δϖ_GR := abs_of_pos h_gr_pos
  have h_orb := orb.gr24PrecessionMatrix_orbital_identities Δϖ_GR
  have h_prod :
      orb.semiMajorAxis *
        (Complex.normSq (complexPluckerSinkAmplitudeA M_C) *
          Complex.normSq (complexPluckerSinkAmplitudeB M_C)) =
        orb.semiLatusRectum := by
    dsimp [M_C]
    rw [h_orb.2.2.2.1]
    exact mul_div_cancel₀ orb.semiLatusRectum ha_ne
  have h_gr_plucker :
      Δϖ_GR =
        6 * Real.pi * G * sourceMass /
          (c ^ 2 * orb.semiMajorAxis *
            (Complex.normSq (complexPluckerSinkAmplitudeA M_C) *
              Complex.normSq (complexPluckerSinkAmplitudeB M_C))) := by
    dsimp [Δϖ_GR]
    unfold PlanetaryOrbit.perihelionPrecessionRadPM
    rw [mul_assoc (c ^ 2), h_prod]
  have h_err_pm : relativePredictiveError Δϖ_GR Δϖ_GR = 0 := by
    simp [relativePredictiveError]
  have h_err_newt : relativePredictiveError orb.newtonianAnomalousPrecessionRad Δϖ_GR = 1 := by
    unfold relativePredictiveError PlanetaryOrbit.newtonianAnomalousPrecessionRad
    rw [zero_sub, abs_neg, h_abs_gr, div_self h_gr_ne]
  have h_scal_neg : orb.nordstromScalarPrecessionRad G sourceMass c < 0 := by
    unfold PlanetaryOrbit.nordstromScalarPrecessionRad
    linarith
  have h_err_scal :
      relativePredictiveError (orb.nordstromScalarPrecessionRad G sourceMass c) Δϖ_GR = 7 / 6 := by
    unfold relativePredictiveError PlanetaryOrbit.nordstromScalarPrecessionRad
    have h_diff : - (1 / 6 : ℝ) * Δϖ_GR - Δϖ_GR = - ((7 / 6 : ℝ) * Δϖ_GR) := by ring
    have h_pos76 : 0 < (7 / 6 : ℝ) * Δϖ_GR := by positivity
    change |(-(1 / 6 : ℝ) * Δϖ_GR - Δϖ_GR)| / |Δϖ_GR| = 7 / 6
    rw [h_diff, abs_neg, abs_of_pos h_pos76, h_abs_gr, mul_div_cancel_right₀ _ h_gr_ne]
  have h_egr :
      orb.einsteinGeneralRelativityPrecessionRad G sourceMass c 1 1 = Δϖ_GR := by
    unfold PlanetaryOrbit.einsteinGeneralRelativityPrecessionRad
    change ((2 - 1 + 2 * 1) / 3 : ℝ) * Δϖ_GR = Δϖ_GR
    ring
  have h_err_egr :
      relativePredictiveError
        (orb.einsteinGeneralRelativityPrecessionRad G sourceMass c 1 1) Δϖ_GR = 0 := by
    rw [h_egr, h_err_pm]
  have h_err_vec :
      relativePredictiveError (orb.spinOneVectorPrecessionRad G sourceMass c) Δϖ_GR = 5 / 6 := by
    unfold relativePredictiveError PlanetaryOrbit.spinOneVectorPrecessionRad
    have h_diff : (1 / 6 : ℝ) * Δϖ_GR - Δϖ_GR = - ((5 / 6 : ℝ) * Δϖ_GR) := by ring
    have h_pos56 : 0 < (5 / 6 : ℝ) * Δϖ_GR := by positivity
    change |((1 / 6 : ℝ) * Δϖ_GR - Δϖ_GR)| / |Δϖ_GR| = 5 / 6
    rw [h_diff, abs_neg, abs_of_pos h_pos56, h_abs_gr, mul_div_cancel_right₀ _ h_gr_ne]
  have h_err_weyl0 :
      relativePredictiveError (orb.wittenConformalTwistorPrecessionRad G sourceMass c 0 0) Δϖ_GR = 1 := by
    unfold relativePredictiveError PlanetaryOrbit.wittenConformalTwistorPrecessionRad
    change |(0 * Δϖ_GR - Real.pi * 0 * orb.semiMajorAxis ^ 2 * Real.sqrt (1 - orb.eccentricity ^ 2) - Δϖ_GR)| / |Δϖ_GR| = 1
    have h_simp :
        0 * Δϖ_GR - Real.pi * 0 * orb.semiMajorAxis ^ 2 * Real.sqrt (1 - orb.eccentricity ^ 2) - Δϖ_GR =
          - Δϖ_GR := by ring
    rw [h_simp, abs_neg, h_abs_gr, div_self h_gr_ne]
  have h_weyl_shift_pos :
      0 < Real.pi * gammaConf * orb.semiMajorAxis ^ 2 * Real.sqrt (1 - orb.eccentricity ^ 2) := by
    positivity
  have h_err_weyl1 :
      relativePredictiveError
        (orb.wittenConformalTwistorPrecessionRad G sourceMass c 1 gammaConf) Δϖ_GR =
        Real.pi * gammaConf * orb.semiMajorAxis ^ 2 *
          Real.sqrt (1 - orb.eccentricity ^ 2) / Δϖ_GR := by
    unfold relativePredictiveError PlanetaryOrbit.wittenConformalTwistorPrecessionRad
    change |(1 * Δϖ_GR - Real.pi * gammaConf * orb.semiMajorAxis ^ 2 * Real.sqrt (1 - orb.eccentricity ^ 2) - Δϖ_GR)| / |Δϖ_GR| = _
    have h_simp :
        1 * Δϖ_GR - Real.pi * gammaConf * orb.semiMajorAxis ^ 2 * Real.sqrt (1 - orb.eccentricity ^ 2) - Δϖ_GR =
          - (Real.pi * gammaConf * orb.semiMajorAxis ^ 2 * Real.sqrt (1 - orb.eccentricity ^ 2)) := by
      ring
    rw [h_simp, abs_neg, abs_of_pos h_weyl_shift_pos, h_abs_gr]
  have h_err_weyl1_pos :
      0 < relativePredictiveError
        (orb.wittenConformalTwistorPrecessionRad G sourceMass c 1 gammaConf) Δϖ_GR := by
    rw [h_err_weyl1]
    positivity
  have h_err_sqg0 :
      relativePredictiveError (orb.fediSQG2016PrecessionRad G sourceMass c 0 0) Δϖ_GR = 1 := by
    unfold relativePredictiveError PlanetaryOrbit.fediSQG2016PrecessionRad
    change |(0 * Δϖ_GR + 0 - Δϖ_GR)| / |Δϖ_GR| = 1
    have h_simp : 0 * Δϖ_GR + 0 - Δϖ_GR = - Δϖ_GR := by ring
    rw [h_simp, abs_neg, h_abs_gr, div_self h_gr_ne]
  have h_sqg10 :
      orb.fediSQG2016PrecessionRad G sourceMass c 1 0 = Δϖ_GR := by
    unfold PlanetaryOrbit.fediSQG2016PrecessionRad
    change 1 * Δϖ_GR + 0 = Δϖ_GR
    ring
  have h_err_sqg10 :
      relativePredictiveError (orb.fediSQG2016PrecessionRad G sourceMass c 1 0) Δϖ_GR = 0 := by
    rw [h_sqg10, h_err_pm]
  have h_err_sqg_gpe :
      relativePredictiveError
        (orb.fediSQG2016PrecessionRad G sourceMass c 1 deltaGPE) Δϖ_GR =
        deltaGPE / Δϖ_GR := by
    unfold relativePredictiveError PlanetaryOrbit.fediSQG2016PrecessionRad
    change |(1 * Δϖ_GR + deltaGPE - Δϖ_GR)| / |Δϖ_GR| = deltaGPE / Δϖ_GR
    have h_simp : 1 * Δϖ_GR + deltaGPE - Δϖ_GR = deltaGPE := by ring
    rw [h_simp, abs_of_pos hDeltaGPE, h_abs_gr]
  have h_err_sqg_gpe_pos :
      0 < relativePredictiveError
        (orb.fediSQG2016PrecessionRad G sourceMass c 1 deltaGPE) Δϖ_GR := by
    rw [h_err_sqg_gpe]
    positivity
  have h_dark10 :
      orb.fediDarkSuperfluid2017PrecessionRad G sourceMass c 1 0 = Δϖ_GR := by
    unfold PlanetaryOrbit.fediDarkSuperfluid2017PrecessionRad
    change 1 * Δϖ_GR -
      2 * Real.pi * 0 * orb.semiMajorAxis * Real.sqrt (1 - orb.eccentricity ^ 2) = Δϖ_GR
    ring
  have h_err_dark10 :
      relativePredictiveError
        (orb.fediDarkSuperfluid2017PrecessionRad G sourceMass c 1 0) Δϖ_GR = 0 := by
    rw [h_dark10, h_err_pm]
  have h_dark_drag_pos :
      0 < 2 * Real.pi * etaDrag * orb.semiMajorAxis * Real.sqrt (1 - orb.eccentricity ^ 2) := by
    positivity
  have h_err_dark_drag :
      relativePredictiveError
        (orb.fediDarkSuperfluid2017PrecessionRad G sourceMass c 1 etaDrag) Δϖ_GR =
        2 * Real.pi * etaDrag * orb.semiMajorAxis *
          Real.sqrt (1 - orb.eccentricity ^ 2) / Δϖ_GR := by
    unfold relativePredictiveError PlanetaryOrbit.fediDarkSuperfluid2017PrecessionRad
    change |(1 * Δϖ_GR -
      2 * Real.pi * etaDrag * orb.semiMajorAxis * Real.sqrt (1 - orb.eccentricity ^ 2) - Δϖ_GR)| /
        |Δϖ_GR| = _
    have h_simp :
        1 * Δϖ_GR -
          2 * Real.pi * etaDrag * orb.semiMajorAxis * Real.sqrt (1 - orb.eccentricity ^ 2) - Δϖ_GR =
          - (2 * Real.pi * etaDrag * orb.semiMajorAxis * Real.sqrt (1 - orb.eccentricity ^ 2)) := by
      ring
    rw [h_simp, abs_neg, abs_of_pos h_dark_drag_pos, h_abs_gr]
  have h_err_dark_drag_pos :
      0 < relativePredictiveError
        (orb.fediDarkSuperfluid2017PrecessionRad G sourceMass c 1 etaDrag) Δϖ_GR := by
    rw [h_err_dark_drag]
    positivity
  have h_cs_flat :
      orb.cachazoSkinnerTwistorPrecessionRad G sourceMass c 1 gammaConf 0 = Δϖ_GR := by
    unfold PlanetaryOrbit.cachazoSkinnerTwistorPrecessionRad
    change 1 * Δϖ_GR -
      (1 - 1) * Real.pi * gammaConf * orb.semiMajorAxis ^ 2 *
        Real.sqrt (1 - orb.eccentricity ^ 2) +
      Real.pi * c ^ 2 * 0 * orb.semiMajorAxis ^ 3 *
        Real.sqrt (1 - orb.eccentricity ^ 2) / (G * sourceMass) = Δϖ_GR
    ring
  have h_err_cs_flat :
      relativePredictiveError
        (orb.cachazoSkinnerTwistorPrecessionRad G sourceMass c 1 gammaConf 0) Δϖ_GR = 0 := by
    rw [h_cs_flat, h_err_pm]
  have h_cs_cc_shift_pos :
      0 < Real.pi * c ^ 2 * lambdaCC * orb.semiMajorAxis ^ 3 *
        Real.sqrt (1 - orb.eccentricity ^ 2) / (G * sourceMass) := by
    positivity
  have h_err_cs_cc :
      relativePredictiveError
        (orb.cachazoSkinnerTwistorPrecessionRad G sourceMass c 1 gammaConf lambdaCC) Δϖ_GR =
        Real.pi * c ^ 2 * lambdaCC * orb.semiMajorAxis ^ 3 *
          Real.sqrt (1 - orb.eccentricity ^ 2) / (G * sourceMass) / Δϖ_GR := by
    unfold relativePredictiveError PlanetaryOrbit.cachazoSkinnerTwistorPrecessionRad
    change |(1 * Δϖ_GR -
      (1 - 1) * Real.pi * gammaConf * orb.semiMajorAxis ^ 2 *
        Real.sqrt (1 - orb.eccentricity ^ 2) +
      Real.pi * c ^ 2 * lambdaCC * orb.semiMajorAxis ^ 3 *
        Real.sqrt (1 - orb.eccentricity ^ 2) / (G * sourceMass) - Δϖ_GR)| / |Δϖ_GR| = _
    have h_simp :
        1 * Δϖ_GR -
          (1 - 1) * Real.pi * gammaConf * orb.semiMajorAxis ^ 2 *
            Real.sqrt (1 - orb.eccentricity ^ 2) +
          Real.pi * c ^ 2 * lambdaCC * orb.semiMajorAxis ^ 3 *
            Real.sqrt (1 - orb.eccentricity ^ 2) / (G * sourceMass) - Δϖ_GR =
          Real.pi * c ^ 2 * lambdaCC * orb.semiMajorAxis ^ 3 *
            Real.sqrt (1 - orb.eccentricity ^ 2) / (G * sourceMass) := by
      ring
    rw [h_simp, abs_of_pos h_cs_cc_shift_pos, h_abs_gr]
  have h_err_cs_cc_pos :
      0 < relativePredictiveError
        (orb.cachazoSkinnerTwistorPrecessionRad G sourceMass c 1 gammaConf lambdaCC) Δϖ_GR := by
    rw [h_err_cs_cc]
    positivity
  have h_cs_unbroken :
      orb.cachazoSkinnerTwistorPrecessionRad G sourceMass c 0 gammaConf 0 =
        orb.wittenConformalTwistorPrecessionRad G sourceMass c 0 gammaConf := by
    unfold PlanetaryOrbit.cachazoSkinnerTwistorPrecessionRad
      PlanetaryOrbit.wittenConformalTwistorPrecessionRad
    ring
  have h_pt : orb.partanenTulkki2025PrecessionRad G sourceMass c = Δϖ_GR := rfl
  have h_err_pt :
      relativePredictiveError (orb.partanenTulkki2025PrecessionRad G sourceMass c) Δϖ_GR = 0 :=
    h_err_pm
  have h_ddf26 : orb.fediDDF2026PrecessionRad G sourceMass c = Δϖ_GR := h_dark10
  have h_err_ddf26 :
      relativePredictiveError (orb.fediDDF2026PrecessionRad G sourceMass c) Δϖ_GR = 0 :=
    h_err_dark10
  have h_turner :
      orb.turnerGr24QEDPrecessionRad G sourceMass c Δϖ_GR = Δϖ_GR :=
    h_gr_plucker.symm
  have h_err_turner :
      relativePredictiveError
        (orb.turnerGr24QEDPrecessionRad G sourceMass c Δϖ_GR) Δϖ_GR = 0 := by
    rw [h_turner, h_err_pm]
  exact ⟨h_gr_pos, h_gr_plucker, h_err_pm, h_err_newt, h_scal_neg,
    h_err_scal, h_egr, h_err_egr, h_err_vec, h_err_weyl0, h_err_weyl1, h_err_weyl1_pos,
    h_err_sqg0, h_sqg10, h_err_sqg10, h_err_sqg_gpe, h_err_sqg_gpe_pos,
    h_dark10, h_err_dark10, h_err_dark_drag, h_err_dark_drag_pos,
    h_cs_flat, h_err_cs_flat, h_err_cs_cc, h_err_cs_cc_pos, h_cs_unbroken,
    h_pt, h_err_pt, h_ddf26, h_err_ddf26, h_turner, h_err_turner⟩

/-! ### Multi-Model Gravitational-Wave Luminosity Comparison & Machine-Checked Relative Predictive Errors

| # | Gravitational-Wave Model & Radiative Mechanism | Binary Radiated Luminosity $P_{\mathrm{GW}}^{\mathrm{model}}$ (2.5PN / Leading Multipole) | TT $(+, \times)$ Error $\varepsilon_{\mathrm{rel}}^{\mathrm{TT}}$ | Total Multipole Error $\varepsilon_{\mathrm{rel}}^{\mathrm{tot}}$ |
|---|---|---|---|---|
| **1** | **Newtonian $1/r$ Instantaneous Gravity** (`newtonianGWLuminosity`: $c \to \infty$) | $0$ | **$1$ ($100\%$)** | **$1$ ($100\%$)** |
| **2** | **Nordström Relativistic Scalar Gravity (1913)** (`nordstromScalarGWLuminosity`) | $\kappa_{\mathrm{scalar}} P_{\mathrm{GW}}^{\mathrm{GR}}$ ($\kappa_{\mathrm{scalar}}=0$ TT; $\frac{1}{6}$ virial trace) | **$1$ ($100\%$)** | **$\frac{5}{6} \approx 83.33\%$** |
| **3** | **Einstein's General Relativity (1916 / 1918) & Peters–Mathews (1963)** (`einsteinGeneralRelativityGWLuminosity` at $\kappa_{\mathrm{quad}}=1$) | $P_{\mathrm{GW}}^{\mathrm{EGR}}(1) = \frac{32}{5}\frac{G_\phi^4 m_1^2 m_2^2(m_1+m_2)}{c^5 a^5} f_{\mathrm{PM}}(e) = P_{\mathrm{GW}}^{\mathrm{GR}}$ | **$0$ ($0\%$)** | **$0$ ($0\%$)** |
| **4** | **Special-Relativistic Spin-1 Vector / Un-Doubled Larmor Model** (`spinOneVectorGWLuminosity`) | $\kappa_{\mathrm{vec}} P_{\mathrm{GW}}^{\mathrm{GR}} + \Delta_{\mathrm{dip}}$ ($\ddot{\mathbf{d}}=\mathbf{0} \implies \Delta_{\mathrm{dip}}=0$, $\kappa_{\mathrm{vec}}=\frac{1}{4}$) | **$1$ ($100\%$)** | **$\frac{3}{4} = 75\%$** |
| **5a** | **Witten (2004) Twistor String (Pure Scale-Free Conformal Limit)** (`wittenConformalTwistorGWLuminosity` at $\beta_{\mathrm{scale}}=0, \delta P_{\mathrm{ghost}}=0$) | $0$ | **$1$ ($100\%$)** | **$1$ ($100\%$)** |
| **5b** | **Witten (2004) Twistor-String Conformal Gravity w/ Negative-Norm Weyl Ghost Flux** (`wittenConformalTwistorGWLuminosity` at $\beta_{\mathrm{scale}}=1, \delta P_{\mathrm{ghost}}>0$) | $P_{\mathrm{GW}}^{\mathrm{GR}} - \delta P_{\mathrm{ghost}}$ | **$\frac{\delta P_{\mathrm{ghost}}}{P_{\mathrm{GW}}^{\mathrm{GR}}} > 0$** | **$\frac{\delta P_{\mathrm{ghost}}}{P_{\mathrm{GW}}^{\mathrm{GR}}} > 0$** |
| **6** | **Dissipative Viscous Stokes-Drag Ether** (`ddf_conservative_action_vs_stokes_drag_critique`: $P_{\mathrm{Stokes}} = F_{\mathrm{drag}} v > 0$) | $P_{\mathrm{diss}} = F_{\mathrm{drag}} v \propto v^2$ | **$1$ ($100\%$)** | **$\frac{P_{\mathrm{Stokes}}}{P_{\mathrm{GW}}^{\mathrm{GR}}} \gg 1$** |
| **7a** | **Cachazo–Skinner (2012) Infinity-Twistor w/ Cosmological Constant ($\Lambda_{\mathrm{cc}} > 0$)** (`cachazoSkinnerTwistorGWLuminosity` at $\pi_I=1, \delta P_\Lambda>0$) | $P_{\mathrm{GW}}^{\mathrm{GR}} + \delta P_\Lambda$ | **$\frac{\delta P_\Lambda}{P_{\mathrm{GW}}^{\mathrm{GR}}} > 0$** | **$\frac{\delta P_\Lambda}{P_{\mathrm{GW}}^{\mathrm{GR}}} > 0$** |
| **7b** | **Cachazo–Skinner (2012) Infinity-Twistor Rational Curves ($\Lambda_{\mathrm{cc}} = 0$)** (`cachazoSkinnerTwistorGWLuminosity` at $\pi_I=1, \delta P_\Lambda=0$) | $P_{\mathrm{GW}}^{\mathrm{CS}}(1, \delta P_{\mathrm{ghost}}, 0) = P_{\mathrm{GW}}^{\mathrm{GR}}$ ($\forall\,\delta P_{\mathrm{ghost}}$) | **$0$ ($0\%$)** | **$0$ ($0\%$)** |
| **8a** | **Fedi (2016) "Superfluid Quantum Gravity" (Pure Longitudinal Inviscid BEC Sink)** (`fediSQG2016GWLuminosity` at $\kappa_{\mathrm{trans}}=0, \delta P_{\mathrm{GPE}}=0$) | $0$ in spin-2 TT $(+, \times)$ channel ($\mu_{\mathrm{shear}} = 0$) | **$1$ ($100\%$)** | **$1$ ($100\%$ on TT)** |
| **8b** | **Fedi (2016) "Superfluid Quantum Gravity" (Vortex-Lattice Transverse Elasticity + GPE)** (`fediSQG2016GWLuminosity` at $\kappa_{\mathrm{trans}}=1, \delta P_{\mathrm{GPE}}\ge 0$) | $P_{\mathrm{GW}}^{\mathrm{GR}} + \delta P_{\mathrm{GPE}}$ ($P_{\mathrm{GW}}^{\mathrm{GR}}$ at $\delta P_{\mathrm{GPE}}=0$) | **$0$ ($0\%$ at $\delta P_{\mathrm{GPE}}=0$)** | **$0\%$** (at $\delta P_{\mathrm{GPE}}=0$) |
| **9a** | **Fedi (2017) "Hydrodynamics of the Dark Superfluid" (Dilatant $\gamma - 1$ w/ Stokes Drag $P_{\mathrm{Stokes}} > 0$)** (`fediDarkSuperfluid2017GWLuminosity` at $\lambda_\gamma=1, P_{\mathrm{Stokes}}>0$) | $P_{\mathrm{GW}}^{\mathrm{GR}} + P_{\mathrm{Stokes}}$ | **$\frac{P_{\mathrm{Stokes}}}{P_{\mathrm{GW}}^{\mathrm{GR}}} > 0$** | **$\frac{P_{\mathrm{Stokes}}}{P_{\mathrm{GW}}^{\mathrm{GR}}} > 0$** |
| **9b** | **Fedi (2017) "Hydrodynamics of the Dark Superfluid" (Conservative Dilatant $\gamma - 1$, $P_{\mathrm{Stokes}} = 0$)** (`fediDarkSuperfluid2017GWLuminosity` at $\lambda_\gamma=1, P_{\mathrm{Stokes}}=0$) | $P_{\mathrm{GW}}^{\mathrm{dark,2017}}(1, 0) = P_{\mathrm{GW}}^{\mathrm{GR}}$ | **$0$ ($0\%$)** | **$0$ ($0\%$)** |
| **10** | **Partanen & Tulkki (2025) Four-$\mathrm{U}(1)$ Gauge Gravity + 2.5PN Post-Minkowskian QFT (Without $Gr_{\mathbb{C}}(2,4)$)** (`partanenTulkki2025GWLuminosity`) | $P_{\mathrm{GW}}^{\mathrm{PT,2025}} = \frac{32}{5}\frac{G_\phi^4 m_1^2 m_2^2(m_1+m_2)}{c^5 a^5} f_{\mathrm{PM}}(e) = P_{\mathrm{GW}}^{\mathrm{GR}}$ | **$0$ ($0\%$)** | **$0$ ($0\%$)** |
| **11** | **Fedi (2026) Conservative Dilatant Dark Fluid (DDF, Without $Gr_{\mathbb{C}}(2,4)$)** (`fediDDF2026GWLuminosity`) | $P_{\mathrm{GW}}^{\mathrm{DDF,2026}} = \frac{32}{5}\frac{G_\phi^4 m_1^2 m_2^2(m_1+m_2)(\varrho_{\max}^\varphi j_{\min}^\varphi)^{5/2}}{a^5} f_{\mathrm{PM}}(e) = P_{\mathrm{GW}}^{\mathrm{GR}}$ | **$0$ ($0\%$)** | **$0$ ($0\%$)** |
| **12** | **Turner (2026) Flat-Space $Gr_{\mathbb{C}}(2,4)$ BCJ Double Copy + 2.5PN Post-Minkowskian QFT (Without DDF)** (`turnerGr24QEDGWLuminosity`) | $\frac{32}{5}\frac{G_\phi^4 m_1^2 m_2^2(m_1+m_2)}{c^5 a^5}\frac{P_{\mathrm{PM}}(e)}{(\sqrt{\|w_A^{\mathbb{C}}\|^2\|w_B^{\mathbb{C}}\|^2})^7} = P_{\mathrm{GW}}^{\mathrm{GR}}$ | **$0$ ($0\%$)** | **$0$ ($0\%$)** |
| **13** | **Turner (2026) Unified $Gr_{\mathbb{C}}(2,4)$ + Conservative Dilatant Dark Fluid (DDF) + 3D `NormedTensorGaussianSplat3D`** (`RiverExterior.gravitational_wave_with_ddf_identities`) | $(P_{\mathrm{GW}}^{\mathrm{DDF}})^2 = \bigl(\frac{32}{5}\frac{G_\phi^4 M^2 m_2^2(M+m_2)}{a^5}\bigr)^2 (\varrho_{\max}^\varphi j_{\min}^\varphi)^5 \frac{P_{\mathrm{PM}}(e)^2}{(\|w_A^{\mathbb{C}}\|^2\|w_B^{\mathbb{C}}\|^2)^7}$ | **$0$ ($0\%$)** | **$0$ ($0\%$)** |
-/

/-- **Newtonian $1/r$ Instantaneous Gravity Gravitational-Wave Luminosity**:
In classical Newtonian gravity ($\nabla^2\Phi = 4\pi G\rho$, $c \to \infty$), gravitational
interaction is instantaneous with no retarded wave operator and zero radiation reaction:
$$P_{\mathrm{GW}}^{\mathrm{Newton}} = 0.$$ -/
@[blueprint "def:signals-qed-newtonian-gw-luminosity"
  (title := "Newtonian instantaneous 1/r gravitational-wave luminosity (0)")
  (statement := /-- For \texttt{orb : PlanetaryOrbit}, define $P_{\mathrm{GW}}^{\mathrm{Newton}} = 0$. -/)]
def PlanetaryOrbit.newtonianGWLuminosity (_orb : PlanetaryOrbit) : ℝ := 0

/-- **Nordström (1913) Spin-0 Relativistic Scalar Gravitational-Wave Luminosity**:
In Nordström's scalar theory ($\Box\Phi = 4\pi G T^\mu_\mu$, helicity $s = 0$), mass and
center-of-mass momentum conservation eliminate monopole and dipole radiation, spin-2
transverse-traceless $(+, \times)$ polarization modes are identically absent ($\kappa_{\mathrm{scalar}} = 0$),
and the residual breathing-mode virial trace quadrupole carries fraction $\kappa_{\mathrm{scalar}}$
($\kappa_{\mathrm{scalar}} = 1/6$ for the isotropic trace quadrupole):
$$P_{\mathrm{GW}}^{\mathrm{scalar}}(\kappa_{\mathrm{scalar}}) = \kappa_{\mathrm{scalar}}\,P_{\mathrm{GW}}^{\mathrm{PM}}(G, m_1, m_2, c).$$ -/
@[blueprint "def:signals-qed-nordstrom-scalar-gw-luminosity"
  (title := "Nordström (1913) spin-0 scalar gravitational-wave luminosity")
  (statement := /-- For \texttt{orb : PlanetaryOrbit}, $(G,m_1,m_2,c)$, and scalar trace-quadrupole
    efficiency $\kappa_{\mathrm{scalar}}$, define
    $P_{\mathrm{GW}}^{\mathrm{scalar}}(\kappa_{\mathrm{scalar}}) = \kappa_{\mathrm{scalar}}\,P_{\mathrm{GW}}^{\mathrm{PM}}(G,m_1,m_2,c)$. -/)]
noncomputable def PlanetaryOrbit.nordstromScalarGWLuminosity
    (orb : PlanetaryOrbit) (G m1 m2 c kappaScalar : ℝ) : ℝ :=
  kappaScalar * orb.petersMathewsLuminosityPM G m1 m2 c

/-- **Einstein's General Relativity (1916 / 1918) & Peters–Mathews (1963) 2.5PN Quadrupole Gravitational-Wave Luminosity**:
In Einstein's linearized weak-field quadrupole radiation formula (`Einstein 1916b`, `Einstein 1918`)
extended to eccentric Keplerian binaries at 2.5PN ($O(G^3/c^5)$) by Peters and Mathews (`1963`),
transverse-traceless spin-2 modes $(h_+, h_\times)$ radiate with PPN quadrupole efficiency
$\kappa_{\mathrm{quad}}$ ($\kappa_{\mathrm{quad}} = 1$ in GR):
$$P_{\mathrm{GW}}^{\mathrm{EGR}}(\kappa_{\mathrm{quad}}) = \kappa_{\mathrm{quad}}\,P_{\mathrm{GW}}^{\mathrm{PM}}(G, m_1, m_2, c),
\qquad P_{\mathrm{GW}}^{\mathrm{EGR}}(1) = \frac{32}{5}\frac{G^4 m_1^2 m_2^2(m_1 + m_2)}{c^5 a^5}\,f_{\mathrm{PM}}(e).$$ -/
@[blueprint "def:signals-qed-einstein-gr-gw-luminosity"
  (title := "Einstein General Relativity (1916/1918) and Peters-Mathews (1963) 2.5PN quadrupole GW luminosity")
  (statement := /-- For \texttt{orb : PlanetaryOrbit}, $(G,m_1,m_2,c)$, and PPN quadrupole
    efficiency $\kappa_{\mathrm{quad}}$, define
    $P_{\mathrm{GW}}^{\mathrm{EGR}}(\kappa_{\mathrm{quad}}) = \kappa_{\mathrm{quad}}\,P_{\mathrm{GW}}^{\mathrm{PM}}(G,m_1,m_2,c)$. -/)]
noncomputable def PlanetaryOrbit.einsteinGeneralRelativityGWLuminosity
    (orb : PlanetaryOrbit) (G m1 m2 c kappaQuad : ℝ) : ℝ :=
  kappaQuad * orb.petersMathewsLuminosityPM G m1 m2 c

/-- **Special-Relativistic Spin-1 Vector / Un-Doubled Larmor Gravitational-Wave Luminosity**:
For a spin-1 vector field $A_\mu$ with universal charge-to-mass ratio $q_i / m_i = \sqrt{G}$,
the electric dipole moment $\mathbf{d} = \sqrt{G} M_{\mathrm{tot}}\mathbf{R}_{\mathrm{CM}}$ has
$\ddot{\mathbf{d}} = \mathbf{0}$ by center-of-mass momentum conservation ($\Delta_{\mathrm{dip}} = 0$),
spin-2 $(+, \times)$ tensor modes are absent ($\kappa_{\mathrm{vec}} = 0$ in TT channels), and the
helicity-$\pm 1$ vector quadrupole carries only $\kappa_{\mathrm{vec}} = 1/4$ of the spin-2
tensor quadrupole flux:
$$P_{\mathrm{GW}}^{\mathrm{vector}}(\kappa_{\mathrm{vec}}, \Delta_{\mathrm{dip}})
  = \kappa_{\mathrm{vec}}\,P_{\mathrm{GW}}^{\mathrm{PM}}(G, m_1, m_2, c) + \Delta_{\mathrm{dip}}.$$ -/
@[blueprint "def:signals-qed-spin-one-vector-gw-luminosity"
  (title := "Special-relativistic spin-1 vector / un-doubled Larmor GW luminosity")
  (statement := /-- For \texttt{orb : PlanetaryOrbit}, $(G,m_1,m_2,c)$, vector quadrupole
    ratio $\kappa_{\mathrm{vec}}$, and dipole-violation flux $\Delta_{\mathrm{dip}}$, define
    $P_{\mathrm{GW}}^{\mathrm{vector}}(\kappa_{\mathrm{vec}},\Delta_{\mathrm{dip}})
    = \kappa_{\mathrm{vec}}\,P_{\mathrm{GW}}^{\mathrm{PM}}(G,m_1,m_2,c) + \Delta_{\mathrm{dip}}$. -/)]
noncomputable def PlanetaryOrbit.spinOneVectorGWLuminosity
    (orb : PlanetaryOrbit) (G m1 m2 c kappaVec deltaDipole : ℝ) : ℝ :=
  kappaVec * orb.petersMathewsLuminosityPM G m1 m2 c + deltaDipole

/-- **Witten (2004) / Berkovits–Witten (2004) Twistor-String Conformal Supergravity (Weyl $C_{\mu\nu\rho\sigma}^2$) Gravitational-Wave Luminosity**:
In 4th-order Weyl conformal supergravity ($S \propto \int d^4x\sqrt{-g}\,C_{\mu\nu\rho\sigma}^2$,
$\Box^2 h_{\mu\nu} = 0$), the $1/q^4$ propagator decomposes into a massless spin-2 mode weighted
by $\beta_{\mathrm{scale}}$ minus a negative-norm Ostrogradsky spin-2 ghost carrying negative
energy flux $-\delta P_{\mathrm{ghost}}$:
$$P_{\mathrm{GW}}^{\mathrm{Weyl}}(\beta_{\mathrm{scale}}, \delta P_{\mathrm{ghost}})
  = \beta_{\mathrm{scale}}\,P_{\mathrm{GW}}^{\mathrm{PM}}(G, m_1, m_2, c) - \delta P_{\mathrm{ghost}}.$$ -/
@[blueprint "def:signals-qed-witten-conformal-twistor-gw-luminosity"
  (title := "Witten (2004) twistor-string conformal supergravity (Weyl C² ghost) GW luminosity")
  (statement := /-- For \texttt{orb : PlanetaryOrbit}, $(G,m_1,m_2,c)$, scale factor
    $\beta_{\mathrm{scale}}$, and negative-norm Weyl ghost flux $\delta P_{\mathrm{ghost}}$, define
    $P_{\mathrm{GW}}^{\mathrm{Weyl}}(\beta_{\mathrm{scale}},\delta P_{\mathrm{ghost}})
    = \beta_{\mathrm{scale}}\,P_{\mathrm{GW}}^{\mathrm{PM}}(G,m_1,m_2,c) - \delta P_{\mathrm{ghost}}$. -/)]
noncomputable def PlanetaryOrbit.wittenConformalTwistorGWLuminosity
    (orb : PlanetaryOrbit) (G m1 m2 c betaScale deltaGhost : ℝ) : ℝ :=
  betaScale * orb.petersMathewsLuminosityPM G m1 m2 c - deltaGhost

/-- **Fedi (2016) Superfluid Quantum Gravity (`hal-01248015v3`/`v4`) Gravitational-Wave Luminosity**:
In Fedi's 2016 scalar BEC sink-flow model, a pure inviscid irrotational condensate ($\kappa_{\mathrm{trans}} = 0$)
supports only longitudinal compressional sound waves (zero shear modulus $\mu_{\mathrm{shear}} = 0$),
so transverse-traceless $(+, \times)$ spin-2 radiation vanishes ($100\%$ error on TT polarization).
With vortex-lattice transverse elasticity $\kappa_{\mathrm{trans}}$ and GPE core Bogm-dispersion
flux correction $\delta P_{\mathrm{GPE}}$:
$$P_{\mathrm{GW}}^{\mathrm{SQG,2016}}(\kappa_{\mathrm{trans}}, \delta P_{\mathrm{GPE}})
  = \kappa_{\mathrm{trans}}\,P_{\mathrm{GW}}^{\mathrm{PM}}(G, m_1, m_2, c) + \delta P_{\mathrm{GPE}}.$$ -/
@[blueprint "def:signals-qed-fedi-sqg-2016-gw-luminosity"
  (title := "Fedi (2016) Superfluid Quantum Gravity (SQG acoustic vs. vortex-lattice) GW luminosity")
  (statement := /-- For \texttt{orb : PlanetaryOrbit}, $(G,m_1,m_2,c)$, transverse shear-mode
    coupling $\kappa_{\mathrm{trans}}$, and GPE dispersion flux residual $\delta P_{\mathrm{GPE}}$,
    define $P_{\mathrm{GW}}^{\mathrm{SQG,2016}}(\kappa_{\mathrm{trans}},\delta P_{\mathrm{GPE}})
    = \kappa_{\mathrm{trans}}\,P_{\mathrm{GW}}^{\mathrm{PM}}(G,m_1,m_2,c) + \delta P_{\mathrm{GPE}}$. -/)]
noncomputable def PlanetaryOrbit.fediSQG2016GWLuminosity
    (orb : PlanetaryOrbit) (G m1 m2 c kappaTrans deltaGPEFlux : ℝ) : ℝ :=
  kappaTrans * orb.petersMathewsLuminosityPM G m1 m2 c + deltaGPEFlux

/-- **Fedi (2017) "Hydrodynamics of the Dark Superfluid" Gravitational-Wave Luminosity**:
In Fedi's 2017 dilatant dark-superfluid model ($\eta_{\mathrm{eff}}(v) \propto \gamma(v) - 1$)
with dilatant quadrupole coupling $\lambda_\gamma$ and baseline dissipative Stokes-drag power
$P_{\mathrm{Stokes}} \ge 0$:
$$P_{\mathrm{GW}}^{\mathrm{dark,2017}}(\lambda_\gamma, P_{\mathrm{Stokes}})
  = \lambda_\gamma\,P_{\mathrm{GW}}^{\mathrm{PM}}(G, m_1, m_2, c) + P_{\mathrm{Stokes}}.$$ -/
@[blueprint "def:signals-qed-fedi-dark-superfluid-2017-gw-luminosity"
  (title := "Fedi (2017) Hydrodynamics of the dark superfluid GW and Stokes-dissipation luminosity")
  (statement := /-- For \texttt{orb : PlanetaryOrbit}, $(G,m_1,m_2,c)$, dilatant coupling
    $\lambda_\gamma$, and baseline Stokes-drag power $P_{\mathrm{Stokes}}$, define
    $P_{\mathrm{GW}}^{\mathrm{dark,2017}}(\lambda_\gamma,P_{\mathrm{Stokes}})
    = \lambda_\gamma\,P_{\mathrm{GW}}^{\mathrm{PM}}(G,m_1,m_2,c) + P_{\mathrm{Stokes}}$. -/)]
noncomputable def PlanetaryOrbit.fediDarkSuperfluid2017GWLuminosity
    (orb : PlanetaryOrbit) (G m1 m2 c lambdaGamma powerStokes : ℝ) : ℝ :=
  lambdaGamma * orb.petersMathewsLuminosityPM G m1 m2 c + powerStokes

/-- **Cachazo–Skinner (2012) Infinity-Twistor Broken Twistor-String Gravitational-Wave Luminosity**:
In the Cachazo–Skinner twistor-string formulation (`arXiv:1207.0741`), the rank-2 infinity
twistor $I_{AB}$ with projection fidelity $\pi_I \in [0, 1]$ projects out the negative-norm
Weyl conformal ghost flux $-\delta P_{\mathrm{ghost}}$ by $(1 - \pi_I)$ while retaining the
spin-2 reduced Hodges double-copy quadrupole flux weighted by $\pi_I$ plus the cosmological-constant
de Sitter radiative correction $\delta P_\Lambda$:
$$P_{\mathrm{GW}}^{\mathrm{CS}}(\pi_I, \delta P_{\mathrm{ghost}}, \delta P_\Lambda)
  = \pi_I\,P_{\mathrm{GW}}^{\mathrm{PM}}(G, m_1, m_2, c)
  - (1 - \pi_I)\,\delta P_{\mathrm{ghost}} + \delta P_\Lambda.$$ -/
@[blueprint "def:signals-qed-cachazo-skinner-twistor-gw-luminosity"
  (title := "Cachazo-Skinner (2012) infinity-twistor broken twistor-string GW luminosity")
  (statement := /-- For \texttt{orb : PlanetaryOrbit}, $(G,m_1,m_2,c)$, infinity-twistor
    projection fidelity $\pi_I$, Weyl ghost flux $\delta P_{\mathrm{ghost}}$, and de Sitter
    flux shift $\delta P_\Lambda$, define
    $P_{\mathrm{GW}}^{\mathrm{CS}}(\pi_I,\delta P_{\mathrm{ghost}},\delta P_\Lambda)
    = \pi_I\,P_{\mathrm{GW}}^{\mathrm{PM}}(G,m_1,m_2,c) - (1-\pi_I)\,\delta P_{\mathrm{ghost}} + \delta P_\Lambda$. -/)]
noncomputable def PlanetaryOrbit.cachazoSkinnerTwistorGWLuminosity
    (orb : PlanetaryOrbit) (G m1 m2 c piInfinity deltaGhost deltaLambdaFlux : ℝ) : ℝ :=
  piInfinity * orb.petersMathewsLuminosityPM G m1 m2 c -
    (1 - piInfinity) * deltaGhost + deltaLambdaFlux

/-- **Partanen and Tulkki (2025) Four-$\mathrm{U}(1)$ Gauge Gravity + 2.5PN Post-Minkowskian QFT Gravitational-Wave Luminosity (Without $Gr_{\mathbb{C}}(2,4)$)**:
In Partanen and Tulkki's flat-space $\mathrm{U}(1)^4$ gauge gravity (`arXiv:2310.01460`,
*Rep. Prog. Phys.* 88, 057802; cf. Bjerrum-Bohr et al. 2018), the 2.5PN radiative quadrupole
power over flat Minkowski space equals the Peters–Mathews luminosity
$$P_{\mathrm{GW}}^{\mathrm{PT,2025}}(G, m_1, m_2, c) = P_{\mathrm{GW}}^{\mathrm{PM}}(G, m_1, m_2, c)$$
without $Gr_{\mathbb{C}}(2,4)$ Plücker twistor coordinates ($\varepsilon_{\mathrm{rel}} = 0$). -/
@[blueprint "def:signals-qed-partanen-tulkki-2025-gw-luminosity"
  (title := "Partanen & Tulkki (2025) 2.5PN post-Minkowskian QFT GW luminosity (without Gr_C(2,4))")
  (statement := /-- For \texttt{orb : PlanetaryOrbit} and $(G,m_1,m_2,c)$, define
    $P_{\mathrm{GW}}^{\mathrm{PT,2025}}(G,m_1,m_2,c) = P_{\mathrm{GW}}^{\mathrm{PM}}(G,m_1,m_2,c)$. -/)]
noncomputable def PlanetaryOrbit.partanenTulkki2025GWLuminosity
    (orb : PlanetaryOrbit) (G m1 m2 c : ℝ) : ℝ :=
  orb.petersMathewsLuminosityPM G m1 m2 c

/-- **Fedi (2026) Conservative Dilatant Dark Fluid (DDF, SSRN 7406660) Gravitational-Wave Luminosity (Without $Gr_{\mathbb{C}}(2,4)$)**:
In Marco Fedi's 2026 *Dilatant Dark Fluid* (SSRN 7406660), transverse shear waves propagate
through the jammed $\varphi$-phase lattice at $c = (\varrho_{\max}^\varphi j_{\min}^\varphi)^{-1/2}$
with zero baseline Stokes dissipation ($\lambda_\gamma = 1, P_{\mathrm{Stokes}} = 0$), yielding
the identical conservative 2.5PN quadrupole luminosity term as
`fediDarkSuperfluid2017GWLuminosity G_phi m1 m2 c 1 0` (and `RiverExterior.petersMathewsLuminosity`
in `Signals.DDF`):
$$P_{\mathrm{GW}}^{\mathrm{DDF,2026}}(G_\phi, m_1, m_2, c)
  = P_{\mathrm{GW}}^{\mathrm{dark,2017}}(G_\phi, m_1, m_2, c, 1, 0)
  = P_{\mathrm{GW}}^{\mathrm{PM}}(G_\phi, m_1, m_2, c)$$
without $Gr_{\mathbb{C}}(2,4)$ Plücker twistor coordinates ($\varepsilon_{\mathrm{rel}} = 0$). -/
@[blueprint "def:signals-qed-fedi-ddf-2026-gw-luminosity"
  (title := "Fedi (2026) conservative Dilatant Dark Fluid (DDF) GW luminosity (without Gr_C(2,4))")
  (statement := /-- For \texttt{orb : PlanetaryOrbit} and $(G_\phi,m_1,m_2,c)$, define
    $P_{\mathrm{GW}}^{\mathrm{DDF,2026}}(G_\phi,m_1,m_2,c)
    = \mathrm{orb}.\mathrm{fediDarkSuperfluid2017GWLuminosity}(G_\phi,m_1,m_2,c,1,0)$. -/)]
noncomputable def PlanetaryOrbit.fediDDF2026GWLuminosity
    (orb : PlanetaryOrbit) (G_phi m1 m2 c : ℝ) : ℝ :=
  orb.fediDarkSuperfluid2017GWLuminosity G_phi m1 m2 c 1 0

/-- **Turner (2026) Flat-Space $Gr_{\mathbb{C}}(2,4)$ BCJ Double Copy + 2.5PN Post-Minkowskian QFT Gravitational-Wave Luminosity (`Signals.QEDGravity`)**:
Factors the 2.5PN Peters–Mathews quadrupole luminosity directly through the dynamic
$Gr_{\mathbb{C}}(2,4)$ quadrupole wave twistor matrix
$M_{\mathbb{C}}^{\mathrm{GW}} = \mathrm{orb}.\mathrm{gr24QuadrupoleWaveMatrix}\,\Phi_{\mathrm{orb}}\,\Delta\varpi \in Gr_{\mathbb{C}}(2,4)$
via the $-7/2$ power of its uncrossed Plücker channel product
$|w_A^{\mathbb{C}}(M_{\mathbb{C}}^{\mathrm{GW}})|^2\,|w_B^{\mathbb{C}}(M_{\mathbb{C}}^{\mathrm{GW}})|^2 = 1 - e^2 = p/a$:
$$P_{\mathrm{GW}}^{\mathrm{Turner,2026}}(G, m_1, m_2, c, \Phi_{\mathrm{orb}}, \Delta\varpi)
  = \frac{32}{5}\frac{G^4 m_1^2 m_2^2(m_1 + m_2)}{c^5 a^5}\,
    \frac{P_{\mathrm{PM}}(e)}{\bigl(\sqrt{|w_A^{\mathbb{C}}(M_{\mathbb{C}}^{\mathrm{GW}})|^2\,|w_B^{\mathbb{C}}(M_{\mathbb{C}}^{\mathrm{GW}})|^2}\bigr)^7}.$$ -/
@[blueprint "def:signals-qed-turner-gr24-gw-luminosity"
  (title := "Turner (2026) flat-space Gr_C(2,4) BCJ double-copy 2.5PN GW luminosity")
  (statement := /-- For \texttt{orb : PlanetaryOrbit} and $(G,m_1,m_2,c,\Phi_{\mathrm{orb}},\Delta\varpi)$
    with $M_{\mathbb C}^{\mathrm{GW}} = \mathrm{orb}.\mathrm{gr24QuadrupoleWaveMatrix}(\Phi_{\mathrm{orb}},\Delta\varpi)$,
    define $P_{\mathrm{GW}}^{\mathrm{Turner,2026}}(G,m_1,m_2,c,\Phi_{\mathrm{orb}},\Delta\varpi)
    = \frac{32}{5}\frac{G^4 m_1^2 m_2^2(m_1+m_2)}{c^5 a^5}
      \frac{P_{\mathrm{PM}}(e)}{(\sqrt{|w_A^{\mathbb C}(M_{\mathbb C}^{\mathrm{GW}})|^2|w_B^{\mathbb C}(M_{\mathbb C}^{\mathrm{GW}})|^2})^7}$. -/)]
noncomputable def PlanetaryOrbit.turnerGr24QEDGWLuminosity
    (orb : PlanetaryOrbit) (G m1 m2 c orbitalPhase deltaVarpi : ℝ) : ℝ :=
  let M_GW := orb.gr24QuadrupoleWaveMatrix orbitalPhase deltaVarpi
  (32 / 5 : ℝ) * G ^ 4 * m1 ^ 2 * m2 ^ 2 * (m1 + m2) /
    (c ^ 5 * orb.semiMajorAxis ^ 5) *
    (orb.petersMathewsPolynomial /
      (Real.sqrt
        (Complex.normSq (complexPluckerSinkAmplitudeA M_GW) *
          Complex.normSq (complexPluckerSinkAmplitudeB M_GW))) ^ 7)

/-- **Master Multi-Model Gravitational-Wave Luminosity & Relative Predictive Error Comparison Theorem**:
For any bound `orb : PlanetaryOrbit`, orbital phase $\Phi_{\mathrm{orb}}$, perihelion advance
$\Delta\varpi$, and positive physical parameters $G, m_1, m_2, c, \delta P_{\mathrm{ghost}}, \delta P_\Lambda, \delta P_{\mathrm{GPE}}, P_{\mathrm{Stokes}} > 0$,
let $P_{\mathrm{GW}}^{\mathrm{GR}} = \mathrm{orb}.\mathrm{petersMathewsLuminosityPM}\,G\,m_1\,m_2\,c$
be the reference 2.5PN Einstein–Peters–Mathews / $Gr_{\mathbb{C}}(2,4)$ double-copy quadrupole
gravitational-wave luminosity and $M_{\mathbb{C}}^{\mathrm{GW}} = \mathrm{orb}.\mathrm{gr24QuadrupoleWaveMatrix}\,\Phi_{\mathrm{orb}}\,\Delta\varpi$.
Then:
1. **Strict Positivity & Exact $Gr_{\mathbb{C}}(2,4)$ Plücker Product Factorization**:
   $$0 < P_{\mathrm{GW}}^{\mathrm{GR}}, \qquad
   (P_{\mathrm{GW}}^{\mathrm{GR}})^2 = \left(\frac{32}{5}\frac{G^4 m_1^2 m_2^2(m_1 + m_2)}{c^5 a^5}\right)^2
     \frac{P_{\mathrm{PM}}(e)^2}{\bigl(|w_A^{\mathbb{C}}(M_{\mathbb{C}}^{\mathrm{GW}})|^2\,|w_B^{\mathbb{C}}(M_{\mathbb{C}}^{\mathrm{GW}})|^2\bigr)^7},$$
2. **Partanen & Tulkki (2025) 2.5PN Post-Minkowskian QFT (Without $Gr_{\mathbb{C}}(2,4)$) & Turner (2026) $Gr_{\mathbb{C}}(2,4)$ Spin-2 Double Copy**:
   $$P_{\mathrm{GW}}^{\mathrm{PT,2025}} = P_{\mathrm{GW}}^{\mathrm{GR}}, \qquad
   \varepsilon_{\mathrm{rel}}(P_{\mathrm{GW}}^{\mathrm{PT,2025}}, P_{\mathrm{GW}}^{\mathrm{GR}}) = 0,$$
   $$P_{\mathrm{GW}}^{\mathrm{Turner,2026}}(G, m_1, m_2, c, \Phi_{\mathrm{orb}}, \Delta\varpi) = P_{\mathrm{GW}}^{\mathrm{GR}}, \qquad
   \varepsilon_{\mathrm{rel}}\bigl(P_{\mathrm{GW}}^{\mathrm{Turner,2026}}(G, m_1, m_2, c, \Phi_{\mathrm{orb}}, \Delta\varpi), P_{\mathrm{GW}}^{\mathrm{GR}}\bigr) = 0,$$
3. **Newtonian $1/r$ Instantaneous Gravity ($c \to \infty$, Zero Radiation)**:
   $$\varepsilon_{\mathrm{rel}}(P_{\mathrm{GW}}^{\mathrm{Newton}}, P_{\mathrm{GW}}^{\mathrm{GR}}) = 1 \quad (100\%\text{ relative error}),$$
4. **Nordström (1913) Spin-0 Relativistic Scalar Gravity**:
   - Transverse-traceless $(+, \times)$ spin-2 channel ($\kappa_{\mathrm{scalar}} = 0$):
     $$\varepsilon_{\mathrm{rel}}\bigl(P_{\mathrm{GW}}^{\mathrm{scalar}}(0), P_{\mathrm{GW}}^{\mathrm{GR}}\bigr) = 1 \quad (100\%\text{ relative error}),$$
   - Isotropic virial trace-quadrupole breathing mode ($\kappa_{\mathrm{scalar}} = 1/6$):
     $$\varepsilon_{\mathrm{rel}}\bigl(P_{\mathrm{GW}}^{\mathrm{scalar}}(1/6), P_{\mathrm{GW}}^{\mathrm{GR}}\bigr) = \frac{5}{6} \quad (\approx 83.33\%\text{ relative error}),$$
5. **Einstein's General Relativity (1916 / 1918) & Peters–Mathews (1963) 2.5PN Quadrupole ($\kappa_{\mathrm{quad}} = 1$)**:
   $$P_{\mathrm{GW}}^{\mathrm{EGR}}(1) = P_{\mathrm{GW}}^{\mathrm{GR}}, \qquad
   \varepsilon_{\mathrm{rel}}\bigl(P_{\mathrm{GW}}^{\mathrm{EGR}}(1), P_{\mathrm{GW}}^{\mathrm{GR}}\bigr) = 0 \quad (0\%\text{ relative error}),$$
6. **Special-Relativistic Spin-1 Vector / Un-Doubled Larmor Model**:
   - Transverse-traceless $(+, \times)$ spin-2 channel ($\kappa_{\mathrm{vec}} = 0, \Delta_{\mathrm{dip}} = 0$):
     $$\varepsilon_{\mathrm{rel}}\bigl(P_{\mathrm{GW}}^{\mathrm{vector}}(0, 0), P_{\mathrm{GW}}^{\mathrm{GR}}\bigr) = 1 \quad (100\%\text{ relative error}),$$
   - Universal-coupling spin-1 vector quadrupole ($\kappa_{\mathrm{vec}} = 1/4, \Delta_{\mathrm{dip}} = 0$):
     $$\varepsilon_{\mathrm{rel}}\bigl(P_{\mathrm{GW}}^{\mathrm{vector}}(1/4, 0), P_{\mathrm{GW}}^{\mathrm{GR}}\bigr) = \frac{3}{4} \quad (75\%\text{ relative error}),$$
7. **Witten (2004) / Berkovits–Witten (2004) Twistor-String Conformal Supergravity ($\mathcal{N}=4$ Weyl $C_{\mu\nu\rho\sigma}^2$)**:
   - Pure scale-free conformal limit ($\beta_{\mathrm{scale}} = 0, \delta P_{\mathrm{ghost}} = 0$):
     $$\varepsilon_{\mathrm{rel}}\bigl(P_{\mathrm{GW}}^{\mathrm{Weyl}}(0, 0), P_{\mathrm{GW}}^{\mathrm{GR}}\bigr) = 1 \quad (100\%\text{ relative error}),$$
   - With matched scale ($\beta_{\mathrm{scale}} = 1$) and negative-norm Ostrogradsky spin-2 ghost flux ($\delta P_{\mathrm{ghost}} > 0$):
     $$\varepsilon_{\mathrm{rel}}\bigl(P_{\mathrm{GW}}^{\mathrm{Weyl}}(1, \delta P_{\mathrm{ghost}}), P_{\mathrm{GW}}^{\mathrm{GR}}\bigr) = \frac{\delta P_{\mathrm{ghost}}}{P_{\mathrm{GW}}^{\mathrm{GR}}} > 0,$$
8. **Fedi (2016) Superfluid Quantum Gravity (`fediSQG2016GWLuminosity`)**:
   - Pure longitudinal inviscid BEC sink flow ($\kappa_{\mathrm{trans}} = 0, \delta P_{\mathrm{GPE}} = 0$):
     $$\varepsilon_{\mathrm{rel}}\bigl(P_{\mathrm{GW}}^{\mathrm{SQG,2016}}(0, 0), P_{\mathrm{GW}}^{\mathrm{GR}}\bigr) = 1 \quad (100\%\text{ relative error on } (+, \times)\text{ modes}),$$
   - With vortex-lattice transverse elasticity in the long-wavelength limit ($\kappa_{\mathrm{trans}} = 1, \delta P_{\mathrm{GPE}} = 0$):
     $$P_{\mathrm{GW}}^{\mathrm{SQG,2016}}(1, 0) = P_{\mathrm{GW}}^{\mathrm{GR}}, \qquad
     \varepsilon_{\mathrm{rel}}\bigl(P_{\mathrm{GW}}^{\mathrm{SQG,2016}}(1, 0), P_{\mathrm{GW}}^{\mathrm{GR}}\bigr) = 0,$$
   - With non-zero GPE core dispersion flux residual ($\kappa_{\mathrm{trans}} = 1, \delta P_{\mathrm{GPE}} > 0$):
     $$\varepsilon_{\mathrm{rel}}\bigl(P_{\mathrm{GW}}^{\mathrm{SQG,2016}}(1, \delta P_{\mathrm{GPE}}), P_{\mathrm{GW}}^{\mathrm{GR}}\bigr) = \frac{\delta P_{\mathrm{GPE}}}{P_{\mathrm{GW}}^{\mathrm{GR}}} > 0,$$
9. **Fedi (2017) "Hydrodynamics of the Dark Superfluid" (`fediDarkSuperfluid2017GWLuminosity`) & Fedi (2026) Conservative DDF (`fediDDF2026GWLuminosity`, Without $Gr_{\mathbb{C}}(2,4)$)**:
   - Conservative dilatant shear / DDF $\varphi$-lattice regime ($\lambda_\gamma = 1, P_{\mathrm{Stokes}} = 0$):
     $$P_{\mathrm{GW}}^{\mathrm{DDF,2026}} = P_{\mathrm{GW}}^{\mathrm{dark,2017}}(1, 0) = P_{\mathrm{GW}}^{\mathrm{GR}}, \qquad
     \varepsilon_{\mathrm{rel}}(P_{\mathrm{GW}}^{\mathrm{DDF,2026}}, P_{\mathrm{GW}}^{\mathrm{GR}}) = 0,$$
   - With non-zero baseline Stokes drag power ($\lambda_\gamma = 1, P_{\mathrm{Stokes}} > 0$):
     $$\varepsilon_{\mathrm{rel}}\bigl(P_{\mathrm{GW}}^{\mathrm{dark,2017}}(1, P_{\mathrm{Stokes}}), P_{\mathrm{GW}}^{\mathrm{GR}}\bigr) = \frac{P_{\mathrm{Stokes}}}{P_{\mathrm{GW}}^{\mathrm{GR}}} > 0,$$
10. **Cachazo–Skinner (2012) Infinity-Twistor Broken Twistor String (`cachazoSkinnerTwistorGWLuminosity`)**:
   - At flat-space infinity-twistor projection ($\pi_I = 1, \delta P_\Lambda = 0$), the negative-norm
     Weyl ghost flux is projected out identically for **all** $\delta P_{\mathrm{ghost}}$:
     $$P_{\mathrm{GW}}^{\mathrm{CS}}(1, \delta P_{\mathrm{ghost}}, 0) = P_{\mathrm{GW}}^{\mathrm{GR}}, \qquad
     \varepsilon_{\mathrm{rel}}\bigl(P_{\mathrm{GW}}^{\mathrm{CS}}(1, \delta P_{\mathrm{ghost}}, 0), P_{\mathrm{GW}}^{\mathrm{GR}}\bigr) = 0,$$
   - With non-zero cosmological-constant de Sitter flux correction ($\pi_I = 1, \delta P_\Lambda > 0$):
     $$\varepsilon_{\mathrm{rel}}\bigl(P_{\mathrm{GW}}^{\mathrm{CS}}(1, \delta P_{\mathrm{ghost}}, \delta P_\Lambda), P_{\mathrm{GW}}^{\mathrm{GR}}\bigr) = \frac{\delta P_\Lambda}{P_{\mathrm{GW}}^{\mathrm{GR}}} > 0,$$
   - In the unbroken conformal limit ($\pi_I = 0, \delta P_\Lambda = 0$), it reduces identically to
     Witten's conformal twistor-string GW luminosity $P_{\mathrm{GW}}^{\mathrm{Weyl}}(0, \delta P_{\mathrm{ghost}})$. -/
@[blueprint "thm:signals-qed-gw-models-relative-error-comparison"
  (title := "Multi-model gravitational-wave luminosity relative predictive error comparison: Einstein GR (1916/1918), Peters-Mathews (1963), Partanen-Tulkki 2025 QFT, Fedi 2026 DDF, Turner 2026 Gr_C(2,4), Cachazo-Skinner (2012), Fedi 2016 SQG, and Fedi 2017 dark superfluid vs. Witten conformal ghost, spin-1 vector (3/4), Nordström scalar (5/6), and Newtonian (1)")
  (statement := /-- For \texttt{orb : PlanetaryOrbit}, $\Phi_{\mathrm{orb}},\Delta\varpi\in\mathbb R$, and
    $G,m_1,m_2,c,\delta P_{\mathrm{ghost}},\delta P_\Lambda,\delta P_{\mathrm{GPE}},P_{\mathrm{Stokes}}>0$, let
    $P_{\mathrm{GW}}^{\mathrm{GR}} = \mathrm{orb}.\mathrm{petersMathewsLuminosityPM}(G,m_1,m_2,c)$ and
    $M_{\mathbb C}^{\mathrm{GW}} = \mathrm{orb}.\mathrm{gr24QuadrupoleWaveMatrix}(\Phi_{\mathrm{orb}},\Delta\varpi)$. Then:
    (1) $0 < P_{\mathrm{GW}}^{\mathrm{GR}}$ and
    $(P_{\mathrm{GW}}^{\mathrm{GR}})^2 = \bigl(\frac{32}{5}\frac{G^4 m_1^2 m_2^2(m_1+m_2)}{c^5 a^5}\bigr)^2 \frac{P_{\mathrm{PM}}(e)^2}{(|w_A^{\mathbb C}|^2|w_B^{\mathbb C}|^2)^7}$;
    (2) $\varepsilon_{\mathrm{rel}}(P_{\mathrm{GW}}^{\mathrm{GR}},P_{\mathrm{GW}}^{\mathrm{GR}})=0$;
    (3) $\varepsilon_{\mathrm{rel}}(P_{\mathrm{GW}}^{\mathrm{Newton}},P_{\mathrm{GW}}^{\mathrm{GR}})=1$;
    (4) $\varepsilon_{\mathrm{rel}}(P_{\mathrm{GW}}^{\mathrm{scalar}}(0),P_{\mathrm{GW}}^{\mathrm{GR}})=1$ and
    $\varepsilon_{\mathrm{rel}}(P_{\mathrm{GW}}^{\mathrm{scalar}}(1/6),P_{\mathrm{GW}}^{\mathrm{GR}})=5/6$;
    (5) $P_{\mathrm{GW}}^{\mathrm{EGR}}(1)=P_{\mathrm{GW}}^{\mathrm{GR}}$ and
    $\varepsilon_{\mathrm{rel}}(P_{\mathrm{GW}}^{\mathrm{EGR}}(1),P_{\mathrm{GW}}^{\mathrm{GR}})=0$;
    (6) $\varepsilon_{\mathrm{rel}}(P_{\mathrm{GW}}^{\mathrm{vector}}(0,0),P_{\mathrm{GW}}^{\mathrm{GR}})=1$ and
    $\varepsilon_{\mathrm{rel}}(P_{\mathrm{GW}}^{\mathrm{vector}}(1/4,0),P_{\mathrm{GW}}^{\mathrm{GR}})=3/4$;
    (7) $\varepsilon_{\mathrm{rel}}(P_{\mathrm{GW}}^{\mathrm{Weyl}}(0,0),P_{\mathrm{GW}}^{\mathrm{GR}})=1$ and
    $\varepsilon_{\mathrm{rel}}(P_{\mathrm{GW}}^{\mathrm{Weyl}}(1,\delta P_{\mathrm{ghost}}),P_{\mathrm{GW}}^{\mathrm{GR}})
    = \delta P_{\mathrm{ghost}}/P_{\mathrm{GW}}^{\mathrm{GR}} > 0$;
    (8) $\varepsilon_{\mathrm{rel}}(P_{\mathrm{GW}}^{\mathrm{SQG,2016}}(0,0),P_{\mathrm{GW}}^{\mathrm{GR}})=1$,
    $P_{\mathrm{GW}}^{\mathrm{SQG,2016}}(1,0)=P_{\mathrm{GW}}^{\mathrm{GR}}$,
    $\varepsilon_{\mathrm{rel}}(P_{\mathrm{GW}}^{\mathrm{SQG,2016}}(1,0),P_{\mathrm{GW}}^{\mathrm{GR}})=0$, and
    $\varepsilon_{\mathrm{rel}}(P_{\mathrm{GW}}^{\mathrm{SQG,2016}}(1,\delta P_{\mathrm{GPE}}),P_{\mathrm{GW}}^{\mathrm{GR}})
    = \delta P_{\mathrm{GPE}}/P_{\mathrm{GW}}^{\mathrm{GR}} > 0$;
    (9) $P_{\mathrm{GW}}^{\mathrm{dark,2017}}(1,0)=P_{\mathrm{GW}}^{\mathrm{GR}}$,
    $\varepsilon_{\mathrm{rel}}(P_{\mathrm{GW}}^{\mathrm{dark,2017}}(1,0),P_{\mathrm{GW}}^{\mathrm{GR}})=0$, and
    $\varepsilon_{\mathrm{rel}}(P_{\mathrm{GW}}^{\mathrm{dark,2017}}(1,P_{\mathrm{Stokes}}),P_{\mathrm{GW}}^{\mathrm{GR}})
    = P_{\mathrm{Stokes}}/P_{\mathrm{GW}}^{\mathrm{GR}} > 0$;
    (10) $P_{\mathrm{GW}}^{\mathrm{CS}}(1,\delta P_{\mathrm{ghost}},0)=P_{\mathrm{GW}}^{\mathrm{GR}}$,
    $\varepsilon_{\mathrm{rel}}(P_{\mathrm{GW}}^{\mathrm{CS}}(1,\delta P_{\mathrm{ghost}},0),P_{\mathrm{GW}}^{\mathrm{GR}})=0$,
    $\varepsilon_{\mathrm{rel}}(P_{\mathrm{GW}}^{\mathrm{CS}}(1,\delta P_{\mathrm{ghost}},\delta P_\Lambda),P_{\mathrm{GW}}^{\mathrm{GR}})
    = \delta P_\Lambda/P_{\mathrm{GW}}^{\mathrm{GR}} > 0$, and
    $P_{\mathrm{GW}}^{\mathrm{CS}}(0,\delta P_{\mathrm{ghost}},0)=P_{\mathrm{GW}}^{\mathrm{Weyl}}(0,\delta P_{\mathrm{ghost}})$;
    (11) $P_{\mathrm{GW}}^{\mathrm{PT,2025}}(G,m_1,m_2,c)=P_{\mathrm{GW}}^{\mathrm{GR}}$,
    $\varepsilon_{\mathrm{rel}}(P_{\mathrm{GW}}^{\mathrm{PT,2025}}(G,m_1,m_2,c),P_{\mathrm{GW}}^{\mathrm{GR}})=0$,
    $P_{\mathrm{GW}}^{\mathrm{DDF,2026}}(G,m_1,m_2,c)=P_{\mathrm{GW}}^{\mathrm{GR}}$,
    $\varepsilon_{\mathrm{rel}}(P_{\mathrm{GW}}^{\mathrm{DDF,2026}}(G,m_1,m_2,c),P_{\mathrm{GW}}^{\mathrm{GR}})=0$,
    $P_{\mathrm{GW}}^{\mathrm{Turner,2026}}(G,m_1,m_2,c,\Phi_{\mathrm{orb}},\Delta\varpi)=P_{\mathrm{GW}}^{\mathrm{GR}}$, and
    $\varepsilon_{\mathrm{rel}}(P_{\mathrm{GW}}^{\mathrm{Turner,2026}}(G,m_1,m_2,c,\Phi_{\mathrm{orb}},\Delta\varpi),P_{\mathrm{GW}}^{\mathrm{GR}})=0$. -/)
  (proof := /-- Establish $0 < P_{\mathrm{GW}}^{\mathrm{GR}}$ and the $Gr_{\mathbb C}(2,4)$ Plücker
    factorization from \texttt{qed\_gravitational\_wave\_without\_ddf\_identities}, then evaluate each
    \texttt{relativePredictiveError} ratio over $P_{\mathrm{GW}}^{\mathrm{GR}} > 0$. -/)]
theorem PlanetaryOrbit.gravitational_wave_models_relative_predictive_error_comparison
    (orb : PlanetaryOrbit)
    (orbitalPhase deltaVarpi G m1 m2 c deltaGhost deltaLambdaFlux deltaGPEFlux powerStokes : ℝ)
    (hG : 0 < G) (hm1 : 0 < m1) (hm2 : 0 < m2) (hc : 0 < c)
    (hGhost : 0 < deltaGhost) (hLambda : 0 < deltaLambdaFlux)
    (hGPE : 0 < deltaGPEFlux) (hStokes : 0 < powerStokes) :
    let P_GR := orb.petersMathewsLuminosityPM G m1 m2 c
    let M_GW := orb.gr24QuadrupoleWaveMatrix orbitalPhase deltaVarpi
    0 < P_GR ∧
      P_GR ^ 2 =
        ((32 / 5 : ℝ) * G ^ 4 * m1 ^ 2 * m2 ^ 2 * (m1 + m2) /
          (c ^ 5 * orb.semiMajorAxis ^ 5)) ^ 2 *
          (orb.petersMathewsPolynomial ^ 2 /
            (Complex.normSq (complexPluckerSinkAmplitudeA M_GW) *
              Complex.normSq (complexPluckerSinkAmplitudeB M_GW)) ^ 7) ∧
      relativePredictiveError P_GR P_GR = 0 ∧
      relativePredictiveError orb.newtonianGWLuminosity P_GR = 1 ∧
      relativePredictiveError (orb.nordstromScalarGWLuminosity G m1 m2 c 0) P_GR = 1 ∧
      relativePredictiveError (orb.nordstromScalarGWLuminosity G m1 m2 c (1 / 6)) P_GR = 5 / 6 ∧
      orb.einsteinGeneralRelativityGWLuminosity G m1 m2 c 1 = P_GR ∧
      relativePredictiveError (orb.einsteinGeneralRelativityGWLuminosity G m1 m2 c 1) P_GR = 0 ∧
      relativePredictiveError (orb.spinOneVectorGWLuminosity G m1 m2 c 0 0) P_GR = 1 ∧
      relativePredictiveError (orb.spinOneVectorGWLuminosity G m1 m2 c (1 / 4) 0) P_GR = 3 / 4 ∧
      relativePredictiveError (orb.wittenConformalTwistorGWLuminosity G m1 m2 c 0 0) P_GR = 1 ∧
      relativePredictiveError
        (orb.wittenConformalTwistorGWLuminosity G m1 m2 c 1 deltaGhost) P_GR =
        deltaGhost / P_GR ∧
      0 < relativePredictiveError
        (orb.wittenConformalTwistorGWLuminosity G m1 m2 c 1 deltaGhost) P_GR ∧
      relativePredictiveError (orb.fediSQG2016GWLuminosity G m1 m2 c 0 0) P_GR = 1 ∧
      orb.fediSQG2016GWLuminosity G m1 m2 c 1 0 = P_GR ∧
      relativePredictiveError (orb.fediSQG2016GWLuminosity G m1 m2 c 1 0) P_GR = 0 ∧
      relativePredictiveError (orb.fediSQG2016GWLuminosity G m1 m2 c 1 deltaGPEFlux) P_GR =
        deltaGPEFlux / P_GR ∧
      0 < relativePredictiveError (orb.fediSQG2016GWLuminosity G m1 m2 c 1 deltaGPEFlux) P_GR ∧
      orb.fediDarkSuperfluid2017GWLuminosity G m1 m2 c 1 0 = P_GR ∧
      relativePredictiveError (orb.fediDarkSuperfluid2017GWLuminosity G m1 m2 c 1 0) P_GR = 0 ∧
      relativePredictiveError (orb.fediDarkSuperfluid2017GWLuminosity G m1 m2 c 1 powerStokes) P_GR =
        powerStokes / P_GR ∧
      0 < relativePredictiveError
        (orb.fediDarkSuperfluid2017GWLuminosity G m1 m2 c 1 powerStokes) P_GR ∧
      orb.cachazoSkinnerTwistorGWLuminosity G m1 m2 c 1 deltaGhost 0 = P_GR ∧
      relativePredictiveError
        (orb.cachazoSkinnerTwistorGWLuminosity G m1 m2 c 1 deltaGhost 0) P_GR = 0 ∧
      relativePredictiveError
        (orb.cachazoSkinnerTwistorGWLuminosity G m1 m2 c 1 deltaGhost deltaLambdaFlux) P_GR =
        deltaLambdaFlux / P_GR ∧
      0 < relativePredictiveError
        (orb.cachazoSkinnerTwistorGWLuminosity G m1 m2 c 1 deltaGhost deltaLambdaFlux) P_GR ∧
      orb.cachazoSkinnerTwistorGWLuminosity G m1 m2 c 0 deltaGhost 0 =
        orb.wittenConformalTwistorGWLuminosity G m1 m2 c 0 deltaGhost ∧
      orb.partanenTulkki2025GWLuminosity G m1 m2 c = P_GR ∧
      relativePredictiveError (orb.partanenTulkki2025GWLuminosity G m1 m2 c) P_GR = 0 ∧
      orb.fediDDF2026GWLuminosity G m1 m2 c = P_GR ∧
      relativePredictiveError (orb.fediDDF2026GWLuminosity G m1 m2 c) P_GR = 0 ∧
      orb.turnerGr24QEDGWLuminosity G m1 m2 c orbitalPhase deltaVarpi = P_GR ∧
      relativePredictiveError
        (orb.turnerGr24QEDGWLuminosity G m1 m2 c orbitalPhase deltaVarpi) P_GR = 0 := by
  intro P_GR M_GW
  have h_gw := orb.qed_gravitational_wave_without_ddf_identities
    orbitalPhase deltaVarpi 0 G m1 m2 c 1 hG hm1 hm2 hc zero_lt_one 1 1 1 1
  have h_pgr_pos : 0 < P_GR := h_gw.2.2.2.2.2.2.2.2.2.2.2.2.2.1
  have h_pgr_ne : P_GR ≠ 0 := ne_of_gt h_pgr_pos
  have h_abs_pgr : |P_GR| = P_GR := abs_of_pos h_pgr_pos
  have h_fac_sq :
      orb.petersMathewsFactor ^ 2 =
        orb.petersMathewsPolynomial ^ 2 /
          (Complex.normSq (complexPluckerSinkAmplitudeA M_GW) *
            Complex.normSq (complexPluckerSinkAmplitudeB M_GW)) ^ 7 :=
    h_gw.2.2.2.2.2.2.2.2.2.2.2.2.1
  have h_pgr_plucker :
      P_GR ^ 2 =
        ((32 / 5 : ℝ) * G ^ 4 * m1 ^ 2 * m2 ^ 2 * (m1 + m2) /
          (c ^ 5 * orb.semiMajorAxis ^ 5)) ^ 2 *
          (orb.petersMathewsPolynomial ^ 2 /
            (Complex.normSq (complexPluckerSinkAmplitudeA M_GW) *
              Complex.normSq (complexPluckerSinkAmplitudeB M_GW)) ^ 7) := by
    dsimp [P_GR]
    unfold PlanetaryOrbit.petersMathewsLuminosityPM
    rw [mul_pow, h_fac_sq]
  have h_err_pm : relativePredictiveError P_GR P_GR = 0 := by
    simp [relativePredictiveError]
  have h_err_newt : relativePredictiveError orb.newtonianGWLuminosity P_GR = 1 := by
    unfold relativePredictiveError PlanetaryOrbit.newtonianGWLuminosity
    rw [zero_sub, abs_neg, h_abs_pgr, div_self h_pgr_ne]
  have h_err_scal0 :
      relativePredictiveError (orb.nordstromScalarGWLuminosity G m1 m2 c 0) P_GR = 1 := by
    unfold relativePredictiveError PlanetaryOrbit.nordstromScalarGWLuminosity
    change |(0 * P_GR - P_GR)| / |P_GR| = 1
    have h_simp : 0 * P_GR - P_GR = - P_GR := by ring
    rw [h_simp, abs_neg, h_abs_pgr, div_self h_pgr_ne]
  have h_err_scal16 :
      relativePredictiveError (orb.nordstromScalarGWLuminosity G m1 m2 c (1 / 6)) P_GR = 5 / 6 := by
    unfold relativePredictiveError PlanetaryOrbit.nordstromScalarGWLuminosity
    change |((1 / 6 : ℝ) * P_GR - P_GR)| / |P_GR| = 5 / 6
    have h_diff : (1 / 6 : ℝ) * P_GR - P_GR = - ((5 / 6 : ℝ) * P_GR) := by ring
    have h_pos56 : 0 < (5 / 6 : ℝ) * P_GR := by positivity
    rw [h_diff, abs_neg, abs_of_pos h_pos56, h_abs_pgr, mul_div_cancel_right₀ _ h_pgr_ne]
  have h_egr : orb.einsteinGeneralRelativityGWLuminosity G m1 m2 c 1 = P_GR := by
    unfold PlanetaryOrbit.einsteinGeneralRelativityGWLuminosity
    change 1 * P_GR = P_GR
    ring
  have h_err_egr :
      relativePredictiveError (orb.einsteinGeneralRelativityGWLuminosity G m1 m2 c 1) P_GR = 0 := by
    rw [h_egr, h_err_pm]
  have h_err_vec0 :
      relativePredictiveError (orb.spinOneVectorGWLuminosity G m1 m2 c 0 0) P_GR = 1 := by
    unfold relativePredictiveError PlanetaryOrbit.spinOneVectorGWLuminosity
    change |(0 * P_GR + 0 - P_GR)| / |P_GR| = 1
    have h_simp : 0 * P_GR + 0 - P_GR = - P_GR := by ring
    rw [h_simp, abs_neg, h_abs_pgr, div_self h_pgr_ne]
  have h_err_vec14 :
      relativePredictiveError (orb.spinOneVectorGWLuminosity G m1 m2 c (1 / 4) 0) P_GR = 3 / 4 := by
    unfold relativePredictiveError PlanetaryOrbit.spinOneVectorGWLuminosity
    change |((1 / 4 : ℝ) * P_GR + 0 - P_GR)| / |P_GR| = 3 / 4
    have h_diff : (1 / 4 : ℝ) * P_GR + 0 - P_GR = - ((3 / 4 : ℝ) * P_GR) := by ring
    have h_pos34 : 0 < (3 / 4 : ℝ) * P_GR := by positivity
    rw [h_diff, abs_neg, abs_of_pos h_pos34, h_abs_pgr, mul_div_cancel_right₀ _ h_pgr_ne]
  have h_err_weyl0 :
      relativePredictiveError (orb.wittenConformalTwistorGWLuminosity G m1 m2 c 0 0) P_GR = 1 := by
    unfold relativePredictiveError PlanetaryOrbit.wittenConformalTwistorGWLuminosity
    change |(0 * P_GR - 0 - P_GR)| / |P_GR| = 1
    have h_simp : 0 * P_GR - 0 - P_GR = - P_GR := by ring
    rw [h_simp, abs_neg, h_abs_pgr, div_self h_pgr_ne]
  have h_err_weyl1 :
      relativePredictiveError
        (orb.wittenConformalTwistorGWLuminosity G m1 m2 c 1 deltaGhost) P_GR =
        deltaGhost / P_GR := by
    unfold relativePredictiveError PlanetaryOrbit.wittenConformalTwistorGWLuminosity
    change |(1 * P_GR - deltaGhost - P_GR)| / |P_GR| = deltaGhost / P_GR
    have h_simp : 1 * P_GR - deltaGhost - P_GR = - deltaGhost := by ring
    rw [h_simp, abs_neg, abs_of_pos hGhost, h_abs_pgr]
  have h_err_weyl1_pos :
      0 < relativePredictiveError
        (orb.wittenConformalTwistorGWLuminosity G m1 m2 c 1 deltaGhost) P_GR := by
    rw [h_err_weyl1]
    positivity
  have h_err_sqg0 :
      relativePredictiveError (orb.fediSQG2016GWLuminosity G m1 m2 c 0 0) P_GR = 1 := by
    unfold relativePredictiveError PlanetaryOrbit.fediSQG2016GWLuminosity
    change |(0 * P_GR + 0 - P_GR)| / |P_GR| = 1
    have h_simp : 0 * P_GR + 0 - P_GR = - P_GR := by ring
    rw [h_simp, abs_neg, h_abs_pgr, div_self h_pgr_ne]
  have h_sqg10 : orb.fediSQG2016GWLuminosity G m1 m2 c 1 0 = P_GR := by
    unfold PlanetaryOrbit.fediSQG2016GWLuminosity
    change 1 * P_GR + 0 = P_GR
    ring
  have h_err_sqg10 :
      relativePredictiveError (orb.fediSQG2016GWLuminosity G m1 m2 c 1 0) P_GR = 0 := by
    rw [h_sqg10, h_err_pm]
  have h_err_sqg_gpe :
      relativePredictiveError (orb.fediSQG2016GWLuminosity G m1 m2 c 1 deltaGPEFlux) P_GR =
        deltaGPEFlux / P_GR := by
    unfold relativePredictiveError PlanetaryOrbit.fediSQG2016GWLuminosity
    change |(1 * P_GR + deltaGPEFlux - P_GR)| / |P_GR| = deltaGPEFlux / P_GR
    have h_simp : 1 * P_GR + deltaGPEFlux - P_GR = deltaGPEFlux := by ring
    rw [h_simp, abs_of_pos hGPE, h_abs_pgr]
  have h_err_sqg_gpe_pos :
      0 < relativePredictiveError (orb.fediSQG2016GWLuminosity G m1 m2 c 1 deltaGPEFlux) P_GR := by
    rw [h_err_sqg_gpe]
    positivity
  have h_dark10 : orb.fediDarkSuperfluid2017GWLuminosity G m1 m2 c 1 0 = P_GR := by
    unfold PlanetaryOrbit.fediDarkSuperfluid2017GWLuminosity
    change 1 * P_GR + 0 = P_GR
    ring
  have h_err_dark10 :
      relativePredictiveError (orb.fediDarkSuperfluid2017GWLuminosity G m1 m2 c 1 0) P_GR = 0 := by
    rw [h_dark10, h_err_pm]
  have h_err_dark_stokes :
      relativePredictiveError (orb.fediDarkSuperfluid2017GWLuminosity G m1 m2 c 1 powerStokes) P_GR =
        powerStokes / P_GR := by
    unfold relativePredictiveError PlanetaryOrbit.fediDarkSuperfluid2017GWLuminosity
    change |(1 * P_GR + powerStokes - P_GR)| / |P_GR| = powerStokes / P_GR
    have h_simp : 1 * P_GR + powerStokes - P_GR = powerStokes := by ring
    rw [h_simp, abs_of_pos hStokes, h_abs_pgr]
  have h_err_dark_stokes_pos :
      0 < relativePredictiveError
        (orb.fediDarkSuperfluid2017GWLuminosity G m1 m2 c 1 powerStokes) P_GR := by
    rw [h_err_dark_stokes]
    positivity
  have h_cs_flat : orb.cachazoSkinnerTwistorGWLuminosity G m1 m2 c 1 deltaGhost 0 = P_GR := by
    unfold PlanetaryOrbit.cachazoSkinnerTwistorGWLuminosity
    change 1 * P_GR - (1 - 1) * deltaGhost + 0 = P_GR
    ring
  have h_err_cs_flat :
      relativePredictiveError
        (orb.cachazoSkinnerTwistorGWLuminosity G m1 m2 c 1 deltaGhost 0) P_GR = 0 := by
    rw [h_cs_flat, h_err_pm]
  have h_err_cs_cc :
      relativePredictiveError
        (orb.cachazoSkinnerTwistorGWLuminosity G m1 m2 c 1 deltaGhost deltaLambdaFlux) P_GR =
        deltaLambdaFlux / P_GR := by
    unfold relativePredictiveError PlanetaryOrbit.cachazoSkinnerTwistorGWLuminosity
    change |(1 * P_GR - (1 - 1) * deltaGhost + deltaLambdaFlux - P_GR)| / |P_GR| =
      deltaLambdaFlux / P_GR
    have h_simp : 1 * P_GR - (1 - 1) * deltaGhost + deltaLambdaFlux - P_GR = deltaLambdaFlux := by
      ring
    rw [h_simp, abs_of_pos hLambda, h_abs_pgr]
  have h_err_cs_cc_pos :
      0 < relativePredictiveError
        (orb.cachazoSkinnerTwistorGWLuminosity G m1 m2 c 1 deltaGhost deltaLambdaFlux) P_GR := by
    rw [h_err_cs_cc]
    positivity
  have h_cs_unbroken :
      orb.cachazoSkinnerTwistorGWLuminosity G m1 m2 c 0 deltaGhost 0 =
        orb.wittenConformalTwistorGWLuminosity G m1 m2 c 0 deltaGhost := by
    unfold PlanetaryOrbit.cachazoSkinnerTwistorGWLuminosity
      PlanetaryOrbit.wittenConformalTwistorGWLuminosity
    ring
  have h_pt : orb.partanenTulkki2025GWLuminosity G m1 m2 c = P_GR := rfl
  have h_err_pt :
      relativePredictiveError (orb.partanenTulkki2025GWLuminosity G m1 m2 c) P_GR = 0 :=
    h_err_pm
  have h_ddf26 : orb.fediDDF2026GWLuminosity G m1 m2 c = P_GR := h_dark10
  have h_err_ddf26 :
      relativePredictiveError (orb.fediDDF2026GWLuminosity G m1 m2 c) P_GR = 0 :=
    h_err_dark10
  have ha_ne : orb.semiMajorAxis ≠ 0 := ne_of_gt orb.semiMajorAxis_pos
  have h_slr_div : orb.semiLatusRectum / orb.semiMajorAxis = 1 - orb.eccentricity ^ 2 := by
    unfold PlanetaryOrbit.semiLatusRectum
    exact mul_div_cancel_left₀ (1 - orb.eccentricity ^ 2) ha_ne
  have h_prod_eq :
      Complex.normSq (complexPluckerSinkAmplitudeA M_GW) *
        Complex.normSq (complexPluckerSinkAmplitudeB M_GW) =
        1 - orb.eccentricity ^ 2 := by
    rw [h_gw.2.2.2.2.2.2.1, h_slr_div]
  have h_turner :
      orb.turnerGr24QEDGWLuminosity G m1 m2 c orbitalPhase deltaVarpi = P_GR := by
    dsimp [P_GR, PlanetaryOrbit.turnerGr24QEDGWLuminosity,
      PlanetaryOrbit.petersMathewsLuminosityPM, PlanetaryOrbit.petersMathewsFactor]
    change (32 / 5 : ℝ) * G ^ 4 * m1 ^ 2 * m2 ^ 2 * (m1 + m2) /
      (c ^ 5 * orb.semiMajorAxis ^ 5) *
      (orb.petersMathewsPolynomial /
        (Real.sqrt
          (Complex.normSq (complexPluckerSinkAmplitudeA M_GW) *
            Complex.normSq (complexPluckerSinkAmplitudeB M_GW))) ^ 7) = _
    rw [h_prod_eq]
  have h_err_turner :
      relativePredictiveError
        (orb.turnerGr24QEDGWLuminosity G m1 m2 c orbitalPhase deltaVarpi) P_GR = 0 := by
    rw [h_turner, h_err_pm]
  exact ⟨h_pgr_pos, h_pgr_plucker, h_err_pm, h_err_newt, h_err_scal0, h_err_scal16,
    h_egr, h_err_egr, h_err_vec0, h_err_vec14, h_err_weyl0, h_err_weyl1, h_err_weyl1_pos,
    h_err_sqg0, h_sqg10, h_err_sqg10, h_err_sqg_gpe, h_err_sqg_gpe_pos,
    h_dark10, h_err_dark10, h_err_dark_stokes, h_err_dark_stokes_pos,
    h_cs_flat, h_err_cs_flat, h_err_cs_cc, h_err_cs_cc_pos, h_cs_unbroken,
    h_pt, h_err_pt, h_ddf26, h_err_ddf26, h_turner, h_err_turner⟩

end Signals.QEDGravity
