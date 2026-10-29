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

end Signals.QEDGravity
