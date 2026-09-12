"""Opt-in real replica-set tests; never use a production URI.
Creates/drops only a random alogyan_test_* database on the supplied test cluster.
"""
import os
import unittest
from uuid import uuid4
from pymongo import MongoClient
from discovery.indexes import ensure_indexes
from discovery.repository import Repository
from test_core import observation


@unittest.skipUnless(os.getenv('ALOGYAN_TEST_MONGODB_URI'), 'test MongoDB replica-set URI not configured')
class MongoIntegrationTests(unittest.TestCase):
    def setUp(self):
        self.client = MongoClient(os.environ['ALOGYAN_TEST_MONGODB_URI'], tz_aware=True,
                                  serverSelectionTimeoutMS=5000)
        self.db = self.client['alogyan_test_' + uuid4().hex]
        ensure_indexes(self.db)
        self.repo = Repository(self.db)

    def tearDown(self):
        self.client.drop_database(self.db.name)
        self.client.close()

    def test_idempotent_ingestion_resolution_and_projection(self):
        self.assertEqual(self.repo.ingest([observation()], 'run1'), 1)
        self.assertEqual(self.repo.ingest([observation()], 'run2'), 0)
        doc = self.db.source_observations.find_one()
        self.assertEqual(self.repo.resolve(doc['_id']), 'created')
        self.assertEqual(self.repo.resolve(doc['_id']), 'skipped')
        entity = self.db.education_entities.find_one()
        self.repo.project_entity(entity['_id'])
        self.assertEqual(self.db.education_entities.count_documents({}), 1)
        self.assertEqual(self.db.discovery_profiles.count_documents({}), 1)
        self.assertEqual(self.db.entity_merge_history.count_documents({}), 1)
        self.assertFalse(self.db.education_entities.find_one()['needsProjection'])

    def test_projection_preserves_vector_until_semantics_change(self):
        self.repo.ingest([observation()], 'run')
        self.repo.resolve(self.db.source_observations.find_one()['_id'])
        entity = self.db.education_entities.find_one()
        self.repo.project_entity(entity['_id'])
        profile = self.db.discovery_profiles.find_one()
        self.db.discovery_profiles.update_one({'_id': profile['_id']}, {'$set': {
            'ai.embedding': [0.1], 'ai.embeddedHash': profile['ai']['semanticHash'], 'ai.needsEmbedding': False}})
        self.repo.project_entity(entity['_id'])
        self.assertEqual(self.db.discovery_profiles.find_one()['ai']['embedding'], [0.1])
        self.db.education_entities.update_one({'_id': entity['_id']}, {'$set': {'description': 'New subjects'}})
        self.repo.project_entity(entity['_id'])
        self.assertNotIn('embedding', self.db.discovery_profiles.find_one()['ai'])
        self.assertTrue(self.db.discovery_profiles.find_one()['ai']['needsEmbedding'])

    def test_transaction_failure_rolls_back_canonical_write(self):
        self.repo.ingest([observation()], 'run')
        original = self.db.source_observations.find_one()
        # Fail after canonical and source-map writes inside the real transaction.
        from unittest.mock import patch
        from pymongo.synchronous.collection import Collection
        real_update = Collection.update_one
        def fail_audit(collection, *args, **kwargs):
            if collection.name == 'entity_merge_history':
                raise ValueError('injected audit failure')
            return real_update(collection, *args, **kwargs)
        with patch.object(Collection, 'update_one', fail_audit):
            with self.assertRaises(ValueError):
                self.repo.resolve(original['_id'])
        self.assertEqual(self.db.education_entities.count_documents({}), 0)
        self.assertEqual(self.db.source_observations.find_one()['processing']['status'], 'pending')
        self.assertEqual(self.repo.resolve(original['_id']), 'created')
