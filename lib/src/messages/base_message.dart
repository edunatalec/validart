import 'package:validart/src/messages/array_message.dart';

/// A base class for validation messages used in the Validart validation library.
///
/// This class provides default error messages for common validation scenarios
/// such as required fields, refinement checks, and logical validators like `any`
/// and `every`, as well as validation messages related to arrays.
class BaseMessage {
  /// The error message used when at least one of multiple validators must pass (`or` condition).
  ///
  /// Defaults to `'Invalid value'`.
  final String any;

  /// The error message container for array-related validation errors.
  final ArrayMessage array;

  /// The error message used when all of multiple validators must pass (`and` condition).
  ///
  /// Defaults to `'Invalid value'`.
  final String every;

  /// The error message used when a custom refinement validation fails.
  ///
  /// Defaults to `'Invalid value'`.
  final String refine;

  /// The error message used when a required value is missing.
  ///
  /// Defaults to `'Required'`.
  final String required;

  /// Creates a new instance of `BaseMessage` with optional custom error messages.
  ///
  /// If no message is provided, the default values are used.
  const BaseMessage({
    String? any,
    ArrayMessage? array,
    String? every,
    String? refine,
    String? required,
  })  : any = any ?? 'Invalid value',
        array = array ?? const ArrayMessage(),
        every = every ?? 'Invalid value',
        refine = refine ?? 'Invalid value',
        required = required ?? 'Required';

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
    String? any,
    ArrayMessage? array,
    String? every,
    String? refine,
    String? required,
  }) {
    return BaseMessage(
      any: any ?? this.any,
      array: array ?? this.array,
      every: every ?? this.every,
      refine: refine ?? this.refine,
      required: required ?? this.required,
    );
  }
}
