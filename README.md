# Agent Skills for Software Development

Portable [Agent Skills](https://agentskills.io) that encode professional
software development practices -- TDD, domain modeling, event modeling,
code review, architecture decisions, and team-based ensemble workflows.
These skills teach any AI coding agent a disciplined SDLC process,
regardless of which harness or editor you use.

**Highlighted capability: Ensemble Team Workflow.** The `ensemble-team`
skill creates a full AI expert team for your project -- with tiered
presets (full/lean/solo-plus), consensus-based planning via Robert's
Rules, ping-pong TDD pairing, mob code review, and built-in
retrospectives. See the skill inventory below.

## Quick Start

1. Install the core skills to get a working TDD cycle:
   ```bash
   npx skills add jwilger/agent-skills --skill tdd --skill domain-modeling
   ```

2. For team-based development, add the ensemble workflow:
   ```bash
   npx skills add jwilger/agent-skills --skill ensemble-team
   ```

3. Or install everything at once:
   ```bash
   npx skills add jwilger/agent-skills --all
   ```

Start with solo mode and the core skills. Scale to pair or full ensemble as
your project grows.

## Skill Inventory

### Tier 0 -- Entry Point

| Skill | Description | Phase |
|-------|-------------|-------|
| `bootstrap` | Zero-config onboarding, harness/capability detection, AGENTS.md generation, skill recommendations | -- |

### Tier 1 -- Core Process (universal, standalone)

| Skill | Description | Phase |
|-------|-------------|-------|
| `tdd` | Adaptive TDD cycle with guided and automated modes; detects harness capabilities and routes to the best execution strategy | build |
| `domain-modeling` | Parse-don't-validate, primitive obsession detection, type-driven design | decide |
| `code-review` | Three-stage review protocol: spec compliance, code quality, domain integrity | ship |
| `architecture-decisions` | ADR format, governance, and lightweight decision records | decide |
| `event-modeling` | Discovery, swimlanes, GWT scenarios, model validation | understand |

### Tier 2 -- Team Workflows (benefit from harness delegation support)

| Skill | Description | Phase |
|-------|-------------|-------|
| `ensemble-team` | Full AI team setup with tiered presets (full/lean/solo-plus), ping-pong TDD pairing, mob review, progressive disclosure, and consensus-based planning | setup |
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

### Skills-Only with Optional Hardening

**Skills** are portable markdown documents (SKILL.md) that teach an agent
*what to do*. They conform to the [Agent Skills specification](https://agentskills.io/specification)
and work on any compatible harness. Skills are the single source of truth
for all practices.

**Enforcement is proportional to capability.** Skills adapt to what the
harness provides. On harnesses with delegation primitives (subagents,
agent teams), the `tdd` skill uses structural enforcement -- context
isolation, handoff schemas, and role specialization. On harnesses without
delegation, the agent follows practices by convention with self-verification
checklists.

**Optional hardening.** On Claude Code, the bootstrap skill can install
hook templates (`skills/tdd/references/hooks/`) that add mechanical
enforcement: pre-tool-use hooks that block unauthorized file edits per
TDD phase, post-tool-use hooks that require pasted test output, and
subagent-stop hooks that enforce mandatory domain review. These are
optional recipes, not a separate plugin layer.

### Skill Structure

Every skill follows a canonical template (see `skills/.template/`):

1. **Frontmatter** -- Agent Skills spec metadata plus project extensions
2. **Value** -- Which XP value this skill serves (feedback, communication,
   simplicity, courage, respect)
3. **Purpose** -- What the skill teaches (2-3 sentences)
4. **Practices** -- Concrete, actionable instructions (the main body)
5. **Enforcement Note** -- Honest statement of what the skill can/cannot
   guarantee at each enforcement level
6. **Verification** -- Self-check checklist with binary, observable criteria
7. **Dependencies** -- Integration points and install commands for related skills

Token budgets: Core skills stay under 3000 tokens, team workflow skills
under 4000 tokens, bootstrap under 1000 tokens. Detailed reference
material lives in `references/` directories, loaded on demand.

### Cross-Skill Dependencies

Skills declare dependencies in frontmatter (`metadata.requires`). When a
skill activates and finds a dependency missing, it recommends installation
with the specific `npx skills add --skill` command. Dependencies are
recommendations, not hard requirements -- every skill degrades gracefully
when used alone.

The dependency graph is a DAG (no circular dependencies). Skills reference
each other by name but never assume internal structure.

## Harness Compatibility

| Harness | Skills | TDD Strategy | Optional Hardening |
|---------|--------|--------------|--------------------|
| Claude Code | All | Agent teams, serial subagents, chaining | Hook templates available |
| Codex | All | Serial subagents, chaining | -- |
| Cursor / Windsurf | All | Chaining, guided | -- |
| OpenCode | All | Chaining, guided | -- |
| Goose | All | Chaining, guided | -- |
| Amp | All | Guided | -- |
| Aider | All | Guided | -- |

Skills work on every harness. The `tdd` skill auto-detects available
delegation primitives and selects the best execution strategy. Optional
hook templates provide mechanical enforcement on Claude Code.

## Installing Individual Skills

Each skill is a directory under `skills/`. Install individually with `--skill`:

```bash
# Core process skills
npx skills add jwilger/agent-skills --skill tdd
npx skills add jwilger/agent-skills --skill domain-modeling
npx skills add jwilger/agent-skills --skill code-review
npx skills add jwilger/agent-skills --skill architecture-decisions
npx skills add jwilger/agent-skills --skill event-modeling

# Team workflow skills
npx skills add jwilger/agent-skills --skill ensemble-team
npx skills add jwilger/agent-skills --skill task-management

# Utility skills
npx skills add jwilger/agent-skills --skill debugging-protocol
npx skills add jwilger/agent-skills --skill user-input-protocol
npx skills add jwilger/agent-skills --skill memory-protocol

# Advanced skills
npx skills add jwilger/agent-skills --skill mutation-testing
npx skills add jwilger/agent-skills --skill atomic-design
```

## Contributing

### Writing a New Skill

1. Read the canonical template at `skills/.template/SKILL.md.example`
2. Read the frontmatter reference at `skills/.template/FRONTMATTER.md`
3. Follow the section order: Value, Purpose, Practices, Enforcement Note,
   Verification, Dependencies
4. Stay within token budgets (Core 3000, Orchestration 4000)
5. Include an honest Enforcement Note -- state what the skill can guarantee
   at each enforcement level (advisory, structural, mechanical)
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

## Migrating from v2.x to v3.0

v3.0 consolidates the skill set and removes the plugin layer.

**Skills renamed or merged:**
- `tdd-cycle` is now `tdd`. The new skill auto-detects harness capabilities
  and supports both guided mode (`/tdd red`, `/tdd green`) and automated
  mode (`/tdd`). Uninstall `tdd-cycle` and install `tdd`.
- `orchestration` is absorbed into `tdd`. Orchestration patterns (serial
  subagents, agent teams, ping-pong pairing) are now execution strategies
  within the `tdd` skill. Uninstall `orchestration`.

**Plugins removed:**
- The `plugins/` directory no longer exists. All enforcement is handled
  by skills directly (structural enforcement via handoff schemas and
  context isolation) or by optional hook templates.
- If you used Claude Code hooks from `plugins/claude-code/hooks/`, the
  equivalent templates are now at `skills/tdd/references/hooks/claude-code-hooks.json`.
  Run `bootstrap` to install them.
- Agent definitions (`plugins/claude-code/agents/`) are replaced by
  prompt templates in `skills/tdd/references/` (`red-prompt.md`,
  `domain-prompt.md`, `green-prompt.md`, `commit-prompt.md`).

**Configuration:**
- `.claude/sdlc.yaml` version is now `"3.0"`. The `bootstrap` skill
  detects outdated configurations and offers to update them.

**Update commands:**
```bash
npx skills remove jwilger/agent-skills --skill tdd-cycle
npx skills remove jwilger/agent-skills --skill orchestration
npx skills add jwilger/agent-skills --skill tdd
```

## License

CC0 1.0 Universal. See [LICENSE](LICENSE).
