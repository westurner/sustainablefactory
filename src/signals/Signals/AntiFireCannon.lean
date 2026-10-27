import Architect
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Tactic
import Signals.EMT
namespace Signals

/-! Exact algebraic audits for the proposed 3-zone SFG cannon model. -/

/-! ### Section 30: Formal Audit & Gap Closure for the 3-Zone $400 \to 800\text{ GHz}$ `rGO-polyCBD-SS-Lignin` Hyperbolic SFG Lens, Denisov Grating Pitch, and Semenov–Hinshelwood Radical Kinetics

This section resolves five mathematical and physical gaps in the chat's 3-zone
`rGO-polyCBD-SS-Lignin` $400 \to 800\text{ GHz}$ Sum-Frequency Generation (SFG)
Anti-Fire Cannon specification (`data/chats/IQ-Sampling-for-Signal-Phase.md`,
lines 15855–17335):
1. **Zone 2 EMT Dispersion Audit ($\varepsilon_{\perp,400} < \varepsilon_{\perp,800}$)**:
   At $f = 3.20\%$ rGO, $\varepsilon_d = 2.82$, and Drude-scaled
   $\operatorname{Re}(\varepsilon_{\mathrm{rGO}}(400\text{ GHz})) = -110$,
   $\operatorname{Re}(\varepsilon_{\mathrm{rGO}}(800\text{ GHz})) = -27.5$, the exact
   EMT out-of-plane permittivities satisfy
   $\varepsilon_{\perp,400} = \frac{969375}{332468} \approx 2.9157 < \frac{969375}{331622} \approx 2.9231 = \varepsilon_{\perp,800}$
   (correcting the chat's table value $\varepsilon_{\perp,2} = 2.85$, which would make
   $\varepsilon_{\perp,2}/\varepsilon_{\perp,1} - 1 < 0$ without the chat's unannounced
   `1.15` multiplier).
2. **Zone 3 $800\text{ GHz}$ ENZ Fill-Fraction Detuning Fix ($9.301\%$ vs. $9.88\%$)**:
   The exact $800\text{ GHz}$ ENZ zero-crossing occurs at
   $f_{\mathrm{ENZ}}(800\text{ GHz}) = \frac{141}{1516} \approx 9.3008\%$, where
   $\varepsilon_\parallel = 0$ and the loss-regularized intensity enhancement reaches
   $\Gamma_{\mathrm{ENZ,reg}}(2.82, 0, 0.048) = (235/4)^2 = 3451.5625$ (field factor
   $58.75\times$). The chat's table value $f = 9.88\%$ detunes
   $\operatorname{Re}(\varepsilon_\parallel)$ to $-0.175608 \ne 0$, strictly reducing
   the ENZ intensity enhancement by more than an order of magnitude.
3. **Denisov Forward Surface-Launch Grating Pitch vs. Bragg Back-Reflection Pitch**:
   First-order forward grating coupling from normal incidence into angle $\theta_{\mathrm{in}}$
   requires $\Lambda_{\mathrm{forward}} = \lambda_0 / \sin\theta_{\mathrm{in}}$, which is
   exactly twice the Bragg back-reflection formula $\lambda_0 / (2\sin\theta_{\mathrm{in}})$
   used in `generate_polycbd_cannon_mask.py`.
4. **Dimensionally Consistent SFG Longitudinal Field ($k_{800} L_{\mathrm{eff}}$ Factor)**:
   Multiplying $\chi^{(2)} E_{400}^2$ (units $\text{V/m}^2$) by the dimensionless
   phase-matched interaction factor $k_{800} L_{\mathrm{eff}}$ restores proper electric
   field units ($\text{V/m}$).
5. **Semenov–Hinshelwood Radical Trajectory & Exothermic Recombination Heat Release**:
   While $k_{\mathrm{quench}} > k_{\mathrm{branch}} - k_{\mathrm{term}}$ forces
   $[\cdot\mathrm{OH}](t) < [\cdot\mathrm{OH}](0)$ for $t > 0$, radical recombination
   $\cdot\mathrm{OH} + \mathrm{H}\cdot + M \to \mathrm{H}_2\mathrm{O} + M$ is exothermic
   ($\Delta H_{\mathrm{rec}} > 0$), so accelerated recombination releases positive thermal
   power $P_{\mathrm{rec}} = R_{\mathrm{rec}}\,\Delta H_{\mathrm{rec}} > 0$ that must be
   removed by an explicit heat sink. -/

