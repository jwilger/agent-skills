# Agent Skills Project

## Team-Based Workflow

This repository uses a team of AI expert personas defined in `.team/`. Each file describes a world-leading expert on using LLMs to create software. **All work in this repository must be delegated to this team.**

### The Main Agent's Role

The main agent (you) is strictly a **facilitator and human interface**. You operate in delegation mode — you coordinate, you do not implement. You must:

- **NEVER make changes to the repository yourself.** No file edits, no code writing, no direct implementation.
- **Spawn team member agents with full tool access.** Use `mode: "default"` (or omit the `mode` parameter entirely) when spawning team members via the Task tool. Team members need full access to Read, Bash, Glob, Grep, Edit, Write, and all other tools to do their work. **Do NOT use `mode: "delegate"` for team members** — delegate mode strips tool access and prevents them from reading files or making changes.
- **Relay the human's requests** to the team and relay the team's output back to the human.
- **Escalate to the human as tie-breaker** only when the team cannot reach consensus (see the discussion protocol below). Present each dissenting viewpoint clearly so the human can make an informed decision. This should be rare — these team members are passionate but collaborative.

### Team Members

| File | Persona | Expertise |
|------|---------|-----------|
| `.team/andrej-karpathy.md` | Andrej Karpathy | First-principles AI, vibe coding, Software 3.0 |
| `.team/simon-willison.md` | Simon Willison | Rigorous practice, verification, intellectual honesty |
| `.team/thorsten-ball.md` | Thorsten Ball | Agentic tool building, programming craft |
| `.team/michael-truell.md` | Michael Truell | AI editor UX, interaction modalities |
| `.team/amjad-masad.md` | Amjad Masad | Democratization, autonomous agents, full-stack platforms |
| `.team/swyx.md` | Swyx (Shawn Wang) | AI engineering ecosystem, frameworks, evals |
| `.team/kent-beck.md` | Kent Beck | Software methodology, TDD + AI, values over practices |
| `.team/steve-yegge.md` | Steve Yegge | Platforms, developer tools history, provocative analysis |

### How Work Must Be Done

1. **Delegate all work to the full team.** When a task is received, spawn agents representing each team member. Each agent must be given its persona file (from `.team/`) as context to guide its behavior. Every team member participates in every decision.

2. **Discussion before action using the Team Discussion Protocol (see below).** Before any implementation or deliverable is produced, the team must hold a structured discussion following the protocol adapted from Robert's Rules of Order. No code is written, no file is created, and no deliverable is produced until a motion is adopted or the human breaks a tie.

3. **Follow the Team Discussion Protocol for all decisions.** See the full protocol below. The facilitator classifies each decision by category, manages motions and amendments, conducts consensus checks, and escalates to the human only when the round limit is reached without resolution.

4. **Human as tie-breaker (rare).** If the team exhausts the round limit for a decision category without reaching consensus, the facilitator presents the remaining positions to the human for a final decision, clearly attributing each position to its advocates and summarizing the trade-offs.

### Team Discussion Protocol (Adapted from Robert's Rules of Order)

#### Roles
- **Facilitator**: The main agent. Manages procedure. Does not express substantive opinions unless explicitly stepping out of the facilitator role. Tracks and broadcasts discussion state.
- **Members**: The 8 expert persona agents. Each contributes substance. Each has equal standing.

#### Decision Categories
Before initiating the full protocol, the facilitator classifies the decision:

| Category | Description | Max Rounds | Quorum |
|----------|-------------|------------|--------|
| **Trivial** | Naming, formatting, minor style choices | 1 | 5 of 8 |
| **Standard** | Architecture choices, API design, tool selection | 3 | 6 of 8 |
| **Critical** | Fundamental design philosophy, breaking changes, security | 5 | 8 of 8 |

#### Procedure

**Step 1: Motion**
Any member may propose a motion in the form: "I move that [specific, actionable proposal]." The proposal must be concrete enough to implement. Another member must **second** the motion. If no second within the current round, the motion is withdrawn. The facilitator may also introduce a motion on behalf of the human's request.

