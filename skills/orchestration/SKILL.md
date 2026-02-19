---
name: orchestration
description: >-
  Multi-agent orchestration patterns: delegation, context passing, workflow
  gates, and role-based coordination. Activate when coordinating multiple
  specialized roles, delegating file edits, or managing TDD cycle handoffs.
  The orchestrator never writes files directly.
license: CC0-1.0
compatibility: >-
  Works on any harness. Adapts to the delegation topology available:
  hub-and-spoke (flat), shallow hierarchy, or sequential role-switching.
  Hub-and-spoke is the default assumption.
metadata:
  author: jwilger
  version: "1.0"
  requires: [tdd-cycle]
  context: [test-files, domain-types, source-files, task-state]
  phase: build
  standalone: false
---

# Orchestration

**Value:** Communication and respect -- the orchestrator ensures every
specialized role receives complete context and every concern is heard before
work proceeds.

## Purpose

Teaches the main conversation to coordinate work through specialized roles
without performing specialized work itself. Solves the problem of an LLM
trying to do everything at once, which leads to skipped reviews, inconsistent
quality, and tangled responsibilities.

## Practices

### Never Write Files Directly

The orchestrator decides WHAT to do and WHO should do it. It never uses
Write or Edit tools on project files. All file modifications flow through
specialized roles.

**Role selection:**

| File type | Role | Scope |
|-----------|------|-------|
| Test files | Test Writer | `*_test.*`, `*.test.*`, `tests/`, `spec/` |
| Production code | Implementer | `src/`, `lib/`, `app/` |
| Module scaffolding | green | lib.rs mod decls, mod.rs, __init__.py, index.ts barrels |
| Build config deps | file-updater | Cargo.toml deps, package.json deps, pyproject.toml deps |
| Type definitions | Domain Modeler | Structs, enums, interfaces, traits |
| Architecture docs | Architect | `ARCHITECTURE.md`, ADRs |
| Config, docs, scripts | File Updater | Everything not specialized |

How roles map to agents depends on the harness delegation topology:

- **Hub-and-spoke (flat):** The orchestrator activates leaf-node specialists
  directly. Specialists cannot sub-delegate. All coordination flows through
  the orchestrator. Common on Claude Code, Amp, and OpenAI Agents SDK.
- **Shallow hierarchy:** The orchestrator delegates to specialists who may
  invoke one level of sub-specialists. Cap depth at 2-3 levels; deeper
  nesting duplicates work and degrades context quality. Common on OpenCode,
  Goose, and CrewAI.
- **Sequential role-switching:** The orchestrator plays each role itself:
  "I am now acting as the Test Writer role" -- then shifts back when done.
  Use on single-agent harnesses or when the orchestrator cannot delegate.

When in doubt, prefer hub-and-spoke. Flat delegation gives the orchestrator
unmediated feedback from every role and keeps coordination simple. Roles are
leaf workers -- if a role needs sub-work done, it reports back to the
orchestrator, which decides whether to decompose further.

**Do not:**
- Make "quick fixes" directly ("just one line")
- Edit files while "in orchestrator mode"
- Skip delegation because "it is trivial"

### Provide Complete Context Every Time

Roles have zero memory of the main conversation. Every delegation must
include all information needed to complete the task.

**Required context template:**
```
WORKING_DIRECTORY: <absolute path to project root>
TASK: What to accomplish
FILES: Specific file paths to read or modify
CURRENT STATE: What exists, what is passing/failing
REQUIREMENTS: What "done" looks like
CONSTRAINTS: Domain types to use, patterns to follow
ERROR: Exact error message (if applicable)
```

**Do not:**
- Say "as discussed earlier" or "continue from where we left off"
- Summarize errors instead of providing exact text
- Assume a role knows project conventions without stating them

### Validate Decomposition Output

After decomposition produces sub-tasks and GWT scenarios for a vertical slice, the orchestrator MUST verify the following before allowing work to proceed:

1. **Application-boundary scenarios exist.** At least one GWT scenario must describe behavior observable at the application's external boundary — the point where a user or external system interacts with the application. Scenarios that only describe internal domain logic are insufficient for a vertical slice.

2. **All necessary architectural layers are accounted for.** The task list must include work items covering every layer the slice traverses — from external interface through application logic, domain, and infrastructure. If the decomposition only produces tasks for a single layer (e.g., domain modeling without corresponding entry-point or persistence tasks), the decomposition is incomplete.

If either check fails, **reject the decomposition and require revision** before any implementation begins. Do not allow agents to start coding against an incomplete slice definition.

### Enforce Workflow Gates

Work proceeds through gates. A gate is a precondition that must be satisfied
before the next step begins. Gates prevent skipping steps.

