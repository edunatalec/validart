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
///   min: 'The array must have at least {min} items',
///   max: 'The array must have at most {max} items',
/// );
///
/// print(arrayMessage.required); // 'The array cannot be empty'
/// print(arrayMessage.unique);   // 'The array must contain unique values'
/// print(arrayMessage.contains); // 'The array must contain specific values'
/// print(arrayMessage.min);      // 'The array must have at least {min} items'
/// print(arrayMessage.max);      // 'The array must have at most {max} items'
/// ```
///
/// ## Fields:
/// - [contains]: The error message when the array must contain specific values.
/// - [max]: The error message when the array exceeds the maximum allowed length.
/// - [min]: The error message when the array has fewer than the minimum required length.
/// - [required]: The error message when an array is required but missing.
/// - [unique]: The error message when the array must contain unique values.
class ArrayMessage {
  /// The error message displayed when the array must contain specific values.
  ///
  /// Defaults to `'The array must contain required values'`.
  final String contains;

  /// The error message displayed when the array exceeds the maximum allowed length.
  ///
  /// Defaults to `'The array must have at most {max} items'`.
  final String Function(int max) max;

  /// The error message displayed when the array has fewer than the minimum required length.
  ///
  /// Defaults to `'The array must have at least {min} items'`.
  final String Function(int min) min;

  /// The error message used when a custom refinement validation fails.
  ///
  /// Defaults to `'Invalid value'`.
  final String refine;

  /// The error message displayed when an array is required but missing.
  ///
  /// Defaults to `'The array cannot be empty'`.
  final String required;

  /// The error message displayed when the array must contain unique values.
  ///
  /// Defaults to `'The array must contain unique values'`.
  final String unique;

  /// Creates an instance of `ArrayMessage` with optional custom error messages.
  ///
  /// If no messages are provided, default values will be used.
  ArrayMessage({
    String? contains,
    String Function(int max)? max,
    String Function(int min)? min,
    String? refine,
    String? required,
    String? unique,
  })  : contains = contains ?? 'The array must contain required values',
        max = max ?? ((max) => 'The array must have at most $max items'),
        min = min ?? ((min) => 'The array must have at least $min items'),
        refine = refine ?? 'Invalid value',
        required = required ?? 'The array cannot be empty',
        unique = unique ?? 'The array must contain unique values';

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
    String? contains,
    String Function(int max)? max,
    String Function(int min)? min,
    String? refine,
    String? required,
    String? unique,
  }) {
    return ArrayMessage(
      contains: contains ?? this.contains,
      max: max ?? this.max,
      min: min ?? this.min,
      refine: refine ?? this.refine,
      required: required ?? this.required,
      unique: unique ?? this.unique,
    );
  }
}
