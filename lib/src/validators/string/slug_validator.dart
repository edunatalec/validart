import 'package:validart/src/validators/validator.dart';

class SlugValidator extends Validator<String> {
  const SlugValidator({required super.message});

  @override
  String get code => 'slug';

  @override
  String? validate(String value) {
    final regex = RegExp(r'^[a-z0-9]+(-[a-z0-9]+)*$');
    return regex.hasMatch(value) ? null : message;
  }
}
