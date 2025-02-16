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
}
