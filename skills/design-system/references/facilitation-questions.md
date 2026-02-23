# Facilitation Questions Quick Reference

Phase-specific question banks. Use these to drive conversation at each
phase. Do not ask all questions -- select the most relevant based on
context. Always follow up vague answers with "Can you be more specific?"

## Phase 1: Philosophy & Constraints

- If this product were a person, how would you describe their personality?
- What three words should a user think of when they see this interface?
- What existing products or interfaces do you admire? What specifically
  about them?
- What accessibility standard must we meet? (Default: WCAG 2.1 AA)
- What platforms and devices must this work on?
- Are there brand guidelines, logos, or existing colors we must honor?
- Is dark mode required, optional, or not needed?
- What is the information density preference -- spacious and focused, or
  dense and comprehensive?
- Are there regulatory or industry constraints on the visual design?
- What is the most important thing a user should be able to do at a
  glance?

## Phase 2: Design Tokens -- Color

- What is the primary brand color? Do you have a hex value or a
  reference?
- Does the brand have a secondary color, or should we derive one?
- What mood should the color palette convey -- warm, cool, neutral,
  vibrant?
- Do you need a dark mode variant? (Informs surface and neutral tokens)
- What colors represent success, warning, and error in your domain?

## Phase 2: Design Tokens -- Typography

- Serif, sans-serif, or a mix? Any specific typeface preferences?
- Should headings use a different typeface from body text?
- Do you need a monospace font for code or data display?
- What is the base reading size? (Default: 16px for web)
- How many heading levels do you realistically need?

## Phase 2: Design Tokens -- Spacing & Layout

- Dense or spacious layouts? How much breathing room between elements?
- What is the maximum content width? (Common: 1200px, 1440px)
- What grid system, if any? (12-column, content-width, fluid)

## Phase 3: Atoms

- What types of buttons does the application need? (Primary action,
  secondary, cancel, destructive)
- What input types? (Text, email, password, number, date, search,
  textarea, select)
- Do you need toggles, checkboxes, radio buttons, or all three?
- What feedback elements? (Badges, tags, progress bars, spinners)
- What icon set or style? (Outlined, filled, specific library)
- Are there any unique elements specific to your domain?

## Phase 4: Molecules

- What form patterns do you need? (Login, registration, search, filters,
  settings)
- How should validation errors appear? (Inline, summary, toast)
- What navigation patterns? (Tabs, breadcrumbs, pagination, steppers)
- What content groupings? (Cards, list items, media objects, stats)
- Do any molecules need to be interactive beyond their atoms? (Expandable,
  sortable, draggable)

## Phase 5: Organisms

- What are the main sections of each page? (Header, sidebar, content
  area, footer)
- How should data be displayed? (Tables, cards, lists, charts)
- What does each section look like when empty? When loading? When an
  error occurs?
- Which sections persist across pages? (Navigation, footer, sidebar)
- How does each section adapt on mobile?

## Phase 6: Templates

- What are the distinct page types in the application?
- Do pages share a common shell (header + sidebar + content area)?
- How does navigation flow between page types?
- What is the layout at each breakpoint? (Stack on mobile, sidebar on
  desktop?)
- Are there full-bleed pages (landing, auth) vs constrained pages
  (dashboard, settings)?
