from sustainablefactory.sphinx_yaml_toc import (
    _chapter_entries,
    _entry_lines,
    _yaml_options,
)


def test_jupyter_book_tree_flattens_root_chapters_and_sections():
    data = {
        "root": "intro",
        "chapters": [
            {"file": "chapter", "title": "Chapter", "sections": [{"file": "section"}]}
        ],
    }

    assert _entry_lines(_chapter_entries(data)) == [
        "intro",
        "Chapter <chapter>",
        "section",
    ]


def test_yaml_options_accept_inline_toctree_attributes():
    data = {
        "maxdepth": 2,
        "caption": "Contents",
        "options": {"hidden": True, "titlesonly": True},
    }

    assert _yaml_options(data) == {
        "maxdepth": 2,
        "caption": "Contents",
        "hidden": True,
        "titlesonly": True,
    }


def test_build_false_entries_are_excluded_from_sphinx_toctree():
    entries = [
        {"file": "search-only", "index": True, "build": False, "link": True},
        {"file": "built", "index": True, "build": True, "link": True},
    ]

    assert _entry_lines(entries) == ["built"]
