# Alogyan Discovery Engine Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Redesign the Alogyan Discovery Engine into an automated, async, staged discovery and lead-scoring pipeline featuring dynamic query generation, a domain-polite URL frontier, dual-speed fetching, two-tier parsing (deterministic + Instructor LLM fallback), normalization, RapidFuzz deduplication, and multi-factor lead scoring for educational institutions.

**Architecture:** A modular async batch pipeline orchestrated by `asyncio` and `motor` (Async MongoDB). The pipeline generates candidate search queries and OSM Overpass maps data into an indexed URL frontier, routes fetches between Scrapling HTTP and headless browser, snapshots raw responses, evaluates deterministic metadata against a confidence threshold with Trafilatura + Instructor LLM fallback, normalizes and deduplicates canonical entities with review queues, and calculates multi-factor lead scores projected into `discovery_profiles`.

**Tech Stack:** Python 3.12+, uv, Scrapling, Trafilatura, Instructor, Motor (PyMongo Async), Pydantic v2, Pydantic-Settings, RapidFuzz, phonenumbers, tldextract, unidecode, httpx, tenacity, pytest, pytest-asyncio.

**Spec:** `docs/superpowers/specs/2026-09-11-discovery-engine-redesign.md`

## Global Constraints
- Python version floor: `>=3.12`.
- Package manager: `uv`.
- MongoDB driver: `motor>=3.7.0` (async).
- Raw observations and canonical entities remain strictly separated.
- Scraped data never overwrites verified or user-claimed records.
- Deterministic parser confidence gate threshold: $\ge 0.70$ for structured bypass, $< 0.70$ for Trafilatura + Instructor fallback.
- RapidFuzz candidate resolution thresholds: $\ge 95\%$ auto-merge, $80\% - 94\%$ route to `duplicate_candidates` review queue, $< 80\%$ create new canonical entity.
- Lead scoring weights: Completeness $40\%$, Contactability $30\%$, Freshness $20\%$, Credibility $10\%$.
- No external message broker or worker daemons (no Redis, Celery, or Kafka).

---

### Task 1: Environment & Project Scaffolding with `uv`

**Files:**
- Create: `pyproject.toml`
- Modify: `requirements.txt`
- Test: `tests/test_environment.py`

**Interfaces:**
- Produces: Validated `uv` virtual environment and dependency tree with pinned dependencies.

- [ ] **Step 1: Write the environment test**

```python
# tests/test_environment.py
import sys
import importlib

def test_python_version():
    assert sys.version_info >= (3, 12), "Python 3.12+ is required"

def test_critical_dependencies_importable():
    modules = [
        "pydantic", "pydantic_settings", "motor", "scrapling", 
        "trafilatura", "instructor", "rapidfuzz", "phonenumbers", 
        "tldextract", "unidecode", "httpx", "tenacity"
    ]
    for mod in modules:
        assert importlib.import_module(mod) is not None
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest tests/test_environment.py`
Expected: FAIL (missing dependencies or environment unconfigured)

- [ ] **Step 3: Create `pyproject.toml` and update `requirements.txt`**

```toml
# pyproject.toml
[project]
name = "alogyan-discovery-engine"
version = "2.0.0"
description = "Automated education discovery & lead intelligence engine"
requires-python = ">=3.12"
dependencies = [
    "scrapling[fetchers]>=0.4.15",
    "motor>=3.7.0",
    "pydantic>=2.10.0",
    "pydantic-settings>=2.7.0",
    "rapidfuzz>=3.14.6",
    "phonenumbers>=9.0.39",
    "tldextract>=5.3.2",
    "unidecode>=1.4.0",
    "trafilatura>=2.0.0",
    "beautifulsoup4>=4.13.0",
    "instructor>=1.7.0",
    "httpx>=0.28.1",
    "tenacity>=9.0.0",
    "python-dotenv>=1.2.3",
    "certifi>=2026.7.22",
]

[dependency-groups]
dev = [
    "pytest>=8.0.0",
    "pytest-asyncio>=0.24.0",
]
```

