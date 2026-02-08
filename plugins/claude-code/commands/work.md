---
description: INVOKE to start or continue work on a task. Shows ready items, creates branch
allowed-tools:
  - Bash
  - Read
  - AskUserQuestion
  - Grep
hooks:
  PreToolUse:
    - matcher: Read
      once: true
      hooks:
        - type: prompt
          prompt: |
            CONFIG CHECK (runs once)

            Verify .claude/sdlc.yaml exists before proceeding.
            If missing, stop and tell user to run /setup first.

            Respond with: {"ok": true}
---

# Work

Start or continue working on a task.

## Methodology

Follows `skills/task-management/SKILL.md` for task lifecycle patterns.
Follows `skills/memory-protocol/SKILL.md` for context persistence.

## Steps

1. Load `.claude/sdlc.yaml` configuration (check version)
2. Check for clean git state (`git status --porcelain`, `git fetch`, `git pull --ff-only`)
3. Search auto memory for current work context
4. Get available tasks (`dot ready --json`) and active tasks (`dot ls --status active --json`)
5. Present options via AskUserQuestion (active tasks first, then children of active parents, then ready tasks)
6. Mark selected task active (`dot on <task-id>`)
7. Create branch or worktree based on config
8. Store work context in auto memory via `/remember`
9. Display task details and acceptance criteria

## Arguments

`$ARGUMENTS` - Optional task ID to work on directly.

## Worktree Support

If `git.worktrees: true` in config, creates isolated worktrees for parallel
development. Each worktree gets its own branch and working directory.

## Error Handling

- No config -> `/setup`
- No .dots/ -> `/setup`
- Dirty git state -> show cleanup options
- No ready tasks -> suggest `/plan` or `dot add`
