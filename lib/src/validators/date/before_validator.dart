import 'package:validart/src/validators/validator.dart';

class BeforeValidator extends Validator<DateTime> {
  final DateTime date;

  const BeforeValidator({required this.date, required super.message});

  @override
  String get code => 'too_big';

  @override
  String? validate(DateTime value) => value.isBefore(date) ? null : message;
}
