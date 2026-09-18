# Open Flow Datasets

This note records the source identity, license, fields, and research boundary for
external flow data used by the Signals numerical adapter. A source artifact is
not evidence for a proposed Proca, SQG, fracture, or DDF mechanism. The adapter
keeps source provenance separate from derived diagnostics.

## Research Extensions

| Source | Data status | Useful extension | Required controls | Current boundary |
| --- | --- | --- | --- | --- |
| PDEBench `Sod6.hdf5` | Solver-produced, 1D, HDF5 | Parser, checksum, shape, coordinate, and provenance validation | Solver metadata and source checksum | `Vx` is zero; no resolved flow map or FTLE |
| JHTDB `channel` | Solver-produced DNS, remote service | 3D velocity/pressure/gradient sampling, particle advection, flow-map and FTLE probes | Query manifest, interpolation method, time window, spatial resolution, ODC-By attribution | Bounded query is not full-domain validation |
| Zenodo cylinder PIV | Measured 2D velocity sequence | Measured flow-map/FTLE and velocity-gradient diagnostics | PIV missing-mask handling, calibration, sampling frequency, uncertainty, spatial interpolation | No pressure, density, or 3D velocity |
| Zenodo RSPID | Synthetic PIV images with known flow families | PIV/optical-flow algorithm controls and ground-truth error | Preserve generator parameters, validation MAT files, image calibration, and train/test separation | Synthetic benchmark, not physical validation |
| MorphoDunes PIV | Measured 2D `uPIV`/`vPIV` fields | Measured turbulence and spatial residual comparisons | Recover time metadata, NaN mask, units, bed geometry, and run conditions | Compact files inspected so far lack an explicit time vector |

The extension order is deliberate:

1. Use JHTDB for a bounded solver-produced velocity/pressure/gradient probe.
2. Use the cylinder PIV artifact for the first measured time-resolved flow-map adapter.
3. Use RSPID as a synthetic positive-control suite for PIV reconstruction and missing-data sensitivity.
4. Add particle advection, deformation-gradient estimation, and FTLE only after time coordinates, interpolation error, and missing masks are explicit.
5. Add density, pressure, temperature, and boundary/control-volume comparisons only where the source actually supplies those fields.

A two-time velocity sample is not by itself an FTLE field. FTLE requires a
resolved flow map over a declared time window, interpolation rules, and a
convergence or sensitivity check. A measured velocity field is not a pressure,
density, or energy-validation dataset unless those quantities and calibration
are independently available.

## JHTDB Attribution and Bounded Probe

**Source:** Johns Hopkins Turbulence Database (JHTDB), channel-flow dataset.

- Database: <https://turbulence.idies.jhu.edu/home>
- Dataset DOI: <https://doi.org/10.7281/T10K26QW>
- Data terms: Open Data Commons Attribution License (ODC-By), with attribution required.
- Suggested database citation: Y. Li, E. Perlman, M. Wan, Y. Yang, C. Meneveau, R. Burns, S. Chen, A. Szalay, and G. Eyink, "A public turbulence database cluster and applications to study Lagrangian evolution of velocity increments in turbulence," *Journal of Turbulence* 9, No. 31 (2008).
- Client: `givernylocal` 3.6.2, Apache-2.0, <https://github.com/sciserver/giverny>.
- Fields queried: velocity, pressure, and velocity gradient.
- Query methods: `lag8` field interpolation for velocity and pressure; `fd4lag4` velocity gradient; no temporal interpolation.
- Probe: 1024 points on a 32 x 32 plane at `y = 0`, at `t = 1.0` and `t = 1.1`.
- Temporary-token policy: the testing token is used only for at most 4096 spatial points per request. The token is never written to the artifact or manifest.
- Verified local output: `jhtdb_channel_probe.npz` plus `jhtdb_channel_probe.manifest.json` under `.tmp/jhtdb_probe/`; the default 1024-point probe SHA-256 is `206ea4e3820593f41a3acc1097a5ed43bf4045ad3a6b281d2a0a3c9096c1cdea`, and the capped 4096-point probe SHA-256 is `847c6dfc59023228b697767373e033993ad211b8bd1bb7599cf3dd93cbbfd947`; neither file is committed.

The JHTDB service is a database, not one downloadable finite file. Its published
DNS/LES collections are multi-terabyte or larger, and the service provides
pointwise queries and HDF5 cutouts. A full-database download is therefore not a
reproducible first step; a bounded cutout with query metadata and checksums is the
appropriate artifact boundary.

## Cylinder PIV Attribution

**Source:** Jessica Shang and Jonathan Tu, "Particle image velocimetry (PIV)
data of flow past a cylinder" (2026), Zenodo.

