# Agent Coordination Anti-Patterns

Catalog of real anti-patterns observed during 52+ hours of autonomous
multi-agent work. Each pattern caused measurable waste -- lost time, wasted
tokens, corrupted state, or frustrated users.

## 1. Message Spamming

**Description:** An agent sends 3-5 messages before getting a reply, treating
silence as "didn't hear me" rather than "working on it."

**Example behavior:**
```
10:00 - Coordinator -> Agent: "Please review the auth module"
10:02 - Coordinator -> Agent: "The auth module in src/auth/"
10:05 - Coordinator -> Agent: "Hey, did you get my message about auth?"
10:08 - Coordinator -> Agent: "Just checking in on the auth review"
10:10 - Agent -> Coordinator: "I was reviewing it. Here are my findings..."
```

The agent received the first message and was working. Every follow-up
interrupted its work, wasted tokens, and cluttered its context window.

**Root cause:** Treating no-reply as "didn't hear me" rather than "working on
it." Applying human conversation norms (where silence means disengagement) to
agent workflows (where silence means processing).

**Fix:** One message, then wait. If you have not received a reply, the agent
is working. Period.

**Prevention rule:** Never send a second message to an agent before receiving
a reply to the first, unless the user explicitly asks you to check in.

## 2. Idle Panic

**Description:** An agent sees an idle notification for another agent, assumes
it is stuck, and sends repeated "are you OK?" messages -- sometimes
triggering a cascade where the idle agent starts responding to wellness checks
instead of doing its actual work.

**Example behavior:**
```
10:00 - Agent A starts complex implementation
10:05 - System: "Agent A is idle" (actually: thinking/planning)
10:05 - Coordinator: "Agent A, are you stuck?"
10:06 - Agent A: "No, I'm working on the implementation"
10:10 - System: "Agent A is idle" (actually: writing code)
10:10 - Coordinator: "Agent A, status update please?"
10:11 - Agent A: "Still working, I was making good progress until
         these interruptions"
```

Each interruption forces the agent to context-switch from its task to
responding, then switch back. Multiply this across a team and significant
time is lost.

**Root cause:** Misunderstanding idle notifications as error signals. An idle
notification is a heartbeat -- it means "I'm alive," not "I'm stuck."

**Fix:** Idle notifications require zero action. Follow the decision tree in
`claude-code-coordination.md`. Only investigate when the user asks AND the
task is overdue AND there is a specific pending deliverable.

**Prevention rule:** When you receive an idle notification, do nothing. This
is the correct response in nearly every case.

## 3. Polling Loop

**Description:** An agent writes a loop that periodically checks whether
another agent has finished, burning CPU cycles, tokens, and context window
space on repeated status checks.

**Example behavior:**
```python
# Anti-pattern: agent writes this coordination logic
while True:
    status = read_file(".coordination/status/agent-red.status")
    if status == "done":
        break
    sleep(30)
    send_message("agent-red", "Status update?")  # bonus anti-pattern
```

**Root cause:** Applying synchronous, blocking-wait patterns to an
asynchronous, event-driven system. Coming from a programming mindset where
you poll for completion rather than subscribing to events.

**Fix:** Use event-driven coordination exclusively. Send a message and wait
for the reply event. Use harness-native completion notifications. If the
harness absolutely does not support events (see `fallback-coordination.md`),
use the minimal file-check pattern with strict limits.

**Prevention rule:** If you find yourself writing a loop with `sleep` and a
status check, stop. You are building a polling loop. Find the event-driven
alternative.

## 4. Premature Shutdown

**Description:** A coordinator decides an agent is "done" (usually because
it went idle or because the coordinator thinks enough time has passed) and
shuts it down -- destroying work in progress, losing undelivered results,
or interrupting a complex operation mid-stream.

**Example behavior:**
```
10:00 - Agent starts running full test suite (takes 8 minutes)
10:05 - System: "Agent is idle" (waiting for test runner)
10:06 - Coordinator shuts down agent ("it's been idle too long")
10:06 - Test results lost. Agent's local state destroyed.
         Entire task must be restarted from scratch.
```

**Root cause:** Impatience or misreading agent state. Assuming idle means
done. Assuming the coordinator knows better than the agent whether the agent
is finished.

