# Implementation Phase

Implement components following the token system. Fill in component
bodies, wire to design tokens, and ensure no raw values leak into
components.

## When to Use

Invoke with `/design implementation` when:
- The component hierarchy is defined and you are ready to write code
- You are implementing new components from the design system catalog
- You need to refactor existing components to use the token system

## Prerequisites

The component hierarchy (atoms, molecules, organisms, templates) and
token definitions must exist before starting implementation. This phase
translates the specification into working code.

## Process

### 1. Set Up Token Infrastructure

Before implementing any component, establish token delivery in the
project's technology stack.

**CSS Custom Properties (web):**
```css
:root {
  --color-primary-500: #0066cc;
  --spacing-md: 16px;
  --font-size-base: 16px;
  --radius-md: 8px;
  /* ... all tokens from the token phase */
}
```

**Theme objects (JS frameworks):**
```javascript
const tokens = {
  color: { primary: { 500: '#0066cc' } },
  spacing: { md: '16px' },
  fontSize: { base: '16px' },
  radius: { md: '8px' }
};
```

**Native platforms:** Use the equivalent token delivery mechanism
(resource files, style constants, theme providers).

### 2. Implement Bottom-Up

Follow the hierarchy strictly:

1. **Atoms first.** Each atom is a self-contained component that
   references tokens for every visual property. No atom depends on
   another atom.

2. **Molecules second.** Each molecule imports and composes atoms.
   Molecule-level styling (spacing between atoms, container properties)
   uses tokens.

3. **Organisms third.** Each organism imports and composes molecules
   and atoms. Organism-level layout, responsive behavior, and content
   states use tokens.

4. **Templates last.** Each template imports and arranges organisms.
   Layout grid, slot sizing, and responsive breakpoints use tokens.

### 3. Wire Every Visual Property to a Token

For every component, verify that no raw values appear:

- **Colors:** All `color`, `background-color`, `border-color` values
  reference color tokens
- **Spacing:** All `padding`, `margin`, `gap` values reference spacing
  tokens
- **Typography:** All `font-family`, `font-size`, `font-weight`,
  `line-height` values reference typography tokens
- **Radii:** All `border-radius` values reference radius tokens
- **Shadows:** All `box-shadow` values reference elevation tokens
- **Animation:** All `transition-duration`, `animation-duration`,
  `transition-timing-function` values reference motion tokens

### 4. Implement All States

For each component, implement every state documented in the hierarchy:

- Default rendering
- Hover styles
- Focus styles (visible focus ring for keyboard navigation)
- Active/pressed styles
- Disabled state (visual and functional -- prevent interaction)
- Error state (for form-related components)
- Loading state (for async-dependent components)

Each state change uses tokens for the modified properties. Example:
hover changes `background-color` from `color-primary-500` to
`color-primary-600`, not from `#0066cc` to `#0052a3`.

### 5. Verify Token Coverage

After implementing each component, run a check:

1. Search the component for any hard-coded visual value (hex colors,
   pixel values, font names, timing values)
2. If found, replace with the corresponding token reference
3. If no corresponding token exists, either the token set is
   incomplete (go back to the tokens phase) or the value is a one-off
   that should be eliminated

## Output

Working components at each level that:
- Render correctly using only token references
- Display all documented states
- Compose correctly (molecules from atoms, organisms from molecules,
  templates from organisms)
- Respond to breakpoints as documented

## Guidelines

**Do:**
- Set up token infrastructure before any component code
- Implement one level at a time, verifying before moving up
- Test each component in isolation before composing
- Check every line for raw values after implementation

**Do not:**
- Implement organisms before atoms are working
- Use raw values "temporarily" with intent to tokenize later
- Copy-paste visual values between components instead of referencing
  shared tokens
- Skip state implementation for any documented state
- Make technology choices (framework, library) in this phase -- those
  decisions belong in architecture-decisions
