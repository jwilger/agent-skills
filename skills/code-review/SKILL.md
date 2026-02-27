---
name: code-review
description: >-
  Three-stage code review protocol: spec compliance, code quality, and domain
  integrity. Activate when reviewing code, preparing PRs, assessing
  implementation quality, or checking that code matches requirements. Triggers
  on: "review this code", "prepare PR", "check implementation", "code quality",
  "does this match the spec".
license: CC0-1.0
metadata:
  author: jwilger
  version: "2.0"
  requires: [domain-modeling]
  context: [source-files, test-files, domain-types, git-history]
  phase: ship
  standalone: true
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

This skill provides advisory guidance. It instructs the agent on correct
review procedure but cannot mechanically prevent skipping stages or merging
without review. The agent follows these practices by convention. If you
observe stages being skipped, point it out.

## Verification

After completing a review guided by this skill, verify:

- [ ] All three stages were performed separately, in order
- [ ] Every acceptance criterion was mapped to code and tests in Stage 1
- [ ] Each changed file was assessed for clarity and domain type usage in Stage 2
- [ ] Domain integrity was checked for compile-time enforcement opportunities in Stage 3
- [ ] Convention violations were not downgraded due to matching existing code
- [ ] A structured summary was produced with clear PASS/FAIL per stage
- [ ] Any CHANGES REQUIRED items list specific, actionable fixes
- [ ] User-facing behavior verification applied to UI-describing scenarios

If any criterion is not met, revisit the relevant stage before finalizing.

## Dependencies

This skill works standalone. For enhanced workflows, it integrates with:

- **domain-modeling:** Provides the primitive obsession and parse-don't-validate
  principles referenced in Stage 2 and Stage 3
- **tdd:** Reviews often follow a TDD cycle; this skill validates the
  output of that cycle

Missing a dependency? Install with:
```
npx skills add jwilger/agent-skills --skill domain-modeling
```
