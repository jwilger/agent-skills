#!/usr/bin/env bash
# PreToolUse command hook for Edit|Write|NotebookEdit|Task|Bash.
# When an ensemble team is configured (.team/coordinator-instructions.md exists),
# blocks file edits, Task agent spawning, and shell commands until the team
# has been activated via TeamCreate.
# Marker is stored outside the git tree to avoid dirtying the working directory.
# Always exits 0 — uses JSON output for deny decisions per Claude Code docs.

set -euo pipefail

# No ensemble team configured: allow all
if [[ ! -f "$CLAUDE_PROJECT_DIR/.team/coordinator-instructions.md" ]]; then
  exit 0
fi

# Team already activated: allow (team members need these tools)
MARKER_DIR="${HOME}/.claude/ensemble-state"
MARKER_FILE="${MARKER_DIR}/${CLAUDE_PROJECT_DIR//\//__}"
if [[ -f "$MARKER_FILE" ]]; then
  exit 0
fi

# Ensemble team configured but not yet activated: deny
cat <<'EOF'
{"hookSpecificOutput": {"hookEventName": "PreToolUse", "permissionDecision": "deny", "permissionDecisionReason": "ENSEMBLE TEAM ENFORCEMENT: You are the coordinator. You MUST activate the ensemble team before doing ANY work — including spawning Task agents. Read .team/coordinator-instructions.md for your operating instructions, then use TeamCreate to launch named team members from .team/ profiles. Do NOT use the Task tool to spawn anonymous agents as a workaround. Do NOT use Bash to run commands. ALL work is delegated to named team members via TeamCreate."}}
EOF

exit 0
