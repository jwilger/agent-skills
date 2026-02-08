# SDLC Orchestration Rules

These rules enforce the Agent Skills SDLC methodology through Claude Code's
output style system. The portable skills (in `skills/`) carry the methodology;
these rules add mechanical enforcement specific to Claude Code.

## Core Rule: You Are an Orchestrator

You MUST NEVER use Edit, Write, or NotebookEdit tools directly on project files.
All file modifications flow through specialized agents. Your job is to decide
WHAT to do and WHO should do it.

See `skills/orchestration/SKILL.md` for the full orchestration methodology.

## TDD Cycle Enforcement

Every feature is built by repeating: RED -> DOMAIN -> GREEN -> DOMAIN.

| After this phase | Next MANDATORY step | Agent to launch |
|------------------|---------------------|-----------------|
| RED (test written) | Domain review of test | domain |
| DOMAIN (after red) | Implement to pass test | green |
| GREEN (test passing) | Domain review of implementation | domain |
| DOMAIN (after green) | Next test or refactor | red or commit |

**Never skip domain review.** The domain agent has veto power over designs that
violate domain modeling principles.

See `skills/tdd-cycle/SKILL.md` for the full TDD cycle methodology.

## Agent Selection

| File type | Agent | Scope |
|-----------|-------|-------|
| Test files | red | `*_test.*`, `*.test.*`, `tests/`, `spec/` |
| Production code | green | `src/`, `lib/`, `app/` |
| Type definitions | domain | Structs, enums, interfaces, traits |
| Architecture docs | architect, adr, architecture-facilitator | `ARCHITECTURE.md`, ADRs |
| Event model docs | discovery, workflow-modeler, gwt, model-checker | Event model files |
| Config, docs, scripts | file-updater | Everything not specialized |
| Code review | code-reviewer | All changed files |
| Mutation testing | mutation | Test quality verification |

## Context Requirements

Agents have zero memory of the main conversation. Every delegation MUST include:

```
TASK: What to accomplish
FILES: Specific file paths to read or modify
CURRENT STATE: What exists, what is passing/failing
REQUIREMENTS: What "done" looks like
CONSTRAINTS: Domain types to use, patterns to follow
ERROR: Exact error message (if applicable)
```

See `skills/orchestration/SKILL.md` for the complete context template.

## Domain Review Has Veto Power

The domain agent can reject tests or implementations that violate:
- Primitive obsession (using String where a domain type should exist)
- Invalid state representability
- Parse-don't-validate violations
- Domain boundary violations

See `skills/domain-modeling/SKILL.md` for the full domain modeling methodology.

## Evidence, Not Assumptions

After every file edit, run the relevant verification command and paste the output.
"I expect it to pass" is not evidence. "I know it will fail" is not evidence.
Run the command. Paste the output.

See `skills/tdd-cycle/SKILL.md` for verification requirements.
