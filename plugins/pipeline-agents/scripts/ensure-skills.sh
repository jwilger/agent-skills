#!/usr/bin/env bash
# Verify required skills are installed and up to date; install or refresh as needed.
set -euo pipefail

PLUGIN_NAME="pipeline-agents"
REQUIRED_SKILLS=(tdd domain-modeling pipeline code-review mutation-testing task-management ci-integration debugging-protocol)

# --- Version detection ---
PLUGIN_JSON="${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json"
MARKER_FILE="skills/.agent-skills-version"
FORCE_REFRESH=false

if [[ -f "$PLUGIN_JSON" ]]; then
  PLUGIN_VERSION="$(grep '"version"' "$PLUGIN_JSON" | head -1 | sed 's/.*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')"
else
  PLUGIN_VERSION=""
fi

if [[ -n "$PLUGIN_VERSION" ]]; then
  if [[ ! -f "$MARKER_FILE" ]] || [[ "$(cat "$MARKER_FILE" | tr -d '[:space:]')" != "$PLUGIN_VERSION" ]]; then
    FORCE_REFRESH=true
  fi
fi

# --- Skill presence check ---
MISSING=()

for skill in "${REQUIRED_SKILLS[@]}"; do
  if ! ls skills/"${skill}"/SKILL.md >/dev/null 2>&1; then
    MISSING+=("$skill")
  fi
done

if [[ "$FORCE_REFRESH" == "false" ]] && [[ ${#MISSING[@]} -eq 0 ]]; then
  echo "{\"systemMessage\": \"${PLUGIN_NAME} plugin: all required skills present.\"}"
  exit 0
fi

# --- Install / refresh ---
INSTALL_ARGS=""
if [[ "$FORCE_REFRESH" == "true" ]]; then
  # Reinstall all required skills to pick up new versions
  for skill in "${REQUIRED_SKILLS[@]}"; do
    INSTALL_ARGS="${INSTALL_ARGS} --skill ${skill}"
  done
else
  # Only install missing skills
  for skill in "${MISSING[@]}"; do
    INSTALL_ARGS="${INSTALL_ARGS} --skill ${skill}"
  done
fi

echo "Installing skills: ${INSTALL_ARGS}" >&2
npx skills add jwilger/agent-skills ${INSTALL_ARGS} >&2 2>&1 || true

# Write version marker
if [[ -n "$PLUGIN_VERSION" ]]; then
  mkdir -p "$(dirname "$MARKER_FILE")"
  echo "$PLUGIN_VERSION" > "$MARKER_FILE"
fi

if [[ "$FORCE_REFRESH" == "true" ]]; then
  echo "{\"systemMessage\": \"${PLUGIN_NAME} plugin: skills refreshed to v${PLUGIN_VERSION}. Consider re-running /bootstrap to pick up any changes.\"}"
else
  echo "{\"systemMessage\": \"${PLUGIN_NAME} plugin auto-installed missing skills: ${MISSING[*]}. Verify they loaded correctly.\"}"
fi
