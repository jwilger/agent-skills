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
- dot task prefix
- TDD verbosity (silent, brief, explain)
- Languages/frameworks (auto-detect from project files)
- Language-specific test patterns

### 5. Team Formation (Optional)

Ask the user: **"Would you like to set up an ensemble AI team for this project?"**

If the user says **no**, skip this step entirely and proceed to Create Configuration.

If the user says **yes**, present the three presets:

| Preset | Size | Best For |
|--------|------|----------|
| **Solo-plus** | ~3 members | Lightweight team for focused projects or spikes |
| **Lean** | ~5-6 members | Balanced team for most projects |
| **Full** | ~9 members | Complete team for complex, multi-domain projects |

Once the user selects a preset, invoke the `ensemble-team` skill workflow
(`skills/ensemble-team/SKILL.md`). This will:

1. **Research real-world experts** for each role based on the project's domain
   and tech stack (using WebSearch, not memorized lists)
2. **Create `.team/` profiles** with AI-approximation disclaimers and compressed
   active-context forms for each team member
3. **Generate supporting docs**: `PROJECT.md`, `TEAM_AGREEMENTS.md` skeleton,
   `docs/glossary.md`, `docs/deferred-items.md`, `docs/future-ideas.md`
4. **Run the team formation session** where the team reaches consensus on their
   own working agreements (Phase 5 of the ensemble-team skill)

The ensemble-team skill handles all phases end-to-end. The setup skill resumes
after the team formation is complete.

### 6. Create Configuration

Write `.claude/sdlc.yaml` with all gathered settings. Write `.claude/settings.json`
with output style reference. Generate `CLAUDE.md` with workflow quick-reference
(using managed markers for safe updates).

If an ensemble team was configured in Step 5, additionally:

- Add `ensemble_team` section to `.claude/sdlc.yaml`:
  ```yaml
  ensemble_team:
    preset: "solo-plus"  # or "lean" or "full"
    members:
      - name: <member-name>
        role: <role>
        profile: .team/<member-name>.md
      # ... one entry per team member
  ```
- Include ensemble team coordinator instructions in the generated `CLAUDE.md`
  (within managed markers). These instructions tell the orchestrator to activate
  ping-pong pairing mode during `/work` and mob review during `/sdlc:pr`.
- If no team was configured, set `ensemble_team: { preset: "none" }` (or omit
  the section entirely).

### 7. Commit and Push

Stage setup files, create branch if PR workflow enabled, commit, push, create PR.

### 8. Display Success

Show summary of what was configured and next steps:
- `/start` to begin work
- `/work` to pick up a task
- `/model` for event modeling
- If an ensemble team was configured, mention the team preset and member count,
  and note that `/work` will use ping-pong pairing and `/sdlc:pr` will use
  mob review.

## Artifacts Created

| Artifact | Path |
|----------|------|
| SDLC configuration | `.claude/sdlc.yaml` |
| Settings reference | `.claude/settings.json` |
| Workflow quick-reference | `CLAUDE.md` (managed markers) |
| Dot tasks directory | `.dots/` (created by dot CLI init) |
| Team profiles (if configured) | `.team/*.md` |
| Project description (if team) | `PROJECT.md` |
| Team agreements (if team) | `TEAM_AGREEMENTS.md` |
| Domain glossary (if team) | `docs/glossary.md` |
| Deferred items (if team) | `docs/deferred-items.md` |
| Future ideas (if team) | `docs/future-ideas.md` |
