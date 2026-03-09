---
name: bootstrap
description: >-
  Trigger this skill immediately when the user says "bootstrap" in any
  form. Also trigger it for any request about initializing a project's
  workflow, configuring development practices, or setting up a codebase
  for the first time. Key signals: "bootstrap", "set up workflow",
  "configure TDD", "generate AGENTS.md", "recommend skills", "onboard
  to project", "what tools should I use", "greenfield", "just cloned",
  "new developer joining". Detects the project environment, recommends
  skills by phase, configures TDD strategy, and generates instruction
  files. Project-level onboarding -- NOT for writing code, tests, or
  performing specific dev tasks.
license: CC0-1.0
metadata:
  author: jwilger
  version: "3.3.0"
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

### Step 1: Detect the Environment

Gather project context silently before asking questions:

```
!test -f package.json && echo "js" || true
!test -f Cargo.toml && echo "rust" || true
!test -f pyproject.toml && echo "python" || true
!test -f go.mod && echo "go" || true
!test -f mix.exs && echo "elixir" || true
!git rev-parse --is-inside-work-tree 2>/dev/null && echo "git" || true
!ls skills/*/SKILL.md 2>/dev/null | sed 's|skills/||;s|/SKILL.md||' || true
```

Record: languages detected, git available, skills already installed. If no
language files are found, note "none" and ask the user in Step 5.

### Step 2: Detect Harness Capabilities

Probe for delegation primitives (see `references/capability-detection.md`):
check for TeamCreate tool, Task tool, and skill chaining (always available).

### Step 3: Detect Harness Type

Identify the harness to generate the correct instruction files:

| Signal | Harness |
|--------|---------|
| `CLAUDE.md` convention, Claude Code tools | Claude Code |
| `AGENTS.md` convention, Codex tools | Codex |
| `.cursor/rules` directory | Cursor / Windsurf |
| None of the above | Generic (AGENTS.md only) |

### Step 4: Configure TDD Mode

Match the strategy to detected capabilities:

| Capabilities detected | Strategy | Default mode |
|----------------------|----------|--------------|
| TeamCreate + Task | Agent teams | Automated |
| Task only | Serial subagents | Automated |
| Neither | Chaining | Automated |

Chaining is always available and runs all TDD phases sequentially in a
single context. Guided mode (`/tdd red`, `/tdd green`, etc.) is always
available as a user-controlled alternative. Let the user override.

If Claude Code is detected and the user wants maximum enforcement, offer
to install optional hook templates from `skills/tdd/references/hooks/`.

### Step 4b: Detect Factory Mode

Check if the `pipeline` skill is installed (`skills/pipeline/SKILL.md` exists). If detected, factory pipeline mode is available and Step 5 includes an additional question.

### Step 5: Ask the User

**Question 1: What are you trying to do?**
- "Start a new project" -- recommend Understand + Decide + Build phases
- "Add a feature or fix a bug" -- recommend Build + Ship phases
- "Set up team workflow" -- recommend all phases plus ensemble team

**Question 2: How much process structure?**
- "Minimal" -- recommend tdd, domain-modeling
- "Standard" -- recommend core + ship skills
- "Full" -- recommend all skills (include factory pipeline skills when pipeline is detected)

**Question 3 (only when pipeline detected): What autonomy level?**
Conservative / Standard / Full. Generate `.factory/config.yaml` with the
chosen level. See `references/skill-recommendations.md` for skill lists.

### Step 6: Task Tracking Convention

Include in generated instruction files that agents should use task lists (TaskCreate,
TaskList, or equivalent harness tools) to track work — even for tasks that seem simple.
Simple tasks often reveal subtasks, and a visible task list keeps progress transparent
and prevents steps from being forgotten.

This convention goes into the AGENTS.md "Conventions" section (see
`references/agents-md.md`). If the `task-management` skill is installed, reference it;
otherwise, include the basic convention directly.

### Step 7: Collect Per-Skill AGENTS.md Contributions

Some installed skills ship a `references/agents-md-setup.md` file that specifies
content to add to AGENTS.md. Scan all installed skills for this file:

```
!for skill in skills/*/; do
  test -f "${skill}references/agents-md-setup.md" && echo "${skill}"
done
```

For each skill that has one, read its `agents-md-setup.md` and incorporate the
specified content into AGENTS.md using managed markers for that skill
(`<!-- BEGIN MANAGED: skill-name -->`). The setup file documents what section
to add or append to and provides the content template.

**Size budget:** AGENTS.md must stay under 32 KiB total. Per-skill contributions
should be concise — a few bullet points or a short section. If the combined
contributions would exceed the budget, summarize and point to the skill for
details rather than including full content.

### Step 8: Generate Instruction Files

Generate harness-appropriate files. For Claude Code, CLAUDE.md uses
`@AGENTS.md` references instead of symlinks or content embedding to keep
a single source of truth and avoid duplication. See
`references/agents-md.md` for AGENTS.md best practices (small routing
document, progressive disclosure, managed markers) and
`references/harness-files.md` for harness-specific generation rules.

### Step 9: Optional Ensemble Team

If the user selected "Set up team workflow" or "Full", offer the
`ensemble-team` skill with its three presets (solo-plus, lean, full).

### Step 10: Commit and Display

Stage generated files, commit with a descriptive message, and display:
- What was configured (harness, TDD mode, skills recommended)
- Next steps (`/tdd` to start a TDD cycle, or phase-specific commands)
- If ensemble team was configured, note the preset and member count

## Enforcement Note

This skill is purely advisory. It generates configuration and instruction
files but cannot install skills or modify harness settings without user
confirmation.

## Verification

- [ ] Environment was detected before asking questions
- [ ] Harness capabilities were probed (not assumed)
- [ ] No more than 2-3 questions were asked
- [ ] TDD strategy matched detected capabilities (see Step 4 table)
- [ ] Generated files use managed markers for safe re-runs
- [ ] Task tracking convention is included in generated AGENTS.md
- [ ] Per-skill AGENTS.md contributions were collected and included
- [ ] Nothing was installed without user confirmation

## Dependencies

This skill works standalone. It recommends but does not require other skills.
It generates configuration that references the `tdd` skill for TDD workflow.
