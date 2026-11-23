import Architect
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic
import Mathlib.Basic.Real.Basic
import Mathlib.Tactic
import Signals.DDF
import Signals.DFT
import Signals.Huygens
import Signals.QuantumTrajectories
import Signals.SatoGrassmannian.AKNS
import Signals.SatoGrassmannian.DualSchubertQFIM
import Signals.SatoGrassmannian.HirotaKP
import Signals.Scattering

open scoped InnerProductSpace

namespace Signals.Photoelectric

noncomputable section

/-! # Photoelectric Effect Across `QCI-GXC` Kohn–Sham DFT, Twistor / Grassmannian Longitudinal $E_z$ & OAM Optics, Strong-Field Keldysh Tunneling, AKNS Solitons, and Dual-Schubert QFIM ($F_{\mu\nu} = 4\,g_{\mu\nu}^{\mathrm{FS}}$)

Formalizes the unified mathematical model of the photoelectric effect and its strongly driven,
nanoscale, and interferometric generalizations across:
1. **Einstein (1905) Stopping Kinetic Energy & Threshold vs. Classical Rayleigh Delay**:
   - `einsteinStoppingKineticEnergy`, `photoelectricThresholdFrequency`, and
     `classicalRayleighAccumulationDelay`: proves sharp cutoff below $\hbar\nu = \Phi_W$ regardless
     of intensity, linear stopping-potential slope $h$ above threshold, and why classical energy
     accumulation diverges as $1/I$ at dim illumination.
2. **`QCI-GXC` Grassmannian Kohn–Sham Work Function & McWeeny SIE Restoration**:
   - `kohnShamWorkFunction`, `mcweenyIdempotencyDefect`: links the surface work function
     $\Phi_W = E_{\mathrm{vac}} - E_F$ to self-consistent Kohn–Sham projectors on
     $\mathrm{Gr}_{\mathbb{C}}(N_\alpha, M)\times\mathrm{Gr}_{\mathbb{C}}(N_\beta, M)$ and
     McWeeny purification $3\lambda^2 - 2\lambda^3$ restoring exact integer idempotency ($\lambda \in \{0, 1\}$).
3. **3D Vectorial Longitudinal $E_z$, ENZ Boundary Amplification, & Spin-to-OAM Selection**:
   - Links `Signals.DDF.enzBoundaryIntensityEnhancement` ($400\times$ at $\varepsilon_{\mathrm{ENZ}} = 0.05$ vs.
     $100\%$ paraxial 2D Jones error on Debye–Wolf focal $E_z$), `Signals.DFT.samToOamLongitudinalTopologicalCharge`,
     `Signals.DFT.oamSuperpositionQfimPhi` ($F_{\varphi\varphi}^{\mathrm{OAM}} = 4\ell^2$), and
     gimbal-lock-free spinor polarization `Signals.DFT.poincareSphereQfimTheta = 1` vs.
     `Signals.DFT.eulerKinematicJacobianDet (±π/2) = 0`.
4. **Strong-Field Keldysh Photoemission, Ponderomotive Energy, ATI Peaks, & Channel-2/3 QFIM Tunneling Speed**:
   - `ponderomotiveEnergy`, `keldyshParameterSq`, `atiPhotoelectronPeakEnergy`,
     `keldyshBarrierDecayKappaSq`, and `keldyshTunnelingWidth`: reduces identically to Einstein's
     formula at $n = 1, s = 0, U_p = 0$, and bridges directly to Three-Channel Plücker–Madelung–QFIM
     tunneling (`Signals.QuantumTrajectories.evanescentOsmoticSpeed`,
     `Signals.SatoGrassmannian.DualSchubertQFIM.sharoglazova_klaers_evanescent_speed_law`), proving
     $100\%$ relative error in standard Bohmian velocity ($v_{\mathrm{Bohm}} = 0$) vs. $0\%$ error
     in the Plücker–Madelung–QFIM model!
5. **AKNS Focusing NLS Driver Solitons, Defocusing GPE Surface Kinks, & Two-Pathway `Gr_C(2,4)` / `QFIM` Interference**:
   - Connects `Signals.SatoGrassmannian.AKNS.brightSoliton_nls_pde` (driving laser envelope
     $A\operatorname{sech}(Ax)e^{i A^2 t}$ with peak ponderomotive enhancement $A^2$),
     `darkSoliton_gpe_pde` (surface depletion kink), and two-pathway ($\omega / 2\omega$) RABBITT
     interference (`twoPathwayPhotoemissionIntensity`, $0\%$ error vs. $50\%$ unphased
     $\mathrm{Gr}_{\ge 0}(2,4)$ error) with `QFIM` phase-variance splitting ($F_Q = 4 g_{\mathrm{FS}}$)
     and Attosecond Quantum Cramér–Rao timing bounds (`Signals.DFT.quantumCramerRaoVarianceBound`).
-/

/-! ## Section 1: Classical Wave Delay vs. Einstein (1905) Photoelectric Law & `QCI-GXC` Work Function -/

/-- **Einstein (1905) Maximum Photoelectron Kinetic Energy (`einsteinStoppingKineticEnergy`)**:
$$K_{\max}(h, \nu, \Phi_W) = \max(0,\, h\nu - \Phi_W).$$ -/
@[blueprint "def:signals-photoelectric-einstein-stopping-kinetic-energy"
  (title := "Einstein (1905) maximum photoelectron kinetic energy max(0, h nu - Phi_W)")
  (statement := /-- Define $\operatorname{einsteinStoppingKineticEnergy}(h, \nu, \Phi_W) = \max(0, h\nu - \Phi_W)$. -/)]
def einsteinStoppingKineticEnergy (h_planck nu phi_w : ℝ) : ℝ :=
  max 0 (h_planck * nu - phi_w)

/-- **Photoelectric Cutoff Threshold Frequency (`photoelectricThresholdFrequency`)**:
$$\nu_0(h, \Phi_W) = \frac{\Phi_W}{h}.$$ -/
@[blueprint "def:signals-photoelectric-threshold-frequency"
  (title := "Photoelectric cutoff threshold frequency Phi_W / h")
  (statement := /-- Define $\operatorname{photoelectricThresholdFrequency}(h, \Phi_W) = \Phi_W / h$. -/)]
def photoelectricThresholdFrequency (h_planck phi_w : ℝ) : ℝ :=
  phi_w / h_planck

/-- **Classical Rayleigh Continuous Wave Accumulation Delay (`classicalRayleighAccumulationDelay`)**:
$$\tau_{\mathrm{delay}}(\Phi_W, I, A_{\mathrm{atom}}) = \frac{\Phi_W}{I\,A_{\mathrm{atom}}}.$$ -/
@[blueprint "def:signals-photoelectric-classical-rayleigh-delay"
  (title := "Classical wave accumulation delay Phi_W / (I * A_atom)")
  (statement := /-- Define $\operatorname{classicalRayleighAccumulationDelay}(\Phi_W, I, A_{\mathrm{atom}}) = \Phi_W / (I A_{\mathrm{atom}})$. -/)]
def classicalRayleighAccumulationDelay (phi_w intensity area_atom : ℝ) : ℝ :=
  phi_w / (intensity * area_atom)

/-- **Kohn–Sham `QCI-GXC` Surface Work Function (`kohnShamWorkFunction`)**:
$$\Phi_W(E_{\mathrm{vac}}, E_F) = E_{\mathrm{vac}} - E_F.$$ -/
@[blueprint "def:signals-photoelectric-kohn-sham-work-function"
  (title := "QCI-GXC Kohn-Sham DFT work function E_vac - E_F")
  (statement := /-- Define $\operatorname{kohnShamWorkFunction}(E_{\mathrm{vac}}, E_F) = E_{\mathrm{vac}} - E_F$. -/)]
def kohnShamWorkFunction (e_vac e_fermi : ℝ) : ℝ :=
  e_vac - e_fermi

/-- **McWeeny Purification Idempotency Defect (`mcweenyIdempotencyDefect`)**:
$$\delta_{\mathrm{McWeeny}}(\lambda) = (3\lambda^2 - 2\lambda^3) - \lambda = -\lambda(\lambda - 1)(2\lambda - 1).$$ -/
@[blueprint "def:signals-photoelectric-mcweeny-idempotency-defect"
  (title := "McWeeny purification idempotency defect (3 lambda^2 - 2 lambda^3) - lambda")
  (statement := /-- Define $\operatorname{mcweenyIdempotencyDefect}(\lambda) = \operatorname{mcweenyPurificationPoly}(\lambda) - \lambda$. -/)]
