#!/usr/bin/env python3
"""Inspect and extract bounded MATLAB v5 PIV flow fields.

The reader keeps source attribution and missing-value masks explicit. It does
not infer a time axis from unrelated files: temporal extraction requires an
explicit sampling frequency and a declared frame axis.
"""

from __future__ import annotations

import argparse
import hashlib
import importlib.metadata
import json
import struct
from pathlib import Path
from typing import Any

import numpy as np
from scipy.io import loadmat, whosmat

SOURCES = {
    "cylinder": {
        "name": "Particle image velocimetry (PIV) data of flow past a cylinder",
        "doi": "https://doi.org/10.5281/zenodo.20765567",
        "file": "cylinder_vel.mat",
        "license": "https://creativecommons.org/licenses/by/4.0/",
        "md5": "4cc876439c48f7970afa477ea17d217a",
        "variables": {"u": "u", "v": "v", "x": "x", "y": "y"},
        "sampling_hz": 20.0,
        "calibration": "planar PIV; LaVision DaVis 8.1.2; velocity m/s; coordinates m",
        "case": "recirculating water channel; cylinder Re=413; mid-span plane",
    },
    "morphodunes": {
        "name": "Laboratory PIV Dataset for Tidal Dune Hydrodynamics - MorphoDunes Project",
        "doi": "https://doi.org/10.5281/zenodo.16414450",
        "file": "EbbNeapHighRough-Exp3.mat",
        "license": "https://creativecommons.org/licenses/by/4.0/",
        "md5": "d9b0b25e1297c2221c85549cd6a1c467",
        "variables": {"u": "uPIV", "v": "vPIV", "x": "xPIV", "y": "yPIV", "z": "zPIV"},
        "sampling_hz": None,
        "calibration": "laboratory PIV; source units and run calibration must be retained",
        "case": "Ebb Neap High-Rough Exp3; reversing-current dune flow",
    },
}


def sha256_file(path: Path, chunk_size: int = 1024 * 1024) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(chunk_size), b""):
            digest.update(chunk)
    return digest.hexdigest()


def md5_file(path: Path, chunk_size: int = 1024 * 1024) -> str:
    digest = hashlib.md5()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(chunk_size), b""):
            digest.update(chunk)
    return digest.hexdigest()


def source_manifest(source: str, input_path: Path) -> dict[str, Any]:
    config = SOURCES[source]
    actual_md5 = md5_file(input_path)
    return {
        "name": config["name"],
        "doi": config["doi"],
        "license": config["license"],
        "source_file": config["file"],
        "source_path": str(input_path),
        "source_size_bytes": input_path.stat().st_size,
        "source_md5": actual_md5,
        "source_md5_expected": config["md5"],
        "source_md5_matches": actual_md5 == config["md5"],
        "source_sha256": sha256_file(input_path),
        "calibration": config["calibration"],
        "case": config["case"],
        "client": f"scipy {importlib.metadata.version('scipy')}",
    }


def _load_variables(source: str, input_path: Path) -> tuple[dict[str, Any], list[tuple[str, tuple[int, ...], str]]]:
    config = SOURCES[source]
    available = {name: (shape, dtype) for name, shape, dtype in whosmat(input_path)}
    missing = [name for name in config["variables"].values() if name not in available]
    if missing:
        raise ValueError(f"missing MATLAB variables for {source}: {missing}")
    values = loadmat(
        input_path,
        variable_names=list(config["variables"].values()),
        squeeze_me=False,
        struct_as_record=False,
    )
    schema = [(name, tuple(shape), str(dtype)) for name, (shape, dtype) in available.items() if name in config["variables"].values()]
    return values, schema


def _normalize_grid(value: np.ndarray, name: str) -> np.ndarray:
    array = np.asarray(value, dtype=np.float64).squeeze()
    if not np.all(np.isfinite(array)):
        raise ValueError(f"{name} contains non-finite coordinates")
    if array.ndim not in (1, 2):
        raise ValueError(f"{name} must be one- or two-dimensional, got {array.shape}")
    return array


def _normalize_velocity(value: np.ndarray, name: str, frame_axis: int) -> np.ndarray:
    array = np.asarray(value, dtype=np.float64)
    if array.ndim < 2:
        raise ValueError(f"{name} must have at least two spatial dimensions")
    axis = frame_axis if frame_axis >= 0 else array.ndim + frame_axis
    if axis < 0 or axis >= array.ndim:
        raise ValueError(f"frame axis {frame_axis} is invalid for {name}{array.shape}")
    if array.ndim == 2:
        if axis != 0:
            raise ValueError(f"{name}{array.shape} has no explicit frame axis; use --frame-axis 0")
        array = array[np.newaxis, ...]
    else:
        array = np.moveaxis(array, axis, 0)
    return array


