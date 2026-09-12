"""Restartable async batch stages for Alogyan Discovery Engine."""
import asyncio
from datetime import datetime, timedelta
from uuid import uuid4
import tldextract
from .models import FrontierItem, RawSnapshot, utcnow, CrawlSource
from .embeddings import embed_profile
from .frontier.query_generator import QueryGenerator
from .frontier.frontier import URLFrontier
from .fetcher.router import SourceRouter
from .parsers.deterministic import DeterministicParser
from .parsers.llm_fallback import LLMFallbackParser
from .resolution import resolve_entity_match
from .scoring.lead_scorer import calculate_lead_score
from .normalize import phone, domain, clean_text_unicode


async def run_generate_queries_stage(repository, city: str = "Agartala", state: str = "Tripura") -> dict:
    gen = QueryGenerator()
    frontier = URLFrontier(repository=repository)
    seeds = gen.build_directory_seeds(city=city, state=state)
    queries = gen.build_search_queries(city=city, state=state)

    enqueued = 0
    # Enqueue official directory seeds
    for item in seeds:
        if await repository.enqueue_frontier_item(item):
            enqueued += 1

    # Enqueue search query placeholder targets or search scrapers
    for q in queries[:10]:
        item = frontier.create_item(
            url=f"https://duckduckgo.com/html/?q={q.replace(' ', '+')}",
            source_type="search",
            query_origin=q,
            priority=5
        )
        if await repository.enqueue_frontier_item(item):
            enqueued += 1

    return {"status": "completed", "queriesGenerated": len(queries), "frontierItemsEnqueued": enqueued}


async def run_crawl_frontier_stage(repository, router: SourceRouter, batch_limit: int = 50, run_id: str = "") -> dict:
    frontier = URLFrontier(repository=repository)
    items = await repository.fetch_next_frontier_batch(limit=batch_limit)
    polite_items = frontier.filter_domain_polite(items)

    crawled, failed = 0, 0
    for item in polite_items:
        try:
            snapshot = await router.fetch(item, run_id=run_id)
            await repository.save_snapshot(
                url=snapshot.url,
                status_code=snapshot.status_code,
                html=snapshot.html,
                fetched_via=snapshot.fetched_via,
                headers=snapshot.headers,
                run_id=run_id
            )
            await repository.update_frontier_status(
                item_id=item.id,
                status="completed" if snapshot.status_code < 400 else "failed",
                attempts=item.attempts + 1
            )
            crawled += 1
        except Exception as exc:
            failed += 1
            await repository.update_frontier_status(
                item_id=item.id,
                status="failed",
                attempts=item.attempts + 1,
                last_error=type(exc).__name__,
                next_fetch_at=utcnow() + timedelta(hours=2)
            )

    return {"crawled": crawled, "failed": failed}


async def run_parse_snapshots_stage(repository, batch_limit: int = 50, run_id: str = "", llm_key: str = "") -> dict:
    det_parser = DeterministicParser()
    llm_parser = LLMFallbackParser(api_key=llm_key) if llm_key else None

    cursor = repository.db.raw_snapshots.find(
        {"parsed": {"$ne": True}}
    ).sort("fetched_at", -1).limit(batch_limit)

    parsed, deterministic_count, llm_count = 0, 0, 0
    async for snap in cursor:
        url = snap.get("url", "")
        html = snap.get("html", "")
        payload, conf = det_parser.parse(html, url=url)

        parser_type = "deterministic"
        if conf < 0.70 and llm_parser:
            try:
                payload = await llm_parser.parse(html, url=url)
                parser_type = "instructor_llm"
                llm_count += 1
            except Exception:
                pass
        elif payload:
            deterministic_count += 1

        if payload:
            obs_doc = {
                "name": payload.name,
                "url": url,
                "domain": domain(url),
                "phones": [p for p in payload.phones if phone(p)],
                "emails": payload.emails,
                "geo_local": payload.geo_local.model_dump(),
                "coordinates": payload.coordinates.model_dump() if payload.coordinates else None,
                "categories": payload.categories.model_dump(),
                "description": payload.full_address or "",
                "courses_offered": payload.courses_offered,
                "social_links": payload.social_links,
                "parserType": parser_type,
                "parserConfidence": conf,
                "sourceSnapshotId": snap.get("_id")
            }
            await repository.save_observation(obs_doc, run_id=run_id)
            parsed += 1

        await repository.db.raw_snapshots.update_one(
            {"_id": snap["_id"]},
            {"$set": {"parsed": True, "parsedAt": utcnow()}}
        )

    return {"snapshotsProcessed": parsed, "deterministic": deterministic_count, "llmFallback": llm_count}


