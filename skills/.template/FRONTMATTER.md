# SKILL.md Frontmatter Reference

This document specifies every frontmatter field used in skills for this
repository. Fields follow the Agent Skills specification
(agentskills.io/specification) with project-specific extensions in `metadata`.

## Required Fields (Agent Skills Spec)

### `name`

The skill identifier. Must match the parent directory name.

- **Type:** string
- **Constraints:** 1-64 characters, lowercase alphanumeric and hyphens only,
  no leading/trailing/consecutive hyphens
- **Examples:** `tdd`, `domain-modeling`, `code-review`

### `description`

What this skill does and when to activate it. Agents read this at startup
(~100 tokens budget) to decide whether to activate the skill, so include
keywords that match relevant tasks.

- **Type:** string
- **Constraints:** 1-1024 characters, non-empty
- **Good:** "Adaptive test-driven development cycle. Detects harness
  capabilities and routes to guided or automated mode. Activate when writing
  tests, implementing features, or doing test-driven development."
- **Bad:** "TDD stuff."

## Optional Fields (Agent Skills Spec)

### `license`

License name or reference to a bundled LICENSE file.

- **Type:** string
- **Default for this repo:** `CC0-1.0`

### `compatibility`

Environment requirements -- intended platforms, system packages, network needs.
Most skills in this repo are universal and do not need this field.

- **Type:** string
- **Constraints:** Max 500 characters
- **Example:** `Requires git and a test runner (jest, pytest, cargo test, etc.)`

### `metadata`

Arbitrary key-value map for additional properties. The Agent Skills spec
reserves this for client-specific extensions. This repository uses it for
project-specific fields documented below.

### `allowed-tools`

Space-delimited list of pre-approved tools the skill may use. Experimental;
support varies by agent implementation.

- **Type:** string
- **Example:** `Bash(git:*) Bash(npm:*) Read`

## Project-Specific Fields (in `metadata`)

These fields live inside the `metadata` block and are specific to this
repository's skill set. They enable cross-skill coordination.

### `metadata.author`

Who wrote this skill.

- **Type:** string
- **Value for this repo:** `jwilger`

### `metadata.version`

Semantic version of this skill. Increment when practices change.

- **Type:** string
- **Example:** `"1.0"`, `"2.1"`

### `metadata.requires`

Other skills this skill depends on. Listed by skill name. When this skill
activates and a required skill is not installed, the skill should detect
the absence and recommend installation (see Dependencies section in body).

- **Type:** list of strings
- **Default:** `[]` (no dependencies)
- **Examples:**
  ```yaml
  requires: []                        # standalone
  requires: [debugging-protocol]      # needs one skill
  requires: [tdd, domain-modeling]  # needs two skills
  ```
- **Rules:**
  - Dependencies must form a DAG (no circular dependencies)
  - Reference skills by name, never assume internal structure
  - Missing dependencies degrade gracefully (recommend, do not fail)

### `metadata.context`

What project context this skill needs to work effectively. Informs
harness configuration and fleet dispatchers about what to provide.

- **Type:** list of strings
- **Default:** `[]`
- **Recognized values:**
  - `test-files` -- needs access to test files
  - `domain-types` -- needs access to type definitions
  - `source-files` -- needs access to production source code
  - `event-model` -- needs event modeling documents
  - `architecture-decisions` -- needs ADR documents
  - `design-system` -- needs design system specification artifact
  - `git-history` -- needs git log / diff access
  - `ci-results` -- needs CI/CD pipeline results
  - `task-state` -- needs task/todo list state
- **Example:**
  ```yaml
  context: [test-files, domain-types, source-files]
  ```

### `metadata.phase`

Which SDLC phase this skill primarily serves. Informational metadata for
UX layering (e.g., grouping skills in a menu). This is NOT a sequencing
constraint -- skills in the "build" phase do not require "understand" phase
skills to have run first.

- **Type:** string (one of four values)
- **Values:**
  - `understand` -- discovery, event modeling, requirements
  - `decide` -- architecture decisions, domain modeling
  - `build` -- TDD, implementation, debugging
  - `ship` -- code review, PR, mutation testing
- **Default:** none (omit if not clearly in one phase)
- **Example:**
  ```yaml
  phase: build
  ```

### `metadata.standalone`

Whether this skill provides value when installed alone, without other skills
from this set.

- **Type:** boolean
- **Default:** `true`
- **Example:**
  ```yaml
  standalone: true   # works alone
  standalone: false  # needs other skills to be useful
  ```

## Complete Frontmatter Example

```yaml
---
name: tdd
description: >-
  Adaptive test-driven development cycle. Detects harness capabilities
  and routes to guided or automated mode. Invoke with /tdd for automated
  or /tdd red|domain|green|commit for guided.
license: CC0-1.0
metadata:
  author: jwilger
  version: "1.0"
  requires: []
  context: [test-files, domain-types, source-files]
  phase: build
  standalone: true
---
```

## Token Budgets

The SKILL.md body (everything after frontmatter) must stay within these
limits to ensure compatibility across harnesses with varying context windows:

| Tier | Skills | Budget |
|------|--------|--------|
| Tier 0 (Bootstrap) | `bootstrap` | 1000 tokens |
| Tier 1 (Core Process) | `tdd`, `domain-modeling`, `code-review`, `architecture-decisions`, `event-modeling`, `ticket-triage`, `design-system`, `refactoring`, `pr-ship` | 3000 tokens |
| Tier 2 (Team Workflows) | `ensemble-team`, `task-management` | 4000 tokens |
| Tier 3 (Utility) | `debugging-protocol`, `user-input-protocol`, `memory-protocol`, `agent-coordination`, `session-reflection`, `error-recovery` | 3000 tokens |
| Tier 4 (Factory Pipeline) | `pipeline`, `ci-integration`, `factory-review` | 3000 tokens |
| Advanced | `mutation-testing`, `atomic-design` | 3000 tokens |

The Agent Skills spec recommends under 5000 tokens and under 500 lines for
the SKILL.md body. Our tighter budgets ensure skills work well on harnesses
with smaller context windows and leave room for project-specific context.

Move detailed reference material, extended examples, and supplementary
documentation to `references/` files. The agent loads these on demand.

## Body Section Order

After the frontmatter, the SKILL.md body follows this section order:

1. **Value** -- Which XP value(s) this serves (1-2 sentences)
2. **Purpose** -- What this skill teaches (2-3 sentences)
3. **Practices** -- Concrete instructions (the main body, largest section)
4. **Enforcement Note** -- What this skill can/cannot guarantee
5. **Verification** -- Self-check checklist (binary, observable criteria)
6. **Dependencies** -- Integration points and install commands

Every section is required. Keep Practices as the dominant section. Minimize
all others to a few sentences each.
