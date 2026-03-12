#!/usr/bin/env bash
# manifest_parser.sh — jq-based helpers to read benchmark/manifest.json

set -euo pipefail

MANIFEST="${BENCHMARK_DIR}/manifest.json"

# List all skill names
manifest_skills() {
  jq -r '.skills[].name' "$MANIFEST"
}

# List test case IDs for a skill
manifest_test_cases() {
  local skill="$1"
  jq -r --arg s "$skill" '.skills[] | select(.name == $s) | .test_cases[].id' "$MANIFEST"
}

# Get the skill file path for a skill
manifest_skill_file() {
  local skill="$1"
  jq -r --arg s "$skill" '.skills[] | select(.name == $s) | .skill_file' "$MANIFEST"
}

# Get prompt for a test case
manifest_prompt() {
  local skill="$1" test_id="$2"
  jq -r --arg s "$skill" --arg t "$test_id" \
    '.skills[] | select(.name == $s) | .test_cases[] | select(.id == $t) | .prompt' "$MANIFEST"
}

# Get working_dir for a test case
manifest_working_dir() {
  local skill="$1" test_id="$2"
  jq -r --arg s "$skill" --arg t "$test_id" \
    '.skills[] | select(.name == $s) | .test_cases[] | select(.id == $t) | .working_dir' "$MANIFEST"
}

# Get assertions as newline-separated list
manifest_assertions() {
  local skill="$1" test_id="$2"
  jq -r --arg s "$skill" --arg t "$test_id" \
    '.skills[] | select(.name == $s) | .test_cases[] | select(.id == $t) | .assertions[]' "$MANIFEST"
}

# Get assertion count
manifest_assertion_count() {
  local skill="$1" test_id="$2"
  jq --arg s "$skill" --arg t "$test_id" \
    '.skills[] | select(.name == $s) | .test_cases[] | select(.id == $t) | .assertions | length' "$MANIFEST"
}

# Get total test case count across all skills
manifest_total_test_cases() {
  jq '[.skills[].test_cases | length] | add' "$MANIFEST"
}
