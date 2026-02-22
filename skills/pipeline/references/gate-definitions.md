# Quality Gate Definitions

Five binary quality gates govern slice progression through the pipeline. Each
gate has explicit pass criteria, required evidence, failure routing, and a
rework budget. No gate may be skipped or softened.

## Gate 1: TDD

**Focus:** The implementation is correct and domain-sound.

**Pass criteria (all must be true):**
- Acceptance test exists and passes
- Acceptance test exercises the application boundary (`boundary_type` present,
  `boundary_evidence` describes external interaction)
- All unit tests pass
- Domain review approved (no unresolved REVISED or CONCERN_RAISED verdicts)
- Commit exists for every completed red-green cycle

**Required evidence:**
```json
{
  "gate": "tdd",
  "acceptance_test": {
    "file": "tests/acceptance/slice_name_test.ext",
    "status": "pass",
    "output_summary": "1 test passed",
    "boundary_type": "HTTP",
    "boundary_evidence": "sends HTTP POST to /api/commands and asserts 201 response"
  },
  "unit_tests": {
    "count": 7,
    "status": "pass",
    "output_summary": "7 tests passed, 0 failed"
  },
  "domain_reviews": [
    {
      "cycle": 1,
      "verdict": "APPROVED",
      "concerns": []
    }
  ],
  "commits": [
    "abc1234",
    "def5678"
  ]
}
```

**Boundary validation rule:** Missing or empty `boundary_type` = gate FAIL.
A `boundary_type` that describes only internal function calls (e.g., calling
a handler or service method directly without going through an external
boundary) = gate FAIL. The `boundary_evidence` field must describe a
concrete external interaction (HTTP request, CLI invocation, message
published, browser action, etc.).

**Failure routing:** Back to the TDD pair with the failing test output and
domain review concerns. The pair resumes from the failing phase (RED if the
test is wrong, GREEN if the implementation is wrong, DOMAIN if review raised
concerns).

**Rework budget:** 3 cycles.

## Gate 2: Review

**Focus:** The code meets spec, is maintainable, and respects domain boundaries.

**Pass criteria (all must be true):**
- Stage 1 (Spec Compliance): PASS -- every acceptance criterion mapped to code
  and tests, no FAIL or unresolved CONCERN items
- Stage 2 (Code Quality): PASS -- no CRITICAL findings, all IMPORTANT findings
  addressed
- Stage 3 (Domain Integrity): PASS -- no domain boundary violations flagged as
  blocking

**Required evidence:**
```json
{
  "gate": "review",
  "stages": {
    "spec_compliance": {
      "verdict": "PASS",
      "criteria_checked": 4,
      "criteria_passed": 4,
      "findings": []
    },
    "code_quality": {
      "verdict": "PASS",
      "findings": [
        {
          "severity": "SUGGESTION",
          "file": "src/auth/handler.ext",
          "line": 42,
          "description": "Consider extracting validation into a separate function",
          "status": "noted"
        }
      ]
    },
    "domain_integrity": {
      "verdict": "PASS",
      "findings": []
    }
  },
  "overall": "APPROVED",
  "required_changes": []
}
```

**Failure routing:** Back to the TDD pair with the full findings list.
The pair addresses findings via their ping-pong process. After fixes, only
the failing stage and subsequent stages are re-reviewed. If the failure was
in Stage 1, all three stages re-run. If Stage 2, only Stages 2 and 3. If
Stage 3, only Stage 3.

**Rework budget:** 3 cycles.

## Gate 3: Mutation

**Focus:** Tests actually detect the bugs they claim to prevent.

**Pass criteria:**
- Mutation kill rate is exactly 100% on changed files
- All surviving mutants are zero

**Required evidence:**
```json
{
  "gate": "mutation",
  "tool": "cargo-mutants",
  "scope": ["src/auth/handler.rs", "src/auth/types.rs"],
  "results": {
    "total_mutants": 23,
    "killed": 23,
    "survived": 0,
    "timed_out": 0,
    "score": "100%"
  },
  "survivors": []
}
```

**Failure routing:** Back to the TDD pair with the survivor list. Each
survivor includes file, line, mutation type, and a recommended test. The
pair writes the missing tests, then mutation testing re-runs on the same
scope.

**Rework budget:** 3 cycles.

## Gate 4: CI

**Focus:** The full CI pipeline passes on the pushed branch.

**Pass criteria:**
- CI pipeline run completes with status "success"

**Required evidence:**
```json
{
  "gate": "ci",
  "pipeline_run_id": "run-12345",
  "status": "success",
  "url": "https://ci.example.com/runs/12345",
  "duration_seconds": 142
}
```

**Failure classification and routing:**
- **Test failure:** Route back to TDD pair. The CI failure output identifies
  which tests failed. This counts against the TDD gate rework budget, not
  a separate CI budget.
- **Infrastructure failure** (network, runner crash, timeout): At standard
  or full autonomy, auto-retry once. At conservative autonomy, notify human.
- **Configuration failure** (missing env var, wrong runner image): Route to
  ci-integration for triage.
- **Linting/formatting failure:** Route to TDD pair with the linter output.

**Rework budget:** 3 cycles (test failures count against TDD gate budget).

## Gate 5: Merge

**Focus:** All upstream gates passed and the branch is safe to merge.

**Pass criteria (all must be true):**
- TDD gate: PASS
- Review gate: PASS
- Mutation gate: PASS
- CI gate: PASS
- No blocking escalations pending for this slice
- Branch is up to date with the target branch (no merge conflicts)

**Required evidence:**
```json
{
  "gate": "merge",
  "upstream_gates": {
    "tdd": "PASS",
    "review": "PASS",
    "mutation": "PASS",
    "ci": "PASS"
  },
  "blocking_escalations": [],
  "branch_status": "up_to_date",
  "merge_conflicts": false
}
```

**Failure routing:**
- If an upstream gate shows FAIL, the slice cannot have reached the merge
  gate -- this indicates a pipeline sequencing error.
- If the branch has merge conflicts, rebase onto the target branch and
  re-run CI gate (re-running upstream gates only if the rebase introduced
  non-trivial changes).
- If a blocking escalation is pending, halt until the human resolves it.

**Rework budget:** Not applicable. Merge gate failures are resolved by
fixing upstream issues or rebasing.

## Evidence Storage

All gate evidence is stored in the audit trail:
```
.factory/audit-trail/slices/<slice-id>/
  tdd-cycles/cycle-NNN.json   # TDD gate evidence (per cycle)
  review.json                  # Review gate evidence
  mutation.json                # Mutation gate evidence
  ci-results/run-NNN.json     # CI gate evidence (per run)
  outcome.json                 # Merge gate evidence + final outcome
```

Each evidence file is append-only within a slice. Rework attempts produce
new entries, not overwrites, so the full history of attempts is preserved.
