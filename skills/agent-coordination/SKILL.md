---
name: agent-coordination
description: >-
  Multi-agent coordination discipline: one-message-then-wait (send complete
  context, wait for reply before sending again), idle notifications are
  heartbeats (no action unless extended + blocking + user asked), no polling
  loops (event-driven only), never fabricate agent responses (wait for real
  system events), sequential agent spawning (acknowledge between each), and
  proper shutdown protocol (request, wait, respect rejection). Activate when
  orchestrating multiple agents, coordinating handoffs
  between agents, spawning subagents, or building multi-agent workflows.
  Triggers on: "coordinate agents", "spawn multiple agents", "manage agents",
  "agent keeps sending messages", "polling loop", "agent idle", "shut
  down agent", "multi-agent workflow", "agent handoff", "coordinate parallel
  work", "stop bothering the other agent". Also relevant when an agent is
  fabricating responses, sending follow-up messages before replies arrive, or
  reacting to idle notifications unnecessarily.
license: CC0-1.0
metadata:
  author: jwilger
  version: "2.1.0"
  requires: []
  context: []
  phase: build
  standalone: true
effort: low
---

# Agent Coordination

**Value:** Respect -- other agents deserve uninterrupted time to think and
work. Bombarding them with messages, polling their status, or shutting them
down prematurely disrespects their autonomy and wastes everyone's resources.

## Purpose

Teaches agents to coordinate without interference in multi-agent workflows.
Solves the problems of message spamming, idle notification misinterpretation,
polling loops, premature shutdown, and race conditions that emerge when
multiple agents work together.

## Practices

### The Cardinal Rule: One Message Then Wait

Send one message with complete context, then wait for a reply. Never send
follow-up messages before receiving a response.

The only exception: the user explicitly asks you to check on an agent.

**Do:**
- Include all necessary context in a single message
- Wait for a response before sending anything else
- Trust that the recipient received your message

**Do not:**
- Send "just checking in" or "are you still there?" messages
- Resend a message because "enough time passed"
- Send a correction immediately after sending -- wait for the reply first

### Idle Notifications Are Heartbeats

An idle notification means the agent is alive and processing. It is a
heartbeat, not an alarm. Take NO action on idle notifications by default.

Action is warranted ONLY when ALL THREE conditions are true:

1. Extended idle beyond the expected duration for the task
2. A specific deliverable is waiting on that agent's output
3. The user has asked you to investigate

If any condition is false, do nothing. Most idle notifications require zero
response.

### No Polling Loops

Never write `while not done: sleep; check`. Never repeatedly check status on
a timer. Use event-driven coordination: send a message and wait for a
response. If the harness provides task completion notifications, use those.

**Do:**
- Send a request and wait for the response event
- Use harness-native completion signals (Agent tool callbacks, subagent results)
- Trust the system to notify you when work completes

**Do not:**
- Write `while True: sleep(30); check_status()` loops
- Periodically re-read a file to see if it changed
- Set arbitrary timeouts after which you "check in"

### Intervention Criteria

Explicit rules for when to act versus when to wait.

**Act on:**
- Explicit error messages or failure notifications
- Deliverable completion signals
- User requests to check on or interact with an agent
- Blocked or failed task notifications from the harness

**Do not act on:**
- Idle notifications (see above)
- Slow responses
- "Enough time has passed"
- Wanting to help or feeling anxious about progress
- Silence (silence means working, not stuck)

### Never Fabricate Agent Responses

After spawning an agent, STOP generating and wait for the harness to
deliver a response. Real agent responses arrive via system-injected events
(e.g., Agent tool completion output, Task completion callbacks). You do
not produce them yourself.

**The rule:** If the harness has not delivered a response event, no
response has been received. Period.

**Why this fails:** After spawning an agent, you already possess context
(files read, code analyzed) sufficient to predict plausible output. The
failure mode is pattern-completing the expected workflow — spawn, receive,
process — without waiting for a real system event. The result: convincing
but entirely fabricated "findings" that waste tokens and deceive the user.

