#!/usr/bin/env bash
# PostToolUse command hook on TeamCreate.
# Writes .ensemble-team-active marker file so the PreToolUse hook
# knows the team has been activated and team members may edit files.
# Always exits 0.

set -euo pipefail

# Only write marker if an ensemble team is configured
if [[ -f "$CLAUDE_PROJECT_DIR/.team/coordinator-instructions.md" ]]; then
  echo "ensemble-team-active" > "$CLAUDE_PROJECT_DIR/.ensemble-team-active"
fi

exit 0
