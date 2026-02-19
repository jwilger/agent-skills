# AGENTS.md Generation Best Practices

AGENTS.md is the harness-agnostic instruction file that tells any AI
coding agent how to work in this project. Bootstrap generates it
following these principles.

## Keep It Small

The root AGENTS.md must stay under 32 KiB. It is a routing document,
not an encyclopedia. Point to skills for details -- do not repeat skill
content in AGENTS.md.

## Structure

Generate these sections in order:

### 1. Project Description

One paragraph describing what the project does. Source from README.md
or ask the user.

### 2. Build and Test Commands

Detected test runner and build commands. Example:

```markdown
## Build and Test

- **Language:** Rust
- **Test runner:** `cargo test`
- **Build:** `cargo build`
- **Lint:** `cargo clippy`
```

### 3. Conventions

Project-specific coding conventions. Start minimal:

```markdown
## Conventions

- One assertion per test
- Commit after each completed TDD cycle
- Domain types over primitives (`Email` not `String`)
```

### 4. Dos and Don'ts

Phase boundary rules (condensed from `tdd/references/phase-boundaries.md`):

```markdown
## Dos and Don'ts

- DO: Write one failing test before implementing
- DO: Run domain review after every RED and GREEN phase
- DO NOT: Edit production code during the RED phase
- DO NOT: Skip the COMMIT phase between TDD cycles
```

### 5. Workflow

TDD mode and available commands:

```markdown
## Workflow

This project uses the `tdd` skill in [automated/guided] mode.

- `/tdd` -- Run a full automated TDD cycle
- `/tdd red` -- Write one failing test (guided)
- `/tdd domain` -- Domain review and type creation (guided)
- `/tdd green` -- Implement minimal code (guided)
- `/tdd commit` -- Commit the completed cycle (guided)
```

### 6. Installed Skills

List installed skills with one-line descriptions. Do not duplicate
skill content.

### 7. Architecture

If `docs/ARCHITECTURE.md` exists, reference it. Otherwise, omit this
section until the first ADR is created.

## Managed Markers

Wrap generated sections in managed markers so re-runs can update
without destroying user additions:

```markdown
<!-- BEGIN MANAGED: bootstrap -->
(generated content here)
<!-- END MANAGED: bootstrap -->
```

Content outside managed markers is never touched on re-runs. Content
inside markers is regenerated from current configuration.

## Progressive Disclosure

AGENTS.md provides the summary. Skills provide the details. When the
agent needs deeper guidance (e.g., exact phase boundary rules), it
loads the relevant skill file. AGENTS.md tells it which skill to load.

## Monorepo Support

If the project is a monorepo (multiple `package.json`, `Cargo.toml`,
or similar at different paths), generate a root AGENTS.md with shared
conventions and a per-workspace section listing workspace-specific
build commands and test runners.
