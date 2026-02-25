---
name: memory-protocol
description: >-
  File-based knowledge persistence patterns: when to store discoveries,
  when to recall past solutions, and how to organize project memory.
  Activate when starting tasks, encountering errors, making decisions,
  or when context may be lost between sessions.
license: CC0-1.0
metadata:
  author: jwilger
  version: "1.1"
  requires: []
  context: []
  phase: build
  standalone: true
---

# Memory Protocol

**Value:** Feedback -- accumulated knowledge creates compound feedback loops
across sessions. What you learn today should accelerate tomorrow's work.

## Purpose

Teaches the agent to systematically store and recall project knowledge using
file-based persistent memory. Solves the problem of context loss between
sessions, repeated debugging of known issues, and rediscovery of established
conventions.

## Practices

### Recall Before Acting

Before starting any non-trivial task, search memory for relevant past work.
Before debugging any error, search for that error message. Before making
design decisions, search for past decisions on the same topic.

**Search triggers:**
- Starting a new task
- Encountering an error or unexpected behavior
- Making architectural or design decisions
- Unsure about a project convention
- Before asking the user a question (it may already be answered)

**How to search:**
```bash
grep -r -i "search terms" ~/.claude/projects/<project-path>/memory/ --include="*.md"
```

If relevant memory is found, use it to inform your work. If not found,
proceed and store what you learn (next practice).

**Do not:**
- Skip search because "this seems simple"
- Assume you remember from a previous session (you do not)

### Store After Discovery

After solving a non-obvious problem, learning a convention, or making a
decision, store it immediately. Do not wait until later -- you will forget
or lose context.

**What to store:**
- Solutions to non-obvious problems (with the error message as keyword)
- Project conventions discovered while working
- Architectural decisions and their rationale
- User preferences for workflow or style
- Tool quirks and workarounds

**What not to store:**
- Obvious or well-documented information
- Temporary values or session-specific facts
- Verbose narratives (keep entries concise and searchable)

**Storage format:**
```markdown
# Brief Title with Keywords

**Context:** One sentence on when this applies.

**Discovery:** The key insight or solution, concise.

**Related:** Links to related memory files if any.
```

Write to the appropriate subdirectory:
```
~/.claude/projects/<project-path>/memory/
  MEMORY.md            # Quick reference (always loaded, keep under 200 lines)
  debugging/           # Error solutions
  architecture/        # Design decisions
  conventions/         # Project patterns
  tools/               # Tool quirks and workarounds
  patterns/            # Reusable approaches
```

### Keep MEMORY.md as the Index

`MEMORY.md` is loaded into context at session start. Use it as a concise
index of the most important facts -- project overview, critical conventions,
known gotchas. Link to detailed files in subdirectories for depth.

Keep MEMORY.md under 200 lines. When it grows beyond that, move details
into topic files and replace with a one-line summary and link.

### Factory Memory

When running inside a pipeline or factory workflow, the pipeline stores
operational learnings in `.factory/memory/` to optimize future runs.

**Types of learnings tracked:**

- **CI patterns:** Which types of changes cause CI failures (e.g., "adding
  new dependencies often breaks the build step")
- **Rework patterns:** Common rework causes by gate (e.g., "mutation
  survivors most often in error-handling paths")
- **Pair effectiveness:** Which engineer pairs are most effective in which
  domain areas (used for pair selection optimization at full autonomy)
- **Domain hotspots:** Files and modules that frequently trigger review
  findings or rework

**How memory optimizes the pipeline:**

- Pair selection (full autonomy level)
- Slice ordering (prioritize slices in domains with fewer rework patterns)
- Proactive warnings (flag known CI-failure-prone change patterns before push)

Memory files in `.factory/memory/` are append-only during a session and
summarized during retrospective. The human can review and edit factory
memory during Phase 3 (human review).

Standalone users can ignore factory memory; the standard memory practices
above remain unchanged.

### Prune Stale Knowledge

Knowledge goes stale. When you encounter a memory that is no longer accurate
(API changed, convention abandoned, bug fixed upstream), update or delete it.
Wrong memories are worse than no memories.

**Pruning triggers:**
- Memory contradicts current observed behavior
- Referenced files or APIs no longer exist
- Convention has clearly changed

### Store Before Context Loss

Before context compaction or at natural stopping points (task complete,
switching tasks), store any undocumented insights from the current session.
This is your last chance before the knowledge evaporates.

### WORKING_STATE.md for Long-Running Sessions

For sessions lasting beyond a single task (pipeline runs, multi-slice TDD,
team coordination), maintain a WORKING_STATE.md file as insurance against
context compaction and crashes.

- **Location:** `.factory/WORKING_STATE.md` (pipeline mode) or project root
  (standalone)
- **Contents:** current task, progress checklist, key decisions, files
  modified, blockers, last updated timestamp
- **Update cadence:** after every significant state change (task start, phase
  change, decision made, blocker encountered)
- **Read cadence:** at session start, after context compaction, after any
  interruption — never guess state from memory

See `references/working-state.md` for the full format and examples.

### Self-Reminder Protocol

Long sessions cause instruction decay. Counter this by periodically
re-reading critical context:

- Every 5-10 messages, re-read: WORKING_STATE.md, role constraints, active
  task context
- After ANY context compaction, immediately re-read all state before acting
- Critical for: pipeline controllers, team coordinators, long TDD sessions

The self-reminder is the primary defense against role drift. Skipping it is
the #1 cause of agents reverting to bad habits mid-session.

## Enforcement Note

This skill provides advisory guidance. It cannot force the agent to search
memory before acting or to store discoveries. On harnesses with persistent
memory directories (Claude Code auto memory), storage is straightforward.
On harnesses without persistent filesystems, adapt the pattern to whatever
persistence mechanism is available (project files, comments, or external
tools). The recall-before-act and store-after-discovery patterns are
universal even if the storage mechanism varies.

## Verification

After completing work guided by this skill, verify:

- [ ] Searched memory before starting the task
- [ ] Searched for error messages before debugging from scratch
- [ ] Stored solutions to any non-obvious problems encountered
- [ ] Stored any newly discovered conventions
- [ ] MEMORY.md remains under 200 lines
- [ ] No stale or contradicted memories left uncorrected
- [ ] WORKING_STATE.md maintained for long-running sessions
- [ ] Self-reminder protocol followed (state re-read every 5-10 messages)
- [ ] State re-read after context compaction (not guessed from memory)

## Dependencies

This skill works standalone. For enhanced workflows, it integrates with:

- **debugging-protocol:** Search memory before starting the 4-phase investigation
- **user-input-protocol:** Store user answers to avoid re-asking the same questions
- **tdd:** Store test patterns and domain modeling insights between sessions
- **pipeline:** Pipeline controllers use WORKING_STATE.md and self-reminder to
  maintain role discipline across long autonomous runs
- **ensemble-team:** Team coordinators use self-reminder to prevent role drift
  during multi-agent sessions

Missing a dependency? Install with:
```
npx skills add jwilger/agent-skills --skill debugging-protocol
```
