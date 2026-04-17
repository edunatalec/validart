## [1.0.0] - 2026-04-14

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
