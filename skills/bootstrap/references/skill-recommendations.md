# Skill Recommendations by Phase

Present these recommendations grouped by SDLC phase. Show install
commands. Let the user choose which to install.

## Understand (Discovery and Requirements)

| Skill | Description |
|-------|-------------|
| `event-modeling` | Event-driven design, swimlanes, GWT scenarios |

```bash
npx skills add jwilger/agent-skills --skill event-modeling
```

## Decide (Architecture and Domain)

| Skill | Description |
|-------|-------------|
| `design-system` | Collaborative design system specification with tokens and component hierarchy |
| `architecture-decisions` | Lightweight ADR governance |
| `domain-modeling` | Parse-don't-validate, type-driven design |
| `ticket-triage` | Evaluate ticket readiness with actionable feedback |

```bash
npx skills add jwilger/agent-skills --skill design-system --skill architecture-decisions --skill domain-modeling --skill ticket-triage
```

## Build (Implementation)

| Skill | Description |
|-------|-------------|
| `tdd` | Adaptive TDD cycle with guided and automated modes |
| `debugging-protocol` | Systematic 4-phase debugging |
| `user-input-protocol` | Structured pause/resume for agent-to-user questions |

```bash
npx skills add jwilger/agent-skills --skill tdd --skill debugging-protocol --skill user-input-protocol
```

## Ship (Review and Delivery)

| Skill | Description |
|-------|-------------|
| `code-review` | Three-stage review: spec compliance, quality, domain integrity |
| `mutation-testing` | Test quality verification via mutation analysis |

```bash
npx skills add jwilger/agent-skills --skill code-review --skill mutation-testing
```

## Workflow (Coordination)

| Skill | Description |
|-------|-------------|
| `ensemble-team` | AI expert team with tiered presets, ping-pong pairing, mob review |
| `task-management` | Work breakdown, state tracking, dependency management |
| `memory-protocol` | Cross-session knowledge persistence |

```bash
npx skills add jwilger/agent-skills --skill ensemble-team --skill task-management --skill memory-protocol
```

## Factory Pipeline (Autonomous Orchestration)

Recommended as a group when pipeline skill is detected and team workflow or
"Full" process structure is selected. Pipeline requires ci-integration, and
factory-review requires pipeline.

| Skill | Description |
|-------|-------------|
| `pipeline` | Autonomous build-phase orchestrator. Manages slice lifecycle, quality gates, and rework routing. |
| `ci-integration` | Deterministic CI/CD interaction. Runs builds, reads results, manages artifacts. |
| `factory-review` | Human review interface for factory mode. Surfaces audit trail and approval prompts. |

```bash
npx skills add jwilger/agent-skills --skill pipeline --skill ci-integration --skill factory-review
```

**When to recommend:**
- `pipeline` -- Team workflow with CI/CD and desire for reduced human coordination overhead
- `ci-integration` -- Project has a CI/CD pipeline (GitHub Actions, GitLab CI, etc.)
- `factory-review` -- Pipeline is installed (always pair with pipeline)

## Preset Bundles

Based on the user's answer to "How much process structure?":

**Minimal:**
```bash
npx skills add jwilger/agent-skills --skill tdd --skill domain-modeling
```

**Standard:**
```bash
npx skills add jwilger/agent-skills --skill tdd --skill domain-modeling --skill code-review --skill architecture-decisions --skill design-system --skill debugging-protocol --skill ticket-triage
```

**Full:**
```bash
npx skills add jwilger/agent-skills --all
```

## Install All

```bash
npx skills add jwilger/agent-skills --all
```
