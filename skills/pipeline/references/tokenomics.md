# Tokenomics

Token cost is an architectural constraint, not an afterthought. At Stage 6
(multi-agent architecture), token decisions made during design determine whether
the pipeline is economically sustainable at scale.

## The Three High-Leverage Decisions

### 1. Model Routing

Not every task requires a frontier model. Routing tasks to the right tier reduces
cost while maintaining quality where it matters.

| Task type | Recommended tier |
|---|---|
| Orchestration, routing, state management | Small-to-mid tier |
| Summarization, structured output, classification | Mid tier |
| Implementation, novel reasoning, domain review | Frontier tier |
| Expert validation agents (spec compliance, domain integrity) | Frontier tier |

The pipeline controller itself (routing work, managing state) should run at a
lower tier than the agents doing creative work.

### 2. Context Hygiene

Each agent should receive only what its phase requires. Passing full conversation
history, entire codebases, or all contract tiers to every agent is the single
largest avoidable cost in multi-agent pipelines.

**Per-phase scoping:** See `agent-delivery-contract.md` for the table defining
exactly which contract tiers each pipeline phase receives.

**Diffs over files:** Where an agent needs to understand a change, pass the diff
rather than the full file. The agent can request the full file if it needs it;
defaulting to full files costs tokens on every invocation.

**Phase boundaries:** Strip conversation history at phase boundaries. Replace it
with the phase's structured evidence packet (e.g., `CYCLE_COMPLETE` for TDD,
`REVIEW_RESULT` for code review). The structured packet contains everything the
next phase needs and nothing it does not.

**Domain type discovery:** Load only the domain types referenced by the current
slice (from `domain_types_referenced` in the slice context), not the full type
registry.

### 3. Prompt Caching

Place skill definitions and system prompts at the top of context. Cache hit spans
are longest when stable content (skills, system prompts) precedes variable content
(task details, code). Most inference providers cache prefix content automatically;
maximizing the stable prefix maximizes the cache hit rate across repeated
invocations of the same agent role.

## The Correction Loop Multiplier

Failed outputs requiring re-prompting cost approximately 3x the tokens of
successful attempts: the failed attempt, the correction prompt, and the retry.

This is the economic argument for gate quality. A gate that catches an error early
(Slice Readiness Review) is ~10x cheaper than a gate that catches it late (mutation
testing or CI). The cascade: a bad acceptance scenario caught at readiness review
costs 1 correction; the same scenario caught after TDD cycles, code review, and
mutation testing costs 3 re-prompts at each gate plus the wasted TDD cycles.

**Implication:** Investing tokens in thorough Slice Readiness Reviews and
Agent Delivery Contracts is economically rational, not expensive.

## Anti-Patterns

- Passing full codebases to implementation agents when only changed files matter
- Keeping conversation history across phase boundaries instead of using evidence packets
- Running orchestration logic on frontier models when mid-tier is sufficient
- Omitting context hygiene "to simplify the pipeline" — simplicity here is false economy
