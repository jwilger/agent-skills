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

## Confirmed Acceptance Scenarios
(full-stack scenarios verifying user-observable behavior; at least one required;
exercise the application through its external boundary — Playwright for browser,
HTTP for APIs, CLI for terminal tools)

| # | Given | When | Then | Boundary | Tool |
|---|---|---|---|---|---|

## Confirmed Domain Scenarios
(event-model unit scenarios for commands/projections; optional at planning time
but expected before TDD begins)

| # | Given | When | Then |
|---|---|---|---|

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

## Agent Delivery Contract

### Tier 1 — Intent
[Problem statement: what we're building, for whom, why now]

### Tier 2 — Acceptance Scenarios
(see Confirmed Acceptance Scenarios above)

### Tier 3 — Feature Constraints
- Bounded context: [name]
- Domain types in scope: [list]
- Architectural constraints: [patterns to follow per docs/ARCHITECTURE.md]

### Tier 4 — Agent Interpretation
[Agent's understanding of the work, drafted from Tiers 1–3]

**Open questions** (must be empty before approval):
- (none)

### Specification Quality Checklist
- [ ] Self-contained — implementable without clarifying questions
- [ ] Clear module boundaries — explicit inputs, outputs, integration points
- [ ] Observable acceptance criteria — user-visible outcomes only
- [ ] Test cases with known-good expected outputs
- [ ] Evaluation design — how validation will be established

## Open Questions / Escalations
(must be empty before approval)

## Review Approval
Status: APPROVED | CHANGES-REQUESTED
Approved by: (all ensemble members)
Date: YYYY-MM-DD
```

## Coordination Model

Uses the subagent model (same as other planning-phase reviews):
- Spawn each reviewer as a subagent via `Agent(subagent_type="<reviewer-name>", prompt="...")`
- Collect each reviewer's output
- Spawn the Driver subagent with all reviewer results as context
- Reviewers write to `.reviews/<name>-<slice-id>-readiness.md`
- Driver writes the plan document and returns it as the subagent result

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
| Pipeline integrity | Cross-slice dependency check: compare this slice's bounded context, `domain_types_referenced`, and `ui_components_referenced` against all currently `active` slices in `.factory/slice-queue.json`. If overlap exists on any shared domain type or bounded context, the slice is **not ready** — add the conflicting active slice to `depends_on` before approval. |

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

Additional requirements:
- Human has signed off on Agent Delivery Contract Tiers 1–3
- Tier 4 open questions are empty
- Specification quality checklist is complete
- Zero overlap with active slices on shared domain types or bounded context
  (or explicit dependency declared in `depends_on`)

## Relation to TDD Skill

The Slice Plan's Task Breakdown section is the input to TDD scenario dispatch.
Once approved and tasks are created, the pipeline controller begins TDD cycles
in task order, respecting `blockedBy` dependencies.
