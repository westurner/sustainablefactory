from importlib.util import module_from_spec, spec_from_file_location
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def load_module():
    script = ROOT / "tools" / "rename_gemini_chat_exports.py"
    spec = spec_from_file_location("rename_gemini_chat_exports", script)
    mod = module_from_spec(spec)
    assert spec and spec.loader
    spec.loader.exec_module(mod)
    return mod


def test_slugify():
    mod = load_module()
    assert mod.slugify("How to test this agent session backup tool?") == (
        "how-to-test-this-agent-session-backup-tool"
    )


def test_extract_first_prompt_from_markdown_and_json(tmp_path: Path):
    mod = load_module()
    md = tmp_path / "Gemini-_11.md"
    md.write_text(
        "> From: https://gemini.google.com/app/123\n\n# you asked\n\nmessage time: 2026-05-16 10:24:15\n\nHow to test this agent session backup tool?\n\n---\n\n# gemini response\n",
        encoding="utf-8",
    )

    js = tmp_path / "Gemini-_15.json"
    js.write_text(
        '[{"role": "user", "contents": [{"type": "text", "content": "Design an in-ground water shutoff valve that works as a fire hydrant"}]}]',
        encoding="utf-8",
    )

    assert mod.extract_first_prompt(md) == "How to test this agent session backup tool?"
    assert mod.extract_first_prompt(js) == (
        "Design an in-ground water shutoff valve that works as a fire hydrant"
    )


def test_build_rename_plan_and_preview(tmp_path: Path, capsys):
    mod = load_module()
    first = tmp_path / "Gemini-_11.md"
    first.write_text(
        "# you asked\n\nmessage time: now\n\nHow to test this agent session backup tool?\n\n---\n\n# gemini response\n",
        encoding="utf-8",
    )
    second = tmp_path / "Gemini-_15.json"
    second.write_text(
        '[{"role": "user", "contents": [{"type": "text", "content": "How to test this agent session backup tool?"}]}]',
        encoding="utf-8",
    )

    plan = mod.build_rename_plan(tmp_path)
    assert [dst.name for _src, dst, _prompt in plan] == [
        "how-to-test-this-agent-session-backup-tool.md",
        "how-to-test-this-agent-session-backup-tool-2.json",
    ]

    mod.main([str(tmp_path)])
    out = capsys.readouterr().out
    assert (
        "mv Gemini-_11.md how-to-test-this-agent-session-backup-tool.md  # How to test this agent session backup tool?"
        in out
    )
    assert "Add -y to apply these renames." in out
    assert first.exists()
    assert second.exists()


def test_main_with_yes_renames_files(tmp_path: Path, capsys):
    mod = load_module()
    md = tmp_path / "Gemini-_40.md"
    md.write_text(
        "# you asked\n\nmessage time: now\n\nIs superconductivity any more useful for QC than QAHE?\n\n---\n\n# gemini response\n",
        encoding="utf-8",
    )

    mod.main([str(tmp_path), "-y"])
    out = capsys.readouterr().out
    assert (
        "mv Gemini-_40.md is-superconductivity-any-more-useful-for-qc-than-qahe.md  # Is superconductivity any more useful for QC than QAHE?"
        in out
    )
    assert not md.exists()
    assert (
        tmp_path / "is-superconductivity-any-more-useful-for-qc-than-qahe.md"
    ).exists()
