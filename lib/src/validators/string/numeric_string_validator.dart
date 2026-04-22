import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

/// Validates that a string is parseable as a finite `double`.
///
/// Delegates to `double.tryParse(value)` and additionally rejects
/// non-finite values (`NaN`, `Infinity`, `-Infinity`). Accepts integer,
/// decimal and scientific notation; rejects whitespace padding, hex
/// prefixes and empty strings.
class NumericStringValidator extends Validator<String> {
  /// Creates a [NumericStringValidator].
  const NumericStringValidator();

  @override
  String get code => VCode.stringNumeric;

  @override
  Map<String, dynamic>? validate(String value) {
    if (value.isEmpty || value != value.trim()) return {};

    final parsed = double.tryParse(value);

    if (parsed == null || !parsed.isFinite) return {};

    return null;
  }
}
