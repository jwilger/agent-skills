# Slice Queue Management

The pipeline maintains a queue of vertical slices in `.factory/slice-queue.json`.
This document defines the queue structure, slice states, ordering strategy,
dependency tracking, and queue operations.

## Queue Structure

```json
{
  "project": "my-project",
  "created_at": "2026-02-22T09:00:00Z",
  "updated_at": "2026-02-22T14:30:00Z",
  "slices": [
    {
      "id": "walking-skeleton",
      "description": "Thinnest end-to-end path: HTTP request -> handler -> repository -> response",
      "status": "completed",
      "priority": 1,
      "depends_on": [],
      "source": "event-model",
      "worktree_path": null,
      "context": {
        "event_model_path": null,
        "related_slices": [],
        "gwt_scenarios": [
          {
            "given": "no running application",
            "when": "the deploy pipeline executes",
            "then": "the application serves a health-check endpoint",
            "boundary": "HTTP"
          }
        ],
        "domain_types_referenced": [],
        "ui_components_referenced": []
      },
      "started_at": "2026-02-22T09:15:00Z",
      "completed_at": "2026-02-22T11:00:00Z"
    },
    {
      "id": "auth-registration",
      "description": "User can register with email and password",
      "status": "active",
      "priority": 2,
      "depends_on": ["walking-skeleton"],
      "source": "event-model",
      "worktree_path": ".factory/worktrees/auth-registration",
      "context": {
        "event_model_path": "docs/event-model/auth.md",
        "related_slices": ["auth-login"],
        "gwt_scenarios": [
          {
            "given": "a visitor on the registration page",
            "when": "they submit valid email and password",
            "then": "a new user account is created and a confirmation is shown",
            "boundary": "HTTP"
          }
        ],
        "domain_types_referenced": ["User", "RegistrationCommand", "UserRegistered"],
        "ui_components_referenced": ["RegistrationForm"]
      },
      "started_at": "2026-02-22T11:05:00Z",
      "completed_at": null
    },
    {
      "id": "auth-login",
      "description": "User can log in with registered credentials",
      "status": "pending",
      "priority": 3,
      "depends_on": ["auth-registration"],
      "source": "event-model",
      "worktree_path": null,
      "context": {
        "event_model_path": "docs/event-model/auth.md",
        "related_slices": ["auth-registration"],
        "gwt_scenarios": [
          {
            "given": "a registered user on the login page",
            "when": "they submit valid credentials",
            "then": "they are authenticated and redirected to the dashboard",
            "boundary": "HTTP"
          }
        ],
        "domain_types_referenced": ["User", "LoginCommand", "UserAuthenticated"],
        "ui_components_referenced": ["LoginForm"]
      },
      "started_at": null,
      "completed_at": null
    },
    {
      "id": "auth-password-reset",
      "description": "User can reset a forgotten password",
      "status": "blocked",
      "priority": 4,
      "depends_on": ["auth-registration"],
      "blocked_reason": "Dependency auth-registration is still active",
      "source": "event-model",
      "worktree_path": null,
      "context": {
        "event_model_path": "docs/event-model/auth.md",
        "related_slices": ["auth-registration", "auth-login"],
        "gwt_scenarios": [
          {
            "given": "a registered user",
            "when": "they request a password reset",
            "then": "a reset email is sent",
            "boundary": "HTTP"
          }
        ],
        "domain_types_referenced": ["User", "PasswordResetRequested"],
        "ui_components_referenced": ["PasswordResetForm"]
      },
      "started_at": null,
      "completed_at": null
    }
  ]
}
```

## Slice States

| State | Meaning | Transitions To |
|-------|---------|---------------|
| `pending` | Defined and waiting. All dependencies met. Ready to start. | `active` |
| `active` | Currently being processed by the pipeline. | `completed`, `escalated` |
| `blocked` | Waiting on one or more dependencies to complete. | `pending` (when deps resolve) |
| `completed` | All gates passed, code merged. | Terminal state |
| `escalated` | Rework budget exhausted, awaiting human decision. | `pending` (if human unblocks), `completed` (if human resolves) |

**State transition rules:**
- A slice moves from `blocked` to `pending` automatically when all its
  dependencies reach `completed` status.
- Only one slice may be `active` at a time, unless the pipeline is running
  at full autonomy level with no file conflicts (see Parallel Execution).
- A slice cannot move to `active` if any dependency is not `completed`.
- `escalated` slices remain in the queue. The human may resolve the issue
  and return the slice to `pending`, or mark it `completed` manually.

## Ordering Strategy

When selecting the next slice to activate, the pipeline applies these rules
in priority order:

### 1. Walking Skeleton First

