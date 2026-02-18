# SDLC Enforcement Plugin for OpenCode

Adds mechanical enforcement for [Agent Skills](../../skills/) that are
otherwise advisory-only. Skills teach the methodology; this plugin enforces
it.

## What This Plugin Does

The portable Agent Skills (tdd-cycle, code-review, domain-modeling, etc.)
instruct the agent on correct behavior but cannot mechanically prevent
violations. This plugin adds enforcement:

| Enforcement | Mechanism | Skill Referenced |
|---|---|---|
| TDD phase boundaries | `tool.execute.before` blocks file edits that violate the active phase | tdd-cycle |
| Domain review gates | Blocks GREEN phase until domain review completes | tdd-cycle, domain-modeling |
| Code review reminders | `session.idle` and `stop` hooks remind before session end | code-review |
| Session state preservation | `experimental.session.compacting` preserves TDD phase across compaction | all |
| System prompt injection | `experimental.chat.system.transform` injects skill context | all |

## Custom Tools

The plugin registers four tools available to the agent:

| Tool | Purpose |
|---|---|
| `sdlc_set_phase` | Set the TDD phase (red, domain-after-red, green, domain-after-green, none). Activates file boundary enforcement. |
| `sdlc_domain_review` | Record domain review findings. Clears the review gate and advances the phase. |
| `sdlc_code_review` | Trigger a three-stage code review. Returns the review protocol template. |
| `sdlc_status` | Show current TDD phase, files modified, pending reviews. |

## Installation

### Project-Level (Recommended)

Copy the plugin file into your project's OpenCode plugin directory:

```bash
mkdir -p .opencode/plugin
cp plugin.ts .opencode/plugin/sdlc.ts
```

### Global

Copy to the global plugin directory:

```bash
mkdir -p ~/.config/opencode/plugin
cp plugin.ts ~/.config/opencode/plugin/sdlc.ts
```

### Dependencies

Add the plugin type package. Create or update `.opencode/package.json`:

```json
{
  "dependencies": {
    "@opencode-ai/plugin": "latest"
  }
}
```

OpenCode runs `bun install` at startup to install dependencies.

## How Enforcement Works

### TDD Phase Boundaries

When the agent (or user) sets a TDD phase with `sdlc_set_phase`, file edit
restrictions activate:

- **RED phase:** Only test files can be edited (`*_test.*`, `*.test.*`,
  `tests/`, `spec/`, `__tests__/`)
- **DOMAIN phase:** Only type definition files can be edited (`types/`,
  `domain/`, `models/`, `interfaces/`, `*.d.ts`)
- **GREEN phase:** Test files are blocked. Production code and type files
  are allowed.
- **none:** No restrictions. This is the default.

If the agent attempts to edit a file that violates the current phase, the
edit is blocked with an explanation of which phase allows that file type.

### Domain Review Gate

When entering RED or GREEN phase, a domain review is marked as pending.
The review gate is cleared by calling `sdlc_domain_review` with findings.
If the review is approved, the phase advances automatically:

```
domain-after-red (approved) -> green
domain-after-green (approved) -> none (cycle complete)
```

If rejected, the agent must revise the current work before proceeding.

### Session Idle Reminders

When the agent goes idle with a pending domain review or many files modified
without a code review, the plugin sends a reminder prompt.

### Stop Enforcement

If the session is about to end with a pending domain review, the plugin
prompts the agent to complete the review first.

## File Classification

The plugin classifies files by pattern matching:

**Test files:** `*_test.*`, `*.test.*`, `*_spec.*`, `*.spec.*`, paths
containing `tests/`, `spec/`, or `__tests__/`

**Type definition files:** paths containing `types/`, `domain/`, `models/`,
`interfaces/`, or files ending in `.d.ts`

**Production files:** everything else

These patterns cover common conventions for Go, Rust, TypeScript/JavaScript,
Python, Elixir, and Ruby. If your project uses non-standard patterns, adjust
the regex arrays in `plugin.ts`.

## Limitations

This plugin provides enforcement but not guarantees:

