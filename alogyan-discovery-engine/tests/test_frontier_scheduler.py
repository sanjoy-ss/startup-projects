import pytest
from discovery.frontier.frontier import URLFrontier

def test_frontier_canonical_url_deduplication():
    frontier = URLFrontier(crawl_delay=3.0)
    item1 = frontier.create_item("https://example.edu.in/?utm_source=google&ref=123", "search")
    item2 = frontier.create_item("https://example.edu.in/", "maps")
    assert item1.url_hash == item2.url_hash
    assert item1.domain == "example.edu.in"

def test_frontier_domain_politeness_filtering():
    frontier = URLFrontier(crawl_delay=3.0)
    items = [
        frontier.create_item("https://school-a.edu.in/page1", "search"),
        frontier.create_item("https://school-a.edu.in/page2", "search"),
        frontier.create_item("https://school-b.edu.in/home", "search"),
    ]
    polite = frontier.filter_domain_polite(items)
    # Only 1 request per domain allowed in a single batch
    domains = [it.domain for it in polite]
    assert len(domains) == 2
    assert "school-a.edu.in" in domains
    assert "school-b.edu.in" in domains
