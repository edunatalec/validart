# Contributing

Thanks for taking the time. This document is the contract for whoever writes code here —
the `README.md` is the contract for whoever uses the package.

## Before you open a PR

One command has to be green:

```bash
./scripts/verify.sh
```

It is the same script the release runs, minus tag, push and publish: dependencies, README
version pin, the CHANGELOG entry, analyze, tests, `example/example.dart`, the examples
inside the `///` docs, `dart doc` with zero warnings, the publish dry-run, and a pana
score of 160/160. If it passes locally it passes in CI, because CI runs that file and
nothing else.

It needs network (it asks pub.dev which pana version to use) and a Dart at or above the
floor declared in `pubspec.yaml`. Running it changes your globally activated pana version —
pub.dev always scores with the newest one, so the script installs exactly that.

Two helpers sit next to it: `./scripts/coverage.sh` writes an HTML coverage report, and
`./scripts/doc.sh` regenerates the API reference and serves it over HTTP (the search box
needs `http://`, it is dead on `file://`).

## What CI checks

Two jobs, both on every pull request:

- **Verify** — `./scripts/verify.sh` on the current stable Dart.
- **Floor** — `pub get`, analyze and test on the **lowest** Dart the package supports, read
  straight from `pubspec.yaml`. It is worth less here than it would be in a Flutter package:
  the Dart SDK annotates `@Since`, so an API newer than the floor already trips
  `sdk_version_since` on the analyzer running at the top and the Verify job already fails.
  What it still catches is real — APIs that carry no annotation, dependency resolution at
  the floor, and runtime behavior — and it costs about two minutes, so it stays.

## Conventions

- **No `//` comments.** A fact that needs recording goes in the commit message, in this
  document, or in a test. Analyzer directives (`// ignore:`) are not comments and may stay.
- **`///` dartdoc is mandatory on every public member**, in English, with a runnable example
  built on the `V.` entry point. `public_member_api_docs` is enforced, and
  `scripts/verify_doc_examples.sh` compiles every ```dart fence found in `lib/`.
- **Behavior changes ship with their test.** Bug fixes start red: write the failing test
  first, watch it fail for the right reason, then fix.
- **A public-API change updates README, CHANGELOG and `example/` in the same commit.**
  New examples go in the matching `example/types/<type>.dart` or
  `example/features/<feature>.dart` — never directly in `example/example.dart`, which only
  aggregates.
- **Every test file resets global state in `setUp`.** `V` is static, so a locale set by one
  test leaks into the next: `setUp(() => V.setLocale(const VLocale()))` at the top of every
  file, plus `V.treatEmptyAsNull(false)` in files that flip that flag. The symptom of a
  missing reset is a locale assertion that fails only when the suite grows.
- **A new error code touches four places in the same commit:** the `VXxxCode` constant, its
  `VLocale` default, both README translation templates (flat and nested), and its own
  `test(...)` block in `test/src/messages/messages_test.dart`. Without the default, the
  message falls through to the raw code string and nothing else catches it.
- **Fuzz tests live in `test/fuzz/`**, tagged `@Tags(['fuzz'])`. Run them alone with
  `dart test -t fuzz`, skip them with `dart test -x fuzz`. The seed is fixed for
  reproducibility; override it with the `FUZZ_SEED` environment variable.
- **Commits are conventional and lowercase**: `feat:`, `fix:`, `chore:`, `docs:`. No body,
  no co-author trailers.

## Deliberate gaps

These are decisions, not oversights. A PR that "fixes" one of them will be declined.

- **No `optional()`, only `nullable()`.** Dart has no `undefined`, so the TypeScript
  distinction between an absent key and a null value has nothing to map onto.
- **No code generation.** `V.object<T>()` validates your existing classes through field
  extractor callbacks, checked by the compiler. There is no build runner and no generated
  file, and adding one would defeat the point.
- **No runtime dependencies.** The package resolves to itself and the SDK. A new validator
  that would need a third-party package belongs in an extension package instead.
- **Only internationally stable patterns ship as built-ins.** `phone`, `postalCode`,
  `taxId` and `licensePlate` carry US, CA and UK patterns. Country-specific ones live in
  extension packages — `validart_br` for Brazil — wired through the public `patterns:`
  parameter and the `add()` hook.
- **The source is formatted in the pre-3.7 style.** The formatter follows the language
  version, which comes from the SDK floor in `pubspec.yaml`, and that floor is Dart 3.0.
  Reformatting the package to the tall style would force the floor up to 3.7 and lock out
  every user below it, for no gain.

## Releasing

Releases are cut by the maintainer, from `master`, with `./scripts/release.sh`. It refuses
to run outside `master` or with a dirty working tree — `pub publish` packs the files on
disk, not the commit — then runs the full `verify.sh` before tagging. Nothing publishes
from CI.
