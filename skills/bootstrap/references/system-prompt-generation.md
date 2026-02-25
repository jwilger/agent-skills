# System Prompt Generation

When to generate a project-specific system prompt:

- The `pipeline` skill is installed
- The `ensemble-team` skill is installed
- The user selected factory mode during bootstrap
- The harness supports a `--system-prompt` flag or equivalent

If any condition is not met, fold critical directives into the instruction
file (CLAUDE.md, AGENTS.md, `.cursor/rules`) instead.

## System Prompt File Structure

Create `SYSTEM_PROMPT.md` in the project root:

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

## Launcher Script

For harnesses that support system prompts, generate a launcher script.

### Claude Code (`bin/ccf`)

```bash
#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
claude --system-prompt "$PROJECT_DIR/SYSTEM_PROMPT.md" "$@"
```

Make executable: `chmod +x bin/ccf`

Usage: `bin/ccf` (interactive) or `bin/ccf "build slice-003"` (with prompt)

### Other Harnesses

| Harness | System Prompt Support | Alternative |
|---------|----------------------|-------------|
| Claude Code | `--system-prompt` flag | Native support |
| Codex | No flag available | Fold into AGENTS.md preamble |
| Cursor | No flag available | Fold into `.cursor/rules` preamble |
| Windsurf | No flag available | Fold into instruction file |
| Generic | Varies | Fold into AGENTS.md preamble |

### Folding Into Instruction Files

When the harness does not support a system prompt flag, add a clearly
marked section at the TOP of the instruction file:

```markdown
<!-- BEGIN MANAGED: system-prompt -->
## Critical Controller Constraints

[Role boundaries and startup procedure from SYSTEM_PROMPT.md]
<!-- END MANAGED: system-prompt -->
```

Place this before other content so it is read first and given highest
priority in the agent's context.

## Refinement

The system prompt is a living document. The `session-reflection` skill
refines it based on observed agent behavior:

1. New failure mode discovered → add to Common Mistakes
2. Advisory instruction decayed → promote to MUST/NEVER language
3. Ambiguous instruction caused confusion → rewrite with specifics
4. Confirmed solved across 3+ sessions → may remove (but prefer keeping)

Never remove items during a session. Removals happen during explicit
reflection between sessions.
