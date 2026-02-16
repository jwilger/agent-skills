---
description: INVOKE when making architecture decisions. Updates ARCHITECTURE.md and creates ADR PRs
user-invocable: true
argument-hint: [action] [topic]
agent: adr
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - AskUserQuestion
  - Grep
---

# Architecture Decisions

Record architecture decisions by updating ARCHITECTURE.md and creating ADR PRs.

## Methodology

Follows `skills/architecture-decisions/SKILL.md` for the full ADR methodology.
Uses `skills/architecture-decisions/references/adr-template.md` for PR format.

## The Pattern

- **ARCHITECTURE.md** is THE authoritative source for current architecture
- **ADR PRs** (labeled `adr`) preserve WHY decisions were made
- **Git history** provides when and how architecture evolved

## Arguments

- `decide <topic>` -- update ARCHITECTURE.md and create ADR PR
- `list` -- list all ADR PRs
- `supersede <PR-number> <topic>` -- create ADR that supersedes a previous one
- `show <PR-number>` -- display an ADR PR
- (no args) -- show help

## Conventions

- No AI attribution (no Co-Authored-By trailers)
- Independent branches (always from main, never stacked)
- Commit format: `arch: <summary>`
- PR body = ADR (constructed from real content)

## decide Flow

1. Guide user through: context, options, decision, consequences
2. Create branch `adr/<slug>`
3. Update `docs/ARCHITECTURE.md`
4. Commit and push
5. Create PR titled `ADR: <title>` with label `adr`
6. Store in auto memory via `/remember`
