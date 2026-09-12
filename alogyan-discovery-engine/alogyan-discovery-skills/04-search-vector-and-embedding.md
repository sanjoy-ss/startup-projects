# Skill: Search, Vector Retrieval and Embeddings

## Purpose
Provide fast lexical, filtered and semantic discovery without using embeddings for everything.

## Read model
All search-oriented data belongs in discovery_profiles.

Suggested fields:
- canonicalId
- slug
- entityType
- name
- aliases
- searchText
- location
- taxonomy
- pricing summary
- verification
- ranking
- ai.semanticText
- ai.semanticHash
- ai.embedding
- ai.embeddingModel
- ai.embeddingVersion
- status
- updatedAt

## Search strategy
Use three mechanisms:

### MongoDB indexes
For exact filtering/sorting:
- entityType
- city
- status
- subject
- ranking
- geo

### Atlas Search
For:
- text search
- autocomplete
- fuzzy lexical matching
- facets

### Atlas Vector Search
For:
- natural-language semantic retrieval
- difficult entity similarity cases
- recommendations later

## Hybrid retrieval
Do not use vector search alone for structured queries.

Example:
"math tutor in Agartala for class 10"

Parse:
- entityType=tutor
- city=agartala
- subject=mathematics
- class=10
- semantic intent="math tutor"

Apply filters first, then lexical/vector ranking.

## Embedding generation
Build controlled semantic text from canonical fields.
Do not embed raw MongoDB JSON.

Example semantic fields:
- name
- type
- description
- subjects
- classes
- boards
- teaching mode
- specialization
- locality/city

## semanticHash
Hash only semantic fields.
If semanticHash is unchanged, do not regenerate the embedding.

## Batch behavior
Embeddings are generated after canonical entity resolution.
Do not embed raw duplicate observations.

## Ranking
Final public rank should combine:
- text relevance
- semantic relevance
- location relevance
- verification
- completeness
- freshness
- trust
- engagement/popularity

Start rule-based.
Do not build ML ranking until you have real click/conversion data.