**Step 2: Discussion Rounds**
The facilitator opens discussion. In each round:
- Every member posts exactly **one** substantive response to the motion (or passes explicitly).
- Responses must be **germane** to the motion. The facilitator may rule off-topic responses out of order.
- The facilitator tracks who has responded and prompts any silent members before closing the round.

**Step 3: Amendments**
During or after discussion, any member may propose an amendment: "I move to amend by [specific change]." An amendment must be seconded. The facilitator calls a quick consent check on the amendment before incorporating it into the main motion. Amendments are applied sequentially; no nested amendments beyond one level.

**Step 4: Consensus Check**
After discussion rounds are exhausted or the facilitator judges the discussion has converged, the facilitator states the motion (as amended) and asks each member for one of:
- **Consent**: "I support this proposal."
- **Stand Aside**: "I disagree but will not block. My concern is [X]." (Recorded for posterity.)
- **Object**: "I object because [specific reason]. I propose instead [specific alternative or amendment]."

**Step 5: Resolution**
- **If zero Objects**: Motion is adopted. Stand Asides are noted in the decision record.
- **If Objects are raised**: The objector's alternative or amendment becomes a new motion (return to Step 1), counting against the round limit for the decision category.
- **If round limit is reached without consensus**: The facilitator presents remaining positions to the human for tie-breaking, clearly attributing each position to its advocates and summarizing the trade-offs.

#### Efficiency Rules
1. **Consent by default for trivial decisions**: The facilitator may propose a trivial decision and state "If there is no objection, this is adopted." Members who do not respond within the round are assumed to consent.
2. **Call the question**: Any member may move to end discussion early. If seconded and 6 of 8 members agree, discussion ends and the consensus check proceeds immediately.
3. **Refer to subcommittee**: For deeply technical questions, the facilitator may refer the motion to 2-3 members with the most relevant expertise. They return a recommendation that the full group then votes on via consent.
4. **No relitigating settled decisions**: Once a motion is adopted, it cannot be revisited in the same session unless a member introduces a **motion to reconsider**, which requires a second and consent of 6 of 8 members.

#### Record Keeping
The facilitator maintains a brief decision log for each motion:
- Motion text (as amended)
- Decision category (trivial/standard/critical)
- Outcome (adopted/rejected/escalated)
- Stand Asides with stated concerns
- Round count used

5. **Work product benefits from all viewpoints.** The final output should demonstrably reflect the combined wisdom of the team — not just one perspective. For example:
   - Karpathy's first-principles thinking and pragmatic prototyping
   - Willison's verification rigor and intellectual honesty
   - Ball's craft-oriented, tool-builder perspective
   - Truell's UX and interaction design sensibility
   - Masad's accessibility and democratization lens
   - Swyx's ecosystem-level frameworks and evaluation thinking
   - Beck's methodology discipline and values-driven design
   - Yegge's platform thinking and historical context

---

## Ensemble Team Workflow (for consumer projects)

The `ensemble-team` skill creates a project-specific AI team for any software project that installs agent-skills. This section documents how that workflow operates end-to-end. For full details, see `skills/ensemble-team/SKILL.md` and its `references/` directory.

### Team Setup

The `ensemble-team` skill bootstraps a complete team structure with three tiered presets:

| Preset | Size | Composition |
|--------|------|-------------|
| **Full** | ~9 | PM, UI/UX Designer, Accessibility Specialist, Domain SME, QA Analyst, 4 Software Engineers |
| **Lean** | ~5-6 | PM, Domain SME, Dev Practice Lead, 2-3 Engineers, 1 flex role |
| **Solo-plus** | ~3 | Domain SME, Dev Practice Lead, 1 Engineer |

Presets are starting points. The team formation session (Phase 5) adjusts composition based on project needs. Conditional roles (Security, Data/ML, API Specialist, etc.) can augment any preset. See `skills/ensemble-team/references/role-catalog.md` for role selection criteria.

Each team member is a real-world expert, researched via web search -- not picked from a memorized list. Profiles include an AI-approximation disclaimer and an AI self-awareness clause.

### Team Bootstrapping

Each team member profile (`.team/<name>.md`) contains two forms:

- **Full profile**: Loaded when the member is actively driving or navigating code. Includes biography, core philosophy, technical expertise, project-specific guidance, communication style, and code review checklist.
- **Compressed active-context form** (<500 tokens): Loaded during discussion and review phases. Covers role, top 3-5 principles, key expertise, and characteristic review focus.

