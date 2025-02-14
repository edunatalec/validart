import 'package:keeper/src/validators/string/pattern_validator.dart';

class EmailValidator extends PatternValidator {
  EmailValidator({required super.message})
    : super(
        r"^(?!.*\.\.)[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+\.[a-zA-Z]{2,}$",
      );
}
