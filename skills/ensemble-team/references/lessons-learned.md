# Lessons Learned from Production Ensemble Teams

These lessons are distilled from running AI ensemble teams on real projects. Bake them
into every new team setup from day one.

## Agent Behavior Issues

### Drivers Go Idle Without Executing Git Commands
- **Problem**: Agent completes coding but doesn't commit/push when instructed
- **Fix**: Spawn prompt must include explicit instructions: "After receiving consensus,
  you MUST run git add, git commit, and git push. Do not go idle until all three complete."
- **Ongoing**: Expect to nudge via messages. This is a persistent pattern.

### Drivers Get Stuck on Completed Tasks
- **Problem**: Agent continues referencing or working on tasks already finished
- **Fix**: Always provide written summary of completed work + `git log --oneline -10`
  verification before new task starts. Driver handoff protocol is mandatory.

### Drivers Skip Blocking Review Feedback
- **Problem**: Driver acknowledges review but doesn't fix all blocking items
- **Fix**: Verify ALL blocking issues are addressed before re-requesting consensus.
  Spawn prompt must include: "Do not re-request consensus until you have addressed
  all blocking feedback."

### Stale Session-End Requests
- **Problem**: Session-end requests from previous sessions get picked up by new agents
- **Fix**: Instruct agents in activation prompt to reject unexpected session-end requests.

## Process Pipeline

### Refactor Step Must Be Mandatory
- Discovered that making refactoring optional leads to accumulated tech debt. Every
  commit must include a refactor check before committing.

### Consensus Before Push (Not After)
- Code should be reviewed locally before reaching the remote. This keeps CI wait out
  of the feedback loop. Push only after all team members consent.

### CI Wait Rule
- Never have more than one pending CI run. If CI fails, fix it before pushing anything
  else. Queueing multiple CI runs leads to cascading failures.

### Mini-Retro After Every CI Build
- 1-minute checkpoint run by the team (NOT the coordinator): (a) Did we follow the
  pipeline? (b) Was the commit atomic? (c) Any process improvements?
- This catches violations immediately rather than accumulating them.

## Coordination

### Always Broadcast Review Requests Explicitly
- Don't assume agents will self-start reviews. The coordinator must explicitly request
  reviews from the team after the Driver commits.

### Keep Reviewers Alive Between Tasks
- Only rotate the Driver. Keep all Reviewers alive to preserve context accumulated
  from reviewing prior tasks. End and re-activate only the outgoing Driver and the
  incoming Driver (who needs new permissions).

### Verify Clean Working Tree Before New Tasks
- Ask the Driver to run `git status` and confirm clean tree. The coordinator must NOT
  run git themselves.

### CSS/Frontend Frequently Omitted
- Backend-focused Drivers often skip CSS and visual design work. Remind the team
  explicitly during review to check styling, spacing, and design token compliance.

### Session Transcripts Trigger CI
- Session transcript directories (e.g., `.claude-sessions/` on Claude Code) trigger
  unnecessary CI runs. Add `paths-ignore` for session transcript directories in CI
  workflow configuration.

## Team Communication

### Direct, Written Messages With Specific Asks
- Vague instructions lead to agent confusion. Always be specific about what needs to
  happen next and who should do it.

### Reviewer Coordination Protocol
- Before writing detailed review, check if others already flagged the same issue.
  Brief "+1" for agreement. Don't re-send acknowledged reviews.

### Driver Onboarding Must Be Explicit
- New Drivers need to read: TEAM_AGREEMENTS.md, PROJECT.md, docs/glossary.md, and the
  relevant user story BEFORE writing any code.

## Documentation

### Glossary Compliance Is Critical
- New domain types must match the glossary. Without enforcement, naming drift happens
  fast (e.g., `TodoTitle` vs `ItemTitle`).

### Deferred Items Must Be Tracked Immediately
- Non-blocking a11y, design, and UX items go in a deferred items tracking file. Review
  at each retro. Never let them accumulate as surprises.

### Team Profiles Should Include Lessons
- Team member profiles (`.team/*.md`) should have a "Lessons From Previous Sessions"
  section that the agent updates as they learn. This persists hard-won knowledge.

## Architecture

### Error Message Pipeline
- Don't defer user-facing error display. If the domain produces an error message, wire
  it through to the template immediately. Computing an error string and discarding it
  is a code smell.

### Test Helpers Get Duplicated
- Shared test setup patterns (like `register_and_login`) get duplicated across test
  files. Extract shared helpers early.

### Validate at Boundary, Trust Types Inside
- Parse, don't validate. Produce typed values at the boundary that carry proof of
  validity. Never re-validate inside the system.
