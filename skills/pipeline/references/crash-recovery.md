# Pipeline Crash Recovery

When the pipeline controller restarts after a crash, context compaction, or
session interruption, follow this procedure exactly. Do not skip steps.
Do not reconstruct state from memory.

## Recovery Procedure

### 1. Kill Orphan Agents

Check for any agents from the previous session that may still be running.
On Claude Code, check for active team members or subagents. Terminate any
that are not responsive or are working on stale state.

### 2. Read Persistent State

Read these files in order:

1. **WORKING_STATE.md** — `.factory/WORKING_STATE.md` for current pipeline
   state, active slice, and progress.
2. **Slice queue** — `.factory/slice-queue.json` for overall queue state
   and slice ordering.
3. **Gate task list** — `.factory/audit-trail/slices/<active-slice>/gates.md`
   for the last completed gate in the active slice.
4. **Role constraints** — Re-read the Controller Role Boundaries section
   of the pipeline SKILL.md.

### 3. Determine Resume Point

From the gate task list, identify the last checked (completed) gate. The
resume point is the next unchecked gate. Do not re-run gates that already
passed unless you have evidence they are invalid.

**If no gate task list exists:** The slice was in the decompose phase or
had not started. Check if a decomposition file exists at
`.factory/audit-trail/slices/<slice-id>/decomposition.json`.

### 4. Verify State Consistency

Before resuming:

- Check that any committed code is still on the expected branch
  (`git log --oneline -5`)
- Verify test suite still passes (`git status` + run tests)
- Check that the audit trail matches the gate task list

If state is inconsistent (e.g., code committed but gate not checked),
reconcile conservatively — re-run the gate verification rather than
assuming it passed.

### 5. Re-Read Role Constraints

Before taking any action, re-read the Controller Role Boundaries. This is
not optional. Crash recovery is the highest-risk time for role drift
because the controller is tempted to "quickly fix" things to get back on
track.

### 6. Resume

Pick up at the identified resume point. Announce the recovery to the user:
"Recovered from interruption. Last completed gate: [gate]. Resuming at:
[next gate]."

## WORKING_STATE.md Format

See `skills/memory-protocol/references/working-state.md` for the full
format specification. The pipeline controller extension adds:

```markdown
## Pipeline State

- Active slice: [slice-id]
- Gate: [current gate name]
- Gate checklist: .factory/audit-trail/slices/[slice-id]/gates.md
- Rework count: [N]
- Agents active: [list of agent names and their current tasks]
```

## Update Cadence

Update WORKING_STATE.md:

- When a new slice becomes active
- When a gate starts or completes
- When rework is triggered
- When agents are spawned or complete
- When blockers are encountered or resolved
- Before any operation that might trigger context compaction

## Common Recovery Mistakes

- **Guessing state from partial memory.** After compaction, you may
  "remember" things that are wrong. Always read the files.
- **Re-running completed work.** If the gate list says a gate passed,
  trust it unless you have evidence of corruption.
- **Writing code to "fix things quickly."** The role boundaries apply
  especially during recovery. Delegate fixes.
- **Forgetting to kill orphans.** Stale agents from the previous session
  may interfere with new agents working on the same files.
