#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <old_version> <new_version>" >&2
  exit 1
fi

OLD_VERSION="$1"
NEW_VERSION="$2"

# Calculate repo root: this script lives at .claude/skills/bump/
REPO_ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"

echo "Bumping version: ${OLD_VERSION} -> ${NEW_VERSION}"
echo "Repo root: ${REPO_ROOT}"
echo ""

# --- VERSION file: single source of truth for project version ---

VERSION_FILE="${REPO_ROOT}/VERSION"

echo "Updating VERSION file ..."
echo "${NEW_VERSION}" > "${VERSION_FILE}"

# --- Verification ---

echo ""
echo "=== Verification ==="

ACTUAL=$(cat "${VERSION_FILE}")
echo "  VERSION file: ${ACTUAL}"

if [[ "${ACTUAL}" != "${NEW_VERSION}" ]]; then
  echo "WARNING: VERSION file does not contain expected version" >&2
  exit 1
fi

echo ""
echo "Version bump complete."
