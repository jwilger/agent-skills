# Agent Skills for Software Development

Portable [Agent Skills](https://agentskills.io) that encode professional
software development practices for any AI coding agent. Skills are
composable, finer-grained "jobs to be done" — TDD phases, architecture
decision lifecycle, event modeling steps, design system creation, work
planning, and coordination patterns.

Skills describe **what** to do, not **how** to wire agents. Harness-specific
configuration (agent teams, subagent strategies, session management) is
per-project config outside this repo.

## Quick Start

Install individual skills:
```bash
npx skills add jwilger/agent-skills --skill tdd --skill domain-modeling
```

Install all skills:
```bash
npx skills add jwilger/agent-skills
```

## Skill Inventory

### Multi-Phase Skills

These skills have distinct phases accessed via sub-invocations.

| Skill | Sub-invocations | Description |
|-------|----------------|-------------|
| `tdd` | `/tdd red` `/tdd domain` `/tdd green` `/tdd commit` | Five-step TDD cycle: outside-in, one failing test, domain review with veto power |
| `event-modeling` | `/event brainstorm` `/event order` `/event wireframes` `/event commands` `/event read-models` `/event automations` `/event integrations` `/event slicing` | Event modeling facilitation from domain discovery through vertical slice decomposition |
| `design-system` | `/design audit` `/design tokens` `/design hierarchy` `/design implementation` `/design documentation` `/design facilitation` `/design artifacts` | Collaborative design system creation using Atomic Design methodology |

### Standalone Skills

| Skill | Description |
|-------|-------------|
| `domain-modeling` | Parse-don't-validate, semantic types, no primitive obsession, make invalid states unrepresentable |
| `code-review` | Three-stage review: spec compliance, code quality, domain integrity |
| `debugging-protocol` | 4-step debugging: observe, hypothesize, experiment, conclude |

### Architecture Skills

| Skill | Description |
|-------|-------------|
| `architecture-probe` | Actively identify architectural decisions needed before building |
| `architecture-adr` | Four-phase ADR lifecycle (RESEARCH, DRAFT, HOLD, MERGE) as PR bodies |
| `architecture-refresher` | Load docs/ARCHITECTURE.md before build phases |
| `architecture-crosscut` | Detect cross-cutting concerns during build, trigger new ADR |

### Work Planning Skills

| Skill | Description |
|-------|-------------|
| `vertical-slice-ticket` | Create well-formed tickets with boundary acceptance criteria |
| `prd-breakdown` | Break PRDs into vertical slice stories |

### Coordination Skills

Agent-count-agnostic — work for solo reflection, two agents, or a full team.

| Skill | Description |
|-------|-------------|
| `consensus-facilitation` | Facilitate consensus alignment among agents or personas |
| `consensus-participation` | Participate in consensus with informed positions |
| `persona-creation` | Create agent personas based on real-world experts |
| `retrospective` | Structured retrospective (solo or multi-agent) |
| `handoff-protocol` | Structured handoff between agents or phases |

## How Skills Work

Each skill is a Markdown file (`SKILL.md`) with frontmatter metadata and
six required body sections:

1. **Value** — Which XP value(s) the skill serves
2. **Purpose** — What it teaches (2-3 sentences)
3. **Practices** — Concrete, actionable instructions
4. **Enforcement Note** — What it can/cannot guarantee
5. **Verification** — Binary self-check checklist
6. **Dependencies** — Integration points with other skills

Multi-phase skills route to `references/` files via sub-invocations for
detailed phase instructions.

## Contributing

Skills follow the template at `skills/.template/SKILL.md.example` and the
frontmatter reference at `skills/.template/FRONTMATTER.md`. Keep SKILL.md
under 500 lines. Move detailed content to `references/`.

## License

CC0-1.0
