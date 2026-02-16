---
description: INVOKE once per project to configure SDLC workflow
user-invocable: true
allowed-tools:
  - Bash
  - Read
  - Write
  - AskUserQuestion
  - WebFetch
hooks:
  PreToolUse:
    - matcher: Bash
      once: true
      hooks:
        - type: prompt
          prompt: |
            SETUP PREREQUISITE CHECK (runs once)

            Verify gh CLI is available before running setup commands.
            If not installed, direct to https://cli.github.com/

            Respond with: {"ok": true}
---

# Setup

Initialize or update the SDLC workflow for this project. Configures:
1. GitHub repository and branch rulesets (optional)
2. dot CLI for local task management
3. Language-specific TDD patterns
4. Project configuration (`.claude/sdlc.yaml`)

## Methodology

This skill implements the bootstrap process described in
`skills/bootstrap/SKILL.md`. It configures the harness-specific enforcement
layer on top of the portable skills.

## Steps

### 1. Version Detection

Check if `.claude/sdlc.yaml` exists. If yes, compare version. If current,
inform user and stop. If outdated, offer update (preserving existing choices).
If new install, proceed with fresh configuration.

### 2. Prerequisites

Check for: gh CLI, gh authentication, dot CLI (https://github.com/ajeetdsouza/dot).

### 3. GitHub Repository Setup (Optional)

If no remote exists, offer to create one. Configure branch rulesets
(signed commits, PR requirements, force push protection, auto-delete branches).
Enforce squash-only merging with PR title/body as commit message.

### 4. Interactive Configuration

Use AskUserQuestion for each choice:
- Development mode (event-modeling vs traditional)
- Git worktrees for parallel development
- dot task prefix
- TDD verbosity (silent, brief, explain)
- Languages/frameworks (auto-detect from project files)
- Language-specific test patterns

### 5. Create Configuration

Write `.claude/sdlc.yaml` with all gathered settings. Write `.claude/settings.json`
with output style reference. Generate `CLAUDE.md` with workflow quick-reference
(using managed markers for safe updates).

### 6. Commit and Push

Stage setup files, create branch if PR workflow enabled, commit, push, create PR.

### 7. Display Success

Show summary of what was configured and next steps:
- `/start` to begin work
- `/work` to pick up a task
- `/model` for event modeling

## Artifacts Created

| Artifact | Path |
|----------|------|
| SDLC configuration | `.claude/sdlc.yaml` |
| Settings reference | `.claude/settings.json` |
| Workflow quick-reference | `CLAUDE.md` (managed markers) |
| Dot tasks directory | `.dots/` (created by dot CLI init) |
