# Factory Mode -- Coordinator Behavior

This reference documents how the ensemble-team coordinator operates
differently in factory mode vs. supervised mode. The coordinator reads
this when the project has a `.factory/config.yaml` present.

## Factory Mode vs. Supervised Mode

| Aspect | Supervised Mode | Factory Mode |
|--------|----------------|--------------|
| Build-phase orchestration | Coordinator manages every handoff | Pipeline controller manages build phase |
| Decision protocol | Robert's Rules on all decisions | Robert's Rules for planning only; no consensus protocol during build |
| Merge approval | Human approves every merge | Quality gates replace human approval; human reviews in batch during Phase 3 |
| Pair management | Coordinator selects and monitors pairs | Pipeline spawns TDD pairs directly |
| Review process | Coordinator facilitates mob review per PR | Pipeline pulls full team for review before push; mob review still applies |
| Error handling | Coordinator routes all failures | Pipeline handles mechanical failures; coordinator resumes only for unrecoverable errors |

## Coordinator Role by Phase

### Phase 1: Understand + Decide

Coordinator operates normally. No change from supervised mode.

- Facilitates team discussions for planning, event modeling, domain modeling,
  and architecture decisions using the Robert's Rules protocol
- Manages vertical slice definition and priority ordering
- Records all decisions in `.team/discussions/`
- Human participates as project owner with tie-breaking authority

### Phase 1.5: Factory Configuration

Coordinator helps the team configure factory mode before build begins.

- Guide the team through `.factory/config.yaml` options: autonomy level
  (`conservative`, `balanced`, `autonomous`), gate thresholds, retry limits
- Validate that the chosen configuration is internally consistent
- Ensure the team understands what each autonomy level means for their
  workflow (e.g., at `conservative`, no auto-merge; at `autonomous`, the
  pipeline can merge without human review if all gates pass)
- Record the configuration decision using the standard Robert's Rules
  protocol (this is a Standard-category decision requiring 6-of-N quorum)

### Phase 2: Build

**The coordinator is inactive during build.** The pipeline controller replaces
the coordinator for all operational tasks.

- Pipeline acts directly on git, test runners, CI, and mutation testing
- Pipeline spawns TDD pairs from the team roster
- Pipeline pulls in the full team for mob review before each push
- No Robert's Rules consensus during build -- the pipeline follows its
  gate-based decision protocol instead
- The coordinator does not monitor, intervene, or relay messages during
  this phase

### Phase 3: Review

Coordinator reactivates for the human review phase.

- Invokes the `factory-review` skill to structure the review experience
- Presents audit trail summary, PR digests, quality trends, and pending
  escalations to the human
- Relays the human's tuning adjustments back to `.factory/config.yaml`
  (validates before applying)
- Facilitates the team retrospective using the standard Robert's Rules
  protocol
- Records retrospective output in `.factory/audit-trail/retrospectives/`

## Handoff Protocol

### Coordinator -> Pipeline (Phase 1 to Phase 2)

The coordinator provides the pipeline with:

1. **Slice queue:** Ordered list of vertical slices to build, with slice IDs,
   acceptance criteria, priority, and enriched context (boundary annotations,
   event model paths, domain types, UI components)
2. **Factory config:** Path to `.factory/config.yaml` (already validated)
3. **Team roster:** List of available engineers with their `.team/` profile
   paths and pairing history
4. **Decision context:** Paths to relevant architecture decisions, domain
   model, and event model documents
5. **Project references:** Stored in `.factory/config.yaml` under a
   `project_references` key. These paths are what the pipeline reads to
   gather pre-implementation context for each slice:
   - `architecture`: path to architecture document (e.g., `"docs/ARCHITECTURE.md"`)
   - `glossary`: path to glossary (e.g., `"docs/glossary.md"`)
   - `design_system_catalog`: path to design system catalog (e.g., `"docs/design-system/"`)
   - `event_model_root`: path to event model root directory (e.g., `"docs/event-model/"`)

The coordinator confirms the handoff is complete, then becomes inactive.

### Pipeline -> Coordinator (Phase 2 to Phase 3)

The pipeline provides the coordinator with:

1. **Summary report:** Slices completed, slices remaining, total rework
   cycles, gate failure counts
2. **Pending escalations:** Any unresolved issues that exceeded rework limits
   or encountered unrecoverable errors, with full context (which gate, what
   was tried, current state)
3. **Audit trail location:** Path to `.factory/audit-trail/` for detailed
   review

The coordinator reads the summary and activates the review phase.

## Fallback: Unrecoverable Errors

If the pipeline encounters an error it cannot resolve through its retry and
rework mechanisms:

1. Pipeline halts the affected slice (other slices may continue if
   independent)
2. Pipeline records the error in the audit trail with full context
3. Pipeline signals the coordinator to resume for the affected slice
4. Coordinator reactivates in supervised mode for that slice only
5. Coordinator facilitates the team in diagnosing and resolving the issue
   using standard Robert's Rules protocol
6. Once resolved, the coordinator may hand the slice back to the pipeline
   or continue in supervised mode for the remainder

The fallback is per-slice, not per-session. Unaffected slices continue in
factory mode.
