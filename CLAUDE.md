# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Agent Skills (v4.1.0) is a portable library of Markdown-based skills that encode professional software development practices for any AI coding agent. Skills are harness-agnostic — they work on Claude Code, Codex, Cursor, Windsurf, OpenCode, Goose, Amp, Aider, and any Agent Skills-compatible harness.

This is a **content-only repository**: no build system, no test runner, no compiled artifacts. The deliverables are SKILL.md files and their reference documentation, installed via `npx skills add jwilger/agent-skills`.

## Development Workflow

There are no build, lint, or test commands. All changes are to Markdown files. Quality is maintained through:

- Adherence to the skill template (`skills/.template/SKILL.md.example`)
- Token budget compliance (see below)
- Frontmatter correctness (`skills/.template/FRONTMATTER.md`)
- Section order enforcement (Value → Purpose → Practices → Enforcement Note → Verification → Dependencies)

Version is tracked in the `VERSION` file (semver). Use `/bump` to increment.

**Commit and PR hygiene:** Never add AI co-author lines (`Co-Authored-By`), "Generated with", "Created by", or any similar taglines to commit messages or PR descriptions. The use of AI tooling should not be called out in version control metadata.

## Architecture

### Skill Tiers

| Tier | Skills | Token Budget |
|------|--------|-------------|
| 0 (Bootstrap) | `bootstrap` | 1000 |
| 1 (Core Process) | `tdd`, `domain-modeling`, `code-review`, `architecture-decisions`, `event-modeling`, `ticket-triage`, `design-system` | 3000 |
| 2 (Team Workflows) | `ensemble-team`, `task-management` | 4000 |
| 3 (Utility) | `debugging-protocol`, `user-input-protocol`, `memory-protocol` | 3000 |
| 4 (Factory Pipeline) | `pipeline`, `ci-integration`, `factory-review` | 3000 |
| Advanced | `mutation-testing`, `atomic-design` | 3000 |

### Skill Directory Structure

Each skill lives in `skills/<name>/` and contains:
- `SKILL.md` — the skill itself (frontmatter + six required body sections)
- `references/` — detailed supplementary docs loaded on demand by the agent

### Key Design Principles

- **Skills are the single source of truth.** All practices live in SKILL.md files. No separate plugin layer.
- **Enforcement proportional to capability.** Skills adapt: structural enforcement (context isolation, handoff schemas) on capable harnesses, advisory guidance on simpler ones. Optional hook templates in `skills/tdd/references/hooks/` add mechanical enforcement on Claude Code.
- **Graceful degradation.** Missing dependencies recommend installation but never block execution. Every skill provides value standalone.
- **Dependencies form a DAG.** Declared in frontmatter `metadata.requires`. No circular dependencies. Skills reference each other by name, never internal structure.
- **Progressive disclosure.** SKILL.md stays concise (within token budgets). Extended examples and detailed guides live in `references/`.

### Factory Pipeline (Tier 4)

The optional pipeline orchestrates autonomous build-and-ship: Human plans → Agent builds (TDD pairs, code review, mutation testing, CI) → Human reviews. Three autonomy levels (conservative/standard/full). Pipeline state lives in `.factory/` in consumer projects. At full autonomy on Claude Code, parallel slices run in isolated git worktrees.

### TDD Execution Strategies

The `tdd` skill auto-detects harness capabilities and selects:
1. **Agent teams** — persistent ping-pong pair sessions (Claude Code with TeamCreate)
2. **Serial subagents** — isolated phases via Task tool (Codex, Claude Code)
3. **Chaining** — sequential roles in single context (all harnesses)
4. **Guided** — manual phase control via `/tdd red`, `/tdd green`, etc.

## Authoring Skills

When creating or modifying a skill:

1. Follow the template at `skills/.template/SKILL.md.example`
2. Use the frontmatter reference at `skills/.template/FRONTMATTER.md`
3. Maintain all six body sections in order: Value, Purpose, Practices, Enforcement Note, Verification, Dependencies
4. Stay within the tier's token budget
5. Keep SKILL.md under 500 lines; move detail to `references/`
6. Enforcement Note must honestly state guarantees at each level (advisory/structural/mechanical)
7. Verification items must be binary and observable
8. Shell fragments in SKILL.md: read-only environment detection only — no writes, no network calls, no package installation
