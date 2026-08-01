#!/bin/bash
set -e

PACKAGE=$(awk '/^name:/ {print $2; exit}' pubspec.yaml)
VERSION=$(awk '/^version:/ {print $2; exit}' pubspec.yaml)

CLI=dart
if grep -q "sdk: flutter" pubspec.yaml; then
  CLI=flutter
fi

GLOBAL_BIN=""
if command -v fvm >/dev/null 2>&1; then
  GLOBAL_BIN=$(fvm api context 2>/dev/null | grep -o '"globalCacheBinPath": *"[^"]*"' | sed -E 's/.*: *"([^"]*)"/\1/')
fi

if [ -x .fvm/flutter_sdk/bin/flutter ]; then
  PATH="$(cd .fvm/flutter_sdk/bin && pwd):$PATH"
fi

PANA_PATH="$PATH"
if [ -n "$GLOBAL_BIN" ] && [ -x "$GLOBAL_BIN/dart" ]; then
  PANA_PATH="$GLOBAL_BIN:$PATH"
fi

sdk_label() {
  echo "Dart $(dart --version 2>&1 | sed -E 's/.*version: ([0-9.]+).*/\1/')"
}

TOTAL_STEPS=9
if [ -f example/pubspec.yaml ]; then
  TOTAL_STEPS=$((TOTAL_STEPS + 1))
fi
if [ -f example/example.dart ]; then
  TOTAL_STEPS=$((TOTAL_STEPS + 1))
fi

STEP=0
step() {
  STEP=$((STEP + 1))
  echo
  echo "[$STEP/$TOTAL_STEPS] $1"
}

echo "Package checks on $(sdk_label)"
echo "pana runs on $(PATH="$PANA_PATH" sdk_label) — pub.dev scores there"

step "Installing dependencies"
$CLI pub get

step "Verifying README installation snippet matches pubspec version"
README_VERSION=$(grep -E "^\s*${PACKAGE}: \^" README.md | head -n1 | sed -E 's/.*\^([0-9]+\.[0-9]+\.[0-9]+).*/\1/')
if [ -z "$README_VERSION" ]; then
  echo
  echo "❌ Aborting: could not find '${PACKAGE}: ^X.Y.Z' in README.md."
  echo "   The Installation section must pin the current pubspec.yaml version."
  exit 1
fi
if [ "$README_VERSION" != "$VERSION" ]; then
  echo
  echo "❌ Aborting: README pins ${PACKAGE} ^${README_VERSION}, but pubspec.yaml is ${VERSION}."
  echo "   Update the README '## Installation' block to '^${VERSION}'."
  exit 1
fi

echo "README pinned at ${PACKAGE} ^${README_VERSION} ✓"

step "Verifying CHANGELOG documents the pubspec version"

CHANGELOG_ENTRY=$(grep -m1 -E '^## \[[0-9]' CHANGELOG.md)
CHANGELOG_VERSION=$(echo "$CHANGELOG_ENTRY" | sed -E 's/^## \[([^]]*)\].*/\1/')
if [ "$CHANGELOG_VERSION" != "$VERSION" ]; then
  echo
  echo "❌ Aborting: the newest released CHANGELOG entry is '${CHANGELOG_VERSION:-none}', but pubspec.yaml is ${VERSION}."
  echo "   A version bump needs its own '## [${VERSION}] - YYYY-MM-DD' entry in CHANGELOG.md."
  exit 1
fi
if ! echo "$CHANGELOG_ENTRY" | grep -qE ' - [0-9]{4}-[0-9]{2}-[0-9]{2}$'; then
  echo
  echo "❌ Aborting: the CHANGELOG entry for ${VERSION} carries no release date."
  echo "   Expected '## [${VERSION}] - YYYY-MM-DD', found '${CHANGELOG_ENTRY}'."
  exit 1
fi

echo "CHANGELOG documents ${VERSION} ✓"

step "Analyzing"
$CLI analyze

if [ -f example/pubspec.yaml ]; then
  step "Analyzing the example app"
  (cd example && $CLI pub get && $CLI analyze)
fi

step "Running tests"
$CLI test

if [ -f example/example.dart ]; then
  step "Running the example"
  dart run example/example.dart
fi

step "Verifying the examples inside the API docs"
./scripts/verify_doc_examples.sh

step "Generating API docs"
DOC_OUT=$(mktemp -d)
dart doc --output "$DOC_OUT" 2>&1 | tee /dev/stderr | grep -qE "no issues found|Found 0 warnings and 0 errors" || {
  echo
  echo "❌ Aborting: 'dart doc' reported warnings or errors."
  rm -rf "$DOC_OUT"
  exit 1
}
rm -rf "$DOC_OUT"

step "Validating package (dry-run)"
$CLI pub publish --dry-run

step "Running pana (pub.dev score)"
PANA_LATEST=$(curl -sf https://pub.dev/api/packages/pana | grep -o '"latest":{"version":"[^"]*"' | sed -E 's/.*"version":"([^"]*)".*/\1/')
if [ -z "$PANA_LATEST" ]; then
  echo
  echo "❌ Aborting: could not read the latest pana version from pub.dev."
  echo "   pub.dev scores with the latest pana, so the release pins itself to it."
  exit 1
fi

if ! ACTIVATE_OUT=$(PATH="$PANA_PATH" dart pub global activate pana "$PANA_LATEST" 2>&1); then
  echo "$ACTIVATE_OUT"
  echo
  echo "❌ Aborting: pana $PANA_LATEST does not run on $(PATH="$PANA_PATH" sdk_label)."
  echo "   Never fall back to an older pana: pub.dev scores with the latest one, so an older"
  echo "   report predicts nothing. Update the global Flutter SDK."
  exit 1
fi

echo "Using pana $PANA_LATEST"

PANA_OUT=$(GIT_ASKPASS= GIT_TERMINAL_PROMPT=0 PATH="$PANA_PATH" dart pub global run pana --no-warning . | tee /dev/stderr)
if ! grep -q "Points: 160/160" <<<"$PANA_OUT"; then
  echo
  echo "❌ Aborting: pana score is below 160/160. Fix the issues above."
  exit 1
fi

echo
echo "✅ $PACKAGE v$VERSION is release-ready"
