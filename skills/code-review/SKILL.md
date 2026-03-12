---
name: code-review
description: >-
  Three-stage code review protocol covering spec compliance, code quality, and
  domain integrity. Use this skill whenever the user asks to review code,
  prepare or check a PR, assess implementation quality, verify code against a
  spec or acceptance criteria, or audit for security and domain modeling issues.
  Triggers on: "review this code", "review my PR", "check implementation
  against spec", "code quality audit", "does this match the requirements",
  "review for security issues", "check for primitive obsession", "monetary
  precision review", "review test coverage gaps". Also activates when the user
  wants structured PASS/FAIL verdicts per requirement, severity-rated findings,
  or a gated review that blocks on critical issues. NOT for: style/formatting
  linting, debugging runtime errors, writing new code, or automated CI checks.
license: CC0-1.0
compatibility: Designed for any coding agent (Claude Code, Codex, Cursor, OpenCode, etc.)
metadata:
  author: jwilger
  version: "2.2.0"
  requires: [domain-modeling]
  context: [source-files, test-files, domain-types, git-history]
  phase: ship
  standalone: true
  constraint_resolution: true
---

# Code Review

**Value:** Feedback and communication -- structured review catches defects that
the author cannot see, and separating review into stages prevents thoroughness
in one area from crowding out another.

## Purpose

Teaches a systematic three-stage code review that evaluates spec compliance,
code quality, and domain integrity as separate passes. Prevents combined
reviews from letting issues slip through by ensuring each dimension gets
focused attention.

## Practices

### Three Stages, In Order

Review code in three sequential stages. Do not combine them. Each stage has a
single focus. A failure in an earlier stage blocks later stages -- there is no
point reviewing code quality on code that does not meet the spec.

**Stage 1: Spec Compliance.** Does the code do what was asked? Not more, not
less.

For each acceptance criterion or requirement:

1. Find the code that implements it
2. Find the test that verifies it
3. Confirm the implementation matches the spec exactly

Mark each criterion: PASS, FAIL (missing/incomplete/divergent), or CONCERN
(implemented but potentially incorrect). Flag anything built beyond
requirements as OVER-BUILT.

If any criterion is FAIL, stop. Return to implementation before continuing.

**Architecture Compliance Check** (run after the per-criterion loop, before
moving to Stage 2):

- If `docs/ARCHITECTURE.md` exists: verify this change complies with all
  documented constraints and patterns (Components, Patterns, Constraints
  sections). Non-compliance is a FAIL — same severity as a missing acceptance
  criterion.
- If `docs/ARCHITECTURE.md` does not exist: flag as a Stage 2 CONCERN:
  "No architecture document found; architectural compliance cannot be verified."

Include in Stage 1 output: `Architecture Compliance: PASS / FAIL / N/A (no ARCHITECTURE.md)`

### Vertical Slice Layer Coverage

For tasks that implement a vertical slice (adding user-observable behavior), perform the following checks in order:

1. **Entry-point wiring check (diff-based):** Examine whether the changeset includes modifications to the application's entry point or its wiring/routing layer. If the slice claims to add new user-observable behavior but the diff does not touch any wiring or entry-point code, the review **fails** unless the author explicitly documents why existing wiring already routes to the new behavior.

2. **End-to-end traceability:** Verify that a path can be traced from the application's external entry point, through any infrastructure or integration layer, to the new domain logic, and back to observable output. If any segment of this path is missing from the changeset and not already present in the codebase, flag the gap.

3. **Boundary-level test coverage:** Confirm that at least one test exercises the new behavior through the application's external boundary (e.g., an HTTP request, a CLI invocation, a message on a queue) rather than calling internal functions directly. Where the application architecture makes automated boundary tests feasible, their absence is a review concern.

4. **Test-level smell check:** If every test in the changeset is a unit test of isolated internal functions with no integration or acceptance-level test, flag this as a concern. The slice may be implementing domain logic without proving it is reachable through the running application.

**Stage 2: Code Quality.** Is the code clear, maintainable, and well-tested?

Review each changed file for:

