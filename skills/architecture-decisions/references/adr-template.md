# ADR File Template

Save ADRs as `docs/decisions/YYYYMMDD-<slug>.md` (e.g.,
`docs/decisions/20240315-database-choice.md`). Replace every section with
real content. Never leave placeholder text.

**Supersession fields:**
- `Supersedes` — list ADR files this decision replaces (or N/A)
- `Superseded by` — filled in when a newer ADR replaces this one

No explicit status field is needed. An ADR on an open PR is de-facto
proposed. A merged ADR that isn't superseded is de-facto approved.
When a new ADR supersedes this one, update this file's `Superseded by`
field in the same PR.

```markdown
# ADR: <Title>

**Date:** YYYY-MM-DD
**Supersedes:** N/A
**Superseded by:** N/A

## Research Findings

Summarize what was learned during the RESEARCH phase. Each finding must
reference the specific source (documentation URL, source file, API
response, etc.).

### Dependency: <Name>
- **Source:** <URL or file path consulted>
- **Key finding:** What the dependency actually does/requires
- **Constraint (if any):** If this dependency already decides the
  question, state it here

### Dependency: <Another Name>
- **Source:** <URL or file path consulted>
- **Key finding:** What was verified
- **Constraint (if any):** If applicable

## Context

What problem motivates this decision? What constraints exist? Why now?
Reference specific research findings that establish the constraints.

## Decision

State the decision in active voice, citing research findings:
- "We will use PostgreSQL for event storage because [Research Findings:
  PostgreSQL] confirmed native JSONB indexing meets our query patterns."
- "We will adopt a monolith-first architecture because..."

## Alternatives Considered

### Alternative Name
- **Pros**: Concrete advantages
- **Cons**: Concrete disadvantages (cite research findings)
- **Why not chosen**: Specific reasoning grounded in verified facts

### Another Alternative
- **Pros**: Concrete advantages
- **Cons**: Concrete disadvantages (cite research findings)
- **Why not chosen**: Specific reasoning grounded in verified facts

## Consequences

### Positive
- What improves as a result of this decision

### Negative
- What trade-offs we accept (be honest)

### Neutral
- What changes without clear positive/negative valence

## References

- Links to relevant documentation, benchmarks, or prior art
- Or "N/A"
```

## Access Guard Files

On the first ADR in a project, create these two files verbatim:

**`docs/decisions/CLAUDE.md`** and **`docs/decisions/AGENTS.md`**:

```
These files are Architecture Decision Records (ADRs). They document the
reasoning behind past architectural choices.

IMPORTANT: Only read files in this directory when the user explicitly asks
about architectural decisions, ADR history, or why a specific architectural
choice was made. Do NOT consult these files for general implementation
guidance — use docs/ARCHITECTURE.md instead.
```

These files exploit harness auto-loading behavior to restrict agents from
using historical ADR rationale as current directives.

## Git Workflow for ADR PRs

```bash
# Always branch independently from main
git checkout main
git pull origin main
git checkout -b adr/<decision-slug>

# Create the ADR file
mkdir -p docs/decisions
# Write docs/decisions/YYYYMMDD-<slug>.md

# On first ADR: create access guard files
# Write docs/decisions/CLAUDE.md and docs/decisions/AGENTS.md

# Update the living document
# Edit docs/ARCHITECTURE.md to reflect this decision

# Commit and push
git add docs/decisions/ docs/ARCHITECTURE.md
git commit -m "arch: <brief decision summary>"
git push -u origin HEAD

# Create labeled PR
gh label create adr --description "Architecture Decision Record" --color "0075ca" 2>/dev/null || true
gh pr create --title "ADR: <Decision Title>" --label adr \
  --body "This PR adds an Architecture Decision Record. See the ADR file for the full record."

# Do NOT merge -- the PR enters HOLD phase
# Return to main for other work
git checkout main
```

## Without GitHub PRs: Commit Message Format

When GitHub PRs are not available, the ADR file is still committed on
the branch and merged via the normal git flow. Use the commit message:

```bash
git commit -m "arch: <brief decision summary>

Adds docs/decisions/YYYYMMDD-<slug>.md

See the ADR file for research findings, decision, and consequences.
"
```

The decision history lives in `git log -- docs/decisions/`.

## Decision Categories Checklist

Use this when inventorying decisions for a new project or major redesign:

**Technology Stack:**
- [ ] Language/runtime
- [ ] Framework
- [ ] Database / event store
- [ ] Messaging / queuing (if needed)

**Domain Architecture:**
- [ ] Bounded context boundaries
- [ ] Aggregate identification
- [ ] Service decomposition strategy

**Integration Patterns:**
- [ ] External API interaction (sync/async)
- [ ] Anti-corruption layer design
- [ ] Data import/export mechanisms

**Cross-Cutting Concerns:**
- [ ] Authentication/authorization
- [ ] Observability (logging, metrics, tracing)
- [ ] Error handling and resilience
