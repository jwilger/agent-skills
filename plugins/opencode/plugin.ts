import type { Plugin } from "@opencode-ai/plugin"
import { tool } from "@opencode-ai/plugin"

// ---------------------------------------------------------------------------
// SDLC Enforcement Plugin for OpenCode
//
// This plugin adds mechanical enforcement for Agent Skills that are otherwise
// advisory-only. Skills teach the methodology; this plugin enforces it.
//
// Enforcement behaviors:
//   1. TDD phase boundary enforcement (tool.execute.before)
//   2. Domain review gate after RED and GREEN phases (tool.execute.after + stop)
//   3. Code review reminder before session end (stop)
//   4. Memory protocol reminders on session idle (event)
//   5. System prompt injection with active skill context (experimental)
//   6. Custom tools for phase management and review triggers
// ---------------------------------------------------------------------------

// --- Session state tracking -------------------------------------------------

type TddPhase = "none" | "red" | "domain-after-red" | "green" | "domain-after-green"

interface SessionState {
  tddPhase: TddPhase
  filesModified: string[]
  testFilesModified: string[]
  productionFilesModified: string[]
  domainReviewPending: boolean
  lastTestRun: string | null
  commitsSinceReview: number
}

const sessions = new Map<string, SessionState>()

function getState(sessionId: string): SessionState {
  let state = sessions.get(sessionId)
  if (!state) {
    state = {
      tddPhase: "none",
      filesModified: [],
      testFilesModified: [],
      productionFilesModified: [],
      domainReviewPending: false,
      lastTestRun: null,
      commitsSinceReview: 0,
    }
    sessions.set(sessionId, state)
  }
  return state
}

// --- File classification ----------------------------------------------------

const TEST_PATTERNS = [
  /[_.]test\.[jt]sx?$/,
  /[_.]spec\.[jt]sx?$/,
  /_test\.go$/,
  /_test\.rs$/,
  /test_[^/]+\.py$/,
  /[_.]test\.exs?$/,
  /\/tests?\//,
  /\/spec\//,
  /\/__tests__\//,
]

const TYPE_DEFINITION_PATTERNS = [
  /\/types\.[jt]sx?$/,
  /\/types\//,
  /\/domain\//,
  /\/models\//,
  /\.d\.ts$/,
  /\/interfaces\//,
]

function isTestFile(path: string): boolean {
  return TEST_PATTERNS.some((p) => p.test(path))
}

function isTypeDefinitionFile(path: string): boolean {
  return TYPE_DEFINITION_PATTERNS.some((p) => p.test(path))
}

function isProductionFile(path: string): boolean {
  return !isTestFile(path) && !isTypeDefinitionFile(path)
}

// --- Phase boundary rules ---------------------------------------------------

interface BoundaryCheck {
  allowed: boolean
  reason: string
}

function checkPhaseBoundary(
  phase: TddPhase,
  filePath: string
): BoundaryCheck {
  switch (phase) {
    case "red":
      if (isTestFile(filePath)) {
        return { allowed: true, reason: "" }
      }
      return {
        allowed: false,
        reason: `TDD RED phase: only test files can be edited. "${filePath}" is not a test file. Complete the RED phase before editing production code.`,
      }

    case "domain-after-red":
    case "domain-after-green":
      if (isTypeDefinitionFile(filePath)) {
        return { allowed: true, reason: "" }
      }
      return {
        allowed: false,
        reason: `TDD DOMAIN phase: only type definition files can be edited. "${filePath}" is not a type definition file. Complete domain review before editing other files.`,
      }

    case "green":
      if (isTestFile(filePath)) {
        return {
          allowed: false,
          reason: `TDD GREEN phase: test files cannot be edited. "${filePath}" is a test file. Only production code can be edited during GREEN.`,
        }
      }
      return { allowed: true, reason: "" }

    case "none":
      return { allowed: true, reason: "" }

    default:
      return { allowed: true, reason: "" }
  }
}

// --- Plugin export ----------------------------------------------------------

