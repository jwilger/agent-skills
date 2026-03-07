# GREEN Phase -- Address the Immediate Error

## Goal

Address the IMMEDIATE error from the test output. Before every change,
check scope: can this be fixed with roughly function-scope work (~20
lines in one file)? If yes, implement it. If no, drill down by writing
a failing unit test for the smallest piece needed.

The GREEN agent's goal is NEVER "make the acceptance test pass." It is
always "address the immediate error" — one error at a time, with a scope
check before each change.

## File Restrictions

**You may ONLY edit production/implementation files.**

Production files live in `src/`, `lib/`, `app/` directories or are
otherwise clearly implementation code.

**You must NOT edit:** test files, type-only definition files (those
with only stubs created by the domain phase), or any file in `tests/`,
`__tests__/`, `spec/`, or `test/` directories.

**Exception:** When drilling down, you write a NEW failing unit test.
This is the one case where the GREEN agent creates a test file — because
the drill-down makes you the RED/ping agent at the inner level. See
Drill-Down below.

## Rules

1. **Address ONLY the exact failure message.** Read the specific error
   from the test output. Ask: "What is the SMALLEST change that
   addresses THIS SPECIFIC message?" Make only that change.

2. **Scope check before every change.** Before implementing, ask: "Can
   I fix this with roughly function-scope work (~20 lines, one file)?"
   - **YES**: Make the change. Run tests. Check the next error.
   - **NO**: STOP implementing. Drill down (see below).

3. **One small change at a time.** Make a single change. Run tests.
   Check the result. Repeat the scope check for any new error.

4. **Run tests after EACH change.** Paste the output every time. Never
   claim tests pass without pasted evidence.

5. **Stop IMMEDIATELY when the test passes.** Do not add error handling,
   flexibility, or features not demanded by the test. Do not refactor.
   Do not anticipate future tests. Stop.

6. **Delete unused/dead code.** If your change makes any existing code
   unreachable or unnecessary, remove it.

7. **Fill stubs, do not redefine types.** You implement method bodies
   for types that the domain phase created. When you encounter
   `unimplemented!()` or `todo!()`, replace it with the simplest code
   that passes the test. If compilation fails because a type is
   undefined (not just unimplemented), stop -- the domain phase should
   have created it.

## Scope Check

The scope check is the core discipline of outside-in TDD. It prevents
the common failure mode where a single GREEN session tries to build an
entire application to make an acceptance test pass.

**Before EVERY change, ask:**

> "Can I fix this error with roughly function-scope work (~20 lines in
> one file)?"

**YES path:**
1. Make the change.
2. Run tests. Paste output.
3. If a new error appears, do the scope check again for the new error.
4. When the test passes, stop.

**NO path (drill down):**
1. The change requires new modules, multiple files, or significant
   architecture work.
2. STOP the current GREEN phase.
3. Write a NEW failing unit test for the smallest piece needed to
   make progress on the current error.
4. Return the DRILL_DOWN format (see Evidence Required below).
5. The orchestrator routes the drill-down through a standard TDD cycle
   with swapped roles — you wrote the test, so someone else implements it.

**Examples of function-scope work (YES):**
- Changing a string literal ("Hello World" → "Component Showcase")
- Adding a return statement
- Implementing a method body with a few lines of logic
- Adding a match arm or case branch

**Examples requiring drill-down (NO):**
- Setting up a new module with its own dependencies
- Creating a server entry point with routing
- Wiring multiple layers (handler → service → repository)
- Adding build system configuration (Cargo.toml features, etc.)

## What NOT to Do

- Do not touch test files (that is the RED phase's job — except during
  drill-down)
- Do not add methods not called by tests
- Do not implement validation not required by the failing test
- Do not keep dead code
- Do not add imports or helpers before addressing the actual failure
- Do not try to "make the acceptance test pass" in one session

## Evidence Required

### Standard return (test passes):

Provide all of the following before moving on:

- **Files modified** and the **specific change** made
- **Test output** showing the test passes (pasted, not described)

### Drill-down return (scope check fails):

When a scope check determines the change is too large:

- **Outer test**: Path to the test that is still failing
- **Outer error**: The error message that triggered the scope check
- **Inner test file**: Path to the new failing unit test you wrote
- **Inner test name**: Name of the new test
- **Inner failure output**: Test runner output for the new failing test
- **Rationale**: Why drill-down was needed (one sentence)

## Next Step

If the test passes: invoke `/tdd domain` for post-implementation domain review.

If drill-down: return to the orchestrator with the DRILL_DOWN evidence.
The orchestrator routes the inner test through a standard TDD cycle with
swapped roles (you wrote the test, so someone else implements it).
