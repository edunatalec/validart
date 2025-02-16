import 'package:keeper/src/messages/map_message.dart';
import 'package:keeper/src/types/type.dart';
import 'package:keeper/src/validators/refine_map_validator.dart';
import 'package:keeper/src/validators/required_validator.dart';
import 'package:keeper/src/validators/validator.dart';

/// A validator for `Map<String, dynamic>` values, enabling object validation.
///
/// Example usage:
/// ```dart
/// final k = Keeper();
///
/// final validator = k.map({
///   'email': k.string().email(),
///   'password': k.string().min(8).max(20),
/// });
///
/// print(validator.validate({'email': 'user@example.com', 'password': 'secure123'})); // true
/// print(validator.validate({'email': 'invalid-email', 'password': '123'})); // false
/// ```
class KMap extends KType<Map<String, dynamic>> {
  /// Stores the object schema definition.
  final Map<String, KType> _object;

  /// Stores the validation messages for `Map`-related errors.
  final MapMessage _message;

  /// Creates an instance of `KMap` with a given schema and optional custom messages.
  ///
  /// Ensures the object is not empty by default.
  KMap(this._object, this._message, {String? message}) {
    assert(_object.isNotEmpty, 'Map must have at least one field.');
    add(RequiredValidator(message: message ?? _message.required));
  }

  /// Retrieves the object schema.
  Map<String, KType> get object => _object;

  /// Adds a validator to the `KMap` instance.
  ///
  /// Allows chaining multiple validation rules.
  @override
  KMap add(KValidator<Map<String, dynamic>> validator) {
    super.add(validator);
    return this;
  }

  /// Validates that the object matches **any** of the provided `KMap` validators.
  ///
  /// Example:
  /// ```dart
  /// final validator = k.map({
  ///   'name': k.string()
  /// }).any([
  ///   k.map({'age': k.int().min(18)}),
  ///   k.map({'email': k.string().email()}),
  /// ]);
  ///
  /// print(validator.validate({'age': 25})); // true
  /// print(validator.validate({'email': 'user@example.com'})); // true
  /// print(validator.validate({'phone': '12345'})); // false
  /// ```
  @override
  KMap any(covariant List<KMap> types, {String? message}) {
    super.any(types, message: message ?? _message.any);
    return this;
  }

  /// Ensures that the object meets **all** the specified validation rules.
  ///
  /// Example:
  /// ```dart
  /// final validator = k.map({
  ///   'email': k.string().email(),
  ///   'password': k.string().min(8),
  /// }).every([
  ///   k.map({'password': k.string().max(20)}),
  /// ]);
  ///
  /// print(validator.validate({'email': 'user@example.com', 'password': 'secure123'})); // true
  /// print(validator.validate({'email': 'user@example.com', 'password': 'verylongpassword123'})); // false
  /// ```
  @override
  KMap every(covariant List<KMap> types, {String? message}) {
    super.every(types, message: message ?? _message.every);
    return this;
  }

  /// Marks the object as optional, allowing it to be omitted.
  ///
  /// Example:
  /// ```dart
  /// final validator = k.map({'name': k.string()}).optional();
  /// print(validator.validate(null)); // true
  /// ```
  @override
  KMap optional() {
    super.optional();
    return this;
  }

  /// Marks the object as nullable, allowing it to be `null`.
  ///
  /// Example:
  /// ```dart
  /// final validator = k.map({'name': k.string()}).nullable();
  /// print(validator.validate(null)); // true
  /// ```
  @override
  KMap nullable() {
    super.nullable();
    return this;
  }

  /// Applies a custom validation function to the object.
  ///
  /// Example (password confirmation):
  /// ```dart
  /// final validator = k.map({
  ///   'password': k.string().min(8),
  ///   'confirmPassword': k.string().min(8),
  /// }).refine(
  ///   (data) => data?['password'] == data?['confirmPassword'],
  ///   path: 'confirmPassword',
  ///   message: 'Passwords do not match',
  /// );
  ///
  /// print(validator.validate({'password': 'secure123', 'confirmPassword': 'secure123'})); // true
  /// print(validator.validate({'password': 'secure123', 'confirmPassword': 'wrongpass'})); // false
  /// ```
  KMap refine(
    bool Function(Map<String, dynamic>? data) validator, {
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
  /// final validator = k.map({
  ///   'email': k.string().email(),
  ///   'password': k.string().min(8),
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

        if (validator is RefineMapValidator) {
          errors.addAll({validator.path: message});
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