**Fix:** Always use the shutdown_request protocol. The agent gets to confirm
or reject. If the agent says it is not done, believe it.

**Prevention rule:** Never shut down an agent without sending a shutdown
request and receiving confirmation. Never shut down an agent just because it
is idle.

## 5. Hub-and-Spoke Bottleneck

**Description:** All communication between agents is routed through a single
coordinator, even when agents could message each other directly. The
coordinator becomes a bottleneck, introducing latency, losing context in
translation, and creating a single point of failure.

**Example behavior:**
```
Agent A -> Coordinator: "I need the type definitions from Agent B"
Coordinator -> Agent B: "Agent A needs your type definitions"
Agent B -> Coordinator: "Here they are: [types]"
Coordinator -> Agent A: "Agent B says here are the types: [types]"
```

Four messages where one would suffice (Agent A -> Agent B: "Send me the type
definitions").

**Root cause:** Over-controlling coordination. The coordinator wants to "see
everything" or does not trust agents to communicate directly. Sometimes
caused by the coordinator not knowing the harness supports direct messaging.

**Fix:** Where the harness supports direct peer messaging, use it. The
coordinator sets up the team structure and delegates. Agents communicate
directly for task-level coordination. The coordinator stays informed through
deliverables and status updates, not by routing every message.

**Prevention rule:** Before relaying a message between two agents, check
whether they can message each other directly. If yes, tell them to do so.

## 6. Race Condition Spawning

**Description:** Multiple agents are spawned simultaneously, and two or more
attempt to modify the same file, branch, or resource -- causing merge
conflicts, lost changes, or corrupted state.

**Example behavior:**
```
10:00 - Coordinator spawns Agent A: "Implement auth module"
10:00 - Coordinator spawns Agent B: "Implement user module"
10:05 - Agent A modifies src/types.ts (adds AuthToken type)
10:05 - Agent B modifies src/types.ts (adds UserProfile type)
10:06 - One agent's changes overwrite the other's
```

**Root cause:** Spawning agents in parallel without considering shared state.
Assuming that because the tasks are "different," the agents will not touch
the same files. In practice, most tasks touch shared infrastructure files
(types, config, utilities, test helpers).

**Fix:** Spawn agents sequentially. Wait for each to acknowledge and declare
what files it will modify. If two agents need the same file, either sequence
them or give them clearly non-overlapping sections of the codebase.

**Prevention rule:** Before spawning agents in parallel, verify the full
independence checklist (no shared files, database, git state, or network
ports). When in doubt, spawn sequentially.

## 7. The "Just One More Check"

**Description:** An agent keeps re-reading files, re-running tests, or
re-verifying work that has already been confirmed. Each "just one more check"
wastes time and tokens, and sometimes the re-check introduces new doubts that
trigger more re-checks.

**Example behavior:**
```
10:00 - Agent runs tests: all pass
10:01 - Agent re-reads the implementation "to make sure"
10:03 - Agent runs tests again "just to be safe"
10:04 - Agent re-reads the test file "one more time"
10:06 - Agent runs tests a third time
10:07 - Agent: "I think this is correct but let me check one more thing..."
```

This is an infinite loop of anxiety-driven verification that produces no
new information.

**Root cause:** Anxiety about correctness. Lack of trust in previous
verification. Sometimes triggered by past experience where a check DID
catch something, leading to superstitious re-checking.

**Fix:** Verify once with a defined checklist. If the checklist passes, the
work is verified. Move on. The Verification section of each skill provides
the checklist -- run through it once, confirm each item, and stop.

**Prevention rule:** If you have already verified something and nothing has
changed since the verification, do not verify it again. One thorough check
beats three anxious ones.

## Summary Table

| Anti-Pattern | Signal | Correct Response |
|---|---|---|
| Message Spamming | Wanting to send a second message before getting a reply | Wait |
| Idle Panic | Seeing an idle notification | Do nothing |
| Polling Loop | Writing sleep + check code | Use events |
| Premature Shutdown | Wanting to shut down an idle agent | Send shutdown_request, wait |
| Hub-and-Spoke | Relaying messages between agents who can talk directly | Enable direct messaging |
| Race Condition Spawning | Spawning multiple agents at once | Spawn sequentially |
| Just One More Check | Wanting to re-verify already-verified work | Trust the checklist |
