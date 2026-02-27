# Artifacts Phase

Generate design system artifacts. Compile philosophy, tokens, and
component catalog into a single artifact file.

## When to Use

Invoke with `/design artifacts` when:
- All phases are complete and you are ready to compile the artifact
- You need to update an existing artifact after design system changes
- You want to generate a visual reference document

## Artifact Format Detection

Check whether the `mcp__pencil__get_editor_state` tool is available.

- **Present:** Use Pencil MCP to produce `docs/design-system.pen`
- **Absent:** Use HTML to produce `docs/design-system.html`

Decide the format before starting. Do not switch formats mid-process.

---

## Pencil MCP Format (.pen)

### Setup

1. Call `get_guidelines(topic="design-system")` for Pencil-specific
   composition rules
2. Call `get_style_guide_tags()` to discover available style tags
3. Select 5-10 relevant tags based on philosophy and call
   `get_style_guide(tags=[...])` for design inspiration
4. Call `open_document("docs/design-system.pen")` if the file exists,
   or `open_document("new")` to create a new document
5. Call `get_editor_state(include_schema=true)` to understand the
   current state and .pen file schema

### Document Structure

Organize as separate top-level frames on the canvas:

1. **Philosophy Frame** -- Text frame documenting principles,
   constraints, accessibility standard. Position: top-left origin.
2. **Tokens Frame** -- Visual token reference with swatches, type
   samples, spacing blocks. Position: right of Philosophy.
3. **Atoms Frame** -- Individual atom components, each as a reusable
   component. Position: below Philosophy.
4. **Molecules Frame** -- Composed molecules referencing atom
   components. Position: right of Atoms.
5. **Organisms Frame** -- Composed organisms. Position: below Atoms.
6. **Templates Frame** -- Page layouts. Position: right of Organisms.

Use `find_empty_space_on_canvas` to position frames without overlap.

### Tokens as Pencil Variables

Define all design tokens using `set_variables`:

```json
{
  "variables": {
    "color-primary-500": { "value": "#0066cc" },
    "spacing-sm": { "value": 8 },
    "font-size-base": { "value": 16 }
  }
}
```

For dark mode, use Pencil's theme system:

```json
{
  "variables": {
    "color-surface-base": {
      "value": { "light": "#ffffff", "dark": "#1a1a1a" }
    }
  }
}
```

### Building Components

**Atoms:** Create each atom as a reusable component (`reusable: true`).
Create state variants grouped in a container frame.

**Molecules:** Compose from atom instances using `type: "ref"`.

**Organisms:** Compose from molecule and atom refs. Document the
feature area with a text annotation.

**Templates:** Arrange organisms into page layouts with defined
dimensions.

### Visual Verification

After each phase, call `get_screenshot` on the relevant frame. Check:
- Alignment and spacing consistency
- Color contrast against accessibility requirements
- Text readability at defined sizes
- Visual hierarchy matching the philosophy

### Operation Batching

Keep each `batch_design` call to 25 operations maximum. Work through
one phase at a time: create the frame, build components within it,
screenshot and verify, then move to the next phase.

---

## HTML Format (.html)

### Requirements

- **Single file.** All CSS and JS embedded inline. No external
  dependencies. Must render correctly when opened via `file://`.
- **Binary assets** (images, icons) base64-encoded inline.
- **Interactive navigation.** Sidebar or top nav linking to each
  section with smooth scroll.
- **Responsive.** Include a viewport toggle control (desktop/tablet/
  mobile preview widths).

### Required Sections

The HTML document contains these sections in order:

**1. Philosophy** (first and prominent):
- Brand identity statement
- Design principles with identifiers (P1, P2, etc.)
- Accessibility standard
- Responsive strategy
- Constraints list

**2. Tokens** -- for each category:
- Visual preview (color swatches, type samples, spacing blocks)
- Token name and value
- Philosophy reference
- Use CSS custom properties so tokens are functional

**3. Atoms** -- for each atom:
- Rendered preview in default state
- All states side by side
- Token references
- Size variants if applicable

**4. Molecules** -- for each molecule:
- Rendered preview
- Composition (atoms used)
- Interaction pattern
- Token references

**5. Organisms** -- for each organism:
- Rendered preview (populated and empty states)
- Composition (molecules and atoms used)
- Responsive behavior
- Token references

**6. Templates** -- for each template:
- Rendered preview at desktop, tablet, and mobile widths
- Slot map (organisms arrangement)
- Navigation context

### Structural Template

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>[Project Name] Design System</title>
  <style>
    :root {
      /* All tokens as CSS custom properties */
    }
    /* Document layout, component styles using only tokens */
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
    // Viewport toggle, smooth scroll, interactive demos
  </script>
</body>
</html>
```

---

## Common Guidelines

**Do:**
- Use token references for every visual value in the artifact
- Show real, representative content (not lorem ipsum for headings)
- Make philosophy the first and most prominent section
- Include a navigation mechanism for quick access to any component
- Verify the artifact renders correctly before delivering

**Do not:**
- Require a build step, CDN, or npm package to view
- Hard-code visual values anywhere -- use token references
- Generate placeholder content for component states (ask the user)
- Switch artifact formats mid-process
