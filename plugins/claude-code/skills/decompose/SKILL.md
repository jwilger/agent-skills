---
description: INVOKE when event model slices are ready. Creates dot tasks from slices
user-invocable: true
argument-hint: [workflow-name]
allowed-tools:
  - Bash
  - Read
  - Glob
  - Write
  - Task
  - AskUserQuestion
  - Grep
hooks:
  PreToolUse:
    - matcher: Read
      once: true
      hooks:
        - type: prompt
          prompt: |
            DECOMPOSE PREREQUISITES CHECK

            Verify:
            1. .claude/sdlc.yaml exists
            2. docs/ARCHITECTURE.md exists
            3. At least one workflow with slices exists (glob `docs/event_model/workflows/*/slices/*.md` returns matches)

            If ARCHITECTURE.md missing, direct to /model arch.

            Respond with: {"ok": true}
---

# Decompose

Create dot tasks from event model slices. Bridges the modeling phase to
actionable work.

## Methodology

Follows `skills/task-management/SKILL.md` for task creation patterns.
Follows `skills/event-modeling/SKILL.md` for slice structure.

## The Mapping

| Event Model Concept | dot Task Equivalent |
|---------------------|---------------------|
| Workflow | Epic (parent task) |
| Vertical Slice | Story Task (child of epic) |
| GWT Scenarios | Acceptance Criteria (in description) |
| Pattern Type | Metadata tag |

### Application-Boundary Acceptance Criteria

At least one acceptance criterion per vertical slice MUST describe behavior observable at the application's external boundary — the point where a user, API client, or external system interacts with the application. If every criterion for a slice can be satisfied by unit-testing internal functions alone, the decomposition is incomplete and MUST be revised.

Ask: "Can this criterion be verified by exercising the application through its actual entry points?" If no criterion passes this test, add one that does before proceeding.

### Layer Verification Checklist

When decomposing a vertical slice, verify that it accounts for all necessary architectural layers:

- **Domain logic** — core business rules and entities
- **Infrastructure adapter** — persistence, external service calls, messaging
- **Application wiring** — connecting domain logic to infrastructure and routing
- **Surface / presentation** — the entry point users or external systems interact with

This checklist is a verification tool, NOT a mandate for separate sub-tasks. A single slice implementation may touch all layers in one pass. The purpose is to catch slices that only implement domain logic without wiring it to an observable entry point.

Any layer marked N/A MUST reference a specific existing component that already handles that concern (e.g., "Infrastructure: handled by existing UserRepository adapter"). Vague justifications such as "not needed" or "will add later" are insufficient — if the layer is truly not needed, name the concrete component that makes it unnecessary.

### Acceptance Test Guidance

Where the application boundary is programmatically testable (e.g., CLI output assertions, API endpoint tests, headless browser tests), write automated acceptance tests that exercise the slice through its external entry point. These tests verify that all layers are wired together correctly.

Where automated verification is not feasible (e.g., visual layout, interactive UX that cannot be driven programmatically), document specific manual verification steps for the human to perform. Each step should map to a GWT scenario from the acceptance criteria so the human knows exactly what to check.

## Steps

1. Load config and verify prerequisites (config, architecture, slices)
2. Find workflows to decompose (from argument or all unplanned)
3. For each workflow: create epic task (`dot add "Epic: <name>" -p 1`)
4. For each slice: create story task as child (`dot add "<name>" -P <epic-id> -p 2`)
5. Verify hierarchy with `dot tree <epic-id>`
6. Store results in auto memory via `/remember`
7. Display results with task IDs and next steps

## Arguments

`$ARGUMENTS` - Optional workflow name. If omitted, decomposes all unplanned workflows.

## Optional: Three-Perspective Review

For complex stories, offer reviews via story, architect, and ux agents.
