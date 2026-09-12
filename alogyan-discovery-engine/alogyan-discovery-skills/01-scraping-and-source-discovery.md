# Skill: Scraping and Source Discovery

## Purpose
Discover public education businesses/professionals and extract clean source observations.

## Supported target entities
- private_school
- coaching_centre
- training_institute
- tutor
- activity_provider
- college
- education_service

## Source strategy
Prefer sources in this order:
1. Claimed/verified Alogyan profile
2. Official institution website
3. Government/public authority source
4. Authorized provider APIs
5. Official social/business profile
6. Trusted education/business directories
7. General public web pages

## Scrapling usage
Use Scrapling primarily for public websites.
Prefer normal HTTP fetching first.
Use browser/dynamic fetching only when JavaScript is necessary.
Obey robots.txt where applicable.
Use throttling and conservative concurrency.
Do not build bypasses for authentication, CAPTCHA, rate limits, or access controls.

## Source adapter interface
Every source adapter should return the same shape:

```python
{
    "provider": str,
    "externalId": str | None,
    "url": str | None,
    "entityType": str | None,
    "name": str | None,
    "website": str | None,
    "location": dict,
    "raw": dict,
}
```

## Extraction priority
Prefer deterministic extraction before AI:
- JSON-LD
- schema.org
- title/meta tags
- h1/h2
- contact/about pages
- phone/email patterns
- canonical links
- address blocks
- course/subject/class lists

## Data safety
Do not collect private student/minor data.
Do not collect:
- student personal phone numbers
- student personal emails
- home addresses
- roll numbers
- DOB
- attendance
- private social profiles
- private WhatsApp data

Focus on public institution and professional information.

## Idempotency
Each observation should have:
- source.provider
- source.externalId when available
- source.url
- observedAt
- contentHash
- runId

Repeated unchanged observations should not create unnecessary duplicate processing.
