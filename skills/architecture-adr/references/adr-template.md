# ADR PR Body Template

Use this template as the body of the pull request for an Architecture
Decision Record. Fill in each section. Do not remove sections -- write
"N/A" if a section does not apply.

---

## PR Body Template

```markdown
## ADR: [Short Decision Title]

**Category:** [Technology stack | Domain architecture | Integration patterns |
Cross-cutting concerns | Deployment and infrastructure | Data management]

**Status:** [RESEARCH | DRAFT | HOLD | MERGE]

### Research Findings

Summarize what you learned during the RESEARCH phase. Cite sources.

- Finding 1 (source: [link or reference])
- Finding 2 (source: [link or reference])
- Finding 3 (source: [link or reference])

### Context

What is the situation that requires this decision? What forces are at play?
State facts, not opinions. Two to four sentences.

### Decision

State the decision clearly in one to two sentences. This is what gets
recorded in docs/ARCHITECTURE.md.

### Alternatives Considered

For each alternative:

**Alternative: [Name]**
- Pros: [list]
- Cons: [list]
- Why rejected: [one sentence]

### Consequences

What becomes easier or harder as a result of this decision?

- Positive: [list]
- Negative: [list]
- Neutral: [list]

### References

- [Link to documentation, benchmark, article, etc.]
- [Link to related code or prior art in the codebase]

### Supersedes

[Link to previous ADR PR if this replaces an earlier decision, or "N/A"]
```

---

## Git Workflow

```bash
# 1. Create the ADR branch off main
git checkout main
git pull
git checkout -b adr/<slug>

# 2. Update docs/ARCHITECTURE.md with the decision result ONLY
#    Add one line under the appropriate category heading.
#    Example: "## Authentication\nWe use OAuth 2.0 with PKCE for all client authentication."

# 3. Commit
git add docs/ARCHITECTURE.md
git commit -m "ADR: <short decision title>"

# 4. Push and open PR with ADR body
git push -u origin adr/<slug>
# Open PR with the template above as the body

# 5. After approval, a reviewer (not the author) merges
```

---

## docs/ARCHITECTURE.md Format

The architecture file contains decision RESULTS only. No rationale, no
alternatives, no status tracking. Each entry is a heading and one to three
sentences stating what was decided.

Example:

```markdown
# Architecture Decisions

## Authentication
We use OAuth 2.0 with PKCE for all client authentication.

## Database
PostgreSQL 16 is the primary data store. One database per bounded context.

## Error Handling
All errors use typed error enums. No string errors. No panic in library code.
```

The full reasoning lives in the PR body, linked from git history. To find
the rationale for any decision, search closed PRs with the `adr/` branch
prefix.

---

## Decision Categories Checklist

Use this checklist during the RESEARCH phase to ensure you have considered
all relevant dimensions of the decision:

- [ ] **Impact scope:** How many components or teams does this affect?
- [ ] **Reversibility:** How hard is it to change this decision later?
- [ ] **Dependencies:** What other decisions does this depend on or enable?
- [ ] **Constraints:** What technical, business, or regulatory constraints apply?
- [ ] **Migration:** If changing from an existing approach, what is the
      migration path?
- [ ] **Operational impact:** How does this affect deployment, monitoring,
      or incident response?
