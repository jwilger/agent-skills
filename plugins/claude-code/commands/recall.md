---
description: INVOKE before ANY task to check for existing solutions in auto memory
argument-hint: <what-to-recall>
model: haiku
allowed-tools:
  - Grep
  - Read
  - Glob
---

# Recall

Search and retrieve relevant knowledge from the file-based auto memory system.

## Methodology

Follows `skills/memory-protocol/SKILL.md` for knowledge retrieval patterns.

## Arguments

`$ARGUMENTS` describes what to recall.

## Process

1. Extract key search terms (tool names, error keywords, domain concepts)
2. Search memory files with Grep across all category directories
3. Read most relevant matching files in full
4. Synthesize and present findings

## When to Use

ALWAYS use at the start of:
- New conversations/sessions
- Working on a new task
- Before architectural decisions
- When encountering errors
- When unsure about project conventions

The memory protocol is non-negotiable. Failing to check auto memory means
potentially rediscovering knowledge that was already found.

## Memory Directory Structure

```
memory/
  MEMORY.md              # Quick references (check first)
  debugging/             # Solutions to past problems
  architecture/          # Architecture decisions
  conventions/           # Project conventions
  tools/                 # Tool quirks and discoveries
  patterns/              # General patterns
```
