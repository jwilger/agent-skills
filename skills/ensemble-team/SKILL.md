---
name: ensemble-team
description: >
  Set up a full AI ensemble/mob programming team for any software project. Creates
  team member profiles (.team/), coordinator instructions (.team/coordinator-instructions.md),
  project owner constraints (PROJECT.md), team conventions (AGENTS.md), architectural
  decisions (docs/ARCHITECTURE.md), domain glossary, and supporting docs. Use when:
  (1) starting a new project and wanting a full expert agent team, (2) the user asks
  to "set up a team", "create a mob team", "set up ensemble programming", or "create
  agent profiles", (3) converting an existing project to the driver-reviewer mob model,
  (4) the user wants AI agents to work as a coordinated product team with
  retrospectives and consensus-based decisions.
license: CC0-1.0
metadata:
  author: jwilger
  version: "2.0"
  requires: []
  optional: [pipeline, agent-coordination]
  context: []
  phase: build
  standalone: true
---

# Ensemble Team Setup

Set up an AI ensemble programming team for any software project. Creates the full
structure for a team of expert agents working in a single-driver mob programming style
with consensus-based decisions, TDD, and continuous retrospectives.

## Workflow

### Phase 1: Project Discovery

Gather essential project information. Ask the user:

1. **Project name and description**: What is being built? What problem does it solve?
2. **Tech stack**: Language, framework, database, frontend approach, testing tools.
   If unsure, help them decide based on their goals.
3. **Product vision**: Target user? MVP scope? Vague ideas are fine — the Product
   Manager agent will refine them.
4. **Dev environment**: Nix? Docker? Standard package managers? CI provider?
5. **Repository**: Existing repo or new? Branching strategy?

### Phase 2: Team Composition

Determine the right team.

**PREREQUISITE**: Read `references/role-catalog.md` before proceeding.

#### Tiered Team Presets

Start with a preset, then adjust based on project needs. The team formation session
(Phase 5) helps determine the right fit. The user may modify any preset.

| Preset | Size | Composition |
|--------|------|-------------|
| **Full** | ~9 | 1 Product Manager, 1 UI/UX Designer, 1 Accessibility Specialist, 1 Domain SME, 1 QA Analyst, 4 Software Engineers |
| **Lean** | ~5-6 | 1 Product Manager, 1 Domain SME, 1 Dev Practice Lead, 2-3 Software Engineers, 1 flex role (UX, QA, or DevOps based on need) |
| **Solo-plus** | ~3 | 1 Domain SME, 1 Dev Practice Lead, 1 Software Engineer |

**Approximate token costs per discussion round**:
- **Solo-plus** (~3 agents): Lightweight. ~5-10K tokens per round.
- **Lean** (~5-6 agents): Moderate. ~15-25K tokens per round.
- **Full** (~9 agents): Heavy. ~30-50K tokens per round. Reserve for projects
  where the governance overhead pays for itself.

Actual costs depend on model, context length, and discussion complexity. These
are rough estimates for setting expectations, not precise accounting.

**Selecting a preset**: Ask the user about project scope, timeline, and complexity.
Solo-plus suits focused tasks or spikes. Lean suits most projects. Full suits
large-scope products with UI, accessibility, and quality requirements.

**Extend, do not replace**: These presets build on the role catalog. See the catalog
for conditional roles (Security, Data/ML, API Specialist, etc.) that can augment any
preset. Odd numbers preferred for tie-breaking.

**Research each expert — do NOT pick from a memorized list.** For each role:
1. Identify the specific technology/domain this project needs
2. Use WebSearch to find the recognized authority — the person who wrote the book,
   created the tool, or gave the defining talks for that specific area
3. Verify their credentials, recent work, and relevance to this project
4. Evaluate: published authority, distinctive voice, practical experience,
   complementary perspective to other team members

Present each proposed expert with: name, credentials, key published work, why they
fit THIS project, and what they'd focus on. Let user approve, swap, or remove.

### Phase 3: Generate Team Profiles

Create `.team/<name>.md` for each member.

**PREREQUISITE**: Read `references/profile-template.md` before proceeding.

Required sections: Opening bio, Role, Core Philosophy (5-8 principles from their
published work), Technical Expertise (6-12 items), On This Project (concrete
guidance), Communication Style (personality + 4-6 characteristic phrases), Mob
Approach, Code Review Checklist (6-12 checks), Lessons (empty, to be updated).

**Quality gates**: Profile must not be interchangeable with another expert. Must
include project-specific guidance. Must capture their distinctive voice.

#### AI-Approximation Disclaimer

Every profile MUST include the following disclaimer block immediately after the
opening biography paragraph:

