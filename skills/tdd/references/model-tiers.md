# Model Tier Reference

Default model assignments for agent roles. Structural constraints (file
restrictions, handoff schemas, phase boundaries) enforce quality regardless
of model tier — model selection optimizes cost and latency, not correctness.

## Three Tiers

| Tier | Default Model | Use Case |
|------|--------------|----------|
| Execution | haiku | Constrained, single-file tasks with clear boundaries |
| Judgment | sonnet | Multi-file reasoning, architectural review, orchestration |
| Strategy | (session model) | User's chosen model for the main orchestrator |

## Per-Role Defaults

| Role | Tier | Default | Rationale |
|------|------|---------|-----------|
| `tdd_red` (ping) | Execution | haiku | Single test file, one assertion. Haiku matches Sonnet on scoped edits at 1/3 cost. |
| `tdd_green` (pong) | Execution | haiku | Even more constrained: one error at a time, smallest change. |
| `commit` | Execution | haiku | Mechanical: stage files, format message, verify clean tree. |
| `domain_reviewer` | Judgment | sonnet | Architectural judgment: type design, domain invariants, naming precision. Multi-file reasoning edge matters. |
| `code_reviewer` | Judgment | sonnet | Three-stage review requiring spec compliance, quality, and domain integrity assessment. |
| `pipeline_controller` | Judgment | sonnet | Multi-stage orchestration with gate evaluation and rework routing. |
| `ensemble_coordinator` | Judgment | sonnet | Robert's Rules facilitation, multi-party routing, phase transitions. |
| `driver` (ensemble) | Judgment | sonnet | Creative coding with design decisions under structural constraints. |
| `reviewer` (ensemble) | Judgment | sonnet | Structured review requiring domain awareness and pattern recognition. |
| orchestrator | Strategy | (inherited) | Main session model chosen by the user. |

### Benchmark Basis

- Haiku 4.5 scores 73.3% on SWE-bench Verified, matching Sonnet 4 ([Anthropic announcement](https://www.anthropic.com/news/claude-haiku-4-5)).
- Qodo's 400-PR benchmark: Haiku won 55-58% of code review comparisons against Sonnet ([Qodo blog](https://www.qodo.ai/blog/thinking-vs-thinking-benchmarking-claude-haiku-4-5-and-sonnet-4-5-on-400-real-prs/)).
- Sonnet retains an edge on multi-file reasoning, architectural judgment, and deep debugging ([DataCamp review](https://www.datacamp.com/blog/anthropic-claude-haiku-4-5)).

### Cost Comparison

| Model | Input (per MTok) | Output (per MTok) | Relative Cost |
|-------|------------------|--------------------|---------------|
| Haiku 4.5 | $1 | $5 | 1x |
| Sonnet 4 | $3 | $15 | 3x |
| Opus 4 | $5 | $25 | 5x |

Source: [Anthropic Pricing](https://platform.claude.com/docs/en/about-claude/pricing)

## Override Configuration

Override defaults in `.claude/sdlc.yaml`:

```yaml
# Override default model tiers for agent roles.
# Values depend on harness. Claude Code: haiku, sonnet, opus.
# Codex: any model ID via config_file. Other harnesses: consult docs.
# Omit to use defaults (haiku for execution, sonnet for judgment).
model_tiers:
  tdd_red: haiku
  tdd_green: haiku
  domain_reviewer: sonnet
  commit: haiku
  pipeline_controller: sonnet
  ensemble_coordinator: sonnet
  code_reviewer: sonnet
  driver: sonnet
  reviewer: sonnet
```

### Common Override Scenarios

**Budget-conscious:** Set all roles to `haiku`. Structural enforcement
(file restrictions, handoff schemas) maintains quality. Review thoroughness
may decrease on complex multi-file changes.

**High-stakes:** Set execution tier to `sonnet`. Improves test design
quality at 3x cost. Most beneficial for complex domain logic where test
structure matters.

**Complex orchestration:** Set `pipeline_controller` to `opus`. Useful
when the pipeline manages many parallel slices or complex rework routing.

## Harness Support Matrix

### Full per-agent model support

| Harness | Mechanism | Model Values |
|---------|-----------|-------------|
| Claude Code | Agent frontmatter `model` + Task tool `model` param | `haiku`, `sonnet`, `opus`, `inherit` |
| Codex | Per-role `config_file` TOML with `model` field | Any model ID |
| Cursor | `.cursor/agents/*.md` frontmatter `model` | `fast`, `inherit`, or model ID |
| OpenCode | `opencode.json` `agent.<name>.model` | `provider/model-id` |
| GitHub Copilot | `.agent.md` frontmatter `model` (VS Code only) | String or array |
| Kiro | `.kiro/agents/*.json` `model` field | Model IDs from Bedrock |
| Gemini CLI | `.gemini/agents/*.md` frontmatter `model` (experimental) | Model IDs, default `inherit` |

### Partial per-agent model support

| Harness | Mechanism | Notes |
|---------|-----------|-------|
| Aider | `--model`, `--editor-model`, `--weak-model` | 3 functional roles, not arbitrary agents |
| Continue.dev | `config.yaml` with 6 role blocks | Roles: chat, autocomplete, edit, apply, embed, rerank |
| Goose | `GOOSE_LEAD_MODEL` / `GOOSE_MODEL` env vars | Lead/worker pattern |
| Cline | Per-mode provider + model (Plan/Act) | 2 modes with independent config |

### No per-agent model support

| Harness | Status |
|---------|--------|
| Windsurf | Session-level model dropdown; system-managed routing |
| Amp | System-managed modes (Smart/Rush/Deep); no user override |
| Roo Code | Sticky per-mode models at runtime; no declarative config |
| Amazon Q | Single global model; system-managed FM routing |
| Junie | Model at subscription/account level |

### Advisory only

Devin, generic skill-only agents, and harnesses with fully managed model
selection. Document tier recommendations in skill text; the harness
decides the actual model.

## Graceful Degradation

Model tier assignments are recommendations, not requirements. Quality
enforcement comes from structural constraints:

1. **File restrictions** — RED can only edit test files, GREEN only
   production files, DOMAIN only type definitions. These are enforced by
   agent definitions and optional hooks, not by model capability.
2. **Handoff schemas** — Every phase produces structured evidence that the
   orchestrator validates before allowing progression.
3. **Phase boundaries** — No phase is skipped. Domain review happens after
   every RED and every GREEN, regardless of model tier.
4. **Rework budgets** — Gate failures route back for rework with a hard
   cap before human escalation.

On harnesses that do not support per-agent model selection, all agents
inherit the session model. The structural constraints still apply. The
only difference is cost and latency optimization.
