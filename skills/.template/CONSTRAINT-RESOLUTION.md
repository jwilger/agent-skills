# Constraint Resolution

When skills conflict, this document provides the resolution. Skills
reference this document rather than embedding their own conflict rules.

## Priority Order

When two skill constraints conflict, resolve using this priority:

1. **Safety constraints** (any skill) -- never yield
2. **User's explicit override** -- always respected when given
3. **Halt `[H]`** outranks **Record & Pause `[RP]`** outranks **Record &
   Continue `[RC]`**
4. **Process skills** (tdd, debugging-protocol) outrank **workflow skills**
   (pipeline, ensemble-team) on questions of *how work is done*
5. **Workflow skills** outrank **process skills** on questions of *when and
   whether work proceeds*
6. When two constraints at the same priority conflict, the **more specific**
   constraint wins (e.g., "no production code in RED phase" beats "complete
   the slice efficiently")

## Known Conflict Resolutions

### Pipeline rework budget vs. code-review convention violation

Convention violation consumes a rework cycle. If the rework budget is
exhausted, escalate the slice `[RP]` -- do not skip convention enforcement.

### Ensemble consensus vs. pipeline auto-merge

In factory mode, consensus applies to slice *planning* (pre-pipeline).
During build, the pipeline controller operates without consensus.
Post-build, the full-team review gate provides the consensus checkpoint
before merge to main. Auto-merge at full autonomy still requires the
review gate to pass.

### Domain veto vs. pipeline autonomy

In pipeline mode, a domain veto that can't resolve in 2 rounds becomes a
domain concern recorded in evidence. It surfaces at the pre-push review
gate. If unresolved at review, the slice escalates `[RP]`.

### Task-management one-active-per-agent vs. pipeline parallel slices

Each parallel worktree is treated as a separate agent context. One active
task per worktree, not per human operator.

### Memory-protocol recall vs. TDD pair speed

TDD pairs perform recall at spawn time (pre-spawn context checklist). They
do NOT perform mid-cycle recall during red-green-domain-commit.

### ADR "research cannot be waived" vs. sources don't exist

Surface the blocker `[RP]`. Do not write an unverified ADR. Do not
fabricate research. Record what was attempted and what's missing.

### Mutation testing 100% kill rate vs. user override

User override must be accompanied by a documented reason in the audit
trail. "I want to skip this" is not sufficient -- the reason must explain
why the surviving mutants are acceptable.

## Self-Reminder Protocol (Consolidated)

When multiple skills define self-reminder protocols, combine their re-read
lists into a single pass at the longest interval. Do not re-read the same
files multiple times per interval.

**Frequency:** Every 10 messages.

**Combined re-read list:**
- Project instructions (CLAUDE.md / AGENTS.md)
- Role constraints (current agent persona, if any)
- Current task context
- WORKING_STATE.md (if it exists)
- Gate task list (if in pipeline mode)
- Controller role boundaries (if acting as pipeline controller)

One pass. Every 10 messages. Not three separate passes at different
frequencies.

**Mandatory after context compaction:** Context compaction destroys implicit
state. Re-reading is not optional after compaction regardless of message
count.

## Anti-Workaround Principle

Technical compliance that defeats the purpose of a constraint is a
violation. When a constraint says "do X," it means "achieve the outcome X
is designed to produce," not "perform an action that superficially
resembles X."

If you find yourself reasoning about why a workaround is technically
allowed, that reasoning is evidence that you're violating the spirit of
the constraint.
