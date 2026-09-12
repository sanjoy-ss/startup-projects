"""Source router routing requests between Scrapling HTTP and Browser fetchers."""
import logging
from typing import Literal
import certifi
import httpx
import asyncio
from tenacity import retry, stop_after_attempt, wait_exponential, retry_if_exception_type
from discovery.models import FrontierItem, RawSnapshot, utcnow


class SourceRouter:
    CHALLENGE_KEYWORDS = [
        "cloudflare", "challenge-platform", "cf-mitigated",
        "attention required", "security check", "please wait... | cloudflare",
        "ddos-guard", "verify you are human"
    ]

    def __init__(self, user_agent: str = 'AlogyanDiscovery/2.0', timeout: float = 15.0, crawl_delay: float = 3.0):
        self.user_agent = user_agent
        self.timeout = timeout
        self.crawl_delay = crawl_delay
        self.headers = {
            "User-Agent": self.user_agent,
            "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8",
            "Accept-Language": "en-US,en;q=0.9",
            "Accept-Encoding": "gzip, deflate, br",
            "Sec-Fetch-Dest": "document",
            "Sec-Fetch-Mode": "navigate",
            "Sec-Fetch-Site": "none",
            "Sec-Fetch-User": "?1",
            "Upgrade-Insecure-Requests": "1"
        }

    def is_challenge_or_blocked(self, status_code: int, html: str) -> bool:
        if status_code in (403, 503):
            return True
        html_lower = html.lower()
        if len(html.strip()) < 500 and any(keyword in html_lower for keyword in self.CHALLENGE_KEYWORDS):
            return True
        return False

    @retry(
        reraise=True,
        stop=stop_after_attempt(2),
        wait=wait_exponential(multiplier=1, min=1, max=5),
        retry=retry_if_exception_type((httpx.RequestError, httpx.TimeoutException))
    )
    async def _fetch_http(self, url: str) -> dict:
        async with httpx.AsyncClient(
            headers=self.headers,
            timeout=self.timeout,
            follow_redirects=True,
            verify=certifi.where()
        ) as client:
            response = await client.get(url)
            return {
                "status_code": response.status_code,
                "html": response.text,
                "headers": dict(response.headers)
            }

    async def _fetch_browser(self, url: str) -> dict:
        """Fetches page using Scrapling's stealth browser or Playwright in a background worker thread."""
        def _sync_fetch():
            from scrapling.fetchers import StealthyFetcher
            fetcher = StealthyFetcher()
            response = fetcher.fetch(url, timeout=int(self.timeout * 1000))
            return {
                "status_code": getattr(response, "status", 200),
                "html": getattr(response, "text", ""),
                "headers": {}
            }

        try:
            return await asyncio.to_thread(_sync_fetch)
        except Exception as exc:
            logging.warning("Browser fetch failed for %s: %s", url, exc)
            return {
                "status_code": 0,
                "html": "",
                "headers": {"error": str(exc)}
            }

    async def fetch(self, item: FrontierItem, run_id: str = "") -> RawSnapshot:
        fetched_via: Literal["scrapling_http", "browser_fetch"] = "scrapling_http"
        try:
            res = await self._fetch_http(item.url)
            if self.is_challenge_or_blocked(res["status_code"], res["html"]):
                logging.info("Challenge or block detected for %s; switching to browser fetch", item.url)
                res = await self._fetch_browser(item.url)
                fetched_via = "browser_fetch"
        except Exception as exc:
            logging.warning("HTTP fetch failed for %s (%s); switching to browser fetch", item.url, type(exc).__name__)
            res = await self._fetch_browser(item.url)
            fetched_via = "browser_fetch"

        return RawSnapshot(
            url=item.url,
            status_code=res.get("status_code", 0),
            headers=res.get("headers", {}),
            html=res.get("html", ""),
            fetched_via=fetched_via,
            run_id=run_id,
            fetched_at=utcnow()
        )
