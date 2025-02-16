import 'package:keeper/src/messages/number_message.dart';

/// A message class for validation errors related to `int` values.
///
/// Extends [NumberMessage] to include additional validation messages
/// specific to `int` numbers, such as checking for odd and even values.
class IntMessage extends NumberMessage<int> {
  /// The error message displayed when the number is expected to be odd but isn't.
  ///
  /// Defaults to `'The number must be odd'`.
  final String odd;

  /// The error message displayed when the number is expected to be even but isn't.
  ///
  /// Defaults to `'The number must be even'`.
  final String even;

  /// Creates a new instance of `IntMessage` with optional custom error messages.
  ///
  /// If no custom messages are provided, default values will be used.
  IntMessage({
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
    String? odd,
    String? even,
  }) : odd = odd ?? 'The number must be odd',
       even = even ?? 'The number must be even';

  /// Creates a copy of the current `IntMessage` instance with updated values.
  ///
  /// If a parameter is not provided, the existing value is retained.
  ///
  /// Example:
  /// ```dart
  /// final defaultMessage = IntMessage();
  /// final customMessage = defaultMessage.copyWith(odd: 'Must be an odd number');
  /// print(customMessage.odd); // Output: 'Must be an odd number'
  /// ```
  @override
  IntMessage copyWith({
    String? required,
    String? refine,
    String? any,
    String? every,
    String Function(int min)? min,
    String Function(int max)? max,
    String Function(int multipleOf)? multipleOf,
    String Function(int min, int max)? between,
    String? positive,
    String? negative,
    String? odd,
    String? even,
  }) {
    return IntMessage(
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
      odd: odd ?? this.odd,
      even: even ?? this.even,
    );
  }
}
