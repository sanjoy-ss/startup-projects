"""MongoDB I/O and atomic resolution. Atlas replica-set transactions are required."""
from copy import deepcopy
from pymongo import UpdateOne
from pymongo.read_concern import ReadConcern
from pymongo.write_concern import WriteConcern
from .models import Observation, utcnow
from .normalize import canonical_fields, digest, name_key, observation_document
from .projector import project
from .resolution import decide

CANDIDATE_LIMIT = 40
MAX_ATTEMPTS = 3


def merge_fields(existing: dict | None, fields: dict, observation: dict) -> dict:
    """Preserve claimed/verified records and stronger or newer field evidence."""
    entity = deepcopy(existing if existing is not None else fields)
    entity.setdefault('provenance', {})
    locked = set(entity.get('lockedFields', []))
    if entity.get('claimed') or entity.get('verified'):
        return entity

    def apply(target, values, prefix=''):
        for key, value in values.items():
            path = f'{prefix}.{key}' if prefix else key
            if path in locked or path.split('.')[0] in locked:
                continue
            if isinstance(value, dict):
                apply(target.setdefault(key, {}), value, path)
                continue
            if not value:
                continue  # Missing evidence cannot erase existing values.
            provenance_key = path.replace('.', '__')
            prior = entity['provenance'].get(provenance_key, {})
            trust = observation['payload']['trust']
            if prior.get('trust', -1) > trust:
                continue
            if (prior.get('trust', -1) == trust and
                    prior.get('observedAt', observation['observedAt']) > observation['observedAt']):
                continue
            target[key] = value
            entity['provenance'][provenance_key] = {
                'observationId': observation['_id'], 'trust': trust,
                'observedAt': observation['observedAt']}
    apply(entity, fields)
    return entity


