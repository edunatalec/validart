import 'package:keeper/src/validators/string/pattern_validator.dart';

class TimeValidator extends PatternValidator {
  TimeValidator({required super.message})
    : super(r'^([01]\d|2[0-3]):([0-5]\d)(?::([0-5]\d))?$');
}