export const SdlcEnforcement: Plugin = async ({ client, $, directory }) => {
  return {
    // ----- Event handling ---------------------------------------------------
    event: async ({ event }) => {
      const sessionId = (event as any).properties?.sessionID
        ?? (event as any).session_id
        ?? (event as any).sessionId

      if (!sessionId) return

      switch (event.type) {
        case "session.created":
          sessions.set(sessionId, {
            tddPhase: "none",
            filesModified: [],
            testFilesModified: [],
            productionFilesModified: [],
            domainReviewPending: false,
            lastTestRun: null,
            commitsSinceReview: 0,
          })
          break

        case "session.deleted":
          sessions.delete(sessionId)
          break

        case "session.idle": {
          const state = getState(sessionId)
          const reminders: string[] = []

          if (state.domainReviewPending) {
            reminders.push(
              "Domain review is pending. Run the `sdlc_domain_review` tool before continuing."
            )
          }

          if (state.filesModified.length > 5 && state.commitsSinceReview === 0) {
            reminders.push(
              "Multiple files modified without a code review. Consider running `sdlc_code_review` before continuing."
            )
          }

          if (reminders.length > 0) {
            await client.session.prompt({
              path: { id: sessionId },
              body: {
                parts: [{
                  type: "text",
                  text: `<sdlc-reminder>\n${reminders.join("\n")}\n</sdlc-reminder>`,
                }],
              },
            })
          }
          break
        }
      }
    },

    // ----- Pre-execution enforcement ----------------------------------------
    "tool.execute.before": async (input, output) => {
      const sessionId = (input as any).sessionID
        ?? (input as any).session_id
      if (!sessionId) return

      const state = getState(sessionId)

      // Only enforce during active TDD phases
      if (state.tddPhase === "none") return

      // Enforce file edit boundaries
      if (input.tool === "edit" || input.tool === "write") {
        const filePath = (input.args as any)?.file_path
          ?? (input.args as any)?.filePath
          ?? (input.args as any)?.path

        if (!filePath || typeof filePath !== "string") return

        const check = checkPhaseBoundary(state.tddPhase, filePath)
        if (!check.allowed) {
          // Block the edit and explain why
          ;(output as any).abort = check.reason
          return
        }
      }

      // Enforce domain review gate: block GREEN if domain review not done
      if (
        state.tddPhase === "red" &&
        state.domainReviewPending &&
        (input.tool === "edit" || input.tool === "write")
      ) {
        const filePath = (input.args as any)?.file_path
          ?? (input.args as any)?.filePath

        if (filePath && isProductionFile(filePath)) {
          ;(output as any).abort =
            "Domain review required after RED phase before starting GREEN. " +
            "Run the `sdlc_domain_review` tool first."
        }
      }
    },

    // ----- Post-execution tracking ------------------------------------------
    "tool.execute.after": async (input) => {
      const sessionId = (input as any).sessionID
        ?? (input as any).session_id
      if (!sessionId) return

      const state = getState(sessionId)

      // Track file modifications
      if (input.tool === "edit" || input.tool === "write") {
        const filePath = (input.args as any)?.file_path
          ?? (input.args as any)?.filePath
          ?? (input.args as any)?.path

        if (filePath && typeof filePath === "string") {
          if (!state.filesModified.includes(filePath)) {
            state.filesModified.push(filePath)
          }
          if (isTestFile(filePath)) {
            if (!state.testFilesModified.includes(filePath)) {
              state.testFilesModified.push(filePath)
            }
          } else {
            if (!state.productionFilesModified.includes(filePath)) {
              state.productionFilesModified.push(filePath)
            }
          }
        }
      }

      // Track test runs
      if (input.tool === "bash") {
        const cmd = (input.args as any)?.command ?? ""
        const testRunPatterns = [
          /cargo\s+test/,
          /npm\s+test/,
          /npx\s+(vitest|jest)/,
          /pytest/,
          /go\s+test/,
          /mix\s+test/,
          /rspec/,
        ]
        if (testRunPatterns.some((p) => p.test(cmd))) {
          state.lastTestRun = new Date().toISOString()
        }

        // Track git commits
        if (/git\s+commit/.test(cmd)) {
          state.commitsSinceReview++
        }
      }
    },

    // ----- Stop hook: enforce review before ending --------------------------
    stop: async (input) => {
      const sessionId = (input as any).sessionID
        ?? (input as any).session_id
      if (!sessionId) return

      const state = getState(sessionId)

      if (state.domainReviewPending) {
        await client.session.prompt({
          path: { id: sessionId },
          body: {
            parts: [{
              type: "text",
              text:
                "Domain review is still pending. Complete the domain review " +
                "before ending this session. Use `sdlc_domain_review` to proceed.",
            }],
          },
        })
      }
    },

    // ----- System prompt injection ------------------------------------------
    "experimental.chat.system.transform": async (_input, output) => {
      const skillContext = [
        "<sdlc-skills>",
        "This project uses the SDLC Agent Skills workflow.",
        "Active enforcement: TDD phase boundaries, domain review gates.",
        "",
        "Available SDLC tools:",
        "- sdlc_set_phase: Set the current TDD phase (red/domain-after-red/green/domain-after-green/none)",
        "- sdlc_domain_review: Trigger domain review checkpoint",
        "- sdlc_code_review: Trigger three-stage code review",
        "- sdlc_status: Show current TDD phase and session state",
        "",
        "Phase boundary enforcement is active. File edits will be blocked",
        "if they violate the current TDD phase boundaries.",
        "</sdlc-skills>",
      ].join("\n")

      ;(output as any).system.push(skillContext)
    },

    // ----- Session compaction: preserve SDLC state --------------------------
    "experimental.session.compacting": async (input, output) => {
      const sessionId = (input as any).sessionID
        ?? (input as any).session_id
      if (!sessionId) return

      const state = sessions.get(sessionId)
      if (!state) return

      const preserved = [
        "<sdlc-preserved-state>",
        `TDD Phase: ${state.tddPhase}`,
        `Domain Review Pending: ${state.domainReviewPending}`,
        `Test Files Modified: ${state.testFilesModified.join(", ") || "none"}`,
        `Production Files Modified: ${state.productionFilesModified.join(", ") || "none"}`,
        `Last Test Run: ${state.lastTestRun || "never"}`,
        `Commits Since Review: ${state.commitsSinceReview}`,
        "</sdlc-preserved-state>",
      ].join("\n")

      ;(output as any).context.push(preserved)
    },

    // ----- Custom tools -----------------------------------------------------
    tool: {
      sdlc_set_phase: tool({
        description:
          "Set the current TDD phase. Use this when transitioning between " +
          "RED, DOMAIN, GREEN phases. Phase boundaries will be enforced: " +
          "RED allows only test files, DOMAIN allows only type definitions, " +
          "GREEN allows only production code. Set to 'none' to disable enforcement.",
        args: {
          phase: tool.schema.enum([
            "red",
            "domain-after-red",
            "green",
            "domain-after-green",
            "none",
          ]),
        },
        async execute(args, ctx) {
          const sessionId = (ctx as any).sessionID
            ?? (ctx as any).session_id
            ?? "default"
          const state = getState(sessionId)
          const previousPhase = state.tddPhase
          state.tddPhase = args.phase as TddPhase

          // Set domain review pending when entering RED or GREEN
          if (args.phase === "red" || args.phase === "green") {
            state.domainReviewPending = true
          }

          // Clear pending review when entering DOMAIN phase
          if (
            args.phase === "domain-after-red" ||
            args.phase === "domain-after-green"
          ) {
            state.domainReviewPending = false
          }

          // Reset tracking on new cycle
          if (args.phase === "red" && previousPhase !== "red") {
            state.testFilesModified = []
            state.productionFilesModified = []
            state.lastTestRun = null
          }

          const phaseDescriptions: Record<TddPhase, string> = {
            red: "RED -- Write one failing test. Only test files can be edited.",
            "domain-after-red":
              "DOMAIN (after red) -- Review test for domain violations. Only type definitions can be edited.",
            green:
              "GREEN -- Implement minimally to pass the test. Only production files can be edited.",
            "domain-after-green":
              "DOMAIN (after green) -- Review implementation for domain violations. Only type definitions can be edited.",
            none: "No active TDD phase. File boundaries not enforced.",
          }

          return `Phase changed: ${previousPhase} -> ${args.phase}\n${phaseDescriptions[args.phase as TddPhase]}`
        },
      }),

      sdlc_domain_review: tool({
        description:
          "Trigger a domain review checkpoint. Use after RED phase (review " +
          "test for primitive obsession) or after GREEN phase (review " +
          "implementation for domain violations). This clears the domain " +
          "review gate and allows the next phase to proceed.",
        args: {
          findings: tool.schema.string().describe(
            "Summary of domain review findings. State APPROVED if no " +
            "violations, or describe violations found."
          ),
          approved: tool.schema.boolean().describe(
            "Whether the domain review passes. If false, the current " +
            "phase must be revised before proceeding."
          ),
        },
        async execute(args, ctx) {
          const sessionId = (ctx as any).sessionID
            ?? (ctx as any).session_id
            ?? "default"
          const state = getState(sessionId)

          state.domainReviewPending = false

          if (args.approved) {
            // Advance to next phase
            if (state.tddPhase === "domain-after-red") {
              state.tddPhase = "green"
              return (
                `Domain review APPROVED after RED.\n${args.findings}\n` +
                "Phase advanced to GREEN. Implement minimally to pass the test."
              )
            }
            if (state.tddPhase === "domain-after-green") {
              state.tddPhase = "none"
              return (
                `Domain review APPROVED after GREEN.\n${args.findings}\n` +
                "TDD cycle complete. Commit, then start the next test or tidy."
              )
            }
            return `Domain review recorded.\n${args.findings}`
          } else {
            return (
              `Domain review REJECTED.\n${args.findings}\n` +
              "Revise the current phase to address domain violations before proceeding."
            )
          }
        },
      }),

      sdlc_code_review: tool({
        description:
          "Trigger a three-stage code review (spec compliance, code quality, " +
          "domain integrity). Use before creating PRs or after completing a " +
          "feature. Returns a structured review template.",
        args: {
          base: tool.schema
            .string()
            .optional()
            .describe("Git base ref for diff (default: main)"),
        },
        async execute(args, ctx) {
          const sessionId = (ctx as any).sessionID
            ?? (ctx as any).session_id
            ?? "default"
          const state = getState(sessionId)
          const base = args.base ?? "main"

          state.commitsSinceReview = 0

          return [
            "THREE-STAGE CODE REVIEW",
            "=======================",
            "",
            `Base: ${base}`,
            `Files modified this session: ${state.filesModified.length}`,
            "",
            "Follow the code-review skill protocol:",
            "",
            "STAGE 1: SPEC COMPLIANCE",
            "For each acceptance criterion, verify:",
            "- Code exists that implements it",
            "- Test exists that verifies it",
            "- Implementation matches spec exactly",
            "",
            "STAGE 2: CODE QUALITY",
            "For each changed file, check:",
            "- Clarity and naming",
            "- Domain type usage (no primitive obsession)",
            "- Error handling coverage",
            "- Test quality and coverage",
            "- YAGNI (no unused or speculative code)",
            "",
            "STAGE 3: DOMAIN INTEGRITY",
            "Check for:",
            "- Compile-time enforcement opportunities",
            "- Consistent domain type usage",
            "- Validation at construction boundaries",
            "- Invalid states that are representable",
            "",
            "Produce a structured summary with PASS/FAIL per stage.",
          ].join("\n")
        },
      }),

      sdlc_status: tool({
        description:
          "Show the current SDLC session state: TDD phase, files modified, " +
          "pending reviews, and enforcement status.",
        args: {},
        async execute(_args, ctx) {
          const sessionId = (ctx as any).sessionID
            ?? (ctx as any).session_id
            ?? "default"
          const state = getState(sessionId)

          return [
            "SDLC SESSION STATUS",
            "===================",
            "",
            `TDD Phase: ${state.tddPhase}`,
            `Domain Review Pending: ${state.domainReviewPending}`,
            "",
            "Files Modified:",
            `  Test files: ${state.testFilesModified.length > 0 ? state.testFilesModified.join(", ") : "none"}`,
            `  Production files: ${state.productionFilesModified.length > 0 ? state.productionFilesModified.join(", ") : "none"}`,
            `  Total: ${state.filesModified.length}`,
            "",
            `Last Test Run: ${state.lastTestRun ?? "never"}`,
            `Commits Since Last Review: ${state.commitsSinceReview}`,
            "",
            "Enforcement:",
            state.tddPhase === "none"
              ? "  Phase boundaries: INACTIVE (set phase with sdlc_set_phase)"
              : `  Phase boundaries: ACTIVE (${state.tddPhase})`,
            state.domainReviewPending
              ? "  Domain review gate: BLOCKING (run sdlc_domain_review)"
              : "  Domain review gate: CLEAR",
          ].join("\n")
        },
      }),
    },
  }
}
