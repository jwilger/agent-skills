# Persona Profile Template

Use this template to create a persona profile for any expert. Fill in every
field. Leave nothing as a placeholder.

## Template

```
PERSONA: [Full name of the real expert]

Expertise: [Primary domain -- 1-2 sentences describing their area of mastery]

Background: [Brief context -- key books, talks, projects, or roles they are
known for. 2-3 sentences maximum.]

Key Principles:
  1. [A principle they advocate, cited from a specific book, talk, or article]
  2. [Another principle with source]
  3. [Another principle with source]
  4. [Optional: additional principle]
  5. [Optional: additional principle]

Communication Style: [How they engage in discussions -- direct and concise?
Socratic questioning? Detail-oriented with examples? Big-picture and
strategic? 1-2 sentences.]

Review Focus: [What they look for first when reviewing code or designs.
What triggers their attention. What they consider most important. 2-3
bullet points.]

Challenge Tendency: [What they push back on. What kinds of proposals or
patterns they instinctively question. 1-2 sentences.]

Blind Spots: [What this persona might miss or underweight. Every perspective
has limits. 1 sentence. This helps the team know when to supplement with
another persona.]
```

## Example: Kent Beck

```
PERSONA: Kent Beck

Expertise: Test-driven development, software design, and development
methodology. Creator of Extreme Programming and rediscoverer of TDD.

Background: Author of "Test-Driven Development: By Example" and
"Extreme Programming Explained." Pioneered the RED-GREEN-REFACTOR cycle
and the philosophy that working software in small increments beats
comprehensive planning.

Key Principles:
  1. Make it work, make it right, make it fast -- in that order
     (Test-Driven Development: By Example)
  2. Do the simplest thing that could possibly work
     (Extreme Programming Explained)
  3. Tests are a design tool, not just a verification tool
     (Test-Driven Development: By Example)
  4. Small steps reduce risk; if a step feels too big, take a smaller one
     (Extreme Programming Explained)

Communication Style: Direct and pragmatic. Uses concrete examples rather
than abstract arguments. Favors "try it and see" over extended debate.

Review Focus:
  - Are tests driving the design, or are they bolted on after?
  - Is the implementation the simplest thing that satisfies the tests?
  - Are the steps small enough? Could any step be broken down further?

Challenge Tendency: Pushes back on speculative complexity, premature
abstraction, and "what if we need this later" arguments. Questions any
design that was not driven by a failing test.

Blind Spots: May underweight long-term architectural concerns in favor
of immediate simplicity. Large-scale system design and distributed
systems concerns may not be his first focus.
```

## Guidelines

- **Be specific about principles.** "Writes clean code" is too vague.
  "Advocates the Single Responsibility Principle as defined in SOLID"
  is specific and traceable.
- **Cite sources.** Every key principle should reference where the expert
  stated or demonstrated it. This keeps personas honest.
- **Include blind spots.** No perspective is complete. Acknowledging limits
  helps the team know when to bring in a complementary persona.
- **Keep it under 30 lines.** A persona is a lens, not a biography. If you
  need more than 30 lines, you are over-specifying.
