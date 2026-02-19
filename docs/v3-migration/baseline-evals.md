# Baseline Enforcement Metrics (v2 -> v3 Migration)

## Current Enforcement Layers

The v2 architecture enforces TDD discipline through three distinct layers, each with different mechanical properties:

### Layer 1: Hook-Based Enforcement (Mechanical, Claude Code Only)

**Source:** `plugins/claude-code/hooks/hooks.json`

Hooks fire automatically on specific events. The agent cannot bypass them without modifying the hooks file itself.

| Hook | Event | Mechanism | What It Enforces |
|------|-------|-----------|------------------|
| Domain Review Checkpoint | `SubagentStop` | Prompt-type hook | After RED or GREEN agent completes, blocks orchestrator from proceeding unless next step is domain agent launch |
| Orchestration Reminder | `SubagentStop` | Prompt-type hook | Reminds orchestrator it must never use Edit/Write directly; provides role-selection table and TDD cycle sequence |
| Question Detection | `SubagentStop` | Prompt-type hook | Blocks agents that ask 2+ blocking questions without using AskUserQuestion tool |

### Layer 2: Agent-Level File-Type Restrictions (Mechanical, Claude Code Only)

**Source:** `plugins/claude-code/agents/red.md`, `green.md`, `domain.md`

Each agent has `PreToolUse` hooks on `Edit` and `Write` that invoke an agent-type verifier before the tool executes. These are mechanical gates -- the tool call is blocked if the verifier returns `{"ok": false}`.

| Agent | PreToolUse Gate | Allowed Files | Blocked Files |
|-------|----------------|---------------|---------------|
| **red** | Agent-type verifier on Edit/Write | Test files (`tests/`, `*_test.*`, `*.test.*`) | Production code, type definitions |
| **green** | Agent-type verifier on Edit/Write | Production implementation files (`src/`, `lib/`, `app/`) | Test files, type-only definitions |
| **domain** | Agent-type verifier on Edit/Write | Type definitions (structs, enums, traits, interfaces with stub bodies) | Test files, implementation logic |

Each agent also has `PostToolUse` hooks on `Edit` and `Write` that require the agent to run tests/type-checks and paste actual output as evidence. These are prompt-type hooks (advisory but persistent -- the agent is reminded every single time it edits a file).

### Layer 3: Skill Text (Advisory, Harness-Agnostic)

**Source:** `skills/tdd-cycle/SKILL.md`, `skills/orchestration/SKILL.md`

These are instructions loaded into agent context. They describe the rules but cannot mechanically prevent violations. Their enforcement depends on the LLM following instructions.

| Skill | What It Teaches | Key Advisory Rules |
|-------|----------------|--------------------|
| **tdd-cycle** | Five-step RED-DOMAIN-GREEN-DOMAIN-COMMIT cycle | Phase boundaries (who edits what), one-test-one-assertion, evidence-not-assumptions, commit gate before new RED |
| **orchestration** | Orchestrator coordination patterns | Never write files directly, enforce workflow gates, provide complete context, domain veto power |

Both skills contain an explicit **Enforcement Note** acknowledging that skill text alone cannot mechanically prevent violations and that hooks provide the mechanical layer.

---

## Representative TDD Enforcement Scenarios

### Scenario 1: RED phase agent edits a production file

**What should happen:** The edit is blocked before it executes.

**Current enforcement:**
- **Mechanical (hooks):** The `red.md` agent has a `PreToolUse` hook on `Edit` that invokes an agent-type verifier. The verifier checks `file_path` against test-file patterns. If the path does not match test patterns, it returns `{"ok": false, "reason": "red agent can only edit test files."}` and the Edit tool call is blocked.
- **Advisory (skill text):** `tdd-cycle/SKILL.md` Phase Boundaries table states RED can only edit test files.

**Enforcement strength:** Strong mechanical gate. The hook fires on every Edit call regardless of what the agent "intends."

**Expected gap after restructuring:** If hooks are removed and enforcement moves to skill text only, nothing mechanically prevents the RED-phase agent from editing production files. The LLM must self-enforce the boundary based on instructions in context.

---

### Scenario 2: Orchestrator skips domain review after RED

**What should happen:** The orchestrator is blocked from launching GREEN directly after RED completes.

**Current enforcement:**
- **Mechanical (hooks):** The `SubagentStop` "Domain Review Checkpoint" hook fires every time a subagent finishes. It detects which agent just completed (via file modification patterns and self-identification). If RED just completed, it returns `{"ok": false, "reason": "Domain review is MANDATORY after {agent} phase."}` blocking the orchestrator from proceeding without launching domain.
- **Advisory (skill text):** `orchestration/SKILL.md` "Enforce Workflow Gates" section lists TDD cycle gates: RED complete -> Domain review of test -> GREEN.

**Enforcement strength:** Strong mechanical gate at the orchestrator level. Even if the orchestrator "decides" to skip domain review, the hook blocks it.

**Expected gap after restructuring:** Without the SubagentStop hook, the orchestrator relies entirely on skill instructions to remember the mandatory domain review step. Skipping it becomes possible if the LLM deprioritizes the instruction under context pressure.

---

### Scenario 3: GREEN phase agent edits a test file

**What should happen:** The edit is blocked before it executes.

