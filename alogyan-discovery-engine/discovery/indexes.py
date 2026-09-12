"""Ordinary MongoDB indexes. Atlas Search definitions are deployed separately."""
from pymongo import ASCENDING as A, DESCENDING as D, IndexModel
from .schema import VALIDATORS

INDEXES = {
    'discovery_runs': [IndexModel([('startedAt', D)])],
    'crawl_sources': [IndexModel([('enabled', A), ('nextCrawlAt', A)])],
    'url_frontier': [
        IndexModel([('status', A), ('priority', D), ('next_fetch_at', A)]),
        IndexModel([('domain', A)]),
        IndexModel([('url', A)])
    ],
    'raw_snapshots': [
        IndexModel([('url', A)]),
        IndexModel([('fetched_at', D)])
    ],
    'source_observations': [
        IndexModel([('sourceKey', A), ('fingerprints.content', A)], unique=True),
        IndexModel([('source.provider', A), ('source.externalId', A)]),
        IndexModel([('source.url', A), ('fingerprints.content', A)]),
        IndexModel([('processing.status', A), ('observedAt', A)]), 
        IndexModel([('runId', A)])
    ],
    'education_entities': [
        IndexModel([('slug', A)], unique=True),
        *(IndexModel([(f'normalized.{field}', A)]) for field in ('phones', 'domains', 'emails')),
        IndexModel([('entityType', A), ('location.cityKey', A), ('normalizedName', A)]),
        IndexModel([('geo_local.city', A), ('categories.primary_category', A)]),
        IndexModel([('leadScore.total_score', D)]),
        IndexModel([('needsProjection', A)]), 
        IndexModel([('location.geo', '2dsphere')])
    ],
    'entity_sources': [IndexModel([('canonicalId', A)])],
    'duplicate_candidates': [IndexModel([('status', A), ('createdAt', A)])],
    'entity_merge_history': [IndexModel([('canonicalId', A), ('createdAt', D)])],
    'discovery_profiles': [
        IndexModel([('canonicalId', A)], unique=True),
        IndexModel([('slug', A)], unique=True),
        IndexModel([('entityType', A), ('location.cityKey', A), ('ranking.finalScore', D), ('_id', A)],
                   partialFilterExpression={'status': 'active'}),
        IndexModel([('entityType', A), ('location.cityKey', A), ('taxonomy.subjects', A),
                    ('ranking.finalScore', D), ('_id', A)], partialFilterExpression={'status': 'active'}),
        IndexModel([('leadScore.total_score', D)]),
        IndexModel([('location.geo', '2dsphere')]), 
        IndexModel([('ai.needsEmbedding', A)])
    ],
    'taxonomy': [IndexModel([('kind', A), ('key', A)], unique=True)],
}


def ensure_indexes(db):
    existing = set(db.list_collection_names())
    for collection, indexes in INDEXES.items():
        validator = VALIDATORS.get(collection)
        if collection not in existing:
            db.create_collection(collection, **({'validator': validator} if validator else {}))
        elif validator:
            db.command('collMod', collection, validator=validator, validationLevel='strict')
        db[collection].create_indexes(indexes)


async def ensure_indexes_async(db):
    existing = set(await db.list_collection_names())
    for collection, indexes in INDEXES.items():
        validator = VALIDATORS.get(collection)
        if collection not in existing:
            await db.create_collection(collection, **({'validator': validator} if validator else {}))
        elif validator:
            try:
                await db.command('collMod', collection, validator=validator, validationLevel='strict')
            except Exception:
                pass  # CollMod on existing collections if permissions or format differs
        await db[collection].create_indexes(indexes)
