# Claude Code Harness Supplement

This file is loaded ONLY when the TDD skill runs on Claude Code. It
documents Claude Code-specific patterns for orchestration, enforcement,
and subagent workflows.

## Strategy Detection (do this FIRST)

Before reading any other section of this file or any other reference file,
determine your execution strategy:

1. **Is Agent tool available?** -> **Subagents.** Read
   `references/orchestrator.md`.
2. **Neither?** -> **Chaining.** Follow the chaining section in SKILL.md.

## Agent Permissions

Subagents spawned via the Agent tool need these tools to do their work:
Read, Write, Edit, Bash, Glob, Grep, Skill.

Do NOT use `mode: "delegate"` for phase agents -- delegate mode strips
tool access and prevents file edits. Use `mode: "default"` or omit
the mode parameter entirely.

## Resume Protocol

Claude Code supports resuming stopped agents with their prior context
intact. Use resume instead of re-launching when:

1. An agent stops because it needs information it cannot obtain (user
   input, output from another agent).
2. The orchestrator gathers the needed information.
3. The orchestrator resumes the stopped agent with the answer.

The resumed agent retains its full context -- do NOT re-supply the
delegation context. The Fresh Context Protocol applies only to NEW
agent invocations, not resumed ones.

## Task Dependency Protocol

When starting a TDD cycle, create tasks with blocking relationships
to make workflow state visible:

1. RED task
2. DOMAIN-after-RED task (`addBlockedBy: [RED]`)
3. GREEN task (`addBlockedBy: [DOMAIN-after-RED]`)
4. DOMAIN-after-GREEN task (`addBlockedBy: [GREEN]`)
5. COMMIT task (`addBlockedBy: [DOMAIN-after-GREEN]`)

Pending tasks with non-empty `blockedBy` cannot be claimed. This makes
the cycle state visible at a glance via `TaskList`.

Task dependencies provide supplementary visibility. They do not replace
hook-based or structural enforcement -- they complement it.

## Subagent Patterns

**Agent tool:** Spawn focused subagents. Each phase agent runs in its own
Agent invocation with a phase-specific prompt from `references/{phase}-prompt.md`.

### Agent Debate Protocol

The domain agent has veto power over primitive obsession, invalid-state
representability, and parse-don't-validate violations.

1. Domain raises concern.
2. Affected agent responds substantively.
3. Orchestrator facilitates (max 2 rounds).
4. No consensus: escalate to user via the ask-user skill or
   AskUserQuestion tool.

## Code Review Gate

Before creating PRs, run the three-stage code review:

1. **Spec Compliance** -- acceptance criteria met?
2. **Code Quality** -- clean, maintainable, well-tested?
3. **Domain Integrity** -- types used correctly, compile-time enforcement?

Use the code-review skill or code-reviewer agent for details.

### Parallel Review

When the project's `.claude/sdlc.yaml` includes `parallel_review: true`,
spawn three reviewer subagents using the Agent tool:

- `spec-reviewer` -- checks acceptance criteria coverage
- `quality-reviewer` -- checks cleanliness, maintainability, tests
- `domain-reviewer` -- checks type usage, parse-don't-validate

Collect results from all three and synthesize.

When `parallel_review` is not set or is `false`, use a single
code-reviewer agent running all three stages sequentially.

## Optional Hook Enforcement

For maximum mechanical enforcement, install the hook templates from
`references/hooks/claude-code-hooks.json`. These add:

- **PreToolUse hooks:** Block unauthorized file edits per phase (RED
  can only edit test files, GREEN only production files, DOMAIN only
  type definitions).
- **PostToolUse hooks:** Require running tests and pasting output
  after every file edit.
- **SubagentStop hooks:** Enforce mandatory domain review after RED
  and GREEN, prevent orchestrator from writing files directly.

Hooks are optional hardening, not a requirement. The TDD skill works
without them via structural enforcement (handoff schemas, context
isolation, role specialization).
