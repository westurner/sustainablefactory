#!/usr/bin/env python3
"""Incrementally transform canonical workflow inputs from a chat manifest."""

from __future__ import annotations

import argparse
import json
import os
import shutil
import subprocess
import tempfile
from pathlib import Path
from typing import Callable, Sequence

from data.create_symlinks import DEFAULT_MANIFEST_PATH, load_config, write_manifest


def load_manifest(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def changed_files(manifest: dict) -> list[dict]:
    """Return records whose outputs are stale or incomplete."""
    records = []
    for record in manifest.get("files", {}).values():
        outputs = [Path(value) for value in record.get("outputs", {}).values()]
        if (
            record.get("transformed_sha256") != record.get("sha256")
            or record.get("transformed_fingerprint")
            != manifest.get("transform_fingerprint")
            or not all(output.exists() for output in outputs)
        ):
            records.append(record)
    return records


def transform_manifest(
    manifest: dict,
    config: dict,
    runner: Callable[[Sequence[str]], object] | None = None,
) -> tuple[int, int]:
    """Transform stale records and update status only after success."""
    use_atomic_outputs = runner is None
    if runner is None:
        runner = lambda command: subprocess.run(command, check=True)

    source_root = Path(manifest["source_root"])
    output_dir = Path(manifest["output_dir"])
    formats = manifest.get("output_formats", config.get("output_formats", ["myst"]))
    transform = config.get("transform", {})
    split_mode = transform.get("cell_split", "m1")
    records = changed_files(manifest)

    for record in records:
        source = source_root / record["source"]
        output_base = output_dir / source.stem
        temporary_dir = None
        if use_atomic_outputs:
            temporary_root = Path(
                manifest.get("temp_dir", output_dir.parent / ".workflow-tmp")
            )
            temporary_root.mkdir(parents=True, exist_ok=True)
            temporary_dir = Path(
                tempfile.mkdtemp(prefix="transform-", dir=temporary_root)
            )
            output_base = temporary_dir / source.stem

        command = [
            "transform-md",
            str(source),
            "--output",
            str(output_base),
            "--out-format=" + ",".join(formats),
        ]
        if split_mode:
            command.extend(["--transform-cell-split", str(split_mode)])

        try:
            runner(command)
            output_values = list(record.get("outputs", {}).values())
            if use_atomic_outputs:
                temporary_outputs = [
                    temporary_dir / Path(value).name for value in output_values
                ]
                if not all(path.exists() for path in temporary_outputs):
                    raise RuntimeError(
                        f"transform did not produce all outputs for {record['source']}"
                    )
                for temporary, final in zip(temporary_outputs, output_values):
                    final_path = Path(final)
                    final_path.parent.mkdir(parents=True, exist_ok=True)
                    os.replace(temporary, final_path)
            elif not all(Path(value).exists() for value in output_values):
                raise RuntimeError(
                    f"transform did not produce all outputs for {record['source']}"
                )
            record["transformed_sha256"] = record["sha256"]
            record["transformed_fingerprint"] = manifest.get("transform_fingerprint")
            record["status"] = "transformed"
        finally:
            if temporary_dir is not None:
                shutil.rmtree(temporary_dir, ignore_errors=True)

    manifest["last_transform"] = {
        "transformed": len(records),
        "skipped": len(manifest.get("files", {})) - len(records),
    }
    return len(records), len(manifest.get("files", {})) - len(records)


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--config", type=Path, default=Path("docs/_toc.yml"))
    parser.add_argument("--manifest", type=Path)
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args(argv)

    config = load_config(args.config)
    manifest_path = args.manifest or config.get(
        "manifest", Path.cwd() / DEFAULT_MANIFEST_PATH
    )
    manifest = load_manifest(manifest_path)
    count = len(changed_files(manifest))
    total = len(manifest.get("files", {}))
    if args.dry_run:
        print(f"workflow transform: {count} changed, {total - count} skipped")
        return 0

    changed, skipped = transform_manifest(manifest, config)
    write_manifest(manifest_path, manifest)
    print(f"workflow transform: {changed} transformed, {skipped} skipped")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
