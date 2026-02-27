---
name: design-system
description: >-
  Collaborative design system creation using Atomic Design methodology.
  Produces a specification with philosophy, tokens, and component hierarchy.
  Invoke with /design audit | /design tokens | /design hierarchy |
  /design implementation | /design documentation | /design facilitation |
  /design artifacts.
license: CC0-1.0
metadata:
  author: jwilger
  version: "2.0"
  requires: []
  context: [event-model]
  phase: decide
  standalone: true
---

# Design System

**Value:** Communication -- a documented design system creates shared
vocabulary for every visual decision. When philosophy is explicit and
tokens are named, contributors extend the system consistently without
guessing at intent.

## Purpose

Facilitates collaborative creation of a design system specification
using Atomic Design methodology. Produces an artifact documenting
philosophy, tokens, and a full component hierarchy from atoms through
templates. Each phase is invocable independently via sub-invocations.

## Practices

### Philosophy-First Design

Every design decision traces back to named principles. Define
philosophy before any visual work. Philosophy includes brand identity,
design principles (each with a short identifier like `P1`, `P2`),
accessibility standard, responsive strategy, and constraints.

If a token or component cannot cite a philosophy principle, either it
is unnecessary or the philosophy is incomplete. Resolve before
proceeding.

### Token-Based Visual Properties

No raw values in components. Every color, spacing value, font size,
radius, shadow, timing, and opacity references a named token. Tokens
follow the naming convention `{category}-{variant}-{modifier}` (e.g.,
`color-primary-500`, `spacing-md`, `font-size-lg`).

Token categories: color, typography, spacing, border radius,
elevation/shadows, motion/animation, breakpoints, opacity. See
`references/token-categories.md` for the exhaustive category reference.

Each token entry documents: name, value, and which philosophy principle
it serves.

### Atomic Design Hierarchy

Build components bottom-up through four levels. Never skip a level.

1. **Atoms** -- Indivisible elements (buttons, inputs, labels, icons).
   Each documents states (default, hover, focus, disabled, error) and
   references only tokens for visual properties.
2. **Molecules** -- Functional units composed of atoms (form fields,
   search bars). Documents composition, interaction pattern, and layout.
3. **Organisms** -- Distinct UI sections composed of molecules and
   atoms (headers, forms, data tables). Documents layout behavior at
   breakpoints and content states (empty, loading, error, populated).
4. **Templates** -- Page layouts arranging organisms. Defines structure,
   content slots, and responsive behavior.

Traceability at every level: atoms reference tokens, molecules
reference atoms, organisms reference molecules and atoms, templates
reference organisms. No raw markup or unsystematized elements.

### Detect Artifact Format

Before generating artifacts, check whether the
`mcp__pencil__get_editor_state` tool is available.

- **Present:** Use `.pen` format. Follow `references/artifacts.md`
  Pencil section.
- **Absent:** Use HTML format. Follow `references/artifacts.md` HTML
  section.

Decide the format before starting artifact work. Do not switch formats
mid-process.

### Facilitate, Do Not Assume

You are a facilitator, not a stenographer. Ask probing questions at
each phase. Challenge choices that conflict with stated philosophy.
Use `references/facilitation.md` for phase-specific question banks.

1. Do not assume visual preferences -- ask
2. Do not skip ahead when the user gives a partial answer -- probe
   deeper
3. If event model wireframes exist in `docs/event_model/`, use them to
   identify required components, but confirm with the user
4. Present token proposals informed by the philosophy and ask for
   adjustments

### Phase Sub-Invocations

Each phase can be invoked independently:

| Invocation | Phase | Reference |
|---|---|---|
| `/design audit` | Audit existing UI patterns | `references/audit.md` |
| `/design tokens` | Define design tokens | `references/tokens.md` |
| `/design hierarchy` | Define component hierarchy | `references/hierarchy.md` |
| `/design implementation` | Implement components | `references/implementation.md` |
| `/design documentation` | Create living documentation | `references/documentation.md` |
| `/design facilitation` | Facilitate design decisions | `references/facilitation.md` |
| `/design artifacts` | Generate design system artifacts | `references/artifacts.md` |

Load the corresponding reference file when a phase is invoked. Phases
are designed to run in order (audit, tokens, hierarchy, implementation,
documentation, artifacts) but each provides value standalone.

**Do:**
- Define philosophy before any visual decisions
- Use only token references in components -- never raw values
- Complete each phase before starting the next when working sequentially
- Verify traceability at every level
- Refer to `references/token-categories.md` for comprehensive token guidance

**Do not:**
- Make technology decisions (CSS framework, component library) -- those
  belong in architecture-decisions
- Skip the philosophy phase or treat it as optional
- Use raw color codes, pixel values, or font names in components
- Design multiple phases simultaneously
- Proceed with gaps -- if something is undefined, ask

## Enforcement Note

This skill provides advisory guidance. The agent tracks phase state and
halts if the philosophy phase is skipped or if raw values are used
instead of token references in components. It cannot mechanically
prevent all violations but will flag traceability gaps when detected.
If you observe the agent skipping a phase or using hard-coded values,
point it out.

## Verification

After completing work guided by this skill, verify:

- [ ] Philosophy documented with named principles before any components
- [ ] Tokens defined for all visual categories (color, typography,
      spacing, radii, elevation, motion, breakpoints, opacity)
- [ ] Every token cites a philosophy principle
- [ ] Atoms reference only tokens (no raw values)
- [ ] Molecules compose only atoms from the catalog
- [ ] Organisms compose only molecules and atoms from the catalog
- [ ] Templates arrange only organisms from the catalog
- [ ] All component states documented (default, hover, focus, disabled,
      error as applicable)
- [ ] Wireframe fields mapped to components if event model exists
- [ ] Artifact exists at `docs/design-system.pen` or
      `docs/design-system.html`
- [ ] Philosophy is the first section in the artifact

If any criterion is not met, revisit the relevant phase before
proceeding.

## Dependencies

This skill works standalone. For enhanced workflows, it integrates
with:

- **event-modeling:** Wireframes from event modeling sessions identify
  which components the design system must include. Run event-modeling
  first for best results.

Missing a dependency? Install with:
```
npx skills add jwilger/agent-skills --skill event-modeling
```
