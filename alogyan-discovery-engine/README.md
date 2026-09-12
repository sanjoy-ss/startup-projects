# Alogyan Discovery Engine

A Python + Scrapling batch pipeline for MongoDB Atlas, starting with configured public education sources in Agartala/Tripura. No Redis, Celery, Kafka, background workers, or always-running crawler.

The existing `alogyan-discovery-skills/` pack is the architecture contract. The parent `.agents/skills/lean-build/SKILL.md` guided this implementation. No applicable `AGENTS.md` was present when this foundation was created.

## Data flow and ownership

```
configured crawl_sources → Scrapling adapter → source_observations
  → pure normalization → indexed candidates → conservative resolution
  → education_entities + entity_sources + entity_merge_history
  → discovery_profiles → optional changed-content embeddings
                         ↘ duplicate_candidates (manual review)
```

- **source_observations:** immutable extracted source payload per source/content hash; `lastSeenAt` advances on unchanged re-crawls. The original `runId` records first observation. Canonical writes never modify the payload.
- **education_entities:** canonical fields, normalized exact signals, field provenance, protected/claimed state, revision, and projection checkpoint.
- **entity_sources:** unique source-identity mapping; `_id` hashes provider + external ID, or URL when unavailable.
- **duplicate_candidates:** ambiguous observations wait for review, without silently creating or merging an entity.
- **entity_merge_history:** before image and resulting revision per observation. Audit records allow a future guarded reversal; there is no unsafe automatic rollback command.
- **discovery_profiles:** explicit public allowlist; downstream Go/Next.js readers should have read access here and `taxonomy`, not raw collections. The Go API and frontend integration are subsequent work.
- **discovery_runs:** counts, timings, completion/error state.

`discovery/models.py` validates ingestion/source boundaries. `schema.py` defines database validators; `indexes.py` installs validators and indexes. Domain normalization/resolution/projection modules are independent of MongoDB. `repository.py` owns transactions; `pipeline.py` orchestrates stages. `sources.py` is the single website adapter; `embeddings.py` is the optional external vector adapter.

## Setup

Use Python 3.10+ (verified here with Python 3.13). From this directory:

```bash
python3 -m venv .venv
.venv/bin/python -m pip install -r requirements.txt
cp .env.example .env
# Edit .env locally; supply a MongoDB Atlas URI, never commit credentials.
.venv/bin/python main.py init-db
```

Atlas replica-set transactions are required; standalone MongoDB is unsupported. Use a dedicated batch database user. `init-db` needs collection/index/validator administration rights; normal jobs need read/write rights. For an existing database, inspect validator compatibility before running `init-db`: it installs strict validation. Credentials are redacted and exception messages are not dumped to run records.

Copy `sources.example.json`, replace the example URL with an authorized official source, and explicitly set `authorized` and `enabled` to true. Never enable the placeholder. Source config is operator-controlled, not a public URL submission endpoint.

```bash
.venv/bin/python main.py import-sources sources.json
.venv/bin/python main.py weekly
```

Sources default to disabled. `import-sources` validates the entire input before writes and preserves existing crawl dates. Publicly crawlable does not mean permission to collect private student information. The adapter extracts organization-level JSON-LD, with a low-trust title/H1 fallback. It does not ingest `Person` nodes, raw full-page HTML, student arrays, or street addresses. It does not yet enrich contacts from additional pages or implement provider APIs. Taxonomy supports normalized structured input; the website adapter does not guess subjects/classes from arbitrary prose.

The HTTP adapter identifies itself, checks robots, rejects non-public hosts, disables redirects, uses no browser impersonation or access-control bypass, and delays requests. Robots failures and HTTP blocks are durable failures. Use the final permitted URL in the source config when a site redirects. Network egress restrictions remain the deployment boundary for DNS rebinding and malicious source hosts.

## Entity resolution

1. Reuse an existing provider/external-ID-or-URL source mapping.
2. Look up indexed exact phone, registrable domain, email, and name + city + type signals.
3. Only if no exact candidates exist, use an anchored first-name-token block restricted to city/type; score at most 40 candidates with RapidFuzz.
4. Auto-match requires a strong exact contact signal, >= 0.95 name similarity, matching type/city, supporting locality/postal evidence, no branch-location conflict, and exactly one plausible candidate.
5. Name-only, conflicting branches, shared contacts, and saturated candidate sets go to review. Unrelated candidates create a new canonical record.

