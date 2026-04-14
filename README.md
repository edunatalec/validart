[![pub package](https://img.shields.io/pub/v/validart.svg)](https://pub.dev/packages/validart)
[![package publisher](https://img.shields.io/pub/publisher/validart.svg)](https://pub.dev/packages/validart/publisher)

# Validart

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
final schema = V.string()..email();

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
  ..notEmpty()
  ..min(5)
  ..max(100)
  ..email();
```

Available: `notEmpty`, `min`, `max`, `length`, `email`, `url`, `uuid`, `ip`, `pattern`, `date`, `time`, `contains`, `startsWith`, `endsWith`, `equals`, `alpha`, `alphanumeric`, `slug`, `password`, `jwt`, `card`, `phone`.

Transforms: `trim`, `toLowerCase`, `toUpperCase`.

### Int

```dart
V.int()
  ..min(0)
  ..max(100)
  ..even();
```

Available: `min`, `max`, `positive`, `negative`, `between`, `multipleOf`, `even`, `odd`, `prime`.

### Double

```dart
V.double()
  ..positive()
  ..finite();
```

Available: `min`, `max`, `positive`, `negative`, `between`, `multipleOf`, `finite`, `decimal`, `integer`.

### Bool

```dart
V.bool()..isTrue();
```

Available: `isTrue`, `isFalse`.

### Date

```dart
V.date()
  ..after(DateTime(2024, 1, 1))
  ..weekday();
```

Available: `after`, `before`, `between`, `weekday`, `weekend`.

## Map (Structured Objects)

Validates `Map<String, dynamic>` with a schema:

```dart
final userSchema = V.map({
  'name': V.string()..min(1),
  'email': V.string()..email(),
  'age': V.int()..min(0)..optional(),
});

userSchema.validate({'name': 'Alice', 'email': 'a@b.com'}); // true
```

Errors include field paths:

```dart
final errors = userSchema.errors({'name': '', 'email': 'bad'});
// [VError(code: too_small, path: [name]), VError(code: invalid_email, path: [email])]
```

### Schema Composition

```dart
final base = V.map({'name': V.string(), 'email': V.string()..email()});

base.pick(['name']);                          // only name
base.omit(['email']);                         // everything except email
base.extend({'password': V.string()..min(8)}); // add fields
base.merge(otherSchema);                     // combine two schemas
base.partial();                              // all fields optional
base.strict();                               // reject unknown keys
base.passthrough();                          // allow unknown keys
```

### Cross-Field Validation

```dart
V.map({
  'password': V.string()..min(8),
  'confirm': V.string(),
})..equalFields('confirm', 'password');
```

### Conditional Validation

```dart
V.map({
  'type': V.string(),
  'cnpj': V.string()..optional(),
})..when('type', equals: 'company', then: {
  'cnpj': V.string()..min(14),
});
```

### Array of Maps

```dart
V.map({'name': V.string()..min(1)}).array();
```

## Object (Entity Validation)

Validates class instances with type-safe field extraction:

```dart
final schema = V.object<User>(
  configure: (o) => o
    .field('name', (u) => u.name, V.string()..min(1))
    .field('email', (u) => u.email, V.string()..email()),
);

schema.validate(user); // true
```

## Array

```dart
final schema = V.string().email().array()
  ..min(1)
  ..unique();

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
V.union([V.string()..email(), V.int()..min(1)]);
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

## Transform

Change the output type:

```dart
final schema = V.string().transform<int>((s) => s.length);
schema.parse('hello'); // 5
```

## Preprocess

Transform input before type checking:

```dart
final schema = V.string()
  ..preprocess((v) => v?.toString().trim() ?? '');

schema.parse(42); // '42'
```

## Modifiers

Available on all types:

```dart
V.string()..optional();          // allows null (skips validation)
V.string()..nullable();          // allows null
V.string()..defaultValue('N/A'); // uses default when null
V.string()..refine(             // custom validation
  (v) => v.contains('@'),
  message: 'Must contain @',
);
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
V.string()..min(3, message: (n) => 'At least $n chars');
```

Use `V.t()` to translate manually:

```dart
V.t('too_small', {'min': 3}); // 'Mínimo de 3 caracteres'
```

Error codes are defined in `VCode`:

```dart
VCode.required     // 'required'
VCode.invalidEmail // 'invalid_email'
VCode.tooSmall     // 'too_small'
// ... see VCode for all codes
```

## Extensibility

The `add()` method is public, so external packages can add validators:

```dart
// In a package like validart_br:
class CpfValidator extends Validator<String> {
  const CpfValidator();

  @override
  String get code => 'invalid_cpf';

  @override
  Map<String, dynamic>? validate(String value) =>
      _isValid(value) ? null : {};
}

extension VStringBr on VString {
  VString cpf({String? message}) {
    add(const CpfValidator(), message: message);
    return this;
  }
}
```

## License

See [LICENSE](LICENSE) for details.
