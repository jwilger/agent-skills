#!/usr/bin/env bash
# claude_runner.sh — run a single Claude Code benchmark invocation with full isolation

set -euo pipefail

# Allow Claude CLI to run from within a Claude Code session
unset CLAUDECODE 2>/dev/null || true

run_claude() {
  local system_prompt="$1"
  local prompt="$2"
  local output_file="$3"
  local working_dir="$4"
  local timeout="${5:-180}"

  local start_time
  start_time=$(date +%s)

  ( cd "$working_dir" && \
    env -u CLAUDECODE timeout "${timeout}s" claude -p "$prompt" \
      --system-prompt "$system_prompt" \
      --allowedTools '' \
      --max-turns 2 \
      --disable-slash-commands \
      --setting-sources '' \
      --strict-mcp-config --mcp-config '' \
      --model claude-opus-4-6 \
      > "$output_file" 2>/dev/null )

  local exit_code=$?
  local end_time
  end_time=$(date +%s)
  local duration=$(( end_time - start_time ))

  # Write metadata
  local meta_file="${output_file%.md}.meta.json"
  cat > "$meta_file" <<METAEOF
{
  "harness": "claude",
  "model": "claude-opus-4-6",
  "duration_seconds": $duration,
  "exit_code": $exit_code,
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
METAEOF

  return $exit_code
}

# Run Claude with skill (system prompt = skill content)
run_claude_with_skill() {
  local skill_file="$1"
  local prompt="$2"
  local output_file="$3"
  local working_dir="$4"
  local timeout="${5:-180}"

  local skill_content
  skill_content=$(cat "$skill_file")
  run_claude "$skill_content" "$prompt" "$output_file" "$working_dir" "$timeout"
}

# Run Claude without skill (generic system prompt)
run_claude_without_skill() {
  local prompt="$1"
  local output_file="$2"
  local working_dir="$3"
  local timeout="${4:-180}"

  local system_prompt="You are a senior software engineer. Answer using only your general software engineering knowledge."
  run_claude "$system_prompt" "$prompt" "$output_file" "$working_dir" "$timeout"
}
