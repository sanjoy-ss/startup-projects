"""Lead Scoring Engine computing composite score (0-100) and classification tiers."""
from discovery.models import LeadScoreBreakdown


def calculate_lead_score(entity: dict) -> LeadScoreBreakdown:
    completeness = 0.0
    contactability = 0.0
    freshness = 0.0
    credibility = 0.0

    # 1. Data Completeness (40% max)
    coords = entity.get("coordinates")
    if coords and coords.get("latitude") is not None and coords.get("longitude") is not None:
        completeness += 10.0

    geo = entity.get("geo_local") or entity.get("location") or {}
    has_loc = bool(geo.get("locality") or geo.get("addressLocality"))
    has_pin = bool(geo.get("pincode") or geo.get("postalCode"))
    if has_loc and has_pin:
        completeness += 10.0
    elif has_loc or has_pin:
        completeness += 5.0

    cats = entity.get("categories") or {}
    primary_cat = cats.get("primary_category") or entity.get("entityType")
    boards = cats.get("curriculum_boards") or entity.get("taxonomy", {}).get("boards", [])
    if primary_cat and boards:
        completeness += 10.0
    elif primary_cat or boards:
        completeness += 5.0

    desc = entity.get("description") or ""
    courses = entity.get("courses_offered") or entity.get("taxonomy", {}).get("subjects", [])
    if desc and courses:
        completeness += 10.0
    elif desc or courses:
        completeness += 5.0

    # 2. Direct Contactability (30% max)
    phones = entity.get("phones") or entity.get("normalized", {}).get("phones", [])
    emails = entity.get("emails") or entity.get("normalized", {}).get("emails", [])

    if len(phones) >= 1:
        contactability += 15.0
    if len(emails) >= 1:
        contactability += 10.0
    if len(phones) >= 2:
        contactability += 5.0

    # 3. Web & Social Freshness (20% max)
    website = entity.get("website")
    if website and str(website).strip():
        freshness += 10.0

    socials = entity.get("social_links") or []
    if socials and len(socials) > 0:
        freshness += 5.0

    days_ago = entity.get("observed_days_ago")
    if days_ago is not None and days_ago <= 60:
        freshness += 5.0

    # 4. Institutional Credibility (10% max)
    recognized_boards = {"cbse", "icse", "tbse", "ugc", "aicte", "state board", "nios"}
    found_boards = [str(b).lower() for b in boards]
    if any(any(rb in fb for rb in recognized_boards) for fb in found_boards):
        credibility += 5.0

    if entity.get("is_directory_verified") or entity.get("trust", 0) >= 60:
        credibility += 5.0

    # Cap individual subscores to their declared maximums
    completeness = min(40.0, completeness)
    contactability = min(30.0, contactability)
    freshness = min(20.0, freshness)
    credibility = min(10.0, credibility)

    total = round(completeness + contactability + freshness + credibility, 1)

    if total >= 80.0:
        tier = "tier_1_hot"
    elif total >= 50.0:
        tier = "tier_2_warm"
    else:
        tier = "tier_3_cold"

    return LeadScoreBreakdown(
        completeness_score=completeness,
        contactability_score=contactability,
        freshness_score=freshness,
        credibility_score=credibility,
        total_score=total,
        tier=tier
    )
