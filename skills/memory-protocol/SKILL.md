---
name: memory-protocol
description: >-
  Knowledge persistence across sessions using Memento MCP knowledge graph
  (primary) or file-based markdown with topic directories (fallback).
  Mandatory recall-before-acting: search memory before starting any task.
  Store-after-discovery: persist solutions, conventions, and decisions
  immediately using structured format (title, context, discovery) in
  topic-based directories (debugging/, conventions/, architecture/,
  patterns/, tools/). Maintains MEMORY.md as concise index under 200 lines.
  WORKING_STATE.md for crash recovery in long sessions. Self-reminder
  protocol every 5-10 messages. Activate at task start, on errors, before
  decisions, when context may be lost, or at session boundaries. Triggers
  on: "remember this", "what did we learn last time", "check memory",
  "save this for later", "store this convention", "recall previous work",
  "persist this knowledge", "working state", "session notes". Also
  activates when instructing subagents (they must follow memory protocol
  too), or when approaching context compaction. NOT for: obvious/well-
  documented information, temporary session-specific facts, or verbose
  narratives.
license: CC0-1.0
metadata:
  author: jwilger
  version: "3.2.1"
  requires: []
  context: []
  phase: build
  standalone: true
---

# Memory Protocol

**Value:** Feedback -- accumulated knowledge creates compound feedback loops
across sessions. What you learn today should accelerate tomorrow's work.

## Purpose

Teaches the agent to systematically store and recall project knowledge across
sessions using a knowledge graph (Memento MCP) when available, with a
file-based fallback for harnesses without MCP support.

Your long-term memory (training data) and short-term memory (context window)
are excellent, but mid-term memory for project-specific knowledge outside the
current context is poor. Memento addresses this gap by persisting a knowledge
graph across sessions and projects.

Solves: context loss between sessions, repeated debugging of known issues,
rediscovery of established conventions.

## Practices

### Detect Capability at Session Start

```
Memento MCP tools available (mcp__memento__*)?
  YES → primary approach: knowledge graph via mcp__memento__* tools
  NO  → fallback approach: grep + markdown files in memory directory
```

### Recall Before Acting — NON-NEGOTIABLE

Before starting any non-trivial task, recall relevant past knowledge. This
step is mandatory. Do not skip it because "this seems simple" or because
you believe you remember from a prior session — you do not retain memory
between sessions.

**Recall triggers:**
- Starting any non-trivial task
- Encountering an error or unexpected behavior
- Making architectural or design decisions
- Unsure about a project convention
- Before asking the user a question (it may already be answered)

**Primary (Memento MCP available):**
1. `mcp__memento__semantic_search` — query describing the current work, limit 10
2. `mcp__memento__open_nodes` — retrieve full details on relevant results
3. Follow `relations` on returned entities to traverse related knowledge
4. Continue traversing until results are no longer relevant

**IMPORTANT:** Do NOT use `mcp__memento__read_graph` — memories span all
projects and the graph is too large to be useful.

**Fallback (no MCP):**
```bash
grep -r -i "search terms" ~/.claude/projects/<project-path>/memory/ --include="*.md"
```

### Store After Discovery

After solving a non-obvious problem, learning a convention, or making a
decision, store it immediately — do not wait, you will lose context.

**What to store:**
- Solutions to non-obvious problems (with error message as search term)
- Project conventions discovered while working
- Architectural decisions and their rationale
- User preferences for workflow or style
- Tool quirks and workarounds

**What not to store:**
- Obvious or well-documented information
- Temporary values or session-specific facts
- Verbose narratives (keep entries concise and searchable)

**Primary (Memento MCP available):**

Always search before creating — `mcp__memento__semantic_search` first. If a
related entity exists, extend it with `mcp__memento__add_observations` rather
than creating a duplicate.

**Entity naming:** `<Descriptive Name> <Project> <YYYY-MM>`
(e.g., "Cargo Test Timeout Fix TaskFlow 2026-01")

**Observation format:**
- Project-specific: `"Project: <name> | Path: <path> | Scope: PROJECT_SPECIFIC | Date: YYYY-MM-DD | <insight>"`
- General: `"Scope: GENERAL | Date: YYYY-MM-DD | <insight>"`
- Each observation must be a complete, self-contained statement

