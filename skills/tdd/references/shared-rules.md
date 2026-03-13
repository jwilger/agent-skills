# Shared TDD Rules

These rules apply to ALL execution strategies (subagents and chaining).
Strategy-specific files reference this file rather than duplicating these
rules.

## Domain Veto Power

If the DOMAIN review raises a concern (primitive obsession, invalid-state
representability, parse-don't-validate violation), the concern routes back to
the phase that introduced it. Facilitate max 2 rounds of debate. No consensus
after 2 rounds -> escalate to the user. The domain veto can only be overridden
by the user, not by the orchestrator or engineers.

## Outside-In Progression

The first test for a vertical slice MUST target the application boundary, not
an internal unit. Reject RED phase evidence if the first test is internal.

**Boundary enforcement check (3 steps):**

1. **File path check.** Verify the test file is located in an integration or
   acceptance test directory (e.g., `tests/acceptance/`, `tests/integration/`,
   `e2e/`, `spec/features/`). A test in a unit test directory is not a
   boundary test.
2. **Boundary interaction check.** Read the test code. It must interact with
   an external boundary: HTTP client, CLI process spawning, browser driver
   (Playwright, Selenium), message queue client, WebSocket connection, or
   equivalent. Look for actual external calls, not mocked boundaries.
3. **Internal function rejection.** If the test only calls internal functions
   directly (e.g., `CommandLogic.handle()`, `service.process()`,
   `MyModule.run()`), reject it. A direct function call is a unit test, not
   an acceptance test -- even if it asserts on user-visible behavior.

After the first boundary-level acceptance test is established and RED,
subsequent RED phases within the same slice may write inner unit tests that
drill down into the implementation.

## Scenario Boundary Classification (required before RED)

Before writing any acceptance test, the orchestrator classifies the scenario:
- Scan the GWT spec for user-visible behavior. UI indicator words include
  (non-exhaustive): "screen," "panel," "displays," "viewing," "opens,"
  "types," "clicks," "navigates," "sees," "wizard," "form," "dashboard,"
  "submits," "advances," "shown," "not shown," "login," "page," "button,"
  "input," "modal," "dialog," "tab," "menu," "dropdown," "toggle,"
  "checkbox," "link," "redirect," "landing," "profile," "settings," "list"
  → If ANY element of the scenario describes user-observable UI behavior —
  what a user sees, interacts with, or navigates to — classify as UI, even
  if the slice is labeled "domain" or "infrastructure"
  → UI scenario → browser-boundary test (e.g. Playwright)
- Background, machine-to-machine, no user-facing behavior
  → API scenario → HTTP-boundary test (e.g. endpoint/integration test)
- When in doubt, classify as UI — browser tests prove more of the stack

**Scope mismatch gate:** If the scenario is classified as UI but the slice has
no web layer dependency (no UI framework, no browser test infrastructure), the
orchestrator MUST STOP and escalate to the human — the slice scope is wrong,
not the boundary classification. Do not downgrade a UI classification to
"integration" to fit the slice's stated scope.

The classification is made by the orchestrator, not the RED agent. It must be
stated explicitly in the RED agent's spawn prompt. If the spawn prompt omits
it, the RED agent must stop and ask before writing any test.

## Browser Acceptance Tests: All Then-Clauses in One Test Block

Each GWT scenario maps to ONE test function containing ALL its Then-clauses.
The "one assertion per test" rule applies to unit tests only. Splitting a
browser acceptance test by assertion is incorrect — it duplicates setup,
creates false isolation, and obscures scenario intent.

## Outside-In Drill-Down is First-Class

Drill-down is the expected path for acceptance tests, not an exception. When
an acceptance test is RED, the GREEN agent's goal is "address the immediate
error" — NEVER "make the acceptance test pass."

Most acceptance test errors require work beyond function-scope: new modules,
routing, database wiring, build configuration. Each of these triggers a
drill-down into an inner RED-DOMAIN-GREEN-DOMAIN-COMMIT cycle. The acceptance
test passes only when enough drill-down cycles have been completed — not by
one agent implementing everything in one pass.

**Key rules:**
- The GREEN agent does a scope check before every change
- If the change exceeds ~function-scope (~20 lines, one file), drill down
- The person who writes a failing test never implements it (at any level)
- After an inner drill-down cycle commits, pop back up and re-run the outer
  test to discover the next error
- See `references/green.md` for the full scope check protocol
- See `references/ping-pong-pairing.md` for drill-down ownership and the
  worked example (applies to the subagent strategy with named personas)

## No Test Infrastructure in Production Code

Test-only routes, hardcoded test data mappings, and in-memory stubs substituting
for production infrastructure are architectural violations — even when guarded by
environment variables or feature flags. Integration tests must use proper isolation
(transaction rollback, test containers, etc.). Test setup belongs in the test
harness, not in production code paths.

## PR Branch Before First TDD Cycle

A PR branch must exist before the first RED phase of a slice. No code may be
committed to the main branch directly. The orchestrator verifies or creates the
branch before spawning the RED agent.

## Given-Clause Enforcement (required for acceptance tests)

The Given clause of a GWT scenario defines how the system must be running for
the test to be valid — it is not just background context. The acceptance test's
setup (server launch config, test fixtures, environment variables, session
establishment) MUST enforce each Given-clause element. A test that would pass
against any arbitrary server returning the right output does not verify its
preconditions.

Examples of Given-clause enforcement:
- "Given the app is running with feature X enabled" → test infrastructure
  starts the app with that feature flag active
- "Given user is authenticated as an admin" → test setup establishes an
  authenticated admin session before the When step
- "Given the database contains order #123" → test fixture inserts the order
  record before exercising the scenario

**Orchestrator gate (after RED, before domain review):** Verify that the
acceptance test's setup enforces every element of the Given clause. Reject RED
evidence where any Given-clause precondition is not enforced by test setup.

## Pre-Spawn Context Checklist (orchestrator verifies before spawning RED agent)

- [ ] Architecture document sections relevant to this slice (extracted by orchestrator — non-delegable)
- [ ] Domain glossary
- [ ] Existing domain types referenced by this slice's GWT scenarios
- [ ] Event model context for this slice's bounded context
- [ ] Design system component inventory from Slice Plan (if UI slice)
- [ ] Walking skeleton reference (if this is not the first slice)
- [ ] Scenario boundary type (UI or API — decided by orchestrator, stated explicitly)
- [ ] Named team member personas selected for ping and pong
- [ ] Given-clause enforcement requirements extracted from the scenario and stated explicitly in the spawn prompt

## Anti-pattern: Type-First TDD

Creating domain types before any test references them inverts TDD into
waterfall. Types flow FROM tests. In compiled languages, a test referencing
non-existent types will not compile -- this IS the expected RED outcome.
Do not pre-create types to avoid compilation failures.

## Pre-Implementation Context Checklist

When the orchestrator is invoked by the pipeline (pipeline mode), it MUST
gather this context before delegating the first RED phase. When running
standalone, this checklist is advisory -- gathering more context improves
quality but is not gated.

### Required context (always gathered in pipeline mode)

1. **Architecture document** -- `docs/ARCHITECTURE.md` or the path specified
   in `.factory/config.yaml` under `project_references.architecture`. Provides
   system boundaries, component relationships, and integration patterns.
2. **Glossary** -- `docs/glossary.md` or the path specified in
   `.factory/config.yaml` under `project_references.glossary`. Terms from the
   glossary must be used consistently in test names, type names, and variable
   names. Inconsistent terminology is a domain review failure.
3. **Existing domain types** -- Grep for type names referenced in the slice's
   GWT scenarios. Locate existing structs, interfaces, enums, or type aliases
   that the slice will interact with. New types must compose with existing
   ones, not duplicate or shadow them.
4. **Event model context** -- Read the event model document at
   `context.event_model_path` on the slice. Understand the commands, events,
   and read models the slice participates in.

### Conditional context

5. **Design system / UI components** -- Gathered only if the slice touches UI.
   Check `context.ui_components_referenced` on the slice; if present, read the
   design system catalog at the path from
   `project_references.design_system_catalog` in `.factory/config.yaml`.
6. **Walking skeleton reference** -- If a walking skeleton exists (the first
   completed slice), read its entry-point wiring pattern. New slices should
   follow the same integration approach unless there is a documented reason
   to diverge.

## Pipeline Integration

When the TDD orchestrator is invoked by the pipeline (not by a coordinator or
human directly), the following applies:

**Pipeline provides:**
- `slice_id`: identifies the current vertical slice
- GWT scenarios (acceptance criteria) for the slice
- `pair`: {driver, navigator} assignment from the pipeline
- `rework_context` (optional): if this is a rework cycle, contains previous
  gate failure details
- `project_references`: paths to architecture document, glossary, design system
  catalog, and event model root as configured in `.factory/config.yaml`
- `slice_context`: the enriched context block from the slice, including
  `event_model_path`, `ui_components_referenced`, and any other context
  metadata attached during planning

**Pipeline context metadata:**
- `pipeline-state`: present when running in pipeline mode
- `slice_id`, `pair`, `rework_context`, `project_references`, `slice_context`
  as described above

**Orchestrator behavior in pipeline mode:**
- Runs the standard TDD cycle without modification
- At cycle completion, produces CYCLE_COMPLETE evidence (see
  `references/cycle-evidence.md`) and returns it to the pipeline for gate
  evaluation
- No Robert's Rules consensus occurs during TDD -- the pair implements
  autonomously
- If the pair encounters a design question that would normally trigger team
  discussion, they record it as a domain concern in the evidence and proceed
  with their best judgment. The concern surfaces during the pre-push
  full-team review.

## Recovery

When an agent produces incorrect output, do NOT fix it yourself. Diagnose the
failure, correct the delegation context, and re-delegate to a new agent
invocation.
