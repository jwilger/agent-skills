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

You MUST follow `skills/code-review/SKILL.md` for the three-stage review process.
You MUST follow `skills/mutation-testing/SKILL.md` for test quality verification.
You MUST follow `skills/task-management/SKILL.md` for task closure.

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

## Human Verification Gate

A vertical slice is not merge-ready until the human has personally verified its behavior. This is a structured checkpoint, not an automated enforcement.

### Pre-PR Human Verification Reminder

After all agent-side checks pass (tests, code review, mutation testing), present the human with:

1. **A clear statement**: "This slice requires your verification before the PR can merge. Agents cannot run the application and interact with it as a user would — this is your responsibility."

2. **A specific verification checklist** derived from the slice's application-boundary GWT scenarios. Each item should be concrete and actionable:
   - "Run the application and verify that [specific behavior from GWT scenario] is observable"
   - "Confirm that [specific boundary condition] produces [expected outcome]"
   - "Verify that [specific user-facing interaction] works as described in the acceptance criteria"

3. **Explicit status separation**:
   - **Agent verified**: All tests pass, code compiles, code review passed, layer wiring confirmed in diff, automated acceptance tests pass (where applicable)
   - **Human verified**: Awaiting your confirmation that the slice's behavior is correct when interacting with the running application

Do not create or push the PR until the human has confirmed the verification checklist. If the human identifies issues, return to the implementation cycle to address them before proceeding.

## Mob Review (Ensemble-Team Enhancement)

When a project team is configured via the ensemble-team workflow, the PR review
can be conducted as a mob review with the full team using consent-by-default
Robert's Rules. You MUST follow `skills/code-review/references/mob-review.md` for the
complete protocol. The existing parallel review mechanism remains the default;
mob review is an enhancement available when a project team is active.

## Error Handling

- Not on feature branch -> warn
- No commits -> nothing to create PR for
- Mutation testing fails -> show results, offer to proceed
