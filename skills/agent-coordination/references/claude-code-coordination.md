# Claude Code Coordination Patterns

Detailed guidance for multi-agent coordination using Claude Code's Agent tool
for subagent spawning, result passing, and lifecycle management.

## Agent Tool Patterns

### Spawning Subagents

Use `Agent(subagent_type="<agent-name>", prompt="...")` to spawn subagents for
delegated work. Each subagent gets a fresh context and executes independently.
Named agent types are defined in `.claude/agents/` as YAML or Markdown files.

**Naming conventions:**
- Use descriptive, role-based agent type names: `tdd-red`, `tdd-green`,
  `reviewer-a11y`, `domain-expert`
- Avoid generic names like `agent-1`, `worker-2`
- Include the task domain when multiple agents share a role:
  `reviewer-frontend`, `reviewer-backend`

**Spawning discipline:**
1. Spawn agents one at a time for dependent work (sequential spawning rule)
2. Wait for each agent's result before spawning the next
3. Provide complete context in the spawn prompt -- the subagent cannot read
   your conversation history
4. Use the `resume` parameter to continue a subagent with additional context
   rather than re-spawning from scratch

### What to Include in Subagent Prompts

Every Agent tool prompt must contain:
- The agent's specific role and responsibilities
- All files and context the agent needs to do its work
- The expected deliverable (what output format, what content)
- Any constraints (files not to touch, patterns to follow)
- Explicit completion criteria -- what "done" looks like

Do NOT assume the subagent will inherit any context from your current session.

### Sequential Spawning with Result Collection

The standard pattern for multi-phase work:
1. Spawn subagent A with full context
2. Collect subagent A's result
3. Spawn subagent B with its own context PLUS relevant results from A
4. Continue the chain

Each subagent's result becomes input context for the next. The orchestrator
is responsible for selecting which parts of prior results are relevant.

### Using the Resume Parameter

When a subagent needs additional input after returning an initial result,
use `resume` to continue its session rather than spawning a new agent:
- The resumed subagent retains its accumulated context
- Provide the new information or follow-up request in the resume prompt
- This avoids re-establishing context from scratch

## Recognizing Real vs. Fabricated Agent Messages

On Claude Code, real agent responses arrive through specific system
mechanisms. You must NEVER generate text that mimics these.

**Real agent responses look like:**
- Task/Agent tool completion output delivered by the harness
- System-level notifications (idle, error, completion)

**Fabricated responses look like:**
- `[Received message from X]` written by you in the same turn as a spawn
- Text you generate that describes what an agent "found" or "reported"
- Any substantive content appearing after a spawn without a system
  event separating them

**The hard rule:** After calling Agent with `run_in_background: true`,
your turn is DONE for that interaction. Generate at most a brief status
line ("Spawned X, waiting for response.") then stop. The next substantive
content you produce must be in response to a system-delivered event.

If you find yourself writing an agent's "findings" in the same output
block where you spawned that agent, you are fabricating. Stop immediately.

## Result-Passing Discipline

### Passing Results Between Subagents

When spawning the next subagent, include all relevant results from prior
subagents in the prompt. The orchestrator is the communication hub -- subagents
do not talk to each other.

**Prompt structure for downstream subagents:**
```
1. What you need this subagent to do (the request, one sentence)
2. Context (what prior subagents produced, what state we're in)
3. Specific deliverable (what you expect back)
4. Any constraints or deadlines
```

**Example of a good downstream prompt:**
```
Review the authentication module changes in src/auth/.
Context: The tdd-green agent refactored the token refresh logic to use
a single retry with exponential backoff (see git diff HEAD~1). The domain
model is unchanged -- this is purely implementation. Here are the test
results from the prior phase: [test output].
Deliverable: Written review in .reviews/auth-refactor.md with blocking/
non-blocking classification.
```

**Example of a bad downstream prompt:**
```
Hey, can you take a look at the latest changes?
```

### Keeping Context Focused

Do not dump every prior subagent's full output into the next prompt. Select
the relevant portions:
- Pass test results to a reviewer, not the full TDD conversation
- Pass the review summary to a fixer, not the entire review discussion
- Pass file paths and specific findings, not raw logs

### Evidence Completeness

Evidence fields must be complete before spawning the next phase. The
orchestrator verifies evidence completeness, not the subagents:
- Check that the subagent's result contains all expected deliverables
- If evidence is incomplete, resume the subagent to request the missing pieces
- Do not spawn the next phase with incomplete inputs

