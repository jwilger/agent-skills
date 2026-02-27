# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Agent Skills (v7.0.0) is a portable library of Markdown-based skills that encode professional software development practices for any AI coding agent. Skills are harness-agnostic — they work on Claude Code, Codex, Cursor, Windsurf, OpenCode, Goose, Amp, Aider, and any Agent Skills-compatible harness.

This is a **content-only repository**: no build system, no test runner, no compiled artifacts. The deliverables are SKILL.md files and their reference documentation, installed via `npx skills add jwilger/agent-skills`.

## Development Workflow

There are no build, lint, or test commands. All changes are to Markdown files. Quality is maintained through:

- Adherence to the skill template (`skills/.template/SKILL.md.example`)
- Frontmatter correctness (`skills/.template/FRONTMATTER.md`)
- Section order enforcement (Value → Purpose → Practices → Enforcement Note → Verification → Dependencies)
- SKILL.md under 500 lines; detailed content moves to `references/`

Version is tracked in the `VERSION` file (semver). Use `/bump` to increment.

**Commit and PR hygiene:** Never add AI co-author lines (`Co-Authored-By`), "Generated with", "Created by", or any similar taglines to commit messages or PR descriptions. The use of AI tooling should not be called out in version control metadata.

## Architecture

### Skill Categories

| Category | Skills |
|----------|--------|
| Multi-phase (sub-invocations) | `tdd`, `event-modeling`, `design-system` |
| Standalone | `domain-modeling`, `code-review`, `debugging-protocol` |
| Architecture | `architecture-probe`, `architecture-adr`, `architecture-refresher`, `architecture-crosscut` |
| Work Planning | `vertical-slice-ticket`, `prd-breakdown` |
| Coordination | `consensus-facilitation`, `consensus-participation`, `persona-creation`, `retrospective`, `handoff-protocol` |

### Skill Directory Structure

Each skill lives in `skills/<name>/` and contains:
- `SKILL.md` — the skill itself (frontmatter + six required body sections)
- `references/` — detailed supplementary docs loaded on demand by the agent

### Key Design Principles

- **Skills are the single source of truth.** All practices live in SKILL.md files.
- **Skills describe WHAT, not HOW to wire agents.** Harness-specific configuration (agent teams, subagent strategies, session management) is per-project config, not skill content.
- **Graceful degradation.** Missing dependencies recommend installation but never block execution. Every skill provides value standalone.
- **Dependencies form a DAG.** Declared in frontmatter `metadata.requires`. No circular dependencies. Skills reference each other by name, never internal structure.
- **Progressive disclosure.** SKILL.md stays concise (under 500 lines). Extended examples and detailed guides live in `references/`.
- **Coordination skills are agent-count-agnostic.** They work for one agent reflecting solo, two agents in subagent mode, or a full team.

### Multi-Phase Skills

Some skills have distinct phases accessed via sub-invocations (e.g., `/tdd red`, `/event brainstorm`, `/design tokens`). The SKILL.md describes the overall process and routing. Each phase has a dedicated reference file in `references/` loaded when invoked.

## Authoring Skills

When creating or modifying a skill:

1. Follow the template at `skills/.template/SKILL.md.example`
2. Use the frontmatter reference at `skills/.template/FRONTMATTER.md`
3. Maintain all six body sections in order: Value, Purpose, Practices, Enforcement Note, Verification, Dependencies
4. Keep SKILL.md under 500 lines; move detail to `references/`
5. Enforcement Note must honestly state guarantees (advisory/structural/mechanical)
6. Verification items must be binary and observable
7. Shell fragments in SKILL.md: read-only environment detection only — no writes, no network calls, no package installation
