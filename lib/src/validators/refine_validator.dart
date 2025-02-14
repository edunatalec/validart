import 'package:keeper/src/validators/validator.dart';

class RefineValidator<T> extends KValidator<T> {
  final bool Function(T? data) validator;

  RefineValidator(this.validator, {required super.message});

  @override
  String? validate(value) {
    return validator(value) ? null : message;
  }
}
