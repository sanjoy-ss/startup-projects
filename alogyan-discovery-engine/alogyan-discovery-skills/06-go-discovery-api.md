# Skill: Go Discovery API

## Purpose
Serve fast public discovery reads from MongoDB.

## Rules
The Go API reads primarily from:
- discovery_profiles
- taxonomy

It should not serve raw records from:
- source_observations
- duplicate_candidates
- crawl history

## Initial endpoints
- GET /v1/search
- GET /v1/entities/:slug
- GET /v1/nearby
- GET /v1/autocomplete
- GET /v1/taxonomy

## Search endpoint
Support filters such as:
- q
- entityType
- city
- locality
- subject
- class
- board
- verified
- distance/radius

## Response optimization
List/search responses should return compact card DTOs only.
Example:
- id
- slug
- name
- type
- locality
- city
- subjects
- thumbnail
- verified
- ranking summary

Fetch full read profile only on detail endpoint.

## Database rules
- Use MongoDB projections.
- Use compound indexes matching query patterns.
- Use cursor pagination.
- Set sensible timeouts.
- Avoid unbounded queries.
- Cap page size.

## Search strategy
- structured filters -> MongoDB/Atlas Search filters
- text query -> Atlas Search
- semantic query -> Vector Search/hybrid
- nearby -> 2dsphere

## Error behavior
Return stable API errors.
Do not expose database internals or provider secrets.
