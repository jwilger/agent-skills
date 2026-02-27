---
name: event-modeling
description: >-
  Event modeling facilitation for discovering and designing event-sourced
  systems. Eight steps from brainstorming domain events through vertical
  slice decomposition with GWT scenarios. Invoke with /event brainstorm |
  /event order | /event wireframes | /event commands | /event read-models |
  /event automations | /event integrations | /event slicing.
license: CC0-1.0
metadata:
  author: jwilger
  version: "2.0"
  requires: []
  context: [event-model]
  phase: understand
  standalone: true
---

# Event Modeling

**Value:** Communication -- event modeling is a structured conversation that
surfaces hidden domain knowledge and creates shared understanding between
humans and agents before any code is written.

## Purpose

Teaches the agent to facilitate event modeling sessions following an
eight-step process from brainstorming domain events through vertical slice
decomposition. Produces a complete event model (actors, events, commands,
read models, automations, slices with GWT scenarios) that drives all
downstream implementation. The model lives in `docs/event_model/`.

## Practices

### Two-Phase Process: Discovery Then Design

Never jump into detailed workflow design without broad domain understanding
first. Phase 1 maps the territory; Phase 2 explores each region.

**Phase 1 -- Domain Discovery.** Identify what the business does, who the
actors are, what major processes exist, what external systems integrate, and
which workflows to model. Ask these questions of the user; do not assume
answers. Output: `docs/event_model/domain/overview.md`.

**Phase 2 -- Workflow Design.** For each workflow, follow the eight-step
process. Each step is invoked via `/event <step>` and loads its reference
file for detailed guidance. Design one workflow at a time. Complete all
eight steps before starting the next workflow. Output:
`docs/event_model/workflows/<name>/overview.md` plus individual slice files
in `slices/`.

The eight steps:

1. `/event brainstorm` -- Brainstorm domain events (see `references/brainstorm.md`)
2. `/event order` -- Order events chronologically (see `references/ordering.md`)
3. `/event wireframes` -- Create wireframes for user interactions (see `references/wireframes.md`)
4. `/event commands` -- Identify commands (see `references/commands.md`)
5. `/event read-models` -- Design read models (see `references/read-models.md`)
6. `/event automations` -- Find automations (see `references/automations.md`)
7. `/event integrations` -- Map external integrations (see `references/integrations.md`)
8. `/event slicing` -- Decompose into vertical slices (see `references/slicing.md`)

### The Prime Directive: Not Losing Information

Store what happened (events), not just current state. Events are immutable
past-tense facts in business language. Every read model field must trace
back to an event. If a field has no source event, something is missing from
the model.

### Event Design Rules

1. Name events in past tense using business language: `OrderPlaced`, not
   `PlaceOrder` or `CreateOrderDTO`
2. Events are immutable facts -- never modify or delete
3. Include relevant data: what happened, when, who/what caused it
4. Find the right granularity -- not `DataUpdated` (too broad) and not
   `FieldXChanged` (too narrow)
5. Commands depend on user inputs and the event stream, not read models.
   Read models serve views and automations only.
6. Events record domain facts (true on any machine). Runtime context
   (file paths, hostnames, PIDs, working directories) does not belong
   in event data.

### The Four Patterns

Every event-sourced system uses these patterns. Each pattern maps to one
vertical slice.

1. **State Change:** Command -> Event. The only way to modify state. A
   command may produce multiple events as part of a single operation.
2. **State View:** Events -> Read Model. How the system answers queries.
   Commands derive their inputs from user-provided data and the event
   stream -- never from read models. No `ReadModel -> Command` edges.
3. **Automation:** Event -> Read Model (todo list) -> Process -> Command
   -> Event. Background work triggered by events. Requires all four
   components: triggering event, read model consulted, conditional
   process logic, and resulting command. If there is no read model and
   no conditional logic, it is NOT an automation -- it is a command
   producing multiple events.
4. **Translation:** External Data -> Internal Event. Anti-corruption layer
   for workflow-specific external integrations. Generic infrastructure
   shared by all workflows is NOT a Translation.

