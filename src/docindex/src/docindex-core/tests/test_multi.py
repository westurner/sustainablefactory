import pytest
from unittest.mock import MagicMock
from datetime import datetime

from docindex_core.backends.multi import MultiBackend
from docindex_core.config import (
    Document,
    DocumentType,
    SearchResult,
    IndexingStats,
    DocumentMetadata,
)


@pytest.fixture
def mock_backends():
    b1 = MagicMock()
    b2 = MagicMock()
    return b1, b2


def test_multi_backend_init(mock_backends):
    b1, b2 = mock_backends

    # Test valid init
    multi = MultiBackend([b1, b2])
    assert len(multi.backends) == 2
    assert multi.primary_backend == b1

    # Test empty init
    with pytest.raises(
        ValueError, match="MultiBackend requires at least one active backend"
    ):
        MultiBackend([])


def test_multi_backend_verify_connection(mock_backends):
    b1, b2 = mock_backends
    multi = MultiBackend([b1, b2])

    # Case 1: Both success
    b1.verify_connection.return_value = True
    b2.verify_connection.return_value = True
    assert multi.verify_connection() is True

    # Case 2: One fails
    b1.verify_connection.return_value = True
    b2.verify_connection.return_value = False
    assert multi.verify_connection() is False

    # Case 3: One raises exception
    b1.verify_connection.return_value = True
    b2.verify_connection.side_effect = Exception("conn error")
    assert multi.verify_connection() is False


def test_multi_backend_create_or_update_index(mock_backends):
    b1, b2 = mock_backends
    multi = MultiBackend([b1, b2])

    b1.create_or_update_index.return_value = {"b1": "ready"}
    b2.create_or_update_index.return_value = {"b2": "ready"}

    res = multi.create_or_update_index(
        "my_index", settings={"opt": 1}, primary_key="id"
    )
    assert res == {"b1": "ready", "b2": "ready"}
    b1.create_or_update_index.assert_called_once_with("my_index", {"opt": 1}, "id")
    b2.create_or_update_index.assert_called_once_with("my_index", {"opt": 1}, "id")


def test_multi_backend_clear_index(mock_backends):
    b1, b2 = mock_backends
    multi = MultiBackend([b1, b2])

    b1.clear_index.return_value = {"b1": "cleared"}
    b2.clear_index.return_value = {"b2": "cleared"}

    res = multi.clear_index("my_index")
    assert res == {"b1": "cleared", "b2": "cleared"}
    b1.clear_index.assert_called_once_with("my_index")
    b2.clear_index.assert_called_once_with("my_index")


def test_multi_backend_delete_index(mock_backends):
    b1, b2 = mock_backends
    multi = MultiBackend([b1, b2])

    b1.delete_index.return_value = True
    b2.delete_index.return_value = True
    assert multi.delete_index("my_index") is True

    b2.delete_index.return_value = False
    assert multi.delete_index("my_index") is False


def test_multi_backend_add_documents(mock_backends):
    b1, b2 = mock_backends
    multi = MultiBackend([b1, b2])

    doc = Document(
        id="doc1",
        type=DocumentType.CHAT,
        title="Doc 1",
        content="Test",
        filename="doc1.md",
        metadata=DocumentMetadata(source_file="test.md"),
    )

    stats1 = IndexingStats(
        total_documents=1,
        indexed_documents=1,
        skipped_documents=0,
        errors=0,
        start_time=datetime.now(),
        end_time=datetime.now(),
        duration_seconds=0.1,
    )
    stats2 = IndexingStats(
        total_documents=1,
        indexed_documents=1,
        skipped_documents=0,
        errors=0,
        start_time=datetime.now(),
        end_time=datetime.now(),
        duration_seconds=0.2,
    )

    b1.add_documents.return_value = stats1
    b2.add_documents.return_value = stats2

    res = multi.add_documents(
        "my_index", [doc], batch_size=10, progress=True, total_estimate=100
    )
    assert res == stats1
    b1.add_documents.assert_called_once_with(
        index_name="my_index",
        documents=[doc],
        batch_size=10,
        progress=True,
        total_estimate=100,
    )
    b2.add_documents.assert_called_once_with(
        index_name="my_index",
        documents=[doc],
        batch_size=10,
        progress=True,
        total_estimate=100,
    )


