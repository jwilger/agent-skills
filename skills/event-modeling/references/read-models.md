# Step 5: Design Read Models

Read models exist to support data displayed on wireframes (Step 3) and
data needed by automations (Step 6). They are projections built from the
event stream.

## Facilitation Approach

For each actor at each workflow point, and for each automation:

- "What does this person need to see?"
- "What information do they need to make decisions?"
- "What data does this automation need to determine its next action?"

## Traceability Rule

Every read model field MUST trace back to an event. If a field has no
source event, the model is incomplete -- go back and add the missing event.

```
OrderSummary:
  orderId       <- OrderPlaced.orderId
  items         <- ItemAdded, ItemRemoved events
  totalAmount   <- OrderPlaced.totalAmount
  status        <- OrderPlaced, PaymentReceived, OrderShipped events
```

If a field cannot be traced to any event, either:
1. An event is missing from the brainstorm (go back to Step 1)
2. The field does not belong in the read model

## Concurrency Check

For each read model field, ask: **"Can there be more than one of these
active at the same time?"**

If the domain supports concurrent instances, use collection types, not
singular values:

```
# Singular (only valid if business rule enforces one-at-a-time):
current_phase: string

# Collection (when concurrent instances exist):
active_journeys: [{journey_id, phase, started_at}, ...]
```

## Command Independence Rule

Read models serve views and automations -- they do NOT feed commands.

- Commands derive inputs from user-provided data and the event stream
- Read models display information to users and inform automation logic
- There must be NO `ReadModel -> Command` edges in any diagram

If you find a command depending on a read model:
- "Does the command rely on a read model to decide what to do?" -- Wrong.
  The command should check the event stream for prior events.
- "Is an idempotency guard querying a read model?" -- Wrong. Check the
  event stream for a duplicate event.

## No Read Models for Infrastructure Preconditions

Read models represent meaningful domain projections -- not infrastructure
checks. If a precondition is purely about infrastructure state (does a
directory exist? is a service running?), it does not need its own read
model.

```
# Bad -- infrastructure check modeled as a read model:
ReadModel: RepositoryExistence
  exists: boolean    <- RepositoryInitialized

# Good -- command checks the precondition directly:
Command: InitializeProject
  Precondition: directory exists (infrastructure, not domain state)
  Produces: ProjectInitialized
```

Infrastructure preconditions are either:
1. Implicit in the command's execution context (the OS provides them)
2. Checked as part of the command handler's implementation

They do not need a domain read model.

## Output Format

List all read models with their fields and event source tracing:

```
ReadModel: OrderSummary
  orderId: string       <- OrderPlaced.orderId
  customerName: string  <- CustomerRegistered.name
  items: [{name, qty, price}]  <- ItemAdded, ItemRemoved
  status: OrderStatus   <- OrderPlaced, PaymentReceived, ShipmentDispatched
  total: Money          <- OrderPlaced.totalAmount
```

## Common Pitfalls

**Do not:**
- Create read models that feed commands (violates command independence)
- Use singular fields when the domain has concurrent instances
- Create read models for infrastructure preconditions
- Include fields that cannot be traced to events

**Do:**
- Trace every field to its source event(s)
- Use collection types when concurrency exists
- Design read models for automations as well as UI views
- Ask "Can there be more than one?" for every field