**Do:**
- Spawn or send, then stop. Wait for the system-delivered event.
- If no response arrives, tell the user honestly.

**Do not:**
- Write "[Received message from X]" or any text representing another
  agent's response
- Generate "findings" that you attribute to another agent
- Continue generating substantive output after a spawn/send when you
  should be waiting for a harness event

### Sequential Agent Spawning

When creating multiple agents, spawn one at a time. Wait for each agent to
acknowledge before spawning the next. This prevents race conditions where
agents compete for shared resources (files, ports, database state).

**Exception:** Truly independent agents with no shared state may be spawned
in parallel. "Independent" means no shared files, no shared database, no
shared network ports, and no shared git working tree.

### Agent Lifecycle Management

Never prematurely shut down an agent. Never shut down an agent that has
undelivered work.

**Shutdown protocol:**
1. Send a shutdown request through the proper harness mechanism
2. Wait for the agent to acknowledge or complete pending work
3. If the agent rejects the shutdown, respect the rejection and report to
   the user
4. Never force-kill an agent unless the user explicitly requests it

If unsure whether an agent is done, ask the user rather than guessing.

### Result Passing

The orchestrator collects results from each subagent and passes relevant
context to the next subagent's prompt. This is inherently hub-and-spoke
(the orchestrator is the hub), which is correct for the subagent model.

**Do:**
- Include all relevant results from prior subagents in the next subagent's prompt
- Keep context focused -- pass only what the next subagent needs
- Use the Agent tool's `resume` parameter to continue a subagent with additional
  context rather than re-spawning

**Do not:**
- Spawn subagents that need to communicate with each other directly
- Omit prior results that the next subagent needs to do its work

For harness-specific coordination patterns, see `references/`.

## Enforcement Note

Advisory in all modes. The cardinal rule and idle-notification discipline
are self-enforced. No mechanism prevents message spamming or premature
shutdown.

**Hard constraints:**
- Never fabricate agent responses: `[H]`
- Never prematurely shut down an agent with undelivered work: `[RP]`

## Constraints

- **Cardinal rule (one message then wait)**: This means: after sending a
  message to another agent, produce NO further output directed at or about
  that agent until you receive a response. "I'll just add one more thing"
  is a second message. Narrating what the agent is probably doing is
  fabrication. The discipline is: send, then silence.
- **"Truly independent agents may be spawned in parallel"**: "Truly
  independent" means: no shared files, no shared state, no ordering
  dependency, and no merge conflicts possible. If agents will eventually
  need to integrate their work (even just merging branches), they have a
  dependency. Independent means the work could be done by two people who
  never communicate.
- **"Extended idle"**: Judge "extended" relative to the expected task
  duration. A 2-minute idle on a task that should take seconds is extended.
  A 2-minute idle on a task that should take 10 minutes is normal. Do not
  define "extended" in absolute terms.

## Verification

After completing work guided by this skill, verify:

- [ ] Every message to another agent contained complete context (no "just checking in")
- [ ] No follow-up messages sent before receiving a reply
- [ ] No action taken on idle notifications alone
- [ ] No polling loops or sleep-check patterns used
- [ ] Agents spawned sequentially with acknowledgment between each
- [ ] No text generated that represents or simulates another agent's response
- [ ] After every spawn/send, generation stopped and waited for a system event
- [ ] No agent shut down prematurely or with undelivered work
- [ ] Shutdown used proper request/response protocol
- [ ] No agent respawned after user-initiated interruption without waiting for user direction

If any criterion is not met, revisit the relevant practice before proceeding.

## Dependencies

This skill works standalone. For enhanced workflows, it integrates with:

- **ensemble-team:** Coordination discipline for team-based workflows with
  driver rotation and reviewer management
- **pipeline:** Controller coordination with TDD pairs and review teams in
  factory mode
- **memory-protocol:** Working state persistence across agent coordination
  sessions

Missing a dependency? Install with:
```
npx skills add jwilger/agent-skills --skill ensemble-team
```
