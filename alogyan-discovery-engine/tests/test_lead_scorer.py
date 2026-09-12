from discovery.scoring.lead_scorer import calculate_lead_score

def test_lead_score_calculation_hot_lead():
    entity = {
        "coordinates": {"latitude": 23.83, "longitude": 91.28},
        "geo_local": {"locality": "Banamalipur", "city": "Agartala", "pincode": "799001"},
        "categories": {"primary_category": "k12_school", "curriculum_boards": ["CBSE"]},
        "description": "Premier CBSE institution established in 1990",
        "courses_offered": ["Science", "Commerce", "Arts"],
        "phones": ["+919862012345", "+913812345678"],
        "emails": ["info@school.edu.in"],
        "website": "https://school.edu.in",
        "social_links": ["https://facebook.com/school"],
        "observed_days_ago": 10,
        "is_directory_verified": True
    }
    score = calculate_lead_score(entity)
    assert score.total_score >= 80.0
    assert score.tier == "tier_1_hot"
    assert score.completeness_score == 40.0
    assert score.contactability_score == 30.0

def test_lead_score_cold_lead_on_sparse_data():
    sparse_entity = {
        "name": "Some Coaching Centre",
        "geo_local": {"city": "Agartala"}
    }
    score = calculate_lead_score(sparse_entity)
    assert score.total_score < 50.0
    assert score.tier == "tier_3_cold"
