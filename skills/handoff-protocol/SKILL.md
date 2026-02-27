---
name: handoff-protocol
description: >-
  Structured handoff between agents or phases. Ensures context, state,
  and evidence transfer completely when work transitions between
  agents, sessions, or phases. Activate when handing off work.
license: CC0-1.0
metadata:
  author: jwilger
  version: "1.0"
  requires: []
  context: [source-files, git-history]
  phase: build
  standalone: true
---

# Handoff Protocol

**Value:** Communication -- handoffs are the highest-risk moment for
information loss. Structured evidence transfer prevents the receiving agent
from guessing about the state of work, which prevents wasted effort and
incorrect assumptions.

## Purpose

Teaches a structured handoff process that transfers context, evidence, and
remaining work between agents, sessions, or phases. Prevents the most
common handoff failures: missing context, described-but-not-shown evidence,
and ambiguous "where I left off" summaries.

## Practices

### Every Handoff Includes Four Sections

A handoff is a structured document with exactly four sections. No section
may be omitted. If a section is empty (e.g., no blockers), state that
explicitly.

```
HANDOFF: [brief description of the work]

## What Was Done
[Completed work with concrete references]

## Evidence
[Pasted output, file paths, commit hashes]

## What Remains
[Specific next steps]

## Blockers
[What prevents progress, or "None"]
```

### What Was Done: Concrete References Only

Describe completed work with specific references that the receiver can
verify. Every claim must be checkable.

**Do:**
```
## What Was Done
- Implemented user login endpoint (src/auth/login.rs, commit a1b2c3d)
- Added acceptance test for login flow (tests/auth/login_test.rs)
- Domain types: UserId, SessionToken, LoginError (src/auth/types.rs)
- TDD cycles completed: 3 (login success, invalid password, locked account)
```

**Do not:**
```
## What Was Done
- Set up the auth module
- Added some tests
- It mostly works
```

Vague descriptions force the receiver to investigate what "mostly works"
means. Be specific.

### Evidence: Pasted, Not Described

Evidence must be SHOWN, not described. "Tests pass" is a claim. Pasted test
output is evidence.

**Do:**
```
## Evidence
Test output (all passing):
  PASS tests/auth/login_test.rs
    login_success .............. ok (12ms)
    invalid_password ........... ok (8ms)
    locked_account ............. ok (9ms)
  3 passed, 0 failed

Git status (clean working tree):
  On branch feature/user-login
  nothing to commit, working tree clean

Latest commit:
  a1b2c3d feat: implement user login with session tokens
```

**Do not:**
```
## Evidence
- Tests pass
- Code is committed
- Working tree is clean
```

Acceptable evidence types:
- **Test output:** Pasted from the terminal, showing pass/fail status
- **File paths:** Absolute paths to created or modified files
- **Commit hashes:** From `git log`, verifiable with `git show`
- **Error messages:** Full output when reporting failures or blockers
- **Screenshots/URLs:** When visual verification is relevant

### What Remains: Specific Next Steps

List exactly what the receiver should do next. Each item should be
actionable without further research.

**Do:**
```
## What Remains
1. Implement password reset flow (next vertical slice per ticket #14)
   - Acceptance test: user requests reset, receives email, clicks link,
     sets new password
   - Start with RED phase: write acceptance test in tests/auth/reset_test.rs
2. Add rate limiting to login endpoint (noted during code review, not yet
   a ticket -- create one first)
```

**Do not:**
```
## What Remains
- Finish the auth stuff
- Maybe add rate limiting?
```

If you are unsure what should come next, say so explicitly rather than
providing vague guidance.

### Blockers: Be Explicit or Say None

If blockers exist, describe them with enough detail that the receiver (or
the user) can resolve them.

**Do:**
```
## Blockers
- Email service configuration: the SMTP credentials in .env.example are
  placeholders. Password reset tests will fail until real credentials
  are provided or a test mock is configured. See tests/README.md for
  mock setup instructions.
```

**Do not:**
```
## Blockers
- Email doesn't work
```

If there are no blockers, state it explicitly:

```
## Blockers
None. All work can proceed immediately.
```

### Receiving a Handoff: Verify Before Starting

When you receive a handoff, verify it before starting work:

1. **Check evidence.** Run the tests mentioned. Verify the commits exist.
   Confirm file paths are correct.
2. **Read What Remains.** Ensure you understand every next step. If
   anything is ambiguous, ask before proceeding.
3. **Check Blockers.** If blockers are listed, verify they are still
   blockers (they may have been resolved since the handoff was written).
4. **Confirm completeness.** If any section is missing or vague, request
   a revised handoff before starting.

Do not start work on a handoff you have not verified. Missing evidence
blocks the handoff.

### Handoff Contexts

This protocol applies to all transitions:

- **Phase transitions:** RED to DOMAIN, DOMAIN to GREEN (TDD cycle).
  Each phase transition is a handoff with evidence.
- **Agent switches:** When one agent stops and another picks up the same
  work. The handoff document is the transfer mechanism.
- **Session boundaries:** When context is lost due to session end or
  compaction. The handoff document survives as a file.
- **Role transitions:** When work moves from design to implementation,
  implementation to review, or review to deployment.

For TDD phase transitions, see the `tdd` skill's handoff schema
(`tdd/references/handoff-schema.md`) for the phase-specific evidence
requirements.

### Storage

Write handoffs to a file so they survive context loss:

- **Default location:** `.handoffs/` directory in the project root
- **Naming:** `[date]-[description].md` (e.g., `2024-03-15-user-login.md`)
- **Add `.handoffs/` to `.gitignore`** -- handoffs are operational
  artifacts, not project history

If the project uses a different convention for operational artifacts,
follow that convention instead.

## Enforcement Note

This skill provides advisory guidance. It instructs the agent on how to
produce and verify structured handoffs but cannot mechanically prevent
incomplete handoffs or described-but-not-shown evidence. The receiving
agent's verification step is the primary enforcement mechanism -- a
well-trained receiver rejects incomplete handoffs. If you observe handoffs
with missing sections or described evidence, point it out.

## Verification

After producing a handoff, verify:

- [ ] All four sections are present (What Was Done, Evidence, What Remains,
      Blockers)
- [ ] What Was Done references specific files, commits, or artifacts
- [ ] Evidence is pasted output, not descriptions ("tests pass")
- [ ] Every claim in What Was Done has corresponding evidence
- [ ] What Remains lists specific, actionable next steps
- [ ] Blockers are detailed or explicitly "None"
- [ ] The handoff is written to a file (not just in conversation context)

After receiving a handoff, verify:

- [ ] Evidence checks out (tests run, commits exist, files are present)
- [ ] What Remains is unambiguous
- [ ] Blockers are current (still blocking or resolved)
- [ ] No sections are missing or vague

If any criterion is not met, request a revised handoff before proceeding.

## Dependencies

This skill works standalone with no required dependencies. It integrates with:

- **tdd:** TDD phase transitions are handoffs; this skill provides the
  general protocol that the TDD handoff schema specializes.
- **consensus-facilitation:** When handoff verification reveals ambiguity,
  the consensus process can resolve disagreements about what was done or
  what remains.

Missing a dependency? Install with:
```
npx skills add jwilger/agent-skills --skill tdd
```
