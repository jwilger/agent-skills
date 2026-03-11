---
description: INVOKE to bump the project version. Discovers changed skills since last tag, shows confirmation summary, commits per-skill then commits project version, tags, and pushes
user-invocable: true
argument-hint: [major|minor|patch]
allowed-tools:
  - Bash
  - Read
  - AskUserQuestion
---

# Bump Version Skill

Follow these steps exactly to bump the project version.

## Step 1: Find the Latest Git Tag

Run:

```bash
git tag -l 'v*' --sort=-v:refname | head -1
```

If no tags exist, note that. The last tag (or empty string if none) is used
throughout to scope change detection.

## Step 2: Get Commits and Changed Files Since Last Tag

If a tag was found, run:

```bash
git log <tag>..HEAD --oneline
git diff --name-only <tag>..HEAD
git diff --name-only HEAD          # unstaged changes
git diff --name-only --cached HEAD # staged changes
```

If no tag exists, use `git log --oneline` and `git diff --name-only HEAD` /
`git diff --name-only --cached HEAD`.

Merge all changed file paths into a single deduplicated list. If there are
no commits since the last tag AND no staged/unstaged changes, warn the user
and **stop immediately** — there is nothing to bump.

## Step 3: Identify Affected Skills

From the full list of changed files, identify which skills are affected.
A skill is affected if any file under `skills/<name>/` appears in the list
(including reference files, not just `SKILL.md`). Exclude `skills/.template/`.

For each affected skill, note the SKILL.md path: `skills/<name>/SKILL.md`.

Also note any non-skill files that changed (e.g., `README.md`, `CLAUDE.md`,
`VERSION`, `.claude/skills/bump/`) — these will go in the final project-level
commit.

## Step 4: Read Current Versions

For each affected skill, read the current `version` from its SKILL.md
frontmatter:

```bash
grep -m1 '^  version:' skills/<name>/SKILL.md
```

Also read the current project version from `VERSION`.

## Step 5: Determine Bump Type Per Skill and Project

If `$ARGUMENTS` is explicitly `major`, `minor`, or `patch`, use that as the
default bump type for all skills and the project (but the user can still
override per-skill in Step 7).

Otherwise, for **each affected skill individually**, infer a suggested bump
type from the diff of that skill's changed files:

```bash
git diff <tag> -- skills/<name>/  # committed changes
git diff HEAD -- skills/<name>/   # unstaged changes
git diff --cached HEAD -- skills/<name>/  # staged changes
```

Apply this heuristic to the combined diff content for that skill:

- Diff removes or replaces a major mechanism (e.g., rewrites a strategy,
  removes a supported mode) → **minor** (or **major** if clearly breaking)
- Diff adds new sections, practices, or options → **minor**
- Diff fixes wording, clarifies, or makes small corrections → **patch**

Also infer a suggested bump type for the **project** based on the overall
scope of all changes combined.

## Step 6: Calculate New Versions

For each affected skill, calculate the new version by applying that skill's
suggested bump type to its current version.

Calculate the new project version by applying the project's suggested bump
type to the current project version in `VERSION`.

## Step 7: Confirm with User — Per Skill

Present a summary and ask the user to confirm or override **each skill
individually**. Use `AskUserQuestion` with one question **per skill** plus one
for the project version. Each question should show:

- The skill name and changed files
- The suggested bump type and brief reasoning
- Options: the suggested bump (recommended), and the other two bump types

For the project version question, show the suggested bump type and reasoning
based on the overall set of changes.

After the user responds, recalculate any versions where the bump type changed.

If the current branch is not `main`, include a warning in the first question.

## Step 8: Commit Each Skill

For each affected skill (process alphabetically by skill name):

1. Run the bump script to update the version in its SKILL.md:

   ```bash
   bash .claude/skills/bump/bump.sh skill skills/<name>/SKILL.md <bump_type>
   ```

   The script prints `<old> -> <new>` on success. If it exits non-zero, stop
   immediately and report the error.

2. Stage all files for that skill:

   ```bash
   git add skills/<name>/
   ```

3. Commit:

   ```bash
   git commit -m "bump <name> to <new_version>"
   ```

## Step 9: Commit Project Version

1. Run the bump script to update `VERSION`:

   ```bash
   bash .claude/skills/bump/bump.sh project <new_project_version>
   ```

2. Stage the project-level files (VERSION, any non-skill changed files, and
   the bump skill itself if it changed):

   ```bash
   git add VERSION
   # Also stage any other non-skill changed files identified in Step 3,
   # including .claude/skills/bump/ if any of its files changed
   ```

3. Commit:

   ```bash
   git commit -m "bump version to <new_project_version>"
   ```

## Step 10: Create Annotated Tag

```bash
git tag -a "v<new_project_version>" -m "v<new_project_version>"
```

## Step 11: Offer to Push

Use `AskUserQuestion` to ask the user if they want to push the commits and tag:

```bash
git push && git push --tags
```

Only push if the user confirms.
