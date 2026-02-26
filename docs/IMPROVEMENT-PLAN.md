# Agent Skills Improvement Plan

> Generated from session log analysis across 6 projects (stochastic_macro,
> bread_log, ace-app, eventcore, claude-code-plugins, agent-skills itself)
> and comprehensive skill review.

## Executive Summary

This plan addresses improvement opportunities identified through analysis of
real-world session logs from projects actively using the agent-skills library.
The improvements follow a tiered approach:

1. **Skill improvements** — fixes and enhancements to existing SKILL.md files
2. **New skills** — gaps identified from session analysis
3. **Plugin marketplace** — advanced Claude Code features that skills alone
   cannot capture (hooks, agents, MCP servers)
4. **Infrastructure** — bump script, version management, testing

---

## Part 1: Skill Improvements

### Priority 0: Orchestrator Role Boundary Enforcement (CRITICAL)

**Problem:** The #1 user intervention across ALL projects is the orchestrator
(pipeline controller or ensemble coordinator) reverting to "doing work itself"
instead of delegating. This happens despite explicit "MUST NOT write code"
instructions. The failure is most severe during crash recovery, rework cycles,
and when fixes seem "trivial."

#### 0A. Delegation Checklist Gate
- **Observation:** 50+ user interventions in bread_log alone correcting this.
- **Fix:** Add a mandatory delegation checklist to `pipeline` and
  `ensemble-team` skills. Before ANY action, the orchestrator must answer:
  "Who am I delegating this to? If the answer is 'myself', STOP."
  This checklist must be part of the self-reminder protocol (re-read every
  5-10 messages).

#### 0B. Named Team Members Only
- **Observation:** Agents spawn anonymous background agents for team work
  (retros, reviews, coding) instead of using named `.team/` members.
- **Fix:** Strengthen the "named team members only" rule in ensemble-team.
  Add: "Never spawn a generic 'background agent' or 'research agent' for
  team activities. Every agent spawned for team work MUST be a named member
  from `.team/`. Generic agents are for non-team tasks only (file search,
  web research)."

#### 0C. File-Based Communication as Default
- **Observation:** Context compaction destroys inter-agent messages. This
  was the root cause of repeated send/re-send loops in bread_log.
- **Fix:** Elevate file-based communication from an ensemble-team pattern
  to a universal principle in `agent-coordination`. Add: "Any substantive
  data exchange between agents (review feedback, handoff evidence,
  retrospective notes, TDD phase evidence) MUST be file-based. Messages
  are coordination signals only ('review ready at .reviews/alice-task.md')."

### Priority 1: TDD Skill Refinements

**Problem:** The TDD skill is the most complex and most frequently invoked skill.
Session logs reveal several recurring failure patterns:

#### 1A. GREEN Phase "Full Implementation" Anti-Pattern
- **Observation:** Agents frequently write the complete implementation in a single
  pass during GREEN, violating the "one error at a time" discipline.
- **Root cause:** The instruction "Make the SMALLEST change" is advisory but the
  temptation to write complete implementations is strong, especially for
  "obvious" solutions.
- **Fix:** Add a concrete heuristic to the GREEN phase instructions:
  "If your change is more than 10 lines, you are almost certainly doing too
  much. Break it into smaller steps." Add an example showing a multi-step
  GREEN progression.

#### 1B. Walking Skeleton Confusion
- **Observation:** Projects often skip or misunderstand the walking skeleton
  requirement. The first slice sometimes implements a complete feature rather
  than the thinnest end-to-end path.
- **Fix:** Add a concrete walking skeleton example to the SKILL.md showing
  what "thinnest end-to-end path" means (e.g., hardcoded response through
  all layers). Add to `references/shared-rules.md`.

#### 1C. Boundary Test Enforcement Gaps
- **Observation:** The outside-in test requirement is well-specified but agents
  struggle to determine what constitutes an "application boundary" in different
  project types (CLI apps, libraries, web APIs, event-sourced systems).
