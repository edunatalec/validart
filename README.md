# Validart

[![pub package](https://img.shields.io/pub/v/validart.svg)](https://pub.dev/packages/validart)
[![package publisher](https://img.shields.io/pub/publisher/validart.svg)](https://pub.dev/packages/validart/publisher)

A type-safe validation library for Dart, inspired by [Zod](https://zod.dev).

Built for **chaining**, **schema composition**, **i18n**, and **extensibility**. Includes validators for emails, phone numbers, dates, and more.

## Table of Contents

- [Installation](#installation)
- [Basic Usage](#basic-usage)
- [Types](#types)
  - [String](#string)
  - [Int](#int)
  - [Double](#double)
  - [Bool](#bool)
  - [Date](#date)
- [Map (Structured Objects)](#map-structured-objects)
  - [Schema Composition](#schema-composition)
  - [Cross-Field Validation](#cross-field-validation)
  - [Custom Field Validation](#custom-field-validation)
  - [Conditional Validation](#conditional-validation)
  - [Array of Maps](#array-of-maps)
- [Object (Entity Validation)](#object-entity-validation)
  - [DTO Pattern](#dto-pattern)
  - [Errors and Entity-Level Rules](#errors-and-entity-level-rules)
  - [Array of Entities](#array-of-entities)
  - [Cross-Field Validation](#cross-field-validation-1)
  - [Custom Field Validation](#custom-field-validation-1)
  - [Conditional Validation](#conditional-validation-1)
  - [Schema Composition](#schema-composition-1)
- [Array](#array)
- [Other Types](#other-types)
  - [Enum](#enum)
  - [Literal](#literal)
  - [Union](#union)
- [Coercion](#coercion)
- [Pipeline](#pipeline)
  - [Pipeline order — primitives](#pipeline-order--primitives)
  - [Pipeline order — containers (`VMap` / `VObject`)](#pipeline-order--containers-vmap--vobject)
  - [Pipeline order — `VArray`](#pipeline-order--varray)
  - [Async pipeline](#async-pipeline)
  - [Transform](#transform)
  - [Preprocess](#preprocess)
- [Modifiers](#modifiers)
  - [Custom `required` message per schema](#custom-required-message-per-schema)
- [Async Validation](#async-validation)
  - [More async primitives](#more-async-primitives)
- [Form Errors](#form-errors)
  - [Reading raw errors](#reading-raw-errors)
  - [Root-level errors via `rootMessages()`](#root-level-errors-via-rootmessages)
  - [Custom error codes in refine](#custom-error-codes-in-refine)
  - [`refine` with `dependsOn` for error aggregation on `VMap` / `VObject`](#refine-with-dependson-for-error-aggregation-on-vmap--vobject)
- [i18n (Internationalization)](#i18n-internationalization)
  - [Type-specific overrides](#type-specific-overrides)
  - [Per-validator override](#per-validator-override)
  - [Manual translation](#manual-translation)
  - [Error codes](#error-codes)
  - [Complete translation template](#complete-translation-template)
- [Extensibility](#extensibility)
  - [Pluggable patterns](#pluggable-patterns)
- [License](#license)

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

`integer` and `numeric` validate that the string _represents_ a number, without converting the output type. Use them when the pipeline value must stay a `String` (form fields, query params). For conversion use `V.coerce.int()` / `V.coerce.double()` instead.

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

Defaults to E.164 with an optional leading `+`. Pass a list of `PhonePattern`s to plug in country-specific rules — validation succeeds when **any** pattern in the list matches:

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

V.string().phone(patterns: [const BrPhonePattern()]);

// Multi-country — accept either BR or E.164-formatted numbers:
V.string().phone(patterns: [
  const BrPhonePattern(),
  const E164PhonePattern(),
]);
```

Use `CountryCodeFormat` to pin whether the leading `+` is `required`, `optional` (default) or `none`:

```dart
V.string().phone(
  patterns: [const E164PhonePattern(countryCode: CountryCodeFormat.required)],
).validate('14155552671'); // false — `+` missing

V.string().phone(
  patterns: [const E164PhonePattern(countryCode: CountryCodeFormat.none)],
).validate('+14155552671'); // false — `+` forbidden
```

#### Postal code

Pluggable pattern. Core ships with `UsZipPattern`, `CaPostalCodePattern`, `UkPostcodePattern`. Others (BR CEP, etc.) come from extension packages:

```dart
V.string().postalCode(patterns: [const UsZipPattern()]).validate('94103-1234');
V.string().postalCode(patterns: [const CaPostalCodePattern()]).validate('K1A 0B1');
V.string().postalCode(patterns: [const UkPostcodePattern()]).validate('SW1A 1AA');

// Multi-country — accept any of several layouts at once:
V.string().postalCode(patterns: [
  const UsZipPattern(),
  const CaPostalCodePattern(),
  const UkPostcodePattern(),
]).validate('SW1A 1AA'); // true
```

When multiple patterns are configured, the error's `{name}` param joins each pattern's name with `/` — so a single locale template like `'Invalid {name}'` renders as `Invalid US ZIP / Canadian Postal Code / UK Postcode`.

`CaPostalCodePattern` and `UkPostcodePattern` accept a `mode` to require or forbid the separating space:

```dart
V.string().postalCode(
  patterns: [const UkPostcodePattern(mode: ValidationMode.formatted)],
).validate('SW1A1AA'); // false — space required

V.string().postalCode(
  patterns: [const CaPostalCodePattern(mode: ValidationMode.unformatted)],
).validate('K1A0B1'); // true
```

#### Tax ID

Pluggable pattern. Core ships with `UsSsnPattern`, `UkNiNumberPattern`, `CaSinPattern` (SIN with Luhn check). Country-specific IDs with custom check digits (e.g. BR CPF/CNPJ) come from extension packages:

```dart
V.string().taxId(patterns: [const UsSsnPattern()]).validate('123-45-6789');
V.string().taxId(patterns: [const UkNiNumberPattern()]).validate('AB123456C');
V.string().taxId(patterns: [const CaSinPattern()]).validate('130-692-544');

// Multi-country — same input shape, multiple valid options:
V.string().taxId(patterns: [
  const UsSsnPattern(),
  const UkNiNumberPattern(),
  const CaSinPattern(),
]);
```

All three accept a `mode` (default `ValidationMode.any`) to pin formatted vs unformatted input:

```dart
V.string().taxId(
  patterns: [const UsSsnPattern(mode: ValidationMode.formatted)],
).validate('123456789'); // false — dashes required

V.string().taxId(
  patterns: [const CaSinPattern(mode: ValidationMode.unformatted)],
).validate('130692544'); // true
```

> **Note:** `UsSsnPattern` in `ValidationMode.any` only accepts fully-formatted (`123-45-6789`) or fully-unformatted (`123456789`) input. Mixed shapes like `123-456789` are now rejected.

#### License plate

Pluggable pattern. Core ships with `UkPlatePattern` (post-2001 format — stable nationwide). US and Canada plates vary heavily by state/province and are not built in; implement them per your needs or use an extension package:

```dart
V.string().licensePlate(patterns: [const UkPlatePattern()]).validate('AB12 CDE');

V.string().licensePlate(
  patterns: [const UkPlatePattern(mode: ValidationMode.unformatted)],
).validate('AB12CDE'); // true
```

### Int

Validates integer values with range, sign, and divisibility checks. Use for quantities, counts, indices, and IDs that must be whole numbers.

```dart
final age = V.int().min(0).max(120);
age.validate(30);   // true
age.validate(-1);   // false
age.validate(121);  // false

V.int().positive().multipleOf(5).validate(15); // true
V.int().prime().validate(7);                   // true
V.int().odd().validate(4);                     // false
```

Available: `min`, `max`, `positive`, `negative`, `between`, `multipleOf`, `even`, `odd`, `prime`.

Combine with `nullable()`, `defaultValue()`, or `.array()`:

```dart
V.int().min(1).nullable().validate(null);              // true
V.int().positive().array().min(1).validate([1, 2, 3]); // true
```

### Double

Validates floating-point numbers — prices, coordinates, weights. Chain `finite()` to reject `NaN` / `Infinity`.

```dart
final price = V.double().positive().finite();
price.validate(9.99);             // true
price.validate(double.infinity);  // false

V.double().decimal().validate(3.14); // true  (has fractional part)
V.double().integer().validate(3.0);  // true  (whole number)
V.double().integer().validate(3.14); // false
```

Available: `min`, `max`, `positive`, `negative`, `between`, `multipleOf`, `finite`, `decimal`, `integer`.

`decimal` requires a fractional part; `integer` requires none — the two are complementary filters for a `double`.

### Bool

Validates boolean values. Use `isTrue()` for terms-acceptance or opt-in flags, `isFalse()` for soft-delete toggles or "not suspended" checks.

```dart
final accepted = V.bool(message: 'You must accept the terms').isTrue();
accepted.validate(true);  // true
accepted.validate(false); // false
accepted.validate(null);  // false — factory-level `message` fires for null

V.bool().isFalse().validate(false); // true
```

Available: `isTrue`, `isFalse`.

`null` is rejected by default. Pair with `.nullable()` when the absence of a value is meaningful.

### Date

Validates `DateTime` values — deadlines, birth dates, scheduling windows.

```dart
final ref = DateTime(2024, 1, 1);

V.date().after(ref).validate(DateTime(2024, 6, 15));  // true
V.date().before(ref).validate(DateTime(2023, 12, 1)); // true
V.date().between(ref, DateTime(2024, 12, 31))
  .validate(DateTime(2024, 6, 15));                   // true

V.date().weekday().validate(DateTime(2024, 1, 15)); // true (Monday)
V.date().weekend().validate(DateTime(2024, 1, 6));  // true (Saturday)
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

Use `equalFields` when one field's value must match another — the classic case is password confirmation. Both fields still run their own validators first; `equalFields` checks equality afterwards and emits `map.fields_not_equal`.

```dart
final signup = V.map({
  'password': V.string().min(8),
  'confirm': V.string(),
}).equalFields('password', 'confirm');

signup.validate({'password': 'secret123', 'confirm': 'secret123'}); // true
signup.validate({'password': 'secret123', 'confirm': 'oops'});      // false

signup.errors({'password': 'secret123', 'confirm': 'oops'})!.first.code;
// map.fields_not_equal
```

### Custom Field Validation

`refineField` attaches a custom predicate to a specific field path, so the resulting error lives on that field in the shape — not on the root of the map. Reach for it when a business rule depends on data already present on the map (e.g. "age must be 18+", "end date must be after start date") and the check is too specific for a generic validator.

```dart
final adult = V.map({
  'age': V.int(),
}).refineField(
  (data) => (data['age'] as int) >= 18,
  path: 'age',
  message: 'Must be at least 18',
);

adult.validate({'age': 21}); // true
adult.validate({'age': 16}); // false

final err = adult.errors({'age': 16})!.first;
err.path;    // [age]
err.message; // Must be at least 18
```

#### `refineField` vs `refineFieldRaw`

Both attach a path-keyed entity-level rule, but they differ in **when** the callback runs and **what** it sees:

| | `refineField` (recommended) | `refineFieldRaw` |
|---|---|---|
| Callback receives | `Map<String, dynamic>` after every field's preprocess + validators + transforms ran | `Map<String, dynamic>` after the container preprocess + type check, **before** any per-field iteration — each value still as it arrived |
| Runs when | inside the entity-level pipeline, gated on the field at `path` passing per-field validation (implicit `dependsOn: {path}`) | always, once the input is a valid `Map` — no per-field results to gate on |
| Use when | the rule depends on parsed/transformed values (the common case) | the rule depends on the raw input as the user typed it — original casing, whitespace, pre-coercion shape |

```dart
// Same callback, two semantics:
final schema = V.map({
  'email': V.string().toLowerCase(),
})
.refineFieldRaw(
  (data) => data['email'] == 'A@B.COM',     // sees raw input
  path: 'email',
  message: 'raw must be A@B.COM',
)
.refineField(
  (data) => data['email'] == 'A@B.COM',     // sees lowercased value
  path: 'email',
  message: 'parsed must be A@B.COM',
);

schema.errors({'email': 'A@B.COM'});
// → only the 'parsed' rule fails; 'raw' rule passed.
```

`VObject<T>.refineFieldRaw` mirrors `VMap.refineFieldRaw` for typed schemas — the callback receives the `T` instance after the container preprocess and cast, before any per-field pipeline runs. Useful for rules that must execute regardless of per-field results.

In most cases, prefer `refineField`. Reach for `refineFieldRaw` only when the rule explicitly depends on the input as it arrived.

### Conditional Validation

`when(field, equals: value, then: {...})` applies extra field validators only when another field has a specific value. Ideal for discriminated shapes ("if `type` is `'company'`, then `cnpj` is required") — fields in `then` are merged over the base schema for matching rows, and skipped entirely otherwise.

```dart
final account = V.map({
  'type': V.string(),
  'cnpj': V.string().nullable(),
}).when('type', equals: 'company', then: {
  'cnpj': V.string().min(14),
});

account.validate({'type': 'person',  'cnpj': null});              // true — rule skipped
account.validate({'type': 'company', 'cnpj': '12345678000190'});  // true
account.validate({'type': 'company', 'cnpj': null});              // false — cnpj now required
```

Multiple `when` calls can be chained; each is independent.

### Array of Maps

Call `.array()` on any `VMap` to validate a list of rows (table-shaped data, CSV imports, JSON arrays of objects). Errors include the row index as the first segment of the path, followed by the field key.

```dart
final users = V.map({
  'name': V.string().min(1),
  'email': V.string().email(),
}).array();

users.validate([
  {'name': 'Alice', 'email': 'alice@ex.com'},
  {'name': 'Bob',   'email': 'bob@ex.com'},
]); // true

users.errors([
  {'name': 'Alice', 'email': 'alice@ex.com'},
  {'name': '',     'email': 'not-an-email'},
]);
// [VError(code: string.too_small, path: [1, name]),
//  VError(code: string.email,     path: [1, email])]
```

## Object (Entity Validation)

Validates class instances (entities, DTOs, domain models) with **type-safe** field extraction — no runtime casts, no string keys for field access. Pick `VObject<T>` over `VMap` when you already have a typed class and want the schema to match its structure exactly.

```dart
class User {
  final String name;
  final String email;
  final int age;

  User({required this.name, required this.email, required this.age});
}

final schema = V.object<User>()
    .field('name', (u) => u.name, V.string().min(1))
    .field('email', (u) => u.email, V.string().email())
    .field('age', (u) => u.age, V.int().min(0).max(120));

schema.validate(User(name: 'Jo', email: 'jo@x.com', age: 30)); // true
```

### DTO Pattern

Because the schema is a plain value, DTOs can expose it as a `static final` — built once per isolate, reused at every call site:

```dart
class SignInDto {
  final String email;
  final String password;

  const SignInDto({required this.email, required this.password});

  static final schema = V.object<SignInDto>()
      .field('email', (dto) => dto.email, V.string().email())
      .field('password', (dto) => dto.password, V.string().password());
}

SignInDto.schema.validate(
  SignInDto(email: 'a@b.com', password: 'Abc!2345'),
); // true
```

### Errors and Entity-Level Rules

Errors include the field name in the path — same convention as `VMap`:

```dart
final errors = schema.errors(User(name: '', email: 'bad', age: 30));
// [VError(code: 'string.too_small', path: ['name']),
//  VError(code: 'string.email', path: ['email'])]
```

Entity-level rules that look at the whole instance go via `refine()`:

```dart
V.object<User>().refine(
  (u) => u.name.isNotEmpty,
  message: 'Name cannot be empty',
  code: 'empty_name',
);
```

### Array of Entities

Validate a list with `.array()` — chains every operator from `VArray`:

```dart
final batch = SignInDto.schema.array().min(1).unique();

batch.validate([
  SignInDto(email: 'a@b.com', password: 'Str0ng!Pass'),
]); // true
```

### Cross-Field Validation

`.equalFields(a, b)` compares two declared fields via `==`. Canonical use case is DTO password confirmation:

```dart
class SignUpDto {
  final String email;
  final String password;
  final String confirm;
  const SignUpDto({
    required this.email,
    required this.password,
    required this.confirm,
  });
}

final schema = V.object<SignUpDto>()
  .field('password', (d) => d.password, V.string().password())
  .field('confirm', (d) => d.confirm, V.string())
  .equalFields('password', 'confirm');

schema.errors(
  SignUpDto(email: 'a@b.com', password: 'Str0ng!Pass', confirm: 'other'),
)?.first.message;
// 'password must be equal to confirm'
```

### Custom Field Validation

`.refineField(check, path:)` runs an entity-level predicate and scopes the error to a specific field path:

```dart
V.object<User>()
  .field('age', (u) => u.age, V.int())
  .refineField(
    (u) => u.age >= 18,
    path: 'age',
    message: 'Must be at least 18',
  );
```

### Conditional Validation

`.when(field, equals:, then:)` applies extra validators only when another field has a specific value:

```dart
class TaxPayer {
  final String country;
  final String taxId;
  const TaxPayer({required this.country, required this.taxId});
}

final schema = V.object<TaxPayer>()
  .field('country', (t) => t.country, V.string())
  .field('taxId', (t) => t.taxId, V.string())
  .when('country', equals: 'US', then: {
    'taxId': V.string().taxId(patterns: [const UsSsnPattern()]),
  });

schema.validate(TaxPayer(country: 'US', taxId: '123-45-6789')); // true
schema.validate(TaxPayer(country: 'BR', taxId: 'anything'));    // true
```

### Schema Composition

`.pick([...])`, `.omit([...])` and `.merge(other)` derive new schemas from existing ones. State (validators, `when` rules, `nullable`, `defaultValue`) propagates across the composition:

```dart
final full = V.object<User>()
  .field('name', (u) => u.name, V.string().min(1))
  .field('email', (u) => u.email, V.string().email())
  .field('age', (u) => u.age, V.int().min(0).max(120));

final publicProfile = full.pick(['name', 'email']); // keeps only 'name', 'email'
final withoutAge    = full.omit(['age']);           // drops 'age'

final contactOnly = V.object<User>()
  .field('email', (u) => u.email, V.string().email());
final identity = V.object<User>()
  .field('name', (u) => u.name, V.string().min(1));
final merged = identity.merge(contactOnly); // name + email
```

> Note: unlike TypeScript, `pick`/`omit` do not generate a subset _type_. The input still has to be a full instance of `T` — only the validation surface is narrowed. For partial/dynamic payloads (CRUD UPDATE via JSON), reach for `VMap.partial()` instead.
>
> `partial()`, `strict()` and `passthrough()` from `VMap` are **not** available on `VObject` — they don't map to nominal Dart classes whose fields are declared up front. See the CHANGELOG of 1.4.0 for the full rationale.

## Array

Validates `List<T>` — each element goes through the element schema, then the list is checked against the array-level constraints.

```dart
final emails = V.string().email().array().min(1).unique();

emails.validate(['a@b.com', 'c@d.com']); // true
emails.validate(['a@b.com', 'a@b.com']); // false (not unique)
emails.validate([]);                     // false (min 1)
```

Errors include the array index in the path:

```dart
final errors = emails.errors(['a@b.com', 'bad']);
// [VError(code: 'string.email', path: [1])]
```

Available: `min`, `max`, `unique`, `contains`.

`contains` asserts that a set of required values is present (emitted code is `array.contains_all`):

```dart
final roles = V.string().array().contains(['admin']);
roles.validate(['admin', 'user']); // true
roles.validate(['user']);          // false
```

Nested arrays work via the `VArray<T>` constructor directly:

```dart
final matrix = VArray<List<int>>(V.int().array());
matrix.validate([[1, 2], [3, 4]]); // true
```

## Other Types

### Enum

Validates that a value is a member of a Dart `enum`. Use for fixed sets of known states (status, role, category).

```dart
enum Status { active, inactive, pending }

final schema = V.enm(Status.values);
schema.validate(Status.active); // true
schema.validate('active');      // false (string, not enum member)
schema.validate(null);          // false

schema.array().validate([Status.active, Status.pending]); // true
```

### Literal

Validates that a value is **exactly** a single expected value. Use for discriminator fields, feature flags locked to a specific value, or sentinel checks.

```dart
final admin = V.literal('admin');
admin.validate('admin'); // true
admin.validate('user');  // false

// Works with any equatable type:
V.literal(42).validate(42);     // true
V.literal(true).validate(true); // true
```

For "one of several literals", compose with `V.union`:

```dart
final role = V.union([
  V.literal('admin'),
  V.literal('editor'),
  V.literal('viewer'),
]);
role.validate('editor'); // true
role.validate('guest');  // false
```

### Union

Validates that a value matches at least one of several schemas. Use when an API accepts multiple input shapes — e.g. an ID that can be a UUID string or an int, or a config field that's either a preset name or a custom value.

```dart
final id = V.union([
  V.string().uuid(),
  V.int().positive(),
]);

id.validate('550e8400-e29b-41d4-a716-446655440000'); // true (matches uuid)
id.validate(42);                                     // true (matches int)
id.validate('not-a-uuid');                           // false
id.validate(-1);                                     // false
```

On failure the emitted code is `'union.invalid'`, and the per-option failures are available in `error.context` for diagnostics. `error.context` is a `List<List<VError>>` — one list of errors per option, in the same order as declared:

```dart
final errors = id.errors(-5);
print(errors!.first.code);   // 'union.invalid'
print(errors.first.context);
// [
//   [VError(code: 'string.invalid_type', ...)],  // option 0: V.string().uuid()
//   [VError(code: 'number.positive', ...)],      // option 1: V.int().positive()
// ]
```

## Coercion

Converts input types automatically **before** validation runs. Use when the raw input comes in as a string (query params, form fields, JSON text) but you need the typed value downstream.

```dart
V.coerce.int().parse('42');          // 42   (int)
V.coerce.double().parse('3.14');     // 3.14 (double)
V.coerce.string().parse(42);         // '42' (String)
V.coerce.bool().parse('true');       // true (bool)
V.coerce.date().parse('2024-01-15'); // DateTime(2024, 1, 15)
```

> **Date coercion accepts ISO 8601 plus 8 regional layouts by default** — `YYYY-MM-DD`, `YYYY/MM/DD`, `YYYYMMDD`, `DD/MM/YYYY`, `MM/DD/YYYY`, `DD-MM-YYYY`, `MM-DD-YYYY`, `DD.MM.YYYY`. Calendar-invalid dates like `30/02/2024` still throw. For strict format validation — e.g. rejecting `01/15/2024` in a BR-only pipeline because of `DD/MM` vs `MM/DD` ambiguity — chain `V.string().date(format: 'DD/MM/YYYY')` **before** the coercion step.
>
> ```dart
> V.coerce.date().parse('2024-01-15'); // DateTime(2024, 1, 15)
> V.coerce.date().parse('15/01/2024'); // DateTime(2024, 1, 15)
> V.coerce.date().parse('01/02/2024'); // DateTime(2024, 2, 1) — DD/MM wins by list order
> V.coerce.date().parse('30/02/2024'); // throws — calendar-invalid
> ```

**Coercion vs. string validators** — `V.coerce.int()` converts `'42'` to `42`; `V.string().integer()` keeps `'42'` as `String` but validates that it _could_ be converted. Pick coercion when you need the typed value in the output; pick the string validator when the downstream code still expects a `String`.

Chain additional validators after coercion:

```dart
V.coerce.int().min(1).max(100).parse('50'); // 50
V.coerce.int().min(1).parse('0');           // throws VException
```

## Pipeline

Validation runs every step in a fixed order — the order does **not** depend on how you write the chain. `V.string().trim().email()` and `V.string().email().trim()` produce the same result because `trim` (a pre-transform) always runs before `email` (a validator), regardless of position.

The three high-level phases are **input shaping → validation → output shaping**. Inside each phase the steps run in the order shown below.

### Pipeline order — primitives

For `V.string()`, `V.int()`, `V.double()`, `V.bool()`, `V.date()`, `V.enm()`, `V.literal()` — and also for `V.map()` / `V.object()` / `V.array()` / `V.union()` / `V.transform()` at the top level (containers add extra steps in the middle, see the next section).

| # | Step | Triggered by | Runs in | Notes |
|---|---|---|---|---|
| 1 | Sync preprocess | `.preprocess(fn)` | `safeParse` + `safeParseAsync` | Reshapes the raw input. Runs in registration order. |
| 2 | Async preprocess | `.preprocessAsync(fn)` | `safeParseAsync` only | Sync preprocess chain runs first, then async, both in registration order. |
| 3 | Null / default resolution | `.nullable()`, `.defaultValue(x)`, factory `message:` | both | If the input is `null`: substitute the default (validated like any input), return null for nullable, or emit the `required` error. |
| 4 | Type check | (automatic) | both | The input must be assignable to the schema's `T`; otherwise emits `<typeName>.invalid_type`. |
| 5 | Pre-transforms | string built-ins: `.trim()`, `.toLowerCase()`, `.toUpperCase()`, `.toCamelCase()`, `.toPascalCase()`, `.toSnakeCase()`, `.toScreamingSnakeCase()`, `.toSlug()` | both | These reshape the validated value before any validator sees it — that's why `.trim().email()` and `.email().trim()` behave identically. |
| 6 | Sync validators | `.min`, `.max`, `.email`, `.url`, every domain validator, `.refine(...)`, `.add(validator)` | both | All sync validators run; their errors are collected (the pipeline does **not** short-circuit on the first error). |
| 7 | Async validators | `.refineAsync(...)`, `.addAsync(validator)` | `safeParseAsync` only | Interleaved with sync validators **in registration order** — `min(3).refineAsync(...)` runs `min(3)` first; `refineAsync(...).min(3)` runs the async check first. |
| 8 | Transforms | `.transform<O>(fn)`, `.transformAsync<O>(fn)` | both | Only run if **every** validator above passed. Each transform can change the output type. |

If any validator in step 6 / 7 emits an error, step 8 is skipped and the result is a `VFailure`.

### Pipeline order — containers (`VMap` / `VObject`)

Containers add an extra block between the type check and the entity-level validation pipeline. Steps in **bold** are container-specific; the rest are inherited from the primitive table above.

| # | Step | Triggered by | Notes |
|---|---|---|---|
| 1 | Container preprocess | `.preprocess(fn)` / `.preprocessAsync(fn)` on the `V.map(...)` / `V.object<T>()` itself | Receives the raw container value (the whole `Map` / `T`), not individual fields. |
| 2 | Null / default | `.nullable()`, `.defaultValue(...)` | Same as primitives. |
| 3 | Type check | (automatic) | `Map<String, dynamic>` for `VMap`, `T` for `VObject<T>`. |
| 4 | **Raw entity validators** | `.refineFieldRaw(check, path:)` (also `.addRaw(...)`) | Runs **once the type check succeeded, before any per-field iteration**. The callback sees fields **as the user typed them** — no field-level preprocess / validators / transforms have applied yet. Always runs (no `dependsOn` gating, no field has been validated). Useful when a rule depends on raw casing or whitespace that a field's `.trim()` / `.toLowerCase()` would erase. |
| 5 | **Strict / unknown-key check** | `.strict()` on `VMap` | If enabled, every key not declared in the schema emits an `unrecognized_key` error. |
| 6 | **Per-field iteration** | Each declared field via `V.map({...})` / `.field(name, extractor, validator)` | Every field runs its **own full pipeline** (steps 1–8 from the primitives table) on the corresponding value. Field errors are aggregated into a single `VFailure`; the field's path is prepended to each error's `path`. |
| 7 | **`when` rules** | `.when(field, equals:, then: {...})` | When the discriminator matches, the listed extra validators run on the corresponding fields, just like step 6. |
| 8 | **Passthrough** | `.passthrough()` on `VMap` | Copies any input keys not in the schema onto the parsed output (no validation; the schema decided to keep them). |
| 9 | Entity-level validators | `.refine(...)`, `.refineField(...)`, `.equalFields(...)`, `.add(...)`, `.refineAsync(...)`, `.addAsync(...)` | Run via `_runPipeline` after every field has been parsed. Steps with `dependsOn: {a, b}` skip only when `a` or `b` itself failed; without `dependsOn`, the step skips conservatively whenever any field failed (because the callback might cast a field that was never produced). See *`refine` with `dependsOn`* below. |
| 10 | Entity-level transforms | `.transform<O>(fn)` | Only run if every step above passed. Rare on containers, but works the same as on primitives. |

```dart
// Why refineFieldRaw runs before per-field — a raw casing check.
V.map({
  'email': V.string().toLowerCase(),
  'expected': V.string(),
}).refineFieldRaw(
  (data) => data['email'] == data['expected'],   // sees uppercase
  path: 'email',
  message: 'email must match expected (raw, case-sensitive)',
);
// At step 4 the callback sees 'A@B.COM' (raw); only later, at step 6,
// the field's own .toLowerCase() reshapes it to 'a@b.com'.
```

### Pipeline order — `VArray`

Arrays have a similar structure to containers, but with element iteration in place of named-field iteration:

| # | Step | Notes |
|---|---|---|
| 1 | Preprocess | Same as primitives. |
| 2 | Null / default | Same. |
| 3 | Type check | Must be a `List`. |
| 4 | Element iteration | Each index runs the element schema's full pipeline. The element's path is prefixed with the integer index (so a failed `name` on element `[1]` lands at `[1, 'name']`). The whole array short-circuits as a `VFailure` when any element fails — array-level validators in step 5 do **not** see partial input. |
| 5 | Array-level validators | `.min(n)`, `.max(n)`, `.unique()`, `.contains([...])`, `.refine((list) => ...)`, `.add(...)`. |
| 6 | Transforms | `.transform<O>(fn)` on the array. |

### Async pipeline

Calling `safeParse` (or `validate` / `parse` / `errors`) on a schema with **any** async step throws `VAsyncRequiredException`, with `suggestion` pointing to the corresponding `*Async` consumer. A schema is "async" when:

- it has any `preprocessAsync` / `refineAsync` / `addAsync` / `transformAsync`, or
- a child schema (field, element, union option, transformed inner) is async.

The `*Async` path runs the same steps as the sync table, with two differences:

1. **Step 1 + step 2** become a single sequence: every sync preprocessor runs first, then every async preprocessor — both in registration order. `runPreprocessorsAsync(value)` exposes this stage as a public method.
2. **Step 6 + step 7** are interleaved in registration order. `min(3).refineAsync(check)` runs `min(3)` first, then `check`. `refineAsync(check).min(3)` runs `check` first, then `min(3)`. This matters when an async check is expensive — put the cheap sync rejections in front of it.

Sync-only schemas keep running synchronously inside `safeParseAsync`, with no `await` overhead — the async pipeline detects sync children via `hasAsync` and short-circuits on the sync path internally.

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

#### Running preprocess in isolation

Most consumers never call this directly — `parse` / `safeParse` already run the preprocess stage internally. But when bridging Validart into a different pipeline (form libraries that revalidate per-field, snapshot tooling, custom debuggers), you sometimes need to apply only the preprocess chain — without `_resolveNull`, validators, refines, or transforms:

```dart
final schema = V.string()
  .preprocess((v) => (v as String).trim())
  .min(3);

schema.runPreprocessors('  hi  ');     // 'hi' — trim ran, .min(3) did NOT
await schema.runPreprocessorsAsync(' x '); // 'x' — async-safe variant

schema.hasPreprocessors;                // true
V.string().hasPreprocessors;            // false
```

`runPreprocessors` throws `VAsyncRequiredException` when the schema has any `preprocessAsync` registered — use `runPreprocessorsAsync` instead. Both are exposed on every `VType` (primitives, containers, unions, transforms).

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

Convert errors to a map keyed by field name:

```dart
final result = schema.safeParse(data);

if (result case VFailure(:final errors)) {
  final map = result.toMap();
  // {'email': 'Invalid email address', 'name': 'Required'}
}
```

### Reading raw errors

Each `VError` has a `path` that tells you where the error attached. The path determines whether the error lands in `toMap()` (per-field) or in `rootMessages()` (form-wide):

| Where the error came from | Emitted `path` | Lands in |
|---|---|---|
| Field validator (`V.map({'x': V.string().min(3)})`) | `['x']` | `toMap()` |
| `refineField(check, path: 'x')` on container | `['x']` | `toMap()` |
| `add(validator, path: ['x'])` on any schema | `['x']` | `toMap()` |
| `refine(check)` on container | `[]` | `rootMessages()` |
| `refineAsync(check)` on container | `[]` | `rootMessages()` |
| `equalFields(a, b)` on container | `[]` | `rootMessages()` |
| `add(validator)` without `path:` | `[]` | `rootMessages()` |
| `addAsync(validator)` without `path:` | `[]` | `rootMessages()` |
| Any validator on a primitive schema used as the root (`V.string().min(3).safeParse(...)`) | `[]` | `rootMessages()` |
| Element error inside `VArray` (`V.array(V.map({'x': ...}))`) | `[0, 'x']` | `toMap()` (key `'0.x'`) |

In short: `path` is empty whenever the error is **not** scoped to a single declared field — that includes both intentional form-wide rules (`refine` / `equalFields` on a container) **and** validators applied directly to a primitive schema. Both are surfaced through `rootMessages()`.

Example with a root-level refine:

```dart
final schema = V.map({
  'startDate': V.date(),
  'endDate': V.date(),
}).refine(
  (m) => (m['endDate'] as DateTime).isAfter(m['startDate'] as DateTime),
  code: 'date_range_invalid',
  message: 'endDate must be after startDate',
);

final errors = schema.errors({
  'startDate': DateTime(2026, 5, 1),
  'endDate': DateTime(2026, 4, 1),
});
// [VError(code: 'date_range_invalid', message: 'endDate ...', path: [])]
```

You can iterate and decide where to render each error:

```dart
for (final e in errors!) {
  if (e.path.isEmpty) {
    showFormBanner(e.message);                       // root-level
  } else {
    fieldErrors[e.path.first as String] = e.message; // field-level
  }
}
```

### Root-level errors via `rootMessages()`

`toMap()` is **field-keyed**, so it deliberately excludes errors with an empty `path`. The full list of producers is in the table under *Reading raw errors* — most commonly that means `refine` / `refineAsync` / `equalFields` applied to a container, but it also covers `add` / `addAsync` without a `path:` argument and any validator on a primitive schema used as the root. Those errors typically describe form-wide rules without a single owning field:

- "if `country == 'BR'`, at least one of `cpf` or `cnpj` is required"
- "cart cannot mix products from different regions"
- "credentials are invalid" / "promo code expired"

Use `rootMessages()` on the `VFailure` to retrieve them as a `List<String>`, separate from field errors:

```dart
final result = schema.safeParse(data);

if (result case VFailure() && final f) {
  final fieldErrors = f.toMap();        // Map<String, String> — per-input errors
  final formErrors = f.rootMessages();  // List<String> — render as a banner
}
```

Rule of thumb:

- Error belongs to an identifiable field → use `refineField(check, path: 'x')` (or pass `path:` to `add` / `refine`) so it lands in `toMap()` and the input renders it inline.
- Error belongs to the form as a whole → use `refine(...)` / `equalFields(...)` and render `rootMessages()` in a separate banner.

The two methods partition the errors cleanly: every error appears in exactly one of `toMap()` or `rootMessages()`. To handle both at once with a single iteration, walk `failure.errors` directly (see *Reading raw errors* above).

### Custom error codes in refine

Pass `code:` to assign a machine-readable identifier — useful for i18n keys, analytics, or `error.code == '...'` checks in client code:

```dart
.refine(check, code: 'date_range_invalid', message: 'end must follow start');
.refineField(check, path: 'email', message: 'disposable emails not allowed');
```

Without `code`, the emitted code is `'custom'` (constant `VCode.custom`). The `code:` parameter is also accepted by `refineAsync`.

### `refine` with `dependsOn` for error aggregation on `VMap` / `VObject`

By default, a generic `.refine(check)` on a `VMap` or `VObject` is **skipped** when any field already failed validation — a conservative rule that avoids `cast` crashes on partially-parsed inputs (the failed field is missing from the map passed to `check`). Built-in `equalFields(a, b)` and `refineField(check, path: x)` are the exception: they declare their dependencies internally and run as long as those specific fields passed, so their error is aggregated alongside unrelated field errors.

To get the same aggregation behavior on a custom `refine`, declare its dependencies explicitly:

```dart
final schema = V.map({
  'name': V.string().min(3),
  'startDate': V.date(),
  'endDate': V.date(),
}).refine(
  (m) => (m['endDate'] as DateTime).isAfter(m['startDate'] as DateTime),
  code: 'date_range_invalid',
  dependsOn: const {'startDate', 'endDate'},
);

// `name` fails (too short) AND the date range is wrong → BOTH errors:
schema.errors({
  'name': 'Jo',
  'startDate': DateTime(2026, 5, 1),
  'endDate': DateTime(2026, 4, 1),
});
// [
//   VError(code: 'string.too_small',     path: ['name']),
//   VError(code: 'date_range_invalid',   path: []),
// ]
```

`dependsOn` accepts any field declared in the base schema OR injected via any `when.then` block. Unknown keys throw an `AssertionError` at construction time. The same parameter is available on `refineAsync`. Without `dependsOn`, the conservative skip-on-any-failure behavior is preserved.

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

All emitted codes follow the `<type>.<action>` convention — the three generic fallbacks stay flat in `VCode` only as a backstop for `VLocale`:

```dart
VCode.required            // 'required'  (generic fallback key)
VCode.invalidType         // 'invalid_type'
VCode.custom              // 'custom'

VStringCode.required      // 'string.required' (emitted by VString)
VStringCode.invalidType   // 'string.invalid_type'
VStringCode.email         // 'string.email'
VStringCode.tooSmall      // 'string.too_small'
VStringCode.integer       // 'string.integer'
VStringCode.postalCode    // 'string.postal_code'

VIntCode.required         // 'int.required'
VIntCode.even             // 'int.even'
VIntCode.prime            // 'int.prime'

VDoubleCode.required      // 'double.required'
VDoubleCode.integer       // 'double.integer' (double that is a whole number)
VDoubleCode.decimal       // 'double.decimal'

VNumberCode.positive      // 'number.positive' (shared by VInt and VDouble)
VNumberCode.tooSmall      // 'number.too_small'

VBoolCode.isTrue          // 'bool.is_true'
VDateCode.tooSmall        // 'date.too_small'
VDateCode.weekday         // 'date.weekday'
VArrayCode.unique         // 'array.unique'
VMapCode.unrecognizedKey  // 'map.unrecognized_key'
VEnumCode.invalid         // 'enum.invalid'
VLiteralCode.invalid      // 'literal.invalid'
VUnionCode.invalid        // 'union.invalid'
```

Each sealed class is implicitly `abstract` and cannot be extended outside the library — they serve purely as namespaces for the `static const` codes they expose.

### Complete translation template

Every translatable key in one place. Copy, replace the values with your language, and pass to `V.setLocale`. Keys you omit fall back to English defaults — for type-prefixed codes (`string.required`, `int.required`, …), an omitted key also falls back to the generic sibling (`required`).

Two equivalent formats are supported — pick the one you prefer, or mix them.

#### Flat format

Same groups as the nested format, just spelled out with the `<type>.<action>` prefix on each key.

```dart
V.setLocale(const VLocale({
  'required': 'Required',
  'invalid_type': 'Expected {expected}, received {received}',
  'custom': 'Invalid value',

  'string.required': 'Required',
  'string.invalid_type': 'Expected {expected}, received {received}',
  'string.not_empty': 'Must not be empty',
  'string.too_small': 'Must be at least {min} characters',
  'string.too_big': 'Must be at most {max} characters',
  'string.length': 'Must be exactly {length} characters',
  'string.integer': 'Must be a valid integer',
  'string.numeric': 'Must be a valid number',
  'string.email': 'Invalid email address',
  'string.url': 'Invalid URL',
  'string.uuid': 'Invalid UUID',
  'string.ip': 'Invalid IP address',
  'string.format': 'Invalid format',
  'string.date': 'Invalid date',
  'string.time': 'Invalid time',
  'string.phone': 'Invalid phone number',
  'string.contains': 'Must contain "{substring}"',
  'string.starts_with': 'Must start with "{prefix}"',
  'string.ends_with': 'Must end with "{suffix}"',
  'string.equals': 'Must be equal to "{expected}"',
  'string.alpha': 'Must contain only letters',
  'string.alphanumeric': 'Must contain only letters and numbers',
  'string.slug': 'Must be a valid slug',
  'string.password':
      'Password must have at least 8 characters, including uppercase, lowercase, digit, and special character',
  'string.jwt': 'Invalid JWT',
  'string.card': 'Invalid credit card number',
  'string.base64': 'Invalid Base64',
  'string.hex_color': 'Invalid hex color',
  'string.mac': 'Invalid MAC address',
  'string.semver': 'Invalid Semantic Version',
  'string.mongo_id': 'Invalid MongoDB ObjectId',
  'string.ulid': 'Invalid ULID',
  'string.nano_id': 'Invalid NanoID',
  'string.iban': 'Invalid IBAN',
  'string.json': 'Invalid JSON',
  'string.cvv': 'Invalid CVV',
  'string.postal_code': 'Invalid {name}',
  'string.tax_id': 'Invalid {name}',
  'string.license_plate': 'Invalid {name}',

  'number.too_small': 'Must be at least {min}',
  'number.too_big': 'Must be at most {max}',
  'number.not_in_range': 'Must be between {min} and {max}',
  'number.positive': 'Must be positive',
  'number.negative': 'Must be negative',
  'number.multiple_of': 'Must be a multiple of {factor}',
  'number.finite': 'Must be finite',

  'int.required': 'Required',
  'int.invalid_type': 'Expected {expected}, received {received}',
  'int.even': 'Must be even',
  'int.odd': 'Must be odd',
  'int.prime': 'Must be prime',

  'double.required': 'Required',
  'double.invalid_type': 'Expected {expected}, received {received}',
  'double.decimal': 'Must be a decimal number',
  'double.integer': 'Must be an integer',

  'bool.required': 'Required',
  'bool.invalid_type': 'Expected {expected}, received {received}',
  'bool.is_true': 'Must be true',
  'bool.is_false': 'Must be false',

  'date.required': 'Required',
  'date.invalid_type': 'Expected {expected}, received {received}',
  'date.too_small': 'Must be after {date}',
  'date.too_big': 'Must be before {date}',
  'date.not_in_range': 'Must be between {min} and {max}',
  'date.weekday': 'Must be a weekday',
  'date.weekend': 'Must be a weekend',
  'date.age': 'Age is out of the allowed range',

  'array.required': 'Required',
  'array.invalid_type': 'Expected {expected}, received {received}',
  'array.too_small': 'Must have at least {min} items',
  'array.too_big': 'Must have at most {max} items',
  'array.unique': 'Must contain unique values',
  'array.contains_all': 'Must contain all required values',

  'map.required': 'Required',
  'map.invalid_type': 'Expected {expected}, received {received}',
  'map.unrecognized_key': 'Unrecognized key "{key}"',
  'map.fields_not_equal': '{field} must be equal to {other}',

  'object.required': 'Required',
  'object.invalid_type': 'Expected {expected}, received {received}',
  'object.fields_not_equal': '{field} must be equal to {other}',

  'enum.required': 'Required',
  'enum.invalid_type': 'Expected {expected}, received {received}',
  'enum.invalid': 'Invalid value. Expected one of: {values}',

  'literal.required': 'Required',
  'literal.invalid_type': 'Expected {expected}, received {received}',
  'literal.invalid': 'Expected "{expected}", received "{received}"',

  'union.required': 'Required',
  'union.invalid_type': 'Expected {expected}, received {received}',
  'union.invalid': 'Value does not match any of the union types',
}));
```

**Interpolation tokens** — each key can use `{param}` placeholders that are substituted at validation time. The most common ones: `{min}`, `{max}`, `{length}`, `{factor}`, `{expected}`, `{received}`, `{substring}`, `{prefix}`, `{suffix}`, `{date}`, `{key}`, `{field}`, `{other}`, `{values}`, `{name}` (for pluggable patterns like postal codes and tax IDs). Leaving a token in the translated string preserves the dynamic value in the output; omit tokens you don't want to render.

#### Nested format

Same content, grouped by type — easier to maintain when translating several keys of the same namespace.

```dart
V.setLocale(const VLocale({
  'required': 'Required',
  'invalid_type': 'Expected {expected}, received {received}',
  'custom': 'Invalid value',

  'string': {
    'required': 'Required',
    'invalid_type': 'Expected {expected}, received {received}',
    'not_empty': 'Must not be empty',
    'too_small': 'Must be at least {min} characters',
    'too_big': 'Must be at most {max} characters',
    'length': 'Must be exactly {length} characters',
    'integer': 'Must be a valid integer',
    'numeric': 'Must be a valid number',
    'email': 'Invalid email address',
    'url': 'Invalid URL',
    'uuid': 'Invalid UUID',
    'ip': 'Invalid IP address',
    'format': 'Invalid format',
    'date': 'Invalid date',
    'time': 'Invalid time',
    'phone': 'Invalid phone number',
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
  },

  'number': {
    'too_small': 'Must be at least {min}',
    'too_big': 'Must be at most {max}',
    'not_in_range': 'Must be between {min} and {max}',
    'positive': 'Must be positive',
    'negative': 'Must be negative',
    'multiple_of': 'Must be a multiple of {factor}',
    'finite': 'Must be finite',
  },

  'int': {
    'required': 'Required',
    'invalid_type': 'Expected {expected}, received {received}',
    'even': 'Must be even',
    'odd': 'Must be odd',
    'prime': 'Must be prime',
  },

  'double': {
    'required': 'Required',
    'invalid_type': 'Expected {expected}, received {received}',
    'decimal': 'Must be a decimal number',
    'integer': 'Must be an integer',
  },

  'bool': {
    'required': 'Required',
    'invalid_type': 'Expected {expected}, received {received}',
    'is_true': 'Must be true',
    'is_false': 'Must be false',
  },

  'date': {
    'required': 'Required',
    'invalid_type': 'Expected {expected}, received {received}',
    'too_small': 'Must be after {date}',
    'too_big': 'Must be before {date}',
    'not_in_range': 'Must be between {min} and {max}',
    'weekday': 'Must be a weekday',
    'weekend': 'Must be a weekend',
    'age': 'Age is out of the allowed range',
  },

  'array': {
    'required': 'Required',
    'invalid_type': 'Expected {expected}, received {received}',
    'too_small': 'Must have at least {min} items',
    'too_big': 'Must have at most {max} items',
    'unique': 'Must contain unique values',
    'contains_all': 'Must contain all required values',
  },

  'map': {
    'required': 'Required',
    'invalid_type': 'Expected {expected}, received {received}',
    'unrecognized_key': 'Unrecognized key "{key}"',
    'fields_not_equal': '{field} must be equal to {other}',
  },

  'object': {
    'required': 'Required',
    'invalid_type': 'Expected {expected}, received {received}',
    'fields_not_equal': '{field} must be equal to {other}',
  },

  'enum': {
    'required': 'Required',
    'invalid_type': 'Expected {expected}, received {received}',
    'invalid': 'Invalid value. Expected one of: {values}',
  },

  'literal': {
    'required': 'Required',
    'invalid_type': 'Expected {expected}, received {received}',
    'invalid': 'Expected "{expected}", received "{received}"',
  },

  'union': {
    'required': 'Required',
    'invalid_type': 'Expected {expected}, received {received}',
    'invalid': 'Value does not match any of the union types',
  },
}));
```

#### Mixing formats

Both forms can coexist in the same map — use flat for one-off overrides and nested for bulk translations. The resolver treats them identically.

```dart
V.setLocale(const VLocale({
  'required': 'Campo obrigatório',
  'string': {
    'email': 'E-mail inválido',
    'too_small': 'Mínimo de {min} caracteres',
  },
  'number.positive': 'Deve ser positivo',
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

Five country-specific validators accept pluggable pattern strategies — external packages can contribute new implementations without forking the core. Every one of them takes a **list** of patterns, and validation succeeds when the value matches **any** pattern in the list:

| Validator                 | Abstract class        | Built-ins shipped in core                                                               |
| ------------------------- | --------------------- | --------------------------------------------------------------------------------------- |
| `phone(patterns:)`        | `PhonePattern`        | `E164PhonePattern` (default when `patterns` is omitted)                                 |
| `card(brands:)`           | `CardBrandPattern`    | `VisaBrand`, `MastercardBrand`, `AmexBrand`, `DinersBrand`, `DiscoverBrand`, `JcbBrand` |
| `postalCode(patterns:)`   | `PostalCodePattern`   | `UsZipPattern`, `CaPostalCodePattern`, `UkPostcodePattern`                              |
| `taxId(patterns:)`        | `TaxIdPattern`        | `UsSsnPattern`, `UkNiNumberPattern`, `CaSinPattern`                                     |
| `licensePlate(patterns:)` | `LicensePlatePattern` | `UkPlatePattern`                                                                        |

Country-specific IDs (e.g. BR CPF/CNPJ, CEP, Mercosul plates) live in extension packages like [validart_br](https://pub.dev/packages/validart_br). A multi-country system can list every accepted pattern in a single schema — no need to build a `V.union` of separate phone/postal/tax schemas.

```dart
// Custom phone pattern
class BrPhonePattern extends PhonePattern {
  const BrPhonePattern();

  @override
  String get code => 'invalid_phone_br';

  @override
  Map<String, dynamic>? validate(String value) { ... }
}

V.string().phone(patterns: [const BrPhonePattern()]);

// Multi-country in a single schema
V.string().postalCode(patterns: [
  const UsZipPattern(),
  const CaPostalCodePattern(),
  const UkPostcodePattern(),
  const BrCepPattern(), // from validart_br
]);

// Custom card brand
class EloBrand extends CardBrandPattern {
  const EloBrand();

  @override
  String get name => 'Elo';

  @override
  bool matches(String digits) { ... } // digits already stripped of spaces/dashes
}

V.string().card(brands: [const EloBrand()]);
```

**Error-code behavior with multiple patterns**

- `phone`: the first pattern's `code` is emitted when only one pattern is configured (preserves custom codes like `invalid_phone_br`). With two or more, the generic `VStringCode.phone` (`'string.phone'`) is emitted.
- `postalCode` / `taxId` / `licensePlate`: the code is always the generic one (`'string.postal_code'`, `'string.tax_id'`, `'string.license_plate'`). The `{name}` interpolation param joins each pattern's `name` with `/` — a single template like `'Invalid {name}'` renders as `Invalid US ZIP / UK Postcode` when multiple are configured.

## License

See [LICENSE](LICENSE) for details.
