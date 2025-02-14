import 'package:keeper/src/validators/string/pattern_validator.dart';

class UrlValidator extends PatternValidator {
  UrlValidator({required super.message})
    : super(
        r'[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)',
      );
}
