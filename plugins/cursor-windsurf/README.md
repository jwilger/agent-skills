# SDLC Skills: Cursor and Windsurf Integration

Rules files that configure Cursor and Windsurf AI behavior for the SDLC
workflow. Everything is advisory -- these IDEs do not support enforcement
hooks, so the AI follows the rules by convention.

## What This Provides

A rules file that teaches the AI:
- TDD red/domain/green/domain cycle with file ownership by phase
- Domain modeling (parse-don't-validate, primitive obsession detection)
- Architecture decision governance (check ADRs before structural changes)
- Three-stage code review (spec compliance, code quality, domain integrity)
- Structured input protocol (stop and ask with options, don't guess)

The rules work across all AI modalities in both editors: tab completion,
inline edits, chat, and agent/Cascade mode. The TDD discipline and domain
modeling rules are most impactful in agent mode where the AI performs
multi-step work autonomously.

## Setup: Cursor

Copy the rules file into your project:

```bash
mkdir -p .cursor/rules
cp .cursor/rules/sdlc.mdc YOUR_PROJECT/.cursor/rules/sdlc.mdc
```

The rule uses `alwaysApply: true`, so it activates in every AI interaction
without needing to be referenced manually.

To verify: open Cursor Settings > Rules and confirm `sdlc` appears in the
project rules list.

### Optional: Split Rules

If you prefer granular control, split the single `sdlc.mdc` file into
separate rules with file-scoped globs:

```
.cursor/rules/
  tdd-red.mdc        # globs: ["*_test.*", "*.test.*", "tests/**"]
  tdd-green.mdc      # globs: ["src/**", "lib/**", "app/**"]
  domain-modeling.mdc # globs: ["**/types.*", "**/*.d.ts", "**/mod.rs"]
  review.mdc          # alwaysApply: false, description: "Code review checklist"
```

This makes rules auto-attach only when editing matching files, reducing
context overhead for simple edits.

## Setup: Windsurf

Copy the rules file into your project:

```bash
mkdir -p .windsurf/rules
cp .windsurf/rules/sdlc.md YOUR_PROJECT/.windsurf/rules/sdlc.md
```

The rule uses `trigger: always` so Cascade applies it to every interaction.

To verify: open Windsurf's "Manage memories" > workspace rules and confirm
the SDLC rule is listed.

### Character Limits

Windsurf limits individual rule files to 6,000 characters and total rules
to 12,000 characters. The SDLC rule file is well under 6,000 characters.
If you add other rules and hit the limit, split the SDLC rule into separate
files for each concern (TDD, domain modeling, review).

## Setup: Agent Skills (Both Editors)

Both Cursor and Windsurf support Agent Skills. For deeper methodology
guidance beyond what the rules file provides, install skills directly:

```bash
npx skills add jwilger/agent-skills --skill tdd-cycle
npx skills add jwilger/agent-skills --skill domain-modeling
npx skills add jwilger/agent-skills --skill code-review
npx skills add jwilger/agent-skills --skill architecture-decisions
npx skills add jwilger/agent-skills --skill debugging-protocol
npx skills add jwilger/agent-skills --skill user-input-protocol
```

Or install all skills at once:

```bash
npx skills add jwilger/agent-skills --all
```

Then run the bootstrap skill to get recommendations tailored to your project.

Skills provide more detailed methodology than the rules file. When both are
installed, they complement each other: the rules file provides always-on
context, and skills provide deep guidance when activated.

## Enforcement Limitations

Neither Cursor nor Windsurf supports enforcement hooks. The AI will
**usually** follow these rules, but it **can** violate them. There is no
mechanical prevention of:

- Editing test files during the green phase
- Skipping domain review between red and green
- Making architecture changes without checking ADRs
- Choosing silently when it should ask for input
- Running three-stage code review in parallel with focused reviewer agents

Code review in these editors runs sequentially. For parallel review with three
focused agents (spec compliance, code quality, domain integrity) running
simultaneously, see the Claude Code, Codex, or OpenCode plugins.

If you observe the AI violating a rule, point it out in chat. The AI will
correct course. For mechanical enforcement, use the Claude Code plugin
(`plugins/claude-code/`) which provides hooks that prevent violations.

## MCP Servers

No SDLC-specific MCP configuration is needed. However, both editors support
MCP servers that enhance the workflow:

- **File system MCP:** Both editors have built-in file access.
- **Git MCP:** Useful for commit-per-cycle discipline.
- **Memory MCP (Memento, etc.):** Enables the memory-protocol skill for
  cross-session knowledge persistence.

Configure MCP servers through each editor's settings if desired.
