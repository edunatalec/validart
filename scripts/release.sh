#!/bin/bash
set -e

./scripts/verify.sh

PACKAGE=$(awk '/^name:/ {print $2; exit}' pubspec.yaml)
VERSION=$(awk '/^version:/ {print $2; exit}' pubspec.yaml)
BRANCH=$(git rev-parse --abbrev-ref HEAD)

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
git push origin "$BRANCH"
git push --tags

step "Publishing to pub.dev"
$CLI pub publish --force

echo
echo "🎉 Done! Published $PACKAGE v$VERSION"
