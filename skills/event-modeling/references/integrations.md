# Step 7: Map External Integrations

Identify external system interactions using the Translation pattern.
Translations are the anti-corruption layer between your domain and
the outside world.

## Facilitation Approach

For each workflow, ask:

- "Does this workflow receive data from outside the system?"
- "Does this workflow send data to external systems?"
- "What third-party services does this workflow depend on?"
- "What notifications need to go out?"

## Translation Pattern

External data enters or leaves the system through Translations:

- **Inbound:** External Data -> Translation -> Internal Event
- **Outbound:** Internal Event -> Translation -> External Action

Translations map between external representations and your domain's
event language.

## Names and Purposes Only

At this stage, note only the **name** of the external system and its
**general purpose**. No technical details.

```
# Good:
- Stripe: provides payment confirmation
- SendGrid: delivers order confirmation emails
- Warehouse API: receives shipping instructions

# Bad (too much implementation detail):
- Stripe webhook sends POST to /api/webhooks/stripe with JSON payload
- SendGrid v3 API requires API key in X-SG-KEY header
- Warehouse REST API at https://warehouse.example.com/api/v2/shipments
```

Implementation details belong in architecture decisions and technical
design, not in the event model.

## Infrastructure vs. Domain Translations

Not every external interaction is a Translation slice. Ask: **"Is this
integration specific to THIS workflow, or would every workflow need it?"**

- **Workflow-specific** -> Translation slice (model it)
- **Cross-cutting** -> Infrastructure (do not model as a slice)

```
# Translation slice (workflow-specific):
- Stripe payment confirmation -> specific to the ordering workflow
- Weather API data -> specific to the logistics workflow

# NOT a Translation slice (cross-cutting infrastructure):
- Event persistence to database -> every workflow needs this
- Message transport between services -> every workflow needs this
- Logging and monitoring -> every workflow needs this
- Authentication/authorization -> every workflow needs this
```

Cross-cutting infrastructure is noted in the domain overview as a
shared dependency, not as a workflow-specific Translation slice.

## Output Format

List all external integrations with their type and direction:

```
External Integrations:
  Inbound:
    - Stripe -> provides payment confirmation (Translation: PaymentConfirmed)
    - Webhook from partner -> provides inventory updates (Translation: InventoryUpdated)

  Outbound:
    - SendGrid <- receives order confirmation for email delivery
    - Warehouse API <- receives shipping instructions

  Infrastructure (not modeled as slices):
    - PostgreSQL: event persistence
    - RabbitMQ: inter-service messaging
```

## Common Pitfalls

**Do not:**
- Include technical implementation details (APIs, protocols, URLs)
- Model cross-cutting infrastructure as Translation slices
- Skip outbound integrations (notifications, data feeds)
- Design the integration -- just identify it

**Do:**
- Distinguish inbound from outbound integrations
- Apply the "workflow-specific vs. cross-cutting" test
- Note the domain purpose of each integration
- Keep it to names and purposes only
