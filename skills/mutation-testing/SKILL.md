---
name: mutation-testing
description: >-
  Mutation testing quality gate with scenario coverage enforcement and
  structured evidence output. Detects project type and runs the right tool
  (cargo-mutants, Stryker, mutmut, Muzak), analyzes surviving mutants by
  mutation type (arithmetic, comparison, boolean, return value, statement
  removal), enforces scenario coverage check before recommending tests,
  produces MUTATION_RESULT JSON evidence packets, and enforces a 100% kill
  rate quality gate. Use when running mutation testing, validating test
  quality, preparing PRs, or analyzing surviving mutants. Triggers on: "run
  mutation testing", "mutation score", "surviving mutants", "kill rate",
  "cargo mutants", "stryker", "pre-PR quality check", "are my tests good
  enough". NOT for: writing tests (use tdd), debugging test failures (use
  debugging-protocol).
license: CC0-1.0
compatibility: Requires a mutation testing tool (cargo-mutants, Stryker, mutmut, or Muzak)
metadata:
  author: jwilger
  version: "2.2.1"
  requires: [tdd]
  context: [test-files, source-files]
  phase: ship
  standalone: true
  constraint_resolution: true
---

# Mutation Testing

**Value:** Feedback -- mutation testing closes the verification loop by
proving that tests actually detect the bugs they claim to prevent. Without
it, passing tests may provide false confidence.

## Purpose

Teaches the agent to run mutation testing as a quality gate before PR
creation. Mutation testing makes small changes (mutations) to production
code and checks whether tests catch them. Surviving mutants reveal gaps
where bugs could hide undetected. The required mutation kill rate is 100%.

## Practices

### Detect and Run the Right Tool

Detect the project type and run the appropriate mutation testing tool.

1. Check for project markers:
   - `Cargo.toml` -> Rust -> `cargo mutants`
   - `package.json` -> TypeScript/JavaScript -> `npx stryker run`
   - `pyproject.toml` or `setup.py` -> Python -> `mutmut run`
   - `mix.exs` -> Elixir -> `mix muzak`

2. Verify the tool is installed. If not, provide installation instructions:
   - Rust: `cargo install cargo-mutants`
   - TypeScript: `npm install --save-dev @stryker-mutator/core`
   - Python: `pip install mutmut`
   - Elixir: add `{:muzak, "~> 1.0", only: :test}` to deps

3. Run mutation testing against the relevant scope. Prefer scoping to
   changed files or packages rather than the entire codebase when possible:
   ```
   # Rust (scoped to package)
   cargo mutants --package <package> --jobs 4

   # TypeScript
   npx stryker run

   # Python (scoped to source)
   mutmut run --paths-to-mutate=src/
   mutmut results

   # Elixir
   mix muzak
   ```

### Parse and Report Results

Extract from the mutation tool output:
- Total mutants generated
- Mutants killed (tests detected the change)
- Mutants survived (tests did NOT detect the change)
- Timed-out mutants
- Mutation score percentage

### Analyze Surviving Mutants

For each surviving mutant, report three things:

1. **Location:** File and line number
2. **Mutation:** What was changed (e.g., "replaced `+` with `-`")
3. **Meaning:** What class of bug this lets through

Common mutation types and what survival indicates:
- **Arithmetic** (`+` -> `-`, `*` -> `/`): Calculations not verified
- **Comparison** (`>` -> `>=`, `==` -> `!=`): Boundary conditions untested
- **Boolean** (`&&` -> `||`, `!` removed): Logic branches not covered
- **Return value** (`true` -> `false`, `Ok` -> `Err`): Return paths not
  checked
- **Statement removal** (line deleted): Side effects not asserted

### Scenario Coverage Check

Before recommending any test for a surviving mutant, check scenario coverage:

For each surviving mutant:

