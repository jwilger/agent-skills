# Step 6: Find Automations

Automations are background processes that respond to events with
decision-making logic. They are one of the four fundamental patterns
in event-sourced systems.

## Facilitation Approach

For each event in the timeline, ask:

- "Does anything happen automatically after this event?"
- "What business rules trigger other processes?"
- "Does the system need to check anything before acting?"
- "Is there a time-based trigger related to this event?"

## The Four Required Components

**All four components are required for a true Automation:**

1. **A triggering event** -- what kicks off the automation
2. **A read model (the "todo list")** -- what the process consults to
   determine current state
3. **Conditional logic** -- the decision: whether and how to act based
   on what the read model shows
4. **A resulting command** -- what action the automation takes, producing
   new events

Pattern: Event -> Read Model (todo list) -> Process -> Command -> Event

## Automation vs. Co-production

If there is no read model and no conditional logic -- if the events are
always unconditionally co-produced -- it is NOT an Automation. Model it
as a single Command slice with multiple output events.

**Test:** Ask "Can this automatic response ever be skipped or vary based
on system state?"
- **Yes** -> It is an Automation (needs all four components)
- **No** -> It is co-production (a single command producing multiple
  events)

```
# Automation (conditional):
OrderPlaced -> check InventoryLevel read model
  -> if all items in stock: issue ReserveInventory command
  -> if any item out of stock: issue BackorderItems command

# NOT an Automation (unconditional co-production):
PlaceOrder command always produces both OrderPlaced AND AuditLogCreated
  -> Model as a single command with multiple output events
```

## Termination Conditions

Every automation MUST have a clear termination condition. Without one,
automations can create infinite loops where one automation triggers
another which triggers the first again.

For each automation, ask:
- "When does this stop?"
- "What prevents this from running forever?"
- "Can this automation trigger itself (directly or indirectly)?"

Document the termination condition explicitly:

```
Automation: Auto-reorder when inventory low
  Trigger: InventoryReserved
  Reads: InventoryLevel (current stock, reorder threshold)
  Logic: If stock < threshold AND no pending reorder exists
  Action: ReorderStock command
  Terminates: When stock >= threshold OR reorder already pending
```

## Output Format

List all automations with their four components and termination condition:

```
Automation: <descriptive name>
  Trigger: <event name>
  Reads: <read model name> (<what fields it checks>)
  Logic: <conditional decision>
  Action: <command name>
  Terminates: <when the automation stops>
```

## Common Pitfalls

**Do not:**
- Label unconditional co-production as an automation
- Create automations without all four components
- Skip the termination condition
- Create automations that can trigger infinite loops

**Do:**
- Apply the "Can this ever be skipped or vary?" test
- Document all four components explicitly
- Identify and document termination conditions
- Check for circular automation chains
