import 'package:keeper/src/messages/base_message.dart';

/// A message class for boolean (`true`/`false`) validation errors.
///
/// Extends [BaseMessage] to include specific messages for boolean validation,
/// such as enforcing `true` or `false` values.
class BoolMessage extends BaseMessage {
  /// The error message displayed when the value is expected to be `true` but isn't.
  ///
  /// Defaults to `'The value must be true'`.
  final String isTrue;

  /// The error message displayed when the value is expected to be `false` but isn't.
  ///
  /// Defaults to `'The value must be false'`.
  final String isFalse;

  /// Creates a new instance of `BoolMessage` with optional custom error messages.
  ///
  /// If no message is provided, default values are used.
  const BoolMessage({
    super.required,
    super.refine,
    super.any,
    super.every,
    String? isTrue,
    String? isFalse,
  }) : isTrue = isTrue ?? 'The value must be true',
       isFalse = isFalse ?? 'The value must be false';

  /// Creates a copy of the current `BoolMessage` instance with updated values.
  ///
  /// If a parameter is not provided, the existing value is retained.
  ///
  /// Example:
  /// ```dart
  /// final defaultMessage = BoolMessage();
  /// final customMessage = defaultMessage.copyWith(isTrue: 'Must be checked');
  /// print(customMessage.isTrue); // Output: 'Must be checked'
  /// ```
  @override
  BoolMessage copyWith({
    String? required,
    String? refine,
    String? isTrue,
    String? isFalse,
    String? any,
    String? every,
  }) {
    return BoolMessage(
      required: required ?? this.required,
      refine: refine ?? this.refine,
      any: any ?? this.any,
      every: every ?? this.every,
      isTrue: isTrue ?? this.isTrue,
      isFalse: isFalse ?? this.isFalse,
    );
  }
}
