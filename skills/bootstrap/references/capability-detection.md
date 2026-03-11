# Capability Detection

Detect what delegation primitives the current harness provides. This
determines which TDD execution strategy is available.

## Detection Procedure

Probe in order from most capable to least:

### 1. Subagents (Agent tool)

Check if the Agent tool (or equivalent subagent spawning) is available.
On Claude Code, this is the Agent tool. On Codex, this is `spawn_agent`.
On other harnesses, check for equivalent subprocess or worker spawning.
When `.claude/agents/` definitions exist, subagents use named personas.

**If available:** The subagents strategy works. Each TDD phase
runs in an isolated subagent with constrained scope.

### 2. Skill Chaining (Always Available)

Every harness that supports Agent Skills supports loading skill files.
This is the baseline.

**Always available:** The chaining strategy works. The agent plays each
role sequentially within a single context.

## Strategy Selection

Select the most capable strategy available:

| Detected capabilities | Strategy | TDD mode |
|----------------------|----------|----------|
| Agent tool | Subagents | Automated (with named personas if `.claude/agents/` exist) |
| Neither | Chaining | Automated (chaining) or Guided |

Both automated strategies work without user intervention. Guided
mode is always available as a user-controlled alternative regardless of
capabilities.

## Harness-Specific Probes

**Claude Code:**
- Agent tool: Check tool list for "Agent"

**Codex:**
- Subagents: Check for `spawn_agent` / `wait` / `close_agent` support or Agent tool equivalent

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

## Recording the Result

Store the detected capabilities in the configuration so downstream
skills (especially `tdd`) can read them without re-probing:

```yaml
# In .claude/sdlc.yaml or equivalent
harness:
  type: claude-code  # or codex, cursor, generic
  capabilities:
    subagents: true
    skill_chaining: true
tdd:
  mode: automated  # or guided
  strategy: subagents  # or chaining
```
