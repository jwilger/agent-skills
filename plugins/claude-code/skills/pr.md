---
description: INVOKE when ready to create PR. Runs three-stage code review and mutation testing
user-invocable: true
allowed-tools:
  - Bash
  - Read
  - Task
hooks:
  PreToolUse:
    - matcher: Read
      once: true
      hooks:
        - type: prompt
          prompt: |
            CONFIG CHECK (runs once)

            Verify .claude/sdlc.yaml exists.
            If missing, stop and tell user to run /setup first.

            Respond with: {"ok": true}
---

# Pull Request

Create or update a pull request for the current work.

## Methodology

Follows `skills/code-review/SKILL.md` for the three-stage review process.
Follows `skills/mutation-testing/SKILL.md` for test quality verification.
Follows `skills/task-management/SKILL.md` for task closure.

## Steps

1. Load configuration from `.claude/sdlc.yaml`
2. Detect current task from branch name
3. Run three-stage code review via code-reviewer agent:
   - Stage 1: Spec compliance (acceptance criteria met?)
   - Stage 2: Code quality (clean, maintainable?)
   - Stage 3: Domain integrity (via domain agent -- compile-time audit)
4. Run mutation testing via mutation agent (target: 100% kill rate)
5. Close task (`dot off <task-id>`) and commit `.dots/` changes
6. Check parent task -- if all children done, offer to close parent
7. Push changes
8. Create or update PR via `gh pr create`

## Review Results

- CRITICAL issues: Block PR creation
- IMPORTANT issues: Warn, recommend fixing, allow proceeding
- SUGGESTIONS: Proceed to mutation testing
- COMPILE-TIME FLAGS: Strongly recommended, not blocking

## Error Handling

- Not on feature branch -> warn
- No commits -> nothing to create PR for
- Mutation testing fails -> show results, offer to proceed
