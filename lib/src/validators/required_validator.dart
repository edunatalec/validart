import 'package:keeper/src/validators/validator.dart';

class RequiredValidator<T> extends KValidator<T> {
  RequiredValidator({required super.message});

  @override
  String? validate(value) {
    if (value == null) return message;
    if (value is String && value.isEmpty) return message;
    if (value is Iterable && value.isEmpty) return message;
    if (value is num && value == 0) return message;

    return null;
  }
}
