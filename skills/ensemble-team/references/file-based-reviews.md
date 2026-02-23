# File-Based Review Feedback

Structured review feedback written to disk. Survives context compaction and works on
harnesses that lack inter-agent messaging.

## Why Files Instead of Messages

In long-running multi-agent ensemble sessions, context compaction discards the content
of inter-agent messages. A Reviewer sends detailed feedback, the Driver's context
compacts, and the message body disappears. This triggers repeated request/re-send loops
that waste significant time and tokens.

Files on disk are immune to context compaction. By writing structured feedback to
`.reviews/`, the substantive content persists regardless of how many compaction cycles
occur. Messages remain useful for coordination ("review posted", "ready for re-review")
but no longer carry the authoritative feedback content.

This also provides a natural fallback for harnesses that have no inter-agent messaging
at all — Reviewers write files, the Driver reads them.

## Review Directory Convention

All review files live in `.reviews/` at the project root:

```
.reviews/
  kent-beck-user-registration.md
  sandi-metz-user-registration.md
  kent-beck-user-registration-pass2.md
```

Add `.reviews/` to `.gitignore`. Review files are ephemeral working artifacts, not
version-controlled deliverables.

## File Naming

```
<reviewer-name>-<task-slug>.md
<reviewer-name>-<task-slug>-pass<N>.md   (re-reviews)
```

- `reviewer-name`: Kebab-case name matching the `.team/` profile filename (without extension)
- `task-slug`: Kebab-case short description of the task under review
- `pass<N>`: Appended for re-review passes (pass2, pass3, etc.)

Examples:
- `kent-beck-login-flow.md` — first review
- `kent-beck-login-flow-pass2.md` — re-review after fixes

## Review File Format

```markdown
# Review: [Task Name]

- **Reviewer**: [Full Name]
- **Date**: [YYYY-MM-DD]
- **Task**: [Task reference or description]
- **Pass**: 1

## Findings

### 1. [Short description]
- **Status**: NEEDS-FIX | APPROVED | QUESTION
- **Location**: `src/auth/login.ts:42-58`
- **Detail**: [Explanation of the issue, question, or approval note]

### 2. [Short description]
- **Status**: NEEDS-FIX
- **Location**: `src/auth/login.ts:15-20`
- **Detail**: [Explanation]

## Verdict

**CHANGES-REQUESTED**

[One-sentence summary of what needs to happen before approval.]

---
Signed: [Full Name], [Role]
```

### Status Values

| Status | Meaning |
|--------|---------|
| `NEEDS-FIX` | Blocking — must be addressed before approval |
| `APPROVED` | This aspect looks good |
| `QUESTION` | Non-blocking — needs clarification but does not block |

### Verdict Values

| Verdict | Meaning |
|---------|---------|
| `APPROVED` | No issues found, ready to proceed |
| `APPROVED-WITH-NOTES` | Minor non-blocking notes, may proceed |
| `CHANGES-REQUESTED` | Blocking issues exist, must be addressed |

## Re-Review Protocol

When the Driver addresses feedback and requests re-review:

1. The Reviewer reads their previous review file (e.g., `kent-beck-login-flow.md`)
2. The Reviewer creates a new file with incremented pass number (e.g., `kent-beck-login-flow-pass2.md`)
3. In the new file, reference each previous `NEEDS-FIX` item and mark it `APPROVED` (fixed) or `NEEDS-FIX` (still open)
4. Add any new findings discovered during re-review
5. Update the verdict

Previous review files are kept for audit trail — do not overwrite them.

## Workflow

### Variant 1: Messaging Available (Claude Code TeamCreate, Task tool)

1. Reviewer reads the code under review
2. Reviewer writes structured review to `.reviews/<name>-<task>.md`
3. Reviewer sends a **one-line summary message** to the Driver:
   `"Review posted to .reviews/<name>-<task>.md — verdict: CHANGES-REQUESTED (2 blocking items)"`
4. Driver reads the `.reviews/` file for full feedback
5. Driver addresses findings, then messages Reviewers when ready for re-review
6. Reviewers write re-review files with incremented pass number

### Variant 2: Messaging Unavailable (Cursor, Windsurf, generic harnesses)

1. Reviewer reads the code under review
2. Reviewer writes structured review to `.reviews/<name>-<task>.md`
3. Driver polls `.reviews/` for files matching the current task slug
4. Driver addresses findings
5. Driver creates a signal file: `.reviews/ready-for-rereview-<task>.md` with a brief note
6. Reviewers poll for the signal file, then write re-review files

## Harness Compatibility

| Harness | Messaging | Review Mode | Notes |
|---------|-----------|-------------|-------|
| Claude Code (TeamCreate) | Yes | Files + messages | Full workflow — files for content, messages for coordination |
| Claude Code (Task tool) | Yes | Files + messages | Subagents write files, return summary via Task result |
| Codex | Limited | Files + messages | CLI agents can write files; coordination via task descriptions |
| Cursor | No | Files only | Reviewers write files; Driver polls `.reviews/` |
| Windsurf | No | Files only | Same as Cursor |
| OpenCode | Limited | Files + messages | Depends on configured agent communication |
| Generic | Varies | Files only (safe default) | File-based mode works on any harness that supports file writes |

## Permission Scoping

Reviewers need write access to `.reviews/` only — not the full project tree.

### Claude Code

Add scoped write permission for Reviewers in `.claude/settings.json`:

```json
{
  "permissions": {
    "allow": ["Write(.reviews/*)"]
  }
}
```

This grants Reviewers write access to the review directory without granting project-wide
file editing.

### Other Harnesses

Use the narrowest available permission scope. If the harness supports path-based
permissions, scope to `.reviews/`. If not, document the limitation and rely on the
Reviewer's activation prompt instructions to restrict writes to `.reviews/` only.

## Anti-Patterns

- **Substantive reviews in messages only**: Messages get compacted. Always write the
  full review to a file; messages are for coordination only.
- **Skipping structured format**: Unstructured feedback is harder to address
  systematically. Use the numbered findings format with status values.
- **Not tracking re-review passes**: Without pass numbers, it's unclear whether a
  finding was addressed. Always increment the pass number and reference prior findings.
- **Version-controlling review files**: Review files are ephemeral working artifacts.
  Add `.reviews/` to `.gitignore`. They should not appear in commits or PRs.
- **Coordinator managing review files**: Review file creation and reading belongs to
  teammates (Reviewers and Driver). The coordinator coordinates sessions, not file I/O.
