# Skill: MongoDB Data Model and Indexing

## Purpose
Keep MongoDB fast for both batch entity resolution and public discovery reads.

## Collection responsibilities

### source_observations
Raw or lightly normalized provider results.
Never used directly by public search.

### education_entities
Canonical real-world entities.
Acts as the write/source-of-truth model.

### entity_sources
Maps canonical entities to source records and provenance.

### discovery_profiles
Denormalized public read model.
Optimized for filtering, ranking, Atlas Search and Vector Search.

## Index rules
Create indexes for query patterns, not every field.

### education_entities
Recommended:
- unique slug
- normalized.phones
- normalized.domains
- normalized.emails
- compound: entityType + location.cityKey + normalizedName
- 2dsphere on location.geo

### source_observations
Recommended:
- provider + externalId
- source.url + fingerprints.content
- processing.status + observedAt
- runId

### discovery_profiles
Recommended:
- unique canonicalId
- unique slug
- entityType + location.cityKey + ranking.finalScore
- entityType + location.cityKey + taxonomy.subjects + ranking.finalScore
- 2dsphere on location.geo

Use partial indexes where appropriate for status=active.

## Read optimization
Public list/search requests should project only fields required for cards.
Profile detail requests can fetch the larger read document.
Avoid large embedded arrays that grow without bound.
Use separate collections for:
- source history
- reviews
- courses with unbounded lifecycle
- analytics
- audit history

## Pagination
Avoid deep skip/limit pagination.
Use cursor pagination using stable sortable fields such as:
- ranking.finalScore
- _id

For Atlas Search, prefer searchAfter/search sequence tokens.

## Write optimization
Use bulk_write for batch ingestion and updates.
Use atomic operators:
- $set
- $inc
- $addToSet
- $pull

Avoid rewriting full documents unnecessarily.
