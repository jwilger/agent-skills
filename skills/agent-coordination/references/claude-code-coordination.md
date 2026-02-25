# Claude Code Coordination Patterns

Detailed guidance for multi-agent coordination using Claude Code's specific
tools: TeamCreate, SendMessage, Task, and shutdown protocols.

## TeamCreate Patterns

### Creating Persistent Teams

Use TeamCreate for agents that need to persist across multiple interactions --
reviewers, domain experts, long-running builders. Each team member gets a
dedicated context and can receive messages.

**Naming conventions:**
- Use descriptive, role-based names: `tdd-red`, `tdd-green`, `reviewer-a11y`,
  `domain-expert`
- Avoid generic names like `agent-1`, `worker-2`
- Include the task domain when multiple agents share a role:
  `reviewer-frontend`, `reviewer-backend`

**Team lifecycle:**
1. Create agents one at a time (sequential spawning rule)
2. Wait for each agent's acknowledgment message before creating the next
3. Provide complete context in the creation prompt -- the agent cannot read
   your mind or your conversation history
4. Keep agents alive between related tasks to preserve accumulated context
5. Only shut down agents when their role is complete for the session

### What to Include in Agent Creation Prompts

Every TeamCreate prompt must contain:
- The agent's specific role and responsibilities
- All files and context the agent needs to do its work
- The communication protocol (who to message, what format)
- What "done" looks like -- explicit completion criteria
- Instructions to use the shutdown protocol when finished

Do NOT assume the agent will inherit any context from your current session.

## SendMessage Discipline

### One Message, Complete Context

Every SendMessage call must be self-contained. The recipient may have
compacted their context since your last interaction.

**Message structure:**
```
1. What you need (the request, one sentence)
2. Context (what happened, what state we're in)
3. Specific deliverable (what you expect back)
4. Any constraints or deadlines
```

**Example of a good message:**
```
Please review the authentication module changes in src/auth/.
Context: We refactored the token refresh logic to use a single retry
with exponential backoff (see git diff HEAD~1). The domain model
unchanged -- this is purely implementation.
Deliverable: Written review in .reviews/auth-refactor.md with blocking/
non-blocking classification.
```

**Example of a bad message:**
```
Hey, can you take a look at the latest changes?
```

### What Never to Send

- "Just checking in" -- violates the cardinal rule
- "Did you get my last message?" -- yes, they did
- "Are you still working on this?" -- if no reply, yes they are
- Status requests without user prompting -- idle means working
- The same message rephrased -- they heard you the first time

### After Sending

After calling SendMessage:
1. Stop. Do other work if you have any.
2. Wait for the reply event from the harness.
3. Do NOT send another message to the same agent before receiving a reply.
4. If the user asks you to check on the agent, send ONE inquiry -- then
   wait again.

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

## Shutdown Protocol

### shutdown_request / shutdown_response

Always use the proper shutdown handshake. Never force-terminate an agent.

**Shutdown sequence:**
1. Send `shutdown_request` message to the agent
2. The agent may:
   - **Accept**: Finishes current work, delivers final output, confirms shutdown
   - **Reject**: Has pending work or undelivered results, explains why
3. If accepted: wait for the shutdown confirmation, then proceed
4. If rejected: report to the user with the agent's reason. Let the user
   decide whether to force shutdown or wait.

**Never do:**
- Kill an agent's session without sending shutdown_request
- Assume an idle agent is "done" and shut it down
- Shut down an agent that said it has undelivered work
- Send shutdown_request and immediately proceed without waiting for response

### When to Initiate Shutdown

- The agent has delivered its final output and confirmed completion
- The user explicitly requests shutting down the agent
- The agent has been idle AND confirmed it has no pending work

### When NOT to Initiate Shutdown

- The agent is idle (idle means processing, not done)
- You think the agent "should be done by now"
- You want to free up resources (ask the user first)
- The agent is taking longer than expected

## Task Tool Sequential Delegation

When using the Task tool for subagent work (rather than persistent teams):

### Sequential Dependent Tasks

For tasks that depend on each other's output:
1. Spawn Task A, wait for completion
2. Read Task A's output
3. Spawn Task B with Task A's output as context
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

Each Task invocation gets a fresh context. This means:
- Include ALL necessary information in the task prompt
- Do not reference "the file we discussed earlier"
- Provide file paths, not descriptions
- Include the specific acceptance criteria for the task
- State what output format you expect