async def run_resolve_and_score_stage(repository, batch_limit: int = 50) -> dict:
    observations = await repository.fetch_pending_observations(limit=batch_limit)
    created, merged, review = 0, 0, 0

    for raw_obs in observations:
        obs_id = raw_obs["_id"]
        obs = {**raw_obs, **raw_obs.get("payload", {})}
        city = obs.get("geo_local", {}).get("city", "Agartala")
        
        # Candidate lookup by city
        cursor = repository.db.education_entities.find(
            {"geo_local.city": city}
        ).limit(40)
        candidates = [c async for c in cursor]

        decision, matched_id = resolve_entity_match(obs, candidates)

        if decision == "auto_merge" and matched_id:
            score = calculate_lead_score(obs)
            await repository.db.education_entities.update_one(
                {"_id": matched_id},
                {
                    "$set": {
                        "updatedAt": utcnow(),
                        "leadScore": score.model_dump()
                    },
                    "$addToSet": {
                        "phones": {"$each": obs.get("phones", [])},
                        "emails": {"$each": obs.get("emails", [])}
                    }
                }
            )
            # Sync to discovery_profiles
            await repository.db.discovery_profiles.update_one(
                {"canonicalId": matched_id},
                {"$set": {"leadScore": score.model_dump(), "updatedAt": utcnow()}},
                upsert=True
            )
            merged += 1
        elif decision == "review_queue":
            await repository.db.duplicate_candidates.insert_one({
                "observationId": obs_id,
                "observationName": obs.get("name"),
                "status": "pending_review",
                "createdAt": utcnow()
            })
            review += 1
        else:
            # create_new
            score = calculate_lead_score(obs)
            import hashlib
            new_id = hashlib.sha256(f"{obs.get('name')}|{city}|{utcnow().isoformat()}".encode()).hexdigest()[:24]
            from .normalize import name_key
            norm_name = name_key(obs.get("name", ""))
            slug = f"{norm_name.replace(' ', '-')[:40]}-{new_id[:6]}"
            location = {
                "city": obs.get("geo_local", {}).get("city", "Agartala"),
                "locality": obs.get("geo_local", {}).get("locality", ""),
                "state": obs.get("geo_local", {}).get("state", "Tripura"),
                "postalCode": obs.get("geo_local", {}).get("pincode", ""),
                "country": "IN",
                "cityKey": name_key(obs.get("geo_local", {}).get("city", "Agartala"))
            }
            taxonomy = {
                "subjects": obs.get("courses_offered", []),
                "classes": [],
                "boards": obs.get("categories", {}).get("curriculum_boards", [])
            }
            normalized = {
                "phones": obs.get("phones", []),
                "emails": obs.get("emails", []),
                "domains": [obs.get("domain")] if obs.get("domain") else []
            }
            entity_doc = {
                "_id": new_id,
                "canonicalId": new_id,
                "name": clean_text_unicode(obs.get("name", "")),
                "normalizedName": norm_name,
                "slug": slug,
                "entityType": "private_school",
                "location": location,
                "taxonomy": taxonomy,
                "normalized": normalized,
                "revision": 1,
                "status": "active",
                "phones": obs.get("phones", []),
                "emails": obs.get("emails", []),
                "domain": obs.get("domain"),
                "website": obs.get("url"),
                "geo_local": obs.get("geo_local", {}),
                "coordinates": obs.get("coordinates"),
                "categories": obs.get("categories", {}),
                "leadScore": score.model_dump(),
                "createdAt": utcnow(),
                "updatedAt": utcnow()
            }
            await repository.db.education_entities.insert_one(entity_doc)

            # Profile creation matching discovery_profiles validator
            semantic_text = f"{entity_doc['name']} {location['city']} {taxonomy['boards']}"
            semantic_hash = hashlib.sha256(semantic_text.encode()).hexdigest()
            await repository.db.discovery_profiles.insert_one({
                "_id": new_id,
                "canonicalId": new_id,
                "slug": slug,
                "name": entity_doc["name"],
                "entityType": entity_doc["entityType"],
                "status": "active",
                "location": location,
                "taxonomy": taxonomy,
                "leadScore": score.model_dump(),
                "ai": {
                    "semanticHash": semantic_hash,
                    "semanticText": semantic_text,
                    "needsEmbedding": True
                }
            })
            created += 1

        # Mark observation processed
        await repository.db.source_observations.update_one(
            {"_id": obs_id},
            {"$set": {"processing.status": "resolved", "processedAt": utcnow()}}
        )

    return {"created": created, "merged": merged, "review": review}


