import 'package:keeper/src/validators/validator.dart';

class RequiredValidator<T> extends KValidator<T> {
  RequiredValidator({required super.message});

  @override
  String? validate(value) {
    if (value == null) return message;
    if (value is Map && value.isEmpty) return message;
    if (value is String && value.isEmpty) return message;

    return null;
  }
}
