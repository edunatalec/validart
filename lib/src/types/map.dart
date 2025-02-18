import 'package:validart/src/messages/map_message.dart';
import 'package:validart/src/types/type.dart';
import 'package:validart/src/validators/refine_map_validator.dart';
import 'package:validart/src/validators/required_validator.dart';
import 'package:validart/src/validators/validator.dart';

/// A validator for `Map<String, dynamic>` values, enabling object validation.
///
/// Example usage:
/// ```dart
/// final v = Validart();
///
/// final validator = v.map({
///   'email': v.string().email(),
///   'password': v.string().min(8).max(20),
/// });
///
/// print(validator.validate({'email': 'user@example.com', 'password': 'secure123'})); // true
/// print(validator.validate({'email': 'invalid-email', 'password': '123'})); // false
/// ```
class VMap extends VType<Map<String, dynamic>> {
  /// Stores the object schema definition.
  final Map<String, VType> _object;

  /// Stores the validation messages for `Map`-related errors.
  final MapMessage _message;

  /// Creates an instance of `VMap` with a given schema and optional custom messages.
  ///
  /// Ensures the object is not empty by default.
  VMap(this._object, this._message, {String? message}) {
    assert(_object.isNotEmpty, 'Map must have at least one field.');
    add(RequiredValidator(message: message ?? _message.required));
  }

  /// Retrieves the object schema.
  Map<String, VType> get object => _object;

  /// Adds a validator to the `VMap` instance.
  ///
  /// Allows chaining multiple validation rules.
  @override
  VMap add(Validator<Map<String, dynamic>> validator) {
    super.add(validator);
    return this;
  }

  /// Marks the object as optional, allowing it to be omitted.
  ///
  /// Example:
  /// ```dart
  /// final validator = v.map({'name': v.string()}).optional();
  /// print(validator.validate(null)); // true
  /// ```
  @override
  VMap optional() {
    super.optional();
    return this;
  }

  /// Marks the object as nullable, allowing it to be `null`.
  ///
  /// Example:
  /// ```dart
  /// final validator = v.map({'name': v.string()}).nullable();
  /// print(validator.validate(null)); // true
  /// ```
  @override
  VMap nullable() {
    super.nullable();
    return this;
  }

  /// Applies a custom validation function to the object.
  ///
  /// Example (password confirmation):
  /// ```dart
  /// final validator = v.map({
  ///   'password': v.string().min(8),
  ///   'confirmPassword': v.string().min(8),
  /// }).refine(
  ///   (data) => data?['password'] == data?['confirmPassword'],
  ///   path: 'confirmPassword',
  ///   message: 'Passwords do not match',
  /// );
  ///
  /// print(validator.validate({'password': 'secure123', 'confirmPassword': 'secure123'})); // true
  /// print(validator.validate({'password': 'secure123', 'confirmPassword': 'wrongpass'})); // false
  /// ```
  VMap refine(
    bool Function(Map<String, dynamic> data) validator, {
    required String path,
    String? message,
  }) {
    return add(
      RefineMapValidator(
        validator,
        path: path,
        message: message ?? _message.refine,
      ),
    );
  }

  /// Retrieves error messages if the validation fails.
  ///
  /// This method aggregates errors from individual field validations and custom refinements.
  ///
  /// Example:
  /// ```dart
  /// final validator = v.map({
  ///   'email': v.string().email(),
  ///   'password': v.string().min(8),
  /// });
  ///
  /// final errors = validator.getErrorMessage({
  ///   'email': 'invalid-email',
  ///   'password': '123'
  /// });
  ///
  /// print(errors);
  /// // Output: {'email': 'Enter a valid email', 'password': 'At least 8 characters required'}
  /// ```
  @override
  Map<String, dynamic>? getErrorMessage(Map<String, dynamic>? value) {
    if (value == null && isNullable) return null;

    final Map<String, dynamic> errors = {};

    for (final validator in validators) {
      final message = validator.validate(value);

      if (message != null) {
        if (validator is RequiredValidator && isOptional && value != null) {
          return null;
        }

        if (validator is! RequiredValidator) {
          errors.addAll({(validator as dynamic).path: message});
        }
      }
    }

    for (final entry in _object.entries) {
      final error = entry.value.getErrorMessage(value?[entry.key]);

      if (error != null) {
        errors.addAll({entry.key: error});
      }
    }

    return errors.isEmpty ? null : errors;
  }
}
