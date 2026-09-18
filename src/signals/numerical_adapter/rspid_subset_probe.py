#!/usr/bin/env python3
"""Validate and extract a bounded RSPID synthetic-PIV control subset."""

from __future__ import annotations

import argparse
import hashlib
import importlib.metadata
import json
from pathlib import Path
from typing import Any

import numpy as np
from PIL import Image
from scipy.io import loadmat, whosmat

SOURCE = {
    "name": "Raw Synthetic Particle Image Dataset (RSPID)",
    "doi": "https://doi.org/10.5281/zenodo.7832205",
    "license": "https://creativecommons.org/licenses/by/4.0/",
    "archive": "raw_synthetic_piv_data.zip",
    "archive_size_bytes": 2148369223,
    "archive_md5": "45ba1313960c4448f669654ddd8a850c",
    "generator": "PIV Image Generator",
    "flow_families": ["uniform", "rankine_vortex", "parabolic", "stagnation", "shear", "decaying_vortex"],
    "generator_reference": "https://doi.org/10.1016/j.softx.2020.100537",
}


def checksum(path: Path, algorithm: str = "sha256") -> str:
    digest = hashlib.new(algorithm)
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def inspect_mat(path: Path) -> list[dict[str, Any]]:
    return [
        {"name": name, "shape": list(shape), "dtype": str(dtype)}
        for name, shape, dtype in whosmat(path)
    ]


def read_subset(image0: Path, image1: Path, validation: Path, output: Path, archive: Path | None = None) -> Path:
    first = np.asarray(Image.open(image0))
    second = np.asarray(Image.open(image1))
    if first.ndim != 2 or second.ndim != 2:
        raise ValueError("RSPID images must be two-dimensional grayscale arrays")
    if first.shape != second.shape:
        raise ValueError(f"RSPID image shapes differ: {first.shape} vs {second.shape}")
    if first.dtype != second.dtype:
        raise ValueError(f"RSPID image dtypes differ: {first.dtype} vs {second.dtype}")
    if first.size == 0:
        raise ValueError("RSPID image pair is empty")

    validation_schema = inspect_mat(validation)
    if not validation_schema:
        raise ValueError("RSPID validation MAT file has no public variables")
    if archive is not None:
        archive_md5 = checksum(archive, "md5")
        if archive_md5 != SOURCE["archive_md5"]:
            raise ValueError(f"RSPID archive MD5 mismatch: expected {SOURCE['archive_md5']}, got {archive_md5}")
    else:
        archive_md5 = None

    output.parent.mkdir(parents=True, exist_ok=True)
    np.savez_compressed(output, image0=first, image1=second)
    manifest = {
        "source": {
            **SOURCE,
            "archive_md5_verified": archive_md5,
            "client": f"scipy {importlib.metadata.version('scipy')}; Pillow {importlib.metadata.version('Pillow')}",
        },
        "selection": {
            "image0": image0.name,
            "image1": image1.name,
            "validation": validation.name,
            "image0_sha256": checksum(image0),
            "image1_sha256": checksum(image1),
            "validation_sha256": checksum(validation),
            "image_shape": list(first.shape),
            "image_dtype": str(first.dtype),
            "pixel_min": int(first.min()),
            "pixel_max": int(first.max()),
        },
        "validation_mat_schema": validation_schema,
        "artifact": {
            "path": output.name,
            "sha256": checksum(output),
            "format": "NumPy NPZ bounded RSPID image pair",
        },
        "interpretation_boundary": {
            "supports": [
                "synthetic PIV reconstruction control",
                "image noise and displacement sensitivity",
                "missing-vector and held-out validation experiments",
            ],
            "does_not_establish": [
                "measured fluid behavior",
                "physical DDF or fracture evidence",
                "pressure, density, or energy validation",
            ],
        },
    }
    output.with_suffix(".manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")
    return output


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--image0", type=Path, required=True)
    parser.add_argument("--image1", type=Path, required=True)
    parser.add_argument("--validation", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--archive", type=Path)
    args = parser.parse_args()
    output = read_subset(args.image0, args.image1, args.validation, args.output, args.archive)
    print(f"RSPID subset written: {output}")


if __name__ == "__main__":
    main()