- File classification uses pattern matching and may misclassify files in
  unusual project structures. Adjust patterns as needed.
- The `stop` hook sends a reminder but cannot force the agent to comply.
- Phase state is in-memory and resets when OpenCode restarts. Use
  `sdlc_set_phase` to re-establish phase after restart.
- The plugin provides tools and gates for inline review. For parallel
  review with three focused subagents, see the Parallel Code Review
  section below.

For the strongest enforcement, use the skills and this plugin together.
The skills teach correct behavior; the plugin catches violations.

## Parallel Code Review

OpenCode supports parallel review via subagents. Instead of running the
three-stage code review sequentially (via the `sdlc_code_review` tool),
you can configure three independent reviewer subagents that run in
parallel, each focused on a single review stage. This is opt-in -- users
add the subagent configurations to their project's `opencode.json`.

The sequential `sdlc_code_review` tool remains available as the default
review mechanism. Parallel review is an alternative for teams that want
faster feedback from specialized reviewers.

### Subagent Configuration

Add these agent definitions to your project's `opencode.json`. Each
reviewer is read-only (no `write` or `edit` permissions) and receives a
prompt referencing the portable `code-review` and `domain-modeling`
skills from `jwilger/agent-skills`.

```json
{
  "agent": {
    "spec-reviewer": {
      "description": "Stage 1: Spec compliance review. Verifies tests match requirements and coverage is adequate.",
      "mode": "subagent",
      "model": "anthropic/claude-sonnet-4-20250514",
      "prompt": "You are a spec compliance reviewer. Focus on whether tests accurately reflect requirements, whether edge cases are covered, and whether the test-to-implementation mapping is correct. Reference the code-review skill for the full review protocol. Report findings as a structured list with severity levels.",
      "tools": {
        "write": false,
        "edit": false
      }
    },
    "quality-reviewer": {
      "description": "Stage 2: Code quality review. Checks style, performance, and maintainability.",
      "mode": "subagent",
      "model": "anthropic/claude-sonnet-4-20250514",
      "prompt": "You are a code quality reviewer. Focus on naming conventions, function complexity, error handling, performance pitfalls, and adherence to project style. Reference the code-review skill for the full review protocol. Report findings as a structured list with severity levels.",
      "tools": {
        "write": false,
        "edit": false
      }
    },
    "domain-reviewer": {
      "description": "Stage 3: Domain integrity review. Validates domain model consistency and ubiquitous language.",
      "mode": "subagent",
      "model": "anthropic/claude-sonnet-4-20250514",
      "prompt": "You are a domain integrity reviewer. Focus on whether changes respect bounded context boundaries, maintain ubiquitous language, and preserve domain invariants. Reference the domain-modeling skill for domain review criteria. Report findings as a structured list with severity levels.",
      "tools": {
        "write": false,
        "edit": false
      }
    }
  }
}
```

### Review Command

To spawn all three reviewers in parallel, add a `/review` command to
your `opencode.json` that forces subtask execution:

```json
{
  "commands": {
    "review": {
      "description": "Run parallel three-stage code review",
      "steps": [
        {
          "agent": "spec-reviewer",
          "subtask": true,
          "input": "Review the current changes for spec compliance."
        },
        {
          "agent": "quality-reviewer",
          "subtask": true,
          "input": "Review the current changes for code quality."
        },
        {
          "agent": "domain-reviewer",
          "subtask": true,
          "input": "Review the current changes for domain integrity."
        }
      ]
    }
  }
}
```

Each reviewer runs as an independent subtask with its own context window.
Results are collected and presented to the main agent when all three
complete.

## Ensemble Team Workflow

Projects with a `.team/` directory (created by the `ensemble-team` skill from
`jwilger/agent-skills`) can use team-based consensus planning, ping-pong TDD
pairing, and mob review. OpenCode's subagent support provides the multi-agent
coordination these workflows require.

## Compatibility

- **OpenCode:** Requires the `@opencode-ai/plugin` type package
- **Runtime:** Bun (OpenCode's plugin runtime)
- **Skills:** Works with all 13 Agent Skills from `jwilger/agent-skills`
