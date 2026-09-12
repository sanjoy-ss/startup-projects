"""Scrapling HTML link discovery. Search hits are candidates, never verified entities."""
from urllib.parse import parse_qs, urlencode, urljoin, urlsplit, urlunsplit
from scrapling.parser import Selector
from .models import CrawlSource, Location, public_url
from .normalize import digest


class SearchBlockedError(ValueError):
    """A challenge page must not be interpreted as search results."""


def google_url(query: str) -> str:
    return 'https://www.google.com/search?' + urlencode({'q': query, 'hl': 'en'})


def extract_candidates(html: str, page_url: str, provider: str, entity_type: str,
                       location: Location, limit: int = 10, selector: str = 'a:has(h3)') -> list[dict]:
    page = Selector(content=html)
    if page.css('form[action*="sorry"], iframe[src*="recaptcha"], #captcha').get():
        raise SearchBlockedError('Search returned a CAPTCHA; no bypass attempted')
    if any(text in html.lower() for text in ('our systems have detected unusual traffic', 'before you continue to google')):
        raise SearchBlockedError('Search returned a challenge or consent page')
    candidates = []
    seen = set()
    for anchor in page.css(selector):
        href = anchor.attrib.get('href', '')
        if provider == 'google' and (href.startswith('/url?') or href.startswith('https://www.google.com/url?')):
            query = parse_qs(urlsplit(href).query)
            href = (query.get('q') or query.get('url') or [''])[0]
        url = urljoin(page_url, href)
        try:
            public_url(url)
        except ValueError:
            continue
        parts = urlsplit(url)
        host = parts.hostname.lower()
        if provider == 'google' and (host == 'google.com' or host.endswith('.google.com') or host.endswith('.google.co.in') or host == 'google.co.in'):
            continue
        if not href or href.startswith(('#', 'javascript:', 'mailto:', 'tel:')):
            continue
        url = urlunsplit((parts.scheme, parts.netloc, parts.path or '/', parts.query, ''))
        if url in seen:
            continue
        seen.add(url)
        title = ' '.join(anchor.css('::text').getall()).strip()
        source = CrawlSource(id='discovered-' + digest(url)[:20], provider='public-website',
                             url=url, entityType=entity_type, location=location, trust=30)
        candidates.append({'title': ' '.join(title.split())[:300], 'foundOn': page_url,
                           'source': source.model_dump()})
        if len(candidates) >= limit:
            break
    return candidates


def discover_search(fetcher, *, query: str, entity_type: str, city: str,
                    state: str, limit: int, directory_url: str | None = None,
                    selector: str = 'a:has(h3)') -> dict:
    page_url = directory_url or google_url(query)
    provider = 'directory' if directory_url else 'google'
    html = fetcher.fetch_html(page_url, authorized=True)
    candidates = extract_candidates(html, page_url, provider, entity_type,
                                    Location(city=city, state=state), limit, selector)
    return {'query': query, 'provider': provider, 'pageUrl': page_url,
            'status': 'candidates_found' if candidates else 'no_supported_results',
            'candidates': candidates}
