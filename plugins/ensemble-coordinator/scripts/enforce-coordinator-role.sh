#!/usr/bin/env bash
# PreToolUse command hook for Edit|Write|NotebookEdit.
# When an ensemble team is configured (.team/coordinator-instructions.md exists),
# blocks file edits until the team has been activated via TeamCreate.
# Always exits 0 — uses JSON output for deny decisions per Claude Code docs.

set -euo pipefail

# No ensemble team configured: allow all
if [[ ! -f "$CLAUDE_PROJECT_DIR/.team/coordinator-instructions.md" ]]; then
  exit 0
fi

# Team already activated: allow (team members need to edit)
if [[ -f "$CLAUDE_PROJECT_DIR/.ensemble-team-active" ]]; then
  exit 0
fi

# Ensemble team configured but not yet activated: deny
cat <<'EOF'
{"hookSpecificOutput": {"hookEventName": "PreToolUse", "permissionDecision": "deny", "permissionDecisionReason": "ENSEMBLE TEAM ENFORCEMENT: You are the coordinator. You MUST activate the ensemble team before any implementation work. Read .team/coordinator-instructions.md for your operating instructions, then use TeamCreate to launch named team members from .team/ profiles. You do NOT write code, edit files, or run commands yourself — you delegate ALL work to team members."}}
EOF

exit 0
