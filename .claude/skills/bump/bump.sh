#!/usr/bin/env bash
set -euo pipefail

# Two subcommands:
#
#   bump.sh skill <skill_md_path> <bump_type>
#     Bump the version field in a skill's SKILL.md frontmatter.
#     Prints the transition: "<old_ver> -> <new_ver>"
#
#   bump.sh project <new_version>
#     Write <new_version> to the VERSION file at the repo root.
#     Prints the transition: "<old_ver> -> <new_ver>"

if [[ $# -lt 2 ]]; then
  echo "Usage:" >&2
  echo "  $0 skill <skill_md_path> <bump_type>  (bump_type: major|minor|patch)" >&2
  echo "  $0 project <new_version>" >&2
  exit 1
fi

SUBCOMMAND="$1"
REPO_ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"

bump_semver() {
  local ver="$1" type="$2"
  local major minor patch
  IFS='.' read -r major minor patch <<< "${ver}"
  case "${type}" in
    major) echo "$((major + 1)).0.0" ;;
    minor) echo "${major}.$((minor + 1)).0" ;;
    patch) echo "${major}.${minor}.$((patch + 1))" ;;
    *) echo "ERROR: Unknown bump type '${type}'" >&2; exit 1 ;;
  esac
}

case "${SUBCOMMAND}" in
  skill)
    if [[ $# -lt 3 ]]; then
      echo "Usage: $0 skill <skill_md_path> <bump_type>" >&2; exit 1
    fi
    SKILL_MD="$2"
    BUMP_TYPE="$3"

    current_ver=$(grep -m1 '^  version:' "${SKILL_MD}" | sed 's/.*version: *"\([^"]*\)".*/\1/')
    if [[ -z "${current_ver}" ]]; then
      echo "ERROR: No version found in ${SKILL_MD}" >&2; exit 1
    fi

    new_ver=$(bump_semver "${current_ver}" "${BUMP_TYPE}")
    sed -i "0,/^  version: \"${current_ver}\"/s//  version: \"${new_ver}\"/" "${SKILL_MD}"
    echo "${current_ver} -> ${new_ver}"
    ;;

  project)
    if [[ $# -lt 2 ]]; then
      echo "Usage: $0 project <new_version>" >&2; exit 1
    fi
    NEW_VERSION="$2"
    VERSION_FILE="${REPO_ROOT}/VERSION"
    OLD_VERSION=$(cat "${VERSION_FILE}")
    echo "${NEW_VERSION}" > "${VERSION_FILE}"
    echo "${OLD_VERSION} -> ${NEW_VERSION}"
    ;;

  *)
    echo "ERROR: Unknown subcommand '${SUBCOMMAND}'" >&2
    echo "Usage:" >&2
    echo "  $0 skill <skill_md_path> <bump_type>" >&2
    echo "  $0 project <new_version>" >&2
    exit 1
    ;;
esac
