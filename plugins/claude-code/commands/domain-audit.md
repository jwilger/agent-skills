---
description: INVOKE to review domain types for primitive obsession and safety gaps
invocation: user
---

# Domain Audit

On-demand domain type audit. Identifies opportunities to strengthen the type
system: primitive obsession, structural-vs-semantic types, runtime checks that
could be compile-time.

## Methodology

Follows `skills/domain-modeling/SKILL.md` for domain modeling principles.

## When to Use

- On demand for a quick domain quality check
- After refactoring to verify domain integrity
- Before PR as a final domain quality gate

## Execution

Invokes the domain agent with a focused audit prompt:

1. Read domain/model files
2. Read test files for runtime assertions
3. For each type: check semantic vs structural, check for confusion potential,
   check for runtime-to-compile-time opportunities
4. Report findings in actionable format

## Output Format

```
FILE: <path>
ISSUE: <structural type | missing domain type | runtime check could be compile-time>
CURRENT: <what exists>
PROPOSED: <what it should be>
RATIONALE: <one sentence>
```

## Integration with TDD Cycle

This runs automatically in lightweight form after RED and GREEN phases via the
domain agent. The `/domain-audit` command is for deeper, on-demand analysis.
