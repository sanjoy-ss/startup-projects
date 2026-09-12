"""Optional OpenAI-compatible HTTP embedding adapter; no SDK or queue required."""
import math
import httpx
from .projector import embedding_needed


class HTTPEmbedder:
    def __init__(self, url: str, api_key: str, model: str, dimensions: int):
        self.url, self.api_key, self.model, self.dimensions = url, api_key, model, dimensions

    def embed(self, text: str) -> list[float]:
        response = httpx.post(self.url, headers={'Authorization': f'Bearer {self.api_key}'},
                              json={'model': self.model, 'input': text, 'dimensions': self.dimensions, 'encoding_format': 'float'},
                              timeout=45, follow_redirects=False)
        response.raise_for_status()
        vector = response.json()['data'][0]['embedding']
        if len(vector) != self.dimensions or not all(isinstance(v, (int, float)) and math.isfinite(v) for v in vector):
            raise ValueError('Invalid embedding vector')
        return [float(v) for v in vector]


def embed_profile(collection, profile: dict, embedder) -> bool:
    if not embedding_needed(profile):
        return False
    vector = embedder.embed(profile['ai']['semanticText'])
    # Do not attach a stale vector when a newer projection wins during HTTP inference.
    result = collection.update_one({'_id': profile['_id'], 'status': 'active',
                                    'ai.semanticHash': profile['ai']['semanticHash']}, {'$set': {
        'ai.embedding': vector, 'ai.embeddedHash': profile['ai']['semanticHash'],
        'ai.embeddingModel': embedder.model, 'ai.embeddingVersion': 1, 'ai.needsEmbedding': False},
        '$unset': {'ai.error': ''}})
    return result.modified_count > 0
