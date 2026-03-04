#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 3 ]]; then
  echo "Usage: $0 <old_version> <new_version> <bump_type> [<last_tag>]" >&2
  echo "  bump_type: major | minor | patch" >&2
  exit 1
fi

OLD_VERSION="$1"
NEW_VERSION="$2"
BUMP_TYPE="$3"
LAST_TAG="${4:-}"

# Calculate repo root: this script lives at .claude/skills/bump/
REPO_ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"

echo "Bumping version: ${OLD_VERSION} -> ${NEW_VERSION} (${BUMP_TYPE})"
echo "Repo root: ${REPO_ROOT}"
echo ""

# --- VERSION file: single source of truth for project version ---

VERSION_FILE="${REPO_ROOT}/VERSION"

echo "Updating VERSION file ..."
echo "${NEW_VERSION}" > "${VERSION_FILE}"

# --- Bump modified skills ---

echo ""
echo "Finding modified skills ..."

if [[ -n "${LAST_TAG}" ]]; then
  MODIFIED_SKILLS=$(git -C "${REPO_ROOT}" diff "${LAST_TAG}..HEAD" --name-only \
    | grep '^skills/.*/SKILL\.md$' || true)
else
  MODIFIED_SKILLS=$(git -C "${REPO_ROOT}" log --name-only --pretty=format: \
    | grep '^skills/.*/SKILL\.md$' | sort -u || true)
fi

bump_semver() {
  local ver="$1"
  local type="$2"
  local major minor patch
  IFS='.' read -r major minor patch <<< "${ver}"
  case "${type}" in
    major) echo "$((major + 1)).0.0" ;;
    minor) echo "${major}.$((minor + 1)).0" ;;
    patch) echo "${major}.${minor}.$((patch + 1))" ;;
  esac
}

BUMPED_SKILLS=()

while IFS= read -r skill_file; do
  [[ -z "${skill_file}" ]] && continue
  full_path="${REPO_ROOT}/${skill_file}"
  [[ -f "${full_path}" ]] || continue

  # Extract current version from frontmatter
  current_ver=$(grep -m1 '^  version:' "${full_path}" | sed 's/.*version: *"\([^"]*\)".*/\1/')
  if [[ -z "${current_ver}" ]]; then
    echo "  Skipping ${skill_file}: no version found in frontmatter"
    continue
  fi

  new_ver=$(bump_semver "${current_ver}" "${BUMP_TYPE}")
  echo "  ${skill_file}: ${current_ver} -> ${new_ver}"

  # Replace the version line in frontmatter (first occurrence only)
  sed -i "0,/^  version: \"${current_ver}\"/s//  version: \"${new_ver}\"/" "${full_path}"

  BUMPED_SKILLS+=("${skill_file}")
done <<< "${MODIFIED_SKILLS}"

if [[ ${#BUMPED_SKILLS[@]} -eq 0 ]]; then
  echo "  (no modified skills found)"
fi

# --- Verification ---

echo ""
echo "=== Verification ==="

ACTUAL=$(cat "${VERSION_FILE}")
echo "  VERSION file: ${ACTUAL}"

if [[ "${ACTUAL}" != "${NEW_VERSION}" ]]; then
  echo "WARNING: VERSION file does not contain expected version" >&2
  exit 1
fi

echo ""
echo "Version bump complete."
echo ""

# Print list of modified skill files for the caller to stage
if [[ ${#BUMPED_SKILLS[@]} -gt 0 ]]; then
  echo "BUMPED_SKILL_FILES:"
  for f in "${BUMPED_SKILLS[@]}"; do
    echo "  ${f}"
  done
fi
