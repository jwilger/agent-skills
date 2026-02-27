# Capability Detection

Detect what delegation primitives the current harness provides. This
determines which TDD execution strategy is available.

## Detection Procedure

Probe in order from most capable to least:

### 1. Agent Teams (TeamCreate)

Check if the TeamCreate tool is available. On Claude Code, this is a
built-in tool. On other harnesses, check for equivalent multi-agent
session management.

**If available:** The agent teams strategy works. Ping-pong TDD pairing
is possible. This is the most capable mode.

### 2. Subagents (Task tool)

Check if the Task tool (or equivalent subagent spawning) is available.
On Claude Code, this is the Task tool. On Codex, this is `spawn_agent`.
On other harnesses, check for equivalent subprocess or worker spawning.

**If available:** The serial subagents strategy works. Each TDD phase
runs in an isolated subagent with constrained scope.

### 3. Skill Chaining (Always Available)

Every harness that supports Agent Skills supports loading skill files.
This is the baseline.

**Always available:** The chaining strategy works. The agent plays each
role sequentially within a single context.

## Strategy Selection

Select the most capable strategy available:

| Detected capabilities | Strategy | TDD mode |
|----------------------|----------|----------|
| TeamCreate + Task | Agent teams | Automated (ping-pong) |
| Task only | Serial subagents | Automated (serial) |
| Neither | Chaining | Automated (chaining) or Guided |

All three automated strategies work without user intervention. Guided
mode is always available as a user-controlled alternative regardless of
capabilities.

## Harness-Specific Probes

**Claude Code:**
- Task tool: Check tool list for "Task"
- TeamCreate: Check tool list for "TeamCreate"
- SendMessage: Check tool list for "SendMessage"

**Codex:**
- Subagents: Check for `spawn_agent` / `wait` / `close_agent` support
- No persistent teams: Codex recreates agents per invocation

**Cursor / Windsurf:**
- No delegation primitives. Use chaining or guided mode.

**Generic:**
- Assume chaining only unless the harness documents otherwise.

## CI/CD Detection

Detect presence of CI/CD configuration to inform skill recommendations:

| File or directory | CI system |
|-------------------|-----------|
| `.github/workflows/` | GitHub Actions |
| `.gitlab-ci.yml` | GitLab CI |
| `Jenkinsfile` | Jenkins |
| `.circleci/config.yml` | CircleCI |
| `bitbucket-pipelines.yml` | Bitbucket Pipelines |
| `.travis.yml` | Travis CI |
| Any `ci` or `pipeline` directory/file pattern | Generic CI |

**Implications:**
- When CI is detected, recommend the `ci-integration` skill
- When CI is detected AND team workflow is selected, recommend the full factory pipeline skill set (`pipeline`, `ci-integration`, `factory-review`)

### 4. Per-Agent Model Selection

Detect whether the harness supports assigning different models to
different agent roles.

| Harness | Support | Mechanism |
|---------|---------|-----------|
| Claude Code | Yes | Agent frontmatter `model` + Task tool `model` param |
| Codex | Yes | Per-role `config_file` TOML |
| Cursor | Yes | `.cursor/agents/*.md` frontmatter `model` |
| OpenCode | Yes | `opencode.json` `agent.<name>.model` |
| GitHub Copilot | Yes (VS Code only) | `.agent.md` frontmatter `model` |
| Kiro | Yes | `.kiro/agents/*.json` `model` field |
| Gemini CLI | Yes (experimental) | `.gemini/agents/*.md` frontmatter `model` |
| Aider | Partial | `--model`, `--editor-model`, `--weak-model` (3 roles) |
| Continue.dev | Partial | `config.yaml` role blocks (6 roles) |
| Goose | Partial | `GOOSE_LEAD_MODEL` / `GOOSE_MODEL` env vars |
| Cline | Partial | Per-mode provider + model (Plan/Act) |
| Windsurf | No | Session-level model dropdown |
| Amp | No | System-managed modes |
| Roo Code | No | Sticky per-mode at runtime, no declarative config |
| Amazon Q | No | Single global model |
| Junie | No | Model at subscription/account level |

Record as `model_selection: true`, `partial`, or `false` in capabilities.

When model selection is available, the TDD skill uses model tier defaults
(haiku for execution roles, sonnet for judgment roles) unless overridden
in `.claude/sdlc.yaml`. When unavailable, all agents inherit the session
model. See `tdd/references/model-tiers.md` for details.

## Recording the Result

Store the detected capabilities in the configuration so downstream
skills (especially `tdd`) can read them without re-probing:

```yaml
# In .claude/sdlc.yaml or equivalent
harness:
  type: claude-code  # or codex, cursor, generic
  capabilities:
    subagents: true
    agent_teams: true
    skill_chaining: true
    model_selection: true  # true, partial, or false
tdd:
  mode: automated  # or guided
  strategy: agent-teams  # or serial-subagents, chaining
```
