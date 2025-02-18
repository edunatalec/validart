import 'package:validart/src/messages/base_message.dart';
import 'package:validart/src/messages/number_message.dart';

/// A message container for validation errors related to `num` values.
///
/// This class extends `NumberMessage<num>`, inheriting general validation messages
/// for numerical types while allowing customization for `num`-specific error messages.
///
/// Example usage:
/// ```dart
/// final numMessages = NumMessage(
///   min: (value) => 'The number must be at least $value',
///   max: (value) => 'The number must be at most $value',
/// );
/// ```
class NumMessage extends NumberMessage<num> {
  /// Creates a new instance of `NumMessage` with customizable validation messages.
  ///
  /// If no custom messages are provided, default messages will be used.
  NumMessage({
    super.required,
    super.refine,
    super.any,
    super.every,
    super.min,
    super.max,
    super.multipleOf,
    super.between,
    super.positive,
    super.negative,
  });

  /// Merges the current `NumMessage` instance with a `BaseMessage`,
  /// replacing only the undefined values with those from the base.
  ///
  /// Example:
  /// ```dart
  /// final baseMessage = BaseMessage(required: 'This field is mandatory');
  /// final numMessage = NumMessage().mergeWithBase(baseMessage);
  ///
  /// print(numMessage.required); // Output: 'This field is mandatory'
  /// print(numMessage.positive); // Output: 'The number must be positive'
  /// ```
  NumMessage mergeWithBase(BaseMessage base) {
    return copyWith(
      required: base.required,
      refine: base.refine,
      any: base.any,
      every: base.every,
    );
  }

  /// Creates a copy of the current `NumMessage` instance with updated values.
  ///
  /// If a parameter is not provided, the existing value is retained.
  ///
  /// Example:
  /// ```dart
  /// final defaultMessage = NumMessage();
  /// final customMessage = defaultMessage.copyWith(positive: 'Must be positive');
  /// print(customMessage.positive); // Output: 'Must be positive'
  /// ```
  @override
  NumMessage copyWith({
    String? required,
    String? refine,
    String? any,
    String? every,
    String Function(num min)? min,
    String Function(num max)? max,
    String Function(num multipleOf)? multipleOf,
    String Function(num min, num max)? between,
    String? positive,
    String? negative,
  }) {
    return NumMessage(
      required: required ?? this.required,
      refine: refine ?? this.refine,
      any: any ?? this.any,
      every: every ?? this.every,
      min: min ?? this.min,
      max: max ?? this.max,
      multipleOf: multipleOf ?? this.multipleOf,
      between: between ?? this.between,
      positive: positive ?? this.positive,
      negative: negative ?? this.negative,
    );
  }
}
