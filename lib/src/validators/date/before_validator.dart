import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

class BeforeValidator extends Validator<DateTime> {
  final DateTime date;

  const BeforeValidator({required this.date});

  @override
  String get code => VCode.tooBig;

  @override
  Map<String, dynamic>? validate(DateTime value) =>
      value.isBefore(date) ? null : {'date': date};
}
