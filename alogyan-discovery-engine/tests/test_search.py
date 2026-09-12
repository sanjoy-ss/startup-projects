import unittest
from unittest.mock import Mock
from urllib.parse import parse_qs, urlsplit
from discovery.models import Location
from discovery.search import extract_candidates, discover_search, google_url, SearchBlockedError


class SearchTests(unittest.TestCase):
    def extract(self, html, **kwargs):
        return extract_candidates(html, 'https://www.google.com/search?q=schools', 'google',
                                  'private_school', Location(city='Agartala'), **kwargs)

    def test_query_encoding(self):
        self.assertEqual(parse_qs(urlsplit(google_url('schools & coaching Agartala')).query)['q'],
                         ['schools & coaching Agartala'])

    def test_result_links_unwrapped_deduplicated_and_disabled(self):
        html = '''<a href="/url?q=https%3A%2F%2Fschool.example.org%2F"><h3>A school</h3></a>
                  <a href="https://school.example.org/"><h3>Duplicate</h3></a>
                  <a href="https://maps.google.com/"><h3>Maps</h3></a>
                  <a href="mailto:test@example.org"><h3>Email</h3></a>'''
        results = self.extract(html)
        self.assertEqual(len(results), 1)
        self.assertEqual(results[0]['source']['url'], 'https://school.example.org/')
        self.assertFalse(results[0]['source']['enabled'])
        self.assertFalse(results[0]['source']['authorized'])
        self.assertEqual(results[0]['source']['location']['city'], 'Agartala')

    def test_captcha_is_not_empty_success(self):
        with self.assertRaises(SearchBlockedError):
            self.extract('<form action="/sorry/index">Challenge</form>')

    def test_directory_selector_and_relative_links(self):
        result = extract_candidates('<a class="school" href="/schools/one">School One</a>',
            'https://directory.example.org/list', 'directory', 'private_school', Location(), selector='a.school')
        self.assertEqual(result[0]['source']['url'], 'https://directory.example.org/schools/one')

    def test_fetch_obeys_shared_fetcher_and_limit(self):
        fetcher = Mock()
        fetcher.fetch_html.return_value = '<a href="https://one.example.org"><h3>One</h3></a><a href="https://two.example.org"><h3>Two</h3></a>'
        result = discover_search(fetcher, query='schools Agartala', entity_type='private_school',
                                 city='Agartala', state='Tripura', limit=1)
        self.assertEqual(len(result['candidates']), 1)
        fetcher.fetch_html.assert_called_once_with(google_url('schools Agartala'), authorized=True)