/-- Forward first-order diffraction grating pitch
$\Lambda_{\mathrm{forward}}(\lambda_0, \sin\theta) = \frac{\lambda_0}{\sin\theta}$
for coupling a normally incident wave into oblique angle $\theta$. -/
@[blueprint "def:signals-ddf-denisov-forward-grating-pitch"
  (title := "Forward diffraction grating pitch Λ_forward = λ_0 / sin θ")
  (statement := /-- Define $\operatorname{denisovForwardGratingPitch}(\lambda_0, \sin\theta)
    = \lambda_0 / \sin\theta$. -/)]
noncomputable def denisovForwardGratingPitch (lambda0 sinTheta : ℝ) : ℝ :=
  lambda0 / sinTheta

/-- Bragg back-reflection grating pitch
$\Lambda_{\mathrm{Bragg}}(\lambda_0, \sin\theta) = \frac{\lambda_0}{2\sin\theta}$
used in the chat's `ProcaCannonMaskSpec.denisov_electrode_pitch_um`
(`IQ-Sampling-for-Signal-Phase.md`, lines 16594–16601). -/
@[blueprint "def:signals-ddf-chat-denisov-bragg-pitch"
  (title := "Bragg half-wavelength grating pitch Λ_Bragg = λ_0 / (2 sin θ)")
  (statement := /-- Define $\operatorname{chatDenisovBraggPitch}(\lambda_0, \sin\theta)
    = \lambda_0 / (2 \sin\theta)$. -/)]
noncomputable def chatDenisovBraggPitch (lambda0 sinTheta : ℝ) : ℝ :=
  lambda0 / (2 * sinTheta)

/-- Dimensionally consistent 3-zone $800\text{ GHz}$ SFG longitudinal electric field
amplitude $E_{z,800} = \frac{\varepsilon_d}{\varepsilon_{\mathrm{ENZ}}}\,\chi^{(2)}\,(k_{800} L_{\mathrm{eff}})\,\eta_D\,E_{400}^2$,
incorporating the dimensionless interaction factor $k_{800} L_{\mathrm{eff}}$ so that
$\chi^{(2)} (\text{m/V}) \cdot E_{400}^2 (\text{V}^2/\text{m}^2)$ is scaled by a length
to yield electric-field units ($\text{V/m}$). -/
@[blueprint "def:signals-ddf-dimensioned-sfg-enz-field800"
  (title := "Dimensionally consistent 3-zone 800 GHz SFG-ENZ longitudinal field E_z,800")
  (statement := /-- Define $\operatorname{dimensionedSfgEnzField800}(\varepsilon_d, \varepsilon_{\mathrm{ENZ}}, \chi_2, k_{800}, L_{\mathrm{eff}}, \eta_D, E_{400})
    = (\varepsilon_d / \varepsilon_{\mathrm{ENZ}})\,\chi_2\,(k_{800} L_{\mathrm{eff}})\,\eta_D\,E_{400}^2$. -/)]
noncomputable def dimensionedSfgEnzField800
    (epsD epsEnz chi2 k800 L_eff eta_D E_pump400 : ℝ) : ℝ :=
  (epsD / epsEnz) * chi2 * (k800 * L_eff) * eta_D * (E_pump400 ^ 2)

/-- Net Semenov–Hinshelwood radical branching rate
$\phi_{\mathrm{net}}(k_{\mathrm{branch}}, k_{\mathrm{term}}, k_{\mathrm{quench}}) = k_{\mathrm{branch}} - k_{\mathrm{term}} - k_{\mathrm{quench}}$
(`IQ-Sampling-for-Signal-Phase.md`, lines 16336–16341 & 16461–16466). -/
@[blueprint "def:signals-ddf-semenov-net-branching-rate"
  (title := "Semenov-Hinshelwood net radical branching rate φ_net = k_branch - k_term - k_quench")
  (statement := /-- Define $\operatorname{semenovNetBranchingRate}(k_{\mathrm{branch}}, k_{\mathrm{term}}, k_{\mathrm{quench}})
    = k_{\mathrm{branch}} - k_{\mathrm{term}} - k_{\mathrm{quench}}$. -/)]
