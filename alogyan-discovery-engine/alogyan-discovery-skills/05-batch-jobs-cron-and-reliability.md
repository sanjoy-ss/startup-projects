# Skill: Batch Jobs, Cron and Reliability

## Purpose
Run the entire discovery engine twice per week without Redis, Celery or Kafka.

## Schedule
Default:
- Tuesday 01:00
- Saturday 01:00
Use server-local timezone intentionally and document it.

## Main command
```bash
python main.py weekly
```

## Weekly pipeline
1. Create discovery_run.
2. Load due crawl_sources.
3. Run discovery adapters.
4. Save source_observations.
5. Crawl new/changed websites.
6. Normalize pending observations.
7. Resolve entities.
8. Update canonical entities.
9. Project changed discovery_profiles.
10. Generate embeddings only for changed semanticHash.
11. Update run statistics.
12. Mark run completed/failed.

## Reliability rules
- Entire pipeline must be idempotent.
- Use runId on observations.
- Use status fields for processing stages.
- Store errors rather than losing records.
- Retry only bounded failures.
- Do not infinitely retry dead sites.
- Every stage should be rerunnable.

## Cron lock
Prevent overlapping runs using flock.

Example:
```bash
#!/bin/bash
LOCKFILE="/tmp/alogyan-discovery.lock"
exec 200>"$LOCKFILE"
flock -n 200 || exit 1

cd /opt/alogyan-discovery-engine
.venv/bin/python main.py weekly
```

## Observability
discovery_runs should store:
- startedAt
- completedAt
- duration
- queries
- discovered URLs
- pages crawled
- observations
- new entities
- updated entities
- duplicate matches
- review candidates
- embeddings generated
- errors

## Crawl cadence
Not every source needs the same refresh rate.
Store nextCrawlAt and crawl interval per source.
