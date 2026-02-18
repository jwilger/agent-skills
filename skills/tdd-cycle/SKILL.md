---
name: tdd-cycle
description: >-
  Red-green-domain-commit TDD cycle with strict phase boundaries, domain
  review checkpoints, and mandatory commit gates. Activate when writing
  tests, implementing features, or doing test-driven development. Teaches
  one-test-at-a-time discipline with mandatory domain modeling review after
  each phase and a hard commit gate before the next RED phase.
license: CC0-1.0
compatibility: Requires git and a test runner (jest, pytest, cargo test, go test, etc.)
metadata:
  author: jwilger
  version: "1.0"
  requires: []
  context: [test-files, domain-types, source-files]
  phase: build
  standalone: true
---

# TDD Cycle

**Value:** Feedback -- short cycles with verifiable outcomes keep AI-generated
code honest. Each phase produces evidence (test output, compiler output) that
confirms progress or exposes drift.

## Purpose

Teaches the red-green-domain-commit cycle: write one failing test, review
it for domain integrity, implement minimally, review the implementation,
commit. This five-step rhythm prevents primitive obsession,
over-engineering, and untested complexity from accumulating. Works with
any language and test framework.

## Practices

### Detect the Test Runner

!`if [ -f Cargo.toml ]; then echo "Language: Rust | Test runner: cargo test"; elif [ -f package.json ]; then if grep -q vitest package.json 2>/dev/null; then echo "Language: TypeScript/JavaScript | Test runner: npx vitest"; elif grep -q jest package.json 2>/dev/null; then echo "Language: TypeScript/JavaScript | Test runner: npx jest"; else echo "Language: TypeScript/JavaScript | Test runner: npm test"; fi; elif [ -f pyproject.toml ] || [ -f setup.py ]; then echo "Language: Python | Test runner: pytest"; elif [ -f go.mod ]; then echo "Language: Go | Test runner: go test ./..."; elif [ -f mix.exs ]; then echo "Language: Elixir | Test runner: mix test"; else echo "Language: unknown | Test runner: unknown (configure manually)"; fi`

Use the detected test runner for all "run the test" steps below.

### Start from the Outside In

The TDD cycle begins at the outermost testable layer of the application.
Before writing unit tests, write a BDD-style acceptance test that describes
how the application as a whole should behave for a given scenario. If the
project uses event modeling (see the `event-modeling` skill), GWT scenarios
become these outermost tests directly.

1. Write an acceptance test for the next scenario. Use the test framework's
   mechanism for pending or ignored tests so it does not block the suite:
   ```
   #[ignore = "acceptance: place order with valid cart"]
   ```
   ```python
   @pytest.mark.skip(reason="acceptance: place order with valid cart")
   ```
   ```typescript
   it.skip("places an order with a valid cart", () => { ... });
   ```
2. Run the suite to confirm it is recognized and skipped.
3. Drill down: identify the first unit of behavior the acceptance test
   needs. Write a unit test for that unit and enter the five-step cycle
   below.
4. After the unit tests pass, remove the pending/ignore marker from the
   acceptance test. Run it.
5. If the acceptance test passes, the scenario is complete. If it fails,
   identify the next missing unit and repeat from step 3.

This outside-in rhythm ensures every unit test exists because an acceptance
test demanded it. No speculative unit tests, no untested integration gaps.
The outer loop provides the feedback that keeps the inner loop honest.

### Acceptance Tests Target the Application Boundary

An acceptance test for a vertical slice must exercise the application through its **public boundary** — the point where external input enters the system. Depending on the project, this boundary might be an HTTP endpoint, a CLI command handler, a message consumer, a public API method, or any other entry point that a real user or external system would invoke.

A test that calls domain functions or internal modules directly is a **unit test**, not an acceptance test — even if it asserts on user-visible behavior. The distinction matters: acceptance tests verify that all architectural layers are wired together and that input flows through the full stack to produce the expected outcome.

When defining the acceptance test for a slice, ask: "If I removed all wiring between layers, would this test still pass?" If yes, it is not an acceptance test.

### Two-Level TDD for Vertical Slices

When building a vertical slice, the TDD cycle operates at two levels simultaneously:

1. **Outer level — Acceptance test (RED for most of the slice)**
   - Write the acceptance test first. It targets the application boundary and describes the slice's expected end-to-end behavior.
   - This test will fail (RED) and **stay red** while you build the inner layers. That is expected and correct.

2. **Inner level — Unit tests (red-green-domain-commit)**
   - Work inward from the boundary. For each layer or component needed by the slice, write a focused unit test, make it pass, review, commit.
   - Each inner cycle follows the full five-step discipline (RED → DOMAIN → GREEN → DOMAIN → COMMIT) with strict phase boundaries. The COMMIT step applies at every level — inner unit-test cycles also commit after each green-domain completion. The minimum guarantee is one commit per GWT scenario, but inner cycles may produce additional commits. This is correct behavior: more commits means more checkpoints and safer incremental progress.

