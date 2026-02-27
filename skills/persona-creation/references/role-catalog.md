# Role Catalog

This catalog lists recommended expert roles for assembling diverse review and
decision-making perspectives. Choose roles that create productive tension for
your specific problem.

## Core Roles

### DDD / Domain Modeling Expert

**When to use:** Designing domain types, reviewing data models, evaluating
bounded context boundaries, assessing ubiquitous language usage.

**Example experts:** Eric Evans, Vaughn Vernon, Scott Wlaschin

**Focus areas:**
- Primitive obsession and semantic types
- Bounded context boundaries
- Ubiquitous language consistency
- Aggregate design and invariant enforcement
- Parse-don't-validate patterns

### TDD Practitioner

**When to use:** Reviewing test quality, evaluating test-first discipline,
assessing test coverage strategy, designing test architecture.

**Example experts:** Kent Beck, James Shore, J.B. Rainsberger

**Focus areas:**
- Test-first discipline and RED-GREEN-REFACTOR cycle
- Test isolation and independence
- Outside-in vs. inside-out approaches
- Test naming and readability
- Avoiding test coupling to implementation

### Software Design / Simplicity Advocate

**When to use:** Evaluating code complexity, reviewing architecture for
over-engineering, assessing YAGNI compliance, simplification opportunities.

**Example experts:** Martin Fowler, Sandi Metz, Rich Hickey

**Focus areas:**
- Simple vs. easy distinction
- Refactoring patterns and code smells
- YAGNI and incremental design
- Naming and readability
- Reducing accidental complexity

### Security Specialist

**When to use:** Reviewing authentication/authorization, evaluating input
validation, assessing data handling, checking for common vulnerabilities.

**Example experts:** OWASP guidelines practitioners, Troy Hunt

**Focus areas:**
- Input validation and sanitization
- Authentication and authorization boundaries
- Data exposure risks
- Dependency vulnerabilities
- Secure defaults

### UX / Product Advocate

**When to use:** Evaluating user-facing behavior, reviewing acceptance
criteria from the user's perspective, assessing error messages and edge
cases that affect users.

**Example experts:** Don Norman, Steve Krug, Jakob Nielsen

**Focus areas:**
- User journey coherence
- Error state handling from user perspective
- Accessibility considerations
- Progressive disclosure in UI
- Acceptance criteria completeness for user scenarios

### Systems / Reliability Engineer

**When to use:** Reviewing infrastructure decisions, evaluating error
handling and resilience, assessing performance implications, deployment
strategy.

**Example experts:** Charity Majors, Cindy Sridharan

**Focus areas:**
- Observability (logs, metrics, traces)
- Error handling and graceful degradation
- Performance implications of design choices
- Deployment and rollback strategies
- Operational complexity

## Assembling a Team

### For Code Review

Select 2-3 roles that cover different aspects of the change:
- A domain change: DDD expert + TDD practitioner + simplicity advocate
- A security-sensitive change: Security specialist + DDD expert
- A user-facing change: UX advocate + TDD practitioner + DDD expert

### For Architecture Decisions

Select 3-4 roles that create productive tension:
- New service boundary: DDD expert + systems engineer + simplicity advocate
- Technology choice: Systems engineer + security specialist + UX advocate
- Data model design: DDD expert + TDD practitioner + systems engineer

### Rules for Selection

1. **Minimum 2, maximum 5.** Fewer than 2 provides no diversity. More than
   5 creates noise.
2. **At least one contrarian.** Include a role whose natural instinct
   conflicts with the proposed direction.
3. **Match to the problem.** Do not include a security specialist for a
   CSS refactoring review. Choose roles relevant to the actual decision.
4. **Rotate over time.** Do not use the same 3 roles for every decision.
   Different problems benefit from different perspectives.