- **Clarity:** Can you understand what the code does without extra context?
  Are names descriptive? Is the structure obvious?
- **Domain types:** Are semantic types used where primitives appear? You MUST follow
  the `domain-modeling` skill for primitive obsession detection.
- **Error handling:** Are errors handled with typed errors? Are all paths
  covered?
- **Test quality:** Do tests verify behavior, not implementation? Is coverage
  adequate for the changed code?
- **YAGNI:** Is there unused code, speculative features, or premature
  abstraction?

Categorize findings by severity:
- CRITICAL: Bug risk, likely to cause defects
- IMPORTANT: Maintainability concern, should fix before merge
- SUGGESTION: Style or minor improvement, optional

If any CRITICAL issue exists, stop. Return to implementation.

**Stage 3: Domain Integrity.** Final gate -- does the code respect domain
boundaries?

Check for:

1. **Compile-time enforcement opportunities:** Are tests checking things the
   type system could enforce instead?
2. **Domain type consistency:** Are semantic types used at all boundaries, or
   do primitives leak through?
3. **Validation placement:** Is validation at construction (parse-don't-validate),
   not scattered through business logic?
4. **State representation:** Can the types represent invalid states? Are bool
   fields hiding state machines? (See `domain-modeling` bool-as-state check.)
5. **Convention compliance:** Do types and patterns match project conventions?
   Apply the Convention Over Precedent rule -- existing code that violates a
   convention is not a defense.

Flag issues but do not block on suggestions, EXCEPT convention violations --
those are blocking per the Convention Over Precedent rule.

### Review Output

Produce a structured summary after all three stages:

```
REVIEW SUMMARY
Stage 1 (Spec Compliance): PASS/FAIL
Stage 2 (Code Quality): PASS/FAIL/PASS with suggestions
Stage 3 (Domain Integrity): PASS/FAIL/PASS with flags

Overall: APPROVED / CHANGES REQUIRED

If CHANGES REQUIRED:
  1. [specific required change]
  2. [specific required change]
```

### Structured Review Evidence

After completing all three stages, produce a REVIEW_RESULT evidence packet
containing: per-stage verdicts {stage, verdict (PASS/FAIL), findings
[{severity, description, file, line?, required_change?}]}, overall_verdict,
required_changes_count, blocking_findings_count.

When `pipeline-state` is provided in context metadata, the code-review skill
operates in **pipeline mode** and stores the evidence to
`.factory/audit-trail/slices/<slice-id>/review.json`. When running
standalone, the evidence is informational only (not stored).

In **factory mode**, the full team reviews before the pipeline pushes code --
this is the quality checkpoint that replaces consensus-during-build. All
blocking review feedback must be addressed before push. See
`references/mob-review.md` for the factory mode review subsection.

### File-Based Review Artifacts

Review findings MUST be written to `.reviews/` files as the default
persistence mechanism. Messages are supplementary coordination signals
only — they do not survive context compaction.

- **Naming:** `<reviewer-name>-<task-slug>.md` (e.g., `kent-beck-user-login.md`)
- **Content:** Full structured review output (all three stages)
- **Location:** `.reviews/` directory (add to `.gitignore`)
- Messages say "review posted to .reviews/" — substantive feedback lives in
  files only

This ensures review findings survive context compaction, agent restarts, and
harnesses that lack inter-agent messaging.

### Non-Blocking Feedback Escalation

Non-blocking items (SUGGESTION severity) that appear in 2+ consecutive
reviews of different slices MUST escalate to blocking (IMPORTANT severity).
Track recurrence by checking previous review files in `.reviews/`.

This prevents persistent quality issues from being perpetually deferred as
"just a suggestion."

### User-Facing Behavior Verification

When a GWT scenario describes user-visible behavior (UI elements, displayed
messages, visual changes), the changeset MUST include code that produces
that visible output. An API-only implementation when the scenario describes
UI interaction is a spec compliance failure — the slice is incomplete.

### Convention Over Precedent

Written conventions override observed patterns. When a review finding
conflicts with a project convention (CLAUDE.md, AGENTS.md, crate-level docs,
architectural decision records) but matches existing code in the codebase,
the finding is still valid. Existing code that violates a convention is tech
debt, not precedent.

Rules:

1. **Never downgrade on the basis of existing code.** A convention violation
   is blocking regardless of how many files already contain the same mistake.
2. **Flag the new code as blocking.** Apply the same severity you would if no
   prior code existed.
3. **Note existing violations as refactoring candidates.** In the review
   output, add a separate note listing files where the same anti-pattern
   already exists so the team can schedule cleanup.

Example: a project convention says "use the typestate pattern for state
machines." The new code uses `struct Foo { is_active: bool }` because three
existing files do the same. The review must block the new code AND note the
three existing files as tech debt.

### Handling Disagreements

When your review finding conflicts with the implementation approach:

1. State the concern with specific code references
2. Explain the risk -- what could go wrong
3. Propose an alternative
4. If no agreement after one round, escalate to the user

You exist to catch what the author missed, not to block progress.

### Business Value and UX Awareness

During Stage 1, also consider:

- Does this slice deliver visible user value?
- Are acceptance criteria specific and testable (not vague)?
- Does the user journey remain coherent after this change?
- Are edge cases and error states handled from the user's perspective?

These are not blocking concerns but should be noted when relevant.

## Enforcement Note

- **Standalone mode**: Advisory. The agent cannot mechanically prevent
  merging without review.
- **Pipeline mode**: Gating. Review verdicts block pipeline progression --
  FAIL or CHANGES REQUIRED halts the slice.

**Hard constraints:**
- Stage 1 FAIL blocks later stages: `[H]`
- Convention violation (Convention Over Precedent rule): `[RP]`

See `CONSTRAINT-RESOLUTION.md` in the template directory for pipeline
rework budget conflicts.

## Constraints

- **Non-blocking escalation**: The escalation rule triggers when the SAME
  issue (not just the same category) appears in 2+ consecutive reviews of
  DIFFERENT slices. Varying the wording of the same concern to avoid
  triggering escalation is a violation. The test is: would a human reviewer
  recognize these as the same underlying issue?
- **Convention Over Precedent**: "Written conventions" means conventions
  documented in CLAUDE.md, AGENTS.md, ADRs, or crate/package-level
  documentation. Patterns observed only in existing code are precedent, not
  convention. But if a pattern is universal (100% of files follow it) and
  no written convention contradicts it, flag it as a candidate for
  documentation -- don't just ignore it.
- **Vertical slice coverage**: The layer coverage check applies when the
  change modifies user-observable behavior. "User-observable" means a human
  using the application would notice a difference. Infrastructure changes
  that improve performance but don't change behavior are not user-observable.
  A new API endpoint IS user-observable even if no UI exists yet.

## Verification

After completing a review guided by this skill, verify:

- [ ] All three stages were performed separately, in order
- [ ] docs/ARCHITECTURE.md compliance checked as a named Stage 1 item
- [ ] Every acceptance criterion was mapped to code and tests in Stage 1
- [ ] Each changed file was assessed for clarity and domain type usage in Stage 2
- [ ] Domain integrity was checked for compile-time enforcement opportunities in Stage 3
- [ ] Convention violations were not downgraded due to matching existing code
- [ ] A structured summary was produced with clear PASS/FAIL per stage
- [ ] Any CHANGES REQUIRED items list specific, actionable fixes
- [ ] Review findings written to `.reviews/` files (not messages only)
- [ ] Recurring non-blocking items escalated to blocking when seen in 2+ reviews
- [ ] User-facing behavior verification applied to UI-describing scenarios

If any criterion is not met, revisit the relevant stage before finalizing.

## Dependencies

This skill works standalone. For enhanced workflows, it integrates with:

- **domain-modeling:** Provides the primitive obsession and parse-don't-validate
  principles referenced in Stage 2 and Stage 3
- **tdd:** Reviews often follow a TDD cycle; this skill validates the
  output of that cycle
- **mutation-testing:** Can follow code review as an additional quality gate

Missing a dependency? Install with:
```
npx skills add jwilger/agent-skills --skill domain-modeling
```
