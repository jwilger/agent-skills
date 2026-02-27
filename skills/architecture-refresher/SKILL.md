---
name: architecture-refresher
description: >-
  Read docs/ARCHITECTURE.md before starting build phases. Ensures current
  architectural context is loaded before implementation. Activate at the
  start of every TDD red, domain, green, or review phase.
license: CC0-1.0
metadata:
  author: jwilger
  version: "1.0"
  requires: []
  context: [architecture-decisions]
  phase: build
  standalone: true
---

# Architecture Refresher

**Value:** Communication -- loading documented decisions before building
ensures implementation aligns with team agreements. Building without reading
decisions wastes effort on approaches the team already rejected.

## Purpose

Ensures the agent reads `docs/ARCHITECTURE.md` at the start of every build
phase. Catches conflicts between implementation and documented architecture
before code is written, not after review.

## Practices

### Read Before Building

At the start of any build phase (TDD red, TDD green, domain modeling, code
review, refactoring), read `docs/ARCHITECTURE.md` in full. This is a
non-negotiable first step -- do it before writing any code or tests.

If the file does not exist, note its absence and proceed. The absence itself
is useful information: no architectural decisions have been recorded yet.

### Note Key Decisions

After reading, identify decisions relevant to the current task:

1. Technology choices that constrain implementation options
2. Boundary definitions that determine where code belongs
3. Patterns that must be followed (error handling, data access, etc.)
4. Constraints that limit acceptable approaches

Hold these in working context for the duration of the build phase.

### Flag Conflicts

During implementation, if any code you are writing or reviewing conflicts
with a documented decision:

1. Stop implementation immediately
2. State the conflict: what the code does versus what the decision says
3. Do not override the documented decision in code
4. If the decision should change, trigger the `architecture-adr` lifecycle
   to update it through proper process

`docs/ARCHITECTURE.md` NEVER changes outside an isolated ADR PR.

## Enforcement Note

This skill provides advisory guidance. It instructs the agent to read
architectural decisions before building but cannot mechanically prevent
implementation from starting without a read. The agent follows this practice
by convention. If you observe building starting without an architecture
refresh, point it out.

## Verification

After completing a build phase guided by this skill, verify:

- [ ] docs/ARCHITECTURE.md was read before any code changes
- [ ] Relevant decisions were identified for the current task
- [ ] No implementation conflicts with documented decisions
- [ ] Any needed decision changes were routed to an ADR, not made in code

If any criterion is not met, revisit the relevant practice before proceeding.

## Dependencies

This skill works standalone. For enhanced workflows, it integrates with:

- **architecture-adr:** Manages the lifecycle for updating decisions when
  conflicts are discovered during build phases
- **architecture-probe:** Identifies missing decisions before building starts
- **tdd:** The refresher runs at the start of each TDD phase to ensure
  architecture alignment throughout the cycle

Missing a dependency? Install with:
```
npx skills add jwilger/agent-skills --skill architecture-adr
```
