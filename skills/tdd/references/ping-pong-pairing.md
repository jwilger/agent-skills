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

## Named Team Member Personas (not generic roles)

When using agent teams, ping and pong should embody named team members from the
project's ensemble roster — not generic "Programmer" or "Engineer" agents.

The orchestrator selects personas based on slice context:
- TDD / test-first focus → the team's development practice lead
- Backend / domain / persistence → the team's backend or systems engineer
- Frontend / component framework → the team's frontend specialist
- AI / LLM integration → the team's AI architecture specialist
- Accessibility-focused slice → the team's accessibility specialist

Include the team member's profile file in the spawn prompt (`.team/<name>.md` or
equivalent). State the persona explicitly: "You are [Name], [Role]. Your job is
to [write a failing test / implement...]"

## Rotation Rules

- Never assign the same person to both ping and pong in the same cycle.
- Rotate to avoid the same pair on consecutive slices.
- Select based on slice context — match expertise to the primary challenge.
- Record the ping/pong assignment in the Slice Plan so it survives context
  compaction.

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

## Phase Reference Loading (Every Turn)

At the START of every turn, each agent must read the reference file for the
phase it is CURRENTLY executing — not just its "default" phase. Roles shift
during drill-downs: ping may end up in a GREEN turn, pong may end up writing
a test (RED turn). Context compaction may discard earlier loads, so re-read
every turn regardless.

| Current phase | File to read |
|--------------|-------------|
| RED (writing a failing test) | `references/red.md` |
| GREEN (implementing) | `references/green.md` |
| DOMAIN (reviewing) | `references/domain.md` |

If an agent starts a GREEN turn but the scope check triggers a drill-down
(writing a failing test), it should switch and load `references/red.md`
before writing that test.

The orchestrator's spawn prompt should remind agents of this rule, but agents
are also responsible for self-enforcing it.

## Ping-Pong-Review Rhythm

1. **Ping** reads `references/red.md`, then writes a failing test (RED step).
2. **Domain reviewer** reads `references/domain.md`, then reviews the test for
   primitive obsession, invalid state risks, and boundary correctness. Sends
   verdict to ping and pong.
3. **Pong** reads `references/green.md`, then addresses the immediate error
   (see GREEN Phase: Scope Check and Drill-Down below). Runs the scope check
   before every change.
4. If pong returns a **DRILL_DOWN**: roles swap at the inner level (see
   Drill-Down Protocol below). When the inner cycle completes, pop back up
   and pong re-runs the outer test to check the next error.
5. If pong returns **standard GREEN** (test passes): **Domain reviewer** reads
   `references/domain.md` and reviews the implementation for domain violations.
   Sends verdict to team.
6. **COMMIT** — orchestrator or designated member commits.
7. **Roles swap.** Ping becomes pong, pong becomes ping. Domain reviewer
   may stay or rotate.
8. Repeat until the acceptance test passes.

## GREEN Phase: Scope Check and Drill-Down

Pong's goal is NEVER "make the acceptance test pass." It is always "address
the immediate error" with a scope check before every change.

**Before every change, pong asks:**

> "Can I fix this error with roughly function-scope work (~20 lines, one file)?"

**YES path:**
1. Make the change. Run tests. Paste output.
2. If a new error appears, do the scope check again.
3. When the test passes, stop. Return standard GREEN evidence.

**NO path (drill down):**
1. The change requires new modules, multiple files, or significant work.
2. STOP implementing.
3. Write a NEW failing unit test for the smallest piece needed.
4. Return the DRILL_DOWN evidence format.
5. The orchestrator routes the drill-down through a standard TDD cycle
   with swapped roles.

**Anti-pattern: "Make the acceptance test pass."** Telling pong to "make the
test pass" for an acceptance test invites building an entire application in
one GREEN session. The correct goal is "address the immediate error" — which
may mean drilling down many times before the acceptance test finally passes.

**Anti-pattern: Full implementation in one pass.** Even when pong "knows"
the full solution, the scope check prevents scope explosion. Each drill-down
gets its own RED-DOMAIN-GREEN-DOMAIN-COMMIT cycle with proper review.

## Drill-Down Protocol

Drill-down is the PRIMARY mechanism for outside-in TDD with acceptance
tests. It is not an edge case — it is the expected path whenever an
acceptance test requires multi-layer implementation.

**When to drill down:**
- The error requires creating a new module or component
- The fix spans multiple files
- The implementation would exceed ~20 lines
- The change requires build system or infrastructure work

**How drill-down works:**

1. Pong (at outer level) writes a failing unit test for the smallest
   piece needed → pong is now acting as PING at the inner level.
2. The inner test is routed to the OTHER engineer (original ping) who
   implements it → original ping is now acting as PONG at the inner level.
3. Domain reviewer reviews at the inner level too.
4. The inner cycle follows the full RED-DOMAIN-GREEN-DOMAIN-COMMIT sequence.
5. When the inner cycle commits, pop back up to the outer level.
6. Pong re-runs the outer test. The error may now be resolved (proceed to
   next error) or a different error appears (scope check again).

**The Rule:** The person who wrote a failing test NEVER writes its
implementation. This applies at EVERY level — outer acceptance tests AND
inner drill-down tests. This is what makes ping-pong work: mutual
accountability through role separation.

**Example (walking skeleton):**
```
Outer: acceptance test "browser navigates to /dev/ui, sees heading"
  Error: "No Cargo.toml metadata for leptos"
  Scope check: NO (needs Cargo.toml features, metadata, dependencies)

  Pong writes inner test: "test that app module exists and can be imported"
  → Drill down: original ping implements the app module
  → Domain review, commit

  Pop back up. Re-run outer test.
  Error: "no route matches /dev/ui"
  Scope check: NO (needs router, route handler, server setup)

  Pong writes inner test: "test that /dev/ui route returns 200"
  → Drill down: original ping implements the route
  → Domain review, commit

  Pop back up. Re-run outer test.
  Error: "Expected heading 'Component Showcase', found empty body"
  Scope check: YES (add heading text to the component)
  → Pong makes the change. Outer test passes.
```

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

## Message Routing

The orchestrator manages the team directly. No intermediate coordination
layer. All external clarification requests from the team route through the
orchestrator to the appropriate team role or the user. Team members message
each other directly for handoffs — the orchestrator does not relay.
