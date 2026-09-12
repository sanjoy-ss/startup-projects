from datetime import datetime, timezone
import pytest
from discovery.models import (
    GeoCoordinates, GeoLocalHierarchy, EducationalCategories,
    InstructorEducationPayload, FrontierItem, RawSnapshot, LeadScoreBreakdown
)

def test_geo_local_hierarchy_validation():
    geo = GeoLocalHierarchy(
        locality="Banamalipur",
        landmark="Near Old Motor Stand",
        city="Agartala",
        state="Tripura",
        pincode="799001"
    )
    assert geo.city == "Agartala"
    assert geo.pincode == "799001"
    assert geo.locality == "Banamalipur"

def test_invalid_pincode_raises():
    with pytest.raises(ValueError):
        GeoLocalHierarchy(city="Agartala", pincode="1234")

def test_educational_categories():
    cat = EducationalCategories(
        primary_category="k12_school",
        sub_categories=["CBSE Secondary", "Science Stream"],
        curriculum_boards=["CBSE"]
    )
    assert cat.primary_category == "k12_school"
    assert "CBSE" in cat.curriculum_boards

def test_lead_score_breakdown():
    score = LeadScoreBreakdown(
        completeness_score=35.0,
        contactability_score=25.0,
        freshness_score=15.0,
        credibility_score=10.0,
        total_score=85.0,
        tier="tier_1_hot"
    )
    assert score.total_score == 85.0
    assert score.tier == "tier_1_hot"

def test_frontier_item():
    item = FrontierItem(
        url="https://example.edu.in/admissions",
        domain="example.edu.in",
        source_type="search",
        query_origin="schools in Agartala"
    )
    assert item.domain == "example.edu.in"
    assert item.status == "queued"
    assert item.priority == 5

def test_raw_snapshot():
    snap = RawSnapshot(
        url="https://example.edu.in",
        status_code=200,
        html="<html><body><h1>Test</h1></body></html>",
        fetched_via="scrapling_http"
    )
    assert len(snap.id) == 64  # sha256
    assert snap.fetched_via == "scrapling_http"
