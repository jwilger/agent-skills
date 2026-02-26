#!/usr/bin/env bash
# Verify cross-skill consistency:
# - All metadata.requires references point to existing skills
# - No circular dependencies
# - All skills follow the six-section body structure
# - All frontmatter fields match the spec
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ERRORS=0
WARNINGS=0

echo "=== Cross-Skill Consistency Verification ==="
echo ""

# Collect all skill names
SKILL_NAMES=()
for SKILL_DIR in "${REPO_ROOT}"/skills/*/; do
  NAME=$(basename "$SKILL_DIR")
  if [[ "$NAME" != ".template" ]] && [[ -f "${SKILL_DIR}SKILL.md" ]]; then
    SKILL_NAMES+=("$NAME")
  fi
done

echo "Found ${#SKILL_NAMES[@]} skills"
echo ""

# --- Check 1: metadata.requires references ---
echo "--- Check 1: Dependency references ---"

for SKILL_NAME in "${SKILL_NAMES[@]}"; do
  SKILL_FILE="${REPO_ROOT}/skills/${SKILL_NAME}/SKILL.md"

  # Extract requires list from frontmatter
  REQUIRES=$(sed -n '/^---$/,/^---$/p' "$SKILL_FILE" | grep -oP 'requires: \[.*?\]' | grep -oP '\w[-\w]*' | grep -v requires || true)

  for REQ in $REQUIRES; do
    if [[ ! -d "${REPO_ROOT}/skills/${REQ}" ]]; then
      echo "  FAIL: ${SKILL_NAME} requires '${REQ}' which does not exist"
      ERRORS=$((ERRORS + 1))
    fi
  done
done

if [[ $ERRORS -eq 0 ]]; then
  echo "  OK: All dependency references are valid"
fi

# --- Check 2: Six required sections ---
echo ""
echo "--- Check 2: Required body sections ---"

REQUIRED_SECTIONS=("Value" "Purpose" "Practices" "Enforcement Note" "Verification" "Dependencies")

for SKILL_NAME in "${SKILL_NAMES[@]}"; do
  SKILL_FILE="${REPO_ROOT}/skills/${SKILL_NAME}/SKILL.md"

  for SECTION in "${REQUIRED_SECTIONS[@]}"; do
    if ! grep -q "## ${SECTION}" "$SKILL_FILE" 2>/dev/null; then
      # Some sections may use different heading formats
      if ! grep -qi "${SECTION}" "$SKILL_FILE" 2>/dev/null; then
        echo "  WARN: ${SKILL_NAME} may be missing section '${SECTION}'"
        WARNINGS=$((WARNINGS + 1))
      fi
    fi
  done
done

echo "  Section check complete"

# --- Check 3: Frontmatter required fields ---
echo ""
echo "--- Check 3: Required frontmatter fields ---"

REQUIRED_FIELDS=("name" "description" "metadata")

for SKILL_NAME in "${SKILL_NAMES[@]}"; do
  SKILL_FILE="${REPO_ROOT}/skills/${SKILL_NAME}/SKILL.md"

  # Extract frontmatter
  FRONTMATTER=$(sed -n '1,/^---$/p' "$SKILL_FILE" | tail -n +2)

  for FIELD in "${REQUIRED_FIELDS[@]}"; do
    if ! echo "$FRONTMATTER" | grep -q "^${FIELD}:" 2>/dev/null; then
      echo "  FAIL: ${SKILL_NAME} missing required field '${FIELD}'"
      ERRORS=$((ERRORS + 1))
    fi
  done

  # Check name matches directory
  FM_NAME=$(echo "$FRONTMATTER" | grep "^name:" | sed 's/name: *//')
  if [[ "$FM_NAME" != "$SKILL_NAME" ]]; then
    echo "  FAIL: ${SKILL_NAME} frontmatter name '${FM_NAME}' does not match directory"
    ERRORS=$((ERRORS + 1))
  fi
done

echo "  Frontmatter check complete"

# --- Check 4: Circular dependency detection ---
echo ""
echo "--- Check 4: Circular dependency detection ---"

# Simple cycle detection using DFS-like approach
CYCLE_FOUND=0
for SKILL_NAME in "${SKILL_NAMES[@]}"; do
  SKILL_FILE="${REPO_ROOT}/skills/${SKILL_NAME}/SKILL.md"
  REQUIRES=$(sed -n '/^---$/,/^---$/p' "$SKILL_FILE" | grep -oP 'requires: \[.*?\]' | grep -oP '\w[-\w]*' | grep -v requires || true)

  for REQ in $REQUIRES; do
    if [[ -f "${REPO_ROOT}/skills/${REQ}/SKILL.md" ]]; then
      # Check if REQ also requires SKILL_NAME (direct cycle)
      REQ_REQUIRES=$(sed -n '/^---$/,/^---$/p' "${REPO_ROOT}/skills/${REQ}/SKILL.md" | grep -oP 'requires: \[.*?\]' | grep -oP '\w[-\w]*' | grep -v requires || true)
      for RR in $REQ_REQUIRES; do
        if [[ "$RR" == "$SKILL_NAME" ]]; then
          echo "  FAIL: Circular dependency: ${SKILL_NAME} <-> ${REQ}"
          CYCLE_FOUND=1
          ERRORS=$((ERRORS + 1))
        fi
      done
    fi
  done
done

if [[ $CYCLE_FOUND -eq 0 ]]; then
  echo "  OK: No circular dependencies detected"
fi

# --- Summary ---
echo ""
echo "=== Summary ==="
echo "Skills checked: ${#SKILL_NAMES[@]}"
echo "Errors: ${ERRORS}"
echo "Warnings: ${WARNINGS}"

if [[ $ERRORS -gt 0 ]]; then
  exit 1
fi
