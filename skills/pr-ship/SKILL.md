---
name: pr-ship
description: >-
  Pull request creation and merge workflow. PR title/body templates,
  conventional commit guidance, review checklist summary, merge strategy
  selection. Activate when code review passes and work is ready to ship.
  Triggers on: "create PR", "ship it", "merge", "open pull request",
  "ready to merge".
license: CC0-1.0
metadata:
  author: jwilger
  version: "1.0"
  requires: []
  context: [git-history, ci-results]
  phase: ship
  standalone: true
---

# PR/Ship

**Value:** Communication -- a well-crafted PR tells reviewers what changed,
why it changed, and how to verify it. Sloppy PRs waste reviewer time and
hide risk.

## Purpose

Bridges the gap between "code review passes" and "code is merged." Teaches
PR description writing, commit hygiene, merge strategy selection, and
post-merge verification. Prevents the common failure modes of empty PR
bodies, unclear change descriptions, and forgotten post-merge steps.

## Practices

### PR Title

Keep the title under 70 characters. Use imperative mood ("Add login
endpoint", not "Added login endpoint"). The title should be a complete
thought -- a reviewer reading only the title should understand the scope.

**Format:** `<type>: <description>`

Types: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `ci`

**Examples:**
- `feat: Add user authentication via OAuth2`
- `fix: Prevent duplicate event processing`
- `refactor: Extract payment validation into domain type`

### PR Body Template

Every PR body follows this structure:

```markdown
## Summary
[1-3 bullet points describing WHAT changed and WHY]

## Changes
[Bullet list of specific changes, grouped by area]

## Test Plan
[How to verify this works -- what tests cover it, what to check manually]

## Related
[Links to issues, ADRs, event model entries, or prior PRs]
```

A PR with an empty or one-line body is a protocol violation. The body
is the decision record for code changes -- it explains the reasoning
that the diff cannot.

### Commit Hygiene

Before creating the PR, review the commit history on the branch:

1. **Are commits atomic?** Each commit should represent one logical change.
   If a commit mixes refactoring with feature work, consider interactive
   rebase to separate them.
2. **Are commit messages clear?** Each message should explain what and why.
   "Fix stuff" and "WIP" are not acceptable in the final history.
3. **Is the history linear?** Prefer rebase over merge commits for feature
   branches to keep history clean.

**Squash decision:** Squash when the intermediate commits add noise
(multiple "fix typo" or "address review" commits). Keep separate commits
when each represents a meaningful, reviewable step. When in doubt, ask
the team's convention from `AGENTS.md`.

### Merge Strategy

Select based on project conventions (check `AGENTS.md`):

| Strategy | When to Use |
|----------|------------|
| Squash and merge | Feature branches with messy history |
| Rebase and merge | Feature branches with clean, atomic commits |
| Merge commit | Long-lived branches or when preserving branch history matters |

If the project uses a stacking workflow (git-spice, Graphite, etc.),
follow the tool's merge conventions. Do not manually merge stacked PRs.

### Pre-Merge Checklist

Before merging, verify ALL of the following:

- [ ] CI pipeline is green on the latest commit
- [ ] All review comments are resolved (not just acknowledged)
- [ ] PR title follows the type: description format
- [ ] PR body has Summary, Changes, Test Plan sections
- [ ] Branch is up to date with the target branch
- [ ] No merge conflicts exist
- [ ] Required approvals are present

### Post-Merge Steps

After merging:

1. Delete the feature branch (unless the project convention says otherwise)
2. Verify CI passes on the target branch after merge
3. If the project has a changelog, update it
4. If the merge closes an issue, verify it was automatically closed

### Pipeline Integration

When running in factory pipeline mode, the pipeline controller handles
merge decisions based on autonomy level:

- **Conservative:** Pipeline creates the PR, human merges
- **Standard:** Pipeline creates the PR and merges after all gates pass,
  human reviews asynchronously
- **Full:** Pipeline auto-merges when all gates pass, no human in the loop
  for merge

The PR body is still required at all autonomy levels -- it serves as the
audit trail even when merge is automatic.

## Enforcement Note

This skill provides advisory guidance. It instructs the agent to create
well-structured PRs with complete descriptions and follow merge conventions.
On harnesses with CI integration, the CI pipeline provides structural
enforcement for test passing and branch currency. The PR body template
is advisory -- no mechanism prevents empty PR descriptions. If you observe
an agent creating a PR with a missing or inadequate description, point it
out.

## Verification

After completing work guided by this skill, verify:

- [ ] PR title is under 70 characters and uses type: description format
- [ ] PR body contains Summary, Changes, and Test Plan sections
- [ ] All review comments are resolved before merge
- [ ] CI is green on the PR branch
- [ ] Merge strategy matches project conventions
- [ ] Feature branch deleted after merge (if applicable)
- [ ] Post-merge CI passes on target branch

If any criterion is not met, address it before considering the work shipped.

## Dependencies

This skill works standalone. For enhanced workflows, it integrates with:

- **code-review:** Review findings must be addressed before PR is ready
  to ship
- **ci-integration:** CI results inform the pre-merge checklist
- **pipeline:** The pipeline controller uses this skill's PR template
  when creating PRs in factory mode

Missing a dependency? Install with:
```
npx skills add jwilger/agent-skills --skill code-review
```
