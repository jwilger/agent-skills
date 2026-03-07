# Instruction File Routing

Reference for routing project-specific directives into the correct
instruction file. There is no separate system prompt file or launcher
script — all project instructions flow through the standard instruction
file hierarchy.

## Instruction File Hierarchy

```
CLAUDE.md                          ← Session management, harness config
  └─ @AGENTS.md                   ← Project rules, conventions, workflow
       └─ .team/coordinator-instructions.md  ← Coordinator/controller role
```

Claude Code loads CLAUDE.md automatically on every session start. The
`@AGENTS.md` reference in CLAUDE.md causes AGENTS.md to load as additional
context. Coordinator-specific instructions live in a separate file that
only coordinators/pipeline-controllers need to read.

## Content Routing

| Content type | Target file | Examples |
|---|---|---|
| Session management | CLAUDE.md | Startup procedure, compaction recovery, state tracking |
| Harness config | CLAUDE.md | TDD hooks installed, resume protocol |
| Project rules | AGENTS.md | Coding conventions, dos/don'ts, workflow |
| Build/test commands | AGENTS.md | Test runner, linter, build commands |
| Installed skills | AGENTS.md | Skill list with one-line descriptions |
| Role boundaries | .team/coordinator-instructions.md | Controller vs. builder, forbidden actions |
| Pipeline gates | .team/coordinator-instructions.md | Pre-flight checks, spawn discipline |
| Domain review | .team/coordinator-instructions.md | Review checklists, domain integrity |

## Harness-Specific Patterns

### Claude Code

Directives go into CLAUDE.md and AGENTS.md using managed markers:

```markdown
<!-- BEGIN MANAGED: session-reflection -->
## Startup Procedure
1. Read WORKING_STATE.md if it exists
2. Run git status
3. Confirm current task before proceeding

## Common Mistakes (NEVER do these)
- NEVER commit without running the linter first
- NEVER modify files outside src/ and test/
<!-- END MANAGED: session-reflection -->
```

### Codex

Codex reads AGENTS.md natively. Add a managed section to AGENTS.md:

```markdown
<!-- BEGIN MANAGED: session-reflection -->
## Process Requirements
- MUST run linter before every commit
- MUST read WORKING_STATE.md after every restart
<!-- END MANAGED: session-reflection -->
```

### Cursor / Windsurf

Add a managed section to `.cursor/rules` or `.windsurfrules`:

```
# Session Reflection - Process Requirements
- MUST run linter before every commit
- MUST read WORKING_STATE.md after every restart
# End Session Reflection
```

### Generic Harness

Add a managed section to AGENTS.md. The agent reads it if its harness
supports the convention.

## Generation Checklist

When generating or updating project instructions:

- [ ] Directives routed to the correct file based on content type
- [ ] Managed markers used for safe re-generation
- [ ] Total instruction count stays under 30 across all files
- [ ] No duplication between CLAUDE.md and AGENTS.md
- [ ] Role-specific directives in coordinator-instructions.md, not AGENTS.md