**TDD cycle gates:**
1. Red complete (test written and failing) -> Domain review of test
2. Domain review passed -> Green (implement)
3. Green complete (test passing) -> Domain review of implementation
4. Domain review passed -> Next test or ship

If a role raises a concern (e.g., domain modeler vetoes a test for primitive
obsession), the gate does not open until the concern is resolved. The
orchestrator facilitates resolution:

1. Concern raised -- affected role responds with rationale
2. Orchestrator summarizes both positions
3. Seek compromise (max 2 rounds)
4. No consensus after 2 rounds -- escalate to user

**The domain modeler has veto power** over primitive obsession, invalid state
representability, and parse-don't-validate violations. This veto can only be
overridden by the user, not by the orchestrator.

### Use Task Dependencies When Available

On harnesses with task/todo tools, encode workflow gates as task dependencies.
Create tasks for each step and block downstream tasks on upstream completion.

```
Task 1: Write failing test [RED]
Task 2: Review test, create types [DOMAIN] -- blocked by Task 1
Task 3: Implement to pass test [GREEN] -- blocked by Task 2
Task 4: Review implementation [DOMAIN] -- blocked by Task 3
```

On harnesses without task tools, track state explicitly in conversation:
"RED complete. Test fails with: [error]. Proceeding to DOMAIN review."

### Anti-pattern: "Type-First TDD"

Creating domain types before any test references them inverts TDD into
waterfall. Types must flow FROM tests, not precede them. If the orchestrator
creates a "define types" task that blocks a RED test task, the ordering is
wrong. NEVER create types before a test references them.

In compiled languages like Rust, a test referencing non-existent types will not
compile. This is expected -- a compilation failure IS a test failure. Do not
pre-create types to avoid compilation failures.

### Verify Outside-In TDD Progression

The orchestrator must verify that the first test written for a vertical slice targets the application boundary — not an internal unit test. This means the initial test exercises the slice's behavior from the perspective of an external caller or user-facing entry point.

Before allowing a slice to proceed toward completion:

- Confirm that the outermost test exists and runs (even if failing initially as part of red-green-refine).
- If the first test written is an internal unit test with no corresponding boundary-level test, flag this and require the agent to write the boundary test first.

This ensures each slice is built outside-in, preventing the pattern where internal layers are implemented in isolation without ever being wired to the application's entry points.

### Proxy Role Questions to User

Roles running as delegated agents cannot ask the user questions directly.
When a role's output contains questions or indicates it is blocked on a
decision:

1. Detect the blocking question
2. Present it to the user with the role's context
3. Deliver the user's answer back to the role with full context

### Recover from Agent Failures (Never Self-Fix)

When a role produces incorrect output — writes to the wrong path, creates
malformed files, or fails to complete its task — the orchestrator must diagnose
and re-delegate. The orchestrator MUST NOT fix the problem by writing files
itself, even when the fix seems trivial.

**Recovery steps:**
1. **Diagnose** — What went wrong? Incomplete context? Wrong path?
2. **Clean up** — Remove files in wrong locations (via shell, not direct edit)
3. **Fix the context** — Correct the delegation that caused the failure
4. **Re-delegate** — Launch a new invocation with corrected context

**Do not:**
- Write, Edit, or move files yourself to compensate for role errors
- "Fix up" a role's partial output by hand
- Rationalize self-editing as "cleanup" or "trivial"

### Resume Agents Instead of Re-Delegating

On harnesses that support agent resume (e.g., Claude Code), prefer resuming
a stopped agent over starting a new one. When an agent stops because it
needs user input or is blocked on a decision:

1. Capture the agent's question and blocking context
2. Present the question to the user (using user-input-protocol if available)
3. Resume the agent with the user's answer

