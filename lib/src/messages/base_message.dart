/// A base class for validation messages used in the Validart validation library.
///
/// This class provides default error messages for common validation scenarios
/// such as required fields, refinement checks, and logical validators like `any`
/// and `every`.
class BaseMessage {
  /// The error message used when a required value is missing.
  ///
  /// Defaults to `'Required'`.
  final String required;

  /// The error message used when a custom refinement validation fails.
  ///
  /// Defaults to `'Invalid value'`.
  final String refine;

  /// The error message used when at least one of multiple validators must pass (`or` condition).
  ///
  /// Defaults to `'Invalid value'`.
  final String any;

  /// The error message used when all of multiple validators must pass (`and` condition).
  ///
  /// Defaults to `'Invalid value'`.
  final String every;

  /// Creates a new instance of `BaseMessage` with optional custom error messages.
  ///
  /// If no message is provided, the default values are used.
  const BaseMessage({
    String? required,
    String? refine,
    String? any,
    String? every,
  }) : required = required ?? 'Required',
       refine = refine ?? 'Invalid value',
       any = any ?? 'Invalid value',
       every = every ?? 'Invalid value';

  /// Creates a copy of the current `BaseMessage` instance with updated values.
  ///
  /// If a parameter is not provided, the existing value is retained.
  ///
  /// Example:
  /// ```dart
  /// final defaultMessage = BaseMessage();
  /// final customMessage = defaultMessage.copyWith(required: 'This field is mandatory');
  /// print(customMessage.required); // Output: 'This field is mandatory'
  /// ```
  BaseMessage copyWith({
    String? required,
    String? refine,
    String? any,
    String? every,
  }) {
    return BaseMessage(
      required: required ?? this.required,
      refine: refine ?? this.refine,
      any: any ?? this.any,
      every: every ?? this.every,
    );
  }
}
