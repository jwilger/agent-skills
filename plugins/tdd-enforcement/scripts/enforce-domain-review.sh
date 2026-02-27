#!/usr/bin/env bash
# PostToolUse command hook on Task matcher.
# After any Task tool completion, reads .tdd-phase and prompts
# the orchestrator to run domain review if in red or green phase.
# Always exits 0.

set -euo pipefail

PHASE_FILE="$CLAUDE_PROJECT_DIR/.tdd-phase"

# No phase file: nothing to enforce
if [[ ! -f "$PHASE_FILE" ]]; then
  exit 0
fi

PHASE="$(cat "$PHASE_FILE" | tr -d '[:space:]')"

case "$PHASE" in
  red)
    echo '{"decision": "block", "reason": "TDD ENFORCEMENT: RED phase complete. Domain review is MANDATORY next. Write '\''domain-after-red'\'' to .tdd-phase and spawn the domain reviewer before proceeding to GREEN."}'
    ;;
  green)
    echo '{"decision": "block", "reason": "TDD ENFORCEMENT: GREEN phase complete. Domain review is MANDATORY next. Write '\''domain-after-green'\'' to .tdd-phase and spawn the domain reviewer before proceeding to COMMIT."}'
    ;;
  *)
    # All other phases: no enforcement needed
    ;;
esac

exit 0
