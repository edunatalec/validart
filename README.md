# Validart

[![pub package](https://img.shields.io/pub/v/validart.svg)](https://pub.dev/packages/validart)
[![package publisher](https://img.shields.io/pub/publisher/validart.svg)](https://pub.dev/packages/validart/publisher)

A type-safe validation library for Dart, inspired by [Zod](https://zod.dev).

Built for **chaining**, **schema composition**, **i18n**, and **extensibility**. Includes validators for emails, phone numbers, dates, and more.

## Installation

```sh
dart pub add validart
```

```dart
import 'package:validart/validart.dart';
```

## Basic Usage

```dart
// No instantiation needed — V is a static class
final schema = V.string().email();

schema.validate('user@example.com'); // true
schema.validate('invalid');          // false

// Get structured errors
final errors = schema.errors('invalid');
// [VError(code: invalid_email, message: Invalid email address)]

// Parse — throws on failure
final value = schema.parse('user@example.com'); // 'user@example.com'

// SafeParse — never throws
final result = schema.safeParse('invalid');
if (result case VFailure(:final errors)) {
  print(errors.first.message);
}
```

## Types

### String

```dart
V.string()
  .notEmpty()
  .min(5)
  .max(100)
  .email();
```

Available: `notEmpty`, `min`, `max`, `length`, `email`, `url`, `uuid`, `ulid`, `nanoId`, `mongoId`, `ip`, `pattern`, `date`, `time`, `contains`, `startsWith`, `endsWith`, `equals`, `alpha`, `alphanumeric`, `slug`, `password`, `jwt`, `card`, `cvv`, `phone`, `base64`, `hexColor`, `mac`, `semver`, `iban`, `json`, `integer`, `numeric`, `postalCode`, `taxId`, `licensePlate`.

`uuid()` accepts RFC 4122 v1–v5 and RFC 9562 v6–v8. Pass `version: UuidVersion.vN` (enum) to restrict — e.g. `V.string().uuid(version: UuidVersion.v7)` for timestamp-ordered only.

Pre-processing: `trim`, `toLowerCase`, `toUpperCase`, `toPascalCase`, `toCamelCase`, `toSnakeCase`, `toScreamingSnakeCase`, `toSlug` — always run before validation, regardless of chain order.

```dart
V.string().toSlug().parse('My Blog Post!');    // 'my-blog-post'
V.string().toCamelCase().parse('hello_world'); // 'helloWorld'
```

Accents are transliterated by default (`São João` → `sao-joao`). Pass `keepAccents: true` to preserve them:

```dart
V.string().toSlug().parse('São João');                  // 'sao-joao'
V.string().toSlug(keepAccents: true).parse('São João'); // 'são-joão'
```

#### Date

Without `format`, accepts multiple known layouts (ISO extended/basic, BR `DD/MM/YYYY`, US `MM/DD/YYYY`, EU `DD.MM.YYYY`, dashed variants). Calendar-invalid dates are rejected.

```dart
V.string().date().validate('2024-01-15'); // true (ISO)
V.string().date().validate('15/01/2024'); // true (BR)
V.string().date().validate('2024-02-30'); // false (calendar-invalid)

// Strict format — tokens: YYYY, MM, DD. Any other char is a literal separator.
V.string().date(format: 'DD/MM/YYYY').validate('15/01/2024'); // true
V.string().date(format: 'DD/MM/YYYY').validate('2024-01-15'); // false
```

#### URL

Defaults to `http` and `https`. Pass a custom `schemes` set to accept other protocols:

```dart
V.string().url().validate('https://example.com');                       // true
V.string().url().validate('ftp://example.com');                         // false
V.string().url(schemes: {'http', 'https', 'ftp'}).validate('ftp://x');  // true
V.string().url(schemes: {'ws', 'wss'}).validate('wss://x.io');          // WebSocket-only
```

#### Password

Default policy: minimum 8 characters, one uppercase, one lowercase, one digit, one special from `!@#$%^&*(),.?":{}|<>`. Pass `specialChars` to expand the accepted set:

```dart
V.string().password().validate('Str0ng!Pass');                       // true
V.string().password().validate('Str0ng_Pass');                       // false ('_' not in default)
V.string().password(specialChars: r'!@#$%^&*()-_+=<>?')
  .validate('Str0ng_Pass');                                          // true
```

#### Numeric strings

`integer` and `numeric` validate that the string *represents* a number, without converting the output type. Use them when the pipeline value must stay a `String` (form fields, query params). For conversion use `V.coerce.int()` / `V.coerce.double()` instead.

```dart
V.string().integer().validate('42');   // true
V.string().integer().validate('-42');  // true
V.string().integer().validate('3.14'); // false (decimal)
V.string().integer().validate('0xFF'); // false (hex)

V.string().numeric().validate('3.14');     // true
V.string().numeric().validate('42e3');     // true (scientific)
V.string().numeric().validate('NaN');      // false
V.string().numeric().validate('Infinity'); // false
```

#### Card

Without `brands`, any Luhn-valid number (with or without mask) is accepted. Pass a list of `CardBrandPattern` to restrict:

```dart
V.string().card().validate('4532 0151 1283 0366'); // true

V.string()
  .card(brands: [const VisaBrand(), const MastercardBrand()])
  .validate('4111111111111111'); // true (Visa)
```

Built-in brands: `VisaBrand`, `MastercardBrand`, `AmexBrand`, `DinersBrand`, `DiscoverBrand`, `JcbBrand`. External packages can extend `CardBrandPattern` to add more (e.g. `EloBrand`, `HipercardBrand` in `validart_br`).

Pin the input shape with `ValidationMode`:

```dart
V.string().card(mode: ValidationMode.formatted).validate('4532 0151 1283 0366'); // true
V.string().card(mode: ValidationMode.formatted).validate('4532015112830366');     // false
V.string().card(mode: ValidationMode.unformatted).validate('4532015112830366');   // true
```

#### Phone

Defaults to E.164 with an optional leading `+`. Pass a `PhonePattern` to plug in country-specific rules:

```dart
V.string().phone().validate('+14155552671'); // true (E.164 default)

class BrPhonePattern extends PhonePattern {
  const BrPhonePattern();

  @override
  String get code => 'invalid_phone_br';

  @override
  Map<String, dynamic>? validate(String value) =>
      RegExp(r'^\+?55\d{10,11}$').hasMatch(value) ? null : {};
}

V.string().phone(pattern: const BrPhonePattern());
```

Use `CountryCodeFormat` to pin whether the leading `+` is `required`, `optional` (default) or `none`:

```dart
V.string().phone(
  pattern: const E164PhonePattern(countryCode: CountryCodeFormat.required),
).validate('14155552671'); // false — `+` missing

V.string().phone(
  pattern: const E164PhonePattern(countryCode: CountryCodeFormat.none),
).validate('+14155552671'); // false — `+` forbidden
```

#### Postal code

Pluggable pattern. Core ships with `UsZipPattern`, `CaPostalCodePattern`, `UkPostcodePattern`. Others (BR CEP, etc.) come from extension packages:

```dart
V.string().postalCode(pattern: const UsZipPattern()).validate('94103-1234');
V.string().postalCode(pattern: const CaPostalCodePattern()).validate('K1A 0B1');
V.string().postalCode(pattern: const UkPostcodePattern()).validate('SW1A 1AA');
```

`CaPostalCodePattern` and `UkPostcodePattern` accept a `mode` to require or forbid the separating space:

```dart
V.string().postalCode(
  pattern: const UkPostcodePattern(mode: ValidationMode.formatted),
).validate('SW1A1AA'); // false — space required

V.string().postalCode(
  pattern: const CaPostalCodePattern(mode: ValidationMode.unformatted),
).validate('K1A0B1'); // true
```

#### Tax ID

Pluggable pattern. Core ships with `UsSsnPattern`, `UkNiNumberPattern`, `CaSinPattern` (SIN with Luhn check). Country-specific IDs with custom check digits (e.g. BR CPF/CNPJ) come from extension packages:

```dart
V.string().taxId(pattern: const UsSsnPattern()).validate('123-45-6789');
V.string().taxId(pattern: const UkNiNumberPattern()).validate('AB123456C');
V.string().taxId(pattern: const CaSinPattern()).validate('046-454-286');
```

All three accept a `mode` (default `ValidationMode.any`) to pin formatted vs unformatted input:

```dart
V.string().taxId(
  pattern: const UsSsnPattern(mode: ValidationMode.formatted),
).validate('123456789'); // false — dashes required

V.string().taxId(
  pattern: const CaSinPattern(mode: ValidationMode.unformatted),
).validate('130692544'); // true
```

> **Note:** `UsSsnPattern` in `ValidationMode.any` only accepts fully-formatted (`123-45-6789`) or fully-unformatted (`123456789`) input. Mixed shapes like `123-456789` are now rejected.

#### License plate

Pluggable pattern. Core ships with `UkPlatePattern` (post-2001 format — stable nationwide). US and Canada plates vary heavily by state/province and are not built in; implement them per your needs or use an extension package:

```dart
V.string().licensePlate(pattern: const UkPlatePattern()).validate('AB12 CDE');

V.string().licensePlate(
  pattern: const UkPlatePattern(mode: ValidationMode.unformatted),
).validate('AB12CDE'); // true
```

### Int

```dart
V.int()
  .min(0)
  .max(100)
  .even();
```

Available: `min`, `max`, `positive`, `negative`, `between`, `multipleOf`, `even`, `odd`, `prime`.

### Double

```dart
V.double()
  .positive()
  .finite();
```

Available: `min`, `max`, `positive`, `negative`, `between`, `multipleOf`, `finite`, `decimal`, `integer`.

### Bool

```dart
V.bool().isTrue();
```

Available: `isTrue`, `isFalse`.

### Date

```dart
V.date()
  .after(DateTime(2024, 1, 1))
  .weekday();
```

Available: `after`, `before`, `between`, `weekday`, `weekend`, `age`.

`age` validates the age derived from a birthdate (computed against `DateTime.now()` at validation time):

```dart
V.date().age(min: 18);          // 18 or older
V.date().age(min: 18, max: 65); // between 18 and 65
V.date().age(max: 120);         // sanity check on claimed birthdate
```

## Map (Structured Objects)

Validates `Map<String, dynamic>` with a schema:

```dart
final userSchema = V.map({
  'name': V.string().min(1),
  'email': V.string().email(),
  'age': V.int().min(0).nullable(),
});

userSchema.validate({'name': 'Alice', 'email': 'a@b.com'}); // true
```

Errors include field paths:

```dart
final errors = userSchema.errors({'name': '', 'email': 'bad'});
// [VError(code: string.too_small, path: [name]), VError(code: invalid_email, path: [email])]
```

### Schema Composition

```dart
final base = V.map({'name': V.string(), 'email': V.string().email()});

base.pick(['name']);                          // only name
base.omit(['email']);                         // everything except email
base.extend({'password': V.string().min(8)}); // add fields
base.merge(otherSchema);                     // combine two schemas
base.partial();                              // all fields nullable
base.strict();                               // reject unknown keys
base.passthrough();                          // allow unknown keys
```

### Cross-Field Validation

```dart
V.map({
  'password': V.string().min(8),
  'confirm': V.string(),
}).equalFields('password', 'confirm');
```

### Custom Field Validation

```dart
V.map({
  'age': V.int(),
}).refineField(
  (data) => (data['age'] as int) >= 18,
  path: 'age',
  message: 'Must be at least 18',
);
```

### Conditional Validation

```dart
V.map({
  'type': V.string(),
  'cnpj': V.string().nullable(),
}).when('type', equals: 'company', then: {
  'cnpj': V.string().min(14),
});
```

### Array of Maps

```dart
V.map({'name': V.string().min(1)}).array();
```

## Object (Entity Validation)

Validates class instances with type-safe field extraction:

```dart
final schema = V.object<User>(
  configure: (o) => o
    .field('name', (u) => u.name, V.string().min(1))
    .field('email', (u) => u.email, V.string().email()),
);

schema.validate(user); // true
```

## Array

```dart
final schema = V.string().email().array()
  .min(1)
  .unique();

schema.validate(['a@b.com', 'c@d.com']); // true
```

Errors include the array index in the path:

```dart
final errors = schema.errors(['a@b.com', 'bad']);
// [VError(code: invalid_email, path: [1])]
```

Available: `min`, `max`, `unique`, `contains`.

## Other Types

### Enum

```dart
V.enm(Status.values).validate(Status.active); // true
```

### Literal

```dart
V.literal('admin').validate('admin'); // true
V.literal('admin').validate('user');  // false
```

### Union

```dart
V.union([V.string().email(), V.int().min(1)]);
```

## Coercion

Converts input types automatically:

```dart
V.coerce.int().parse('42');       // 42
V.coerce.double().parse('3.14');  // 3.14
V.coerce.string().parse(42);     // '42'
V.coerce.bool().parse('true');   // true
V.coerce.date().parse('2024-01-15'); // DateTime
```

## Pipeline

The validation pipeline runs in three phases:

1. **Pre-processing** — normalizes the value before validation (`trim`, `toLowerCase`, `toUpperCase`). The order in the chain does not matter — these always run first.
2. **Validation** — checks constraints on the normalized value (`email`, `min`, `max`, etc.).
3. **Post-processing** — transforms the validated value (`transform<O>()`). Only runs if validation passes.

```dart
// Both are equivalent — trim always runs before email validation:
V.string().trim().email();
V.string().email().trim();
```

### Transform

Change the output type (post-processing phase):

```dart
final schema = V.string().transform<int>((s) => s.length);
schema.parse('hello'); // 5
```

### Preprocess

Transform the raw input before type checking — runs before everything else, including coercion and null checks:

```dart
final schema = V.string()
  .preprocess((v) => v?.toString().trim() ?? '');

schema.parse(42); // '42'
```

## Modifiers

Available on all types:

```dart
V.string().nullable();          // allows null
V.string().defaultValue('N/A'); // uses default when null
V.string().refine(             // custom validation
  (v) => v.contains('@'),
  message: 'Must contain @',
);
```

The default is **validated** by the rest of the pipeline — if it doesn't satisfy the schema, parsing fails:

```dart
V.string().defaultValue('').min(3).parse(null); // throws VException
V.string().defaultValue('hello').min(3).parse(null); // 'hello'
```

### Custom `required` message per schema

Every factory (`V.string()`, `V.int()`, `V.bool()`, `V.date()`, `V.map()`, `V.array()`, `V.object()`, `V.enm()`, `V.literal()`, `V.union()`) accepts an optional `message` that customizes the `required` error (fired on `null` input) without touching the locale:

```dart
V.bool(message: 'You must accept the terms').isTrue();
V.string(message: 'Name is required').min(1);
V.int(message: 'Age is required').between(0, 150);
```

Fallback chain for the `required` error: factory `message` (per schema) → locale translation → default English.

Individual validators (`.email(message: ...)`, `.min(n, message: ...)`, `.refine(fn, message: ...)`, ...) accept their own `message` for the error they produce. The factory-level one fires only on `null` input; the validator-level one fires only when that validator rejects a non-null value — both can coexist on the same schema:

```dart
V.string(message: 'Name is required')
    .min(3, message: (n) => 'At least $n chars');
```

## Async Validation

For checks that need IO (uniqueness in a database, remote token verification), use `refineAsync`:

```dart
final schema = V.string().email().refineAsync(
  (email) async => !(await db.emailExists(email)),
  message: 'Email already registered',
  code: 'email_taken',
);

await schema.validateAsync('a@b.com');   // Future<bool>
await schema.parseAsync('a@b.com');      // Future<String?>
await schema.safeParseAsync('a@b.com');  // Future<VResult<String?>>
await schema.errorsAsync('a@b.com');     // Future<List<VError>?>
```

Any schema containing `refineAsync` becomes async-only — calling the sync consumers (`validate`, `parse`, etc.) throws `VAsyncRequiredException`, pointing to the `*Async` variant. Schemas without `refineAsync` stay fully sync with zero overhead. Async propagates through `VMap`, `VArray`, `VObject`, `VUnion`, and `VTransformed`.

### More async primitives

```dart
// Timeout on a slow check — exceeding counts as failure
V.string().refineAsync(
  check,
  timeout: const Duration(seconds: 5),
);

// Custom AsyncValidator for reuse across schemas
class UsernameAvailable extends AsyncValidator<String> {
  const UsernameAvailable();
  @override String get code => 'username_taken';
  @override Future<Map<String, dynamic>?> validate(String value) async =>
      (await db.usernameExists(value)) ? {} : null;
}

V.string().addAsync(const UsernameAvailable());

// Async pre-processing (before type check)
V.string().preprocessAsync((raw) async => await api.resolveAlias(raw as String));

// Async post-processing (change output type)
final loader = V.string().uuid().transformAsync<User>(
  (id) async => await db.loadUser(id),
);
final user = await loader.parseAsync('550e8400-...'); // User
```

## Form Errors

Convert errors to a map for Flutter forms:

```dart
final result = schema.safeParse(data);

if (result case VFailure(:final errors)) {
  final map = result.toMap();
  // {'email': 'Invalid email address', 'name': 'Required'}
}
```

## i18n (Internationalization)

Set translations using `VLocale`:

```dart
V.setLocale(const VLocale({
  'required': 'Campo obrigatório',
  'invalid_email': 'Email inválido',
  'string.too_small': 'Mínimo de {min} caracteres',
}));
```

Only override what you need — everything else falls back to English defaults. Switch locale at runtime:

```dart
V.setLocale(const VLocale(ptBrTranslations));
V.setLocale(const VLocale(esTranslations));
V.setLocale(const VLocale()); // reset to English
```

### Type-specific overrides

Every schema emits a **type-prefixed error code** for `required` and `invalid_type` — `VString` → `string.required`, `VInt` → `int.required`, etc. This lets you translate each type independently while still having a single generic fallback. Keys can be **flat** or **nested**:

```dart
V.setLocale(const VLocale({
  // Generic fallback — applies to every schema that has no type-specific override.
  'required': 'Campo obrigatório',

  // Nested override — only strings.
  'string': {
    'required': 'Campo de texto obrigatório',
  },

  // Flat override — same idea, written inline. Works interchangeably.
  'int.required': 'Número obrigatório',
}));

V.string().errors(null)!.first.message; // 'Campo de texto obrigatório'
V.int().errors(null)!.first.message;    // 'Número obrigatório'
V.bool().errors(null)!.first.message;   // 'Campo obrigatório' (generic fallback)
```

Lookup order for any prefixed code (e.g. `string.required`): custom prefixed → custom generic (`required`) → default prefixed → default generic → the code itself.

### Per-validator override

Bypasses the locale entirely for a single validator call:

```dart
V.string().min(3, message: (n) => 'At least $n chars');
```

### Manual translation

Use `V.t()` to resolve a code yourself (useful for custom validators or UI):

```dart
V.t('string.too_small', {'min': 3}); // 'Mínimo de 3 caracteres'
```

### Error codes

Error codes are organized into one `sealed class` per type. `VCode` itself holds only the generic fallbacks (`required`, `invalidType`, `custom`); everything else lives in a companion class — `VStringCode`, `VNumberCode`, `VIntCode`, `VDoubleCode`, `VBoolCode`, `VDateCode`, `VArrayCode`, `VMapCode`, `VObjectCode`, `VEnumCode`, `VLiteralCode`, `VUnionCode`:

```dart
VCode.required            // 'required'  (generic fallback key)
VCode.invalidType         // 'invalid_type'
VCode.custom              // 'custom'

VStringCode.required      // 'string.required' (emitted by VString)
VStringCode.invalidType   // 'string.invalid_type'
VStringCode.email         // 'invalid_email'
VStringCode.tooSmall      // 'string.too_small'
VStringCode.integer       // 'string.integer'
VStringCode.postalCode    // 'postal_code'

VIntCode.required         // 'int.required'
VIntCode.even             // 'even'
VIntCode.prime            // 'prime'

VDoubleCode.required      // 'double.required'
VDoubleCode.integer       // 'integer' (double that is a whole number)
VDoubleCode.decimal       // 'decimal'

VNumberCode.positive      // 'positive' (shared by VInt and VDouble)
VNumberCode.tooSmall      // 'number.too_small'

VBoolCode.isTrue          // 'is_true'
VDateCode.tooSmall        // 'date.too_small'
VArrayCode.unique         // 'unique'
VMapCode.unrecognizedKey  // 'unrecognized_key'
VEnumCode.invalid         // 'invalid_enum'
VLiteralCode.invalid      // 'invalid_literal'
VUnionCode.invalid        // 'invalid_union'
```

Each sealed class is implicitly `abstract` and cannot be extended outside the library — they serve purely as namespaces for the `static const` codes they expose.

### Complete translation template

Every translatable key in one place. Copy, replace the values with your language, and pass to `V.setLocale`. Keys you omit fall back to English defaults — for type-prefixed codes (`string.required`, `int.required`, …), an omitted key also falls back to the generic sibling (`required`).

```dart
V.setLocale(const VLocale({
  // ── Generic fallbacks ─────────────────────────────────────────────
  'required': 'Required',
  'invalid_type': 'Expected {expected}, received {received}',
  'custom': 'Invalid value',

  // ── Type-specific required / invalid_type (optional) ──────────────
  // If you omit these, each schema falls back to the generic keys above.
  'string.required': 'Required',
  'string.invalid_type': 'Expected {expected}, received {received}',
  'int.required': 'Required',
  'int.invalid_type': 'Expected {expected}, received {received}',
  'double.required': 'Required',
  'double.invalid_type': 'Expected {expected}, received {received}',
  'bool.required': 'Required',
  'bool.invalid_type': 'Expected {expected}, received {received}',
  'date.required': 'Required',
  'date.invalid_type': 'Expected {expected}, received {received}',
  'array.required': 'Required',
  'array.invalid_type': 'Expected {expected}, received {received}',
  'map.required': 'Required',
  'map.invalid_type': 'Expected {expected}, received {received}',
  'object.required': 'Required',
  'object.invalid_type': 'Expected {expected}, received {received}',
  'enum.required': 'Required',
  'enum.invalid_type': 'Expected {expected}, received {received}',
  'literal.required': 'Required',
  'literal.invalid_type': 'Expected {expected}, received {received}',
  'union.required': 'Required',
  'union.invalid_type': 'Expected {expected}, received {received}',

  // ── String validators ─────────────────────────────────────────────
  'not_empty': 'Must not be empty',
  'string.too_small': 'Must be at least {min} characters',
  'string.too_big': 'Must be at most {max} characters',
  'string.length': 'Must be exactly {length} characters',
  'string.integer': 'Must be a valid integer',
  'string.numeric': 'Must be a valid number',
  'invalid_email': 'Invalid email address',
  'invalid_url': 'Invalid URL',
  'invalid_uuid': 'Invalid UUID',
  'invalid_ip': 'Invalid IP address',
  'invalid_format': 'Invalid format',
  'invalid_date': 'Invalid date',
  'invalid_time': 'Invalid time',
  'invalid_phone': 'Invalid phone number',
  'contains': 'Must contain "{substring}"',
  'starts_with': 'Must start with "{prefix}"',
  'ends_with': 'Must end with "{suffix}"',
  'equals': 'Must be equal to "{expected}"',
  'alpha': 'Must contain only letters',
  'alphanumeric': 'Must contain only letters and numbers',
  'slug': 'Must be a valid slug',
  'password':
      'Password must have at least 8 characters, including uppercase, lowercase, digit, and special character',
  'jwt': 'Invalid JWT',
  'card': 'Invalid credit card number',
  'base64': 'Invalid Base64',
  'hex_color': 'Invalid hex color',
  'mac': 'Invalid MAC address',
  'semver': 'Invalid Semantic Version',
  'mongo_id': 'Invalid MongoDB ObjectId',
  'ulid': 'Invalid ULID',
  'nano_id': 'Invalid NanoID',
  'iban': 'Invalid IBAN',
  'json': 'Invalid JSON',
  'cvv': 'Invalid CVV',
  'postal_code': 'Invalid {name}',
  'tax_id': 'Invalid {name}',
  'license_plate': 'Invalid {name}',

  // ── Number validators (shared by int + double) ────────────────────
  'number.too_small': 'Must be at least {min}',
  'number.too_big': 'Must be at most {max}',
  'number.not_in_range': 'Must be between {min} and {max}',
  'positive': 'Must be positive',
  'negative': 'Must be negative',
  'multiple_of': 'Must be a multiple of {factor}',
  'finite': 'Must be finite',

  // ── Int-specific ──────────────────────────────────────────────────
  'even': 'Must be even',
  'odd': 'Must be odd',
  'prime': 'Must be prime',

  // ── Double-specific ───────────────────────────────────────────────
  'decimal': 'Must be a decimal number',
  'integer': 'Must be an integer',

  // ── Bool validators ───────────────────────────────────────────────
  'is_true': 'Must be true',
  'is_false': 'Must be false',

  // ── Date validators ───────────────────────────────────────────────
  'date.too_small': 'Must be after {date}',
  'date.too_big': 'Must be before {date}',
  'date.not_in_range': 'Must be between {min} and {max}',
  'weekday': 'Must be a weekday',
  'weekend': 'Must be a weekend',
  'age': 'Age is out of the allowed range',

  // ── Array validators ──────────────────────────────────────────────
  'array.too_small': 'Must have at least {min} items',
  'array.too_big': 'Must have at most {max} items',
  'unique': 'Must contain unique values',
  'contains_all': 'Must contain all required values',

  // ── Map validators ────────────────────────────────────────────────
  'unrecognized_key': 'Unrecognized key "{key}"',
  'fields_not_equal': '{field} must be equal to {other}',

  // ── Composite (enum / literal / union) ────────────────────────────
  'invalid_enum': 'Invalid value. Expected one of: {values}',
  'invalid_literal': 'Expected "{expected}", received "{received}"',
  'invalid_union': 'Value does not match any of the union types',
}));
```

**Interpolation tokens** — each key can use `{param}` placeholders that are substituted at validation time. The most common ones: `{min}`, `{max}`, `{length}`, `{factor}`, `{expected}`, `{received}`, `{substring}`, `{prefix}`, `{suffix}`, `{date}`, `{key}`, `{field}`, `{other}`, `{values}`, `{name}` (for pluggable patterns like postal codes and tax IDs). Leaving a token in the translated string preserves the dynamic value in the output; omit tokens you don't want to render.

The same template works in **nested form**, which is convenient when several keys share a prefix:

```dart
V.setLocale(const VLocale({
  'required': 'Campo obrigatório',
  'string': {
    'required': 'Texto obrigatório',
    'too_small': 'Mínimo de {min} caracteres',
    'too_big': 'Máximo de {max} caracteres',
  },
  'number': {
    'too_small': 'Valor mínimo: {min}',
    'too_big': 'Valor máximo: {max}',
    'positive': 'Deve ser positivo',
  },
  'invalid_email': 'E-mail inválido',
}));
```

## Extensibility

The `add()` method is public, so any code — your own project or an external package — can plug custom validators into a schema. Write a `Validator<T>` once and you have two ways to use it.

```dart
class CpfValidator extends Validator<String> {
  const CpfValidator();

  @override
  String get code => 'invalid_cpf';

  @override
  Map<String, dynamic>? validate(String value) =>
      _isValid(value) ? null : {};
}
```

**Use it directly** — no extension needed:

```dart
final cpfSchema = V.string().add(const CpfValidator());

cpfSchema.validate('529.982.247-25'); // true
cpfSchema.validate('111.111.111-11'); // false

// Chains normally with other validators:
V.string().min(11).add(const CpfValidator());
```

**Or wrap it in an extension** for nicer ergonomics when you reuse the same validator across the codebase (or ship a package):

```dart
extension VStringBr on VString {
  VString cpf({String? message}) =>
      add(const CpfValidator(), message: message);
}

V.string().cpf();
```

### Pluggable patterns

For `phone()` and `card()`, external packages can plug new patterns without forking the core:

```dart
// Custom phone pattern
class BrPhonePattern extends PhonePattern {
  const BrPhonePattern();

  @override
  String get code => 'invalid_phone_br';

  @override
  Map<String, dynamic>? validate(String value) { ... }
}

// Custom card brand
class EloBrand extends CardBrandPattern {
  const EloBrand();

  @override
  String get name => 'Elo';

  @override
  bool matches(String digits) { ... } // digits already stripped of spaces/dashes
}
```

## License

See [LICENSE](LICENSE) for details.
