#!/usr/bin/env bash
# PreToolUse command hook for Edit|Write.
# Reads .tdd-phase state file + file_path from stdin JSON.
# Outputs JSON deny decision or nothing (allow).
# Always exits 0 — uses JSON output for decisions per Claude Code docs.

set -euo pipefail

PHASE_FILE="$CLAUDE_PROJECT_DIR/.tdd-phase"

# Graceful degradation: if phase file missing, allow all
if [[ ! -f "$PHASE_FILE" ]]; then
  exit 0
fi

PHASE="$(cat "$PHASE_FILE" | tr -d '[:space:]')"

# Unknown or empty phase: allow all
if [[ -z "$PHASE" ]]; then
  exit 0
fi

# Read stdin (hook input JSON) and extract file_path via jq
INPUT="$(cat)"

if ! command -v jq >/dev/null 2>&1; then
  echo "Warning: jq not installed, skipping TDD phase enforcement" >&2
  exit 0
fi

FILE_PATH="$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.filePath // empty' 2>/dev/null || true)"

if [[ -z "$FILE_PATH" ]]; then
  # Can't determine file path, allow
  exit 0
fi

# Determine if the file is a test file by path patterns
is_test_file() {
  local path="$1"
  case "$path" in
    */tests/*|*/__tests__/*|*/spec/*|*/test/*) return 0 ;;
  esac
  local basename="${path##*/}"
  case "$basename" in
    *_test.*|*.test.*|test_*.*|*_spec.*|*.spec.*) return 0 ;;
  esac
  return 1
}

deny() {
  local reason="$1"
  cat <<EOF
{"hookSpecificOutput": {"hookEventName": "PreToolUse", "permissionDecision": "deny", "permissionDecisionReason": "$reason"}}
EOF
  exit 0
}

case "$PHASE" in
  red)
    # RED: allow only test files
    if ! is_test_file "$FILE_PATH"; then
      deny "TDD ENFORCEMENT: RED phase — only test files may be edited. This file is not a test file."
    fi
    ;;
  green)
    # GREEN: block test files, allow everything else
    if is_test_file "$FILE_PATH"; then
      deny "TDD ENFORCEMENT: GREEN phase — test files may not be edited. Only production code is allowed."
    fi
    ;;
  domain-after-red|domain-after-green)
    # DOMAIN: block test files, allow everything else
    # (content-level "type definitions only" stays advisory)
    if is_test_file "$FILE_PATH"; then
      deny "TDD ENFORCEMENT: DOMAIN phase — test files may not be edited. Only type definitions are allowed."
    fi
    ;;
  commit)
    # COMMIT: block all edits
    deny "TDD ENFORCEMENT: COMMIT phase — no file edits allowed. Only git operations permitted."
    ;;
  *)
    # Unknown phase: allow all (graceful degradation)
    ;;
esac

# If we get here, allow the edit (exit 0 with no output)
exit 0
