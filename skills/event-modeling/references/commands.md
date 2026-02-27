# Step 4: Identify Commands

For each event in the timeline, determine the trigger. Commands are the
only way to change state in an event-sourced system.

## Facilitation Approach

For each event, ask:

- "What triggered this event?"
- "Who or what issued that command?"
- "What information did they provide?"
- "Under what circumstances would this command be rejected?"

## Command Naming Rules

Commands MUST be:
- **Imperative, present tense**: `PlaceOrder`, `ProcessPayment`,
  `CancelSubscription`
- **Business language**: words the business uses, not technical jargon
- **Specific**: one command per distinct user intention

Commands are NOT events. Events record what happened (past tense).
Commands express intent (present tense).

```
Command: PlaceOrder        -> Event: OrderPlaced
Command: ProcessPayment    -> Event: PaymentReceived (or PaymentFailed)
Command: CancelOrder       -> Event: OrderCancelled
```

## Command Triggers

Every command has a trigger source:

- **User-triggered**: A human takes an action through the UI
- **Automation-triggered**: A process issues the command based on
  business rules (see Step 6)
- **Translation-triggered**: An external system provides data that
  translates into a command (see Step 7)

## Command Inputs

For each command, identify what information is required:

```
Command: PlaceOrder
  Triggered by: Customer (via UI)
  Inputs:
    - cartId (identifies which cart)
    - paymentMethod (how to pay)
  Produces: OrderPlaced (success) or Error (failure)
```

## Command Independence Rule

Commands derive their inputs from:
1. **User-provided data** (what the user types, selects, or clicks)
2. **The event stream** (what has already happened)

Commands do NOT derive inputs from read models. Read models serve views
and automations only. If a command needs to know whether something already
happened (e.g., idempotency), it checks the event stream, not a read
model.

- "Does the command rely on a read model to decide what to do?" -- Wrong.
  The command should check the event stream for prior events.
- "Is an idempotency guard querying a read model?" -- Wrong. Check the
  event stream for a duplicate event.

## Rejection Conditions

Commands can fail; events cannot. For each command, identify the business
rules that would cause rejection:

- "Under what circumstances would this NOT happen?"
- "What has to be true for this command to succeed?"
- "What state would make this command invalid?"

These rejection conditions become GWT error scenarios in Step 8.

```
Command: PlaceOrder
  Rejection conditions:
    - Cart is empty (no items added)
    - Cart has already been placed (idempotency)
    - Customer account is suspended
```

## Output Format

List all commands with their trigger, inputs, produced events, and
rejection conditions.

## Common Pitfalls

**Do not:**
- Create commands that read from read models
- Skip rejection conditions -- they reveal business rules
- Conflate commands with events (present tense vs. past tense)
- Create CRUD-style commands (CreateOrder, UpdateOrder, DeleteOrder)
  -- use business intent (PlaceOrder, AmendOrder, CancelOrder)

**Do:**
- Identify who or what triggers each command
- Document all inputs required
- List all rejection conditions (business rules)
- Ensure every event traces back to a command, automation, or translation
