# Rust Numerical Adapter Specification

## Purpose

This specification defines the numerical layer for work that is intentionally
outside the Lean proof kernel:

- finite Gross-Pitaevskii/Madelung evolution and diagnostics;
- finite-time flow-map and FTLE/LCS calculations;
- Vortex-columnar array and file ingestion for measured or simulated flow data;
- one-sided trace, jump, and normal-flux residual calculations.

Lean remains the contract and provenance boundary. Rust may compute arrays,
time integrations, interpolants, covariance spectra, and residual statistics,
but a numerical result is not evidence for a Proca, SQG, fracture, or DDF
mechanism by itself.

## Responsibility Split

### Lean

Lean owns:

- units and named model fields;
- positive dimensions and explicit nonzero assumptions;
- supplied constitutive, balance, trace, jump, and tolerance laws;
- provenance metadata and sample linkage;
- small analytic identities and acceptance predicates;
- compile-time fixtures for serialized summaries.

### Rust/WASM

Rust owns:

- parsing Vortex artifacts and converting CSV/JSON/Arrow fixtures;
- checksum and schema validation;
- dense or sparse array storage;
- interpolation and finite-difference stencils;
- GP/Madelung time stepping;
- covariance positive-semidefinite checks;
- particle advection, deformation gradients, and FTLE fields;
- bootstrap or block-bootstrap uncertainty estimates;
- deterministic export of summaries and residual arrays.

The first Rust implementation should be a native CLI. WASM is a later target
for browser-side visualization or interactive parameter sweeps after the native
numerics and serialized schema are stable.

## Current Implementation Status

The native core is implemented in `numerical_adapter/` with no required
third-party numerical dependency. It currently provides metadata validation,
weak trace/jump residuals, covariance positive-semidefinite checks, diagonal
affine FTLE fixtures, a deterministic simulated affine-flow dataset, a
self-check CLI, and unit tests.

The optional Vortex round-trip uses Vortex `0.86.1` and the documented session,
in-memory write, and read APIs. The development Dockerfiles install
`libclang-dev` for the upstream `custom-labels` build dependency, and the
current environment has a passing fixed-u64 round-trip test. Do not treat this
fixture as benchmark or real-artifact validation; those remain separate steps.

The simulated affine-flow fixture is the first integrated dataset path. It
validates metadata, ordered time snapshots, covariance/GP diagnostics, and
affine FTLE output without claiming external measurement or solver validation.
Performance benchmarks are intentionally deferred until a representative real
artifact is selected.

The optional `hdf5` feature uses `hdf5-pure` 0.46.1 to ingest the public
PDEBench/DaRUS `Sod6.hdf5` solver artifact without a C library dependency.
`hdf5_io::read_pdebench_sod6` checks the source metadata, the `density`,
`pressure`, and `Vx` field shapes, monotone `x-coordinate` and `t-coordinate`
vectors, the recorded SHA-256 checksum, finite decoded values, and the
source-specific prefix policy for 201 field rows backed by 202 time
coordinates. It preserves the raw coordinate vectors and does not infer
covariance, healing length, or FTLE from this file.
The artifact is downloaded outside the repository; set
`SIGNALS_PDEBENCH_SOD6` to run the environment-gated integration test.

The separate `jhtdb_probe.py` utility uses `givernylocal` 3.6.2 to query the
JHTDB `channel` dataset. Its default bounded run samples 1024 spatial points at
two times, while the utility permits at most 4096 spatial points per request,
and records velocity, pressure, and velocity-gradient fields in an
NPZ artifact plus a JSON manifest. The manifest records the JHTDB dataset DOI,
ODC-By terms, client version, interpolation methods, coordinate ranges, query
times, generated-artifact SHA-256, and the fact that the temporary testing token
was not persisted. It intentionally does not claim a full-domain flow map or
FTLE field.

## Preferred Artifact Format: Vortex

