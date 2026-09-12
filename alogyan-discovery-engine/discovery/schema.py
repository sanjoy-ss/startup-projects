"""Storage contracts supplement input models without coupling domain logic to MongoDB."""

def schema(required, properties):
    return {'$jsonSchema': {'bsonType': 'object', 'required': required, 'properties': properties}}


VALIDATORS = {
    'crawl_sources': schema(['id', 'provider', 'url', 'enabled', 'authorized'], {
        'enabled': {'bsonType': 'bool'}, 'authorized': {'bsonType': 'bool'}}),
    'source_observations': schema(['sourceKey', 'source', 'payload', 'fingerprints', 'processing', 'observedAt'], {
        'observedAt': {'bsonType': 'date'},
        'processing': {'bsonType': 'object', 'required': ['status', 'attempts'], 'properties': {
            'status': {'enum': ['pending', 'resolved', 'review', 'failed']},
            'attempts': {'bsonType': 'int', 'minimum': 0}}}}),
    'education_entities': schema(['name', 'normalizedName', 'entityType', 'slug', 'location',
                                  'taxonomy', 'normalized', 'revision', 'status'], {
        'slug': {'bsonType': 'string'}, 'revision': {'bsonType': 'int', 'minimum': 1},
        'status': {'enum': ['active', 'inactive', 'merged']}}),
    'discovery_profiles': schema(['canonicalId', 'slug', 'name', 'entityType', 'status', 'ai'], {
        'canonicalId': {'bsonType': 'string'},
        'ai': {'bsonType': 'object', 'required': ['semanticHash', 'semanticText'], 'properties': {
            'semanticHash': {'bsonType': 'string'}, 'semanticText': {'bsonType': 'string'},
            'embedding': {'bsonType': 'array', 'items': {'bsonType': 'double'}}}}}),
}
