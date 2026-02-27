---
name: vertical-slice-ticket
description: >-
  Create well-formed vertical slice tickets with boundary acceptance criteria.
  Ensures tickets are properly sized, complete, vertical, non-overlapping,
  domain-aligned, and unblocked. Activate when creating user stories,
  tickets, or work items.
license: CC0-1.0
metadata:
  author: jwilger
  version: "1.0"
  requires: []
  context: [event-model]
  phase: understand
  standalone: true
---

# Vertical Slice Ticket

**Value:** Communication and feedback -- well-formed tickets communicate intent
precisely, and boundary acceptance criteria provide fast feedback on whether
a slice actually works from the user's perspective.

## Purpose

Teaches how to write vertical slice tickets that span all layers of the
application and include acceptance criteria exercised at the application
boundary. Prevents incomplete slices, horizontal layering, and vague
requirements by enforcing concrete readiness criteria before implementation
begins.

## Practices

### Every Ticket Is a Vertical Slice

A ticket must deliver observable value to a user or external actor. It must
span all necessary layers (UI, API, domain logic, persistence) to produce
that value end-to-end. A ticket that implements "just the database schema"
or "just the API endpoint" without connecting to user-visible behavior is a
horizontal slice and must be rejected.

**Do:**
- Write tickets that deliver a single, observable user behavior
- Include all layers needed to make the behavior work end-to-end
- Start with the thinnest possible slice (walking skeleton) before expanding

**Do not:**
- Create "backend-only" or "frontend-only" tickets for the same feature
- Split by architectural layer (data, service, UI) instead of by behavior
- Bundle multiple user-observable behaviors into one ticket

### Acceptance Criteria at the Application Boundary

Every ticket must include Given-When-Then (GWT) scenarios that describe
behavior at the application boundary -- the point where an external actor
interacts with the system.

If there IS a UI, acceptance tests MUST exercise the actual UI through
browser automation (Playwright, Cypress, Selenium). A test that only calls
an internal API when the user interacts through a web page does NOT satisfy
the boundary requirement.

```
Given a registered customer with items in their cart
When the customer clicks "Place Order" on the checkout page
Then the customer sees an order confirmation with a tracking number
And the customer receives a confirmation email within 5 minutes
```

Each scenario must be specific enough that a test can verify it with a
binary pass/fail result. Avoid vague criteria like "the page loads quickly"
or "the user has a good experience."

### Ticket Quality Criteria

Before a ticket is ready for implementation, verify these six properties:

1. **Properly sized.** Completable in 1-2 days of focused work. If larger,
   decompose further. If smaller than half a day, consider combining with a
   related slice.

2. **Complete.** All information needed to implement is present: acceptance
   criteria, relevant context, known constraints, and links to related
   artifacts (event model, designs, ADRs).

3. **Vertical.** The ticket spans all layers needed to deliver the
   observable behavior. No hidden dependencies on unwritten tickets.

4. **Non-overlapping.** The ticket does not duplicate behavior covered by
   another ticket. Each user-observable behavior lives in exactly one ticket.

5. **Domain-aligned.** The ticket uses ubiquitous language from the project's
   domain model. Terms match what the domain experts use, not technical jargon.

6. **Unblocked.** The ticket can be started immediately. All dependencies
   (other tickets, decisions, access, infrastructure) are resolved or
   explicitly listed as assumptions.

### Work Tracking Setup

Tickets must be tracked somewhere the team can reference them. If no tracking
system exists, help the user establish one:

1. Ask what tools they currently use (GitHub Issues, Linear, Jira, a plain
   text file, etc.)
2. If none, recommend GitHub Issues for repos hosted on GitHub, or a
   `TODO.md` file in the project root as a minimal starting point
3. Each ticket needs a unique identifier (issue number, heading anchor, or
   sequential ID)
4. Track status: not started, in progress, done

Do not prescribe a specific tool. Match the team's existing workflow.

### Readiness Checklist

Before marking a ticket as ready for implementation, confirm:

- [ ] Title states the user-observable outcome (not the technical task)
- [ ] At least one GWT scenario at the application boundary
- [ ] All GWT scenarios are specific and binary-verifiable
- [ ] Ticket is completable in 1-2 days
- [ ] All six quality criteria (sized, complete, vertical, non-overlapping,
      domain-aligned, unblocked) are satisfied
- [ ] Ubiquitous language used throughout (no unexplained technical jargon)
- [ ] Dependencies listed and resolved or explicitly assumed

If any item fails, refine the ticket before starting implementation.

## Enforcement Note

This skill provides advisory guidance. It instructs the agent on how to
write well-formed vertical slice tickets but cannot mechanically prevent
poorly formed tickets from being created. The readiness checklist is a
self-check the agent applies before marking a ticket as ready. If you
observe tickets that violate these criteria, point it out.

## Verification

After creating tickets guided by this skill, verify:

- [ ] Every ticket delivers user-observable behavior (not a horizontal layer)
- [ ] Every ticket has GWT scenarios at the application boundary
- [ ] UI-involving scenarios specify UI interaction (not just API calls)
- [ ] Tickets are sized for 1-2 days of work
- [ ] No two tickets overlap in the behavior they deliver
- [ ] Domain language is used consistently throughout
- [ ] All tickets pass the readiness checklist before implementation begins
- [ ] A work tracking system is in place with unique IDs for each ticket

If any criterion is not met, revisit the relevant practice before proceeding.

## Dependencies

This skill works standalone. For enhanced workflows, it integrates with:

- **event-modeling:** Event models provide the source material for identifying
  vertical slices and their boundary behaviors.
- **tdd:** Once a ticket is ready, TDD drives the implementation using the
  ticket's GWT scenarios as acceptance tests.
- **prd-breakdown:** Breaks a PRD into vertical slices that this skill then
  refines into implementation-ready tickets.

Missing a dependency? Install with:
```
npx skills add jwilger/agent-skills --skill event-modeling
```
