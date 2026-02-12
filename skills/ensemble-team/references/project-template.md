# Project Owner Constraints Template (PROJECT.md)

Use this template to generate the project's PROJECT.md. Replace `{{placeholders}}`
with project-specific values.

---

```markdown
# {{project_name}}

{{project_description}}

> **This document contains project owner constraints.** The team must follow these rules.
> Changes to this document require project owner approval. For team-owned practices and
> conventions, see `TEAM_AGREEMENTS.md`.

## Tech Stack

{{tech_stack_section}}

## Development Mandates

These are non-negotiable practices for the project:

- **Test-Driven Development**: Every feature is built using strict TDD
  (Red-Green-Refactor). No production code without a failing test.
- **Mob/Ensemble Programming**: All production code is written by the mob. No solo
  commits to production code.
- **Consensus Decision-Making**: The team operates by consensus. No single technical
  lead or decision-maker. If consensus is not reached after 10 rounds of substantive
  discussion, the decision is escalated to the project owner for a final call.
- **Driver-Reviewer Mob Model**: At most one agent (the Driver) may modify files at
  any time. The remaining agents participate as Reviewers via read-only access and
  messaging. All team members must reach consensus before a task is considered complete.
- **Code Quality Gates**: {{quality_gate_description}}

## Environment & Tooling

{{environment_section}}

## Scope

### Must Have
{{must_have_items}}

### Should Have
{{should_have_items}}

### Could Have
{{could_have_items}}

### Out of Scope
{{out_of_scope_items}}
```
