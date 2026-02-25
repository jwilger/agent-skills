# Fallback Coordination Patterns

For harnesses without native multi-agent messaging (Cursor, Windsurf, generic
harnesses, or any environment where agents cannot directly send messages to
each other). These patterns use the file system as the coordination layer.

## Core Principle

When agents cannot message each other, files become the communication
channel. All coordination state lives on disk, where it survives context
compaction, session restarts, and harness limitations.

## File-Based Coordination

### Coordination Directory

Use a `.coordination/` directory at the project root for all coordination
state. This directory is ephemeral -- it tracks in-progress work, not
permanent project artifacts.

```
.coordination/
  status/              # Agent status files
    agent-red.status   # "working", "blocked", "done"
    agent-green.status # Each agent maintains its own file
  tasks/               # Task assignment files
    task-001.md        # Task description + assignment + state
    task-002.md        # One file per task
  handoffs/            # Deliverable handoffs between agents
    red-to-green.md    # Output from one agent for another
  locks/               # Simple file locks for shared resources
    src-auth.lock      # Indicates who is working on what
```

Add `.coordination/` to `.gitignore` -- this is operational state, not
project history.

### Status Files

Each agent writes its own status file. Other agents read but never write
another agent's status file.

**Format:**
```
status: working | blocked | done | error
task: task-001
updated: 2024-01-15T10:30:00Z
message: Running test suite for auth module
```

**Rules:**
- Write your own status file at meaningful state transitions (not continuously)
- Read other agents' status files before starting dependent work
- Never modify another agent's status file
- A missing status file means the agent has not started yet (not an error)

### Task Assignment Files

One file per task. The coordinator creates these; agents read and update their
assigned tasks.

**Format:**
```markdown
# Task 001: Implement token refresh

**Status:** in-progress | blocked | complete | failed
**Assigned to:** agent-red
**Depends on:** none
**Deliverable:** src/auth/refresh.ts with passing tests

## Description
[Full task description with all necessary context]

## Acceptance Criteria
- [ ] Token refresh retries once with exponential backoff
- [ ] Failing test exists before implementation
- [ ] All existing tests pass

## Output
[Agent writes completion notes here when done]
```

### Handoff Files

When one agent's output feeds into another agent's input, use handoff files
rather than relying on the agents to discover each other's changes.

**Naming convention:** `{source}-to-{target}.md`

**Format:**
```markdown
# Handoff: Red to Green

**From:** agent-red (TDD Red phase)
**To:** agent-green (TDD Green phase)
**Task:** task-001

## Deliverable
- Test file: tests/auth/test_refresh.py
- Test count: 3 new tests, all failing
- Test command: pytest tests/auth/test_refresh.py

## Context
[Anything the next agent needs to know]

## Constraints
[Any constraints on the implementation]
```

The receiving agent reads the handoff file for complete context rather than
trying to reconstruct what the previous agent did from file diffs.

### File Locks

Simple advisory locks to prevent two agents from editing the same file
simultaneously. These are cooperative -- agents must check for locks before
editing.

**Lock protocol:**
1. Before editing a file, check for an existing lock
2. If locked by another agent, do not edit -- work on something else or wait
3. Create your lock file: write your agent ID and timestamp
4. Do your work
5. Remove your lock file when done

**Lock file format:**
```
agent: agent-red
acquired: 2024-01-15T10:30:00Z
files: src/auth/refresh.ts, src/auth/types.ts
reason: Implementing token refresh logic
```

**Stale lock detection:** If a lock is older than 30 minutes and the agent's
status file shows "done" or "error", the lock is stale and may be removed by
the coordinator.

## Turn-Based Execution

When subagent spawning is the only coordination mechanism (no persistent
teams, no messaging), use strict turn-based execution.

### Sequential Subagent Spawning

1. Define the full task sequence before starting
2. Spawn subagent 1 with its task and full context
3. Wait for subagent 1 to complete
4. Read subagent 1's output
5. Spawn subagent 2 with its task, full context, AND subagent 1's output
6. Continue the chain

Never spawn the next subagent before the current one completes, unless the
tasks are provably independent (see independence checklist in
`claude-code-coordination.md`).

### Subagent Context Template

Every subagent invocation should include:

```
## Your Task
[Specific, actionable description]

## Project Context
[Relevant project structure, conventions, tech stack]

## Prior Work
[What previous agents completed, with file paths]

## Constraints
[What you must not change, dependencies to respect]

## Expected Output
[Exactly what files to create/modify, what format]

## Completion Signal
[How to indicate you're done -- write to status file, output format, etc.]
```

## Coordination Through Shared File System

### Watch Patterns (When Polling Is Unavoidable)

In some harnesses, the only way to detect another agent's completion is to
check the file system. This is the ONE exception to the "no polling" rule,
and it must be done carefully:

- Check at most once per minute (not in a tight loop)
- Check a specific file (the status file or handoff file), not "anything
  that changed"
- Stop checking once you find the completion signal
- Set a maximum check count (e.g., 30 checks = 30 minutes), then report
  to the user instead of continuing indefinitely

This is a last resort. Prefer harness-native completion signals whenever
available.

### Status Reporting

When the harness has no messaging, agents report status by writing files:

**Progress updates:** Write to your status file at meaningful milestones.
Not every line of code -- just phase transitions (started, tests written,
implementation complete, tests passing, done).

**Error reporting:** Write error details to your status file immediately.
Include the error message, what you were doing, and what you need to
proceed. The coordinator or user reads this to unblock you.

**Completion reporting:** Write a completion summary to the handoff file
or task file. Include what was done, what files changed, and what the
next agent needs to know.
