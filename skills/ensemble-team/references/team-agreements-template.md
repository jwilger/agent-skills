# Team Agreements: Discussion Topics

This is NOT a template to fill in with pre-canned answers. It is a list of **problems
the team must discuss and reach consensus on** during their formation session.

For each topic, the problem is stated and context is provided. The team debates and
decides their own approach. The output is a `TEAM_AGREEMENTS.md` file that captures
the team's actual decisions.

## How to Use This

During team formation (Phase 5 of the skill workflow), the team holds a formation
session. The Practice Lead facilitates. For each topic below:

1. Present the **problem** to the team
2. Share the **context** (why this matters, what goes wrong without an agreement)
3. Let the team **discuss and propose** their approach
4. Reach **consensus** (all members consent or stand aside)
5. Record the agreement in `TEAM_AGREEMENTS.md`

The team may also identify topics not listed here. This list is non-exhaustive.

---

## Topics to Discuss

### 1. How do we decide what to build?

**Problem**: Without a shared approach to deciding what to build, teams either build
whatever the loudest voice suggests or follow a spec rigidly without questioning
whether it solves the right problem.

**Context**: Teams that jump to solutions without understanding the problem build
features nobody uses. Teams that treat specs as contracts miss the nuance that emerges
during implementation. The team needs a shared understanding of how they move from
"vague idea" to "thing we're building."

**Sub-questions**:
- How do we validate that a feature solves a real user problem before building it?
- Who defines acceptance criteria, and can anyone on the team challenge them?
- How do we handle scope creep — when someone says "wouldn't it be cool if..."?

### 2. How does the Driver-Reviewer mob model work?

**Problem**: Multiple agents editing files simultaneously causes merge conflicts,
unclear ownership, and bypassed reviews. Without clear rules about who can write and
who reviews, quality degrades.

**Context**: The driver-reviewer model exists because AI agents operating in parallel
on the same codebase create chaos. One writer at a time is a hard constraint. But the
team needs to decide the norms around it.

**Sub-questions**:
- How does the team select who drives for each task?
- What happens if a Reviewer spots an urgent issue — can they fix it directly or must
  they message the Driver?
- How does the team handle a Driver who isn't responding to feedback?
- What does the handoff look like when the Driver role rotates?

### 3. When is a piece of work "done"?

**Problem**: Without a shared definition of done, "done" means different things to
different people. Features ship with missing tests, inaccessible UI, no error handling,
or incomplete edge cases.

**Context**: Every discipline has a different bar for "done." Engineering might say
"tests pass." Design says "spacing is consistent." A11y says "keyboard navigable."
Product says "user can complete the journey." The team needs a single, comprehensive
definition everyone agrees on.

**Sub-questions**:
- What engineering quality checks must pass? (tests, linting, formatting, etc.)
- What accessibility standards must be met?
- What design standards must be met?
- What product criteria must be satisfied?
- What process steps must be completed? (reviews, consensus, etc.)

### 4. What is our commit and integration pipeline?

