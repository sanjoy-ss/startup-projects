# Skill: Normalization and Entity Resolution

## Purpose
Convert noisy observations from many sources into one canonical education entity.

## Pipeline
1. Normalize fields.
2. Generate fingerprints.
3. Generate a small candidate set.
4. Score each candidate.
5. Auto-match, review, or create new.
6. Preserve merge history.

## Normalize
Normalize at least:
- name
- phone
- email
- domain
- city
- locality
- state
- postal code
- entity type
- subjects
- classes
- boards

### Name normalization
Typical transformations:
- lowercase
- unicode normalization
- punctuation removal
- whitespace collapse
- common spelling normalization such as centre -> center
Do not remove meaningful organization words blindly.

### Phone normalization
Use phonenumbers.
Store E.164 form when valid.

### Domain normalization
Strip protocol, www and path.
Store registrable domain.

## Candidate generation
Never compare a new observation with the entire collection.

Candidate signals:
1. provider external ID
2. exact phone
3. exact domain
4. exact email
5. normalized name + city
6. close geo distance
7. fuzzy/Atlas Search candidate lookup

Limit expensive scoring to a small candidate set.

## Matching signals
Strong:
- same official external ID
- same domain
- same public phone
- same official email
- very close geo + matching name/address

Weak:
- name similarity only
- same city only
- same broad category only

Never auto-merge from name similarity alone.

## Suggested initial thresholds
- >= 0.95: auto-match only with at least one strong signal
- 0.80–0.95: manual review
- < 0.80: create a new entity

Tune thresholds using real labeled Tripura data.

## Merge rules
- Never delete source evidence.
- Preserve merge history.
- Prefer claimed/verified fields over scraped fields.
- Prefer higher-trust sources over lower-trust sources.
- Maintain aliases.
- Make merges reversible where practical.
