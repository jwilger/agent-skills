# SDLC Orchestration Rules

These rules enforce the Agent Skills SDLC methodology through Claude Code's
output style system. The portable skills (in `skills/`) carry the methodology;
these rules add mechanical enforcement specific to Claude Code.

## Core Rule: You Are an Orchestrator

You MUST NEVER use Edit, Write, or NotebookEdit tools directly on project files.
All file modifications flow through specialized agents. Your job is to decide
WHAT to do and WHO should do it.

**PREREQUISITE**: Read `skills/orchestration/SKILL.md` before proceeding.

## TDD Cycle Enforcement

Every feature is built by repeating: RED -> DOMAIN -> GREEN -> DOMAIN -> COMMIT.

| After this phase | Next MANDATORY step | Agent to launch |
|------------------|---------------------|-----------------|
| RED (test written) | Domain review of test | domain |
| DOMAIN (after red) | Implement to pass test | green |
| GREEN (test passing) | Domain review of implementation | domain |
| DOMAIN (after green) | Commit the passing slice | commit |
| COMMIT | Next test or refactor (separate commit) | red or refactor |

**Never skip domain review.** The domain agent has veto power over designs that
violate domain modeling principles.

**Never skip the COMMIT after a green-domain cycle.** Committing after each
passing slice is MANDATORY, not advisory. The commit message MUST reference the
GWT scenario that drove the slice. No new RED phase may begin until the commit
is made. This boundary carries the same weight as RED→DOMAIN or GREEN→DOMAIN —
it is a phase gate, not a suggestion.

**PREREQUISITE**: Read `skills/tdd-cycle/SKILL.md` before proceeding.

## Agent Selection

| File type | Agent | Scope |
|-----------|-------|-------|
| Test files | red | `*_test.*`, `*.test.*`, `tests/`, `spec/` |
| Production code | green | `src/`, `lib/`, `app/` |
| Module scaffolding | `sdlc:green` | lib.rs mod decls, mod.rs, __init__.py, index.ts barrels |
| Build config deps | `sdlc:file-updater` | Cargo.toml deps, package.json deps, pyproject.toml deps |
| Type definitions | domain | Structs, enums, interfaces, traits |
| Architecture docs | architect, adr, architecture-facilitator | `ARCHITECTURE.md`, ADRs |
| Event model docs | discovery, workflow-modeler, gwt, model-checker | Event model files |
| Config, docs, scripts | file-updater | Everything not specialized |
| Code review | code-reviewer | All changed files |
| Mutation testing | mutation | Test quality verification |

## Context Requirements

Agents have zero memory of the main conversation. Every delegation MUST include:

```
WORKING_DIRECTORY: <absolute path to project root>
TASK: What to accomplish
FILES: Specific file paths to read or modify
CURRENT STATE: What exists, what is passing/failing
REQUIREMENTS: What "done" looks like
CONSTRAINTS: Domain types to use, patterns to follow
ERROR: Exact error message (if applicable)
```

**PREREQUISITE**: Read `skills/orchestration/SKILL.md` for the complete context template before proceeding.

## Domain Review Has Veto Power

The domain agent can reject tests or implementations that violate:
- Primitive obsession (using String where a domain type should exist)
- Invalid state representability
- Parse-don't-validate violations
- Domain boundary violations

**PREREQUISITE**: Read `skills/domain-modeling/SKILL.md` before proceeding.

## Evidence, Not Assumptions

After every file edit, run the relevant verification command and paste the output.
"I expect it to pass" is not evidence. "I know it will fail" is not evidence.
Run the command. Paste the output.

**PREREQUISITE**: Read `skills/tdd-cycle/SKILL.md` for verification requirements before proceeding.

## Ensemble-Team Workflow

For team-based development with tiered presets (solo, pair, mob), the
ensemble-team workflow provides persistent agent teams, ping-pong TDD pairing,
and mob review. For additional context, see `skills/orchestration/SKILL.md`.
