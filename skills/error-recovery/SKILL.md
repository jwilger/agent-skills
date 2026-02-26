---
name: error-recovery
description: >-
  Structured error classification and recovery during autonomous operation.
  Classify runtime errors, apply retry strategies with backoff, maintain
  error logs, and escalate intelligently. Activate when encountering API
  failures, build tool crashes, file permission issues, or unexpected
  runtime errors during autonomous work. Triggers on: "error recovery",
  "retry", "API failure", "crash recovery", "service unavailable".
license: CC0-1.0
metadata:
  author: jwilger
  version: "1.0"
  requires: []
  context: []
  phase: build
  standalone: true
---

# Error Recovery

**Value:** Courage -- autonomous operation requires resilience. Recovering
from errors without human intervention keeps the workflow moving. Knowing
when to escalate prevents wasted effort on unrecoverable situations.

## Purpose

Teaches agents to handle unexpected errors during autonomous operation
(API failures, build tool crashes, permission issues, resource exhaustion).
Provides classification, retry strategies, and escalation rules. Prevents
the failure modes of infinite retry loops, silent error swallowing, and
unnecessary human interruptions for recoverable issues.

## Practices

### Classify Before Acting

When an error occurs, classify it before attempting recovery:

| Category | Examples | Recovery |
|----------|---------|----------|
| **Transient** | Network timeout, 503, rate limit, lock contention | Retry with backoff |
| **Environmental** | Missing dependency, wrong version, port conflict | Fix environment, then retry |
| **Permission** | File permission denied, auth token expired | Escalate to user |
| **Logic** | Assertion failure, type error, schema mismatch | Do NOT retry -- investigate |
| **Resource** | Out of memory, disk full, context exhaustion | Reduce scope or escalate |

**Do not retry logic errors.** If a test fails, an assertion fires, or a
type mismatch occurs, retrying will produce the same result. Switch to
the debugging protocol instead.

### Retry Strategy: Exponential Backoff

For transient errors, retry with exponential backoff:

1. **First retry:** Wait 2 seconds
2. **Second retry:** Wait 5 seconds
3. **Third retry:** Wait 15 seconds
4. **After third failure:** Stop retrying and escalate

Never retry more than 3 times for the same error. Never retry without
waiting. Never use a fixed retry loop without backoff.

**Rate limit handling:** If the error includes a `Retry-After` header or
equivalent, respect it. Do not retry before the indicated time.

### Error Logging

When an error occurs, log it to a structured format before attempting
recovery:

```markdown
## Error Log: [timestamp]

- **Category:** transient | environmental | permission | logic | resource
- **Error:** [exact error message]
- **Context:** [what was happening when the error occurred]
- **Action taken:** [retry | escalate | investigate | fix-environment]
- **Outcome:** [resolved | escalated | investigating]
```

In pipeline mode, append to
`.factory/audit-trail/slices/<slice-id>/error-log.md`.
In standalone mode, write to the project's scratch directory or memory.

### Environmental Recovery

For environmental errors (missing tools, wrong versions, port conflicts):

1. Identify the specific environmental issue
2. Attempt a targeted fix (install missing dependency, kill conflicting
   process, clear stale lock file)
3. Verify the fix resolved the issue
4. Retry the original operation ONCE
5. If it fails again, escalate -- the environment may need manual
   intervention

**Port conflicts:** Check for processes using the port with
`lsof -i :<port>` or equivalent. If the process is not related to the
current project, report it to the user rather than killing it.

### Context Exhaustion Recovery

When approaching context limits during long operations:

1. Write current state to WORKING_STATE.md immediately
2. Complete the current atomic operation if possible
3. Signal that continuation is needed
4. Do NOT start new operations that cannot complete in remaining context

This prevents the failure mode of starting work that cannot be finished,
leaving the project in an inconsistent state.

### Escalation Rules

Escalate to the user when:

- Permission errors (you cannot fix what you cannot access)
- Logic errors after investigation (the bug needs human insight)
- 3 retries exhausted for a transient error (the service may be down)
- Environmental fix failed (the environment may need manual repair)
- Resource exhaustion (context limit, disk space, memory)
- Any error you cannot classify (unknown errors are dangerous)

**How to escalate:** Provide the error category, the exact error message,
what you tried, and what you recommend. Do not just say "an error
occurred."

### Pipeline Integration

In factory pipeline mode, error recovery integrates with the rework
protocol:

- Transient errors during CI: auto-retry once (standard/full autonomy)
- Build tool crashes: classify and apply the appropriate strategy
- Gate failures: these are NOT errors -- they are expected feedback from
  quality gates. Do not apply error recovery to gate failures.

## Enforcement Note

This skill provides advisory guidance. It instructs the agent on error
classification and recovery strategies but cannot mechanically enforce
retry limits or prevent silent error swallowing. The agent follows these
practices by convention. If you observe the agent retrying endlessly or
ignoring errors, point it out.

## Verification

After recovering from an error, verify:

- [ ] Error was classified before any recovery attempt
- [ ] Logic errors were NOT retried (investigated instead)
- [ ] Retries used exponential backoff (not immediate)
- [ ] No more than 3 retries for the same error
- [ ] Error was logged with category, message, context, and outcome
- [ ] Escalation included the error category, message, attempts, and recommendation
- [ ] Environmental fixes were verified before retrying the operation
- [ ] State was saved before context exhaustion recovery

If any criterion is not met, revisit the relevant practice.

## Dependencies

This skill works standalone. For enhanced workflows, it integrates with:

- **debugging-protocol:** Logic errors escalate to the debugging protocol
  for systematic investigation
- **pipeline:** Pipeline gate failures are handled by the rework protocol,
  not error recovery
- **session-reflection:** Recurring errors become system prompt refinements
- **ci-integration:** CI failures classify as transient (infra) or logic
  (test failure) for appropriate handling

Missing a dependency? Install with:
```
npx skills add jwilger/agent-skills --skill debugging-protocol
```
