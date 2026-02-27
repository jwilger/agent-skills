# Shared TDD Rules

These rules apply across all phases and all invocations of the TDD cycle.

## Domain Veto Power

If the DOMAIN review raises a concern (primitive obsession, invalid-state
representability, parse-don't-validate violation), the concern routes back
to the phase that introduced it. Max 2 rounds of debate. No consensus
after 2 rounds -> escalate to the user. The domain veto can only be
overridden by the user, not by the implementing agent.

## Outside-In Progression

The first test for a vertical slice MUST target the application boundary,
not an internal unit.

### Boundary Identification by Project Type

| Project Type | Application Boundary | Example Test Entry Point |
|-------------|---------------------|------------------------|
| Web API | HTTP request/response | HTTP client hitting the server |
| CLI | Process spawn with args/stdout | `std::process::Command` or subprocess call |
| Library | Public API entry point | The public function/method that consumers call |
| Event-sourced | Command handler input/event output | Send command, assert events emitted |
| GUI / Web App | Browser/UI automation | Playwright, Selenium, or equivalent |

### Boundary Enforcement Check (3 Steps)

1. **File path check.** Verify the test file is located in an
   integration or acceptance test directory (e.g.,
   `tests/acceptance/`, `tests/integration/`, `e2e/`,
   `spec/features/`). A test in a unit test directory is not a
   boundary test.

2. **Boundary interaction check.** Read the test code. It must
   interact with an external boundary: HTTP client, CLI process
   spawning, browser driver (Playwright, Selenium), message queue
   client, WebSocket connection, or equivalent. Look for actual
   external calls, not mocked boundaries.

3. **Internal function rejection.** If the test only calls internal
   functions directly (e.g., `CommandLogic.handle()`,
   `service.process()`, `MyModule.run()`), reject it. A direct
   function call is a unit test, not an acceptance test -- even if it
   asserts on user-visible behavior.

After the first boundary-level acceptance test is established and RED,
subsequent RED phases within the same slice may write inner unit tests
that drill down into the implementation.

## Web App Boundary Rule

For projects where the application boundary is a user-facing web app:

- The acceptance test MUST exercise the full stack via browser
  automation (Playwright, Cypress, Selenium) -- rendering the UI,
  performing user interactions, and asserting on visible DOM state.
- A test that only POSTs to an HTTP endpoint WITHOUT rendering the UI
  does NOT satisfy the boundary requirement for a web app slice that
  has UI components.

**Acceptance test checklist for web app slices:**

1. Test imports a browser driver (Playwright, Selenium, Cypress, etc.)
2. Test navigates to a real URL (not mocked)
3. Test renders the page and waits for DOM elements
4. Test performs a user action (click, type, submit)
5. Test asserts on visible UI state (text content, element visibility,
   state changes)

If all five are not present, the test is not a boundary test for a web
app slice with UI components.

## Walking Skeleton

The first vertical slice must be a walking skeleton: the thinnest
end-to-end path proving all architectural layers connect. It may use
hardcoded values or stubs. Build it before any other slice.

## DOMAIN Phase Rework: When Type Changes Break Tests

When a DOMAIN phase change (e.g., adding a trait bound, changing a type
signature) causes test compilation failures, route BACK to RED for test
file updates before advancing to GREEN. GREEN never touches test files
regardless of the reason.

## Anti-pattern: Type-First TDD

Creating domain types before any test references them inverts TDD into
waterfall. Types flow FROM tests. In compiled languages, a test
referencing non-existent types will not compile -- this IS the expected
RED outcome. Do not pre-create types to avoid compilation failures.
