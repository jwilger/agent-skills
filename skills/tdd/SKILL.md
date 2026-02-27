---
name: tdd
description: >-
  Five-step test-driven development cycle (RED, DOMAIN, GREEN, DOMAIN, COMMIT).
  Outside-in, one failing test at a time, domain review with veto power.
  Invoke with /tdd red | /tdd domain | /tdd green | /tdd commit.
license: CC0-1.0
metadata:
  author: jwilger
  version: "3.0"
  requires: []
  context: [test-files, domain-types, source-files]
  phase: build
  standalone: true
---

# TDD

**Value:** Feedback -- short cycles with verifiable evidence keep code honest.
Tests express intent; evidence confirms progress. Every cycle produces a
committed, working increment.

## Purpose

Teaches a five-step TDD cycle (RED, DOMAIN, GREEN, DOMAIN, COMMIT) that
builds software outside-in, one failing test at a time. Prevents primitive
obsession, skipped reviews, and untested complexity through mandatory domain
review with veto power at every cycle boundary.

## Practices

### The Five-Step Cycle

Every feature is built by repeating: RED -> DOMAIN -> GREEN -> DOMAIN -> COMMIT.

1. **RED** -- Write one failing test with one assertion. Only edit test files.
   Write the code you wish you had -- reference types and functions that do not
   exist yet. Run the test. Paste the failure output. Stop.
   Done when: tests run and FAIL (compilation error OR assertion failure).

2. **DOMAIN (after RED)** -- Review the test for primitive obsession and
   invalid-state risks. Create type definitions with stub bodies (`todo!()`,
   `raise NotImplementedError`, etc.). Do not implement logic. Stop.
   Done when: tests COMPILE but still FAIL (assertion/panic, not compilation).

3. **GREEN** -- Address the immediate failure. Read the exact error message.
   Make the SMALLEST change that fixes THIS SPECIFIC message. Run tests. If
   a new failure appears, repeat -- one error at a time (~10 lines max between
   test runs). Only edit production files. Paste output after each change.
   Done when: tests PASS with minimal implementation.

4. **DOMAIN (after GREEN)** -- Review the implementation for domain violations:
   anemic models, leaked validation, primitive obsession that slipped through.
   If violations found, raise a concern and propose a revision.
   Done when: types are clean and tests still pass.

5. **COMMIT** -- Run the full test suite. Stage all changes and create a git
   commit referencing the GWT scenario. Run `git status` after committing to
   verify no uncommitted files remain. This is a **hard gate**: no new RED
   phase may begin until this commit exists and the working tree is clean.
   Done when: git commit created, all tests passing, working tree clean.

After step 5, either start the next RED phase or tidy the code (structural
changes only, separate commit).

### Phase Sub-Invocations

Each phase loads its reference file with detailed instructions:

- `/tdd red` -- loads `references/red.md`
- `/tdd domain` -- loads `references/domain.md`
- `/tdd green` -- loads `references/green.md`
- `/tdd commit` -- loads `references/commit.md`

### Core Rules

**A compilation failure IS a test failure.** Do not pre-create types to avoid
compilation errors. Types flow FROM tests, never precede them. Creating domain
types before any test references them inverts TDD into waterfall.

**Unexpected failures trigger debugging.** When a test fails in GREEN with an
error you did NOT expect, switch to the `debugging-protocol` skill before
making any code change. The expected failure from RED is not the same as an
unexpected failure. Expected failures guide implementation; unexpected
failures require investigation.

**Domain review has veto power** over primitive obsession and invalid-state
representability. Max 2 rounds of debate, then escalate to the human. The
domain veto can only be overridden by the user, not by the implementing agent.

**Phase boundaries are strict.** Each phase edits only its own file types.
See `references/phase-boundaries.md` for the complete matrix.

| Phase  | Can Edit              | Cannot Edit                     |
|--------|-----------------------|---------------------------------|
| RED    | Test files            | Production code, type defs      |
| DOMAIN | Type definitions only | Test logic, implementation      |
| GREEN  | Production code       | Test files, type signatures     |
| COMMIT | Nothing (git only)    | All source files                |

If blocked by a boundary, stop and report. Never circumvent boundaries.

### Walking Skeleton First

The first vertical slice must be a walking skeleton: the thinnest end-to-end
path proving all architectural layers connect. It may use hardcoded values or
stubs. Build it before any other slice. It de-risks the architecture and gives
subsequent slices a proven wiring path to extend.

### Outside-In TDD

Start from an acceptance test at the application boundary -- the point where
external input enters the system. Drill inward through unit tests. The outer
acceptance test stays RED while inner unit tests go through their own
RED-DOMAIN-GREEN-DOMAIN-COMMIT cycles. The slice is complete only when the
outer acceptance test passes.

If there IS a UI, acceptance tests MUST exercise the actual UI through browser
automation (Playwright, Cypress, Selenium). A test that only POSTs to an HTTP
endpoint without rendering the UI does NOT satisfy the boundary requirement
for a web app slice with UI components.

A test that calls internal functions directly is a unit test, not an acceptance
test -- even if it asserts on user-visible behavior. See
`references/shared-rules.md` for boundary identification by project type.

### Hard Gate: COMMIT Before New RED

**No new RED phase may begin until the previous cycle's COMMIT exists.** This
is non-negotiable. The commit is the checkpoint that proves the cycle is
complete. Starting a new test without committing the previous cycle violates
the TDD discipline and risks losing work.

### Handoff Evidence

Each phase transition requires evidence. See `references/handoff-schema.md`
for the complete schema. Key evidence:

- **RED -> DOMAIN:** test file, test name, failure output (pasted, not described)
- **DOMAIN -> GREEN:** review status, type files created
- **GREEN -> DOMAIN:** implementation files, passing test output (pasted)
- **DOMAIN -> COMMIT:** review status, full test suite output

## Enforcement Note

This skill provides advisory guidance. It instructs the agent on correct TDD
behavior but cannot mechanically prevent violations. Phase boundaries and
handoff evidence requirements are enforced by convention -- the agent
self-checks against the phase boundary matrix and handoff schema before
transitioning. If you observe violations -- production code edited during RED,
domain review skipped, commits missing -- point it out.

## Verification

After completing a cycle, verify:

- [ ] Every failing test was written BEFORE its implementation
- [ ] Domain review occurred after EVERY RED and GREEN phase
- [ ] Phase boundary rules were respected (file-type restrictions)
- [ ] Evidence (test output) was provided at each transition
- [ ] Commit exists for every completed RED-GREEN cycle
- [ ] GREEN phase iterated one failure at a time (not full implementation in one pass)
- [ ] Working tree clean after every COMMIT (`git status` verified)
- [ ] Walking skeleton completed first (first vertical slice)
- [ ] Acceptance test exercises the actual application boundary
- [ ] No new RED phase started before the previous COMMIT was made

## Dependencies

This skill works standalone. For enhanced workflows, it integrates with:

- **domain-modeling:** Strengthens the domain review phases with
  parse-don't-validate, semantic types, and invalid-state prevention.
- **code-review:** Three-stage review (spec compliance, code quality, domain
  integrity) after TDD cycles complete.
- **debugging-protocol:** Invoked when unexpected failures occur during the
  GREEN phase to enforce investigation before fixes.

Missing a dependency? Install with:
```
npx skills add jwilger/agent-skills --skill domain-modeling
```
