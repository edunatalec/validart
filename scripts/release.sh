#!/bin/bash
set -e

TOTAL_STEPS=8
STEP=0
step() {
  STEP=$((STEP + 1))
  echo
  echo "[$STEP/$TOTAL_STEPS] $1"
}

step "Installing dependencies"
dart pub get

step "Running tests"
dart test

step "Running example"
dart run example/example.dart

step "Validating package (dry-run)"
dart pub publish --dry-run

step "Running pana (pub.dev score)"
pana --no-warning .

VERSION=$(grep '^version:' pubspec.yaml | awk '{print $2}')

step "Creating tag v$VERSION"
if git rev-parse "v$VERSION" >/dev/null 2>&1; then
  echo "Tag v$VERSION already exists, skipping"
else
  git tag "v$VERSION"
fi

step "Pushing"
git push origin master
git push --tags

step "Publishing to pub.dev"
dart pub publish --force

echo
echo "🎉 Done! Published v$VERSION"
