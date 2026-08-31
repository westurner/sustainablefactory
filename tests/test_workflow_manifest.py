import json

from data.create_symlinks import build_manifest, remove_stale_outputs, write_manifest


def test_build_manifest_is_deterministic_and_retains_transform_status(tmp_path):
    source_root = tmp_path / "source"
    output_dir = tmp_path / "output"
    source_root.mkdir()
    source = source_root / "one.md"
    source.write_text("one")
    previous = {
        "files": {
            "one.md": {
                "transformed_sha256": "old-hash",
                "status": "transformed",
            }
        }
    }

    manifest = build_manifest(
        source_root,
        [source],
        {"output_dir": output_dir, "output_formats": ["myst", "ipynb"]},
        previous,
    )

    record = manifest["files"]["one.md"]
    assert record["source"] == "one.md"
    assert len(record["sha256"]) == 64
    assert record["transformed_sha256"] == "old-hash"
    assert record["outputs"]["myst"].endswith("/one.myst.md")
    assert record["outputs"]["ipynb"].endswith("/one.ipynb")


def test_write_manifest_replaces_file_atomically(tmp_path):
    path = tmp_path / ".tmp" / "workflow" / "manifest.json"
    manifest = {"version": 1, "files": {}}

    write_manifest(path, manifest)

    assert json.loads(path.read_text()) == manifest
    assert not path.with_name("manifest.json.tmp").exists()


def test_remove_stale_outputs_removes_only_unselected_files(tmp_path):
    stale = tmp_path / "stale.myst.md"
    current = tmp_path / "current.myst.md"
    stale.write_text("stale")
    current.write_text("current")
    previous = {
        "files": {
            "stale.md": {"outputs": {"myst": str(stale)}},
            "current.md": {"outputs": {"myst": str(current)}},
        }
    }
    manifest = {"files": {"current.md": {"outputs": {"myst": str(current)}}}}

    removed = remove_stale_outputs(previous, manifest)

    assert removed == [stale]
    assert not stale.exists()
    assert current.exists()


def test_remove_stale_outputs_removes_formats_no_longer_requested(tmp_path):
    old_notebook = tmp_path / "one.ipynb"
    current_myst = tmp_path / "one.myst.md"
    old_notebook.write_text("old")
    current_myst.write_text("current")
    previous = {
        "files": {
            "one.md": {
                "outputs": {
                    "myst": str(current_myst),
                    "ipynb": str(old_notebook),
                }
            }
        }
    }
    manifest = {"files": {"one.md": {"outputs": {"myst": str(current_myst)}}}}

    removed = remove_stale_outputs(previous, manifest)

    assert removed == [old_notebook]
    assert not old_notebook.exists()
    assert current_myst.exists()
