import 'package:validart/src/messages/array_message.dart';
import 'package:validart/src/messages/base_message.dart';

/// A message class for boolean (`true`/`false`) validation errors.
///
/// Extends [BaseMessage] to include specific messages for boolean validation,
/// such as enforcing `true` or `false` values.
class BoolMessage extends BaseMessage {
  /// The error message displayed when the value is expected to be `false` but isn't.
  ///
  /// Defaults to `'The value must be false'`.
  final String isFalse;

  /// The error message displayed when the value is expected to be `true` but isn't.
  ///
  /// Defaults to `'The value must be true'`.
  final String isTrue;

  /// Creates a new instance of `BoolMessage` with optional custom error messages.
  ///
  /// If no message is provided, default values are used.
  const BoolMessage({
    super.any,
    super.array,
    super.every,
    super.refine,
    super.required,
    String? isFalse,
    String? isTrue,
  })  : isFalse = isFalse ?? 'The value must be false',
        isTrue = isTrue ?? 'The value must be true';

  /// Merges the current `BoolMessage` instance with a `BaseMessage`,
  /// replacing only the undefined values with those from the base.
  ///
  /// Example:
  /// ```dart
  /// final baseMessage = BaseMessage(required: 'This field is mandatory');
  /// final boolMessage = BoolMessage().mergeWithBase(baseMessage);
  ///
  /// print(boolMessage.required); // Output: 'This field is mandatory'
  /// print(boolMessage.isTrue);   // Output: 'The value must be true'
  /// ```
  BoolMessage mergeWithBase(BaseMessage base) {
    return copyWith(
      any: base.any,
      array: base.array,
      every: base.every,
      refine: base.refine,
      required: base.required,
    );
  }

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
    String? any,
    ArrayMessage? array,
    String? every,
    String? isFalse,
    String? isTrue,
    String? refine,
    String? required,
  }) {
    return BoolMessage(
      any: any ?? this.any,
      array: array ?? this.array,
      every: every ?? this.every,
      isFalse: isFalse ?? this.isFalse,
      isTrue: isTrue ?? this.isTrue,
      refine: refine ?? this.refine,
      required: required ?? this.required,
    );
  }
}
