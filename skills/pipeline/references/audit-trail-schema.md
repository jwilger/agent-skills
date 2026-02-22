# Audit Trail Schema

Every pipeline action produces structured evidence stored in the `.factory/`
directory. This document defines the directory layout and JSON schemas for
each file type.

## Directory Layout

```
.factory/
  config.yaml                         # Autonomy level and gate configuration
  slice-queue.json                    # Queue state (see slice-queue.md)
  memory/                             # Operational learnings (pipeline memory)
  audit-trail/
    slices/<slice-id>/
      decomposition.json              # Task breakdown from task-management
      tdd-cycles/cycle-NNN.json       # Per-cycle TDD evidence
      review.json                     # Code review gate evidence
      mutation.json                   # Mutation testing gate evidence
      ci-results/run-NNN.json         # Per-run CI outcome
      rework-log.json                 # Rework attempt history
      outcome.json                    # Final slice outcome
    metrics/
      daily-summary.json              # Daily aggregate metrics
      trend.json                      # Multi-day trend data
    escalations/<timestamp>.json      # Human escalation records
    retrospectives/<pr-number>.json   # Post-merge retrospective records
```

## Slice-Level Schemas

### decomposition.json

Produced by the task-management skill at the start of each slice.

```json
{
  "slice_id": "auth-registration",
  "slice_description": "User can register with email and password",
  "created_at": "2026-02-22T10:00:00Z",
  "tasks": [
    {
      "task_id": "auth-reg-001",
      "name": "Create registration command handler",
      "acceptance_criteria": [
        "Given valid registration data, when command is processed, then UserRegistered event is stored",
        "Given a duplicate email, when command is processed, then command is rejected with a clear error"
      ],
      "dependencies": [],
      "status": "open"
    },
    {
      "task_id": "auth-reg-002",
      "name": "Add email validation domain type",
      "acceptance_criteria": [
        "Email type rejects malformed addresses at construction time",
        "Email type normalizes casing"
      ],
      "dependencies": [],
      "status": "open"
    }
  ],
  "dependency_graph": {
    "auth-reg-001": [],
    "auth-reg-002": []
  }
}
```

### tdd-cycles/cycle-NNN.json

Produced after each completed RED-GREEN-DOMAIN-COMMIT cycle.

```json
{
  "cycle_number": 1,
  "slice_id": "auth-registration",
  "timestamp": "2026-02-22T10:45:00Z",
  "pair": ["engineer-a", "engineer-b"],
  "phases": {
    "red": {
      "test_file": "tests/acceptance/registration_test.ext",
      "test_name": "test_valid_registration_stores_event",
      "failure_output": "Error: function register_user not found",
      "files_changed": ["tests/acceptance/registration_test.ext"]
    },
    "domain_after_red": {
      "verdict": "APPROVED",
      "types_created": ["src/auth/types.ext"],
      "concerns": []
    },
    "green": {
      "implementation_files": ["src/auth/handler.ext"],
      "test_output": "1 test passed, 0 failed",
      "files_changed": ["src/auth/handler.ext"]
    },
    "domain_after_green": {
      "verdict": "APPROVED",
      "review_notes": "Types are clean, validation at construction",
      "full_test_output": "1 test passed, 0 failed"
    },
    "commit": {
      "commit_hash": "abc1234",
      "commit_message": "feat(auth): registration handler stores UserRegistered event",
      "full_test_output": "1 test passed, 0 failed"
    }
  }
}
```

### review.json

Produced after the full-team code review completes (or after each re-review
during rework).

```json
{
  "slice_id": "auth-registration",
  "timestamp": "2026-02-22T12:00:00Z",
  "attempt": 1,
  "stages": {
    "spec_compliance": {
      "led_by": ["pm-agent", "domain-sme-agent"],
      "verdict": "PASS",
      "criteria_checked": 3,
      "criteria_passed": 3,
      "findings": []
    },
    "code_quality": {
      "led_by": ["engineer-c", "engineer-d"],
      "verdict": "PASS",
      "findings": [
        {
          "severity": "SUGGESTION",
          "file": "src/auth/handler.ext",
          "line": 42,
          "description": "Consider extracting validation into a helper",
          "status": "noted",
          "category": "trivial"
        }
      ]
    },
    "domain_integrity": {
      "led_by": ["domain-sme-agent"],
      "verdict": "PASS",
      "findings": []
    }
  },
  "overall": "APPROVED",
  "required_changes": []
}
```

### mutation.json

Produced after each mutation testing run.

```json
{
  "slice_id": "auth-registration",
  "timestamp": "2026-02-22T12:30:00Z",
  "attempt": 1,
  "tool": "cargo-mutants",
  "scope": ["src/auth/handler.ext", "src/auth/types.ext"],
  "results": {
    "total_mutants": 18,
    "killed": 18,
    "survived": 0,
    "timed_out": 0,
    "score": "100%"
  },
  "survivors": [],
  "gate_verdict": "PASS"
}
```

### ci-results/run-NNN.json

Produced after each CI pipeline run.

