# Alogyan Discovery Engine — Agent Skill Pack

This skill pack defines the architecture and engineering rules for the Alogyan education discovery engine.

## Recommended reading order
1. `00-project-architecture.md`
2. `01-scraping-and-source-discovery.md`
3. `02-mongodb-data-model-and-indexing.md`
4. `03-normalization-and-entity-resolution.md`
5. `04-search-vector-and-embedding.md`
6. `05-batch-jobs-cron-and-reliability.md`
7. `06-go-discovery-api.md`
8. `07-testing-and-quality.md`

## Current operating constraints
- MongoDB Atlas
- Python + Scrapling batch engine
- Go public discovery API
- Next.js frontend
- Cron twice weekly
- No Redis/Celery/Kafka initially
- Start with Agartala/Tripura
- Public/authorized education data only
- No private student/minor data collection

## Agent behavior
When implementing features:
- preserve the existing architecture unless there is a measured need to change it
- optimize data quality before crawl volume
- keep raw/source and canonical data separate
- optimize public reads through `discovery_profiles`
- prefer exact/indexed matching before fuzzy or AI matching
- use AI embeddings only after entity resolution
- make batch jobs idempotent and restartable
- avoid premature microservice splitting
