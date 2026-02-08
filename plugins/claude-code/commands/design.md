---
description: INVOKE for domain discovery, workflow design, GWT generation, or architecture
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

# Design

Design event model workflows following Event Modeling methodology.

## Methodology

Follows `skills/event-modeling/SKILL.md` for the full event modeling methodology.
Follows `skills/architecture-decisions/SKILL.md` for the `arch` subcommand.
Follows `skills/atomic-design/SKILL.md` for the `design-system` subcommand.

No architecture or technical decisions during event modeling. The ONLY exception
is mandatory third-party integrations (note name and purpose only).

## Arguments

- `discover` -- domain discovery (actors, goals, processes)
- `workflow [name]` -- design a specific workflow (creates PR)
- `gwt <name>` -- generate GWT scenarios for a workflow
- `validate` -- validate event model completeness
- `arch` -- make architecture decisions (creates ARCHITECTURE.md with ADR PRs)
- `design-system` -- create design system using Atomic Design
- (no args) -- resume or start discovery

## Agent Delegation

| Subcommand | Agents Used |
|------------|-------------|
| discover | discovery |
| workflow | workflow-designer, then model-checker |
| gwt | gwt, then model-checker |
| validate | model-checker |
| arch | design-facilitator, adr (one decision = one PR) |
| design-system | ux |

## Workflow Design Process

Each workflow gets its own branch (`event-model/<name>`) and PR.
The 9-step process covers: user goal, events, ordering, wireframes, commands,
read models, automations, mermaid diagram, slice decomposition.

After workflow design, model-checker validates completeness iteratively.
After GWT scenarios, model-checker validates again.

## Architecture Process

Prerequisites: domain discovery + at least one workflow with GWT.
Design-facilitator works through decisions ONE AT A TIME.
Each decision creates an independent ADR branch and PR.

## The Four Patterns

1. **Command** -- Trigger -> Command -> Event(s)
2. **View** -- Events -> Read Model
3. **Automation** -- Event -> View -> Process -> Command -> Event
4. **Translation** -- External Data -> Internal Event
