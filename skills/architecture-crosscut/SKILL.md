---
name: architecture-crosscut
description: >-
  Detect cross-cutting concerns during build phases that need architectural
  decisions. Triggers a new ADR when undecided cross-cutting patterns emerge.
  Activate during implementation when patterns span multiple components.
license: CC0-1.0
metadata:
  author: jwilger
  version: "1.0"
  requires: []
  context: [source-files, architecture-decisions]
  phase: build
  standalone: true
---

# Architecture Crosscut

**Value:** Simplicity -- catching cross-cutting concerns early prevents ad hoc
solutions from multiplying across the codebase. One deliberate pattern is
simpler than ten accidental ones.

## Purpose

Watches for cross-cutting concerns during implementation that lack documented
architectural decisions. When a pattern spans multiple components without a
recorded decision, stops implementation and triggers the ADR lifecycle. Prevents
inconsistent ad hoc approaches from becoming entrenched.

## Practices

### Cross-Cutting Concern Categories

During implementation, watch for these patterns appearing across component
boundaries:

1. **Authentication and authorization** -- access control, identity, roles,
   permissions, token management
2. **Logging and observability** -- structured logging, tracing, metrics,
   health checks, alerting
3. **Error handling** -- error types, propagation strategy, user-facing
   messages, retry policies
4. **Shared state management** -- caching, sessions, global configuration,
   feature flags
5. **Data access patterns** -- repository patterns, query strategies,
   connection management, transactions
6. **Communication patterns** -- HTTP clients, message publishing,
   serialization, API versioning

### Detection Triggers

A cross-cutting concern needs an ADR when any of these occur:

- You are about to implement the same pattern in a second component
- You find two existing components using different approaches for the same
  concern
- A new concern appears that will affect three or more components
- You are copying error handling, logging, or auth code between files

### Stop and Check

When a trigger fires:

1. Stop implementation immediately
2. Check `docs/ARCHITECTURE.md` for an existing decision on this concern
3. If a decision exists, follow it -- do not invent an alternative
4. If no decision exists, do not proceed with implementation

### Trigger ADR Lifecycle

When no decision exists for a detected cross-cutting concern:

1. Note the concern and the components it affects
2. Present the finding to the human: what the concern is, why it needs a
   decision, and what components are affected
3. Use the `architecture-adr` skill to create a new ADR for this concern
4. Resume implementation only after the ADR is merged

`docs/ARCHITECTURE.md` NEVER changes outside an isolated ADR PR. Do not add
a cross-cutting decision inline during implementation work.

**Do:**
- Stop as soon as you detect an undecided cross-cutting concern
- Present concrete evidence: which files, which pattern, what inconsistency
- Wait for the ADR to merge before resuming

**Do not:**
- Invent a "temporary" solution and plan to formalize it later
- Copy an existing ad hoc pattern assuming it was deliberate
- Batch multiple cross-cutting concerns into a single ADR

## Enforcement Note

This skill provides advisory guidance. It instructs the agent to detect
cross-cutting concerns and route them to the ADR lifecycle but cannot
mechanically prevent ad hoc solutions from being implemented. The agent
follows these practices by convention. If you observe cross-cutting patterns
being implemented without an ADR, point it out.

## Verification

After completing implementation guided by this skill, verify:

- [ ] Cross-cutting concern categories were monitored during implementation
- [ ] Any concern spanning multiple components was checked against
      docs/ARCHITECTURE.md
- [ ] No new cross-cutting pattern was implemented without a documented decision
- [ ] Undecided concerns were routed to the architecture-adr lifecycle
- [ ] Implementation resumed only after the relevant ADR was merged

If any criterion is not met, revisit the relevant practice before proceeding.

## Dependencies

This skill works standalone. For enhanced workflows, it integrates with:

- **architecture-adr:** Manages the ADR lifecycle triggered when an undecided
  cross-cutting concern is detected
- **architecture-refresher:** Loads existing decisions so crosscut detection
  can check whether a concern is already decided
- **architecture-probe:** The probe identifies cross-cutting concerns before
  building; this skill catches ones that emerge during building

Missing a dependency? Install with:
```
npx skills add jwilger/agent-skills --skill architecture-adr
```
