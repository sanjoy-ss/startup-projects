"""Conservative resolution of an already bounded, indexed candidate set."""
from dataclasses import dataclass
from rapidfuzz.fuzz import token_sort_ratio, token_set_ratio, ratio


@dataclass(frozen=True)
class Decision:
    action: str  # match, review, create
    canonicalId: str | None = None
    reason: str = ''
    candidates: tuple[str, ...] = ()


def resolve_entity_match(incoming: dict, candidates: list[dict], mapped_id: str | None = None) -> tuple[str, str | None]:
    """
    Evaluates incoming observation against candidates.
    Returns: (decision, matched_canonical_id)
      - decision: 'auto_merge' | 'review_queue' | 'create_new'
    """
    if mapped_id:
        return "auto_merge", mapped_id

    inc_name = incoming.get("name", "")
    inc_phones = set(incoming.get("phones", []) or incoming.get("normalized", {}).get("phones", []))
    inc_domains = set([incoming.get("domain")] if incoming.get("domain") else incoming.get("normalized", {}).get("domains", []))

    plausible_candidates = []
    auto_merge_candidate = None

    for cand in candidates:
        cand_id = cand.get("_id") or cand.get("canonicalId")
        cand_name = cand.get("name", "") or cand.get("normalizedName", "")
        cand_phones = set(cand.get("phones", []) or cand.get("normalized", {}).get("phones", []))
        cand_domains = set([cand.get("domain")] if cand.get("domain") else cand.get("normalized", {}).get("domains", []))

        # Check phone and domain signals
        shared_phones = inc_phones & cand_phones
        shared_domains = inc_domains & cand_domains
        has_signal = bool(shared_phones or shared_domains)

        # Name similarity using both sort and set ratios to catch appended qualifiers (e.g. Senior Secondary)
        sort_sim = token_sort_ratio(inc_name.lower(), cand_name.lower()) / 100.0
        set_sim = token_set_ratio(inc_name.lower(), cand_name.lower()) / 100.0
        sim = max(sort_sim, set_sim)

        if has_signal and sim >= 0.75:
            auto_merge_candidate = cand_id
            break

        # Auto-merge only if pure token_sort_ratio is very high (to prevent partial subset auto-merges)
        if sort_sim >= 0.95:
            auto_merge_candidate = cand_id
            break

        if has_signal or sim >= 0.80:
            plausible_candidates.append(cand_id)

    if auto_merge_candidate:
        return "auto_merge", auto_merge_candidate

    if plausible_candidates:
        return "review_queue", None

    return "create_new", None


def decide(incoming: dict, candidates: list[dict], mapped_id: str | None = None,
           saturated: bool = False) -> Decision:
    if mapped_id:
        return Decision('match', mapped_id, 'existing source identity')
    plausible = []
    strong_matches = []
    for candidate in candidates:
        signals = sum(bool(set(incoming['normalized'][field]) &
                           set(candidate.get('normalized', {}).get(field, [])))
                      for field in ('phones', 'domains', 'emails'))
        similarity = ratio(incoming['normalizedName'], candidate['normalizedName']) / 100
        city = incoming['location']['cityKey']
        same_city = bool(city) and city == candidate['location'].get('cityKey')
        same_type = incoming['entityType'] == candidate['entityType']
        # Shared chain domains/phones do not collapse branches or employed tutors.
        conflict = any(incoming['location'].get(k) and candidate['location'].get(k)
                       and incoming['location'][k] != candidate['location'][k]
                       for k in ('cityKey', 'localityKey', 'postalCode'))
        if signals or (same_city and same_type and similarity >= .80):
            plausible.append(candidate['_id'])
        branch_evidence = any(incoming['location'].get(k) and incoming['location'][k] == candidate['location'].get(k)
                              for k in ('localityKey', 'postalCode'))
        if signals and same_city and same_type and branch_evidence and not conflict and similarity >= .95:
            strong_matches.append(candidate['_id'])
    if saturated:
        return Decision('review', reason='candidate limit reached', candidates=tuple(plausible))
    if len(strong_matches) == 1 and len(plausible) == 1:
        return Decision('match', strong_matches[0], 'strong exact signal and compatible name/location')
    if plausible:
        return Decision('review', reason='ambiguous identity or branch; human review required',
                        candidates=tuple(plausible))
    return Decision('create', reason='no compatible candidate')
