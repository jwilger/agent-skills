# Goose Integration

SDLC workflow integration for [Goose](https://github.com/block/goose),
Block's open-source AI agent.

## What This Provides

Goose supports MCP servers, Recipes (YAML workflow definitions), and
`.goosehints` for project context. This integration uses recipes and
goosehints to guide Goose through structured development workflows.

**No enforcement.** Goose does not have hooks or plugin-level enforcement.
Recipes guide the agent through correct workflows, but cannot mechanically
prevent it from editing the wrong file or skipping a step. The `.goosehints`
file reinforces practices as part of the system prompt.

## Setup

### 1. Copy goosehints to your project

Copy the `.goosehints` file to your project root:

```bash
cp plugins/goose/.goosehints /path/to/your/project/.goosehints
```

Edit it to match your project's specifics (test runner, language, etc.).

### 2. Copy recipes

Copy the recipes you want to use:

```bash
cp -r plugins/goose/recipes/ /path/to/your/project/.goose/recipes/
```

Or reference them directly from this repository.

### 3. Install agent skills

If your Goose setup supports reading skills (via CONTEXT_FILE_NAMES or
MCP), install the skills for deeper guidance:

```bash
npx skills add jwilger/agent-skills/tdd-cycle
npx skills add jwilger/agent-skills/domain-modeling
npx skills add jwilger/agent-skills/code-review
npx skills add jwilger/agent-skills/architecture-decisions
```

## Recipes

### tdd-cycle.yaml

Implements the red/domain/green/domain TDD cycle. Requires a feature name
and acceptance criteria as parameters.

```bash
goose run --recipe recipes/tdd-cycle.yaml
```

The recipe walks Goose through writing one failing test, reviewing it for
domain modeling quality, implementing minimally, and reviewing the
implementation -- repeating for each acceptance criterion.

### event-modeling.yaml

Facilitates an event modeling session. Requires a system name and
description. Walks through brainstorming events, creating timelines,
identifying commands and views, writing GWT scenarios, and validating
the model.

```bash
goose run --recipe recipes/event-modeling.yaml
```

### code-review.yaml

Performs a three-stage code review on a branch: spec compliance, code
quality, and domain integrity. Each stage must pass before the next.

```bash
goose run --recipe recipes/code-review.yaml
```

### pr-workflow.yaml

Creates a pull request with quality gates: test verification, optional
mutation testing, three-stage code review, and PR generation with evidence.

```bash
goose run --recipe recipes/pr-workflow.yaml
```

## How It Works

The `.goosehints` file is loaded at the start of every Goose session and
becomes part of the system prompt. It establishes the TDD workflow, domain
modeling principles, and review expectations as baseline behavior.

Recipes encode specific workflows as parameterized YAML. When you run a
recipe, Goose follows the instructions as a structured task with defined
steps. Recipes can be run interactively or headlessly (with `prompt` field)
for CI/automation.

### Limitations

- **Advisory only.** Goose has no hook system. The agent follows recipe
  instructions by convention, not mechanical enforcement. If you observe
  the agent crossing phase boundaries or skipping domain review, point
  it out.
- **No subagents.** Goose does not have a subagent/delegation model. The
  same agent plays all roles (red, domain, green) sequentially. The recipe
  instructions define the role boundaries.
- **No persistent workflow state.** Goose does not track which TDD phase
  you are in across sessions. The recipe restarts the workflow each time.
  For multi-session features, use the recipe's prompt field to describe
  where you left off.

## Scheduling

Goose supports scheduled recipe execution for automated workflows:

```bash
goose schedule add \
  --schedule-id nightly-review \
  --cron "0 0 21 * * *" \
  --recipe-source recipes/code-review.yaml
```

This is useful for automated code review on active branches.

## Combining with Skills

For the best experience, install the agent skills alongside the Goose
recipes. The `.goosehints` file provides baseline instructions. Skills
provide deeper methodology guidance when activated. Recipes provide
structured task execution.

```
.goosehints     → Baseline behavior (always active)
skills/         → Deep methodology (activated on relevant tasks)
recipes/        → Structured workflows (run explicitly)
```
