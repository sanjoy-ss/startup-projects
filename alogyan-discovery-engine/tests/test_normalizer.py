from discovery.normalize import (
    normalize_phone_e164,
    normalize_domain,
    clean_text_unicode,
    phone,
    domain
)

def test_phone_normalization_indian_numbers():
    assert normalize_phone_e164("0381 234 5678", "IN") == "+913812345678"
    assert normalize_phone_e164("98620-12345", "IN") == "+919862012345"
    assert normalize_phone_e164("+91 98620 12345", "IN") == "+919862012345"
    assert normalize_phone_e164("invalid", "IN") is None

def test_domain_normalization():
    assert normalize_domain("https://www.agartala-school.edu.in/about?ref=1") == "agartala-school.edu.in"
    assert normalize_domain("subdomain.example.com/path") == "example.com"
    assert normalize_domain("") is None

def test_clean_text_unicode():
    assert clean_text_unicode("St. Paul’s  Senior\u200b School") == "St. Paul's Senior School"