The resumed agent retains its prior conversation and working state. Do NOT
re-send the full context template -- the agent already has it. Only provide
the new information (the user's answer, clarification, or unblocking data).

This is more efficient than fire-and-forget delegation because the agent
keeps accumulated context -- file contents it read, intermediate reasoning,
partial progress. Re-delegating would discard all of that and start cold.

**When to resume vs. re-delegate:**
- **Resume** when the agent has accumulated significant context and just
  needs one piece of information to continue.
- **Re-delegate** when the agent's task has fundamentally changed, when
  the agent finished its task and a new one is starting, or when the
  harness does not support resume.

**Note:** The "Provide Complete Context Every Time" practice applies to
NEW delegations only. Resumed agents already have their context.

### Respect Delegation Depth

Do not nest delegation deeper than the harness supports. Even on harnesses
that allow deep nesting, prefer shallow topologies:

- **3-4 active agents** is the empirical sweet spot per workflow cycle
- Deeper trees add coordination cost with diminishing quality returns
- Delegated agents duplicating parent work is a sign of excessive depth
- Context gets summarized (lossy) at each delegation boundary

If a role needs help, it reports back to the orchestrator rather than
activating its own specialists. The orchestrator decides whether to decompose
further. This keeps feedback loops short and coordination centralized.

### Assign Wiring Tasks Explicitly

Connecting layers together — wiring domain logic to infrastructure, infrastructure to the application's entry point, and so on — must be treated as explicit, assigned tasks. Do not assume wiring will happen as a side effect of implementing individual layers.

The orchestrator must:

1. Ensure the decomposition includes distinct wiring tasks that connect each architectural layer to its neighbors.
2. Assign each wiring task to a specific agent.
3. Verify that all wiring tasks are completed before the slice proceeds to code review.

A vertical slice is not vertically integrated until every layer is connected end-to-end. Unassigned or forgotten wiring tasks are the primary cause of slices that "work" in isolation but are unreachable from the application's external boundary.

### Ping-Pong Pairing

The orchestrator manages pair programming using a persistent pair session.
Both engineers are activated once and persist for the duration of the
pairing session. Handoffs happen via lightweight structured messages
between the engineers, not by the orchestrator recreating agents. The
orchestrator monitors the pair and routes clarification requests to external
roles or the user. This keeps the topology flat (hub-and-spoke with
persistent spokes) and avoids an unnecessary coordination layer.

#### Pair Selection

Pick 2 software engineers from the team for each pairing session. The
orchestrator tracks pairing history in `.team/pairing-history.json` and
must not repeat either of the last 2 pairings. If only 2 engineers exist,
this constraint is relaxed.

**Pairing history schema** (`.team/pairing-history.json`):
```json
{
  "pairings": [
    {"driver": "engineer-name", "navigator": "engineer-name", "slice": "slice-id", "date": "ISO-date"}
  ]
}
```

Create this file if it does not exist. Append a new entry each time a
pairing session begins.

#### Pair Session Lifecycle

1. **Establish the pair session.** The orchestrator creates a persistent
   pair session for the vertical slice (e.g., named `pair-<slice-id>`).
   How this maps to harness primitives varies: on multi-agent harnesses
   this may be a named team or agent group; on single-agent harnesses the
   orchestrator tracks the pair state in conversation context.

2. **Activate both engineers once.** Each engineer is given full initial
   context at the start of the session:
   - Their persona profile (from `.team/`)
   - The scenario being implemented (GWT acceptance criteria)
   - Current codebase context (relevant file paths, test output, domain types)
   - Their assigned starting role (driver or navigator) and the ping-pong protocol
   - Instructions to perform `red`, `green`, and `domain` steps within
     their own context (not via the orchestrator)

   The orchestrator provides this context when activating each engineer,
   following the "Provide Complete Context Every Time" practice. After
   activation, engineers retain their accumulated context across the
   entire session -- they are NOT recreated on each handoff.

3. **Engineers work and hand off directly.** Engineers send structured
   handoff messages to each other when roles swap. The orchestrator does
   not relay these handoffs. See "Structured Handoff Messages" below.

4. **Orchestrator monitors.** The orchestrator observes the pair's progress
   via task updates and status notifications. It intervenes only to:
   - Route clarification requests to external roles or the user
   - Resolve blocking disagreements between the pair
   - Verify workflow gates are respected

5. **End the session when done.** When the acceptance test passes and the
   slice is complete, the orchestrator ends the pair session and releases
   both engineers.

#### Phase Step Invocation

Engineers perform the `red`, `green`, and `domain` phase steps within
their own persistent context. This means:

- The driver performs the RED step to write a failing test within their
  own context.
- The navigator performs the GREEN step to write a passing implementation
  within their own context.
- Either engineer performs the DOMAIN review within their own context,
  then shares the outcome with their partner via a handoff message.

Engineers do NOT ask the orchestrator to run these steps on their behalf.
The orchestrator's role is monitoring and external routing, not mediating
every TDD step.

#### Ping-Pong Rhythm

The pair alternates between driver (writes the failing test) and navigator
(makes it pass or drills down). The rhythm within one vertical slice:

1. **Engineer A (driver)** writes a failing test by performing the RED
   step within their own context.
2. **Both engineers discuss** domain concerns. Each performs the DOMAIN
   review within their own context and they exchange findings via
   structured handoff messages.
3. **Engineer B (navigator)** either:
   - (a) Writes minimal green implementation by performing the GREEN
     step within their own context, OR
   - (b) Writes a lower-level failing test to clarify the error, if the
     current failure does not make the next green step obvious.

   **Refactor ownership:** The engineer who writes the green implementation
   also performs the refactor step, because they have the freshest context on
   the implementation decision. Do not hand off refactoring to the other
   engineer.

4. **Roles swap:** B sends a structured handoff message to A. B becomes
   driver, A becomes navigator.
5. Repeat until the original acceptance test passes.
6. Remove ignore markers from lower-level tests as they go green.

#### Structured Handoff Messages

When driver and navigator roles swap, the outgoing driver sends a
structured handoff to the incoming driver containing:

- **Failing test:** name and file path of the test that needs a green implementation (or the next red test to write)
- **Intent:** what behavior the test is specifying
- **Domain context:** any relevant constraints or decisions surfaced during the domain discussion
- **Current output:** the exact test failure or error message
- **New role assignment:** which engineer is now driver and which is navigator

Because both engineers persist across the session, the incoming driver
retains all prior context from earlier cycles. The handoff message provides
the delta, not a full re-bootstrap.

#### Drill-Down Ownership

When the navigator chooses option (b) -- drilling down instead of going
green -- the roles swap at that level too:

1. Navigator writes a lower-level failing test (they are now driver at
   this level) by performing the RED step within their own context.
2. Original driver writes the green for this lower-level test (they are
   now navigator at this level) by performing the GREEN step within their
   own context.
3. When this level goes green, pop back up to the previous level and
   continue with swapped roles.

This preserves the ping-pong alternation at every level of the test
hierarchy. The person who wrote a failing test never writes its green
implementation.

#### Clarification Routing

If the pair needs clarification from other team members (PM, domain SME,
architect, etc.), they send the request to the orchestrator. The
orchestrator proxies the question to the appropriate role or the user, then
sends the answer back to the requesting engineer. No ad-hoc lateral
delegation outside the pair session.

#### Pairing Verification

After a pairing session, verify:

- [ ] Orchestrator established a persistent pair session for the vertical slice
- [ ] Both engineers were activated once with full context (persona, scenario, codebase state, role)
- [ ] Engineers were NOT recreated on each role swap
- [ ] Engineers performed red, green, and domain steps within their own context
- [ ] Handoffs between engineers used structured messages (not orchestrator relay)
- [ ] Handoff messages included failing test, intent, domain context, current output, and new role assignment
- [ ] Pair was selected without repeating either of the last 2 pairings
- [ ] `.team/pairing-history.json` was updated with the new pairing entry
- [ ] Driver and navigator roles alternated after each red-green cycle
- [ ] Drill-down levels also alternated roles
- [ ] All external clarification requests routed through the orchestrator
- [ ] Pair session was ended after acceptance test passed

## Enforcement Note

This skill provides advisory guidance. It cannot mechanically prevent the
orchestrator from writing files directly or skipping gates. On harnesses with
plugin support (e.g., Claude Code hooks, OpenCode event hooks), enforcement
plugins add mechanical guardrails -- pre-tool-use hooks block unauthorized
file edits, post-delegation hooks require domain review after red and green
phases. On harnesses without plugin support, follow these practices by
convention. If you observe violations, point them out.
For additional context, see `../../README.md#harness-plugin-availability`.

## Verification

After completing a workflow cycle guided by this skill, verify:

- [ ] Orchestrator did not use Write or Edit tools on project files
- [ ] Every role delegation included complete context (task, files, state, requirements)
- [ ] Domain review occurred after both red and green phases
- [ ] No workflow gates were skipped
- [ ] Role concerns were addressed before proceeding (not ignored)
- [ ] User was consulted for any unresolved disagreements
- [ ] Agents needing user input were resumed (not re-delegated) when the harness supports it
- [ ] Delegation depth matched harness topology (no nesting beyond what is supported)

## Human Verification Checkpoint

A vertical slice is not merge-ready until a human has personally run the application and verified the slice's behavior. Agents cannot interact with user interfaces or fully simulate end-user experience, so automated checks alone are insufficient.

Before marking a slice as ready for PR merge, the orchestrator must:

1. Include a **human verification checkpoint** in the completion workflow that lists the specific behaviors the human should confirm — derived directly from the slice's GWT scenarios.
2. Clearly communicate to the human what to verify: that the slice is reachable from the application's entry point and produces the expected user-visible behavior described in the acceptance criteria.
3. Do not allow the PR to be treated as merge-ready until the human has confirmed verification.

Where automated acceptance tests are feasible (e.g., headless browser tests, CLI output assertions, API integration tests), agents should write them. But automated tests supplement human verification — they do not replace it.

## Dependencies

This skill requires `tdd-cycle` for the red/domain/green/domain workflow it
orchestrates. For enhanced workflows, it integrates with:

- **domain-modeling:** Domain modeler role applies these principles during review
- **code-review:** Three-stage review before shipping
- **task-management:** Encodes workflow gates as task dependencies
- **user-input-protocol:** Structured format for proxying role questions

Missing a dependency? Install with:
```
npx skills add jwilger/agent-skills --skill domain-modeling
```
