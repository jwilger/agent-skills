# Claude Code Harness Supplement

This file is loaded ONLY when the TDD skill runs on Claude Code. It
documents Claude Code-specific patterns for orchestration, enforcement,
and team workflows.

## Strategy Detection (do this FIRST)

Before reading any other section of this file or any other reference file,
determine your execution strategy:

1. **Is TeamCreate available?** -> **Agent teams.** Read
   `references/ping-pong-pairing.md`. Skip the "Serial Subagent Patterns"
   section below.
2. **Is Task available (but not TeamCreate)?** -> **Serial subagents.** Read
   `references/orchestrator.md`. Skip the "Agent Teams Patterns" section
   below.
3. **Neither?** -> **Chaining.** Follow the chaining section in SKILL.md.

Do NOT read both strategy files. Each assumes its own execution model.

## Common Tool Notes

**SendMessage tool:** Engineers in a pair exchange structured handoff
messages. The orchestrator monitors via task updates.

## Agent Permissions

Subagents spawned via the Task tool need these tools to do their work:
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

## Serial Subagent Patterns

> Skip this section if you are using agent teams.

**Task tool:** Spawn focused subagents. Each phase agent runs in its own
Task invocation with a phase-specific prompt from `references/{phase}-prompt.md`.

### Agent Debate Protocol

The domain agent has veto power over primitive obsession, invalid-state
representability, and parse-don't-validate violations.

1. Domain raises concern.
2. Affected agent responds substantively.
3. Orchestrator facilitates (max 2 rounds).
4. No consensus: escalate to user via the ask-user skill or
   AskUserQuestion tool.

## Agent Teams Patterns

> Skip this section if you are using serial subagents.

**TeamCreate tool:** Create persistent agent teams for ping-pong pairing.
Name teams descriptively (e.g., `pair-<slice-id>`).

### Ensemble Team Integration

Before beginning orchestration, detect ensemble team mode:

1. Glob for `.team/*.md` -- are there team member profiles?
2. Read `ensemble_team.preset` from `.claude/sdlc.yaml` -- is it set
   to something other than `"none"`?

If both conditions are met, the ensemble team is active. Switch to
ping-pong pairing mode:

- Create a persistent pair team via TeamCreate.
- Select two engineers from `.team/` profiles. Track history in
  `.team/pairing-history.json` (no repeat of last 2 pairings).
- Load compressed active-context forms for bootstrapping.
- Both engineers stay alive for the entire TDD cycle of a vertical
  slice. Handoffs happen via SendMessage, not agent recreation.
- Use mob review (full team, compressed contexts) for PR reviews.

## Code Review Gate

Before creating PRs, run the three-stage code review:

1. **Spec Compliance** -- acceptance criteria met?
2. **Code Quality** -- clean, maintainable, well-tested?
3. **Domain Integrity** -- types used correctly, compile-time enforcement?

Use the code-review skill or code-reviewer agent for details.

### Parallel Review

When the project's `.claude/sdlc.yaml` includes `parallel_review: true`,
use TeamCreate to spawn three reviewer agents in parallel:

- `spec-reviewer` -- checks acceptance criteria coverage
- `quality-reviewer` -- checks cleanliness, maintainability, tests
- `domain-reviewer` -- checks type usage, parse-don't-validate

Assign review tasks via TaskUpdate with `owner`. Synthesize results
when all three complete. Shut down the review team after synthesis.

When `parallel_review` is not set or is `false`, use a single
code-reviewer agent running all three stages sequentially.

## Model Tier Defaults

Claude Code supports per-agent model selection via the `model` field in
agent definition frontmatter (`.claude/agents/*.md`) and the `model`
parameter on the Task tool. Both work for standalone and team-spawned
agents as of v2.1.47.

Default model tiers for TDD phase agents:

| Agent | Default Model |
|-------|--------------|
| tdd-red | haiku |
| tdd-green | haiku |
| domain-reviewer | sonnet |

These defaults are set in the agent definition frontmatter shipped with
the pipeline-agents plugin. Override via `model_tiers` in
`.claude/sdlc.yaml`. See `references/model-tiers.md` for full rationale,
cost comparison, and harness support matrix.

## Plugin-Based Hook Enforcement

For maximum mechanical enforcement, use the `tdd-enforcement` plugin
(`claude --plugin-dir ./plugins/tdd-enforcement`). It provides:

- **PreToolUse hook (deterministic):** Reads `.tdd-phase` state file
  and blocks unauthorized file edits per phase. RED can only edit test
  files, GREEN and DOMAIN cannot edit test files, COMMIT blocks all
  edits. No LLM inference — instant, zero false positives.
- **PostToolUse hook on Task:** After any subagent completes, checks
  `.tdd-phase` and reminds the orchestrator that domain review is
  mandatory after RED and GREEN phases.

The orchestrator writes the current phase to `.tdd-phase` before
spawning each phase agent. See `references/orchestrator.md` for the
phase state file protocol.

Hooks are optional hardening, not a requirement. The TDD skill works
without them via structural enforcement (handoff schemas, context
isolation, role specialization).
