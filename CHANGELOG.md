# Changelog

## [1.4.0] - 2026-04-25

### Fixed

- **`preprocess(...)` / `preprocessAsync(...)` now actually run on every container type.** All container schemas — `VMap`, `VArray`, `VObject`, `VEnum`, `VLiteral`, `VUnion`, `VTransformed` (and its async counterpart `VTransformedAsync`) — previously overrode `safeParse` / `safeParseAsync` without invoking the base-class preprocess loop, silently dropping any `.preprocess(fn)` / `.preprocessAsync(fn)` registered on them. Only primitives (`VString`, `VInt`, `VDouble`, `VBool`, `VDate`) ever honored preprocessors. Every container now applies sync and async preprocessors before `_resolveNull`, so `V.map({...}).preprocess((raw) => normalize(raw))` and every analogous call transforms the input exactly like it does on primitives. Regression tests were added in `test/src/types/{map,array,enum,literal,union,object}_test.dart` and `test/src/features_test.dart` so the bug cannot return silently.
- **`refine(...)` now runs on `VLiteral`, `VUnion` and `VTransformed` / `VTransformedAsync`.** Each of these overrode `safeParse` and returned `VSuccess(value)` directly on match instead of routing through `_runPipeline(value)`, so any `.refine(fn)` / `.refineAsync(fn)` step was silently dropped. The overrides now delegate the final success path to `_runPipeline` (or `_runPipelineAsync`), which also makes `add()` custom validators and chained transforms downstream of the fix work as documented.
- **`VTransformed<I, O>` and `VTransformedAsync<I, O>` honor their own `nullable()` / `defaultValue(O)`.** Previously the wrappers only consulted the inner schema's null-handling, so `V.string().transform<int>((s) => s.length).defaultValue(0).parse(null)` failed with `string.invalid_type` because `0` was forwarded to the inner `VString`. The wrappers now short-circuit on null input when `_hasDefault` or `_isNullable` is set on the wrapper itself — default goes through `_runPipeline` as the transformed output `O`, and nullable returns `VSuccess<O?>(null)` directly. Inner-nullable behavior (`.nullable().transformAsync(...)`) is preserved because the wrapper still delegates when it has no own null-handling set.
- **Pipeline contract test suite (`test/src/pipeline_contract_test.dart`).** Iterates every concrete `VType` subclass and asserts that `preprocess`, `preprocessAsync`, `refine`, `refineAsync`, `nullable()`, `defaultValue()` and the combination of all of them behave correctly. Adding a new `VType` subclass now requires one call to `_runPipelineContract<T>(...)` — a subclass that forgets to run the base-class preprocess loop (or to route success through `_runPipeline`) fails the contract immediately.

### Known behavior (not yet changed)

- **Entity-level validators short-circuit behind field errors.** `refine`, `equalFields`, and `refineField` live in `_runPipeline`, which only executes when every per-field validation already passed. If any field fails, the entity-level checks are suppressed on that call. Pinned by `test/src/integration_scenarios_test.dart` under the `design: pipeline short-circuit` group. Revisiting this to collect all errors in a single pass is an opportunity for a later release.

### Added

- **`VObject<T>.array()`** — fluent helper that returns `VArray<T>`, mirroring `VMap.array()`. Enables `SignInDto.schema.array().min(1).unique()` for `List<T>` validation without breaking the chain.
- **`VObject<T>.equalFields(fieldA, fieldB, {message})`** — cross-field equality check, mirroring `VMap.equalFields`. Canonical use case is DTO password confirmation. Emits the new error code `VObjectCode.fieldsNotEqual` (`'object.fields_not_equal'`) with default template `'{field} must be equal to {other}'`, customizable per-call via `message:` or globally via `VLocale({'object.fields_not_equal': '...'})`. Throws `ArgumentError` if either field name is not declared on the schema. Backed by a new internal `ObjectEqualFieldsValidator<T>`.
- **`VObject<T>.when(field, equals:, then:)`** — conditional validation, mirroring `VMap.when`. When the value read from `field` equals `equals`, every validator in `then` is applied to the corresponding field in addition to its baseline validator. Asserts that `field` and every key in `then` are declared on the schema. Propagates through `hasAsync` and `safeParseAsync` when any `then` validator is async.
- **`VObject<T>.refineField(check, path:, message:)`** — entity-level predicate scoped to a specific field path. The `check` receives the whole `T` instance (so it can compare across fields), and the emitted error's `path` is `[path]`. Mirrors `VMap.refineField` but without the string-keyed lookup.
- **`VObject<T>.pick(List<String>)` / `.omit(List<String>)`** — derive a new schema containing only / excluding the specified fields. Preserves all pipeline state (validator steps, `when` rules, preprocessors, `nullable`, `defaultValue`). Unlike TypeScript, the input type stays `T` — only the validation surface is narrowed; this is not a subset _type_. For partial/dynamic payloads, use `VMap.partial()` instead.
- **`VObject<T>.merge(VObject<T> other)`** — combine two schemas of the same `T` into a new one. Fields and pipeline state (validator steps, `when` rules, preprocessors, `nullable`, `defaultValue`) from both sides are concatenated/OR-ed. Useful for composing shared `audit`/`meta` field groups with domain-specific schemas.

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
