# System Prompt Patterns

Reference for writing effective project-specific system prompts. Based on
observed patterns from autonomous agent work: what sticks, what decays, and
how to promote instructions that keep failing.

## What Sticks

These patterns reliably influence agent behavior across long sessions:

### Explicit Role Boundaries
```
You are a builder. You write code and tests.
You are NOT a reviewer, architect, or product manager.
```
Clear positive identity + explicit negation. The agent knows what it is and
what it is not.

### Concrete Forbidden Actions
```
NEVER write code without a failing test first.
NEVER modify files outside the src/ and test/ directories.
NEVER add dependencies without explicit user approval.
```
Specific, binary, no room for interpretation.

### Checklists with Binary Items
```
Before every commit:
- [ ] All tests pass
- [ ] Linter passes
- [ ] No files outside task scope modified
```
Observable, checkable, mechanical.

### Startup Procedures
```
At session start:
1. Read WORKING_STATE.md
2. Read .claude/SYSTEM_PROMPT.md
3. Run git status
4. Confirm current task with user
```
Sequential, concrete, impossible to misinterpret.

## What Decays

These patterns lose effectiveness as context grows:

### Advisory Language
```
Try to remember to check the linter.
It would be good to review the state file periodically.
Keep in mind that we prefer functional patterns.
```
"Try to," "it would be good," "keep in mind" -- these are suggestions, not
instructions. They decay first.

### General Principles Without Specifics
```
Write clean code.
Follow best practices.
Be careful with state management.
```
Too vague to act on. The agent interprets these differently as context shifts.

### Instructions Buried in Long Paragraphs
```
When working on this project, there are several things to keep in mind.
First, the team prefers... [200 more words] ...and also remember to run
the linter before committing.
```
The linter instruction is buried. It will be forgotten. Extract it as a
standalone checklist item.

### Context-Dependent Rules Without Triggers
```
Use the legacy API for the billing module.
```
When does this apply? The agent may not realize it is in the billing module.
Better: "When modifying any file in `src/billing/`, use the legacy API (v1),
not the current API (v2)."

## Structural vs. Advisory

The core distinction:

| Advisory (decays) | Structural (sticks) |
|-------------------|---------------------|
| "Remember to check WORKING_STATE.md" | "MUST read WORKING_STATE.md after every context compaction" |
| "Try to stay in your role" | "You are a builder. NEVER perform code review." |
| "Be careful with dependencies" | "NEVER add dependencies. If one seems needed, STOP and ask." |
| "Keep commits small" | "Each commit contains exactly one logical change. If you have two changes, make two commits." |

## Promotion Pattern

Instructions earn structural status through repeated failure:

### First Occurrence (Advisory)
A new gap is discovered. Add an advisory item:
```
## Reminders
- Check linter output before committing
```

### Second Occurrence (Promoted to Structural)
The same gap recurred. Promote with emphasis:
```
## Process Requirements
- MUST run linter before every commit. Do not commit if linter fails.
```

### Third Occurrence (Explicit Forbidden Action)
The gap persists. Rewrite as a hard constraint:
```
## Common Mistakes (NEVER do these)
- NEVER commit without running the linter first. If you are about to commit,
  STOP, run the linter, and only proceed if it passes with zero warnings.
```

## System Prompt File Structure

```markdown
# [Project Name] System Prompt

## Role and Constraints
You are [role]. You [do X, Y, Z].
You are NOT [other role]. You do NOT [A, B, C].

## Startup Procedure (run every session start)
1. Read WORKING_STATE.md (if it exists)
2. Read this system prompt fully
3. Run git status to understand current state
4. Confirm current task before proceeding

## Process Requirements
- MUST [requirement] before [action]
- MUST [requirement] after [action]

## Common Mistakes (NEVER do these)
- NEVER [specific forbidden action]. Instead, [correct action].
- NEVER [specific forbidden action]. If tempted, [alternative].

## Reminders (re-read every 5-10 messages)
- [Concise reminder 1]
- [Concise reminder 2]
```

## Content Guidelines

- **Under 500 tokens total.** The system prompt is loaded every session. Keep
  it tight.
- **Role boundaries first.** The most important section. Get this wrong and
  everything else fails.
- **Startup procedure second.** Ensures consistent session initialization.
- **No detailed process rules.** Those belong in skills. The system prompt
  handles project-specific constraints and known failure modes only.
- **Use NEVER/ALWAYS/MUST.** Not "try to," "consider," or "remember to."
- **One idea per bullet.** Do not combine multiple instructions into one item.
- **Test readability.** If you cannot scan the entire prompt in 30 seconds,
  it is too long. Cut or move detail to skills/references.

## Refinement Workflow

1. Identify gaps from session reflection analysis
2. Draft new items or promote existing ones
3. Review total token count -- stay under 500 tokens
4. If over budget, move least-critical items to a Reminders section that gets
   re-read periodically rather than loaded at startup
5. Test the updated prompt in the next session
6. Remove items only after the gap is confirmed solved across 3+ sessions