def mcweenyIdempotencyDefect (lam : ℝ) : ℝ :=
  Signals.DFT.mcweenyPurificationPoly lam - lam

/-! ## Section 2: Strong-Field Keldysh Photoemission, Ponderomotive Shifts, ATI Peaks, & Channel-2/3 QFIM Tunneling -/

/-- **Quiver Ponderomotive Energy (`ponderomotiveEnergy`)**:
$$U_p(q, E_0, m_e, \omega) = \frac{q^2 E_0^2}{4 m_e \omega^2}.$$ -/
@[blueprint "def:signals-photoelectric-ponderomotive-energy"
  (title := "Strong-field quiver ponderomotive energy q^2 E_0^2 / (4 m_e omega^2)")
  (statement := /-- Define $\operatorname{ponderomotiveEnergy}(q, E_0, m_e, \omega) = q^2 E_0^2 / (4 m_e \omega^2)$. -/)]
def ponderomotiveEnergy (q_charge e0_amp mass_e omega : ℝ) : ℝ :=
  q_charge ^ 2 * e0_amp ^ 2 / (4 * mass_e * omega ^ 2)

/-- **Squared Keldysh Adiabaticity Parameter (`keldyshParameterSq`)**:
$$\gamma_K^2(\Phi_W, U_p) = \frac{\Phi_W}{2 U_p},$$
distinguishing multiphoton Einstein/ATI photoemission ($\gamma_K \gg 1$) from quasi-static
optical barrier tunneling ($\gamma_K \ll 1$). -/
@[blueprint "def:signals-photoelectric-keldysh-parameter-sq"
  (title := "Squared Keldysh adiabaticity parameter Phi_W / (2 U_p)")
  (statement := /-- Define $\operatorname{keldyshParameterSq}(\Phi_W, U_p) = \Phi_W / (2 U_p)$. -/)]
def keldyshParameterSq (phi_w up_pond : ℝ) : ℝ :=
  phi_w / (2 * up_pond)

/-- **Above-Threshold Ionization / Photoemission (`ATI`) Peak Energy (`atiPhotoelectronPeakEnergy`)**:
$$E_{n,s}(\hbar\omega, \Phi_W, U_p) = (n + s)\hbar\omega - (\Phi_W + U_p).$$ -/
@[blueprint "def:signals-photoelectric-ati-peak-energy"
  (title := "Above-threshold photoemission (ATI) peak energy (n + s) hbar omega - (Phi_W + U_p)")
  (statement := /-- Define $\operatorname{atiPhotoelectronPeakEnergy}(n, s, \hbar\omega, \Phi_W, U_p) = (n + s)\hbar\omega - (\Phi_W + U_p)$. -/)]
def atiPhotoelectronPeakEnergy (n_photons s_ati hbar_omega phi_w up_pond : ℝ) : ℝ :=
  (n_photons + s_ati) * hbar_omega - (phi_w + up_pond)

/-- **Keldysh Barrier Evanescent Decay Constant Squared (`keldyshBarrierDecayKappaSq`)**:
$$\kappa^2(m_e, \Phi_W, \hbar) = \frac{2 m_e \Phi_W}{\hbar^2}.$$ -/
@[blueprint "def:signals-photoelectric-keldysh-barrier-decay-kappa-sq"
  (title := "Keldysh work-function barrier decay wavenumber squared 2 m_e Phi_W / hbar^2")
  (statement := /-- Define $\operatorname{keldyshBarrierDecayKappaSq}(m_e, \Phi_W, \hbar) = 2 m_e \Phi_W / \hbar^2$. -/)]
def keldyshBarrierDecayKappaSq (mass_e phi_w hbar : ℝ) : ℝ :=
  2 * mass_e * phi_w / hbar ^ 2

/-- **Quasi-Static Triangular Tunneling Barrier Width (`keldyshTunnelingWidth`)**:
$$x_{\mathrm{turn}}(\Phi_W, q, E_0) = \frac{\Phi_W}{q E_0}.$$ -/
@[blueprint "def:signals-photoelectric-keldysh-tunneling-width"
  (title := "Quasi-static triangular tunneling barrier width Phi_W / (q E_0)")
  (statement := /-- Define $\operatorname{keldyshTunnelingWidth}(\Phi_W, q, E_0) = \Phi_W / (q E_0)$. -/)]
def keldyshTunnelingWidth (phi_w q_charge e0_amp : ℝ) : ℝ :=
  phi_w / (q_charge * e0_amp)

/-! ## Section 3: Soliton-Driven Ultrafast Photoemission & Two-Pathway `Gr_C(2,4)` / `QFIM` Interference -/

/-- **AKNS Focusing NLS Bright-Soliton Envelope Intensity Profile (`nlsBrightSolitonIntensity`)**:
$$I_{\mathrm{NLS}}(A, x) = |q(x, t)|^2 = \frac{A^2}{\cosh^2(A x)}.$$ -/
@[blueprint "def:signals-photoelectric-nls-bright-soliton-intensity"
  (title := "AKNS focusing NLS bright-soliton intensity profile A^2 / cosh^2(A x)")
  (statement := /-- Define $\operatorname{nlsBrightSolitonIntensity}(A, x) = A^2 / \cosh^2(A x)$. -/)]
def nlsBrightSolitonIntensity (amp x : ℝ) : ℝ :=
  amp ^ 2 / Real.cosh (amp * x) ^ 2

/-- **Two-Pathway ($\omega / 2\omega$ RABBITT) Coherent Photoemission Yield (`twoPathwayPhotoemissionIntensity`)**:
$$I_{\mathrm{coh}}(p_1, p_2, \Delta\phi) = p_1 + p_2 + 2\sqrt{p_1 p_2}\,\cos\Delta\phi.$$ -/
@[blueprint "def:signals-photoelectric-two-pathway-intensity"
  (title := "Two-pathway coherent photoemission yield p1 + p2 + 2 sqrt(p1 p2) cos(Delta phi)")
  (statement := /-- Define $\operatorname{twoPathwayPhotoemissionIntensity}(p_1, p_2, \Delta\phi) = p_1 + p_2 + 2\sqrt{p_1 p_2}\cos\Delta\phi$. -/)]
def twoPathwayPhotoemissionIntensity (p1 p2 dphi : ℝ) : ℝ :=
  p1 + p2 + 2 * Real.sqrt (p1 * p2) * Real.cos dphi

/-- **Unphased Positive-Grassmannian $\mathrm{Gr}_{\ge 0}(2,4)$ Two-Pathway Yield (`unphasedTwoPathwayIntensity`)**:
$$I_{\mathrm{unphased}}(p_1, p_2) = p_1 + p_2,$$
missing the coherent interference term and yielding a $50\%$ relative error at equal constructive pathways ($p_1 = p_2 > 0, \Delta\phi = 0$). -/
@[blueprint "def:signals-photoelectric-unphased-two-pathway-intensity"
  (title := "Unphased positive-Grassmannian two-pathway yield p1 + p2")
  (statement := /-- Define $\operatorname{unphasedTwoPathwayIntensity}(p_1, p_2) = p_1 + p_2$. -/)]
def unphasedTwoPathwayIntensity (p1 p2 : ℝ) : ℝ :=
  p1 + p2

/-- **Master Theorem (`photoelectric_unified_qci_gxc_twistor_akns_qfim_identities`)**:
Certifies in a single machine-checked package:
1. Einstein (1905) threshold cutoff ($\hbar\nu < \Phi_W \implies K_{\max} = 0$) and linear excess above
   threshold ($\Phi_W \le \hbar\nu \implies K_{\max} = \hbar\nu - \Phi_W$), plus exact $1/I$ growth
   of the classical Rayleigh delay at fixed $\Phi_W, A_{\mathrm{atom}}$;
2. `QCI-GXC` Kohn–Sham work function $\Phi_W = E_{\mathrm{vac}} - E_F$ and McWeeny purification
   restoring exact idempotency at $\lambda \in \{0, 1\}$ while driving $\lambda = 1/2 \mapsto 1/2$ and
   reducing half-occupancy defect;
3. High-NA / ENZ longitudinal surface gain (`enzBoundaryIntensityEnhancement 1 (1/20) = 400`, vs.
   $100\%$ paraxial 2D Jones error), spin-to-OAM angular momentum conservation
   (`samToOamLongitudinalTopologicalCharge`), $4\ell^2$ OAM angular QFIM super-resolution, and
   gimbal-lock-free spinor `QFIM` (`poincareSphereQfimTheta = 1` vs. `eulerKinematicJacobianDet (±π/2) = 0`);