- **Fix:** Add a boundary identification guide to `references/shared-rules.md`
  with examples per project type:
  - Web API: HTTP request/response
  - CLI: Process spawn with args/stdout
  - Library: Public API entry point
  - Event-sourced: Command handler input/event output
  - GUI: Browser/UI automation

#### 1D. Two-Phase Reference Loading
- **Observation:** Agents read strategy-specific reference files BEFORE
  completing capability detection, biasing toward the wrong strategy.
- **Fix:** Add a structural two-phase loading pattern to ALL
  capability-adaptive skills (tdd, pipeline, ensemble-team):
  Phase 1: Detection + routing table (always loaded, small)
  Phase 2: Strategy-specific references (loaded ONLY after detection)
  SKILL.md should list strategy file names ONLY in the routing table,
  never inline in the body text.

#### 1E. Context Loss During Long TDD Sessions
- **Observation:** Multi-cycle TDD sessions lose discipline after context
  compaction. The agent forgets phase rules and starts combining phases.
- **Fix:** Strengthen the self-reminder protocol integration. The TDD
  orchestrator should re-read its strategy file every 3 cycles (not just
  after compaction). Add explicit instruction: "After every COMMIT phase,
  before starting the next RED, re-read your strategy entry-point file."

### Priority 2: Ensemble Team Improvements

#### 2A. Retrospective Quality
- **Observation:** Retrospectives often become single-agent summaries rather
  than genuine multi-agent discussions. The "NOT a retrospective" warning
  exists but is frequently violated.
- **Fix:** Add mechanical enforcement: the retrospective coordinator must
  verify that at least N distinct agents wrote to `.reviews/retro/` files
  before synthesizing. Add a file count check as a hard gate.

#### 2B. Profile Token Bloat
- **Observation:** Team profiles with full bios consume significant context.
  The compressed context section helps but agents often load full profiles
  when compressed would suffice.
- **Fix:** Make the loading strategy explicit: "Always load compressed context
  first. Only load the full profile when the member is actively driving code
  or conducting a detailed review." Add this to coordinator-template.md.

#### 2C. Team Formation Duration
- **Observation:** The 10-topic formation session can take extremely long,
  consuming significant context before any code is written.
- **Fix:** Add a "quick formation" option that covers only topics 2
  (mob model), 3 (definition of done), and 6 (code conventions) as
  essential, with the rest deferred to the first retrospective.

### Priority 3: Pipeline Resilience

#### 3A. Crash Recovery Reliability
- **Observation:** Pipeline controllers frequently lose their place after
  context compaction despite the crash recovery protocol.
- **Fix:** Make the gate checklist (`.factory/audit-trail/slices/<id>/gates.md`)
  the ONLY source of truth for resume. Add instruction: "After any interruption,
  read the gate checklist FIRST. Do not trust your memory of what phase you
  were in."

#### 3B. Rework Loop Detection
- **Observation:** Pipelines sometimes enter rework loops where the same gate
  keeps failing for the same reason without making progress.
- **Fix:** Add rework differentiation: "After each rework attempt, compare the
  new failure message to the previous one. If the failure is identical after
  2 cycles, escalate with full context rather than retrying."

### Priority 4: Debugging Protocol Enhancement

#### 4A. Integration with TDD Cycle
- **Observation:** When a test fails unexpectedly during TDD, agents sometimes
  skip the debugging protocol and jump straight to code changes.
- **Fix:** Add a cross-reference trigger: "When a test fails in GREEN phase
  with an error you did not expect, switch to the debugging protocol's
  Phase 1 before making any code change. The expected failure (from RED) is
  not the same as an unexpected failure."

### Priority 5: Bootstrap Improvements

#### 5A. Detect Existing Configuration
- **Observation:** Re-running bootstrap on a project with existing configuration
  can overwrite previous setup.
