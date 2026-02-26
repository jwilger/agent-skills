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
| `ticket-triage` | Evaluate ticket readiness against six criteria with actionable remediation guidance | plan |
| `design-system` | Design token definitions, component catalog, and visual consistency specification | decide |
| `refactoring` | Safe refactoring patterns under green tests: extract, inline, rename, move, simplify | build |
| `pr-ship` | PR creation, commit hygiene, merge strategy, and post-merge workflow | ship |

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
| `agent-coordination` | File-based communication, patience discipline, agent identity resolution for multi-agent workflows | build |
| `session-reflection` | Structured session analysis with hard triggers, context budgets, and continuation summaries | build |
| `error-recovery` | Error classification, retry strategies with backoff, escalation rules for autonomous operation | build |

### Tier 4 -- Factory Pipeline (requires pipeline orchestrator)

| Skill | Description | Phase |
|-------|-------------|-------|
| `pipeline` | Three-phase factory pipeline orchestrator: plan → build → review. Boundary-enforced TDD gates, enriched slice context, git worktree isolation | all |
| `ci-integration` | Quality gate definitions and CI adapter for automated pass/fail decisions | ship |
| `factory-review` | Structured human review protocol for factory output with audit trail | review |

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

## Setup by Harness

All skills work on every harness. The `tdd` skill auto-detects available
delegation primitives and selects the best execution strategy automatically.
What differs is the *level of enforcement* and the available *execution
strategies*. Choose your harness below for specific setup guidance.

### Claude Code (Full Capability)

Claude Code provides the richest experience: agent teams, serial subagents,
hooks for mechanical enforcement, and parallel pipeline execution.

**Install skills:**
```bash
npx skills add jwilger/agent-skills --all
```

**Run bootstrap** to detect capabilities and configure your project:
```
/bootstrap
```

Bootstrap will detect Claude Code's full tool set (TeamCreate, Task,
AskUserQuestion) and recommend automated TDD mode with agent teams.

**Optional: Install plugins for mechanical enforcement.**
Plugins add hooks and custom agents on top of the advisory guidance that
skills provide. Each plugin auto-installs its required skills on session
start — you don't need to install skills separately when using plugins.

To use a plugin, point Claude Code at the plugin directory:
```bash
claude --plugin-dir ./plugins/tdd-enforcement
```

Or install multiple plugins:
```bash
claude --plugin-dir ./plugins/tdd-enforcement \
       --plugin-dir ./plugins/pipeline-agents \
       --plugin-dir ./plugins/session-tools
```

**What you get:**
- TDD via persistent ping-pong pair teams (agent teams strategy)
- Factory pipeline with parallel slice execution in git worktrees
- Optional hook-based phase boundary enforcement (blocks unauthorized edits)
- Custom agents with `disallowedTools` for role boundary enforcement
- Session state auto-save/restore across context compactions

### Codex

Codex supports subagent spawning, giving you isolated per-phase TDD agents.

**Install skills:**
```bash
npx skills add jwilger/agent-skills --all
```

**Run bootstrap** in your Codex session. It will detect the Task tool and
recommend automated TDD mode with serial subagents.

**What you get:**
- TDD via serial subagents (each phase runs in an isolated agent)
- Structural enforcement via handoff schemas (missing evidence blocks
  the next phase)
- Factory pipeline in serial execution mode
- No plugins (Codex does not support Claude Code plugins)

### Cursor / Windsurf

These editors support skill loading but not agent delegation primitives.

**Install skills:**
```bash
npx skills add jwilger/agent-skills --all
```

For Cursor, skills are loaded from `.cursor/rules/`. For Windsurf, check
your editor's agent skill configuration. Bootstrap will detect the
harness type and generate the appropriate instruction files.

**Run bootstrap** in your editor's agent chat. It will detect chaining
mode and recommend either automated (chaining) or guided TDD.

