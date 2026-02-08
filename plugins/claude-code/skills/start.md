---
description: INVOKE to begin work. Auto-detects project state and routes to appropriate phase
user-invocable: true
allowed-tools:
  - Bash
  - Read
  - Glob
  - AskUserQuestion
---

# Start

Smart entry point that detects the current SDLC phase and routes to the
appropriate skill.

## Methodology

Implements the progressive onboarding described in `skills/bootstrap/SKILL.md`.
Routes to the correct workflow phase based on project state.

## Detection Sequence

1. **No config?** -> Direct to `/setup`
2. **Traditional mode?** -> Show available skills and stop
3. **No domain discovery?** -> Direct to `/model discover`
4. **No workflows?** -> Direct to `/model workflow <name>`
5. **Workflows missing GWT?** -> Direct to `/model gwt <name>`
6. **No architecture?** -> Direct to `/model arch`
7. **No tasks from slices?** -> Direct to `/decompose`
8. **On feature branch?** -> Show continue-work options
9. **Active tasks?** -> Show active tasks, direct to `/work`
10. **Default** -> Project ready, direct to `/work`

Each check reads project state (files, git branch, dot tasks) and routes
accordingly. Version mismatch warning shown but does not block work.
