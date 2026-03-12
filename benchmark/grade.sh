#!/usr/bin/env bash
# grade.sh — grade all benchmark outputs against manifest assertions

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export BENCHMARK_DIR="$SCRIPT_DIR"
RESULTS_DIR="$BENCHMARK_DIR/results"
MAX_PARALLEL="${MAX_PARALLEL:-8}"

source "$BENCHMARK_DIR/lib/manifest_parser.sh"
source "$BENCHMARK_DIR/lib/grader.sh"

# Filter options
FILTER_SKILL="${FILTER_SKILL:-}"
FILTER_VARIANT="${FILTER_VARIANT:-}"

VARIANTS=("claude-with" "claude-without" "codex-with" "codex-without")

log() { echo "[$(date +%H:%M:%S)] $*" >&2; }
log_ok() { echo "[$(date +%H:%M:%S)] ✓ $*" >&2; }
log_err() { echo "[$(date +%H:%M:%S)] ✗ $*" >&2; }

grade_single() {
  local skill="$1" test_id="$2" variant="$3"
  local output_dir="$RESULTS_DIR/$skill/$test_id/$variant"
  local output_file="$output_dir/output.md"
  local grading_file="$output_dir/grading.json"

  # Skip if already graded
  if [[ -f "$grading_file" ]] && [[ -s "$grading_file" ]]; then
    log "SKIP grading $skill/$test_id/$variant (already graded)"
    return 0
  fi

  # Skip if no output
  if [[ ! -f "$output_file" ]] || [[ ! -s "$output_file" ]]; then
    log_err "No output for $skill/$test_id/$variant"
    # Write empty grading
    cat > "$grading_file" <<EMPTYEOF
{
  "assertions": [],
  "pass_count": 0,
  "total": 0,
  "pass_rate": 0,
  "error": "no output file"
}
EMPTYEOF
    return 1
  fi

  # Build assertions JSON array
  local assertions_json
  assertions_json=$(jq -n --arg s "$skill" --arg t "$test_id" \
    --slurpfile m "$BENCHMARK_DIR/manifest.json" \
    '$m[0].skills[] | select(.name == $s) | .test_cases[] | select(.id == $t) | .assertions')

  log "Grading $skill/$test_id/$variant"

  if grade_output "$output_file" "$assertions_json" "$grading_file"; then
    # Validate JSON output
    if jq empty "$grading_file" 2>/dev/null; then
      local pass_count total
      pass_count=$(jq '.pass_count // (.assertions | map(select(.pass)) | length)' "$grading_file")
      total=$(jq '.total // (.assertions | length)' "$grading_file")
      log_ok "$skill/$test_id/$variant: $pass_count/$total"
    else
      log_err "$skill/$test_id/$variant: invalid JSON in grading output"
      return 1
    fi
  else
    log_err "$skill/$test_id/$variant: grading failed"
    return 1
  fi
}

main() {
  log "Grading benchmark outputs"

  local total=0
  local graded=0
  local failed=0
  local pids=()

  for skill in $(manifest_skills); do
    [[ -n "$FILTER_SKILL" && "$skill" != "$FILTER_SKILL" ]] && continue

    for test_id in $(manifest_test_cases "$skill"); do
      for variant in "${VARIANTS[@]}"; do
        [[ -n "$FILTER_VARIANT" && "$FILTER_VARIANT" != "$variant" ]] && continue
        total=$(( total + 1 ))

        # Throttle parallelism
        while (( ${#pids[@]} >= MAX_PARALLEL )); do
          local new_pids=()
          for pid in "${pids[@]}"; do
            if kill -0 "$pid" 2>/dev/null; then
              new_pids+=("$pid")
            else
              wait "$pid" && graded=$(( graded + 1 )) || failed=$(( failed + 1 ))
            fi
          done
          pids=("${new_pids[@]}")
          if (( ${#pids[@]} >= MAX_PARALLEL )); then
            sleep 1
          fi
        done

        grade_single "$skill" "$test_id" "$variant" &
        pids+=($!)
      done
    done
  done

  # Wait for remaining
  for pid in "${pids[@]}"; do
    wait "$pid" && graded=$(( graded + 1 )) || failed=$(( failed + 1 ))
  done

  log "Grading complete: $graded succeeded, $failed failed out of $total"
}

main "$@"
