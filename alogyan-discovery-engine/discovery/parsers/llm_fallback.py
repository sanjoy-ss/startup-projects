"""Fallback parser using Trafilatura for boilerplate cleaning and Instructor LLM for structured extraction."""
import logging
import trafilatura
from bs4 import BeautifulSoup
from tenacity import retry, stop_after_attempt, wait_exponential
from discovery.models import InstructorEducationPayload


class LLMFallbackParser:
    def __init__(self, client=None, model: str = "gpt-4o-mini", api_key: str = "", base_url: str = ""):
        self.model = model
        self._client = client
        self.api_key = api_key
        self.base_url = base_url

    @property
    def client(self):
        if self._client is None:
            import instructor
            from openai import AsyncOpenAI
            kwargs = {}
            if self.api_key:
                kwargs['api_key'] = self.api_key
            if self.base_url:
                kwargs['base_url'] = self.base_url
            raw_client = AsyncOpenAI(**kwargs)
            self._client = instructor.from_openai(raw_client)
        return self._client

    def clean_markdown(self, html: str) -> str:
        """Extracts dense, readable text from HTML, stripping boilerplate."""
        try:
            soup = BeautifulSoup(html, 'html.parser')
            for tag in soup(['script', 'style', 'nav', 'footer', 'aside', 'noscript', 'svg']):
                tag.decompose()
            pruned_html = str(soup)

            extracted = trafilatura.extract(
                pruned_html,
                include_links=True,
                include_tables=True,
                output_format='txt',
                favor_recall=True
            )
            if extracted and len(extracted.strip()) > 30:
                return extracted.strip()
            return soup.get_text(separator='\n', strip=True)
        except Exception as exc:
            logging.debug("Trafilatura extraction warning: %s", exc)

        soup = BeautifulSoup(html, 'html.parser')
        for tag in soup(['script', 'style', 'nav', 'footer', 'aside', 'noscript', 'svg']):
            tag.decompose()
        return soup.get_text(separator=' ', strip=True)

    @retry(
        reraise=True,
        stop=stop_after_attempt(3),
        wait=wait_exponential(multiplier=1, min=2, max=10)
    )
    async def parse(self, html: str, url: str = "") -> InstructorEducationPayload:
        clean_text = self.clean_markdown(html)
        # Truncate to ~4,000 tokens / 12,000 characters
        truncated_text = clean_text[:12000]

        prompt = f"""
        Extract educational institution details from the following web page content.
        Source URL: {url}
        Page Content:
        {truncated_text}
        """

        result = await self.client.chat.completions.create(
            model=self.model,
            response_model=InstructorEducationPayload,
            messages=[
                {
                    "role": "system",
                    "content": (
                        "You are an expert educational data extractor for Alogyan Discovery Engine. "
                        "Extract official name, contact numbers, emails, location hierarchy (locality, landmark, city, state, pin), "
                        "educational categories (school/college/coaching), board affiliations, and confidence score."
                    )
                },
                {"role": "user", "content": prompt}
            ]
        )
        if url and not result.website:
            result.website = url
        return result