def test_multi_backend_search(mock_backends):
    b1, b2 = mock_backends
    multi = MultiBackend([b1, b2])

    results = [
        SearchResult(
            id="doc1",
            type=DocumentType.CHAT,
            title="Doc 1",
            content_snippet="test",
            relevance_score=1.0,
            matched_fields=["content"],
        )
    ]
    b1.search.return_value = results

    res = multi.search(
        "my_index", "query", limit=5, offset=1, filters="type=chat", sort=["title:asc"]
    )
    assert res == results
    b1.search.assert_called_once_with(
        index_name="my_index",
        query="query",
        limit=5,
        offset=1,
        filters="type=chat",
        sort=["title:asc"],
    )
    b2.search.assert_not_called()


def test_multi_backend_get_index_stats(mock_backends):
    b1, b2 = mock_backends
    multi = MultiBackend([b1, b2])

    b1.get_index_stats.return_value = {"count": 42}

    assert multi.get_index_stats("my_index") == {"count": 42}
    b1.get_index_stats.assert_called_once_with("my_index")
    b2.get_index_stats.assert_not_called()


def test_multi_backend_get_synonyms(mock_backends):
    b1, b2 = mock_backends
    multi = MultiBackend([b1, b2])

    b1.get_synonyms.return_value = {"word": ["syn"]}

    assert multi.get_synonyms("my_index") == {"word": ["syn"]}
    b1.get_synonyms.assert_called_once_with("my_index")
    b2.get_synonyms.assert_not_called()


def test_multi_backend_update_synonyms(mock_backends):
    b1, b2 = mock_backends
    multi = MultiBackend([b1, b2])

    b1.update_synonyms.return_value = {"b1": "updated"}
    b2.update_synonyms.return_value = {"b2": "updated"}

    res = multi.update_synonyms("my_index", {"word": ["syn"]})
    assert res == {"b1": "updated", "b2": "updated"}
    b1.update_synonyms.assert_called_once_with("my_index", {"word": ["syn"]})
    b2.update_synonyms.assert_called_once_with("my_index", {"word": ["syn"]})


def test_multi_backend_clear_synonyms(mock_backends):
    b1, b2 = mock_backends
    multi = MultiBackend([b1, b2])

    b1.clear_synonyms.return_value = {"b1": "cleared"}
    b2.clear_synonyms.return_value = {"b2": "cleared"}

    res = multi.clear_synonyms("my_index")
    assert res == {"b1": "cleared", "b2": "cleared"}
    b1.clear_synonyms.assert_called_once_with("my_index")
    b2.clear_synonyms.assert_called_once_with("my_index")


def test_multi_backend_delete_documents_by_filter(mock_backends):
    b1, b2 = mock_backends
    multi = MultiBackend([b1, b2])

    b1.delete_documents_by_filter.return_value = {"b1": "deleted"}
    b2.delete_documents_by_filter.return_value = {"b2": "deleted"}

    res = multi.delete_documents_by_filter("my_index", "type=chat")
    assert res == {"b1": "deleted", "b2": "deleted"}
    b1.delete_documents_by_filter.assert_called_once_with("my_index", "type=chat")
    b2.delete_documents_by_filter.assert_called_once_with("my_index", "type=chat")


def test_multi_backend_swap_indexes(mock_backends):
    b1, b2 = mock_backends
    multi = MultiBackend([b1, b2])

    b1.swap_indexes.return_value = {"b1": "swapped"}
    b2.swap_indexes.return_value = {"b2": "swapped"}

    res = multi.swap_indexes("index_a", "index_b")
    assert res == {"b1": "swapped", "b2": "swapped"}
    b1.swap_indexes.assert_called_once_with("index_a", "index_b")
    b2.swap_indexes.assert_called_once_with("index_a", "index_b")


def test_multi_backend_optimize(mock_backends):
    b1, b2 = mock_backends
    multi = MultiBackend([b1, b2])

    multi.optimize()
    b1.optimize.assert_called_once()
    b2.optimize.assert_called_once()

    b1.optimize.reset_mock()
    b2.optimize.reset_mock()
    b1.optimize.side_effect = Exception("opt fail")
    multi.optimize()
    b1.optimize.assert_called_once()
    b2.optimize.assert_called_once()
