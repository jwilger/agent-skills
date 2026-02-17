---
description: INVOKE to start or continue work on a task. Shows ready items, creates branch
user-invocable: true
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

If `git.worktrees.enabled: true` in config, creates isolated worktrees for
parallel development. Each worktree gets its own branch and working directory.

### Worktree Path Resolution

Resolve the worktree location by combining `git.worktrees.location` from
`sdlc.yaml` with the project root. If `location` is a relative path (e.g.,
`.worktrees`), resolve it against the project root to get an absolute path.
Absolute paths in `location` are used as-is. Append the naming template result
to get the final worktree path.

### Naming Convention

Worktree directories are named using the template `{mode}-{identifier}`:
- **mode** is `slice` when `development.mode` is `event-modeling`, or `ticket`
  when `development.mode` is `traditional`
- **identifier** comes from the slice name or ticket ID of the task being
  worked on (e.g., `user-registration`, `GH-1234`)

Example: for a slice called "user-registration" in event-modeling mode with
the default `.worktrees` location, the worktree is created at:
`{project_root}/.worktrees/slice-user-registration`

### Creating and Switching to Worktrees

When creating a worktree, use `git worktree add` with the resolved absolute
path and an appropriate branch name derived from the naming template:
```
git worktree add {resolved_path} -b {mode}-{identifier}
```

If a worktree already exists for the current slice or ticket (the resolved path
already exists on disk), switch to it rather than recreating it. Always emit
the full absolute path after creation or switch so users and agents know
exactly where to work.

### Stale Worktree Cleanup

On startup, check for existing worktrees whose associated tasks are completed
(no longer active in `dot ls`). For each stale worktree, offer cleanup to the
user via AskUserQuestion before removing:
```
git worktree remove {absolute_path}
```

## Error Handling

- No config -> `/setup`
- No .dots/ -> `/setup`
- Dirty git state -> show cleanup options
- No ready tasks -> suggest `/decompose` or `dot add`
