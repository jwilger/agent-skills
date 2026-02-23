# ADR PR Description Template

Use this template for the PR body when creating an ADR-as-PR. Replace every
section with real content from the decision conversation. Never leave
placeholder text.

```markdown
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

## Supersedes

- PR numbers if this replaces a previous decision
- Or "N/A"
```

## Without GitHub PRs: Commit Message Format

When GitHub PRs are not available, use the same template structure in the
commit message for the commit that updates `docs/ARCHITECTURE.md`:

```bash
git add docs/ARCHITECTURE.md
git commit -m "arch: <brief decision summary>

## Research Findings
- <Dependency>: <key finding> (source: <URL or file>)

## Context
What problem motivates this decision?

## Decision
We will <chosen approach> because <reasoning citing findings>.

## Alternatives Considered
- <Alternative>: <why not chosen, citing findings>

## Consequences
- Positive: <what improves>
- Negative: <trade-offs accepted>
"
```

The decision history lives in `git log -- docs/ARCHITECTURE.md`.

## Git Workflow for ADR PRs

```bash
# Always branch independently from main
git checkout main
git pull origin main
git checkout -b adr/<decision-slug>

# Update the living document
# Edit docs/ARCHITECTURE.md to reflect this decision

# Commit with conventional prefix
git add docs/ARCHITECTURE.md
git commit -m "arch: <brief decision summary>"

# Push and create labeled PR
git push -u origin HEAD
gh label create adr --description "Architecture Decision Record" --color "0075ca" 2>/dev/null || true
gh pr create --title "ADR: <Decision Title>" --label adr --body "<PR body from template above>"

# Do NOT merge -- the PR enters HOLD phase
# Return to main for other work
git checkout main
```

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
