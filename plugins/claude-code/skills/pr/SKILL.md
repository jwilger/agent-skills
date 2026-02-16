---
description: INVOKE when ready to create PR. Runs three-stage code review and mutation testing
user-invocable: true
allowed-tools:
  - Bash
  - Read
  - Task
  - TeamCreate
  - SendMessage
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
3. Run three-stage code review:
   - Check `.claude/sdlc.yaml` for `parallel_review: true`
   - If parallel_review enabled:
     a. Create an agent team (TeamCreate) for code review
     b. Create 3 review tasks (one per stage: spec compliance, code quality, domain integrity)
     c. Spawn spec-reviewer, quality-reviewer, domain-reviewer as teammates
     d. Assign one task to each reviewer
     e. Reviewers work in parallel; they may SendMessage each other about overlapping concerns
     f. Collect all three results and synthesize into unified review summary
     g. Shut down the review team after all stages complete
   - If parallel_review disabled (default):
     a. Run existing sequential three-stage code-reviewer agent (unchanged behavior)
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
