# SDLC Workflow

trigger: always

This project follows a structured software development lifecycle. These
instructions govern all code changes.

## Test-Driven Development Cycle

All code changes follow the red/domain/green/domain cycle:

1. **Red:** Write ONE failing test. Run it. Verify it fails for the expected
   reason. Stop.
2. **Domain review:** Check the test for primitive obsession. Replace raw
   primitives with domain types (structs, enums, interfaces). Use
   `unimplemented!()`/`todo!()`/`raise NotImplementedError` stubs. Stop.
3. **Green:** Write the minimal code to make the test pass. Nothing extra.
   Run the test. Verify it passes. Stop.
4. **Domain review:** Check the implementation for domain violations — anemic
   models, leaked domain logic, missing invariants. Stop.
5. Repeat from step 1 for the next behavior.

Never skip domain review steps. Pause and check for primitive obsession even
on trivial changes.

### File Ownership by Phase

- **Red phase:** Only edit test files (`*_test.*`, `*.test.*`, `tests/`, `spec/`)
- **Domain phase:** Only edit type definitions (structs, enums, interfaces, traits)
- **Green phase:** Only edit implementation code (`src/`, `lib/`, `app/`)

Do not mix phases. If you need to edit a test while implementing, go back to
red phase first.

## Domain Modeling

- Use domain types, not primitives. `Email` not `String`, `Money` not `float`.
- Parse, don't validate: construct valid objects at the boundary, reject
  invalid input at construction time.
- Make invalid states unrepresentable through the type system.
- Check for primitive obsession after every test and every implementation.

## Architecture Decisions

Before making structural changes (new modules, dependencies, pattern changes),
check for `ARCHITECTURE.md` or `docs/ARCHITECTURE.md`. Follow existing
decisions. If you need to diverge, document the decision and rationale as an
ADR before implementing.

## Code Review Checklist

Before considering work complete:

1. **Spec compliance:** Every acceptance criterion has a corresponding test.
2. **Code quality:** No dead code, no duplication, clear naming, minimal
   complexity.
3. **Domain integrity:** No primitive obsession, domain types used correctly,
   invariants enforced by types.

## When You Need Input

When you hit a decision requiring human judgment — business rule ambiguity,
architecture trade-offs, scope questions — stop and ask. Present:
- Context (what you found)
- 2-4 specific options with implications
- Your recommendation

Do not guess. Do not pick the "most likely" option silently.

## Testing

Detect the project's test runner:
- `Cargo.toml`: `cargo test`
- `package.json` with vitest: `npx vitest`
- `package.json` with jest: `npx jest`
- `pyproject.toml`/`setup.py`: `pytest`
- `go.mod`: `go test ./...`
- `mix.exs`: `mix test`

Always run tests after writing them (red) and after implementing (green).

## Conventions

- One assertion per test.
- Commit after each completed red/green cycle.
- When blocked on design, state options and trade-offs rather than choosing
  silently.

## Installed Skills

This project uses skills from `jwilger/agent-skills`. If your environment
supports Agent Skills, these provide detailed methodology:

- `tdd-cycle` — Red/domain/green/domain workflow
- `domain-modeling` — Parse-don't-validate, primitive obsession detection
- `code-review` — Three-stage review protocol
- `architecture-decisions` — ADR format and governance
- `event-modeling` — Discovery, swimlanes, GWT scenarios
- `debugging-protocol` — Systematic 4-phase debugging
- `user-input-protocol` — Structured checkpoint format
- `memory-protocol` — Knowledge persistence patterns
- `task-management` — Work breakdown and dependency tracking
- `mutation-testing` — Test quality verification
- `atomic-design` — UI component hierarchy
