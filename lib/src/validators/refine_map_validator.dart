import 'package:keeper/src/validators/refine_validator.dart';

class RefineMapValidator extends RefineValidator<Map<String, dynamic>> {
  final String path;

  RefineMapValidator(
    super.validator, {
    required super.message,
    required this.path,
  });

  @override
  String? validate(value) {
    return validator(value) ? null : message;
  }
}
