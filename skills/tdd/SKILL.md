---
name: tdd
description: >-
  Use this skill whenever the user wants to write code using TDD, test-driven
  development, or test-first methodology. Triggers on: "/tdd", "let's do TDD",
  "write a failing test", "red green refactor", "test-first", "start a TDD
  cycle", or any request to implement a feature by writing tests before code.
  Adaptive five-step cycle (RED-DOMAIN-GREEN-DOMAIN-COMMIT) that detects
  harness capabilities and routes to guided (/tdd red|domain|green|commit)
  or automated (/tdd) mode. NOT for running existing tests, debugging test
  failures, or reviewing code -- only for the disciplined test-first cycle.
license: CC0-1.0
metadata:
  author: jwilger
  version: "2.2.0"
  requires: []
  context: [test-files, domain-types, source-files]
  phase: build
  standalone: true
  constraint_resolution: true
---

# TDD

**Value:** Feedback -- short cycles with verifiable evidence keep AI-generated
code honest and the human in control. Tests express intent; evidence confirms
progress.

## Purpose

Teaches a five-step TDD cycle (RED, DOMAIN, GREEN, DOMAIN, COMMIT) that
adapts to whatever harness runs it. Detects available delegation primitives
and routes to guided mode (human drives each phase) or automated mode
(system orchestrates phases). Prevents primitive obsession, skipped reviews,
and untested complexity regardless of mode.

## Practices

### The Five-Step Cycle

Every feature is built by repeating: RED -> DOMAIN -> GREEN -> DOMAIN -> COMMIT.

1. **RED** -- Write one failing test with one assertion. Only edit test files.
   Write the code you wish you had -- reference types and functions that do not
   exist yet. Run the test. Paste the failure output. Stop.
   Done when: tests run and FAIL (compilation error OR assertion failure).

2. **DOMAIN (after RED)** -- Review the test for primitive obsession and
   invalid-state risks. Create type definitions with stub bodies (`todo!()`,
   `raise NotImplementedError`, etc.). Do not implement logic. Stop.
   Done when: tests COMPILE but still FAIL (assertion/panic, not compilation error).

3. **GREEN** -- Address the immediate error — NEVER "make the test pass" in
   one go. Scope check before every change: can this be fixed with
   ~function-scope work (~20 lines, one file)? YES → make the change, run
   tests, check the next error. NO → drill down by writing a failing unit
   test for the smallest piece needed, then route it through a standard TDD
   cycle with swapped roles. Only edit production files (except when drilling
   down). Paste output after each change.
   Done when: tests PASS with minimal implementation.

4. **DOMAIN (after GREEN)** -- Review the implementation for domain violations:
   anemic models, leaked validation, primitive obsession that slipped through.
   If violations found, raise a concern and propose a revision.
   Done when: types are clean and tests still pass.

5. **COMMIT** -- Run the full test suite. Stage all changes and create a git
   commit referencing the GWT scenario. Run `git status` after committing to
   verify no uncommitted files remain. This is a **hard gate**: no new RED
   phase may begin until this commit exists and the working tree is clean.
   Done when: git commit created, all tests passing, working tree clean.

After step 5, either start the next RED phase or tidy the code (structural
changes only, separate commit).

A compilation failure IS a test failure. Do not pre-create types to avoid
compilation errors. Types flow FROM tests, never precede them.

Domain review has veto power over primitive obsession and invalid-state
representability. Vetoes escalate to the human after two rounds.

### User-Facing Modes

**Guided mode** (`/tdd red`, `/tdd domain`, `/tdd green`, `/tdd commit`):
Each phase loads `references/{phase}.md` with detailed instructions for that
step. For experienced engineers who want explicit phase control. Works on
any harness -- no delegation primitives required. The human decides when to
advance phases.

**Automated mode** (`/tdd` or `/tdd auto`):
The system detects harness capabilities, selects an execution strategy, and
orchestrates the full cycle. The user sees working code, not sausage-making.
For verbose output showing phase transitions and evidence, use `/tdd auto --verbose`.

### Capability Detection (Automated Mode)

When automated mode activates, detect available primitives in this order:

1. **Subagents available?** Check for Agent tool. If present, use the
   **subagents** strategy with focused per-phase agents.
2. **Fallback.** Use the **chaining** strategy -- role-switch internally between
   phases within a single context.

