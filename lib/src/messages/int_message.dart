import 'package:validart/src/messages/array_message.dart';
import 'package:validart/src/messages/base_message.dart';
import 'package:validart/src/messages/number_message.dart';

/// A message class for validation errors related to `int` values.
///
/// Extends [NumberMessage] to include additional validation messages
/// specific to `int` numbers, such as checking for odd, even, and prime values.
///
/// ### Example
/// ```dart
/// final intMessage = IntMessage(
///   odd: 'The number must be odd',
///   even: 'The number must be even',
///   prime: 'The number must be prime',
/// );
///
/// print(intMessage.odd); // 'The number must be odd'
/// print(intMessage.even); // 'The number must be even'
/// print(intMessage.prime); // 'The number must be prime'
/// ```
class IntMessage extends NumberMessage<int> {
  /// The error message displayed when the number is expected to be even but isn't.
  ///
  /// Defaults to `'The number must be even'`.
  final String even;

  /// The error message displayed when the number is expected to be odd but isn't.
  ///
  /// Defaults to `'The number must be odd'`.
  final String odd;

  /// The error message displayed when the number is expected to be prime but isn't.
  ///
  /// Defaults to `'The number must be a prime number'`.
  final String prime;

  /// Creates a new instance of `IntMessage` with optional custom error messages.
  ///
  /// If no messages are provided, default values will be used.
  IntMessage({
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
    String? even,
    String? odd,
    String? prime,
  })  : even = even ?? 'The number must be even',
        odd = odd ?? 'The number must be odd',
        prime = prime ?? 'The number must be a prime number';

  /// Merges the current `IntMessage` instance with a `BaseMessage`,
  /// replacing only the undefined values with those from the base.
  ///
  /// Example:
  /// ```dart
  /// final baseMessage = BaseMessage(required: 'This field is mandatory');
  /// final intMessage = IntMessage().mergeWithBase(baseMessage);
  ///
  /// print(intMessage.required); // Output: 'This field is mandatory'
  /// print(intMessage.odd);      // Output: 'The number must be odd'
  /// ```
  IntMessage mergeWithBase(BaseMessage base) {
    return copyWith(
      any: base.any,
      array: base.array,
      every: base.every,
      refine: base.refine,
      required: base.required,
    );
  }

  /// Creates a copy of the current `IntMessage` instance with updated values.
  ///
  /// If a parameter is not provided, the existing value is retained.
  ///
  /// ## Example:
  /// ```dart
  /// final defaultMessage = IntMessage();
  /// final customMessage = defaultMessage.copyWith(odd: 'Must be an odd number');
  /// print(customMessage.odd); // Output: 'Must be an odd number'
  /// ```
  @override
  IntMessage copyWith({
    String? any,
    ArrayMessage? array,
    String Function(int min, int max)? between,
    String? even,
    String? every,
    String Function(int max)? max,
    String Function(int min)? min,
    String Function(int multipleOf)? multipleOf,
    String? negative,
    String? odd,
    String? positive,
    String? prime,
    String? refine,
    String? required,
  }) {
    return IntMessage(
      any: any ?? this.any,
      array: array ?? this.array,
      between: between ?? this.between,
      even: even ?? this.even,
      every: every ?? this.every,
      max: max ?? this.max,
      min: min ?? this.min,
      multipleOf: multipleOf ?? this.multipleOf,
      negative: negative ?? this.negative,
      odd: odd ?? this.odd,
      positive: positive ?? this.positive,
      prime: prime ?? this.prime,
      refine: refine ?? this.refine,
      required: required ?? this.required,
    );
  }
}
