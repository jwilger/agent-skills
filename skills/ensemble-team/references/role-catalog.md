# Role Catalog

Reference for determining what roles a project needs and how to research the best
person to fill each one. This is NOT a fixed list of names — every role requires
active research to find the ideal expert for the specific project.

## Determining Roles

### Always-Include Roles

Every ensemble team needs these five disciplines covered, regardless of project type:

| Role | Purpose | What Goes Wrong Without It |
|------|---------|---------------------------|
| Product Manager | Define what to build and why | Team builds features nobody needs; scope creeps |
| Development Practice Lead | TDD discipline, refactoring, process rigor | Tests get skipped; "we'll clean it up later" never happens |
| Domain Architect | Model business domain with types and workflows | Naming drift, primitive obsession, leaky abstractions |
| Lead Engineer | Idiomatic patterns, ecosystem choices, production readiness | Non-idiomatic code, poor dependency choices, unobservable systems |
| UX Specialist | Ensure the product is usable and intuitive | Users can't figure out how to use the thing |

### Conditional Roles

Add these based on project characteristics:

| Role | Add When | What Goes Wrong Without It |
|------|----------|---------------------------|
| UI/Visual Designer | Project has a visual UI | Inconsistent spacing, no visual hierarchy, design-by-developer |
| Accessibility Specialist | Project has a user-facing interface | Inaccessible = broken for ~15-20% of users |
| CSS/Design Engineer | Web project with custom styling | Unmaintainable CSS, no design token system, inconsistent styling |
| Frontend Framework Specialist | SPA or framework-based frontend | Misuse of framework patterns, poor state management |
| Hypermedia Architect | Server-rendered HTML, HTMX, progressive enhancement | Over-engineering the client side, breaking progressive enhancement |
| DevOps/Infrastructure | Complex deployment, cloud infra, containerization | "Works on my machine"; brittle deploys |
| Security Specialist | Auth-heavy, financial, or sensitive data | Vulnerabilities ship unnoticed |
| Data/ML Engineer | Data pipelines, ML models, analytics | Poor data modeling, unvalidated models |
| API/Integration Specialist | Public APIs, complex integrations, microservices | Inconsistent API design, versioning nightmares |
| Mobile Specialist | Native mobile apps | Platform anti-patterns, poor native UX |

### Team Size Guidelines

- **Minimum viable**: 5 (the always-include roles)
- **Recommended**: 7-9 (always-include + 2-4 conditional)
- **Maximum**: 10 (communication overhead grows quadratically beyond this)
- **Odd numbers preferred**: Helps break ties in day-to-day votes

## Researching the Right Expert

For each role, research and select a real-world person. Do NOT pick from a memorized
list — actively search for the best fit given the project's specific technology,
domain, and needs.

### Research Process

For each role on the team:

1. **Identify the specific need**: What technology, framework, or domain is this
   project using? A "Lead Engineer" for a Rust project requires different expertise
   than one for a Python project.

2. **Search for candidates**: Use WebSearch to find:
   - Authors of the definitive book(s) for the relevant technology/domain
   - Creators or lead maintainers of the key tools/frameworks being used
   - Recognized practitioners who've shipped production systems (not just academics)
   - Active voices whose current thinking is well-documented (blogs, talks, recent books)

3. **Evaluate each candidate** against these criteria:
   - **Published authority**: Have they written the book, created the tool, or given the
     defining talk? The profile needs to be grounded in real published material.
   - **Distinctive voice**: Do they have characteristic opinions, phrases, and style that
     can be captured in a profile? A profile that could belong to anyone is useless.
   - **Practical experience**: Have they built real systems, not just theorized? The
     advice in the profile must come from production experience.
   - **Complementary perspective**: Does this person naturally focus on a different
     aspect of quality than the other team members? Avoid overlapping perspectives.
   - **Searchable body of work**: Can you find enough material (books, blog posts,
     conference talks, open source work) to write an authentic profile? If the person's
     views aren't well-documented, the profile will be shallow.

4. **Verify the candidate**: Before proposing to the user, confirm:
   - Their credentials are accurate (correct book titles, organizations, roles)
   - They're still relevant (not exclusively associated with outdated technology)
   - Their expertise genuinely matches the project's needs

### What Makes a Good Expert Selection

**Good**: The person is the recognized authority for exactly the technology or practice
this project uses. Their published work directly informs how the team should build.

**Bad**: The person is famous but their expertise doesn't match the project. Don't pick
a React expert for a server-rendered HTMX project just because they're well-known.

### Presenting to the User

For each proposed expert, present:
- **Name and credentials**: Who they are and why they're the right fit
- **Key published work**: Books, tools, talks that ground the persona
- **Why this person for this project**: Specific connection between their expertise
  and the project's needs
- **What they'd focus on**: The specific aspect of quality they'd own

Let the user approve, swap, or remove any selection. If the user suggests someone,
research that person with the same rigor before creating their profile.
