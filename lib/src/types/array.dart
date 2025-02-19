import 'package:validart/src/messages/array_message.dart';
import 'package:validart/src/types/refine.dart';
import 'package:validart/src/types/type.dart';
import 'package:validart/src/validators/array/contains_array_validator.dart';
import 'package:validart/src/validators/array/unique_validator.dart';
import 'package:validart/src/validators/required_validator.dart';
import 'package:validart/src/validators/string/max_length_validator.dart';
import 'package:validart/src/validators/string/min_length_validator.dart';
import 'package:validart/src/validators/validator.dart';

/// A validation class for lists (`List<T>`) in Validart.
///
/// The `VArray` class provides validation for arrays, including:
/// - Required validation
/// - Minimum and maximum length constraints
/// - Unique elements constraint
/// - Containment validation (ensuring specific elements exist)
///
/// ## Example Usage:
/// ```dart
/// final validator = v.string().array().min(2).max(5).unique();
///
/// print(validator.validate(['one', 'two'])); // true
/// print(validator.validate([])); // false (does not meet min length)
/// print(validator.validate(['one', 'one'])); // false (not unique)
/// ```
class VArray<T> extends VRefine<List<T>> {
  /// The validation type for the elements inside the array.
  final VType<T> _type;

  /// The validation messages used for array-related errors.
  final ArrayMessage _message;

  /// Creates an instance of `VArray<T>` with optional custom validation messages.
  ///
  /// This constructor initializes the array validator and automatically applies
  /// a `RequiredValidator` to ensure that the array is not empty unless marked as optional.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.string().array();
  ///
  /// print(validator.validate([])); // 'Array is required' (invalid)
  /// print(validator.validate(['apple', 'banana'])); // null (valid)
  /// ```
  ///
  /// ### Parameters
  /// - [_type]: The base type validator applied to each element in the array.
  /// - [_message]: The validation messages used for error handling.
  /// - [message]: *(optional)* A custom error message for required validation.
  ///
  /// ### Behavior
  /// By default, this validator requires the array to be non-empty. To allow empty arrays,
  /// use the `.optional()` method.
  VArray(this._type, this._message, {required String? message}) {
    add(RequiredValidator(message: message ?? _message.required));
  }

  /// Ensures that the array contains all specified elements.
  ///
  /// This method adds a `ContainsArrayValidator` to check if the array includes
  /// all elements from the provided `requiredElements` list. If any required
  /// element is missing, the validation fails and returns an error message.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.string().array().contains(['apple', 'banana']);
  ///
  /// print(validator.validate(['apple', 'banana', 'cherry'])); // null (valid)
  /// print(validator.validate(['apple', 'cherry'])); // 'Array must contain specific values' (invalid)
  /// ```
  ///
  /// ### Parameters
  /// - [requiredElements]: The list of elements that must be present in the array.
  /// - [message]: *(optional)* A custom error message to return if validation fails.
  ///
  /// ### Returns
  /// The current `VArray<T>` instance with the `contains` validation applied.
  VArray<T> contains(List<T> requiredElements, {String? message}) {
    return add(ContainsArrayValidator(
      requiredElements: requiredElements,
      message: message ?? _message.contains,
    ));
  }

  /// Ensures that the array does not exceed a maximum number of elements.
  ///
  /// This method adds a `MaxLengthValidator` to verify that the array contains
  /// at most the specified number of elements. If the array has more elements,
  /// the validation fails and returns an error message.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.string().array().max(5);
  ///
  /// print(validator.validate(['apple', 'banana', 'cherry'])); // null (valid)
  /// print(validator.validate(['apple', 'banana', 'cherry', 'date', 'fig', 'grape'])); // 'Array must contain at most 5 elements' (invalid)
  /// ```
  ///
  /// ### Parameters
  /// - [max]: The maximum number of elements allowed.
  /// - [message]: *(optional)* A custom error message to return if validation fails.
  ///
  /// ### Returns
  /// The current `VArray<T>` instance with the `max` validation applied.
  VArray<T> max(int max, {String Function(int max)? message}) {
    return add(
      MaxLengthValidator<List<T>>(
        max,
        message: message?.call(max) ?? _message.max(max),
      ),
    );
  }

  /// Ensures that the array has at least a minimum number of elements.
  ///
  /// This method adds a `MinLengthValidator` to verify that the array contains
  /// at least the specified number of elements. If the array has fewer elements,
  /// the validation fails and returns an error message.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.string().array().min(2);
  ///
  /// print(validator.validate(['apple', 'banana'])); // null (valid)
  /// print(validator.validate(['apple'])); // 'Array must contain at least 2 elements' (invalid)
  /// ```
  ///
  /// ### Parameters
  /// - [min]: The minimum number of elements required.
  /// - [message]: *(optional)* A custom error message to return if validation fails.
  ///
  /// ### Returns
  /// The current `VArray<T>` instance with the `min` validation applied.
  VArray<T> min(int min, {String Function(int min)? message}) {
    return add(
      MinLengthValidator<List<T>>(
        min,
        message: message?.call(min) ?? _message.min(min),
      ),
    );
  }

  /// Ensures that all elements in the array are unique.
  ///
  /// This method adds a `UniqueValidator` to check if the array contains
  /// only distinct elements. If duplicate values are found, the validation
  /// fails and returns an error message.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.string().array().unique();
  ///
  /// print(validator.validate(['apple', 'banana', 'cherry'])); // null (valid)
  /// print(validator.validate(['apple', 'banana', 'apple'])); // 'Array must contain unique values' (invalid)
  /// ```
  ///
  /// ### Parameters
  /// - [message]: *(optional)* A custom error message to return if validation fails.
  ///
  /// ### Returns
  /// The current `VArray<T>` instance with the `unique` validation applied.
  VArray<T> unique({String? message}) {
    return add(UniqueValidator(message: message ?? _message.unique));
  }

  @override
  VArray<T> add(Validator<List<T>> validator) {
    super.add(validator);
    return this;
  }

  @override
  VArray<T> nullable() {
    super.nullable();
    return this;
  }

  @override
  VArray<T> optional() {
    super.optional();
    return this;
  }

  @override
  VArray<T> refine(
    bool Function(List<T> data) validator, {
    String? message,
  }) {
    super.refine(validator, message: message ?? _message.refine);
    return this;
  }

  @override
  String? getErrorMessage(List<T>? value) {
    if (value == null && isNullable) return null;

    for (final validator in validators) {
      final message = validator.validate(value);

      if (message != null) {
        if (validator is RequiredValidator && isOptional && value != null) {
          return null;
        }

        return message;
      }
    }

    for (final item in value!) {
      final message = _type.getErrorMessage(item);

      if (message != null) return message;
    }

    return null;
  }
}
