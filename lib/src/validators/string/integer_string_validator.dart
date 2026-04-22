import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

/// Validates that a string is parseable as a Dart `int` in decimal base.
///
/// Delegates to `int.tryParse(value)`: accepts an optional leading `+`/`-`
/// followed by decimal digits. Rejects decimal notation, scientific
/// notation, hex prefixes, whitespace padding and empty strings.
class IntegerStringValidator extends Validator<String> {
  /// Creates an [IntegerStringValidator].
  const IntegerStringValidator();

  @override
  String get code => VStringCode.integer;

  @override
  Map<String, dynamic>? validate(String value) {
    if (value.isEmpty || value != value.trim()) return {};

    if (int.tryParse(value, radix: 10) == null) return {};

    return null;
  }
}
