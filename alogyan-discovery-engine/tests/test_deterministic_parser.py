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
    payload, confidence = parser.parse(HTML_WITH_JSON_LD, url="https://holycross.edu.in")
    assert payload is not None
    assert payload.name == "Holy Cross School"
    assert confidence >= 0.70
    assert payload.geo_local.city == "Agartala"
    assert payload.geo_local.pincode == "799009"

def test_deterministic_parser_low_confidence_on_empty():
    parser = DeterministicParser()
    payload, confidence = parser.parse("<html><body><div>Random blog post</div></body></html>", url="https://example.com")
    assert confidence < 0.70
