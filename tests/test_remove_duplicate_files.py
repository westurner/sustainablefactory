from importlib.util import module_from_spec, spec_from_file_location
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def load_module():
    script = ROOT / "tools" / "remove_duplicate_files.py"
    spec = spec_from_file_location("remove_duplicate_files", script)
    mod = module_from_spec(spec)
    assert spec and spec.loader
    spec.loader.exec_module(mod)
    return mod


def test_build_removal_plan_and_preview(tmp_path: Path, capsys):
    mod = load_module()
    keep = tmp_path / "keep.txt"
    keep.write_text("abcdef\n", encoding="utf-8")
    duplicate = tmp_path / "duplicate.txt"
    duplicate.write_text("abcdef\n", encoding="utf-8")
    different = tmp_path / "different.txt"
    different.write_text("abcxyz\n", encoding="utf-8")

    plan = mod.build_removal_plan(tmp_path, prefix_bytes=3)
    assert len(plan) == 1
    assert plan[0].keep.name == "keep.txt"
    assert plan[0].remove.name == "duplicate.txt"

    mod.main([str(tmp_path), "--prefix-bytes", "3"])
    captured = capsys.readouterr()
    out = captured.out
    err = captured.err
    assert "cmp -s" in out
    assert "rm" in out
    assert "keep.txt" in out
    assert "duplicate.txt" in out
    assert "Add -y to remove these files." in err
    assert keep.exists()
    assert duplicate.exists()
    assert different.exists()


def test_main_with_yes_removes_duplicates(tmp_path: Path, capsys):
    mod = load_module()
    first = tmp_path / "first.txt"
    first.write_text("same file\n", encoding="utf-8")
    second = tmp_path / "second.txt"
    second.write_text("same file\n", encoding="utf-8")

    mod.main([str(tmp_path), "-y", "--prefix-bytes", "4"])
    out = capsys.readouterr().out
    assert "rm" in out
    assert first.exists()
    assert not second.exists()
    assert first.read_text(encoding="utf-8") == "same file\n"
