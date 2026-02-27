# Step 1: Brainstorm Domain Events

Sticky-note style -- capture all possible events without ordering or
filtering. Quantity over quality at this stage. Do not judge, do not
organize, do not sequence. Just collect.

## Facilitation Approach

Ask the user these questions and keep pressing for more:

- "What facts need to be recorded in this workflow?"
- "What happened that the business cares about?"
- "What would an auditor want to know?"
- "What triggers a change in the business?"
- "What decisions get made?"
- "What information needs to be communicated?"

After each answer, ask: **"What else? What am I missing?"**

Do not stop until the user says there is nothing more. Then ask one more
time.

## Event Naming Rules

Events MUST be:
- **Past tense** -- something that already happened: `OrderPlaced`, not
  `PlaceOrder`
- **Business language** -- words the business uses, not technical jargon:
  `PaymentReceived`, not `PaymentRecordInserted`
- **Immutable facts** -- never modified or deleted once recorded
- **Specific enough** to be useful: `InventoryReserved`, not `DataUpdated`
- **Broad enough** to capture meaningful state changes: `OrderPlaced`, not
  `OrderFieldOneSet`

## Domain Facts vs. Runtime Context

Events must record **domain facts** -- statements that are true regardless
of which machine, process, or environment replays them. Runtime context does
not belong in event data.

```
# Bad -- runtime context leaks into the event:
ProjectInitialized {
  project_id: "abc-123",
  working_directory: "/home/dev/projects/myapp",   # machine-specific
  pid: 48291,                                       # process-specific
  hostname: "dev-laptop.local"                      # environment-specific
}

# Good -- domain facts only:
ProjectInitialized {
  project_id: "abc-123",
  project_name: "myapp",
  initialized_by: "user-456",
  template: "web-app"
}
```

**Test:** "Would this field have the same value if the event were replayed
on a different machine?" If no, it is runtime context and does not belong
in the event.

## Output Format

List all brainstormed events in a flat list. No ordering, no grouping, no
hierarchy. Just names and brief descriptions of what happened.

```
Brainstormed Events:
- OrderPlaced -- a customer submitted an order
- PaymentReceived -- payment was confirmed for an order
- InventoryReserved -- inventory was set aside for an order
- ShipmentDispatched -- the order was handed to a carrier
- OrderCancelled -- the customer cancelled the order
- RefundIssued -- money was returned to the customer
- ...
```

## Common Pitfalls

**Do not:**
- Sequence events yet (that is Step 2)
- Design commands yet (that is Step 4)
- Discuss implementation details
- Filter out events that seem minor -- capture everything first
- Use present tense or imperative mood for event names

**Do:**
- Include error/failure events (PaymentFailed, ShipmentLost)
- Include lifecycle events (AccountCreated, AccountClosed)
- Include events from all actors (customer, admin, system)
- Keep asking "What else?" until truly exhausted
