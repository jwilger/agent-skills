---
name: bootstrap
description: >-
  Zero-config SDLC onboarding. Detects project environment, harness
  capabilities, and harness type. Configures TDD mode, generates AGENTS.md,
  offers optional enforcement hooks, and recommends skills by phase. Single
  entry point for all harnesses.
license: CC0-1.0
metadata:
  author: jwilger
  version: "2.1"
  requires: []
  context: []
  phase: understand
  standalone: true
---

# Bootstrap

**Value:** Communication -- establish shared understanding of environment,
capabilities, and workflow before any work begins.

## Purpose

Single entry point for configuring the SDLC workflow on any harness. Detects
the project environment and harness capabilities, configures TDD mode
(guided or automated), generates harness-appropriate instruction files, and
recommends skills. Never silently installs or modifies anything.

## Practices

Follow steps 0-8 in order. Each step references detailed docs where needed.

**Step 0: Detect Existing Configuration.** Check for existing AGENTS.md,
CLAUDE.md, `.factory/`, `.team/`. If found, update managed sections only.
See `references/existing-config-detection.md`.

**Step 1: Detect Environment.** Silently gather: languages (package.json,
Cargo.toml, etc.), git availability, installed skills. Record results.

**Step 2: Detect Capabilities.** Probe for delegation primitives (Task
tool, TeamCreate, AskUserQuestion). When AskUserQuestion is available, use
it for ALL user questions. See `references/capability-detection.md`.

**Step 3: Detect Harness Type.** Identify harness (Claude Code, Codex,
Cursor/Windsurf, Generic) from conventions and tools. See
`references/harness-files.md`.

**Step 4: Configure TDD Mode.** Recommend automated (`/tdd`) when
subagents or teams are available, guided otherwise. Let the user override.

**Step 4b: Detect Factory Mode.** If `pipeline` skill is installed, factory
mode is available — add autonomy level question to Step 5.

**Step 5: Ask the User.** Three questions max: (1) what are you doing?
(2) how much structure? (3) autonomy level (pipeline only). After
confirmation, offer batch skill installation. See
`references/skill-recommendations.md` and
`references/existing-config-detection.md`.

**Step 6: Generate Instruction Files.** Generate harness-appropriate files.
See `references/agents-md.md` and `references/harness-files.md`.

**Step 6.5: Generate System Prompt (Claude Code + Factory only).** Create
`.claude/SYSTEM_PROMPT.md` and `bin/ccf` launcher. See
`references/system-prompt-generation.md`.

**Step 7: Optional Ensemble Team.** Offer `ensemble-team` skill if user
selected team workflow or full structure.

**Step 7b: Verify .gitignore Safety.** Confirm `.claude/skills/` is not
gitignored. Fix overly broad patterns (use `/skills/` not `skills/`).

**Step 8: Commit and Display.** Stage, commit, show configuration summary
and next steps.

## Enforcement Note

Purely advisory. Generates configuration but cannot install skills or modify
harness settings without user confirmation.

## Verification

- [ ] Environment was detected before asking questions
- [ ] Harness capabilities were probed (not assumed)
- [ ] No more than 2-3 questions were asked
- [ ] TDD mode recommendation matched detected capabilities
- [ ] Generated files use managed markers for safe re-runs
- [ ] Nothing was installed without user confirmation

## Dependencies

This skill works standalone. It recommends but does not require other skills.
It generates configuration that references the `tdd` skill for TDD workflow.
