"""Query Generator generating search queries, Overpass OSM queries, and directory seeds."""
from urllib.parse import urlsplit
import tldextract
from discovery.models import FrontierItem


class QueryGenerator:
    DEFAULT_LOCALITIES = [
        "Banamalipur", "Dhaleswar", "Ramnagar", "Indranagar",
        "Arundhutinagar", "Kunjaban", "79 Tilla", "Badharghat", "Bordowali"
    ]

    INTENTS = [
        "schools", "CBSE schools", "ICSE schools", "higher secondary schools",
        "coaching centres", "NEET coaching", "JEE coaching",
        "colleges", "private tutors"
    ]

    def build_search_queries(self, city: str = "Agartala", state: str = "Tripura") -> list[str]:
        queries = []
        for intent in self.INTENTS:
            queries.append(f"{intent} in {city}")
            queries.append(f"{intent} in {city} {state}")
        for locality in self.DEFAULT_LOCALITIES:
            queries.append(f"schools near {locality} {city}")
            queries.append(f"coaching institutes near {locality} {city}")
        return queries

    def build_osm_overpass_query(self, bbox: tuple[float, float, float, float] = (23.75, 91.20, 23.95, 91.35)) -> str:
        """Builds Overpass QL query string for bounding box (south, west, north, east)."""
        s, w, n, e = bbox
        return f"""
        [out:json][timeout:30];
        (
          node["amenity"~"school|college|kindergarten"]({s},{w},{n},{e});
          way["amenity"~"school|college|kindergarten"]({s},{w},{n},{e});
          node["building"~"university|school"]({s},{w},{n},{e});
        );
        out center;
        """

    def parse_osm_response(self, osm_json: dict) -> list[FrontierItem]:
        items = []
        elements = osm_json.get("elements", [])
        for elem in elements:
            tags = elem.get("tags", {})
            website = tags.get("website") or tags.get("contact:website") or tags.get("url")
            name = tags.get("name") or tags.get("official_name", "Educational Institution")
            if website and website.startswith(("http://", "https://")):
                ext = tldextract.extract(website)
                domain = getattr(ext, 'top_domain_under_public_suffix', None) or ext.registered_domain or urlsplit(website).netloc
                item = FrontierItem(
                    url=website.strip(),
                    domain=domain,
                    source_type="maps",
                    query_origin=f"osm:{name}",
                    priority=8
                )
                items.append(item)
        return items

    def build_directory_seeds(self, city: str = "Agartala", state: str = "Tripura") -> list[FrontierItem]:
        seeds = [
            ("https://tripura.gov.in", "Official Portal of Government of Tripura"),
            ("https://education.tripura.gov.in", "Directorate of Secondary Education Tripura"),
            ("https://tbse.tripura.gov.in", "Tripura Board of Secondary Education"),
        ]
        items = []
        for url, desc in seeds:
            ext = tldextract.extract(url)
            domain = getattr(ext, 'top_domain_under_public_suffix', None) or ext.registered_domain or urlsplit(url).netloc
            items.append(FrontierItem(
                url=url,
                domain=domain,
                source_type="directory",
                query_origin=desc,
                priority=10
            ))
        return items
