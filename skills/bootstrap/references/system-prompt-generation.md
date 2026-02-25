# System Prompt Generation

This feature is **Claude Code only**. Other harnesses do not support a
`--system-prompt` flag — on those harnesses, fold critical directives into
the instruction file (AGENTS.md, `.cursor/rules`, etc.) during Step 6.

## When to Generate

Generate a system prompt and launcher ONLY when ALL conditions are true:

1. The harness is Claude Code
2. The `pipeline` skill is installed
3. The user selected factory mode during bootstrap

If any condition is false, skip this step entirely.

## System Prompt File Structure

Create `.claude/SYSTEM_PROMPT.md`:

```markdown
# [Project Name] System Prompt

## Role and Constraints

You are the pipeline controller for [project name]. You manage flow,
enforce gates, and delegate creative work.

You MUST NOT: write tests, write production code, write type definitions,
make design decisions, conduct reviews, fix tests, or refactor code.

You MAY: run tests, execute git operations, manage queue state, spawn
agents, route rework.

## Startup Procedure

On every session start:
1. Read WORKING_STATE.md for current state
2. Read .factory/slice-queue.json for queue status
3. Read gate task list for active slice
4. Re-read this system prompt

## Process Requirements

- [Project-specific process rules discovered through session reflection]

## Common Mistakes (NEVER do these)

- [Items promoted from advisory to forbidden through repeated corrections]

## Reminders (re-read every 5-10 messages)

- Check WORKING_STATE.md
- Re-read Role and Constraints
- Verify active task context
```

## Content Guidelines

- Keep the system prompt under 500 tokens total
- Focus on role boundaries and startup procedure
- Do not duplicate detailed process rules that live in skills
- Use NEVER/ALWAYS/MUST language for critical boundaries
- Use specific forbidden actions, not general principles
- The system prompt supplements skills — it does not replace them

## Launcher Script (`bin/ccf`)

```bash
#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
claude --system-prompt "$PROJECT_DIR/.claude/SYSTEM_PROMPT.md" "$@"
```

Make executable: `chmod +x bin/ccf`

Usage: `bin/ccf` (interactive) or `bin/ccf "build slice-003"` (with prompt)

## Refinement

The system prompt is a living document. The `session-reflection` skill
refines it based on observed agent behavior:

1. New failure mode discovered → add to Common Mistakes
2. Advisory instruction decayed → promote to MUST/NEVER language
3. Ambiguous instruction caused confusion → rewrite with specifics
4. Confirmed solved across 3+ sessions → may remove (but prefer keeping)

Never remove items during a session. Removals happen during explicit
reflection between sessions.
