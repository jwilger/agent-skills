---
description: INVOKE after solving problems or learning conventions. Stores in auto memory
user-invocable: true
argument-hint: <what-to-remember>
model: haiku
allowed-tools:
  - Read
  - Write
  - Glob
  - Grep
---

# Remember

Store discoveries, insights, and knowledge in the file-based auto memory system.

## Methodology

Follows `skills/memory-protocol/SKILL.md` for knowledge capture patterns.

## Arguments

`$ARGUMENTS` describes what to remember.

## Process

1. Categorize: debugging, architecture, conventions, tools, or patterns
2. Search for duplicates in the category directory
3. Create descriptive filename (kebab-case, 3-5 words)
4. Write markdown file with template: Title, Date, Category, Project,
   Problem/Context, Solution/Discovery, Details, Related
5. Update MEMORY.md with reference (keep last 5 entries)

## Categories

| Category | Use For | Directory |
|----------|---------|-----------|
| debugging | Solutions, error fixes | debugging/ |
| architecture | Decisions, design patterns | architecture/ |
| conventions | Project conventions, standards | conventions/ |
| tools | Tool behaviors, CLI quirks | tools/ |
| patterns | General reusable patterns | patterns/ |

## Do Not Store

- Transient conversation details
- Information already in project files
- Duplicates of existing memory
- Sensitive data (credentials, personal info)
