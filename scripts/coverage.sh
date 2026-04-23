#!/bin/bash
set -e

echo "Cleaning previous coverage..."
rm -rf coverage

echo "Running tests with coverage..."
dart test --coverage=coverage

echo "Ensuring coverage CLI is installed..."
if ! command -v format_coverage >/dev/null 2>&1; then
  dart pub global activate coverage
fi

echo "Formatting coverage report..."
format_coverage --lcov --check-ignore --in=coverage --out=coverage/lcov.info --report-on=lib

echo "Generating HTML report..."
genhtml -o coverage/html coverage/lcov.info

echo "✅ Coverage report generated successfully!"
open coverage/html/index.html
