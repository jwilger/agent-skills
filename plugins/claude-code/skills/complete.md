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

## Steps

1. Determine task ID (from argument or branch name)
2. Verify task exists and is not already closed
3. Close task (`dot off <task-id>`)
4. Check parent task -- if all siblings done, offer to close parent
5. Commit `.dots/` changes (`git add .dots/ && git commit -m "chore: close task <id>"`)
6. Display result

## Arguments

`$ARGUMENTS` - Optional task ID. If omitted, extracted from current branch name.
