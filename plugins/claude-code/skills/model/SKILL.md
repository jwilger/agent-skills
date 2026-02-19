---
description: INVOKE for domain discovery, workflow modeling, GWT generation, or architecture
user-invocable: true
argument-hint: [discover|workflow|gwt|validate|arch|design-system] [name]
context: fork
allowed-tools:
  - Bash
  - Read
  - Write
  - Task
  - AskUserQuestion
  - Grep
---

# Model

Model event workflows following Event Modeling methodology.

## Methodology

You MUST follow `skills/event-modeling/SKILL.md` for the full event modeling methodology.
You MUST follow `skills/architecture-decisions/SKILL.md` for the `arch` subcommand.
You MUST follow `skills/atomic-design/SKILL.md` for the `design-system` subcommand.

No architecture or technical decisions during event modeling. The ONLY exception
is mandatory third-party integrations (note name and purpose only).

## Arguments

- `discover` -- domain discovery (actors, goals, processes)
- `workflow [name]` -- model a specific workflow (creates PR)
- `gwt <name>` -- generate GWT scenarios for a workflow
- `validate` -- validate event model completeness
- `arch` -- make architecture decisions (creates ARCHITECTURE.md with ADR PRs)
- `design-system` -- create design system using Atomic Design
- (no args) -- resume or start discovery

## Artifact Locations

| Subcommand | Artifact | Path |
|------------|----------|------|
| discover | Domain overview | `docs/event_model/domain/overview.md` |
| workflow | Workflow overview | `docs/event_model/workflows/<name>/overview.md` |
| workflow | Workflow slices | `docs/event_model/workflows/<name>/slices/*.md` |
| gwt | GWT scenarios | Inline in slice files above |
| arch | Architecture doc | `docs/ARCHITECTURE.md` |
| arch | ADR PRs | GitHub PRs on `adr/<slug>` branches |

## Agent Delegation

| Subcommand | Agents Used |
|------------|-------------|
| discover | discovery |
| workflow | workflow-modeler, then model-checker |
| gwt | gwt, then model-checker |
| validate | model-checker |
| arch | architecture-facilitator, adr (one decision = one PR) |
| design-system | ux |

## Workflow Modeling Process

Each workflow gets its own branch (`event-model/<name>`) and PR.
The 9-step process covers: user goal, events, ordering, wireframes, commands,
read models, automations, mermaid diagram, slice decomposition.

After workflow modeling, model-checker validates completeness iteratively.
After GWT scenarios, model-checker validates again.

## Architecture Process

Prerequisites: `docs/event_model/domain/overview.md` exists AND at least one workflow with GWT scenarios (check for `## Scenario` headings in `docs/event_model/workflows/*/slices/*.md`).
Architecture-facilitator works through decisions ONE AT A TIME.
Each decision creates an independent ADR branch and PR.

## The Four Patterns

1. **Command** -- Trigger -> Command -> Event(s)
2. **View** -- Events -> Read Model
3. **Automation** -- Event -> View -> Process -> Command -> Event
4. **Translation** -- External Data -> Internal Event
