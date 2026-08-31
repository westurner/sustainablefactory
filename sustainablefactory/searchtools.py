"""Optional dual-mode search UI for Sphinx documentation."""

from __future__ import annotations

from pathlib import Path
from typing import Any


DEFAULT_SEARCH_CONFIG: dict[str, Any] = {
    "native": {"enabled": True},
    "docindex": {
        "enabled": False,
        "index": "all",
        "oxirs": {"enabled": False, "url": ""},
        "meilisearch": {
            "enabled": False,
            "url": "",
            "public_api_key": "",
        },
    },
}


def _merge_dicts(base: dict[str, Any], override: object) -> dict[str, Any]:
    result = dict(base)
    if not isinstance(override, dict):
        return result
    for key, value in override.items():
        if isinstance(value, dict) and isinstance(result.get(key), dict):
            result[key] = _merge_dicts(result[key], value)
        else:
            result[key] = value
    return result


def normalize_search_config(config: object) -> dict[str, Any]:
    """Return a complete, template-safe copy of the search configuration."""
    return _merge_dicts(
        DEFAULT_SEARCH_CONFIG,
        config if isinstance(config, dict) else {},
    )


def setup(app):
    app.add_config_value(
        "docindex_searchtools_enhanced", False, "html", types=frozenset({bool})
    )
    app.add_config_value(
        "docindex_searchtools", DEFAULT_SEARCH_CONFIG, "html", types=frozenset({dict})
    )
    app.connect("config-inited", _configure_search_assets)
    app.connect("html-page-context", _add_search_context)
    app.connect("build-finished", _merge_native_search_asset)
    return {
        "version": "0.1.0",
        "parallel_read_safe": True,
        "parallel_write_safe": True,
    }


def _configure_search_assets(app, config) -> None:
    search_config = normalize_search_config(config.docindex_searchtools)
    if config.docindex_searchtools_enhanced and search_config["docindex"]["enabled"]:
        app.add_js_file("docindex-search.js")


def _add_search_context(app, pagename, templatename, context, doctree) -> None:
    context["docindex_searchtools_enhanced"] = bool(
        app.config.docindex_searchtools_enhanced
    )
    context["docindex_search_config"] = normalize_search_config(
        app.config.docindex_searchtools
    )


def _merge_native_search_asset(app, exception) -> None:
    """Append the grouped-summary implementation to Sphinx's native asset."""
    if exception is not None or app.builder.name != "html":
        return

    output = Path(app.outdir) / "_static" / "searchtools.js"
    source = Path(__file__).parents[1] / "docs" / "_static" / "search-snippets.js"
    if not output.exists() or not source.exists():
        return

    marker = "/* sustainablefactory grouped search snippets */"
    native = output.read_text(encoding="utf-8")
    if marker in native:
        return

    snippets = source.read_text(encoding="utf-8")
    output.write_text(
        f"{native}\n{marker}\n{snippets}",
        encoding="utf-8",
    )
    generated_source = output.parent / source.name
    if generated_source != output:
        generated_source.unlink(missing_ok=True)
