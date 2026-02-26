# Retrospective Protocol

A single agent writing all perspectives is NOT a retrospective — it is a
summary. Retrospectives require actual exchange between distinct agents,
each bringing their own accumulated context and perspective.

## Prerequisites

- Every agent spawned for the retrospective MUST be a named team member
  from `.team/`. Never use generic background agents.
- The coordinator facilitates but does NOT contribute observations (the
  coordinator has no development perspective to share).
- The human is a team member who participates in the consent protocol.

## Phase 1: Previous Action Item Audit

Before generating new observations, audit all action items from the
previous retrospective.

1. Read the last retrospective output from `AGENTS.md` or the retro
   archive.
2. For each action item, determine status: DONE, IN-PROGRESS, NOT-STARTED.
3. Items marked NOT-STARTED from 2+ retros ago escalate to blocking:
   - The team must address them before proceeding to Phase 2.
   - If the item is no longer relevant, the team votes to close it with
     a documented reason.

**Anti-pattern: Skipping Phase 1.** This is how action items die. If the
team never checks whether items were implemented, they learn that retro
outputs are decorative.

## Phase 2: Individual Observations

Each team member writes their observations independently to
`.reviews/retro/<member-name>-<date>.md`.

**Format per member:**
```markdown
# Retro Observations: [Member Name] — [Date]

## What Worked
- [observation with specific example]

## What Didn't Work
- [observation with specific example]

## Proposals
- [concrete, actionable proposal]
```

**Rules:**
- Write to file before any discussion. Files prevent groupthink.
- Each observation must reference a specific event, not a general feeling.
- Proposals must be concrete ("add X check to review checklist") not
  abstract ("improve code quality").

**File count gate:** The coordinator MUST verify that at least N distinct
team members wrote observation files to `.reviews/retro/` before
proceeding to Phase 3. Count the files: `ls .reviews/retro/*-<date>.md`.
If fewer than the expected number of members contributed, the coordinator
prompts the missing members before synthesizing. A single-agent summary
masquerading as a team retrospective is a protocol violation.

**Anti-pattern: Single-agent retro.** One agent reading all profiles and
generating "observations" for each member. This produces bland, uniform
observations that lack the creative tension of real disagreement.

## Phase 3: Team Discussion

After all members have written observations, the coordinator initiates
discussion.

1. Coordinator reads all observation files and presents a summary of
   themes.
2. Each member reacts to other members' observations via messages. This
   must be actual message exchange — the coordinator verifies that members
   are responding to each other, not just restating their own points.
3. Discussion continues until themes converge into proposals.

**What the coordinator verifies:**
- At least one member responded to another member's observation (not just
  acknowledged it)
- Proposals emerged from discussion, not from a single member's original
  list
- Disagreements were surfaced, not smoothed over

**Anti-pattern: Coordinator-run retro.** The coordinator writes the summary
and presents it as team consensus. The coordinator facilitates — they do
not author the retrospective.

## Phase 4: Consensus and Record

1. Each proposal goes through the consent protocol (same as formation
   session decisions).
2. The human must consent as a team member before changes to `AGENTS.md`
   or new ADRs are adopted.
3. Every adopted action item MUST have a named owner (a specific team
   member, not "the team").
4. Record outputs to the appropriate location:
   - Process changes → `AGENTS.md` conventions section
   - Architectural changes → ADR in `docs/ARCHITECTURE.md`
   - Action items → tracked in `AGENTS.md` with owner and status

**Anti-pattern: No-owner action items.** "We should improve test coverage"
with no owner means nobody is accountable. Every item needs a name next
to it.

## Action Item Implementation Gate

Adopted action items are implemented before the next work item starts.
This is non-negotiable. The implementation may be small (add a checklist
item, update a convention) or large (refactor a process), but it happens
before new feature work begins.

**Rationale:** If action items can be indefinitely deferred, the retro
process becomes theatre. Implementing immediately creates a real feedback
loop between reflection and practice.

## Non-Blocking Feedback Escalation

During retrospective review of deferred items and review findings:

- Any non-blocking item that appeared in 2+ consecutive reviews of
  different slices MUST be escalated to blocking.
- Track this by reviewing previous `.reviews/` files.
- Escalated items are added to the retro action items with a named owner.

## Archive

After the retro completes, the coordinator archives all observation files:

```
.reviews/retro/archive/[date]/
  [member-name].md
  summary.md (coordinator's summary of discussion and outcomes)
```

This creates a historical record for future retros to reference patterns
over time.