Update `requirements.txt`:
```text
scrapling[fetchers]>=0.4.15
motor>=3.7.0
pydantic>=2.10.0
pydantic-settings>=2.7.0
rapidfuzz>=3.14.6
phonenumbers>=9.0.39
tldextract>=5.3.2
unidecode>=1.4.0
trafilatura>=2.0.0
beautifulsoup4>=4.13.0
instructor>=1.7.0
httpx>=0.28.1
tenacity>=9.0.0
python-dotenv>=1.2.3
certifi>=2026.7.22
pytest>=8.0.0
pytest-asyncio>=0.24.0
```

- [ ] **Step 4: Sync environment with `uv` and run tests**

Run: `uv pip install -r requirements.txt && pytest tests/test_environment.py`
Expected: PASS

- [ ] **Step 5: Verify environment status**

Run: `uv run python -c "import motor, instructor, trafilatura, rapidfuzz; print('Dependencies OK')"`

---

### Task 2: Pydantic Domain Models with Geo-Local Hierarchy & Categories

**Files:**
- Modify: `discovery/models.py`
- Test: `tests/test_domain_models.py`

**Interfaces:**
- Consumes: Pydantic v2
- Produces: `GeoCoordinates`, `GeoLocalHierarchy`, `EducationalCategories`, `InstructorEducationPayload`, `FrontierItem`, `RawSnapshot`, `LeadScoreBreakdown`

- [ ] **Step 1: Write unit tests for domain models**

```python
# tests/test_domain_models.py
from datetime import datetime, timezone
import pytest
from discovery.models import (
    GeoCoordinates, GeoLocalHierarchy, EducationalCategories,
    InstructorEducationPayload, FrontierItem, RawSnapshot, LeadScoreBreakdown
)

def test_geo_local_hierarchy_validation():
    geo = GeoLocalHierarchy(
        locality="Banamalipur",
        landmark="Near Old Motor Stand",
        city="Agartala",
        state="Tripura",
        pincode="799001"
    )
    assert geo.city == "Agartala"
    assert geo.pincode == "799001"

def test_invalid_pincode_raises():
    with pytest.raises(ValueError):
        GeoLocalHierarchy(city="Agartala", pincode="1234")

def test_educational_categories():
    cat = EducationalCategories(
        primary_category="k12_school",
        sub_categories=["CBSE Secondary", "Science Stream"],
        curriculum_boards=["CBSE"]
    )
    assert cat.primary_category == "k12_school"
    assert "CBSE" in cat.curriculum_boards

def test_lead_score_breakdown():
    score = LeadScoreBreakdown(
        completeness_score=35.0,
        contactability_score=25.0,
        freshness_score=15.0,
        credibility_score=10.0,
        total_score=85.0,
        tier="tier_1_hot"
    )
    assert score.total_score == 85.0
    assert score.tier == "tier_1_hot"
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest tests/test_domain_models.py`
Expected: FAIL (types not yet defined in `discovery/models.py`)

- [ ] **Step 3: Implement schemas in `discovery/models.py`**

Add `GeoCoordinates`, `GeoLocalHierarchy`, `EducationalCategories`, `InstructorEducationPayload`, `FrontierItem`, `RawSnapshot`, `LeadScoreBreakdown` to `discovery/models.py`.

- [ ] **Step 4: Run test to verify it passes**

Run: `pytest tests/test_domain_models.py`
Expected: PASS

---

### Task 3: Async MongoDB Storage & Index Management (`motor`)

**Files:**
- Modify: `discovery/config.py`
- Modify: `discovery/indexes.py`
- Create: `discovery/storage/repository.py`
- Test: `tests/test_storage_indexes.py`

**Interfaces:**
- Consumes: `discovery/config.py`, `motor.motor_asyncio`
- Produces: `AsyncRepository`, `ensure_indexes_async(db)`

- [ ] **Step 1: Write storage and index test**