- **Fix:** Add detection for existing AGENTS.md, .factory/, CLAUDE.md managed
  sections. Offer to update rather than overwrite. Use managed markers
  consistently.

#### 5B. Skill Installation Guidance
- **Observation:** Bootstrap recommends skills but the user must manually
  install each one. This creates friction.
- **Fix:** After the user confirms their choices, offer to run the install
  commands in sequence. Still require confirmation, but batch the operations.

---

## Part 2: New Skills

### 2A. Error Recovery Skill (Tier 3)
- **Gap:** No skill specifically addresses recovery from unexpected errors
  during autonomous operation (API failures, build tool crashes, file
  permission issues).
- **Scope:** Classify runtime errors into recoverable/unrecoverable,
  provide retry strategies with backoff, maintain error logs, and
  escalate intelligently.

### 2B. Refactoring Skill (Tier 1)
- **Gap:** Refactoring is mentioned as "mandatory" in ensemble-team and
  as a step in TDD, but there's no dedicated skill teaching safe
  refactoring patterns.
- **Scope:** Extract/inline, rename, move, introduce explaining variable,
  replace conditional with polymorphism. Always under green tests.
  Never refactor and add behavior in the same commit.

### 2C. PR/Ship Skill (Tier 1)
- **Gap:** The gap between "code review passes" and "PR is created and
  merged" is not covered by any skill. Includes PR description writing,
  commit squashing decisions, changelog updates.
- **Scope:** PR title/body templates, conventional commits guidance,
  review checklist summary, merge strategy.

---

## Part 3: Plugin Marketplace

### Rationale

Skills are harness-agnostic by design. However, Claude Code offers
capabilities that skills alone cannot leverage:
- **Hooks** for mechanical enforcement of skill rules
- **Custom agents** for specialized subagent roles
- **MCP servers** for external tool integration
- **Default settings** for team-wide configuration

A companion plugin marketplace ships these advanced features while
keeping the core skills portable.

### Architecture

```
agent-skills-plugins/              # Separate repository
├── .claude-plugin/
│   └── marketplace.json           # Marketplace manifest
├── plugins/
│   ├── tdd-enforcement/           # Hooks for TDD phase boundaries
│   │   ├── .claude-plugin/plugin.json
│   │   ├── hooks/hooks.json
│   │   └── scripts/
│   │       ├── check-phase-boundary.sh
│   │       └── verify-test-output.sh
│   ├── pipeline-agents/           # Custom agents for pipeline roles
│   │   ├── .claude-plugin/plugin.json
│   │   └── agents/
│   │       ├── pipeline-controller.md
│   │       ├── tdd-red.md
│   │       ├── tdd-green.md
│   │       └── domain-reviewer.md
│   ├── ensemble-coordinator/      # Coordinator agent + hooks
│   │   ├── .claude-plugin/plugin.json
│   │   ├── agents/
│   │   │   └── ensemble-coordinator.md
│   │   └── hooks/hooks.json
│   └── session-tools/             # Session management utilities
│       ├── .claude-plugin/plugin.json
│       ├── hooks/hooks.json       # SessionStart, PreCompact hooks
│       └── scripts/
│           ├── auto-save-state.sh
│           └── restore-state.sh
└── README.md
```

### Plugin Descriptions

#### tdd-enforcement
- **PreToolUse hooks** that block file edits outside the current TDD phase
  (e.g., cannot edit production code during RED phase)
- **PostToolUse hooks** that verify test output was captured
- **Stop hooks** that verify working tree is clean before session end
- Ships the hook templates currently in `skills/tdd/references/hooks/`

#### pipeline-agents
- Custom agent definitions for pipeline roles with proper constraints
- Each agent has `disallowedTools` to enforce role boundaries
  (e.g., pipeline-controller cannot use Edit/Write tools)
- Leverages Claude Code's `permissionMode` for agents

