import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

/// Validates that a string is a valid URL slug.
class SlugValidator extends Validator<String> {
  /// Creates a [SlugValidator].
  const SlugValidator();

  @override
  String get code => VCode.slug;

  @override
  Map<String, dynamic>? validate(String value) {
    final regex = RegExp(r'^[a-z0-9]+(-[a-z0-9]+)*$');
    return regex.hasMatch(value) ? null : {};
  }
}