This deliberately favors review over false merges. A first-token change without contact evidence can produce a duplicate: the initial lexical block is conservative, not a substitute for Atlas Search. Do not expand crawl coverage before checking 100–200 labeled pilot entities, including false merges and missing contact/location data. AI matching is not required or enabled in this version.

Claimed/verified records are preserved wholesale. Other writes use leaf-field trust and timestamps; empty scraped fields cannot erase known values. Raw evidence is retained even when lower trust cannot update canonical fields. Lists are replaced only by nonempty evidence at sufficient trust; source evidence retains prior values for review.

## Restart and retry behavior

- Observation IDs are deterministic source/content hashes; bulk upserts suppress duplicate processing.
- Canonical update, source mapping, audit record, and resolved checkpoint commit in one Atlas transaction.
- A dirty projection flag survives a crash after resolution. Projection writes and clearing the flag are transactional.
- Embedding completion uses a semantic-hash compare-and-set, preventing stale vectors from attaching to a newer profile.
- Pending/failed observations, dirty entities, and pending embeddings are scanned independently of newly crawled sources. Each stage has a configurable batch limit.
- Source failures back off and disable after three failures; observation/embedding failures stop retrying after three attempts. Projection failures retain the dirty flag for the next batch. Error codes are retained without raw secrets.
- After correcting a source, re-enable it and set its `nextCrawlAt` to a due time. After fixing a data/provider error, reset the specific observation's `processing.attempts` or profile's `ai.attempts`; do not mass-reset completed records.
- Review observations remain parked until an operator adjudicates them. A review UI/command is not included in this initial foundation.
- A killed process can leave a run marked `running`; its data-stage checkpoints remain restartable. The next run processes the backlog. Monitor stale run timestamps.

## Embedding contract

The library defaults to embeddings **off**; the supplied `.env.example` and installer select the requested OpenAI preset and require your private API key. Configure the HTTPS URL, key, model, and dimensions only for an authorized OpenAI-compatible endpoint. Calls send controlled public semantic text after resolution, never raw observations. Verify the selected provider/model accepts the `dimensions` parameter.

`ai.semanticHash` includes canonical name, type, description, normalized taxonomy, and locality/city/state. Contact, verification, ranking, and timestamps do not invalidate vectors. Unchanged content preserves vectors and skips the provider. Changed text clears stale vectors, resets attempts, and queues the new hash. Initial profiles without embeddings are pending until a provider is configured. Profile deactivation suppresses embedding work.

An external API call and a MongoDB commit cannot form one transaction: a process killed between those steps may repeat a paid call on retry. Successful persisted hashes are not recomputed. Model/version changes alone do not silently trigger calls; plan an explicit semantic-version migration if changing providers.

Ordinary B-tree and geo indexes ship here. Atlas Search/Vector Search indexes are a deployment-specific next step after selecting an embedding dimension and public API query shape. Never expose vector search across inactive profiles, and use structured filters alongside semantic ranking. Public cursor pagination should sort by `ranking.finalScore` descending then `_id` ascending; avoid deep skip/limit.

## OpenAI configuration and Linux cron installation

Run this on the **Linux server**, as the unprivileged account that will own the job:

```bash
cd /opt/alogyan-discovery-engine
bash deploy/install.sh
```

Prerequisites: Python 3.10+ with venv support, an installed/running cron service, an Atlas cluster reachable from the server, and your OpenAI API key. Set the server timezone to **Asia/Kolkata or UTC** before installation. The installer:

1. Creates/reuses `.venv` and installs pinned requirements.
2. Prompts privately for your Atlas URI and OpenAI key; writes a mode-0600 `.env` while retaining unrelated settings.
3. Configures `https://api.openai.com/v1/embeddings`, `text-embedding-3-small`, and 1536 dimensions. No embedding request is made during setup.
4. Checks configuration and initializes the Atlas validators/indexes.
5. Preserves other cron entries, saves a private recovery copy under `deploy/backups/`, installs one managed entry, and reads it back to verify.

The schedule is Tuesday/Saturday **01:00 IST**. UTC hosts receive Monday/Friday **19:30 UTC**. Unsupported/DST server timezones and existing `CRON_TZ` overrides are rejected to prevent silently wrong schedules. Previewing the cron entry does not modify the system:

```bash
.venv/bin/python deploy/install_cron.py
.venv/bin/python deploy/install_cron.py --install
.venv/bin/python deploy/install_cron.py --remove
```