4. Strong-field Keldysh identity $\gamma_K^2 = \frac{\omega^2 (2 m_e \Phi_W)}{q^2 E_0^2}$,
   exact $n = 1, s = 0, U_p = 0$ reduction of `atiPhotoelectronPeakEnergy` to Einstein's law,
   and exact equivalence of the Keldysh barrier decay scale $\kappa = \sqrt{2 m_e \Phi_W}/\hbar$
   with Three-Channel Plücker–Madelung–QFIM Channel-2 osmotic speed (`0%` error vs. `100%`
   standard Bohmian error) and coupled-waveguide `QFIM` tunneling speed (`sharoglazova_klaers_evanescent_speed_law`);
5. AKNS focusing NLS bright soliton (`brightSoliton_nls_pde`) and defocusing GPE dark soliton
   (`darkSoliton_gpe_pde`) PDE closures, peak intensity $I_{\mathrm{NLS}}(A, 0) = A^2$, coherent
   two-pathway `Gr_C(2,4)` interference (`0%` vs. `50%` unphased `Gr_≥0` error), and `QFIM = 4 g_FS`
   attosecond Cramér–Rao variance scaling. -/
@[blueprint "thm:signals-photoelectric-unified-qci-gxc-twistor-akns-qfim-identities"
  (title := "Master theorem: Photoelectric effect across QCI-GXC DFT, twistors/ENZ/OAM, Keldysh tunneling, AKNS solitons, and QFIM = 4 g_FS")
  (statement := /-- Unifies Einstein (1905) threshold/stopping laws, McWeeny QCI-GXC work-function
    purification, 400x ENZ longitudinal E_z and OAM QFIM super-resolution, Keldysh strong-field
    ponderomotive/ATI scaling, Three-Channel Plücker-Madelung-QFIM tunneling (0% vs. 100% Bohm error),
    AKNS NLS/GPE soliton PDEs, and two-pathway RABBITT Gr_C(2,4) interference. -/)
  (proof := /-- Combine \texttt{ring}, \texttt{field\_simp}, \texttt{norm\_num},
    \texttt{Signals.DFT} / \texttt{Signals.DDF} / \texttt{Signals.QuantumTrajectories} /
    \texttt{Signals.SatoGrassmannian} lemmas. -/)]
