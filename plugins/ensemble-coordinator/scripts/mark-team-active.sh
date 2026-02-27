#!/usr/bin/env bash
# PostToolUse command hook on TeamCreate.
# Writes ensemble-team-active marker file so the PreToolUse hook
# knows the team has been activated and team members may edit files.
# Marker is stored outside the git tree to avoid dirtying the working directory.
# Always exits 0.

set -euo pipefail

# Only write marker if an ensemble team is configured
if [[ -f "$CLAUDE_PROJECT_DIR/.team/coordinator-instructions.md" ]]; then
  MARKER_DIR="${HOME}/.claude/ensemble-state"
  mkdir -p "$MARKER_DIR"
  echo "ensemble-team-active" > "${MARKER_DIR}/${CLAUDE_PROJECT_DIR//\//__}"
fi

exit 0