**Relationships — ALWAYS create at least one** after creating or updating an
entity. Use `mcp__memento__create_relations` to link to related entities.
Active-voice relation types: `implements`, `extends`, `depends_on`,
`discovered_during`, `contradicts`, `supersedes`, `validates`, `part_of`,
`related_to`, `derived_from`.

See `references/memento-protocol.md` for entity type table, observation
format guide, relationship table, traversal strategy, and examples.

**Fallback (no MCP):** write to `~/.claude/projects/<project-path>/memory/`
using the subdirectory structure:
```
memory/
  MEMORY.md       # Quick reference index (keep under 200 lines)
  debugging/      # Error solutions
  architecture/   # Design decisions
  conventions/    # Project patterns
  tools/          # Tool quirks
  patterns/       # Reusable approaches
```

Storage format for markdown files:
```markdown
# Brief Title with Keywords

**Context:** One sentence on when this applies.

**Discovery:** The key insight or solution, concise.

**Related:** Links to related memory files if any.
```

### Subagent Responsibilities

This protocol applies to both the main agent AND any subagents to which work
is delegated. When instructing a subagent, include the memory protocol
requirement explicitly.

Subagents must:
- Search Memento (or grep) before beginning their delegated task
- Store any new insights discovered during their work
- Create relationships to existing entities when applicable

### Keep MEMORY.md as Index (Fallback) or Session Summary (Memento)

**Without MCP:** `MEMORY.md` is loaded at session start. Use it as a concise
index of the most important facts — project overview, critical conventions,
known gotchas. Link to detailed files in subdirectories. Keep under 200 lines;
move detail to topic files when it grows beyond that.

**With Memento MCP:** `MEMORY.md` is optional. If maintained, use it only as
a brief session-start summary of the most critical active-project facts. The
knowledge graph is the authoritative store.

### Factory Memory

When running inside a pipeline or factory workflow, the pipeline stores
operational learnings in `.factory/memory/` to optimize future runs.

**Types of learnings tracked:**
- **CI patterns:** Which change types cause CI failures
- **Rework patterns:** Common rework causes by gate
- **Pair effectiveness:** Which engineer pairs are most effective in which domains
- **Domain hotspots:** Files and modules that frequently trigger findings

Standalone users can ignore factory memory; the standard memory practices
above remain unchanged.

### Prune Stale Knowledge

When you encounter a memory that is no longer accurate (API changed, convention
abandoned, bug fixed upstream), update or delete it. Wrong memories are worse
than no memories.

**Pruning triggers:**
- Memory contradicts current observed behavior
- Referenced files or APIs no longer exist
- Convention has clearly changed

### Store Before Context Loss

Before context compaction or at natural stopping points, **proactively store
any unsaved discoveries** before knowledge is lost to truncation. This is your
last chance before the knowledge evaporates.

### WORKING_STATE.md for Long-Running Sessions

For sessions lasting beyond a single task (pipeline runs, multi-slice TDD,
team coordination), maintain a WORKING_STATE.md file as insurance against
context compaction and crashes.

- **Location:** `.factory/WORKING_STATE.md` (pipeline mode) or project root
- **Update cadence:** after every significant state change
- **Read cadence:** at session start, after compaction, after any interruption

See `references/working-state.md` for the full format and examples.

### Self-Reminder Protocol

Long sessions cause instruction decay. Counter this by periodically
re-reading critical context:

- Every 5-10 messages, re-read: WORKING_STATE.md, role constraints, active task
- After ANY context compaction, immediately re-read all state before acting
- Critical for: pipeline controllers, team coordinators, long TDD sessions

The self-reminder is the primary defense against role drift.

## Enforcement Note

Detect at session start:
- Memento MCP tools available → primary approach (`mcp__memento__*`)
- No MCP available → file-based fallback (grep + markdown writes)

This skill provides advisory guidance; it cannot mechanically force recall or
storage. The recall-before-act and store-after-discovery patterns are
universal even if the storage mechanism varies by harness.

## Verification

After completing work guided by this skill, verify:

- [ ] Searched memory (semantic or grep) before starting the task
- [ ] Searched for error messages before debugging from scratch
- [ ] Stored discoveries as Memento entities or markdown files
- [ ] Related entities linked with `create_relations`
- [ ] Subagents instructed to follow the memory protocol
- [ ] MEMORY.md under 200 lines if maintained
- [ ] No stale or contradicted memories left uncorrected
- [ ] WORKING_STATE.md maintained for long-running sessions
- [ ] Self-reminder protocol followed (state re-read every 5-10 messages)

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
