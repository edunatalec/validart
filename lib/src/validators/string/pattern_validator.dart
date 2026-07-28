import '../../v_code.dart';
import '../validator.dart';

/// Validates that a string matches the given regular expression [pattern].
class PatternValidator extends Validator<String> {
  /// Creates a [PatternValidator] with the given [pattern].
  const PatternValidator({required this.pattern});

  /// The regular expression pattern to match against.
  final String pattern;

  @override
  String get code => VStringCode.format;

  @override
  Map<String, dynamic>? validate(String value) {
    final regex = RegExp(pattern);
    return regex.hasMatch(value) ? null : {'pattern': pattern};
  }
}
