#!/bin/bash
set -e

RELEASE_BRANCH=master

BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$BRANCH" != "$RELEASE_BRANCH" ]; then
  echo "❌ Aborting: a release runs from ${RELEASE_BRANCH}, and HEAD is on ${BRANCH}."
  echo "   Publishing is irreversible, and a tag cut outside ${RELEASE_BRANCH} points at a commit no published branch carries."
  exit 1
fi

if [ -n "$(git status --porcelain)" ]; then
  echo "❌ Aborting: the working tree is not clean."
  echo "   'pub publish' packs the files on disk, not the commit — every uncommitted change would ship, unretractably."
  git status --short
  exit 1
fi

./scripts/verify.sh

PACKAGE=$(awk '/^name:/ {print $2; exit}' pubspec.yaml)
VERSION=$(awk '/^version:/ {print $2; exit}' pubspec.yaml)

CLI=dart
if grep -q "sdk: flutter" pubspec.yaml; then
  CLI=flutter
fi

TOTAL_STEPS=3
STEP=0
step() {
  STEP=$((STEP + 1))
  echo
  echo "[$STEP/$TOTAL_STEPS] $1"
}

step "Creating tag v$VERSION"
if git rev-parse "v$VERSION" >/dev/null 2>&1; then
  echo "Tag v$VERSION already exists, skipping"
else
  git tag "v$VERSION"
fi

step "Pushing"
git push origin "$RELEASE_BRANCH"
git push --tags

step "Publishing to pub.dev"
$CLI pub publish --force

echo
echo "🎉 Done! Published $PACKAGE v$VERSION"
