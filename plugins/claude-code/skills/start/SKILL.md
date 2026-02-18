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

## Artifact Locations

| Artifact | Path / Check | Created By |
|----------|-------------|------------|
| SDLC config | `.claude/sdlc.yaml` | `/setup` |
| Development mode | `mode` field in `.claude/sdlc.yaml` | `/setup` |
| Dot tasks directory | `.dots/` | `/setup` (dot CLI) |
| Domain discovery | `docs/event_model/domain/overview.md` | `/model discover` |
| Workflow models | `docs/event_model/workflows/*/overview.md` | `/model workflow` |
| Workflow slices | `docs/event_model/workflows/*/slices/*.md` | `/model workflow` |
| GWT scenarios | `## Scenario` headings in slice files above | `/model gwt` |
| Architecture doc | `docs/ARCHITECTURE.md` | `/model arch` |
| Tasks from slices | `dot ls --json` (non-empty) | `/decompose` |
| Feature branch | `git branch --show-current` (not main/master) | `/work` |
| Active tasks | `dot ls --status active --json` (non-empty) | `/work` |

## Detection Sequence

1. **No config?** `test -f .claude/sdlc.yaml` — if missing -> `/setup`
2. **Traditional mode?** Read `mode` from `.claude/sdlc.yaml`; if `traditional` -> show skills, stop
3. **No domain discovery?** `test -f docs/event_model/domain/overview.md` — if missing -> `/model discover`
4. **No workflows?** Glob `docs/event_model/workflows/*/overview.md` — if no matches -> `/model workflow <name>`
5. **Workflows missing GWT?** Grep for `## Scenario` in `docs/event_model/workflows/*/slices/*.md` — if none -> `/model gwt <name>`
6. **No architecture?** `test -f docs/ARCHITECTURE.md` — if missing -> `/model arch`
7. **No tasks from slices?** `dot ls --json 2>/dev/null` — if empty/fails -> `/decompose`
8. **On feature branch?** `git branch --show-current` — if not main/master -> continue-work options
9. **Active tasks?** `dot ls --status active --json` — if non-empty -> `/work`
10. **Default** -> Project ready, direct to `/work`

Each check reads project state (files, git branch, dot tasks) and routes
accordingly. Version mismatch warning shown but does not block work.

## Ensemble Team Detection

After running the detection sequence, check for ensemble team presence:

1. **Check `.team/` directory**: Glob for `.team/*.md` profile files.
2. **Check config**: Read `ensemble_team` section from `.claude/sdlc.yaml`.

If both exist (profiles in `.team/` AND `ensemble_team.preset` is not `"none"`),
display a notice in the project state summary:

> **Ensemble team active** — [preset] preset, [N] members.
> `/work` will use ping-pong pairing mode. `/sdlc:pr` will use mob review.

This notice helps the agent (and the user) know that:
- The orchestration layer should activate pair mode during `/work` sessions
- PR reviews should use the full team mob review protocol instead of solo review
- Team profiles are available in `.team/` for loading during discussions
