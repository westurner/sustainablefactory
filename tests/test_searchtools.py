from sustainablefactory.searchtools import (
    DEFAULT_SEARCH_CONFIG,
    normalize_search_config,
)


def test_normalize_search_config_preserves_separate_search_modes():
    config = normalize_search_config(
        {
            "native": {"enabled": False},
            "docindex": {
                "enabled": True,
                "oxirs": {"enabled": True, "url": "https://oxirs.example/query"},
            },
        }
    )

    assert config["native"]["enabled"] is False
    assert config["docindex"]["enabled"] is True
    assert config["docindex"]["oxirs"]["enabled"] is True
    assert config["docindex"]["meilisearch"] == DEFAULT_SEARCH_CONFIG[
        "docindex"
    ]["meilisearch"]


def test_normalize_search_config_does_not_mutate_defaults():
    normalize_search_config({"docindex": {"enabled": True}})

    assert DEFAULT_SEARCH_CONFIG["docindex"]["enabled"] is False


def test_search_extension_registers_bool_toggle_and_mode_dict():
    from sustainablefactory import searchtools

    registered = {}

    class App:
        def add_config_value(self, name, default, rebuild, types):
            registered[name] = (default, rebuild, types)

        def connect(self, *args):
            pass

    searchtools.setup(App())

    assert registered["enhanced_searchtools"][2] == frozenset({bool})
    assert registered["searchtools"][2] == frozenset({dict})
