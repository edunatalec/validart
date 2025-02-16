import 'package:keeper/src/messages/base_message.dart';

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
}
