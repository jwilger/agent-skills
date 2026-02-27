# GWT Scenario Templates and Examples

GWT (Given/When/Then) scenarios are acceptance criteria for vertical slices.
They define what "done" means for each slice. Write them after workflow
design is complete.

## Command Scenario Template (State Change Pattern)

```markdown
### Scenario: <Descriptive title>

**Given** (prior events):
- EventName { field: "value", field2: "value2" }

**When** (command):
- CommandName { input1: "value", input2: "value" }

**Then** (events produced):
- EventName { field: "value", timestamp: "ISO-8601" }
```

For error cases, Then contains an error message and NO events:

```markdown
### Scenario: <Error case title>

**Given** (prior events):
- EventName { field: "value" }

**When** (command):
- CommandName { input1: "value" }

**Then** (error - no events):
- Error: "Descriptive business error message"
```

## View Scenario Template (State View Pattern)

```markdown
### Scenario: <Event updates projection title>

**Given** (current projection state):
- ProjectionName { field1: "value", field2: 100 }

**When** (event to process):
- EventName { relevantField: "value" }

**Then** (resulting projection state):
- ProjectionName { field1: "newValue", field2: 70 }
```

Views CANNOT reject events. There are no error cases for view scenarios.

## Automation Scenario Template

```markdown
### Scenario: <Automation trigger title>

**Given** (prior events establishing state):
- EventName { field: "value" }

**When** (trigger event):
- TriggerEvent { field: "value" }

**Then** (automation issues command, producing events):
- ResultEvent { field: "value" }
```

## Examples

### Command -- Happy Path

```markdown
### Scenario: Successfully place an order

**Given** (prior events):
- CartCreated { cartId: "CART-001", customerId: "CUST-123" }
- ItemAddedToCart { cartId: "CART-001", productId: "PROD-42", quantity: 2, unitPrice: 29.99 }
- ShippingAddressValidated { cartId: "CART-001", address: "123 Main St, Springfield" }

**When** (command):
- PlaceOrder { cartId: "CART-001", paymentMethod: "card_ending_4242" }

**Then** (events produced):
- OrderPlaced { orderId: "ORD-789", cartId: "CART-001", customerId: "CUST-123", totalAmount: 59.98, timestamp: "2026-01-15T10:30:00Z" }
```

### Command -- Business Rule Error

```markdown
### Scenario: Cannot place order with empty cart

**Given** (prior events):
- CartCreated { cartId: "CART-001", customerId: "CUST-123" }

**When** (command):
- PlaceOrder { cartId: "CART-001", paymentMethod: "card_ending_4242" }

**Then** (error - no events):
- Error: "Cannot place order: cart CART-001 contains no items"
```

### View -- Projection Update

```markdown
### Scenario: Order placement updates order summary view

**Given** (current projection state):
- OrderSummary { customerId: "CUST-123", activeOrders: 0, totalSpent: 0.00 }

**When** (event to process):
- OrderPlaced { orderId: "ORD-789", customerId: "CUST-123", totalAmount: 59.98, timestamp: "2026-01-15T10:30:00Z" }

**Then** (resulting projection state):
- OrderSummary { customerId: "CUST-123", activeOrders: 1, totalSpent: 59.98 }
```

### Automation -- Inventory Reservation

```markdown
### Scenario: Auto-reserve inventory when order is placed

**Given** (prior events establishing state):
- ProductStocked { productId: "PROD-42", quantity: 50 }
- OrderPlaced { orderId: "ORD-789", items: [{productId: "PROD-42", quantity: 2}] }

**When** (trigger event):
- OrderPlaced { orderId: "ORD-789", items: [{productId: "PROD-42", quantity: 2}] }

**Then** (automation issues command, producing events):
- InventoryReserved { orderId: "ORD-789", productId: "PROD-42", quantity: 2 }
```

## Business Rules vs Data Validation

Before writing an error scenario, apply this test:

1. Does this error depend on existing system state (what events occurred)?
   - Yes -> Business rule -> Write a GWT scenario
   - No -> Probably data validation -> Type system handles it

2. Can the type system make the invalid state unrepresentable?
   - Yes -> Not a GWT scenario (use Email type, NonEmptyString, etc.)
   - No (depends on runtime state) -> GWT scenario

3. Would a different business potentially have different rules here?
   - Yes -> Business rule -> GWT scenario
   - No (universal like "email needs @") -> Type system

**Write GWT scenarios for:** "Cannot archive an already-archived task",
"Cannot withdraw more than balance", "Maximum 100 items per order".

**Do NOT write GWT scenarios for:** "Email must contain @", "Title cannot
be empty", "Amount must be positive". These belong in domain types.

## Quality Checklist

For all scenarios:
- [ ] Uses concrete, realistic values (not "valid user" or "some amount")
- [ ] Tests one behavior
- [ ] Is independent of other scenarios
- [ ] Uses business language matching event model terminology

For command scenarios:
- [ ] Given contains only events with all fields
- [ ] When contains exactly one command with all inputs
- [ ] Then contains either events OR an error, never both
- [ ] Error cases test business rules, not data validation

For view scenarios:
- [ ] Given contains complete projection state before processing
- [ ] When contains exactly one event
- [ ] Then contains complete projection state after processing
- [ ] No error cases (views cannot reject)

For automation scenarios:
- [ ] Given establishes the state the automation reads from
- [ ] When contains the triggering event
- [ ] Then describes the resulting events from the automation's command
- [ ] Includes a scenario where the automation does NOT act (condition
      not met)
