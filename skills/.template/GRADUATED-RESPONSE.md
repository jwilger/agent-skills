# Graduated Response

When a hard constraint cannot be satisfied, the agent's behavior depends on
the constraint's severity tag. Every hard constraint in every skill MUST be
tagged with one of these three severities.

## Severity Levels

### `[RC]` Record & Continue

Non-critical constraints where documenting the deviation is sufficient.

**Agent behavior:** Log the constraint, the reason it couldn't comply, and
the alternative chosen. Then continue working.

**Use for:** Formatting preferences, documentation conventions, close
reasons, minor process steps that don't affect correctness.

### `[RP]` Record & Pause Item

Important constraints where the blocked work item should be set aside.

**Agent behavior:** Document the blocker with specifics. Move to unblocked
work. Surface the issue at the next human touchpoint.

**Use for:** Design decisions needing human input, domain vetoes that can't
resolve, missing prerequisites, reviewer unavailability, convention
violations that block a specific item but not the project.

### `[H]` Halt

Safety or correctness-critical constraints. Violation would produce
incorrect, dangerous, or unrecoverable outcomes.

**Agent behavior:** Stop all related work immediately. Surface the blocker.
Do not proceed. Do not attempt workarounds.

**Use for:** Phase boundary violations, gate bypasses, unverified claims,
fabricated responses, silent modifications without consent, skipped
investigation before fixes.

## Rules

1. Every hard constraint must be tagged with exactly one severity
2. The tag determines behavior when compliance is **genuinely impossible**
3. "Genuinely impossible" means: the required resource doesn't exist, the
   required party is unreachable, or the prerequisite cannot be satisfied
4. "Genuinely impossible" does NOT mean: "this would take too long," "I
   think I can skip this safely," or "this is inconvenient"
5. When the agent encounters a tagged constraint it cannot satisfy, it
   follows the tag's behavior -- no negotiation, no reinterpretation
