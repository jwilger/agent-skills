# Step 2: Order Events Chronologically

Take the brainstormed events from Step 1 and arrange them into a timeline
-- the "plot" of the workflow. This step reveals missing events and
clarifies the flow.

## Facilitation Approach

Walk through the workflow from beginning to end:

- "What happens first?"
- "And then what happens?" (repeat until complete)
- "Can any of these happen in parallel?"
- "What has to happen before this can happen?"
- "Is there a point where things can branch?"

## Happy Path First

Start with the happy path -- the most common, successful flow through the
workflow. Place events in chronological order from left to right.

```
Timeline (Happy Path):
  CartCreated -> ItemAddedToCart -> ... -> OrderPlaced -> PaymentReceived
    -> InventoryReserved -> ShipmentDispatched -> OrderDelivered
```

## Alternative and Error Paths

After the happy path, map alternative flows:

- "What if the payment fails?"
- "What if the customer cancels?"
- "What if inventory is not available?"
- "What if the external system is down?"
- "What if the user changes their mind partway through?"

Show alternative paths branching from the main timeline:

```
Timeline:
  CartCreated -> ItemAddedToCart -> OrderPlaced -> PaymentReceived
                                              \-> PaymentFailed
                                                    -> OrderCancelled
                                                    -> RefundIssued
```

## Discovering Missing Events

Ordering often reveals gaps:

- **Between events:** "What happens between PaymentReceived and
  ShipmentDispatched?" Maybe InventoryReserved or PackagePrepared.
- **At the start:** "What happened before CartCreated? How did the
  customer get here?"
- **At the end:** "What happens after OrderDelivered? Is there a
  review or follow-up?"
- **On error paths:** "What events record failure states?"

When you discover a missing event, add it to the brainstorm list from
Step 1 and insert it into the timeline.

## Output Format

Produce a chronological timeline showing the happy path and all identified
alternative/error paths. Note any events that were added during ordering.

```
Timeline:
  1. CartCreated
  2. ItemAddedToCart (may repeat)
  3. ShippingAddressProvided
  4. OrderPlaced
  5a. PaymentReceived -> InventoryReserved -> ShipmentDispatched -> OrderDelivered
  5b. PaymentFailed -> OrderCancelled

New events discovered during ordering:
  - ShippingAddressProvided (was implicit, now explicit)
  - PackagePrepared (between InventoryReserved and ShipmentDispatched)
```

## Common Pitfalls

**Do not:**
- Jump to designing commands or read models yet
- Assume a single linear path -- most workflows branch
- Skip error and edge case paths
- Force events into a sequence when they can happen in parallel

**Do:**
- Ask "And then what happens?" after every event
- Identify where paths diverge and converge
- Note which events can repeat (e.g., ItemAddedToCart)
- Mark parallel events explicitly
