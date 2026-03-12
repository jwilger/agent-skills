# Enforcement Vocabulary

Every skill's Enforcement Note section MUST use exactly one of these four
terms per mode (standalone, pipeline, ensemble). If enforcement differs by
mode, state each mode separately. Never claim a higher level than what the
mechanism actually provides.

## Levels

### Advisory

Guidance the agent should follow. No mechanical check prevents violation.
The agent self-polices based on the skill's text instructions.

**Mechanism:** Text instructions only.

**Example:** "The agent follows push-and-wait discipline by convention."

### Gating

Work product is checked after completion. Violations are caught at
review/gate time, not prevented during writing. Bad work can be written
but cannot proceed past the gate.

**Mechanism:** Evidence gates, review verdicts, phase-transition checks.

**Example:** "Gate failures route to rework -- incomplete evidence blocks
the next pipeline stage."

### Structural

Execution architecture prevents violation. Separate agents with scoped
file access, separate worktrees, phase-isolated tool permissions, or
similar isolation boundaries.

**Mechanism:** Agent isolation, file-type restrictions in spawn prompts,
worktree separation.

**Example:** "Subagents receive only phase-relevant files. The RED agent
cannot access production source code."

### Mechanical

Harness-level hooks or CI checks that reject violations automatically,
independent of agent cooperation. The agent cannot bypass these even if
it tries.

**Mechanism:** Pre-commit hooks, CI checks, linters, pre-tool-use hooks.

**Example:** "A pre-tool-use hook blocks writes to production files during
the RED phase."

## Rules

1. Use exactly one level per mode in the Enforcement Note
2. If enforcement differs by mode, state each mode on its own line
3. Never claim Structural when the mechanism is actually Advisory
4. Never claim Mechanical unless a hook or CI check exists
5. "Advisory with self-enforcement obligations" is still Advisory --
   the agent promising to enforce itself does not elevate the level
6. Gating requires a defined gate that actually blocks progression --
   not just a recommendation to check
