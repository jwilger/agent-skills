#!/usr/bin/env bash
# run.sh — main benchmark orchestrator
# Reads manifest.json, runs 4 variants per test case:
#   claude-with-skill, claude-without-skill, codex-with-skill, codex-without-skill

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export BENCHMARK_DIR="$SCRIPT_DIR"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TEST_REPOS="${TEST_REPOS:-$HOME/projects/agent-skills-test-repositories}"
RESULTS_DIR="$BENCHMARK_DIR/results"
SCRATCH_DIR="/tmp/benchmark-scratch"
MAX_PARALLEL="${MAX_PARALLEL:-4}"
TIMEOUT="${TIMEOUT:-180}"
RETRY_COUNT="${RETRY_COUNT:-1}"

# Filter options
FILTER_SKILL="${FILTER_SKILL:-}"       # Run only this skill
FILTER_VARIANT="${FILTER_VARIANT:-}"   # Run only this variant (claude-with, claude-without, codex-with, codex-without)

# Source library functions
source "$BENCHMARK_DIR/lib/manifest_parser.sh"
source "$BENCHMARK_DIR/lib/claude_runner.sh"
source "$BENCHMARK_DIR/lib/codex_runner.sh"

VARIANTS=("claude-with" "claude-without" "codex-with" "codex-without")

log() { echo "[$(date +%H:%M:%S)] $*" >&2; }
log_ok() { echo "[$(date +%H:%M:%S)] ✓ $*" >&2; }
log_err() { echo "[$(date +%H:%M:%S)] ✗ $*" >&2; }

# Prepare a clean working directory for a test case
prepare_working_dir() {
  local working_dir_name="$1"
  local dest="$2"

  if [[ "$working_dir_name" == "empty-project" ]]; then
    mkdir -p "$dest"
    return 0
  fi

  local source_dir="$TEST_REPOS/$working_dir_name"
  if [[ ! -d "$source_dir" ]]; then
    log_err "Test repo not found: $source_dir"
    return 1
  fi

  # Copy and strip agent-skills metadata
  cp -r "$source_dir" "$dest"
  rm -rf "$dest/.claude" "$dest/CLAUDE.md" "$dest/AGENTS.md" \
         "$dest/.codex" "$dest/GEMINI.md" "$dest/.github/agents" \
         2>/dev/null || true
}

# Run a single variant for a test case
run_variant() {
  local skill="$1"
  local test_id="$2"
  local variant="$3"
  local prompt="$4"
  local working_dir_name="$5"
  local skill_file="$6"

  local output_dir="$RESULTS_DIR/$skill/$test_id/$variant"
  mkdir -p "$output_dir"
  local output_file="$output_dir/output.md"

  # Skip if already completed
  if [[ -f "$output_file" ]] && [[ -s "$output_file" ]]; then
    log "SKIP $skill/$test_id/$variant (already exists)"
    return 0
  fi

  # Prepare isolated working directory
  local work_dir="$SCRATCH_DIR/${skill}-${test_id}-${variant}"
  rm -rf "$work_dir"
  prepare_working_dir "$working_dir_name" "$work_dir" || return 1

  local attempt=0
  local max_attempts=$(( RETRY_COUNT + 1 ))
  local exit_code=1

  while (( attempt < max_attempts && exit_code != 0 )); do
    attempt=$(( attempt + 1 ))
    if (( attempt > 1 )); then
      log "RETRY $skill/$test_id/$variant (attempt $attempt/$max_attempts)"
    fi

    case "$variant" in
      claude-with)
        run_claude_with_skill "$REPO_ROOT/$skill_file" "$prompt" "$output_file" "$work_dir" "$TIMEOUT"
        exit_code=$?
        ;;
      claude-without)
        run_claude_without_skill "$prompt" "$output_file" "$work_dir" "$TIMEOUT"
        exit_code=$?
        ;;
      codex-with)
        run_codex_with_skill "$REPO_ROOT/$skill_file" "$prompt" "$output_file" "$work_dir" "$TIMEOUT"
        exit_code=$?
        ;;
      codex-without)
        run_codex_without_skill "$prompt" "$output_file" "$work_dir" "$TIMEOUT"
        exit_code=$?
        ;;
    esac
  done

  # Cleanup temp working dir
  rm -rf "$work_dir"

  if (( exit_code == 0 )); then
    log_ok "$skill/$test_id/$variant"
  else
    log_err "$skill/$test_id/$variant (exit code: $exit_code)"
  fi

  return $exit_code
}

