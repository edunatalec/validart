import 'package:validart/src/validators/required_validator.dart';
import 'package:validart/src/validators/validator.dart';

/// `VType<T>` is an abstract base class for defining validation rules in Validart.
///
/// It serves as the foundation for all data types that require validation, such as:
/// - `VString` for strings
/// - `VInt` for integers
/// - `VBool` for booleans
/// - `VDouble` for floating-point numbers
/// - `VNum` for numeric values
/// - `VDate` for date values
/// - `VArray<T>` for array values
///
/// This class provides a structured way to add validation rules, handle optional and nullable values,
/// and retrieve error messages when validation fails.
abstract class VType<T> {
  /// Stores the list of validation rules applied to this type.
  final List<Validator<T>> _validators = [];

  /// Determines whether the value is optional.
  ///
  /// If `true`, the value is allowed to be omitted without triggering a validation error.
  bool _isOptional = false;

  /// Determines whether the value is nullable.
  ///
  /// If `true`, `null` values will be considered valid.
  bool _isNullable = false;

  /// Returns the list of validators added to this type.
  List<Validator<T>> get validators => _validators;

  /// Indicates whether the value is optional.
  bool get isOptional => _isOptional;

  /// Indicates whether the value can be `null`.
  bool get isNullable => _isNullable;

  /// Adds a validator to the current type.
  ///
  /// This method allows adding custom validation rules dynamically.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.string().add(MyCustomValidator());
  /// ```
  ///
  /// ### Parameters
  /// - [validator]: The validation rule to be added.
  ///
  /// ### Returns
  /// The current `VType<T>` instance with the added validator.
  VType<T> add(Validator<T> validator) {
    _validators.add(validator);
    return this;
  }

  /// Marks the value as optional, meaning it can be omitted without causing validation failure.
  ///
  /// By default, values are required unless explicitly marked as optional.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.string().optional();
  /// print(validator.validate(null)); // true (valid because it's optional)
  /// ```
  ///
  /// ### Returns
  /// The current `VType<T>` instance with the optional flag enabled.
  VType<T> optional() {
    _isOptional = true;
    return this;
  }

  /// Marks the value as nullable, allowing `null` as a valid input.
  ///
  /// Unlike `optional`, which allows a value to be omitted, `nullable` specifically permits `null` as a valid input.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.string().nullable();
  /// print(validator.validate(null)); // true (valid because it's nullable)
  /// ```
  ///
  /// ### Returns
  /// The current `VType<T>` instance with the nullable flag enabled.
  VType<T> nullable() {
    _isNullable = true;
    return this;
  }

  /// Retrieves the validation error message for a given value.
  ///
  /// If the value is valid, it returns `null`. Otherwise, it returns the corresponding validation error message.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.string().min(5);
  /// print(validator.getErrorMessage('hello')); // null (valid)
  /// print(validator.getErrorMessage('hi')); // 'Value must be at least 5 characters' (invalid)
  /// ```
  ///
  /// ### Parameters
  /// - [value]: The value to be validated.
  ///
  /// ### Returns
  /// - `null` if the value passes all validation rules.
  /// - A string containing the error message if validation fails.
  getErrorMessage(T? value) {
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

    return null;
  }

  /// Validates the provided value based on the assigned validation rules.
  ///
  /// Returns `true` if the value meets all validation requirements, otherwise `false`.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.string().min(5);
  /// print(validator.validate('hello')); // true (valid)
  /// print(validator.validate('hi')); // false (invalid, too short)
  /// ```
  ///
  /// ### Parameters
  /// - [value]: The value to be validated.
  ///
  /// ### Returns
  /// - `true` if the value is valid.
  /// - `false` if the value fails validation.
  bool validate(T? value) => getErrorMessage(value) == null;
}