#### ensemble-coordinator
- Coordinator agent with built-in team protocol
- Hooks for retrospective enforcement (PostToolUse on commit)
- SessionStart hook for automatic state restoration

#### session-tools
- PreCompact hook that auto-saves WORKING_STATE.md
- SessionStart hook that reads memory and restores context
- Stop hook that runs session reflection analysis

### Marketplace Manifest

```json
{
  "name": "agent-skills-plugins",
  "owner": {
    "name": "jwilger",
    "email": "john@johnwilger.com"
  },
  "metadata": {
    "description": "Advanced Claude Code features for the agent-skills library",
    "version": "1.0.0",
    "pluginRoot": "./plugins"
  },
  "plugins": [
    {
      "name": "tdd-enforcement",
      "source": "./plugins/tdd-enforcement",
      "description": "Mechanical enforcement of TDD phase boundaries via hooks",
      "version": "1.0.0",
      "category": "enforcement",
      "tags": ["tdd", "hooks", "enforcement"]
    },
    {
      "name": "pipeline-agents",
      "source": "./plugins/pipeline-agents",
      "description": "Custom agents for factory pipeline roles with tool restrictions",
      "version": "1.0.0",
      "category": "agents",
      "tags": ["pipeline", "agents", "factory"]
    },
    {
      "name": "ensemble-coordinator",
      "source": "./plugins/ensemble-coordinator",
      "description": "Ensemble team coordinator agent with retrospective hooks",
      "version": "1.0.0",
      "category": "agents",
      "tags": ["ensemble", "team", "coordinator"]
    },
    {
      "name": "session-tools",
      "source": "./plugins/session-tools",
      "description": "Session state management hooks for crash recovery",
      "version": "1.0.0",
      "category": "utilities",
      "tags": ["session", "state", "recovery"]
    }
  ]
}
```

---

## Part 4: Infrastructure

### 4A. Bump Script Updates

The bump skill must know about the plugin marketplace. Update
`.claude/skills/bump/bump.sh` to:

1. Update `VERSION` in the main repo (existing behavior)
2. If `plugins/` directory exists with a marketplace.json,
   update `metadata.version` in the marketplace manifest
3. If individual plugin.json files exist, update their versions
4. Report all files updated for staging

### 4B. Skill Token Budget Verification

Add a verification script that counts tokens in each SKILL.md body
and warns when approaching or exceeding tier budgets. This prevents
gradual budget creep.

### 4C. Cross-Skill Consistency Checks

Add a script that verifies:
- All `metadata.requires` references point to existing skills
- No circular dependencies exist
- All skills follow the six-section body structure
- All frontmatter fields match the FRONTMATTER.md spec

---

## Implementation Status

### Completed (v5.1.0)

All Phase 1 and Phase 2 skill improvements have been implemented:

- **Priority 0** — Orchestrator Role Boundary Enforcement:
  - 0A: Delegation Checklist Gate added to `pipeline/SKILL.md`
  - 0B: Named Team Members strengthened in `ensemble-team/SKILL.md` and
    `ensemble-team/references/lessons-learned.md`
  - 0C: File-Based Communication added to `agent-coordination/SKILL.md`
- **Priority 1** — TDD Skill Refinements:
  - 1A: GREEN Phase 10-line heuristic added to `tdd/references/green.md`
  - 1B: Walking skeleton boundary identification guide in `tdd/references/shared-rules.md`
  - 1C: Boundary identification by project type table in `tdd/references/shared-rules.md`
  - 1D: Two-phase reference loading already structured in SKILL.md routing table
  - 1E: Context loss mitigation via event-driven self-reminder triggers in `pipeline/SKILL.md`
  - DOMAIN-to-RED rework path added to `tdd/references/shared-rules.md`
  - Post-phase file-type verification added to `tdd/references/orchestrator.md`
  - Agent identity resolution and spawn context in `tdd/references/ping-pong-pairing.md`
  - Task scope isolation in `tdd/references/ping-pong-pairing.md`
  - Git workflow conventions in subagent prompts (`tdd/references/orchestrator.md`)
