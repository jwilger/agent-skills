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
- The plugin does not spawn subagents for domain or code review -- it
  provides the tools and gates, and the agent performs the review inline.

For the strongest enforcement, use the skills and this plugin together.
The skills teach correct behavior; the plugin catches violations.

## Compatibility

- **OpenCode:** Requires the `@opencode-ai/plugin` type package
- **Runtime:** Bun (OpenCode's plugin runtime)
- **Skills:** Works with all 13 Agent Skills from `jwilger/agent-skills`
