"""URL Frontier managing crawling queue, canonical URL deduplication, and politeness."""
from urllib.parse import urlsplit, urlunsplit, parse_qsl, urlencode
from typing import Literal
import tldextract
from discovery.models import FrontierItem


class URLFrontier:
    STRIP_PARAMS = {
        'utm_source', 'utm_medium', 'utm_campaign', 'utm_term', 'utm_content',
        'ref', 'fbclid', 'gclid', 'msclkid', 'sessionid', 'sid'
    }

    def __init__(self, repository=None, crawl_delay: float = 3.0):
        self.repository = repository
        self.crawl_delay = crawl_delay

    def normalize_url(self, raw_url: str) -> str:
        """Strips tracking query parameters and fragments, standardizes trailing slashes."""
        parts = urlsplit(raw_url.strip())
        scheme = parts.scheme.lower()
        netloc = parts.netloc.lower()
        path = parts.path.rstrip('/')

        query_params = [
            (k, v) for k, v in parse_qsl(parts.query, keep_blank_values=True)
            if k.lower() not in self.STRIP_PARAMS
        ]
        new_query = urlencode(sorted(query_params)) if query_params else ''
        return urlunsplit((scheme, netloc, path, new_query, ''))

    def create_item(
        self,
        url: str,
        source_type: Literal["search", "maps", "directory", "website"] = "website",
        query_origin: str = "",
        priority: int = 5
    ) -> FrontierItem:
        normalized = self.normalize_url(url)
        ext = tldextract.extract(normalized)
        domain = getattr(ext, 'top_domain_under_public_suffix', None) or ext.registered_domain or urlsplit(normalized).netloc
        return FrontierItem(
            url=normalized,
            domain=domain,
            source_type=source_type,
            query_origin=query_origin,
            priority=priority
        )

    def filter_domain_polite(self, items: list[FrontierItem]) -> list[FrontierItem]:
        """Ensures at most one request per registered domain in the current batch."""
        seen_domains = set()
        polite_batch = []
        for item in items:
            if item.domain not in seen_domains:
                seen_domains.add(item.domain)
                polite_batch.append(item)
        return polite_batch

    async def enqueue_batch(self, items: list[FrontierItem]) -> int:
        if not self.repository:
            return len(items)
        inserted = 0
        for item in items:
            is_new = await self.repository.enqueue_frontier_item(item)
            if is_new:
                inserted += 1
        return inserted
