#!/bin/bash

echo "Running tests with coverage..."
dart run test --coverage=coverage

echo "Formatting coverage report..."
dart run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info --report-on=lib

echo "Generating HTML report..."
genhtml -o coverage/html coverage/lcov.info

echo "✅ Coverage report generated successfully!"

open coverage/html/index.html
