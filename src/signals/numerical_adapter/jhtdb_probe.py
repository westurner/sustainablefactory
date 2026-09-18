#!/usr/bin/env python3
"""Acquire a bounded, attributed JHTDB channel-flow probe.

This script requires the external ``givernylocal`` package and a token in
``JHTDB_AUTH_TOKEN``. It deliberately queries at most 4096 spatial points per
request, which is the temporary testing-token limit.
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
from givernylocal.turbulence_toolkit import getData

DATASET_REFERENCE = "https://doi.org/10.7281/T10K26QW"
DATABASE_REFERENCE = "https://turbulence.idies.jhu.edu/home"
LICENSE_REFERENCE = "https://opendatacommons.org/licenses/by/"
POINT_LIMIT = 4096
DEFAULT_POINTS_PER_AXIS = 32
DEFAULT_TIME_START = 1.0
DEFAULT_TIME_END = 1.1
DEFAULT_DELTA_T = 0.1


def _query(cube, variable: str, spatial_method: str, spatial_operator: str, points: np.ndarray, time_start: float, time_end: float, delta_t: float) -> tuple[np.ndarray, np.ndarray, list[str]]:
    results, times = getData(
        cube,
        variable,
        time_start,
        "none",
        spatial_method,
        spatial_operator,
        points,
        option=[time_end, delta_t],
        return_times=True,
        verbose=False,
    )
    frames = [frame.to_numpy(dtype=np.float64) for frame in results]
    columns = results[0].columns.tolist()
    return np.stack(frames), np.asarray(times, dtype=np.float64), columns


def _gradient_consistency(velocity: np.ndarray, service_gradient: np.ndarray, x_points: np.ndarray, z_points: np.ndarray) -> list[dict[str, Any]]:
    point_count = len(x_points)
    velocity_grid = velocity.reshape(velocity.shape[0], point_count, point_count, 3)
    gradient_grid = service_gradient.reshape(service_gradient.shape[0], point_count, point_count, 9)
    comparisons = []
    component_names = [(0, "u"), (1, "v"), (2, "w")]
    axis_columns = [(0, "x", 0), (2, "z", 1)]
    for component, component_name in component_names:
        finite_differences = np.gradient(
            velocity_grid[..., component],
            x_points,
            z_points,
            axis=(1, 2),
            edge_order=2,
        )
        for service_column, axis_name, finite_difference_index in axis_columns:
            difference = finite_differences[finite_difference_index] - gradient_grid[..., service_column + component * 3]
            comparisons.append({
                "component": component_name,
                "axis": axis_name,
                "service_column": int(service_column + component * 3),
                "samples": int(difference.size),
                "rmse": float(np.sqrt(np.mean(difference**2))),
                "max_abs": float(np.max(np.abs(difference))),
            })
    return comparisons


def acquire(output_dir: Path, points_per_axis: int, time_start: float, time_end: float, delta_t: float) -> Path:
    auth_token = os.environ.get("JHTDB_AUTH_TOKEN")
    if not auth_token:
        raise SystemExit("JHTDB_AUTH_TOKEN must be set in the environment")
    point_count = points_per_axis * points_per_axis
    if point_count > POINT_LIMIT:
        raise SystemExit(f"use at most {POINT_LIMIT} points with the temporary testing token")
    if time_end <= time_start or delta_t <= 0:
        raise SystemExit("time_end must exceed time_start and delta_t must be positive")

    output_dir.mkdir(parents=True, exist_ok=True)
    x_points = np.linspace(1.0, 2.0 * np.pi - 1.0, points_per_axis, dtype=np.float64)
    z_points = np.linspace(1.0, 3.0 * np.pi - 1.0, points_per_axis, dtype=np.float64)
    points = np.array(
        [axis.ravel() for axis in np.meshgrid(x_points, 0.0, z_points, indexing="ij")],
        dtype=np.float64,
    ).T

    cube = turb_dataset(
        dataset_title="channel",
        output_path=str(output_dir),
        auth_token=auth_token,
    )
    velocity, times, velocity_columns = _query(
        cube, "velocity", "lag8", "field", points, time_start, time_end, delta_t
    )
    pressure, pressure_times, pressure_columns = _query(
        cube, "pressure", "lag8", "field", points, time_start, time_end, delta_t
    )
    velocity_gradient, gradient_times, gradient_columns = _query(
        cube, "velocity", "fd4lag4", "gradient", points, time_start, time_end, delta_t
    )
    if not np.array_equal(times, pressure_times) or not np.array_equal(times, gradient_times):
        raise SystemExit("JHTDB variables returned inconsistent time coordinates")

    gradient_consistency = _gradient_consistency(velocity, velocity_gradient, x_points, z_points)
    time_step = float(times[1] - times[0])
    euler_displacement = velocity[0] * time_step
    advection_probe = {
        "method": "one-step Euler at sampled grid points; no off-grid interpolation",
        "time_step": time_step,
        "mean_abs_displacement": float(np.mean(np.abs(euler_displacement))),
        "max_abs_displacement": float(np.max(np.abs(euler_displacement))),
        "ftle_computed": False,
    }

    artifact_path = output_dir / "jhtdb_channel_probe.npz"
    np.savez_compressed(
        artifact_path,
        points=points,
        times=times,
        velocity=velocity,
        pressure=pressure,
        velocity_gradient=velocity_gradient,
    )
    checksum = hashlib.sha256(artifact_path.read_bytes()).hexdigest()
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
            "variable_fields": ["velocity", "pressure", "velocity gradient"],
            "velocity_columns": velocity_columns,
            "pressure_columns": pressure_columns,
            "gradient_columns": gradient_columns,
            "spatial_operator": {"velocity": "field", "pressure": "field", "velocity_gradient": "gradient"},
            "spatial_method": {"velocity": "lag8", "pressure": "lag8", "velocity_gradient": "fd4lag4"},
            "temporal_method": "none",
            "point_count": int(len(points)),
            "time_count": int(len(times)),
            "times": times.tolist(),
            "coordinate_axes": {
                "x": [float(x_points[0]), float(x_points[-1])],
                "y": 0.0,
                "z": [float(z_points[0]), float(z_points[-1])],
            },
            "temporary_token_policy": "testing token; at most 4096 spatial points per request",
            "gradient_consistency": gradient_consistency,
            "advection_probe": advection_probe,
        },
        "artifact": {
            "path": artifact_path.name,
            "sha256": checksum,
            "format": "NumPy NPZ probe artifact",
            "token_recorded": False,
            "full_database_downloaded": False,
        },
        "interpretation_boundary": {
            "supports": [
                "bounded solver-produced velocity/pressure/gradient sample",
                "finite-difference gradient cross-check",
                "future particle-advection and FTLE probe",
            ],
            "does_not_establish": [
                "experimental validation",
                "a full-domain flow map",
                "Proca, SQG, fracture, or DDF mechanisms",
            ],
        },
    }
    manifest_path = output_dir / "jhtdb_channel_probe.manifest.json"
    manifest_path.write_text(json.dumps(manifest, indent=2) + "\n")
    return artifact_path


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output-dir", type=Path, default=Path(".tmp/jhtdb_probe"))
    parser.add_argument("--points-per-axis", type=int, default=DEFAULT_POINTS_PER_AXIS)
    parser.add_argument("--time-start", type=float, default=DEFAULT_TIME_START)
    parser.add_argument("--time-end", type=float, default=DEFAULT_TIME_END)
    parser.add_argument("--delta-t", type=float, default=DEFAULT_DELTA_T)
    args = parser.parse_args()
    artifact_path = acquire(args.output_dir, args.points_per_axis, args.time_start, args.time_end, args.delta_t)
    print(f"JHTDB probe written: {artifact_path}")


if __name__ == "__main__":
    main()
