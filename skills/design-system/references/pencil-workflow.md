# Pencil MCP Workflow Guide

When Pencil MCP tools are available, produce the design system as a
`.pen` file at `docs/design-system.pen`.

## Detection

Check for the `mcp__pencil__get_editor_state` tool. If available, use
this workflow. If not, fall back to `html-artifact.md`.

## Setup

1. Call `get_guidelines(topic="design-system")` for Pencil-specific
   design system composition rules.
2. Call `get_style_guide_tags()` to discover available style tags.
3. Select 5-10 relevant tags based on the user's philosophy and call
   `get_style_guide(tags=[...])` for design inspiration.
4. Call `open_document("docs/design-system.pen")` if the file exists,
   or `open_document("new")` to create a new document.
5. Call `get_editor_state(include_schema=true)` to understand the
   current state and .pen file schema.

## Document Structure

Organize the design system as separate top-level frames on the canvas:

1. **Philosophy Frame** -- Text frame documenting principles, constraints,
   accessibility standard. Position: top-left origin.
2. **Tokens Frame** -- Visual token reference with swatches, type samples,
   spacing blocks. Position: right of Philosophy.
3. **Atoms Frame** -- Individual atom components, each as a reusable
   component. Position: below Philosophy.
4. **Molecules Frame** -- Composed molecules referencing atom components.
   Position: right of Atoms.
5. **Organisms Frame** -- Composed organisms. Position: below Atoms.
6. **Templates Frame** -- Page layouts. Position: right of Organisms.

Use `find_empty_space_on_canvas` to position frames without overlap.

## Tokens as Pencil Variables

Define all design tokens using `set_variables`:

```json
{
  "variables": {
    "color-primary-500": { "value": "#0066cc" },
    "color-primary-600": { "value": "#0052a3" },
    "spacing-sm": { "value": 8 },
    "spacing-md": { "value": 16 },
    "font-size-base": { "value": 16 }
  }
}
```

When tokens support dark mode, use Pencil's theme system:

```json
{
  "variables": {
    "color-surface-base": {
      "value": { "light": "#ffffff", "dark": "#1a1a1a" }
    }
  }
}
```

Reference these variables in component properties instead of hard-coded
values.

## Building Components

### Atoms

Create each atom as a reusable component (`reusable: true`):

```javascript
// Example: Button atom
btn=I("atoms-frame", {
  type: "frame",
  name: "Button",
  reusable: true,
  layout: "horizontal",
  padding: 12,
  cornerRadius: [6,6,6,6]
})
label=I(btn, {
  type: "text",
  name: "label",
  content: "Button",
  fontSize: 14,
  fontWeight: "600"
})
```

For each atom, create state variants. Group states in a container frame:

```javascript
states=I("atoms-frame", {
  type: "frame",
  name: "Button States",
  layout: "horizontal",
  gap: 16
})
// Insert default, hover, focus, disabled, error variants
```

### Molecules

Compose molecules from atom instances (`type: "ref"`):

```javascript
formField=I("molecules-frame", {
  type: "frame",
  name: "FormField",
  reusable: true,
  layout: "vertical",
  gap: 4
})
lbl=I(formField, { type: "ref", ref: "Label" })
inp=I(formField, { type: "ref", ref: "TextInput" })
err=I(formField, { type: "ref", ref: "ErrorMessage" })
```

### Organisms

Compose organisms from molecule and atom refs. Document the feature
area each organism serves using a text annotation:

```javascript
header=I("organisms-frame", {
  type: "frame",
  name: "AppHeader",
  reusable: true,
  layout: "horizontal"
})
// Add logo, nav, user menu molecule refs
```

### Templates

Templates arrange organisms into page layouts:

```javascript
dashboard=I("templates-frame", {
  type: "frame",
  name: "DashboardTemplate",
  width: 1280,
  height: 800,
  layout: "vertical"
})
// Add header organism ref, sidebar + content layout
```

## Visual Verification

After each phase, call `get_screenshot` on the relevant frame to
verify the design visually:

```
get_screenshot(nodeId="atoms-frame")
```

Check for:
- Alignment and spacing consistency
- Color contrast against accessibility requirements
- Text readability at defined sizes
- Visual hierarchy matching the philosophy

## Operation Batching

Keep each `batch_design` call to 25 operations maximum. Work through
one phase at a time:

1. Create the phase frame
2. Build components within it (may take multiple batch calls)
3. Screenshot and verify
4. Move to the next phase

## Guidelines

**Do:**
- Define all tokens as Pencil variables before creating components
- Use `reusable: true` for every atom, molecule, and organism
- Use `type: "ref"` when composing higher-level components from
  lower-level ones
- Verify each phase visually with `get_screenshot`
- Use Pencil's layout system (`layout`, `gap`, `padding`) for
  consistent spacing

**Do not:**
- Hard-code color or spacing values in components -- reference variables
- Create components without the `reusable` flag
- Skip visual verification between phases
- Exceed 25 operations per `batch_design` call
