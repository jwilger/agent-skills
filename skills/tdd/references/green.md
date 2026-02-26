# GREEN Phase -- Make the Failing Test Pass

## Goal

Write the MINIMAL production code to make the current failing test pass.
Nothing more.

**GREEN MEANS ONE ERROR AT A TIME.** Read the test output. Fix the FIRST
error only. Run tests again. If a new error appears, fix that one. Never
write more than ~10 lines of code between test runs. If your change is
more than 10 lines, you are almost certainly doing too much — break it
into smaller steps.

## File Restrictions

**You may ONLY edit production/implementation files.**

Production files live in `src/`, `lib/`, `app/` directories or are
otherwise clearly implementation code.

**You MUST NOT create, edit, or delete test files.** If the current failure
requires test changes, STOP and return to the orchestrator with a handoff
requesting RED phase rework. This is a hard boundary, not a suggestion.

**You must NOT edit:** test files, type-only definition files (those
with only stubs created by the domain phase), or any file in `tests/`,
`__tests__/`, `spec/`, or `test/` directories.

## Rules

1. **Address ONLY the exact failure message.** Read the specific error
   from the test output. Ask: "What is the SMALLEST change that
   addresses THIS SPECIFIC message?" Make only that change.

2. **One small change at a time.** Make a single change. Run tests.
   Check the result. Repeat until the test passes.

3. **Run tests after EACH change.** Paste the output every time. Never
   claim tests pass without pasted evidence.

4. **Stop IMMEDIATELY when the test passes.** Do not add error handling,
   flexibility, or features not demanded by the test. Do not refactor.
   Do not anticipate future tests. Stop.

5. **Delete unused/dead code.** If your change makes any existing code
   unreachable or unnecessary, remove it.

6. **Fill stubs, do not redefine types.** You implement method bodies
   for types that the domain phase created. When you encounter
   `unimplemented!()` or `todo!()`, replace it with the simplest code
   that passes the test. If compilation fails because a type is
   undefined (not just unimplemented), stop -- the domain phase should
   have created it.

## Iterative Discipline

The GREEN phase is an iterative loop, not a single leap:

1. Read the exact error message from the test output.
2. Identify the SMALLEST change that addresses THIS SPECIFIC error.
3. Make that change and nothing else.
4. Run tests. Paste output.
5. If a new error appears, go back to step 1.
6. When the test passes, stop.

**Why this matters:** Writing the full implementation in one pass bypasses
the feedback loop. You may write code that passes the test but introduces
subtle bugs, unnecessary complexity, or domain violations. The iterative
approach lets each error message guide you to the minimal correct solution.

**Common mistake:** "I know what the full implementation should be, so I'll
write it all at once." Even when you know the answer, the discipline of one
error at a time catches incorrect assumptions and keeps changes auditable.

## What NOT to Do

- Do not touch test files (that is the RED phase's job)
- Do not add methods not called by tests
- Do not implement validation not required by the failing test
- Do not keep dead code
- Do not add imports or helpers before addressing the actual failure

## Evidence Required

Provide all of the following before moving on:

- **Files modified** and the **specific change** made
- **Test output** showing the test passes (pasted, not described)

## Next Step

Now invoke `/tdd domain` for post-implementation domain review.
