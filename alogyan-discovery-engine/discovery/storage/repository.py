"""Asynchronous MongoDB repository for Alogyan Discovery Engine."""
from datetime import datetime, timedelta
from typing import Literal
from discovery.models import FrontierItem, RawSnapshot, utcnow


class AsyncRepository:
    def __init__(self, db):
        self.db = db

    async def save_snapshot(
        self,
        url: str,
        status_code: int,
        html: str,
        fetched_via: Literal["scrapling_http", "browser_fetch"] = "scrapling_http",
        headers: dict | None = None,
        run_id: str = ""
    ) -> RawSnapshot:
        snapshot = RawSnapshot(
            url=url,
            status_code=status_code,
            headers=headers or {},
            html=html,
            fetched_via=fetched_via,
            run_id=run_id,
            fetched_at=utcnow()
        )
        doc = snapshot.model_dump()
        doc['_id'] = snapshot.id
        await self.db.raw_snapshots.update_one(
            {'_id': snapshot.id},
            {'$set': doc},
            upsert=True
        )
        return snapshot

    async def enqueue_frontier_item(self, item: FrontierItem) -> bool:
        doc = item.model_dump()
        doc['_id'] = item.id or item.url_hash
        res = await self.db.url_frontier.update_one(
            {'_id': doc['_id']},
            {
                '$setOnInsert': {
                    'url': item.url,
                    'domain': item.domain,
                    'source_type': item.source_type,
                    'query_origin': item.query_origin,
                    'status': 'queued',
                    'priority': item.priority,
                    'attempts': 0,
                    'created_at': utcnow(),
                    'next_fetch_at': utcnow()
                }
            },
            upsert=True
        )
        return bool(res.upserted_id)

    async def fetch_next_frontier_batch(self, limit: int = 50) -> list[FrontierItem]:
        now = utcnow()
        cursor = self.db.url_frontier.find(
            {
                'status': 'queued',
                'next_fetch_at': {'$lte': now}
            }
        ).sort([('priority', -1), ('next_fetch_at', 1)]).limit(limit)
        
        items = []
        async for doc in cursor:
            # Map _id back to id if needed
            doc_id = doc.get('_id')
            data = {k: v for k, v in doc.items() if k != '_id'}
            data['id'] = str(doc_id)
            items.append(FrontierItem.model_validate(data))
        return items

    async def update_frontier_status(
        self,
        item_id: str,
        status: Literal["queued", "in_progress", "completed", "failed"],
        attempts: int | None = None,
        next_fetch_at: datetime | None = None,
        last_error: str | None = None
    ):
        update_fields: dict = {'status': status}
        if attempts is not None:
            update_fields['attempts'] = attempts
        if next_fetch_at is not None:
            update_fields['next_fetch_at'] = next_fetch_at
        if last_error is not None:
            update_fields['last_error'] = last_error

        await self.db.url_frontier.update_one(
            {'_id': item_id},
            {'$set': update_fields}
        )

    async def save_observation(self, observation: dict, run_id: str) -> str:
        import hashlib
        import json
        obs_id = observation.get('_id') or observation.get('id')
        url = observation.get('url', '')
        if not obs_id:
            obs_id = hashlib.sha256(f"{url}|{utcnow().isoformat()}".encode()).hexdigest()

        src_key = hashlib.sha256(f"discovery|{url}".encode()).hexdigest()
        content_hash = hashlib.sha256(json.dumps(observation, default=str).encode()).hexdigest()

        doc = {
            '_id': obs_id,
            'sourceKey': src_key,
            'source': {
                'provider': observation.get('parserType', 'discovery_engine'),
                'externalId': obs_id,
                'url': url
            },
            'payload': observation,
            'fingerprints': {'content': content_hash},
            'runId': run_id,
            'observedAt': utcnow(),
            'processing': {'status': 'pending', 'attempts': 0}
        }
        await self.db.source_observations.update_one(
            {'_id': obs_id},
            {'$set': doc},
            upsert=True
        )
        return obs_id

    async def fetch_pending_observations(self, limit: int = 100) -> list[dict]:
        cursor = self.db.source_observations.find(
            {'processing.status': 'pending'}
        ).limit(limit)
        return [doc async for doc in cursor]

    async def record_lead_score(self, entity_id: str, lead_score: dict):
        await self.db.education_entities.update_one(
            {'_id': entity_id},
            {'$set': {'leadScore': lead_score, 'updatedAt': utcnow()}}
        )
        await self.db.discovery_profiles.update_one(
            {'canonicalId': entity_id},
            {'$set': {'leadScore': lead_score, 'updatedAt': utcnow()}}
        )
