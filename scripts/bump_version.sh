#!/usr/bin/env bash
#
# Computes the next semantic version for Dompet from Conventional Commits
# since the last v* tag and writes it to pubspec.yaml.
#
# Bump rules (highest wins across all commits in the range):
#   - major : "BREAKING CHANGE" footer, or a type with "!" (e.g. feat!:, fix!:)
#   - minor : feat(...) / feat: commits
#   - patch : everything else (fix, chore, docs, refactor, ci, test, ...)
#
# Usage:
#   scripts/bump_version.sh            # bump pubspec based on commits since last tag
#   scripts/bump_version.sh --dry-run  # print computed version without writing
#   scripts/bump_version.sh --print    # print only the resulting tag (vX.Y.Z)
#
set -euo pipefail

DRY_RUN=0
PRINT_ONLY=0
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    --print) PRINT_ONLY=1 ;;
    *) echo "Unknown argument: $arg" >&2; exit 2 ;;
  esac
done

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PUBSPEC="$ROOT_DIR/pubspec.yaml"

CURRENT_VERSION="$(grep -E '^version:' "$PUBSPEC" | sed 's/version:[[:space:]]*//' | tr -d '[:space:]')"
if [ -z "$CURRENT_VERSION" ]; then
  echo "Could not read version from pubspec.yaml" >&2
  exit 1
fi
# Strip any build metadata (e.g. 1.0.0+42) before parsing.
BASE_VERSION="${CURRENT_VERSION%%+*}"
IFS='.' read -r MAJOR MINOR PATCH <<<"$BASE_VERSION"

# Determine the commit range: from the last v* tag (exclusive) to HEAD.
LAST_TAG="$(git -C "$ROOT_DIR" describe --tags --abbrev=0 --match 'v[0-9]*.[0-9]*.[0-9]*' 2>/dev/null || true)"
if [ -n "$LAST_TAG" ]; then
  RANGE="${LAST_TAG}..HEAD"
else
  RANGE="HEAD"
fi

COMMITS="$(git -C "$ROOT_DIR" log --format='%B' "$RANGE" 2>/dev/null || true)"

if [ -z "$COMMITS" ]; then
  # No new commits since the last tag: nothing to release.
  if [ "$PRINT_ONLY" -eq 1 ]; then
    echo ""
  else
    echo "No commits since ${LAST_TAG:-the beginning}; version unchanged ($CURRENT_VERSION)."
  fi
  exit 0
fi

BUMP="patch"
if printf '%s\n' "$COMMITS" | grep -qE 'BREAKING CHANGE'; then
  BUMP="major"
elif printf '%s\n' "$COMMITS" | grep -qE '^[a-zA-Z]+(\(.+\))?!:'; then
  BUMP="major"
elif printf '%s\n' "$COMMITS" | grep -qE '^feat(\(.+\))?:'; then
  BUMP="minor"
fi

case "$BUMP" in
  major) MAJOR=$((MAJOR + 1)); MINOR=0; PATCH=0 ;;
  minor) MINOR=$((MINOR + 1)); PATCH=0 ;;
  patch) PATCH=$((PATCH + 1)) ;;
esac

NEW_VERSION="${MAJOR}.${MINOR}.${PATCH}"
NEW_TAG="v${NEW_VERSION}"

if [ "$PRINT_ONLY" -eq 1 ]; then
  echo "$NEW_TAG"
  exit 0
fi

echo "Current version : $BASE_VERSION"
echo "Last tag        : ${LAST_TAG:-<none>}"
echo "Bump type       : $BUMP"
echo "Next version    : $NEW_VERSION"

if [ "$DRY_RUN" -eq 1 ]; then
  exit 0
fi

# Preserve any +build suffix, incrementing it so every build is unique.
BUILD_SUFFIX=""
if [[ "$CURRENT_VERSION" == *"+"* ]]; then
  BUILD_NUMBER="${CURRENT_VERSION##*+}"
  BUILD_SUFFIX="+$((BUILD_NUMBER + 1))"
fi

TMP_FILE="$(mktemp)"
awk -v new="${NEW_VERSION}${BUILD_SUFFIX}" \
  '/^version:/ { print "version: " new; next } { print }' \
  "$PUBSPEC" > "$TMP_FILE"
mv "$TMP_FILE" "$PUBSPEC"

echo "$NEW_TAG"
