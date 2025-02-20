import 'package:validart/src/messages/array_message.dart';
import 'package:validart/src/messages/base_message.dart';
import 'package:validart/src/messages/number_message.dart';

/// A message container for validation errors related to `num` values.
///
/// This class extends `NumberMessage<num>`, inheriting general validation messages
/// for numerical types while allowing customization for `num`-specific error messages.
///
/// ### Example
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
    super.any,
    super.array,
    super.between,
    super.every,
    super.max,
    super.min,
    super.multipleOf,
    super.negative,
    super.positive,
    super.refine,
    super.required,
  });

  /// Merges the current `NumMessage` instance with a `BaseMessage`,
  /// replacing only the undefined values with those from the base.
  ///
  /// ### Example
  /// ```dart
  /// final baseMessage = BaseMessage(required: 'This field is mandatory');
  /// final numMessage = NumMessage().mergeWithBase(baseMessage);
  ///
  /// print(numMessage.required); // Output: 'This field is mandatory'
  /// print(numMessage.positive); // Output: 'The number must be positive'
  /// ```
  NumMessage mergeWithBase(BaseMessage base) {
    return copyWith(
      any: base.any,
      array: base.array,
      every: base.every,
      refine: base.refine,
      required: base.required,
    );
  }

  /// Creates a copy of the current `NumMessage` instance with updated values.
  ///
  /// If a parameter is not provided, the existing value is retained.
  ///
  /// ### Example
  /// ```dart
  /// final defaultMessage = NumMessage();
  /// final customMessage = defaultMessage.copyWith(positive: 'Must be positive');
  /// print(customMessage.positive); // Output: 'Must be positive'
  /// ```
  @override
  NumMessage copyWith({
    String? any,
    ArrayMessage? array,
    String Function(num min, num max)? between,
    String? every,
    String Function(num max)? max,
    String Function(num min)? min,
    String Function(num multipleOf)? multipleOf,
    String? negative,
    String? positive,
    String? refine,
    String? required,
  }) {
    return NumMessage(
      any: any ?? this.any,
      array: array ?? this.array,
      between: between ?? this.between,
      every: every ?? this.every,
      max: max ?? this.max,
      min: min ?? this.min,
      multipleOf: multipleOf ?? this.multipleOf,
      negative: negative ?? this.negative,
      positive: positive ?? this.positive,
      refine: refine ?? this.refine,
      required: required ?? this.required,
    );
  }
}
