import pytest
from unittest.mock import AsyncMock, patch
from discovery.models import FrontierItem
from discovery.fetcher.router import SourceRouter

@pytest.mark.asyncio
async def test_router_selects_http_by_default():
    router = SourceRouter(user_agent="AlogyanTest/1.0", timeout=5)
    item = FrontierItem(
        url="https://example.edu.in",
        domain="example.edu.in",
        source_type="website"
    )
    with patch.object(router, "_fetch_http", new_callable=AsyncMock) as mock_http:
        mock_http.return_value = {
            "status_code": 200,
            "html": "<html><body><h1>Example School</h1></body></html>",
            "headers": {"content-type": "text/html"}
        }
        snapshot = await router.fetch(item)
        assert snapshot.fetched_via == "scrapling_http"
        assert snapshot.status_code == 200
        assert "Example School" in snapshot.html

@pytest.mark.asyncio
async def test_router_falls_back_to_browser_on_challenge():
    router = SourceRouter(user_agent="AlogyanTest/1.0", timeout=5)
    item = FrontierItem(
        url="https://protected-portal.edu.in",
        domain="protected-portal.edu.in",
        source_type="website"
    )
    with patch.object(router, "_fetch_http", new_callable=AsyncMock) as mock_http, \
         patch.object(router, "_fetch_browser", new_callable=AsyncMock) as mock_browser:
        
        # HTTP returns challenge
        mock_http.return_value = {
            "status_code": 403,
            "html": "<html><body>Attention Required! | Cloudflare</body></html>",
            "headers": {}
        }
        # Browser succeeds
        mock_browser.return_value = {
            "status_code": 200,
            "html": "<html><body><h1>Protected School Portal</h1></body></html>",
            "headers": {}
        }

        snapshot = await router.fetch(item)
        assert mock_browser.called
        assert snapshot.fetched_via == "browser_fetch"
        assert snapshot.status_code == 200
        assert "Protected School Portal" in snapshot.html
