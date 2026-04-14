import 'package:validart/src/validators/validator.dart';

class StartsWithValidator extends Validator<String> {
  final String prefix;

  const StartsWithValidator({required this.prefix, required super.message});

  @override
  String get code => 'starts_with';

  @override
  String? validate(String value) => value.startsWith(prefix) ? null : message;
}
