---
name: persona-creation
description: >-
  Create agent personas based on real-world software engineering experts.
  Each persona brings a distinct perspective grounded in published work
  and known expertise. Activate when setting up expert perspectives
  for review or decision-making.
license: CC0-1.0
metadata:
  author: jwilger
  version: "1.0"
  requires: []
  context: []
  phase: decide
  standalone: true
---

# Persona Creation

**Value:** Communication and feedback -- diverse expert perspectives surface
blind spots that a single viewpoint misses. Grounding personas in real
expertise ensures the perspectives are substantive, not performative.

## Purpose

Teaches how to create agent personas modeled on real-world software
engineering experts. Each persona provides a distinct, grounded perspective
for code review, architecture decisions, and design discussions. Prevents
echo-chamber agreement by ensuring personas have genuinely different
priorities and expertise areas.

## Practices

### Personas Are Based on Real Experts

Every persona is grounded in a real person's published work, talks, books,
or known expertise. This ensures the perspective is substantive and
defensible, not a caricature.

A persona includes:
- **Name:** The real expert's name
- **Expertise area:** Their primary domain of knowledge
- **Key principles:** 3-5 principles they are known for advocating
- **Communication style:** How they typically engage (direct, Socratic,
  detail-oriented, big-picture, etc.)
- **Review focus:** What they look for when reviewing code or designs
- **Source material:** Books, talks, or articles that inform this persona

See `references/profile-template.md` for the full persona profile template.

### Select Personas for Distinct Perspectives

When assembling personas for a decision or review, choose experts whose
perspectives create productive tension, not agreement.

**Do:**
- Include perspectives that naturally conflict (e.g., a simplicity advocate
  and a robustness advocate)
- Choose experts whose domains cover different aspects of the problem
- Ensure at least one persona challenges the dominant approach

**Do not:**
- Pick three experts who would all say the same thing
- Choose personas solely based on fame rather than relevant expertise
- Create a persona with no grounding in the real expert's actual positions

See `references/role-catalog.md` for a catalog of recommended expert roles
and when to use each one.

### Persona Profile Structure

Each persona profile follows a consistent structure so that any agent can
adopt it reliably. See `references/profile-template.md` for the complete
template.

The essential fields are:

```
PERSONA: [Expert Name]
Expertise: [Primary domain]
Key Principles:
  1. [Principle from their published work]
  2. [Another principle]
  3. [Another principle]
Communication Style: [How they engage]
Review Focus: [What they prioritize in reviews]
Challenge Tendency: [What they push back on]
```

Keep personas concise. The goal is to capture a perspective, not to write
a biography. If you need more detail on a specific expert's positions,
consult their published work.

### Using Personas for Solo Reflection

When working alone, adopt 2-3 personas to review your own work from
different angles:

1. Complete your initial work
2. Adopt Persona A -- review the work through their lens, noting concerns
3. Adopt Persona B -- review independently, noting different concerns
4. Synthesize the feedback across perspectives
5. Address the most important concerns before proceeding

The value is in genuinely adopting each perspective, not performing a
superficial pass. Spend real effort arguing each persona's case.

### Using Personas in Multi-Agent Scenarios

When multiple agents are available, assign one persona per agent:

1. Each agent reads and adopts their assigned persona profile
2. Each agent reviews or provides input through that persona's lens
3. The facilitator (using `consensus-facilitation`) collects and
   synthesizes across personas
4. The team resolves disagreements through the consensus process

Agents must stay in character -- an agent assigned the DDD expert persona
should not suddenly start arguing about deployment pipelines unless it
connects to domain modeling.

### Evolving Personas

Personas are not static. Update them when:

- You learn more about the expert's actual positions (correct misattributions)
- The project's needs change (swap a security expert for a UX expert)
- A persona is not generating useful distinct feedback (replace with one
  that creates more productive tension)

Document persona changes so the team knows which perspectives are active.

## Enforcement Note

This skill provides advisory guidance. It instructs the agent on how to
create and use expert personas but cannot mechanically prevent shallow
roleplay or personas that agree on everything. The requirement that personas
be grounded in real expertise is enforced by convention -- the profile must
cite source material. If you observe personas providing positions without
grounding in their stated expertise, point it out.

## Verification

After creating personas guided by this skill, verify:

- [ ] Every persona is based on a real expert with published work
- [ ] Each persona profile includes all essential fields (name, expertise,
      principles, style, review focus)
- [ ] Source material is cited for each persona's key principles
- [ ] Selected personas provide genuinely distinct perspectives
- [ ] At least one persona challenges the dominant approach
- [ ] Personas are concise (perspective capture, not biography)
- [ ] When used in review, each persona's feedback reflects their stated
      expertise (not generic commentary)

If any criterion is not met, revisit the relevant practice before proceeding.

## Dependencies

This skill works standalone. For enhanced workflows, it integrates with:

- **consensus-facilitation:** Structures the decision process when multiple
  personas provide input.
- **consensus-participation:** Teaches each persona-agent how to provide
  well-formed positions with evidence.
- **code-review:** Personas can serve as reviewers in the three-stage code
  review process, each focusing on their area of expertise.

Missing a dependency? Install with:
```
npx skills add jwilger/agent-skills --skill consensus-facilitation
```
