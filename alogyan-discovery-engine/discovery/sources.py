"""Conservative configured-page adapter. No recursive or browser crawling."""
import ipaddress
import json
import socket
import time
from urllib.parse import urlsplit
from urllib.robotparser import RobotFileParser
import httpx
from scrapling.parser import Selector
from .models import CrawlSource, Observation, public_url
from .normalize import digest, name_key

ALLOWED_TYPES = {'EducationalOrganization', 'School', 'Preschool', 'ElementarySchool',
                 'MiddleSchool', 'HighSchool', 'CollegeOrUniversity', 'Organization',
                 'LocalBusiness', 'ProfessionalService'}


def assert_public_host(url: str):
    public_url(url)
    host = urlsplit(url).hostname
    addresses = socket.getaddrinfo(host, None, type=socket.SOCK_STREAM)
    if not addresses or any(not ipaddress.ip_address(address[4][0]).is_global for address in addresses):
        raise ValueError('Crawling requires a public internet host')


def extract(html: str, source: CrawlSource) -> list[Observation]:
    page = Selector(content=html)
    records = []
    for script in page.css('script[type="application/ld+json"]::text').getall():
        try:
            data = json.loads(script)
        except (ValueError, TypeError):
            continue
        queue = data if isinstance(data, list) else [data]
        for item in queue[:50]:
            if not isinstance(item, dict):
                continue
            nodes = item.get('@graph', [item])
            if not isinstance(nodes, list):
                continue
            for node in nodes[:50]:
                if not isinstance(node, dict):
                    continue
                types = node.get('@type', [])
                types = [types] if isinstance(types, str) else types
                if not set(types) & ALLOWED_TYPES or not isinstance(node.get('name'), str):
                    continue
                address = node.get('address', {})
                address = address if isinstance(address, dict) else {}
                location = source.location.model_copy(update={
                    key: address[field] for key, field in [('city', 'addressLocality'),
                        ('state', 'addressRegion'), ('postalCode', 'postalCode')]
                    if isinstance(address.get(field), str)})
                website = node.get('url', source.url)
                website = website if isinstance(website, str) else source.url
                def strings(key):
                    value = node.get(key, [])
                    return [value] if isinstance(value, str) else [v for v in value if isinstance(v, str)] if isinstance(value, list) else []
                # Keep only organization-level public evidence, not the whole HTML,
                # Person objects, students, staff lists, street addresses, or arbitrary metadata.
                raw = {key: node[key] for key in ('@type', 'name', 'url', 'telephone', 'email') if key in node}
                external_id = node.get('@id')
                records.append(Observation(provider=source.provider,
                    externalId=external_id if isinstance(external_id, str) else digest([source.url, name_key(node['name']), location.model_dump()]),
                    url=source.url, entityType=source.entityType, name=node['name'], website=website,
                    phones=strings('telephone'), emails=strings('email'), location=location,
                    raw=raw, trust=source.trust))
    if not records:
        title = page.css('h1::text').get() or page.css('title::text').get()
        if title and title.strip():
            records.append(Observation(provider=source.provider, externalId=source.url,
                url=source.url, website=source.url, entityType=source.entityType,
                name=title.strip()[:300], location=source.location,
                raw={'heading': title.strip()[:300]}, trust=min(source.trust, 30)))
    return records


class WebsiteAdapter:
    def __init__(self, user_agent: str, delay: float):
        self.user_agent, self.delay = user_agent, delay
        self._last_request = {}

    def _throttle(self, origin: str, delay: float):
        remaining = delay - (time.monotonic() - self._last_request.get(origin, float('-inf')))
        if remaining > 0:
            time.sleep(remaining)
        self._last_request[origin] = time.monotonic()

    def fetch_html(self, url: str, authorized: bool) -> str:
        if not authorized:
            raise ValueError('Source has not been approved for public crawling')
        assert_public_host(url)
        parts = urlsplit(url)
        origin = f'{parts.scheme}://{parts.netloc}'
        robots_url = origin + '/robots.txt'
        self._throttle(origin, self.delay)
        response = httpx.get(robots_url, headers={'User-Agent': self.user_agent},
                             timeout=20, follow_redirects=False)
        parser = RobotFileParser(robots_url)
        if response.status_code == 404:
            parser.parse([])
        elif response.status_code == 200:
            parser.parse(response.text.splitlines())
        else:
            raise ValueError('robots.txt unavailable or disallows safe crawling')
        if not parser.can_fetch(self.user_agent, url):
            raise ValueError('robots.txt disallows this URL')
        delay = max(self.delay, parser.crawl_delay(self.user_agent) or 0)
        rate = parser.request_rate(self.user_agent)
        if rate and rate.requests:
            delay = max(delay, rate.seconds / rate.requests)
        if delay > 60:
            raise ValueError('Source requires a crawl delay beyond the batch policy')
        self._throttle(origin, delay)
        from scrapling.fetchers import Fetcher
        page = Fetcher.get(url, headers={'User-Agent': self.user_agent},
                           impersonate=None, stealthy_headers=False, follow_redirects=False, retries=0, timeout=30)
        if page.status != 200:
            raise ValueError(f'Source HTTP status {page.status}; no redirect or bypass attempted')
        if len(page.body) > 2_000_000:
            raise ValueError('Source exceeds 2 MB extraction budget')
        return page.body.decode('utf-8', errors='replace')

    def discover(self, source: CrawlSource) -> list[Observation]:
        observations = extract(self.fetch_html(source.url, source.authorized), source)
        if not observations:
            raise ValueError('No public education organization extracted')
        return observations