Select the most capable strategy available. Do not attempt a higher strategy
when its primitives are missing.

**You are the orchestrator.** The agent reading this file performs capability
detection and dispatches directly. Do NOT spawn a single "orchestrator"
subagent to do it for you -- that hides work, bypasses strategy detection,
and pre-selects the wrong strategy. Whether you were invoked by `/tdd`, by
the pipeline, or by any other caller: you detect capabilities, you choose
the strategy, you spawn the phase agents yourself.

**After determining your strategy, read ONLY the entry-point file for that
strategy:**

| Strategy | Entry-point file |
|----------|-----------------|
| Subagents | `references/orchestrator.md` |
| Chaining | (no entry file -- follow the chaining section below) |

Do NOT read `orchestrator.md` when using chaining.

`orchestrator.md` references `references/shared-rules.md` for rules that
apply to all strategies (domain veto, outside-in progression, pipeline
integration, pre-implementation context checklist). Read `shared-rules.md`
when directed by your strategy's entry-point file.

### Execution Strategy: Chaining (Fallback)

Used when no delegation primitives are available. The agent plays each role
sequentially:

1. Load `references/red.md`. Execute the RED phase.
2. Load `references/domain.md`. Execute DOMAIN review of the test.
3. Load `references/green.md`. Execute the GREEN phase.
4. Load `references/domain.md`. Execute DOMAIN review of the implementation.
5. Load `references/commit.md`. Execute the COMMIT phase.
6. Repeat.

Role boundaries are advisory in this mode. The agent must self-enforce phase
boundaries: only edit file types permitted by the current phase (see
`references/phase-boundaries.md`).

### Execution Strategy: Subagents

Used when the Agent tool is available for spawning focused subagents. Each
phase runs in an isolated subagent with constrained scope.

- Spawn each phase agent using `Agent(subagent_type="<agent-name>", prompt="...")`
  with the prompt template in `references/{phase}-prompt.md`.
- The orchestrator follows `references/orchestrator.md` for coordination rules.
- **Structural handoff schema** (`references/handoff-schema.md`): every phase
  agent must return evidence fields (test output, file paths changed, domain
  concerns). Missing evidence fields = handoff blocked. The orchestrator does
  not proceed to the next phase until the schema is satisfied.
- Context isolation provides structural enforcement: each subagent receives
  only the files relevant to its phase.

### Named Team Member Personas (Subagent Strategy)

When `.claude/agents/` definitions exist (from the `ensemble-team` skill), the
subagent strategy uses named personas for ping and pong roles. The orchestrator
selects team members based on slice context, spawns them as subagents using
`Agent(subagent_type="<agent-name>", prompt="...")`, and collects results to pass
as context to the next subagent.

See `references/orchestrator.md` for coordination rules and
`references/ping-pong-pairing.md` for persona selection, rotation, and
pairing history.

### Phase Boundary Rules

Each phase edits only its own file types. This prevents drift. See
`references/phase-boundaries.md` for the complete file-type matrix.

| Phase | Can Edit | Cannot Edit |
|-------|----------|-------------|
| RED | Test files | Production code, type definitions |
| DOMAIN | Type definitions (stubs) | Test logic, implementation bodies |
| GREEN | Implementation bodies | Test files, type signatures |
| COMMIT | Nothing -- git operations only | All source files |

If blocked by a boundary, stop and return to the orchestrator (automated) or
report to the user (guided). Never circumvent boundaries.

### Walking Skeleton First

The first vertical slice must be a walking skeleton: the thinnest end-to-end
path proving all architectural layers connect. It may use hardcoded values or
stubs. Build it before any other slice. It de-risks the architecture and gives
subsequent slices a proven wiring path to extend.

### Outside-In TDD

Start from an acceptance test at the application boundary -- the point where
external input enters the system. Drill inward through unit tests. The outer
acceptance test stays RED while inner unit tests go through their own
red-green-domain-commit cycles. The slice is complete only when the outer
acceptance test passes.

A test that calls internal functions directly is a unit test, not an acceptance
test -- even if it asserts on user-visible behavior.

**Boundary enforcement by mode:**
- **Pipeline mode:** The CYCLE_COMPLETE evidence must include `boundary_type`
  and `boundary_evidence` on the acceptance test. The pipeline's TDD gate
  rejects evidence where the acceptance test calls internal functions directly.
