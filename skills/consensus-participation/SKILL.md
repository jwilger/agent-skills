---
name: consensus-participation
description: >-
  Participate in consensus discussions by providing informed input,
  constructive critique, and clear positions. Activate when asked
  to contribute to a decision or review.
license: CC0-1.0
metadata:
  author: jwilger
  version: "1.0"
  requires: []
  context: []
  phase: decide
  standalone: true
---

# Consensus Participation

**Value:** Courage and respect -- courage to state disagreements clearly and
specifically, respect to engage with others' positions substantively and
commit to the group's decision once made.

## Purpose

Teaches how to participate effectively in consensus discussions by providing
positions grounded in evidence, distinguishing blocking concerns from
preferences, proposing alternatives when disagreeing, and committing to
the outcome. Prevents empty agreement, vague objections, and post-decision
undermining.

## Practices

### Provide Positions with Rationale

Every position must include WHY, not just WHAT. A position without rationale
is noise.

**Do:**
```
I recommend SQLite because this is a single-user desktop app with a
small dataset (<10k records). SQLite requires no server process,
works offline natively, and simplifies deployment. The risk is that
we lack team experience with SQLite, which a half-day spike could
mitigate.
```

**Do not:**
```
I think SQLite is fine.
```

Ground your rationale in evidence: code you have read, documentation you
have reviewed, prior decisions, performance data, or domain constraints.
Opinions without evidence carry no weight in consensus.

### Distinguish Blocking Concerns from Preferences

Not all disagreements are equal. Be explicit about the strength of your
position.

**Blocking concern:** "This approach creates a security vulnerability
because user input reaches the database without sanitization. I cannot
accept this design until input validation is added." A blocking concern
identifies a concrete risk or violation that must be addressed.

**Preference:** "I would rather use a factory method than a constructor
here, but either approach works correctly." A preference is something you
would like but can accept the alternative.

State which one yours is. If everything is blocking, nothing is blocking.
Reserve blocking status for genuine risks: security issues, data loss,
specification violations, architectural integrity.

### Engage Substantively with Other Positions

When you disagree, engage with the substance of the other position.

1. **Acknowledge** what the other position gets right
2. **Identify** the specific point of disagreement
3. **Explain** why you disagree with evidence
4. **Propose** an alternative that addresses both positions

```
I agree that SQLite simplifies deployment (good point about zero
server overhead). However, the PRD mentions a "team collaboration"
feature in phase 2, which requires concurrent multi-user writes.
SQLite's write locking would become a bottleneck. I propose we start
with PostgreSQL and use Docker Compose for local development to keep
setup simple.
```

**Do not:**
- Dismiss without engaging: "That won't work"
- Appeal to authority without evidence: "Best practice says..."
- Repeat your position louder instead of responding to the critique

### Propose Alternatives When Disagreeing

Disagreeing without an alternative is just complaining. If you reject an
approach, you owe the group a better option.

Your alternative must be:
- **Specific** enough to evaluate (not "we should think about this more")
- **Feasible** within the project's constraints
- **Responsive** to the concern that motivated the original proposal

If you genuinely cannot think of a better alternative, say so explicitly
and suggest what investigation might reveal one.

### Commit After Decide

Once consensus is reached, commit to the decision -- even if you preferred
a different option. This means:

1. **Implement faithfully.** Do not subtly undermine the decision by
   implementing your preferred approach "because it's easier."
2. **Advocate publicly.** If asked about the decision, present the group's
   rationale, not your personal preference.
3. **Raise new evidence, not old arguments.** If new information emerges
   that changes the calculus, bring it to the group. Do not re-litigate
   the same arguments that were already considered.

The commitment is to the process, not to agreeing. You can disagree and
commit. What you cannot do is disagree and sabotage.

### Solo Mode: Internal Critic

When participating in solo consensus (adopting perspectives), commit to
each perspective fully:

1. Adopt the viewpoint genuinely -- argue its strongest case
2. Do not strawman a perspective just to knock it down
3. Let each perspective challenge the others with real concerns
4. After synthesis, commit to the decision without revisiting

## Enforcement Note

This skill provides advisory guidance. It instructs the agent on how to
participate in consensus discussions but cannot mechanically prevent empty
agreement or post-decision undermining. The requirement for rationale with
every position is enforced by convention -- the facilitator (or the agent
itself in solo mode) rejects positions that lack evidence. If you observe
positions without rationale being accepted, point it out.

## Verification

After participating in a consensus discussion, verify:

- [ ] Every position you provided included specific rationale with evidence
- [ ] You explicitly labeled each concern as blocking or preference
- [ ] You engaged substantively with positions you disagreed with
- [ ] You proposed alternatives when disagreeing (not just objecting)
- [ ] You acknowledged valid points in other positions
- [ ] You committed to the final decision without undermining it
- [ ] You did not re-litigate decided points without new evidence

If any criterion is not met, revisit the relevant practice before proceeding.

## Dependencies

This skill works standalone. For enhanced workflows, it integrates with:

- **consensus-facilitation:** Provides the structure within which
  participation happens -- framing, rounds, synthesis, and escalation.
- **persona-creation:** When participating as an expert persona, grounds
  your perspective in that persona's published expertise.

Missing a dependency? Install with:
```
npx skills add jwilger/agent-skills --skill consensus-facilitation
```
