# Changelog

## [3.0.2] - 2026-08-01

### Added

- `CONTRIBUTING.md` now ships in the published archive, which is what makes pub.dev show the "Contributing" link in the package sidebar.

### Changed

- API reference: every symbol cited in prose is now a link, each public type ends with a `See also:` block, and the library page walks through the schema pipeline instead of restating the description.
- API reference grouped into Core, Types, Containers, Internationalization and Extensibility, each with its own topic page — the public surface no longer renders as one flat alphabetical list.
- README follows the skeleton shared by the published packages: `## Contents` lists only what comes after it, the pitch became `## Why validart`, Requirements states the command that checks the SDK, and a new `## Example` section points at the runnable tour.
- Dev dependency bounds loosened (`lints`, `test`) so the package resolves on the declared SDK floor, which CI now analyzes and tests on every pull request.
- README gained a `## Contributing` section, and links to repository files are now absolute. A relative link is rewritten to GitHub on the package page but left untouched in the generated API reference, where it resolved to a 404.

## [3.0.1] - 2026-07-28

### Changed

- Adopted the stricter shared analysis options (strict casts, plus async, import, immutability and bug-prone lints); source, tests and examples adjusted to the new rules — no behavior change.

## [3.0.0] - 2026-05-17

### Added

- **`VObject<T>.safeParseRaw` / `parseRaw` / `validateRaw` / `errorsRaw` (and async siblings).** Validate a `Map<String, dynamic>` directly against an object schema without first constructing `T`. Each declared field is read by name (`map[field.name]`); per-field validators, transforms, `when` rules, `whenMatchesRaw` rules, `refineFieldRaw` rules, `strict`, and `passthrough` apply. Returns the validated map — caller constructs `T` afterwards with the guarantee that every required field is present. Motivation: when `T`'s constructor rejects null on a required field, building it for a partial payload throws before any validator can run; `safeParseRaw` removes the friction. Entity-level rules typed against `T` (`refine`, `refineField`, `equalFields`) and entity-level transforms are silently skipped — pass the validated map through `T`'s constructor and revalidate with `safeParse(T)` when those rules matter. Schemas declaring `whenMatches` (entity-only) throw `VException` at the `safeParseRaw` entry point — use `whenMatchesRaw` instead. `defaultValue` is a no-op (typed as `T?`, cannot substitute into `Map`); `nullable()` is honored. Pinned by `test/src/types/object_raw_test.dart` and the new `VObject.safeParseRaw contract` group in `pipeline_contract_test.dart`.
- **`VObject<T>.strict()` / `.passthrough()`** — previously unavailable on `VObject`, now exposed with documented semantics. No-op in entity mode (declared fields are read through extractors, so unknown keys cannot arrive). Active in raw mode: `strict()` emits `object.unrecognized_key` for every key not declared on the schema; `passthrough()` copies non-declared keys through to the validated map. Mirrors `VMap.strict()` / `passthrough()`. State propagates through `pick` / `omit` / `merge` / `partial` (via `_copyObjectStateTo`).
- **`VObjectCode.unrecognizedKey`** (`'object.unrecognized_key'`) — emitted by `safeParseRaw` on a `VObject` marked `.strict()` for each undeclared key. Default template: `'Unrecognized key "{key}"'`. Customizable globally via `VLocale({'object.unrecognized_key': '...'})` or per-call. Pinned by the regression group in `test/src/messages/messages_test.dart::VObjectCode`.
- **`RefineStage` enum (`post` / `pre`)** — controls when a `refineField` / `refineFieldRaw` callback runs in the container pipeline. `post` (default) runs after per-field iteration and is gated by `dependsOn`; `pre` runs before per-field iteration and sees the input as the user typed it (no preprocess / transforms applied). Exported from `package:validart/validart.dart`.
- **`V.date()` calendar helpers** — `isToday()`, `sameDayAs(DateTime other)`, `afterToday()`, `beforeToday()`. Compare only y/m/d (hour/minute/second ignored), resolved against `DateTime.now()` in local time at validation time. `isToday` / `sameDayAs` accept exact-day matches; `afterToday` / `beforeToday` are **strict** (today itself is rejected — compose with `isToday` via `VUnion` for "today or later" / "today or earlier"). New codes `VDateCode.isToday` / `sameDay` / `afterToday` / `beforeToday` with default templates `'Must be today'` / `'Must be the same day as {date}'` / `'Must be after today'` / `'Must be before today'`. Pinned by `test/src/types/date_test.dart` (4 new groups) and the `VDateCode` regression in `test/src/messages/messages_test.dart`.
- **`V.string().treatEmptyAsNull({bool enabled = true})` + `V.treatEmptyAsNull(bool)` (global setter).** Normalizes `""` (string vazia exata, sem trim) para `null` antes do pipeline da string, deixando `nullable()` / `defaultValue()` tratarem como missing. Default global é `false` (opt-in, não-breaking). Setting local sobrepõe o global por instância — útil para opt-out em um campo específico quando o global está ativo. Roda antes de qualquer `.preprocess()` do user. Whitespace-only não é afetado (compõe com `.trim()` se quiser). Casos típicos: forms em que o input vazio significa "não preenchido" (alinhando com `valiform`). Pinned por `test/src/types/string_test.dart::treatEmptyAsNull` (11 casos) e chain assertion em `fluent_chain_test.dart`. **Convenção do projeto**: tests que ligam o global devem resetar `V.treatEmptyAsNull(false)` em `setUp` — mesma higiene do locale.
- **`VObject<T>.whenMatchesRaw((Map<String, dynamic>) => bool, dependsOn:, then:)`** — universal sibling of `whenMatches`, callback receives the raw map view of the input (rebuilt lazily from extractors in entity mode, passed through directly in raw mode). Use when the schema needs to support both `safeParse(T)` and `safeParseRaw(Map)` (the typical `valiform` setup). Same skip semantics + non-empty `dependsOn` contract as `whenMatches`.
- **`VObject<T>.refineFieldRaw((Map<String, dynamic>) => bool, path:, {stage, dependsOn})`** — universal field-scoped refine; callback receives the map view. Mirror of `refineField` for use cases that consume both entity and raw modes. `stage: RefineStage.post` (default) gates on `dependsOn`; `stage: RefineStage.pre` runs unconditionally. New `_ObjectRawFieldRule` storage on VObject; previously the slot was occupied by an entity-typed `refineFieldRaw` that has been promoted to a `stage:` parameter on `refineField` (see Changed below).

### Changed

