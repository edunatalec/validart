import 'package:keeper/src/messages/message.dart';
import 'package:keeper/src/types/bool.dart';
import 'package:keeper/src/types/double.dart';
import 'package:keeper/src/types/int.dart';
import 'package:keeper/src/types/map.dart';
import 'package:keeper/src/types/num.dart';
import 'package:keeper/src/types/string.dart';
import 'package:keeper/src/types/type.dart';

/// The `Keeper` class is the entry point for defining validation rules.
///
/// It provides a fluent API for validating different data types, including:
/// - Strings (`KString`)
/// - Booleans (`KBool`)
/// - Integers (`KInt`)
/// - Doubles (`KDouble`)
/// - Numeric values (`KNum`)
/// - Maps (`KMap`)
///
/// This class enables custom validation rules and supports chaining for
/// complex validation logic.
///
/// Example usage:
///
/// ```dart
/// final k = Keeper();
///
/// final validator = k.string().min(5).max(20);
///
/// print(validator.validate('Hello')); // true
/// print(validator.validate('Hi')); // false (too short)
/// ```
class Keeper {
  /// Internal message handler for validation messages.
  final Message _message;

  /// Creates an instance of `Keeper`.
  ///
  /// Optionally, you can provide a custom [message] for validation errors.
  Keeper({Message? message}) : _message = message ?? Message();

  /// Creates a map validator (`KMap`) to validate structured data.
  ///
  /// Example:
  /// ```dart
  /// final validator = k.map({
  ///   'email': k.string().email(),
  ///   'age': k.int().min(18),
  /// });
  /// ```
  KMap map(Map<String, KType> object, {String? message}) {
    return KMap(object, _message.map, message: message);
  }

  /// Creates a string validator (`KString`) for validating text-based inputs.
  ///
  /// Example:
  /// ```dart
  /// final validator = k.string().email();
  /// ```
  KString string({String? message}) {
    return KString(_message.string, message: message);
  }

  /// Creates a boolean validator (`KBool`).
  ///
  /// Example:
  /// ```dart
  /// final validator = k.bool().isTrue();
  /// ```
  KBool bool({String? message}) {
    return KBool(_message.bool, message: message);
  }

  /// Creates an integer validator (`KInt`) for validating whole numbers.
  ///
  /// Example:
  /// ```dart
  /// final validator = k.int().positive();
  /// ```
  KInt int({String? message}) {
    return KInt(_message.int, message: message);
  }

  /// Creates a double validator (`KDouble`) for validating floating-point numbers.
  ///
  /// Example:
  /// ```dart
  /// final validator = k.double().min(8);
  /// ```
  KDouble double({String? message}) {
    return KDouble(_message.double, message: message);
  }

  /// Creates a numeric validator (`KNum`) for validating both integers and doubles.
  ///
  /// Example:
  /// ```dart
  /// final validator = k.num().between(1.5, 10.5);
  /// ```
  KNum num({String? message}) {
    return KNum(_message.num, message: message);
  }
}
