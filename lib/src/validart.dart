import 'package:validart/src/messages/message.dart';
import 'package:validart/src/types/bool.dart';
import 'package:validart/src/types/date.dart';
import 'package:validart/src/types/double.dart';
import 'package:validart/src/types/int.dart';
import 'package:validart/src/types/map.dart';
import 'package:validart/src/types/num.dart';
import 'package:validart/src/types/string.dart';
import 'package:validart/src/types/type.dart';

/// The `Validart` class is the entry point for defining validation rules.
///
/// It provides a fluent API for validating different data types, including:
/// - Strings (`VString`)
/// - Booleans (`VBool`)
/// - Integers (`VInt`)
/// - Doubles (`VDouble`)
/// - Numeric values (`VNum`)
/// - Maps (`VMap`)
/// - Date (`VDate`)
///
/// This class enables custom validation rules and supports chaining for
/// complex validation logic.
///
/// ### Example
///
/// ```dart
/// final v = Validart();
///
/// final validator = v.string().min(5).max(20);
///
/// print(validator.validate('Hello')); // true
/// print(validator.validate('Hi')); // false (too short)
/// ```
class Validart {
  /// Internal message handler for validation messages.
  final Message _message;

  /// Creates an instance of `Validart` for managing validations.
  ///
  /// This constructor initializes the validation system with optional custom messages.
  /// If no custom messages are provided, the default validation messages will be used.
  ///
  /// ### Example
  /// ```dart
  /// // Using default messages
  /// final v = Validart();
  ///
  /// // Using custom messages
  /// final customMessages = Message(
  ///   string: StringMessage(
  ///     required: 'This field cannot be empty',
  ///     email: 'Invalid email format',
  ///   ),
  ///   int: IntMessage(
  ///     min: (value) => 'Minimum value allowed is $value',
  ///   ),
  /// );
  ///
  /// final vCustom = Validart(message: customMessages);
  /// ```
  ///
  /// ### Parameters
  /// - [message] *(optional)*: A custom `Message` instance that allows overriding the default validation messages.
  ///
  /// ### Behavior
  /// - If no `message` parameter is provided, Validart will use its built-in default messages.
  /// - Providing a custom `Message` instance enables localized or customized validation messages.
  ///
  /// ### Returns
  /// A new instance of `Validart` with the specified message configuration.
  Validart({Message? message}) : _message = message ?? Message();

  /// Creates a `VMap` instance for validating objects with structured keys.
  ///
  /// This method allows defining a schema where each key in the `Map` is associated with a specific validation type.
  /// It ensures that the provided object structure adheres to the defined validation rules.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.map({
  ///   'name': v.string().min(3),
  ///   'email': v.string().email(),
  ///   'age': v.int().min(18),
  /// });
  ///
  /// final validData = {'name': 'Alice', 'email': 'alice@example.com', 'age': 25};
  /// final invalidData = {'name': 'Al', 'email': 'invalid-email', 'age': 15};
  ///
  /// print(validator.validate(validData)); // true
  /// print(validator.getErrorMessage(invalidData));
  /// // {'name': 'Minimum length: 3 characters', 'email': 'Please provide a valid email', 'age': 'The number must be at least 18'}
  /// ```
  ///
  /// ### Parameters
  /// - [object]: A `Map<String, VType>` defining the validation schema for each key.
  /// - [message] *(optional)*: A custom error message for object-level validation failures.
  ///
  /// ### Behavior
  /// - The `object` **must not be empty**. Providing an empty `Map` will result in an invalid validation schema.
  /// - Each key in `object` defines a field that will be validated.
  /// - The returned `VMap` will apply the validation rules defined for each field in the provided schema.
  ///
  /// ### Returns
  /// A new instance of `VMap` with the specified schema.
  VMap map(Map<String, VType> object, {String? message}) {
    return VMap(object, _message.map, message: message);
  }

  /// Creates a `VString` instance for validating string values.
  ///
  /// This method initializes a validator that allows applying multiple string-related validation rules,
  /// such as minimum/maximum length, email validation, URL validation, and more.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.string().min(5).email();
  ///
  /// print(validator.validate("test@example.com")); // true
  /// print(validator.validate("short")); // false (too short)
  /// ```
  ///
  /// ### Parameters
  /// - [message] *(optional)*: A custom error message for validation failures.
  ///
  /// ### Returns
  /// A new instance of `VString` for string validation.
  VString string({String? message}) {
    return VString(_message.string, message: message);
  }

  /// Creates a `VBool` instance for validating boolean values.
  ///
  /// This method ensures that the value being validated is a boolean (`true` or `false`).
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.bool().isTrue();
  ///
  /// print(validator.validate(true)); // true
  /// print(validator.validate(false)); // false
  /// ```
  ///
  /// ### Parameters
  /// - [message] *(optional)*: A custom error message for validation failures.
  ///
  /// ### Returns
  /// A new instance of `VBool` for boolean validation.
  VBool bool({String? message}) {
    return VBool(_message.bool, message: message);
  }

  /// Creates a `VInt` instance for validating integer values.
  ///
  /// This method initializes a validator that can apply integer-related rules such as minimum/maximum value,
  /// checking for odd/even numbers, multiples, and more.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.int().min(10).max(50).odd();
  ///
  /// print(validator.validate(25)); // true
  /// print(validator.validate(8)); // false (not odd)
  /// ```
  ///
  /// ### Parameters
  /// - [message] *(optional)*: A custom error message for validation failures.
  ///
  /// ### Returns
  /// A new instance of `VInt` for integer validation.
  VInt int({String? message}) {
    return VInt(_message.int, message: message);
  }

  /// Creates a `VDouble` instance for validating floating-point values.
  ///
  /// This method supports numeric constraints like minimum/maximum value, ensuring the number is finite,
  /// and allowing decimal precision checks.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.double().positive().between(1.5, 10.0);
  ///
  /// print(validator.validate(5.5)); // true
  /// print(validator.validate(-2.3)); // false (not positive)
  /// ```
  ///
  /// ### Parameters
  /// - [message] *(optional)*: A custom error message for validation failures.
  ///
  /// ### Returns
  /// A new instance of `VDouble` for floating-point number validation.
  VDouble double({String? message}) {
    return VDouble(_message.double, message: message);
  }

  /// Creates a `VNum` instance for validating generic numeric values (`int` or `double`).
  ///
  /// This method allows applying validation rules that work for both integers and floating-point numbers.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.num().min(10).max(100);
  ///
  /// print(validator.validate(50)); // true
  /// print(validator.validate(5)); // false (too small)
  /// ```
  ///
  /// ### Parameters
  /// - [message] *(optional)*: A custom error message for validation failures.
  ///
  /// ### Returns
  /// A new instance of `VNum` for number validation.
  VNum num({String? message}) {
    return VNum(_message.num, message: message);
  }

  /// Creates a `VDate` instance for validating date values.
  ///
  /// This method ensures that the value is a valid date and allows applying rules like `before()`, `after()`,
  /// and `betweenDates()`.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.date().after(DateTime(2025, 1, 1));
  ///
  /// print(validator.validate(DateTime(2026, 5, 20))); // true
  /// print(validator.validate(DateTime(2024, 12, 31))); // false (before required date)
  /// ```
  ///
  /// ### Parameters
  /// - [message] *(optional)*: A custom error message for validation failures.
  ///
  /// ### Returns
  /// A new instance of `VDate` for date validation.
  VDate date({String? message}) {
    return VDate(_message.date, message: message);
  }
}