- **Breaking — old `VObject.refineFieldRaw((T) => bool, path:)` removed; same behavior now expressed as `refineField(check, path:, stage: RefineStage.pre)`.** The slot `refineFieldRaw` is now occupied by a new Map-typed universal variant (see Added). **Migration:** `obj.refineFieldRaw((t) => check(t), path: 'x')` → `obj.refineField((t) => check(t), path: 'x', stage: RefineStage.pre)`. Same for `VMap.refineFieldRaw` — removed and replaced by `refineField((m) => ..., path:, stage: RefineStage.pre)`. The pre-pipeline timing semantics are preserved; only the entry point name and the new `stage:` parameter are different. Pinned by `test/src/features_test.dart::refineField stages (post vs pre)`.
- **Breaking — `whenMatches` (on `VMap` and `VObject`) now skips when a declared `dependsOn` field failed per-field validation.** Previously the predicate was always called even when its declared dependencies had failed, leaving the callback responsible for defending against partial / wrong-typed input. The rule now follows the same gating as `refine(dependsOn:)`: if any key in `dependsOn` shows up in `failedFieldPaths`, the predicate is not called and the entire `then` block is not applied — protects the callback from casting a value that never passed its own validator. Side effect: `dependsOn` must now be **non-empty** (an `AssertionError` fires at construction otherwise). Use plain `refine()` / `add()` for rules that should always run regardless of field outcomes. Pinned by new tests in `test/src/types/{map,object,object_raw}_test.dart`.
- **Breaking — `refineField` on `VMap` and `VObject` now unions `dependsOn` with `{path}` and rejects an empty set.** Previously, passing `dependsOn: {a, b}` *replaced* the implicit `{path}`, which let callers accidentally drop their own path from the skip set and reach a callback whose `path`-typed field had failed its own validator (cast crashes in `VMap`; logically-stale reads in `VObject`). The path is now always part of the effective deps; you only declare the *extra* fields the callback reads. `dependsOn: const {}` triggers an `AssertionError` at construction — a refineField that should run regardless of field failures is a `refineField(stage: RefineStage.pre)` (raw input, runs before per-field) or a plain `refine(dependsOn: const {})` (entity-level, runs after per-field). **Migration:** if your code used `dependsOn: {path, extraA, extraB}`, you can simplify to `dependsOn: {extraA, extraB}`. Pinned by `test/src/features_test.dart::refineField — dependsOn override`.

### Fixed

- **`whenMatchesRaw` (entity mode) was using a stale `failedFieldPaths` snapshot.** The set of failed fields was computed before the `_whenMatchesRules` loop and reused for the subsequent `_whenMatchesRawRules` loop — meaning a `whenMatchesRaw` rule whose `dependsOn` referenced a field that failed via an earlier `whenMatches.then` would not skip as documented. Now recomputed via `_firstSegments(errors)` between the two loops in both `safeParse` and `safeParseAsync`. Pinned by `test/src/types/object_test.dart::whenMatchesRaw — entity mode::skips when whenMatches.then fails a declared dep field`.

## [2.2.0] - 2026-05-08

### Added

- **`VMap.partial({except})` and `VObject<T>.partial({except})`** — opt-in exception list on the existing `partial()` method. With no argument the behavior is unchanged (every field becomes nullable). Passing `except: ['id']` keeps the listed keys with their original validator while every other field gets wrapped to accept `null` — the canonical pattern for an update DTO that retains a required identifier (`id`, `slug`, etc.). Keys must be declared on the schema; otherwise an `AssertionError` fires in debug, mirroring the assert behavior of `refine(dependsOn:)`. Pipeline state (entity-level rules, `when` / `whenMatches`, preprocessors, `nullable`, `defaultValue`) is preserved exactly like the no-argument variant.

### Fixed

- **`partial()` now mirrors `.nullable()` semantics for fields with `defaultValue` or inner `nullable`.** The internal `_NullableWrapper` previously short-circuited on `null` input and returned `VSuccess(null)` without consulting the inner schema's null handling, so any `defaultValue` declared on a wrapped field was silently dropped — `V.map({'k': V.string().defaultValue('x')}).partial().parse({'k': null})` produced `{'k': null}` instead of the `{'k': 'x'}` you would get from manually applying `.nullable()`. The wrapper now delegates to the inner schema whenever it has its own null handling (`_hasDefault` or `_isNullable`), so default substitution and the inner nullable short-circuit run as documented; only when the inner is strict does the wrapper itself absorb the null. `hasAsync` now also delegates to the inner so async pipelines on a partial-wrapped field are detected by sync consumers (`safeParse` throws `VAsyncRequiredException`). Pinned by new tests under `partial` in `test/src/types/{map,object}_test.dart`.

## [2.1.0] - 2026-05-01

### Changed

- **`V.string().url()` accepts `schemes: const {}` (scheme-optional mode) and `hostOnly: true` (reject path/query/fragment).** Default behavior is unchanged: `schemes: null` keeps the existing `{http, https}`-required validation. Passing `schemes: const {}` makes the scheme optional — bare hosts (`google.com`, `www.google.com`, `localhost:8080`) and any well-formed `scheme://host` (`https://x.com`, `ftp://x.com`) both pass. Independently, `hostOnly: true` rejects anything past the host:port, useful for "domain field" inputs that should never accept a path. Host validation also tightened across all modes: standard labels separated by dots with a TLD of 2+ alphabetic characters, OR the literal `localhost`, plus an optional `:port`. The previous regex (`[^\\s/$.?#].[^\\s]*`) accepted hosts like `_under_score.x` and `-leading.com` that no DNS resolver would accept; those now correctly fail.

### Added

