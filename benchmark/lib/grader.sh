#!/usr/bin/env bash
# grader.sh — grade a single benchmark output against assertions using Claude Sonnet

set -euo pipefail

# Allow Claude CLI to run from within a Claude Code session
unset CLAUDECODE 2>/dev/null || true

grade_output() {
  local output_file="$1"
  local assertions_json="$2"  # JSON array of assertion strings
  local grading_file="$3"

  local output_content
  output_content=$(cat "$output_file" 2>/dev/null || echo "[EMPTY OUTPUT]")

  local grading_prompt
  grading_prompt=$(cat <<GRADEEOF
Grade the following agent output against each assertion. For each assertion, determine if it PASSES or FAILS based on the output.

## Agent Output

<output>
${output_content}
</output>

## Assertions

${assertions_json}

## Instructions

For each assertion, respond with a JSON object containing:
- "text": the assertion text
- "pass": true if the output clearly meets this assertion, false otherwise
- "evidence": a brief quote or explanation showing why it passes or fails

Be strict and conservative. Only mark PASS if the assertion is clearly and unambiguously met.

Respond with ONLY a JSON object in this exact format, no other text:
{
  "assertions": [
    {"text": "...", "pass": true/false, "evidence": "..."},
    ...
  ],
  "pass_count": N,
  "total": N,
  "pass_rate": 0.XX
}
GRADEEOF
)

  local system_prompt="You are a strict, objective grader. Evaluate each assertion independently. Be conservative: only pass assertions clearly met. Respond with valid JSON only."

  local raw_file="${grading_file}.raw"

  env -u CLAUDECODE claude -p "$grading_prompt" \
    --system-prompt "$system_prompt" \
    --allowedTools '' \
    --max-turns 1 \
    --disable-slash-commands \
    --setting-sources '' \
    --strict-mcp-config --mcp-config '' \
    --model claude-sonnet-4-6 \
    --output-format json \
    > "$raw_file" 2>/dev/null

  local exit_code=$?

  if (( exit_code != 0 )); then
    rm -f "$raw_file"
    return $exit_code
  fi

  # Extract the grading JSON from the session envelope.
  # --output-format json wraps the response in {"type":"result","result":"```json\n{...}\n```",...}
  # We need to: extract .result string -> strip markdown code fences -> parse as JSON
  jq -r '.result' "$raw_file" \
    | sed 's/^```json//; s/^```//; /^$/d' \
    | jq '.' > "$grading_file" 2>/dev/null

  local parse_code=$?
  rm -f "$raw_file"

  return $parse_code
}
