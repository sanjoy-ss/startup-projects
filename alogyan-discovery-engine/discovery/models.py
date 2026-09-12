"""Validated boundaries; MongoDB documents use matching schema and camelCase conventions."""
import hashlib
from datetime import datetime, timezone
from typing import Literal
from pydantic import BaseModel, ConfigDict, Field, field_validator
from urllib.parse import urlsplit

EntityType = Literal[
    'private_school', 'coaching_centre', 'training_institute',
    'tutor', 'activity_provider', 'college', 'education_service', 'other'
]


def utcnow() -> datetime:
    return datetime.now(timezone.utc)


def public_url(value: str) -> str:
    parts = urlsplit(value)
    if parts.scheme not in ('http', 'https') or not parts.hostname or parts.username or parts.password:
        raise ValueError('Expected an HTTP(S) URL without credentials')
    if parts.port not in (None, 80, 443):
        raise ValueError('Only public HTTP(S) ports are supported')
    return value


class Model(BaseModel):
    model_config = ConfigDict(extra='ignore')


class GeoCoordinates(Model):
    latitude: float | None = Field(default=None, ge=-90.0, le=90.0)
    longitude: float | None = Field(default=None, ge=-180.0, le=180.0)
    geo_source: Literal["openstreetmap", "google_maps", "schema_org", "inferred", None] = None


class GeoLocalHierarchy(Model):
    locality: str | None = Field(default=None, description="e.g. Banamalipur, Dhaleswar, Ramnagar")
    landmark: str | None = Field(default=None, description="e.g. Near Circuit House, Opp. City Centre")
    ward_or_zone: str | None = Field(default=None, description="Municipal ward or revenue block")
    city: str = Field(default="Agartala")
    district: str = Field(default="West Tripura")
    state: str = Field(default="Tripura")
    pincode: str | None = Field(default=None)

    @field_validator('pincode')
    @classmethod
    def validate_pincode(cls, v: str | None) -> str | None:
        if v is not None:
            v_clean = v.strip()
            if not (len(v_clean) == 6 and v_clean.isdigit()):
                raise ValueError("Indian PIN code must be exactly 6 digits")
            return v_clean
        return v


class EducationalCategories(Model):
    primary_category: Literal[
        "k12_school", 
        "higher_education_college", 
        "coaching_competitive_exams", 
        "private_tutor_or_academy", 
        "preschool_daycare", 
        "vocational_skill_institute",
        "special_education"
    ]
    sub_categories: list[str] = Field(default_factory=list)
    education_levels: list[Literal[
        "pre_primary", "primary", "middle_school", "secondary_10th", 
        "higher_secondary_12th", "diploma", "undergraduate", "postgraduate"
    ]] = Field(default_factory=list)
    curriculum_boards: list[str] = Field(default_factory=list)
    medium_of_instruction: list[str] = Field(default_factory=list)


class LeadScoreBreakdown(Model):
    completeness_score: float = Field(default=0.0, ge=0.0, le=40.0)
    contactability_score: float = Field(default=0.0, ge=0.0, le=30.0)
    freshness_score: float = Field(default=0.0, ge=0.0, le=20.0)
    credibility_score: float = Field(default=0.0, ge=0.0, le=10.0)
    total_score: float = Field(default=0.0, ge=0.0, le=100.0)
    tier: Literal["tier_1_hot", "tier_2_warm", "tier_3_cold"] = "tier_3_cold"


class InstructorEducationPayload(Model):
    name: str = Field(description="Official full name of institution or academy")
    entity_type: str = "private_school"
    categories: EducationalCategories
    geo_local: GeoLocalHierarchy = Field(default_factory=GeoLocalHierarchy)
    coordinates: GeoCoordinates | None = None
    phones: list[str] = Field(default_factory=list)
    emails: list[str] = Field(default_factory=list)
    website: str | None = None
    full_address: str | None = None
    courses_offered: list[str] = Field(default_factory=list)
    social_links: list[str] = Field(default_factory=list)
    confidence_assessment: float = Field(default=0.8, ge=0.0, le=1.0)


class FrontierItem(Model):
    id: str | None = None
    url: str
    domain: str
    source_type: Literal["search", "maps", "directory", "website"] = "website"
    query_origin: str = ""
    status: Literal["queued", "in_progress", "completed", "failed"] = "queued"
    priority: int = Field(default=5, ge=1, le=10)
    attempts: int = 0
    next_fetch_at: datetime = Field(default_factory=utcnow)
    created_at: datetime = Field(default_factory=utcnow)

    @field_validator('url')
    @classmethod
    def validate_url(cls, v: str) -> str:
        return public_url(v)

    @property
    def url_hash(self) -> str:
        return hashlib.sha256(self.url.strip().lower().rstrip("/").encode("utf-8")).hexdigest()

    def model_post_init(self, __context):
        if not self.id:
            self.id = self.url_hash


class RawSnapshot(Model):
    id: str = ""
    url: str
    status_code: int
    headers: dict[str, str] = Field(default_factory=dict)
    html: str
    fetched_via: Literal["scrapling_http", "browser_fetch"] = "scrapling_http"
    run_id: str = ""
    fetched_at: datetime = Field(default_factory=utcnow)

    @field_validator('url')
    @classmethod
    def validate_url(cls, v: str) -> str:
        return public_url(v)

    def model_post_init(self, __context):
        if not self.id:
            content_hash = hashlib.sha256(f"{self.url}|{self.html}".encode("utf-8")).hexdigest()
            self.id = content_hash


# Legacy models preserved for backward compatibility
class Location(Model):
    city: str = ''
    locality: str = ''
    state: str = ''
    postalCode: str = ''
    country: str = 'IN'


class Taxonomy(Model):
    subjects: list[str] = Field(default_factory=list, max_length=50)
    classes: list[str] = Field(default_factory=list, max_length=30)
    boards: list[str] = Field(default_factory=list, max_length=20)


class Observation(Model):
    provider: str = Field(min_length=1, max_length=100)
    externalId: str | None = Field(default=None, max_length=500)
    url: str
    entityType: EntityType
    name: str = Field(min_length=1, max_length=300)
    website: str = ''
    phones: list[str] = Field(default_factory=list, max_length=20)
    emails: list[str] = Field(default_factory=list, max_length=20)
    location: Location = Field(default_factory=Location)
    taxonomy: Taxonomy = Field(default_factory=Taxonomy)
    description: str = Field(default='', max_length=5000)
    raw: dict = Field(default_factory=dict)
    trust: int = Field(default=40, ge=0, le=80)

    _url = field_validator('url')(public_url)


class CrawlSource(Model):
    id: str = Field(min_length=1, max_length=100)
    provider: str = Field(min_length=1, max_length=100)
    url: str
    entityType: EntityType
    location: Location = Field(default_factory=lambda: Location(city='Agartala', state='Tripura'))
    intervalDays: int = Field(default=7, ge=1, le=365)
    trust: int = Field(default=60, ge=0, le=80)
    enabled: bool = False
    authorized: bool = False

    _url = field_validator('url')(public_url)