- **`V.string().domain()`** — shortcut for "host only, no scheme, no path". Accepts bare domains (`google.com`, `www.example.com`, `api.v2.example.co.uk`), `localhost`, and optional `:port`; rejects scheme prefixes (`https://google.com`), path / query / fragment (`google.com/foo`, `google.com?x=1`), and malformed hosts. Emits its own error code `VStringCode.domain` (`'string.domain'` → `'Invalid domain'`) so the message matches the user's intent — for full URLs, keep using `.url(...)`. Implemented as `DomainValidator` delegating to `UrlValidator(schemes: const {}, hostOnly: true)` plus an early-return that rejects any input containing `://`.
- **`VArray<T>.distinct(by:)`** — uniqueness by an extracted key. Use it for arrays of `Map` / class instances where `==` on the elements themselves is meaningless. The `by` extractor is required (without one, use `.unique()`); duplicates are detected by collecting `by(elem)` into a `Set`. Emits the same error code as `unique()` (`array.unique`) since the failure mode is identical. Inspired by `lodash.uniqBy` and SQL `DISTINCT`.
- **`VObject<T>.partial()`** — mirrors `VMap.partial()`. Returns a new `VObject<T>` where every declared field's validator is wrapped so `null` is accepted in addition to the original shape; non-null inputs still run the original validator. Preserves all pipeline state (entity-level rules, `when` / `whenMatches`, preprocessors, `nullable`, `defaultValue`). Useful for partial-update DTOs where the type still has every field but only a subset is required at the API boundary, removing the need to sprinkle `.nullable()` on every `field(...)` call. The README note that previously said `partial()` was unavailable on `VObject` was rewritten — `strict()` and `passthrough()` remain unavailable (they assume a runtime-shapeable container, which `VObject<T>` is not).
- **`VObject<T>.fieldIf(condition, name, extractor, validator)`** — same as `field(...)` when `condition` is `true`, no-op otherwise. Lets the fluent chain stay unbroken when declaring a field is conditional on a flag known at the call site (feature toggle, request context, partial-update DTO). VMap doesn't need an equivalent because Dart map literals already accept `if (cond) 'key': validator`.
- **`VMap.whenMatches(condition, dependsOn:, then:)` and `VObject<T>.whenMatches(condition, dependsOn:, then:)`** — predicate-based conditional validation, sibling of the existing `when(field, equals:, then:)` (which is left untouched). Use it when a single literal `equals` is not enough: the trigger depends on a comparison other than `==` (`>`, `oneOf`, ...) or on the combined value of multiple fields. The predicate receives the raw input (`Map<String, dynamic>` for `VMap`, `T` for `VObject<T>`) and runs at the same pipeline step as `when` — failures inside `then` contribute to `failedFieldPaths` and gate later `refine(dependsOn:)` rules. `dependsOn` is required (forces explicit declaration of the fields the predicate reads, so `_knownKeys()` can validate them and downstream `refine(dependsOn:)` keeps working). The predicate itself is always synchronous; validators inside `then` may be sync or async — a `whenMatches` whose `then` contains an async validator opts the schema into async mode (`hasAsync == true`). VObject is strict (every key in `dependsOn` and `then` must already be declared via `.field(...)`); VMap follows the same liberal rule as `when` for `then` keys (they enter `_knownKeys` automatically, so subsequent `refine(dependsOn: {<thatKey>})` works without further setup). Read-only snapshot exposed via `whenMatchesRules` getter on both types. Pinned by `pipeline_contract_test.dart::whenMatches contract`.
- **`applyIf(condition, builder)` extension on every `VType`.** Conditional schema construction at **build time** (not at validation time): when `condition` is `true`, returns `builder(this)`; otherwise returns the receiver unchanged. The generic `<V extends VType>` preserves the receiver's concrete type, so the fluent chain keeps working (`V.string().applyIf(...).email()` still returns `VString`). Designed for parametrizing schemas from external flags (a feature toggle, a request context) without duplicating the schema body. For an else-branch, chain a second `applyIf` with the negated condition. Lives in `lib/src/extensions/apply_if.dart`, exported from `package:validart/validart.dart`.

## [2.0.0] - 2026-04-25

### Fixed

- **`preprocess(...)` / `preprocessAsync(...)` now actually run on every container type.** All container schemas — `VMap`, `VArray`, `VObject`, `VEnum`, `VLiteral`, `VUnion`, `VTransformed` (and its async counterpart `VTransformedAsync`) — previously overrode `safeParse` / `safeParseAsync` without invoking the base-class preprocess loop, silently dropping any `.preprocess(fn)` / `.preprocessAsync(fn)` registered on them. Only primitives (`VString`, `VInt`, `VDouble`, `VBool`, `VDate`) ever honored preprocessors. Every container now applies sync and async preprocessors before `_resolveNull`, so `V.map({...}).preprocess((raw) => normalize(raw))` and every analogous call transforms the input exactly like it does on primitives. Regression tests were added in `test/src/types/{map,array,enum,literal,union,object}_test.dart` and `test/src/features_test.dart` so the bug cannot return silently.
- **`refine(...)` now runs on `VLiteral`, `VUnion` and `VTransformed` / `VTransformedAsync`.** Each of these overrode `safeParse` and returned `VSuccess(value)` directly on match instead of routing through `_runPipeline(value)`, so any `.refine(fn)` / `.refineAsync(fn)` step was silently dropped. The overrides now delegate the final success path to `_runPipeline` (or `_runPipelineAsync`), which also makes `add()` custom validators and chained transforms downstream of the fix work as documented.
- **`VTransformed<I, O>` and `VTransformedAsync<I, O>` honor their own `nullable()` / `defaultValue(O)`.** Previously the wrappers only consulted the inner schema's null-handling, so `V.string().transform<int>((s) => s.length).defaultValue(0).parse(null)` failed with `string.invalid_type` because `0` was forwarded to the inner `VString`. The wrappers now short-circuit on null input when `_hasDefault` or `_isNullable` is set on the wrapper itself — default goes through `_runPipeline` as the transformed output `O`, and nullable returns `VSuccess<O?>(null)` directly. Inner-nullable behavior (`.nullable().transformAsync(...)`) is preserved because the wrapper still delegates when it has no own null-handling set.
- **Pipeline contract test suite (`test/src/pipeline_contract_test.dart`).** Iterates every concrete `VType` subclass and asserts that `preprocess`, `preprocessAsync`, `refine`, `refineAsync`, `nullable()`, `defaultValue()` and the combination of all of them behave correctly. Adding a new `VType` subclass now requires one call to `_runPipelineContract<T>(...)` — a subclass that forgets to run the base-class preprocess loop (or to route success through `_runPipeline`) fails the contract immediately.
- **`VMap.partial()` now preserves pipeline state from the base schema.** It previously built a fresh `VMap(partialSchema)` from scratch, silently dropping any `refine` / `equalFields` / `refineField` / `add` / `when` / `strict` / `passthrough` / `nullable` / `defaultValue` / preprocessor declared before the call — diverging from `extend` / `merge` / `pick` / `omit`, which all carry those over via `_copyMapStateTo`. `partial()` now does the same, so a base schema's entity-level rules survive the conversion to a patch schema. Pinned by `test/src/integration_scenarios_test.dart::partial() + dependsOn`.
- **Entity-level validators with declared field dependencies now run even when unrelated fields fail.** `equalFields(a, b)` (declares `{a, b}`) and `refineField(check, path: 'x')` (declares `{x}`) previously short-circuited if any field had errors; they now run as long as their declared dependencies passed, and their result is aggregated alongside field errors in a single `VFailure`. Generic `refine(check)` without `dependsOn` keeps the conservative behavior — it still skips when any field error exists, since it lacks the metadata to know which fields it depends on. `VArray.refine` is unchanged (`VArray` does not have entity-level dependencies). `when` rules continue to be evaluated as part of field-level validation.
- **`VEnum.safeParse` and `VLiteral.safeParse` now throw `VAsyncRequiredException` when the schema has any async step.** Previously, both overrides skipped the `hasAsync` gate that every other container honors, so calling `validate` / `parse` (sync) on `V.enm(Color.values).refineAsync(...)` or `V.literal('admin').preprocessAsync(...)` silently ran only the sync portion of the pipeline — `_runPipeline` does not iterate `_AsyncValidatorStep`, so the async refine was dropped on the floor and the schema returned `true`/`VSuccess` regardless. The gate now fires consistently across `VString` / `VInt` / `VDouble` / `VBool` / `VDate` / `VArray` / `VMap` / `VObject` / `VUnion` / `VTransformed` / `VEnum` / `VLiteral`, and the new `pipeline_contract_test.dart` cases for `runPreprocessors` exercise the path on every concrete `VType`.

