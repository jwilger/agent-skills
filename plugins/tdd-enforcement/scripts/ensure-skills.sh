#!/usr/bin/env bash
# Verify required skills are installed; install missing ones.
set -euo pipefail

REQUIRED_SKILLS=(tdd domain-modeling)
MISSING=()

for skill in "${REQUIRED_SKILLS[@]}"; do
  if ! ls skills/"${skill}"/SKILL.md >/dev/null 2>&1; then
    MISSING+=("$skill")
  fi
done

if [[ ${#MISSING[@]} -eq 0 ]]; then
  echo '{"systemMessage": "tdd-enforcement plugin: all required skills present."}'
  exit 0
fi

INSTALL_ARGS=""
for skill in "${MISSING[@]}"; do
  INSTALL_ARGS="${INSTALL_ARGS} --skill ${skill}"
done

echo "Installing missing skills: ${MISSING[*]}" >&2
npx skills add jwilger/agent-skills ${INSTALL_ARGS} >&2 2>&1 || true

echo "{\"systemMessage\": \"tdd-enforcement plugin auto-installed missing skills: ${MISSING[*]}. Verify they loaded correctly.\"}"