theorem photoelectric_unified_qci_gxc_twistor_akns_qfim_identities
    (h_planck nu_below nu_above e_vac e_fermi : ℝ)
    (q_charge e0_amp mass_e omega hbar j0 : ℝ)
    (amp x t p_path : ℝ)
    (l_in : ℤ)
    (h_hpos : 0 < h_planck)
    (h_below : h_planck * nu_below ≤ kohnShamWorkFunction e_vac e_fermi)
    (h_above : kohnShamWorkFunction e_vac e_fermi ≤ h_planck * nu_above)
    (hq : q_charge ≠ 0) (he0 : e0_amp ≠ 0) (hme : 0 < mass_e)
    (homega : omega ≠ 0) (hhbar : 0 < hbar)
    (hphi_pos : 0 < kohnShamWorkFunction e_vac e_fermi)
    (hj0 : 0 ≤ j0)
    (hgap : hbar * j0 ≤ kohnShamWorkFunction e_vac e_fermi)
    (hp_pos : 0 < p_path) :
    let phi_w := kohnShamWorkFunction e_vac e_fermi
    let up := ponderomotiveEnergy q_charge e0_amp mass_e omega
    let kappa := Real.sqrt (keldyshBarrierDecayKappaSq mass_e phi_w hbar)
    let v_osm := Signals.QuantumTrajectories.evanescentOsmoticSpeed hbar mass_e kappa
    let kp := Real.sqrt (2 * mass_e * (phi_w - hbar * j0) / hbar ^ 2)
    let km := Real.sqrt (2 * mass_e * (phi_w + hbar * j0) / hbar ^ 2)
    let dκ := (km - kp) / 2
    let κbar := (km + kp) / 2
    let r_c := Real.sqrt (Real.cosh (2 * dκ * x))
    let p_vec : Signals.SatoGrassmannian.DualSchubertQFIM.Plucker6 := WithLp.toLp 2 (fun i : Fin 6 =>
      if i = 0 then ((Real.cosh (dκ * x) / r_c : ℝ) : ℂ)
      else if i = 1 then ((Real.sinh (dκ * x) / r_c : ℝ) : ℂ)
      else 0)
    let dp_vec : Signals.SatoGrassmannian.DualSchubertQFIM.Plucker6 := WithLp.toLp 2 (fun i : Fin 6 =>
      if i = 0 then ((-(dκ * Real.sinh (dκ * x)) / (r_c * Real.cosh (2 * dκ * x)) : ℝ) : ℂ)
      else if i = 1 then (((dκ * Real.cosh (dκ * x)) / (r_c * Real.cosh (2 * dκ * x)) : ℝ) : ℂ)
      else 0)
    let ρ_c : ℝ := Real.exp (-2 * κbar * x) * Real.cosh (2 * dκ * x)
    let dρ_c : ℝ := 2 * ρ_c * (-κbar + dκ * Real.tanh (2 * dκ * x))
    (einsteinStoppingKineticEnergy h_planck nu_below phi_w = 0 ∧
      einsteinStoppingKineticEnergy h_planck nu_above phi_w = h_planck * nu_above - phi_w ∧
      h_planck * photoelectricThresholdFrequency h_planck phi_w = phi_w ∧
      classicalRayleighAccumulationDelay phi_w (1 / 1000) 1 =
        1000 * classicalRayleighAccumulationDelay phi_w 1 1) ∧
    (mcweenyIdempotencyDefect 0 = 0 ∧
      mcweenyIdempotencyDefect 1 = 0 ∧
      mcweenyIdempotencyDefect (1 / 2) = 0 ∧
      Signals.DFT.mcweenyPurificationPoly (3 / 4) = 27 / 32) ∧
    (Signals.DDF.enzBoundaryIntensityEnhancement 1 (1 / 20) = 400 ∧
      Signals.DFT.samToOamLongitudinalTopologicalCharge l_in 1 = l_in + 1 ∧
      Signals.DFT.oamSuperpositionQfimPhi 3 = 4 * Signals.DFT.oamSuperpositionFubiniStudyPhi 3 ∧
      Signals.DFT.quantumCramerRaoVarianceBound 10 (Signals.DFT.oamSuperpositionQfimPhi 3) =
        (1 / 9) * Signals.DFT.quantumCramerRaoVarianceBound 10 (Signals.DFT.oamSuperpositionQfimPhi 1) ∧
      Signals.DFT.eulerKinematicJacobianDet (Real.pi / 2) = 0 ∧
      Signals.DFT.eulerKinematicJacobianDet (-Real.pi / 2) = 0 ∧
      Signals.DFT.poincareSphereQfimTheta = 4 * Signals.DFT.poincareSphereFubiniStudyTheta) ∧
    (atiPhotoelectronPeakEnergy 1 0 (h_planck * nu_above) phi_w 0 =
        h_planck * nu_above - phi_w ∧
      keldyshParameterSq phi_w up =
        omega ^ 2 * (2 * mass_e * phi_w) / (q_charge ^ 2 * e0_amp ^ 2) ∧
      keldyshParameterSq phi_w up =
        (omega * hbar * kappa / (q_charge * e0_amp)) ^ 2 ∧
      v_osm ^ 2 = 2 * phi_w / mass_e ∧
      Signals.Huygens.relativePredictiveError
        Signals.QuantumTrajectories.standardBohmEvanescentVelocity v_osm = 1 ∧
      Signals.Huygens.relativePredictiveError
        (Signals.QuantumTrajectories.pluckerThreeChannelSpeedSq 0 v_osm 0)
        (2 * phi_w / mass_e) = 0 ∧
      (hbar / mass_e) ^ 2 *
          ((⟪p_vec, dp_vec⟫_ℂ).im ^ 2 + (dρ_c / (2 * ρ_c)) ^ 2 +
            Signals.SatoGrassmannian.DualSchubertQFIM.qfim p_vec dp_vec / 4) =
        (2 / mass_e) * (phi_w - hbar * j0 * Real.tanh (2 * dκ * x))) ∧
    (Complex.I * deriv (fun s => Signals.SatoGrassmannian.AKNS.brightSoliton amp x s) t +
        iteratedDeriv 2 (fun r => Signals.SatoGrassmannian.AKNS.brightSoliton amp r t) x +
        2 * ((‖Signals.SatoGrassmannian.AKNS.brightSoliton amp x t‖ ^ 2 : ℝ) : ℂ) *
          Signals.SatoGrassmannian.AKNS.brightSoliton amp x t = 0 ∧
      Complex.I * deriv (fun s => Signals.SatoGrassmannian.AKNS.darkSoliton amp x s) t +
        iteratedDeriv 2 (fun r => Signals.SatoGrassmannian.AKNS.darkSoliton amp r t) x -
        2 * ((‖Signals.SatoGrassmannian.AKNS.darkSoliton amp x t‖ ^ 2 : ℝ) : ℂ) *
          Signals.SatoGrassmannian.AKNS.darkSoliton amp x t = 0 ∧
      nlsBrightSolitonIntensity amp 0 = amp ^ 2 ∧
      Signals.Huygens.relativePredictiveError
        (unphasedTwoPathwayIntensity p_path p_path)
        (twoPathwayPhotoemissionIntensity p_path p_path 0) = 1 / 2 ∧
      Signals.Huygens.relativePredictiveError
        (twoPathwayPhotoemissionIntensity p_path p_path 0) (4 * p_path) = 0 ∧
      Signals.DFT.twoChannelPhaseVariance (1 / 2) (1 / 2) 1 (-1) = 1) := by
  intro phi_w up kappa v_osm kp km dκ κbar r_c p_vec dp_vec ρ_c dρ_c
  have h_thresh : h_planck * photoelectricThresholdFrequency h_planck phi_w = phi_w := by
    unfold photoelectricThresholdFrequency
    field_simp [h_hpos.ne']
  have h_kappa_nonneg : 0 ≤ keldyshBarrierDecayKappaSq mass_e phi_w hbar := by
    unfold keldyshBarrierDecayKappaSq
    positivity
  have h_kappa_sq : kappa ^ 2 = 2 * mass_e * phi_w / hbar ^ 2 := by
    dsimp [kappa]
    rw [Real.sq_sqrt h_kappa_nonneg]
    rfl
  have h_vosm_sq : v_osm ^ 2 = 2 * phi_w / mass_e := by
    dsimp [v_osm]
    unfold Signals.QuantumTrajectories.evanescentOsmoticSpeed
    have h_mul : (hbar / (2 * mass_e) * (2 * kappa)) ^ 2 = (hbar ^ 2 / mass_e ^ 2) * kappa ^ 2 := by
      field_simp [hme.ne']
    rw [h_mul, h_kappa_sq]
    field_simp [hhbar.ne', hme.ne']
  have h_vosm_pos : 0 < v_osm := by
    dsimp [v_osm]
    unfold Signals.QuantumTrajectories.evanescentOsmoticSpeed
    have h_ksq_pos : 0 < keldyshBarrierDecayKappaSq mass_e phi_w hbar := by
      unfold keldyshBarrierDecayKappaSq
      positivity
    have h_kpos : 0 < kappa := Real.sqrt_pos.mpr h_ksq_pos
    positivity
  have h_keldysh_1 :
      keldyshParameterSq phi_w up =
        omega ^ 2 * (2 * mass_e * phi_w) / (q_charge ^ 2 * e0_amp ^ 2) := by
    dsimp [up]
    unfold keldyshParameterSq ponderomotiveEnergy
    field_simp [hq, he0, hme.ne', homega]
    ring
  have h_keldysh_2 :
      keldyshParameterSq phi_w up =
        (omega * hbar * kappa / (q_charge * e0_amp)) ^ 2 := by
    rw [h_keldysh_1]
    have h_rhs : (omega * hbar * kappa / (q_charge * e0_amp)) ^ 2 =
        omega ^ 2 * hbar ^ 2 * kappa ^ 2 / (q_charge ^ 2 * e0_amp ^ 2) := by
      ring
    rw [h_rhs, h_kappa_sq]
    field_simp [hhbar.ne', hq, he0]
  have h_bohm_err :
      Signals.Huygens.relativePredictiveError
        Signals.QuantumTrajectories.standardBohmEvanescentVelocity v_osm = 1 := by
    unfold Signals.Huygens.relativePredictiveError
      Signals.QuantumTrajectories.standardBohmEvanescentVelocity
    rw [zero_sub, abs_neg, abs_of_pos h_vosm_pos, div_self h_vosm_pos.ne']
  have h_sk :=
    Signals.SatoGrassmannian.DualSchubertQFIM.sharoglazova_klaers_evanescent_speed_law
      (ℏ := hbar) (m := mass_e) (E_abs := phi_w) (J₀ := j0)
      (κ_plus := kp) (κ_minus := km) hhbar hme
      (by
        dsimp [kp]
        rw [Real.sq_sqrt]
        have h_diff : 0 ≤ phi_w - hbar * j0 := sub_nonneg.mpr hgap
        positivity)
      (by
        dsimp [km]
        rw [Real.sq_sqrt]
        have hjbar : 0 ≤ hbar * j0 := mul_nonneg hhbar.le hj0
        have h_sum : 0 ≤ phi_w + hbar * j0 := by linarith [hphi_pos, hjbar]
        positivity)
      x
  have h_two_path_coh : twoPathwayPhotoemissionIntensity p_path p_path 0 = 4 * p_path := by
    unfold twoPathwayPhotoemissionIntensity
    rw [Real.cos_zero, show p_path * p_path = p_path ^ 2 by ring,
      Real.sqrt_sq hp_pos.le]
    ring
  have h_two_path_err :
      Signals.Huygens.relativePredictiveError
        (unphasedTwoPathwayIntensity p_path p_path)
        (twoPathwayPhotoemissionIntensity p_path p_path 0) = 1 / 2 := by
    rw [h_two_path_coh]
    unfold Signals.Huygens.relativePredictiveError unphasedTwoPathwayIntensity
    have h_neg : |p_path + p_path - 4 * p_path| = 2 * p_path := by
      rw [show p_path + p_path - 4 * p_path = -(2 * p_path) by ring, abs_neg,
        abs_of_pos (by linarith)]
    have h_den : |4 * p_path| = 4 * p_path := abs_of_pos (by linarith)
    rw [h_neg, h_den]
    field_simp [hp_pos.ne']
    norm_num
  refine ⟨⟨?_, ?_, h_thresh, ?_⟩, ⟨?_, ?_, ?_, ?_⟩, ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_⟩,
      ⟨?_, h_keldysh_1, h_keldysh_2, h_vosm_sq, h_bohm_err, ?_, h_sk.2.2.2⟩,
      ⟨Signals.SatoGrassmannian.AKNS.brightSoliton_nls_pde amp x t,
        Signals.SatoGrassmannian.AKNS.darkSoliton_gpe_pde amp x t, ?_, h_two_path_err, ?_, ?_⟩⟩
  · unfold einsteinStoppingKineticEnergy
    exact max_eq_left (sub_nonpos.mpr h_below)
  · unfold einsteinStoppingKineticEnergy
    exact max_eq_right (sub_nonneg.mpr h_above)
  · unfold classicalRayleighAccumulationDelay
    ring
  · unfold mcweenyIdempotencyDefect Signals.DFT.mcweenyPurificationPoly; norm_num
  · unfold mcweenyIdempotencyDefect Signals.DFT.mcweenyPurificationPoly; norm_num
  · unfold mcweenyIdempotencyDefect Signals.DFT.mcweenyPurificationPoly; norm_num
  · unfold Signals.DFT.mcweenyPurificationPoly; norm_num
  · unfold Signals.DDF.enzBoundaryIntensityEnhancement; norm_num
  · unfold Signals.DFT.samToOamLongitudinalTopologicalCharge; rfl
  · unfold Signals.DFT.oamSuperpositionQfimPhi Signals.DFT.oamSuperpositionFubiniStudyPhi; ring
  · unfold Signals.DFT.quantumCramerRaoVarianceBound Signals.DFT.oamSuperpositionQfimPhi; ring
  · unfold Signals.DFT.eulerKinematicJacobianDet; exact Real.cos_pi_div_two
  · unfold Signals.DFT.eulerKinematicJacobianDet
    rw [neg_div, Real.cos_neg]; exact Real.cos_pi_div_two
  · unfold Signals.DFT.poincareSphereQfimTheta Signals.DFT.poincareSphereFubiniStudyTheta; norm_num
  · unfold atiPhotoelectronPeakEnergy; ring
  · unfold Signals.Huygens.relativePredictiveError Signals.QuantumTrajectories.pluckerThreeChannelSpeedSq
    rw [zero_pow two_ne_zero, zero_add, add_zero, h_vosm_sq, sub_self, abs_zero, zero_div]
  · unfold nlsBrightSolitonIntensity
    rw [mul_zero, Real.cosh_zero, one_pow, div_one]
  · rw [h_two_path_coh]
    unfold Signals.Huygens.relativePredictiveError
    rw [sub_self, abs_zero, zero_div]
  · unfold Signals.DFT.twoChannelPhaseVariance; norm_num

/-! ## Section 4: Adversarial Critique & Gap-Closure Guardrails

Addresses five concrete physical critiques of simplified textbook / lossless / zero-temperature models:
1. **Schottky Field-Assisted Work-Function Lowering (`schottkyBarrierLoweringSq`, `schottkyEffectiveWorkFunction`)**:
   Under an intense extracting / laser field $E_0 > 0$, the image-charge potential lowers the
   effective barrier height by $\Delta\Phi_{\mathrm{Schottky}} = \sqrt{\frac{q^3 E_0}{4\pi\varepsilon_0}} > 0$.
2. **Dissipative Drude `ENZ` Saturation (`enzDissipativeIntensityEnhancement`)**:
   Prevents unphysical $\infty$ divergence at $\operatorname{Re}(\varepsilon_{\mathrm{ENZ}}) = 0$ by
   including collision damping $\operatorname{Im}(\varepsilon_{\mathrm{ENZ}}) = \varepsilon_{\mathrm{im}} \neq 0$,
   capping peak enhancement at $\varepsilon_{\mathrm{air}}^2 / \varepsilon_{\mathrm{im}}^2$ (and reducing
   $400\times \to 200\times$ at $\varepsilon_{\mathrm{re}} = \varepsilon_{\mathrm{im}} = 1/20$).
3. **Fermi–Dirac Finite-Temperature Edge (`fermiDiracOccupation`)**:
   Smoothly broadens the $T = 0$ sharp cutoff around $E_F$ with exact midpoint $f_{\mathrm{FD}}(0, k_B T) = 1/2$
   and particle-hole symmetry $f_{\mathrm{FD}}(\Delta E, k_B T) + f_{\mathrm{FD}}(-\Delta E, k_B T) = 1$.
4. **`ARPES` Binding-Energy Kinematics (`arpesKineticEnergyFromBinding`)**:
   Extends Einstein's threshold to sub-Fermi bands $E_B \ge 0$ via $E_{\mathrm{kin}} = h\nu - \Phi_W - E_B$.
5. **Attosecond `RABBITT` Temporal `QFIM` & `KP-II` Positroid Soliton Closure**:
   Proves $F_{\tau\tau}^{\mathrm{RABBITT}} = 4\,g_{\tau\tau}^{\mathrm{FS}} = 4\,\omega_{\mathrm{IR}}^2$
   with Quantum Cramér–Rao bound $\frac{1}{4 N_{\mathrm{counts}} \omega_{\mathrm{IR}}^2}$, alongside
   exact $\mathrm{Gr}_{\mathbb{C}}(2,4)$ Hirota `KP-II` bilinear closure `hirotaKP_tauU_eq_zero`. -/

/-- **Schottky Image-Charge Barrier Lowering Squared (`schottkyBarrierLoweringSq`)**:
$$\Delta\Phi_{\mathrm{Schottky}}^2(q, E_0, \varepsilon_0) = \frac{q^3 E_0}{4\pi\varepsilon_0}.$$ -/
@[blueprint "def:signals-photoelectric-schottky-barrier-lowering-sq"
  (title := "Schottky image-charge barrier lowering squared q^3 E_0 / (4 pi eps_0)")
  (statement := /-- Define $\operatorname{schottkyBarrierLoweringSq}(q, E_0, \varepsilon_0) = q^3 E_0 / (4\pi\varepsilon_0)$. -/)]
def schottkyBarrierLoweringSq (q_charge e0_amp eps0 : ℝ) : ℝ :=
  q_charge ^ 3 * e0_amp / (4 * Real.pi * eps0)

/-- **Schottky Field-Lowered Effective Work Function (`schottkyEffectiveWorkFunction`)**:
$$\Phi_{\mathrm{eff}}(\Phi_W, q, E_0, \varepsilon_0) = \Phi_W - \sqrt{\frac{q^3 E_0}{4\pi\varepsilon_0}}.$$ -/
@[blueprint "def:signals-photoelectric-schottky-effective-work-function"
  (title := "Schottky field-lowered effective work function Phi_W - sqrt(q^3 E_0 / (4 pi eps_0))")
  (statement := /-- Define $\operatorname{schottkyEffectiveWorkFunction}(\Phi_W, q, E_0, \varepsilon_0) = \Phi_W - \sqrt{\operatorname{schottkyBarrierLoweringSq}(q, E_0, \varepsilon_0)}$. -/)]
def schottkyEffectiveWorkFunction (phi_w q_charge e0_amp eps0 : ℝ) : ℝ :=
  phi_w - Real.sqrt (schottkyBarrierLoweringSq q_charge e0_amp eps0)

/-- **Dissipative Drude `ENZ` Surface Intensity Enhancement (`enzDissipativeIntensityEnhancement`)**:
$$G_{\mathrm{ENZ}}^{\mathrm{lossy}}(\varepsilon_{\mathrm{air}}, \varepsilon_{\mathrm{re}}, \varepsilon_{\mathrm{im}}) = \frac{\varepsilon_{\mathrm{air}}^2}{\varepsilon_{\mathrm{re}}^2 + \varepsilon_{\mathrm{im}}^2}.$$ -/
@[blueprint "def:signals-photoelectric-enz-dissipative-enhancement"
  (title := "Dissipative Drude ENZ intensity enhancement eps_air^2 / (eps_re^2 + eps_im^2)")
  (statement := /-- Define $\operatorname{enzDissipativeIntensityEnhancement}(\varepsilon_{\mathrm{air}}, \varepsilon_{\mathrm{re}}, \varepsilon_{\mathrm{im}}) = \varepsilon_{\mathrm{air}}^2 / (\varepsilon_{\mathrm{re}}^2 + \varepsilon_{\mathrm{im}}^2)$. -/)]
def enzDissipativeIntensityEnhancement (eps_air eps_re eps_im : ℝ) : ℝ :=
  eps_air ^ 2 / (eps_re ^ 2 + eps_im ^ 2)

/-- **Fermi–Dirac Finite-Temperature Occupation (`fermiDiracOccupation`)**:
$$f_{\mathrm{FD}}(\Delta E, k_B T) = \frac{1}{1 + \exp(\Delta E / (k_B T))}.$$ -/
@[blueprint "def:signals-photoelectric-fermi-dirac-occupation"
  (title := "Fermi-Dirac occupation 1 / (1 + exp(Delta E / (k_B T)))")
  (statement := /-- Define $\operatorname{fermiDiracOccupation}(\Delta E, k_B T) = 1 / (1 + \exp(\Delta E / (k_B T)))$. -/)]
def fermiDiracOccupation (delta_e kb_t : ℝ) : ℝ :=
  1 / (1 + Real.exp (delta_e / kb_t))

/-- **`ARPES` Kinetic Energy at Binding Energy $E_B$ (`arpesKineticEnergyFromBinding`)**:
$$E_{\mathrm{kin}}^{\mathrm{ARPES}}(h\nu, \Phi_W, E_B) = h\nu - \Phi_W - E_B.$$ -/
@[blueprint "def:signals-photoelectric-arpes-kinetic-energy"
  (title := "ARPES photoelectron kinetic energy h nu - Phi_W - E_B")
  (statement := /-- Define $\operatorname{arpesKineticEnergyFromBinding}(h\nu, \Phi_W, E_B) = h\nu - \Phi_W - E_B$. -/)]
def arpesKineticEnergyFromBinding (h_nu phi_w e_bind : ℝ) : ℝ :=
  h_nu - phi_w - e_bind

/-- **Attosecond `RABBITT` Temporal Fubini–Study Metric (`rabbittAttosecondFubiniStudy`)**:
For balanced two-pathway sideband modulation $\Delta\phi(\tau) = 2\omega_{\mathrm{IR}}\tau$:
$$g_{\tau\tau}^{\mathrm{FS}}(\omega_{\mathrm{IR}}) = \omega_{\mathrm{IR}}^2.$$ -/
@[blueprint "def:signals-photoelectric-rabbitt-fubini-study"
  (title := "Attosecond RABBITT temporal Fubini-Study metric omega_IR^2")
  (statement := /-- Define $\operatorname{rabbittAttosecondFubiniStudy}(\omega_{\mathrm{IR}}) = \omega_{\mathrm{IR}}^2$. -/)]
def rabbittAttosecondFubiniStudy (omega_ir : ℝ) : ℝ :=
  omega_ir ^ 2

/-- **Attosecond `RABBITT` Temporal Quantum Fisher Information Metric (`rabbittAttosecondQfim`)**:
$$F_{\tau\tau}^{\mathrm{RABBITT}}(\omega_{\mathrm{IR}}) = 4\,g_{\tau\tau}^{\mathrm{FS}}(\omega_{\mathrm{IR}}) = 4\,\omega_{\mathrm{IR}}^2.$$ -/
@[blueprint "def:signals-photoelectric-rabbitt-qfim"
  (title := "Attosecond RABBITT temporal QFIM 4 omega_IR^2")
  (statement := /-- Define $\operatorname{rabbittAttosecondQfim}(\omega_{\mathrm{IR}}) = 4\,\omega_{\mathrm{IR}}^2$. -/)]
def rabbittAttosecondQfim (omega_ir : ℝ) : ℝ :=
  4 * omega_ir ^ 2

/-- **Critique & Gap-Closure Theorem (`photoelectric_critique_and_gap_closure_identities`)** -/
@[blueprint "thm:signals-photoelectric-critique-and-gap-closure-identities"
  (title := "Photoelectric critique & gap-closure: Schottky lowering, lossy ENZ saturation, Fermi-Dirac symmetry, ARPES kinematics, RABBITT QFIM, & Hirota KP-II")
  (statement := /-- Proves strict Schottky barrier reduction under $q, E_0, \varepsilon_0 > 0$,
    finite lossy ENZ saturation ($400 \to 200$ at $\varepsilon_{\mathrm{re}}=\varepsilon_{\mathrm{im}}=1/20$),
    Fermi--Dirac midpoint $1/2$ and particle-hole sum $1$, ARPES Fermi-level reduction,
    RABBITT temporal QFIM $F_{\tau\tau} = 4\omega_{\mathrm{IR}}^2$ and QCRB, and $\mathrm{Gr}_{\mathbb{C}}(2,4)$
    Hirota KP-II bilinear soliton closure. -/)
  (proof := /-- Combine \texttt{Real.exp\_neg}, \texttt{Real.sqrt\_pos}, \texttt{ring},
    \texttt{field\_simp}, \texttt{norm\_num}, and \texttt{HirotaKP.hirotaKP\_tauU\_eq\_zero}. -/)]
theorem photoelectric_critique_and_gap_closure_identities
    (phi_w q_charge e0_amp eps0 eps_air eps_re eps_im delta_e kb_t h_nu omega_ir n_counts : ℝ)
    (v w : Signals.SatoGrassmannian.Gr24Truncation.C4) (t1 t2 t3 : ℂ)
    (hq : 0 < q_charge) (he0 : 0 < e0_amp) (heps0 : 0 < eps0)
    (h_enz_im : eps_im ≠ 0) :
    schottkyEffectiveWorkFunction phi_w q_charge e0_amp eps0 < phi_w ∧
      enzDissipativeIntensityEnhancement eps_air eps_re 0 =
        Signals.DDF.enzBoundaryIntensityEnhancement eps_air eps_re ∧
      enzDissipativeIntensityEnhancement eps_air 0 eps_im = eps_air ^ 2 / eps_im ^ 2 ∧
      0 < enzDissipativeIntensityEnhancement 1 0 eps_im ∧
      enzDissipativeIntensityEnhancement 1 (1 / 20) (1 / 20) = 200 ∧
      enzDissipativeIntensityEnhancement 1 (1 / 20) (1 / 20) <
        Signals.DDF.enzBoundaryIntensityEnhancement 1 (1 / 20) ∧
      fermiDiracOccupation 0 kb_t = 1 / 2 ∧
      fermiDiracOccupation delta_e kb_t + fermiDiracOccupation (-delta_e) kb_t = 1 ∧
      arpesKineticEnergyFromBinding h_nu phi_w 0 = h_nu - phi_w ∧
      rabbittAttosecondQfim omega_ir = 4 * rabbittAttosecondFubiniStudy omega_ir ∧
      Signals.DFT.twoChannelPhaseVariance (1 / 2) (1 / 2) omega_ir (-omega_ir) =
        rabbittAttosecondFubiniStudy omega_ir ∧
      Signals.DFT.quantumCramerRaoVarianceBound n_counts (rabbittAttosecondQfim omega_ir) =
        1 / (4 * n_counts * omega_ir ^ 2) ∧
      Signals.SatoGrassmannian.HirotaKP.hirotaKP
        (Signals.SatoGrassmannian.HirotaKP.tauU v w) t1 t2 t3 = 0 := by
  have h_schottky_sq_pos : 0 < schottkyBarrierLoweringSq q_charge e0_amp eps0 := by
    unfold schottkyBarrierLoweringSq
    have hpi : 0 < Real.pi := Real.pi_pos
    positivity
  have h_schottky_lt : schottkyEffectiveWorkFunction phi_w q_charge e0_amp eps0 < phi_w := by
    unfold schottkyEffectiveWorkFunction
    linarith [Real.sqrt_pos.mpr h_schottky_sq_pos]
  have h_fd_sum : fermiDiracOccupation delta_e kb_t + fermiDiracOccupation (-delta_e) kb_t = 1 := by
    unfold fermiDiracOccupation
    have hneg : (-delta_e) / kb_t = -(delta_e / kb_t) := by ring
    rw [hneg, Real.exp_neg]
    have hexp_pos : 0 < Real.exp (delta_e / kb_t) := Real.exp_pos _
    have h1 : 1 + Real.exp (delta_e / kb_t) ≠ 0 := by linarith
    have h2 : 1 + (Real.exp (delta_e / kb_t))⁻¹ ≠ 0 := by positivity
    field_simp [h1, h2, hexp_pos.ne']
    ring
  refine ⟨h_schottky_lt, ?_, ?_, ?_, ?_, ?_, ?_, h_fd_sum, ?_, ?_, ?_, ?_,
      Signals.SatoGrassmannian.HirotaKP.hirotaKP_tauU_eq_zero v w t1 t2 t3⟩
  · unfold enzDissipativeIntensityEnhancement Signals.DDF.enzBoundaryIntensityEnhancement
    rw [zero_pow two_ne_zero, add_zero, div_pow]
  · unfold enzDissipativeIntensityEnhancement
    rw [zero_pow two_ne_zero, zero_add]
  · unfold enzDissipativeIntensityEnhancement
    rw [zero_pow two_ne_zero, zero_add, one_pow]
    exact div_pos one_pos (sq_pos_of_ne_zero h_enz_im)
  · unfold enzDissipativeIntensityEnhancement; norm_num
  · unfold enzDissipativeIntensityEnhancement Signals.DDF.enzBoundaryIntensityEnhancement; norm_num
  · unfold fermiDiracOccupation
    rw [zero_div, Real.exp_zero]
    norm_num
  · unfold arpesKineticEnergyFromBinding; ring
  · unfold rabbittAttosecondQfim rabbittAttosecondFubiniStudy; ring
  · unfold Signals.DFT.twoChannelPhaseVariance rabbittAttosecondFubiniStudy; ring
  · unfold Signals.DFT.quantumCramerRaoVarianceBound rabbittAttosecondQfim; ring

/-! ## Section 5: Polaritons, Surface Plasmon Polaritons (`SPPs`), Volume-Plasmon Satellites, & Pole-Free `VRC` ($x_X = -1$) Photoemission -/

/-- **Volume-Plasmon Loss Satellite Kinetic Energy (`volumePlasmonSatelliteKineticEnergy`)**:
When an escaping photoelectron excites $m_{\mathrm{pl}} \in \mathbb{N}$ bulk plasmons of energy
$\hbar\omega_p$ (at the `ENZ` electron-density resonance $\varepsilon_r(\rho_e, \omega_p) = 0$),
its kinetic energy shifts down to:
$$E_{\mathrm{sat}}(h\nu, \Phi_W, m_{\mathrm{pl}}, \hbar\omega_p) = h\nu - \Phi_W - m_{\mathrm{pl}}\,\hbar\omega_p.$$ -/
@[blueprint "def:signals-photoelectric-volume-plasmon-satellite"
  (title := "Volume-plasmon loss satellite kinetic energy h nu - Phi_W - m * hbar * omega_p")
  (statement := /-- Define $\operatorname{volumePlasmonSatelliteKineticEnergy}(h\nu, \Phi_W, m_{\mathrm{pl}}, \hbar\omega_p) = h\nu - \Phi_W - m_{\mathrm{pl}}\,\hbar\omega_p$. -/)]
def volumePlasmonSatelliteKineticEnergy
    (h_nu phi_w m_plasmon hbar_wp : ℝ) : ℝ :=
  h_nu - phi_w - m_plasmon * hbar_wp

/-- **2D SPP Hotspot Mode-Area Compression Factor (`sppHotspotModeAreaCompression`)**:
In a `sppHotspotTensorSplat` with longitudinal width $\sigma_1 = \lambda_0 / n_{\mathrm{SPP}}$ and
skin-depth width $\sigma_2 = \lambda_0 / (n_{\mathrm{SPP}}\kappa_{\mathrm{ratio}})$, the area
compression factor relative to $\lambda_0^2$ is:
$$\mathcal{C}_{\mathrm{SPP}}(n_{\mathrm{SPP}}, \kappa_{\mathrm{ratio}}) = n_{\mathrm{SPP}}^2\,\kappa_{\mathrm{ratio}}.$$ -/
@[blueprint "def:signals-photoelectric-spp-hotspot-mode-area-compression"
  (title := "SPP hotspot mode-area compression factor n_SPP^2 * kappa_ratio")
  (statement := /-- Define $\operatorname{sppHotspotModeAreaCompression}(n_{\mathrm{SPP}}, \kappa_{\mathrm{ratio}}) = n_{\mathrm{SPP}}^2 \kappa_{\mathrm{ratio}}$. -/)]
def sppHotspotModeAreaCompression (n_spp kappa_ratio : ℝ) : ℝ :=
  n_spp ^ 2 * kappa_ratio

/-- **SPP-Enhanced Local Hotspot Ponderomotive Energy (`sppHotspotPonderomotiveEnergy`)**:
Sub-wavelength plasmonic mode-area compression boosts local field intensity $|E_{\mathrm{loc}}|^2$
by $\mathcal{C}_{\mathrm{SPP}} = n_{\mathrm{SPP}}^2\kappa_{\mathrm{ratio}}$, magnifying the
strong-field Keldysh ponderomotive energy:
$$U_p^{\mathrm{SPP}} = n_{\mathrm{SPP}}^2\,\kappa_{\mathrm{ratio}}\,U_p.$$ -/
@[blueprint "def:signals-photoelectric-spp-hotspot-ponderomotive"
  (title := "SPP hotspot local ponderomotive energy n_SPP^2 * kappa_ratio * U_p")
  (statement := /-- Define $\operatorname{sppHotspotPonderomotiveEnergy}(q, E_0, m_e, \omega, n_{\mathrm{SPP}}, \kappa_{\mathrm{ratio}}) = \operatorname{sppHotspotModeAreaCompression}(n_{\mathrm{SPP}}, \kappa_{\mathrm{ratio}}) \cdot \operatorname{ponderomotiveEnergy}(q, E_0, m_e, \omega)$. -/)]
def sppHotspotPonderomotiveEnergy
    (q_charge e0_amp mass_e omega n_spp kappa_ratio : ℝ) : ℝ :=
  sppHotspotModeAreaCompression n_spp kappa_ratio *
    ponderomotiveEnergy q_charge e0_amp mass_e omega

/-- **Polariton-Branch Photoemission Kinetic Energy (`polaritonBranchKineticEnergy`)**:
For an upper (`ω_UP`) or lower (`ω_LP`) Hopfield polariton branch with photon energy
$\hbar\omega_{\mathrm{pol}}$, surface work function $\Phi_W$, and band binding energy $E_B$:
$$E_{\mathrm{kin}}^{\mathrm{pol}}(\hbar, \omega_{\mathrm{pol}}, \Phi_W, E_B) = \hbar\omega_{\mathrm{pol}} - \Phi_W - E_B.$$ -/
@[blueprint "def:signals-photoelectric-polariton-branch-kinetic-energy"
  (title := "Polariton-branch photoemission kinetic energy hbar * omega_pol - Phi_W - E_B")
  (statement := /-- Define $\operatorname{polaritonBranchKineticEnergy}(\hbar, \omega_{\mathrm{pol}}, \Phi_W, E_B) = \hbar\omega_{\mathrm{pol}} - \Phi_W - E_B$. -/)]
def polaritonBranchKineticEnergy
    (hbar omega_pol phi_w e_bind : ℝ) : ℝ :=
  hbar * omega_pol - phi_w - e_bind

/-- **Polariton, Surface Plasmon Polariton (`SPP`), Volume-Plasmon, and Pole-Free `VRC` Photoemission Theorem (`photoelectric_polariton_plasmon_spp_vrc_identities`)**:
Certifies in a single machine-checked package:
1. **Surface Plasmon Polariton (`SPP`) Outside-Light-Cone Momentum & Metal Skin-Depth Concentration**:
   For $0 < \varepsilon_d < |\varepsilon_m|$, `sppEffectiveIndexSq` exceeds $\varepsilon_d$ (allowing
   plasmon momentum transfer $\hbar k_{\mathrm{SPP}}$ across flat interfaces), the $\mathrm{Gr}_{\mathbb{C}}(2,4)$
   Plücker ratio equals $|\varepsilon_m|/\varepsilon_d > 1$, and the conductor-side continuum evanescent
   quantum energy exceeds the dielectric side by $(|\varepsilon_m|/\varepsilon_d)^2 > 1$
   (`MovingSheath.sppContinuum_gr24_and_semigroup_identities`);
2. **SPP Hotspot Keldysh Enhancement**:
   `sppHotspotPonderomotiveEnergy` amplifies $U_p$ by $n_{\mathrm{SPP}}^2\kappa_{\mathrm{ratio}}$,
   reducing the squared Keldysh parameter $\gamma_K^2$ by $(n_{\mathrm{SPP}}^2\kappa_{\mathrm{ratio}})^{-1}$;
3. **Volume-Plasmon `ENZ` Resonance & Photoemission Satellites**:
   `Signals.DFT.dftElectronDensityPermittivity` hits the bulk longitudinal plasmon zero at
   $\alpha_{\mathrm{pol}}\rho_e = \omega_p^2$ (`4 * 1 / 4 = 1 ⇒ ε_r = 0`), producing quantized
   loss satellites spaced by $\hbar\omega_p$;
4. **Hopfield Exciton/Phonon-Polariton Band Splitting, `Gr_C(2,4)` Weights, & Lyddane–Sachs–Teller Reststrahlen**:
   Upper and lower polariton photoemission lines split by $\hbar\,\Omega_{\mathrm{eff}} \ge 2\hbar g$,
   their Hopfield photon/matter fractions satisfy $|C|^2 + |X|^2 = 1$ and $4|C|^2|X|^2 = 1 - d_{\mathrm{Hopfield}}^2$,
   and the LST permittivity vanishes at the ENZ longitudinal optical phonon $\omega_{\mathrm{LO}}$ while
   turning negative (surface-polariton active) inside $(\omega_{\mathrm{TO}}, \omega_{\mathrm{LO}})$;
5. **Pole-Free Complex Homogeneous `VRC` at On-Shell Polariton Resonance ($x_X = -1$)**:
   While rational Plabic charts divide by $x_X + 1 = 0$, `Signals.DFT.vrcResonantQfimX1` and
   `vrcResonantFubiniStudyX1` remain strictly positive and finite (`F = 4 g_FS > 0`) at $x_X = -1$. -/
@[blueprint "thm:signals-photoelectric-polariton-plasmon-spp-vrc-identities"
  (title := "Polaritons, SPPs, volume-plasmon satellites, and pole-free VRC photoemission theorem")
  (statement := /-- Unifies SPP outside-light-cone momentum and skin-depth duality on Gr_C(2,4),
    SPP hotspot Keldysh gamma_K^2 compression, volume-plasmon ENZ resonance and m * hbar * omega_p
    loss satellites, Hopfield UP/LP photoemission splitting and LST Reststrahlen surface-polariton
    windows, and pole-free VRC QFIM = 4 g_FS at on-shell resonance x_X = -1. -/)
  (proof := /-- Combine \texttt{MovingSheath.sppContinuum\_gr24\_and\_semigroup\_identities},
    \texttt{Signals.Scattering.polariton\_hopfield\_rabi\_and\_lst\_identities},
    \texttt{Signals.DFT.vrc\_fubini\_study\_kahler\_qfim\_pole\_free\_resonance\_and\_critique\_fixes\_identities},
    and \texttt{field\_simp}/\texttt{ring}. -/)]
theorem photoelectric_polariton_plasmon_spp_vrc_identities
    {sub : Signals.DDF.DDFSubstrate} (sheath : Signals.DDF.MovingSheath sub)
    (eps_d abs_eps_m kappa_d m_boson hbar theta_spp : ℝ)
    (q_charge e0_amp mass_e omega phi_w n_spp kappa_ratio h_nu hbar_wp : ℝ)
    (ω_ph ω_ex g eps_inf ω_TO ω_LO ω_rest e_bind : ℝ)
    (x1 x2 : ℝ)
    (heps_d : 0 < eps_d) (h_lt_m : eps_d < abs_eps_m)
    (hn_spp : 0 < n_spp) (hkr : 0 < kappa_ratio)
    (hq : q_charge ≠ 0) (he0 : e0_amp ≠ 0) (hme : 0 < mass_e) (homega : omega ≠ 0)
    (hg_pos : 0 < g) (heps_inf : 0 < eps_inf)
    (hTO_pos : 0 < ω_TO) (h_gt_TO : ω_TO < ω_rest) (h_lt_LO : ω_rest < ω_LO) :
    let n_sq := Signals.DDF.sppEffectiveIndexSq eps_d abs_eps_m
    let chi := Signals.DDF.sppPermittivityContrast eps_d abs_eps_m
    let M_spp := Signals.DDF.sppGr24Matrix chi theta_spp
    let up_free := ponderomotiveEnergy q_charge e0_amp mass_e omega
    let up_spp := sppHotspotPonderomotiveEnergy q_charge e0_amp mass_e omega n_spp kappa_ratio
    let ω_UP := Signals.Scattering.upperPolaritonFreq ω_ph ω_ex g
    let ω_LP := Signals.Scattering.lowerPolaritonFreq ω_ph ω_ex g
    let d_hop := Signals.Scattering.hopfieldBarycentricShift (ω_ph - ω_ex) g
    (eps_d < n_sq ∧
      Complex.normSq (Signals.DDF.complexPluckerSinkAmplitudeA M_spp) /
          Complex.normSq (Signals.DDF.complexPluckerSinkAmplitudeB M_spp) =
        abs_eps_m / eps_d ∧
      Signals.DDF.continuumBohmPotentialMode m_boson hbar ((abs_eps_m / eps_d) * kappa_d) =
        (abs_eps_m / eps_d) ^ 2 * Signals.DDF.continuumBohmPotentialMode m_boson hbar kappa_d) ∧
    (keldyshParameterSq phi_w up_spp =
        keldyshParameterSq phi_w up_free / sppHotspotModeAreaCompression n_spp kappa_ratio) ∧
    (Signals.DFT.dftElectronDensityPermittivity 4 1 4 = 0 ∧
      volumePlasmonSatelliteKineticEnergy h_nu phi_w 0 hbar_wp -
          volumePlasmonSatelliteKineticEnergy h_nu phi_w 1 hbar_wp = hbar_wp) ∧
    (polaritonBranchKineticEnergy hbar ω_UP phi_w e_bind -
          polaritonBranchKineticEnergy hbar ω_LP phi_w e_bind =
        hbar * Signals.Scattering.polaritonEffectiveRabiSplitting (ω_ph - ω_ex) g ∧
      2 * g ≤ ω_UP - ω_LP ∧
      Signals.Scattering.hopfieldPhotonWeight d_hop +
        Signals.Scattering.hopfieldMatterWeight d_hop = 1 ∧
      4 * Signals.Scattering.hopfieldPhotonWeight d_hop *
          Signals.Scattering.hopfieldMatterWeight d_hop = 1 - d_hop ^ 2 ∧
      Signals.Scattering.lyddaneSachsTellerPermittivity eps_inf ω_TO ω_LO ω_LO = 0 ∧
      Signals.Scattering.lyddaneSachsTellerPermittivity eps_inf ω_TO ω_LO ω_rest < 0) ∧
    (2 ≤ Signals.DFT.vrcResonantPluckerNormSq x1 x2 ∧
      0 < Signals.DFT.vrcResonantQfimX1 x1 x2 ∧
      Signals.DFT.vrcResonantQfimX1 x1 x2 = 4 * Signals.DFT.vrcResonantFubiniStudyX1 x1 x2) := by
  intro n_sq chi M_spp up_free up_spp ω_UP ω_LP d_hop
  have h_spp :=
    sheath.sppContinuum_gr24_and_semigroup_identities
      eps_d abs_eps_m 0 0 0 1 kappa_d m_boson hbar theta_spp heps_d h_lt_m
  have h_pol :=
    Signals.Scattering.polariton_hopfield_rabi_and_lst_identities
      ω_ph ω_ex g eps_inf ω_TO ω_LO ω_rest hg_pos heps_inf hTO_pos h_gt_TO h_lt_LO
  have h_vrc :=
    Signals.DFT.vrc_fubini_study_kahler_qfim_pole_free_resonance_and_critique_fixes_identities
      x1 x2 (Signals.DFT.vrcResonantDirectionalJetX1 x1 x2) 1 0 0 1 1 1 1 1
      one_ne_zero (by
        unfold Signals.DFT.vrcResonantDirectionalJetX1 Signals.DFT.vrcResonantPluckerNormSq
        positivity)
  have h_comp_pos : 0 < sppHotspotModeAreaCompression n_spp kappa_ratio := by
    unfold sppHotspotModeAreaCompression
    positivity
  have h_up_free_ne : up_free ≠ 0 := by
    dsimp [up_free]
    unfold ponderomotiveEnergy
    have hq2 : q_charge ^ 2 ≠ 0 := pow_ne_zero 2 hq
    have he2 : e0_amp ^ 2 ≠ 0 := pow_ne_zero 2 he0
    have ho2 : omega ^ 2 ≠ 0 := pow_ne_zero 2 homega
    positivity
  have h_kel_scale :
      keldyshParameterSq phi_w up_spp =
        keldyshParameterSq phi_w up_free / sppHotspotModeAreaCompression n_spp kappa_ratio := by
    dsimp [up_spp, up_free]
    unfold keldyshParameterSq sppHotspotPonderomotiveEnergy
    have h_comp_ne : sppHotspotModeAreaCompression n_spp kappa_ratio ≠ 0 := h_comp_pos.ne'
    field_simp [h_comp_ne, h_up_free_ne]
  refine ⟨⟨h_spp.2.1, h_spp.2.2.2.2.2.1.trans h_spp.2.2.2.2.2.2.1, h_spp.2.2.2.2.2.2.2.2.2.2⟩,
    h_kel_scale,
    ⟨by unfold Signals.DFT.dftElectronDensityPermittivity; norm_num,
      by unfold volumePlasmonSatelliteKineticEnergy; ring⟩,
    ⟨by
      dsimp [ω_UP, ω_LP]
      unfold polaritonBranchKineticEnergy
      have h_diff := h_pol.2.1
      rw [show hbar * Signals.Scattering.upperPolaritonFreq ω_ph ω_ex g - phi_w - e_bind -
          (hbar * Signals.Scattering.lowerPolaritonFreq ω_ph ω_ex g - phi_w - e_bind) =
        hbar * (Signals.Scattering.upperPolaritonFreq ω_ph ω_ex g -
          Signals.Scattering.lowerPolaritonFreq ω_ph ω_ex g) by ring, h_diff],
      h_pol.2.2.1, h_pol.2.2.2.2.2.2.1, h_pol.2.2.2.2.2.2.2.2.1,
      h_pol.2.2.2.2.2.2.2.2.2.2.2.1, h_pol.2.2.2.2.2.2.2.2.2.2.2.2⟩,
    ⟨h_vrc.2.1, h_vrc.2.2.2.2.2.2.1, h_vrc.2.2.2.2.1⟩⟩

end

end Signals.Photoelectric
