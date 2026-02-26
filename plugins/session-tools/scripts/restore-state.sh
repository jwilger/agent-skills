#!/usr/bin/env bash
# Restore session context on startup/resume.
# This hook runs during SessionStart to provide context.
set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"

MESSAGES=""

# Check for working state file
if [ -d "$PROJECT_DIR/.factory" ] && [ -f "$PROJECT_DIR/.factory/WORKING_STATE.md" ]; then
  MESSAGES="Factory pipeline detected. Read .factory/WORKING_STATE.md for current state. Re-read Controller Role Boundaries before taking any action."
elif [ -f "$PROJECT_DIR/WORKING_STATE.md" ]; then
  MESSAGES="Previous session state found. Read WORKING_STATE.md before taking any action."
fi

# Check for system prompt
if [ -f "$PROJECT_DIR/.claude/SYSTEM_PROMPT.md" ]; then
  MESSAGES="${MESSAGES:+$MESSAGES }System prompt found at .claude/SYSTEM_PROMPT.md — read it for project-specific corrections and role constraints."
fi

# Check for team directory
if [ -d "$PROJECT_DIR/.team" ]; then
  MESSAGES="${MESSAGES:+$MESSAGES }Ensemble team detected (.team/ directory). All creative work must go through named team members."
fi

# Check for memory files
if [ -f "$PROJECT_DIR/.claude/memory/MEMORY.md" ] || [ -f "$PROJECT_DIR/MEMORY.md" ]; then
  MESSAGES="${MESSAGES:+$MESSAGES }Memory files found — consult them for persistent learnings."
fi

if [ -n "$MESSAGES" ]; then
  # Escape for JSON
  MESSAGES_ESCAPED=$(echo "$MESSAGES" | sed 's/"/\\"/g' | tr '\n' ' ')
  echo "{\"systemMessage\": \"${MESSAGES_ESCAPED}\"}"
else
  echo '{}'
fi
