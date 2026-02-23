# Shared TDD Rules

These rules apply to ALL execution strategies (agent teams, serial subagents,
and chaining). Strategy-specific files reference this file rather than
duplicating these rules.

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
