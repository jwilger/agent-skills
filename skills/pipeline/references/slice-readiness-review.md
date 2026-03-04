# Slice Readiness Review

## Purpose

Before the build trio begins any TDD work on a slice, the full ensemble convenes
to produce a Slice Plan document. This prevents the build trio from discovering
mid-cycle that required components don't exist, domain types are undefined, or
acceptance test scenarios are underspecified.

## Trigger

Convene for every slice, before spawning `ping` for the first scenario. If an
approved Slice Plan already exists for this slice, skip to Task Creation.

## Output

A plan document (at the project's canonical path — conventionally
`docs/slices/<slice-id>/plan.md`) containing:

```markdown
# Slice Plan: <slice-id> — <slice-name>

## Overview
- Bounded context, slice type (UI / API / hybrid), GWT scenario count,
  component pre-work required (yes/no)

## Confirmed GWT Scenarios
(verified or refined from the project's GWT specification source)

## UI Component Inventory
| Component | Design System Reference | Status (exists / needs-building) | Notes |

## Domain Type Inventory
| Type | Semantic type definition | Status (exists / needs-creation) |

## Accessibility Requirements
- ARIA roles, keyboard patterns, applicable WCAG criteria for this slice

## Task Breakdown
Ordered list the coordinator will use to create Tasks:
1. [Component] Build `<ComponentName>` UI component  ← blocks dependent scenarios
2. [Scenario] <slice-id>-S1: <scenario name>  ← blockedBy: [1] if component needed
3. [Scenario] <slice-id>-S2: ...

## Ping/Pong Assignments
- Ping: <team-member-name> (selected from rotation pool)
- Pong: <team-member-name> (different from ping; different from previous slice's pong)

## Open Questions / Escalations
(must be empty before approval)

## Review Approval
Status: APPROVED | CHANGES-REQUESTED
Approved by: (all ensemble members)
Date: YYYY-MM-DD
```

## Coordination Model

Uses the ensemble TeamCreate model (same as other planning-phase reviews):
- One task per reviewer (parallel, no `blockedBy`)
- One Driver task blocked by all reviewer tasks
- Reviewers report via `SendMessage` + write to `.reviews/<name>-<slice-id>-readiness.md`
- Driver writes the plan document and sends completion via `SendMessage`

**Driver selection:** The team member with the strongest expertise for the primary
challenge of this slice (e.g. frontend specialist for UI-heavy slices, domain
architect for domain-heavy slices).

## Reviewer Focus Areas

Each reviewer has a specific scope. Include their focus explicitly in the spawn prompt:

| Expertise area | Focus for this review |
|---|---|
| TDD / development practice | GWT scenario quality, task decomposition, test-first concerns |
| Domain architecture | Domain types needed, semantic type definitions, parse-don't-validate |
| Frontend / UI framework | UI components needed, design system → code mapping |
| Visual design / design systems | Design system alignment, component spec completeness |
| Backend / systems | Persistence patterns, backend architecture concerns |
| AI / LLM integration | AI/LLM integration needs (if applicable to slice) |
| Accessibility | A11y requirements, ARIA patterns, applicable WCAG criteria |
| UX | User journey coherence, UX concerns |
| Product | Product value, scope alignment, MVP fit |
| Event modeling | Scenario completeness, event model alignment |

## Component Pre-Work Gate

If the UI Component Inventory contains any component marked `needs-building`:

1. Create a component-build task for each missing component (no `blockedBy`)
2. Create scenario tasks with `blockedBy: [component-task-ids]` for any scenario
   that renders the missing component
3. The build trio works through component-build tasks first, using the same TDD
   trio workflow with the design system spec as the acceptance criteria source

## Approval Standard

All ensemble members APPROVED, zero open items. "Approved with caveats" is not
approval — route for fixes immediately.

## Relation to TDD Skill

The Slice Plan's Task Breakdown section is the input to TDD scenario dispatch.
Once approved and tasks are created, the pipeline controller begins TDD cycles
in task order, respecting `blockedBy` dependencies.
