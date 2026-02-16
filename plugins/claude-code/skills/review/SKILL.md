---
description: INVOKE when PR has review comments to address
user-invocable: true
context: fork
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Task
---

# Review

Handle PR review feedback. Fetches pending comments, addresses each one
through the appropriate agent, and replies in-thread.

## Methodology

Follows `skills/code-review/SKILL.md` for review handling.
Follows `skills/orchestration/SKILL.md` for agent delegation.

## Steps

1. Detect current PR (`gh pr view --json number,url,reviewDecision`)
2. Fetch unresolved threads (`gh pr-review review view --unresolved`)
3. Display comments organized by file
4. Address each comment:
   - Test changes -> red agent
   - Implementation changes -> green agent
   - Type changes -> domain agent
5. Reply in-thread via `gh pr-review comments reply`
6. Commit and push changes
7. Request re-review

## Error Handling

- No PR -> direct to `/pr`
- No pending comments -> "PR is ready for merge!"
- API errors -> suggest manual review via GitHub
