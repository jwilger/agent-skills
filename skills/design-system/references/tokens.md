# Tokens Phase

Define design tokens for all visual categories. Every token cites a
philosophy principle. No raw values appear in components after this
phase.

## When to Use

Invoke with `/design tokens` when:
- Philosophy principles are confirmed and you are ready to define the
  visual vocabulary
- You need to add or revise tokens for an existing design system
- An audit revealed raw values that need to be tokenized

## Prerequisites

Philosophy must be defined with named principles (P1, P2, etc.) before
starting this phase. If philosophy is not yet defined, facilitate that
first.

## Process

### 1. Present Categories One at a Time

Work through token categories in this order. For each category, propose
defaults informed by the philosophy and ask the user for adjustments.

1. **Colors** -- primary, secondary, accent, semantic, neutrals, surfaces
2. **Typography** -- families, size scale, weight scale, line height
3. **Spacing** -- base unit and scale
4. **Border radii** -- corner rounding scale
5. **Elevation/shadows** -- depth and z-index layers
6. **Motion/animation** -- durations and easing curves
7. **Breakpoints** -- responsive layout thresholds
8. **Opacity** -- transparency levels

See `token-categories.md` for the exhaustive reference on each category
including naming conventions, subcategories, and common pitfalls.

### 2. Name Tokens Consistently

Follow the naming convention: `{category}-{variant}-{modifier}`

Examples:
- `color-primary-500`, `color-error-light`
- `spacing-sm`, `spacing-md`, `spacing-lg`
- `font-size-base`, `font-weight-bold`
- `radius-md`, `shadow-lg`
- `duration-fast`, `ease-default`

Names must communicate intent without seeing the value.

### 3. Cite Philosophy Principles

Every token entry documents:
- **Name:** Token identifier
- **Value:** The concrete value
- **Principle:** Which philosophy principle it serves (e.g., P1, P2)

If a token cannot cite a principle, either the token is unnecessary or
the philosophy is incomplete. Resolve before proceeding.

### 4. Validate the Token Set

Before confirming tokens, verify:
- Every philosophy principle is served by at least one token
- Color contrast meets the stated accessibility standard (check
  text-on-background pairings)
- The spacing scale has no gaps that would force raw values
- Typography scale produces a clear visual hierarchy
- Semantic colors cover all feedback states (success, warning, error,
  info)
- Surface colors provide sufficient layer distinction

## Output

A complete token table for each category:

```
## Color Tokens

| Token                  | Value   | Principle |
|------------------------|---------|-----------|
| color-primary-500      | #0066cc | P1        |
| color-primary-600      | #0052a3 | P1        |
| color-error            | #dc2626 | P3        |
| color-surface-base     | #ffffff | P2        |

## Typography Tokens

| Token                  | Value            | Principle |
|------------------------|------------------|-----------|
| font-family-body       | Inter, sans-serif| P2        |
| font-size-base         | 16px             | P3        |
| font-weight-bold       | 700              | P1        |
```

## Guidelines

**Do:**
- Propose token values informed by the philosophy -- do not ask the
  user to invent values from scratch
- Present visual contrast checks for color pairings
- Include dark mode variants if the philosophy requires dark mode
- Note when a token value departs from common defaults and explain why

**Do not:**
- Define tokens without philosophy principles in place
- Skip any of the eight categories
- Allow tokens that cannot cite a philosophy principle
- Propose a token set without asking for user adjustments