### GWT Scenarios

After workflow design, generate Given/When/Then scenarios for each slice.
These become acceptance criteria for implementation. Use
`references/gwt-template.md` for the full scenario format and examples.

**Command scenarios:** Given = prior events. When = the command. Then =
events produced OR an error (never both).

**View scenarios:** Given = current projection state. When = one new event.
Then = resulting projection state. Views cannot reject events.

**Automation scenarios:** Given = prior events. When = trigger event. Then =
automation issues command, producing events.

**Critical distinction:** GWT scenarios test business rules (state-dependent
policies), not data validation (format/structure checks that belong in the
type system).

### Application-Boundary Acceptance Scenarios

Every vertical slice MUST include at least one GWT scenario defined at the
application boundary:

- **Given**: The system is in a known state (prior events, seed data)
- **When**: A user interacts through the application's external interface
  (HTTP endpoint, CLI command, message queue consumer, UI action, etc.)
- **Then**: The result is observable at that same boundary (a response,
  output, rendered state change, emitted event, etc.)

A GWT scenario satisfied entirely by calling an internal function describes
a unit-level specification, not a slice acceptance criterion.

### Slice Independence

Slices sharing an event schema are independent. The event schema is the
shared contract. Command slices test by asserting on produced events; view
slices test with synthetic event fixtures. Neither needs the other to be
implemented first. No artificial dependency chains between slices.

### Facilitation Mindset

You are a facilitator, not a stenographer. Ask probing questions. Challenge
assumptions. Keep asking "And then what happens?" after every event, every
command, every answer. Use business language, not technical jargon. Do not
discuss databases, APIs, frameworks, or implementation during event modeling.
The only exception: note mandatory third-party integrations by name and
purpose.

**Do:**
- Follow all steps in order -- the process reveals understanding
- Ask "And then what happens?" relentlessly
- Use concrete, realistic data in all examples and scenarios
- Design one workflow at a time
- Ensure information completeness before proceeding

**Do not:**
- Skip steps because you think you know enough
- Make architecture or implementation decisions during modeling
- Write GWT scenarios for data validation (use the type system)
- Design multiple workflows simultaneously
- Proceed with gaps in the model

## Enforcement Note

This skill provides advisory guidance. It instructs the agent on the event
modeling methodology but cannot mechanically prevent skipping steps or
producing incomplete models. When used with the `tdd` skill, GWT scenarios
from event modeling become acceptance tests that enforce the model. Without
it, the agent follows these practices by convention. If you observe steps
being skipped, point it out.

## Verification

After completing event modeling work, verify:

- [ ] Domain overview exists at `docs/event_model/domain/overview.md` with
      actors, workflows, external integrations, and recommended starting
      workflow
- [ ] Each designed workflow has `docs/event_model/workflows/<name>/overview.md`
      with all eight steps completed
- [ ] All events are past tense, business language, immutable facts
- [ ] Every read model field traces to a source event
- [ ] Every event has a trigger (command, automation, or translation)
- [ ] Automations have all four components (event, read model, conditional
      logic, command)
- [ ] Read model fields use collection types when domain supports concurrent
      instances
- [ ] No cross-cutting infrastructure modeled as Translation slices
- [ ] GWT scenarios exist for each slice with concrete data
- [ ] GWT error scenarios test business rules only, not data validation
- [ ] Every slice has at least one application-boundary acceptance scenario
- [ ] Slices sharing an event schema are independently testable
- [ ] No gaps remain in the model after validation

If any criterion is not met, revisit the relevant practice before proceeding.

## Dependencies

This skill works standalone. For enhanced workflows, it integrates with:

- **domain-modeling:** Events reveal domain types (Email, Money, OrderStatus)
  that the domain modeling skill refines
- **tdd:** Each vertical slice maps to one TDD cycle; GWT scenarios become
  acceptance tests

Missing a dependency? Install with:
```
npx skills add jwilger/agent-skills --skill domain-modeling
```