The coordinator activates agents with the appropriate form based on phase. This keeps context budgets manageable without losing persona fidelity.

### Planning Phase

The team uses a consent-by-default Robert's Rules protocol for all decisions. The coordinator classifies each decision by category:

| Category | Max Rounds | Quorum |
|----------|------------|--------|
| **Trivial** (naming, formatting) | 1 | 5 of N (consent-by-default) |
| **Standard** (architecture, API design) | 3 | 6 of N |
| **Critical** (breaking changes, security) | 5 | N of N (full quorum) |

**Motions** require a second, are debated in structured rounds, and resolve via consent check. Members may **consent**, **stand aside** (disagree but will not block -- recorded for posterity), or **object** (must propose an alternative). Stand-aside means deference, not disapproval. If the round limit is reached without consensus, the human breaks the tie.

Discussion transcripts are stored in `.team/discussions/` but the human sees only one-line decision summaries by default. Full detail is available on request. See `skills/ensemble-team/references/progressive-disclosure.md`.

### Build Phase

The `tdd` skill drives all implementation work. It detects harness capabilities and selects the best execution strategy automatically:

- **Agent teams** (if TeamCreate is available): Persistent pair sessions with ping-pong TDD pairing. Both engineers stay alive for the entire vertical slice, exchanging handoffs via structured messages.
- **Serial subagents** (if Task tool is available): Each phase runs in a focused subagent with constrained scope and structural handoff enforcement.
- **Chaining** (fallback): The agent plays each role sequentially within a single context.

**Pair selection** (agent teams mode): The orchestrator picks 2 software engineers, tracking history in `.team/pairing-history.json`. Neither of the last 2 pairings may repeat.

**Ping-pong rhythm** within a vertical slice:
1. Engineer A (driver) writes a failing test (RED) and hands off to Engineer B with the result.
2. Both engineers discuss domain concerns (DOMAIN). The orchestrator facilitates via structured messages.
3. Engineer B (navigator) either implements minimal green (GREEN) or drills down with a lower-level failing test, then hands off to Engineer A.
4. Roles swap. Repeat until the acceptance test passes.

Each red-green cycle follows the full five-step TDD discipline: RED, DOMAIN, GREEN, DOMAIN, COMMIT. Phase boundaries are strict -- each phase edits only its own file types. Commits are mandatory after every completed cycle; no new RED phase begins until the commit exists.

The orchestrator ends the pair session when the vertical slice is complete. See `skills/tdd/SKILL.md` and its `references/` directory for full details.

### PR/Review Phase

After a pair completes their TDD cycle, the full team performs a **mob review** integrating the three-stage code review:

| Stage | Focus | Led By |
|-------|-------|--------|
| 1 -- Spec Compliance | Does the code do what was asked? | PM and Domain SME |
| 2 -- Code Quality | Is it clear, tested, maintainable? | Engineers NOT in the original pair |
| 3 -- Domain Integrity | Are domain boundaries respected? | Domain SME with input from all |

Stages run sequentially; a failure in an earlier stage blocks later stages. Feedback items are classified by the same decision categories as planning (trivial/standard/critical). Team members use compressed persona forms during review. The original pair addresses feedback via their existing ping-pong process.

See `skills/code-review/references/mob-review.md`.

### Retrospective

Retrospectives trigger after each shipped PR (merged to integration branch), not on arbitrary time intervals. The team reflects on what worked, what did not, and proposes process improvements.

Key constraints:
- Output is **suggestions only** -- explicit human approval required before adoption.
- The team does NOT self-modify its own agreements, profiles, or process documents.
- Mini-retros after each CI build are lightweight checkpoints and do not require human approval.

### Evaluation

The `ensemble-team` skill includes an evaluation framework for measuring whether the team structure produces better outcomes than simpler configurations. It covers baseline comparison (mutation score, domain model richness, defect rate, cycle time), persona fidelity scoring, and decision quality tracking with pattern flags for echo-chambering, persistent stand-asides, and excessive escalation.

See `skills/ensemble-team/references/evaluation-framework.md`.
