# Step 3: Create Wireframes

For each user interaction point in the timeline, create an ASCII wireframe.
These wireframes do not need to represent the actual UI/UX of the
application. Their purpose is to provide a complete accounting of what data
a user can see and what actions a user can take from each screen.

## Facilitation Approach

At each point where a user interacts with the system, ask:

- "What does the user see on this screen?"
- "What data do they need to make a decision?"
- "What actions can they take from here?"
- "What information do they provide with each action?"

## Wireframe Structure

Each wireframe shows three things:

1. **What data the user SEES** (from read models)
2. **What data the user PROVIDES** (command inputs)
3. **What actions the user can TAKE** (buttons/triggers)

```
+-------------------------------+
|  Place Order                  |
+-------------------------------+
|  Items: [list from cart]      |  <- SEES (read model)
|  Shipping: [address]          |  <- SEES (read model)
|  Total: $XX.XX                |  <- SEES (read model)
|                               |
|  Payment: [card selector]     |  <- PROVIDES (command input)
|                               |
|  [Confirm Order]              |  <- TAKES ACTION (command trigger)
|  [Cancel]                     |  <- TAKES ACTION (command trigger)
+-------------------------------+
```

## Traceability Rule

Every wireframe field must trace to either:
- An **event field** (for displayed data via read models), or
- A **command input** (for user-provided data)

If you cannot trace a field, something is missing from the event model.
Add the missing event or command input before proceeding.

## Wireframe-to-Component Mapping

When a design system exists (or will be created), map each wireframe
element to design system components:

1. **Identify every interactive and display element** in the wireframe
   (buttons, inputs, labels, lists, cards, forms, etc.)
2. **Map each element to a design system component** (or note if a new
   component is needed): which atoms (Button, Input, Label), molecules
   (FormField, SearchBar), and organisms (Form, Table, Card)?
3. **Create a component checklist** for the slice:
   ```
   Components for OrderForm wireframe:
   - [ ] OrderItemList (organism) <- displays Order read model items
   - [ ] PriceInput (molecule) <- captures price for PlaceOrder command
   - [ ] SubmitButton (atom) <- triggers PlaceOrder command
   Status: All exist in design system / NewComponentNeeded
   ```
4. **Verify component traceability:**
   - Every wireframe field displaying data traces to a read model AND a
     named component
   - Every wireframe field accepting input feeds a command AND uses a
     named component
   - Every component exists in the design system or is flagged as new

If no design system exists yet, flag components as "to-be-designed" and
note them as a prerequisite before implementation.

## Concurrency Check

If the domain supports concurrent instances (e.g., multiple orders,
multiple journeys), wireframes should show lists or tables, not
single-item views.

Ask: **"Can there be more than one of these in progress at the same
time?"**

If yes, the wireframe must show a collection view, not a single-item
detail view. The detail view comes from selecting an item in the
collection.

## Output Format

Produce one ASCII wireframe per user interaction point, with annotations
tracing each field to its source (event/read model or command input).

## Common Pitfalls

**Do not:**
- Design beautiful UI -- these are data inventories, not mockups
- Skip wireframes for "simple" screens
- Forget error states and empty states
- Show a single-item view when the domain has concurrent instances

**Do:**
- Create a wireframe for every user interaction in the timeline
- Annotate every field with its data source
- Include empty/loading/error states where relevant
- Map to design system components when available
