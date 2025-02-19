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

  /// Creates an instance of `Validart`.
  ///
  /// Optionally, you can provide a custom [message] for validation errors.
  Validart({Message? message}) : _message = message ?? Message();

  /// Creates a map validator (`VMap`) to validate structured data.
  ///
  /// Example:
  /// ```dart
  /// final validator = v.map({
  ///   'email': v.string().email(),
  ///   'age': v.int().min(18),
  /// });
  /// ```
  ///
  /// - [message] *(optional)* Custom error message for when the field is required (default: "Required")
  VMap map(Map<String, VType> object, {String? message}) {
    return VMap(object, _message.map, message: message);
  }

  /// Creates a string validator (`VString`) for validating text-based inputs.
  ///
  /// Example:
  /// ```dart
  /// final validator = v.string().email();
  /// ```
  ///
  /// - [message] *(optional)* Custom error message for when the field is required (default: "Required")
  VString string({String? message}) {
    return VString(_message.string, message: message);
  }

  /// Creates a boolean validator (`VBool`).
  ///
  /// Example:
  /// ```dart
  /// final validator = v.bool().isTrue();
  /// ```
  ///
  /// - [message] *(optional)* Custom error message for when the field is required (default: "Required")
  VBool bool({String? message}) {
    return VBool(_message.bool, message: message);
  }

  /// Creates an integer validator (`VInt`) for validating whole numbers.
  ///
  /// Example:
  /// ```dart
  /// final validator = v.int().positive();
  /// ```
  ///
  /// - [message] *(optional)* Custom error message for when the field is required (default: "Required")
  VInt int({String? message}) {
    return VInt(_message.int, message: message);
  }

  /// Creates a double validator (`VDouble`) for validating floating-point numbers.
  ///
  /// Example:
  /// ```dart
  /// final validator = v.double().min(8);
  /// ```
  ///
  /// - [message] *(optional)* Custom error message for when the field is required (default: "Required")
  VDouble double({String? message}) {
    return VDouble(_message.double, message: message);
  }

  /// Creates a numeric validator (`VNum`) for validating both integers and doubles.
  ///
  /// Example:
  /// ```dart
  /// final validator = v.num().between(1.5, 10.5);
  /// ```
  ///
  /// - [message] *(optional)* Custom error message for when the field is required (default: "Required")
  VNum num({String? message}) {
    return VNum(_message.num, message: message);
  }

  /// Creates a date validator (`VDate`) for validating date values.
  ///
  /// This method returns a `VDate` instance, which allows you to apply various
  /// date-related validation rules such as checking if a date is before or after
  /// a certain value, falls within a specific range, or occurs on a weekday or weekend.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.date().after(DateTime(2024, 1, 1));
  /// ```
  ///
  /// - [message] *(optional)* Custom error message for when the field is required (default: "Required")
  VDate date({String? message}) {
    return VDate(_message.date, message: message);
  }
}
