"""Explicit public allowlist and semantic input. Never copy raw observations."""
from .normalize import digest


def project(entity: dict, now) -> dict:
    semantic = {key: entity.get(key) for key in
                ('name', 'entityType', 'description', 'taxonomy')}
    semantic['location'] = {k: entity.get('location', {}).get(k, '')
                            for k in ('city', 'locality', 'state')}
    text = '\n'.join(filter(None, [entity['name'], entity['entityType'],
                    entity.get('description', ''),
                    ', '.join(semantic['location'].values()),
                    *(', '.join(entity.get('taxonomy', {}).get(k, []))
                      for k in ('subjects', 'classes', 'boards'))]))
    profile = {k: entity[k] for k in ('slug', 'entityType', 'name', 'location', 'taxonomy', 'status')}
    profile.update(canonicalId=entity['_id'], aliases=entity.get('aliases', [])[:20], description=entity.get('description', ''),
                   website=entity.get('website', ''),
                   contact={k: entity.get('normalized', {}).get(k, []) for k in ('phones', 'emails')},
                   verification={'verified': bool(entity.get('verified')), 'claimed': bool(entity.get('claimed'))},
                   ranking={'finalScore': (30 if entity.get('verified') else 0) +
                            sum(bool(entity.get(k)) for k in ('name', 'website', 'description')) * 5},
                   searchText=text, updatedAt=now,
                   ai={'semanticText': text, 'semanticHash': digest(semantic)})
    return profile


def embedding_needed(profile: dict) -> bool:
    ai = profile['ai']
    return profile['status'] == 'active' and ai.get('embeddedHash') != ai['semanticHash']
