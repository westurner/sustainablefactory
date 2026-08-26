from pathlib import Path

from tools.workflow_transform import changed_files, transform_manifest


def test_changed_files_skips_complete_outputs(tmp_path):
    output = tmp_path / "one.myst.md"
    output.write_text("generated")
    manifest = {
        "files": {
            "one.md": {
                "source": "one.md",
                "sha256": "same",
                "transformed_sha256": "same",
                "outputs": {"myst": str(output)},
            }
        }
    }

    assert changed_files(manifest) == []


def test_changed_files_detects_transform_configuration_change(tmp_path):
    output = tmp_path / "one.myst.md"
    output.write_text("generated")
    manifest = {
        "transform_fingerprint": "new-config",
        "files": {
            "one.md": {
                "sha256": "same",
                "transformed_sha256": "same",
                "transformed_fingerprint": "old-config",
                "outputs": {"myst": str(output)},
            }
        },
    }

    assert len(changed_files(manifest)) == 1


def test_transform_manifest_updates_only_stale_records(tmp_path):
    source_root = tmp_path / "source"
    output_dir = tmp_path / "output"
    source_root.mkdir()
    output_dir.mkdir()
    source = source_root / "one.md"
    source.write_text("source")
    manifest = {
        "source_root": str(source_root),
        "output_dir": str(output_dir),
        "output_formats": ["myst"],
        "files": {
            "one.md": {
                "source": "one.md",
                "sha256": "new-hash",
                "transformed_sha256": "old-hash",
                "outputs": {"myst": str(output_dir / "one.myst.md")},
                "status": "selected",
            }
        },
    }
    commands = []

    def run_transform(command):
        commands.append(command)
        (output_dir / "one.myst.md").write_text("generated")

    changed, skipped = transform_manifest(
        manifest, {"transform": {"cell_split": "m1"}}, run_transform
    )

    assert (changed, skipped) == (1, 0)
    assert commands == [
        [
            "transform-md",
            str(source),
            "--output",
            str(output_dir / "one"),
            "--out-format=myst",
            "--transform-cell-split",
            "m1",
        ]
    ]
    assert manifest["files"]["one.md"]["transformed_sha256"] == "new-hash"
    assert manifest["files"]["one.md"]["status"] == "transformed"
    assert manifest["last_transform"] == {"transformed": 1, "skipped": 0}


def test_transform_manifest_does_not_mark_failed_records(tmp_path):
    source_root = tmp_path / "source"
    output_dir = tmp_path / "output"
    source_root.mkdir()
    output_dir.mkdir()
    source = source_root / "one.md"
    source.write_text("source")
    manifest = {
        "source_root": str(source_root),
        "output_dir": str(output_dir),
        "output_formats": ["myst"],
        "files": {
            "one.md": {
                "source": "one.md",
                "sha256": "new-hash",
                "transformed_sha256": "old-hash",
                "outputs": {"myst": str(output_dir / "one.myst.md")},
                "status": "selected",
            }
        },
    }

    def fail(_command):
        raise RuntimeError("transform failed")

    try:
        transform_manifest(manifest, {}, fail)
    except RuntimeError:
        pass
    else:
        raise AssertionError("failed transform should raise")

    assert manifest["files"]["one.md"]["transformed_sha256"] == "old-hash"
    assert manifest["files"]["one.md"]["status"] == "selected"


def test_transform_manifest_atomically_promotes_default_outputs(tmp_path, monkeypatch):
    source_root = tmp_path / "source"
    output_dir = tmp_path / "output"
    temp_dir = tmp_path / "workflow" / "transform"
    source_root.mkdir()
    output_dir.mkdir()
    source = source_root / "one.md"
    source.write_text("source")
    final_output = output_dir / "one.myst.md"
    final_output.write_text("old")
    manifest = {
        "source_root": str(source_root),
        "output_dir": str(output_dir),
        "temp_dir": str(temp_dir),
        "output_formats": ["myst"],
        "transform_fingerprint": "fingerprint",
        "files": {
            "one.md": {
                "source": "one.md",
                "sha256": "new-hash",
                "transformed_sha256": "old-hash",
                "outputs": {"myst": str(final_output)},
                "status": "selected",
            }
        },
    }

    def fake_run(command, check):
        assert check is True
        Path(command[3] + ".myst.md").write_text("new")

    monkeypatch.setattr("tools.workflow_transform.subprocess.run", fake_run)

    transform_manifest(manifest, {})

    assert final_output.read_text() == "new"
    assert list(temp_dir.iterdir()) == []
