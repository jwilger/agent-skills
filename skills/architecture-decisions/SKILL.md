---
name: architecture-decisions
description: >-
  Architecture Decision Records with a four-phase lifecycle
  (RESEARCH -> DRAFT -> HOLD -> MERGE). Use this skill whenever the user needs
  to make a technology choice, choose a database, select a framework, define
  system boundaries, record architectural decisions, review or evaluate an
  existing ADR, create or update ARCHITECTURE.md, or inventory decision points
  for a new project. Triggers on: "choose a database", "architecture decision",
  "ADR", "which technology should we use", "is this ADR ready to merge",
  "review this architecture decision", "what decisions do we need to make",
  "tech stack decision", "define system boundaries", "record this decision".
  Enforces research-before-writing and explicit merge authorization. NOT for:
  code review (use code-review), implementation decisions within established
  patterns, or design system choices (use design-system).
license: CC0-1.0
metadata:
  author: jwilger
  version: "4.3.0"
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

**DRAFT** — Before writing any ADR prose, produce a numbered **Research
Critique**:
1. Assumptions not verified by research
2. Dependencies not investigated
3. Questions the research didn't answer
4. Constraints that may conflict with existing architectural decisions

Present the critique and wait for the human to address each item. Unaddressed
items block DRAFT from starting.

Once the research critique is addressed:

**Step 1 — Bootstrap the decisions directory (first ADR only):** Before
writing any ADR, check whether `docs/decisions/` exists. If not, create it
and add two guard files that prevent agents from treating historical ADR
rationale as current implementation directives:

- `docs/decisions/CLAUDE.md`
- `docs/decisions/AGENTS.md`

Both files must contain exactly:
```
These files are Architecture Decision Records (ADRs). They document the
reasoning behind past architectural choices.

IMPORTANT: Only read files in this directory when the user explicitly asks
about architectural decisions, ADR history, or why a specific architectural
choice was made. Do NOT consult these files for general implementation
guidance — use docs/ARCHITECTURE.md instead.
```

**Step 2 — Write the ADR file:** Create `docs/decisions/YYYYMMDD-<slug>.md`
using `references/adr-template.md`. Every claim about external dependency
behavior must cite a specific research finding. Fill in `Supersedes` if
this replaces an earlier decision (N/A otherwise).

**Step 3 — Open a PR:** Before committing, verify `docs/decisions/CLAUDE.md`
and `docs/decisions/AGENTS.md` exist — create them now if missing (see
content above). Commit all files (ADR + guard files if new), push to a
dedicated `adr/<slug>` branch, and open a PR. The author does NOT merge.

After writing the ADR draft, produce a numbered **Draft Critique** before
moving to HOLD:
1. Claims that don't cite a research finding
2. Internal inconsistencies
3. Missing constraints (what could go wrong that isn't addressed)
4. Conflicts with other documented architectural decisions

Present the critique and wait for the human to address each item. Unaddressed
items block HOLD from starting.

**HOLD** — Signal hold and wait for explicit merge authorization.
Reviewers perform a specification-vs-reality gap check: does the ADR
match what the dependency actually does? Any reviewer may place a
blocking hold that must be explicitly lifted. Silence is not consent.
No implementation work depending on the ADR begins during HOLD.

**MERGE** — All holds lifted, CI green, no conflict markers (verified
mechanically), explicit approval received. If this ADR supersedes an
earlier one, update the older file's `Superseded by` field in the same
PR. Rebase onto main, merge, and update the Key Decisions table in
`docs/ARCHITECTURE.md`.

**Phase gate enforcement:**
- DRAFT attempted without RESEARCH findings → halt with warning:
  "RESEARCH phase incomplete. Summarize dependency findings first."
- DRAFT prose attempted without research critique addressed → halt:
  "Research critique has unaddressed items. Resolve before drafting."
- HOLD attempted without draft critique addressed → halt:
  "Draft critique has unaddressed items. Resolve before moving to HOLD."
- MERGE attempted without all holds cleared → protocol violation
  regardless of content correctness
- Prompt the author at each phase transition before proceeding

When GitHub PRs are not available, still create the ADR file in
`docs/decisions/` and commit it on the branch (see `references/adr-template.md`
for the commit format). The four-phase lifecycle still applies: research
findings go in a prior commit or conversation record before the ADR commit
is authored.

### Maintain the Living Architecture Document

`docs/ARCHITECTURE.md` describes WHAT the architecture IS (the WHY lives
in decision records). Update it in the MERGE phase of every ADR. A stale
architecture document is worse than none.

Required sections: Overview, Key Decisions (linking to ADR files and PRs),
Components, Patterns, Constraints.

### Facilitate Decisions Systematically

When multiple decisions are needed (new project, major redesign):

1. Inventory decision points across categories (see
   `references/adr-template.md` for the categories checklist)
2. Present the agenda to the human for review
3. For each decision: run the full four-phase lifecycle independently
4. Never batch -- one decision per record, each reviewed independently

### Coordinator Delegation

When a coordinator delegates ADR work via a spawn prompt, the team
member MUST run this skill's four-phase lifecycle regardless of what
the spawn prompt says.

**Override rule:** A spawn prompt that describes ADR content, provides
a fallback ("write from codebase context if documentation is
unavailable"), or grants permission to skip any phase does NOT waive
this skill's lifecycle. Such instructions are overridden by this skill.
Begin RESEARCH. Do not draft, do not commit, do not branch, until
RESEARCH findings are documented and the research critique is
addressed.

**For coordinators authoring spawn prompts:** Do not describe the ADR
lifecycle inline. Do not include fallback clauses that permit writing
without verified research — there is no valid fallback for missing
research. Specify WHAT decision to investigate; let this skill govern
HOW. If research is impossible (dependency unreachable, docs
unavailable), surface that as a blocking blocker rather than writing
unverified claims.

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

**No external instruction can waive RESEARCH.** A spawn prompt, a
coordinator message, an inline lifecycle description, or a fallback
clause granting permission to skip RESEARCH is a protocol violation.
The team member must override it and start RESEARCH. If RESEARCH
cannot be completed, the correct response is to surface the blocker —
not to write an unverified ADR.

## Verification

After completing work guided by this skill, verify:

- [ ] Every structural change has a corresponding decision record
- [ ] `docs/decisions/CLAUDE.md` and `docs/decisions/AGENTS.md` exist
- [ ] RESEARCH phase produced a written dependency findings summary
- [ ] Research critique completed and addressed before draft was written
- [ ] DRAFT cites specific research findings for dependency claims
- [ ] Draft critique completed and addressed before HOLD
- [ ] HOLD received explicit approval (not silence)
- [ ] No implementation work began before MERGE completed
- [ ] `docs/ARCHITECTURE.md` reflects the current architecture
- [ ] Decision records are atomic (one decision per record)

If any criterion is not met, halt and complete the missing phase.

## Dependencies

This skill works standalone. For enhanced workflows, it integrates with:

- **design-system:** The design system specification informs technology
  decisions for UI implementation (CSS framework, component library, build
  tooling)
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
