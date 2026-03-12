#!/usr/bin/env bash
# codex_runner.sh — run a single Codex CLI benchmark invocation with full isolation

set -euo pipefail

run_codex() {
  local prompt="$1"
  local output_file="$2"
  local working_dir="$3"
  local timeout="${4:-180}"

  local start_time
  start_time=$(date +%s)

  timeout "${timeout}s" codex exec "$prompt" \
    -o "$output_file" \
    --full-auto \
    --skip-git-repo-check \
    -c 'mcp_servers={}' \
    -C "$working_dir" \
    2>/dev/null

  local exit_code=$?
  local end_time
  end_time=$(date +%s)
  local duration=$(( end_time - start_time ))

  # Write metadata
  local meta_file="${output_file%.md}.meta.json"
  cat > "$meta_file" <<METAEOF
{
  "harness": "codex",
  "model": "gpt-5.4",
  "duration_seconds": $duration,
  "exit_code": $exit_code,
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
METAEOF

  return $exit_code
}

# Run Codex with skill (skill content prepended to prompt)
run_codex_with_skill() {
  local skill_file="$1"
  local prompt="$2"
  local output_file="$3"
  local working_dir="$4"
  local timeout="${5:-180}"

  local skill_content
  skill_content=$(cat "$skill_file")
  local full_prompt
  full_prompt=$(printf 'You have been given the following skill to guide your work:\n<skill>\n%s\n</skill>\n\nNow complete this task:\n%s' "$skill_content" "$prompt")
  run_codex "$full_prompt" "$output_file" "$working_dir" "$timeout"
}

# Run Codex without skill (plain prompt)
run_codex_without_skill() {
  local prompt="$1"
  local output_file="$2"
  local working_dir="$3"
  local timeout="${4:-180}"

  run_codex "$prompt" "$output_file" "$working_dir" "$timeout"
}
