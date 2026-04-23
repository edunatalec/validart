#!/bin/bash
set -e

TOTAL_STEPS=5
STEP=0
step() {
  STEP=$((STEP + 1))
  echo
  echo "[$STEP/$TOTAL_STEPS] $1"
}

step "Cleaning previous coverage"
rm -rf coverage

step "Running tests with coverage"
dart test --coverage=coverage

step "Ensuring coverage CLI is installed"
if ! command -v format_coverage >/dev/null 2>&1; then
  dart pub global activate coverage
fi

step "Formatting coverage report"
format_coverage --lcov --check-ignore --in=coverage --out=coverage/lcov.info --report-on=lib

step "Generating HTML report"
genhtml -o coverage/html coverage/lcov.info

echo
echo "✅ Coverage report generated successfully!"
open coverage/html/index.html