- **Automated mode (non-pipeline):** The orchestrator checks boundary scope
  and re-delegates if the first test is not a boundary test. Advisory -- no
  gate blocks progression.
- **Guided mode:** The human is responsible for ensuring boundary-level tests.
  The skill text instructs correct behavior but cannot enforce it.

### Cycle-Complete Evidence

At the end of each complete RED-DOMAIN-GREEN-DOMAIN-COMMIT cycle, produce
a CYCLE_COMPLETE evidence packet containing: slice_id, acceptance_test
{file, name, output, boundary_type, boundary_evidence}, unit_tests
{count, all_passing, output}, domain_reviews [{phase, verdict, concerns}],
commits [{hash, message}], rework_cycles, team {ping, pong, domain_reviewer}.

When `pipeline-state` is provided in context metadata, the TDD skill
operates in **pipeline mode**: it receives a `slice_id` and stores
evidence to `.factory/audit-trail/slices/<slice-id>/tdd-cycles/cycle-NNN.json`.
When running standalone, the evidence is informational only (not stored).

See `references/cycle-evidence.md` for full schema.

### Harness-Specific Guidance

If running on Claude Code, also read `references/claude-code.md` for
harness-specific rules including hook-based enforcement. For maximum
mechanical enforcement, ask the bootstrap skill to install optional hooks
from `references/hooks/claude-code-hooks.json`.

## Enforcement Note

- **Guided mode**: Advisory. The human enforces by controlling phase transitions.
- **Chaining mode**: Advisory. The agent self-enforces phase boundaries.
- **Subagent mode**: Structural. Context isolation and handoff schemas enforce
  phase boundaries. Missing evidence blocks handoffs.
- **Pipeline mode**: Gating. Evidence gates reject incomplete phase transitions.
- **Optional hooks** (Claude Code): Mechanical. Pre-tool-use hooks block
  unauthorized file edits per phase. See `references/claude-code.md`.

**Hard constraints:**
- Phase boundary violation (wrong file type in wrong phase): `[H]`
- Domain veto escalation (contested design decision): `[RP]`
- Commit gate (no new RED before prior cycle committed): `[H]`

See `references/constraint-resolution.md` in the template directory for
pipeline rework budget conflicts and domain veto resolution in pipeline mode.

## Constraints

- **Chaining mode self-enforcement**: Self-enforcement means you produce the
  same file-type restrictions as if separate agents were enforcing them.
  Writing production code during RED phase violates this constraint even
  though no mechanism prevents it. If you catch yourself reasoning about
  why a phase boundary doesn't apply in chaining mode, you are violating it.
- **"~20 lines, one file" scope check**: This is a judgment heuristic, not a
  precise threshold. The spirit is: if the change touches multiple concerns,
  multiple files, or requires understanding distant code, it is too large for
  a single cycle. Do not game this by making a 40-line change across 2
  functions in one file and claiming it's "one file."

## Verification

After completing a cycle, verify:

- [ ] Every failing test was written BEFORE its implementation
- [ ] Domain review occurred after EVERY RED and GREEN phase
- [ ] Phase boundary rules were respected (file-type restrictions)
- [ ] Evidence (test output) was provided at each handoff
- [ ] Commit exists for every completed RED-GREEN cycle
- [ ] GREEN phase iterated one failure at a time (not full implementation in one pass)
- [ ] Working tree clean after every COMMIT (`git status` verified)
- [ ] Walking skeleton completed first (first vertical slice)

**HARD GATE -- COMMIT (must pass before any new RED phase):**

- [ ] All tests pass
- [ ] Git commit created with message referencing the current GWT scenario
- [ ] No new RED phase started before this commit was made

## Dependencies

This skill works standalone. For enhanced workflows, it integrates with:

- **domain-modeling:** Strengthens the domain review phases with parse-don't-validate,
  semantic types, and invalid-state prevention principles.
- **code-review:** Three-stage review (spec compliance, code quality, domain
  integrity) after TDD cycles complete.
- **mutation-testing:** Validates test quality by checking that tests detect
  injected mutations in production code.
- **ensemble-team:** Provides real-world expert personas for pair selection
  and mob review.

Missing a dependency? Install with:
```
npx skills add jwilger/agent-skills --skill domain-modeling
```