**Problem**: Without a defined pipeline, steps get skipped. Refactoring gets deferred
("we'll clean it up later" — no you won't). Code gets pushed before review. Multiple
CI runs queue up and cascade failures. Process violations accumulate silently.

**Context**: The pipeline is the single most important agreement. Every commit goes
through it. It must be explicit, mandatory, and have no optional steps. Teams that
treat pipeline steps as suggestions end up with broken builds and accumulated debt.

**Sub-questions**:
- What checks run before every commit? (lint, format, test, e2e, etc.)
- Is there a refactoring step, and is it mandatory or optional?
- Does the team review before or after pushing to the remote?
- How does the team handle CI failures — can new work start while CI is red?
- Is there a post-commit checkpoint, and who runs it?
- How does the team ensure domain terminology stays consistent?

### 5. How do we resolve disagreements?

**Problem**: Without an escalation path, disagreements either stall work indefinitely
or get resolved by whoever is loudest. Neither outcome is healthy.

**Context**: Day-to-day coding decisions need lightweight resolution (try both, vote,
move on). Significant decisions (architecture, patterns, library choices) need more
care. And there must be a termination condition — discussions can't go on forever.

**Sub-questions**:
- How do we handle small day-to-day disagreements during coding?
- How do we handle significant architectural or design decisions?
- After how many rounds of discussion do we escalate, and to whom?
- How do we record decisions so they're not relitigated later?

### 6. What are our code conventions?

**Problem**: Without shared conventions, every team member writes differently. The
codebase becomes a patchwork of styles. New contributors (or new Driver sessions) have
to guess which pattern to follow.

**Context**: Conventions cover project structure, language idioms, error handling,
testing strategy, naming, and more. The team should establish these early and evolve
them as they learn what works.

**Sub-questions**:
- What is the project directory structure and dependency flow?
- What language-specific idioms and patterns does the team prefer?
- How does the team handle errors? (error types, propagation, user-facing messages)
- What is the testing strategy? (unit vs integration vs e2e, mocking policy, test naming)
- What are the frontend conventions? (HTML structure, CSS organization, JS/TS role)
- How does the team manage domain language? (glossary, naming, type design principles)

### 7. When and how do we hold retrospectives?

**Problem**: Without retrospectives, process violations and pain points accumulate.
The team never improves. But time-based retros (weekly, bi-weekly) don't make sense
for AI agents who work continuously. The team needs event-driven triggers.

**Context**: The most valuable retros happen when context is fresh — right after a CI
build, right after a feature ships, right after something goes wrong. The team needs
to decide their retro triggers, format, and how they track action items.

**Sub-questions**:
- What events trigger a retrospective?
- Is there a lightweight checkpoint after each commit/CI build? Who runs it?
- What format do retros follow? (Start/Stop/Continue? Different?)
- How are action items tracked and followed up on?
- How do non-blocking issues get captured for later review?
- Can team agreements be updated at retros? What's the process?

### 8. What are our architectural principles?

**Problem**: Without shared principles, each team member pulls the architecture in
their preferred direction. One person wants microservices, another wants a monolith.
One wants client-side state, another wants server-side rendering.

**Context**: Architectural principles aren't dogma — they're the team's shared mental
model of how the system should be built. They should emerge from the project's needs,
not from individual preferences.

**Sub-questions**:
- What is the team's stance on simplicity vs. flexibility?
- Where does state live? (client, server, database)
- How pure should the domain layer be? (I/O at boundaries only? Pragmatic mixing?)
- What is the testing philosophy? (TDD strict? Test-after? Property-based?)
- How does the team approach progressive enhancement?
- What is the deployment and observability strategy?

### 9. How do we communicate as a team?

**Problem**: Passive aggression, assumptions across disciplines, and engineering voices
dominating over design/a11y/UX create friction and missed perspectives. Duplicate
reviews waste the Driver's time.

**Context**: AI agents communicate exclusively through messages. There's no body
language, no hallway conversation, no shared whiteboard. Communication norms must be
explicit.

**Sub-questions**:
- How do we ensure every discipline's perspective is heard equally?
- How do we handle cross-discipline questions and assumptions?
- How do reviewers coordinate to avoid sending duplicate feedback?
- When is it appropriate to "+1" vs. write a full review?

### 10. What tooling and repository conventions do we follow?

**Problem**: Without shared tooling conventions, team members fight the environment
instead of building the product. CI/CD configuration becomes a source of friction.

**Context**: This covers source control workflow, CI/CD pipeline, dependency management,
and work tracking.

**Sub-questions**:
- Branching strategy? (trunk-based? feature branches?)
- CI/CD pipeline stages and configuration?
- How do we manage dependencies? (criteria for adding new ones)
- How do we track work? (issues? task tools? both?)

---

## Output Format

The team's `TEAM_AGREEMENTS.md` should capture their actual decisions in whatever
structure makes sense to them. Common sections:

1. Working Agreements (values, communication norms, mob model details)
2. Definition of Done (comprehensive checklist)
3. Code Conventions and Patterns (language, structure, testing, pipeline)
4. Disagreement Resolution (day-to-day and significant decisions)
5. Architectural Principles (team's shared mental model)
6. Retrospective Cadence (triggers, format, action items)
7. Tooling & Repository (source control, CI/CD, work tracking)
8. Team Composition Assessment (roster, gaps, recommendations)
9. Signatures (consensus record — every member signs)

The document should be a **living document** that the team updates at retrospectives.
