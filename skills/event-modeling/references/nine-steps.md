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

## Step 5: Identify Commands

For each event, determine the trigger:
- "What triggered this event?"
- "Who or what issued that command?"
- "What information did they provide?"
- "Under what circumstances would this NOT happen?"

Commands are imperative, present tense: `PlaceOrder`, `ProcessPayment`.
Commands can fail; events cannot.

## Step 6: Design Read Models

For each actor at each workflow point:
- "What does this person need to see?"
- "What information do they need to make decisions?"

Verify every read model field traces back to an event. Example:
```
OrderSummary:
  orderId       <- OrderPlaced.orderId
  items         <- ItemAdded, ItemRemoved events
  totalAmount   <- OrderPlaced.totalAmount
  status        <- OrderPlaced, PaymentReceived, OrderShipped events
```

If a field has no source event, the model is incomplete.

## Step 7: Find Automations

Look for automatic responses to events:
- "Does anything happen automatically after this event?"
- "What business rules trigger other processes?"

Pattern: Event -> View (todo list) -> Process -> Command -> Event

Every automation must have a clear termination condition. Watch for infinite
loops.

## Step 8: Map External Integrations

Identify external system interactions using the Translation pattern:
- "Does this workflow receive data from outside?"
- "Does this workflow send data to external systems?"

Note only names and general purposes. No technical details (APIs, webhooks,
protocols). Example: "Stripe provides payment confirmation" -- not
"Stripe webhook sends POST to /api/webhooks/stripe".

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
run?

**Automations:** Does anything happen automatically? What business rules
apply? Does this trigger other processes?

**Edge Cases:** What if this fails? What if the user cancels? What if the
external system is down?
