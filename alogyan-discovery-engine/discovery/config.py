from urllib.parse import urlsplit
from pydantic import Field, SecretStr, model_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file='.env', env_prefix='ALOGYAN_', extra='ignore')
    mongodb_uri: SecretStr
    mongodb_database: str = 'alogyan_discovery'
    batch_limit: int = Field(default=500, ge=1, le=10000)
    user_agent: str = 'AlogyanDiscovery/1.0'
    crawl_delay: float = Field(default=3, ge=1)
    embedding_url: str = ''
    embedding_key: SecretStr = SecretStr('')
    embedding_model: str = ''
    embedding_dimensions: int = Field(default=1536, ge=1, le=4096)

    @model_validator(mode='after')
    def validate_services(self):
        uri = self.mongodb_uri.get_secret_value()
        if not uri.startswith(('mongodb://', 'mongodb+srv://')) or any(v in uri for v in ('USERNAME', 'PASSWORD', 'CLUSTER')):
            raise ValueError('Set a real MongoDB URI in ALOGYAN_MONGODB_URI')
        if self.embedding_url:
            parsed = urlsplit(self.embedding_url)
            if parsed.scheme != 'https' or not parsed.hostname or parsed.username or parsed.password or parsed.query or parsed.fragment:
                raise ValueError('Embedding endpoint must be HTTPS without credentials, query, or fragment')
            if not self.embedding_model.strip() or not self.embedding_key.get_secret_value().strip():
                raise ValueError('Embedding URL requires a model and API key')
        elif self.embedding_model or self.embedding_key.get_secret_value():
            raise ValueError('Embedding credentials/model require an embedding URL')
        return self
