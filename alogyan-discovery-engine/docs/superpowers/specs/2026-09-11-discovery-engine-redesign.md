# Alogyan Discovery Engine Redesign Specification

**Status:** Approved by User  
**Date:** 2026-09-11  
**Target:** `alogyan-discovery-engine`  
**Runtime:** Python 3.12+ with `uv`  

---

## 1. Executive Summary & Goals

The **Alogyan Discovery Engine** is an automated, modular, asynchronous data-discovery and lead-intelligence system tailored for educational institutions, academies, schools, colleges, and coaching centers.

### Primary Objectives:
1. **Automated Discovery**: Eliminate static manual URL seeding by introducing a dynamic **Query Generator** (Search, Maps, and Directories) and a domain-polite **URL Frontier**.
2. **Dual-Speed Fetch & Extraction**: Fast, zero-overhead **Scrapling HTTP** fetch for ~85% of standard sites, with automatic fallback to **Headless Browser fetch** for JavaScript-heavy/protected pages.
3. **Two-Tier Parser**: Sub-millisecond deterministic parsing (JSON-LD, Microdata, DOM regex) with confidence scoring, backed by an **Instructor + LLM fallback** (using Trafilatura / Crawl4AI) for messy, unformatted pages.
4. **Data Normalization & Resolution**: Robust normalization (`phonenumbers` E.164, `tldextract` domains, `unidecode` text) paired with `RapidFuzz` conservative candidate resolution to prevent accidental entity merges.
5. **Lead Scoring Engine**: Multi-factor scoring ($0 - 100$) evaluating Data Completeness (40%), Contactability (30%), Vitality & Freshness (20%), and Institutional Credibility (10%).
6. **Async MongoDB Atlas Persistence**: Pure asynchronous transactions (PyMongo Async / Motor) writing to canonical collections, read-optimized `discovery_profiles`, and a review queue in `duplicate_candidates` consumed by the Next.js Console (`alogyan-console`).

---

## 2. Architecture & Data Flow

```
                     ALOGYAN DISCOVERY ENGINE
                                │
                                ▼
                        QUERY GENERATOR
                                │
        ┌───────────────────────┼───────────────────────┐
        ▼                       ▼                       ▼
   Web Search            OpenStreetMap Maps         Directories
  (DDG/SearXNG)           (Overpass API)        (Education Portals)
        │                       │                       │
        └───────────────────────┼───────────────────────┘
                                │
                                ▼
                           URL FRONTIER
                   (Politeness, Dedup, Priority)
                                │
                                ▼
                          SOURCE ROUTER
                                │
                     ┌──────────┴──────────┐
                     ▼                     ▼
              Scrapling HTTP         Browser fetch
                 (Async)             (Playwright)
                     │                     │
                     └──────────┬──────────┘
                                ▼
                          RAW SNAPSHOT
                    (Immutable HTML / Headers)
                                │
                                ▼
                      DETERMINISTIC PARSER
                                │
                     ┌──────────┴──────────┐
                     ▼                     ▼
               Confidence ≥ 0.70     Confidence < 0.70
                     │                     │
              Structured Data       Trafilatura / Crawl4AI
                     │                     │
                     │                     ▼
                     │              Instructor LLM
                     │              (OpenAI / Gemini)
                     │                     │
                     └──────────┬──────────┘
                                ▼
                       SOURCE OBSERVATION
                                │
                                ▼
                            NORMALIZER
                 (Phones E.164, Domains, Addresses)
                                │
                                ▼
                           DEDUPLICATOR
                     (Exact Signals + RapidFuzz)
                                │
                                ▼
                            ENRICHMENT
                     (Geo Coordinates, Boards)
                                │
                                ▼
                           LEAD SCORE
                 (Completeness, Contact, Freshness)
                                │
                                ▼
                          MongoDB Atlas
                                │
                 ┌──────────────┴──────────────┐
                 ▼                             ▼
         Atlas Search Index             Next.js Console
```

---

## 3. Technology Stack & Dependencies

The project uses `uv` for lightning-fast, reproducible dependency management under Python 3.12+:

