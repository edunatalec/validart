import 'dart:convert';

import '../../v_code.dart';
import '../validator.dart';

/// Validates that a string parses as valid JSON.
class JsonValidator extends Validator<String> {
  /// Creates a [JsonValidator].
  const JsonValidator();

  @override
  String get code => VStringCode.json;

  @override
  Map<String, dynamic>? validate(String value) {
    try {
      jsonDecode(value);
      return null;
    } catch (_) {
      return {};
    }
  }
}
