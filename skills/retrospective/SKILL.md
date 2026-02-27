---
name: retrospective
description: >-
  Structured retrospective for reflecting on completed work. Identifies
  what went well, what didn't, and actionable improvements. Works solo
  or with multiple agents. Activate after completing a feature, sprint,
  or significant work item.
license: CC0-1.0
metadata:
  author: jwilger
  version: "1.0"
  requires: []
  context: [git-history, source-files]
  phase: ship
  standalone: true
---

# Retrospective

**Value:** Feedback and courage -- feedback because retrospectives turn
experience into learning, courage because honest assessment of what went
wrong requires candor about mistakes.

## Purpose

Teaches a structured retrospective process that reviews completed work,
identifies what went well and what did not, and produces actionable
improvements. Prevents retrospectives from degenerating into venting
sessions or vague platitudes by requiring specific, assignable actions.

## Practices

### When to Run a Retrospective

Run a retrospective after:
- Completing a feature or significant work item
- Finishing a sprint or iteration
- Resolving a significant bug or incident
- Any time the team (or you, working solo) feels "that was harder than
  it should have been"

Do not skip retrospectives because things went well. Understanding WHY
things went well is as valuable as understanding failures.

### Three Phases

Every retrospective follows three phases in order. Do not skip or combine
them.

#### Phase 1: Gather Data

Collect facts about what happened. No interpretation yet.

1. Review git history for the period (`git log --oneline --since=...`)
2. List completed work items and their outcomes
3. Note any incidents, bugs, or unexpected issues encountered
4. Record timeline: what happened in what order
5. Identify any tools, processes, or decisions that affected the work

**Output:** A factual timeline of events and outcomes. No judgments.

```
DATA:
- Completed slices: user-login, user-registration, password-reset
- 2 TDD cycles required debugging-protocol intervention (login
  session handling, email validation)
- Password-reset took 3x longer than estimated due to unclear
  acceptance criteria
- All tests passing, CI green, deployed to staging
```

#### Phase 2: Generate Insights

Analyze the data to understand WHY things happened as they did.

For each notable event from Phase 1:
1. Ask "why did this happen?" (not "whose fault is this?")
2. Identify contributing factors (process, tooling, communication,
   knowledge gaps)
3. Distinguish root causes from symptoms
4. Note patterns: did the same issue occur multiple times?

**Output:** Insights connecting events to causes.

```
INSIGHTS:
- Debugging interventions both involved edge cases not covered by
  acceptance criteria -> criteria writing process needs edge case
  checklist
- Password-reset delay caused by ambiguous PRD language ("secure
  reset" undefined) -> PRD review should flag undefined terms
- Login and registration went smoothly because event model was
  detailed for those flows -> event modeling investment pays off
```

#### Phase 3: Decide Actions

Convert insights into specific, actionable improvements.

Every action must be:
- **Specific:** What exactly will change (not "improve testing")
- **Assignable:** Who will do it (a person, a role, or "the team")
- **Measurable:** How will you know it worked
- **Time-bound:** When will it be done or reviewed

Categorize actions:

- **Keep doing:** Things that went well and should continue
- **Stop doing:** Things that caused problems and should be eliminated
- **Start doing:** New practices to adopt based on insights

```
ACTIONS:
Keep doing:
  - Detailed event modeling before implementation (measurably fewer
    debugging interventions on modeled flows)

Stop doing:
  - Accepting PRD language without definitions for security-related
    terms

Start doing:
  - Edge case checklist during ticket writing (add to readiness
    checklist by next sprint)
  - PRD review pass for undefined domain terms (add to prd-breakdown
    process immediately)
```

Limit actions to 3-5. More than 5 actions will not all be completed.
Prioritize the highest-impact changes.

### Multi-Agent Retrospectives

When multiple agents participated in the work:

1. Each agent contributes observations from their perspective (Phase 1)
2. The facilitator collects and deduplicates observations
3. Insights are generated collaboratively (Phase 2)
4. Actions are decided by consensus (Phase 3)

Use the `consensus-facilitation` skill if disagreements arise about
which actions to prioritize.

### Solo Retrospectives

When working alone, run the same three phases but be deliberate about
self-honesty:

1. Do not skip Phase 1 data gathering -- review actual git history and
   artifacts, do not rely on memory
2. In Phase 2, actively look for YOUR mistakes, not just external factors
3. In Phase 3, commit to actions you will actually do (not aspirational
   changes you will forget)

### Retrospective Output

Produce a structured retrospective document:

```
RETROSPECTIVE: [Feature/Sprint/Period name]
Date: [date]
Participants: [who was involved]

## Data
[Factual timeline from Phase 1]

## Insights
[Analysis from Phase 2]

## Actions
Keep doing: [list]
Stop doing: [list]
Start doing: [list with assignee and timeline]
```

Store the retrospective where the team can reference it. For projects using
memory protocols, record key actions in the project memory.

## Enforcement Note

This skill provides advisory guidance. It instructs the agent on how to
conduct a structured retrospective but cannot mechanically prevent shallow
retrospectives or vague actions. The requirement that actions be specific,
assignable, measurable, and time-bound is enforced by self-check. If you
observe actions like "improve testing" without specifics, point it out.

## Verification

After conducting a retrospective, verify:

- [ ] All three phases were completed in order (data, insights, actions)
- [ ] Phase 1 used actual artifacts (git history, work items) not memory
- [ ] Phase 2 identified root causes, not just symptoms
- [ ] Phase 2 asked "why" not "who"
- [ ] Every action is specific, assignable, measurable, and time-bound
- [ ] Actions are categorized (keep/stop/start)
- [ ] Total actions are 3-5 (not an overwhelming list)
- [ ] A structured retrospective document was produced
- [ ] Positive outcomes were captured (not just problems)

If any criterion is not met, revisit the relevant phase before finalizing.

## Dependencies

This skill works standalone with no required dependencies. It integrates with:

- **consensus-facilitation:** Structures multi-agent retrospective
  discussions when prioritizing actions.

Missing a dependency? Install with:
```
npx skills add jwilger/agent-skills --skill consensus-facilitation
```
