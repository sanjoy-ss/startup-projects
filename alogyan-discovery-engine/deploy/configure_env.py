#!/usr/bin/env python3
"""Prompt locally for service credentials without echoing or accepting secrets in argv."""
import getpass
import os
from pathlib import Path
import sys
from dotenv import dotenv_values, set_key

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))


def configure():
    from discovery.config import Settings
    path = ROOT / '.env'
    values = dict(dotenv_values(path)) if path.exists() else {}
    existing_uri = values.get('ALOGYAN_MONGODB_URI') or ''
    uri = getpass.getpass('MongoDB Atlas URI (hidden; Enter keeps existing): ').strip() or existing_uri
    existing_key = values.get('ALOGYAN_EMBEDDING_KEY') or ''
    key = getpass.getpass('OpenAI API key (hidden; Enter keeps existing): ').strip() or existing_key
    updates = {
        'ALOGYAN_MONGODB_URI': uri,
        'ALOGYAN_MONGODB_DATABASE': values.get('ALOGYAN_MONGODB_DATABASE') or 'alogyan_discovery',
        'ALOGYAN_EMBEDDING_URL': 'https://api.openai.com/v1/embeddings',
        'ALOGYAN_EMBEDDING_KEY': key,
        'ALOGYAN_EMBEDDING_MODEL': 'text-embedding-3-small',
        'ALOGYAN_EMBEDDING_DIMENSIONS': '1536',
    }
    Settings(_env_file=None, **{name.removeprefix('ALOGYAN_').lower(): value for name, value in updates.items()})
    if not path.exists():
        descriptor = os.open(path, os.O_CREAT | os.O_EXCL | os.O_WRONLY, 0o600)
        os.close(descriptor)
    path.chmod(0o600)
    for name, value in updates.items():
        set_key(path, name, value, quote_mode='always')
    print('Saved private .env with OpenAI embeddings configured. No API call was made.')


if __name__ == '__main__':
    try:
        configure()
    except (Exception, KeyboardInterrupt) as exc:
        print(f'Configuration not completed ({type(exc).__name__}); check your entered credentials.', file=sys.stderr)
        raise SystemExit(1)
