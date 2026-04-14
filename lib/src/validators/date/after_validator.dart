import 'package:validart/src/validators/validator.dart';

class AfterValidator extends Validator<DateTime> {
  final DateTime date;

  const AfterValidator({required this.date, required super.message});

  @override
  String get code => 'too_small';

  @override
  String? validate(DateTime value) => value.isAfter(date) ? null : message;
}
