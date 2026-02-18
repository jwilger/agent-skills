# Evaluation Framework

Measure whether the team structure produces better outcomes than simpler
configurations. Without evaluation, the ensemble is ceremony for its own sake.

## Baseline Comparison

Run at least one vertical slice with the full ensemble team AND one with a
minimal configuration (2 engineers only, no consensus protocol). Compare:

| Metric | How to measure | Where logged |
|--------|---------------|--------------|
| Test quality | Mutation score (e.g., mutmut, cargo-mutants, stryker) | `.team/eval-results.md` |
| Domain model richness | Named type count, primitive obsession violations found in review | `.team/eval-results.md` |
| Defect rate | Issues found during code review that require rework | `.team/eval-results.md` |
| Cycle time | Wall-clock time from slice start to passing tests | `.team/eval-results.md` |

Document both runs in `.team/eval-results.md` with raw numbers and a brief
analysis. If the full team does not measurably improve at least two of the
four metrics, revisit team composition or protocol overhead.

## Persona Fidelity Scoring

After profile generation (Phase 3), run an LLM-as-judge pass:

1. **Identification test**: Present each profile (with name redacted) to a
   judge LLM. Can it identify which expert the profile represents from the
   text alone? Score: correct/incorrect per profile.

2. **Distinctiveness test**: Present pairs of profiles to the judge. Are they
   meaningfully distinct? Could swapping them change team behavior? Score:
   0-1 distinctiveness rating per pair.

3. **Threshold**: If the judge cannot identify >75% of profiles, or if >25%
   of pairs score below 0.5 distinctiveness, the research step needs rework.
   Profiles that are interchangeable add cost without adding perspective.

Log results alongside the profiles in `.team/eval-results.md`.

## Decision Quality Tracking

Log every consensus decision in `.team/decision-log.json`:

```json
{
  "decisions": [
    {
      "date": "2026-02-18",
      "motion": "Use PostgreSQL for persistence",
      "category": "standard",
      "rounds_used": 2,
      "consent": 7,
      "stand_aside": 1,
      "object": 0,
      "stand_aside_details": ["Yegge: prefers SQLite for prototyping phase"],
      "outcome": "adopted",
      "revisited": false
    }
  ]
}
```

**Tokens-per-decision**: Track total tokens consumed across all agents for each
motion, from proposal to resolution. Add a `"tokens_used"` field to each
decision entry. Flag any decision where tokens-per-decision exceeds 2x the
tier's expected per-round cost (e.g., >20K for solo-plus, >50K for lean, >100K
for full). These outliers indicate either a genuinely complex decision or an
inefficient discussion that could have been resolved faster. Review flagged
decisions in retrospectives to distinguish the two cases.

**Pattern flags** (check after every 10 decisions):

- **Too homogeneous**: >80% of decisions resolve in round 1 with 0 objections.
  The team may be echo-chambering. Consider adding a contrarian role or
  adjusting persona prompts to emphasize distinctive viewpoints.
- **Persistent stand-asides**: Same member stands aside on >50% of decisions
  in a category. Their expertise may not align with their assigned role, or
  the team may be systematically underweighting their perspective.
- **Excessive escalation**: >20% of decisions escalate to the human. The
  protocol may be too strict, or team composition may have irreconcilable
  tensions. Consider reducing team size or adjusting quorum rules.

## Retrospective Metrics

Feed these into the post-PR retrospective (referenced from TEAM_AGREEMENTS.md):

| Metric | What it reveals |
|--------|----------------|
| Pairing diversity | Number of unique driver/reviewer pairings used. Low diversity suggests role rigidity. |
| Stand-aside frequency by role | Which roles are consistently outvoted. May indicate a missing perspective or miscast role. |
| Escalation frequency | How often the team cannot self-resolve. Target: <10% of decisions. |
| Decision reversal rate | How often adopted motions are later reconsidered. High rate suggests premature consensus. |

Track these per-sprint or per-PR, whichever is the natural work boundary.
Trends matter more than absolute numbers.
