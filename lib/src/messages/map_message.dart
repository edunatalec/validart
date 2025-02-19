import 'package:validart/src/messages/array_message.dart';
import 'package:validart/src/messages/base_message.dart';

/// A message class for validation errors related to `Map<String, dynamic>` values.
///
/// Extends [BaseMessage] to include standard validation messages such as required,
/// refine, any, every, and array validation.
///
/// ### Example
/// ```dart
/// final mapMessage = MapMessage(
///   required: 'A map is required',
///   refine: 'Invalid map format',
/// );
///
/// print(mapMessage.required); // 'A map is required'
/// print(mapMessage.refine);   // 'Invalid map format'
/// ```
class MapMessage extends BaseMessage {
  /// Creates a new instance of `MapMessage` with optional custom error messages.
  ///
  /// If no messages are provided, default values will be used.
  MapMessage({
    super.any,
    super.array,
    super.every,
    super.refine,
    super.required,
  });

  /// Merges the current `MapMessage` instance with a `BaseMessage`,
  /// replacing only the undefined values with those from the base.
  ///
  /// This allows inheriting common validation messages while keeping
  /// specific map-related messages intact.
  ///
  /// ## Example:
  /// ```dart
  /// final baseMessage = BaseMessage(required: 'This field is mandatory');
  /// final mapMessage = MapMessage().mergeWithBase(baseMessage);
  ///
  /// print(mapMessage.required); // Output: 'This field is mandatory'
  /// ```
  MapMessage mergeWithBase(BaseMessage base) {
    return copyWith(
      any: base.any,
      array: base.array,
      every: base.every,
      refine: base.refine,
      required: base.required,
    );
  }

  /// Creates a copy of the current `MapMessage` instance with updated values.
  ///
  /// If a parameter is not provided, the existing value is retained.
  ///
  /// ## Example:
  /// ```dart
  /// final defaultMessage = MapMessage();
  /// final customMessage = defaultMessage.copyWith(required: 'A map is required');
  /// print(customMessage.required); // Output: 'A map is required'
  /// ```
  @override
  MapMessage copyWith({
    String? any,
    ArrayMessage? array,
    String? every,
    String? refine,
    String? required,
  }) {
    return MapMessage(
      any: any ?? this.any,
      array: array ?? this.array,
      every: every ?? this.every,
      refine: refine ?? this.refine,
      required: required ?? this.required,
    );
  }
}