### Added

- **`VFailure.rootMessages()`** — returns the messages of every error with an empty `path` (root-level errors, typically emitted by `refine` / `equalFields` applied directly on a schema root). `toMap()` is field-keyed and intentionally excludes those errors so they cannot leak into a UI's per-field display under a fake key; `rootMessages()` is the explicit channel for retrieving them as a `List<String>` to render in a form-wide banner. The two methods partition the errors cleanly: every error appears in exactly one of `toMap()` or `rootMessages()`. Documented in the README under _Form Errors → Root-level errors via `rootMessages()`_.
- **`refine(check, dependsOn: {'a', 'b'})` on `VMap` and `VObject`.** Optional parameter that declares which schema field keys this refine depends on. When provided, the refine skips only if one of those specific keys failed validation, and runs (aggregating its error with the field errors) otherwise. Without `dependsOn`, the existing conservative behavior is preserved (skip on any field error). `dependsOn` accepts any field declared in the base schema **or** in any `when.then` block; an `AssertionError` is thrown for unknown keys. Same parameter on `refineAsync`. Built-in `equalFields` and `refineField` use this internally to declare their dependencies (`{a, b}` and `{path}` respectively), so they automatically aggregate alongside unrelated field errors. The internal `add(validator, dependsOn:)` parameter is also exposed so external packages can plug in custom entity-level validators with declared deps.
- **`VObject<T>.array()`** — fluent helper that returns `VArray<T>`, mirroring `VMap.array()`. Enables `SignInDto.schema.array().min(1).unique()` for `List<T>` validation without breaking the chain.
- **`VObject<T>.equalFields(fieldA, fieldB, {message})`** — cross-field equality check, mirroring `VMap.equalFields`. Canonical use case is DTO password confirmation. Emits the new error code `VObjectCode.fieldsNotEqual` (`'object.fields_not_equal'`) with default template `'{field} must be equal to {other}'`, customizable per-call via `message:` or globally via `VLocale({'object.fields_not_equal': '...'})`. Throws `AssertionError` if either field name is not declared on the schema (uniform across all entity-level rules: `equalFields`, `refineField`, `refine(dependsOn:)`). Backed by a new internal `ObjectEqualFieldsValidator<T>`.
- **`VObject<T>.when(field, equals:, then:)`** — conditional validation, mirroring `VMap.when`. When the value read from `field` equals `equals`, every validator in `then` is applied to the corresponding field in addition to its baseline validator. Asserts that `field` and every key in `then` are declared on the schema. Propagates through `hasAsync` and `safeParseAsync` when any `then` validator is async.
- **`VObject<T>.refineField(check, path:, message:)`** — entity-level predicate scoped to a specific field path. The `check` receives the whole `T` instance (so it can compare across fields), and the emitted error's `path` is `[path]`. Mirrors `VMap.refineField` but without the string-keyed lookup.
- **`VObject<T>.pick(List<String>)` / `.omit(List<String>)`** — derive a new schema containing only / excluding the specified fields. Preserves all pipeline state (validator steps, `when` rules, preprocessors, `nullable`, `defaultValue`). Unlike TypeScript, the input type stays `T` — only the validation surface is narrowed; this is not a subset _type_. For partial/dynamic payloads, use `VMap.partial()` instead.
- **`VObject<T>.merge(VObject<T> other)`** — combine two schemas of the same `T` into a new one. Fields and pipeline state (validator steps, `when` rules, preprocessors, `nullable`, `defaultValue`) from both sides are concatenated/OR-ed. Useful for composing shared `audit`/`meta` field groups with domain-specific schemas.
- **`VType.runPreprocessors(value)` / `runPreprocessorsAsync(value)`** — public accessors to the preprocess stage of any schema, returning the value after the preprocess chain ran (sync chain only for `runPreprocessors`; sync + async, in registration order, for the async variant). Does NOT run `_resolveNull`, validators, or transforms — only the preprocess stage. Sync variant throws `VAsyncRequiredException` when the schema has any async preprocessor. Useful for downstream consumers (e.g. `valiform`) that need to mirror the container preprocess in their own scoped pipeline before running per-field checks. Every concrete container (`VType`, `VMap`, `VObject`, `VArray`, `VUnion`, `VTransformed`, `VTransformedAsync`, `VEnum`, `VLiteral`) was refactored to use these methods internally for their `safeParse` / `safeParseAsync` preprocess stage — behaviour is identical to before, only the duplicated loop is gone. Pinned by `test/src/pipeline_contract_test.dart`, which now asserts both methods on every concrete `VType`.
- **`VType.hasPreprocessors`** — `true` when the schema has at least one preprocessor registered (sync or async). Lets consumers gate the preprocess plumbing on actually-needed work; `valiform`'s per-field validator uses it to skip snapshot construction entirely on schemas without container preprocess.
- **`VMap.refineFieldRaw(check, {path, message})` and `VObject<T>.refineFieldRaw(check, {path, message})`** — entity-level rules scoped to a field path that run **before** any per-field iteration. The callback receives the raw input (`Map<String, dynamic>` for `VMap`, `T` for `VObject<T>`) — each field still as it arrived from the input, no field-level preprocess / validators / transforms applied yet. Compare with `refineField`, whose callback runs after the full per-field pipeline (and whose `dependsOn` is implicitly `{path}`); `refineFieldRaw` has no `dependsOn` because no field has been validated yet, so it always runs once the type check succeeds. Error path is `[path]` (mirrors `refineField`) so consumers like `valiform`'s `VForm` surface it inline under the target field. Use `refineFieldRaw` when the rule depends on the input as the user typed it (raw casing, whitespace, pre-coercion shape); reach for `refineField` for everything else. Backed by a new `_RawValidatorStep<T>` and a public `VType.addRaw(...)` low-level API. Documented in README → Cross-Field Validation.
- **Factory-level `invalidTypeMessage:` parameter.** Every factory (`V.string()`, `V.int()`, `V.bool()`, `V.date()`, `V.map()`, `V.array()`, `V.object()`, `V.enm()`, `V.literal()`, `V.union()`) now accepts an optional `invalidTypeMessage:` that customizes the `invalid_type` error fired when input is non-null but has the wrong runtime type (e.g. `42` against `V.string()`). It coexists with the existing `message:` (which still scopes only to the `required` error on `null` input) — set one, the other, or both. Mirrors Zod's `required_error` / `invalid_type_error` separation; `required` is typically a user-facing label, `invalid_type` is a developer-facing signal, so keeping the channels separate avoids one polluting the other. The error code is unchanged (`string.invalid_type`, `int.invalid_type`, ...); only the message text is replaced when set. Without `invalidTypeMessage:`, the locale template `'Expected {expected}, received {received}'` is preserved verbatim. `VEnum` and `VLiteral` accept the parameter for API uniformity but the override never fires there — they emit `enum.invalid` / `literal.invalid` codes instead of `invalid_type`.

