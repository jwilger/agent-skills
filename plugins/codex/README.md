# SDLC Skills for Codex

Integrates the SDLC skills workflow with OpenAI Codex.

## What Codex Supports

Codex reads `AGENTS.md` files scoped to directory trees and follows their
instructions when modifying files. It also supports Agent Skills (SKILL.md)
and MCP servers. It has no hooks or enforcement plugins.

This means SDLC practices are advisory -- Codex follows them by convention
based on the instructions in `AGENTS.md` and any installed skills. There is
no mechanical enforcement preventing phase violations.

## Setup

### 1. Install Skills

```bash
npx skills add jwilger/agent-skills
```

This installs all SDLC skills. Codex loads skill metadata at startup and
activates relevant skills based on task context.

### 2. Copy AGENTS.md to Your Project

Copy the `AGENTS.md` file from this directory to your project root:

```bash
cp AGENTS.md /path/to/your/project/AGENTS.md
```

Codex automatically reads `AGENTS.md` at the project root and applies its
instructions to all files within scope. Customize the testing commands
section and conventions for your project.

### 3. (Optional) Copy Agent Metadata

If you want the SDLC skill to appear with branding in the Codex UI:

```bash
mkdir -p /path/to/your/project/agents
cp agents/openai.yaml /path/to/your/project/agents/openai.yaml
```

## What You Get

- **TDD workflow guidance:** Codex follows the red/domain/green/domain cycle
  when writing and implementing tests.
- **Domain modeling:** Codex checks for primitive obsession and creates domain
  types rather than using raw primitives.
- **Code review:** Codex applies a three-stage review (spec, quality, domain)
  before considering work complete.
- **Architecture awareness:** Codex consults `ARCHITECTURE.md` before making
  structural changes.
- **Parallel code review:** Three reviewer agent personas (spec compliance,
  code quality, domain integrity) can be spawned in parallel using Codex's
  `spawn_agent`/`wait`/`close_agent` commands, reducing review time for large
  changesets. See `agents/reviewers/` for the persona files.
- **Ensemble team workflow:** Projects with a `.team/` directory (created by
  the `ensemble-team` skill) can use team-based consensus planning, ping-pong
  TDD pairing, and mob review via Codex's multi-agent support.

## What You Do Not Get

Without hooks or enforcement plugins, Codex cannot be mechanically prevented
from skipping steps. The AGENTS.md instructions are strong guidance, but the
agent may occasionally:

- Edit test files during the green phase
- Skip domain review for "trivial" changes
- Over-implement beyond what the test requires

If you observe these behaviors, point them out. The instructions tell Codex
to follow the workflow, but it is advisory, not enforced.

Codex does support multi-agent workflows via `spawn_agent`, and the parallel
code review feature uses this capability. However, there are no hooks or
enforcement plugins to mechanically gate merges on review completion. For
mechanical enforcement, use the Claude Code plugin which provides PreToolUse
hooks, SubagentStop hooks, and subagent delegation.

## Subdirectory AGENTS.md

Codex supports nested `AGENTS.md` files with more-specific scope. You can
add additional instructions for specific directories:

```
project/
  AGENTS.md              # Project-wide SDLC instructions
  src/
    AGENTS.md            # Source-specific conventions
  tests/
    AGENTS.md            # Test-specific conventions
```

More-deeply-nested files take precedence over parent files.

## Customization

Edit the `AGENTS.md` to match your project:

- Update the testing commands section for your stack
- Add project-specific conventions
- Reference your `ARCHITECTURE.md` location
- Add or remove skills from the installed list