- **Priority 2** — Ensemble Team Improvements:
  - 2A: Phase discipline in facilitated sessions (ensemble-team Key Principles)
  - 2B: Selective activation during build phase (ensemble-team Key Principles)
  - Agent respawn after compaction (`ensemble-team/references/lessons-learned.md`)
  - Task agents vs team agents (`ensemble-team/references/lessons-learned.md`)
- **Priority 3** — Pipeline Resilience:
  - 3A: Crash recovery reordered with Step 0 (re-read role constraints first)
  - 3A: Capture surviving agent outputs before killing orphans
  - 3A: Re-spawn agents with full context step added
  - 3A: Compaction-proof invariants in Session Resilience
  - 3A: Ralph Loop / stop-hook awareness
  - 3B: Rework differentiation (identical failures escalate after 2 cycles)
  - Controller patience discipline (while TDD pair active, do NOTHING)
  - Pipeline gate task scoping (controller-only, not in team task list)
- **Priority 4** — Debugging Protocol Enhancement:
  - 4A: TDD integration trigger added
  - Schema/configuration debugging practice added
- **Priority 5** — Bootstrap Improvements:
  - 5A: .gitignore safety verification (Step 7b)
  - AskUserQuestion detection in capability table
- **Cross-cutting improvements:**
  - Patience discipline in `agent-coordination/SKILL.md`
  - Agent identity resolution in `agent-coordination/SKILL.md`
  - ADR PR body requirements in `architecture-decisions/SKILL.md`
  - ADR merge authority (drafter does not self-merge)
  - Harness-native question tool preference in `user-input-protocol/SKILL.md`
  - Multi-agent facilitation guidance in `event-modeling/SKILL.md`
  - Session reflection hard trigger, context budget, continuation summaries
  - Verification items updated across tdd, agent-coordination, architecture-decisions

### Completed (v5.1.0 Phase 2)

All remaining work from the improvement plan has been implemented:

- **Part 1 remaining items:**
  - 2A: Retrospective file count gate in `ensemble-team/references/retrospective-protocol.md`
  - 2B: Profile loading strategy in `ensemble-team/references/coordinator-template.md`
  - 2C: Quick formation option in `ensemble-team/SKILL.md`
  - 5A: Existing config detection in `bootstrap/references/existing-config-detection.md`
  - 5B: Batch skill installation in `bootstrap/references/existing-config-detection.md`

- **Part 2 — New Skills:**
  - `error-recovery` (Tier 3): Error classification, retry strategies, escalation rules
  - `refactoring` (Tier 1): Safe refactoring patterns under green tests
  - `pr-ship` (Tier 1): PR creation, merge workflow, commit hygiene

- **Part 3 — Plugin Marketplace:**
  - Marketplace manifest at `.claude-plugin/marketplace.json`
  - `tdd-enforcement` plugin: PreToolUse/PostToolUse/Stop hooks for TDD phase boundaries
  - `pipeline-agents` plugin: Custom agents for pipeline roles with disallowedTools
  - `ensemble-coordinator` plugin: Coordinator agent with retrospective hooks
  - `session-tools` plugin: SessionStart/PreCompact/Stop hooks for state management

- **Part 4 — Infrastructure:**
  - 4A: Bump script updated for plugin marketplace and individual plugin versions
  - 4B: Token budget verification script (`scripts/verify-token-budgets.sh`)
  - 4C: Cross-skill consistency checks (`scripts/verify-skill-consistency.sh`)
  - Tier tables updated in CLAUDE.md and FRONTMATTER.md
  - Controller boundaries moved to `pipeline/references/controller-boundaries.md`
  - Token budget compliance verified (0 errors across all 23 skills)