```python
# tests/test_storage_indexes.py
import pytest
from unittest.mock import AsyncMock, MagicMock
from discovery.storage.repository import AsyncRepository
from discovery.indexes import ensure_indexes_async

@pytest.mark.asyncio
async def test_ensure_indexes_creates_expected_collections():
    mock_db = MagicMock()
    mock_collection = MagicMock()
    mock_collection.create_index = AsyncMock()
    mock_db.__getitem__.return_value = mock_collection
    
    await ensure_indexes_async(mock_db)
    assert mock_collection.create_index.call_count >= 5
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest tests/test_storage_indexes.py`
Expected: FAIL

- [ ] **Step 3: Implement `ensure_indexes_async` and `AsyncRepository`**

Update `discovery/indexes.py` with async index definitions for `url_frontier`, `raw_snapshots`, `source_observations`, `education_entities`, `discovery_profiles`, and `duplicate_candidates`.
Implement `AsyncRepository` in `discovery/storage/repository.py`.

- [ ] **Step 4: Run test to verify it passes**

Run: `pytest tests/test_storage_indexes.py`
Expected: PASS

---

### Task 4: Source Router (Scrapling HTTP + Headless Browser) & Snapshot Store

**Files:**
- Create: `discovery/fetcher/router.py`
- Test: `tests/test_fetcher_router.py`

**Interfaces:**
- Consumes: `FrontierItem`, `scrapling`, `httpx`, `AsyncRepository`
- Produces: `SourceRouter.fetch(frontier_item) -> RawSnapshot`

- [ ] **Step 1: Write router test**

```python
# tests/test_fetcher_router.py
import pytest
from unittest.mock import AsyncMock, patch
from discovery.models import FrontierItem
from discovery.fetcher.router import SourceRouter

@pytest.mark.asyncio
async def test_router_selects_http_by_default():
    router = SourceRouter(user_agent="AlogyanTest/1.0", timeout=5)
    item = FrontierItem(
        url="https://example.edu.in",
        domain="example.edu.in",
        source_type="website"
    )
    with patch.object(router, "_fetch_http", new_callable=AsyncMock) as mock_http:
        mock_http.return_value = {"status_code": 200, "html": "<html><body>Hello</body></html>", "headers": {}}
        snapshot = await router.fetch(item)
        assert snapshot.fetched_via == "scrapling_http"
        assert snapshot.status_code == 200
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest tests/test_fetcher_router.py`
Expected: FAIL

- [ ] **Step 3: Implement `SourceRouter` in `discovery/fetcher/router.py`**

Implement `SourceRouter` with:
- `_fetch_http`: Uses Scrapling HTTP / `httpx.AsyncClient` with stealth headers.
- `_fetch_browser`: Uses Scrapling stealth browser fetcher.
- Fallback logic: Detect empty DOM or 403 challenge, switch to browser fetch.
- SHA-256 hash generation and `RawSnapshot` creation.

- [ ] **Step 4: Run test to verify it passes**

Run: `pytest tests/test_fetcher_router.py`
Expected: PASS

---

### Task 5: Two-Tier Parser — Deterministic Parser with Confidence Scoring

**Files:**
- Create: `discovery/parsers/deterministic.py`
- Test: `tests/test_deterministic_parser.py`

**Interfaces:**
- Consumes: `RawSnapshot` HTML
- Produces: `DeterministicParser.parse(html) -> tuple[ExtractedEducationPayload | None, float]`

- [ ] **Step 1: Write test for deterministic parser and confidence calculation**

```python
# tests/test_deterministic_parser.py
from discovery.parsers.deterministic import DeterministicParser

HTML_WITH_JSON_LD = """
<html>
<head>
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "School",
  "name": "Holy Cross School",
  "telephone": "+91 381 234 5678",
  "address": {
    "@type": "PostalAddress",
    "streetAddress": "Durjoynagar",
    "addressLocality": "Agartala",
    "addressRegion": "Tripura",
    "postalCode": "799009"
  }
}
</script>
</head>
<body><h1>Welcome to Holy Cross</h1></body>
</html>
"""

def test_deterministic_parser_high_confidence():
    parser = DeterministicParser()
    payload, confidence = parser.parse(HTML_WITH_JSON_LD)
    assert payload is not None
    assert payload.name == "Holy Cross School"
    assert confidence >= 0.70
    assert payload.geo_local.city == "Agartala"
    assert payload.geo_local.pincode == "799009"

def test_deterministic_parser_low_confidence_on_empty():
    parser = DeterministicParser()
    payload, confidence = parser.parse("<html><body><div>Random blog post</div></body></html>")
    assert confidence < 0.70
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest tests/test_deterministic_parser.py`
Expected: FAIL

