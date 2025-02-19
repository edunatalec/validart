/// A message container for validation errors related to array (list) values.
///
/// The `ArrayMessage` class provides predefined error messages for array-based
/// validations, such as required arrays, uniqueness constraints, and containment checks.
///
/// ## Example Usage:
/// ```dart
/// final arrayMessage = ArrayMessage(
///   required: 'The array cannot be empty',
///   unique: 'The array must contain unique values',
///   contains: 'The array must contain specific values',
/// );
///
/// print(arrayMessage.required); // 'The array cannot be empty'
/// print(arrayMessage.unique);   // 'The array must contain unique values'
/// print(arrayMessage.contains); // 'The array must contain specific values'
/// ```
///
/// ## Fields:
/// - [required]: The error message when an array is required but missing.
/// - [unique]: The error message when the array must contain unique values.
/// - [contains]: The error message when the array must contain specific values.
class ArrayMessage {
  /// The error message displayed when an array is required but missing.
  ///
  /// Defaults to an empty string.
  final String required;

  /// The error message displayed when the array must contain unique values.
  ///
  /// Defaults to an empty string.
  final String unique;

  /// The error message displayed when the array must contain specific values.
  ///
  /// Defaults to an empty string.
  final String contains;

  /// Creates an instance of `ArrayMessage` with optional custom error messages.
  ///
  /// If no messages are provided, default values (empty strings) will be used.
  const ArrayMessage({
    String? required,
    String? unique,
    String? contains,
  })  : required = required ?? '',
        unique = unique ?? '',
        contains = contains ?? '';

  /// Creates a copy of the current `ArrayMessage` instance with updated values.
  ///
  /// If a parameter is not provided, the existing value is retained.
  ///
  /// ## Example:
  /// ```dart
  /// final defaultMessage = ArrayMessage();
  /// final customMessage = defaultMessage.copyWith(required: 'List is required');
  /// print(customMessage.required); // Output: 'List is required'
  /// ```
  ArrayMessage copyWith({
    String? required,
    String? unique,
    String? contains,
  }) {
    return ArrayMessage(
      required: required ?? this.required,
      unique: unique ?? this.unique,
      contains: contains ?? this.contains,
    );
  }
}
