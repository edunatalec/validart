import 'package:validart/src/types/array.dart';
import 'package:validart/src/types/refine.dart';
import 'package:validart/src/types/type.dart';
import 'package:validart/src/validators/any_validator.dart';
import 'package:validart/src/validators/every_validator.dart';

/// A validation class that supports `any` and `every` conditions.
///
/// Extends [VRefine] to allow chaining multiple validation rules where:
/// - `any`: The value must satisfy at least one of the given validation rules.
/// - `every`: The value must satisfy all of the given validation rules.
///
/// This class provides flexible validation options for complex scenarios.
abstract class VPrimitive<T> extends VRefine<T> {
  /// Ensures that the value satisfies at least one of the given validators.
  ///
  /// This method applies multiple validation rules (`types`), and the value
  /// must pass at least one of them for the validation to succeed.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.string().any([
  ///   v.string().equals('hello'),
  ///   v.string().equals('world'),
  /// ]);
  ///
  /// print(validator.validate('hello')); // null (valid)
  /// print(validator.validate('world')); // null (valid)
  /// print(validator.validate('hello world')); // 'Invalid value' (invalid)
  /// print(validator.validate('random text')); // 'Invalid value' (invalid)
  /// ```
  ///
  /// ### Parameters
  /// - [types]: A list of `VType<T>` validators, at least one of which must be satisfied.
  /// - [message]: *(optional)* A custom error message to return if validation fails.
  ///
  /// ### Returns
  /// The current `VType<T>` instance with the `any` validation applied.
  VType<T> any(List<VType<T>> types, {String? message}) {
    return add(AnyValidator(types, message: message!));
  }

  /// Ensures that the value satisfies all the given validators.
  ///
  /// This method applies multiple validation rules (`types`), and the value
  /// must pass all of them for the validation to succeed.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.string().every([
  ///   v.string().min(5),
  ///   v.string().max(10),
  ///   v.string().contains('test'),
  /// ]);
  ///
  /// print(validator.validate('test123')); // null (valid)
  /// print(validator.validate('test12')); // null (valid)
  /// print(validator.validate('short')); // 'Invalid value' (invalid)
  /// print(validator.validate('this is a long test')); // 'Invalid value' (invalid)
  /// print(validator.validate('randomword')); // 'Invalid value' (invalid)
  /// ```
  ///
  /// ### Parameters
  /// - [types]: A list of `VType<T>` validators that must all be satisfied.
  /// - [message]: *(optional)* A custom error message to return if validation fails.
  ///
  /// ### Returns
  /// The current `VType<T>` instance with the `every` validation applied.
  VType<T> every(List<VType<T>> types, {String? message}) {
    return add(EveryValidator(types, message: message!));
  }

  /// Converts the current validator into an array validator (`VArray<T>`).
  ///
  /// This method enables validation of lists (`List<T>`) where each element in
  /// the array must satisfy the validation rules defined in the base validator.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.string().min(3).array();
  ///
  /// print(validator.validate(['apple', 'banana', 'cherry'])); // null (valid)
  /// print(validator.validate(['a', 'bb', 'ccc'])); // 'Each element must have at least 3 characters' (invalid)
  /// ```
  ///
  /// ### Parameters
  /// - [message]: *(optional)* A custom error message to return if validation fails.
  ///
  /// ### Returns
  /// A `VArray<T>` instance that applies the base validation rules to each element in the array.
  VArray<T> array({String? message});
}
