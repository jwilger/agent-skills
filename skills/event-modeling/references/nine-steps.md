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

### Domain Facts vs. Runtime Context

Events must record **domain facts** — statements that are true regardless of
which machine, process, or environment replays them. Runtime context does not
belong in event data.

```
# Bad — runtime context leaks into the event:
ProjectInitialized {
  project_id: "abc-123",
  working_directory: "/home/dev/projects/myapp",   # machine-specific
  pid: 48291,                                       # process-specific
  hostname: "dev-laptop.local"                      # environment-specific
}

# Good — domain facts only:
ProjectInitialized {
  project_id: "abc-123",
  project_name: "myapp",
  initialized_by: "user-456",
  template: "web-app"
}
```

**Test:** "Would this field have the same value if the event were replayed on
a different machine?" If no, it is runtime context and does not belong in the
event.

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

### Wireframe-to-Component Mapping

When a design system exists (or will be created), map each wireframe element
to design system components:

1. **Identify every interactive and display element** in the wireframe
   (buttons, inputs, labels, lists, cards, forms, etc.)
2. **Map each element to a design system component** (or note if a new
   component is needed): which atoms (Button, Input, Label), molecules
   (FormField, SearchBar), and organisms (Form, Table, Card)?
3. **Create a component checklist** for the slice:
   ```
   Components for OrderForm wireframe:
   - [ ] OrderItemList (organism) ← displays Order read model items
   - [ ] PriceInput (molecule) ← captures price for PlaceOrder command
   - [ ] SubmitButton (atom) ← triggers PlaceOrder command
   Status: All exist in design system ✓ / NewComponentNeeded ✗
   ```
4. **Verify component traceability:**
   - Every wireframe field displaying data traces to a read model AND a
     named component
   - Every wireframe field accepting input feeds a command AND uses a
     named component
   - Every component exists in the design system or is flagged as new

If no design system exists yet, flag components as "to-be-designed" and note
them as a prerequisite before implementation.

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

### Command Independence

Commands derive their inputs from user-provided data and the event stream.
Read models serve views and automations — they do NOT feed commands. If a
command needs to know whether something already happened, it checks the
event stream directly, not a read model.

- "Does the command rely on a read model to decide what to do?" → Wrong.
  The command should check the event stream for prior events.
- "Is an idempotency guard querying a read model?" → Wrong. Check the
  event stream for a duplicate event.

### No Read Models for Infrastructure Preconditions

Read models represent meaningful domain projections — not infrastructure
checks. If a precondition is purely about infrastructure state (does a
directory exist? is a service running?), it does not need its own read model.

```
# Bad — infrastructure check modeled as a read model:
ReadModel: RepositoryExistence
  exists: boolean    ← RepositoryInitialized

# Good — command checks the precondition directly:
Command: InitializeProject
  Precondition: directory exists (infrastructure, not domain state)
  Produces: ProjectInitialized
```

Infrastructure preconditions are either:
1. Implicit in the command's execution context (the OS provides them)
2. Checked as part of the command handler's implementation

They do not need a domain read model.

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

### Data Flow Rules for Diagrams

When creating workflow diagrams, data flows follow these rules:
- **Actor/UI → Command**: User inputs flow into commands
- **Command → Event**: Commands produce events
- **Event → Read Model**: Events feed read model projections
- **Read Model → Actor/UI**: Read models serve views
- **Event → Automation Read Model → Process → Command**: Automations
  consult read models, but the resulting command still checks the event
  stream for its own validation

There must be NO `ReadModel → Command` edges in any diagram. If you find
one, the command is incorrectly depending on a read model.

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

**For slices with a presentation layer**, the slice definition MUST include:
- **Component list:** Which design system components implement the wireframe
- **Data binding:** Which component fields bind to which read model fields
- **User actions:** Which components trigger which commands
- **New components needed:** Which components are not yet in the design system

A slice that specifies backend behavior without specifying its UI components
is incomplete — implementation agents will build the API and skip the front-end.

Bad slices: "Set up database" (technical, no user value), "Implement order
system" (too broad), "Create Order table" (implementation detail).

Also not slices: cross-cutting infrastructure (e.g., "Persist Events to
Database") that would appear identically in every workflow. Infrastructure
is not business behavior — document it in the domain overview, not as
workflow slices.

### Slice Independence

Slices that share an event schema are **independent** — connected by the
event contract, not by execution order. The event schema is the shared
contract between a command slice that produces events and a view slice that
consumes them.

```
# Bad — artificial dependency chain:
Slice 1: "Initialize Project" (must complete before Slice 2)
Slice 2: "Show Project Dashboard" (depends on Slice 1 running first)

# Good — independent slices sharing an event schema:
Slice 1: "Initialize Project" → produces ProjectInitialized event
Slice 2: "Project Dashboard" → projects from ProjectInitialized event
  (testable with synthetic ProjectInitialized fixtures, no Slice 1 needed)
```

- **Command slices** test by asserting on produced events (given prior
  events, when command executes, then these events are produced)
- **View slices** test with synthetic event fixtures (given these events,
  the projection shows this state)
- Neither slice needs the other to be implemented or running

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