## Idle Notification Decision Tree

When you receive an idle notification for an agent, follow this decision
process exactly:

```
Receive idle notification
  |
  v
Is the user asking me to check on this agent?
  |
  +-- NO --> Do nothing. Stop here.
  |
  +-- YES
        |
        v
      Is there a specific pending deliverable from this agent?
        |
        +-- NO --> Tell the user the agent is processing. Do nothing else.
        |
        +-- YES
              |
              v
            Has the idle period been unusually long for this task type?
              |
              +-- NO --> Tell the user the agent is still working. Wait.
              |
              +-- YES --> Send ONE inquiry message:
                          "Status check: are you blocked on [specific task]?
                           If you need anything, let me know."
                          Then wait. Do NOT send another message.
```

**"Unusually long" guidelines:**
- Simple file review: > 5 minutes idle may warrant checking
- Complex implementation: > 15 minutes idle before considering a check
- Full test suite run: depends entirely on suite size -- do not guess

When in doubt, ask the user rather than messaging the agent.

## Subagent Lifecycle

Subagents spawned via the Agent tool are ephemeral by default. They do their
work and return a result. There is no persistent session to shut down.

**Lifecycle rules:**
- A subagent completes when it returns its result to the orchestrator
- The orchestrator decides whether to resume the subagent (with `resume`) or
  spawn a new one for the next phase
- No explicit shutdown protocol is needed for ephemeral subagents
- If a subagent was spawned with `run_in_background: true`, wait for its
  completion notification before acting on its results

**When to resume vs. re-spawn:**
- **Resume** when the subagent needs to do follow-up work in the same context
  (e.g., fix an issue it found, provide additional detail)
- **Re-spawn** when the next task requires a different role or fresh context

## User Interruption Handling

User interruptions and system interruptions require opposite responses.
Confusing them causes the proliferation cascade described in
`anti-patterns.md` (anti-pattern #9).

```
Agent interrupted
  |
  v
Was this a USER-initiated interruption?
(Ctrl+C, Escape, user typing "stop", manual cancellation)
  |
  +-- YES --> STOP. Wait for user direction.
  |           Do NOT respawn the agent.
  |           Do NOT resume the agent.
  |           Do NOT spawn a replacement.
  |           Your next action MUST be waiting for the user.
  |
  +-- NO (system interruption: compaction, timeout, crash)
        |
        v
      Can the agent be resumed with full context?
        |
        +-- YES --> Resume the agent. Provide context summary
        |           of where it left off.
        |
        +-- NO --> Respawn with full context from the last
                   known good state. Include handoff data
                   from previous work.
```

**Why this matters:** User interruptions are INTENTIONAL. The user may
want to give the agent better guidance, change the approach, redirect
entirely, or just pause. Auto-recovering treats the user's deliberate
action as an error to fix -- which is disrespectful and wastes resources.

System interruptions (context compaction, harness timeouts) are NOT
intentional. The agent was doing useful work and got cut off. Recovery
is appropriate.

**The distinction is simple:** Did the user cause the interruption? Wait
for direction. Did the system cause the interruption? Attempt recovery.

## Sequential Subagent Delegation

When using the Agent tool for subagent work:

### Sequential Dependent Tasks

For tasks that depend on each other's output:
1. Spawn subagent A, wait for completion
2. Read subagent A's output
3. Spawn subagent B with subagent A's output as context
4. Continue the chain

Never spawn dependent tasks in parallel hoping they will "figure it out."

### Independent Tasks with run_in_background

For truly independent work:
1. Verify the tasks share NO state (files, database, git working tree)
2. Spawn each with `run_in_background: true`
3. Wait for completion notifications from the harness
4. Do NOT poll for completion -- the harness will notify you

**Independence checklist:**
- [ ] No shared files being read or written
- [ ] No shared database tables being modified
- [ ] No shared git branches or working trees
- [ ] No shared network ports or services
- [ ] No ordering dependency between the tasks

If any checkbox fails, run the tasks sequentially.

### Context Isolation

Each Agent invocation gets a fresh context. This means:
- Include ALL necessary information in the agent prompt
- Do not reference "the file we discussed earlier"
- Provide file paths, not descriptions
- Include the specific acceptance criteria for the task
- State what output format you expect
