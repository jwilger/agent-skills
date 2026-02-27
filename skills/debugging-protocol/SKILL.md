---
name: debugging-protocol
description: >-
  Systematic 4-step debugging: observe the failure, hypothesize a cause,
  experiment with one change, conclude with a verified fix. Activate when
  tests fail unexpectedly, errors occur, or behavior is wrong. Triggers
  on: "debug", "why is this failing", "unexpected error", "bug", "broken".
license: CC0-1.0
metadata:
  author: jwilger
  version: "2.0"
  requires: []
  context: [source-files, test-files, git-history]
  phase: build
  standalone: true
---

# Debugging Protocol

**Value:** Feedback -- systematic investigation produces understanding.
Understanding produces correct fixes. Skipping investigation produces
symptom fixes that hide bugs.

## Purpose

Teaches a disciplined 4-step debugging process that enforces root cause
analysis before any fix attempt. Prevents the most common failure mode:
jumping to a fix without understanding why the problem exists.

## Practices

### No Fixes Without Investigation

Never change code to fix a bug until you understand WHY it is broken.
When you see an error and immediately know the fix, that is exactly when
you are most likely to be wrong.

### Step 1: Observe

Gather facts. Do not interpret yet.

1. Read the full error message -- every line, not just the first
2. Identify the exact file and line where the failure occurs
3. Reproduce the failure consistently
4. Check recent changes: `git log --oneline -10` and `git diff`

**Output:** A clear statement of what is happening and where.

### Step 2: Hypothesize

Form a single, explicit hypothesis.

1. Find similar code that works correctly
2. Compare working vs failing: setup, inputs, state, configuration
3. State: "I believe the bug is caused by [X] because [evidence]"

**Output:** One hypothesis grounded in observed evidence.

### Step 3: Experiment

Test the hypothesis with one change.

1. Make ONE change to test the hypothesis
2. Observe the result
3. If wrong, UNDO the change completely
4. Form a new hypothesis incorporating what you learned

Do not change multiple things at once. If you change the import, the
type, and the logic simultaneously, you cannot know which change mattered.

**Output:** Confirmed or refuted hypothesis with evidence.

### Step 4: Conclude

Fix with confidence because you understand the root cause.

1. Write a failing test that reproduces the bug (if one does not exist)
2. Implement the fix targeting the root cause
3. Verify: the new test passes, all existing tests still pass

**Output:** A fix backed by a test, with all tests green.

### Three Strikes Rule

If three fix attempts fail, stop. The problem is not what you think it is.
Document what you tried, question your assumptions, and escalate.

## Enforcement Note

This skill provides advisory guidance. It instructs the agent to investigate
before fixing but cannot mechanically prevent premature fix attempts. If you
observe the agent skipping investigation, point it out.

## Verification

After debugging guided by this skill, verify:

- [ ] Observed the full error before making any code changes
- [ ] Stated an explicit hypothesis before each fix attempt
- [ ] Made only one change per hypothesis test
- [ ] Undid failed hypotheses before trying new ones
- [ ] Wrote or confirmed a failing test before implementing the fix
- [ ] All tests pass after the fix
- [ ] Did not exceed three fix attempts without escalating

## Dependencies

This skill works standalone with no required dependencies. It integrates with:

- **tdd:** When a test fails unexpectedly during TDD, this skill guides
  investigation before modifying code
- **domain-modeling:** If three fixes fail, the root cause may be a domain
  modeling problem -- escalate to domain review

Missing a dependency? Install with:
```
npx skills add jwilger/agent-skills --skill tdd
```
