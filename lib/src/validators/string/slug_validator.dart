import '../../v_code.dart';
import '../validator.dart';

/// Validates that a string is a valid URL slug.
class SlugValidator extends Validator<String> {
  /// Creates a [SlugValidator].
  const SlugValidator();

  @override
  String get code => VStringCode.slug;

  @override
  Map<String, dynamic>? validate(String value) {
    final regex = RegExp(r'^[a-z0-9]+(-[a-z0-9]+)*$');
    return regex.hasMatch(value) ? null : {};
  }
}
