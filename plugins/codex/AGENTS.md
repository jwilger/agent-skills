# SDLC Workflow Instructions

This project follows a structured software development lifecycle. These
instructions apply to all files you modify.

## Workflow: Test-Driven Development

All code changes follow the red/domain/green/domain cycle:

1. **Red:** Write ONE failing test. Run it. Verify it fails for the expected
   reason. Stop.
2. **Domain review:** Review the test for primitive obsession. Create domain
   types (structs, enums, interfaces) where primitives are used. Use
   `unimplemented!()`/`todo!()`/`raise NotImplementedError` stubs. Stop.
3. **Green:** Implement the minimal code to make the test pass. No extra
   features. Run the test. Verify it passes. Stop.
4. **Domain review:** Review the implementation for domain violations --
   anemic models, leaked domain logic, missing invariants. Stop.
5. Repeat from step 1 for the next behavior.

Do not skip domain review steps. Even for "trivial" changes, pause and check
for primitive obsession and invalid state representability.

## File Ownership by Phase

- **Red phase:** Only edit test files (`*_test.*`, `*.test.*`, `tests/`, `spec/`)
- **Domain phase:** Only edit type definitions (structs, enums, interfaces, traits)
- **Green phase:** Only edit implementation code (`src/`, `lib/`, `app/`)

Do not mix phases. If you need to edit a test while implementing, stop and
go back to the red phase.

## Domain Modeling Rules

- Use domain types, not primitives. `Email` not `String`, `Money` not `float`.
- Parse, don't validate: construct valid objects at the boundary, reject invalid
  input at construction time.
- Make invalid states unrepresentable through the type system.
- Check for primitive obsession after every test and every implementation.

## Architecture Decisions

Before making structural changes (new modules, dependency additions, pattern
changes), check for an `ARCHITECTURE.md` or `docs/ARCHITECTURE.md` file. If
one exists, follow its decisions. If you need to diverge, document the
decision and rationale before implementing.

## Code Review Checklist

Before considering work complete, verify:

1. **Spec compliance:** Every acceptance criterion has a corresponding test.
2. **Code quality:** No dead code, no duplication, clear naming, minimal
   complexity.
3. **Domain integrity:** No primitive obsession, domain types used correctly,
   invariants enforced by types.

## Parallel Code Review

The sequential Code Review Checklist above remains the default review approach.
As an alternative, Codex supports spawning three parallel reviewer agents that
each focus on a single review stage simultaneously, reducing total review time.

### Reviewer Personas

Three reviewer personas are provided in `agents/reviewers/`:

- **`spec-reviewer.md`** -- Stage 1: Spec Compliance. Checks that every
  acceptance criterion has corresponding code and tests.
- **`quality-reviewer.md`** -- Stage 2: Code Quality. Checks naming, error
  handling, dead code, test coverage, and security.
- **`domain-reviewer.md`** -- Stage 3: Domain Integrity. Checks primitive
  obsession, compile-time enforcement, boundary violations, and type safety.

All three are read-only -- they examine code but do not modify it.

### Protocol

To run a parallel code review, use the spawn/wait/close pattern:

```
# 1. Spawn all three reviewers in parallel
spawn_agent("spec-reviewer", persona="agents/reviewers/spec-reviewer.md",
    task="Review the changes for spec compliance against: [task description]")
spawn_agent("quality-reviewer", persona="agents/reviewers/quality-reviewer.md",
    task="Review the changed files for code quality issues")
spawn_agent("domain-reviewer", persona="agents/reviewers/domain-reviewer.md",
    task="Review the changed files for domain integrity violations")

# 2. Wait for all three to complete
wait("spec-reviewer")
wait("quality-reviewer")
wait("domain-reviewer")

# 3. Read results from each reviewer and synthesize
# Combine the three stage results into a single review summary:
#   REVIEW SUMMARY
#   Stage 1 (Spec Compliance): PASS/FAIL
#   Stage 2 (Code Quality): PASS/FAIL
#   Stage 3 (Domain Integrity): PASS/FAIL
#   Overall: APPROVED / CHANGES REQUIRED

# 4. Close the agents
close_agent("spec-reviewer")
close_agent("quality-reviewer")
close_agent("domain-reviewer")
```

If any stage returns FAIL, address the required actions before considering work
complete.

### When to Use Parallel Review

- **Use parallel review** when the changeset is large or when review time is a
  bottleneck. All three stages run simultaneously instead of sequentially.
- **Use the sequential checklist** for small changes where spawning three agents
  would add unnecessary overhead.

## Testing Commands

Detect the project's test runner and use it:

- `Cargo.toml` present: `cargo test`
- `package.json` with vitest: `npx vitest`
- `package.json` with jest: `npx jest`
- `pyproject.toml` or `setup.py`: `pytest`
- `go.mod`: `go test ./...`
- `mix.exs`: `mix test`

Always run tests after writing them (red) and after implementing (green).
Never assume a test will pass or fail -- run it and observe.

## Conventions

- One assertion per test. Multiple behaviors need multiple tests.
- Commit after each completed red/green cycle, not mid-cycle.
- When encountering errors, search project memory or docs before debugging
  from scratch.
- When blocked on a design decision, state the options and trade-offs rather
  than choosing silently.

## Installed Skills

This project uses skills from `jwilger/agent-skills`. If you have skill
support, these skills provide detailed guidance:

- `tdd-cycle` -- Red/domain/green/domain workflow
- `domain-modeling` -- Parse-don't-validate, primitive obsession detection
- `code-review` -- Three-stage review protocol
- `architecture-decisions` -- ADR format and governance
- `event-modeling` -- Discovery, swimlanes, GWT scenarios
- `debugging-protocol` -- Systematic 4-phase debugging
- `user-input-protocol` -- Structured checkpoint format
- `memory-protocol` -- Knowledge persistence patterns
- `task-management` -- Work breakdown and dependency tracking
- `mutation-testing` -- Test quality verification
- `atomic-design` -- UI component hierarchy
