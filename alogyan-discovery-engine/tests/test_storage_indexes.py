import pytest
from unittest.mock import AsyncMock, MagicMock
from discovery.indexes import ensure_indexes_async, INDEXES
from discovery.storage.repository import AsyncRepository

def test_indexes_contain_new_collections():
    assert "url_frontier" in INDEXES
    assert "raw_snapshots" in INDEXES

@pytest.mark.asyncio
async def test_ensure_indexes_async_runs():
    mock_db = MagicMock()
    mock_db.list_collection_names = AsyncMock(return_value=["url_frontier"])
    mock_db.create_collection = AsyncMock()
    mock_db.command = AsyncMock()
    
    mock_col = MagicMock()
    mock_col.create_indexes = AsyncMock()
    mock_db.__getitem__.return_value = mock_col

    await ensure_indexes_async(mock_db)
    assert mock_col.create_indexes.called

@pytest.mark.asyncio
async def test_async_repository_methods():
    mock_db = MagicMock()
    mock_frontier = MagicMock()
    mock_frontier.update_one = AsyncMock(return_value=MagicMock(modified_count=1))
    mock_snapshots = MagicMock()
    mock_snapshots.update_one = AsyncMock(return_value=MagicMock(upserted_id="123"))

    mock_db.url_frontier = mock_frontier
    mock_db.raw_snapshots = mock_snapshots
    mock_db.__getitem__.side_effect = lambda name: mock_snapshots if name == "raw_snapshots" else mock_frontier

    repo = AsyncRepository(mock_db)
    snapshot = await repo.save_snapshot("https://example.edu.in", 200, "<html></html>", "scrapling_http")
    assert snapshot.status_code == 200
    assert mock_snapshots.update_one.called
