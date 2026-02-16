---
description: Orchestrator delegates to agents, never writes directly. Loaded for ALL skills.
user-invocable: false
---

# Orchestration Rules

The main conversation is an **orchestrator only**. It coordinates work but
never writes code directly.

## Methodology

Follow `skills/orchestration/SKILL.md` for the full orchestration methodology.
Follow `skills/tdd-cycle/SKILL.md` for the TDD cycle this orchestrates.

## Core Rule: Never Write Files

You MUST NEVER use Edit, Write, or NotebookEdit tools directly on project files.
All file modifications flow through specialized agents.

## Agent Selection

| File Type | Agent | Notes |
|-----------|-------|-------|
| Test files | red | All test code, assertions, test fixtures |
| Implementation code | green | Production code that makes tests pass |
| Domain types/models | domain | Type definitions, domain entities |
| Architecture docs | adr, architect | ARCHITECTURE.md (via PR) |
| GWT scenarios | gwt | Given/When/Then acceptance criteria |
| Everything else | file-updater | Config, docs, scripts, tooling |

## TDD Cycle (MANDATORY SEQUENCE)

```
RED -> DOMAIN (review test) -> GREEN -> DOMAIN (review impl) -> repeat
```

Domain review happens TWICE per cycle. This is unconditional -- there are NO
valid reasons to skip domain review. Not for "trivial" changes, not for "just
one line," not for "obviously not a domain concern."

### The Red-Domain Feedback Loop

When domain raises a concern that causes red to revise the test, domain MUST
re-review after the revision. Without the second pass, types don't exist and
green is blocked.

## Fresh Context Protocol

When launching a NEW agent, it has ZERO context from the conversation. Every
new delegation MUST include:
- File paths
- Current test name and error messages
- Acceptance criteria
- Relevant domain types
- Current TDD phase

NEVER say "as discussed earlier" or "continue from where we left off" in a
new agent invocation.

## Resume Protocol

On harnesses that support agent resume (e.g., Claude Code), a stopped agent
can be resumed with its prior context intact. Use resume instead of
re-launching when:

1. An agent needs information it cannot obtain (e.g., user input, output
   from another agent). The agent should STOP and report what it needs.
2. The orchestrator gathers the needed information (asks the user, runs
   another agent, etc.).
3. The orchestrator RESUMES the stopped agent with the answer. The agent
   retains its prior context -- do NOT re-supply the full delegation context.

The Fresh Context Protocol applies only to NEW agent invocations, not resumed
ones. Resuming preserves expensive context and avoids redundant work.

## Task Dependency Protocol

Hooks enforce the TDD cycle mechanically (SubagentStop hooks prevent wrong
file types). Task dependencies provide **supplementary visibility** -- they
let the orchestrator and teammates see what is blocked and what is ready.
They do NOT replace hook enforcement; they complement it.

When starting a TDD cycle, create tasks with `TaskCreate` and wire up
blocking relationships using `addBlockedBy`:

1. RED task
2. DOMAIN-after-RED task (blocked by 1) -- `addBlockedBy: ["<red-task-id>"]`
3. GREEN task (blocked by 2) -- `addBlockedBy: ["<domain-after-red-task-id>"]`
4. DOMAIN-after-GREEN task (blocked by 3) -- `addBlockedBy: ["<green-task-id>"]`

This makes the workflow state visible at a glance via `TaskList`: pending
tasks with non-empty `blockedBy` cannot be claimed, so teammates
immediately see what is ready to work on and what is still waiting.

## Agent Debate Protocol

The domain agent has VETO POWER over primitive obsession, invalid state
representability, and parse-don't-validate violations. When agents disagree:

1. Domain raises concern
2. Affected agent responds substantively
3. Orchestrator facilitates (max 2 rounds)
4. No consensus -> escalate to user

## Code Review Gate

Before creating PRs, run three-stage code review:
1. Spec Compliance (acceptance criteria met?)
2. Code Quality (clean, maintainable, well-tested?)
3. Domain Integrity (types used correctly? compile-time enforcement opportunities?)

See code-reviewer agent for details.

## Team-Based Review Coordination

When the project's `.claude/sdlc.yaml` includes `parallel_review: true`, use
a review team to run all three review stages in parallel instead of
sequentially.

### Parallel Review Lifecycle

1. **Create the review team.** Use `TeamCreate` with a descriptive name
   (e.g., `code-review-<feature>`).
2. **Create three review tasks.** One task per review stage:
   - Spec Compliance review
   - Code Quality review
   - Domain Integrity review
3. **Spawn focused reviewer agents as teammates:**
   - `spec-reviewer` -- checks acceptance criteria coverage
   - `quality-reviewer` -- checks code cleanliness, maintainability, tests
   - `domain-reviewer` -- checks type usage, compile-time enforcement,
     parse-don't-validate adherence
4. **Assign tasks to reviewers.** Use `TaskUpdate` with `owner` to assign
   each task to the corresponding reviewer agent.
5. **Reviewers work in parallel.** They may send messages to each other
   about overlapping concerns (e.g., a domain issue that also affects
   code quality).
6. **Synthesize results.** Once all three reviewers complete their tasks,
   the orchestrator combines their findings into a unified review summary
   for the user.
7. **Shut down the review team.** Send `shutdown_request` to each reviewer,
   then use `TeamDelete` to clean up.

### Sequential Review (Default)

When `parallel_review` is not set or is `false`, use the existing sequential
`code-reviewer` agent, which runs all three review stages in a single pass.
