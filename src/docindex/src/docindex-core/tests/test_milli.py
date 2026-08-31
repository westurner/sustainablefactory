import pytest
from unittest.mock import MagicMock
from docindex_core.backends.milli import MilliBackend, MilliConfig


def test_milli_backend_methods():
    # Construct config
    config = MilliConfig(
        host="http://localhost",
        port=7700,
        api_key="test_key",
        index_name="test_index",
        enabled=True,
    )

    # Instantiate MilliBackend
    backend = MilliBackend(config)

    # Mock self.client
    mock_client = MagicMock()
    backend._client = mock_client

    # 1. verify_connection
    mock_client.health.return_value = {"status": "available"}
    assert backend.verify_connection() is True

    # 2. get_index_stats
    mock_index = MagicMock()
    mock_client.index.return_value = mock_index
    mock_index.get_stats.return_value = {"numberOfDocuments": 42, "isIndexing": False}
    stats = backend.get_index_stats("test_index")
    assert stats["numberOfDocuments"] == 42

    # Test fallback branch (non-dict stats return)
    from types import SimpleNamespace

    mock_index.get_stats.return_value = SimpleNamespace(
        number_of_documents=99, is_indexing=True
    )
    stats2 = backend.get_index_stats("test_index")
    assert stats2["numberOfDocuments"] == 99
    assert stats2["isIndexing"] is True

    # 3. get_synonyms / update_synonyms / reset_synonyms / clear_synonyms
    mock_index.get_synonyms.return_value = {"car": ["automobile"]}
    assert backend.get_synonyms("test_index") == {"car": ["automobile"]}

    mock_index.update_synonyms.return_value = {"taskUid": 10}
    assert backend.update_synonyms("test_index", {"car": ["automobile"]}) == {
        "taskUid": 10
    }

    mock_index.reset_synonyms.return_value = {"taskUid": 11}
    assert backend.reset_synonyms("test_index") == {"taskUid": 11}
    assert backend.clear_synonyms("test_index") == {"taskUid": 11}

    # 4. wait_for_task (success, fail)
    mock_client.wait_for_task.return_value = {"status": "succeeded", "uid": 12}
    assert backend.wait_for_task(12) == {"status": "succeeded", "uid": 12}

    mock_client.wait_for_task.return_value = {
        "status": "failed",
        "uid": 13,
        "error": "some error",
    }
    from meilisearch.errors import MeilisearchError

    with pytest.raises(MeilisearchError):
        backend.wait_for_task(13)

    # 5. swap_indexes
    mock_client.swap_indexes.return_value = {"taskUid": 14}
    assert backend.swap_indexes([("a", "b")]) == {"taskUid": 14}

    # 6. delete_documents_by_filter
    mock_index.delete_documents_by_filter.return_value = {"taskUid": 15}
    assert backend.delete_documents_by_filter("test_index", "id = 1") == {"taskUid": 15}

    # 7. delete_index_if_exists (success)
    mock_client.delete_index.return_value = None
    assert backend.delete_index_if_exists("test_index") is True

    # delete_index_if_exists (not found)
    mock_client.delete_index.side_effect = MeilisearchError("index_not_found")
    assert backend.delete_index_if_exists("test_index") is False
