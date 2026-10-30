import Architect
import Signals.Pending
import Signals.PaperModels

namespace SignalsPending

open Signals.Pending

/-- Summary lemma: in a Pending bi-twistor wakefield momentum-sink contract,
the vehicle momentum change is equal and opposite to the momentum absorbed by the wakefield. -/
@[blueprint "lem:pending-twistor-sink-momentum-balance"
  (title := "Pending bi-twistor sink momentum conservation")
  (statement := /-- When a localized system transfers momentum $\Delta\mathbf P_{\mathrm{wake}}=\mathbf x_n-\mathbf x_1$
    to a bi-twistor wakefield sink, the vehicle momentum change satisfies
    $\Delta\mathbf P_{\mathrm{craft}}=-\Delta\mathbf P_{\mathrm{wake}}$. -/)
  (proof := /-- Apply \texttt{TwistorMomentumSinkHypothesis.craft\_momentum\_opposite\_wake}. -/)
  (latexEnv := "lemma")]
lemma twistor_sink_momentum_balance (hypothesis : TwistorMomentumSinkHypothesis) :
    hypothesis.craftMomentumChange = -hypothesis.wakefieldMomentum :=
  hypothesis.craft_momentum_opposite_wake

/-- Summary lemma: extracted electrical pulse energy in a Pending pulsed wakefield
Halbach cavity is bounded by the Dawson wave-breaking ceiling over the cavity volume. -/
@[blueprint "lem:pending-pulsed-wakefield-dawson-ceiling"
  (title := "Pending pulsed wakefield Dawson energy ceiling")
  (statement := /-- Extracted electrical energy per pulse satisfies
    $U_{\mathrm{extracted}}\le u_E(\varepsilon_0,E_{\mathrm{Dawson}})\,V_{\mathrm{cav}}$. -/)
  (proof := /-- Apply \texttt{PulsedWakefieldHalbachHypothesis.extracted\_pulse\_energy\_le\_dawson\_ceiling}. -/)
  (latexEnv := "lemma")]
lemma pulsed_wakefield_energy_ceiling (hypothesis : PulsedWakefieldHalbachHypothesis) :
    hypothesis.extractedPulseEnergy.joules ≤
      Signals.MHD.electrostaticWaveEnergyDensity hypothesis.permittivity
        hypothesis.dawsonFieldCeiling.voltsPerMeter *
        hypothesis.cavityVolume.cubicMeters :=
  hypothesis.extracted_pulse_energy_le_dawson_ceiling

/-- Summary lemma: without external drive power, a Pending supercritical DDF
phase-slip hull-stress model produces zero net forward thrust. -/
@[blueprint "lem:pending-ddf-zero-drive-zero-thrust"
  (title := "Pending supercritical DDF phase-slip requires external drive power")
  (statement := /-- If $P_{\mathrm{drive}}=0$ and $v>0$, supercritical DDF vortex shedding
    yields $F_{\mathrm{thrust}}=0$. -/)
  (proof := /-- Apply \texttt{DDFPhaseSlipHullStressHypothesis.zero\_drive\_zero\_thrust}. -/)
  (latexEnv := "lemma")]
lemma ddf_phase_slip_zero_drive_zero_thrust
    (hypothesis : DDFPhaseSlipHullStressHypothesis)
    (zero_drive : hypothesis.externalDrivePower.watts = 0) :
    hypothesis.inferredThrust.newtons = 0 :=
  hypothesis.zero_drive_zero_thrust zero_drive

/-- Summary lemma: at the 39 K MgB2 operating temperature and below 3.4 MPa,
He-3 is a supercritical gas and cannot solidify into a solid labyrinth seal. -/
@[blueprint "lem:pending-cryogenic-spool-he3-phase-bounds"
  (title := "Pending He-3 supercritical and solidification phase constraints")
  (statement := /-- At $T_{\mathrm{op}}=39\text{ K}$ and $P_{\mathrm{op}}<3.4\text{ MPa}$,
    $\mathrm{He\text{-}3}$ is a supercritical gas ($T_{\mathrm{op}}>3.32\text{ K}$) and cannot
    form a solid labyrinth seal. -/)
  (proof := /-- Combine \texttt{supercritical\_at\_39K} and \texttt{no\_solid\_seal\_below\_3\_4\_MPa}. -/)
  (latexEnv := "lemma")]
lemma cryogenic_spool_he3_phase_bounds
    (hypothesis : CryogenicSpoolAMBHypothesis)
    (h_temp : hypothesis.operatingTemperature.kelvin = 39)
    (h_press : hypothesis.operatingPressure.pascals < 3400000) :
    hypothesis.isSupercriticalGas ∧ ¬hypothesis.canSolidifyHe3 :=
  ⟨hypothesis.supercritical_at_39K h_temp,
    hypothesis.no_solid_seal_below_3_4_MPa h_press⟩

/-- Summary lemma: in a connected Hawking-radiation synthesis contract, the
shared-state `InverseGPEPoint` recovers the exact `InteractiveGPEPoint` potential,
`width ≤ height`, and whenever `2 * log 10 < S_BH / k_B`, the Page-curve
bond dimension strictly exceeds the configured `ALSRank`. -/
@[blueprint "lem:pending-hawking-synthesis-gpe-and-page-bounds"
  (title := "Pending Hawking synthesis GPE potential recovery and Page bond-dimension bound")
  (statement := /-- For any \texttt{contract : HawkingGrassmannianSynthesisContract width height sampleCount}
    with $2\ln 10 < S_{\mathrm{BH}}/k_B$,
    $\mathrm{decoding}.\mathrm{inverseGPE}.\mathrm{potential} = (\mathrm{decoding}.\mathrm{interactiveGPE}.\mathrm{potential} : \mathbb{C})$,
    $\mathrm{width} \le \mathrm{height}$, and
    $(\mathrm{decoding}.\mathrm{als}.\mathrm{rank}.\mathrm{rank} : \mathbb{R}) < \chi_{\mathrm{Page}}$. -/)
  (proof := /-- Combine \texttt{connected\_gpe\_potential\_recovery}, \texttt{width\_le\_height},
    and \texttt{als\_rank\_lt\_page\_bond\_dimension}. -/)
  (latexEnv := "lemma")]
lemma hawking_synthesis_gpe_and_page_bounds
    {width height sampleCount : ℕ}
    (contract : HawkingGrassmannianSynthesisContract width height sampleCount)
    (h_entropy : 2 * Real.log 10 < contract.horizonEntropyNats) :
    contract.decoding.inverseGPE.potential =
      (contract.decoding.interactiveGPE.potential : ℂ) ∧
    width ≤ height ∧
    (contract.decoding.als.rank.rank : ℝ) < contract.pageBondDimensionLowerBound :=
  ⟨contract.connected_gpe_potential_recovery.1,
    contract.decoding.width_le_height,
    contract.als_rank_lt_page_bond_dimension h_entropy⟩

end SignalsPending
