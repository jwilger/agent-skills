# Harness-Specific File Generation

After generating the universal AGENTS.md, create harness-specific files
that the detected harness reads natively.

## Claude Code

**Primary file:** `CLAUDE.md`

Claude Code reads `CLAUDE.md` from the project root on every session start.
Generate it using an `@` reference to AGENTS.md rather than symlinks or
content embedding. The `@` reference tells Claude Code to load AGENTS.md
as additional context, keeping CLAUDE.md small and avoiding duplication.

```markdown
<!-- BEGIN MANAGED: bootstrap -->
@AGENTS.md

## Claude Code

- TDD enforcement hooks installed: [yes/no]
- Resume protocol: Resume stopped agents instead of re-creating
- Task dependency protocol: See `skills/tdd/references/claude-code.md`
- When editing CLAUDE.md or AGENTS.md: keep total instructions under 30, use @-references for detailed topics, never duplicate content between files
<!-- END MANAGED: bootstrap -->
```

When the `ensemble-team` skill has been run, a second managed section is
added to CLAUDE.md:

```markdown
<!-- BEGIN MANAGED: ensemble-team -->
## Ensemble Team

Read `.team/coordinator-instructions.md` for your coordinator role.
<!-- END MANAGED: ensemble-team -->
```

**Optional hooks:** If the user accepted hook installation during
bootstrap, copy `skills/tdd/references/hooks/claude-code-hooks.json`
to `.claude/hooks.json` (or merge into existing hooks file).

**Configuration:** Write `.claude/sdlc.yaml` with all detected settings.

## Codex

**Primary file:** `AGENTS.md` (Codex reads this natively)

No additional files needed. AGENTS.md is the Codex instruction file.
Include Codex-specific patterns in a managed section:

```markdown
<!-- BEGIN MANAGED: bootstrap-codex -->
## Codex Patterns

- Use `spawn_agent` for parallel code review
- See `skills/tdd/references/` for phase agent prompts
<!-- END MANAGED: bootstrap-codex -->
```

## Cursor / Windsurf

**Primary file:** `.cursor/rules` (or `.cursorrules`)

Generate a rules file that summarizes the workflow. Cursor rules files
have a smaller effective context than AGENTS.md, so be more concise:

```
# TDD Workflow
Follow the tdd skill: RED -> DOMAIN -> GREEN -> DOMAIN -> COMMIT
Only edit test files during RED, type definitions during DOMAIN,
production code during GREEN. Commit after every cycle.
```

Also generate AGENTS.md for agents that read it (some Cursor extensions
do).

## Generic Harness

**Primary file:** `AGENTS.md` only.

No harness-specific files. The agent reads AGENTS.md if its harness
supports the convention. If not, the installed skills provide guidance
directly.

## Configuration File

All harnesses write a configuration file at `.claude/sdlc.yaml` (the
path is a convention from the original Claude Code setup, retained for
compatibility):

```yaml
version: "3.0"
harness:
  type: claude-code
  capabilities:
    subagents: true
    agent_teams: true
    skill_chaining: true
    model_selection: true
tdd:
  mode: automated
  strategy: agent-teams
  hooks_installed: false
languages:
  - rust
skills_installed:
  - tdd
  - domain-modeling
  - code-review
ensemble_team:
  preset: none

# Override default model tiers for agent roles.
# Values depend on harness. Claude Code: haiku, sonnet, opus.
# Codex: any model ID via config_file. Other harnesses: consult docs.
# Omit to use defaults (haiku for execution, sonnet for judgment).
# model_tiers:
#   tdd_red: haiku
#   tdd_green: haiku
#   domain_reviewer: sonnet
#   commit: haiku
#   pipeline_controller: sonnet
#   ensemble_coordinator: sonnet
#   code_reviewer: sonnet
#   driver: sonnet
#   reviewer: sonnet
```

### Model Tier Overrides

The `model_tiers` section lets teams customize which model each agent role
uses. Common use cases:

- **Budget-conscious teams:** Set all roles to `haiku`. Structural
  enforcement (file restrictions, handoff schemas) maintains quality.
- **High-stakes projects:** Promote execution-tier roles to `sonnet` for
  improved test design quality.
- **Complex pipelines:** Set `pipeline_controller` to `opus` when managing
  many parallel slices.

On harnesses without per-agent model support (Windsurf, Amp, Roo Code,
Amazon Q, Junie), model tier values are ignored — all agents inherit the
session model. The structural constraints still apply. See
`tdd/references/model-tiers.md` for the full harness support matrix.

## System Prompt (Claude Code + Factory Mode Only)

When Claude Code is the harness AND factory mode is configured (pipeline +
user selected factory mode), generate a system prompt file and launcher
script. See `system-prompt-generation.md` for the full procedure.

Generate `.claude/SYSTEM_PROMPT.md` and `bin/ccf` launcher. Add to
CLAUDE.md managed section:

```markdown
<!-- BEGIN MANAGED: system-prompt -->
## System Prompt

Pipeline controller system prompt: `.claude/SYSTEM_PROMPT.md`
Launcher: `bin/ccf` (uses `claude --system-prompt`)
<!-- END MANAGED: system-prompt -->
```

On non-Claude-Code harnesses, skip this section. Fold critical directives
into the instruction file during normal Step 6 generation instead.

## Re-run Safety

All generated content lives inside managed markers. Re-running bootstrap:

1. Detects existing configuration and offers to update or replace.
2. Preserves user content outside managed markers.
3. Regenerates content inside managed markers from current settings.
4. Warns if the configuration version has changed significantly.
