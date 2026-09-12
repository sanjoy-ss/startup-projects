import unittest
from datetime import timedelta
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import Mock
from discovery.models import Observation, CrawlSource, utcnow
from discovery.normalize import canonical_fields, name_key, phone, domain, observation_document
from discovery.resolution import decide
from discovery.repository import merge_fields
from discovery.projector import project
from discovery.embeddings import embed_profile
from discovery.sources import extract


def observation(**changes):
    values = dict(provider='official', externalId='one', url='https://school.example.org/',
        name='Tripura Learning Centre', entityType='private_school', trust=70,
        phones=['9876543210'], website='https://school.example.org/',
        location={'city': 'Agartala', 'state': 'Tripura', 'locality': 'West', 'postalCode': '799001'})
    return Observation(**(values | changes))


def entity(**changes):
    return canonical_fields(observation()) | dict(_id='one', slug='one', status='active', **changes)


class NormalizationTests(unittest.TestCase):
    def test_name_unicode_punctuation_and_meaningful_words(self):
        self.assertEqual(name_key('  TRIPURA Learning—Centre! '), 'tripura learning center')
        self.assertEqual(name_key('ＡＢＣ School'), 'abc school')
        self.assertNotEqual(name_key('North School'), name_key('South School'))

    def test_phone_and_domain(self):
        self.assertEqual(phone('98765 43210'), '+919876543210')
        self.assertIsNone(phone('123'))
        self.assertEqual(domain('https://www.campus.example.co.in/about'), 'example.co.in')
        self.assertEqual(domain('https://teacher.blogspot.com'), 'teacher.blogspot.com')

    def test_taxonomy_and_fingerprints(self):
        obs = observation(taxonomy={'subjects': ['Maths', 'mathematics', 'Math']})
        self.assertEqual(canonical_fields(obs)['taxonomy']['subjects'], ['mathematics'])
        first = observation_document(obs, 'run1', utcnow())
        second = observation_document(obs, 'run2', utcnow())
        self.assertEqual(first['_id'], second['_id'])
        changed = observation_document(observation(name='Changed school'), 'run2', utcnow())
        self.assertNotEqual(first['_id'], changed['_id'])
        self.assertEqual(first['sourceKey'], changed['sourceKey'])


class ResolutionTests(unittest.TestCase):
    def test_strong_match(self):
        self.assertEqual(decide(canonical_fields(observation()), [entity()]).action, 'match')

    def test_name_only_is_review(self):
        incoming = canonical_fields(observation(phones=[], website=''))
        self.assertEqual(decide(incoming, [entity()]).action, 'review')

    def test_shared_domain_branch_and_tutor_are_not_merged(self):
        for obs in [observation(location={'city': 'Agartala', 'locality': 'East'}),
                    observation(entityType='tutor'), observation(name='Another School')]:
            with self.subTest(obs=obs.name):
                self.assertEqual(decide(canonical_fields(obs), [entity()]).action, 'review')

    def test_ambiguous_and_saturated_review(self):
        other = entity(); other['_id'] = 'two'
        self.assertEqual(decide(canonical_fields(observation()), [entity(), other]).action, 'review')
        self.assertEqual(decide(canonical_fields(observation()), [entity()], saturated=True).action, 'review')

    def test_shared_contact_without_branch_evidence_requires_review(self):
        sparse = observation(location={'city': 'Agartala'})
        self.assertEqual(decide(canonical_fields(sparse), [entity()]).action, 'review')

    def test_source_identity_survives_rename(self):
        self.assertEqual(decide(canonical_fields(observation(name='Renamed')), [], 'one').canonicalId, 'one')

    def test_unrelated_creates(self):
        self.assertEqual(decide(canonical_fields(observation()), []).action, 'create')


class ProvenanceTests(unittest.TestCase):
    def test_verified_and_claimed_preserved(self):
        doc = observation_document(observation(name='Wrong'), 'run', utcnow())
        for flag in ('verified', 'claimed'):
            old = entity(**{flag: True})
            self.assertEqual(merge_fields(old, canonical_fields(observation(name='Wrong')), doc), old | {'provenance': {}})

    def test_missing_contact_does_not_erase_and_lower_trust_cannot_replace(self):
        now = utcnow()
        original = observation_document(observation(), 'run', now)
        saved = merge_fields(None, canonical_fields(observation()), original)
        poor = observation(phones=[], website='', name='Bad', trust=20, location={'city': 'Other'})
        result = merge_fields(saved, canonical_fields(poor), observation_document(poor, 'run2', now))
        self.assertEqual(result['name'], saved['name'])
        self.assertEqual(result['normalized']['phones'], saved['normalized']['phones'])
        self.assertEqual(result['location']['city'], 'Agartala')

    def test_older_evidence_does_not_revert_newer(self):
        now = utcnow()
        saved = merge_fields(None, canonical_fields(observation()), observation_document(observation(), 'r1', now))
        old = observation(name='Old')
        result = merge_fields(saved, canonical_fields(old), observation_document(old, 'r2', now - timedelta(days=1)))
        self.assertEqual(saved['name'], result['name'])


class ProjectionTests(unittest.TestCase):
    def test_public_allowlist(self):
        record = entity(raw={'secret': 'private'}, provenance={'internal': 1})
        public = project(record, utcnow())
        self.assertNotIn('raw', public)
        self.assertNotIn('provenance', public)
        self.assertNotIn('secret', str(public))

    def test_semantic_hash_ignores_nonsemantic_changes(self):
        before = project(entity(), utcnow())
        after = project(entity(verified=True, internalNote='updated'), utcnow())
        self.assertEqual(before['ai']['semanticHash'], after['ai']['semanticHash'])
        changed = entity(); changed['taxonomy']['subjects'] = ['mathematics']
        self.assertNotEqual(before['ai']['semanticHash'], project(changed, utcnow())['ai']['semanticHash'])

    def test_unchanged_skips_provider_and_changed_uses_cas(self):
        profile = project(entity(), utcnow()) | {'_id': 'profile1'}
        profile['ai']['embeddedHash'] = profile['ai']['semanticHash']
        provider = Mock(model='test'); collection = Mock()
        self.assertFalse(embed_profile(collection, profile, provider))
        provider.embed.assert_not_called()
        profile['ai']['embeddedHash'] = 'old'
        provider.embed.return_value = [0.1, 0.2]
        collection.update_one.return_value = SimpleNamespace(modified_count=1)
        self.assertTrue(embed_profile(collection, profile, provider))
        query = collection.update_one.call_args.args[0]
        self.assertEqual(query['ai.semanticHash'], profile['ai']['semanticHash'])
        collection.update_one.return_value = SimpleNamespace(modified_count=0)
        self.assertFalse(embed_profile(collection, profile, provider))


class ExtractionTests(unittest.TestCase):
    def test_fixture_extracts_only_public_organization(self):
        source = CrawlSource(id='one', provider='official', url='https://example.org/', entityType='private_school')
        observations = extract(Path('tests/fixtures/school.html').read_text(), source)
        self.assertEqual(len(observations), 1)
        self.assertEqual(observations[0].name, 'Tripura Learning Centre')
        self.assertNotIn('Private pupil', str(observations))
        self.assertNotIn('streetAddress', str(observations))
        self.assertEqual(observations[0].location.city, 'Agartala')

    def test_bad_json_uses_heading(self):
        source = CrawlSource(id='one', provider='official', url='https://example.org/', entityType='private_school')
        self.assertEqual(extract('<h1>School</h1><script type="application/ld+json">broken</script>', source)[0].name, 'School')


if __name__ == '__main__':
    unittest.main()
