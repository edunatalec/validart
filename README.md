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

Available: `notEmpty`, `min`, `max`, `length`, `email`, `url`, `uuid`, `ulid`, `nanoId`, `mongoId`, `ip`, `pattern`, `date`, `time`, `contains`, `startsWith`, `endsWith`, `equals`, `alpha`, `alphanumeric`, `slug`, `password`, `jwt`, `card`, `cvv`, `phone`, `base64`, `hexColor`, `mac`, `semver`, `iban`, `json`, `postalCode`, `taxId`, `licensePlate`.

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

#### Card

Without `brands`, any Luhn-valid number (with or without mask) is accepted. Pass a list of `CardBrandPattern` to restrict:

```dart
V.string().card().validate('4532 0151 1283 0366'); // true

V.string()
  .card(brands: [const VisaBrand(), const MastercardBrand()])
  .validate('4111111111111111'); // true (Visa)
```

Built-in brands: `VisaBrand`, `MastercardBrand`, `AmexBrand`, `DinersBrand`, `DiscoverBrand`, `JcbBrand`. External packages can extend `CardBrandPattern` to add more (e.g. `EloBrand`, `HipercardBrand` in `validart_br`).

#### Phone

Defaults to E.164. Pass a `PhonePattern` to plug in country-specific rules:

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

#### Postal code

Pluggable pattern. Core ships with `UsZipPattern`, `CaPostalCodePattern`, `UkPostcodePattern`. Others (BR CEP, etc.) come from extension packages:

```dart
V.string().postalCode(pattern: const UsZipPattern()).validate('94103-1234');
V.string().postalCode(pattern: const CaPostalCodePattern()).validate('K1A 0B1');
V.string().postalCode(pattern: const UkPostcodePattern()).validate('SW1A 1AA');
```

#### Tax ID

Pluggable pattern. Core ships with `UsSsnPattern`, `UkNiNumberPattern`, `CaSinPattern` (SIN with Luhn check). Country-specific IDs with custom check digits (e.g. BR CPF/CNPJ) come from extension packages:

```dart
V.string().taxId(pattern: const UsSsnPattern()).validate('123-45-6789');
V.string().taxId(pattern: const UkNiNumberPattern()).validate('AB123456C');
V.string().taxId(pattern: const CaSinPattern()).validate('046-454-286');
```

#### License plate

Pluggable pattern. Core ships with `UkPlatePattern` (post-2001 format — stable nationwide). US and Canada plates vary heavily by state/province and are not built in; implement them per your needs or use an extension package:

```dart
V.string().licensePlate(pattern: const UkPlatePattern()).validate('AB12 CDE');
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
  'too_small': 'Mínimo de {min} caracteres',
}));
```

Only override what you need — everything else falls back to English defaults. Switch locale at runtime:

```dart
V.setLocale(const VLocale(ptBrTranslations));
V.setLocale(const VLocale(esTranslations));
V.setLocale(const VLocale()); // reset to English
```

Per-validator overrides bypass the locale:

```dart
V.string().min(3, message: (n) => 'At least $n chars');
```

Use `V.t()` to translate manually:

```dart
V.t('too_small', {'min': 3}); // 'Mínimo de 3 caracteres'
```

Error codes are defined in `VCode`:

```dart
VCode.required        // 'required'
VCode.invalidEmail    // 'invalid_email'
VCode.stringTooSmall  // 'string.too_small'
VCode.numberTooSmall  // 'number.too_small'
// ... see VCode for all codes
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
