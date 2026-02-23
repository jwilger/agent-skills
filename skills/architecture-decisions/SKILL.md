---
name: architecture-decisions
description: >-
  Architecture Decision Records with a four-phase lifecycle
  (RESEARCH → DRAFT → HOLD → MERGE). Activate when making technology
  choices, defining system boundaries, recording architectural decisions,
  or creating/updating ARCHITECTURE.md. Enforces research-before-writing
  and explicit merge authorization.
license: CC0-1.0
metadata:
  author: jwilger
  version: "2.0"
  requires: []
  context: [architecture-decisions, event-model, source-files]
  phase: decide
  standalone: true
---

# Architecture Decisions

**Value:** Communication -- architecture decisions grounded in verified
research ensure every contributor understands not just why a choice was
made, but that the reasoning reflects reality. Decisions based on
assumptions are decisions waiting to fail.

## Purpose

Teaches the agent to move architecture decisions through a strict
four-phase lifecycle: research dependencies first, draft from verified
findings, hold for review, merge only with explicit authorization.
Prevents decisions based on stale assumptions about external dependencies.
See `references/adr-lifecycle.md` for detailed phase rules.

## Practices

### Follow the Four-Phase ADR Lifecycle

Every architecture decision follows four phases in strict order. Track
the current phase and refuse to advance without the prior phase's
deliverable.

**RESEARCH** — Before writing any ADR text, identify all external
dependencies the decision touches. Read their source code and
documentation. Produce a written summary of findings. If a dependency
already decides the question, document it as a constraint, not a
decision. Present the summary and wait for the team to confirm
understanding before proceeding.

**DRAFT** — Write the ADR from verified research findings. Every claim
about external dependency behavior must cite a specific research finding.
Create the ADR as a PR on a dedicated `adr/<slug>` branch using
`references/adr-template.md`. The author does NOT merge.

**HOLD** — Signal hold and wait for explicit merge authorization.
Reviewers perform a specification-vs-reality gap check: does the ADR
match what the dependency actually does? Any reviewer may place a
blocking hold that must be explicitly lifted. Silence is not consent.
No implementation work depending on the ADR begins during HOLD.

**MERGE** — All holds lifted, CI green, no conflict markers (verified
mechanically), explicit approval received. Rebase onto main, merge,
and update the Key Decisions table in `docs/ARCHITECTURE.md`.

**Phase gate enforcement:**
- DRAFT attempted without RESEARCH findings → halt with warning:
  "RESEARCH phase incomplete. Summarize dependency findings first."
- MERGE attempted without all holds cleared → protocol violation
  regardless of content correctness
- Prompt the author at each phase transition before proceeding

When GitHub PRs are not available, use commit messages as the decision
record (see `references/adr-template.md` for the commit format). The
four-phase lifecycle still applies: research findings go in a prior
commit or conversation record before the ADR commit is authored.

### Maintain the Living Architecture Document

`docs/ARCHITECTURE.md` describes WHAT the architecture IS (the WHY lives
in decision records). Update it in the MERGE phase of every ADR. A stale
architecture document is worse than none.

Required sections: Overview, Key Decisions (linking to ADR PRs/commits),
Components, Patterns, Constraints.

### Facilitate Decisions Systematically

When multiple decisions are needed (new project, major redesign):

1. Inventory decision points across categories (see
   `references/adr-template.md` for the categories checklist)
2. Present the agenda to the human for review
3. For each decision: run the full four-phase lifecycle independently
4. Never batch -- one decision per record, each reviewed independently

### Review for Architectural Alignment

Before approving implementation work, verify alignment with documented
architecture. Does it follow documented patterns? Respect domain
boundaries? Introduce undecided dependencies? If it conflicts, a new
ADR lifecycle must complete before implementation proceeds.

## Enforcement Note

This skill provides advisory guidance with structural phase gates. The
agent tracks ADR phase state and halts advancement when prior-phase
deliverables are missing. It cannot mechanically prevent all violations
but will refuse to draft without research or merge without cleared holds.
If you observe the agent skipping a phase, point it out.

## Verification

After completing work guided by this skill, verify:

- [ ] Every structural change has a corresponding decision record
- [ ] RESEARCH phase produced a written dependency findings summary
- [ ] DRAFT cites specific research findings for dependency claims
- [ ] HOLD received explicit approval (not silence)
- [ ] No implementation work began before MERGE completed
- [ ] `docs/ARCHITECTURE.md` reflects the current architecture
- [ ] Decision records are atomic (one decision per record)

If any criterion is not met, halt and complete the missing phase.

## Dependencies

This skill works standalone. For enhanced workflows, it integrates with:

- **event-modeling:** Completed event models surface the decision points that
  need architectural choices (technology, boundaries, integration patterns)
- **domain-modeling:** Domain model constraints inform bounded context
  boundaries and aggregate design decisions
- **code-review:** Reviewers verify implementation aligns with documented
  architecture decisions

Missing a dependency? Install with:
```
npx skills add jwilger/agent-skills --skill event-modeling
```
