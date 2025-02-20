import 'package:validart/src/validators/refine_validator.dart';

/// A specialized validator for refining validation logic on a map.
///
/// This validator allows custom validation rules for a map structure
/// and enables error messages to be associated with a specific key path.
///
/// ### Example
/// ```dart
/// final validator = v.map({
///   'email': v.string().email(),
///   'password': v.string().min(8),
///   'confirmPassword': v.string().min(8),
/// }).refine(
///   (data) => data?['password'] == data?['confirmPassword'],
///   path: 'confirmPassword',
///   message: 'Passwords do not match',
/// );
///
/// print(validator.validate({
///   'email': 'test@example.com',
///   'password': 'secret123',
///   'confirmPassword': 'secret123',
/// })); // true
///
/// print(validator.validate({
///   'email': 'test@example.com',
///   'password': 'secret123',
///   'confirmPassword': 'wrongpass',
/// })); // false, because passwords do not match
/// ```
class RefineMapValidator extends RefineValidator<Map<String, dynamic>> {
  /// The key path where the validation error should be reported.
  final String path;

  /// Creates a [RefineMapValidator] with a custom validation function.
  ///
  /// - [validator] is a function that determines whether the map is valid.
  /// - [message] is the error message to display when validation fails.
  /// - [path] is the specific key in the map where the error should be reported.
  RefineMapValidator(
    super.validator, {
    required super.message,
    required this.path,
  });

  @override
  String? validate(value) {
    return validator(value) ? null : message;
  }
}