**Step 1 — Scenario check:** Does any acceptance scenario or domain scenario
(from the slice's `acceptance_scenarios` or `domain_scenarios` arrays, or
the plan's Confirmed Scenarios sections) require the behavior being mutated?

- **YES** → A scenario exists but its test is missing. Proceed to Recommend
  Missing Tests below.
- **NO** → Flag for human decision:
  ```
  Surviving mutant at [file]:[line] has no GWT scenario requiring this behavior.
  Options:
    (a) Delete the code — this behavior may not be needed.
    (b) Add a missing acceptance or domain scenario — the spec is incomplete.
  The 100% kill rate still applies; this clarifies how to resolve it.
  ```
  Do NOT proceed to test recommendations for uncovered mutants. Writing a test
  without a scenario games the metric without testing real behavior.

### Recommend Missing Tests

For each surviving mutant **with a covering scenario**, suggest a specific test:

```
Surviving: src/money.rs:45 -- replaced `+` with `-` in Money::add()
Recommend: Test that adding Money(50) + Money(30) equals Money(80),
           not Money(20). The current tests do not assert the sum value.

Surviving: src/account.rs:78 -- replaced `>` with `>=` in check_balance()
Recommend: Test the exact boundary -- check_balance with exactly zero
           balance. Current tests only check positive and negative.
```

### Structured Output

After mutation testing completes, produce a `MUTATION_RESULT` evidence packet:

```json
{
  "tool": "cargo-mutants",
  "scope": ["src/money.rs", "src/account.rs"],
  "total_mutants": 42,
  "killed": 40,
  "survived": 2,
  "score": 95.2,
  "survivors": [
    {"file": "src/money.rs", "line": 45, "mutation_type": "arithmetic", "description": "replaced + with -"}
  ],
  "verdict": "FAIL"
}
```

- **Verdict:** `PASS` if score is 100% on changed files, `FAIL` otherwise
- When running in pipeline mode, store to `.factory/audit-trail/slices/<slice-id>/mutation.json`
- When running standalone, the output is informational only -- display it and proceed to the quality gate

### Enforce the Quality Gate

The required mutation kill rate is **100%**. All mutants must be killed.

- If score is 100%: Report success, proceed to PR creation
- If score is below 100%: List all survivors with recommendations. Block
  PR creation with a clear warning. The user may override, but the default
  is to fix first.

**Do:**
- Scope mutation runs to changed code when possible
- Report survivors with actionable fix recommendations
- Re-run after fixes to confirm all mutants are now killed
- Treat timeouts as killed (the mutation broke something)

**Do not:**
- Skip mutation testing before PR creation
- Accept surviving mutants without reporting them
- Run mutations on the entire codebase when only a module changed
- Recommend tests for data validation that belongs in domain types

### Pipeline Mode

When invoked by the pipeline orchestrator:

- A `FAIL` verdict routes automatically back to the `tdd` skill with the survivor list attached. The pipeline handles this rework routing -- mutation-testing just reports results.
- Survivor details in the `MUTATION_RESULT` packet must be specific enough (file, line, mutation type, description) for the TDD pair to write targeted tests without re-running the mutation tool to understand what failed.
- The pipeline may invoke mutation-testing multiple times per slice; each run overwrites the previous `mutation.json` for that slice.

## Enforcement Note

- **Pipeline mode**: Gating. 100% kill rate is a gate -- failing blocks
  merge.
- **Standalone mode**: Advisory. The agent reports but cannot prevent
  override.

**Hard constraints:**
- 100% kill rate: `[H]` in pipeline mode, `[RP]` in standalone (block PR,
  user can override with documented reason)

See `CONSTRAINT-RESOLUTION.md` in the template directory for override
documentation requirements.

## Constraints

- **100% kill rate**: 100% means 100%. Not "close enough." Not "98% with
  justification." The only path below 100% is an explicit user override,
  which MUST include a documented reason explaining why each surviving
  mutant is acceptable. "I want to ship" is not a reason. "This mutant
  tests logging output which is not a business rule" is a reason.
- **"No test without scenario"**: Writing a test solely to kill a mutant
  without a corresponding scenario games the metric. The test proves you
  can kill the mutant, not that the behavior matters. If no scenario covers
  the behavior, the correct response is to flag the gap for the team -- the
  missing scenario might reveal a missing requirement.

## Verification

After completing mutation testing, verify:

- [ ] Mutation testing tool was run against the relevant scope
- [ ] All surviving mutants are listed with file, line, and mutation type
- [ ] Each survivor checked for scenario coverage before test recommendations
- [ ] Each survivor with a covering scenario has a specific test recommendation
- [ ] Each survivor without a covering scenario is flagged for human decision
- [ ] Mutation score is 100% (or user explicitly chose to override)
- [ ] If fixes were made, mutation testing was re-run to confirm

If any criterion is not met, revisit the relevant practice before proceeding.

## Dependencies

This skill works standalone but is most valuable as a pre-PR quality gate.
It integrates with:

- **tdd:** TDD produces the tests that mutation testing validates;
  surviving mutants indicate the TDD cycle missed a case
- **code-review:** Mutation results inform code review -- reviewers can
  check that new code has no surviving mutants

Missing a dependency? Install with:
```
npx skills add jwilger/agent-skills --skill tdd
```
