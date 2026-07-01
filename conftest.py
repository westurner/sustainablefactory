"""
conftest.py pytest configuration file
"""
import os
import sys
import types
from pathlib import Path


# Always ensure project and package src/ modules are importable in tests.
ROOT = Path(__file__).resolve().parent
SEARCH_PATHS = [
    ROOT / "src" / "docindex-core" / "src",
    ROOT / "src" / "docindex-sphinx" / "src",
    ROOT / "src" / "docindex-cli" / "src",
    ROOT / "src" / "docindex-sustainablefactory" / "src",
]
for path in SEARCH_PATHS:
    as_str = str(path)
    if as_str not in sys.path:
        sys.path.insert(0, as_str)


# Provide a lightweight pydantic stub when dependency is unavailable.
try:
    import pydantic  # type: ignore  # noqa: F401
except Exception:
    pyd_mod = types.ModuleType("pydantic")

    class _FieldInfo:
        def __init__(self, default=None, default_factory=None, description=None):
            self.default = default
            self.default_factory = default_factory
            self.description = description

    def Field(default=None, default_factory=None, description=None):
        return _FieldInfo(default=default, default_factory=default_factory, description=description)

    class ConfigDict(dict):
        pass

    class BaseModel:
        def __init__(self, **kwargs):
            annotations = getattr(self.__class__, "__annotations__", {})
            for key in annotations:
                if key in kwargs:
                    value = kwargs[key]
                else:
                    attr = getattr(self.__class__, key, None)
                    if isinstance(attr, _FieldInfo):
                        if attr.default_factory is not None:
                            value = attr.default_factory()
                        else:
                            value = attr.default
                    else:
                        value = attr
                setattr(self, key, value)

        def model_dump(self):
            out = {}
            for key in getattr(self.__class__, "__annotations__", {}):
                value = getattr(self, key)
                if hasattr(value, "value"):
                    value = value.value
                if hasattr(value, "model_dump"):
                    value = value.model_dump()
                elif isinstance(value, list):
                    converted = []
                    for item in value:
                        if hasattr(item, "model_dump"):
                            converted.append(item.model_dump())
                        elif hasattr(item, "value"):
                            converted.append(item.value)
                        else:
                            converted.append(item)
                    value = converted
                out[key] = value
            return out

    pyd_mod.BaseModel = BaseModel
    pyd_mod.Field = Field
    pyd_mod.ConfigDict = ConfigDict
    sys.modules["pydantic"] = pyd_mod


# Provide a lightweight meilisearch stub when dependency is unavailable.
try:
    import meilisearch  # type: ignore  # noqa: F401
except Exception:
    meili_mod = types.ModuleType("meilisearch")
    errors_mod = types.ModuleType("meilisearch.errors")

    class MeilisearchError(Exception):
        pass

    class MeilisearchCommunicationError(Exception):
        pass

    class Client:
        def __init__(self, *args, **kwargs):
            self.args = args
            self.kwargs = kwargs

        def health(self):
            return {"status": "available"}

    errors_mod.MeilisearchError = MeilisearchError
    errors_mod.MeilisearchCommunicationError = MeilisearchCommunicationError
    meili_mod.Client = Client
    meili_mod.errors = errors_mod

    sys.modules["meilisearch"] = meili_mod
    sys.modules["meilisearch.errors"] = errors_mod
