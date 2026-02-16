# The Nine-Step Workflow Design Process

Follow ALL nine steps for each workflow. Do not skip steps. Do not combine
steps. The process reveals understanding that shortcuts would miss.

## Step 1: Identify the User Goal

Ask until the goal is crystal clear:
- "What exactly is the user trying to accomplish?"
- "What does success look like to them?"
- "What would make this fail?"

Do not proceed until the goal is unambiguous.

## Step 2: Brainstorm Events

Sticky-note style -- capture all possible events without ordering:
- "What facts need to be recorded?"
- "What happened that we care about?"
- "What would an auditor want to know?"

Events must be past tense, business language, facts. Example:
`OrderPlaced`, `PaymentReceived`, `InventoryReserved`.

Keep asking: "What else? What am I missing?"

## Step 3: Order Events Chronologically

Arrange brainstormed events into the timeline -- the "plot" of the workflow.

- "What happens first?"
- "And then what happens?" (repeat until complete)
- Identify the happy path and alternative/error paths

## Step 4: Create Wireframes

These wireframes do not need to represent the actual UI/UX of the
application. Their purpose is to provide a complete accounting of what data
a user can see and what actions a user can take from each screen.

For each user interaction point, create an ASCII wireframe showing:
- What data the user SEES (from read models)
- What data the user PROVIDES (command inputs)
- What actions the user can TAKE (buttons/triggers)

```
+-------------------------------+
|  Place Order                  |
+-------------------------------+
|  Items: [list from cart]      |
|  Shipping: [address]          |
|  Total: $XX.XX                |
|                               |
|  [Confirm Order]              |
+-------------------------------+
```

Every wireframe field must trace to an event field (displays) or a command
input (inputs). If you cannot trace a field, something is missing.

### Concurrency Check

If the domain supports concurrent instances (e.g., multiple orders, multiple
journeys), wireframes should show lists or tables, not single-item views.
Ask: "Can there be more than one of these in progress at the same time?"

## Step 5: Identify Commands

For each event, determine the trigger:
- "What triggered this event?"
- "Who or what issued that command?"
- "What information did they provide?"
- "Under what circumstances would this NOT happen?"

Commands are imperative, present tense: `PlaceOrder`, `ProcessPayment`.
Commands can fail; events cannot.

## Step 6: Design Read Models

Read models exist to support data displayed on wireframes as well as data
needed by automations. For each actor at each workflow point, and for each
automation:
- "What does this person need to see?"
- "What information do they need to make decisions?"
- "What data does this automation need to determine its next action?"

Verify every read model field traces back to an event. Example:
```
OrderSummary:
  orderId       <- OrderPlaced.orderId
  items         <- ItemAdded, ItemRemoved events
  totalAmount   <- OrderPlaced.totalAmount
  status        <- OrderPlaced, PaymentReceived, OrderShipped events
```

If a field has no source event, the model is incomplete.

### Concurrency Check

For each read model field, ask: "Can there be more than one of these active
at the same time?" If the domain supports concurrent instances, use collection
types, not singular values:
```
# Singular (only valid if business rule enforces one-at-a-time):
current_phase: string

# Collection (when concurrent instances exist):
active_journeys: [{journey_id, phase, started_at}, ...]
```

## Step 7: Find Automations

Look for automatic responses to events that involve decision-making:
- "Does anything happen automatically after this event?"
- "What business rules trigger other processes?"
- "Does the system need to check anything before acting?"

Pattern: Event -> Read Model (todo list) -> Process -> Command -> Event

**All four components are required for a true Automation:**
1. A triggering event
2. A read model (the "todo list") the process consults
3. Conditional logic that decides whether and how to act
4. A resulting command that produces new events

If there is no read model and no conditional logic — if the events are
always unconditionally co-produced — it is NOT an Automation. Model it as
a single Command slice with multiple output events.

**Test**: Ask "Can this automatic response ever be skipped or vary based on
system state?" If no, it is co-production, not automation.

Every automation must have a clear termination condition. Watch for infinite
loops.

## Step 8: Map External Integrations

Identify external system interactions using the Translation pattern:
- "Does this workflow receive data from outside?"
- "Does this workflow send data to external systems?"

Note only names and general purposes. No technical details (APIs, webhooks,
protocols). Example: "Stripe provides payment confirmation" -- not
"Stripe webhook sends POST to /api/webhooks/stripe".

### Infrastructure vs. Domain Translations

Ask: "Is this integration specific to THIS workflow, or would every
workflow need it?"

If every workflow needs it, it is cross-cutting infrastructure (persistence,
messaging, logging) — NOT a Translation slice. Note it as an infrastructure
dependency, not as a slice.

## Step 9: Decompose into Vertical Slices

List all vertical slices grouped by pattern type:

- **Command Slices:** Each command that produces events
- **View Slices:** Each read model/projection
- **Automation Slices:** Each automatic process
- **Translation Slices:** Each external integration

A good slice is: a complete user interaction, independently valuable,
testable in isolation, small enough for 1-2 days of work.

Bad slices: "Set up database" (technical, no user value), "Implement order
system" (too broad), "Create Order table" (implementation detail).

Also not slices: cross-cutting infrastructure (e.g., "Persist Events to
Database") that would appear identically in every workflow. Infrastructure
is not business behavior — document it in the domain overview, not as
workflow slices.

## Output Structure

```
docs/event_model/workflows/<name>/
  overview.md       # All 9 steps, workflow diagram, slice index
  slices/
    <slice-1>.md    # Pattern, diagram, details, GWT scenarios
    <slice-2>.md
    ...
```

## Facilitation Questions Quick Reference

**Domain Discovery:** What does the business do? Who are the actors? What
are the major processes? What external systems exist? Which workflow is
most critical?

**Events:** What facts need recording? What happened here? Would the
business need to know this?

**Timeline:** What happens first? And then? Can these happen in parallel?

**Commands:** Who initiates this? Is it user-triggered or automatic? What
intent does this represent?

**Read Models:** What does this actor need to see? What queries do users
run? Can there be multiple instances active simultaneously?

**Automations:** Does anything happen automatically? What business rules
apply? Does this trigger other processes?

**Edge Cases:** What if this fails? What if the user cancels? What if the
external system is down?