```json
{
  "slice_id": "auth-registration",
  "run_number": 1,
  "timestamp": "2026-02-22T13:00:00Z",
  "pipeline_run_id": "run-12345",
  "status": "success",
  "url": "https://ci.example.com/runs/12345",
  "duration_seconds": 142,
  "failure_classification": null,
  "failure_details": null
}
```

For a failed run:
```json
{
  "slice_id": "auth-registration",
  "run_number": 2,
  "timestamp": "2026-02-22T13:15:00Z",
  "pipeline_run_id": "run-12346",
  "status": "failure",
  "url": "https://ci.example.com/runs/12346",
  "duration_seconds": 87,
  "failure_classification": "test_failure",
  "failure_details": "tests/integration/auth_test.ext:23 -- assertion failed: expected 200, got 500"
}
```

### rework-log.json

Tracks all rework attempts for a slice. See `rework-protocol.md` for the
full schema and routing rules.

### outcome.json

Produced when a slice reaches its final state (merged, escalated, or skipped).

```json
{
  "slice_id": "auth-registration",
  "final_status": "merged",
  "timestamp": "2026-02-22T13:30:00Z",
  "merge_commit": "def5678",
  "target_branch": "main",
  "total_tdd_cycles": 3,
  "total_rework_attempts": {
    "tdd": 0,
    "review": 1,
    "mutation": 0,
    "ci": 0
  },
  "gates_passed": {
    "tdd": true,
    "review": true,
    "mutation": true,
    "ci": true,
    "merge": true
  },
  "elapsed_time_seconds": 12600,
  "escalations": []
}
```

For an escalated slice:
```json
{
  "slice_id": "auth-password-reset",
  "final_status": "escalated",
  "timestamp": "2026-02-22T16:00:00Z",
  "escalation_gate": "mutation",
  "escalation_reason": "3 rework attempts exhausted; 2 survivors persist",
  "escalation_ref": ".factory/audit-trail/escalations/2026-02-22T16-00-00Z.json",
  "total_tdd_cycles": 5,
  "total_rework_attempts": {
    "tdd": 0,
    "review": 0,
    "mutation": 3,
    "ci": 0
  }
}
```

## Aggregate Schemas

### metrics/daily-summary.json

Aggregated daily across all slices active that day.

```json
{
  "date": "2026-02-22",
  "slices_completed": 2,
  "slices_escalated": 0,
  "slices_active": 1,
  "total_tdd_cycles": 8,
  "total_rework_attempts": 1,
  "average_gate_pass_rate": {
    "tdd": 1.0,
    "review": 0.85,
    "mutation": 1.0,
    "ci": 1.0
  },
  "average_slice_duration_seconds": 10800
}
```

### metrics/trend.json

Rolling window of daily summaries for trend analysis.

```json
{
  "window_days": 7,
  "entries": [
    {
      "date": "2026-02-16",
      "slices_completed": 1,
      "average_rework_attempts": 0.5
    },
    {
      "date": "2026-02-17",
      "slices_completed": 2,
      "average_rework_attempts": 0.0
    }
  ]
}
```

### escalations/<timestamp>.json

Produced when a slice is escalated to the human.

```json
{
  "timestamp": "2026-02-22T16:00:00Z",
  "slice_id": "auth-password-reset",
  "gate": "mutation",
  "attempts": [
    {
      "attempt": 1,
      "action": "TDD pair wrote boundary test for password length check",
      "result": "Killed 1 of 2 survivors; 1 remains at line 78"
    },
    {
      "attempt": 2,
      "action": "TDD pair added test for empty password edge case",
      "result": "New test introduced; original survivor at line 78 persists"
    },
    {
      "attempt": 3,
      "action": "TDD pair refactored validation and added negative test",
      "result": "Survivor at line 78 persists; mutation replaces return value"
    }
  ],
  "current_state": {
    "branch": "slice/auth-password-reset",
    "last_commit": "fed9876",
    "passing_tests": 14,
    "mutation_score": "97%"
  },
  "recommendation": "The surviving mutant at line 78 replaces the return value of a logging side-effect. Consider whether this mutation is meaningful or if the function should be restructured to make the return value testable."
}
```

### retrospectives/<pr-number>.json

Produced after a merged PR triggers a retrospective.

```json
{
  "pr_number": 42,
  "timestamp": "2026-02-22T17:00:00Z",
  "slices_included": ["auth-registration", "auth-login"],
  "went_well": [
    "Walking skeleton established clean wiring pattern for subsequent slices",
    "Domain review caught primitive obsession early in cycle 2"
  ],
  "needs_improvement": [
    "Review gate failed on first attempt for both slices due to missing boundary tests"
  ],
  "suggestions": [
    "Add a pre-review checklist item for boundary test coverage"
  ],
  "requires_human_approval": true
}
```

## File Lifecycle Rules

- **Append-only within a slice:** Rework attempts produce new entries, not
  overwrites. The full history is preserved.
- **Immutable after slice completion:** Once `outcome.json` is written, no
  slice files are modified.
- **Queue state is mutable:** `slice-queue.json` is updated as slices move
  through states.
- **Metrics are regenerated:** Daily summary and trend files are recomputed,
  not appended to.
