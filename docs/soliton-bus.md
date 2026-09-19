# Soliton Bus Model

This page documents the finite transport and operator contracts in
`Signals.SolitonBus`. The source chats describe a proposed N-LIG/Lignolux
architecture. They are design evidence, not evidence that a room-temperature
quantum processor, single-photon Kerr gate, or nondestructive parity detector
has been realized.

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
Kerr/non-Gaussian path [in the optical-gate discussion](../data/chats/Breakthrough-in-Extreme-Dielectric-Nanolasers.md#L302)
and proposes cross-phase modulation between OAM solitons [in the nonlinear interaction discussion](../data/chats/Breakthrough-in-Extreme-Dielectric-Nanolasers.md#L330).
Those claims remain conditional in the model.

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

## Validation

From `src/signals`:

```bash
lake build Signals SignalsTests
```

The focused tests cover multiplex selector matching, demultiplexing, Boolean
NAND identities, parity, routing-map involutions, operator inventory counts,
and matrix-vector application. The build still reports the repository's
pre-existing Physlib `if_pos` deprecation warning.