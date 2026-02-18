# Progressive Disclosure Protocol

Control what the human sees and when. Full transparency is available on demand,
but the default is concise summaries that respect attention.

## One-Line Decision Summaries

After every consensus round, the facilitator produces exactly one summary line:

```
[DECISION] <category> | <motion summary> | <outcome> | <vote tally> | <stand-asides if any>
```

Examples:
- `[DECISION] Standard | Use PostgreSQL for persistence | Adopted | 8/8 consent | 0 stand-asides`
- `[DECISION] Trivial | Name module "auth_tokens" | Adopted | 7/8 consent | 1 stand-aside: Yegge prefers "token_service"`
- `[DECISION] Critical | Adopt event sourcing for audit trail | Escalated | 5/8 consent, 3 objects | See discussion transcript`

This is the only decision output the human receives by default. Do not
elaborate, do not include discussion excerpts, do not editorialize.

## Discussion Transcripts

Full discussion text is stored in `.team/discussions/`, one file per motion:

```
.team/discussions/YYYY-MM-DD-<slug>.md
```

Example: `.team/discussions/2026-02-18-persistence-layer-choice.md`

Each file contains:
- Motion text (original and as amended)
- Decision category
- Each member's response per round (attributed)
- Amendments proposed and their outcomes
- Final consensus check with each member's vote
- Outcome

These files are **never pushed to the human unprompted**. They exist so the
human can review any decision in depth if they choose to. The facilitator may
reference them: "Full discussion in `.team/discussions/2026-02-18-persistence-layer-choice.md`."

## Escalation Visibility

When a motion is escalated to the human (round limit reached without
consensus), the facilitator switches from summary mode to full-context mode:

1. State the motion (as amended)
2. Present each remaining position, attributed to its advocates
3. Summarize the core disagreement in 2-3 sentences
4. Include relevant excerpts from the discussion transcript
5. Ask the human to decide

Escalations are the one case where the human sees discussion detail without
requesting it. This is intentional: the human needs full context to break a tie.

## Build Phase Visibility

During ping-pong pairing (TDD implementation), the human sees only:

- **Pair selection**: Which two members are driving/reviewing, and their roles
- **Test status**: Pass/fail after each red-green-refactor cycle (one line each)
- **Escalation requests**: If the pair or reviewing team needs a human decision
- **Final outcome**: Tests passing, ready for review, or blocked with reason

The human does not see:
- Internal pair discussion about implementation approach
- Intermediate code states between test cycles
- Review comments that are resolved without escalation

If the human asks to see more detail at any point, provide it. Progressive
disclosure means the detail exists and is accessible -- it is just not the
default.

## Mode Transition Signals

When the system escalates from pair mode to full-team deliberation, the human must see a clear, one-line signal:

```
[MODE] Pair → Ensemble | Reason: <reason>
```

Example: `[MODE] Pair → Ensemble | Reason: Pair disagrees on error-handling strategy; needs team input`

The human can decline the escalation and direct the pair to continue on their own. Mode transitions should be rare during the build phase -- they indicate the pair hit something beyond their scope. If transitions are frequent, the original design discussion likely left ambiguity that should be addressed at the ensemble level first.

## Principle

Match information density to decision authority. The human makes high-level
product decisions and breaks ties. Give them the signal they need for that,
not the noise of eight experts debating variable names.
