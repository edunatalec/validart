import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

class SlugValidator extends Validator<String> {
  const SlugValidator();

  @override
  String get code => VCode.slug;

  @override
  Map<String, dynamic>? validate(String value) {
    final regex = RegExp(r'^[a-z0-9]+(-[a-z0-9]+)*$');
    return regex.hasMatch(value) ? null : {};
  }
}