- [ ] **Step 3: Implement `DeterministicParser` in `discovery/parsers/deterministic.py`**

Parse Schema.org JSON-LD, microdata, meta tags, and DOM anchors. Compute confidence score ($0.0 - 1.0$).

- [ ] **Step 4: Run test to verify it passes**

Run: `pytest tests/test_deterministic_parser.py`
Expected: PASS

---

### Task 6: Two-Tier Parser — Trafilatura Boilerplate Stripping & Instructor LLM Fallback

**Files:**
- Create: `discovery/parsers/llm_fallback.py`
- Test: `tests/test_llm_fallback_parser.py`

**Interfaces:**
- Consumes: `RawSnapshot` HTML, `instructor` client
- Produces: `LLMFallbackParser.parse(html) -> InstructorEducationPayload`

- [ ] **Step 1: Write test for Trafilatura cleaning and mocked Instructor extraction**

```python
# tests/test_llm_fallback_parser.py
import pytest
from unittest.mock import MagicMock
from discovery.parsers.llm_fallback import LLMFallbackParser
from discovery.models import InstructorEducationPayload, EducationalCategories, GeoLocalHierarchy

@pytest.mark.asyncio
async def test_trafilatura_strips_boilerplate_and_instructor_extracts():
    mock_instructor_client = MagicMock()
    mock_payload = InstructorEducationPayload(
        name="Netaji Subhash Academy",
        entity_type="school",
        categories=EducationalCategories(primary_category="k12_school"),
        geo_local=GeoLocalHierarchy(city="Agartala", state="Tripura"),
        phones=["+919862000000"],
        confidence_assessment=0.9
    )
    mock_instructor_client.chat.completions.create.return_value = mock_payload
    
    parser = LLMFallbackParser(client=mock_instructor_client, model="gpt-4o-mini")
    html = "<html><nav>Menu</nav><body><h1>Netaji Subhash Academy</h1><p>Call: 9862000000 in Agartala</p></body><footer>Footer</footer></html>"
    result = await parser.parse(html)
    assert result.name == "Netaji Subhash Academy"
    assert result.phones == ["+919862000000"]
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest tests/test_llm_fallback_parser.py`
Expected: FAIL

- [ ] **Step 3: Implement `LLMFallbackParser` in `discovery/parsers/llm_fallback.py`**

Uses `trafilatura.extract(html)` to clean text, truncates to 4,000 tokens, and calls `instructor` with `response_model=InstructorEducationPayload`.

- [ ] **Step 4: Run test to verify it passes**

Run: `pytest tests/test_llm_fallback_parser.py`
Expected: PASS

---

### Task 7: Query Generator (Search, Maps via Overpass OSM, Directories)

**Files:**
- Create: `discovery/frontier/query_generator.py`
- Test: `tests/test_query_generator.py`

**Interfaces:**
- Consumes: Target region & category list
- Produces: `list[FrontierItem]`

- [ ] **Step 1: Write test for query generator and Overpass query builder**

```python
# tests/test_query_generator.py
from discovery.frontier/query_generator import QueryGenerator

def test_query_generator_generates_search_matrices():
    gen = QueryGenerator()
    queries = gen.build_search_queries(city="Agartala", state="Tripura")
    assert len(queries) > 5
    assert any("schools in Agartala" in q for q in queries)
    assert any("coaching" in q for q in queries)

def test_build_overpass_osm_query():
    gen = QueryGenerator()
    osm_query = gen.build_osm_overpass_query(bbox=(23.8, 91.2, 23.9, 91.3))
    assert 'amenity"="school"' in osm_query
    assert 'out center;' in osm_query
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest tests/test_query_generator.py`
Expected: FAIL