3. **Outer test goes GREEN — Slice is wired**
   - The outer acceptance test passes only when all layers are implemented **and** wired together through the application boundary.
   - If all inner unit tests pass but the outer acceptance test is still red, the slice is not complete — there is missing wiring or integration.

Do not mark a slice as complete until the outer acceptance test passes. The outer test is the proof that the slice works as a vertical cut through the full stack, not just as isolated domain logic.

### Walking Skeleton First

The first vertical slice in any new project — or in any major new feature area that introduces new architectural layers — must be a **walking skeleton**: the thinnest possible end-to-end path that proves all architectural layers are connected and communicating.

A walking skeleton may use hardcoded values, stubs, or minimal implementations. Its purpose is not to deliver full functionality but to establish the integration path that every subsequent slice will build upon. The acceptance test for a walking skeleton verifies that input entering the application boundary flows through every required layer and produces an observable output — even if that output is trivial.

Build the walking skeleton before any other slice. It de-risks the architecture and gives every subsequent slice a proven wiring path to extend rather than create from scratch.

### When Automated Acceptance Tests Are Not Feasible

Where the application boundary is programmatically testable — CLI output assertions, HTTP response checks, headless browser tests, message queue consumers — write automated acceptance tests. They provide fast, repeatable feedback and should be the default choice.