**What you get:**
- TDD via chaining (agent plays each role sequentially in one context)
- Advisory enforcement (agent self-enforces phase boundaries by convention)
- Factory pipeline in chaining mode (quality gates still enforce, but no
  isolated subagents)
- Self-verification checklists at each phase transition

**Tip:** Use guided TDD mode (`/tdd red`, `/tdd green`, etc.) if you want
explicit control over phase transitions. The agent will load phase-specific
reference files and guide you through each step.

### OpenCode / Goose

These harnesses support skill loading with basic agent capabilities.

**Install skills:**
```bash
npx skills add jwilger/agent-skills --all
```

**Run bootstrap.** It will detect available capabilities and configure
accordingly (typically chaining or guided mode).

**What you get:**
- TDD in chaining or guided mode
- Advisory enforcement only
- Factory pipeline in degraded mode (advisory gates -- the agent checks
  quality but cannot structurally prevent violations)
- All skills provide value as advisory guidance

### Amp / Aider / Other Harnesses

Any harness that supports the [Agent Skills specification](https://agentskills.io/specification)
can use these skills.

**Install skills:**
```bash
npx skills add jwilger/agent-skills --all
```

**Run bootstrap** if your harness supports it, or manually load skills
by referencing the SKILL.md files.

**What you get:**
- TDD in guided mode (`/tdd red`, `/tdd green`, `/tdd domain`, `/tdd commit`)
- Advisory enforcement (practices by convention, self-check checklists)
- Factory pipeline in advisory mode
- Full value from all skill content -- the practices, checklists, and
  domain modeling guidance work regardless of enforcement level

### Capability Summary

| Harness | TDD Strategy | Pipeline Mode | Enforcement Level |
|---------|-------------|---------------|-------------------|
| Claude Code | Agent teams | Full (parallel worktrees) | Mechanical (hooks) + Structural + Advisory |
| Codex | Serial subagents | Serial | Structural (handoff schemas) + Advisory |
| Cursor / Windsurf | Chaining | Chaining | Advisory (self-enforcement) |
| OpenCode / Goose | Chaining / Guided | Advisory gates | Advisory |
| Amp / Aider | Guided | Advisory gates | Advisory |

## Factory Pipeline (v4.0+)

v4.0 introduces a factory pipeline that automates the build-and-ship
phases while keeping humans in control of planning and review.

v4.1 adds four improvements to the pipeline:

- **Boundary-level acceptance test enforcement.** The TDD gate now
  requires acceptance tests to exercise an external boundary (HTTP, CLI,
  message queue, websocket, Playwright UI, or manual verification).
  Tests that only call internal functions are rejected. CYCLE_COMPLETE
  evidence includes `boundary_type` and `boundary_evidence` fields.
- **Pre-implementation context checklist.** Before dispatching a TDD
  pair, the pipeline gathers architecture docs, glossary, domain types,
  and event model context. This is passed as `project_references` and
  `slice_context` to the TDD orchestrator.
- **Enriched slice context.** Each slice now carries a `context` block
  with boundary annotations on GWT scenarios, event model source path,
  related slices, domain types referenced, and UI components referenced.
- **Git worktree isolation for parallel slices.** At full autonomy,
  parallel slices execute in isolated git worktrees at
  `.factory/worktrees/<slice-id>`. Falls back to sequential execution
  when `git worktree` is unavailable. Conflicts are detected at merge
  time rather than predicted up front.

See `skills/pipeline/SKILL.md` and `skills/tdd/SKILL.md` for full
details.

### Three-Phase Workflow

1. **Human-driven (understand + decide).** The human defines what to build
   -- requirements, acceptance criteria, architecture decisions. The AI team
   helps with event modeling, domain modeling, and planning, but the human
   approves the plan.

2. **Agent-autonomous (build + ship).** The pipeline executes the approved
   plan without blocking on human input. Quality gates (tests, mutation
   score, CI status) replace human approval gates. Decisions are classified
   as gate-resolvable, judgment-required (batched for review), or blocking
   (pipeline halts). The full TDD cycle, code review, and CI integration
   run autonomously.

3. **Human review (inspect + tune).** The human reviews shipped work,
   batched decisions, and the audit trail. Feedback flows back into the
   next planning cycle.

### Progressive Autonomy

The pipeline supports three autonomy levels:

- **Conservative:** Agent proposes, human approves each vertical slice
  before build begins. Rework requires human sign-off.
- **Standard:** Agent builds autonomously. Human reviews at the end of
  each batch. Rework is autonomous up to 2 cycles per gate.
- **Full:** Agent selects pairs, orders slices, and optimizes based on
  factory memory. Human reviews completed batches only.

### Audit Trail

All pipeline activity is recorded in `.factory/` for full traceability:
build logs, gate results, decision classifications, rework history, and
factory memory. The human can inspect any part of the trail during review.

### Backward Compatibility

All existing skills continue to work standalone without the pipeline.
The factory pipeline is an optional orchestration layer -- it composes
existing skills (`tdd`, `code-review`, `mutation-testing`, etc.) into an
automated workflow. Projects that do not install the pipeline skills see
no change in behavior.

### Using the Factory Pipeline

#### Prerequisites

You need:
- An ensemble team already set up (`ensemble-team` skill, Phase 1-5 complete)
- Vertical slices defined (from event modeling with GWT scenarios)
- A CI/CD pipeline configured for your project
- The three factory skills installed: `pipeline`, `ci-integration`, `factory-review`

Install the factory skills alongside your existing setup:

```bash
npx skills add jwilger/agent-skills \
  --skill pipeline \
  --skill ci-integration \
  --skill factory-review \
  --skill mutation-testing
```

Then re-run `bootstrap` to detect factory mode and choose an autonomy level.
This generates `.factory/config.yaml` with your settings.

#### Typical Session

1. **Plan (human + team):** You describe what to build. The coordinator
   facilitates event modeling, domain modeling, and vertical slice definition
   using the full Robert's Rules protocol. This is the same planning phase
   as supervised mode -- nothing changes here.

2. **Configure and hand off:** The team agrees on autonomy level and gate
   thresholds (a Standard-category decision). The coordinator hands the
   slice queue, team roster, and config to the pipeline controller.

3. **Build (autonomous):** The pipeline takes each slice through:
   decompose → TDD pair implements → full-team code review → address
   feedback → mutation test → push + CI → merge or escalate. No human
   input required unless a gate fails 3 times or a blocking concern is raised.

4. **Review (human):** When the pipeline finishes (or when you check in),
   invoke the `factory-review` skill. It shows: slices completed, rework
   rate, gate failures, pending escalations, and quality trends. You can
   adjust `.factory/config.yaml` (e.g., promote from conservative to
   standard) and the team runs a retrospective.

#### Harness-Specific Guidance

The pipeline adapts to what your harness can do. The core workflow is
identical everywhere -- only the execution mechanism changes.

**Claude Code** (full capability):
- Pipeline uses agent teams for TDD pairs (persistent ping-pong sessions)
- Background agents for CI monitoring
- Full parallel slice execution at the `full` autonomy level using git
  worktree isolation (one worktree per active slice)
- Pre-implementation context gathering (architecture docs, glossary,
  domain types, event model) passed to every TDD pair
- Hook templates available for mechanical enforcement of phase boundaries
- Recommended: start here if you have a choice of harness

**Codex**:
- Pipeline uses serial subagents for TDD phases (no persistent pair sessions)
- Each TDD phase runs in an isolated subagent with constrained scope
- No parallel slices (single-threaded execution)
- All quality gates and audit trail features work identically

**Cursor / Windsurf**:
- Pipeline operates in chaining mode (single context, sequential phases)
- The agent plays driver and navigator roles sequentially within one context
- Quality gates still enforce: tests must pass, review must complete,
  mutation score must hit 100% on changed files
- No mechanical enforcement (advisory only) -- the agent follows practices
  by convention
- Longer context windows recommended (the full pipeline consumes more
  context than individual skills)

**Other harnesses (OpenCode, Goose, Amp, Aider)**:
- Chaining or guided mode depending on harness capability
- Factory mode degrades gracefully: quality gate *checks* still run (the
  agent verifies tests pass, reviews code, runs mutation testing) but the
  structural enforcement (isolated subagents, persistent pairs) is not
  available
- The audit trail still works -- `.factory/` files are written regardless
  of harness
- Guided TDD mode (`/tdd red`, `/tdd green`) works within the pipeline
  the same way it works standalone

#### Autonomy Levels in Practice

Start conservative and promote as you build confidence:

| Level | When to use | What the pipeline does autonomously |
|-------|-------------|-------------------------------------|
| **Conservative** | First 2-3 slices, new domain, new team | Runs gates, reports every result. You approve every merge and every rework attempt. |
| **Standard** | After verifying gate quality on a few slices | Auto-reworks within budget, batches non-blocking findings, auto-retries infra CI failures. You approve merges. |
| **Full** | 5+ clean slices at standard, stable CI | Auto-merges when all gates pass, runs slices in parallel in git worktrees (Claude Code only), optimizes pair selection from factory memory. You review batches. |

Change the level at any time by editing `.factory/config.yaml`. The change
takes effect on the next slice. The pipeline never auto-promotes -- level
changes are always your decision.

#### What to Do When Things Go Wrong

- **Gate fails once or twice:** The pipeline auto-reworks (at standard/full).
  The TDD pair gets the failure details and tries again. You don't need to
  intervene.
- **Gate fails 3 times:** The pipeline halts that slice and escalates to you
  with full context: what failed, what was tried, all evidence from all
  attempts. You decide whether to fix it yourself, adjust the approach, or
  skip the slice.
- **Blocking concern during review:** A team member flags a security issue
  or domain integrity problem. The pipeline halts immediately. You see the
  concern in the next `factory-review` summary.
- **CI infra failure:** At standard/full, the pipeline retries once
  automatically. After 2 failures, it escalates.

## Plugin Marketplace (Claude Code Only)

Skills are harness-agnostic by design. For Claude Code users who want
mechanical enforcement beyond what advisory skills provide, a companion
plugin marketplace offers hooks, custom agents, and session management
tools.

| Plugin | What it adds |
|--------|-------------|
| `tdd-enforcement` | PreToolUse hooks that block file edits outside the current TDD phase; PostToolUse hooks requiring test evidence; Stop hooks verifying clean working tree |
| `pipeline-agents` | Custom agent definitions for pipeline roles (controller, TDD-red, TDD-green, domain-reviewer) with `disallowedTools` enforcing role boundaries |
| `ensemble-coordinator` | Coordinator agent with retrospective enforcement hooks |
| `session-tools` | PreCompact auto-save, SessionStart context restore, Stop session reflection |

Plugins live in the `plugins/` directory with a marketplace manifest at
`.claude-plugin/marketplace.json`.

**Automatic skill installation:** Each plugin includes a `SessionStart`
hook that checks for its required skills on every session start. If any
skills are missing, the plugin auto-installs them via `npx skills add`.
You do not need to install skills manually when using a plugin — the
plugin handles it.

**Without plugins (all other harnesses):** Install skills manually via
`npx skills add`. Skills check for dependencies at activation time and
recommend installation commands for any missing dependencies, but cannot
auto-install on harnesses without hook support.

## Installing Individual Skills

Each skill is a directory under `skills/`. Install individually with `--skill`:

```bash
# Core process skills
npx skills add jwilger/agent-skills --skill tdd
npx skills add jwilger/agent-skills --skill domain-modeling
npx skills add jwilger/agent-skills --skill code-review
npx skills add jwilger/agent-skills --skill architecture-decisions
npx skills add jwilger/agent-skills --skill event-modeling
npx skills add jwilger/agent-skills --skill ticket-triage
npx skills add jwilger/agent-skills --skill design-system
npx skills add jwilger/agent-skills --skill refactoring
npx skills add jwilger/agent-skills --skill pr-ship

# Team workflow skills
npx skills add jwilger/agent-skills --skill ensemble-team
npx skills add jwilger/agent-skills --skill task-management

# Utility skills
npx skills add jwilger/agent-skills --skill debugging-protocol
npx skills add jwilger/agent-skills --skill user-input-protocol
npx skills add jwilger/agent-skills --skill memory-protocol
npx skills add jwilger/agent-skills --skill agent-coordination
npx skills add jwilger/agent-skills --skill session-reflection
npx skills add jwilger/agent-skills --skill error-recovery

# Factory pipeline skills
npx skills add jwilger/agent-skills --skill pipeline
npx skills add jwilger/agent-skills --skill ci-integration
npx skills add jwilger/agent-skills --skill factory-review

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

## Migrating from v5.0 to v5.1

v5.1 adds front-end enforcement, design system compliance, new skills,
and a companion plugin marketplace. All changes are additive.

**New skills (install if needed):**

```bash
npx skills add jwilger/agent-skills \
  --skill refactoring \
  --skill pr-ship \
  --skill error-recovery
```

**Front-end and design system enforcement (automatic with skill update):**

- Event modeling now requires wireframe-to-component mapping (Step 4) and
  UI component inventory in slice definitions (Step 9). Slices that specify
  backend behavior without specifying UI components are flagged as incomplete.
- TDD boundary validation now requires `boundary_type: "Browser"` for web
  app slices with `ui_components_referenced`. HTTP-only tests are rejected.
- Design system context is now mandatory (not conditional) for UI slices in
  the TDD pre-implementation checklist. The TDD pair must verify design
  token compliance during DOMAIN review.
- The review gate (Gate 2) now checks for hard-coded color/spacing/sizing
  values and verifies component names match the design system catalog.

**Plugin marketplace (Claude Code only, optional):**

Four companion plugins are available in `plugins/` for mechanical enforcement
on Claude Code: `tdd-enforcement`, `pipeline-agents`, `ensemble-coordinator`,
and `session-tools`. These are optional — skills continue to work without them.

**Other improvements:**

- Delegation checklist gate for pipeline and ensemble-team orchestrators
- Named-team-only rule (no anonymous agents for team work)
- File-based communication as universal principle in agent-coordination
- GREEN phase 10-line heuristic and iterative evidence requirement
- Crash recovery reliability (gate checklist as single source of truth)
- Rework loop detection (identical failures escalate after 2 cycles)
- Quick formation option for ensemble-team (3 essential topics)
- Token budget and cross-skill consistency verification scripts

**Update commands:**

```bash
npx skills add jwilger/agent-skills --all
```

## Migrating from v4.0 to v4.1

v4.1 strengthens the pipeline with boundary enforcement, enriched slice
context, pre-implementation context gathering, and git worktree
isolation. All changes are additive -- existing standalone skill usage is
unaffected.

**Slice queue changes (required if using the pipeline):**

Slices now require a `context` block with at least one GWT scenario that
has a `boundary` field. Enqueue validation rejects slices missing this.
Update existing entries in `.factory/slice-queue.json` to include the
context block. See `skills/pipeline/references/slice-queue.md` for the
schema.

**Project references configuration (recommended):**

Add a `project_references` section to `.factory/config.yaml` with paths
to your architecture doc, glossary, design system catalog, and event
model root. The pipeline gathers this context before dispatching each
TDD pair. Without it, the pipeline still runs but pairs start without
pre-loaded project context.

```yaml
# .factory/config.yaml (add this section)
project_references:
  architecture_doc: docs/architecture.md
  glossary: docs/glossary.md
  design_system_catalog: docs/design-system.md
  event_model_root: docs/event-model/
```

**CYCLE_COMPLETE evidence schema change:**

In pipeline mode, acceptance tests now require `boundary_type` (one of:
http, cli, message_queue, websocket, playwright_ui, manual) and
`boundary_evidence` (description of what boundary is exercised) in the
CYCLE_COMPLETE evidence packet. The TDD gate rejects evidence where the
acceptance test calls internal functions directly. See
`skills/tdd/references/cycle-evidence.md` for the full schema.

**Git worktree isolation (automatic, full autonomy only):**

If running at full autonomy with parallel slices, the pipeline now uses
git worktrees at `.factory/worktrees/<slice-id>` instead of file-conflict
prediction. The directory is created automatically. If `git worktree` is
not available, the pipeline falls back to sequential execution. No
configuration needed.

**Update commands:**

```bash
# Update all skills to v4.1
npx skills add jwilger/agent-skills --all

# Re-run bootstrap to pick up new config options
# (invoke /bootstrap in your agent session)
```

## Migrating from v3.x to v4.0

v4.0 adds the factory pipeline. No existing skills are renamed, removed,
or changed in a breaking way. If you don't install the pipeline skills,
your project works exactly as before.

**New skills to install (optional):**

```bash
npx skills add jwilger/agent-skills \
  --skill pipeline \
  --skill ci-integration \
  --skill factory-review
```

**What changed in existing skills:**

All changes are additive. New sections are only active when the `pipeline`
skill is detected:

- `tdd`: Produces CYCLE_COMPLETE evidence packets when running in pipeline
  mode. No change in standalone behavior.
- `code-review`: Produces REVIEW_RESULT evidence packets. Adds factory mode
  review (full team reviews before push). No change in standalone behavior.
- `mutation-testing`: Produces MUTATION_RESULT evidence packets. Adds
  pipeline mode where failures auto-route to the TDD pair. No change in
  standalone behavior.
- `task-management`: Adds slice-to-task decomposition for vertical slices
  with GWT scenarios. Adds pipeline tracking metadata. No change in
  standalone behavior.
- `ensemble-team`: Detects pipeline skill and enables factory mode. Adds
  Phase 1.5 (factory configuration) and factory mode coordinator
  instructions. In supervised mode (no pipeline), behavior is identical to
  v3.x.
- `bootstrap`: Detects pipeline skill and offers autonomy level question.
  Generates `.factory/config.yaml`. Without the pipeline skill, bootstrap
  behaves identically to v3.x.
- `user-input-protocol`: Adds batch mode for factory (decisions classified
  as gate-resolvable, judgment-required, or blocking). Adds urgency field.
  No change in standalone behavior.
- `memory-protocol`: Adds factory memory practice (`.factory/memory/`).
  No change in standalone behavior.

**New files in your project (only when factory mode is active):**

```
.factory/
  config.yaml                    # Autonomy levels, gate thresholds, project references
  slice-queue.json               # Vertical slice queue state
  memory/                        # Operational learnings
  audit-trail/                   # Full evidence trail for every slice
  worktrees/                     # Git worktrees for parallel slices (full autonomy)
```

**If you already have an ensemble team set up:**

Re-run `bootstrap` to detect factory mode. Then re-run the team formation
session (Phase 5 of `ensemble-team`) to discuss Topic #11: "What is our
autonomy and oversight model?" This is the team's chance to agree on
autonomy level, rework budgets, and review cadence before the pipeline
takes over the build phase.

**Update commands:**

```bash
# Update all skills to v4.0
npx skills add jwilger/agent-skills --all

# Or add just the factory skills to an existing setup
npx skills add jwilger/agent-skills \
  --skill pipeline \
  --skill ci-integration \
  --skill factory-review

# Re-run bootstrap to detect factory mode
# (invoke /bootstrap in your agent session)
```

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
