---
name: refactoring
description: >-
  Safe refactoring patterns under green tests. Extract, rename, move,
  simplify -- always in a separate commit from behavior changes. Activate
  when cleaning up code after TDD GREEN, during code review rework, or
  when the codebase needs structural improvement. Triggers on: "refactor",
  "clean up", "extract method", "rename", "simplify".
license: CC0-1.0
metadata:
  author: jwilger
  version: "1.0"
  requires: []
  context: [source-files, test-files]
  phase: build
  standalone: true
---

# Refactoring

**Value:** Simplicity -- refactoring removes accidental complexity without
changing behavior. Each refactoring step keeps tests green, making the
codebase easier to understand and extend.

## Purpose

Teaches safe, disciplined refactoring as a distinct activity from feature
development. Prevents the common failure mode of mixing behavior changes
with structural changes in the same commit, which makes both harder to
review, debug, and revert.

## Practices

### The Cardinal Rule: Green Before, Green After

Never start a refactoring without all tests passing. Never finish a
refactoring with any test failing. If a test breaks during refactoring,
undo the change -- you changed behavior, not just structure.

Run the full test suite before starting and after every individual
refactoring step. "I'm pretty sure the tests still pass" is not evidence.

### Separate Commits for Behavior and Structure

Never combine behavior changes and refactoring in the same commit.

**Correct sequence:**
1. RED-GREEN-DOMAIN-COMMIT (behavior change)
2. Refactor commit (structural change only, tests stay green)

**Incorrect:** Implementing a feature AND renaming variables AND extracting
methods in a single commit. This makes review impossible and revert risky.

### One Refactoring at a Time

Apply one refactoring operation per step. Run tests. Commit if green.
Then apply the next. Chaining multiple refactorings without testing
between them hides which change broke things.

### Safe Refactoring Catalog

Apply these patterns when you recognize the code smell they address:

**Extract Method/Function** -- When a block of code has a clear purpose
that can be named. Extract it into a function with a descriptive name.
The function name should explain WHY, not WHAT.

**Inline Method/Function** -- When a function body is as clear as its
name, or when indirection adds no value. Replace the call with the body.

**Rename** -- When a name does not communicate intent. Variable, function,
type, module, file -- rename to match domain language. Update all
references. Check the glossary for canonical terms.

**Move** -- When code is in the wrong module or file. Move it to where
it belongs based on domain boundaries and cohesion. Update imports.

**Introduce Explaining Variable** -- When an expression is complex.
Extract it into a named variable that explains its purpose.

**Replace Conditional with Polymorphism** -- When a conditional (if/else,
switch/match) selects behavior based on type. Replace with polymorphic
dispatch. This is a larger refactoring -- commit intermediate steps.

**Remove Dead Code** -- When code is unreachable or unused. Delete it.
Do not comment it out. Version control remembers.

**Simplify Conditional** -- When a boolean expression is complex.
Decompose into named predicates or consolidate redundant branches.

### When NOT to Refactor

- Tests are failing (fix first, refactor after)
- You are in the middle of a TDD GREEN phase (finish GREEN, commit, then
  refactor)
- The refactoring requires changing test assertions (that is a behavior
  change, not a refactoring)
- You are refactoring code you do not understand yet (read it first,
  understand it, then refactor)

### Refactoring During TDD

After every COMMIT phase in TDD, evaluate: does the code need structural
improvement? If yes, refactor in a separate commit before starting the
next RED phase. This keeps the codebase clean without mixing concerns.

The refactoring step is MANDATORY in the ensemble-team workflow. Every
commit cycle includes a refactoring check.

### Refactoring During Code Review

When code review identifies structural issues (naming, duplication,
complexity), address them as refactoring commits separate from any
functional fixes. This makes review of the fix straightforward.

## Enforcement Note

This skill provides advisory guidance. It instructs the agent to separate
refactoring from behavior changes and to keep tests green throughout.
On harnesses with delegation primitives, the separation can be structurally
enforced by running tests between refactoring steps. No mechanical
enforcement prevents mixing behavior and structure in one commit. If you
observe the agent combining refactoring with feature work, point it out.

## Verification

After completing work guided by this skill, verify:

- [ ] All tests passed before refactoring started
- [ ] All tests pass after every refactoring step
- [ ] No behavior changed (test assertions unchanged)
- [ ] Refactoring is in a separate commit from behavior changes
- [ ] Each commit contains one logical refactoring operation
- [ ] Names match domain glossary where applicable
- [ ] Dead code was removed, not commented out

If any criterion is not met, undo the refactoring and try again.

## Dependencies

This skill works standalone. For enhanced workflows, it integrates with:

- **tdd:** Refactoring happens after each TDD COMMIT phase. The TDD skill
  references the refactoring step as mandatory in the cycle.
- **code-review:** Review findings that identify structural issues feed
  into refactoring work.
- **domain-modeling:** Domain model types and glossary inform naming
  decisions during rename refactorings.

Missing a dependency? Install with:
```
npx skills add jwilger/agent-skills --skill tdd
```