# Disable Codex skills for isolation
codex_skills_backup() {
  if [[ -d "$HOME/.codex/skills" ]]; then
    log "Backing up ~/.codex/skills"
    mv "$HOME/.codex/skills" "$HOME/.codex/skills.bak"
  fi
}

codex_skills_restore() {
  if [[ -d "$HOME/.codex/skills.bak" ]]; then
    log "Restoring ~/.codex/skills"
    mv "$HOME/.codex/skills.bak" "$HOME/.codex/skills"
  fi
}

# Main execution
main() {
  log "Benchmark runner starting"
  log "Max parallel: $MAX_PARALLEL | Timeout: ${TIMEOUT}s | Retries: $RETRY_COUNT"

  # Create scratch directory
  mkdir -p "$SCRATCH_DIR" "$RESULTS_DIR"

  # Back up codex skills for isolation
  local has_codex_variants=false
  for v in "${VARIANTS[@]}"; do
    if [[ -z "$FILTER_VARIANT" || "$FILTER_VARIANT" == "$v" ]]; then
      if [[ "$v" == codex-* ]]; then
        has_codex_variants=true
        break
      fi
    fi
  done

  if $has_codex_variants; then
    codex_skills_backup
    trap codex_skills_restore EXIT
  fi

  local total_runs=0
  local completed_runs=0
  local failed_runs=0
  local pids=()

  # Count total runs
  for skill in $(manifest_skills); do
    [[ -n "$FILTER_SKILL" && "$skill" != "$FILTER_SKILL" ]] && continue
    for test_id in $(manifest_test_cases "$skill"); do
      for variant in "${VARIANTS[@]}"; do
        [[ -n "$FILTER_VARIANT" && "$FILTER_VARIANT" != "$variant" ]] && continue
        total_runs=$(( total_runs + 1 ))
      done
    done
  done

  log "Total runs planned: $total_runs"

  # Execute runs with parallelization
  for skill in $(manifest_skills); do
    [[ -n "$FILTER_SKILL" && "$skill" != "$FILTER_SKILL" ]] && continue

    local skill_file
    skill_file=$(manifest_skill_file "$skill")

    for test_id in $(manifest_test_cases "$skill"); do
      local prompt working_dir_name
      prompt=$(manifest_prompt "$skill" "$test_id")
      working_dir_name=$(manifest_working_dir "$skill" "$test_id")

      for variant in "${VARIANTS[@]}"; do
        [[ -n "$FILTER_VARIANT" && "$FILTER_VARIANT" != "$variant" ]] && continue

        # Throttle parallelism
        while (( ${#pids[@]} >= MAX_PARALLEL )); do
          local new_pids=()
          for pid in "${pids[@]}"; do
            if kill -0 "$pid" 2>/dev/null; then
              new_pids+=("$pid")
            else
              wait "$pid" && completed_runs=$(( completed_runs + 1 )) || failed_runs=$(( failed_runs + 1 ))
            fi
          done
          pids=("${new_pids[@]}")
          if (( ${#pids[@]} >= MAX_PARALLEL )); then
            sleep 1
          fi
        done

        run_variant "$skill" "$test_id" "$variant" "$prompt" "$working_dir_name" "$skill_file" &
        pids+=($!)
      done
    done
  done

  # Wait for remaining jobs
  for pid in "${pids[@]}"; do
    wait "$pid" && completed_runs=$(( completed_runs + 1 )) || failed_runs=$(( failed_runs + 1 ))
  done

  log "Benchmark complete: $completed_runs succeeded, $failed_runs failed out of $total_runs"

  # Write run summary
  cat > "$RESULTS_DIR/run_summary.json" <<SUMEOF
{
  "total_runs": $total_runs,
  "completed": $completed_runs,
  "failed": $failed_runs,
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "config": {
    "max_parallel": $MAX_PARALLEL,
    "timeout_seconds": $TIMEOUT,
    "retry_count": $RETRY_COUNT,
    "filter_skill": "${FILTER_SKILL:-null}",
    "filter_variant": "${FILTER_VARIANT:-null}"
  }
}
SUMEOF

  if (( failed_runs > 0 )); then
    return 1
  fi
  return 0
}

main "$@"