Where automated testing of the boundary is not feasible (e.g., the slice's observable behavior requires visual inspection or physical interaction), document the specific manual verification steps the human must perform. These steps replace the automated acceptance test as the definition of "outer test passes" for that slice.

In either case, the human is the final verification gate. Automated acceptance tests increase confidence but do not replace human confirmation that the slice works as intended.

### A Compilation Failure IS a Test Failure

In compiled languages like Rust, a test referencing non-existent types will not
compile. This is expected -- `cargo test` failing because a type does not exist
IS the test failing. Do not pre-create types to avoid compilation failures. The
RED phase produces the failing test; the DOMAIN phase then creates just enough
type stubs to shift the failure from compilation error to runtime assertion/panic.

### The Five-Step Cycle

Every feature is built by repeating: RED → DOMAIN → GREEN → DOMAIN → COMMIT.

1. **RED** -- Write one failing test with one assertion. Only edit test files.
   Write the code you wish you had -- reference types and functions that
   SHOULD exist, even if they do not exist yet. Run the test. Paste the
   failure output (compilation errors count). Stop.
   - **Done when:** tests run and FAIL (compilation error OR assertion failure).
2. **DOMAIN (after red)** -- Review the test for primitive obsession and
   invalid-state risks. Create type definitions with stub bodies
   (`unimplemented!()`, `todo!()`, `raise NotImplementedError`). Do not
   implement logic. Stop.
   - **Done when:** tests COMPILE but still FAIL (assertion/panic, NOT compilation error).
3. **GREEN** -- Write the minimal code to make the test pass. Only edit
   production files. Run the test. Paste the passing output. Stop.
   - **Done when:** tests PASS with minimal implementation.
4. **DOMAIN (after green)** -- Review the implementation for domain
   violations: anemic models, leaked validation, primitive obsession that
   slipped through. If violations found, raise a concern and propose a
   revision. If clean, proceed to COMMIT.
   - **Done when:** types are clean and tests still pass.
5. **COMMIT** -- Committing is MANDATORY after every completed green-domain
   cycle. This is a hard gate: no new RED phase may begin until this commit
   is made. Run the full test suite one final time to confirm all tests
   pass. Stage all changes and create a git commit. The commit message MUST
   reference the GWT scenario being implemented (e.g.,
   `"GREEN: Given a valid email, When creating a user, Then the user is created"`).
   If refactoring is warranted, it happens AFTER this commit in a separate
   commit -- never mixed into this one.
   - **Done when:** git commit created with all passing tests and a message referencing the current scenario.

After step 5, either start the next RED phase or tidy the code (structural
changes only, separate commit).

### Worked Example (Rust)

**Happy path -- types do not exist yet:**

1. RED writes a test:
   ```rust
   let email = EmailAddress::new("test@example.com").unwrap();
   assert!(email.as_str() == "test@example.com");
   ```
   `cargo test` fails: `cannot find type EmailAddress`. Good -- that is a failing test.

2. DOMAIN creates the stub:
   ```rust
   pub struct EmailAddress(String);
   impl EmailAddress {
       pub fn new(s: &str) -> Result<Self, EmailAddressError> { todo!() }
       pub fn as_str(&self) -> &str { todo!() }
   }
   ```
   `cargo test` now compiles but panics at `todo!()`. Failure shifted from
   compilation error to runtime panic.

3. GREEN implements the validation logic. Test passes.

4. DOMAIN reviews the implementation. Types are clean. Proceed to COMMIT.

5. COMMIT: all tests pass, commit with message referencing the scenario.
   Cycle complete.

**Pushback path -- domain improves the test:**

1. RED writes:
   ```rust
   let user = create_user("test@example.com".to_string());
   ```
   Uses raw `String` for email.

2. DOMAIN reviews and pushes back: "Use `EmailAddress` newtype instead of
   `String` -- catches invalid emails at the type boundary."

3. RED revises:
   ```rust
   let email = EmailAddress::new("test@example.com").unwrap();
   let user = create_user(email);
   ```

4. DOMAIN creates the `EmailAddress` stub. Cycle continues.

### Phase Boundaries

Each phase edits only its own file types. This prevents drift.

| Phase | Can Edit | Cannot Edit |
|-------|----------|-------------|
| RED | Test files (`*_test.*`, `*.test.*`, `tests/`, `spec/`) | Production code, type definitions |
| DOMAIN | Type definitions (structs, enums, interfaces, traits) | Test logic, implementation bodies |
| GREEN | Implementation bodies, filling stubs | Test files, type signatures |
| COMMIT | Nothing -- only `git add` and `git commit` | All source files (code is frozen at this point) |

If blocked by a boundary, stop and return to the orchestrator. Never
circumvent boundaries.

### One Test, One Assertion

Write one test at a time. Each test has one assertion. If you need multiple
verifications, write multiple tests. Shared setup belongs in helper functions.

### Minimal Implementation

In GREEN, write only enough code to make the failing test pass. Do not add
error handling, flexibility, or features not demanded by the test. Future
tests will drive future features.

### Anti-pattern: "Type-First TDD"

Creating domain types before any test references them inverts TDD into
waterfall. Types must flow FROM tests, not precede them. If the orchestrator
creates a "define types" task that blocks a RED test task, the ordering is
wrong. NEVER create types before a test references them. The correct flow
is always: RED writes a test referencing types that do not exist, THEN
DOMAIN creates those types as stubs.

### Domain Review Has Veto Power

The domain review can reject a test or implementation that violates domain
modeling principles. When a concern is raised:

1. The concern is stated with the specific violation and a proposed alternative.
2. The affected phase responds substantively.
3. If consensus is not reached after two rounds, escalate to the human.

Do not dismiss domain concerns. Do not silently accept bad designs.

### Evidence, Not Assumptions

Always run the test. Always paste the output. "I expect it to fail" is not
evidence. "I know it will pass" is not evidence. Run the test. Paste the
output.

### Refactor as Exhale

After the COMMIT step (step 5) completes the cycle, tidy the code if
warranted. The working state is already committed. Make structural
improvements in a separate commit. Never mix behavioral and structural
changes.

### Drill-Down Testing

If a test fails with an unclear error, mark it ignored with a reason, write
a more focused test, and work back up once the lower-level tests pass.

```
#[ignore = "working on: test_balance_calculation"]
```

## Enforcement Note

This skill defines mandatory policy for phase boundaries and cycle
discipline, but a skill file alone cannot mechanically prevent violations;
mechanical enforcement requires hooks or orchestrator gates. On harnesses with plugin support (Claude Code hooks, OpenCode
event hooks), enforcement plugins add file-type restrictions and mandatory
domain review gates. On other harnesses, the agent follows these practices
by convention. If you observe the agent editing production code during RED
or skipping domain review, point it out. For available enforcement
plugins, see the [Harness Plugin Availability](../../README.md#harness-plugin-availability) table.

## Verification

After completing a cycle, verify:

- [ ] RED: Wrote exactly one test with one assertion
- [ ] RED: Ran the test and pasted the failure output
- [ ] DOMAIN (after red): Reviewed test for primitive obsession
- [ ] DOMAIN (after red): Created types with stub bodies, no implementation logic
- [ ] GREEN: Implemented minimal code, nothing beyond what the test demands
- [ ] GREEN: Ran the test and pasted the passing output
- [ ] DOMAIN (after green): Reviewed implementation for domain violations

**HARD GATE -- COMMIT (must pass before any new RED phase):**

- [ ] COMMIT: All tests pass
- [ ] COMMIT: Git commit created with message referencing the current GWT scenario
- [ ] COMMIT: No new RED phase started before this commit was made

If any criterion above the gate is not met, revisit the relevant phase.
If the COMMIT gate is not met, you MUST commit before proceeding. No
exceptions. No new test may be written until the commit exists.

## Dependencies

This skill works standalone. For enhanced workflows, it integrates with:

- **domain-modeling:** Teaches the principles domain review checks for
  (parse-don't-validate, semantic types, invalid states). Install this to
  strengthen domain review quality.
- **debugging-protocol:** Use when a test fails unexpectedly and the cause
  is not obvious from the error output.
- **architecture-decisions:** Consult ADRs before writing tests that touch
  architectural boundaries.

Missing a dependency? Install with:
```
npx skills add jwilger/agent-skills --skill domain-modeling
```
