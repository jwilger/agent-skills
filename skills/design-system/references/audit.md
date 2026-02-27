# Audit Phase

Audit existing UI patterns and inconsistencies before defining a new
design system. This phase produces an inventory that informs token and
component decisions.

## When to Use

Invoke with `/design audit` when:
- A project has existing UI code but no formal design system
- You are migrating from ad-hoc styles to a token-based system
- You need to understand current visual patterns before defining new ones

Skip this phase if the project has no existing UI.

## Process

### 1. Inventory Current Components

Scan the codebase for existing UI elements. For each element found,
document:

- **Name:** What it is called in code (component name, class name)
- **Location:** File path(s) where it appears
- **Visual properties:** Colors, fonts, spacing, radii used (note raw
  values vs any existing variables/tokens)
- **States:** What states are implemented (hover, focus, disabled, etc.)
- **Variants:** Size or style variants that exist
- **Usage count:** How many places it is used

Organize the inventory by Atomic Design level:
- Atoms (buttons, inputs, labels, icons, badges)
- Molecules (form fields, search bars, nav items)
- Organisms (headers, footers, forms, data tables)
- Templates (page layouts)

### 2. Identify Inconsistencies

Compare similar components and flag:

- **Color inconsistencies:** Same semantic meaning using different
  colors (e.g., primary buttons with three different blue values)
- **Spacing inconsistencies:** Similar layouts using different spacing
  values
- **Typography inconsistencies:** Same text role using different font
  sizes or weights
- **Border radius inconsistencies:** Mixed rounding styles
- **State coverage gaps:** Components missing hover, focus, or
  disabled states
- **Naming inconsistencies:** Same concept with different names in
  different parts of the codebase

### 3. Document Existing Styles

Extract every unique value currently used for:

- Colors (hex codes, RGB values, named colors)
- Font families and sizes
- Spacing values (padding, margin, gap)
- Border radii
- Shadows
- Breakpoints
- Opacity values

Group values that appear to serve the same purpose. These groups
become candidates for tokens.

### 4. Gap Analysis

Identify what is missing:

- Components needed but not yet built (reference wireframes if event
  model exists)
- States not implemented (especially disabled and error states)
- Responsive behavior not defined
- Accessibility gaps (missing focus styles, insufficient contrast)
- Dark mode support if required

## Output

The audit produces a structured report:

```
## Audit Report

### Component Inventory
| Component | Level | Location | Raw Values | States | Issues |
|-----------|-------|----------|-----------|--------|--------|
| ...       | atom  | ...      | 3 colors  | 2/5    | ...    |

### Value Clusters
| Purpose        | Values Found       | Proposed Token    |
|---------------|-------------------|-------------------|
| Primary blue  | #0066cc, #0070dd  | color-primary-500 |
| Small spacing | 6px, 8px, 10px   | spacing-sm        |

### Inconsistencies
1. [Description of inconsistency]
2. [Description of inconsistency]

### Gaps
1. [Missing component or state]
2. [Missing component or state]
```

## Guidelines

**Do:**
- Be exhaustive -- scan all UI files, stylesheets, and component
  directories
- Note which raw values are most commonly used (they become token
  candidates)
- Flag accessibility issues found during the audit
- Cross-reference with event model wireframes if available

**Do not:**
- Fix inconsistencies during the audit -- document them for later phases
- Define tokens during the audit -- that is the tokens phase
- Skip the audit on projects with existing UI -- assumptions lead to
  gaps in the token system
