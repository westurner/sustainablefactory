import json
from pathlib import Path

from data.create_symlinks import (
    create_chat_symlinks,
    document_tags,
    load_config,
    source_documents,
)


def test_source_documents_support_globs_excludes_and_explicit_files(tmp_path):
    source = tmp_path / "source"
    source.mkdir()
    (source / "one.md").write_text("---\ntags: [Research]\n---\n# One\n")
    (source / "two.md").write_text("# Two\n")
    (source / "three.json").write_text(json.dumps({"tags": "Data"}))
    (source / "skip.md").write_text("# Skip\n")

    selected = source_documents(
        source,
        include_globs=["*.md"],
        exclude_globs=["skip.*"],
        files=["three.json"],
    )

    assert [path.name for path in selected] == ["one.md", "three.json", "two.md"]
    assert document_tags(source / "one.md") == ["Research"]
    assert document_tags(source / "three.json") == ["Data"]


def test_create_chat_symlinks_builds_all_and_tagged_overlays(tmp_path):
    source = tmp_path / "source"
    source.mkdir()
    document = source / "one.md"
    document.write_text("---\ntags: [Research, data science]\n---\n# One\n")
    overlays = {"all": tmp_path / "overlays" / "chats__all"}

    created = create_chat_symlinks(
        source,
        overlays,
        do_print_files=False,
        include_globs=["*.md"],
        tag_root=tmp_path / "chats",
    )

    assert set(created) == {"all", "Research", "data-science"}
    assert (overlays["all"] / "one.md").is_symlink()
    assert (tmp_path / "chats" / "Research" / "one.md").is_symlink()
    assert (tmp_path / "chats" / "data-science" / "one.md").is_symlink()


def test_load_config_resolves_paths_relative_to_settings_file(tmp_path):
    settings = tmp_path / "_toc.yml"
    settings.write_text(
        "format: jb-book\nsustainablefactory:\n  chat_sources:\n"
        "    source: source\n    overlay_root: overlays\n    include: ['*.md']\n"
    )

    config = load_config(settings)

    assert config["source_chats"] == tmp_path / "source"
    assert config["overlay_root"] == tmp_path / "overlays"
    assert config["include"] == ["*.md"]


def test_project_toc_keeps_jupyter_book_shape():
    toc = Path(__file__).parents[1] / "docs" / "_toc.yml"
    config = load_config(toc)

    assert config["source_chats"] == toc.parent.parent / "data" / "chats"