### Changed

- **Breaking — `VObject` now uses a fluent `.field()` API instead of the `configure:` callback builder.** The `VObjectBuilder<T>` class and the `configure:` named parameter on both `V.object<T>(...)` and `VObject<T>(...)` were removed. Field extractors are now chained directly on the schema with the same `.field(name, extractor, validator)` signature, identical to the rest of the library (`V.string().email().min(5)`). Before: `V.object<User>(configure: (o) => o.field('name', (u) => u.name, V.string()).field('age', (u) => u.age, V.int()));` After: `V.object<User>().field('name', (u) => u.name, V.string()).field('age', (u) => u.age, V.int());`. **Migration:** drop `configure: (o) =>` and the `o.` prefix — the rest of the chain is unchanged. Enables the `static final` DTO pattern: `class SignInDto { static final schema = V.object<SignInDto>().field(...).field(...); }`, so the schema is built once per isolate and reused without re-wrapping it in `V.object<X>(...)` at every call site.

## [1.3.0] - 2026-04-23

### Added

- **`V.coerce.date()` now accepts the same default formats as `V.string().date()`** — ISO 8601 (`YYYY-MM-DD` and variants with time), BR (`DD/MM/YYYY`), US (`MM/DD/YYYY`), EU (`DD.MM.YYYY`), dashed (`DD-MM-YYYY`, `MM-DD-YYYY`), compact (`YYYYMMDD`), slashed (`YYYY/MM/DD`). Calendar-invalid dates (like `30/02/2024`) continue to throw. Parsing logic moved to a shared helper (`lib/src/utils/date_parser.dart`) used by both `DateStringValidator` and `VCoerce.date()`. For strict format validation, chain `V.string().date(format: '...')` before coercion.

### Changed

- **Breaking — `V.string().phone()` / `.postalCode()` / `.taxId()` / `.licensePlate()` now accept a list of patterns.** The parameter was renamed from `pattern:` (single `Pattern`) to `patterns:` (non-empty `List<Pattern>`), and validation succeeds when **any** pattern in the list matches — enabling multi-country systems to declare every accepted format in a single schema instead of wrapping multiple schemas in `V.union([...])`. `V.string().phone()` with no argument continues to default to a single `E164PhonePattern` (behavior unchanged). **Migration:** wrap any existing single pattern in a list — `pattern: const UsZipPattern()` → `patterns: [const UsZipPattern()]`. For phone, the emitted error code keeps each pattern's custom `code` when exactly one pattern is configured; with two or more, the generic `VStringCode.phone` is emitted. For postal code / tax ID / license plate, the `{name}` interpolation param now joins each pattern's `name` with `/` when multiple are configured — a single template like `'Invalid {name}'` renders correctly in both single- and multi-pattern mode.
- **Breaking — all error codes are now domain-prefixed.** Every string emitted by `error.code` follows `<type>.<action>` (e.g. `string.email`, `number.positive`, `int.even`, `bool.is_true`, `date.weekday`, `array.unique`, `enum.invalid`). The three generic fallbacks (`required`, `invalid_type`, `custom`) stay flat in `VCode` — `VLocale` uses them as the backstop when a prefixed key has no match. Constants in the sealed classes keep the same identifiers (`VStringCode.email`, `VIntCode.even`, `VDoubleCode.integer`, etc.); only the string value each one maps to changed. **Migration:** find-and-replace the old flat codes in `VLocale` configurations and in any `error.code == '...'` comparisons. Highlights: `'invalid_email'` → `'string.email'`, `'positive'` → `'number.positive'`, `'even'` → `'int.even'`, `'decimal'` → `'double.decimal'`, `'is_true'` → `'bool.is_true'`, `'weekday'` → `'date.weekday'`, `'unique'` → `'array.unique'`, `'invalid_enum'` → `'enum.invalid'`. Complete mapping table in README.
- **`VLocale._defaults` is now structured as a nested map** grouping each type's translations (`'string': {'email': '...', 'too_small': '...'}`). Default behavior unchanged — the `_resolve` fallback chain already works with flat or nested lookups. This is purely a readability improvement for maintainers; custom translations can still use either form.

### Fixed

- **Missing default locale templates for 14 emitted codes.** The codes `string.base64`, `string.cvv`, `string.hex_color`, `string.iban`, `string.json`, `string.mac`, `string.mongo_id`, `string.nano_id`, `string.semver`, `string.ulid`, `date.age`, `string.postal_code`, `string.tax_id` and `string.license_plate` were emitted by their validators but had no matching entry in `VLocale._defaults`, so `error.message` fell through to the raw code string (e.g. `"string.base64"` instead of `"Invalid Base64"`). The default templates already documented in the README are now actually registered in `VLocale`. A regression test in `test/src/messages/messages_test.dart` (`'Every emitted VCode has a default translation'`) iterates every `VXxxCode` constant and asserts a non-code default exists, so any new code added without a matching locale entry fails the suite immediately.
- **Invalid SIN example in README and `example/example.dart`.** The sample `V.string().taxId(patterns: [const CaSinPattern()]).validate('046-454-286')` was commented `// true`, but SINs starting with `0` are forbidden by CRA specification — the actual output is `false`. Replaced with `130-692-544` (a Luhn-valid SIN starting with a legal leading digit). All README examples with `// result` comments were re-verified against real output after the change.

