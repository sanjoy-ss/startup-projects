import sys
import importlib

def test_python_version():
    assert sys.version_info >= (3, 12), "Python 3.12+ is required"

def test_critical_dependencies_importable():
    modules = [
        "pydantic", "pydantic_settings", "motor", "scrapling", 
        "trafilatura", "instructor", "rapidfuzz", "phonenumbers", 
        "tldextract", "unidecode", "httpx", "tenacity"
    ]
    for mod in modules:
        assert importlib.import_module(mod) is not None, f"Module {mod} should be importable"
