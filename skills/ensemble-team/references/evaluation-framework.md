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
| Pairing diversity | Number of unique driver/navigator pairings used. Low diversity suggests role rigidity. |
| Stand-aside frequency by role | Which roles are consistently outvoted. May indicate a missing perspective or miscast role. |
| Escalation frequency | How often the team cannot self-resolve. Target: <10% of decisions. |
| Decision reversal rate | How often adopted motions are later reconsidered. High rate suggests premature consensus. |

Track these per-sprint or per-PR, whichever is the natural work boundary.
Trends matter more than absolute numbers.

## Factory Mode Metrics

These metrics apply only when the `pipeline` skill is installed and factory mode is
active. They measure pipeline efficiency and compare quality outcomes against
supervised mode.

### Pipeline Efficiency

| Metric | How to measure | Where logged |
|--------|---------------|--------------|
| Slices completed per session | Count of slices merged in a single pipeline run | `.team/eval-results.md` |
| Average cycle time per slice | Wall-clock time from first TDD cycle to merge | `.team/eval-results.md` |
| Rework rate | Rework cycles / total gate evaluations | `.team/eval-results.md` |
| Gate failure distribution | Count of failures per gate type (test, mutation, review, CI) | `.team/eval-results.md` |
| Escalation rate | Escalations / total slices processed | `.team/eval-results.md` |
| Auto-merge success rate | Slices merged without human intervention (at standard/full autonomy) | `.team/eval-results.md` |

### Quality Comparison: Factory vs. Supervised

Compare factory mode runs against supervised mode runs using the same baseline
metrics (mutation score, domain model richness, defect rate, cycle time). Add:

| Metric | What it reveals |
|--------|----------------|
| Human intervention frequency | How often the human is pulled in. Lower is better if quality holds. |
| Coordination token overhead | Total tokens spent on coordination vs. implementation. Factory mode should reduce this. |

Document both modes in `.team/eval-results.md` with raw numbers and analysis. If
factory mode does not reduce coordination overhead while maintaining quality parity,
revisit the autonomy configuration or gate thresholds.

### Pattern Flags for Factory Mode

Check after every 5 pipeline runs:

- **High rework rate on a specific gate** (>50% of slices need rework at the same
  gate): The gate threshold may be miscalibrated, or the team needs stronger
  guidance in that area. Review the gate's criteria and adjust.
- **Escalation clustering**: Multiple escalations on similar issues suggest a
  systematic gap — a missing team agreement, unclear domain rule, or architectural
  ambiguity. Address the root cause rather than resolving escalations one by one.
- **Review rubber-stamping**: Pre-push reviews consistently pass without findings.
  The review stage may have become ceremonial. Rotate reviewers, increase review
  scope, or add spot-check audits.
- **Pair stagnation**: Same pairs are repeatedly assigned despite rotation policy.
  Check pairing history and ensure the pipeline is respecting `.team/pairing-history.json`.
