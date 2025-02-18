import 'package:validart/src/messages/base_message.dart';

/// A message container for validation errors related to numerical values.
///
/// This class extends `BaseMessage` and provides validation messages specific
/// to numerical types, supporting generic types that extend `num`, such as `int` and `double`.
///
/// Example usage:
/// ```dart
/// final numberMessages = NumberMessage<int>(
///   min: (value) => 'The number must be at least $value',
///   max: (value) => 'The number must be at most $value',
///   positive: 'The number must be positive',
///   negative: 'The number must be negative',
/// );
/// ```
class NumberMessage<T extends num> extends BaseMessage {
  /// Message for the minimum allowed value validation.
  final String Function(T min) min;

  /// Message for the maximum allowed value validation.
  final String Function(T max) max;

  /// Message for the "multiple of" validation.
  final String Function(T multipleOf) multipleOf;

  /// Message for the validation that ensures a number is within a range.
  final String Function(T min, T max) between;

  /// Message for the validation that ensures a number is positive.
  final String positive;

  /// Message for the validation that ensures a number is negative.
  final String negative;

  /// Creates a new instance of `NumberMessage` with customizable validation messages.
  ///
  /// If no custom messages are provided, default messages will be used.
  NumberMessage({
    super.required,
    super.refine,
    super.any,
    super.every,
    String Function(T min)? min,
    String Function(T max)? max,
    String Function(T multipleOf)? multipleOf,
    String Function(T min, T max)? between,
    String? positive,
    String? negative,
  })  : min = min ?? ((min) => 'The number must be at least $min'),
        max = max ?? ((max) => 'The number must be at most $max'),
        multipleOf = multipleOf ??
            ((multiple) => 'The number must be a multiple of $multiple'),
        between = between ??
            ((min, max) => 'The number must be between $min and $max'),
        positive = positive ?? 'The number must be positive',
        negative = negative ?? 'The number must be negative';
}