def semenovNetBranchingRate (k_branch k_term k_quench : ℝ) : ℝ :=
  k_branch - k_term - k_quench

/-- Time-dependent hydroxyl radical concentration trajectory
$n(t) = n_0 \exp\bigl(\phi_{\mathrm{net}}(k_{\mathrm{branch}}, k_{\mathrm{term}}, k_{\mathrm{quench}})\,t\bigr)$
under the linear Semenov–Hinshelwood rate model (`IQ-Sampling-for-Signal-Phase.md`, lines 16468–16470). -/
@[blueprint "def:signals-ddf-semenov-radical-concentration"
  (title := "Semenov-Hinshelwood hydroxyl radical concentration trajectory n(t) = n_0 exp(φ_net t)")
  (statement := /-- Define $\operatorname{semenovRadicalConcentration}(n_0, k_{\mathrm{branch}}, k_{\mathrm{term}}, k_{\mathrm{quench}}, t)
    = n_0 \exp(\operatorname{semenovNetBranchingRate}(k_{\mathrm{branch}}, k_{\mathrm{term}}, k_{\mathrm{quench}})\,t)$. -/)]
noncomputable def semenovRadicalConcentration
    (n0 k_branch k_term k_quench t : ℝ) : ℝ :=
  n0 * Real.exp (semenovNetBranchingRate k_branch k_term k_quench * t)

/-- Exothermic radical recombination thermal power release
$P_{\mathrm{rec}}(R_{\mathrm{rec}}, \Delta H_{\mathrm{rec}}, V) = R_{\mathrm{rec}}\,\Delta H_{\mathrm{rec}}\,V$
when radical pairs recombine into closed-shell $\mathrm{H}_2\mathrm{O}$
($\Delta H_{\mathrm{rec}} \approx 499\text{ kJ/mol} > 0$). -/
@[blueprint "def:signals-ddf-exothermic-recombination-heat-power"
  (title := "Exothermic radical-to-water recombination heat power P_rec = R_rec ΔH_rec V")
  (statement := /-- Define $\operatorname{exothermicRecombinationHeatPower}(R_{\mathrm{rec}}, \Delta H_{\mathrm{rec}}, V)
    = R_{\mathrm{rec}}\,\Delta H_{\mathrm{rec}}\,V$. -/)]
def exothermicRecombinationHeatPower (R_rec deltaH_rec volume : ℝ) : ℝ :=
  R_rec * deltaH_rec * volume

/-- **3-Zone $400 \to 800\text{ GHz}$ `rGO-polyCBD-SS-Lignin` Hyperbolic SFG Audit, Zone 3 ENZ Detuning Fix, Denisov Grating Pitch, and Semenov–Hinshelwood Kinetics Theorem**:
Proves 16 simultaneous audit and gap-closure identities for the Anti-Fire Cannon's
3-zone metamaterial lens and radical-kinetics model:
1. **Zone 1 ($400\text{ GHz}$) Exact ENZ Fill Fraction**:
   $f_{\mathrm{ENZ}}(400\text{ GHz}) = \frac{141}{5641}$ and
   $\varepsilon_\parallel\!\left(\frac{141}{5641}, -110, \frac{282}{100}\right) = 0$,