- **Package & Virtualenv Management**: `uv`
- **Crawling & Fetching**: `scrapling[fetchers]>=0.4.15`, `httpx>=0.28.1`, `tenacity>=9.0.0`
- **Text & HTML Extraction**: `trafilatura>=2.0.0`, `beautifulsoup4>=4.13.0`
- **LLM Structured Extraction**: `instructor>=1.7.0`, `pydantic>=2.10.0`, `pydantic-settings>=2.7.0`
- **Data Normalization & Deduplication**:
  - `phonenumbers>=9.0.39` (E.164 parsing)
  - `tldextract>=5.3.2` (registered domain extraction)
  - `unidecode>=1.4.0` (Unicode text normalization)
  - `rapidfuzz>=3.14.6` (Levenshtein / token matching)
- **Database & Storage**:
  - `motor>=3.7.0` (Async MongoDB driver)
  - `certifi>=2026.7.22`
- **Vector & Embeddings**: External OpenAI-compatible embedding endpoint (`text-embedding-3-small` preset)

---

## 4. Subsystems Specification

### 4.1. Query Generator (`discovery/frontier/query_generator.py`)
Generates systematic seed candidates across three vectors:
1. **Web Search**:
   - Generates matrices across `(entity_type, locality, city, intent)`:
     - e.g., `"schools in Agartala"`, `"CBSE higher secondary in West Tripura"`, `"NEET coaching institutes Agartala"`, `"math tutors near Banamalipur"`.
   - Uses Scrapling against privacy-preserving public search engines (DuckDuckGo / SearXNG) or extensible API connectors.
2. **OpenStreetMap Maps Ingestion**:
   - Queries the Overpass API with bounding boxes for target areas (Tripura / North East / India):
     - Tags: `amenity=school`, `amenity=college`, `amenity=kindergarten`, `building=university`.
   - Yields exact coordinates (`lat`, `lon`), official names, address tags, and websites without external API cost.
3. **Directory Scrapers**:
   - Ingests public state education boards (e.g. TBSE, CBSE state affiliations, directorate portals) to pull authoritative school and college websites.

### 4.2. URL Frontier (`discovery/frontier/frontier.py`)
Maintains queue integrity, politeness, and rate limits:
- **Canonical Normalization**: Strips URL parameters (`utm_*`, `fbclid`, session tokens), standardizes schemes to lowercase, removes trailing slashes.
- **Deduplication**: Hash-based check against `url_frontier` and `raw_snapshots`.
- **Domain Politeness**:
  - Minimum delay between requests to the same registrable domain (default: 3.0s).
  - Maximum 1 concurrent worker per domain.
- **Priority Rules**:
  - Priority 10: Official government / board education portals.
  - Priority 8: Curated directory sources.
  - Priority 5: Discovered institution domains from search/maps.
- **State Machine**: `queued` $\rightarrow$ `in_progress` $\rightarrow$ `completed` | `failed` (max 3 retries with backoff: 2h, 8h, 24h).

### 4.3. Source Router (`discovery/fetcher/router.py`)
Directs URLs to the most efficient fetcher:
- **Scrapling HTTP Fetcher (Primary, ~85%)**:
  - High-concurrency async HTTP using realistic browser headers, TLS fingerprinting, and automatic compression handling.
- **Headless Browser Fetcher (Secondary, ~15%)**:
  - Uses Scrapling Playwright/stealth browser.
  - Automatically triggered if:
    1. Domain matches known SPA/JavaScript directory list.
    2. HTTP fetch returns empty DOM body or anti-bot challenge (HTTP 403/503).
- **Raw Snapshot Store**:
  - Saves full HTML payload, status code, headers, and fetch timestamp to `raw_snapshots` collection with SHA-256 ID.
  - Allows offline parser reprocessing without re-crawling remote sites.

### 4.4. Two-Tier Parser (`discovery/parsers/`)

#### Tier 1: Deterministic Parser (`deterministic.py`)
- Evaluates raw snapshot HTML:
  - **Schema.org JSON-LD**: Extracts `@type` matching `School`, `EducationalOrganization`, `CollegeOrUniversity`.
  - **Microdata & OpenGraph**: Extracts `og:title`, `og:description`, `og:phone_number`, etc.
  - **DOM Contact Extraction**: Fast CSS/regex extraction of `tel:`, `mailto:`, address blocks, and contact pages.
- **Confidence Scoring ($0.0 - 1.0$)**:
  - Name found & non-generic: $+0.35$
  - Valid educational entity type: $+0.20$
  - Verified contact (phone or email): $+0.25$
  - Address / Locality identified: $+0.15$
  - Rich metadata (courses, board, timings): $+0.05$
- **Routing Gate**:
  - If Confidence $\ge 0.70$: Directly outputs structured data.
  - If Confidence $< 0.70$: Forwards snapshot to Tier 2.

