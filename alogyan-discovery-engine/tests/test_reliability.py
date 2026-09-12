import unittest
from unittest.mock import Mock, patch
from types import SimpleNamespace
from discovery.models import CrawlSource, utcnow
from discovery.pipeline import weekly
from discovery.sources import WebsiteAdapter
from discovery.repository import Repository
from discovery.normalize import canonical_fields
from test_core import observation


class Cursor(list):
    def sort(self, *args):
        return self

    def limit(self, count):
        return Cursor(self[:count])


def repository_stub():
    repo = Mock()
    repo.db.crawl_sources.find.return_value = Cursor()
    repo.pending.return_value = []
    repo.db.education_entities.find.return_value = Cursor()
    repo.db.discovery_profiles.find.return_value = Cursor()
    return repo


class ReliabilityTests(unittest.TestCase):
    def test_one_bad_observation_does_not_drop_next_record(self):
        repo = repository_stub()
        repo.pending.return_value = [{'_id': 'broken'}, {'_id': 'good'}]
        repo.resolve.side_effect = [ValueError('bad'), 'created']
        result = weekly(repo, Mock())
        self.assertEqual(result['created'], 1)
        self.assertEqual(result['errors'], 1)
        self.assertEqual(result['status'], 'completed_with_errors')
        repo.record_failure.assert_called_once()
        repo.db.discovery_runs.update_one.assert_called_once()

    def test_backlog_projects_without_new_crawls(self):
        repo = repository_stub()
        repo.db.education_entities.find.return_value = Cursor([{'_id': 'old'}])
        result = weekly(repo, Mock())
        repo.project_entity.assert_called_once_with('old')
        self.assertEqual(result['projected'], 1)

    def test_fatal_failure_still_finishes_run(self):
        repo = repository_stub()
        repo.pending.side_effect = RuntimeError('database unavailable')
        with self.assertRaises(RuntimeError):
            weekly(repo, Mock())
        update = repo.db.discovery_runs.update_one.call_args.args[1]['$set']
        self.assertEqual(update['status'], 'failed')
        self.assertIn('completedAt', update)

    def test_repeated_source_failure_disables_source(self):
        repo = repository_stub()
        source = CrawlSource(id='one', provider='official', url='https://example.org/',
                             entityType='private_school', authorized=True, enabled=True)
        repo.db.crawl_sources.find.return_value = Cursor([source.model_dump() | {'_id': 'one', 'failures': 2}])
        adapter = Mock(); adapter.discover.side_effect = ValueError('blocked')
        result = weekly(repo, adapter)
        update = repo.db.crawl_sources.update_one.call_args.args[1]['$set']
        self.assertFalse(update['enabled'])
        self.assertEqual(update['lastError'], 'ValueError')
        self.assertEqual(result['errors'], 1)

    def test_exact_candidate_lookup_precedes_fuzzy(self):
        db = Mock()
        db.education_entities.find.return_value = Cursor([{'_id': 'one'}])
        Repository(db).candidates(canonical_fields(observation()), None)
        db.education_entities.find.assert_called_once()
        self.assertIn('$or', db.education_entities.find.call_args.args[0])

    def test_fuzzy_query_is_city_type_and_prefix_bounded(self):
        db = Mock()
        db.education_entities.find.side_effect = [Cursor(), Cursor()]
        Repository(db).candidates(canonical_fields(observation()), None)
        query = db.education_entities.find.call_args.args[0]
        self.assertEqual(query['location.cityKey'], 'agartala')
        self.assertEqual(query['entityType'], 'private_school')
        self.assertTrue(query['normalizedName']['$regex'].startswith('^'))

    @patch('discovery.sources.assert_public_host')
    @patch('discovery.sources.httpx.get')
    def test_robots_denial_stops_before_scrapling(self, get, host):
        get.return_value = SimpleNamespace(status_code=200, text='User-agent: *\nDisallow: /')
        source = CrawlSource(id='one', provider='official', url='https://example.org/',
                             entityType='private_school', authorized=True)
        with self.assertRaisesRegex(ValueError, 'disallows'):
            WebsiteAdapter('AlogyanDiscovery/1.0', 3).discover(source)

    @patch('discovery.sources.httpx.get')
    def test_unapproved_source_never_fetches(self, get):
        source = CrawlSource(id='one', provider='official', url='https://example.org/', entityType='private_school')
        with self.assertRaises(ValueError):
            WebsiteAdapter('AlogyanDiscovery/1.0', 3).discover(source)
        get.assert_not_called()