- [ ] **Step 3: Implement `QueryGenerator` in `discovery/frontier/query_generator.py`**

- [ ] **Step 4: Run test to verify it passes**

Run: `pytest tests/test_query_generator.py`
Expected: PASS

---

### Task 8: URL Frontier & Politeness Scheduler

**Files:**
- Create: `discovery/frontier/frontier.py`
- Test: `tests/test_frontier_scheduler.py`

**Interfaces:**
- Consumes: `FrontierItem`, `AsyncRepository`
- Produces: `URLFrontier.pop_next_batch(limit) -> list[FrontierItem]`, `URLFrontier.enqueue(items)`

- [ ] **Step 1: Write test for frontier deduplication and domain delay**

```python
# tests/test_frontier_scheduler.py
import pytest
from discovery.models import FrontierItem
from discovery.frontier.frontier import URLFrontier

def test_frontier_canonical_url_deduplication():
    frontier = URLFrontier(crawl_delay=3.0)
    item1 = frontier.normalize_and_create("https://example.edu.in/?utm_source=google&ref=123", "search")
    item2 = frontier.normalize_and_create("https://example.edu.in/", "maps")
    assert item1.url_hash == item2.url_hash
    assert item1.domain == "example.edu.in"
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest tests/test_frontier_scheduler.py`
Expected: FAIL

- [ ] **Step 3: Implement `URLFrontier` in `discovery/frontier/frontier.py`**

- [ ] **Step 4: Run test to verify it passes**

Run: `pytest tests/test_frontier_scheduler.py`
Expected: PASS

---

### Task 9: Normalizer (Phones E.164, Domains, Addresses)

**Files:**
- Modify: `discovery/normalize.py` (or `discovery/normalization/normalizer.py`)
- Test: `tests/test_normalizer.py`

**Interfaces:**
- Consumes: Extracted raw phones, domains, addresses, and unicode text
- Produces: Normalized data structures

- [ ] **Step 1: Write normalization tests**

```python
# tests/test_normalizer.py
from discovery.normalize import normalize_phone_e164, normalize_domain, clean_text_unicode

def test_phone_normalization_indian_numbers():
    assert normalize_phone_e164("0381 234 5678", "IN") == "+913812345678"
    assert normalize_phone_e164("98620-12345", "IN") == "+919862012345"
    assert normalize_phone_e164("invalid", "IN") is None

def test_domain_normalization():
    assert normalize_domain("https://www.agartala-school.edu.in/about?ref=1") == "agartala-school.edu.in"

def test_clean_text_unicode():
    assert clean_text_unicode("St. Paul’s  Senior\u200b School") == "St. Paul's Senior School"
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest tests/test_normalizer.py`
Expected: FAIL

- [ ] **Step 3: Implement normalization functions in `discovery/normalize.py`**

- [ ] **Step 4: Run test to verify it passes**

Run: `pytest tests/test_normalizer.py`
Expected: PASS

---

### Task 10: Deduplicator & Entity Resolution (`RapidFuzz`)

**Files:**
- Modify: `discovery/resolution.py`
- Test: `tests/test_deduplicator.py`

**Interfaces:**
- Consumes: Normalized observation and existing candidates
- Produces: `MatchResult` (`AUTO_MERGE`, `REVIEW_QUEUE`, `CREATE_NEW`)

- [ ] **Step 1: Write deduplication and threshold tests**

```python
# tests/test_deduplicator.py
from discovery.resolution import resolve_entity_match

def test_exact_phone_match_auto_merges():
    candidate = {"_id": "ent_1", "phones": ["+919862012345"], "name": "Bhavan's Tripura"}
    observation = {"phones": ["+919862012345"], "name": "Bhavan's Tripura Vidya Mandir"}
    decision, matched_id = resolve_entity_match(observation, [candidate])
    assert decision == "auto_merge"
    assert matched_id == "ent_1"

def test_high_similarity_routes_to_review():
    candidate = {"_id": "ent_2", "phones": ["+919862099999"], "name": "St. Johns School"}
    observation = {"phones": ["+919862088888"], "name": "St. Johns Senior Secondary School"}
    decision, _ = resolve_entity_match(observation, [candidate])
    assert decision == "review_queue"
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest tests/test_deduplicator.py`
Expected: FAIL

