---
description: INVOKE when event model slices are ready. Creates dot tasks from slices
argument-hint: [workflow-name]
allowed-tools:
  - Bash
  - Read
  - Glob
  - Write
  - Task
  - AskUserQuestion
  - Grep
hooks:
  PreToolUse:
    - matcher: Read
      once: true
      hooks:
        - type: prompt
          prompt: |
            PLAN PREREQUISITES CHECK

            Verify:
            1. .claude/sdlc.yaml exists
            2. docs/ARCHITECTURE.md exists
            3. At least one workflow with slices exists

            If ARCHITECTURE.md missing, direct to /design arch.

            Respond with: {"ok": true}
---

# Plan

Create dot tasks from event model slices. Bridges design phase to actionable work.

## Methodology

Follows `skills/task-management/SKILL.md` for task creation patterns.
Follows `skills/event-modeling/SKILL.md` for slice structure.

## The Mapping

| Event Model Concept | dot Task Equivalent |
|---------------------|---------------------|
| Workflow | Epic (parent task) |
| Vertical Slice | Story Task (child of epic) |
| GWT Scenarios | Acceptance Criteria (in description) |
| Pattern Type | Metadata tag |

## Steps

1. Load config and verify prerequisites (config, architecture, slices)
2. Find workflows to plan (from argument or all unplanned)
3. For each workflow: create epic task (`dot add "Epic: <name>" -p 1`)
4. For each slice: create story task as child (`dot add "<name>" -P <epic-id> -p 2`)
5. Verify hierarchy with `dot tree <epic-id>`
6. Store planning results in auto memory via `/remember`
7. Display results with task IDs and next steps

## Arguments

`$ARGUMENTS` - Optional workflow name. If omitted, plans all unplanned workflows.

## Optional: Three-Perspective Review

For complex stories, offer reviews via story, architect, and ux agents.
