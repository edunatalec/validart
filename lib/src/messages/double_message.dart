import 'package:validart/src/messages/base_message.dart';
import 'package:validart/src/messages/number_message.dart';

/// A message class for validation errors related to `double` values.
///
/// Extends [NumberMessage] to include additional validation messages
/// specific to `double` numbers, such as checking for finite values,
/// decimal numbers, and integer constraints.
class DoubleMessage extends NumberMessage<double> {
  /// The error message displayed when the value is not finite.
  ///
  /// Defaults to `'The number must be finite'`.
  final String finite;

  /// The error message displayed when the value is not a decimal (i.e., it's an integer).
  ///
  /// Defaults to `'The number must be a decimal (not an integer)'`.
  final String decimal;

  /// The error message displayed when the value is expected to be an integer but isn't.
  ///
  /// Defaults to `'The number must be an integer'`.
  final String integer;

  /// Creates a new instance of `DoubleMessage` with optional custom error messages.
  ///
  /// If no custom messages are provided, default values will be used.
  DoubleMessage({
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
    String? finite,
    String? decimal,
    String? integer,
  })  : finite = finite ?? 'The number must be finite',
        decimal = decimal ?? 'The number must be a decimal (not an integer)',
        integer = integer ?? 'The number must be an integer';

  /// Merges the current `DoubleMessage` instance with a `BaseMessage`,
  /// replacing only the undefined values with those from the base.
  ///
  /// Example:
  /// ```dart
  /// final baseMessage = BaseMessage(required: 'This field is mandatory');
  /// final doubleMessage = DoubleMessage().mergeWithBase(baseMessage);
  ///
  /// print(doubleMessage.required); // Output: 'This field is mandatory'
  /// print(doubleMessage.finite);   // Output: 'The number must be finite'
  /// ```
  DoubleMessage mergeWithBase(BaseMessage base) {
    return copyWith(
      required: base.required,
      refine: base.refine,
      any: base.any,
      every: base.every,
    );
  }

  /// Creates a copy of the current `DoubleMessage` instance with updated values.
  ///
  /// If a parameter is not provided, the existing value is retained.
  ///
  /// Example:
  /// ```dart
  /// final defaultMessage = DoubleMessage();
  /// final customMessage = defaultMessage.copyWith(decimal: 'Must be a decimal number');
  /// print(customMessage.decimal); // Output: 'Must be a decimal number'
  /// ```
  @override
  DoubleMessage copyWith({
    String? required,
    String? refine,
    String? any,
    String? every,
    String Function(double min)? min,
    String Function(double max)? max,
    String Function(double multipleOf)? multipleOf,
    String Function(double min, double max)? between,
    String? positive,
    String? negative,
    String? finite,
    String? decimal,
    String? integer,
  }) {
    return DoubleMessage(
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
      finite: finite ?? this.finite,
      decimal: decimal ?? this.decimal,
      integer: integer ?? this.integer,
    );
  }
}