- [ ] **Step 3: Implement `resolve_entity_match` in `discovery/resolution.py`**

- [ ] **Step 4: Run test to verify it passes**

Run: `pytest tests/test_deduplicator.py`
Expected: PASS

---

### Task 11: Lead Scoring Engine (Multi-Factor Composite Score)

**Files:**
- Create: `discovery/scoring/lead_scorer.py`
- Test: `tests/test_lead_scorer.py`

**Interfaces:**
- Consumes: Canonical entity document
- Produces: `LeadScoreBreakdown`

- [ ] **Step 1: Write lead scoring tests**

```python
# tests/test_lead_scorer.py
from discovery.scoring.lead_scorer import calculate_lead_score

def test_lead_score_calculation_hot_lead():
    entity = {
        "coordinates": {"latitude": 23.83, "longitude": 91.28},
        "geo_local": {"locality": "Banamalipur", "city": "Agartala", "pincode": "799001"},
        "categories": {"primary_category": "k12_school", "curriculum_boards": ["CBSE"]},
        "description": "Premier CBSE institution established in 1990",
        "phones": ["+919862012345"],
        "emails": ["info@school.edu.in"],
        "website": "https://school.edu.in",
        "social_links": ["https://facebook.com/school"],
        "observed_days_ago": 10,
        "is_directory_verified": True
    }
    score = calculate_lead_score(entity)
    assert score.total_score >= 80.0
    assert score.tier == "tier_1_hot"

def test_lead_score_cold_lead_on_sparse_data():
    sparse_entity = {
        "name": "Some Coaching Centre",
        "geo_local": {"city": "Agartala"}
    }
    score = calculate_lead_score(sparse_entity)
    assert score.total_score < 50.0
    assert score.tier == "tier_3_cold"
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest tests/test_lead_scorer.py`
Expected: FAIL

- [ ] **Step 3: Implement `calculate_lead_score` in `discovery/scoring/lead_scorer.py`**

- [ ] **Step 4: Run test to verify it passes**

Run: `pytest tests/test_lead_scorer.py`
Expected: PASS

---

### Task 12: Unified CLI Runner (`main.py`) & End-to-End Orchestrator

**Files:**
- Modify: `main.py`
- Modify: `discovery/pipeline.py`
- Test: `tests/test_cli_commands.py`

**Interfaces:**
- Consumes: All stages (`query_generator`, `router`, `parsers`, `normalizer`, `deduplicator`, `lead_scorer`, `repository`)
- Produces: CLI commands (`init-db`, `generate-queries`, `crawl-frontier`, `parse-snapshots`, `resolve-and-score`, `run-all`)

- [ ] **Step 1: Write CLI command tests**

```python
# tests/test_cli_commands.py
import pytest
from unittest.mock import AsyncMock, patch
from main import build_parser

def test_cli_parser_commands():
    parser = build_parser()
    assert "init-db" in parser._subparsers._actions[1].choices
    assert "generate-queries" in parser._subparsers._actions[1].choices
    assert "crawl-frontier" in parser._subparsers._actions[1].choices
    assert "parse-snapshots" in parser._subparsers._actions[1].choices
    assert "resolve-and-score" in parser._subparsers._actions[1].choices
    assert "run-all" in parser._subparsers._actions[1].choices
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest tests/test_cli_commands.py`
Expected: FAIL

- [ ] **Step 3: Implement async pipeline orchestrator and CLI in `main.py` & `discovery/pipeline.py`**

- [ ] **Step 4: Run test to verify it passes**

Run: `pytest tests/test_cli_commands.py`
Expected: PASS

- [ ] **Step 5: Run full test suite**

Run: `uv run pytest -v`
Expected: ALL PASS
