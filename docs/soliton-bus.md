# Soliton Bus Model

This page documents the finite transport and operator contracts in
`Signals.SolitonBus`. The source chats describe a proposed N-LIG/Lignolux
architecture.

## Chat-Derived Design

The reviewed chat corpus groups the bus design into four related layers:

| Layer | Chat-derived proposal | Model boundary |
| --- | --- | --- |
| Multiplexing | WDM, MDM, OAM, and A2Q soliton-bus addressing | Lane addresses and selectors are finite data; they do not prove independent physical channels. |
| Routing | Thermo-optic address trees, demultiplexers, bucket-brigade routing, and OAM sorting | `RoutingPlan` requires an injective destination map; switching latency and crosstalk remain calibration data. |
| Readout | Kerr cross-phase modulation, probe-beam phase shifts, and homodyne detection | The phase relation is a conditional interaction contract; it is not a proof of nondestructive quantum measurement. |
| Operators | Gaussian quadrature operations, beam splitters, phase gates, CNOT-like gates, and nonlinear phase interactions | Finite matrices and phase-space maps are implemented; material coupling and universal hardware operation are not inferred. |

The source request explicitly groups WDM, MDM, OAM, A2Q, squeezed-state
readout, and nondestructive phase measurement [in the signal-phase chat](../data/chats/IQ-Sampling-for-Signal-Phase.md#L8547).
The same chat proposes OAM encoding and a Kerr probe path [at the bus design section](../data/chats/IQ-Sampling-for-Signal-Phase.md#L8589).
The proposed N-LIG architecture also describes the signal bus, OAM qudit
payload, and a Kerr cavity [in the interaction-zone design](../data/chats/IQ-Sampling-for-Signal-Phase.md#L8729).

The separate architecture chat proposes wavelength as a coarse address and a
thermo-optic layer as a fine decoder [in its address-tree description](../data/chats/_Quantum%20Processor%20and%20Soliton%20Discussions%20%20.md#L363).
It describes bucket-brigade routing as a simulation target, with switch
latency and loss as quantities to measure [in the network-routing plan](../data/chats/_Quantum%20Processor%20and%20Soliton%20Discussions%20%20.md#L582).

## Classical Transport API

`LaneAddress` represents five independent multiplexing coordinates:

- wavelength channel for WDM;
- spatial mode for MDM;
- integer orbital-angular-momentum charge;
- polarization channel;
- time slot for TDM.

`LaneSelector` enables any subset of those coordinates. `demultiplex` filters
finite frame lists by the enabled selector fields. `BusNetwork` and
`RoutingPlan` represent a finite lane fabric; the route map must be injective,
so the contract does not silently merge two source lanes. `broadcastLanes`
represents a finite bucket-brigade fan-out.

The classical logic inventory includes identity, NOT, NAND, AND, OR, XOR, XNOR,
and NOR. The lemmas `nand_complete_not`, `nand_complete_and`, and
`nand_complete_or` show the usual NAND-derived identities for Boolean values.
The inventory is complete as a finite Boolean operator set; it is not a
throughput or hardware-timing claim.

## Quantum and CV Operators

The module uses explicit finite complex matrices and amplitude-vector
application, so it does not require a second Lean package or silently import a
different mathlib build.

The finite one-qubit inventory contains:

- Pauli X, Y, and Z;
- Hadamard, also exposed as the balanced dual-rail beam-splitter matrix;
- parameterized unit-modulus phase gates.

The multi-mode inventory contains explicit CNOT, SWAP, controlled-phase, and
Toffoli matrices. Standard one-qubit operators carry checked finite unitarity
lemmas. Multi-qubit matrices remain explicit operator data until their
permutation-unitarity lemmas are added.

The finite quadrature layer supplies displacement, phase rotation, reciprocal
squeezing, balanced beam splitting, Kerr phase shift, and cross-phase
modulation. These are finite mathematical operators, not claims that N-LIG
provides the required nonlinear coefficient or low-loss quantum regime.

The chat proposal describes Gaussian rotations and squeezing together with a
Kerr/non-Gaussian path in `data/chats/Breakthrough-in-Extreme-Dielectric-Nanolasers.md`
and proposes cross-phase modulation between OAM solitons in that same chat.
Those claims remain conditional in the model.

## Dynamics Contracts

The propagation layer now records the standard finite nonlinear-envelope
quantities used in hollow-core soliton work:

$$
L_D = \frac{T_0^2}{|\beta_2|}, \qquad
L_{NL} = \frac{1}{\gamma P_0}, \qquad
N^2 = \frac{L_D}{L_{NL}}.
$$

`SolitonPropagationDynamics` stores the pulse duration $T_0$, peak power
$P_0$, anomalous group-velocity dispersion $\beta_2$, nonlinear coefficient
$\gamma$, both characteristic lengths, and the supplied soliton order. The
record also keeps self-compression and resonant-dispersive-wave observations as
hypotheses, because those outcomes depend on gas pressure, core geometry,
loss, mode matching, and photoionization.

`SolitonCollisionDynamics` makes the two-pulse interaction explicit:

$$
\Delta\phi_{probe,XPM} = \gamma_{XPM} P_{signal} L_{eff}.
$$

The phase law is checked algebraically. The coefficient includes the chosen
XPM convention and modal-overlap factor; it is not a universal material
constant. Collision observation, nonabsorption, and crosstalk remain measured
or conditional fields. This is the appropriate boundary for XPM and Kerr
proposals: a formula for phase shift is not a demonstrated single-photon gate.

This is also a review correction: the phase shift is driven by the interacting
signal power, not by the probe power being phase-shifted. Both powers remain in
the record so self-phase, probe loading, and collision bookkeeping can be
extended without changing the meaning of the XPM law.

`OAMMultiplexingObservation` records fibre length, mode-group count, symbol
rate, data rate, modal crosstalk, and MIMO equalizer order. The long-haul OAM
experiment below demonstrates modal transport and equalization, but it does
not demonstrate soliton propagation or N-LIG fabrication.

`SolitonDynamicsOperator.defaultPlacement` separates operator location:

| Placement | Operators | Interpretation |
| --- | --- | --- |
| `onBus` | linear propagation, self-phase modulation, XPM, self-compression, OAM mode coupling | Co-propagating or in-guide dynamics, subject to dispersion, loss, and modal calibration. |
| `busInterface` | resonant dispersive-wave generation, parity measurement | Requires a spectral or measurement boundary; not a transparent bus primitive by default. |
| `offBus` | homodyne readout | A detector/local oscillator path outside the transported signal mode. |

### Scholarly References

<a id="travers2019"></a> Travers, J. C., Grigorova, T. F., Brahms, C., and Belli, F. (2019), [High-energy pulse self-compression and ultraviolet generation through soliton dynamics in hollow capillary fibres](https://doi.org/10.1038/s41566-019-0416-4). Experimental hollow-capillary self-compression and UV dispersive-wave generation.

<a id="travers2024"></a> Travers, J. C. (2024), [Optical solitons in hollow-core fibres](https://doi.org/10.1016/j.optcom.2023.130191). Review of gas-filled hollow-core propagation, self-compression, Raman shifting, photoionization, plasma, and dispersive-wave effects.

<a id="kivshar1993"></a> Kivshar, Y. S., and Quiroga-Teixeiro, M. L. (1993), [Influence of cross-phase modulation on soliton switching in nonlinear optical fibers](https://doi.org/10.1364/ol.18.000980). Coupled nonlinear-fibre model for XPM-mediated soliton switching.

<a id="wang2018"></a> Wang, A. et al. (2018), [Directly using 88-km conventional multi-mode fiber for 6-mode orbital angular momentum multiplexing transmission](https://doi.org/10.1364/oe.26.010038). The title says 88 km, while the abstract reports 8.8 km of OM4 fibre; the model follows the abstract and records 120-Gbit/s QPSK, six OAM mode groups, and 2x2 or 4x4 MIMO equalization.

## Evidence Boundary

The implementation does not establish:

- room-temperature soliton stability in N-LIG or rGO-Vitrimer;
- preservation of a quantum state through a proposed material bus;
- single-photon-strength Kerr coupling;
- nondestructive parity measurement;
- entropy siphoning or vacuum-noise removal;
- a fault-tolerant QPU or QRAM architecture.

QECLean was evaluated as a possible adapter. Its cached artifacts were built
against a different mathlib context from Signals, so the public bus module uses
a self-contained finite-matrix layer instead of making QECLean a hard
dependency. The QECLean source remains available for future adapter work after
toolchain alignment.

## Soliton-Bus Quantum Error-Coding Plan

### Recovered design choices

The chat corpus search was case-insensitive literal `soliton` over
`data/chats/*.md` only. `rg` was unavailable in the active terminal, so the
equivalent `grep -i` search was used; it found 22 Markdown files. Detailed
review focused on the processor/soliton and hardware-architecture chats cited
below. These chats recover proposals, not experimental validation.

These choices belong to separate axes: a design chooses how signals are
addressed, how each code block encodes a state, and how checks are measured.
They should not be collapsed into one meaning for “multiplexing.”

1. **Hierarchical optical addressing.** The proposal uses WDM as a coarse
	depth/layer selector, OAM or MDM as a finer channel selector, and a
	thermo-optic switch as an active route into an ancilla or memory layer. The
	chats also propose TDM to reuse a waveguide at different pulse times
	([depth and OAM routing](../data/chats/_Quantum%20Processor%20and%20Soliton%20Discussions%20%20.md#L256),
	[time-bin reuse](../data/chats/_Quantum%20Computing%20Hardware%20Architectures%20Review%20%20.md#L1477)).
	**Use in v1:** represent these as address/scheduling coordinates only.
	Address separation does not prove low crosstalk or independent quantum
	channels.
2. **Port graph with an ancilla hub.** The proposed star has data leaves
	reached through a central ancilla, with bus operations intended to support
	stabilizer measurements ([star and bus-connected checks](../data/chats/_Quantum%20Processor%20and%20Soliton%20Discussions%20%20.md#L3172),
	[paper architecture](paper.myst.md#L60)). **Use in v1:** call each
	physical endpoint a `BusPort`; represent possible interactions with an
	explicit coupling relation. A port is not itself a code qubit or a
	stabilizer. The measurement order, ancilla reuse, fault propagation, and
	photonic resource/measurement primitive still need specification.
3. **Multiplexed OAM qudit.** An alternative is to use a finite OAM basis as
	the data state, so mode shifts, phases, leakage, and mode mixing are data
	errors rather than just routing errors. The existing OAM-100 record is
	readiness metadata: the review explicitly says it lacks an OAM encoding
	map, syndrome readout, and recovery, and requires mode-dependent loss and
	crosstalk characterization ([OAM boundary and next measurements](paper-model-review.md#L1077),
	[QEC readiness fields](paper-model-review.md#L1137)). **Defer as a separate
	qudit-code project.** A coherent superposition over OAM modes is one
	qudit state, not a collection of independent addressed channels.
4. **Propagating GKP/CV state.** A grid state with homodyne syndrome
	measurements is a distinct continuous-variable encoding path. The paper
	review describes the cited optical work as a logical-state precursor, not
	completed fault-tolerant computation, and the qutrit/ququart break-even
	experiment is not an OAM experiment ([optical-state boundary](paper-model-review.md#L1071),
	[qudit experiment boundary](paper-model-review.md#L1098)). **Keep outside
	the first qubit/erasure API.**
5. **Layer-code geometry.** Layer codes are a CSS-to-3D topological-code
	construction: their layers and 1D junctions come from Tanner incidences.
	They are not optical wavelength layers or OAM channels. The paper’s
	construction supplies mathematical code properties, not a photonic
	decoder, threshold, or hardware benchmark ([Layer-code review](paper-model-review.md#L916)).
	**Treat this as a later code-family contribution**, independent of the
	optical address scheme.

### First implementation decision

For the first implementation, WDM, MDM, OAM, polarization, and TDM are
**transport/address dimensions**. QEC is defined over an abstract finite set
of qubit blocks, independently of which optical degree of freedom eventually
encodes each block. This matches the existing `LaneAddress`/`LaneSelector`
boundary and lets QECLean prove qubit-code facts without making claims about
N-LIG, OAM devices, or a quantum bus. OAM-as-data remains an explicit
alternative encoding, never an implicit interpretation of `oamCharge`.

Use **port** for the hardware endpoint and **address** for the multiplex
selector:

- `BusPort` identifies a coupler, interface, detector, or check-measurement
  endpoint. It is distinct from `LaneAddress`; multiple addresses may be
  routed through one port at different times.
- `PortCoupling` (or a finite port graph) records which endpoints can interact
  and with what calibrated coupling/crosstalk. Do not define physical
  adjacency as consecutive `Fin` indices or infer it from OAM charge.
- `CodeBlockPlacement` maps each abstract code-block ID to its required port
  and lane address(es). Require injectivity where resources must be distinct;
  model time-shared resources with an explicit schedule rather than pretending
  they are separate hardware.
- An `EncodingChoice` states whether the eventual data encoding is an abstract
  qubit, a specified qubit encoding, an OAM qudit of dimension `d`, or a CV/GKP
  mode. The v1 Signals contract records the choice and its evidence status;
  it does not prove that a proposed encoding is physically realized.

### Signals work

Add a focused `Signals/SolitonQEC.lean` module under `Signals.Pending`, reusing
`Signals.SolitonBus.LaneAddress`, `BusNetwork`, and the existing unit and
bounded-factor wrappers. Keep it out of the verified classical transport API
until its fields describe calibrated observations or purely mathematical
invariants.

The deployment/noise contract should make these inputs explicit:

- finite code-block and port indices, address-to-port placement, and the
  selected encoding interpretation;
- a measured or assumed port-coupling graph, including which nearby signals
  can produce correlated faults;
- mode-resolved loss with a distinction between **flagged erasure** and
  **unflagged loss**, plus detector efficiency and false/missed-flag rates;
- mode crosstalk, phase/timing error, check-readout error, and correlated error
  support, each with units or normalization, uncertainty, calibration status,
  and provenance where available;
- a syndrome-extraction/readout contract that says which check is measured,
  by what photonic primitive, with what outcome and disturbance bounds.

Add focused examples for unique and colliding addresses, two addresses routed
through one scheduled port, a flagged versus unflagged loss, and a correlated
neighbor fault. These tests validate record laws and reject missing
assumptions; they do not establish QEC performance. In particular, the
existing XPM phase law is not a QND parity measurement, and the proposed
room-temperature/no-dispersion, 10 GHz, and entropy-siphoning statements in
`paper.myst.md` remain design claims, not fields to promote to verified facts
([paper architecture and claims](paper.myst.md#L60),
[paper-model-review evidence boundary](paper-model-review.md#L1)).

### QECLean contribution

Add a dependency-free, qubit-stabilizer erasure API in a new logical-framework
module such as
`QEC/Stabilizer/Framework/Core/Logical/ErasureCorrection.lean`, exported
through the existing `Core.Logical` and `Core` umbrellas. Its public input is
a known erased support `E : Finset (Fin n)`; define erasure correctability by
the absence of a nontrivial logical Pauli supported entirely inside `E`,
including the project’s phase-equivalence convention.

Prove the two useful interfaces:

1. The stabilizer-code erasure criterion: the Pauli error set supported in
	`E` is jointly correctable exactly when no nontrivial logical operator is
	supported in `E`.
2. The distance corollary: for a code of distance `d`, every known erasure
	set with `E.card < d` is correctable. This is the erasure bound; do not
	replace it with the unknown-error bound `2t < d`.

Use the existing Pauli support, logical-operator, and code-distance
abstractions. Add a small checked example with the existing `[[5,1,3]]` code
showing correction of a single known erased qubit, plus a boundary example
where an erased set contains a logical support. This theorem is a code
property, not an erasure decoder, channel model, or hardware threshold. Keep
the work independent of `Signals` and `Physlib`; QECLean’s Lake configuration
already uses mathlib and its own Lean tooling, and this contribution needs no
new dependency. The existing [Layer scaffold](../src/QECLean/QEC/Stabilizer/Codes/Layer.lean#L274)
can use the API later, but deriving its defect stabilizers is a separate task.

### Cross-project handoff and gates

Do not import either Lean library into the other. For the first cross-check,
maintain one tiny documented fixture containing only the finite block IDs,
address/port placement, X/Z check data, erased-block set, and code parameters.
Signals checks placement and declared calibration/noise fields; QECLean checks
the code and erasure theorem. Keep physical observations and units on the
Signals side, not in QECLean.

The implementation sequence is:

1. Add and test the Signals Pending deployment/noise contract.
2. Add the generic QECLean erasure criterion and distance corollary; test the
	`[[5,1,3]]` one-erasure case.
3. Instantiate one finite fixture on both sides without a package dependency.
4. Only after detector and channel calibration, add a measured noise model and
	assess a concrete syndrome circuit/decoder. Keep OAM-qudit codes, CV/GKP
	codes, a full Layer-code lift, room-temperature operation, threshold,
	scalable throughput, and thermodynamic cooling claims outside v1.

For docs-only changes, build the Sphinx docs and run `git diff --check`. When
code is added, also run the Signals build and QECLean’s focused Lean build.

## Validation

From `src/signals`:

```bash
lake build Signals SignalsTests
```

The focused tests cover multiplex selector matching, demultiplexing, Boolean
NAND identities, parity, routing-map involutions, operator inventory counts,
and matrix-vector application. The build still reports the repository's
pre-existing Physlib `if_pos` deprecation warning.