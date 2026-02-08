# Agent Skills for Software Development

Portable [Agent Skills](https://agentskills.io) that encode professional
software development practices -- TDD, domain modeling, event modeling,
code review, architecture decisions, and more. These skills teach any
AI coding agent a disciplined SDLC process, regardless of which harness
or editor you use.

## Quick Start

Install the full skill set:

```bash
npx skills add jwilger/agent-skills
```

Or install individual skills:

```bash
npx skills add jwilger/agent-skills/tdd-cycle
npx skills add jwilger/agent-skills/domain-modeling
npx skills add jwilger/agent-skills/code-review
```

## Skill Inventory

### Tier 0 -- Entry Point

| Skill | Description | Phase |
|-------|-------------|-------|
| `bootstrap` | Zero-config onboarding, harness detection, skill recommendations | -- |

### Tier 1 -- Core Process (universal, standalone)

| Skill | Description | Phase |
|-------|-------------|-------|
| `tdd-cycle` | Red-green-domain TDD cycle with phase boundaries and domain review checkpoints | build |
| `domain-modeling` | Parse-don't-validate, primitive obsession detection, type-driven design | decide |
| `code-review` | Three-stage review protocol: spec compliance, code quality, domain integrity | ship |
| `architecture-decisions` | ADR format, governance, and lightweight decision records | decide |
| `event-modeling` | Discovery, swimlanes, GWT scenarios, model validation | understand |

### Tier 2 -- Orchestration (need some harness support)

| Skill | Description | Phase |
|-------|-------------|-------|
| `orchestration` | Multi-agent delegation patterns, workflow gates, conflict resolution | build |
| `task-management` | Work breakdown, state tracking, dependency management | build |

### Tier 3 -- Utility (universal, standalone)

| Skill | Description | Phase |
|-------|-------------|-------|
| `debugging-protocol` | Systematic 4-phase investigation: root cause before fix | build |
| `user-input-protocol` | Structured pause/resume pattern for agent-to-user questions | build |
| `memory-protocol` | Recall-before-act knowledge accumulation and retrieval | build |

### Advanced (optional)

| Skill | Description | Phase |
|-------|-------------|-------|
| `mutation-testing` | Mutation testing as a test quality gate | ship |
| `atomic-design` | UI component hierarchy (atoms, molecules, organisms) | build |

## Architecture

### Three Tiers

This system separates concerns into three layers:

**Skills** are portable markdown documents (SKILL.md) that teach an agent
*what to do*. They conform to the [Agent Skills specification](https://agentskills.io/specification)
and work on any compatible harness. Skills are advisory -- they instruct
the agent on correct behavior through clear principles and practices.

**Harness Plugins** add *mechanical enforcement* on harnesses that support
it. Hooks that prevent editing the wrong file during the wrong TDD phase,
gates that force domain review between red and green, slash commands that
wire up multi-step workflows. Plugins make the experience better on
specific harnesses but are never required.

**The Enforcement Gap.** Skills cannot mechanically prevent an agent from
violating a practice. They can describe the rules clearly and include
self-verification checklists, but an agent may still rationalize skipping
steps. This is an honest limitation. On harnesses with plugin support
(Claude Code hooks, OpenCode event hooks), enforcement plugins close
this gap. On harnesses without enforcement, the agent follows practices
by convention. If you observe a violation, point it out. Skills are the
constitution; plugins are the police. You benefit from both, but the
constitution works across jurisdictions while the police are local.

### Skill Structure

Every skill follows a canonical template (see `skills/.template/`):

1. **Frontmatter** -- Agent Skills spec metadata plus project extensions
2. **Value** -- Which XP value this skill serves (feedback, communication,
   simplicity, courage, respect)
3. **Purpose** -- What the skill teaches (2-3 sentences)
4. **Practices** -- Concrete, actionable instructions (the main body)
5. **Enforcement Note** -- Honest statement of what the skill can/cannot
   guarantee without harness plugins
6. **Verification** -- Self-check checklist with binary, observable criteria
7. **Dependencies** -- Integration points and install commands for related skills

Token budgets: Core skills stay under 3000 tokens, orchestration skills
under 4000 tokens, bootstrap under 1000 tokens. Detailed reference
material lives in `references/` directories, loaded on demand.

### Cross-Skill Dependencies

Skills declare dependencies in frontmatter (`metadata.requires`). When a
skill activates and finds a dependency missing, it recommends installation
with the specific `npx skills add` command. Dependencies are
recommendations, not hard requirements -- every skill degrades gracefully
when used alone.

The dependency graph is a DAG (no circular dependencies). Skills reference
each other by name but never assume internal structure.

## Harness Plugin Availability

| Harness | Skills | Plugin | Enforcement |
|---------|--------|--------|-------------|
| Claude Code | All 13 | Planned | Hooks, subagents, commands |
| OpenCode | All 13 | Planned | JS/TS modules, event hooks |
| Codex | All 13 | Planned | AGENTS.md, commands |
| Cursor / Windsurf | All 13 | Planned | Rules files |
| Goose | All 13 | Planned | Recipes (YAML) |
| Amp | All 13 | None | MCP only |
| Aider | All 13 | None | No plugin system |

Skills work on every harness in the table. Plugins add ergonomics and
enforcement on harnesses that support them.

## Installing Individual Skills

Each skill is a directory under `skills/`. Install by path:

```bash
# Core process skills
npx skills add jwilger/agent-skills/tdd-cycle
npx skills add jwilger/agent-skills/domain-modeling
npx skills add jwilger/agent-skills/code-review
npx skills add jwilger/agent-skills/architecture-decisions
npx skills add jwilger/agent-skills/event-modeling

# Orchestration skills
npx skills add jwilger/agent-skills/orchestration
npx skills add jwilger/agent-skills/task-management

# Utility skills
npx skills add jwilger/agent-skills/debugging-protocol
npx skills add jwilger/agent-skills/user-input-protocol
npx skills add jwilger/agent-skills/memory-protocol

# Advanced skills
npx skills add jwilger/agent-skills/mutation-testing
npx skills add jwilger/agent-skills/atomic-design
```

## Contributing

### Writing a New Skill

1. Read the canonical template at `skills/.template/SKILL.md.example`
2. Read the frontmatter reference at `skills/.template/FRONTMATTER.md`
3. Follow the section order: Value, Purpose, Practices, Enforcement Note,
   Verification, Dependencies
4. Stay within token budgets (Core 3000, Orchestration 4000)
5. Include an honest Enforcement Note -- do not overstate what the skill
   can guarantee without harness plugins
6. Include a Verification section with binary, observable criteria
7. Keep the SKILL.md body under 500 lines; move detailed examples and
   reference material to `references/`

### Reviewing a Skill

When reviewing skills, check for:

- **Template conformance:** All six body sections present in the correct order
- **Token budget:** Within the tier limit
- **Enforcement honesty:** Does the Enforcement Note accurately describe
  what the skill can and cannot guarantee?
- **Verification quality:** Are the checklist items specific, observable,
  and binary (yes/no)?
- **Standalone usability:** Does the skill provide value when installed
  alone?
- **Security:** Do shell fragments in SKILL.md limit themselves to
  read-only environment detection? No writes, no network calls, no
  package installation.

## License

CC0 1.0 Universal. See [LICENSE](LICENSE).