#### Tier 2: LLM Fallback Parser (`llm_fallback.py`)
- **Boilerplate Stripping**: Uses **Trafilatura / Crawl4AI** to convert messy HTML into clean, dense Markdown (stripping navs, footers, scripts, ads).
- **Structured Extraction via Instructor**:
  - Connects to OpenAI-compatible endpoint (defaults to `gpt-4o-mini`, compatible with Gemini or Groq).
  - Enforces the schema below with Pydantic validation:

```python
class GeoCoordinates(BaseModel):
    latitude: float | None = Field(default=None, ge=-90.0, le=90.0)
    longitude: float | None = Field(default=None, ge=-180.0, le=180.0)
    geo_source: Literal["openstreetmap", "google_maps", "schema_org", "inferred", None] = None

class GeoLocalHierarchy(BaseModel):
    locality: str | None = Field(default=None, description="e.g. Banamalipur, Dhaleswar, Ramnagar")
    landmark: str | None = Field(default=None, description="e.g. Near Circuit House, Opp. City Centre")
    ward_or_zone: str | None = Field(default=None, description="Municipal ward or revenue block")
    city: str | None = Field(default="Agartala")
    district: str | None = Field(default="West Tripura")
    state: str | None = Field(default="Tripura")
    pincode: str | None = Field(default=None, pattern=r"^\d{6}$")

class EducationalCategories(BaseModel):
    primary_category: Literal[
        "k12_school", 
        "higher_education_college", 
        "coaching_competitive_exams", 
        "private_tutor_or_academy", 
        "preschool_daycare", 
        "vocational_skill_institute",
        "special_education"
    ]
    sub_categories: list[str] = Field(default_factory=list)
    education_levels: list[Literal[
        "pre_primary", "primary", "middle_school", "secondary_10th", 
        "higher_secondary_12th", "diploma", "undergraduate", "postgraduate"
    ]] = Field(default_factory=list)
    curriculum_boards: list[str] = Field(default_factory=list)
    medium_of_instruction: list[str] = Field(default_factory=list)

class InstructorEducationPayload(BaseModel):
    name: str
    entity_type: str
    categories: EducationalCategories
    geo_local: GeoLocalHierarchy
    coordinates: GeoCoordinates | None = None
    phones: list[str] = Field(default_factory=list)
    emails: list[str] = Field(default_factory=list)
    website: str | None = None
    full_address: str | None = None
    courses_offered: list[str] = Field(default_factory=list)
    social_links: list[str] = Field(default_factory=list)
    confidence_assessment: float = Field(ge=0.0, le=1.0)
```

### 4.5. Normalizer & Deduplicator (`discovery/normalization/` & `discovery/resolution/`)

#### Normalizer (`normalizer.py`)
- **Phones**: Formatted to E.164 via `phonenumbers` (default region `IN`). Tagged as `mobile` or `fixed_line`.
- **Domains**: Registrable domains extracted via `tldextract`.
- **Addresses & Text**: Cleaned with `unidecode`, standard abbreviations normalized, 6-digit Indian PIN verified.

#### Deduplicator (`deduplicator.py`)
- **Exact Matches**: Instant lookup against indexed exact phone, registrable domain, or provider external ID.
- **Fuzzy Matching (`RapidFuzz`)**:
  - Blocks candidates by `(geo_local.city, categories.primary_category)`.
  - Computes `token_sort_ratio` on normalized institution names.
  - Rules:
    - **$\ge 95\%$ similarity** + matching locality/city $\rightarrow$ **Auto-merge** into existing canonical entity.
    - **$80\% - 94\%$ similarity** OR conflicting contact signals $\rightarrow$ Route to **`duplicate_candidates`** collection for manual review in the Next.js Console.
    - **$< 80\%$ similarity** $\rightarrow$ Create new record in `education_entities`.
- **Provenance & Trust**: Leaf-field provenance preserved; verified or user-claimed records are immutable against lower-trust scraped updates.

### 4.6. Lead Scoring Engine (`discovery/scoring/lead_scorer.py`)
Computes a composite Lead Score ($0 - 100$):

$$\text{Lead Score} = \text{Completeness} (40\%) + \text{Contactability} (30\%) + \text{Freshness} (20\%) + \text{Credibility} (10\%)$$

