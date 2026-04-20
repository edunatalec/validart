## [1.1.0] - 2026-04-20

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
