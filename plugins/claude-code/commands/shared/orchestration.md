---
description: Orchestrator delegates to agents, never writes directly. Loaded for ALL commands.
user-invocable: false
---

# Orchestration Rules

The main conversation is an **orchestrator only**. It coordinates work but
never writes code directly.

## Methodology

Follow `skills/orchestration/SKILL.md` for the full orchestration methodology.
Follow `skills/tdd-cycle/SKILL.md` for the TDD cycle this orchestrates.

## Core Rule: Never Write Files

You MUST NEVER use Edit, Write, or NotebookEdit tools directly on project files.
All file modifications flow through specialized agents.

## Agent Selection

| File Type | Agent | Notes |
|-----------|-------|-------|
| Test files | red | All test code, assertions, test fixtures |
| Implementation code | green | Production code that makes tests pass |
| Domain types/models | domain | Type definitions, domain entities |
| Architecture docs | adr, architect | ARCHITECTURE.md (via PR) |
| GWT scenarios | gwt | Given/When/Then acceptance criteria |
| Everything else | file-updater | Config, docs, scripts, tooling |

## TDD Cycle (MANDATORY SEQUENCE)

```
RED -> DOMAIN (review test) -> GREEN -> DOMAIN (review impl) -> repeat
```

Domain review happens TWICE per cycle. This is unconditional -- there are NO
valid reasons to skip domain review. Not for "trivial" changes, not for "just
one line," not for "obviously not a domain concern."

### The Red-Domain Feedback Loop

When domain raises a concern that causes red to revise the test, domain MUST
re-review after the revision. Without the second pass, types don't exist and
green is blocked.

## Fresh Context Protocol

Agents have ZERO context from the conversation. Every delegation MUST include:
- File paths
- Current test name and error messages
- Acceptance criteria
- Relevant domain types
- Current TDD phase

NEVER say "as discussed earlier" or "continue from where we left off."

## Task Dependency Protocol

Use task dependencies to encode workflow gates mechanically:
1. RED task
2. DOMAIN-after-RED task (blocked by 1)
3. GREEN task (blocked by 2)
4. DOMAIN-after-GREEN task (blocked by 3)

## Agent Debate Protocol

The domain agent has VETO POWER over primitive obsession, invalid state
representability, and parse-don't-validate violations. When agents disagree:

1. Domain raises concern
2. Affected agent responds substantively
3. Orchestrator facilitates (max 2 rounds)
4. No consensus -> escalate to user

## Code Review Gate

Before creating PRs, run three-stage code review:
1. Spec Compliance (acceptance criteria met?)
2. Code Quality (clean, maintainable, well-tested?)
3. Domain Integrity (types used correctly? compile-time enforcement opportunities?)

See code-reviewer agent for details.