## [1.2.0] - 2026-04-23

### Added

- **`ValidationMode` enum** (`any` / `formatted` / `unformatted`) — controls whether separator-based formatting is required, forbidden, or optional on validators that accept multiple input shapes. Exported from `package:validart/validart.dart`.
- **`mode` field on `UsSsnPattern`, `UkNiNumberPattern`, `CaSinPattern`** — SSN, NINO and SIN patterns now accept a `ValidationMode`. Default `any` keeps the current behavior (modulo the change noted below for SSN).
- **`mode` field on `CaPostalCodePattern`, `UkPostcodePattern`** — Canadian and UK postal codes can now require or forbid the separating space.
- **`mode` field on `UkPlatePattern`** — UK plates can now require or forbid the space between the two groups.
- **`mode` parameter on `VString.card()`** — `V.string().card(mode: ValidationMode.formatted)` requires groups of four separated by spaces/dashes; `ValidationMode.unformatted` rejects any non-digit; `ValidationMode.any` (default) keeps the current behavior.
- **`CountryCodeFormat` enum** (`required` / `optional` / `none`) and `countryCode` field on `E164PhonePattern` — pin whether the leading `+` must be present, optional (default), or forbidden. Exported from `package:validart/validart.dart`.
- **`VString.integer()` / `VString.numeric()`** — validate that a string is parseable as a Dart `int` (decimal base) or a finite `double` (accepts decimal and scientific notation, rejects `NaN`/`Infinity`). Both keep the output type as `String`; use `V.coerce.int()` / `V.coerce.double()` when you want conversion instead. New error codes `VCode.stringInteger` (`string.integer`) and `VCode.stringNumeric` (`string.numeric`) — domain-prefixed so they can be translated independently of `VCode.integer` (used by `VDouble.integer()`).
- **README i18n reference** — new "Complete translation template" section in the i18n docs listing every translatable key with its default English message (including the new type-prefixed `required`/`invalid_type` entries and all interpolation tokens), ready to copy into a `VLocale` and translate.

### Changed

- **Breaking — Type-prefixed error codes for `required` and `invalid_type`.** Every schema now emits its own prefixed code: `VString` → `string.required` / `string.invalid_type`, `VInt` → `int.required` / `int.invalid_type`, and so on for `VDouble`, `VBool`, `VDate`, `VArray`, `VMap`, `VObject`, `VEnum`, `VLiteral`, `VUnion`. The generic codes (`'required'`, `'invalid_type'`) are no longer emitted at runtime but remain defined in `VCode` as fallback keys for translation. Code that compares `error.code == 'required'` must be updated to check the prefixed form or use `.endsWith('.required')`.
- **Breaking — `VCode` reorganized into sealed classes per type.** The 60+ flat constants (`VCode.stringRequired`, `VCode.invalidEmail`, `VCode.positive`, `VCode.even`, ...) were replaced by 12 companion `sealed class`es — `VStringCode`, `VNumberCode`, `VIntCode`, `VDoubleCode`, `VBoolCode`, `VDateCode`, `VArrayCode`, `VMapCode`, `VObjectCode`, `VEnumCode`, `VLiteralCode`, `VUnionCode`. `VCode` itself now holds only the generic fallbacks (`required`, `invalidType`, `custom`). Migration is a mechanical rename — the **strings emitted** in `error.code` and the keys used by `VLocale` stay identical. Examples: `VCode.stringRequired` → `VStringCode.required`, `VCode.invalidEmail` → `VStringCode.email`, `VCode.positive` → `VNumberCode.positive`, `VCode.even` → `VIntCode.even`, `VCode.age` → `VDateCode.age`, `VCode.invalidEnum` → `VEnumCode.invalid`.
- **`VLocale` now accepts nested overrides and falls back to the generic code.** Entries can be flat (`'string.required': '...'`) or nested (`'string': {'required': '...'}`), mixed in the same map. When a prefixed code has no match, lookup drops the prefix and tries the generic key — so `{'required': 'Obrigatório'}` still covers every schema, while `{'string': {'required': '...'}}` or `{'string.required': '...'}` narrows the override to strings only. Existing `VLocale({'required': 'x'})` calls keep working unchanged.
- **`VType` exposes `typeName` getter** — abstract in the base class, overridden by each concrete schema (e.g. `'string'`, `'int'`). Third-party schemas extending `VType` must implement it.
- **Breaking (subtle) — `UsSsnPattern` in `ValidationMode.any`** no longer accepts mixed shapes like `123-456789` or `12345-6789`. Only fully-formatted (`123-45-6789`) or fully-unformatted (`123456789`) inputs are accepted. Users that relied on the older permissive behavior can write their own regex via a custom `TaxIdPattern`.

## [1.1.0] - 2026-04-21

### Added

**Async validation**

- **`refineAsync`** — async custom check on any schema. Companion consumers `validateAsync`, `parseAsync`, `safeParseAsync`, `errorsAsync` run the full pipeline asynchronously. Sync consumers (`validate`, `parse`, `safeParse`, `errors`) throw the new `VAsyncRequiredException` when called on a schema that contains async steps — pointing callers to the async variant. Propagates recursively through `VMap`, `VArray`, `VObject`, `VUnion`, and `VTransformed`. Schemas without async stay 100% synchronous with no overhead.
- **`AsyncValidator<T>`** — async sibling of `Validator<T>` (returns `Future<Map<String, dynamic>?>`) with new `addAsync` method on every schema for plugging custom async validators. Reusable across schemas.
- **`preprocessAsync`** — async input transformation before type check.
- **`transformAsync<O>`** — async output conversion after validation (creates `VTransformedAsync<I, O>`).
- **`timeout`** parameter on `refineAsync` — exceeding it counts as a failure with the same code/message.
- **`VAsyncRequiredException`** — exception thrown by sync consumers when the schema contains async steps; includes `methodName` and `suggestion` fields.

**Generic string validators**

