# Working State Schema

Reference for the WORKING_STATE.md file format, maintenance rules, and
usage patterns.

## Purpose

WORKING_STATE.md is insurance against context compaction and crashes. It
records current state so the agent can resume work without guessing. It is
NOT a journal or history -- it is a snapshot of right now.

## File Location

- **Pipeline mode:** `.factory/WORKING_STATE.md`
- **Standalone mode:** `WORKING_STATE.md` (project root)

## Format

```markdown
# Working State
Last updated: [ISO timestamp]

## Current Task
- Slice/Task ID: [id]
- Description: [what we're doing]
- Phase: [RED/GREEN/DOMAIN/COMMIT/REVIEW/etc.]
- Status: [in-progress/blocked/waiting]

## Progress
- [x] Completed step 1
- [x] Completed step 2
- [ ] Current step 3
- [ ] Pending step 4

## Key Decisions
- [Decision and rationale]

## Files Modified This Session
- path/to/file.ext (what changed)

## Blocked On
- [What's blocking, who/what we're waiting for]

## Pipeline State (factory mode only)
- Active slice: [slice-id]
- Gate: [current gate name]
- Gate checklist: [path to gate task list]
- Rework count: [N]
```

## Field Reference

### Current Task
What the agent is working on right now. Must be specific enough that a fresh
agent (or the same agent after compaction) can understand the task without
additional context.

- **Slice/Task ID:** Reference to the task tracker, slice queue, or issue
- **Description:** One sentence describing the goal, not the method
- **Phase:** The current TDD or workflow phase
- **Status:** One of: `in-progress`, `blocked`, `waiting`

### Progress
Checklist of steps for the current task. Checked items are done. The first
unchecked item is where work should resume.

Keep this list to 5-10 items maximum. If the task has more steps, group
them into phases.

### Key Decisions
Decisions made during this session that affect future work. Include the
rationale -- a decision without a reason is useless after compaction.

Limit to 3-5 entries. Move resolved decisions to memory files if they have
long-term value.

### Files Modified This Session
Quick reference for what has changed. Helps the agent after compaction
understand what files are in play without running git diff.

### Blocked On
What is preventing progress. Empty when work is flowing. When populated,
this is the first thing to address after resuming.

### Pipeline State
Factory-mode only. Tracks the pipeline position so the controller can
resume orchestration after a crash or compaction.

## Maintenance Rules

### When to Update

Update WORKING_STATE.md after every significant state change:

- Task start (new Current Task)
- Phase change (RED to GREEN, etc.)
- Decision made (add to Key Decisions)
- File modified (add to Files Modified)
- Blocker encountered (add to Blocked On)
- Blocker resolved (remove from Blocked On)
- Step completed (check off in Progress)

### How to Update

**Overwrite, do not append.** WORKING_STATE.md represents current state. Old
state is irrelevant. If a task is complete, clear it and start the new task.

**Keep concise.** If a section exceeds 5-7 items, prune completed or
resolved entries. Move important historical information to memory files.

### When to Read

**Read FIRST after any interruption:**

- Context compaction
- Crash recovery
- Session restart
- Switching between tasks
- Returning from a long subagent delegation

**Never guess state from memory.** After compaction, your "memory" of what
you were doing is unreliable. The file is the source of truth.

### When to Delete

Delete WORKING_STATE.md when:

- The project has no active work in progress
- A clean session start is desired
- The file contents are completely stale (all tasks done, no blockers)

## Examples

### Pipeline Controller

```markdown
# Working State
Last updated: 2025-01-15T14:32:00Z

## Current Task
- Slice/Task ID: SLICE-003
- Description: Implement user notification preferences API
- Phase: BUILD
- Status: in-progress

## Progress
- [x] Sliced requirements into 3 sub-tasks
- [x] Sub-task 1: Database schema migration (complete, merged)
- [ ] Sub-task 2: API endpoints (builder pair active)
- [ ] Sub-task 3: Integration tests
- [ ] Gate: code review
- [ ] Gate: mutation testing

## Key Decisions
- Using event-driven notifications (not polling) per ADR-012
- Storing preferences as JSONB column (flexible schema for future types)

## Files Modified This Session
- db/migrations/20250115_notification_prefs.sql (new migration)
- src/notifications/preferences.ts (new module)

## Blocked On
- (none)

## Pipeline State
- Active slice: SLICE-003
- Gate: build
- Gate checklist: .factory/slices/003/gates/build.md
- Rework count: 0
```

### Standalone TDD Session

```markdown
# Working State
Last updated: 2025-01-15T10:15:00Z

## Current Task
- Slice/Task ID: GH-42
- Description: Fix date parsing for ISO 8601 timestamps with timezone offsets
- Phase: RED
- Status: in-progress

## Progress
- [x] Reproduced the bug with timezone offset "+05:30"
- [x] Investigated root cause (regex does not handle colon in offset)
- [ ] Write failing test for colon-separated offset
- [ ] Fix the regex in parse_timestamp()
- [ ] Verify all date tests pass

## Key Decisions
- Fixing regex directly rather than switching to a date library (scope constraint from user)

## Files Modified This Session
- (none yet -- still in RED phase)

## Blocked On
- (none)
```
