---
name: prd-breakdown
description: >-
  Break a Product Requirements Document into vertical slice stories.
  Works without an event model. Activate when given a PRD, spec document,
  or feature description that needs decomposition into implementable work items.
license: CC0-1.0
metadata:
  author: jwilger
  version: "1.0"
  requires: []
  context: [source-files]
  phase: understand
  standalone: true
---

# PRD Breakdown

**Value:** Simplicity and communication -- decomposing a large document into
small, independent slices reduces complexity and makes scope visible to the
entire team.

## Purpose

Teaches how to analyze a Product Requirements Document (or any feature
specification) and decompose it into vertical slice stories that can be
independently implemented and deployed. Works without an event model by
extracting actors, goals, and behaviors directly from the document.

## Practices

### Read the Whole Document First

Read the entire PRD before decomposing. You need the full picture to identify
boundaries between slices and avoid creating overlapping stories.

1. Read end-to-end without taking action
2. Identify the core user problem the PRD addresses
3. Note the actors mentioned (users, admins, external systems)
4. Note explicit success criteria or acceptance criteria already provided
5. Identify constraints (technical, business, regulatory)

### Identify Actors and Goals

Extract every distinct actor and their goals from the PRD.

An actor is anyone (or anything) that interacts with the system from the
outside: a user, an admin, an external API, a scheduled job. A goal is a
specific outcome the actor wants to achieve.

```
Actor: Customer
Goals:
  - Browse available products
  - Add products to cart
  - Complete purchase with payment
  - Track order status

Actor: Store Admin
Goals:
  - Add and update product listings
  - View and manage orders
  - Generate sales reports
```

If the PRD is vague about actors, ask the user to clarify who benefits from
each capability before proceeding.

### Decompose into Vertical Slices

For each actor-goal pair, identify the thinnest end-to-end behavior that
delivers value. Each slice must:

1. **Deliver observable value** to the actor. The actor can see or use the
   result.
2. **Span all layers** needed to produce that value (UI, API, domain,
   persistence).
3. **Be independently deployable.** Deploying this slice alone does not
   break the system.
4. **Be independently testable.** A test at the application boundary can
   verify this slice without depending on other unbuilt slices.

Start with the simplest version of each behavior. A "browse products" slice
might start with a hardcoded list before adding search and filtering.

**Do:**
- Slice by user-observable behavior, not by technical component
- Make each slice as thin as possible while still delivering value
- Include error and edge cases as separate slices when they are substantial

**Do not:**
- Create "setup" or "infrastructure" slices with no user-observable behavior
- Bundle multiple behaviors into one slice because they share a database table
- Defer all error handling to a single "error handling" slice at the end

### Write Acceptance Criteria for Each Slice

Each slice gets Given-When-Then scenarios describing the expected behavior at
the application boundary.

```
Slice: Customer browses product catalog

Given the store has 3 products listed
When the customer visits the product catalog page
Then the customer sees all 3 products with name, price, and image

Given the store has no products listed
When the customer visits the product catalog page
Then the customer sees a message "No products available"
```

Cover the happy path and the most important edge case. Additional edge cases
become separate slices if they involve significant implementation work.

### Order the Slices

Arrange slices in implementation order:

1. **Walking skeleton first.** The thinnest end-to-end path proving all
   architectural layers connect. This de-risks the architecture before
   building features on top of it.

2. **Core value next.** The slices that deliver the primary actor's primary
   goal. For an e-commerce app: browse, add to cart, purchase -- in that
   order.

3. **Supporting behaviors after.** Admin features, reporting, edge cases,
   and polish.

4. **Respect dependencies.** If slice B requires data that slice A creates,
   slice A comes first. Make dependencies explicit in the ordering.

Mark each slice with its position in the sequence and note any dependencies
on prior slices.

### Produce the Breakdown Output

Present the complete breakdown as a structured list:

```
## PRD Breakdown: [Feature Name]

### Slice 1: [Walking skeleton description]
Actor: [who]
Acceptance Criteria:
  - GWT scenario 1
  - GWT scenario 2
Dependencies: none
Size estimate: [S/M/L relative to other slices]

### Slice 2: [Next slice description]
...
```

If the PRD is ambiguous or incomplete, list the open questions separately
and ask the user to resolve them before finalizing the breakdown.

## Enforcement Note

This skill provides advisory guidance. It instructs the agent on how to
decompose a PRD into vertical slices but cannot mechanically prevent
horizontal decomposition or missing acceptance criteria. The agent
self-checks against the slice properties (observable, vertical, deployable,
testable) before finalizing. If you observe slices that violate these
properties, point it out.

## Verification

After completing a PRD breakdown, verify:

- [ ] The entire PRD was read before decomposition began
- [ ] All actors and their goals are identified
- [ ] Every slice delivers observable value to an actor
- [ ] Every slice spans all necessary layers (not horizontal)
- [ ] Every slice is independently deployable and testable
- [ ] Every slice has GWT acceptance criteria at the application boundary
- [ ] Slices are ordered: walking skeleton first, then by value/dependency
- [ ] No two slices overlap in the behavior they deliver
- [ ] Open questions and ambiguities are listed separately
- [ ] Domain language from the PRD is used consistently

If any criterion is not met, revisit the relevant practice before proceeding.

## Dependencies

This skill works standalone. For enhanced workflows, it integrates with:

- **vertical-slice-ticket:** Refines each slice from the breakdown into a
  fully implementation-ready ticket with readiness criteria.
- **event-modeling:** An alternative (and often richer) source for slice
  identification when an event model is available.
- **tdd:** Drives implementation of each slice using its GWT scenarios as
  acceptance tests.

Missing a dependency? Install with:
```
npx skills add jwilger/agent-skills --skill vertical-slice-ticket
```
