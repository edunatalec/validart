[![pub package](https://img.shields.io/pub/v/validart.svg)](https://pub.dev/packages/validart)
[![package publisher](https://img.shields.io/pub/publisher/validart.svg)](https://pub.dev/packages/validart/publisher)

# Validart

**Validart** is a flexible and type-safe validation library for Dart, inspired by [Zod](https://zod.dev).

Built for **chaining**, **custom rules**, and **nullable values**. Validart includes validators for **emails, phone numbers, numbers, dates, and more**, making validation in Dart simple and scalable.

## Installation

To install **Validart**, run this command:

With Dart:

```sh
dart pub add validart
```

With Flutter:

```sh
flutter pub add validart
```

This will add a line like this to your project's `pubspec.yaml`:

```yaml
dependencies:
  validart: ^0.0.3
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

Strings are one of the most commonly validated types. In Validart, you can chain multiple validation rules to ensure that a string meets specific criteria.

```dart
final validator = v.string().min(5).max(20).email();

print(validator.validate('test')); // false (too short)
print(validator.validate('user@example.com')); // true
print(validator.validate('example@com')); // false (invalid email format)
```

#### Available String Validations

- `.min(length)`, `.max(length)` - Ensures the string length is within the specified range.
- `.email()`, `.uuid()`, `.url()`, `.date()` - Validates against common string formats.
- `.phone(type)` - Ensures the string is a valid phone number.
- `.cpf()`, `.cnpj()`, `.cep()` - Validates Brazilian CPF, CNPJ, and CEP numbers.
- `.contains(value)`, `.equals(value)`, `.pattern(regex)`, `.startsWith(value)`, `.endsWith(value)` - Validates string structure and content.
- `.alpha()`, `.alphanumeric()`, `.slug()`, `.password()`, `.card()`, `.jwt()` - Ensures the string matches specific types.
- `.refine((data) => condition)`, `.nullable()`, `.optional()` - Provides additional flexibility.

### int

Integers are whole numbers, and Validart provides a robust set of validation methods to ensure your numbers meet specific criteria.

```dart
final validator = v.int().min(10).max(100).odd();

print(validator.validate(5));  // false (too small)
print(validator.validate(99)); // true (odd and within range)
print(validator.validate(100)); // false (not odd)
```

#### Available int Validations

- `.min(value)`, `.max(value)` - Restricts the integer within a range.
- `.positive()`, `.negative()` - Ensures the integer is positive or negative.
- `.odd()`, `.even()` - Checks if the integer is odd or even.
- `.multipleOf(value)`, `.between(min, max)` - Enforces divisibility and range.
- `.prime()` - Checks if the integer is a prime number.
- `.refine((data) => condition)`, `.nullable()`, `.optional()` - Allows additional constraints and flexibility.

### double

Doubles represent floating-point numbers. They are useful for values that require decimal precision, such as prices or scientific measurements.

```dart
final validator = v.double().positive().decimal();

print(validator.validate(5.5));  // true
print(validator.validate(-2.3)); // false (not positive)
print(validator.validate(3)); // true (even though it's an int, it's valid as a double)
```

#### Available double Validations

- `.min(value)`, `.max(value)` - Controls numerical ranges.
- `.positive()`, `.negative()` - Ensures the integer is positive or negative.
- `.finite()`, `.decimal()`, `.integer()` - Ensures valid floating-point values.
- `.multipleOf(value)`, `.between(min, max)` - Validates divisibility and range.
- `.refine((data) => condition)`, `.nullable()`, `.optional()` - Allows customization.

### num

`num` supports both `int` and `double`, making it versatile for handling both types.

```dart
final validator = v.num().between(1, 10);

print(validator.validate(5));    // true
print(validator.validate(11.2)); // false (out of range)
```

#### Available num Validations

- `.min(value)`, `.max(value)`, `.positive()`, `.negative()` - Defines numerical limits.
- `.multipleOf(value)`, `.between(min, max)` - Checks range constraints.
- `.refine((data) => condition)`, `.nullable()`, `.optional()` - Ensures flexibility.

### Date

Date validation is essential for handling timestamps and scheduling events.

```dart
final validator = v.date();

print(validator.validate(DateTime(2025, 5, 20))); // true
print(validator.validate("2025-05-20")); // false (not a DateTime object)
```

#### Available Date Validations

- `.before(date)`, `.after(date)`, `.betweenDates(min, max)` - Ensures that the date occurs before, after, or within a specific date range.
- `.weekday()`, `.weekend()` - Validates whether the date falls on a weekday (Monday to Friday) or a weekend (Saturday or Sunday).
- `.refine((data) => condition)`, `.nullable()`, `.optional()` - Provides additional flexibility by allowing custom validation logic, permitting `null` values, or making the field optional.

### bool

```dart
final validator = v.bool().isTrue();

print(validator.validate(true));  // true
print(validator.validate(false)); // false
```

#### Available bool Validations

- `.isTrue()`, `.isFalse()` - Enforces boolean constraints.
- `.refine((data) => condition)`, `.nullable()`, `.optional()` - Customization options.

### map

Validates objects with structured keys.

```dart
final validator = v.map({
  'email': v.string().email(),
  'password': v.string().min(8).max(20),
});
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

## Arrays in Validart

Validart allows validating **lists of values** using `.array()`. This is useful when you need to ensure that all elements in an array conform to specific validation rules.

For example, you can validate an array of strings where each string must be an email:

```dart
final validator = v.string().email().array();

print(validator.validate(['user@example.com', 'test@valid.com'])); // true
print(validator.validate(['user@example.com', 'invalid-email'])); // false
```

### **Available Array Validations**

When working with `.array()`, you can apply additional validations such as:

- `.unique()` - Ensures that all elements in the array are unique.
- `.contains(value)` - Requires that the array contains certain values.
- `.min(length)`, `.max(length)` - Restricts the number of elements in the array.
- `.nullable()`, `.optional()` - Allows handling `null` values or empty arrays.
- `.refine((data) => condition)` - Adds a custom validation function.

### **Validating Unique Arrays**

You can enforce uniqueness within an array using `.unique()`:

```dart
final validator = v.string().array().unique();

print(validator.validate(['a', 'b', 'c'])); // true
print(validator.validate(['a', 'b', 'a'])); // false (duplicate 'a')
```

### **Ensuring Certain Values are Present**

Use `.contains([...])` to ensure specific values exist in the array:

```dart
final validator = v.string().array().contains(['admin', 'user']);

print(validator.validate(['admin', 'user', 'guest'])); // true
print(validator.validate(['admin', 'guest'])); // false (missing 'user')
```

### **Controlling Array Length**

You can restrict the number of elements using `.min(length)` and `.max(length)`:

```dart
final validator = v.string().array().min(2).max(5);

print(validator.validate(['one', 'two'])); // true
print(validator.validate(['one'])); // false (less than 2 elements)
print(validator.validate(['one', 'two', 'three', 'four', 'five', 'six'])); // false (more than 5 elements)
```

### **Nullable and Optional Arrays**

- `.nullable()` allows the array itself to be `null`.
- `.optional()` allows an empty array but does not accept `null`.

```dart
final nullableValidator = v.string().array().nullable();
print(nullableValidator.validate(null)); // true
print(nullableValidator.validate(['valid'])); // true

final optionalValidator = v.string().array().optional();
print(optionalValidator.validate([])); // true
print(optionalValidator.validate(null)); // false
```

### **Custom Refinements on Arrays**

You can apply custom logic using `.refine()`:

```dart
final validator = v.string().array().refine(
  (list) => list.length > 2,
  message: 'The array must contain more than 2 items.',
);

print(validator.validate(['a', 'b', 'c'])); // true
print(validator.validate(['a', 'b'])); // false
```

---

## **Validating Integer Arrays**

Similarly, you can validate arrays of integers using `v.int().array()`, applying constraints such as:

```dart
final validator = v.int().array().min(2).max(5).unique();

print(validator.validate([1, 2, 3])); // true
print(validator.validate([1, 1, 2])); // false (duplicate 1)
print(validator.validate([1])); // false (not enough elements)
```

You can also ensure all integers are within a specific range:

```dart
final validator = v.int().between(10, 50).array();

print(validator.validate([15, 20, 30])); // true
print(validator.validate([5, 60])); // false (out of range)
```

Using `.multipleOf()`, you can enforce divisibility:

```dart
final validator = v.int().multipleOf(5).array();

print(validator.validate([5, 10, 15])); // true
print(validator.validate([5, 7, 10])); // false (7 is not a multiple of 5)
```

This makes it easy to validate structured lists of integers while ensuring specific constraints.

## Customizing Validation Messages

Validart allows you to customize the validation messages for different types, making error handling more user-friendly.

### Global Message Customization

You can define a **custom message set** when initializing Validart:

```dart
import 'package:validart/validart.dart';

final customMessages = Message(
  string: StringMessage(
    required: 'This field cannot be empty',
    min: (value) => 'Minimum length is $value characters',
    max: (value) => 'Maximum length is $value characters',
    email: 'Invalid email address format',
  ),
  int: IntMessage(
    min: (value) => 'Minimum value allowed is $value',
  ),
);

final v = Validart(message: customMessages);
```

Now, when a validation fails, the custom error messages will be returned instead of the default ones.

```dart
final validator = v.string().min(5);

print(validator.getErrorMessage('a'));
// Output: "Minimum length is 5 characters"
```

### Per-Validation Custom Messages

You can also override messages per validation rule, instead of defining them globally.

```dart
final validator = v.string()
  .min(5, message: 'Must be at least 5 characters')
  .email(message: 'Please enter a valid email');

print(validator.getErrorMessage('abc'));
// Output: "Must be at least 5 characters"

print(validator.getErrorMessage('invalid-email'));
// Output: "Please enter a valid email"
```

This allows for fine-grained control over how error messages are displayed.

### Using `BaseMessage` for Default Messages

If you want to apply default messages across multiple validation types without redefining them for each type, you can use `BaseMessage`:

```dart
final baseMessage = BaseMessage(
  required: 'This field is required',
  refine: 'Invalid value provided',
  any: 'At least one condition must be met',
  every: 'All conditions must be met',
);

final stringMessage = StringMessage(
  email: 'Please provide a valid email',
  min: (value) => 'Minimum length: $value characters',
).mergeWithBase(baseMessage);

final customMessages = Message(
  base: baseMessage,
  string: stringMessage,
);

final v = Validart(message: customMessages);
```