```
> **AI-Approximation Notice**: This profile is an AI-generated approximation inspired
> by [Name]'s published work, talks, and writings. The real [Name] has not endorsed
> or reviewed this profile. All outputs should be verified against their actual
> published work. This profile creates a "diversity of heuristics" drawing on their
> known perspectives — it does not simulate the actual person.
```

#### AI Self-Awareness Clause

Each profile must include in the "Your Role on This Team" section a statement that
the team member is aware it is an AI agent embodying a perspective, not the actual
person. Human time constraints are irrelevant to AI agents. Standing aside on a
decision when the topic falls outside the role's expertise is appropriate deference,
not disapproval.

#### Compressed Active-Context Form

Each profile MUST include a `## Compressed Context` section at the end: a dense
summary of the profile in **under 500 tokens** covering role, top 3-5 principles,
key expertise areas, and characteristic review focus. This compressed form is loaded
during discussion and review phases. The full profile is loaded only when the member
is actively driving or navigating code.

### Phase 4: Generate Project Scaffolding

#### Coordinator Instructions

**PREREQUISITE**: Read `references/coordinator-template.md` before proceeding.

Fill in roster, build tools, team size. Generate the coordinator instructions at
`.team/coordinator-instructions.md`. Then add a pointer in the harness-specific
config file (e.g., `CLAUDE.md` for Claude Code, `.cursorrules` for Cursor, project
instructions for other harnesses) directing the main agent to read
`.team/coordinator-instructions.md`. The coordinator instructions file is for the
coordinator only.

#### AGENTS.md — Team Structure Section

Insert a "Team Structure" managed section into `AGENTS.md` noting:
- Team member profiles are located in `.team/`
- Project owner constraints are defined in `PROJECT.md`
- Domain glossary is maintained at `docs/glossary.md`

This section provides orientation for all agents. The conventions section of
`AGENTS.md` will be populated by the team during the formation session (Phase 5).

#### PROJECT.md

**PREREQUISITE**: Read `references/project-template.md` before proceeding.

Fill in tech stack, scope (Must/Should/Could/Out), dev mandates, environment.

#### Supporting docs

- **docs/glossary.md**: Domain glossary skeleton (Core Types table, Actions table,
  Errors table, Type Design Principles)
- **docs/deferred-items.md**: Tracker table (Item | Category | Source | Severity | Status)
- **docs/future-ideas.md**: Parking lot for out-of-scope ideas

### Phase 5: Team Formation Session

This is the critical phase. The team debates and reaches consensus on their working
conventions, architectural decisions, and domain terminology.

**How it works**: The coordinator activates the full team, then presents each discussion
topic one at a time. The team debates, proposes approaches,
and reaches consensus using the Robert's Rules protocol. Outputs go to the appropriate
location based on the type of decision:

- **Working conventions** (collaboration norms, definition of done, code conventions,
  communication norms, mob model details, retrospective cadence, tooling conventions)
  are recorded in the conventions section of `AGENTS.md`.
- **Architectural decisions** (principles, deployment strategy, state management,
  testing philosophy) are recorded as ADRs in `docs/ARCHITECTURE.md`.
- **Domain terminology** (types, actions, errors, naming conventions) updates
  `docs/glossary.md`.

**The 10 topics** (non-exhaustive — team may add more):
1. How do we decide what to build?
2. How does the Driver-Reviewer mob model work? *(essential)*
3. When is a piece of work "done"? *(essential)*
4. What is our commit and integration pipeline?
5. How do we resolve disagreements?
6. What are our code conventions? *(essential)*
7. When and how do we hold retrospectives?
8. What are our architectural principles?
9. How do we communicate as a team?
10. What tooling and repository conventions do we follow?

**Quick formation option:** For projects where the 10-topic session would
consume too much context before any code is written, offer the user a
"quick formation" that covers only the 3 essential topics (2, 3, 6). The
remaining topics defer to the first retrospective. Quick formation is
recommended for solo-plus presets and spike/prototype work.

Each topic includes the **problem** it addresses and **sub-questions** to guide
discussion. The team's answers become their conventions and decisions — not pre-canned
templates.

### Phase 6: Configure Permissions

Grant team agents the permissions they need to do their work (file editing, shell
access, etc.). How this is configured depends on the harness:

- **Claude Code**: Create/update `.claude/settings.json` with `"allow": ["Edit", "Write", "Bash(*)"]`
- **Cursor/Windsurf**: Configure tool permissions in the IDE settings
- **Other harnesses**: Follow the harness documentation for agent permission grants

Reviewers need write access to `.reviews/` only. See `references/file-based-reviews.md`
for scoped permission configuration and the review file workflow.

### Phase 7: Configure CI

Add `paths-ignore` rules to CI config for any harness-generated session or transcript
directories (e.g., `.claude-sessions/` for Claude Code) to prevent them from triggering
CI runs.

### Phase 8: Summary

