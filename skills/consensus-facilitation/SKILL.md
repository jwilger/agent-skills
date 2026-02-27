---
name: consensus-facilitation
description: >-
  Facilitate consensus alignment among agents or personas. Structure
  discussion rounds, collect positions, synthesize agreement, and
  escalate deadlocks. Activate when a decision requires input from
  multiple perspectives.
license: CC0-1.0
metadata:
  author: jwilger
  version: "1.0"
  requires: []
  context: []
  phase: decide
  standalone: true
---

# Consensus Facilitation

**Value:** Communication and respect -- structured facilitation ensures every
perspective is heard, disagreements are surfaced explicitly, and decisions
are made collectively rather than by whoever speaks loudest.

## Purpose

Teaches how to facilitate a consensus process that collects informed
positions, identifies common ground, and synthesizes agreement. Works for
solo reflection (adopting multiple perspectives), two-agent discussions, or
full team decisions. Prevents deadlocks through a strict round limit and
escalation path.

## Practices

### The Facilitator Role

The facilitator structures the discussion. The facilitator does NOT decide
the outcome. Your job is to:

1. Frame the question clearly
2. Collect positions from all participants
3. Identify areas of agreement and disagreement
4. Propose a synthesis
5. Confirm consensus or escalate

If you are both facilitating and participating (solo reflection), separate
the roles explicitly. State your facilitation actions and your participant
positions in distinct sections.

### Step 1: Frame the Question

Present the decision clearly before collecting positions.

1. State the question in one sentence
2. Provide relevant context (constraints, prior decisions, tradeoffs)
3. List the options under consideration (if known)
4. State what "done" looks like -- what artifact or action results from
   this decision

```
DECISION NEEDED: Should we use PostgreSQL or SQLite for the task
management database?

Context: Single-user desktop app, <10k records expected, must work
offline. Team has PostgreSQL experience but no SQLite experience.

Options: (A) PostgreSQL, (B) SQLite, (C) other proposal
Outcome: An ADR documenting the choice and rationale.
```

If the question is vague, clarify it before proceeding. A vague question
produces vague consensus.

### Step 2: Collect Positions

Each participant provides a position with rationale. Not just a vote.

A valid position includes:
- **Choice:** Which option (or a new proposal)
- **Rationale:** Why this option, grounded in evidence (code, docs,
  research, experience)
- **Concerns:** What risks or downsides exist with this choice
- **Blocking vs. preference:** Is this a strong conviction (would block
  alternatives) or a preference (could accept other options)

```
POSITION (Participant A):
Choice: SQLite
Rationale: Single-user app with small dataset. SQLite requires no
  server process and works offline natively. Deployment is simpler.
Concerns: Team lacks SQLite experience; migration path unclear if
  we later need multi-user support.
Blocking: No -- preference, not a hard requirement.
```

Reject positions that lack rationale. "I agree" or "Option B" without
explanation does not count as a position.

### Step 3: Identify Common Ground

After collecting all positions, the facilitator synthesizes:

1. **Agreement areas:** What do all participants agree on?
2. **Disagreement areas:** Where do positions conflict?
3. **Blocking concerns:** Are any concerns blocking (must be addressed)?
4. **Non-blocking preferences:** What can be accommodated without
   compromising the decision?

Present this summary back to participants before proposing a synthesis.

### Step 4: Propose a Synthesis

The facilitator proposes a decision that:

- Addresses all blocking concerns
- Incorporates as many non-blocking preferences as possible
- Includes mitigations for identified risks

```
PROPOSED SYNTHESIS:
Use SQLite for v1. Mitigate the team's inexperience with a spike
task (half-day) to prototype the data layer. Document the decision
in an ADR that includes migration criteria for when to switch to
PostgreSQL (e.g., multi-user requirement emerges).
```

The synthesis is a proposal, not a decree. Participants may accept, counter,
or raise new concerns.

### Step 5: Confirm or Escalate

**Consensus reached:** All participants accept the synthesis (even if
some preferred a different option). Record the decision, rationale, and
any dissenting preferences that were accommodated.

**Consensus not reached after 3 rounds:** Escalate to the human. Present:
- The original question
- Each participant's final position
- Where agreement exists and where it does not
- The facilitator's recommended decision (clearly labeled as a
  recommendation, not a consensus)

Three rounds is the hard limit. Continuing beyond three rounds produces
diminishing returns and delays action. The human breaks the deadlock.

### Record the Decision

Every consensus process produces a decision record:

```
DECISION RECORD
Question: [the question]
Decision: [what was decided]
Rationale: [why, incorporating key arguments]
Dissent: [any positions that accepted but disagreed, with their reasoning]
Date: [when decided]
```

Store this in the appropriate place for the project (ADR, issue comment,
meeting notes, or inline in the relevant file).

### Solo Reflection Mode

When working alone, use this process for important decisions by adopting
multiple perspectives:

1. Frame the question as above
2. Consider the question from 2-3 distinct viewpoints (e.g., user
   experience, technical simplicity, long-term maintainability)
3. State each viewpoint's position with rationale
4. Synthesize across viewpoints
5. Record the decision

This prevents single-perspective blind spots on consequential choices.

## Enforcement Note

This skill provides advisory guidance. It instructs the agent on how to
facilitate consensus but cannot mechanically prevent skipping steps or
forcing decisions without genuine agreement. The three-round limit and
escalation to human are enforced by convention. If you observe the
facilitator deciding instead of synthesizing, or rounds exceeding the
limit without escalation, point it out.

## Verification

After facilitating a consensus process, verify:

- [ ] The question was framed clearly with context and options
- [ ] Every participant provided a position with rationale (not just a vote)
- [ ] Common ground and disagreements were explicitly identified
- [ ] A synthesis was proposed that addresses blocking concerns
- [ ] Consensus was confirmed or escalated within 3 rounds
- [ ] A decision record was produced with rationale and dissent
- [ ] The facilitator synthesized rather than decided

If any criterion is not met, revisit the relevant step before proceeding.

## Dependencies

This skill works standalone. For enhanced workflows, it integrates with:

- **consensus-participation:** Teaches participants how to provide
  well-formed positions with evidence and constructive critique.
- **persona-creation:** Provides distinct expert perspectives for richer
  solo reflection or multi-agent consensus.
- **architecture-decisions:** Consensus outcomes on architectural questions
  can be recorded as ADRs.

Missing a dependency? Install with:
```
npx skills add jwilger/agent-skills --skill consensus-participation
```
