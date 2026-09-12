from discovery.resolution import resolve_entity_match

def test_exact_phone_match_auto_merges():
    candidate = {
        "_id": "ent_1",
        "phones": ["+919862012345"],
        "name": "Bhavan's Tripura Vidya Mandir",
        "city": "Agartala",
        "category": "k12_school"
    }
    observation = {
        "phones": ["+919862012345"],
        "name": "Bhavan's Tripura Vidya Mandir",
        "city": "Agartala",
        "category": "k12_school"
    }
    decision, matched_id = resolve_entity_match(observation, [candidate])
    assert decision == "auto_merge"
    assert matched_id == "ent_1"

def test_high_similarity_routes_to_review():
    candidate = {
        "_id": "ent_2",
        "phones": ["+919862099999"],
        "name": "St. Johns School",
        "city": "Agartala",
        "category": "k12_school"
    }
    observation = {
        "phones": ["+919862088888"],
        "name": "St. Johns Senior Secondary School",
        "city": "Agartala",
        "category": "k12_school"
    }
    decision, _ = resolve_entity_match(observation, [candidate])
    assert decision == "review_queue"

def test_dissimilar_creates_new():
    candidate = {
        "_id": "ent_3",
        "phones": ["+919862011111"],
        "name": "Holy Cross School",
        "city": "Agartala",
        "category": "k12_school"
    }
    observation = {
        "phones": ["+919862022222"],
        "name": "Don Bosco Academy",
        "city": "Agartala",
        "category": "k12_school"
    }
    decision, matched_id = resolve_entity_match(observation, [candidate])
    assert decision == "create_new"
    assert matched_id is None
