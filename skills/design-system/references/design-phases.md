# Seven-Phase Design System Process

This document details each phase of the design system creation process.
Every phase completes before the next begins. The agent facilitates each
phase collaboratively with the user.

## Phase 1: Philosophy & Constraints

**Entry condition:** User has requested a design system. Event model
wireframes are available if event-modeling skill was used.

**What to ask the user:**

1. What is the brand identity? (Name, personality, values)
2. Who are the target users and what emotions should the interface evoke?
3. What accessibility standard applies? (WCAG 2.1 AA is the minimum default)
4. What is the responsive strategy? (Mobile-first, desktop-first, specific
   breakpoints)
5. What visual principles guide the design? (e.g., "spacious and calm" vs
   "dense and information-rich", "playful" vs "professional")
6. What constraints exist? (Must support dark mode, must work on mobile,
   brand colors locked, existing style guide to honor)
7. Are there existing products or designs to maintain consistency with?

**Output:** A philosophy section containing:
- Brand identity statement (1-2 sentences)
- Design principles (3-5 named principles, each with a one-sentence
  rationale)
- Accessibility standard with level
- Responsive strategy
- Explicit constraints list

**Traceability:** Every principle gets a short identifier (e.g., `P1`,
`P2`) used as references in later phases.

**Phase gate:** Do not proceed until the user confirms the philosophy.
Every subsequent decision traces back to these principles.

## Phase 2: Design Tokens

**Entry condition:** Philosophy confirmed.

**What to ask the user:**

Present token categories one at a time. For each category, propose
defaults informed by the philosophy and ask for adjustments. See
`token-categories.md` for the full category reference.

Categories in order:
1. Colors (primary, secondary, accent, semantic, neutrals, surfaces)
2. Typography (families, size scale, weight scale, line height)
3. Spacing (base unit and scale)
4. Border radii
5. Elevation/shadows
6. Motion/animation timing
7. Breakpoints
8. Opacity

**Output:** A complete token table. Each token entry includes:
- Token name (following naming convention: `category-variant-modifier`)
- Value
- Philosophy reference (which principle it serves, e.g., `P1`)

**Traceability:** Every token cites at least one philosophy principle.
If a token cannot cite a principle, either the token is unnecessary or
the philosophy is incomplete.

**Phase gate:** All token categories defined. User confirms the token
set. No raw values will be used in subsequent phases -- only token
references.

## Phase 3: Atoms

**Entry condition:** Tokens confirmed.

**What to ask the user:**

1. What interactive elements does the system need? (Buttons, inputs,
   toggles, checkboxes, radio buttons, links)
2. What display elements? (Labels, badges, icons, avatars, dividers,
   loaders)
3. What button variants? (Primary, secondary, ghost, danger, sizes)
4. What input types? (Text, number, date, select, textarea, search)
5. If event model wireframes exist: review each wireframe and extract
   every indivisible element.

For each atom, define:
- **States:** default, hover, focus, active, disabled, error (as applicable)
- **Token references:** which tokens control each visual property
- **Sizes:** if the atom has size variants (sm, md, lg)

**Output:** Atom catalog with each atom documenting:
- Name and purpose
- Visual properties mapped to tokens (no raw values)
- All states with token-based style changes
- Size variants if applicable

**Traceability:** Every visual property references a token. Every atom
traces to a user need or wireframe element.

**Phase gate:** All atoms defined. User confirms. No molecule work
begins until atoms are complete.

## Phase 4: Molecules

**Entry condition:** Atoms confirmed.

**What to ask the user:**

1. What functional groupings do you need? (Form fields, search bars,
   navigation items, card headers, media objects)
2. How do these groups behave? (Inline vs stacked, validation patterns,
   interaction sequences)
3. If event model wireframes exist: identify every group of 2-3
   elements that function as a unit.

For each molecule, define:
- **Composition:** which atoms it contains and how they relate
- **Interaction pattern:** what happens when the user interacts
- **Layout:** how atoms are arranged (horizontal, vertical, wrapped)
- **Token references:** spacing between atoms, container styling

**Output:** Molecule catalog with each molecule documenting:
- Name and purpose
- Composition (list of atoms used)
- Layout and spacing (token references)
- Interaction pattern
- States (if the molecule has aggregate states beyond its atoms)

**Traceability:** Every molecule composes only atoms from the catalog.
Layout spacing uses only tokens.

**Phase gate:** All molecules defined. User confirms. No organism work
begins until molecules are complete.

## Phase 5: Organisms

**Entry condition:** Molecules confirmed.

**What to ask the user:**

1. What distinct UI sections does the application need? (Header,
   footer, sidebar, data table, form section, hero section, card grid)
2. How do these sections behave at different breakpoints?
3. What content variations exist? (Empty state, loading state, error
   state, populated state)
4. If event model wireframes exist: each wireframe region that serves
   a distinct feature maps to an organism.

For each organism, define:
- **Composition:** which molecules and atoms it contains
- **Layout behavior:** responsive rules, breakpoint changes
- **Content states:** empty, loading, error, populated
- **Feature area:** what business function it serves

**Output:** Organism catalog with each organism documenting:
- Name and feature area
- Composition (molecules and atoms used)
- Layout behavior at each breakpoint
- Content states
- Token references for organism-level styling

**Traceability:** Organisms compose molecules and atoms from the
catalogs. No raw markup or unsystematized elements.

**Phase gate:** All organisms defined. User confirms.

## Phase 6: Templates

**Entry condition:** Organisms confirmed.

**What to ask the user:**

1. What page types does the application need? (Dashboard, list view,
   detail view, form page, landing page, settings, auth pages)
2. How are organisms arranged on each page type?
3. What is the navigation structure between pages?
4. How does each template adapt across breakpoints?
5. If event model wireframes exist: each wireframe page layout maps to
   a template.

For each template, define:
- **Structure:** which organisms occupy which regions
- **Content slots:** where dynamic content goes
- **Responsive behavior:** layout changes at breakpoints
- **Navigation context:** where this template sits in the flow

**Output:** Template catalog with each template documenting:
- Name and page type
- Organism arrangement (slot map)
- Responsive layout rules
- Navigation context

**Traceability:** Templates arrange only organisms from the catalog.
Layout spacing uses only tokens.

**Phase gate:** All templates defined. User confirms.

## Phase 7: Artifact Assembly

**Entry condition:** Templates confirmed. All phases 1-6 complete.

Compile the complete design system into the chosen artifact format.

**If Pencil MCP is available:** Follow `pencil-workflow.md` to produce
`docs/design-system.pen`.

**If Pencil MCP is not available:** Follow `html-artifact.md` to produce
`docs/design-system.html`.

The artifact must include:
1. **Philosophy section** (first and prominent) -- principles, constraints,
   accessibility standard
2. **Token reference** -- all tokens with visual previews
3. **Component catalog** -- atoms, molecules, organisms, templates, each
   showing composition, states, and token references
4. **Traceability** -- visible links from components to tokens to philosophy

**Verification after assembly:**
- Philosophy is the first section visible
- Every component shows its token references
- Every token shows its philosophy reference
- All states are represented
- Responsive behavior is demonstrated
- The artifact lives at the correct path

**Phase gate:** User reviews the assembled artifact and confirms it is
complete and accurate.
