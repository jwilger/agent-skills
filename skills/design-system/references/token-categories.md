# Design Token Categories

Tokens are named design decisions. Every visual property in the system
references a token. Raw values never appear in components.

## Naming Convention

Pattern: `{category}-{variant}-{modifier}`

Examples: `color-primary-500`, `spacing-md`, `font-size-lg`,
`radius-sm`, `shadow-elevated`

Use lowercase, hyphen-separated names. Be descriptive enough that the
name communicates the intent without seeing the value.

## Color

### What it controls
All color in the UI: backgrounds, text, borders, icons, interactive
states, semantic feedback.

### Subcategories

**Primary:** Brand color with a scale (50-950 or similar). Used for
primary actions, active states, links.

**Secondary:** Supporting brand color. Used for secondary actions,
accents, highlights.

**Accent:** Optional third color for emphasis or decorative elements.

**Semantic:** Colors with meaning. Required set:
- `color-success` -- positive outcomes, confirmations
- `color-warning` -- caution, non-blocking issues
- `color-error` -- errors, destructive actions, validation failures
- `color-info` -- neutral informational messages

Each semantic color needs a light variant (backgrounds) and a dark
variant (text/icons).

**Neutral:** Gray scale for text, borders, backgrounds, disabled states.
Typically 8-12 steps from near-white to near-black.

**Surface:** Background colors for layers.
- `color-surface-base` -- page background
- `color-surface-raised` -- cards, modals
- `color-surface-overlay` -- dropdowns, tooltips
- `color-surface-sunken` -- inset areas, wells

### Common pitfalls
- Defining too many primary shades (5-7 is usually enough)
- Missing dark mode surface colors
- Semantic colors without light/dark variants
- No contrast-checked pairings for text on backgrounds

## Typography

### What it controls
Font families, sizes, weights, line heights, letter spacing.

### Subcategories

**Families:** Typically 2-3.
- `font-family-body` -- primary reading font
- `font-family-heading` -- headings (can be same as body)
- `font-family-mono` -- code, tabular data

**Size scale:** Minimum 6 steps.
- `font-size-xs` through `font-size-3xl` (or similar)
- Base size (typically 16px for web) anchors the scale
- Use a consistent ratio (1.125, 1.2, 1.25, or 1.333)

**Weight scale:**
- `font-weight-regular` (400)
- `font-weight-medium` (500)
- `font-weight-semibold` (600)
- `font-weight-bold` (700)

**Line height:**
- `line-height-tight` -- headings (1.1-1.3)
- `line-height-normal` -- body text (1.4-1.6)
- `line-height-loose` -- spacious reading (1.6-1.8)

**Letter spacing:**
- `letter-spacing-tight` -- large headings
- `letter-spacing-normal` -- body text
- `letter-spacing-wide` -- small caps, labels

### Common pitfalls
- Too many font sizes (8-10 is a practical maximum)
- Missing monospace family for code/data
- Line heights that cause text to overlap at small sizes

## Spacing

### What it controls
Padding, margins, gaps between elements.

### Structure
Define a base unit (typically 4px or 8px) and a scale.

Recommended scale:
- `spacing-xs` -- 4px (half-base for 8px system)
- `spacing-sm` -- 8px
- `spacing-md` -- 16px
- `spacing-lg` -- 24px
- `spacing-xl` -- 32px
- `spacing-2xl` -- 48px
- `spacing-3xl` -- 64px

### Common pitfalls
- Gaps in the scale that force raw values
- No distinction between component padding and layout spacing
- Base unit too large (16px) making fine adjustments impossible

## Border Radius

### What it controls
Corner rounding on containers, buttons, inputs, cards.

### Structure
- `radius-none` -- 0 (sharp corners)
- `radius-sm` -- subtle rounding (2-4px)
- `radius-md` -- standard rounding (6-8px)
- `radius-lg` -- prominent rounding (12-16px)
- `radius-full` -- pill/circle (9999px)

### Common pitfalls
- Too many radius values (4-5 is enough)
- Inconsistent radius between buttons and inputs

## Elevation / Shadows

### What it controls
Depth perception through box shadows and z-index layering.

### Structure

**Shadows:**
- `shadow-sm` -- subtle lift (cards at rest)
- `shadow-md` -- moderate lift (dropdowns, popovers)
- `shadow-lg` -- strong lift (modals, dialogs)
- `shadow-none` -- flat (remove shadow)

**Z-index layers:**
- `z-base` -- 0 (default content)
- `z-dropdown` -- 100 (dropdowns, popovers)
- `z-sticky` -- 200 (sticky headers)
- `z-modal` -- 300 (modals, dialogs)
- `z-toast` -- 400 (notifications, toasts)
- `z-tooltip` -- 500 (tooltips)

### Common pitfalls
- Arbitrary z-index values (use defined layers)
- Shadows too strong or too numerous

## Motion / Animation

### What it controls
Transition durations and easing curves.

### Structure

**Duration:**
- `duration-instant` -- 0ms (no transition)
- `duration-fast` -- 100-150ms (micro-interactions, hover)
- `duration-normal` -- 200-300ms (standard transitions)
- `duration-slow` -- 400-500ms (page transitions, complex animations)

**Easing:**
- `ease-default` -- standard ease (ease-in-out)
- `ease-in` -- accelerate (elements leaving)
- `ease-out` -- decelerate (elements entering)
- `ease-spring` -- overshoot for playful UIs

### Common pitfalls
- Animations too slow (>500ms feels sluggish)
- Missing `prefers-reduced-motion` consideration
- Easing curves that feel mechanical

## Breakpoints

### What it controls
Responsive layout changes.

### Structure
- `breakpoint-sm` -- 640px (large phone / small tablet)
- `breakpoint-md` -- 768px (tablet portrait)
- `breakpoint-lg` -- 1024px (tablet landscape / small desktop)
- `breakpoint-xl` -- 1280px (desktop)
- `breakpoint-2xl` -- 1536px (large desktop)

### Common pitfalls
- Too many breakpoints (3-5 is practical)
- Breakpoints that do not match actual content reflow needs
- Missing the smallest breakpoint (content should work below `sm`)

## Opacity

### What it controls
Transparency for overlays, disabled states, decorative layers.

### Structure
- `opacity-overlay` -- 0.5-0.7 (modal backdrops)
- `opacity-disabled` -- 0.4-0.5 (disabled elements)
- `opacity-hover` -- 0.8-0.9 (hover effects on images/cards)

### Common pitfalls
- Overlay too transparent (content behind distracts)
- Disabled opacity too subtle (hard to distinguish from enabled)
