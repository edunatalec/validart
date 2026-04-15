import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

/// Validates that a string matches the given regular expression [pattern].
class PatternValidator extends Validator<String> {
  /// The regular expression pattern to match against.
  final String pattern;

  /// Creates a [PatternValidator] with the given [pattern].
  const PatternValidator({required this.pattern});

  @override
  String get code => VCode.invalidFormat;

  @override
  Map<String, dynamic>? validate(String value) {
    final regex = RegExp(pattern);
    return regex.hasMatch(value) ? null : {'pattern': pattern};
  }
}
