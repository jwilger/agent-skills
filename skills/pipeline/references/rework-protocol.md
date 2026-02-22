# Rework Protocol

When a quality gate fails, the pipeline routes the slice back to the
appropriate skill for correction. This document defines the routing rules,
rework budgets, tracking requirements, and escalation procedure.

## Routing Rules

Each gate failure maps to a specific rework action. The pipeline does not
guess -- it follows the routing table.

### TDD Gate Failure

**Trigger:** Acceptance test fails, unit tests fail, or domain review raised
unresolved concerns.

**Route to:** TDD pair.

**Context provided:**
- Failing test output (full stderr/stdout)
- Domain review concerns (if applicable)
- Which phase failed (RED test was wrong, GREEN implementation was wrong,
  DOMAIN review raised a veto)
- Files changed in the current slice

**Expected outcome:** TDD pair resumes from the failing phase, fixes the
issue, completes the cycle through COMMIT. The pipeline re-evaluates the
TDD gate with fresh evidence.

### Review Gate Failure

**Trigger:** Any review stage produced a FAIL or CHANGES REQUIRED verdict.

**Route to:** TDD pair with the full findings list.

**Context provided:**
- Per-stage verdicts (spec compliance, code quality, domain integrity)
- Each finding with severity, file, line, description
- Required changes (only CRITICAL and IMPORTANT findings require action;
  SUGGESTION findings are informational)

**Expected outcome:** TDD pair addresses findings via their ping-pong
process. After fixes, the pipeline triggers a scoped re-review: only the
failing stage and subsequent stages are re-evaluated. The original reviewers
re-review their specific flagged concerns.

### Mutation Gate Failure

**Trigger:** Mutation kill rate is below 100%.

**Route to:** TDD pair with the survivor list.

**Context provided:**
- Each surviving mutant: file, line, mutation type, description
- Recommended test for each survivor
- Current mutation score

**Expected outcome:** TDD pair writes the missing tests (following TDD
discipline: RED then GREEN). The pipeline re-runs mutation testing on the
same file scope. New tests must kill all survivors without introducing new
ones.

### CI Gate Failure

**Trigger:** CI pipeline run completed with a non-success status.

**Failure classification determines routing:**

| Classification | Route | Action |
|---------------|-------|--------|
| Test failure | TDD pair | Fix failing tests; counts against TDD gate budget |
| Infrastructure failure | Pipeline auto-retry (standard/full) or human (conservative) | Retry the CI run |
| Configuration failure | ci-integration skill | Triage and fix CI config |
| Lint/format failure | TDD pair | Apply formatter/linter fixes |

**Context provided (all classifications):**
- CI run output (full log or relevant excerpt)
- Failure classification
- Failing step name and output

**Expected outcome:** Depends on classification. Test failures go through
the full TDD rework cycle. Infrastructure failures are retried. Config
failures are triaged by the ci-integration skill.

## Rework Budget

Each gate allows a maximum of **3 rework cycles** per slice. The budget is
tracked per gate, not globally.

**Budget accounting:**
- Each time a gate fails and work is routed back, the cycle counter for that
  gate increments by 1.
- CI test failures count against the TDD gate budget (since the fix goes
  through TDD), not a separate CI budget.
- Infrastructure retries do not count against any rework budget.
- A gate that passes on rework attempt N resets nothing -- the counter is
  preserved in the audit trail for retrospective analysis.

**Budget exhaustion procedure:**

When a gate reaches 3 failures for a given slice:

1. **Halt the slice.** Do not attempt further rework.
2. **Compile full context:**
   - All rework attempt evidence (3 failed attempts with their outputs)
   - Original slice definition and acceptance criteria
   - Current state of the code (branch, last commit)
   - What was tried in each attempt and why it failed
3. **Escalate to human** with a structured summary:
   ```
   ESCALATION: Slice <slice-id> failed <gate-name> gate 3 times

   Slice: <description>
   Gate: <gate-name>

   Attempt 1: <what was tried> -> <why it failed>
   Attempt 2: <what was tried> -> <why it failed>
   Attempt 3: <what was tried> -> <why it failed>

   Current state: <branch name, last commit hash>
   Recommendation: <pipeline's assessment of the root cause>
   ```
4. **Mark slice as "escalated"** in the queue. The pipeline moves to the
   next unblocked slice (if any).

## Rework Tracking

Every rework attempt is logged in:
```
.factory/audit-trail/slices/<slice-id>/rework-log.json
```

**Schema:**
```json
{
  "slice_id": "auth-registration",
  "rework_entries": [
    {
      "gate": "review",
      "attempt": 1,
      "timestamp": "2026-02-22T14:30:00Z",
      "trigger": {
        "stage": "code_quality",
        "findings": [
          {
            "severity": "CRITICAL",
            "file": "src/auth/handler.ext",
            "line": 42,
            "description": "Unchecked error return from database call"
          }
        ]
      },
      "action_taken": "Routed to TDD pair with findings list",
      "outcome": "Fixed -- added error handling, re-review passed"
    },
    {
      "gate": "mutation",
      "attempt": 1,
      "timestamp": "2026-02-22T15:10:00Z",
      "trigger": {
        "survivors": [
          {
            "file": "src/auth/handler.ext",
            "line": 55,
            "mutation": "replaced > with >=",
            "recommended_test": "Test exact boundary for max login attempts"
          }
        ],
        "score": "95%"
      },
      "action_taken": "Routed to TDD pair with survivor list",
      "outcome": "Fixed -- added boundary test, mutation score now 100%"
    }
  ]
}
```

## Rework Does Not Reset Quality

When rework fixes one gate, subsequent gates must still be re-evaluated:

- TDD rework -> re-run review (scoped to changed code), mutation, CI
- Review rework -> re-run mutation (if code changed), CI
- Mutation rework -> re-run CI (new tests may affect CI)
- CI rework -> re-run merge check (branch may need rebase)

The pipeline tracks which gates need re-evaluation after each rework and
runs them in order. A gate that previously passed is re-run only if the
rework could have affected its evidence.
