## [1.0.0] - 2026-04-13

### Breaking Changes - Complete Rewrite

- **New core API**: `parse()`, `safeParse()`, `validate()`, `errors()` replace old `getErrorMessage()`
- **Typed results**: `VResult<T>` sealed class with `VSuccess<T>` and `VFailure<T>` using Dart 3 pattern matching
- **Structured errors**: `VError` with `code`, `message`, and `path` (supports nested paths like `['address', 'zip']`)
- **Transforms**: `trim()`, `toLowerCase()`, `toUpperCase()` on strings; `transform()` for type-changing transforms
- **Coercion**: `v.coerce.int()`, `v.coerce.double()`, `v.coerce.string()`, `v.coerce.bool()`, `v.coerce.date()`
- **Schema composition**: `pick()`, `omit()`, `extend()`, `merge()`, `partial()`, `strict()`, `passthrough()` on VMap
- **Object validation**: `VObject<T>` for validating class instances with type-safe field extraction
- **New types**: `VEnum<T>`, `VLiteral<T>`, `VUnion`
- **Simplified messages**: Single `VMessages` class with per-type message classes, no more `mergeWithBase`
- **Entry point**: `Validart` class with `v.string()`, `v.int()`, `v.map()`, `v.object<T>()`, etc.
- **Array errors include index**: Error paths contain the array index (e.g., `path: [2, 'name']`)
- **Default value support**: `defaultValue(T value)` on any type
- **Reduced file count**: From 85+ files to ~25 files

### Removed

- Brazilian validators (CPF, CNPJ, CEP) moved to future `validart_br` package (documented in `BR_VALIDATORS.md`)
- `getErrorMessage()` method
- `VRefine`, `VPrimitive` intermediate classes
- All separate validator class files (logic now inline in types)
- `any()` / `every()` combinators (replaced by `VUnion` and `refine()`)
