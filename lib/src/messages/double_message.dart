import 'package:validart/src/messages/array_message.dart';
import 'package:validart/src/messages/base_message.dart';
import 'package:validart/src/messages/number_message.dart';

/// A message class for validation errors related to `double` values.
///
/// Extends [NumberMessage] to include additional validation messages
/// specific to `double` numbers, such as checking for finite values,
/// decimal numbers, and integer constraints.
///
/// ## Example Usage:
/// ```dart
/// final doubleMessage = DoubleMessage(
///   finite: 'The number must be finite',
///   decimal: 'The number must be a decimal',
///   integer: 'The number must be an integer',
/// );
///
/// print(doubleMessage.finite); // 'The number must be finite'
/// print(doubleMessage.decimal); // 'The number must be a decimal'
/// print(doubleMessage.integer); // 'The number must be an integer'
/// ```
class DoubleMessage extends NumberMessage<double> {
  /// The error message displayed when the value is not a decimal (i.e., it's an integer).
  ///
  /// Defaults to `'The number must be a decimal (not an integer)'`.
  final String decimal;

  /// The error message displayed when the value is not finite.
  ///
  /// Defaults to `'The number must be finite'`.
  final String finite;

  /// The error message displayed when the value is expected to be an integer but isn't.
  ///
  /// Defaults to `'The number must be an integer'`.
  final String integer;

  /// Creates a new instance of `DoubleMessage` with optional custom error messages.
  ///
  /// If no messages are provided, default values will be used.
  DoubleMessage({
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
    String? decimal,
    String? finite,
    String? integer,
  })  : decimal = decimal ?? 'The number must be a decimal (not an integer)',
        finite = finite ?? 'The number must be finite',
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
      any: base.any,
      array: base.array,
      every: base.every,
      refine: base.refine,
      required: base.required,
    );
  }

  /// Creates a copy of the current `DoubleMessage` instance with updated values.
  ///
  /// If a parameter is not provided, the existing value is retained.
  ///
  /// ## Example:
  /// ```dart
  /// final defaultMessage = DoubleMessage();
  /// final customMessage = defaultMessage.copyWith(decimal: 'Must be a decimal number');
  /// print(customMessage.decimal); // Output: 'Must be a decimal number'
  /// ```
  @override
  DoubleMessage copyWith({
    String? any,
    ArrayMessage? array,
    String Function(double min, double max)? between,
    String? decimal,
    String? every,
    String? finite,
    String? integer,
    String Function(double max)? max,
    String Function(double min)? min,
    String Function(double multipleOf)? multipleOf,
    String? negative,
    String? positive,
    String? refine,
    String? required,
  }) {
    return DoubleMessage(
      any: any ?? this.any,
      array: array ?? this.array,
      between: between ?? this.between,
      decimal: decimal ?? this.decimal,
      every: every ?? this.every,
      finite: finite ?? this.finite,
      integer: integer ?? this.integer,
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