The first slice in any project must be a walking skeleton: the thinnest
end-to-end path proving all architectural layers connect. It may use
hardcoded values or stubs. No other slice may begin until the walking
skeleton is completed. The pipeline enforces this by checking whether any
slice with `id` containing "walking-skeleton" (or explicitly marked as such)
exists and is completed before activating other slices.

### 2. Dependency Graph

Among `pending` slices, prefer those whose dependencies completed most
recently. This maintains momentum on related work and keeps context warm.
A slice with zero dependencies is always eligible.

### 3. Priority

Among slices with equal dependency status, use the `priority` field
(lower number = higher priority). Priority is set at enqueue time, typically
reflecting business value or risk.

### 4. FIFO Tiebreak

If priority is also equal, process in the order they were enqueued (first
in, first out).

## Dependency Tracking

Each slice declares its dependencies via the `depends_on` field: an array
of slice IDs that must reach `completed` status before this slice can
become `pending`.

**Dependency rules:**
- Dependencies must form a directed acyclic graph (DAG). The pipeline
  validates this at enqueue time and rejects cycles.
- A dependency on an `escalated` slice blocks the dependent. The human must
  resolve the escalated slice first.
- Dependencies are by slice ID, not by file or module. If two slices modify
  the same files but have no declared dependency, the pipeline handles
  conflicts via the parallel execution rules (full autonomy) or sequential
  processing (conservative/standard).

## Queue Operations

### Enqueue

Add a new slice to the queue.

**Input:** Slice definition (id, description, priority, depends_on, source, context).
**Validation:**
- Slice ID must be unique within the queue
- Dependencies must reference existing slice IDs
- Adding the slice must not create a dependency cycle
- Priority must be a positive integer
- The `context` block must be present with at least one GWT scenario that
  includes a `boundary` field (ensures every slice has boundary annotation
  for the gate to check against)

**Effect:** Slice is added with status `blocked` (if it has unmet
dependencies) or `pending` (if all dependencies are met or it has none).

### Dequeue

Select the next slice to process.

**Input:** None.
**Algorithm:** Apply the ordering strategy (walking skeleton, dependency
graph, priority, FIFO). Return the highest-priority `pending` slice.
**Effect:** Selected slice moves to `active`.

### Block

Mark a slice as blocked.

**Input:** Slice ID and reason.
**Validation:** Slice must be in `pending` state.
**Effect:** Slice moves to `blocked` with `blocked_reason` recorded.

### Unblock

Check blocked slices for resolved dependencies.

**Input:** None (triggered automatically after any slice completes).
**Algorithm:** For each `blocked` slice, check whether all `depends_on`
slice IDs are in `completed` state. If yes, move to `pending`.
**Effect:** Zero or more slices move from `blocked` to `pending`.

### Complete

Mark a slice as completed.

**Input:** Slice ID.
**Validation:** Slice must be in `active` state. All five quality gates must
show PASS in the audit trail.
**Effect:** Slice moves to `completed`. `completed_at` is set. Triggers
unblock check on all `blocked` slices.

### Escalate

Mark a slice as escalated.

**Input:** Slice ID, gate name, escalation reason.
**Validation:** Slice must be in `active` state.
**Effect:** Slice moves to `escalated`. Escalation record written to
`.factory/audit-trail/escalations/`.

## Parallel Execution (Full Autonomy Only)

At full autonomy level, the pipeline may activate multiple slices
concurrently if they have no predicted file conflicts.

**Conflict detection:**
1. When a slice is decomposed, the task-management skill lists predicted
   files to be created or modified.
2. Before activating a second slice in parallel, the pipeline compares
   predicted file lists between the candidate and all currently active slices.
3. If any file appears in both lists, the candidate is not eligible for
   parallel execution and waits.

**Worktree isolation:**
Each active parallel slice operates in its own git worktree at
`.factory/worktrees/<slice-id>`. The worktree is created from the
integration branch when the slice is activated, and all work for the slice
(TDD, review, mutation testing) happens within that worktree. Downstream
skills receive the worktree path as `WORKING_DIRECTORY` and are unaware of
the isolation mechanism.

Conflicts are detected at merge time only -- no mid-execution prediction is
needed because each worktree has its own working copy. On slice completion,
the pipeline merges the worktree branch back to the integration branch. If
merge conflicts occur, the pipeline attempts an automatic rebase of the
slice branch onto the updated integration branch and re-runs CI. If the
rebase fails (non-trivial conflicts), the pipeline escalates to the human
with full context. The worktree is removed after a successful merge or on
slice escalation (the branch is preserved for human inspection in the
escalation case).

**Limits:**
- Maximum 3 slices active in parallel (prevents excessive context usage)
- Each parallel slice has its own independent audit trail and rework budget
- Parallel slices do not share TDD pairs
