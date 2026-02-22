# Autonomy Levels

The pipeline operates at one of three autonomy levels. Each level determines
how much the pipeline can do without human intervention. The level is set in
`.factory/config.yaml` and can be changed at any time.

## Conservative

**Philosophy:** Maximum human oversight. Every significant outcome is reported
and every merge requires approval. Use this when establishing trust with a new
project, working in an unfamiliar domain, or when the cost of an undetected
mistake is high.

**Behavior:**
- All five quality gates enforced, no exceptions
- No auto-merge: human approves every merge
- No auto-rework: human is notified of every gate failure and decides whether
  to rework or skip
- No decision batching: every review finding is surfaced individually
- No parallel slices: one slice at a time, sequentially
- Human notified of every gate result (pass or fail)

**Human interaction cadence:** Every gate, every merge, every failure.

**Good for:** New projects, unfamiliar domains, first week of pipeline use,
regulated environments.

## Standard

**Philosophy:** Balanced autonomy. The pipeline handles routine rework and
batches non-blocking information. The human is involved for merges and
significant issues. Use this for established projects with proven CI and a
track record of successful pipeline runs.

**Behavior:**
- All five quality gates enforced
- Auto-rework on gate failures within the 3-cycle budget: the pipeline routes
  failures back to the appropriate skill and retries without human involvement
- Batch non-blocking review findings: SUGGESTION-severity items from code
  review are collected and presented at the next human review cycle rather
  than surfaced individually
- Skip trivial review findings: formatting and minor naming suggestions that
  do not affect correctness are noted in the audit trail but do not trigger
  rework
- Auto-retry CI on infrastructure failures: one automatic retry before
  notifying the human
- No auto-merge: human still approves every merge
- No parallel slices: one slice at a time

**Human interaction cadence:** Every merge, budget exhaustion, critical
findings, CI configuration failures.

**Review frequency options:**
- `every_slice` (default): human reviews and merges after each slice
- `every_3_slices`: human reviews a batch of up to 3 completed slices
- `daily`: human reviews all completed slices once per day

**Good for:** Established projects with proven CI, teams that have run the
pipeline successfully for several slices.

## Full

**Philosophy:** Maximum pipeline autonomy. The pipeline merges automatically
when all gates pass and optimizes its own operations. The human is involved
only for escalations and budget exhaustion. Use this for mature projects with
comprehensive test suites, stable CI, and a strong track record of clean
pipeline runs.

**Behavior:**
- All five quality gates enforced
- Auto-rework on gate failures within budget
- Auto-merge when all five gates pass: no human approval required
- Parallel slice execution: slices with no shared file dependencies can run
  concurrently (the pipeline detects file overlap by analyzing the task
  decomposition and changed-file lists)
- Pair selection optimization: the pipeline considers domain affinity from
  memory when selecting TDD pairs, not just pairing history constraints
- Slice ordering optimization: the pipeline may reorder pending slices based
  on dependency analysis and pair availability
- All standard-level automations included

**Human interaction cadence:** Budget exhaustion, critical escalations,
retrospective reviews.

**Parallel execution rules:**
- The pipeline detects worktree support by running `git worktree list`. If
  the command succeeds, parallel slices use worktree isolation. If it fails
  (shallow clones, non-git VCS, restricted environments), the pipeline falls
  back to sequential execution for all slices, regardless of autonomy level,
  and logs a warning explaining why parallel execution is unavailable.
- Each parallel slice gets its own git worktree at
  `.factory/worktrees/<slice-id>`, created from the integration branch when
  the slice is activated. All work for that slice (TDD, review, mutation
  testing) happens within the worktree directory. The pipeline passes the
  worktree path as `WORKING_DIRECTORY` to all downstream skills.
- On slice completion, the pipeline merges the worktree branch back to the
  integration branch and removes the worktree. On slice escalation, the
  worktree is removed and the branch is preserved for human inspection.
- Conflicts are detected at merge time, not predicted in advance. If a merge
  conflict occurs, the pipeline attempts an automatic rebase of the slice
  branch onto the updated integration branch and re-runs CI. If the rebase
  fails (due to non-trivial conflicts), the pipeline escalates to the human
  with full context.
- Parallel slices maintain independent audit trails and gate evidence
- Each parallel slice has its own rework budget

**Good for:** Mature projects with comprehensive test suites, stable CI,
5+ successful clean pipeline runs at standard level.

## Configuration

Autonomy level is set in `.factory/config.yaml`:

```yaml
autonomy_level: conservative  # conservative | standard | full

gates:
  tdd: required       # always required, cannot be disabled
  review: required    # always required, cannot be disabled
  mutation: required  # always required, cannot be disabled
  ci: required        # always required, cannot be disabled
  merge: manual       # manual | auto (auto only valid at full level)

rework_budget: 3  # max rework cycles per gate per slice

# Only applies at standard level
review_frequency: every_slice  # every_slice | every_3_slices | daily
```

**Validation rules:**
- `merge: auto` is rejected unless `autonomy_level` is `full`
- `rework_budget` must be a positive integer (1-10 range recommended)
- All gates must be `required` -- the pipeline does not support disabling gates
- `review_frequency` is ignored at conservative and full levels

## Changing Levels

The autonomy level can be changed at any time by editing `.factory/config.yaml`.
The change takes effect on the next slice (the current in-progress slice, if any,
finishes under its original level).

**Recommended progression:**
1. Start at conservative for the first 2-3 slices
2. Move to standard after verifying gate evidence quality and rework routing
3. Move to full after 5+ successful slices at standard with no escalations

The pipeline does not auto-promote. Level changes are always a human decision.
