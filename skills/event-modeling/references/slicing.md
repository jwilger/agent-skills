# Step 8: Decompose into Vertical Slices

Take the complete workflow model (events, commands, read models,
automations, translations) and decompose it into independently
deliverable vertical slices.

## Slice Grouping by Pattern

List all vertical slices grouped by pattern type:

- **Command Slices (State Change):** Each command that produces events
- **View Slices (State View):** Each read model/projection
- **Automation Slices:** Each automatic process
- **Translation Slices:** Each external integration

## What Makes a Good Slice

A good slice is:
- A complete user interaction or system behavior
- Independently valuable (delivers business value on its own)
- Testable in isolation
- Small enough for 1-2 days of work

**Bad slices:**
- "Set up database" (technical, no user value)
- "Implement order system" (too broad)
- "Create Order table" (implementation detail)
- "Persist Events to Database" (cross-cutting infrastructure)

Cross-cutting infrastructure that appears identically in every workflow
is not a slice -- document it in the domain overview as a shared
dependency.

## Slice Independence

Slices that share an event schema are **independent** -- connected by
the event contract, not by execution order. The event schema is the
shared contract between a command slice that produces events and a view
slice that consumes them.

```
# Bad -- artificial dependency chain:
Slice 1: "Initialize Project" (must complete before Slice 2)
Slice 2: "Show Project Dashboard" (depends on Slice 1 running first)

# Good -- independent slices sharing an event schema:
Slice 1: "Initialize Project" -> produces ProjectInitialized event
Slice 2: "Project Dashboard" -> projects from ProjectInitialized event
  (testable with synthetic ProjectInitialized fixtures, no Slice 1 needed)
```

- **Command slices** test by asserting on produced events (given prior
  events, when command executes, then these events are produced)
- **View slices** test with synthetic event fixtures (given these events,
  the projection shows this state)
- Neither slice needs the other to be implemented or running

## Component List for UI Slices

**For slices with a presentation layer**, the slice definition MUST
include:

- **Component list:** Which design system components implement the
  wireframe
- **Data binding:** Which component fields bind to which read model fields
- **User actions:** Which components trigger which commands
- **New components needed:** Which components are not yet in the design
  system

A slice that specifies backend behavior without specifying its UI
components is incomplete -- implementation agents will build the API and
skip the front-end.

## Required Layers Per Slice Pattern

Each slice pattern implies a minimum set of architectural layers. A slice
is not complete until all required layers are implemented and wired
together.

- **State View**: infrastructure + domain (projection) + presentation +
  wiring
- **State Change**: presentation + domain (validation/rules) +
  infrastructure + wiring
- **Automation**: infrastructure (trigger) + domain (policy) +
  infrastructure (action) + wiring
- **Translation**: infrastructure (receive) + domain (mapping) +
  infrastructure (deliver) + wiring

When decomposing a slice, verify that your acceptance criteria and task
breakdown cover every required layer. A slice that only implements domain
logic without presentation or infrastructure is incomplete -- it is a
component, not a vertical slice.

## GWT Scenarios Per Slice

Every slice must have GWT scenarios as acceptance criteria. Use
`references/gwt-template.md` for the scenario format. Every slice MUST
include at least one application-boundary acceptance scenario.

## Output Structure

```
docs/event_model/workflows/<name>/
  overview.md       # All 8 steps, workflow diagram, slice index
  slices/
    <slice-1>.md    # Pattern, diagram, details, GWT scenarios
    <slice-2>.md
    ...
```

Each slice file contains:
- Slice name and pattern type
- Components involved (command, events, read model, etc.)
- Component list (for UI slices)
- Required layers
- GWT scenarios (happy path + error cases)
- Application-boundary acceptance scenario

## Output Format

```
Vertical Slices:

Command Slices (State Change):
  1. PlaceOrder
     - Command: PlaceOrder
     - Events: OrderPlaced
     - Rejection: empty cart, duplicate order, suspended account
     - Layers: presentation + domain + infrastructure + wiring
     - Components: OrderForm (organism), SubmitButton (atom)

View Slices (State View):
  1. OrderSummary
     - Read Model: OrderSummary
     - Source Events: OrderPlaced, PaymentReceived, ShipmentDispatched
     - Layers: infrastructure + domain + presentation + wiring
     - Components: OrderCard (organism), StatusBadge (atom)

Automation Slices:
  1. AutoReserveInventory
     - Trigger: OrderPlaced
     - Read Model: InventoryLevel
     - Logic: check stock against order items
     - Command: ReserveInventory or BackorderItems
     - Layers: infrastructure + domain + infrastructure + wiring

Translation Slices:
  1. StripePaymentConfirmation
     - External: Stripe
     - Direction: Inbound
     - Produces: PaymentReceived or PaymentFailed
     - Layers: infrastructure + domain + infrastructure + wiring
```

## Common Pitfalls

**Do not:**
- Create slices for cross-cutting infrastructure
- Create dependency chains between slices that share event schemas
- Skip the component list for UI slices
- Leave out required layers
- Forget GWT scenarios

**Do:**
- Group slices by pattern type
- Verify slice independence
- Include component lists for presentation-layer slices
- Ensure every slice covers all required layers
- Write GWT scenarios for every slice
