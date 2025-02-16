# Validart

## Introduction

**Validart** is a flexible and type-safe validation library for Dart, inspired by [Zod](https://zod.dev).

Built for **chaining**, **custom rules**, and **nullable values**. Validart includes validators for **emails, phone numbers, numbers, and more**, making validation in Dart simple and scalable.

## Installation

To install **Validart**, add it to your `pubspec.yaml`:

```yaml
dependencies:
  validart: ^0.0.1
```

Then, run:

```sh
dart pub get
```

Import Validart in your Dart file:

```dart
import 'package:validart/validart.dart';
```

## Basic Usage

Create a schema and validate data:

```dart
final v = Validart();
final validator = v.string().email();

print(validator.validate('user@example.com')); // true
print(validator.validate('invalid-email'));   // false
```

Retrieve error messages:

```dart
final validator = v.string().email();
print(validator.getErrorMessage('invalid-email'));
// "Enter a valid email"
```

## Primitives

### String

```dart
final validator = v.string().min(5).max(20).email();

print(validator.validate('test')); // false (too short)
print(validator.validate('user@example.com')); // true
print(validator.getErrorMessage('invalid-email'));
// "Enter a valid email"
```

#### Available String Validations

- `.min(length)` - Minimum length requirement
- `.max(length)` - Maximum length requirement
- `.email()` - Validates an email format
- `.uuid()` - Validates a UUID
- `.url()` - Validates a URL
- `.phone(PhoneType.brazil)` - Validates phone numbers based on country
- `.cpf()`, `.cnpj()`, `.cep()` - Validates Brazilian CPF, CNPJ, and CEP
- `.contains(value)`, `.equals(value)`
- `.pattern(regex)`, `.startsWith(value)`, `.endsWith(value)`
- `.refine((data) => condition)`
- `.nullable()`, `.optional()`

### int

```dart
final validator = v.int().min(10).max(100).odd();

print(validator.validate(5));  // false (too small)
print(validator.validate(99)); // true (odd and within range)
print(validator.validate(100)); // false (not odd)
```

#### Available int Validations

- `.min(value)`, `.max(value)`
- `.positive()`, `.negative()`
- `.odd()`, `.even()`
- `.multipleOf(value)`
- `.between(min, max)`
- `.refine((data) => condition)`
- `.nullable()`, `.optional()`

### double

```dart
final validator = v.double().positive().decimal();

print(validator.validate(5.5));  // true
print(validator.validate(-2.3)); // false (not positive)
```

#### Available double Validations

- `.min(value)`, `.max(value)`
- `.positive()`, `.negative()`
- `.finite()`, `.decimal()`, `.integer()`
- `.multipleOf(value)`
- `.between(min, max)`
- `.refine((data) => condition)`
- `.nullable()`, `.optional()`

### num

Supports both `int` and `double`.

```dart
final validator = v.num().between(1, 10);

print(validator.validate(5));    // true
print(validator.validate(11.2)); // false (out of range)
```

#### Available num Validations

- `.min(value)`, `.max(value)`
- `.positive()`, `.negative()`
- `.multipleOf(value)`
- `.between(min, max)`
- `.refine((data) => condition)`
- `.nullable()`, `.optional()`

### bool

```dart
final validator = v.bool().isTrue();

print(validator.validate(true));  // true
print(validator.validate(false)); // false
```

#### Available bool Validations

- `.isTrue()` - Must be `true`
- `.isFalse()` - Must be `false`
- `.refine((data) => condition)`
- `.nullable()`, `.optional()`

### map

Validates objects with structured keys.

```dart
final validator = v.map({
  'email': v.string().email(),
  'password': v.string().min(8).max(20),
  'confirmPassword': v.string().min(8).max(20),
}).refine(
  (data) => data?['password'] == data?['confirmPassword'],
  path: 'confirmPassword',
  message: 'Passwords do not match',
);
```

#### Available map Validations

- `.refine((data) => condition, path: 'field', message: 'error message')`
- `.nullable()`, `.optional()`

## Combining Validators

You can combine multiple validators using `.any()` or `.every()`:

```dart
final validator = v.string().any([
  v.string().email(),
  v.string().url(),
]);

print(validator.validate('user@example.com')); // true
print(validator.validate('https://example.com')); // true
print(validator.validate('invalid')); // false
```

```dart
final validator = v.string().every([
  v.string().min(5),
  v.string().contains('test'),
]);

print(validator.validate('test123')); // true (min length and contains 'test')
print(validator.validate('12345'));   // false (does not contain 'test')
```

## Arrays

Validart allows validating lists of values using **`.array()`**, ensuring that each element meets the defined validation rules.

### Example:

```dart
final validator = v.string().phone(
  PhoneType.brazil,
  areaCode: AreaCodeFormat.required,
  countryCode: CountryCodeFormat.none,
).array();

print(validator.validate(['11 98765-4321'])); // true
print(validator.validate(['11 98765-4321', '11 98765-4322'])); // true

print(validator.validate(['98765-4321'])); // false
print(validator.validate(['11 98765-4321', '98765-4321'])); // false
```