---

## Graceful Degradation Strategy

All improvements follow the three-tier degradation model:

| Tier | Target | Capabilities | Example |
|------|--------|-------------|---------|
| **Advanced** | Claude Code | Hooks, agents, MCP, worktrees, teams | TDD phase boundary hooks block unauthorized edits |
| **Standard** | Cursor, Codex, Windsurf, OpenCode | Skills with delegation | Serial subagent TDD with handoff schema enforcement |
| **Basic** | Any agent harness | Advisory skills only | Chaining mode TDD with self-enforcement by convention |

Plugins are Claude Code-only by design. Skills remain universal.
Every improvement to a skill must work in advisory mode on any harness.
Plugin features add mechanical enforcement on top of advisory guidance.

---

## Session Log Findings

### From agent-skills meta-analysis (15 sessions, v1.x through v5.0)

#### Owner Philosophy (Confirmed Priorities)

1. **"Lights-out software factory" vision** — Human plans, agents build
   autonomously, human reviews artifacts. Pipeline skill is the centerpiece.
2. **Skills as single source of truth** — The v3.0 restructure (Feb 2026)
   deliberately collapsed 18 specialized agents and plugin duplication into
   skills-only. Plugins should not duplicate skill content.
3. **Enforcement proportional to capability** — Skills honestly state
   enforcement levels. Hooks add mechanical enforcement on top.
4. **Convention over precedent** — Written conventions override observed
   code patterns. Existing non-conforming code is tech debt.

#### Top Failure Modes (Ranked by Frequency)

1. **Orchestrator reverts to doing work itself** — The #1 user intervention
   across ALL projects. Pipeline controllers and coordinators write code
   directly instead of delegating. "Use the fucking team" appears multiple
   times in bread_log sessions. This is the single highest-priority fix.

2. **Generic subagents used instead of named team members** — Agents spawn
   anonymous background agents for team work (retros, reviews) instead of
   using named `.team/` members. Violates the ensemble-team principle.

3. **Retrospectives confused with code review** — Agents produce refactoring
   suggestions during retros instead of process improvements. Process
   observations vs. code quality suggestions are distinct.

4. **Context compaction destroys inter-agent messages** — Led to file-based
   review pattern. This should be elevated to a universal principle.

5. **Wrong TDD strategy selected** — Agent reads wrong reference files
   before completing capability detection, then locks into wrong strategy.

6. **Boundary tests not enforced structurally** — Domain-layer unit tests
   pass TDD gates that should require boundary-level acceptance tests.

7. **Pre-implementation context skipped** — Agents start TDD without reading
   architecture docs, glossary, event model, or design system.

#### What Skills CAN'T Do (Plugin Motivation)

| Enforcement Gap | Skills Reliability | With Hooks |
|-----------------|-------------------|------------|
| File-type boundary enforcement | ~90% | ~100% |
| Domain review gates | ~80% | ~100% |
| Git attribution hygiene | ~60% | ~100% |
| Post-edit test execution | ~90% | ~100% |
| Named agent role restrictions | Impossible | Full support |
| Lifecycle event handling | Impossible | Full support |
| MCP server configuration | Impossible | Full support |

### From bread_log analysis (30 sessions, 16 analyzed)

**Top failure modes (ranked by user frustration signals):**

1. **Generic Task agents instead of named team members** (5 sessions) —
   The single most repeated frustration. Users corrected with explicit
   profanity multiple times. **ADDRESSED:** Delegation Checklist and
   Named Team Members hard rule.
2. **Controller writes code after compaction** (3 sessions) — Role
   boundaries lost after context continuation. 60MB session showed
   controller editing `.rs` files directly after 5th continuation.
   **ADDRESSED:** Compaction-proof invariants and Step 0 in crash recovery.
3. **Controller interrupts working agents** (4 sessions) — Impatient
   polling, status narration, file reads while agents work.
   **ADDRESSED:** Patience Is Non-Negotiable section.