- DOI: <https://doi.org/10.5281/zenodo.20765567>
- File: `cylinder_vel.mat`
- Source file size: 1,082,404,799 bytes.
- Source MD5: `4cc876439c48f7970afa477ea17d217a`.
- License: CC BY 4.0.
- Variables: `u`, `v`, `x`, and `y`; velocity is in m/s and coordinates are in m.
- Verified MATLAB schema: `u`/`v` have shape `135 x 80 x 8000` with frame axis 2;
  `x`/`y` have shape `135 x 80`.
- Experiment: planar PIV in a recirculating water channel, cylinder Reynolds number 413, mid-span plane, 20 Hz sampling.
- Processing: LaVision DaVis 8.1.2.
- Related publication: J. H. Tu et al., "Spectral analysis of fluid flows using sub-Nyquist-rate PIV data," *Experiments in Fluids* (2014), <https://doi.org/10.1007/s00348-014-1805-6>.
- Verified source SHA-256: `328cd8d17cd2eb42faef6e4766bc8e515e0eac06868152972adab9bdf91926e7`.
- Verified bounded extraction: first two frames at `t = 0` and `0.05 s`,
  output `2 x 135 x 80` `u/v` arrays with 21,600 valid vector values and
  NPZ SHA-256 `d47053c16f9c4c207a7e528e7ccb8c70761f5c487da9dc36d2d12e1f9548912f`.

This is the best measured source for the first flow-map/FTLE adapter. The adapter
must preserve masked values, retain the original `u/v` arrays and grids, record
the 20 Hz interval, and avoid inventing pressure, density, or out-of-plane
velocity. A derived FTLE result remains a measured-data diagnostic, not proof of
a fracture or new propagation mechanism.

## RSPID Attribution

**Source:** Michel Machado and Douglas Rocha, "Raw Synthetic Particle Image
Dataset (RSPID)" (2023), Zenodo.

- DOI: <https://doi.org/10.5281/zenodo.7832205>
- File: `raw_synthetic_piv_data.zip`.
- Source file size: 2,148,369,223 bytes.
- Source MD5: `45ba1313960c4448f669654ddd8a850c`.
- License: CC BY 4.0.
- Generator: PIV Image Generator software.
- Image configuration: 665 x 630 pixels, 8-bit images, particle-radius/density/noise/out-of-plane parameters, and multiple displacement factors.
- Flow families: uniform, Rankine vortex, parabolic, stagnation, shear, and decaying vortex.
- Ground truth: validation `.mat` files are included beside image pairs.
- Generator reference: Mendes, Bernardino, and Ferreira, "PIV-Image-Generator: A software package for planar PIV and optical flow benchmarking," *SoftwareX* 12 (2020), 100537, <https://doi.org/10.1016/j.softx.2020.100537>.

RSPID is the positive-control source for PIV reconstruction, image noise,
missing-vector masks, and known-flow error. It must not be described as measured
fluid behavior. The first useful subset is one flow family plus its paired images
and validation file, not the entire 2.1 GB archive.

## MorphoDunes Compact Measured Candidate

**Source:** Gaetano Porcile, D. Mouaze, P. Weill, A. Gangloff, and A. C. Bennis,
"Laboratory PIV dataset for tidal dune hydrodynamics - MorphoDunes Project"
(2025), Zenodo.

- DOI: <https://doi.org/10.5281/zenodo.16414450>
- License: CC BY 4.0.
- Files: four MATLAB runs, approximately 1.3-1.5 MB each.
- Inspected file: `EbbNeapHighRough-Exp3.mat`, SHA-256 `7ad9c3ae3d7ebc2d8a44a6f5b92d8cdf48920e108286b0c7ba0522b5559cdb68`.
- Variables: `uPIV`, `vPIV`, `xPIV`, `yPIV`, `zPIV`.
- Inspected shapes: velocity/grid arrays `624 x 151`; `zPIV` `624 x 1`.
- Missingness: velocity arrays contain NaNs and require an explicit mask.

The compact file is valuable for measured spatial diagnostics and NaN-mask
handling, but its inspected schema has no explicit time vector. It is therefore
not the first FTLE source unless the associated publication/run metadata supplies
temporal sampling and the four runs are shown to be consecutive frames rather
than distinct conditions.

## PDEBench Attribution

**Source:** Makoto Takamoto, Timothy Praditia, Raphael Leiteritz, Dan MacKinlay,
Francesco Alesiani, Dirk Pflueger, and Mathias Niepert, *PDEBench Datasets*.

- DOI: <https://doi.org/10.18419/darus-2986>
- License: CC BY 4.0.
- Selected file: `Sod6.hdf5`, DaRUS datafile 133150.
- Fields: `density`, `pressure`, `Vx`, `x-coordinate`, `t-coordinate`.
- Boundary: solver-produced HDF5 schema/provenance test only; the stored `Vx`
  field is zero, and the source time coordinate has 202 values for 201 field
  rows. It does not support a resolved FTLE or physical validation by itself.
