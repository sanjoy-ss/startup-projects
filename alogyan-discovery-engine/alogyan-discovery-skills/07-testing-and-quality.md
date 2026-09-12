# Skill: Testing and Data Quality

## Purpose
Prevent bad crawls and false merges from corrupting canonical education data.

## Test layers

### Unit tests
Test:
- name normalization
- phone normalization
- domain normalization
- fingerprint generation
- duplicate scoring
- semantic hash
- projector output

### Source fixture tests
Save representative HTML/API fixtures.
Run extraction against fixtures instead of live websites during normal tests.

### Entity-resolution fixtures
Maintain labeled pairs:
- same_entity=true
- same_entity=false

Examples should include:
- spelling differences
- branches
- shared phone numbers
- renamed institutes
- schools with similar names
- tutors working at institutions

## Quality metrics
Track:
- percentage of observations matched
- new entity rate
- manual-review rate
- false-merge rate
- duplicate creation rate
- records missing location
- records missing contact
- records missing source provenance

## Golden rule
False merges are more damaging than duplicate records.
When uncertain, create a review candidate instead of auto-merging.

## Production checks
Before expanding from Agartala:
- manually inspect at least 100–200 entities
- review high-score and borderline matches
- verify location normalization
- verify source provenance
- verify search ranking
