#!/usr/bin/env python3
"""Verify bounded Flat Light control artifacts and write provenance metadata.

The utility never downloads credentials or writes outside the supplied local
artifact directory. It records source identity, license, checksums, and the
interpretation boundary for classical controls.
"""
import argparse
import hashlib
import json
from pathlib import Path
from typing import Any

CONTROL_REGISTER: dict[str, dict[str, Any]] = {
    "wdm_mzi": {
        "path": "WDM-MZI-Silicon-Photonics-Data.zip",
        "source": "Zenodo WDM-MZI silicon-photonics control dataset",
        "doi": "10.5281/zenodo.22819801",
        "url": "https://doi.org/10.5281/zenodo.22819801",
        "license": "CC BY 4.0",
        "expected_md5": "86e2e1f949fab4d969f8441eba772bfe",
        "fields": [
            "spectral responses",
            "directional couplers",
            "Y-splitters",
            "eye diagrams",
            "classical transfer-analysis scripts",
        ],
        "boundary": "classical silicon-photonics control; not N-LIG or Proca evidence",
    },
    "lig_comparison": {
        "path": "lig-pesf-supplement.docx",
        "source": "Figshare laser-induced-graphene comparison supplement",
        "doi": "10.6084/m9.figshare.33483753",
        "url": "https://doi.org/10.6084/m9.figshare.33483753",
        "license": "CC BY 4.0",
        "expected_md5": "c9a56e184a1925cc9241ec2734d1e8e1",
        "fields": [
            "laser-induced-graphene process comparison",
            "supplementary characterization context",
        ],
        "boundary": "polyethersulfone comparison control; not lignin-derived N-LIG evidence",
    },
    "silica_refractive_index": {
        "path": "SiO2-Malitson.yml",
        "source": "RefractiveIndex.INFO fused-silica Malitson record",
        "doi": "10.1038/s41597-023-02898-2",
        "url": "https://refractiveindex.info/database/data/main/SiO2/nk/Malitson.yml",
        "license": "CC0",
        "expected_sha256": "6b0e570b582a96f68c3f43400f942284afde1a579e95001cac6ffa3049b0e0bd",
        "fields": [
            "fused-silica Sellmeier coefficients",
            "temperature",
            "wavelength range",
        ],
        "boundary": "classical optical-constant baseline; not an N-LIG measurement",
    },
    "gwosc_catalog": {
        "path": "gwosc-event-catalog.json",
        "source": "Gravitational Wave Open Science Center event-catalog metadata",
        "doi": "10.7935/82H3-HH23",
        "url": "https://gwosc.org/data/",
        "license": "release-specific GWOSC data terms",
        "expected_sha256": "b2e3db64abb2c86be05a6a86e4cee740b048ca56a9d62fd5d553b34e0d59f12d",
        "fields": ["event-catalog URLs", "catalog descriptions"],
        "boundary": "timing/calibration methodology control; not a direct optical Proca test",
    },
}

EXTERNAL_SOURCE_REGISTER = [
    {
        "name": "chime_frb_catalog_1",
        "source": "CHIME/FRB Catalog 1 public archive",
        "doi": "10.11570/23.0029",
        "url": "https://www.canfar.net/storage/list/AstroDataCitationDOI/CISTI.CANFAR/21.0007/data",
        "license": "archive-specific public access and citation terms",
        "local_artifact": False,
        "boundary": "frequency-dependent propagation constraint; plasma and source-delay degeneracies remain",
    }
]


def checksum(path: Path, algorithm: str) -> str:
    digest = hashlib.new(algorithm)
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def verify_artifact(root: Path, name: str, metadata: dict[str, Any]) -> dict[str, Any]:
    path = root / metadata["path"]
    if not path.is_file():
        raise FileNotFoundError(path)
    actual_sha256 = checksum(path, "sha256")
    actual_md5 = checksum(path, "md5")
    expected_md5 = metadata.get("expected_md5")
    expected_sha256 = metadata.get("expected_sha256")
    if expected_md5 and actual_md5 != expected_md5:
        raise ValueError(
            f"{name}: MD5 mismatch: expected {expected_md5}, got {actual_md5}"
        )
    if expected_sha256 and actual_sha256 != expected_sha256:
        raise ValueError(
            f"{name}: SHA-256 mismatch: expected {expected_sha256}, got {actual_sha256}"
        )
    return {
        "name": name,
        "path": str(path),
        "bytes": path.stat().st_size,
        "sha256": actual_sha256,
        "md5": actual_md5,
        **metadata,
        "checksums_verified": bool(expected_md5 or expected_sha256),
    }


def build_manifest(root: Path) -> dict[str, Any]:
    artifacts = [
        verify_artifact(root, name, metadata)
        for name, metadata in CONTROL_REGISTER.items()
    ]
    return {
        "format": "flat-light-classical-controls-v1",
        "artifact_root": str(root),
        "artifacts": artifacts,
        "external_sources": EXTERNAL_SOURCE_REGISTER,
        "interpretation_boundary": {
            "supports": [
                "classical silicon-photonics transfer baselines",
                "classical fused-silica dispersion baseline",
                "LIG process-pipeline comparison",
                "public timing and calibration workflow controls",
            ],
            "does_not_establish": [
                "N-LIG fabrication reproducibility",
                "zero diffraction",
                "fundamental photon mass",
                "longitudinal Proca propagation",
                "phase-slip chemistry",
            ],
        },
    }


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--artifact-dir", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    manifest = build_manifest(args.artifact_dir)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(manifest, indent=2) + "\n")
    print(f"Flat Light control manifest written: {args.output}")


if __name__ == "__main__":
    main()
