import 'package:validart/src/messages/base_message.dart';

/// A message class for validation errors related to `Map<String, dynamic>` values.
///
/// Extends [BaseMessage] to include standard validation messages such as required,
/// refine, any, and every.
class MapMessage extends BaseMessage {
  /// Creates a new instance of `MapMessage` with optional custom error messages.
  ///
  /// If no custom messages are provided, default values will be used.
  ///
  /// Example:
  /// ```dart
  /// final defaultMessage = MapMessage();
  /// final customMessage = MapMessage(required: 'A map is required');
  /// print(customMessage.required); // Output: 'A map is required'
  /// ```
  const MapMessage({super.required, super.refine, super.any, super.every});

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
  MapMessage mergeWithBase(BaseMessage base) {
    return copyWith(
      required: base.required,
      refine: base.refine,
      any: base.any,
      every: base.every,
    );
  }

  /// Creates a copy of the current `MapMessage` instance with updated values.
  ///
  /// If a parameter is not provided, the existing value is retained.
  ///
  /// Example:
  /// ```dart
  /// final defaultMessage = MapMessage();
  /// final customMessage = defaultMessage.copyWith(required: 'A map is required');
  /// print(customMessage.required); // Output: 'A map is required'
  /// ```
  @override
  MapMessage copyWith({
    String? required,
    String? refine,
    String? any,
    String? every,
  }) {
    return MapMessage(
      required: required ?? this.required,
      refine: refine ?? this.refine,
      any: any ?? this.any,
      every: every ?? this.every,
    );
  }
}
