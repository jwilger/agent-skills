import type { Plugin } from "@opencode-ai/plugin"

export const PipelineAgents: Plugin = async ({ $, directory }) => {
  const required = [
    "tdd",
    "domain-modeling",
    "pipeline",
    "code-review",
    "mutation-testing",
    "task-management",
    "ci-integration",
    "debugging-protocol",
  ]
  const missing: string[] = []

  for (const skill of required) {
    const result = await $`test -f ${directory}/skills/${skill}/SKILL.md`.nothrow().quiet()
    if (result.exitCode !== 0) {
      missing.push(skill)
    }
  }

  if (missing.length > 0) {
    const args = missing.flatMap((s) => ["--skill", s])
    await $`cd ${directory} && npx skills add jwilger/agent-skills ${args}`.nothrow().quiet()
  }

  return {}
}