- `base64` — RFC 4648 (length multiple of 4, padding with `=`).
- `hexColor` — `#FFF` or `#FFFFFF`.
- `mac` — MAC address with colon or dash separators (consistent within the value).
- `semver` — Semantic Version 2.0 including pre-release / build metadata.
- `mongoId` — 24-hex MongoDB ObjectId.
- `iban` — ISO 13616 (accepts spaces) + mod-97 check digit.
- `json` — string that parses via `dart:convert`.
- `cvv` — 3 or 4 digits.
- `ulid` — 26 chars Crockford Base32, timestamp-cap first char (0–7).
- `nanoId` — URL-safe `[A-Za-z0-9_-]`, default length 21 (configurable via `length`).

**Pluggable patterns**

- **`PhonePattern`** — abstract phone-validation strategy. Built-in: `E164PhonePattern` (default). `V.string().phone({PhonePattern? pattern, String? message})` — optional `pattern`; without it, behaves exactly as before.
- **`CardBrandPattern`** — abstract card-brand matcher. Built-ins: `VisaBrand`, `MastercardBrand`, `AmexBrand`, `DinersBrand`, `DiscoverBrand`, `JcbBrand`. `V.string().card({List<CardBrandPattern>? brands, String? message})` — when `brands` is omitted/empty, any Luhn-valid number is accepted; when provided, must match at least one.
- **`PostalCodePattern`** — abstract postal-code strategy. Built-ins: `UsZipPattern` (`12345` / `12345-6789`), `CaPostalCodePattern` (`A1A 1A1`), `UkPostcodePattern`.
- **`TaxIdPattern`** — abstract tax-ID strategy. Built-ins: `UsSsnPattern` (`123-45-6789`), `UkNiNumberPattern` (HMRC prefix rules + `A`–`D` suffix), `CaSinPattern` (9 digits + Luhn + CRA first-digit rule).
- **`LicensePlatePattern`** — abstract license-plate strategy. Built-in: `UkPlatePattern` (`AB12 CDE` post-2001 format). Plates with heavy regional variation (US per state, CA per province) are intentionally not built in.

External packages (e.g. `validart_br` with CPF, CNPJ, CEP, Mercosul) can extend each abstract pattern without forking the core.

**New methods / API**

- **`VString.date({String? format, String? message})`** — new optional `format`. When passed, the string must match that exact format (tokens: `YYYY`, `MM`, `DD`; any other character is a literal separator). When omitted, accepts ISO extended/basic, BR, US and EU layouts.
- **`VString.toPascalCase`, `toCamelCase`, `toSnakeCase`, `toScreamingSnakeCase`, `toSlug`** — pre-processing case transforms. Word boundaries detected across separators (` `, `_`, `-`), case transitions, and digits; non-alphanumeric characters are dropped.
- **`keepAccents`** parameter on all case transformers. Default `false` (accents transliterated: `São João` → `sao-joao`, `ç` → `c`, `ñ` → `n`, `ß` → `ss`). Pass `true` to preserve.
- **`VDate.age({int? min, int? max, String? message})`** — validates age derived from a birthdate (computed against `DateTime.now()` at validation time). At least one of `min`/`max` is required.
- **`UuidVersion` enum** — `UuidVersion.v1` through `UuidVersion.v8`. `V.string().uuid({UuidVersion? version, String? message})` accepts an optional version filter — e.g. `V.string().uuid(version: UuidVersion.v7)` for timestamp-ordered only.
- **`VString.url({Set<String>? schemes})`** — optional `schemes` set. Default `{http, https}` (backwards compatible); pass `{http, https, ftp, ws}` etc. to accept other protocols.
- **`VString.password({String? specialChars})`** — optional `specialChars` string. Default `!@#$%^&*(),.?":{}|<>` (backwards compatible); pass a custom string to expand (e.g. `r'!@#$%^&*()-_+=<>?'` to accept `-` and `_`).
- **Factory-level `message` on every factory** — `V.string()`, `V.int()`, `V.double()`, `V.bool()`, `V.date()`, `V.map()`, `V.array()`, `V.object()`, `V.enm()`, `V.literal()`, `V.union()` all accept an optional `message` to customize the `required` error per schema without changing the global locale. Example: `V.bool(message: 'You must accept the terms').isTrue()`. Fallback: custom → locale → default English. Same parameter name as the validator-level `message` (`.email(message: ...)`, `.min(n, message: ...)`, `.refine(fn, message: ...)`, ...) but different scope: the factory-level one fires only on null input (pre-validation `required` error), the validator-level one fires only when that validator rejects a non-null value. Both can coexist on the same schema.
- **`hasDefault` / `defaultValueOrNull` on every schema** — read-only introspection getters on `VType<T>`. `hasDefault` returns whether a default was configured via `defaultValue(x)`; `defaultValueOrNull` returns the configured value (or `null` when none was set). Useful for tooling and conditional logic that needs to inspect schema state without altering it.

### Changed

- **`UuidValidator`** now accepts versions 1–8 (was 1–5). v6, v7 and v8 from RFC 9562 draft (including the timestamp-ordered v7 that is replacing v4 in many modern APIs) are considered valid.
- **`PhoneValidator`** delegates to a `PhonePattern` instead of hardcoding the E.164 regex. Backwards compatible: the default pattern preserves the previous behavior.
- **`CardValidator`** gained an optional `brands` constructor parameter. Backwards compatible: without `brands` it behaves exactly as before (Luhn + length). Cards with masks (spaces or dashes) are still accepted.
- **`DateStringValidator`** gained an optional `format` constructor parameter and, without it, now accepts multiple formats (ISO extended/basic, BR `DD/MM/YYYY`, US `MM/DD/YYYY`, EU `DD.MM.YYYY`, and dashed variants). Ambiguous strings like `02/03/2020` pass when at least one interpretation is calendar-valid.
- **Breaking — `defaultValue` is now validated by the pipeline.** When input is `null` and a default is set, the default is substituted for the input and runs through preprocessors, validators and refines (sync or async). Previously it short-circuited with `VSuccess(default)` regardless of whether the default satisfied the schema. This prevents silent bugs like `V.string().defaultValue('').min(3).parse(null)` returning `''`. Upgrade: ensure your `defaultValue(x)` satisfies the chained validators.
- **Breaking — `DateStringValidator` multi-format mode.** Callers that relied on the previous ISO-only semantics need to either use `date(format: 'YYYY-MM-DD')` explicitly or accept that BR/US/EU strings now pass.

### Fixed

- **`DateStringValidator`** now rejects calendar-invalid dates such as `2024-02-30`, `2024-04-31`, or `2023-02-29` that the previous regex-only implementation accepted. The validator reconstructs the date via `DateTime` and compares each component to guard against rollover (`2024-13-01` → `2025-01-01`).

