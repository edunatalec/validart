import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

class AfterValidator extends Validator<DateTime> {
  final DateTime date;

  const AfterValidator({required this.date});

  @override
  String get code => VCode.dateTooSmall;

  @override
  Map<String, dynamic>? validate(DateTime value) =>
      value.isAfter(date) ? null : {'date': date};
}
