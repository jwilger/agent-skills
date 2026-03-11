# Handoff Schema -- Structural Evidence Requirements

Every phase transition requires specific evidence fields. Missing fields
block the handoff. This is structural enforcement -- the absence of
evidence is itself a signal that the phase was not completed correctly.

## RED -> DOMAIN Handoff

Required fields:

| Field | Description |
|-------|-------------|
| `test_file` | Absolute path to the test file created or modified |
| `test_name` | Name of the specific test function or case |
| `failure_output` | Actual test runner output, pasted verbatim |

`failure_output` must be real output from the test runner. "I expect it
to fail" or "the test should fail" is not evidence. Compilation errors
are valid failure output.

## DOMAIN (post-RED) -> GREEN Handoff

Required fields:

| Field | Description |
|-------|-------------|
| `domain_review` | `APPROVED` or `REVISED` (with explanation of revision) |
| `type_files_created` | List of type definition files created or modified (may be empty if no new types needed) |

If `domain_review` is `REVISED`, the revision explanation must include
what was changed and why. The RED agent must re-run the test and provide
updated failure output before the handoff proceeds.

## GREEN -> DOMAIN (post-GREEN) Handoff

Required fields:

| Field | Description |
|-------|-------------|
| `implementation_files` | List of production files created or modified |
| `test_output` | Actual test runner output showing the test now passes |

`test_output` must show the specific test passing. "Tests should pass
now" is not evidence.

## DOMAIN (post-GREEN) -> COMMIT Handoff

Required fields:

| Field | Description |
|-------|-------------|
| `review` | `APPROVED` or `CONCERN_RAISED` (with specific concern and proposed alternative) |
| `full_test_output` | Full test suite output, not just the single test |

If `review` is `CONCERN_RAISED`, the concern must be resolved before
proceeding to COMMIT. The implementation is revised via the GREEN phase,
then domain reviews again.

## GREEN -> DRILL_DOWN Handoff

Alternative to GREEN -> DOMAIN when the scope check determines the needed
change is larger than function-scope. Instead of implementing, the GREEN
agent writes a failing unit test and returns this evidence.

Required fields:

| Field | Description |
|-------|-------------|
| `drill_down` | Must be `true` |
| `outer_test` | Path to the test that is still failing |
| `outer_error` | The error message that triggered the scope check |
| `inner_test_file` | Path to the new failing unit test written by the GREEN agent |
| `inner_test_name` | Name of the new test function |
| `inner_failure_output` | Actual test runner output showing the inner test fails |
| `rationale` | Why drill-down was needed (one sentence) |

The orchestrator routes the inner test through a standard TDD cycle with
swapped roles: the agent who wrote the inner test (GREEN/pong at outer level)
becomes the RED/ping at inner level. The other engineer (RED/ping at outer
level) implements the inner test as GREEN/pong at inner level. Domain review
applies at the inner level too.

When the inner cycle commits, the orchestrator pops back to the outer level
and re-runs the outer test. The next error (if any) goes through the same
scope check.

## Enforcement by Mode

**Automated mode (subagents):** The orchestrator checks returned evidence
against this schema before spawning the next phase agent. A missing field
means the orchestrator re-prompts the current agent for the missing
evidence. When using named personas, the orchestrator passes these evidence
fields as context in the next subagent's prompt.

**Guided mode:** The skill text prompts the user to provide this
evidence at each phase transition. The user is responsible for verifying
completeness before advancing.

**Chaining mode:** The agent self-checks against this schema before
switching roles to the next phase.
