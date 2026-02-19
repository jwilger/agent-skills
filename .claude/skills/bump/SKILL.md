---
description: INVOKE to bump the project version. Analyzes git log, determines semver bump type, updates VERSION file, commits, and tags
user-invocable: true
argument-hint: [major|minor|patch]
allowed-tools:
  - Bash
  - Read
  - AskUserQuestion
---

# Bump Version Skill

Follow these steps exactly to bump the project version.

## Step 1: Check for Clean Working Tree

Run `git status --porcelain`. If there is any output, warn the user that the
working tree is dirty and **stop immediately**. Do not proceed with a dirty tree.

## Step 2: Read Current Version

Read the file `VERSION` in the repository root and extract the current version.

## Step 3: Find the Latest Git Tag

Run:

```bash
git tag -l 'v*' --sort=-v:refname | head -1
```

If no tags exist, note that and use the full git log in the next step.

## Step 4: Get Commits Since Last Tag

If a tag was found, run:

```bash
git log <tag>..HEAD --oneline
```

If no tags exist, run:

```bash
git log --oneline
```

If there are **no commits since the last tag**, warn the user and **stop
immediately**. There is nothing to bump.

## Step 5: Determine Bump Type

If `$ARGUMENTS` is explicitly `major`, `minor`, or `patch`, use that directly.

Otherwise, analyze the commit messages to determine the bump type:

- If any commit contains "BREAKING" or "breaking change" (case-insensitive) →
  **major**
- If any commit contains "Add", "new", "implement", or "feature"
  (case-insensitive) → **minor**
- Everything else → **patch**

## Step 6: Calculate New Version

Parse the current version as `MAJOR.MINOR.PATCH` and increment:

- **major**: increment MAJOR, reset MINOR and PATCH to 0
- **minor**: increment MINOR, reset PATCH to 0
- **patch**: increment PATCH

## Step 7: Confirm with User

Use `AskUserQuestion` to show the user:

- Current version → New version
- The list of commits that will be included
- The reasoning for the bump type chosen

Ask the user to confirm or provide an override (e.g., they may want `minor`
instead of `patch`). If the user provides an override, recalculate the new
version accordingly.

## Step 8: Run the Bump Script

Check if the current branch is `main`. If not, **warn** the user but allow them
to proceed if they confirm.

Run the bump script:

```bash
bash .claude/skills/bump/bump.sh <current_version> <new_version>
```

If the script fails (non-zero exit), **stop immediately** and report the error.

## Step 9: Stage and Commit

Stage the VERSION file:

```bash
git add VERSION
```

Commit with the message:

```
bump version to X.Y.Z
```

## Step 10: Create Annotated Tag

```bash
git tag -a "vX.Y.Z" -m "vX.Y.Z"
```

## Step 11: Offer to Push

Use `AskUserQuestion` to ask the user if they want to push the commit and tag:

```bash
git push && git push --tags
```

Only push if the user confirms.
