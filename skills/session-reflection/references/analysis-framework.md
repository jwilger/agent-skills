# Intervention Analysis Framework

Reference for categorizing, scoring, and prioritizing user interventions
during session reflection.

## Five-Category Taxonomy

### 1. Correction

The agent did the wrong thing. The system prompt or skill instructions did
not cover this case, or covered it ambiguously.

**Examples:**
- Agent modified a file it was told not to touch
- Agent used the wrong testing strategy for this project
- Agent created a class when the project uses functional patterns
- Agent committed without running tests first

**Root cause:** Missing instruction or ambiguous instruction in system prompt.

**Fix pattern:** Add explicit directive: "NEVER modify files in `vendor/`.
Only modify files in `src/` and `test/`."

### 2. Repetition

The agent was told the same thing it was told before, in this session or a
previous one. The instruction exists but did not stick.

**Examples:**
- "I already told you to use snake_case for file names"
- "Again, run the linter before committing"
- "We discussed this -- the API returns paginated results"

**Root cause:** Instruction exists but is advisory (not structural), buried
in a long section, or was given verbally but never written down.

**Fix pattern:** Promote to structural language with emphasis. Move from
paragraph text to a checklist item or NEVER/ALWAYS rule.

### 3. Role Redirect

The agent stepped outside its assigned role or responsibility boundary.

**Examples:**
- Builder agent started reviewing code instead of building
- Agent made product decisions instead of asking the product owner
- Agent refactored unrelated code while fixing a specific bug
- Agent gave opinions on architecture when asked to implement a design

**Root cause:** Role boundaries not explicit enough, or boundaries decayed
during a long session.

**Fix pattern:** Add explicit role definition: "You are a builder. You
implement designs. You do NOT review, refactor beyond your task scope, or
make architectural decisions."

### 4. Frustration Escalation

The user became more forceful, used stronger language, or repeated a
correction with emphasis. This signals instruction decay -- the agent
understood earlier but drifted.

**Examples:**
- "STOP writing tests for private methods" (after earlier gentle correction)
- "I said NO new dependencies. None. Zero." (after agent added one anyway)
- "Please just do exactly what I asked, nothing more" (after scope creep)

**Root cause:** Instruction decay over long context. Advisory language loses
effect as context grows. The agent's attention drifts from earlier
instructions.

**Fix pattern:** Rewrite as structural with explicit consequence: "NEVER add
dependencies without explicit user approval. If you think a dependency is
needed, STOP and ask. Do not proceed."

### 5. Workaround

The user did the work themselves instead of asking the agent, or gave up on
getting the agent to do it correctly.

**Examples:**
- User manually fixed formatting after agent kept getting it wrong
- User wrote the test themselves after agent wrote wrong kind of test
- User edited the config file directly rather than explaining again

**Root cause:** Capability gap or repeated failure on this type of task. The
user lost confidence in the agent's ability to do this correctly.

**Fix pattern:** If it's a skill gap, add detailed procedure to system
prompt. If it's a recurring pattern, consider whether the task type needs a
different approach entirely.

## Severity Scoring

Score interventions by severity to prioritize which gaps to fix first:

| Severity | Category | Weight | Rationale |
|----------|----------|--------|-----------|
| Critical | Frustration Escalation | 5 | Trust erosion -- highest priority |
| High | Workaround | 4 | User gave up on the agent |
| High | Repetition | 4 | Known gap that was not fixed |
| Medium | Correction | 3 | New gap, first occurrence |
| Medium | Role Redirect | 3 | Boundary issue, first occurrence |

## Prioritization Rubric

1. **Fix highest-severity first.** A single Frustration Escalation outranks
   three Corrections.

2. **Then fix most-frequent.** Among same-severity items, fix the one that
   occurred most often.

3. **Batch related gaps.** If three Corrections all relate to "file naming
   conventions," address them as one system prompt update.

4. **Time-weight recent interventions.** A correction from 10 minutes ago
   matters more than one from 2 hours ago (the recent one reflects current
   state).

## Pattern Detection

A pattern exists when the same category appears 3+ times for related issues:

- 3+ Corrections about code style = missing style guide in system prompt
- 3+ Role Redirects about scope = missing role boundaries
- 3+ Repetitions about the same topic = advisory instruction that needs
  promotion to structural

When a pattern is detected, do not add another advisory item. Escalate:
rewrite the entire section as a structural directive with explicit
NEVER/ALWAYS language.

## Root Cause Analysis

For each detected pattern, identify the root cause:

| Root Cause | Description | Fix Strategy |
|------------|-------------|--------------|
| Missing instruction | No guidance exists for this case | Add new directive |
| Ambiguous instruction | Guidance exists but can be interpreted multiple ways | Rewrite with specifics |
| Decayed instruction | Guidance was followed early but drifted | Promote to structural, add to self-reminder checklist |
| Capability gap | Agent cannot reliably do this type of task | Add detailed procedure or flag for human handling |

## Analysis Output Format

After completing analysis, produce a summary:

```markdown
## Session Reflection - [date]

### Interventions Found: [N]

| # | Category | Severity | Description | Root Cause |
|---|----------|----------|-------------|------------|
| 1 | Repetition | High | File naming convention ignored again | Decayed instruction |
| 2 | Correction | Medium | Used wrong test framework | Missing instruction |

### Patterns Detected
- [Pattern description and recommended fix]

### System Prompt Changes
- [What to add/promote/rewrite]
```