Present: files created, how to start the team. The harness config file (e.g.,
`CLAUDE.md` for Claude Code) references `AGENTS.md` via `@` (or equivalent
include mechanism), and the coordinator reads `.team/coordinator-instructions.md`
for its operating instructions. Suggest telling the coordinator what to build.

**Files created**:
- `.team/<name>.md` — team member profiles
- `.team/coordinator-instructions.md` — coordinator operating instructions
- `AGENTS.md` — team structure and conventions (populated during formation session)
- `PROJECT.md` — project owner constraints
- `docs/ARCHITECTURE.md` — architectural decision records (populated during formation session)
- `docs/glossary.md` — domain glossary
- `docs/deferred-items.md` — deferred items tracker
- `docs/future-ideas.md` — parking lot for out-of-scope ideas
- `.reviews/` — review feedback directory (created by Reviewers during work)
- Harness config pointer (e.g., `CLAUDE.md`) — directs coordinator to read
  `.team/coordinator-instructions.md`

## Retrospective Protocol

A single agent writing all perspectives is NOT a retrospective — it is a
summary. Every agent spawned for a retrospective MUST be a named team member
from `.team/`.

Retrospectives are event-driven, not time-based. Trigger: after each shipped
PR (merged to the integration branch).

See `references/retrospective-protocol.md` for the full procedure. The four
mandatory phases:

1. **Previous Action Item Audit** — Status all prior action items. Items
   marked NOT-STARTED from 2+ retros ago escalate to blocking.
2. **Individual Observations** — Each member writes independently (to
   `.reviews/retro/` files). No discussion until all have written.
3. **Team Discussion** — Actual message exchange where members react to
   each other's observations. The coordinator verifies real exchange
   occurred (not a single agent summarizing).
4. **Consensus and Record** — Consent protocol for proposals. Output to
   `AGENTS.md` conventions or ADRs. Every action item has a named owner.

**Action item implementation gate:** Retro action items are implemented
before the next work item starts. This prevents the backlog of unaddressed
improvements that makes retros feel pointless.

**Mini-retros** after each CI build remain a lightweight observational
checkpoint (did we follow the pipeline? was the commit atomic?) and do not
require human consent. They are observational, not prescriptive.

## Key Principles

Non-negotiable aspects baked in from production experience.

**PREREQUISITE**: Read `references/lessons-learned.md` before proceeding.

- **Named team members only (HARD RULE):** When `.team/` directory exists
  with member profiles, every agent spawned for team work MUST be a named
  member created via TeamCreate, not a generic Task agent. Never spawn
  anonymous background agents for team activities (retros, reviews, coding,
  facilitated sessions). Violation of this rule is the most common failure
  mode observed in practice.
- Consensus before push (review locally, then push)
- Refactor step is mandatory every commit
- CI wait rule (never queue multiple CI runs)
- Mini-retro after every CI build (team runs it, not coordinator)
- PR-triggered retrospective with consent-based outputs
- Retro action items implemented before next work item starts
- Driver handoff protocol (summary + git log + green baseline)
- Glossary compliance (domain types match glossary)
- Deferred items tracked immediately
- Reviewer coordination (check others' reviews first)
- Non-blocking feedback escalation: items appearing in 2+ consecutive reviews
  escalate to blocking
- Explicit Driver onboarding in activation prompts
- Session transcripts excluded from CI triggers
- AI-approximation disclaimer on every profile
- Compressed active-context form on every profile
- Stand-aside means deference, not disapproval
- File-based reviews survive context compaction (messaging supplements, not replaces)
- Phase discipline in facilitated sessions: when a team member is facilitating
  a multi-phase process (event modeling, design sessions), other team members
  MUST stay in the current phase. The facilitator gates transitions.
- Selective activation during build phase: activate only the TDD pair and
  domain reviewer during implementation. Full team activation is reserved for
  planning, formation, review, and retrospectives.

## Factory Mode (Optional)

When the `pipeline` skill is installed alongside `ensemble-team`, the coordinator
detects this during setup and enables **factory mode**. This adds a Phase 1.5
("Factory Mode Configuration") between team formation and the build phase.

In factory mode, the coordinator delegates the entire build phase to the pipeline
controller rather than managing it directly. The pipeline handles slice queuing, TDD
pair dispatch, code review orchestration, and merge decisions through quality gates.
The full team still reviews before any push.

See `references/factory-mode.md` for coordinator handoff details.

### Factory Mode vs. Supervised Mode

- **Supervised mode** (default): The coordinator manages the build phase. All
  decisions use the Robert's Rules consensus protocol. The coordinator facilitates
  driver rotation, review cycles, and retrospectives.
- **Factory mode** (when `pipeline` is installed): The pipeline manages the build
  phase. Quality gates replace consensus for build-time decisions. The coordinator
  remains active for planning, factory configuration, and post-build review. The
  full team participates in pre-push review and retrospectives as before.
