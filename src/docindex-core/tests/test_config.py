import os

import pytest

from docindex_core.config import (
    DEFAULT_INDEX_SETTINGS,
    Document,
    DocumentMetadata,
    DocumentType,
    IndexingStats,
    MeilisearchConfig,
)


@pytest.mark.parametrize(
    "host,port,expected",
    [
        ("localhost", 7700, "http://localhost:7700"),
        ("search", 9999, "http://search:9999"),
    ],
)
def test_docindex_config_url(host, port, expected):
    cfg = MeilisearchConfig(host=host, port=port)
    assert cfg.url == expected


def test_docindex_config_from_env(monkeypatch):
    monkeypatch.setenv("MEILISEARCH_HOST", "meili")
    monkeypatch.setenv("MEILISEARCH_PORT", "8800")
    monkeypatch.setenv("MEILISEARCH_API_KEY", "abc")
    monkeypatch.setenv("MEILISEARCH_BATCH_SIZE", "42")
    monkeypatch.setenv("MEILISEARCH_ENABLED", "FALSE")

    cfg = MeilisearchConfig.from_env()

    assert cfg.host == "meili"
    assert cfg.port == 8800
    assert cfg.api_key == "abc"
    assert cfg.batch_size == 42
    assert cfg.enabled is False


@pytest.mark.parametrize(
    "total,indexed,expected",
    [
        (0, 0, 0.0),
        (10, 7, 70.0),
    ],
)
def test_indexing_stats_success_rate(total, indexed, expected):
    stats = IndexingStats(
        total_documents=total,
        indexed_documents=indexed,
        skipped_documents=0,
        errors=0,
        start_time="2026-01-01T00:00:00",
        end_time="2026-01-01T00:00:01",
        duration_seconds=1.0,
    )
    assert stats.success_rate == expected


def test_document_dump_uses_enum_values():
    doc = Document(
        id="d1",
        type=DocumentType.CHAT,
        title="t",
        content="c",
        filename="f.md",
        metadata=DocumentMetadata(source_file="/tmp/f.md"),
    )
    dumped = doc.model_dump()
    assert dumped["type"] == "chat"


def test_default_index_settings_has_synonyms():
    assert "lignin" in DEFAULT_INDEX_SETTINGS.synonyms
    assert DEFAULT_INDEX_SETTINGS.searchable_attributes[0] == "title"