Use [Vortex](https://github.com/vortex-data/vortex) as the primary artifact
format for large numerical arrays. The upstream project describes a Rust
columnar format with extensible encodings, Arrow interoperability, and lazy
statistics. These properties fit time-indexed flow fields better than parsing
large CSV or JSON files repeatedly.

HDF5 is a compatibility input, not a replacement for Vortex. The first
external artifact is the compact [PDEBench DaRUS Sod6 file](https://doi.org/10.18419/darus-2986):
the record identifies a CC BY 4.0 dataset, HDF5 storage, and a 4,948,776-byte
`Sod6.hdf5` file with solver-produced density, pressure, and velocity arrays.
Its stored `Vx` values are identically zero, so this artifact exercises parsing,
shape checks, provenance, and coordinate handling but does not provide a
resolved velocity flow map for FTLE.

The adapter must:

- pin the Vortex crate version and file-format edition in the run metadata;
- record the Vortex encoding set and schema hash;
- store dense fields as flattened columns with explicit shape, coordinate, and
  chunk metadata rather than relying on implicit array dimensions;
- chunk by time and spatial tile so FTLE windows and boundary faces can be read
  without materializing unrelated fields;
- preserve an Arrow conversion path for interoperability and test fixtures;
- retain CSV/JSON as small human-readable fixtures and emergency fallback
  inputs, not as the preferred large-array transport;
- benchmark Vortex versus Arrow/Parquet and fallback readers on representative
  density/velocity/covariance data before selecting chunk sizes.

The Vortex README states that the file format is intended to remain backwards
compatible from its 0.36.0 release, while library APIs may change. The adapter
must therefore pin both the crate API and the file-format edition, and must
reject unsupported editions with an `incomplete` or `invalid` status rather
than silently converting data.

For WASM, prefer native Vortex decoding when the pinned crate and encoding set
compile cleanly. Otherwise perform Vortex-to-Arrow/summary conversion in the
native CLI and send bounded chunks to the browser; do not force a large or
unsupported Vortex dependency into the browser bundle.

## Input Contract

Every run must include a metadata object matching the Lean
`FlowDatasetMetadata` boundary:

```json
{
  "artifact_reference": "data/flow/case-001.vortex",
  "artifact_checksum": "sha256:...",
  "license_reference": "...",
  "unit_convention": "SI",
  "calibration_reference": "...",
  "execution_context": "solver=...; mesh=...; timestep=..."
}
```

The numerical payload must additionally record:

- `origin`: `measured` or `simulated`;
- Vortex format edition, crate version, schema hash, and encoding set;
- case name and source label;
- grid dimensions and coordinate vectors;
- time stamps and monotonic time-step checks;
- density, pressure, temperature, and velocity components where available;
- covariance or replicate data when uncertainty is estimated;
- boundary faces and outward normals;
- sensor calibration and missing-value policy for measured data;
- solver, mesh, constitutive model, boundary conditions, and convergence report
  for simulated data.

No run is ingestion-ready when a required field is empty, a checksum does not
match, units are ambiguous, coordinates are non-monotone, or array shapes do
not agree.

The initial external readers are intentionally source-specific. A future generic
HDF5/Vortex schema should only be added after a second artifact demonstrates a
stable mapping for spatial coordinates, time windows, density, pressure,
velocity components, boundary faces, and uncertainty fields. The next measured
candidate is the [Zenodo cylinder PIV source](https://doi.org/10.5281/zenodo.20765567),
which supplies measured `u/v/x/y` fields at 20 Hz but no pressure or density.
The [RSPID source](https://doi.org/10.5281/zenodo.7832205) is a synthetic
positive-control suite for PIV reconstruction and must not be used as physical
validation. The compact MorphoDunes MATLAB files provide measured spatial PIV
fields and NaN masks, but the inspected file lacks an explicit time vector.
[JHTDB](https://turbulence.idies.jhu.edu/home) is the later cutout source for
large time-resolved DNS/LES fields.

The `rspid_subset_probe.py` utility validates an extracted RSPID image pair and
validation `.mat` file without requiring the full archive. It records image
shape/dtype, per-file SHA-256 values, validation-variable shapes, generator
parameters supplied by the source, and an explicit synthetic-control boundary.

The MATLAB v5 reader `matlab_piv_probe.py` now verifies the Zenodo cylinder
artifact, recognizes `u/v` arrays with shape `135 x 80 x 8000` and frame axis 2,
preserves NaN masks, and extracts an explicit bounded time window using the
20 Hz source calibration. The first verified extraction contains two frames at
`t = 0` and `0.05 s`; the source and derived NPZ checksums are recorded in
`OPEN_FLOW_DATASETS.md`. The reader rejects temporal extraction when a source
does not declare a sampling frequency, as with the inspected MorphoDunes file.

## Madelung/GP Diagnostics

The adapter must select one explicit regime before computing:

1. conservative Gross-Pitaevskii;
2. hydrodynamic/Thomas-Fermi approximation;
3. driven-dissipative or externally forced evolution.

It must not silently apply a conservative equation to driven data. For a
conservative GP state, the derived quantities are convention-dependent and
must record the convention for phase, mass, and Planck's constant:

- density $\rho$ and phase $S$;
- velocity $u = \hbar \nabla S / m$ when a phase field is available;
- healing length from the declared interaction and density model;
- compressibility from the declared equation of state;
- quantum-pressure terms only where density floors and boundary stencils are
  valid;
- covariance of local velocity or density replicates;
- residuals for mass, momentum, and energy balances.

A finite-difference or spectral implementation must report grid spacing,
time step, stencil/order, boundary treatment, density floor, and convergence
study. It must not infer incompressibility from a fixed covariance determinant.
Covariance validation should include a positive-semidefinite check, not only
symmetry and nonnegative diagonal entries.

## FTLE/LCS Diagnostics

FTLE requires a resolved velocity flow map, not a single velocity sample. For a
seed $x_0$ and integration window $T$, the adapter should:

1. interpolate the velocity field with a recorded spatial and temporal method;
2. integrate trajectories from $x_0$ and perturbed seeds;
3. estimate the deformation gradient $F = D\Phi_T(x_0)$, preferably with
   variational equations or a documented finite-difference stencil;
4. form $C = F^T F$ and compute its largest eigenvalue $\lambda_{max}$;
5. report $\sigma_T = |T|^{-1} \log\sqrt{\lambda_{max}}$;
6. include integration error, interpolation error, seed spacing, and window
   sensitivity in the output.

FTLE ridges are diagnostic candidates for material transport structures. They
are not automatically fractures, shocks, turbulence boundaries, or causal
interfaces. Analytic convergence cases must be included before interpreting
ridges in measured data.

## Weak Traces and Jumps

For a boundary face with outward normal $n$, compute one-sided values and the
normal flux using a declared convention. Export:

- left and right traces;
- trace jump and prescribed jump;
- left and right fluxes;
- flux jump and prescribed flux jump;
- test-function or weak-pairing value;
- weak-balance residual and tolerance;
- stencil/order and distance from the boundary.

The Rust result maps to `WeakTraceJumpContract`. A nonzero jump is a supplied
interface datum or an anomaly relative to a prescribed law; it is not a
fracture diagnosis. A full weak derivative theorem requires a selected
function space, measure, trace theorem, and flux pairing, so those assumptions
must be recorded before adding a stronger Lean abstraction.

## Output Contract

Export a deterministic result containing:

- input checksum and metadata;
- software version, numerical backend, and configuration hash;
- derived fields and units;
- residual arrays and summary statistics;
- covariance eigenvalues and PSD status;
- FTLE field, window, interpolation, and convergence diagnostics;
- weak trace/jump summaries;
- warnings for density floors, missing data, extrapolation, failed convergence,
  or under-resolved flow;
- explicit status: `computed`, `incomplete`, or `invalid`.

The Lean handoff should import only small summaries and fixture values first.
Those values should populate `MadelungGPSplat`, `MadelungGPGrid`,
`WeakTraceJumpContract`, and the existing `CompressibleFlowDataset` metadata;
raw arrays remain Rust-owned artifacts referenced by checksum.

## Validation Matrix

The native adapter must have tests for:

- uniform density and zero velocity: zero gradients and zero FTLE;
- affine velocity field: analytic deformation gradient and FTLE convergence;
- Gaussian density: healing-length and quantum-pressure stencil convergence;
- diagonal and rotated covariance: symmetry, PSD, and eigenvalue checks;
- a prescribed interface jump: exact trace/flux residual recovery;
- missing fields, bad checksums, unit mismatch, non-monotone coordinates, and
  inconsistent array shapes;
- refinement studies over spatial step, time step, interpolation order, and
  FTLE window;
- deterministic serialization and checksum round trips.
- Vortex-to-Arrow equivalence on representative columns and chunk selections;
- pinned-edition rejection and fallback-reader equivalence;
- native Vortex versus Arrow/Parquet read benchmarks for representative cases.

WASM tests should reuse native fixtures and compare summary values within an
explicit tolerance. Browser rendering must remain separate from numerical
correctness tests.

## Scholarly Basis

- Dalfovo et al., *Theory of Bose-Einstein condensation in trapped gases*,
  Rev. Mod. Phys. 71 (1999), DOI:
  https://doi.org/10.1103/RevModPhys.71.463.
- Carusotto and Ciuti, *Quantum fluids of light*, Rev. Mod. Phys. 85 (2013),
  DOI: https://doi.org/10.1103/RevModPhys.85.299.
- Chen and Frid, *Divergence-Measure Fields and Hyperbolic Conservation Laws*,
  Arch. Rational Mech. Anal. 147 (1999), DOI:
  https://doi.org/10.1007/s002050050146.
- Francfort and Marigo, *Revisiting brittle fracture as an energy minimization
  problem*, J. Mech. Phys. Solids 46 (1998), DOI:
  https://doi.org/10.1016/S0022-5096(98)00034-9.
- Haller, *Lagrangian Coherent Structures*, Annual Review of Fluid Mechanics 47
  (2015), DOI: https://doi.org/10.1146/annurev-fluid-010313-141322.

### Format Reference

- [Vortex project](https://github.com/vortex-data/vortex), Apache-2.0 columnar
  format and Rust toolkit. Treat its README and pinned release metadata as the
  format reference; performance claims must be reproduced locally.
