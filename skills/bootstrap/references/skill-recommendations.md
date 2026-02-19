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
| `architecture-decisions` | Lightweight ADR governance |
| `domain-modeling` | Parse-don't-validate, type-driven design |

```bash
npx skills add jwilger/agent-skills --skill architecture-decisions --skill domain-modeling
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

## Preset Bundles

Based on the user's answer to "How much process structure?":

**Minimal:**
```bash
npx skills add jwilger/agent-skills --skill tdd --skill domain-modeling
```

**Standard:**
```bash
npx skills add jwilger/agent-skills --skill tdd --skill domain-modeling --skill code-review --skill architecture-decisions --skill debugging-protocol
```

**Full:**
```bash
npx skills add jwilger/agent-skills --all
```

## Install All

```bash
npx skills add jwilger/agent-skills --all
```
