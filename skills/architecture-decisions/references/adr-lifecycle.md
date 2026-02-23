# ADR Four-Phase Lifecycle

Every architecture decision follows four phases in strict order:
**RESEARCH → DRAFT → HOLD → MERGE**. No phase may be skipped. The agent
tracks the current phase and enforces gate conditions at each transition.

## Phase 1: RESEARCH

**Goal:** Verify assumptions about external dependencies before any ADR
text is written.

**Entry condition:** A decision point has been identified.

**Activities:**
1. List every external dependency the decision touches (libraries,
   services, APIs, protocols, standards)
2. For each dependency, read its source code, official documentation,
   or API specification
3. Produce a written summary of findings per dependency:
   - What was consulted (URL, file, version)
   - What the dependency actually does (not what you assume)
   - Whether it already decides the question (making it a constraint)
4. If a dependency already decides the question, document it as a
   constraint in `docs/ARCHITECTURE.md` -- no ADR needed

**Exit deliverable:** Written research findings summary covering all
touched dependencies.

**Gate rule:** The team must confirm understanding of the findings before
the author proceeds to DRAFT.

**What is NOT allowed:**
- Writing ADR text (Context, Decision, Alternatives sections)
- Making implementation choices
- Starting implementation

## Phase 2: DRAFT

**Goal:** Write the ADR grounded in verified research.

**Entry condition:** RESEARCH findings summary exists and team has
confirmed understanding.

**Activities:**
1. Create a branch: `adr/<decision-slug>` from main
2. Write the ADR using `references/adr-template.md`
3. Every claim about external dependency behavior must cite a specific
   finding from the RESEARCH phase
4. Update `docs/ARCHITECTURE.md` to reflect the proposed decision
5. Create a PR labeled `adr` with the ADR as the PR description
6. The author does NOT merge and does NOT request merge

**Exit deliverable:** Open PR with complete ADR and ARCHITECTURE.md
update.

**Gate rule:** A DRAFT attempted without RESEARCH findings halts with:
> "RESEARCH phase incomplete. Summarize dependency findings before
> drafting the ADR."

**What is NOT allowed:**
- Merging the PR
- Beginning implementation that depends on this decision
- Claims about dependencies not verified in RESEARCH

## Phase 3: HOLD

**Goal:** Independent verification that the ADR matches reality.

**Entry condition:** PR is open with complete ADR.

**Activities:**
1. Author signals "HOLD: ADR ready for review" on the PR
2. Reviewers perform a **specification-vs-reality gap check**:
   - Do the research findings match current dependency behavior?
   - Does the ADR accurately reflect the research findings?
   - Are there dependency changes since RESEARCH that invalidate findings?
3. Any reviewer may place a **blocking hold** with a specific concern
4. Blocking holds must be explicitly lifted by the reviewer who placed
   them -- the author cannot self-clear a hold
5. Silence from reviewers is NOT consent -- explicit approval is required

**Exit deliverable:** All blocking holds explicitly lifted. At least one
explicit approval received.

**Gate rule:** A MERGE attempted with any unresolved hold is a protocol
violation regardless of content correctness.

**What is NOT allowed:**
- Implementation work that depends on this decision
- Self-clearing blocking holds
- Treating reviewer silence as approval
- Merging without explicit approval

## Phase 4: MERGE

**Goal:** Finalize the decision and make it authoritative.

**Entry condition:** All holds lifted, explicit approval received.

**Activities:**
1. Verify CI is green on the ADR branch
2. Verify no conflict markers exist (mechanically, not by inspection)
3. Rebase the ADR branch onto main
4. Merge the PR
5. Verify `docs/ARCHITECTURE.md` Key Decisions table is updated with
   a link to the merged PR

**Exit deliverable:** Merged PR. ARCHITECTURE.md updated on main.

**Gate rule:** All of these must be true before merge:
- All blocking holds explicitly lifted
- CI passing
- No conflict markers (verified by running `grep -r '<<<<<<<'` on
  changed files)
- Explicit approval on record

## Phase Transition Prompts

At each transition, the agent prompts the author:

**RESEARCH → DRAFT:**
> "Research findings are ready. Dependencies examined: [list]. Shall I
> proceed to DRAFT the ADR?"

**DRAFT → HOLD:**
> "ADR drafted on branch adr/<slug>. PR created. Entering HOLD --
> waiting for reviewer approval."

**HOLD → MERGE:**
> "All holds cleared. Approval received from [reviewers]. CI is green.
> No conflict markers. Ready to rebase and merge?"

## Handling Edge Cases

**Decision is actually a constraint:** If RESEARCH reveals a dependency
already decides the question, skip the ADR. Document the constraint
directly in `docs/ARCHITECTURE.md` under Constraints. Note why it is a
constraint, not a decision.

**Research invalidates the draft:** If new information surfaces during
HOLD that contradicts the RESEARCH findings, return to RESEARCH. Do not
patch the DRAFT -- re-verify from the beginning.

**Urgent decisions:** The lifecycle still applies. RESEARCH may be brief
(a single dependency check) but cannot be skipped. Document the urgency
in the ADR Context section.

**No external dependencies:** If the decision involves only internal
architecture with no external dependencies, RESEARCH focuses on the
current codebase state. The phase still produces a written summary of
what was examined.
