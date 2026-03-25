---
name: session-reflection
description: >-
  Structured session analysis and project instruction refinement using a
  five-type intervention taxonomy (Correction, Repetition, Role Redirect,
  Frustration Escalation, Workaround) with severity scoring. Refines project
  instructions (CLAUDE.md, AGENTS.md) with structural language, maintains
  WORKING_STATE.md for crash recovery, and implements a self-reminder protocol
  to prevent role drift. Includes advisory-to-structural promotion for
  recurring gaps. Use after milestones, repeated user corrections, session
  restarts, crash recovery, every 5 completed tasks, or on request. Triggers
  on: "reflect on this session", "why do I keep correcting you", "update
  project instructions", "session retrospective", "crash recovery", "context
  compaction", "role drift", "analyze my corrections". Also relevant when
  noticing repeated corrections or resuming after compaction.
license: CC0-1.0
metadata:
  author: jwilger
  version: "2.1.1"
  requires: []
  optional: [memory-protocol, agent-coordination]
  context: [git-history]
  phase: build
  standalone: true
  constraint_resolution: true
effort: medium
---

# Session Reflection

**Value:** Feedback -- every user intervention is a signal that the system
prompt is incomplete. Turning corrections into durable instructions creates
compound improvement across sessions.

## Purpose

Teaches agents to analyze session history for recurring corrections, generate
project-specific instructions that prevent known failure modes, and maintain
working state that survives context compaction and crashes. Transforms reactive
corrections into proactive prevention.

## Practices

### Reflection Triggers

Reflect after: milestones (PR merged, feature complete), 3+ repeated
corrections from the user, session restart or crash recovery, every 5
completed tasks, and on explicit user request. Do not wait for a "good time"
-- reflect when triggered.

### Analyze Session History

Examine conversation history, git log, memory files, WORKING_STATE.md, and
session logs. Categorize each user intervention into one of five types:

- **Correction**: Agent did the wrong thing (instruction gap)
- **Repetition**: Agent was told the same thing again (emphasis gap)
- **Role Redirect**: Agent stepped outside its role (boundary gap)
- **Frustration Escalation**: User became more forceful (decay problem)
- **Workaround**: User did it themselves (skill gap)

See `references/analysis-framework.md` for detailed categorization and
prioritization.

### Generate or Refine Project Instructions

Route project-specific directives into the appropriate instruction file
based on content type. There is no separate system prompt file — everything
flows from CLAUDE.md → AGENTS.md → .team/coordinator-instructions.md:

- **CLAUDE.md** — Session management (startup procedure, compaction recovery,
  state tracking), harness-specific configuration
- **AGENTS.md** — General project rules, dos/don'ts, coding conventions,
  workflow configuration
- **.team/coordinator-instructions.md** — Coordinator/pipeline-controller role
  distinctions, build pre-flight gates, spawn discipline, domain review
  checklists

Refinement rules: add new items for new gaps, promote advisory to structural
when gaps recur, rewrite ambiguous items for clarity. Never remove items
until the gap is confirmed solved across 3+ sessions. See
`references/system-prompt-patterns.md` for writing patterns and
`references/launcher-templates.md` for harness-specific file routing.

### Self-Reminder Protocol

See `CONSTRAINT-RESOLUTION.md` in the template directory for the
consolidated self-reminder protocol (frequency, combined re-read list,
and post-compaction rules).

### Working State Persistence

Maintain WORKING_STATE.md as insurance against context compaction and crashes.
Update after every significant state change. Always read before acting after
any interruption. Location: `.factory/WORKING_STATE.md` (pipeline) or project
root (standalone). See `references/working-state-schema.md` for format.

**Do:**
- Update on task start, phase change, decision made, blocker encountered
- Overwrite with current state (not append)
- Read FIRST after any interruption

**Do not:**
- Guess state from memory after a compaction or restart
- Use as a journal -- keep it concise and current
- Skip updates because "nothing important changed"

### Post-Session Learning Loop

At session end: identify patterns from this session, update memory files,
refine project instructions if triggers were hit, archive working state.

The loop closes when the same category of intervention stops recurring. If
an intervention category persists across 3+ sessions after instruction
refinement, escalate: the gap may require a new skill or a structural
change to the workflow.

## Enforcement Note

Advisory in all modes. Reflection triggers and instruction generation are
self-enforced.

**Hard constraints:**
- Mandatory after context compaction: `[H]` -- context compaction destroys
  implicit state; re-reading is not optional.

## Constraints

- **"3+ repeated corrections"**: A "repeated correction" means the user
  corrected the same underlying behavior multiple times. Different phrasings
  of the same correction count as one correction repeated. Different
  corrections in the same category (e.g., two different formatting
  preferences) count separately.
- **"Never remove instructions until confirmed solved across 3+ sessions"**:
  This prevents premature cleanup. An instruction that hasn't triggered in
  3 sessions might be preventing the problem -- that's success, not staleness.
  Remove only when you have positive evidence the underlying behavior is
  fixed (e.g., the code pattern that caused the issue no longer exists).

## Verification

After completing work guided by this skill, verify:

- [ ] Reflection performed at every trigger point (milestone, repeated correction, restart)
- [ ] User interventions categorized using the five-type taxonomy
- [ ] Project instructions refined with structural (not just advisory) language
- [ ] Directives routed to correct file (CLAUDE.md / AGENTS.md / coordinator-instructions.md)
- [ ] Self-reminder protocol followed (state re-read every 5-10 messages)
- [ ] WORKING_STATE.md current and accurate
- [ ] State re-read after every context compaction (not guessed)

If any criterion is not met, revisit the relevant practice before proceeding.

## Dependencies

This skill works standalone. For enhanced workflows, it integrates with:

- **memory-protocol:** Persistent storage for session learnings and working state
- **agent-coordination:** Coordination patterns referenced in instruction generation
- **pipeline:** Pipeline controller benefits from self-reminder and crash recovery
- **ensemble-team:** Team retrospectives feed into session reflection analysis

Missing a dependency? Install with:
```
npx skills add jwilger/agent-skills --skill memory-protocol
```
