# TDD Orchestrator Instructions

> **Scope:** This file applies to the **serial subagents** execution strategy
> only. If you are using agent teams (TeamCreate available), use
> `ping-pong-pairing.md` instead. If you are using chaining (no delegation
> primitives), follow the chaining section in SKILL.md.

You coordinate the TDD cycle by delegating to phase agents. You NEVER write,
edit, or create project files yourself.

## Shared Rules

Read `references/shared-rules.md` for rules that apply to all execution
strategies: domain veto power, outside-in progression, type-first TDD
anti-pattern, pre-implementation context checklist, pipeline integration,
and recovery protocol.

## Core Rule

All file modifications flow through phase agents. Not "quick fixes," not
"just one line," not "cleanup." Every file change is delegated.

## Agent Selection

| File type | Agent | Scope |
|-----------|-------|-------|
| Test files | RED agent | `*_test.*`, `*.test.*`, `tests/`, `spec/` |
| Type definitions | DOMAIN agent | Structs, enums, traits, interfaces |
| Production code | GREEN agent | `src/`, `lib/`, `app/` |
| Commit | COMMIT agent | All changed files from this cycle |

## Mandatory Cycle: RED -> DOMAIN -> GREEN -> DOMAIN -> COMMIT

Every phase is mandatory, every time. No exceptions for "trivial" changes.

### Workflow Gates

Each gate must be satisfied before the next phase begins:

1. **RED complete** -> Test exists and fails (compilation failure counts).
   Required evidence: `{test_file, test_name, failure_output}`.
2. **DOMAIN (after RED) complete** -> Types compile, test is domain-correct.
   Required evidence: `{domain_review, type_files_created}`.
3. **GREEN complete** -> All tests pass.
   Required evidence: `{implementation_files, test_output}`.
4. **DOMAIN (after GREEN) complete** -> No domain violations.
   Required evidence: `{review, full_test_output}`.
5. **COMMIT complete** -> Atomic commit exists.
   Required evidence: `{commit_hash, commit_message, full_test_output}`.

**No new RED without a completed COMMIT.** This is a hard gate.

### Handoff Schema Enforcement

Check every returned evidence object for the required fields listed above.
If ANY field is missing, block progression and re-request from the same agent
with a clear description of what is missing.

### Fresh Context Protocol

Every new agent delegation MUST include complete context:

```
WORKING_DIRECTORY: <absolute path to project root>
TASK: What to accomplish
FILES: Specific file paths to read or modify
CURRENT STATE: What exists, what is passing/failing
REQUIREMENTS: What "done" looks like
CONSTRAINTS: Domain types to use, patterns to follow
ERROR: Exact error message (if applicable)
```

NEVER say "as discussed earlier" or "continue from where we left off."

## Passing Context to Phase Agents

All gathered context (see Pre-Implementation Context Checklist in
`references/shared-rules.md`) goes into the `CONSTRAINTS` field of every
Fresh Context Protocol delegation. This ensures each phase agent has full
domain awareness without relying on conversational memory. Include file
paths and relevant excerpts -- not just references to document names.

## Serial Subagent Delegation Cycle

The cycle above (RED -> DOMAIN -> GREEN -> DOMAIN -> COMMIT) is executed by
spawning a fresh subagent for each phase. Use the agent selection table and
handoff schema enforcement in this file for coordination. For rules that apply
to all strategies (domain veto, outside-in progression, type-first anti-pattern,
pipeline integration, recovery), see `references/shared-rules.md`.
