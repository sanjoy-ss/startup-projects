"""Deterministic metadata parser extracting structured data and computing confidence."""
import json
import re
from bs4 import BeautifulSoup
from discovery.models import (
    InstructorEducationPayload,
    EducationalCategories,
    GeoLocalHierarchy,
    GeoCoordinates
)


class DeterministicParser:
    EDU_TYPES = {
        "school": "k12_school",
        "educationalorganization": "k12_school",
        "collegeoruniversity": "higher_education_college",
        "preschool": "preschool_daycare",
        "localbusiness": "private_tutor_or_academy"
    }

    def _extract_json_ld(self, soup: BeautifulSoup) -> list[dict]:
        results = []
        for script in soup.find_all('script', type='application/ld+json'):
            try:
                data = json.loads(script.string or '')
                if isinstance(data, dict):
                    if '@graph' in data:
                        results.extend(data['@graph'])
                    else:
                        results.append(data)
                elif isinstance(data, list):
                    results.extend(data)
            except Exception:
                continue
        return results

    def parse(self, html: str, url: str = "") -> tuple[InstructorEducationPayload | None, float]:
        soup = BeautifulSoup(html, 'html.parser')
        json_lds = self._extract_json_ld(soup)

        name = None
        phones = []
        emails = []
        address_str = None
        locality = None
        city = "Agartala"
        state = "Tripura"
        pincode = None
        category = "k12_school"
        lat, lon = None, None

        # 1. Search JSON-LD nodes
        for node in json_lds:
            node_type = str(node.get('@type', '')).lower()
            if any(k in node_type for k in self.EDU_TYPES):
                name = node.get('name') or name
                if 'telephone' in node:
                    tel = node['telephone']
                    if isinstance(tel, list):
                        phones.extend(tel)
                    elif isinstance(tel, str):
                        phones.append(tel)
                if 'email' in node:
                    em = node['email']
                    if isinstance(em, list):
                        emails.extend(em)
                    elif isinstance(em, str):
                        emails.append(em)

                addr = node.get('address')
                if isinstance(addr, dict):
                    locality = addr.get('addressLocality') or locality
                    city = addr.get('addressLocality') or city
                    state = addr.get('addressRegion') or state
                    pincode = addr.get('postalCode') or pincode
                    address_str = addr.get('streetAddress') or address_str
                elif isinstance(addr, str):
                    address_str = addr

                geo = node.get('geo')
                if isinstance(geo, dict):
                    try:
                        lat = float(geo.get('latitude'))
                        lon = float(geo.get('longitude'))
                    except (TypeError, ValueError):
                        pass

                for key, mapped_cat in self.EDU_TYPES.items():
                    if key in node_type:
                        category = mapped_cat
                        break

        # 2. Fallback to OpenGraph and meta tags
        if not name:
            og_title = soup.find('meta', property='og:title') or soup.find('meta', attrs={'name': 'title'})
            if og_title and og_title.get('content'):
                name = og_title['content'].strip()

        if not name and soup.title:
            name = soup.title.string.split('|')[0].split('-')[0].strip() if soup.title.string else None

        # DOM regex scan for contact signals
        if not phones:
            tel_links = soup.find_all('a', href=re.compile(r'^tel:'))
            for link in tel_links:
                phones.append(link['href'].replace('tel:', '').strip())

        if not emails:
            mailto_links = soup.find_all('a', href=re.compile(r'^mailto:'))
            for link in mailto_links:
                emails.append(link['href'].replace('mailto:', '').split('?')[0].strip())

        # Check for 6-digit Indian PIN in text
        if not pincode:
            pin_match = re.search(r'\b(799\d{3})\b', html)
            if pin_match:
                pincode = pin_match.group(1)

        # 3. Calculate Confidence Score
        confidence = 0.0
        if name and len(name) > 3 and "Untitled" not in name:
            confidence += 0.35
        if category:
            confidence += 0.20
        if phones or emails:
            confidence += 0.25
        if locality or pincode:
            confidence += 0.15
        if lat and lon:
            confidence += 0.05

        confidence = min(1.0, round(confidence, 2))

        # Build payload if name is identified
        if name:
            coords = GeoCoordinates(latitude=lat, longitude=lon, geo_source="schema_org") if (lat and lon) else None
            # Validate pincode format
            valid_pin = pincode if (pincode and len(pincode) == 6 and pincode.isdigit()) else None
            geo_local = GeoLocalHierarchy(
                locality=locality,
                city=city or "Agartala",
                state=state or "Tripura",
                pincode=valid_pin
            )
            payload = InstructorEducationPayload(
                name=name,
                entity_type="private_school",
                categories=EducationalCategories(primary_category=category),
                geo_local=geo_local,
                coordinates=coords,
                phones=list(set(phones)),
                emails=list(set(emails)),
                website=url,
                full_address=address_str,
                confidence_assessment=confidence
            )
            return payload, confidence

        return None, confidence