- **Data Completeness (40 pts)**:
  - Lat/Long coordinates present: $+10$
  - Detailed address with Locality & PIN: $+10$
  - Granular categories and boards populated: $+10$
  - Courses / Programs / Description populated: $+10$
- **Direct Contactability (30 pts)**:
  - Verified Mobile / WhatsApp: $+15$
  - Official Email: $+10$
  - Landline / Secondary phone: $+5$
- **Web & Social Freshness (20 pts)**:
  - Active, resolving official website: $+10$
  - Social media handles found: $+5$
  - Fresh observation / recent notice ($< 60$ days): $+5$
- **Institutional Credibility (10 pts)**:
  - Recognized Board / Affiliation (CBSE, ICSE, TBSE, UGC): $+5$
  - Cross-referenced in official state directory / Overpass: $+5$

**Classification Tiers**:
- **Tier 1 ($\ge 80$)**: Hot Lead (Featured ranking, priority outreach).
- **Tier 2 ($50 - 79$)**: Warm Lead (Good profile, candidate for automated enrichment).
- **Tier 3 ($< 50$)**: Cold Lead (Sparse record, queued for secondary crawls).

---

## 5. MongoDB Collections & Index Strategy

### Collections:
1. `url_frontier`: Crawl queue and rate-limiting states.
2. `raw_snapshots`: Full HTML snapshot payloads.
3. `source_observations`: Extracted observations before canonical resolution.
4. `education_entities`: Canonical entity ground truth with leaf provenance.
5. `discovery_profiles`: Denormalized read collection projected for Next.js Console & Search.
6. `duplicate_candidates`: Ambiguous merge pairs parked for admin review.
7. `discovery_runs`: Execution logs, metrics, duration, error counts.

### Key Indexes:
- `url_frontier`: `[("status", 1), ("priority", -1), ("nextFetchAt", 1)]`, unique `[("urlHash", 1)]`, `[("domain", 1)]`.
- `raw_snapshots`: unique `[("_id", 1)]`, `[("url", 1)]`.
- `education_entities`: `2dsphere` on `coordinates`, index on `leadScore.totalScore` (desc), `[("geo_local.city", 1), ("categories.primary_category", 1)]`, `phones`, `domain`.
- `discovery_profiles`: `[("ranking.finalScore", -1), ("_id", 1)]`, `[("ai.needsEmbedding", 1)]`.

---

## 6. CLI Command Interface

All commands are run using `uv`:

```bash
# 1. Initialize MongoDB validators, collections, and indexes
uv run main.py init-db

# 2. Run Query Generator to seed URL Frontier
uv run main.py generate-queries --city "Agartala" --state "Tripura"

# 3. Crawl queued Frontier URLs (Scrapling HTTP / Browser) -> raw_snapshots
uv run main.py crawl-frontier --batch 100

# 4. Run Two-Tier Parser (Deterministic + Instructor LLM) -> source_observations
uv run main.py parse-snapshots --batch 100

# 5. Run Normalizer, Deduplicator (RapidFuzz), and Lead Scoring -> canonical & profiles
uv run main.py resolve-and-score --batch 100

# 6. Recompute vector embeddings for modified profiles
uv run main.py embed-profiles --batch 50

# 7. Run full end-to-end automated discovery loop (for scheduled batch/cron)
uv run main.py run-all --batch 200
```

---

## 7. Implementation Phasing

To ensure smooth delivery and early validation, implementation is divided into 3 milestones:

- **Phase 1: Core Async Engine & Two-Tier Parser**
  - Project setup with `uv`, `pyproject.toml`, and Pydantic v2 schemas.
  - Async MongoDB storage adapter (`motor`) with index configuration.
  - Source Router (Scrapling HTTP + Browser fetcher) and `raw_snapshots` store.
  - Two-Tier Parser: Deterministic parser with confidence scoring + Trafilatura + Instructor LLM fallback.
- **Phase 2: URL Frontier & Automated Query Generator**
  - OpenStreetMap (Overpass API) ingestion adapter.
  - Search query generator (DuckDuckGo / SearXNG / permitted directory adapters).
  - Frontier scheduler with domain politeness and priority queue.
- **Phase 3: Lead Scoring Engine, Deduplication & Console Integration**
  - Phone (E.164), domain, and address normalizer.
  - RapidFuzz candidate resolution & `duplicate_candidates` review queue.
  - Lead Scoring composite calculator.
  - End-to-end CLI orchestrator (`run-all`) and Next.js console data synchronization.