## [1.0.0] - 2026-04-18

### Complete Rewrite

**Core API:**

- `V` static class — no instantiation needed (`V.string()`, `V.int()`, `V.map()`, etc.)
- `parse()`, `safeParse()`, `validate()`, `errors()` on all types
- `VResult<T>` sealed class with `VSuccess<T>` and `VFailure<T>` (Dart 3 pattern matching)
- `VError` with `code`, `message`, `path` (nested paths like `['address', 'zip']` or `[2, 'name']`), and optional `context` (`List<List<VError>>?`) populated by `VUnion` to expose each option's failure

**Types:**

- `VString` — 22 validators + `notEmpty()` + pre-processing transforms (`trim`, `toLowerCase`, `toUpperCase`) that always run before validation
- `VInt`, `VDouble` — numeric validators (`min`, `max`, `even`, `odd`, `prime`, `finite`, etc.)
- `VBool` — `isTrue`, `isFalse`
- `VDate` — `after`, `before`, `between`, `weekday`, `weekend`
- `VArray<T>` — `min`, `max`, `unique`, `contains` + indexed error paths
- `VMap` — schema composition (`pick`, `omit`, `extend`, `merge`, `partial`, `strict`, `passthrough`) + `equalFields()`, `refineField()`, `when()`, `whenRules`, `array()`. `extend`/`merge` preserve pipeline state from the base (validators, `when` rules, `strict`/`passthrough`/`nullable` flags, `defaultValue`, preprocessors); `merge` concatenates rules/steps from both sides and OR-s flags
- `VObject<T>` — validates class/entity instances with type-safe field extraction
- `VEnum<T>`, `VLiteral<T>`, `VUnion`
- `VTransformed<I, O>` — type-changing transforms

**Pipeline:**

- Three-phase execution: pre-processing → validation → post-processing
- Pre-processing transforms (`trim`, `toLowerCase`, `toUpperCase`) always run before validators regardless of chain order

**Features:**

- Coercion: `V.coerce.int()`, `V.coerce.double()`, `V.coerce.string()`, `V.coerce.bool()`, `V.coerce.date()`
- `transform<O>()` — change output type with chaining support
- `preprocess()` — transform input before type checking; multiple calls chain in declaration order
- `equalFields()` — cross-field comparison (password confirmation)
- `when()` — conditional field validation
- `refineField()` — targeted cross-field validation whose error attaches to the specified field path
- `VFailure.toMap()` — convert errors to `Map<String, String>` for Flutter forms
- `defaultValue(T)` — provide defaults when value is null; takes precedence over `nullable()` when both are set
- Fluent chaining across inherited and concrete methods via covariant returns on every concrete type — e.g. `V.string().nullable().email()`, `V.int().positive().even()`

**i18n:**

- `VLocale` — `Map<String, String>` with `{param}` interpolation; asserts in debug mode when any `{param}` is left unreplaced
- `V.setLocale()` / `V.t()` — switch locale at runtime
- `VCode` — static string constants for all error codes (extensible by external packages)
- Fallback chain: custom translation → English default → code itself
- Per-validator message override bypasses locale

**Architecture:**

- Validators are classes extending `Validator<T>` in `validators/{type}/` — return `Map<String, dynamic>?` (params, not messages)
- `add()` is public — external packages can extend types via Dart extensions
- `part of` pattern for type files sharing pipeline internals
- Zero production dependencies

### Removed (from v0.x)

- `Validart` class (replaced by `V` static class)
- `VMessages`, `VStringMessages`, etc. (replaced by `VLocale`)
- `getErrorMessage()` method
- Brazilian validators (CPF, CNPJ, CEP) — to be published as `validart_br` package
- `any()` / `every()` combinators (replaced by `VUnion` and `refine()`)

## [0.1.1] - 2025-02-23

### Fixed

- Added missing `VDate` export to the package exports.

## [0.1.0] - 2025-02-23

### Added

- **`ValidationMode`** support for:
  - `.cep()`
  - `.cnpj()`
  - `.cpf()`
  - `.phone()`
- Now, it is possible to validate formatted strings (`ValidationMode.formatted`) or unformatted ones (`ValidationMode.unformatted`).
- Improved documentation for CPF, CNPJ, CEP, and Phone, explaining how to use `ValidationMode`.

### Changed

- Updated API to support both formatted and unformatted validation for documents and phone numbers.

## [0.0.4] - 2025-02-20

### Added

- Implemented an **assertion** in `VMap.refine()` to ensure the provided `path` exists in the defined object schema.
  - This prevents referencing non-existent fields, improving validation reliability.
  - Added a **test case** to verify that an `AssertionError` is thrown when an invalid path is used.

### Changed

- Updated the **README** with more detailed documentation and examples.
- Improved **API documentation** to ensure full coverage across all public elements.

## [0.0.3] - 2025-02-19

### Added

- Introduced a new primitive validator: `v.date()`, allowing date-based validations.
- Implemented `.prime()` validator for integers to check if a number is prime.
- Added new string validators:
  - `password()`: Ensures password complexity.
  - `jwt()`: Validates JSON Web Tokens.
  - `card()`: Validates credit card numbers.
  - `integer()`: Ensures the string represents a valid integer.
  - `double()`: Ensures the string represents a valid double.
  - `slug()`: Ensures the string is a valid slug format (lowercase, hyphens, no spaces or special characters).
  - `alpha()`: Ensures the string contains only alphabetic characters.
  - `alphanumeric()`: Ensures the string contains only letters and numbers.
- Expanded test suite, achieving **100% test coverage**.

### Changed

- Standardized class names for greater consistency across the library.
- Improved error messages and default validation messages.
- Adjusted validation logic for maps within arrays, fixing issues with nested validations.
- Updated **README.md** to include detailed documentation on array validations, including `.array()`, `.unique()`, `.contains()`, `.min()`, `.max()`, and other related methods.
- Improved examples for **string** and **integer** array validation.

### Fixed

- Resolved bugs related to map validation within arrays, ensuring proper validation behavior.

## [0.0.2] - 2025-02-17

### Changed

- Renamed `string().startsWidth` to `string().startsWith` for consistency.
- Updated **README** to reflect recent changes and improvements.

### Removed

- Removed `.any()` and `.every()` functions from `.map()` as they were not applicable.

### Added

- Achieved **100% test coverage**, ensuring full validation reliability.
- Added **default messages** for all validation types, providing a consistent error handling experience.

## [0.0.1] - 2025-02-16

- Initial release
