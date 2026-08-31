import json
from pathlib import Path

import pytest

from docindex_core.chat_parser import BatchChatIndexer, ChatParser


def _write(path: Path, content: str):
    path.write_text(content, encoding="utf-8")
    return path


@pytest.mark.parametrize(
    "name,expected",
    [
        ("gemini_file.md", "gemini"),
        ("my_copilot_chat.md", "copilot"),
        ("openai_notes.md", "openai"),
        ("gpt4.md", "openai"),
        ("misc.md", "custom"),
    ],
)
def test_detect_chat_type(name, expected):
    assert ChatParser._detect_chat_type(Path(name)) == expected


def test_parse_json_chat_list_and_dict_variants(tmp_path):
    p1 = tmp_path / "a.json"
    p1.write_text(
        json.dumps(
            [
                {"content": "hello", "role": "user", "title": "A"},
                {"text": "world", "author": "assistant"},
                {"message": "final"},
                "skip-me",
                {},
            ]
        )
    )

    docs = ChatParser.parse_json_chat(p1)
    assert len(docs) == 3
    assert docs[0].title == "A"
    assert docs[1].metadata.tags == ["assistant"]

    p2 = tmp_path / "b.json"
    p2.write_text(json.dumps({"messages": [{"content": "m1"}]}))
    assert len(ChatParser.parse_json_chat(p2)) == 1

    p3 = tmp_path / "c.json"
    p3.write_text(json.dumps({"turns": [{"content": "t1"}]}))
    assert len(ChatParser.parse_json_chat(p3)) == 1

    p4 = tmp_path / "d.json"
    p4.write_text(json.dumps({"content": "single"}))
    assert len(ChatParser.parse_json_chat(p4)) == 1


def test_parse_json_chat_invalid_or_unexpected(tmp_path):
    bad = tmp_path / "bad.json"
    bad.write_text("{not json")
    assert ChatParser.parse_json_chat(bad) == []

    odd = tmp_path / "odd.json"
    odd.write_text(json.dumps("string"))
    assert ChatParser.parse_json_chat(odd) == []


def test_parse_markdown_chat_and_splitter(tmp_path):
    p = tmp_path / "chat.md"
    _write(
        p,
        "# Heading One\ncontent\n\n---\n\n## Two\nmore content",
    )
    docs = ChatParser.parse_markdown_chat(p)
    assert len(docs) == 2
    assert docs[0].title == "Heading One"

    # No --- path: split by H1 only
    content = "# H1\nA\n# H2\nB"
    sections = ChatParser._split_markdown_sections(content)
    assert len(sections) == 2


def test_parse_markdown_read_error_and_parse_chat_file_dispatch(tmp_path):
    missing = tmp_path / "missing.md"
    assert ChatParser.parse_markdown_chat(missing) == []

    j = tmp_path / "x.json"
    j.write_text(json.dumps({"messages": [{"content": "ok"}]}))
    assert len(ChatParser.parse_chat_file(j)) == 1

    m = tmp_path / "x.md"
    m.write_text("# t\nbody")
    assert len(ChatParser.parse_chat_file(m)) == 1

    weird = tmp_path / "x.txt"
    weird.write_text("nope")
    assert ChatParser.parse_chat_file(weird) == []

    assert ChatParser.parse_chat_file(tmp_path / "nope.json") == []


def test_batch_chat_indexer_get_files_parse_all_and_total(tmp_path, monkeypatch):
    d = tmp_path / "chats"
    d.mkdir()
    (d / "a.json").write_text(json.dumps({"messages": [{"content": "x"}]}))
    (d / "b.md").write_text("# H\ntext")
    (d / "c.myst.md").write_text("# H\ntext")
    (d / "d.chatexport_abc1.md").write_text("# H\ntext")

    idx = BatchChatIndexer(d)
    files = idx.get_chat_files()
    assert [path.name for path in files] == ["a.json", "c.myst.md"]

    # Cover parse_all exception branch.
    original = ChatParser.parse_chat_file

    def boom(filepath):
        if filepath.name == "b.md":
            raise RuntimeError("boom")
        return original(filepath)

    monkeypatch.setattr(ChatParser, "parse_chat_file", staticmethod(boom))
    pairs = list(idx.parse_all())
    assert any(fp.name == "a.json" for fp, _ in pairs)

    total = idx.get_total_documents()
    assert total >= 1


def test_batch_chat_indexer_parse_all_skips_empty_documents(tmp_path, monkeypatch):
    d = tmp_path / "chats"
    d.mkdir()
    (d / "a.md").write_text("# H\ntext")

    idx = BatchChatIndexer(d)

    monkeypatch.setattr(ChatParser, "parse_chat_file", staticmethod(lambda _: []))
    assert list(idx.parse_all()) == []


def test_batch_chat_indexer_init_missing_dir(tmp_path):
    with pytest.raises(ValueError):
        BatchChatIndexer(tmp_path / "missing")


def test_md_section_doc_type_heuristics():
    from docindex_core.chat_parser import _md_section_doc_type
    from docindex_core.config import DocumentType

    assert _md_section_doc_type("Thinking:\nLet's see...") == DocumentType.CHAT_THINKING
    assert _md_section_doc_type("User:\nHello") == DocumentType.CHAT_INPUT
    assert (
        _md_section_doc_type("Gemini Replied:\nHello back") == DocumentType.CHAT_OUTPUT
    )
    assert _md_section_doc_type("Normal section without keywords") == DocumentType.CHAT
