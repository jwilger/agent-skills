---
name: architecture-probe
description: >-
  Actively identify architectural decisions needed before building. Scans
  for undecided technology choices, undefined boundaries, and missing
  patterns. Activate before starting implementation work.
license: CC0-1.0
metadata:
  author: jwilger
  version: "1.0"
  requires: []
  context: [source-files, architecture-decisions]
  phase: decide
  standalone: true
---

# Architecture Probe

**Value:** Courage -- surfacing undecided architecture before building takes
courage because it slows down the start, but prevents costly rework when
assumptions prove wrong mid-implementation.

## Purpose

Scans the codebase and requirements for architectural decision points that
must be resolved before implementation begins. Prevents teams from building
on unstated assumptions by making every decision explicit and deliberate.

## Practices

### Scan for Decision Points

Before starting implementation work, systematically check each category for
undecided or undocumented choices. Do not assume that existing code implies
a deliberate decision -- it may be accidental.

**Decision Categories Checklist:**

1. **Technology stack** -- language, framework, runtime, database, message
   broker. Is each choice documented or merely inherited?
2. **Domain architecture** -- bounded contexts, aggregate boundaries, module
   structure. Are boundaries explicit or just directory conventions?
3. **Integration patterns** -- APIs, event buses, shared databases, file
   exchanges. Are contracts defined or assumed?
4. **Cross-cutting concerns** -- authentication, logging, error handling,
   caching, observability. Are patterns chosen or ad hoc?
5. **Deployment and infrastructure** -- hosting, CI/CD, environment
   configuration. Are constraints documented?
6. **Data management** -- migration strategy, backup, retention, access
   patterns. Are these designed or deferred?

For each category, check `docs/ARCHITECTURE.md` for an existing decision. If
the file does not exist or the category is absent, that is a decision point.

### Present a Decision Agenda

After scanning, present the human with a prioritized agenda of decisions
needed. Sort by implementation impact -- decisions that block the most work
come first.

For each decision point:

1. State what needs to be decided (one sentence)
2. State why it blocks progress (one sentence)
3. Note any constraints already visible in the codebase

**Do:**
- Present all discovered decision points before starting any ADR
- Let the human prioritize which decisions to make first
- Accept "defer" as a valid decision (but document it)

**Do not:**
- Batch multiple decisions into a single ADR
- Start building before the human has reviewed the agenda
- Make architectural decisions yourself -- present options, let humans decide

### One Decision, One ADR

Each decision point from the agenda gets its own ADR lifecycle. Use the
`architecture-adr` skill to create and manage each ADR. Never combine
multiple decisions into a single record -- they have different stakeholders,
timelines, and reversal costs.

## Enforcement Note

This skill provides advisory guidance. It instructs the agent to scan for
decisions before building but cannot mechanically prevent implementation from
starting without a scan. On harnesses with delegation primitives, a build
phase can be gated on probe completion. On all harnesses, the agent follows
these practices by convention. If you observe building starting without an
architecture probe, point it out.

## Verification

After completing a probe guided by this skill, verify:

- [ ] All six decision categories were checked against docs/ARCHITECTURE.md
- [ ] Each undecided point was presented to the human with context
- [ ] The human reviewed and prioritized the decision agenda
- [ ] No decisions were batched into a single ADR
- [ ] Deferred decisions were explicitly noted, not silently skipped

If any criterion is not met, revisit the relevant practice before proceeding.

## Dependencies

This skill works standalone. For enhanced workflows, it integrates with:

- **architecture-adr:** Manages the lifecycle of each decision identified by
  this probe -- one ADR per decision point
- **architecture-refresher:** Loads existing decisions so the probe can
  identify what is already decided versus what is missing

Missing a dependency? Install with:
```
npx skills add jwilger/agent-skills --skill architecture-adr
```
