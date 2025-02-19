import 'package:validart/src/messages/array_message.dart';
import 'package:validart/src/types/refine.dart';
import 'package:validart/src/types/type.dart';
import 'package:validart/src/validators/array/contains_array_validator.dart';
import 'package:validart/src/validators/array/unique_validator.dart';
import 'package:validart/src/validators/required_validator.dart';
import 'package:validart/src/validators/max_length_validator.dart';
import 'package:validart/src/validators/min_length_validator.dart';
import 'package:validart/src/validators/validator.dart';

/// A validation class for lists (`List<T>`) in Validart.
///
/// The `VArray` class provides validation for arrays, including:
/// - Required validation
/// - Minimum and maximum length constraints
/// - Unique elements constraint
/// - Containment validation (ensuring specific elements exist)
///
/// ### Example
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

  /// Adds a new validator to the `VArray<T>` instance.
  ///
  /// This method allows chaining multiple array validation rules, ensuring
  /// that the list meets all defined constraints.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.string().array().min(2).max(5);
  ///
  /// print(validator.validate(['apple', 'banana'])); // true
  /// print(validator.validate(['apple'])); // false (too few elements)
  /// print(validator.validate(['apple', 'banana', 'cherry', 'date', 'fig', 'grape'])); // false (too many elements)
  /// ```
  ///
  /// ### Parameters
  /// - [validator]: A `Validator<List<T>>` instance to be added.
  ///
  /// ### Returns
  /// The current `VArray<T>` instance with the added validator.
  @override
  VArray<T> add(Validator<List<T>> validator) {
    super.add(validator);
    return this;
  }

  /// Marks the array as nullable, allowing `null` as a valid input.
  ///
  /// When this method is applied, `null` values will pass validation, while
  /// non-null values will still be subject to all other validation rules.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.string().array().nullable();
  ///
  /// print(validator.validate(null)); // true (null is allowed)
  /// print(validator.validate([])); // false (empty array is still invalid)
  /// print(validator.validate(['apple', 'banana'])); // true
  /// ```
  ///
  /// ### Returns
  /// The current `VArray<T>` instance with the `nullable` flag enabled.
  @override
  VArray<T> nullable() {
    super.nullable();
    return this;
  }

  /// Marks the array as optional.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.string().array().optional();
  ///
  /// print(validator.validate([])); // true
  /// print(validator.validate(null)); // false
  /// print(validator.validate(['apple', 'banana'])); // true
  /// ```
  ///
  /// ### Returns
  /// The current `VArray<T>` instance with the `optional` flag enabled.
  @override
  VArray<T> optional() {
    super.optional();
    return this;
  }

  /// Applies a custom validation function to the array.
  ///
  /// This method allows defining a custom validation logic for the array,
  /// enabling checks beyond the built-in validators. The provided function
  /// receives the array and should return `true` if valid.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.string().array().refine((list) => list.length % 2 == 0);
  ///
  /// print(validator.validate(['apple', 'banana'])); // true (even length)
  /// print(validator.validate(['apple'])); // false (odd length)
  /// ```
  ///
  /// ### Parameters
  /// - [validator]: A function that receives the array and returns `true` if valid.
  /// - [message] *(optional)*: A custom validation message if the rule fails.
  ///
  /// ### Returns
  /// The current `VArray<T>` instance with the custom validation applied.
  @override
  VArray<T> refine(
    bool Function(List<T> data) validator, {
    String? message,
  }) {
    super.refine(validator, message: message ?? _message.refine);
    return this;
  }

  /// Retrieves the error message for the given array.
  ///
  /// This method first applies all validators attached to the array itself.
  /// If the array-level validation passes, it then checks each individual item
  /// against the base type validator (`_type`). The first validation failure
  /// encountered at either level will return an error message.
  ///
  /// ### Validation Order
  /// 1. The array-level validators (e.g., `min()`, `max()`, `unique()`) are checked first.
  /// 2. If the array passes, each item inside the array is validated individually.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.string().array().min(2).max(5);
  ///
  /// print(validator.getErrorMessage(['apple'])); // 'The array must have at least 2 items' (array validation fails)
  /// print(validator.getErrorMessage(['apple', 'banana', 'cherry', 'date', 'fig', 'grape'])); // 'The array must have at most 5 items' (array validation fails)
  /// print(validator.getErrorMessage(['apple', 'banana', 'cherry', 'date', 'fig'])); // null
  /// ```
  ///
  /// ### Parameters
  /// - [value]: The array to be validated.
  ///
  /// ### Returns
  /// - `null` if the array and all its items pass validation.
  /// - An error message if the array fails any validation rule.
  @override
  getErrorMessage(List<T>? value) {
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
