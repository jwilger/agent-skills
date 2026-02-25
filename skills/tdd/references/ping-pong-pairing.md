# Ping-Pong TDD Team Protocol

> **Scope:** This file applies to the **agent teams** execution strategy only.
> If you are using serial subagents (Task tool without TeamCreate), use
> `orchestrator.md` instead. If you are using chaining (no delegation
> primitives), follow the chaining section in SKILL.md.

For use when persistent agent teams are available. Three members alternate
roles through structured TDD cycles: ping (writes failing tests), pong
(makes tests pass), and domain reviewer (reviews tests and implementation).

## Shared Rules

Read `references/shared-rules.md` for rules that apply to all execution
strategies:

- Domain veto power (max 2 rounds, then escalate)
- Outside-in progression (first test must target application boundary)
- Type-first TDD anti-pattern (types flow from tests, never precede them)
- Pre-implementation context checklist (architecture, glossary, types,
  event model)
- Pipeline integration (when `pipeline-state` is in context metadata)
- Recovery protocol (re-delegate, never self-fix)

## Team Selection

Each TDD cycle requires three roles:

- **Ping:** Writes failing tests (RED phase)
- **Pong:** Makes tests pass (GREEN phase)
- **Domain Reviewer:** Reviews test design and implementation for domain
  integrity (both DOMAIN phases)

Track pairing history in `.team/pairing-history.json`. Neither of the last
2 ping/pong combinations may repeat. The domain reviewer may repeat (domain
expertise is more important than rotation for this role). If only 2
engineers exist, the domain reviewer constraint is relaxed — an engineer
may also serve as domain reviewer for cycles where they are not ping or
pong.

**Schema** (`.team/pairing-history.json`):
```json
{
  "pairings": [
    {
      "ping": "name",
      "pong": "name",
      "domain_reviewer": "name",
      "slice": "slice-id",
      "date": "ISO-date"
    }
  ]
}
```

Create this file if it does not exist. Append a new entry when a session
begins.

## Sequential Spawning

Spawn team members one at a time, waiting for evidence before proceeding:

1. **Spawn ping.** Wait for RED evidence (failing test output).
2. **Spawn domain reviewer.** Provide the failing test for review. Wait for
   domain review verdict.
3. **Spawn pong.** Provide the reviewed test and domain feedback. Wait for
   GREEN evidence (passing test output).
4. **Domain reviewer reviews implementation.** Provide the GREEN changeset.
   Wait for domain review verdict.
5. **COMMIT.** Orchestrator commits (or delegates commit).

Never spawn all three simultaneously. Each agent needs the output of the
prior step to do meaningful work. Spawning in parallel causes agents to
idle-wait or work on stale assumptions.

## Session Lifecycle

1. **Establish the team session.** Create a persistent team for the vertical
   slice (e.g., `team-<slice-id>`). All three members are activated and
   persist for the entire TDD cycle.
2. **Bootstrap each member** with full initial context:
   - Their persona profile
   - The scenario being implemented (GWT acceptance criteria)
   - Current codebase context (file paths, test output, domain types)
   - Their role assignment (ping, pong, or domain reviewer)
   - The ping-pong-review protocol
3. **Members work and hand off** via structured messages. The orchestrator
   does NOT relay handoffs between members.
4. **Orchestrator monitors** via task updates and status notifications.
   Intervenes only for: external clarification routing, blocking
   disagreements, or workflow gate verification.
5. **End the session** when the acceptance test passes and the slice is
   complete.

## Ping-Pong-Review Rhythm

1. **Ping** writes a failing test (RED step).
2. **Domain reviewer** reviews the test for primitive obsession, invalid
   state risks, and boundary correctness. Sends verdict to ping and pong.
3. **Pong** writes the GREEN implementation iteratively (see Iterative
   GREEN Discipline below). Runs tests after each small change.
4. **Domain reviewer** reviews the implementation for domain violations.
   Sends verdict to team.
5. **COMMIT** — orchestrator or designated member commits.
6. **Roles swap.** Ping becomes pong, pong becomes ping. Domain reviewer
   may stay or rotate.
7. Repeat until the acceptance test passes.

## Iterative GREEN Discipline

The GREEN phase must proceed one error at a time:

1. Read the exact error message from the test output.
2. Ask: "What is the SMALLEST change that fixes THIS SPECIFIC message?"
3. Make only that change. Nothing else.
4. Run tests. Paste the output.
5. If a new failure appears, return to step 1.
6. Stop immediately when the test passes.

**Anti-pattern: Writing the full implementation in one pass.** This skips
the feedback loop that catches mistakes early. Even if you "know" the full
solution, implement it one error at a time. The test output guides you.

**Anti-pattern: Adding error handling or features not demanded by the
current failure.** Stop means stop. If the test passes, do not improve the
code. Improvements happen in the refactor step or the next RED phase.

## Commit Atomicity Verification

After every commit:

1. Run `git status` to verify no uncommitted files remain.
2. If uncommitted files exist, stage and amend (or create a follow-up
   commit) before proceeding.
3. No new RED phase begins until the working tree is clean.

This prevents the common failure mode where test files or type definitions
are left uncommitted and break the next agent's context.

## Structured Handoff Messages

### Ping to Domain Reviewer (after RED)

```
HANDOFF: RED -> DOMAIN REVIEW
Failing test: [file path and test name]
Intent: [what behavior the test specifies]
Test output: [exact failure message]
Files changed: [list of new/modified test files]
```

### Domain Reviewer to Pong (after test review)

```
HANDOFF: DOMAIN REVIEW -> GREEN
Review verdict: [approved / flagged]
Concerns: [list of concerns, or "none"]
Test file: [path to the test to make pass]
Current failure: [exact error message]
```

### Pong to Domain Reviewer (after GREEN)

```
HANDOFF: GREEN -> DOMAIN REVIEW
Implementation: [files changed and summary of changes]
Test output: [passing test output]
Approach: [brief description of implementation approach]
```

### Domain Reviewer to Orchestrator (after implementation review)

```
HANDOFF: DOMAIN REVIEW -> COMMIT
Review verdict: [approved / flagged]
Concerns: [list of concerns, or "none"]
Ready to commit: [yes / no - if no, explain what needs rework]
```

Because all three members persist, handoffs provide the delta — not a full
re-bootstrap.

## Drill-Down Ownership

When pong needs to drill down instead of going green at the current level:

1. Pong writes a lower-level failing test (now acting as ping at this level).
2. Ping writes the green for it (now acting as pong at this level).
3. Domain reviewer reviews at this level too.
4. When this level goes green, pop back up with swapped roles.

The person who wrote a failing test never writes its green implementation.

## Message Routing

The orchestrator manages the team directly. No intermediate coordination
layer. All external clarification requests from the team route through the
orchestrator to the appropriate team role or the user. Team members message
each other directly for handoffs — the orchestrator does not relay.