The remove command deletes only this project's marked entry. Installation is idempotent. Use one scheduler host; Python's POSIX `fcntl.flock` holds `.weekly.lock` across the entire run and skips overlaps. The wrapper works on Linux/macOS without a separate `flock` executable; the one-command installer intentionally targets Linux. Logs rotate under `logs/weekly.log` (2 MB, five backups), including batch statistics and safe failure codes. Monitor these logs and nonzero exits. The wrapper replaces its working directory with the checkout and calls its own venv Python, so cron does not need an interactive shell environment.

Import authorized sources with `main.py import-sources sources.json` before expecting results. Keep the server awake/running at the scheduled times; classic cron does not replay missed runs. Cron is not installed on the development Mac.

To change credentials without reinstalling cron:

```bash
.venv/bin/python deploy/configure_env.py
.venv/bin/python main.py check-config
```

The configuration command selects the OpenAI preset. To disable optional embeddings, clear all three `.env` values `ALOGYAN_EMBEDDING_URL`, `ALOGYAN_EMBEDDING_MODEL`, and `ALOGYAN_EMBEDDING_KEY`. The pipeline can run without embeddings, retaining pending hashes for later. An incomplete enabled configuration fails before crawling. Never put credentials in command-line arguments or source control.

OpenAI requests explicitly ask for float vectors and include the configured dimensions, following the [official embeddings API reference](https://developers.openai.com/api/reference/ruby/resources/embeddings/methods/create). Changing provider/model does not bypass the existing semantic-hash guard.

## Verification

```bash
.venv/bin/python -m unittest discover -s tests -v
.venv/bin/python main.py --help
bash -n deploy/weekly.sh
```

Offline tests use HTML fixtures and deterministic domain inputs; no crawling or paid embedding calls. To exercise real transactions/indexes, configure `ALOGYAN_TEST_MONGODB_URI` with a **test replica set** and rerun. Integration tests create and delete only uniquely named `alogyan_test_*` databases. They test repeat ingestion, persisted embedding reuse/invalidation, and failure after canonical writes to verify transaction rollback and restart.

The local offline suite passes; the real-MongoDB tests remain skipped until a test URI is supplied. Live crawling, Atlas deployment, provider inference, and remote server cron installation are not claimed as verified.

## Reference APIs

- [Scrapling HTTP fetcher reference](https://scrapling.readthedocs.io/en/latest/api-reference/fetchers.html)
- [PyMongo bulk writes](https://www.mongodb.com/docs/languages/python/pymongo-driver/current/crud/bulk-write/)
- [PyMongo indexes](https://www.mongodb.com/docs/languages/python/pymongo-driver/current/indexes/)

## Scrapling search and directory discovery

`discover-web` discovers candidate source URLs without MongoDB or an OpenAI/search API key:

```bash
python main.py discover-web --query "schools in Agartala Tripura" --city Agartala --type private_school
```

It checks robots and fetches one page through Scrapling's HTTP Fetcher, selecting external result links. It never bypasses CAPTCHA/consent pages or publishes search snippets as canonical profiles. **Live verification of the Google command was blocked by Google's robots.txt.** Do not assume the command will return Google results; the tested behavior is an explicit `blocked_or_unavailable` response. Google Maps extraction is not implemented, and the static Google HTML selector is fixture-tested only.

For a permitted public directory, supply its listing page and a CSS selector identifying the relevant links:

```bash
python main.py discover-web --query "Agartala schools" --city Agartala --type private_school --directory-url "https://REPLACE-WITH-PERMITTED-DIRECTORY/schools" --link-selector "a.school-link" --output discovered-sources.json
```

The directory URL/selector above are placeholders: choose them from the real directory markup. The query labels a directory discovery run; it does not submit that query to an arbitrary directory. This first version discovers one page, up to 20 links, without automatic pagination or cron search refresh.

Output is an import-compatible JSON file. Candidate URLs are deduplicated, low-trust, and disabled until reviewed. Search context does not prove that a listing is in the requested area or belongs to that education category. Check each candidate's URL, category, and location; enable/authorize appropriate sources, then run:

```bash
python main.py import-sources discovered-sources.json
python main.py weekly
```

Output files are never overwritten. Use another `--output` for subsequent discovery passes. Existing weekly cron continues refreshing imported sources. No platform API integration was added.
