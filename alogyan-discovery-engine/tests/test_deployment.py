import os
from pathlib import Path
from types import SimpleNamespace
import unittest
from unittest.mock import patch, Mock
from pydantic import ValidationError
from discovery.config import Settings
from discovery.embeddings import HTTPEmbedder
from deploy.install_cron import block, replace_block, schedule


class CronTests(unittest.TestCase):
    def test_install_is_idempotent_and_preserves_other_jobs(self):
        existing = 'MAILTO=operator@example.org\n0 0 * * * /opt/other-job\n'
        generated = block(Path('/opt/alogyan engine'), '0 1 * * 2,6')
        once = replace_block(existing, generated)
        self.assertEqual(once, replace_block(once, generated))
        self.assertTrue(once.startswith(existing))
        self.assertIn("'/opt/alogyan engine/.venv/bin/python'", once)
        self.assertEqual(replace_block(once), existing)

    def test_unclosed_block_refuses_replacement(self):
        with self.assertRaises(ValueError):
            replace_block('# BEGIN ALOGYAN DISCOVERY\nother work\n', 'new')

    def test_cron_special_path_rejected(self):
        with self.assertRaises(ValueError):
            block(Path('/opt/100%project'), '0 1 * * 2,6')

    @patch('deploy.install_cron.time.localtime')
    def test_ist_and_utc_schedules(self, local):
        local.return_value = SimpleNamespace(tm_gmtoff=19800)
        self.assertEqual(schedule(), '0 1 * * 2,6')
        local.return_value = SimpleNamespace(tm_gmtoff=0)
        self.assertEqual(schedule(), '30 19 * * 1,5')
        local.return_value = SimpleNamespace(tm_gmtoff=3600)
        with self.assertRaises(ValueError):
            schedule()


@patch.dict(os.environ, {}, clear=True)
class ConfigurationTests(unittest.TestCase):
    def settings(self, **values):
        return Settings(_env_file=None, mongodb_uri='mongodb://localhost/test', **values)

    def test_embeddings_can_be_disabled(self):
        self.assertEqual(self.settings().embedding_url, '')

    def test_incomplete_embedding_configuration_fails_early(self):
        with self.assertRaises(ValidationError):
            self.settings(embedding_url='https://api.openai.com/v1/embeddings', embedding_model='text-embedding-3-small')

    def test_insecure_endpoint_rejected(self):
        with self.assertRaises(ValidationError):
            self.settings(embedding_url='http://example.org', embedding_key='test', embedding_model='test')

    def test_placeholder_mongo_uri_rejected(self):
        with self.assertRaises(ValidationError):
            Settings(_env_file=None, mongodb_uri='mongodb+srv://USERNAME:PASSWORD@CLUSTER/db')

    @patch('discovery.embeddings.httpx.post')
    def test_openai_request_uses_explicit_float_encoding(self, post):
        response = Mock()
        response.json.return_value = {'data': [{'embedding': [0.1, 0.2]}]}
        post.return_value = response
        result = HTTPEmbedder('https://api.openai.com/v1/embeddings', 'test', 'text-embedding-3-small', 2).embed('Public education text')
        self.assertEqual(result, [0.1, 0.2])
        self.assertEqual(post.call_args.kwargs['json']['encoding_format'], 'float')
        self.assertFalse(post.call_args.kwargs['follow_redirects'])
