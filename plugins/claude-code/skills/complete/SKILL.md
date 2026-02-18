---
description: Mark a task as complete. Closes the task and commits .dots/ changes
user-invocable: true
argument-hint: [task-id]
allowed-tools:
  - Bash
  - Read
  - AskUserQuestion
hooks:
  PreToolUse:
    - matcher: Read
      once: true
      hooks:
        - type: prompt
          prompt: |
            CONFIG CHECK (runs once)

            Verify .claude/sdlc.yaml and .dots/ exist.
            If missing, stop and tell user to run /setup first.

            Respond with: {"ok": true}
---

# Complete

Mark a task as complete. Closes the task and commits `.dots/` changes on the
current branch so they travel with the PR.

## Methodology

Follows `skills/task-management/SKILL.md` for task lifecycle.

## When to Use

- Before `/pr` -- close task, then create PR
- Without a PR -- for config changes, spikes, etc.
- Parent closure -- after all children are done

Note: `/pr` automatically closes the task. Use `/complete` only when closing
independently of PR creation.

## Verification Checklist

Before marking a vertical slice as complete, confirm that verification is split into two categories:

### Agent Verified

The agent confirms ALL of the following before proceeding:

- All tests pass (unit, integration, and any automated acceptance tests)
- Code compiles / builds without errors
- Code review has passed (if applicable at this stage)
- The slice's implementation spans all required architectural layers, and wiring between layers is present
- Where the project supports automated boundary tests (e.g., headless browser tests, CLI output assertions, API contract tests), those tests pass

### Human Verified

**Agents cannot run the application and interact with it as a user would.** This is an inherent limitation — agents cannot operate UIs, navigate running applications, or perform experiential verification.

Before this slice is considered truly complete, the human must personally:

1. Run the application
2. Interact with the slice's functionality as an end user would
3. Confirm that the expected behavior is observable

**Generate a specific verification checklist from the slice's GWT scenarios.** Do not use vague language like "please verify it works." Instead, produce concrete items derived from the application-boundary Given/When/Then scenarios, such as:

- "Verify that when [specific trigger from scenario], [specific observable outcome] is visible/accessible in the running application"
- "Confirm that [boundary condition from scenario] produces [expected behavior]"

Present this checklist to the human as part of the completion summary. The slice is not complete until the human confirms these items.

## Steps

1. Determine task ID (from argument or branch name)
2. Verify task exists and is not already closed
3. Close task (`dot off <task-id>`)
4. Check parent task -- if all siblings done, offer to close parent
5. Commit `.dots/` changes (`git add .dots/ && git commit -m "chore: close task <id>"`)
6. Display result

## Arguments

`$ARGUMENTS` - Optional task ID. If omitted, extracted from current branch name.
