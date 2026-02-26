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

# --- Plugin marketplace version (if present) ---

MARKETPLACE_FILE="${REPO_ROOT}/.claude-plugin/marketplace.json"

if [[ -f "${MARKETPLACE_FILE}" ]]; then
  echo "Updating marketplace manifest version ..."
  # Use sed to update the metadata.version field
  sed -i "s/\"version\": \"${OLD_VERSION}\"/\"version\": \"${NEW_VERSION}\"/g" "${MARKETPLACE_FILE}"
  # Also update the marketplace metadata version even if it differs from OLD_VERSION
  # This ensures the marketplace metadata.version always matches the project version
  sed -i "s/\"version\": \"[0-9]*\.[0-9]*\.[0-9]*\"/\"version\": \"${NEW_VERSION}\"/g" "${MARKETPLACE_FILE}"
fi

# --- Individual plugin versions (if present) ---

PLUGIN_DIR="${REPO_ROOT}/plugins"

if [[ -d "${PLUGIN_DIR}" ]]; then
  echo "Updating plugin versions ..."
  for PLUGIN_JSON in "${PLUGIN_DIR}"/*/.claude-plugin/plugin.json; do
    if [[ -f "${PLUGIN_JSON}" ]]; then
      PLUGIN_NAME=$(basename "$(dirname "$(dirname "${PLUGIN_JSON}")")")
      sed -i "s/\"version\": \"[0-9]*\.[0-9]*\.[0-9]*\"/\"version\": \"${NEW_VERSION}\"/g" "${PLUGIN_JSON}"
      echo "  Updated: ${PLUGIN_NAME}"
    fi
  done

  # Also update plugin versions in the marketplace manifest plugin entries
  if [[ -f "${MARKETPLACE_FILE}" ]]; then
    echo "  (marketplace plugin entries updated with marketplace manifest)"
  fi
fi

# --- Verification ---

echo ""
echo "=== Verification ==="

ACTUAL=$(cat "${VERSION_FILE}")
echo "  VERSION file: ${ACTUAL}"

if [[ "${ACTUAL}" != "${NEW_VERSION}" ]]; then
  echo "WARNING: VERSION file does not contain expected version" >&2
  exit 1
fi

if [[ -f "${MARKETPLACE_FILE}" ]]; then
  MP_VERSION=$(grep -o '"version": "[^"]*"' "${MARKETPLACE_FILE}" | head -1 | sed 's/"version": "//;s/"//')
  echo "  Marketplace version: ${MP_VERSION}"
fi

if [[ -d "${PLUGIN_DIR}" ]]; then
  for PLUGIN_JSON in "${PLUGIN_DIR}"/*/.claude-plugin/plugin.json; do
    if [[ -f "${PLUGIN_JSON}" ]]; then
      PLUGIN_NAME=$(basename "$(dirname "$(dirname "${PLUGIN_JSON}")")")
      PV=$(grep -o '"version": "[^"]*"' "${PLUGIN_JSON}" | head -1 | sed 's/"version": "//;s/"//')
      echo "  Plugin ${PLUGIN_NAME}: ${PV}"
    fi
  done
fi

echo ""
echo "Version bump complete."
