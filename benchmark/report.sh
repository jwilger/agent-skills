#!/usr/bin/env bash
# report.sh — generate comparison tables from graded benchmark results

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export BENCHMARK_DIR="$SCRIPT_DIR"
RESULTS_DIR="$BENCHMARK_DIR/results"
REPORT_FILE="$RESULTS_DIR/report.md"
SUMMARY_FILE="$RESULTS_DIR/summary.json"

source "$BENCHMARK_DIR/lib/manifest_parser.sh"

VARIANTS=("claude-with" "claude-without" "codex-with" "codex-without")

# Extract pass_rate from a grading.json, returns 0 if missing
get_pass_rate() {
  local grading_file="$1"
  if [[ -f "$grading_file" ]] && jq empty "$grading_file" 2>/dev/null; then
    jq '(.pass_count // (.assertions | map(select(.pass)) | length)) as $p |
        (.total // (.assertions | length)) as $t |
        if $t > 0 then ($p / $t * 100 | round) else 0 end' "$grading_file"
  else
    echo "0"
  fi
}

get_pass_count() {
  local grading_file="$1"
  if [[ -f "$grading_file" ]] && jq empty "$grading_file" 2>/dev/null; then
    jq '.pass_count // (.assertions | map(select(.pass)) | length)' "$grading_file"
  else
    echo "0"
  fi
}

get_total() {
  local grading_file="$1"
  if [[ -f "$grading_file" ]] && jq empty "$grading_file" 2>/dev/null; then
    jq '.total // (.assertions | length)' "$grading_file"
  else
    echo "0"
  fi
}

main() {
  echo "Generating report..."

  local report=""
  local summary_skills=()

  report+="# Cross-Harness Skill Benchmark Report\n\n"
  report+="Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)\n\n"

  # Aggregate totals for summary
  local agg_claude_with=0 agg_claude_without=0 agg_codex_with=0 agg_codex_without=0
  local agg_total=0

  for skill in $(manifest_skills); do
    report+="## $skill\n\n"
    report+="| Test Case | Claude+Skill | Codex+Skill | Claude-Skill | Codex-Skill |\n"
    report+="|-----------|-------------|-------------|-------------|-------------|\n"

    local skill_cw=0 skill_cow=0 skill_xw=0 skill_xow=0
    local skill_total=0

    for test_id in $(manifest_test_cases "$skill"); do
      local cw_file="$RESULTS_DIR/$skill/$test_id/claude-with/grading.json"
      local cow_file="$RESULTS_DIR/$skill/$test_id/claude-without/grading.json"
      local xw_file="$RESULTS_DIR/$skill/$test_id/codex-with/grading.json"
      local xow_file="$RESULTS_DIR/$skill/$test_id/codex-without/grading.json"

      local cw_pass cow_pass xw_pass xow_pass
      cw_pass=$(get_pass_count "$cw_file")
      cow_pass=$(get_pass_count "$cow_file")
      xw_pass=$(get_pass_count "$xw_file")
      xow_pass=$(get_pass_count "$xow_file")

      local total
      total=$(get_total "$cw_file")
      if (( total == 0 )); then
        total=$(manifest_assertion_count "$skill" "$test_id")
      fi

      local cw_pct cow_pct xw_pct xow_pct
      if (( total > 0 )); then
        cw_pct=$(( cw_pass * 100 / total ))
        cow_pct=$(( cow_pass * 100 / total ))
        xw_pct=$(( xw_pass * 100 / total ))
        xow_pct=$(( xow_pass * 100 / total ))
      else
        cw_pct=0; cow_pct=0; xw_pct=0; xow_pct=0
      fi

      report+="| $test_id | $cw_pass/$total ($cw_pct%) | $xw_pass/$total ($xw_pct%) | $cow_pass/$total ($cow_pct%) | $xow_pass/$total ($xow_pct%) |\n"

      skill_cw=$(( skill_cw + cw_pass ))
      skill_cow=$(( skill_cow + cow_pass ))
      skill_xw=$(( skill_xw + xw_pass ))
      skill_xow=$(( skill_xow + xow_pass ))
      skill_total=$(( skill_total + total ))
    done

    agg_claude_with=$(( agg_claude_with + skill_cw ))
    agg_claude_without=$(( agg_claude_without + skill_cow ))
    agg_codex_with=$(( agg_codex_with + skill_xw ))
    agg_codex_without=$(( agg_codex_without + skill_xow ))
    agg_total=$(( agg_total + skill_total ))

    # Skill-level deltas
    local skill_delta_claude=0 skill_delta_codex=0 harness_delta_with=0 harness_delta_without=0
    if (( skill_total > 0 )); then
      skill_delta_claude=$(( (skill_cw - skill_cow) * 100 / skill_total ))
      skill_delta_codex=$(( (skill_xw - skill_xow) * 100 / skill_total ))
      harness_delta_with=$(( (skill_cw - skill_xw) * 100 / skill_total ))
      harness_delta_without=$(( (skill_cow - skill_xow) * 100 / skill_total ))
    fi

    report+="\n**Skill Delta (Claude):** ${skill_delta_claude}% | "
    report+="**Skill Delta (Codex):** ${skill_delta_codex}% | "
    report+="**Harness Delta (+Skill):** ${harness_delta_with}% | "
    report+="**Harness Delta (-Skill):** ${harness_delta_without}%\n\n"

    # Collect for JSON summary
    summary_skills+=("{\"name\":\"$skill\",\"claude_with\":$skill_cw,\"claude_without\":$skill_cow,\"codex_with\":$skill_xw,\"codex_without\":$skill_xow,\"total\":$skill_total,\"skill_delta_claude\":$skill_delta_claude,\"skill_delta_codex\":$skill_delta_codex,\"harness_delta_with\":$harness_delta_with,\"harness_delta_without\":$harness_delta_without}")
  done

  # Aggregate summary
  report+="---\n\n"
  report+="## Aggregate Summary\n\n"
  report+="| Metric | Score |\n"
  report+="|--------|-------|\n"

  if (( agg_total > 0 )); then
    report+="| Claude+Skill | $agg_claude_with/$agg_total ($(( agg_claude_with * 100 / agg_total ))%) |\n"
    report+="| Codex+Skill | $agg_codex_with/$agg_total ($(( agg_codex_with * 100 / agg_total ))%) |\n"
    report+="| Claude-Skill | $agg_claude_without/$agg_total ($(( agg_claude_without * 100 / agg_total ))%) |\n"
    report+="| Codex-Skill | $agg_codex_without/$agg_total ($(( agg_codex_without * 100 / agg_total ))%) |\n"
    report+="| **Skill Delta (Claude)** | +$(( (agg_claude_with - agg_claude_without) * 100 / agg_total ))% |\n"
    report+="| **Skill Delta (Codex)** | +$(( (agg_codex_with - agg_codex_without) * 100 / agg_total ))% |\n"
    report+="| **Harness Delta (+Skill)** | $(( (agg_claude_with - agg_codex_with) * 100 / agg_total ))% |\n"
    report+="| **Harness Delta (-Skill)** | $(( (agg_claude_without - agg_codex_without) * 100 / agg_total ))% |\n"
  fi

  report+="\n## Skill Comparison Table\n\n"
  report+="| Skill | Claude+S | Codex+S | Claude-S | Codex-S | Δ Claude | Δ Codex | Δ Harness+S | Δ Harness-S |\n"
  report+="|-------|----------|---------|----------|---------|----------|---------|-------------|-------------|\n"

  for skill in $(manifest_skills); do
    local cw cow xw xow tot
    # Re-read from the summary_skills array is complex in bash; re-derive
    cw=0; cow=0; xw=0; xow=0; tot=0
    for test_id in $(manifest_test_cases "$skill"); do
      local t_cw t_cow t_xw t_xow t_total
      t_cw=$(get_pass_count "$RESULTS_DIR/$skill/$test_id/claude-with/grading.json")
      t_cow=$(get_pass_count "$RESULTS_DIR/$skill/$test_id/claude-without/grading.json")
      t_xw=$(get_pass_count "$RESULTS_DIR/$skill/$test_id/codex-with/grading.json")
      t_xow=$(get_pass_count "$RESULTS_DIR/$skill/$test_id/codex-without/grading.json")
      t_total=$(get_total "$RESULTS_DIR/$skill/$test_id/claude-with/grading.json")
      if (( t_total == 0 )); then
        t_total=$(manifest_assertion_count "$skill" "$test_id")
      fi
      cw=$(( cw + t_cw )); cow=$(( cow + t_cow ))
      xw=$(( xw + t_xw )); xow=$(( xow + t_xow ))
      tot=$(( tot + t_total ))
    done

    if (( tot > 0 )); then
      local cw_pct=$(( cw * 100 / tot ))
      local cow_pct=$(( cow * 100 / tot ))
      local xw_pct=$(( xw * 100 / tot ))
      local xow_pct=$(( xow * 100 / tot ))
      local dc=$(( cw_pct - cow_pct ))
      local dx=$(( xw_pct - xow_pct ))
      local dhw=$(( cw_pct - xw_pct ))
      local dhwo=$(( cow_pct - xow_pct ))
      report+="| $skill | ${cw_pct}% | ${xw_pct}% | ${cow_pct}% | ${xow_pct}% | +${dc}% | +${dx}% | ${dhw}% | ${dhwo}% |\n"
    fi
  done

  # Write report
  echo -e "$report" > "$REPORT_FILE"
  echo "Report written to $REPORT_FILE"

  # Write JSON summary
  local skills_json
  skills_json=$(printf '%s\n' "${summary_skills[@]}" | jq -s '.')

  jq -n \
    --argjson skills "$skills_json" \
    --argjson agg_cw "$agg_claude_with" \
    --argjson agg_cow "$agg_claude_without" \
    --argjson agg_xw "$agg_codex_with" \
    --argjson agg_xow "$agg_codex_without" \
    --argjson agg_total "$agg_total" \
    '{
      timestamp: (now | todate),
      aggregate: {
        claude_with: $agg_cw,
        claude_without: $agg_cow,
        codex_with: $agg_xw,
        codex_without: $agg_xow,
        total: $agg_total,
        skill_delta_claude: (if $agg_total > 0 then (($agg_cw - $agg_cow) * 100 / $agg_total) else 0 end),
        skill_delta_codex: (if $agg_total > 0 then (($agg_xw - $agg_xow) * 100 / $agg_total) else 0 end),
        harness_delta_with_skill: (if $agg_total > 0 then (($agg_cw - $agg_xw) * 100 / $agg_total) else 0 end),
        harness_delta_without_skill: (if $agg_total > 0 then (($agg_cow - $agg_xow) * 100 / $agg_total) else 0 end)
      },
      skills: $skills
    }' > "$SUMMARY_FILE"

  echo "Summary written to $SUMMARY_FILE"
}

main "$@"
