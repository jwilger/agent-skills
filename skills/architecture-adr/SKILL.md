---
name: architecture-adr
description: >-
  Architecture Decision Records with a four-phase lifecycle
  (RESEARCH, DRAFT, HOLD, MERGE). ADRs are PR bodies. docs/ARCHITECTURE.md
  updated with decision result in isolated PR. Activate when making
  technology choices or recording architectural decisions.
license: CC0-1.0
metadata:
  author: jwilger
  version: "2.0"
  requires: []
  context: [architecture-decisions, source-files]
  phase: decide
  standalone: true
---

# Architecture ADR

**Value:** Communication -- writing decisions down with context, alternatives,
and consequences ensures the team shares understanding. A decision that only
lives in someone's head is not a decision.

## Purpose

Manages Architecture Decision Records through a four-phase lifecycle that
enforces research before writing, explicit approval before merging, and clean
separation between decision records and implementation code. Prevents
undocumented decisions and ensures every architectural choice is traceable.

## Practices

### ADRs Are PR Bodies, Not Files

An ADR lives as the body of a pull request, not as a file committed to the
repository. This keeps decision discussion in the PR review thread and
prevents the repo from accumulating stale decision files.

The only file that changes in an ADR PR is `docs/ARCHITECTURE.md`, which
records the decision RESULT -- a brief statement of what was decided. No
rationale, alternatives, or decision status goes into that file. The full
record lives in the PR body, permanently accessible via the PR URL.

When GitHub PRs are not available (local-only work, offline), use a
detailed commit message on the `adr/<slug>` branch as the record instead.

### Four-Phase Lifecycle

Every ADR moves through four phases in order. No phase may be skipped.

**RESEARCH.** Investigate the decision space before writing anything.

1. Read existing `docs/ARCHITECTURE.md` for related decisions
2. Examine the codebase for current patterns and constraints
3. Research options: documentation, benchmarks, community practice
4. Cite findings with sources -- no unsupported claims

**DRAFT.** Write the ADR as a PR body using the template in
`references/adr-template.md`.

1. Create a branch: `adr/<slug>` off `main`
2. Update `docs/ARCHITECTURE.md` with the decision result (one line)
3. Open a PR with the ADR as the body
4. Request review from relevant stakeholders

**HOLD.** The ADR awaits explicit approval.

1. Silence is NOT consent -- someone must explicitly approve
2. Address review feedback by updating the PR body
3. If the decision changes materially during review, return to RESEARCH

**MERGE.** The approved ADR is merged.

1. The PR author does NOT merge their own ADR
2. A reviewer with approval authority merges
3. The merged PR becomes the permanent record

### Isolation Rule

An ADR PR contains ONLY the `docs/ARCHITECTURE.md` update. No implementation
code, no test changes, no configuration changes. If implementation requires
the decision, it goes in a separate PR that references the ADR PR.

`docs/ARCHITECTURE.md` NEVER changes outside an isolated ADR PR. If you need
to update an architectural decision during implementation work, stop, create
a new ADR PR, and get it merged first.

### One Decision Per ADR

Each ADR addresses exactly one decision. Even if two decisions seem related,
they get separate PRs. This ensures each decision has its own approval
lifecycle and can be reverted independently.

### Decision Categories

Use these categories when writing the ADR (match the probe categories):

- Technology stack
- Domain architecture
- Integration patterns
- Cross-cutting concerns
- Deployment and infrastructure
- Data management

### Superseding Decisions

When a new decision supersedes an old one:

1. Reference the old ADR PR in the "Supersedes" field
2. Update `docs/ARCHITECTURE.md` to reflect the new decision
3. Do not delete or modify the old PR -- it remains as history

## Enforcement Note

This skill provides advisory guidance. It instructs the agent on the ADR
lifecycle but cannot mechanically prevent decisions from being made without
ADRs or merged without approval. On harnesses with PR integration, the
four-phase lifecycle maps naturally to PR workflow. On all harnesses, the
agent follows these practices by convention. If you observe architectural
decisions being made without an ADR, point it out.

## Verification

After completing an ADR guided by this skill, verify:

- [ ] Research was completed with cited findings before drafting
- [ ] The ADR is a PR body (or commit message if PRs unavailable)
- [ ] The PR branch follows `adr/<slug>` naming off `main`
- [ ] `docs/ARCHITECTURE.md` contains only the decision result (no rationale)
- [ ] The PR contains no implementation code -- only ARCHITECTURE.md changes
- [ ] HOLD phase required explicit approval (not silence)
- [ ] The author did not merge their own ADR
- [ ] Each ADR addresses exactly one decision

If any criterion is not met, revisit the relevant practice before proceeding.

## Dependencies

This skill works standalone. For enhanced workflows, it integrates with:

- **architecture-probe:** Identifies decision points that become ADRs
- **architecture-refresher:** Loads decisions from docs/ARCHITECTURE.md
  before build phases to ensure implementation respects them
- **architecture-crosscut:** Detects new cross-cutting concerns during
  implementation that need ADR treatment

Missing a dependency? Install with:
```
npx skills add jwilger/agent-skills --skill architecture-probe
```
