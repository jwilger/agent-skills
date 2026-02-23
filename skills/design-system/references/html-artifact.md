# HTML Artifact Guide

When Pencil MCP is not available, produce the design system as a
single-file HTML document at `docs/design-system.html`.

## Requirements

- **Single file.** All CSS and JS embedded inline. No external
  dependencies. The file must render correctly when opened directly
  in a browser via `file://`.
- **Binary assets** (images, icons) base64-encoded inline.
- **Interactive navigation.** A sidebar or top nav linking to each
  section with smooth scroll.
- **Responsive.** The artifact itself should demonstrate responsive
  behavior. Include a viewport toggle control (desktop/tablet/mobile
  preview widths).

## Required Sections

The HTML document must contain these sections in this order:

### 1. Philosophy

The first visible section. Contains:
- Brand identity statement
- Design principles with identifiers (P1, P2, etc.)
- Accessibility standard
- Responsive strategy
- Constraints list

This section is prominent because every component traces back to it.

### 2. Tokens

For each token category (color, typography, spacing, etc.):
- **Visual preview.** Color swatches for colors. Type samples for
  typography. Spacing blocks for spacing. Radius examples for radii.
  Shadow examples for elevation.
- **Token name** and **value** displayed alongside each preview.
- **Philosophy reference** (which principle each token serves).
- Use CSS custom properties for all token values so the tokens are
  functional, not just documented.

### 3. Atoms

For each atom:
- **Rendered preview** showing the atom in its default state.
- **All states** shown side by side (default, hover, focus, disabled,
  error).
- **Token references** listed below the preview.
- **Size variants** if applicable.

### 4. Molecules

For each molecule:
- **Rendered preview** at default state.
- **Composition** -- list of atoms it contains.
- **Interaction pattern** described briefly.
- **Token references** for molecule-level styling.

### 5. Organisms

For each organism:
- **Rendered preview** showing populated and empty states.
- **Composition** -- molecules and atoms used.
- **Responsive behavior** -- show how it changes at different widths
  (use the viewport toggle to demonstrate).
- **Token references** for organism-level styling.

### 6. Templates

For each template:
- **Rendered preview** at desktop, tablet, and mobile widths.
- **Slot map** -- which organisms go where.
- **Navigation context** -- where this page type sits in the app flow.

## Structural Template

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>[Project Name] Design System</title>
  <style>
    /* === Design Tokens as CSS Custom Properties === */
    :root {
      /* Colors */
      --color-primary-500: #...;
      /* Typography */
      --font-family-body: '...';
      /* Spacing */
      --spacing-md: 16px;
      /* ... all tokens ... */
    }

    /* === Document Layout === */
    /* Navigation, sections, component previews */

    /* === Component Styles === */
    /* Atoms, molecules, organisms using only token references */
  </style>
</head>
<body>
  <nav><!-- Section navigation --></nav>

  <main>
    <section id="philosophy"><!-- Philosophy --></section>
    <section id="tokens"><!-- Token reference --></section>
    <section id="atoms"><!-- Atom catalog --></section>
    <section id="molecules"><!-- Molecule catalog --></section>
    <section id="organisms"><!-- Organism catalog --></section>
    <section id="templates"><!-- Template catalog --></section>
  </main>

  <script>
    // Viewport toggle, smooth scroll, interactive state demos
  </script>
</body>
</html>
```

## Guidelines

**Do:**
- Use CSS custom properties for every token value
- Show real, representative content in previews (not lorem ipsum for
  headings or labels)
- Make the philosophy section visually prominent (larger type, top
  position)
- Include a "jump to" navigation for quick access to any component

**Do not:**
- Require a build step, CDN, or npm package to view the file
- Use JavaScript frameworks -- vanilla HTML/CSS/JS only
- Hard-code visual values in component styles (use token variables)
- Generate placeholder content for component states (ask the user for
  representative content where appropriate)
