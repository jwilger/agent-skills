#!/usr/bin/env bash
# Verify that SKILL.md files stay within their tier token budgets.
# Token estimation: ~4 characters per token (conservative).
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# Define tier budgets (tokens)
declare -A TIER_BUDGETS
TIER_BUDGETS[bootstrap]=1000
TIER_BUDGETS[tdd]=3000
TIER_BUDGETS[domain-modeling]=3000
TIER_BUDGETS[code-review]=3000
TIER_BUDGETS[architecture-decisions]=3000
TIER_BUDGETS[event-modeling]=3000
TIER_BUDGETS[design-system]=3000
TIER_BUDGETS[ticket-triage]=3000
TIER_BUDGETS[refactoring]=3000
TIER_BUDGETS[pr-ship]=3000
TIER_BUDGETS[ensemble-team]=4000
TIER_BUDGETS[task-management]=4000
TIER_BUDGETS[debugging-protocol]=3000
TIER_BUDGETS[user-input-protocol]=3000
TIER_BUDGETS[memory-protocol]=3000
TIER_BUDGETS[agent-coordination]=3000
TIER_BUDGETS[session-reflection]=3000
TIER_BUDGETS[error-recovery]=3000
TIER_BUDGETS[pipeline]=3000
TIER_BUDGETS[ci-integration]=3000
TIER_BUDGETS[factory-review]=3000
TIER_BUDGETS[mutation-testing]=3000
TIER_BUDGETS[atomic-design]=3000

ERRORS=0
WARNINGS=0

echo "=== Skill Token Budget Verification ==="
echo ""

for SKILL_DIR in "${REPO_ROOT}"/skills/*/; do
  SKILL_NAME=$(basename "$SKILL_DIR")
  SKILL_FILE="${SKILL_DIR}SKILL.md"

  # Skip template directory
  if [[ "$SKILL_NAME" == ".template" ]]; then
    continue
  fi

  if [[ ! -f "$SKILL_FILE" ]]; then
    echo "WARNING: ${SKILL_NAME} has no SKILL.md"
    WARNINGS=$((WARNINGS + 1))
    continue
  fi

  # Extract body (everything after frontmatter closing ---)
  BODY=$(sed -n '/^---$/,/^---$/d; p' "$SKILL_FILE" | tail -n +1)
  CHAR_COUNT=${#BODY}
  TOKEN_ESTIMATE=$((CHAR_COUNT / 4))
  LINE_COUNT=$(wc -l < "$SKILL_FILE")

  BUDGET=${TIER_BUDGETS[$SKILL_NAME]:-3000}
  THRESHOLD_90=$((BUDGET * 90 / 100))

  if [[ $TOKEN_ESTIMATE -gt $BUDGET ]]; then
    echo "FAIL: ${SKILL_NAME} (~${TOKEN_ESTIMATE} tokens, ${LINE_COUNT} lines) exceeds budget of ${BUDGET} tokens"
    ERRORS=$((ERRORS + 1))
  elif [[ $TOKEN_ESTIMATE -gt $THRESHOLD_90 ]]; then
    echo "WARN: ${SKILL_NAME} (~${TOKEN_ESTIMATE} tokens, ${LINE_COUNT} lines) at ${TOKEN_ESTIMATE}/${BUDGET} (>90%)"
    WARNINGS=$((WARNINGS + 1))
  else
    echo "  OK: ${SKILL_NAME} (~${TOKEN_ESTIMATE} tokens, ${LINE_COUNT} lines)"
  fi

  if [[ $LINE_COUNT -gt 500 ]]; then
    echo "FAIL: ${SKILL_NAME} has ${LINE_COUNT} lines (max 500)"
    ERRORS=$((ERRORS + 1))
  fi
done

echo ""
echo "=== Summary ==="
echo "Errors: ${ERRORS}"
echo "Warnings: ${WARNINGS}"

if [[ $ERRORS -gt 0 ]]; then
  exit 1
fi
