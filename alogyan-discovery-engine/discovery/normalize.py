"""Pure deterministic normalization; no DNS, database, or AI calls."""
import hashlib
import json
import re
import unicodedata
from urllib.parse import urlsplit, urlunsplit
import phonenumbers
import tldextract
import unidecode
from .models import Observation

_extract = tldextract.TLDExtract(cache_dir=None, suffix_list_urls=(), include_psl_private_domains=True)


def digest(value) -> str:
    return hashlib.sha256(json.dumps(value, sort_keys=True, ensure_ascii=False,
                                     separators=(',', ':'), default=str).encode()).hexdigest()


def name_key(value: str) -> str:
    value = unicodedata.normalize('NFKC', value).casefold()
    value = ''.join(c if c.isalnum() else ' ' for c in value)
    return re.sub(r'\bcentre\b', 'center', ' '.join(value.split()))


def phone(value: str) -> str | None:
    try:
        parsed = phonenumbers.parse(value, 'IN')
        if phonenumbers.is_valid_number(parsed):
            return phonenumbers.format_number(parsed, phonenumbers.PhoneNumberFormat.E164)
    except phonenumbers.NumberParseException:
        pass
    return None


def normalize_phone_e164(value: str, default_region: str = 'IN') -> str | None:
    """Parses and formats a phone number into strict E.164."""
    if not value or not isinstance(value, str):
        return None
    try:
        parsed = phonenumbers.parse(value.strip(), default_region)
        if phonenumbers.is_valid_number(parsed):
            return phonenumbers.format_number(parsed, phonenumbers.PhoneNumberFormat.E164)
    except phonenumbers.NumberParseException:
        pass
    return None


def domain(value: str) -> str | None:
    if not value or not isinstance(value, str):
        return None
    host = urlsplit(value if '://' in value else 'https://' + value).hostname
    if not host:
        return None
    result = _extract(host.lower())
    return getattr(result, 'top_domain_under_public_suffix', None) or result.registered_domain or None


def normalize_domain(value: str) -> str | None:
    return domain(value)


def clean_text_unicode(value: str) -> str:
    """Cleans Unicode artifacts, zero-width characters, and normalizes quotes/spaces."""
    if not value:
        return ""
    # Standardize curly quotes to straight quotes
    cleaned = value.replace('’', "'").replace('‘', "'").replace('“', '"').replace('”', '"')
    # Remove zero-width chars and non-breaking spaces
    cleaned = re.sub(r'[\u200b\u200c\u200d\uFEFF\xa0]', ' ', cleaned)
    # Collapse consecutive whitespace
    cleaned = ' '.join(cleaned.split())
    return cleaned.strip()


def normalized_url(value: str) -> str:
    parts = urlsplit(value)
    return urlunsplit((parts.scheme.lower(), parts.netloc.lower(), parts.path or '/', parts.query, ''))


def source_key(obs: Observation) -> str:
    return digest([obs.provider, obs.externalId or normalized_url(obs.url)])


def canonical_fields(obs: Observation) -> dict:
    location = obs.location.model_dump()
    for key in ('city', 'locality', 'state'):
        location[key] = ' '.join(location[key].strip().split())
        location[key + 'Key'] = name_key(location[key])
    location['postalCode'] = re.sub(r'\s', '', location['postalCode'])
    taxonomy = {}
    synonyms = {'math': 'mathematics', 'maths': 'mathematics', 'computer science': 'computing'}
    for key, values in obs.taxonomy.model_dump().items():
        taxonomy[key] = sorted({synonyms.get(name_key(v), name_key(v)) for v in values if name_key(v)})
    emails = sorted({e.strip().casefold() for e in obs.emails
                     if re.fullmatch(r'[^\s@]+@[^\s@]+\.[^\s@]+', e.strip())})
    domains = [d] if (d := domain(obs.website)) else []
    return dict(name=' '.join(obs.name.split()), normalizedName=name_key(obs.name),
                entityType=obs.entityType, website=obs.website, description=obs.description.strip(),
                location=location, taxonomy=taxonomy,
                normalized=dict(phones=sorted({p for v in obs.phones if (p := phone(v))}),
                                emails=emails, domains=domains))


def observation_document(obs: Observation, run_id: str, now) -> dict:
    payload = obs.model_dump()
    content_hash = digest(payload)
    key = source_key(obs)
    return {'_id': digest([key, content_hash]), 'sourceKey': key,
            'source': {'provider': obs.provider, 'externalId': obs.externalId, 'url': obs.url},
            'payload': payload, 'fingerprints': {'content': content_hash},
            'observedAt': now, 'lastSeenAt': now, 'runId': run_id,
            'processing': {'status': 'pending', 'attempts': 0}}
