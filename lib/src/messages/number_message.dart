import 'package:validart/src/messages/base_message.dart';

/// A message container for validation errors related to numerical values.
///
/// This class extends `BaseMessage` and provides validation messages specific
/// to numerical types, supporting generic types that extend `num`, such as `int` and `double`.
///
/// ## Example usage:
/// ```dart
/// final numberMessages = NumberMessage<int>(
///   min: (value) => 'The number must be at least $value',
///   max: (value) => 'The number must be at most $value',
///   positive: 'The number must be positive',
///   negative: 'The number must be negative',
/// );
/// ```
class NumberMessage<T extends num> extends BaseMessage {
  /// Message for the validation that ensures a number is within a range.
  ///
  /// Defaults to `'The number must be between {min} and {max}'`.
  final String Function(T min, T max) between;

  /// Message for the validation that ensures a number is negative.
  ///
  /// Defaults to `'The number must be negative'`.
  final String negative;

  /// Message for the maximum allowed value validation.
  ///
  /// Defaults to `'The number must be at most {max}'`.
  final String Function(T max) max;

  /// Message for the minimum allowed value validation.
  ///
  /// Defaults to `'The number must be at least {min}'`.
  final String Function(T min) min;

  /// Message for the "multiple of" validation.
  ///
  /// Defaults to `'The number must be a multiple of {multiple}'`.
  final String Function(T multipleOf) multipleOf;

  /// Message for the validation that ensures a number is positive.
  ///
  /// Defaults to `'The number must be positive'`.
  final String positive;

  /// Creates a new instance of `NumberMessage` with customizable validation messages.
  ///
  /// If no custom messages are provided, default messages will be used.
  NumberMessage({
    super.any,
    super.array,
    super.every,
    super.refine,
    super.required,
    String Function(T min, T max)? between,
    String? negative,
    String Function(T max)? max,
    String Function(T min)? min,
    String Function(T multipleOf)? multipleOf,
    String? positive,
  })  : between = between ??
            ((min, max) => 'The number must be between $min and $max'),
        max = max ?? ((max) => 'The number must be at most $max'),
        min = min ?? ((min) => 'The number must be at least $min'),
        multipleOf = multipleOf ??
            ((multiple) => 'The number must be a multiple of $multiple'),
        negative = negative ?? 'The number must be negative',
        positive = positive ?? 'The number must be positive';
}