class Repository:
    def __init__(self, db):
        self.db = db

    def ingest(self, observations: list[Observation], run_id: str) -> int:
        now = utcnow()
        operations = []
        for obs in observations:
            doc = observation_document(obs, run_id, now)
            doc.pop('lastSeenAt')
            operations.append(UpdateOne({'_id': doc['_id']},
                {'$setOnInsert': doc, '$set': {'lastSeenAt': now}}, upsert=True))
        if not operations:
            return 0
        return self.db.source_observations.bulk_write(operations, ordered=False).upserted_count

    def candidates(self, fields, session):
        clauses = [{f'normalized.{key}': {'$in': values}}
                   for key, values in fields['normalized'].items() if values]
        city = fields['location']['cityKey']
        if city:
            clauses.append({'entityType': fields['entityType'], 'location.cityKey': city,
                            'normalizedName': fields['normalizedName']})
        candidates = list(self.db.education_entities.find(
            {'$or': clauses, 'status': 'active'}, session=session).limit(CANDIDATE_LIMIT + 1)) if clauses else []
        # Only after exact lookups: bounded lexical block over the same compound index.
        # Never perform collection-wide fuzzy/AI scans.
        if not candidates and city and fields['normalizedName']:
            import re
            prefix = re.escape(fields['normalizedName'].split()[0])
            candidates = list(self.db.education_entities.find({
                'entityType': fields['entityType'], 'location.cityKey': city, 'status': 'active',
                'normalizedName': {'$regex': '^' + prefix + r'(?: |$)'}}, session=session)
                .limit(CANDIDATE_LIMIT + 1))
        return candidates[:CANDIDATE_LIMIT], len(candidates) > CANDIDATE_LIMIT

    def resolve(self, observation_id: str) -> str:
        def operation(session):
            doc = self.db.source_observations.find_one({'_id': observation_id}, session=session)
            if doc['processing']['status'] not in ('pending', 'failed'):
                return 'skipped'
            fields = canonical_fields(Observation.model_validate(doc['payload']))
            if not fields['normalizedName']:
                raise ValueError('Name has no meaningful characters')
            mapping = self.db.entity_sources.find_one({'_id': doc['sourceKey']}, session=session)
            candidates, saturated = ([], False) if mapping else self.candidates(fields, session)
            decision = decide(fields, candidates, mapping['canonicalId'] if mapping else None, saturated)
            now = utcnow()
            if decision.action == 'review':
                self.db.duplicate_candidates.update_one({'_id': doc['_id']}, {'$setOnInsert': {
                    'observationId': doc['_id'], 'candidateIds': list(decision.candidates),
                    'reason': decision.reason, 'status': 'pending', 'createdAt': now}}, upsert=True, session=session)
                self.db.source_observations.update_one({'_id': doc['_id']},
                    {'$set': {'processing.status': 'review', 'processing.completedAt': now}}, session=session)
                return 'review'
            canonical_id = decision.canonicalId or digest(['entity', doc['sourceKey']])
            existing = self.db.education_entities.find_one({'_id': canonical_id}, session=session)
            if mapping and not existing:
                raise ValueError('Source mapping references a missing entity')
            entity = merge_fields(existing, fields, doc)
            entity.setdefault('slug', (name_key(fields['name']).replace(' ', '-') or 'education') + '-' + canonical_id[:12])
            if existing and existing.get('name') != entity.get('name'):
                entity['aliases'] = sorted(set(existing.get('aliases', []) + [existing['name']]))[:20]
            entity.setdefault('status', 'active')
            entity.setdefault('createdAt', now)
            entity.update(updatedAt=now, needsProjection=True, revision=(existing or {}).get('revision', 0) + 1)
            entity.pop('_id', None)
            self.db.education_entities.update_one({'_id': canonical_id}, {'$set': entity}, upsert=True, session=session)
            self.db.entity_sources.update_one({'_id': doc['sourceKey']}, {'$set': {
                'canonicalId': canonical_id, 'latestObservationId': doc['_id'], 'updatedAt': now},
                '$setOnInsert': {'source': doc['source'], 'createdAt': now}}, upsert=True, session=session)
            # Per-observation before image makes each canonical change auditable/reversible.
            self.db.entity_merge_history.update_one({'_id': doc['_id']}, {'$setOnInsert': {
                'canonicalId': canonical_id, 'observationId': doc['_id'], 'before': existing,
                'afterRevision': entity['revision'], 'reason': decision.reason, 'createdAt': now}},
                upsert=True, session=session)
            self.db.source_observations.update_one({'_id': doc['_id']}, {'$set': {
                'processing.status': 'resolved', 'processing.canonicalId': canonical_id,
                'processing.completedAt': now}}, session=session)
            return 'created' if existing is None else 'matched'
        with self.db.client.start_session() as session:
            return session.with_transaction(operation, read_concern=ReadConcern('snapshot'),
                                            write_concern=WriteConcern('majority'))

    def project_entity(self, canonical_id: str):
        def operation(session):
            entity = self.db.education_entities.find_one({'_id': canonical_id}, session=session)
            profile = project(entity, utcnow())
            old = self.db.discovery_profiles.find_one({'canonicalId': canonical_id}, session=session)
            ai = profile.pop('ai')
            changed = not old or old['ai']['semanticHash'] != ai['semanticHash']
            update = {'$set': profile | {f'ai.{k}': v for k, v in ai.items()}}
            if changed:
                update['$set']['ai.needsEmbedding'] = profile['status'] == 'active'
                update['$set']['ai.attempts'] = 0
                update['$unset'] = {f'ai.{key}': '' for key in
                                   ('embedding', 'embeddedHash', 'embeddingModel', 'embeddingVersion', 'error')}
            if profile['status'] == 'active' and (not old or old['ai'].get('embeddedHash') != ai['semanticHash']):
                update['$set']['ai.needsEmbedding'] = True
            if profile['status'] != 'active':
                update['$set']['ai.needsEmbedding'] = False
            self.db.discovery_profiles.update_one({'canonicalId': canonical_id}, update, upsert=True, session=session)
            self.db.education_entities.update_one({'_id': canonical_id, 'revision': entity['revision']},
                {'$set': {'needsProjection': False}}, session=session)
        with self.db.client.start_session() as session:
            session.with_transaction(operation)

    def pending(self, limit: int):
        return self.db.source_observations.find({'processing.status': {'$in': ['pending', 'failed']},
            'processing.attempts': {'$lt': MAX_ATTEMPTS}}).sort('observedAt', 1).limit(limit)

    def record_failure(self, observation_id: str, exc: Exception):
        # Exception strings can contain source contents or credentials: store a safe error code.
        self.db.source_observations.update_one({'_id': observation_id},
            {'$set': {'processing.status': 'failed', 'processing.error': type(exc).__name__},
             '$inc': {'processing.attempts': 1}})
