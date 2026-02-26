#!/usr/bin/env bash
# Auto-save session state before context compaction.
# This hook runs during PreCompact to preserve working state.
set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"

# Determine the working state file location
if [ -d "$PROJECT_DIR/.factory" ]; then
  STATE_FILE="$PROJECT_DIR/.factory/WORKING_STATE.md"
else
  STATE_FILE="$PROJECT_DIR/WORKING_STATE.md"
fi

# If a working state file exists, add a compaction marker
if [ -f "$STATE_FILE" ]; then
  TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  # Append a compaction notice so the agent knows state was saved
  echo "" >> "$STATE_FILE"
  echo "---" >> "$STATE_FILE"
  echo "_State preserved before context compaction at ${TIMESTAMP}_" >> "$STATE_FILE"
fi

# Output success JSON
echo '{"continue": true, "systemMessage": "Session state saved. After compaction, re-read WORKING_STATE.md and role constraints before taking any action."}'
