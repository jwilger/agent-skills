# Agent Delivery Contract

## Purpose

The Agent Delivery Contract encodes explicit human vs. agent ownership for every
slice. Without it, agents optimize for what they infer rather than what was
intended — producing correct-looking code that solves the wrong problem.

This directly prevents:
- **ACD Pitfall #1** (Agent Defines Test Scenarios): humans own acceptance criteria
- **ACD Pitfall #4** (No Provenance Tracking): every phase decision traces to a tier

## Four-Tier Structure

| Tier | Name | Owner | Content |
|---|---|---|---|
| 1 | Intent | Human | Problem statement: what we're building, for whom, why now |
| 2 | Acceptance Scenarios | Human | Full-stack GWT scenarios (`acceptance_scenarios` array) |
| 3 | Feature Constraints | Human | Bounded context, domain types, architecture patterns to follow |
| 4 | Agent Interpretation | Agent (human-validated) | How the agent understands the work; open questions |

**The contract lives as a section in `docs/slices/<slice-id>/plan.md`** — not a
separate file. Add it after the Confirmed Acceptance Scenarios section.

## Contract Template

```markdown
## Agent Delivery Contract

### Tier 1 — Intent
[Problem statement: what we're building, for whom, why now]

### Tier 2 — Acceptance Scenarios
(reference to Confirmed Acceptance Scenarios above — no duplication)

### Tier 3 — Feature Constraints
- Bounded context: [name]
- Domain types in scope: [list]
- Architectural constraints: [patterns to follow per docs/ARCHITECTURE.md]

### Tier 4 — Agent Interpretation
[Agent's understanding of the work, drafted from Tiers 1–3]

**Open questions** (must be empty before approval):
- (none)

### Specification Quality Checklist
- [ ] Self-contained — implementable without clarifying questions
- [ ] Clear module boundaries — explicit inputs, outputs, integration points
- [ ] Observable acceptance criteria — user-visible outcomes only
- [ ] Test cases with known-good expected outputs — each scenario has
      deterministic expected output
- [ ] Evaluation design — how validation will be established
```

## Agent Role During Contract Creation

- **Tier 1:** Human writes; agent may ask clarifying questions only
- **Tier 2:** Agent drafts initial acceptance scenarios from Tier 1 intent;
  human decides which to keep, modifies wording, and adds missing cases
- **Tier 3:** Human writes; agent identifies missing constraints from the
  existing architecture documentation
- **Tier 4:** Agent drafts from Tiers 1–3; human validates for misinterpretation;
  open questions must be resolved before approval

Humans retain final decision authority on all tiers.

## Approval Gate

Human must sign off on Tiers 1–3 before implementation begins. This sign-off is
the Slice Readiness Review approval. Tier 4 is agent-drafted but must be reviewed
for misinterpretation before that approval is granted. Open questions in Tier 4
must be empty (same standard as the plan's Open Questions section).

## Scope Gate

If specifying the contract section takes more than ~15 minutes of human effort,
the slice is too large and should be split. Flag this in Open Questions.

## Per-Phase Context Scoping

Each pipeline phase receives only the contract tiers it needs. This enforces
context hygiene and prevents agents from anchoring on intent when they should
be focused on implementation details.

| Pipeline Phase | Contract Tiers Provided |
|---|---|
| Slice Readiness Review | All tiers (creating and validating) |
| TDD / implementation | Tier 2 (acceptance scenarios) + Tier 3 (feature constraints) |
| Code Review | Tier 1 (intent) + Tier 2 (acceptance scenarios) + Tier 4 (agent interpretation) |
| Mutation testing | No contract context (artifact-only phase) |
| CI | Automated; no agent context |

See `tokenomics.md` for the broader principle of per-phase context scoping.