def extract(source: str, input_path: Path, output_path: Path, frame_axis: int, start: int, count: int, sampling_hz: float | None) -> Path:
    config = SOURCES[source]
    metadata = source_manifest(source, input_path)
    values, schema = _load_variables(source, input_path)
    u = _normalize_velocity(values[config["variables"]["u"]], "u", frame_axis)
    v = _normalize_velocity(values[config["variables"]["v"]], "v", frame_axis)
    if u.shape != v.shape:
        raise ValueError(f"u/v shapes differ after frame normalization: {u.shape} vs {v.shape}")
    if sampling_hz is None:
        raise ValueError("sampling frequency is required for temporal extraction")
    if sampling_hz <= 0 or not np.isfinite(sampling_hz):
        raise ValueError("sampling frequency must be finite and positive")
    if start < 0 or count <= 0 or start + count > u.shape[0]:
        raise ValueError(f"requested frames [{start}, {start + count}) outside {u.shape[0]} frames")

    x = _normalize_grid(values[config["variables"]["x"]], "x")
    y = _normalize_grid(values[config["variables"]["y"]], "y")
    u_selected = u[start : start + count]
    v_selected = v[start : start + count]
    valid = np.isfinite(u_selected) & np.isfinite(v_selected)
    times = (start + np.arange(count, dtype=np.float64)) / sampling_hz
    output_path.parent.mkdir(parents=True, exist_ok=True)
    np.savez_compressed(output_path, u=u_selected, v=v_selected, valid_mask=valid, x=x, y=y, times=times)
    output_checksum = sha256_file(output_path)
    manifest = {
        "source": metadata,
        "schema": [{"name": name, "shape": list(shape), "dtype": dtype} for name, shape, dtype in schema],
        "selection": {
            "frame_axis": frame_axis,
            "start_frame": start,
            "frame_count": count,
            "sampling_hz": sampling_hz,
            "time_axis_explicit": True,
            "time_unit": "s",
        },
        "arrays": {
            "u_shape": list(u_selected.shape),
            "v_shape": list(v_selected.shape),
            "x_shape": list(x.shape),
            "y_shape": list(y.shape),
            "valid_count": int(valid.sum()),
            "missing_count": int((~valid).sum()),
        },
        "artifact": {
            "path": output_path.name,
            "sha256": output_checksum,
            "format": "NumPy NPZ bounded MATLAB PIV extraction",
            "source_not_modified": True,
        },
        "interpretation_boundary": {
            "supports": ["measured 2D velocity field", "mask-aware interpolation", "bounded flow-map/FTLE input"],
            "does_not_establish": ["pressure or density", "3D velocity", "DDF, fracture, Proca, SQG, or FTL communication"],
        },
    }
    output_path.with_suffix(".manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")
    return output_path


