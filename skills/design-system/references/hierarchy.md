# Hierarchy Phase

Define the component hierarchy following Atomic Design: atoms,
molecules, organisms, and templates. Each level documents composition,
states, and token references.

## When to Use

Invoke with `/design hierarchy` when:
- Tokens are confirmed and you are ready to define the component
  catalog
- You are adding new components to an existing design system
- You need to restructure an existing component hierarchy

## Prerequisites

Tokens must be defined before starting this phase. Components reference
tokens for all visual properties.

## Process

### Level 1: Atoms

Atoms are indivisible UI elements. Each atom has a single visual
responsibility.

**What to define for each atom:**

1. **Name and purpose** -- what it is and when to use it
2. **Visual properties** -- mapped to tokens (no raw values)
3. **States** -- document each applicable state:
   - Default
   - Hover
   - Focus (keyboard and programmatic)
   - Active (pressed)
   - Disabled
   - Error
   - Loading (if applicable)
4. **Size variants** -- if the atom comes in sizes (sm, md, lg),
   document each
5. **Accessibility** -- ARIA role, keyboard behavior, screen reader
   text

**Common atoms:** Button, Input, Label, Checkbox, Radio, Toggle,
Select, Textarea, Link, Icon, Badge, Avatar, Divider, Spinner.

**Ask the user:**
- What interactive elements does the system need?
- What display elements?
- What button variants? (primary, secondary, ghost, danger)
- What input types? (text, number, date, select, textarea, search)
- If event model wireframes exist: review each wireframe and extract
  every indivisible element

**Composition rules:**
- Atoms contain only native elements (text, shapes, images) and tokens
- Atoms never contain other atoms
- Every visual property references a token

### Level 2: Molecules

Molecules are small functional groups of atoms. One interaction pattern
per molecule.

**What to define for each molecule:**

1. **Name and purpose** -- what user task it serves
2. **Composition** -- which atoms it contains (by name from the catalog)
3. **Layout** -- how atoms are arranged (horizontal, vertical, wrapped)
4. **Spacing** -- token references for gaps between atoms
5. **Interaction pattern** -- what happens when the user interacts
6. **Aggregate states** -- states beyond individual atom states (e.g.,
   a form field molecule in an "error" state highlights both label and
   input)

**Common molecules:** Form field (label + input + error), Search bar
(input + button), Navigation item (icon + label), Card header
(avatar + title + subtitle), Media object (image + text).

**Ask the user:**
- What functional groupings do you need?
- How do these groups behave? (inline vs stacked, validation patterns)
- If event model wireframes exist: identify every group of 2-3
  elements that function as a unit

**Composition rules:**
- Molecules compose only atoms from the catalog
- Molecules never skip atoms to use raw elements
- Layout spacing uses only tokens

### Level 3: Organisms

Organisms are complex components that form distinct UI sections. One
feature area per organism.

**What to define for each organism:**

1. **Name and feature area** -- what business function it serves
2. **Composition** -- which molecules and atoms it contains
3. **Layout behavior** -- how it arranges at each breakpoint
4. **Content states:**
   - Populated (normal display)
   - Empty (no data)
   - Loading (data in flight)
   - Error (data fetch failed)
5. **Token references** -- organism-level styling (background, border,
   padding)

**Common organisms:** App header, Footer, Sidebar, Data table,
Complete form, Card grid, Hero section, Feature section.

**Ask the user:**
- What distinct UI sections does the application need?
- How do these sections behave at different breakpoints?
- What content variations exist?
- If event model wireframes exist: each wireframe region that serves a
  distinct feature maps to an organism

**Composition rules:**
- Organisms compose molecules and atoms from the catalogs
- No raw markup or unsystematized elements
- Responsive behavior documented for each breakpoint token

### Level 4: Templates

Templates are page-level layouts arranging organisms. They define
structure, not content.

**What to define for each template:**

1. **Name and page type** -- what kind of page it represents
2. **Organism arrangement** -- slot map showing which organisms go where
3. **Responsive layout** -- how the arrangement changes at each
   breakpoint
4. **Content slots** -- where dynamic content goes
5. **Navigation context** -- where this template sits in the app flow

**Common templates:** Dashboard, List view, Detail view, Form page,
Landing page, Settings page, Auth page (login/register).

**Ask the user:**
- What page types does the application need?
- How are organisms arranged on each page type?
- What is the navigation structure between pages?
- If event model wireframes exist: each wireframe page layout maps to
  a template

**Composition rules:**
- Templates arrange only organisms from the catalog
- Layout spacing uses only tokens
- Templates never contain atoms or molecules directly -- those live
  inside organisms

## Output

A component catalog organized by level:

```
## Atoms
### Button
- Purpose: Primary user action
- Tokens: color-primary-500, spacing-sm, radius-md, font-weight-semibold
- States: default, hover, focus, active, disabled
- Variants: primary, secondary, ghost, danger; sizes sm, md, lg

## Molecules
### FormField
- Purpose: Labeled input with validation feedback
- Composition: Label + Input + ErrorMessage
- Layout: vertical, gap spacing-xs
- Interaction: error state shows ErrorMessage atom

## Organisms
### LoginForm
- Feature: User authentication
- Composition: FormField (email) + FormField (password) + Button
- States: default, loading, error
- Breakpoints: stacks at breakpoint-sm

## Templates
### AuthPage
- Page type: Authentication flow
- Organisms: AppHeader + LoginForm + Footer
- Layout: centered content, max-width 400px
```

## Guidelines

**Do:**
- Start from atoms and build up -- do not define organisms first
- Confirm each level with the user before moving to the next
- Cross-reference with event model wireframes for completeness
- Document every state for every component

**Do not:**
- Skip levels (e.g., building organisms from raw markup)
- Allow components to reference raw values instead of tokens
- Define templates before organisms exist
- Create components that duplicate existing catalog entries
