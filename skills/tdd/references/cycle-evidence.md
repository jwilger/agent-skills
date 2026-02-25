# Cycle Evidence -- CYCLE_COMPLETE Packet

This reference documents the structured evidence packet that the TDD cycle
produces at the end of each complete cycle. The pipeline's TDD gate consumes
this packet to verify that a cycle completed successfully.

## Purpose

The CYCLE_COMPLETE packet provides machine-readable proof that a TDD cycle
followed the full RED-DOMAIN-GREEN-DOMAIN-COMMIT discipline. Without this
evidence, the pipeline cannot distinguish a properly completed cycle from
one that skipped phases. The packet captures what was tested, what was
reviewed, and what was committed.

## CYCLE_COMPLETE Schema

```json
{
  "slice_id": "string -- vertical slice identifier",
  "cycle_number": "number -- sequential cycle within the slice (1-indexed)",
  "acceptance_test": {
    "file": "string -- absolute path to the acceptance test file",
    "name": "string -- test function or case name",
    "output": "string -- test runner stdout (pass/fail + output)",
    "boundary_type": "string -- external boundary exercised (HTTP, CLI, message_queue, websocket, playwright_ui, manual_verification)",
    "boundary_evidence": "string -- how the test interacts with the boundary (e.g., 'sends HTTP POST to /api/commands and asserts 201 response')"
  },
  "unit_tests": {
    "count": "number -- total unit tests run",
    "all_passing": "boolean -- true if every unit test passed",
    "output": "string -- test runner stdout for full suite"
  },
  "domain_reviews": [
    {
      "phase": "string -- RED_DOMAIN or GREEN_DOMAIN",
      "verdict": "string -- approved or flagged",
      "concerns": ["string -- concern descriptions, empty if approved"]
    }
  ],
  "commits": [
    {
      "hash": "string -- git commit SHA",
      "message": "string -- commit message"
    }
  ],
  "rework_cycles": "number -- times this cycle was sent back for rework (0 if clean)",
  "team": {
    "ping": "string -- engineer name (wrote failing test for this cycle)",
    "pong": "string -- engineer name (wrote GREEN implementation for this cycle)",
    "domain_reviewer": "string -- engineer name (reviewed test and implementation)"
  }
}
```

## Field Details

### `acceptance_test`

The boundary-level test for the vertical slice. This is the outside-in test
written in the first RED phase of the slice. Its output must show a passing
result for the cycle to be considered complete.

`boundary_type` identifies which external boundary the acceptance test
exercises. Valid values: `HTTP`, `CLI`, `message_queue`, `websocket`,
`playwright_ui`, `manual_verification`. A test that calls internal functions
directly (e.g., `CommandLogic.handle()`, `service.process()`) is a unit test,
not an acceptance test -- it disqualifies as the boundary-level test even if
it asserts on user-visible behavior.

`boundary_evidence` describes how the test interacts with the external
boundary in concrete terms (e.g., "sends HTTP POST to /api/commands and
asserts 201 response", "spawns CLI process with `--create` flag and asserts
exit code 0", "connects to WebSocket at /ws/events and asserts message
received").

In standalone (non-pipeline) mode, these fields are informational. The TDD
skill text instructs the agent to fill them, but only the pipeline gate
structurally rejects missing values.

### `unit_tests`

The full unit test suite output. `all_passing` must be `true`. The `count`
field provides a sanity check -- a cycle that results in zero unit tests is
suspicious and should be flagged.

### `domain_reviews`

There are exactly two domain reviews per cycle: one after RED (reviewing the
test and any new types) and one after GREEN (reviewing the implementation for
domain violations). A `flagged` verdict with unresolved concerns means the
cycle required rework -- this is captured in `rework_cycles`.

### `commits`

One or more commits produced by the COMMIT phase. Typically one commit per
cycle, but a rework cycle may produce additional commits. Each commit hash
is a verifiable reference in git history.

### `rework_cycles`

Number of times the cycle was sent back from a domain review or quality gate.
Zero means the cycle completed cleanly on the first pass. This metric feeds
into the pipeline's rework rate calculation.

### `team`

The three members who worked the cycle. Ping writes the failing test (RED).
Pong writes the GREEN implementation. Domain reviewer reviews both the test
and the implementation. Roles swap between cycles within a slice (ping
becomes pong, pong becomes ping; domain reviewer may stay or rotate).

## When Produced

The CYCLE_COMPLETE packet is produced at the end of each complete
RED-DOMAIN-GREEN-DOMAIN-COMMIT cycle. It is NOT produced for incomplete
cycles (e.g., a RED phase that was abandoned) or for cycles that are still
in progress.

## Where Stored

```
.factory/audit-trail/slices/<slice-id>/tdd-cycles/cycle-NNN.json
```

`NNN` is zero-padded to three digits (e.g., `cycle-001.json`,
`cycle-002.json`). The slice directory is created when the first cycle
for that slice completes.

In non-factory mode (standalone TDD), the packet is not written to disk.
It exists only as structured output passed between the TDD orchestrator
and the calling agent.

## Pipeline Consumption

The pipeline's TDD gate reads CYCLE_COMPLETE packets to evaluate whether
a slice is ready to proceed:

1. **Acceptance test passes:** `acceptance_test.output` shows a passing
   result
2. **All unit tests pass:** `unit_tests.all_passing` is `true`
3. **Domain reviews approved:** Every entry in `domain_reviews` has
   `verdict: "approved"` (no unresolved `flagged` verdicts)
4. **Boundary scope verified:** `acceptance_test.boundary_type` is present
   and matches the slice's GWT boundary annotation.
   `acceptance_test.boundary_evidence` describes an external interaction
   (not a direct call to an internal function).

If any condition is not met, the TDD gate fails and the slice enters a
rework cycle. The pipeline records the gate failure in the audit trail
and routes the slice back to the TDD pair.