**Current enforcement:**
- **Mechanical (hooks):** The `green.md` agent has a `PreToolUse` hook on `Edit` that invokes an agent-type verifier. The verifier checks `file_path` and blocks paths containing `tests/`, `__tests__/`, `spec/`, `test/` or matching test-file naming patterns.
- **Advisory (skill text):** `tdd-cycle/SKILL.md` Phase Boundaries table states GREEN cannot edit test files.

**Enforcement strength:** Strong mechanical gate, symmetric with Scenario 1.

**Expected gap after restructuring:** Same as Scenario 1 -- without hooks, enforcement depends on LLM instruction-following. GREEN editing tests is a common drift pattern because "fixing a test to match implementation" feels natural to an LLM.

---

### Scenario 4: Evidence (test output) required before phase transitions

**What should happen:** After every Edit or Write, the agent must run tests and paste actual output.

**Current enforcement:**
- **Mechanical (hooks):** Each agent (red, green, domain) has `PostToolUse` hooks on `Edit` and `Write`. These are prompt-type hooks that fire after every edit/write and instruct the agent to run tests and paste output. They explicitly call out anti-patterns: "I expect it to fail" is not evidence, "Tests should pass now" is not evidence.
- **Advisory (skill text):** `tdd-cycle/SKILL.md` "Evidence, Not Assumptions" section: "Always run the test. Always paste the output."

**Enforcement strength:** Medium. PostToolUse prompt hooks are reminders, not blockers -- they cannot prevent the agent from proceeding without evidence. But they fire on every single edit, making it hard for the agent to forget. This is stronger than pure skill text because the reminder is event-driven rather than relying on the LLM recalling a rule from earlier context.

**Expected gap after restructuring:** Without PostToolUse hooks, evidence requirements become purely advisory. The agent may "know" it should run tests but skip it under time pressure or when context is long. The event-driven reminder disappears.

---

### Scenario 5: New RED phase begins without a prior commit

**What should happen:** The orchestrator blocks the next RED phase until a git commit exists for the completed cycle.

**Current enforcement:**
- **Advisory (skill text):** `tdd-cycle/SKILL.md` COMMIT step: "Committing is MANDATORY after every completed green-domain cycle. This is a hard gate: no new RED phase may begin until this commit is made." The Verification section marks COMMIT as a "HARD GATE" with explicit checklist items.
- **Partial mechanical (hooks):** The SubagentStop "Orchestration Reminder" hook includes the TDD cycle sequence (After DOMAIN post-green -> Next test or refactor), which implicitly requires the commit step. However, there is NO explicit hook that checks for git commit existence before allowing a new RED agent to launch.

**Enforcement strength:** Weak to medium. The commit gate is the least mechanically enforced of all TDD rules. It depends on the orchestrator following the skill text's "HARD GATE" instruction. The SubagentStop hook reminds about cycle order but does not verify commit existence.

**Expected gap after restructuring:** This scenario already has a gap in v2. In v3 (skills-only), it remains advisory. If the project wants stronger enforcement, this is a candidate for a new mechanism -- possibly a shell-type hook that checks `git log` before allowing RED agent activation.

---

## Summary: Enforcement Mechanism Inventory

| Mechanism | Type | Harness-Specific? | Survives Skills-Only Migration? |
|-----------|------|--------------------|---------------------------------|
| PreToolUse agent-type verifiers (red, green, domain) | Mechanical blocker | Claude Code only | NO -- requires hooks |
| PostToolUse evidence reminders (red, green, domain) | Mechanical reminder | Claude Code only | NO -- requires hooks |
| SubagentStop domain review checkpoint | Mechanical blocker | Claude Code only | NO -- requires hooks |
| SubagentStop orchestration reminder | Mechanical reminder | Claude Code only | NO -- requires hooks |
| SubagentStop question detection | Mechanical blocker | Claude Code only | NO -- requires hooks |
| tdd-cycle/SKILL.md phase boundaries | Advisory text | Harness-agnostic | YES |
| tdd-cycle/SKILL.md commit gate | Advisory text | Harness-agnostic | YES |
| orchestration/SKILL.md workflow gates | Advisory text | Harness-agnostic | YES |
| orchestration/SKILL.md "never write files" | Advisory text | Harness-agnostic | YES |

## Expected Gaps After Restructuring

1. **File-type boundaries become advisory.** The strongest current enforcement (PreToolUse blockers on red/green/domain agents) has no skill-text equivalent that can mechanically prevent violations. The new skill must compensate with extremely clear, prominent instructions and ideally suggest hook configurations for harnesses that support them.

2. **Domain review sequencing becomes advisory.** The SubagentStop checkpoint that forces domain review after RED and GREEN disappears. The orchestration skill must encode this sequence prominently enough that LLMs follow it consistently.

3. **Evidence reminders lose event-driven triggering.** PostToolUse hooks fire on every edit. Skill text can say "always run tests" but cannot trigger a reminder at the exact moment the agent finishes an edit. This is a qualitative downgrade in enforcement fidelity.

4. **Commit gate remains weak.** Already the weakest enforcement point in v2, it does not get worse in v3 but also does not get better. Consider whether v3 should introduce a recommended hook configuration for this.

5. **Harness-specific enforcement becomes optional configuration.** The new skill architecture should include a reference file documenting recommended hook configurations for Claude Code (and other harnesses) so that projects CAN opt into mechanical enforcement. The skill text is the floor; hooks are the ceiling.
