"""Sphinx directive for Jupyter Book-style YAML table-of-contents files."""

from __future__ import annotations

import textwrap
from pathlib import Path
from typing import Any, ClassVar

import yaml
from docutils.parsers.rst import directives
from docutils.statemachine import StringList
from sphinx.directives.other import TocTree


_YAML_OPTIONS = {
    "maxdepth",
    "caption",
    "glob",
    "hidden",
    "includehidden",
    "numbered",
    "titlesonly",
    "reversed",
    "class",
}


def _as_list(value: Any) -> list[Any]:
    if value is None:
        return []
    return value if isinstance(value, list) else [value]


def _entry_lines(entries: list[Any]) -> list[str]:
    lines: list[str] = []
    for entry in entries:
        if isinstance(entry, str):
            lines.append(entry)
            continue
        if not isinstance(entry, dict):
            continue

        target = entry.get("file", entry.get("url"))
        if target:
            title = entry.get("title")
            if title:
                lines.append(f"{title} <{target}>")
            else:
                lines.append(str(target))

        children = entry.get("sections", entry.get("subsections", []))
        lines.extend(_entry_lines(_as_list(children)))
    return lines


def _chapter_entries(data: dict[str, Any]) -> list[Any]:
    entries: list[Any] = []
    root = data.get("root")
    if root:
        entries.append(root)
    entries.extend(_as_list(data.get("chapters")))
    entries.extend(_as_list(data.get("sections")))
    return entries


def _yaml_options(data: dict[str, Any]) -> dict[str, Any]:
    options = data.get("options", {})
    merged = {
        key: data[key] for key in _YAML_OPTIONS if key in data
    }
    if isinstance(options, dict):
        merged.update({key: options[key] for key in _YAML_OPTIONS if key in options})
    return merged


class YAMLToctree(TocTree):
    """Expand a YAML document tree into Sphinx's native ``toctree`` node."""

    option_spec: ClassVar[dict] = dict(TocTree.option_spec)
    option_spec["file"] = directives.path

    def _load_data(self) -> dict[str, Any]:
        toc_file = self.options.get("file")
        if toc_file:
            path = Path(self.env.srcdir) / toc_file
        else:
            path = Path(self.env.srcdir) / getattr(
                self.config, "yaml_toctree_default_file", "_toc.yml"
            )

        inline = textwrap.dedent("\n".join(self.content)).expandtabs(2)
        if inline.strip():
            data = yaml.safe_load(inline)
        elif path.exists():
            data = yaml.safe_load(path.read_text(encoding="utf-8"))
        else:
            raise self.error(f"YAML toctree file not found: {path}")

        if not isinstance(data, dict):
            raise self.error("YAML toctree content must be a mapping")
        return data

    def _configure_options(self, data: dict[str, Any]) -> None:
        for key, value in _yaml_options(data).items():
            if key in self.options:
                continue
            if key in {"glob", "hidden", "includehidden", "titlesonly", "reversed"}:
                if value:
                    self.options[key] = True
            elif key == "numbered" and value is True:
                self.options[key] = 1
            else:
                self.options[key] = value

    def _run_entries(self, entries: list[Any], caption: str | None = None):
        saved_content = self.content
        saved_caption = self.options.get("caption")
        self.content = StringList(_entry_lines(entries), source=self.state.document["source"])
        if caption is not None:
            self.options["caption"] = caption
        result = super().run()
        self.content = saved_content
        if saved_caption is None:
            self.options.pop("caption", None)
        else:
            self.options["caption"] = saved_caption
        return result

    def run(self):
        data = self._load_data()
        self._configure_options(data)

        parts = _as_list(data.get("parts"))
        if not parts:
            return self._run_entries(_chapter_entries(data))

        result = []
        root = data.get("root")
        if root:
            result.extend(self._run_entries([root]))
        for part in parts:
            if not isinstance(part, dict):
                continue
            entries = part.get("chapters", part.get("sections", []))
            result.extend(self._run_entries(
                _as_list(entries), caption=part.get("caption")
            ))
        return result


def setup(app):
    app.add_directive("toctreeyaml", YAMLToctree)
    app.add_config_value("yaml_toctree_default_file", "_toc.yml", "env")
    return {
        "version": "0.1.0",
        "parallel_read_safe": True,
        "parallel_write_safe": True,
    }
