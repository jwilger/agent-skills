# Handoff Schema -- Evidence Required at Phase Transitions

Every phase transition requires specific evidence. Missing evidence
means the phase was not completed correctly. Do not advance to the
next phase until all required fields are present.

## RED -> DOMAIN Handoff

Required fields:

| Field | Description |
|-------|-------------|
| `test_file` | Path to the test file created or modified |
| `test_name` | Name of the specific test function or case |
| `failure_output` | Actual test runner output, pasted verbatim |

`failure_output` must be real output from the test runner. "I expect it
to fail" or "the test should fail" is not evidence. Compilation errors
are valid failure output.

## DOMAIN (post-RED) -> GREEN Handoff

Required fields:

| Field | Description |
|-------|-------------|
| `domain_review` | `APPROVED` or `REVISED` (with explanation) |
| `type_files_created` | List of type definition files created or modified (may be empty if no new types needed) |

If `domain_review` is `REVISED`, the revision explanation must include
what was changed and why. The test must be re-run and updated failure
output provided before proceeding.

## GREEN -> DOMAIN (post-GREEN) Handoff

Required fields:

| Field | Description |
|-------|-------------|
| `implementation_files` | List of production files created or modified |
| `test_output` | Actual test runner output showing the test passes |

`test_output` must show the specific test passing. "Tests should pass
now" is not evidence.

## DOMAIN (post-GREEN) -> COMMIT Handoff

Required fields:

| Field | Description |
|-------|-------------|
| `review` | `APPROVED` or `CONCERN_RAISED` (with specific concern and proposed alternative) |
| `full_test_output` | Full test suite output, not just the single test |

If `review` is `CONCERN_RAISED`, the concern must be resolved before
proceeding to COMMIT. The implementation is revised via GREEN, then
domain reviews again.
