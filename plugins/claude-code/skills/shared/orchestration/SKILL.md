---
description: Orchestrator delegates to agents, never writes directly. Loaded for ALL skills.
user-invocable: false
---

# Orchestration Rules

The main conversation is an **orchestrator only**. It coordinates work but
never writes code directly.

## Ensemble Team Check

Before beginning any orchestration, check for ensemble team configuration:

1. **Glob** for `.team/*.md` — are there team member profiles?
2. **Read** `ensemble_team` from `.claude/sdlc.yaml` — is `preset` set to
   something other than `"none"`?

If both conditions are met, the ensemble team is active. Switch to **ping-pong
pairing mode** instead of solo orchestration:

- **Create a persistent pair team** via `TeamCreate` (e.g., `pair-<slice-id>`)
  at the start of the work session. Do NOT create a new team per TDD cycle.
- **Select two engineers** from the `.team/` profiles. Load their compressed
  active-context forms for bootstrapping.
- **Use the Ping-Pong TDD Pairing protocol** (defined later in this file) for
  all TDD work. The pair handles driver/navigator swaps internally via
  `SendMessage`.
- **Use mob review** for PR reviews: spawn the full team (compressed contexts)
  instead of a single code-reviewer agent.

If the ensemble team is NOT active, proceed with the standard solo orchestration
described below.

## Methodology

You MUST follow `skills/orchestration/SKILL.md` for the full orchestration methodology.
You MUST follow `skills/tdd-cycle/SKILL.md` for the TDD cycle this orchestrates.

## Core Rule: Never Write Files

You MUST NEVER use Edit, Write, or NotebookEdit tools directly on project files.
All file modifications flow through specialized agents.

## Agent Selection

| Phase/Need | Agent | Triggered by |
|------------|-------|-------------|
| Write failing test | red | Orchestrator starts a new slice |
| Type definitions (stubs) | domain | RED test fails to compile due to missing types |
| Implementation | green | Test compiles but fails on assertion/panic |
| Type review | domain | GREEN implementation complete |
| Commit cycle changes | commit | DOMAIN-after-GREEN complete |
| Architecture docs | adr, architect | New boundary or cross-cutting concern |
| GWT scenarios | gwt | New acceptance criteria needed |
| Everything else | file-updater | Config, docs, scripts, tooling |

## TDD Cycle (MANDATORY SEQUENCE)

```
RED → DOMAIN → GREEN → DOMAIN → COMMIT → repeat
```

This is a **5-phase cycle**. Every phase is mandatory, every time.

- **RED**: Write a failing test.
- **DOMAIN** (after RED): Review the test for domain correctness; produce any
  required type stubs.
- **GREEN**: Write the minimum implementation to pass the test.
- **DOMAIN** (after GREEN): Review the implementation for domain integrity.
- **COMMIT**: Create a git commit containing all changed files from this cycle.
  The commit message MUST reference the GWT scenario under test. The
  orchestrator MUST verify the commit exists (e.g., confirm the agent reports
  the commit SHA) before dispatching the next RED phase or any REFACTOR phase.
  This is a **hard gate**, not a suggestion.

Domain review happens TWICE per cycle. This is unconditional -- there are NO
valid reasons to skip domain review. Not for "trivial" changes, not for "just
one line," not for "obviously not a domain concern."

The COMMIT phase is equally unconditional. Uncommitted work MUST NOT carry
across cycle boundaries. Each cycle's changes are atomically committed before
the next cycle begins.

### Anti-pattern: "Type-First TDD"

Creating domain types before any test references them inverts TDD into
waterfall. Types must flow FROM tests, not precede them. If the orchestrator
creates a "define types" task that blocks a RED test task, the ordering is
wrong. NEVER create types before a test references them. In compiled languages
like Rust, a test referencing non-existent types will not compile. This is
expected -- a compilation failure IS a test failure. Do not pre-create types
to avoid compilation failures.

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
5. COMMIT task (blocked by 4) -- `addBlockedBy: ["<domain-after-green-task-id>"]`

| Phase | Scope | Done when | Next |
|-------|-------|-----------|------|
| RED | Test files only | Test exists and fails (compilation failure counts) | DOMAIN |
| DOMAIN (after RED) | Type stubs, test revisions | Types compile, test is domain-correct | GREEN |
| GREEN | Implementation files only | All tests pass | DOMAIN |
| DOMAIN (after GREEN) | Implementation review | No domain integrity violations | COMMIT |
| COMMIT | All changed files from this cycle | `git commit` created with message referencing the GWT scenario | RED (next cycle) or REFACTOR (separate commit) |

The orchestrator MUST NOT dispatch the next RED phase until the COMMIT task
is marked completed. This is a hard gate -- if the commit does not exist,
the cycle is not finished.

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

## Ping-Pong TDD Pairing

When the ensemble-team workflow is active, the orchestrator manages TDD pairing
using a persistent 2-person agent team. **PREREQUISITE**: Read `skills/orchestration/SKILL.md` (Ping-Pong Pairing section) before proceeding. Key points for Claude Code:

- The orchestrator creates a pair team via `TeamCreate` (e.g., `pair-<slice-id>`).
- Both engineers are bootstrapped once and stay alive for the entire TDD cycle --
  they are NOT respawned on each handoff.
- Role swaps (driver/navigator) happen via `SendMessage` between the engineers,
  not through the orchestrator.
- Each engineer invokes `sdlc:red`, `sdlc:green`, and `sdlc:domain` as sub-agents
  within their own persistent context. The orchestrator does not mediate individual
  TDD steps.
- The orchestrator monitors via task updates and idle notifications, intervening
  only for external clarification routing or blocking disagreements.