async def run_full_pipeline_async(repository, router: SourceRouter, batch_limit: int = 50, llm_key: str = "", city: str = "Agartala", state: str = "Tripura") -> dict:
    run_id = uuid4().hex
    started = utcnow()
    await repository.db.discovery_runs.insert_one({"_id": run_id, "startedAt": started, "status": "running"})

    try:
        gen_stats = await run_generate_queries_stage(repository, city=city, state=state)
        crawl_stats = await run_crawl_frontier_stage(repository, router, batch_limit=batch_limit, run_id=run_id)
        parse_stats = await run_parse_snapshots_stage(repository, batch_limit=batch_limit, run_id=run_id, llm_key=llm_key)
        resolve_stats = await run_resolve_and_score_stage(repository, batch_limit=batch_limit)

        summary = {
            "runId": run_id,
            "status": "completed",
            "generation": gen_stats,
            "crawling": crawl_stats,
            "parsing": parse_stats,
            "resolution": resolve_stats
        }
        await repository.db.discovery_runs.update_one(
            {"_id": run_id},
            {
                "$set": {
                    "status": "completed",
                    "completedAt": utcnow(),
                    "durationSeconds": (utcnow() - started).total_seconds(),
                    "statistics": summary
                }
            }
        )
        return summary
    except Exception as exc:
        await repository.db.discovery_runs.update_one(
            {"_id": run_id},
            {"$set": {"status": "failed", "lastError": str(exc), "completedAt": utcnow()}}
        )
        raise


def weekly(repository, adapter, limit: int = 500, embedder=None) -> dict:
    """Synchronous weekly runner preserved for backward compatibility."""
    db = repository.db
    run_id, started = uuid4().hex, utcnow()
    stats = dict(observations=0, pagesCrawled=0, created=0, matched=0, review=0,
                 skipped=0, projected=0, embeddings=0, errors=0)
    db.discovery_runs.insert_one({'_id': run_id, 'startedAt': started, 'status': 'running'})
    status = 'failed'
    try:
        due = db.crawl_sources.find({'enabled': True, 'authorized': True,
                                    'nextCrawlAt': {'$lte': started}}).sort('nextCrawlAt', 1).limit(limit)
        for record in due:
            source = CrawlSource.model_validate({key: record[key] for key in CrawlSource.model_fields if key in record})
            try:
                observations = adapter.discover(source)
                stats['observations'] += repository.ingest(observations, run_id)
                stats['pagesCrawled'] += 1
                db.crawl_sources.update_one({'_id': record['_id']}, {'$set': {
                    'nextCrawlAt': utcnow() + timedelta(days=source.intervalDays),
                    'lastRunId': run_id, 'failures': 0}, '$unset': {'lastError': ''}})
            except Exception as exc:
                stats['errors'] += 1
                failures = record.get('failures', 0) + 1
                db.crawl_sources.update_one({'_id': record['_id']}, {'$set': {
                    'failures': failures, 'enabled': failures < 3,
                    'lastError': type(exc).__name__, 'lastRunId': run_id,
                    'nextCrawlAt': utcnow() + timedelta(days=min(7, 2 ** failures))}})
        for observation in repository.pending(limit):
            try:
                stats[repository.resolve(observation['_id'])] += 1
            except Exception as exc:
                stats['errors'] += 1
                repository.record_failure(observation['_id'], exc)
        for entity in db.education_entities.find({'needsProjection': True}).limit(limit):
            try:
                repository.project_entity(entity['_id'])
                stats['projected'] += 1
            except Exception as exc:
                stats['errors'] += 1
                db.education_entities.update_one({'_id': entity['_id']},
                    {'$set': {'projectionError': type(exc).__name__}})
        if embedder:
            for profile in db.discovery_profiles.find({'status': 'active', 'ai.needsEmbedding': True,
                        'ai.attempts': {'$not': {'$gte': 3}}}).limit(limit):
                try:
                    stats['embeddings'] += int(embed_profile(db.discovery_profiles, profile, embedder))
                except Exception as exc:
                    stats['errors'] += 1
                    db.discovery_profiles.update_one({'_id': profile['_id'],
                        'ai.semanticHash': profile['ai']['semanticHash']},
                        {'$set': {'ai.error': type(exc).__name__}, '$inc': {'ai.attempts': 1}})
        status = 'completed' if not stats['errors'] else 'completed_with_errors'
        return {'runId': run_id, 'status': status, **stats}
    finally:
        finished = utcnow()
        db.discovery_runs.update_one({'_id': run_id}, {'$set': {
            'status': status, 'completedAt': finished,
            'durationSeconds': (finished - started).total_seconds(), 'statistics': stats}})

