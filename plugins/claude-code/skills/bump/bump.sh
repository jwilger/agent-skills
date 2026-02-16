#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <old_version> <new_version>" >&2
  exit 1
fi

OLD_VERSION="$1"
NEW_VERSION="$2"

# Calculate repo root: this script lives at plugins/claude-code/skills/bump/
REPO_ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"

echo "Bumping version: ${OLD_VERSION} -> ${NEW_VERSION}"
echo "Repo root: ${REPO_ROOT}"
echo ""

# --- JSON files: global replacement of "version": "OLD" -> "version": "NEW" ---

echo "Updating .claude-plugin/marketplace.json ..."
sed -i "s/\"version\": \"${OLD_VERSION}\"/\"version\": \"${NEW_VERSION}\"/g" \
  "${REPO_ROOT}/.claude-plugin/marketplace.json"

echo "Updating plugins/claude-code/.claude-plugin/plugin.json ..."
sed -i "s/\"version\": \"${OLD_VERSION}\"/\"version\": \"${NEW_VERSION}\"/g" \
  "${REPO_ROOT}/plugins/claude-code/.claude-plugin/plugin.json"

# --- YAML files: replace version on line 1 only ---

YAML_FILES=(
  "plugins/goose/recipes/pr-workflow.yaml"
  "plugins/goose/recipes/code-review.yaml"
  "plugins/goose/recipes/tdd-cycle.yaml"
  "plugins/goose/recipes/event-modeling.yaml"
)

for yaml_file in "${YAML_FILES[@]}"; do
  echo "Updating ${yaml_file} ..."
  sed -i "1s/version: \"${OLD_VERSION}\"/version: \"${NEW_VERSION}\"/" \
    "${REPO_ROOT}/${yaml_file}"
done

# --- Verification ---

echo ""
echo "=== Verification: grepping for new version ${NEW_VERSION} ==="

ALL_FILES=(
  ".claude-plugin/marketplace.json"
  "plugins/claude-code/.claude-plugin/plugin.json"
  "${YAML_FILES[@]}"
)

TOTAL=0
for f in "${ALL_FILES[@]}"; do
  COUNT=$(grep -c "\"${NEW_VERSION}\"" "${REPO_ROOT}/${f}" 2>/dev/null || \
          grep -c "\"${NEW_VERSION}\"" "${REPO_ROOT}/${f}" 2>/dev/null || echo "0")
  echo "  ${f}: ${COUNT} occurrence(s)"
  TOTAL=$((TOTAL + COUNT))
done

echo ""
echo "Total occurrences of ${NEW_VERSION}: ${TOTAL}"
echo "Expected: 7"

if [[ "${TOTAL}" -ne 7 ]]; then
  echo "WARNING: Expected 7 occurrences but found ${TOTAL}" >&2
  exit 1
fi

echo "Version bump complete."
