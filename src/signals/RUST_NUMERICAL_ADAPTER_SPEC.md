# Rust Numerical Adapter Specification

## Purpose

This specification defines the numerical layer for work that is intentionally
outside the Lean proof kernel:

- finite Gross-Pitaevskii/Madelung evolution and diagnostics;
- finite-time flow-map and FTLE/LCS calculations;
- array and file ingestion for measured or simulated flow data;
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

- parsing CSV, JSON, or binary array artifacts;
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

## Input Contract

Every run must include a metadata object matching the Lean
`FlowDatasetMetadata` boundary:

```json
{
  "artifact_reference": "data/flow/case-001.h5",
  "artifact_checksum": "sha256:...",
  "license_reference": "...",
  "unit_convention": "SI",
  "calibration_reference": "...",
  "execution_context": "solver=...; mesh=...; timestep=..."
}
```

The numerical payload must additionally record:

- `origin`: `measured` or `simulated`;
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
