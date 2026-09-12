import pytest
from unittest.mock import AsyncMock, MagicMock
from discovery.parsers.llm_fallback import LLMFallbackParser
from discovery.models import InstructorEducationPayload, EducationalCategories, GeoLocalHierarchy

@pytest.mark.asyncio
async def test_trafilatura_clean_and_mocked_instructor():
    mock_client = MagicMock()
    mock_payload = InstructorEducationPayload(
        name="Netaji Subhash Academy",
        entity_type="private_school",
        categories=EducationalCategories(primary_category="k12_school"),
        geo_local=GeoLocalHierarchy(city="Agartala", state="Tripura"),
        phones=["+919862000000"],
        confidence_assessment=0.92
    )

    # In instructor async, client.chat.completions.create is an async function
    mock_client.chat = MagicMock()
    mock_client.chat.completions = MagicMock()
    mock_client.chat.completions.create = AsyncMock(return_value=mock_payload)

    parser = LLMFallbackParser(client=mock_client, model="gpt-4o-mini")
    html = """
    <html>
      <nav>Main Navigation Links</nav>
      <body>
        <h1>Netaji Subhash Academy</h1>
        <p>Premier institution in Agartala, Tripura.</p>
        <p>Contact us: +91 9862000000</p>
      </body>
      <footer>Copyright 2026</footer>
    </html>
    """
    clean_txt = parser.clean_markdown(html)
    assert "Netaji Subhash Academy" in clean_txt
    assert "Main Navigation Links" not in clean_txt  # Trafilatura strips boilerplate

    result = await parser.parse(html, url="https://netaji-academy.edu.in")
    assert result.name == "Netaji Subhash Academy"
    assert result.phones == ["+919862000000"]
    assert result.confidence_assessment == 0.92