4. **TDD pair agents pick up pipeline gate tasks** — Pair agents found
   pipeline tasks in task list and worked them. **ADDRESSED:** Pipeline
   gate task scoping.
5. **Agent name mismatch breaks handoffs** — Case-sensitive names
   silently fail. **ADDRESSED:** Agent Identity Resolution practice.
6. **GREEN phase writes full implementation** — Not following iterative
   discipline. **ADDRESSED:** 10-line heuristic and verification items.
7. **Ralph loop causes controller thrashing** — Stop hook re-injection
   triggers unnecessary actions. **ADDRESSED:** Ralph Loop awareness in
   Session Resilience.

**Key statistic:** 40+ user frustration signals including 8 with explicit
profanity across 16 sessions analyzed.

### From ace/ace-app analysis (12 sessions)

**Top findings:**

1. **Context compaction recovery is catastrophically expensive** — 9
   compactions in the primary build session, each triggering multi-minute
   recovery. Fresh agents violated TDD phase boundaries immediately.
   **ADDRESSED:** Agent respawn with full context guidance.
2. **AskUserQuestion tool consistently forgotten** — User corrected at
   least twice per session. **ADDRESSED:** Capability detection in
   bootstrap, native tool preference in user-input-protocol.
3. **Acceptance test boundary enforcement too weak** — TDD pair called
   internal functions directly instead of testing through the boundary.
   **ADDRESSED:** Boundary identification table and walking skeleton
   verification item.
4. **Event modeling: solo authoring vs facilitation** — Facilitator
   authored model alone instead of collecting contributions. **ADDRESSED:**
   Multi-agent facilitation guidance in event-modeling.
5. **Session reflection should trigger more automatically** — User had
   to invoke after 10+ corrections. **ADDRESSED:** Hard trigger requirement.

### From eventcore + claude-code-plugins analysis (85 sessions)

**Top findings:**

1. **GREEN phase boundary violation** — GREEN subagent edited test files
   in eventcore TDD session. **ADDRESSED:** Hard boundary in green.md
   and post-phase verification in orchestrator.md.
2. **ARCHITECTURE.md vs ADR content confusion** — Agents put ADR rationale
   in ARCHITECTURE.md instead of PR descriptions. User: "the whole ADR
   process is fucked." **ADDRESSED:** Strengthened ARCHITECTURE.md
   description and PR body requirements.
3. **Agent produces roadmaps instead of doing work** — 3 escalating
   corrections in one session. This is a behavioral anti-pattern addressed
   by the session-reflection hard trigger.
4. **Version strings inconsistent across files** — Hardcoded versions
   drift after bumps. Flagged for future infrastructure work (4B).
5. **Subagents lack repository conventions** — Sub-agents didn't inherit
   no-Co-Authored-By, squash-merge, or commit format. **ADDRESSED:** Git
   workflow conventions in subagent prompts.
6. **Bootstrap creates .gitignore conflicts** — Broad patterns accidentally
   match skill directories. **ADDRESSED:** Step 7b .gitignore verification.

### Cross-Project Patterns

| Pattern | Frequency | Status |
|---------|-----------|--------|
| Orchestrator writes code | 5+ projects | ADDRESSED |
| Generic agents instead of team | 5+ projects | ADDRESSED |
| Context compaction destroys state | All projects | ADDRESSED |
| GREEN phase full implementation | 3 projects | ADDRESSED |
| Controller impatience / polling | 3 projects | ADDRESSED |
| Boundary test not at boundary | 2 projects | ADDRESSED |
| ADR content in wrong location | 2 projects | ADDRESSED |
| Agent name mismatch | 2 projects | ADDRESSED |
| Skill decay over time | All projects | PARTIALLY ADDRESSED (event-driven reminders) |
| Version string drift | 1 project | FUTURE (infrastructure) |