def write_cylinder_binary(input_path: Path, output_path: Path, sampling_hz: float) -> Path:
    config = SOURCES["cylinder"]
    metadata = source_manifest("cylinder", input_path)
    if sampling_hz <= 0 or not np.isfinite(sampling_hz):
        raise ValueError("sampling frequency must be finite and positive")
    values, schema = _load_variables("cylinder", input_path)
    u = np.asarray(values[config["variables"]["u"]], dtype=np.float64)
    v = np.asarray(values[config["variables"]["v"]], dtype=np.float64)
    x = _normalize_grid(values[config["variables"]["x"]], "x")
    y = _normalize_grid(values[config["variables"]["y"]], "y")
    if u.ndim != 3 or v.shape != u.shape:
        raise ValueError(f"cylinder u/v must be 3D and equal, got {u.shape} and {v.shape}")
    if x.shape != u.shape[:2] or y.shape != u.shape[:2]:
        raise ValueError(f"cylinder x/y grids must match u/v spatial shape, got {x.shape}, {y.shape}, {u.shape}")
    x_axis = x[:, 0]
    y_axis = y[0, :]
    if not np.allclose(x, x_axis[:, None]) or not np.allclose(y, y_axis[None, :]):
        raise ValueError("cylinder grid is not rectilinear")
    dx = float(x_axis[1] - x_axis[0])
    dy = float(y_axis[1] - y_axis[0])
    if dx == 0 or dy == 0 or not np.allclose(np.diff(x_axis), dx) or not np.allclose(np.diff(y_axis), dy):
        raise ValueError("cylinder grid spacing is not regular")
    if not np.isfinite(u).all() or not np.isfinite(v).all():
        raise ValueError("cylinder binary conversion requires finite u/v values")

    output_path.parent.mkdir(parents=True, exist_ok=True)
    rows, columns, frames = u.shape
    header_size = 144
    plane_values = rows * columns
    u_offset = header_size
    v_offset = u_offset + frames * plane_values * 4
    source_sha256 = bytes.fromhex(metadata["source_sha256"])
    source_md5 = bytes.fromhex(metadata["source_md5"])
    header = b"SFLOW01\0" + struct.pack(
        "<IIQQQdddddQQ32s16s",
        1,
        header_size,
        rows,
        columns,
        frames,
        1.0 / sampling_hz,
        float(x_axis[0]),
        dx,
        float(y_axis[0]),
        dy,
        u_offset,
        v_offset,
        source_sha256,
        source_md5,
    )
    if len(header) != header_size:
        raise AssertionError(f"unexpected flow binary header size: {len(header)}")
    with output_path.open("wb") as stream:
        stream.write(header)
        for frame in range(frames):
            np.asarray(u[:, :, frame], dtype="<f4").tofile(stream)
        for frame in range(frames):
            np.asarray(v[:, :, frame], dtype="<f4").tofile(stream)
    manifest = {
        "source": metadata,
        "schema": [{"name": name, "shape": list(shape), "dtype": dtype} for name, shape, dtype in schema],
        "binary": {
            "format": "SFLOW01",
            "path": output_path.name,
            "sha256": sha256_file(output_path),
            "rows": rows,
            "columns": columns,
            "frames": frames,
            "sampling_hz": sampling_hz,
            "time_step": 1.0 / sampling_hz,
            "x0": float(x_axis[0]),
            "dx": dx,
            "y0": float(y_axis[0]),
            "dy": dy,
            "u_offset": u_offset,
            "v_offset": v_offset,
            "dtype": "little-endian f32",
            "layout": "frame-major, then first MATLAB spatial axis, then second spatial axis",
        },
        "interpretation_boundary": {
            "supports": ["Rust memory-mapped flow-map integration", "measured 2D velocity diagnostics", "bounded FTLE input"],
            "does_not_establish": ["pressure or density", "3D velocity", "DDF, fracture, Proca, SQG, or FTL communication"],
        },
    }
    output_path.with_suffix(".manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")
    return output_path


def inspect(source: str, input_path: Path) -> None:
    metadata = source_manifest(source, input_path)
    _, schema = _load_variables(source, input_path)
    print(json.dumps({"source": metadata, "schema": [{"name": name, "shape": list(shape), "dtype": dtype} for name, shape, dtype in schema]}, indent=2))


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", choices=sorted(SOURCES), required=True)
    parser.add_argument("--input", type=Path, required=True)
    parser.add_argument("--output", type=Path)
    parser.add_argument("--inspect", action="store_true")
    parser.add_argument("--frame-axis", type=int, default=0)
    parser.add_argument("--start", type=int, default=0)
    parser.add_argument("--count", type=int, default=2)
    parser.add_argument("--sampling-hz", type=float)
    parser.add_argument("--binary-output", type=Path, help="write a cylinder-only SFLOW01 binary for the Rust FTLE engine")
    args = parser.parse_args()
    if args.binary_output is not None:
        if args.source != "cylinder":
            parser.error("--binary-output is currently supported only for --source cylinder")
        sampling_hz = args.sampling_hz if args.sampling_hz is not None else SOURCES[args.source]["sampling_hz"]
        output = write_cylinder_binary(args.input, args.binary_output, sampling_hz)
        print(f"Cylinder SFLOW01 binary written: {output}")
        return
    if args.inspect:
        inspect(args.source, args.input)
        return
    if args.output is None:
        parser.error("--output is required unless --inspect is used")
    sampling_hz = args.sampling_hz if args.sampling_hz is not None else SOURCES[args.source]["sampling_hz"]
    if sampling_hz is None:
        parser.error("--sampling-hz is required for this source")
    output = extract(args.source, args.input, args.output, args.frame_axis, args.start, args.count, sampling_hz)
    print(f"MATLAB PIV extraction written: {output}")


if __name__ == "__main__":
    main()
