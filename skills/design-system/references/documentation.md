# Documentation Phase

Create living design system documentation: component catalog, token
reference, and usage guidelines.

## When to Use

Invoke with `/design documentation` when:
- Components are implemented and you need to document how to use them
- You are updating documentation after adding new components or tokens
- You need to create usage guidelines for other developers

## Prerequisites

Implemented components and confirmed tokens should exist. Documentation
describes what has been built and how to use it.

## Process

### 1. Component Catalog

For each component at every level (atoms, molecules, organisms,
templates), document:

**Overview:**
- Name and purpose (one sentence)
- Which level it belongs to (atom/molecule/organism/template)
- Which philosophy principles it serves

**Usage:**
- When to use this component
- When NOT to use this component (common misuse cases)
- Import/usage code example

**API:**
- Props/parameters with types and defaults
- Events/callbacks emitted
- Slots/children accepted (for composable components)

**States:**
- Visual examples of each state (default, hover, focus, disabled,
  error, loading)
- How to trigger each state programmatically

**Composition:**
- For molecules: which atoms are used
- For organisms: which molecules and atoms are used
- For templates: which organisms are arranged

**Accessibility:**
- Required ARIA attributes
- Keyboard interaction pattern
- Screen reader behavior

### 2. Token Reference

Document all tokens organized by category:

- **Visual preview** for each token (color swatches, type samples,
  spacing blocks)
- **Token name** and **value**
- **Philosophy principle** it serves
- **Usage context** -- where this token is typically used
- **Do/don't pairings** -- correct and incorrect usage examples

### 3. Usage Guidelines

Document cross-cutting patterns:

**Composition guidelines:**
- How to compose components at each level
- When to create a new component vs compose existing ones
- Naming conventions for new components

**Token usage rules:**
- How to reference tokens in the project's technology stack
- How to add new tokens (process and approval)
- What to do when no token exists for a needed value

**Pattern library:**
- Common UI patterns built from the component catalog
- Page-level patterns showing template usage
- Form patterns, data display patterns, navigation patterns

**Accessibility guidelines:**
- Color contrast requirements and how to verify
- Focus management patterns
- Screen reader testing checklist

### 4. Maintenance Guide

Document how to evolve the design system:

- How to add a new atom, molecule, organism, or template
- How to modify an existing token (impact analysis)
- How to deprecate a component
- Version history and changelog format

## Output

Living documentation that includes:

1. **Component catalog** -- every component with usage examples, API
   reference, state demonstrations, and composition documentation
2. **Token reference** -- all tokens with visual previews, values,
   and philosophy citations
3. **Usage guidelines** -- composition rules, token usage, patterns,
   and accessibility
4. **Maintenance guide** -- how to evolve the system

## Guidelines

**Do:**
- Use real, representative content in examples (not lorem ipsum)
- Show both correct and incorrect usage for each component
- Keep documentation adjacent to component code when possible
- Update documentation when components or tokens change

**Do not:**
- Document components that do not exist yet (documentation follows
  implementation)
- Write documentation that duplicates the component source code
- Skip accessibility documentation
- Create documentation that requires a build step to view (prefer
  formats readable without tooling)
