from discovery.frontier.query_generator import QueryGenerator

def test_query_generator_generates_search_matrices():
    gen = QueryGenerator()
    queries = gen.build_search_queries(city="Agartala", state="Tripura")
    assert len(queries) >= 5
    assert any("schools in Agartala" in q for q in queries)
    assert any("coaching" in q for q in queries)

def test_build_overpass_osm_query():
    gen = QueryGenerator()
    osm_query = gen.build_osm_overpass_query(bbox=(23.8, 91.2, 23.9, 91.3))
    assert 'amenity"="school"' in osm_query or 'amenity"~"school' in osm_query
    assert "out center;" in osm_query

def test_parse_osm_response_with_website():
    gen = QueryGenerator()
    mock_osm_json = {
        "elements": [
            {
                "type": "node",
                "id": 12345,
                "lat": 23.83,
                "lon": 91.28,
                "tags": {
                    "name": "Maharaja Bir Bikram College",
                    "amenity": "college",
                    "website": "https://mbbcollege.in"
                }
            }
        ]
    }
    items = gen.parse_osm_response(mock_osm_json)
    assert len(items) == 1
    assert items[0].url == "https://mbbcollege.in"
    assert items[0].source_type == "maps"
    assert items[0].priority == 8
