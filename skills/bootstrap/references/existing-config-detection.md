# Existing Configuration Detection

Before running bootstrap, check for existing project configuration to avoid
overwriting user-authored content.

## Detection Checks

```
!test -f AGENTS.md && echo "AGENTS.md exists" || true
!test -f CLAUDE.md && echo "CLAUDE.md exists" || true
!test -d .factory && echo ".factory/ exists" || true
!test -d .team && echo ".team/ exists" || true
```

## Managed Markers

When existing configuration is detected, look for managed markers:

```markdown
<!-- BEGIN MANAGED -->
... auto-generated content ...
<!-- END MANAGED -->
```

**Rules:**
- Replace only content between managed markers
- Never touch content outside managed markers
- If no managed markers exist, offer to add them (wrapping the existing
  content in managed markers) or append new content after existing content
- Always show the user what will change and confirm before writing

## Update vs Overwrite Decision

| Detected File | Action |
|---------------|--------|
| AGENTS.md with managed markers | Replace managed section only |
| AGENTS.md without markers | Ask: update in place or create backup? |
| CLAUDE.md with managed markers | Replace managed section only |
| CLAUDE.md without markers | Ask: add managed section or skip? |
| .factory/ directory | Preserve existing pipeline state; update config only |
| .team/ directory | Preserve existing team; offer to re-run formation |

## Batch Installation

After the user confirms their skill choices, offer to run the install
commands in sequence. Present the full list of commands and ask for
confirmation before executing:

```
The following skills will be installed:
  npx skills add jwilger/agent-skills --skill tdd
  npx skills add jwilger/agent-skills --skill domain-modeling
  npx skills add jwilger/agent-skills --skill code-review
Proceed? [y/N]
```

Still require explicit confirmation, but batch the operations to reduce
friction. Never auto-install without user approval.
