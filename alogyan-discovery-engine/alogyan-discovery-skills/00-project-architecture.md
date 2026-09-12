# Skill: Alogyan Discovery Architecture

## Purpose
Build and maintain the Alogyan education discovery engine as a simple, scalable batch-processing system.

## Current architecture
- Python 3.10+ batch engine.
- Scrapling for permitted website crawling.
- MongoDB Atlas as operational and read database.
- Go Discovery API as the always-running public read API.
- Next.js as web frontend.
- Cron runs discovery twice per week.
- No Redis, Kafka, Celery, or always-running crawler service at the current stage.

## Core data flow
1. Discover candidates from configured sources.
2. Save every source result as a source observation.
3. Crawl official/public websites when appropriate.
4. Normalize names, phones, domains, locations and taxonomy.
5. Generate exact fingerprints.
6. Generate duplicate candidates using indexed lookups.
7. Run fuzzy/entity-resolution scoring.
8. Create or update canonical education entities.
9. Project changed canonical entities into discovery_profiles.
10. Recompute embeddings only when semanticHash changes.
11. Public API reads from discovery_profiles, not raw/source collections.

## Core MongoDB collections
- discovery_runs
- crawl_sources
- source_observations
- education_entities
- entity_sources
- duplicate_candidates
- entity_merge_history
- discovery_profiles
- taxonomy

## Design rules
- Raw observations and canonical entities must remain separate.
- Public API must not query source_observations.
- Avoid cross-collection joins on user-facing search paths.
- discovery_profiles is a denormalized read model.
- Never overwrite verified/claimed data with lower-trust scraped data.
- Every canonical field should retain provenance where practical.
- Prefer idempotent batch jobs.
- Every stage must be restartable.
- Do not introduce new infrastructure unless production load proves it is needed.

## Scaling philosophy
Scale vertically and optimize indexes first.
Split services only when there is a measured bottleneck.
Do not prematurely add queues, Kafka, distributed schedulers or sharding.