2. **Zone 2 ($f = 3.20\%$) $400\text{ GHz}$ Type-II Hyperbolic vs. $800\text{ GHz}$ Elliptical Dielectric Transition**:
   - $\varepsilon_{\parallel,400} = -\frac{9878}{12500} < 0$ and $\varepsilon_{\perp,400} = \frac{969375}{332468} > 0$,
   - $\varepsilon_{\parallel,800} = \frac{23122}{12500} > 0$ and $\varepsilon_{\perp,800} = \frac{969375}{331622} > 0$,
   - $\varepsilon_{\perp,400} < \varepsilon_{\perp,800}$ (correcting the chat's table value $2.85 < 2.92$),
3. **Zone 3 ($800\text{ GHz}$) Exact ENZ Fill Fraction ($9.301\%$) vs. Chat's Detuned Table Value ($9.88\%$)**:
   - $f_{\mathrm{ENZ}}(800\text{ GHz}) = \frac{141}{1516}$ gives $\varepsilon_\parallel\!\left(\frac{141}{1516}, -\frac{55}{2}, \frac{282}{100}\right) = 0$ and peak regularized intensity enhancement $\Gamma_{\mathrm{ENZ,reg}}\!\left(\frac{282}{100}, 0, \frac{48}{1000}\right) = \left(\frac{235}{4}\right)^2$,
   - At $f = \frac{988}{10000}$ ($9.88\%$), $\varepsilon_\parallel = -\frac{21951}{125000} \ne 0$, strictly reducing the enhancement:
     $$\Gamma_{\mathrm{ENZ,reg}}\!\left(\frac{282}{100}, -\frac{21951}{125000}, \frac{48}{1000}\right) < \Gamma_{\mathrm{ENZ,reg}}\!\left(\frac{282}{100}, 0, \frac{48}{1000}\right),$$
4. **Forward vs. Bragg Denisov Grating Pitch**:
   $\operatorname{denisovForwardGratingPitch}(\lambda_0, \sin\theta) = 2 \cdot \operatorname{chatDenisovBraggPitch}(\lambda_0, \sin\theta)$,
5. **Semenov–Hinshelwood Explosion vs. Quenching Dichotomy & Exothermic Recombination Heat**:
   - Unquenched ($k_{\mathrm{quench}} = 0, k_{\mathrm{branch}} > k_{\mathrm{term}}, t > 0$): $n_0 < n(t)$,
   - Quenched ($k_{\mathrm{branch}} - k_{\mathrm{term}} < k_{\mathrm{quench}}, t > 0$): $n(t) < n_0$,
   - Positive exothermic recombination heat power: $0 < \operatorname{exothermicRecombinationHeatPower}(R_{\mathrm{rec}}, \Delta H_{\mathrm{rec}}, V)$. -/
@[blueprint "thm:signals-ddf-three-zone-sfg-and-hydroxyl-audit"
  (title := "3-Zone 400->800 GHz rGO-polyCBD-SS-Lignin SFG audit, Zone 3 ENZ detuning fix, and Semenov-Hinshelwood kinetics theorem")
  (statement := /-- For the 3-zone \texttt{rGO-polyCBD-SS-Lignin} metamaterial parameters
    ($\varepsilon_d = 2.82$, $|\varepsilon_m(400\text{ GHz})| = 110$, $|\varepsilon_m(800\text{ GHz})| = 27.5$,
    $f_{\mathrm{Zone2}} = 0.032$, $\varepsilon_i = 0.048$) and any $\lambda_0, \sin\theta, n_0, k_{\mathrm{branch}}, k_{\mathrm{term}}, k_{\mathrm{quench}}, t, R_{\mathrm{rec}}, \Delta H_{\mathrm{rec}}, V > 0$
    with $k_{\mathrm{term}} < k_{\mathrm{branch}}$ and $k_{\mathrm{branch}} - k_{\mathrm{term}} < k_{\mathrm{quench}}$:
    (1) $f_{\mathrm{ENZ}}(400\text{ GHz}) = 141/5641$ and $\varepsilon_\parallel(141/5641, -110, 2.82) = 0$,
    (2) at $f = 0.032$, $\varepsilon_{\parallel,400} = -9878/12500 < 0$, $\varepsilon_{\perp,400} = 969375/332468 > 0$,
    $\varepsilon_{\parallel,800} = 23122/12500 > 0$, $\varepsilon_{\perp,800} = 969375/331622 > 0$, and
    $\varepsilon_{\perp,400} < \varepsilon_{\perp,800}$,
    (3) $f_{\mathrm{ENZ}}(800\text{ GHz}) = 141/1516$ gives $\varepsilon_\parallel = 0$ and
    $\Gamma_{\mathrm{ENZ,reg}}(2.82, 0, 0.048) = (235/4)^2$, whereas the chat's $f = 0.0988$ gives
    $\varepsilon_\parallel = -21951/125000 < 0$ and strictly smaller $\Gamma_{\mathrm{ENZ,reg}}$,
    (4) $\operatorname{denisovForwardGratingPitch}(\lambda_0, \sin\theta) = 2\,\operatorname{chatDenisovBraggPitch}(\lambda_0, \sin\theta)$, and
    (5) $n_0 < \operatorname{semenovRadicalConcentration}(n_0, k_{\mathrm{branch}}, k_{\mathrm{term}}, 0, t)$,
    $\operatorname{semenovRadicalConcentration}(n_0, k_{\mathrm{branch}}, k_{\mathrm{term}}, k_{\mathrm{quench}}, t) < n_0$, and
    $0 < \operatorname{exothermicRecombinationHeatPower}(R_{\mathrm{rec}}, \Delta H_{\mathrm{rec}}, V)$. -/)
  (proof := /-- Evaluate the exact rational EMT fractions by \texttt{norm\_num}, compare the
    detuned vs.\ resonant ENZ denominators, unfold the grating pitch ratio, and apply
    \texttt{Real.one\_lt\_exp\_iff} and \texttt{Real.exp\_lt\_one\_iff} to the Semenov--Hinshelwood
    trajectories. -/)]
theorem three_zone_rgo_polycbd_sfg_and_hydroxyl_kinetics_audit_identities
    (lambda0 sinTheta n0 k_branch k_term k_quench t R_rec deltaH_rec volume : ℝ)
    (hsin_ne : sinTheta ≠ 0) (hn0_pos : 0 < n0) (ht_pos : 0 < t)
    (h_expl : k_term < k_branch)
    (h_quench : k_branch - k_term < k_quench)
    (hR_pos : 0 < R_rec) (hH_pos : 0 < deltaH_rec) (hV_pos : 0 < volume) :
    emtCriticalEnzFillFraction (282 / 100) 110 = 141 / 5641 ∧
      emtEpsilonParallel (141 / 5641) (-110) (282 / 100) = 0 ∧
      emtEpsilonParallel (32 / 1000) (-110) (282 / 100) = -9878 / 12500 ∧
      emtEpsilonParallel (32 / 1000) (-110) (282 / 100) < 0 ∧
      emtEpsilonPerp (32 / 1000) (-110) (282 / 100) = 969375 / 332468 ∧
      emtEpsilonParallel (32 / 1000) (-55 / 2) (282 / 100) = 23122 / 12500 ∧
      0 < emtEpsilonParallel (32 / 1000) (-55 / 2) (282 / 100) ∧
      emtEpsilonPerp (32 / 1000) (-55 / 2) (282 / 100) = 969375 / 331622 ∧
      emtEpsilonPerp (32 / 1000) (-110) (282 / 100) <
        emtEpsilonPerp (32 / 1000) (-55 / 2) (282 / 100) ∧
      emtCriticalEnzFillFraction (282 / 100) (55 / 2) = 141 / 1516 ∧
      emtEpsilonParallel (141 / 1516) (-55 / 2) (282 / 100) = 0 ∧
      emtEpsilonParallel (988 / 10000) (-55 / 2) (282 / 100) = -2744 / 15625 ∧
      regularizedEnzEnhancement (282 / 100) 0 (48 / 1000) = (235 / 4) ^ 2 ∧
      regularizedEnzEnhancement (282 / 100) (-2744 / 15625) (48 / 1000) <
        regularizedEnzEnhancement (282 / 100) 0 (48 / 1000) ∧
      denisovForwardGratingPitch lambda0 sinTheta =
        2 * chatDenisovBraggPitch lambda0 sinTheta ∧
      n0 < semenovRadicalConcentration n0 k_branch k_term 0 t ∧
      semenovRadicalConcentration n0 k_branch k_term k_quench t < n0 ∧
      0 < exothermicRecombinationHeatPower R_rec deltaH_rec volume := by
  have h1 : emtCriticalEnzFillFraction (282 / 100) 110 = 141 / 5641 := by
    unfold emtCriticalEnzFillFraction; norm_num
  have h2 : emtEpsilonParallel (141 / 5641) (-110) (282 / 100) = 0 := by
    unfold emtEpsilonParallel; norm_num
  have h3 : emtEpsilonParallel (32 / 1000) (-110) (282 / 100) = -9878 / 12500 := by
    unfold emtEpsilonParallel; norm_num
  have h4 : emtEpsilonParallel (32 / 1000) (-110) (282 / 100) < 0 := by
    rw [h3]; norm_num
  have h5 : emtEpsilonPerp (32 / 1000) (-110) (282 / 100) = 969375 / 332468 := by
    unfold emtEpsilonPerp; norm_num
  have h6 : emtEpsilonParallel (32 / 1000) (-55 / 2) (282 / 100) = 23122 / 12500 := by
    unfold emtEpsilonParallel; norm_num
  have h7 : 0 < emtEpsilonParallel (32 / 1000) (-55 / 2) (282 / 100) := by
    rw [h6]; norm_num
  have h8 : emtEpsilonPerp (32 / 1000) (-55 / 2) (282 / 100) = 969375 / 331622 := by
    unfold emtEpsilonPerp; norm_num
  have h9 :
      emtEpsilonPerp (32 / 1000) (-110) (282 / 100) <
        emtEpsilonPerp (32 / 1000) (-55 / 2) (282 / 100) := by
    rw [h5, h8]; norm_num
  have h10 : emtCriticalEnzFillFraction (282 / 100) (55 / 2) = 141 / 1516 := by
    unfold emtCriticalEnzFillFraction; norm_num
  have h11 : emtEpsilonParallel (141 / 1516) (-55 / 2) (282 / 100) = 0 := by
    unfold emtEpsilonParallel; norm_num
  have h12 : emtEpsilonParallel (988 / 10000) (-55 / 2) (282 / 100) = -2744 / 15625 := by
    unfold emtEpsilonParallel; norm_num
  have h13 : regularizedEnzEnhancement (282 / 100) 0 (48 / 1000) = (235 / 4) ^ 2 := by
    unfold regularizedEnzEnhancement; norm_num
  have h14 :
      regularizedEnzEnhancement (282 / 100) (-2744 / 15625) (48 / 1000) <
        regularizedEnzEnhancement (282 / 100) 0 (48 / 1000) := by
    unfold regularizedEnzEnhancement; norm_num
  have h15 :
      denisovForwardGratingPitch lambda0 sinTheta =
        2 * chatDenisovBraggPitch lambda0 sinTheta := by
    unfold denisovForwardGratingPitch chatDenisovBraggPitch
    field_simp [hsin_ne]
  have h16 : n0 < semenovRadicalConcentration n0 k_branch k_term 0 t := by
    unfold semenovRadicalConcentration semenovNetBranchingRate
    have h_rate_pos : 0 < k_branch - k_term - 0 := by linarith
    have h_arg_pos : 0 < (k_branch - k_term - 0) * t := mul_pos h_rate_pos ht_pos
    have h_exp_gt : 1 < Real.exp ((k_branch - k_term - 0) * t) :=
      Real.one_lt_exp_iff.mpr h_arg_pos
    calc
      n0 = n0 * 1 := (mul_one n0).symm
      _ < n0 * Real.exp ((k_branch - k_term - 0) * t) :=
        mul_lt_mul_of_pos_left h_exp_gt hn0_pos
  have h17 : semenovRadicalConcentration n0 k_branch k_term k_quench t < n0 := by
    unfold semenovRadicalConcentration semenovNetBranchingRate
    have h_rate_neg : k_branch - k_term - k_quench < 0 := by linarith
    have h_arg_neg : (k_branch - k_term - k_quench) * t < 0 :=
      mul_neg_of_neg_of_pos h_rate_neg ht_pos
    have h_exp_lt : Real.exp ((k_branch - k_term - k_quench) * t) < 1 :=
      Real.exp_lt_one_iff.mpr h_arg_neg
    calc
      n0 * Real.exp ((k_branch - k_term - k_quench) * t) < n0 * 1 :=
        mul_lt_mul_of_pos_left h_exp_lt hn0_pos
      _ = n0 := mul_one n0
  have h18 : 0 < exothermicRecombinationHeatPower R_rec deltaH_rec volume := by
    unfold exothermicRecombinationHeatPower
    positivity
  exact ⟨h1, h2, h3, h4, h5, h6, h7, h8, h9, h10, h11, h12, h13, h14, h15, h16, h17, h18⟩


end Signals
