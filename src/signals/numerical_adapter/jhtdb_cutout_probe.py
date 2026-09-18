#!/usr/bin/env python3
"""Acquire a bounded, attributed JHTDB HDF5 cutout.

The temporary JHTDB token is read only from ``JHTDB_AUTH_TOKEN`` and is never
written to the output manifest. Defaults intentionally request a tiny 8x8x8
brick at two channel-flow time indices.
"""

from __future__ import annotations

import argparse
import hashlib
import importlib.metadata
import json
import os
from pathlib import Path

import numpy as np
from givernylocal.turbulence_dataset import turb_dataset
from givernylocal.turbulence_toolkit import getCutout, write_cutout_hdf5_and_xmf_files

DATABASE_REFERENCE = "https://turbulence.idies.jhu.edu/home"
DATASET_REFERENCE = "https://doi.org/10.7281/T10K26QW"
LICENSE_REFERENCE = "https://opendatacommons.org/licenses/by/"
POINT_LIMIT = 4096


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def count_axis(axis_range: list[int], stride: int) -> int:
    if len(axis_range) != 2 or axis_range[1] < axis_range[0] or stride <= 0:
        raise ValueError(f"invalid axis range/stride: {axis_range}, {stride}")
    return (axis_range[1] - axis_range[0]) // stride + 1


def acquire(
    output_dir: Path,
    variable: str,
    x_range: list[int],
    y_range: list[int],
    z_range: list[int],
    t_range: list[int],
    strides: list[int],
    output_stem: str,
) -> Path:
    auth_token = os.environ.get("JHTDB_AUTH_TOKEN")
    if not auth_token:
        raise SystemExit("JHTDB_AUTH_TOKEN must be set in the environment")
    if len(strides) != 4:
        raise ValueError("strides must contain x, y, z, and t values")
    dimensions = [
        count_axis(x_range, strides[0]),
        count_axis(y_range, strides[1]),
        count_axis(z_range, strides[2]),
        count_axis(t_range, strides[3]),
    ]
    point_count = int(np.prod(dimensions))
    if point_count > POINT_LIMIT:
        raise ValueError(f"bounded cutout has {point_count} values; limit is {POINT_LIMIT}")

    output_dir.mkdir(parents=True, exist_ok=True)
    cube = turb_dataset("channel", str(output_dir), auth_token)
    axes_ranges = np.array([x_range, y_range, z_range, t_range], dtype=np.int64)
    result = getCutout(cube, variable, axes_ranges, np.array(strides, dtype=np.int64), verbose=False)
    write_cutout_hdf5_and_xmf_files(cube, result, output_stem)

    hdf5_path = output_dir / f"{output_stem}.h5"
    xmf_path = output_dir / f"{output_stem}.xmf"
    if not hdf5_path.exists() or not xmf_path.exists():
        raise RuntimeError("JHTDB cutout writer did not produce both HDF5 and XMF files")
    manifest = {
        "source": {
            "name": "Johns Hopkins Turbulence Database",
            "database_reference": DATABASE_REFERENCE,
            "dataset": "channel",
            "dataset_reference": DATASET_REFERENCE,
            "license_reference": LICENSE_REFERENCE,
            "citation": "Li et al., A public turbulence database cluster and applications to study Lagrangian evolution of velocity increments in turbulence, Journal of Turbulence 9 (2008), No. 31",
            "client": f"givernylocal {importlib.metadata.version('givernylocal')}",
        },
        "query": {
            "variable": variable,
            "axis_ranges": {"x": x_range, "y": y_range, "z": z_range, "t": t_range},
            "strides": {"x": strides[0], "y": strides[1], "z": strides[2], "t": strides[3]},
            "shape": dimensions,
            "value_count": point_count,
            "temporary_token_policy": "testing token; bounded cutout at or below 4096 values",
        },
        "result": {
            "dimensions": {name: int(size) for name, size in result.sizes.items()},
            "variables": sorted(str(name) for name in result.data_vars),
            "attributes": {str(key): str(value) for key, value in result.attrs.items()},
        },
        "artifacts": {
            "hdf5": {"path": hdf5_path.name, "sha256": sha256_file(hdf5_path)},
            "xmf": {"path": xmf_path.name, "sha256": sha256_file(xmf_path)},
            "token_recorded": False,
            "full_database_downloaded": False,
        },
        "interpretation_boundary": {
            "supports": ["bounded solver-produced velocity cutout", "HDF5 ingestion", "future particle-advection input"],
            "does_not_establish": ["experimental validation", "full-domain FTLE", "DDF, fracture, Proca, SQG, or FTL mechanisms"],
        },
    }
    manifest_path = output_dir / f"{output_stem}.manifest.json"
    manifest_path.write_text(json.dumps(manifest, indent=2) + "\n")
    return manifest_path


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output-dir", type=Path, default=Path(".tmp/jhtdb_cutout_probe"))
    parser.add_argument("--variable", default="velocity")
    parser.add_argument("--x-range", nargs=2, type=int, default=[1, 8])
    parser.add_argument("--y-range", nargs=2, type=int, default=[105, 112])
    parser.add_argument("--z-range", nargs=2, type=int, default=[1, 8])
    parser.add_argument("--t-range", nargs=2, type=int, default=[1, 2])
    parser.add_argument("--strides", nargs=4, type=int, default=[1, 1, 1, 1])
    parser.add_argument("--output-stem", default="channel_velocity_8cube_2time")
    args = parser.parse_args()
    manifest = acquire(
        args.output_dir,
        args.variable,
        args.x_range,
        args.y_range,
        args.z_range,
        args.t_range,
        args.strides,
        args.output_stem,
    )
    print(f"JHTDB cutout manifest written: {manifest}")


if __name__ == "__main__":
    main()
